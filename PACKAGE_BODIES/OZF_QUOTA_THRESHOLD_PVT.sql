--------------------------------------------------------
--  DDL for Package Body OZF_QUOTA_THRESHOLD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_QUOTA_THRESHOLD_PVT" AS
/* $Header: ozfvqtrb.pls 120.1 2006/05/11 03:43:03 inanaiah noship $*/

-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_QUOTA_THRESHOLD_PVT
-- Purpose
--
-- History
--  Created By   - Padmavathi Karthikeyan
--  Modified by kvattiku July 15, 04 Took care of the binding variable issue
--              inanaiah May 11, 06 Bug 5185832 fix - closed c_quota loop after
--                                    l_operation_result IF stmt

-- NOTE
--        Will prcess the quota thresholds and creates
--        notification information in ams_act_logs
--        table. Will make a call to notification
--        package.  Will insert alert types for dashboard use.
-- End of Comments
-- ===============================================================

G_PKG_NAME  CONSTANT  VARCHAR2(30) :='OZF_QUOTA_THRESHOLD_PVT';
G_FILE_NAME CONSTANT  VARCHAR2(20) :='ozfvqtrb.pls';
G_DEBUG BOOLEAN := FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
--G_DEBUG BOOLEAN := TRUE;
TYPE NUMBER_TBL_TYPE IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

   -----------------------------------------------------------------------
   -- PROCEDURE
   --    start_process
   --
   -- Sends notification to budget owner by calling the procedure
   -- ozf_utility_pvt.send_wf_standalone_message

   -----------------------------------------------------------------------
PROCEDURE start_process(
      p_api_version_number   IN       NUMBER
     ,x_msg_count            OUT NOCOPY      NUMBER
     ,x_msg_data             OUT NOCOPY      VARCHAR2
     ,x_return_status         OUT NOCOPY     VARCHAR2
     ,p_owner_id             IN       NUMBER
     ,p_parent_owner_id      IN       NUMBER
     ,p_message_text         IN       VARCHAR2
     ,p_activity_log_id      IN       NUMBER
)
   IS
       l_api_name              CONSTANT VARCHAR2(30)   := 'Start_Process';
       l_return_status                  VARCHAR2(1);
      l_strSubject                     VARCHAR2(30);
      l_strChildSubject                VARCHAR2(30);
      l_notification_id                NUMBER;
      l_strBody               VARCHAR2(2000);

   BEGIN
      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message('Entering ams_threshold_notify.Start_process : ');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      fnd_message.set_name('OZF', 'OZF_THRESHOLD_SUBJECT');
      l_strSubject := fnd_message.get;
      fnd_message.set_name('OZF', 'OZF_THRESHOLD_CHILDSUBJ');
      l_strChildSubject := fnd_message.get;

     -- fnd_message.set_name('OZF', 'OZF_NOTIFY_HEADERLINE');
      --l_strBody := fnd_message.get ||fnd_global.local_chr(10)||fnd_global.local_chr(10)||p_message_text;
      l_strBody := p_message_text;
      fnd_message.set_name('OZF', 'OZF_NOTIFY_FOOTER');
      l_strBody := l_strBody || fnd_global.local_chr(10) || fnd_global.local_chr(10) ||fnd_message.get ;

      ozf_utility_pvt.send_wf_standalone_message(
                          p_subject => l_strSubject
                          ,p_body  => l_strBody
                          ,p_send_to_res_id  => p_owner_id
                          ,x_notif_id  => l_notification_id
                          ,x_return_status  => l_return_status
                         );

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;


      IF p_parent_owner_id <>0 THEN
         ozf_utility_pvt.send_wf_standalone_message(
                          p_subject => l_strChildSubject
                          ,p_body  => l_strBody
                          ,p_send_to_res_id  => p_parent_owner_id
                          ,x_notif_id  => l_notification_id
                          ,x_return_status  => l_return_status
                         );
      END IF;

      IF l_return_status <> fnd_api.g_ret_sts_success THEN
         RAISE fnd_api.g_exc_error;
      END IF;

   EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
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
   END start_process; /*  START_PROCESS */

   -----------------------------------------------------------------------
   -- PROCEDURE
   --    validate_quota_threshold
   --
   -- This is the main procedure called while executing concurrent program.
   -- For all enabled quota threshold rules, it will check for violation
   -- and sent notification accordingly.
   -- It also set alert flages for dashboard use.

   -----------------------------------------------------------------------
PROCEDURE validate_quota_threshold
(
     x_errbuf        OUT NOCOPY      VARCHAR2,
     x_retcode       OUT NOCOPY      NUMBER
  )
IS
l_api_name                CONSTANT VARCHAR2(30) := 'validate_quota_threshold';
l_api_version_number      CONSTANT NUMBER       := 1.0;
l_full_name               CONSTANT VARCHAR2(60) := G_PKG_NAME ||'.'|| l_api_name;
l_count                      NUMBER := 0;
l_value_limit             NUMBER := 0;
l_base_line_amt              NUMBER := 0;
l_value_limit_type          VARCHAR2(15);
l_operation_result          VARCHAR2(25);
l_operation_result_notify          VARCHAR2(25);
l_notification_result      VARCHAR2(25);
l_return_status           VARCHAR2(2);
l_operator_meaning        VARCHAR2(25);
l_budget_name             VARCHAR2(240);
l_parent_fund_id          NUMBER;
l_trans_id                NUMBER;
l_log_id                  NUMBER;
l_owner_id                NUMBER;
l_parent_owner_id         NUMBER;
l_message                 VARCHAR2(5000);
l_period_meaning          VARCHAR2(25);
l_msg_data               VARCHAR2 (5000);
l_msg_count              NUMBER;
l_valuelimit_name        VARCHAR2(60);
l_baseline_name        VARCHAR2(60);
l_today_date           VARCHAR2(20);
l_quota                NUMBER;
l_resource_list        NUMBER_TBL_TYPE;

-- This cursor gets the threshold rules which are in active status

CURSOR c_threshold_rules_cur IS
SELECT r.threshold_rule_id,
       r.threshold_id
FROM   ozf_threshold_rules_all r, ozf_thresholds_all_b t
WHERE  r.threshold_id = t.threshold_id
AND t.threshold_type = 'QUOTA'
AND r.enabled_flag = 'Y'
AND r.start_date <= SYSDATE
AND r.end_date >= SYSDATE ;


--This cursor will get all the enabled budgets which are tied with the Thresholds
CURSOR c_threshold_funds(p_threshold_rule_id NUMBER)
IS
SELECT a.fund_id budget_id,
       a.parent_fund_id parent_budget_id,
       a.owner owner,
       c.value_limit value_limit,
       c.operator_code operator_code,
       c.start_date rule_start_date,
       c.end_date rule_end_date,
       c.threshold_id threshold_id,
       c.threshold_rule_id threshold_rule_id,
       c.percent_amount percent_amt,
       c.base_line base_line,
       c.frequency_period frequency_period,
       c.repeat_frequency repeat_frequency,
       c.comparison_type,
       c.alert_type
FROM   ozf_funds_all_b a,
       ozf_thresholds_all_b b,
       ozf_threshold_rules_all c
WHERE  a.threshold_id = b.threshold_id
AND    a.status_code = 'ACTIVE'
AND    b.enable_flag = 'Y'
AND    b.threshold_id = c.threshold_id
AND    c.threshold_rule_id = p_threshold_rule_id
AND    c.end_date >= SYSDATE;

--This cursor is to get all the resources for the enabled quota thresholds
CURSOR  c_all_resources
IS
SELECT  DISTINCT  a.owner owner
FROM   ozf_funds_all_b a,
       ozf_thresholds_all_b b,
       ozf_threshold_rules_all c
