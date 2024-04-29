--------------------------------------------------------
--  DDL for Package Body BIM_KPI_FACT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_KPI_FACT" AS
/* $Header: bimkpifb.pls 120.0 2005/05/31 13:17:49 appldev noship $*/

G_PKG_NAME  CONSTANT  VARCHAR2(20) :='BIM_KPI_FACT';
G_FILE_NAME CONSTANT  VARCHAR2(20) :='bimkpifb.pls';

---------------------------------------------------------------------
-- FUNCTION
--    calculate_days
-- NOTE
-- PARAMETER
--   p_start_date      IN  DATE,
--   p_end_date        IN  DATE,
--   p_aggregate       IN  VARCHAR2
--   p_period          IN  VARCHAR2
-- RETURN   NUMBER
---------------------------------------------------------------------
FUNCTION  calculate_days(
   p_start_date       DATE
   ,p_end_date        DATE
   ,p_aggregate       VARCHAR2
   ,p_period          VARCHAR2) return NUMBER
IS

l_date DATE;
l_days number;
l_day_code VARCHAR2(30);
l_week_code VARCHAR2(30);
l_month_code VARCHAR2(30);
l_quarter_code VARCHAR2(30);
l_year_code VARCHAR2(30);
l_cur_period_start_date date;
l_cur_period_end_date date;
l_prev_period_start_date date;
l_prev_period_end_date date;
l_period_start_date date;
l_period_end_date date;
l_temp_start_date date;
l_temp_end_date date;
l_org_id number;

BEGIN

   l_day_code := 'DAY';
   l_week_code := 'WEEK';
   l_month_code := 'MONTH';
   l_quarter_code := 'QUARTER';
   l_year_code := 'YEAR';

   l_date := sysdate - 1;
   l_org_id := 204;

   IF (p_aggregate = l_day_code) THEN
     IF (p_aggregate = 'Current') THEN
       IF (p_end_date >= l_date) THEN
         RETURN 1;
       ELSE
         RETURN 0;
       END IF;
     ELSE
       IF (p_end_date >= l_date -1) THEN
         RETURN 1;
       ELSE
         RETURN 0;
       END IF;
     END IF;
   END IF;

   IF (p_aggregate = l_month_code) THEN
     l_cur_period_start_date := BIM_SET_OF_BOOKS.GET_FISCAL_MONTH_START(l_date, l_org_id);
     l_cur_period_end_date := BIM_SET_OF_BOOKS.GET_FISCAL_MONTH_END(l_date, l_org_id);
     IF (p_period = 'Previous') THEN
       l_prev_period_start_date := BIM_SET_OF_BOOKS.GET_FISCAL_MONTH_START(l_cur_period_start_date - 1, l_org_id);
       l_prev_period_end_date := BIM_SET_OF_BOOKS.GET_FISCAL_MONTH_END(l_cur_period_start_date - 1, l_org_id);
     END IF;
   ELSIF (p_aggregate = l_quarter_code) THEN
     l_cur_period_start_date := BIM_SET_OF_BOOKS.GET_FISCAL_QTR_START(l_date, l_org_id);
     l_cur_period_end_date := BIM_SET_OF_BOOKS.GET_FISCAL_QTR_END(l_date, l_org_id);
     IF (p_period = 'Previous') THEN
       l_prev_period_start_date := BIM_SET_OF_BOOKS.GET_FISCAL_QTR_START(l_cur_period_start_date - 1, l_org_id);
       l_prev_period_end_date := BIM_SET_OF_BOOKS.GET_FISCAL_QTR_END(l_cur_period_start_date - 1, l_org_id);
     END IF;
   ELSIF (p_aggregate = l_year_code) THEN
     l_cur_period_start_date := BIM_SET_OF_BOOKS.GET_FISCAL_YEAR_START(l_date, l_org_id);
     l_cur_period_end_date := BIM_SET_OF_BOOKS.GET_FISCAL_YEAR_END(l_date, l_org_id);
     IF (p_period = 'Previous') THEN
       l_prev_period_start_date := BIM_SET_OF_BOOKS.GET_FISCAL_YEAR_START(l_cur_period_start_date - 1, l_org_id);
       l_prev_period_end_date := BIM_SET_OF_BOOKS.GET_FISCAL_YEAR_END(l_cur_period_start_date - 1, l_org_id);
     END IF;
   ELSIF (p_aggregate = l_week_code) THEN
     select next_day(l_date-7, TO_NUMBER(to_char(to_date('01/09/2004', 'DD/MM/RRRR'), 'DD'))) into l_cur_period_start_date from dual;
     select next_day(l_date, TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) into l_cur_period_end_date from dual;
     IF (p_period = 'Previous') THEN
       select next_day(l_date-14, TO_NUMBER(to_char(to_date('01/09/2004', 'DD/MM/RRRR'), 'DD'))) into l_prev_period_start_date from dual;
       select next_day(l_prev_period_start_date,  TO_NUMBER(to_char(to_date('07/09/2004', 'DD/MM/RRRR'), 'DD'))) into l_prev_period_end_date from dual;
     END IF;
   END IF;
   IF (p_period = 'Previous') THEN
     l_days := trunc(l_date) - trunc(l_cur_period_start_date);
     IF trunc(l_cur_period_end_date) = trunc(l_date) THEN
        l_period_end_date := l_prev_period_end_date;
     ELSE
        l_period_end_date := l_prev_period_start_date + l_days;
     END IF;
     l_period_start_date := l_prev_period_start_date;
   ELSE
     l_period_start_date := l_cur_period_start_date;
     l_period_end_date := l_date;
   END IF;
   --dbms_output.put_line('period_start_date   -- ' || l_period_start_date);
   --dbms_output.put_line('period_end_date   -- ' || l_period_end_date);

   --dbms_output.put_line('p_start_date  -- ' || p_start_date);
   --dbms_output.put_line('p_end_date   -- ' || p_end_date);

   l_days := 0;
   IF (p_start_date > l_period_end_date) THEN
      l_days := 0;
   ELSIF (p_end_date < l_period_start_date) THEN
      l_days := 0;
   ELSIF (p_start_date <= l_period_start_date) THEN
      l_temp_start_date := l_period_start_date;
      IF(p_end_date >= l_period_end_date) THEN
         l_temp_end_date := l_period_end_date;
      ELSE
         l_temp_end_date := p_end_date;
      END IF;
      l_days := trunc(l_temp_end_date) - trunc(l_temp_start_date) + 1;
   ELSIF (p_start_date > l_period_start_date) THEN
      l_temp_start_date := p_start_date;
      IF(p_end_date >= l_period_end_date) THEN
        l_temp_end_date := l_period_end_date;
      ELSE
        l_temp_end_date := p_end_date;
      END IF;
      l_days := trunc(l_temp_end_date) -  trunc(l_temp_start_date) + 1;
   END IF;

   --dbms_output.put_line('l_days   -- ' || l_days);

   RETURN (l_days);
END calculate_days;

-----------------------------------------------------------------------
-- PROCEDURE
--    POPULATE
--
-----------------------------------------------------------------------

