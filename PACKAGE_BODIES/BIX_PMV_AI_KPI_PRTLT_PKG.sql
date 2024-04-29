--------------------------------------------------------
--  DDL for Package Body BIX_PMV_AI_KPI_PRTLT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_AI_KPI_PRTLT_PKG" AS
/*$Header: bixikpip.plb 115.10 2004/03/08 04:11:23 suray noship $ */

PROCEDURE GET_SQL(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                  p_sql_text           OUT NOCOPY VARCHAR2,
                  p_custom_output      OUT NOCOPY bis_query_attributes_TBL
                  )
AS
l_sqltext	      VARCHAR2(32000) ;
l_as_of_date   DATE;
l_period_type	varchar2(2000);
l_comp_type    varchar2(2000);
l_record_type_id NUMBER;
l_sql_errm      varchar2(32000);
l_goal  NUMBER;
l_custom_rec       BIS_QUERY_ATTRIBUTES;
l_period_type_id   NUMBER := 1;
l_period_from  DATE;
l_period_to    DATE;
l_call_center VARCHAR2(3000);
l_classification VARCHAR2(3000);
l_dnis VARCHAR2(3000);
l_call_where_clause VARCHAR2(3000);
l_session_where_clause VARCHAR2(3000);
l_view_by            VARCHAR2(3000);

BEGIN
 p_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
 l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;

IF (FND_PROFILE.DEFINED('BIX_CALL_SLGOAL_PERCENT')) THEN
   BEGIN
   l_goal := TO_NUMBER(FND_PROFILE.VALUE('BIX_CALL_SLGOAL_PERCENT'));
   EXCEPTION
   WHEN OTHERS THEN
    l_goal := 0;
   END;
ELSE
   l_goal := 0;
END IF;

IF l_goal IS NULL THEN
  l_goal := 0;
END IF;

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
   l_session_where_clause := ' AND server_group_id IN (:l_call_center) ';
END IF;

IF l_classification IS NOT NULL THEN
   l_call_where_clause := l_call_where_clause || ' AND mv.classification_value IN (:l_classification) ';
END IF;

--insert into bixtest values ('l_dnis is ' || l_dnis);
--commit;

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


--insert into bixtest
--values ('Entere and about to set SQL');
--commit;

