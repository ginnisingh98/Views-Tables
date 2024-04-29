--------------------------------------------------------
--  DDL for Package Body OZF_FUND_ADJUSTMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_FUND_ADJUSTMENT_PVT" AS
/*$Header: ozfvadjb.pls 120.25.12010000.16 2010/03/02 09:03:48 kdass ship $*/

   g_pkg_name         CONSTANT VARCHAR2 (30) := 'OZF_Fund_Adjustment_PVT';
   g_cons_fund_mode   CONSTANT VARCHAR2 (30) := 'WORKFLOW';
   G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
   g_recal_flag CONSTANT VARCHAR2(1) :=  NVL(fnd_profile.value('OZF_BUDGET_ADJ_ALLOW_RECAL'),'N');

   /* =========================================================
   --tbl_type to hold the object
   --This is a private rec type to be used by this API only
   */
   TYPE object_rec_type IS RECORD (
      object_id                     NUMBER
     ,object_curr                   VARCHAR2 (30));

   /* =========================================================
   --tbl_type to hold the amount
   --This is a private rec type to be used by this API only
   ============================================================*/

   TYPE object_tbl_type IS TABLE OF object_rec_type
      INDEX BY BINARY_INTEGER;

---------------------------------------------------------------------
-- PROCEDURE
--    validate_lumsum_offer
--
-- PURPOSE
--
-- PARAMETERS
   --p_qp_list_header_id     IN   NUMBER
   --x_return_status         OUT NOCOPY  VARCHAR2);
-- NOTES
--           This API will va;idate the lumsum offer distribution
-- HISTORY
--   09/24/2001  Mumu Pande  Create.
----------------------------------------------------------------------

PROCEDURE validate_lumpsum_offer (p_qp_list_header_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2);
--------------------------------------------------------------------------
    FUNCTION find_org_id (p_actbudget_id IN NUMBER) RETURN number IS
      l_org_id number := NULL;

      CURSOR get_fund_org_csr(p_id in number) IS
      SELECT org_id
      FROM ozf_funds_all_b
      WHERE fund_id = p_actbudget_id;

    BEGIN

     OPEN  get_fund_org_csr(p_actbudget_id);
     FETCH get_fund_org_csr INTO l_org_id;
     CLOSE get_fund_org_csr;

     RETURN l_org_id;

    END find_org_id;
--------------------------------------------------------------------------
--  yzhao: internal procedure called by wf_respond() to fix bug 2741039
--------------------------------------------------------------------------
    PROCEDURE set_org_ctx (p_org_id IN NUMBER) IS
    BEGIN

         IF p_org_id is not NULL THEN
           fnd_client_info.set_org_context(to_char(p_org_id));
         END IF;

    END set_org_ctx;

--------------------------------------------------------------------------

---------------------------------------------------------------------
-- PROCEDURE
--    create_budget_amt_utilized
--
-- PURPOSE
--   -- Should be called only by the cost module of OM
-- PARAMETERS
--      p_act_budget_used_by_id    IN NUMBER  --
--     ,p_act_budget_used_by_type  IN VARCHAR2 -- eg. CAMP
--     ,p_amount IN NUMBER total amount for utilizing
--           x_return_status OUT VARCHAR2
--
-- NOTES
--       This API will create utlizations for camps, schedules,events,offers.event_sche
--       in the ozf_Act_budgets table and ozf_Fund_utlized_vl table.
--       This API should be called from the cost module of OM only
-- HISTORY
--    04/27/2001  Mumu Pande  Create.
---------------------------------------------------------------------
   PROCEDURE create_budget_amt_utilized (
      p_budget_used_by_id     IN       NUMBER
     ,p_budget_used_by_type   IN       VARCHAR2
     ,p_currency              IN       VARCHAR2
     ,p_cost_tbl              IN       cost_tbl_type
     ,p_api_version           IN       NUMBER
     ,p_init_msg_list         IN       VARCHAR2 := fnd_api.g_false
     ,p_commit                IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,x_msg_count             OUT NOCOPY      NUMBER
     ,x_msg_data              OUT NOCOPY      VARCHAR2
   ) IS
      /*
       CURSOR c_parent_source IS
          SELECT   parent_src_id, parent_currency, SUM (amount) total_amount
              FROM (SELECT   a1.parent_source_id parent_src_id, a1.parent_src_curr parent_currency
                            ,NVL (SUM (a1.parent_src_apprvd_amt), 0) amount
                        FROM ozf_act_budgets a1
                       WHERE a1.act_budget_used_by_id = p_budget_used_by_id
                         AND a1.arc_act_budget_used_by = p_budget_used_by_type
                         AND a1.status_code = 'APPROVED'
                         AND a1.transfer_type <> 'UTILIZED'
                    GROUP BY a1.parent_source_id, a1.parent_src_curr
                    UNION
                    SELECT   a2.parent_source_id parent_src_id, a2.parent_src_curr parent_currency
                            ,-NVL (SUM (a2.parent_src_apprvd_amt), 0) amount
                        FROM ozf_act_budgets a2
                       WHERE a2.budget_source_id = p_budget_used_by_id
                         AND a2.budget_source_type = p_budget_used_by_type
                         AND a2.status_code = 'APPROVED'
                    GROUP BY a2.parent_source_id, a2.parent_src_curr)
          GROUP BY parent_src_id, parent_currency
          ORDER BY parent_src_id;
      */
/*
      CURSOR c_parent_source IS
         SELECT   parent_src_id
                 ,parent_currency
                 ,SUM (amount) total_amount
             FROM (SELECT   a1.fund_id parent_src_id
                           ,a1.currency_code parent_currency
                           ,NVL (SUM (a1.amount), 0) amount
                       FROM ozf_funds_utilized_all_vl a1
                      WHERE a1.component_id = p_budget_used_by_id
                        AND a1.component_type = p_budget_used_by_type

--                        AND a1.status_code = 'APPROVED' -- only approved record are present here
                        AND a1.utilization_type IN ('TRANSFER', 'REQUEST')
                   GROUP BY a1.fund_id, a1.currency_code
                   UNION
                   SELECT   a2.fund_id parent_src_id
                           ,a2.currency_code parent_currency
                           ,-NVL (SUM (a2.amount), 0) amount
                       FROM ozf_funds_utilized_all_vl a2
                      WHERE a2.plan_id = p_budget_used_by_id
                        AND a2.plan_type = p_budget_used_by_type
                        AND a2.utilization_type IN ('TRANSFER', 'REQUEST', 'UTILIZED')

--                        AND a2.status_code = 'APPROVED' -- -- only approved record are present here
                   GROUP BY a2.fund_id, a2.currency_code)
         GROUP BY parent_src_id, parent_currency
         ORDER BY parent_src_id;
*/

/*
      CURSOR c_act_util_rec (
         p_used_by_id      IN   NUMBER
        ,p_used_by_type    IN   VARCHAR2
        ,p_parent_src_id   IN   NUMBER
      ) IS
         SELECT activity_budget_id
               ,object_version_number
               ,approved_amount
               ,parent_src_apprvd_amt
           FROM ozf_act_budgets
          WHERE act_budget_used_by_id = p_used_by_id
            AND arc_act_budget_used_by = p_used_by_type

--            AND parent_source_id = p_parent_src_id
            AND transfer_type = 'UTILIZED';
*/
    --  l_parent_source_rec     c_parent_source%ROWTYPE;
      l_api_version           NUMBER                                  := 1.0;
      l_return_status         VARCHAR2 (1)                            := fnd_api.g_ret_sts_success;
      l_api_name              VARCHAR2 (60)                           := 'create_budget_amount_utilized';
      l_act_budget_id         NUMBER;
      l_act_budgets_rec       ozf_actbudgets_pvt.act_budgets_rec_type;
      l_util_amount           NUMBER                                  := 0;
      l_amount_remaining      NUMBER                                  := 0;
      l_full_name    CONSTANT VARCHAR2 (90)                           :=    g_pkg_name
                                                                         || '.'
                                                                         || l_api_name;
      l_amount                NUMBER                                  := 0;
      l_converted_amt         NUMBER;
      l_activity_id           NUMBER;
      l_obj_ver_num           NUMBER;
      l_old_approved_amount   NUMBER;
      l_old_parent_src_amt    NUMBER;
      l_utilized_amount     NUMBER;

   BEGIN
      SAVEPOINT create_budget_amt_utilized;
      x_return_status            := fnd_api.g_ret_sts_success;
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (': begin ');
      END IF;

      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      <<cost_line_tbl_loop>>
      FOR k IN NVL (p_cost_tbl.FIRST, 1) .. NVL (p_cost_tbl.LAST, 0)
      LOOP
         /*   OPEN c_parent_source;

            <<parent_cur_loop>>
            LOOP
               FETCH c_parent_source INTO l_parent_source_rec;

               -- change later if a error has to be raised or not.
               IF c_parent_source%NOTFOUND THEN
                  ozf_utility_pvt.error_message ('OZF_ACT_BUDG_UTIL_OVER');
               END IF;

               EXIT WHEN c_parent_source%NOTFOUND;
          */
               --- convert the cost currency into the campaign currency
         IF p_currency = p_cost_tbl (k).cost_curr THEN
            l_amount                   := p_cost_tbl (k).cost_amount; -- inrequest currency
         ELSE
            -- call the currency conversion wrapper
            ozf_utility_pvt.convert_currency (
               x_return_status=> x_return_status
              ,p_from_currency=> p_cost_tbl (k).cost_curr
              ,p_to_currency=> p_currency
              ,p_from_amount=> p_cost_tbl (k).cost_amount
              ,x_to_amount=> l_amount
            );

            IF x_return_status <> fnd_api.g_ret_sts_success THEN
               x_return_status            := fnd_api.g_ret_sts_error;
               RAISE fnd_api.g_exc_error;
            END IF;
         END IF;

         /*
          -- convert the object currency amount in to fund currency
          IF l_parent_source_rec.parent_currency = p_currency THEN
             l_converted_amt            := l_amount;
          ELSE
             -- call the currency conversion wrapper
             ozf_utility_pvt.convert_currency (
                x_return_status=> x_return_status
               ,p_from_currency=> p_currency
               ,p_to_currency=> l_parent_source_rec.parent_currency
               ,p_from_amount=> l_amount
               ,x_to_amount=> l_converted_amt
             );

             IF x_return_status <> fnd_api.g_ret_sts_success THEN
                x_return_status            := fnd_api.g_ret_sts_error;
                RAISE fnd_api.g_exc_error;
             END IF;
          END IF;

          -- check against the converted amount but update the amount in parent currency
          IF NVL (l_parent_source_rec.total_amount, 0) >= NVL (l_converted_amt, 0) THEN
             l_util_amount              := l_amount; -- in req currency
             l_amount_remaining         :=   l_amount
                                           - l_util_amount; -- in request currency
          ELSIF NVL (l_parent_source_rec.total_amount, 0) < NVL (l_converted_amt, 0) THEN
             -- call the currency conversion wrapper
             ozf_utility_pvt.convert_currency (
                x_return_status=> x_return_status
               ,p_from_currency=> l_parent_source_rec.parent_currency
               ,p_to_currency=> p_currency
               ,p_from_amount=> l_parent_source_rec.total_amount
               ,x_to_amount=> l_util_amount
             );
             l_amount_remaining         :=   l_amount
                                           - l_util_amount; -- in req currnecy
          END IF;
         */
         l_util_amount              := l_amount; -- in req currency
         l_amount                   := l_amount_remaining; -- in req currency

         IF l_util_amount <> 0 THEN
            -- don't need to convert if currencies are equal
            l_act_budgets_rec.request_amount := l_util_amount;
            IF G_DEBUG THEN
               ozf_utility_pvt.debug_message (   l_full_name
                                           || ': begin create act budgets ');
            END IF;
            l_act_budgets_rec.act_budget_used_by_id := p_budget_used_by_id;
            l_act_budgets_rec.arc_act_budget_used_by := p_budget_used_by_type;
            l_act_budgets_rec.budget_source_type := p_budget_used_by_type;
            l_act_budgets_rec.budget_source_id := p_budget_used_by_id;
            l_act_budgets_rec.request_currency := p_currency;
            l_act_budgets_rec.request_date := SYSDATE;
            l_act_budgets_rec.user_status_id := 5001;
            l_act_budgets_rec.status_code := 'APPROVED';
            l_act_budgets_rec.transfer_type := 'UTILIZED';
            --l_act_budgets_rec.approved_original_amount := l_parent_source_rec.total_amount;
            --l_act_budgets_rec.approved_in_currency := l_parent_source_rec.total_amount;
            l_act_budgets_rec.approval_date := SYSDATE;
            l_act_budgets_rec.approver_id := ozf_utility_pvt.get_resource_id (fnd_global.user_id);
            l_act_budgets_rec.justification :=
                                        TO_CHAR (p_cost_tbl (k).cost_id)
                                     || p_cost_tbl (k).cost_desc;
            --  l_act_budgets_rec.parent_source_id := l_parent_source_rec.parent_src_id;

            --  l_act_budgets_rec.parent_src_curr := l_parent_source_rec.parent_currency;
/*
            OPEN c_act_util_rec (
               p_budget_used_by_id
              ,p_budget_used_by_type
              ,l_parent_source_rec.parent_src_id
            );
            FETCH c_act_util_rec INTO l_activity_id, l_obj_ver_num, l_old_approved_amount,l_old_parent_src_amt;
            CLOSE c_act_util_rec;

            IF l_activity_id IS NULL THEN
               l_act_budgets_rec.approved_amount := l_util_amount;
            l_act_budgets_rec.parent_src_apprvd_amt := l_parent_source_rec.total_amount;
               ozf_actbudgets_pvt.create_act_budgets (
                  p_api_version=> l_api_version
                 ,x_return_status=> l_return_status
                 ,x_msg_count=> x_msg_count
                 ,x_msg_data=> x_msg_data
                 ,p_act_budgets_rec=> l_act_budgets_rec
                 ,x_act_budget_id=> l_act_budget_id
               );

               IF l_return_status = fnd_api.g_ret_sts_error THEN
                  RAISE fnd_api.g_exc_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                  RAISE fnd_api.g_exc_unexpected_error;
               END IF;
            ELSE
               l_act_budgets_rec.request_amount :=   l_old_approved_amount
                                                   + l_util_amount;
               l_act_budgets_rec.parent_src_apprvd_amt := l_parent_source_rec.total_amount + l_old_parent_src_amt;
               l_act_budgets_rec.activity_budget_id := l_activity_id;
               l_act_budgets_rec.object_version_number := l_obj_ver_num;
               ozf_actbudgets_pvt.update_act_budgets (
                  p_api_version=> l_api_version
                 ,x_return_status=> l_return_status
                 ,x_msg_count=> x_msg_count
                 ,x_msg_data=> x_msg_data
                 ,p_act_budgets_rec=> l_act_budgets_rec
               );
            END IF;
*/
             process_act_budgets (x_return_status  => l_return_status,
                                  x_msg_count => x_msg_count,
                                  x_msg_data   => x_msg_data,
                                  p_act_budgets_rec => l_act_budgets_rec,
                                  p_act_util_rec   =>ozf_actbudgets_pvt.G_MISS_ACT_UTIL_REC,
                                  x_act_budget_id  => l_act_budget_id,
                                  x_utilized_amount => l_utilized_amount
                                 ) ;

            IF l_return_status = fnd_api.g_ret_sts_error THEN
               RAISE fnd_api.g_exc_error;
            ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
               RAISE fnd_api.g_exc_unexpected_error;
            END IF;
            --Raise error message if committed amount is less then
            IF l_util_amount > l_utilized_amount  AND  l_utilized_amount = 0   THEN
                 IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                     fnd_message.set_name('OZF', 'OZF_COMMAMT_LESS_REQAMT');
                     fnd_msg_pub.ADD;
                 END IF;
            END IF;

         END IF;

          /*
            EXIT WHEN l_amount_remaining = 0;
            IF G_DEBUG THEN
               ozf_utility_pvt.debug_message (   l_full_name
                                           || ': end create act budgets  ');
            END IF;
            l_activity_id              := NULL;
            l_act_budgets_rec          := NULL;
            END LOOP parent_cur_loop;
         */
         -- initiallize these variable

         l_amount_remaining         := 0;
         l_amount                   := 0;
         l_converted_amt            := 0;
         l_util_amount              := 0;

--         CLOSE c_parent_source;
      END LOOP cost_line_tbl_loop;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO create_budget_amt_utilized;
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO create_budget_amt_utilized;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN OTHERS THEN
         ROLLBACK TO create_budget_amt_utilized;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
   END create_budget_amt_utilized;



---------------------------------------------------------------------
   -- NAME
   --    get_parent_Src
   -- PURPOSE
   -- API to automaticaly populate the parent_source_id ( fund_id), parent_src_curr, parent_src_apprv_amt
   -- HISTORY
   -- 04/27/2001 mpande   Created.
   -- 08/05/2005 feliu    Use ozf_object_fund_summary table to get committed budgets.
---------------------------------------------------------------------

   PROCEDURE get_parent_src (
      p_budget_source_type   IN       VARCHAR2
     ,p_budget_source_id     IN       NUMBER
     ,p_amount               IN       NUMBER
     ,p_req_curr             IN       VARCHAR2
     ,p_mode                 IN       VARCHAR2 := jtf_plsql_api.g_create
     ,p_old_amount           IN       NUMBER := 0
     ,p_exchange_rate_type   IN       VARCHAR2 DEFAULT NULL --Added for bug 7030415
     ,x_return_status        OUT NOCOPY      VARCHAR2
     ,x_parent_src_tbl       OUT NOCOPY      parent_src_tbl_type
   ) IS

      CURSOR c_parent_source IS
        SELECT fund_id parent_source
               ,fund_currency parent_curr
               ,NVL(committed_amt,0)-NVL(utilized_amt,0) total_amount
               ,NVL(univ_curr_committed_amt,0)-NVL(univ_curr_utilized_amt,0) total_acctd_amount
        FROM ozf_object_fund_summary
        WHERE object_id =p_budget_source_id
        AND object_type = p_budget_source_type;


/*
             SELECT   parent_source
                 ,parent_curr
                 ,SUM (amount) total_amount
                 ,SUM(acctd_amount) total_acctd_amount
             FROM (SELECT   a1.fund_id parent_source
                           ,a1.currency_code parent_curr
                           ,SUM(NVL(a1.amount, 0)) amount
                           ,SUM(NVL(a1.acctd_amount,0)) acctd_amount
                       FROM ozf_funds_utilized_all_b a1
                       WHERE a1.component_id = p_budget_source_id
                       AND a1.component_type = p_budget_source_type
                        AND a1.utilization_type NOT IN
                                               ('ADJUSTMENT', 'ACCRUAL', 'UTILIZED', 'SALES_ACCRUAL', 'CHARGEBACK')
                   GROUP BY a1.fund_id, a1.currency_code
                   UNION
                   SELECT   a2.fund_id parent_source
                           ,a2.currency_code parent_curr
                           ,-SUM(NVL(a2.amount, 0)) amount,
                                          -SUM(NVL(a2.acctd_amount,0)) acctd_amount
                       FROM ozf_funds_utilized_all_b a2
                      WHERE a2.plan_id = p_budget_source_id
                        AND a2.plan_type =p_budget_source_type
                   GROUP BY a2.fund_id, a2.currency_code)
         GROUP BY parent_source, parent_curr
         ORDER BY parent_source;
*/
         CURSOR c_total_acct_amt IS
           SELECT SUM(NVL(univ_curr_committed_amt,0) - NVL(univ_curr_utilized_amt,0))
           FROM ozf_object_fund_summary
           WHERE object_id =p_budget_source_id
           AND object_type = p_budget_source_type;

/*
                SELECT   SUM(acctd_amount) total_acctd_amount
                FROM (SELECT   SUM(NVL(a1.acctd_amount,0)) acctd_amount
                              FROM ozf_funds_utilized_all_b a1
                              WHERE a1.component_id = p_budget_source_id
                             AND a1.component_type =p_budget_source_type
                             AND a1.utilization_type NOT IN
                                               ('ADJUSTMENT', 'ACCRUAL', 'UTILIZED', 'SALES_ACCRUAL', 'CHARGEBACK')
                             UNION
                            SELECT -SUM(NVL(a2.acctd_amount,0)) acctd_amount
                            FROM ozf_funds_utilized_all_b a2
                            WHERE a2.plan_id = p_budget_source_id
                            AND a2.plan_type = p_budget_source_type);
*/
      l_parent_source_rec   c_parent_source%ROWTYPE;
      l_converted_amt       NUMBER;
      p_updated_amount      NUMBER                    := 0;
      l_counter             NUMBER;
      l_amount_remaining    NUMBER;
      l_old_currency        VARCHAR2(30);
      l_acctd_amount        NUMBER;
      l_amount              NUMBER;
      l_total_amount        NUMBER;

      l_rate                NUMBER;  --Added for bug 7030415

   BEGIN
      x_return_status        := fnd_api.g_ret_sts_success;
      l_total_amount         := p_amount; -- amount in object currency
      l_counter                  := 1;
      l_old_currency             := p_req_curr; -- object currency.
      l_amount_remaining  := p_amount;

     OPEN c_total_acct_amt;
     FETCH c_total_acct_amt INTO l_acctd_amount;
     CLOSE c_total_acct_amt;

      OPEN c_parent_source;
      LOOP
         FETCH c_parent_source INTO l_parent_source_rec;
         EXIT WHEN c_parent_source%NOTFOUND;

