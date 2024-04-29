--------------------------------------------------------
--  DDL for Package Body ISC_DBI_RETURN_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_RETURN_DETAIL_PKG" AS
/* $Header: ISCRGAEB.pls 120.1 2005/10/17 12:33:42 hprathur noship $ */


PROCEDURE GET_SQL( p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
		   x_custom_sql		OUT NOCOPY	VARCHAR2,
		   x_custom_output 	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt 		VARCHAR2(32000);
  l_measures		VARCHAR2(32000);
  l_org 		VARCHAR2(32000);
  l_org_where		VARCHAR2(32000);
  l_prod		VARCHAR2(32000);
  l_prod_where		VARCHAR2(32000);
  l_prod_cat		VARCHAR2(32000);
  l_prod_cat_from	VARCHAR2(32000);
  l_prod_cat_where	VARCHAR2(32000);
  l_ret_reason		VARCHAR2(32000);
  l_ret_reason_where	VARCHAR2(32000);
  l_cust		VARCHAR2(32000);
  l_cust_where		VARCHAR2(32000);
  l_lang		VARCHAR2(10);
  l_g_currency		VARCHAR2(15) := '''FII_GLOBAL1''';
  l_g1_currency		VARCHAR2(15) := '''FII_GLOBAL2''';
  l_currency		VARCHAR2(20);
  l_return_amt		VARCHAR2(20);
  l_custom_rec		BIS_QUERY_ATTRIBUTES;

BEGIN

  l_lang := userenv('LANG');

  FOR i IN 1..p_param.COUNT
  LOOP

    IF(p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION')
      THEN l_org := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_VBH_CAT')
      THEN l_prod_cat := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_ORG')
      THEN l_prod := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'CUSTOMER+FII_CUSTOMERS')
      THEN l_cust := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES')
      THEN l_currency := p_param(i).parameter_id;
    END IF;

    IF(p_param(i).parameter_name = 'ORDER_ITEM_RETURN_REASON+ORDER_ITEM_RETURN_REASON')
      THEN l_ret_reason := p_param(i).parameter_id;
    END IF;

  END LOOP;

  IF(l_currency = l_g_currency)
    THEN l_return_amt := 'returned_amt_g';
    ELSIF (l_currency = l_g1_currency)
      THEN l_return_amt := 'returned_amt_g1';
    ELSE l_return_amt := 'returned_amt_f';
  END IF;


  IF (l_org IS NULL OR l_org = '' OR l_org = 'All')
    THEN l_org_where := '
	    AND (EXISTS
		(SELECT 1
		   FROM org_access o
		  WHERE o.responsibility_id = fnd_global.resp_id
		    AND o.resp_application_id = fnd_global.resp_appl_id
		    AND o.organization_id = mv.inv_org_id)
		OR EXISTS
		(SELECT 1
		   FROM mtl_parameters org
		  WHERE org.organization_id = mv.inv_org_id
		    AND NOT EXISTS
			(SELECT 1
			   FROM org_access ora
			  WHERE org.organization_id = ora.organization_id)))';
    ELSE l_org_where := '
	    AND mv.inv_org_id = &ORGANIZATION+ORGANIZATION';
  END IF;

  IF (l_prod_cat IS NULL OR l_prod_cat = '' OR l_prod_cat = 'All')
    THEN
      l_prod_cat_from := '';
      l_prod_cat_where := '';
    ELSE
      l_prod_cat_from := ',
		ENI_DENORM_HIERARCHIES		eni_cat,
		MTL_DEFAULT_CATEGORY_SETS	mdcs';
      l_prod_cat_where := '
	    AND mv.item_category_id = eni_cat.child_id
	    AND eni_cat.parent_id IN (&ITEM+ENI_ITEM_VBH_CAT)
	    AND	eni_cat.dbi_flag = ''Y''
	    AND eni_cat.object_type = ''CATEGORY_SET''
	    AND eni_cat.object_id = mdcs.category_set_id
	    AND	mdcs.functional_area_id = 11';
  END IF;

  IF ( l_prod IS NULL OR l_prod = '' OR l_prod = 'All' )
    THEN l_prod_where := '';
    ELSE l_prod_where := '
	    AND mv.item_id IN (&ITEM+ENI_ITEM_ORG)';
  END IF;

  IF (l_cust IS NULL OR l_cust = '' OR l_cust = 'All')
    THEN l_cust_where := '';
    ELSE l_cust_where := '
	    AND mv.customer_id IN (&CUSTOMER+FII_CUSTOMERS)';
  END IF;

  IF ( l_ret_reason IS NULL OR l_ret_reason = '' OR l_ret_reason = 'All' )
    THEN l_ret_reason_where := '';
    ELSE l_ret_reason_where := '
	    AND mv.return_reason IN (&ORDER_ITEM_RETURN_REASON+ORDER_ITEM_RETURN_REASON)';
  END IF;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

   l_stmt := '
 SELECT	ISC_ATTRIBUTE_7,ISC_ATTRIBUTE_3, ISC_ATTRIBUTE_4,
	org.name						ISC_ATTRIBUTE_8,
	cust.value						ISC_ATTRIBUTE_5,
	ISC_ATTRIBUTE_6,  ISC_MEASURE_1, ISC_MEASURE_2
   FROM
(SELECT	(rank() over (&ORDER_BY_CLAUSE, isc_attribute_7, isc_attribute_4)) - 1	rnk,
	customer_id,
	inv_org_id,
	ISC_ATTRIBUTE_3, ISC_ATTRIBUTE_4, ISC_ATTRIBUTE_6, ISC_ATTRIBUTE_7,
	ISC_MEASURE_1, ISC_MEASURE_2
   FROM
(SELECT	mv.customer_id						CUSTOMER_ID,
	mv.inv_org_id						INV_ORG_ID,
	mv.order_number						ISC_ATTRIBUTE_3,
	mv.line_number						ISC_ATTRIBUTE_4,
	mv.time_fulfilled_date_id				ISC_ATTRIBUTE_6,
	mv.header_id						ISC_ATTRIBUTE_7,
	mv.'||l_return_amt||'					ISC_MEASURE_1,
	sum(mv.'||l_return_amt||') over()			ISC_MEASURE_2
   FROM ISC_DBI_CFM_003_MV	mv'
	||l_prod_cat_from||'
  WHERE mv.time_fulfilled_date_id BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE
				      AND &BIS_CURRENT_ASOF_DATE'
	||l_org_where
	||l_prod_cat_where
	||l_prod_where
	||l_cust_where
	||l_ret_reason_where||'))	a,
	FII_CUSTOMERS_V			cust,
	HR_ALL_ORGANIZATION_UNITS_TL	org
  WHERE	a.customer_id = cust.id
    AND a.inv_org_id = org.organization_id
    AND org.language = :ISC_LANG
    AND ((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
  ORDER BY rnk';

  x_custom_sql := l_stmt;

  l_custom_rec.attribute_name := ':ISC_LANG';
  l_custom_rec.attribute_value := l_lang;
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

END get_sql;

END ISC_DBI_RETURN_DETAIL_PKG ;


/