l_sqltext := '
	SELECT
            sum(PAG)*100/
             decode(sum(nvl(PIO,0)+nvl(PIOC,0)),0,NULL,
		          sum(nvl(PIO,0)+nvl(PIOC,0)))  BIX_PMV_AI_PREVSL,
             sum(CAG)*100/
             decode(sum(nvl(CIO,0)+nvl(CIOC,0)),0,NULL,
		          sum(nvl(CIO,0)+nvl(CIOC,0)))  BIX_PMV_AI_SL,
             ' || l_goal ||'                           BIX_PMV_AI_SLGOAL ,
             ' || l_goal ||'                           BIX_PMV_AI_PREVSLGOAL ,
             sum(PAT)/
             decode(sum(nvl(PIH,0)+nvl(PIHC,0)),0,NULL,
		          sum(nvl(PIH,0)+nvl(PIHC,0)))  BIX_PMV_AI_PREVSPANS,
             sum(CAT)/
             decode(sum(nvl(CIH,0)+nvl(CIHC,0)),0,NULL,
		          sum(nvl(CIH,0)+nvl(CIHC,0)))  BIX_PMV_AI_SPANS,
           sum(PAB)*100/
           decode(sum(nvl(PIO,0)+nvl(PIOC,0)),0,NULL,
		        sum(nvl(PIO,0)+nvl(PIOC,0)))  BIX_PMV_AI_PREVABANRATE,
           sum(CAB)*100/
             decode(sum(nvl(CIO,0)+nvl(CIOC,0)),0,NULL,
		          sum(nvl(CIO,0)+nvl(CIOC,0)))  BIX_PMV_AI_ABANRATE,
           sum(PTR)*100/
           decode(sum(PIH),0,NULL,sum(PIH))  BIX_PMV_AI_PREVTRANRATE,
           sum(CTR)*100/
             decode(sum(CIH),0,NULL,sum(CIH))  BIX_PMV_AI_TRANRATE,
           sum(CIH) BIX_PMV_AI_INCALLHAND,
           sum(PIH) BIX_PMV_AI_PREVINCALLHAND,
           sum(CDI) BIX_PMV_AI_DIALED,
           sum(PDI) BIX_PMV_AI_PREVDIALED,
           sum(CWE) BIX_PMV_AI_WEBCALL,
           sum(PWE) BIX_PMV_AI_PREVWEBCALL,
      sum(nvl(CLO,0)-nvl(CID,0))*100/
      decode(sum(CLO),0,NULL,sum(CLO)) BIX_PMV_AI_AVAILRATE,
      sum(nvl(PLO,0)-nvl(PID,0))*100/
	 decode(sum(PLO),0,NULL,sum(PLO)) BIX_PMV_AI_PREVAVAILRATE,
      sum(nvl(CLO,0)-nvl(CAV,0)-nvl(CID,0))*100/
      decode(sum(CLO),0,NULL,sum(CLO)) BIX_PMV_AI_UTILRATE,
      sum(nvl(PLO,0)-nvl(PAV,0)-nvl(PID,0))*100/
      decode(sum(PLO),0,NULL,sum(PLO)) BIX_PMV_AI_PREVUTILRATE,
           sum(PTA)/
           decode(sum(nvl(PHA,0)+nvl(PHAC,0)),0,NULL,
		        sum(nvl(PHA,0)+nvl(PHAC,0)))  BIX_PMV_AI_PREVAVGTALK,
           sum(CTA)/
             decode(sum(nvl(CHA,0)+nvl(CHAC,0)),0,NULL,
		          sum(nvl(CHA,0)+nvl(CHAC,0)))  BIX_PMV_AI_AVGTALK,
           sum(PWA)/
           decode(sum(nvl(PHA,0)+nvl(PHAC,0)),0,NULL,
		        sum(nvl(PHA,0)+nvl(PHAC,0)))  BIX_PMV_AI_PREVAVGWRAP,
           sum(CWA)/
             decode(sum(nvl(CHA,0)+nvl(CHAC,0)),0,NULL,
		          sum(nvl(CHA,0)+nvl(CHAC,0)))  BIX_PMV_AI_AVGWRAP,
           sum(CHA)*3600/
             decode(sum(CLO),0,NULL,sum(CLO))  BIX_PMV_AI_HANDPERHR,
           sum(PHA)*3600/
             decode(sum(PLO),0,NULL,sum(PLO)) BIX_PMV_AI_PREVHANDPERHR,
           sum(CCU) BIX_PMV_AI_CUST,
           sum(PCU) BIX_PMV_AI_PREVCUST,
           sum(CSR) BIX_PMV_AI_SRCR,
           sum(PSR) BIX_PMV_AI_PREVSRCR,
	   sum(CLE)   BIX_PMV_AI_LECR,
	   sum(PLE)   BIX_PMV_AI_PREVLECR,
	   sum(COP)   BIX_PMV_AI_OPCR,
	   sum(POP)   BIX_PMV_AI_PREVOPCR
	FROM
        (
             SELECT
                    sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
				              (
						     CASE WHEN media_item_type IN (''TELE_INB'',''TELE_DIRECT'')
				               THEN CALL_CALLS_OFFERED_TOTAL ELSE 0 END
						    )
                     ,0)) PIO,
                    sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
				              (
						     CASE WHEN media_item_type IN (''TELE_INB'',''TELE_DIRECT'')
				               THEN CALL_CALLS_OFFERED_TOTAL ELSE 0 END
						    )
                     ,0)) CIO,
                    sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
                    CALL_CALLS_HANDLED_TOTAL ,0)) PHA,
                    sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
                     CALL_CALLS_HANDLED_TOTAL,0)) CHA,
                    sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
				              (
						     CASE WHEN media_item_type IN (''TELE_INB'',''TELE_DIRECT'')
				               THEN AGENT_CALLS_ANSWERED_BY_GOAL ELSE 0 END
						    )
                     ,0)) PAG,
                    sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
				              (
						     CASE WHEN media_item_type IN (''TELE_INB'',''TELE_DIRECT'')
				               THEN AGENT_CALLS_ANSWERED_BY_GOAL ELSE 0 END
						    )
                     ,0)) CAG,
                    sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
				              (
						     CASE WHEN media_item_type IN (''TELE_INB'',''TELE_DIRECT'')
				               THEN CALL_TOT_QUEUE_TO_ANSWER ELSE 0 END
						    )
                     ,0)) PAT,
                    sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
				              (
						     CASE WHEN media_item_type IN (''TELE_INB'',''TELE_DIRECT'')
				               THEN CALL_TOT_QUEUE_TO_ANSWER ELSE 0 END
						    )
                     ,0)) CAT,
                    sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
				              (
						     CASE WHEN media_item_type IN (''TELE_INB'',''TELE_DIRECT'')
				               THEN CALL_CALLS_ABANDONED ELSE 0 END
						    )
                     ,0)) PAB,
                    sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
				              (
						     CASE WHEN media_item_type IN (''TELE_INB'',''TELE_DIRECT'')
				               THEN CALL_CALLS_ABANDONED ELSE 0 END
						    )
                      ,0)) CAB,
                    sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
				              (
						     CASE WHEN media_item_type IN (''TELE_INB'',''TELE_DIRECT'')
				               THEN CALL_CALLS_TRANSFERRED ELSE 0 END
						    )
                      ,0)) PTR,
                    sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
				              (
						     CASE WHEN media_item_type IN (''TELE_INB'',''TELE_DIRECT'')
				               THEN CALL_CALLS_TRANSFERRED ELSE 0 END
						    )
                      ,0)) CTR,
                    sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
				              (
						     CASE WHEN media_item_type IN (''TELE_INB'',''TELE_DIRECT'')
				               THEN CALL_CALLS_HANDLED_TOTAL ELSE 0 END
						    )
                           ,0)) PIH,
                    sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
				              (
						     CASE WHEN media_item_type IN (''TELE_INB'',''TELE_DIRECT'')
				               THEN CALL_CALLS_HANDLED_TOTAL ELSE 0 END
						    )
                           ,0)) CIH,
                    sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
                           decode(media_item_type,
                                  ''TELE_MANUAL'',CALL_CALLS_HANDLED_TOTAL,
                                  0)
                           ,0)) PDI,
                    sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
                           decode(media_item_type,
                                  ''TELE_MANUAL'',CALL_CALLS_HANDLED_TOTAL,
                                  0)
                           ,0)) CDI,
                    sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
                           decode(media_item_type,
                                  ''TELE_WEB_CALLBACK'',CALL_CALLS_HANDLED_TOTAL,
                                  0)
                           ,0)) PWE,
                    sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
                           decode(media_item_type,
                                  ''TELE_WEB_CALLBACK'',CALL_CALLS_HANDLED_TOTAL,
                                  0)
                           ,0)) CWE,
                    sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
                     CALL_TALK_TIME,0)) PTA,
                    sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
                     CALL_TALK_TIME,0)) CTA,
                    sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
                     AGENT_WRAP_TIME_NAC,0)) PWA,
                    sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
                     AGENT_WRAP_TIME_NAC,0)) CWA,
                    count(DISTINCT(CASE
                                   WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
                                   AND party_id <> -1
                                   THEN
                                      PARTY_ID
                                   END
                                   )
                           ) CCU,
                    count(DISTINCT(CASE
                                  WHEN cal.report_date = &BIS_PREVIOUS_ASOF_DATE
                                  AND party_id <> -1
                                  THEN
                                     PARTY_ID
                                  END
                                  )
                           ) PCU,
                    sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
                     AGENT_SR_CREATED,0)) PSR,
                    sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
                     AGENT_SR_CREATED,0)) CSR,
                    sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
                     AGENT_LEADS_CREATED,0)) PLE,
                    sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
                     AGENT_LEADS_CREATED,0)) CLE,
                    sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
                     AGENT_OPPORTUNITIES_CREATED,0)) POP,
                    sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
                     AGENT_OPPORTUNITIES_CREATED,0)) COP
              FROM bix_ai_call_details_mv mv,
                   fii_time_rpt_struct cal
              WHERE mv.time_id        = cal.time_id
		    AND mv.row_type = :l_cust_row_type
              AND   mv.period_type_id = cal.period_type_id
              AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN) =
                                        cal.record_type_id
              AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE,
                                      &BIS_PREVIOUS_ASOF_DATE) ';

