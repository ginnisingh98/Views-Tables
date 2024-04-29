--------------------------------------------------------
--  DDL for Package Body OZF_ACCRUAL_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_ACCRUAL_ENGINE" AS
/* $Header: ozfacreb.pls 120.56.12010000.12 2010/03/09 08:54:49 bkunjan ship $ */
----------------------------------------------------------------------------------
-- Package Name
--   ozf_accrual_engine
-- PROCEDURES
--   calculate_accrual_amount
--   adjust_accrual
--   Get_Message
-- Purpose
--   Package body for accrual_engine
-- History
--   06/19/00      pjindal        Created
--   06/20/00      mpande         Updated 1) created new procedure CALCULATE_ACCRUAL_AMOUNT
--                                to fix bug assciated to accomodate rollup to more than 2 levels campaigns
--                                and accomodate association of multiple budgets////
--                                        2) Updated Procedure Adjust_accrual to accomodate above requirements
--                                        3) Updated Procedure Get_message for error handling
--                                        4) Updated call to create_utlization
--   12 Sep 2000  mpande          Changed contribution amount to approved amount
--   02 Feb 2001  mpande          Removed Accrual Fund and Benifit Limit check.
--   02 Feb 2001  mpande          Introduced Currency Validation
--   13 JUN 2001  mpande          Updated for hornet requirement
--   03 Aug 2001  mpande          Changed for offer_type and passing order line instead of orders
--   12/03/2001   mpande          Updated for different offers, update of adjustment, line quantity
--   01/23/2002   yzhao           object_type: ORDER_LINE - ORDER   object_id: Line id - order id,
--                                product_level_type = 'PRODUCT'
--   02/15/2002   mpande          Updated for 1) Cancelleld Order
--                                            2) Negative Adjustment
--                                            3) Created a subroutine for utilization
--   6/11/2002    mpande          1) Updated for Exception Handling
--                                2) Accrual Offers Query
--   7/26/2002    mpande          Bug#2459550, Return Order Bug , Fixed
--   1/22/2003    feliu            1)added g_universal_currency.
--                                2)changed ams_actbudgets_pvt.act_util_rec_type
--                                  to ams_fund_utilized_pvt.utilization_rec_type
--                                3)added more columns for utilization_rec_type record.
--                                4)added create_act_budgets and create_utilized_rec.
--                                5)changed ams_fund_adjustment_pvt.process_act_budgets call to
--                                  create_act_budgets and create_utilized_rec.
--   03/19/2003   yzhao           post to GL when order is shipped or invoiced RETURN
--                                added one more parameter to reprocess failed gl postings
--   10/23/2003   yzhao           fix bug 3156515 - PROMOTIONAL GOODS OFFER EXCEEDS THE BUDGET AMOUNT
--   10/14/2003   yzhao           Fix TEVA bug - customer fully accrual budget committed amount is always 0 even when accrual happens
--   10/15/2003   kdass           11.5.10 Accrual Engine Enhancement: Added error log messages using Oracle Logging framework
--   10/20/2003   yzhao           when object sources from sales accrual budget, the budget is treated as fixed budget
--   11/12/2003   kdass           added new procedure log_message to log messages
--   11/19/2003   yzhao           Fix TEVA bug 3268498 - UTILIZATION JOURNALS ARE NOT BEING POSTED FOR ALL LINE ITEMS ON AN ORDER
--                                bug 3156149 - RMA ORDER FAILS TO CREATE JOURNAL ENTRIES TO GENERAL LEDGER
--   11/26/2003   kdass           added new function event_subscription
--   12/02/2003   yzhao           post to GL based on profile 'OZF : Create GL Entries for Orders'
--   12/08/2003   yzhao           fix bug 3291322 - ERRORS IN BUDGET CHECKBOOK > WHEN ACCRUAL BUDGET USED TO FUND OFF-INVOICE OFFER
--   12/10/2003   yzhao           fix TEVA bug 3308544 - ACCRUAL INCORRECT FROM RMAS
--   02/05/2004   yzhao           11.5.10 fix bug 3405449 - post to qualified budget only
--   02/12/2004   yzhao           fix bug 3435420 - do not post to gl for customer accrual budget with liability off
--                                11.5.10 gl posting for off invoice until AutoInvoice workflow is done
--                                        populate cust_account_id with offer's beneficiary account
--                                        populate reference_type/id for special pricing
--   05/11/2004   kdass           fixed bug 3609771
--   06/10/2004   feliu             fixed bug 3667697,3684809
--   08/03/2004   feliu            fixed bug 3813516.
--   14/10/2004   Ribha           Fixed Performance Bug 3917556 for queries on ra_customer_trx_all
--   01/31/2005   kdass           fixed 11.5.9 bug 4067266
--   06/08/2005   kdass           Bug 4415878 SQL Repository Fix - added the column object_id to the cursor c_old_adjustment_amount
--                                in procedure adjust_changed_order. Now passed object_id to the cursor c_split_line
--                                and added condition - AND header_id = p_header_id
--    06/12/2005  Ribha          R12 Changes - populate new columns bill_to_site_use_id/ship_to_site_use_id in ozf_funds_utilized_all_b
--   06/26/2005   Ribha          fixed bug 4173825 - get adjusted_amount from oe_price_adjustments
--   06/26/2005   Ribha          fixed bug 4417084 - for partial return order
--   07/27/2005   Feliu          add enhancement for R12 to insert order info to ozf_sales_transaction table.
--   08/01/2005   Ribha          R12: populate universal currency amount in ozf_funds_utilized_all_b
--   08/02/2005   Ribha          R12: populate new table ozf_object_fund_summary
--   09/21/2005   Ribha          Bug Fix 4619156
--   10/28/2005   Ribha          fixed bug 4676217 (same as 3697213 in 1159)
--   12/23/2005   kdass          Bug 4778995 - removed columns month_id/quarter_id/year_id
--   03/31/2006   kdass          fixed bug 5101720
--   11/09/2006   kpatro         fixed bug 5523042
--   20/09/2006   kpatro         fixed bug 5485334
--   02/24/2007   kdass          fixed bug 5485334 - issue 2
--   03/24/2007   kdass          fixed bug 5900966
--   04/11/2007   kdass          fixed bug 5953774
--   05/11/2007   nirprasa       fixed bug 6021635
--   05/11/2007   nirprasa       fixed bug 6140826 - don't post to GL the utilization amount having orig_utilization_id as -1
--   10/01/2007   nirprasa       fixed bug 6373391
--   19/12/2007   psomyaju       Ship-Debit R12.1 Enhancement: Added code for custom_setup_id 10445
--   17/01/2008   nirprasa       Ship-Debit R12.1 Offer Enhancement:   1)Create utilization even if committed amount is zero.
--   17/01/2008   nirprasa       Ship-Debit R12.1 Autopay Enhancement: 2)bill_to_site_use_id was incorrect in ozf_funds_utilized_all_b
--                                                                       table when offer's autopay party is Customer Name/Customer Bill To
--   21/04/2008   psomyaju       bug 6278466 - FP:11510-R12 6051298 - FUNDS EARNED NOT RECOGNISED AS ELIGBLE FOR CLAIM AND AUTO
--   09/06/2008   nirprasa       bug 7157394 - put the org_id assignment done for bug 6278466 only if beneficiary is not a customer.
--                                             Also, remove the initialization of org_id
--   09/19/2008   nirprasa       bug 6998502 - VOLUME OFFERS ARE NOT APPLIED CORRECTLY ON A SALES ORDER
--   11/09/2008   psomyaju       bug 7431334 - GL ENTRIES ON OFF-INVOICE DISCOUNTS CREATED ON
--   11/24/2008   nirprasa       bug 7030415 - R12SIP WE CAN'T SETUP CURRENY CONVERSION TYPE FOR SPECIFIC OPERATING UNIT
--   02/18/2009   kdass          bug 8258508 - TST1211:UNABLE TO CREATE CLAIM FOR CHILD BATCHES
--   04/24/2009   kpatro         bug 8463331 - FP:7567852:NO EARNED/PAID AMT IF RMA ORDER IS REFERENCED TO ORIGINAL  ORDER
--   05/04/2009   kdass          fixed bug 8421406 - BENEFICIARY WITHIN THE MARKET OPTIONS DO NOT WORK
--   06/25/2009   nirprasa       bug 7654383 - FP:7491702:CREATE GL ENTRY FAILS FOR OFFERS FOR OBSOLECTED CODE IN R12
--   06/25/2009   nirprasa       bug 8435487 - FP:8434980:OZF-TM : F ACCRUAL ENGINE JOB RUNNING MORE THAN 20 HRS FOR
--   06/25/2009   nirprasa       bug 8435499 - FP:8203657:WRONG ASO EVENT GENERATED WHEN WHEN REQUEST DATE AND PRICIN
--   08/13/2009   kdass          bug 8253115 - FP: 11.5.10-R12 7651889 - OZF_FUND_UTILIZED_ALL_B CONTAINS MODIFIERS LINE DELET
--   1/11/2010    nepanda        Bug 9269593 - transfer to gl process is erroring out ec03 error : FP for bug 8994266
--   2/17/2010    nepanda        Bug 9131648 : multi currency changes
--   03/09/2010   bkunjan	 Bug 9382547 - ER SLA Uptake in Channel Revenue Management.
-------------------------------------------------------------------------------
   g_pkg_name   CONSTANT VARCHAR2 (30) := 'OZF_ACCRUAL_ENGINE';
   g_recal_flag CONSTANT VARCHAR2(1) :=  NVL(fnd_profile.value('OZF_BUDGET_ADJ_ALLOW_RECAL'),'N');
   g_debug_flag      VARCHAR2 (1) := 'N';
   G_DEBUG      BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
   g_universal_currency   CONSTANT VARCHAR2 (15) := fnd_profile.VALUE ('OZF_UNIV_CURR_CODE');
   g_order_gl_phase   CONSTANT VARCHAR2 (15) := NVL(fnd_profile.VALUE ('OZF_ORDER_GLPOST_PHASE'), 'SHIPPED');
   g_bulk_limit  CONSTANT NUMBER := 5000;  -- yzhao: Sep 8,2005 bulk fetch limit. It should get from profile.
   g_message_count NUMBER := -1; --nirprasa, added for bug 8435487 to restrict thenumber of ASO messages to be processed

   TYPE utilIdTbl       IS TABLE OF ozf_funds_utilized_all_b.utilization_id%TYPE;
   TYPE objVerTbl       IS TABLE OF ozf_funds_utilized_all_b.object_version_number%TYPE;
   TYPE amountTbl       IS TABLE OF ozf_funds_utilized_all_b.amount%TYPE;
   TYPE planTypeTbl     IS TABLE OF ozf_funds_utilized_all_b.plan_type%TYPE;
   TYPE planIdTbl       IS TABLE OF ozf_funds_utilized_all_b.plan_id%TYPE;
   TYPE planAmtTbl      IS TABLE OF ozf_funds_utilized_all_b.plan_curr_amount%TYPE;
   TYPE utilTypeTbl     IS TABLE OF ozf_funds_utilized_all_b.utilization_type%TYPE;
   TYPE fundIdTbl       IS TABLE OF ozf_funds_utilized_all_b.fund_id%TYPE;
   TYPE acctAmtTbl      IS TABLE OF ozf_funds_utilized_all_b.acctd_amount%TYPE;
   TYPE glDateTbl       IS TABLE OF ozf_funds_utilized_all_b.gl_date%TYPE;
   TYPE orgIdTbl        IS TABLE OF ozf_funds_utilized_all_b.org_id%TYPE;
   TYPE priceAdjTbl     IS TABLE OF ozf_funds_utilized_all_b.price_adjustment_id%TYPE         ;
   TYPE objectIdTbl     IS TABLE OF ozf_funds_utilized_all_b.object_id%TYPE         ;

   --nirprasa, ER 8399134
   TYPE excDateTbl          IS TABLE OF ozf_funds_utilized_all_b.exchange_rate_date%TYPE;
   TYPE excTypeTbl          IS TABLE OF ozf_funds_utilized_all_b.exchange_rate_type%TYPE;
   TYPE currCodeTbl         IS TABLE OF ozf_funds_utilized_all_b.currency_code%TYPE;
   TYPE planCurrCodeTbl     IS TABLE OF ozf_funds_utilized_all_b.plan_currency_code%TYPE;
   TYPE fundReqCurrCodeTbl  IS TABLE OF ozf_funds_utilized_all_b.fund_request_currency_code%TYPE;
   TYPE planCurrAmtTbl      IS TABLE OF ozf_funds_utilized_all_b.plan_curr_amount%TYPE;
   TYPE planCurrAmtRemTbl   IS TABLE OF ozf_funds_utilized_all_b.plan_curr_amount_remaining%TYPE;
   TYPE univCurrAmtTbl      IS TABLE OF ozf_funds_utilized_all_b.univ_curr_amount%TYPE;
----------------------------------------------------------------------------------
-- Procedure Name
--  calculate_accrual_amount
-- created by mpande 07/20/2000
-- 02/13/2002 updated for negative adjustment amount
-- Purpose
--   This procedure will accept p_src_id which could be a CAMP_id or a FUND_ID
-- and return a PL/SQL table which consists all the funds rolled up to the first level
-- with  its contribution amount
-----------------------------------------------------------------------------------

PROCEDURE calculate_accrual_amount (
      x_return_status   OUT NOCOPY      VARCHAR2,
      p_src_id          IN       NUMBER,
      p_earned_amt      IN       NUMBER,
      p_cust_account_type IN     VARCHAR2 := NULL,
      p_cust_account_id IN       NUMBER  := NULL,
      p_product_item_id IN       NUMBER  := NULL,
      x_fund_amt_tbl    OUT NOCOPY      ozf_fund_amt_tbl_type
   ) IS

-- rimehrot, for R12: query from the new table

     CURSOR c_budget (p_src_id IN NUMBER) IS
        SELECT fund_id parent_source_id, committed_amt total_amount , fund_currency parent_curr
        FROM ozf_object_fund_summary
        WHERE object_type = 'OFFR'
        AND object_id = p_src_id
        --AND NVL(committed_amt, 0) <> 0
        ORDER BY fund_id;

      --- local variables
      l_count           NUMBER            := 0;
      l_return_status   VARCHAR2 (30);
      l_msg_count                  NUMBER;
      l_msg_data                   VARCHAR2 (2000);
      l_rate            NUMBER;
      l_total_amount    NUMBER            := 0;
      l_budget_offer_yn  VARCHAR2(1);
      l_utilized_amount    NUMBER;
      l_eligible_fund_amt_tbl        ozf_fund_amt_tbl_type;
      l_eligible_count  NUMBER            := 0;
      l_eligible_total_amount      NUMBER  := 0;
      l_eligible_flag              BOOLEAN := false;
      l_converted_amt       NUMBER;
      l_count1 NUMBER :=0;
      l_total_amount1 NUMBER :=0;

      TYPE parentIdType     IS TABLE OF ozf_object_fund_summary.fund_id%TYPE;
      TYPE amountType       IS TABLE OF ozf_object_fund_summary.committed_amt%TYPE;
      TYPE currencyType     IS TABLE OF ozf_object_fund_summary.fund_currency%TYPE;
      TYPE fraction_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
      l_parent_id_tbl       parentIdType;
      l_total_amount_tbl    amountType;
      l_parent_curr_tbl     currencyType;
      l_fraction_tbl    fraction_tbl_type;

      -- cursor for accrual budget
      CURSOR c_offer_info  IS
         SELECT NVL(budget_offer_yn,'N')
         FROM ozf_offers
         WHERE qp_list_header_id = p_src_id;
      -- cursor for accrual fund
      CURSOR c_fund  IS
         SELECT fund_id , currency_code_tc
         FROM ozf_funds_all_b
         WHERE plan_id = p_src_id;

      /* yzhao: 10/03/2003 fix bug 3156515 - PROMOTIONAL GOODS OFFER EXCEEDS THE BUDGET AMOUNT
                   get utilized amount.
           -- rimehrot, commented for R12: use ozf_object_fund_summary table directly.
           CURSOR c_get_utilized_amount(p_offer_id IN NUMBER, p_fund_id IN NUMBER) IS
           SELECT   SUM(NVL(a2.amount, 0)) amount
           FROM   ozf_funds_utilized_all_b a2
           WHERE  a2.plan_id = p_offer_id
           AND  a2.plan_type = 'OFFR'
           AND  a2.fund_id = p_fund_id
           AND  a2.utilization_type NOT IN ('REQUEST', 'TRANSFER', 'SALES_ACCRUAL');
        */
          -- rimehrot, for R12: use ozf_object_fund_summary directly to get utilized amount.
      CURSOR c_get_utilized_amount(p_offer_id IN NUMBER, p_fund_id IN NUMBER) IS
         SELECT utilized_amt
         FROM ozf_object_fund_summary
         WHERE fund_id = p_fund_id
         AND object_type = 'OFFR'
         AND object_id = p_offer_id;

   BEGIN
      x_return_status            := fnd_api.g_ret_sts_success;

      IF g_debug_flag = 'Y' THEN
         ozf_utility_pvt.write_conc_log('    D: ENTER calculate_accrual_amount   offer_id=' || p_src_id || '  p_earned_amt=' || p_earned_amt);
      END IF;

      /*  kdass 31-JAN-05 - fix 11.5.9 bug 4067266 - RETROACTIVE VOLUME BUDGETS DO NOT CALCULATE CORRECTLY WHEN THE 1ST TIER IS AT 0%
      IF p_earned_amt = 0 THEN
         RETURN;
      END IF;
      */
      -- check if it is a accrual budget
      OPEN c_offer_info;
      FETCH c_offer_info INTO l_budget_offer_yn ;
      CLOSE c_offer_info;
      -- For positive accruals for a fully accrued budget we have only one budget for that
      /* yzhao: 04/04/2003 for fully accrued budget, only one budget. No matter it's positive or negative(return)
      IF p_earned_amt > 0 AND l_budget_offer_yn = 'Y' THEN
       */
      IF l_budget_offer_yn = 'Y' THEN
         l_count := 1;
         OPEN c_fund;
         FETCH c_fund INTO      x_fund_amt_tbl (l_count).ofr_src_id,
                                x_fund_amt_tbl (l_count).budget_currency;
         CLOSE c_fund;
         x_fund_amt_tbl (l_count).earned_amount := p_earned_amt;
         RETURN ;
      END IF ;

      -- first get the total committed amount
      OPEN c_budget (p_src_id);
      LOOP
        FETCH c_budget BULK COLLECT INTO l_parent_id_tbl, l_total_amount_tbl, l_parent_curr_tbl LIMIT g_bulk_limit;

        FOR i IN NVL(l_parent_id_tbl.FIRST, 1) .. NVL(l_parent_id_tbl.LAST, 0) LOOP
            -- if recalculate is allowed, always calculate based on committed amount
            -- otherwise, calculate based on available amount
            IF g_recal_flag = 'Y' THEN
                l_count := l_count + 1;
                x_fund_amt_tbl (l_count).ofr_src_id := l_parent_id_tbl(i);
                x_fund_amt_tbl (l_count).earned_amount := l_total_amount_tbl(i);
                x_fund_amt_tbl (l_count).budget_currency:= l_parent_curr_tbl(i);
            ELSE
                -- recalculate is not allowed, always calculate based on available amount
               /* yzhao: 10/03/2003 fix bug 3156515 - PROMOTIONAL GOODS OFFER EXCEEDS THE BUDGET AMOUNT
                           fraction calculation: this budget's committed amount for this offer / all budget's total committed amount for this offer
                           for positive accrual posting,
                               if recalculate committed flag is ON, posting amount = p_earned_amount * fraction
                               else, posting amount = LEAST(p_earned_amount * fraction, this budget's committed amount - utilized amount)
                           for negative accrual posting,
                               posting amount = -LEAST(abs(p_earned_amount) * fraction, this budget's committed amount - utilized amount)
               */
               OPEN c_get_utilized_amount( p_offer_id => p_src_id
                                         , p_fund_id => l_parent_id_tbl(i));
               FETCH c_get_utilized_amount INTO l_utilized_amount;
               CLOSE c_get_utilized_amount;

               IF l_total_amount_tbl(i) <= l_utilized_amount THEN   -- !!! think about negative utilized amount!
                  -- no available amount. next iteration
                  GOTO LABEL_FOR_NEXT_ITERATION;
               END IF;

               l_count := l_count + 1;
               x_fund_amt_tbl (l_count).ofr_src_id := l_parent_id_tbl(i);
               x_fund_amt_tbl (l_count).earned_amount := l_total_amount_tbl(i) - NVL(l_utilized_amount, 0);
               x_fund_amt_tbl (l_count).budget_currency:= l_parent_curr_tbl(i);
            END IF;  -- IF g_recal_flag = 'Y'
            IF g_debug_flag = 'Y' THEN
               ozf_utility_pvt.write_conc_log('    D: calculate_accrual_amount: ' || l_count || ') fund_id=' || x_fund_amt_tbl (l_count).ofr_src_id
                  || ' utilized_amount=' || l_utilized_amount || x_fund_amt_tbl (l_count).budget_currency);
            END IF;
            -- if the currencies of the budgets are different then convert it into the first budget currency
            -- to get the total amount
            IF l_count  > 1 THEN
               IF x_fund_amt_tbl (l_count).budget_currency <>
                                                       x_fund_amt_tbl (l_count - 1).budget_currency THEN
                  ozf_utility_pvt.convert_currency (
                     x_return_status=> x_return_status,
                     p_from_currency=> x_fund_amt_tbl (l_count).budget_currency,
                     p_to_currency=> x_fund_amt_tbl (l_count - 1).budget_currency,
                     p_from_amount=> x_fund_amt_tbl (l_count).earned_amount,
                     x_to_amount=> l_converted_amt,
                     x_rate=> l_rate
                  );
                  x_fund_amt_tbl (l_count).earned_amount := l_converted_amt;

               END IF;
               l_total_amount := l_total_amount + x_fund_amt_tbl (l_count).earned_amount;
            ELSE
               l_total_amount := x_fund_amt_tbl (l_count).earned_amount;
            END IF;

            If l_parent_id_tbl.COUNT > 1 THEN
               ozf_budgetapproval_pvt.check_budget_qualification(
                  p_budget_id          => x_fund_amt_tbl (l_count).ofr_src_id
                , p_cust_account_id    => p_cust_account_id
                , p_product_item_id    => p_product_item_id
                , x_qualify_flag       => l_eligible_flag
                , x_return_status      => l_return_status
                , x_msg_count          => l_msg_count
                , x_msg_data           => l_msg_data
               );

               IF g_debug_flag = 'Y' THEN
                  ozf_utility_pvt.write_conc_log ('    D: calculate_accrual_amount(): check_budget_qualification status:   ' || l_return_status);
               END IF;
               IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  l_eligible_flag := false;
               END IF;
            ELSE
               l_eligible_flag := true;
            END IF;

            IF l_eligible_flag THEN
               IF g_debug_flag = 'Y' THEN
                  ozf_utility_pvt.write_conc_log ('    D: calculate_accrual_amount(): budget ' || x_fund_amt_tbl (l_count).ofr_src_id
                     || ' is qualified for product:' || p_product_item_id || ' customer: ' || p_cust_account_id);
               END IF;
               l_eligible_count := l_eligible_count + 1;
               l_eligible_fund_amt_tbl (l_eligible_count).ofr_src_id := x_fund_amt_tbl (l_count).ofr_src_id;
               l_eligible_fund_amt_tbl (l_eligible_count).earned_amount := x_fund_amt_tbl (l_count).earned_amount;
               l_eligible_fund_amt_tbl (l_eligible_count).budget_currency:= x_fund_amt_tbl (l_count).budget_currency;
               l_eligible_total_amount := l_eligible_total_amount + l_eligible_fund_amt_tbl (l_eligible_count).earned_amount;
            ELSE
               IF g_debug_flag = 'Y' THEN
                  ozf_utility_pvt.write_conc_log ('    D: calculate_accrual_amount(): budget ' || x_fund_amt_tbl (l_count).ofr_src_id
                     || ' is not qualified for product:' || p_product_item_id || ' customer: ' || p_cust_account_id);
               END IF;
            END IF;

            <<LABEL_FOR_NEXT_ITERATION>>
            NULL;
        END LOOP;  -- FOR i IN NVL(l_parent_id_tbl.FIRST, 1) .. NVL(l_parent_id_tbl.LAST, 0) LOOP
        EXIT WHEN c_budget%NOTFOUND;
      END LOOP;  -- c_budget
      CLOSE c_budget;

      IF l_eligible_total_amount > 0 THEN
          x_fund_amt_tbl.DELETE;
          x_fund_amt_tbl := l_eligible_fund_amt_tbl;
          l_total_amount := l_eligible_total_amount;
          l_count := l_eligible_count;
          IF g_debug_flag = 'Y' THEN
             ozf_utility_pvt.write_conc_log('    D: calculate_accrual_amount(): ' || l_count
                || ' eligible budgets found. Total amount available for posting:' || l_total_amount);
          END IF;
      END IF;

      -- Note that the amounts are in one currency
      IF l_total_amount = 0 THEN
         IF g_recal_flag = 'N' and p_earned_amt < 0 THEN    -- ??? really needed ???
            x_return_status            := fnd_api.g_ret_sts_error;
            RETURN;
         END IF;
      END IF;

      IF g_debug_flag = 'Y' THEN
         ozf_utility_pvt.write_conc_log('    D: calculate_accrual_amount(): g_recal_flag=' || g_recal_flag || ' p_earned_amt=' || p_earned_amt
            || ' final sourcing budget table count=' || x_fund_amt_tbl.COUNT || ' sourcing budgets total amount=' || l_total_amount);
      END IF;

      -- calculate the fraction if recalculation flag is on, or to_post amount is less than available amount
      -- otherwise, use whatever available amount
      IF g_recal_flag = 'Y' OR p_earned_amt < l_total_amount THEN
          FOR i IN NVL (x_fund_amt_tbl.FIRST, 1) .. NVL (x_fund_amt_tbl.LAST, 0)
          LOOP
             IF l_total_amount = 0 THEN
                 l_fraction_tbl (x_fund_amt_tbl (i).ofr_src_id) := 1;
             ELSE
                 l_fraction_tbl (x_fund_amt_tbl (i).ofr_src_id) :=
                                                      x_fund_amt_tbl (i).earned_amount / l_total_amount;
             END IF;
          END LOOP;

          --nirprasa, ER 8399134
          l_total_amount1 := p_earned_amt;
          l_count1 := x_fund_amt_tbl.COUNT;

          IF g_debug_flag = 'Y' THEN
          ozf_utility_pvt.write_conc_log ('x_fund_amt_tbl.COUNT '||x_fund_amt_tbl.COUNT);
          ozf_utility_pvt.write_conc_log ('l_total_amount '||l_total_amount1);
          ozf_utility_pvt.write_conc_log ('x_fund_amt_tbl.FIRST '|| x_fund_amt_tbl.FIRST);
          END IF;
          FOR i IN NVL (x_fund_amt_tbl.FIRST, 1) .. NVL (x_fund_amt_tbl.LAST, 0)
          LOOP
              --nirprasa, ER 8399134 to prorate the last record to resolve rounding issue
              IF i = x_fund_amt_tbl.COUNT AND i > 1 THEN
                 x_fund_amt_tbl (i).earned_amount := l_total_amount1;
              ELSE
              x_fund_amt_tbl (i).earned_amount :=
                           p_earned_amt * l_fraction_tbl (x_fund_amt_tbl (i).ofr_src_id);
                 l_total_amount1 := l_total_amount1 - x_fund_amt_tbl (i).earned_amount;
              END IF;
              IF g_debug_flag = 'Y' THEN
                 ozf_utility_pvt.write_conc_log ('    D: calculate_accrual_amount(): --index--'  || i  || '--final posting amt--'
                                || x_fund_amt_tbl (i).earned_amount
                                || '--fund id--' || x_fund_amt_tbl (i).ofr_src_id
                                || '--fraction--' || l_fraction_tbl(x_fund_amt_tbl (i).ofr_src_id));
              END IF;
          END LOOP;
      END IF;

   EXCEPTION
      WHEN OTHERS THEN
         IF c_budget%ISOPEN THEN
            CLOSE c_budget;
         END IF;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, 'Calculate Accrual');
         END IF;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
   END calculate_accrual_amount;

  /*****************************************************************************************/
-- Start of Comments
--
-- NAME
--   Create_Act_Budgets
--
-- PURPOSE
--   This procedure is to create a act_budget record
--
-- HISTORY
-- 01/22/2003  feliu  CREATED

-- End of Comments
/*****************************************************************************************/
   PROCEDURE create_actbudgets_rec (
      x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,x_act_budget_id      OUT NOCOPY      NUMBER
     ,p_act_budgets_rec    IN              ozf_actbudgets_pvt.act_budgets_rec_type
     ,p_ledger_id          IN              NUMBER
     ,p_org_id             IN              NUMBER DEFAULT NULL -- added for bug 7030415
    ) IS
      l_api_name      CONSTANT VARCHAR2 (30)        := 'create_actbudgets_rec';
      l_full_name     CONSTANT VARCHAR2 (60)        :=    g_pkg_name
                                                       || '.'
                                                       || l_api_name;
      l_return_status         VARCHAR2 (1); -- Return value from procedures
      l_act_budgets_rec       ozf_actbudgets_pvt.act_budgets_rec_type := p_act_budgets_rec;
      l_requester_id          NUMBER;
      l_activity_id           NUMBER;
      l_obj_ver_num           NUMBER;
      l_old_approved_amount   NUMBER;
      l_set_of_book_id        NUMBER;
      l_sob_type_code         VARCHAR2(30);
      l_fc_code               VARCHAR2(150);
      l_exchange_rate_type    VARCHAR2(150);
      l_exchange_rate         NUMBER;
      l_approved_amount_fc    NUMBER;
      l_old_amount_fc         NUMBER;
      l_plan_currency         VARCHAR2(150);
      l_rate                  NUMBER;

      CURSOR c_act_budget_id IS
         SELECT ozf_act_budgets_s.NEXTVAL
         FROM DUAL;

      CURSOR c_act_util_rec (p_used_by_id IN NUMBER, p_used_by_type IN VARCHAR2) IS
         SELECT activity_budget_id, object_version_number, approved_amount,approved_amount_fc
         FROM ozf_act_budgets
         WHERE act_budget_used_by_id = p_used_by_id
         AND arc_act_budget_used_by = p_used_by_type
         AND transfer_type = 'UTILIZED';

      -- added for bug 7030415
      CURSOR c_get_conversion_type( p_org_id   IN   NUMBER) IS
         SELECT exchange_rate_type
         FROM   ozf_sys_parameters_all
         WHERE  org_id = p_org_id;

      CURSOR c_offer_type (p_offer_id IN NUMBER) IS
         SELECT nvl(transaction_currency_code,fund_request_curr_code) offer_currency_code
         FROM   ozf_offers
         WHERE  qp_list_header_id = p_offer_id;
   BEGIN
      IF g_debug_flag = 'Y' THEN
         ozf_utility_pvt.write_conc_log(   l_full_name
                                     || ': start');
      END IF;
      -- Standard Start of API savepoint
      SAVEPOINT create_actbudgets_rec;

      --  Initialize API return status to success
      x_return_status            := fnd_api.g_ret_sts_success;
      /* Added for bug 7030415
       This currency conversion is for approved_amount_fc column in ozf_act_budgets table.
       Using the utilization org_id because to_currency is the functional currency of
       order's org's ledger.*/

      OPEN c_get_conversion_type(p_org_id);
      FETCH c_get_conversion_type INTO l_exchange_rate_type;
      CLOSE c_get_conversion_type;

        IF g_debug_flag = 'Y' THEN
          ozf_utility_pvt.write_conc_log('**************************START****************************');
          ozf_utility_pvt.write_conc_log(l_api_name||' From Amount: '||l_act_budgets_rec.request_amount );
          ozf_utility_pvt.write_conc_log(l_api_name||' From Curr: '||l_act_budgets_rec.request_currency );
          ozf_utility_pvt.write_conc_log(l_api_name||' p_ledger_id: '||p_ledger_id);
          ozf_utility_pvt.write_conc_log(l_api_name||' l_exchange_rate_type: '|| l_exchange_rate_type);
          ozf_utility_pvt.write_conc_log('Request amount is converted from request curr to functional curr');
        END IF;

      IF l_act_budgets_rec.request_amount <> 0 THEN
         ozf_utility_pvt.calculate_functional_currency (
               p_from_amount=>l_act_budgets_rec.request_amount
              ,p_tc_currency_code=> l_act_budgets_rec.request_currency
              ,p_ledger_id => p_ledger_id
              ,x_to_amount=> l_approved_amount_fc
              ,x_mrc_sob_type_code=> l_sob_type_code
              ,x_fc_currency_code=> l_fc_code
              ,x_exchange_rate_type=> l_exchange_rate_type
              ,x_exchange_rate=> l_exchange_rate
              ,x_return_status=> l_return_status
            );
         IF g_debug_flag = 'Y' THEN
            ozf_utility_pvt.write_conc_log(l_full_name || 'calculate_functional_curr: ' || l_return_status);
         END IF;

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

      END IF;

      --nirprasa, ER 8399134 for transfer_type='UTILIZED' all three columns will be in
      -- offer currency always.
      OPEN c_offer_type(p_act_budgets_rec.act_budget_used_by_id);
      FETCH c_offer_type INTO l_plan_currency;
      CLOSE c_offer_type;

      IF g_debug_flag = 'Y' THEN
         ozf_utility_pvt.write_conc_log(l_full_name || ' l_plan_currency: ' || l_plan_currency);
         ozf_utility_pvt.write_conc_log(l_full_name || ' request_currency ' || l_act_budgets_rec.request_currency);
      END IF;

      IF l_plan_currency <> l_act_budgets_rec.request_currency THEN
      ozf_utility_pvt.convert_currency (x_return_status => x_return_status
                                      ,p_from_currency => l_act_budgets_rec.request_currency
                                      ,p_to_currency   => l_plan_currency
                                      ,p_conv_type     => l_exchange_rate_type -- Added for bug 7030415
                                      ,p_from_amount   => l_act_budgets_rec.request_amount
                                      ,x_to_amount     => l_act_budgets_rec.approved_amount
                                      ,x_rate          => l_rate
                                      );

         l_act_budgets_rec.request_amount := l_act_budgets_rec.approved_amount;
         l_act_budgets_rec.approved_original_amount := l_act_budgets_rec.approved_amount;
      END IF;


      OPEN c_act_util_rec (
         p_act_budgets_rec.act_budget_used_by_id,
         p_act_budgets_rec.arc_act_budget_used_by
      );
      FETCH c_act_util_rec INTO l_activity_id,
                                l_obj_ver_num,
                                l_old_approved_amount,
                                l_old_amount_fc;
      CLOSE c_act_util_rec;

      --if act_budget record exist for this offer, update record.
      IF l_activity_id IS NOT NULL THEN
         UPDATE ozf_act_budgets
         SET  request_amount = l_old_approved_amount + NVL(l_act_budgets_rec.request_amount, 0),
              approved_amount =l_old_approved_amount + NVL(l_act_budgets_rec.request_amount, 0),
              src_curr_request_amt =l_old_approved_amount + NVL(l_act_budgets_rec.request_amount, 0),
              object_version_number = l_obj_ver_num + 1
              ,parent_source_id = l_act_budgets_rec.parent_source_id
              ,parent_src_curr  = l_act_budgets_rec.parent_src_curr
              ,parent_src_apprvd_amt =l_act_budgets_rec.parent_src_apprvd_amt
              ,approved_amount_fc = NVL(l_old_amount_fc,0) + NVL(l_approved_amount_fc,0)
              ,approved_original_amount = l_old_approved_amount + l_act_budgets_rec.request_amount
         WHERE activity_budget_id = l_activity_id
             AND object_version_number = l_obj_ver_num;
         x_act_budget_id := l_activity_id;

         IF (SQL%NOTFOUND) THEN
            -- Error, check the msg level and added an error message to the
            -- API message list
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name ('OZF', 'OZF_API_RECORD_NOT_FOUND');
               fnd_msg_pub.ADD;
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;

         RETURN; -- exit from program.
      END IF;

      IF l_act_budgets_rec.request_currency IS NULL THEN
         ozf_utility_pvt.write_conc_log ('OZF_ACT_BUDG_NO_CURRENCY');
         x_return_status            := fnd_api.g_ret_sts_error;
      END IF;



      OPEN c_act_budget_id;
      FETCH c_act_budget_id INTO l_act_budgets_rec.activity_budget_id;
      CLOSE c_act_budget_id;

      l_requester_id := ozf_utility_pvt.get_resource_id (fnd_global.user_id);

      INSERT INTO ozf_act_budgets
                  (activity_budget_id,last_update_date
                  ,last_updated_by, creation_date
                  ,created_by,last_update_login -- other columns
                  ,object_version_number,act_budget_used_by_id
                  ,arc_act_budget_used_by,budget_source_type
                  ,budget_source_id,transaction_type
                  ,request_amount,request_currency
                  ,request_date,user_status_id
                  ,status_code,approved_amount
                  ,approved_original_amount,approved_in_currency
                  ,approval_date, approver_id
                  ,spent_amount, partner_po_number
                  ,partner_po_date, partner_po_approver
                  ,posted_flag, adjusted_flag
                  ,parent_act_budget_id, contact_id
                  ,reason_code, transfer_type
                  ,requester_id,date_required_by
                  ,parent_source_id,parent_src_curr
                  ,parent_src_apprvd_amt,partner_holding_type
                  ,partner_address_id, vendor_id
                  ,owner_id,recal_flag
                  ,attribute_category, attribute1
                  ,attribute2, attribute3
                  ,attribute4, attribute5
                  ,attribute6, attribute7
                  ,attribute8, attribute9
                  ,attribute10, attribute11
                  ,attribute12, attribute13
                  ,attribute14, attribute15
                  ,approved_amount_fc
                  ,src_curr_request_amt
                  )
           VALUES (l_act_budgets_rec.activity_budget_id,SYSDATE
                   ,fnd_global.user_id, SYSDATE
                   ,fnd_global.user_id, fnd_global.conc_login_id
                   ,1, l_act_budgets_rec.act_budget_used_by_id
                   ,l_act_budgets_rec.arc_act_budget_used_by, l_act_budgets_rec.budget_source_type
                  ,l_act_budgets_rec.budget_source_id, l_act_budgets_rec.transaction_type
                  ,l_act_budgets_rec.request_amount, l_act_budgets_rec.request_currency
                  ,SYSDATE, l_act_budgets_rec.user_status_id
                  ,NVL(l_act_budgets_rec.status_code, 'NEW'), l_act_budgets_rec.approved_amount
                  ,l_act_budgets_rec.approved_amount,l_act_budgets_rec.approved_in_currency
                  ,sysdate,l_requester_id
                  ,l_act_budgets_rec.spent_amount, l_act_budgets_rec.partner_po_number
                  ,l_act_budgets_rec.partner_po_date, l_act_budgets_rec.partner_po_approver
                  ,l_act_budgets_rec.posted_flag, l_act_budgets_rec.adjusted_flag
                  ,l_act_budgets_rec.parent_act_budget_id, l_act_budgets_rec.contact_id
                  ,l_act_budgets_rec.reason_code, l_act_budgets_rec.transfer_type
                  ,l_requester_id,l_act_budgets_rec.date_required_by
                  ,l_act_budgets_rec.parent_source_id,l_act_budgets_rec.parent_src_curr
                  ,l_act_budgets_rec.parent_src_apprvd_amt,l_act_budgets_rec.partner_holding_type
                  ,l_act_budgets_rec.partner_address_id, l_act_budgets_rec.vendor_id
                  ,NULL,l_act_budgets_rec.recal_flag
                  ,l_act_budgets_rec.attribute_category, l_act_budgets_rec.attribute1
                  ,l_act_budgets_rec.attribute2, l_act_budgets_rec.attribute3
                  ,l_act_budgets_rec.attribute4, l_act_budgets_rec.attribute5
                  ,l_act_budgets_rec.attribute6, l_act_budgets_rec.attribute7
                  ,l_act_budgets_rec.attribute8, l_act_budgets_rec.attribute9
                  ,l_act_budgets_rec.attribute10, l_act_budgets_rec.attribute11
                  ,l_act_budgets_rec.attribute12, l_act_budgets_rec.attribute13
                  ,l_act_budgets_rec.attribute14, l_act_budgets_rec.attribute15
                  ,l_approved_amount_fc
                  ,l_act_budgets_rec.approved_amount);

      x_act_budget_id := l_act_budgets_rec.activity_budget_id;

      IF g_debug_flag = 'Y' THEN
         ozf_utility_pvt.write_conc_log(   l_api_name
                                     || ': insert complete' || l_act_budgets_rec.activity_budget_id);
      END IF;

          -- Standard call to get message count AND IF count is 1, get message info.
      fnd_msg_pub.count_and_get (
            p_count=> x_msg_count,
            p_data=> x_msg_data,
            p_encoded=> fnd_api.g_false
      );

   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO create_actbudgets_rec;
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count,
            p_data=> x_msg_data,
            p_encoded=> fnd_api.g_false
         );

      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO create_actbudgets_rec;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count,
            p_data=> x_msg_data,
            p_encoded=>fnd_api.g_false
         );

      WHEN OTHERS THEN
         ROLLBACK TO create_actbudgets_rec;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count,
            p_data=> x_msg_data,
            p_encoded=> fnd_api.g_false
         );

   END create_actbudgets_rec;

  ---------------------------------------------------------------------
