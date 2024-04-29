--------------------------------------------------------
--  DDL for Package Body BIX_PMV_EMC_KPI_PRTLT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_EMC_KPI_PRTLT_PKG" AS
/*$Header: bixekpib.plb 115.11 2003/12/20 02:14:42 djambula noship $ */

PROCEDURE GET_SQL(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                  p_sql_text           OUT NOCOPY VARCHAR2,
                  p_custom_output      OUT NOCOPY bis_query_attributes_TBL
                  )
AS
l_sqltext	      VARCHAR2(32000) ;
l_as_of_date   DATE;
l_period_type	varchar2(2000);
l_comp_type    varchar2(2000);
l_account      varchar2(1000);
l_record_type_id NUMBER;
l_sql_errm      varchar2(32000);
l_agent_cost      NUMBER := 0;
l_cust_resp_time_goal NUMBER;
l_service_level_goal  NUMBER;
l_custom_rec       BIS_QUERY_ATTRIBUTES;
l_period_type_id   NUMBER := 1;
l_start_date   DATE;
l_end_date     DATE;
l_period_from  DATE;
l_period_to    DATE;
l_max_collect_date   VARCHAR2(100);
l_period_start_Date  DATE;
l_dummy_cust     NUMBER;
l_application_id NUMBER := 680;
l_classification VARCHAR2(32000);
l_where_clause VARCHAR2(32000);
l_view_by varchar2(1000);
l_row_type varchar2(10) := 'ACP';

BEGIN
 p_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
 l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;

