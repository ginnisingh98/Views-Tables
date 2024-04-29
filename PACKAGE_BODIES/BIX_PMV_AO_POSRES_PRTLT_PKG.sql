--------------------------------------------------------
--  DDL for Package Body BIX_PMV_AO_POSRES_PRTLT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_AO_POSRES_PRTLT_PKG" AS
/*$Header: bixoposp.plb 115.4 2004/03/08 09:16:55 pubalasu noship $ */

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
l_sql_errm      varchar2(32000);
l_previous_report_start_date DATE;
l_current_report_start_date DATE;
l_previous_as_of_date DATE;
l_period_type_id NUMBER;
l_time_id_column  VARCHAR2(1000);
l_goal NUMBER;
--added for campaign, schedule and source code
l_campaign_id       varchar2(3000);
l_schedule_id       varchar2(3000);
l_source_code_id    varchar2(3000);
l_campaign_where_clause VARCHAR2(3000);
l_schedule_where_clause VARCHAR2(3000);
l_source_code_where_clause VARCHAR2(3000);
l_agent_group varchar2(3000);
l_call_where_clause VARCHAR2(3000);
l_session_where_clause VARCHAR2(3000);
l_call_center VARCHAR2(3000);
l_view_by            VARCHAR2(3000);

l_custom_rec BIS_QUERY_ATTRIBUTES := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;

BEGIN
--
--Initialize p_custom_output
--
p_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

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


IF l_call_center IS NOT NULL THEN
   l_call_where_clause := ' AND mv.server_group_id IN (:l_call_center) ';
END IF;
IF l_campaign_id IS NOT NULL THEN
   l_campaign_where_clause := ' AND mv.campaign_id IN (:l_campaign_id) ';
END IF;
IF l_schedule_id IS NOT NULL THEN
   l_schedule_where_clause := ' AND mv.schedule_id IN (:l_schedule_id) ';
END IF;
IF l_source_code_id IS NOT NULL THEN
    l_source_code_where_clause := ' AND mv.campaign_id in (select source_code_for_id from
   ams_source_codes where source_code_id IN (:l_source_code_id) and arc_source_code_for=''CAMP'' and active_flag=''Y'')  ';

END IF;

   l_sqltext := '
         SELECT meaning BIX_PMV_AO_OUTCOME,
	         sum(pper)  BIX_PMV_AO_PPER,
			 sum(cper)  BIX_PMV_AO_CPER
         FROM (
             SELECT lookup.meaning meaning,
                    nvl(sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
                           decode(lookup.lookup_code,
                                      ''PR'', AGENTCALL_PR_COUNT,
                                      ''TR'', AGENTCALL_ORR_COUNT,
                                   0),
                     0)),0) PPER,
                    nvl(sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
                           decode(lookup.lookup_code,
                                      ''PR'', AGENTCALL_PR_COUNT,
                                      ''TR'', AGENTCALL_ORR_COUNT,
                                   0),
                     0)),0) CPER
              FROM bix_ao_call_details_mv mv,
                   fii_time_rpt_struct cal,
                   (
                		select lookup_code,meaning
                        from fnd_lookup_values_vl
                        where lookup_type = :l_lookup_type
                      )
                     lookup
              WHERE mv.time_id        = cal.time_id
		    AND mv.row_type = :l_row_type
              AND   mv.period_type_id = cal.period_type_id
              AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN) =
                                        cal.record_type_id
              AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE,
                                      &BIS_PREVIOUS_ASOF_DATE) ';

l_sqltext := l_sqltext || l_call_where_clause ||l_source_code_where_clause||
             '
		    GROUP BY lookup.meaning
		    UNION ALL
            (
                    select meaning,0,0
                    from fnd_lookup_values_vl
                    where lookup_type = :l_lookup_type            )
		    )
           GROUP BY meaning '
                ;
l_sqltext:=replace(replace(replace(replace(replace(l_sqltext,
'      ',' '),'     ',' '),'    ',' '),'   ',' '),'  ',' ');
p_custom_sql := l_sqltext;

l_custom_rec.attribute_name := ':l_row_type';
l_custom_rec.attribute_value:= 'C';
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


l_custom_rec.attribute_name := ':l_lookup_type';
l_custom_rec.attribute_value:= 'BIX_PMV_AO_RESPONSES';
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;


EXCEPTION
WHEN OTHERS THEN
NULL;

NULL;
END GET_SQL;
END BIX_PMV_AO_POSRES_PRTLT_PKG;


/
