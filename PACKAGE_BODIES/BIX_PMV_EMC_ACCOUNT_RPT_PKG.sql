--------------------------------------------------------
--  DDL for Package Body BIX_PMV_EMC_ACCOUNT_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_EMC_ACCOUNT_RPT_PKG" AS
/*$Header: bixeactr.plb 120.0 2005/05/25 17:28:49 appldev noship $ */

PROCEDURE GET_SQL(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                  p_sql_text           OUT NOCOPY VARCHAR2,
                  p_custom_output      OUT NOCOPY bis_query_attributes_TBL
                  )
AS
l_sqltext	      VARCHAR2(32000) ;
l_where_clause        VARCHAR2(1000) ;
l_as_of_date   DATE;
l_period_type	varchar2(2000);
l_comp_type    varchar2(2000);
l_sql_errm      varchar2(32000);
l_agent_cost      NUMBER := 0;
l_cust_resp_time_goal NUMBER;
l_service_level_goal  NUMBER;
l_custom_rec       BIS_QUERY_ATTRIBUTES;
l_period_type_id   NUMBER := 1;
l_record_type_id   NUMBER;
l_account      VARCHAR2(32000);
l_start_date   DATE;
l_end_date     DATE;
l_period_from  DATE;
l_period_to    DATE;
l_max_collect_date   VARCHAR2(100);
l_period_start_Date  DATE;
l_classification VARCHAR2(32000);
l_view_by     varchar2(1000);
l_row_type varchar2(10) := 'AC';

BEGIN

--
--Initialize p_custom_output
--

 p_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
 l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;

-- Get the parameters

BIX_PMV_DBI_UTL_PKG.get_emc_page_params( p_page_parameter_tbl,
                                         l_as_of_date,
                                         l_period_type,
                                         l_record_type_id,
                                         l_comp_type,
                                         l_account,
                					 l_classification,
			               		 l_view_by
                                       );



-- If the account is not 'All'

 IF l_account IS NOT NULL THEN
 l_where_clause := 'AND email_account_id IN (:l_account) ';
 END IF;


 IF l_classification IS NOT NULL THEN
 l_where_clause := l_where_clause || ' AND email_classification_id IN (:l_classification) ';
 END IF;

l_period_start_Date := BIX_PMV_DBI_UTL_PKG.period_start_date(l_as_of_date,l_period_type);

 /* Get the MAX date for which data is collected in Email Summary table */

    BIS_COLLECTION_UTILITIES.get_last_refresh_dates('BIX_EMAIL_DETAILS_F',
                                                     l_start_date,
                                                     l_end_date,
                                                     l_period_from,
                                                     l_period_to
                                                   );


 /* if the data is not collected till AS OF DATE
    then get the accumulated measures from the MAX collected DATE time bucket
    if the max collect date falls between current period */

  IF (NVL(l_period_to,l_as_of_date) >= l_as_of_date ) THEN
   l_max_collect_date := TO_CHAR(l_as_of_date,'DD/MM/YYYY');
  ELSIF ( l_period_to < l_period_start_date ) THEN
    l_max_collect_date := TO_CHAR(l_as_of_date,'DD/MM/YYYY');
  ELSE
    l_max_collect_date := TO_CHAR(l_period_to,'DD/MM/YYYY');
  END IF;

