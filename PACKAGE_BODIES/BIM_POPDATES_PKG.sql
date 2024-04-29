--------------------------------------------------------
--  DDL for Package Body BIM_POPDATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIM_POPDATES_PKG" AS
/*$Header: bimdateb.pls 120.2 2005/11/09 01:59:23 arvikuma noship $*/

g_pkg_name  CONSTANT  VARCHAR2(20) := 'BIM_POPDATES_PKG';
g_file_name CONSTANT  VARCHAR2(20) := 'bimdateb.pls';

PROCEDURE POP_INTL_DATES(p_input_date DATE) IS
CURSOR min_gl_date IS
SELECT TRUNC(min(start_date))
FROM gl_periods
WHERE  period_set_name = fnd_profile.value('AMS_CAMPAIGN_DEFAULT_CALENDER');

CURSOR max_gl_date IS
SELECT TRUNC(max(end_date))
FROM   gl_periods
WHERE  period_set_name = fnd_profile.value('AMS_CAMPAIGN_DEFAULT_CALENDER');

cursor min_object_date (p_date DATE) is
select trunc(min(de)) from (
select min(bu1.approval_date) de
FROM      ozf_funds_all_b o,
          ozf_act_budgets BU1
WHERE  o.start_date_active > p_date
and o.status_code in ('ACTIVE','CANCELLED', 'CLOSED')
AND    bu1.transfer_type in ('TRANSFER', 'REQUEST')
AND    bu1.approval_date <=trunc(o.start_date_active)
AND    bu1.status_code = 'APPROVED'
AND    bu1.arc_act_budget_used_by = 'FUND'
AND    bu1.act_budget_used_by_id = o.fund_id
AND    bu1.budget_source_type ='FUND'
union all
select min(bu2.approval_date) de
FROM      ozf_funds_all_b o,
          ozf_act_budgets BU2
WHERE  o.start_date_active > p_date --between p_start_datel and p_end_datel
AND    o.status_code in ('ACTIVE','CANCEL', 'CLOSED')
AND    bu2.approval_date <=trunc(o.start_date_active)
AND    bu2.status_code= 'APPROVED'
AND    bu2.arc_act_budget_used_by = 'FUND'
AND    bu2.budget_source_type ='FUND'
AND    bu2.budget_source_id = o.fund_id
union all
SELECT min(a.approval_date) de
FROM ozf_act_budgets a,
     ams_campaigns_all_b b
WHERE a.budget_source_type ='FUND'
AND   a.ARC_ACT_BUDGET_USED_BY = 'CAMP'
AND   a.status_code ='APPROVED'
and  a.act_budget_used_by_id=b.campaign_id
and  b.actual_exec_start_date>p_date
and  b.status_code in ('ACTIVE', 'CANCELLED', 'COMPLETED','CLOSED')
union all
SELECT min(a.approval_date)
FROM ozf_act_budgets a,
     ams_event_headers_all_b b
WHERE a.budget_source_type ='FUND'
AND   a.ARC_ACT_BUDGET_USED_BY = 'EVEH'
AND   a.status_code ='APPROVED'
and  a.act_budget_used_by_id=b.event_header_id
and  b.active_from_date>p_date
and  b.system_status_code in ('ACTIVE', 'CANCELLED', 'COMPLETED','CLOSED')
union all
SELECT   min(a.last_reg_status_date) de
FROM     ams_event_registrations A,
         ams_event_headers_all_b b,
		 ams_event_offers_all_b c
where 	 b.active_from_date>p_date
and      b.system_status_code in ('ACTIVE', 'CANCELLED', 'COMPLETED')
and	     a.event_offer_id = c.event_offer_id
and      c.event_header_id = b.event_header_id );

l_min_date DATE;
l_end_date DATE := sysdate-1;
l_date DATE;
l_status                      VARCHAR2(5);
l_industry                    VARCHAR2(5);
l_schema                      VARCHAR2(30);
l_return                       BOOLEAN;

BEGIN
  l_return  := fnd_installation.get_app_info('BIM', l_status, l_industry, l_schema);

   EXECUTE IMMEDIATE 'TRUNCATE TABLE '||l_schema||'.bim_intl_dates';

   OPEN max_gl_date;
   FETCH max_gl_date into l_date;
   CLOSE max_gl_date;

   IF l_date> l_end_date THEN
   l_end_date :=l_date;
   END IF;

   OPEN min_object_date(p_input_date) ;
   FETCH min_object_date into l_min_date;
   --ams_utility_pvt.write_conc_log('Inside pop dates: starting from '||l_min_date);

   IF l_min_date is null then
   l_min_date :=p_input_date;
   END IF;
