--------------------------------------------------------
--  DDL for Package Body BIX_PMV_AO_AGTDTL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_AO_AGTDTL_RPT_PKG" AS
/*$Header: bixoagdr.plb 115.6 2004/05/05 07:55:34 pubalasu noship $ */


PROCEDURE GET_SQL(p_page_parameter_tbl IN         BIS_PMV_PAGE_PARAMETER_TBL,
                  p_sql_text           OUT NOCOPY VARCHAR2,
                  p_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
                  )
AS
  l_sqltext            VARCHAR2(32000) ;
  l_where_clause       VARCHAR2(1000) ;


  l_as_of_date   DATE;
  l_period_type	varchar2(2000);
  l_comp_type    varchar2(2000);
  l_period_type_id   NUMBER := 1;
  l_call_center VARCHAR2(3000);
  l_campaign_id varchar2(3000);
  l_schedule_id varchar2(3000);
  l_source_code_id varchar2(3000);
  l_agent_group        VARCHAR2(3000);
  l_call_where_clause VARCHAR2(3000);
  l_session_where_clause VARCHAR2(3000);
     l_campaign_where_clause VARCHAR2(3000);
  l_source_code_where_clause VARCHAR2(3000);
  l_schedule_where_clause VARCHAR2(3000);
  l_view_by            VARCHAR2(3000);
  l_record_type_id NUMBER;

  l_unknown VARCHAR2(50);
  l_custom_rec         BIS_QUERY_ATTRIBUTES;

BEGIN

  /* Initialize the variables */
  p_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
  l_custom_rec    := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  l_where_clause  := NULL;
  l_call_center   := NULL;
  l_agent_group   := NULL;


l_unknown := FND_MESSAGE.GET_STRING('BIX','BIX_PMV_UNKNOWN');

IF l_unknown IS NULL OR l_unknown = 'BIX_PMV_UNKNOWN'
THEN
   l_unknown := 'Unknown';
END IF;

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
   l_call_where_clause := ' AND fact.server_group_id IN (:l_call_center) ';
END IF;
IF l_campaign_id IS NOT NULL THEN
   l_campaign_where_clause := ' AND fact.campaign_id IN (:l_campaign_id) ';
END IF;
IF l_schedule_id IS NOT NULL THEN
   l_schedule_where_clause := ' AND fact.schedule_id IN (:l_schedule_id) ';
END IF;
IF l_source_code_id IS NOT NULL THEN
      l_source_code_where_clause := ' AND fact.campaign_id in (select source_code_for_id from
   ams_source_codes where source_code_id IN (:l_source_code_id) and arc_source_code_for=''CAMP'' and active_flag=''Y'') ';

END IF;



  /* Agent Group where clause is not formed here as the table bix_call_details_f and bix_agent_session_f */
  /* have two different column names , resource_id and agent_id respectively , for the agent             */