--         IF l_parent_source_rec.total_amount <> 0 THEN

             IF l_acctd_amount = 0 THEN -- no committed amount but g_recal_flag is 'Y', then only create utilization for first budget.
                l_amount := l_total_amount;
             ELSE -- propotional distribute amount based on remaining amount.
                l_amount := ozf_utility_pvt.currround(l_parent_source_rec.total_acctd_amount / l_acctd_amount * l_total_amount, l_old_currency);
             END IF;

             l_amount_remaining :=l_amount_remaining - l_amount;

                -- This conversion should essentially be based
                --on utilization org, since the converted amount is used to populate the
                --amount column of utilization table.
            IF G_DEBUG THEN
               ozf_utility_pvt.debug_message('parent_curr '|| l_parent_source_rec.parent_curr);
               ozf_utility_pvt.debug_message('l_old_currency '|| l_old_currency);
               ozf_utility_pvt.debug_message('l_amount '||l_amount);
            END IF;

              IF l_parent_source_rec.parent_curr <> l_old_currency THEN
                  ozf_utility_pvt.convert_currency (
                      x_return_status=> x_return_status
                     ,p_from_currency=> l_old_currency
                     ,p_to_currency=> l_parent_source_rec.parent_curr
                     ,p_conv_type=> p_exchange_rate_type --Added for bug 7030415
                     ,p_from_amount=> l_amount
                     ,x_to_amount=> l_converted_amt
                     ,x_rate=>l_rate
                     );
               ELSE
                  l_converted_amt := l_amount;
               END IF;

               x_parent_src_tbl (l_counter).fund_id := l_parent_source_rec.parent_source;
               x_parent_src_tbl (l_counter).fund_curr := l_parent_source_rec.parent_curr;
               x_parent_src_tbl (l_counter).fund_amount := l_converted_amt;
               x_parent_src_tbl (l_counter).plan_amount := l_amount;
               l_counter := l_counter + 1;

        -- END IF;
          EXIT WHEN l_acctd_amount = 0; -- for no committed amount.
          -- could have negative utilization amount. commented by feliu on 08/26/2005.
          --EXIT WHEN l_amount_remaining <= 0;

      END LOOP;

      CLOSE c_parent_source;

   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status            := fnd_api.g_ret_sts_error;
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
      WHEN OTHERS THEN
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

   END get_parent_src;


/*****************************************************************************************/
-- Start of Comments
-- NAME
--    Create Fund Utilization
-- PURPOSE
--  Create utilizations for the utlized amount of that  activity
-- called only from ozf_Act_budgets API for utlized amount creation
-- HISTORY
-- 02/23/2001  mpande  CREATED
-- 02/28/02    feliu   Added condition for manual adjustment.
---------------------------------------------------------------------

   PROCEDURE create_fund_utilization (
      p_act_budget_rec   IN       ozf_actbudgets_pvt.act_budgets_rec_type
     ,x_return_status    OUT NOCOPY      VARCHAR2
     ,x_msg_count        OUT NOCOPY      NUMBER
     ,x_msg_data         OUT NOCOPY      VARCHAR2
     ,p_act_util_rec     IN       ozf_actbudgets_pvt.act_util_rec_type
            := ozf_actbudgets_pvt.g_miss_act_util_rec
   ) IS
     l_utilized_amount    NUMBER;
   BEGIN
     create_fund_utilization (
        p_act_budget_rec   => p_act_budget_rec
       ,x_return_status    => x_return_status
       ,x_msg_count        => x_msg_count
       ,x_msg_data         => x_msg_data
       ,p_act_util_rec     => p_act_util_rec
       ,x_utilized_amount  => l_utilized_amount);
   END create_fund_utilization;

   PROCEDURE create_fund_utilization (
      p_act_budget_rec   IN       ozf_actbudgets_pvt.act_budgets_rec_type
     ,x_return_status    OUT NOCOPY      VARCHAR2
     ,x_msg_count        OUT NOCOPY      NUMBER
     ,x_msg_data         OUT NOCOPY      VARCHAR2
     ,p_act_util_rec     IN       ozf_actbudgets_pvt.act_util_rec_type
            := ozf_actbudgets_pvt.g_miss_act_util_rec
     ,x_utilized_amount  OUT NOCOPY      NUMBER
   ) IS
     l_utilization_id NUMBER;
   BEGIN

     --kdass - added for Bug 8726683
     create_fund_utilization (
        p_act_budget_rec   => p_act_budget_rec
       ,x_return_status    => x_return_status
       ,x_msg_count        => x_msg_count
       ,x_msg_data         => x_msg_data
       ,p_act_util_rec     => p_act_util_rec
       ,x_utilized_amount  => x_utilized_amount
       ,x_utilization_id   => l_utilization_id);

   END create_fund_utilization;


/*****************************************************************************************/
-- Start of Comments
-- NAME
--    Create Fund Utilization
-- PURPOSE
--  Create utilizations for the utlized amount of that  activity
--   called only from ozf_Act_budgets API for utlized amount creation
-- HISTORY
-- 02/23/2001  mpande  CREATED
-- 02/28/02    feliu   Added condition for manual adjustment.
-- 06/21/2004  yzhao   Added x_utilized_amount to return actual utilized amount
---------------------------------------------------------------------

   PROCEDURE create_fund_utilization (
      p_act_budget_rec   IN       ozf_actbudgets_pvt.act_budgets_rec_type
     ,x_return_status    OUT NOCOPY      VARCHAR2
     ,x_msg_count        OUT NOCOPY      NUMBER
     ,x_msg_data         OUT NOCOPY      VARCHAR2
     ,p_act_util_rec     IN       ozf_actbudgets_pvt.act_util_rec_type
            := ozf_actbudgets_pvt.g_miss_act_util_rec
     ,x_utilized_amount  OUT NOCOPY      NUMBER
     ,x_utilization_id   OUT NOCOPY      NUMBER
   ) IS
       l_api_version         CONSTANT NUMBER                                     := 1.0;
      l_api_name            CONSTANT VARCHAR2 (30)                              := 'create_fund_utilization';
      l_full_name           CONSTANT VARCHAR2 (60)                              :=    g_pkg_name
                                                                                   || '.'
                                                                                   || l_api_name;
     l_util_rec                 ozf_fund_utilized_pvt.utilization_rec_type;
      --l_util_id                  NUMBER;
      l_util_amount              NUMBER;
      l_return_status            VARCHAR2 (1)                               := fnd_api.g_ret_sts_success;
      l_obj_number               NUMBER;
      l_parent_src_tbl           parent_src_tbl_type;
      l_fund_transfer_flag       VARCHAR2 (1)                               := 'N';
      l_offer_type               VARCHAR2 (30);
      l_qlf_type                 VARCHAR2 (30);
      l_qlf_id                   NUMBER;
      l_src_fund_type            VARCHAR2 (30);
      l_src_fund_accrual_basis   VARCHAR2 (30);
      l_accrual_flag             VARCHAR2 (1);
      l_plan_id                  NUMBER;
      l_budget_offer_yn          VARCHAR2(1) := 'N';
      l_fund_id                  NUMBER;
      l_accrual_basis            VARCHAR2 (30);
      l_fund_currency            VARCHAR2 (30);
      l_total_amount             NUMBER;
      l_cust_account_id          NUMBER;
      l_bill_to_site_id          NUMBER;
      l_beneficiary_account_id   NUMBER;
      l_check_request           VARCHAR2 (10);

      --Added variables/c_org_id for bugfix 6278466
      l_org_id                   NUMBER;
      l_autopay_party_id         NUMBER;

      l_autopay_party_attr       VARCHAR2(30);

      CURSOR c_org_id (p_site_use_id IN NUMBER) IS
         SELECT org_id
           FROM hz_cust_site_uses_all
          WHERE site_use_id = p_site_use_id;

      -- 11/13/2001 mpande removed qualifier type
      -- Added autopay_party_id for bugfix 6278466
      CURSOR c_offer_type (p_offer_id IN NUMBER) IS
         SELECT offer_type
               ,qualifier_id,qualifier_type,NVL(budget_offer_yn,'N'),beneficiary_account_id,
               autopay_party_attr,autopay_party_id
           FROM ozf_offers
          WHERE qp_list_header_id = p_offer_id;

      CURSOR c_funds (p_ofr_fund_id IN NUMBER) IS
         SELECT fund_type
               ,accrual_basis,plan_id
           FROM ozf_funds_all_b
          WHERE fund_id = p_ofr_fund_id;
      -- 6/13/2002 mpande added for deal type ofer
      CURSOR c_accrual_flag (p_price_adjustment_id IN NUMBER) IS
         SELECT NVL(accrual_flag,'N')
           FROM oe_price_adjustments
          WHERE price_Adjustment_id = p_price_Adjustment_id;

      -- 07/30/03 feliu added for accrual budget.
      CURSOR c_fund_plan (p_plan_id IN NUMBER) IS
        SELECT fund_id , currency_code_tc, accrual_basis
        FROM ozf_funds_all_b
        WHERE plan_id = p_plan_id;

      -- 18-JAN-05 kdass get the cust_account_id from cust_acct_site_id
      -- rimehrot for R12, added bill_to_site_use_id
      CURSOR c_cust_account_id (p_site_use_id IN NUMBER) IS
        SELECT sites.cust_account_id, uses.bill_to_site_use_id
           FROM hz_cust_acct_sites_all sites, hz_cust_site_uses_all uses
           WHERE uses.site_use_id = p_site_use_id
             AND sites.cust_acct_site_id = uses.cust_acct_site_id;

     CURSOR c_get_cust_account_id(p_party_id IN NUMBER) IS
        select max(cust_account_id) from hz_cust_accounts
        where party_id = p_party_id
        and status= 'A';

        -- rimehrot, bug fix 4030022
      CURSOR c_check_budget_request(p_offer_id IN NUMBER, p_fund_id IN NUMBER) IS
      SELECT 'X' FROM ozf_act_budgets
      WHERE act_budget_used_by_id = p_offer_id
      AND budget_source_id = p_fund_id
      AND status_code ='APPROVED'
      AND transfer_type = 'REQUEST';

      --Added for bug 7030415

       CURSOR c_get_conversion_type( p_org_id IN NUMBER) IS
       SELECT exchange_rate_type
       FROM   ozf_sys_parameters_all
       WHERE  org_id = p_org_id;


      l_exchange_rate_type      VARCHAR2(30) := FND_API.G_MISS_CHAR;
      l_rate                    NUMBER;
      l_fund_reconc_msg         VARCHAR2(4000);
      l_act_bud_cst_msg         VARCHAR2(4000);


   BEGIN
        SAVEPOINT create_utilization;

      l_total_amount := 0;
      --Added for bug 7425189
      l_fund_reconc_msg := fnd_message.get_string ('OZF', 'OZF_FUND_RECONCILE');
      l_act_bud_cst_msg := fnd_message.get_string ('OZF', 'OZF_ACT_BUDG_CST_UTIL');


      IF l_fund_transfer_flag = 'N' THEN
         -- 01/02/2002 mpande changed for utilization changes
         IF p_act_budget_rec.budget_source_type = 'FUND' THEN
            l_parent_src_tbl (1).fund_id := p_act_budget_rec.budget_source_id;
            l_parent_src_tbl (1).fund_curr := p_act_budget_rec.approved_in_currency;
            l_parent_src_tbl (1).fund_amount := p_act_budget_rec.approved_original_amount;
            l_parent_src_tbl (1).plan_amount := p_act_budget_rec.approved_original_amount;
         ELSIF      p_act_budget_rec.transfer_type = 'TRANSFER'
                AND p_act_budget_rec.arc_act_budget_used_by = 'FUND' THEN
            l_parent_src_tbl (1).fund_id := p_act_budget_rec.act_budget_used_by_id;
            -- 12/18/2001 changed here for currency change ***
            /*l_parent_src_tbl (1).fund_curr := p_act_budget_rec.approved_in_currency;
              l_parent_src_tbl (1).fund_amount := p_act_budget_rec.approved_original_amount;
            */
            l_parent_src_tbl (1).fund_curr := p_act_budget_rec.request_currency;
            l_parent_src_tbl (1).fund_amount := p_act_budget_rec.approved_amount;
            l_parent_src_tbl (1).plan_amount := p_act_budget_rec.approved_amount;

