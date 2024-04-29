--------------------------------------------------------
--  DDL for Package Body BIX_PMV_EMC_CUSTDET_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_EMC_CUSTDET_RPT_PKG" AS
/*$Header: bixecd1r.plb 120.0 2005/05/25 17:25:19 appldev noship $ */

PROCEDURE GET_SQL(p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
                  p_sql_text           OUT NOCOPY VARCHAR2,
                  p_custom_output      OUT NOCOPY bis_query_attributes_TBL
                  )
AS
l_sqltext	      VARCHAR2(32000) ;
l_where_clause        VARCHAR2(1000) ;
l_as_of_date   DATE;
l_period_type	varchar2(2000);
l_comp_type    varchar2(2000);
l_sql_errm      varchar2(32000);
l_agent_cost      NUMBER;
l_custom_rec       BIS_QUERY_ATTRIBUTES;
l_record_type_id   NUMBER ;
l_account      VARCHAR2(32000);
l_start_date   DATE;
l_end_date     DATE;
l_period_from  DATE;
l_period_to    DATE;
l_dummy_cust     NUMBER;
l_max_collect_date   VARCHAR2(100);
l_period_start_date  DATE;
l_unident_string VARCHAR2(100);
l_application_id NUMBER := 680;
l_classification VARCHAR2(32000);
l_view_by varchar2(1000);
l_row_type varchar2(10) := 'ACP';

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


-- If the account is not 'All'

 IF l_account IS NOT NULL THEN
 l_where_clause := 'AND email_account_id IN (:l_account) ';
 END IF;


 IF l_classification IS NOT NULL THEN
 l_where_clause := l_where_clause || ' AND email_classification_id IN (:l_classification) ';
 END IF;
--
--Retrieve the dummy (unidentified) customer id which is used by EMC
--
IF (FND_PROFILE.DEFINED('IEM_DEFAULT_CUSTOMER_ID')) THEN
   l_dummy_cust := TO_NUMBER(FND_PROFILE.VALUE('IEM_DEFAULT_CUSTOMER_ID'));
END IF;

--
--If it is null then set it to some invalid value so the SQL does not error
--out
--
IF l_dummy_cust IS NULL
THEN
   l_dummy_cust := -123456;
END IF;

--
--Retrieve the message UNIDENTIFIED from FND_MESSAGES
--
l_unident_string := FND_MESSAGE.GET_STRING('BIX','BIX_PMV_UNIDENT');

IF l_unident_string IS NULL OR l_unident_string = 'BIX_PMV_UNIDENT'
THEN
   l_unident_string := 'Not identified';
END IF;

-- If the account is not 'All'

 /* Get the MAX date for which data is collected in Email Summary table */

    BIS_COLLECTION_UTILITIES.get_last_refresh_dates('BIX_EMAIL_DETAILS_F',
                                                     l_start_date,
                                                     l_end_date,
                                                     l_period_from,
                                                     l_period_to
                                                   );


l_period_start_date := BIX_PMV_DBI_UTL_PKG.period_start_date(l_as_of_date,l_period_type);

 /* Get the MAX date for which data is collected in Email Summary table */

    BIS_COLLECTION_UTILITIES.get_last_refresh_dates('BIX_EMAIL_DETAILS_F',
                                                     l_start_date,
                                                     l_end_date,
                                                     l_period_from,
                                                     l_period_to
                                                   );
--
--If the data is not collected till AS OF DATE
--then get the accumulated measures from the MAX collected DATE time bucket
--if the max collect date falls within the current period
--

IF l_period_to BETWEEN l_period_start_date AND l_as_of_date
THEN
   l_max_collect_date := TO_CHAR(l_period_to,'DD/MM/YYYY');
ELSE
   l_max_collect_date := TO_CHAR(l_as_of_date,'DD/MM/YYYY');
END IF;


l_sqltext :=
'SELECT decode(hzp.party_id,'||l_dummy_cust||',:l_unident_string,hzp.party_name) BIX_EMC_CUSTOMER,
nvl(sum(curr_received),0)                         BIX_EMC_RCVD_CP,
nvl(sum(sum(curr_received)) over(), 0)            BIX_PMV_TOTAL16,
(NVL(SUM(curr_received),0) - SUM(prev_received)) /
    DECODE(SUM(prev_received),0,NULL,SUM(prev_received)) * 100 BIX_EMC_RCVDCHANGE,
(NVL(SUM(SUM(curr_received)) over(),0) - SUM(SUM(prev_received)) over() ) /
    DECODE(SUM(SUM(prev_received)) over(),0,NULL,sum(SUM(prev_received)) over()) * 100 BIX_PMV_TOTAL17,