l_sqltext :=
    'SELECT
        res.resource_name   BIX_PMV_AO_AGENT
      ,ROUND(SUM(NVL(fact.login,0))/3600, 1)   BIX_PMV_AO_LOGIN_CP
       ,ROUND(nvl((SUM(SUM(NVL(fact.login,0))) OVER())/3600,0), 1)     BIX_PMV_TOTAL1
       , ROUND(nvl(SUM(NVL(fact.login,0))*100/DECODE(SUM(SUM(fact.login)) OVER(),0,NULL,SUM(SUM(fact.login)) OVER()),0), 1)
	  BIX_PMV_AO_PERTOTAL1
        ,ROUND(SUM(NVL(fact.login,0) - NVL(fact.idle, 0)) /
            DECODE(SUM(NVL(fact.login,0)), 0, NULL, SUM(NVL(fact.login,0))) * 100, 1)
                      BIX_PMV_AO_AVAILRATE_CP
	   ,ROUND
		  (	sum( SUM(NVL(fact.login,0) - NVL(fact.idle, 0))) over() *100/
               DECODE(sum(SUM(NVL(fact.login,0))) over() , 0, NULL,
			   sum( SUM(NVL(fact.login,0))) over() )
			           ,1)
                      BIX_PMV_TOTAL2
       ,ROUND((SUM(NVL(fact.login,0) - NVL(fact.idle, 0)) /
            DECODE(SUM(NVL(fact.login,0)), 0, NULL, SUM(NVL(fact.login,0)))) * 100
            -
            AVG( (SUM(NVL(fact.login,0) - NVL(fact.idle, 0)))*100/
               DECODE(SUM(NVL(fact.login,0)) , 0, NULL,
			    SUM(NVL(fact.login,0))) ) OVER()
			       , 1) BIX_PMV_AO_AVAILRATE_VAR
       ,ROUND(
		    SUM( NVL(fact.login,0) - NVL(fact.idle, 0) - NVL(fact.available,0) ) /
               DECODE(SUM(fact.login), 0, NULL, SUM(fact.login))
			 * 100
	      , 1) BIX_PMV_AO_UTILRATE_CP
       , ROUND(
            SUM(SUM( NVL(fact.login,0)  - NVL(fact.idle, 0) - NVL(fact.available,0) )) over() *100
            /
            DECODE(SUM(SUM(fact.login)) over(), 0, NULL, SUM(SUM(fact.login)) over())
              	      , 1)
        BIX_PMV_TOTAL3
       ,ROUND(
       SUM( NVL(fact.login,0) - NVL(fact.idle, 0) - NVL(fact.available,0) )*100 /
               DECODE(SUM(fact.login), 0, NULL, SUM(fact.login))
		            -
            AVG(
            SUM( NVL(fact.login,0) - NVL(fact.idle, 0) - NVL(fact.available,0) )*100
            /
            DECODE(SUM(fact.login), 0, NULL, SUM(fact.login)) )
            over()
		         ,1) BIX_PMV_AO_UTILRATE_VAR
          ,SUM(NVL(fact.tot_calls,0))   BIX_PMV_AO_OUTCALLHAND_CP
       ,SUM(SUM(NVL(fact.tot_calls,0))) OVER()  BIX_PMV_TOTAL4
	  ,ROUND(SUM(fact.tot_calls)*100/decode(SUM(SUM(fact.tot_calls)) OVER(),0,null,SUM(SUM(fact.tot_calls)) OVER()),1)
	  BIX_PMV_AO_PERTOTAL2
        ,ROUND(SUM(NVL(fact.tot_calls,0)) /
            DECODE(SUM(NVL(fact.login,0))/3600, 0, NULL, SUM(NVL(fact.login,0))/3600), 1)
                      BIX_PMV_AO_OUTCALLHAND_PAH_CP
       ,ROUND(SUM(SUM(NVL(fact.tot_calls,0))) OVER() /
            DECODE(SUM(SUM(NVL(fact.login,0))) OVER()/3600, 0, NULL, SUM(SUM(NVL(fact.login,0))) OVER()/3600), 1)
                      BIX_PMV_TOTAL5
       ,ROUND(SUM(NVL(fact.tot_calls,0)) /
            DECODE(SUM(NVL(fact.login,0))/3600, 0, NULL, SUM(NVL(fact.login,0))/3600), 1) -
          ROUND(SUM(SUM(NVL(fact.tot_calls,0))) OVER() /
            DECODE(SUM(SUM(NVL(fact.login,0))) OVER()/3600, 0, NULL, SUM(SUM(NVL(fact.login,0))) OVER()/3600), 1)
                      BIX_PMV_AO_OUTCALLHAND_PAH_VAR
       ,ROUND(
       nvl(
       SUM(NVL(fact.talk,0)) /
            DECODE(SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) + NVL(fact.calls_tran_conf,0)
              + NVL(cont_calls_tc,0)), 0, NULL, SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) +
              NVL(fact.calls_tran_conf,0) + NVL(cont_calls_tc,0))),0), 1)
                      BIX_PMV_AO_AVGTALK_CP
       ,ROUND(nvl(
         SUM(SUM(NVL(fact.talk,0))) OVER()/
            DECODE(SUM(SUM(NVL(tot_calls,0) +
					  NVL(fact.cont_calls_hand,0)
                   )) OVER(), 0, NULL,
			    SUM(SUM(NVL(tot_calls,0) +
					  NVL(fact.cont_calls_hand,0)
			    )) OVER()),0), 1) BIX_PMV_TOTAL6
       ,ROUND(SUM(NVL(fact.talk,0)) /
            DECODE(SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) + NVL(fact.calls_tran_conf,0)
              + NVL(cont_calls_tc,0)), 0, NULL, SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) +
              NVL(fact.calls_tran_conf,0) + NVL(cont_calls_tc,0))) -
          SUM(SUM(NVL(fact.talk,0))) OVER() /
            DECODE(SUM(SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0)
            )) OVER(), 0, NULL, SUM(SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) )) OVER()), 1)
                      BIX_PMV_AO_AVGTALK_VAR
       ,ROUND(SUM(NVL(fact.wrap,0)) /
            DECODE(SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) + NVL(fact.calls_tran_conf,0)
            + NVL(cont_calls_tc,0)), 0, NULL, SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) +
            NVL(fact.calls_tran_conf,0) + NVL(cont_calls_tc,0))), 1)
                      BIX_PMV_AO_AVGWRAP_CP
       ,ROUND(SUM(SUM(NVL(fact.wrap,0))) OVER() /
            DECODE(SUM(SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0)
            )) OVER(), 0, NULL, SUM(SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) )) OVER()), 1)
                      BIX_PMV_TOTAL7
       ,ROUND(SUM(NVL(fact.wrap,0)) /
            DECODE(SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) + NVL(fact.calls_tran_conf,0)
            + NVL(cont_calls_tc,0)), 0, NULL, SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) +
            NVL(fact.calls_tran_conf,0) + NVL(cont_calls_tc,0))) -
          SUM(SUM(NVL(fact.wrap,0))) OVER() /
            DECODE(SUM(SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0)
            )) OVER(), 0, NULL, SUM(SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) )) OVER()), 1)
                      BIX_PMV_AO_AVGWRAP_VAR
                         ,SUM(NVL(fact.sr,0))
                      BIX_PMV_AO_SRCR_CP
       ,SUM(SUM(NVL(fact.sr,0))) OVER()
                      BIX_PMV_TOTAL8
