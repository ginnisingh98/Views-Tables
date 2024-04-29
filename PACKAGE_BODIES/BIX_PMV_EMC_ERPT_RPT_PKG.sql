--------------------------------------------------------
--  DDL for Package Body BIX_PMV_EMC_ERPT_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_EMC_ERPT_RPT_PKG" AS
/*$Header: bixerptr.plb 120.0 2005/05/25 17:16:32 appldev noship $ */

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
l_agent_cost      NUMBER;
l_custom_rec       BIS_QUERY_ATTRIBUTES;
l_period_type_id   NUMBER := 1;
l_record_type_id   NUMBER ;
l_account      VARCHAR2(32000);
l_start_date   DATE;
l_end_date     DATE;
l_period_from  DATE;
l_period_to    DATE;
l_max_collect_date   VARCHAR2(100);
l_period_start_date  DATE;
l_application_id NUMBER := 680;
l_classification VARCHAR2(32000);
l_view_by  varchar2(1000);
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

 /* Get the MAX date for which data is collected in Email Summary table */

    BIS_COLLECTION_UTILITIES.get_last_refresh_dates('BIX_EMAIL_DETAILS_F',
                                                     l_start_date,
                                                     l_end_date,
                                                     l_period_from,
                                                     l_period_to
                                                   );


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