nvl(sum(CURR_TOT_REPLD),0)                        BIX_EMC_REPLD_CP,
nvl(SUM(sum(CURR_TOT_REPLD)) over(),0)            BIX_PMV_TOTAL1,
(NVL(SUM(curr_tot_repld),0) - SUM(prev_tot_repld)) /
    DECODE(SUM(prev_tot_repld),0,NULL,SUM(prev_tot_repld)) * 100 BIX_EMC_REPCHANGE,
(NVL(SUM(SUM(curr_tot_repld)) OVER(),0) - SUM(SUM(prev_tot_repld))OVER()) /
    DECODE(SUM(SUM(prev_tot_repld))OVER(),0,NULL,SUM(SUM(prev_tot_repld))OVER()) * 100 BIX_PMV_TOTAL8,
nvl(sum(PREV_TOT_REPLD),0)                        BIX_EMC_PRREPLD,
nvl(sum(CURR_MSGSGOAL),0)*100/DECODE(sum(CURR_TOT_REPLD),0,NULL,sum(CURR_TOT_REPLD)) BIX_EMC_MSGSGOAL_CP,
nvl(sum(sum(CURR_MSGSGOAL)) over(),0)*100/
      DECODE(sum(sum(CURR_TOT_REPLD)) over(),0,NULL,sum(sum(CURR_TOT_REPLD)) over()) BIX_PMV_TOTAL4,
	 100*
	 (
	 (nvl(sum(CURR_MSGSGOAL),0)/DECODE(sum(CURR_TOT_REPLD),0,NULL,sum(CURR_TOT_REPLD))) -
      (nvl(sum(PREV_MSGSGOAL),0)/DECODE(sum(PREV_TOT_REPLD),0,NULL,sum(PREV_TOT_REPLD)))
	 )
 BIX_EMC_MGCHANGE,

	 100*
	 (
	 (nvl(sum(sum(CURR_MSGSGOAL)) over(),0)/DECODE(sum(sum(CURR_TOT_REPLD)) over(),0,NULL,sum(sum(CURR_TOT_REPLD)) over()))-
      (nvl(sum(sum(PREV_MSGSGOAL)) over(),0)/DECODE(sum(sum(PREV_TOT_REPLD)) over(),0,NULL,sum(sum(PREV_TOT_REPLD)) over()))
	 )
 BIX_PMV_TOTAL9,
nvl(sum(PREV_MSGSGOAL),0)*100/DECODE(sum(PREV_TOT_REPLD),0,NULL,sum(PREV_TOT_REPLD)) BIX_EMC_PREVMSGSGOAL,
nvl(sum(CURR_CRTIME),0)/(3600*DECODE(sum(CURR_TOT_REPLD),0,NULL,sum(CURR_TOT_REPLD))) BIX_EMC_CRTIME_CP,
nvl(sum(sum(CURR_CRTIME)) over(),0)/
    (3600*DECODE(sum(sum(CURR_TOT_REPLD)) over(),0,NULL,sum(sum(CURR_TOT_REPLD)) over())) BIX_PMV_TOTAL5,
((nvl(sum(CURR_CRTIME),0)/DECODE(sum(CURR_TOT_REPLD),0,NULL,sum(CURR_TOT_REPLD)))
   - (sum(PREV_CRTIME)/DECODE(sum(PREV_TOT_REPLD),0,NULL,sum(PREV_TOT_REPLD))))*100/
(sum(PREV_CRTIME)/DECODE(sum(PREV_TOT_REPLD),0,NULL,sum(PREV_TOT_REPLD))) BIX_EMC_CRCHANGE,
((nvl(sum(sum(CURR_CRTIME)) OVER(),0)/DECODE(sum(sum(CURR_TOT_REPLD)) OVER(),0,NULL,sum(sum(CURR_TOT_REPLD)) OVER()))
   - (sum(sum(PREV_CRTIME)) OVER()/DECODE(sum(sum(PREV_TOT_REPLD)) OVER(),0,NULL,sum(sum(PREV_TOT_REPLD)) OVER())))*100/
