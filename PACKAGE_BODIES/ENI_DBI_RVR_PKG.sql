--------------------------------------------------------
--  DDL for Package Body ENI_DBI_RVR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_RVR_PKG" AS
/* $Header: ENIRVRPB.pls 120.0 2005/05/26 19:38:06 appldev noship $ */

PROCEDURE GET_SQL( p_param          IN          BIS_PMV_PAGE_PARAMETER_TBL
                 , x_custom_sql     OUT NOCOPY  VARCHAR2
                 , x_custom_output  OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL) IS

  l_org                 VARCHAR2(32000);
  l_prod                VARCHAR2(32000);
  l_prod_where          VARCHAR2(32000);
  l_prod_cat            VARCHAR2(32000);
  l_prod_cat_from       VARCHAR2(32000);
  l_prod_cat_where      VARCHAR2(32000);
  l_cust                VARCHAR2(32000);
  l_cust_where          VARCHAR2(32000);
  l_ret_reason          VARCHAR2(32000);
  l_ret_reason_where    VARCHAR2(32000);
  l_item_cat_flag       NUMBER; -- 0 for product, 1 for product category, 3 for no grouping on item dimension
  l_cust_flag           NUMBER; -- 0 for customer and 1 for no customer selected

  l_curr_suffix         VARCHAR2(10);
--  l_curr                VARCHAR2(15) := 'NOT PASSED IN';

  l_custom_rec          BIS_QUERY_ATTRIBUTES ;
  -- l_open_url added for BUG 3730452
  l_open_url            VARCHAR2(2000);

  l_all_prods           BOOLEAN;
  l_all_prod_cats       BOOLEAN;
  l_all_custs           BOOLEAN;
  l_all_reasons         BOOLEAN;

BEGIN
    l_open_url          := '''pFunctionName=ENI_DBI_RVD_R&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''';

    FOR i IN 1..p_param.COUNT LOOP
        CASE p_param(i).parameter_name
            WHEN 'ITEM+ENI_ITEM_VBH_CAT'                              THEN l_prod_cat   := p_param(i).parameter_value;
            WHEN 'ITEM+ENI_ITEM'                                      THEN l_prod       := p_param(i).parameter_value;
            WHEN 'CUSTOMER+FII_CUSTOMERS'                             THEN l_cust       := p_param(i).parameter_value;
            WHEN 'ORDER_ITEM_RETURN_REASON+ORDER_ITEM_RETURN_REASON'  THEN l_ret_reason := p_param(i).parameter_id;
            WHEN 'CURRENCY+FII_CURRENCIES'                            THEN
