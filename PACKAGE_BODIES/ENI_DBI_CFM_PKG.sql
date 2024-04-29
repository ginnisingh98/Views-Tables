--------------------------------------------------------
--  DDL for Package Body ENI_DBI_CFM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_CFM_PKG" AS
/* $Header: ENICFMPB.pls 120.0 2005/05/26 19:35:02 appldev noship $ */

PROCEDURE Get_Sql ( p_param  IN  BIS_PMV_PAGE_PARAMETER_TBL
                  , x_custom_sql OUT NOCOPY VARCHAR2
                  , x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL ) IS

    l_stmt                  VARCHAR2(10000);
    l_measures              VARCHAR2(10000);
    l_select_stmt           VARCHAR2(10000);
    l_union_select_stmt     VARCHAR2(10000);
    l_union_group_by_stmt   VARCHAR2(10000);
    l_inner_select_stmt     VARCHAR2(10000);
    l_where_stmt            VARCHAR2(10000);
    l_mv1                   VARCHAR2(100);
    l_mv2                   VARCHAR2(100);
    l_flags_where           VARCHAR2(1000);
    l_inv_org               VARCHAR2(10000);
    l_inv_org_where         VARCHAR2(10000);
    l_prod                  VARCHAR2(10000);
    l_prod_where            VARCHAR2(10000);
    l_prod_cat              VARCHAR2(10000);
    l_prod_cat_from         VARCHAR2(10000);
    l_prod_cat_where        VARCHAR2(10000);
    l_cust                  VARCHAR2(10000);
    l_cust_where            VARCHAR2(10000);
    l_curr                  VARCHAR2(10000);
    l_curr_suffix           VARCHAR2(10);
    l_view_by               VARCHAR2(120);
    l_lang                  VARCHAR2(10);
    l_item_cat_flag         NUMBER;
    l_cust_flag             NUMBER;
    l_view_by_flag          NUMBER;

    l_open_url1             VARCHAR2(1000);
    l_open_url2             VARCHAR2(1000);

    l_all_prods             BOOLEAN;
    l_all_prod_cats         BOOLEAN;
    l_all_custs             BOOLEAN;

    l_vb_prod_cat           BOOLEAN;
    l_vb_prod               BOOLEAN;
    l_vb_org                BOOLEAN;
    l_vb_cust               BOOLEAN;

    l_custom_rec            BIS_QUERY_ATTRIBUTES;