/*
 l_sqltext :=  '
SELECT
''Support@oracle.com'' BIX_EMC_ACCOUNT,
1000000000 BIX_EMC_RCVD,
20 BIX_EMC_RCVDCHANGE,
30 BIX_EMC_COMPLETED,
40 BIX_EMC_COMPCHANGE,
50 BIX_EMC_REPLD,
60 BIX_EMC_REPCHANGE,
70 BIX_EMC_DELETED,
80 BIX_EMC_DELCHANGE,
90 BIX_EMC_BACKLOG,
100 BIX_EMC_BACKCHANGE,
110 BIX_EMC_TRANRATIO,
120 BIX_EMC_TRATIOCHANGE,
130 BIX_EMC_DELRATIO,
140 BIX_EMC_DRATIOCHANGE,
150 BIX_EMC_SR,
160 BIX_EMC_SRCHANGE,
10 BIX_PMV_TOTAL1,
20 BIX_PMV_TOTAL2,
30 BIX_PMV_TOTAL3,
40 BIX_PMV_TOTAL4,
50 BIX_PMV_TOTAL5,
60 BIX_PMV_TOTAL6,
70 BIX_PMV_TOTAL7,
80 BIX_PMV_TOTAL8,
90 BIX_PMV_TOTAL9,
100 BIX_PMV_TOTAL10,
110 BIX_PMV_TOTAL11,
120 BIX_PMV_TOTAL12,
130 BIX_PMV_TOTAL13,
140 BIX_PMV_TOTAL14,
150 BIX_PMV_TOTAL15,
160 BIX_PMV_TOTAL16,
170 BIX_PMV_TOTAL17,
180 BIX_PMV_TOTAL18
FROM DUAL';

*/

   l_sqltext :=
 'SELECT lookup_table.value VIEWBY,
 NVL(SUM(curr_received),0) BIX_EMC_RCVD_CP,
 ((NVL(SUM(curr_received),0) - SUM(prev_received)) / SUM(prev_received) * 100) BIX_EMC_RCVDCHANGE,
 NVL(SUM(prev_received),0) BIX_EMC_PRRCVD,
 NVL(SUM(curr_composed),0) BIX_EMC_COMPOSED_CP,
 ((NVL(SUM(curr_composed),0) - DECODE(SUM(prev_composed),0,NULL,SUM(prev_composed)))
    /DECODE(SUM(prev_composed),0,NULL,SUM(prev_composed)) * 100) BIX_EMC_COMPOSE_CHANGE,
 NVL(SUM(curr_replied),0) + NVL(SUM(curr_auto_replied),0) BIX_EMC_REPLD_CP,
 (((NVL(SUM(curr_replied),0) + NVL(SUM(curr_auto_replied),0))  - (NVL(SUM(prev_replied),0) + NVL(sum(prev_auto_replied),0)) )
 /DECODE(NVL(SUM(prev_replied),0) + NVL(SUM(prev_auto_replied),0),0,NULL,NVL(SUM(prev_replied),0) + NVL(SUM(prev_auto_replied),0))  * 100) BIX_EMC_REPCHANGE,
 NVL(SUM(prev_replied),0) + NVL(SUM(prev_auto_replied),0) BIX_EMC_PRREPLD,
 NVL(SUM(curr_deleted),0) + NVL(SUM(curr_auto_deleted),0) BIX_EMC_DELETED_CP,
 (((NVL(SUM(curr_deleted),0) + NVL(SUM(curr_auto_deleted),0))  - (NVL(SUM(prev_deleted),0) + NVL(sum(prev_auto_deleted),0)) )
 / DECODE(NVL(SUM(prev_deleted),0) + NVL(SUM(prev_auto_deleted),0),0,NULL,NVL(SUM(prev_deleted),0) + NVL(SUM(prev_auto_deleted),0))  * 100) BIX_EMC_DELCHANGE,
 NVL(SUM(curr_backlog),0)  BIX_EMC_BACKLOG_CP,
 ((NVL(SUM(curr_backlog),0) - DECODE(SUM(prev_backlog),0,NULL,SUM(prev_backlog)))
 / DECODE(SUM(prev_backlog),0,NULL,SUM(prev_backlog)) * 100) BIX_EMC_BACKCHANGE,
 NVL(SUM(prev_backlog),0)  BIX_EMC_PREVBACKLOG,
 (NVL(SUM(curr_dist_trfr),0)/ DECODE(SUM(NVL(curr_deleted,0) + NVL(curr_replied,0)),0,NULL,
 SUM(NVL(curr_deleted,0) + NVL(curr_replied,0)))*100) BIX_EMC_TRANRATIO_CP,
 ((SUM(curr_dist_trfr)/DECODE(SUM(NVL(curr_deleted,0) + NVL(curr_replied,0)),0,NULL,
  SUM(NVL(curr_deleted,0) + NVL(curr_replied,0))) - SUM(prev_dist_trfr)/ DECODE(SUM(NVL(prev_deleted,0) + NVL(prev_replied,0)),0,NULL,
  SUM(NVL(prev_deleted,0) + NVL(prev_replied,0)))) * 100)  BIX_EMC_TRATIOCHANGE,
 ((NVL(SUM(curr_deleted),0)+ NVL(SUM(curr_auto_deleted),0))/ DECODE(SUM(curr_completed),0,NULL,SUM(curr_completed))*100) BIX_EMC_DELRATIO_CP,
 ((((NVL(SUM(curr_deleted),0)+ NVL(SUM(curr_auto_deleted),0))/ DECODE(SUM(curr_completed),0,NULL,SUM(curr_completed))) -
 ((NVL(SUM(prev_deleted),0)+ NVL(SUM(prev_auto_deleted),0))/ DECODE(SUM(prev_completed),0,NULL,SUM(prev_completed))))* 100) BIX_EMC_DRATIOCHANGE,
  NVL(SUM(curr_sr_created),0) BIX_EMC_SR_CP,
 ((NVL(SUM(curr_sr_created),0) - SUM(prev_sr_created)) / SUM(prev_sr_created) * 100) BIX_EMC_SRCHANGE,
  NVL(SUM(curr_leads_created),0) BIX_EMC_LEADS_CP,
  ((NVL(SUM(curr_leads_created),0) - SUM(prev_leads_created)) / SUM(prev_leads_created) * 100) BIX_EMC_LEADSCHANGE,
  NVL(SUM(SUM(curr_received)) OVER(),0) BIX_PMV_TOTAL1,
  ((NVL(SUM(SUM(curr_received)) OVER(),0) - SUM(SUM(prev_received)) OVER()) / SUM(SUM(prev_received)) OVER() * 100) BIX_PMV_TOTAL2,
  NVL(SUM(SUM(curr_composed)) OVER(),0) BIX_PMV_TOTAL3,
 ((NVL(SUM(SUM(curr_composed)) OVER(),0) - DECODE(SUM(SUM(prev_composed)) OVER(),0,NULL,SUM(SUM(prev_composed)) OVER()))
 / DECODE(SUM(SUM(prev_composed)) OVER(),0,NULL,SUM(SUM(prev_composed)) OVER()) * 100) BIX_PMV_TOTAL4,
  NVL(SUM(SUM(curr_replied)) OVER(),0) + NVL(SUM(SUM(curr_auto_replied)) OVER(),0) BIX_PMV_TOTAL5,
 (((NVL(SUM(SUM(curr_replied)) OVER(),0) + NVL(SUM(SUM(curr_auto_replied)) OVER(),0))  -
 (NVL(SUM(SUM(prev_replied)) OVER(),0) + NVL(SUM(SUM(prev_auto_replied)) OVER(),0)))
  / DECODE(NVL(SUM(SUM(prev_replied)) OVER(),0) + NVL(SUM(SUM(prev_auto_replied)) OVER(),0),0,NULL,
  NVL(SUM(SUM(prev_replied)) OVER(),0) + NVL(SUM(SUM(prev_auto_replied)) OVER(),0))  * 100) BIX_PMV_TOTAL6,
  NVL(SUM(SUM(curr_deleted)) OVER(),0) + NVL(SUM(SUM(curr_auto_deleted)) OVER(),0) BIX_PMV_TOTAL7,
  (((NVL(SUM(SUM(curr_deleted)) OVER(),0) + NVL(SUM(SUM(curr_auto_deleted)) OVER(),0))  -
   (NVL(SUM(SUM(prev_deleted)) OVER(),0) + NVL(SUM(SUM(prev_auto_deleted)) OVER(),0)) )
  / DECODE(NVL(SUM(SUM(prev_deleted)) OVER(),0) + NVL(SUM(SUM(prev_auto_deleted)) OVER(),0),0,NULL,
   NVL(SUM(SUM(prev_deleted)) OVER(),0) + NVL(SUM(SUM(prev_auto_deleted)) OVER(),0))  * 100) BIX_PMV_TOTAL8,
  SUM(SUM(curr_backlog)) OVER()  BIX_PMV_TOTAL9,
  ((SUM(SUM(curr_backlog)) OVER() - DECODE(SUM(SUM(prev_backlog)) OVER(),0,NULL,SUM(SUM(prev_backlog)) OVER()))
  / DECODE(SUM(SUM(prev_backlog)) OVER(),0,NULL,SUM(SUM(prev_backlog)) OVER()) * 100) BIX_PMV_TOTAL10,
  (NVL(SUM(SUM(curr_dist_trfr)) OVER(),0)/ DECODE(SUM(SUM(NVL(curr_deleted,0) + NVL(curr_replied,0))) OVER(),0,NULL,
  SUM(SUM(NVL(curr_deleted,0) + NVL(curr_replied,0))) OVER())*100) BIX_PMV_TOTAL11,
  ((SUM(SUM(curr_dist_trfr)) OVER()/DECODE(SUM(SUM(NVL(curr_deleted,0) + NVL(curr_replied,0))) OVER(),0,NULL,
  SUM(SUM(NVL(curr_deleted,0) + NVL(curr_replied,0))) OVER()) -
  SUM(SUM(prev_dist_trfr)) OVER()/ DECODE(SUM(SUM(NVL(prev_deleted,0) + NVL(prev_replied,0))) OVER(),0,NULL,
   SUM(SUM(NVL(prev_deleted,0) + NVL(prev_replied,0))) OVER())) * 100)  BIX_PMV_TOTAL12,
   ((NVL(SUM(SUM(curr_deleted)) OVER(),0) + NVL(SUM(SUM(curr_auto_deleted)) OVER(),0) )/
  DECODE(SUM(SUM(curr_completed)) OVER(),0,NULL,SUM(SUM(curr_completed)) OVER())*100) BIX_PMV_TOTAL13,
 ((((NVL(SUM(SUM(curr_deleted)) OVER(),0)+ NVL(SUM(SUM(curr_auto_deleted)) OVER(),0))/ DECODE(SUM(SUM(curr_completed)) OVER(),0,NULL,SUM(SUM(curr_completed)) OVER())) -
 ((NVL(SUM(SUM(prev_deleted)) OVER(),0)+ NVL(SUM(SUM(prev_auto_deleted)) OVER(),0))/ DECODE(SUM(SUM(prev_completed)) OVER(),0,NULL,SUM(SUM(prev_completed)) OVER())))* 100) BIX_PMV_TOTAL14,
  NVL(SUM(SUM(curr_sr_created)) OVER(),0) BIX_PMV_TOTAL15,
  ((NVL(SUM(SUM(curr_sr_created)) OVER(),0) - SUM(SUM(prev_sr_created)) OVER()) / SUM(SUM(prev_sr_created)) OVER() * 100)BIX_PMV_TOTAL16,
  NVL(SUM(SUM(curr_leads_created)) OVER(),0) BIX_PMV_TOTAL17,
  ((NVL(SUM(SUM(curr_leads_created)) OVER(),0) - SUM(SUM(prev_leads_created)) OVER()) / SUM(SUM(prev_leads_created)) OVER() * 100)BIX_PMV_TOTAL18
