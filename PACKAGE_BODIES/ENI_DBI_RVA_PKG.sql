--------------------------------------------------------
--  DDL for Package Body ENI_DBI_RVA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_RVA_PKG" AS
/* $Header: ENIRVAPB.pls 120.1 2006/03/22 23:36:32 ajerome noship $ */

PROCEDURE GET_SQL(  p_param         IN          BIS_PMV_PAGE_PARAMETER_TBL
                 ,  x_custom_sql    OUT NOCOPY  VARCHAR2
                 ,  x_custom_output OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL )
                 IS

  l_stmt                VARCHAR2(32000);
  l_measures            VARCHAR2(32000);
  l_select_stmt         VARCHAR2(32000);
  l_inner_sql           VARCHAR2(32000);
  l_inner_select_stmt   VARCHAR2(32000);
  l_inner_group_by_stmt VARCHAR2(32000);
  l_union_select_stmt   VARCHAR2(32000);
  l_union_group_by_stmt VARCHAR2(32000);
  l_where_stmt          VARCHAR2(32000);
  l_mv1                 VARCHAR2(100);
  l_flags_where         VARCHAR2(1000);
  l_view_by             VARCHAR2(32000);
  l_org                 VARCHAR2(32000);
  l_org_where           VARCHAR2(32000);
  l_prod                VARCHAR2(32000);
  l_prod_where          VARCHAR2(32000);
  l_cust_where          VARCHAR2(32000);
  l_cust                VARCHAR2(32000);
  l_prod_cat            VARCHAR2(32000);
  l_prod_cat_from       VARCHAR2(32000);
  l_prod_cat_where      VARCHAR2(32000);
  l_ret_reason          VARCHAR2(32000);
  l_ret_reason_where    VARCHAR2(32000);

--  l_curr            VARCHAR2(15) := 'NOT PASSED IN';
  l_curr_suffix     VARCHAR2(10);

  l_lang            VARCHAR2(10);
  l_item_cat_flag   NUMBER; -- 0 for product and 1 for product category
  l_cust_flag       NUMBER; -- 0 for customer and 1 for no customer selected
  l_reason_flag     NUMBER; -- 0 for reason and 1 for all reasons
  l_custom_rec      BIS_QUERY_ATTRIBUTES ;

  l_all_prods       BOOLEAN;
  l_all_prod_cats   BOOLEAN;
  l_all_custs       BOOLEAN;
  l_all_reasons     BOOLEAN;

  l_vb_prod_cat     BOOLEAN;
  l_vb_prod         BOOLEAN;
  l_vb_cust         BOOLEAN;
  l_vb_org          BOOLEAN;

  l_open_url1       VARCHAR2(200);
  l_open_url2       VARCHAR2(200);
  l_open_urls       VARCHAR2(500);

  --Bug 5083648
  l_inv_org_flag   VARCHAR2(1);

BEGIN

    l_lang := userenv('LANG');

    FOR i IN 1..p_param.COUNT LOOP
        CASE p_param(i).parameter_name
            WHEN 'VIEW_BY'                          THEN l_view_by    := p_param(i).parameter_value;
            WHEN 'ITEM+ENI_ITEM_VBH_CAT'            THEN l_prod_cat   := p_param(i).parameter_value;
            /* ENI Reports need MASTER ORG Items as a parameter */
            WHEN 'ITEM+ENI_ITEM'                    THEN l_prod       := p_param(i).parameter_value;
            /* Commenting out as the below are not required in ENI Reports */
