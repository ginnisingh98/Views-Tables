--------------------------------------------------------
--  DDL for Package Body ENI_DBI_OEX_T_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_OEX_T_PKG" AS
/*$Header: ENIOETPB.pls 120.2 2006/03/23 04:38:10 pgopalar noship $*/

PROCEDURE get_sql
(
        p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
        x_custom_sql OUT NOCOPY VARCHAR2,
        x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
)
IS

l_period_type VARCHAR2(100);
l_period_bitand NUMBER;
l_view_by VARCHAR2(100);
l_as_of_date DATE;
l_prev_as_of_date DATE;
l_report_start DATE;
l_cur_period NUMBER;
l_days_into_period NUMBER;
l_comp_type VARCHAR2(100);
l_category VARCHAR2(100);
l_item VARCHAR2(100);
l_org VARCHAR2(100);
l_id_column VARCHAR2(100);
l_order_by VARCHAR2(100);
l_drill VARCHAR2(100);
l_status VARCHAR2(100);
l_priority VARCHAR2(100);
l_reason VARCHAR2(100);
l_lifecycle_phase VARCHAR2(100);
l_currency VARCHAR2(100);
l_bom_type VARCHAR2(100);
l_type VARCHAR2(100);
l_manager VARCHAR2(100);
l_lob VARCHAR2(100);

l_from_clause VARCHAR2(1000);
l_where_clause VARCHAR2(1000);
l_group_by_clause VARCHAR2(1000);

l_comp_where VARCHAR2(100);

l_err_msg VARCHAR2(100);

-- The record structure for bind variable values
l_custom_rec BIS_QUERY_ATTRIBUTES;

l_currency_column varchar2(30);
l_currency_string varchar2(100);
BEGIN

            eni_dbi_util_pkg.get_parameters
            (
                        p_page_parameter_tbl,
                        l_period_type,
                        l_period_bitand,
                        l_view_by,
                        l_as_of_date,
                        l_prev_as_of_date,
                        l_report_start,
                        l_cur_period,
                        l_days_into_period,
                        l_comp_type,
                        l_category,
                        l_item,
                        l_org,
                        l_id_column,
                        l_order_by,
                        l_drill,
                        l_status,
                        l_priority,
                        l_reason,
                        l_lifecycle_phase,
                        l_currency,
                        l_bom_type,
                        l_type,
                        l_manager,
                        l_lob
            );

