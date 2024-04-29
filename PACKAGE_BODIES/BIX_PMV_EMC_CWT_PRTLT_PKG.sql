--------------------------------------------------------
--  DDL for Package Body BIX_PMV_EMC_CWT_PRTLT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_EMC_CWT_PRTLT_PKG" AS
/*$Header: bixecwtb.plb 120.0 2005/05/25 17:20:21 appldev noship $ */

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
l_account      varchar2(32000);
l_sql_errm      varchar2(32000);
l_previous_report_start_date DATE;
l_current_report_start_date DATE;
l_previous_as_of_date DATE;
l_period_type_id NUMBER;
l_time_id_column  VARCHAR2(1000);
l_goal NUMBER;
l_custom_rec BIS_QUERY_ATTRIBUTES := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
l_classification VARCHAR2(32000);
l_where_clause VARCHAR2(32000);
l_view_by  varchar2(1000);
l_row_type varchar2(10) := 'AC';

BEGIN



--
--Initialize p_custom_output
--
p_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

 bix_pmv_dbi_utl_pkg.get_emc_page_params (p_page_parameter_tbl,
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



IF (FND_PROFILE.DEFINED('BIX_EMAIL_GOAL')) THEN
begin
   l_goal := TO_NUMBER(FND_PROFILE.VALUE('BIX_EMAIL_GOAL'));
exception
when others then
   l_goal:=0;
end;
ELSE
   l_goal := 0;
END IF;





IF ( l_comp_type  = 'YEARLY' AND l_period_type = 'FII_TIME_ENT_YEAR' )
THEN
--This is for year over year comparison and period type is year. We need to get the prior year's values
--for display.
 l_sqltext
 :='
 /*Outermost query does the calculations of service level goal and constrains
 display between current report start date and current year only
 */
select name VIEWBY,
ROUND((nvl(sum(CURR_ERT),0)/DECODE(SUM(CURR_REPLD),0,NULL,SUM(CURR_REPLD)))/3600,1) BIX_EMC_CRTIME,
ROUND((nvl(sum(PREV_ERT),0)/DECODE(SUM(PREV_REPLD),0,NULL,SUM(PREV_REPLD)))/3600,1) BIX_EMC_PRCRTIME,
' || l_goal ||'                           BIX_EMC_GOAL
from
(
/* Outer most iview .Uses lag to select prior values for the corresponding year*/
select cal.name,cal.start_date,
SUM(
	 CASE when (cal.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
	 	  and cal.report_date = least(cal.end_date,&BIS_CURRENT_ASOF_DATE))
		  then
		  		EMAIL_RESP_TIME_IN_PERIOD
		  else
		  	   null
		  end
   ) CURR_ERT
,lag(
	SUM(
	 CASE WHEN (cal.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_PREVIOUS_ASOF_DATE
	 	  and cal.report_date = least(cal.end_date,&BIS_PREVIOUS_ASOF_DATE ))
		  then
		  		EMAIL_RESP_TIME_IN_PERIOD
		  else
		  	    null
		  end
		 )
) over (order by cal.start_date) PREV_ERT
,
SUM(
	 CASE when (cal.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
	 	  and cal.report_date = least(cal.end_date,&BIS_CURRENT_ASOF_DATE))
		  then
		  		 NVL(EMAILS_REPLIED_IN_PERIOD,0)+NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0)
		  else
		  	    null
		   end
   ) CURR_REPLD
,
lag(
	 SUM (
	 CASE WHEN (cal.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_PREVIOUS_ASOF_DATE
	 and cal.report_date = least(cal.end_date,&BIS_PREVIOUS_ASOF_DATE ))
	 then
	 	  NVL(EMAILS_REPLIED_IN_PERIOD,0)+NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0)
	 else
	 	  null
	 end
	 	)
) over (order by cal.start_date) PREV_REPLD
from
(
/* Selects measures for all years in time range from previous report start date to current as of date*/
   select fii604.name,fii604.start_date,fii604.end_date,cal.report_Date,cal.period_type_id,cal.time_id
   from fii_time_ent_year fii604, fii_time_rpt_struct cal
   where
   fii604.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
   and cal.report_date between fii604.start_date and fii604.end_date
   and cal.report_date in (least(fii604.end_date, &BIS_CURRENT_ASOF_DATE) , &BIS_PREVIOUS_ASOF_DATE)
   AND  bitAND(cal.record_type_id,&BIS_NESTED_PATTERN ) = cal.record_type_id
   order by fii604.sequence
)cal,(
	   select period_type_id,time_id,
	   EMAIL_RESP_TIME_IN_PERIOD,
	   EMAILS_REPLIED_IN_PERIOD,
	   EMAILS_AUTO_REPLIED_IN_PERIOD
	   from bix_Email_Details_mv
	    where row_type=:l_row_type '|| l_where_clause || '
		)mv
where mv.period_type_id(+)=cal.period_type_id
and mv.time_id(+)=cal.time_id
group by cal.name,cal.start_date
) recset /*End of outermost view */
WHERE recset.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
group by name';