/*         ELSIF      p_act_budget_rec.transfer_type = 'UTILIZED'
                AND p_act_budget_rec.arc_act_budget_used_by IN ('OFFR','CAMP','EVEH','DELV') THEN
            l_parent_src_tbl (1).fund_id := p_act_budget_rec.act_budget_used_by_id;
            l_parent_src_tbl (1).fund_curr := p_act_budget_rec.approved_in_currency;
            l_parent_src_tbl (1).fund_amount := p_act_budget_rec.approved_original_amount;
            */

         ELSE
            IF p_act_budget_rec.transfer_type = 'UTILIZED' THEN
               -- added by feliu to fix bug for accrual budget.
               IF p_act_budget_rec.budget_source_type = 'OFFR' THEN
                       OPEN c_offer_type (p_act_budget_rec.budget_source_id);
                       --Added l_autopay_party_id for bugfix 6278466
                       FETCH c_offer_type INTO l_offer_type, l_qlf_id,l_qlf_type,l_budget_offer_yn,l_beneficiary_account_id,
                                               l_autopay_party_attr,l_autopay_party_id;
                       CLOSE c_offer_type;
               END IF;

               --Added for bug 7030415
               IF p_act_util_rec.exchange_rate_type IS NULL
               OR p_act_util_rec.exchange_rate_type = fnd_api.g_miss_char THEN
               OPEN c_get_conversion_type(p_act_util_rec.org_id);
               FETCH c_get_conversion_type INTO l_exchange_rate_type;
               CLOSE c_get_conversion_type;

               ELSE
                  l_exchange_rate_type := p_act_util_rec.exchange_rate_type;
               END IF;
               -- For accrual budget, do not fetch committed amount.
               IF l_budget_offer_yn = 'Y' THEN
                       OPEN c_fund_plan (p_act_budget_rec.budget_source_id);
                       FETCH c_fund_plan INTO l_fund_id,l_fund_currency,l_accrual_basis;
                       CLOSE c_fund_plan;

                  --05/06/2004  kdass fix for bug 3586046
                  --08/18/2005  feliu fix for third party accrual.
               /*   IF l_accrual_basis ='CUSTOMER' THEN
                     IF p_act_budget_rec.parent_source_id <> l_fund_id THEN
                        fnd_message.set_name ('OZF', 'OZF_FUND_OFFR_ADJ');
                        fnd_msg_pub.ADD;
                        RAISE fnd_api.g_exc_error;
                     END IF;
               */
               --Added for bug 7030415, In case of accrual budget.
               --Need to use the org_id since the converted amount is used to populate
               --the amount column of utilization table. p_act_util_rec.org_id


               IF p_act_budget_rec.request_currency  <>l_fund_currency THEN

                  IF G_DEBUG THEN
                     ozf_utility_pvt.debug_message (   l_full_name
                             || ' p_act_budget_rec.exchange_rate_date1: ' || p_act_budget_rec.exchange_rate_date);
                  END IF;

                 --Added for bug 7425189
                 IF p_act_budget_rec.justification IN (l_fund_reconc_msg,l_act_bud_cst_msg)
                 AND p_act_budget_rec.exchange_rate_date IS NOT NULL THEN
                    ozf_utility_pvt.convert_currency (
                    x_return_status=> l_return_status,
                    p_from_currency=> p_act_budget_rec.request_currency,
                    p_to_currency=> l_fund_currency,
                    p_conv_date=> p_act_budget_rec.exchange_rate_date,
                    p_from_amount=> p_act_budget_rec.approved_amount,
                    x_to_amount=> l_util_amount,
                    x_rate=>l_rate
                   );
                 ELSE
                    ozf_utility_pvt.convert_currency (
                    x_return_status => l_return_status,
                    p_from_currency => p_act_budget_rec.request_currency,
                    p_to_currency   => l_fund_currency,
                    p_conv_type     => l_exchange_rate_type,
                    p_conv_date     => p_act_budget_rec.exchange_rate_date, --bug 8532055
                    p_from_amount   => p_act_budget_rec.approved_amount,
                    x_to_amount     => l_util_amount,
                    x_rate          =>l_rate
                   );
                  END IF;

                ELSE
                  l_util_amount := p_act_budget_rec.request_amount;
                END IF;

                     l_parent_src_tbl (1).fund_id := l_fund_id;
                     l_parent_src_tbl (1).fund_curr := l_fund_currency;
                     l_parent_src_tbl (1).fund_amount := l_util_amount;
                     l_parent_src_tbl (1).plan_amount :=p_act_budget_rec.request_amount;

                     IF G_DEBUG THEN
                        ozf_utility_pvt.debug_message (':for accrual budget ' || l_util_amount );
                     END IF;
                  -- for SALES budget, should same as customer accrual.
                  --08/18/2005  feliu fix for third party accrual.
                /*  ELSE
                     l_parent_src_tbl (1).fund_id := p_act_budget_rec.parent_source_id; --l_fund_id;
                     l_parent_src_tbl (1).fund_curr := p_act_budget_rec.parent_src_curr;--l_fund_currency;
                     l_parent_src_tbl (1).fund_amount := p_act_budget_rec.parent_src_apprvd_amt;--l_util_amount;
                     l_parent_src_tbl (1).plan_amount := p_act_budget_rec.request_amount;
                */
                --END IF;

           -- end of  accrual budget.


               ELSIF    p_act_budget_rec.parent_source_id IS NULL
                  OR p_act_budget_rec.parent_source_id = fnd_api.g_miss_num THEN
                  --Added for bug 7030415 , For fixed budget
                  --nirprasa,12.2 adjustment_net_accrual flow comes to this else condition.
                  --While updating ozf_act_budgets 'UTILIZED' recs, p_act_util_rec.plan_curr_amount
                  --holds the amount in plan currency. SO send this amount for conversion to budget's curr.
                  IF G_DEBUG THEN
                   ozf_utility_pvt.debug_message('budget_source_type '|| p_act_budget_rec.budget_source_type);
                   ozf_utility_pvt.debug_message('p_act_budget_rec.approved_amount '|| p_act_budget_rec.approved_amount);
                   ozf_utility_pvt.debug_message('p_act_budget_rec.request_currency '|| p_act_budget_rec.request_currency);
                   ozf_utility_pvt.debug_message('p_act_util_rec.plan_curr_amount '|| p_act_util_rec.plan_curr_amount);
                   ozf_utility_pvt.debug_message('p_act_util_rec.plan_currency_code '|| p_act_util_rec.plan_currency_code);
                  END IF;
                  IF p_act_util_rec.plan_curr_amount IS NULL
                  OR p_act_util_rec.plan_curr_amount = FND_API.G_MISS_NUM THEN
                  get_parent_src (
                     p_budget_source_type=> p_act_budget_rec.budget_source_type
                    ,p_budget_source_id=> p_act_budget_rec.budget_source_id
                    ,p_amount=> p_act_budget_rec.approved_amount
                    ,p_req_curr=> p_act_budget_rec.request_currency
                    ,p_exchange_rate_type=>l_exchange_rate_type
                    ,x_return_status=> l_return_status
                    ,x_parent_src_tbl=> l_parent_src_tbl
                  );
                  ELSE
                  get_parent_src (
                     p_budget_source_type=> p_act_budget_rec.budget_source_type
                    ,p_budget_source_id=> p_act_budget_rec.budget_source_id
                    ,p_amount=> p_act_util_rec.plan_curr_amount
                    ,p_req_curr=> p_act_budget_rec.request_currency
                    ,p_exchange_rate_type=>l_exchange_rate_type
                    ,x_return_status=> l_return_status
                    ,x_parent_src_tbl=> l_parent_src_tbl
                  );
                  END IF;
                 /*
                  IF l_return_status = fnd_api.g_ret_sts_error THEN
                      RAISE fnd_api.g_exc_error;
                  ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                      RAISE fnd_api.g_exc_unexpected_error;
                  END IF;
*/               ELSE
                  l_parent_src_tbl (1).fund_id := p_act_budget_rec.parent_source_id;
                  l_parent_src_tbl (1).fund_curr := p_act_budget_rec.parent_src_curr;
                  l_parent_src_tbl (1).fund_amount := p_act_budget_rec.parent_src_apprvd_amt;
                  l_parent_src_tbl (1).plan_amount := p_act_budget_rec.request_amount;
               END IF;

            ELSE

               get_parent_src (
                  p_budget_source_type=> p_act_budget_rec.budget_source_type
                 ,p_budget_source_id=> p_act_budget_rec.budget_source_id
                 ,p_amount=> p_act_budget_rec.approved_amount
                 ,p_req_curr=> p_act_budget_rec.request_currency
                 ,p_exchange_rate_type=>l_exchange_rate_type
                 ,x_return_status=> l_return_status
                 ,x_parent_src_tbl=> l_parent_src_tbl
               );
  /*             IF l_return_status = fnd_api.g_ret_sts_error THEN
                      RAISE fnd_api.g_exc_error;
               ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                      RAISE fnd_api.g_exc_unexpected_error;
               END IF;
        */    END IF;
         END IF;
      END IF;

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_full_name||' : '||'g_recal_flag:   '||g_recal_flag);
      END IF;

      FOR i IN NVL (l_parent_src_tbl.FIRST, 1) .. NVL (l_parent_src_tbl.LAST, 0)
      LOOP
         l_util_rec := null;  -- fixed bug 5124036.
         l_total_amount := l_total_amount + NVL (l_parent_src_tbl (i).plan_amount, 0);
         -- Added condition by feliu on 02/25/02
         IF p_act_util_rec.utilization_type is NULL OR
             p_act_util_rec.utilization_type  = fnd_api.g_miss_char THEN
            l_util_rec.utilization_type := p_act_budget_rec.transfer_type;
         ELSE
            l_util_rec.utilization_type := p_act_util_rec.utilization_type;
         END IF;


         l_util_rec.fund_id         := l_parent_src_tbl (i).fund_id;
         l_util_rec.plan_type       := p_act_budget_rec.budget_source_type;
         l_util_rec.plan_id         := p_act_budget_rec.budget_source_id;
         l_util_rec.component_type  := p_act_budget_rec.arc_act_budget_used_by;
         l_util_rec.component_id    := p_act_budget_rec.act_budget_used_by_id;
         l_util_rec.ams_activity_budget_id := p_act_budget_rec.activity_budget_id;
         l_util_rec.amount          := NVL (l_parent_src_tbl (i).fund_amount, 0);
         l_util_rec.currency_code   := l_parent_src_tbl (i).fund_curr;
         /* Added on 10/18/2001 by feliu for recalculating committed.*/
         l_util_rec.adjustment_type_id := p_act_util_rec.adjustment_type_id;
         l_util_rec.adjustment_type := p_act_util_rec.adjustment_type;
         --l_util_rec.recal_comm_flag := p_act_util_rec.recal_comm_flag;
         /* Added on 02/08/2002 by Mpande */
         l_util_rec.adjustment_desc := p_act_budget_rec.justification;
         l_util_rec.object_type     := p_act_util_rec.object_type;
         l_util_rec.object_id       := p_act_util_rec.object_id;
         l_util_rec.camp_schedule_id := p_act_util_rec.camp_schedule_id;
         l_util_rec.product_level_type := p_act_util_rec.product_level_type;
         l_util_rec.product_id      := p_act_util_rec.product_id;
         l_util_rec.cust_account_id := p_act_util_rec.cust_account_id;
         l_util_rec.price_adjustment_id := p_act_util_rec.price_adjustment_id;
         l_util_rec.adjustment_date := p_act_util_rec.adjustment_date;
         l_util_rec.gl_date := p_act_util_rec.gl_date;
         /* added by feliu for 11.5.9 */
         l_util_rec.activity_product_id := p_act_util_rec.activity_product_id;
         l_util_rec.scan_unit := p_act_util_rec.scan_unit;
         l_util_rec.scan_unit_remaining := p_act_util_rec.scan_unit_remaining;
         l_util_rec.volume_offer_tiers_id := p_act_util_rec.volume_offer_tiers_id;
         /* added by yzhao for 11.5.10 */
         l_util_rec.reference_type := p_act_util_rec.reference_type;
         l_util_rec.reference_id := p_act_util_rec.reference_id;
         l_util_rec.billto_cust_account_id := p_act_util_rec.billto_cust_account_id;
           /*added by feliu for 11.5.10 */
         l_util_rec.order_line_id := p_act_util_rec.order_line_id;
         l_util_rec.org_id := p_act_util_rec.org_id;
           /*added by feliu for 11.5.10 */
         l_util_rec.gl_posted_flag := p_act_util_rec.gl_posted_flag;
         l_util_rec.orig_utilization_id := p_act_util_rec.orig_utilization_id;
           /* added by rimehrot for R12 */
         l_util_rec.bill_to_site_use_id := p_act_util_rec.bill_to_site_use_id;
         l_util_rec.ship_to_site_use_id := p_act_util_rec.ship_to_site_use_id;
           /* added by kdass for R12 */
         l_util_rec.gl_account_credit := p_act_util_rec.gl_account_credit;
         l_util_rec.gl_account_debit  := p_act_util_rec.gl_account_debit;



         --fix for bug 6657242
         l_util_rec.site_use_id := p_act_util_rec.site_use_id;

         --nirprasa, assign the amounts so as to skip conversion and rounding later.
         --for bugs 7505085, 7425189
         IF G_DEBUG THEN
         ozf_utility_pvt.debug_message ('ozfvadjb p_act_budget_rec.request_amount '||p_act_budget_rec.request_amount);
         END IF;
         IF p_act_util_rec.plan_curr_amount IS NULL
         OR p_act_util_rec.plan_curr_amount = FND_API.G_MISS_NUM THEN
         l_util_rec.plan_curr_amount := p_act_budget_rec.request_amount;
         l_util_rec.plan_curr_amount_remaining := p_act_budget_rec.request_amount;
         ELSE
            l_util_rec.plan_curr_amount           := p_act_util_rec.plan_curr_amount;
            l_util_rec.plan_curr_amount_remaining := p_act_util_rec.plan_curr_amount_remaining;
         END IF;
         l_util_rec.plan_currency_code         := p_act_util_rec.plan_currency_code;
         l_util_rec.fund_request_currency_code := p_act_util_rec.fund_request_currency_code;
         l_util_rec.exchange_rate_date         := p_act_util_rec.exchange_rate_date;
         l_util_rec.exchange_rate_type         := p_act_util_rec.exchange_rate_type;
         -- nirprasa,12.2 no need to assign the currency_code column. Its already assigned above.

         --kdass added flexfields
         l_util_rec.attribute_category  := p_act_util_rec.attribute_category;
         l_util_rec.attribute1  := p_act_util_rec.attribute1;
         l_util_rec.attribute2  := p_act_util_rec.attribute2;
         l_util_rec.attribute3  := p_act_util_rec.attribute3;
         l_util_rec.attribute4  := p_act_util_rec.attribute4;
         l_util_rec.attribute5  := p_act_util_rec.attribute5;
         l_util_rec.attribute6  := p_act_util_rec.attribute6;
         l_util_rec.attribute7  := p_act_util_rec.attribute7;
         l_util_rec.attribute8  := p_act_util_rec.attribute8;
         l_util_rec.attribute9  := p_act_util_rec.attribute9;
         l_util_rec.attribute10  := p_act_util_rec.attribute10;
         l_util_rec.attribute11  := p_act_util_rec.attribute11;
         l_util_rec.attribute12  := p_act_util_rec.attribute12;
         l_util_rec.attribute13  := p_act_util_rec.attribute13;
         l_util_rec.attribute14  := p_act_util_rec.attribute14;
         l_util_rec.attribute15  := p_act_util_rec.attribute15;

         IF  l_util_rec.utilization_type IN ('LEAD_ACCRUAL', 'ACCRUAL') THEN
             -- yzhao: 11.5.10 02/12/2004 fix bug 3438414 - MASS1R10 UNABLE TO QUERY EARNINGS AGAINST NET ACCRUAL OFFERS
             IF l_util_rec.amount_remaining IS NULL THEN
                l_util_rec.amount_remaining := l_util_rec.amount;
             END IF;
         ELSIF  l_util_rec.utilization_type = 'UTILIZED' THEN
             l_util_rec.adjustment_date := sysdate;
             -- yzhao: 10/20/2003 added PRIC for price list
             IF l_util_rec.plan_type = 'PRIC' THEN
                l_util_rec.utilization_type := 'ADJUSTMENT';
                l_util_rec.amount_remaining := l_util_rec.amount;
             ELSIF l_util_rec.plan_type = 'OFFR' THEN
                OPEN c_funds (l_util_rec.fund_id);
                FETCH c_funds INTO l_src_fund_type, l_src_fund_accrual_basis,l_plan_id;
                CLOSE c_funds;
                --for budget source from sales accrual budget.
                IF l_plan_id IS NOT NULL AND l_plan_id <> FND_API.g_miss_num THEN
                   IF l_plan_id <>  l_util_rec.component_id  THEN
                      l_src_fund_type := 'FIXED' ;
                   END IF;
                END IF;
                -- fix bug 4569075 by feliu on 08/25/2005 to populate benefiticary_account_id
                IF l_util_rec.billto_cust_account_id IS NULL THEN
                  --kdass 23-FEB-2004 fix for bug 3426061
                  -- If the Qualifier is a Buying group, then store Customer Account ID instead of Party ID
                  IF l_qlf_type = 'BUYER' THEN
                     OPEN c_get_cust_account_id(l_qlf_id);
                     FETCH c_get_cust_account_id INTO l_cust_account_id;
                     CLOSE c_get_cust_account_id;

                  -- kdass 18-JAN-05 Bug 4125112, if qualifier_type is 'BILL_TO' or 'SHIP_TO', then qualifier_id
                  -- is cust account site id. Query hz tables to get cust_account_id.
                  ELSIF l_qlf_type IN ('CUSTOMER_BILL_TO', 'SHIP_TO') THEN
                     OPEN c_cust_account_id (l_qlf_id);
                     FETCH c_cust_account_id INTO l_cust_account_id, l_bill_to_site_id;
                     CLOSE c_cust_account_id;
                     IF l_qlf_type = 'CUSTOMER_BILL_TO' THEN
                        l_util_rec.bill_to_site_use_id := l_qlf_id;
                     ELSIF l_qlf_type = 'SHIP_TO' THEN
                        l_util_rec.bill_to_site_use_id := l_bill_to_site_id;
                        l_util_rec.ship_to_site_use_id := l_qlf_id;
                     END IF;
                  ELSE
                     l_cust_account_id := l_qlf_id;
                  END IF;

                  l_util_rec.billto_cust_account_id := l_cust_account_id;

                END IF; -- end of   l_util_rec.billto_cust_account_id
                IF l_util_rec.cust_account_id IS NULL THEN
                   IF l_beneficiary_account_id IS NOT NULL THEN
                    IF l_autopay_party_attr <> 'CUSTOMER' AND l_autopay_party_attr IS NOT NULL THEN
                      --Added c_org_id for bugfix 6278466
                      OPEN c_org_id (l_autopay_party_id);
                      FETCH c_org_id INTO l_org_id;
                      CLOSE c_org_id;
                      l_util_rec.org_id := l_org_id;
                    END IF;
                      l_util_rec.cust_account_id := l_beneficiary_account_id;
                   ELSE
                      l_util_rec.cust_account_id := l_util_rec.billto_cust_account_id;
                   END IF;
                END IF; -- l_util_rec.cust_account_id

              -- end of bug fix 4569075

                IF l_src_fund_type = 'FIXED' THEN
                   IF l_offer_type IN ('ACCRUAL','LUMPSUM','SCAN_DATA','NET_ACCRUAL') THEN
                         l_util_rec.utilization_type := 'ACCRUAL';
                         --l_util_rec.adjustment_type_id := NULL;
                         --l_util_rec.adjustment_type := NULL;
                         l_util_rec.amount_remaining := l_parent_src_tbl (i).fund_amount;
                /*         IF l_offer_type = 'LUMPSUM' THEN
                            l_util_rec.cust_account_id := l_qlf_id;
                            -- kdass 18-JAN-05 Bug 4125112, if qualifier_type is 'BILL_TO' or 'SHIP_TO', then qualifier_id
                            -- is cust account site id. Query hz tables to get cust_account_id.
                            IF l_qlf_type IN ('CUSTOMER_BILL_TO', 'SHIP_TO') THEN
                               OPEN c_cust_account_id (l_qlf_id);
                               FETCH c_cust_account_id INTO l_cust_account_id, l_bill_to_site_id;
                               CLOSE c_cust_account_id;
                               l_util_rec.cust_account_id := l_cust_account_id;
                            END IF;
                         END IF;
                  */
                   ELSIF l_offer_type IN( 'DEAL','VOLUME_OFFER') THEN
                   -- 6/13/2002 mpande added for Trade Deal Offer -- It is a combof Off invoice and Accrual
                      l_accrual_flag :='N';
                      OPEN c_accrual_flag( l_util_rec.price_adjustment_id ) ;
                      FETCH c_accrual_flag INTO l_accrual_flag ;
                      CLOSE c_accrual_flag ;
                      IF l_accrual_flag = 'Y' THEN
                         l_util_rec.utilization_type := 'ACCRUAL';
                         --l_util_rec.adjustment_type_id := NULL;
                         --l_util_rec.adjustment_type := NULL;
                         l_util_rec.amount_remaining := l_parent_src_tbl (i).fund_amount;
                      -- for off invoice part of trade deal
                      ELSE
                         l_util_rec.utilization_type := 'UTILIZED';
                      END IF;
                   ELSE
                      l_util_rec.utilization_type := 'UTILIZED';
                   END IF;

                ELSE
                   IF l_src_fund_accrual_basis = 'SALES' THEN
                      l_util_rec.utilization_type := 'SALES_ACCRUAL';
                      --l_util_rec.amount_remaining := l_parent_src_tbl (i).fund_amount;
                   ELSIF l_src_fund_accrual_basis = 'CUSTOMER' THEN
                      l_util_rec.utilization_type := 'ACCRUAL';
                      l_util_rec.amount_remaining := l_parent_src_tbl (i).fund_amount;
                   END IF;
                END IF;

                -- for chargback, added on 12/23/02 by feliu and move out of fixed budget.
                IF   l_util_rec.object_type = 'TP_ORDER' THEN
                      l_util_rec.utilization_type := 'ACCRUAL';
                      l_util_rec.amount_remaining := l_parent_src_tbl (i).fund_amount;
                      IF G_DEBUG THEN
                         ozf_utility_pvt.debug_message (':for charge back: ' || l_parent_src_tbl (i).fund_amount );
                      END IF;
                END IF;

             END IF;
         END IF; -- end for utlization type = utilized

         --added by feliu for manual adjustment.
         -- 12/02/2003 yzhao: 11.5.10 chargeback
         IF l_util_rec.utilization_type IN ('ADJUSTMENT', 'CHARGEBACK') THEN
            l_util_rec.amount_remaining := l_util_rec.amount;
         IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_full_name||' : '||'l_util_rec.amount_remaining:   '|| l_util_rec.amount_remaining);
         END IF;
      END IF;

      -- check that cust_account_id is populated correctly
      -- added by rimehrot for R12, populate site id's
     /*
      IF l_qlf_type IS NOT NULL AND l_qlf_id IS NOT NULL THEN
      IF l_qlf_type IN ('CUSTOMER_BILL_TO', 'SHIP_TO') THEN
        OPEN c_cust_account_id (l_qlf_id);
                FETCH c_cust_account_id INTO l_cust_account_id, l_bill_to_site_id;
                CLOSE c_cust_account_id;

        IF l_qlf_type = 'CUSTOMER_BILL_TO' THEN
          l_util_rec.bill_to_site_use_id := l_qlf_id;
        ELSIF l_qlf_type = 'SHIP_TO' THEN
          l_util_rec.bill_to_site_use_id := l_bill_to_site_id;
          l_util_rec.ship_to_site_use_id := l_qlf_id;
        END IF;

      END IF; -- l_qlf_type is billto/shipto
      END IF; --l_qlf_type not null
*/
      --kdass 02-AUG-2005 - R12 change for paid adjustments
      IF l_util_rec.utilization_type = 'ADJUSTMENT' AND
            NVL(l_util_rec.adjustment_type, ' ') IN ('INCREASE_PAID', 'DECREASE_PAID') THEN
            l_util_rec.amount_remaining := - l_util_rec.amount;
            l_util_rec.amount := 0;
            --kdass fixed bug 9432297
            l_util_rec.plan_curr_amount_remaining := - l_util_rec.plan_curr_amount;
            l_util_rec.plan_curr_amount := 0;
            l_util_rec.fund_request_amount_remaining := - l_util_rec.fund_request_amount;
            l_util_rec.fund_request_amount := 0;

            l_util_rec.gl_posted_flag := ozf_accrual_engine.G_GL_FLAG_NO;
      END IF;


      IF l_util_rec.utilization_type = 'ADJUSTMENT'
      THEN
      -- check if there is a valid budget request
        -- rimehrot, bug fix 4030022
      OPEN c_check_budget_request(l_util_rec.plan_id, l_util_rec.fund_id);
        FETCH c_check_budget_request INTO l_check_request;
          IF c_check_budget_request%ROWCOUNT = 0 THEN
           ozf_utility_pvt.error_message('OZF_NO_FUND_REQUEST');
           RAISE fnd_api.g_exc_unexpected_error;
         END IF;
          CLOSE c_check_budget_request;
      END IF;

      /*bug 8532055
      --nirprasa for bug 7425189, send exchange_rate_date for utilization
      IF p_act_budget_rec.justification IN (l_fund_reconc_msg,l_act_bud_cst_msg)
      AND p_act_budget_rec.exchange_rate_date IS NOT NULL THEN
        l_util_rec.exchange_rate_date := p_act_budget_rec.exchange_rate_date;
      END IF;
      */

      --bug 7425189, 8532055
      l_util_rec.exchange_rate_date := p_act_budget_rec.exchange_rate_date;

         ozf_fund_utilized_pvt.create_utilization (
            p_api_version=> l_api_version
           ,p_init_msg_list=> fnd_api.g_false
           ,p_commit=> fnd_api.g_false
           ,p_validation_level=> fnd_api.g_valid_level_full
           ,x_return_status=> l_return_status
           ,x_msg_count=> x_msg_count
           ,x_msg_data=> x_msg_data
           ,p_utilization_rec=> l_util_rec
           ,x_utilization_id=> x_utilization_id --l_util_id
         );

         IF l_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      END LOOP;

     x_utilized_amount := l_total_amount;

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_full_name||' : '||'x_utilized_amount:   '|| x_utilized_amount);
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

   END create_fund_utilization;



---------------------------------------------------------------------
-- PROCEDURE
--    Convert_Currency
--
-- PURPOSE
--           This API will be used to convert currency for checkbook.
-- PARAMETERS
--                  p_from_currency  IN VARCHAR2 From currency
--                  p_to_currency IN VARCHAR@  To currency
--                  p_from_amount IN NUMBER    From amount
-- NOTES

-- HISTORY
--    06/08/2001  feliu  Create.
----------------------------------------------------------------------
   FUNCTION convert_currency (
      p_from_currency   IN   VARCHAR2
     ,p_to_currency     IN   VARCHAR2
     ,p_from_amount     IN   NUMBER
     ,p_conv_type       IN   VARCHAR2 DEFAULT FND_API.G_MISS_CHAR --Added for bug 7030415
   )
      RETURN NUMBER IS
      l_conversion_type_profile   CONSTANT VARCHAR2 (30) := 'OZF_CURR_CONVERSION_TYPE';
      l_user_rate                 CONSTANT NUMBER        := 1; -- Currenty not used.
      l_max_roll_days             CONSTANT NUMBER        := -1; -- Negative so API rolls back to find the last conversion rate.
      l_denominator                        NUMBER; -- Not used in Marketing.
      l_numerator                          NUMBER; -- Not used in Marketing.
      l_rate                               NUMBER; -- Not used in Marketing.
      l_conversion_type                    VARCHAR2 (30); -- Currency conversion type; see API documention for details.
      l_returned_amount                    NUMBER        := 1000;
   BEGIN
      -- Get the currency conversion type from profile option
      --Added for bug 7030415
      IF p_conv_type = FND_API.G_MISS_CHAR OR p_conv_type IS NULL THEN
        l_conversion_type := fnd_profile.VALUE (l_conversion_type_profile);
      ELSE
        l_conversion_type := p_conv_type;
      END IF;
      -- Call the proper GL API to convert the amount.
      gl_currency_api.convert_closest_amount (
         x_from_currency=> p_from_currency
        ,x_to_currency=> p_to_currency
        ,x_conversion_date=> SYSDATE
        ,x_conversion_type=> l_conversion_type
        ,x_user_rate=> l_user_rate
        ,x_amount=> p_from_amount
        ,x_max_roll_days=> l_max_roll_days
        ,x_converted_amount=> l_returned_amount
        ,x_denominator=> l_denominator
        ,x_numerator=> l_numerator
        ,x_rate=> l_rate
      );
      RETURN l_returned_amount;
   EXCEPTION
      WHEN gl_currency_api.no_rate THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_NO_RATE');
            fnd_message.set_token ('CURRENCY_FROM', p_from_currency);
            fnd_message.set_token ('CURRENCY_TO', p_to_currency);
            fnd_msg_pub.ADD;
            RETURN 0;
         END IF;
      WHEN gl_currency_api.invalid_currency THEN
         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name ('OZF', 'OZF_INVALID_CURR');
            fnd_message.set_token ('CURRENCY_FROM', p_from_currency);
            fnd_message.set_token ('CURRENCY_TO', p_to_currency);
            fnd_msg_pub.ADD;
            RETURN 0;
         END IF;
      WHEN OTHERS THEN
         RETURN 0;
   END convert_currency;


---------------------------------------------------------------------
-- PROCEDURE
--    validate_lumsum_offer
--
-- PURPOSE
--
-- PARAMETERS
   --p_qp_list_header_id     IN   NUMBER
   --x_return_status         OUT NOCOPY  VARCHAR2);
