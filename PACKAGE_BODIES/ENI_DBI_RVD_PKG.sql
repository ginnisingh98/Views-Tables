--------------------------------------------------------
--  DDL for Package Body ENI_DBI_RVD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_DBI_RVD_PKG" AS
/* $Header: ENIRVDPB.pls 120.0 2005/05/26 19:35:51 appldev noship $ */

PROCEDURE GET_SQL( p_param          IN          BIS_PMV_PAGE_PARAMETER_TBL
                 , x_custom_sql     OUT NOCOPY  VARCHAR2
                 , x_custom_output  OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL ) IS

  l_stmt            VARCHAR2(32000);
  l_measures        VARCHAR2(32000);
  l_org             VARCHAR2(32000);
  l_org_where       VARCHAR2(32000);
  l_prod            VARCHAR2(32000);
  l_prod_where      VARCHAR2(32000);
  l_prod_cat        VARCHAR2(32000);
  l_prod_cat_from   VARCHAR2(32000);
  l_prod_cat_where  VARCHAR2(32000);
  l_ret_reason      VARCHAR2(32000);
  l_ret_reason_where    VARCHAR2(32000);
  l_cust            VARCHAR2(32000);
  l_cust_where      VARCHAR2(32000);
  l_lang            VARCHAR2(10);

--  l_curr            VARCHAR2(15) := 'NOT PASSED IN';
  l_curr_suffix     VARCHAR2(10);

  l_all_prods       BOOLEAN;
  l_all_prod_cats   BOOLEAN;
  l_all_custs       BOOLEAN;
  l_all_reasons     BOOLEAN;

--  l_custom_rec      BIS_QUERY_ATTRIBUTES;

BEGIN

    l_lang := userenv('LANG');

    FOR i IN 1..p_param.COUNT LOOP
        CASE p_param(i).parameter_name
            WHEN 'ITEM+ENI_ITEM_VBH_CAT'            THEN l_prod_cat   := p_param(i).parameter_value;
            WHEN 'ITEM+ENI_ITEM'                    THEN l_prod       := p_param(i).parameter_value;
            WHEN 'CUSTOMER+FII_CUSTOMERS'           THEN l_cust       := p_param(i).parameter_value;
            WHEN 'CURRENCY+FII_CURRENCIES'          THEN
--                l_curr := p_param(i).parameter_id;
                l_curr_suffix :=
                    CASE p_param(i).parameter_id
                        WHEN eni_dbi_util_pkg.get_curr_prim() THEN 'g'    -- primary global currency
                        WHEN eni_dbi_util_pkg.get_curr_sec()  THEN 'g1'   -- secondary global currency
                        ELSE 'f'                       -- functional currency
                    END;
            WHEN 'ORDER_ITEM_RETURN_REASON+ORDER_ITEM_RETURN_REASON'  THEN l_ret_reason := p_param(i).parameter_id;
            ELSE null;
        END CASE;
    END LOOP;

    l_all_prods       := (l_prod        IS NULL OR l_prod       = '' OR l_prod       = 'All');
    l_all_prod_cats   := (l_prod_cat    IS NULL OR l_prod_cat   = '' OR l_prod_cat   = 'All');
    l_all_custs       := (l_cust        IS NULL OR l_cust       = '' OR l_cust       = 'All');
    l_all_reasons     := (l_ret_reason  IS NULL OR l_ret_reason = '' OR l_ret_reason = 'All');



  IF l_all_prod_cats THEN
      l_prod_cat_from  := '';
      l_prod_cat_where := '';
    ELSE
      l_prod_cat_from := ',
        ENI_DENORM_HIERARCHIES      eni_cat
      , MTL_DEFAULT_CATEGORY_SETS   mdcs';
      l_prod_cat_where := '
        AND mv.item_category_id = eni_cat.child_id
        AND eni_cat.parent_id   IN (&ITEM+ENI_ITEM_VBH_CAT)
        AND eni_cat.dbi_flag    = ''Y''
        AND eni_cat.object_type = ''CATEGORY_SET''
        AND eni_cat.object_id   = mdcs.category_set_id
        AND mdcs.functional_area_id = 11';
    END IF;

    IF l_all_prods THEN
        l_prod_where := '';
    ELSE l_prod_where := '
        AND mv.master_item_id   IN (&ITEM+ENI_ITEM)';
    END IF;

    IF l_all_custs THEN
        l_cust_where := '';
    ELSE l_cust_where := '
        AND mv.customer_id      IN (&CUSTOMER+FII_CUSTOMERS)';
    END IF;

    IF l_all_reasons THEN
        l_ret_reason_where := '';
    ELSE l_ret_reason_where := '
        AND mv.return_reason    IN (&ORDER_ITEM_RETURN_REASON+ORDER_ITEM_RETURN_REASON)';
    END IF;

--    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

    l_stmt := '
 SELECT ENI_ATTRIBUTE3
      , ENI_ATTRIBUTE4
      , cust.value  ENI_ATTRIBUTE5
      , ENI_ATTRIBUTE6
      , ENI_MEASURE1
      , ENI_MEASURE2
      , ENI_MEASURE3
   FROM
(SELECT (rank() over (&ORDER_BY_CLAUSE, ENI_ATTRIBUTE3, ENI_ATTRIBUTE4, inv_org_id)) - 1    rnk,
        customer_id
      , inv_org_id
      , ENI_ATTRIBUTE3
      , ENI_ATTRIBUTE4
      , ENI_ATTRIBUTE6
      , ENI_MEASURE1
      , ENI_MEASURE2
      , ENI_MEASURE3
   FROM
(SELECT mv.customer_id                                      CUSTOMER_ID
      , mv.inv_org_id                                       INV_ORG_ID
      , mv.order_number                                     ENI_ATTRIBUTE3
      , mv.header_id                                        ENI_MEASURE3
      , mv.line_number                                      ENI_ATTRIBUTE4
      , mv.time_fulfilled_date_id                           ENI_ATTRIBUTE6
      , mv.returned_amt_'||l_curr_suffix||'                 ENI_MEASURE1
      , sum(mv.returned_amt_'||l_curr_suffix||') over()     ENI_MEASURE2
   FROM ISC_DBI_CFM_003_MV  mv'
      ||l_prod_cat_from||'
  WHERE mv.time_fulfilled_date_id BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE
                                  AND     &BIS_CURRENT_ASOF_DATE'
    ||l_prod_cat_where
    ||l_prod_where
    ||l_cust_where
    ||l_ret_reason_where||'))   a
  , FII_CUSTOMERS_V             cust
  WHERE a.customer_id = cust.id
    AND ((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
  &ORDER_BY_CLAUSE NULLS LAST';
--  || '-- CURR:' || l_curr;

  x_custom_sql := l_stmt;

END get_sql;

END ENI_DBI_RVD_PKG ;


/
