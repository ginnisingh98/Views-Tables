--------------------------------------------------------
--  DDL for Package Body BIX_PMV_EMC_BKLG_PRTLT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIX_PMV_EMC_BKLG_PRTLT_PKG" AS
/*$Header: bixeblgp.plb 120.0 2005/05/25 17:19:46 appldev noship $ */

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
l_time_id_column  VARCHAR2(1000);
l_start_date DATE;
l_end_date DATE;
l_period_from DATE;
l_period_to DATE;
l_period_to_bind VARCHAR2(100);
l_classification VARCHAR2(32000);
l_where_clause VARCHAR2(32000);
l_view_by varchar2(1000);
l_row_type varchar2(10) := 'AC';
l_period_start_date date;

l_custom_rec BIS_QUERY_ATTRIBUTES := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;

BEGIN
--
--Initialize p_custom_output
--
p_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

BIS_COLLECTION_UTILITIES.get_last_refresh_dates('BIX_EMAIL_DETAILS_F',
                                                 l_start_date,
                                                 l_end_date,
                                                 l_period_from,
                                                 l_period_to
                                                 );

 bix_pmv_dbi_utl_pkg.get_emc_page_params (p_page_parameter_tbl,
   			     			      l_as_of_date,
			    			      l_period_type,
				                      l_record_type_id,
				                      l_comp_type,
				                      l_account,
						      l_classification ,
						      l_view_by
				                      );


-- If the account is not 'All'

 IF l_account IS NOT NULL THEN
 l_where_clause := 'AND email_account_id IN (:l_account) ';
 END IF;


 IF l_classification IS NOT NULL THEN
 l_where_clause := l_where_clause || ' AND email_classification_id IN (:l_classification) ';
 END IF;

IF l_period_to IS NULL
THEN
   l_period_to := l_as_of_date;
END IF;

--
--PMV requires dates to be bound as character in DD/MM/YYYY format
--


/* Started additions  for bug  3762642 */

l_period_start_Date := BIX_PMV_DBI_UTL_PKG.period_start_date(l_as_of_date,l_period_type);
 IF (NVL(l_period_to,l_as_of_date) >= l_as_of_date ) THEN
   l_period_to_bind := TO_CHAR(l_as_of_date,'DD/MM/YYYY');
 ELSE
    l_period_to_bind := TO_CHAR(l_period_to,'DD/MM/YYYY');
  END IF;

/* End of additions for bug 3762642 */




IF ( l_comp_type  = 'YEARLY' AND l_period_type = 'FII_TIME_ENT_YEAR' )
THEN
--This is for year over year comparison and period type is year. We need to get the prior year's values
--for display.
 l_sqltext
 :='
 /*Outermost query does the calculations of backolog and constrains
 display between current report start date and current year only
 */