/*
 l_sqltext :=  '
	SELECT
	75   BIX_EMC_SVCLVL,
	80   BIX_PMV_TOTAL1,
	90   BIX_EMC_GOAL,
	90   BIX_PMV_TOTAL2,
	36   BIX_EMC_CRTIME,
	34.2 BIX_PMV_TOTAL3,
	30   BIX_EMC_MSGSGOAL,
	30   BIX_PMV_TOTAL4,
	273000 BIX_EMC_RCVD,
	242970 BIX_PMV_TOTAL5,
	268000 BIX_EMC_REPLD,
	246560 BIX_PMV_TOTAL6,
	18500  BIX_EMC_BACKLOG,
	19240  BIX_PMV_TOTAL7,
	5.2    BIX_EMC_REPPERHR,
	5.824  BIX_PMV_TOTAL8,
	56     BIX_EMC_ONE_DONE,
	54.5   BIX_PMV_TOTAL9,
	15     BIX_EMC_TRANRATIO,
	7      BIX_PMV_TOTAL10,
	0.7    BIX_EMC_DELRATIO,
	-0.3   BIX_PMV_TOTAL11,
	357    BIX_EMC_CUST_COUNT,
	317.73 BIX_PMV_TOTAL12,
	44250  BIX_EMC_SR,
	40267.5 BIX_PMV_TOTAL13,
	3.2     BIX_EMC_COSTPERMSG,
	2.88    BIX_PMV_TOTAL14,
	110000  BIX_EMC_LABOR_COST,
	101750  BIX_PMV_TOTAL15
	FROM DUAL';
*/

 BEGIN
 IF (FND_PROFILE.DEFINED('BIX_EMAIL_GOAL')) THEN
    l_cust_resp_time_goal := TO_NUMBER(FND_PROFILE.VALUE('BIX_EMAIL_GOAL'));
 END IF;

 IF l_cust_resp_time_goal IS NULL THEN
    l_cust_resp_time_goal := 0;
 END IF;
 EXCEPTION
 WHEN OTHERS THEN
 l_cust_resp_time_goal := 0;
 END;

 BEGIN
 IF (FND_PROFILE.DEFINED('BIX_EMAIL_SLVL_GOAL')) THEN
    l_service_level_goal := ROUND(TO_NUMBER(FND_PROFILE.VALUE('BIX_EMAIL_SLVL_GOAL')),1);
 END IF;

 IF l_service_level_goal IS NULL THEN
    l_service_level_goal := 0;
 END IF;

 EXCEPTION
 WHEN OTHERS THEN
  l_service_level_goal := 0;
 END;

 --
 --Retrieve the dummy (unidentified) customer id which is used by EMC
 --
 IF (FND_PROFILE.DEFINED('IEM_DEFAULT_CUSTOMER_ID')) THEN
   l_dummy_cust := TO_NUMBER(FND_PROFILE.VALUE('IEM_DEFAULT_CUSTOMER_ID'));
 END IF;

 IF l_dummy_cust IS NULL THEN
    l_dummy_cust := -1;
 END IF;

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


   l_sqltext :=
  'SELECT
    ROUND(SUM(curr_slvl) * 100,1) BIX_EMC_SVCLVL,
    ROUND(SUM(prev_slvl) * 100,1) BIX_PMV_TOTAL1,
    ' || l_service_level_goal || ' BIX_EMC_GOAL,'||  l_service_level_goal || ' BIX_PMV_TOTAL2,
    ROUND(SUM(curr_avg_resp_time)/3600,1) BIX_EMC_CRTIME,
    ROUND(SUM(prev_avg_resp_time)/3600,1) BIX_PMV_TOTAL3,
    ' || l_cust_resp_time_goal || ' BIX_EMC_MSGSGOAL,'||  l_cust_resp_time_goal || ' BIX_PMV_TOTAL4,
    NVL(SUM(curr_received),0) BIX_EMC_RCVD,
    SUM(prev_received)  BIX_PMV_TOTAL5,
    SUM(NVL(curr_replied,0)+ NVL(curr_auto_replied,0)) BIX_EMC_REPLD,
    SUM(NVL(prev_replied,0)+ NVL(prev_auto_replied,0)) BIX_PMV_TOTAL6,
    NVL(SUM(curr_backlog),0) BIX_EMC_BACKLOG,
    DECODE(SUM(prev_backlog),0,NULL,SUM(prev_backlog)) BIX_PMV_TOTAL7,
    ROUND(NVL(SUM(curr_replied),0)/sum(CURR_LOGIN_TIME_IN_PERIOD),1) BIX_EMC_REPPERHR,
    ROUND(SUM(prev_replied)/ sum(PREV_LOGIN_TIME_IN_PERIOD),1) BIX_PMV_TOTAL8,
    ROUND(SUM(curr_one_done)*100,1) BIX_EMC_ONE_DONE,
    ROUND(SUM(prev_one_done)*100,1) BIX_PMV_TOTAL9,
    ROUND(NVL(SUM(curr_transferred),0)/ DECODE(SUM(NVL(curr_deleted,0) + NVL(curr_replied,0)),0,NULL,
		   SUM(NVL(curr_deleted,0) + NVL(curr_replied,0)))*100,1) BIX_EMC_TRANRATIO,
    ROUND(SUM(prev_transferred)/ DECODE(SUM(NVL(prev_deleted,0) + NVL(prev_replied,0)),0,NULL,
		   SUM(NVL(prev_deleted,0) + NVL(prev_replied,0)))*100,1) BIX_PMV_TOTAL10,
    ROUND((NVL(SUM(curr_deleted),0)+NVL(SUM(curr_auto_deleted),0))/
           DECODE(SUM(curr_completed) ,0,NULL,SUM(curr_completed))*100,1) BIX_EMC_DELRATIO,
    ROUND((NVL(SUM(prev_deleted),0)+NVL(SUM(prev_auto_deleted),0))/
          DECODE(SUM(prev_completed) ,0,NULL,SUM(prev_completed))*100,1) BIX_PMV_TOTAL11,
    NVL(SUM(curr_customer_count),0) BIX_EMC_CUST_COUNT,
    DECODE(SUM(prev_customer_count),0,NULL,SUM(prev_customer_count)) BIX_PMV_TOTAL12,
    NVL(SUM(curr_sr_created),0) BIX_EMC_SR,
    SUM(prev_sr_created) BIX_PMV_TOTAL13,
    NVL(SUM(curr_composed),0) BIX_EMC_COMPOSED,
    SUM(prev_composed) BIX_PMV_TOTAL14,
    NVL(SUM(curr_leads),0) BIX_EMC_LEADS,
    SUM(prev_leads) BIX_PMV_TOTAL15
  FROM
  (
     SELECT
           NVL(SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_RPLD_BY_GOAL_IN_PERIOD)),0)/
           SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,
		  DECODE(NVL(EMAILS_REPLIED_IN_PERIOD,0) + NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0),0,NULL,
		         NVL(EMAILS_REPLIED_IN_PERIOD,0) + NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0) )
		  )) curr_slvl,
           NVL(SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_RPLD_BY_GOAL_IN_PERIOD)),0)/
           SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,
		  DECODE(NVL(EMAILS_REPLIED_IN_PERIOD,0) + NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0),0,NULL,
		         NVL(EMAILS_REPLIED_IN_PERIOD,0) + NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0) )
		  )) prev_slvl,
           NVL(SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAIL_RESP_TIME_IN_PERIOD)),0)/
           SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,
		  DECODE(NVL(EMAILS_REPLIED_IN_PERIOD,0) + NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0),0,NULL,
		                     NVL(EMAILS_REPLIED_IN_PERIOD,0) + NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0) ))) curr_avg_resp_time,
           NVL(SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAIL_RESP_TIME_IN_PERIOD)),0)/
           SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,
		  DECODE(NVL(EMAILS_REPLIED_IN_PERIOD,0) + NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0),0,NULL,
		                     NVL(EMAILS_REPLIED_IN_PERIOD,0) + NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0) ))) prev_avg_resp_time,
           SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_OFFERED_IN_PERIOD)) curr_received,
           SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_OFFERED_IN_PERIOD)) prev_received,
           SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_REPLIED_IN_PERIOD)) curr_replied,
           SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_REPLIED_IN_PERIOD)) prev_replied,
           SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_AUTO_REPLIED_IN_PERIOD)) curr_auto_replied,
           SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_AUTO_REPLIED_IN_PERIOD)) prev_auto_replied,
           NVL(SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,ONE_RSLN_IN_PERIOD)),0)/
           SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,INTERACTION_THREADS_IN_PERIOD))  curr_one_done,
           SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,ONE_RSLN_IN_PERIOD))/
           SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,INTERACTION_THREADS_IN_PERIOD))  prev_one_done,
           SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_RSL_AND_TRFD_IN_PERIOD)) curr_transferred,
           SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_RSL_AND_TRFD_IN_PERIOD)) prev_transferred,
           SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_DELETED_IN_PERIOD)) curr_deleted,
           SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_DELETED_IN_PERIOD)) prev_deleted,
           SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_AUTO_DELETED_IN_PERIOD)) curr_auto_deleted,
           SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_AUTO_DELETED_IN_PERIOD)) prev_auto_deleted,
           SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,NVL(EMAILS_REPLIED_IN_PERIOD,0) +
                NVL(EMAILS_DELETED_IN_PERIOD,0) + NVL(EMAILS_AUTO_UPTD_SR_IN_PERIOD,0) +
			 NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0) + NVL(EMAILS_AUTO_DELETED_IN_PERIOD,0) +
			 NVL(EMAILS_AUTO_RESOLVED_IN_PERIOD,0))) curr_completed,
           SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,NVL(EMAILS_REPLIED_IN_PERIOD,0) +
                NVL(EMAILS_DELETED_IN_PERIOD,0) + NVL(EMAILS_AUTO_UPTD_SR_IN_PERIOD,0) +
			 NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0) + NVL(EMAILS_AUTO_DELETED_IN_PERIOD,0) +
			 NVL(EMAILS_AUTO_RESOLVED_IN_PERIOD,0))) prev_completed,
           COUNT(DISTINCT(CASE WHEN calendar.report_date = &BIS_CURRENT_ASOF_DATE
						 AND fact.party_id <> -1
						 AND fact.party_id <> ' || l_dummy_cust ||
               ' THEN fact.PARTY_ID END )) curr_customer_count,
           COUNT(DISTINCT(CASE WHEN calendar.report_date = &BIS_PREVIOUS_ASOF_DATE
						 AND fact.party_id <> -1
						 AND fact.party_id <> ' || l_dummy_cust ||
               ' THEN fact.PARTY_ID END )) prev_customer_count,
           SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,SR_CREATED_IN_PERIOD)) curr_sr_created,
           SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,SR_CREATED_IN_PERIOD)) prev_sr_created,
		 SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_COMPOSED_IN_PERIOD)) curr_composed,
		 SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_COMPOSED_IN_PERIOD)) prev_composed,
           SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,LEADS_CREATED_IN_PERIOD)) curr_leads,
           SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,LEADS_CREATED_IN_PERIOD)) prev_leads
     FROM bix_email_details_mv fact,
          fii_time_rpt_struct calendar
        WHERE fact.time_id = calendar.time_id
	   AND   fact.row_type = :l_row_type
        AND fact.period_type_id = calendar.period_type_id
        AND calendar.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
        AND bitand(calendar.record_type_id,&BIS_NESTED_PATTERN ) =  calendar.record_type_id ';
 l_sqltext := l_sqltext || l_where_clause || ' ),
       (
         SELECT
         SUM(DECODE(period_start_date,:l_max_collect_date,
               NVL(ACCUMULATED_OPEN_EMAILS,0) + NVL(ACCUMULATED_EMAILS_IN_QUEUE,0) )) curr_backlog,
         SUM(DECODE(period_start_date,&BIS_PREVIOUS_ASOF_DATE,
                NVL(ACCUMULATED_OPEN_EMAILS,0) + NVL(ACCUMULATED_EMAILS_IN_QUEUE,0) )) prev_backlog
         FROM   bix_email_details_mv
	    WHERE  time_id IN (TO_CHAR(:l_max_collect_date,''J''),TO_CHAR(&BIS_PREVIOUS_ASOF_DATE,''J''))
	    ANd    row_type = :l_row_type
         AND   period_type_id = :l_period_type_id ';
 l_sqltext := l_sqltext || l_where_clause || ' ),
   (
    SELECT
      SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,LOGIN_TIME))/3600 CURR_LOGIN_TIME_IN_PERIOD,
      SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,LOGIN_TIME))/3600 PREV_LOGIN_TIME_IN_PERIOD
      FROM   bix_agent_session_f fact,
          fii_time_rpt_struct calendar
        WHERE fact.application_id = :l_application_id
        AND fact.time_id = calendar.time_id
        AND fact.period_type_id = calendar.period_type_id
        AND calendar.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
       AND bitand(calendar.record_type_id,&BIS_NESTED_PATTERN) =  calendar.record_type_id
	  ) ';


p_sql_text := l_sqltext;


l_custom_rec.attribute_name := ':l_period_type_id' ;
l_custom_rec.attribute_value:= l_period_type_id;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;

l_custom_rec.attribute_name := ':l_max_collect_date' ;
l_custom_rec.attribute_value:= l_max_collect_date;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;


l_custom_rec.attribute_name := ':l_application_id';
l_custom_rec.attribute_value:= l_application_id;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;

p_custom_output.EXTEND;
p_custom_output(p_custom_output.COUNT) := l_custom_rec;

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
END  BIX_PMV_EMC_KPI_PRTLT_PKG;

/