(sum(sum(PREV_CRTIME)) OVER()/DECODE(sum(sum(PREV_TOT_REPLD)) OVER(),0,NULL,sum(sum(PREV_TOT_REPLD)) OVER())) BIX_PMV_TOTAL10,
nvl(sum(PREV_CRTIME),0)/(3600*DECODE(sum(PREV_TOT_REPLD),0,NULL,sum(PREV_TOT_REPLD))) BIX_EMC_PRCRTIME,
nvl(sum(CURR_ONEDONE),0)*100/sum(CURR_THREADS)           BIX_EMC_ONE_DONE_CP,
nvl(sum(sum(CURR_ONEDONE)) over(),0)*100/sum(sum(CURR_THREADS)) over()           BIX_PMV_TOTAL6,
nvl(sum(CURR_ONEDONE),0)*100/sum(CURR_THREADS)- nvl(sum(PREV_ONEDONE),0)*100/sum(PREV_THREADS) BIX_EMC_ODCHANGE,
nvl(sum(sum(CURR_ONEDONE)) over(),0)*100/sum(sum(CURR_THREADS)) over()-
		nvl(sum(sum(PREV_ONEDONE)) over(),0)*100/sum(sum(PREV_THREADS)) over() BIX_PMV_TOTAL11,
nvl(sum(curr_BACKLOG),0)                           BIX_EMC_BACKLOG_CP,
nvl(sum(sum(curr_BACKLOG)) over(),0)                           BIX_PMV_TOTAL7,
(NVL(SUM(curr_backlog),0) - DECODE(SUM(prev_backlog),0,NULL,SUM(prev_backlog)))
      / DECODE(SUM(prev_backlog),0,NULL,SUM(prev_backlog)) * 100 BIX_EMC_BACKCHANGE,
(SUM(SUM(curr_backlog)) OVER() - DECODE(SUM(SUM(prev_backlog)) OVER(),0,NULL,
            SUM(SUM(prev_backlog)) OVER()))
      / DECODE(SUM(SUM(prev_backlog)) OVER(),0,NULL,SUM(SUM(prev_backlog)) OVER()) * 100 BIX_PMV_TOTAL12,
NVL(SUM(curr_sr),0) BIX_EMC_SR_CP,
NVL(SUM(SUM(curr_sr)) OVER(),0) BIX_PMV_TOTAL3,
(NVL(SUM(curr_sr),0) - SUM(prev_sr)) / SUM(prev_sr) * 100 BIX_EMC_SRCHANGE,
(NVL(SUM(SUM(curr_sr)) OVER(),0) - SUM(SUM(prev_sr)) OVER()) / SUM(SUM(prev_sr)) OVER() * 100 BIX_PMV_TOTAL13,
NVL(SUM(curr_leads),0) BIX_EMC_LEADS_CP,
NVL(SUM(SUM(curr_leads)) OVER(),0) BIX_PMV_TOTAL14,
(NVL(SUM(curr_leads),0) - SUM(prev_leads)) / SUM(prev_leads) * 100 BIX_EMC_LEADSCHANGE,
(NVL(SUM(SUM(curr_leads)) OVER(),0) - SUM(SUM(prev_leads)) OVER()) / SUM(SUM(prev_leads)) OVER() * 100 BIX_PMV_TOTAL15
FROM (
       SELECT  party_id                                        PARTY_ID,
	sum(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_OFFERED_IN_PERIOD,NULL))   CURR_RECEIVED,
	sum(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_OFFERED_IN_PERIOD,NULL))  PREV_RECEIVED,
	sum(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_REPLIED_IN_PERIOD,NULL))   CURR_REPLD,
	sum(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_REPLIED_IN_PERIOD,NULL))  PREV_REPLD,
	sum(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_DELETED_IN_PERIOD,NULL))   CURR_DEL,
	sum(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_DELETED_IN_PERIOD,NULL))  PREV_DEL,
	SUM(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
              NVL(EMAILS_REPLIED_IN_PERIOD,0) + NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0),NULL)) CURR_TOT_REPLD,
	SUM(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
              NVL(EMAILS_REPLIED_IN_PERIOD,0) + NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0),NULL)) PREV_TOT_REPLD,
     sum(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_RPLD_BY_GOAL_IN_PERIOD,NULL))   CURR_MSGSGOAL,
     sum(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_RPLD_BY_GOAL_IN_PERIOD,NULL))  PREV_MSGSGOAL,
     sum(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,EMAILS_RSL_AND_TRFD_IN_PERIOD,NULL))   CURR_TRAN,
     sum(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAILS_RSL_AND_TRFD_IN_PERIOD,NULL))  PREV_TRAN,
	sum(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,SR_CREATED_IN_PERIOD,NULL))            CURR_SR,
	sum(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,SR_CREATED_IN_PERIOD,NULL))           PREV_SR,
	sum(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,LEADS_CREATED_IN_PERIOD,NULL))         CURR_LEADS,
	sum(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,LEADS_CREATED_IN_PERIOD,NULL))        PREV_LEADS,
	sum(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,EMAIL_RESP_TIME_IN_PERIOD,NULL))       CURR_CRTIME,
	sum(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,EMAIL_RESP_TIME_IN_PERIOD,NULL))      PREV_CRTIME,
     sum(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,ONE_RSLN_IN_PERIOD,NULL))              CURR_ONEDONE,
     sum(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,ONE_RSLN_IN_PERIOD,NULL))             PREV_ONEDONE,
     sum(DECODE(cal.report_date,&BIS_CURRENT_ASOF_DATE,INTERACTION_THREADS_IN_PERIOD,NULL))   CURR_THREADS,
     sum(DECODE(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,INTERACTION_THREADS_IN_PERIOD,NULL))  PREV_THREADS