--          WHEN 'ORGANIZATION+ORGANIZATION'        THEN l_org        := p_param(i).parameter_value;
--          WHEN 'ITEM+ENI_ITEM_ORG'                THEN l_item_org   := p_param(i).parameter_value;
            WHEN 'CUSTOMER+FII_CUSTOMERS'           THEN l_cust       := p_param(i).parameter_value;
            WHEN 'ORDER_ITEM_RETURN_REASON+ORDER_ITEM_RETURN_REASON'  THEN l_ret_reason := p_param(i).parameter_id;
            WHEN 'CURRENCY+FII_CURRENCIES'                            THEN
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
    l_all_reasons   := (l_ret_reason  IS NULL OR l_ret_reason = '' OR l_ret_reason = 'All');

    l_vb_prod_cat   := (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT' );
    l_vb_prod       := (l_view_by = 'ITEM+ENI_ITEM' );
    l_vb_cust       := (l_view_by = 'CUSTOMER+FII_CUSTOMERS' );
    l_vb_org        := (l_view_by = 'ORGANIZATION+ORGANIZATION');

    IF l_all_prod_cats
    THEN
        IF  ( l_vb_prod_cat OR
              l_vb_org )
        THEN
            l_prod_cat_from := '
      , ENI_DENORM_HIERARCHIES      eni_cat
      , MTL_DEFAULT_CATEGORY_SETS   mdcs';
            l_prod_cat_where := '
        AND fact.item_category_id = eni_cat.child_id
        AND eni_cat.top_node_flag = ''Y''
        AND eni_cat.dbi_flag      = ''Y''
        AND eni_cat.object_type   = ''CATEGORY_SET''
        AND eni_cat.object_id     = mdcs.category_set_id
        AND mdcs.functional_area_id = 11';
        ELSE
            l_prod_cat_from := '';
            l_prod_cat_where := '';
        END IF;
    ELSE
        l_prod_cat_from := '
      , ENI_DENORM_HIERARCHIES      eni_cat
      , MTL_DEFAULT_CATEGORY_SETS   mdcs';
        l_prod_cat_where := '
        AND fact.item_category_id = eni_cat.child_id
        AND eni_cat.parent_id     IN (&ITEM+ENI_ITEM_VBH_CAT)
        AND eni_cat.dbi_flag      = ''Y''
        AND eni_cat.object_type   = ''CATEGORY_SET''
        AND eni_cat.object_id     = mdcs.category_set_id
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
        l_cust_where := '
        AND fact.customer_id in (&CUSTOMER+FII_CUSTOMERS)';
        l_cust_flag := 0; -- customer selected
    END IF;

    -- REASON
    IF l_all_reasons THEN
        l_ret_reason_where := '';
        l_reason_flag := 1;
    ELSE
        l_ret_reason_where := '
        AND fact.return_reason IN (&ORDER_ITEM_RETURN_REASON+ORDER_ITEM_RETURN_REASON)';
        l_reason_flag := 0;
    END IF;

    l_measures :=
     ', ENI_MEASURE1,ENI_MEASURE2,ENI_MEASURE3,ENI_MEASURE4,ENI_MEASURE5
      , ENI_MEASURE6,ENI_MEASURE7,ENI_MEASURE8,ENI_MEASURE9,ENI_MEASURE10 ';
--  Commenting out measures not required in ENI Reports
--    , ISC_MEASURE_11,ISC_MEASURE_12,ISC_MEASURE_13';
    l_open_url1 :=
    '''pFunctionName=ENI_DBI_RVR_R&VIEW_BY=ORDER_ITEM_RETURN_REASON+ORDER_ITEM_RETURN_REASON&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''';
    l_open_url2 :=
    '''pFunctionName=ENI_DBI_RVD_R&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''';
    l_open_urls :=  '
      , DECODE(ENI_MEASURE1,0,NULL,
              '||l_open_url1||') ENI_ATTRIBUTE5
      , DECODE(ENI_MEASURE5,0,NULL,
              '||l_open_url2||') ENI_ATTRIBUTE6';


/* This portion of the code sets up spaghetti pieces for particular viewbys */
CASE
WHEN l_vb_org THEN                                -- +=================== ORGANIZATION ========================+
    l_select_stmt := '
 SELECT org.name                    VIEWBY
      , org.organization_id         VIEWBYID
      , NULL                        ENI_ATTRIBUTE3 -- drill across url
      , NULL                        ENI_ATTRIBUTE4 -- item description
      ' || l_measures || '
      , NULL ENI_ATTRIBUTE5
      , NULL ENI_ATTRIBUTE6
   FROM
(SELECT (rank() over (&ORDER_BY_CLAUSE nulls last, inv_org_id)) - 1     rnk
      , inv_org_id '
      || l_measures ||  '
   FROM
(SELECT c.inv_org_id,   ';

    l_inner_select_stmt := '
         SELECT fact.inv_org_id     INV_ORG_ID';
    l_union_select_stmt := '
         SELECT inv_org_id          INV_ORG_ID';
    l_inner_group_by_stmt := '
        GROUP BY fact.inv_org_id';
    l_union_group_by_stmt := '
        GROUP BY inv_org_id';
    l_where_stmt := '
    HR_ALL_ORGANIZATION_UNITS_TL    org
  WHERE a.inv_org_id = org.organization_id
    AND org.language = :ENI_LANG
    AND ((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
 &ORDER_BY_CLAUSE NULLS LAST';

WHEN l_vb_prod THEN                            -- +====================== PRODUCT ===========================+
    l_select_stmt := '
 SELECT items.value                 VIEWBY
      , items.id                    VIEWBYID
      , NULL                        ENI_ATTRIBUTE3 -- drill across url
      , items.description           ENI_ATTRIBUTE4 -- item description
      '||l_measures||l_open_urls||'
   FROM
(SELECT (rank() over (&ORDER_BY_CLAUSE nulls last, item_id)) - 1        rnk
        , item_id
        '||l_measures||'
     FROM
(SELECT c.item_id,              ';
        -- c.uom,       ';

    l_inner_select_stmt := '
         SELECT fact.master_item_id ITEM_ID';
                -- , fact.uom         UOM';

    l_union_select_stmt := '
         SELECT item_id             ITEM_ID';
                -- uom              UOM,';

    l_inner_group_by_stmt := '
        GROUP BY fact.master_item_id';
            --, fact.uom';

    l_union_group_by_stmt := '
        GROUP BY item_id';
            --, uom';

    l_where_stmt := '
    ENI_ITEM_V          items
    WHERE a.item_id = items.id
    AND ((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
 &ORDER_BY_CLAUSE NULLS LAST';

WHEN l_vb_cust THEN                            -- +===================== CUSTOMER ==========================+
    l_select_stmt := '
 SELECT cust.value                  VIEWBY
      , cust.id                     VIEWBYID
      , NULL                        ENI_ATTRIBUTE3 -- drill across url
      , NULL                        ENI_ATTRIBUTE4 -- item description
      '||l_measures||l_open_urls||'
   FROM
(SELECT (rank() over (&ORDER_BY_CLAUSE nulls last, customer_id)) - 1        rnk
      , customer_id
      '||l_measures||'
   FROM
(SELECT c.customer_id,  ';
    l_inner_select_stmt := '
         SELECT fact.customer_id    CUSTOMER_ID';
    l_union_select_stmt := '
         SELECT customer_id         CUSTOMER_ID';
    l_inner_group_by_stmt := '
        GROUP BY fact.customer_id';
    l_union_group_by_stmt := '
        GROUP BY customer_id';
    l_where_stmt := '
    FII_CUSTOMERS_V         cust
  WHERE a.customer_id = cust.id
    AND ((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
 &ORDER_BY_CLAUSE NULLS LAST';

WHEN l_vb_prod_cat THEN                        -- +================== PRODUCT CAT ==========================+
    l_select_stmt := '
 SELECT eni_vbh.value               VIEWBY
      , eni_vbh.id                  VIEWBYID
      , DECODE(eni_vbh.leaf_node_flag, ''Y'',
            ''pFunctionName=ENI_DBI_RVA_R&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM&pParamIds=Y'',
            ''pFunctionName=ENI_DBI_RVA_R&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&pParamIds=Y'')
        ENI_ATTRIBUTE3              -- drill across url
      , NULL                        ENI_ATTRIBUTE4 -- item description
      '||l_measures||l_open_urls||'
   FROM
(SELECT (rank() over (&ORDER_BY_CLAUSE nulls last, item_category_id)) - 1   rnk,
    item_category_id
    '||l_measures||'
   FROM
(SELECT c.item_category_id, ';
    IF l_all_prod_cats
    THEN
        l_inner_select_stmt := '
         SELECT eni_cat.parent_id               ITEM_CATEGORY_ID';
        l_inner_group_by_stmt := '
         GROUP BY eni_cat.parent_id';
    ELSE
        l_inner_select_stmt := '
         SELECT eni_cat.imm_child_id            ITEM_CATEGORY_ID';
        l_inner_group_by_stmt := '
        GROUP BY eni_cat.imm_child_id';
    END IF;
    l_union_select_stmt := '
         SELECT item_category_id                ITEM_CATEGORY_ID';
    l_union_group_by_stmt := '
        GROUP BY item_category_id';
    l_where_stmt := '
    ENI_ITEM_VBH_NODES_V        eni_vbh
  WHERE a.item_category_id = eni_vbh.id
    AND a.item_category_id = eni_vbh.parent_id
    AND a.item_category_id = eni_vbh.child_id
    AND ((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
 &ORDER_BY_CLAUSE NULLS LAST';
END CASE;

    IF(     l_all_prods
      AND   l_all_custs
      AND   l_all_reasons
      AND   (   l_vb_prod_cat
            OR  l_vb_org )
      )
    THEN
        l_mv1 := 'ISC_DBI_CFM_011_MV';
        l_flags_where := '
        ';

        l_prod_cat_from := '';
        IF l_vb_prod_cat THEN
            l_inner_select_stmt := '
                SELECT  fact.parent_id  ITEM_CATEGORY_ID';
            l_inner_group_by_stmt := '
                GROUP BY fact.parent_id';
        ELSE
            l_inner_select_stmt := '
                SELECT  fact.inv_org_id INV_ORG_ID';
            l_inner_group_by_stmt := '
                GROUP BY fact.inv_org_id';
        END IF;

        IF l_all_prod_cats THEN
            -- inv_org_flag == 1 ==> look at the rows that rollup() over inv_org_id;
            --  i.e. sum over all orgs
            -- inv_org_flag == 0 ==> look at the non-rollup rows

            --Bug 5083648 : Replaced Literal with Bind Parameter
            /*
                l_prod_cat_where := '
            AND fact.top_node_flag = ''Y''
            AND fact.inv_org_flag = '|| CASE
                                              WHEN l_vb_prod_cat  THEN '1'
                                              WHEN l_vb_org       THEN '0'
                                          END;
            */
            l_prod_cat_where := '
              AND fact.top_node_flag = ''Y''
              AND fact.inv_org_flag = :INV_ORG_FLAG';

            IF l_vb_prod_cat
            THEN l_inv_org_flag := '1';
            ELSE
              IF l_vb_org
              THEN l_inv_org_flag := '0';
              END IF;
            END IF;

        ELSE -- prod cat has been specified
            IF l_vb_prod_cat THEN
                l_prod_cat_from := '
                    , ENI_DENORM_HIERARCHIES          eni_cat
                    , MTL_DEFAULT_CATEGORY_SETS       mdcs';
                -- inv_org_flag == 1 ==> look at the rows that rollup() over inv_org_id;
                --  i.e. sum over all orgs
                l_prod_cat_where := '
        AND fact.inv_org_flag   = 1
        AND fact.parent_id      = eni_cat.child_id
        AND eni_cat.dbi_flag    = ''Y''
        AND eni_cat.object_type = ''CATEGORY_SET''
        AND eni_cat.object_id   = mdcs.category_set_id
        AND mdcs.functional_area_id = 11
        AND eni_cat.parent_id   IN (&ITEM+ENI_ITEM_VBH_CAT)
        AND ( (eni_cat.leaf_node_flag = ''Y''
                AND eni_cat.parent_id = eni_cat.child_id)
            OR (eni_cat.imm_child_id = eni_cat.child_id
                AND eni_cat.parent_id <> child_id) )';
            ELSIF l_vb_org THEN
                -- inv_org_flag == 0 ==> look at the non-rollup rows
                l_prod_cat_where := '
        AND fact.parent_id      IN (&ITEM+ENI_ITEM_VBH_CAT)
        AND fact.inv_org_flag   = 0';
            END IF;
        END IF;
    ELSE
        l_mv1 := 'ISC_DBI_CFM_002_MV';
        IF( NOT l_vb_prod_cat AND
            l_all_prod_cats )
        THEN
            l_prod_cat_from := '';
            l_prod_cat_where := '';
        END IF;

        l_flags_where := '
        AND fact.item_cat_flag = :ENI_ITEM_CAT_FLAG
        AND fact.customer_flag = :ENI_CUST_FLAG';
    END IF;

  IF l_reason_flag = 0 -- use of ISC_DBI_CFM_007_MV (return reason)
    THEN l_inner_sql := l_union_select_stmt||'
      , sum(curr_return)                    CURR_RETURN
      , sum(prev_return)                    PREV_RETURN
      , sum(curr_ship)                      CURR_SHIP
      , sum(prev_ship)                      PREV_SHIP
      , sum(lines_cnt)                      LINES_CNT
      , sum(return_qty)                     RETURN_QTY
       FROM ('||l_inner_select_stmt||'
      , sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
               fact.returned_amt_'||l_curr_suffix||', 0))       CURR_RETURN
      , sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
               fact.returned_amt_'||l_curr_suffix||', 0))       PREV_RETURN
      , 0                                                       CURR_SHIP
      , 0                                                       PREV_SHIP
      , sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
               fact.lines_cnt, 0))                              LINES_CNT
      , sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
               fact.returned_qty, 0))                           RETURN_QTY
       FROM ISC_DBI_CFM_007_MV  fact
          , FII_TIME_RPT_STRUCT cal'||l_prod_cat_from||'
      WHERE fact.time_id = cal.time_id
        AND fact.period_type_id = cal.period_type_id
        AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN) = cal.record_type_id
        AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
        AND fact.customer_flag = :ENI_CUST_FLAG
        AND fact.item_cat_flag = :ENI_ITEM_CAT_FLAG
        AND fact.return_reason_flag = :ENI_REASON_FLAG'
        --||l_org_where
        ||l_prod_cat_where
        ||l_prod_where
        ||l_cust_where
        ||l_ret_reason_where
        ||l_inner_group_by_stmt||'
      UNION ALL
        '||l_inner_select_stmt||'
      , 0                                                       CURR_RETURN
      , 0                                                       PREV_RETURN
      , sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
               fact.fulfilled_amt2_'||l_curr_suffix||', 0))     CURR_SHIP
      , sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
               fact.fulfilled_amt2_'||l_curr_suffix||', 0))     PREV_SHIP
      , 0                                                       LINES_CNT
      , 0                                                       RETURN_QTY
       FROM ISC_DBI_CFM_002_MV  fact
          , FII_TIME_RPT_STRUCT cal'||l_prod_cat_from||'
      WHERE fact.time_id = cal.time_id
        AND fact.return_flag = 0
        AND fact.period_type_id = cal.period_type_id
        AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN) = cal.record_type_id
        AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
        AND fact.customer_flag = :ENI_CUST_FLAG
        AND fact.item_cat_flag = :ENI_ITEM_CAT_FLAG'
        -- ||l_org_where
        ||l_prod_cat_where
        ||l_prod_where
        ||l_cust_where
        ||l_inner_group_by_stmt||')'
        ||l_union_group_by_stmt;

     ELSE
    l_inner_sql := l_inner_select_stmt||'
      , sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
               decode(fact.return_flag, 1,
                  fact.returned_amt_'||l_curr_suffix||', 0), 0))        CURR_RETURN
      , sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
               decode(fact.return_flag, 1,
                  fact.returned_amt_'||l_curr_suffix||', 0), 0))        PREV_RETURN
      , sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
               decode(fact.return_flag, 0,
                  fact.fulfilled_amt2_'||l_curr_suffix||', 0), 0))      CURR_SHIP
      , sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
               decode(fact.return_flag, 0,
                  fact.fulfilled_amt2_'||l_curr_suffix||', 0), 0))      PREV_SHIP
      , sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
               decode(fact.return_flag, 1,
                  fact.lines_cnt, 0), 0))                               LINES_CNT
      , sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
               decode(fact.return_flag, 1,
                  fact.returned_qty, 0), 0))                            RETURN_QTY
       FROM '||l_mv1||'    fact
          , FII_TIME_RPT_STRUCT   cal'||l_prod_cat_from||'
      WHERE fact.time_id = cal.time_id
        AND fact.period_type_id = cal.period_type_id
        AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN) = cal.record_type_id
        AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)'
        ||l_flags_where
    --  ||l_org_where
        ||l_prod_cat_where
        ||l_prod_where
        ||l_cust_where
        ||l_inner_group_by_stmt;
  END IF;
