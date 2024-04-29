--------------------------------------------------------
--  DDL for Package Body ENI_DBI_RVT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_RVT_PKG" AS
/* $Header: ENIRVTPB.pls 120.0 2005/05/26 19:32:38 appldev noship $ */

PROCEDURE GET_SQL( p_param          IN          BIS_PMV_PAGE_PARAMETER_TBL
                 , x_custom_sql     OUT NOCOPY  VARCHAR2
                 , x_custom_output  OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL ) IS

  l_stmt                VARCHAR2(32000);
  l_flags_where         VARCHAR2(1000);
  l_org                 VARCHAR2(32000);
  l_org_where           VARCHAR2(32000);
  l_prod                VARCHAR2(32000);
  l_prod_where          VARCHAR2(32000);
  l_prod_cat            VARCHAR2(32000);
  l_prod_cat_from       VARCHAR2(32000);
  l_prod_cat_where      VARCHAR2(32000);
  l_cust                VARCHAR2(32000);
  l_cust_where          VARCHAR2(32000);
  l_ret_reason          VARCHAR2(32000);
  l_ret_reason_where    VARCHAR2(32000);
  l_period_type         VARCHAR2(32000);
  l_temp                VARCHAR2(480);
  l_sql_stmt            VARCHAR2(32000);

  l_curr_suffix         VARCHAR2(10);

  l_item_cat_flag       NUMBER; -- 0 for product, 1 for product category, 3 for no grouping on item dimension
  l_cust_flag           NUMBER; -- 0 for customer and 1 for no customer selected
  l_reason_flag         NUMBER; -- 0 for reason and 1 for all reasons
  l_mv                  VARCHAR2(10);
  l_custom_rec          BIS_QUERY_ATTRIBUTES;

  l_all_prods           BOOLEAN;
  l_all_prod_cats       BOOLEAN;
  l_all_custs           BOOLEAN;
  l_all_reasons         BOOLEAN;

  l_time_comp_type      VARCHAR2(32000);
  l_time_comp_where     VARCHAR2(32000);

  l_order_by            VARCHAR2(200);
  l_period_id_col       VARCHAR2(100);
  l_period_diff         NUMBER;
BEGIN

    FOR i IN 1..p_param.COUNT LOOP
        CASE p_param(i).parameter_name
            WHEN 'PERIOD_TYPE'                                        THEN l_period_type    := p_param(i).parameter_value;
            WHEN 'ITEM+ENI_ITEM_VBH_CAT'                              THEN l_prod_cat       := p_param(i).parameter_value;
            WHEN 'ITEM+ENI_ITEM'                                      THEN l_prod           := p_param(i).parameter_value;
            WHEN 'CUSTOMER+FII_CUSTOMERS'                             THEN l_cust           := p_param(i).parameter_value;
            WHEN 'ORDER_ITEM_RETURN_REASON+ORDER_ITEM_RETURN_REASON'  THEN l_ret_reason     := p_param(i).parameter_id;
            WHEN 'ORDERBY'                                            THEN l_order_by       := p_param(i).parameter_value;
            WHEN 'TIME_COMPARISON_TYPE'                               THEN l_time_comp_type := p_param(i).parameter_value;
            WHEN 'CURRENCY+FII_CURRENCIES'                            THEN
                l_curr_suffix :=
                    CASE p_param(i).parameter_id
                        WHEN eni_dbi_util_pkg.get_curr_prim THEN 'g'    -- primary global currency
                        WHEN eni_dbi_util_pkg.get_curr_sec  THEN 'g1'   -- secondary global currency
                        ELSE 'f'                                        -- functional currency
                    END;
            ELSE NULL;
        END CASE;
    END LOOP;

    l_all_prods       := (l_prod        IS NULL OR l_prod       = '' OR l_prod       = 'All');
    l_all_prod_cats   := (l_prod_cat    IS NULL OR l_prod_cat   = '' OR l_prod_cat   = 'All');
    l_all_custs       := (l_cust        IS NULL OR l_cust       = '' OR l_cust       = 'All');
    l_all_reasons     := (l_ret_reason  IS NULL OR l_ret_reason = '' OR l_ret_reason = 'All');

    IF(   /* l_all_prod_cats
      AND */ l_all_prods
      AND l_all_custs
      AND l_all_reasons )
    THEN
        l_mv := '011';
        l_flags_where := '
            AND fact.inv_org_flag       = 1
            AND fact.return_flag        = 1';
            -- look at return rollups across all inv_org_ids

        IF l_all_prod_cats THEN
            l_prod_cat_where := '
            AND fact.top_node_flag      = ''Y'' ';      -- no cat specified, so examine top nodes only
        ELSE
            l_prod_cat_where := '
            AND fact.parent_id          IN (&ITEM+ENI_ITEM_VBH_CAT)'; -- cat specified
        END IF;
    ELSE
        /* Seems like there's no reason to use anything but 007 in this case */
        l_mv := '007';
        l_flags_where := '
            AND fact.item_cat_flag      = :ENI_ITEM_CAT_FLAG
            AND fact.customer_flag      = :ENI_CUST_FLAG
            AND fact.return_reason_flag = :ENI_REASON_FLAG';

        IF l_all_prod_cats THEN
            l_prod_cat_from := '';
            l_prod_cat_where := '';
        ELSE
            l_prod_cat_from := '
                , ENI_DENORM_HIERARCHIES      eni_cat
                , MTL_DEFAULT_CATEGORY_SETS   mdcs';
            l_prod_cat_where := '
            AND NVL( fact.item_category_id(+), -1 ) = eni_cat.child_id
            AND eni_cat.parent_id       IN (&ITEM+ENI_ITEM_VBH_CAT)
            AND eni_cat.dbi_flag        = ''Y''
            AND eni_cat.object_type     = ''CATEGORY_SET''
            AND eni_cat.object_id       = mdcs.category_set_id
            AND mdcs.functional_area_id = 11';
        END IF;

        IF l_all_prods THEN
            l_prod_where := '';
        ELSE
            l_prod_where := '
            AND fact.master_item_id     IN (&ITEM+ENI_ITEM)';
        END IF;

        IF l_all_custs THEN
          l_cust_where:='';
          l_cust_flag := 1; -- all customers
        ELSE
          l_cust_where :='
            AND fact.customer_id        IN (&CUSTOMER+FII_CUSTOMERS)';
          l_cust_flag := 0; -- customer selected
        END IF;

        l_item_cat_flag :=
            CASE
                WHEN ( l_all_prods AND l_all_prod_cats )        THEN 3 -- all
                WHEN ( l_all_prods AND NOT l_all_prod_cats )    THEN 1 -- category
                ELSE                                                 0 -- product
            END;

        IF l_all_reasons THEN
          l_reason_flag := 1;
        ELSE
          l_reason_flag := 0;
          l_ret_reason_where := '
            AND fact.return_reason      IN (&ORDER_ITEM_RETURN_REASON+ORDER_ITEM_RETURN_REASON)';
        END IF;
    END IF;

    -- The standard is that trend reports are only sortable by time ...
    l_order_by := 'ORDER BY t.'
                  || CASE
                         WHEN ( instr( l_order_by, 'DESC' ) <> 0 ) THEN 'start_date DESC'
                         ELSE 'start_date ASC'
                     END;
    /* TODO: Make the util package incorporate the above in an understandable/commented way */

    IF ('SEQUENTIAL' = l_time_comp_type)    THEN
        l_time_comp_where := 'p.end_date (+) = c.start_date - 1';
    ELSE
        CASE l_period_type
            WHEN 'FII_TIME_WEEK'        THEN
                l_period_id_col := 'week_id';
                l_period_diff   := 10000;
            WHEN 'FII_TIME_ENT_PERIOD'  THEN
                l_period_id_col := 'ent_period_id';
                l_period_diff   := 1000;
            WHEN 'FII_TIME_ENT_QTR'     THEN
                l_period_id_col := 'ent_qtr_id';
                l_period_diff   := 10;
            WHEN 'FII_TIME_ENT_YEAR'    THEN
                l_period_id_col := 'ent_year_id';
                l_period_diff   := 1;
        END CASE;
        l_time_comp_where := 'p.'||l_period_id_col||' (+) = c.'||l_period_id_col||' - '||l_period_diff;
    END IF;

    l_stmt := '
