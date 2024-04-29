--------------------------------------------------------
--  DDL for Package Body BIX_PMV_EMC_RESOLV_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_EMC_RESOLV_RPT_PKG" AS
/*$Header: bixeresb.plb 120.0 2005/05/25 17:22:28 appldev noship $ */

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
l_row_type    varchar2(10) := 'AC';

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

/*
l_sqltext := '
SELECT
''test@oracle.com'' VIEWBY,
10 BIX_EMC_COMPLETED,
20 BIX_EMC_COMPCHANGE,
30 BIX_EMC_REPLD,
40 BIX_EMC_REPCHANGE,
50 BIX_EMC_DELETED,
60 BIX_EMC_DELCHANGE,
70 BIX_EMC_AUTOREPLD,
80 BIX_EMC_AUTOREPLD_CHANGE,
90  BIX_EMC_AUTODELETED,
100 BIX_EMC_AUTODELETED_CHANGE,
10 BIX_EMC_AUTORESOLV,
20 BIX_EMC_AUTORESOLV_CHANGE,
30 BIX_EMC_AUTOUPDATESR,
40 BIX_EMC_AUTOUPDATESR_CHANGE,
10 BIX_PMV_TOTAL3,
20 BIX_PMV_TOTAL4,
30 BIX_PMV_TOTAL5,
40 BIX_PMV_TOTAL6,
50 BIX_PMV_TOTAL7,
60 BIX_PMV_TOTAL8,
70 BIX_PMV_TOTAL9,
80 BIX_PMV_TOTAL10,
90 BIX_PMV_TOTAL11,
100 BIX_PMV_TOTAL12,
10 BIX_PMV_TOTAL13,
20 BIX_PMV_TOTAL14,
30 BIX_PMV_TOTAL15,
40 BIX_PMV_TOTAL16,
1000 BIX_EMC_AUTORESPONSE,
2000 BIX_EMC_RESPONSE
FROM DUAL';

p_sql_text := l_sqltext;
*/

   l_sqltext :=
  '
  SELECT * FROM
  (
  SELECT
    lookup_table.value VIEWBY,
    lookup_table.id    VIEWBYID,
    NVL(SUM(curr_completed),0) BIX_EMC_COMPLETED_CP,
    (NVL(SUM(curr_completed),0) - DECODE(SUM(prev_completed),0,NULL,SUM(prev_completed)))
    / DECODE(SUM(prev_completed),0,NULL,SUM(prev_completed)) * 100 BIX_EMC_COMPCHANGE,
    NVL(SUM(curr_replied),0) BIX_EMC_REPLD,
    (NVL(SUM(curr_replied),0) - SUM(prev_replied)) / SUM(prev_replied) * 100 BIX_EMC_REPCHANGE,
    NVL(SUM(curr_deleted),0) BIX_EMC_DELETED,
    (NVL(SUM(curr_deleted),0) - SUM(prev_deleted)) / SUM(prev_deleted) * 100 BIX_EMC_DELCHANGE,
    NVL(SUM(curr_auto_replied),0) BIX_EMC_AUTOREPLD,
    (NVL(SUM(curr_auto_replied),0) - SUM(prev_auto_replied)) / SUM(prev_auto_replied) * 100 BIX_EMC_AUTOREPLD_CHANGE,
    NVL(SUM(curr_auto_deleted),0) BIX_EMC_AUTODELETED,
    (NVL(SUM(curr_auto_deleted),0) - SUM(prev_auto_deleted)) / SUM(prev_auto_deleted) * 100 BIX_EMC_AUTODELETED_CHANGE,
    NVL(SUM(curr_auto_resolv),0) BIX_EMC_AUTORESOLV,
    (NVL(SUM(curr_auto_resolv),0) - SUM(prev_auto_resolv)) / SUM(prev_auto_resolv) * 100 BIX_EMC_AUTORESOLV_CHANGE,
    NVL(SUM(curr_auto_sr),0) BIX_EMC_AUTOUPDATESR,
    (NVL(SUM(curr_auto_sr),0) - SUM(prev_auto_sr)) / SUM(prev_auto_sr) * 100 BIX_EMC_AUTOUPDATESR_CHANGE,
    NVL(SUM(curr_replied),0) +  NVL(SUM(curr_deleted),0)  BIX_EMC_RESPONSE,
    NVL(SUM(curr_auto_replied),0) +  NVL(SUM(curr_auto_deleted),0) +
    NVL(SUM(curr_auto_sr),0) + NVL(SUM(curr_auto_resolv),0)    BIX_EMC_AUTORESPONSE,
    NVL(SUM(SUM(curr_completed)) OVER(),0) BIX_PMV_TOTAL3,
    (NVL(SUM(SUM(curr_completed)) OVER(),0) - DECODE(SUM(SUM(prev_completed)) OVER(),0,NULL,SUM(SUM(prev_completed)) OVER() ))
    / DECODE(SUM(SUM(prev_completed)) OVER(),0,NULL,SUM(SUM(prev_completed)) OVER()) * 100 BIX_PMV_TOTAL4,
    NVL(SUM(SUM(curr_replied)) OVER(),0) BIX_PMV_TOTAL5,
    (NVL(SUM(SUM(curr_replied)) OVER(),0) - SUM(SUM(prev_replied)) OVER()) / SUM(SUM(prev_replied)) OVER() * 100 BIX_PMV_TOTAL6,
    NVL(SUM(SUM(curr_deleted)) OVER(),0) BIX_PMV_TOTAL7,
    (NVL(SUM(SUM(curr_deleted)) OVER(),0) - SUM(SUM(prev_deleted)) OVER()) / SUM(SUM(prev_deleted)) OVER() * 100 BIX_PMV_TOTAL8,
    NVL(SUM(SUM(curr_auto_replied)) OVER(),0) BIX_PMV_TOTAL9,
    (NVL(SUM(SUM(curr_auto_replied)) OVER(),0) - SUM(SUM(prev_auto_replied)) OVER()) / SUM(SUM(prev_auto_replied)) OVER() * 100 BIX_PMV_TOTAL10,
    NVL(SUM(SUM(curr_auto_deleted)) OVER() ,0) BIX_PMV_TOTAL11,
    (NVL(SUM(SUM(curr_auto_deleted)) OVER(),0) - SUM(SUM(prev_auto_deleted)) OVER()) / SUM(SUM(prev_auto_deleted)) OVER() * 100 BIX_PMV_TOTAL12,
    NVL(SUM(SUM(curr_auto_resolv)) OVER(),0) BIX_PMV_TOTAL13,
    (NVL(SUM(SUM(curr_auto_resolv)) OVER(),0) - SUM(SUM(prev_auto_resolv)) OVER()) / SUM(SUM(prev_auto_resolv)) OVER() * 100 BIX_PMV_TOTAL14,
    NVL(SUM(SUM(curr_auto_sr)) OVER(),0) BIX_PMV_TOTAL15,
    (NVL(SUM(SUM(curr_auto_sr)) OVER(),0) - SUM(SUM(prev_auto_sr)) OVER()) / SUM(SUM(prev_auto_sr)) OVER() * 100 BIX_PMV_TOTAL16,
    NVL(SUM(SUM(curr_replied)) OVER(),0) +  NVL(SUM(SUM(curr_deleted)) OVER(),0)  BIX_CALC_ITEM33,--001
    NVL(SUM(SUM(curr_auto_replied)) OVER(),0) +  NVL(SUM(SUM(curr_auto_deleted)) OVER(),0) +
    NVL(SUM(SUM(curr_auto_sr)) OVER(),0) + NVL(SUM(SUM(curr_auto_resolv)) OVER(),0)    BIX_CALC_ITEM34 --001
  FROM
  ( ';

  IF l_view_by = 'EMAIL ACCOUNT+EMAIL ACCOUNT' THEN
    l_sqltext := l_sqltext || ' SELECT
     email_account_id id,
     SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,
                NVL(EMAILS_REPLIED_IN_PERIOD,0) +
                NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0) +
                NVL(EMAILS_DELETED_IN_PERIOD,0) +
                NVL(EMAILS_AUTO_DELETED_IN_PERIOD,0)+
                NVL(EMAILS_AUTO_UPTD_SR_IN_PERIOD,0)+
                NVL(EMAILS_AUTO_RESOLVED_IN_PERIOD,0)
                )) curr_completed,
     SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,
                NVL(EMAILS_REPLIED_IN_PERIOD,0) +
                NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0) +
                NVL(EMAILS_DELETED_IN_PERIOD,0) +
                NVL(EMAILS_AUTO_DELETED_IN_PERIOD,0)+
                NVL(EMAILS_AUTO_UPTD_SR_IN_PERIOD,0)+
                NVL(EMAILS_AUTO_RESOLVED_IN_PERIOD,0)
                )) prev_completed,
     SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_REPLIED_IN_PERIOD)) curr_replied,
     SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_REPLIED_IN_PERIOD)) prev_replied,
     SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_DELETED_IN_PERIOD)) curr_deleted,
     SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_DELETED_IN_PERIOD)) prev_deleted,
     SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_AUTO_REPLIED_IN_PERIOD)) curr_auto_replied,
     SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_AUTO_REPLIED_IN_PERIOD)) prev_auto_replied,
     SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_AUTO_DELETED_IN_PERIOD)) curr_auto_deleted,
     SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_AUTO_DELETED_IN_PERIOD)) prev_auto_deleted,
     SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_AUTO_UPTD_SR_IN_PERIOD)) curr_auto_sr,
     SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_AUTO_UPTD_SR_IN_PERIOD)) prev_auto_sr,
     SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_AUTO_RESOLVED_IN_PERIOD)) curr_auto_resolv,
     SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_AUTO_RESOLVED_IN_PERIOD)) prev_auto_resolv
     FROM bix_email_details_mv fact,
          fii_time_rpt_struct calendar
        WHERE fact.time_id = calendar.time_id
	   AND   fact.row_type = :l_row_type
        AND fact.period_type_id = calendar.period_type_id
        AND calendar.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
        AND bitand(calendar.record_type_id,&BIS_NESTED_PATTERN ) =  calendar.record_type_id '
        || l_where_clause || '
     GROUP BY email_account_id
     ) fact, ';
	ELSE
    l_sqltext := l_sqltext || ' SELECT
     email_classification_id id,
     SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,
                NVL(EMAILS_REPLIED_IN_PERIOD,0) +
                NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0) +
                NVL(EMAILS_DELETED_IN_PERIOD,0) +
                NVL(EMAILS_AUTO_DELETED_IN_PERIOD,0)+
                NVL(EMAILS_AUTO_UPTD_SR_IN_PERIOD,0)+
                NVL(EMAILS_AUTO_RESOLVED_IN_PERIOD,0)
                )) curr_completed,
     SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,
                NVL(EMAILS_REPLIED_IN_PERIOD,0) +
                NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0) +
                NVL(EMAILS_DELETED_IN_PERIOD,0) +
                NVL(EMAILS_AUTO_DELETED_IN_PERIOD,0)+
                NVL(EMAILS_AUTO_UPTD_SR_IN_PERIOD,0)+
                NVL(EMAILS_AUTO_RESOLVED_IN_PERIOD,0)
                )) prev_completed,
     SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_REPLIED_IN_PERIOD)) curr_replied,
     SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_REPLIED_IN_PERIOD)) prev_replied,
     SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_DELETED_IN_PERIOD)) curr_deleted,
     SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_DELETED_IN_PERIOD)) prev_deleted,
     SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_AUTO_REPLIED_IN_PERIOD)) curr_auto_replied,
     SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_AUTO_REPLIED_IN_PERIOD)) prev_auto_replied,
     SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_AUTO_DELETED_IN_PERIOD)) curr_auto_deleted,
     SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_AUTO_DELETED_IN_PERIOD)) prev_auto_deleted,
     SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_AUTO_UPTD_SR_IN_PERIOD)) curr_auto_sr,
     SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_AUTO_UPTD_SR_IN_PERIOD)) prev_auto_sr,
     SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_AUTO_RESOLVED_IN_PERIOD)) curr_auto_resolv,
     SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_AUTO_RESOLVED_IN_PERIOD)) prev_auto_resolv
     FROM bix_email_details_mv fact,
          fii_time_rpt_struct calendar
        WHERE fact.time_id = calendar.time_id
	   AND   fact.row_type = :l_row_type
        AND fact.period_type_id = calendar.period_type_id
        AND calendar.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
        AND bitand(calendar.record_type_id,&BIS_NESTED_PATTERN ) =  calendar.record_type_id '
        || l_where_clause || '
     GROUP BY email_classification_id
     ) fact, ';
	END IF;

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
	nvl(BIX_EMC_COMPLETED_CP,0)+
	abs(nvl(BIX_EMC_COMPCHANGE,0))+
	nvl(BIX_EMC_RESPONSE,0)+
	nvl(BIX_EMC_AUTORESPONSE,0)+
	nvl(BIX_EMC_REPLD,0)+
	abs(nvl(BIX_EMC_REPCHANGE,0))+
	nvl(BIX_EMC_DELETED,0)+
	abs(nvl(BIX_EMC_DELCHANGE,0))+
	nvl(BIX_EMC_AUTOREPLD,0)+
	abs(nvl(BIX_EMC_AUTOREPLD_CHANGE,0))+
	nvl(BIX_EMC_AUTODELETED,0)+
	abs(nvl(BIX_EMC_AUTODELETED_CHANGE,0))+
	nvl(BIX_EMC_AUTORESOLV,0)+
	abs(nvl(BIX_EMC_AUTORESOLV_CHANGE,0))+
	nvl(BIX_EMC_AUTOUPDATESR,0)+
	abs(nvl(BIX_EMC_AUTOUPDATESR_CHANGE,0))
	)<> 0
	&ORDER_BY_CLAUSE ';

p_sql_text := l_sqltext;

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
END  BIX_PMV_EMC_RESOLV_RPT_PKG;

/