BEGIN

    l_lang := userenv('LANG');

    FOR i IN 1..p_param.COUNT LOOP
        CASE p_param(i).parameter_name
            WHEN 'VIEW_BY'                          THEN l_view_by    := p_param(i).parameter_value;
            WHEN 'ITEM+ENI_ITEM_VBH_CAT'            THEN l_prod_cat   := p_param(i).parameter_value;
            WHEN 'ITEM+ENI_ITEM'                    THEN l_prod       := p_param(i).parameter_value;
            WHEN 'CUSTOMER+FII_CUSTOMERS'           THEN l_cust       := p_param(i).parameter_value;
            WHEN 'CURRENCY+FII_CURRENCIES'          THEN
                l_curr_suffix :=
                    CASE p_param(i).parameter_id
                        WHEN eni_dbi_util_pkg.get_curr_prim THEN 'g'    -- primary global currency
                        WHEN eni_dbi_util_pkg.get_curr_sec  THEN 'g1'   -- secondary global currency
                        ELSE 'f'                                        -- functional currency
                    END;
            ELSE null;
        END CASE;
    END LOOP;

    l_all_prods     := (l_prod        IS NULL OR l_prod       = '' OR l_prod       = 'All');
    l_all_prod_cats := (l_prod_cat    IS NULL OR l_prod_cat   = '' OR l_prod_cat   = 'All');
    l_all_custs     := (l_cust        IS NULL OR l_cust       = '' OR l_cust       = 'All');

    l_vb_prod_cat   := (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT' );
    l_vb_prod       := (l_view_by = 'ITEM+ENI_ITEM' );
    l_vb_cust       := (l_view_by = 'CUSTOMER+FII_CUSTOMERS' );
    l_vb_org        := (l_view_by = 'ORGANIZATION+ORGANIZATION');

    l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

    l_measures := '
            , ENI_MEASURE1, ENI_MEASURE2, ENI_MEASURE3, ENI_MEASURE4, ENI_MEASURE5
            , ENI_MEASURE6, ENI_MEASURE7, ENI_MEASURE8, ENI_MEASURE9, ENI_MEASURE10
            , ENI_MEASURE11, ENI_MEASURE12, ENI_MEASURE13, ENI_MEASURE14
            , ENI_MEASURE15, ENI_MEASURE16, ENI_MEASURE17, ENI_MEASURE18
            , ENI_MEASURE19, ENI_MEASURE20, ENI_MEASURE21, ENI_MEASURE22
            , ENI_MEASURE24, ENI_MEASURE25 ';
    l_open_url1 :=
    '''pFunctionName=ENI_DBI_CFM_R&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM&pParamIds=Y''';
    l_open_url2 :=
    '''pFunctionName=ENI_DBI_CFM_R&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&pParamIds=Y''';


/* This portion of the code sets up spaghetti pieces for particular viewbys */
CASE
    WHEN l_vb_prod THEN                         -- +====================== PRODUCT =========================+
        l_select_stmt := '
      SELECT  items.value       VIEWBY
            , NULL              ENI_ATTRIBUTE3 -- drill across url
            , items.description ENI_ATTRIBUTE4 -- item description
            -- , mtl.unit_of_measure ENI_ATTRIBUTE_5 -- item uom'
            || l_measures ||'
      FROM
        ( SELECT ( rank() over (&ORDER_BY_CLAUSE nulls last, item_id) ) - 1 rnk
                 , item_id'
                 || l_measures ||'
          FROM
          ( SELECT c.item_id ';

        l_inner_select_stmt := ' SELECT fact.master_item_id ITEM_ID';
        l_union_select_stmt := ' SELECT item_id  ITEM_ID';
        l_union_group_by_stmt := ' GROUP BY item_id';

        l_where_stmt := '
              , ENI_ITEM_V   items
          WHERE a.item_id = items.id
            AND ( (a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1) )
          &ORDER_BY_CLAUSE NULLS LAST';

    WHEN l_vb_org THEN                          -- +=================== ORGANIZATION =======================+
        l_select_stmt := '
SELECT  org.name          VIEWBY
      , NULL              ENI_ATTRIBUTE3 -- drill across url
      , NULL              ENI_ATTRIBUTE4 -- item description
      -- ,  NULL  ISC_ATTRIBUTE_5 -- item uom'
      || l_measures ||'
FROM
  ( SELECT ( rank() over (&ORDER_BY_CLAUSE nulls last, inv_org_id) ) - 1 rnk
           , inv_org_id'
           || l_measures ||'
    FROM
    ( SELECT c.inv_org_id ';

        l_inner_select_stmt := ' SELECT fact.inv_org_id    INV_ORG_ID';
        l_union_select_stmt := ' SELECT inv_org_id      INV_ORG_ID';
        l_union_group_by_stmt := ' GROUP BY inv_org_id';

        l_where_stmt := '
              , HR_ALL_ORGANIZATION_UNITS_TL org
          WHERE a.inv_org_id = org.organization_id
            AND org.language = :ENI_LANG
            AND ( (a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1) )
          &ORDER_BY_CLAUSE NULLS LAST';

    WHEN l_vb_cust THEN                         -- +===================== CUSTOMER =========================+
        l_select_stmt := '
SELECT  cust.value        VIEWBY
      , NULL              ENI_ATTRIBUTE3 -- drill across url
      , NULL              ENI_ATTRIBUTE4 -- item description
      -- ,  NULL  ISC_ATTRIBUTE_5 -- item uom'
      || l_measures ||'
FROM
  ( SELECT ( rank() over (&ORDER_BY_CLAUSE nulls last, customer_id) ) - 1 rnk
           , customer_id'
           || l_measures ||'
    FROM
    ( SELECT c.customer_id ';

        l_inner_select_stmt := ' SELECT fact.customer_id CUSTOMER_ID';
        l_union_select_stmt := ' SELECT customer_id  CUSTOMER_ID';
        l_union_group_by_stmt := ' GROUP BY customer_id';
        l_where_stmt := '
              , FII_CUSTOMERS_V cust
          WHERE a.customer_id = cust.id
            AND ( (a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1) )
          &ORDER_BY_CLAUSE NULLS LAST';

    WHEN l_vb_prod_cat THEN                     -- +================== PRODUCT CAT =========================+
        l_select_stmt := '
SELECT  eni_vbh.value     VIEWBY
      , eni_vbh.id        VIEWBYID
      , decode( eni_vbh.leaf_node_flag, ''Y''
              , '|| l_open_url1 ||'
              , '|| l_open_url2 ||' )  ENI_ATTRIBUTE3 -- drill across url
      , NULL              ENI_ATTRIBUTE4 -- item description
      -- ,  NULL  ISC_ATTRIBUTE_5 -- item uom'
      || l_measures ||'
FROM
    ( SELECT ( rank() over (&ORDER_BY_CLAUSE nulls last, item_category_id) ) - 1 rnk
         , item_category_id'
         || l_measures ||'
      FROM
      ( SELECT c.item_category_id ';

        IF l_all_prod_cats THEN
            l_inner_select_stmt := ' SELECT eni_cat.parent_id  ITEM_CATEGORY_ID ';
        ELSE
            l_inner_select_stmt := ' SELECT eni_cat.imm_child_id ITEM_CATEGORY_ID ';
        END IF;

        l_union_select_stmt := ' SELECT item_category_id ITEM_CATEGORY_ID ';
        l_union_group_by_stmt := ' GROUP BY item_category_id';
        l_where_stmt := '
              , ENI_ITEM_VBH_NODES_V    eni_vbh
          WHERE a.item_category_id  = eni_vbh.id
            AND eni_vbh.parent_id   = eni_vbh.child_id
            AND ( (a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1) )
          &ORDER_BY_CLAUSE NULLS LAST';

END CASE;

    IF(     l_all_prods
        AND l_all_custs
        AND ( l_vb_org OR l_vb_prod_cat ) )
    THEN
        l_mv1 := 'ISC_DBI_CFM_009_MV';
        l_mv2 := 'ISC_DBI_CFM_011_MV';
        l_flags_where := '';

        IF l_vb_prod_cat THEN
            l_inner_select_stmt := ' SELECT fact.parent_id   ITEM_CATEGORY_ID ';
            IF l_all_prod_cats THEN
                l_prod_cat_from := '';
                l_prod_cat_where := '
        AND fact.top_node_flag      = ''Y''
        AND fact.inv_org_flag       = 1 ';
            ELSE
                l_prod_cat_from := '
    , ENI_DENORM_HIERARCHIES    eni_cat
    , MTL_DEFAULT_CATEGORY_SETS mdcs';
                l_prod_cat_where := '
        AND fact.inv_org_flag       = 1
        AND fact.parent_id          = eni_cat.child_id
        AND eni_cat.dbi_flag        = ''Y''
        AND eni_cat.object_type     = ''CATEGORY_SET''
        AND eni_cat.object_id       = mdcs.category_set_id
        AND mdcs.functional_area_id = 11
        AND eni_cat.parent_id   IN (&ITEM+ENI_ITEM_VBH_CAT)
        AND (  (   eni_cat.leaf_node_flag   = ''Y''
               AND eni_cat.parent_id        = eni_cat.child_id)
            OR (   eni_cat.imm_child_id     = eni_cat.child_id
               AND eni_cat.parent_id        <> child_id) )';
            END IF;
        ELSIF l_vb_org THEN
            l_prod_cat_from := '';
            l_prod_cat_where := '
        AND fact.inv_org_flag = 0
        AND '|| CASE
                    WHEN l_all_prod_cats THEN 'fact.top_node_flag = ''Y'' '
                    ELSE 'fact.parent_id  IN (&ITEM+ENI_ITEM_VBH_CAT) '
                END;
        END IF;
    ELSE
        l_mv1 := 'ISC_DBI_CFM_000_MV';
        l_mv2 := 'ISC_DBI_CFM_002_MV';
        l_flags_where := '
     AND fact.item_cat_flag = :ENI_ITEM_CAT_FLAG
     AND fact.customer_flag = :ENI_CUST_FLAG';

        l_prod_cat_from := '
        , ENI_DENORM_HIERARCHIES  eni_cat
        , MTL_DEFAULT_CATEGORY_SETS mdcs';

        IF( l_all_prod_cats ) THEN
            IF l_vb_prod_cat THEN -- all top-node categories
                l_prod_cat_where := '
        AND fact.item_category_id   = eni_cat.child_id
        AND eni_cat.top_node_flag   = ''Y''
        AND eni_cat.dbi_flag        = ''Y''
        AND eni_cat.object_type     = ''CATEGORY_SET''
        AND eni_cat.object_id       = mdcs.category_set_id
        AND mdcs.functional_area_id = 11';
            ELSE
                l_prod_cat_from := '';
                l_prod_cat_where := '';
            END IF;
        ELSE -- category specified
            l_prod_cat_where := '
        AND fact.item_category_id   = eni_cat.child_id
        AND eni_cat.parent_id       IN (&ITEM+ENI_ITEM_VBH_CAT)
        AND eni_cat.dbi_flag        = ''Y''
        AND eni_cat.object_type     = ''CATEGORY_SET''
        AND eni_cat.object_id       = mdcs.category_set_id
        AND mdcs.functional_area_id = 11';
        END IF;

        -- ITEM AND ITEM CATEGORY
        IF l_all_prods THEN
            l_prod_where := '';

            l_item_cat_flag :=  CASE -- order matters
                                    WHEN l_vb_prod          THEN 4 -- rollup on master item
                                    WHEN l_vb_prod_cat      THEN 1 -- rollup on category
                                    WHEN l_all_prod_cats    THEN 3 -- all product categories
                                    ELSE 1
                                END;
        ELSE
            l_prod_where := '
                AND fact.master_item_id IN (&ITEM+ENI_ITEM)';

            IF l_vb_prod THEN
                l_item_cat_flag := 4;
            ELSE
                l_item_cat_flag := 0;
            END IF;
        END IF;

        -- CUSTOMER
        IF l_all_custs THEN
            l_cust_where := '';
            l_cust_flag  := CASE
                                WHEN l_vb_cust THEN 0 -- customers selected
                                ELSE 1                -- all customers & not viewed by customer
                            END;
        ELSE
            l_cust_where := ' AND fact.customer_id in (&CUSTOMER+FII_CUSTOMERS)';
            l_cust_flag := 0; -- customer selected
        END IF;
    END IF;

  l_stmt := l_select_stmt || '
    , c.curr_booked_qty                                 ENI_MEASURE1  -- book qty
    , c.curr_booked_value                               ENI_MEASURE2  -- book
    , ( c.curr_booked_value-c.prev_booked_value)
    / decode( c.prev_booked_value, 0, NULL
            , abs(c.prev_booked_value)) * 100           ENI_MEASURE3  -- book change
    , c.curr_fulfill_qty                                ENI_MEASURE4  -- fulf qty
    , c.curr_fulfill_value                              ENI_MEASURE5  -- fulf
    , (c.curr_fulfill_value-c.prev_fulfill_value)
    / decode( c.prev_fulfill_value, 0, NULL
            , abs(c.prev_fulfill_value)) * 100          ENI_MEASURE6  -- fulf change
    , c.curr_booked_value
    / decode( c.curr_fulfill_value, 0, NULL
            , c.curr_fulfill_value)                     ENI_MEASURE7  -- book to fulf r
    , c.curr_booked_value
    / decode( c.curr_fulfill_value, 0, NULL
            , c.curr_fulfill_value)
    - c.prev_booked_value
    / decode( c.prev_fulfill_value, 0, NULL
            , c.prev_fulfill_value)                     ENI_MEASURE8  -- book to fulf r change
    , sum(c.curr_booked_value) over ()                  ENI_MEASURE9  -- gd total book
    , ( sum(c.curr_booked_value) over () - sum(c.prev_booked_value) over () )
    / decode( sum( c.prev_booked_value ) over (), 0, NULL
            , abs( sum(c.prev_booked_value) over () ) )
    * 100                                               ENI_MEASURE10 -- gd total book change
    , sum(c.curr_fulfill_value) over ()                 ENI_MEASURE11 -- gd total fulf
    , (sum(c.curr_fulfill_value) over () - sum(c.prev_fulfill_value) over ())
    / decode( sum(c.prev_fulfill_value) over (), 0, NULL
            , abs( sum(c.prev_fulfill_value) over () ) )
    * 100                                               ENI_MEASURE12 -- gd total fulf change
    , sum(c.curr_booked_value) over ()
    / decode( sum(c.curr_fulfill_value) over (), 0, NULL
            , sum(c.curr_fulfill_value) over () )       ENI_MEASURE13 -- gd total book to fulf r
    , sum(c.curr_booked_value) over ()
    / decode( sum(c.curr_fulfill_value) over (), 0, NULL
            , sum(c.curr_fulfill_value) over () )
    - sum(c.prev_booked_value) over ()
    / decode( sum(c.prev_fulfill_value) over (), 0, NULL
            , sum(c.prev_fulfill_value) over () )       ENI_MEASURE14 -- gd total book to fulf r change
    , c.curr_booked_value                               ENI_MEASURE15 -- KPI book
    , c.prev_booked_value                               ENI_MEASURE16 -- KPI book prior
    , c.curr_fulfill_value                              ENI_MEASURE17 -- KPI fulf
    , c.prev_fulfill_value                              ENI_MEASURE18 -- KPI fulf prior
    , c.curr_booked_value
    / decode( c.curr_fulfill_value, 0, NULL
            , c.curr_fulfill_value )                    ENI_MEASURE19 -- KPI book to fulf r
    , c.prev_booked_value
    / decode( c.prev_fulfill_value, 0, NULL
            , c.prev_fulfill_value )                    ENI_MEASURE20 -- KPI book to fulf r prior
    , sum(c.curr_booked_value) over ()                  ENI_MEASURE21 -- KPI gd total book value
    , sum(c.prev_booked_value) over ()                  ENI_MEASURE22 -- KPI gd total book prior
    , c.prev_booked_value
    / decode( c.prev_fulfill_value, 0, NULL
            , c.prev_fulfill_value )                    ENI_MEASURE24 -- KPI book to fulf r prior
    , sum(c.prev_booked_value) over ()
    / decode( sum(c.prev_fulfill_value) over (), 0, NULL
            , sum(c.prev_fulfill_value) over () )       ENI_MEASURE25 -- KPI gd total book to fulf r prior
    FROM ('||l_union_select_stmt||'
        , sum(curr_booked_qty)    CURR_BOOKED_QTY
        , sum(curr_booked_value)  CURR_BOOKED_VALUE
        , sum(prev_booked_value)  PREV_BOOKED_VALUE
        , sum(curr_fulfill_qty)   CURR_FULFILL_QTY
        , sum(curr_fulfill_value) CURR_FULFILL_VALUE
        , sum(prev_fulfill_value) PREV_FULFILL_VALUE
    FROM ('||l_inner_select_stmt||'
        , fact.inv_org_id                                   INV_ORG
        , decode( cal.report_date, &BIS_CURRENT_ASOF_DATE
                , fact.booked_qty, 0)                       CURR_BOOKED_QTY
        , decode( cal.report_date, &BIS_CURRENT_ASOF_DATE
                , fact.booked_amt_'||l_curr_suffix||', 0)   CURR_BOOKED_VALUE
        , decode( cal.report_date, &BIS_PREVIOUS_ASOF_DATE
                , fact.booked_amt_'||l_curr_suffix||', 0)   PREV_BOOKED_VALUE
        , 0                                                 CURR_FULFILL_QTY
        , 0                                                 CURR_FULFILL_VALUE
        , 0                                                 PREV_FULFILL_VALUE
    FROM '||l_mv1||'   fact
        , FII_TIME_RPT_STRUCT_V  cal'
        ||l_prod_cat_from||'
    WHERE fact.time_id = cal.time_id'
      || l_flags_where||'
      AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
      AND cal.period_type_id = fact.period_type_id
      AND bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id'
      || l_prod_cat_where
      || l_prod_where
      || l_cust_where||'
  UNION ALL
        '||l_inner_select_stmt||'
        , fact.inv_org_id                                       INV_ORG
        , 0                                                     CURR_BOOKED_QTY
        , 0                                                     CURR_BOOKED_VALUE
        , 0                                                     PREV_BOOKED_VALUE
        , decode( cal.report_date, &BIS_CURRENT_ASOF_DATE
                , fact.fulfilled_qty, 0)                        CURR_FULFILL_QTY
        , decode( cal.report_date, &BIS_CURRENT_ASOF_DATE
                , fact.fulfilled_amt_'||l_curr_suffix||', 0)    CURR_FULFILL_VALUE
        , decode( cal.report_date, &BIS_PREVIOUS_ASOF_DATE
                , fact.fulfilled_amt_'||l_curr_suffix||', 0)    PREV_FULFILL_VALUE
    FROM '||l_mv2||'   fact
      , FII_TIME_RPT_STRUCT_V  cal'
      ||l_prod_cat_from||'
   WHERE fact.time_id = cal.time_id'
     || l_flags_where||'
     AND fact.return_flag = 0
     AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
     AND cal.period_type_id = fact.period_type_id
     AND bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id'
     || l_prod_cat_where
     || l_prod_where
     || l_cust_where
     || ')'
   -- WHERE '||l_inv_org_where
     ||l_union_group_by_stmt||') c) ) a'
     ||l_where_stmt;

    x_custom_sql := l_stmt;

    l_custom_rec.attribute_name         := ':ENI_ITEM_CAT_FLAG';
    l_custom_rec.attribute_value        := to_char(l_item_cat_flag);
    l_custom_Rec.attribute_type         := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type    := bis_pmv_parameters_pub.integer_bind;
    x_custom_output.EXTEND;
    x_custom_output(1) := l_custom_rec;

    l_custom_rec.attribute_name         := ':ENI_CUST_FLAG';
    l_custom_rec.attribute_value        := to_char(l_cust_flag);
    l_custom_Rec.attribute_type         := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type    := bis_pmv_parameters_pub.integer_bind;
    x_custom_output.EXTEND;
    x_custom_output(2) := l_custom_rec;

    l_custom_rec.attribute_name         := ':ENI_LANG';
    l_custom_rec.attribute_value        := l_lang;
    l_custom_Rec.attribute_type         := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_Rec.attribute_data_type    := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
    x_custom_output.EXTEND;
    x_custom_output(3) := l_custom_rec;

END Get_Sql;

END ENI_DBI_CFM_PKG;

/