ELSIF ( l_comp_type  = 'YEARLY' AND l_period_type <> 'FII_TIME_ENT_YEAR' )
THEN
--
--If it enters here it means the comparison is for Week, Month or Quarter
--and it is a Year over Year comparison.
--
   l_sqltext := '
      SELECT fii2.name                                            VIEWBY,
             ROUND((nvl(sum(CURR_ERT),0)/DECODE(SUM(CURR_REPLD),0,NULL,SUM(CURR_REPLD)))/3600,1) BIX_EMC_CRTIME,
             ROUND((nvl(sum(PREV_ERT),0)/DECODE(SUM(PREV_REPLD),0,NULL,SUM(PREV_REPLD)))/3600,1) BIX_EMC_PRCRTIME,
             ' || l_goal ||'                           BIX_EMC_GOAL
      FROM
            ( SELECT fiitb.sequence                             SEQUENCE,
                     SUM( CASE when
                                  (
                                   fiitb.start_date between &BIS_CURRENT_REPORT_START_DATE
                                                      and &BIS_CURRENT_ASOF_DATE
                                   and cal.report_date = least(fiitb.end_date,&BIS_CURRENT_ASOF_DATE)
                                   )
                               then
                                 EMAIL_RESP_TIME_IN_PERIOD
                               else
						    NULL
                               end
                         ) CURR_ERT,
                     SUM( CASE when
                                  (
                                   fiitb.start_date between &BIS_CURRENT_REPORT_START_DATE
                                                      and &BIS_CURRENT_ASOF_DATE
                                   and cal.report_date = least(fiitb.end_date,&BIS_CURRENT_ASOF_DATE)
                                   )
                               then
						 NVL(EMAILS_REPLIED_IN_PERIOD,0)+NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0)
                               else
						    NULL
                               end
                         ) CURR_REPLD,
                     SUM( CASE when
                                  (
                                   fiitb.start_date between &BIS_PREVIOUS_REPORT_START_DATE
                                                      and &BIS_PREVIOUS_ASOF_DATE
                                   and cal.report_date = least(fiitb.end_date,&BIS_PREVIOUS_ASOF_DATE)
                                   )
                               then
                                 EMAIL_RESP_TIME_IN_PERIOD
                               else
						    NULL
                               end
                         ) PREV_ERT,
                     SUM( CASE when
                                  (
                                   fiitb.start_date between &BIS_PREVIOUS_REPORT_START_DATE
                                                      and &BIS_PREVIOUS_ASOF_DATE
                                   and cal.report_date = least(fiitb.end_date,&BIS_PREVIOUS_ASOF_DATE)
                                   )
                               then
                               NVL(EMAILS_REPLIED_IN_PERIOD,0)+NVL(EMAILS_AUTO_REPLIED_IN_PERIOD,0)
                               else
						    NULL
                               end
                         ) PREV_REPLD
              FROM  '||l_period_type||'	fiitb,
                    bix_email_details_mv eml,
				fii_time_rpt_struct cal
              WHERE eml.time_id        = cal.time_id
		    ANd   eml.row_type = :l_row_type
              AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN)=cal.record_type_id
              AND   fiitb.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE AND
								   &BIS_CURRENT_ASOF_DATE
              AND cal.report_date = (CASE WHEN(
									 fiitb.start_date between
                                              &BIS_PREVIOUS_REPORT_START_DATE and
                                              &BIS_PREVIOUS_ASOF_DATE
									 )
                                          THEN
                                             least(fiitb.end_date, &BIS_PREVIOUS_ASOF_DATE)
                                          ELSE
                                             least(fiitb.end_date, &BIS_CURRENT_ASOF_DATE)
                                          END
                                     )
              AND cal.period_type_id = eml.period_type_id ';
 l_sqltext := l_sqltext || l_where_clause || ' GROUP BY fiitb.sequence
		    ) summ, '
		    ||l_period_type||' fii2
             WHERE fii2.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
                                       AND &BIS_CURRENT_ASOF_DATE
             AND fii2.sequence = summ.sequence (+)
             GROUP BY fii2.name, fii2.start_date, summ.sequence
             ORDER BY fii2.start_date ';

ELSE
--
--If it reaches here it means it is either a Sequential comparison for
--week, month or quarter OR it is a YEAR period type.  For YEAR period type
--it does not matter whether it is a Y/Y comparison or a Sequential comparison
--as both will be treated the same.
--
l_sqltext := '
      SELECT fii2.name                                  VIEWBY,
             ROUND((nvl(sum(CURR_ERT),0)/DECODE(SUM(CURR_REPLD),0,NULL,SUM(CURR_REPLD)))/3600,1) BIX_EMC_CRTIME,
		   NULL                                                 BIX_EMC_PRCRTIME,
		' || l_goal ||'                           BIX_EMC_GOAL
      FROM
            ( SELECT fiitb.name                               NAME,
                     sum(EMAIL_RESP_TIME_IN_PERIOD)         CURR_ERT,
                     NVL(sum(EMAILS_REPLIED_IN_PERIOD),0) + NVL(SUM(EMAILS_AUTO_REPLIED_IN_PERIOD),0) CURR_REPLD
              FROM  '||l_period_type||'	fiitb,
                    bix_email_details_mv eml,
				fii_time_rpt_struct cal
              WHERE eml.time_id        = cal.time_id
		    AND  eml.row_type = :l_row_type
              AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN)=cal.record_type_id
              AND   fiitb.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND
								   &BIS_CURRENT_ASOF_DATE
		    AND cal.report_date = least(&BIS_CURRENT_ASOF_DATE,fiitb.end_date)
		    AND cal.period_type_id = eml.period_type_id ';
 l_sqltext := l_sqltext || l_where_clause || ' GROUP BY fiitb.name
              ) curr, ' ||
              l_period_type || ' fii2
       WHERE fii2.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
       AND &BIS_CURRENT_ASOF_DATE
       AND fii2.name = curr.name (+)
	  GROUP BY fii2.name,fii2.start_date
       ORDER BY fii2.start_date
             ';

END IF;

p_custom_sql := l_sqltext;

l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.View_By_Type;
l_custom_rec.attribute_value := 'TIME+'||l_period_type;

p_custom_output.EXTEND();
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
END BIX_PMV_EMC_CWT_PRTLT_PKG;

/
