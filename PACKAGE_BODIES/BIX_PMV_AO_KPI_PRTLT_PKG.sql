--------------------------------------------------------
--  DDL for Package Body BIX_PMV_AO_KPI_PRTLT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_AO_KPI_PRTLT_PKG" AS
/*$Header: bixokpip.plb 115.5 2004/03/26 18:05:32 suray noship $ */

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
l_contgoal  NUMBER;
l_abangoal  NUMBER;
l_custom_rec       BIS_QUERY_ATTRIBUTES;
l_period_type_id   NUMBER := 1;
l_period_from  DATE;
l_period_to    DATE;
l_call_center VARCHAR2(3000);
l_call_where_clause VARCHAR2(3000);
l_session_where_clause VARCHAR2(3000);
l_source_code_where_clause VARCHAR2(3000);
l_sess_source_where_clause VARCHAR2(3000);
l_campaign_where_clause VARCHAR2(3000);
l_schedule_where_clause VARCHAR2(3000);
l_view_by            VARCHAR2(3000);
l_campaign_id VARCHAR2(3000);
l_schedule_id VARCHAR2(3000);
l_source_code_id VARCHAR2(3000);
l_agent_group VARCHAR2(3000);

BEGIN
 p_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
 l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;

IF (FND_PROFILE.DEFINED('BIX_PMV_AO_TARCONT')) THEN
begin
   l_contgoal := TO_NUMBER(FND_PROFILE.VALUE('BIX_PMV_AO_TARCONT'));
exception
when others then
    l_contgoal:=0;
end;
ELSE
   l_contgoal := 0;
END IF;

IF l_contgoal IS NULL THEN
  l_contgoal := 0;
END IF;


IF (FND_PROFILE.DEFINED('BIX_PMV_AO_ABANRATEGOAL')) THEN
begin
   l_abangoal := TO_NUMBER(FND_PROFILE.VALUE('BIX_PMV_AO_ABANRATEGOAL'));
exception
when others then
    l_abangoal:=0;
end;
ELSE
   l_abangoal := 0;
END IF;

IF l_abangoal IS NULL THEN
  l_abangoal := 0;
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
   l_call_where_clause := ' AND mv.server_group_id IN (:l_call_center) ';
   l_session_where_clause := ' AND server_group_id IN (:l_call_center) ';
END IF;
IF l_campaign_id IS NOT NULL THEN
   l_campaign_where_clause := ' AND mv.campaign_id IN (:l_campaign_id) ';
END IF;
IF l_schedule_id IS NOT NULL THEN
   l_schedule_where_clause := ' AND mv.schedule_id IN (:l_schedule_id) ';
END IF;
IF l_source_code_id IS NOT NULL THEN
   l_source_code_where_clause := ' AND mv.campaign_id in (select source_code_for_id from
   ams_source_codes where source_code_id IN (:l_source_code_id) and arc_source_code_for=''CAMP'' and active_flag=''Y'') ';
   l_sess_source_where_clause := ' AND sess.campaign_id in (select source_code_for_id from
   ams_source_codes where source_code_id IN (:l_source_code_id) and arc_source_code_for=''CAMP'' and active_flag=''Y'') ';
END IF;

