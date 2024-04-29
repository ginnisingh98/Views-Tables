--------------------------------------------------------
--  DDL for Package Body ENI_DBI_PRC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_PRC_PKG" AS
/*$Header: ENIPRCPB.pls 120.0 2005/05/26 19:34:46 appldev noship $*/

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
  l_category1 VARCHAR2(100);
  l_item VARCHAR2(5000);
  l_org VARCHAR2(5000);
--  l_item_org VARCHAR2(5000); -- eletuchy 11-17-04: made unnecessary by ITEM+ENI_ITEM BIS bind
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
  l_where_clause1 VARCHAR2(1000) := NULL;
  l_group_by_clause VARCHAR2(500);

  l_err_msg VARCHAR2(100);

  l_table VARCHAR2(100);

  -- The record structure for bind variable values
  l_custom_rec BIS_QUERY_ATTRIBUTES;

  l_lookup VARCHAR2(100);
  l_lookup_table VARCHAR2(100);
  l_summary VARCHAR2(100);
  l_oex_columns VARCHAR2(500);
  l_oex_total_columns VARCHAR2(500);
  l_drill_to_cat_url VARCHAR2(500);
  l_drill_to_other_expenses VARCHAR2(500);
  top_flag VARCHAR2(1);
  leaf_flag VARCHAR2(1);
  l_where_clause_outer VARCHAR2(1000);
  l_revenue VARCHAR2(100);
  l_cogs       VARCHAR2(100);
  l_expense VARCHAR2(100);
  l_currency_value VARCHAR2(100);

  BEGIN


   l_revenue := 'rev_amount';
   l_cogs  := 'cogs_amount';
   l_expense := 'exp_amount';

