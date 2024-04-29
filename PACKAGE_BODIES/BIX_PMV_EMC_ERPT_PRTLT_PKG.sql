--------------------------------------------------------
--  DDL for Package Body BIX_PMV_EMC_ERPT_PRTLT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_EMC_ERPT_PRTLT_PKG" AS
/*$Header: bixerptp.plb 120.0 2005/05/25 17:15:29 appldev noship $ */

PROCEDURE GET_SQL(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                  p_custom_sql         OUT NOCOPY VARCHAR2,
                  p_custom_output      OUT NOCOPY bis_query_attributes_TBL
                  )
AS
l_sqltext	      VARCHAR2(32000) ;
l_as_of_date   DATE;
l_period_type	varchar2(2000);
l_record_type_id NUMBER;
l_comp_type    varchar2(2000);
l_account      varchar2(32000);
l_sql_errm      varchar2(32000);
l_period_from   DATE;
l_period_to     DATE;
l_where_clause  varchar2(32000);
l_other_account VARCHAR2(1000);
l_start_date    DATE;
l_end_date      DATE;
l_max_collect_date VARCHAR2(30);
l_period_start_date DATE;
l_agent_cost NUMBER;
l_application_id NUMBER := 680;
l_classification VARCHAR2(32000);
l_view_by varchar2(1000);
l_row_type varchar2(10) := 'AC';

l_custom_rec BIS_QUERY_ATTRIBUTES := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;

BEGIN