--START 001 added the following new columns for calculation purposes
 ,NVL(SUM(curr_dist_trfr),0)/ DECODE(SUM(NVL(curr_deleted,0) + NVL(curr_replied,0)),0,NULL,
  SUM(NVL(curr_deleted,0) + NVL(curr_replied,0)))*100      BIX_CALC_ITEM1
 ,NVL(SUM(SUM(curr_dist_trfr)) OVER(),0)/ DECODE(SUM(SUM(NVL(curr_deleted,0) + NVL(curr_replied,0))) OVER(),0,NULL,
  SUM(SUM(NVL(curr_deleted,0) + NVL(curr_replied,0))) OVER())*100 BIX_CALC_ITEM2
 ,NVL(SUM(prev_dist_trfr),0)/ DECODE(SUM(NVL(prev_deleted,0) + NVL(prev_replied,0)),0,NULL,
  SUM(NVL(prev_deleted,0) + NVL(prev_replied,0)))*100      BIX_CALC_ITEM3
 ,NVL(SUM(SUM(prev_dist_trfr)) OVER(),0)/ DECODE(SUM(SUM(NVL(prev_deleted,0) + NVL(prev_replied,0))) OVER(),0,NULL,
  SUM(SUM(NVL(prev_deleted,0) + NVL(prev_replied,0))) OVER())*100 BIX_CALC_ITEM4
 ,(NVL(SUM(curr_deleted),0)+ NVL(SUM(curr_auto_deleted),0))/ DECODE(SUM(curr_completed),0,NULL,SUM(curr_completed))*100 BIX_CALC_ITEM5
 ,(NVL(SUM(SUM(curr_deleted)) OVER(),0) + NVL(SUM(SUM(curr_auto_deleted)) OVER(),0) )/
   DECODE(SUM(SUM(curr_completed)) OVER(),0,NULL,SUM(SUM(curr_completed)) OVER())*100 BIX_CALC_ITEM6
 ,(NVL(SUM(prev_deleted),0)+ NVL(SUM(prev_auto_deleted),0))/ DECODE(SUM(prev_completed),0,NULL,SUM(prev_completed))*100 BIX_CALC_ITEM7
 ,(NVL(SUM(SUM(prev_deleted)) OVER(),0) + NVL(SUM(SUM(prev_auto_deleted)) OVER(),0) )/
   DECODE(SUM(SUM(prev_completed)) OVER(),0,NULL,SUM(SUM(prev_completed)) OVER())*100 BIX_CALC_ITEM8
 ,NVL(SUM(curr_received),0)                                BIX_CALC_ITEM9
 ,NVL(SUM(SUM(curr_received)) OVER(),0)                    BIX_CALC_ITEM10
 ,NVL(SUM(prev_received),0)                                BIX_CALC_ITEM11
 ,NVL(SUM(SUM(prev_received)) OVER(),0)                    BIX_CALC_ITEM12
 ,NVL(SUM(curr_replied),0) + NVL(SUM(curr_auto_replied),0) BIX_CALC_ITEM13
 ,NVL(SUM(SUM(curr_replied)) OVER(),0) + NVL(SUM(SUM(curr_auto_replied)) OVER(),0) BIX_CALC_ITEM14
 ,NVL(SUM(prev_replied),0) + NVL(SUM(prev_auto_replied),0) BIX_CALC_ITEM15
 ,NVL(SUM(SUM(prev_replied)) OVER(),0) + NVL(SUM(SUM(prev_auto_replied)) OVER(),0) BIX_CALC_ITEM16
 ,NVL(SUM(curr_backlog),0)                                 BIX_CALC_ITEM17
 ,NVL(SUM(SUM(curr_backlog))  OVER(),0)                    BIX_CALC_ITEM18
 ,NVL(SUM(prev_backlog),0)                                 BIX_CALC_ITEM19
 ,NVL(SUM(SUM(prev_backlog))  OVER(),0)                    BIX_CALC_ITEM20
 ,NVL(SUM(curr_composed),0)                                BIX_CALC_ITEM21
 ,NVL(SUM(SUM(curr_composed)) OVER(),0)                    BIX_CALC_ITEM22
 ,NVL(SUM(prev_composed),0)                                BIX_CALC_ITEM23
 ,NVL(SUM(SUM(prev_composed)) OVER(),0)                    BIX_CALC_ITEM24
 ,NVL(SUM(curr_sr_created),0)                              BIX_CALC_ITEM25
 ,NVL(SUM(SUM(curr_sr_created)) OVER(),0)                  BIX_CALC_ITEM26
 ,NVL(SUM(prev_sr_created),0)                              BIX_CALC_ITEM27
 ,NVL(SUM(SUM(prev_sr_created)) OVER(),0)                  BIX_CALC_ITEM28
 ,NVL(SUM(curr_leads_created),0)                           BIX_CALC_ITEM29
 ,NVL(SUM(SUM(curr_leads_created)) OVER(),0)               BIX_CALC_ITEM30
 ,NVL(SUM(prev_leads_created),0)                           BIX_CALC_ITEM31
 ,NVL(SUM(SUM(prev_leads_created)) OVER(),0)               BIX_CALC_ITEM32
 ,NVL(SUM(SUM(curr_trfd)) OVER(),0)                        BIX_CALC_ITEM33
 ,NVL(SUM(curr_trfd),0)                                    BIX_EMC_TRANOUT
 ,((NVL(SUM(curr_trfd),0)-DECODE(SUM(prev_trfd),0,NULL,SUM(prev_trfd)))
/DECODE(SUM(prev_trfd),0,NULL,SUM(prev_trfd)) * 100)   BIX_PMV_EMC_TRANSOUT_CHNG
 ,((NVL(SUM(SUM(curr_trfd)) OVER(),0)-DECODE(SUM(SUM(prev_trfd)) OVER(),0,NULL,SUM(SUM(prev_trfd)) OVER()))
/DECODE(SUM(SUM(prev_trfd)) OVER(),0,NULL,SUM(SUM(prev_trfd)) OVER()) * 100)    BIX_PMV_EMC_TRANSOUT_CHNG_TOTA
--End 001 addition of columns done
FROM ( ';
  IF l_view_by = 'EMAIL ACCOUNT+EMAIL ACCOUNT' THEN
    l_sqltext := l_sqltext || ' SELECT
 email_account_id id,
 SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_OFFERED_IN_PERIOD)) curr_received,
 SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_OFFERED_IN_PERIOD)) prev_received,
 SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_COMPOSED_IN_PERIOD)) curr_composed,
 SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_COMPOSED_IN_PERIOD)) prev_composed,
 SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,NVL(EMAILS_REPLIED_IN_PERIOD,0) +
 NVL(EMAILS_DELETED_IN_PERIOD,0) + NVL(EMAILS_AUTO_UPTD_SR_IN_PERIOD,0) +
 NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0) + NVL(EMAILS_AUTO_DELETED_IN_PERIOD,0) +
 NVL(EMAILS_AUTO_RESOLVED_IN_PERIOD,0))) curr_completed,
 SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,NVL(EMAILS_REPLIED_IN_PERIOD,0) +
 NVL(EMAILS_DELETED_IN_PERIOD,0) + NVL(EMAILS_AUTO_UPTD_SR_IN_PERIOD,0) +
 NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0) + NVL(EMAILS_AUTO_DELETED_IN_PERIOD,0) +
 NVL(EMAILS_AUTO_RESOLVED_IN_PERIOD,0))) prev_completed,
 SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_REPLIED_IN_PERIOD)) curr_replied,
 SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_REPLIED_IN_PERIOD)) prev_replied,
 SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_AUTO_REPLIED_IN_PERIOD)) curr_auto_replied,
 SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_AUTO_REPLIED_IN_PERIOD)) prev_auto_replied,
 SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_DELETED_IN_PERIOD)) curr_deleted,
 SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_DELETED_IN_PERIOD)) prev_deleted,
 SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_AUTO_DELETED_IN_PERIOD)) curr_auto_deleted,
 SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_AUTO_DELETED_IN_PERIOD)) prev_auto_deleted,
 SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_RSL_AND_TRFD_IN_PERIOD)) curr_dist_trfr,
 SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_RSL_AND_TRFD_IN_PERIOD)) prev_dist_trfr,
 SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,SR_CREATED_IN_PERIOD)) curr_sr_created,
 SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,SR_CREATED_IN_PERIOD)) prev_sr_created,
 SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,LEADS_CREATED_IN_PERIOD)) curr_leads_created,
 SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,LEADS_CREATED_IN_PERIOD)) prev_leads_created,
 NULL curr_backlog,
 NULL prev_backlog,
 SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,emails_rsl_and_trfd_in_period))  curr_trfd,--001
 SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,emails_rsl_and_trfd_in_period)) prev_trfd --001