select name VIEWBY,
nvl(sum(CURR_BACKLOG),0)                        BIX_EMC_BACKLOG,
nvl(sum(PREV_BACKLOG),0)                        BIX_EMC_PREVBACKLOG
from
(
/* Outer most iview .Uses lag to select prior values for the corresponding year*/
select cal.name,cal.start_date,
SUM(
	 CASE when (cal.start_date between &BIS_CURRENT_REPORT_START_DATE and &BIS_CURRENT_ASOF_DATE
	 	  and cal.report_date = least(cal.end_date,:l_period_to_bind))
		  then
		  	nvl(ACCUMULATED_OPEN_EMAILS,0)+nvl(ACCUMULATED_EMAILS_IN_QUEUE,0)
		  else
		  	   null
		  end
   ) CURR_BACKLOG
,lag(
	SUM(
	 CASE WHEN (cal.start_date between &BIS_PREVIOUS_REPORT_START_DATE and &BIS_PREVIOUS_ASOF_DATE
	 	  and cal.report_date = least(cal.end_date,&BIS_PREVIOUS_ASOF_DATE ))
		  then
		  		nvl(ACCUMULATED_OPEN_EMAILS,0)+nvl(ACCUMULATED_EMAILS_IN_QUEUE,0)
		  else
		  	    null
		  end
		 )
) over (order by cal.start_date) PREV_BACKLOG
from
(
/* Selects measures for all years in time range from previous report start date to current as of date*/
   select fii604.name,fii604.start_date,fii604.end_date,cal.report_Date,cal.period_type_id,cal.time_id
   from fii_time_ent_year fii604, fii_time_rpt_struct cal
   where
   fii604.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE AND &BIS_CURRENT_ASOF_DATE
   and cal.report_date between fii604.start_date and fii604.end_date
   and cal.report_date in (least(fii604.end_date, :l_period_to_bind) , &BIS_PREVIOUS_ASOF_DATE)
   AND  bitAND(cal.record_type_id,:l_period_type_id ) = cal.record_type_id
   order by fii604.sequence
)cal,(
	   select period_type_id,time_id,ACCUMULATED_OPEN_EMAILS,ACCUMULATED_EMAILS_IN_QUEUE
	   from bix_Email_Details_mv
	   where period_type_id=:l_period_type_id
	   and row_type=:l_row_type '|| l_where_clause || '
		)mv
where mv.time_id(+)=cal.time_id
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
SELECT fii604.name                                 VIEWBY,
nvl(sum(CURR_BACKLOG),0)                        BIX_EMC_BACKLOG,
nvl(sum(PREV_BACKLOG),0)                        BIX_EMC_PREVBACKLOG
FROM
(
   SELECT fii604.sequence                             SEQUENCE,
   SUM( CASE when
   (
   fii604.start_date between &BIS_CURRENT_REPORT_START_DATE
   and &BIS_CURRENT_ASOF_DATE
   )
        then
        nvl(ACCUMULATED_OPEN_EMAILS,0)+nvl(ACCUMULATED_EMAILS_IN_QUEUE,0)
        else
        NULL
        end
   ) CURR_BACKLOG,
   SUM( CASE when
   (
   fii604.start_date between &BIS_PREVIOUS_REPORT_START_DATE
   and &BIS_PREVIOUS_ASOF_DATE
   )
   then
   nvl(ACCUMULATED_OPEN_EMAILS,0)+nvl(ACCUMULATED_EMAILS_IN_QUEUE,0)
   else
   NULL
   end
   ) PREV_BACKLOG
FROM  '||l_period_type||'	fii604,
      bix_email_details_mv eml
WHERE eml.time_id = to_char
(
   least
      (
         fii604.end_date,
         (
         CASE
         WHEN
         :l_period_to_bind BETWEEN fii604.start_date AND fii604.end_date
         THEN
         :l_period_to_bind
         ELSE
         fii604.end_date
         END
         )
      )
,''J'')
AND fii604.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE AND
                           &BIS_CURRENT_ASOF_DATE
AND eml.row_type = :l_row_type
AND eml.period_type_id = :l_period_type_id ';

l_sqltext := l_sqltext || l_where_clause || ' GROUP BY fii604.sequence
) summ, '
||l_period_type||' fii604
WHERE fii604.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
AND &BIS_CURRENT_ASOF_DATE
AND fii604.sequence = summ.sequence (+)
GROUP BY fii604.name, fii604.start_date
ORDER BY fii604.start_date ';

ELSE
--
--If it reaches here it means it is either a Sequential comparison for
--week, month or quarter OR it is a YEAR period type.  For YEAR period type
--it does not matter whether it is a Y/Y comparison or a Sequential comparison
--as both will be treated the same.
--
l_sqltext := '
SELECT fii604.name                                 VIEWBY,
nvl(sum(CURR_BACKLOG),0)                        BIX_EMC_BACKLOG,
NULL                                            BIX_EMC_PREVBACKLOG
FROM
(
   SELECT fii604.name                             NAME,
   SUM(
        nvl(ACCUMULATED_OPEN_EMAILS,0)+nvl(ACCUMULATED_EMAILS_IN_QUEUE,0)
   )    CURR_BACKLOG,
   NULL PREV_BACKLOG
FROM  '||l_period_type||'	fii604,
      bix_email_details_mv eml
WHERE eml.time_id = to_char
(
   least
      (
         fii604.end_date,
         (
         CASE
         WHEN
         :l_period_to_bind BETWEEN fii604.start_date AND fii604.end_date
         THEN
         :l_period_to_bind
         ELSE
         fii604.end_date
         END
         )
      )
,''J'')
AND fii604.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE AND
                           &BIS_CURRENT_ASOF_DATE
AND eml.row_type = :l_row_type
AND eml.period_type_id = :l_period_type_id ';
l_sqltext := l_sqltext || l_where_clause || ' GROUP BY fii604.name
) summ, '
||l_period_type||' fii604
WHERE fii604.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
AND &BIS_CURRENT_ASOF_DATE
AND fii604.name = summ.name (+)
GROUP BY fii604.name, fii604.start_date
ORDER BY fii604.start_date ';

END IF;

p_custom_sql := l_sqltext;

p_custom_output.EXTEND;
l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.View_By_Type;
l_custom_rec.attribute_value := 'TIME+'||l_period_type;
p_custom_output(p_custom_output.COUNT) := l_custom_rec;

p_custom_output.EXTEND();
l_custom_rec.attribute_name := ':l_period_to_bind' ;
l_custom_rec.attribute_value:= l_period_to_bind;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
p_custom_output(p_custom_output.count) := l_custom_rec;

p_custom_output.EXTEND();
l_custom_rec.attribute_name := ':l_period_type_id' ;
l_custom_rec.attribute_value:= 1;
l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
p_custom_output(p_custom_output.count) := l_custom_rec;

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
--l_sql_errm := SQLERRM;
NULL;
END GET_SQL;
END  BIX_PMV_EMC_BKLG_PRTLT_PKG;

/
