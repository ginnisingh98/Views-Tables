--------------------------------------------------------
--  DDL for Package Body BIX_PMV_AO_TELDTL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_AO_TELDTL_RPT_PKG" AS
/*$Header: bixotelr.plb 115.20 2004/05/04 11:11:23 pubalasu noship $ */


PROCEDURE GET_SQL(p_page_parameter_tbl IN         BIS_PMV_PAGE_PARAMETER_TBL,
                  p_sql_text           OUT NOCOPY VARCHAR2,
                  p_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
                  )
AS
  l_sqltext            VARCHAR2(32000) ;
  l_where_clause       VARCHAR2(1000) ;

  l_call_center        VARCHAR2(3000);
  l_view_by            VARCHAR2(3000);
  l_unknown            VARCHAR2(3000);
  l_column_name        VARCHAR2(1000);

  l_custom_rec         BIS_QUERY_ATTRIBUTES;
    --added for campaign, schedule and source code
  l_campaign_id       varchar2(3000);
  l_schedule_id       varchar2(3000);
  l_source_code_id    varchar2(3000);
  l_campaign_where_clause VARCHAR2(3000);
  l_call_where_clause VARCHAR2(3000);
  l_schedule_where_clause VARCHAR2(3000);
  l_source_code_where_clause VARCHAR2(3000);
  l_agent_group varchar2(3000);
  l_sess_source_where_clause VARCHAR2(3000);
  l_as_of_date   DATE;
  l_period_type	varchar2(2000);
  l_comp_type    varchar2(2000);
  l_record_type_id NUMBER;

BEGIN
  /* Initialize p_custom_output and l_custom_rec */
  p_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;

  l_where_clause   := NULL;
  l_call_center    := NULL;
  l_view_by        := NULL;
  l_column_name    := NULL;

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
   l_call_where_clause := ' AND server_group_id IN (:l_call_center) ';
END IF;

IF l_campaign_id IS NOT NULL THEN
   l_campaign_where_clause := ' AND mv.campaign_id IN (:l_campaign_id) ';
END IF;
IF l_schedule_id IS NOT NULL THEN
   l_schedule_where_clause := ' AND mv.schedule_id IN (:l_schedule_id) ';
END IF;
IF l_source_code_id IS NOT NULL THEN
   l_source_code_where_clause := ' AND campaign_id in (select source_code_for_id from
   ams_source_codes where source_code_id IN (:l_source_code_id) and arc_source_code_for=''CAMP'' and active_flag=''Y'')  ';

END IF;

l_where_clause:=l_call_where_clause||l_source_code_where_clause;

l_unknown := FND_MESSAGE.GET_STRING('BIX','BIX_PMV_UNKNOWN');

IF l_unknown IS NULL OR l_unknown = 'BIX_PMV_UNKNOWN'
THEN
   l_unknown := 'Unknown';