--                l_curr        := p_param(i).parameter_id;
                l_curr_suffix :=
                    CASE p_param(i).parameter_id
                        WHEN eni_dbi_util_pkg.get_curr_prim THEN 'g'    -- primary global currency
                        WHEN eni_dbi_util_pkg.get_curr_sec  THEN 'g1'   -- secondary global currency
                        ELSE 'f'                                        -- functional currency
                    END;
            ELSE null;
        END CASE;
    END LOOP;

    l_all_prods       := (l_prod        IS NULL OR l_prod       = '' OR l_prod       = 'All');
    l_all_prod_cats   := (l_prod_cat    IS NULL OR l_prod_cat   = '' OR l_prod_cat   = 'All');
    l_all_custs       := (l_cust        IS NULL OR l_cust       = '' OR l_cust       = 'All');
    l_all_reasons     := (l_ret_reason  IS NULL OR l_ret_reason = '' OR l_ret_reason = 'All');

    IF l_all_prods THEN
        -- If item is not selected then set the prod where clause to null
        l_prod_where := '';

        -- Then check if prod category parameter is null as well
        IF l_all_prod_cats THEN

            -- If prod cat is null, set the prod_cat where clause to null
            -- and the item cat flag = 3
            l_prod_cat_from := '';
            l_prod_cat_where := '';
            l_item_cat_flag := 3; -- all categories

        ELSE
            -- If not null, then set the prod cat where clause
            -- and the prod cat flag = 1
            l_prod_cat_from := '
                , ENI_DENORM_HIERARCHIES          eni_cat
                , MTL_DEFAULT_CATEGORY_SETS       mdcs';
            l_prod_cat_where := '
              AND mv.item_category_id   = eni_cat.child_id
              AND eni_cat.parent_id     IN (&ITEM+ENI_ITEM_VBH_CAT)
              AND eni_cat.dbi_flag      = ''Y''
              AND eni_cat.object_type   = ''CATEGORY_SET''
              AND eni_cat.object_id     = mdcs.category_set_id
              AND mdcs.functional_area_id = 11';

            l_item_cat_flag := 1; -- a specific category
        END IF;
     ELSE -- When item is selected, set the where clause and the item cat flag
        l_prod_where := '
              AND mv.master_item_id     IN (&ITEM+ENI_ITEM)';
        l_item_cat_flag := 0; -- product
     END IF;

    -- Similarly when cust is not selected, set the where clause and the
    -- cust flag to 1 else 0
    IF l_all_custs
      THEN
        l_cust_where:= '';
        l_cust_flag := 1; -- all customers and not viewed by customer
      ELSE
        l_cust_where :='
              AND mv.customer_id        IN (&CUSTOMER+FII_CUSTOMERS)';
        l_cust_flag := 0; -- customer selected
    END IF;

    IF l_all_reasons
      THEN l_ret_reason_where := '';
      ELSE l_ret_reason_where := '
              AND mv.return_reason      IN (&ORDER_ITEM_RETURN_REASON+ORDER_ITEM_RETURN_REASON)';
    END IF;

    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

    x_custom_sql := '
   SELECT ret.value                             VIEWBY          -- return reason
        , ret.id                                VIEWBYID
        , c.prev_return                         ENI_MEASURE7    -- return value (prior)
        , c.curr_return                         ENI_MEASURE1    -- return value
        , (c.curr_return - c.prev_return)
            / decode(c.prev_return, 0, NULL,
                 abs(c.prev_return)) * 100      ENI_MEASURE2    -- change (return value),
        , c.curr_return
            / decode(sum(c.curr_return) over(), 0, NULL,
                 sum(c.curr_return) over())
            * 100                               ENI_MEASURE3    -- percent of total
        , c.lines_cnt                           ENI_MEASURE4    -- lines affected
        , (CASE WHEN c.lines_cnt IS NULL
                  OR c.lines_cnt = 0
          THEN NULL
          ELSE   '|| l_open_url ||' END) as     ENI_ATTRIBUTE2  -- drill for lines affected
        , sum(c.curr_return) over()             ENI_MEASURE5    -- grand total for return value
        , (sum(c.curr_return) over() - sum(c.prev_return) over())
            / decode(sum(c.prev_return) over(), 0, NULL,
                 abs(sum(c.prev_return) over()))
            * 100                               ENI_MEASURE6    -- grand total for return value change
        , sum(c.lines_cnt) over()               ENI_MEASURE8    -- grand total for lines affected
     FROM (SELECT mv.return_reason                                      REASON
                , sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
                    mv.returned_amt_' || l_curr_suffix || ', 0))                      CURR_RETURN
                , sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
                    mv.returned_amt_' || l_curr_suffix || ', 0))                      PREV_RETURN
                , sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
                    mv.lines_cnt, 0))                                   LINES_CNT
           FROM ISC_DBI_CFM_007_MV      mv
              , FII_TIME_RPT_STRUCT     cal'
              || l_prod_cat_from ||'
           WHERE  mv.time_id        = cal.time_id
              AND mv.period_type_id = cal.period_type_id
              AND bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id
              AND cal.report_date   IN (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
              AND mv.customer_flag  = :ENI_CUST_FLAG
              AND mv.item_cat_flag  = :ENI_ITEM_CAT_FLAG
              AND mv.return_reason_flag = 0'
              || l_prod_cat_where || l_prod_where || l_cust_where || l_ret_reason_where || '
           GROUP BY mv.return_reason )  c
       , BIS_ORDER_ITEM_RET_REASON_V ret
     WHERE c.reason = ret.id
--        &ORDER_BY_CLAUSE NULLS LAST';
--        &ORDER_BY_CLAUSE NULLS LAST -- '||l_curr;

    l_custom_rec.attribute_name     := ':ENI_ITEM_CAT_FLAG';
    l_custom_rec.attribute_value    := to_char(l_item_cat_flag);
    l_custom_rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.EXTEND;
    x_custom_output(1) := l_custom_rec;

    l_custom_rec.attribute_name     := ':ENI_CUST_FLAG';
    l_custom_rec.attribute_value    := to_char(l_cust_flag);
    l_custom_Rec.attribute_type     := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.EXTEND;
    x_custom_output(2) := l_custom_rec;

END get_sql;

END ENI_DBI_RVR_PKG;


/
