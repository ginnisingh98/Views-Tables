--------------------------------------------------------
--  DDL for Package Body BIX_PMV_EMC_AGTDET_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_EMC_AGTDET_RPT_PKG" AS
/*$Header: bixead1r.plb 120.1 2005/09/14 16:24:03 anasubra noship $ */

PROCEDURE GET_SQL(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                  p_sql_text           OUT NOCOPY VARCHAR2,
                  p_custom_output      OUT NOCOPY bis_query_attributes_TBL
                  )
AS
l_sqltext	      VARCHAR2(32000) ;
l_where_clause        VARCHAR2(1000) ;
l_where_clause2        VARCHAR2(1000) ;
l_ses_where_clause    VARCHAR2(1000);
l_as_of_date   DATE;
l_period_type	varchar2(2000);
l_comp_type    varchar2(2000);
l_sql_errm      varchar2(32000);
l_agent_cost      NUMBER;
l_custom_rec       BIS_QUERY_ATTRIBUTES;
l_period_type_id   NUMBER := 1;
l_record_type_id   NUMBER ;
l_account      VARCHAR2(32000);
l_start_date   DATE;
l_end_date     DATE;
l_period_from  DATE;
l_period_to    DATE;
l_period_start_date  DATE;
l_classification VARCHAR2(32000);
l_view_by   varchar2(1000);
l_agent_group VARCHAR2(1000);
l_application_id  NUMBER := 680;
l_row_type VARCHAR2(10) := 'ACR';

BEGIN

--
--Initialize p_custom_output
--

 p_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
 l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;

-- Get the parameters

BIX_PMV_DBI_UTL_PKG.get_emc_page_params( p_page_parameter_tbl,
                                         l_as_of_date,
                                         l_period_type,
                                         l_record_type_id,
                                         l_comp_type,
                                         l_account,
          			                l_classification,
	          		                l_view_by
                                       );


  IF (p_page_parameter_tbl.count > 0) THEN

     FOR i IN p_page_parameter_tbl.first..p_page_parameter_tbl.last LOOP

       IF p_page_parameter_tbl(i).parameter_name = 'ORGANIZATION+JTF_ORG_SUPPORT_GROUP' THEN
          l_agent_group := p_page_parameter_tbl(i).parameter_id;
       END IF;

     END LOOP;
  END IF;


-- If the account is not 'All'

 IF l_account IS NOT NULL THEN
 l_where_clause := 'AND email_account_id IN (:l_account) ';
 l_where_clause2 := 'WHERE email_account_id IN (:l_account) ';
 END IF;

 IF l_classification IS NOT NULL THEN
 l_where_clause := l_where_clause || ' AND email_classification_id IN (:l_classification) ';
 END IF;

 IF l_agent_group IS NOT NULL THEN
 l_where_clause := l_where_clause || ' AND EXISTS (
				            SELECT 1
                                FROM   jtf_rs_group_members mem
                                WHERE  fact.agent_id = mem.resource_id
                                AND    mem.group_id IN (:l_agent_group)
                                AND    nvl(mem.delete_flag, ''N'') <> ''Y'' ) ';


 l_ses_where_clause :=  ' AND EXISTS (
				            SELECT 1
                                FROM   jtf_rs_group_members mem
                                WHERE  fact.agent_id = mem.resource_id
                                AND    mem.group_id IN (:l_agent_group)
                                AND    nvl(mem.delete_flag, ''N'') <> ''Y'' ) ';
 IF l_account IS NOT NULL THEN
 l_where_clause2 := l_where_clause2 || ' AND  resource_id IN (
				            SELECT  mem.resource_id
                                FROM   jtf_rs_group_members mem
                                WHERE  mem.group_id IN (:l_agent_group)
                                AND    nvl(mem.delete_flag, ''N'') <> ''Y'' ) ';
  ELSE

 l_where_clause2 := ' WHERE resource_id IN (
				            SELECT  mem.resource_id
                                FROM   jtf_rs_group_members mem
                                WHERE  mem.group_id IN (:l_agent_group)
                                AND    nvl(mem.delete_flag, ''N'') <> ''Y'' ) ';
  END IF;
 END IF;