/* To provide secondary currency support */
  l_currency := TRIM(both '''' from l_currency);
  l_currency_string := 	eni_dbi_util_pkg.get_curr_prim;
  l_currency_string := TRIM(both '''' from l_currency_string);

  IF    l_currency = l_currency_string THEN
	l_currency_column := 'PRIM_ACTUAL_G';
  ELSE
	l_currency_column := 'SEC_ACTUAL_G';
  END IF;
/* To provide secondary currency support */

            eni_dbi_util_pkg.get_time_clauses
            (
                        'A',
			    'fgbm',
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
			    l_group_by_clause
            );

	    l_where_clause := NULL;
	    --Bug 5083913 Replaced l_category with :CATEGORY
            IF l_category  IS NOT NULL THEN
            	l_where_clause := l_where_clause ||
			'AND product_category_id (+) = :CATEGORY
			 AND gid (+) = 2
              AND marker (+) = 1';
	        ELSE
	    	l_where_clause := l_where_clause ||
			' AND gid (+) = 0
              AND marker(+) = 2';
            END IF;

	    IF l_comp_type = 'SEQUENTIAL' THEN
	    	l_comp_where := 'AND c.start_date = p.end_date + 1';
	    ELSIF l_period_type = 'FII_TIME_WEEK' THEN
	    	l_comp_where := 'AND c.week_id = p.week_id + 10000';
	    ELSIF l_period_type = 'FII_TIME_ENT_PERIOD' THEN
	    	l_comp_where := 'AND c.ent_period_id = p.ent_period_id + 1000';
	    ELSIF l_period_type = 'FII_TIME_ENT_QTR' THEN
	    	l_comp_where := 'AND c.ent_qtr_id = p.ent_qtr_id + 10';
	    ELSIF l_period_type = 'FII_TIME_ENT_YEAR' THEN
	    	l_comp_where := 'AND c.ent_year_id = p.ent_year_id + 1';
            END IF;

/*
          Bug: 3450100
	        1.  BIS PMV returns Order by clause with NLSSORT(t.start_date,'NLS_BINARY')
                     Removed NLSSORT as this must be applied only to character columns not date column

		2.  The FII TIME where clause contained    	AND p.start_date < ' ||'&'||'BIS_PREVIOUS_ASOF_DATE
		      This will return n-1 data points if the as_of_date is first date in the qtr,year,period, week
		      hence removed this condition


*/
        IF UPPER(l_order_by) LIKE '%DESC%' THEN
             l_order_by := 't.start_date desc' ;
        ELSE
             l_order_by := 't.start_date asc' ;
        END IF;

            x_custom_sql := '
			SELECT
				t.name AS VIEWBY,
				SUM(case when ftrs.report_date = t.c_end_date
				THEN NVL(fgbm.' || l_currency_column ||   ', 0)
				ELSE 0 END) AS ENI_MEASURE1,
				SUM(case when ftrs.report_date = t.p_end_date
				THEN NVL(fgbm.' || l_currency_column ||   ', 0)
				ELSE 0 END) AS ENI_MEASURE2
			FROM
				eni_dbi_gl_base_sum_mv fgbm,
				fii_time_rpt_struct ftrs,
				(
					SELECT
						c.name,
						c.'||l_id_column||',
						c.start_date AS start_date,
						(case when  '|| '&' || 'BIS_CURRENT_ASOF_DATE < c.end_date
						then  '|| '&' || 'BIS_CURRENT_ASOF_DATE else c.end_date end ) AS c_end_date,
						(case when '|| '&' || 'BIS_PREVIOUS_ASOF_DATE < p.end_date
                                                then '|| '&' || 'BIS_PREVIOUS_ASOF_DATE else p.end_date end) AS p_end_date
					FROM
						' || l_period_type ||' c, ' || l_period_type || ' p
					WHERE
						c.start_date >= ' || '&' || 'BIS_CURRENT_REPORT_START_DATE
						AND c.'||l_id_column||' <= :CUR_PERIOD_ID
						AND p.start_date >= ' || '&' || 'BIS_PREVIOUS_REPORT_START_DATE
						' || l_comp_where || '
				) t
			WHERE
				(
					t.c_end_date = ftrs.report_date
					OR t.p_end_date = ftrs.report_date
				)
				AND fgbm.time_id (+) = ftrs.time_id
				AND BITAND(ftrs.record_type_id, ' || '&' || 'BIS_NESTED_PATTERN ) = ftrs.record_type_id
                                ' || l_where_clause || '
			GROUP BY
				' || l_group_by_clause || '
			ORDER BY
				' || l_order_by;

	    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
	    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
	    x_custom_output.extend;

	    l_custom_rec.attribute_name := ':CUR_PERIOD_ID';
	    l_custom_rec.attribute_value := l_cur_period;
	    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
	    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
	    x_custom_output.extend;
	    x_custom_output(1) := l_custom_rec;

	    l_custom_rec.attribute_name := ':CATEGORY';
	    l_custom_rec.attribute_value := l_category;
	    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
	    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
	    x_custom_output.extend;
	    x_custom_output(2) := l_custom_rec;

	    --Bug 5083652 -- Start Code

	    x_custom_output.extend;
	    l_custom_rec.attribute_name := ':PERIODTYPE';
	    l_custom_rec.attribute_value := REPLACE(l_period_type,'''');
   	    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
	    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
	    x_custom_output(3) := l_custom_rec;

	    x_custom_output.extend;
	    l_custom_rec.attribute_name := ':COMPARETYPE';
	    l_custom_rec.attribute_value := REPLACE(l_comp_type,'''');
	    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
	    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
	    x_custom_output(4) := l_custom_rec;


	    x_custom_output.extend;
	    l_custom_rec.attribute_name := ':PERIODAND';
	    l_custom_rec.attribute_value := REPLACE(l_period_bitand,'''');
	    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
	    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
	    x_custom_output(5) := l_custom_rec;

	    --Bug 5083652 -- End Code

END get_sql;

END eni_dbi_oex_t_pkg;

/
