--------------------------------------------------------
--  DDL for Package Body BIX_PMV_EMC_EVAT_PRTLT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_EMC_EVAT_PRTLT_PKG" AS
/*$Header: bixevatp.plb 115.14 2003/11/22 01:46:30 djambula noship $ */

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
l_classification VARCHAR2(32000);
l_view_by varchar2(1000);
l_row_type varchar2(10) := 'AC';

l_custom_rec BIS_QUERY_ATTRIBUTES := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;

BEGIN

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
						      l_classification ,
						      l_view_by
				                      );

-- If the account is not 'All'

 IF l_account IS NOT NULL THEN
 l_where_clause := 'AND email_account_id IN (:l_account) ';
 END IF;


 IF l_classification IS NOT NULL THEN
 l_where_clause := l_where_clause || ' AND email_classification_id IN (:l_classification) ';
 END IF;


l_period_start_date := BIX_PMV_DBI_UTL_PKG.period_start_date(l_as_of_date,l_period_type);

 /* Get the MAX date for which data is collected in Email Summary table */

    BIS_COLLECTION_UTILITIES.get_last_refresh_dates('BIX_EMAIL_DETAILS_F',
                                                     l_start_date,
                                                     l_end_date,
                                                     l_period_from,
                                                     l_period_to
                                                   );

--
--If the data is not collected till AS OF DATE
--then get the accumulated measures from the MAX collected DATE time bucket
--if the max collect date falls within the current period
--

  IF l_period_to BETWEEN l_period_start_date AND l_as_of_date
  THEN
    l_max_collect_date := TO_CHAR(l_period_to,'DD/MM/YYYY');
  ELSE
   l_max_collect_date := TO_CHAR(l_as_of_date,'DD/MM/YYYY');
  END IF;

 l_other_account := FND_MESSAGE.GET_STRING('BIX','BIX_PMV_ALLACCT');

 IF l_other_account IS NULL OR l_other_account = 'BIX_PMV_ALLACCT'
 THEN
	l_other_account := 'Others';
 END IF;

l_sqltext := '
SELECT DECODE(greatest(RANKING,10),10,account.value,:l_other_account )  BIX_EMC_ACCOUNT,
nvl(sum(CURR_RCVD),0)                                               BIX_EMC_RCVD,
nvl(SUM(SUM(CURR_RCVD)) over(),0)                                   BIX_PMV_TOTAL1,
nvl(sum(curr_composed),0)                                           BIX_EMC_COMPOSED,
nvl(SUM(sum(curr_composed)) OVER(),0)                               BIX_PMV_TOTAL2,
sum(CURR_REPLD)                                                     BIX_EMC_REPLD,
SUM(sum(CURR_REPLD)) over()                                         BIX_PMV_TOTAL3,
sum(CURR_DEL)                                                       BIX_EMC_DELETED,
SUM(sum(CURR_DEL)) over()                                           BIX_PMV_TOTAL4,
nvl(sum(curr_trfd) ,0)                                              BIX_EMC_TRANOUT,
nvl(SUM(sum(curr_trfd)) OVER(),0)                                   BIX_PMV_TOTAL6,
nvl(sum(CURR_BACKLOG),0)                                            BIX_EMC_BACKLOG,
nvl(SUM(sum(CURR_BACKLOG)) over(),0)                                BIX_PMV_TOTAL5,
nvl(sum(CURR_SR),0)                                                 BIX_EMC_SR,
nvl(SUM(sum(CURR_SR)) over(),0)                                     BIX_PMV_TOTAL8,
nvl(sum(curr_leads),0)                                              BIX_EMC_LEADS,
nvl(SUM(sum(curr_leads)) OVER(),0)                                  BIX_PMV_TOTAL9
FROM (
       SELECT  email_account_id                                ACCOUNT_ID,
	sum(EMAILS_OFFERED_IN_PERIOD)              CURR_RCVD,
	sum(EMAILS_COMPOSED_IN_PERIOD)             CURR_COMPOSED,
	NVL(sum(EMAILS_REPLIED_IN_PERIOD),0) + NVL(SUM(EMAILS_AUTO_REPLIED_IN_PERIOD),0)  CURR_REPLD,
	NVL(sum(EMAILS_DELETED_IN_PERIOD),0) + NVL(SUM(EMAILS_AUTO_DELETED_IN_PERIOD),0)  CURR_DEL,
	sum(EMAILS_RSL_AND_TRFD_IN_PERIOD)               CURR_TRFD,
	sum(SR_CREATED_IN_PERIOD)                  CURR_SR,
	sum(LEADS_CREATED_IN_PERIOD)               CURR_LEADS,
	RANK() OVER (ORDER BY sum(nvl(EMAILS_OFFERED_IN_PERIOD,0)) DESC, vl.value)  RANKING
	FROM bix_email_details_mv fact,
  	   fii_time_rpt_struct cal, bix_email_accounts_v vl
      WHERE fact.time_id = cal.time_id
	 AND   fact.row_type = :l_row_type
      AND fact.period_type_id = cal.period_type_id
      AND cal.report_date = &BIS_CURRENT_ASOF_DATE
      AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN)=cal.record_type_id
	 AND vl.id = fact.email_account_id ';
   l_sqltext := l_sqltext || l_where_clause || '
      GROUP BY email_account_id, vl.value
	 ) summ,
	 (
       SELECT  email_account_id                             ACCOUNT_ID,
               SUM(NVL(ACCUMULATED_OPEN_EMAILS,0) +
                   NVL(ACCUMULATED_EMAILS_IN_QUEUE,0)
			    )                                        CURR_BACKLOG
         FROM   bix_email_details_mv
         WHERE time_id = to_char(:l_max_collect_date,''J'')
	    AND   row_type = :l_row_type
         AND   period_type_id = :l_period_type_id ';
   l_sqltext := l_sqltext || l_where_clause || '
         GROUP BY email_account_id
	  ) accu,
         bix_email_accounts_v account
         WHERE summ.account_id = accu.account_id (+)
	    AND   summ.account_id = account.id
         GROUP BY DECODE(greatest(RANKING,10),10,account.value,:l_other_account),
                  DECODE(greatest(RANKING,10),10,RANKING,11)
	    ORDER BY DECODE(greatest(RANKING,10),10,RANKING,11) ';

p_custom_sql := l_sqltext;

p_custom_output.EXTEND();
l_custom_rec.attribute_name := ':l_max_collect_date';
l_custom_rec.attribute_value:= l_max_collect_date;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
p_custom_output(p_custom_output.count) := l_custom_rec;

p_custom_output.EXTEND();
l_custom_rec.attribute_name := ':l_period_type_id' ;
l_custom_rec.attribute_value:= 1;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
p_custom_output(p_custom_output.count) := l_custom_rec;

p_custom_output.EXTEND();
l_custom_rec.attribute_name := ':l_other_account' ;
l_custom_rec.attribute_value:= l_other_account;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
p_custom_output(p_custom_output.count) := l_custom_rec;

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
END  BIX_PMV_EMC_EVAT_PRTLT_PKG;

/