PROCEDURE POPULATE
   (ERRBUF                  OUT  NOCOPY VARCHAR2,
    RETCODE                 OUT  NOCOPY NUMBER
    ) IS

l_org_id NUMBER;
l_days NUMBER;
l_date DATE;
l_day_code VARCHAR2(30);
l_week_code VARCHAR2(30);
l_month_code VARCHAR2(30);
l_quarter_code VARCHAR2(30);
l_year_code VARCHAR2(30);
l_cur_year_start_date DATE;
l_cur_year_end_date DATE;
l_pre_year_start_date DATE;
l_pre_year_end_date DATE;
l_cur_qtr_start_date DATE;
l_cur_qtr_end_date DATE;
l_pre_qtr_start_date DATE;
l_pre_qtr_end_date DATE;
l_cur_month_start_date DATE;
l_cur_month_end_date DATE;
l_pre_month_start_date DATE;
l_pre_month_end_date DATE;
l_cur_week_start_date DATE;
l_cur_week_end_date DATE;
l_pre_week_start_date DATE;
l_pre_week_end_date DATE;
l_status                      VARCHAR2(5);
l_industry                    VARCHAR2(5);
l_schema                      VARCHAR2(30);
l_return                       BOOLEAN;

BEGIN

  ERRBUF :='SUCCESS';
  RETCODE := 0;

  l_day_code := 'DAY';
  l_week_code := 'WEEK';
  l_month_code := 'MONTH';
  l_quarter_code := 'QUARTER';
  l_year_code := 'YEAR';

  ams_utility_pvt.write_conc_log('BIM_R_KPI_FACT: POPULATE START');
  l_return  := fnd_installation.get_app_info('BIM', l_status, l_industry, l_schema);
  l_date := sysdate - 1;
  l_org_id := 204;
  l_cur_year_start_date := BIM_SET_OF_BOOKS.GET_FISCAL_YEAR_START(l_date, l_org_id);
  l_cur_year_end_date := l_date;
  l_pre_year_start_date := BIM_SET_OF_BOOKS.GET_PRE_FISCAL_YEAR_START(l_date, l_org_id);
  l_pre_year_end_date := BIM_SET_OF_BOOKS.GET_PRE_FISCAL_YEAR_END(l_date, l_org_id);
  l_cur_qtr_start_date := BIM_SET_OF_BOOKS.GET_FISCAL_QTR_START(l_date, l_org_id);
  l_cur_qtr_end_date := l_date;
  l_pre_qtr_start_date := BIM_SET_OF_BOOKS.GET_PRE_FISCAL_QTR_START(l_date, l_org_id);
  l_pre_qtr_end_date := BIM_SET_OF_BOOKS.GET_PRE_FISCAL_QTR_END(l_date, l_org_id);
  l_cur_month_start_date := BIM_SET_OF_BOOKS.GET_FISCAL_MONTH_START(l_date, l_org_id);
  l_cur_month_end_date := l_date;
  l_pre_month_start_date := BIM_SET_OF_BOOKS.GET_PRE_FISCAL_MONTH_START(l_date, l_org_id);
  l_pre_month_end_date := BIM_SET_OF_BOOKS.GET_PRE_FISCAL_MONTH_END(l_date, l_org_id);
  select next_day(trunc(l_date)-7, TO_NUMBER(to_char(to_date('01/09/2004', 'DD/MM/RRRR'), 'DD'))) into l_cur_week_start_date from dual;
  l_cur_week_end_date := trunc(l_date);
  l_days :=  l_cur_week_end_date-l_cur_week_start_date ;