-- PROCEDURE
--    Create_Utilized_Rec
--
-- HISTORY
--    01/22/2003  feliu  Create.
--    10/14/2003  yzhao  Fix TEVA bug - customer fully accrual budget committed amount is always 0 even when accrual happens
--    11/25/2003  yzhao  11.5.10 populate utilized_amt and earned_amt
---------------------------------------------------------------------

   PROCEDURE create_utilized_rec (
     x_return_status      OUT NOCOPY      VARCHAR2
     ,x_msg_count          OUT NOCOPY      NUMBER
     ,x_msg_data           OUT NOCOPY      VARCHAR2
     ,x_utilization_id      OUT NOCOPY      NUMBER
     ,p_utilization_rec    IN       ozf_fund_utilized_pvt.utilization_rec_type
   ) IS
      l_api_name            CONSTANT VARCHAR2 (30)     := 'create_utilized_rec';
      l_full_name           CONSTANT VARCHAR2 (60)     :=    g_pkg_name || '.' || l_api_name;
      l_return_status                VARCHAR2 (1);
      l_utilization_rec              ozf_fund_utilized_pvt.utilization_rec_type := p_utilization_rec;
      l_earned_amt                   NUMBER;
      l_obj_num                      NUMBER;
      l_fund_type                    VARCHAR2 (30);
      l_parent_fund_id               NUMBER;
      l_accrual_basis                VARCHAR2 (30);
      l_original_budget              NUMBER;
      l_event_id                     NUMBER;
      /* R12: yzhao bug 4669269 - obsolete ozf_mc_transactions
      l_mc_record_id                 NUMBER;
      l_mc_obj_num                   NUMBER;
      l_mc_col_1                     NUMBER;
      l_mc_col_6                     NUMBER;
      l_mc_col_7                     NUMBER;
      l_mc_col_8                     NUMBER;
      l_mc_col_9                     NUMBER;
       */
      l_offer_type                   VARCHAR2 (30);
      l_accrual_flag                 VARCHAR2 (1);
      l_set_of_book_id               NUMBER;
      l_sob_type_code                VARCHAR2 (30);
      l_fc_code                      VARCHAR2 (150);
      l_fund_rec                     ozf_funds_pvt.fund_rec_type;
      l_rollup_orig_amt           NUMBER;
      l_rollup_earned_amt         NUMBER;
      l_new_orig_amt              NUMBER;
      l_new_utilized_amt          NUMBER;
      l_new_earned_amt            NUMBER;
      l_rate                      NUMBER;
      l_univ_amt                  NUMBER;
      l_new_paid_amt              NUMBER;
      l_new_univ_amt              NUMBER;
      l_paid_amt                  NUMBER;
      l_rollup_paid_amt           NUMBER;
      l_committed_amt             NUMBER;
      l_rollup_committed_amt      NUMBER;
      -- yzhao: 10/14/2003 added
      l_new_committed_amt         NUMBER;
      l_new_recal_committed       NUMBER;
      l_recal_committed           NUMBER;
      l_rollup_recal_committed    NUMBER;
      l_plan_id                   NUMBER;
      l_act_budget_id             NUMBER;
      l_act_budget_objver         NUMBER;
      l_liability_flag            VARCHAR2(1);
      -- yzhao: 11.5.10
      l_utilized_amt              NUMBER;
      l_rollup_utilized_amt       NUMBER;
      l_off_invoice_gl_post_flag  VARCHAR2(1);
      l_order_ledger              NUMBER;
      l_ord_ledger_name           VARCHAR2(150);
      l_fund_ledger               NUMBER;
      l_custom_setup_id           NUMBER;
      l_beneficiary_account_id    NUMBER;
      l_req_header_id             NUMBER;
      -- rimehrot: added for R12
      l_plan_currency                VARCHAR2 (150);
      l_transaction_currency         VARCHAR2 (150);
      l_objfundsum_rec               ozf_objfundsum_pvt.objfundsum_rec_type := NULL;
      l_objfundsum_id                NUMBER;
      l_offer_id                     NUMBER;

      --nirprasa
      l_autopay_party_attr       VARCHAR2(30);
      l_autopay_party_id         NUMBER;

--Added variable for bug 6278466
      l_org_id                    NUMBER; -- removed initialization for bug 6278466

--Added c_site_org_id for bug 6278466
      CURSOR c_site_org_id (p_site_use_id IN NUMBER) IS
         SELECT org_id
           FROM hz_cust_site_uses_all
          WHERE site_use_id = p_site_use_id;

      -- Cursor to get the sequence for utilization_id
      CURSOR c_utilization_seq IS
         SELECT ozf_funds_utilized_s.NEXTVAL
         FROM DUAL;

      -- Cursor to get fund earned amount and object_version_number
      CURSOR c_fund_b (p_fund_id IN NUMBER) IS
         SELECT object_version_number
               ,accrual_basis
               ,fund_type
               ,original_budget
               ,earned_amt
               ,paid_amt
               ,parent_fund_id
               ,rollup_original_budget
               ,rollup_earned_amt
               ,rollup_paid_amt
               -- yzhao 10/14/2003 added below
               ,committed_amt
               ,recal_committed
               ,rollup_committed_amt
               ,rollup_recal_committed
               ,plan_id
               ,NVL(liability_flag, 'N')
               -- yzhao: 11.5.10
               ,utilized_amt
               ,rollup_utilized_amt
         FROM ozf_funds_all_b
         WHERE fund_id = p_fund_id;

      /* R12: yzhao bug 4669269 - obsolete ozf_mc_transactions
      CURSOR c_mc_trans(p_fund_id IN NUMBER) IS
         SELECT mc_record_id
                ,object_version_number
                ,amount_column1 -- original
                ,amount_column6 -- committed; yzhao: 10/14/2003 added
                ,amount_column7 -- earn
                ,amount_column8 -- paid
        ,amount_column9 -- utilized
         FROM ozf_mc_transactions_all
         WHERE source_object_name ='FUND'
         AND source_object_id = p_fund_id;
       */

      CURSOR c_offer_type (p_offer_id IN NUMBER) IS
         SELECT offer_type, custom_setup_id, beneficiary_account_id,
                nvl(transaction_currency_code,fund_request_curr_code) offer_currency_code,
                transaction_currency_code,
                offer_id,autopay_party_attr,autopay_party_id --nirprasa
         FROM   ozf_offers
         WHERE  qp_list_header_id = p_offer_id;

      CURSOR c_accrual_flag (p_price_adjustment_id IN NUMBER) IS
         SELECT NVL(accrual_flag,'N')
         FROM oe_price_adjustments
         WHERE price_Adjustment_id = p_price_Adjustment_id;

      CURSOR c_parent (p_fund_id IN NUMBER)IS
         SELECT fund_id
               ,object_version_number
               ,rollup_original_budget
               ,rollup_earned_amt
               ,rollup_paid_amt
               -- yzhao: 10/14/2003 added
               ,rollup_committed_amt
               ,rollup_recal_committed
               -- yzhao: 11.5.10
               ,rollup_utilized_amt
         FROM ozf_funds_all_b
         connect by prior  parent_fund_id =fund_id
         start with fund_id =  p_fund_id;

      /* 10/14/2003  yzhao  Fix TEVA bug - customer fully accrual budget committed amount is always 0
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

     /*fix for bug 4778995
     -- yzhao: 11.5.10 get time_id
     CURSOR c_get_time_id(p_date IN DATE) IS
        SELECT month_id, ent_qtr_id, ent_year_id
        FROM   ozf_time_day
        WHERE  report_date = trunc(p_date);
     */


     /* Add by feliu on 12/30/03 to fix org issue:
        If order org's SOB is different than Budget Org's SOB, then we use Budget's org_id and function currency.
    and have log message to ask use to make manual adjustment.otherwise we use order org_id and function currency.
      kdass 08/23/2005 MOAC change: changed comparison from SOB to Ledger
      */
      /*
      CURSOR c_order_sob(p_org_id IN NUMBER) IS
        SELECT SET_OF_BOOKS_ID
        FROM ozf_sys_parameters_all
        WHERE org_id = p_org_id;

      -- yzhao: 11.5.10 check if post to gl for off invoice discount
      CURSOR c_fund_sob(p_fund_id IN NUMBER) IS
        SELECT  sob.set_of_books_id, fun.ORG_id, NVL(sob.gl_acct_for_offinv_flag, 'F')
        FROM    ozf_sys_parameters_all sob
               ,ozf_funds_all_b  fun
        WHERE fun.fund_id = p_fund_id
        AND   sob.org_id = fun.ORG_id ;
      */

      --nirprasa, for bug 7654383. removed fund's org_id
      CURSOR c_fund_ledger(p_fund_id IN NUMBER) IS
         SELECT  fun.ledger_id
         FROM    gl_sets_of_books sob,
                 ozf_funds_all_b fun
         where  sob.set_of_books_id = fun.ledger_id
         and fun.fund_id = p_fund_id;

      CURSOR c_offinv_flag(p_org_id IN NUMBER) IS
         SELECT  NVL(sob.gl_acct_for_offinv_flag, 'F')
         FROM    ozf_sys_parameters_all sob
         WHERE   sob.org_id = p_org_id;

      -- yzhao: 11.5.10 populate reference_type/id for special pricing
      CURSOR c_get_request_header_id(p_list_header_id IN NUMBER) IS
         SELECT request_header_id
         FROM   ozf_request_headers_all_b
         WHERE  offer_id =p_list_header_id;

     -- rimehrot: for R12 update ozf_object_fund_summary table
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

--Ship - Debit Enhancements / Added by Pranay
      CURSOR c_sd_request_header_id(p_list_header_id IN NUMBER) IS
         SELECT request_header_id
         FROM   ozf_sd_request_headers_all_b
         WHERE  offer_id =p_list_header_id;

-- nirprasa, cursor for currency conversion type.
      CURSOR c_get_conversion_type( p_org_id   IN   NUMBER) IS
         SELECT exchange_rate_type
         FROM   ozf_sys_parameters_all
         WHERE  org_id = p_org_id;

   BEGIN
      --------------------- initialize -----------------------
      SAVEPOINT create_utilized_rec;
      IF g_debug_flag = 'Y' THEN
         ozf_utility_pvt.write_conc_log(   l_full_name
                                     || ': start' || p_utilization_rec.utilization_type);
      END IF;

      x_return_status            := fnd_api.g_ret_sts_success;

       -- Get the identifier
      OPEN c_utilization_seq;
      FETCH c_utilization_seq INTO l_utilization_rec.utilization_id;
      CLOSE c_utilization_seq;
      OPEN c_fund_b (l_utilization_rec.fund_id);
      FETCH c_fund_b INTO l_obj_num
                         ,l_accrual_basis
                         ,l_fund_type
                         ,l_original_budget
                         ,l_earned_amt
                         ,l_paid_amt
                         ,l_parent_fund_id
                         ,l_rollup_orig_amt
                         ,l_rollup_earned_amt
                         ,l_rollup_paid_amt
                         ,l_committed_amt
                         ,l_recal_committed
                         ,l_rollup_committed_amt
                         ,l_rollup_recal_committed
                         ,l_plan_id
                         ,l_liability_flag
                         ,l_utilized_amt
                         ,l_rollup_utilized_amt;
      IF (c_fund_b%NOTFOUND) THEN
         CLOSE c_fund_b;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_API_RECORD_NOT_FOUND');
            fnd_msg_pub.ADD;
         END IF;
         RAISE fnd_api.g_exc_error;
      END IF;
      CLOSE c_fund_b;

      OPEN c_offinv_flag(l_utilization_rec.org_id);
      FETCH c_offinv_flag INTO l_off_invoice_gl_post_flag;
      CLOSE c_offinv_flag;

      --kdass MOAC changes: change comparison from SOB to Ledger
      /*
      OPEN c_order_sob(l_utilization_rec.org_id);
      FETCH c_order_sob INTO l_order_sob;
      CLOSE c_order_sob;

      OPEN c_fund_sob(l_utilization_rec.fund_id);
      FETCH c_fund_sob INTO l_fund_sob, l_fund_org, l_off_invoice_gl_post_flag;
      CLOSE c_fund_sob;
      */

      OPEN c_fund_ledger(l_utilization_rec.fund_id);
      FETCH c_fund_ledger INTO l_fund_ledger;
      CLOSE c_fund_ledger;
      --get the order's ledger id
      mo_utils.Get_Ledger_Info (p_operating_unit => l_utilization_rec.org_id
                               ,p_ledger_id      => l_order_ledger
                               ,p_ledger_name    => l_ord_ledger_name);
      IF l_utilization_rec.org_id IS NULL THEN
         IF g_debug_flag = 'Y' THEN
            ozf_utility_pvt.write_conc_log (' org_id from order is null ');
         END IF;
      ELSE
         IF g_debug_flag = 'Y' THEN
            ozf_utility_pvt.write_conc_log (' org_id from order: ' || l_utilization_rec.org_id);
         END IF;
      END IF;

      IF l_fund_ledger IS NOT NULL AND l_order_ledger <> l_fund_ledger THEN
         -- l_utilization_rec.org_id := l_fund_org;  R12: stick to order's org. Budget org is not essential information
         ozf_utility_pvt.write_conc_log (' Warning: There is a potential problem with this accrual record. The ledger ');
         ozf_utility_pvt.write_conc_log ('used by Trade Management to create the GL postings for this ');
         ozf_utility_pvt.write_conc_log ('accrual does not match the one the sales order rolls up to. Please ');
         ozf_utility_pvt.write_conc_log ('review carefully and make adjustments in Trade Management if necessary.');
      END IF;

      -- Added for bug 7030415, moved the the code here to get the correct utilization org_id.

      OPEN c_offer_type(l_utilization_rec.component_id);
      FETCH c_offer_type INTO l_offer_type, l_custom_setup_id, l_beneficiary_account_id, l_plan_currency,
                              l_transaction_currency,l_offer_id,l_autopay_party_attr,l_autopay_party_id;
      CLOSE c_offer_type;

      IF g_debug_flag = 'Y' THEN
         ozf_utility_pvt.write_conc_log ('l_offer_type: ' || l_offer_type);
         ozf_utility_pvt.write_conc_log ('l_offer_id: ' || l_offer_id);
         ozf_utility_pvt.write_conc_log ('l_utilization_rec.billto_cust_account_id: ' || l_utilization_rec.billto_cust_account_id);
         ozf_utility_pvt.write_conc_log ('l_utilization_rec.order_line_id: ' || l_utilization_rec.order_line_id);
      END IF;

      -- added by feliu on 08/30/2005 for R12.
      IF l_offer_type = 'VOLUME_OFFER' THEN
         l_beneficiary_account_id := ozf_volume_calculation_pub.get_beneficiary(l_offer_id
                                                                            ,l_utilization_rec.order_line_id);
         --04-MAY-09 kdass bug 8421406 - passed order_line_id to get volume offer beneficiary
         IF l_beneficiary_account_id = 0 THEN
            l_utilization_rec.cust_account_id := l_utilization_rec.billto_cust_account_id;
         ELSE
            l_utilization_rec.cust_account_id := l_beneficiary_account_id;
            l_utilization_rec.billto_cust_account_id := NULL;
            l_utilization_rec.ship_to_site_use_id := NULL;
            l_utilization_rec.bill_to_site_use_id := NULL;
         END IF;

         IF g_debug_flag = 'Y' THEN
            ozf_utility_pvt.write_conc_log ('l_utilization_rec.cust_account_id ' || l_utilization_rec.cust_account_id);
            ozf_utility_pvt.write_conc_log ('l_utilization_rec.billto_cust_account_id: ' || l_utilization_rec.billto_cust_account_id);
         END IF;

      ELSE

      -- yzhao: 11.5.10 populate cust_account_id with offer's beneficiary account, otherwise billto cust account id
        IF l_utilization_rec.cust_account_id IS NULL THEN
         IF l_beneficiary_account_id IS NOT NULL THEN

            --Added c_site_org_id for bug 6278466
            IF l_autopay_party_attr <> 'CUSTOMER' THEN
              OPEN c_site_org_id(l_autopay_party_id);
              FETCH c_site_org_id INTO l_org_id;
              CLOSE c_site_org_id;
              l_utilization_rec.org_id := l_org_id;
            END IF;
            l_utilization_rec.cust_account_id := l_beneficiary_account_id;

            --kdass bug 8258508/ Duplicate bill to sites for same cust_account_id. Cases are as follows:
            --Defaulting bill_to_site_id from beneficiary of type CUSTOMER_BILL_TO
            --Defaulting ship_to from beneficiary of type SHIP_TO
            --No bill_to/ship_to for beneficiary of type CUSTOMER
            IF l_autopay_party_attr = 'CUSTOMER_BILL_TO' THEN
                l_utilization_rec.bill_to_site_use_id := l_autopay_party_id;
                l_utilization_rec.ship_to_site_use_id := NULL;
            ELSIF l_autopay_party_attr = 'SHIP_TO' THEN
                l_utilization_rec.bill_to_site_use_id := NULL;
                l_utilization_rec.ship_to_site_use_id := l_autopay_party_id;
            ELSIF l_autopay_party_attr = 'CUSTOMER' THEN
                l_utilization_rec.bill_to_site_use_id := NULL;
                l_utilization_rec.ship_to_site_use_id := NULL;
            END IF;

            IF g_debug_flag = 'Y' THEN
               ozf_utility_pvt.write_conc_log ('l_utilization_rec.bill_to_site_use_id: ' || l_utilization_rec.bill_to_site_use_id);
               ozf_utility_pvt.write_conc_log ('l_utilization_rec.ship_to_site_use_id: ' || l_utilization_rec.ship_to_site_use_id);
            END IF;

         ELSE
            l_utilization_rec.cust_account_id := l_utilization_rec.billto_cust_account_id;
         END IF;
        END IF;
      END IF;


        /* Added for bug 7030415,- get the exchange rate based on org_id and pass it to the currency conversion API
        Utilization amount is converted from utilization curr to functional curr to populate
        acctd_amount column of utilization table.*/


        OPEN c_get_conversion_type(l_utilization_rec.org_id);
        FETCH c_get_conversion_type INTO l_utilization_rec.exchange_rate_type;
        CLOSE c_get_conversion_type;

        --nepanda Fix for bug 8994266 : commented IF to call calculate_functional_currency in case of amount = 0 also
      --IF l_utilization_rec.amount <> 0 THEN
         l_utilization_rec.amount := ozf_utility_pvt.currround(l_utilization_rec.amount , l_utilization_rec.currency_code);  -- round amount to fix bug 3615680;

         --nirprasa, ER 8399134
         l_utilization_rec.plan_curr_amount := ozf_utility_pvt.currround(l_utilization_rec.plan_curr_amount , l_utilization_rec.plan_currency_code);  -- round amount to fix bug 3615680;
         IF g_debug_flag = 'Y' THEN
           ozf_utility_pvt.write_conc_log('**************************START****************************');
           ozf_utility_pvt.write_conc_log(l_api_name||' From Amount: '||l_utilization_rec.plan_curr_amount );
           ozf_utility_pvt.write_conc_log(l_api_name||' From Curr: '||l_utilization_rec.plan_currency_code );
           ozf_utility_pvt.write_conc_log(l_api_name||' p_ledger_id: '|| l_order_ledger);
           ozf_utility_pvt.write_conc_log(l_api_name||' l_utilization_rec.exchange_rate_type: '|| l_utilization_rec.exchange_rate_type);
           ozf_utility_pvt.write_conc_log('Utilization amount is converted from transactional curr to functional curr to populate acctd_amount column');
        END IF;
         --plan_currency_code =  offers currency, if its Arrows case of diff offer and budget currency
         --else plan_currency_code = order currency, if its Null currency offer case
         ozf_utility_pvt.calculate_functional_currency (
                  p_from_amount=> l_utilization_rec.plan_curr_amount --12.2, multi-currency enhancement
                 ,p_tc_currency_code=> l_utilization_rec.plan_currency_code --12.2, multi-currency enhancement
                 ,p_ledger_id => l_order_ledger
                 ,x_to_amount=> l_utilization_rec.acctd_amount
                 ,x_mrc_sob_type_code=> l_sob_type_code
                 ,x_fc_currency_code=> l_fc_code
                 ,x_exchange_rate_type=> l_utilization_rec.exchange_rate_type
                 ,x_exchange_rate=> l_utilization_rec.exchange_rate
                 ,x_return_status=> l_return_status
               );

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
     -- END IF; --nepanda Fix for bug 8994266

      -- yzhao: 10/20/2003 when object sources from sales accrual budget, the budget behaves like fixed budget.
      IF l_fund_type = 'FULLY_ACCRUED' AND
         l_utilization_rec.component_type = 'OFFR' AND
         l_plan_id <> l_utilization_rec.component_id  THEN
         l_fund_type := 'FIXED' ;
      END IF;

      IF g_debug_flag = 'Y' THEN
      ozf_utility_pvt.write_conc_log(l_api_name||' l_fc_code '|| l_fc_code );
      ozf_utility_pvt.write_conc_log(l_api_name||' l_plan_currency '|| l_plan_currency );
      END IF;


      --nirprasa, ER 8399134 multi-currency enhancement, l_plan_currency = offer currency
      --l_utilization_rec.plan_currency_code = transactional currency
      --This is added for null curr offers to convert amount from order to offer's
      -- fund request currency code(JTF_DEFAULT_CURENCY_CODE) currency

      IF l_transaction_currency IS NULL THEN
        IF l_plan_currency = l_fc_code THEN
           l_utilization_rec.fund_request_amount := l_utilization_rec.acctd_amount;
        ELSIF l_plan_currency = l_utilization_rec.currency_code THEN
           l_utilization_rec.fund_request_amount := l_utilization_rec.amount;
        ELSIF l_utilization_rec.fund_request_amount IS NULL OR
        l_utilization_rec.fund_request_amount = FND_API.G_MISS_NUM THEN
        --need to chk this for cancel/partialship and returned orders
        --where this amount will already be populated.
        ozf_utility_pvt.convert_currency (x_return_status => x_return_status
              ,p_from_currency => l_utilization_rec.plan_currency_code
              ,p_to_currency   => l_plan_currency
              ,p_conv_type     => l_utilization_rec.exchange_rate_type -- Added for bug 7030415
              ,p_from_amount   => l_utilization_rec.plan_curr_amount
              ,x_to_amount     => l_utilization_rec.fund_request_amount
              ,x_rate          => l_rate);
        END IF;

      ELSE
        l_utilization_rec.fund_request_amount := l_utilization_rec.plan_curr_amount;
      END IF;
      l_utilization_rec.fund_request_currency_code := l_plan_currency;
      IF l_fund_type = 'FIXED' THEN
      ---- kpatro 11/09/2006 added check for utilization_type to fix 5523042
      IF  l_utilization_rec.utilization_type IS NULL THEN
         IF l_offer_type IN ('ACCRUAL') THEN
            l_utilization_rec.utilization_type := 'ACCRUAL';
            l_utilization_rec.amount_remaining := l_utilization_rec.amount;
            l_utilization_rec.acctd_amount_remaining := l_utilization_rec.acctd_amount;
            l_utilization_rec.plan_curr_amount_remaining := l_utilization_rec.plan_curr_amount ;
            l_utilization_rec.fund_request_amount_remaining := l_utilization_rec.fund_request_amount;
         ELSIF l_offer_type IN( 'DEAL','VOLUME_OFFER') THEN
            l_accrual_flag :='N';
            OPEN c_accrual_flag( l_utilization_rec.price_adjustment_id ) ;
            FETCH c_accrual_flag INTO l_accrual_flag ;
            CLOSE c_accrual_flag ;
            IF l_accrual_flag = 'Y' THEN
               l_utilization_rec.utilization_type := 'ACCRUAL';
               l_utilization_rec.amount_remaining := l_utilization_rec.amount;
               l_utilization_rec.acctd_amount_remaining := l_utilization_rec.acctd_amount;
               l_utilization_rec.plan_curr_amount_remaining := l_utilization_rec.plan_curr_amount ;
               l_utilization_rec.fund_request_amount_remaining := l_utilization_rec.fund_request_amount;
            ELSE
               l_utilization_rec.utilization_type := 'UTILIZED';
            END IF;
         ELSE
            l_utilization_rec.utilization_type := 'UTILIZED';
         END IF;
        END IF;
         -- 11.5.10: for off-invoice offer, if posting to gl flag is off, set gl_posted_flag to null so it shows up in earned and paid
         --          if flag is on, leave the flag as 'N'
         IF l_utilization_rec.utilization_type = 'UTILIZED'
         --AND l_off_invoice_gl_post_flag = 'F'
         THEN
           -- l_utilization_rec.gl_posted_flag := G_GL_FLAG_NULL;  -- null;
         --ELSE
            IF l_utilization_rec.gl_posted_flag IS NULL THEN  -- added by feliu on 06/09/04
               l_utilization_rec.gl_posted_flag := G_GL_FLAG_NO;      -- 'N', waiting for posting to gl
            END IF;

            IF l_utilization_rec.gl_posted_flag = G_GL_FLAG_NO
            AND l_utilization_rec.utilization_type IN ( 'ACCRUAL' ,'ADJUSTMENT') THEN
               l_utilization_rec.amount_remaining := l_utilization_rec.amount;
               l_utilization_rec.acctd_amount_remaining := l_utilization_rec.acctd_amount;
               l_utilization_rec.plan_curr_amount_remaining := l_utilization_rec.plan_curr_amount ;
               l_utilization_rec.fund_request_amount_remaining := l_utilization_rec.fund_request_amount;
            END IF;
         ELSE -- Added by nirprasa, This is added for partial shipment scenario when amt_reminain was being updated as null.
             IF l_utilization_rec.gl_posted_flag IS NULL THEN  -- added by feliu on 06/09/04
                l_utilization_rec.gl_posted_flag := G_GL_FLAG_NO;      -- 'N', waiting for posting to gl
             END IF;
             IF l_utilization_rec.gl_posted_flag = G_GL_FLAG_NO AND l_utilization_rec.utilization_type IN ( 'ACCRUAL' ,'ADJUSTMENT') THEN
                 l_utilization_rec.amount_remaining := l_utilization_rec.amount;
                 l_utilization_rec.acctd_amount_remaining := l_utilization_rec.acctd_amount;
                 l_utilization_rec.plan_curr_amount_remaining := l_utilization_rec.plan_curr_amount ;
                 l_utilization_rec.fund_request_amount_remaining := l_utilization_rec.fund_request_amount;
             END IF;
         END IF;
      ELSE
         IF l_accrual_basis = 'SALES' THEN
            l_utilization_rec.utilization_type := 'SALES_ACCRUAL';
            l_utilization_rec.gl_posted_flag := G_GL_FLAG_NO;-- set to 'X' only after shipping.
         ELSIF l_accrual_basis = 'CUSTOMER' THEN
            l_utilization_rec.utilization_type := 'ACCRUAL';
            -- yzhao: fix bug 3435420 - do not post to gl for customer accrual budget with liability off
            IF l_liability_flag = 'Y' THEN
               l_utilization_rec.amount_remaining := l_utilization_rec.amount;
               l_utilization_rec.acctd_amount_remaining := l_utilization_rec.acctd_amount;
               l_utilization_rec.plan_curr_amount_remaining := l_utilization_rec.plan_curr_amount ;
               l_utilization_rec.fund_request_amount_remaining := l_utilization_rec.fund_request_amount;
               IF l_utilization_rec.gl_posted_flag IS NULL THEN  -- yzhao 06/10/04
                   l_utilization_rec.gl_posted_flag := G_GL_FLAG_NO;      -- 'N', waiting for posting to gl
               END IF;
            ELSE
               l_utilization_rec.gl_posted_flag := G_GL_FLAG_NO;--G_GL_FLAG_NOLIAB;  -- 'X', do not post to gl
            END IF;
         END IF;
      END IF;

      l_utilization_rec.plan_id       := l_utilization_rec.component_id;
      l_utilization_rec.plan_type       := 'OFFR';
      l_utilization_rec.component_type       := 'OFFR';
      l_utilization_rec.adjustment_desc := fnd_message.get_string ('OZF', 'OZF_FUND_ASO_ORD_FEEDBACK');

      -- yzhao: 11/25/2003 11.5.10 populate adjustment_date and time_id
      IF l_utilization_rec.adjustment_date IS NULL THEN
         l_utilization_rec.adjustment_date := SYSDATE;
      END IF;

      /*fix for bug 4778995
      OPEN c_get_time_id(l_utilization_rec.adjustment_date);
      FETCH c_get_time_id INTO l_utilization_rec.month_id, l_utilization_rec.quarter_id, l_utilization_rec.year_id;
      CLOSE c_get_time_id;
      */


      /* yzhao: 11.5.10 populate reference_type/id for special pricing
                seeded custom_setup_id for special pricing:
                115 offer invoice
                116 accrual
                117 scan data
      */
      IF l_utilization_rec.reference_id IS NULL AND l_custom_setup_id IN (115, 116, 117) THEN
         OPEN c_get_request_header_id(l_utilization_rec.component_id);
         FETCH c_get_request_header_id INTO l_utilization_rec.reference_id;
         CLOSE c_get_request_header_id;
         l_utilization_rec.reference_type := 'SPECIAL_PRICE';
      END IF;

      --Ship - Debit enhancements / Added by Pranay
      IF l_utilization_rec.reference_id IS NULL AND l_custom_setup_id = 118 THEN
         OPEN c_sd_request_header_id(l_utilization_rec.component_id);
         FETCH c_sd_request_header_id INTO l_utilization_rec.reference_id;
         CLOSE c_sd_request_header_id;
         l_utilization_rec.reference_type := 'SD_REQUEST';
      END IF;

      --feliu, add on 07/30/04 to populate adjustment if adjust_type_id is not null
      IF l_utilization_rec.adjustment_type_id IS NOT NULL THEN
           l_utilization_rec.utilization_type := 'ADJUSTMENT';
      END IF;

       --rimehrot for R12, if gl_posted_flag = Y or Null and gl_date is null, make gl_date = adjustment_date
      IF l_utilization_rec.gl_date IS NULL THEN
        IF l_utilization_rec.gl_posted_flag IS NULL OR l_utilization_rec.gl_posted_flag = G_GL_FLAG_YES THEN
          l_utilization_rec.gl_date := l_utilization_rec.adjustment_date;
        END IF;
      END IF;

      --get amount for universal currency and used to update rollup amount.
      IF g_universal_currency IS NULL THEN
         IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('OZF', 'OZF_UNIV_CURR_NOT_FOUND');
            fnd_msg_pub.add;
         END IF;
            RAISE fnd_api.g_exc_error;
      END IF;

      --rimehrot for R12, populate universal currency amount column
      IF g_universal_currency = l_utilization_rec.currency_code THEN
         l_utilization_rec.univ_curr_amount := l_utilization_rec.amount;
         l_utilization_rec.univ_curr_amount_remaining := l_utilization_rec.amount_remaining;
      ELSIF g_universal_currency = l_utilization_rec.plan_currency_code THEN
         l_utilization_rec.univ_curr_amount := l_utilization_rec.plan_curr_amount;
         l_utilization_rec.univ_curr_amount_remaining := l_utilization_rec.plan_curr_amount_remaining;
      ELSE
         /*Added for bug 7030415 - Send the exchange rate
        Utilization amount is converted from request curr to universal curr to populate univ_curr_amount
        column in ozf_funds_utilized_all_b */

        IF g_debug_flag = 'Y' THEN
         ozf_utility_pvt.write_conc_log('**************************START****************************');
         ozf_utility_pvt.write_conc_log(l_api_name||' From Amount: '||l_utilization_rec.amount );
         ozf_utility_pvt.write_conc_log(l_api_name||' From Curr: '||l_utilization_rec.currency_code );
         ozf_utility_pvt.write_conc_log(l_api_name||' to curr univ_curr_amount: '|| g_universal_currency);
         ozf_utility_pvt.write_conc_log(l_api_name||' l_exchange_rate_type: '|| l_utilization_rec.exchange_rate_type);
        END IF;
         ozf_utility_pvt.convert_currency (
                   p_from_currency=> l_utilization_rec.plan_currency_code
                  ,p_to_currency=> g_universal_currency
                  ,p_conv_type=> l_utilization_rec.exchange_rate_type --Added for bug 7030415
                  ,p_from_amount=> l_utilization_rec.plan_curr_amount
                  ,x_return_status=> l_return_status
                  ,x_to_amount=> l_utilization_rec.univ_curr_amount
                  ,x_rate=> l_rate
                );
         IF g_debug_flag = 'Y' THEN
          ozf_utility_pvt.write_conc_log(l_api_name||' Converted Amount l_utilization_rec.univ_curr_amount: '|| l_utilization_rec.univ_curr_amount);
          ozf_utility_pvt.write_conc_log('Utilization amount is converted from request curr to universal curr to populate univ_curr_amount column in izf_funds_utilized_all_b');
         END IF;
         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         END IF;
         /* Send the exchange rate for bug 7030415 */
         ozf_utility_pvt.convert_currency (
                   p_from_currency=> l_utilization_rec.plan_currency_code
                  ,p_to_currency=> g_universal_currency
                  ,p_conv_type=> l_utilization_rec.exchange_rate_type --Added for bug 7030415
                  ,p_from_amount=> l_utilization_rec.plan_curr_amount_remaining
                  ,x_return_status=> l_return_status
                  ,x_to_amount=> l_utilization_rec.univ_curr_amount_remaining
                  ,x_rate=> l_rate
                );
         IF g_debug_flag = 'Y' THEN
           ozf_utility_pvt.write_conc_log(l_api_name||' From Amount: '||l_utilization_rec.amount_remaining );
           ozf_utility_pvt.write_conc_log(l_api_name||' Converted Amount l_utilization_rec.univ_curr_amount_remaining: '|| l_utilization_rec.univ_curr_amount_remaining);
           ozf_utility_pvt.write_conc_log('Utilization amount is converted from request curr to universal curr to populate univ_curr_amount column in izf_funds_utilized_all_b');
           ozf_utility_pvt.write_conc_log('***************************END******************************');
         END IF;
         IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF; -- g_universal_currency = l_utilization_rec.currency_code

      INSERT INTO ozf_funds_utilized_all_b
                     (utilization_id,last_update_date
                     ,last_updated_by,last_update_login
                     ,creation_date,created_by
                     ,created_from,request_id
                     ,program_application_id,program_id
                     ,program_update_date,utilization_type
                     ,fund_id,plan_type
                     ,plan_id,component_type,component_id
                     ,object_type,object_id
                     ,order_id,invoice_id
                     ,amount,acctd_amount
                     ,currency_code,exchange_rate_type
                     ,exchange_rate_date,exchange_rate
                     ,adjustment_type,adjustment_date
                     ,object_version_number,attribute_category
                     ,attribute1,attribute2
                     ,attribute3,attribute4
                     ,attribute5,attribute6
                     ,attribute7,attribute8
                     ,attribute9,attribute10
                     ,attribute11,attribute12
                     ,attribute13,attribute14
                     ,attribute15,org_id
                     ,adjustment_type_id,camp_schedule_id
                     ,gl_date, gl_posted_flag
                     ,product_level_type
                     ,product_id,ams_activity_budget_id
                     ,amount_remaining,acctd_amount_remaining
                     ,cust_account_id,price_adjustment_id
                     ,plan_curr_amount,plan_curr_amount_remaining
                     ,scan_unit,scan_unit_remaining
                     ,activity_product_id,volume_offer_tiers_id
                     --  11/04/2003   yzhao     11.5.10: added
                     ,billto_cust_account_id
                     ,reference_type
                     ,reference_id
                     /*fix for bug 4778995
                     ,month_id
                     ,quarter_id
                     ,year_id
                     */
                     ,order_line_id
                     ,orig_utilization_id -- added by feliu on 08/03/04
                     -- added by rimehrot for R12
                     ,bill_to_site_use_id
                     ,ship_to_site_use_id
                     ,univ_curr_amount
                     ,univ_curr_amount_remaining
                     ,fund_request_currency_code
                     ,fund_request_amount
                     ,fund_request_amount_remaining
                     ,plan_currency_code
        )
              VALUES (l_utilization_rec.utilization_id,SYSDATE -- LAST_UPDATE_DATE
                     ,NVL (fnd_global.user_id, -1),NVL (fnd_global.conc_login_id, -1) -- LAST_UPDATE_LOGIN
                     ,SYSDATE,NVL (fnd_global.user_id, -1) -- CREATED_BY
                     ,l_utilization_rec.created_from,fnd_global.conc_request_id -- REQUEST_ID
                     ,fnd_global.prog_appl_id,fnd_global.conc_program_id -- PROGRAM_ID
                     ,SYSDATE,l_utilization_rec.utilization_type
                     ,l_utilization_rec.fund_id,l_utilization_rec.plan_type
                     ,l_utilization_rec.plan_id,l_utilization_rec.component_type
                     ,l_utilization_rec.component_id,l_utilization_rec.object_type
                     ,l_utilization_rec.object_id,l_utilization_rec.order_id
                     ,l_utilization_rec.invoice_id,l_utilization_rec.amount
                     ,l_utilization_rec.acctd_amount,l_utilization_rec.currency_code
                     ,l_utilization_rec.exchange_rate_type,SYSDATE
                     ,l_utilization_rec.exchange_rate,l_utilization_rec.adjustment_type
                     ,l_utilization_rec.adjustment_date,1 -- object_version_number
                     ,l_utilization_rec.attribute_category,l_utilization_rec.attribute1
                     ,l_utilization_rec.attribute2
                     ,l_utilization_rec.attribute3,l_utilization_rec.attribute4
                     ,l_utilization_rec.attribute5,l_utilization_rec.attribute6
                     ,l_utilization_rec.attribute7,l_utilization_rec.attribute8
                     ,l_utilization_rec.attribute9,l_utilization_rec.attribute10
                     ,l_utilization_rec.attribute11,l_utilization_rec.attribute12
                     ,l_utilization_rec.attribute13,l_utilization_rec.attribute14
                     ,l_utilization_rec.attribute15,l_utilization_rec.org_id--TO_NUMBER (SUBSTRB (USERENV ('CLIENT_INFO'), 1, 10)) -- org_id
                     ,l_utilization_rec.adjustment_type_id,l_utilization_rec.camp_schedule_id
                     ,l_utilization_rec.gl_date, l_utilization_rec.gl_posted_flag
                     ,l_utilization_rec.product_level_type
                     ,l_utilization_rec.product_id,l_utilization_rec.ams_activity_budget_id
                     ,l_utilization_rec.amount_remaining,l_utilization_rec.acctd_amount_remaining
                     ,l_utilization_rec.cust_account_id,l_utilization_rec.price_adjustment_id
                     ,l_utilization_rec.plan_curr_amount,l_utilization_rec.plan_curr_amount_remaining
                     ,l_utilization_rec.scan_unit,l_utilization_rec.scan_unit_remaining
                     ,l_utilization_rec.activity_product_id,l_utilization_rec.volume_offer_tiers_id
                     --  11/04/2003   yzhao     11.5.10: added
                     ,l_utilization_rec.billto_cust_account_id
                     ,l_utilization_rec.reference_type
                     ,l_utilization_rec.reference_id
                     /*fix for bug 4778995
                     ,l_utilization_rec.month_id
                     ,l_utilization_rec.quarter_id
                     ,l_utilization_rec.year_id
                     */
                     ,l_utilization_rec.order_line_id
                     ,l_utilization_rec.orig_utilization_id
                     -- added by rimehrot for R12
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
                     (utilization_id,last_update_date
                     ,last_updated_by,last_update_login
                     ,creation_date,created_by
                     ,created_from,request_id
                     ,program_application_id,program_id
                     ,program_update_date,adjustment_desc
                     ,source_lang,language
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
                  ,l_utilization_rec.org_id --TO_NUMBER (SUBSTRB (USERENV ('CLIENT_INFO'), 1, 10)) -- org_id
              FROM fnd_languages l
              WHERE l.installed_flag IN ('I', 'B')
              AND NOT EXISTS ( SELECT NULL
                                  FROM ozf_funds_utilized_all_tl t
                                 WHERE t.utilization_id = l_utilization_rec.utilization_id
                                   AND t.language = l.language_code);

         x_utilization_id :=       l_utilization_rec.utilization_id  ;

         IF l_utilization_rec.utilization_type IN ('ACCRUAL', 'SALES_ACCRUAL', 'UTILIZED', 'ADJUSTMENT') THEN
            /* R12: yzhao bug 4669269 - obsolete ozf_mc_transactions
                OPEN c_mc_trans (l_utilization_rec.fund_id);
                FETCH c_mc_trans INTO l_mc_record_id
                                     ,l_mc_obj_num
                                     ,l_mc_col_1
                                     ,l_mc_col_6        -- yzhao: 10/14/2003 added
                                     ,l_mc_col_7
                                     ,l_mc_col_8
                     ,l_mc_col_9;
                IF (c_mc_trans%NOTFOUND) THEN
                   CLOSE c_mc_trans;
                   IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                      fnd_message.set_name ('OZF', 'OZF_API_RECORD_NOT_FOUND');
                      fnd_msg_pub.ADD;
                   END IF;
                   RAISE fnd_api.g_exc_error;
                END IF;
                CLOSE c_mc_trans;
            */
               -- rimehrot changed for R12, Populate new table ozf_object_fund_summary
               -- rimehrot: component_id/type is the destination. Will always be equal to plan_id/type in this case
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

            IF l_fund_type = 'FULLY_ACCRUED' THEN
               -- for a fully accrued customer fund with liability flag on, the budgeted, utilized and committed column gets populated
               -- 11.5.10: update utilized_amt, not earned_amt
               IF l_accrual_basis = 'CUSTOMER' AND NVL(l_liability_flag, 'N') = 'Y' THEN
                  l_original_budget := NVL (l_original_budget, 0)+ NVL (l_utilization_rec.amount, 0);
                  l_utilized_amt     := NVL (l_utilized_amt, 0)+ NVL (l_utilization_rec.amount, 0);
                  l_rollup_orig_amt :=NVL(l_rollup_orig_amt,0) + NVL (l_utilization_rec.univ_curr_amount, 0);
                  l_rollup_utilized_amt := NVL(l_rollup_utilized_amt,0) + NVL (l_utilization_rec.univ_curr_amount, 0);
                  -- l_mc_col_1     := NVL(l_mc_col_1,0) +  NVL (l_utilization_rec.acctd_amount, 0);
                  -- l_mc_col_9     := NVL(l_mc_col_9,0) +  NVL (l_utilization_rec.acctd_amount, 0);
                  l_new_orig_amt := NVL (l_utilization_rec.univ_curr_amount, 0);
                  l_new_utilized_amt := NVL (l_utilization_rec.univ_curr_amount, 0);
                  l_new_paid_amt := 0;

                 -- rimehrot changed for R12, Populate utilized/committed/recal_committed in ozf_object_fund_summary
                  l_objfundsum_rec.utilized_amt := NVL(l_objfundsum_rec.utilized_amt, 0) + NVL(l_utilization_rec.amount, 0);
                  l_objfundsum_rec.plan_curr_utilized_amt := NVL(l_objfundsum_rec.plan_curr_utilized_amt, 0)
                                                               --nirprasa,use new plan currency column
                                                               -- + NVL(l_utilization_rec.plan_curr_amount, 0);*/
                                                               + NVL(l_utilization_rec.fund_request_amount, 0);
                  l_objfundsum_rec.univ_curr_utilized_amt := NVL(l_objfundsum_rec.univ_curr_utilized_amt, 0)
                                                                  + NVL(l_utilization_rec.univ_curr_amount, 0);
                  l_objfundsum_rec.committed_amt := NVL(l_objfundsum_rec.committed_amt, 0) + NVL(l_utilization_rec.amount, 0);
                  l_objfundsum_rec.plan_curr_committed_amt := NVL(l_objfundsum_rec.plan_curr_committed_amt, 0)
                                                                  + NVL(l_utilization_rec.plan_curr_amount, 0);
                  l_objfundsum_rec.univ_curr_committed_amt := NVL(l_objfundsum_rec.univ_curr_committed_amt, 0)
                                                                  + NVL(l_utilization_rec.univ_curr_amount, 0);
                  l_objfundsum_rec.recal_committed_amt := NVL(l_objfundsum_rec.recal_committed_amt, 0)
                                                                  + NVL(l_utilization_rec.amount, 0);
                  l_objfundsum_rec.plan_curr_recal_committed_amt := NVL(l_objfundsum_rec.plan_curr_recal_committed_amt, 0)
                                                                  + NVL(l_utilization_rec.plan_curr_amount, 0);
                  l_objfundsum_rec.univ_curr_recal_committed_amt := NVL(l_objfundsum_rec.univ_curr_recal_committed_amt, 0)
                                                                  + NVL(l_utilization_rec.univ_curr_amount, 0);
                 -- rimehrot: end changes for R12

                  -- yzhao: 10/14/2003 Fix TEVA bug - customer fully accrual budget committed amount is always 0 even when accrual happens
                  -- l_mc_col_6     := NVL(l_mc_col_6,0) +  NVL (l_utilization_rec.acctd_amount, 0);
                  l_new_committed_amt := NVL (l_utilization_rec.univ_curr_amount, 0);
                  l_new_recal_committed := NVL (l_utilization_rec.univ_curr_amount, 0);
                  l_committed_amt := NVL(l_committed_amt, 0) + NVL (l_utilization_rec.amount, 0);
                  l_rollup_committed_amt := NVL(l_rollup_committed_amt, 0) + NVL (l_utilization_rec.univ_curr_amount, 0);
                  l_recal_committed := NVL(l_recal_committed, 0) + NVL (l_utilization_rec.amount, 0);
                  l_rollup_recal_committed := NVL(l_rollup_recal_committed, 0) + NVL (l_utilization_rec.univ_curr_amount, 0);

                  -- 10/14/2003  update ozf_act_budgets REQUEST between fully accrual budget and its offer when accrual happens
                  OPEN  c_accrual_budget_reqeust(l_utilization_rec.fund_id, l_plan_id);
                  FETCH c_accrual_budget_reqeust INTO l_act_budget_id, l_act_budget_objver;
                  IF (c_accrual_budget_reqeust%NOTFOUND) THEN
                     ozf_utility_pvt.write_conc_log ('    D: create_utilized_rec() ERROR customer fully accrual budget. can not find approved budget request record between fund '
                                     || l_utilization_rec.fund_id || ' and offer ' || l_plan_id);
                     CLOSE c_accrual_budget_reqeust;
                     IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                       fnd_message.set_name ('OZF', 'OZF_API_RECORD_NOT_FOUND');
                       fnd_msg_pub.ADD;
                     END IF;
                     RAISE fnd_api.g_exc_error;
                  END IF;
                  CLOSE c_accrual_budget_reqeust;

                  UPDATE ozf_act_budgets
                    SET    request_amount = NVL(request_amount, 0) + l_utilization_rec.plan_curr_amount
                          , src_curr_request_amt = NVL(src_curr_request_amt, 0) + l_utilization_rec.amount
                          , approved_amount = NVL(approved_amount, 0) + l_utilization_rec.fund_request_amount
                          , approved_original_amount = NVL(approved_original_amount, 0) + l_utilization_rec.amount
                          , approved_amount_fc = NVL(approved_amount_fc, 0) + l_utilization_rec.acctd_amount
                          , last_update_date = sysdate
                          , last_updated_by = NVL (fnd_global.user_id, -1)
                          , last_update_login = NVL (fnd_global.conc_login_id, -1)
                          , object_version_number = l_act_budget_objver + 1
                  WHERE  activity_budget_id = l_act_budget_id
                  AND    object_version_number = l_act_budget_objver;

              -- 4619156, comment as request no longer in util table.
               /*   OPEN c_budget_request_utilrec(l_utilization_rec.fund_id, l_plan_id, l_act_budget_id);
                  FETCH c_budget_request_utilrec INTO l_act_budget_id, l_act_budget_objver;
                  IF (c_budget_request_utilrec%NOTFOUND) THEN
                      write_conc_log ('    D: create_utilized_rec() ERROR customer fully accrual budget. can not find approved budget request record in utilization table between fund '
                                      || l_utilization_rec.fund_id || ' and offer ' || l_plan_id);
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
                  SET    amount = NVL(amount,0) + NVL(l_utilization_rec.amount,0)
                       , plan_curr_amount = NVL(plan_curr_amount,0) + NVL(l_utilization_rec.plan_curr_amount,0)
                       , univ_curr_amount = NVL(univ_curr_amount, 0) + NVL(l_utilization_rec.univ_curr_amount, 0)
                       , acctd_amount = NVL(acctd_amount,0) + NVL(l_utilization_rec.acctd_amount,0)
                       , last_update_date = sysdate
                       , last_updated_by = NVL (fnd_global.user_id, -1)
                       , last_update_login = NVL (fnd_global.conc_login_id, -1)
                       , object_version_number = l_act_budget_objver + 1
                  WHERE  utilization_id = l_act_budget_id
                  AND    object_version_number = l_act_budget_objver;*/
                  -- yzhao: 10/14/2003 END Fix TEVA bug - customer fully accrual budget committed amount is always 0

               -- for a fully accrued sales fund and customer accrual with liability flag off,
               -- then only the budgeted column gets populated
               -- ELSIF l_accrual_basis = 'SALES' THEN
            /*  feliu1122
               ELSE
                  l_original_budget :=NVL (l_original_budget, 0)+ NVL (l_utilization_rec.amount, 0);
                  l_rollup_orig_amt :=NVL(l_rollup_orig_amt,0) + NVL (l_new_univ_amt, 0);
                  -- l_mc_col_1     := NVL(l_mc_col_1,0) +  NVL (l_utilization_rec.acctd_amount, 0);
                  l_new_orig_amt := NVL (l_new_univ_amt, 0);
                  l_new_utilized_amt := 0;
                  l_new_paid_amt := 0;
*/             END IF;
            ELSE -- for fixed budget
                  -- utilized is always updated for Accrual or Utilized record
               l_utilized_amt      := NVL (l_utilized_amt, 0) + NVL (l_utilization_rec.amount, 0);
               l_rollup_utilized_amt := NVL(l_rollup_utilized_amt,0) + NVL (l_utilization_rec.univ_curr_amount, 0);
               l_new_utilized_amt := NVL (l_utilization_rec.univ_curr_amount, 0);
                  -- l_mc_col_9     := NVL(l_mc_col_9,0) +  NVL (l_utilization_rec.acctd_amount, 0);
                  -- rimehrot: for R12, populate utilized amount
               l_objfundsum_rec.utilized_amt := NVL(l_objfundsum_rec.utilized_amt, 0) + NVL(l_utilization_rec.amount, 0);
               l_objfundsum_rec.plan_curr_utilized_amt := NVL(l_objfundsum_rec.plan_curr_utilized_amt, 0)
                                                                --  + NVL(l_utilization_rec.plan_curr_amount, 0);
                                                                + NVL(l_utilization_rec.fund_request_amount, 0);
               l_objfundsum_rec.univ_curr_utilized_amt := NVL(l_objfundsum_rec.univ_curr_utilized_amt, 0)
                                                                  + NVL(l_utilization_rec.univ_curr_amount, 0);

                  -- end R12 changes
                  -- 11.5.10: for off-invoice offer, if posting to gl flag is off, utilized, eanred and paid updated the same time
                  --          if flag is on, only utilized will be updated, earned and paid will be updated after gl posting
                  --          fix bug 3428988 - for accrual offer, do not update paid and earned amount when creating utilization
                  /* feliu 1121
                  IF l_utilization_rec.utilization_type = 'UTILIZED' AND l_off_invoice_gl_post_flag = 'F' THEN
                     l_earned_amt      := NVL (l_earned_amt, 0) + NVL (l_utilization_rec.amount, 0);
                     l_rollup_earned_amt := NVL(l_rollup_earned_amt,0) + NVL (l_new_univ_amt, 0);
                     l_new_earned_amt := NVL (l_new_univ_amt, 0);
                     -- l_mc_col_7     := NVL(l_mc_col_7,0) +  NVL (l_utilization_rec.acctd_amount, 0);
                     l_paid_amt      := NVL (l_paid_amt, 0) + NVL (l_utilization_rec.amount, 0);
                     l_rollup_paid_amt := NVL(l_rollup_paid_amt,0) + NVL (l_new_univ_amt, 0);
                     l_new_paid_amt := NVL (l_new_univ_amt, 0);
                     -- l_mc_col_8     := NVL(l_mc_col_8,0) +  NVL (l_utilization_rec.acctd_amount, 0);
                     -- rimehrot: for R12, populate earned/paid amount
                     l_objfundsum_rec.earned_amt := NVL(l_objfundsum_rec.earned_amt, 0) + NVL(l_utilization_rec.amount, 0);
                     l_objfundsum_rec.plan_curr_earned_amt := NVL(l_objfundsum_rec.plan_curr_earned_amt, 0)
                                                                  + NVL(l_utilization_rec.plan_curr_amount, 0);
                     l_objfundsum_rec.univ_curr_earned_amt := NVL(l_objfundsum_rec.univ_curr_earned_amt, 0)
                                                                  + NVL(l_utilization_rec.univ_curr_amount, 0);

                     l_objfundsum_rec.paid_amt := NVL(l_objfundsum_rec.paid_amt, 0) + NVL(l_utilization_rec.amount, 0);
                     l_objfundsum_rec.plan_curr_paid_amt := NVL(l_objfundsum_rec.plan_curr_paid_amt, 0)
                                                                  + NVL(l_utilization_rec.plan_curr_amount, 0);
                     l_objfundsum_rec.univ_curr_paid_amt := NVL(l_objfundsum_rec.univ_curr_paid_amt, 0)
                                                                  + NVL(l_utilization_rec.univ_curr_amount, 0);
                     -- end R12 changes
                  END IF;  */
            END IF; -- end of fund_type.

            UPDATE ozf_funds_all_b
            SET original_budget =  l_original_budget,
                utilized_amt = l_utilized_amt,
                earned_amt = l_earned_amt,
                paid_amt = l_paid_amt,
                object_version_number = l_obj_num + 1
                ,rollup_original_budget = l_rollup_orig_amt
                ,rollup_utilized_amt = l_rollup_utilized_amt
                ,rollup_earned_amt = l_rollup_earned_amt
                ,rollup_paid_amt = l_rollup_paid_amt
                -- yzhao: 10/14/2003 Fix TEVA bug - customer fully accrual budget committed amount is always 0 even when accrual happens
                ,committed_amt = l_committed_amt
                ,rollup_committed_amt = l_rollup_committed_amt
                ,recal_committed = l_recal_committed
                ,rollup_recal_committed = l_rollup_recal_committed
            WHERE fund_id =  l_utilization_rec.fund_id
            AND object_version_number = l_obj_num;

            IF l_parent_fund_id is NOT NULL THEN
               FOR fund IN c_parent(l_parent_fund_id)
               LOOP
                  UPDATE ozf_funds_all_b
                  SET object_version_number = fund.object_version_number + 1
                   ,rollup_original_budget = NVL(fund.rollup_original_budget,0) + NVL(l_new_orig_amt,0)
                   ,rollup_earned_amt = NVL(fund.rollup_earned_amt,0) + NVL(l_new_earned_amt,0)
                   ,rollup_paid_amt = NVL(fund.rollup_paid_amt,0) + NVL(l_new_paid_amt,0)
                   -- yzhao: 10/14/2003 Fix TEVA bug - customer fully accrual budget committed amount is always 0 even when accrual happens
                   ,rollup_committed_amt = NVL(fund.rollup_committed_amt, 0) + NVL(l_new_committed_amt, 0)
                   ,rollup_recal_committed = NVL(fund.rollup_recal_committed, 0) + NVL(l_new_recal_committed, 0)
                   -- yzhao: 11.5.10
                   ,rollup_utilized_amt = NVL(fund.rollup_utilized_amt,0) + NVL(l_new_utilized_amt,0)
                  WHERE fund_id = fund.fund_id
                  AND object_version_number = fund.object_version_number;
                END LOOP;
            END IF;

          -- rimehrot: for R12, create or update in ozf_object_fund_summary
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
               ozf_objfundsum_pvt.update_objfundsum(
                       p_api_version                => 1.0,
                       p_init_msg_list              => Fnd_Api.G_FALSE,
                       p_validation_level           => Fnd_Api.G_VALID_LEVEL_NONE,
                       p_objfundsum_rec             => l_objfundsum_rec,
                       x_return_status              => l_return_status,
                       x_msg_count                  => x_msg_count,
                       x_msg_data                   => x_msg_data
                );
               IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
               END IF;
            END IF;
            -- rimehrot: end changes for R12

          /* R12 yzhao: bug 4669269 - obsolete ozf_mc_transactions
          -- update ozf_mc_transaction_all table.
          UPDATE ozf_mc_transactions_all
            SET amount_column1 =l_mc_col_1,
                amount_column6 =l_mc_col_6,   -- yzhao: 10/14/2003
                amount_column7 =l_mc_col_7,
                amount_column8 =l_mc_col_8,
                amount_column9 =l_mc_col_9,   -- yzhao: 11.5.10 for utilized_amt
                object_version_number = l_mc_obj_num + 1
            WHERE mc_record_id = l_mc_record_id
            AND object_version_number = l_mc_obj_num;
           */
         END IF; -- end if utilization type

        /* yzhao: 03/19/2003 post to GL when order is shipped. move to function post_accrual_to_gl */

        IF g_debug_flag = 'Y' THEN
         ozf_utility_pvt.write_conc_log(   l_full_name
                                     || ': end' || l_event_id);
        END IF;

        fnd_msg_pub.count_and_get (
            p_count=> x_msg_count,
            p_data=> x_msg_data,
            p_encoded=> fnd_api.g_false
         );

   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO create_utilized_rec;
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count,
            p_data=> x_msg_data,
            p_encoded=> fnd_api.g_false
         );

      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO create_utilized_rec;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count,
            p_data=> x_msg_data,
            p_encoded=> fnd_api.g_false
         );

      WHEN OTHERS THEN
         ROLLBACK TO create_utilized_rec;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count,
            p_data=> x_msg_data,
            p_encoded=> fnd_api.g_false
         );


   END create_utilized_rec;