l_sqltext :=
'SELECT
vl.resource_name BIX_AGENT,
nvl(sum(CURR_INBOX),0) BIX_EMC_RECCOUNT,
nvl(sum(sum(CURR_INBOX)) over(),0) BIX_PMV_TOTAL1,
nvl(sum(CURR_FETCH),0) BIX_EMC_FETCH,
nvl(sum(sum(CURR_FETCH)) over(),0) BIX_PMV_TOTAL2,
nvl(sum(CURR_TRANIN),0) BIX_EMC_TRANIN,
nvl(sum(sum(CURR_TRANIN)) over(),0) BIX_PMV_TOTAL3,
nvl(sum(CURR_ASSIGN),0) BIX_EMC_ASSIGN,
nvl(sum(sum(CURR_ASSIGN)) over(),0) BIX_PMV_TOTAL4,
nvl(sum(CURR_AUTO),0) BIX_EMC_AUTOROUTE,
nvl(sum(sum(CURR_AUTO)) over(),0) BIX_PMV_TOTAL5,
nvl(sum(CURR_PROC),0) BIX_EMC_PROCECOUNT,
nvl(sum(sum(CURR_PROC)) over(),0) BIX_PMV_TOTAL6,
nvl(sum(CURR_REPLD),0) BIX_EMC_REPLD,
nvl(sum(sum(CURR_REPLD)) over(),0) BIX_PMV_TOTAL7,
nvl(sum(PREV_REPLD),0) BIX_EMC_PRREPLD,
nvl(sum(CURR_DEL),0) BIX_EMC_DELETED,
nvl(sum(sum(CURR_DEL)) over(),0) BIX_PMV_TOTAL8,
nvl(sum(CURR_TRANOUT),0) BIX_EMC_TRANOUT,
nvl(sum(sum(CURR_TRANOUT)) over(),0) BIX_PMV_TOTAL9,
nvl(sum(CURR_REROUTED),0) BIX_EMC_REROUTED,
nvl(sum(sum(CURR_REROUTED)) OVER(),0) BIX_PMV_TOTAL16,
nvl(sum(CURR_MSGSGOAL),0)*100/sum(CURR_REPLD) BIX_EMC_MSGSGOAL_CP,
nvl(sum(sum(CURR_MSGSGOAL)) over(),0)*100/
	 sum(sum(CURR_REPLD)) over() BIX_PMV_TOTAL14,
	 (nvl(sum(CURR_MSGSGOAL),0)*100/sum(CURR_REPLD)) -
     	 (nvl(sum(sum(CURR_MSGSGOAL)) over(),0)*100/(sum(sum(CURR_REPLD)) over())) BIX_EMC_AGCOMP1,
nvl(sum(PREV_MSGSGOAL),0)*100/sum(PREV_REPLD) BIX_EMC_PREVMSGSGOAL,
(NVL(SUM(curr_repld),0)/DECODE(SUM(curr_login_time),0,NULL,sum(curr_login_time)))  BIX_EMC_REPPERHR_CP,
(NVL(SUM(SUM(curr_repld)) OVER(),0)/DECODE(SUM(SUM(curr_login_time)) OVER(),0,NULL,SUM(sum(curr_login_time)) OVER() ))  BIX_PMV_TOTAL17,
(NVL(SUM(curr_repld),0)/DECODE(SUM(curr_login_time),0,NULL,sum(curr_login_time)) ) -
 ( NVL(SUM(SUM(curr_repld)) OVER(),0)/DECODE(SUM(SUM(curr_login_time)) OVER(),0,NULL,SUM(sum(curr_login_time)) OVER() ) ) BIX_EMC_AGCOMP3,
NVL(SUM(prev_repld),0)/DECODE(SUM(prev_login_time),0,NULL,sum(prev_login_time)) BIX_EMC_PREVREPPERHR,
nvl(sum(CURR_ARTIME),0)/(3600*sum(CURR_REPLD)) BIX_EMC_ARTIME_CP,
nvl(sum(sum(CURR_ARTIME)) over(),0)/
	(3600*sum(sum(CURR_REPLD)) over()) BIX_PMV_TOTAL15,