--l_days := l_days+1;
  select next_day(trunc(l_date)-14, TO_NUMBER(to_char(to_date('01/09/2004', 'DD/MM/RRRR'), 'DD'))) into l_pre_week_start_date from dual;
  l_pre_week_end_date := l_pre_week_start_date+l_days;

  ams_utility_pvt.write_conc_log('BIM_R_KPI_FACT: INSERT START');

  ams_utility_pvt.debug_message('POPULATE BIM_R_KPI_FACT START');

  EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.bim_r_kpi_facts';


  INSERT
    INTO bim_r_kpi_facts(
    creation_date,
    created_by,
    last_update_date,
    last_updated_by,
    last_update_login,
    object_id,
    object_type,
    region,
    country,
    business_unit,
    start_date,
    end_date,
    status,
    period_type,
    calculation_type,
    cost_cur_period,
    cost_pre_period,
    leads_cur_period,
    leads_pre_period,
    res_cur_period,
    res_pre_period,
    reg_cur_period,
    reg_pre_period,
    rev_cur_period,
    rev_pre_period,
    orders_cur_period,
    orders_pre_period,
    aleads_cur_period,
    aleads_pre_period
    )
  SELECT
     sysdate,
     -1,
     sysdate,
     -1,
     -1,
     inner.object_id,
     inner.object_type,
     inner.region,
     inner.country,
     inner.business_unit,
     inner.start_date,
     inner.end_date,
     inner.status,
     inner.period_type,
     inner.calculation_type,
     inner.cost_cur_period,
     inner.cost_pre_period,
     inner.leads_cur_period,
     inner.leads_pre_period,
     inner.res_cur_period,
     inner.res_pre_period,
     inner.reg_cur_period,
     inner.reg_pre_period,
     inner.rev_cur_period,
     inner.rev_pre_period,
     inner.orders_cur_period,
     inner.orders_pre_period,
     inner.aleads_cur_period,
     inner.aleads_pre_period
   FROM (
   SELECT
     a.campaign_id object_id,
     a.transaction_create_date,
     'CAMP' object_type,
     a.budget_approved budget_approved,
     a.campaign_region region,
     a.campaign_country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.campaign_status status,
     l_year_code period_type,
     'Cumulative' calculation_type,
     SUM(calculate_days(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     a.transaction_create_date,
     a.start_date),
     end_date,
     l_year_code,
     'Current')*(a.budget_approved/DECODE(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1)),
     0,
     1,
     DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1))))) cost_cur_period,
     0 cost_pre_period,
     0 leads_cur_period,
     0 leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     0 rev_cur_period,
     0 rev_pre_period,
     0 orders_cur_period,
     0 orders_pre_period,
     0 aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_camp_daily_facts a
   WHERE
     a.budget_approved > 0
   GROUP  BY a.campaign_id,
     a.transaction_create_date,
     a.start_date,
     a.end_date,
     a.budget_approved,
     a.campaign_region,
     a.campaign_country,
     a.business_unit_id,
     a.campaign_status
   UNION ALL
   SELECT
     a.campaign_id object_id,
     a.transaction_create_date,
     'CAMP' object_type,
     a.budget_approved budget_approved,
     a.campaign_region region,
     a.campaign_country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.campaign_status status,
     l_year_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     SUM(calculate_days(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     a.transaction_create_date,
     a.start_date),
     end_date,
     l_year_code,
     'Previous')*(a.budget_approved/DECODE(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1)),
     0,
     1,
     DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1))))) cost_cur_period,
     0 leads_cur_period,
     0 leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     0 rev_cur_period,
     0 rev_pre_period,
     0 orders_cur_period,
     0 orders_pre_period,
     0 aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_camp_daily_facts a
   WHERE
     a.budget_approved > 0
   GROUP  BY a.campaign_id,
     a.transaction_create_date,
     a.start_date,
     a.end_date,
     a.budget_approved,
     a.campaign_region,
     a.campaign_country,
     a.business_unit_id,
     a.campaign_status
   UNION ALL
   SELECT
     a.campaign_id object_id,
     a.transaction_create_date,
     'CAMP' object_type,
     a.budget_approved budget_approved,
     a.campaign_region region,
     a.campaign_country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.campaign_status status,
     l_quarter_code period_type,
     'Cumulative' calculation_type,
     SUM(calculate_days(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     a.transaction_create_date,
     a.start_date),
     end_date,
     l_quarter_code,
     'Current')*(a.budget_approved/DECODE(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1)),
     0,
     1,
     DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1))))) cost_cur_period,
     0 cost_pre_period,
     0 leads_cur_period,
     0 leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     0 rev_cur_period,
     0 rev_pre_period,
     0 orders_cur_period,
     0 orders_pre_period,
     0 aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_camp_daily_facts a
   WHERE
     a.budget_approved > 0
   GROUP  BY a.campaign_id,
     a.transaction_create_date,
     a.start_date,
     a.end_date,
     a.budget_approved,
     a.campaign_region,
     a.campaign_country,
     a.business_unit_id,
     a.campaign_status
   UNION ALL
   SELECT
     a.campaign_id object_id,
     a.transaction_create_date,
     'CAMP' object_type,
     a.budget_approved budget_approved,
     a.campaign_region region,
     a.campaign_country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.campaign_status status,
     l_quarter_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     SUM(calculate_days(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     a.transaction_create_date,
     a.start_date),
     end_date,
     l_quarter_code,
     'Previous')*(a.budget_approved/DECODE(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1)),
     0,
     1,
     DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1))))) cost_cur_period,
     0 leads_cur_period,
     0 leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     0 rev_cur_period,
     0 rev_pre_period,
     0 orders_cur_period,
     0 orders_pre_period,
     0 aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_camp_daily_facts a
   WHERE
     a.budget_approved > 0
   GROUP  BY a.campaign_id,
     a.transaction_create_date,
     a.start_date,
     a.end_date,
     a.budget_approved,
     a.campaign_region,
     a.campaign_country,
     a.business_unit_id,
     a.campaign_status
   UNION ALL
   SELECT
     a.campaign_id object_id,
     a.transaction_create_date,
     'CAMP' object_type,
     a.budget_approved budget_approved,
     a.campaign_region region,
     a.campaign_country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.campaign_status status,
     l_month_code period_type,
     'Cumulative' calculation_type,
     SUM(calculate_days(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     a.transaction_create_date,
     a.start_date),
     end_date,
     l_month_code,
     'Current')*(a.budget_approved/DECODE(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1)),
     0,
     1,
     DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1))))) cost_cur_period,
     0 cost_pre_period,
     0 leads_cur_period,
     0 leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     0 rev_cur_period,
     0 rev_pre_period,
     0 orders_cur_period,
     0 orders_pre_period,
     0 aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_camp_daily_facts a
   WHERE
     a.budget_approved > 0
   GROUP  BY a.campaign_id,
     a.transaction_create_date,
     a.start_date,
     a.end_date,
     a.budget_approved,
     a.campaign_region,
     a.campaign_country,
     a.business_unit_id,
     a.campaign_status
   UNION ALL
   SELECT
     a.campaign_id object_id,
     a.transaction_create_date,
     'CAMP' object_type,
     a.budget_approved budget_approved,
     a.campaign_region region,
     a.campaign_country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.campaign_status status,
     l_month_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     SUM(calculate_days(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     a.transaction_create_date,
     a.start_date),
     end_date,
     l_month_code,
     'Previous')*(a.budget_approved/DECODE(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1)),
     0,
     1,
     DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1))))) cost_cur_period,
     0 leads_cur_period,
     0 leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     0 rev_cur_period,
     0 rev_pre_period,
     0 orders_cur_period,
     0 orders_pre_period,
     0 aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_camp_daily_facts a
   WHERE
     a.budget_approved > 0
   GROUP  BY a.campaign_id,
     a.transaction_create_date,
     a.start_date,
     a.end_date,
     a.budget_approved,
     a.campaign_region,
     a.campaign_country,
     a.business_unit_id,
     a.campaign_status
   UNION ALL
   SELECT
     a.campaign_id object_id,
     a.transaction_create_date,
     'CAMP' object_type,
     a.budget_approved budget_approved,
     a.campaign_region region,
     a.campaign_country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.campaign_status status,
     l_week_code period_type,
     'Cumulative' calculation_type,
     SUM(calculate_days(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     a.transaction_create_date,
     a.start_date),
     end_date,
     l_week_code,
     'Current')*(a.budget_approved/DECODE(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1)),
     0,
     1,
     DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1))))) cost_cur_period,
     0 cost_pre_period,
     0 leads_cur_period,
     0 leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     0 rev_cur_period,
     0 rev_pre_period,
     0 orders_cur_period,
     0 orders_pre_period,
     0 aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_camp_daily_facts a
   WHERE
     a.budget_approved > 0
   GROUP  BY a.campaign_id,
     a.transaction_create_date,
     a.start_date,
     a.end_date,
     a.budget_approved,
     a.campaign_region,
     a.campaign_country,
     a.business_unit_id,
     a.campaign_status
   UNION ALL
   SELECT
     a.campaign_id object_id,
     a.transaction_create_date,
     'CAMP' object_type,
     a.budget_approved budget_approved,
     a.campaign_region region,
     a.campaign_country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.campaign_status status,
     l_week_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     SUM(calculate_days(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     a.transaction_create_date,
     a.start_date),
     end_date,
     l_week_code,
     'Previous')*(a.budget_approved/DECODE(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1)),
     0,
     1,
     DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1))))) cost_cur_period,
     0 leads_cur_period,
     0 leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     0 rev_cur_period,
     0 rev_pre_period,
     0 orders_cur_period,
     0 orders_pre_period,
     0 aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_camp_daily_facts a
   WHERE
     a.budget_approved > 0
   GROUP  BY a.campaign_id,
     a.transaction_create_date,
     a.start_date,
     a.end_date,
     a.budget_approved,
     a.campaign_region,
     a.campaign_country,
     a.business_unit_id,
     a.campaign_status
   UNION ALL
   SELECT
     a.campaign_id object_id,
     a.transaction_create_date,
     'CAMP' object_type,
     a.budget_approved budget_approved,
     a.campaign_region region,
     a.campaign_country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.campaign_status status,
     l_day_code period_type,
     'Cumulative' calculation_type,
     SUM(calculate_days(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     a.transaction_create_date,
     a.start_date),
     end_date,
     l_day_code,
     'Current')*(a.budget_approved/DECODE(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1)),
     0,
     1,
     DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1))))) cost_cur_period,
     0 cost_pre_period,
     0 leads_cur_period,
     0 leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     0 rev_cur_period,
     0 rev_pre_period,
     0 orders_cur_period,
     0 orders_pre_period,
     0 aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_camp_daily_facts a
   WHERE
     a.budget_approved > 0
   GROUP  BY a.campaign_id,
     a.transaction_create_date,
     a.start_date,
     a.end_date,
     a.budget_approved,
     a.campaign_region,
     a.campaign_country,
     a.business_unit_id,
     a.campaign_status
   UNION ALL
   SELECT
     a.campaign_id object_id,
     a.transaction_create_date,
     'CAMP' object_type,
     a.budget_approved budget_approved,
     a.campaign_region region,
     a.campaign_country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.campaign_status status,
     l_day_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     SUM(calculate_days(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     a.transaction_create_date,
     a.start_date),
     end_date,
     l_day_code,
     'Previous')*(a.budget_approved/DECODE(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1)),
     0,
     1,
     DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1))))) cost_cur_period,
     0 leads_cur_period,
     0 leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     0 rev_cur_period,
     0 rev_pre_period,
     0 orders_cur_period,
     0 orders_pre_period,
     0 aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_camp_daily_facts a
   WHERE
     a.budget_approved > 0
   GROUP  BY a.campaign_id,
     a.transaction_create_date,
     a.start_date,
     a.end_date,
     a.budget_approved,
     a.campaign_region,
     a.campaign_country,
     a.business_unit_id,
     a.campaign_status
   UNION ALL
   SELECT
     a.campaign_id object_id,
     sysdate transaction_create_date,
     'CAMP' object_type,
     0 budget_approved,
     a.campaign_region region,
     a.campaign_country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.campaign_status status,
     l_year_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     0 cost_pre_period,
     sum(leads_open + leads_closed) leads_cur_period,
     0 leads_pre_period,
     sum(positive_responses) resp_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     sum(orders_booked_amt) rev_cur_period,
     0 rev_pre_period,
     sum(orders_booked) orders_cur_period,
     0 orders_pre_period,
     sum(leads_hot) aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_camp_daily_facts a
   WHERE
     a.transaction_create_date between l_cur_year_start_date and l_cur_year_end_date
   GROUP  BY a.campaign_id,
     a.start_date,
     a.end_date,
     a.campaign_region,
     a.campaign_country,
     a.business_unit_id,
     a.campaign_status
   UNION ALL
   SELECT
     a.campaign_id object_id,
     sysdate transaction_create_date,
     'CAMP' object_type,
     0 budget_approved,
     a.campaign_region region,
     a.campaign_country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.campaign_status status,
     l_year_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     0 cost_pre_period,
     0 leads_cur_period,
     sum(leads_open + leads_closed ) leads_pre_period,
     0 res_cur_period,
     sum(positive_responses) resp_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     0 rev_cur_period,
     sum(orders_booked_amt)  rev_pre_period,
     0 orders_cur_period,
     sum(orders_booked) orders_pre_period,
     0 aleads_cur_period,
     sum(leads_hot) aleads_pre_period
   FROM
     bim_r_camp_daily_facts a
   WHERE
     a.transaction_create_date between l_pre_year_start_date and l_pre_year_end_date
   GROUP  BY a.campaign_id,
     a.start_date,
     a.end_date,
     a.campaign_region,
     a.campaign_country,
     a.business_unit_id,
     a.campaign_status
   UNION ALL
   SELECT
     a.campaign_id object_id,
     sysdate transaction_create_date,
     'CAMP' object_type,
     0 budget_approved,
     a.campaign_region region,
     a.campaign_country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.campaign_status status,
     l_quarter_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     0 cost_pre_period,
     sum(leads_open + leads_closed ) leads_cur_period,
     0 leads_pre_period,
     sum(positive_responses) resp_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     sum(orders_booked_amt) rev_cur_period,
     0 rev_pre_period,
     sum(orders_booked) orders_cur_period,
     0 orders_pre_period,
     sum(leads_hot) aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_camp_daily_facts a
   WHERE
     a.transaction_create_date between l_cur_qtr_start_date and l_cur_qtr_end_date
   GROUP  BY a.campaign_id,
     a.start_date,
     a.end_date,
     a.campaign_region,
     a.campaign_country,
     a.business_unit_id,
     a.campaign_status
   UNION ALL
   SELECT
     a.campaign_id object_id,
     sysdate transaction_create_date,
     'CAMP' object_type,
     0 budget_approved,
     a.campaign_region region,
     a.campaign_country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.campaign_status status,
     l_quarter_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     0 cost_pre_period,
     0 leads_cur_period,
     sum(leads_open + leads_closed ) leads_pre_period,
     0 res_cur_period,
     sum(positive_responses) resp_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     0 rev_cur_period,
     sum(orders_booked_amt)  rev_pre_period,
     0 orders_cur_period,
     sum(orders_booked) orders_pre_period,
     0 aleads_cur_period,
     sum(leads_hot) aleads_pre_period
   FROM
     bim_r_camp_daily_facts a
   WHERE
     a.transaction_create_date between l_pre_qtr_start_date and l_pre_qtr_end_date
   GROUP  BY a.campaign_id,
     a.start_date,
     a.end_date,
     a.campaign_region,
     a.campaign_country,
     a.business_unit_id,
     a.campaign_status
   UNION ALL
   SELECT
     a.campaign_id object_id,
     sysdate transaction_create_date,
     'CAMP' object_type,
     0 budget_approved,
     a.campaign_region region,
     a.campaign_country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.campaign_status status,
     l_month_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     0 cost_pre_period,
     sum(leads_open + leads_closed ) leads_cur_period,
     0 leads_pre_period,
     sum(positive_responses) resp_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     sum(orders_booked_amt) rev_cur_period,
     0 rev_pre_period,
     sum(orders_booked) orders_cur_period,
     0 orders_pre_period,
     sum(leads_hot) aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_camp_daily_facts a
   WHERE
     a.transaction_create_date between l_cur_month_start_date and l_cur_month_end_date
   GROUP  BY a.campaign_id,
     a.start_date,
     a.end_date,
     a.campaign_region,
     a.campaign_country,
     a.business_unit_id,
     a.campaign_status
   UNION ALL
   SELECT
     a.campaign_id object_id,
     sysdate transaction_create_date,
     'CAMP' object_type,
     0 budget_approved,
     a.campaign_region region,
     a.campaign_country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.campaign_status status,
     l_month_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     0 cost_pre_period,
     0 leads_cur_period,
     sum(leads_open + leads_closed ) leads_pre_period,
     0 res_cur_period,
     sum(positive_responses) resp_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     0 rev_cur_period,
     sum(orders_booked_amt)  rev_pre_period,
     0 orders_cur_period,
     sum(orders_booked) orders_pre_period,
     0 aleads_cur_period,
     sum(leads_hot) aleads_pre_period
   FROM
     bim_r_camp_daily_facts a
   WHERE
     a.transaction_create_date between l_pre_month_start_date and l_pre_month_end_date
   GROUP  BY a.campaign_id,
     a.start_date,
     a.end_date,
     a.campaign_region,
     a.campaign_country,
     a.business_unit_id,
     a.campaign_status
   UNION ALL
   SELECT
     a.campaign_id object_id,
     sysdate transaction_create_date,
     'CAMP' object_type,
     0 budget_approved,
     a.campaign_region region,
     a.campaign_country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.campaign_status status,
     l_week_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     0 cost_pre_period,
     sum(leads_open + leads_closed ) leads_cur_period,
     0 leads_pre_period,
     sum(positive_responses) resp_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     sum(orders_booked_amt) rev_cur_period,
     0 rev_pre_period,
     sum(orders_booked) orders_cur_period,
     0 orders_pre_period,
     sum(leads_hot) aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_camp_daily_facts a
   WHERE
     a.transaction_create_date between l_cur_week_start_date and l_cur_week_end_date
   GROUP  BY a.campaign_id,
     a.start_date,
     a.end_date,
     a.campaign_region,
     a.campaign_country,
     a.business_unit_id,
     a.campaign_status
   UNION ALL
   SELECT
     a.campaign_id object_id,
     sysdate transaction_create_date,
     'CAMP' object_type,
     0 budget_approved,
     a.campaign_region region,
     a.campaign_country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.campaign_status status,
     l_week_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     0 cost_pre_period,
     0 leads_cur_period,
     sum(leads_open + leads_closed) leads_pre_period,
     0 res_cur_period,
     sum(positive_responses) resp_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     0 rev_cur_period,
     sum(orders_booked_amt)  rev_pre_period,
     0 orders_cur_period,
     sum(orders_booked) orders_pre_period,
     0 aleads_cur_period,
     sum(leads_hot) aleads_pre_period
   FROM
     bim_r_camp_daily_facts a
   WHERE
     a.transaction_create_date between l_pre_week_start_date and l_pre_week_end_date
   GROUP  BY a.campaign_id,
     a.start_date,
     a.end_date,
     a.campaign_region,
     a.campaign_country,
     a.business_unit_id,
     a.campaign_status
   UNION ALL
   SELECT
     a.campaign_id object_id,
     sysdate transaction_create_date,
     'CAMP' object_type,
     0 budget_approved,
     a.campaign_region region,
     a.campaign_country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.campaign_status status,
     l_day_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     0 cost_pre_period,
     sum(leads_open + leads_closed) leads_cur_period,
     0 leads_pre_period,
     sum(positive_responses) resp_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     sum(orders_booked_amt) rev_cur_period,
     0 rev_pre_period,
     sum(orders_booked) orders_cur_period,
     0 orders_pre_period,
     sum(leads_hot) aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_camp_daily_facts a
   WHERE
     a.transaction_create_date = trunc(l_date)
   GROUP  BY a.campaign_id,
     a.start_date,
     a.end_date,
     a.campaign_region,
     a.campaign_country,
     a.business_unit_id,
     a.campaign_status
   UNION ALL
   SELECT
     a.campaign_id object_id,
     sysdate transaction_create_date,
     'CAMP' object_type,
     0 budget_approved,
     a.campaign_region region,
     a.campaign_country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.campaign_status status,
     l_day_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     0 cost_pre_period,
     0 leads_cur_period,
     sum(leads_open + leads_closed) leads_pre_period,
     0 res_cur_period,
     sum(positive_responses) resp_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     0 rev_cur_period,
     sum(orders_booked_amt)  rev_pre_period,
     0 orders_cur_period,
     sum(orders_booked) orders_pre_period,
     0 aleads_cur_period,
     sum(leads_hot) aleads_pre_period
   FROM
     bim_r_camp_daily_facts a
   WHERE
     a.transaction_create_date = trunc(l_date) - 1
   GROUP  BY a.campaign_id,
     a.start_date,
     a.end_date,
     a.campaign_region,
     a.campaign_country,
     a.business_unit_id,
     a.campaign_status
   UNION ALL
   SELECT
     decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id) object_id,
     a.transaction_create_date,
     decode(a.event_header_id,-999,'EONE','EVEH') object_type,
     a.budget_approved budget_approved,
     b.area2_code region,
     a.country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.status status,
     l_year_code period_type,
     'Cumulative' calculation_type,
     SUM(calculate_days(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     a.transaction_create_date,
     a.start_date),
     end_date,
     l_year_code,
     'Current')*(a.budget_approved/DECODE(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1)),
     0,
     1,
     DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1))))) cost_cur_period,
     0 cost_pre_period,
     0 leads_cur_period,
     0 leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     0 rev_cur_period,
     0 rev_pre_period,
     0 orders_cur_period,
     0 orders_pre_period,
     0 aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_even_daily_facts a
     ,jtf_loc_hierarchies_b b
   WHERE
     a.budget_approved > 0
   AND b.location_hierarchy_id = a.country
   GROUP  BY decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id),
   decode(a.event_header_id,-999,'EONE','EVEH'),
     a.transaction_create_date,
     a.start_date,
     a.end_date,
     a.budget_approved,
     b.area2_code,
     a.country,
     a.business_unit_id,
     a.status
   UNION ALL
   SELECT
     decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id) object_id,
     a.transaction_create_date,
     decode(a.event_header_id,-999,'EONE','EVEH') object_type,
     a.budget_approved budget_approved,
     b.area2_code region,
     a.country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.status status,
     l_year_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     SUM(calculate_days(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     a.transaction_create_date,
     a.start_date),
     end_date,
     l_year_code,
     'Previous')*(a.budget_approved/DECODE(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1)),
     0,
     1,
     DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1))))) cost_cur_period,
     0 leads_cur_period,
     0 leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     0 rev_cur_period,
     0 rev_pre_period,
     0 orders_cur_period,
     0 orders_pre_period,
     0 aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_even_daily_facts a
     ,jtf_loc_hierarchies_b b
   WHERE
     a.budget_approved > 0
   AND b.location_hierarchy_id = a.country
   GROUP  BY decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id),
     decode(a.event_header_id,-999,'EONE','EVEH'),
     a.transaction_create_date,
     a.start_date,
     a.end_date,
     a.budget_approved,
     b.area2_code,
     a.country,
     a.business_unit_id,
     a.status
   UNION ALL
   SELECT
     decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id) object_id,
     a.transaction_create_date,
     decode(a.event_header_id,-999,'EONE','EVEH') object_type,
     a.budget_approved budget_approved,
     b.area2_code region,
     a.country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.status status,
     l_quarter_code period_type,
     'Cumulative' calculation_type,
     SUM(calculate_days(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     a.transaction_create_date,
     a.start_date),
     end_date,
     l_quarter_code,
     'Current')*(a.budget_approved/DECODE(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1)),
     0,
     1,
     DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1))))) cost_cur_period,
     0 cost_pre_period,
     0 leads_cur_period,
     0 leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     0 rev_cur_period,
     0 rev_pre_period,
     0 orders_cur_period,
     0 orders_pre_period,
     0 aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_even_daily_facts a
     ,jtf_loc_hierarchies_b b
   WHERE
     a.budget_approved > 0
   AND b.location_hierarchy_id = a.country
   GROUP  BY decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id),
   decode(a.event_header_id,-999,'EONE','EVEH'),
     a.transaction_create_date,
     a.start_date,
     a.end_date,
     a.budget_approved,
     b.area2_code,
     a.country,
     a.business_unit_id,
     a.status
   UNION ALL
   SELECT
     decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id) object_id,
     a.transaction_create_date,
     decode(a.event_header_id,-999,'EONE','EVEH') object_type,
     a.budget_approved budget_approved,
     b.area2_code region,
     a.country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.status status,
     l_quarter_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     SUM(calculate_days(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     a.transaction_create_date,
     a.start_date),
     end_date,
     l_quarter_code,
     'Previous')*(a.budget_approved/DECODE(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1)),
     0,
     1,
     DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1))))) cost_cur_period,
     0 leads_cur_period,
     0 leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     0 rev_cur_period,
     0 rev_pre_period,
     0 orders_cur_period,
     0 orders_pre_period,
     0 aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_even_daily_facts a
     ,jtf_loc_hierarchies_b b
   WHERE
     a.budget_approved > 0
   AND b.location_hierarchy_id = a.country
   GROUP  BY decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id),
     decode(a.event_header_id,-999,'EONE','EVEH'),
     a.transaction_create_date,
     a.start_date,
     a.end_date,
     a.budget_approved,
     b.area2_code,
     a.country,
     a.business_unit_id,
     a.status
   UNION ALL
   SELECT
     decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id) object_id,
     a.transaction_create_date,
     decode(a.event_header_id,-999,'EONE','EVEH') object_type,
     a.budget_approved budget_approved,
     b.area2_code region,
     a.country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.status status,
     l_month_code period_type,
     'Cumulative' calculation_type,
     SUM(calculate_days(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     a.transaction_create_date,
     a.start_date),
     end_date,
     l_month_code,
     'Current')*(a.budget_approved/DECODE(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1)),
     0,
     1,
     DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1))))) cost_cur_period,
     0 cost_pre_period,
     0 leads_cur_period,
     0 leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     0 rev_cur_period,
     0 rev_pre_period,
     0 orders_cur_period,
     0 orders_pre_period,
     0 aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_even_daily_facts a
     ,jtf_loc_hierarchies_b b
   WHERE
     a.budget_approved > 0
   AND b.location_hierarchy_id = a.country
   GROUP  BY decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id),