----------------------------------------------------------------------------------
-- Procedure Name
--  create_utilization
-- created by mpande 02/08/2002
-- Purpose
--   This procedure will create utiliation records for the order accruals
-----------------------------------------------------------------------------------
   PROCEDURE create_fund_utilization (
      p_act_util_rec      IN       ozf_fund_utilized_pvt.utilization_rec_type,
      p_act_budgets_rec   IN       ozf_actbudgets_pvt.act_budgets_rec_type,
      x_utilization_id    OUT NOCOPY      NUMBER,
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2
   ) IS
      l_api_version           NUMBER                                  := 1.0;
      l_api_name              VARCHAR2 (60)                           := 'create_fund_utilization';
      l_act_budget_id         NUMBER;
      l_act_budgets_rec       ozf_actbudgets_pvt.act_budgets_rec_type := p_act_budgets_rec;
      l_act_util_rec          ozf_fund_utilized_pvt.utilization_rec_type    := p_act_util_rec;
      l_activity_id           NUMBER;
      l_obj_ver_num           NUMBER;
      l_old_approved_amount   NUMBER;
      l_old_parent_src_amt    NUMBER;
      l_ledger_id             NUMBER;
      l_ledger_name           VARCHAR2(30);
      l_utilization_id        NUMBER;

      /* -- 6/3/2002 mpande changed as per PM specifications --
        We should accrue to the bill to org but not o the sold to org
      CURSOR c_cust_number (p_header_id IN NUMBER) IS
         SELECT sold_to_org_id
           FROM oe_order_headers_all
          WHERE header_id = p_header_id;
         */
      CURSOR c_cust_number (p_header_id IN NUMBER) IS
         SELECT cust.cust_account_id, header.invoice_to_org_id, header.ship_to_org_id
           FROM hz_cust_acct_sites_all acct_site,
                hz_cust_site_uses_all site_use,
                hz_cust_accounts  cust,
                oe_order_headers_all header
          WHERE header.header_id = p_header_id
              AND acct_site.cust_acct_site_id = site_use.cust_acct_site_id
            AND acct_site.cust_account_id = cust.cust_account_id
            AND site_use.site_use_id = header.invoice_to_org_id ;

      -- Cursor to get the org_id for order
      CURSOR c_org_id (p_order_header_id IN NUMBER)IS
         SELECT org_id FROM oe_order_headers_all
         WHERE header_id = p_order_header_id;

      --nirprasa,ER 8399134
      CURSOR c_offer_info (p_list_header_id IN NUMBER) IS
         SELECT qp.orig_org_id offer_org_id
        FROM qp_list_headers_all qp, ozf_offers off
          WHERE qp.list_header_id = p_list_header_id
            AND qp.list_header_id = off.qp_list_header_id;

      l_offer_info            c_offer_info%ROWTYPE;
   BEGIN
      SAVEPOINT create_fund_utilization_acr;
      x_return_status            := fnd_api.g_ret_sts_success;
      IF g_debug_flag = 'Y' THEN
         ozf_utility_pvt.write_conc_log ('    D:  Enter create_fund_utilization() ');
      END IF;
      l_act_util_rec.product_level_type := 'PRODUCT';
      IF l_act_util_rec.billto_cust_account_id IS NULL THEN
          --  customer id
          OPEN c_cust_number (p_act_util_rec.object_id);
          FETCH c_cust_number INTO l_act_util_rec.billto_cust_account_id, l_act_util_rec.bill_to_site_use_id, l_act_util_rec.ship_to_site_use_id;
          CLOSE c_cust_number;
      END IF;

      l_act_budgets_rec.justification := fnd_message.get_string ('OZF', 'OZF_FUND_ASO_ORD_FEEDBACK');
      l_act_budgets_rec.transfer_type := 'UTILIZED';
      l_act_budgets_rec.request_date := SYSDATE;
      l_act_budgets_rec.status_code := 'APPROVED';
      l_act_budgets_rec.user_status_id :=
            ozf_utility_pvt.get_default_user_status (
               'OZF_BUDGETSOURCE_STATUS',
               l_act_budgets_rec.status_code
            );
      --nirprasa, ER 8399134 Arrow's case: If offer is not a global offer and applied to an order
      -- of different OU then use offer's org.
      OPEN c_offer_info(l_act_util_rec.plan_id);
      FETCH c_offer_info INTO l_offer_info;
      CLOSE c_offer_info;

      IF l_offer_info.offer_org_id IS NOT NULL AND l_offer_info.offer_org_id  <> l_act_util_rec.org_id THEN
         l_act_util_rec.org_id := l_offer_info.offer_org_id ;
      END IF;
      --end ER 8399134
      IF l_act_util_rec.org_id IS NULL THEN
          OPEN c_org_id( l_act_util_rec.object_id) ;
          FETCH c_org_id INTO l_act_util_rec.org_id;
          CLOSE c_org_id ;
      END IF;

      IF g_debug_flag = 'Y' THEN
      ozf_utility_pvt.write_conc_log ('  l_act_budgets_rec.user_status_id '||l_act_budgets_rec.user_status_id);
      ozf_utility_pvt.write_conc_log ('  l_act_budgets_rec.org_id '||l_act_util_rec.org_id);
      END IF;

      --get the order's ledger id
      mo_utils.Get_Ledger_Info (p_operating_unit => l_act_util_rec.org_id
                               ,p_ledger_id      => l_ledger_id
                               ,p_ledger_name    => l_ledger_name);
      IF g_debug_flag = 'Y' THEN
      ozf_utility_pvt.write_conc_log (' l_ledger_id '||l_ledger_id);
      ozf_utility_pvt.write_conc_log (' l_ledger_name '|| l_ledger_name);
      END IF;

      create_actbudgets_rec (
        x_return_status       =>x_return_status
        ,x_msg_count          =>x_msg_count
        ,x_msg_data           =>x_msg_data
        ,x_act_budget_id      =>l_activity_id
        ,p_act_budgets_rec    =>l_act_budgets_rec
        ,p_ledger_id          => l_ledger_id        -- yzhao: added for R12
        ,p_org_id             =>l_act_util_rec.org_id -- nirprasa added to get conversion type for bug 7030415
      );

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         ozf_utility_pvt.write_conc_log (': create Act Budgets Failed '||x_return_status);
         IF x_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      l_act_util_rec.ams_activity_budget_id := l_activity_id;
      create_utilized_rec (
        x_return_status      =>x_return_status
        ,x_msg_count           =>x_msg_count
        ,x_msg_data           =>x_msg_data
        ,x_utilization_id     =>l_utilization_id
        ,p_utilization_rec    =>l_act_util_rec
      );

      x_utilization_id := l_utilization_id;

      IF x_return_status <>fnd_api.g_ret_sts_success THEN
         ozf_utility_pvt.write_conc_log (': create utilization Failed '||x_return_status);
         IF x_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END IF;

      fnd_msg_pub.count_and_get (
         p_count=> x_msg_count,
         p_data=>x_msg_data,
         p_encoded=> fnd_api.g_false
      );
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO create_fund_utilization_acr;
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO create_fund_utilization_acr;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN OTHERS THEN
         ROLLBACK TO create_fund_utilization_acr;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
   END create_fund_utilization;

/*----------------------------------------------------------------------------
-- Procedure Name
--   post_accrual_to_budget
-- Purpose
--   This procedure will post accrual to budget proportionally, and create utilization records
--   extracted from adjust_accrual so it can be reused
--
-- Parameters:
--
-- History
--  created      yzhao     03/21/03
------------------------------------------------------------------------------*/
   PROCEDURE post_accrual_to_budget (
      p_adj_amt_tbl         IN  ozf_adjusted_amt_tbl_type,
      x_return_status       OUT NOCOPY      VARCHAR2,
      x_msg_count           OUT NOCOPY      NUMBER,
      x_msg_data            OUT NOCOPY      VARCHAR2
   ) IS
      l_return_status           VARCHAR2(1);
      l_offer_name              VARCHAR2(240);
      l_adj_amount              NUMBER;
      l_remaining_amount        NUMBER;
      l_rate                    NUMBER;
      l_converted_adj_amount    NUMBER;
      l_act_util_rec            ozf_actbudgets_pvt.act_util_rec_type;
      l_act_budgets_rec         ozf_actbudgets_pvt.act_budgets_rec_type;
      l_util_rec                ozf_fund_utilized_pvt.utilization_rec_type;
      l_fund_amt_tbl            ozf_fund_amt_tbl_type;
      l_cust_account_id         NUMBER;
      l_adjustment_date         DATE;
      l_bill_to_site_use_id     NUMBER;
      l_ship_to_site_use_id     NUMBER;
      l_utilization_id          NUMBER;

      l_order_org_id            NUMBER;
      l_exchange_rate_type      VARCHAR2(30) := FND_API.G_MISS_CHAR ;

       -- Added by rimehrot for R12
      CURSOR c_get_price_adj_dtl (p_price_adjustment_id IN NUMBER) IS
         SELECT creation_date
           FROM oe_price_adjustments adj
           WHERE adj.price_Adjustment_id = p_price_adjustment_id;

      CURSOR c_cust_number (p_header_id IN NUMBER) IS
         SELECT cust.cust_account_id, header.invoice_to_org_id, header.ship_to_org_id
           FROM hz_cust_acct_sites_all acct_site,
                hz_cust_site_uses_all site_use,
                hz_cust_accounts  cust,
                oe_order_headers_all header
          WHERE header.header_id = p_header_id
              AND acct_site.cust_acct_site_id = site_use.cust_acct_site_id
            AND acct_site.cust_account_id = cust.cust_account_id
            AND site_use.site_use_id = header.invoice_to_org_id ;

      --Added for bug 7030415, get order's org_id
      CURSOR c_order_org_id (p_line_id IN NUMBER) IS
         SELECT header.org_id
         FROM oe_order_lines_all line, oe_order_headers_all header
         WHERE line_id = p_line_id
         AND line.header_id = header.header_id;

      CURSOR c_offer_type (p_offer_id IN NUMBER) IS
         SELECT beneficiary_account_id,
               autopay_party_attr,autopay_party_id,transaction_currency_code
           FROM ozf_offers
          WHERE qp_list_header_id = p_offer_id;

      --Added for bug 7030415, get conversion type
      CURSOR c_get_conversion_type( p_org_id   IN   NUMBER) IS
         SELECT exchange_rate_type
         FROM   ozf_sys_parameters_all
         WHERE  org_id = p_org_id;

     --Added c_site_org_id for bug 6278466
      CURSOR c_site_org_id (p_site_use_id IN NUMBER) IS
         SELECT org_id
           FROM hz_cust_site_uses_all
          WHERE site_use_id = p_site_use_id;

      l_offer_type  c_offer_type%ROWTYPE;


   BEGIN
     x_return_status            := fnd_api.g_ret_sts_success;

     IF g_debug_flag = 'Y' THEN
        ozf_utility_pvt.write_conc_log('    D: Enter post_accrual_to_budget   p_adj_amt_tbl count=' || p_adj_amt_tbl.count);
     END IF;

     FOR i IN p_adj_amt_tbl.FIRST .. p_adj_amt_tbl.LAST
     LOOP

        IF g_debug_flag = 'Y' THEN
           ozf_utility_pvt.write_conc_log('D: Enter post_accrual_to_budget   price_adj_id=' || p_adj_amt_tbl(i).price_adjustment_id ||
                           ' amount=' || p_adj_amt_tbl(i).earned_amount);
        END IF;

        l_fund_amt_tbl.DELETE;

        OPEN c_cust_number(p_adj_amt_tbl(i).order_header_id);
        FETCH c_cust_number INTO l_cust_account_id, l_bill_to_site_use_id, l_ship_to_site_use_id;
        CLOSE c_cust_number;

        ozf_accrual_engine.calculate_accrual_amount (
          x_return_status  => l_return_status,
          p_src_id         => p_adj_amt_tbl(i).qp_list_header_id,
          p_earned_amt     => p_adj_amt_tbl(i).earned_amount,
          p_cust_account_type => 'BILL_TO',
          p_cust_account_id => l_cust_account_id,
          p_product_item_id => p_adj_amt_tbl(i).product_id,
          x_fund_amt_tbl   => l_fund_amt_tbl
        );

        IF g_debug_flag = 'Y' THEN
           ozf_utility_pvt.write_conc_log ('    D: post_adjust_to_budget(): Calculate Accrual Amount returns' || l_return_status);
        END IF;

        IF l_return_status <> fnd_api.g_ret_sts_success THEN
           IF l_return_status = fnd_api.g_ret_sts_error THEN
              RAISE fnd_api.g_exc_error;
           ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
              RAISE fnd_api.g_exc_unexpected_error;
           END IF;
        END IF;

        --- if this is not funded by a parent campaign or any budget the error OUT NOCOPY saying no budgte found
        IF l_fund_amt_tbl.COUNT = 0 THEN
           IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
              fnd_message.set_name ('OZF', 'OZF_FUND_NO_BUDGET_FOUND');
              fnd_message.set_token ('OFFER_ID', p_adj_amt_tbl(i).qp_list_header_id);
              fnd_msg_pub.ADD;
           END IF;
           IF g_debug_flag = 'Y' THEN
              ozf_utility_pvt.write_conc_log('    D: post_adjust_to_budget()  calculation for posting to budget failed. No posting to budget. RETURN');
           END IF;
           -- yzhao: 03/26/2003 should continue or error out?
           --RETURN;
           --kdass 24-MAR-2007 bug 5900966 - if no budget is attached to the offer, then move to process next record
           GOTO l_endofadjamtloop;
        END IF;

        l_adj_amount := 0; -- in offer currency
        l_remaining_amount  := p_adj_amt_tbl(i).earned_amount; -- in offer currency

        IF g_debug_flag = 'Y' THEN
           ozf_utility_pvt.write_conc_log (' D: post_adjust_to_budget() Begin loop l_remaining_amount '|| l_remaining_amount || ' l_adj amount ' || l_adj_amount);
        END IF;

        -- added by rimehrot for R12
        OPEN c_get_price_adj_dtl (p_adj_amt_tbl(i).price_adjustment_id);
        FETCH c_get_price_adj_dtl INTO l_adjustment_date;
        CLOSE c_get_price_adj_dtl;

        FOR j IN l_fund_amt_tbl.FIRST .. l_fund_amt_tbl.LAST
        LOOP
           l_act_budgets_rec :=NULL;
           l_util_rec :=NULL;
           IF l_remaining_amount >= l_fund_amt_tbl (j).earned_amount THEN
             l_adj_amount := l_fund_amt_tbl (j).earned_amount; -- this is in offer and order currency
           ELSE
             l_adj_amount := l_remaining_amount;
           END IF;
           l_remaining_amount := l_remaining_amount - l_adj_amount;

           --nirprasa, ER 8399134,multi-currency enhancement the amount is in order currency now.
           --IF p_adj_amt_tbl(i).offer_currency = l_fund_amt_tbl (j).budget_currency THEN
           IF p_adj_amt_tbl(i).order_currency = l_fund_amt_tbl (j).budget_currency THEN
              l_act_budgets_rec.parent_src_apprvd_amt :=l_adj_amount;
           ELSE
              IF g_debug_flag = 'Y' THEN
                 ozf_utility_pvt.write_conc_log ('    D: post_adjust_to_budget() In not equal currency');
              END IF;

              -- Added for bug 7030415, get the order's org_id to get the exchange rate.

              /*Adjustment amount is converted from plan curr to budgets curr to populate
              parent_src_apprvd_amt column in ozf_act_budgets table and amount column
              of ozf_funds_utilized_all_b table*/

                 OPEN c_order_org_id(p_adj_amt_tbl(i).order_line_id);
                 FETCH c_order_org_id INTO l_order_org_id;
                 CLOSE c_order_org_id;

                 OPEN c_offer_type(p_adj_amt_tbl(i).qp_list_header_id);
                 FETCH c_offer_type INTO l_offer_type;
                 CLOSE c_offer_type;

                 IF l_util_rec.cust_account_id IS NULL THEN
                   IF l_offer_type.beneficiary_account_id IS NOT NULL THEN
                    IF l_offer_type.autopay_party_attr <> 'CUSTOMER' AND l_offer_type.autopay_party_attr IS NOT NULL THEN

                      OPEN c_site_org_id (l_offer_type.autopay_party_id);
                      FETCH c_site_org_id INTO l_order_org_id;
                      CLOSE c_site_org_id;

                        END IF;
                    END IF;
                END IF;

                 OPEN c_get_conversion_type(l_order_org_id);
                 FETCH c_get_conversion_type INTO l_exchange_rate_type;
                 CLOSE c_get_conversion_type;

                IF g_debug_flag = 'Y' THEN
                  ozf_utility_pvt.write_conc_log('**************************START****************************');
                  ozf_utility_pvt.write_conc_log('post_accrual_to_budget' ||' From Amount l_adj_amount: '||l_adj_amount );
                  ozf_utility_pvt.write_conc_log('post_accrual_to_budget' ||' From Curr p_adj_amt_tbl(i).offer_currency: '||p_adj_amt_tbl(i).offer_currency );
                  ozf_utility_pvt.write_conc_log('post_accrual_to_budget' ||' From Curr p_adj_amt_tbl(i).order_currency '||p_adj_amt_tbl(i).order_currency );
                  ozf_utility_pvt.write_conc_log('post_accrual_to_budget' ||' To Curr l_fund_amt_tbl (j).budget_currency: '|| l_fund_amt_tbl (j).budget_currency);
                  ozf_utility_pvt.write_conc_log('post_accrual_to_budget' ||' l_exchange_rate_type: '|| l_exchange_rate_type);
                END IF;

              --nirprasa, ER 8399134 added if condition for null currency offer case where source currency for conversions will be order currency
              --and else condition to hadle arrows case when offer's currency is
              --different from order currency, in which case the source currency for conversions will be offer currency
              IF l_offer_type.transaction_currency_code IS NULL THEN
              ozf_utility_pvt.convert_currency (
               x_return_status => l_return_status,
               p_from_currency => p_adj_amt_tbl(i).order_currency,
               p_to_currency   => l_fund_amt_tbl (j).budget_currency,
               p_conv_type     => l_exchange_rate_type, -- nirprasa added for bug 7030415
               p_from_amount   => l_adj_amount,
               x_to_amount     => l_converted_adj_amount,
               x_rate          => l_rate
              );
              ELSE
              ozf_utility_pvt.convert_currency (
               x_return_status => l_return_status,
               p_from_currency => p_adj_amt_tbl(i).offer_currency,
               p_to_currency   => l_fund_amt_tbl (j).budget_currency,
               p_conv_type     => l_exchange_rate_type, -- nirprasa added for bug 7030415
               p_from_amount   => l_adj_amount,
               x_to_amount     => l_converted_adj_amount,
               x_rate          => l_rate
              );
              END IF;

               IF g_debug_flag = 'Y' THEN
                ozf_utility_pvt.write_conc_log('post_accrual_to_budget' ||' Converted Amount l_converted_adj_amount: '|| l_converted_adj_amount);
                ozf_utility_pvt.write_conc_log('Adjustment amount is converted from offer curr to budgets curr to populate parent_src_apprvd_amt column in izf_act_budgets table and amount column of ozf_funds_utilized_all_b table');
                ozf_utility_pvt.write_conc_log('***************************END******************************');
              END IF;

              IF l_return_status <> fnd_api.g_ret_sts_success THEN
                 IF g_debug_flag = 'Y' THEN
                    ozf_utility_pvt.write_conc_log ('   D: post_adjust_to_budget() convert currency failed. No posting to budget. Return');
                 END IF;
                 RAISE fnd_api.g_exc_unexpected_error;
              END IF;
              l_act_budgets_rec.parent_src_apprvd_amt :=l_converted_adj_amount;
           END IF;

           IF g_debug_flag = 'Y' THEN
              ozf_utility_pvt.write_conc_log (   '    D: post_adjust_to_budget() Adj amount coverted ' || l_converted_adj_amount
              || ' l_adj amount '     || l_adj_amount        );
           END IF;

           l_act_budgets_rec.budget_source_type := 'OFFR';
           l_act_budgets_rec.budget_source_id := p_adj_amt_tbl(i).qp_list_header_id;
           l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
           l_act_budgets_rec.act_budget_used_by_id := p_adj_amt_tbl(i).qp_list_header_id;
           l_act_budgets_rec.parent_src_curr := l_fund_amt_tbl (j).budget_currency;
           l_act_budgets_rec.parent_source_id := l_fund_amt_tbl (j).ofr_src_id;
           l_act_budgets_rec.request_amount :=l_adj_amount;
           --nirprasa, ER 8399134 multi currency enhancement
           --l_act_budgets_rec.request_currency := p_adj_amt_tbl(i).offer_currency;
           --nirprasa, ER 8399134 multi currency enhancement
           IF l_offer_type.transaction_currency_code IS NULL THEN
              l_act_budgets_rec.request_currency := p_adj_amt_tbl(i).order_currency;
           ELSE
              l_act_budgets_rec.request_currency := p_adj_amt_tbl(i).offer_currency;
           END IF;
           l_act_budgets_rec.approved_amount := l_act_budgets_rec.request_amount;
           --nirprasa, ER 8399134 multi currency enhancement
           --l_act_budgets_rec.approved_in_currency := p_adj_amt_tbl(i).offer_currency;
           l_act_budgets_rec.approved_in_currency := l_act_budgets_rec.request_currency;
           -- added by rimehrot for R12
           l_util_rec.bill_to_site_use_id := l_bill_to_site_use_id;
           l_util_rec.ship_to_site_use_id := l_ship_to_site_use_id;
           l_util_rec.billto_cust_account_id := l_cust_account_id;
           l_util_rec.adjustment_date := l_adjustment_date;
           l_util_rec.object_type := 'ORDER';
           l_util_rec.object_id   := p_adj_amt_tbl(i).order_header_id;
           l_util_rec.price_adjustment_id := p_adj_amt_tbl(i).price_adjustment_id;
           l_util_rec.amount := l_act_budgets_rec.parent_src_apprvd_amt;
           l_util_rec.plan_curr_amount := l_act_budgets_rec.request_amount;
           l_util_rec.component_type := 'OFFR';
           l_util_rec.component_id := p_adj_amt_tbl(i).qp_list_header_id ;
           l_util_rec.currency_code := l_fund_amt_tbl (j).budget_currency;
           l_util_rec.fund_id := l_fund_amt_tbl(j).ofr_src_id;
           l_util_rec.product_id := p_adj_amt_tbl(i).product_id ;
           l_util_rec.volume_offer_tiers_id := NULL;
           l_util_rec.gl_posted_flag := G_GL_FLAG_NO;  -- 'N'
           l_util_rec.billto_cust_account_id := l_cust_account_id;
           l_util_rec.order_line_id := p_adj_amt_tbl(i).order_line_id;
           --nirprasa, ER 8399134multi currency enhancement
           l_util_rec.plan_currency_code := l_act_budgets_rec.request_currency;
           l_util_rec.fund_request_currency_code := p_adj_amt_tbl(i).offer_currency;
           --nirprasa, ER 8399134 multi currency enhancement

           create_fund_utilization (
                p_act_util_rec     => l_util_rec,
                p_act_budgets_rec  => l_act_budgets_rec,
                x_utilization_id   => l_utilization_id,
                x_return_status    => l_return_status,
                x_msg_count        => x_msg_count,
                x_msg_data         => x_msg_data
              );
           IF l_return_status <> fnd_api.g_ret_sts_success THEN
              IF g_debug_flag = 'Y' THEN
                 ozf_utility_pvt.write_conc_log ('D: post_adjust_to_budget() create_fund_utilization() returns error. Exception');
              END IF;
              RAISE fnd_api.g_exc_unexpected_error;
           END IF;

           <<l_endofearadjloop>>

           IF g_debug_flag = 'Y' THEN
              ozf_utility_pvt.write_conc_log ( '    D: post_adjust_to_budget()  loop iteration end l_remaining_amount ' || l_remaining_amount
                || ' l_adj amount '|| l_adj_amount || ' fund_id '
                || l_fund_amt_tbl (j).ofr_src_id        );
           END IF;

           EXIT WHEN l_remaining_amount = 0;
        END LOOP earned_adj_loop;

        <<l_endofadjamtloop>>

        IF g_debug_flag = 'Y' THEN
           ozf_utility_pvt.write_conc_log('D: Ends successfully post_accrual_to_budget   price_adj_id=' || p_adj_amt_tbl(i).price_adjustment_id
                  || ' amount=' || p_adj_amt_tbl(i).earned_amount);
        END IF;

     END LOOP; -- p_adj_amt_tbl

     IF g_debug_flag = 'Y' THEN
        ozf_utility_pvt.write_conc_log('D: Ends of post_accrual_to_budget');
     END IF;

     x_return_status   := fnd_api.g_ret_sts_success;

     fnd_msg_pub.count_and_get (
            p_count=> x_msg_count,
            p_data=> x_msg_data,
            p_encoded=> fnd_api.g_false
         );

   EXCEPTION
      WHEN OTHERS THEN
        x_return_status            := fnd_api.g_ret_sts_unexp_error;
        ozf_utility_pvt.write_conc_log (' /**************UNEXPECTED EXCEPTION in ozf_accrual_engine.post_accrual_to_budget');
        IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
           fnd_msg_pub.add_exc_msg ('ozf_accrual_engine', 'post_accrual_to_budget');
        END IF;
        fnd_msg_pub.count_and_get (
            p_count=> x_msg_count,
            p_data=> x_msg_data,
            p_encoded=> fnd_api.g_false
         );
  END post_accrual_to_budget;