WHERE  a.threshold_id = b.threshold_id
AND    a.status_code = 'ACTIVE'
AND    b.enable_flag = 'Y'
AND    b.threshold_id = c.threshold_id
AND    b.threshold_type = 'QUOTA'
AND    c.enabled_flag = 'Y'
AND    c.start_date <= SYSDATE
AND    c.end_date >= SYSDATE;

--This cursor will get all product related infromation for the given budget
CURSOR c_product_facts (p_budget_id NUMBER)
IS
SELECT
       p.item_id item_id,
       p.item_type item_type,
       sum(c.ptd_sales) mtd_sales,
       sum(c.qtd_sales) qtd_sales,
       sum(c.ytd_sales) ytd_sales,
       sum(c.lysp_sales) lysp_sales,
       sum(c.past_due_order_qty) outst_order,
       sum(c.current_period_order_qty) current_order,
       sum(c.backordered_qty) back_order,
       sum(c.booked_for_future_qty) future_order,
       sum(c.current_year_target) yearly_quota,
       sum(c.current_period_target) monthly_quota,
       sum(c.current_qtr_target) quarterly_quota,
       sum(c.lysq_sales) lysq_sales,
       sum(c.ly_sales) ly_sales
FROM   ozf_product_allocations p, ozf_cust_daily_facts c
WHERE
       p.item_type <> 'OTHERS' and
       p.fund_id = p_budget_id and
       p.item_id = c.product_attr_value and
       p.item_type = c.product_attribute and
       c.report_date = trunc(SYSDATE)
group by p.item_id, p.item_type;


--This cursor will get all customer related infromation for the given budget
CURSOR c_customer_facts (p_budget_id NUMBER)
IS
SELECT
       c.cust_account_id cust_account_id,
       c.ship_to_site_use_id ship_to_site_use_id,
       sum(c.ptd_sales) mtd_sales,
       sum(c.qtd_sales) qtd_sales,
       sum(c.ytd_sales) ytd_sales,
       sum(c.lysp_sales) lysp_sales,
       sum(c.past_due_order_qty) outst_order,
       sum(c.current_period_order_qty) current_order,
       sum(c.backordered_qty) back_order,
       sum(c.booked_for_future_qty) future_order,
       sum(c.current_year_target) yearly_quota,
       sum(c.current_period_target) monthly_quota,
       sum(c.current_qtr_target) quarterly_quota,
       sum(c.lysq_sales) lysq_sales,
       sum(c.ly_sales) ly_sales
FROM   ozf_account_allocations a, ozf_cust_daily_facts c
WHERE
      a.allocation_for = 'FUND' and
      a.allocation_for_id = p_budget_id and
      a.site_use_code = 'SHIP_TO' and
      a.cust_account_id = c.cust_account_id and
      a.site_use_id = c.ship_to_site_use_id and
      c.report_date = trunc(SYSDATE)
group by c.cust_account_id, c.ship_to_site_use_id;

--This cursor will get quota related information for the given resource id
CURSOR c_quota (p_resource_id NUMBER)
IS
SELECT resource_id, sequence_number, kpi_name, kpi_value
FROM ozf_dashb_daily_kpi
WHERE resource_id = p_resource_id
AND report_date = trunc(SYSDATE)
ORDER BY sequence_number;

CURSOR c_log_seq IS
SELECT ams_act_logs_s.NEXTVAL
FROM DUAL;

CURSOR c_trans_seq IS
SELECT ams_act_logs_transaction_id_s.NEXTVAL
FROM DUAL;


CURSOR c_log_message (p_trans_id NUMBER)
IS
SELECT budget_id, log_message_text
FROM ams_act_logs
WHERE log_transaction_id = p_trans_id;

CURSOR c_owner(p_budget_id NUMBER)
IS
SELECT owner,parent_fund_id
FROM ozf_Funds_All_b
WHERE fund_id = p_budget_id;

CURSOR c_parent_owner(p_budget_id NUMBER)
IS
SELECT owner
FROM ozf_Funds_All_b
WHERE fund_id = p_budget_id;

CURSOR c_budget_name(p_budget_id NUMBER)
IS
SELECT short_name
FROM ozf_fund_details_v
WHERE fund_id = p_budget_id;

CURSOR c_valuelimit_name(p_lkup_code VARCHAR2)
IS
SELECT meaning
FROM ozf_lookups
WHERE lookup_type = 'OZF_QUOTA_VALUE_LIMIT'
AND lookup_code = p_lkup_code;

CURSOR c_baseline_name(p_lkup_code VARCHAR2)
IS
SELECT meaning
FROM ozf_lookups
WHERE lookup_type = 'OZF_QUOTA_BASE_LINE'
AND lookup_code = p_lkup_code;

TYPE owner_record_type IS RECORD
 (owner NUMBER,
  parent_owner NUMBER,
  message_text VARCHAR2(5000),
  remove_flag  VARCHAR2(1));

l_owner_record       owner_record_type;

TYPE owner_table_type IS TABLE OF owner_record_type
     INDEX BY BINARY_INTEGER;
l_owner_table        owner_table_type;
l_notify_table       owner_table_type;
l_alert_str          VARCHAR2(100);
l_alert_no           SMALLINT;
l_quota_lysp_sales   NUMBER;
l_quota_lysq_sales   NUMBER;
l_quota_ly_sales   NUMBER;


