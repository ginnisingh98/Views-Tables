--------------------------------------------------------
--  DDL for Package Body ENI_DBI_IVA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_IVA_PKG" AS
/*$Header: ENIIVAPB.pls 120.0.12000000.2 2007/02/22 08:49:28 lparihar ship $*/

  PROCEDURE get_sql
  (
        p_page_parameter_tbl IN BIS_PMV_PAGE_PARAMETER_TBL,
        x_custom_sql OUT NOCOPY VARCHAR2,
        x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL
  )
  IS

    l_period_type      VARCHAR2(100);
    l_period_bitand    NUMBER;
    l_view_by          VARCHAR2(100);
    l_as_of_date       DATE;
    l_prev_as_of_date  DATE;
    l_report_start     DATE;
    l_cur_period       NUMBER;
    l_days_into_period NUMBER;
    l_comp_type        VARCHAR2(100);
    l_category         VARCHAR2(100);
    l_item             VARCHAR2(5000);
    l_item_org         VARCHAR2(5000);
    l_id_column        VARCHAR2(100);
    l_order_by         VARCHAR2(100);
    l_drill            VARCHAR2(100);
    l_status           VARCHAR2(100);
    l_priority         VARCHAR2(100);
    l_reason           VARCHAR2(100);
    l_lifecycle_phase  VARCHAR2(100);
    l_currency         VARCHAR2(100);
    l_bom_type         VARCHAR2(100);
    l_type             VARCHAR2(100);
    l_manager          VARCHAR2(100);
    l_lob              VARCHAR2(100);

    l_from_clause      VARCHAR2(1000);
    l_from_clause_1    VARCHAR2(1000):= NULL;
    l_where_clause     VARCHAR2(1000) := NULL;
    l_group_by_clause  VARCHAR2(1000) := NULL;

    l_comp_where       VARCHAR2(100);
    l_org              VARCHAR2(500);
    l_summary          VARCHAR2(100);
    l_lookup_select    VARCHAR2(100);
    l_lookup           VARCHAR2(100);
    l_lookup_group     VARCHAR2(100);
    l_drill_to_cat_url VARCHAR2(500);
    l_err_msg          VARCHAR2(100);
    l_excep            VARCHAR2(1000);
    l_where_clause1    VARCHAR2(200);
    l_category1        NUMBER(15);
    top_flag           VARCHAR2(1):=NULL;
    leaf_flag          VARCHAR2(1):=NULL;
    -- The record structure for bind variable values
    l_custom_rec       BIS_QUERY_ATTRIBUTES;
    garbage            VARCHAR2(1000);
    l_lookup_where     VARCHAR2(1000);
    l_lookup_inner_select VARCHAR2(100);
    l_rank_measure     VARCHAR2(20);

    l_curr_suffix      VARCHAR2(20);
    l_curr             VARCHAR2(100);

  BEGIN

    --  Getting the value for the item org necessary for multiple item selection
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

    l_category1 := TRIM(both '''' from l_category);
    IF (l_category1 IS NOT NULL) THEN
      select top_node_flag,leaf_node_flag
        into top_flag,leaf_flag
        from eni_denorm_hierarchies edh
       where edh.parent_id = l_category1
         and edh.child_id = edh.parent_id;

      IF (top_flag = 'Y' and leaf_flag = 'Y') THEN

        l_where_clause1 := '';

      ELSE

        l_where_clause1 := ' AND lookupv.parent_id <> lookupv.child_id ';

      END IF;

    END IF;

    l_curr_suffix :=
      CASE l_currency
        WHEN ENI_DBI_UTIL_PKG.get_curr_sec  THEN 'sg'   -- secondary global currency
        ELSE 'g'                                        -- primary global currency (default)
      END;

    l_summary := 'edismv';
    IF (l_view_by = 'ITEM+ENI_ITEM') THEN

      -- Modified the clauses for product and organization viewbys to provide windowing feature. Bug # 3781824
      --  VIEW BY IS PRODUCT
      l_lookup_select := 'lookupv.value VIEWBY, lookupv.id VIEWBYID';
      l_lookup := ', ENI_ITEM_V lookupv';
      l_group_by_clause := ' edismv.item_org_id ';
      l_drill_to_cat_url := 'NULL';
      l_lookup_inner_select := ' edismv.item_org_id ';
      l_lookup_where := ' and b.item_org_id = lookupv.id ';
      l_rank_measure := 'item_org_id';

      IF (l_item_org IS NULL AND l_category IS NULL) THEN

        l_from_clause := '  eni_dbi_inv_sum_mv edismv ';
        l_where_clause := ' AND edismv.marker = 3 ';

      ELSIF (l_item_org IS NULL AND l_category IS NOT NULL) THEN

        l_from_clause :=  '  eni_dbi_inv_sum_mv edismv  , eni_denorm_hierarchies edh ';
        l_where_clause := ' AND  edismv.marker = 3 ' ||
                          ' AND edh.parent_id = &' || 'ITEM+ENI_ITEM_VBH_CAT' ||
                          ' AND edismv.product_category_id = edh.child_id ';

      ELSIF (l_item_org IS NOT NULL AND l_category IS NULL) THEN

        l_from_clause :=  '  eni_dbi_inv_sum_mv edismv ';
        l_where_clause := ' AND edismv.marker = 3 ' ||
                          ' AND edismv.item_org_id IN ( &' || 'ITEM+ENI_ITEM ) ';

      ELSIF (l_item_org IS NOT NULL AND l_category IS NOT NULL) THEN
             l_from_clause :=  ' eni_dbi_inv_sum_mv edismv, eni_denorm_hierarchies edh ';
             l_where_clause := ' AND edismv.marker = 3 ' ||
                               ' AND edismv.item_org_id IN ( &' || 'ITEM+ENI_ITEM ) '||
                               ' AND edh.parent_id = &' || 'ITEM+ENI_ITEM_VBH_CAT' ||
                               ' AND edismv.product_category_id = edh.child_id ';
      END IF;

    ELSIF l_view_by = 'ITEM+ENI_ITEM_VBH_CAT' THEN

      --  VIEW BY IS PRODUCT CATEGORY
      l_drill_to_cat_url := 'decode(leaf_node_flag, ''Y'', '||
                            '''pFunctionName=ENI_DBI_IVA_R' || '&' || 'VIEW_BY_NAME=VIEW_BY_ID' ||
                            '&' || 'VIEW_BY=ITEM+ENI_ITEM' || '&' || 'pParamIds=Y'',
                            ''pFunctionName=ENI_DBI_IVA_R'  || '&' || 'VIEW_BY_NAME=VIEW_BY_ID' ||
                            '&' || 'VIEW_BY=ITEM+ENI_ITEM_VBH_CAT' || '&' || 'pParamIds=Y'') ';
      l_lookup_select := 'lookupv.VALUE VIEWBY, lookupv.id VIEWBYID';
      l_lookup := ', eni_item_vbh_nodes_v lookupv';
      l_group_by_clause := ' product_category_id ';

      l_lookup_inner_select := ' edismv.product_category_id ';
      l_lookup_where := ' and b.product_category_id = lookupv.child_id ';
      l_rank_measure := 'product_category_id';

      IF (l_item_org IS NULL AND l_category IS NULL) THEN

        l_from_clause :=  ' eni_dbi_inv_sum_mv edismv , eni_item_vbh_nodes_v lookupv ';
        l_where_clause := ' AND edismv.marker = 2 '||
								                  ' AND edismv.gid = 1 '||
                          ' AND lookupv.top_node_flag = ''Y'' ' ||
                          ' AND product_category_id = lookupv.parent_id ' ||
                          ' AND product_category_id = lookupv.child_id ';
        l_lookup_where :=
                          ' AND lookupv.top_node_flag = ''Y'' ' ||
                          ' AND product_category_id = lookupv.parent_id ' ||
                          ' AND product_category_id = lookupv.child_id ';

      ELSIF (l_item_org IS NULL AND l_category IS NOT NULL) THEN

        l_from_clause :=  ' eni_dbi_inv_sum_mv edismv , eni_item_vbh_nodes_v lookupv ';
	/*Bug 5843937*/
        l_where_clause := ' AND edismv.organization_id IS NOT NULL AND edismv.marker = 2 '||
                          ' AND lookupv.parent_id = &' || 'ITEM+ENI_ITEM_VBH_CAT ' ||
                          ' AND lookupv.id = product_category_id ' ||
                          ' AND lookupv.id = lookupv.child_id '||
                          ' AND lookupv.parent_id <> lookupv.child_id ';
        l_lookup_where :=
                          ' AND lookupv.child_id = product_category_id ' ||
                          ' AND lookupv.parent_id = lookupv.child_id ';

      ELSIF (l_item_org IS NOT NULL AND l_category IS NULL) THEN

        l_from_clause :=  ' eni_dbi_inv_sum_mv edismv, eni_denorm_hierarchies edh ';
        l_where_clause := ' AND edismv.marker = 3 ' ||
                          ' AND edismv.item_org_id IN ( &' || 'ITEM+ENI_ITEM ) ' ||
                          ' AND edh.top_node_flag = ''Y'' ' ||
                          ' AND edismv.product_category_id = edh.child_id ';
        l_lookup_inner_select := ' edh.parent_id product_category_id ';
        l_group_by_clause := ' edh.parent_id ';

      ELSIF (l_item_org IS NOT NULL AND l_category IS NOT NULL) THEN

        l_from_clause:= ' eni_dbi_inv_sum_mv edismv, eni_denorm_hierarchies edh ';
        l_where_clause := ' AND edismv.marker = 3 ' ||
                          ' AND edismv.item_org_id IN ( &' || 'ITEM+ENI_ITEM ) '||
                          ' AND edh.parent_id = &' || 'ITEM+ENI_ITEM_VBH_CAT' ||
                          ' AND edismv.product_category_id = edh.child_id ';
        l_lookup_inner_select := ' edh.imm_child_id product_category_id ';
        l_group_by_clause := 'edh.imm_child_id ';
        l_lookup_where :=
                          ' AND lookupv.child_id = product_category_id ' ||
                          ' AND lookupv.parent_id = lookupv.child_id ';

      END IF;

      l_where_clause := l_where_clause; -- || l_where_clause1;

    ELSIF l_view_by = 'ORGANIZATION+ORGANIZATION' THEN

      --  VIEW BY IS ORGANIZATION
      l_summary := 'odipmv';
      l_lookup_select := 'lookupv.organization_name VIEWBY, lookupv.organization_id VIEWBYID ';
      l_lookup := ', org_organization_definitions lookupv';
      l_group_by_clause := ' odipmv.organization_id ';
      l_drill_to_cat_url := 'NULL';
      l_lookup_inner_select := ' odipmv.organization_id ';
      l_lookup_where := ' and b.organization_id = lookupv.organization_id ';
      l_rank_measure := 'organization_id';

      IF (l_item_org IS NULL AND l_category IS NULL) THEN
        l_from_clause := ' eni_dbi_inv_base_mv odipmv ';
        l_where_clause := NULL;
      ELSIF (l_item_org IS NULL AND l_category IS NOT NULL) THEN
        l_from_clause := ' eni_dbi_inv_base_mv odipmv, eni_denorm_hierarchies edh ';
        l_where_clause := ' AND edh.parent_id = &' || 'ITEM+ENI_ITEM_VBH_CAT' ||
                           ' AND odipmv.item_category_id = edh.child_id ';
      ELSIF (l_item_org IS NOT NULL AND l_category IS NULL) THEN
        l_from_clause := ' eni_dbi_inv_base_mv odipmv ';
        l_where_clause := ' AND odipmv.item_master_org_id IN ( &' || 'ITEM+ENI_ITEM ) ';
      ELSIF (l_item_org IS NOT NULL AND l_category IS NOT NULL) THEN
        l_from_clause := ' eni_dbi_inv_base_mv odipmv , eni_denorm_hierarchies edh ';
        l_where_clause := ' AND odipmv.item_master_org_id IN ( &' || 'ITEM+ENI_ITEM ) '||
                          ' AND edh.parent_id = &' || 'ITEM+ENI_ITEM_VBH_CAT' ||
                          ' AND odipmv.item_category_id = edh.child_id ';
      END IF;
    END IF;

/*
Bug : 3258092
Desc: Values computed for XTD instead of ITD. Values stored in base table are instaneous not summary

Bug: 3123997
Inv Total, InTransit Value and WIP Value mustbe N/A if the item doesn't exist
Issue: NVL(edismv.xxxx,0)
Fix  : edismv.xxxx
       removed the 'else' clause as well
*/

    IF l_view_by = 'ITEM+ENI_ITEM_VBH_CAT' THEN

      IF (UPPER(l_order_by) like '%ENI_MEASURE26%DESC%') THEN
        l_order_by := ' ENI_MEASURE1 DESC';
      ELSIF (UPPER(l_order_by) like '%ENI_MEASURE26%ASC%') THEN
        l_order_by := ' ENI_MEASURE1 ASC';
      END IF;

      -- added LEADING hint to avoid full table access of ftrs
      x_custom_sql :=
      'SELECT /*+ LEADING(ftrs) */
          ' || l_lookup_select || ',
   ENI_MEASURE1,
   ENI_MEASURE2,
   ENI_MEASURE4,
   ENI_MEASURE5,
   ENI_MEASURE7,
   ENI_MEASURE8,
   ENI_MEASURE10,
   ENI_MEASURE11,
   SUM(ENI_MEASURE1) OVER() ENI_MEASURE14,
   SUM(ENI_MEASURE2) OVER() ENI_MEASURE15,
   SUM(ENI_MEASURE4) OVER() ENI_MEASURE17,
   SUM(ENI_MEASURE5) OVER() ENI_MEASURE18,
   SUM(ENI_MEASURE7) OVER() ENI_MEASURE20,
   SUM(ENI_MEASURE8) OVER() ENI_MEASURE21,
   SUM(ENI_MEASURE10) OVER() ENI_MEASURE23,
   SUM(ENI_MEASURE11) OVER() ENI_MEASURE24,
   (RATIO_TO_REPORT(ENI_MEASURE1) OVER())*100 AS ENI_MEASURE26,
   100 AS ENI_MEASURE27,
   ' || l_drill_to_cat_url || ' AS ENI_MEASURE28
  FROM
  (
   SELECT a.*,
   rank() over ( &'||'ORDER_BY_CLAUSE'||' nulls last,' || l_rank_measure ||')-1 as rank_num
   FROM
   (
   SELECT
    ' || l_lookup_inner_select || ',
    SUM
    (
     case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
     THEN
      '|| l_summary || '.inv_total_value_'||l_curr_suffix||'
     END
    ) AS ENI_MEASURE1,
    SUM
    (
     case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
     THEN
      '|| l_summary || '.inv_total_value_'||l_curr_suffix||'
     END
    ) AS ENI_MEASURE2,
    SUM
    (
     case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
     THEN
      '|| l_summary || '.onhand_value_'||l_curr_suffix||'
     END
    ) AS ENI_MEASURE4,
    SUM
    (
     case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
     THEN
      '|| l_summary || '.onhand_value_'||l_curr_suffix||'
     END
    ) AS ENI_MEASURE5,
    SUM
    (
     case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
     THEN
      '|| l_summary || '.intransit_value_'||l_curr_suffix||'
     END
    ) AS ENI_MEASURE7,
    SUM
    (
     case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
     THEN
      '|| l_summary || '.intransit_value_'||l_curr_suffix||'
     END
    ) AS ENI_MEASURE8,
    SUM
    (
     case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
     THEN
      '|| l_summary || '.wip_value_'||l_curr_suffix||'
     END
    ) AS ENI_MEASURE10,
    SUM
    (
     case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
     THEN
      '|| l_summary || '.wip_value_'||l_curr_suffix||'
     END
    ) AS ENI_MEASURE11
   FROM
    ' || l_from_clause || ', fii_time_rpt_struct ftrs
   WHERE
    ftrs.time_id = '|| l_summary || '.time_id
    AND
    (
     ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
     OR ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
    )
    AND BITAND(ftrs.record_type_id,1143) = ftrs.record_type_id
    ' || l_where_clause || '
   GROUP BY
    ' || l_group_by_clause || '
   ) a
  )b ' || l_lookup || '
  where ((b.rank_num between &'||'START_INDEX and &'||'END_INDEX) OR (&'||'END_INDEX = -1)) '||
  l_lookup_where || '
  order by rank_num';




   ELSE  -- windowing provided for Product and Organization viewby. Bug # 3781824

     IF (UPPER(l_order_by) like '%ENI_MEASURE26%DESC%') THEN
       l_order_by := ' ENI_MEASURE1 DESC';
     ELSIF (UPPER(l_order_by) like '%ENI_MEASURE26%ASC%') THEN
       l_order_by := ' ENI_MEASURE1 ASC';
     END IF;

     x_custom_sql :=
      'SELECT
          ' || l_lookup_select || ',
   ENI_MEASURE1,
   ENI_MEASURE2,
   ENI_MEASURE4,
   ENI_MEASURE5,
   ENI_MEASURE7,
   ENI_MEASURE8,
   ENI_MEASURE10,
   ENI_MEASURE11,
   ENI_MEASURE14,
   ENI_MEASURE15,
   ENI_MEASURE17,
   ENI_MEASURE18,
   ENI_MEASURE20,
   ENI_MEASURE21,
   ENI_MEASURE23,
   ENI_MEASURE24,
   ENI_MEASURE26,
   100 AS ENI_MEASURE27,
   ' || l_drill_to_cat_url || ' AS ENI_MEASURE28
  FROM
  (
   SELECT a.*,
   (RATIO_TO_REPORT(ENI_MEASURE1) OVER())*100 AS ENI_MEASURE26,
   rank() over ( &'||'ORDER_BY_CLAUSE'||' nulls last,' || l_rank_measure ||')-1 as rank_num
   FROM
   (
   SELECT
    ' || l_lookup_inner_select || ',
    SUM
    (
     case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
     THEN
      '|| l_summary || '.inv_total_value_'||l_curr_suffix||'
     END
    ) AS ENI_MEASURE1,
    SUM
    (
     case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
     THEN
      '|| l_summary || '.inv_total_value_'||l_curr_suffix||'
     END
    ) AS ENI_MEASURE2,
    SUM
    (
     case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
     THEN
      '|| l_summary || '.onhand_value_'||l_curr_suffix||'
     END
    ) AS ENI_MEASURE4,
    SUM
    (
     case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
     THEN
      '|| l_summary || '.onhand_value_'||l_curr_suffix||'
     END
    ) AS ENI_MEASURE5,
    SUM
    (
     case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
     THEN
      '|| l_summary || '.intransit_value_'||l_curr_suffix||'
     END
    ) AS ENI_MEASURE7,
    SUM
    (
     case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
     THEN
      '|| l_summary || '.intransit_value_'||l_curr_suffix||'
     END
    ) AS ENI_MEASURE8,
    SUM
    (
     case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
     THEN
      '|| l_summary || '.wip_value_'||l_curr_suffix||'
     END
    ) AS ENI_MEASURE10,
    SUM
    (
     case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
     THEN
      '|| l_summary || '.wip_value_'||l_curr_suffix||'
     END
    ) AS ENI_MEASURE11,
    SUM
    (
     SUM
     (
      case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
      THEN
       '|| l_summary || '.inv_total_value_'||l_curr_suffix||'
      END
     )
    ) OVER() AS ENI_MEASURE14,
    SUM
    (
     SUM
     (
      case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
      THEN
       '|| l_summary || '.inv_total_value_'||l_curr_suffix||'
      END
     )
    ) OVER() AS ENI_MEASURE15,
    SUM
    (
     SUM
     (
      case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
      THEN
       '|| l_summary || '.onhand_value_'||l_curr_suffix||'
      END
     )
    ) OVER() AS ENI_MEASURE17,
    SUM
    (
     SUM
     (
      case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
      THEN
       '|| l_summary || '.onhand_value_'||l_curr_suffix||'
      END
     )
    ) OVER() AS ENI_MEASURE18,
    SUM
    (
     SUM
     (
      case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
      THEN
       '|| l_summary || '.intransit_value_'||l_curr_suffix||'
      END
     )
    ) OVER() AS ENI_MEASURE20,
    SUM
    (
     SUM
     (
      case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
      THEN
       '|| l_summary || '.intransit_value_'||l_curr_suffix||'
      END
     )
    ) OVER() AS ENI_MEASURE21,
    SUM
    (
     SUM
     (
      case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
      THEN
       '|| l_summary || '.wip_value_'||l_curr_suffix||'
      END
     )
    ) OVER() AS ENI_MEASURE23,
    SUM
    (
     SUM
     (
      case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
      THEN
       '|| l_summary || '.wip_value_'||l_curr_suffix||'
      END
     )
    ) OVER() AS ENI_MEASURE24
   FROM
    ' || l_from_clause || ', fii_time_rpt_struct ftrs
   WHERE
    ftrs.time_id = '|| l_summary || '.time_id
    AND
    (
     ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
     OR ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
    )
    AND BITAND(ftrs.record_type_id,1143) = ftrs.record_type_id
    ' || l_where_clause || '
   GROUP BY
    ' || l_group_by_clause || '
   ) a
  )b ' || l_lookup || '
  where ((b.rank_num between &'||'START_INDEX and &'||'END_INDEX) OR (&'||'END_INDEX = -1)) '||
  l_lookup_where || '
  order by rank_num';

    END IF;

EXCEPTION

            WHEN OTHERS THEN
               NULL;

END get_sql;

END eni_dbi_iva_pkg;

/