,ROUND(nvl(SUM(NVL(fact.sr,0))*100/
DECODE(SUM(SUM(NVL(fact.sr,0))) OVER(),0,NULL,
       SUM(SUM(NVL(fact.sr,0))) OVER()),0),1) BIX_PMV_AO_PERTOTAL3
       ,SUM(NVL(fact.leads,0))
                      BIX_PMV_AO_LECR_CP
       ,SUM(SUM(NVL(fact.leads,0))) OVER()
                      BIX_PMV_TOTAL9
,ROUND(SUM(NVL(fact.leads,0))*100/
DECODE(SUM(SUM(NVL(fact.leads,0))) OVER(),0,NULL,
       SUM(SUM(NVL(fact.leads,0))) OVER()),1) BIX_PMV_AO_PERTOTAL4
       ,
       ROUND(SUM(nvl(fact.calls_tran_conf,0))/
       DECODE(SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) + NVL(fact.calls_tran_conf,0)
              + NVL(cont_calls_tc,0)),0,NULL,SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) +
NVL(fact.calls_tran_conf,0)
              + NVL(cont_calls_tc,0))
       ),1) BIX_PMV_AO_TRNSFR_CP
       , ROUND(AVG(SUM(nvl(fact.calls_tran_conf,0))/
       DECODE(SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) + NVL(fact.calls_tran_conf,0)
              + NVL(cont_calls_tc,0)),0,NULL,SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) +
NVL(fact.calls_tran_conf,0)
              + NVL(cont_calls_tc,0))
       )) OVER() ,1) BIX_PMV_TOTAL10
       ,  ROUND(SUM(nvl(fact.calls_tran_conf,0))/
       DECODE(SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) + NVL(fact.calls_tran_conf,0)
              + NVL(cont_calls_tc,0)),0,NULL,SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) +
NVL(fact.calls_tran_conf,0)
              + NVL(cont_calls_tc,0))
       )
       -
       AVG(SUM(nvl(fact.calls_tran_conf,0))/
       DECODE(SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) + NVL(fact.calls_tran_conf,0)
              + NVL(cont_calls_tc,0)),0,NULL,SUM(NVL(tot_calls,0) + NVL(fact.cont_calls_hand,0) +
NVL(fact.calls_tran_conf,0)
              + NVL(cont_calls_tc,0))
       )) OVER(),1)     BIX_PMV_AO_TRNSFR_VAR
       ,NVL(SUM(NVL(fact.oppr,0)),0) BIX_PMV_AO_OPCR_CP
       ,SUM(SUM(NVL(fact.oppr,0))) OVER()   BIX_PMV_TOTAL25