FROM bix_email_details_mv fact,
  	   fii_time_rpt_struct cal
      WHERE fact.time_id = cal.time_id
      AND fact.period_type_id = cal.period_type_id
	 AND row_type = :l_row_type
      AND cal.report_date IN ( &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
      AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN)=cal.record_type_id
	 ' || l_where_clause ||
      ' GROUP BY party_id
	 ) email,
	 (
       SELECT  party_id PARTY_ID,
                        SUM(DECODE(period_start_date,:l_max_collect_date,
                        NVL(ACCUMULATED_OPEN_EMAILS,0) + NVL(ACCUMULATED_EMAILS_IN_QUEUE,0) )) curr_backlog,
                        SUM(DECODE(period_start_date,&BIS_PREVIOUS_ASOF_DATE,
                        NVL(ACCUMULATED_OPEN_EMAILS,0) + NVL(ACCUMULATED_EMAILS_IN_QUEUE,0) )) prev_backlog
       FROM   bix_email_details_mv
       WHERE time_id IN  (TO_CHAR(:l_max_collect_date,''J''),TO_CHAR(&BIS_PREVIOUS_ASOF_DATE,''J''))
       AND   period_type_id = :l_period_type_id
	  AND   row_type = :l_row_type
	  ' || l_where_clause ||
       ' GROUP BY party_id
       ) accu,
       hz_parties hzp
         WHERE email.party_id = hzp.party_id
	    AND email.party_id = accu.party_id (+)
	    GROUP BY hzp.party_id,decode(hzp.party_id,'||l_dummy_cust||',:l_unident_string,hzp.party_name) ';

--START 001

l_sqltext := 'SELECT  * FROM ( '||l_sqltext ||' ) WHERE
ABS(NVL(BIX_EMC_REPLD_CP   ,0))+ABS(NVL(BIX_EMC_REPCHANGE  ,0))+ABS(NVL(BIX_EMC_MSGSGOAL_CP,0))+ABS(NVL(BIX_EMC_MGCHANGE   ,0))+
ABS(NVL(BIX_EMC_CRTIME_CP  ,0))+ABS(NVL(BIX_EMC_CRCHANGE   ,0))+ABS(NVL(BIX_EMC_ONE_DONE_CP,0))+ABS(NVL(BIX_EMC_ODCHANGE   ,0))+
ABS(NVL(BIX_EMC_RCVD_CP    ,0))+ABS(NVL(BIX_EMC_RCVDCHANGE ,0))+ABS(NVL(BIX_EMC_BACKLOG_CP  ,0))+ABS(NVL(BIX_EMC_BACKCHANGE ,0))+
ABS(NVL(BIX_EMC_SR_CP      ,0))+ABS(NVL(BIX_EMC_SRCHANGE   ,0))+ABS(NVL(BIX_EMC_LEADS_CP   ,0))+ABS(NVL(BIX_EMC_LEADSCHANGE,0))
!=0  &ORDER_BY_CLAUSE ';

--END 001

--
--NOTE:  DO not make the join to hz_parties as a OUTER JOIN.
--If you do so, there will be NULL customer names which are not really sub-totals,
--but the program will interpret those rows to be sub-totals as well.
--
p_sql_text := l_sqltext;


-- insert Period Type ID bind variable

l_custom_rec.attribute_name := ':l_period_type_id' ;
l_custom_rec.attribute_value:= 1;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;

-- Insert account Bind Variable

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

l_custom_rec.attribute_name := ':l_max_collect_date' ;
l_custom_rec.attribute_value:= l_max_collect_date;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;

l_custom_rec.attribute_name := ':l_unident_string' ;
l_custom_rec.attribute_value:= l_unident_string;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;

p_custom_output.Extend();
p_custom_output(p_custom_output.count) := l_custom_rec;

l_custom_rec.attribute_name := ':l_application_id';
l_custom_rec.attribute_value:= l_application_id;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;

p_custom_output.EXTEND;
p_custom_output(p_custom_output.COUNT) := l_custom_rec;

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
END  BIX_PMV_EMC_CUSTDET_RPT_PKG;

/