/*
l_sqltext := '
SELECT
1 BIX_PMV_AO_CONTPERHR,
1 BIX_PMV_AO_PREVCONTPERHR,
1 BIX_PMV_AO_TARCONT,
1 BIX_PMV_AO_PREVTARCONT,
1 BIX_PMV_AO_PORESP,
1 BIX_PMV_AO_PREVPORESP,
1 BIX_PMV_AO_ABANRATE,
1 BIX_PMV_AO_PREVABANRATE,
1 BIX_PMV_AO_ABANRATE_GL,
1 BIX_PMV_AO_PREVARGOAL,
1 BIX_PMV_AO_OUTCALLHAND,
1 BIX_PMV_AO_PREVOUTCALLHAND,
1 BIX_PMV_AO_SCHED,
1 BIX_PMV_AO_PREVSCHED,
1 BIX_PMV_AO_AVAILRATE,
1 BIX_PMV_AO_PREVAVAILRATE,
1 BIX_PMV_AO_UTILRATE,
1 BIX_PMV_AO_PREVUTILRATE,
1 BIX_PMV_AO_AVGTALK,
1 BIX_PMV_AO_PREVAVGTALK,
1 BIX_PMV_AO_AVGWRAP,
1 BIX_PMV_AO_PREVAVGWRAP,
1 BIX_PMV_AO_HANDPERHR,
1 BIX_PMV_AO_PREVHANDPERHR,
1 BIX_PMV_AO_CUST,
1 BIX_PMV_AO_PREVCUST,
1 BIX_PMV_AO_LECR,
1 BIX_PMV_AO_PREVLECR,
1 BIX_PMV_AO_OPCR,
1 BIX_PMV_AO_PREVOPCR,
1 BIX_PMV_AO_SRCR,
1 BIX_PMV_AO_PREVSRCR
FROM DUAL ';
***/