------------------------------------------------------------------------------
-- Procedure Name
--   Adjust_Accrual
-- Purpose
--   This procedure will calculate and update the accrual info.
--
--  created      pjindal     06/20/00
--  updated      mpande      07/18/00
--  updated      mpande      08/02/00 -- changed the fund_utlization creation calls
--  updated      mpande      02/02/01 -- changed the fund_type checks , benifit  limit checks
--  updated      mpande      12/28/2001  -- added line and header info also
------------------------------------------------------------------------------
   PROCEDURE adjust_accrual (
      p_api_version        IN       NUMBER,
      p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false,
      p_commit             IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      p_line_adj_tbl       IN       oe_order_pub.line_adj_tbl_type,
      p_old_line_adj_tbl   IN       oe_order_pub.line_adj_tbl_type,
      p_header_rec         IN       oe_order_pub.header_rec_type := NULL,
      p_exception_queue    IN       VARCHAR2 := fnd_api.g_false

   ) IS
      l_return_status           VARCHAR2 (10)                           := fnd_api.g_ret_sts_success;
      l_api_name       CONSTANT VARCHAR2 (30)                           := 'Adjust_Accrual';
      l_api_version    CONSTANT NUMBER                                  := 1.0;
      l_earned_amount           NUMBER;
      l_old_earned_amount       NUMBER;
      l_util_id                 NUMBER;
      l_adj_amount              NUMBER;
      l_line_quantity           NUMBER;
      l_old_adjusted_amount     NUMBER    := 0;
      l_cancelled_quantity      NUMBER;
      l_modifier_level_code     VARCHAR2 (30);
      l_new_adjustment_amount   NUMBER;
      l_line_category_code      VARCHAR2(30);
      l_range_break             NUMBER;
      l_operation               VARCHAR2(30);
      l_product_id              NUMBER;
      l_util_rec                ozf_fund_utilized_pvt.utilization_rec_type;
      l_act_budgets_rec         ozf_actbudgets_pvt.act_budgets_rec_type;
      l_gl_posted_flag          VARCHAR2 (1);
      l_utilization_id          NUMBER;
      l_gl_date                 DATE;
      l_object_version_number   NUMBER;
      l_plan_type               VARCHAR2(30);
      l_utilization_type        VARCHAR2(30);
      l_amount                  NUMBER;
      l_fund_id                 NUMBER;
      l_acctd_amount            NUMBER;
      l_order_curr              VARCHAR2(30);
      l_offer_curr              VARCHAR2(30);
      l_count                   NUMBER            := 0;
      l_adj_amt_tbl             ozf_adjusted_amt_tbl_type;
      l_plan_id                 NUMBER;
      l_plan_amount             NUMBER;
      l_rate                    NUMBER;
      l_conv_earned_amount      NUMBER;
      l_conv_adjustment_amount  NUMBER;
      l_util_exists             NUMBER;
      l_new_line_id             NUMBER;

      l_order_org_id            NUMBER;
      l_exchange_rate_type      VARCHAR2(30) := FND_API.G_MISS_CHAR;
      l_offer_transaction_curr  VARCHAR2(30);

      CURSOR c_line_info (p_line_id IN NUMBER) IS
         SELECT line.inventory_item_id,
                line.ordered_quantity,
                line.cancelled_quantity,
                line.line_category_code,
                header.transactional_curr_code,
                header.org_id
         FROM oe_order_lines_all line, oe_order_headers_all header
         WHERE line_id = p_line_id
           AND line.header_id = header.header_id;

      CURSOR c_list_line_info (p_list_line_id IN NUMBER) IS
         SELECT estim_gl_value
         FROM qp_list_lines
         WHERE list_line_id = p_list_line_id;

      CURSOR c_old_adjustment_amount (p_price_adjustment_id IN NUMBER) IS
         SELECT SUM (plan_curr_amount)
         FROM ozf_funds_utilized_all_b
         WHERE price_adjustment_id = p_price_adjustment_id
         AND object_type = 'ORDER';

      CURSOR c_order_count (p_header_id IN NUMBER) IS
         SELECT SUM (ordered_quantity - NVL (cancelled_quantity, 0))
         FROM oe_order_lines_all
         WHERE header_id = p_header_id;

         -- Added adjusted_amount for bug fix 4173825
      CURSOR c_mod_level (p_price_ad_id IN NUMBER) IS
         SELECT modifier_level_code,range_break_quantity, adjusted_amount
         FROM oe_price_adjustments
         WHERE price_adjustment_id = p_price_ad_id;

      -- Added component_type,utilization_type for bug fix 5523042
      CURSOR c_old_adjustment_amt (p_price_adjustment_id IN NUMBER) IS
         SELECT  NVL (amount, 0) amount,
                  fund_id,
                  currency_code,
                  NVL (plan_curr_amount, 0) plan_curr_amount,
                  gl_posted_flag, product_id,component_type,utilization_type,
                  NVL (fund_request_amount, 0) fund_request_amount,plan_currency_code,fund_request_currency_code --nirprasa, ER 8399134, multi-currency enhancement
         FROM ozf_funds_utilized_all_b
         WHERE price_adjustment_id = p_price_adjustment_id
         AND object_type = 'ORDER';
         --GROUP BY fund_id, currency_code, price_adjustment_id, gl_posted_flag, product_id ;

      --nirprasa, ER 8399134 query fund_request_amount instead of plan_curr_amount
      CURSOR c_get_util_rec(p_utilization_id IN NUMBER) IS
       SELECT  object_version_number,
               plan_type, utilization_type,
               amount,
               fund_id,
               acctd_amount,
               plan_id,
               fund_request_amount
       FROM   ozf_funds_utilized_all_b
       WHERE  utilization_id = p_utilization_id;

      CURSOR c_tm_offer (p_list_header_id IN NUMBER) IS
         --SELECT nvl(transaction_currency_code,fund_request_curr_code) transaction_currency_code
         SELECT nvl(transaction_currency_code,fund_request_curr_code) offer_currency_code,
                transaction_currency_code
         FROM ozf_offers
         WHERE qp_list_header_id = p_list_header_id;

      CURSOR c_get_util (p_list_header_id IN NUMBER, p_header_id IN NUMBER, p_line_id IN NUMBER) IS
         SELECT 1
         FROM ozf_funds_utilized_all_b
         WHERE plan_type = 'OFFR'
         AND plan_id = p_list_header_id
         AND object_type = 'ORDER'
         AND object_id = p_header_id
         AND order_line_id = p_line_id
         AND utilization_type = 'ADJUSTMENT'
         AND price_adjustment_id IS NULL;

      CURSOR c_split_line(p_line_id IN NUMBER) IS
        SELECT line_id
        FROM oe_order_lines_all
        WHERE split_from_line_id IS NOT NULL
        AND line_id = p_line_id
        AND split_by = 'SYSTEM';

      -- added for bug 7030415 get conversion type
      CURSOR c_get_conversion_type( p_org_id   IN   NUMBER) IS
         SELECT exchange_rate_type
         FROM   ozf_sys_parameters_all
         WHERE  org_id = p_org_id;

      BEGIN
         SAVEPOINT adjust_accrual;
         -- Standard call to check for call compatibility.
         IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
         -- Initialize message list IF p_init_msg_list is set to TRUE.
         IF fnd_api.to_boolean (p_init_msg_list) THEN
            fnd_msg_pub.initialize;
         END IF;
         --  Initialize API return status to success
         x_return_status            := fnd_api.g_ret_sts_success;

         <<new_line_tbl_loop>>

         IF g_debug_flag = 'Y' THEN
            ozf_utility_pvt.write_conc_log ('  D: Inside New Line Table Loop');
         END IF;

         l_adj_amt_tbl.DELETE;

         FOR i IN NVL (p_line_adj_tbl.FIRST, 1) .. NVL (p_line_adj_tbl.LAST, 0)
         LOOP
            x_return_status            := fnd_api.g_ret_sts_success;
            SAVEPOINT line_adjustment;

            IF g_debug_flag = 'Y' THEN
              ozf_utility_pvt.write_conc_log ('    /++++++++ ADJUSTMENT DEBUG MESSAGE START +++++++++/'          );
              ozf_utility_pvt.write_conc_log ('    D: Begin Processing For Price Adjustment Id # '|| p_line_adj_tbl(i).price_adjustment_id          );
            END IF;

            IF  p_line_adj_tbl (i).list_line_type_code IN
                                              ('CIE', 'DIS', 'IUE', 'OID',  'PLL', 'PMR', 'TSN','PBH')
                --AND p_line_adj_tbl (i).applied_flag = 'Y'
                AND p_line_adj_tbl (i).applied_flag IN ('Y', 'N') --bug 8253115
           THEN

              OPEN c_tm_offer ( p_line_adj_tbl (i).list_header_id);
              FETCH c_tm_offer INTO l_offer_curr,l_offer_transaction_curr;

            -- check if it is a TM Offers
              IF c_tm_offer%NOTFOUND THEN
                 CLOSE c_tm_offer;
                 IF g_debug_flag = 'Y' THEN
                    ozf_utility_pvt.write_conc_log('D  not TM offer: offer id:  ' ||  p_line_adj_tbl(i).list_header_id);
                 END IF;
                 GOTO l_endoflineadjloop;
              ELSE
                 CLOSE c_tm_offer;
              END IF;

              l_line_quantity            := 0;
              l_old_adjusted_amount      := 0;
              l_cancelled_quantity       := 0;
              l_earned_amount            := 0;
              l_new_adjustment_amount    := 0; --nirprasa, fix for bug 8435499.

              IF g_debug_flag = 'Y' THEN
                 ozf_utility_pvt.write_conc_log ('    D: Operation '|| p_line_adj_tbl (i).operation ||
                 ' Order header id  ' || p_line_adj_tbl (i).header_id || ' Line id  ' || p_line_adj_tbl (i).line_id  ||
                  ' applied flag  ' || p_line_adj_tbl (i).applied_flag);
              END IF;

              OPEN c_line_info (p_line_adj_tbl (i).line_id);
              FETCH c_line_info INTO l_product_id,
                                     l_line_quantity,
                                     l_cancelled_quantity,
                                     l_line_category_code,
                                     l_order_curr,
                                     l_order_org_id;
              CLOSE c_line_info;

               --Added for bug 7030415
              OPEN c_get_conversion_type(l_order_org_id);
              FETCH c_get_conversion_type INTO l_exchange_rate_type;
              CLOSE c_get_conversion_type;

              --bug 8253115 - Negative accruals are not created for manually deleted modifiers.
              --When modifiers are deleted manually from booked orders, we get UPDATE message with applied_flag = N
              --instead of DELETE message with applied_flag = Y, so for this record changed the operation to DELETE
              IF p_exception_queue = fnd_api.g_true AND p_line_adj_tbl (i).operation = 'CREATE' THEN
                 l_operation := 'UPDATE' ;
              ELSIF p_line_adj_tbl (i).operation = 'UPDATE' AND p_line_adj_tbl (i).applied_flag = 'N' THEN
                 l_operation := 'DELETE';
              ELSIF p_line_adj_tbl (i).applied_flag = 'Y' THEN
                 l_operation := p_line_adj_tbl (i).operation;
              ELSE
                 GOTO l_endoflineadjloop;
              END IF;

              IF l_operation <> 'DELETE' THEN
                 OPEN c_mod_level (p_line_adj_tbl (i).price_adjustment_id);
                 FETCH c_mod_level INTO l_modifier_level_code,l_range_break, l_new_adjustment_amount;
                 CLOSE c_mod_level;

                 IF g_debug_flag = 'Y' THEN
                    ozf_utility_pvt.write_conc_log ('    D: Modifier level code '|| l_modifier_level_code);
                 END IF;
              END IF;

              IF g_debug_flag = 'Y' THEN
                 ozf_utility_pvt.write_conc_log (
                  '    D: Line quantity '|| l_line_quantity || ' Cancelled quantity ' || l_cancelled_quantity ||
                  '   line_adj_tbl.adjusted_amount=' || l_new_adjustment_amount
                 );
              END IF;

              IF l_modifier_level_code = 'ORDER' THEN
                  -- for the time being this is the workaround cause there is no way to find out how much adjustment for total
                  -- has happened due to this order level offer
                 l_cancelled_quantity       := 0;
                 OPEN c_order_count (p_line_adj_tbl (i).header_id);
                 FETCH c_order_count INTO l_line_quantity;
                 CLOSE c_order_count;
              END IF;

              --kdass 24-FEB-07 bug 5485334 - do not create utilization when offer gets applied on
              --order booked before offer start date on manual re-pricing order
              OPEN c_get_util (p_line_adj_tbl(i).list_header_id, p_line_adj_tbl(i).header_id, p_line_adj_tbl(i).line_id);
              FETCH c_get_util INTO l_util_exists;
              CLOSE c_get_util;

              IF NVL(l_util_exists,0) = 1 THEN
                 IF g_debug_flag = 'Y' THEN
                    ozf_utility_pvt.write_conc_log('Manual re-pricing of order created before offer start date. No utilization.');
                 END IF;
                 GOTO l_endoflineadjloop;
              END IF;

              IF l_operation = 'CREATE' THEN
                 IF g_debug_flag = 'Y' THEN
                    ozf_utility_pvt.write_conc_log ('operation create');
                 END IF;

                 l_earned_amount := (-(NVL(l_new_adjustment_amount, 0))) * l_line_quantity;

                 IF g_debug_flag = 'Y' THEN
                    ozf_utility_pvt.write_conc_log('    D: adjust_accrual()_ create  earned amount = ' || l_earned_amount);
                 END IF;

                 IF l_line_category_code = 'RETURN' THEN
                    IF g_debug_flag = 'Y' THEN
                       ozf_utility_pvt.write_conc_log ( '   LINE IS RETURN  ');
                    END IF;
                    l_earned_amount := -l_earned_amount;
                 END IF;

                  -- if it is a TSN then get the gl value of the upgrade
                 IF p_line_adj_tbl (i).list_line_type_code = 'TSN' THEN
                    OPEN c_list_line_info (p_line_adj_tbl (i).list_line_id);
                    FETCH c_list_line_info INTO l_earned_amount;
                    CLOSE c_list_line_info;
                     -- Multiply with the quantity ordered
                     -- 5/2/2002 mpande modified ordered qty is the line quantity
                    l_earned_amount            :=    l_earned_amount * (l_line_quantity);
                 END IF;

                  --nirprasa, ER 8399134 multi-currency enhancement
                  IF l_offer_transaction_curr IS NOT NULL AND l_offer_transaction_curr <> l_order_curr THEN


                     IF g_debug_flag = 'Y' THEN
                       ozf_utility_pvt.write_conc_log('l_order_curr: ' || l_order_curr);
                       ozf_utility_pvt.write_conc_log('l_offer_curr: ' || l_offer_curr);
                       ozf_utility_pvt.write_conc_log('l_earned_amount: ' || l_earned_amount);
                       ozf_utility_pvt.write_conc_log('l_order_org_id: ' || l_order_org_id);
                       ozf_utility_pvt.write_conc_log('**************************START****************************');
                       ozf_utility_pvt.write_conc_log(l_api_name||' From Amount l_earned_amount: '||l_earned_amount );
                       ozf_utility_pvt.write_conc_log(l_api_name||' From Curr l_order_curr: '||l_order_curr );
                       ozf_utility_pvt.write_conc_log(l_api_name||' l_exchange_rate_type: '|| l_exchange_rate_type);
                      END IF;

                     ozf_utility_pvt.convert_currency (x_return_status => x_return_status
                                                      ,p_from_currency => l_order_curr
                                                      ,p_to_currency   => l_offer_curr
                                                      ,p_conv_type     => l_exchange_rate_type -- Added for bug 7030415
                                                      ,p_from_amount   => l_earned_amount
                                                      ,x_to_amount     => l_conv_earned_amount
                                                      ,x_rate          => l_rate
                                                      );

                     IF g_debug_flag = 'Y' THEN
                        ozf_utility_pvt.write_conc_log(l_api_name||' To Curr l_offer_curr: '|| l_offer_curr );
                        ozf_utility_pvt.write_conc_log(l_api_name||' Converted Amount l_conv_earned_amount: '|| l_conv_earned_amount);
                        ozf_utility_pvt.write_conc_log('Earned amount is converted from order curr to offer curr');
                        ozf_utility_pvt.write_conc_log('***************************END******************************');
                        ozf_utility_pvt.write_conc_log('x_return_status: ' || x_return_status);
                     END IF;

                     IF x_return_status <> fnd_api.g_ret_sts_success THEN
                        GOTO l_endoflineadjloop;
                     END IF;

                     l_earned_amount := l_conv_earned_amount;

                     IF g_debug_flag = 'Y' THEN
                       ozf_utility_pvt.write_conc_log ('earned amt after currency conversion: ' || l_earned_amount);
                     END IF;
                  END IF;

              ELSIF l_operation = 'UPDATE' THEN
                 IF g_debug_flag = 'Y' THEN
                    ozf_utility_pvt.write_conc_log ('operation UPDATE');
                 END IF;
                  -- if the old and the new is the same we donot need to update it \
                 OPEN c_old_adjustment_amount (p_line_adj_tbl (i).price_adjustment_id);
                 FETCH c_old_adjustment_amount INTO l_old_adjusted_amount; -- in order curr
                 CLOSE c_old_adjustment_amount;

                 IF g_debug_flag = 'Y' THEN
                    ozf_utility_pvt.write_conc_log (
                     '    D: Old adjsutment amount '
                     || l_old_adjusted_amount
                     || '  Old price adjustment id '
                     || p_line_adj_tbl (i).price_adjustment_id
                     );
                 END IF;
                  -- if all the money coming in has been adjusted then set it to 0
                  --5/2/2002 the ordered quantity is the actual ordered quantity and not the difference
                 IF l_line_category_code = 'RETURN' THEN
                    IF g_debug_flag = 'Y' THEN
                       ozf_utility_pvt.write_conc_log ( '   LINE IS RETURN  ');
                    END IF;
                    l_line_quantity := -l_line_quantity; -- fred should be cancelled qutity.
                 END IF;

                 l_new_adjustment_amount    :=   (l_line_quantity )
                                             * (-(NVL (l_new_adjustment_amount, 0)));

                 IF g_debug_flag = 'Y' THEN
                    ozf_utility_pvt.write_conc_log('    D: adjust_accrual() l_new_adjustment_amount=' || l_new_adjustment_amount );
                 END IF;

                  --nirprasa, ER 8399134, multi-currency enhancement
                  IF l_offer_curr <> l_order_curr AND l_offer_transaction_curr IS NOT NULL THEN

                     IF g_debug_flag = 'Y' THEN
                     ozf_utility_pvt.write_conc_log('l_order_curr: ' || l_order_curr);
                     ozf_utility_pvt.write_conc_log('l_offer_curr: ' || l_offer_curr);
                     ozf_utility_pvt.write_conc_log('l_new_adjustment_amount: ' || l_new_adjustment_amount);
                     END IF;

                     ozf_utility_pvt.convert_currency (x_return_status => x_return_status
                                                      ,p_from_currency => l_order_curr
                                                      ,p_to_currency   => l_offer_curr
                                                      ,p_conv_type     => l_exchange_rate_type -- Added for bug 7030415
                                                      ,p_from_amount   => l_new_adjustment_amount
                                                      ,x_to_amount     => l_conv_adjustment_amount
                                                      ,x_rate          => l_rate
                                                      );

                     ozf_utility_pvt.write_conc_log('x_return_status: ' || x_return_status);

                     IF x_return_status <> fnd_api.g_ret_sts_success THEN
                        GOTO l_endoflineadjloop;
                     END IF;

                     l_new_adjustment_amount := l_conv_adjustment_amount;

                     IF g_debug_flag = 'Y' THEN
                        ozf_utility_pvt.write_conc_log ('new adjusted amt after currency conversion: ' || l_new_adjustment_amount);
                     END IF;
                  END IF;

                 l_earned_amount            :=  l_new_adjustment_amount - NVL(l_old_adjusted_amount,0);

                 IF g_debug_flag = 'Y' THEN
                    ozf_utility_pvt.write_conc_log ('    D: Update earned amount '|| l_earned_amount);
                 END IF;

                -- Changes by rimehrot (12/8/2004) for bug 3697213
               -- When order is re-priced and offer is removed from the order, a message with operation
               -- 'DELETE' is sent and the original accrual should be reverted in this case.
              ELSIF l_operation = 'DELETE' AND p_line_adj_tbl (i).price_adjustment_id IS NOT NULL THEN
                 IF g_debug_flag = 'Y' THEN
                   ozf_utility_pvt.write_conc_log ('operation DELETE');
                 END IF;

                 FOR old_adjustment_rec IN
                   c_old_adjustment_amt (p_line_adj_tbl (i).price_adjustment_id)
                 LOOP
                    l_adj_amount := -old_adjustment_rec.amount;
                    IF old_adjustment_rec.amount = 0 THEN
                       GOTO l_endofloop;
                    END IF;

                    l_util_rec :=NULL;
                    l_act_budgets_rec :=NULL;
                    l_util_rec.object_type := 'ORDER';
                    l_util_rec.object_id   := p_line_adj_tbl (i).header_id;
                    l_util_rec.product_id := old_adjustment_rec.product_id;
                    l_util_rec.price_adjustment_id := p_line_adj_tbl (i).price_adjustment_id;
                    l_act_budgets_rec.budget_source_type := 'OFFR';
                    l_act_budgets_rec.budget_source_id := p_line_adj_tbl (i).list_header_id;
                    l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
                    l_act_budgets_rec.act_budget_used_by_id := p_line_adj_tbl (i).list_header_id;
                    l_act_budgets_rec.parent_src_apprvd_amt := l_adj_amount;
                    l_act_budgets_rec.parent_src_curr := old_adjustment_rec.currency_code;
                    l_act_budgets_rec.parent_source_id := old_adjustment_rec.fund_id;
                    l_act_budgets_rec.request_amount := -old_adjustment_rec.plan_curr_amount;
                    l_act_budgets_rec.request_currency := l_order_curr;
                    l_util_rec.amount := l_adj_amount ;
                    l_util_rec.plan_curr_amount :=  l_act_budgets_rec.request_amount;
                    l_util_rec.component_id := p_line_adj_tbl (i).list_header_id;
                    l_util_rec.currency_code :=old_adjustment_rec.currency_code;
                    l_util_rec.fund_id :=old_adjustment_rec.fund_id;
                    -- kpatro 11/09/2006 fix for bug 5523042
                    l_util_rec.utilization_type := old_adjustment_rec.utilization_type;
                    l_util_rec.component_type := old_adjustment_rec.component_type;

                    --nirprasa, ER 8399134 multi-currency enhancement
                    l_util_rec.plan_currency_code := old_adjustment_rec.plan_currency_code;
                    l_util_rec.fund_request_currency_code := old_adjustment_rec.fund_request_currency_code;
                    l_util_rec.fund_request_amount := -old_adjustment_rec.fund_request_amount;

                  -- yzhao: 06/23/2004 if old record needs to post, set this gl flag to N, otherwise, no posting
                    IF old_adjustment_rec.gl_posted_flag IN (G_GL_FLAG_NULL, G_GL_FLAG_NOLIAB) THEN
                       l_util_rec.gl_posted_flag := old_adjustment_rec.gl_posted_flag;  -- 'N';
                    ELSE
                       l_util_rec.gl_posted_flag := G_GL_FLAG_NO;  -- 'N';
                    END IF;
                  -- rimehrot: initially put the gl_posted_flag as N. If post_accrual_to_gl call reqd later,
                  -- will get changed accordingly depending on the value obtained after posting.

                    create_fund_utilization (
                       p_act_util_rec=> l_util_rec,
                     p_act_budgets_rec=> l_act_budgets_rec,
                     x_utilization_id => l_utilization_id,
                     x_return_status=> l_return_status,
                     x_msg_count=> x_msg_count,
                     x_msg_data=> x_msg_data
                     );

                    IF g_debug_flag = 'Y' THEN
                       ozf_utility_pvt.write_conc_log (
                        'create utlization from cancelled order returns '|| l_return_status
                       );
                    END IF;

                    IF l_return_status <> fnd_api.g_ret_sts_success THEN
                       GOTO l_endoflineadjloop;
                    END IF;

                  -- If gl_posted_flag of original accrual has been posted, call post_accrual_to_gl
                  -- to post new accrual

                    IF old_adjustment_rec.gl_posted_flag IN (G_GL_FLAG_YES, G_GL_FLAG_FAIL) THEN
                    -- get details of utilization created above.
                    -- fred could be removed. direct to use from above cursor.
                       OPEN c_get_util_rec (l_utilization_id);
                       FETCH c_get_util_rec INTO l_object_version_number, l_plan_type, l_utilization_type, l_amount,
                          l_fund_id, l_acctd_amount, l_plan_id, l_plan_amount;
                       CLOSE c_get_util_rec;

                       post_accrual_to_gl( p_util_utilization_id            => l_utilization_id
                                     , p_util_object_version_number      => l_object_version_number
                                     , p_util_amount                     => l_amount
                                     , p_util_plan_type                  => l_plan_type
                                     , p_util_plan_id                    => l_plan_id
                                     , p_util_plan_amount                => l_plan_amount
                                     , p_util_utilization_type           => l_utilization_type
                                     , p_util_fund_id                    => l_fund_id
                                     , p_util_acctd_amount               => l_acctd_amount
                                     , x_gl_posted_flag                  => l_gl_posted_flag
                                     , x_return_status                   => l_return_status
                                     , x_msg_count                       => x_msg_count
                                     , x_msg_data                        => x_msg_data
                                     );

                   -- do not raise exception for gl posting error. Just mark it as failed and deal with it later
                       IF g_debug_flag = 'Y' THEN
                          ozf_utility_pvt.write_conc_log('    D: adjust_changed_order() processing price adjustment id' || p_line_adj_tbl (i).line_id
                          || '  post_accrual_to_gl(util_id=' || l_utilization_id ||
                           ' gl_posted_flag' || l_gl_posted_flag || ') returns ' || l_return_status);
                       END IF;
                    END IF; -- end of gl_posted_flag in (Y, F)

                    <<l_endofloop>>
                    NULL;
                 END LOOP old_adjustment_rec;
               END IF; -- end if for mode

               --6373391
               IF g_debug_flag = 'Y' THEN
               ozf_utility_pvt.write_conc_log('NP line_id '||p_line_adj_tbl (i).line_id);
               END IF;

               OPEN c_split_line(p_line_adj_tbl (i).line_id);
               FETCH c_split_line INTO l_new_line_id;
               CLOSE c_split_line;

               IF g_debug_flag = 'Y' THEN
               ozf_utility_pvt.write_conc_log('NP  l_new_line_id '||l_new_line_id);
               END IF;

               -- OM sometimes is not sending create message for new split line . So handle it in TM.
               -- and create accrual so that we get a rec in utilization table for split line

               IF  NVL(l_earned_amount,0) = 0 AND p_line_adj_tbl (i).operation <> 'CREATE'
               AND NVL(l_new_line_id,0) = 0 THEN
                  IF g_debug_flag = 'Y' THEN
                     ozf_utility_pvt.write_conc_log('    D: adjust_accrual()  earned amount = 0. No adjustment');
                  END IF;
                  GOTO l_endoflineadjloop;
               END IF;


               ozf_utility_pvt.write_conc_log('NP LG P1 creating adjustment for '||l_new_line_id);

               IF g_debug_flag = 'Y' THEN
                  ozf_utility_pvt.write_conc_log(' creating adjustment for '||l_new_line_id);
                  ozf_utility_pvt.write_conc_log('    D: adjust_accrual()  earned amount = ' || l_earned_amount);
               END IF;

               l_count := l_count + 1;
               l_adj_amt_tbl (l_count).order_header_id := p_line_adj_tbl (i).header_id;
               l_adj_amt_tbl (l_count).order_line_id := p_line_adj_tbl (i).line_id;
               l_adj_amt_tbl (l_count).price_adjustment_id := p_line_adj_tbl (i).price_adjustment_id;
               l_adj_amt_tbl (l_count).qp_list_header_id:= p_line_adj_tbl (i).list_header_id;
               l_adj_amt_tbl (l_count).product_id := l_product_id;
               --l_adj_amt_tbl (l_count).earned_amount := ozf_utility_pvt.currround (l_earned_amount, l_order_curr);
               l_adj_amt_tbl (l_count).earned_amount := l_earned_amount;
               l_adj_amt_tbl (l_count).offer_currency:= l_offer_curr;
               --nirprasa, ER 8399134 multi-currency enhancement, added parameter order currency.
               --l_adj_amt_tbl, will be passed on to post_accrual_to_budget
               l_adj_amt_tbl (l_count).order_currency:= l_order_curr;
            END IF;
            <<l_endoflineadjloop>>

            IF x_return_status <> fnd_api.g_ret_sts_success THEN
               IF g_debug_flag = 'Y' THEN
                  ozf_utility_pvt.write_conc_log (
                    '   /****** Adjustment Failure *******/ Offer Id: "'|| p_line_adj_tbl(i).list_header_id ||'"' || 'Price Adjustment Id'||p_line_adj_tbl (i).price_adjustment_id);
               END IF;
                  -- Initialize the Message list for Next Processing
               ROLLBACK TO line_adjustment;
               x_return_status := fnd_api.g_ret_sts_error ;
               EXIT;
            ELSE
               IF g_debug_flag = 'Y' THEN
                  ozf_utility_pvt.write_conc_log(
                    '   /****** Adjustment Success *******/ Offer Id: "'|| p_line_adj_tbl(i).list_header_id ||
                    '"' || ' Price Adjustment Id "'||p_line_adj_tbl (i).price_Adjustment_id ||'"' );
               END IF;
            END IF;

         END LOOP new_line_tbl_loop;

         IF l_adj_amt_tbl.count > 0 THEN
            post_accrual_to_budget (
                   p_adj_amt_tbl         => l_adj_amt_tbl
                 , x_return_status       => l_return_status
                 , x_msg_count           => x_msg_count
                 , x_msg_data            => x_msg_data
            );
         END IF;

         IF g_debug_flag = 'Y' THEN
            ozf_utility_pvt.write_conc_log('    D: post_accrual_to_budget returns ' || l_return_status);
         END IF;
         x_return_status  := l_return_status;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count,
            p_data=> x_msg_data,
            p_encoded=> fnd_api.g_false
         );

   EXCEPTION
      WHEN OTHERS THEN
        --ROLLBACK TO adjust_accrual;
        x_return_status            := fnd_api.g_ret_sts_unexp_error;
        ozf_utility_pvt.write_conc_log(' /**************UNEXPECTED EXCEPTION in adjust_accrual *************/');
        IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
           fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
        END IF;
        fnd_msg_pub.count_and_get (
            p_count=> x_msg_count,
            p_data=> x_msg_data,
            p_encoded=> fnd_api.g_false
         );
   END adjust_accrual;
   ------------------------------------------------------------------------------
