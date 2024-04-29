--------------------------------------------------------
--  DDL for Package Body ENI_DBI_PRC_T_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_PRC_T_PKG" AS
/*$Header: ENIPRTPB.pls 120.0 2005/05/26 19:38:53 appldev noship $*/

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
l_item VARCHAR2(5000);
l_org VARCHAR2(5000);
l_item_org VARCHAR2(5000);
l_id_column VARCHAR2(100);
l_order_by VARCHAR2(100);
l_drill VARCHAR2(10);
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
l_where_clause VARCHAR2(1000) := NULL;
l_group_by_clause VARCHAR2(500);

l_comp_where VARCHAR2(100);

l_err_msg VARCHAR2(100);

l_table VARCHAR2(100);

-- The record structure for bind variable values
l_custom_rec BIS_QUERY_ATTRIBUTES;

l_view_by_col VARCHAR2(100);
l_group_by_col VARCHAR2(100);
l_lookup VARCHAR2(100);
l_summary VARCHAR2(100);
l_oex_columns VARCHAR2(1000) := NULL;
l_drill_params VARCHAR2(400);
l_drill_to_other_expenses VARCHAR2(500);
l_revenue	VARCHAR2(100);
l_cogs		VARCHAR2(100);
l_expense	VARCHAR2(100);
l_currency_value    VARCHAR2(100);

BEGIN

     l_revenue := 'rev_amount';
     l_cogs  := 'cogs_amount';
     l_expense := 'exp_amount';


	    for i in 1..p_page_parameter_tbl.COUNT
            LOOP
                IF ((p_page_parameter_tbl(i).parameter_name = 'ITEM+ENI_ITEM')
                   OR  (p_page_parameter_tbl(i).parameter_name = 'ITEM+ENI_ITEM_ORG')) THEN
                    l_item_org := p_page_parameter_tbl(i).parameter_id;
		    EXIT;
                END IF;
            END LOOP;

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

    l_currency_value := eni_dbi_util_pkg.get_curr_sec;