END IF;


  IF l_view_by = 'CAMPAIGN+CAMPAIGN' THEN

  l_sqltext:=' select VIEWBY,VIEWBYID,ROUND(i / g1 * 100, 1)
 BIX_PMV_AO_ABANRATE_CP
 ,ROUND(SUM(i) OVER() / SUM(g1) OVER() * 100, 1)
 BIX_PMV_TOTAL1
 ,ROUND((i / g1 * 100) - (j / h1 * 100), 1)
 BIX_PMV_AO_ABANRATE_CG
 ,ROUND(SUM(i) OVER() / SUM(g1) OVER() * 100 - SUM(j) OVER() / SUM(h1) OVER() * 100, 1)
 BIX_PMV_TOTAL2
 ,ROUND(j / h1 * 100, 1)
 BIX_PMV_AO_ABANRATE_PP
 /* Added for US Abandon Rate */
 ,ROUND(ius / g1 * 100, 1)
 BIX_PMV_AO_US_ABANRATE_CP
 ,ROUND(SUM(ius) OVER() / SUM(g1) OVER() * 100, 1)
 BIX_PMV_TOTAL25
 ,ROUND((ius / g1 * 100) - (jus / h1 * 100), 1)
 BIX_PMV_AO_US_ABANRATE_CG
 ,ROUND(SUM(ius) OVER() / SUM(g1) OVER() * 100 - SUM(jus) OVER() / SUM(h1) OVER() * 100, 1)
 BIX_PMV_TOTAL26
 ,ROUND(jus / h1 * 100, 1)
 BIX_PMV_AO_US_ABANRATE_PP
 /* End of Additions */
 ,nvl(m,0) BIX_PMV_AO_OUTCALLHAND_CP
 ,nvl(SUM(m) OVER() ,0)
	 BIX_PMV_TOTAL3
 ,ROUND((m - n) / DECODE(n, 0, NULL, n) * 100, 1)
 BIX_PMV_AO_OUTCALLHAND_CG
 ,ROUND((SUM(m) OVER() - SUM(n) OVER()) / DECODE(SUM(n) OVER(), 0, NULL, SUM(n) OVER()) * 100, 1)
 BIX_PMV_TOTAL4
 ,nvl(n,0) BIX_PMV_AO_OUTCALLHAND_PP
 ,ROUND(u / q, 1) BIX_PMV_AO_AVGTALK_CP
 ,ROUND(SUM(u) OVER() / SUM(q) OVER(), 1)
 BIX_PMV_TOTAL5
 ,ROUND(((u / q) - (v / r)) / DECODE(v / r, 0, NULL, v / r) * 100 , 1)
 BIX_PMV_AO_AVGTALK_CG
 ,ROUND((SUM(u) OVER() / SUM(q) OVER() - SUM(v) OVER() / SUM(r) OVER()) /
	 DECODE(SUM(v) OVER() / SUM(r) OVER(), 0, NULL, SUM(v) OVER() / SUM(r) OVER()) * 100 , 1)
 BIX_PMV_TOTAL6
 ,ROUND(v / r, 1) BIX_PMV_AO_AVGTALK_PP
 ,ROUND(s / q, 1) BIX_PMV_AO_AVGWRAP_CP
 ,ROUND(SUM(s) OVER() / SUM(q) OVER(), 1)
 BIX_PMV_TOTAL7
 ,ROUND(((s / q) - (t / r)) / DECODE(t / r, 0, NULL, t / r) * 100, 1)
 BIX_PMV_AO_AVGWRAP_CG
 ,ROUND((SUM(s) OVER() / SUM(q) OVER() - SUM(t) OVER() / SUM(r) OVER()) /
	 DECODE(SUM(t) OVER() / SUM(r) OVER(), 0, NULL, SUM(t) OVER() / SUM(r) OVER()) * 100, 1)
 BIX_PMV_TOTAL8
 ,w BIX_PMV_AO_SRCR_CP
 ,SUM(w) OVER() BIX_PMV_TOTAL9
 ,ROUND((w - x) / DECODE(x, 0, NULL, x) * 100, 1)
 BIX_PMV_AO_SRCR_CG
 ,ROUND((SUM(w) OVER() - SUM(x) OVER()) / DECODE(SUM(x) OVER(), 0, NULL, SUM(x) OVER()) * 100, 1)
 BIX_PMV_TOTAL10
 ,y BIX_PMV_AO_LECR_CP
 ,SUM(y) OVER() BIX_PMV_TOTAL11
 ,ROUND((y - z) / DECODE(z, 0, NULL, z) * 100, 1)
 BIX_PMV_AO_LECR_CG
 ,ROUND((SUM(y) OVER() - SUM(z) OVER()) / DECODE(SUM(z) OVER(), 0, NULL, SUM(z) OVER()) * 100, 1)
 BIX_PMV_TOTAL12
 ,y1 BIX_PMV_AO_OPCR_CP
 ,SUM(y1) OVER() BIX_PMV_TOTAL13
 ,ROUND((y1 - z1) / DECODE(z1, 0, NULL, z1) * 100, 1)
 BIX_PMV_AO_OPCR_CG
 ,ROUND((SUM(y1) OVER() - SUM(z1) OVER()) / DECODE(SUM(z1) OVER(), 0, NULL, SUM(z1) OVER()) * 100, 1)
 BIX_PMV_TOTAL14
 ,a1 BIX_PMV_AO_CUST_CP
 ,a9 BIX_PMV_TOTAL15
 ,ROUND((a1 - a2) / DECODE(a2, 0, null, a2) * 100, 1)
 BIX_PMV_AO_CUST_CG
 ,ROUND((a9 - a10) / DECODE(a10, 0, NULL, a10) * 100, 1)
 BIX_PMV_TOTAL16
 ,ROUND(
 (NVL(loginc,0) - NVL(idlec, 0)) /
 DECODE(loginc, 0, NULL, loginc) * 100, 1)
 BIX_PMV_AO_AVAILRATE_CP
 ,ROUND(
 SUM(NVL(loginc,0) - NVL(idlec, 0)) OVER() /
 DECODE(SUM(loginc) OVER(), 0, NULL, SUM(loginc) OVER() )* 100, 1)
 BIX_PMV_TOTAL17
 ,ROUND(
 (NVL(loginc,0) - NVL(idlec, 0)) /
 DECODE(loginc, 0, NULL, loginc) * 100
 -
 (NVL(loginp,0) - NVL(idlep, 0)) /
 DECODE(loginp, 0, NULL, loginp) * 100
 , 1)
 BIX_PMV_AO_AVAILRATE_CG
 ,ROUND(
 sum(NVL(loginc,0) - NVL(idlec, 0)) over() /
 DECODE(sum(loginc) over(), 0, NULL, sum(loginc) over() ) * 100
 -
 sum(NVL(loginp,0) - NVL(idlep, 0)) over() /
 DECODE(sum(loginp) over(), 0, NULL, sum(loginp)over()) * 100
 , 1)
 BIX_PMV_TOTAL18
 ,ROUND(
 (NVL(loginc,0) - NVL(idlec, 0)-nvl(availc,0)) /
 DECODE(loginc, 0, NULL, loginc) * 100, 1) BIX_PMV_AO_UTILRATE_CP
 ,ROUND(
 SUM(NVL(loginc,0) - NVL(idlec, 0)-nvl(availc,0)) OVER() /
 DECODE(SUM(loginc) OVER(), 0, NULL, SUM(loginc) OVER() )* 100, 1)
 BIX_PMV_TOTAL19
 ,ROUND(
 (NVL(loginc,0) - NVL(idlec, 0)-nvl(availc,0)) /
 DECODE(loginc, 0, NULL, loginc) * 100
 -
 (NVL(loginp,0) - NVL(idlep, 0)-nvl(availp,0)) /
 DECODE(loginp, 0, NULL, loginp) * 100
 , 1)
 BIX_PMV_AO_UTILRATE_CG
 ,
 ROUND(
 sum(NVL(loginc,0) - NVL(idlec, 0)-nvl(availc,0)) over() /
 DECODE(sum(loginc) over(), 0, NULL, sum(loginc) over() ) * 100
 -
 sum(NVL(loginp,0) - NVL(idlep, 0)-nvl(availp,0)) over() /
 DECODE(sum(loginp) over(), 0, NULL, sum(loginp)over()) * 100
 , 1) BIX_PMV_TOTAL20
 ,nvl(prC,0) BIX_PMV_AO_PORESP_CP
 ,sum(nvl(prc,0)) OVER() BIX_PMV_TOTAL21
 /* ,nvl(PRC,0)-NVL(PRP,0) BIX_PMV_AO_PORESP_CG
 ,SUM(nvl(PRC,0)-NVL(PRP,0)) OVER() BIX_PMV_TOTAL22
 */
 ,(nvl(PRC,0)-NVL(PRP,0))*100/decode(prp,0,null,prp) BIX_PMV_AO_PORESP_CG
 ,sum(nvl(PRC,0)-NVL(PRP,0)) over()*100/sum(decode(prp,0,null,prp)) over() BIX_PMV_TOTAL22
 ,nvl(PRp,0) BIX_PMV_AO_PORESP_PP
 ,contc/(decode(loginc,0,null,loginc)/3600) BIX_PMV_AO_CONTPERHR_CP , sum(nvl(contc,0)) over() /(decode(loginc ,0,null,loginc)/3600) BIX_PMV_TOTAL23
 , (contc/decode(loginc,0,NULL,loginc) -contp/decode(loginp,0,null,loginp))*100/decode(contp/decode(loginp,0,null,loginp),0,null,contp/decode(loginp,0,null,loginp)) BIX_PMV_AO_CONTPERHR_CG
 ,(sum(contc) over()/decode(loginc,0,null,loginc) - sum(contp) over()/decode(loginp,0,null,loginp))*100/decode(sum(contp) over()/decode(loginp,0,null,loginp),0,null,sum(contp) over()/decode(loginp,0,null,loginp) ) BIX_PMV_TOTAL24
 ,contp/(decode(loginp,0,null,loginp)/3600) BIX_PMV_AO_CONTPERHR_PP
 FROM (
 /* First level inline view */
 SELECT decode(campmast.value,null, :l_unknown ,campmast.value) VIEWBY
 ,nvl(campmast.id,-1) VIEWBYID
 ,DECODE(SUM(c), 0, NULL, SUM(c)) c
 ,DECODE(SUM(d), 0, NULL, SUM(d)) d
 ,DECODE(SUM(g), 0, NULL, SUM(g)) g
 ,DECODE(SUM(h), 0, NULL, SUM(h)) h
 ,SUM(NVL(i,0)) i
 ,SUM(NVL(j,0)) j
 /* Added for US Abandonment rate */
 ,SUM(NVL(ius,0)) ius
 ,SUM(NVL(jus,0)) jus
 /* End of addition */
 ,SUM(NVL(k,0)) k
 ,SUM(NVL(l,0)) l
	 ,DECODE(SUM(m), 0, NULL, SUM(m)) m
	 ,DECODE(SUM(n), 0, NULL, SUM(n)) n
 ,SUM(NVL(s,0)) s
 ,SUM(NVL(t,0)) t
 ,SUM(NVL(u,0)) u
 ,SUM(NVL(v,0)) v
 ,SUM(NVL(w,0)) w
 ,SUM(NVL(x,0)) x
 ,SUM(NVL(y,0)) y
 ,SUM(NVL(z,0)) z
 ,SUM(NVL(y1,0)) y1
 ,SUM(NVL(z1,0)) z1
 ,sum(a1) a1
 ,sum(a2) a2
 ,MIN(a9) a9
 ,MIN(a10) a10
 ,SUM(q) q
 ,sum ( r ) r
 ,sum(g1) g1
 ,sum(h1) h1 ,
 min(sourcecode) sourcecode
 ,min(loginp) loginp
 ,min(loginc) loginc
 ,min(idlep) idlep
 ,min(idlec) idlec
 ,min(availp) availp
 ,min(availc ) availc
 ,sum(nvl(prp,0) ) prp
 ,sum(nvl(prc,0)) prc
 ,sum(nvl(contp,0)) contp
 ,sum(nvl(contc,0)) contc
	 FROM (
	 /* Added this for eliminating campaign id with -999 */
	 SELECT campaign_id
 ,DECODE(SUM(c), 0, NULL, SUM(c)) c
 ,DECODE(SUM(d), 0, NULL, SUM(d)) d
 ,DECODE(SUM(g), 0, NULL, SUM(g)) g
 ,DECODE(SUM(h), 0, NULL, SUM(h)) h
 ,SUM(NVL(i,0)) i
 ,SUM(NVL(j,0)) j
 /* Added for US Abandonment rate */
 ,SUM(NVL(ius,0)) ius
 ,SUM(NVL(jus,0)) jus
 /* End of addition */
 ,SUM(NVL(k,0)) k
 ,SUM(NVL(l,0)) l
	 ,DECODE(SUM(m), 0, NULL, SUM(m)) m
	 ,DECODE(SUM(n), 0, NULL, SUM(n)) n
 ,SUM(NVL(s,0)) s
 ,SUM(NVL(t,0)) t
 ,SUM(NVL(u,0)) u
 ,SUM(NVL(v,0)) v
 ,SUM(NVL(w,0)) w
 ,SUM(NVL(x,0)) x
 ,SUM(NVL(y,0)) y
 ,SUM(NVL(z,0)) z
 ,SUM(NVL(y1,0)) y1
 ,SUM(NVL(z1,0)) z1
 ,COUNT(DISTINCT(CASE WHEN report_date = &BIS_CURRENT_ASOF_DATE
 AND party_id <> -1
 THEN PARTY_ID END ))
 a1
 ,COUNT(DISTINCT(CASE WHEN report_date = &BIS_PREVIOUS_ASOF_DATE
 AND party_id <> -1
 THEN PARTY_ID END ))
 a2
 ,MIN(a9) a9
 ,MIN(a10) a10
 ,DECODE(SUM(NVL(m,0) + NVL(a3,0)), 0, NULL, SUM(NVL(m,0) + NVL(a3,0))) q
 ,DECODE(SUM(NVL(n,0) + NVL(a4,0)), 0, NULL, SUM(NVL(n,0) + NVL(a4,0))) r
 ,DECODE(SUM(NVL(g,0) + NVL(a7,0)), 0, NULL, SUM(NVL(g,0) + NVL(a7,0))) g1
 ,DECODE(SUM(NVL(h,0) + NVL(a8,0)), 0, NULL, SUM(NVL(h,0) + NVL(a8,0))) h1 ,min(sourcecode) sourcecode
 ,sum(sum(nvl(loginp,0))) over( ) loginp
 ,sum(sum(nvl(loginc,0))) over( ) loginc
 ,sum(sum(nvl(idlep,0))) over( ) idlep
 ,sum(sum(nvl(idlec,0))) over( ) idlec
	 ,sum(sum(nvl(availp,0))) over() availp
 ,sum(sum(nvl(availc,0))) over() availc
 ,sum(nvl(prp,0) ) prp
 ,sum(nvl(prc,0)) prc
 ,sum(nvl(contp,0)) contp
 ,sum(nvl(contc,0)) contc
	from
	 (
	 /* START OF UNION ALL CLAUSES - INNER MOST QUERY */
 SELECT
 campaign_id
 ,source_code_id sourcecode
 ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,agent_calls_handled_total, 0)
 c
 ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,agent_calls_handled_total, 0)
 d
 ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,
 decode(dialing_method,''PRED'',call_calls_offered_total,0),0)
 g
 ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,decode(dialing_method,''PRED'',call_calls_offered_total,0), 0)
 h
 ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,decode(dialing_method,''PRED'',call_calls_abandoned,0), 0)
 i
 ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,decode(dialing_method,''PRED'',call_calls_abandoned,0), 0)
 j
 /* Added for US Abandon rate */
 ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,decode(dialing_method,''PRED'',call_calls_abandoned_us,0), 0)
 ius
 ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,decode(dialing_method,''PRED'',call_calls_abandoned_us,0), 0)
 jus