-- NOTES
--        This API will validate the lumsum offer distribution
-- HISTORY
--   09/24/2001  Mumu Pande  Create.
----------------------------------------------------------------------

   PROCEDURE validate_lumpsum_offer (p_qp_list_header_id IN NUMBER, x_return_status OUT NOCOPY VARCHAR2) IS
      l_api_version   CONSTANT NUMBER                            := 1.0;
      l_api_name      CONSTANT VARCHAR2 (30)                     := 'validate_lumpsum_offer';
      l_full_name     CONSTANT VARCHAR2 (60)                     :=    g_pkg_name
                                                                    || '.'
                                                                    || l_api_name;

      CURSOR cur_get_lumpsum_details IS
         SELECT status_code
               ,lumpsum_amount
               ,object_version_number
               ,distribution_type
               ,qp_list_header_id
               ,offer_id
           FROM ozf_offers
          WHERE qp_list_header_id = p_qp_list_header_id;

      l_lumpsum_offer          cur_get_lumpsum_details%ROWTYPE;

      CURSOR cur_get_lumpsum_line_details IS
         SELECT SUM (line_lumpsum_qty)
           FROM ams_act_products
          WHERE arc_act_product_used_by = 'OFFR'
            AND act_product_used_by_id = p_qp_list_header_id;

      l_total_distribution     NUMBER;

      CURSOR c_approved_amount (p_offer_id NUMBER) IS
         SELECT SUM(NVL(plan_curr_committed_amt,0))
         FROM ozf_object_fund_summary
         WHERE object_id =p_offer_id
         AND object_type = 'OFFR';

         /* Fix for the bug#3047142
         SELECT SUM(DECODE(transfer_type,'REQUEST', NVL(approved_amount,0),NVL(0-approved_original_amount,0)))
         FROM ozf_act_budgets
         WHERE status_code = 'APPROVED'
         AND ((arc_act_budget_used_by = 'OFFR' AND act_budget_used_by_id = l_id and transfer_type ='REQUEST')
              OR (budget_source_type = 'OFFR' AND budget_source_id = l_id and transfer_type ='TRANSFER'));

         /* SELECT SUM(DECODE(transfer_type,'REQUEST', NVL(approved_amount,0),NVL(0-approved_original_amount,0)))
           FROM ozf_act_budgets
          WHERE arc_act_budget_used_by = 'OFFR'
            AND act_budget_used_by_id = l_id;
     */

      l_approved_amount        NUMBER;
   BEGIN
      x_return_status            := fnd_api.g_ret_sts_success;
      OPEN cur_get_lumpsum_details;
      FETCH cur_get_lumpsum_details INTO l_lumpsum_offer;
      CLOSE cur_get_lumpsum_details;
      OPEN cur_get_lumpsum_line_details;
      FETCH cur_get_lumpsum_line_details INTO l_total_distribution;
      CLOSE cur_get_lumpsum_line_details;
      OPEN c_approved_amount (p_qp_list_header_id);
      FETCH c_approved_amount INTO l_approved_amount;
      CLOSE c_approved_amount;

      --nirprasa, comment out for bug 8625525
     /*  IF l_lumpsum_offer.lumpsum_amount > l_approved_amount
         OR l_lumpsum_offer.lumpsum_amount < l_approved_amount THEN
         ozf_utility_pvt.error_message (p_message_name => 'OZF_OFFER_AMNT_GT_APPR_AMNT');
         RAISE fnd_api.g_exc_error;
      END IF;*/

      IF l_lumpsum_offer.distribution_type = 'AMT' THEN
         IF l_total_distribution <> l_lumpsum_offer.lumpsum_amount THEN
            fnd_message.set_name ('OZF', 'OZF_INVALID_DISTR_ACTIVE');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         ELSIF l_total_distribution > l_lumpsum_offer.lumpsum_amount THEN
            fnd_message.set_name ('OZF', 'OZF_INVALID_DISTRIBUTION');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         END IF;
      ELSIF l_lumpsum_offer.distribution_type = '%' THEN
         IF l_total_distribution <> 100 THEN
            fnd_message.set_name ('OZF', 'OZF_INVALID_DISTR_ACTIVE');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         ELSIF l_total_distribution > 100 THEN
            fnd_message.set_name ('OZF', 'OZF_INVALID_DISTRIBUTION');
            fnd_msg_pub.ADD;
            RAISE fnd_api.g_exc_error;
         END IF;
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status            := fnd_api.g_ret_sts_error;
      WHEN OTHERS THEN
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;
   END validate_lumpsum_offer;
  ---------------------------------------------------------------------
   -- PROCEDURE
   --    get_exchange_rate
   -- PURPOSE
   -- Get currency exchange rate. called by BudgetOverVO.java.
   -- PARAMETERS
   --         p_from_currency   IN VARCHAR2,
   --           p_to_currency   IN VARCHAR2,
   --           p_conversion_date IN DATE ,
   --           p_conversion_type IN VARCHAR2,
   --           p_max_roll_days  IN NUMBER,
   --           x_denominator   OUT NUMBER,
   --       x_numerator OUT NUMBER,
   --           x_rate    OUT NUMBER,
   --           x_return_status   OUT  VARCHAR2

   -- HISTORY
   -- 02/05/2002 feliu  CREATED
   ----------------------------------------------------------------------
   PROCEDURE get_exchange_rate (
        p_from_currency IN VARCHAR2,
        p_to_currency   IN VARCHAR2,
        p_conversion_date IN DATE ,
        p_conversion_type IN VARCHAR2,
        p_max_roll_days  IN NUMBER,
        x_denominator   OUT NOCOPY NUMBER,
        x_numerator     OUT NOCOPY NUMBER,
        x_rate    OUT NOCOPY NUMBER,
        x_return_status  OUT NOCOPY  VARCHAR2)

IS

BEGIN
   gl_currency_api.get_closest_triangulation_rate (
                x_from_currency =>      p_from_currency,
                x_to_currency   =>      p_to_currency,
                x_conversion_date =>     p_conversion_date,
                x_conversion_type =>    p_conversion_type,
                x_max_roll_days   =>     p_max_roll_days,
                x_denominator   => x_denominator,
                x_numerator     => x_numerator,
                x_rate    => x_rate );

   x_return_status := fnd_api.g_ret_sts_success;

   EXCEPTION
      WHEN OTHERS THEN
         IF SQLCODE=1  THEN
            x_denominator := 1.0;
            x_numerator := 0.0;
            x_rate := 1.0;
            x_return_status := FND_API.g_ret_sts_success;
         END IF;
END get_exchange_rate;


      ---------------------------------------------------------------------
   -- PROCEDURE
   --    process_act_budgets
   --
   -- PURPOSE
   --
   -- PARAMETERS
   --         p_api_version
   --         ,x_return_status
--            ,x_msg_count
--            ,x_msg_data
  --          ,p_act_budgets_rec
    --        ,x_act_budget_id
    --        x_utilized_amount : actual utilized amount when success
   -- NOTES
   -- HISTORY
   --    4/18/2002  Mumu Pande  Create.
   ----------------------------------------------------------------------

   PROCEDURE process_act_budgets (
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      p_act_budgets_rec   IN  ozf_actbudgets_pvt.act_budgets_rec_type,
      p_act_util_rec      IN  ozf_actbudgets_pvt.act_util_rec_type,
      x_act_budget_id     OUT NOCOPY      NUMBER,
      x_utilized_amount   OUT NOCOPY      NUMBER                 -- added yzhao Jun 21, 2004
   ) IS
     l_utilization_id        NUMBER;
   BEGIN

      --kdass - added for Bug 8726683
      process_act_budgets (
         x_return_status   => x_return_status
        ,x_msg_count       => x_msg_count
        ,x_msg_data        => x_msg_data
        ,p_act_budgets_rec => p_act_budgets_rec
        ,p_act_util_rec    => p_act_util_rec
        ,x_act_budget_id   => x_act_budget_id
        ,x_utilized_amount => x_utilized_amount
        ,x_utilization_id  => l_utilization_id);

   END process_act_budgets;

   PROCEDURE process_act_budgets (
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      p_act_budgets_rec   IN  ozf_actbudgets_pvt.act_budgets_rec_type,
      p_act_util_rec      IN  ozf_actbudgets_pvt.act_util_rec_type,
      x_act_budget_id     OUT NOCOPY      NUMBER,
      x_utilized_amount   OUT NOCOPY      NUMBER,                -- added yzhao Jun 21, 2004
      x_utilization_id    OUT NOCOPY      NUMBER
   ) IS
      CURSOR c_act_util_rec (p_used_by_id IN NUMBER, p_used_by_type IN VARCHAR2) IS
         SELECT activity_budget_id, object_version_number, approved_amount
         FROM ozf_act_budgets
         WHERE act_budget_used_by_id = p_used_by_id
         AND arc_act_budget_used_by = p_used_by_type
         AND transfer_type = 'UTILIZED';
      CURSOR c_offer_type (p_offer_id IN NUMBER) IS
         SELECT nvl(transaction_currency_code,fund_request_curr_code) offer_currency_code
         FROM   ozf_offers
         WHERE  qp_list_header_id = p_offer_id;
      CURSOR c_get_conversion_type( p_org_id IN NUMBER) IS
         SELECT exchange_rate_type
         FROM   ozf_sys_parameters_all
         WHERE  org_id = p_org_id;

      l_activity_id           NUMBER;
      l_obj_ver_num           NUMBER;
      l_old_approved_amount   NUMBER;
      --l_return_status         VARCHAR2 (20);
      l_api_name              VARCHAR2 (60)         := 'process_act_budget';
      l_full_name             VARCHAR2 (100)         := g_pkg_name||'.'||l_api_name;
      l_act_budget_id         NUMBER;
      l_act_budgets_rec       ozf_actbudgets_pvt.act_budgets_rec_type:=p_Act_budgets_rec;
      l_act_util_rec          ozf_actbudgets_pvt.act_util_rec_type := p_act_util_rec;
      l_api_version           NUMBER                                  := 1;
      l_budget_request_rec    ozf_actbudgets_pvt.act_budgets_rec_type := NULL;
      l_plan_currency         VARCHAR2(150);
      l_exchange_rate_type    VARCHAR2(30) := FND_API.G_MISS_CHAR ;
      l_rate                  NUMBER;
      l_utilized_amount       NUMBER;

   BEGIN
      x_return_status := fnd_api.g_ret_sts_success;
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_full_name||' : '||'begin' || ' p_act_budgets_rec.transfer_type: '  || p_act_budgets_rec.transfer_type);
      END IF;
      --dbms_output.put_line(l_full_name||' : '||'begin');

      -- yzhao: 10/21/2003 for third party accrual price list, create an approved budget request when accrual happens
      --                   note: Price list does not allow negative accrual for now
      IF (p_act_budgets_rec.transfer_type = 'UTILIZED' AND
          p_act_budgets_rec.budget_source_type = 'PRIC' AND
          p_act_budgets_rec.arc_act_budget_used_by = 'PRIC' AND
          p_act_budgets_rec.status_code = 'APPROVED' AND
          p_act_budgets_rec.request_amount > 0) THEN

          l_budget_request_rec.transfer_type := 'REQUEST';
          l_budget_request_rec.budget_source_type := 'FUND';
          l_budget_request_rec.budget_source_id := p_act_budgets_rec.parent_source_id;  -- passed by price list from its profile
          l_budget_request_rec.arc_act_budget_used_by := 'PRIC';
          l_budget_request_rec.act_budget_used_by_id := p_act_budgets_rec.act_budget_used_by_id;
          l_budget_request_rec.request_currency := p_act_budgets_rec.request_currency;  -- price list currency
          l_budget_request_rec.request_amount := p_act_budgets_rec.request_amount;      -- in price list currency

          l_budget_request_rec.status_code := 'APPROVED';
          l_budget_request_rec.user_status_id := ozf_Utility_Pvt.get_default_user_status (
                                                    'OZF_BUDGETSOURCE_STATUS', p_act_budgets_rec.status_code);
          l_budget_request_rec.object_version_number := 1;
          l_budget_request_rec.approval_date := sysdate;
          --l_budget_request_rec.approver_id := ozf_utility_pvt.get_resource_id (fnd_global.user_id);
          --l_budget_request_rec.requester_id := ozf_utility_pvt.get_resource_id (fnd_global.user_id);
          l_budget_request_rec.approver_id := p_act_budgets_rec.approver_id;
          l_budget_request_rec.requester_id := p_act_budgets_rec.requester_id;
          IF l_budget_request_rec.approver_id  IS NULL THEN
             l_budget_request_rec.approver_id := ozf_utility_pvt.get_resource_id (fnd_global.user_id);
          END IF;
          IF l_budget_request_rec.requester_id  IS NULL THEN
             l_budget_request_rec.requester_id := ozf_utility_pvt.get_resource_id (fnd_global.user_id);
          END IF;


          ozf_actbudgets_pvt.create_Act_Budgets (
                             p_api_version             => 1.0,
                             p_init_msg_list           => Fnd_Api.G_FALSE,
                             p_commit                  => Fnd_Api.G_FALSE,
                             p_validation_level        => Fnd_Api.G_VALID_LEVEL_FULL,
                             x_return_status           => x_return_status,
                             x_msg_count               => x_msg_count,
                             x_msg_data                => x_msg_data,
                             p_act_Budgets_rec         => l_budget_request_rec,
                             p_act_util_rec            => ozf_actbudgets_pvt.G_MISS_ACT_UTIL_REC,
                             p_approval_flag           => fnd_api.g_true,     -- auto approved
                             x_act_budget_id           => l_act_budget_id,
                             x_utilized_amount         => l_utilized_amount,
                             x_utilization_id          => x_utilization_id); --kdass - added for Bug 8726683
          IF x_return_status <> fnd_api.g_ret_sts_success THEN
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;

      END IF;  -- price list
      -- yzhao: 10/21/2003 ENDS for third party accrual price list, create an approved budget request when accrual happens

      OPEN c_act_util_rec (
         p_act_budgets_rec.act_budget_used_by_id,
         p_act_budgets_rec.arc_act_budget_used_by
      );
      FETCH c_act_util_rec INTO l_activity_id,
                                l_obj_ver_num,
                                l_old_approved_amount;
      CLOSE c_act_util_rec;

      --nirprasa, added for bug 9097346. since post multi currency changes need to populate
      --these new columns for marketing objects.
      IF l_act_budgets_rec.arc_act_budget_used_by <> 'OFFR' THEN
          l_act_util_rec.plan_curr_amount := l_act_budgets_rec.request_amount;
          l_act_util_rec.fund_request_currency_code  := l_act_budgets_rec.request_currency;
          l_act_util_rec.plan_currency_code := l_act_budgets_rec.request_currency;
      END IF;

      --dbms_output.put_line(l_full_name||' : '||'l_Activity_budget_id'|| l_Activity_id);

      IF l_activity_id IS NULL THEN
         --l_act_budgets_rec.approved_amount := l_util_amount;
         --l_act_budgets_rec.parent_src_apprvd_amt := l_parent_source_rec.total_amount;
         ozf_actbudgets_pvt.create_act_budgets (
            p_api_version=> l_api_version,
            x_return_status=> x_return_status,
            x_msg_count=> x_msg_count,
            x_msg_data=> x_msg_data,
            p_act_budgets_rec=> l_act_budgets_rec,
            x_act_budget_id=> l_act_budget_id,
            p_act_util_rec => l_act_util_rec,
            x_utilized_amount => x_utilized_amount,    -- yzhao: 06/21/2004 added for chargeback
            x_utilization_id => x_utilization_id --kdass - added for Bug 8726683
         );

            IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_full_name||' : '||'x_utilized_amount:   '|| x_utilized_amount);
      END IF;

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_full_name||' : '||'create act budget retrun status'||x_return_status);
      END IF;
      --dbms_output.put_line(l_full_name||' : '||'create act budget retrun status'||l_return_status);

         IF x_return_status = fnd_api.g_ret_sts_error THEN
            RAISE fnd_api.g_exc_error;
         ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      ELSE
      --dbms_output.put_line(l_full_name||' : '||'l_Activity_budget_id in update'||l_Activity_id);
      --dbms_output.put_line(l_full_name||' : '||'l_old_approved_amount'||l_old_approved_amount);
      --dbms_output.put_line(l_full_name||' : '||'l_new approved_amount'||l_Act_budgets_rec.approved_amount);
      --dbms_output.put_line(l_full_name||' : '||'l_new parent approved_amount'||l_act_budgets_rec.parent_src_apprvd_amt);
      IF G_DEBUG THEN
      ozf_utility_pvt.debug_message('l_act_budgets_rec.request_amount '|| l_act_budgets_rec.request_amount);
      ozf_utility_pvt.debug_message('l_act_budgets_rec.request_currency '|| l_act_budgets_rec.request_currency);
      ozf_utility_pvt.debug_message('l_old_approved_amount '|| l_old_approved_amount);
      ozf_utility_pvt.debug_message('l_act_budgets_rec.parent_src_apprvd_amt '|| l_act_budgets_rec.parent_src_apprvd_amt);
      END IF;
      --nirprasa, 12.2 ER8399134 this change is needed to handle adjustments for marketing objects.
      IF l_act_budgets_rec.arc_act_budget_used_by = 'OFFR' THEN
         OPEN c_offer_type(l_act_budgets_rec.act_budget_used_by_id);
         FETCH c_offer_type INTO l_plan_currency;
         CLOSE c_offer_type;

         IF l_plan_currency <> l_act_budgets_rec.request_currency THEN
            OPEN c_get_conversion_type(l_act_util_rec.org_id);
            FETCH c_get_conversion_type INTO l_exchange_rate_type;
            CLOSE c_get_conversion_type;
            IF G_DEBUG THEN
            ozf_utility_pvt.debug_message('l_plan_currency '|| l_plan_currency);
            ozf_utility_pvt.debug_message('l_exchange_rate_type '|| l_exchange_rate_type);
            END IF;
            l_act_util_rec.plan_curr_amount := l_act_budgets_rec.request_amount;
            l_act_util_rec.plan_curr_amount_remaining := l_act_budgets_rec.request_amount;
            l_act_util_rec.plan_currency_code := l_act_budgets_rec.request_currency;
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
            l_act_budgets_rec.request_currency := l_plan_currency;
            IF G_DEBUG THEN
            ozf_utility_pvt.debug_message('l_act_budgets_rec.request_amount '|| l_act_budgets_rec.request_amount);
            END IF;
         END IF;
      ELSE --for marketing objects
         l_act_util_rec.plan_curr_amount := l_act_budgets_rec.request_amount;
         l_act_util_rec.plan_currency_code := l_act_budgets_rec.request_currency;
         l_act_util_rec.fund_request_currency_code  := l_act_budgets_rec.request_currency;
      END IF;
         l_act_budgets_rec.request_amount :=
                      l_old_approved_amount
                    + l_act_budgets_rec.request_amount;

          l_act_budgets_rec.approved_amount :=
                      l_old_approved_amount
                    + l_act_budgets_rec.request_amount;


         l_act_budgets_rec.parent_src_apprvd_amt :=
                 l_act_budgets_rec.parent_src_apprvd_amt;
         l_act_budgets_rec.activity_budget_id := l_activity_id;
         l_act_budgets_rec.object_version_number := l_obj_ver_num;
         ozf_actbudgets_pvt.update_act_budgets (
            p_api_version=> l_api_version,
            x_return_status=> x_return_status,
            x_msg_count=> x_msg_count,
            x_msg_data=> x_msg_data,
            p_act_budgets_rec=> l_act_budgets_rec,
            p_child_approval_flag    => 'N'             ,
            p_parent_process_flag=> fnd_api.g_false,
            p_parent_process_key=> fnd_api.g_miss_char,
            p_parent_context=> fnd_api.g_miss_char,
            p_parent_approval_flag=> fnd_api.g_false,
            p_continue_flow=> fnd_api.g_false,
            p_requestor_owner_flag   => 'N',
            p_act_util_rec => l_act_util_rec,
            x_utilized_amount => x_utilized_amount,     -- yzhao: 06/21/2004 added for chargeback
            x_utilization_id => x_utilization_id  --kdass - added for Bug 8726683
         );


      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message(l_full_name||' : '||'update act budget retrun status'||x_return_status);
      END IF;
      --dbms_output.put_line(l_full_name||' : '||'update act budget retrun status'||l_return_status);

      END IF;

         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count,
            p_data=> x_msg_data,
            p_encoded=> fnd_api.g_false
         );

      IF x_return_status = fnd_api.g_ret_sts_error THEN
         RAISE fnd_api.g_exc_error;
      ELSIF x_return_status = fnd_api.g_ret_sts_unexp_error THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count,
            p_data=> x_msg_data,
            p_encoded=> fnd_api.g_false
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count,
            p_data=> x_msg_data,
            p_encoded=> fnd_api.g_false
         );
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count,
            p_data=> x_msg_data,
            p_encoded=> fnd_api.g_false
         );
   END process_act_budgets;


   ---------------------------------------------------------------------
   -- PROCEDURE
   --    process_act_budgets
   --
   -- PURPOSE
   --    overloaded to return actual utilized amount
   --
   -- PARAMETERS
   --         p_api_version
   --         ,x_return_status
   --         ,x_msg_count
   --         ,x_msg_data
   --         ,p_act_budgets_rec
    --        ,x_act_budget_id
   -- NOTES
   -- HISTORY
   --    6/21/2004  Ying Zhao  Create.
   ----------------------------------------------------------------------
   PROCEDURE process_act_budgets (
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      p_act_budgets_rec   IN       ozf_actbudgets_pvt.act_budgets_rec_type,
      p_act_util_rec     IN       ozf_actbudgets_pvt.act_util_rec_type,
      x_act_budget_id     OUT NOCOPY      NUMBER
   ) IS
      l_utilized_amount   NUMBER;
   BEGIN
      process_act_budgets (
          x_return_status     => x_return_status,
          x_msg_count         => x_msg_count,
          x_msg_data          => x_msg_data,
          p_act_budgets_rec   => p_act_budgets_rec,
          p_act_util_rec      => p_act_util_rec,
          x_act_budget_id     => x_act_budget_id,
          x_utilized_amount   => l_utilized_amount
      );
   END process_act_budgets;


---------------------------------------------------------------------
-- PROCEDURE
--    post_scan_data_amount
--
-- PURPOSE
-- This procedure is called by post_utilized_budget  when offer type is "SCAN_DATA' .
-- It is used to create utilized records for scan data offer when offer start date reaches:

-- PARAMETERS
--       p_offer_id
--      ,p_api_version     IN       NUMBER
--      ,p_init_msg_list   IN       VARCHAR2 := fnd_api.g_false
--      ,p_commit          IN       VARCHAR2 := fnd_api.g_false
--      ,x_msg_count       OUT      NUMBER
--      ,x_msg_data        OUT      VARCHAR2
--      ,x_return_status   OUT      VARCHAR2)

-- NOTES
-- HISTORY
--    09/24/2002  feliu  Create.
----------------------------------------------------------------------

