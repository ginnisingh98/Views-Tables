--------------------------------------------------------
--  DDL for Package Body ENI_DBI_CAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_CAT_PKG" AS
/*$Header: ENICATPB.pls 120.1 2006/03/23 04:36:31 pgopalar noship $*/
PROCEDURE GET_SQL ( p_page_parameter_tbl IN  BIS_PMV_PAGE_PARAMETER_TBL
                  , x_custom_sql        OUT NOCOPY VARCHAR2
                  , x_custom_output     OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

l_custom_rec		BIS_QUERY_ATTRIBUTES;
l_err_msg		VARCHAR2(1000);
l_period_type		VARCHAR2(1000);
l_period_bitand		NUMBER;
l_view_by		VARCHAR2(1000);
l_as_of_date		DATE;
l_prev_as_of_date	DATE;
l_report_start		DATE;
l_cur_period		NUMBER;
l_days_into_period	NUMBER;
l_comp_type		VARCHAR2(100);
l_category		VARCHAR2(100);
l_item			VARCHAR2(100);
l_org			VARCHAR2(100);
l_id_column		VARCHAR2(100);
l_order_by		VARCHAR2(1000);
l_drill			VARCHAR2(100);
l_status		VARCHAR2(100);
l_priority		VARCHAR2(100);
l_reason		VARCHAR2(100);
l_lifecycle_phase	VARCHAR2(100);
l_currency		VARCHAR2(100);
l_bom_type		VARCHAR2(100);
l_type			VARCHAR2(100);
l_manager		VARCHAR2(100);
l_temp			VARCHAR2(1000);
l_lob			VARCHAR2(1000);
l_comp_where		VARCHAR2(1000);
l_org_where 		VARCHAR2(1000);
l_cat_where 		VARCHAR2(1000);
l_item_where		VARCHAR2(1000);
l_priority_where	VARCHAR2(1000);
l_reason_where		VARCHAR2(1000);
l_type_where		VARCHAR2(1000);
l_from_clause		VARCHAR2(1000);
l_where_clause		VARCHAR2(1000);
l_group_by_clause	VARCHAR2(1000);
l_common_part		VARCHAR2(32000);
l_inner_part		VARCHAR2(32000);
l_status_where		VARCHAR2(4000);
l_open_url		VARCHAR2(4000);

BEGIN


		x_custom_output := bis_query_attributes_tbl();


		ENI_DBI_UTIL_PKG.get_parameters( p_page_parameter_tbl
                                 , l_period_type
                                 , l_period_bitand
                                 , l_view_by
                                 , l_as_of_date
                                 , l_prev_as_of_date
                                 , l_report_start
                                 , l_cur_period
                                 , l_days_into_period
                                 , l_comp_type
                                 , l_category
                                 , l_item
                                 , l_org
                                 , l_id_column
                                 , l_order_by
                                 , l_drill
                                 , l_status
                                 , l_priority
                                 , l_reason
                                 , l_lifecycle_phase
                                 , l_currency
                                 , l_bom_type
                                 , l_type
                                 , l_manager
		                             , l_lob
                                 );

		ENI_DBI_UTIL_PKG.get_time_clauses
            		(
                        	'I',
				                  'edcd',
        	                l_period_type,
                	        l_period_bitand,
                        	l_as_of_date,
	                        l_prev_as_of_date,
        	                l_report_start,
                	        l_cur_period,
                        	l_days_into_period,
	                        l_comp_type,
        	                l_id_column,
                	        l_from_clause,
                        	l_where_clause,
				                  l_group_by_clause,
				                  'ROLLING'
        		);

	IF(l_order_by like '%DESC%')
	THEN
		l_order_by:=' t.start_date desc ';
	ELSIF(l_order_by like '%ASC%')
	THEN
		l_order_by:=' t.start_date asc ';
	ELSE
		l_order_by:=' t.start_date asc ';
	END IF;

	IF (l_priority IS NULL OR l_priority = '' OR l_priority = 'All')
	THEN
		l_priority_where:= '';

	ELSE
		l_priority_where := ' and edcd.priority_code = :PRIORITY_ID';
	END IF;

	IF (l_type IS NULL OR l_type = '' OR l_type = 'All')
	THEN
		l_type_where := '';

	ELSE
		l_type_where := ' and edcd.change_order_type_id = :TYPE_ID';
	END IF;


	IF (l_reason IS NULL OR l_reason = '' OR l_reason = 'All')
	THEN
		l_reason_where := '';

	ELSE
		l_reason_where := ' and edcd.reason_code  = :REASON_ID';
	END IF;

	IF (l_status IS NULL OR l_status = '' OR l_status = 'All')
	THEN
		l_status_where := '';

	ELSE
		l_status_where := ' and edcd.status_type  = :STATUS_ID';
	END IF;

	IF (l_org IS NULL OR l_org = '' OR l_org = 'All')
	THEN
		l_org_where := '';

	ELSE
		l_org_where := ' AND edcd.organization_id = :ORGANIZATION_ID';
	END IF;

-- Bug : 3465553
/*
	l_open_url:=   '''pFunctionName=ENI_DBI_COL_OPEN_R&pCustomView=ENI_DBI_COL_CV1&REPORTED=OPEN'||
	'&start_date=''||to_char(t.start_date,''dd-mm-yyyy'')||''&end_date=''||to_char(t.c_end_date,''dd-mm-yyyy'')||''&''||''AS_OF_DATE=''||to_char(t.c_end_date,''dd-mm-yyyy'')';
*/
-- Bug : 3465553
l_open_url :=null;

	IF (l_item IS NULL OR l_item = '' OR l_item = 'All')
	THEN
		l_item_where := '';
		IF(l_view_by NOT like '%ITEM+%')
		THEN
			X_CUSTOM_SQL:='
				SELECT	NULL AS VIEWBY,
					NULL AS	ENI_MEASURE1,
					NULL AS	ENI_MEASURE9,
					NULL AS	ENI_MEASURE3,
					NULL AS	ENI_MEASURE11,
					NULL AS	ENI_MEASURE31,
					NULL AS	ENI_MEASURE32,
					NULL AS	ENI_MEASURE33,
					NULL AS	ENI_MEASURE34,
					NULL AS	ENI_MEASURE35,
					NULL AS	ENI_MEASURE36,
					NULL AS	ENI_MEASURE37,
					NULL AS	ENI_MEASURE38,
					NULL AS ENI_MEASURE40,
					NULL AS	ENI_MEASURE10,
					NULL AS ENI_MEASURE12
				FROM	DUAL';
				RETURN;
		END IF;
	ELSE
		l_item_where := ' AND edcd.item_id = :ITEM_ID';
	END IF;

x_custom_sql:=
'
select t.name as VIEWBY,
	sum(ENI_MEASURE1)  AS ENI_MEASURE1,
	sum(ENI_MEASURE9)  AS ENI_MEASURE9,
	sum(ENI_MEASURE31) AS ENI_MEASURE31,
	sum(ENI_MEASURE32) AS ENI_MEASURE32,
	sum(ENI_MEASURE33) AS ENI_MEASURE33,
	sum(ENI_MEASURE34) AS ENI_MEASURE34,
	sum(ENI_MEASURE3)  AS ENI_MEASURE3,
	sum(ENI_MEASURE11) AS ENI_MEASURE11,
	sum(ENI_MEASURE35) AS ENI_MEASURE35,
	sum(ENI_MEASURE36) AS ENI_MEASURE36,
	sum(ENI_MEASURE37) AS ENI_MEASURE37,
	sum(ENI_MEASURE38) AS ENI_MEASURE38,
	nvl(sum(ENI_MEASURE1),0)  AS ENI_MEASURE10,
	nvl(sum(ENI_MEASURE3),0)  AS ENI_MEASURE12,
	NULL as ENI_MEASURE40
from

(SELECT
     t.name AS VIEWBY
   ,t.c_end_date
   , SUM(CASE WHEN
         (NVL(edcd.cancellation_date, NVL(edcd.implementation_date,:NVL_DATE)
             ) >  t.c_end_date
         ) AND edcd.creation_date <= t.c_end_date
         THEN edcd.cnt ELSE null
         END) AS ENI_MEASURE1
   , SUM(CASE WHEN
         (NVL(edcd.cancellation_date, NVL(edcd.implementation_date,:NVL_DATE)
             ) >  t.p_end_date
         ) AND edcd.creation_date <= t.p_end_date
         THEN edcd.cnt ELSE null
         END) AS ENI_MEASURE9
   , SUM(CASE WHEN
         NVL(edcd.cancellation_date,
             NVL(edcd.implementation_date,:NVL_DATE)
            ) >  t.c_end_date
         AND edcd.creation_date <= t.c_end_date
         THEN
         (CASE WHEN
          (LEAST(NVL(edcd.cancellation_date,
                     NVL(edcd.implementation_date,t.c_end_date)
                    ), t.c_end_date) - edcd.creation_date)
          BETWEEN 0 AND 1
          THEN edcd.CNT ELSE null END)
         ELSE null END)
     AS ENI_MEASURE31
   , SUM(CASE WHEN
         NVL(edcd.cancellation_date,
             NVL(edcd.implementation_date,:NVL_DATE)
            ) >  t.c_end_date
         AND edcd.creation_date <= t.c_end_date
         THEN
         (CASE WHEN
          (LEAST(NVL(edcd.cancellation_date,
                     NVL(edcd.implementation_date,t.c_end_date)
                    ), t.c_end_date) - edcd.creation_date)
          BETWEEN 2 AND 5
          THEN edcd.cnt ELSE null END)
         ELSE null END)
     AS ENI_MEASURE32
   , SUM(CASE WHEN
         NVL(edcd.cancellation_date,
             NVL(edcd.implementation_date,:NVL_DATE)
            ) >  t.c_end_date
         AND edcd.creation_date <= t.c_end_date
         THEN
         (CASE WHEN
          (LEAST(NVL(edcd.cancellation_date,
                     NVL(edcd.implementation_date,t.c_end_date)
                    ), t.c_end_date ) - edcd.creation_date)
          BETWEEN 6 and 10
          THEN edcd.cnt ELSE null END)
         ELSE null END)
     AS ENI_MEASURE33
   , SUM(CASE WHEN
         NVL(edcd.cancellation_date,
             NVL(edcd.implementation_date,:NVL_DATE)
            ) >  t.c_end_date
         AND edcd.creation_date <= t.c_end_date
         THEN
         (CASE WHEN
          (LEAST(NVL(edcd.cancellation_date,
                     NVL(edcd.implementation_date,t.c_end_date)
                    ), t.c_end_date) - edcd.creation_date)
          > 10
          THEN edcd.cnt ELSE null END)
         ELSE null END)
     AS ENI_MEASURE34
   , SUM(CASE WHEN
         NVL(NVL(edcd.cancellation_date, edcd.implementation_date),:NVL_DATE)
          > t.c_end_date
          AND edcd.creation_date <= t.c_end_date
         THEN
         ((t.c_end_date - edcd.creation_date) * edcd.cnt)
         ELSE null END)
	 /
	 DECODE(SUM(CASE WHEN
         (NVL(edcd.cancellation_date, NVL(edcd.implementation_date,:NVL_DATE)
             ) >  t.c_end_date
         ) AND edcd.creation_date <= t.c_end_date
         THEN edcd.cnt ELSE null
         END),0,NULL,SUM(CASE WHEN
         (NVL(edcd.cancellation_date, NVL(edcd.implementation_date,:NVL_DATE)
             ) >  t.c_end_date
         ) AND edcd.creation_date <= t.c_end_date
         THEN edcd.cnt ELSE null
         END))
     AS ENI_MEASURE3
   , SUM(CASE WHEN
         NVL(NVL(edcd.cancellation_date, edcd.implementation_date),:NVL_DATE)
          > t.p_end_date
          AND edcd.creation_date <= t.p_end_date
         THEN
         ((t.p_end_date - edcd.creation_date) * edcd.cnt)
         ELSE null END)
	 /
	 DECODE(SUM(CASE WHEN
         (NVL(edcd.cancellation_date, NVL(edcd.implementation_date,:NVL_DATE)
             ) >  t.p_end_date
         ) AND edcd.creation_date <= t.p_end_date
         THEN edcd.cnt ELSE null
         END),0,NULL,SUM(CASE WHEN
         (NVL(edcd.cancellation_date, NVL(edcd.implementation_date,:NVL_DATE)
             ) >  t.p_end_date
         ) AND edcd.creation_date <= t.p_end_date
         THEN edcd.cnt ELSE null
         END))
     AS ENI_MEASURE11,
     NULL AS	ENI_MEASURE35,
     NULL AS	ENI_MEASURE36,
     NULL AS	ENI_MEASURE37,
     NULL AS	ENI_MEASURE38

   FROM eni_dbi_co_dnum_mv edcd
      , '|| l_from_clause || '
   WHERE
   1=1
	  AND edcd.creation_date <= &BIS_CURRENT_ASOF_DATE
    ' || l_item_where ||'
    ' || l_org_where || '
    ' || l_type_where || '
    ' || l_priority_where || '
    ' || l_reason_where|| '
    ' || l_status_where || '
   GROUP BY
    ' || l_group_by_clause || ') edcs,
    '||l_from_clause||'
    where t.c_end_date = edcs.c_end_date(+)
    GROUP BY '||l_group_by_clause||'
   ORDER BY
    '||l_order_by;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := bis_query_attributes_tbl();
  x_custom_output.extend;
  l_custom_rec.attribute_name := ':STATUS_ID';
  l_custom_rec.attribute_value := REPLACE(l_status,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output(1) := l_custom_rec;

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':PRIORITY_ID';
  l_custom_rec.attribute_value := l_priority;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(2) := l_custom_rec;

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':TYPE_ID';
  l_custom_rec.attribute_value := REPLACE(l_type,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output(3) := l_custom_rec;

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':REASON_ID';
  l_custom_rec.attribute_value := l_reason;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(4) := l_custom_rec;

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':NVL_DATE';
  l_custom_rec.attribute_value := '31/12/3000';
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
  x_custom_output(5) := l_custom_rec;

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':ORGANIZATION_ID';
  l_custom_rec.attribute_value := REPLACE(l_org,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output(6) := l_custom_rec;

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':ITEM_ID';
  l_custom_rec.attribute_value := l_item;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(7) := l_custom_rec;

--Bug 5083652 -- Start Code

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':PERIODTYPE';
  l_custom_rec.attribute_value := REPLACE(l_period_type,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(8) := l_custom_rec;

   x_custom_output.extend;
  l_custom_rec.attribute_name := ':COMPARETYPE';
  l_custom_rec.attribute_value := REPLACE(l_comp_type,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(9) := l_custom_rec;


  x_custom_output.extend;
  l_custom_rec.attribute_name := ':PERIODAND';
  l_custom_rec.attribute_value := REPLACE(l_period_bitand,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output(10) := l_custom_rec;

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':CUR_PERIOD_ID';
  l_custom_rec.attribute_value := REPLACE(l_cur_period,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output(11) := l_custom_rec;

--Bug 5083652 -- End Code

END GET_SQL;
END ENI_DBI_CAT_PKG;

/