/* End of additions */
 ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,call_calls_transferred, 0)
 k
 ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,call_calls_transferred, 0)
 l
 ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,call_calls_handled_total, 0)
 m
 ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,call_calls_handled_total, 0)
 n
 ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,agent_wrap_time_nac)
 s
 ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,agent_wrap_time_nac)
 t
 ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,call_talk_time)
 u
 ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,call_talk_time)
 v
 ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,agent_sr_created)
 w
 ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,agent_sr_created)
 x
 ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,agent_leads_created)
 y
 ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,agent_leads_created)
 z
 ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,agent_opportunities_created)
 y1
 ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,agent_opportunities_created)
 z1
 ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,agentcall_pr_count)
 prc
 ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,agentcall_pr_count)
 prp
 ,party_id party_id
	 ,calendar.report_date report_date
 ,NULL a3
 ,NULL a4
	,NULL a7
	 ,NULL a8
 ,COUNT(DISTINCT(CASE WHEN calendar.report_date = &BIS_CURRENT_ASOF_DATE
 AND party_id <> -1
 THEN PARTY_ID END )) OVER()
 a9
 ,COUNT(DISTINCT(CASE WHEN calendar.report_date = &BIS_PREVIOUS_ASOF_DATE
 AND party_id <> -1
 THEN PARTY_ID END )) OVER()
 a10
 ,0 loginp
 ,0 loginc
 ,0 idlep
 ,0 idlec
 ,0 availp
 ,0 availc
 ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,agentcall_contact_count)
 contp
 ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,agentcall_contact_count)
 contc
 FROM
 bix_ao_call_details_mv a,
 fii_time_rpt_struct calendar
 WHERE a.row_type = ''C''
 AND a.time_id = calendar.time_id
 AND a.period_type_id = calendar.period_type_id
 AND calendar.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
 AND bitand(calendar.record_type_id,&BIS_NESTED_PATTERN ) = calendar.record_type_id
     '||l_where_clause||' union all
 /* continue inline view and select session measures */
 SELECT -999
 ,-999 sourcecode
 ,NULL c
 ,NULL d
 ,NULL g
 ,NULL h
 ,NULL i
 ,NULL j
 /* Added for US abandon measure */
 ,NULL ius
 ,NULL jus
 /* End of addition */
 ,NULL k
 ,NULL l
 ,NULL m
 ,NULL n
 ,NULL s
 ,NULL t
 ,NULL u
 ,NULL v
 ,NULL w
 ,NULL x
 ,NULL y
 ,NULL z
 ,NULL y1
 ,NULL z1
 ,0 prc
 ,0 prp
	 ,NULL party_id
	 ,NULL report_date
 ,0 a3
 ,0 a4
 ,0 a7
 ,0 a8
 ,0 a9
 ,0 a10
 , SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,login_time))
 loginp
 , SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,login_time))
 loginc
 , SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,idle_time))
 idlep
 , SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,idle_time))
 idlec
 , SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,available_time))
 availp
 , SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,available_time))
 availc
 , 0 contp
 ,0 contc
 FROM
 bix_agent_session_f fact,
 fii_time_rpt_struct calendar
 WHERE fact.time_id = calendar.time_id
 AND fact.application_id = 696
 AND fact.period_type_id = calendar.period_type_id
 AND calendar.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
 AND
 bitand(calendar.record_type_id,&BIS_NESTED_PATTERN ) = calendar.record_type_id
  '||l_call_where_clause ||'
