--------------------------------------------------------
--  DDL for Package Body BIX_PMV_EMC_ORR_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_EMC_ORR_RPT_PKG" AS
/*$Header: bixeorrb.plb 120.0 2005/05/25 17:19:29 appldev noship $ */

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
l_record_type_id   NUMBER ;
l_account      VARCHAR2(32000);
l_start_date   DATE;
l_end_date     DATE;
l_period_from  DATE;
l_period_to    DATE;
l_dummy_cust     NUMBER;
l_max_collect_date   VARCHAR2(100);
l_period_start_date  DATE;
l_unident_string VARCHAR2(100);
l_application_id NUMBER := 680;
l_classification VARCHAR2(32000);
l_view_by varchar2(1000);
l_row_type varchar2(10) := 'ACORR';
l_unknown varchar2(1000);
l_outcome_filter NUMBER := -1;
l_subtotal varchar2(1000);
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


 l_unknown := FND_MESSAGE.GET_STRING('BIX','BIX_PMV_UNKNOWN');

 IF l_unknown IS NULL OR l_unknown = 'BIX_PMV_UNKNOWN' THEN
   l_unknown := 'Unknown';
 END IF;


 l_subtotal := FND_MESSAGE.GET_STRING('BIX','BIX_PMV_SUBTOTAL');

 IF l_subtotal IS NULL OR l_subtotal = 'BIX_PMV_SUBTOTAL' THEN
   l_subtotal := 'Subtotal';
 END IF;


 IF l_account IS NOT NULL THEN
 l_where_clause := 'AND email_account_id IN (:l_account) ';
 END IF;


 IF l_classification IS NOT NULL THEN
 l_where_clause := l_where_clause || ' AND email_classification_id IN (:l_classification) ';
 END IF;
/*
l_sqltext :=
'SELECT ''Reply'' BIX_EMC_OUTCOME,
        ''Email Sent'' BIX_EMC_RESULT,
        ''General Inquiry'' BIX_EMC_REASON,
       7390 BIX_EMC_COUNT,
       7390 BIX_PMV_TOTAL1,
       8.5 BIX_EMC_PERTOTAL1,
       100 BIX_PMV_TOTAL2,
       4   BIX_EMC_COUNTCHANGE,
       4   BIX_PMV_TOTAL3
 FROM DUAL';

p_sql_text := l_sqltext;

*/

--
--Two grouping sets - one by O,R,R and one by just O - this is for the
--SUBTOTAL. Grouping set will produce a binary number of 0s if the column
--is present and binary of 1 if the column is not present.
--

-- Start 001. Changed the query to add up only the subtotals instead of both - the subtotals and individual values

l_sqltext :=
'SELECT * FROM(
SELECT
outcome.outcome_code  BIX_EMC_OUTCOME,
result.result_code  BIX_EMC_RESULT,
reason.reason_code  BIX_EMC_REASON,
NVL(curr_count,0) BIX_EMC_COUNT,
NVL(SUM(curr_count) OVER(),0) BIX_PMV_TOTAL1,
NVL(curr_count,0) * 100/DECODE(curr_outcount,0,NULL,curr_outcount) BIX_EMC_PERTOTAL1,
(NVL(curr_count,0) * 100/DECODE(curr_outcount,0,NULL,curr_outcount)) -
(NVL(prev_count,0) * 100/DECODE(prev_outcount,0,NULL,prev_outcount)) BIX_EMC_COUNTCHANGE
FROM
  (
       SELECT  outcome_id,
          result_id,
          reason_id,
		grouping_id(outcome_id,result_id,reason_id) g_id,
          SUM(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_ORR_COUNT_IN_PERIOD,NULL)) curr_count,
          SUM(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_ORR_COUNT_IN_PERIOD,NULL)) prev_count,
          sum(SUM(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_ORR_COUNT_IN_PERIOD,NULL)))
		over (partition by outcome_id) curr_outcount,
	 sum(SUM(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_ORR_COUNT_IN_PERIOD,NULL)))
		over (partition by outcome_id) prev_outcount
  FROM bix_email_details_mv fact,
  	   fii_time_rpt_struct cal
      WHERE fact.time_id = cal.time_id
      AND fact.row_type = :l_row_type
      AND fact.period_type_id = cal.period_type_id
	  AND fact.outcome_id != :l_outcome_filter
      AND cal.report_date IN ( &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
      AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN)=cal.record_type_id
	 ' || l_where_clause ||
         '  GROUP BY
		    outcome_id,result_id,reason_id
	 ) fact, jtf_ih_outcomes_vl outcome,jtf_ih_results_vl result,jtf_ih_reasons_vl reason
         WHERE fact.outcome_id = outcome.outcome_id(+)
         AND   fact.result_id  = result.result_id(+)
         AND   fact.reason_id  = reason.reason_id(+)
         ORDER BY outcome.outcome_code,g_id,result.result_code,reason.reason_code
         )  --start 002
      WHERE  ABS(NVL(bix_emc_count,0))+ABS(NVL(bix_emc_countchange,0)) != 0  ';
   --end 002