decode(a.event_header_id,-999,'EONE','EVEH'),
     a.transaction_create_date,
     a.start_date,
     a.end_date,
     a.budget_approved,
     b.area2_code,
     a.country,
     a.business_unit_id,
     a.status
   UNION ALL
   SELECT
     decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id) object_id,
     a.transaction_create_date,
     decode(a.event_header_id,-999,'EONE','EVEH') object_type,
     a.budget_approved budget_approved,
     b.area2_code region,
     a.country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.status status,
     l_month_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     SUM(calculate_days(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     a.transaction_create_date,
     a.start_date),
     end_date,
     l_month_code,
     'Previous')*(a.budget_approved/DECODE(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1)),
     0,
     1,
     DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1))))) cost_cur_period,
     0 leads_cur_period,
     0 leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     0 rev_cur_period,
     0 rev_pre_period,
     0 orders_cur_period,
     0 orders_pre_period,
     0 aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_even_daily_facts a
     ,jtf_loc_hierarchies_b b
   WHERE
     a.budget_approved > 0
   AND b.location_hierarchy_id = a.country
   GROUP  BY decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id),
decode(a.event_header_id,-999,'EONE','EVEH'),
     a.transaction_create_date,
     a.start_date,
     a.end_date,
     a.budget_approved,
     b.area2_code,
     a.country,
     a.business_unit_id,
     a.status
   UNION ALL
   SELECT
     decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id) object_id,
     a.transaction_create_date,
     decode(a.event_header_id,-999,'EONE','EVEH') object_type,
     a.budget_approved budget_approved,
     b.area2_code region,
     a.country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.status status,
     l_week_code period_type,
     'Cumulative' calculation_type,
     SUM(calculate_days(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     a.transaction_create_date,
     a.start_date),
     end_date,
     l_week_code,
     'Current')*(a.budget_approved/DECODE(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1)),
     0,
     1,
     DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1))))) cost_cur_period,
     0 cost_pre_period,
     0 leads_cur_period,
     0 leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     0 rev_cur_period,
     0 rev_pre_period,
     0 orders_cur_period,
     0 orders_pre_period,
     0 aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_even_daily_facts a
     ,jtf_loc_hierarchies_b b
   WHERE
     a.budget_approved > 0
   AND b.location_hierarchy_id = a.country
   GROUP  BY decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id),