group by campaign_id
 UNION ALL
 /*Continue inline view select continued measures */
 SELECT campaign_id
 ,source_code_id sourcecode
 ,NULL c
 ,NULL d
 ,NULL g
 ,NULL h
 ,NULL i
 /* Added for US abandon measure */
 ,NULL ius
 ,NULL j
 ,NULL jus
 /* End of addition */
 ,NULL k
 ,NULL l
 ,NULL m
 ,NULL n
 ,NULL s
 ,NULL t
 ,NULL u
 ,NULL v
 ,NULL w
 ,NULL x
 ,NULL y
 ,NULL z
 ,NULL y1
 ,NULL z1
 ,0 prc
 ,0 prp
	 ,NULL party_id
	 ,NULL report_date
 ,DECODE(time_id,TO_NUMBER(TO_CHAR(&BIS_CURRENT_EFFECTIVE_START_DATE,''J'')),call_cont_calls_handled_tot_na)
 a3
 ,DECODE(time_id,TO_NUMBER(TO_CHAR(&BIS_PREVIOUS_EFFECTIVE_START_DATE,''J'')),call_cont_calls_handled_tot_na)
 a4
 ,DECODE(time_id,TO_NUMBER(TO_CHAR(&BIS_CURRENT_EFFECTIVE_START_DATE,''J'')), decode(dialing_method,''PRED'',call_cont_calls_offered_na,0), 0)
 a7
 ,DECODE(time_id,TO_NUMBER(TO_CHAR(&BIS_PREVIOUS_EFFECTIVE_START_DATE,''J'')),decode(dialing_method,''PRED'',call_cont_calls_offered_na,0), 0)
 a8
 ,NULL a9
 ,NULL a10
 ,0 loginp
 ,0 loginc
 ,0 idlep
 ,0 idlec
 ,0 availp
 ,0 availc
 ,0 contp
 ,0 contc
 FROM
 bix_ao_call_details_mv a
 WHERE row_type = ''C''
 AND time_id IN (TO_NUMBER(TO_CHAR(&BIS_CURRENT_EFFECTIVE_START_DATE,''J'')),
 TO_NUMBER(TO_CHAR(&BIS_PREVIOUS_EFFECTIVE_START_DATE,''J'')))
 AND period_type_id = 1     '||l_where_clause||'
 )
 group by campaign_id
 ) a ,( select source_code_for_id,camp.id id,camp.value value from bim_dimv_campaigns camp,ams_source_codes scodes
			 where scodes.source_code_id=camp.id and
			 arc_source_code_for=:l_camp and active_flag=''Y'' ) campmast
			 where a.campaign_id=campmast.source_code_for_id(+)
			 and a.campaign_id<>-999
 group by campmast.value,campmast.id
 )

 &ORDER_BY_CLAUSE';
  ELSIF l_view_by = 'BIX_TELEPHONY+BIX_CALL_CENTER' THEN
  l_sqltext:='
   select VIEWBY,VIEWBYID,ROUND(i / g1 * 100, 1)
 BIX_PMV_AO_ABANRATE_CP
 ,ROUND(SUM(i) OVER() / SUM(g1) OVER() * 100, 1)
 BIX_PMV_TOTAL1
 ,ROUND((i / g1 * 100) - (j / h1 * 100), 1)
 BIX_PMV_AO_ABANRATE_CG
 ,ROUND(SUM(i) OVER() / SUM(g1) OVER() * 100 - SUM(j) OVER() / SUM(h1) OVER() * 100, 1)
 BIX_PMV_TOTAL2
 ,ROUND(j / h1 * 100, 1)
 BIX_PMV_AO_ABANRATE_PP
 /* Added for US Abandon Rate */
 ,ROUND(ius / g1 * 100, 1)
 BIX_PMV_AO_US_ABANRATE_CP
 ,ROUND(SUM(ius) OVER() / SUM(g1) OVER() * 100, 1)
 BIX_PMV_TOTAL25
 ,ROUND((ius / g1 * 100) - (jus / h1 * 100), 1)
 BIX_PMV_AO_US_ABANRATE_CG
 ,ROUND(SUM(ius) OVER() / SUM(g1) OVER() * 100 - SUM(jus) OVER() / SUM(h1) OVER() * 100, 1)
 BIX_PMV_TOTAL26
 ,ROUND(jus / h1 * 100, 1)
 BIX_PMV_AO_US_ABANRATE_PP
 /* End of Additions */
 ,nvl(m,0) BIX_PMV_AO_OUTCALLHAND_CP
 ,nvl(SUM(m) OVER() ,0)
	 BIX_PMV_TOTAL3
 ,ROUND((m - n) / DECODE(n, 0, NULL, n) * 100, 1)
 BIX_PMV_AO_OUTCALLHAND_CG
 ,ROUND((SUM(m) OVER() - SUM(n) OVER()) / DECODE(SUM(n) OVER(), 0, NULL, SUM(n) OVER()) * 100, 1)
 BIX_PMV_TOTAL4
 ,nvl(n,0) BIX_PMV_AO_OUTCALLHAND_PP
 ,ROUND(u / q, 1) BIX_PMV_AO_AVGTALK_CP
 ,ROUND(SUM(u) OVER() / SUM(q) OVER(), 1)
 BIX_PMV_TOTAL5
 ,ROUND(((u / q) - (v / r)) / DECODE(v / r, 0, NULL, v / r) * 100 , 1)
 BIX_PMV_AO_AVGTALK_CG
 ,ROUND((SUM(u) OVER() / SUM(q) OVER() - SUM(v) OVER() / SUM(r) OVER()) /
	 DECODE(SUM(v) OVER() / SUM(r) OVER(), 0, NULL, SUM(v) OVER() / SUM(r) OVER()) * 100 , 1)
 BIX_PMV_TOTAL6
 ,ROUND(v / r, 1) BIX_PMV_AO_AVGTALK_PP
 ,ROUND(s / q, 1) BIX_PMV_AO_AVGWRAP_CP
 ,ROUND(SUM(s) OVER() / SUM(q) OVER(), 1)
 BIX_PMV_TOTAL7
 ,ROUND(((s / q) - (t / r)) / DECODE(t / r, 0, NULL, t / r) * 100, 1)
 BIX_PMV_AO_AVGWRAP_CG
 ,ROUND((SUM(s) OVER() / SUM(q) OVER() - SUM(t) OVER() / SUM(r) OVER()) /
	 DECODE(SUM(t) OVER() / SUM(r) OVER(), 0, NULL, SUM(t) OVER() / SUM(r) OVER()) * 100, 1)
 BIX_PMV_TOTAL8
 ,w BIX_PMV_AO_SRCR_CP
 ,SUM(w) OVER() BIX_PMV_TOTAL9
 ,ROUND((w - x) / DECODE(x, 0, NULL, x) * 100, 1)
 BIX_PMV_AO_SRCR_CG
 ,ROUND((SUM(w) OVER() - SUM(x) OVER()) / DECODE(SUM(x) OVER(), 0, NULL, SUM(x) OVER()) * 100, 1)
 BIX_PMV_TOTAL10
 ,y BIX_PMV_AO_LECR_CP
 ,SUM(y) OVER() BIX_PMV_TOTAL11
 ,ROUND((y - z) / DECODE(z, 0, NULL, z) * 100, 1)
 BIX_PMV_AO_LECR_CG
 ,ROUND((SUM(y) OVER() - SUM(z) OVER()) / DECODE(SUM(z) OVER(), 0, NULL, SUM(z) OVER()) * 100, 1)
 BIX_PMV_TOTAL12
 ,y1 BIX_PMV_AO_OPCR_CP
 ,SUM(y1) OVER() BIX_PMV_TOTAL13
 ,ROUND((y1 - z1) / DECODE(z1, 0, NULL, z1) * 100, 1)
 BIX_PMV_AO_OPCR_CG
 ,ROUND((SUM(y1) OVER() - SUM(z1) OVER()) / DECODE(SUM(z1) OVER(), 0, NULL, SUM(z1) OVER()) * 100, 1)
 BIX_PMV_TOTAL14
 ,a1 BIX_PMV_AO_CUST_CP
 ,a9 BIX_PMV_TOTAL15
 ,ROUND((a1 - a2) / DECODE(a2, 0, null, a2) * 100, 1)
 BIX_PMV_AO_CUST_CG
 ,ROUND((a9 - a10) / DECODE(a10, 0, NULL, a10) * 100, 1)
 BIX_PMV_TOTAL16
 ,ROUND(
 (NVL(loginc,0) - NVL(idlec, 0)) /
 DECODE(loginc, 0, NULL, loginc) * 100, 1)
 BIX_PMV_AO_AVAILRATE_CP
 ,ROUND(
 SUM(NVL(loginc,0) - NVL(idlec, 0)) OVER() /
 DECODE(SUM(loginc) OVER(), 0, NULL, SUM(loginc) OVER() )* 100, 1)
 BIX_PMV_TOTAL17
 ,ROUND(
 (NVL(loginc,0) - NVL(idlec, 0)) /
 DECODE(loginc, 0, NULL, loginc) * 100
 -
 (NVL(loginp,0) - NVL(idlep, 0)) /
 DECODE(loginp, 0, NULL, loginp) * 100
 , 1)
 BIX_PMV_AO_AVAILRATE_CG
 ,ROUND(
 sum(NVL(loginc,0) - NVL(idlec, 0)) over() /
 DECODE(sum(loginc) over(), 0, NULL, sum(loginc) over() ) * 100
 -
 sum(NVL(loginp,0) - NVL(idlep, 0)) over() /
 DECODE(sum(loginp) over(), 0, NULL, sum(loginp)over()) * 100
 , 1)
 BIX_PMV_TOTAL18
 ,ROUND(
 (NVL(loginc,0) - NVL(idlec, 0)-nvl(availc,0)) /
 DECODE(loginc, 0, NULL, loginc) * 100, 1) BIX_PMV_AO_UTILRATE_CP
 ,ROUND(
 SUM(NVL(loginc,0) - NVL(idlec, 0)-nvl(availc,0)) OVER() /
 DECODE(SUM(loginc) OVER(), 0, NULL, SUM(loginc) OVER() )* 100, 1)
 BIX_PMV_TOTAL19
 ,ROUND(
 (NVL(loginc,0) - NVL(idlec, 0)-nvl(availc,0)) /
 DECODE(loginc, 0, NULL, loginc) * 100
 -
 (NVL(loginp,0) - NVL(idlep, 0)-nvl(availp,0)) /
 DECODE(loginp, 0, NULL, loginp) * 100
 , 1)
 BIX_PMV_AO_UTILRATE_CG
 ,
 ROUND(
 sum(NVL(loginc,0) - NVL(idlec, 0)-nvl(availc,0)) over() /
 DECODE(sum(loginc) over(), 0, NULL, sum(loginc) over() ) * 100
 -
 sum(NVL(loginp,0) - NVL(idlep, 0)-nvl(availp,0)) over() /
 DECODE(sum(loginp) over(), 0, NULL, sum(loginp)over()) * 100
 , 1) BIX_PMV_TOTAL20
 ,nvl(prC,0) BIX_PMV_AO_PORESP_CP
 ,sum(nvl(prc,0)) OVER() BIX_PMV_TOTAL21
 /* ,nvl(PRC,0)-NVL(PRP,0) BIX_PMV_AO_PORESP_CG
 ,SUM(nvl(PRC,0)-NVL(PRP,0)) OVER() BIX_PMV_TOTAL22
 */
 ,(nvl(PRC,0)-NVL(PRP,0))*100/decode(prp,0,null,prp) BIX_PMV_AO_PORESP_CG
 ,sum(nvl(PRC,0)-NVL(PRP,0)) over()*100/sum(decode(prp,0,null,prp)) over() BIX_PMV_TOTAL22
 ,nvl(PRp,0) BIX_PMV_AO_PORESP_PP
 ,contc/(decode(loginc,0,null,loginc)/3600) BIX_PMV_AO_CONTPERHR_CP , sum(nvl(contc,0)) over() /(decode(sum(loginc) over() ,0,null,sum(loginc) over() )/3600) BIX_PMV_TOTAL23
 , (contc/decode(loginc,0,NULL,loginc) -contp/decode(loginp,0,null,loginp))*100/decode(contp/decode(loginp,0,null,loginp),0,null,contp/decode(loginp,0,null,loginp))   BIX_PMV_AO_CONTPERHR_CG
 ,  (sum(contc) over()/decode(sum(loginc) over(),0,null,sum(loginc) over()) -
 sum(contp) over()/decode(sum(loginp) over(),0,null,sum(loginp) over()))*100/
 decode(sum(contp) over()/decode(sum(loginp) over(),0,null,sum(loginp) over()),0,null,sum(contp) over()
 /decode(sum(loginp) over(),0,null,sum(loginp) over()) ) BIX_PMV_TOTAL24
 ,contp/(decode(loginp,0,null,loginp)/3600) BIX_PMV_AO_CONTPERHR_PP
 FROM ( SELECT nvl(group_name,:l_unknown) VIEWBY,a.server_group_id VIEWBYID
 ,DECODE(SUM(c), 0, NULL, SUM(c)) c
 ,DECODE(SUM(d), 0, NULL, SUM(d)) d
 ,DECODE(SUM(g), 0, NULL, SUM(g)) g
 ,DECODE(SUM(h), 0, NULL, SUM(h)) h
 ,SUM(NVL(i,0)) i
 ,SUM(NVL(j,0)) j
 /* Added for US Abandonment rate */
 ,SUM(NVL(ius,0)) ius
 ,SUM(NVL(jus,0)) jus
 /* End of addition */
 ,SUM(NVL(k,0)) k
 ,SUM(NVL(l,0)) l
	 ,DECODE(SUM(m), 0, NULL, SUM(m)) m
	 ,DECODE(SUM(n), 0, NULL, SUM(n)) n
 ,SUM(NVL(s,0)) s
 ,SUM(NVL(t,0)) t
 ,SUM(NVL(u,0)) u
 ,SUM(NVL(v,0)) v
 ,SUM(NVL(w,0)) w
 ,SUM(NVL(x,0)) x
 ,SUM(NVL(y,0)) y
 ,SUM(NVL(z,0)) z
 ,SUM(NVL(y1,0)) y1
 ,SUM(NVL(z1,0)) z1
 ,COUNT(DISTINCT(CASE WHEN report_date = &BIS_CURRENT_ASOF_DATE
 AND party_id <> -1
 THEN PARTY_ID END ))
 a1
 ,COUNT(DISTINCT(CASE WHEN report_date = &BIS_PREVIOUS_ASOF_DATE
 AND party_id <> -1
 THEN PARTY_ID END ))
 a2
 ,MIN(a9) a9
 ,MIN(a10) a10
 ,DECODE(SUM(NVL(m,0) + NVL(a3,0)), 0, NULL, SUM(NVL(m,0) + NVL(a3,0))) q
 ,DECODE(SUM(NVL(n,0) + NVL(a4,0)), 0, NULL, SUM(NVL(n,0) + NVL(a4,0))) r
 ,DECODE(SUM(NVL(g,0) + NVL(a7,0)), 0, NULL, SUM(NVL(g,0) + NVL(a7,0))) g1
 ,DECODE(SUM(NVL(h,0) + NVL(a8,0)), 0, NULL, SUM(NVL(h,0) + NVL(a8,0))) h1 ,sum(nvl(loginp,0)) loginp
 ,sum(nvl(loginc,0)) loginc
 ,sum(nvl(idlep,0)) idlep
 ,sum(nvl(idlec,0)) idlec
 ,sum(nvl(availp,0)) availp
 ,sum(nvl(availc,0)) availc
 ,sum(nvl(prp,0) ) prp
 ,sum(nvl(prc,0)) prc
 ,sum(nvl(contp,0)) contp
 ,sum(nvl(contc,0)) contc
	 FROM (
 SELECT
 server_group_id
 ,source_code_id sourcecode
 ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,agent_calls_handled_total, 0)
 c
 ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,agent_calls_handled_total, 0)
 d
 ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,
 decode(dialing_method,''PRED'',call_calls_offered_total,0),0)
 g
 ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,decode(dialing_method,''PRED'',call_calls_offered_total,0), 0)
 h
 ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,decode(dialing_method,''PRED'',call_calls_abandoned,0), 0)
 i
 ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,decode(dialing_method,''PRED'',call_calls_abandoned,0), 0)
 j
 /* Added for US Abandon rate */
 ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,decode(dialing_method,''PRED'',call_calls_abandoned_us,0), 0)
 ius
 ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,decode(dialing_method,''PRED'',call_calls_abandoned_us,0), 0)
 jus