BEGIN

      -- Standard Start of API savepoint
      --SAVEPOINT validate_quota_threshold;

      -- Debug Message
      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message('Private QUOTA API: ' || l_api_name || ' start');
      END IF;
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Inside quota api ....... ' );
      OPEN c_trans_seq;
      FETCH c_trans_seq INTO l_trans_id;
      CLOSE c_trans_seq;
      -- Initialize API return status to SUCCESS
      -- x_return_status := FND_API.G_RET_STS_SUCCESS;

      OPEN c_all_resources;
      FETCH c_all_resources BULK COLLECT INTO l_resource_list;
      CLOSE c_all_resources;

      IF l_resource_list.FIRST IS NOT NULL AND l_resource_list.LAST IS NOT NULL THEN

          FORALL i in l_resource_list.FIRST .. l_resource_list.LAST
           UPDATE OZF_QUOTA_ALERTS SET mtd_alert = NULL, qtd_alert = NULL,
           ytd_alert = NULL, back_order_alert = NULL, outstand_order_alert = NULL
           WHERE report_date = trunc(sysdate) and resource_id  = l_resource_list(i);

          FORALL i in l_resource_list.FIRST .. l_resource_list.LAST
           UPDATE OZF_DASHB_DAILY_KPI SET alert_type = NULL
           WHERE report_date = trunc(sysdate) and resource_id  = l_resource_list(i);
      END IF;

      FOR rule IN c_threshold_rules_cur
      LOOP
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Inside rules loop rule id : ' ||  rule.threshold_rule_id);
          FOR budget IN c_threshold_funds(rule.threshold_rule_id)
          LOOP
          FND_FILE.PUT_LINE(FND_FILE.LOG,'Inside budget loop budget id :' ||  budget.budget_id);
                   l_operation_result_notify := '';
                   l_operator_meaning := '';
                   l_notification_result := '';
                   l_alert_no := 0;

                   l_quota_lysp_sales := 0;
                   l_quota_lysq_sales := 0;
                   l_quota_ly_sales   := 0;

                   FOR product IN c_product_facts(budget.budget_id)
                   LOOP
                       FND_FILE.PUT_LINE(FND_FILE.LOG,'Inside Product loop :: Product :' || product.item_id );
                       l_operation_result := '';
                       l_alert_str := '';
                       IF budget.comparison_type = 'PERCENT' then
                           IF budget.base_line = 'MONTHLY_QUOTA' THEN
                              l_base_line_amt := (product.monthly_quota * budget.percent_amt / 100);
                           ELSIF budget.base_line = 'QUARTERLY_QUOTA' THEN
                              l_base_line_amt := (product.quarterly_quota* budget.percent_amt / 100);
                           ELSIF budget.base_line = 'YEARLY_QUOTA' THEN
                              l_base_line_amt := (product.yearly_quota* budget.percent_amt / 100);
                           END IF;
                       ELSE
                           l_base_line_amt := budget.percent_amt;
                       END IF;

                       IF budget.value_limit = 'MTD' THEN
                          l_value_limit := product.mtd_sales;
                          l_alert_str := 'mtd_alert';
                          IF budget.comparison_type = 'PERCENT' then
                              IF budget.base_line = 'LYSP_SALES' THEN
                                  l_base_line_amt := (product.lysp_sales* budget.percent_amt / 100);
                              END IF;
                          END IF;
                       ELSIF budget.value_limit = 'QTD' THEN
                          l_value_limit := product.qtd_sales;
                          l_alert_str := 'qtd_alert';
                          IF budget.comparison_type = 'PERCENT' then
                              IF budget.base_line = 'LYSP_SALES' THEN
                                  l_base_line_amt := (product.lysq_sales* budget.percent_amt / 100);
                              END IF;
                          END IF;
                       ELSIF budget.value_limit = 'YTD' THEN
                          l_value_limit := product.ytd_sales;
                          l_alert_str := 'ytd_alert';
                          IF budget.comparison_type = 'PERCENT' then
                              IF budget.base_line = 'LYSP_SALES' THEN
                                  l_base_line_amt := (product.ly_sales* budget.percent_amt / 100);
                              END IF;
                          END IF;
                       /*ELSIF budget.value_limit = 'CURRENT_ORDERS' THEN
                          l_value_limit := product.current_order;
                          l_alert_str := 'current_order_alert';
                       ELSIF budget.value_limit = 'FUTURE_ORDERS' THEN
                          l_value_limit := product.future_order;
                          l_alert_str := 'future_order_alertt'; */
                       ELSIF budget.value_limit = 'BACK_ORDERS' THEN
                          l_value_limit := product.back_order;
                          l_alert_str := 'back_order_alert';
                       ELSIF budget.value_limit = 'OUTSTANDING_ORDERS' THEN
                          l_value_limit := product.outst_order;
                          l_alert_str := 'outstand_order_alert';
                       /*ELSIF budget.value_limit = 'TOTAL_SHIPMENTS' THEN
                          l_value_limit := product.mtd_sales + product.outst_order + product.back_order + product.current_order;
                          l_alert_str := 'total_ship_alert'; */
                       END IF;

                        FND_FILE.PUT_LINE(FND_FILE.LOG,'Inside Product loop - l_value_limit :' || l_value_limit );
                        FND_FILE.PUT_LINE(FND_FILE.LOG,'Inside Product loop - l_base_line_amt :' || l_base_line_amt );
                     --l_base_line_amt is rhs for operation_result imput.
                       operation_result(l_api_version_number,
                                        FND_API.G_FALSE,
                                        l_Msg_Count,
                                        l_Msg_Data,
                                        l_return_status,
                                        l_value_limit,
                                        l_base_line_amt,
                                        budget.operator_code,
                                        l_operation_result);
                        IF G_DEBUG THEN
                           OZF_UTILITY_PVT.debug_message('l_operation_result: ' || l_operation_result);
                        END IF;
                        FND_FILE.PUT_LINE(FND_FILE.LOG,'l_operation_result :' || l_operation_result );

                       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                          RAISE FND_API.G_EXC_ERROR;
                       END IF;

                       IF l_operation_result = 'VIOLATED' THEN
                          update_alerts(l_api_version_number,
                                        FND_API.G_FALSE,
                                        l_Msg_Count,
                                        l_Msg_Data,
                                        l_return_status,
                                        budget.owner,
                                        'PROD',
                                        product.item_type,
                                        product.item_id,
                                        budget.alert_type,
                                        l_alert_str,
                                        0);
                           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                              RAISE FND_API.G_EXC_ERROR;
                           END IF;
                       END IF;

                   END LOOP;

                   l_quota_lysp_sales := 0;
                   l_quota_lysq_sales := 0;
                   l_quota_ly_sales   := 0;
                   FOR customer IN c_customer_facts(budget.budget_id)
                   LOOP
                       l_quota_lysp_sales := l_quota_lysp_sales + customer.lysp_sales;
                       l_quota_lysq_sales := l_quota_lysq_sales + customer.lysq_sales;
                       l_quota_ly_sales   := l_quota_ly_sales + customer.ly_sales;
                        FND_FILE.PUT_LINE(FND_FILE.LOG,'Inside customer loop :: Customer :' || customer.cust_account_id );
                       l_operation_result := '';
                       l_alert_str := '';
                       IF budget.comparison_type = 'PERCENT' then
                           IF budget.base_line = 'MONTHLY_QUOTA' THEN
                              l_base_line_amt := (customer.monthly_quota * budget.percent_amt / 100);
                           ELSIF budget.base_line = 'QUARTERLY_QUOTA' THEN
                              l_base_line_amt := (customer.quarterly_quota* budget.percent_amt / 100);
                           ELSIF budget.base_line = 'YEARLY_QUOTA' THEN
                              l_base_line_amt := (customer.yearly_quota* budget.percent_amt / 100);
                           END IF;
                       ELSE
                           l_base_line_amt := budget.percent_amt;
                       END IF;

                       IF budget.value_limit = 'MTD' THEN
                          l_value_limit := customer.mtd_sales;
                          l_alert_str := 'mtd_alert';
                          IF budget.comparison_type = 'PERCENT' then
                              IF budget.base_line = 'LYSP_SALES' THEN
                                  l_base_line_amt := (customer.lysp_sales* budget.percent_amt / 100);
                              END IF;
                          END IF;
                       ELSIF budget.value_limit = 'QTD' THEN
                          l_value_limit := customer.qtd_sales;
                          l_alert_str := 'qtd_alert';
                          IF budget.comparison_type = 'PERCENT' then
                              IF budget.base_line = 'LYSP_SALES' THEN
                                  l_base_line_amt := (customer.lysq_sales* budget.percent_amt / 100);
                              END IF;
                          END IF;
                       ELSIF budget.value_limit = 'YTD' THEN
                          l_value_limit := customer.ytd_sales;
                          l_alert_str := 'ytd_alert';
                          IF budget.comparison_type = 'PERCENT' then
                              IF budget.base_line = 'LYSP_SALES' THEN
                                  l_base_line_amt := (customer.ly_sales* budget.percent_amt / 100);
                              END IF;
                          END IF;
                       /*ELSIF budget.value_limit = 'CURRENT_ORDERS' THEN
                          l_value_limit := customer.current_order;
                          l_alert_str := 'current_order_alert';
                       ELSIF budget.value_limit = 'FUTURE_ORDERS' THEN
                          l_value_limit := customer.future_order;
                          l_alert_str := 'future_order_alert';  */
                       ELSIF budget.value_limit = 'BACK_ORDERS' THEN
                          l_value_limit := customer.back_order;
                          l_alert_str := 'back_order_alert';
                       ELSIF budget.value_limit = 'OUTSTANDING_ORDERS' THEN
                          l_value_limit := customer.outst_order;
                          l_alert_str := 'outstand_order_alert';
                       /*ELSIF budget.value_limit = 'TOTAL_SHIPMENTS' THEN
                          l_value_limit := customer.mtd_sales + customer.outst_order + customer.back_order + customer.current_order;
                          l_alert_str := 'total_ship_alert';       */
                       END IF;
                        FND_FILE.PUT_LINE(FND_FILE.LOG,'Customer - l_value_limit :' || l_value_limit );
                        FND_FILE.PUT_LINE(FND_FILE.LOG,'Customer - l_base_line_amt :' || l_base_line_amt );

                     --l_base_line_amt is rhs for operation_result imput.
                       operation_result(l_api_version_number,
                                        FND_API.G_FALSE,
                                        l_Msg_Count,
                                        l_Msg_Data,
                                        l_return_status,
                                        l_value_limit,
                                        l_base_line_amt,
                                        budget.operator_code,
                                        l_operation_result);
                        IF G_DEBUG THEN
                           OZF_UTILITY_PVT.debug_message('Operator: ' || l_operation_result);
                        END IF;
                        FND_FILE.PUT_LINE(FND_FILE.LOG,'l_operation_result :' || l_operation_result );

                       IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                          RAISE FND_API.G_EXC_ERROR;
                       END IF;

                       IF l_operation_result = 'VIOLATED' THEN
                          update_alerts(l_api_version_number,
                                        FND_API.G_FALSE,
                                        l_Msg_Count,
                                        l_Msg_Data,
                                        l_return_status,
                                        budget.owner,
                                        'CUST',
                                        NULL,
                                        customer.ship_to_site_use_id,
                                        budget.alert_type,
                                        l_alert_str,
                                        customer.cust_account_id);
                           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                              RAISE FND_API.G_EXC_ERROR;
                           END IF;
                       END IF;

                   END LOOP;
                   FND_FILE.PUT_LINE(FND_FILE.LOG,' l_quota_lysp_sales :' || l_quota_lysp_sales );
                   FND_FILE.PUT_LINE(FND_FILE.LOG,' l_quota_lysq_sales :' || l_quota_lysq_sales );
                   FND_FILE.PUT_LINE(FND_FILE.LOG,' l_quota_ly_sales :' || l_quota_ly_sales );

                   IF budget.value_limit = 'MTD' OR budget.value_limit = 'QTD'
                      OR budget.value_limit = 'YTD' THEN
                      l_quota := 0;
                       FOR quota IN c_quota(budget.owner)
                       LOOP
                        FND_FILE.PUT_LINE(FND_FILE.LOG,'Inside quota loop ' );
                            l_operation_result := '';
                           IF budget.comparison_type = 'PERCENT' then
                               IF budget.base_line = 'MONTHLY_QUOTA' THEN
                                  IF quota.sequence_number = 1 THEN
                                     l_quota := quota.kpi_value;
                                     l_base_line_amt := (l_quota * budget.percent_amt) / 100;
                                  END IF;
                                  /*IF quota.sequence_number = 2 THEN
                                     --l_base_line_amt := (quota.kpi_value * 100 / l_quota)*(budget.percent_amt/100);
                                     l_base_line_amt := (quota.kpi_value / l_quota)*budget.percent_amt;
                                  END IF;*/
                               ELSIF budget.base_line = 'QUARTERLY_QUOTA' THEN
                                  IF quota.sequence_number = 4 THEN
                                     l_quota := quota.kpi_value;
                                     l_base_line_amt := (l_quota * budget.percent_amt) / 100;
                                  END IF;
                                  /*IF quota.sequence_number = 5 THEN
                                     l_base_line_amt := (quota.kpi_value / l_quota)*budget.percent_amt;
                                  END IF;*/
                               ELSIF budget.base_line = 'YEARLY_QUOTA' THEN
                                  IF quota.sequence_number = 7 THEN
                                     l_quota := quota.kpi_value;
                                     l_base_line_amt := (l_quota * budget.percent_amt) / 100;
                                  END IF;
                                  /*IF quota.sequence_number = 8 THEN
                                     l_base_line_amt := (quota.kpi_value / l_quota)*budget.percent_amt;
                                  END IF;*/
                               END IF;
                           ELSE
                               l_base_line_amt := budget.percent_amt;
                           END IF;

                           IF budget.value_limit = 'MTD' THEN
                              l_alert_no := 3;
                              IF quota.sequence_number = 2 THEN
                                 l_value_limit := quota.kpi_value;
                              END IF;
                              IF budget.comparison_type = 'PERCENT' then
                                  IF budget.base_line = 'LYSP_SALES' THEN
                                      l_base_line_amt := (l_quota_lysp_sales* budget.percent_amt / 100);
                                  END IF;
                              END IF;
                           ELSIF budget.value_limit = 'QTD' THEN
                              l_alert_no := 6;
                              IF quota.sequence_number = 5 THEN
                                 l_value_limit := quota.kpi_value;
                              END IF;

                              IF budget.comparison_type = 'PERCENT' then
                                  IF budget.base_line = 'LYSP_SALES' THEN
                                      l_base_line_amt := (l_quota_lysq_sales* budget.percent_amt / 100);
                                  END IF;
                              END IF;

                           ELSIF budget.value_limit = 'YTD' THEN
                              l_alert_no := 9;
                              IF quota.sequence_number = 8 THEN
                                 l_value_limit := quota.kpi_value;
                              END IF;

                              IF budget.comparison_type = 'PERCENT' then
                                  IF budget.base_line = 'LYSP_SALES' THEN
                                      l_base_line_amt := (l_quota_ly_sales * budget.percent_amt / 100);
                                  END IF;
                              END IF;

                           END IF;


                        FND_FILE.PUT_LINE(FND_FILE.LOG,'Quota - l_value_limit :' || l_value_limit );
                        FND_FILE.PUT_LINE(FND_FILE.LOG,'Quota - l_base_line_amt :' || l_base_line_amt );

                         --l_base_line_amt is rhs for operation_result imput.
                           operation_result(l_api_version_number,
                                            FND_API.G_FALSE,
                                            l_Msg_Count,
                                            l_Msg_Data,
                                            l_return_status,
                                            l_value_limit,
                                            l_base_line_amt,
                                            budget.operator_code,
                                            l_operation_result);
                            IF G_DEBUG THEN
                               OZF_UTILITY_PVT.debug_message('Operator: ' || l_operation_result);
                            END IF;
                            FND_FILE.PUT_LINE(FND_FILE.LOG,'budget.operator_code :' || budget.operator_code );
                            FND_FILE.PUT_LINE(FND_FILE.LOG,'l_operation_result :' || l_operation_result );

                           IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                              RAISE FND_API.G_EXC_ERROR;
                           END IF;

                           IF l_operation_result = 'VIOLATED' THEN
                              update_alerts(l_api_version_number,
                                            FND_API.G_FALSE,
                                            l_Msg_Count,
                                            l_Msg_Data,
                                            l_return_status,
                                            budget.owner,
                                            'QUOTA',
                                            NULL,
                                            l_alert_no,
                                            budget.alert_type,
                                            NULL,
                                            0);
                               IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                                  RAISE FND_API.G_EXC_ERROR;
                               END IF;
                               l_operation_result_notify := 'VIOLATED';
                               OZF_UTILITY_PVT.debug_message(' budget.alert_type:' || budget.alert_type);
                               OZF_UTILITY_PVT.debug_message(' l_alert_no:' ||l_alert_no );
                               FND_FILE.PUT_LINE(FND_FILE.LOG,' budget.alert_type:' || budget.alert_type);
                               FND_FILE.PUT_LINE(FND_FILE.LOG,' l_alert_no:' ||l_alert_no );
                           END IF;
                        END LOOP;
                   END IF;

                 /* l_opeartion_result is deciding factor in calling verify_notification.
                  if l_opearation_result is 'VIOLATED' then we will call verify_notification
                  else if the l_opearation_result is 'NOT VIOLATED' then we will not call verify_notification*/
                  FND_FILE.PUT_LINE(FND_FILE.LOG,' l_operation_result_notify : ' || l_operation_result_notify);
                  IF l_operation_result_notify = 'VIOLATED' THEN
                     verify_notification( l_api_version_number,
                                        FND_API.G_FALSE,
                                        l_Msg_Count,
                                        l_Msg_Data,
                                        l_return_status,
                                        budget.budget_id,
                                        budget.threshold_id,
                                        budget.threshold_rule_id,
                                        budget.frequency_period,
                                        budget.repeat_frequency,
                                        budget.rule_start_date,
                                        l_notification_result);

                   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      RAISE FND_API.G_EXC_ERROR;
                   END IF;
                   FND_FILE.PUT_LINE(FND_FILE.LOG,' l_notification_result : ' || l_notification_result);
                    --l_notification_result will drive write_to_log
                  IF G_DEBUG THEN
                     OZF_UTILITY_PVT.debug_message('Notify result: ' || l_notification_result );
                  END IF;

                   --Get lookup meaning

                   l_period_meaning := ozf_utility_pvt.get_lookup_meaning('AMS_TRIGGER_FREQUENCY_TYPE'
                                                                         ,budget.frequency_period);

                   IF l_notification_result = 'NOTIFY' THEN

                    --Get operator meaning.
                    IF budget.operator_code = '0' THEN
                      fnd_message.set_name ('OZF', 'OZF_THRESHOLD_LESS');
                      l_operator_meaning := fnd_message.get;
                    ELSIF budget.operator_code = '1' THEN
                      fnd_message.set_name ('OZF', 'OZF_THRESHOLD_EQUAL');
                      l_operator_meaning := fnd_message.get;
                    ELSE
                      fnd_message.set_name ('OZF', 'OZF_THRESHOLD_LARGER');
                      l_operator_meaning := fnd_message.get;
                    END IF;

                    OPEN c_budget_name(budget.budget_id);
                    FETCH c_budget_name INTO l_budget_name;
                    CLOSE c_budget_name;

                    OPEN c_valuelimit_name(budget.value_limit);
                    FETCH c_valuelimit_name INTO l_valuelimit_name;
                    CLOSE c_valuelimit_name;

                    select to_char(sysdate, 'dd-Mon-yyyy' ) into l_today_date from dual;

                    IF budget.comparison_type = 'PERCENT' then
                        OPEN c_baseline_name(budget.base_line);
                        FETCH c_baseline_name INTO l_baseline_name;
                        CLOSE c_baseline_name;
                        fnd_message.set_name ('OZF', 'OZF_WF_NTF_QUOTA_THRESHOLD_FYI');
                        fnd_message.set_token ('BUDGET_NAME', l_budget_name, FALSE);
                        fnd_message.set_token ('VALUE_LIMIT', l_valuelimit_name, FALSE);
                        fnd_message.set_token ('OPERATOR', l_operator_meaning, FALSE);
                        fnd_message.set_token ('PERCENT_AMOUNT', budget.percent_amt, FALSE);
                        fnd_message.set_token ('BASE_LINE', l_baseline_name, FALSE);
                        fnd_message.set_token ('DATE', l_today_date, FALSE);
                        l_message := fnd_message.get;
                    ELSE
                        fnd_message.set_name ('OZF', 'OZF_WF_NTF_QUOTA_THRS_CONS_FYI');
                        fnd_message.set_token ('BUDGET_NAME', l_budget_name, FALSE);
                        fnd_message.set_token ('VALUE_LIMIT', l_valuelimit_name, FALSE);
                        fnd_message.set_token ('OPERATOR', l_operator_meaning, FALSE);
                        fnd_message.set_token ('PERCENT_AMOUNT', budget.percent_amt, FALSE);
                        fnd_message.set_token ('DATE', l_today_date, FALSE);
                        l_message := fnd_message.get;
                    END IF;


                     OZF_Utility_PVT.create_log(l_return_status,
                                                'FTHO',
                                                budget.threshold_rule_id,
                                                l_message,
                                                1,
                                                'GENERAL',
                                                'NOTIFY',
                                                budget.budget_id,
                                                budget.threshold_id,
                                                l_trans_id,
                                                SYSDATE
                                                );

                   IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      RAISE FND_API.G_EXC_ERROR;
                   END IF;
                  END IF; -- Notification result end if
                  END IF; -- operation result end if

                    l_value_limit := 0;
                    l_base_line_amt := 0;
                    l_value_limit_type := '';
                    l_operation_result := '';
                    l_notification_result := '';
          END LOOP;
        END LOOP;
      l_owner_table.delete;

      --Create owner_message table.
      FOR logs IN c_log_message(l_trans_id) LOOP
       OPEN c_owner(logs.budget_id);
       FETCH c_owner INTO l_owner_id,l_parent_fund_id;
       CLOSE c_owner;

       OPEN c_parent_owner(l_parent_fund_id);
       FETCH c_parent_owner INTO l_parent_owner_id;
       CLOSE c_parent_owner;

       l_owner_table(l_count).owner := l_owner_id;
       l_owner_table(l_count).parent_owner := NVL(l_parent_owner_id,0);
       l_owner_table(l_count).message_text := logs.log_message_text;
       l_owner_table(l_count).remove_flag := 'F';

       l_count := l_count +1;
      END LOOP;

      --Combine message for same owner and parent owner and create notify_tabel.
      l_count := 1;
      IF l_owner_table.FIRST IS NOT NULL AND l_owner_table.LAST IS NOT NULL THEN
          FOR i IN NVL(l_owner_table.FIRST, 1) .. NVL(l_owner_table.LAST, 0) LOOP
             IF l_owner_table(i).remove_flag = 'F' THEN
                l_message := l_owner_table(i).message_text;
                l_notify_table(l_count).owner :=  l_owner_table(i).owner;
                l_notify_table(l_count).parent_owner :=l_owner_table(i).parent_owner;
                l_parent_owner_id := l_owner_table(i).parent_owner;
                FOR j IN NVL(l_owner_table.FIRST, 1) .. NVL(l_owner_table.LAST, 0) LOOP
                     IF j <> i AND l_owner_table(j).remove_flag = 'F' AND l_parent_owner_id = l_owner_table(j).parent_owner THEN
                         l_message := l_message || fnd_global.local_chr(10)|| l_owner_table(j).message_text || '. ' || fnd_global.local_chr(10);
                         l_owner_table(j).remove_flag := 'T';
                     END IF;
                END LOOP;
                l_notify_table(l_count).message_text := l_message;
                l_count := l_count + 1;
             END IF;
          EXIT WHEN l_owner_table.COUNT = 0;
          END LOOP;
      END IF;

      IF l_notify_table.FIRST IS NOT NULL AND l_notify_table.LAST IS NOT NULL THEN
            --MAKE A CALL TO NOTIFICATION PROGRAM WHEN READY
          FOR i IN  NVL(l_notify_table.FIRST, 0)..NVL(l_notify_table.LAST, 0) LOOP

            OPEN c_log_seq;
            FETCH c_log_seq INTO l_log_id;
            CLOSE c_log_seq;

            OZF_Utility_PVT.create_log(x_return_status =>l_return_status,
                                         p_arc_log_used_by =>'FTHO',
                                         p_log_used_by_id => l_notify_table(i).owner,
                                         p_msg_data =>l_notify_table(i).message_text,
                                         p_msg_level =>1,
                                         p_msg_type => 'COMBINED',
                                         p_desc =>'NOTIFY',
                                         --p_budget_id =>null,
                                         --p_threshold_id => null,
                                         --p_transaction_id => null,
                                         p_notification_creat_date => SYSDATE,
                                         p_activity_log_id => l_log_id
                                         );
            IF G_DEBUG THEN
               OZF_UTILITY_PVT.debug_message('Call workflow: ' || l_return_status );
            END IF;

            start_process(l_api_version_number,
                                                l_Msg_Count,
                                                l_Msg_Data,
                                                l_return_status,
                                                l_notify_table(i).owner,
                                                l_notify_table(i).parent_owner,
                                                l_notify_table(i).message_text,
                                                l_log_id
                                               );

            IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                 RAISE FND_API.G_EXC_ERROR;
            END IF;

         END LOOP;
     END IF;

     COMMIT;

      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message('PUBLIC QUOTA API: ' || l_api_name || 'END');
      END IF;
      x_retcode                  := 0;

      ozf_utility_pvt.write_conc_log(l_msg_data);

      FND_FILE.PUT_LINE(FND_FILE.LOG,'End of quota validation : ' );