l_sqltext := l_sqltext || l_call_where_clause ||
             '
              ) fresh,
              (
              SELECT
                    nvl(SUM( CASE when
                              period_start_date = &BIS_PREVIOUS_EFFECTIVE_START_DATE
                              then
                               decode(media_item_type,
                                  ''TELE_INB'',CALL_CONT_CALLS_OFFERED_NA,
                                  ''TELE_DIRECT'',CALL_CONT_CALLS_OFFERED_NA,
                                  0)
                              else
                                 0
                              end),0) PIOC,
                    nvl(SUM( CASE when
                              period_start_date = &BIS_CURRENT_EFFECTIVE_START_DATE
                              then
                               decode(media_item_type,
                                  ''TELE_INB'',CALL_CONT_CALLS_OFFERED_NA,
                                  ''TELE_DIRECT'',CALL_CONT_CALLS_OFFERED_NA,
                                  0)
                              else
                                 0
                              end),0) CIOC,
                    nvl(SUM( CASE when
                              period_start_date = &BIS_PREVIOUS_EFFECTIVE_START_DATE
                              then
                               decode(media_item_type,
                                  ''TELE_INB'',CALL_CONT_CALLS_HANDLED_TOT_NA,
                                  ''TELE_DIRECT'',CALL_CONT_CALLS_HANDLED_TOT_NA,
                                  0)
                              else
                                 0
                              end),0) PIHC,
                    nvl(SUM( CASE when
                              period_start_date = &BIS_CURRENT_EFFECTIVE_START_DATE
                              then
                               decode(media_item_type,
                                  ''TELE_INB'',CALL_CONT_CALLS_HANDLED_TOT_NA,
                                  ''TELE_DIRECT'',CALL_CONT_CALLS_HANDLED_TOT_NA,
                                  0)
                              else
                                 0
                              end),0) CIHC,
                    nvl(SUM(decode(period_start_date,&BIS_PREVIOUS_EFFECTIVE_START_DATE,
                               CALL_CONT_CALLS_HANDLED_TOT_NA,NULL)),0) PHAC,
                    nvl(SUM(decode(period_start_date,&BIS_CURRENT_EFFECTIVE_START_DATE,
                               CALL_CONT_CALLS_HANDLED_TOT_NA,NULL)),0) CHAC
              FROM bix_ai_call_details_mv mv
              WHERE time_id IN ( to_char(&BIS_CURRENT_EFFECTIVE_START_DATE,''J''),
                                 to_char(&BIS_PREVIOUS_EFFECTIVE_START_DATE,''J''))
              AND   mv.period_type_id = :l_period_type_id
		    AND mv.row_type = :l_class_row_type
              AND period_start_time = :l_period_start_time ';

l_sqltext := l_sqltext || l_call_where_clause ||
             '
             ) continued,
             (
              SELECT
                    sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
                     LOGIN_TIME,0)) PLO,
                    sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
                     LOGIN_TIME,0)) CLO,
                    sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
                     AVAILABLE_TIME,0)) PAV,
                    sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
                     AVAILABLE_TIME,0)) CAV,
                    sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
                     IDLE_TIME,0)) PID,
                    sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
                     IDLE_TIME,0)) CID
              FROM bix_agent_session_f sess,
                   fii_time_rpt_struct cal
              WHERE sess.time_id        = cal.time_id
              AND   sess.period_type_id = cal.period_type_id
              AND application_id = :l_application_id
              AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN) =
                                        cal.record_type_id
              AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE,
                                      &BIS_PREVIOUS_ASOF_DATE) ';

