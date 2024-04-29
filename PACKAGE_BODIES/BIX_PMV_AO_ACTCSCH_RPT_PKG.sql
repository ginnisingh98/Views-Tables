--------------------------------------------------------
--  DDL for Package Body BIX_PMV_AO_ACTCSCH_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_AO_ACTCSCH_RPT_PKG" AS
/*$Header: bixocshr.plb 115.8 2004/04/26 06:04:13 pubalasu noship $ */


PROCEDURE GET_SQL(p_page_parameter_tbl IN         BIS_PMV_PAGE_PARAMETER_TBL,
                  p_sql_text           OUT NOCOPY VARCHAR2,
                  p_custom_output      OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
                  )
AS
  l_sqltext            VARCHAR2(32000) ;
  l_where_clause       VARCHAR2(1000) ;
  l_call_center        VARCHAR2(3000);
  l_view_by            VARCHAR2(3000);
  l_column_name        VARCHAR2(1000);
  l_unknown             VARCHAR2(3000);

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
   ams_source_codes where arc_source_code_for=''CAMP'' and active_flag=''Y'' and  source_code_id IN (:l_source_code_id) ) ';
END IF;

l_where_clause:=l_source_code_where_clause||l_call_where_clause;

l_unknown := FND_MESSAGE.GET_STRING('BIX','BIX_PMV_UNKNOWN');

IF l_unknown IS NULL OR l_unknown = 'BIX_PMV_UNKNOWN'
THEN
   l_unknown := 'Unknown';
END IF;


/**
  IF l_view_by = 'BIX_TELEPHONY+BIX_CALL_CENTER' THEN
    l_column_name := 'server_group_id ';
  ELSIF l_view_by = 'CAMPAIGN+CAMPAIGN' THEN
    l_column_name := 'source_code_id';
  ELSE
    l_column_name := 'server_group_id ';
  END IF;
**/


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

/*
IF l_column_name = 'server_group_id '
THEN
   l_sqltext := 'SELECT group_name VIEWBY ';
ELSE
   l_sqltext := 'SELECT value  VIEWBY ';
END IF;
*/

