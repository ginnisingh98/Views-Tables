--------------------------------------------------------
--  DDL for Package Body AMS_ACTMETRICS_SEED_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_ACTMETRICS_SEED_PVT" AS
/* $Header: amsvamsb.pls 120.20.12010000.2 2008/08/12 08:11:47 amlal ship $ */
--------------------------------------------------------------------------------
--
-- NAME
--    AMS_ACTMETRICS_SEED_PVT 12.0
--
-- HISTORY
-- 30-Aug-2001   dmvincen     Created
-- 05-Sep-2001   dmvincen     Checking for changed values only.
--                            Using union all for performance.
--                            Fixed setting dirty flags.
-- 24-Oct-2001   dmvincen   Fixed update for existing values.
-- 04-Jan-2002   dmvincen     New columns for materialized views.
-- 27-Nov-2002   dmvincen     Sunil decoupled with BIM.
-- 29-Nov-2002   sunkumar     added index hints for performance reasons
-- 06-Dec-2002   dmvincen     Fixed cartesian product joins.
--                            Synced with BIM fact queries.
-- 06-Feb-2003   sunkumar     added the missing group by expression
--                            for order amount, for all objtypes. bug#2782228
-- 06-Mar-2003   dmvincen     BUG2837271: Fixed response count for distinct
--                            party_id.
-- 06-Mar-2003   dmvincen     Update last_update_date for history recording.
-- 06-Mar-2003   dmvincen     Removed magic strings.
-- 13-Jun-2003   sunkumar     bug# 2948298 added registrants, attendees and
--                            cancellations for campaign schedule of type event.
-- 31-Jul-2003   sunkumar     BUG 3058065: Added Booked and Invoiced Revenue
-- 05-Jul-2003   sunkumar     Added 'CALCULATE_TARGET_GROUP'
--                            and 'CALCULATE_SEEDED_LIST_METRICS'
--                            and modified   'CALCULATE_SEEDED_METRICS'
--                            to add seeded metrics for campaign workbench (R10)
-- 06-Nov-2003   choang       1) updated all types related to profile options
--                            to use profile option
--                            column 2) added bulk update callouts to new
--                            seeded metric procedures.
-- 13-Nov-2003   choang       Fixed lead seeded metrics.
-- 14-Nov-2003   dmvincen     Leads to check subcategory is null.
-- 14-Nov-2003   dmvincen     Wrong syntax for decode...G_EONE.
-- 16-Jan-2004   dmvincen     BUG3370252: Orders count not populating correctly.
--                            Removed linkage through leads/opps for orders
--                            and quotes, and revenue.
-- 26-Jan-2004   choang       bug 3396140: changed target group queries to use
--                            list_act_type TARGET instead of LIST.
-- 26-Jan-2004   dmvincen     BUG3396063: Indicate refresh for formulas.
-- 04-Feb-2004   dmvincen     Object level query amount missing entry join.
-- 06-Feb-2004   dmvincen     Removed object tables for more generic queries.
-- 06-Feb-2004   dmvincen     Added like to function name for any schema match.
-- 11-Feb-2004   dmvincen     Added currency conversion during bulk update.
-- 20-feb-2004   sunkumar     modified list queries. bug#3370252
-- 23-feb-2004   sunkumar     modified leads/opp. query for list for org. contact
-- 26-feb-2004   sunkumar     used HZ tables to get data for list queries
-- 09-Mar-2004   dmvincen     Moved hz_cust_accounts into exists clause.
-- 11-May-2004   sunkumar     bug#3611891:LIST EFFECTIVENESS SHOWS WRONG NO OF LEADS
-- 25-May-2004   sunkumar     bug#3578292:INVOICE REV COL GETS POPULATED W/O INVOICING IN LIST EFF
-- 08-Jun-2004   dmvincen     BUG#3488796: PERF: Invoiced revenue to use exists clause
-- 23-Jun-2004   dmvincen     BUG3704598: PERF: List queries.
-- 06-Jan-2005   dmvincen     BUG4116414: Merge forward: List query performance.
-- 16-Jun-2005   dmvincen     BUG4438486: Refresh function variable metrics.
-- 11-Aug-2005   dmvincen     Added Inferred Calculations.
-- 21-Oct-2005   dmvincen     BUG4650767: Inferred B2B Orders requires Roles.
-- 21-Dec-2005   dmvincen     BUG4878626: Performance if inferred queries.
-- 05-Jan-2006   dmvincen     BUG4924982: SQL Repos: Quotes performance.
-- 19-Jan-2006   dmvincen     BUG4963536: Inferred response is a rogue.
-- 03-Feb-2006   dmvincen     BUG5002890: Inferred Leads has high buffer gets.
-- 03-Feb-2006   dmvincen     BUG4970454: Inferred Orders has high buffer gets.
--------------------------------------------------------------------------------
--
--
-- Global variables and constants.
--
-- Name of the current package.
G_PKG_NAME CONSTANT VARCHAR2(30) := 'AMS_ACTMETRICS_SEED_PVT';

G_FUNCTION_NAME CONSTANT VARCHAR2(80) :='AMS_ACTMETRICS_SEED_PVT.CALCULATE_SEEDED_METRICS';

-- sunkumar Added 11.5.10: 05-August-2003
G_TARGET_FUNCTION_NAME CONSTANT VARCHAR2(80) :='AMS_ACTMETRICS_SEED_PVT.CALCULATE_TARGET_GROUP';
G_LIST_FUNCTION_NAME CONSTANT VARCHAR2(80) := 'AMS_ACTMETRICS_SEED_PVT.CALCULATE_SEEDED_LIST_METRICS';

G_DEAD_LEAD_STATUS fnd_profile_option_values.profile_option_value%TYPE := fnd_profile.value('AS_DEAD_LEAD_STATUS');
G_LEAD_LINK_STATUS fnd_profile_option_values.profile_option_value%TYPE := fnd_profile.value('AS_LEAD_LINK_STATUS');
-- sunkumar end additions

G_FUNC_CURRENCY fnd_profile_option_values.profile_option_value%TYPE := fnd_profile.value('AMS_DEFAULT_CURR_CODE');


-- sunkumar Added 11.5.10: 05-August-2003
G_ACCOUNTING_INFO VARCHAR2(30) := 'Accounting Information';
G_ALIST CONSTANT VARCHAR2(30) := 'ALIST';
-- sunkumar end additions

G_CSCH CONSTANT VARCHAR2(30) := 'CSCH';
G_EVEO CONSTANT VARCHAR2(30) := 'EVEO';
G_EONE CONSTANT VARCHAR2(30) := 'EONE';
G_FUNCTION CONSTANT VARCHAR2(30) := 'FUNCTION';
G_LEAD_ID CONSTANT NUMBER := 906;
G_OPPORTUNITY_ID CONSTANT NUMBER := 907;
G_ORDER_AMOUNT_ID CONSTANT NUMBER := 908;
G_RESPONSE_ID CONSTANT NUMBER := 903;
G_ATTENDEE_ID CONSTANT NUMBER := 910;
G_ORDER_COUNT_ID CONSTANT NUMBER := 912;
G_REGISTRANTS_ID CONSTANT NUMBER := 909;
G_CANCELLATION_ID CONSTANT NUMBER := 911;
G_INVOICED_ID CONSTANT NUMBER := 921;
G_BOOKED_ID CONSTANT NUMBER := 922;
G_REVENUE_ID CONSTANT NUMBER := 902;
G_BOOKED CONSTANT VARCHAR2(30) := 'BOOKED';
G_HEADER CONSTANT VARCHAR2(30) := 'HEADER';
G_OPP_QUOTE CONSTANT VARCHAR2(30) := 'OPP_QUOTE';
G_REGISTERED CONSTANT VARCHAR2(30) := 'REGISTERED';
G_CANCELLED CONSTANT VARCHAR2(30) := 'CANCELLED';
G_POSITIVE_RESPONSE CONSTANT VARCHAR2(1) := 'Y';
G_IS_DIRTY CONSTANT VARCHAR2(1) := 'Y';
G_IS_LEAD CONSTANT VARCHAR2(1) := 'Y';
G_IS_ENABLED CONSTANT VARCHAR2(1) := 'Y';
G_IS_DELETED CONSTANT VARCHAR2(1) := 'Y';
G_NOT_DELETED CONSTANT VARCHAR2(1) := 'N';
G_IS_ATTENDED CONSTANT VARCHAR2(1) := 'Y';

--sunkumar -  start: 11510 additions 04-August-2003

G_BOOKED_FLAG CONSTANT VARCHAR2(1) := 'Y';
G_IS_ACCEPTED CONSTANT VARCHAR2(1) := 'Y';
G_NOT_ACCEPTED CONSTANT VARCHAR2(1) := 'N';

G_LEAD_TYPE CONSTANT VARCHAR2(1) := 'A';
G_LEAD_RANK CONSTANT VARCHAR2(30) := 'RANK';

G_CONTACT_GROUP_ID CONSTANT NUMBER := 770;
G_CONTROL_GROUP_ID CONSTANT NUMBER := 771;
G_QUOTE_COUNT_ID CONSTANT NUMBER := 914;
G_QUOTE_AMOUNT_ID CONSTANT NUMBER := 915;
G_TARGET_GROUP_ID CONSTANT NUMBER := 913;
G_DEAD_LEAD_ID CONSTANT NUMBER := 780;
G_OPP_CONVERSION_ID CONSTANT NUMBER := 781;
G_ACCEPTED_LEAD_ID CONSTANT NUMBER := 782;
G_TOP_LEAD_ID CONSTANT NUMBER := 783;
--G_BOOKED_ORDER_ID CONSTANT NUMBER := 918;
G_OPP_AMOUNT CONSTANT NUMBER := 916;

G_LIST_TYPE       CONSTANT VARCHAR2(30) := 'LIST';
G_TARGET_TYPE     CONSTANT VARCHAR2(30) := 'TARGET';
G_LIST_SEL_ACTION CONSTANT VARCHAR2(30) := 'LIST';

G_FORMULA  CONSTANT VARCHAR2(30) := 'FORMULA';
G_METRIC   CONSTANT VARCHAR2(30) := 'METRIC';
G_CATEGORY CONSTANT VARCHAR2(30) := 'CATEGORY';
G_VARIABLE CONSTANT VARCHAR2(30) := 'VARIABLE';

G_B2B_LIST_CATEGORY CONSTANT VARCHAR2(30) := 'B2B_TCA_PROFILE';

--sunkumar end: 11510 additions

--sunkumar 03-mar-2004 additions for list metric_id's

G_LIST_LEAD_ID CONSTANT NUMBER := 326;
G_LIST_OPP_ID CONSTANT NUMBER := 331;

--sunkumar - 18-Jun-2003 - bug #2948298
G_ACTIVITY_EVENTS CONSTANT VARCHAR2(30) := 'EVENTS';

-- BUG 4281906: Calculation lag in days.
G_CALC_LAG_DAYS CONSTANT NUMBER := fnd_profile.value('AMS_METR_SEEDED_CALC_EXP');

AMS_DEBUG_HIGH_ON BOOLEAN := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON BOOLEAN := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON BOOLEAN := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Write_Log(name varchar2, message1 varchar2, message2 varchar2 := null)
IS
   msg varchar2(2000);
begin
   msg := TO_CHAR(DBMS_UTILITY.get_time)||': '
       ||G_PKG_NAME||'.'||name||': '||message1;
   if message2 is not null then
       msg := msg || ': '||message2;
   end if;
   Ams_Utility_Pvt.Write_Conc_Log(msg);
END Write_Log;

PROCEDURE Show_Values(
          p_actmetric_id_table IN num_table_type,
          p_actual_value_table IN num_table_type)
IS
   l_index NUMBER;
   l_last number;
   l_limit NUMBER := 5;
BEGIN
   write_log('Show_Values','COUNT='||p_actmetric_id_table.COUNT);
   IF p_actmetric_id_table.COUNT > 0 THEN
      IF l_limit is not null then
        l_last := p_actmetric_id_table.first + l_limit - 1;
       IF l_last > p_actmetric_id_table.last THEN
          l_last := p_actmetric_id_table.last;
       end if;
     else
        l_last := p_actmetric_id_table.last;
     end if;

      FOR l_index IN p_actmetric_id_table.FIRST .. l_last
      LOOP
         EXIT WHEN l_index IS NULL;
         write_log('Show_Values',
                 'actmetid='||p_actmetric_id_table(l_index),
                 'actual_value='||p_actual_value_table(l_index));
      END LOOP;
   END IF;
END Show_Values;

-- NAME
--     convert_currency
--
-- PURPOSE
--     Change currency to the default.
--
-- NOTES
--
-- HISTORY
-- 30-Aug-2001   dmvincen   Created.
--
FUNCTION  convert_currency(
   p_from_currency          VARCHAR2
  ,p_from_amount            NUMBER) RETURN NUMBER
IS
   l_conversion_type_profile    CONSTANT VARCHAR2(30) := 'AMS_CURR_CONVERSION_TYPE';
   l_conversion_type    fnd_profile_option_values.profile_option_value%TYPE;   -- Curr conversion type; see API doc for details.
   l_to_amount      NUMBER;
   x_return_status  VARCHAR2(1);
BEGIN

    IF p_from_currency IS NULL OR
       G_FUNC_CURRENCY = p_from_currency OR
       nvl(p_from_amount,0) = 0 THEN
       RETURN p_from_amount;
    END IF;

    -- condition added to pass conversion types
    l_conversion_type := fnd_profile.VALUE(l_conversion_type_profile);

    -- Conversion type cannot be null in profile
    IF l_conversion_type IS NULL THEN
       IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('AMS', 'AMS_NO_EXCHANGE_TYPE');
         fnd_msg_pub.ADD;
       END IF;
       RETURN 0;
    END IF;

   -- Call the proper AMS_UTILITY_API API to convert the amount.

      ams_utility_pvt.Convert_Currency (
         x_return_status ,
         p_from_currency,
         G_FUNC_CURRENCY,
         sysdate,
         p_from_amount,
         l_to_amount);

   RETURN (l_to_amount);

EXCEPTION
   WHEN gl_currency_api.no_rate THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('AMS', 'AMS_NO_RATE');
         fnd_msg_pub.ADD;
      END IF;
   WHEN gl_currency_api.invalid_currency THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('AMS', 'AMS_INVALID_CURR');
         fnd_msg_pub.ADD;
      END IF;
   WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg('AMS_UTLITY_PVT', 'Convert_curency');
      END IF;
END convert_currency;

-- NAME
--     convert_to_trans_currency
--
-- PURPOSE
--     Change the currency from default to transactional.
--
-- NOTES
--
-- HISTORY
-- 08-Jun-2004   dmvincen   Created.
--
FUNCTION  convert_to_trans_currency(
   p_trans_currency          VARCHAR2
  ,p_from_amount            NUMBER) RETURN NUMBER
IS
   l_conversion_type_profile    CONSTANT VARCHAR2(30) := 'AMS_CURR_CONVERSION_TYPE';
   l_conversion_type    fnd_profile_option_values.profile_option_value%TYPE;   -- Curr conversion type; see API doc for details.
   l_to_amount      NUMBER;
   x_return_status  VARCHAR2(1);
BEGIN

    IF p_trans_currency IS NULL OR
       G_FUNC_CURRENCY = p_trans_currency OR
       nvl(p_from_amount,0) = 0 THEN
       RETURN p_from_amount;
    END IF;

    -- condition added to pass conversion types
    l_conversion_type := fnd_profile.VALUE(l_conversion_type_profile);

    -- Conversion type cannot be null in profile
    IF l_conversion_type IS NULL THEN
       IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('AMS', 'AMS_NO_EXCHANGE_TYPE');
         fnd_msg_pub.ADD;
       END IF;
       RETURN 0;
    END IF;

   -- Call the proper AMS_UTILITY_API API to convert the amount.

      ams_utility_pvt.Convert_Currency (
         x_return_status ,
         G_FUNC_CURRENCY,
         p_trans_currency,
         sysdate,
         p_from_amount,
         l_to_amount);

   RETURN (l_to_amount);

EXCEPTION
   WHEN gl_currency_api.no_rate THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('AMS', 'AMS_NO_RATE');
         fnd_msg_pub.ADD;
      END IF;
   WHEN gl_currency_api.invalid_currency THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
         fnd_message.set_name('AMS', 'AMS_INVALID_CURR');
         fnd_msg_pub.ADD;
      END IF;
   WHEN OTHERS THEN
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
         fnd_msg_pub.add_exc_msg('AMS_UTLITY_PVT', 'Convert_curency');
      END IF;
END convert_to_trans_currency;

-- NAME
--     Update_Actmetrics_Bulk
--
-- PURPOSE
--     Bulk update the activity metrics for given ids and actual values.
--     Set ancester nodes to dirty.
--
-- NOTES
--     To Do: The Costs and Revenue value must be converted.
--
-- HISTORY
-- 30-Aug-2001   dmvincen   Created.
-- 16-Jun-2005   dmvincen   BUG4438486: Refresh function variable metrics
--                          by setting dirty flag.
--
PROCEDURE Update_Actmetrics_Bulk(
          p_actmetric_id_table IN num_table_type,
          p_actual_value_table IN num_table_type)
IS
   l_today DATE := SYSDATE;
BEGIN
   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Update_Actmetrics_Bulk',
          'BULK UPDATING COUNT='||p_actmetric_id_table.COUNT);
   END IF;
   IF AMS_DEBUG_MEDIUM_ON THEN
    Show_Values(p_actmetric_id_table, p_actual_value_table);
   END IF;
   IF p_actmetric_id_table.COUNT > 0 THEN
      -- Bulk update all the actual values.
      FORALL l_index IN p_actmetric_id_table.FIRST .. p_actmetric_id_table.LAST
         UPDATE ams_act_metrics_all
            SET days_since_last_refresh = l_today - last_calculated_date,
                last_calculated_date = l_today,
                last_update_date = l_today,
                object_version_number = object_version_number+1,
                dirty_flag = 'Y',
                difference_since_last_calc =
                        p_actual_value_table(l_index) - func_actual_value,
                trans_actual_value = convert_to_trans_currency(transaction_currency_code,p_actual_value_table(l_index)),
                func_actual_value = p_actual_value_table(l_index)
          WHERE activity_metric_id = p_actmetric_id_table(l_index);

      -- Bulk update ancesters to be dirty.
      FORALL l_index IN p_actmetric_id_table.first..p_actmetric_id_table.last
        UPDATE ams_act_metrics_all a
           SET dirty_flag = G_IS_DIRTY
           WHERE activity_metric_id IN
            (SELECT activity_metric_id FROM
             (SELECT activity_metric_id, dirty_flag FROM ams_act_metrics_all
             START WITH activity_metric_id = p_actmetric_id_table(l_index)
            CONNECT BY activity_metric_id = PRIOR summarize_to_metric
             UNION ALL
             SELECT activity_metric_id, dirty_flag FROM ams_act_metrics_all
            START WITH activity_metric_id = p_actmetric_id_table(l_index)
            CONNECT BY activity_metric_id = PRIOR rollup_to_metric
            UNION ALL
            SELECT a.activity_metric_id, a.dirty_flag
            FROM ams_act_metrics_all a, ams_metrics_all_b m,
                 ams_metric_formulas f,
                 ams_act_metrics_all b, ams_metrics_all_b c
            WHERE a.metric_id = m.metric_id
            AND m.metric_id = f.metric_id
            AND b.metric_id = c.metric_id
            AND a.arc_act_metric_used_by = b.arc_act_metric_used_by
            AND a.act_metric_used_by_id = b.act_metric_used_by_id
            AND m.metric_calculation_type = G_FORMULA
            AND a.last_update_date > b.last_update_date
            AND ((b.metric_id = f.source_id
                  AND f.source_type = G_METRIC)
               OR (c.metric_category = f.source_id
                   AND f.source_type = G_CATEGORY))
            AND b.activity_metric_id = p_actmetric_id_table(l_index)
            AND a.dirty_flag <> G_IS_DIRTY
            UNION ALL
           SELECT a.activity_metric_id, a.dirty_flag
              FROM ams_act_metrics_all a, ams_metrics_all_b b,
                   ams_act_metrics_all c
             WHERE a.metric_id = b.metric_id
               AND b.accrual_type = G_VARIABLE
               AND a.arc_act_metric_used_by = c.arc_act_metric_used_by
               AND a.act_metric_used_by_id = c.act_metric_used_by_id
               AND c.activity_metric_id = p_actmetric_id_table(l_index)
               AND TO_NUMBER(NVL(b.compute_using_function,'-1')) = c.metric_id
               AND a.dirty_flag <> G_IS_DIRTY)
           WHERE dirty_flag <> G_IS_DIRTY);

   END IF;
END update_actmetrics_bulk;

