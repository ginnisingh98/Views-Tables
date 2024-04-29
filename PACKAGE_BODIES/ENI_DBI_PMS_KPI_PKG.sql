--------------------------------------------------------
--  DDL for Package Body ENI_DBI_PMS_KPI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_PMS_KPI_PKG" AS
/* $Header: ENIPMSPB.pls 120.2 2006/03/23 04:42:05 pgopalar noship $ */

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

l_err_msg VARCHAR2(100);

-- The record structure for bind variable values
l_custom_rec BIS_QUERY_ATTRIBUTES;

l_view_by_col VARCHAR2(100);
l_group_by_col VARCHAR2(100);
l_lookup VARCHAR2(100);
l_summary VARCHAR2(100);

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

		IF l_category  IS NOT NULL THEN

            		l_where_clause := l_where_clause ||
			        --' AND parent_prod_cat_id = ' || l_category;
				' AND parent_prod_cat_id = :CATEGORY';               -- Bug 5083911


		ELSIF l_category IS NULL THEN

	    		l_where_clause := l_where_clause ||
				' AND parent_prod_cat_id = -2 ';

		END IF;

	  -- All items in a specific category
	x_custom_sql :=
	'
		SELECT
			SUM
			(
				case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
				then
					fars.rev_prim_actual_g
				else
					0
				end
			) AS ENI_MEASURE1,
			SUM
			(
				case
					when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
				then
					fars.rev_prim_actual_g
				else
					0
				end
			) AS ENI_MEASURE2,
			SUM
			(
				case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
				then
					fars.cogs_value_g
				else
					0
				end
			) AS ENI_MEASURE5,
			SUM
			(
				case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
				then
					fars.cogs_value_g
				else
					0
				end
			) AS ENI_MEASURE6,
			SUM
			(
				case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
				then
					fars.prim_actual_g
				else
					0
				end
			) AS ENI_MEASURE7,
			SUM
			(
				case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
				then
					fars.prim_actual_g
				else
					0
				end
			) AS ENI_MEASURE8,
			SUM
			(
				case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
				then
					((fars.rev_prim_actual_g - (cogs_value_g + prim_actual_g))
					/decode(fars.rev_prim_actual_g, 0, null, fars.rev_prim_actual_g))*100
				else
					0
				end
			) AS ENI_MEASURE9,
			SUM
			(
				case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
				then
					((fars.rev_prim_actual_g - (cogs_value_g + prim_actual_g))
					/decode(fars.rev_prim_actual_g, 0, null, fars.rev_prim_actual_g))*100
				else
					0
				end
			) AS ENI_MEASURE10,
			SUM
			(
				case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
				then
					fars.inv_total_value_g
				else
					0
				end
			) AS ENI_MEASURE11,
			SUM
			(
				case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
				then
					fars.inv_total_value_g
				else
					0
				end
			) AS ENI_MEASURE12
		FROM
			eni_dbi_prc_sum_c_mv fars,
			fii_time_rpt_struct ftrs
		WHERE
			fars.time_id = ftrs.time_id
			AND
			(
				ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
				OR ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
			)
			--AND BITAND(ftrs.record_type_id, ' || l_period_bitand || ') = ftrs.record_type_id
			AND BITAND(ftrs.record_type_id,:PERIODAND) = ftrs.record_type_id                 --Bug 5083911
			' || l_where_clause;


	x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
        l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
        x_custom_output.extend;

        l_custom_rec.attribute_name := ':ITEM+ENI_ITEM';
        l_custom_rec.attribute_value := 5;
        l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
        x_custom_output.extend;
        x_custom_output(1) := l_custom_rec;

        -- Start Bug 5083911
	x_custom_output.extend;
        l_custom_rec.attribute_name := ':CATEGORY';
        l_custom_rec.attribute_value :=replace(l_category,'''');
        l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        x_custom_output(2) := l_custom_rec;

        x_custom_output.extend;
        l_custom_rec.attribute_name := ':PERIODAND'; --Bug 5083652
        l_custom_rec.attribute_value := replace(l_period_bitand,'''');
        l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
        x_custom_output(3) := l_custom_rec;

	-- End Bug 5083911

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
	  l_custom_rec.attribute_name := ':CUR_PERIOD_ID';
	  l_custom_rec.attribute_value := REPLACE(l_cur_period,'''');
	  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
	  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
	  x_custom_output(11) := l_custom_rec;

	--Bug 5083652 -- End Code

END get_sql;

END eni_dbi_pms_kpi_pkg;

/