PROCEDURE post_scan_data_amount (
      p_offer_id        IN       NUMBER
     ,p_api_version     IN       NUMBER
     ,p_init_msg_list   IN       VARCHAR2 := fnd_api.g_false
     ,p_commit          IN       VARCHAR2 := fnd_api.g_false
     ,p_check_date      IN       VARCHAR2 := fnd_api.g_true -- do date validation
     ,x_msg_count       OUT NOCOPY      NUMBER
     ,x_msg_data        OUT NOCOPY      VARCHAR2
     ,x_return_status   OUT NOCOPY      VARCHAR2
) IS
      l_api_version           NUMBER                                  := 1.0;
      l_return_status         VARCHAR2 (1)                            := fnd_api.g_ret_sts_success;
      l_msg_data               VARCHAR2 (2000);
      l_msg_count              NUMBER;
      l_api_name              VARCHAR2 (60)                           := 'post_scan_data_amount';
      l_full_name        CONSTANT VARCHAR2 (90)                           :=    g_pkg_name
                                                                             || '.'
                                                                             || l_api_name;
      l_product_id                NUMBER;
      l_offer_start_date          DATE;
      l_act_budget_id             NUMBER;
      l_act_budgets_rec           ozf_actbudgets_pvt.act_budgets_rec_type;
      l_act_util_rec              ozf_actbudgets_pvt.act_util_rec_type ;
      l_amount                    NUMBER                                  := 0;
      l_converted_amt             NUMBER;
      l_perform_util              VARCHAR2 (1);
      l_level_type_code           VARCHAR2 (30);
      l_scan_value                NUMBER;
      l_forecast_unit             NUMBER;
      l_quantity                  NUMBER;
      l_act_product_id            NUMBER;
      l_total_committed_amt       NUMBER;
      l_total_utilized_amt        NUMBER;
      l_currency_code             VARCHAR2(30);
      l_unit                      NUMBER;
      l_acct_closed_flag          VARCHAR2(1);
      l_cust_acct_id              NUMBER;
      l_cust_type                 VARCHAR2(30);
      l_offer_owner               NUMBER;
      l_org_id                    NUMBER;
      l_cust_setup_id             NUMBER;
      l_req_header_id             NUMBER;

     --get offer start data and currency.
      CURSOR c_offer_date IS
         SELECT qp.start_date_active, NVL(qp.currency_code, ofs.fund_request_curr_code) currency_code,
                NVL(ofs.account_closed_flag,'N'),ofs.qualifier_id, ofs.qualifier_type,ofs.owner_id,ofs.custom_setup_id,
                ofs.org_id
         FROM qp_list_headers_b qp,ozf_offers ofs
         WHERE qp.list_header_id = p_offer_id
         AND qp.list_header_id = ofs.qp_list_header_id;

      --get product information.
      CURSOR c_off_products (p_offer_id IN NUMBER) IS
         SELECT activity_product_id,DECODE (level_type_code, 'PRODUCT', inventory_item_id, category_id) product_id
               ,level_type_code,scan_value,scan_unit_forecast,quantity
         FROM ams_act_products
         WHERE act_product_used_by_id = p_offer_id
         AND arc_act_product_used_by = 'OFFR';

      --kdass 08-Jun-2005 Bug 4415878 SQL Repository Fix - changed the cursor query
      -- get committed budget information.
      CURSOR c_prod_budgets (p_offer_id IN NUMBER) IS
         SELECT NVL(plan_curr_committed_amt,0) approved_amount
                ,fund_id
                ,fund_currency currency_code
         FROM ozf_object_fund_summary
         WHERE object_id =p_offer_id
         AND object_type = 'OFFR';

/*
         SELECT SUM (approved_amount) approved_amount, fund_id, currency_code
         FROM (
               SELECT NVL(plan_curr_amount,0) approved_amount, fund_id, currency_code
               FROM ozf_funds_utilized_all_b
               WHERE utilization_type = 'REQUEST'
               AND component_type = 'OFFR'
               AND component_id = p_offer_id
               UNION ALL
               SELECT NVL(-plan_curr_amount,0) approved_amount, fund_id, currency_code
               FROM ozf_funds_utilized_all_b
               WHERE utilization_type = 'TRANSFER'
               AND plan_type = 'OFFR'
               AND plan_id = p_offer_id
              ) GROUP BY fund_id, currency_code;


      CURSOR c_prod_budgets (p_offer_id IN NUMBER) IS
         SELECT SUM(NVL(DECODE(utilization_type, 'REQUEST',util.plan_curr_amount,-util.plan_curr_amount),0)) approved_amount,
            util.fund_id,util.currency_code
         FROM ozf_funds_utilized_all_b util
         WHERE util.utilization_type IN ('REQUEST','TRANSFER')
         AND DECODE(util.utilization_type,'REQUEST', util.component_type,util.plan_type) = 'OFFR'
         AND DECODE(util.utilization_type,'REQUEST', util.component_id,util.plan_id) = p_offer_id
         GROUP BY util.fund_id,util.currency_code;
      */

      --kdass 08-Jun-2005 Bug 4415878 SQL Repository Fix - changed the cursor query
      -- get total committed and utilized amount
      CURSOR c_committed_budgets(p_offer_id IN NUMBER) IS
        SELECT SUM(NVL(plan_curr_committed_amt,0))
        FROM ozf_object_fund_summary
        WHERE object_id =p_offer_id
        AND object_type = 'OFFR';
/*
         SELECT SUM (approved_amount)
         FROM (SELECT NVL(plan_curr_amount,0) approved_amount
               FROM ozf_funds_utilized_all_b
               WHERE utilization_type = 'REQUEST'
                 AND component_type = 'OFFR'
                 AND component_id = p_offer_id
               UNION ALL
               SELECT NVL(-plan_curr_amount,0) approved_amount
               FROM ozf_funds_utilized_all_b
               WHERE utilization_type = 'TRANSFER'
                 AND plan_type = 'OFFR'
                 AND plan_id = p_offer_id);

      CURSOR c_committed_budgets(p_offer_id IN NUMBER) IS
        SELECT SUM(DECODE(utilization_type,'REQUEST',plan_curr_amount,'TRANSFER',-plan_curr_amount))
        FROM ozf_funds_utilized_all_b
        WHERE utilization_type IN ('REQUEST','TRANSFER')
        AND DECODE(utilization_type,'REQUEST', component_type,plan_type) = 'OFFR'
        AND DECODE(utilization_type,'REQUEST', component_id,plan_id) = p_offer_id;
      */

      CURSOR c_utilized_budgets(p_offer_id IN NUMBER) IS
        SELECT NVL(SUM(plan_curr_amount),0)
        FROM ozf_funds_utilized_all_b
        WHERE plan_id = p_offer_id
        AND  plan_type = 'OFFR'
        AND  utilization_type ='ACCRUAL';

      CURSOR c_req_date(p_offer_id IN NUMBER) IS
        SELECT request_header_id
        FROM ozf_request_headers_all_b
        WHERE offer_id =p_offer_id;

/*
      CURSOR c_get_cust_account_id(p_party_id IN NUMBER) IS
        select max(cust_account_id) from hz_cust_accounts
        where party_id = p_party_id
        and status= 'A';
*/

      --Added for bug 7030415
      CURSOR c_get_conversion_type( p_org_id IN NUMBER) IS
        SELECT exchange_rate_type
        FROM   ozf_sys_parameters_all
        WHERE  org_id = p_org_id;

     l_exchange_rate_type VARCHAR2(30) := FND_API.G_MISS_CHAR;
     l_rate               NUMBER;
     l_offer_org_id       NUMBER;

   BEGIN
      SAVEPOINT post_scan_data_amount;
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name || ': start');
      END IF;
      x_return_status            := fnd_api.g_ret_sts_success;

      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- get total committed and utilized amount.
      OPEN c_committed_budgets(p_offer_id);
      FETCH c_committed_budgets INTO l_total_committed_amt;
      CLOSE c_committed_budgets;

      -- get total utilized and utilized amount.
      OPEN c_utilized_budgets(p_offer_id);
      FETCH c_utilized_budgets INTO l_total_utilized_amt;
      CLOSE c_utilized_budgets;

      -- check wether date validation is reqd
      OPEN c_offer_date;
      FETCH c_offer_date INTO l_offer_start_date,l_currency_code,
            l_acct_closed_flag,l_cust_acct_id,l_cust_type,l_offer_owner,l_cust_setup_id,l_offer_org_id;
      CLOSE c_offer_date;
      -- for special pricing, get request_header_id.
      IF l_cust_setup_id = 117 THEN
         OPEN c_req_date(p_offer_id);
         FETCH c_req_date INTO l_req_header_id;
         CLOSE c_req_date;
      END IF;


      -- check wether date validation is reqd
      IF p_check_date = fnd_api.g_true THEN
     -- if the offer start date is today or has passed then only adjust
         IF TRUNC(l_offer_start_date) <= TRUNC(SYSDATE) THEN
            l_perform_util             := 'T';
         ELSE
            l_perform_util             := 'F';
         END IF;
      ELSE
         -- donot check date
         l_perform_util             := 'T';
      END IF;

      --if system date reaches start_date and did not post before by checking utilized amount.
      IF l_perform_util = 'T' AND l_acct_closed_flag = 'N'  AND l_total_utilized_amt = 0 THEN
         OPEN c_off_products (p_offer_id);

         <<offer_prdt_loop>>
         LOOP
            FETCH c_off_products INTO l_act_product_id,l_product_id, l_level_type_code,l_scan_value,l_forecast_unit,l_quantity;
            EXIT WHEN c_off_products%NOTFOUND;

            FOR l_prod_budget_rec IN c_prod_budgets (p_offer_id)
            LOOP
               -- change later if a error has to be raised or not.
            /*   IF c_prod_budgets%NOTFOUND THEN
                  ozf_utility_pvt.error_message ('OZF_ACT_BUDG_UTIL_OVER');
               END IF;
             */
               EXIT WHEN c_prod_budgets%NOTFOUND;
               --get request amount proportionaly for total committed amount.
               l_unit := ozf_utility_pvt.currround(l_prod_budget_rec.approved_amount / l_total_committed_amt * l_forecast_unit
                                                   ,l_currency_code) ;

               -- 08/13/2004 kdass fix for 11.5.9 bug 3830164, divided the amount by the quantity
               --l_amount := l_unit * l_scan_value; -- in object currency.
               l_amount := l_unit * l_scan_value / l_quantity; -- in object currency.

               IF G_DEBUG THEN
                  ozf_utility_pvt.debug_message ( 'scan unit: ' ||  l_unit);

                  ozf_utility_pvt.debug_message ( 'scan amount : ' ||  l_amount);
               END IF;

               IF l_amount <> 0 THEN
               -- convert the object currency amount into fund currency
                   IF l_prod_budget_rec.currency_code = l_currency_code THEN
                      l_converted_amt            := l_amount;
                   ELSE
                  -- call the currency conversion wrapper
                  --Added for bug 7030415

                  OPEN c_get_conversion_type(l_offer_org_id);
                  FETCH c_get_conversion_type INTO l_exchange_rate_type;
                  CLOSE c_get_conversion_type;

                      ozf_utility_pvt.convert_currency (
                           x_return_status=> x_return_status
                           ,p_from_currency=> l_currency_code
                           ,p_conv_type=> l_exchange_rate_type
                           ,p_to_currency=> l_prod_budget_rec.currency_code
                           ,p_from_amount=> l_amount
                           ,x_to_amount=> l_converted_amt
                           ,x_rate=> l_rate
                          );

                      IF x_return_status <> fnd_api.g_ret_sts_success THEN
                          x_return_status            := fnd_api.g_ret_sts_error;
                          RAISE fnd_api.g_exc_error;
                      END IF;
                   END IF;

                  l_act_budgets_rec.request_amount := l_amount; -- in object currency.
                  l_act_budgets_rec.act_budget_used_by_id := p_offer_id;
                  l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
                  l_act_budgets_rec.budget_source_type := 'OFFR';
                  l_act_budgets_rec.budget_source_id := p_offer_id;
                  l_act_budgets_rec.request_currency := l_currency_code;
                  l_act_budgets_rec.request_date := SYSDATE;
                  l_act_budgets_rec.status_code := 'APPROVED';
                  l_act_budgets_rec.user_status_id := ozf_utility_pvt.get_default_user_status (
                                             'OZF_BUDGETSOURCE_STATUS'
                                             ,l_act_budgets_rec.status_code
                                            );
                  l_act_budgets_rec.transfer_type := 'UTILIZED';
                  l_act_budgets_rec.approval_date := SYSDATE;
                  l_act_budgets_rec.requester_id := l_offer_owner;

                  l_act_budgets_rec.approver_id :=
                                               ozf_utility_pvt.get_resource_id (fnd_global.user_id);
                  -- when workflow goes through without approval, fnd_global.user_id is not passed.
                  IF l_act_budgets_rec.approver_id = -1 THEN
                     l_act_budgets_rec.approver_id := l_offer_owner;
                  END IF;

                  l_act_budgets_rec.justification :=
                                             fnd_message.get_string ('OZF', 'OZF_ACT_BUDGET_SCANDATA_UTIL');
                  l_act_budgets_rec.parent_source_id := l_prod_budget_rec.fund_id;
                  l_act_budgets_rec.parent_src_curr := l_prod_budget_rec.currency_code;
                  l_act_budgets_rec.parent_src_apprvd_amt := l_converted_amt; -- in budget currency.
                  l_act_util_rec.product_id := l_product_id ;
                  l_act_util_rec.product_level_type := l_level_type_code;
                  l_act_util_rec.gl_date := sysdate;
                  l_act_util_rec.scan_unit := l_unit ;
                  l_act_util_rec.scan_unit_remaining := l_unit;
                  l_act_util_rec.activity_product_id := l_act_product_id;
                  l_act_util_rec.utilization_type :='UTILIZED'; --will changed to 'ACCRUAL' in create_fund_utilization.
/*
                  --kdass 23-FEB-2004 fix for bug 3426061
                  -- If the Qualifier is a Buying group, then store Customer Account ID instead of Party ID
                  IF l_cust_type = 'BUYER' THEN
                     OPEN c_get_cust_account_id(l_cust_acct_id);
                     FETCH c_get_cust_account_id INTO l_cust_acct_id;
                     CLOSE c_get_cust_account_id;
                  END IF;

                  l_act_util_rec.cust_account_id := l_cust_acct_id;
*/
                  --nirprasa,12.1.1
                  l_act_util_rec.plan_currency_code := l_currency_code;
                  l_act_util_rec.fund_request_currency_code := l_currency_code;
                  --nirprasa,12.1.1
                  l_org_id := find_org_id (l_act_budgets_rec.parent_source_id);
                  -- set org_context since workflow mailer does not set the context
                  set_org_ctx (l_org_id);
                  -- for special pricing, add reference type and id.
                  IF l_cust_setup_id = 117 THEN
                     l_act_util_rec.reference_id := l_req_header_id;
                     l_act_util_rec.reference_type := 'SPECIAL_PRICE';
                  END IF;

                  process_act_budgets (x_return_status  => l_return_status,
                                       x_msg_count => x_msg_count,
                                       x_msg_data   => x_msg_data,
                                       p_act_budgets_rec => l_act_budgets_rec,
                                       p_act_util_rec   =>l_act_util_rec,
                                       x_act_budget_id  => l_act_budget_id
                                       ) ;

                  IF l_return_status = fnd_api.g_ret_sts_error THEN
                     RAISE fnd_api.g_exc_error;
                  ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                     RAISE fnd_api.g_exc_unexpected_error;
                  END IF;
               END IF; -- for  amount

               IF G_DEBUG THEN
                  ozf_utility_pvt.debug_message (   l_full_name
                                              || ': end create act budgets  ');
               END IF;
               l_act_budgets_rec          := NULL;
               l_act_util_rec             := NULL;
            END LOOP;

         END LOOP offer_prdt_loop;

         CLOSE c_off_products;
      END IF;


      IF      fnd_api.to_boolean (p_commit)
          AND l_return_status = fnd_api.g_ret_sts_success THEN
         COMMIT;
      END IF;


      fnd_msg_pub.count_and_get (
         p_encoded=> fnd_api.g_false
        ,p_count=> x_msg_count
        ,p_data=> x_msg_data
      );
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name || ': end');
      END IF;

   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO post_scan_data_amount;
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO post_scan_data_amount;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN OTHERS THEN
         ROLLBACK TO post_scan_data_amount;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
     END Post_scan_data_amount;


---------------------------------------------------------------------
-- PROCEDURE
--    post_lumpsum_amount
--
-- PURPOSE
-- This procedure is called by post_utilized_budget  when offer type is "LUMPSUM' .
-- It is used to create utilized records for lumpsum offer when offer start date reaches:

-- PARAMETERS
--       p_offer_id
--      ,p_api_version     IN       NUMBER
--      ,p_init_msg_list   IN       VARCHAR2 := fnd_api.g_false
--      ,p_commit          IN       VARCHAR2 := fnd_api.g_false
--      ,x_msg_count       OUT      NUMBER
--      ,x_msg_data        OUT      VARCHAR2
--      ,x_return_status   OUT      VARCHAR2)