/* End of additions */
 ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,call_calls_transferred, 0)
 k
 ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,call_calls_transferred, 0)
 l
 ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,call_calls_handled_total, 0)
 m
 ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,call_calls_handled_total, 0)
 n
 ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,agent_wrap_time_nac)
 s
 ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,agent_wrap_time_nac)
 t
 ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,call_talk_time)
 u
 ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,call_talk_time)
 v
 ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,agent_sr_created)
 w
 ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,agent_sr_created)
 x
 ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,agent_leads_created)
 y
 ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,agent_leads_created)
 z
 ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,agent_opportunities_created)
 y1
 ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,agent_opportunities_created)
 z1
 ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,agentcall_pr_count)
 prc
 ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,agentcall_pr_count)
 prp
 ,party_id party_id
	 ,calendar.report_date report_date
 ,NULL a3
 ,NULL a4
	,NULL a7
	 ,NULL a8
 ,COUNT(DISTINCT(CASE WHEN calendar.report_date = &BIS_CURRENT_ASOF_DATE
 AND party_id <> -1
 THEN PARTY_ID END )) OVER()
 a9
 ,COUNT(DISTINCT(CASE WHEN calendar.report_date = &BIS_PREVIOUS_ASOF_DATE
 AND party_id <> -1
 THEN PARTY_ID END )) OVER()
 a10
 ,0 loginp
 ,0 loginc
 ,0 idlep
 ,0 idlec
 ,0 availp
 ,0 availc
 ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,agentcall_contact_count)
 contp
 ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,agentcall_contact_count)
 contc
 FROM
 bix_ao_call_details_mv a,
 fii_time_rpt_struct calendar
 WHERE a.row_type = ''C''
 AND a.time_id = calendar.time_id
 AND a.period_type_id = calendar.period_type_id
 AND calendar.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
 AND bitand(calendar.record_type_id,&BIS_NESTED_PATTERN ) = calendar.record_type_id
      '||l_where_clause||' union all
 /* continue inline view and select session measures */
 SELECT server_group_id
 ,-999 sourcecode
 ,NULL c
 ,NULL d
 ,NULL g
 ,NULL h
 ,NULL i
 ,NULL j
 /* Added for US abandon measure */
 ,NULL ius
 ,NULL jus
 /* End of addition */
 ,NULL k
 ,NULL l
 ,NULL m
 ,NULL n
 ,NULL s
 ,NULL t
 ,NULL u
 ,NULL v
 ,NULL w
 ,NULL x
 ,NULL y
 ,NULL z
 ,NULL y1
 ,NULL z1
 ,0 prc
 ,0 prp
	 ,NULL party_id
	 ,NULL report_date
 ,0 a3
 ,0 a4
 ,0 a7
 ,0 a8
 ,0 a9
 ,0 a10
 , SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,login_time))
 loginp
 , SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,login_time))
 loginc
 , SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,idle_time))
 idlep
 , SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,idle_time))
 idlec
 , SUM(DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,available_time))
 availp
 , SUM(DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,available_time))
 availc
 , 0 contp
 ,0 contc
 FROM
 bix_agent_session_f fact,
 fii_time_rpt_struct calendar
 WHERE fact.time_id = calendar.time_id
 AND fact.application_id = 696
 AND fact.period_type_id = calendar.period_type_id
 AND calendar.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
 AND
 bitand(calendar.record_type_id,&BIS_NESTED_PATTERN ) = calendar.record_type_id
  '||l_call_where_clause||'  group by server_group_id
 UNION ALL
 /*Continue inline view select continued measures */
 SELECT server_group_id
 ,source_code_id sourcecode
 ,NULL c
 ,NULL d
 ,NULL g
 ,NULL h
 ,NULL i
 /* Added for US abandon measure */
 ,NULL ius
 ,NULL j
 ,NULL jus
 /* End of addition */
 ,NULL k
 ,NULL l
 ,NULL m
 ,NULL n
 ,NULL s
 ,NULL t
 ,NULL u
 ,NULL v
 ,NULL w
 ,NULL x
 ,NULL y
 ,NULL z
 ,NULL y1
 ,NULL z1
 ,0 prc
 ,0 prp
	 ,NULL party_id
	 ,NULL report_date
 ,DECODE(time_id,TO_NUMBER(TO_CHAR(&BIS_CURRENT_EFFECTIVE_START_DATE,''J'')),call_cont_calls_handled_tot_na)
 a3
 ,DECODE(time_id,TO_NUMBER(TO_CHAR(&BIS_PREVIOUS_EFFECTIVE_START_DATE,''J'')),call_cont_calls_handled_tot_na)
 a4
 ,DECODE(time_id,TO_NUMBER(TO_CHAR(&BIS_CURRENT_EFFECTIVE_START_DATE,''J'')), decode(dialing_method,''PRED'',call_cont_calls_offered_na,0), 0)
 a7
 ,DECODE(time_id,TO_NUMBER(TO_CHAR(&BIS_PREVIOUS_EFFECTIVE_START_DATE,''J'')),decode(dialing_method,''PRED'',call_cont_calls_offered_na,0), 0)
 a8
 ,NULL a9
 ,NULL a10
 ,0 loginp
 ,0 loginc
 ,0 idlep
 ,0 idlec
 ,0 availp
 ,0 availc
 ,0 contp
 ,0 contc
 FROM
 bix_ao_call_details_mv a
 WHERE row_type = ''C''
 AND time_id IN (TO_NUMBER(TO_CHAR(&BIS_CURRENT_EFFECTIVE_START_DATE,''J'')),
 TO_NUMBER(TO_CHAR(&BIS_PREVIOUS_EFFECTIVE_START_DATE,''J'')))
 AND period_type_id = 1   '||l_where_clause||'
 ) a , ieo_svr_groups grp