l_sqltext :=
'
SELECT * from
(
SELECT lookup_table.value   VIEWBY,
        lookup_table.id      VIEWBYID,
nvl(sum(CURR_MSGSGOAL),0)*100/DECODE(sum(CURR_TOT_REPLD),0,NULL,sum(CURR_TOT_REPLD)) BIX_EMC_MSGSGOAL_CP
,
nvl(sum(CURR_MSGSGOAL),0)*100/DECODE(sum(CURR_TOT_REPLD),0,NULL,sum(CURR_TOT_REPLD)) BIX_CALC_ITEM1,
nvl(sum(sum(CURR_MSGSGOAL)) over(),0)*100/
      DECODE(sum(sum(CURR_TOT_REPLD)) over(),0,NULL,sum(sum(CURR_TOT_REPLD)) over()) BIX_PMV_TOTAL1,
	 nvl(sum(sum(CURR_MSGSGOAL)) over(),0)*100/
	 DECODE(sum(sum(CURR_TOT_REPLD)) over(),0,NULL,sum(sum(CURR_TOT_REPLD)) over()) BIX_CALC_ITEM2,
	 100*
	 (
	 (nvl(sum(CURR_MSGSGOAL),0)/DECODE(sum(CURR_TOT_REPLD),0,NULL,sum(CURR_TOT_REPLD))) -
      (nvl(sum(PREV_MSGSGOAL),0)/DECODE(sum(PREV_TOT_REPLD),0,NULL,sum(PREV_TOT_REPLD)))
	 )
	  BIX_EMC_MGCHANGE,
	 100*
	 (
	 (nvl(sum(sum(CURR_MSGSGOAL)) over(),0)/DECODE(sum(sum(CURR_TOT_REPLD)) over(),0,NULL,sum(sum(CURR_TOT_REPLD)) over()))-
      (nvl(sum(sum(PREV_MSGSGOAL)) over(),0)/DECODE(sum(sum(PREV_TOT_REPLD)) over(),0,NULL,sum(sum(PREV_TOT_REPLD)) over()))
	 )
	  BIX_PMV_TOTAL2,
nvl(sum(PREV_MSGSGOAL),0)*100/DECODE(sum(PREV_TOT_REPLD),0,NULL,sum(PREV_TOT_REPLD)) BIX_EMC_PREVMSGSGOAL,
nvl(sum(PREV_MSGSGOAL),0)*100/DECODE(sum(PREV_TOT_REPLD),0,NULL,sum(PREV_TOT_REPLD)) BIX_CALC_ITEM3,
nvl(sum(sum(PREV_MSGSGOAL)) over(),0)*100/DECODE(sum(sum(PREV_TOT_REPLD)) over(),0,NULL,sum(sum(PREV_TOT_REPLD))
over()) BIX_CALC_ITEM4,
nvl(sum(CURR_TOT_REPLD),0) BIX_EMC_REPLD_CP,
nvl(sum(sum(CURR_TOT_REPLD)) over(),0) BIX_PMV_TOTAL3,
(nvl(sum(CURR_TOT_REPLD),0) - sum(PREV_TOT_REPLD))*100/DECODE(sum(PREV_TOT_REPLD),0,NULL,sum(PREV_TOT_REPLD))  BIX_EMC_REPCHANGE,
(nvl(sum(sum(CURR_TOT_REPLD)) over(),0)-sum(sum(PREV_TOT_REPLD)) over())*100/
   DECODE(sum(sum(PREV_TOT_REPLD)) over(),0,NULL,sum(sum(PREV_TOT_REPLD)) over()) BIX_PMV_TOTAL4,
nvl(sum(prev_tot_repld),0) BIX_EMC_PRREPLD,
nvl(sum(CURR_AUTO_REPLD),0)*100/
 decode(SUM(CURR_TOT_REPLD),0,NULL,SUM(CURR_TOT_REPLD))       BIX_EMC_AUTO_RPLD_RATE_CP,
nvl(sum(sum(CURR_AUTO_REPLD)) over(),0)*100/
 decode(SUM(SUM(CURR_TOT_REPLD)) OVER(),0,NULL,SUM(SUM(CURR_TOT_REPLD)) OVER())   BIX_PMV_TOTAL11,
((nvl(sum(CURR_AUTO_REPLD),0)/ decode(SUM(CURR_TOT_REPLD),0,NULL,SUM(CURR_TOT_REPLD))) -
(sum(PREV_AUTO_REPLD)/ decode(SUM(PREV_TOT_REPLD),0,NULL,SUM(PREV_TOT_REPLD))))*100 BIX_EMC_AUTO_PRLD_CHANGE,
((nvl(SUM(sum(CURR_AUTO_REPLD)) OVER(),0)/ decode(SUM(SUM(CURR_TOT_REPLD)) OVER(),0,NULL,SUM(SUM(CURR_TOT_REPLD)) OVER())) -
(SUM(sum(PREV_AUTO_REPLD))OVER()/ decode(SUM(SUM(PREV_TOT_REPLD)) OVER(),0,NULL,SUM(SUM(PREV_TOT_REPLD)) OVER())))*100 BIX_PMV_TOTAL13,
NVL(SUM(CURR_TRFD),0)*100/DECODE(SUM(CURR_RESOLVED),0,NULL,SUM(CURR_RESOLVED)) BIX_EMC_TRANRATIO_CP,
NVL(SUM(SUM(CURR_TRFD)) OVER(),0)*100/
  DECODE(SUM(SUM(CURR_RESOLVED)) OVER(),0,NULL,SUM(SUM(CURR_RESOLVED)) OVER())   BIX_PMV_TOTAL12,

((NVL(SUM(CURR_TRFD),0)/DECODE(SUM(CURR_RESOLVED),0,NULL,SUM(CURR_RESOLVED))) -
(SUM(PREV_TRFD)/DECODE(SUM(PREV_RESOLVED),0,NULL,SUM(PREV_RESOLVED)))) * 100
 BIX_EMC_TRATIOCHANGE,

((NVL(SUM(SUM(CURR_TRFD)) OVER(),0)/DECODE(SUM(SUM(CURR_RESOLVED)) OVER(),0,NULL,SUM(SUM(CURR_RESOLVED)) OVER())) -
(SUM(SUM(PREV_TRFD)) OVER()/DECODE(SUM(SUM(PREV_RESOLVED)) OVER(),0,NULL,SUM(SUM(PREV_RESOLVED)) OVER()))) * 100
 BIX_PMV_TOTAL14,
nvl(sum(CURR_CRTIME),0)/(3600*DECODE(sum(CURR_TOT_REPLD),0,NULL,sum(CURR_TOT_REPLD))) BIX_EMC_CRTIME_CP,
nvl(sum(CURR_CRTIME),0)/(3600*DECODE(sum(CURR_TOT_REPLD),0,NULL,sum(CURR_TOT_REPLD))) BIX_CALC_ITEM5,
nvl(sum(sum(CURR_CRTIME)) over(),0)/
    (3600*DECODE(sum(sum(CURR_TOT_REPLD)) over(),0,NULL,sum(sum(CURR_TOT_REPLD)) over())) BIX_PMV_TOTAL5,
    nvl(sum(sum(CURR_CRTIME)) over(),0)/
	   (3600*DECODE(sum(sum(CURR_TOT_REPLD)) over(),0,NULL,sum(sum(CURR_TOT_REPLD)) over())) BIX_CALC_ITEM6,
((nvl(sum(CURR_CRTIME),0)/DECODE(sum(CURR_TOT_REPLD),0,NULL,sum(CURR_TOT_REPLD)))
   - (sum(PREV_CRTIME)/DECODE(sum(PREV_TOT_REPLD),0,NULL,sum(PREV_TOT_REPLD))))*100/
(sum(PREV_CRTIME)/DECODE(sum(PREV_TOT_REPLD),0,NULL,sum(PREV_TOT_REPLD))) BIX_EMC_CRCHANGE,
((nvl(sum(sum(CURR_CRTIME)) OVER(),0)/DECODE(sum(sum(CURR_TOT_REPLD)) OVER(),0,NULL,sum(sum(CURR_TOT_REPLD)) OVER()))
   - (sum(sum(PREV_CRTIME)) OVER()/DECODE(sum(sum(PREV_TOT_REPLD)) OVER(),0,NULL,sum(sum(PREV_TOT_REPLD)) OVER())))*100/
(sum(sum(PREV_CRTIME)) OVER()/DECODE(sum(sum(PREV_TOT_REPLD)) OVER(),0,NULL,sum(sum(PREV_TOT_REPLD)) OVER())) BIX_PMV_TOTAL6,
nvl(sum(PREV_CRTIME),0)/(3600*DECODE(sum(PREV_TOT_REPLD),0,NULL,sum(PREV_TOT_REPLD))) BIX_EMC_PRCRTIME,
nvl(sum(PREV_CRTIME),0)/(3600*DECODE(sum(PREV_TOT_REPLD),0,NULL,sum(PREV_TOT_REPLD))) BIX_CALC_ITEM7,
sum(sum(PREV_CRTIME)) over()/
	   (3600*DECODE(sum(sum(PREV_TOT_REPLD)) over(),0,NULL,sum(sum(PREV_TOT_REPLD)) over())) BIX_CALC_ITEM8,
nvl(sum(CURR_ARTIME),0)/(3600*sum(CURR_REPLD)) BIX_EMC_ARTIME_CP,
nvl(sum(sum(CURR_ARTIME)) over(),0)/(3600*sum(sum(CURR_REPLD)) over()) BIX_PMV_TOTAL7,
((nvl(sum(CURR_ARTIME),0)/(3600*sum(CURR_REPLD))) - (nvl(sum(PREV_ARTIME),0)/(3600*sum(PREV_REPLD))))*100 /
       (nvl(sum(PREV_ARTIME),0)/(3600*sum(PREV_REPLD))) BIX_EMC_ARCHANGE,
((nvl(sum(sum(CURR_ARTIME)) over(),0)/(3600*sum(sum(CURR_REPLD)) over())) - (nvl(sum(sum(PREV_ARTIME)) over(),0)/(3600*sum(sum(PREV_REPLD)) over())))*100 /
       (nvl(sum(sum(PREV_ARTIME)) over(),0)/(3600*sum(sum(PREV_REPLD)) over())) BIX_PMV_TOTAL8,
nvl(sum(CURR_ONEDONE),0)*100/sum(CURR_THREADS) BIX_EMC_ONE_DONE_CP,
nvl(sum(CURR_ONEDONE),0)*100/sum(CURR_THREADS) BIX_CALC_ITEM9,
nvl(sum(sum(CURR_ONEDONE)) over(),0)*100/sum(sum(CURR_THREADS)) over() BIX_PMV_TOTAL9,
nvl(sum(sum(CURR_ONEDONE)) over(),0)*100/sum(sum(CURR_THREADS)) over() BIX_CALC_ITEM10,
 nvl(sum(PREV_ONEDONE),0)*100/sum(PREV_THREADS) BIX_CALC_ITEM11,
 nvl(sum(sum(PREV_ONEDONE)) over(),0)*100/sum(sum(PREV_THREADS)) over() BIX_CALC_ITEM12,
nvl(sum(CURR_ONEDONE),0)*100/sum(CURR_THREADS)- nvl(sum(PREV_ONEDONE),0)*100/sum(PREV_THREADS) BIX_EMC_ODCHANGE,
nvl(sum(sum(CURR_ONEDONE)) over(),0)*100/sum(sum(CURR_THREADS)) over()-
		nvl(sum(sum(PREV_ONEDONE)) over(),0)*100/sum(sum(PREV_THREADS)) over() BIX_PMV_TOTAL10  ,
(NVL(SUM(curr_deleted),0)+ NVL(SUM(curr_auto_deleted),0))/ DECODE(SUM(curr_completed),0,NULL,SUM(curr_completed))*100 BIX_EMC_DELRATIO_CP,
(NVL(SUM(curr_deleted),0)+ NVL(SUM(curr_auto_deleted),0))/ DECODE(SUM(curr_completed),0,NULL,SUM(curr_completed))*100 BIX_CALC_ITEM13,
(((NVL(SUM(curr_deleted),0)+ NVL(SUM(curr_auto_deleted),0))/ DECODE(SUM(curr_completed),0,NULL,SUM(curr_completed))) -
          ((NVL(SUM(prev_deleted),0)+ NVL(SUM(prev_auto_deleted),0))/ DECODE(SUM(prev_completed),0,NULL,SUM(prev_completed))))* 100 BIX_EMC_DRATIOCHANGE,
(NVL(SUM(SUM(curr_deleted)) OVER(),0) + NVL(SUM(SUM(curr_auto_deleted)) OVER(),0) )/
          DECODE(SUM(SUM(curr_completed)) OVER(),0,NULL,SUM(SUM(curr_completed)) OVER())*100 BIX_PMV_TOTAL15,
(NVL(SUM(SUM(curr_deleted)) OVER(),0) + NVL(SUM(SUM(curr_auto_deleted)) OVER(),0) )/
          DECODE(SUM(SUM(curr_completed)) OVER(),0,NULL,SUM(SUM(curr_completed)) OVER())*100 BIX_CALC_ITEM14,
(((NVL(SUM(SUM(curr_deleted)) OVER(),0)+ NVL(SUM(SUM(curr_auto_deleted)) OVER(),0))/ DECODE(SUM(SUM(curr_completed)) OVER(),0,NULL,SUM(SUM(curr_completed)) OVER())) -
          ((NVL(SUM(SUM(prev_deleted)) OVER(),0)+ NVL(SUM(SUM(prev_auto_deleted)) OVER(),0))/ DECODE(SUM(SUM(prev_completed)) OVER(),0,NULL,SUM(SUM(prev_completed)) OVER())))* 100 BIX_PMV_TOTAL16,
(NVL(SUM(prev_deleted),0)+ NVL(SUM(prev_auto_deleted),0))/ DECODE(SUM(prev_completed),0,NULL,SUM(prev_completed))*100 BIX_CALC_ITEM15,
(NVL(SUM(SUM(prev_deleted)) OVER(),0) + NVL(SUM(SUM(prev_auto_deleted)) OVER(),0) )/
          DECODE(SUM(SUM(prev_completed)) OVER(),0,NULL,SUM(SUM(prev_completed)) OVER())*100 BIX_CALC_ITEM16,
NVL(SUM(CURR_TRFD),0)*100/DECODE(SUM(CURR_RESOLVED),0,NULL,SUM(CURR_RESOLVED)) BIX_CALC_ITEM17,
NVL(SUM(SUM(CURR_TRFD)) OVER(),0)*100/
DECODE(SUM(SUM(CURR_RESOLVED)) OVER(),0,NULL,SUM(SUM(CURR_RESOLVED)) OVER())   BIX_CALC_ITEM18,
NVL(SUM(PREV_TRFD),0)*100/DECODE(SUM(PREV_RESOLVED),0,NULL,SUM(PREV_RESOLVED)) BIX_CALC_ITEM19,
SUM(SUM(PREV_TRFD)) OVER()*100/
DECODE(SUM(SUM(PREV_RESOLVED)) OVER(),0,NULL,SUM(SUM(PREV_RESOLVED)) OVER())   BIX_CALC_ITEM20
FROM ( ';

  IF l_view_by = 'EMAIL ACCOUNT+EMAIL ACCOUNT' THEN
       l_sqltext := l_sqltext || ' SELECT  email_account_id                                ID,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
                     EMAILS_RPLD_BY_GOAL_IN_PERIOD,NULL))         CURR_MSGSGOAL,
	sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
                     EMAILS_RPLD_BY_GOAL_IN_PERIOD,NULL))         PREV_MSGSGOAL,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
		     EMAILS_REPLIED_IN_PERIOD,NULL))                    CURR_REPLD,
	sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
		     EMAILS_REPLIED_IN_PERIOD,NULL))                    PREV_REPLD,
     sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_AUTO_REPLIED_IN_PERIOD,NULL))  CURR_AUTO_REPLD,
     sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_AUTO_REPLIED_IN_PERIOD,NULL))  PREV_AUTO_REPLD,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
              NVL(EMAILS_REPLIED_IN_PERIOD,0) + NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0),NULL)) CURR_TOT_REPLD,
	SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
              NVL(EMAILS_REPLIED_IN_PERIOD,0) + NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0),NULL)) PREV_TOT_REPLD,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_RSL_AND_TRFD_IN_PERIOD,NULL)) CURR_TRFD,
	sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_RSL_AND_TRFD_IN_PERIOD,NULL)) PREV_TRFD,
        sum( decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
               NVL(EMAILS_REPLIED_IN_PERIOD,0) + NVL(EMAILS_DELETED_IN_PERIOD,0),NULL)) CURR_RESOLVED,
        sum( decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
               NVL(EMAILS_REPLIED_IN_PERIOD,0) + NVL(EMAILS_DELETED_IN_PERIOD,0),NULL)) PREV_RESOLVED,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
		     EMAIL_RESP_TIME_IN_PERIOD,NULL))                    CURR_CRTIME,
	sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
		     EMAIL_RESP_TIME_IN_PERIOD,NULL))                    PREV_CRTIME,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
		     AGENT_RESP_TIME_IN_PERIOD,NULL))                    CURR_ARTIME,
	sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
		     AGENT_RESP_TIME_IN_PERIOD,NULL))                    PREV_ARTIME,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
		     ONE_RSLN_IN_PERIOD,NULL))                    CURR_ONEDONE,
	sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
		     ONE_RSLN_IN_PERIOD,NULL))                    PREV_ONEDONE,
 	sum(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,
 		     EMAILS_DELETED_IN_PERIOD)) 		CURR_DELETED,
        sum(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
                     EMAILS_DELETED_IN_PERIOD)) 		PREV_DELETED,
	sum(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,
		     EMAILS_AUTO_DELETED_IN_PERIOD)) 		CURR_AUTO_DELETED,
     	sum(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
     		     EMAILS_AUTO_DELETED_IN_PERIOD)) 		PREV_AUTO_DELETED,
	sum(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,
		NVL(EMAILS_REPLIED_IN_PERIOD,0) +
                NVL(EMAILS_DELETED_IN_PERIOD,0) +
                NVL(EMAILS_AUTO_UPTD_SR_IN_PERIOD,0) +
		NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0) +
		NVL(EMAILS_AUTO_DELETED_IN_PERIOD,0) +
	 	NVL(EMAILS_AUTO_RESOLVED_IN_PERIOD,0))) 	CURR_COMPLETED,
     	sum(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
     		NVL(EMAILS_REPLIED_IN_PERIOD,0) +
                NVL(EMAILS_DELETED_IN_PERIOD,0) +
                NVL(EMAILS_AUTO_UPTD_SR_IN_PERIOD,0) +
		NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0) +
		NVL(EMAILS_AUTO_DELETED_IN_PERIOD,0) +
	 	NVL(EMAILS_AUTO_RESOLVED_IN_PERIOD,0))) 	PREV_COMPLETED,
        sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
		     INTERACTION_THREADS_IN_PERIOD,NULL))                    CURR_THREADS,
	sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
		     INTERACTION_THREADS_IN_PERIOD,NULL))                    PREV_THREADS,
	sum(sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
		     EMAILS_REPLIED_IN_PERIOD,NULL))) over()                 CURR_TOTALREPLD,
	sum(sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
		     EMAILS_REPLIED_IN_PERIOD,NULL))) over()                 PREV_TOTALREPLD
       FROM bix_email_details_mv fact,
  	   fii_time_rpt_struct cal
      WHERE fact.time_id = cal.time_id
      AND fact.period_type_id = cal.period_type_id
	 AND fact.row_type = :l_row_type
      AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
      AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN)=cal.record_type_id '
	  || l_where_clause ||
      ' GROUP BY email_account_id
	 ) summ, ';
      ELSE
       l_sqltext := l_sqltext || ' SELECT  email_classification_id                                ID,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
                     EMAILS_RPLD_BY_GOAL_IN_PERIOD,NULL))         CURR_MSGSGOAL,
	sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
                     EMAILS_RPLD_BY_GOAL_IN_PERIOD,NULL))         PREV_MSGSGOAL,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
		     EMAILS_REPLIED_IN_PERIOD,NULL))                    CURR_REPLD,
	sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
		     EMAILS_REPLIED_IN_PERIOD,NULL))                    PREV_REPLD,
        sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_AUTO_REPLIED_IN_PERIOD,NULL))  CURR_AUTO_REPLD,
        sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_AUTO_REPLIED_IN_PERIOD,NULL))  PREV_AUTO_REPLD,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
              NVL(EMAILS_REPLIED_IN_PERIOD,0) + NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0),NULL)) CURR_TOT_REPLD,
	SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
              NVL(EMAILS_REPLIED_IN_PERIOD,0) + NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0),NULL)) PREV_TOT_REPLD,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_RSL_AND_TRFD_IN_PERIOD,NULL)) CURR_TRFD,
	sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_RSL_AND_TRFD_IN_PERIOD,NULL)) PREV_TRFD,
        sum( decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
               NVL(EMAILS_REPLIED_IN_PERIOD,0) + NVL(EMAILS_DELETED_IN_PERIOD,0),NULL)) CURR_RESOLVED,
        sum( decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
               NVL(EMAILS_REPLIED_IN_PERIOD,0) + NVL(EMAILS_DELETED_IN_PERIOD,0),NULL)) PREV_RESOLVED,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
		     EMAIL_RESP_TIME_IN_PERIOD,NULL))                    CURR_CRTIME,
	sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
		     EMAIL_RESP_TIME_IN_PERIOD,NULL))                    PREV_CRTIME,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
		     AGENT_RESP_TIME_IN_PERIOD,NULL))                    CURR_ARTIME,
	sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
		     AGENT_RESP_TIME_IN_PERIOD,NULL))                    PREV_ARTIME,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
		     ONE_RSLN_IN_PERIOD,NULL))                    CURR_ONEDONE,
	sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
		     ONE_RSLN_IN_PERIOD,NULL))                    PREV_ONEDONE,
	sum(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,
 		     EMAILS_DELETED_IN_PERIOD)) 		CURR_DELETED,
        sum(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
                     EMAILS_DELETED_IN_PERIOD)) 		PREV_DELETED,
        sum(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,
		     EMAILS_AUTO_DELETED_IN_PERIOD)) 		CURR_AUTO_DELETED,
	sum(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
     		     EMAILS_AUTO_DELETED_IN_PERIOD)) 		PREV_AUTO_DELETED,
	sum(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,
		NVL(EMAILS_REPLIED_IN_PERIOD,0) +
                NVL(EMAILS_DELETED_IN_PERIOD,0) +
                NVL(EMAILS_AUTO_UPTD_SR_IN_PERIOD,0) +
		NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0) +
		NVL(EMAILS_AUTO_DELETED_IN_PERIOD,0) +
	 	NVL(EMAILS_AUTO_RESOLVED_IN_PERIOD,0))) 	CURR_COMPLETED,
     	sum(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
     		NVL(EMAILS_REPLIED_IN_PERIOD,0) +
                NVL(EMAILS_DELETED_IN_PERIOD,0) +
                NVL(EMAILS_AUTO_UPTD_SR_IN_PERIOD,0) +
		NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0) +
		NVL(EMAILS_AUTO_DELETED_IN_PERIOD,0) +
	 	NVL(EMAILS_AUTO_RESOLVED_IN_PERIOD,0))) 	PREV_COMPLETED,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
		     INTERACTION_THREADS_IN_PERIOD,NULL))                    CURR_THREADS,
	sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
		     INTERACTION_THREADS_IN_PERIOD,NULL))                    PREV_THREADS,
	sum(sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
		     EMAILS_REPLIED_IN_PERIOD,NULL))) over()                 CURR_TOTALREPLD,
	sum(sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
		     EMAILS_REPLIED_IN_PERIOD,NULL))) over()                 PREV_TOTALREPLD
	FROM bix_email_details_mv fact,
  	   fii_time_rpt_struct cal
      WHERE fact.time_id = cal.time_id
      AND fact.period_type_id = cal.period_type_id
	 AND fact.row_type = :l_row_type
      AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
      AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN)=cal.record_type_id '
	  || l_where_clause ||
      ' GROUP BY email_classification_id
	 ) summ, ';
      END IF;

     IF l_view_by = 'EMAIL ACCOUNT+EMAIL ACCOUNT' THEN
       l_sqltext := l_sqltext || ' bix_email_accounts_v lookup_table ';
     ELSE
        l_sqltext := l_sqltext || ' bix_email_classifications_v lookup_table ';
     END IF;

      l_sqltext := l_sqltext ||  ' WHERE summ.id = lookup_table.id
	    GROUP BY lookup_table.value, lookup_table.id

)
where
(nvl(BIX_EMC_PRREPLD,0)
+nvl(BIX_EMC_REPLD_CP,0)
+abs(nvl(BIX_EMC_REPCHANGE,0))
+nvl(BIX_EMC_PREVMSGSGOAL,0)
+nvl(BIX_EMC_MSGSGOAL_CP,0)
+abs(nvl(BIX_EMC_MGCHANGE,0))
+nvl(BIX_EMC_AUTO_RPLD_RATE_CP,0)
+abs(nvl(BIX_EMC_AUTO_PRLD_CHANGE,0))
+nvl(BIX_EMC_TRANRATIO_CP,0)
+abs(nvl(BIX_EMC_TRATIOCHANGE,0))
+nvl(BIX_EMC_DELRATIO_CP,0)
+abs(nvl(BIX_EMC_DRATIOCHANGE,0))
+nvl(BIX_EMC_ONE_DONE_CP,0)
+abs(nvl(BIX_EMC_ODCHANGE,0))
+nvl(BIX_EMC_PRCRTIME,0)
+nvl(BIX_EMC_CRTIME_CP,0)
+abs(nvl(BIX_EMC_CRCHANGE,0))
+nvl(BIX_EMC_ARTIME_CP,0)
+abs(nvl(BIX_EMC_ARCHANGE,0)))<>0
&ORDER_BY_CLAUSE ';

p_sql_text := l_sqltext;

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

l_custom_rec.attribute_name := ':l_application_id';
l_custom_rec.attribute_value:= l_application_id;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;

p_custom_output.EXTEND;
p_custom_output(p_custom_output.COUNT) := l_custom_rec;

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
END  BIX_PMV_EMC_ERPT_RPT_PKG;

/
