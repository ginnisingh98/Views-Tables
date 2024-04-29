--------------------------------------------------------
--  DDL for Package Body ENI_DBI_OEX_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_OEX_PKG" AS
/*$Header: ENIOEXPB.pls 120.2 2006/03/23 04:39:16 pgopalar noship $*/

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
l_group_by_clause VARCHAR2(500);
l_lookup_group VARCHAR2(500);

l_summary VARCHAR2(100);
l_view_by_col VARCHAR2(100);
l_group_by_col VARCHAR2(100);
l_lookup_select VARCHAR2(100);
l_lookup VARCHAR2(100);
l_drill_to_cat_url VARCHAR2(500);

l_err_msg VARCHAR2(100);
l_cbo_hint VARCHAR2(100);
/* PERF FIX:
    added due to CBO performing a FTS of FTRS; please check explain plans when modifying the
    generated SQL */

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

            IF l_view_by = 'LOB+FII_LOB' THEN

                l_summary := 'eni_dbi_gl_base_sum_mv';

                l_view_by_col   := 'lookupv.value AS VIEWBY, lookupv.id VIEWBYID ';
                l_group_by_col  := 'lookupv.value, lookupv.id ';
                l_lookup        := 'fii_lob_v lookupv';
                l_where_clause  := l_where_clause ||
                                ' AND fgbm.line_of_business_id = lookupv.id ' ||
                                ' AND fgbm.line_of_business_id = lookupv.parent_id ' ||
                                ' AND fgbm.gid = 0';
                                -- using fgbm.line_of_business_id => no FTS in explain plan
                l_drill_to_cat_url := 'NULL';

                IF l_category IS NOT NULL THEN
                    l_where_clause := l_where_clause ||
                                ' AND fgbm.product_category_id = :CATEGORY_ID '|| --|| l_category  || Bug 5083699
                                ' AND fgbm.marker = 1';

                ELSE -- l_category IS NULL THEN
                    l_where_clause := l_where_clause ||
                                ' AND fgbm.marker = 3';
                END IF;

            ELSIF l_view_by = 'ITEM+ENI_ITEM_VBH_CAT' THEN

                l_summary := 'eni_dbi_gl_base_sum_c_mv';
                l_cbo_hint := '/*+ LEADING (ftrs) */';

                l_view_by_col   :=  'lookupv.value AS VIEWBY, lookupv.id VIEWBYID, lookupv.leaf_node_flag ';
                l_group_by_col  := 'lookupv.value, lookupv.id, lookupv.leaf_node_flag ';
                l_lookup        := 'eni_item_vbh_nodes_v lookupv';
                l_where_clause  := l_where_clause ||
                                ' AND fgbm.CHILD_PROD_CAT_ID = lookupv.id ' ||
                                ' AND fgbm.CHILD_PROD_CAT_ID = lookupv.parent_id ';
                                -- using fgbm.CHILD_PROD_CAT_ID => no FTS in explain plan
                l_drill_to_cat_url := '
                                               decode(leaf_node_flag, ''Y'',
                                                 NULL,
                ''pFunctionName=ENI_DBI_OEX_R'  || '&' || 'VIEW_BY_NAME=VIEW_BY_ID' || '&' || 'VIEW_BY=ITEM+ENI_ITEM_VBH_CAT' || '&' || 'pParamIds=Y'') ';

                IF l_category IS NOT NULL THEN
                    -- viewing at the category level

                    l_where_clause := l_where_clause ||
                                ' AND fgbm.marker = 2 AND fgbm.parent_prod_cat_id = :CATEGORY_ID '; --|| l_category; Bug 5083699
                ELSE -- l_category IS NULL THEN

                    l_where_clause := l_where_clause ||
                                ' AND fgbm.parent_prod_cat_id = -2' ||
                                ' AND fgbm.marker = 1 ';
                END IF;
           END IF;

        x_custom_sql :=
         ' SELECT '|| l_cbo_hint ||'
            VIEWBY
           ,VIEWBYID
           , ' || l_drill_to_cat_url || ' AS ENI_ATTRIBUTE2
           ,ENI_MEASURE1
           ,ENI_MEASURE2
           ,ENI_MEASURE4
           ,ENI_MEASURE5
          FROM
           (
            SELECT ' || l_view_by_col || ',
                SUM
                (
                    case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
                    then
                            ' || l_currency_column ||   '
                    else
                        0
                    end
                ) AS ENI_MEASURE1,
                                SUM
                (
                    case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
                                        then
                        ' || l_currency_column ||   '
                                        else
                        0
                    end
                ) AS ENI_MEASURE2,

                SUM
                (
                    SUM
                    (
                    case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
                    then
                            ' || l_currency_column ||   '
                        else
                            0
                        end
                    )
                ) OVER() AS ENI_MEASURE4,

                SUM
                (
                    SUM
                    (
                    case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
                    then
                            ' || l_currency_column ||   '
                        else
                            0
                        end
                    )
                ) OVER() AS ENI_MEASURE5
            FROM
                ' || l_summary || ' fgbm,
                fii_time_rpt_struct ftrs,
                ' || l_lookup || '
            WHERE
                fgbm.time_id = ftrs.time_id
                AND
                (
                    ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
                        OR ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
                )
                AND BITAND(ftrs.record_type_id, ' || '&' || 'BIS_NESTED_PATTERN) = ftrs.record_type_id
                ' || l_where_clause || '
            GROUP BY
                ' || l_group_by_col || '
                )
            ORDER BY
                ' || l_order_by;

  --Bug 5083699 : Added Bind Parameter for CategoryId
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  l_custom_rec.attribute_name       := ':CATEGORY_ID';
  l_custom_rec.attribute_value      := replace(l_category,'''');
  l_custom_rec.attribute_type       := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type  := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

--Bug 5083652 -- Start Code

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':PERIODTYPE';
  l_custom_rec.attribute_value := REPLACE(l_period_type,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(2) := l_custom_rec;

   x_custom_output.extend;
  l_custom_rec.attribute_name := ':COMPARETYPE';
  l_custom_rec.attribute_value := REPLACE(l_comp_type,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(3) := l_custom_rec;


  x_custom_output.extend;
  l_custom_rec.attribute_name := ':PERIODAND';
  l_custom_rec.attribute_value := REPLACE(l_period_bitand,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output(4) := l_custom_rec;

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':CUR_PERIOD_ID';
  l_custom_rec.attribute_value := REPLACE(l_cur_period,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output(5) := l_custom_rec;

--Bug 5083652 -- End Code
END get_sql;

END eni_dbi_oex_pkg;

/