l_sqltext := '
	SELECT
           SUM(CCONT/(DECODE(CLO,0,NULL,CLO)/3600))  BIX_PMV_AO_CONTPERHR ,
          SUM(PCONT/(DECODE(PLO,0,NULL,PLO)/3600)) BIX_PMV_AO_PREVCONTPERHR,
          SUM(CPR) BIX_PMV_AO_PORESP,
          SUM(PPR) BIX_PMV_AO_PREVPORESP,
          '||l_contgoal||' BIX_PMV_AO_TARCONT,
          '||l_contgoal||' BIX_PMV_AO_PREVTARCONT,
           sum(PAB)*100/
           decode(sum(nvl(PIOPRED,0)+nvl(PIOCPRED,0)),0,NULL,
		       sum(nvl(PIOPRED,0)+nvl(PIOCPRED,0)))  BIX_PMV_AO_PREVABANRATE,
           sum(CAB)*100/
             decode(sum(nvl(CIOPRED,0)+nvl(CIOCPRED,0)),0,NULL,
		          sum(nvl(CIOPRED,0)+nvl(CIOCPRED,0)))  BIX_PMV_AO_ABANRATE,
              /* Added for US Abandonment Rate */
                     sum(PABFTC)*100/
           decode(sum(nvl(PIOPRED,0)+nvl(PIOCPRED,0)),0,NULL,
                  sum(nvl(PIOPRED,0)+nvl(PIOCPRED,0)))  BIX_PMV_AO_US_ABANRATE_PP,
           sum(CABFTC)*100/
             decode(sum(nvl(CIOPRED,0)+nvl(CIOCPRED,0)),0,NULL,
		          sum(nvl(CIOPRED,0)+nvl(CIOCPRED,0)))  BIX_PMV_AO_US_ABANRATE_CP,
              /* End of additions */
            '||l_abangoal||' BIX_PMV_AO_ABANRATE_GL,
            '||l_abangoal||' BIX_PMV_AO_PREVARGOAL,
           sum(csched) BIX_PMV_AO_SCHED,
            sum(psched) BIX_PMV_AO_PREVSCHED,
           sum(CHA) BIX_PMV_AO_OUTCALLHAND,
           sum(PHA) BIX_PMV_AO_PREVOUTCALLHAND,
      sum(nvl(CLO,0)-nvl(CID,0))*100/
      decode(sum(CLO),0,NULL,sum(CLO)) BIX_PMV_AO_AVAILRATE,
      sum(nvl(PLO,0)-nvl(PID,0))*100/
	 decode(sum(PLO),0,NULL,sum(PLO)) BIX_PMV_AO_PREVAVAILRATE,
      sum(nvl(CLO,0)-nvl(CAV,0)-nvl(CID,0))*100/
      decode(sum(CLO),0,NULL,sum(CLO)) BIX_PMV_AO_UTILRATE,
      sum(nvl(PLO,0)-nvl(PAV,0)-nvl(PID,0))*100/
      decode(sum(PLO),0,NULL,sum(PLO)) BIX_PMV_AO_PREVUTILRATE,
           sum(PTA)/
           decode(sum(nvl(PHA,0)+nvl(PHAC,0)),0,NULL,
		        sum(nvl(PHA,0)+nvl(PHAC,0)))  BIX_PMV_AO_PREVAVGTALK,
           sum(CTA)/
             decode(sum(nvl(CHA,0)+nvl(CHAC,0)),0,NULL,
		          sum(nvl(CHA,0)+nvl(CHAC,0)))  BIX_PMV_AO_AVGTALK,
           sum(PWA)/
           decode(sum(nvl(PHA,0)+nvl(PHAC,0)),0,NULL,
		        sum(nvl(PHA,0)+nvl(PHAC,0)))  BIX_PMV_AO_PREVAVGWRAP,
        sum(CWA)/
             decode(sum(nvl(CHA,0)+nvl(CHAC,0)),0,NULL,
		          sum(nvl(CHA,0)+nvl(CHAC,0)))  BIX_PMV_AO_AVGWRAP,
      round( sum(CHA)*3600/
             decode(sum(CLO),0,NULL,sum(CLO)),1)  BIX_PMV_AO_HANDPERHR,
      round(sum(PHA)*3600/
             decode(sum(PLO),0,NULL,sum(PLO)),1) BIX_PMV_AO_PREVHANDPERHR,
       sum(CCU) BIX_PMV_AO_CUST,
       sum(PCU) BIX_PMV_AO_PREVCUST,
       sum(CSR) BIX_PMV_AO_SRCR,
       sum(PSR) BIX_PMV_AO_PREVSRCR,
	   sum(CLE)   BIX_PMV_AO_LECR,
	   sum(PLE)   BIX_PMV_AO_PREVLECR,
	   sum(COP)   BIX_PMV_AO_OPCR,
	   sum(POP)   BIX_PMV_AO_PREVOPCR
	FROM
        (
             SELECT
                  sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
				              AGENTCALL_CONTACT_COUNT ,0
						    )
                     ) PCONT,
                    sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
				               AGENTCALL_CONTACT_COUNT ,0
						    )
                     ) CCONT,
                  sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
				              AGENTCALL_PR_COUNT ,0
						    )
                     ) PPR,
                    sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
				               AGENTCALL_PR_COUNT ,0
						    )
                     ) CPR,
                sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
				              CALL_CALLS_OFFERED_TOTAL,0
						    )
                     ) PIO,
                    sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
				               CALL_CALLS_OFFERED_TOTAL,0
						    )
                     ) CIO,
                     sum(
                     case when dialing_method=''PRED'' then
	                     decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
		     				              CALL_CALLS_OFFERED_TOTAL,0
		     	    )
            		     else
		     		0
                    end
		              ) PIOPRED,
		       sum(
		      case when dialing_method=''PRED'' then
		       decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
		     				               CALL_CALLS_OFFERED_TOTAL,0
		     	)
        		       else
		     	    0
                end
		     	  )
		           CIOPRED,
                    sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
                    CALL_CALLS_HANDLED_TOTAL ,0)) PHA,
                    sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
                     CALL_CALLS_HANDLED_TOTAL,0)) CHA,
                    sum(
                    case when dialing_method=''PRED'' then
                    decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
				         CALL_CALLS_ABANDONED,0)
		     else 0
                   end
                     ) PAB,
                    sum(
                    case when dialing_method=''PRED'' then
                    decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
				              CALL_CALLS_ABANDONED,0)

		    else 0
				        end      ) CAB,
             /* Added for US Abandonment rate */
                    sum(
                    case when dialing_method=''PRED'' then
                    decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
				         CALL_CALLS_ABANDONED_US,0)
		     else 0
                   end
                     ) PABFTC,
                    sum(
                    case when dialing_method=''PRED'' then
                    decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
				              CALL_CALLS_ABANDONED_US,0)

		    else 0
				        end      ) CABFTC,
                   /* End of additions */
                    sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
				              CALL_CALLS_TRANSFERRED,0 )) PTR,
                    sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
				         CALL_CALLS_TRANSFERRED ,0)) CTR,
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
                                   WHEN cal.report_date = &BIS_CURRENT_ASOF_DATE
                                   THEN
                                      schedule_id
                                   END
                                   )
                           ) CSCHED,
                      count(DISTINCT(CASE
                                  WHEN cal.report_date = &BIS_PREVIOUS_ASOF_DATE
                                  THEN
                                     schedule_id
                                  END
                                  )
                           ) PSCHED,

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
              FROM bix_ao_call_details_mv mv,
                   fii_time_rpt_struct cal
              WHERE mv.time_id        = cal.time_id
		      AND mv.row_type = :l_cust_row_type
              AND   mv.period_type_id = cal.period_type_id
              AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN) =
                                        cal.record_type_id
              AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE,
                                      &BIS_PREVIOUS_ASOF_DATE) ';