l_sqltext := l_sqltext || l_session_where_clause ||
             '
             ) sess ';


/****
 l_sqltext :=  '
	SELECT
	75   BIX_PMV_AI_SL,
	80   BIX_PMV_AI_PREVSL,
	90   BIX_PMV_AI_SLGOAL,
	90   BIX_PMV_AI_PREVSLGOAL,
	36   BIX_PMV_AI_SPANS,
	36   BIX_PMV_AI_PREVSPANS,
	34.2 BIX_PMV_AI_ABANRATE,
	34.2 BIX_PMV_AI_PREVABANRATE,
	30   BIX_PMV_AI_TRANRATE,
	30   BIX_PMV_AI_PREVTRANRATE,
	30   BIX_PMV_AI_INCALLHAND,
	30   BIX_PMV_AI_PREVINCALLHAND,
	273000 BIX_PMV_AI_DIALED,
	273000 BIX_PMV_AI_PREVDIALED,
	242970 BIX_PMV_AI_WEBCALL,
	242970 BIX_PMV_AI_PREVWEBCALL,
	268000 BIX_PMV_AI_AVAILRATE,
	268000 BIX_PMV_AI_PREVAVAILRATE,
	246560 BIX_PMV_AI_UTILRATE,
	246560 BIX_PMV_AI_PREVUTILRATE,
	18500  BIX_PMV_AI_AVGTALK,
	18500  BIX_PMV_AI_PREVAVGTALK,
	19240  BIX_PMV_AI_AVGWRAP,
	19240  BIX_PMV_AI_PREVAVGWRAP,
	5.2    BIX_PMV_AI_HANDPERHR,
	5.2    BIX_PMV_AI_PREVHANDPERHR,
	5.824  BIX_PMV_AI_CUST,
	5.824  BIX_PMV_AI_PREVCUST,
	56     BIX_PMV_AI_SRCR,
	56     BIX_PMV_AI_PREVSRCR,
	54.5   BIX_PMV_AI_LECR,
	54.5   BIX_PMV_AI_PREVLECR
	FROM DUAL ';

****/

p_sql_text := l_sqltext;

l_custom_rec.attribute_name := ':l_cust_row_type';
l_custom_rec.attribute_value:= 'CDPR';
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;

l_custom_rec.attribute_name := ':l_class_row_type';
l_custom_rec.attribute_value:= 'CDR';
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;

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

l_custom_rec.attribute_name := ':l_application_id';
l_custom_rec.attribute_value := 696;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;

p_custom_output.EXTEND;
p_custom_output(p_custom_output.COUNT) := l_custom_rec;

--insert into bixtest values ('KPI:');
--insert into bixtest values (l_sqltext);
--commit;

EXCEPTION
WHEN OTHERS THEN
NULL;
END GET_SQL;
END  BIX_PMV_AI_KPI_PRTLT_PKG;

/