FROM bix_email_details_mv fact,
 fii_time_rpt_struct calendar
WHERE fact.time_id = calendar.time_id
AND fact.period_type_id = calendar.period_type_id
AND fact.row_type = :l_row_type
AND calendar.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND bitand(calendar.record_type_id,&BIS_NESTED_PATTERN ) =  calendar.record_type_id '
|| l_where_clause || '
GROUP BY email_account_id
UNION ALL
SELECT email_account_id id,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
 NULL,NULL,NULL,NULL,SUM(DECODE(period_start_date,:l_max_collect_date,NVL(ACCUMULATED_OPEN_EMAILS,0) + NVL(ACCUMULATED_EMAILS_IN_QUEUE,0) )) curr_backlog,
 SUM(DECODE(period_start_date,&BIS_PREVIOUS_ASOF_DATE,NVL(ACCUMULATED_OPEN_EMAILS,0) + NVL(ACCUMULATED_EMAILS_IN_QUEUE,0) )) prev_backlog,NULL,NULL
FROM  bix_email_details_mv
WHERE time_id IN (TO_CHAR(:l_max_collect_date,''J''),TO_CHAR(&BIS_PREVIOUS_ASOF_DATE,''J''))
AND   row_type = :l_row_type
AND   period_type_id = :l_period_type_id ' || l_where_clause || '
GROUP BY email_account_id
) fact, ';
ELSE
    l_sqltext := l_sqltext || ' SELECT
 email_classification_id id,
 SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_OFFERED_IN_PERIOD)) curr_received,
 SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_OFFERED_IN_PERIOD)) prev_received,
 SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_COMPOSED_IN_PERIOD)) curr_composed,
 SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_COMPOSED_IN_PERIOD)) prev_composed,
 SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,NVL(EMAILS_REPLIED_IN_PERIOD,0) +
 NVL(EMAILS_DELETED_IN_PERIOD,0) + NVL(EMAILS_AUTO_UPTD_SR_IN_PERIOD,0) +
 NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0) + NVL(EMAILS_AUTO_DELETED_IN_PERIOD,0) +
 NVL(EMAILS_AUTO_RESOLVED_IN_PERIOD,0))) curr_completed,
 SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,NVL(EMAILS_REPLIED_IN_PERIOD,0) +
 NVL(EMAILS_DELETED_IN_PERIOD,0) + NVL(EMAILS_AUTO_UPTD_SR_IN_PERIOD,0) +
 NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0) + NVL(EMAILS_AUTO_DELETED_IN_PERIOD,0) +
 NVL(EMAILS_AUTO_RESOLVED_IN_PERIOD,0))) prev_completed,
 SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_REPLIED_IN_PERIOD)) curr_replied,
 SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_REPLIED_IN_PERIOD)) prev_replied,
 SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_AUTO_REPLIED_IN_PERIOD)) curr_auto_replied,
 SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_AUTO_REPLIED_IN_PERIOD)) prev_auto_replied,
 SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_DELETED_IN_PERIOD)) curr_deleted,
 SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_DELETED_IN_PERIOD)) prev_deleted,
 SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_AUTO_DELETED_IN_PERIOD)) curr_auto_deleted,
 SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_AUTO_DELETED_IN_PERIOD)) prev_auto_deleted,
 SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_RSL_AND_TRFD_IN_PERIOD)) curr_dist_trfr,
 SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_RSL_AND_TRFD_IN_PERIOD)) prev_dist_trfr,
 SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,SR_CREATED_IN_PERIOD)) curr_sr_created,
 SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,SR_CREATED_IN_PERIOD)) prev_sr_created,
 SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,LEADS_CREATED_IN_PERIOD)) curr_leads_created,
 SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,LEADS_CREATED_IN_PERIOD)) prev_leads_created,
 NULL curr_backlog,
 NULL prev_backlog,
 SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE ,emails_rsl_and_trfd_in_period))  curr_trfd,--001 Transferred Out column in the Email Activity table portlet
 SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,emails_rsl_and_trfd_in_period)) prev_trfd --001
