--------------------------------------------------------
--  DDL for Package Body BIX_PMV_AO_COPRHR_PRTLT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_AO_COPRHR_PRTLT_PKG" AS
/*$Header: bixocphp.plb 120.1 2005/06/10 04:21:03 appldev  $ */

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
l_sess_source_where_clause VARCHAR2(3000);
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
   l_source_code_where_clause := ' AND mv.campaign_id IN (select source_code_for_id
   from ams_source_codes where active_flag=''Y'' and source_code_id in (:l_source_code_id)
   and arc_source_code_for=''CAMP'' ) ';
END IF;

IF (FND_PROFILE.DEFINED('BIX_PMV_AO_TARCONT')) THEN
begin
   l_goal := TO_NUMBER(FND_PROFILE.VALUE('BIX_PMV_AO_TARCONT'));
exception
   when others then
   l_goal :=0;
end;
ELSE
   l_goal := 0;
END IF;


IF ( l_comp_type  = 'YEARLY' AND l_period_type <> 'FII_TIME_ENT_YEAR' )
THEN
--
--If it enters here it means the comparison is for Week, Month or Quarter
--and it is a Year over Year comparison.
--
   l_sqltext := '
      SELECT fii1.name                                  VIEWBY,
             NVL(sum(PREV_CONTACTS)/
             sum(DECODE(PREV_LOGIN/3600,0,NULL,PREV_LOGIN/3600)),0)  BIX_PMV_AO_CONTPERHR_PP,

            NVL(sum(CURR_CONTACTS)/
             sum(DECODE(CURR_LOGIN/3600,0,NULL,CURR_LOGIN/3600)),0)  BIX_PMV_AO_CONTPERHR_CP,
            ' || l_goal ||'                               BIX_PMV_AO_CONTPERHR_GL
      FROM
            (
            /*start inline view
            select current contacts and previous contacts
            */
              SELECT fii1.sequence SEQUENCE,
              SUM( CASE when
                        (
                          fii1.start_date between &BIS_CURRENT_REPORT_START_DATE
                                                      and &BIS_CURRENT_ASOF_DATE
                           and cal.report_date = least(fii1.end_date,&BIS_CURRENT_ASOF_DATE)
                          )
                          then
                            AGENTCALL_CONTACT_COUNT
                          else
				            0
                          end
              ) CURR_CONTACTS,
              SUM( CASE when
                            (
                                fii1.start_date between &BIS_PREVIOUS_REPORT_START_DATE
                                                   and &BIS_PREVIOUS_ASOF_DATE
                                   and cal.report_date = least(fii1.end_date,&BIS_PREVIOUS_ASOF_DATE)
                               )
                               then
                               AGENTCALL_CONTACT_COUNT
                               else
				                0
                               end
              ) PREV_CONTACTS,
              0 CURR_LOGIN,
              0 PREV_LOGIN
              FROM  ';
l_sqltext := l_sqltext || l_period_type ||'	fii1,
            bix_ao_call_details_mv mv,
			fii_time_rpt_struct cal
            WHERE mv.time_id        = cal.time_id
		    AND mv.row_type = :l_row_type
            AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN)=cal.record_type_id
            AND   fii1.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE AND
			&BIS_CURRENT_ASOF_DATE
            AND cal.report_date = (CASE WHEN(
									 fii1.start_date between
                                              &BIS_PREVIOUS_REPORT_START_DATE and
                                              &BIS_PREVIOUS_ASOF_DATE
									 )
                                          THEN
                                             least(fii1.end_date, &BIS_PREVIOUS_ASOF_DATE)
                                          ELSE
                                             least(fii1.end_date, &BIS_CURRENT_ASOF_DATE)
                                          END
                                     )

            AND cal.period_type_id = mv.period_type_id
         ';
l_sqltext := l_sqltext || l_call_where_clause ||l_source_code_where_clause||
            '
		    GROUP BY fii1.sequence
            UNION ALL
           /*continue inline view
           select from session tables for current and previous login times
           */
          SELECT fii1.sequence,
          0 CURR_CONTACTS,
          0 PREV_CONTACTS,
          SUM( CASE when
               (
               fii1.start_date between &BIS_CURRENT_REPORT_START_DATE
                                            and &BIS_CURRENT_ASOF_DATE
               )
               then
                 LOGIN_TIME
               else
			     0
               end
              ) CURR_LOGIN,
          SUM( CASE when
                 (
                 fii1.start_date between &BIS_PREVIOUS_REPORT_START_DATE
                                            and &BIS_PREVIOUS_ASOF_DATE
                  )
                  then
                     LOGIN_TIME
                  else
				      0
                  end
               ) PREV_LOGIN
            FROM  ';