-- Procedure Name
--   recalculate_earnings
-- Purpose
--   This procedure re-converts the converted amounts in utilization table
--   gl_date will be used as exchange_date.
-- History
-- 04/29/2009 nirprasa Created
------------------------------------------------------------------------------

  PROCEDURE recalculate_earnings (
      p_exchange_rate_date          IN            DATE,
      p_exchange_rate_type          IN            VARCHAR2,
      p_util_org_id                 IN            NUMBER,
      p_currency_code               IN            VARCHAR2,
      p_plan_currency_code          IN            VARCHAR2,
      p_fund_req_currency_code      IN            VARCHAR2,
      p_amount                      IN            NUMBER,
      p_plan_curr_amount            IN            NUMBER,
      p_plan_curr_amount_rem        IN            NUMBER,
      p_univ_curr_amount            IN            NUMBER,
      p_acctd_amount                IN            NUMBER,
      p_fund_req_amount             IN            NUMBER,
      p_util_plan_id                IN            NUMBER,
      p_util_plan_type              IN            VARCHAR2,
      p_util_fund_id                IN            NUMBER,
      p_util_utilization_id         IN            NUMBER,
      p_util_utilization_type       IN            VARCHAR2,
      x_return_status               OUT NOCOPY    VARCHAR2,
      x_msg_count                   OUT NOCOPY    VARCHAR2,
      x_msg_data                    OUT NOCOPY    VARCHAR2);

------------------------------------------------------------------------------
-- Procedure Name
--   adjust_changed_order
-- Purpose
--   This procedure will calculate and update the accrual info for cancelled order
--     and post to gl for shipped order.
--
--  created      mpande     02/15/2002
--  modified     yzhao      03/19/2003   added posting to GL for shipped order lines
------------------------------------------------------------------------------
   PROCEDURE adjust_changed_order (
      p_api_version        IN       NUMBER,
      p_init_msg_list      IN       VARCHAR2 := fnd_api.g_false,
      p_commit             IN       VARCHAR2 := fnd_api.g_false,
      p_validation_level   IN       NUMBER := fnd_api.g_valid_level_full,
      x_return_status      OUT NOCOPY      VARCHAR2,
      x_msg_count          OUT NOCOPY      NUMBER,
      x_msg_data           OUT NOCOPY      VARCHAR2,
      p_header_rec         IN       oe_order_pub.header_rec_type,
      p_old_header_rec     IN       oe_order_pub.header_rec_type,
      p_line_tbl           IN       oe_order_pub.line_tbl_type,
      p_old_line_tbl       IN       oe_order_pub.line_tbl_type
   ) IS
      l_return_status           VARCHAR2 (1)                          ;
      l_api_name       CONSTANT VARCHAR2 (30)                           := 'Adjust_Changed_order';
      l_api_version    CONSTANT NUMBER                                  := 1.0;
      --  local variables
      l_qp_list_hdr_id          NUMBER;
      l_earned_amount           NUMBER;
      l_old_earned_amount       NUMBER;
      l_header_id               NUMBER; -- order or invoice id
      l_line_id                 NUMBER; -- order or invoice id
      l_util_rec                ozf_fund_utilized_pvt.utilization_rec_type;
      l_empty_util_rec          ozf_fund_utilized_pvt.utilization_rec_type;
      l_util_id                 NUMBER;
      l_util_curr               VARCHAR2 (30);
      l_adj_amount              NUMBER;
      l_converted_adj_amount    NUMBER;
      l_order_status            VARCHAR2 (30);
      l_order_booked_flag       VARCHAR2 (1);
      l_line_quantity           NUMBER;
      l_old_adjusted_amount     NUMBER                                  := 0;
      l_order_curr              VARCHAR2 (150);
      l_cancelled_quantity      NUMBER;
      l_modifier_level_code     VARCHAR2 (30);
      l_line_status             VARCHAR2 (30);
      l_new_adjustment_amount   NUMBER;
      l_act_budgets_rec         ozf_actbudgets_pvt.act_budgets_rec_type;
      l_empty_act_budgets_rec   ozf_actbudgets_pvt.act_budgets_rec_type;
      l_order_number            NUMBER;
      l_gl_posted_flag          VARCHAR2 (1);
      l_orig_adj_amount         NUMBER;
      l_rate                    NUMBER;
      l_total                   NUMBER;
      l_gl_date                 DATE;
      l_new_line_id             NUMBER;
      l_new_adj_id              NUMBER;
      l_sales_transaction_rec   OZF_SALES_TRANSACTIONS_PVT.SALES_TRANSACTION_REC_TYPE;
      l_sales_transaction_id    NUMBER;
      l_org_id                  NUMBER;
      l_sales_trans             NUMBER;
      l_utilization_id          NUMBER;

      l_utilIdTbl               utilIdTbl;
      l_objVerTbl               objVerTbl;
      l_amountTbl               amountTbl;
      l_planTypeTbl             planTypeTbl;
      l_planIdTbl               planIdTbl;
      l_planAmtTbl              planAmtTbl;
      l_utilTypeTbl             utilTypeTbl;
      l_fundIdTbl               fundIdTbl;
      l_acctAmtTbl              acctAmtTbl;
      l_orgIdTbl                orgIdTbl;

      l_excDateTbl              excDateTbl;
      l_excTypeTbl              excTypeTbl;
      l_currCodeTbl             currCodeTbl;
      l_planCurrCodeTbl         planCurrCodeTbl;
      l_fundReqCurrCodeTbl      fundReqCurrCodeTbl;
      l_planCurrAmtTbl          planCurrAmtTbl;
      l_planCurrAmtRemTbl       planCurrAmtRemTbl;
      l_univCurrAmtTbl          univCurrAmtTbl;
      CURSOR party_id_csr(p_cust_account_id NUMBER) IS
         SELECT party_id
         FROM hz_cust_accounts
         WHERE cust_account_id = p_cust_account_id;

      CURSOR party_site_id_csr(p_account_site_id NUMBER) IS
         SELECT a.party_site_id
         FROM hz_cust_acct_sites_all a,
              hz_cust_site_uses_all b
         WHERE b.site_use_id = p_account_site_id
         AND   b.cust_acct_site_id = a.cust_acct_site_id;

      CURSOR sales_transation_csr(p_line_id NUMBER) IS
         SELECT 1 FROM DUAL WHERE EXISTS
         ( SELECT 1
           FROM ozf_sales_transactions_all trx
           WHERE trx.line_id = p_line_id
           AND source_code = 'OM');

      CURSOR c_order_info (p_header_id IN NUMBER) IS
         SELECT flow_status_code,
                booked_flag,
                transactional_curr_code,
                order_number,
                org_id
         FROM oe_order_headers_all
         WHERE header_id = p_header_id;

      CURSOR c_all_price_adjustments (p_line_id IN NUMBER) IS
         SELECT price_adjustment_id,
                list_header_id,
                adjusted_amount,          -- yzhao: 03/21/2003 added following 2 for shipped order
                header_id
         FROM oe_price_adjustments
         WHERE line_id = p_line_id;

      -- used for cancelled order and partial ship.
      CURSOR c_old_adjustment_amount (p_price_adjustment_id IN NUMBER) IS
         SELECT sum(plan_curr_amount) plan_curr_amount, sum(amount) amount,
                sum(fund_request_amount) fund_request_amount, ----nirprasa, ER 8399134
                   fund_id,currency_code,
                   'N' gl_posted_flag,min(plan_id) plan_id,
                   utilization_type,adjustment_type,
                   price_adjustment_id,orig_utilization_id,
                   exchange_rate_type, --nirprasa, added for LGE enhancement
                   plan_currency_code, ----nirprasa, ER 8399134
                   fund_request_currency_code ----nirprasa, ER 8399134
        FROM ozf_funds_utilized_all_b
        WHERE price_adjustment_id = p_price_adjustment_id
        AND object_type = 'ORDER'
        AND NVL(gl_posted_flag,'N') <> 'Y'
        GROUP BY fund_id,
                 currency_code,
                 gl_posted_flag,
                 utilization_type,
                 adjustment_type,
                 price_adjustment_id,
                 orig_utilization_id,
                 exchange_rate_type,
                 plan_currency_code,
                 fund_request_currency_code;

      -- yzhao: 03/21/2003 get old adjustment amount per price_adjustment_id, copy from adjust_accrual
      CURSOR c_old_adjustment_total_amount (p_price_adjustment_id IN NUMBER) IS
         SELECT SUM (plan_curr_amount)  -- change to plan_curr_amount from acct_amount by feliu
         FROM ozf_funds_utilized_all_b
         WHERE price_adjustment_id = p_price_adjustment_id
         AND object_type = 'ORDER'
         AND utilization_type NOT IN ('ADJUSTMENT', 'LEAD_ADJUSTMENT'); -- remove adjustment amount on 08/03/04 by feliu

     -- yzhao: 03/21/2003 get shipped/invoiced order's accraul record, post to GL
     -- changed for bug 6140826
     --nirprasa, ER 8399134 query fund_request_amount
     CURSOR c_get_accrual_rec(p_line_id IN NUMBER) IS
        SELECT utilization_id, object_version_number, plan_type, utilization_type, amount
             , fund_id, acctd_amount, fund_request_amount, plan_id,org_id
             , exchange_rate_type, exchange_rate_date
             , currency_code, plan_currency_code, fund_request_currency_code
             , plan_curr_amount, plan_curr_amount_remaining
             , univ_curr_amount
        FROM   ozf_funds_utilized_all_b
        WHERE  price_adjustment_id IN (SELECT price_adjustment_id
                                      FROM   oe_price_adjustments
                                      WHERE  line_id = p_line_id)
        AND    gl_posted_flag = G_GL_FLAG_NO  -- 'N'
        AND object_type = 'ORDER'
       -- 05/11/2004  kdass  fixed bug 3609771 - added UTILIZED to query
        AND    utilization_type in ('ACCRUAL', 'LEAD_ACCRUAL','SALES_ACCRUAL')
        UNION ALL -- added for bug 5485334 kpatro
        select utilization_id, object_version_number, plan_type, utilization_type, amount
             , fund_id, acctd_amount, plan_curr_amount, plan_id,org_id
             , exchange_rate_type, exchange_rate_date
             , currency_code, plan_currency_code, fund_request_currency_code
             , plan_curr_amount, plan_curr_amount_remaining
             , univ_curr_amount
              from  ozf_funds_utilized_all_b
        where object_type = 'ORDER'
        and order_line_id = p_line_id
        AND  gl_posted_flag = G_GL_FLAG_NO
        AND utilization_type IN ('ADJUSTMENT','LEAD_ADJUSTMENT')
           AND (price_adjustment_id IS NULL or (price_adjustment_id =-1 and orig_utilization_id<>-1)); --added for bug 6021635 nirprasa


     CURSOR c_actual_shipment_date(p_line_id IN NUMBER) IS
        SELECT actual_shipment_date
        FROM oe_order_lines_all
        WHERE line_id = p_line_id;

     CURSOR c_invoice_date(p_line_id IN NUMBER, p_order_number IN VARCHAR2) IS
        SELECT  cust.trx_date     -- transaction(invoice) date
        FROM ra_customer_trx_all cust
           , ra_customer_trx_lines_all cust_lines
        WHERE cust.customer_trx_id = cust_lines.customer_trx_id
        AND cust_lines.sales_order = p_order_number -- added condition for partial index for bug fix 3917556
        AND cust_lines.interface_line_attribute6 = TO_CHAR(p_line_id);

     -- add by feliu on 08/03/04, get split line id to use in create postivie adjustment.
     CURSOR c_split_line(p_line_id IN NUMBER) IS
        SELECT line_id
        FROM oe_order_lines_all
        WHERE split_from_line_id = p_line_id
        AND   split_by = 'SYSTEM';

     -- add by feliu on 08/03/04, get price_adjustment_id to use in create postivie adjustment.
     CURSOR c_new_adj_line(p_line_id IN NUMBER, p_header_id IN NUMBER) IS
        SELECT price_adjustment_id
        FROM  oe_price_adjustments
        WHERE line_id = p_line_id
        AND   list_header_id = p_header_id;
     -- add by feliu on 08/03/04, get max utilization id to use in create  adjustment.
     CURSOR c_max_utilized_id(p_price_adj_id IN NUMBER) IS
        SELECT max(utilization_id)
        FROM ozf_funds_utilized_all_b
        WHERE price_adjustment_id = p_price_adj_id
        AND object_type = 'ORDER';

      CURSOR c_orig_order_info (p_line_id IN NUMBER) IS
         SELECT NVL(shipped_quantity,ordered_quantity)
         FROM oe_order_lines_all
         WHERE line_id =p_line_id;

      CURSOR c_orig_adjustment_amount (p_order_line_id IN NUMBER) IS
         SELECT    plan_curr_amount, amount, fund_request_amount, --nirprasa, ER 8399134
                   fund_id,currency_code,
                   gl_posted_flag,plan_id,
                   utilization_type,price_adjustment_id,
                   adjustment_type,orig_utilization_id,
                   plan_currency_code,fund_request_currency_code --nirprasa, ER 8399134
        FROM ozf_funds_utilized_all_b
        WHERE order_line_id = p_order_line_id
        AND adjustment_type_id IN(-4,-5);

      --kdass bug 5953774
      CURSOR c_offer_currency (p_list_header_id IN NUMBER) IS
             SELECT nvl(transaction_currency_code, fund_request_curr_code) offer_currency,
             transaction_currency_code
           FROM ozf_offers
           WHERE qp_list_header_id = p_list_header_id;



        --added for bug
                CURSOR c_old_adj_total_amount (p_order_line_id IN NUMBER) IS
         SELECT SUM (plan_curr_amount)  -- change to plan_curr_amount from acct_amount by feliu
         FROM ozf_funds_utilized_all_b
         WHERE price_adjustment_id = -1
         and order_line_id=p_order_line_id
         AND object_type = 'ORDER'
         AND utilization_type  IN ('ADJUSTMENT', 'LEAD_ADJUSTMENT'); --

           CURSOR c_old_adjustment_details (p_order_line_id IN NUMBER) IS
          SELECT    plan_curr_amount, amount,
                   fund_id,currency_code,
                   gl_posted_flag,plan_id,
                   utilization_type,price_adjustment_id,
                   adjustment_type,orig_utilization_id
         FROM ozf_funds_utilized_all_b
         WHERE price_adjustment_id = -1
          and order_line_id=p_order_line_id
         AND object_type = 'ORDER'
         AND utilization_id=(
        SELECT max(utilization_id)
        FROM ozf_funds_utilized_all_b
        WHERE price_adjustment_id = -1
            and order_line_id=p_order_line_id
        AND object_type = 'ORDER');


         CURSOR  c_split_order_line_info(p_order_line_id IN NUMBER)  IS
        SELECT DECODE(line.line_category_code,'ORDER',line.ordered_quantity,
                                                                            'RETURN', -line.ordered_quantity) ordered_quantity,
             DECODE(line.line_category_code,'ORDER',NVL(line.shipped_quantity,0),
                                                                            'RETURN', line.invoiced_quantity,
                                                                            line.ordered_quantity) shipped_quantity

        FROM oe_order_lines_all line, oe_order_headers_all header
        WHERE line.line_id = p_order_line_id
        AND line.header_id = header.header_id;


         CURSOR c_all_fund_utilizations (p_line_id IN NUMBER) IS
        SELECT price_adjustment_id , plan_id
         FROM ozf_funds_utilized_all_b
         WHERE order_line_id = p_line_id;

         CURSOR c_offer_type (p_offer_id IN NUMBER) IS
         SELECT offer_type
         FROM   ozf_offers
         WHERE  qp_list_header_id = p_offer_id;

          CURSOR c_discount_header(p_discount_line_id IN NUMBER) IS
         SELECT discount_type,volume_type
          FROM ozf_offer_discount_lines
          WHERE offer_discount_line_id = p_discount_line_id
          AND tier_type = 'PBH';

     CURSOR c_get_group(p_order_line_id IN NUMBER,p_list_header_id IN NUMBER) IS
       SELECT group_no,pbh_line_id,include_volume_flag
        FROM ozf_order_group_prod
        WHERE order_line_id = p_order_line_id
        AND qp_list_header_id = p_list_header_id;

     CURSOR c_market_option(p_list_header_id IN NUMBER, p_group_id IN NUMBER) IS
       SELECT opt.retroactive_flag
        FROM ozf_offr_market_options opt
        WHERE opt.GROUP_NUMBER= p_group_id
        AND opt.qp_list_header_id = p_list_header_id;

           CURSOR c_current_discount(p_volume IN NUMBER, p_parent_discount_id IN NUMBER) IS
         SELECT discount
        FROM ozf_offer_discount_lines
        WHERE p_volume > volume_from
             AND p_volume <= volume_to
         AND parent_discount_line_id = p_parent_discount_id;

          CURSOR  c_get_tier_limits (p_parent_discount_id IN NUMBER) IS
       SELECT MIN(volume_from),MAX(volume_to)
       FROM ozf_offer_discount_lines
       WHERE parent_discount_line_id = p_parent_discount_id;

     CURSOR  c_get_max_tier (p_max_volume_to IN NUMBER,p_parent_discount_id IN NUMBER)    IS
        SELECT  discount
        FROM ozf_offer_discount_lines
        WHERE volume_to =p_max_volume_to
        AND parent_discount_line_id = p_parent_discount_id;

   CURSOR c_discount(p_order_line_id  IN NUMBER) IS
       SELECT SUM(adjusted_amount_per_pqty)
       FROM oe_price_adjustments
       WHERE line_id = p_order_line_id
       AND accrual_flag = 'N'
       AND applied_flag = 'Y'
      -- AND list_line_type_code IN ('DIS', 'SUR', 'PBH', 'FREIGHT_CHARGE');
       AND list_line_type_code IN ('DIS', 'SUR', 'PBH');
        --
   CURSOR c_get_exchange_rate_info(p_utilization_id  IN NUMBER) IS
       SELECT exchange_rate_date,exchange_rate_type
       FROM ozf_funds_utilized_all_b
       WHERE utilization_id = p_utilization_id;

      l_shipped_qty   NUMBER;
      l_offer_curr    VARCHAR2(150);
      l_transaction_curr_code VARCHAR2(150);
      l_offer_amount  NUMBER;

      l_ordered_qty   NUMBER;
      l_offer_type    VARCHAR2(240);

       l_group_id                NUMBER;
      l_pbh_line_id             NUMBER;
      l_included_vol_flag       VARCHAR2(1);
      l_retroactive             VARCHAR2(1) ;
      l_discount_type           VARCHAR2(30);
      l_volume_type             VARCHAR2(30);

      l_msg_count               NUMBER;
      l_msg_data                VARCHAR2 (2000)        := NULL;
      l_source_code             VARCHAR2(30);
      l_volume                  NUMBER;
      l_new_discount            NUMBER;
      l_min_tier                NUMBER;
      l_max_tier                NUMBER;
      l_utilization_amount      NUMBER;
      l_unit_selling_price      NUMBER;
      l_unit_discount           NUMBER;
      l_exchange_rate_date      DATE;
      l_exchange_rate_type      VARCHAR2(30) := FND_API.G_MISS_CHAR;


   BEGIN
      SAVEPOINT adjust_changed_order;
      -- Standard call to check for call compatibility.
      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;
      -- Initialize message list IF p_init_msg_list is set to TRUE.
      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;
      --  Initialize API return status to success
      x_return_status            := fnd_api.g_ret_sts_success;
      <<new_line_tbl_loop>>

      IF g_debug_flag = 'Y' THEN
         ozf_utility_pvt.write_conc_log (
            ' /*************************** DEBUG MESSAGE START for adjust_changed_line *************************/');
      END IF;

      FOR i IN NVL (p_line_tbl.FIRST, 1) .. NVL (p_line_tbl.LAST, 0)
      LOOP
         savepoint line_adjustment;
         IF g_debug_flag = 'Y' THEN
            ozf_utility_pvt.write_conc_log (
            '    D: Begin Processing For Order Line '|| p_line_tbl(i).line_id || ' cancelled_flag=' || p_line_tbl (i).cancelled_flag
               );
         END IF;

         IF g_debug_flag = 'Y' THEN
            ozf_utility_pvt.write_conc_log ('    D: AQ info for order header_id=' || p_line_tbl(i).header_id
                          -- || ' p_line_tbl(i).operation=' || p_line_tbl(i).operation
                           || ' p_line_tbl(i).flow_status_code=' || p_line_tbl(i).flow_status_code
                           || ' p_line_tbl(i).line_id=' || p_line_tbl(i).line_id
                           || ' p_line_tbl(i).ordered_quantity=' || p_line_tbl(i).ordered_quantity
                           || ' p_line_tbl(i).shipped_quantity=' || p_line_tbl(i).shipped_quantity
                           || ' p_line_tbl(i).invoiced_quantity=' || p_line_tbl(i).invoiced_quantity
                           || ' p_line_tbl(i).invoice_interface_status_code=' || p_line_tbl(i).invoice_interface_status_code
                           || ' p_line_tbl(i).line_category_code=' || p_line_tbl(i).line_category_code );
            ozf_utility_pvt.write_conc_log ('    D: AQ info for old order header_id=' || p_line_tbl(i).header_id
                          -- || ' p_line_tbl(i).operation=' || p_line_tbl(i).operation
                           || ' p_old_line_tbl(i).flow_status_code=' || p_old_line_tbl(i).flow_status_code
                           || ' p_old_line_tbl(i).line_id=' || p_old_line_tbl(i).line_id
                           || ' p_old_line_tbl(i).ordered_quantity=' || p_old_line_tbl(i).ordered_quantity
                           || ' p_old_line_tbl(i).shipped_quantity=' || p_old_line_tbl(i).shipped_quantity
                           || ' p_old_line_tbl(i).invoiced_quantity=' || p_old_line_tbl(i).invoiced_quantity
                           || ' p_old_line_tbl(i).invoice_interface_status_code=' || p_old_line_tbl(i).invoice_interface_status_code
                           || ' p_old_line_tbl(i).line_category_code=' || p_old_line_tbl(i).line_category_code );
         END IF;

         IF p_line_tbl (i).cancelled_flag = 'Y' THEN

            FOR price_adjustment_rec IN c_all_price_adjustments (p_line_tbl (i).line_id)
            LOOP

               FOR old_adjustment_rec IN
                   c_old_adjustment_amount (price_adjustment_rec.price_adjustment_id)
               LOOP

                  l_adj_amount := -old_adjustment_rec.amount;

                  IF old_adjustment_rec.amount = 0 THEN
                     GOTO l_endofloop;
                  END IF;

                  l_util_rec := l_empty_util_rec;
                  l_act_budgets_rec :=l_empty_act_budgets_rec;
                  l_act_budgets_rec.budget_source_type := 'OFFR';
                  l_act_budgets_rec.budget_source_id := old_adjustment_rec.plan_id;
                  l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
                  l_act_budgets_rec.act_budget_used_by_id := old_adjustment_rec.plan_id;
                  l_act_budgets_rec.parent_src_curr := old_adjustment_rec.currency_code;
                  l_act_budgets_rec.parent_source_id := old_adjustment_rec.fund_id;
                  l_util_rec.object_type := 'ORDER';
                  l_util_rec.object_id   := p_line_tbl (i).header_id;
                  l_util_rec.product_id := p_line_tbl(i).inventory_item_id;
                  l_util_rec.price_adjustment_id := old_adjustment_rec.price_adjustment_id;
                  l_util_rec.utilization_type := old_adjustment_rec.utilization_type;
                  l_util_rec.component_id :=old_adjustment_rec.plan_id;
                  l_util_rec.component_type := 'OFFR';
                  l_util_rec.currency_code :=old_adjustment_rec.currency_code;
                  l_util_rec.fund_id :=old_adjustment_rec.fund_id;
                  l_util_rec.order_line_id := p_line_tbl (i).line_id;
                  l_util_rec.gl_posted_flag := old_adjustment_rec.gl_posted_flag;
                  l_act_budgets_rec.parent_src_apprvd_amt := l_adj_amount;
                  l_act_budgets_rec.request_amount :=-old_adjustment_rec.plan_curr_amount;
                  --Fix for bug 8660000
                  l_act_budgets_rec.request_currency := old_adjustment_rec.plan_currency_code;
                  --End bug 8660000
                  l_util_rec.amount := l_adj_amount ;
                  l_util_rec.plan_curr_amount :=  l_act_budgets_rec.request_amount;

                  IF old_adjustment_rec.utilization_type  = 'ADJUSTMENT' THEN
                     l_util_rec.adjustment_type_id :=-4;
                     l_util_rec.adjustment_type := 'DECREASE_EARNED';
                     l_util_rec.orig_utilization_id := old_adjustment_rec.orig_utilization_id;
                  END IF;
                  --nirprasa, ER 8399134. Called for cancelled orders
                  l_util_rec.plan_currency_code :=  old_adjustment_rec.plan_currency_code;
                  l_util_rec.fund_request_currency_code :=  old_adjustment_rec.fund_request_currency_code;
                  l_util_rec.fund_request_amount :=  -old_adjustment_rec.fund_request_amount;

                  create_fund_utilization (
                        p_act_util_rec=> l_util_rec,
                        p_act_budgets_rec=> l_act_budgets_rec,
                        x_utilization_id => l_utilization_id,
                        x_return_status=> l_return_status,
                        x_msg_count=> x_msg_count,
                        x_msg_data=> x_msg_data
                     );

                  IF g_debug_flag = 'Y' THEN
                     ozf_utility_pvt.write_conc_log (
                       '    D: create utlization from cancelled order returns '|| l_return_status);
                  END IF;

                  IF l_return_status <> fnd_api.g_ret_sts_success THEN
                     GOTO l_endoflineadjloop;
                  END IF;
                  --- quit when the total earned amount is adjusted
                  <<l_endofloop>>
                  NULL;
               END LOOP old_adjustment_rec;
            END LOOP; -- end loop for price adjustment rec
         END IF;   -- if for cancelled flag


         IF p_line_tbl (i).reference_line_id IS NOT NULL
            --AND p_line_tbl (i).flow_status_code = 'FULFILLED'
            AND p_line_tbl (i).line_category_code ='RETURN'
            AND p_line_tbl(i).invoiced_quantity IS NOT NULL THEN

            IF g_debug_flag = 'Y' THEN
               ozf_utility_pvt.write_conc_log('    D: adjusted_changed_order: RMA with reference: ' || p_line_tbl(i).reference_line_id);
            END IF;

            OPEN c_orig_order_info (p_line_tbl (i).reference_line_id);
            FETCH c_orig_order_info INTO l_shipped_qty;
            CLOSE c_orig_order_info;

            FOR old_adjustment_rec IN
                c_orig_adjustment_amount (p_line_tbl (i).reference_line_id)
            LOOP

               IF l_shipped_qty is NOT NULL OR l_shipped_qty <> 0 THEN
                  l_adj_amount := old_adjustment_rec.amount * p_line_tbl(i).invoiced_quantity/ l_shipped_qty ;
               END IF;

               IF g_debug_flag = 'Y' THEN
                  ozf_utility_pvt.write_conc_log(' D: adjusted_changed_order: RMA with reference: l_adj_amount    ' || l_adj_amount);
               END IF;

               IF old_adjustment_rec.amount = 0 OR l_adj_amount = 0 THEN
                  GOTO l_endofloop;
               END IF;

               l_util_rec := l_empty_util_rec;
               l_act_budgets_rec :=l_empty_act_budgets_rec;
               l_act_budgets_rec.budget_source_type := 'OFFR';
               l_act_budgets_rec.budget_source_id := old_adjustment_rec.plan_id;
               l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
               l_act_budgets_rec.act_budget_used_by_id := old_adjustment_rec.plan_id;
               l_act_budgets_rec.parent_src_curr := old_adjustment_rec.currency_code;
               l_act_budgets_rec.parent_source_id := old_adjustment_rec.fund_id;
               l_util_rec.object_type := 'ORDER';
               l_util_rec.object_id   := p_line_tbl (i).header_id;
               l_util_rec.product_id := p_line_tbl(i).inventory_item_id;
               l_util_rec.price_adjustment_id := old_adjustment_rec.price_adjustment_id;
               l_util_rec.utilization_type := old_adjustment_rec.utilization_type;
               l_util_rec.component_id :=old_adjustment_rec.plan_id;
               l_util_rec.component_type := 'OFFR';
               l_util_rec.currency_code :=old_adjustment_rec.currency_code;
               l_util_rec.fund_id :=old_adjustment_rec.fund_id;
               l_util_rec.order_line_id := p_line_tbl (i).line_id;
               l_util_rec.gl_posted_flag := old_adjustment_rec.gl_posted_flag;
               l_util_rec.gl_date := sysdate;
               l_act_budgets_rec.parent_src_apprvd_amt := l_adj_amount;
               l_act_budgets_rec.request_amount :=old_adjustment_rec.plan_curr_amount * p_line_tbl(i).invoiced_quantity/ l_shipped_qty ;
               l_act_budgets_rec.request_currency := old_adjustment_rec.plan_currency_code;
               l_util_rec.amount := l_adj_amount ;
               l_util_rec.plan_curr_amount :=  l_act_budgets_rec.request_amount;
               l_util_rec.adjustment_type_id :=-4;
               l_util_rec.adjustment_type := 'DECREASE_EARNED';
               l_util_rec.orig_utilization_id := old_adjustment_rec.orig_utilization_id;
               --nirprasa, ER 8399134. Called for returned orders
               l_util_rec.plan_currency_code :=  old_adjustment_rec.plan_currency_code;
               l_util_rec.fund_request_currency_code :=  old_adjustment_rec.fund_request_currency_code;
               l_util_rec.fund_request_amount :=  -old_adjustment_rec.fund_request_amount;

               create_fund_utilization (
                        p_act_util_rec=> l_util_rec,
                        p_act_budgets_rec=> l_act_budgets_rec,
                        x_utilization_id => l_utilization_id,
                        x_return_status=> l_return_status,
                        x_msg_count=> x_msg_count,
                        x_msg_data=> x_msg_data
               );

               IF g_debug_flag = 'Y' THEN
                  ozf_utility_pvt.write_conc_log (
                       '    D: create utlization from RMA order: ' || l_return_status);
               END IF;

               IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  GOTO l_endoflineadjloop;
               END IF;
                  --- quit when the total earned amount is adjusted
               <<l_endofloop>>
               NULL;
            END LOOP old_adjustment_rec;
         END IF; -- end of p_line_tbl (i).reference_line_id IS NOT NULL

         /*
           Note: adjustment already posted to TM budget in adjust_accrual when line is SHIPPED or RETURN order is booked
                 SHIPPED LINE: if shipped quantity <> requested quantity, e.g.
                 Original order: quantity 10, price adjustment id 12345
                 During shipping, only 8 are shipped, then 2 is backordered.
                 2 new lines are automatically created:
                 one line for shipped: quantity = 8, with old price adjustment id, line operation=UPDATE
                 another line for backorder: quantity = 2(10-8), with new price adjustment id, line operation=CREATE

                 handle case for partial ship with running accrual engine before ship. added by fliu on 05/24/04 to fix bug 3357164
                 If running accrual engine after booking order, one record is created. then partial shipped,  two new records will be created. one with positive
                 for backordered amount. another with negative for adjustment from previous record.
           */

          IF p_line_tbl(i).line_id= p_old_line_tbl(i).line_id
             AND p_old_line_tbl(i).ordered_quantity <>p_line_tbl(i).shipped_quantity
             AND NVL(p_line_tbl(i).shipped_quantity,0) <> 0
             --AND p_line_tbl(i).flow_status_code = 'SHIPPED'
          THEN

             IF g_debug_flag = 'Y' THEN
                ozf_utility_pvt.write_conc_log('    D: adjusted_changed_order: partial shipment line(line_id=' || p_line_tbl(i).line_id || ')');
             END IF;

             OPEN c_order_info (p_line_tbl (i).header_id);
             FETCH c_order_info INTO l_order_status, l_order_booked_flag, l_order_curr,l_order_number,l_org_id;
             CLOSE c_order_info;

             FOR price_adjustment_rec IN c_all_price_adjustments (p_line_tbl (i).line_id)
             LOOP

                OPEN c_old_adjustment_total_amount (price_adjustment_rec.price_adjustment_id);
                FETCH c_old_adjustment_total_amount INTO l_total;
                CLOSE c_old_adjustment_total_amount;

                IF NVL(l_total,0) = 0 THEN  -- add to fix bug 4930867.
                   GOTO l_endpriceadjloop;
                END IF;

                FOR old_adjustment_rec IN
                    c_old_adjustment_amount(price_adjustment_rec.price_adjustment_id)
                LOOP
                              -- adjust unshipped amount.
                    IF g_debug_flag = 'Y' THEN
                       ozf_utility_pvt.write_conc_log (' price_adjustment_rec.adjusted_amount: '|| price_adjustment_rec.adjusted_amount ||
                                                       ' p_line_tbl(i).shipped_quantity: '|| p_line_tbl(i).shipped_quantity ||
                                                       ' old_adjustment_rec.plan_curr_amount: '|| old_adjustment_rec.plan_curr_amount ||
                                                       ' price_adjustment_rec.price_adjustment_id: '|| price_adjustment_rec.price_adjustment_id );
                    END IF;

                    -- add by feliu on 08/03/04 to fix  3778200
                    IF old_adjustment_rec.utilization_type IN ('ADJUSTMENT', 'LEAD_ADJUSTMENT') THEN  -- new calculation for adjustment.
                       l_orig_adj_amount := old_adjustment_rec.plan_curr_amount *
                                     (1 - p_line_tbl(i).shipped_quantity / p_old_line_tbl(i).ordered_quantity) ; -- in order currency.
                    ELSE
                        -- added by Ribha for bug fix 4417084
                       IF p_line_tbl(i).line_category_code <> 'RETURN' THEN
                          l_orig_adj_amount := old_adjustment_rec.plan_curr_amount -
                                             ( - price_adjustment_rec.adjusted_amount * p_line_tbl(i).shipped_quantity
                                             * old_adjustment_rec.plan_curr_amount /l_total) ; -- in order currency.
                       ELSE
                          l_orig_adj_amount := old_adjustment_rec.plan_curr_amount -
                                             ( - price_adjustment_rec.adjusted_amount * (-p_line_tbl(i).shipped_quantity)
                                                * old_adjustment_rec.plan_curr_amount /l_total) ; -- in order currency.
                       END IF;
                    END IF;

                    IF g_debug_flag = 'Y' THEN
                       ozf_utility_pvt.write_conc_log (' partial ship l_total: '|| l_total ||
                                          ' partial ship p_line_tbl(i).shipped_quantity : '|| p_line_tbl(i).shipped_quantity  ||
                                          ' partial ship l_orig_adj_amount: '|| l_orig_adj_amount );
                    END IF;

                    l_orig_adj_amount  := ozf_utility_pvt.currround (
                                    l_orig_adj_amount ,
                                   --nirprasa, ER 8399134, now the amount can be in offer currency also
                                   --so remove the order currency and get the currency from old record
                                   --l_order_curr
                                   old_adjustment_rec.plan_currency_code
                                  );

                   --nirprasa, ER 8399134
                   --IF l_order_curr <> old_adjustment_rec.currency_code THEN
                   IF old_adjustment_rec.plan_currency_code <> old_adjustment_rec.currency_code THEN
                       ozf_utility_pvt.convert_currency(x_return_status => l_return_status
                                                        ,p_from_currency => old_adjustment_rec.plan_currency_code
                                                        ,p_to_currency => old_adjustment_rec.currency_code
                                                        ,p_conv_type => old_adjustment_rec.exchange_rate_type --nirprasa Added for bug 7030415
                                                        ,p_from_amount =>l_orig_adj_amount
                                                        ,x_to_amount => l_adj_amount
                                                        ,x_rate => l_rate); -- in fund  currency

                    ELSE
                       l_adj_amount := l_orig_adj_amount;
                    END IF;

                    IF g_debug_flag = 'Y' THEN
                       ozf_utility_pvt.write_conc_log (' partial ship adj_amount: '|| l_adj_amount );
                    END IF;

                    IF NVL(l_adj_amount,0) = 0 THEN
                       GOTO l_endoffloop;
                    END IF;

                    l_util_rec := l_empty_util_rec;
                    l_act_budgets_rec :=l_empty_act_budgets_rec;
                    l_util_rec.object_type := 'ORDER';
                    l_util_rec.object_id   := p_line_tbl (i).header_id;
                    l_util_rec.product_id := p_line_tbl(i).inventory_item_id;
                    l_util_rec.price_adjustment_id := price_adjustment_rec.price_adjustment_id;
                    l_util_rec.utilization_type := old_adjustment_rec.utilization_type;
                    l_act_budgets_rec.budget_source_type := 'OFFR';
                    l_act_budgets_rec.budget_source_id := old_adjustment_rec.plan_id;
                    l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
                    l_act_budgets_rec.act_budget_used_by_id := old_adjustment_rec.plan_id;
                    l_act_budgets_rec.parent_src_apprvd_amt := - l_adj_amount;
                    l_act_budgets_rec.parent_src_curr := old_adjustment_rec.currency_code;
                    l_act_budgets_rec.parent_source_id := old_adjustment_rec.fund_id;
                    l_act_budgets_rec.request_amount :=-l_orig_adj_amount;
                    l_act_budgets_rec.request_currency := l_order_curr;
                    l_util_rec.amount := - l_adj_amount ;

                    --nirprasa, ER 8399134,multi-currency enhancement, keep the amount in order currency
                    OPEN c_offer_currency (old_adjustment_rec.plan_id);
                    FETCH c_offer_currency INTO l_offer_curr,l_transaction_curr_code;
                    CLOSE c_offer_currency;

                    IF l_transaction_curr_code IS NOT NULL AND l_order_curr <> l_transaction_curr_code THEN
                       ozf_utility_pvt.convert_currency(x_return_status => l_return_status
                                                        ,p_from_currency => l_order_curr
                                                        ,p_to_currency => l_transaction_curr_code
                                                        ,p_conv_type => old_adjustment_rec.exchange_rate_type --nirprasa Added for bug 7030415
                                                        ,p_from_amount =>l_orig_adj_amount
                                                        ,x_to_amount => l_offer_amount
                                                        ,x_rate => l_rate); -- in offer  currency

                    ELSE
                       l_offer_amount := l_orig_adj_amount;
                    END IF;
                    l_util_rec.plan_curr_amount :=  - l_offer_amount;
                    --nirprasa, ER 8399134

                    l_util_rec.component_id :=old_adjustment_rec.plan_id;
                    l_util_rec.component_type := 'OFFR';
                    l_util_rec.currency_code :=old_adjustment_rec.currency_code;
                    l_util_rec.fund_id :=old_adjustment_rec.fund_id;
                    l_util_rec.order_line_id := p_line_tbl (i).line_id;
                    l_util_rec.gl_posted_flag := old_adjustment_rec.gl_posted_flag;  -- 'N';
                    -- create adjustment , added by feliu on 08/03/04 to fix bug 3778200
                    IF old_adjustment_rec.utilization_type  = 'ADJUSTMENT' THEN
                       l_util_rec.adjustment_type_id :=-4;
                       l_util_rec.adjustment_type := 'DECREASE_EARNED';
                       l_util_rec.orig_utilization_id := old_adjustment_rec.orig_utilization_id;
                    END IF;
                    --nirprasa, ER 8399134 multi currency enhancement. partial shipment
                    l_util_rec.plan_currency_code :=  old_adjustment_rec.plan_currency_code;
                    l_util_rec.fund_request_currency_code :=  old_adjustment_rec.fund_request_currency_code;

                    create_fund_utilization (
                                     p_act_util_rec=> l_util_rec,
                                     p_act_budgets_rec=> l_act_budgets_rec,
                                     x_utilization_id => l_utilization_id,
                                     x_return_status=> l_return_status,
                                     x_msg_count=> x_msg_count,
                                    x_msg_data=> x_msg_data
                                  );
                    IF g_debug_flag = 'Y' THEN
                       ozf_utility_pvt.write_conc_log (' retrun status for create _fund_utilization of '|| l_return_status ||
                            ' when partial shipping. ' );
                    END IF;

                    IF l_return_status <> fnd_api.g_ret_sts_success THEN
                       GOTO l_endoflineadjloop;
                    END IF;
                    /* yzhao: fix bug 3778200 - partial shipment after offer adjustment.
                              if line is splitted to have new line for unshipped quantity, new price adjustment need to pass to the offer adjustment
                    */
                    /* adjustment should populate order_line_id */
                    IF old_adjustment_rec.utilization_type IN ('ADJUSTMENT', 'LEAD_ADJUSTMENT')  THEN
                       -- find out the corresponding new order line id and price adjustment id
                       -- create positive offer adjustment for unshipped quantity, no gl posting
                       -- and set new price adjustment id
                       OPEN c_split_line(p_line_tbl (i).line_id);
                       FETCH c_split_line INTO l_new_line_id;
                       CLOSE c_split_line;

                       OPEN c_new_adj_line(l_new_line_id,old_adjustment_rec.plan_id);
                       FETCH c_new_adj_line INTO l_new_adj_id;
                       CLOSE c_new_adj_line;

                       OPEN c_max_utilized_id(l_new_adj_id);
                       FETCH c_max_utilized_id INTO  l_util_rec.orig_utilization_id;
                       CLOSE c_max_utilized_id;
                       IF g_debug_flag = 'Y' THEN
                          ozf_utility_pvt.write_conc_log ('create positive line for adjustment: '|| l_new_adj_id );
                       END IF;
                       l_act_budgets_rec.request_amount := -l_act_budgets_rec.request_amount;
                       l_act_budgets_rec.parent_src_apprvd_amt := - l_act_budgets_rec.parent_src_apprvd_amt;
                       l_util_rec.amount := -l_util_rec.amount;
                       l_util_rec.plan_curr_amount := -l_util_rec.plan_curr_amount;
                       l_util_rec.order_line_id := l_new_line_id;
                       l_util_rec.price_adjustment_id := l_new_adj_id;

                       IF l_util_rec.utilization_type  = 'ADJUSTMENT' THEN
                          l_util_rec.adjustment_type_id :=-5;
                          l_util_rec.adjustment_type := 'STANDARD';
                       END IF;

                       create_fund_utilization (
                                         p_act_util_rec=> l_util_rec,
                                         p_act_budgets_rec=> l_act_budgets_rec,
                                         x_utilization_id => l_utilization_id,
                                         x_return_status=> l_return_status,
                                         x_msg_count=> x_msg_count,
                                        x_msg_data=> x_msg_data
                                      );

                       IF l_return_status <> fnd_api.g_ret_sts_success THEN
                          GOTO l_endoflineadjloop;
                       END IF;

                    END IF;-- end loop of old_adjustment_rec.utilization_type
                     --- quit when the total earned amount is adjusted
                    <<l_endoffloop>>
                    NULL;
                END LOOP old_adjustment_rec;
                <<l_endpriceadjloop>>
                NULL;
             END LOOP; -- end loop for price adjustment rec



          END IF; -- end of shipped_quantity is not equal ordered_quantity.

          /*  yzhao: 12/02/2003 11.5.10 post to GL based on profile TM: Create GL Entries for Orders
              For normal order with accrual offer
                  a) if profile is set to 'Shipped', post to gl when line is shipped
                  b) if profile is set to 'Invoiced', post to gl when line is invoiced
              For normal order with off invoice offer that needs to post to gl
               or returned order,
                  post to gl when line is invoiced
           */
         l_gl_date := NULL;

         IF g_debug_flag = 'Y' THEN
            ozf_utility_pvt.write_conc_log ('    D: profile to create gl entries is set to ' ||
                    fnd_profile.VALUE ('OZF_ORDER_GLPOST_PHASE') || ' g_order_gl_phase=' || g_order_gl_phase);
         END IF;

         IF ( g_order_gl_phase = 'SHIPPED' AND p_line_tbl(i).line_category_code <> 'RETURN' AND
            NVL(p_line_tbl(i).shipped_quantity,0) <> 0 AND
            -- July 08 2004 fix bug 3746354 utilization missing for unshipped quantity after second partial shipment. add flow_status_code='SHIPPED'
            p_line_tbl(i).flow_status_code = 'SHIPPED') THEN
            OPEN c_actual_shipment_date(p_line_tbl(i).line_id);
            FETCH c_actual_shipment_date into l_gl_date ;
            CLOSE c_actual_shipment_date;

            l_sales_transaction_rec.quantity     := p_line_tbl(i).shipped_quantity;
            l_sales_transaction_rec.transfer_type := 'IN';

            IF g_debug_flag = 'Y' THEN
               ozf_utility_pvt.write_conc_log('    D: adjust_changed_order() gl_date uses shipment date: ' || l_gl_date || ' for arrcual posting');
            END IF;

         END IF;

         IF l_order_number IS NULL THEN -- get order_number if null, bug fix 3917556
            OPEN c_order_info (p_line_tbl (i).header_id);
            FETCH c_order_info INTO l_order_status, l_order_booked_flag, l_order_curr,l_order_number,l_org_id;
            CLOSE c_order_info;
         END IF;

         IF l_gl_date IS NULL THEN
            IF (p_line_tbl(i).invoice_interface_status_code = 'YES' OR NVL(p_line_tbl(i).invoiced_quantity,0) <> 0) THEN
               OPEN c_invoice_date(p_line_tbl(i).line_id, l_order_number);
               FETCH c_invoice_date INTO l_gl_date;
               CLOSE c_invoice_date;

               IF l_gl_date IS NULL THEN
                    -- yzhao: Jun 29, 2004 if accrual engine runs before auto-invoice completes, invoice record not created in ar table
                  l_gl_date := sysdate;
                  IF g_debug_flag = 'Y' THEN
                     ozf_utility_pvt.write_conc_log('    D: adjust_changed_order() auto-invoice not complete. use sysdate for gl_date');
                  END IF;
               END IF;

               l_sales_transaction_rec.quantity   := p_line_tbl(i).invoiced_quantity;

               IF g_debug_flag = 'Y' THEN
                  ozf_utility_pvt.write_conc_log('    D: adjust_changed_order() gl_date uses invoice date: ' || l_gl_date || ' for arrcual posting');
               END IF;
            END IF;
         END IF;

         IF l_gl_date IS NOT NULL THEN
            OPEN sales_transation_csr(p_line_tbl (i).line_id);
            FETCH  sales_transation_csr INTO l_sales_trans;
            CLOSE sales_transation_csr;

            IF g_debug_flag = 'Y' THEN
               ozf_utility_pvt.write_conc_log('    Create_Transaction: l_sales_trans:  ' ||  l_sales_trans);
            END IF;

            IF NVL(l_sales_trans,0) <> 1 THEN

               l_sales_transaction_rec.sold_to_cust_account_id := p_line_tbl (i).sold_to_org_id;

               OPEN party_id_csr(l_sales_transaction_rec.sold_to_cust_account_id);
               FETCH party_id_csr INTO l_sales_transaction_rec.sold_to_party_id;
               CLOSE party_id_csr;

               OPEN party_site_id_csr(p_line_tbl (i).invoice_to_org_id);
               FETCH party_site_id_csr INTO l_sales_transaction_rec.sold_to_party_site_id;
               CLOSE party_site_id_csr;

               l_sales_transaction_rec.ship_to_site_use_id  := p_line_tbl (i).ship_to_org_id;
               l_sales_transaction_rec.bill_to_site_use_id  :=p_line_tbl(i).invoice_to_org_id;
               l_sales_transaction_rec.uom_code:= NVL(p_line_tbl(i).shipping_quantity_uom,p_line_tbl(i).order_quantity_uom);
               l_sales_transaction_rec.amount   := p_line_tbl(i).unit_selling_price * l_sales_transaction_rec.quantity;
               l_sales_transaction_rec.currency_code  :=l_order_curr;
               l_sales_transaction_rec.inventory_item_id := p_line_tbl(i).inventory_item_id;
               l_sales_transaction_rec.header_id  :=   p_line_tbl (i).header_id;
               l_sales_transaction_rec.line_id  := p_line_tbl (i).line_id;
               l_sales_transaction_rec.source_code := 'OM';
               IF p_line_tbl(i).line_category_code <> 'RETURN' THEN
                  l_sales_transaction_rec.transfer_type := 'IN';
               ELSE
                  l_sales_transaction_rec.transfer_type := 'OUT';
               END IF;
               l_sales_transaction_rec.transaction_date  := l_gl_date;--l_volume_detail_rec.transaction_date
               l_sales_transaction_rec.org_id := l_org_id;

               IF g_debug_flag = 'Y' THEN
                  ozf_utility_pvt.write_conc_log('   Create_Transaction' );
               END IF;

               OZF_SALES_TRANSACTIONS_PVT.Create_Transaction (
                               p_api_version      => 1.0
                              ,p_init_msg_list    => FND_API.G_FALSE
                              ,p_commit           => FND_API.G_FALSE
                              ,p_validation_level => FND_API.G_VALID_LEVEL_FULL
                              ,p_transaction_rec  => l_sales_transaction_rec
                              ,x_sales_transaction_id => l_sales_transaction_id
                              ,x_return_status    => l_return_status
                              ,x_msg_data         => x_msg_data
                              ,x_msg_count        => x_msg_count
                      );

               IF g_debug_flag = 'Y' THEN
                  ozf_utility_pvt.write_conc_log('   Create_Transaction' ||  l_return_status);
               END IF;

               IF l_return_status <> fnd_api.g_ret_sts_success THEN
                  GOTO l_endoflineadjloop;
               END IF;
            END IF; -- NVL(l_sales_trans,0)

            IF g_debug_flag = 'Y' THEN
               ozf_utility_pvt.write_conc_log(' recalculate_earnings: start');
            END IF;
            OPEN c_get_accrual_rec(p_line_tbl(i).line_id);
            LOOP
               FETCH c_get_accrual_rec BULK COLLECT
               INTO l_utilIdTbl, l_objVerTbl, l_planTypeTbl, l_utilTypeTbl, l_amountTbl
                    , l_fundIdTbl, l_acctAmtTbl, l_planAmtTbl, l_planIdTbl,l_orgIdTbl
                    , l_excTypeTbl, l_excDateTbl, l_currCodeTbl, l_planCurrCodeTbl
                    , l_fundReqCurrCodeTbl, l_planCurrAmtTbl, l_planCurrAmtRemTbl
                    , l_univCurrAmtTbl
               LIMIT g_bulk_limit;

               FORALL t_i IN NVL(l_utilIdTbl.FIRST, 1) .. NVL(l_utilIdTbl.LAST, 0)
               UPDATE ozf_funds_utilized_all_b
               SET gl_date = l_gl_date
               WHERE utilization_id = l_utilIdTbl(t_i);

               FOR t_i IN NVL(l_utilIdTbl.FIRST, 1) .. NVL(l_utilIdTbl.LAST, 0)
               LOOP
                  IF TRUNC(l_excDateTbl(t_i)) <> TRUNC(l_gl_date)
                     AND l_utilTypeTbl(t_i) IN ('ACCRUAL', 'LEAD_ACCRUAL','SALES_ACCRUAL','UTILIZED') THEN


                     l_excDateTbl(t_i) := l_gl_date;
                     IF g_debug_flag = 'Y' THEN
                        ozf_utility_pvt.write_conc_log(' recalculate_earnings: start');
                        ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_excDateTbl(t_i) '||l_excDateTbl(t_i));
                        ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_excTypeTbl(t_i) '||l_excTypeTbl(t_i));
                        ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_orgIdTbl(t_i) '||l_orgIdTbl(t_i));
                        ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_currCodeTbl(t_i) '||l_currCodeTbl(t_i));
                        ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_planCurrCodeTbl(t_i) '||l_planCurrCodeTbl(t_i));
                        ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_fundReqCurrCodeTbl(t_i) '||l_fundReqCurrCodeTbl(t_i));
                        ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_amountTbl(t_i) '||l_amountTbl(t_i));
                        ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_planCurrAmtTbl(t_i) '||l_planCurrAmtTbl(t_i));
                        ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_planCurrAmtRemTbl(t_i) '||l_planCurrAmtRemTbl(t_i));
                        ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_univCurrAmtTbl(t_i) '||l_univCurrAmtTbl(t_i));
                        ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_acctAmtTbl(t_i) '||l_acctAmtTbl(t_i));
                        ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_planIdTbl(t_i) '||l_planIdTbl(t_i));
                        ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_planTypeTbl(t_i) '||l_planTypeTbl(t_i));
                        ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_fundIdTbl(t_i) '||l_fundIdTbl(t_i));
                        ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_utilIdTbl(t_i) '||l_utilIdTbl(t_i));
                        ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_utilTypeTbl(t_i) '||l_utilTypeTbl(t_i));
                      END IF;
                     recalculate_earnings(p_exchange_rate_date     => l_excDateTbl(t_i),
                                          p_exchange_rate_type     => l_excTypeTbl(t_i),
                                          p_util_org_id            => l_orgIdTbl(t_i),
                                          p_currency_code          => l_currCodeTbl(t_i),
                                          p_plan_currency_code     => l_planCurrCodeTbl(t_i),
                                          p_fund_req_currency_code => l_fundReqCurrCodeTbl(t_i),
                                          p_amount                 => l_amountTbl(t_i),
                                          p_plan_curr_amount       => l_planCurrAmtTbl(t_i),
                                          p_plan_curr_amount_rem   => l_planCurrAmtRemTbl(t_i),
                                          p_univ_curr_amount       => l_univCurrAmtTbl(t_i),
                                          p_acctd_amount           => l_acctAmtTbl(t_i),
                                          p_fund_req_amount        => l_planAmtTbl(t_i),
                                          p_util_plan_id           => l_planIdTbl(t_i),
                                          p_util_plan_type         => l_planTypeTbl(t_i),
                                          p_util_fund_id           => l_fundIdTbl(t_i),
                                          p_util_utilization_id    => l_utilIdTbl(t_i),
                                          p_util_utilization_type  => l_utilTypeTbl(t_i),
                                          x_return_status          => l_return_status,
                                          x_msg_count              => x_msg_count,
                                          x_msg_data               => x_msg_data);
                     IF g_debug_flag = 'Y' THEN
                        ozf_utility_pvt.write_conc_log(' recalculate_earnings returns ' || l_return_status
                             );
                        ozf_utility_pvt.write_conc_log(' l_planAmtTbl(t_i) ' || l_planAmtTbl(t_i));
                     END IF;
                  END IF;
                  IF l_amountTbl(t_i) <> 0 THEN--nepanda --Fix for bug 8994266
                  post_accrual_to_gl(        p_util_utilization_id          => l_utilIdTbl(t_i)
                                           , p_util_object_version_number => l_objVerTbl(t_i)
                                           , p_util_amount                => l_amountTbl(t_i)
                                           , p_util_plan_type             => l_planTypeTbl(t_i)
                                           , p_util_plan_id               => l_planIdTbl(t_i)
                                           , p_util_plan_amount           => l_planAmtTbl(t_i)
                                           , p_util_utilization_type      => l_utilTypeTbl(t_i)
                                           , p_util_fund_id               => l_fundIdTbl(t_i)
                                           , p_util_acctd_amount          => l_acctAmtTbl(t_i)
                                           , p_util_org_id                => l_orgIdTbl(t_i)
                                           , x_gl_posted_flag             => l_gl_posted_flag
                                           , x_return_status              => l_return_status
                                           , x_msg_count                  => x_msg_count
                                           , x_msg_data                   => x_msg_data
                                       );

                         -- do not raise exception for gl posting error. Just mark it as failed and deal with it later
                  IF g_debug_flag = 'Y' THEN
                     ozf_utility_pvt.write_conc_log('    D: adjust_changed_order() processing invoiced/shipped line ' || p_line_tbl(i).line_id
                             || '  post_accrual_to_gl(util_id=' || l_utilIdTbl(t_i) || ') returns ' || l_return_status
                             || '  x_gl_posted_flag=' || l_gl_posted_flag);
                  END IF;
                         -- yzhao: 03/04/2004 post gl for related accruals from offer adjustment or object reconcile
                  IF l_return_status = fnd_api.g_ret_sts_success AND l_gl_posted_flag = G_GL_FLAG_YES THEN
                     post_related_accrual_to_gl(
                                p_utilization_id              => l_utilIdTbl(t_i)
                              , p_utilization_type            => l_utilTypeTbl(t_i)
                              , p_gl_date                     => l_gl_date
                              , x_return_status               => l_return_status
                              , x_msg_count                   => x_msg_count
                              , x_msg_data                    => x_msg_data
                           );
                  END IF;
                  ELSE--if amount is zero then only update gl_posted_flag to Y in ozf_funds_utilized_all and do not insert record to ozf_ae_lines_all
                  UPDATE ozf_funds_utilized_all_b
                        SET last_update_date = SYSDATE
                          , last_updated_by = NVL (fnd_global.user_id, -1)
                          , last_update_login = NVL (fnd_global.conc_login_id, -1)
                          , object_version_number = l_objVerTbl(t_i) + 1
                          , gl_posted_flag = G_GL_FLAG_YES
                        WHERE utilization_id = l_utilIdTbl(t_i)
                        AND   object_version_number = l_objVerTbl(t_i);
                  END IF; --IF l_amountTbl(t_i) <> 0 THEN --nepanda Fix for bug 8994266
                END LOOP; -- FOR t_i IN NVL(l_utilIdTbl.FIRST, 1) .. NVL(l_utilIdTbl.LAST, 0) LOOP

                EXIT WHEN c_get_accrual_rec%NOTFOUND;
            END LOOP;  -- bulk fetch
            CLOSE c_get_accrual_rec;

         END IF;  -- IF l_gl_date IS NOT NULL

         <<l_endoflineadjloop>>
         IF l_return_status <> fnd_api.g_ret_sts_success THEN
            -- Write Relelvant Messages
            IF g_debug_flag = 'Y' THEN
                ozf_utility_pvt.write_conc_log (
               ' /*************************** DEBUG MESSAGE END *************************/' ||
               ' /****** Offer Adjustment For Line(id=' || p_line_tbl(i).line_id || ') failed  with the following Errors *******/');
            END IF;

            -- Dump All the MEssages from the Message list
            ozf_utility_pvt.write_conc_log;
            -- Initialize the Message list for NExt Processing
            fnd_msg_pub.initialize;
            ROLLBACK TO line_adjustment;
            -- return a status error
            x_return_status := fnd_api.g_ret_sts_error ;
            --5/30/2002  Added to exit the loop because we want to perform handle exception to put the  me
            -- go out of the loop because we put this message in the exception queue
            EXIT;
         ELSIF  l_return_status = fnd_api.g_ret_sts_success THEN
            IF g_debug_flag = 'Y' THEN
               ozf_utility_pvt.write_conc_log (' /*************************** DEBUG MESSAGE END *********************/'||
                   ' /****** Line Adjustment Success *******/ p_line_tbl(i).line_id  '   || p_line_tbl(i).line_id );
            END IF;
         ELSE
           IF g_debug_flag = 'Y' THEN
              ozf_utility_pvt.write_conc_log ( '    D: Line Return Status ' ||l_return_status);
           END IF;

         END IF;

      END LOOP new_line_tbl_loop;

      -- Standard call to get message count and IF count is 1, get message info.
      fnd_msg_pub.count_and_get (
         p_count=> x_msg_count,
         p_data=> x_msg_data,
         p_encoded=> fnd_api.g_false
      );
   EXCEPTION
      WHEN OTHERS THEN
         --ROLLBACK TO adjust_accrual;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         ozf_utility_pvt.write_conc_log (' /**************UNEXPECTED EXCEPTION*************/');
         ozf_utility_pvt.write_conc_log('    D: adjust_changed_order: exception. errcode=' || sqlcode || '  msg: ' || substr(sqlerrm, 1, 3000));

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count,
            p_data=> x_msg_data,
            p_encoded=> fnd_api.g_false
         );
   END adjust_changed_order;

   ------------------------------------------------------------------------------