FROM bix_email_details_mv fact,
 fii_time_rpt_struct calendar
WHERE fact.time_id = calendar.time_id
AND fact.row_type = :l_row_type
AND fact.period_type_id = calendar.period_type_id
AND calendar.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
AND bitand(calendar.record_type_id,&BIS_NESTED_PATTERN ) =  calendar.record_type_id '
|| l_where_clause || '
GROUP BY email_classification_id
UNION ALL
SELECT email_classification_id id,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
 NULL,NULL,NULL,SUM(DECODE(period_start_date,:l_max_collect_date,NVL(ACCUMULATED_OPEN_EMAILS,0) + NVL(ACCUMULATED_EMAILS_IN_QUEUE,0) )) curr_backlog,
 SUM(DECODE(period_start_date,&BIS_PREVIOUS_ASOF_DATE,NVL(ACCUMULATED_OPEN_EMAILS,0) + NVL(ACCUMULATED_EMAILS_IN_QUEUE,0) )) prev_backlog,NULL,NULL
FROM   bix_email_details_mv
WHERE  time_id IN (TO_CHAR(:l_max_collect_date,''J''),TO_CHAR(&BIS_PREVIOUS_ASOF_DATE,''J''))
AND    row_type = :l_row_type
AND   period_type_id = :l_period_type_id ' || l_where_clause || '
GROUP BY email_classification_id
) fact, ';

