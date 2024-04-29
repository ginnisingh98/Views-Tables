--------------------------------------------------------
--  DDL for Package Body BIX_PMV_AI_CACENT_PRTLT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_AI_CACENT_PRTLT_PKG" AS
/*$Header: bixicenp.plb 115.11 2003/12/25 00:40:04 anasubra noship $ */

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
l_classification VARCHAR2(3000);
l_other_group VARCHAR2(30);
l_call_where_clause VARCHAR2(3000);
l_session_where_clause VARCHAR2(3000);
l_dnis VARCHAR2(3000);
l_unknown VARCHAR2(50);
l_view_by            VARCHAR2(3000);

l_custom_rec BIS_QUERY_ATTRIBUTES := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;

BEGIN
--
--Initialize p_custom_output
--
p_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

-- Get the parameters

BIX_PMV_DBI_UTL_PKG.get_ai_page_params( p_page_parameter_tbl,
                                         l_as_of_date,
                                         l_period_type,
                                         l_record_type_id,
                                         l_comp_type,
                                         l_call_center,
                                         l_classification,
                                         l_dnis,
								 l_view_by
                                      );

IF l_call_center IS NOT NULL THEN
   l_call_where_clause := ' AND mv.server_group_id IN (:l_call_center) ';
   l_session_where_clause := ' AND mv.server_group_id IN (:l_call_center) ';
END IF;

IF l_classification IS NOT NULL THEN
   l_call_where_clause := l_call_where_clause || ' AND mv.classification_value IN (:l_classification) ';
END IF;


IF l_dnis IS NOT NULL THEN
   IF l_dnis = '''INBOUND'''
   THEN
      l_call_where_clause := l_call_where_clause ||
	                        ' AND mv.dnis_name <> ''OUTBOUND'' ';
   ELSIF l_dnis = '''OUTBOUND'''
   THEN
      l_call_where_clause := l_call_where_clause ||
	                        ' AND mv.dnis_name = ''OUTBOUND'' ';
   ELSE
      l_call_where_clause := l_call_where_clause ||
	                        ' AND mv.dnis_name IN (:l_dnis) ';
   END IF;
END IF;
l_other_group := FND_MESSAGE.GET_STRING('BIX','BIX_PMV_ALLACCT');

IF l_other_group IS NULL OR l_other_group = 'BIX_PMV_ALLACCT'
THEN
   l_other_group := 'Others';
END IF;

l_unknown := FND_MESSAGE.GET_STRING('BIX','BIX_PMV_UNKNOWN');

IF l_unknown IS NULL OR l_unknown = 'BIX_PMV_UNKNOWN'
THEN
   l_unknown := 'Unknown';
END IF;