decode(a.event_header_id,-999,'EONE','EVEH'),
     a.transaction_create_date,
     a.start_date,
     a.end_date,
     a.budget_approved,
     b.area2_code,
     a.country,
     a.business_unit_id,
     a.status
   UNION ALL
   SELECT
     decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id) object_id,
     a.transaction_create_date,
     decode(a.event_header_id,-999,'EONE','EVEH') object_type,
     a.budget_approved budget_approved,
     b.area2_code region,
     a.country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.status status,
     l_week_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     SUM(calculate_days(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     a.transaction_create_date,
     a.start_date),
     end_date,
     l_week_code,
     'Previous')*(a.budget_approved/DECODE(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1)),
     0,
     1,
     DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1))))) cost_cur_period,
     0 leads_cur_period,
     0 leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     0 rev_cur_period,
     0 rev_pre_period,
     0 orders_cur_period,
     0 orders_pre_period,
     0 aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_even_daily_facts a
     ,jtf_loc_hierarchies_b b
   WHERE
     a.budget_approved > 0
   AND b.location_hierarchy_id = a.country
   GROUP  BY decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id),
decode(a.event_header_id,-999,'EONE','EVEH'),
     a.transaction_create_date,
     a.start_date,
     a.end_date,
     a.budget_approved,
     b.area2_code,
     a.country,
     a.business_unit_id,
     a.status
   UNION ALL
   SELECT
     decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id) object_id,
     a.transaction_create_date,
     decode(a.event_header_id,-999,'EONE','EVEH') object_type,
     a.budget_approved budget_approved,
     b.area2_code region,
     a.country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.status status,
     l_day_code period_type,
     'Cumulative' calculation_type,
     SUM(calculate_days(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     a.transaction_create_date,
     a.start_date),
     end_date,
     l_day_code,
     'Current')*(a.budget_approved/DECODE(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1)),
     0,
     1,
     DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1))))) cost_cur_period,
     0 cost_pre_period,
     0 leads_cur_period,
     0 leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     0 rev_cur_period,
     0 rev_pre_period,
     0 orders_cur_period,
     0 orders_pre_period,
     0 aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_even_daily_facts a
     ,jtf_loc_hierarchies_b b
   WHERE
     a.budget_approved > 0
   AND b.location_hierarchy_id = a.country
   GROUP  BY decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id),