--   IF p_input_date <l_min_date then
--   l_min_date :=p_input_date;
--   END IF;
   --ams_utility_pvt.write_conc_log('Before the loop');
   WHILE l_min_date < l_end_date+1 LOOP
     BEGIN
     INSERT
     INTO BIM_INTL_DATES fdf (
     TRDATE
    ,FISCAL_MONTH
    ,MONTH_FLAG
    ,FISCAL_QTR
    ,QTR_FLAG
    ,FISCAL_YEAR
    ,FISCAL_MONTH_START
    ,FISCAL_MONTH_END
    ,MONTH_NUM
    ,FISCAL_QTR_START
    ,FISCAL_QTR_END
    ,QTR_NUM
    ,FISCAL_YEAR_START
    ,FISCAL_YEAR_END
    ,FISCAL_ROLL_YEAR_START
    ,PRE_FISCAL_MONTH_START
    ,PRE_FISCAL_MONTH_END
    ,PRE_FISCAL_QTR_START
    ,PRE_FISCAL_QTR_END
    ,PRE_FISCAL_YEAR_START
    ,PRE_FISCAL_YEAR_END
    ,PRE_FISCAL_ROLL_YEAR_START
    ,PRE_FISCAL_ROLL_YEAR_END
    ,YEAR_FLAG
    )
    SELECT
     l_min_date
    ,BIM_SET_OF_BOOKS.GET_FISCAL_MONTH(l_min_date,204)
    ,'N'
    ,BIM_SET_OF_BOOKS.GET_FISCAL_QTR(l_min_date,204)
     ,'N'
    ,BIM_SET_OF_BOOKS.GET_FISCAL_YEAR(l_min_date,204)
    ,BIM_SET_OF_BOOKS.GET_FISCAL_MONTH_START(l_min_date,204)
    ,BIM_SET_OF_BOOKS.GET_FISCAL_MONTH_END(l_min_date,204)
    ,BIM_SET_OF_BOOKS.GET_FISCAL_MONTH_NUM(l_min_date,204)
    ,BIM_SET_OF_BOOKS.GET_FISCAL_QTR_START(l_min_date,204)
    ,BIM_SET_OF_BOOKS.GET_FISCAL_QTR_END(l_min_date,204)
    ,BIM_SET_OF_BOOKS.GET_FISCAL_QTR_NUM(l_min_date,204)
    ,BIM_SET_OF_BOOKS.GET_FISCAL_YEAR_START(l_min_date,204)
    ,BIM_SET_OF_BOOKS.GET_FISCAL_YEAR_END(l_min_date,204)
    ,BIM_SET_OF_BOOKS.GET_FISCAL_ROLL_YEAR_START(l_min_date,204)
    ,BIM_SET_OF_BOOKS.GET_PRE_FISCAL_MONTH_START(l_min_date,204)
    ,BIM_SET_OF_BOOKS.GET_PRE_FISCAL_MONTH_END(l_min_date,204)
    ,BIM_SET_OF_BOOKS.GET_PRE_FISCAL_QTR_START(l_min_date,204)
    ,BIM_SET_OF_BOOKS.GET_PRE_FISCAL_QTR_END(l_min_date,204)
    ,BIM_SET_OF_BOOKS.GET_PRE_FISCAL_YEAR_START(l_min_date,204)
    ,BIM_SET_OF_BOOKS.GET_PRE_FISCAL_YEAR_END(l_min_date,204)
    ,BIM_SET_OF_BOOKS.GET_PRE_FISCAL_ROLL_YEAR_START(l_min_date,204)
    ,BIM_SET_OF_BOOKS.GET_PRE_FISCAL_ROLL_YEAR_END(l_min_date,204)
    ,'N'
     FROM DUAL;
     l_min_date := l_min_date +1;
     EXCEPTION
     WHEN OTHERS THEN
     ams_utility_pvt.write_conc_log('Error inserting bim_intl_dates ' || sqlerrm(sqlcode));
     RAISE FND_API.g_exc_error;
     END;
 END LOOP;
  --ams_utility_pvt.write_conc_log('After the loop');
  --ams_utility_pvt.write_conc_log('Update the month flag');
BEGIN
 update bim_intl_dates p set month_flag = 'Y'
 where p.trdate in (SELECT min(trdate)
 FROM bim_intl_dates
 GROUP BY fiscal_month);
EXCEPTION
     WHEN OTHERS THEN
     ams_utility_pvt.write_conc_log('Error updating bim_intl_dates ' || sqlerrm(sqlcode));
     RAISE FND_API.g_exc_error;
     END;

 --ams_utility_pvt.write_conc_log('Update the quarter flag');
BEGIN
update bim_intl_dates p set qtr_flag = 'Y'
where p.trdate in (SELECT min(trdate)
FROM bim_intl_dates
GROUP BY fiscal_qtr);
EXCEPTION
     WHEN OTHERS THEN
     ams_utility_pvt.write_conc_log('Error updating bim_intl_dates ' || sqlerrm(sqlcode));
     RAISE FND_API.g_exc_error;
     END;
 --ams_utility_pvt.write_conc_log('Update the year flag');
BEGIN
update bim_intl_dates p set year_flag = 'Y'
where p.trdate in (SELECT min(trdate)
FROM bim_intl_dates
GROUP BY fiscal_year);
EXCEPTION
     WHEN OTHERS THEN
     ams_utility_pvt.write_conc_log('Error updating bim_intl_dates ' || sqlerrm(sqlcode));
     RAISE FND_API.g_exc_error;
     END;

DELETE FROM bim_rep_history
WHERE object='DATES';
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
        -1,
        -1,
        'DATES',
        sysdate);

commit;
  --ams_utility_pvt.write_conc_log('Successfully finished pop date');
 EXCEPTION
 WHEN OTHERS THEN
      ams_utility_pvt.write_conc_log('Error in procedure' || sqlerrm(sqlcode));
      RAISE FND_API.g_exc_unexpected_error;
END POP_INTL_DATES;
END BIM_POPDATES_PKG;

/