-- Procedure Name
--   Get_Exception_Message
-- Purpose
--   This procedure collects order updates FROM the Order Capture NotIFication
--   API. Started FROM a concurrent process, it is a loop which
--   gets the latest notIFication off of the queue.
--
-- History
--   4/30/2002 mpande Created
------------------------------------------------------------------------------
   PROCEDURE get_exception_message (x_errbuf OUT NOCOPY VARCHAR2, x_retcode OUT NUMBER);
------------------------------------------------------------------------------
-- Procedure Name
--   Get_Message
-- Purpose
--   This procedure collects order updates FROM the Order Capture NotIFication
--   API. Started FROM a concurrent process, it is a loop which
--   gets the latest notIFication off of the queue.
--   p_run_exception IN VARCHAR2
--    Can Have 2 values : 'N' Run Only Messages Donot Run Exception Messages
--                      : 'Y' Run Both Message and Exception  DEFAULT
-- History
--   06-20-00  pjindal Created
--   06-20-00  updated message handling and error handling
--   5/6/2002  Added one more parameter to run exception messages
------------------------------------------------------------------------------
   PROCEDURE get_message (x_errbuf OUT NOCOPY VARCHAR2,
                          x_retcode OUT NOCOPY NUMBER,
                          p_run_exception IN VARCHAR2 := 'N',
                          p_debug     IN VARCHAR2 := 'N'
                         ) IS
      l_return_status              VARCHAR2 (1);
      l_process_audit_id           NUMBER;
      l_msg_count                  NUMBER;
      l_msg_data                   VARCHAR2 (2000);
      l_no_more_messages           VARCHAR2 (1);
      l_header_id                  NUMBER;
      l_booked_flag                VARCHAR2 (1);
      l_header_rec                 oe_order_pub.header_rec_type;
      l_old_header_rec             oe_order_pub.header_rec_type;
      l_header_adj_tbl             oe_order_pub.header_adj_tbl_type;
      l_old_header_adj_tbl         oe_order_pub.header_adj_tbl_type;
      l_header_price_att_tbl       oe_order_pub.header_price_att_tbl_type;
      l_old_header_price_att_tbl   oe_order_pub.header_price_att_tbl_type;
      l_header_adj_att_tbl         oe_order_pub.header_adj_att_tbl_type;
      l_old_header_adj_att_tbl     oe_order_pub.header_adj_att_tbl_type;
      l_header_adj_assoc_tbl       oe_order_pub.header_adj_assoc_tbl_type;
      l_old_header_adj_assoc_tbl   oe_order_pub.header_adj_assoc_tbl_type;
      l_header_scredit_tbl         oe_order_pub.header_scredit_tbl_type;
      l_old_header_scredit_tbl     oe_order_pub.header_scredit_tbl_type;
      l_line_tbl                   oe_order_pub.line_tbl_type;
      l_old_line_tbl               oe_order_pub.line_tbl_type;
      l_line_adj_tbl               oe_order_pub.line_adj_tbl_type;
      l_old_line_adj_tbl           oe_order_pub.line_adj_tbl_type;
      l_line_price_att_tbl         oe_order_pub.line_price_att_tbl_type;
      l_old_line_price_att_tbl     oe_order_pub.line_price_att_tbl_type;
      l_line_adj_att_tbl           oe_order_pub.line_adj_att_tbl_type;
      l_old_line_adj_att_tbl       oe_order_pub.line_adj_att_tbl_type;
      l_line_adj_assoc_tbl         oe_order_pub.line_adj_assoc_tbl_type;
      l_old_line_adj_assoc_tbl     oe_order_pub.line_adj_assoc_tbl_type;
      l_line_scredit_tbl           oe_order_pub.line_scredit_tbl_type;
      l_old_line_scredit_tbl       oe_order_pub.line_scredit_tbl_type;
      l_lot_serial_tbl             oe_order_pub.lot_serial_tbl_type;
      l_old_lot_serial_tbl         oe_order_pub.lot_serial_tbl_type;
      l_action_request_tbl         oe_order_pub.request_tbl_type;
      l_que_msg_count              NUMBER := 0 ;
   BEGIN
      -- Standard Start of process savepoint
      -- Start looping to check for messages in the queue
      fnd_msg_pub.initialize;
      g_debug_flag := p_debug ;

      SAVEPOINT get_message_savepoint;

      <<message_loop>>

      LOOP
         -- Queue savepoint for standard advanced queue error handling
         BEGIN
         SAVEPOINT get_message_loop_savepoint;

         ozf_utility_pvt.write_conc_log ('STARTING MESSAGE QUEUE');

         --
         -- Invoke Get_Mesage to dequeue queue payload and return Order data
         --
         aso_order_feedback_pub.get_notice (
            p_api_version=> 1.0,
            x_return_status=> l_return_status,
            x_msg_count=> l_msg_count,
            x_msg_data=> l_msg_data,
            p_app_short_name=> 'OZF' -- need to be resolved , wether it is AMS or OZF
                                    ,
            x_no_more_messages=> l_no_more_messages,
            x_header_rec=> l_header_rec,
            x_old_header_rec=> l_old_header_rec,
            x_header_adj_tbl=> l_header_adj_tbl,
            x_old_header_adj_tbl=> l_old_header_adj_tbl,
            x_header_price_att_tbl=> l_header_price_att_tbl,
            x_old_header_price_att_tbl=> l_old_header_price_att_tbl,
            x_header_adj_att_tbl=> l_header_adj_att_tbl,
            x_old_header_adj_att_tbl=> l_old_header_adj_att_tbl,
            x_header_adj_assoc_tbl=> l_header_adj_assoc_tbl,
            x_old_header_adj_assoc_tbl=> l_old_header_adj_assoc_tbl,
            x_header_scredit_tbl=> l_header_scredit_tbl,
            x_old_header_scredit_tbl=> l_old_header_scredit_tbl,
            x_line_tbl=> l_line_tbl,
            x_old_line_tbl=> l_old_line_tbl,
            x_line_adj_tbl=> l_line_adj_tbl,
            x_old_line_adj_tbl=> l_old_line_adj_tbl,
            x_line_price_att_tbl=> l_line_price_att_tbl,
            x_old_line_price_att_tbl=> l_old_line_price_att_tbl,
            x_line_adj_att_tbl=> l_line_adj_att_tbl,
            x_old_line_adj_att_tbl=> l_old_line_adj_att_tbl,
            x_line_adj_assoc_tbl=> l_line_adj_assoc_tbl,
            x_old_line_adj_assoc_tbl=> l_old_line_adj_assoc_tbl,
            x_line_scredit_tbl=> l_line_scredit_tbl,
            x_old_line_scredit_tbl=> l_old_line_scredit_tbl,
            x_lot_serial_tbl=> l_lot_serial_tbl,
            x_old_lot_serial_tbl=> l_old_lot_serial_tbl,
            x_action_request_tbl=> l_action_request_tbl
         );
         --
         --///added by mpande to write a error message to the list
         --if not sucess add a error message to th emessage listx
         IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
            ozf_utility_pvt.write_conc_log ('Queue Return Error ');

            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name ('OZF', 'OZF_FUND_ASO_ORD_FEEDBACK_FAIL');
               fnd_msg_pub.ADD;
            END IF;
            ozf_utility_pvt.write_conc_log;
            RETURN;
         END IF;
         -- Check return status
         -- if success call adjust_accrual
         --
         IF l_return_status = fnd_api.g_ret_sts_success THEN
            IF (l_line_adj_tbl.COUNT <> 0) THEN
               IF g_debug_flag = 'Y' THEN
                  ozf_utility_pvt.write_conc_log ('ADJUSTMENT ');
               END IF;

               adjust_accrual (
                  p_api_version=> 1.0
                 ,p_init_msg_list=> fnd_api.g_true
                 ,x_return_status=> l_return_status
                 ,x_msg_count=> l_msg_count
                 ,x_msg_data=> l_msg_data
                 ,p_line_adj_tbl=> l_line_adj_tbl
                 ,p_old_line_adj_tbl=> l_old_line_adj_tbl
                 ,p_header_rec=> l_header_rec
               );
               IF g_debug_flag = 'Y' THEN
                  ozf_utility_pvt.write_conc_log (   'ADJUSTMENT STATUS ' || l_return_status);
               END IF;
            END IF;
         END IF;
         --l_return_status := fnd_api.g_ret_sts_success;
         IF l_return_status = fnd_api.g_ret_sts_success THEN
            IF (l_line_tbl.COUNT <> 0) THEN
               IF g_debug_flag = 'Y' THEN
                  ozf_utility_pvt.write_conc_log ('LINE');
               END IF;
               adjust_changed_order (
                  p_api_version=> 1.0
                 ,p_init_msg_list=> fnd_api.g_true
                 ,x_return_status=> l_return_status
                 ,x_msg_count=> l_msg_count
                 ,x_msg_data=> l_msg_data
                 ,p_header_rec=> l_header_rec
                 ,p_old_header_rec=> l_old_header_rec
                 ,p_line_tbl=> l_line_tbl
                 ,p_old_line_tbl=> l_old_line_tbl
               );
               IF g_debug_flag = 'Y' THEN
                  ozf_utility_pvt.write_conc_log (                 'LINE STATUS '          || l_return_status       );
               END IF;
            END IF;
         END IF;
       -- Call to Volume Offer adjustment.
        --

         IF l_no_more_messages = 'T' THEN
            ozf_utility_pvt.write_conc_log (   'NO MORE MESSAGES IN THE QUEUE ' || l_no_more_messages);
         END IF;
         --
         -- Check return status of functional process,
         -- rollback to undo processing
         -- if not success write the error message to the log file

         IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
            --fnd_file.put_line(--fnd_file.log, 'before writinf concurrenct log '||l_return_status);
            ozf_utility_pvt.write_conc_log ('D: Error in one of the process');

            ROLLBACK TO get_message_loop_savepoint;
            x_retcode                  := 1;
            x_errbuf                   := l_msg_data;
         END IF;

         IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
            /*Enqueue the failed message into the Order Feedback Exception Queue. This data
            can be dequeued subsequently by using the GET_EXCEPTION API */
            IF g_debug_flag = 'Y' THEN
               ozf_utility_pvt.write_conc_log ('In handle queue exception ');
            END IF;
            aso_order_feedback_pub.handle_exception (
               p_api_version=> 1.0,
               p_init_msg_list=> fnd_api.g_false,
               p_commit=> fnd_api.g_false,
               x_return_status=> l_return_status,
               x_msg_count=> l_msg_count,
               x_msg_data=> l_msg_data,
               p_app_short_name=> 'OZF',
               p_header_rec=> l_header_rec,
               p_old_header_rec=> l_old_header_rec,
               p_header_adj_tbl=> l_header_adj_tbl,
               p_old_header_adj_tbl=> l_old_header_adj_tbl,
               p_header_price_att_tbl=> l_header_price_att_tbl,
               p_old_header_price_att_tbl=> l_old_header_price_att_tbl,
               p_header_adj_att_tbl=> l_header_adj_att_tbl,
               p_old_header_adj_att_tbl=> l_old_header_adj_att_tbl,
               p_header_adj_assoc_tbl=> l_header_adj_assoc_tbl,
               p_old_header_adj_assoc_tbl=> l_old_header_adj_assoc_tbl,
               p_header_scredit_tbl=> l_header_scredit_tbl,
               p_old_header_scredit_tbl=> l_old_header_scredit_tbl,
               p_line_tbl=> l_line_tbl,
               p_old_line_tbl=> l_old_line_tbl,
               p_line_adj_tbl=> l_line_adj_tbl,
               p_old_line_adj_tbl=> l_old_line_adj_tbl,
               p_line_price_att_tbl=> l_line_price_att_tbl,
               p_old_line_price_att_tbl=> l_old_line_price_att_tbl,
               p_line_adj_att_tbl=> l_line_adj_att_tbl,
               p_old_line_adj_att_tbl=> l_old_line_adj_att_tbl,
               p_line_adj_assoc_tbl=> l_line_adj_assoc_tbl,
               p_old_line_adj_assoc_tbl=> l_old_line_adj_assoc_tbl,
               p_line_scredit_tbl=> l_line_scredit_tbl,
               p_old_line_scredit_tbl=> l_old_line_scredit_tbl,
               p_lot_serial_tbl=> l_lot_serial_tbl,
               p_old_lot_serial_tbl=> l_old_lot_serial_tbl,
               p_action_request_tbl=> l_action_request_tbl
            );
         END IF;
         -- Quit the procedure IF the queue is empty
         ozf_utility_pvt.write_conc_log (' /*************************** END OF QUEUE MESSAGE  *************************/');

         EXIT WHEN l_return_status = fnd_api.g_ret_sts_unexp_error;
         EXIT WHEN l_no_more_messages = fnd_api.g_true;
         l_que_msg_count := l_que_msg_count + 1 ;
         EXIT WHEN l_que_msg_count = g_message_count; --nirprasa, added for bug 8435487 FP of bug 8218560
         IF l_return_status = fnd_api.g_ret_sts_success THEN
            COMMIT;
            x_retcode                  := 0;
         END IF;
         EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO get_message_loop_savepoint;
            ozf_utility_pvt.write_conc_log('FALIED');
            ozf_utility_pvt.write_conc_log;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO get_message_loop_savepoint;
            ozf_utility_pvt.write_conc_log('FALIED');
            ozf_utility_pvt.write_conc_log;

        WHEN OTHERS THEN
            ROLLBACK TO get_message_loop_savepoint;
            ozf_utility_pvt.write_conc_log('FAILED');
            IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
               FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
               FND_MESSAGE.Set_Token('TEXT',sqlerrm);
               FND_MSG_PUB.Add;
            END IF;
            ozf_utility_pvt.write_conc_log;

         END;
      END LOOP message_loop;

      ozf_utility_pvt.write_conc_log ('QUEUE PROCESSED '|| to_char(l_que_msg_count) || ' MESSAGES ');
      -- move except message from begining to last to fix issue for double creating accrual when same messsages
      -- in both exception queue and normal queue. by feliu on 12/30/2005
      IF p_run_exception = 'Y' THEN

         ozf_utility_pvt.write_conc_log ('START Exception Message ....... '|| x_retcode);

         ozf_utility_pvt.write_conc_log ('<====EXCEPTION QUEUE START TIME '||to_char( SYSDATE ,'DD/MM/RR HH:MI:SS A.M. ')||' ====>');

         get_exception_message(x_errbuf , x_retcode);

         ozf_utility_pvt.write_conc_log ('END Exception Message Return Code'|| x_retcode);

         ozf_utility_pvt.write_conc_log ('<====EXCEPTION QUEUE END TIME '||to_char( SYSDATE ,'DD/MM/RR HH:MI:SS A.M. ')||' ====>');

      END IF;


   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
        ozf_utility_pvt.write_conc_log ('QUEUE PROCESSED ' ||to_char(l_que_msg_count) ||'MESSAGES' );
        x_retcode := 1;
      WHEN fnd_api.g_exc_unexpected_error THEN
        ozf_utility_pvt.write_conc_log ('QUEUE PROCESSED ' ||to_char(l_que_msg_count) || 'MESSAGES' );
        x_retcode := 1;
      WHEN OTHERS THEN
        ozf_utility_pvt.write_conc_log ('QUEUE PROCESSED '|| to_char(l_que_msg_count) ||'MESSAGES' );
        x_retcode := 1;

   END get_message;
   ------------------------------------------------------------------------------