';
      l_sqltext:=l_sqltext||'WHERE a.server_group_id = grp.server_group_id(+)';

l_sqltext:=l_sqltext||'
group by group_name,a.server_group_id
 ) &ORDER_BY_CLAUSE
  ';

  END IF;

/* l_sqltext :=
'SELECT
10 BIX_PMV_AO_CAMPNAME,
10 BIX_PMV_AO_CONTPERHR_CP,
10 BIX_PMV_AO_CONTPERHR_CG,
10 BIX_PMV_AO_PORESP_CP,
10 BIX_PMV_AO_PORESP_CG,
10 BIX_PMV_AO_ABANRATE_CP,
10 BIX_PMV_AO_ABANRATE_CG,
10 BIX_PMV_AO_OUTCALLHAND_CP,
10 BIX_PMV_AO_OUTCALLHAND_CG,
10 BIX_PMV_AO_AVAILRATE_CP,
10 BIX_PMV_AO_AVAILRATE_CG,
10 BIX_PMV_AO_UTILRATE_CP,
10 BIX_PMV_AO_UTILRATE_CG,
10 BIX_PMV_AO_AVGTALK_CP,
10 BIX_PMV_AO_AVGTALK_CG,
10 BIX_PMV_AO_AVGWRAP_CP,
10 BIX_PMV_AO_AVGWRAP_CG,
10 BIX_PMV_AO_SRCR_CP,
10 BIX_PMV_AO_SRCR_CG,
10 BIX_PMV_AO_LECR_CP,
10 BIX_PMV_AO_LECR_CG,
10 BIX_PMV_AO_OPCR_CP,
10 BIX_PMV_AO_OPCR_CG,
10 BIX_PMV_AO_CUST_CP,
10 BIX_PMV_AO_CUST_CG,
100 BIX_PMV_TOTAL1,
100 BIX_PMV_TOTAL2,
100 BIX_PMV_TOTAL3,
100 BIX_PMV_TOTAL4,
100 BIX_PMV_TOTAL5,
100 BIX_PMV_TOTAL6,
100 BIX_PMV_TOTAL7,
100 BIX_PMV_TOTAL8,
100 BIX_PMV_TOTAL9,
100 BIX_PMV_TOTAL10,
100 BIX_PMV_TOTAL11,
100 BIX_PMV_TOTAL12,
100 BIX_PMV_TOTAL13,
100 BIX_PMV_TOTAL14,
100 BIX_PMV_TOTAL15,
100 BIX_PMV_TOTAL16,
100 BIX_PMV_TOTAL17,
100 BIX_PMV_TOTAL18,
100 BIX_PMV_TOTAL19,
100 BIX_PMV_TOTAL20,
100 BIX_PMV_TOTAL21,
100 BIX_PMV_TOTAL22
FROM DUAL ';
*/





  l_sqltext:=replace(replace(replace(replace(replace(l_sqltext,
'      ',' '),'     ',' '),'    ',' '),'   ',' '),'  ',' ');

     p_sql_text := l_sqltext;


    l_custom_rec.attribute_name := ':l_unknown' ;
    l_custom_rec.attribute_value:= l_unknown;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

    p_custom_output.Extend();
    p_custom_output(p_custom_output.count) := l_custom_rec;

--  p_custom_output.EXTEND();
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

IF l_view_by = 'CAMPAIGN+CAMPAIGN' THEN

l_custom_rec.attribute_name := ':l_camp';
l_custom_rec.attribute_value:= 'CAMP';
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;

END IF;


l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.View_By_Type;
l_custom_rec.attribute_value := l_view_by;

p_custom_output.EXTEND();
p_custom_output(p_custom_output.COUNT) := l_custom_rec;


EXCEPTION
  WHEN OTHERS THEN
    NULL;
END GET_SQL;
END  BIX_PMV_AO_TELDTL_RPT_PKG;

/