--    l_currency := TRIM(both '''' from l_currency);

    IF (l_currency = l_currency_value) THEN
	   l_revenue := 'rev_sec_amount';
	   l_cogs  := 'cogs_sec_amount';
	   l_expense := 'exp_sec_amount';
    END IF;

    l_drill_to_other_expenses := 'decode(ENI_MEASURE13, 0, NULL, NULL, NULL,''pFunctionName=ENI_DBI_OEX_R'  ||
                             '&' || 'VIEW_BY_NAME=VIEW_BY_ID' ||
                             '&' || 'VIEW_BY=LOB+FII_LOB' || '&' || 'pParamIds=Y'') ';
    l_summary := 'edps2mv';
    l_oex_columns := '
        ,   SUM
            (
                case when ftrs.report_date = t.c_end_date
                then
                   ' ||l_summary|| '.' || l_expense || '
                else
                    NULL
                end
            )
            AS ENI_MEASURE13
        ,   SUM
            (
                case when ftrs.report_date = t.p_end_date
                then
                   ' ||l_summary|| '.' || l_expense || '
                else
                    NULL
                end
            )
            AS ENI_MEASURE14 ';
    IF (l_item IS NULL AND l_category IS NULL) THEN
/*          l_from_clause := ' (select * from eni_dbi_prc_sum2_mv ' ||
                           ' where marker = 1) edps2mv'; */
	  l_from_clause := 'eni_dbi_prc_sum2_mv edps2mv';
	  l_where_clause := 'edps2mv.marker = 1 and
	                     edps2mv.time_id (+) = ftrs.time_id';
    ELSIF (l_item IS NULL AND l_category IS NOT NULL) THEN
          l_oex_columns := ' , null AS ENI_MEASURE13, null AS ENI_MEASURE14 ';
/*          l_from_clause := ' (select * from eni_dbi_prc_sum2_mv edps2mv ' ||
                           ' where edps2mv.marker = 2 ' ||
                           ' AND edps2mv.product_category_id = '|| l_category ||' ) edps2mv';  */
	  l_from_clause := 'eni_dbi_prc_sum2_mv edps2mv';
	  l_where_clause := 'edps2mv.marker = 2 and
	                     edps2mv.time_id (+) = ftrs.time_id and
			     edps2mv.product_category_id = :PRODUCT_CATEGORY';
    ELSIF (l_item IS NOT NULL AND l_category IS NULL) THEN
          l_summary := 'edps1mv';
          l_oex_columns := ' , null AS ENI_MEASURE13, null AS ENI_MEASURE14 ';
/*          l_from_clause := ' (select * from eni_dbi_prc_sum1_mv edps1mv ' ||
                           ' where edps1mv.item_org_id IN (' || l_item_org || '))edps1mv ' ;  */
	  l_from_clause := 'eni_dbi_prc_sum1_mv edps1mv';
	  l_where_clause := 'edps1mv.time_id (+) = ftrs.time_id and
			     edps1mv.item_org_id IN ('|| '&' || 'ITEM+ENI_ITEM)';
    ELSIF (l_item IS NOT NULL AND l_category IS NOT NULL) THEN
          l_summary := 'edps1mv';
          l_oex_columns := ' , null AS ENI_MEASURE13, null AS ENI_MEASURE14 ';
/*          l_from_clause := ' (select * from eni_dbi_prc_sum1_mv edps1mv ' ||
                           ' , eni_denorm_hierarchies edh ' ||
                           ' where edps1mv.item_org_id IN (' || l_item_org || ')' ||
                           ' AND edh.parent_id = '|| l_category ||
                           ' AND edh.child_id = edps1mv.product_category_id ) edps1mv';  */
          l_from_clause := ' eni_dbi_prc_sum1_mv edps1mv, eni_denorm_hierarchies edh ';
          l_where_clause := 'edps1mv.time_id (+) = ftrs.time_id and ' ||
	                   ' edps1mv.item_org_id IN (' || '&' || 'ITEM+ENI_ITEM)' ||
                           ' AND edh.parent_id = :PRODUCT_CATEGORY' ||
                           ' AND edh.child_id = edps1mv.product_category_id ';
    END IF;
    IF UPPER(l_order_by) LIKE '%START_DATE%ASC' THEN
          l_order_by := 'start_date asc' ;
    ELSIF UPPER(l_order_by) LIKE '%START_DATE%DESC' THEN
          l_order_by := 'start_date desc' ;
    ELSIF UPPER(l_order_by) LIKE '%START_DATE%' THEN
          l_order_by := 'start_date asc' ;
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

    l_drill_params := '&' || 'VIEW_BY=LOB+FII_LOB';

x_custom_sql :=
'
 SELECT
	date_name AS VIEWBY
	, SUM(ENI_MEASURE1)  AS ENI_MEASURE1
	, SUM(ENI_MEASURE2)  AS ENI_MEASURE2
	, SUM(ENI_MEASURE7)  AS ENI_MEASURE7
	, SUM(ENI_MEASURE8)  AS ENI_MEASURE8
	, SUM(ENI_MEASURE11) AS ENI_MEASURE11
	, SUM(ENI_MEASURE17) AS ENI_MEASURE17
	, SUM(ENI_MEASURE10) AS ENI_MEASURE10
	, SUM(ENI_MEASURE13) AS ENI_MEASURE13
	, SUM(ENI_MEASURE14) AS ENI_MEASURE14
	, SUM(ENI_MEASURE16) AS ENI_MEASURE16
	, SUM(ENI_MEASURE43) AS ENI_MEASURE43
	, SUM(ENI_MEASURE47) AS ENI_MEASURE47
FROM
(
   SELECT
        date_name
        , start_date -- start_date
        , ENI_MEASURE1  -- current revenue
        , ENI_MEASURE2  -- prior revenue
        , ENI_MEASURE7  -- current cogs
        , ENI_MEASURE8  -- prior cogs
        , ((ENI_MEASURE2 - ENI_MEASURE8)
           /decode(ENI_MEASURE2, 0, null, ENI_MEASURE2))*100
          AS ENI_MEASURE11  -- prior gross margin
        , ((ENI_MEASURE2 - ENI_MEASURE8 - ENI_MEASURE14)
           /decode(ENI_MEASURE2, 0, null, ENI_MEASURE2))*100
          AS ENI_MEASURE17  -- prior product margin
        , ((ENI_MEASURE1 - ENI_MEASURE7)
            /decode(ENI_MEASURE1, 0, null, ENI_MEASURE1))*100
          AS ENI_MEASURE10  -- current gross margin
        , ENI_MEASURE13 -- current other expenses
        , ENI_MEASURE14  -- prior other expenses
        , ((ENI_MEASURE1 - ENI_MEASURE7 - ENI_MEASURE13)
           /decode(ENI_MEASURE1, 0, null, ENI_MEASURE1))*100
          AS ENI_MEASURE16  -- current product margin
        , NULL AS ENI_MEASURE43 -- drill across url for other expenses
	   -- Removed the drill for the bug # 3659784
        , NVL(ENI_MEASURE7,0)+NVL(ENI_MEASURE13,0)
          AS ENI_MEASURE47  -- for Costs(COGS+Expenses) on graph 1
    FROM
    (
	SELECT
		t.name AS date_name
		,t.start_date as start_date
		,SUM(
			case when ftrs.report_date = t.c_end_date
			then ' ||l_summary|| '.' || l_revenue || '
			else NULL
			end
		    ) AS ENI_MEASURE1
		,SUM(
			case when ftrs.report_date = t.p_end_date
			then ' ||l_summary|| '.' || l_revenue || '
			else 0
			end
		    ) AS ENI_MEASURE2
		,SUM(
			case when ftrs.report_date = t.c_end_date
			then ' ||l_summary|| '.' || l_cogs || '
			else NULL
			end
		    ) AS ENI_MEASURE7
		,SUM(
			case when ftrs.report_date = t.p_end_date
			then ' ||l_summary|| '.' || l_cogs || '
			else 0
			end
		    ) AS ENI_MEASURE8
	        '||l_oex_columns||'
   		,SUM
                    (
			case when ftrs.report_date = t.c_end_date
			then NVL(((' ||l_summary|| '.' || l_revenue || ' - ' ||l_summary|| '.' || l_cogs || '
                             - ' ||l_summary|| '.' || l_expense || ')/decode(' ||l_summary|| '.' || l_revenue || ', 0, null, ' ||l_summary|| '.' || l_revenue || '))*100,0)
	                else NULL
			end
		    ) AS ENI_MEASURE16
		,SUM
		    (
	                case when ftrs.report_date = t.p_end_date
		        then ((' ||l_summary|| '.' || l_revenue || ' - ' ||l_summary|| '.' || l_cogs || '
                               - ' ||l_summary|| '.' || l_expense || ')/decode(' ||l_summary|| '.' || l_revenue || ', 0, null, ' ||l_summary|| '.' || l_revenue || '))*100
	                else 0
			end
		    ) AS ENI_MEASURE17
	      , DECODE( SUM( case when ftrs.report_date = t.c_end_date
		             then ' ||l_summary|| '.' || l_expense || '
	                     else NULL end),
			0, null, ''pFunctionName=ENI_DBI_OEX_R'||l_drill_params||''') -- drill across url for other expenses
	        AS ENI_MEASURE43
	FROM
		' || l_from_clause || '
                , fii_time_rpt_struct ftrs
		, (
			SELECT
				c.name,
				c.'||l_id_column||',
				c.start_date AS start_date,
				(case when  '|| '&' || 'BIS_CURRENT_ASOF_DATE < c.end_date
				then  '|| '&' || 'BIS_CURRENT_ASOF_DATE else c.end_date end ) AS c_end_date,
				(case when  '|| '&' || 'BIS_PREVIOUS_ASOF_DATE < p.end_date
				then  '|| '&' || 'BIS_PREVIOUS_ASOF_DATE else p.end_date end ) AS p_end_date
			FROM
				' || l_period_type ||' c, ' || l_period_type || ' p
			WHERE
				c.start_date >= ' || '&' || 'BIS_CURRENT_REPORT_START_DATE
				AND c.'||l_id_column||' <= :PERIOD_ID ' || '
				AND p.start_date >= ' || '&' || 'BIS_PREVIOUS_REPORT_START_DATE
				' || l_comp_where || '
		  ) t
	WHERE
		(
			t.c_end_date = ftrs.report_date
			OR t.p_end_date = ftrs.report_date
		)
		AND BITAND(ftrs.record_type_id,  &' || 'BIS_NESTED_PATTERN) = ftrs.record_type_id
		AND ' || l_where_clause || '
	GROUP BY
		t.name,t.start_date,t.c_end_date
	)
  UNION ALL
	SELECT
		  c.name AS date_name
		, c.start_date AS start_date
	    , NULL AS ENI_MEASURE1
	    , NULL AS ENI_MEASURE2
	    , NULL AS ENI_MEASURE7
	    , NULL AS ENI_MEASURE8
	    , NULL AS ENI_MEASURE11
	    , NULL AS ENI_MEASURE17
	    , NULL AS ENI_MEASURE10
	    , NULL AS ENI_MEASURE13
	    , NULL AS ENI_MEASURE14
	    , NULL AS ENI_MEASURE16
	    , NULL AS ENI_MEASURE43
	    , NULL AS ENI_MEASURE47
	FROM
		' || l_period_type ||' c, ' || l_period_type || ' p
	WHERE
		c.start_date >= ' || '&' || 'BIS_CURRENT_REPORT_START_DATE
		AND c.'||l_id_column||' <= :PERIOD_ID'  || '
		AND p.start_date >= ' || '&' || 'BIS_PREVIOUS_REPORT_START_DATE
		' || l_comp_where || '
  )
  GROUP BY date_name,start_date
  ORDER BY
            ' || l_order_by ;


	x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
        l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

	x_custom_output.extend;
        l_custom_rec.attribute_name := ':PERIOD_ID';
        l_custom_rec.attribute_value := l_cur_period;
        l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
        x_custom_output.extend;
        x_custom_output(1) := l_custom_rec;

	IF (l_category is not null ) THEN
		x_custom_output.extend;
		l_custom_rec.attribute_name := ':PRODUCT_CATEGORY';
		l_custom_rec.attribute_value := TRIM(BOTH '''' FROM l_category);
		l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
		l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
		x_custom_output.extend;
		x_custom_output(2) := l_custom_rec;
	END IF;

END get_sql;

END eni_dbi_prc_t_pkg;

/