-- NAME
--     Calculate_Quotes
--
-- PURPOSE
--     Bulk collect the quotes from source tables.
--
-- HISTORY
-- 05-Jan-2005   dmvincen   Created from calculate_seeded_metrics.
-- 05-Jan-2005   dmvincen   Added enabled metric checks.
--
PROCEDURE Calculate_Quotes -- ALL
IS
   l_actual_values_table num_table_type;
   l_activity_metric_id_table num_table_type;
   l_today DATE := sysdate;

   cursor c_has_quotes_enabled IS
     SELECT count(distinct b.metric_id) metric_count,
            count(a.activity_metric_id) activity_count
     FROM ams_metrics_all_b b, ams_act_metrics_all a
     WHERE b.metric_id in (244,245,246,247,248,254,255,256,257,258)
     AND enabled_flag = G_IS_ENABLED
     AND a.metric_id = b.metric_id
     AND nvl(a.last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS;

   l_has_enabled NUMBER;
   l_activity_count NUMBER;
BEGIN
   OPEN c_has_quotes_enabled;
   FETCH c_has_quotes_enabled INTO l_has_enabled, l_activity_count;
   CLOSE c_has_quotes_enabled;

   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_Quotes','Enabled Count='||l_has_enabled,
                'Activity Metrics='||l_activity_count);
   END IF;

   IF l_has_enabled > 0 THEN

     SELECT NVL(actual_value, 0), activity_metric_id
     BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
     FROM
       (SELECT decode(metric_category,914,quote_count,
                915,quote_amount,0) actual_value, activity_metric_id, func_actual_value
       FROM(
         SELECT count(G.quote_header_id) quote_count,
          sum(convert_currency(nvl(currency_code,G_FUNC_CURRENCY),
                             total_list_price + total_adjusted_amount)) quote_amount,
                marketing_source_code_id
         FROM   aso_quote_headers_all G
         WHERE  G.marketing_source_code_id in (select c.source_code_id
            from ams_act_metrics_all AL, ams_metrics_all_b ALB,
                ams_source_codes c
            where   AL.ARC_ACT_METRIC_USED_BY = C.arc_source_code_for
              AND   AL.act_metric_used_by_id = C.source_code_for_id
              AND   AL.metric_id = ALB.metric_id
              AND   ALB.metric_id in (244,245,246,247,248,254,255,256,257,258)
              AND   ALB.enabled_flag = 'Y'
              AND   nvl(AL.last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS
           )
          and quote_version = (select max(quote_version) from aso_quote_headers_all
                               where quote_number = g.quote_number)
          GROUP BY marketing_source_code_id
         ) quotes,
           ams_act_metrics_all AL, ams_metrics_all_b ALB,
           ams_source_codes c
       where   quotes.marketing_source_code_id(+) = c.source_code_id
         AND   AL.ARC_ACT_METRIC_USED_BY = C.arc_source_code_for
         AND   AL.act_metric_used_by_id = C.source_code_for_id
         AND   AL.metric_id = ALB.metric_id
         AND   ALB.metric_id in (244,245,246,247,248,254,255,256,257,258)
         AND   ALB.enabled_flag = 'Y'
         AND   nvl(AL.last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS
      ) C
     WHERE NVL(actual_value,0) <> NVL(func_actual_value,-1)
     ;

      -- Save all calculation upto this point.
      update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
      l_activity_metric_id_table.DELETE;
      l_actual_values_table.DELETE;

   END IF;

END;

-- NAME
--     Calculate_Leads_Opps
--
-- PURPOSE
--     Bulk collect the leads and opportunities from source tables.
--
-- HISTORY
-- 05-Jan-2005   dmvincen   Created from calculate_seeded_metrics.
-- 05-Jan-2005   dmvincen   Added enabled metric checks.
--
PROCEDURE Calculate_Leads_Opps -- ALL
IS
   l_actual_values_table num_table_type;
   l_activity_metric_id_table num_table_type;
   l_today DATE := sysdate;

   cursor c_has_leads_quotes_enabled IS
     SELECT count(distinct b.metric_id) metric_count,
            count(activity_metric_id) activity_count
     FROM ams_metrics_all_b b, ams_act_metrics_all a
     WHERE b.metric_id in (264,265,266,267,268, -- Dead leads
           83,84,85,88,89, -- Leads
           274,275,276,277,278, -- Leads Accepted
           284,285,286,287,288, -- Leads to Opportunities
           294,295,296,297,298,  -- Top Leads
           93,94,95,98,99)  -- Opportunities
     AND enabled_flag = G_IS_ENABLED
     AND nvl(last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS
     and a.metric_id = b.metric_id;

   cursor c_get_profiles is
    select max(max_score),
           fnd_profile.value('AS_LEAD_LINK_STATUS'),
           fnd_profile.value('AS_DEAD_LEAD_STATUS')
    from as_sales_lead_ranks_b
    where enabled_flag = 'Y';

   l_max_score number;
   l_link_status varchar2(150);
   l_dead_status varchar2(150);
   l_has_enabled NUMBER;
   l_activity_count number;
BEGIN
   OPEN c_has_leads_quotes_enabled;
   FETCH c_has_leads_quotes_enabled INTO l_has_enabled, l_activity_count;
   CLOSE c_has_leads_quotes_enabled;

   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_Leads_Opps','Enabled Count='||l_has_enabled,
                'Activity Count='||l_activity_count);
   END IF;

   IF l_has_enabled > 0 THEN

      OPEN c_get_profiles;
      fetch c_get_profiles into l_max_score, l_link_status, l_dead_status;
      close c_get_profiles;

      SELECT NVL(actual_value, 0), activity_metric_id
      BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
      FROM
        (SELECT COUNT(decode(metric_sub_category,null,sales_lead_id,
          G_TOP_LEAD_ID,decode(lead_rank_score,l_max_score,1,null),
          G_ACCEPTED_LEAD_ID,decode(accepted_flag,G_IS_ACCEPTED,1,null),
          G_OPP_CONVERSION_ID,decode(x.status_code,l_link_status,1,null),
          G_DEAD_LEAD_ID,decode(x.status_code,l_dead_status,1,null))) actual_value,
           AL.activity_metric_id, AL.func_actual_value
        FROM
           (SELECT c.arc_source_code_for, c.source_code_for_id,
                   x.sales_lead_id, x.lead_rank_score,
                   NVL(X.ACCEPT_FLAG,G_NOT_ACCEPTED) accepted_flag,
                   X.status_code
            FROM  as_sales_leads X, as_statuses_b  Y,
                  (select distinct c.source_code_id,
                          c.arc_source_code_for, c.source_code_for_id
                  FROM ams_source_codes  C,
                  ams_metrics_all_b b, ams_act_metrics_all a
              where a.metric_id = b.metric_id
              AND c.arc_source_code_for = a.arc_act_metric_used_by
              and c.source_code_for_id = a.act_metric_used_by_id
              and b.enabled_flag = G_IS_ENABLED
              and b.metric_id in (83,84,85,88,89, -- Leads
                     294,295,296,297,298, -- Top Leads
                     274,275,276,277,278, -- Leads Accepted
                     284,285,286,287,288, -- Leads to Opps
                     264,265,266,267,268) -- Dead Leads
              and a.last_calculated_date > l_today - G_CALC_LAG_DAYS) c
            WHERE X.status_code = Y.status_code
              AND  Y.lead_flag = G_IS_LEAD
              AND  Y.enabled_flag = G_IS_ENABLED
              AND  NVL(X.DELETED_FLAG,G_NOT_DELETED) <> G_IS_DELETED
              AND source_promotion_id = c.source_code_id
            ) X,
           ams_act_metrics_all AL, ams_metrics_all_b ALB
        WHERE AL.arc_act_metric_used_by = X.arc_source_code_for(+)
        AND AL.act_metric_used_by_id = X.source_code_for_id(+)
        AND AL.metric_id = ALB.metric_id
        AND ALB.metric_id in (83,84,85,88,89, -- Leads
                     294,295,296,297,298, -- Top Leads
                     274,275,276,277,278, -- Leads Accepted
                     284,285,286,287,288, -- Leads to Opps
                     264,265,266,267,268) -- Dead Leads
        and nvl(al.last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS
        AND ALB.enabled_flag = G_IS_ENABLED
        GROUP BY AL.activity_metric_id, AL.func_actual_value
    UNION ALL
        --R9 Campaign Schedule/Opportunities
        SELECT
         COUNT(X.lead_id) actual_value, AL.activity_metric_id,
           AL.func_actual_value
        FROM
           ams_source_codes  C,
           as_leads_all X,
           ams_act_metrics_all AL, ams_metrics_all_b ALB
         WHERE X.source_promotion_id(+) = C.source_code_id
         AND AL.ARC_ACT_METRIC_USED_BY = C.arc_source_code_for
         AND AL.metric_id = ALB.metric_id
         AND AL.act_metric_used_by_id = C.source_code_for_id
         AND ALB.metric_id in (93,94,95,98,99)  -- Opportunities
         AND ALB.enabled_flag = G_IS_ENABLED
         and nvl(al.last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS
         GROUP BY  AL.activity_metric_id, AL.func_actual_value
        )
      WHERE NVL(actual_value,0) <> NVL(func_actual_value,-1)
      ;

      -- Save all calculation upto this point.
      update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
      l_activity_metric_id_table.DELETE;
      l_actual_values_table.DELETE;

   END IF;

END;

-- NAME
--     Calculate_Orders
--
-- PURPOSE
--     Bulk collect the orders from source tables.
--
-- HISTORY
-- 05-Jan-2005   dmvincen   Created from calculate_seeded_metrics.
-- 05-Jan-2005   dmvincen   Added enabled metric checks.
--
PROCEDURE Calculate_Orders
IS
   l_actual_values_table num_table_type;
   l_activity_metric_id_table num_table_type;
   l_today date := sysdate;
   cursor c_has_orders_enabled IS
     SELECT count(distinct a.metric_id) metric_count,
            count(activity_metric_id) activity_count
     FROM ams_metrics_all_b b, ams_act_metrics_all a
     WHERE b.metric_id in (155,156,157,158,159, -- Orders
          103,104,105,108,109, -- Orders amount
          233,234,235,236,237, -- Booked Revenue
          220,221,222,224,225) -- Invoiced Revenue
     AND enabled_flag = G_IS_ENABLED
     and a.metric_id = b.metric_id
--     and a.last_calculated_date > l_today - G_CALC_LAG_DAYS
     and NVL(A.LAST_CALCULATED_DATE,l_today) > l_today - G_CALC_LAG_DAYS ;

   l_has_enabled NUMBER;
   l_activity_count number;
BEGIN
   OPEN c_has_orders_enabled;
   FETCH c_has_orders_enabled INTO l_has_enabled, l_activity_count;
   CLOSE c_has_orders_enabled;

   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_Orders','Enabled Count='||l_has_enabled,
                'Activity Count='||l_activity_count);
   END IF;

   IF l_has_enabled > 0 THEN

      SELECT NVL(actual_value, 0), activity_metric_id
      BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
      FROM
        (SELECT
          DECODE(DECODE(METRIC_CATEGORY,G_REVENUE_ID,
                       METRIC_SUB_CATEGORY,METRIC_CATEGORY)
           , G_ORDER_COUNT_ID , ORDER_COUNT
           , G_ORDER_AMOUNT_ID , BOOKED_REVENUE
           , G_BOOKED_ID , BOOKED_REVENUE
           , G_INVOICED_ID , INVOICED_REVENUE
           , 0 ) ACTUAL_VALUE, ACTIVITY_METRIC_ID, FUNC_ACTUAL_VALUE
       FROM
          (SELECT ARC_SOURCE_CODE_FOR, SOURCE_CODE_FOR_ID,
          COUNT(DISTINCT H.HEADER_ID) ORDER_COUNT,
          SUM(AMS_ACTMETRICS_SEED_PVT.CONVERT_CURRENCY(CURRENCY_CODE, BOOKED_REVENUE)) BOOKED_REVENUE,
          SUM(AMS_ACTMETRICS_SEED_PVT.CONVERT_CURRENCY(CURRENCY_CODE, INVOICED_REVENUE)) INVOICED_REVENUE
          FROM
            (SELECT H.ARC_SOURCE_CODE_FOR, H.SOURCE_CODE_FOR_ID, H.HEADER_ID,
              SUM(NVL(H.UNIT_SELLING_PRICE * H.ORDERED_QUANTITY,0)) BOOKED_REVENUE,
              SUM(NVL(H.UNIT_SELLING_PRICE * ABS(H.INVOICED_QUANTITY),0)) INVOICED_REVENUE,
              H.CURRENCY_CODE
              FROM
                (SELECT C.ARC_SOURCE_CODE_FOR, C.SOURCE_CODE_FOR_ID,
                       I.LINE_ID, I.UNIT_SELLING_PRICE,
                 DECODE(H.FLOW_STATUS_CODE, G_BOOKED, H.HEADER_ID, NULL) HEADER_ID,
                 DECODE(H.FLOW_STATUS_CODE, G_BOOKED, I.ORDERED_QUANTITY, 0) ORDERED_QUANTITY,
                 I.INVOICED_QUANTITY,
                 NVL(H.TRANSACTIONAL_CURR_CODE,G_FUNC_CURRENCY) CURRENCY_CODE
                FROM OE_ORDER_HEADERS_ALL H, OE_ORDER_LINES_ALL I,
               (SELECT DISTINCT ARC_SOURCE_CODE_FOR, SOURCE_CODE_FOR_ID, SOURCE_CODE_ID
               FROM AMS_SOURCE_CODES C, AMS_ACT_METRICS_ALL A, AMS_METRICS_ALL_B B
               WHERE A.ARC_ACT_METRIC_USED_BY = C.ARC_SOURCE_CODE_FOR
               AND A.ACT_METRIC_USED_BY_ID = C.SOURCE_CODE_FOR_ID
               AND A.METRIC_ID = B.METRIC_ID
               AND DECODE(B.METRIC_CATEGORY,G_REVENUE_ID,
               B.METRIC_SUB_CATEGORY,B.METRIC_CATEGORY) IN
               (G_ORDER_COUNT_ID,G_ORDER_AMOUNT_ID,G_BOOKED_ID, G_INVOICED_ID)
               AND B.FUNCTION_NAME LIKE '%'|| G_FUNCTION_NAME
               AND B.METRIC_CALCULATION_TYPE = G_FUNCTION
               AND B.ENABLED_FLAG = G_IS_ENABLED
               AND NVL(A.LAST_CALCULATED_DATE,l_today) > l_today - G_CALC_LAG_DAYS
               ) C
                WHERE H.HEADER_ID = I.HEADER_ID(+)
                AND  H.BOOKED_FLAG = G_BOOKED_FLAG
                AND  H.BOOKED_DATE IS NOT NULL
                AND  H.MARKETING_SOURCE_CODE_ID = C.SOURCE_CODE_ID
                AND  EXISTS (
                   SELECT 1 FROM DUAL WHERE H.FLOW_STATUS_CODE = G_BOOKED
                   UNION ALL
                   SELECT /*+ FIRST_ROWS */ 1
                   FROM OE_SYSTEM_PARAMETERS_ALL OSPA, MTL_SYSTEM_ITEMS_B ITEM
                   WHERE H.ORG_ID = OSPA.ORG_ID
                   AND I.INVENTORY_ITEM_ID = ITEM.INVENTORY_ITEM_ID
                   AND NVL(I.SHIP_FROM_ORG_ID, OSPA.MASTER_ORGANIZATION_ID) = ITEM.ORGANIZATION_ID
                   and rownum = 1
                   )
                ) H
          GROUP BY H.ARC_SOURCE_CODE_FOR, H.SOURCE_CODE_FOR_ID,
                   H.HEADER_ID,H.CURRENCY_CODE
       ) H
       GROUP BY ARC_SOURCE_CODE_FOR, SOURCE_CODE_FOR_ID) T,
       AMS_ACT_METRICS_ALL AL, AMS_METRICS_ALL_B ALB
    WHERE AL.ARC_ACT_METRIC_USED_BY = T.ARC_SOURCE_CODE_FOR(+)
    AND   AL.ACT_METRIC_USED_BY_ID = T.SOURCE_CODE_FOR_ID(+)
    AND   AL.METRIC_ID = ALB.METRIC_ID
    AND   DECODE(METRIC_CATEGORY,G_REVENUE_ID,
                 METRIC_SUB_CATEGORY,METRIC_CATEGORY) IN
      (G_ORDER_COUNT_ID,G_ORDER_AMOUNT_ID,G_BOOKED_ID, G_INVOICED_ID)
    AND   ALB.FUNCTION_NAME LIKE '%'|| G_FUNCTION_NAME
    AND   ALB.METRIC_CALCULATION_TYPE = G_FUNCTION
    AND   ALB.ENABLED_FLAG = G_IS_ENABLED
     AND NVL(AL.LAST_CALCULATED_DATE,l_today) > l_today - G_CALC_LAG_DAYS
             )
      WHERE NVL(actual_value,0) <> NVL(func_actual_value,-1)
      ;

      -- Save all calculation upto this point.
      update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
      l_activity_metric_id_table.DELETE;
      l_actual_values_table.DELETE;

   END IF;

END;

-- NAME
--     Calculate_Responses
--
-- PURPOSE
--     Bulk collect the responses from source tables.
--
-- HISTORY
-- 05-Jan-2005   dmvincen   Created from calculate_seeded_metrics.
-- 05-Jan-2005   dmvincen   Added enabled metric checks.
--
PROCEDURE Calculate_Responses
IS

   l_actual_values_table num_table_type;
   l_activity_metric_id_table num_table_type;
   l_today DATE := sysdate;
   cursor c_has_responses_enabled IS
     SELECT count(distinct b.metric_id) metric_count,
            count(activity_metric_id) activity_count
     FROM ams_metrics_all_b b, ams_act_metrics_all a
     WHERE b.metric_id in (165,166,167,168,169)
     AND enabled_flag = G_IS_ENABLED
     AND a.metric_id = b.metric_id
     AND NVL(A.LAST_CALCULATED_DATE,l_today) > l_today - G_CALC_LAG_DAYS;

   l_has_enabled NUMBER;
   l_activity_count NUMBER;
BEGIN
   OPEN c_has_responses_enabled;
   FETCH c_has_responses_enabled INTO l_has_enabled, l_activity_count;
   CLOSE c_has_responses_enabled;

   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_Responses','Enabled Count='||l_has_enabled,
                'Activity Count='||l_activity_count);
   END IF;

   IF l_has_enabled > 0 THEN

      SELECT NVL(actual_value, 0), activity_metric_id
      BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
      FROM
        (
         -- R9 Campaigns/Response Count
      SELECT COUNT(distinct  Z.party_id) actual_value,
             AL.activity_metric_id, AL.func_actual_value
         FROM
           (select  arc_source_code_for, source_code_for_id, party_id
          from jtf_ih_interactions Z, ams_source_codes  C,
               ams_act_metrics_all a, ams_metrics_all_b b
          where c.arc_source_code_for = a.arc_act_metric_used_by
          AND  c.source_code_for_id = a.act_metric_used_by_id
          AND  a.metric_id = b.metric_id
          and  b.metric_id in (168,169,165,166,167)
          AND  NVL(a.last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS
           AND  b.enabled_flag = G_IS_ENABLED
           and  z.source_code_id = c.source_code_id
           and exists (select 1 from jtf_ih_results_b Y
               where y.result_id = z.result_id
               and rownum = 1
               and positive_response_flag = G_POSITIVE_RESPONSE)
          ) Z,
          ams_act_metrics_all AL, ams_metrics_all_b ALB
      WHERE AL.act_metric_used_by_id = Z.source_code_for_id(+)
      AND   AL.ARC_ACT_METRIC_USED_BY = Z.arc_source_code_for(+)
      AND   AL.metric_id = ALB.metric_id
      and   ALB.metric_id in (168,169,165,166,167)
      AND   NVL(AL.last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS
      AND   ALB.enabled_flag = G_IS_ENABLED
      GROUP BY AL.activity_metric_id, AL.func_actual_value
         )
      WHERE NVL(actual_value,0) <> NVL(func_actual_value,-1)
      ;

      -- Save all calculation upto this point.
      update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
      l_activity_metric_id_table.DELETE;
      l_actual_values_table.DELETE;

   END IF;
END;

-- NAME
--     Calculate_Registrants
--
-- PURPOSE
--     Bulk collect the registrants from source tables.
--
-- HISTORY
-- 05-Jan-2005   dmvincen   Created from calculate_seeded_metrics.
-- 05-Jan-2005   dmvincen   Added enabled metric checks.
--
PROCEDURE Calculate_Registrants
IS
   l_actual_values_table num_table_type;
   l_activity_metric_id_table num_table_type;
   l_today DATE := sysdate;

   cursor c_has_registrations_enabled IS
     SELECT count(distinct b.metric_id) metric_count,
            count(activity_metric_id) activity_count
     FROM ams_metrics_all_b b, ams_act_metrics_all a
     WHERE b.metric_id in (123,124,127, -- Registrants
              143,144,147, -- Cancellations
            133,134,137) -- Attendees
     AND enabled_flag = G_IS_ENABLED
     AND a.metric_id = b.metric_id
     AND NVL(A.last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS;

   l_has_enabled NUMBER;
   l_activity_count NUMBER;
BEGIN
   OPEN c_has_registrations_enabled;
   FETCH c_has_registrations_enabled INTO l_has_enabled, l_activity_count;
   CLOSE c_has_registrations_enabled;

   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_Registrants','Enabled Count='||l_has_enabled,
                'Activity Count='||l_activity_count);
   END IF;

   IF l_has_enabled > 0 THEN

     SELECT NVL(actual_value, 0), activity_metric_id
     BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
     FROM
        (
   --Campaign schedule of type events registrants, attendees, cancellations.
   --And Event schedule and One-off event registrants, attendees, cancellations.
      select SUM(decode(metric_category,909,registered,
                 910,attendee,911,cancelled,0)) actual_value,
             activity_metric_id, func_actual_value
      from (
      select sum(decode(system_status_code,'REGISTERED',1,0)) registered,
             sum(decode(system_status_code||':'||attended_flag,'REGISTERED:Y',1,0)) attendee,
             sum(decode(system_status_code,'CANCELLED',1,0)) cancelled,
             object_id, object_type
      from ams_event_registrations r,
          (select distinct act_metric_used_by_id event_offer_id,
                  act_metric_used_by_id object_id,
                  arc_act_metric_used_by object_type
           from ams_act_metrics_all a, ams_metrics_all_b b
           where a.metric_id = b.metric_id
              AND   b.metric_id in (123,124,133,134,143,144)
              AND   b.enabled_flag = G_IS_ENABLED
              AND   NVL(A.last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS
          UNION ALL
           select distinct related_event_id, act_metric_used_by_id object_id,
                  arc_act_metric_used_by object_type
           from ams_act_metrics_all a, ams_metrics_all_b b,
                ams_campaign_schedules_b c
           where a.metric_id = b.metric_id
              AND   b.metric_id in (127,137,147)
              AND   b.enabled_flag = G_IS_ENABLED
              AND   NVL(A.last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS
              AND   c.schedule_id = a.act_metric_used_by_id
              AND   c.activity_type_code = G_ACTIVITY_EVENTS
          ) A
        where r.event_offer_id = a.event_offer_id
        group by object_id, object_type
      ) A,
          AMS_ACT_METRICS_ALL AL, AMS_METRICS_ALL_B ALB
      where AL.arc_act_metric_used_by = a.object_type(+)
      AND   AL.act_metric_used_by_id = a.object_id(+)
      and al.metric_id = alb.metric_id
      AND   ALB.metric_id in (127,137,147,123,124,133,134,143,144)
      AND   ALB.enabled_flag = G_IS_ENABLED
      AND   NVL(AL.last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS
      group by activity_metric_id, func_actual_value
      )
      WHERE NVL(actual_value,0) <> NVL(func_actual_value,-1)
      ;

      -- Save all calculation upto this point.
      update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
      l_activity_metric_id_table.DELETE;
      l_actual_values_table.DELETE;

   END IF;

END;

-- NAME
--     Calculate_Quotes
--
-- PURPOSE
--     Bulk collect the quotes from source tables.
--
-- HISTORY
-- 05-Jan-2005   dmvincen   Created from calculate_seeded_metrics.
-- 05-Jan-2005   dmvincen   Added enabled metric checks.
-- 05-Jan-2006   dmvincen   Seperated getting source code id.
--
PROCEDURE Calculate_Quotes(
          p_arc_act_metric_used_by VARCHAR2,
          p_act_metric_used_by_id NUMBER)
IS
   l_actual_values_table num_table_type;
   l_activity_metric_id_table num_table_type;
   cursor c_has_quotes_enabled(p_object_type VARCHAR2,
                               p_object_id NUMBER) IS
     SELECT count(distinct b.metric_id) metric_count,
            count(a.activity_metric_id) activity_count
     FROM ams_metrics_all_b b, ams_act_metrics_all a
     WHERE b.metric_id in (244,245,246,247,248,254,255,256,257,258)
     AND enabled_flag = G_IS_ENABLED
     AND arc_act_metric_used_by = p_object_type
     AND act_metric_used_by_id = p_object_id
     AND a.metric_id = b.metric_id;

   -- BUG4924982: Get source code id in a seperate step.
   CURSOR c_get_source_code_id (p_object_type VARCHAR2,
                               p_object_id NUMBER) IS
         select c.source_code_id
            from ams_act_metrics_all AL, ams_metrics_all_b ALB,
                ams_source_codes c
            where   AL.ARC_ACT_METRIC_USED_BY = C.arc_source_code_for
              AND   AL.act_metric_used_by_id = C.source_code_for_id
              AND   AL.metric_id = ALB.metric_id
              AND   ALB.metric_id in (244,245,246,247,248,254,255,256,257,258)
              AND   ALB.enabled_flag = 'Y'
              AND   AL.ACT_METRIC_USED_BY_ID = p_object_id
              AND   AL.arc_act_metric_used_by = p_object_type
              AND   rownum = 1
           ;

   l_has_enabled NUMBER;
   l_activity_count NUMBER;
   l_source_code_id NUMBER;
BEGIN
   OPEN c_has_quotes_enabled(p_arc_act_metric_used_by,
                                 p_act_metric_used_by_id);
   FETCH c_has_quotes_enabled INTO l_has_enabled, l_activity_count;
   CLOSE c_has_quotes_enabled;

   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_Quotes','Enabled Count='||l_has_enabled,
                'Activity Count='||l_activity_count);
   END IF;

   IF l_has_enabled > 0 THEN

     OPEN c_get_source_code_id(p_arc_act_metric_used_by,
                               p_act_metric_used_by_id);
     FETCH c_get_source_code_id INTO l_source_code_id;
     CLOSE c_get_source_code_id;

     SELECT NVL(actual_value, 0), activity_metric_id
     BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
     FROM
       (SELECT decode(metric_category,914,quote_count,
                915,quote_amount,0) actual_value,
               activity_metric_id, func_actual_value
       FROM(
         SELECT count(G.quote_header_id) quote_count,
          sum(convert_currency(nvl(currency_code,G_FUNC_CURRENCY),
                      total_list_price + total_adjusted_amount)) quote_amount,
                marketing_source_code_id
         FROM   aso_quote_headers_all G
         WHERE  G.marketing_source_code_id = l_source_code_id
          and quote_version = (select max(quote_version)
                               from aso_quote_headers_all
                               where quote_number = g.quote_number)
          GROUP BY marketing_source_code_id
         ) quotes,
           ams_act_metrics_all AL, ams_metrics_all_b ALB,
           ams_source_codes c
       where   quotes.marketing_source_code_id(+) = c.source_code_id
         AND   AL.ARC_ACT_METRIC_USED_BY = C.arc_source_code_for
         AND   AL.act_metric_used_by_id = C.source_code_for_id
         AND   AL.metric_id = ALB.metric_id
         AND   ALB.metric_id in (244,245,246,247,248,254,255,256,257,258)
         AND   ALB.enabled_flag = 'Y'
         AND   AL.ACT_METRIC_USED_BY_ID = p_act_metric_used_by_id
         AND   AL.arc_act_metric_used_by = P_ARC_ACT_METRIC_USED_BY
      ) C
     WHERE NVL(actual_value,0) <> NVL(func_actual_value,-1)
     ;

      -- Save all calculation upto this point.
      update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
      l_activity_metric_id_table.DELETE;
      l_actual_values_table.DELETE;

    END IF;

END;

-- NAME
--     Calculate_Leads_Opps
--
-- PURPOSE
--     Bulk collect the leads and opportunities from source tables.
--
-- HISTORY
-- 05-Jan-2005   dmvincen   Created from calculate_seeded_metrics.
-- 05-Jan-2005   dmvincen   Added enabled metric checks.
--
PROCEDURE Calculate_Leads_Opps(
          p_arc_act_metric_used_by VARCHAR2,
          p_act_metric_used_by_id NUMBER)
IS
   l_actual_values_table num_table_type;
   l_activity_metric_id_table num_table_type;
   cursor c_has_leads_opps_enabled(p_object_type VARCHAR2,
          p_object_id NUMBER) IS
     SELECT count(distinct b.metric_id) metric_count,
            count(activity_metric_id) activity_count
     FROM ams_metrics_all_b b, ams_act_metrics_all a
     WHERE b.metric_id in (264,265,266,267,268, -- Dead leads
           83,84,85,88,89, -- Leads
           274,275,276,277,278, -- Leads Accepted
           284,285,286,287,288, -- Leads to Opportunities
           294,295,296,297,298,  -- Top Leads
           93,94,95,98,99)  -- Opportunities
     AND enabled_flag = G_IS_ENABLED
     AND arc_act_metric_used_by = p_object_type
     AND act_metric_used_by_id = p_object_id
     AND a.metric_id = b.metric_id;

   cursor c_get_profiles is
    select max(max_score),
           fnd_profile.value('AS_LEAD_LINK_STATUS'),
           fnd_profile.value('AS_DEAD_LEAD_STATUS')
    from as_sales_lead_ranks_b
    where enabled_flag = 'Y';

   l_max_score number;
   l_link_status varchar2(150);
   l_dead_status varchar2(150);
   l_has_enabled NUMBER;
   l_activity_count number;
BEGIN
   OPEN c_has_leads_opps_enabled(p_arc_act_metric_used_by,
                                 p_act_metric_used_by_id);
   FETCH c_has_leads_opps_enabled INTO l_has_enabled, l_activity_count;
   CLOSE c_has_leads_opps_enabled;

   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_Leads_Opps','Enabled Count='||l_has_enabled,
                'Activity Count='||l_activity_count);
   END IF;

   IF l_has_enabled > 0 THEN

      OPEN c_get_profiles;
      FETCH c_get_profiles INTO l_max_score, l_link_status, l_dead_status;
      close c_get_profiles;

      SELECT NVL(actual_value, 0), activity_metric_id
      BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
      FROM (
        SELECT COUNT(decode(metric_sub_category,null,sales_lead_id,
          G_TOP_LEAD_ID,decode(lead_rank_score,l_max_score,1,null),
          G_ACCEPTED_LEAD_ID,decode(accepted_flag,G_IS_ACCEPTED,1,null),
          G_OPP_CONVERSION_ID,decode(x.status_code,l_link_status,1,null),
          G_DEAD_LEAD_ID,decode(x.status_code,l_dead_status,1,null))) actual_value,
           AL.activity_metric_id, AL.func_actual_value
        FROM
           (SELECT c.arc_source_code_for, c.source_code_for_id,
                   x.sales_lead_id, x.lead_rank_score,
                   NVL(X.ACCEPT_FLAG,G_NOT_ACCEPTED) accepted_flag,
                   X.status_code
            FROM  as_sales_leads X, as_statuses_b  Y,
                  (select distinct c.source_code_id,
                          c.arc_source_code_for, c.source_code_for_id
                  FROM ams_source_codes  C,
                  ams_metrics_all_b b, ams_act_metrics_all a
              where a.metric_id = b.metric_id
              AND c.arc_source_code_for = a.arc_act_metric_used_by
              and c.source_code_for_id = a.act_metric_used_by_id
              and b.enabled_flag = G_IS_ENABLED
              and b.metric_id in (83,84,85,88,89, -- Leads
                     294,295,296,297,298, -- Top Leads
                     274,275,276,277,278, -- Leads Accepted
                     284,285,286,287,288, -- Leads to Opps
                     264,265,266,267,268) -- Dead Leads
              AND  C.arc_source_code_for = p_arc_act_metric_used_by
              AND  C.source_code_for_id = p_act_metric_used_by_id
              ) c
            WHERE X.status_code = Y.status_code
              AND  Y.lead_flag = G_IS_LEAD
              AND  Y.enabled_flag = G_IS_ENABLED
              AND  NVL(X.DELETED_FLAG,G_NOT_DELETED) <> G_IS_DELETED
              AND X.source_promotion_id = c.source_code_id
            ) X,
           ams_act_metrics_all AL, ams_metrics_all_b ALB
        WHERE AL.arc_act_metric_used_by = X.arc_source_code_for(+)
        AND AL.act_metric_used_by_id = X.source_code_for_id(+)
        AND AL.metric_id = ALB.metric_id
        AND ALB.metric_id in (83,84,85,88,89, -- Leads
                     294,295,296,297,298, -- Top Leads
                     274,275,276,277,278, -- Leads Accepted
                     284,285,286,287,288, -- Leads to Opps
                     264,265,266,267,268) -- Dead Leads
        AND  AL.ACT_METRIC_USED_BY_ID = p_act_metric_used_by_id
        AND  AL.ARC_ACT_METRIC_USED_BY = p_arc_act_metric_used_by
        AND ALB.enabled_flag = G_IS_ENABLED
        GROUP BY AL.activity_metric_id, AL.func_actual_value
    UNION ALL
        --R9 Campaign Schedule/Opportunities
        SELECT
         COUNT(X.lead_id) actual_value, AL.activity_metric_id,
           AL.func_actual_value
        FROM
           ams_source_codes  C,
           as_leads_all X,
           ams_act_metrics_all AL, ams_metrics_all_b ALB
         WHERE X.source_promotion_id(+) = C.source_code_id
         AND AL.ARC_ACT_METRIC_USED_BY = C.arc_source_code_for
         AND AL.metric_id = ALB.metric_id
         AND AL.act_metric_used_by_id = C.source_code_for_id
         AND ALB.metric_id in (93,94,95,98,99)  -- Opportunities
         AND ALB.enabled_flag = G_IS_ENABLED
         AND  AL.ACT_METRIC_USED_BY_ID = p_act_metric_used_by_id
         AND  AL.ARC_ACT_METRIC_USED_BY = p_arc_act_metric_used_by
         GROUP BY  AL.activity_metric_id, AL.func_actual_value
        )
      WHERE NVL(actual_value,0) <> NVL(func_actual_value,-1)
      ;

      -- Save all calculation upto this point.
      update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
      l_activity_metric_id_table.DELETE;
      l_actual_values_table.DELETE;

    END IF;
END;

-- NAME
--     Calculate_Orders
--
-- PURPOSE
--     Bulk collect the orders from source tables.
--
-- HISTORY
-- 05-Jan-2005   dmvincen   Created from calculate_seeded_metrics.
-- 05-Jan-2005   dmvincen   Added enabled metric checks.
--
PROCEDURE Calculate_Orders(
          p_arc_act_metric_used_by VARCHAR2,
          p_act_metric_used_by_id NUMBER)
IS
   l_actual_values_table num_table_type;
   l_activity_metric_id_table num_table_type;
   cursor c_has_orders_enabled(p_object_type VARCHAR2,
                               p_object_id NUMBER) IS
     SELECT count(distinct b.metric_id) metric_count,
            count(activity_metric_id) activity_count
     FROM ams_metrics_all_b b, ams_act_metrics_all a
     WHERE b.metric_id in (155,156,157,158,159, -- Orders
          103,104,105,108,109, -- Orders amount
          233,234,235,236,237, -- Booked Revenue
          220,221,222,224,225) -- Invoiced Revenue
     AND enabled_flag = G_IS_ENABLED
     AND arc_act_metric_used_by = p_object_type
     AND act_metric_used_by_id = p_object_id
     AND a.metric_id = b.metric_id;

   l_has_enabled NUMBER;
   l_activity_count NUMBER;
BEGIN
   OPEN c_has_orders_enabled(p_arc_act_metric_used_by,
                             p_act_metric_used_by_id);
   FETCH c_has_orders_enabled INTO l_has_enabled, l_activity_count;
   CLOSE c_has_orders_enabled;

   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_Orders','Enabled Count='||l_has_enabled,
                'Activity Count='||l_activity_count);
   END IF;

   IF l_has_enabled > 0 THEN

      SELECT NVL(actual_value, 0), activity_metric_id
      BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
      FROM
        (
         SELECT -- metrics_name,
         decode(decode(metric_category,G_REVENUE_ID,
                      metric_sub_category,metric_category)
          , G_ORDER_COUNT_ID , order_count
          , G_ORDER_AMOUNT_ID , booked_revenue
          , G_BOOKED_ID , booked_revenue
          , G_INVOICED_ID , invoiced_revenue
          , 0 ) actual_value, activity_metric_id, func_actual_value
       FROM
       (SELECT
            arc_source_code_for, source_code_for_id,
            count(DISTINCT h.header_id) order_count,
            sum(convert_currency(currency_code, booked_revenue)) booked_revenue,
            sum(convert_currency(currency_code, invoiced_revenue)) invoiced_revenue
           FROM
              (SELECT H.arc_source_code_for, H.source_code_for_id,
                h.header_id,
                sum(nvl(H.unit_selling_price * H.ordered_quantity,0)) booked_revenue,
                sum(nvl(H.unit_selling_price * abs(H.invoiced_quantity),0)) invoiced_revenue,
                h.currency_code
                FROM
               (SELECT C.arc_source_code_for, C.source_code_for_id,
                      i.line_id, I.unit_selling_price,
                decode(H.flow_status_code, G_BOOKED, H.header_id, NULL) header_id,
                decode(H.flow_status_code, G_BOOKED, I.ordered_quantity, 0) ordered_quantity,
                I.invoiced_quantity,
                nvl(H.transactional_curr_code,G_FUNC_CURRENCY) currency_code
               FROM oe_order_headers_all H, oe_order_lines_all I,
                   ams_source_codes  C
               WHERE H.header_id = I.header_id(+)
               AND  H.booked_flag = G_BOOKED_FLAG
               AND  H.booked_date IS NOT NULL
               AND  H.marketing_source_code_id = C.source_code_id
               AND  EXISTS (
                     SELECT 1 FROM dual WHERE H.flow_status_code = G_BOOKED
                     and rownum = 1
                     UNION ALL
                     SELECT 1 FROM OE_SYSTEM_PARAMETERS_ALL ospa, MTL_SYSTEM_ITEMS_B item
                            WHERE H.org_id = ospa.org_id
                            AND I.inventory_item_id = item.inventory_item_id
                            AND   nvl(I.ship_from_org_id, ospa.master_organization_id) = item.organization_id
                     and rownum = 1
                     )
               AND C.arc_source_code_for = p_arc_act_metric_used_by
               AND C.source_code_for_id = p_act_metric_used_by_id) H
            GROUP BY H.arc_source_code_for, H.source_code_for_id,
                h.header_id,H.currency_code
            ) H
            GROUP BY arc_source_code_for, source_code_for_id) T,
              ams_act_metrics_all AL, ams_metrics_all_b ALB
            WHERE AL.ARC_ACT_METRIC_USED_BY = T.arc_source_code_for(+)
            AND   AL.act_metric_used_by_id = T.source_code_for_id(+)
            AND   AL.metric_id = ALB.metric_id
            AND   ALB.metric_id in (155,156,157,158,159, -- Orders
                   103,104,105,108,109, -- Orders amount
                   233,234,235,236,237, -- Booked Revenue
                   220,221,222,224,225) -- Invoiced Revenue
            AND   ALB.enabled_flag = G_IS_ENABLED
            AND   AL.arc_act_metric_used_by = p_arc_act_metric_used_by
            AND   AL.act_metric_used_by_id = p_act_metric_used_by_id
         )
      WHERE NVL(actual_value,0) <> NVL(func_actual_value,-1)
      ;
      -- Save all calculation upto this point.
      update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
      l_activity_metric_id_table.DELETE;
      l_actual_values_table.DELETE;

    END IF;
END;

-- NAME
--     Calculate_Responses
--
-- PURPOSE
--     Bulk collect the responses from source tables.
--
-- HISTORY
-- 05-Jan-2005   dmvincen   Created from calculate_seeded_metrics.
-- 05-Jan-2005   dmvincen   Added enabled metric checks.
--
PROCEDURE Calculate_Responses(
          p_arc_act_metric_used_by VARCHAR2,
          p_act_metric_used_by_id NUMBER)
IS
   l_actual_values_table num_table_type;
   l_activity_metric_id_table num_table_type;
   cursor c_has_responses_enabled(p_object_type VARCHAR2,
          p_object_id NUMBER) IS
     SELECT count(distinct b.metric_id) metric_count,
            count(activity_metric_id) activity_count
     FROM ams_metrics_all_b b, ams_act_metrics_all a
     WHERE b.metric_id in (165,166,167,168,169)
     AND enabled_flag = G_IS_ENABLED
     AND arc_act_metric_used_by = p_object_type
     AND act_metric_used_by_id = p_object_id
     AND a.metric_id = b.metric_id;

   l_has_enabled NUMBER;
   l_activity_count NUMBER;
BEGIN
   OPEN c_has_responses_enabled(p_arc_act_metric_used_by,
                                p_act_metric_used_by_id);
   FETCH c_has_responses_enabled INTO l_has_enabled, l_activity_count;
   CLOSE c_has_responses_enabled;

   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_Responses','Enabled Count='||l_has_enabled,
                'Activity Count='||l_activity_count);
   END IF;

   IF l_has_enabled > 0 THEN

      SELECT NVL(actual_value, 0), activity_metric_id
      BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
      FROM (
        SELECT actual_value, activity_metric_id
        FROM(
       -- R9 Campaign Schedules/Response Count
           SELECT COUNT(DISTINCT C.party_id) actual_value,
               AL.activity_metric_id, AL.func_actual_value
           FROM
            (SELECT arc_source_code_for, source_code_for_id, party_id
             FROM jtf_ih_interactions Z, ams_source_codes C
             WHERE exists (select 1 from jtf_ih_results_b Y
                    where z.result_id = y.result_id
                    AND y.positive_response_flag = G_POSITIVE_RESPONSE
                    and rownum = 1)
             AND Z.source_code_id = C.source_code_id
             AND C.arc_source_code_for = p_arc_act_metric_used_by
             AND C.source_code_for_id = p_act_metric_used_by_id) C,
            ams_act_metrics_all AL, ams_metrics_all_b ALB
          WHERE AL.act_metric_used_by_id = C.source_code_for_id(+)
          AND   AL.ARC_ACT_METRIC_USED_BY = C.arc_source_code_for(+)
          AND   AL.metric_id = ALB.metric_id
          AND   ALB.metric_id in (165,166,167,168,169)
          AND   ALB.enabled_flag = G_IS_ENABLED
          AND   AL.ACT_METRIC_USED_BY_ID = p_act_metric_used_by_id
          AND   AL.ARC_ACT_METRIC_USED_BY = p_arc_act_metric_used_by
          GROUP BY AL.activity_metric_id, AL.func_actual_value

        )
      WHERE NVL(actual_value,0) <> NVL(func_actual_value,-1)
      );

      -- Save all calculation upto this point.
      update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
      l_activity_metric_id_table.DELETE;
      l_actual_values_table.DELETE;

    END IF;
END;

-- NAME
--     Calculate_Registrants
--
-- PURPOSE
--     Bulk collect the registrants from source tables.
--
-- HISTORY
-- 05-Jan-2005   dmvincen   Created from calculate_seeded_metrics.
-- 05-Jan-2005   dmvincen   Added enabled metric checks.
--
PROCEDURE Calculate_Registrants(
          p_arc_act_metric_used_by VARCHAR2,
          p_act_metric_used_by_id NUMBER)
IS
   l_actual_values_table num_table_type;
   l_activity_metric_id_table num_table_type;
   cursor c_has_registrations_enabled(p_object_type VARCHAR2,
                                      p_object_id NUMBER) IS
     SELECT count(distinct b.metric_id) metric_count,
            count(activity_metric_id) activity_count
     FROM ams_metrics_all_b b, ams_act_metrics_all a
     WHERE b.metric_id in (123,124,127, -- Registrants
              143,144,147, -- Cancellations
            133,134,137) -- Attendees
     AND enabled_flag = G_IS_ENABLED
     AND arc_act_metric_used_by = p_object_type
     AND act_metric_used_by_id = p_object_id
     AND a.metric_id = b.metric_id;

   l_has_enabled NUMBER;
   l_activity_count NUMBER;
BEGIN
   OPEN c_has_registrations_enabled(p_arc_act_metric_used_by,
                                    p_act_metric_used_by_id);
   FETCH c_has_registrations_enabled INTO l_has_enabled, l_activity_count;
   CLOSE c_has_registrations_enabled;

   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_Registrants','Enabled Count='||l_has_enabled,
                'Activity Count='||l_activity_count);
   END IF;

   IF l_has_enabled > 0 THEN

      -- Do campaign schedule specific calculations here.
      IF NVL(p_arc_act_metric_used_by,'NULL') = G_CSCH THEN

         SELECT NVL(actual_value, 0), activity_metric_id
         BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
         FROM
           (
        --Campaign schedule of type events registrants.
      select SUM(decode(metric_category,909,registered,
                 910,attendee,911,cancelled,0)) actual_value,
             activity_metric_id, func_actual_value
      from (
      select sum(decode(system_status_code,'REGISTERED',1,0)) registered,
             sum(decode(system_status_code||':'||attended_flag,'REGISTERED:Y',1,0)) attendee,
             sum(decode(system_status_code,'CANCELLED',1,0)) cancelled,
             object_id, object_type
      from ams_event_registrations r,
          (select distinct related_event_id event_offer_id,
                    act_metric_used_by_id object_id,
                  arc_act_metric_used_by object_type
           from ams_act_metrics_all a, ams_metrics_all_b b, ams_campaign_schedules_b c
           where a.metric_id = b.metric_id
              AND   b.metric_id in (127,137,147)
              AND   a.ARC_ACT_METRIC_USED_BY = G_CSCH
              AND   b.enabled_flag = G_IS_ENABLED
              AND   c.schedule_id = a.act_metric_used_by_id
              AND   c.activity_type_code = G_ACTIVITY_EVENTS
              AND   a.act_metric_used_by_id = p_act_metric_used_by_id
          ) A
        where r.event_offer_id = a.event_offer_id
        group by object_id, object_type
      ) A,
          AMS_ACT_METRICS_ALL AL, AMS_METRICS_ALL_B ALB
      where AL.arc_act_metric_used_by = a.object_type(+)
      AND   AL.act_metric_used_by_id = a.object_id(+)
      AND   al.metric_id = alb.metric_id
      AND   ALB.metric_id in (127,137,147)
      AND   ALB.enabled_flag = G_IS_ENABLED
      AND   AL.act_metric_used_by_id = p_act_metric_used_by_id
      group by activity_metric_id, func_actual_value
        )
      WHERE NVL(actual_value,0) <> NVL(func_actual_value,-1)
      ;

      -- Save all calculation upto this point.
      update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
      l_activity_metric_id_table.DELETE;
      l_actual_values_table.DELETE;

      END IF; -- CSCH only

      IF NVL(p_arc_act_metric_used_by,'NULL') IN (G_EVEO, G_EONE) THEN
         SELECT NVL(actual_value, 0), activity_metric_id
         BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
         FROM (
               --R9 (Event Schedule/One-off Event)/Registrations
      select SUM(decode(metric_category,909,registered,
                 910,attendee,911,cancelled,0)) actual_value,
             activity_metric_id, func_actual_value
      from (
      select sum(decode(system_status_code,'REGISTERED',1,0)) registered,
             sum(decode(system_status_code||':'||attended_flag,'REGISTERED:Y',1,0)) attendee,
             sum(decode(system_status_code,'CANCELLED',1,0)) cancelled,
             object_id, object_type
      from ams_event_registrations r,
          (select distinct act_metric_used_by_id event_offer_id,
                  act_metric_used_by_id object_id,
                  arc_act_metric_used_by object_type
           from ams_act_metrics_all a, ams_metrics_all_b b
           where a.metric_id = b.metric_id
              AND   b.metric_id in (123,124,133,134,143,144)
              AND   a.ARC_ACT_METRIC_USED_BY = p_arc_act_metric_used_by
              AND   b.enabled_flag = G_IS_ENABLED
              AND   a.act_metric_used_by_id = p_act_metric_used_by_id
          ) A
        where r.event_offer_id = a.event_offer_id
        group by object_id, object_type
      ) A,
          AMS_ACT_METRICS_ALL AL, AMS_METRICS_ALL_B ALB
      where AL.arc_act_metric_used_by = a.object_type(+)
        AND   AL.act_metric_used_by_id = a.object_id(+)
        and al.metric_id = alb.metric_id
        AND   ALB.metric_id in (123,124,133,134,143,144)
        AND   ALB.enabled_flag = G_IS_ENABLED
        AND   AL.act_metric_used_by_id = p_act_metric_used_by_id
        AND   AL.ARC_ACT_METRIC_USED_BY = p_arc_act_metric_used_by
      group by activity_metric_id, func_actual_value
      )
         WHERE NVL(actual_value,0) <> NVL(func_actual_value,-1)
      ;

      -- Save all calculation upto this point.
      update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
      l_activity_metric_id_table.DELETE;
      l_actual_values_table.DELETE;

      END IF; -- EVEO EONE only
    END IF;
END;

-- NAME
--     Calculate_Seeded_Metrics
--
-- PURPOSE
--     Bulk collect the metrics from source tables.
--
-- NOTES
--     Only one bulk collect should be executed.
--     Number of orders for events is currently unavailable.
--
-- HISTORY
-- 30-Aug-2001   dmvincen   Created.
-- 24-Oct-2001   dmvincen   Fixed update for existing values.
-- 05-Jan-2005   dmvincen   Broke out queries into smaller procedures.
--

PROCEDURE Calculate_Seeded_Metrics(
          p_arc_act_metric_used_by VARCHAR2 := NULL,
          p_act_metric_used_by_id NUMBER := NULL)
IS
   --l_actual_values_table num_table_type;
   --l_activity_metric_id_table num_table_type;
BEGIN
   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_Seeded_Metrics','BEGIN');
   END IF;
   -- Get all object data to update.
   IF p_arc_act_metric_used_by IS NULL THEN

      Calculate_Quotes;

      Calculate_Leads_Opps;

      Calculate_Orders;

      Calculate_Responses;

      Calculate_Registrants;

   ELSE -- if object type is set.

      Calculate_Quotes(p_arc_act_metric_used_by, p_act_metric_used_by_id);

      Calculate_Leads_Opps(p_arc_act_metric_used_by, p_act_metric_used_by_id);

      Calculate_Orders(p_arc_act_metric_used_by, p_act_metric_used_by_id);

      Calculate_Responses(p_arc_act_metric_used_by, p_act_metric_used_by_id);

   END IF;

   IF NVL(p_arc_act_metric_used_by,'NULL') IN (G_CSCH, G_EONE, G_EVEO) THEN

       Calculate_Registrants(p_arc_act_metric_used_by, p_act_metric_used_by_id);

   END IF; -- CSCH EVEO EONE only

   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_Seeded_Metrics','END');
   END IF;

END Calculate_Seeded_Metrics;

-- NAME
--     Calculate_Target_Group
--
-- PURPOSE
--     Bulk collect the target group counts into metrics.
--
-- HISTORY
-- 05-Aug-2003   sunkumar created.
-- 05-Jan-2005   dmvincen Checking for Enabled metrics.
--
--

PROCEDURE Calculate_Target_Group(
          p_arc_act_metric_used_by VARCHAR2 := NULL,
          p_act_metric_used_by_id NUMBER := NULL)
IS
   l_actual_values_table num_table_type;
   l_activity_metric_id_table num_table_type;
   l_today DATE := sysdate;
   cursor c_has_traget_enabled IS
     SELECT count(distinct a.metric_id) metric_count,
            count(activity_metric_id) activity_count
     FROM ams_metrics_all_b b, ams_act_metrics_all a
     WHERE b.metric_id in (304,305,306,307,308, -- Contact Group
                       314,315,316,317,318)  -- Control Group
     AND enabled_flag = G_IS_ENABLED
     AND a.metric_id = b.metric_id
     AND NVL(last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS;

   cursor c_has_traget_enabled_obj(p_object_type VARCHAR2,
                                   p_object_id NUMBER) IS
     SELECT count(distinct a.metric_id) metric_count,
            count(activity_metric_id) activity_count
     FROM ams_metrics_all_b b, ams_act_metrics_all a
     WHERE b.metric_id in (304,305,306,307,308, -- Contact Group
                       314,315,316,317,318)  -- Control Group
     AND enabled_flag = G_IS_ENABLED
     AND arc_act_metric_used_by = p_object_type
     AND act_metric_used_by_id = p_object_id
     AND a.metric_id = b.metric_id;

   l_has_enabled NUMBER;
   l_activity_count NUMBER;
BEGIN
   -- Get all object data to update.
   IF p_arc_act_metric_used_by IS NULL THEN

      OPEN c_has_traget_enabled;
      FETCH c_has_traget_enabled INTO l_has_enabled, l_activity_count;
      CLOSE c_has_traget_enabled;

      IF AMS_DEBUG_HIGH_ON THEN
         Write_Log('Calculate_Target_Group','Enabled Count='||l_has_enabled,
                   'Activity Count='||l_activity_count);
      END IF;

      IF l_has_enabled > 0 THEN

         SELECT NVL(actual_value, 0) actual_value, activity_metric_id
         BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
         FROM
           (
            --R10 contact/control group count
            SELECT SUM(NVL (decode(ALB.metric_sub_category,
              G_CONTACT_GROUP_ID, ACT.no_of_rows_active,
              G_CONTROL_GROUP_ID, ACT.no_of_rows_in_ctrl_group,0),0)) actual_value,
              AL.activity_metric_id,AL.func_actual_value
            FROM
            (SELECT al.activity_metric_id,
                   alh.no_of_rows_active, alh.no_of_rows_in_ctrl_group
             FROM ams_list_headers_all ALH, ams_act_metrics_all al,
                  ams_metrics_all_b alb
             WHERE ALH.arc_list_used_by = al.arc_act_metric_used_by
             AND   ALH.list_used_by_id = al.act_metric_used_by_id
             AND   al.metric_id = alb.metric_id
             and   alb.metric_id in (304,305,306,307,308,   -- Contact Group
                                    314,315,316,317,318)   -- Control Group
             and   alb.enabled_flag = 'Y'
             AND NVL(last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS
             ) ACT,
             ams_act_metrics_all AL, ams_metrics_all_b ALB
           WHERE  ACT.activity_metric_id(+) = AL.activity_metric_id
            AND   AL.metric_id=ALB.METRIC_ID
            AND   ALB.metric_id in (304,305,306,307,308,   -- Contact Group
                                    314,315,316,317,318)  -- Control Group
            AND   ALB.metric_category = G_TARGET_GROUP_ID
            AND   ALB.metric_sub_category in
                       (G_CONTACT_GROUP_ID,G_CONTROL_GROUP_ID)
            AND   ALB.function_name LIKE '%'|| G_TARGET_FUNCTION_NAME
            AND   ALB.metric_calculation_type = G_FUNCTION
            AND   ALB.enabled_flag = G_IS_ENABLED
            AND NVL(last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS
            GROUP BY AL.activity_metric_id, AL.func_actual_value
           )
         WHERE NVL(actual_value,0) <> NVL(func_actual_value,-1)
         ;

         update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
         l_activity_metric_id_table.DELETE;
         l_actual_values_table.DELETE;

      END IF;
  -- ELSIF p_arc_act_metric_used_by = G_CSCH THEN
    ELSE -- IF object is specified, all object types supported.

      OPEN c_has_traget_enabled_obj(p_arc_act_metric_used_by,
                                    p_act_metric_used_by_id);
      FETCH c_has_traget_enabled_obj INTO l_has_enabled, l_activity_count;
      CLOSE c_has_traget_enabled_obj;

      IF AMS_DEBUG_HIGH_ON THEN
         Write_Log('Calculate_Target_Group','Enabled Count='||l_has_enabled,
                   'Activity Count='||l_activity_count);
      END IF;

      IF l_has_enabled > 0 THEN

         SELECT NVL(actual_value, 0) actual_value, activity_metric_id
         BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
         FROM
           (
            --R10 contact/control group count
            SELECT SUM(NVL (decode(ALB.metric_sub_category,
              G_CONTACT_GROUP_ID, ACT.no_of_rows_active,
              G_CONTROL_GROUP_ID, ACT.no_of_rows_in_ctrl_group,0),0)) actual_value,
              AL.activity_metric_id,AL.func_actual_value
            FROM
            (SELECT al.activity_metric_id,
                   alh.no_of_rows_active, alh.no_of_rows_in_ctrl_group
             FROM ams_list_headers_all ALH, ams_act_metrics_all al,
                  ams_metrics_all_b alb
             WHERE ALH.arc_list_used_by = al.arc_act_metric_used_by
             AND   ALH.list_used_by_id = al.act_metric_used_by_id
             AND   al.metric_id = alb.metric_id
             and   alb.metric_id in (304,305,306,307,308,   -- Contact Group
                                    314,315,316,317,318)   -- Control Group
             and   alb.enabled_flag = 'Y') ACT,
             ams_act_metrics_all AL, ams_metrics_all_b ALB
           WHERE  ACT.activity_metric_id(+) = AL.activity_metric_id
            AND   AL.metric_id=ALB.METRIC_ID
            AND   ALB.metric_id in (304,305,306,307,308,   -- Contact Group
                                    314,315,316,317,318)  -- Control Group
            AND   ALB.metric_category = G_TARGET_GROUP_ID
            AND   ALB.metric_sub_category in
                       (G_CONTACT_GROUP_ID,G_CONTROL_GROUP_ID)
            AND   ALB.function_name LIKE '%'|| G_TARGET_FUNCTION_NAME
            AND   ALB.metric_calculation_type = G_FUNCTION
            AND   ALB.enabled_flag = G_IS_ENABLED
            AND   AL.ACT_METRIC_USED_BY_ID = p_act_metric_used_by_id
            AND   AL.ARC_ACT_METRIC_USED_BY = p_arc_act_metric_used_by
            GROUP BY AL.activity_metric_id, AL.func_actual_value
           )
         WHERE NVL(actual_value,0) <> NVL(func_actual_value,-1)
         ;

         update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
         l_activity_metric_id_table.DELETE;
         l_actual_values_table.DELETE;

         END IF;

   END IF;

END Calculate_Target_Group;

-- NAME
--     Calculate_List_Target
--
-- PURPOSE
--     Bulk collect the list data from sources comparing against the list
--     entries.
--
-- HISTORY
-- 05-Jan-2005   dmvincen  Derived from Calculate_Seeded_list_metrics.
--
PROCEDURE Calculate_List_Target
IS
   l_actual_values_table num_table_type;
   l_activity_metric_id_table num_table_type;
   l_today DATE := sysdate;
   cursor c_has_traget_enabled IS
     SELECT count(distinct b.metric_id) metric_count,
            count(activity_metric_id) activity_count
     FROM ams_metrics_all_b b, ams_act_metrics_all a
     WHERE b.metric_id IN (347, 348)
     AND enabled_flag = G_IS_ENABLED
     AND a.metric_id = b.metric_id
     AND nvl(last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS;

   l_has_enabled NUMBER;
   l_activity_count NUMBER;
BEGIN
   OPEN c_has_traget_enabled;
   FETCH c_has_traget_enabled INTO l_has_enabled, l_activity_count;
   CLOSE c_has_traget_enabled;

   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_List_Target','Enabled Count='||l_has_enabled,
                'Activity Count='||l_activity_count);
   END IF;

   IF l_has_enabled > 0 THEN

      SELECT NVL(actual_value, 0), activity_metric_id
      BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
      FROM (
         --------------------------------------------------------
         -- choang - 03-mar-2004 - outer-joins needed to pick up
         --          objects which no longer exist; deleted act
         --          list, for example;
         --          hard-code the metric id's for performance
         --------------------------------------------------------
         --contact group count at list level
            SELECT COUNT(contacts.list_entry_id) actual_value
                 , actmet.activity_metric_id
                 , actmet.func_actual_value
            FROM
               (
              SELECT LIST.list_entry_id, 'ALIST' object_type,
                     actlist.act_list_header_id
              FROM ams_act_lists actlist
                 , ams_list_entries LIST
                 , ams_act_metrics_all a
                 , ams_metrics_all_b b
              WHERE LIST.list_header_id = actlist.list_header_id
              AND actlist.list_act_type = 'LIST'
              AND EXISTS (SELECT  1
                FROM ams_list_entries target, ams_act_lists acttarget
                WHERE acttarget.list_used_by = actlist.list_used_by
                AND   acttarget.list_used_by_id = actlist.list_used_by_id
                AND   acttarget.list_act_type = 'TARGET'
                AND   target.list_header_id = acttarget.list_header_id
                AND   target.list_entry_source_system_id =
                      LIST.list_entry_source_system_id
                AND   target.list_entry_source_system_type =
                      LIST.list_entry_source_system_type
                AND   target.enabled_flag = 'Y'
                AND   target.part_of_control_group_flag = 'N'
                AND   rownum = 1
               )
              AND LIST.enabled_flag = 'Y'
              AND LIST.part_of_control_group_flag = 'N'
              AND a.metric_id = b.metric_id
              AND actlist.act_list_header_id = a.act_metric_used_by_id
              AND a.arc_act_metric_used_by = 'ALIST'
              AND NVL(a.last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS
              AND b.metric_id = 347
              AND b.enabled_flag = G_IS_ENABLED
               ) contacts
               , ams_act_metrics_all actmet, ams_metrics_all_b ALB
            WHERE ALB.metric_id = 347
            AND   actmet.metric_id = ALB.metric_id
            AND   ALB.enabled_flag = G_IS_ENABLED
            AND   contacts.act_list_header_id (+) = actmet.act_metric_used_by_id
            AND   contacts.object_type(+) = actmet.arc_act_metric_used_by
            AND NVL(actmet.last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS
            GROUP BY actmet.activity_metric_id, actmet.func_actual_value

         UNION ALL

         --R10 Control Group Count    at list level
            SELECT COUNT(controls.list_entry_id) actual_value
                 , actmet.activity_metric_id
                 , actmet.func_actual_value
            FROM
               (
              SELECT LIST.list_entry_id, 'ALIST' object_type,
                     actlist.act_list_header_id
              FROM ams_act_lists actlist
                 , ams_list_entries LIST
                 , ams_act_metrics_all a
                 , ams_metrics_all_b b
              WHERE LIST.list_header_id = actlist.list_header_id
              AND actlist.list_act_type = 'LIST'
              AND EXISTS (SELECT  1
                FROM ams_list_entries target, ams_act_lists acttarget
                WHERE acttarget.list_used_by = actlist.list_used_by
                AND   acttarget.list_used_by_id = actlist.list_used_by_id
                AND   acttarget.list_act_type = 'TARGET'
                AND   target.list_header_id = acttarget.list_header_id
                AND   target.list_entry_source_system_id =
                      LIST.list_entry_source_system_id
                AND   target.list_entry_source_system_type =
                      LIST.list_entry_source_system_type
                AND   target.enabled_flag = 'N'
                AND   target.part_of_control_group_flag = 'Y'
                AND   rownum = 1
               )
              AND LIST.enabled_flag = 'N'
              AND LIST.part_of_control_group_flag = 'Y'
              AND a.metric_id = b.metric_id
              AND actlist.act_list_header_id = a.act_metric_used_by_id
              AND a.arc_act_metric_used_by = 'ALIST'
              AND NVL(a.last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS
              AND b.metric_id = 348
              AND b.enabled_flag = 'Y'
               ) controls
               , ams_act_metrics_all actmet, ams_metrics_all_b ALB
            WHERE ALB.metric_id = 348
            AND   actmet.metric_id = ALB.metric_id
            AND   ALB.enabled_flag = 'Y'
            AND   controls.act_list_header_id (+) = actmet.act_metric_used_by_id
            AND   controls.object_type(+) = actmet.arc_act_metric_used_by
            AND NVL(actmet.last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS
            GROUP BY actmet.activity_metric_id, actmet.func_actual_value
      )
      WHERE NVL(actual_value, 0) <> NVL(func_actual_value, -1);

      update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
      l_activity_metric_id_table.DELETE;
      l_actual_values_table.DELETE;

   END IF;

END;

-- NAME
--     Calculate_List_Resp_Lead_Opp
--
-- PURPOSE
--     Bulk collect the list data from sources comparing against the list
--     entries.
--
-- HISTORY
-- 05-Jan-2005   dmvincen  Derived from Calculate_Seeded_list_metrics.
-- 03-Mar-2004    choang   Re-wrote all queries to take org contacts into consideration
-- 04-Mar-2004    choang   Removed org contact validation for control and contact
--                         queries; validation is only required for the entries
--                         in the list to exist in the target group.
-- 05-Jan-2005   dmvincen  Separated the queries into procedures for better
--                         management.
--
PROCEDURE Calculate_List_Resp_Lead_Opp
IS
   l_actual_values_table num_table_type;
   l_activity_metric_id_table num_table_type;
   l_today DATE := sysdate;
   cursor c_has_metrics_enabled IS
     SELECT count(decode(b.metric_id,321,1,null)) response_count,
            count(decode(b.metric_id,326,1,null)) leads_count,
            count(decode(b.metric_id,331,1,null)) opportunities_count
     FROM ams_metrics_all_b b, ams_act_metrics_all a
     WHERE b.metric_id IN (321, 326, 331)
     AND enabled_flag = G_IS_ENABLED
     AND a.metric_id = b.metric_id
     AND NVL(last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS
     ;

   l_response_count NUMBER;
   l_leads_count NUMBER;
   l_opps_count NUMBER;
BEGIN
   OPEN c_has_metrics_enabled;
   FETCH c_has_metrics_enabled
     INTO l_response_count, l_leads_count, l_opps_count;
   CLOSE c_has_metrics_enabled;

   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_List_Resp_Lead_Opp','Response Count='||l_response_count);
   END IF;

   IF l_response_count > 0 THEN

      SELECT NVL(actual_value, 0), activity_metric_id
      BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
      FROM (
         /* BUG 4070346: Performance issue: This new query performs a full
          * table scan on the source codes table.  This is much smaller
          * than using the list entries or relationships tables.  Each
          * sub query returns a distinct list of party IDs for each activity
          * list.  Then each set of party IDs is checked against the
          * interactions to see if it has a positive response.  The final list
          * of party ids is unique per activity list and thus does not require
          * a distinct count.
          */
         --R10: Responses Count
         SELECT PARTIES ACTUAL_VALUE
              , ACTMET.ACTIVITY_METRIC_ID
              , ACTMET.FUNC_ACTUAL_VALUE
         FROM (
            SELECT COUNT(PARTY_ID) PARTIES, OBJECT_TYPE, OBJECT_ID
            FROM (
               -- SELECT DISTINCT LIST OF B2C AND B2B PARTIES
                SELECT distinct ACTLIST.ACT_LIST_HEADER_ID OBJECT_ID,
                       'ALIST' OBJECT_TYPE,
                       decode(src.source_category,
                        'B2C',ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID,
                        'B2B',REL.OBJECT_ID,null) PARTY_ID,
                        SOURCE.SOURCE_CODE_ID, src.source_category
                FROM AMS_ACT_LISTS ACTLIST,
                     AMS_LIST_ENTRIES ENTRY,
                     AMS_SOURCE_CODES SOURCE,
                     AMS_LIST_SRC_TYPES SRC,
                     HZ_RELATIONSHIPS REL,
                     AMS_METRICS_ALL_B B,
                     AMS_ACT_METRICS_ALL A
                WHERE ENTRY.LIST_HEADER_ID = ACTLIST.LIST_HEADER_ID
                  AND   SOURCE.SOURCE_CODE_FOR_ID = ACTLIST.LIST_USED_BY_ID
                  AND   SOURCE.ARC_SOURCE_CODE_FOR = ACTLIST.LIST_USED_BY
                  AND   ENTRY.LIST_ENTRY_SOURCE_SYSTEM_TYPE =
                                SRC.SOURCE_TYPE_CODE
                  AND   SRC.LIST_SOURCE_TYPE = 'TARGET'
                  AND   SRC.SOURCE_CATEGORY in ('B2C','B2B')
                  AND   REL.PARTY_ID(+) = ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID
                  AND   REL.DIRECTIONAL_FLAG(+) = 'F'
                  AND   A.METRIC_ID = B.METRIC_ID
                  AND   B.ENABLED_FLAG = G_IS_ENABLED
                  AND   nvl(LAST_CALCULATED_DATE,l_today) > l_today - G_CALC_LAG_DAYS
                  AND   B.METRIC_ID = 321
                  AND   a.arc_act_metric_used_by = 'ALIST'
                  AND   a.act_metric_used_by_id = ACTLIST.ACT_LIST_HEADER_ID
                  AND   actlist.list_act_type = 'LIST'
               ) LIST_PARTIES
            -- CHECK EACH PARTY FOR A POSITIVE RESPONSE WITHIN THE SOURCE CODE.
            WHERE EXISTS (SELECT 1
               FROM JTF_IH_INTERACTIONS INTER, JTF_IH_RESULTS_B RESULT
               WHERE RESULT.POSITIVE_RESPONSE_FLAG = 'Y'
               AND   RESULT.RESULT_ID = INTER.RESULT_ID
               AND   INTER.SOURCE_CODE_ID = LIST_PARTIES.SOURCE_CODE_ID
               AND   INTER.PARTY_ID = LIST_PARTIES.PARTY_ID
               AND ROWNUM = 1)
            GROUP BY OBJECT_TYPE, OBJECT_ID
            ) RESP
            , AMS_ACT_METRICS_ALL ACTMET, AMS_METRICS_ALL_B ALB
         WHERE ALB.METRIC_ID = 321
         AND   ACTMET.METRIC_ID = ALB.METRIC_ID
         AND   ALB.ENABLED_FLAG = G_IS_ENABLED
         AND   RESP.OBJECT_ID (+) = ACTMET.ACT_METRIC_USED_BY_ID
         AND   RESP.OBJECT_TYPE(+) = ACTMET.ARC_ACT_METRIC_USED_BY
         AND   nvl(LAST_CALCULATED_DATE,l_today) > l_today - G_CALC_LAG_DAYS

         /******* BUG 4070346: End of new query *******/

      )
      WHERE NVL(actual_value, 0) <> NVL(func_actual_value, -1);

      update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
      l_activity_metric_id_table.DELETE;
      l_actual_values_table.DELETE;

   END IF;

   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_List_Resp_Lead_Opp','Leads Count='||l_leads_count);
   END IF;

   IF l_leads_count > 0 THEN

      SELECT NVL(actual_value, 0), activity_metric_id
      BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
      FROM (
         --R10: Leads Count
    --sunkumar - 28-Jan-04 modified to include the join between party id's
        SELECT COUNT( leads.sales_lead_id) actual_value
             , actmet.activity_metric_id
             , actmet.func_actual_value
        FROM
           (
              SELECT lead.sales_lead_id,
                     LIST_PARTIES.activity_metric_id
              FROM as_sales_leads lead
                 , as_statuses_b  lead_status
           , (
               -- SELECT DISTINCT LIST OF B2C AND B2B PARTIES
              SELECT distinct A.activity_metric_id,
                     decode(src.source_category,
                      'B2C',ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID,
                        'B2B',REL.OBJECT_ID,null) PARTY_ID,
                      SOURCE.SOURCE_CODE_ID, src.source_category
              FROM AMS_ACT_LISTS ACTLIST,
                   AMS_LIST_ENTRIES ENTRY,
                   AMS_SOURCE_CODES SOURCE,
                   AMS_LIST_SRC_TYPES SRC,
                   HZ_RELATIONSHIPS REL,
                   AMS_METRICS_ALL_B B,
                   AMS_ACT_METRICS_ALL A
              WHERE ENTRY.LIST_HEADER_ID = ACTLIST.LIST_HEADER_ID
                AND   SOURCE.SOURCE_CODE_FOR_ID = ACTLIST.LIST_USED_BY_ID
                AND   SOURCE.ARC_SOURCE_CODE_FOR = ACTLIST.LIST_USED_BY
                AND   ENTRY.LIST_ENTRY_SOURCE_SYSTEM_TYPE =
                              SRC.SOURCE_TYPE_CODE
                AND   SRC.LIST_SOURCE_TYPE = 'TARGET'
                AND   SRC.SOURCE_CATEGORY in ('B2C','B2B')
                AND   REL.PARTY_ID(+) = ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID
                AND   REL.DIRECTIONAL_FLAG(+) = 'F'
                AND   A.METRIC_ID = B.METRIC_ID
                AND   B.ENABLED_FLAG = G_IS_ENABLED
                AND   nvl(LAST_CALCULATED_DATE,l_today) > l_today - G_CALC_LAG_DAYS
                AND   B.METRIC_ID = 326
                AND   a.arc_act_metric_used_by = 'ALIST'
                AND   a.act_metric_used_by_id = ACTLIST.ACT_LIST_HEADER_ID
                AND   actlist.list_act_type = 'LIST'
                ) LIST_PARTIES
              WHERE lead.status_code = lead_status.status_code
              AND lead_status.lead_flag = 'Y'
              AND lead_status.enabled_flag = 'Y'
              AND lead.source_promotion_id = LIST_PARTIES.source_code_id
              AND NVL(lead.deleted_flag, 'N') <> 'Y'
              AND lead.customer_id = list_parties.party_id
           ) leads
        , ams_act_metrics_all actmet, ams_metrics_all_b ALB
        WHERE ALB.metric_id = 326     -- metric id for leads
        AND   actmet.metric_id = ALB.metric_id
        AND   ALB.enabled_flag = G_IS_ENABLED
        AND   leads.activity_metric_id  = actmet.activity_metric_id
        AND   nvl(LAST_CALCULATED_DATE,l_today) > l_today - G_CALC_LAG_DAYS
        GROUP BY actmet.activity_metric_id, actmet.func_actual_value
          )
      WHERE NVL(actual_value, 0) <> NVL(func_actual_value, -1);

      update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
      l_activity_metric_id_table.DELETE;
      l_actual_values_table.DELETE;

   END IF;

   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_List_Resp_Lead_Opp','Opportunities Count='||l_opps_count);
   END IF;

   IF l_opps_count > 0 THEN

      SELECT NVL(actual_value, 0), activity_metric_id
      BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
      FROM (
        --R10: Opportunities
        --sunkumar - 28-Jan-04 modified to include the join between party id's
        --sunkumar - 02-mar-2004  removed cartesian join
        SELECT COUNT( opps.lead_id) actual_value
             , actmet.activity_metric_id
             , actmet.func_actual_value
        FROM
           (
           SELECT lead.lead_id, list_parties.activity_metric_id
           FROM as_leads_all lead
               , (
               -- SELECT DISTINCT LIST OF B2C AND B2B PARTIES
              SELECT distinct A.activity_metric_id,
                     decode(src.source_category,
                      'B2C',ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID,
                      'B2B',REL.OBJECT_ID,null) PARTY_ID,
                      SOURCE.SOURCE_CODE_ID, src.source_category
              FROM AMS_ACT_LISTS ACTLIST,
                   AMS_LIST_ENTRIES ENTRY,
                   AMS_SOURCE_CODES SOURCE,
                   AMS_LIST_SRC_TYPES SRC,
                   HZ_RELATIONSHIPS REL,
                   AMS_METRICS_ALL_B B,
                   AMS_ACT_METRICS_ALL A
              WHERE ENTRY.LIST_HEADER_ID = ACTLIST.LIST_HEADER_ID
                AND   SOURCE.SOURCE_CODE_FOR_ID = ACTLIST.LIST_USED_BY_ID
                AND   SOURCE.ARC_SOURCE_CODE_FOR = ACTLIST.LIST_USED_BY
                AND   ENTRY.LIST_ENTRY_SOURCE_SYSTEM_TYPE =
                              SRC.SOURCE_TYPE_CODE
                AND   SRC.LIST_SOURCE_TYPE = 'TARGET'
                AND   SRC.SOURCE_CATEGORY in ('B2C','B2B')
                AND   REL.PARTY_ID(+) = ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID
                AND   REL.DIRECTIONAL_FLAG(+) = 'F'
                AND   A.METRIC_ID = B.METRIC_ID
                AND   B.ENABLED_FLAG = G_IS_ENABLED
                AND   nvl(LAST_CALCULATED_DATE,l_today) > l_today - G_CALC_LAG_DAYS
                AND   B.METRIC_ID = 331
                AND   a.arc_act_metric_used_by = 'ALIST'
                AND   a.act_metric_used_by_id = ACTLIST.ACT_LIST_HEADER_ID
                AND   actlist.list_act_type = 'LIST'
              ) LIST_PARTIES
            WHERE lead.source_promotion_id = LIST_PARTIES.source_code_id
              AND lead.customer_id = list_parties.party_id
           ) opps
           , ams_act_metrics_all actmet, ams_metrics_all_b ALB
        WHERE ALB.metric_id =  331    -- metric id for opportunities
        AND   actmet.metric_id = ALB.metric_id
        AND   ALB.enabled_flag = G_IS_ENABLED
        AND   opps.activity_metric_id (+) = actmet.activity_metric_id
        AND   nvl(LAST_CALCULATED_DATE,l_today) > l_today - G_CALC_LAG_DAYS
        GROUP BY actmet.activity_metric_id, actmet.func_actual_value
      )
      WHERE NVL(actual_value, 0) <> NVL(func_actual_value, -1);

      update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
      l_activity_metric_id_table.DELETE;
      l_actual_values_table.DELETE;

   END IF;

END;

-- NAME
--     Calculate_List_Orders
--
-- PURPOSE
--     Bulk collect the seed values from order entries and compare against
--     the list entries.
--
-- HISTORY
-- 05-Jan-2005   dmvincen Created from Calculated_Seeded_list_metrics
-- 17-Dec-2003   choang   Fixed SQL for contact group, control group and responses
-- 03-Mar-2004    choang   Re-wrote all queries to take org contacts into consideration
--
--
PROCEDURE Calculate_List_Orders
IS
   l_actual_values_table num_table_type;
   l_activity_metric_id_table num_table_type;
   l_today DATE := sysdate;
   cursor c_has_orders_enabled IS
     SELECT count(distinct b.metric_id) metric_count,
            count(a.activity_metric_id) activity_count
     FROM ams_metrics_all_b b, ams_act_metrics_all a
     WHERE b.metric_id IN (336, 341, 346)
     AND enabled_flag = G_IS_ENABLED
     AND a.metric_id = b.metric_id
     AND nvl(last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS;

   l_has_enabled NUMBER;
   l_activity_count NUMBER;
BEGIN
   OPEN c_has_orders_enabled;
   FETCH c_has_orders_enabled INTO l_has_enabled, l_activity_count;
   CLOSE c_has_orders_enabled;

   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_List_Orders','Enabled Count='||l_has_enabled,
                'Activity Count='||l_activity_count);
   END IF;

   IF l_has_enabled > 0 THEN

      SELECT NVL(actual_value, 0), activity_metric_id
      BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
      FROM (
         --R10: Bookedorders
/***** BUG 4070346: Improved performance for list orderes.
****** 12/21/2004 New Order/booked revenue/invoiced revenue list query.
****** Combines the tree queries to lookup all the order information at
****** once and dividing the results amount the appropriate metrics
******/
        SELECT -- metrics_name,
        decode(AL.metric_id
         , 336 , order_count
         , 341 , booked_revenue
         , 346 , invoiced_revenue
         , 0 ) actual_value, activity_metric_id, func_actual_value
        FROM
        (SELECT
        object_type, object_id,
        count(DISTINCT h.header_id) order_count,
        sum(ams_actmetrics_seed_pvt.convert_currency(currency_code, booked_revenue)) booked_revenue,
        sum(ams_actmetrics_seed_pvt.convert_currency(currency_code, invoiced_revenue)) invoiced_revenue
        FROM
          (SELECT H.object_type, H.object_id, H.header_id,
            sum(nvl(H.unit_selling_price * H.ordered_quantity,0)) booked_revenue,
            sum(nvl(H.unit_selling_price * abs(H.invoiced_quantity),0)) invoiced_revenue,
            H.currency_code
           FROM
           (SELECT /*+ first_rows */
                  H.object_type, H.object_id, I.line_id, I.unit_selling_price,
            decode(H.flow_status_code, 'BOOKED', H.header_id, NULL) header_id,
            decode(H.flow_status_code, 'BOOKED', I.ordered_quantity, 0) ordered_quantity,
            I.invoiced_quantity, H.currency_code
            FROM oe_order_lines_all I,
            (SELECT H.header_id, H.flow_status_code, H.org_id,
                       H.transactional_curr_code currency_code,
                       list_parties.object_type,
                       list_parties.object_id
                FROM oe_order_headers_all H, hz_cust_accounts A
                , (
                   -- SELECT DISTINCT LIST OF B2C AND B2B PARTIES
                  SELECT distinct actlist_source.source_code_for_id,
                         actlist_source.arc_source_code_for,
                         decode(src.source_category,
                          'B2C',ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID,
                            'B2B',REL.OBJECT_ID,null) PARTY_ID,
                          actlist_SOURCE.SOURCE_CODE_ID, src.source_category,
                          actlist_source.object_type, actlist_source.object_id
                  FROM AMS_LIST_ENTRIES ENTRY,
                       AMS_LIST_SRC_TYPES SRC,
                       HZ_RELATIONSHIPS REL,
                       (select distinct source_code_for_id, arc_source_code_for,
                               source_code_id, 'ALIST' object_type,
                               ACTLIST.ACT_LIST_HEADER_ID object_id,
                               ACTLIST.LIST_HEADER_ID
                        from ams_source_codes source, AMS_ACT_LISTS ACTLIST,
                             ams_metrics_all_b b, ams_act_metrics_all a
                        where a.metric_id = b.metric_id
                        AND b.metric_id in (336,341,346)
                        AND b.enabled_flag = G_IS_ENABLED
                        AND nvl(LAST_CALCULATED_DATE,l_today) > l_today - G_CALC_LAG_DAYS
                        AND ACTLIST.LIST_USED_BY = source.arc_source_code_for
                        AND ACTLIST.LIST_USED_BY_ID = source.source_code_for_id
                        AND a.arc_act_metric_used_by = 'ALIST'
                        AND a.act_metric_used_by_id = ACTLIST.ACT_LIST_HEADER_ID
                        AND actlist.list_act_type = 'LIST'
                        ) actlist_source
                    WHERE ENTRY.LIST_HEADER_ID = actlist_source.LIST_HEADER_ID
                    AND   ENTRY.LIST_ENTRY_SOURCE_SYSTEM_TYPE =
                                  SRC.SOURCE_TYPE_CODE
                    AND   SRC.LIST_SOURCE_TYPE = 'TARGET'
                    AND   SRC.SOURCE_CATEGORY in ('B2C','B2B')
                    AND   REL.PARTY_ID(+) = ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID
                    AND   REL.DIRECTIONAL_FLAG(+) = 'F'
                  ) LIST_PARTIES
                WHERE H.booked_flag = 'Y'
                AND H.booked_date IS NOT NULL
                AND H.marketing_source_code_id = LIST_PARTIES.source_code_id
                AND H.sold_to_org_id = A.cust_account_id
                AND A.party_id = list_parties.party_id
           ) H
           WHERE H.header_id = I.header_id(+)
           AND EXISTS (
              SELECT 1 FROM dual WHERE H.flow_status_code = 'BOOKED'
              UNION ALL
              SELECT  1
              FROM OE_SYSTEM_PARAMETERS_ALL ospa, MTL_SYSTEM_ITEMS_B item
              WHERE H.org_id = ospa.org_id
              AND I.inventory_item_id = item.inventory_item_id
              AND   nvl(I.ship_from_org_id, ospa.master_organization_id) = item.organization_id
              and rownum = 1
              )
           ) H
        GROUP BY H.object_type, H.object_id, H.header_id,H.currency_code
        ) H
        GROUP BY object_type, object_id) T,
          ams_act_metrics_all AL, ams_metrics_all_b ALB
        WHERE AL.ARC_ACT_METRIC_USED_BY = T.object_type(+)
      AND   AL.act_metric_used_by_id = T.object_id(+)
      AND   ALB.metric_id IN (336,341,346)
      AND   AL.metric_id = ALB.metric_id
      AND   ALB.enabled_flag = G_IS_ENABLED
      AND nvl(LAST_CALCULATED_DATE,l_today) > l_today - G_CALC_LAG_DAYS
          )
      WHERE NVL(actual_value, 0) <> NVL(func_actual_value, -1);

      update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
      l_activity_metric_id_table.DELETE;
      l_actual_values_table.DELETE;

   END IF;

END;

-- NAME
--     Calculate_Seeded_List_Metrics
--
-- PURPOSE
--     Bulk collect the list data from sources comparing against the list
--     entries.
--
-- HISTORY
-- 05-Aug-2003   sunkumar created.
-- 17-Dec-2003   choang   Fixed SQL for contact group, control group and responses
-- 02-Mar-2004   sunkumar code cleanup
-- 03-Mar-2004    choang   Re-wrote all queries to take org contacts into consideration
-- 04-Mar-2004    choang   Removed org contact validation for control and contact
--                         queries; validation is only required for the entries
--                         in the list to exist in the target group.
-- 05-Jan-2005   dmvincen  Separated the queries into procedures for better
--                         management.
--

PROCEDURE Calculate_Seeded_List_Metrics(
          p_arc_act_metric_used_by VARCHAR2 := NULL,
          p_act_metric_used_by_id NUMBER := NULL)
IS
   l_actual_values_table num_table_type;
   l_activity_metric_id_table num_table_type;
BEGIN
   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_Seeded_List_Metrics','BEGIN');
   END IF;
   -- Get all object data to update.
   IF p_arc_act_metric_used_by IS NULL THEN

      Calculate_List_Target;

      Calculate_List_Resp_Lead_Opp;

      Calculate_List_Orders;

   END IF;

   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_Seeded_List_Metrics','END');
   END IF;
END Calculate_Seeded_List_Metrics;

-- NAME
--     Calculate_Inferred_Responses
--
-- PURPOSE
--     Calculate inferred Responses for a single object.
--
-- HISTORY
-- 11-Aug-2005   dmvincen created.
-- 19-Jan-2006   dmvincen Fixed actmet and metric join, lost in 120.13
--
PROCEDURE Calculate_Inferred_Responses(
          p_arc_act_metric_used_by VARCHAR2,
          p_act_metric_used_by_id NUMBER)
is
   l_actual_values_table num_table_type;
   l_activity_metric_id_table num_table_type;
   cursor c_has_inferred_enabled(object_type varchar2, object_id number) IS
     SELECT count(1)
     FROM ams_metrics_all_b b, ams_act_metrics_all a
     WHERE a.metric_id IN (361,362)
     AND enabled_flag = G_IS_ENABLED
     and a.metric_id = b.metric_id
     and a.arc_act_metric_used_by = object_type
     and a.act_metric_used_by_id = object_id;

   l_has_enabled NUMBER;
   l_today date := sysdate;
   l_inferred_period number := fnd_profile.value('AMS_METR_INFERRED_PERIOD');
begin
   open c_has_inferred_enabled(p_arc_act_metric_used_by, p_act_metric_used_by_id);
   fetch c_has_inferred_enabled into l_has_enabled;
   close c_has_inferred_enabled;

   if l_has_enabled > 0 then
      SELECT NVL(actual_value, 0), activity_metric_id
      BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
      from (select actual_value, actmet.activity_metric_id, func_actual_value
      FROM (
        select count(1) actual_value, ACTIVITY_METRIC_ID
        from (
			SELECT decode(SRC.SOURCE_CATEGORY, 'B2C', ENTRY.PARTY_ID,
			               'B2B', REL.OBJECT_ID, null) PRIMARY_PARTY_ID,
			       decode(SRC.SOURCE_CATEGORY, 'B2C', NULL,
				           'B2B', ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID, null)
				   CONTACT_REL_PARTY_ID,
             CS.LAST_ACTIVATION_DATE, AM.ACTIVITY_METRIC_ID,
			 SRC.SOURCE_CATEGORY, CS.SCHEDULE_ID OBJECT_ID
			FROM AMS_CAMPAIGN_SCHEDULES_B CS ,
			     AMS_LIST_HEADERS_ALL LHA ,
			     AMS_LIST_ENTRIES ENTRY ,
			     AMS_ACT_METRICS_ALL AM ,
			     AMS_METRICS_ALL_B MB,
			     HZ_RELATIONSHIPS REL,
			     AMS_LIST_SRC_TYPES SRC
			WHERE AM.METRIC_ID = MB.METRIC_ID
			  AND AM.ARC_ACT_METRIC_USED_BY = 'CSCH'
			  AND AM.ACT_METRIC_USED_BY_ID = CS.SCHEDULE_ID
			  AND MB.ENABLED_FLAG = 'Y'
			  AND MB.METRIC_ID IN (361,362)
              AND am.act_metric_used_by_id = p_act_metric_used_by_id
			  AND 'Y' = DECODE(MB.METRIC_ID, 362, ENTRY.ENABLED_FLAG,
			               361, ENTRY.PART_OF_CONTROL_GROUP_FLAG,'N')
			  AND ENTRY.LIST_HEADER_ID = LHA.LIST_HEADER_ID
			  AND CS.SCHEDULE_ID = LHA.LIST_USED_BY_ID
			  AND 'CSCH' = LHA.ARC_LIST_USED_BY
			  AND  ENTRY.LIST_ENTRY_SOURCE_SYSTEM_TYPE = SRC.SOURCE_TYPE_CODE
			  AND SRC.LIST_SOURCE_TYPE = 'TARGET'
			  AND SRC.SOURCE_CATEGORY in ('B2C','B2B')
			  AND REL.PARTY_ID(+) = ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID
			  AND REL.DIRECTIONAL_FLAG(+) = 'F'
           ) csch_parties
        -- Check each party for a positive response within active period.
         where exists (select /*+ use_concat */ 1
		 from jtf_ih_interactions inter, jtf_ih_results_b result
         WHERE result.positive_response_flag = 'Y'
         AND   result.result_id = inter.result_id
         and   ((source_category = 'B2B'
           and   inter.contact_rel_party_id = csch_parties.contact_rel_party_id
           and   inter.primary_party_id = csch_parties.primary_party_id)
           OR
               (source_category = 'B2C'
               and inter.party_id = csch_parties.primary_party_id))
         and inter.creation_date between csch_parties.last_activation_date
               and csch_parties.last_activation_date + l_inferred_period
         and rownum = 1)
      group by ACTIVITY_METRIC_ID
        ) resp
        , ams_act_metrics_all actmet, ams_metrics_all_b ALB
    WHERE ALB.metric_id in (361,362)
    AND actmet.metric_id = alb.metric_id
    AND   ALB.enabled_flag = 'Y'
    and actmet.arc_act_metric_used_by = 'CSCH'
    and actmet.act_metric_used_by_id = p_act_metric_used_by_id
    AND actmet.ACTIVITY_METRIC_ID = resp.ACTIVITY_METRIC_ID(+)
    )
    where NVL(actual_value, 0) <> NVL(func_actual_value, -1);

      update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
      l_activity_metric_id_table.DELETE;
      l_actual_values_table.DELETE;

   end if;
end;

-- NAME
--     Calculate_Inferred_Responses
--
-- PURPOSE
--     Calculate inferred responses for a all objects.
--
-- HISTORY
-- 11-Aug-2005   dmvincen created.
--
PROCEDURE Calculate_Inferred_Responses
is
   l_actual_values_table num_table_type;
   l_activity_metric_id_table num_table_type;
   l_today DATE := sysdate;
   cursor c_has_inferred_enabled IS
     SELECT count(distinct b.metric_id) metric_count,
            count(activity_metric_id) activity_count
     FROM ams_metrics_all_b b, ams_act_metrics_all a
     WHERE b.metric_id IN (361,362)
     AND enabled_flag = G_IS_ENABLED
     AND a.metric_id = b.metric_id
     AND nvl(last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS;

   l_has_enabled NUMBER;
   l_activity_count NUMBER;
   l_inferred_period number := fnd_profile.value('AMS_METR_INFERRED_PERIOD');
begin
   open c_has_inferred_enabled;
   fetch c_has_inferred_enabled into l_has_enabled, l_activity_count;
   close c_has_inferred_enabled;

   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_Inferred_Responses','Enabled Count='||l_has_enabled,
           'Activity Count='||l_activity_count);
   END IF;

   if l_has_enabled > 0 then
      SELECT NVL(actual_value, 0), activity_metric_id
      BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
      from (select actual_value, actmet.activity_metric_id, func_actual_value
      FROM (
        select count(1) actual_value, ACTIVITY_METRIC_ID
        from (
			SELECT decode(SRC.SOURCE_CATEGORY, 'B2C', ENTRY.PARTY_ID,
			               'B2B', REL.OBJECT_ID, null) PRIMARY_PARTY_ID,
			       decode(SRC.SOURCE_CATEGORY, 'B2C', NULL,
				           'B2B', ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID, null)
				   CONTACT_REL_PARTY_ID,
             CS.LAST_ACTIVATION_DATE, AM.ACTIVITY_METRIC_ID,
			 SRC.SOURCE_CATEGORY, CS.SCHEDULE_ID OBJECT_ID
			FROM AMS_CAMPAIGN_SCHEDULES_B CS ,
			     AMS_LIST_HEADERS_ALL LHA ,
			     AMS_LIST_ENTRIES ENTRY ,
			     AMS_ACT_METRICS_ALL AM ,
			     AMS_METRICS_ALL_B MB,
			     HZ_RELATIONSHIPS REL,
			     AMS_LIST_SRC_TYPES SRC
			WHERE AM.METRIC_ID = MB.METRIC_ID
			  AND AM.ARC_ACT_METRIC_USED_BY = 'CSCH'
			  AND AM.ACT_METRIC_USED_BY_ID = CS.SCHEDULE_ID
			  AND MB.ENABLED_FLAG = 'Y'
			  AND MB.METRIC_ID IN (361,362)
              AND NVL(AM.LAST_CALCULATED_DATE,l_today ) > l_today - G_CALC_LAG_DAYS
			  AND 'Y' = DECODE(MB.METRIC_ID, 362, ENTRY.ENABLED_FLAG,
			               361, ENTRY.PART_OF_CONTROL_GROUP_FLAG,'N')
			  AND ENTRY.LIST_HEADER_ID = LHA.LIST_HEADER_ID
			  AND CS.SCHEDULE_ID = LHA.LIST_USED_BY_ID
			  AND 'CSCH' = LHA.ARC_LIST_USED_BY
			  AND  ENTRY.LIST_ENTRY_SOURCE_SYSTEM_TYPE = SRC.SOURCE_TYPE_CODE
			  AND SRC.LIST_SOURCE_TYPE = 'TARGET'
			  AND SRC.SOURCE_CATEGORY in ('B2C','B2B')
			  AND REL.PARTY_ID(+) = ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID
			  AND REL.DIRECTIONAL_FLAG(+) = 'F'
           ) csch_parties
        -- Check each party for a positive response within active period.
         where exists (select /*+ use_concat */ 1
		 from jtf_ih_interactions inter, jtf_ih_results_b result
         WHERE result.positive_response_flag = 'Y'
         AND   result.result_id = inter.result_id
         and   ((source_category = 'B2B'
            and   inter.contact_rel_party_id = csch_parties.contact_rel_party_id
            and   inter.primary_party_id = csch_parties.primary_party_id)
           OR
               (source_category = 'B2C'
               and inter.party_id = csch_parties.primary_party_id))
         and inter.creation_date between csch_parties.last_activation_date
               and csch_parties.last_activation_date + l_inferred_period
         and rownum = 1)
      group by ACTIVITY_METRIC_ID
        ) resp
        , ams_act_metrics_all actmet, ams_metrics_all_b ALB
    WHERE ALB.metric_id in (361,362)
    AND   actmet.metric_id = ALB.metric_id
    AND   ALB.enabled_flag = 'Y'
    and l_today - G_CALC_LAG_DAYS < nvl(actmet.last_calculated_date,l_today)
    AND actmet.ACTIVITY_METRIC_ID = resp.ACTIVITY_METRIC_ID(+)
    )
    where NVL(actual_value, 0) <> NVL(func_actual_value, -1);

      update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
      l_activity_metric_id_table.DELETE;
      l_actual_values_table.DELETE;

   end if;

end;

-- NAME
--     Calculate_Inferred_Leads
--
-- PURPOSE
--     Calculate inferred leads for an object.
--
-- HISTORY
-- 11-Aug-2005   dmvincen created.
--
PROCEDURE Calculate_Inferred_Leads(
          p_arc_act_metric_used_by VARCHAR2,
          p_act_metric_used_by_id NUMBER)
is
   l_actual_values_table num_table_type;
   l_activity_metric_id_table num_table_type;
   cursor c_has_inferred_enabled(object_type varchar2, object_id number) IS
     SELECT count(1)
     FROM ams_metrics_all_b b, ams_act_metrics_all a
     WHERE a.metric_id IN (371,372)
     AND enabled_flag = G_IS_ENABLED
     and a.metric_id = b.metric_id
     and a.arc_act_metric_used_by = object_type
     and a.act_metric_used_by_id = object_id;

   l_has_enabled NUMBER;
   l_today date := sysdate;
   l_inferred_period number := fnd_profile.value('AMS_METR_INFERRED_PERIOD');
begin
   open c_has_inferred_enabled(p_arc_act_metric_used_by, p_act_metric_used_by_id);
   fetch c_has_inferred_enabled into l_has_enabled;
   close c_has_inferred_enabled;

   if l_has_enabled > 0 then
     SELECT NVL(actual_value, 0), activity_metric_id
      BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
      FROM (select actual_value, am.activity_metric_id, am.func_actual_value
       from (
      select count(1) actual_value, activity_metric_id
      from (
			SELECT decode(SRC.SOURCE_CATEGORY, 'B2C', ENTRY.PARTY_ID,
			               'B2B', REL.OBJECT_ID, null) PRIMARY_PARTY_ID,
			       decode(SRC.SOURCE_CATEGORY, 'B2C', NULL,
				           'B2B', ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID, null)
				   CONTACT_REL_PARTY_ID,
             CS.LAST_ACTIVATION_DATE, AM.ACTIVITY_METRIC_ID,
			 SRC.SOURCE_CATEGORY, CS.SCHEDULE_ID OBJECT_ID
			FROM AMS_CAMPAIGN_SCHEDULES_B CS ,
			     AMS_LIST_HEADERS_ALL LHA ,
			     AMS_LIST_ENTRIES ENTRY ,
			     AMS_ACT_METRICS_ALL AM ,
			     AMS_METRICS_ALL_B MB,
			     HZ_RELATIONSHIPS REL,
			     AMS_LIST_SRC_TYPES SRC
			WHERE AM.METRIC_ID = MB.METRIC_ID
			  AND AM.ARC_ACT_METRIC_USED_BY = 'CSCH'
			  AND AM.ACT_METRIC_USED_BY_ID = CS.SCHEDULE_ID
			  AND MB.ENABLED_FLAG = 'Y'
			  AND MB.METRIC_ID IN (371,372)
	          AND cs.schedule_id = p_act_metric_used_by_id
			  AND 'Y' = DECODE(MB.METRIC_ID, 372, ENTRY.ENABLED_FLAG,
			               371, ENTRY.PART_OF_CONTROL_GROUP_FLAG,'N')
			  AND ENTRY.LIST_HEADER_ID = LHA.LIST_HEADER_ID
			  AND CS.SCHEDULE_ID = LHA.LIST_USED_BY_ID
			  AND 'CSCH' = LHA.ARC_LIST_USED_BY
			  AND  ENTRY.LIST_ENTRY_SOURCE_SYSTEM_TYPE = SRC.SOURCE_TYPE_CODE
			  AND SRC.LIST_SOURCE_TYPE = 'TARGET'
			  AND SRC.SOURCE_CATEGORY in ('B2C','B2B')
			  AND REL.PARTY_ID(+) = ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID
			  AND REL.DIRECTIONAL_FLAG(+) = 'F'
         ) csch_parties
      where exists (select /*+ use_concat */1
	     from as_sales_leads lead, as_statuses_b lead_status
         where lead.status_code = lead_status.status_code
         AND lead_status.lead_flag = 'Y'
         AND lead_status.enabled_flag = 'Y'
         AND NVL(lead.deleted_flag, 'N') <> 'Y'
         and ((source_category = 'B2C' AND lead.customer_id = csch_parties.primary_party_id)
            OR
            (source_category = 'B2B' and lead.customer_id = csch_parties.primary_party_id
             and lead.primary_contact_party_id = csch_parties.contact_rel_party_id))
        and lead.creation_date between csch_parties.last_activation_date
             and csch_parties.last_activation_date + l_inferred_period
         AND exists (select 1
            from as_sales_lead_lines LL, ams_act_products actprod
            where ll.inventory_item_id = actprod.INVENTORY_ITEM_ID
            and ll.organization_id = actprod.organization_id
            and ll.sales_lead_id = lead.sales_lead_id
            and actprod.arc_act_product_used_by = 'CSCH'
            and actprod.act_product_used_by_id = csch_parties.object_id
            and actprod.level_type_code = 'PRODUCT'
            and rownum = 1
            )
        and rownum = 1
        )
       group by activity_metric_id) leads,
     ams_act_metrics_all am, ams_metrics_all_b mb
      WHERE am.metric_id = mb.metric_id
      and am.arc_act_metric_used_by = 'CSCH'
      and mb.enabled_flag = 'Y'
      and mb.metric_id in (371,372)
      and am.act_metric_used_by_id = p_act_metric_used_by_id
      and leads.activity_metric_id(+) = am.activity_metric_id)
      where NVL(actual_value, 0) <> NVL(func_actual_value, -1);

      update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
      l_activity_metric_id_table.DELETE;
      l_actual_values_table.DELETE;

   end if;
end;

-- NAME
--     Calculate_Inferred_Leads
--
-- PURPOSE
--     Calculate inferred leads for a all objects.
--
-- HISTORY
-- 11-Aug-2005   dmvincen created.
--
PROCEDURE Calculate_Inferred_Leads
is
   l_actual_values_table num_table_type;
   l_activity_metric_id_table num_table_type;
   l_today DATE := sysdate;
   cursor c_has_inferred_enabled IS
     SELECT count(distinct b.metric_id) metric_count,
            count(activity_metric_id) activity_count
     FROM ams_metrics_all_b b, ams_act_metrics_all a
     WHERE b.metric_id IN (371,372)
     AND enabled_flag = G_IS_ENABLED
     AND a.metric_id = b.metric_id
     AND nvl(last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS;

   l_has_enabled NUMBER;
   l_activity_count NUMBER;
   l_inferred_period number := fnd_profile.value('AMS_METR_INFERRED_PERIOD');
begin
   open c_has_inferred_enabled;
   fetch c_has_inferred_enabled into l_has_enabled,l_activity_count;
   close c_has_inferred_enabled;

   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_Inferred_Leads','Enabled Count='||l_has_enabled,
         'Activity Count='||l_activity_count);
   END IF;

   if l_has_enabled > 0 then
     SELECT NVL(actual_value, 0), activity_metric_id
      BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
      FROM (select actual_value, am.activity_metric_id, am.func_actual_value
       from (
      select count(1) actual_value, activity_metric_id
      from (
			SELECT decode(SRC.SOURCE_CATEGORY, 'B2C', ENTRY.PARTY_ID,
			               'B2B', REL.OBJECT_ID, null) PRIMARY_PARTY_ID,
			       decode(SRC.SOURCE_CATEGORY, 'B2C', NULL,
				           'B2B', ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID, null)
				   CONTACT_REL_PARTY_ID,
             CS.LAST_ACTIVATION_DATE, AM.ACTIVITY_METRIC_ID,
			 SRC.SOURCE_CATEGORY, CS.SCHEDULE_ID OBJECT_ID
			FROM AMS_CAMPAIGN_SCHEDULES_B CS ,
			     AMS_LIST_HEADERS_ALL LHA ,
			     AMS_LIST_ENTRIES ENTRY ,
			     AMS_ACT_METRICS_ALL AM ,
			     AMS_METRICS_ALL_B MB,
			     HZ_RELATIONSHIPS REL,
			     AMS_LIST_SRC_TYPES SRC
			WHERE AM.METRIC_ID = MB.METRIC_ID
			  AND AM.ARC_ACT_METRIC_USED_BY = 'CSCH'
			  AND AM.ACT_METRIC_USED_BY_ID = CS.SCHEDULE_ID
			  AND MB.ENABLED_FLAG = 'Y'
			  AND MB.METRIC_ID IN (371,372)
              AND nvl(am.last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS
			  AND 'Y' = DECODE(MB.METRIC_ID, 372, ENTRY.ENABLED_FLAG,
			               371, ENTRY.PART_OF_CONTROL_GROUP_FLAG,'N')
			  AND ENTRY.LIST_HEADER_ID = LHA.LIST_HEADER_ID
			  AND CS.SCHEDULE_ID = LHA.LIST_USED_BY_ID
			  AND 'CSCH' = LHA.ARC_LIST_USED_BY
			  AND  ENTRY.LIST_ENTRY_SOURCE_SYSTEM_TYPE = SRC.SOURCE_TYPE_CODE
			  AND SRC.LIST_SOURCE_TYPE = 'TARGET'
			  AND SRC.SOURCE_CATEGORY in ('B2C','B2B')
			  AND REL.PARTY_ID(+) = ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID
			  AND REL.DIRECTIONAL_FLAG(+) = 'F'
         ) csch_parties
      where exists (select /*+ use_concat */ 1
	     from as_sales_leads lead, as_statuses_b lead_status
         where lead.status_code = lead_status.status_code
         AND lead_status.lead_flag = 'Y'
         AND lead_status.enabled_flag = 'Y'
         AND NVL(lead.deleted_flag, 'N') <> 'Y'
         and ((source_category = 'B2C' AND lead.customer_id = csch_parties.primary_party_id)
            OR
            (source_category = 'B2B' and lead.customer_id = csch_parties.primary_party_id
             and lead.primary_contact_party_id = csch_parties.contact_rel_party_id))
        and lead.creation_date between csch_parties.last_activation_date
             and csch_parties.last_activation_date + l_inferred_period
         AND exists (select 1
            from as_sales_lead_lines LL, ams_act_products actprod
            where ll.inventory_item_id = actprod.INVENTORY_ITEM_ID
            and ll.organization_id = actprod.organization_id
            and ll.sales_lead_id = lead.sales_lead_id
            and actprod.arc_act_product_used_by = 'CSCH'
            and actprod.act_product_used_by_id = csch_parties.object_id
            and actprod.level_type_code = 'PRODUCT'
            and rownum = 1
            )
        and rownum = 1
        )
       group by activity_metric_id) leads,
        ams_act_metrics_all am, ams_metrics_all_b mb
      WHERE am.metric_id = mb.metric_id
      and am.arc_act_metric_used_by = 'CSCH'
      and mb.enabled_flag = 'Y'
      and mb.metric_id in (371,372)
      AND nvl(am.last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS
      and leads.activity_metric_id(+) = am.activity_metric_id)
      where NVL(actual_value, 0) <> NVL(func_actual_value, -1);

      update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
      l_activity_metric_id_table.DELETE;
      l_actual_values_table.DELETE;

   end if;

end;

-- NAME
--     Calculate_Inferred_Orders
--
-- PURPOSE
--     Calculate inferred orders for an object.
--
-- HISTORY
-- 11-Aug-2005   dmvincen created.
--
PROCEDURE Calculate_Inferred_Orders(
          p_arc_act_metric_used_by VARCHAR2,
          p_act_metric_used_by_id NUMBER)
is
   l_actual_values_table num_table_type;
   l_activity_metric_id_table num_table_type;
   cursor c_has_inferred_enabled(object_type varchar2, object_id number) IS
     SELECT count(1)
     FROM ams_metrics_all_b b, ams_act_metrics_all a
     WHERE a.metric_id IN (381,382,391,392)
     AND enabled_flag = G_IS_ENABLED
     and a.metric_id = b.metric_id
     and a.arc_act_metric_used_by = object_type
     and a.act_metric_used_by_id = object_id;

   l_has_enabled NUMBER;
   l_today date := sysdate;
   l_inferred_period number := fnd_profile.value('AMS_METR_INFERRED_PERIOD');
begin
   open c_has_inferred_enabled(p_arc_act_metric_used_by, p_act_metric_used_by_id);
   fetch c_has_inferred_enabled into l_has_enabled;
   close c_has_inferred_enabled;

   if l_has_enabled > 0 then
    SELECT NVL(actual_value, 0), activity_metric_id
    BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
    FROM (
      SELECT
      decode(al.metric_id
      , 381, order_count, 382, order_count
      , 391, booked_revenue, 392, booked_revenue
      , 0 ) actual_value, al.activity_metric_id, func_actual_value,
     al.metric_id, al.act_metric_used_by_id
      FROM
      (SELECT
      ACTIVITY_METRIC_ID,
      count(distinct nvl(contact_rel_party_id, primary_party_id)) targets,
      count(DISTINCT header_id) order_count,
      sum(ams_actmetrics_seed_pvt.convert_currency(currency_code, booked_revenue)) booked_revenue
      FROM (
       SELECT /*+ ordered */ H.header_id, H.transactional_curr_code currency_code,
               sum(nvl(I.ordered_quantity * I.unit_selling_price,0)) booked_revenue,
                csch_parties.ACTIVITY_METRIC_ID,
            primary_party_id, contact_rel_party_id
       from (
			SELECT decode(SRC.SOURCE_CATEGORY, 'B2C', ENTRY.PARTY_ID,
			               'B2B', REL.OBJECT_ID, null) PRIMARY_PARTY_ID,
			       decode(SRC.SOURCE_CATEGORY, 'B2C', NULL,
				           'B2B', ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID, null)
				   CONTACT_REL_PARTY_ID,
             CS.LAST_ACTIVATION_DATE, AM.ACTIVITY_METRIC_ID,
			 SRC.SOURCE_CATEGORY, CS.SCHEDULE_ID OBJECT_ID
			FROM AMS_CAMPAIGN_SCHEDULES_B CS ,
			     AMS_LIST_HEADERS_ALL LHA ,
			     AMS_LIST_ENTRIES ENTRY ,
			     AMS_ACT_METRICS_ALL AM ,
			     AMS_METRICS_ALL_B MB,
			     HZ_RELATIONSHIPS REL,
			     AMS_LIST_SRC_TYPES SRC
			WHERE AM.METRIC_ID = MB.METRIC_ID
			  AND AM.ARC_ACT_METRIC_USED_BY = 'CSCH'
			  AND AM.ACT_METRIC_USED_BY_ID = CS.SCHEDULE_ID
			  AND MB.ENABLED_FLAG = 'Y'
			  AND MB.METRIC_ID IN (391,381,392,382)
              and am.act_metric_used_by_id = p_act_metric_used_by_id
			  AND 'Y' = DECODE(MB.METRIC_ID,
                    392, ENTRY.ENABLED_FLAG,
                    382, ENTRY.ENABLED_FLAG,
                    391, ENTRY.PART_OF_CONTROL_GROUP_FLAG,
                    381, ENTRY.PART_OF_CONTROL_GROUP_FLAG,'N')
			  AND ENTRY.LIST_HEADER_ID = LHA.LIST_HEADER_ID
			  AND CS.SCHEDULE_ID = LHA.LIST_USED_BY_ID
			  AND 'CSCH' = LHA.ARC_LIST_USED_BY
			  AND  ENTRY.LIST_ENTRY_SOURCE_SYSTEM_TYPE = SRC.SOURCE_TYPE_CODE
			  AND SRC.LIST_SOURCE_TYPE = 'TARGET'
			  AND SRC.SOURCE_CATEGORY in ('B2C','B2B')
			  AND REL.PARTY_ID(+) = ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID
			  AND REL.DIRECTIONAL_FLAG(+) = 'F'
          ) csch_parties,
           hz_cust_accounts account,
           oe_order_headers_all H,
           oe_order_lines_all I,
           ams_act_products aprod
        where csch_parties.primary_party_id = account.party_id
        AND H.sold_to_org_id = account.cust_account_id
        AND ((source_category = 'B2B'
              AND exists (select 1 from hz_cust_account_roles roles
               where H.sold_to_contact_id = roles.cust_account_role_id
               AND roles.cust_account_id = account.cust_account_id
               AND roles.party_id = csch_parties.contact_rel_party_id
               AND rownum = 1))
           OR
            (source_category = 'B2C'))
         and H.booked_flag = 'Y'
         AND H.booked_date IS NOT NULL
         AND H.flow_status_code = 'BOOKED'
         and aprod.arc_act_product_used_by = 'CSCH'
         and aprod.act_product_used_by_id = csch_parties.object_id
         -- Commenting out this line since sold_from_org_id doesn't get
         -- populated. Bug#5139222
         -- and aprod.organization_id = i.sold_from_org_id
         and aprod.INVENTORY_ITEM_ID = i.ordered_item_id
         and aprod.level_type_code = 'PRODUCT'
         AND H.header_id = I.header_id
         -- AND H.creation_date
	 AND H.ordered_date
             between csch_parties.last_activation_date
             and csch_parties.last_activation_date + l_inferred_period
         group by H.header_id, H.transactional_curr_code ,
             csch_parties.object_id, csch_parties.activity_metric_id,
           primary_party_id, contact_rel_party_id
        ) csch_orders
            GROUP BY csch_orders.activity_metric_id
         ) T,
             ams_act_metrics_all AL, ams_metrics_all_b ALB
         WHERE ALB.metric_id IN (391,381,392,382)
         AND   AL.metric_id = ALB.metric_id
         AND   ALB.enabled_flag = 'Y'
         AND   AL.activity_metric_id = t.activity_metric_id(+)
         AND   AL.arc_act_metric_used_by = 'CSCH'
         and al.act_metric_used_by_id = p_act_metric_used_by_id
        )
      WHERE NVL(actual_value, 0) <> NVL(func_actual_value, -1);

      update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
      l_activity_metric_id_table.DELETE;
      l_actual_values_table.DELETE;

   end if;

end;

-- NAME
--     Calculate_Inferred_Orders
--
-- PURPOSE
--     Calculate inferred orders for a all objects.
--
-- HISTORY
-- 11-Aug-2005   dmvincen created.
--
PROCEDURE Calculate_Inferred_Orders
is
   l_actual_values_table num_table_type;
   l_activity_metric_id_table num_table_type;
   l_today DATE := sysdate;
   cursor c_has_inferred_enabled IS
     SELECT count(distinct b.metric_id) metric_count,
            count(activity_metric_id) activity_count
     FROM ams_metrics_all_b b, ams_act_metrics_all a
     WHERE b.metric_id IN (381,382,391,392)
     AND enabled_flag = G_IS_ENABLED
     AND a.metric_id = b.metric_id
     AND nvl(last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS;

   l_has_enabled NUMBER;
   l_activity_count NUMBER;
   l_inferred_period number := fnd_profile.value('AMS_METR_INFERRED_PERIOD');
begin
   open c_has_inferred_enabled;
   fetch c_has_inferred_enabled into l_has_enabled,l_activity_count;
   close c_has_inferred_enabled;

   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_Inferred_Orders','Enabled Count='||l_has_enabled,
          'Activity Count='||l_activity_count);
   END IF;

   if l_has_enabled > 0 then
    SELECT NVL(actual_value, 0), activity_metric_id
    BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
    FROM (
      SELECT
      decode(al.metric_id
      , 381, order_count, 382, order_count
      , 391, booked_revenue, 392, booked_revenue
      , 0 ) actual_value, al.activity_metric_id, func_actual_value,
     al.metric_id, al.act_metric_used_by_id
      FROM
      (SELECT
      ACTIVITY_METRIC_ID,
      count(distinct nvl(contact_rel_party_id, primary_party_id)) targets,
      count(DISTINCT header_id) order_count,
      sum(ams_actmetrics_seed_pvt.convert_currency(currency_code, booked_revenue)) booked_revenue
      FROM (
       SELECT /*+ ordered */ H.header_id, H.transactional_curr_code currency_code,
               sum(nvl(I.ordered_quantity * I.unit_selling_price,0)) booked_revenue,
                csch_parties.ACTIVITY_METRIC_ID,
            primary_party_id, contact_rel_party_id
       from (
			SELECT decode(SRC.SOURCE_CATEGORY, 'B2C', ENTRY.PARTY_ID,
			               'B2B', REL.OBJECT_ID, null) PRIMARY_PARTY_ID,
			       decode(SRC.SOURCE_CATEGORY, 'B2C', NULL,
				           'B2B', ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID, null)
				   CONTACT_REL_PARTY_ID,
             CS.LAST_ACTIVATION_DATE, AM.ACTIVITY_METRIC_ID,
			 SRC.SOURCE_CATEGORY, CS.SCHEDULE_ID OBJECT_ID
			FROM AMS_METRICS_ALL_B MB,
			     AMS_ACT_METRICS_ALL AM ,
			     AMS_CAMPAIGN_SCHEDULES_B CS ,
			     AMS_LIST_HEADERS_ALL LHA ,
			     AMS_LIST_ENTRIES ENTRY ,
			     HZ_RELATIONSHIPS REL,
			     AMS_LIST_SRC_TYPES SRC
			WHERE AM.METRIC_ID = MB.METRIC_ID
			  AND AM.ARC_ACT_METRIC_USED_BY = 'CSCH'
			  AND AM.ACT_METRIC_USED_BY_ID = CS.SCHEDULE_ID
			  AND MB.ENABLED_FLAG = 'Y'
			  AND MB.METRIC_ID IN (391,381,392,382)
              AND NVL(AM.LAST_CALCULATED_DATE,l_today ) > l_today - G_CALC_LAG_DAYS
			  AND 'Y' = DECODE(MB.METRIC_ID,
                    392, ENTRY.ENABLED_FLAG,
                    382, ENTRY.ENABLED_FLAG,
                    391, ENTRY.PART_OF_CONTROL_GROUP_FLAG,
                    381, ENTRY.PART_OF_CONTROL_GROUP_FLAG,'N')
			  AND ENTRY.LIST_HEADER_ID = LHA.LIST_HEADER_ID
			  AND CS.SCHEDULE_ID = LHA.LIST_USED_BY_ID
			  AND 'CSCH' = LHA.ARC_LIST_USED_BY
			  AND  ENTRY.LIST_ENTRY_SOURCE_SYSTEM_TYPE = SRC.SOURCE_TYPE_CODE
			  AND SRC.LIST_SOURCE_TYPE = 'TARGET'
			  AND SRC.SOURCE_CATEGORY in ('B2C','B2B')
			  AND REL.PARTY_ID(+) = ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID
			  AND REL.DIRECTIONAL_FLAG(+) = 'F'
          ) csch_parties,
           hz_cust_accounts account,
           oe_order_headers_all H,
           oe_order_lines_all I,
           ams_act_products aprod
        where csch_parties.primary_party_id = account.party_id
        AND H.sold_to_org_id = account.cust_account_id
        AND ((source_category = 'B2B'
              AND exists (select 1 from hz_cust_account_roles roles
               where H.sold_to_contact_id = roles.cust_account_role_id
               AND roles.cust_account_id = account.cust_account_id
               AND roles.party_id = csch_parties.contact_rel_party_id
               AND rownum = 1))
           OR
            (source_category = 'B2C'))
         and H.booked_flag = 'Y'
         AND H.booked_date IS NOT NULL
         AND H.flow_status_code = 'BOOKED'
         and aprod.arc_act_product_used_by = 'CSCH'
         and aprod.act_product_used_by_id = csch_parties.object_id
         -- Commenting out this line since sold_from_org_id doesn't get
         -- populated. Bug#5139222
         -- and aprod.organization_id = i.sold_from_org_id
         and aprod.INVENTORY_ITEM_ID = i.ordered_item_id
         and aprod.level_type_code = 'PRODUCT'
         AND H.header_id = I.header_id
         -- AND H.creation_date
	 AND H.ordered_date
             between csch_parties.last_activation_date
             and csch_parties.last_activation_date + l_inferred_period
         group by H.header_id, H.transactional_curr_code ,
             csch_parties.object_id, csch_parties.activity_metric_id,
           primary_party_id, contact_rel_party_id
        ) csch_orders
            GROUP BY csch_orders.activity_metric_id
         ) T,
             ams_act_metrics_all AL, ams_metrics_all_b ALB
         WHERE ALB.metric_id IN (391,381,392,382)
         AND   AL.metric_id = ALB.metric_id
         AND   ALB.enabled_flag = 'Y'
         and l_today - G_CALC_LAG_DAYS < nvl(AL.last_calculated_date,l_today)
         AND   AL.activity_metric_id = t.activity_metric_id(+)
        )
      WHERE NVL(actual_value, 0) <> NVL(func_actual_value, -1);

      update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
      l_activity_metric_id_table.DELETE;
      l_actual_values_table.DELETE;

   end if;

end;

-- NAME
--     Calculate_Inferred_Metrics
--
-- PURPOSE
--     Calculate inferred activity for an object.
--
-- HISTORY
-- 11-Aug-2005   dmvincen created.
--
PROCEDURE Calculate_Inferred_Metrics(
          p_arc_act_metric_used_by VARCHAR2,
          p_act_metric_used_by_id NUMBER)
is
begin
   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_Inferred_Metrics',
               'object type='||p_arc_act_metric_used_by,
            'object id='||p_act_metric_used_by_id);
   END IF;
   Calculate_Inferred_Responses(p_arc_act_metric_used_by, p_act_metric_used_by_id);

   Calculate_Inferred_Leads(p_arc_act_metric_used_by, p_act_metric_used_by_id);

   Calculate_Inferred_Orders(p_arc_act_metric_used_by, p_act_metric_used_by_id);
   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_Inferred_Metrics','END');
   END IF;

end;
--------------------------------------------------------------------
-- Following API are added by rrajesh on 06/06 for fixing Performance issues; each SQL has a buffer get < 1 M
--------------------------------------------------------------------
-- NAME
--     Calc_Inf_Resp_new
--
-- PURPOSE
--     Calculate inferred responses for all objects.
--     Storing the targted parties in global temp table to improve performance
-- HISTORY
-- 15-Jun-2006   rrajesh created.
--
--------------------------------------------------------------------
PROCEDURE Calc_Inf_Resp_new
is
   l_actual_values_table num_table_type;
   l_activity_metric_id_table num_table_type;
   l_today DATE := sysdate;
   cursor c_has_inferred_enabled IS
     SELECT count(distinct b.metric_id) metric_count,
            count(activity_metric_id) activity_count
     FROM ams_metrics_all_b b, ams_act_metrics_all a
     WHERE b.metric_id IN (361,362)
     AND enabled_flag = G_IS_ENABLED
     AND a.metric_id = b.metric_id
     AND nvl(last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS;

   l_has_enabled NUMBER;
   l_activity_count NUMBER;
   l_inferred_period number := fnd_profile.value('AMS_METR_INFERRED_PERIOD');



begin
   open c_has_inferred_enabled;
   fetch c_has_inferred_enabled into l_has_enabled, l_activity_count;
   close c_has_inferred_enabled;

   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_Inferred_Responses','Enabled Count='||l_has_enabled,
           'Activity Count='||l_activity_count);
   END IF;


   IF l_has_enabled > 0 THEN

	INSERT INTO AMS_INFMET_RESP_GT(PRIMARY_PARTY_ID, CONTACT_REL_PARTY_ID,
			LAST_ACTIVATION_DATE, ACTIVITY_METRIC_ID, SOURCE_CATEGORY)
        SELECT decode(SRC.SOURCE_CATEGORY, 'B2C', ENTRY.PARTY_ID,
      			               'B2B', REL.OBJECT_ID, null) PRIMARY_PARTY_ID,
			       decode(SRC.SOURCE_CATEGORY,'B2C', NULL,
				           'B2B', ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID, null)
				   CONTACT_REL_PARTY_ID,
             CS.LAST_ACTIVATION_DATE, AM.ACTIVITY_METRIC_ID,
			 SRC.SOURCE_CATEGORY
			FROM AMS_CAMPAIGN_SCHEDULES_B CS ,
			     AMS_LIST_HEADERS_ALL LHA ,  AMS_LIST_ENTRIES ENTRY ,
			     AMS_ACT_METRICS_ALL AM ,  AMS_METRICS_ALL_B MB,    HZ_RELATIONSHIPS REL,
			     AMS_LIST_SRC_TYPES SRC
			WHERE AM.METRIC_ID = MB.METRIC_ID
			  AND AM.ARC_ACT_METRIC_USED_BY = 'CSCH'
			  AND AM.ACT_METRIC_USED_BY_ID = CS.SCHEDULE_ID
			  AND MB.ENABLED_FLAG = 'Y'
			  AND MB.METRIC_ID IN (361,362)
                          AND NVL(AM.LAST_CALCULATED_DATE,l_today ) > l_today - G_CALC_LAG_DAYS
			  -- AND NVL(AM.LAST_CALCULATED_DATE,sysdate) > sysdate - 90
			  AND 'Y' = DECODE(MB.METRIC_ID, 362, ENTRY.ENABLED_FLAG,
			               361, ENTRY.PART_OF_CONTROL_GROUP_FLAG,'N')
			  AND ENTRY.LIST_HEADER_ID = LHA.LIST_HEADER_ID
			  AND CS.SCHEDULE_ID = LHA.LIST_USED_BY_ID
			  AND 'CSCH' = LHA.ARC_LIST_USED_BY
			  AND  ENTRY.LIST_ENTRY_SOURCE_SYSTEM_TYPE = SRC.SOURCE_TYPE_CODE
			  AND SRC.LIST_SOURCE_TYPE = 'TARGET'
			  AND SRC.SOURCE_CATEGORY in ('B2C','B2B')
			  AND REL.PARTY_ID(+) = ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID
			  AND REL.DIRECTIONAL_FLAG(+) ='F';

      SELECT NVL(actual_value, 0), activity_metric_id
      BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
      from (select actual_value, actmet.activity_metric_id, func_actual_value
      FROM (
        select count(1) actual_value, ACTIVITY_METRIC_ID
        from AMS_INFMET_RESP_GT csch_parties
         where exists (select /*+ use_concat */ 1
		 from jtf_ih_interactions inter, jtf_ih_results_b result
         WHERE result.positive_response_flag = 'Y'
         AND   result.result_id = inter.result_id
         and   ((source_category = 'B2B'
            and   inter.contact_rel_party_id = csch_parties.contact_rel_party_id
            and   inter.primary_party_id = csch_parties.primary_party_id)
           OR
               (source_category = 'B2C'
               and inter.party_id = csch_parties.primary_party_id))
         and inter.creation_date between csch_parties.last_activation_date
               and csch_parties.last_activation_date + l_inferred_period
		-- and csch_parties.last_activation_date + 90
         and rownum = 1)
      group by ACTIVITY_METRIC_ID
        ) resp
        , ams_act_metrics_all actmet, ams_metrics_all_b ALB
    WHERE ALB.metric_id in (361,362)
    AND   actmet.metric_id = ALB.metric_id
    AND   ALB.enabled_flag = 'Y'
    and l_today - G_CALC_LAG_DAYS < nvl(actmet.last_calculated_date,l_today)
    -- and sysdate - 90 < nvl(actmet.last_calculated_date,sysdate)
    AND actmet.ACTIVITY_METRIC_ID = resp.ACTIVITY_METRIC_ID(+)
    )
    where NVL(actual_value, 0) <> NVL(func_actual_value, -1);

    update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
    l_activity_metric_id_table.DELETE;
    l_actual_values_table.DELETE;

   end if;

end;
------------------------------------------------------------------------------
-- NAME
--     Calc_Inf_Order_new
--
-- PURPOSE
--     Calculate inferred orders for all objects.
--     Storing the targted parties in global temp table to improve performance
-- HISTORY
-- 16-Jun-2006   rrajesh created.
--
------------------------------------------------------------------------------
PROCEDURE Calc_Inf_Order_new
is
   l_actual_values_table num_table_type;
   l_activity_metric_id_table num_table_type;
   l_today DATE := sysdate;
   cursor c_has_inferred_enabled IS
     SELECT count(distinct b.metric_id) metric_count,
            count(activity_metric_id) activity_count
     FROM ams_metrics_all_b b, ams_act_metrics_all a
     WHERE b.metric_id IN (381,382,391,392)
     AND enabled_flag = G_IS_ENABLED
     AND a.metric_id = b.metric_id
     AND nvl(last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS;

   l_has_enabled NUMBER;
   l_activity_count NUMBER;
   l_inferred_period number := fnd_profile.value('AMS_METR_INFERRED_PERIOD');
   l_sql_stmt VARCHAR2(2000);

begin
   open c_has_inferred_enabled;
   fetch c_has_inferred_enabled into l_has_enabled,l_activity_count;
   close c_has_inferred_enabled;

   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_Inferred_Orders','Enabled Count='||l_has_enabled,
          'Activity Count='||l_activity_count);
   END IF;

   if l_has_enabled > 0 then
      /* INSERT INTO AMS_INFMET_ORDER_GT(PRIMARY_PARTY_ID, CONTACT_REL_PARTY_ID,
			LAST_ACTIVATION_DATE, ACTIVITY_METRIC_ID, SOURCE_CATEGORY, OBJECT_ID)
      SELECT decode(SRC.SOURCE_CATEGORY, 'B2C', ENTRY.PARTY_ID,
			               'B2B', REL.OBJECT_ID, null) PRIMARY_PARTY_ID,
             decode(SRC.SOURCE_CATEGORY, 'B2C', NULL,
			           'B2B', ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID, null) CONTACT_REL_PARTY_ID,
             CS.LAST_ACTIVATION_DATE, AM.ACTIVITY_METRIC_ID, SRC.SOURCE_CATEGORY, CS.SCHEDULE_ID OBJECT_ID
			FROM AMS_METRICS_ALL_B MB,
			     AMS_ACT_METRICS_ALL AM ,
			     AMS_CAMPAIGN_SCHEDULES_B CS ,
			     AMS_LIST_HEADERS_ALL LHA ,
			     AMS_LIST_ENTRIES ENTRY ,
			     HZ_RELATIONSHIPS REL,
			     AMS_LIST_SRC_TYPES SRC
			WHERE AM.METRIC_ID = MB.METRIC_ID
			  AND AM.ARC_ACT_METRIC_USED_BY = 'CSCH'
			  AND AM.ACT_METRIC_USED_BY_ID = CS.SCHEDULE_ID
			  AND MB.ENABLED_FLAG = 'Y'
			  AND MB.METRIC_ID IN (391,381,392,382)
              AND NVL(AM.LAST_CALCULATED_DATE,l_today ) > l_today - G_CALC_LAG_DAYS
	      -- AND NVL(AM.LAST_CALCULATED_DATE,sysdate ) > sysdate - 90
			  AND 'Y' = DECODE(MB.METRIC_ID,
                    392, ENTRY.ENABLED_FLAG,
                    382, ENTRY.ENABLED_FLAG,
                    391, ENTRY.PART_OF_CONTROL_GROUP_FLAG,
                    381, ENTRY.PART_OF_CONTROL_GROUP_FLAG,'N')
			  AND ENTRY.LIST_HEADER_ID = LHA.LIST_HEADER_ID
			  AND CS.SCHEDULE_ID = LHA.LIST_USED_BY_ID
			  AND 'CSCH' = LHA.ARC_LIST_USED_BY
			  AND  ENTRY.LIST_ENTRY_SOURCE_SYSTEM_TYPE = SRC.SOURCE_TYPE_CODE
			  AND SRC.LIST_SOURCE_TYPE = 'TARGET'
			  AND SRC.SOURCE_CATEGORY in ('B2C','B2B')
			  AND REL.PARTY_ID(+) = ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID
			  AND REL.DIRECTIONAL_FLAG(+) = 'F'; */

    -- Splitting the SQL between order number metrices and revenue metrices
    l_sql_stmt := 'INSERT INTO AMS_INFMET_ORDER_GT(PRIMARY_PARTY_ID, CONTACT_REL_PARTY_ID,
			LAST_ACTIVATION_DATE, ACTIVITY_METRIC_ID, SOURCE_CATEGORY, OBJECT_ID)
      SELECT decode(SRC.SOURCE_CATEGORY, ''B2C'', ENTRY.PARTY_ID,
			               ''B2B'', REL.OBJECT_ID, null) PRIMARY_PARTY_ID,
             decode(SRC.SOURCE_CATEGORY, ''B2C'', NULL,
			           ''B2B'', ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID, null) CONTACT_REL_PARTY_ID,
             CS.LAST_ACTIVATION_DATE, AM.ACTIVITY_METRIC_ID, SRC.SOURCE_CATEGORY, CS.SCHEDULE_ID OBJECT_ID
			FROM AMS_METRICS_ALL_B MB,
			     AMS_ACT_METRICS_ALL AM ,
			     AMS_CAMPAIGN_SCHEDULES_B CS ,
			     AMS_LIST_HEADERS_ALL LHA ,
			     AMS_LIST_ENTRIES ENTRY ,
			     HZ_RELATIONSHIPS REL,
			     AMS_LIST_SRC_TYPES SRC
			WHERE AM.METRIC_ID = MB.METRIC_ID
			  AND AM.ARC_ACT_METRIC_USED_BY = ''CSCH''
			  AND AM.ACT_METRIC_USED_BY_ID = CS.SCHEDULE_ID
			  AND MB.ENABLED_FLAG = ''Y''
			  AND MB.METRIC_ID IN (:1, :2)
              AND NVL(AM.LAST_CALCULATED_DATE,l_today ) > l_today - G_CALC_LAG_DAYS
	      -- AND NVL(AM.LAST_CALCULATED_DATE,sysdate ) > sysdate - 90
			  AND ''Y'' = DECODE(MB.METRIC_ID,
                    :3, ENTRY.PART_OF_CONTROL_GROUP_FLAG,
		    :4, ENTRY.ENABLED_FLAG,''N'')
			  AND ENTRY.LIST_HEADER_ID = LHA.LIST_HEADER_ID
			  AND CS.SCHEDULE_ID = LHA.LIST_USED_BY_ID
			  AND ''CSCH'' = LHA.ARC_LIST_USED_BY
			  AND  ENTRY.LIST_ENTRY_SOURCE_SYSTEM_TYPE = SRC.SOURCE_TYPE_CODE
			  AND SRC.LIST_SOURCE_TYPE = ''TARGET''
			  AND SRC.SOURCE_CATEGORY in (''B2C'',''B2B'')
			  AND REL.PARTY_ID(+) = ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID
			  AND REL.DIRECTIONAL_FLAG(+) = ''F'' ';

    EXECUTE IMMEDIATE l_sql_stmt USING '381', '382', '381', '382';
    EXECUTE IMMEDIATE l_sql_stmt USING '391', '392', '391', '392';

    -- Using ordered and NL hint so that the ams_act_product gets the first hit.
    -- This change brought down the buffer get from 4 M to 550269.

    SELECT NVL(actual_value, 0), activity_metric_id
    BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
    FROM (
      SELECT
      decode(al.metric_id
      , 381, order_count, 382, order_count
      , 391, booked_revenue, 392, booked_revenue
      , 0 ) actual_value, al.activity_metric_id, func_actual_value,
     al.metric_id, al.act_metric_used_by_id
      FROM
      (SELECT
      ACTIVITY_METRIC_ID,
      count(distinct nvl(contact_rel_party_id, primary_party_id)) targets,
      count(DISTINCT header_id) order_count,
      sum(ams_actmetrics_seed_pvt.convert_currency(currency_code, booked_revenue)) booked_revenue
      FROM (
       SELECT /*+ ordered USE_NL(ACCOUNT H) */ H.header_id, H.transactional_curr_code currency_code,
               sum(nvl(I.ordered_quantity * I.unit_selling_price,0)) booked_revenue,
                csch_parties.ACTIVITY_METRIC_ID,
            primary_party_id, contact_rel_party_id
       from AMS_INFMET_ORDER_GT csch_parties,
           ams_act_products aprod,
           hz_cust_accounts account,
           oe_order_headers_all H,
           oe_order_lines_all I
        where csch_parties.primary_party_id = account.party_id
        AND H.sold_to_org_id = account.cust_account_id
        AND ((source_category = 'B2B'
              AND exists (select 1 from hz_cust_account_roles roles
               where H.sold_to_contact_id = roles.cust_account_role_id
               AND roles.cust_account_id = account.cust_account_id
               AND roles.party_id = csch_parties.contact_rel_party_id
               AND rownum = 1))
           OR
            (source_category = 'B2C'))
         and H.booked_flag = 'Y'
         AND H.booked_date IS NOT NULL
         AND H.flow_status_code = 'BOOKED'
         and aprod.arc_act_product_used_by = 'CSCH'
         and aprod.act_product_used_by_id = csch_parties.object_id
         and aprod.INVENTORY_ITEM_ID = i.ordered_item_id
         and aprod.level_type_code = 'PRODUCT'
         AND H.header_id = I.header_id
         AND H.ordered_date
             between csch_parties.last_activation_date
             and csch_parties.last_activation_date + l_inferred_period
	     -- and csch_parties.last_activation_date + 90
         group by H.header_id, H.transactional_curr_code ,
             csch_parties.object_id, csch_parties.activity_metric_id,
           primary_party_id, contact_rel_party_id
        ) csch_orders
            GROUP BY csch_orders.activity_metric_id
         ) T,
             ams_act_metrics_all AL, ams_metrics_all_b ALB
         WHERE ALB.metric_id IN (391,381,392,382)
         AND   AL.metric_id = ALB.metric_id
         AND   ALB.enabled_flag = 'Y'
         -- and sysdate - 90 < nvl(AL.last_calculated_date,sysdate)
	 and l_today - G_CALC_LAG_DAYS < nvl(AL.last_calculated_date,l_today)
         AND   AL.activity_metric_id = t.activity_metric_id(+)
        )
      WHERE NVL(actual_value, 0) <> NVL(func_actual_value, -1);

      update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
      l_activity_metric_id_table.DELETE;
      l_actual_values_table.DELETE;

   end if;

end;
----------------------------------------------------
-- NAME
--     Calc_Inf_Lead_new
--
-- PURPOSE
--     Calculate inferred leads for all objects.
--     Storing the targted parties in global temp table to improve performance
-- HISTORY
-- 16-Jun-2006   rrajesh created.
--
------------------------------------------------------------------------------
PROCEDURE Calc_Inf_Lead_new
is
   l_actual_values_table num_table_type;
   l_activity_metric_id_table num_table_type;
   l_today DATE := sysdate;
   cursor c_has_inferred_enabled IS
     SELECT count(distinct b.metric_id) metric_count,
            count(activity_metric_id) activity_count
     FROM ams_metrics_all_b b, ams_act_metrics_all a
     WHERE b.metric_id IN (371,372)
     AND enabled_flag = G_IS_ENABLED
     AND a.metric_id = b.metric_id
     AND nvl(last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS;

   l_has_enabled NUMBER;
   l_activity_count NUMBER;
   l_inferred_period number := fnd_profile.value('AMS_METR_INFERRED_PERIOD');
begin
   open c_has_inferred_enabled;
   fetch c_has_inferred_enabled into l_has_enabled,l_activity_count;
   close c_has_inferred_enabled;

   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_Inferred_Leads','Enabled Count='||l_has_enabled,
         'Activity Count='||l_activity_count);
   END IF;

   if l_has_enabled > 0 then

     INSERT INTO AMS_INFMET_LEAD_GT(PRIMARY_PARTY_ID, CONTACT_REL_PARTY_ID,
			LAST_ACTIVATION_DATE, ACTIVITY_METRIC_ID, SOURCE_CATEGORY, OBJECT_ID)
     SELECT decode(SRC.SOURCE_CATEGORY, 'B2C', ENTRY.PARTY_ID,
			               'B2B', REL.OBJECT_ID, null) PRIMARY_PARTY_ID,
			       decode(SRC.SOURCE_CATEGORY, 'B2C', NULL,
				           'B2B', ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID, null)
				   CONTACT_REL_PARTY_ID,
             CS.LAST_ACTIVATION_DATE, AM.ACTIVITY_METRIC_ID,
			 SRC.SOURCE_CATEGORY, CS.SCHEDULE_ID OBJECT_ID
			FROM AMS_CAMPAIGN_SCHEDULES_B CS ,
			     AMS_LIST_HEADERS_ALL LHA ,
			     AMS_LIST_ENTRIES ENTRY ,
			     AMS_ACT_METRICS_ALL AM ,
			     AMS_METRICS_ALL_B MB,
			     HZ_RELATIONSHIPS REL,
			     AMS_LIST_SRC_TYPES SRC
			WHERE AM.METRIC_ID = MB.METRIC_ID
			  AND AM.ARC_ACT_METRIC_USED_BY = 'CSCH'
			  AND AM.ACT_METRIC_USED_BY_ID = CS.SCHEDULE_ID
			  AND MB.ENABLED_FLAG = 'Y'
			  AND MB.METRIC_ID IN (371,372)
              AND nvl(am.last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS
	      -- AND nvl(am.last_calculated_date,sysdate) > sysdate - 90
			  AND 'Y' = DECODE(MB.METRIC_ID, 372, ENTRY.ENABLED_FLAG,
			               371, ENTRY.PART_OF_CONTROL_GROUP_FLAG,'N')
			  AND ENTRY.LIST_HEADER_ID = LHA.LIST_HEADER_ID
			  AND CS.SCHEDULE_ID = LHA.LIST_USED_BY_ID
			  AND 'CSCH' = LHA.ARC_LIST_USED_BY
			  AND  ENTRY.LIST_ENTRY_SOURCE_SYSTEM_TYPE = SRC.SOURCE_TYPE_CODE
			  AND SRC.LIST_SOURCE_TYPE = 'TARGET'
			  AND SRC.SOURCE_CATEGORY in ('B2C','B2B')
			  AND REL.PARTY_ID(+) = ENTRY.LIST_ENTRY_SOURCE_SYSTEM_ID
			  AND REL.DIRECTIONAL_FLAG(+) = 'F' ;

     SELECT NVL(actual_value, 0), activity_metric_id
      BULK COLLECT INTO l_actual_values_table, l_activity_metric_id_table
      FROM (select actual_value, am.activity_metric_id, am.func_actual_value
       from (
      select count(1) actual_value, activity_metric_id
      from AMS_INFMET_LEAD_GT csch_parties
      where exists (select 1
	     from as_sales_leads lead, as_statuses_b lead_status
         where lead.status_code = lead_status.status_code
         AND lead_status.lead_flag = 'Y'
         AND lead_status.enabled_flag = 'Y'
         AND NVL(lead.deleted_flag, 'N') <> 'Y'
         and ((source_category = 'B2C' AND lead.customer_id = csch_parties.primary_party_id)
            OR
            (source_category = 'B2B' and lead.customer_id = csch_parties.primary_party_id
             and lead.primary_contact_party_id = csch_parties.contact_rel_party_id))
        and lead.creation_date between csch_parties.last_activation_date
             and csch_parties.last_activation_date + l_inferred_period
	     -- and csch_parties.last_activation_date + 90
         AND exists (select 1
            from as_sales_lead_lines LL, ams_act_products actprod
            where ll.inventory_item_id = actprod.INVENTORY_ITEM_ID
            and ll.organization_id = actprod.organization_id
            and ll.sales_lead_id = lead.sales_lead_id
            and actprod.arc_act_product_used_by = 'CSCH'
            and actprod.act_product_used_by_id = csch_parties.object_id
            and actprod.level_type_code = 'PRODUCT'
            and rownum = 1
            )
        and rownum = 1
        )
       group by activity_metric_id) leads,
        ams_act_metrics_all am, ams_metrics_all_b mb
      WHERE am.metric_id = mb.metric_id
      and am.arc_act_metric_used_by = 'CSCH'
      and mb.enabled_flag = 'Y'
      and mb.metric_id in (371,372)
      AND nvl(am.last_calculated_date,l_today) > l_today - G_CALC_LAG_DAYS
      -- AND nvl(am.last_calculated_date,sysdate) > sysdate - 90
      and leads.activity_metric_id(+) = am.activity_metric_id)
      where NVL(actual_value, 0) <> NVL(func_actual_value, -1);

      update_actmetrics_bulk(l_activity_metric_id_table, l_actual_values_table);
      l_activity_metric_id_table.DELETE;
      l_actual_values_table.DELETE;

   end if;

end;
------------------------------------------------------------------------------
-- NAME
--     Calculate_Inferred_Metrics
--
-- PURPOSE
--     Calculate inferred activity for a all objects.
--
-- HISTORY
-- 11-Aug-2005   dmvincen created.
--
------------------------------------------------------------------------------
PROCEDURE Calculate_Inferred_Metrics
is
begin
   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_Inferred_Metrics','BEGIN, ALL');
   END IF;

   -- Replacing the inferred metrics APIs with new ones using Global temporary tables

   -- Calculate_Inferred_Responses;
   Calc_Inf_Resp_new;

   -- Calculate_Inferred_Leads;
   Calc_Inf_Lead_new;

   -- Calculate_Inferred_Orders;
   Calc_Inf_Order_new;

   IF AMS_DEBUG_HIGH_ON THEN
      Write_Log('Calculate_Inferred_Metrics','END');
   END IF;

end;

END Ams_Actmetrics_Seed_Pvt;

/