--      RAISE FND_API.G_EXC_ERROR;
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     --ROLLBACK TO validate_quota_threshold;
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception G_EXC_ERROR '||l_api_name);
     x_retcode                  := 1;
     x_errbuf                   := substr(l_msg_data,1,1000);
     ozf_utility_pvt.write_conc_log(l_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     --ROLLBACK TO validate_quota_threshold;
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception G_EXC_UNEXPECTED_ERROR '||l_api_name);
    x_retcode                  := 1;
    x_errbuf                   := substr(l_msg_data,1,1000);
    ozf_utility_pvt.write_conc_log(l_msg_data);

   WHEN OTHERS THEN
     --ROLLBACK TO validate_quota_threshold;
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Exception OTHERS '||l_api_name);
     x_retcode                  := 1;
     x_errbuf                   := substr(l_msg_data,1,1000);
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error : ' || SQLCODE||SQLERRM);
     ozf_utility_pvt.write_conc_log(l_msg_data);

END validate_quota_threshold;

   -----------------------------------------------------------------------
   -- PROCEDURE
   --    operation_result
   --
   -- It compares value limit amout and base line limit amount
   -- to decide validate status.

   -----------------------------------------------------------------------
PROCEDURE operation_result(
    p_api_version_number    IN  NUMBER,
    p_init_msg_list         IN   VARCHAR2     := FND_API.G_FALSE,
    X_Msg_Count       OUT NOCOPY  NUMBER,
    X_Msg_Data        OUT NOCOPY  VARCHAR2,
    x_return_status   OUT NOCOPY VARCHAR2,
    p_lhs                IN NUMBER,
    p_rhs                IN NUMBER,
    p_operator_code      IN VARCHAR2,
    x_result          OUT NOCOPY VARCHAR2)
IS
l_api_version_number  CONSTANT NUMBER       := 1.0;
l_api_name            CONSTANT VARCHAR2(30) := 'operation_result';


BEGIN
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      --OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Derive the result based on operator_code

      IF p_operator_code = '2' THEN
         IF p_lhs >= p_rhs THEN
           x_result := 'VIOLATED';
         ELSE
           x_result := 'NOT VIOLATED';
         END IF;


      ELSIF p_operator_code = '0' THEN
         IF p_lhs <= p_rhs THEN
           x_result := 'VIOLATED';
         ELSE
           x_result := 'NOT VIOLATED';
         END IF;

       ELSIF p_operator_code = '1' THEN
         IF p_lhs = p_rhs THEN
           x_result := 'VIOLATED';
         ELSE
           x_result := 'NOT VIOLATED';
         END IF;

       END IF; -- for main IF/ELSIF

      --OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
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
END operation_result;
   -----------------------------------------------------------------------
   -- PROCEDURE
   --    verify_notification
   -- In Parozf
   -- p_api_version_number   IN       NUMBER
   -- p_init_msg_list        IN       VARCHAR2 := fnd_api.g_false
   -- p_budget_id            IN       NUMBER -- budget to which the threshold applies
   -- p_threshold_id         IN       NUMBER -- threshold_id
   -- p_threshold_rule_id    IN       NUMBER -- threhold_rule_id
   -- p_frequency_period     IN       VARCHAR2 -- MONTHLY or DAILY
   -- p_repeat_frequency     IN       NUMBER
                            -- It is a number . It signifies the frequency of resending the notifications
   -- p_rule_start_date      IN       DATE
   -- Standard Out params
   -- x_msg_count            OUT      NUMBER
   -- x_msg_data             OUT      VARCHAR2
   -- x_return_status        OUT      VARCHAR2
   -- x_result               OUT      VARCHAR2 -- NOTIFY OR NO_NOTIFY

   -- Checks ams_act_logs table if there already is a notification sent to
   -- the budget owner or not for a threshold rule violation

   -----------------------------------------------------------------------
PROCEDURE verify_notification(
    p_api_version_number    IN  NUMBER,
    p_init_msg_list         IN   VARCHAR2     := FND_API.G_FALSE,
    X_Msg_Count       OUT NOCOPY  NUMBER,
    X_Msg_Data        OUT NOCOPY  VARCHAR2,
    x_return_status   OUT NOCOPY VARCHAR2,
    p_budget_id          IN NUMBER,
    p_threshold_id       IN NUMBER,
    p_threshold_rule_id  IN NUMBER,
    p_frequency_period   IN VARCHAR2,
    p_repeat_frequency     IN NUMBER,
    p_rule_start_date     IN DATE,
    x_result          OUT NOCOPY VARCHAR2)
IS
l_api_version_number  CONSTANT NUMBER       := 1.0;
l_api_name            CONSTANT VARCHAR2(30) := 'verify_notification';
l_count                  NUMBER := 0;
l_notify_freq_days    NUMBER := 0;
l_notified_date          DATE     := SYSDATE;

CURSOR c_notification_exist(x_threshold_id NUMBER,
                             x_threshold_rule_id NUMBER,
                          x_budget_id NUMBER) IS
      SELECT Max(notification_creation_date)
      FROM     AMS_ACT_LOGS
      WHERE  arc_act_log_used_by = 'FTHO'
      AND     act_log_used_by_id  = x_threshold_rule_id
      AND     budget_id         = x_budget_id
      AND     threshold_id      = x_threshold_id;

BEGIN
      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
      --OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

         IF p_frequency_period = 'DAILY' THEN
            l_notify_freq_days := p_repeat_frequency;
         END IF;

         IF p_frequency_period ='WEEKLY' THEN
            l_notify_freq_days := p_repeat_frequency*7;

         END IF;

         IF p_frequency_period ='MONTHLY' THEN
            l_notify_freq_days := p_repeat_frequency * 30;
         END IF;

         IF p_frequency_period = 'QUARTERLY' THEN
           l_notify_freq_days :=  p_repeat_frequency * 30 * 3;
         END IF;

         IF p_frequency_period = 'YEARLY' THEN
           l_notify_freq_days :=  p_repeat_frequency * 365;
         END IF;

      -- checks entry in the ams_act_logs table for notification_purposes
        OPEN c_notification_exist(p_threshold_id,
                                  p_threshold_rule_id,
                                  p_budget_id);
        FETCH c_notification_exist INTO l_notified_date;
        CLOSE c_notification_exist;

      -- In case of no notification recorder.
      IF l_notified_date is NULL THEN
          l_notified_date := p_rule_start_date;
      END IF;

      IF SYSDATE - l_notified_date >= l_notify_freq_days THEN
           x_result := ('NOTIFY');
      ELSE
           x_result := ('NOT NOTIFY');
      END IF;

      IF G_DEBUG THEN
         OZF_UTILITY_PVT.debug_message('Private API: Notified day' || l_notify_freq_days || ' end ' ||x_result );
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
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
END verify_notification;

PROCEDURE update_alerts(
    p_api_version_number    IN  NUMBER,
    p_init_msg_list         IN   VARCHAR2     := FND_API.G_FALSE,
    x_Msg_Count       OUT NOCOPY  NUMBER,
    x_Msg_Data        OUT NOCOPY  VARCHAR2,
    x_return_status   OUT NOCOPY VARCHAR2,
    p_resource_id               IN NUMBER,
    p_alert_for                 IN VARCHAR2,
    p_product_attribute         IN VARCHAR2,
    p_attribute2                IN NUMBER, -- product_attr_value/ship_to_site_use_id/sequence_number
    p_alert_type                IN VARCHAR2,
    p_select_attribute          IN VARCHAR2,
    p_cust_account_id           IN NUMBER
    )
IS
l_api_version_number  CONSTANT NUMBER       := 1.0;
l_api_name            CONSTANT VARCHAR2(30) := 'update_alerts';
l_sql_stmt            VARCHAR2(2000);
l_sql_str            VARCHAR2(2000);
l_alert_type          VARCHAR2(30);
l_new_alert_type          VARCHAR2(30);
l_ins_csr             NUMBER;
l_ignore                 NUMBER;
l_stmt       VARCHAR2(2000) := NULL;
l_quota_alert_id       NUMBER;
l_update               BOOLEAN;

CURSOR c_quota_alert_seq IS
SELECT ozf_quota_alerts_s.NEXTVAL
FROM DUAL;

BEGIN
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME)
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
     FND_MSG_PUB.initialize;
    END IF;

    OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');

    FND_FILE.PUT_LINE(FND_FILE.LOG,' p_resource_id: '|| p_resource_id);
    FND_FILE.PUT_LINE(FND_FILE.LOG,' p_alert_for: '|| p_alert_for);
    FND_FILE.PUT_LINE(FND_FILE.LOG,' p_product_attribute: '|| p_product_attribute);
    FND_FILE.PUT_LINE(FND_FILE.LOG,' p_attribute2: '|| p_attribute2);
    FND_FILE.PUT_LINE(FND_FILE.LOG,' p_alert_type: '|| p_alert_type);
    FND_FILE.PUT_LINE(FND_FILE.LOG,' p_select_attribute: '|| p_select_attribute);
    FND_FILE.PUT_LINE(FND_FILE.LOG,' p_cust_account_id: '|| p_cust_account_id);

    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_sql_stmt := '';
    l_sql_str := '';
    l_ins_csr := 0;
    l_ignore := 0;
    l_stmt := '';
    l_new_alert_type := '';
    l_update := FALSE;

    IF p_alert_for = 'PROD' THEN
    BEGIN
       /*l_sql_stmt := 'SELECT ' || p_select_attribute || ' FROM OZF_QUOTA_ALERTS '
                  || 'WHERE report_date = trunc(SYSDATE) AND resource_id = ' || p_resource_id
                  || 'AND alert_for = ''PROD'' AND product_attribute = ''' || p_product_attribute
                  || ''' AND product_attr_value = ' || p_attribute2 */
        l_sql_stmt := 'SELECT ' || p_select_attribute || ' FROM OZF_QUOTA_ALERTS '
                  || 'WHERE report_date = trunc(SYSDATE) AND resource_id = :1 '
                  || 'AND alert_for = ''PROD'' AND product_attribute = :2 '
                  || 'AND product_attr_value = :3';
        EXECUTE IMMEDIATE l_sql_stmt
               INTO l_alert_type
               USING p_resource_id, p_product_attribute, p_attribute2;
        IF  ( l_alert_type IS NULL OR l_alert_type = FND_API.G_MISS_CHAR OR l_alert_type = '') THEN
            l_new_alert_type := p_alert_type;
            l_update := TRUE;
        ELSIF l_alert_type = 'ACCEPTABLE' THEN
              IF (p_alert_type = 'WARNING' OR p_alert_type = 'UNACCEPTABLE' )THEN
                l_new_alert_type := p_alert_type;
                l_update := TRUE;
              END IF;
        ELSIF l_alert_type = 'WARNING' THEN
              IF (p_alert_type = 'UNACCEPTABLE' )THEN
                l_new_alert_type := p_alert_type;
                l_update := TRUE;
              END IF;
        END IF;

        IF l_update THEN

        /*
        l_sql_str := 'UPDATE OZF_QUOTA_ALERTS SET ' || p_select_attribute;
        l_sql_str := l_sql_str || ' = ''' || l_new_alert_type ;
        l_sql_str := l_sql_str || ''' WHERE report_date = trunc(SYSDATE) AND resource_id = ' || p_resource_id;
        l_sql_str := l_sql_str || ' AND alert_for = ''PROD'' AND product_attribute = ''' || p_product_attribute;
        l_sql_str := l_sql_str || ''' AND product_attr_value = ' || p_attribute2;

              FND_DSQL.init;
              FND_DSQL.add_text(l_sql_str);
              l_ins_csr := DBMS_SQL.open_cursor;
              FND_DSQL.set_cursor(l_ins_csr);
              l_stmt := FND_DSQL.get_text(FALSE);

              FND_FILE.PUT_LINE(FND_FILE.LOG,'product UPD query: '|| l_stmt);
              DBMS_SQL.parse(l_ins_csr, l_stmt, DBMS_SQL.native);
              FND_DSQL.do_binds;
              l_ignore := DBMS_SQL.execute(l_ins_csr);
        */

        --kvattiku updated
              l_sql_str := 'UPDATE OZF_QUOTA_ALERTS SET ' || p_select_attribute;
              l_sql_str := l_sql_str || ' = :1 ';
              l_sql_str := l_sql_str || ' WHERE report_date = trunc(SYSDATE) AND resource_id = :2';
              l_sql_str := l_sql_str || ' AND alert_for = ''PROD'' AND product_attribute = :3';
              l_sql_str := l_sql_str || ' AND product_attr_value = :4';

         EXECUTE IMMEDIATE l_sql_str
               USING l_new_alert_type, p_resource_id, p_product_attribute, p_attribute2;

        END IF;
    EXCEPTION
           WHEN NO_DATA_FOUND THEN
              OPEN c_quota_alert_seq;
              FETCH c_quota_alert_seq INTO l_quota_alert_id;
              CLOSE c_quota_alert_seq;

              l_sql_str := 'INSERT INTO OZF_QUOTA_ALERTS ';
              l_sql_str := l_sql_str || '(quota_alert_id, report_date, resource_id, alert_for, ';
              l_sql_str := l_sql_str || 'product_attribute, product_attr_value, ' || p_select_attribute;
              l_sql_str := l_sql_str || ') VALUES (' || l_quota_alert_id || ',''' || TRUNC(SYSDATE) || ''',';
              l_sql_str := l_sql_str || p_resource_id || ','''||'PROD'',''' || p_product_attribute || ''',';
              l_sql_str := l_sql_str || p_attribute2 || ',''' || p_alert_type || ''')';

              --FND_FILE.PUT_LINE(FND_FILE.LOG,'l_sql_str ::::::::::' || l_sql_str );
              FND_DSQL.init;
              FND_DSQL.add_text(l_sql_str);
              l_ins_csr := DBMS_SQL.open_cursor;
              FND_DSQL.set_cursor(l_ins_csr);
              l_stmt := FND_DSQL.get_text(FALSE);

              FND_FILE.PUT_LINE(FND_FILE.LOG,'product INS query: '|| l_stmt);
              DBMS_SQL.parse(l_ins_csr, l_stmt, DBMS_SQL.native);
              FND_DSQL.do_binds;
              l_ignore := DBMS_SQL.execute(l_ins_csr);

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
             FND_FILE.PUT_LINE(FND_FILE.LOG,'PROD EXCEPTION : '|| SUBSTR(SQLERRM, 1, 2000));
    END;

    ELSIF p_alert_for = 'CUST' THEN
    BEGIN
        l_sql_stmt := 'SELECT ' || p_select_attribute || ' FROM OZF_QUOTA_ALERTS '
                  || 'WHERE report_date = trunc(SYSDATE) AND resource_id = :1 '
                  || 'AND alert_for = ''CUST'' AND cust_account_id = :2 '
                  || 'AND ship_to_site_use_id = :3';
        EXECUTE IMMEDIATE l_sql_stmt
               INTO l_alert_type
               USING p_resource_id, p_cust_account_id, p_attribute2;
        IF  ( l_alert_type IS NULL OR l_alert_type = FND_API.G_MISS_CHAR OR l_alert_type = '') THEN
            l_new_alert_type := p_alert_type;
            l_update := TRUE;
        ELSIF l_alert_type = 'ACCEPTABLE' THEN
              IF (p_alert_type = 'WARNING' OR p_alert_type = 'UNACCEPTABLE' )THEN
                l_new_alert_type := p_alert_type;
                l_update := TRUE;
              END IF;
        ELSIF l_alert_type = 'WARNING' THEN
              IF (p_alert_type = 'UNACCEPTABLE' )THEN
                l_new_alert_type := p_alert_type;
                l_update := TRUE;
              END IF;
        END IF;

        IF l_update THEN

        /* commented by kvattiku
              l_sql_str := 'UPDATE OZF_QUOTA_ALERTS SET ' || p_select_attribute;
              l_sql_str := l_sql_str || ' = ''' || l_new_alert_type ;
              l_sql_str := l_sql_str || ''' WHERE report_date = trunc(SYSDATE) AND resource_id = ' || p_resource_id;
              l_sql_str := l_sql_str || ' AND alert_for = ''CUST'' AND cust_account_id = ''' || p_cust_account_id;
              l_sql_str := l_sql_str || ''' AND ship_to_site_use_id = ' || p_attribute2;

              FND_DSQL.init;
              FND_DSQL.add_text(l_sql_str);
              l_ins_csr := DBMS_SQL.open_cursor;
              FND_DSQL.set_cursor(l_ins_csr);
              l_stmt := FND_DSQL.get_text(FALSE);

              FND_FILE.PUT_LINE(FND_FILE.LOG,'CUSTOMER UPD query: '|| l_stmt);
              DBMS_SQL.parse(l_ins_csr, l_stmt, DBMS_SQL.native);
              FND_DSQL.do_binds;
              l_ignore := DBMS_SQL.execute(l_ins_csr);
        */

        --added by kvattiku
        l_sql_str := 'UPDATE OZF_QUOTA_ALERTS SET ' || p_select_attribute;
        l_sql_str := l_sql_str || ' = :1';
        l_sql_str := l_sql_str || ' WHERE report_date = trunc(SYSDATE) AND resource_id = :2';
        l_sql_str := l_sql_str || ' AND alert_for = ''CUST'' AND cust_account_id = :3';
        l_sql_str := l_sql_str || ' AND ship_to_site_use_id = :4';

        EXECUTE IMMEDIATE l_sql_str
        USING l_new_alert_type, p_resource_id, p_cust_account_id, p_attribute2;


        END IF;
    EXCEPTION
           WHEN NO_DATA_FOUND THEN
              OPEN c_quota_alert_seq;
              FETCH c_quota_alert_seq INTO l_quota_alert_id;
              CLOSE c_quota_alert_seq;

              l_sql_str := 'INSERT INTO OZF_QUOTA_ALERTS ';
              l_sql_str := l_sql_str || '(quota_alert_id, report_date, resource_id, alert_for, ';
              l_sql_str := l_sql_str || 'cust_account_id, ship_to_site_use_id, ' || p_select_attribute;
              l_sql_str := l_sql_str || ') VALUES (' || l_quota_alert_id || ',''' || TRUNC(SYSDATE) || ''',';
              l_sql_str := l_sql_str || p_resource_id || ','''||'CUST'',''' || p_cust_account_id || ''',';
              l_sql_str := l_sql_str || p_attribute2 || ',''' || p_alert_type || ''')';

              --FND_FILE.PUT_LINE(FND_FILE.LOG,'l_sql_str ::::::::::' || l_sql_str );
              FND_DSQL.init;
              FND_DSQL.add_text(l_sql_str);
              l_ins_csr := DBMS_SQL.open_cursor;
              FND_DSQL.set_cursor(l_ins_csr);
              l_stmt := FND_DSQL.get_text(FALSE);

              FND_FILE.PUT_LINE(FND_FILE.LOG,'CUSTOMER INS query: '|| l_stmt);
              DBMS_SQL.parse(l_ins_csr, l_stmt, DBMS_SQL.native);
              FND_DSQL.do_binds;
              l_ignore := DBMS_SQL.execute(l_ins_csr);

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
             FND_FILE.PUT_LINE(FND_FILE.LOG,'CUST EXCEPTION : '|| SUBSTR(SQLERRM, 1, 2000));
    END;

    ELSIF p_alert_for = 'QUOTA' THEN
    BEGIN
        l_sql_stmt := 'SELECT alert_type FROM OZF_DASHB_DAILY_KPI '
                  || 'WHERE report_date = trunc(SYSDATE) AND resource_id = :1 '
                  || 'AND sequence_number = :2';

        EXECUTE IMMEDIATE l_sql_stmt
               INTO l_alert_type
               USING p_resource_id, p_attribute2;
        IF  ( l_alert_type IS NULL OR l_alert_type = FND_API.G_MISS_CHAR OR l_alert_type = '') THEN
            l_new_alert_type := p_alert_type;
            l_update := TRUE;
        ELSIF l_alert_type = 'ACCEPTABLE' THEN
              IF (p_alert_type = 'WARNING' OR p_alert_type = 'UNACCEPTABLE' )THEN
                l_new_alert_type := p_alert_type;
                l_update := TRUE;
              END IF;
        ELSIF l_alert_type = 'WARNING' THEN
              IF (p_alert_type = 'UNACCEPTABLE' )THEN
                l_new_alert_type := p_alert_type;
                l_update := TRUE;
              END IF;
        END IF;

        IF l_update THEN

        /* commented by kvattiku
              l_sql_str := 'UPDATE OZF_DASHB_DAILY_KPI SET alert_type = ''' || l_new_alert_type;
              l_sql_str := l_sql_str || ''' WHERE report_date = trunc(SYSDATE) AND resource_id = ' || p_resource_id;
              l_sql_str := l_sql_str || ' AND sequence_number = ' || p_attribute2;

              FND_DSQL.init;
              FND_DSQL.add_text(l_sql_str);
              l_ins_csr := DBMS_SQL.open_cursor;
              FND_DSQL.set_cursor(l_ins_csr);
              l_stmt := FND_DSQL.get_text(FALSE);

              FND_FILE.PUT_LINE(FND_FILE.LOG,'CUSTOMER UPD query: '|| l_stmt);
              DBMS_SQL.parse(l_ins_csr, l_stmt, DBMS_SQL.native);
              FND_DSQL.do_binds;
              l_ignore := DBMS_SQL.execute(l_ins_csr);
        */

        --added by kvattiku
        l_sql_str := 'UPDATE OZF_DASHB_DAILY_KPI SET alert_type = :1';
        l_sql_str := l_sql_str || ' WHERE report_date = trunc(SYSDATE) AND resource_id = :2';
        l_sql_str := l_sql_str || ' AND sequence_number = :3';

        EXECUTE IMMEDIATE l_sql_str
        USING l_new_alert_type, p_resource_id, p_attribute2;

        END IF;
    EXCEPTION
           WHEN NO_DATA_FOUND THEN
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              x_msg_count := 1;
              x_msg_data := SUBSTR(SQLERRM, 1, 2000);
             FND_FILE.PUT_LINE(FND_FILE.LOG,'QUOTA EXCEPTION : '|| SUBSTR(SQLERRM, 1, 2000));

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
             FND_FILE.PUT_LINE(FND_FILE.LOG,'QUOTA EXCEPTION : '|| SUBSTR(SQLERRM, 1, 2000));
    END;
    END IF;


    OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (p_count          =>   x_msg_count,
     p_data           =>   x_msg_data
    );
EXCEPTION
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
     FND_FILE.PUT_LINE(FND_FILE.LOG,'update_alerts EXCEPTION : '|| SUBSTR(SQLERRM, 1, 2000));
END update_alerts;

END OZF_QUOTA_THRESHOLD_PVT;

/