END IF;

	IF l_view_by = 'EMAIL ACCOUNT+EMAIL ACCOUNT' THEN
	    l_sqltext := l_sqltext || ' bix_email_accounts_v lookup_table ';
	ELSE
	    l_sqltext := l_sqltext || ' bix_email_classifications_v lookup_table ';
	END IF;

	l_sqltext := l_sqltext || ' WHERE fact.id = lookup_table.id
     GROUP BY lookup_table.value,lookup_table.id ';

--Start 002 , added the logic for filtering out rows with only 0 | N/A values

l_sqltext := 'SELECT  * FROM ( '||l_sqltext ||' ) WHERE
ABS(NVL(BIX_EMC_RCVD_CP   ,0))+ABS(NVL(BIX_EMC_RCVDCHANGE,0))+ABS(NVL(BIX_EMC_REPLD_CP  ,0))+ABS(NVL(BIX_EMC_REPCHANGE ,0))+
ABS(NVL(BIX_EMC_DELETED_CP,0))+ABS(NVL(BIX_EMC_DELCHANGE ,0))+ABS(NVL(BIX_EMC_TRANOUT   ,0))+ABS(NVL(BIX_PMV_EMC_TRANSOUT_CHNG,0))+
ABS(NVL(BIX_EMC_BACKLOG_CP    ,0))+ABS(NVL(BIX_EMC_BACKCHANGE    ,0))+ABS(NVL(BIX_EMC_COMPOSED_CP   ,0))+ABS(NVL(BIX_EMC_COMPOSE_CHANGE,0))+
ABS(NVL(BIX_EMC_TRANRATIO_CP  ,0))+ABS(NVL(BIX_EMC_TRATIOCHANGE  ,0))+ABS(NVL(BIX_EMC_DELRATIO_CP   ,0))+ABS(NVL(BIX_EMC_DRATIOCHANGE  ,0))+
ABS(NVL(BIX_EMC_SR_CP         ,0))+ABS(NVL(BIX_EMC_SRCHANGE      ,0))+ABS(NVL(BIX_EMC_LEADS_CP      ,0))+ABS(NVL(BIX_EMC_LEADSCHANGE  ,0))
!=0  &ORDER_BY_CLAUSE ';