(nvl(sum(CURR_ARTIME),0)/(3600*sum(CURR_REPLD)))- (nvl(sum(sum(CURR_ARTIME)) over(),0)/(3600*sum(sum(CURR_REPLD)) over())) BIX_EMC_AGCOMP2,
nvl(sum(CURR_SR),0) BIX_EMC_SR_CP,
nvl(sum(sum(CURR_SR)) over(),0) BIX_PMV_TOTAL10,
nvl(sum(CURR_SR),0)*100/sum(sum(CURR_SR)) over() BIX_EMC_PERTOTAL1,
nvl(sum(CURR_LEADS),0) BIX_EMC_LEADS_CP,
nvl(sum(sum(CURR_LEADS)) over(),0) BIX_PMV_TOTAL18,
nvl(sum(CURR_LEADS),0)*100/sum(sum(CURR_LEADS)) over() BIX_EMC_PERTOTAL2,
(NVL(SUM(curr_repld),0)/DECODE(SUM(curr_login_time),0,NULL,sum(curr_login_time)))  BIX_CALC_ITEM1,
(NVL(SUM(SUM(curr_repld)) OVER(),0)/DECODE(SUM(SUM(curr_login_time)) OVER(),0,NULL,SUM(sum(curr_login_time)) OVER() ))  BIX_CALC_ITEM2,
(NVL(SUM(prev_repld),0)/DECODE(SUM(prev_login_time),0,NULL,sum(prev_login_time)))  BIX_CALC_ITEM3,
(NVL(SUM(SUM(prev_repld)) OVER(),0)/DECODE(SUM(SUM(prev_login_time)) OVER(),0,NULL,SUM(sum(prev_login_time)) OVER() ))  BIX_CALC_ITEM4
FROM (
       SELECT  agent_id                                    AGENT_ID,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
     nvl(EMAILS_FETCHED_IN_PERIOD,0)+nvl(EMAILS_TRNSFRD_IN_IN_PERIOD,0)+
	nvl(EMAILS_AUTO_ROUTED_IN_PERIOD,0)+nvl(EMAILS_ASSIGNED_IN_PERIOD,0),NULL)) CURR_INBOX,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
                     EMAILS_FETCHED_IN_PERIOD,NULL))         CURR_FETCH,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
                     EMAILS_TRNSFRD_IN_IN_PERIOD,NULL))         CURR_TRANIN,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
                     EMAILS_ASSIGNED_IN_PERIOD,NULL))         CURR_ASSIGN,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
                     EMAILS_AUTO_ROUTED_IN_PERIOD,NULL))         CURR_AUTO,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
     nvl(EMAILS_REPLIED_IN_PERIOD,0)+nvl(EMAILS_TRNSFRD_OUT_IN_PERIOD,0)+
	nvl(EMAILS_DELETED_IN_PERIOD,0)+nvl(EMAILS_REROUTED_IN_PERIOD,0) ,NULL))   CURR_PROC,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
		     EMAILS_REPLIED_IN_PERIOD,NULL))                    CURR_REPLD,
        sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
                     EMAILS_REPLIED_IN_PERIOD,NULL))                    PREV_REPLD,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
		     EMAILS_DELETED_IN_PERIOD,NULL))                    CURR_DEL,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
                     EMAILS_TRNSFRD_OUT_IN_PERIOD,NULL))         CURR_TRANOUT,
        sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
                     EMAILS_REROUTED_IN_PERIOD,NULL))         CURR_REROUTED,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
                     AGENT_EMAILS_RPLD_BY_GOAL,NULL))         CURR_MSGSGOAL,
	sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
                     AGENT_EMAILS_RPLD_BY_GOAL,NULL))         PREV_MSGSGOAL,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
		     AGENT_RESP_TIME_IN_PERIOD,NULL))                    CURR_ARTIME,
	sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
		     SR_CREATED_IN_PERIOD,NULL))                    CURR_SR,
         sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
                     LEADS_CREATED_IN_PERIOD,NULL))                    CURR_LEADS,
     NULL CURR_LOGIN_TIME,
	NULL PREV_LOGIN_TIME
	FROM bix_email_details_mv fact,
  	   fii_time_rpt_struct cal
      WHERE fact.time_id = cal.time_id
	 AND   fact.row_type = :l_row_type
      AND fact.period_type_id = cal.period_type_id
      AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
      AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN)=cal.record_type_id '
	  || l_where_clause ||
      ' GROUP BY agent_id
	 UNION ALL
	 SELECT agent_id,
              NULL                                        CURR_INBOX,
              NULL                                        CURR_FETCHED,
              NULL                                        CURR_TRANIN,
              NULL                                        CURR_ASSIGN,
              NULL                                        CURR_AUTO,
              NULL                                        CURR_PROC,
              NULL                                        CURR_REPLD,
              NULL                                        PREV_REPLD,
              NULL                                        CURR_DEL,
              NULL                                        CURR_TRANOUT,
              NULL                                        CURR_REROUTED,
              NULL                                        CURR_MSGSGOAL,
              NULL                                        PREV_MSGSGOAL,
              NULL                                        CURR_ARTIME,
              NULL                                        CURR_SR,
              NULL                                        CURR_LEADS    ,
              SUM(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,LOGIN_TIME))/3600 CURR_LOGIN_TIME_IN_PERIOD,
              SUM(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,LOGIN_TIME))/3600 PREV_LOGIN_TIME_IN_PERIOD
      FROM   bix_agent_session_f fact,
             fii_time_rpt_struct cal
      WHERE fact.application_id = :l_application_id
      AND fact.time_id = cal.time_id
      AND fact.period_type_id = cal.period_type_id
      AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
      AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN) =  cal.record_type_id ' || l_ses_where_clause ||
       ' GROUP BY agent_id
	  UNION ALL
      SELECT  resource_id                                 AGENT_ID,
              NULL                                        CURR_INBOX,
              NULL                                        CURR_FETCHED,
              NULL                                        CURR_TRANIN,
              NULL                                        CURR_ASSIGN,
              NULL                                        CURR_AUTO,
              NULL                                        CURR_PROC,
              NULL                                        CURR_REPLD,
              NULL                                        PREV_REPLD,
              NULL                                        CURR_DEL,
              NULL                                        CURR_TRANOUT,
              NULL                                        CURR_REROUTED,
              NULL                                        CURR_MSGSGOAL,
              NULL                                        PREV_MSGSGOAL,
              NULL                                        CURR_ARTIME,
              NULL                                        CURR_SR,
              NULL                                        CURR_LEADS    ,
		    NULL                                        CURR_LOGIN_TIME,
		    NULL                                        PREV_LOGIN_TIME
       from iem_agents '
       || l_where_clause2 ||
	  '  ) summ,
         jtf_rs_resource_extns_vl vl
         WHERE summ.agent_id = vl.resource_id
	    GROUP BY vl.resource_id, vl.resource_name ';