l_sqltext := l_sqltext || l_call_where_clause ||l_source_code_where_clause||
             '
              ) fresh,
              (
              SELECT
                    nvl(SUM( CASE when
                              period_start_date = &BIS_PREVIOUS_EFFECTIVE_START_DATE
                              then
                                CALL_CONT_CALLS_OFFERED_NA
                              else
                                 0
                              end),0) PIOC,
                    nvl(SUM( CASE when
                              period_start_date = &BIS_CURRENT_EFFECTIVE_START_DATE
                              then
                               CALL_CONT_CALLS_OFFERED_NA
                             else
                                 0
                              end),0) CIOC,
                    nvl(SUM( CASE when
                              period_start_date = &BIS_PREVIOUS_EFFECTIVE_START_DATE
                              then
                                CALL_CONT_CALLS_OFFERED_NA
                              else
                                 0
                              end),0) PIOCPRED,
                    nvl(SUM( CASE when
                              period_start_date = &BIS_CURRENT_EFFECTIVE_START_DATE
                              and dialing_method=''PRED''
                              then
                               CALL_CONT_CALLS_OFFERED_NA
                             else
                                 0
                              end),0) CIOCPRED,
                  nvl(SUM( CASE when
                              period_start_date = &BIS_PREVIOUS_EFFECTIVE_START_DATE
                              then
                              CALL_CONT_CALLS_HANDLED_TOT_NA
                             else
                                 0
                              end),0) PIHC,
                    nvl(SUM( CASE when
                              period_start_date = &BIS_CURRENT_EFFECTIVE_START_DATE
                              then
                                CALL_CONT_CALLS_HANDLED_TOT_NA
                              else
                                 0
                              end),0) CIHC,
                    nvl(SUM(decode(period_start_date,&BIS_PREVIOUS_EFFECTIVE_START_DATE,
                               CALL_CONT_CALLS_HANDLED_TOT_NA,NULL)),0) PHAC,
                    nvl(SUM(decode(period_start_date,&BIS_CURRENT_EFFECTIVE_START_DATE,
                               CALL_CONT_CALLS_HANDLED_TOT_NA,NULL)),0) CHAC
              FROM bix_ao_call_details_mv mv
              WHERE time_id IN ( to_char(&BIS_CURRENT_EFFECTIVE_START_DATE,''J''),
                                 to_char(&BIS_PREVIOUS_EFFECTIVE_START_DATE,''J''))
              AND   mv.period_type_id = :l_period_type_id
		    AND mv.row_type = :l_class_row_type
 ';

l_sqltext := l_sqltext || l_call_where_clause ||l_source_code_where_clause||
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

/* Before passing l_sqltext to the calling proc, we trim it up a bit */
l_sqltext:=replace(replace(replace(replace(replace(l_sqltext,
'      ',' '),'     ',' '),'    ',' '),'   ',' '),'  ',' ');
p_sql_text := l_sqltext;


l_custom_rec.attribute_name := ':l_cust_row_type';
l_custom_rec.attribute_value:= 'C';
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;

l_custom_rec.attribute_name := ':l_class_row_type';
l_custom_rec.attribute_value:= 'C';
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

--insert into bixtest values ('KPI:');
--insert into bixtest values (l_sqltext);
--commit;



EXCEPTION
WHEN OTHERS THEN
NULL;
END GET_SQL;
END  BIX_PMV_AO_KPI_PRTLT_PKG;

/