p_sql_text := REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(l_sqltext,'      ',' '),'     ',' '),'    ',' '),'   ',' '),'  ',' ');

--End 002 , added the logic for filtering out rows with only 0 | N/A values and used "REPLACE" to shorten the query length

p_custom_output.EXTEND();
l_custom_rec.attribute_name := ':l_period_type_id' ;
l_custom_rec.attribute_value:= l_period_type_id;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;

-- Insert account Bind Variable

IF ( l_account IS NOT NULL) THEN
l_custom_rec.attribute_name := ':l_account' ;
l_custom_rec.attribute_value:= l_account;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;
END IF;

IF ( l_classification IS NOT NULL) THEN
l_custom_rec.attribute_name := ':l_classification' ;
l_custom_rec.attribute_value:= l_classification;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;
END IF;

l_custom_rec.attribute_name := ':l_max_collect_date' ;
l_custom_rec.attribute_value:= l_max_collect_date;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;

l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.View_By_Type;
l_custom_rec.attribute_value := l_view_by;

p_custom_output.EXTEND();
p_custom_output(p_custom_output.COUNT) := l_custom_rec;

l_custom_rec.attribute_name := ':l_row_type' ;
l_custom_rec.attribute_value:= l_row_type;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;

EXCEPTION
WHEN OTHERS THEN
NULL;
END GET_SQL;
END  BIX_PMV_EMC_ACCOUNT_RPT_PKG;

/