-- NOTES
-- HISTORY
--    09/24/2002  feliu  Create.
--    10/07/2005  feliu  rewrite to fix issue for bug 4628081
----------------------------------------------------------------------

   PROCEDURE post_lumpsum_amount (
      p_offer_id        IN       NUMBER
     ,p_api_version     IN       NUMBER
     ,p_init_msg_list   IN       VARCHAR2 := fnd_api.g_false
     ,p_commit          IN       VARCHAR2 := fnd_api.g_false
     ,p_check_date      IN       VARCHAR2 := fnd_api.g_true -- do date validation
     ,x_msg_count       OUT NOCOPY      NUMBER
     ,x_msg_data        OUT NOCOPY      VARCHAR2
     ,x_return_status   OUT NOCOPY      VARCHAR2
   ) IS
      l_return_status             VARCHAR2 (10)                           := fnd_api.g_ret_sts_success;
      l_api_name         CONSTANT VARCHAR2 (30)                           := 'Posting_lumpsum_amount';
      l_api_version      CONSTANT NUMBER                                  := 1.0;
      l_full_name        CONSTANT VARCHAR2 (90)                           :=    g_pkg_name
                                                                             || '.'
                                                                             || l_api_name;
      l_product_id                NUMBER;
      l_fund_id                   NUMBER;
      l_offer_start_date          DATE;
      l_offer_end_date            DATE;
      l_act_budget_id             NUMBER;
      l_act_budgets_rec           ozf_actbudgets_pvt.act_budgets_rec_type;
      l_act_util_rec              ozf_actbudgets_pvt.act_util_rec_type ;
      l_amount                    NUMBER                                  := 0;
      l_converted_amt             NUMBER;
      l_perform_util              VARCHAR2 (1);
      l_offer_total_amount        NUMBER;
      l_offer_distribution_type   VARCHAR2 (30);
      l_total_qty                 NUMBER;
      l_level_type_code         VARCHAR2 (30);
      l_currency_code             VARCHAR2 (30);
      l_total_committed_amt       NUMBER;
      l_total_utilized_amt        NUMBER;
      l_fund_utilized_amt         NUMBER;
      l_utilized_amt              NUMBER;
      l_custom_setup_id           NUMBER;
      l_acct_closed_flag       VARCHAR2 (1);
      l_spread_flag       VARCHAR2 (1);
      l_cust_type         VARCHAR2(30);
      l_cust_acct_id     NUMBER;
      l_offer_owner     NUMBER;
      l_org_id             NUMBER;
      l_offer_org_id     NUMBER;
      l_date                DATE;

      --get offer date and currency.
      CURSOR c_offer_date IS
         SELECT qp.start_date_active,qp.end_date_active, NVL(qp.currency_code, ofs.fund_request_curr_code) currency_code,
                ofs.custom_setup_id,NVL(ofs.account_closed_flag,'N'),ofs.qualifier_id, ofs.qualifier_type,
                ofs.org_id
         FROM qp_list_headers_b qp,ozf_offers ofs
         WHERE qp.list_header_id = p_offer_id
         AND qp.list_header_id = ofs.qp_list_header_id;

      ---get distribution
      CURSOR c_offer_distribution IS
         SELECT offer_amount
               ,distribution_type,owner_id
         FROM ozf_offers
         WHERE qp_list_header_id = p_offer_id;

      --get product information.
      CURSOR c_off_products (p_offer_id IN NUMBER) IS
         SELECT DECODE (level_type_code, 'PRODUCT', inventory_item_id, category_id) product_id
               ,SUM(line_lumpsum_qty) amount, level_type_code
         FROM ams_act_products
         WHERE act_product_used_by_id = p_offer_id
         AND arc_act_product_used_by = 'OFFR'
         GROUP BY inventory_item_id,level_type_code,category_id; -- added by feliu to fix bug 4861647

      --get sum of lumpsum line amount.
      CURSOR c_off_pdts_total_qty (p_offer_id IN NUMBER) IS
         SELECT SUM (line_lumpsum_qty) total_quantity
         FROM ams_act_products
         WHERE act_product_used_by_id = p_offer_id
         AND arc_act_product_used_by = 'OFFR';

      --kdass 08-Jun-2005 Bug 4415878 SQL Repository Fix - changed the cursor query
      -- get committed budget information.
      CURSOR c_prod_budgets (p_offer_id IN NUMBER) IS
         SELECT NVL(plan_curr_committed_amt,0) approved_amount
                ,fund_id
                ,fund_currency currency_code
         FROM ozf_object_fund_summary
         WHERE object_id =p_offer_id
         AND object_type = 'OFFR';

         /*

         SELECT SUM (approved_amount) approved_amount, fund_id, currency_code
         FROM (
               SELECT NVL(plan_curr_amount,0) approved_amount, fund_id, currency_code
               FROM ozf_funds_utilized_all_b
               WHERE utilization_type = 'REQUEST'
               AND component_type = 'OFFR'
               AND component_id = p_offer_id
               UNION ALL
               SELECT NVL(-plan_curr_amount,0) approved_amount, fund_id, currency_code
               FROM ozf_funds_utilized_all_b
               WHERE utilization_type = 'TRANSFER'
               AND plan_type = 'OFFR'
               AND plan_id = p_offer_id
              ) GROUP BY fund_id, currency_code;


      CURSOR c_prod_budgets (p_offer_id IN NUMBER) IS
         SELECT SUM(NVL(DECODE(utilization_type, 'REQUEST',util.plan_curr_amount,-util.plan_curr_amount),0)) approved_amount,
            util.fund_id,util.currency_code
         FROM ozf_funds_utilized_all_b util
         WHERE util.utilization_type IN ('REQUEST','TRANSFER')
         AND DECODE(util.utilization_type,'REQUEST', util.component_type,util.plan_type) = 'OFFR'
         AND DECODE(util.utilization_type,'REQUEST', util.component_id,util.plan_id) = p_offer_id
         GROUP BY util.fund_id,util.currency_code;
      */

      --kdass 08-Jun-2005 Bug 4415878 SQL Repository Fix - changed the cursor query
      -- get total committed and utilized amount
      CURSOR c_committed_budgets(p_offer_id IN NUMBER) IS
        SELECT SUM(NVL(plan_curr_committed_amt,0))
        FROM ozf_object_fund_summary
        WHERE object_id =p_offer_id
        AND object_type = 'OFFR';
         /*
         SELECT SUM (approved_amount)
         FROM (SELECT NVL(plan_curr_amount,0) approved_amount
               FROM ozf_funds_utilized_all_b
               WHERE utilization_type = 'REQUEST'
                 AND component_type = 'OFFR'
                 AND component_id = p_offer_id
               UNION ALL
               SELECT NVL(-plan_curr_amount,0) approved_amount
               FROM ozf_funds_utilized_all_b
               WHERE utilization_type = 'TRANSFER'
                 AND plan_type = 'OFFR'
                 AND plan_id = p_offer_id);

      CURSOR c_committed_budgets(p_offer_id IN NUMBER) IS
        SELECT SUM(DECODE(utilization_type,'REQUEST',plan_curr_amount,'TRANSFER',-plan_curr_amount))
        FROM ozf_funds_utilized_all_b
        WHERE utilization_type IN ('REQUEST','TRANSFER')
        AND DECODE(utilization_type,'REQUEST', component_type,plan_type) = 'OFFR'
        AND DECODE(utilization_type,'REQUEST', component_id,plan_id) = p_offer_id;
      */

      CURSOR c_utilization_budgets(p_offer_id IN NUMBER) IS
        SELECT NVL(SUM(plan_curr_amount),0), MAX(creation_date)
        FROM ozf_funds_utilized_all_b
        WHERE plan_id = p_offer_id
        AND  plan_type = 'OFFR'
        AND  utilization_type ='ACCRUAL';

       -- get total utilized amount for this product and this budget.
     CURSOR c_utilized_budgets(p_offer_id IN NUMBER,p_fund_id IN NUMBER) IS
        SELECT SUM(util.plan_curr_amount)
        FROM ozf_funds_utilized_all_b util
        WHERE util.component_id = p_offer_id
        AND util.component_type = 'OFFR'
        AND util.utilization_type ='ACCRUAL'
        --AND product_id =p_product_id
        AND fund_id = p_fund_id;

    CURSOR l_scatter_posting (p_custom_setup_id IN NUMBER) IS
        SELECT attr_available_flag
        FROM   ams_custom_setup_attr
        WHERE  custom_setup_id = p_custom_setup_id
        AND    object_attribute = 'SCPO';

   --Added for bug 7030415
   CURSOR c_get_conversion_type( p_org_id IN NUMBER) IS
        SELECT exchange_rate_type
        FROM   ozf_sys_parameters_all
        WHERE  org_id = p_org_id;

   l_exchange_rate_type VARCHAR2(30) := FND_API.G_MISS_CHAR;
   l_rate               NUMBER;

    l_count NUMBER;
    l_limit_row NUMBER := 100;
    l_amount_remaining NUMBER;

   TYPE itemIdTbl       IS TABLE OF ams_act_products.inventory_item_id%TYPE;
   TYPE lumsumAmtTbl       IS TABLE OF ams_act_products.line_lumpsum_qty%TYPE;
   TYPE levelTypeTbl       IS TABLE OF ams_act_products.level_type_code%TYPE;

   l_itemId_tbl    itemIdTbl;
   l_lumsumAmt_tbl  lumsumAmtTbl;
   l_levelType_tbl  levelTypeTbl;

   l_spread_amount_remaining NUMBER;
   l_last_offer_accrual_date DATE;
   l_last_prod_accrual_date DATE;


   BEGIN
      SAVEPOINT Posting_lumpsum_amount;
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name || ': start');
      END IF;
      x_return_status            := fnd_api.g_ret_sts_success;

      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- get total committed amount.
      OPEN c_committed_budgets(p_offer_id);
      FETCH c_committed_budgets INTO l_total_committed_amt;
      CLOSE c_committed_budgets;

      -- get total utilized amount.
      OPEN c_utilization_budgets(p_offer_id);
      FETCH c_utilization_budgets INTO l_total_utilized_amt,l_last_offer_accrual_date;
      CLOSE c_utilization_budgets;

      OPEN c_offer_date;
      FETCH c_offer_date INTO l_offer_start_date,l_offer_end_date,l_currency_code,
            l_custom_setup_id,l_acct_closed_flag,l_cust_acct_id,l_cust_type,l_offer_org_id;
      CLOSE c_offer_date;

      -- get spread posting information.
      OPEN l_scatter_posting(l_custom_setup_id);
      FETCH l_scatter_posting INTO l_spread_flag;
      CLOSE l_scatter_posting;

      -- check wether date validation is reqd
      IF p_check_date = fnd_api.g_true THEN
     -- if the offer start date is today or has passed then only adjust
         IF TRUNC(l_offer_start_date) <= TRUNC(SYSDATE) THEN
            l_perform_util             := 'T';
         ELSE
            l_perform_util             := 'F';
         END IF;
      ELSE
         -- donot check date
         l_perform_util             := 'T';
      END IF;

      OPEN c_offer_distribution;
      FETCH c_offer_distribution INTO l_offer_total_amount, l_offer_distribution_type,l_offer_owner;
      CLOSE c_offer_distribution;

      --IF l_spread_flag = 'N' THEN 08/11/03 commented by feliu to fix bug 3091395
         validate_lumpsum_offer (p_qp_list_header_id => p_offer_id, x_return_status => x_return_status);
      --END IF;

      IF x_return_status <> fnd_api.g_ret_sts_success THEN
         x_return_status            := fnd_api.g_ret_sts_error;
         RAISE fnd_api.g_exc_error;
      END IF;

      IF G_DEBUG THEN
      ozf_utility_pvt.debug_message (  'l_perform_util ' || l_perform_util);
      ozf_utility_pvt.debug_message (  'l_acct_closed_flag ' || l_acct_closed_flag);
      ozf_utility_pvt.debug_message (  'l_total_utilized_amt ' || l_total_utilized_amt);
      ozf_utility_pvt.debug_message (  'l_offer_total_amount ' || l_offer_total_amount);
      ozf_utility_pvt.debug_message (  'p_offer_id ' || p_offer_id);
      ozf_utility_pvt.write_conc_log (  'l_total_committed_amt ' || l_total_committed_amt);
      END IF;

      --check if start date reaches, if account closed, and if already posted.
      --nirprasa,12.1.1 replace ROUND() by ozf_utility_pvt.currround() to use the currency precision instead
      --of hardcoded value.
      --nirprasa, start fix for bug 8625525

      IF l_perform_util = 'T' AND l_acct_closed_flag = 'N' AND  l_total_utilized_amt < l_total_committed_amt THEN

         OPEN c_off_products (p_offer_id);
         FETCH c_off_products BULK COLLECT INTO l_itemId_tbl,l_lumsumAmt_tbl,l_levelType_tbl LIMIT l_limit_row;

         FOR l_prod_budget_rec IN c_prod_budgets (p_offer_id) LOOP

            EXIT WHEN c_prod_budgets%NOTFOUND;
            l_amount_remaining := l_prod_budget_rec.approved_amount;
            l_offer_total_amount := l_total_committed_amt - NVL(l_total_utilized_amt,0);
            l_count := 0;

            --nirprasa, bug 8460909
            IF l_spread_flag = 'Y' THEN
                IF TRUNC(sysdate) > TRUNC(l_offer_end_date) THEN
                   l_date := TRUNC(l_offer_end_date);
                ELSE
                   l_date := TRUNC(sysdate);
                END IF;

                IF G_DEBUG THEN
                   ozf_utility_pvt.write_conc_log (  'l_date ' || l_date);
                   ozf_utility_pvt.write_conc_log (  'l_last_offer_accrual_date ' || l_last_offer_accrual_date);
                   ozf_utility_pvt.write_conc_log (  'l_total_committed_amt ' || l_total_committed_amt);
                   ozf_utility_pvt.write_conc_log (  'l_amount_remaining ' || l_amount_remaining);
                   ozf_utility_pvt.write_conc_log (  'l_total_utilized_amt ' || l_total_utilized_amt);
                END IF;

                IF l_last_offer_accrual_date IS NULL THEN
                   l_spread_amount_remaining := ozf_utility_pvt.currround(l_offer_total_amount * (l_date - TRUNC(l_offer_start_date) + 1) /(TRUNC(l_offer_end_date) - TRUNC(l_offer_start_date) + 1),l_prod_budget_rec.currency_code);
                ELSE
                   l_spread_amount_remaining := ozf_utility_pvt.currround(l_offer_total_amount * (l_date - TRUNC(l_last_offer_accrual_date) ) /(TRUNC(l_offer_end_date) - TRUNC(l_last_offer_accrual_date)),l_prod_budget_rec.currency_code);
                END IF;
                l_spread_amount_remaining := ozf_utility_pvt.currround((l_prod_budget_rec.approved_amount / l_total_committed_amt) * l_spread_amount_remaining,l_prod_budget_rec.currency_code);
            END IF;

            FOR i IN NVL(l_itemId_tbl.FIRST, 1) .. NVL(l_itemId_tbl.LAST, 0) LOOP
               l_count := l_count + 1;

               IF G_DEBUG THEN
                  ozf_utility_pvt.write_conc_log (  '*****************l_count ' || l_count||'*****************');
                  ozf_utility_pvt.write_conc_log (  'l_amount ' || l_amount);
                  ozf_utility_pvt.write_conc_log (  'l_spread_flag ' || l_spread_flag);
                  ozf_utility_pvt.write_conc_log (  'l_spread_amount_remaining ' || l_spread_amount_remaining);
               END IF;

               IF l_offer_distribution_type = '%' THEN
                  l_amount   := ozf_utility_pvt.currround(l_offer_total_amount * l_lumsumAmt_tbl(i) / 100,l_currency_code);
               ELSIF l_offer_distribution_type = 'QTY' THEN
                 OPEN c_off_pdts_total_qty (p_offer_id);
                 FETCH c_off_pdts_total_qty INTO l_total_qty;
                 CLOSE c_off_pdts_total_qty;
                 --14-OCT-2008 bug 7382309 - changed from 100 to offer committed amountl_total_committed_amt
                 --l_amount  := ROUND(l_lumsumAmt_tblozf_utility_pvt.currround(i) * 100 / l_total_qty,2);
                 l_amount  := ozf_utility_pvt.currround(l_lumsumAmt_tbl(i) * l_offer_total_amount / l_total_qty,l_currency_code);
               ELSIF l_offer_distribution_type = 'AMT' THEN
                  OPEN c_off_pdts_total_qty (p_offer_id);
                  FETCH c_off_pdts_total_qty INTO l_total_qty;
                  CLOSE c_off_pdts_total_qty;
                  IF G_DEBUG THEN
                     ozf_utility_pvt.write_conc_log (  'l_lumsumAmt_tbl(i) ' || l_lumsumAmt_tbl(i));
                     ozf_utility_pvt.write_conc_log (  'l_offer_total_amount ' || l_offer_total_amount);
                     ozf_utility_pvt.write_conc_log (  'l_total_qty ' || l_total_qty);
                  END IF;
                  l_amount := ozf_utility_pvt.currround(l_lumsumAmt_tbl(i) * l_offer_total_amount / l_total_qty,l_currency_code) ;
               END IF;



               IF l_spread_flag = 'Y' THEN
                  --posted amount for this product since start date.
                  -- add if condition to fix bug 3407559. only have partial amount if sysdate is less than offer end date.
                  --7721879 Fix
                  IF  TRUNC(SYSDATE) < TRUNC(l_offer_end_date) THEN
                    l_last_prod_accrual_date := TRUNC(l_offer_end_date);
                  END IF;

                  IF TRUNC(sysdate) < TRUNC(l_offer_end_date) THEN
                     IF G_DEBUG THEN
                        ozf_utility_pvt.write_conc_log (  'l_offer_start_date ' || l_offer_start_date);
                        ozf_utility_pvt.write_conc_log (  'l_offer_end_date ' || l_offer_end_date);
                        ozf_utility_pvt.write_conc_log (  'l_last_offer_accrual_date ' || l_last_offer_accrual_date);
                        ozf_utility_pvt.write_conc_log (  'l_amount ' || l_amount);
                     END IF;
                     IF l_last_offer_accrual_date IS NULL THEN
                        l_amount := ozf_utility_pvt.currround(l_amount * (TRUNC(sysdate) - TRUNC(l_offer_start_date) + 1)/(TRUNC(l_offer_end_date) - TRUNC(l_offer_start_date) + 1),l_currency_code);
                     ELSE
                        l_amount := ozf_utility_pvt.currround(l_amount * (TRUNC(sysdate) - TRUNC(l_last_offer_accrual_date))/(TRUNC(l_offer_end_date) - TRUNC(l_last_offer_accrual_date)),l_currency_code);
                     END IF;
                  END IF;
               END IF;

              IF G_DEBUG THEN
                  ozf_utility_pvt.write_conc_log (  'posting amount ' || l_amount || '  for product: ' || l_itemId_tbl(i));
                  ozf_utility_pvt.write_conc_log (  'l_spread_amount_remaining ' || l_spread_amount_remaining);
                  ozf_utility_pvt.write_conc_log (  'l_prod_budget_rec.approved_amount  ' || l_prod_budget_rec.approved_amount );
                  ozf_utility_pvt.write_conc_log (  'l_total_committed_amt  ' || l_total_committed_amt );
               END IF;

               IF l_spread_flag = 'Y' THEN
                  l_utilized_amt := ozf_utility_pvt.currround((l_prod_budget_rec.approved_amount / l_total_committed_amt) * l_amount,l_prod_budget_rec.currency_code);
               ELSE
                  l_utilized_amt := ozf_utility_pvt.currround((l_prod_budget_rec.approved_amount / l_total_committed_amt) * l_amount,l_prod_budget_rec.currency_code);
               END IF;

               --nirprasa, end fix for bug 8625525

               IF G_DEBUG THEN
                ozf_utility_pvt.write_conc_log (  ' l_utilized_amt ' || l_utilized_amt);
                ozf_utility_pvt.write_conc_log (  ' l_count ' || l_count);
                ozf_utility_pvt.write_conc_log (  ' l_itemId_tbl.COUNT ' || l_itemId_tbl.COUNT);
               END IF;

               IF l_count = l_itemId_tbl.COUNT THEN
               -- use remaining amount if it is last record to solve the issue for rounding.
                  IF l_spread_flag <> 'Y' THEN
                     l_utilized_amt := l_amount_remaining;
                  ELSE
                     IF G_DEBUG THEN
                     ozf_utility_pvt.debug_message (  ' l_spread_amount_remaining ' || l_spread_amount_remaining);
                     END IF;

                     l_utilized_amt := l_spread_amount_remaining;

                     END IF;
                  END IF;

               IF G_DEBUG THEN
                  ozf_utility_pvt.debug_message (  ' l_spread_amount_remaining1 ' || l_spread_amount_remaining);
                  ozf_utility_pvt.debug_message (  ' l_amount_remaining1 ' || l_amount_remaining);
                  ozf_utility_pvt.debug_message (  ' l_utilized_amt1 ' || l_utilized_amt);
               END IF;

               --7721879
               l_amount_remaining := l_amount_remaining - l_utilized_amt;
               l_spread_amount_remaining := l_spread_amount_remaining - l_utilized_amt;

               IF G_DEBUG THEN
               ozf_utility_pvt.debug_message (  ' l_spread_amount_remaining2 ' || l_spread_amount_remaining);
               ozf_utility_pvt.debug_message (  ' l_amount_remaining2 ' || l_amount_remaining);
               ozf_utility_pvt.debug_message (  ' l_utilized_amt2 ' || l_utilized_amt);
               END IF;

               IF G_DEBUG THEN
                 ozf_utility_pvt.debug_message (  ': lumpsum posting amount ' || l_utilized_amt);
               END IF;

               -- convert the object currency amount in to fund currency
               IF l_prod_budget_rec.currency_code = l_currency_code THEN
                  l_converted_amt            := l_utilized_amt;
               ELSE
                  --Added for bug 7030415

                  OPEN c_get_conversion_type(l_offer_org_id);
                  FETCH c_get_conversion_type INTO l_exchange_rate_type;
                  CLOSE c_get_conversion_type;
                  -- call the currency conversion wrapper
                  ozf_utility_pvt.convert_currency (
                     x_return_status=> x_return_status
                    ,p_from_currency=> l_currency_code
                    ,p_to_currency=> l_prod_budget_rec.currency_code
                    ,p_conv_type=> l_exchange_rate_type
                    ,p_from_amount=> l_utilized_amt
                    ,x_to_amount=> l_converted_amt
                    ,x_rate=> l_rate
                  );

                  IF x_return_status <> fnd_api.g_ret_sts_success THEN
                     x_return_status            := fnd_api.g_ret_sts_error;
                     RAISE fnd_api.g_exc_error;
                  END IF;
               END IF;

               IF G_DEBUG THEN
               ozf_utility_pvt.debug_message (  'LS CP l_converted_amt ' || l_converted_amt);
               END IF;

               IF l_converted_amt <> 0 THEN
                  l_act_budgets_rec.request_amount := l_utilized_amt; --in object currency.
                  l_act_budgets_rec.act_budget_used_by_id := p_offer_id;
                  l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
                  l_act_budgets_rec.budget_source_type := 'OFFR';
                  l_act_budgets_rec.budget_source_id := p_offer_id;
                  l_act_budgets_rec.request_currency := l_currency_code;
                  l_act_budgets_rec.request_date := SYSDATE;
                  l_act_budgets_rec.status_code := 'APPROVED';
                  l_act_budgets_rec.user_status_id := ozf_utility_pvt.get_default_user_status (
                                                              'OZF_BUDGETSOURCE_STATUS'
                                                              ,l_act_budgets_rec.status_code
                                                              );
                  l_act_budgets_rec.transfer_type := 'UTILIZED';
                  l_act_budgets_rec.approval_date := SYSDATE;
                  l_act_budgets_rec.requester_id := l_offer_owner;
                  l_act_budgets_rec.approver_id :=
                                               ozf_utility_pvt.get_resource_id (fnd_global.user_id);
              -- when workflow goes through without approval, fnd_global.user_id is not passed.
                  IF l_act_budgets_rec.approver_id = -1 THEN
                     l_act_budgets_rec.approver_id := l_offer_owner;
                  END IF;
                  l_act_budgets_rec.justification :=
                                             fnd_message.get_string ('OZF', 'OZF_ACT_BUDGET_LUMPSUM_UTIL');
                  l_act_budgets_rec.parent_source_id := l_prod_budget_rec.fund_id;
                  l_act_budgets_rec.parent_src_curr := l_prod_budget_rec.currency_code;
                  l_act_budgets_rec.parent_src_apprvd_amt := l_converted_amt; -- in budget currency.
                  l_act_util_rec.product_id := l_itemId_tbl(i) ;
                  l_act_util_rec.product_level_type := l_levelType_tbl(i);
                  l_act_util_rec.gl_date := sysdate;
                  --nirprasa,12.2
                  l_act_util_rec.plan_currency_code := l_currency_code;
                  l_act_util_rec.fund_request_currency_code := l_currency_code;
                  --nirprasa,12.2
                  l_org_id := find_org_id (l_act_budgets_rec.parent_source_id);
                  -- set org_context since workflow mailer does not set the context
                  set_org_ctx (l_org_id);

                  process_act_budgets(x_return_status  => l_return_status,
                                       x_msg_count => x_msg_count,
                                       x_msg_data   => x_msg_data,
                                       p_act_budgets_rec => l_act_budgets_rec,
                                       p_act_util_rec   =>l_act_util_rec,
                                       x_act_budget_id  => l_act_budget_id
                                       ) ;
                  IF G_DEBUG THEN
                    ozf_utility_pvt.debug_message (   l_full_name
                                              || ': end create act budgets  ');
                  END IF;

                  IF l_return_status = fnd_api.g_ret_sts_error THEN
                     RAISE fnd_api.g_exc_error;
                  ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                     RAISE fnd_api.g_exc_unexpected_error;
                  END IF;
               END IF; -- for util amount

               l_act_util_rec             := NULL;
               l_act_budgets_rec          := NULL;

            END LOOP;--end for loop

         END LOOP;

         CLOSE c_off_products;
      END IF;

       fnd_msg_pub.count_and_get (
         p_encoded=> fnd_api.g_false
        ,p_count=> x_msg_count
        ,p_data=> x_msg_data
      );
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name || ': end');
      END IF;
  EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO Posting_lumpsum_amount;
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO Posting_lumpsum_amount;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN OTHERS THEN
         ROLLBACK TO Posting_lumpsum_amount;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
     END post_lumpsum_amount;