decode(a.event_header_id,-999,'EONE','EVEH'),
     a.transaction_create_date,
     a.start_date,
     a.end_date,
     a.budget_approved,
     b.area2_code,
     a.country,
     a.business_unit_id,
     a.status
   UNION ALL
   SELECT
     decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id) object_id,
     a.transaction_create_date,
     decode(a.event_header_id,-999,'EONE','EVEH') object_type,
     a.budget_approved budget_approved,
     b.area2_code region,
     a.country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.status status,
     l_day_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     SUM(calculate_days(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     a.transaction_create_date,
     a.start_date),
     end_date,
     l_day_code,
     'Previous')*(a.budget_approved/DECODE(DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1)),
     0,
     1,
     DECODE(GREATEST(a.start_date - a.transaction_create_date,
     0),
     0,
     ((nvl(a.end_date,
     sysdate) - a.transaction_create_date)+1),
     ((nvl(a.end_date,
     sysdate) - a.start_date)+1))))) cost_cur_period,
     0 leads_cur_period,
     0 leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     0 reg_pre_period,
     0 rev_cur_period,
     0 rev_pre_period,
     0 orders_cur_period,
     0 orders_pre_period,
     0 aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_even_daily_facts a
     ,jtf_loc_hierarchies_b b
   WHERE
     a.budget_approved > 0
   AND b.location_hierarchy_id = a.country
   GROUP  BY decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id),
