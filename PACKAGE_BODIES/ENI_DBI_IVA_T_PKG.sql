--------------------------------------------------------
--  DDL for Package Body ENI_DBI_IVA_T_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_IVA_T_PKG" AS
/*$Header: ENIIVTPB.pls 120.1.12000000.2 2007/02/22 08:52:07 lparihar ship $*/

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
    l_where_clause VARCHAR2(1000) := NULL;
    l_group_by_clause VARCHAR2(1000);

    l_comp_where VARCHAR2(100);

    l_summary VARCHAR2(100);

    l_err_msg VARCHAR2(100);

    -- The record structure for bind variable values
    l_custom_rec BIS_QUERY_ATTRIBUTES;

    l_curr_suffix      VARCHAR2(20);
    l_g_curr_prim     CONSTANT VARCHAR2(15) := '''FII_GLOBAL1''';
    l_g_curr_sec      CONSTANT VARCHAR2(15) := '''FII_GLOBAL2''';

  BEGIN

    for i in 1..p_page_parameter_tbl.COUNT
    LOOP
      IF ((p_page_parameter_tbl(i).parameter_name = 'ITEM+ENI_ITEM')
          OR  (p_page_parameter_tbl(i).parameter_name = 'ITEM+ENI_ITEM_ORG')) THEN

        l_item_org := p_page_parameter_tbl(i).parameter_id;

      END IF;
    END LOOP;

    eni_dbi_util_pkg.get_parameters(
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

    l_where_clause := NULL;

    IF (l_item IS NULL AND l_category IS NULL) THEN

      l_from_clause := 'eni_dbi_inv_sum_mv edismv';
      l_where_clause := ' edismv.marker = 1 AND edismv.time_id (+) = ftrs.time_id ';

    ELSIF (l_item IS NULL AND l_category IS NOT NULL) THEN

      l_from_clause := 'eni_dbi_inv_sum_mv edismv';
      /**Bug 5843937*/
      l_where_clause := ' edismv.organization_id IS NOT NULL AND edismv.marker = 2 AND edismv.time_id (+) = ftrs.time_id ';
      l_where_clause := l_where_clause || 'AND edismv.product_category_id = :CATEGORY_ID '; -- || l_category; Bug 5083662

    ELSIF (l_item IS NOT NULL AND l_category IS NULL) THEN

      l_from_clause := 'eni_dbi_inv_sum_mv edismv';
      l_where_clause := ' edismv.marker = 3 AND edismv.time_id (+) = ftrs.time_id ';
      --Discussed with Lakshaman and replacing the IN clause with a join (for l_item_org)
      l_where_clause := l_where_clause || ' AND edismv.item_org_id = :ITEM_ORG '; -- || l_item_org || Bug 5083662

    ELSIF (l_item IS NOT NULL AND l_category IS NOT NULL) THEN

      l_from_clause := 'eni_dbi_inv_sum_mv edismv, eni_denorm_hierarchies edh';
      l_where_clause := ' edismv.marker = 3 AND edismv.time_id (+) = ftrs.time_id ';
      --Discussed with Lakshaman and replacing the IN clause with a join (for l_item_org)
      l_where_clause := l_where_clause || ' AND edismv.item_org_id = :ITEM_ORG '; -- || l_item_org || Bug 5083662
      l_where_clause := l_where_clause || ' AND edh.parent_id = :CATEGORY_ID '|| --|| l_category || Bug 5083662
                              ' AND edismv.product_category_id = edh.child_id ';

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

    l_curr_suffix :=
      CASE l_currency
        WHEN l_g_curr_sec  THEN 'sg'   -- secondary global currency
        ELSE 'g'                       -- primary global currency (default)
      END;

/*
Bug : 3258092
Desc: Values computed for XTD instead of ITD. Values stored in base table are instaneous not summary

Bug: 3123997
Inv Total, InTransit Value and WIP Value mustbe N/A if the item doesn't exist
Issue: NVL(edismv.xxxx,0)
Fix  : edismv.xxxx
       removed the 'else' clause as well
*/

    x_custom_sql := '
      SELECT
          date_name AS VIEWBY
          , SUM(ENI_MEASURE1)  AS ENI_MEASURE1
          , SUM(ENI_MEASURE50) AS ENI_MEASURE50
          , SUM(ENI_MEASURE2)  AS ENI_MEASURE2
          , SUM(ENI_MEASURE4)  AS ENI_MEASURE4
          , SUM(ENI_MEASURE5)  AS ENI_MEASURE5
          , SUM(ENI_MEASURE7)  AS ENI_MEASURE7
          , SUM(ENI_MEASURE8)  AS ENI_MEASURE8
          , SUM(ENI_MEASURE10) AS ENI_MEASURE10
          , SUM(ENI_MEASURE11) AS ENI_MEASURE11
          , SUM(ENI_MEASURE14) AS ENI_MEASURE14
          , SUM(ENI_MEASURE15) AS ENI_MEASURE15
          , SUM(ENI_MEASURE16) AS ENI_MEASURE16
      FROM
          (
               (
               SELECT
                  t.name AS date_name,
                  t.start_date AS start_date,
                  SUM
                  (
                      case when ftrs.report_date = t.c_end_date
                      THEN edismv.inv_total_value_'||l_curr_suffix||'
                      ELSE 0
                      END
                  ) AS ENI_MEASURE1,
                  SUM
                  (
                      case when ftrs.report_date = t.c_end_date
                      THEN edismv.inv_total_value_'||l_curr_suffix||'
                      ELSE 0
                      END
                  ) AS ENI_MEASURE50,
                  SUM
                  (
                      case when ftrs.report_date = t.p_end_date
                      THEN edismv.inv_total_value_'||l_curr_suffix||'
                      ELSE 0
                      END
                  ) AS ENI_MEASURE2,
                  SUM
                  (
                      case when ftrs.report_date = t.c_end_date
                      THEN edismv.onhand_value_'||l_curr_suffix||'
                      ELSE 0
                      END
                  ) AS ENI_MEASURE4,
                  SUM
                  (
                      case when ftrs.report_date = t.p_end_date
                      THEN edismv.onhand_value_'||l_curr_suffix||'
                      ELSE 0
                      END
                  ) AS ENI_MEASURE5,
                  SUM
                  (
                      case when ftrs.report_date = t.c_end_date
                      THEN edismv.intransit_value_'||l_curr_suffix||'
                      ELSE 0
                      END
                  ) AS ENI_MEASURE7,
                  SUM
                  (
                      case when ftrs.report_date = t.p_end_date
                      THEN edismv.intransit_value_'||l_curr_suffix||'
                      ELSE 0
                      END
                  ) AS ENI_MEASURE8,
                  SUM
                  (
                      case when ftrs.report_date = t.c_end_date
                      THEN edismv.wip_value_'||l_curr_suffix||'
                      ELSE 0
                      END
                  ) AS ENI_MEASURE10,
                  SUM
                  (
                      case when ftrs.report_date = t.p_end_date
                      THEN edismv.wip_value_'||l_curr_suffix||'
                      ELSE 0
                      END
                  ) AS ENI_MEASURE11,
                  10 AS ENI_MEASURE14,
                  11 AS ENI_MEASURE15,
                  12 AS ENI_MEASURE16
             FROM
                  ' || l_from_clause ||' , fii_time_rpt_struct ftrs,
                  (
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
                          AND c.'||l_id_column||' <= :CUR_PERIOD_ID '|| --Bug 5083662
                         'AND p.start_date >= ' || '&' || 'BIS_PREVIOUS_REPORT_START_DATE
                          ' || l_comp_where || '
                  ) t
              WHERE
                  ' || l_where_clause || '
                  AND (
                      t.c_end_date = ftrs.report_date
                      OR t.p_end_date = ftrs.report_date
                  )
                  AND BITAND(ftrs.record_type_id, 1143) = ftrs.record_type_id
              GROUP BY
                  t.name,t.start_date,t.c_end_date
              )
          UNION ALL
              (
              SELECT
                    c.name AS date_name
                  , c.start_date AS start_date
                  , NULL AS ENI_MEASURE1
                  , NULL AS ENI_MEASURE50
                  , NULL AS ENI_MEASURE2
                  , NULL AS ENI_MEASURE4
                  , NULL AS ENI_MEASURE5
                  , NULL AS ENI_MEASURE7
                  , NULL AS ENI_MEASURE8
                  , NULL AS ENI_MEASURE10
                  , NULL AS ENI_MEASURE11
                  , NULL AS ENI_MEASURE14
                  , NULL AS ENI_MEASURE15
                  , NULL AS ENI_MEASURE16
              FROM
                  ' || l_period_type ||' c, ' || l_period_type || ' p
              WHERE
                  c.start_date >= ' || '&' || 'BIS_CURRENT_REPORT_START_DATE
                  AND c.'||l_id_column||' <= :CUR_PERIOD_ID '|| --Bug 5083662
                 'AND p.start_date >= ' || '&' || 'BIS_PREVIOUS_REPORT_START_DATE
                  ' || l_comp_where || '
              )
          )
      GROUP BY date_name,start_date
      ORDER BY
          ' || l_order_by;

  --Bug 5083662 : Added Bind Parameters
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':CATEGORY_ID';
  l_custom_rec.attribute_value := REPLACE(l_category,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(1) := l_custom_rec;

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':CUR_PERIOD_ID';
  l_custom_rec.attribute_value := REPLACE(l_cur_period,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
  x_custom_output(2) := l_custom_rec;

  x_custom_output.extend;
  l_custom_rec.attribute_name := ':ITEM_ORG';
  l_custom_rec.attribute_value := REPLACE(l_item_org,'''');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output(3) := l_custom_rec;

  EXCEPTION

    WHEN OTHERS THEN
      NULL;

END get_sql;

END eni_dbi_iva_t_pkg;

/