l_sqltext := l_sqltext || l_period_type ||'	fii1,
            bix_agent_session_f mv,
			fii_time_rpt_struct cal
            WHERE mv.time_id        = cal.time_id
		    AND mv.application_id = :l_application_id
            AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN)=cal.record_type_id
            AND   fii1.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE AND
							   &BIS_CURRENT_ASOF_DATE
            AND cal.report_date = (CASE WHEN(
									 fii1.start_date between
                                              &BIS_PREVIOUS_REPORT_START_DATE and
                                              &BIS_PREVIOUS_ASOF_DATE
									 )
                                          THEN
                                             least(fii1.end_date, &BIS_PREVIOUS_ASOF_DATE)
                                          ELSE
                                             least(fii1.end_date, &BIS_CURRENT_ASOF_DATE)
                                          END
                                     )
              AND cal.period_type_id = mv.period_type_id ';

l_sqltext := l_sqltext || l_call_where_clause ||
             '
	         GROUP BY fii1.sequence
		    ) summ, ';
l_sqltext := l_sqltext || l_period_type ||' fii1
             WHERE fii1.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
                                       AND &BIS_CURRENT_ASOF_DATE
             AND fii1.sequence = summ.sequence (+)
             GROUP BY fii1.name, fii1.start_date, summ.sequence
             ORDER BY fii1.start_date ';

ELSE
--
--If it reaches here it means it is either a Sequential comparison for
--week, month or quarter OR it is a YEAR period type.  For YEAR period type
--it does not matter whether it is a Y/Y comparison or a Sequential comparison
--as both will be treated the same.
--
l_sqltext := '
             SELECT fii1.name                                 VIEWBY,
             0                                               BIX_PMV_AO_CONTPERHR_PP,
             nvl(SUM(NVL(CURR_CONTACTS,0))/
             decode(SUM(CURR_LOGIN/3600),0,null,sum(curr_login/3600)),0)                          BIX_PMV_AO_CONTPERHR_CP,
             ' || l_goal ||'                                 BIX_PMV_AO_CONTPERHR_GL
      FROM
            (
           /*start of inline view
            select current contacts from mv */
               SELECT fii1.name                            NAME,
               sum(AGENTCALL_CONTACT_COUNT )             CURR_CONTACTS,
               0                                          CURR_LOGIN
               FROM  '||l_period_type||'	fii1,
               bix_ao_call_details_mv mv,
			   fii_time_rpt_struct cal
               WHERE mv.time_id        = cal.time_id
               AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN)=cal.record_type_id
               AND   fii1.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND
								   &BIS_CURRENT_ASOF_DATE
		       AND cal.report_date = least(&BIS_CURRENT_ASOF_DATE,fii1.end_date)
		       AND cal.period_type_id = mv.period_type_id
		       AND mv.row_type = :l_row_type  ';
l_sqltext := l_sqltext || l_call_where_clause ||l_source_code_where_clause||
             '
              GROUP BY fii1.name
              UNION ALL
             /* continue inline view
             select login time from session tables */
              SELECT fii1.name,
              0  CURR_CONTACTS,
              SUM(LOGIN_TIME) CURR_LOGIN
              FROM  ';
l_sqltext := l_sqltext || l_period_type ||'	fii1,
              bix_agent_session_f mv,
			  fii_time_rpt_struct cal
              WHERE mv.time_id        = cal.time_id
      	      AND mv.application_id = :l_application_id
              AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN)=cal.record_type_id
              AND   fii1.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND
								   &BIS_CURRENT_ASOF_DATE
              AND cal.report_date = least(fii1.end_date, &BIS_CURRENT_ASOF_DATE)   ';
l_sqltext := l_sqltext || l_call_where_clause ||
             '
            GROUP BY fii1.name
             ) curr, ';
l_sqltext := l_sqltext || l_period_type || ' fii1
       WHERE fii1.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
       AND &BIS_CURRENT_ASOF_DATE
       AND fii1.name = curr.name (+)
	  GROUP BY fii1.name, fii1.start_date
       ORDER BY fii1.start_date
             ';

END IF;

/* Before passing l_sqltext to the calling proc, we trim it up a bit */
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

l_custom_rec.attribute_name := ':l_application_id';
l_custom_rec.attribute_value := 696;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;

p_custom_output.EXTEND;
p_custom_output(p_custom_output.COUNT) := l_custom_rec;

l_custom_rec.attribute_name := ':l_period_type_id';
l_custom_rec.attribute_value:= 1;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;


l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.View_By_Type;
l_custom_rec.attribute_value := 'TIME+'||l_period_type;

p_custom_output.EXTEND;
p_custom_output(p_custom_output.COUNT) := l_custom_rec;


EXCEPTION
WHEN OTHERS THEN
l_sql_errm := SQLERRM;
NULL;
END GET_SQL;
END BIX_PMV_AO_COPRHR_PRTLT_PKG;


/