-- Procedure Name
--   Get_Exception_Message
-- Purpose
--   This procedure collects order updates FROM the Order Capture NotIFication
--   API. Started FROM a concurrent process, it is a loop which
--   gets the latest notIFication off of the queue.
--
-- History
--   4/30/2002 mpande Created
------------------------------------------------------------------------------
   PROCEDURE get_exception_message (x_errbuf OUT NOCOPY VARCHAR2,
                                    x_retcode OUT NOCOPY NUMBER
   )  IS
      l_return_status              VARCHAR2 (1);
      l_process_audit_id           NUMBER;
      l_msg_count                  NUMBER;
      l_msg_data                   VARCHAR2 (2000);
      l_no_more_messages           VARCHAR2 (1);
      l_header_id                  NUMBER;
      l_booked_flag                VARCHAR2 (1);
      l_header_rec                 oe_order_pub.header_rec_type;
      l_old_header_rec             oe_order_pub.header_rec_type;
      l_header_adj_tbl             oe_order_pub.header_adj_tbl_type;
      l_old_header_adj_tbl         oe_order_pub.header_adj_tbl_type;
      l_header_price_att_tbl       oe_order_pub.header_price_att_tbl_type;
      l_old_header_price_att_tbl   oe_order_pub.header_price_att_tbl_type;
      l_header_adj_att_tbl         oe_order_pub.header_adj_att_tbl_type;
      l_old_header_adj_att_tbl     oe_order_pub.header_adj_att_tbl_type;
      l_header_adj_assoc_tbl       oe_order_pub.header_adj_assoc_tbl_type;
      l_old_header_adj_assoc_tbl   oe_order_pub.header_adj_assoc_tbl_type;
      l_header_scredit_tbl         oe_order_pub.header_scredit_tbl_type;
      l_old_header_scredit_tbl     oe_order_pub.header_scredit_tbl_type;
      l_line_tbl                   oe_order_pub.line_tbl_type;
      l_old_line_tbl               oe_order_pub.line_tbl_type;
      l_line_adj_tbl               oe_order_pub.line_adj_tbl_type;
      l_old_line_adj_tbl           oe_order_pub.line_adj_tbl_type;
      l_line_price_att_tbl         oe_order_pub.line_price_att_tbl_type;
      l_old_line_price_att_tbl     oe_order_pub.line_price_att_tbl_type;
      l_line_adj_att_tbl           oe_order_pub.line_adj_att_tbl_type;
      l_old_line_adj_att_tbl       oe_order_pub.line_adj_att_tbl_type;
      l_line_adj_assoc_tbl         oe_order_pub.line_adj_assoc_tbl_type;
      l_old_line_adj_assoc_tbl     oe_order_pub.line_adj_assoc_tbl_type;
      l_line_scredit_tbl           oe_order_pub.line_scredit_tbl_type;
      l_old_line_scredit_tbl       oe_order_pub.line_scredit_tbl_type;
      l_lot_serial_tbl             oe_order_pub.lot_serial_tbl_type;
      l_old_lot_serial_tbl         oe_order_pub.lot_serial_tbl_type;
      l_action_request_tbl         oe_order_pub.request_tbl_type;
      l_index   NUMBER;
      l_mode                       VARCHAR2(30):= DBMS_AQ.BROWSE;
      l_navigation                 VARCHAR2 (30) := DBMS_AQ.FIRST_MESSAGE;

   BEGIN
      -- Standard Start of process savepoint
      -- Start looping to check for messages in the queue
      fnd_msg_pub.initialize;
      SAVEPOINT get_message_savepoint;
      -- dequeue the exception queue
      <<exception_loop>>
      LOOP
         ozf_utility_pvt.write_conc_log ('In Queue Exception ');

         -- Queue savepoint for standard advanced queue error handling
         BEGIN
         SAVEPOINT get_excep_loop_savepoint;
         --
         -- Invoke Get_Mesage to dequeue queue payload and return Order data
         --
         aso_order_feedback_pub.get_exception (
            p_api_version=> 1.0,
            x_return_status=> l_return_status,
            x_msg_count=> l_msg_count,
            x_msg_data=> l_msg_data,
            p_app_short_name=> 'OZF', -- need to be resolved , wether it is AMS or OZF
            p_dequeue_mode  => l_mode,
            p_navigation   => l_navigation ,
            x_no_more_messages=> l_no_more_messages,
            x_header_rec=> l_header_rec,
            x_old_header_rec=> l_old_header_rec,
            x_header_adj_tbl=> l_header_adj_tbl,
            x_old_header_adj_tbl=> l_old_header_adj_tbl,
            x_header_price_att_tbl=> l_header_price_att_tbl,
            x_old_header_price_att_tbl=> l_old_header_price_att_tbl,
            x_header_adj_att_tbl=> l_header_adj_att_tbl,
            x_old_header_adj_att_tbl=> l_old_header_adj_att_tbl,
            x_header_adj_assoc_tbl=> l_header_adj_assoc_tbl,
            x_old_header_adj_assoc_tbl=> l_old_header_adj_assoc_tbl,
            x_header_scredit_tbl=> l_header_scredit_tbl,
            x_old_header_scredit_tbl=> l_old_header_scredit_tbl,
            x_line_tbl=> l_line_tbl,
            x_old_line_tbl=> l_old_line_tbl,
            x_line_adj_tbl=> l_line_adj_tbl,
            x_old_line_adj_tbl=> l_old_line_adj_tbl,
            x_line_price_att_tbl=> l_line_price_att_tbl,
            x_old_line_price_att_tbl=> l_old_line_price_att_tbl,
            x_line_adj_att_tbl=> l_line_adj_att_tbl,
            x_old_line_adj_att_tbl=> l_old_line_adj_att_tbl,
            x_line_adj_assoc_tbl=> l_line_adj_assoc_tbl,
            x_old_line_adj_assoc_tbl=> l_old_line_adj_assoc_tbl,
            x_line_scredit_tbl=> l_line_scredit_tbl,
            x_old_line_scredit_tbl=> l_old_line_scredit_tbl,
            x_lot_serial_tbl=> l_lot_serial_tbl,
            x_old_lot_serial_tbl=> l_old_lot_serial_tbl,
            x_action_request_tbl=> l_action_request_tbl
         );
         --
         --ozf_utility_pvt.debug_message('l_return_status  ='||l_return_status );
         --///added by mpande to write a error message to the list
         --if not sucess add a error message to th emessage list
         IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
             IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name ('OZF', 'OZF_FUND_ASO_ORD_FEEDBACK_FAIL');
               fnd_msg_pub.ADD;
            END IF;
            ozf_utility_pvt.write_conc_log;
            RETURN;
         END IF;
         -- Check return status
         -- if success call adjust_accrual
         --
         IF l_return_status = fnd_api.g_ret_sts_success THEN
            IF (l_line_adj_tbl.COUNT <> 0) THEN
                ozf_utility_pvt.write_conc_log ('In get exception adjustment');

               adjust_accrual (
                  p_api_version=> 1.0,
                  p_init_msg_list=> fnd_api.g_true,
                  x_return_status=> l_return_status,
                  x_msg_count=> l_msg_count,
                  x_msg_data=> l_msg_data,
                  p_line_adj_tbl=> l_line_adj_tbl,
                  p_old_line_adj_tbl=> l_old_line_adj_tbl,
                  p_header_rec=> l_header_rec,
                  p_exception_queue    => fnd_api.g_true
               );
               ozf_utility_pvt.write_conc_log ('ADJUSTMENT EXCEPTION STATUS'||l_return_status);

            END IF;
         END IF;
         IF l_return_status = fnd_api.g_ret_sts_success THEN
            IF (l_line_tbl.COUNT <> 0) THEN
               ozf_utility_pvt.write_conc_log ('    D: EXCEPTON QUEUE Start processing line');

               adjust_changed_order (
                  p_api_version=> 1.0,
                  p_init_msg_list=> fnd_api.g_true,
                  x_return_status=> l_return_status,
                  x_msg_count=> l_msg_count,
                  x_msg_data=> l_msg_data,
                  p_header_rec=> l_header_rec,
                  p_old_header_rec=> l_old_header_rec,
                  p_line_tbl=> l_line_tbl,
                  p_old_line_tbl=> l_old_line_tbl
               );
               ozf_utility_pvt.write_conc_log ('    D: EXCEPTION QUEUE PROCESSING LINE RETURNS STATUS'||l_return_status);

            END IF;
         END IF;

         IF l_no_more_messages = 'T' THEN
            ozf_utility_pvt.write_conc_log (   'NO MORE MESSAGES IN THE QUEUE '
                                         || l_no_more_messages);
         END IF;
         -- write_conc_log;
         --
         -- Check return status of functional process,
         -- rollback to undo processing
         -- if not success write the error message to the log file
         IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
            l_navigation  := DBMS_AQ.NEXT_MESSAGE;
            ROLLBACK TO get_excep_loop_savepoint;
            --x_retcode                  := 1;
            x_errbuf                   := l_msg_data;
         END IF;
         -- Quit the procedure IF the queue is empty
         EXIT WHEN l_return_status = fnd_api.g_ret_sts_unexp_error;
         EXIT WHEN l_no_more_messages = fnd_api.g_true;

         IF l_return_status = fnd_api.g_ret_sts_success THEN

            aso_order_feedback_pub.get_exception (
               p_api_version=> 1.0,
               x_return_status=> l_return_status,
               x_msg_count=> l_msg_count,
               x_msg_data=> l_msg_data,
               p_app_short_name=> 'OZF', -- need to be resolved , wether it is AMS or OZF
               p_dequeue_mode  => DBMS_AQ.REMOVE_NODATA,
               p_navigation   => DBMS_AQ.FIRST_MESSAGE,
               x_no_more_messages=> l_no_more_messages,
               x_header_rec=> l_header_rec,
               x_old_header_rec=> l_old_header_rec,
               x_header_adj_tbl=> l_header_adj_tbl,
               x_old_header_adj_tbl=> l_old_header_adj_tbl,
               x_header_price_att_tbl=> l_header_price_att_tbl,
               x_old_header_price_att_tbl=> l_old_header_price_att_tbl,
               x_header_adj_att_tbl=> l_header_adj_att_tbl,
               x_old_header_adj_att_tbl=> l_old_header_adj_att_tbl,
               x_header_adj_assoc_tbl=> l_header_adj_assoc_tbl,
               x_old_header_adj_assoc_tbl=> l_old_header_adj_assoc_tbl,
               x_header_scredit_tbl=> l_header_scredit_tbl,
               x_old_header_scredit_tbl=> l_old_header_scredit_tbl,
               x_line_tbl=> l_line_tbl,
               x_old_line_tbl=> l_old_line_tbl,
               x_line_adj_tbl=> l_line_adj_tbl,
               x_old_line_adj_tbl=> l_old_line_adj_tbl,
               x_line_price_att_tbl=> l_line_price_att_tbl,
               x_old_line_price_att_tbl=> l_old_line_price_att_tbl,
               x_line_adj_att_tbl=> l_line_adj_att_tbl,
               x_old_line_adj_att_tbl=> l_old_line_adj_att_tbl,
               x_line_adj_assoc_tbl=> l_line_adj_assoc_tbl,
               x_old_line_adj_assoc_tbl=> l_old_line_adj_assoc_tbl,
               x_line_scredit_tbl=> l_line_scredit_tbl,
               x_old_line_scredit_tbl=> l_old_line_scredit_tbl,
               x_lot_serial_tbl=> l_lot_serial_tbl,
               x_old_lot_serial_tbl=> l_old_lot_serial_tbl,
               x_action_request_tbl=> l_action_request_tbl
            );

            --added for bug 8435487
            IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
               IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
                  fnd_message.set_name ('OZF', 'OZF_FUND_ASO_ORD_FEEDBACK_FAIL');
                  fnd_msg_pub.ADD;
               END IF;
                  ozf_utility_pvt.write_conc_log('again exception happened');
               RETURN;
            ELSE
                l_navigation := DBMS_AQ.FIRST_MESSAGE ;
                COMMIT;
                x_retcode                  := 0;
            END IF;
         ELSE
            ozf_utility_pvt.write_conc_log;
            FND_MSG_PUB.INITIALIZE;
         END IF;
         EXCEPTION
         WHEN FND_API.G_EXC_ERROR THEN
            ROLLBACK TO get_excep_loop_savepoint;
            ozf_utility_pvt.write_conc_log('FALIED');
            ozf_utility_pvt.write_conc_log;

        WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO get_excep_loop_savepoint;
            ozf_utility_pvt.write_conc_log('FALIED');
            ozf_utility_pvt.write_conc_log;

        WHEN OTHERS THEN
            ROLLBACK TO get_excep_loop_savepoint;
            ozf_utility_pvt.write_conc_log('FAILED');
            IF FND_MSG_PUB.Check_Msg_level (FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
               FND_MESSAGE.Set_Name('OZF','OZF_API_DEBUG_MESSAGE');
               FND_MESSAGE.Set_Token('TEXT',sqlerrm);
               FND_MSG_PUB.Add;
            END IF;
            ozf_utility_pvt.write_conc_log;
         END;
      END LOOP exception_loop;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_retcode                  := 1;
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_retcode                  := 1;
      WHEN OTHERS THEN
         x_retcode                  := 1;
   END get_exception_message;


   PROCEDURE reprocess_failed_gl_posting (x_errbuf  OUT NOCOPY VARCHAR2,
                                          x_retcode OUT NOCOPY NUMBER);
   PROCEDURE post_offinvoice_to_gl(x_errbuf  OUT NOCOPY VARCHAR2,
                                   x_retcode OUT NOCOPY NUMBER);

------------------------------------------------------------------------------
-- Procedure Name
--   Accrue_offers
-- Purpose
--   This procedure performs accruals for all offers for the folow
--   1) Order Managemnt Accruals
--   2) Backdating Adjustment
--   3) Volume Offer Backdating
--   4) reprocess all utilizations whose postings to GL have failed
-- History
--   7/22/2002  mpande Created
--   03/19/2003 yzhao  added parameter p_run_unposted_gl to post unposted accruals to GL
--                       'N' do not process failed GL postings  -- DEFAULT
--                       'Y' reprocess all failed GL postings
------------------------------------------------------------------------------
   PROCEDURE Accrue_offers (x_errbuf OUT NOCOPY VARCHAR2,
                            x_retcode OUT NOCOPY NUMBER,
                            p_run_exception IN VARCHAR2 := 'N',
                            p_run_backdated_adjustment IN VARCHAR2 := 'N',
                            p_run_volume_off_adjustment IN VARCHAR2 := 'N',
                            p_run_unposted_gl IN VARCHAR2 := 'N',
                            p_process_message_count IN NUMBER, --added for bug 8435487
                            p_debug IN VARCHAR2    := 'N' )    IS
   BEGIN
     g_debug_flag := p_debug;
     g_message_count := NVL(p_process_message_count,-1);
     G_FAE_START_DATE := TRUNC(sysdate);

     ozf_utility_pvt.write_conc_log (' <===> ORDER MANAGEMENT ACCRUALS BEGIN  <===>');
     ozf_utility_pvt.write_conc_log (' <===> g_message_count <===>'||g_message_count);

     ozf_utility_pvt.write_conc_log ('<====ORDER MANAGEMENT ACCRUALS BEGIN TIME '||to_char( SYSDATE ,'DD/MM/RR HH:MI:SS A.M. ')||' ====>');

     get_message( x_errbuf,
                  x_retcode,
                  p_run_exception,
                  p_debug );

     ozf_utility_pvt.write_conc_log ('<====ORDER MANAGEMENT ACCRUALS END TIME '||to_char( SYSDATE ,'DD/MM/RR HH:MI:SS A.M. ')||' ====>');

     ozf_utility_pvt.write_conc_log (' x_retcode '||x_retcode||'x_errbuf'||x_errbuf);

     ozf_utility_pvt.write_conc_log ('<===> ORDER MANAGEMENT ACCRUALS END  <===>');

     IF p_run_backdated_adjustment = 'Y' OR p_run_volume_off_adjustment = 'Y' THEN
        ozf_utility_pvt.write_conc_log ('<===> BACKDATED ADJUSTMENT BEGIN  <===>');
        ozf_utility_pvt.write_conc_log ('<====BACKDATED ADJUSTMENT BEGIN TIME '||to_char( SYSDATE ,'DD/MM/RR HH:MI:SS A.M. ')||' ====>');

     -- start backdated Adjustment only
        ozf_adjustment_ext_pvt.adjust_backdated_offer(
                         x_errbuf,
                         x_retcode,
                         p_debug );
        ozf_utility_pvt.write_conc_log ('<====BACKDATED ADJUSTMENT END TIME '||to_char( SYSDATE ,'DD/MM/RR HH:MI:SS A.M. ')||' ====>');

        ozf_utility_pvt.write_conc_log (' BACKDATE ADJUSTMENT x_retcode '||x_retcode||'x_errbuf'||x_errbuf);

        ozf_utility_pvt.write_conc_log ('<===> BACKDATED ADJUSTMENT END <===> ');

     END IF;

     ozf_utility_pvt.write_conc_log ('<===> POST OFFINVOICE UTILIZATION TO GL BEGIN  <===>');
     ozf_utility_pvt.write_conc_log ('<====POST OFFINVOICE UTILIZATION TO GL BEGIN TIME '||to_char( SYSDATE ,'DD/MM/RR HH:MI:SS A.M. ')||' ====>');

     post_offinvoice_to_gl(x_errbuf, x_retcode);

     ozf_utility_pvt.write_conc_log ('<====POST OFFINVOICE UTILIZATION TO GL END TIME '||to_char( SYSDATE ,'DD/MM/RR HH:MI:SS A.M. ')||' ====>');
     ozf_utility_pvt.write_conc_log ('<===> POST OFFINVOICE UTILIZATION TO GL END  <===>');

     IF p_run_volume_off_adjustment = 'Y' THEN
        ozf_utility_pvt.write_conc_log ('<===> VOLUME OFFER ADJUSTMENT BEGIN <=== >');
        ozf_utility_pvt.write_conc_log ('<====VOLUME OFFER ADJUSTMENT BEGIN TIME '||to_char( SYSDATE ,'DD/MM/RR HH:MI:SS A.M. ')||' ====>');

        ozf_adjustment_ext_pvt.adjust_volume_offer(
                         x_errbuf,
                         x_retcode,
                         p_debug);
       ozf_utility_pvt.write_conc_log ('<====VOLUME OFFER ADJUSTMENT END TIME '||to_char( SYSDATE ,'DD/MM/RR HH:MI:SS A.M. ')||' ====>');
       ozf_utility_pvt.write_conc_log (' x_retcode '||x_retcode||'x_errbuf'||x_errbuf);

        ozf_utility_pvt.write_conc_log ('<===> VOLUME OFFER ADJUSTMENT END  <===>');
     END IF;

     IF p_run_unposted_gl = 'Y' THEN
        ozf_utility_pvt.write_conc_log ('<===> REPROCESS ALL FAILED GL POSTING BEGIN <=== >');
        ozf_utility_pvt.write_conc_log ('<====REPROCESS ALL FAILED GL POSTING BEGIN TIME '||to_char( SYSDATE ,'DD/MM/RR HH:MI:SS A.M. ')||' ====>');

        reprocess_failed_gl_posting(
                         x_errbuf,
                         x_retcode);
        ozf_utility_pvt.write_conc_log ('<====REPROCESS ALL FAILED GL POSTING END TIME '||to_char( SYSDATE ,'DD/MM/RR HH:MI:SS A.M. ')||' ====>');

        ozf_utility_pvt.write_conc_log (' REPROCESS_FAILED_GL_POSTING x_retcode='||x_retcode||' x_errbuf='||x_errbuf);
        ozf_utility_pvt.write_conc_log ('<===> REPROCESS ALL FAILED GL POSTING END  <===>');

     END IF;

     G_FAE_START_DATE := NULL;
   END Accrue_offers;


------------------------------------------------------------------------------
-- Procedure Name
--   post_accrual_to_gl
-- Purpose
--   This procedure posts accrual to GL
-- History
--   03/19/2003  Ying Zhao Created
------------------------------------------------------------------------------
   PROCEDURE post_accrual_to_gl(
      p_util_utilization_id         IN              NUMBER,
      p_util_object_version_number  IN              NUMBER,
      p_util_amount                 IN              NUMBER,
      p_util_plan_type              IN              VARCHAR2,
      p_util_plan_id                IN              NUMBER,
      p_util_plan_amount            IN              NUMBER,
      p_util_utilization_type       IN              VARCHAR2,
      p_util_fund_id                IN              NUMBER,
      p_util_acctd_amount           IN              NUMBER,
      p_adjust_paid_flag            IN              BOOLEAN  := false,
      p_util_org_id                 IN              NUMBER := NULL,
      x_gl_posted_flag              OUT NOCOPY      VARCHAR2,
      x_return_status               OUT NOCOPY      VARCHAR2,
      x_msg_count                   OUT NOCOPY      NUMBER,
      x_msg_data                    OUT NOCOPY      VARCHAR2
     )
   IS
     l_gl_posted_flag               VARCHAR2(1) := G_GL_FLAG_NO;
     l_event_id                     NUMBER;
     l_return_status                VARCHAR2(1);
     l_tmp_number                   NUMBER;
     l_acctd_amt                    NUMBER;
     l_paid_amt                     NUMBER;
     l_rollup_paid_amt              NUMBER;
     l_new_univ_amt                 NUMBER;
     l_currency_code                VARCHAR2(30);
     -- l_mc_col_8                     NUMBER;
     l_parent_fund_id               NUMBER;
     -- l_mc_record_id                 NUMBER;
     l_obj_num                      NUMBER;
     l_rate                         NUMBER;
     l_objfundsum_rec               ozf_objfundsum_pvt.objfundsum_rec_type := NULL;
     l_event_type_code              VARCHAR2(30);
     l_adjustment_type              VARCHAR2(1);
     l_orig_amt                     NUMBER;
     l_rollup_orig_amt              NUMBER;
     l_off_invoice_gl_post_flag    VARCHAR2(1);
     l_earned_amt  NUMBER;
     l_rollup_earned_amt  NUMBER;
     l_liability_flag     VARCHAR2(1);
     l_accrual_basis   VARCHAR2(30);
     l_exchange_rate_type          VARCHAR2(30) := FND_API.G_MISS_CHAR; --nirprasa

      --nirprasa, added for bug 7030415.
     CURSOR c_get_conversion_type( p_org_id   IN   NUMBER) IS
        SELECT exchange_rate_type
        FROM   ozf_sys_parameters_all
        WHERE  org_id = p_org_id;

     CURSOR c_get_fund (p_fund_id IN NUMBER) IS
       SELECT  object_version_number, parent_fund_id, currency_code_tc,liability_flag,accrual_basis
       FROM    ozf_funds_all_b
       WHERE   fund_id = p_fund_id;

     /* R12: yzhao bug 4669269 - obsolete ozf_mc_transactions
     CURSOR c_mc_trans(p_fund_id IN NUMBER) IS
         SELECT mc_record_id
               ,object_version_number
         FROM ozf_mc_transactions_all
         WHERE source_object_name ='FUND'
         AND source_object_id = p_fund_id;
      */

     CURSOR c_parent (p_fund_id IN NUMBER)IS
        SELECT fund_id
              ,object_version_number
        FROM ozf_funds_all_b
        connect by prior  parent_fund_id =fund_id
        start with fund_id =  p_fund_id;

     -- rimehrot: for R12 update ozf_object_fund_summary table
     CURSOR c_get_objfundsum_rec(p_object_type IN VARCHAR2, p_object_id IN NUMBER, p_fund_id IN NUMBER) IS
         SELECT objfundsum_id
              , object_version_number
              , earned_amt
              , paid_amt
              , plan_curr_earned_amt
              , plan_curr_paid_amt
              , univ_curr_earned_amt
              , univ_curr_paid_amt
        FROM   ozf_object_fund_summary
        WHERE  object_type = p_object_type
        AND    object_id = p_object_id
        AND    fund_id = p_fund_id;

      CURSOR c_offinv_flag(p_org_id IN NUMBER) IS
        SELECT  NVL(sob.gl_acct_for_offinv_flag, 'F')
        FROM    ozf_sys_parameters_all sob
        WHERE   sob.org_id = p_org_id;

   BEGIN
     SAVEPOINT  post_accrual_to_gl_sp;

      IF g_debug_flag = 'Y' THEN
         ozf_utility_pvt.write_conc_log ('    D: post_accrual_to_gl() BEGIN posting to GL for utilization id ' ||
                     p_util_utilization_id ||
                     ' object_version_number=' || p_util_object_version_number ||
                     ' amount=' || p_util_amount ||
                     ' plan_type=' || p_util_plan_type ||
                     ' utilization_type=' || p_util_utilization_type ||
                     ' util_fund_id=' || p_util_fund_id ||
                     ' acctd_amount=' || p_util_acctd_amount
                     );
      END IF;

     IF p_util_plan_type IN ( 'OFFR' , 'PRIC')  THEN         -- yzhao: 10/20/2003 PRICE_LIST is changed to PRIC
        -- moved from  IF  l_gl_posted_flag IN(G_GL_FLAG_YES,G_GL_FLAG_NULL,G_GL_FLAG_NOLIAB) THEN
        -- to fix bug 5128552
        OPEN c_get_fund(p_util_fund_id);
        FETCH c_get_fund INTO l_obj_num, l_parent_fund_id, l_currency_code, l_liability_flag,l_accrual_basis;
        CLOSE c_get_fund;

        -- yzhao: 11/25/2003 11.5.10 post gl for off invoice discount
         IF p_util_utilization_type IN ('ACCRUAL', 'LEAD_ACCRUAL', 'ADJUSTMENT', 'LEAD_ADJUSTMENT', 'UTILIZED','SALES_ACCRUAL') THEN
           IF  p_util_utilization_type IN ('ACCRUAL', 'LEAD_ACCRUAL') THEN
	       --//ER 9382547
               --l_event_type_code := 'ACCRUAL';
	       l_event_type_code := 'ACCRUAL_CREATION';

              IF l_accrual_basis = 'CUSTOMER' AND NVL(l_liability_flag,'N')= 'N' THEN
                 l_gl_posted_flag := G_GL_FLAG_NOLIAB;
              END IF;
           ELSIF p_util_utilization_type = 'UTILIZED' THEN
              OPEN c_offinv_flag(p_util_org_id);
              FETCH c_offinv_flag INTO l_off_invoice_gl_post_flag;
              CLOSE c_offinv_flag;

              IF l_off_invoice_gl_post_flag = 'F' THEN
                 l_gl_posted_flag := G_GL_FLAG_NULL;
              ELSE
                 --l_event_type_code := 'OFF_INVOICE';
		 l_event_type_code := 'INVOICE_DISCOUNT';
              END IF;
           ELSIF p_util_utilization_type = 'SALES_ACCRUAL' THEN
              l_gl_posted_flag := G_GL_FLAG_NOLIAB;
           ELSE
	     --Adjustments
              l_event_type_code   := 'ACCRUAL_ADJUSTMENT';
           END IF;

           --//ER 9382547
           /*
	   IF NVL(p_util_amount,0) >= 0 THEN
              l_adjustment_type   := 'P'; -- positive
           ELSE
              l_adjustment_type   := 'N'; -- negetive adjustment
           END IF;
           */

          IF  l_gl_posted_flag = G_GL_FLAG_NO THEN
             OZF_GL_INTERFACE_PVT.Post_Accrual_To_GL (
                p_api_version       => 1.0
               ,p_init_msg_list     => fnd_api.g_false
               ,p_commit            => fnd_api.g_false
               ,p_validation_level  => fnd_api.g_valid_level_full

               ,p_utilization_id    =>  p_util_utilization_id
               ,p_event_type_code   => l_event_type_code

               ,x_return_status     => l_return_status
               ,x_msg_data          => x_msg_data
               ,x_msg_count         => x_msg_count
             );

             IF g_debug_flag = 'Y' THEN
                ozf_utility_pvt.write_conc_log ('   D: post_accrual_to_gl() create_gl_entry for utilization id '
                                   || p_util_utilization_id || ' returns ' || l_return_status);
             END IF;

             IF l_return_status = fnd_api.g_ret_sts_success THEN
                l_gl_posted_flag := G_GL_FLAG_YES;  -- 'Y';
             ELSE
              -- do not raise exception for gl posting error. Just mark it as failed and deal with it later
                l_gl_posted_flag := G_GL_FLAG_FAIL;  -- 'F';
              -- 07/17/2003 yzhao: log error message
                fnd_msg_pub.count_and_get (
                    p_count    => x_msg_count,
                    p_data     => x_msg_data,
                    p_encoded  => fnd_api.g_false
                 );
                ozf_utility_pvt.write_conc_log('   /****** Failed to post to GL ******/ for utilization id ' || p_util_utilization_id);

                ozf_utility_pvt.write_conc_log;
                fnd_msg_pub.initialize;
              END IF;

           END IF; --l_gl_posted_flag = G_GL_FLAG_NO

           -- update utilization gl_posted_flag directly to avoid all validations
           UPDATE ozf_funds_utilized_all_b
           SET last_update_date = SYSDATE
                , last_updated_by = NVL (fnd_global.user_id, -1)
                , last_update_login = NVL (fnd_global.conc_login_id, -1)
                , object_version_number = p_util_object_version_number + 1
                , gl_posted_flag = l_gl_posted_flag
                --, gl_date = sysdate
            WHERE utilization_id = p_util_utilization_id
            AND   object_version_number = p_util_object_version_number;

            IF  l_gl_posted_flag IN(G_GL_FLAG_YES,G_GL_FLAG_NULL,G_GL_FLAG_NOLIAB) THEN

              IF g_universal_currency IS NULL THEN
                 IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                    fnd_message.set_name('OZF', 'OZF_UNIV_CURR_NOT_FOUND');
                     fnd_msg_pub.add;
                  END IF;
                  RAISE fnd_api.g_exc_error;
              END IF;

              --Added for bug 7030415
                OPEN c_get_conversion_type(p_util_org_id);
                FETCH c_get_conversion_type INTO l_exchange_rate_type;
                CLOSE c_get_conversion_type;

                IF g_debug_flag = 'Y' THEN
                        ozf_utility_pvt.write_conc_log('**************************START****************************');
                        ozf_utility_pvt.write_conc_log('post_accrual_to_gl' ||' From Amount p_util_amount: '||p_util_amount );
                        ozf_utility_pvt.write_conc_log('post_accrual_to_gl' ||' From Curr l_currency_code: '||l_currency_code );
                        ozf_utility_pvt.write_conc_log('post_accrual_to_gl' ||' To Curr g_universal_currency: '|| g_universal_currency);
                        --ozf_utility_pvt.write_conc_log('post_accrual_to_gl' ||' l_exchange_rate_type: '|| l_exchange_rate_type);
                END IF;

              ozf_utility_pvt.convert_currency(
                    x_return_status => l_return_status
                    ,p_from_currency => l_currency_code
                    ,p_to_currency => g_universal_currency
                    ,p_conv_type   => l_exchange_rate_type
                    ,p_from_amount => p_util_amount
                    ,x_to_amount => l_new_univ_amt
                    ,x_rate => l_rate);

              IF g_debug_flag = 'Y' THEN
                ozf_utility_pvt.write_conc_log('post_accrual_to_gl' ||' Converted Amount l_new_univ_amt: '|| l_new_univ_amt);
                ozf_utility_pvt.write_conc_log('Utilization amount is converted from fund curr to universal curr');
                ozf_utility_pvt.write_conc_log('***************************END******************************');
              END IF;

              IF l_return_status = fnd_api.g_ret_sts_error THEN
                 RAISE fnd_api.g_exc_error;
              ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                 RAISE fnd_api.g_exc_unexpected_error;
              END IF;

              IF l_gl_posted_flag = G_GL_FLAG_NOLIAB THEN
                 l_orig_amt := p_util_amount;
                 l_rollup_orig_amt := l_new_univ_amt;
              ELSE
                -- rimehrot changed for R12, Populate new table ozf_object_fund_summary
                 l_objfundsum_rec := NULL;
                 OPEN c_get_objfundsum_rec(p_util_plan_type
                                     , p_util_plan_id
                                     , p_util_fund_id);
                 FETCH c_get_objfundsum_rec INTO l_objfundsum_rec.objfundsum_id
                                           , l_objfundsum_rec.object_version_number
                                           , l_objfundsum_rec.earned_amt
                                           , l_objfundsum_rec.paid_amt
                                           , l_objfundsum_rec.plan_curr_earned_amt
                                           , l_objfundsum_rec.plan_curr_paid_amt
                                           , l_objfundsum_rec.univ_curr_earned_amt
                                           , l_objfundsum_rec.univ_curr_paid_amt;
                 CLOSE c_get_objfundsum_rec;

              -- yzhao: 11/25/2003  11.5.10 need to update budget earned amount for accrual, earned and paid amount for off-invoice discount
                 IF p_util_utilization_type = 'UTILIZED' OR p_adjust_paid_flag THEN
                    l_paid_amt := p_util_amount;
                    l_rollup_paid_amt := l_new_univ_amt;
                   -- l_mc_col_8 := l_acctd_amt;

                    l_objfundsum_rec.paid_amt := NVL(l_objfundsum_rec.paid_amt, 0) + NVL(l_paid_amt, 0);
                    l_objfundsum_rec.plan_curr_paid_amt := NVL(l_objfundsum_rec.plan_curr_paid_amt, 0)
                                                                  + NVL(p_util_plan_amount, 0);
                    l_objfundsum_rec.univ_curr_paid_amt := NVL(l_objfundsum_rec.univ_curr_paid_amt, 0)
                                                                  + NVL(l_rollup_paid_amt, 0);
                 END IF;

                 l_earned_amt := p_util_amount;
                 l_rollup_earned_amt := l_new_univ_amt;

              -- rimehrot: for R12, populate paid/earned columns in ozf_object_fund_summary
              ozf_utility_pvt.write_conc_log('l_objfundsum_rec.earned_amt ' || l_objfundsum_rec.earned_amt);
              ozf_utility_pvt.write_conc_log('p_util_amount ' || p_util_amount);
              ozf_utility_pvt.write_conc_log('l_objfundsum_rec.plan_curr_earned_amt ' || l_objfundsum_rec.plan_curr_earned_amt);
              ozf_utility_pvt.write_conc_log('p_util_plan_amount ' || p_util_plan_amount);
              ozf_utility_pvt.write_conc_log('l_objfundsum_rec.univ_curr_earned_amt ' || l_objfundsum_rec.univ_curr_earned_amt);
              ozf_utility_pvt.write_conc_log('l_new_univ_amt ' || l_new_univ_amt);
                 l_objfundsum_rec.earned_amt := NVL(l_objfundsum_rec.earned_amt, 0) + NVL(p_util_amount, 0);
                 l_objfundsum_rec.plan_curr_earned_amt := NVL(l_objfundsum_rec.plan_curr_earned_amt, 0)
                                                              + NVL(p_util_plan_amount, 0);
                 l_objfundsum_rec.univ_curr_earned_amt := NVL(l_objfundsum_rec.univ_curr_earned_amt, 0)
                                                              + NVL(l_new_univ_amt, 0);
                 --rimehrot, for R12
                 ozf_objfundsum_pvt.update_objfundsum(
                       p_api_version                => 1.0,
                       p_init_msg_list              => Fnd_Api.G_FALSE,
                       p_validation_level           => Fnd_Api.G_VALID_LEVEL_NONE,
                       p_objfundsum_rec             => l_objfundsum_rec,
                       x_return_status              => l_return_status,
                       x_msg_count                  => x_msg_count,
                       x_msg_data                   => x_msg_data
                    );
                 IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                   RAISE fnd_api.g_exc_unexpected_error;
                 ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
                   RAISE fnd_api.g_exc_error;
                 END IF;
              -- end R12 changes

              END IF; -- p_util_utilization_type = 'SALES_ACCRUAL'

              UPDATE ozf_funds_all_b
              SET    original_budget = NVL(original_budget, 0) + NVL(l_orig_amt, 0)
                    ,rollup_original_budget = NVL(rollup_original_budget, 0) + NVL(l_rollup_orig_amt, 0)
                    ,earned_amt = NVL(earned_amt, 0) + NVL(l_earned_amt, 0)
                    ,paid_amt = NVL(paid_amt, 0 ) + NVL(l_paid_amt, 0)
                    ,rollup_earned_amt = NVL(rollup_earned_amt, 0) +  NVL(l_rollup_earned_amt, 0)
                    ,rollup_paid_amt = NVL(rollup_paid_amt, 0) + NVL(l_rollup_paid_amt, 0)
                    ,object_version_number = l_obj_num + 1
              WHERE fund_id =  p_util_fund_id
              AND   object_version_number = l_obj_num;

              IF l_parent_fund_id is NOT NULL THEN
                 FOR fund IN c_parent(l_parent_fund_id)
                 LOOP
                      UPDATE ozf_funds_all_b
                      SET object_version_number = fund.object_version_number + 1
                         ,rollup_earned_amt = NVL(rollup_earned_amt,0) + NVL(l_new_univ_amt,0)
                         ,rollup_paid_amt = NVL(rollup_paid_amt,0) + NVL(l_rollup_paid_amt,0)
                         ,rollup_original_budget = NVL(rollup_original_budget,0) + NVL(l_rollup_orig_amt,0)
                      WHERE fund_id = fund.fund_id
                      AND object_version_number = fund.object_version_number;
                 END LOOP;
              END IF;


              /* R12: yzhao bug 4669269 - obsolete ozf_mc_transactions
              OPEN c_mc_trans(p_util_fund_id);
              FETCH c_mc_trans INTO l_mc_record_id, l_obj_num;
              CLOSE c_mc_trans;

              -- update ozf_mc_transaction_all table.
              UPDATE ozf_mc_transactions_all
                SET amount_column7 = NVL(amount_column7, 0) + NVL(p_util_acctd_amount,0),
                    amount_column8 = NVL(amount_column8, 0) + NVL(l_mc_col_8, 0),
                    object_version_number = l_obj_num + 1
                WHERE mc_record_id = l_mc_record_id
                AND object_version_number = l_obj_num;
               */
          END IF; -- l_gl_posted_flag
        END IF; -- for utilization_type
     END IF; -- end of plan_type


     x_gl_posted_flag := l_gl_posted_flag;
     x_return_status := fnd_api.g_ret_sts_success;

     IF g_debug_flag = 'Y' THEN
        ozf_utility_pvt.write_conc_log ('    D: post_accrual_to_gl() ENDs for utilization id ' || p_util_utilization_id
         || ' final gl_posted_flag=' || x_gl_posted_flag);
     END IF;

   EXCEPTION
     WHEN OTHERS THEN
       ROLLBACK TO post_accrual_to_gl_sp;
       ozf_utility_pvt.write_conc_log('    D: post_accrual_to_gl(): exception ');
       x_return_status            := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.count_and_get (
            p_count    => x_msg_count,
            p_data     => x_msg_data,
            p_encoded  => fnd_api.g_false
       );
   END post_accrual_to_gl;