---------------------------------------------------------------------
-- PROCEDURE
--    post_utilized_budget
--
-- PURPOSE
-- This procedure is called by updating offer API when changing offer status to "ACTIVE'
-- and by post_utilized_budget concurrent program for scan data offer and lump sum offer.
-- It is used to create utilized records when offer start date reaches.

-- PARAMETERS
--       p_offer_id
--       p_offer_type
--      ,p_api_version     IN       NUMBER
--      ,p_init_msg_list   IN       VARCHAR2 := fnd_api.g_false
--      ,p_commit          IN       VARCHAR2 := fnd_api.g_false
--      ,x_msg_count       OUT      NUMBER
--      ,x_msg_data        OUT      VARCHAR2
--      ,x_return_status   OUT      VARCHAR2)

-- NOTES
-- HISTORY
--    09/24/2002  feliu  Create.
----------------------------------------------------------------------
 PROCEDURE post_utilized_budget (
      p_offer_id        IN       NUMBER
     ,p_offer_type      IN       VARCHAR2
     ,p_api_version     IN       NUMBER
     ,p_init_msg_list   IN       VARCHAR2 := fnd_api.g_false
     ,p_commit          IN       VARCHAR2 := fnd_api.g_false
     ,p_check_date      IN       VARCHAR2 := fnd_api.g_true -- do date validation
     ,x_msg_count       OUT NOCOPY      NUMBER
     ,x_msg_data        OUT NOCOPY      VARCHAR2
     ,x_return_status   OUT NOCOPY      VARCHAR2
   ) IS
      l_api_version           NUMBER                                  := 1.0;
      l_return_status         VARCHAR2 (1)                            := fnd_api.g_ret_sts_success;
      l_msg_data               VARCHAR2 (2000);
      l_msg_count              NUMBER;
      l_api_name              VARCHAR2 (60)                           := 'post_utilized_budget';
      l_full_name        CONSTANT VARCHAR2 (90)                           :=    g_pkg_name
                                                                             || '.'
                                                                             || l_api_name;

      l_cust_setup           NUMBER;
      CURSOR c_offer_rec(p_offer_id IN NUMBER) IS
         SELECT custom_setup_id
         FROM ozf_offers
         WHERE qp_list_header_id = p_offer_id;

    BEGIN
      SAVEPOINT post_utilized_budget;
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (': begin ' || l_full_name);
      END IF;
      x_return_status            := fnd_api.g_ret_sts_success;

      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF p_offer_type = 'SCAN_DATA' THEN
           Post_scan_data_amount
       (
             p_offer_id         => p_offer_id
            ,p_api_version     => l_api_version
            ,p_init_msg_list   => fnd_api.g_false
            ,p_commit          => fnd_api.g_false
            ,p_check_date      => p_check_date
            ,x_msg_count       => l_msg_count
            ,x_msg_data        => l_msg_data
            ,x_return_status   => l_return_status
          );
      ELSIF p_offer_type = 'LUMPSUM' THEN
         OPEN c_offer_rec (p_offer_id);
         FETCH c_offer_rec INTO l_cust_setup;
         CLOSE c_offer_rec;

     IF l_cust_setup = 110 THEN  -- for soft fund.
           post_sf_lumpsum_amount
           (
             p_offer_id         => p_offer_id
            ,p_api_version     => l_api_version
            ,p_init_msg_list   => fnd_api.g_false
            ,p_commit          => fnd_api.g_false
            ,p_validation_level => fnd_api.g_valid_level_full
            ,x_msg_count       => l_msg_count
            ,x_msg_data        => l_msg_data
            ,x_return_status   => l_return_status
           );
     ELSE
           post_lumpsum_amount
           (
             p_offer_id         => p_offer_id
            ,p_api_version     => l_api_version
            ,p_init_msg_list   => fnd_api.g_false
            ,p_commit          => fnd_api.g_false
            ,p_check_date      => p_check_date
            ,x_msg_count       => l_msg_count
            ,x_msg_data        => l_msg_data
            ,x_return_status   => l_return_status
           );
         END IF;

     END IF;

     IF l_return_status <> fnd_api.g_ret_sts_success THEN
         x_return_status            := fnd_api.g_ret_sts_error;
         RAISE fnd_api.g_exc_error;
     END IF;

      fnd_msg_pub.count_and_get (
         p_encoded=> fnd_api.g_false
        ,p_count=> x_msg_count
        ,p_data=> x_msg_data
      );

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name || ': end');
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO post_utilized_budget;
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO post_utilized_budget;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN OTHERS THEN
         ROLLBACK TO post_utilized_budget;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );

  END post_utilized_budget;

---------------------------------------------------------------------
-- PROCEDURE
--    adjust_utilized_budget
--
-- PURPOSE
--This API will be called by claim to automatic increase committed and utilized budget
--when automatic adjustment is allowed for scan data offer.
--It will increase both committed and utilized amount.

-- PARAMETERS
--       p_offer_id
--       p_product_activity_id
--       p_amount
--      ,p_cust_acct_id         IN         NUMBER
--      ,p_bill_to_cust_acct_id IN         NUMBER
--      ,p_bill_to_site_use_id  IN         NUMBER
--      ,p_ship_to_site_use_id  IN         NUMBER
--      ,p_api_version     IN       NUMBER
--      ,p_init_msg_list   IN       VARCHAR2 := fnd_api.g_false
--      ,p_commit          IN       VARCHAR2 := fnd_api.g_false
--      ,x_msg_count       OUT      NUMBER
--      ,x_msg_data        OUT      VARCHAR2
--      ,x_return_status   OUT      VARCHAR2)

-- NOTES
-- HISTORY
--    09/24/2002  feliu  Create.
--    03/29/2005  kdass  bug 5117557 - added params p_cust_acct_id, p_bill_to_cust_acct_id,
--                       p_bill_to_site_use_id, p_ship_to_site_use_id
----------------------------------------------------------------------

PROCEDURE  adjust_utilized_budget (
      p_claim_id             IN         NUMBER
     ,p_offer_id             IN         NUMBER
     ,p_product_activity_id  IN         NUMBER
     ,p_amount               IN         NUMBER
     ,p_cust_acct_id         IN         NUMBER
     ,p_bill_to_cust_acct_id IN         NUMBER
     ,p_bill_to_site_use_id  IN         NUMBER
     ,p_ship_to_site_use_id  IN         NUMBER
     ,p_api_version          IN         NUMBER
     ,p_init_msg_list        IN         VARCHAR2 := fnd_api.g_false
     ,p_commit               IN         VARCHAR2 := fnd_api.g_false
     ,x_msg_count            OUT NOCOPY NUMBER
     ,x_msg_data             OUT NOCOPY VARCHAR2
     ,x_return_status        OUT NOCOPY VARCHAR2
   ) IS

      l_return_status             VARCHAR2 (10)                           := fnd_api.g_ret_sts_success;
      l_api_name         CONSTANT VARCHAR2 (30)                           := 'adjust_utilized_budget';
      l_api_version      CONSTANT NUMBER                                  := 1.0;
      l_msg_data               VARCHAR2 (2000);
      l_msg_count              NUMBER;
      l_full_name        CONSTANT VARCHAR2 (90)                           :=    g_pkg_name
                                                                             || '.'
                                                                             || l_api_name;
      l_amount                    NUMBER                                  := 0;
      l_fund_id                   NUMBER;
      L_scan_value                NUMBER;
      l_available_amt       NUMBER;
      l_offer_currency_code       VARCHAR2 (30);
      l_product_id                NUMBER;
      l_level_type_code         VARCHAR2 (30);
      l_act_budgets_rec           ozf_actbudgets_pvt.act_budgets_rec_type;
      l_act_util_rec          ozf_actbudgets_pvt.act_util_rec_type ;
      l_converted_amt             NUMBER;
      l_budget_currency_code             VARCHAR2 (30);
      l_act_budget_id             NUMBER;
      l_source_from_parent        VARCHAR2 (1);
      l_committed_remaining       NUMBER;
      l_campaign_id               NUMBER;
      l_unit_remaining            NUMBER;
      l_util_amount               NUMBER;
      l_amount_remaining          NUMBER;
      l_cust_acct_id              NUMBER;
      l_offer_quantity            NUMBER;

      --get product information.
      CURSOR c_off_products (p_product_activity_id IN NUMBER) IS
         SELECT DECODE (level_type_code, 'PRODUCT', inventory_item_id, category_id) product_id
               ,level_type_code,scan_value, quantity
         FROM ams_act_products
         WHERE activity_product_Id = p_product_activity_id;

      --get offer currency and source_from_parent
      CURSOR c_offer_data(p_qp_list_header_id IN NUMBER) IS
         SELECT nvl(transaction_currency_code,fund_request_curr_code),NVL(source_from_parent,'N'),qualifier_id
         FROM ozf_offers
         WHERE qp_list_header_id = p_qp_list_header_id;

      --get total committed remaining.
      ---Ribha commented this. Dont use ozf_object_checkbook_v (non mergeable view)
      -- Ribha: use ozf_object_fund_summary instead of ozf_object_checkbook_v
      CURSOR c_budget_committed(p_qp_list_header_id IN NUMBER) IS
         SELECT SUM(NVL(plan_curr_committed_amt,0) - NVL(plan_curr_utilized_amt,0))
         from ozf_object_fund_summary
         WHERE object_type = 'OFFR'
         AND object_id = p_qp_list_header_id;

       -- get parent campaign id
      CURSOR c_parent_camapign(p_qp_list_header_id IN NUMBER) IS
         SELECT act_offer_used_by_id
         FROM ozf_act_offers
         WHERE qp_list_header_id = p_qp_list_header_id
         AND arc_act_offer_used_by = 'CAMP';

      --get utilized budget information.
      CURSOR c_utilized_budget(p_product_activity_id IN NUMBER) IS
         SELECT  fund_id,plan_type,plan_id, currency_code
         FROM ozf_funds_utilized_all_b
         WHERE activity_product_Id = p_product_activity_id;

      --get total available budget amount.
      /*
      CURSOR c_budget_data(p_fund_id IN NUMBER) IS
         SELECT available_budget,fund_id,currency_code_tc
         FROM ozf_fund_details_v
         WHERE fund_id = p_fund_id;
      */
      --12/08/2005 kdass - sql repository fix SQL ID 14892491 - query the base table directly
      CURSOR c_budget_data(p_fund_id IN NUMBER) IS
         SELECT (NVL(original_budget, 0) - NVL(holdback_amt, 0)
                 + NVL(transfered_in_amt, 0) - NVL(transfered_out_amt, 0)) available_budget,
                fund_id,currency_code_tc
         FROM ozf_funds_all_b
         WHERE fund_id = p_fund_id;


      --get un_utilized budget.
      CURSOR c_source_fund(p_qp_list_header_id IN NUMBER) IS
        SELECT fund_id
               ,fund_currency
               ,NVL(committed_amt,0)-NVL(utilized_amt,0) committed_amt
        FROM ozf_object_fund_summary
        WHERE object_id =p_qp_list_header_id
        AND object_type = 'OFFR';

     /*
         SELECT   fund_id
                 ,fund_currency
                 ,SUM (amount) committed_amt
             FROM (SELECT   a1.fund_id fund_id
                           ,a1.currency_code fund_currency
                           ,NVL (SUM (a1.amount), 0) amount
                       FROM ozf_funds_utilized_all_b a1
                      WHERE a1.component_id = p_qp_list_header_id
                        AND a1.component_type = 'OFFR'
                        AND a1.utilization_type = 'REQUEST'
                   GROUP BY a1.fund_id, a1.currency_code
                   UNION
                   SELECT   a2.fund_id fund_id
                           ,a2.currency_code fund_currency
                           ,-NVL (SUM (a2.amount), 0) amount
                       FROM ozf_funds_utilized_all_b a2
                      WHERE a2.plan_id = p_qp_list_header_id
                        AND a2.plan_type = 'OFFR'
                   GROUP BY a2.fund_id, a2.currency_code)
         GROUP BY fund_id, fund_currency
         ORDER BY fund_id;
*/
   BEGIN
      SAVEPOINT adjust_utilized_budget;
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name || ': start');
      END IF;
      x_return_status            := fnd_api.g_ret_sts_success;

      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      -- get product information.
      OPEN c_off_products(p_product_activity_id);
      FETCH c_off_products INTO l_product_id, l_level_type_code,l_scan_value,l_offer_quantity;
      CLOSE c_off_products;

      -- get offer information.
      OPEN c_offer_data(p_offer_id);
      FETCH c_offer_data INTO l_offer_currency_code,l_source_from_parent,l_cust_acct_id;
      CLOSE c_offer_data;

      l_amount := p_amount * l_scan_value; -- in object currency.

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message ( l_full_name || 'l_amount:  ' || l_amount);
      END IF;
      -- get committed remaining. Ribha: changed as performance fix.
      OPEN c_budget_committed(p_offer_id);
      FETCH c_budget_committed INTO l_committed_remaining;
      CLOSE c_budget_committed;
    --  l_committed_remaining := nvl(ozf_utility_pvt.get_commited_amount(p_offer_id),0) - nvl(ozf_utility_pvt.get_utilized_amount(p_offer_id),0);

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (l_full_name ||'l_committed_remaining:  ' || l_committed_remaining);
      END IF;

      IF ROUND(l_committed_remaining/l_scan_value) < p_amount THEN -- committed remaining is not enough.
         IF l_source_from_parent ='Y' THEN -- offer is sourced from campaign.

         -- get campaign information.
            OPEN c_parent_camapign(p_offer_id);
            FETCH c_parent_camapign INTO l_campaign_id;
            CLOSE c_parent_camapign;

          IF G_DEBUG THEN
            ozf_utility_pvt.debug_message (l_full_name ||'create_act_budgets:  ' || l_campaign_id);
          END IF;

            l_act_budgets_rec.budget_source_type := 'CAMP';
            l_act_budgets_rec.budget_source_id := l_campaign_id;
         ELSE  -- sourced from budget.
            --find first budget which has enough fund to source requirement.
            FOR l_budget_util_rec IN c_utilized_budget (p_product_activity_id) LOOP
          --change later if a error has to be raised or not.
         /* IF c_utilized_budget%NOTFOUND THEN
              ozf_utility_pvt.error_message ('OZF_ACT_BUDG_UTIL_OVER');
          END IF;
         */
               EXIT WHEN c_utilized_budget%NOTFOUND;

               OPEN c_budget_data(l_budget_util_rec.fund_id);
               FETCH c_budget_data INTO l_available_amt,l_fund_id,l_budget_currency_code;
               CLOSE c_budget_data;

            -- convert the object currency amount in to fund currency
               IF l_budget_util_rec.currency_code = l_offer_currency_code THEN
                  l_converted_amt            := l_amount - l_committed_remaining;
               ELSE

             -- call the currency conversion wrapper
                 ozf_utility_pvt.convert_currency (
                     x_return_status=> x_return_status
                    ,p_from_currency=> l_offer_currency_code
                    ,p_to_currency=> l_budget_util_rec.currency_code
                    ,p_from_amount=> l_amount - l_committed_remaining
                    ,x_to_amount=> l_converted_amt
                 );

                 IF x_return_status <> fnd_api.g_ret_sts_success THEN
                    x_return_status            := fnd_api.g_ret_sts_error;
                    RAISE fnd_api.g_exc_error;
                 END IF;
               END IF; -- end for currency test.

              --if budget has enough available, then select this budget as source.
               EXIT WHEN  l_available_amt >= l_converted_amt;
            END LOOP;

            l_act_budgets_rec.budget_source_type := 'FUND';
            l_act_budgets_rec.budget_source_id := l_fund_id;

         --handle case for all budgets has not enough money.
            IF l_converted_amt > l_available_amt THEN
                ozf_utility_pvt.error_message ('OZF_ACT_BUDG_NO_MONEY');
            END IF;

         END IF; -- end of  source from parent.

         l_act_budgets_rec.act_budget_used_by_id := p_offer_id;
         l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
         l_act_budgets_rec.transfer_type := 'REQUEST';
         l_act_util_rec.adjustment_type := 'INCREASE_COMM_EARNED';
         l_act_util_rec.adjustment_type_id := -8;
         l_act_util_rec.adjustment_date := sysdate;
         l_act_budgets_rec.request_amount := (p_amount - ROUND(l_committed_remaining/l_scan_value))*l_scan_value; -- in object currency.
         l_act_budgets_rec.request_currency := l_offer_currency_code;
         l_act_budgets_rec.approved_amount := l_act_budgets_rec.request_amount;
         l_act_budgets_rec.approved_original_amount := l_converted_amt; -- in budget currency.
         l_act_budgets_rec.approved_in_currency := l_budget_currency_code;
         l_act_budgets_rec.status_code := 'APPROVED';
         l_act_budgets_rec.request_date := SYSDATE;
         l_act_budgets_rec.user_status_id :=
                                         ozf_utility_pvt.get_default_user_status (
                                             'OZF_BUDGETSOURCE_STATUS'
                                             ,l_act_budgets_rec.status_code
                                            );
         l_act_budgets_rec.approval_date := SYSDATE;
         l_act_budgets_rec.approver_id :=  ozf_utility_pvt.get_resource_id (fnd_global.user_id);
         l_act_budgets_rec.requester_id := ozf_utility_pvt.get_resource_id (fnd_global.user_id);

         ozf_actbudgets_pvt.create_act_budgets (
           p_api_version=> l_api_version
          ,x_return_status=> l_return_status
          ,x_msg_count=> l_msg_count
          ,x_msg_data=> l_msg_data
          ,p_act_budgets_rec=> l_act_budgets_rec
          ,p_act_util_rec=> l_act_util_rec
          ,x_act_budget_id=> l_act_budget_id
          ,p_approval_flag=> fnd_api.g_true
         );

         IF NOT (l_return_status = fnd_api.g_ret_sts_success) THEN
             ROLLBACK TO recal_comm_fund_conc;
             fnd_msg_pub.count_and_get (
              p_count=> x_msg_count
             ,p_data=> x_msg_data
             ,p_encoded=> fnd_api.g_false
             );
         END IF;

      END IF ; -- end of committed remaining is less than  required.

      l_unit_remaining := p_amount;

    --Created utilized record.
      FOR l_fund_rec IN c_source_fund (p_offer_id) LOOP
        IF l_fund_rec.committed_amt <> 0 THEN
          l_act_budgets_rec := NULL;
          l_act_util_rec  := NULL;

          -- convert the object currency amount in to fund currency
          IF l_fund_rec.fund_currency = l_offer_currency_code THEN
              l_converted_amt            := l_amount; -- in fund currency
          ELSE
           -- call the currency conversion wrapper
             ozf_utility_pvt.convert_currency (
                 x_return_status=> x_return_status
                 ,p_from_currency=> l_offer_currency_code
                 ,p_to_currency=> l_fund_rec.fund_currency
                 ,p_from_amount=> l_amount
                 ,x_to_amount=> l_converted_amt
             );

             IF x_return_status <> fnd_api.g_ret_sts_success THEN
                 x_return_status            := fnd_api.g_ret_sts_error;
                 RAISE fnd_api.g_exc_error;
             END IF;
          END IF;

          --check against the converted amount but update the amount in parent currency
          IF NVL (l_fund_rec.committed_amt, 0) >= NVL (l_converted_amt, 0) THEN
             l_util_amount              := l_amount; -- in req currency
             l_amount_remaining         :=   l_amount
                                                - l_util_amount; -- in request currency
             l_act_budgets_rec.parent_src_apprvd_amt := l_converted_amt;
          ELSIF NVL (l_fund_rec.committed_amt, 0) < NVL (l_converted_amt, 0) THEN
                  -- call the currency conversion wrapper
             ozf_utility_pvt.convert_currency (
                     x_return_status=> x_return_status
                    ,p_from_currency=> l_fund_rec.fund_currency
                    ,p_to_currency=> l_offer_currency_code
                    ,p_from_amount=> l_fund_rec.committed_amt
                    ,x_to_amount=> l_util_amount
             );
             l_util_amount := ROUND(l_util_amount/l_scan_value) * l_scan_value;
             l_unit_remaining := l_unit_remaining - ROUND(l_util_amount/l_scan_value);
             l_amount_remaining         :=   l_amount -  l_util_amount; -- in req currnecy
             l_act_budgets_rec.parent_src_apprvd_amt :=  l_util_amount;
          END IF;

          l_amount                   := l_amount_remaining; -- in req currency
          l_act_budgets_rec.request_amount := l_util_amount;
          l_act_budgets_rec.act_budget_used_by_id := p_offer_id;
          l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
          l_act_budgets_rec.budget_source_type := 'OFFR';
          l_act_budgets_rec.budget_source_id := p_offer_id;
          l_act_budgets_rec.request_currency := l_offer_currency_code;
          l_act_budgets_rec.request_date := SYSDATE;
          l_act_budgets_rec.status_code := 'APPROVED';
          l_act_budgets_rec.user_status_id := ozf_utility_pvt.get_default_user_status (
                                             'OZF_BUDGETSOURCE_STATUS'
                                             ,l_act_budgets_rec.status_code
                                            );
          l_act_budgets_rec.transfer_type := 'UTILIZED';
          l_act_budgets_rec.approval_date := SYSDATE;
          l_act_budgets_rec.approver_id := ozf_utility_pvt.get_resource_id (fnd_global.user_id);
          fnd_message.set_name ('OZF', 'OZF_ACT_BUDGET_INCR_UTIL');
          fnd_message.set_token ('CLAIM_ID', p_claim_id, FALSE);
          l_act_budgets_rec.justification := fnd_message.get;
          l_act_budgets_rec.parent_source_id := l_fund_rec.fund_id;
          l_act_budgets_rec.parent_src_curr := l_fund_rec.fund_currency;
          l_act_util_rec.product_id := l_product_id ;
          l_act_util_rec.product_level_type := l_level_type_code;
          l_act_util_rec.gl_date := sysdate;

          --kdass 29-MAR-2006 bug 5117557
          l_act_util_rec.cust_account_id := p_cust_acct_id;
          l_act_util_rec.billto_cust_account_id := p_bill_to_cust_acct_id;
          l_act_util_rec.bill_to_site_use_id := p_bill_to_site_use_id;
          l_act_util_rec.ship_to_site_use_id := p_ship_to_site_use_id;
          l_act_util_rec.scan_unit := p_amount * l_offer_quantity;
          l_act_util_rec.scan_unit_remaining := p_amount * l_offer_quantity;
          --l_act_util_rec.scan_unit := p_amount;
          --l_act_util_rec.scan_unit_remaining := p_amount;

          l_act_util_rec.activity_product_id := p_product_activity_id;
          --l_act_util_rec.utilization_type :='UTILIZED';
          l_act_util_rec.utilization_type :='ADJUSTMENT';
          l_act_util_rec.adjustment_type := 'INCREASE_COMM_EARNED';
          l_act_util_rec.adjustment_type_id := -8;
       --   l_act_util_rec.billto_cust_account_id := l_cust_acct_id;

          process_act_budgets (x_return_status  => l_return_status,
                                       x_msg_count => x_msg_count,
                                       x_msg_data   => x_msg_data,
                                       p_act_budgets_rec => l_act_budgets_rec,
                                       p_act_util_rec   =>l_act_util_rec,
                                       x_act_budget_id  => l_act_budget_id
                                       ) ;

          IF l_return_status = fnd_api.g_ret_sts_error THEN
             RAISE fnd_api.g_exc_error;
          ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
             RAISE fnd_api.g_exc_unexpected_error;
          END IF;
        EXIT WHEN l_amount_remaining = 0;
       END IF;
      END LOOP;

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
         ROLLBACK TO adjust_utilized_budget;
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO adjust_utilized_budget;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN OTHERS THEN
         ROLLBACK TO adjust_utilized_budget;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );

    END adjust_utilized_budget;