/* End spaghetti pieces */

  l_stmt := l_select_stmt||'
    c.curr_return                                   ENI_MEASURE1 -- return value
  , (c.curr_return - c.prev_return)
      / decode(c.prev_return, 0, NULL,
           abs(c.prev_return)) * 100                ENI_MEASURE2 -- return value change
  , c.curr_return
      / decode(c.curr_ship, 0, NULL,
           c.curr_ship) * 100                       ENI_MEASURE3 -- return rate
  , c.curr_return
      / decode(c.curr_ship, 0, NULL,
           c.curr_ship) * 100 -
    c.prev_return
      / decode(c.prev_ship, 0, NULL,
           c.prev_ship) * 100                       ENI_MEASURE4 -- return rate change
  , c.lines_cnt                                     ENI_MEASURE5 -- past due lines
  , sum(c.curr_return) over ()                      ENI_MEASURE6 -- gd total return value
  , (sum(c.curr_return) over () - sum(c.prev_return) over ())
      / decode(sum(c.prev_return) over (), 0, NULL,
           abs(sum(c.prev_return) over ())) * 100   ENI_MEASURE7 -- gd total return change
  , sum(c.curr_return) over ()
      / decode(sum(c.curr_ship) over (), 0, NULL,
           sum(c.curr_ship) over ()) * 100          ENI_MEASURE8 -- gd total return rate
  , sum(c.curr_return) over ()
      / decode(sum(c.curr_ship) over (), 0, NULL,
           sum(c.curr_ship) over ()) * 100 -
    sum(c.prev_return) over()
      / decode(sum(c.prev_ship) over (), 0, NULL,
           sum(c.prev_ship) over ()) * 100          ENI_MEASURE9 -- gd total return rate change
  , sum(c.lines_cnt) over ()                        ENI_MEASURE10   -- gd return lines
   FROM ('||l_inner_sql||')  c)
  WHERE ENI_MEASURE1 <> 0
     OR ENI_MEASURE2 IS NOT NULL
     OR ENI_MEASURE3 IS NOT NULL
     OR ENI_MEASURE4 IS NOT NULL
     OR ENI_MEASURE5 <> 0)  a,'
    ||l_where_stmt;
--    || '-- CURR:' || l_curr;

  x_custom_sql := l_stmt;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  l_custom_rec.attribute_name       := ':ENI_ITEM_CAT_FLAG';
  l_custom_rec.attribute_value      := to_char(l_item_cat_flag);
  l_custom_rec.attribute_type       := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type  := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name       := ':ENI_CUST_FLAG';
  l_custom_rec.attribute_value      := to_char(l_cust_flag);
  l_custom_rec.attribute_type       := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type  := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name       := ':ENI_REASON_FLAG';
  l_custom_rec.attribute_value      := to_char(l_reason_flag);
  l_custom_rec.attribute_type       := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type  := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name       := ':ENI_LANG';
  l_custom_rec.attribute_value      := l_lang;
  l_custom_rec.attribute_type       := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type  := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name       := ':INV_ORG_FLAG';
  l_custom_rec.attribute_value      := l_inv_org_flag;
  l_custom_rec.attribute_type       := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type  := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;


END get_sql;

END ENI_DBI_RVA_PKG;


/