decode(a.event_header_id,-999,'EONE','EVEH'),
     a.transaction_create_date,
     a.start_date,
     a.end_date,
     a.budget_approved,
     b.area2_code,
     a.country,
     a.business_unit_id,
     a.status
   UNION ALL
   SELECT
     decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id) object_id,
     sysdate transaction_create_date,
     decode(a.event_header_id,-999,'EONE','EVEH') object_type,
     0 budget_approved,
     b.area2_code region,
     a.country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.status status,
     l_year_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     0 cost_pre_period,
     sum(leads_open + leads_closed) leads_cur_period,
     0 leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     sum(registrations) reg_cur_period,
     0 reg_pre_period,
     sum(booked_orders_amt) rev_cur_period,
     0 rev_pre_period,
     sum(booked_orders) orders_cur_period,
     0 orders_pre_period,
     sum(leads_hot) aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_even_daily_facts a
     ,jtf_loc_hierarchies_b b
   WHERE
     a.transaction_create_date between l_cur_year_start_date and l_cur_year_end_date
   AND b.location_hierarchy_id = a.country
   GROUP  BY decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id),
decode(a.event_header_id,-999,'EONE','EVEH'),
     a.start_date,
     a.end_date,
     b.area2_code,
     a.country,
     a.business_unit_id,
     a.status
   UNION ALL
   SELECT
     decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id) object_id,
     sysdate transaction_create_date,
     decode(a.event_header_id,-999,'EONE','EVEH') object_type,
     0 budget_approved,
     b.area2_code region,
     a.country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.status status,
     l_year_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     0 cost_pre_period,
     0 leads_cur_period,
     sum(leads_open + leads_closed) leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     sum(registrations) reg_pre_period,
     0 rev_cur_period,
     sum(booked_orders_amt)  rev_pre_period,
     0 orders_cur_period,
     sum(booked_orders) orders_pre_period,
     0 aleads_cur_period,
     sum(leads_hot) aleads_pre_period
   FROM
     bim_r_even_daily_facts a
     ,jtf_loc_hierarchies_b b
   WHERE
     a.transaction_create_date between l_pre_year_start_date and l_pre_year_end_date
   AND b.location_hierarchy_id = a.country
   GROUP  BY decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id),
decode(a.event_header_id,-999,'EONE','EVEH'),
     a.start_date,
     a.end_date,
     b.area2_code,
     a.country,
     a.business_unit_id,
     a.status
   UNION ALL
   SELECT
     decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id) object_id,
     sysdate transaction_create_date,
     decode(a.event_header_id,-999,'EONE','EVEH') object_type,
     0 budget_approved,
     b.area2_code region,
     a.country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.status status,
     l_quarter_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     0 cost_pre_period,
     sum(leads_open + leads_closed) leads_cur_period,
     0 leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     sum(registrations) reg_cur_period,
     0 reg_pre_period,
     sum(booked_orders_amt) rev_cur_period,
     0 rev_pre_period,
     sum(booked_orders) orders_cur_period,
     0 orders_pre_period,
     sum(leads_hot) aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_even_daily_facts a
     ,jtf_loc_hierarchies_b b
   WHERE
     a.transaction_create_date between l_cur_qtr_start_date and l_cur_qtr_end_date
   AND b.location_hierarchy_id = a.country
   GROUP  BY decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id),
decode(a.event_header_id,-999,'EONE','EVEH'),
     a.start_date,
     a.end_date,
     b.area2_code,
     a.country,
     a.business_unit_id,
     a.status
   UNION ALL
   SELECT
     decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id) object_id,
     sysdate transaction_create_date,
     decode(a.event_header_id,-999,'EONE','EVEH') object_type,
     0 budget_approved,
     b.area2_code region,
     a.country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.status status,
     l_quarter_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     0 cost_pre_period,
     0 leads_cur_period,
     sum(leads_open + leads_closed) leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     sum(registrations) reg_pre_period,
     0 rev_cur_period,
     sum(booked_orders_amt)  rev_pre_period,
     0 orders_cur_period,
     sum(booked_orders) orders_pre_period,
     0 aleads_cur_period,
     sum(leads_hot) aleads_pre_period
   FROM
     bim_r_even_daily_facts a
     ,jtf_loc_hierarchies_b b
   WHERE
     a.transaction_create_date between l_pre_qtr_start_date and l_pre_qtr_end_date
   AND b.location_hierarchy_id = a.country
   GROUP  BY decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id),
decode(a.event_header_id,-999,'EONE','EVEH'),
     a.start_date,
     a.end_date,
     b.area2_code,
     a.country,
     a.business_unit_id,
     a.status
   UNION ALL
   SELECT
     decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id) object_id,
     sysdate transaction_create_date,
     decode(a.event_header_id,-999,'EONE','EVEH') object_type,
     0 budget_approved,
     b.area2_code region,
     a.country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.status status,
     l_month_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     0 cost_pre_period,
     sum(leads_open + leads_closed) leads_cur_period,
     0 leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     sum(registrations) reg_cur_period,
     0 reg_pre_period,
     sum(booked_orders_amt) rev_cur_period,
     0 rev_pre_period,
     sum(booked_orders) orders_cur_period,
     0 orders_pre_period,
     sum(leads_hot) aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_even_daily_facts a
     ,jtf_loc_hierarchies_b b
   WHERE
     a.transaction_create_date between l_cur_month_start_date and l_cur_month_end_date
   AND b.location_hierarchy_id = a.country
   GROUP  BY decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id),