/*IF (FND_PROFILE.DEFINED('BIX_DM_AGENT_COST')) THEN
   l_agent_cost := TO_NUMBER(FND_PROFILE.VALUE('BIX_DM_AGENT_COST'));
ELSE
   l_agent_cost := 0;
END IF;
*/
--
--Initialize p_custom_output
--
p_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

 bix_pmv_dbi_utl_pkg.get_emc_page_params (p_page_parameter_tbl,
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


 l_other_account := FND_MESSAGE.GET_STRING('BIX','BIX_PMV_ALLACCT');

 IF l_other_account IS NULL OR l_other_account = 'BIX_PMV_ALLACCT'
 THEN
	l_other_account := 'Others';
 END IF;


l_sqltext := '
SELECT DECODE(greatest(RANKING,10),10,account.value,:l_other_account)   BIX_EMC_ACCOUNT,
round(nvl(SUM(MSGSGOAL),0)*100/decode(SUM(TOT_REPLD),0,NULL,SUM(TOT_REPLD)),1)  BIX_EMC_MSGSGOAL,
nvl(SUM(SUM(MSGSGOAL)) over(),0)*100/
decode(SUM(SUM(TOT_REPLD)) over(),0,NULL,sum(SUM(TOT_REPLD)) over())            BIX_PMV_TOTAL1,
round(nvl(sum(AUTO_REPLD),0)*100/
 decode(SUM(TOT_REPLD),0,NULL,SUM(TOT_REPLD)),1)                           BIX_EMC_AUTO_RPLD_RATE,
round(nvl(sum(sum(AUTO_REPLD)) over(),0)*100/
 decode(SUM(SUM(TOT_REPLD)) OVER(),0,NULL,SUM(SUM(TOT_REPLD)) OVER()),1)   BIX_PMV_TOTAL6,
ROUND(NVL(SUM(TRFD),0)*100/DECODE(SUM(RESOLVED),0,NULL,SUM(RESOLVED)),1) BIX_EMC_TRANRATIO,
ROUND(NVL(SUM(SUM(TRFD)) OVER(),0)*100/
  DECODE(SUM(SUM(RESOLVED)) OVER(),0,NULL,SUM(SUM(RESOLVED)) OVER()),1)   BIX_PMV_TOTAL7,
round(nvl(sum(CRTIME),0)/(3600*decode(SUM(TOT_REPLD),0,NULL,SUM(TOT_REPLD))),1) BIX_EMC_CRTIME,
round(nvl(sum(sum(CRTIME)) over(),0)/
 (3600*decode(SUM(SUM(TOT_REPLD)) over(),0,NULL,SUM(SUM(TOT_REPLD)) over())),1) BIX_PMV_TOTAL3,
round(nvl(sum(ARTIME),0)/(3600*decode(SUM(REPLD),0,NULL,SUM(REPLD))),1) BIX_EMC_ARTIME,
round(nvl(SUM(SUM(ARTIME)) over(),0)/(3600*decode(
SUM(SUM(REPLD)) over(),0,NULL,SUM(SUM(REPLD)) over())),1)               BIX_PMV_TOTAL4,
nvl(SUM(ONEDONE),0)*100/decode(SUM(THREADS),0,NULL,SUM(THREADS))        BIX_EMC_ONE_DONE,
nvl(SUM(SUM(ONEDONE)) over(),0)*100/
decode(SUM(SUM(THREADS)) over(),0,NULL,SUM(SUM(THREADS)) over())        BIX_PMV_TOTAL5,
--Start 001.  Changes for adding columns for delete rate and its Grand Total
(NVL(SUM(curr_deleted),0)+ NVL(SUM(curr_auto_deleted),0))/ DECODE(SUM(curr_completed),0,NULL,SUM(curr_completed))*100 BIX_EMC_DELETE_RATE,
(NVL(SUM(SUM(curr_deleted)) OVER(),0) + NVL(SUM(SUM(curr_auto_deleted)) OVER(),0) )/
          DECODE(SUM(SUM(curr_completed)) OVER(),0,NULL,SUM(SUM(curr_completed)) OVER())*100 BIX_EMC_DELETE_TOTAL
--End 001.  Changes for adding columns for delete rate and its Grand Total
FROM (
       SELECT  email_account_id                             ACCOUNT_ID,
     	     sum(EMAILS_RPLD_BY_GOAL_IN_PERIOD)      MSGSGOAL,
	          sum(EMAILS_REPLIED_IN_PERIOD)           REPLD,
	          sum(EMAILS_AUTO_REPLIED_IN_PERIOD)      AUTO_REPLD,
			NVL(SUM(EMAILS_REPLIED_IN_PERIOD),0) + NVL(SUM(EMAILS_AUTO_REPLIED_IN_PERIOD),0) TOT_REPLD,
	          sum(EMAILS_RSL_AND_TRFD_IN_PERIOD)      TRFD,
	          NVL(SUM(EMAILS_REPLIED_IN_PERIOD),0) + NVL(SUM(EMAILS_DELETED_IN_PERIOD),0) RESOLVED,
               sum(EMAIL_RESP_TIME_IN_PERIOD)          CRTIME,
               sum(AGENT_RESP_TIME_IN_PERIOD)          ARTIME,
               sum(ONE_RSLN_IN_PERIOD)                 ONEDONE,
               sum(INTERACTION_THREADS_IN_PERIOD)      THREADS,
               sum(sum(EMAILS_REPLIED_IN_PERIOD)) over() TOTALREPLD,
               RANK() OVER (ORDER BY nvl(sum(EMAILS_RPLD_BY_GOAL_IN_PERIOD)/
						DECODE(NVL(sum(EMAILS_REPLIED_IN_PERIOD),0) + NVL(SUM(EMAILS_AUTO_REPLIED_IN_PERIOD),0),0,
						NULL,
						NVL(sum(EMAILS_REPLIED_IN_PERIOD),0) + NVL(SUM(EMAILS_AUTO_REPLIED_IN_PERIOD),0)),0) DESC,
                              account.value
                     )                                      RANKING,
--Start 001.  Changes for adding columns for delete rate and its Grand Total
SUM(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_DELETED_IN_PERIOD)) CURR_DELETED,
SUM(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_AUTO_DELETED_IN_PERIOD)) CURR_AUTO_DELETED,
NVL(EMAILS_REPLIED_IN_PERIOD,0) + NVL(EMAILS_DELETED_IN_PERIOD,0) + NVL(EMAILS_AUTO_UPTD_SR_IN_PERIOD,0) +
NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0) + NVL(EMAILS_AUTO_DELETED_IN_PERIOD,0) + NVL(EMAILS_AUTO_RESOLVED_IN_PERIOD,0))) 	curr_completed
--End 001.  Changes for adding columns for delete rate and its Grand Total
       FROM bix_email_details_mv fact,
  	   fii_time_rpt_struct cal, bix_email_accounts_v account
      WHERE fact.time_id = cal.time_id
	 AND   fact.row_type = :l_row_type
	 AND fact.email_account_id = account.id
      AND fact.period_type_id = cal.period_type_id
      AND cal.report_date = &BIS_CURRENT_ASOF_DATE
      AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN)=cal.record_type_id ';
  l_sqltext := l_sqltext || l_where_clause || '
      GROUP BY email_account_id, account.value
	     ) email,
            bix_email_accounts_v account
         WHERE email.account_id = account.id
         GROUP BY DECODE(greatest(RANKING,10),10,RANKING,11),
			   DECODE(greatest(RANKING,10),10,account.value,:l_other_account)
	 ORDER BY DECODE(greatest(RANKING,10),10,RANKING,11),
			DECODE(greatest(RANKING,10),10,account.value,:l_other_account)  ';

p_custom_sql := l_sqltext;


l_custom_rec.attribute_name := ':l_other_account' ;
l_custom_rec.attribute_value:= l_other_account;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

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
--lsql_errm := SQLERRM;
NULL;
END GET_SQL;
END  BIX_PMV_EMC_ERPT_PRTLT_PKG;

/
