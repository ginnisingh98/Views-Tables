--------------------------------------------------------
--  DDL for Package Body BIX_PMV_EMC_BACK_ACT_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_EMC_BACK_ACT_RPT_PKG" AS
/*$Header: bixebacr.plb 120.1 2006/05/11 02:15:47 pubalasu noship $ */

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

/*
 l_sqltext :=  '
SELECT
''marketing@oracle.com'' VIEWBY,
10 BIX_EMC_BACKLOG,
20 BIX_EMC_BACKCHANGE,
30 BIX_EMC_AGT_HR_EQ,
40 BIX_EMC_COST_EQ,
50 BIX_EMC_0_1_DAY,
60 BIX_EMC_0_1_DAY_CHANGE,
70 BIX_EMC_2_3_DAY,
80 BIX_EMC_2_3_DAY_CHANGE,
90 BIX_EMC_4_7_DAY,
100 BIX_EMC_4_7_DAY_CHANGE,
110 BIX_EMC_OVER_7_DAY,
120 BIX_EMC_OVER_7_DAY_CHANGE,
130 BIX_PMV_TOTAL1,
140 BIX_PMV_TOTAL2,
150 BIX_PMV_TOTAL3,
160 BIX_PMV_TOTAL4,
170 BIX_PMV_TOTAL5,
180 BIX_PMV_TOTAL6,
190 BIX_PMV_TOTAL7,
200 BIX_PMV_TOTAL8,
210 BIX_PMV_TOTAL9,
220 BIX_PMV_TOTAL10,
230 BIX_PMV_TOTAL11,
240 BIX_PMV_TOTAL12
FROM DUAL';

p_sql_text := l_sqltext;
*/

   l_sqltext :=
  '
  SELECT * FROM (
  SELECT
    lookup_table.value VIEWBY,
    lookup_table.id    VIEWBYID,
    SUM(curr_backlog)  BIX_EMC_BACKLOG_CP,
    (NVL(SUM(curr_backlog),0) -SUM(prev_backlog))/
           DECODE(SUM(prev_backlog),0,NULL,SUM(prev_backlog)) * 100 BIX_EMC_BACKCHANGE,
    SUM(prev_backlog) BIX_EMC_PREVBACKLOG,
    SUM(curr_backlog)/(SUM(total_emails_replied)/SUM(total_login_hours)) BIX_EMC_AGT_HR_EQ,
    NVL(SUM(curr_one_day),0)/DECODE(SUM(curr_backlog),0,NULL,SUM(curr_backlog))*100 BIX_EMC_0_1_DAY_CP,
    (NVL(SUM(curr_one_day),0)/DECODE(SUM(curr_backlog),0,NULL,SUM(curr_backlog)) -
           NVL(SUM(prev_one_day),0)/DECODE(SUM(prev_backlog),0,NULL,SUM(prev_backlog))) * 100 BIX_EMC_0_1_DAY_CHANGE,
    NVL(SUM(curr_three_day),0)/DECODE(SUM(curr_backlog),0,NULL,SUM(curr_backlog))*100 BIX_EMC_2_3_DAY_CP,
    (NVL(SUM(curr_three_day),0)/DECODE(SUM(curr_backlog),0,NULL,SUM(curr_backlog)) -
           NVL(SUM(prev_three_day),0)/DECODE(SUM(prev_backlog),0,NULL,SUM(prev_backlog))) * 100 BIX_EMC_2_3_DAY_CHANGE,
    NVL(SUM(curr_week),0)/DECODE(SUM(curr_backlog),0,NULL,SUM(curr_backlog))*100 BIX_EMC_4_7_DAY_CP,
    (NVL(SUM(curr_week),0)/DECODE(SUM(curr_backlog),0,NULL,SUM(curr_backlog)) -
           NVL(SUM(prev_week),0)/DECODE(SUM(prev_backlog),0,NULL,SUM(prev_backlog))) * 100 BIX_EMC_4_7_DAY_CHANGE,
    NVL(SUM(curr_week_plus),0)/DECODE(SUM(curr_backlog),0,NULL,SUM(curr_backlog))*100 BIX_EMC_OVER_7_DAY_CP,
    (NVL(SUM(curr_week_plus),0)/DECODE(SUM(curr_backlog),0,NULL,SUM(curr_backlog)) -
           NVL(SUM(prev_week_plus),0)/DECODE(SUM(prev_backlog),0,NULL,SUM(prev_backlog))) * 100 BIX_EMC_OVER_7_DAY_CHANGE,
    SUM(SUM(curr_backlog)) OVER() BIX_PMV_TOTAL1,
    (NVL(SUM(SUM(curr_backlog)) OVER(),0) - SUM(SUM(prev_backlog)) OVER())/
           DECODE(SUM(SUM(prev_backlog)) OVER(),0,NULL,SUM(SUM(prev_backlog)) OVER()) * 100 BIX_PMV_TOTAL2,
    SUM(SUM(curr_backlog)) OVER()/(SUM(SUM(total_emails_replied)) OVER()/SUM(SUM(total_login_hours)) OVER()) BIX_PMV_TOTAL3,
    NVL(SUM(SUM(curr_one_day)) OVER(),0)/DECODE(SUM(SUM(curr_backlog))  OVER(),0,NULL,SUM(SUM(curr_backlog)) OVER())*100 BIX_PMV_TOTAL5,
    (NVL(SUM(SUM(curr_one_day)) OVER(),0)/DECODE(SUM(SUM(curr_backlog)) OVER(),0,NULL,SUM(SUM(curr_backlog)) OVER()) -
           NVL(SUM(SUM(prev_one_day)) OVER(),0)/DECODE(SUM(SUM(prev_backlog)) OVER(),0,NULL,SUM(SUM(prev_backlog)) OVER())) * 100 BIX_PMV_TOTAL6,
    NVL(SUM(SUM(curr_three_day)) OVER(),0)/DECODE(SUM(SUM(curr_backlog)) OVER(),0,NULL,SUM(SUM(curr_backlog)) OVER())*100 BIX_PMV_TOTAL7,
    (NVL(SUM(SUM(curr_three_day)) OVER(),0)/DECODE(SUM(SUM(curr_backlog)) OVER(),0,NULL,SUM(SUM(curr_backlog)) OVER()) -
           NVL(SUM(SUM(prev_three_day)) OVER(),0)/DECODE(SUM(SUM(prev_backlog)) OVER(),0,NULL,SUM(SUM(prev_backlog)) OVER())) * 100 BIX_PMV_TOTAL8,
    NVL(SUM(SUM(curr_week)) OVER(),0)/DECODE(SUM(SUM(curr_backlog)) OVER(),0,NULL,SUM(SUM(curr_backlog)) OVER())*100 BIX_PMV_TOTAL9,
    (NVL(SUM(SUM(curr_week)) OVER(),0)/DECODE(SUM(SUM(curr_backlog)) OVER(),0,NULL,SUM(SUM(curr_backlog)) OVER()) -
           NVL(SUM(SUM(prev_week)) OVER(),0)/DECODE(SUM(SUM(prev_backlog)) OVER(),0,NULL,SUM(SUM(prev_backlog)) OVER())) * 100 BIX_PMV_TOTAL10,
    NVL(SUM(SUM(curr_week_plus)) OVER(),0)/DECODE(SUM(SUM(curr_backlog)) OVER(),0,NULL,SUM(SUM(curr_backlog)) OVER())*100 BIX_PMV_TOTAL11,
    (NVL(SUM(SUM(curr_week_plus)) OVER(),0)/DECODE(SUM(SUM(curr_backlog)) OVER(),0,NULL,SUM(SUM(curr_backlog)) OVER()) -
           NVL(SUM(SUM(prev_week_plus)) OVER(),0)/DECODE(SUM(SUM(prev_backlog)) OVER(),0,NULL,SUM(SUM(prev_backlog)) OVER())) * 100 BIX_PMV_TOTAL12
  FROM
  ( ';

  IF l_view_by = 'EMAIL ACCOUNT+EMAIL ACCOUNT' THEN
  l_sqltext := l_sqltext || '  SELECT
   email_account_id id,
   SUM(DECODE(period_start_date,:l_max_collect_date,
        NVL(ACCUMULATED_OPEN_EMAILS,0) + NVL(ACCUMULATED_EMAILS_IN_QUEUE,0) )) curr_backlog,
   SUM(DECODE(period_start_date,&BIS_PREVIOUS_ASOF_DATE,
       NVL(ACCUMULATED_OPEN_EMAILS,0) + NVL(ACCUMULATED_EMAILS_IN_QUEUE,0) )) prev_backlog,
   NVL(SUM(DECODE(period_start_date,:l_max_collect_date,ACCUMULATED_EMAILS_ONE_DAY)),0) curr_one_day,
   SUM(DECODE(period_start_date,&BIS_PREVIOUS_ASOF_DATE,ACCUMULATED_EMAILS_ONE_DAY)) prev_one_day,
   NVL(SUM(DECODE(period_start_date,:l_max_collect_date,ACCUMULATED_EMAILS_THREE_DAYS)),0) curr_three_day,
   SUM(DECODE(period_start_date,&BIS_PREVIOUS_ASOF_DATE,ACCUMULATED_EMAILS_THREE_DAYS)) prev_three_day,
   NVL(SUM(DECODE(period_start_date,:l_max_collect_date,ACCUMULATED_EMAILS_WEEK)),0) curr_week,
   SUM(DECODE(period_start_date,&BIS_PREVIOUS_ASOF_DATE,ACCUMULATED_EMAILS_WEEK)) prev_week,
   NVL(SUM(DECODE(period_start_date,:l_max_collect_date,ACCUMULATED_EMAILS_WEEK_PLUS)),0) curr_week_plus,
   SUM(DECODE(period_start_date,&BIS_PREVIOUS_ASOF_DATE,ACCUMULATED_EMAILS_WEEK_PLUS)) prev_week_plus
   FROM   bix_email_details_mv
   WHERE  time_id IN (TO_CHAR(:l_max_collect_date,''J''),TO_CHAR(&BIS_PREVIOUS_ASOF_DATE,''J''))
   AND    row_type = :l_row_type
   AND   period_type_id = :l_period_type_id ' || l_where_clause || '
   GROUP BY email_account_id
   ) fact, ';
  ELSE
  l_sqltext := l_sqltext || '  SELECT
   email_classification_id id,
   SUM(DECODE(period_start_date,:l_max_collect_date,
        NVL(ACCUMULATED_OPEN_EMAILS,0) + NVL(ACCUMULATED_EMAILS_IN_QUEUE,0) )) curr_backlog,
   SUM(DECODE(period_start_date,&BIS_PREVIOUS_ASOF_DATE,
       NVL(ACCUMULATED_OPEN_EMAILS,0) + NVL(ACCUMULATED_EMAILS_IN_QUEUE,0) )) prev_backlog,
   NVL(SUM(DECODE(period_start_date,:l_max_collect_date,ACCUMULATED_EMAILS_ONE_DAY)),0) curr_one_day,
   SUM(DECODE(period_start_date,&BIS_PREVIOUS_ASOF_DATE,ACCUMULATED_EMAILS_ONE_DAY)) prev_one_day,
   NVL(SUM(DECODE(period_start_date,:l_max_collect_date,ACCUMULATED_EMAILS_THREE_DAYS)),0) curr_three_day,
   SUM(DECODE(period_start_date,&BIS_PREVIOUS_ASOF_DATE,ACCUMULATED_EMAILS_THREE_DAYS)) prev_three_day,
   NVL(SUM(DECODE(period_start_date,:l_max_collect_date,ACCUMULATED_EMAILS_WEEK)),0) curr_week,
   SUM(DECODE(period_start_date,&BIS_PREVIOUS_ASOF_DATE,ACCUMULATED_EMAILS_WEEK)) prev_week,
   NVL(SUM(DECODE(period_start_date,:l_max_collect_date,ACCUMULATED_EMAILS_WEEK_PLUS)),0) curr_week_plus,
   SUM(DECODE(period_start_date,&BIS_PREVIOUS_ASOF_DATE,ACCUMULATED_EMAILS_WEEK_PLUS)) prev_week_plus
   FROM   bix_email_details_mv
   WHERE  time_id IN (TO_CHAR(:l_max_collect_date,''J''),TO_CHAR(&BIS_PREVIOUS_ASOF_DATE,''J''))
   AND    row_type = :l_row_type
   AND   period_type_id = :l_period_type_id ' || l_where_clause || '
   GROUP BY email_classification_id
   ) fact, ';
  END IF;

  l_sqltext := l_sqltext || '  (
      SELECT SUM(EMAILS_REPLIED_IN_PERIOD) total_emails_replied
      FROM bix_email_details_mv fact,
           fii_time_rpt_struct calendar
      WHERE fact.time_id = calendar.time_id
      AND fact.period_type_id = calendar.period_type_id
      AND calendar.report_date = &BIS_CURRENT_ASOF_DATE
	 AND fact.row_type = :l_row_type
      AND bitand(calendar.record_type_id,&BIS_NESTED_PATTERN ) =  calendar.record_type_id
     ),
    (
      SELECT SUM(LOGIN_TIME)/3600 total_login_hours
      FROM bix_agent_session_f fact,
           fii_time_rpt_struct calendar
      WHERE fact.application_id = :l_application_id
      AND  fact.time_id = calendar.time_id
      AND fact.period_type_id = calendar.period_type_id
      AND calendar.report_date = &BIS_CURRENT_ASOF_DATE
      AND bitand(calendar.record_type_id,&BIS_NESTED_PATTERN ) =  calendar.record_type_id
     ), ';


	IF l_view_by = 'EMAIL ACCOUNT+EMAIL ACCOUNT' THEN
	l_sqltext := l_sqltext || ' bix_email_accounts_v lookup_table ';
	ELSE
	l_sqltext := l_sqltext || ' bix_email_classifications_v lookup_table ';
	END IF;


     l_sqltext := l_sqltext || ' WHERE fact.id = lookup_table.id
     GROUP BY lookup_table.value,lookup_table.id
	)
     where
	(
	nvl(BIX_EMC_PREVBACKLOG,0)+
	nvl(BIX_EMC_BACKLOG_CP,0)+
	abs(nvl(BIX_EMC_BACKCHANGE,0))+
	nvl(BIX_EMC_AGT_HR_EQ,0)+
	nvl(BIX_EMC_0_1_DAY_CP,0)+
	abs(nvl(BIX_EMC_0_1_DAY_CHANGE,0))+
	nvl(BIX_EMC_2_3_DAY_CP,0)+
	abs(nvl(BIX_EMC_2_3_DAY_CHANGE,0))+
	nvl(BIX_EMC_4_7_DAY_CP,0)+
	abs(nvl(BIX_EMC_4_7_DAY_CHANGE,0))+
	nvl(BIX_EMC_OVER_7_DAY_CP,0)+
	abs(nvl(BIX_EMC_OVER_7_DAY_CHANGE,0))
	) <> 0
	&ORDER_BY_CLAUSE ';

p_sql_text := l_sqltext;


-- insert Period Type ID bind variable

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
END  BIX_PMV_EMC_BACK_ACT_RPT_PKG;

/
