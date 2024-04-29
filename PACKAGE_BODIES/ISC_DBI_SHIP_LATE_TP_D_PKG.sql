--------------------------------------------------------
--  DDL for Package Body ISC_DBI_SHIP_LATE_TP_D_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_SHIP_LATE_TP_D_PKG" AS
/* $Header: ISCRG91B.pls 120.1 2006/06/22 07:14:54 abhdixi noship $ */

PROCEDURE GET_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,x_custom_sql OUT NOCOPY VARCHAR2,
	x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS


  l_stmt 		VARCHAR2(32000);
  l_org 		VARCHAR2(32000);
  l_org_where     	VARCHAR2(32000);
  l_item		VARCHAR2(32000);
  l_item_where		VARCHAR2(32000);
  l_inv_cat		VARCHAR2(32000);
  l_inv_cat_where	VARCHAR2(32000);
  l_cust		VARCHAR2(32000);
  l_cust_where		VARCHAR2(32000);
  l_lang		VARCHAR2(10);
  l_late_promise_flag	NUMBER :=1;
  l_custom_rec 		BIS_QUERY_ATTRIBUTES ;

BEGIN

  l_lang := userenv('LANG');

  FOR i IN 1..p_param.COUNT
  LOOP

    IF(p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION')
      THEN l_org :=  p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_INV_CAT') THEN
       l_inv_cat :=  p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_ORG') THEN
       l_item :=  p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'CUSTOMER+FII_CUSTOMERS') THEN
       l_cust :=  p_param(i).parameter_value;
    END IF;

  END LOOP;


  IF ( l_org IS NULL OR l_org = 'All' ) THEN
    l_org_where := '
	AND (EXISTS
		(SELECT 1
		FROM org_access o
		WHERE o.responsibility_id = fnd_global.resp_id
		AND o.resp_application_id = fnd_global.resp_appl_id
		AND o.organization_id = f.inv_org_id)
		OR EXISTS
		(SELECT 1
		FROM mtl_parameters org
		WHERE org.organization_id = f.inv_org_id
		AND NOT EXISTS
			(SELECT 1
			FROM org_access ora
			WHERE org.organization_id = ora.organization_id)))';

  ELSE
    l_org_where := '
  	    AND f.inv_org_id = &ORGANIZATION+ORGANIZATION';
  END IF;

  IF ( l_inv_cat IS NULL OR l_inv_cat = 'All' ) THEN
    l_inv_cat_where :='';
  ELSE
    l_inv_cat_where := '
	AND f.item_category_id in (&ITEM+ENI_ITEM_INV_CAT)';
  END IF;

  IF ( l_item IS NULL OR l_item = 'All' ) THEN
    l_item_where :='';
  ELSE
    l_item_where := '
	AND f.item_id in (&ITEM+ENI_ITEM_ORG)';
  END IF;

  IF (l_cust IS NULL OR l_cust = 'All') THEN
    l_cust_where:='';
  ELSE
    l_cust_where :='
	AND f.customer_id in (&CUSTOMER+FII_CUSTOMERS)';
  END IF;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

   l_stmt := 'SELECT ISC_ATTRIBUTE_2,
		ISC_MEASURE_1,
		org.name	ISC_ATTRIBUTE_5,
		cust.value  	ISC_ATTRIBUTE_3,
		ISC_ATTRIBUTE_4,
		ISC_MEASURE_2,ISC_MEASURE_3
		FROM (select (rank() over (&ORDER_BY_CLAUSE nulls last,ISC_MEASURE_3,ISC_MEASURE_1)) - 1 rnk,
		customer_id,
		inv_org_id,
		ISC_ATTRIBUTE_2,ISC_ATTRIBUTE_4,ISC_MEASURE_1,
		ISC_MEASURE_2,ISC_MEASURE_3
		FROM(select customer_id,
		inv_org_id,
		order_number				ISC_ATTRIBUTE_2,
		time_shipped_date_id			ISC_ATTRIBUTE_4,
		line_number				ISC_MEASURE_1,
		days_late_promise			ISC_MEASURE_2,
		header_id				ISC_MEASURE_3
		FROM ISC_DBI_FM_0003_MV f
		WHERE f.time_shipped_date_id between
		&BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE
		AND f.late_promise_flag = :ISC_LATE_PROMISE_FLAG'
		||l_org_where||l_inv_cat_where||l_item_where||l_cust_where||')) a,
		FII_CUSTOMERS_V		cust,
		HR_ALL_ORGANIZATION_UNITS_TL org
  		WHERE a.customer_id = cust.id
		AND a.inv_org_id = org.organization_id
		AND org.language = :ISC_LANG
		AND ((a.rnk between &START_INDEX and &END_INDEX) OR(&END_INDEX = -1))
		ORDER BY rnk';

  x_custom_sql := l_stmt;

  l_custom_rec.attribute_name := ':ISC_LATE_PROMISE_FLAG';
  l_custom_rec.attribute_value := to_char(l_late_promise_flag);
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_LANG';
  l_custom_rec.attribute_value := l_lang;
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

END get_sql;

END ISC_DBI_SHIP_LATE_TP_D_PKG ;


/