l_column_name := 'schedule_id ';


  l_sqltext := 'SELECT schedule_name BIX_PMV_AO_CSCHNAME ';
  l_sqltext := l_sqltext ||
    '  ,ROUND(i / g1 * 100, 1) BIX_PMV_AO_ABANRATE_CP
       ,ROUND(SUM(i) OVER() / SUM(g1) OVER() * 100, 1) BIX_PMV_TOTAL1
       ,ROUND((i / g1 * 100) - (j / h1 * 100), 1) BIX_PMV_AO_ABANRATE_CG
       ,ROUND(SUM(i) OVER() / SUM(g1) OVER() * 100 - SUM(j) OVER() / SUM(h1) OVER() * 100, 1) BIX_PMV_TOTAL2
       ,ROUND(j / h1 * 100, 1)  BIX_PMV_AO_ABANRATE_PP
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
       ,nvl(m,0)          BIX_PMV_AO_OUTCALLHAND_CP
       ,nvl(SUM(m) OVER() ,0)  BIX_PMV_TOTAL3
       ,ROUND((m - n) / DECODE(n, 0, NULL, n) * 100, 1)  BIX_PMV_AO_OUTCALLHAND_CG
       ,ROUND((SUM(m) OVER() - SUM(n) OVER()) / DECODE(SUM(n) OVER(), 0, NULL, SUM(n) OVER()) * 100, 1) BIX_PMV_TOTAL4
       ,nvl(n,0)          BIX_PMV_AO_OUTCALLHAND_PP
       ,ROUND(u / q, 1)  BIX_PMV_AO_AVGTALK_CP
       ,ROUND(SUM(u) OVER() / SUM(q) OVER(), 1)   BIX_PMV_TOTAL5
       ,ROUND(((u / q) - (v / r)) / DECODE(v / r, 0, NULL, v / r) * 100 , 1) BIX_PMV_AO_AVGTALK_CG
       ,ROUND((SUM(u) OVER() / SUM(q) OVER() - SUM(v) OVER() / SUM(r) OVER()) /
	       DECODE(SUM(v) OVER() / SUM(r) OVER(), 0, NULL, SUM(v) OVER() / SUM(r) OVER()) * 100 , 1) BIX_PMV_TOTAL6
       ,ROUND(v / r, 1)   BIX_PMV_AO_AVGTALK_PP ,ROUND(s / q, 1)   BIX_PMV_AO_AVGWRAP_CP
       ,ROUND(SUM(s) OVER() / SUM(q) OVER(), 1) BIX_PMV_TOTAL7
       ,ROUND(((s / q) - (t / r)) / DECODE(t / r, 0, NULL, t / r) * 100, 1) BIX_PMV_AO_AVGWRAP_CG
       ,ROUND((SUM(s) OVER() / SUM(q) OVER() - SUM(t) OVER() / SUM(r) OVER()) /
	       DECODE(SUM(t) OVER() / SUM(r) OVER(), 0, NULL, SUM(t) OVER() / SUM(r) OVER()) * 100, 1) BIX_PMV_TOTAL8
       ,NVL(w,0)                 BIX_PMV_AO_SRCR_CP     ,NVL(SUM(w) OVER(),0)     BIX_PMV_TOTAL9
       ,ROUND((w - x) / DECODE(x, 0, NULL, x) * 100, 1)   BIX_PMV_AO_SRCR_CG
       ,ROUND((SUM(w) OVER() - SUM(x) OVER()) / DECODE(SUM(x) OVER(), 0, NULL, SUM(x) OVER()) * 100, 1)
                          BIX_PMV_TOTAL10
       ,NVL(y,0)                 BIX_PMV_AO_LECR_CP  ,NVL(SUM(y) OVER(),0)     BIX_PMV_TOTAL11
       ,ROUND((y - z) / DECODE(z, 0, NULL, z) * 100, 1) BIX_PMV_AO_LECR_CG
       ,ROUND((SUM(y) OVER() - SUM(z) OVER()) / DECODE(SUM(z) OVER(), 0, NULL, SUM(z) OVER()) * 100, 1)
                          BIX_PMV_TOTAL12 ,NVL(y1,0)                BIX_PMV_AO_OPCR_CP
       ,SUM(y1) OVER()    BIX_PMV_TOTAL13 ,ROUND((y1 - z1) / DECODE(z1, 0, NULL, z1) * 100, 1)
                          BIX_PMV_AO_OPCR_CG
       ,ROUND((SUM(y1) OVER() - SUM(z1) OVER()) / DECODE(SUM(z1) OVER(), 0, NULL, SUM(z1) OVER()) * 100, 1)
                          BIX_PMV_TOTAL14
       ,NVL(a1,0)                BIX_PMV_AO_CUST_CP    ,NVL(a9,0)                BIX_PMV_TOTAL15
       ,ROUND((a1 - a2) / DECODE(a2, 0, null, a2) * 100, 1)     BIX_PMV_AO_CUST_CG
       ,ROUND((a9 - a10) / DECODE(a10, 0, NULL, a10) * 100, 1)    BIX_PMV_TOTAL16
       , ROUND(
        (NVL(loginc,0) - NVL(idlec, 0)) /
            DECODE(loginc, 0, NULL, loginc) * 100, 1)
         BIX_PMV_AO_AVAILRATE_CP
       , ROUND(
        (NVL(loginc,0) - NVL(idlec, 0)) /
            DECODE(loginc, 0, NULL, loginc) * 100, 1)
       /* ROUND(
        SUM(NVL(loginc,0) - NVL(idlec, 0)) OVER() /
            DECODE(SUM(loginc) OVER(), 0, NULL, SUM(loginc) OVER() )* 100, 1) */
                      BIX_PMV_TOTAL17
       , ROUND(
        (NVL(loginc,0) - NVL(idlec, 0)) /
            DECODE(loginc, 0, NULL, loginc) * 100
            -
        (NVL(loginp,0) - NVL(idlep, 0)) /
            DECODE(loginp, 0, NULL, loginp) * 100
              , 1)
              BIX_PMV_AO_AVAILRATE_CG
       , ROUND(
        (NVL(loginc,0) - NVL(idlec, 0)) /
            DECODE(loginc, 0, NULL, loginc) * 100
            -
        (NVL(loginp,0) - NVL(idlep, 0)) /
            DECODE(loginp, 0, NULL, loginp) * 100
              , 1)
       /* ROUND(
        sum(NVL(loginc,0) - NVL(idlec, 0)) over() /
            DECODE(sum(loginc) over(), 0, NULL, sum(loginc) over() ) * 100
            -
        sum(NVL(loginp,0) - NVL(idlep, 0)) over() /
            DECODE(sum(loginp) over(), 0, NULL, sum(loginp)over()) * 100
              , 1) */

                   BIX_PMV_TOTAL18
       ,ROUND(
        (NVL(loginc,0) - NVL(idlec, 0)-nvl(availc,0)) /
            DECODE(loginc, 0, NULL, loginc) * 100, 1)  BIX_PMV_AO_UTILRATE_CP
       ,ROUND(
        (NVL(loginc,0) - NVL(idlec, 0)-nvl(availc,0)) /
            DECODE(loginc, 0, NULL, loginc) * 100, 1)
       /* ROUND(
        SUM(NVL(loginc,0) - NVL(idlec, 0)-nvl(availc,0)) OVER() /
            DECODE(SUM(loginc) OVER(), 0, NULL, SUM(loginc) OVER() )* 100, 1) */
          BIX_PMV_TOTAL19
       , ROUND(
        (NVL(loginc,0) - NVL(idlec, 0)-nvl(availc,0)) /
            DECODE(loginc, 0, NULL, loginc) * 100
            -
        (NVL(loginp,0) - NVL(idlep, 0)-nvl(availp,0)) /
            DECODE(loginp, 0, NULL, loginp) * 100
              , 1)
          BIX_PMV_AO_UTILRATE_CG
       , ROUND(
        (NVL(loginc,0) - NVL(idlec, 0)-nvl(availc,0)) /
            DECODE(loginc, 0, NULL, loginc) * 100
            -
        (NVL(loginp,0) - NVL(idlep, 0)-nvl(availp,0)) /
            DECODE(loginp, 0, NULL, loginp) * 100
              , 1)
              BIX_PMV_TOTAL20
       /* NVL(ROUND(
        sum(NVL(loginc,0) - NVL(idlec, 0)-nvl(availc,0)) over() /
            DECODE(sum(loginc) over(), 0, NULL, sum(loginc) over() ) * 100
            -
        sum(NVL(loginp,0) - NVL(idlep, 0)-nvl(availp,0)) over() /
            DECODE(sum(loginp) over(), 0, NULL, sum(loginp)over()) * 100
              , 1),0)
        BIX_PMV_TOTAL20 */
       ,nvl(prC,0) BIX_PMV_AO_PORESP_CP
       ,NVL(sum(nvl(prc,0)) OVER(),0) BIX_PMV_TOTAL21
       ,100*(nvl(PRC,0)-NVL(PRP,0))/decode(PRP,0,NULL,PRP) BIX_PMV_AO_PORESP_CG
       ,100*(SUM(PRC) OVER() -SUM(PRP) OVER())/ DECODE(SUM(PRP) OVER(),0,NULL,SUM(PRP) OVER())BIX_PMV_TOTAL22
       ,nvl(PRp,0) BIX_PMV_AO_PORESP_PP
       ,contc/(decode(loginc,0,null,loginc)/3600) BIX_PMV_AO_CONTPERHR_CP
       ,sum(contc) over()/(decode(loginc,0,null,loginc)/3600) BIX_PMV_TOTAL23
      /* , SUM(contc) OVER()/ ( decode( sum(loginc) OVER(),0,null,sum(loginc) OVER() )/3600) BIX_PMV_TOTAL23  */
        ,(contc/decode(loginc,0,NULL,loginc) - contp/decode(loginp ,0,NULL,loginp))*100/decode(contp/decode(loginp ,0,NULL,loginp),0,null,contp/decode(loginp ,0,NULL,loginp)) BIX_PMV_AO_CONTPERHR_CG
		,(sum(contc) over() /decode(loginc,0,NULL,loginc) - sum(contp) over() /decode(loginp ,0,NULL,loginp))*100/decode(sum(contp) over()/decode(loginp ,0,NULL,loginp),0,null,sum(contp) over() /decode(loginp ,0,NULL,loginp))   BIX_PMV_TOTAL24
	   /*,sum(contc-contp) over() *100/decode(sum(contc) over(),0,null,sum(contc) over()) BIX_PMV_TOTAL24 */
       ,contp/(decode(loginp,0,null,loginp)/3600) BIX_PMV_AO_CONTPERHR_PP
  FROM (
     SELECT DECODE(a.schedule_id ,''-999'',''-999'',NVL(sched.schedule_name, :l_unknown)) schedule_name
     ,sum(c) c ,sum(d) d,sum(g) g,sum(h) h,sum(i) i  ,sum(j) j ,sum(ius) ius,sum(jus) jus,sum(k) k,sum(l) l
	,sum(m) m,sum(n) n,sum(s) s,sum(t) t,sum(u) u,sum(v) v,sum(w) w ,sum(x) x,sum(y) y,sum(z) z,sum(y1) y1
	,sum(z1) z1,sum(a1) a1,sum(a2) a2,sum(a9) a9,sum(a10) a10,sum(q) q ,sum(r) r,sum(g1) g1 ,sum(h1) h1
	,sum(prp) prp,sum(prc) prc,sum(contp) contp,sum(contc) contc
        ,min(loginp)  loginp
   ,min(loginc)  loginc
   ,min(idlep)  idlep
   ,min(idlec)  idlec
   ,min(availp)  availp
   ,min(availc)  availc FROM (' ;

/* Add the extra inline view for login handling */
l_sqltext := l_sqltext || '   SELECT '|| l_column_name ||'
   , c,d,g,h,i,j,ius,jus,k,l,m,n,s,t,u,v,w,x,y,z,y1,z1,a1,a2,a9,a10,q,r,g1,h1,prp,prc,contp,contc
   ,sum(loginp) over() loginp
   ,sum(loginc) over() loginc
   ,sum(idlep) over() idlep
   ,sum(idlec) over() idlec
   ,sum(availp) over() availp
   ,sum(availc) over() availc
   FROM (
  ';
  /* End of addition for inline view - Add one extra ")" also at the end*/
  l_sqltext := l_sqltext || '
    SELECT
       ' || l_column_name || '
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
      ,DECODE(SUM(NVL(h,0) + NVL(a8,0)), 0, NULL, SUM(NVL(h,0) + NVL(a8,0))) h1
      ,sum(nvl(loginp,0)) loginp
      ,sum(nvl(loginc,0)) loginc
      ,sum(nvl(idlep,0))  idlep
      ,sum(nvl(idlec,0))  idlec
      ,sum(nvl(availp,0)) availp
      ,sum(nvl(availc,0)) availc
      ,sum(nvl(prp,0) ) prp
      ,sum(nvl(prc,0)) prc
      ,sum(nvl(contp,0)) contp
      ,sum(nvl(contc,0)) contc

    FROM ( ';

  l_sqltext := l_sqltext || '
    SELECT
      ' || l_column_name || '
      ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,agent_calls_handled_total, 0)
                       c
      ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,agent_calls_handled_total, 0)
                       d
     ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,decode(dialing_method,''PRED'',call_calls_offered_total,0),0)
                       g
      ,DECODE(calendar.report_date,&BIS_PREVIOUS_ASOF_DATE,
      decode(dialing_method,''PRED'',call_calls_offered_total,0), 0)
                       h
      ,DECODE(calendar.report_date,&BIS_CURRENT_ASOF_DATE,
      decode(dialing_method,''PRED'',call_calls_abandoned,0)
      , 0)
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
      ,NULL            a3
      ,NULL            a4
	,NULL            a7
	 ,NULL            a8
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
    AND   a.time_id = calendar.time_id
    AND   a.period_type_id = calendar.period_type_id
    AND   calendar.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
    AND   bitand(calendar.record_type_id,&BIS_NESTED_PATTERN ) =  calendar.record_type_id ';

  l_sqltext := l_sqltext || l_where_clause || '
    union all
    /* continue inline view and select session measures */
SELECT
       -999
      ,NULL  c
      ,NULL  d
      ,NULL  g
      ,NULL  h
      ,NULL  i
      ,NULL  j
      /* Added for US abandon measure */
      ,NULL  ius
      ,NULL  jus
      /* End of addition */
      ,NULL  k
      ,NULL  l
      ,NULL  m
      ,NULL  n
      ,NULL  s
      ,NULL  t
      ,NULL  u
      ,NULL  v
      ,NULL  w
      ,NULL  x
      ,NULL  y
      ,NULL  z
      ,NULL  y1
      ,NULL  z1
      ,0 prc
      ,0 prp
	 ,NULL party_id
	 ,NULL report_date
     ,0  a3
     ,0  a4
     ,0  a7
     ,0  a8
     ,0  a9
     ,0   a10
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
    bitand(calendar.record_type_id,&BIS_NESTED_PATTERN ) =  calendar.record_type_id ';

  l_sqltext := l_sqltext || l_call_where_clause ||    '
      group by '||l_column_name|| '
    UNION ALL
    /*Continue inline view select continued measures */
    SELECT
       ' || l_column_name || '
      ,NULL  c
      ,NULL  d
      ,NULL  g
      ,NULL  h
      ,NULL  i
      ,NULL  j
      /* Added for US abandon measure */
      ,NULL  ius
      ,NULL  jus
      /* End of addition */
      ,NULL  k
      ,NULL  l
      ,NULL  m
      ,NULL  n
      ,NULL  s
      ,NULL  t
      ,NULL  u
      ,NULL  v
      ,NULL  w
      ,NULL  x
      ,NULL  y
      ,NULL  z
      ,NULL  y1
      ,NULL  z1
      ,0 prc
      ,0 prp
	 ,NULL party_id
	 ,NULL report_date
      ,DECODE(time_id,TO_NUMBER(TO_CHAR(&BIS_CURRENT_EFFECTIVE_START_DATE,''J'')),call_cont_calls_handled_tot_na)
             a3
      ,DECODE(time_id,TO_NUMBER(TO_CHAR(&BIS_PREVIOUS_EFFECTIVE_START_DATE,''J'')),call_cont_calls_handled_tot_na)
             a4
     ,DECODE(time_id,TO_NUMBER(TO_CHAR(&BIS_CURRENT_EFFECTIVE_START_DATE,''J'')),decode(dialing_method,''PRED'',call_cont_calls_offered_na,0), 0)
             a7
      ,DECODE(time_id,TO_NUMBER(TO_CHAR(&BIS_PREVIOUS_EFFECTIVE_START_DATE,''J'')),decode(dialing_method,''PRED'',call_cont_calls_offered_na,0), 0)
             a8
      ,NULL  a9
      ,NULL  a10
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
    AND   time_id IN (TO_NUMBER(TO_CHAR(&BIS_CURRENT_EFFECTIVE_START_DATE,''J'')),
                          TO_NUMBER(TO_CHAR(&BIS_PREVIOUS_EFFECTIVE_START_DATE,''J'')))
    AND   period_type_id = 1 ';

  l_sqltext := l_sqltext || l_where_clause || '
  )
    GROUP BY ' || l_column_name || '
      )
     ) a , ams_campaign_schedules_vl sched
        WHERE a.schedule_id= sched.schedule_id (+)
    GROUP BY DECODE(a.schedule_id ,''-999'',''-999'',NVL(sched.schedule_name, :l_unknown))
  )  a  where a.schedule_name <> ''-999''';


    l_sqltext := l_sqltext ||
     /* ' , ams_campaign_schedules_vl sched
        WHERE a.schedule_id= sched.schedule_id (+)
        and a.schedule_id <> ''-999'' */
         ' &ORDER_BY_CLAUSE ';

  /* Before passing l_sqltext to the calling proc, we trim it up a bit */
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






l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.View_By_Type;
l_custom_rec.attribute_value := l_view_by;

p_custom_output.EXTEND();
p_custom_output(p_custom_output.COUNT) := l_custom_rec;




EXCEPTION
 WHEN OTHERS THEN
 NULL;

END GET_SQL;
END  BIX_PMV_AO_ACTCSCH_RPT_PKG;

/
