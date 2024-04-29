--------------------------------------------------------
--  DDL for Package Body BIX_PMV_EMC_VBAG_PRTLT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_EMC_VBAG_PRTLT_PKG" AS
/*$Header: bixevbap.plb 115.13 2003/11/22 01:46:31 djambula noship $ */

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
l_custom_rec BIS_QUERY_ATTRIBUTES := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
l_classification VARCHAR2(32000);
l_view_by varchar2(1000);
l_row_type varchar2(10) := 'AC';

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
       SELECT DECODE(greatest(RANKING,10),10,EMC_ACCOUNT,:l_other_account)  BIX_EMC_ACCOUNT,
              NVL(SUM(CURR_RCVD),0)                  BIX_EMC_RCVD,
		    NVL(SUM(CURR_REPLD),0)                 BIX_EMC_REPLD
FROM (
       SELECT  account.value                                EMC_ACCOUNT,
          	sum(EMAILS_OFFERED_IN_PERIOD)           CURR_RCVD,
	          NVL(sum(EMAILS_REPLIED_IN_PERIOD),0) + NVL(SUM(EMAILS_AUTO_REPLIED_IN_PERIOD),0) CURR_REPLD,
			RANK() OVER (ORDER BY nvl(sum(EMAILS_OFFERED_IN_PERIOD),0) DESC,
					   account.value
					   )                               RANKING
       FROM bix_email_details_mv fact,
  	   fii_time_rpt_struct cal,
	   bix_email_accounts_v account
      WHERE fact.time_id = cal.time_id
	 AND   fact.row_type = :l_row_type
      AND fact.period_type_id = cal.period_type_id
      AND cal.report_date = &BIS_CURRENT_ASOF_DATE
      AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN)=cal.record_type_id
      AND   fact.email_account_id = account.id ';
 l_sqltext := l_sqltext || l_where_clause || ' GROUP BY account.value
	     )
      GROUP BY DECODE(greatest(RANKING,10),10,EMC_ACCOUNT,:l_other_account),
               DECODE(greatest(RANKING,10),10,RANKING,11),
			DECODE(greatest(RANKING,10),10,1,2)
	 ORDER BY DECODE(greatest(RANKING,10),10,1,2),
			DECODE(greatest(RANKING,10),10,RANKING,11), 1 ';

p_custom_sql := l_sqltext;

l_custom_rec.attribute_name := ':l_other_account' ;
l_custom_rec.attribute_value:= l_other_account;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

p_custom_output.Extend();
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
NULL;
END GET_SQL;
END  BIX_PMV_EMC_VBAG_PRTLT_PKG;

/