SELECT  t.name                                    VIEWBY
      , s.cur_return_amt                            ENI_MEASURE1 -- curr return value
      , s.pre_return_amt                            ENI_MEASURE2 -- prev return value
      , (s.cur_return_amt - s.pre_return_amt)
          / decode( s.pre_return_amt,0, NULL,
                    abs(s.pre_return_amt)) * 100    ENI_MEASURE3 -- return value change
  FROM ( SELECT dates.start_date                                            START_DATE
              , sum(decode(dates.period, ''C'', fact.returned_amt_'||l_curr_suffix||', 0))      CUR_RETURN_AMT
              , sum(decode(dates.period, ''P'', fact.returned_amt_'||l_curr_suffix||', 0))      PRE_RETURN_AMT
         FROM ( SELECT c.start_date                                       START_DATE
                     , ''C''                                                  PERIOD
                     , least(c.end_date, &BIS_CURRENT_ASOF_DATE)          REPORT_DATE
                    FROM '||l_period_type||' c
                    WHERE c.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
                                             AND &BIS_CURRENT_ASOF_DATE
                UNION ALL
                SELECT c.start_date                                         START_DATE
                     , ''P''                                                  PERIOD
                     , least(p.end_date, &BIS_PREVIOUS_ASOF_DATE)           REPORT_DATE
                  FROM '||l_period_type||' p, '||l_period_type||' c
                  WHERE ( p.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE
                                           AND &BIS_PREVIOUS_ASOF_DATE )
                    AND ( c.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
                                           AND &BIS_CURRENT_ASOF_DATE )
                    AND '||l_time_comp_where||'
              )                             dates
            , ISC_DBI_CFM_'||l_mv||'_MV       fact
            , FII_TIME_RPT_STRUCT           cal'
            ||l_prod_cat_from||'
        WHERE   cal.report_date = dates.report_date
            AND bitand( cal.record_type_id, &BIS_NESTED_PATTERN ) = cal.record_type_id
            AND fact.time_id = cal.time_id
            AND fact.period_type_id = cal.period_type_id'
    ||l_flags_where||l_org_where||l_prod_cat_where||l_prod_where||l_cust_where||l_ret_reason_where||'
        GROUP BY dates.start_date )    s
      , '||l_period_type||'         t
  WHERE t.start_date = s.start_date(+)
    AND t.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
                         AND &BIS_CURRENT_ASOF_DATE
  ' || l_order_by;

  l_custom_rec      := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output   := BIS_QUERY_ATTRIBUTES_TBL();
  x_custom_sql      := l_stmt;

  l_custom_rec.attribute_name   := ':ENI_ITEM_CAT_FLAG';
  l_custom_rec.attribute_value  := to_char( l_item_cat_flag );
  l_custom_rec.attribute_type   := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name   := ':ENI_CUST_FLAG';
  l_custom_rec.attribute_value  := to_char( l_cust_flag );
  l_custom_Rec.attribute_type   := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name   := ':ENI_REASON_FLAG';
  l_custom_rec.attribute_value  := to_char( l_reason_flag );
  l_custom_Rec.attribute_type   := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

END get_sql;

END ENI_DBI_RVT_PKG ;


/