------------------------------------------------------------------------------
-- Procedure Name
--   reprocess_failed_gl_posting
-- Purpose
--   This procedure repost to GL for all failed gl postings
-- History
--   03-20-00  yzhao   Created
------------------------------------------------------------------------------
   PROCEDURE reprocess_failed_gl_posting (x_errbuf  OUT NOCOPY VARCHAR2,
                                          x_retcode OUT NOCOPY NUMBER
                                         ) IS
     l_gl_posted_flag          VARCHAR2 (1);
     l_return_status           VARCHAR2 (1);
     l_msg_count               NUMBER;
     l_msg_data                VARCHAR2(2000);

     l_utilIdTbl               utilIdTbl;
     l_objVerTbl               objVerTbl;
     l_amountTbl               amountTbl;
     l_planTypeTbl             planTypeTbl;
     l_planIdTbl               planIdTbl;
     l_planAmtTbl              planAmtTbl;
     l_utilTypeTbl             utilTypeTbl;
     l_fundIdTbl               fundIdTbl;
     l_acctAmtTbl              acctAmtTbl;
     l_orgIdTbl                orgIdTbl;

     CURSOR c_get_failed_gl_posting IS
       SELECT utilization_id, object_version_number,
              plan_type, utilization_type,
              amount, fund_id, acctd_amount, fund_request_amount, plan_id,org_id
       FROM   ozf_funds_utilized_all_b
       WHERE  plan_type IN ( 'OFFR' , 'PRIC')       -- yzhao: 10/20/2003 PRICE_LIST is changed to PRIC
         -- AND  utilization_type = 'ACCRUAL'          yzhao: 01/29/2004 11.5.10 off-invoice offer, LEAD_ACCRUAL may post to GL too
         AND  gl_posted_flag = G_GL_FLAG_FAIL;  -- 'F';

   BEGIN
      IF g_debug_flag = 'Y' THEN
         ozf_utility_pvt.write_conc_log ('    D: Begin posting to GL for all failed postings');
      END IF;

     OPEN c_get_failed_gl_posting;
     LOOP
         FETCH c_get_failed_gl_posting BULK COLLECT INTO l_utilIdTbl, l_objVerTbl
                                                       , l_planTypeTbl, l_utilTypeTbl
                                                       , l_amountTbl, l_fundIdTbl, l_acctAmtTbl, l_planAmtTbl, l_planIdTbl,l_orgIdTbl
                                                       LIMIT g_bulk_limit;
         FOR i IN NVL(l_utilIdTbl.FIRST, 1) .. NVL(l_utilIdTbl.LAST, 0) LOOP
             post_accrual_to_gl( p_util_utilization_id        => l_utilIdTbl(i)
                               , p_util_object_version_number => l_objVerTbl(i)
                               , p_util_amount                => l_amountTbl(i)
                               , p_util_plan_type             => l_planTypeTbl(i)
                               , p_util_plan_id               => l_planIdTbl(i)
                               , p_util_plan_amount           => l_planAmtTbl(i)
                               , p_util_utilization_type      => l_utilTypeTbl(i)
                               , p_util_fund_id               => l_fundIdTbl(i)
                               , p_util_acctd_amount          => l_acctAmtTbl(i)
                               , p_util_org_id                     => l_orgIdTbl(i)
                               , x_gl_posted_flag             => l_gl_posted_flag
                               , x_return_status              => l_return_status
                               , x_msg_count                  => l_msg_count
                               , x_msg_data                   => l_msg_data
                           );

             IF l_return_status <> fnd_api.g_ret_sts_success THEN
                -- failed again. Leave as it is.
                ozf_utility_pvt.write_conc_log('   /****** Failed to post to GL ******/ for utilization id ' || l_utilIdTbl(i));
             ELSE
                IF g_debug_flag = 'Y' THEN
                   ozf_utility_pvt.write_conc_log ('    D: successfully posted to GL for utilization id ' || l_utilIdTbl(i)
                                || '  x_gl_posted_flag=' || l_gl_posted_flag);
                END IF;

                -- yzhao: 03/04/2004 post gl for related accruals from offer adjustment or object reconcile
                IF l_gl_posted_flag = G_GL_FLAG_YES THEN
                    post_related_accrual_to_gl(
                        p_utilization_id              => l_utilIdTbl(i)
                      , p_utilization_type            => l_utilTypeTbl(i)
                      , x_return_status               => l_return_status
                      , x_msg_count                   => l_msg_count
                      , x_msg_data                    => l_msg_data
                  );
                END IF;

             END IF;
         END LOOP;  -- FOR i IN NVL(p_utilIdTbl.FIRST, 1) .. NVL(p_utilIdTbl.LAST, 0) LOOP

         EXIT WHEN c_get_failed_gl_posting%NOTFOUND;
     END LOOP;  -- bulk fetch loop
     CLOSE c_get_failed_gl_posting;

     x_retcode := 0;
     IF g_debug_flag = 'Y' THEN
        ozf_utility_pvt.write_conc_log ('    D: End successfully posting to GL for all failed postings');
     END IF;

   EXCEPTION
     WHEN OTHERS THEN
       x_retcode                  := 1;
       ozf_utility_pvt.write_conc_log('   /****** Failed to post to GL - exception ' ||  sqlcode || ' ******/' );
   END reprocess_failed_gl_posting;


------------------------------------------------------------------------------
-- Procedure Name
--   post_offinvoice_to_gl
-- Purpose
--   This procedure posts utilization created by off-invoice offer to GL only when AutoInvoice workflow is done
-- History
--   03/19/2003  Ying Zhao Created
------------------------------------------------------------------------------
  PROCEDURE post_offinvoice_to_gl(
             x_errbuf  OUT NOCOPY VARCHAR2,
             x_retcode OUT NOCOPY NUMBER     )
   IS
     l_gl_posted_flag             VARCHAR2(1);
     l_invoice_line_id            NUMBER;
     l_gl_date                    DATE;
     l_return_status              VARCHAR2 (1);
     l_msg_count                  NUMBER;
     l_msg_data                   VARCHAR2 (2000);
     l_order_number               NUMBER;
     l_object_id                  NUMBER := 0;

     l_utilIdTbl               utilIdTbl;
     l_objVerTbl               objVerTbl;
     l_amountTbl               amountTbl;
     l_planTypeTbl             planTypeTbl;
     l_planIdTbl               planIdTbl;
     l_planAmtTbl              planAmtTbl;
     l_utilTypeTbl             utilTypeTbl;
     l_fundIdTbl               fundIdTbl;
     l_acctAmtTbl              acctAmtTbl;
     l_orgIdTbl                orgIdTbl;
     l_objectIdTbl             objectIdTbl;
     l_priceAdjTbl             priceAdjTbl;

     --nirprasa, ER 8399134
     l_excDateTbl              excDateTbl;
     l_excTypeTbl              excTypeTbl;
     l_currCodeTbl             currCodeTbl;
     l_planCurrCodeTbl         planCurrCodeTbl;
     l_fundReqCurrCodeTbl      fundReqCurrCodeTbl;
     l_planCurrAmtTbl          planCurrAmtTbl;
     l_planCurrAmtRemTbl       planCurrAmtRemTbl;
     l_univCurrAmtTbl          univCurrAmtTbl;
     -- yzhao: 03/21/2003 get invoiced order's utilization record, post to GL
     --nirprasa, ER 8399134
     CURSOR c_get_all_util_rec IS
       SELECT utilization_id, object_version_number, plan_type, utilization_type, amount
              , fund_id, acctd_amount, fund_request_amount, plan_id
              ,org_id, exchange_rate_type, exchange_rate_date
              , currency_code, plan_currency_code, fund_request_currency_code
              , plan_curr_amount, plan_curr_amount_remaining
              , univ_curr_amount,object_id, price_adjustment_id
       FROM   ozf_funds_utilized_all_b
       WHERE  utilization_type = 'UTILIZED'
       AND    gl_posted_flag = 'N'
       AND    object_type = 'ORDER'
       AND    price_adjustment_id IS NOT NULL;

     -- Replaced Sales_Order Column with interface_line_attribute1 for Bug 8463331
     CURSOR c_get_invoice_status(p_price_adjustment_id IN NUMBER, p_order_number IN  VARCHAR2) IS
       SELECT customer_trx_line_id, cust.trx_date
       FROM   ra_customer_trx_all cust
            , ra_customer_trx_lines_all cust_lines
            , oe_price_adjustments price
       WHERE  price.price_adjustment_id = p_price_adjustment_id
       AND    cust_lines.customer_trx_line_id IS NOT NULL
       AND    interface_line_context = 'ORDER ENTRY'
       AND    cust_lines.interface_line_attribute6 = TO_CHAR(price.line_id)
       AND    cust_lines.interface_line_attribute1 = p_order_number -- added for partial index; performance bug fix 3917556
       AND    cust.customer_trx_id = cust_lines.customer_trx_id;


         -- added for 3917556
      CURSOR c_get_offer_info (p_header_id IN NUMBER) IS
         SELECT order_number
           FROM oe_order_headers_all
          WHERE header_id = p_header_id;

   BEGIN
     x_retcode := 0;
     SAVEPOINT  post_offinvoice_to_gl_sp;

     IF g_debug_flag = 'Y' THEN
        ozf_utility_pvt.write_conc_log ('    D: post_offinvoice_to_gl() BEGIN ');
     END IF;

     OPEN c_get_all_util_rec;
     LOOP
        FETCH c_get_all_util_rec BULK COLLECT INTO
        l_utilIdTbl, l_objVerTbl, l_planTypeTbl, l_utilTypeTbl, l_amountTbl
      , l_fundIdTbl, l_acctAmtTbl, l_planAmtTbl, l_planIdTbl,l_orgIdTbl
      , l_excTypeTbl, l_excDateTbl, l_currCodeTbl, l_planCurrCodeTbl
      , l_fundReqCurrCodeTbl, l_planCurrAmtTbl, l_planCurrAmtRemTbl
      , l_univCurrAmtTbl, l_objectIdTbl ,l_priceAdjTbl
       LIMIT g_bulk_limit;


        IF g_debug_flag = 'Y' THEN
           ozf_utility_pvt.write_conc_log ('    D: l_utilIdTbl count: ' || l_utilIdTbl.COUNT);
        END IF;

        FOR i IN NVL(l_utilIdTbl.FIRST, 1) .. NVL(l_utilIdTbl.LAST, 0) LOOP

           IF l_object_id <> l_objectIdTbl(i) THEN
              l_object_id := l_objectIdTbl(i);
              OPEN c_get_offer_info(l_object_id);
              FETCH c_get_offer_info INTO l_order_number;
              CLOSE c_get_offer_info;
           END IF;

           l_invoice_line_id := NULL; --Bugfix: 7431334

           OPEN c_get_invoice_status(l_priceAdjTbl(i), l_order_number);
           FETCH c_get_invoice_status INTO l_invoice_line_id, l_gl_date;
           CLOSE c_get_invoice_status;

           IF l_invoice_line_id IS NOT NULL THEN

               -- fix for bug 6998502
              IF l_gl_date IS NULL THEN
               l_gl_date := sysdate;
              END IF;

              FORALL t_i IN NVL(l_utilIdTbl.FIRST, 1) .. NVL(l_utilIdTbl.LAST, 0)
               UPDATE ozf_funds_utilized_all_b
               SET gl_date = l_gl_date
               WHERE utilization_id = l_utilIdTbl(t_i);
               --nirprasa, ER 8399134
               IF TRUNC(l_excDateTbl(i)) <> TRUNC(l_gl_date) AND l_utilTypeTbl(i) IN ('UTILIZED') THEN

                  l_excDateTbl(i) := l_gl_date;

                  IF g_debug_flag = 'Y' THEN
                     ozf_utility_pvt.write_conc_log(' recalculate_earnings: start');
                     ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_excDateTbl(t_i) '||l_excDateTbl(i));
                     ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_excTypeTbl(t_i) '||l_excTypeTbl(i));
                     ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_orgIdTbl(t_i) '||l_orgIdTbl(i));
                     ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_currCodeTbl(t_i) '||l_currCodeTbl(i));
                     ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_planCurrCodeTbl(t_i) '||l_planCurrCodeTbl(i));
                     ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_fundReqCurrCodeTbl(t_i) '||l_fundReqCurrCodeTbl(i));
                     ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_amountTbl(t_i) '||l_amountTbl(i));
                     ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_planCurrAmtTbl(t_i) '||l_planCurrAmtTbl(i));
                     ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_planCurrAmtRemTbl(t_i) '||l_planCurrAmtRemTbl(i));
                     ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_univCurrAmtTbl(t_i) '||l_univCurrAmtTbl(i));
                     ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_acctAmtTbl(t_i) '||l_acctAmtTbl(i));
                     ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_planIdTbl(t_i) '||l_planIdTbl(i));
                     ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_planTypeTbl(t_i) '||l_planTypeTbl(i));
                     ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_fundIdTbl(t_i) '||l_fundIdTbl(i));
                     ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_utilIdTbl(t_i) '||l_utilIdTbl(i));
                     ozf_utility_pvt.write_conc_log(' recalculate_earnings: l_utilTypeTbl(t_i) '||l_utilTypeTbl(i));
                  END IF;

                 recalculate_earnings(p_exchange_rate_date     => l_excDateTbl(i),
                                      p_exchange_rate_type     => l_excTypeTbl(i),
                                      p_util_org_id            => l_orgIdTbl(i),
                                      p_currency_code          => l_currCodeTbl(i),
                                      p_plan_currency_code     => l_planCurrCodeTbl(i),
                                      p_fund_req_currency_code => l_fundReqCurrCodeTbl(i),
                                      p_amount                 => l_amountTbl(i),
                                      p_plan_curr_amount       => l_planCurrAmtTbl(i),
                                      p_plan_curr_amount_rem   => l_planCurrAmtRemTbl(i),
                                      p_univ_curr_amount       => l_univCurrAmtTbl(i),
                                      p_acctd_amount           => l_acctAmtTbl(i),
                                      p_fund_req_amount        => l_planAmtTbl(i),
                                      p_util_plan_id           => l_planIdTbl(i),
                                      p_util_plan_type         => l_planTypeTbl(i),
                                      p_util_fund_id           => l_fundIdTbl(i),
                                      p_util_utilization_id    => l_utilIdTbl(i),
                                      p_util_utilization_type  => l_utilTypeTbl(i),
                                      x_return_status          => l_return_status,
                                      x_msg_count              => l_msg_count,
                                      x_msg_data               => l_msg_data);
                     IF g_debug_flag = 'Y' THEN
                        ozf_utility_pvt.write_conc_log(' recalculate_earnings returns ' || l_return_status
                             );
                     END IF;
              END IF;

              post_accrual_to_gl( p_util_utilization_id        => l_utilIdTbl(i)
                               , p_util_object_version_number => l_objVerTbl(i)
                               , p_util_amount                => l_amountTbl(i)
                               , p_util_plan_type             => l_planTypeTbl(i)
                               , p_util_plan_id               => l_planIdTbl(i)
                               , p_util_plan_amount           => l_planAmtTbl(i)
                               , p_util_utilization_type      => 'UTILIZED'
                               , p_util_fund_id               => l_fundIdTbl(i)
                               , p_util_acctd_amount          => l_acctAmtTbl(i)
                               , x_gl_posted_flag             => l_gl_posted_flag
                               , x_return_status              => l_return_status
                               , x_msg_count                  => l_msg_count
                               , x_msg_data                   => l_msg_data
                           );

             -- do not raise exception for gl posting error. Just mark it as failed and deal with it later
              IF g_debug_flag = 'Y' THEN
                 ozf_utility_pvt.write_conc_log ('    D:  post_offinvoice_to_gl() post_accrual_to_gl(util_id='
                           || l_utilIdTbl(i)
                           || ') returns ' || l_return_status || ' x_gl_posted_flag' || l_gl_posted_flag);
              END IF;

             -- yzhao: 03/04/2004 post gl for related accruals from offer adjustment or object reconcile
              IF l_return_status = fnd_api.g_ret_sts_success AND l_gl_posted_flag = G_GL_FLAG_YES THEN
                 post_related_accrual_to_gl(
                      p_utilization_id              => l_utilIdTbl(i)
                    , p_utilization_type            => 'UTILIZED'
                    , p_gl_date                     => l_gl_date
                    , x_return_status               => l_return_status
                    , x_msg_count                   => l_msg_count
                    , x_msg_data                    => l_msg_data
                );
              END IF;
           END IF; --l_invoice_line_id IS NOT

        END LOOP;  -- FOR i IN NVL(l_utilIdTbl.FIRST, 1) .. NVL(l_utilIdTbl.LAST, 0) LOOP

        EXIT WHEN c_get_all_util_rec%NOTFOUND;
     END LOOP;   -- bulk fetch
     CLOSE c_get_all_util_rec;

     IF g_debug_flag = 'Y' THEN
         ozf_utility_pvt.write_conc_log ('    D: post_offinvoice_to_gl() END');
     END IF;


   EXCEPTION
     WHEN OTHERS THEN
       ROLLBACK TO post_offinvoice_to_gl_sp;
       x_retcode := 1;
       ozf_utility_pvt.write_conc_log('    D: post_offinvoice_to_gl(): exception ');
       fnd_msg_pub.count_and_get (
            p_count    => l_msg_count,
            p_data     => l_msg_data,
            p_encoded  => fnd_api.g_false
       );
       x_errbuf := l_msg_data;
   END post_offinvoice_to_gl;

------------------------------------------------------------------------------
-- Procedure Name
--   post_related_accrual_to_gl
-- Purpose
--   This procedure posts utilization(from offer adjustment or offer reconcile) to GL
--        called when the original utilization is posted to GL successfully
-- History
--   03/04/2003  Ying Zhao Created
------------------------------------------------------------------------------
   PROCEDURE post_related_accrual_to_gl(
      p_utilization_id              IN              NUMBER,
      p_utilization_type            IN              VARCHAR2,
      p_gl_date                     IN              DATE      := NULL,
      x_return_status               OUT NOCOPY      VARCHAR2,
      x_msg_count                   OUT NOCOPY      NUMBER,
      x_msg_data                    OUT NOCOPY      VARCHAR2)
   IS
     l_adjust_paid_flag             BOOLEAN := false;
     l_gl_posted_flag               VARCHAR2(1) := NULL;
     l_return_status                VARCHAR2 (1);
     l_msg_count                    NUMBER;
     l_msg_data                     VARCHAR2 (2000);

     l_utilIdTbl                    utilIdTbl;
     l_objVerTbl                    objVerTbl;
     l_amountTbl                    amountTbl;
     l_planTypeTbl                  planTypeTbl;
     l_planIdTbl                    planIdTbl;
     l_planAmtTbl                   planAmtTbl;
     l_utilTypeTbl                  utilTypeTbl;
     l_fundIdTbl                    fundIdTbl;
     l_acctAmtTbl                   acctAmtTbl;
     l_orgIdTbl                     orgIdTbl;
     -- yzhao: 03/04/2004 get related accraul records, post to GL
     CURSOR c_get_related_accrual IS
       SELECT utilization_id, object_version_number, plan_type, utilization_type, amount
            , fund_id, acctd_amount, fund_request_amount, plan_id,org_id
       FROM   ozf_funds_utilized_all_b
       WHERE  (gl_posted_flag = G_GL_FLAG_NO OR gl_posted_flag = G_GL_FLAG_FAIL)
       AND    orig_utilization_id = p_utilization_id;

   BEGIN
     SAVEPOINT  post_related_accrual_to_gl_sp;
     IF g_debug_flag = 'Y' THEN
        ozf_utility_pvt.write_conc_log ('    D: post_related_accrual_to_gl() BEGIN posting related accruals to GL for utilization id ' || p_utilization_id);
     END IF;

     IF p_utilization_type = 'UTILIZED' THEN
        l_adjust_paid_flag := true;
     END IF;

     OPEN c_get_related_accrual;
     LOOP
         FETCH c_get_related_accrual BULK COLLECT
         INTO l_utilIdTbl, l_objVerTbl, l_planTypeTbl, l_utilTypeTbl, l_amountTbl
            , l_fundIdTbl, l_acctAmtTbl, l_planAmtTbl, l_planIdTbl,l_orgIdTbl
         LIMIT g_bulk_limit;

         IF p_gl_date IS NOT NULL THEN
             FORALL i IN NVL(l_utilIdTbl.FIRST, 1) .. NVL(l_utilIdTbl.LAST, 0)
                 UPDATE ozf_funds_utilized_all_b
                    SET gl_date = p_gl_date
                  WHERE utilization_id = l_utilIdTbl(i);
         END IF;

         FOR i IN NVL(l_utilIdTbl.FIRST, 1) .. NVL(l_utilIdTbl.LAST, 0) LOOP
             post_accrual_to_gl( p_util_utilization_id        => l_utilIdTbl(i)
                               , p_util_object_version_number => l_objVerTbl(i)
                               , p_util_amount                => l_amountTbl(i)
                               , p_util_plan_type             => l_planTypeTbl(i)
                               , p_util_plan_id               => l_planIdTbl(i)
                               , p_util_plan_amount           => l_planAmtTbl(i)
                               , p_util_utilization_type      => l_utilTypeTbl(i)
                               , p_util_fund_id               => l_fundIdTbl(i)
                               , p_util_acctd_amount          => l_acctAmtTbl(i)
                               , p_adjust_paid_flag           => l_adjust_paid_flag
                               , p_util_org_id                => l_orgIdTbl(i)
                               , x_gl_posted_flag             => l_gl_posted_flag
                               , x_return_status              => l_return_status
                               , x_msg_count                  => l_msg_count
                               , x_msg_data                   => l_msg_data
                           );

            -- do not raise exception for gl posting error. Just mark it as failed and deal with it later
            IF g_debug_flag = 'Y' THEN
               ozf_utility_pvt.write_conc_log('    D:  post_related_accrual_to_gl() post_accrual_to_gl(util_id=' || l_utilIdTbl(i)
                           || ') returns ' || l_return_status || ' x_gl_posted_flag' || l_gl_posted_flag);
            END IF;
         END LOOP; -- FOR i IN NVL(l_utilIdTbl.FIRST, 1) .. NVL(l_utilIdTbl.LAST, 0) LOOP

         EXIT WHEN c_get_related_accrual%NOTFOUND;
     END LOOP;  -- bulk fetch
     CLOSE c_get_related_accrual;

     x_return_status := fnd_api.g_ret_sts_success;
     IF g_debug_flag = 'Y' THEN
        ozf_utility_pvt.write_conc_log ('    D: post_related_accrual_to_gl() ENDs for utilization id ' || p_utilization_id);
     END IF;

   EXCEPTION
     WHEN OTHERS THEN
       ROLLBACK TO post_related_accrual_to_gl_sp;
       ozf_utility_pvt.write_conc_log('    D: post_related_accrual_to_gl(): exception ');
       x_return_status            := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.count_and_get (
            p_count    => x_msg_count,
            p_data     => x_msg_data,
            p_encoded  => fnd_api.g_false
       );

   END post_related_accrual_to_gl;

     ------------------------------------------------------------------------------
-- Procedure Name
--   recalculate_earnings
-- Purpose
--   This procedure re-converts the converted amounts in utilization table
--   gl_date will be used as exchange_date.
--
-- History
-- 04/29/2009 nirprasa Created for ER 8399134
------------------------------------------------------------------------------
   PROCEDURE recalculate_earnings (
      p_exchange_rate_date          IN            DATE,
      p_exchange_rate_type          IN            VARCHAR2,
      p_util_org_id                 IN            NUMBER,
      p_currency_code               IN            VARCHAR2,
      p_plan_currency_code          IN            VARCHAR2,
      p_fund_req_currency_code      IN            VARCHAR2,
      p_amount                      IN            NUMBER,
      p_plan_curr_amount            IN            NUMBER,
      p_plan_curr_amount_rem        IN            NUMBER,
      p_univ_curr_amount            IN            NUMBER,
      p_acctd_amount                IN            NUMBER,
      p_fund_req_amount             IN            NUMBER,
      p_util_plan_id                IN            NUMBER,
      p_util_plan_type              IN            VARCHAR2,
      p_util_fund_id                IN            NUMBER,
      p_util_utilization_id         IN            NUMBER,
      p_util_utilization_type       IN            VARCHAR2,
      x_return_status               OUT NOCOPY    VARCHAR2,
      x_msg_count                   OUT NOCOPY    VARCHAR2,
      x_msg_data                    OUT NOCOPY    VARCHAR2)
   IS

   CURSOR c_get_conversion_type( p_org_id   IN   NUMBER) IS
        SELECT exchange_rate_type
        FROM   ozf_sys_parameters_all
        WHERE  org_id = p_org_id;

   CURSOR c_get_objfundsum_rec(p_object_type IN VARCHAR2, p_object_id IN NUMBER, p_fund_id IN NUMBER) IS
        SELECT objfundsum_id
              , object_version_number
              , utilized_amt
              , earned_amt
              , paid_amt
              , plan_curr_utilized_amt
              , plan_curr_earned_amt
              , plan_curr_paid_amt
              , univ_curr_utilized_amt
              , univ_curr_earned_amt
              , univ_curr_paid_amt
        FROM   ozf_object_fund_summary
        WHERE  object_type = p_object_type
        AND    object_id = p_object_id
        AND    fund_id = p_fund_id;

   CURSOR c_parent (p_fund_id IN NUMBER)IS
        SELECT fund_id
              ,object_version_number
        FROM ozf_funds_all_b
        connect by prior  parent_fund_id =fund_id
        start with fund_id =  p_fund_id;

   CURSOR c_get_fund (p_fund_id IN NUMBER) IS
       SELECT  object_version_number, parent_fund_id,liability_flag,accrual_basis
       FROM    ozf_funds_all_b
       WHERE   fund_id = p_fund_id;

   CURSOR c_act_budget_rec(p_plan_id IN NUMBER) IS
       SELECT activity_budget_id
            , object_version_number
       FROM   ozf_act_budgets
       WHERE  transfer_type = 'UTILIZED'
       AND    status_code = 'APPROVED'
       AND    act_budget_used_by_id = p_plan_id;

   l_exchange_rate_type         VARCHAR2(30);
   l_exchange_rate              NUMBER;
   l_rate                       NUMBER;
   l_conv_amount                NUMBER;
   l_conv_amount_remg           NUMBER;
   l_conv_acctd_amount          NUMBER;
   l_conv_acctd_amount_remg     NUMBER;
   l_conv_fund_req_amount       NUMBER;
   l_conv_fund_req_amount_remg  NUMBER;
   l_conv_univ_amount           NUMBER;
   l_conv_univ_amount_remg      NUMBER;
   l_paid_amt                   NUMBER;
   l_paid_conv_amt              NUMBER;
   l_rollup_paid_amt            NUMBER;
   l_rollup_paid_conv_amt       NUMBER;
   l_rollup_orig_amt            NUMBER;
   l_orig_amt                   NUMBER;
   l_act_budget_id              NUMBER;
   l_act_budget_objver          NUMBER;
   l_order_ledger               NUMBER;
   l_obj_num                    NUMBER;
   l_parent_fund_id             NUMBER;
   l_liability_flag             VARCHAR2(1);
   l_accrual_basis              VARCHAR2(30);
   l_ord_ledger_name            VARCHAR2(150);
   l_sob_type_code              VARCHAR2(30);
   l_fc_code                    VARCHAR2(150);
   l_msg_count                  NUMBER;
   l_return_status              VARCHAR2(30);
   l_msg_data                   VARCHAR2(2000);
   l_gl_posted_flag             VARCHAR2(1);
   p_adjust_paid_flag           BOOLEAN  := false;
   l_objfundsum_rec             ozf_objfundsum_pvt.objfundsum_rec_type := NULL;

   BEGIN
     SAVEPOINT  recalculate_earnings_sp;
     IF g_debug_flag = 'Y' THEN
        ozf_utility_pvt.write_conc_log ('recalculate_earnings_sp() BEGIN converting amounts based on shipping date for utilization id ' || p_util_utilization_id);
     END IF;

     OPEN c_get_conversion_type(p_util_org_id);
     FETCH c_get_conversion_type INTO l_exchange_rate_type;
     CLOSE c_get_conversion_type;

     --budget
     IF p_currency_code = p_plan_currency_code THEN
        l_conv_amount := p_plan_curr_amount;
     ELSE
     ozf_utility_pvt.convert_currency (
               x_return_status => l_return_status,
               p_from_currency => p_plan_currency_code,
               p_to_currency   => p_currency_code,
               p_conv_type     => l_exchange_rate_type,
               p_conv_date     => p_exchange_rate_date,
               p_from_amount   => p_plan_curr_amount,
               x_to_amount     => l_conv_amount,
               x_rate          => l_rate
              );
     END IF;

     IF NVL(p_plan_curr_amount_rem,0) <> 0 THEN
        l_conv_amount_remg := l_conv_amount;
     END IF;

     --functional
     --get the order's ledger id
     mo_utils.Get_Ledger_Info (
                  p_operating_unit => p_util_org_id
                 ,p_ledger_id      => l_order_ledger
                 ,p_ledger_name    => l_ord_ledger_name);

     ozf_utility_pvt.calculate_functional_currency (
                  p_from_amount => p_plan_curr_amount
                 ,p_conv_date     => p_exchange_rate_date
                 ,p_tc_currency_code => p_plan_currency_code
                 ,p_ledger_id => l_order_ledger
                 ,x_to_amount => l_conv_acctd_amount
                 ,x_mrc_sob_type_code => l_sob_type_code
                 ,x_fc_currency_code => l_fc_code
                 ,x_exchange_rate_type => l_exchange_rate_type
                 ,x_exchange_rate => l_exchange_rate
                 ,x_return_status => l_return_status
               );
     IF NVL(p_plan_curr_amount_rem,0) <> 0 THEN
        l_conv_acctd_amount_remg := l_conv_acctd_amount;
     END IF;

     --universal
     IF g_universal_currency = p_currency_code THEN
        l_conv_univ_amount := l_conv_amount;
     ELSIF g_universal_currency = p_plan_currency_code THEN
        l_conv_univ_amount := p_plan_curr_amount;
     ELSIF g_universal_currency = l_fc_code THEN
        l_conv_univ_amount := l_conv_acctd_amount;
     ELSE
     ozf_utility_pvt.convert_currency(
              x_return_status => l_return_status
             ,p_from_currency => p_plan_currency_code
             ,p_to_currency => g_universal_currency
             ,p_conv_type   => l_exchange_rate_type
             ,p_conv_date     => p_exchange_rate_date
             ,p_from_amount => p_plan_curr_amount
             ,x_to_amount => l_conv_univ_amount
             ,x_rate => l_rate
             );
     END IF;

     IF NVL(p_plan_curr_amount_rem,0) <> 0 THEN
        l_conv_univ_amount_remg := l_conv_univ_amount;
     END IF;

     --offer if null currency offer
     IF p_plan_currency_code = p_fund_req_currency_code THEN
        l_conv_fund_req_amount := p_plan_curr_amount;
     ELSE
     ozf_utility_pvt.convert_currency (
              x_return_status => x_return_status
             ,p_from_currency => p_plan_currency_code
             ,p_to_currency   => p_fund_req_currency_code
             ,p_conv_type     => l_exchange_rate_type
             ,p_conv_date     => p_exchange_rate_date
             ,p_from_amount   => p_plan_curr_amount
             ,x_to_amount     => l_conv_fund_req_amount
             ,x_rate          => l_rate
             );
     END IF;

     IF NVL(p_plan_curr_amount_rem,0) <> 0 THEN
        l_conv_fund_req_amount_remg := l_conv_fund_req_amount;
     END IF;

     --update util table
     UPDATE ozf_funds_utilized_all_b
     SET amount = l_conv_amount, amount_remaining = l_conv_amount_remg,
         acctd_amount = l_conv_acctd_amount, acctd_amount_remaining = l_conv_acctd_amount_remg,
         fund_request_amount = l_conv_fund_req_amount, fund_request_amount_remaining = l_conv_fund_req_amount_remg,
         univ_curr_amount = l_conv_univ_amount, univ_curr_amount_remaining = l_conv_univ_amount_remg,
         exchange_rate_type = l_exchange_rate_type,exchange_rate_date = p_exchange_rate_date,exchange_rate = l_exchange_rate
     WHERE utilization_id = p_util_utilization_id;

     --update summary table
     l_objfundsum_rec := NULL;
     OPEN c_get_objfundsum_rec(
        p_util_plan_type
       ,p_util_plan_id
       ,p_util_fund_id);
     FETCH c_get_objfundsum_rec INTO
        l_objfundsum_rec.objfundsum_id
        ,l_objfundsum_rec.object_version_number
        ,l_objfundsum_rec.utilized_amt
        ,l_objfundsum_rec.earned_amt
        ,l_objfundsum_rec.paid_amt
        ,l_objfundsum_rec.plan_curr_utilized_amt
        ,l_objfundsum_rec.plan_curr_earned_amt
        ,l_objfundsum_rec.plan_curr_paid_amt
        ,l_objfundsum_rec.univ_curr_utilized_amt
        ,l_objfundsum_rec.univ_curr_earned_amt
        ,l_objfundsum_rec.univ_curr_paid_amt;
     CLOSE c_get_objfundsum_rec;


     IF p_util_utilization_type = 'UTILIZED' OR p_adjust_paid_flag THEN
        l_paid_amt := p_amount;
        l_paid_conv_amt := l_conv_amount;
        l_rollup_paid_amt := p_univ_curr_amount;
        l_rollup_paid_conv_amt := l_conv_univ_amount;
        l_objfundsum_rec.paid_amt :=  NVL(l_objfundsum_rec.paid_amt, 0)
                                    - NVL(p_amount, 0)
                                    + NVL(l_conv_amount, 0);
        --fix for bug 8586014
        l_objfundsum_rec.plan_curr_paid_amt :=    NVL(l_objfundsum_rec.plan_curr_paid_amt, 0)
                                                - NVL(p_fund_req_amount, 0)
                                                + NVL(l_conv_fund_req_amount, 0);
        l_objfundsum_rec.univ_curr_paid_amt :=   NVL(l_objfundsum_rec.univ_curr_paid_amt, 0)
                                               - NVL(p_univ_curr_amount, 0)
                                               + NVL(l_conv_univ_amount, 0);
     END IF;

     l_objfundsum_rec.earned_amt := NVL(l_objfundsum_rec.earned_amt, 0)
                                    - NVL(p_amount, 0)
                                    + NVL(l_conv_amount, 0);
     l_objfundsum_rec.utilized_amt := NVL(l_objfundsum_rec.utilized_amt, 0)
                                    - NVL(p_amount, 0)
                                    + NVL(l_conv_amount, 0);


     l_objfundsum_rec.plan_curr_utilized_amt := NVL(l_objfundsum_rec.plan_curr_utilized_amt, 0)
                                    - NVL(p_fund_req_amount, 0)
                                    + NVL(l_conv_fund_req_amount, 0);
     --fix for bug 8586014
     l_objfundsum_rec.plan_curr_earned_amt := NVL(l_objfundsum_rec.plan_curr_earned_amt, 0)
                                    - NVL(p_fund_req_amount, 0)
                                    + NVL(l_conv_fund_req_amount, 0);

     l_objfundsum_rec.univ_curr_utilized_amt := NVL(l_objfundsum_rec.univ_curr_utilized_amt, 0)
                                              - NVL(p_univ_curr_amount, 0)
                                              + NVL(l_conv_univ_amount, 0);

     l_objfundsum_rec.univ_curr_earned_amt := NVL(l_objfundsum_rec.univ_curr_earned_amt, 0)
                                              - NVL(p_univ_curr_amount, 0)
                                              + NVL(l_conv_univ_amount, 0);

     ozf_objfundsum_pvt.update_objfundsum(p_api_version       => 1.0,
                                p_init_msg_list     => Fnd_Api.G_FALSE,
                                p_validation_level  => Fnd_Api.G_VALID_LEVEL_NONE,
                                p_objfundsum_rec    => l_objfundsum_rec,
                                x_return_status     => l_return_status,
                                x_msg_count         => x_msg_count,
                                x_msg_data          => x_msg_data
     );
     IF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
        RAISE fnd_api.g_exc_unexpected_error;
     ELSIF l_return_status = fnd_api.g_ret_sts_error THEN
        RAISE fnd_api.g_exc_error;
     END IF;

     --update activity table
     OPEN c_act_budget_rec(p_util_plan_id);
     FETCH c_act_budget_rec INTO l_act_budget_id, l_act_budget_objver;
     CLOSE c_act_budget_rec;

     UPDATE ozf_act_budgets
     SET  src_curr_request_amt = NVL(src_curr_request_amt, 0) - p_amount + l_conv_amount
          , approved_original_amount = NVL(approved_original_amount, 0) - NVL(p_fund_req_amount, 0)
                                                                        + NVL(l_conv_fund_req_amount,0)
          , approved_amount_fc = NVL(approved_amount_fc, 0) - NVL(p_acctd_amount,0)
                                                            + NVL(l_conv_acctd_amount,0)
          , request_amount     = NVL(request_amount, 0) - NVL(p_fund_req_amount, 0)
                                                        + NVL(l_conv_fund_req_amount, 0)
          , approved_amount     = NVL(approved_amount, 0) - NVL(p_fund_req_amount, 0)
                                                          + NVL(l_conv_fund_req_amount, 0)
          , last_update_date = sysdate
          , last_updated_by = NVL (fnd_global.user_id, -1)
          , last_update_login = NVL (fnd_global.conc_login_id, -1)
          , object_version_number = l_act_budget_objver + 1
     WHERE  activity_budget_id = l_act_budget_id
     AND    object_version_number = l_act_budget_objver;

     --update fund table.
     OPEN c_get_fund(p_util_fund_id);
     FETCH c_get_fund INTO l_obj_num, l_parent_fund_id, l_liability_flag,l_accrual_basis;
     CLOSE c_get_fund;


     IF p_util_utilization_type IN ('ACCRUAL', 'LEAD_ACCRUAL') THEN
        IF l_accrual_basis = 'CUSTOMER' AND NVL(l_liability_flag,'N')= 'N' THEN
           l_gl_posted_flag := G_GL_FLAG_NOLIAB;
        END IF;
     ELSIF p_util_utilization_type = 'SALES_ACCRUAL' THEN
        l_gl_posted_flag := G_GL_FLAG_NOLIAB;
     END IF;

     IF l_gl_posted_flag = G_GL_FLAG_NOLIAB THEN
                 l_orig_amt := l_conv_amount;
                 l_rollup_orig_amt := l_conv_univ_amount;
     END IF;

     UPDATE ozf_funds_all_b
     SET    original_budget = NVL(original_budget, 0) + NVL(l_orig_amt, 0) - NVL(p_amount,0)
           ,rollup_original_budget = NVL(rollup_original_budget, 0) + NVL(l_rollup_orig_amt, 0)
                                                                   - NVL(p_univ_curr_amount, 0)
          ,earned_amt = NVL(earned_amt, 0) + NVL(l_conv_amount, 0)- NVL(p_amount, 0)
          ,paid_amt = NVL(paid_amt, 0 ) + NVL(l_paid_conv_amt, 0) - NVL(l_paid_amt, 0)
          ,rollup_earned_amt = NVL(rollup_earned_amt, 0) + NVL(l_rollup_orig_amt, 0)
                                                         - NVL(p_univ_curr_amount, 0)
          ,rollup_paid_amt   = NVL(rollup_paid_amt, 0)   + NVL(l_rollup_paid_amt, 0)
                                                         - NVL(l_rollup_paid_conv_amt, 0)
          ,object_version_number = l_obj_num + 1
     WHERE fund_id =  p_util_fund_id
     AND   object_version_number = l_obj_num;

     IF l_parent_fund_id is NOT NULL THEN
     FOR fund IN c_parent(l_parent_fund_id)
     LOOP
        UPDATE ozf_funds_all_b
        SET object_version_number = fund.object_version_number + 1
          ,rollup_earned_amt = NVL(rollup_earned_amt,0) + NVL(l_rollup_orig_amt, 0)
                                                        - NVL(p_univ_curr_amount,0)
          ,rollup_paid_amt = NVL(rollup_paid_amt,0) + NVL(l_rollup_paid_amt,0)
                                                    - NVL(l_rollup_paid_conv_amt, 0)
          ,rollup_original_budget = NVL(rollup_original_budget,0) + NVL(l_rollup_orig_amt,0)
                                                                  - NVL(p_univ_curr_amount, 0)
        WHERE fund_id = fund.fund_id
        AND object_version_number = fund.object_version_number;
     END LOOP;
     END IF;



   EXCEPTION
     WHEN OTHERS THEN
       ROLLBACK TO recalculate_earnings_sp;
       ozf_utility_pvt.write_conc_log('recalculate_earnings(): exception ');
       fnd_msg_pub.count_and_get (
            p_count    => l_msg_count,
            p_data     => l_msg_data,
            p_encoded  => fnd_api.g_false
       );


     x_return_status := fnd_api.g_ret_sts_success;
     IF g_debug_flag = 'Y' THEN
        ozf_utility_pvt.write_conc_log ('    D: recalculate_earnings() ENDs for utilization id ' || p_util_utilization_id);
     END IF;
   END recalculate_earnings;
END ozf_accrual_engine;

/