decode(a.event_header_id,-999,'EONE','EVEH'),
     a.start_date,
     a.end_date,
     b.area2_code,
     a.country,
     a.business_unit_id,
     a.status
   UNION ALL
   SELECT
     decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id) object_id,
     sysdate transaction_create_date,
     decode(a.event_header_id,-999,'EONE','EVEH') object_type,
     0 budget_approved,
     b.area2_code region,
     a.country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.status status,
     l_month_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     0 cost_pre_period,
     0 leads_cur_period,
     sum(leads_open + leads_closed) leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     sum(registrations) reg_pre_period,
     0 rev_cur_period,
     sum(booked_orders_amt)  rev_pre_period,
     0 orders_cur_period,
     sum(booked_orders) orders_pre_period,
     0 aleads_cur_period,
     sum(leads_hot) aleads_pre_period
   FROM
     bim_r_even_daily_facts a
     ,jtf_loc_hierarchies_b b
   WHERE
     a.transaction_create_date between l_pre_month_start_date and l_pre_month_end_date
   AND b.location_hierarchy_id = a.country
   GROUP  BY decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id),
decode(a.event_header_id,-999,'EONE','EVEH'),
     a.start_date,
     a.end_date,
     b.area2_code,
     a.country,
     a.business_unit_id,
     a.status
   UNION ALL
   SELECT
     decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id) object_id,
     sysdate transaction_create_date,
     decode(a.event_header_id,-999,'EONE','EVEH') object_type,
     0 budget_approved,
     b.area2_code region,
     a.country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.status status,
     l_week_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     0 cost_pre_period,
     sum(leads_open + leads_closed) leads_cur_period,
     0 leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     sum(registrations) reg_cur_period,
     0 reg_pre_period,
     sum(booked_orders_amt) rev_cur_period,
     0 rev_pre_period,
     sum(booked_orders) orders_cur_period,
     0 orders_pre_period,
     sum(leads_hot) aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_even_daily_facts a
     ,jtf_loc_hierarchies_b b
   WHERE
     a.transaction_create_date between l_cur_week_start_date and l_cur_week_end_date
   AND b.location_hierarchy_id = a.country
   GROUP  BY decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id),
decode(a.event_header_id,-999,'EONE','EVEH'),
     a.start_date,
     a.end_date,
     b.area2_code,
     a.country,
     a.business_unit_id,
     a.status
   UNION ALL
   SELECT
     decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id) object_id,
     sysdate transaction_create_date,
     decode(a.event_header_id,-999,'EONE','EVEH') object_type,
     0 budget_approved,
     b.area2_code region,
     a.country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.status status,
     l_week_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     0 cost_pre_period,
     0 leads_cur_period,
     sum(leads_open + leads_closed) leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     sum(registrations) reg_pre_period,
     0 rev_cur_period,
     sum(booked_orders_amt)  rev_pre_period,
     0 orders_cur_period,
     sum(booked_orders) orders_pre_period,
     0 aleads_cur_period,
     sum(leads_hot) aleads_pre_period
   FROM
     bim_r_even_daily_facts a
     ,jtf_loc_hierarchies_b b
   WHERE
     a.transaction_create_date between l_pre_week_start_date and l_pre_week_end_date
   AND b.location_hierarchy_id = a.country
   GROUP  BY decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id),
decode(a.event_header_id,-999,'EONE','EVEH'),
     a.start_date,
     a.end_date,
     b.area2_code,
     a.country,
     a.business_unit_id,
     a.status
   UNION ALL
   SELECT
     decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id) object_id,
     sysdate transaction_create_date,
     decode(a.event_header_id,-999,'EONE','EVEH') object_type,
     0 budget_approved,
     b.area2_code region,
     a.country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.status status,
     l_day_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     0 cost_pre_period,
     sum(leads_open + leads_closed) leads_cur_period,
     0 leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     sum(registrations) reg_cur_period,
     0 reg_pre_period,
     sum(booked_orders_amt) rev_cur_period,
     0 rev_pre_period,
     sum(booked_orders) orders_cur_period,
     0 orders_pre_period,
     sum(leads_hot) aleads_cur_period,
     0 aleads_pre_period
   FROM
     bim_r_even_daily_facts a
     ,jtf_loc_hierarchies_b b
   WHERE
     trunc(a.transaction_create_date) = trunc(l_date)
   AND b.location_hierarchy_id = a.country
   GROUP  BY decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id),
decode(a.event_header_id,-999,'EONE','EVEH'),
     a.start_date,
     a.end_date,
     b.area2_code,
     a.country,
     a.business_unit_id,
     a.status
   UNION ALL
   SELECT
     decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id) object_id,
     sysdate transaction_create_date,
     decode(a.event_header_id,-999,'EONE','EVEH') object_type,
     0 budget_approved,
     b.area2_code region,
     a.country country,
     a.business_unit_id business_unit,
     a.start_date start_date,
     a.end_date end_date,
     a.status status,
     l_day_code period_type,
     'Cumulative' calculation_type,
     0 cost_cur_period,
     0 cost_pre_period,
     0 leads_cur_period,
     sum(leads_open + leads_closed) leads_pre_period,
     0 res_cur_period,
     0 res_pre_period,
     0 reg_cur_period,
     sum(registrations) reg_pre_period,
     0 rev_cur_period,
     sum(booked_orders_amt)  rev_pre_period,
     0 orders_cur_period,
     sum(booked_orders) orders_pre_period,
     0 aleads_cur_period,
     sum(leads_hot) aleads_pre_period
   FROM
     bim_r_even_daily_facts a
     ,jtf_loc_hierarchies_b b
   WHERE
     trunc(a.transaction_create_date) = trunc(l_date - 1)
   AND b.location_hierarchy_id = a.country
   GROUP  BY decode(a.event_header_id,-999,a.event_offer_id, a.event_header_id),
decode(a.event_header_id,-999,'EONE','EVEH'),
     a.start_date,
     a.end_date,
     b.area2_code,
     a.country,
     a.business_unit_id,
     a.status
   ) inner;
COMMIT;

  ams_utility_pvt.write_conc_log('BIM_R_KPI_FACT: INSERT END');

   UPDATE bim_r_kpi_facts
   SET cost_cur_period=0
       ,cost_pre_period=0
   WHERE status = 'CANCELLED';
COMMIT;

   ams_utility_pvt.debug_message('POPULATE BIM_R_KPI_FACT END');

   DELETE FROM bim_rep_history
   WHERE object='KPILD';
   INSERT INTO
   bim_rep_history
       (creation_date,
        last_update_date,
        created_by,
        last_updated_by,
        object,
        object_last_updated_date)
   VALUES
       (sysdate,
        sysdate,
        FND_GLOBAL.USER_ID(),
        FND_GLOBAL.USER_ID(),
        'KPILD',
        sysdate);
COMMIT;

  ams_utility_pvt.write_conc_log('BIM_R_KPI_FACT: POPULATE END');

  ams_utility_pvt.write_conc_log('End of KPI Facts Program');

 EXCEPTION

   WHEN OTHERS THEN
     ams_utility_pvt.write_conc_log('BIM_R_KPI_FACT--POPULATE: Error occured '||sqlerrm(sqlcode));
     ERRBUF  := sqlerrm(sqlcode);
     RETCODE := sqlcode;

--   dbms_output.put_line('END OF POPULATING BIM_R_KPI_FACT');
--  dbms_output.put_line('END OF POPULATE');

END POPULATE;

END BIM_KPI_FACT;

/
