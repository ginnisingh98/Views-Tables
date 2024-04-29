--------------------------------------------------------
--  DDL for Package Body ISC_DBI_BACKORDER_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_BACKORDER_DETAIL_PKG" AS
/* $Header: ISCRGAXB.pls 120.0 2005/05/25 17:22:25 appldev noship $ */


PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS


  l_sql_stmt 			VARCHAR2(10000);
  l_stmt 			VARCHAR2(10000);
  l_outer_sql			VARCHAR2(10000);
  l_inv_org 			VARCHAR2(10000);
  l_inv_org_where     		VARCHAR2(10000);
  l_item			VARCHAR2(10000);
  l_item_where			VARCHAR2(10000);
  l_inv_cat			VARCHAR2(10000);
  l_inv_cat_where		VARCHAR2(10000);
  l_cust			VARCHAR2(10000);
  l_cust_where			VARCHAR2(10000);
  l_lang			VARCHAR2(10);
  l_custom_rec			BIS_QUERY_ATTRIBUTES;

BEGIN

  FOR i IN 1..p_param.COUNT
  LOOP

    IF(p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION')
      THEN l_inv_org :=  p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_INV_CAT')
      THEN l_inv_cat :=  p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_ORG')
      THEN l_item :=  p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'CUSTOMER+FII_CUSTOMERS')
      THEN l_cust :=  p_param(i).parameter_value;
    END IF;

  END LOOP;

  IF(l_inv_org IS NULL OR l_inv_org = 'All')
    THEN l_inv_org_where :=  '
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
    ELSE l_inv_org_where :=  '
    AND mv.inv_org_id = &ORGANIZATION+ORGANIZATION';
  END IF;

  IF(l_inv_cat IS NULL OR l_inv_cat = 'All')
    THEN l_inv_cat_where := '';
    ELSE l_inv_cat_where := '
    AND mv.item_category_id IN (&ITEM+ENI_ITEM_INV_CAT)';
  END IF;

  IF(l_item IS NULL OR l_item = 'All')
    THEN l_item_where := '';
    ELSE l_item_where := '
    AND mv.item_id IN (&ITEM+ENI_ITEM_ORG)';
  END IF;

  IF (l_cust IS NULL OR l_cust = 'All')
    THEN l_cust_where :='';
    ELSE l_cust_where :='
    AND mv.customer_id IN (&CUSTOMER+FII_CUSTOMERS)';
  END IF;

  l_lang := USERENV('LANG');

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  l_outer_sql:= 'ISC_ATTRIBUTE_1, ISC_ATTRIBUTE_2, ISC_ATTRIBUTE_7, ISC_ATTRIBUTE_8,
	ISC_MEASURE_1, ISC_MEASURE_2, ISC_MEASURE_3, ISC_MEASURE_4';

  l_sql_stmt := 'SELECT	mv.customer_id				CUSTOMER_ID,
		mv.inv_org_id				INV_ORG_ID,
		mv.item_id				ITEM_ID,
		mv.uom					UOM,
		mv.order_number				ISC_ATTRIBUTE_1, -- Order Number
		mv.line_number				ISC_ATTRIBUTE_2, -- Line Number
		mv.time_request_date_id			ISC_ATTRIBUTE_7, -- Request Date
		mv.time_schedule_date_id		ISC_ATTRIBUTE_8, -- Schedule Date
		mv.backorder_qty			ISC_MEASURE_1, -- Backordered Quantity
		mv.days_late_request			ISC_MEASURE_2, -- Days Late to Request
		mv.days_late_schedule			ISC_MEASURE_3, -- Days Late to Schedule
		mv.header_id				ISC_MEASURE_4 -- Header ID
   	   FROM	ISC_DBI_FM_0007_MV	mv,
		(SELECT max(time_snapshot_date_id)	DAY
	  	  FROM	ISC_DBI_FM_0007_MV		mv
		  WHERE	mv.time_snapshot_date_id BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE
						     AND &BIS_CURRENT_ASOF_DATE
		)			a
 	  WHERE	mv.time_snapshot_date_id = a.day'
	||l_inv_org_where||l_cust_where||l_inv_cat_where||l_item_where;

  l_stmt := '
SELECT	ISC_ATTRIBUTE_1, ISC_ATTRIBUTE_2,
	org.name		ISC_ATTRIBUTE_9,
	cust.value		ISC_ATTRIBUTE_3, -- Customer
	items.value		ISC_ATTRIBUTE_4, -- Item
	items.description	ISC_ATTRIBUTE_5, -- Description
	mtl.unit_of_measure	ISC_ATTRIBUTE_6, -- UOM
	ISC_MEASURE_1, ISC_ATTRIBUTE_7, ISC_ATTRIBUTE_8, ISC_MEASURE_2, ISC_MEASURE_3, ISC_MEASURE_4
  FROM (SELECT (rank() over (&ORDER_BY_CLAUSE NULLS LAST, isc_measure_4, isc_attribute_2))-1 RNK,
	customer_id, item_id, uom, inv_org_id,
	'||l_outer_sql||'
   FROM ('||l_sql_stmt||')
	)			c,
	FII_CUSTOMERS_V		cust,
	ENI_ITEM_ORG_V		items,
	MTL_UNITS_OF_MEASURE_TL mtl,
	HR_ALL_ORGANIZATION_UNITS_TL org
  WHERE	c.customer_id = cust.id
    AND c.item_id = items.id
    AND c.uom = mtl.uom_code
    AND mtl.language = :ISC_LANG
    AND c.inv_org_id = org.organization_id
    AND	org.language = :ISC_LANG
    AND	((c.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
  ORDER BY rnk';

  x_custom_sql := l_stmt;

  l_custom_rec.attribute_name := ':ISC_LANG';
  l_custom_rec.attribute_value := l_lang;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

END Get_Sql;

END ISC_DBI_BACKORDER_DETAIL_PKG ;


/
