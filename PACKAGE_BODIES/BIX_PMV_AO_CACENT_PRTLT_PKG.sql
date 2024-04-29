--------------------------------------------------------
--  DDL for Package Body BIX_PMV_AO_CACENT_PRTLT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_AO_CACENT_PRTLT_PKG" AS
/*$Header: bixoccnp.plb 115.8 2004/04/13 13:42:32 suray noship $ */

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
l_call_center VARCHAR2(3000);

l_other_group VARCHAR2(30);

l_session_where_clause VARCHAR2(3000);

l_campaign_id varchar2(3000);
l_schedule_id varchar2(3000);
l_source_code_id varchar2(3000);
l_agent_group        VARCHAR2(3000);
l_call_where_clause VARCHAR2(3000);

l_campaign_where_clause VARCHAR2(3000);
l_source_code_where_clause VARCHAR2(3000);
l_schedule_where_clause VARCHAR2(3000);
l_sess_source_where_clause VARCHAR2(3000);

l_unknown VARCHAR2(50);
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
--   l_source_code_where_clause := ' AND mv.source_code_id IN (:l_source_code_id) ';
   l_source_code_where_clause := ' AND mv.campaign_id in (select source_code_for_id from
   ams_source_codes where source_code_id IN (:l_source_code_id) and arc_source_code_for=''CAMP'' and active_flag=''Y'') ';


END IF;


l_unknown := FND_MESSAGE.GET_STRING('BIX','BIX_PMV_UNKNOWN');

IF l_unknown IS NULL OR l_unknown = 'BIX_PMV_UNKNOWN'
THEN
   l_unknown := 'Unknown';
END IF;


   l_sqltext := '
            SELECT DECODE(greatest(RANKING,10),10,group_name,
		                   decode(group_name,:l_unknown,
                                    ''</a><nobr>''|| :l_unknown ||''</nobr><a href=#>'',
                                    ''</a><nobr>''|| :l_other_group ||''</nobr><a href=#>''
							 )
                         ) VIEWBY,
                 sum(HAND) BIX_PMV_AO_OUTCALLHAND,
                 sum(sum(HAND)) over() BIX_PMV_TOTAL2,
                 round(NVL(sum(ABAND)*100/
                  decode(sum(OFFRD),0,NULL,sum(OFFRD)),0),1) BIX_PMV_AO_ABANRATE,
                 round(sum (sum(ABAND)) over()*100/
                 decode(sum(sum(OFFRD)) over(),0,NULL,sum(sum(OFFRD)) over()),1) BIX_PMV_TOTAL4,
                 round(nvl(sum(USABAND)*100/
                 decode(sum(OFFRD),0,NULL,sum(OFFRD)),0),1) BIX_PMV_AO_US_ABANRATE,
                 round(sum(nvl(sum(USABAND),0)) over()*100/
                 decode(sum(sum(OFFRD)) over(),0,NULL,sum(sum(OFFRD)) over()),1) BIX_PMV_TOTAL11,
                 sum(sr) BIX_PMV_AO_SRCR,
                 sum(sum(sr)) over() BIX_PMV_TOTAL6,
                 sum(lead) BIX_PMV_AO_LECR,
                 sum(sum(lead)) over() BIX_PMV_TOTAL7 ,
			  sum(opp) BIX_PMV_AO_OPCR,
			  sum(sum(opp)) over() BIX_PMV_TOTAL8,
               round(nvl(3600* sum(contacts)  /decode(sum(login),0,null,sum(login)),0),1)
               BIX_PMV_AO_CONTPERHR,
              round(sum(sum(contacts)) over()  /(decode(sum(sum(login)) over(),0,null,sum(sum(login)) over())/3600),1) BIX_PMV_TOTAL9,
              nvl(sum(pr),0) BIX_PMV_AO_PORESP,
              sum(nvl(sum(pr),0)) over() BIX_PMV_TOTAL10

             FROM
             (
             /*
             --Additional inline view needed to compute RANK due to continued measures
             */
            SELECT nvl(bixcent.value,:l_unknown) group_name,
                   nvl(sum(OFFRD),0) OFFRD, nvl(sum(hand),0) HAND,
                   nvl(sum(ABAND),0) ABAND,
                   nvl(sum(USABAND),0) USABAND,
                   nvl(sum(LOGIN),0) LOGIN,
                   nvl(sum(CONTACTS),0) CONTACTS,
                   nvl(sum(PR),0) PR,
                   nvl(sum(talk),0) TALK, nvl(sum(sr),0) SR, nvl(sum(lead),0) LEAD, nvl(sum(opp),0) OPP,
			    decode(bixcent.value,NULL,11,
                             RANK() OVER (ORDER BY nvl(sum(HAND),0) DESC, bixcent.value)
				      ) RANKING
            FROM
               (
             SELECT server_group_id server_group_id,
                   sum(decode(dialing_method,''PRED'',CALL_CALLS_OFFERED_TOTAL,0) ) OFFRD,
                    sum(AGENT_CALLS_HANDLED_TOTAL) HAND,
                    sum(decode(dialing_method,''PRED'',CALL_CALLS_ABANDONED,0) ) ABAND,
                    sum(decode(dialing_method,''PRED'',CALL_CALLS_ABANDONED_US,0) ) USABAND,
                    sum(CALL_TALK_TIME) TALK,
                    sum(AGENT_SR_CREATED) SR,
                    sum(AGENT_LEADS_CREATED) LEAD,
                    sum(AGENT_OPPORTUNITIES_CREATED) OPP,
                    sum(AGENTCALL_CONTACT_COUNT) CONTACTS,
                    sum(AGENTCALL_PR_COUNT) PR,
                    0 LOGIN
              FROM bix_ao_call_details_mv mv,
                   fii_time_rpt_struct cal
              WHERE mv.time_id        = cal.time_id
		    AND mv.row_type = :l_row_type
              AND   mv.period_type_id = cal.period_type_id
              AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN) =
                                        cal.record_type_id
              AND cal.report_date = &BIS_CURRENT_ASOF_DATE ';

l_sqltext := l_sqltext || l_call_where_clause ||l_source_code_where_clause||
             '
		    GROUP BY mv.server_group_id
              UNION ALL
              SELECT server_group_id server_group_id,
                    sum(decode(dialing_method,''PRED'',CALL_CONT_CALLS_HANDLED_TOT_NA,0) ) OFFRD,
                    nvl(sum(AGENT_CONT_CALLS_HAND_NA),0) HAND,
                    0 ABAND,
                    0 USBAND,
                    0 TALK,
                    0 SR,
                    0 LEAD,
				    0 OPP,
                    0 CONTACTS,
                    0 PR,
                    0 LOGIN
              FROM bix_ao_call_details_mv mv
              WHERE mv.time_id = to_char(&BIS_CURRENT_EFFECTIVE_START_DATE,''J'')
		    AND mv.row_type = :l_row_type
              AND   mv.period_type_id = :l_period_type_id
 ';

l_sqltext := l_sqltext || l_call_where_clause ||l_source_code_where_clause||
             '
		    GROUP BY mv.server_group_id
            UNION ALL
            SELECT mv.server_group_id ,
              0 OFFRD,
              0 HAND,
              0 ABAND,
              0 USABAND,
              0 TALK,
              0 SR,
              0 LEAD,
              0 OPP,
              0 CONTACTS,
              0 PR,
              SUM(LOGIN_TIME) LOGIN
              FROM
 		              bix_agent_session_f mv,
			  fii_time_rpt_struct cal
              WHERE mv.time_id        = cal.time_id
              AND application_id = :l_application_id
		      AND   mv.period_type_id = cal.period_type_id
              AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN) =
                                        cal.record_type_id
              AND cal.report_date = &BIS_CURRENT_ASOF_DATE
               ';