/******

l_sqltext :=
' SELECT
   DECODE(g_id,3,:l_subtotal,outcome.outcome_code)  BIX_EMC_OUTCOME,
   DECODE(g_id,3,NULL,NVL(result.result_code,:l_unknown))  BIX_EMC_RESULT,
   DECODE(g_id,3,NULL,NVL(reason.reason_code,:l_unknown ))  BIX_EMC_REASON,
   NVL(curr_count,0) BIX_EMC_COUNT,
   NVL(SUM(curr_count) OVER(),0) BIX_PMV_TOTAL1,
   NVL(curr_count,0) * 100/DECODE(SUM(curr_count) OVER(),0,NULL,SUM(curr_count) OVER()) BIX_EMC_PERTOTAL1,
   NVL(curr_count,0) * 100/DECODE(SUM(curr_count) OVER(),0,NULL,SUM(curr_count) OVER()) -
   NVL(prev_count,0) * 100/DECODE(SUM(prev_count) OVER(),0,NULL,SUM(prev_count) OVER()) BIX_EMC_COUNTCHANGE
  FROM
  (
       SELECT  outcome_id,
          result_id,
          reason_id,
		grouping_id(outcome_id,result_id,reason_id) g_id,
          SUM(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_ORR_COUNT_IN_PERIOD,NULL)) curr_count,
          SUM(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_ORR_COUNT_IN_PERIOD,NULL)) prev_count
      FROM bix_email_details_mv fact,
  	   fii_time_rpt_struct cal
      WHERE fact.time_id = cal.time_id
	 AND fact.row_type = :l_row_type
      AND fact.period_type_id = cal.period_type_id
	 AND fact.outcome_id != :l_outcome_filter
      AND cal.report_date IN ( &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
      AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN)=cal.record_type_id
	 ' || l_where_clause ||
      '    GROUP BY
		 GROUPING SETS
		 (
		   ( outcome_id,result_id,reason_id),
		   ( outcome_id)
           )
	 ) fact, jtf_ih_outcomes_vl outcome,jtf_ih_results_vl result,jtf_ih_reasons_vl reason
         WHERE fact.outcome_id = outcome.outcome_id(+)
         AND   fact.result_id  = result.result_id(+)
         AND   fact.reason_id  = reason.reason_id(+) ';

******/


--End 001



p_sql_text := l_sqltext;


-- insert Period Type ID bind variable

l_custom_rec.attribute_name := ':l_period_type_id' ;
l_custom_rec.attribute_value:= 1;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;

l_custom_rec.attribute_name := ':l_outcome_filter' ;
l_custom_rec.attribute_value:= l_outcome_filter;
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

l_custom_rec.attribute_name := ':l_row_type' ;
l_custom_rec.attribute_value:= l_row_type;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;


l_custom_rec.attribute_name := ':l_subtotal' ;
l_custom_rec.attribute_value:= l_subtotal;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;


l_custom_rec.attribute_name := ':l_unknown' ;
l_custom_rec.attribute_value:= l_unknown;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;


l_custom_rec.attribute_name := ':l_space' ;
l_custom_rec.attribute_value:= '    ';
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;







EXCEPTION
WHEN OTHERS THEN
NULL;
END GET_SQL;
END  BIX_PMV_EMC_ORR_RPT_PKG;

/