--START 001

l_sqltext := 'SELECT  * FROM ( '||l_sqltext ||' ) WHERE
ABS(NVL(BIX_EMC_RECCOUNT   ,0))+ABS(NVL(BIX_EMC_FETCH  ,0))+ABS(NVL(BIX_EMC_TRANIN,0))+ABS(NVL(BIX_EMC_ASSIGN   ,0))+
ABS(NVL(BIX_EMC_AUTOROUTE  ,0))+ABS(NVL(BIX_EMC_PROCECOUNT   ,0))+ABS(NVL(BIX_EMC_REPLD,0))+ABS(NVL(BIX_EMC_DELETED   ,0))+
ABS(NVL(BIX_EMC_TRANOUT    ,0))+ABS(NVL(BIX_EMC_REROUTED ,0))+ABS(NVL(BIX_EMC_MSGSGOAL_CP  ,0))+ABS(NVL(BIX_EMC_AGCOMP1 ,0))+
ABS(NVL(BIX_EMC_REPPERHR_CP      ,0))+ABS(NVL(BIX_EMC_AGCOMP3   ,0))+ABS(NVL(BIX_EMC_ARTIME_CP   ,0))+ABS(NVL(BIX_EMC_AGCOMP2,0))+
+ABS(NVL(BIX_EMC_SR_CP,0))+ABS(NVL(BIX_EMC_PERTOTAL1,0))+ABS(NVL(BIX_EMC_LEADS_CP,0))+ABS(NVL(BIX_EMC_PERTOTAL2,0))
!=0  &ORDER_BY_CLAUSE ';

--END 001

p_sql_text := l_sqltext;

-- Insert account Bind Variable

l_custom_rec.attribute_name := ':l_application_id';
l_custom_rec.attribute_value:= l_application_id;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;

p_custom_output.EXTEND;
p_custom_output(p_custom_output.COUNT) := l_custom_rec;

IF ( l_account IS NOT NULL) THEN
l_custom_rec.attribute_name := ':l_account' ;
l_custom_rec.attribute_value:= l_account;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;
END IF;

IF ( l_classification IS NOT NULL) THEN
l_custom_rec.attribute_name := ':l_classification' ;
l_custom_rec.attribute_value:= l_classification;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;
END IF;


IF ( l_agent_group IS NOT NULL) THEN
l_custom_rec.attribute_name := ':l_agent_group' ;
l_custom_rec.attribute_value:= l_agent_group;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;
END IF;

l_custom_rec.attribute_name := ':l_row_type' ;
l_custom_rec.attribute_value:= l_row_type;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;

EXCEPTION
WHEN OTHERS THEN
NULL;
END GET_SQL;
END  BIX_PMV_EMC_AGTDET_RPT_PKG;

/