/*****************************************************************************************/
-- Start of Comments
-- NAME
--    update_budget_source
-- PURPOSE
-- This API is called from the java layer from the update button on budget_sourcing screen
-- It update source_from_parent column for ams_campaign_schedules_b and AMS_EVENT_OFFERS_ALL_B.
-- HISTORY
-- 12/08/2002  feliu  CREATED
---------------------------------------------------------------------

   PROCEDURE update_budget_source(
      p_object_version_number IN       NUMBER
     ,p_budget_used_by_id     IN       NUMBER
     ,p_budget_used_by_type   IN       VARCHAR2
     ,p_from_parent           IN       VARCHAR2
     ,p_api_version           IN       NUMBER
     ,p_init_msg_list         IN       VARCHAR2 := fnd_api.g_false
     ,p_commit                IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN       NUMBER := fnd_api.g_valid_level_full
     ,x_return_status         OUT NOCOPY      VARCHAR2
     ,x_msg_count             OUT NOCOPY      NUMBER
     ,x_msg_data              OUT NOCOPY      VARCHAR2
   ) IS
      l_api_version   CONSTANT NUMBER                                  := 1.0;
      l_api_name      CONSTANT VARCHAR2 (50)                           := 'update_budget_source';
      l_full_name     CONSTANT VARCHAR2 (80)                           :=    g_pkg_name
                                                                          || '.'
                                                                          || l_api_name;
      l_return_status          VARCHAR2 (1);
      l_msg_data               VARCHAR2 (10000);
      l_msg_count              NUMBER;

BEGIN
      SAVEPOINT update_budget_source;
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (': begin ' || l_full_name);
      END IF;
      x_return_status            := fnd_api.g_ret_sts_success;

      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      IF p_budget_used_by_type = 'CSCH' THEN

         UPDATE ams_campaign_schedules_b
         SET source_from_parent = p_from_parent
             --,object_version_number =   p_object_version_number + 1
         WHERE schedule_id = p_budget_used_by_id;
         --AND object_version_number = p_object_version_number;

         IF (SQL%NOTFOUND) THEN
         -- Error, check the msg level and added an error message to the
         -- API message list
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name ('OZF', 'OZF_API_RECORD_NOT_FOUND');
               fnd_msg_pub.ADD;
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
         END IF;
      ELSE
         UPDATE ams_event_offers_all_b
         SET source_from_parent = p_from_parent
         WHERE event_offer_id = p_budget_used_by_id;

         IF (SQL%NOTFOUND) THEN
         -- Error, check the msg level and added an error message to the
         -- API message list
            IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name ('OZF', 'OZF_API_RECORD_NOT_FOUND');
               fnd_msg_pub.ADD;
            END IF;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;
      END IF;

      -- Standard check of p_commit.
      IF fnd_api.to_boolean (p_commit) THEN
         COMMIT WORK;
      END IF;

      fnd_msg_pub.count_and_get (
         p_encoded=> fnd_api.g_false
        ,p_count=> x_msg_count
        ,p_data=> x_msg_data
      );

      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name || ': end');
      END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO update_budget_source;
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO update_budget_source;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN OTHERS THEN
         ROLLBACK TO update_budget_source;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
   END update_budget_source;


 /*****************************************************************************************/
-- Start of Comments
-- NAME
--    post_sf_lumpsum_amount
-- PURPOSE
-- This API is called from soft fund request to create expense based utilization.
-- HISTORY
-- 10/22/2003  feliu  CREATED
---------------------------------------------------------------------

   PROCEDURE post_sf_lumpsum_amount (
      p_offer_id        IN       NUMBER
     ,p_api_version     IN       NUMBER
     ,p_init_msg_list   IN       VARCHAR2 := fnd_api.g_false
     ,p_commit          IN       VARCHAR2 := fnd_api.g_false
     ,p_validation_level      IN       NUMBER := fnd_api.g_valid_level_full
     ,x_msg_count       OUT NOCOPY      NUMBER
     ,x_msg_data        OUT NOCOPY      VARCHAR2
     ,x_return_status   OUT NOCOPY      VARCHAR2
   ) IS
      l_return_status             VARCHAR2 (10)                           := fnd_api.g_ret_sts_success;
      l_api_name         CONSTANT VARCHAR2 (30)                           := 'post_sf_lumpsum_amount';
      l_api_version      CONSTANT NUMBER                                  := 1.0;
      l_full_name        CONSTANT VARCHAR2 (90)                           :=    g_pkg_name
                                                                             || '.'
                                                                             || l_api_name;
      l_req_header_id                  NUMBER;
      l_offer_id                  NUMBER := p_offer_id;
       l_media_id                NUMBER;
      l_fund_id                   NUMBER;
      l_act_budget_id             NUMBER;
      l_act_budgets_rec           ozf_actbudgets_pvt.act_budgets_rec_type;
      l_act_util_rec              ozf_actbudgets_pvt.act_util_rec_type ;
      l_amount                    NUMBER                                  := 0;
      l_converted_amt             NUMBER;
      l_level_type_code         VARCHAR2 (30);
      l_currency_code             VARCHAR2 (30);
      l_total_committed_amt       NUMBER;
      l_utilized_amt              NUMBER;
      l_cust_acct_id      NUMBER;
      l_req_owner              NUMBER;
      l_org_id                    NUMBER;
      l_offer_org_id                    NUMBER;
      --get request date and currency.
      CURSOR c_request_date(p_offer_id IN NUMBER) IS
        SELECT req.request_header_id, req.currency_code,off.qualifier_id, req.submitted_by,off.org_id --approved_by
        FROM ozf_request_headers_all_b req, ozf_offers off
        WHERE req.offer_id =p_offer_id
        AND req.offer_id = off.qp_list_header_id;

      --get expense information.
      CURSOR c_req_expense (p_request_header_id IN NUMBER) IS
         select item_id, NVL(approved_amount,0),item_type from ozf_request_lines_all
         where request_header_id =p_request_header_id;

      --kdass 08-Jun-2005 Bug 4415878 SQL Repository Fix - changed the cursor query
      -- get committed budget information.
      CURSOR c_req_budgets (p_offer_id IN NUMBER) IS
         SELECT NVL(plan_curr_committed_amt,0) approved_amount
                ,fund_id
                ,fund_currency currency_code
         FROM ozf_object_fund_summary
         WHERE object_id =p_offer_id
         AND object_type = 'OFFR';

         /*
         SELECT SUM (approved_amount) approved_amount, fund_id, currency_code
         FROM (
               SELECT NVL(plan_curr_amount,0) approved_amount, fund_id, currency_code
               FROM ozf_funds_utilized_all_b
               WHERE utilization_type = 'REQUEST'
               AND component_type = 'OFFR'
               AND component_id = p_offer_id
               UNION ALL
               SELECT NVL(-plan_curr_amount,0) approved_amount, fund_id, currency_code
               FROM ozf_funds_utilized_all_b
               WHERE utilization_type = 'TRANSFER'
               AND plan_type = 'OFFR'
               AND plan_id = p_offer_id
              ) GROUP BY fund_id, currency_code;


      CURSOR c_req_budgets (p_offer_id IN NUMBER) IS
         SELECT SUM(NVL(DECODE(utilization_type, 'REQUEST',util.plan_curr_amount,-util.plan_curr_amount),0)) approved_amount,
            util.fund_id,util.currency_code
         FROM ozf_funds_utilized_all_b util
         WHERE util.utilization_type IN ('REQUEST','TRANSFER')
         AND DECODE(util.utilization_type,'REQUEST', util.component_type,util.plan_type) = 'OFFR'
         AND DECODE(util.utilization_type,'REQUEST', util.component_id,util.plan_id) = p_offer_id
         GROUP BY util.fund_id,util.currency_code;
      */

      --kdass 08-Jun-2005 Bug 4415878 SQL Repository Fix - changed the cursor query
      -- get total committed and utilized amount
      CURSOR c_committed_budgets(p_offer_id IN NUMBER) IS
        SELECT SUM(NVL(plan_curr_committed_amt,0))
        FROM ozf_object_fund_summary
        WHERE object_id =p_offer_id
        AND object_type = 'OFFR';

/*
         SELECT SUM (approved_amount)
         FROM (SELECT NVL(plan_curr_amount,0) approved_amount
               FROM ozf_funds_utilized_all_b
               WHERE utilization_type = 'REQUEST'
                 AND component_type = 'OFFR'
                 AND component_id = p_offer_id
               UNION ALL
               SELECT NVL(-plan_curr_amount,0) approved_amount
               FROM ozf_funds_utilized_all_b
               WHERE utilization_type = 'TRANSFER'
                 AND plan_type = 'OFFR'
                 AND plan_id = p_offer_id);


      CURSOR c_committed_budgets(p_offer_id IN NUMBER) IS
        SELECT SUM(DECODE(utilization_type,'REQUEST',plan_curr_amount,'TRANSFER',-plan_curr_amount))
        FROM ozf_funds_utilized_all_b
        WHERE utilization_type IN ('REQUEST','TRANSFER')
        AND DECODE(utilization_type,'REQUEST', component_type,plan_type) = 'OFFR'
        AND DECODE(utilization_type,'REQUEST', component_id,plan_id) = p_offer_id;
      */

      -- Added for bug 7030415, get conversion type
      CURSOR c_get_conversion_type( p_org_id   IN   NUMBER) IS
         SELECT exchange_rate_type
         FROM   ozf_sys_parameters_all
         WHERE  org_id = p_org_id;

      l_exchange_rate_type VARCHAR2(30) := FND_API.G_MISS_CHAR;
      l_rate               NUMBER;

   BEGIN
      SAVEPOINT Posting_lumpsum_amount;
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name || ': start');
      END IF;
      x_return_status            := fnd_api.g_ret_sts_success;

      IF fnd_api.to_boolean (p_init_msg_list) THEN
         fnd_msg_pub.initialize;
      END IF;

      IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
         RAISE fnd_api.g_exc_unexpected_error;
      END IF;

      OPEN c_request_date(l_offer_id);
      FETCH c_request_date INTO l_req_header_id,l_currency_code,l_cust_acct_id,l_req_owner,l_offer_org_id;
      CLOSE c_request_date;

      -- get total committed amount.
      OPEN c_committed_budgets(l_offer_id);
      FETCH c_committed_budgets INTO l_total_committed_amt;
      CLOSE c_committed_budgets;


      OPEN c_req_expense (l_req_header_id);

      LOOP
        FETCH c_req_expense INTO l_media_id, l_amount, l_level_type_code;

        EXIT WHEN c_req_expense%NOTFOUND;
       IF l_amount  <> 0 THEN
        FOR l_req_budgets IN c_req_budgets (l_offer_id)
            LOOP
               -- change later if a error has to be raised or not.
             /*  IF c_req_budgets%NOTFOUND THEN
                  ozf_utility_pvt.error_message ('OZF_ACT_BUDG_UTIL_OVER');
                END IF;
              */
               EXIT WHEN c_req_budgets%NOTFOUND;
                l_utilized_amt := ozf_utility_pvt.currround((l_req_budgets.approved_amount / l_total_committed_amt) * l_amount ,l_currency_code);
               --l_utilized_amt := ROUND((l_req_budgets.approved_amount / l_total_committed_amt) * l_amount,2);

           IF G_DEBUG THEN
              ozf_utility_pvt.debug_message (  ': lumpsum posting amount ' || l_utilized_amt);
           END IF;

               -- convert the object currency amount in to fund currency
               IF l_req_budgets.currency_code = l_currency_code THEN
                  l_converted_amt            := l_utilized_amt;
               ELSE
                  -- call the currency conversion wrapper
                  --Added for bug 7030415

                  OPEN c_get_conversion_type(l_offer_org_id);
                  FETCH c_get_conversion_type INTO l_exchange_rate_type;
                  CLOSE c_get_conversion_type;

                  ozf_utility_pvt.convert_currency (
                     x_return_status=> x_return_status
                    ,p_from_currency=> l_currency_code
                    ,p_to_currency=> l_req_budgets.currency_code
                    ,p_conv_type=> l_exchange_rate_type
                    ,p_from_amount=> l_utilized_amt
                    ,x_to_amount=> l_converted_amt
                    ,x_rate=> l_rate
                  );

                  IF x_return_status <> fnd_api.g_ret_sts_success THEN
                     x_return_status            := fnd_api.g_ret_sts_error;
                     RAISE fnd_api.g_exc_error;
                  END IF;
               END IF;
           IF G_DEBUG THEN
              ozf_utility_pvt.debug_message (  ': l_converted_amt ' || l_converted_amt);
           END IF;

               IF l_converted_amt <> 0 THEN
                  l_act_budgets_rec.request_amount := l_utilized_amt; --in object currency.
                  l_act_budgets_rec.act_budget_used_by_id := l_offer_id;
                  l_act_budgets_rec.arc_act_budget_used_by := 'OFFR';
                  l_act_budgets_rec.budget_source_type := 'OFFR';
                  l_act_budgets_rec.budget_source_id := l_offer_id;
                  l_act_budgets_rec.request_currency := l_currency_code;
                  l_act_budgets_rec.request_date := SYSDATE;
                  l_act_budgets_rec.status_code := 'APPROVED';
                  l_act_budgets_rec.user_status_id := ozf_utility_pvt.get_default_user_status (
                                                              'OZF_BUDGETSOURCE_STATUS'
                                                              ,l_act_budgets_rec.status_code
                                                              );
                  l_act_budgets_rec.transfer_type := 'UTILIZED';
                  l_act_budgets_rec.approval_date := SYSDATE;
                  l_act_budgets_rec.requester_id := l_req_owner;
                  l_act_budgets_rec.approver_id := ozf_utility_pvt.get_resource_id (fnd_global.user_id);
              -- when workflow goes through without approval, fnd_global.user_id is not passed.
                  IF l_act_budgets_rec.approver_id = -1 THEN
                     l_act_budgets_rec.approver_id := l_req_owner;
                  END IF;
                  l_act_budgets_rec.justification :=
                                             fnd_message.get_string ('OZF', 'OZF_SF_BUDGET_LUMPSUM_UTIL');
                  l_act_budgets_rec.parent_source_id := l_req_budgets.fund_id;
                  l_act_budgets_rec.parent_src_curr := l_req_budgets.currency_code;
                  l_act_budgets_rec.parent_src_apprvd_amt := l_converted_amt; -- in budget currency.
                  l_act_util_rec.product_id := l_media_id ;
                  l_act_util_rec.product_level_type := l_level_type_code;
                  l_act_util_rec.gl_date := sysdate;
                --  l_act_util_rec.billto_cust_account_id := l_cust_acct_id;
                  l_act_util_rec.reference_id := l_req_header_id;
                  l_act_util_rec.reference_type := 'SOFT_FUND';

                  --nirprasa,12.1.1
                  l_act_util_rec.plan_currency_code := l_currency_code;
                  l_act_util_rec.fund_request_currency_code := l_currency_code;
                  --nirprasa,12.1.1
                  l_org_id := find_org_id (l_act_budgets_rec.parent_source_id);
                  -- set org_context since workflow mailer does not set the context
                  set_org_ctx (l_org_id);
            IF G_DEBUG THEN
              ozf_utility_pvt.debug_message (  ': l_req_owner ' || l_act_budgets_rec.approver_id);
           END IF;
                process_act_budgets (x_return_status  => l_return_status,
                                       x_msg_count => x_msg_count,
                                       x_msg_data   => x_msg_data,
                                       p_act_budgets_rec => l_act_budgets_rec,
                                       p_act_util_rec   =>l_act_util_rec,
                                       x_act_budget_id  => l_act_budget_id
                                       ) ;

                  IF l_return_status = fnd_api.g_ret_sts_error THEN
                     RAISE fnd_api.g_exc_error;
                  ELSIF l_return_status = fnd_api.g_ret_sts_unexp_error THEN
                     RAISE fnd_api.g_exc_unexpected_error;
                  END IF;
               END IF; -- for util amount

               IF G_DEBUG THEN
                  ozf_utility_pvt.debug_message (   l_full_name
                                              || ': end create act budgets  ');
               END IF;
               l_act_util_rec             := NULL;
               l_act_budgets_rec          := NULL;
            END LOOP;
           END IF; -- end of l_amount
        END LOOP ;

        CLOSE c_req_expense;


       fnd_msg_pub.count_and_get (
         p_encoded=> fnd_api.g_false
        ,p_count=> x_msg_count
        ,p_data=> x_msg_data
      );
      IF G_DEBUG THEN
         ozf_utility_pvt.debug_message (   l_full_name || ': end');
      END IF;
  EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         ROLLBACK TO Posting_lumpsum_amount;
         x_return_status            := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         ROLLBACK TO Posting_lumpsum_amount;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );
      WHEN OTHERS THEN
         ROLLBACK TO Posting_lumpsum_amount;
         x_return_status            := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count
           ,p_data=> x_msg_data
           ,p_encoded=> fnd_api.g_false
         );

     END post_sf_lumpsum_amount;



   ----------------------------------------------------------------------
   PROCEDURE update_request_status (
      x_return_status     OUT NOCOPY      VARCHAR2,
      x_msg_count         OUT NOCOPY      NUMBER,
      x_msg_data          OUT NOCOPY      VARCHAR2,
      p_offer_is           IN    NUMBER
   ) IS
      CURSOR c_req_header_rec(p_offer_id IN NUMBER) IS
         SELECT request_header_id,object_version_number,status_code
         FROM ozf_request_headers_all_b
         WHERE offer_id = p_offer_id;

      l_req_header_id           NUMBER;
      l_obj_ver_num             NUMBER;
      l_status_code             VARCHAR2 (30);
      l_return_status           VARCHAR2 (10)         := fnd_api.g_ret_sts_success;
      l_api_name                VARCHAR2 (60)         := 'update_request_status';
      l_full_name               VARCHAR2 (100)        := g_pkg_name||'.'||l_api_name;
      l_api_version             NUMBER                := 1;
   BEGIN

      IF G_DEBUG THEN
         ams_utility_pvt.debug_message(l_full_name||' : '||'begin');
      END IF;

      OPEN c_req_header_rec (p_offer_is);
      FETCH c_req_header_rec INTO l_req_header_id,
                                l_obj_ver_num,
                                l_status_code;
      CLOSE c_req_header_rec;

      IF l_status_code <> 'APPROVED' THEN
         UPDATE ozf_request_headers_all_b
         SET status_code ='APPROVED',
             object_version_number = l_obj_ver_num + 1
         WHERE request_header_id = l_req_header_id;
      END IF;

      fnd_msg_pub.count_and_get (
            p_count=> x_msg_count,
            p_data=> x_msg_data,
            p_encoded=> fnd_api.g_false
         );

   EXCEPTION
      WHEN fnd_api.g_exc_error THEN
         x_return_status := fnd_api.g_ret_sts_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count,
            p_data=> x_msg_data,
            p_encoded=> fnd_api.g_false
         );
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;
         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count,
            p_data=> x_msg_data,
            p_encoded=> fnd_api.g_false
         );
      WHEN OTHERS THEN
         x_return_status := fnd_api.g_ret_sts_unexp_error;

         IF fnd_msg_pub.check_msg_level (fnd_msg_pub.g_msg_lvl_unexp_error) THEN
            fnd_msg_pub.add_exc_msg (g_pkg_name, l_api_name);
         END IF;

         fnd_msg_pub.count_and_get (
            p_count=> x_msg_count,
            p_data=> x_msg_data,
            p_encoded=> fnd_api.g_false
         );
   END update_request_status;

END ozf_fund_adjustment_pvt;

/