/* eletuchy 11-17-04: made unnecessary by ITEM+ENI_ITEM BIS bind
    FOR i in 1..p_page_parameter_tbl.COUNT LOOP
        IF ( (p_page_parameter_tbl(i).parameter_name = 'ITEM+ENI_ITEM')
             OR ( p_page_parameter_tbl(i).parameter_name = 'ITEM+ENI_ITEM_ORG') ) THEN
            l_item_org := p_page_parameter_tbl(i).parameter_id;
            EXIT;
        END IF;
    END LOOP;
*/

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

    l_category1 := TRIM(both '''' from l_category);

    l_currency_value :=  eni_dbi_util_pkg.get_curr_sec;

    IF (l_category1 IS NOT NULL) THEN
      select top_node_flag,leaf_node_flag
      into top_flag,leaf_flag
      from eni_denorm_hierarchies edh
      where edh.parent_id = l_category1
      and edh.child_id = edh.parent_id;

        IF (top_flag = 'Y' and leaf_flag = 'Y') THEN
            l_where_clause1 := '';
        ELSE
            l_where_clause1 := ' AND vbh.parent_id <> vbh.child_id ';
        END IF;
    END IF;

    IF (l_currency = l_currency_value) THEN
       l_revenue := 'rev_sec_amount';
       l_cogs  := 'cogs_sec_amount';
       l_expense := 'exp_sec_amount';
    END IF;

    l_oex_columns := ' , NULL AS ENI_MEASURE13, NULL AS ENI_MEASURE14 ';
    l_oex_total_columns := ' , NULL AS ENI_MEASURE33, NULL AS ENI_MEASURE34 ';
    l_drill_to_other_expenses := 'decode(ENI_MEASURE13, NULL, NULL, 0,  NULL,''pFunctionName=ENI_DBI_OEX_R'  ||
                              '&' || 'VIEW_BY_NAME=VIEW_BY_ID' ||
                              '&' || 'VIEW_BY=LOB+FII_LOB' || '&' || 'pParamIds=Y'') ';

    IF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') THEN
      -- VIEW BY PRODUCT CATEGORY
      l_lookup := 'vbh.value AS VIEWBY, vbh.id AS VIEWBYID, vbh.leaf_node_flag AS leaf_node_flag';
      l_lookup_table := ', eni_item_vbh_nodes_v vbh';
      l_drill_to_cat_url := 'decode(leaf_node_flag, ''Y'', ' ||
                            '''pFunctionName=ENI_DBI_PRC_R' || '&' || 'VIEW_BY_NAME=VIEW_BY_ID' ||
                            '&' || 'VIEW_BY=ITEM+ENI_ITEM' || '&' || 'pParamIds=Y'',
                            ''pFunctionName=ENI_DBI_PRC_R'  || '&' || 'VIEW_BY_NAME=VIEW_BY_ID' ||
                            '&' || 'VIEW_BY=ITEM+ENI_ITEM_VBH_CAT' || '&' || 'pParamIds=Y'') ';
      l_group_by_clause := 'vbh.id, vbh.value,vbh.leaf_node_flag';

      IF (l_item IS NULL AND l_category IS NULL) THEN

        l_summary := 'edps2mv';
        l_from_clause := 'eni_dbi_prc_sum2_mv edps2mv ';
        l_where_clause := ' AND edps2mv.marker = 2 ' ||
                          ' AND vbh.top_node_flag = ''Y'' ' ||
                          ' AND vbh.parent_id = vbh.child_id ' ||
                          ' AND edps2mv.product_category_id = vbh.child_id ';
        l_oex_columns := '
            , SUM( case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
            then NVL(edps2mv.' || l_expense || ',0) else 0 end ) AS ENI_MEASURE13
            , SUM(case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
            then edps2mv.' || l_expense || ' else 0 end ) AS ENI_MEASURE14 ';
        l_oex_total_columns := '
            ,SUM(SUM(case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
            then NVL(edps2mv.' || l_expense || ',0) else 0 end )) OVER() AS ENI_MEASURE33
            ,SUM(SUM(case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
             then edps2mv.' || l_expense || ' else 0 end )) OVER() AS ENI_MEASURE34';

      ELSIF (l_item IS NULL AND l_category IS NOT NULL) THEN

        l_summary := 'edps2mv';

        l_from_clause := 'eni_dbi_prc_sum2_mv edps2mv ';
        l_where_clause := ' AND edps2mv.marker = 2 ' ||
                          ' AND vbh.parent_id = :PRODUCT_CATEGORY ' ||
                          ' AND vbh.id = edps2mv.product_category_id ' ||
                          ' AND vbh.id = vbh.child_id ';

        l_oex_columns := '
            , SUM( case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
            then NVL(edps2mv.' || l_expense || ',0) else 0 end ) AS ENI_MEASURE13
            , SUM(case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
            then edps2mv.' || l_expense || ' else 0 end ) AS ENI_MEASURE14 ';
        l_oex_total_columns := '
            ,SUM(SUM(case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
            then NVL(edps2mv.' || l_expense || ',0) else 0 end )) OVER() AS ENI_MEASURE33
            ,SUM(SUM(case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
             then edps2mv.' || l_expense || ' else 0 end )) OVER() AS ENI_MEASURE34';
        l_where_clause := l_where_clause || l_where_clause1;

      ELSIF (l_item IS NOT NULL AND l_category IS NULL) THEN

        l_summary := 'edps1mv';
        l_from_clause :=  ' eni_dbi_prc_sum1_mv edps1mv , eni_denorm_hierarchies edh';
        l_where_clause := ' AND edps1mv.item_org_id IN ('|| '&' || 'ITEM+ENI_ITEM)' ||
                          ' AND edh.top_node_flag = ''Y'' ' ||
                          ' AND edps1mv.product_category_id = edh.child_id ' ||
                          ' AND vbh.id = edh.imm_child_id ' ||
                          ' AND vbh.parent_id = vbh.child_id ' ||
                          ' AND vbh.child_id = vbh.id ';

      ELSIF (l_item IS NOT NULL AND l_category IS NOT NULL) THEN

        l_summary := 'edps1mv';
        l_from_clause :=  ' eni_dbi_prc_sum1_mv edps1mv ';
        l_where_clause := ' AND edps1mv.item_org_id IN IN ('|| '&' || 'ITEM+ENI_ITEM)' ||
                          ' AND vbh.parent_id = :PRODUCT_CATEGORY '||
                          ' AND edps1mv.product_category_id = vbh.child_id ';

      END IF;

      -- modifications by achampan for bug X
      x_custom_sql := '
   SELECT vbh.value AS VIEWBY, vbh.id AS VIEWBYID
        , ' || l_drill_to_cat_url || ' AS ENI_ATTRIBUTE4
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
        ,  ((ENI_MEASURE1 - ENI_MEASURE7)
           /decode(ENI_MEASURE1, 0, null, ENI_MEASURE1))*100
           AS  ENI_MEASURE10  -- current gross margin
        , ENI_MEASURE13 -- current other expenses
        , ENI_MEASURE14 -- prior other expenses
        , ((ENI_MEASURE1 - ENI_MEASURE7 - ENI_MEASURE13)
           /decode(ENI_MEASURE1, 0, null, ENI_MEASURE1))*100
           AS ENI_MEASURE16  -- current product margin
        , ENI_MEASURE21 -- current revenue grand total
        , ENI_MEASURE22 -- prior revenue grand total
        , ENI_MEASURE27 -- current cogs grand total
        , ENI_MEASURE28 -- prior cogs grand total
        , ((ENI_MEASURE21 - ENI_MEASURE27)
           /decode(ENI_MEASURE21, 0, null, ENI_MEASURE21))*100
           AS ENI_MEASURE30  -- gross margin grand total
        , (
            (ENI_MEASURE21-ENI_MEASURE27)
            /decode(ENI_MEASURE21, 0, null, ENI_MEASURE21)
          )
          -
          (
            (ENI_MEASURE22-ENI_MEASURE28)
            /decode(ENI_MEASURE22, 0, null, ENI_MEASURE22)
          )
          AS ENI_MEASURE32  -- gross margin change
        , ENI_MEASURE33 -- current other expenses grand total
        , ENI_MEASURE34 -- prior other expenses grand total
        , ((ENI_MEASURE21 - ENI_MEASURE27 - ENI_MEASURE33) /decode(ENI_MEASURE21, 0, null, ENI_MEASURE21))*100 AS ENI_MEASURE36  -- product margin grand total
        , (
            (
              (ENI_MEASURE21-ENI_MEASURE27-ENI_MEASURE33)
              /decode(ENI_MEASURE21, 0, null, ENI_MEASURE21)
              -
              (
                (ENI_MEASURE22-ENI_MEASURE28-ENI_MEASURE34)
                /decode(ENI_MEASURE22, 0, null, ENI_MEASURE22)
              )
            )
          )
          AS ENI_MEASURE38  -- product margin change
        , ' || l_drill_to_other_expenses || ' -- drill across url for other expenses
          AS ENI_MEASURE43
        , NVL(ENI_MEASURE7,0)+NVL(ENI_MEASURE13,0)
          AS ENI_MEASURE47  -- for Costs(COGS+Expenses) on graph 1
        , ((ENI_MEASURE22 - ENI_MEASURE28 - ENI_MEASURE34) /decode(ENI_MEASURE22, 0, null, ENI_MEASURE22))*100 AS ENI_MEASURE20  -- Prior product margin grand total

   FROM
   (
     SELECT t.*, (rank() over( &'||'ORDER_BY_CLAUSE'||' nulls last, id) - 1) col_rank
     FROM
     (
       SELECT
         vbh.id,
       SUM
       (
         case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
         then
           NVL(' || l_summary || '.' || l_revenue || ',0)
         else
           0
         end
       ) AS ENI_MEASURE1
     , SUM
       (
         case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
         then
          ' || l_summary || '.' || l_revenue || '
         else
          0
         end
       ) AS ENI_MEASURE2
     , SUM
       (
         case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
         then
          NVL(' || l_summary || '.' || l_cogs || ',0)
         else
          0
         end
       ) AS ENI_MEASURE7
     , SUM
       (
         case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
         then
          ' || l_summary || '.' || l_cogs || '
         else
          0
         end
       ) AS ENI_MEASURE8
       '||l_oex_columns||'
     ,SUM
            (
                case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
                then
                   NVL(((' || l_summary || '.rev_amount - ' || l_summary || '.cogs_amount)
                  /decode(' || l_summary || '.rev_amount, 0, null, ' || l_summary || '.rev_amount))*100,0)
                else
                    0
                end
            )
    AS ENI_MEASURE10
    , SUM
       (
         case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
         then
                        NVL(((' || l_summary || '.' || l_revenue || ' - ' || l_summary || '.' || l_cogs || '
                        - ' || l_summary || '.' || l_expense || ')
                       /decode(' || l_summary || '.' || l_revenue || ', 0, null, ' || l_summary || '.' || l_revenue || '))*100,0)
         else
          0
         end
       )
       AS ENI_MEASURE16
     , SUM
       (
         SUM
         (
           case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
           then
               NVL(' || l_summary || '.' || l_revenue || ',0)
           else
               0
           end
         )
       ) OVER()
       AS ENI_MEASURE21
     , SUM
       (
         SUM
         (
           case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
           then
                ' || l_summary || '.' || l_revenue || '
           else
                0
           end
         )
       ) OVER()
       AS ENI_MEASURE22
     , SUM
       (
         SUM
         (
           case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
           then
             NVL(' || l_summary || '.' || l_cogs || ',0)
           else
             0
           end
         )
       ) OVER()
       AS ENI_MEASURE27
     , SUM
       (
         SUM
         (
           case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
           then
             NVL(' || l_summary || '.' || l_cogs || ',0)
           else
             0
           end
         )
       ) OVER()
       AS ENI_MEASURE28
       '||l_oex_total_columns||'
     FROM
       ' || l_from_clause || '
       , fii_time_rpt_struct ftrs
       ' || l_lookup_table ||'
     WHERE
       ' || l_summary || '.time_id = ftrs.time_id
       AND
       (
        ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
        OR ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
       )
       AND BITAND(ftrs.record_type_id, &' || 'BIS_NESTED_PATTERN) = ftrs.record_type_id
       ' || l_where_clause || '
     GROUP BY
       ' || l_group_by_clause || '
    )t
    where
    NOT( (ENI_MEASURE1 = 0) AND (NVL(ENI_MEASURE2,0) = 0) AND
         (ENI_MEASURE7 = 0) AND (NVL(ENI_MEASURE8,0) = 0) AND
         (NVL(ENI_MEASURE13,0) = 0) AND (NVL(ENI_MEASURE14,0) = 0))
    ) a '||l_lookup_table||'
    where ((a.col_rank between &'||'START_INDEX and &'||'END_INDEX) OR (&'||'END_INDEX = -1)) '||
    l_where_clause_outer || ' and a.id = vbh.id and vbh.parent_id = vbh.child_id order by a.col_rank' ;

    ELSIF (l_view_by = 'ITEM+ENI_ITEM') THEN

      -- view by item
      l_lookup := 'eiv.value AS VIEWBY, eiv.id AS VIEWBYID';
      l_lookup_table := ', eni_item_v eiv';
      l_summary := 'edps1mv';
      l_group_by_clause := ' item_org_id ';
      l_drill_to_cat_url := 'NULL';
      l_where_clause_outer :='';
      l_where_clause_outer := ' AND eiv.id = a.item_org_id ';
      IF (l_item IS NULL AND l_category IS NULL) THEN
           l_from_clause :=  ' eni_dbi_prc_sum1_mv edps1mv ';
           l_where_clause :='';
      ELSIF (l_item IS NULL AND l_category IS NOT NULL) THEN
           l_from_clause :=  ' eni_dbi_prc_sum1_mv edps1mv, eni_denorm_hierarchies edh ';
           l_where_clause := ' AND edh.parent_id = :PRODUCT_CATEGORY ' ||
                             ' AND edps1mv.product_category_id = edh.child_id ';-- ||
                             --' AND edps1mv.inventory_item_id = eiv.inventory_item_id ' ||
                             --' AND edps1mv.organization_id = eiv.organization_id ';
      ELSIF (l_item IS NOT NULL AND l_category IS NULL) THEN
           l_from_clause :=  ' eni_dbi_prc_sum1_mv edps1mv ';
           l_where_clause := ' AND edps1mv.item_org_id IN ('|| '&' || 'ITEM+ENI_ITEM)' ;--||
                             --' AND edps1mv.item_org_id = eiv.id ';
           l_where_clause_outer := ' AND eiv.id = a.item_org_id ';
      ELSIF (l_item IS NOT NULL AND l_category IS NOT NULL) THEN
           l_from_clause :=  ' eni_dbi_prc_sum1_mv edps1mv, eni_denorm_hierarchies edh ';
           l_where_clause := ' AND edh.parent_id = :PRODUCT_CATEGORY ' ||
                             ' AND edps1mv.product_category_id = edh.child_id ' ||
                             ' AND edps1mv.item_org_id IN ('|| '&' || 'ITEM+ENI_ITEM) '; -- ||
                            -- ' AND edps1mv.item_org_id IN (' || l_item_org || ')'; -- ||
                             --' AND edps1mv.item_org_id = eiv.id ';
      END IF;

      -- achampan: added rank - 1 to fix windowing of item viewby
      x_custom_sql := '
   SELECT eiv.value as VIEWBY
        , eiv.id as VIEWBYID
        , ' || l_drill_to_cat_url || ' AS ENI_ATTRIBUTE4
        , ENI_MEASURE1
        , ENI_MEASURE2
        , ENI_MEASURE7
        , ENI_MEASURE8
        , ((ENI_MEASURE2 - ENI_MEASURE8)
           /decode(ENI_MEASURE2, 0, null, ENI_MEASURE2))*100
           AS ENI_MEASURE11
        , ((ENI_MEASURE2 - ENI_MEASURE8 - ENI_MEASURE14)
           /decode(ENI_MEASURE2, 0, null, ENI_MEASURE2))*100
           AS ENI_MEASURE17
        ,  ((ENI_MEASURE1 - ENI_MEASURE7)
           /decode(ENI_MEASURE1, 0, null, ENI_MEASURE1))*100
           AS  ENI_MEASURE10
        , ENI_MEASURE13
        , ENI_MEASURE14
        ,((ENI_MEASURE1 - ENI_MEASURE7 - ENI_MEASURE13)
           /decode(ENI_MEASURE1, 0, null, ENI_MEASURE1))*100
           AS   ENI_MEASURE16
        , ENI_MEASURE21
        , ENI_MEASURE22
        , ENI_MEASURE27
        , ENI_MEASURE28
        , ((ENI_MEASURE21 - ENI_MEASURE27)
           /decode(ENI_MEASURE21, 0, null, ENI_MEASURE21))*100
           AS ENI_MEASURE30
        , (
            (ENI_MEASURE21-ENI_MEASURE27)
            /decode(ENI_MEASURE21, 0, null, ENI_MEASURE21)
          )
          -
          (
            (ENI_MEASURE22-ENI_MEASURE28)
            /decode(ENI_MEASURE22, 0, null, ENI_MEASURE22)
          )
          AS ENI_MEASURE32
        , ENI_MEASURE33
        , ENI_MEASURE34
        , ((ENI_MEASURE21 - ENI_MEASURE27 - ENI_MEASURE33) /decode(ENI_MEASURE21, 0, null, ENI_MEASURE21))*100 AS ENI_MEASURE36
        , (
            (
              (ENI_MEASURE21-ENI_MEASURE27-ENI_MEASURE33)
              /decode(ENI_MEASURE21, 0, null, ENI_MEASURE21)
              -
              (
                (ENI_MEASURE22-ENI_MEASURE28-ENI_MEASURE34)
                /decode(ENI_MEASURE22, 0, null, ENI_MEASURE22)
              )
            )
          )
          AS ENI_MEASURE38
        , ' || l_drill_to_other_expenses || '
          AS ENI_MEASURE43
        , NVL(ENI_MEASURE7,0)+NVL(ENI_MEASURE13,0)
          AS ENI_MEASURE47
        , ((ENI_MEASURE22 - ENI_MEASURE28 - ENI_MEASURE34) /decode(ENI_MEASURE22, 0, null, ENI_MEASURE22))*100 AS ENI_MEASURE20  -- Prior product margin grand total
   FROM
   (
     SELECT t.*, (rank() over( &'||'ORDER_BY_CLAUSE'||' nulls last, item_org_id) - 1) col_rank
     FROM
     (
       SELECT
         item_org_id,
         SUM
         (
             case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
             then
                 NVL(' || l_summary || '.' || l_revenue || ',0)
             else
                 0
             end
         )
         AS ENI_MEASURE1
       , SUM
         (
             case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
             then
                 ' || l_summary || '.' || l_revenue || '
             else
                 0
             end
         )
         AS ENI_MEASURE2
       , SUM
         (
             case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
             then
                 NVL(' || l_summary || '.' || l_cogs || ',0)
             else
                 0
             end
         )
         AS ENI_MEASURE7
       , SUM
         (
             case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
             then
                 ' || l_summary || '.' || l_cogs || '
             else
                 0
             end
         )
         AS ENI_MEASURE8
         '||l_oex_columns||'
       , SUM
         (
             case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
             then
                 NVL(((' || l_summary || '.rev_amount - ' || l_summary || '.cogs_amount)
                /decode(' || l_summary || '.rev_amount, 0, null, ' || l_summary || '.rev_amount))*100,0)
             else
                 0
             end
         )
         AS ENI_MEASURE10
       , SUM
         (
             case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
             then
                 NVL(((' || l_summary || '.' || l_revenue || ' - ' || l_summary || '.' || l_cogs || '
                 - ' || l_summary || '.' || l_expense || ')
                /decode(' || l_summary || '.' || l_revenue || ', 0, null, ' || l_summary || '.' || l_revenue || '))*100,0)
             else
                 0
             end
         )
         AS ENI_MEASURE16
       , SUM
         (
           SUM
           (
               case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
               then
                   NVL(' || l_summary || '.' || l_revenue || ',0)
               else
                   0
               end
           )
         ) OVER() AS ENI_MEASURE21
       , SUM
         (
           SUM
           (
              case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
              then
                   ' || l_summary || '.' || l_revenue || '
              else
                   0
              end
           )
         ) OVER() AS ENI_MEASURE22
       , SUM
         (
           SUM
           (
               case when ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
               then
                    NVL(' || l_summary || '.' || l_cogs || ',0)
               else
                    0
               end
           )
         ) OVER() AS ENI_MEASURE27
       , SUM
         (
           SUM
           (
               case when ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
               then
                    NVL(' || l_summary || '.' || l_cogs || ',0)
               else
                    0
               end
           )
         ) OVER() AS ENI_MEASURE28
         '||l_oex_total_columns||'
       FROM
         ' || l_from_clause || '
         , fii_time_rpt_struct ftrs
       WHERE
         ' || l_summary || '.time_id = ftrs.time_id
         AND
         (
          ftrs.report_date = '||'&'||'BIS_CURRENT_ASOF_DATE
          OR ftrs.report_date = '||'&'||'BIS_PREVIOUS_ASOF_DATE
         )
         AND BITAND(ftrs.record_type_id, &' || 'BIS_NESTED_PATTERN) = ftrs.record_type_id
         ' || l_where_clause || '
       GROUP BY
         ' || l_group_by_clause || '
     )t
     where
       NOT( (ENI_MEASURE1 = 0) AND (NVL(ENI_MEASURE2,0) = 0) AND
            (ENI_MEASURE7 = 0) AND (NVL(ENI_MEASURE8,0) = 0) AND
            (NVL(ENI_MEASURE13,0) = 0) AND (NVL(ENI_MEASURE14,0) = 0))
   ) a '||l_lookup_table||'
   where ((a.col_rank between &'||'START_INDEX and &'||'END_INDEX) OR (&'||'END_INDEX = -1)) '||
         l_where_clause_outer || 'order by a.col_rank' ;

      -- Added 'order by a.col_rank' to fix bug # 3760722

    END IF;

    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    IF (l_category1 is not null ) THEN
        x_custom_output.extend;

        l_custom_rec.attribute_name := ':PRODUCT_CATEGORY';
        l_custom_rec.attribute_value := l_category1;
        l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
        l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND;
        x_custom_output.extend;
        x_custom_output(1) := l_custom_rec;
    END IF;

END get_sql;

END eni_dbi_prc_pkg;

/
