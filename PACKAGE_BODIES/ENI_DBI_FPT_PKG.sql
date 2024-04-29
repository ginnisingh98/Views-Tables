--------------------------------------------------------
--  DDL for Package Body ENI_DBI_FPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_FPT_PKG" AS
/* $Header: ENIFPTPB.pls 120.0 2005/05/26 19:36:28 appldev noship $ */

PROCEDURE Get_Sql ( p_param         IN          BIS_PMV_PAGE_PARAMETER_TBL
                  , x_custom_sql    OUT NOCOPY  VARCHAR2
                  , x_custom_output OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt                VARCHAR2(10000);
  l_period_type         VARCHAR2(10000);
  l_mv1                 VARCHAR2(100);
  l_mv2                 VARCHAR2(100);
  l_flags_where         VARCHAR2(1000);
  l_inv_org             VARCHAR2(10000);
  l_inv_org_where       VARCHAR2(10000);
  l_prod                VARCHAR2(10000);
  l_prod_where          VARCHAR2(10000);
  l_prod_cat            VARCHAR2(10000);
  l_prod_cat_from       VARCHAR2(10000);
  l_prod_cat_where      VARCHAR2(10000);
  l_cust                VARCHAR2(10000);
  l_cust_where          VARCHAR2(10000);

  l_curr_suffix         VARCHAR2(10);
--  l_curr                VARCHAR2(15) := 'NOT PASSED IN';

  l_all_prods           BOOLEAN;
  l_all_prod_cats       BOOLEAN;
  l_all_custs           BOOLEAN;

  l_item_cat_flag       NUMBER; -- 0 for product, 1 for product category, 3 for no grouping on item dimension
  l_cust_flag           NUMBER; -- 0 for customer and 1 for no customer selected

  l_order_by            VARCHAR2(250);
  l_custom_rec          BIS_QUERY_ATTRIBUTES;

BEGIN
    l_period_type := 'TEST';
    FOR i IN 1..p_param.COUNT LOOP
        CASE p_param(i).parameter_name
            WHEN 'PERIOD_TYPE'              THEN l_period_type  := p_param(i).parameter_value;
            WHEN 'ITEM+ENI_ITEM_VBH_CAT'    THEN l_prod_cat     := p_param(i).parameter_value;
            WHEN 'ITEM+ENI_ITEM'            THEN l_prod         := p_param(i).parameter_value;
            WHEN 'CUSTOMER+FII_CUSTOMERS'   THEN l_cust         := p_param(i).parameter_value;
            WHEN 'ORDERBY'                  THEN l_order_by     := p_param(i).parameter_value;
            WHEN 'CURRENCY+FII_CURRENCIES'  THEN
                l_curr_suffix :=
                    CASE p_param(i).parameter_id
                        WHEN eni_dbi_util_pkg.get_curr_prim THEN 'g'    -- primary global currency
                        WHEN eni_dbi_util_pkg.get_curr_sec  THEN 'g1'   -- secondary global currency
                        ELSE 'f'                                        -- functional currency
                    END;
            ELSE null;
        END CASE;
    END LOOP;

    IF l_order_by like '%DESC%' THEN
         l_order_by := ' DESC';
    ELSE
         l_order_by := ' ASC';
    END IF;

    l_all_prods       := (l_prod        IS NULL OR l_prod       = '' OR l_prod       = 'All');
    l_all_prod_cats   := (l_prod_cat    IS NULL OR l_prod_cat   = '' OR l_prod_cat   = 'All');
    l_all_custs       := (l_cust        IS NULL OR l_cust       = '' OR l_cust       = 'All');

    IF ( l_all_prods      AND
         l_all_custs )
    THEN

        l_mv1 := 'ISC_DBI_CFM_009_MV';
        l_mv2 := 'ISC_DBI_CFM_011_MV';

        l_flags_where := '
            AND fact.inv_org_flag       = 1';
            -- look at rollups across all inv_org_ids

        IF l_all_prod_cats THEN
            l_prod_cat_where := '
            AND fact.top_node_flag      = ''Y'' ';      -- no cat specified, so examine top nodes only
        ELSE
            l_prod_cat_where := '
            AND fact.parent_id          IN (&ITEM+ENI_ITEM_VBH_CAT)'; -- cat specified
        END IF;
    ELSE
        l_mv1 := 'ISC_DBI_CFM_000_MV';
        l_mv2 := 'ISC_DBI_CFM_002_MV';
        l_flags_where := '
            AND fact.item_cat_flag      = :ENI_ITEM_CAT_FLAG
            AND fact.customer_flag      = :ENI_CUST_FLAG';

        IF l_all_prod_cats THEN
            l_prod_cat_from := '';
            l_prod_cat_where := '';
        ELSE
            l_prod_cat_from := '
            , ENI_DENORM_HIERARCHIES        eni_cat
            , MTL_DEFAULT_CATEGORY_SETS     mdcs';
            l_prod_cat_where := '
            AND fact.item_category_id   = eni_cat.child_id
            AND eni_cat.parent_id       IN (&ITEM+ENI_ITEM_VBH_CAT)
            AND eni_cat.dbi_flag        = ''Y''
            AND eni_cat.object_type     = ''CATEGORY_SET''
            AND eni_cat.object_id       = mdcs.category_set_id
            AND mdcs.functional_area_id = 11';
        END IF;

        IF l_all_prods
          THEN l_prod_where := '';
          ELSE l_prod_where := '
              AND fact.master_item_id   IN (&ITEM+ENI_ITEM)';
        END IF;

        IF l_all_custs THEN
            l_cust_where := '';
            l_cust_flag := 1;
        ELSE
            l_cust_where := '
              AND fact.customer_id      IN (&CUSTOMER+FII_CUSTOMERS)';
            l_cust_flag := 0;
        END IF;

        IF l_all_prods THEN
            IF l_all_prod_cats
            THEN l_item_cat_flag := 3; -- category
            ELSE l_item_cat_flag := 1; -- all
            END IF;
        ELSE
            l_item_cat_flag := 0; -- product
        END IF;

    END IF;

    l_stmt := '
 SELECT fii.name                                    VIEWBY
      , nvl(s.prev_booked_value, 0)                 ENI_MEASURE1 -- book prior
      , nvl(s.curr_booked_value, 0)                 ENI_MEASURE2 -- book
      , (s.curr_booked_value-s.prev_booked_value)
          / decode(s.prev_booked_value, 0, NULL,
               abs(s.prev_booked_value)) * 100      ENI_MEASURE3 -- book change
      , nvl(s.prev_fulfill_value, 0)                ENI_MEASURE4 -- fulf prior
      , nvl(s.curr_fulfill_value, 0)                ENI_MEASURE5 -- fulf
      , (s.curr_fulfill_value-s.prev_fulfill_value)
          / decode(s.prev_fulfill_value, 0, NULL,
               abs(s.prev_fulfill_value)) * 100     ENI_MEASURE6 -- fulf change
      , s.prev_booked_value
          / decode(s.prev_fulfill_value, 0, NULL,
               s.prev_fulfill_value)                ENI_MEASURE7 -- book to fulf r prior
      , s.curr_booked_value
          / decode(s.curr_fulfill_value, 0, NULL,
               s.curr_fulfill_value)                ENI_MEASURE8 -- book to fulf r
      , s.curr_booked_value
          / decode(s.curr_fulfill_value, 0, NULL,
               s.curr_fulfill_value) -
        s.prev_booked_value
          / decode(s.prev_fulfill_value, 0, NULL,
               s.prev_fulfill_value)                ENI_MEASURE9 -- book to fulf r change
   FROM (SELECT start_date                      START_DATE
              , sum(curr_booked_value)          CURR_BOOKED_VALUE
              , sum(prev_booked_value)          PREV_BOOKED_VALUE
              , sum(curr_fulfill_value)         CURR_FULFILL_VALUE
              , sum(prev_fulfill_value)         PREV_FULFILL_VALUE
       FROM
    (SELECT dates.start_date                                    START_DATE
          , fact.inv_org_id                                     INV_ORG
          , decode(dates.period, ''C'',
                nvl(fact.booked_amt_'||l_curr_suffix||',0), 0)  CURR_BOOKED_VALUE
          , decode(dates.period, ''P'',
                nvl(fact.booked_amt_'||l_curr_suffix||',0), 0)  PREV_BOOKED_VALUE
          , 0                                                   CURR_FULFILL_VALUE
          , 0                                                   PREV_FULFILL_VALUE
       FROM ( SELECT fii.start_date                                 START_DATE
                   , ''C''                                            PERIOD
                   , least(fii.end_date, &BIS_CURRENT_ASOF_DATE)    REPORT_DATE
              FROM '||l_period_type||' fii
              WHERE fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
                                       AND &BIS_CURRENT_ASOF_DATE
        UNION ALL
              SELECT p2.start_date                                  START_DATE
                   , ''P''                                            PERIOD
                   , p1.report_date                                 REPORT_DATE
         FROM (SELECT
                       least(fii.end_date, &BIS_PREVIOUS_ASOF_DATE) REPORT_DATE,
                rownum          ID
               FROM '||l_period_type||' fii
              WHERE fii.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE
                                       AND &BIS_PREVIOUS_ASOF_DATE
              ORDER BY fii.start_date DESC ) p1,
            (SELECT fii.start_date      START_DATE,
                rownum          ID
               FROM '||l_period_type||' fii
              WHERE fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
                                       AND &BIS_CURRENT_ASOF_DATE
              ORDER BY fii.start_date DESC ) p2
         WHERE p1.id(+) = p2.id
         )                              dates
      , '||l_mv1||'                     fact
      , FII_TIME_RPT_STRUCT             cal'||l_prod_cat_from||'
      WHERE cal.report_date = dates.report_date
            AND fact.time_id = cal.time_id
            AND fact.period_type_id = cal.period_type_id'
            ||l_flags_where||'
            AND bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id'
            ||l_prod_cat_where
            ||l_prod_where
            ||l_cust_where||'
    UNION ALL
     SELECT dates.start_date            START_DATE
          , fact.inv_org_id             INV_ORG
          , 0                           CURR_BOOKED_VALUE
          , 0                           PREV_BOOKED_VALUE
          , decode(dates.period, ''C'',
                nvl(fact.fulfilled_amt_'||l_curr_suffix||',0), 0)   CURR_FULFILL_VALUE
          , decode(dates.period, ''P'',
                nvl(fact.fulfilled_amt_'||l_curr_suffix||',0), 0)   PREV_FULFILL_VALUE
       FROM ( SELECT fii.start_date                                 START_DATE
                   , ''C''                                            PERIOD
                   , least(fii.end_date, &BIS_CURRENT_ASOF_DATE)    REPORT_DATE
              FROM '||l_period_type||' fii
              WHERE fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
                                       AND &BIS_CURRENT_ASOF_DATE
        UNION ALL
              SELECT p2.start_date                                  START_DATE
                   , ''P''                                            PERIOD
                   , p1.report_date                                 REPORT_DATE
         FROM (SELECT
                       least(fii.end_date, &BIS_PREVIOUS_ASOF_DATE) REPORT_DATE
                   , rownum                                         ID
               FROM '||l_period_type||' fii
              WHERE fii.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE
                                       AND &BIS_PREVIOUS_ASOF_DATE
              ORDER BY fii.start_date DESC ) p1,
            (SELECT fii.start_date                                  START_DATE
                   , rownum                                         ID
               FROM '||l_period_type||' fii
              WHERE fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
                                       AND &BIS_CURRENT_ASOF_DATE
              ORDER BY fii.start_date DESC ) p2
         WHERE p1.id(+) = p2.id
         )                              dates
       , '||l_mv2||'             fact
       , FII_TIME_RPT_STRUCT           cal'||l_prod_cat_from||'
      WHERE cal.report_date = dates.report_date
            AND fact.time_id = cal.time_id
            AND fact.period_type_id = cal.period_type_id'
            ||l_flags_where||'
            AND fact.return_flag = 0
            AND bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id'
            ||l_prod_cat_where
            ||l_prod_where
            ||l_cust_where||' )
      -- WHERE '||l_inv_org_where||'
    GROUP BY start_date)        s,
    '||l_period_type||'     fii
  WHERE fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
               AND &BIS_CURRENT_ASOF_DATE
    AND fii.start_date = s.start_date(+)
ORDER BY fii.start_date ' || l_order_by;
-- || ' -- CURR: ' || l_curr;

    x_custom_sql := l_stmt;

    l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

    l_custom_rec.attribute_name       := ':ENI_ITEM_CAT_FLAG';
    l_custom_rec.attribute_value      := to_char(l_item_cat_flag);
    l_custom_rec.attribute_type       := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type  := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(1) := l_custom_rec;

    l_custom_rec.attribute_name       := ':ENI_CUST_FLAG';
    l_custom_rec.attribute_value      := to_char(l_cust_flag);
    l_custom_Rec.attribute_type       := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type  := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.extend;
    x_custom_output(2) := l_custom_rec;

END Get_Sql;

END ENI_DBI_FPT_PKG;

/