,ROUND(SUM(NVL(fact.oppr,0))*100/
DECODE(SUM(SUM(NVL(fact.oppr,0))) OVER(),0,NULL,
       SUM(SUM(NVL(fact.oppr,0))) OVER()),1) BIX_PMV_AO_PERTOTAL5
        FROM (
      SELECT
         fact.resource_id
                 agent_id
        ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,fact.agent_talk_time_nac))
                 talk
        ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,fact.call_talk_time))
                 calltalk
        ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,fact.agent_wrap_time_nac))
                 wrap
        ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,fact.agent_calls_handled_total))
                 tot_calls
           ,NULL    cont_calls_hand
        ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,fact.agent_calls_tran_conf_to_nac))
                 calls_tran_conf
        ,NULL    cont_calls_tc
        ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,fact.agent_leads_created))
                 leads
        ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,fact.agent_opportunities_created))
                 oppr
        ,SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,fact.agent_sr_created))
                 sr
        ,NULL    login
	   ,NULL    idle
        ,NULL    available
      FROM
        bix_ao_call_details_mv fact,
        fii_time_rpt_struct calendar
      WHERE fact.row_type = ''CR''
	 AND   fact.time_id = calendar.time_id
      AND   fact.period_type_id = calendar.period_type_id
      AND   calendar.report_date = &BIS_CURRENT_ASOF_DATE
      AND   bitand(calendar.record_type_id,&BIS_NESTED_PATTERN ) =  calendar.record_type_id ';

  l_sqltext := l_sqltext || l_call_where_clause ||l_source_code_where_clause;

  IF l_agent_group IS NOT NULL THEN
    l_sqltext := l_sqltext ||
                   ' AND EXISTS (
                       SELECT 1
                       FROM   jtf_rs_group_members mem
                       WHERE  fact.resource_id = mem.resource_id
                       AND    mem.group_id IN (:l_agent_group)
                       AND    nvl(mem.delete_flag, ''N'') <> ''Y'' )';
  END IF;

  l_sqltext := l_sqltext || '
    GROUP BY fact.resource_id
    UNION ALL
    SELECT
        fact.agent_id
              agent_id
      , NULL  talk
	 , NULL  calltalk
      , NULL  wrap
      , NULL  tot_calls
      , NULL  cont_calls_hand
      , NULL  calls_tran_conf
      , NULL  cont_calls_tc
      , NULL  leads
      , NULL  oppr
      , NULL  sr
      , SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,fact.login_time))
              login
      , SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,fact.idle_time))
              idle
      , SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,fact.available_time))
              available
    FROM
      bix_agent_session_f fact,
      fii_time_rpt_struct calendar
    WHERE fact.time_id = calendar.time_id
    AND   fact.application_id = 696
    AND   fact.period_type_id = calendar.period_type_id
    AND   calendar.report_date = &BIS_CURRENT_ASOF_DATE
    AND   bitand(calendar.record_type_id,&BIS_NESTED_PATTERN ) =  calendar.record_type_id ';

  l_sqltext := l_sqltext || l_call_where_clause ;

  IF l_agent_group IS NOT NULL THEN
    l_sqltext := l_sqltext ||
                   ' AND EXISTS (
                       SELECT 1
                       FROM   jtf_rs_group_members mem
                       WHERE  fact.agent_id = mem.resource_id
                       AND    mem.group_id IN (:l_agent_group)
                       AND    nvl(mem.delete_flag, ''N'') <> ''Y'' )';
  END IF;

  l_sqltext := l_sqltext || '
    GROUP BY fact.agent_id
    UNION ALL
    SELECT
        fact.resource_id
              agent_id
      , NULL  talk
	 , NULL  calltalk
      , NULL  wrap
       , NULL  tot_calls
      , SUM(fact.agent_cont_calls_hand_na)
              cont_calls_hand
      , NULL  calls_tran_conf
      , SUM(fact.agent_cont_calls_tc_na)
              cont_calls_tc
      , NULL  leads
      , NULL  oppr
      , NULL  sr
      , NULL  login
	 , NULL  idle
      , NULL  available
    FROM
      bix_ao_call_details_mv fact
    WHERE fact.row_type = ''CR''
    AND   fact.time_id = TO_NUMBER(TO_CHAR(&BIS_CURRENT_EFFECTIVE_START_DATE,''J''))
    AND   fact.period_type_id = 1 ';

  l_sqltext := l_sqltext || l_call_where_clause ||l_source_code_where_clause;

  IF l_agent_group IS NOT NULL THEN
    l_sqltext := l_sqltext ||
                   ' AND EXISTS (
                       SELECT 1
                       FROM   jtf_rs_group_members mem
                       WHERE  fact.resource_id = mem.resource_id
                       AND    mem.group_id IN (:l_agent_group)
                       AND    nvl(mem.delete_flag, ''N'') <> ''Y'' )';
  END IF;

  l_sqltext := l_sqltext || '
    GROUP BY fact.resource_id
  ) fact, jtf_rs_resource_extns_vl res
  WHERE fact.agent_id = res.resource_id
  GROUP BY res.resource_name &ORDER_BY_CLAUSE ';


  /* Before passing l_sqltext to the calling proc, we trim it up a bit */
l_sqltext:=replace(replace(replace(replace(replace(l_sqltext,
'      ',' '),'     ',' '),'    ',' '),'   ',' '),'  ',' ');

  p_sql_text := l_sqltext;

  p_custom_output.EXTEND();
  IF l_agent_group IS NOT NULL THEN
    l_custom_rec.attribute_name := ':l_agent_group' ;
    l_custom_rec.attribute_value:= l_agent_group;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

    p_custom_output.Extend();
    p_custom_output(p_custom_output.count) := l_custom_rec;
  END IF;

  IF l_call_center IS NOT NULL THEN
    l_custom_rec.attribute_name := ':l_call_center' ;
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
END  BIX_PMV_AO_AGTDTL_RPT_PKG;







/