l_sqltext := l_sqltext || l_call_where_clause ||
              ' GROUP BY mv.server_group_id ) summ,
              BIX_BIS_CALL_CENTER_V BIXCENT
              WHERE summ.server_group_id = bixcent.id (+)
                 GROUP BY bixcent.value
              )
             GROUP BY DECODE(greatest(RANKING,10),10,RANKING,decode(group_name,:l_unknown,11,12)),
			   DECODE(greatest(RANKING,10),10,group_name,
		                   decode(group_name,:l_unknown,
                                  ''</a><nobr>''|| :l_unknown ||''</nobr><a href=#>'',
                                  ''</a><nobr>''|| :l_other_group ||''</nobr><a href=#>''
						      )
                                  )
	     ORDER BY DECODE(greatest(RANKING,10),10,RANKING,decode(group_name,:l_unknown,11,12)),
			DECODE(greatest(RANKING,10),10,group_name,
		                   decode(group_name,:l_unknown,
                               ''</a><nobr>''|| :l_unknown ||''</nobr><a href=#>'',
                               ''</a><nobr>''|| :l_other_group ||''</nobr><a href=#>''
						     )
                               )  ';
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

l_custom_rec.attribute_name := ':l_other_group' ;
l_custom_rec.attribute_value:= l_other_group;
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
l_custom_rec.attribute_name := ':l_period_type_id';
l_custom_rec.attribute_value:= 1;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;


l_custom_rec.attribute_name := ':l_application_id';
l_custom_rec.attribute_value := 696;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;

p_custom_output.EXTEND;
p_custom_output(p_custom_output.COUNT) := l_custom_rec;


l_custom_rec.attribute_name := ':l_unknown';
l_custom_rec.attribute_value:= l_unknown;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

p_custom_output.EXTEND;
p_custom_output(p_custom_output.COUNT) := l_custom_rec;

l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.View_By_Type;
l_custom_rec.attribute_value := 'BIX_TELEPHONY+BIX_CALL_CENTER';

p_custom_output.EXTEND;
p_custom_output(p_custom_output.COUNT) := l_custom_rec;

EXCEPTION
WHEN OTHERS THEN
NULL;
END GET_SQL;
END BIX_PMV_AO_CACENT_PRTLT_PKG;

/
