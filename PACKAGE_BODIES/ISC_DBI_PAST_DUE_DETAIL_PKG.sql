--------------------------------------------------------
--  DDL for Package Body ISC_DBI_PAST_DUE_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_PAST_DUE_DETAIL_PKG" AS
/* $Header: ISCRG76B.pls 120.1 2005/10/18 14:16:15 hprathur noship $ */


PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sql_stmt 			VARCHAR2(10000);
  l_stmt			VARCHAR2(10000);
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
  l_bucket			VARCHAR2(10000);
  l_low				NUMBER;
  l_high			NUMBER;
  l_bucket_low_where		VARCHAR2(10000);
  l_bucket_high_where		VARCHAR2(10000);
  l_bucket_rec			bis_bucket_pub.BIS_BUCKET_REC_TYPE;
  l_error_tbl			bis_utilities_pub.ERROR_TBL_TYPE;
  l_status			VARCHAR2(10000);

  l_custom_rec			BIS_QUERY_ATTRIBUTES;

BEGIN

  l_lang := userenv('LANG');

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

    IF(p_param(i).parameter_name = 'ISC_ATTRIBUTE_5')
      THEN l_bucket := p_param(i).parameter_id;
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

-- Retrieve record to get bucket ranges
  bis_bucket_pub.RETRIEVE_BIS_BUCKET('ISC_DBI_PAST_DUE', l_bucket_rec, l_status, l_error_tbl);

  IF (l_bucket IS NULL OR l_bucket = '')
    THEN l_low := NULL; l_high := NULL;
  ELSIF (l_bucket = 1)
    THEN l_low := l_bucket_rec.range1_low; l_high := l_bucket_rec.range1_high;
  ELSIF (l_bucket = 2)
    THEN l_low := l_bucket_rec.range2_low; l_high := l_bucket_rec.range2_high;
  ELSIF (l_bucket = 3)
    THEN l_low := l_bucket_rec.range3_low; l_high := l_bucket_rec.range3_high;
  ELSIF (l_bucket = 4)
    THEN l_low := l_bucket_rec.range4_low; l_high := l_bucket_rec.range4_high;
  ELSIF (l_bucket = 5)
    THEN l_low := l_bucket_rec.range5_low; l_high := l_bucket_rec.range5_high;
  ELSIF (l_bucket = 6)
    THEN l_low := l_bucket_rec.range6_low; l_high := l_bucket_rec.range6_high;
  ELSIF (l_bucket = 7)
    THEN l_low := l_bucket_rec.range7_low; l_high := l_bucket_rec.range7_high;
  ELSIF (l_bucket = 8)
    THEN l_low := l_bucket_rec.range8_low; l_high := l_bucket_rec.range8_high;
  ELSIF (l_bucket = 9)
    THEN l_low := l_bucket_rec.range9_low; l_high := l_bucket_rec.range9_high;
  ELSE
         l_low := l_bucket_rec.range10_low; l_high := l_bucket_rec.range10_high;
  END IF;

  IF (l_low IS NULL)
    THEN l_bucket_low_where := '';
    ELSE l_bucket_low_where := '
    AND mv.days_late >= :ISC_LOW';
  END IF;

  IF (l_high IS NULL)
    THEN l_bucket_high_where := '';
    ELSE l_bucket_high_where := '
    AND	mv.days_late < :ISC_HIGH';
  END IF;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  l_outer_sql:= 'ISC_ATTRIBUTE_2,ISC_ATTRIBUTE_4,ISC_ATTRIBUTE_8,ISC_MEASURE_1,ISC_MEASURE_2,
	ISC_MEASURE_3,ISC_MEASURE_4,ISC_MEASURE_5,ISC_MEASURE_6,CURRENCY';

  l_sql_stmt := '
SELECT	mv.customer_id				CUSTOMER_ID,
	mv.inv_org_id				INV_ORG_ID,
	mv.order_number				ISC_ATTRIBUTE_2,
	mv.time_booked_date_id			ISC_ATTRIBUTE_4,
	mv.line_number				ISC_ATTRIBUTE_8,
	null					ISC_MEASURE_1,  -- obsolete
	mv.days_late				ISC_MEASURE_2,
	mv.header_id				ISC_MEASURE_3,
	null					ISC_MEASURE_4,  -- obsolete
	null					ISC_MEASURE_5,  -- obsolete
	null					ISC_MEASURE_6,  -- obsolete
	null					CURRENCY	-- obsolete
   FROM ISC_DBI_FM_0008_MV	mv,
	(SELECT max(time_snapshot_date_id)		DAY
	   FROM	ISC_DBI_FM_0008_MV		mv
	  WHERE	mv.time_snapshot_date_id BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE
					     AND &BIS_CURRENT_ASOF_DATE
			)	a
  WHERE mv.time_snapshot_date_id = a.day'
	||l_inv_org_where||l_cust_where||l_inv_cat_where||l_item_where||l_bucket_low_where||l_bucket_high_where;

  l_stmt :='
SELECT
      ISC_ATTRIBUTE_2,
	ISC_ATTRIBUTE_8,
	org.name	ISC_ATTRIBUTE_9,
	cust.value	ISC_ATTRIBUTE_3,
	ISC_ATTRIBUTE_4,ISC_MEASURE_2,
	ISC_MEASURE_3,ISC_MEASURE_1,ISC_MEASURE_4,ISC_MEASURE_5,ISC_MEASURE_6,CURRENCY
  FROM (SELECT (rank() over (&ORDER_BY_CLAUSE NULLS LAST, isc_measure_3, isc_attribute_8))-1 rnk,
	customer_id,
	inv_org_id,
	'||l_outer_sql||'
   FROM ('||l_sql_stmt||')) c,
	FII_CUSTOMERS_V		cust,
	HR_ALL_ORGANIZATION_UNITS_TL org
  WHERE	c.customer_id = cust.id
    AND c.inv_org_id = org.organization_id
    AND org.language = :ISC_LANG
    AND	((c.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
  ORDER BY rnk';

  x_custom_sql := l_stmt;

  l_custom_rec.attribute_name := ':ISC_LOW';
  l_custom_rec.attribute_value := to_char(l_low);
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_HIGH';
  l_custom_rec.attribute_value := to_char(l_high);
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_LANG';
  l_custom_rec.attribute_value := l_lang;
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

END Get_Sql;

END ISC_DBI_PAST_DUE_DETAIL_PKG ;


/
