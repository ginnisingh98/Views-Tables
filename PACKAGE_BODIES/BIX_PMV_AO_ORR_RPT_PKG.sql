--------------------------------------------------------
--  DDL for Package Body BIX_PMV_AO_ORR_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_AO_ORR_RPT_PKG" AS
/*$Header: bixoorrr.plb 115.3 2004/06/01 09:06:05 pubalasu noship $ */

PROCEDURE GET_SQL(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                  p_sql_text           OUT NOCOPY VARCHAR2,
                  p_custom_output      OUT NOCOPY bis_query_attributes_TBL
                  )
AS
l_sqltext	      VARCHAR2(32000) ;
l_where_clause        VARCHAR2(1000) ;
l_call_where_clause        VARCHAR2(1000) ;
l_source_code_where_clause        VARCHAR2(1000) ;
l_campaign_where_clause        VARCHAR2(1000) ;
l_schedule_where_clause        VARCHAR2(1000) ;
l_as_of_date   DATE;
l_period_type	varchar2(2000);
l_comp_type    varchar2(2000);
l_sql_errm      varchar2(32000);
l_agent_cost      NUMBER;
l_custom_rec       BIS_QUERY_ATTRIBUTES;
l_record_type_id   NUMBER ;
l_start_date   DATE;
l_end_date     DATE;
l_period_from  DATE;
l_period_to    DATE;
l_dummy_cust     NUMBER;
l_max_collect_date   VARCHAR2(100);
l_period_start_date  DATE;
l_unident_string VARCHAR2(100);
l_application_id NUMBER := 696;
l_view_by varchar2(1000);
l_row_type varchar2(10) := 'CORR';
l_unknown varchar2(1000);
l_outcome_filter NUMBER := -1;
l_subtotal varchar2(1000);
l_call_center VARCHAR2(3000);

l_campaign_id varchar2(3000);
l_schedule_id varchar2(3000);
l_source_code_id varchar2(3000);
l_agent_group        VARCHAR2(3000);


BEGIN

--
--Initialize p_custom_output
--

 p_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
 l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;

-- Get the parameters
BIX_PMV_DBI_UTL_PKG.get_ao_page_params( p_page_parameter_tbl,
                                         l_as_of_date,
                                         l_period_type,
                                         l_record_type_id,
                                         l_comp_type,
                                         l_call_center,
                                         l_campaign_id,
                                         l_schedule_id,
                                         l_source_code_id,
                                         l_agent_group,
        								 l_view_by
                                      );




 l_unknown := FND_MESSAGE.GET_STRING('BIX','BIX_PMV_UNKNOWN');

 IF l_unknown IS NULL OR l_unknown = 'BIX_PMV_UNKNOWN' THEN
   l_unknown := 'Unknown';
 END IF;


 l_subtotal := FND_MESSAGE.GET_STRING('BIX','BIX_PMV_SUBTOTAL');

 IF l_subtotal IS NULL OR l_subtotal = 'BIX_PMV_SUBTOTAL' THEN
   l_subtotal := 'Subtotal';
 END IF;

IF l_call_center IS NOT NULL THEN
   l_call_where_clause := ' AND fact.server_group_id IN (:l_call_center) ';
END IF;

IF l_source_code_id IS NOT NULL THEN
   l_source_code_where_clause := ' AND fact.campaign_id in (select source_code_for_id from
   ams_source_codes where source_code_id IN (:l_source_code_id) and arc_source_code_for=''CAMP'' and active_flag=''Y'') ';

END IF;

l_where_clause:=l_where_clause||l_call_where_clause||l_source_code_where_clause;
--
--Two grouping sets - one by O,R,R and one by just O - this is for the
--SUBTOTAL. Grouping set will produce a binary number of 0s if the column
--is present and binary of 1 if the column is not present.
--

l_sqltext :=
' SELECT
   DECODE(g_id,3,:l_subtotal,outcome.outcome_code)  BIX_PMV_AO_OUTCOME,
   DECODE(g_id,3,'' '',NVL(result.result_code,:l_unknown))  BIX_PMV_AO_RESULT,
   DECODE(g_id,3,'' '',NVL(reason.reason_code,:l_unknown ))  BIX_PMV_AO_REASON,
   NVL(curr_count,0) BIX_PMV_AO_COUNT,
nvl(sum(decode(g_id,3,curr_count)) over(),0) BIX_PMV_TOTAL1,
   ROUND(nvl(curr_count * 100/DECODE(sum(decode(g_id,3,curr_count)) over(),0,NULL,sum(decode(g_id,3,curr_count)) over()),0),1) BIX_PMV_AO_PERTOTAL1,
   ROUND(nvl(curr_count * 100/DECODE(sum(decode(g_id,3,curr_count)) over(),0,NULL,sum(decode(g_id,3,curr_count)) over()),0),1) -
   ROUND(NVL(prev_count * 100/DECODE(sum(decode(g_id,3,prev_count)) over(),0,NULL,sum(decode(g_id,3,prev_count)) over()),0),1) BIX_PMV_AO_COUNTCHANGE
   /*,sum(   ROUND(NVL(curr_count,0) * 100/DECODE(SUM(curr_count) OVER(),0,NULL,SUM(curr_count) OVER()),1) -
   ROUND(NVL(prev_count,0) * 100/DECODE(SUM(prev_count) OVER(),0,NULL,SUM(prev_count) OVER()),1) ) over() over() BIX_PMV_TOTAL2
   */
  FROM
  (
       SELECT  outcome_id,
          result_id,
          reason_id,
		grouping_id(outcome_id,result_id,reason_id) g_id,
          SUM(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,AGENTCALL_ORR_COUNT,NULL)) curr_count,
          SUM(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,AGENTCALL_ORR_COUNT,NULL)) prev_count
      FROM bix_ao_call_details_mv fact,
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
         AND   fact.reason_id  = reason.reason_id(+)
         order by outcome.outcome_code,g_id,result.result_code,reason.reason_code ';
  /* Before passing l_sqltext to the calling proc, we trim it up a bit */
l_sqltext:=replace(replace(replace(replace(replace(l_sqltext,
'      ',' '),'     ',' '),'    ',' '),'   ',' '),'  ',' ');
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

IF l_call_center IS NOT NULL
THEN
   l_custom_rec.attribute_name := ':l_call_center';
   l_custom_rec.attribute_value:= l_call_center;
   l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
   l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

   p_custom_output.Extend();
   p_custom_output(p_custom_output.count) := l_custom_rec;
END IF;
IF l_campaign_id IS NOT NULL
THEN
l_custom_rec.attribute_name := ':l_campaign_id';
l_custom_rec.attribute_value:= l_campaign_id;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;
END IF;

IF l_schedule_id IS NOT NULL
THEN
l_custom_rec.attribute_name := ':l_schedule_id';
l_custom_rec.attribute_value:= l_schedule_id;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;
END IF;
IF l_source_code_id IS NOT NULL
THEN
l_custom_rec.attribute_name := ':l_source_code_id';
l_custom_rec.attribute_value:= l_source_code_id;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;
END IF;

EXCEPTION
WHEN OTHERS THEN
NULL;
END GET_SQL;
END  BIX_PMV_AO_ORR_RPT_PKG;






/