--insert into bixtest
--values ('l_period_type ' || l_period_type || ' l_comp_type ' || l_comp_type);
--commit;

   l_sqltext := '
            SELECT DECODE(greatest(RANKING,10),10,group_name,
		                   decode(group_name,:l_unknown,
                                    ''</a><nobr>''|| :l_unknown ||''</nobr><a href=#>'',
                                    ''</a><nobr>''|| :l_other_group ||''</nobr><a href=#>''
							 )
                         ) VIEWBY,
                 round(sum(in_ansgoal)*100/decode(sum(IN_OFFRD),0,NULL,sum(IN_OFFRD)),1) BIX_PMV_AI_SL,
                 round(sum(sum(in_ansgoal)) over()*100/
                 decode(sum(sum(IN_OFFRD)) over(),0,NULL,sum(sum(IN_OFFRD)) over()),1) BIX_PMV_TOTAL1,
                 sum(in_fresh_hand) BIX_PMV_AI_INCALLHAND,
                 sum(sum(in_fresh_hand)) over() BIX_PMV_TOTAL2,
                 round(sum(IN_QTOANS)/
                 decode(sum(in_hand),0,NULL,sum(in_hand)),1) BIX_PMV_AI_SPANS,
                 round(sum(sum(IN_QTOANS)) over()/
                 decode(sum(sum(in_hand)) over(),0,NULL,sum(sum(in_hand)) over()),1) BIX_PMV_TOTAL3,
                 round(sum(IN_ABAND)*100/
                 decode(sum(IN_OFFRD),0,NULL,sum(IN_OFFRD)),1) BIX_PMV_AI_ABANRATE,
                 round(sum(sum(IN_ABAND)) over()*100/
                 decode(sum(sum(IN_OFFRD)) over(),0,NULL,sum(sum(IN_OFFRD)) over()),1) BIX_PMV_TOTAL4,
                 round(sum(talk)/
                 decode(sum(hand),0,NULL,sum(hand)),1) BIX_PMV_AI_AVGTALK,
                 round(sum(sum(talk)) over()/
                 decode(sum(sum(hand)) over(),0,NULL,sum(sum(hand)) over()),1) BIX_PMV_TOTAL5,
                 sum(sr) BIX_PMV_AI_SRCR,
                 sum(sum(sr)) over() BIX_PMV_TOTAL6,
                 sum(lead) BIX_PMV_AI_LECR,
                 sum(sum(lead)) over() BIX_PMV_TOTAL7 ,
			  sum(opp) BIX_PMV_AI_OPCR,
			  sum(sum(opp)) over() BIX_PMV_TOTAL8
             FROM
             (
             --
             --Additional inline view needed to compute RANK due to continued measures
             --
            SELECT nvl(group_name,:l_unknown) group_name,
                   nvl(sum(IN_OFFRD),0) IN_OFFRD, nvl(sum(in_ansgoal),0) in_ansgoal, nvl(sum(in_hand),0) in_hand,
			    nvl(sum(IN_FRESH_HAND),0) IN_FRESH_HAND,
                   nvl(sum(hand),0) hand, nvl(sum(IN_QTOANS),0) IN_QTOANS, nvl(sum(IN_ABAND),0) IN_ABAND,
                   nvl(sum(talk),0) talk, nvl(sum(sr),0) sr, nvl(sum(lead),0) lead, nvl(sum(opp),0) opp,
			    decode(group_name,NULL,11,
                             RANK() OVER (ORDER BY nvl(sum(in_fresh_hand),0) DESC, group_name)
				      ) RANKING
            FROM
               (
             SELECT server_group_id server_group_id,
                    sum(decode(mv.media_item_type,
                               ''TELE_INB'',CALL_CALLS_OFFERED_TOTAL,
                               ''TELE_DIRECT'',CALL_CALLS_OFFERED_TOTAL,
                               0)
                       ) IN_OFFRD,
                    sum(decode(mv.media_item_type,
                               ''TELE_INB'',AGENT_CALLS_ANSWERED_BY_GOAL,
                               ''TELE_DIRECT'',AGENT_CALLS_ANSWERED_BY_GOAL,
                               0)
                       ) IN_ANSGOAL,
                    sum(decode(mv.media_item_type,
                               ''TELE_INB'',AGENT_CALLS_HANDLED_TOTAL,
                               ''TELE_DIRECT'',AGENT_CALLS_HANDLED_TOTAL,
                               0)
                       ) IN_HAND,
                    sum(decode(mv.media_item_type,
                               ''TELE_INB'',AGENT_CALLS_HANDLED_TOTAL,
                               ''TELE_DIRECT'',AGENT_CALLS_HANDLED_TOTAL,
                               0)
                       ) IN_FRESH_HAND,
                    sum(AGENT_CALLS_HANDLED_TOTAL) HAND,
                    sum(decode(mv.media_item_type,
                               ''TELE_INB'',CALL_TOT_QUEUE_TO_ANSWER,
                               ''TELE_DIRECT'',CALL_TOT_QUEUE_TO_ANSWER,
                               0)
                       ) IN_QTOANS,
                    sum(decode(mv.media_item_type,
                               ''TELE_INB'',CALL_CALLS_ABANDONED,
                               ''TELE_DIRECT'',CALL_CALLS_ABANDONED,
                               0)
                       ) IN_ABAND,
                    sum(CALL_TALK_TIME) TALK,
                    sum(AGENT_SR_CREATED) SR,
                    sum(AGENT_LEADS_CREATED) LEAD,
                    sum(AGENT_OPPORTUNITIES_CREATED) OPP
              FROM bix_ai_call_details_mv mv,
                   fii_time_rpt_struct cal
              WHERE mv.time_id        = cal.time_id
		    AND mv.row_type = :l_row_type
              AND   mv.period_type_id = cal.period_type_id
              AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN) =
                                        cal.record_type_id
              AND cal.report_date = &BIS_CURRENT_ASOF_DATE ';

l_sqltext := l_sqltext || l_call_where_clause ||
             '
		    GROUP BY mv.server_group_id
              UNION ALL
              SELECT server_group_id server_group_id,
                    nvl(sum(decode(mv.media_item_type,
                               ''TELE_INB'',CALL_CONT_CALLS_OFFERED_NA,
                               ''TELE_DIRECT'', CALL_CONT_CALLS_OFFERED_NA,
                               0)
                       ),0) IN_OFFRD,
                    0 IN_ANSGOAL,
                    nvl(sum(decode(mv.media_item_type,
                               ''TELE_INB'',AGENT_CONT_CALLS_HAND_NA,
                               ''TELE_DIRECT'', AGENT_CONT_CALLS_HAND_NA,
                               0)
                       ),0) IN_HAND,
                    0 IN_FRESH_HAND,
                    nvl(sum(AGENT_CONT_CALLS_HAND_NA),0) HAND,
                    0 IN_QTOANS,
                    0 IN_ABAND,
                    0 TALK,
                    0 SR,
                    0 LEAD,
				0 OPP
              FROM bix_ai_call_details_mv mv
              WHERE mv.time_id = to_char(&BIS_CURRENT_EFFECTIVE_START_DATE,''J'')
		    AND mv.row_type = :l_row_type
              AND   mv.period_type_id = :l_period_type_id
              AND period_start_time = :l_period_start_time ';

l_sqltext := l_sqltext || l_call_where_clause ||
             '
		    GROUP BY mv.server_group_id
               ) summ,
                 IEO_SVR_GROUPS SG
                 WHERE sg.server_group_id (+) = summ.server_group_id
                 GROUP BY group_name
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

p_custom_sql := l_sqltext;

l_custom_rec.attribute_name := ':l_row_type';
l_custom_rec.attribute_value:= 'CDR';
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

IF l_classification IS NOT NULL
THEN
l_custom_rec.attribute_name := ':l_classification';
l_custom_rec.attribute_value:= l_classification;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

p_custom_output.EXTEND;
p_custom_output(p_custom_output.COUNT) := l_custom_rec;
END IF;

IF l_dnis IS NOT NULL AND l_dnis NOT IN ('INBOUND','OUTBOUND')
THEN
   l_custom_rec.attribute_name := ':l_dnis';
   l_custom_rec.attribute_value:= l_dnis;
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

l_custom_rec.attribute_name := ':l_period_start_time';
l_custom_rec.attribute_value:= '00:00';
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

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
l_sql_errm := SQLERRM;
--insert into bixtest values (l_sql_errm);
--commit;
NULL;
END GET_SQL;
END BIX_PMV_AI_CACENT_PRTLT_PKG;

/
