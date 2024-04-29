--------------------------------------------------------
--  DDL for Package Body ISC_DBI_PDUE_SCH_DETAIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_PDUE_SCH_DETAIL_PKG" AS
/* $Header: ISCRGA5B.pls 120.1 2005/10/18 12:49:04 hprathur noship $ */


PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt			VARCHAR2(10000);
  l_measures			VARCHAR2(10000);
  l_period_type			VARCHAR2(10000);
  l_inv_org			VARCHAR2(10000);
  l_inv_org_where		VARCHAR2(10000);
  l_prod			VARCHAR2(10000);
  l_prod_where			VARCHAR2(10000);
  l_prod_cat			VARCHAR2(10000);
  l_prod_cat_from		VARCHAR2(10000);
  l_prod_cat_where		VARCHAR2(10000);
  l_cust			VARCHAR2(10000);
  l_cust_where			VARCHAR2(10000);
  l_curr			VARCHAR2(10000);
  l_curr_g			VARCHAR2(15) := '''FII_GLOBAL1''';
  l_curr_g1			VARCHAR2(15) := '''FII_GLOBAL2''';
  l_curr_suffix			VARCHAR2(120);
  l_bucket			VARCHAR2(120);
  l_low				NUMBER;
  l_high			NUMBER;
  l_bucket_low_where		VARCHAR2(10000);
  l_bucket_high_where		VARCHAR2(10000);
  l_snapshot_taken		BOOLEAN	:= TRUE;
  l_as_of_date			DATE;
  l_effective_start_date	DATE;
  l_cursor_id			NUMBER;
  l_dummy			NUMBER;
  l_lang			VARCHAR2(10);
  l_bucket_rec			bis_bucket_pub.BIS_BUCKET_REC_TYPE;
  l_error_tbl			bis_utilities_pub.ERROR_TBL_TYPE;
  l_status			VARCHAR2(10000);
  l_custom_rec			BIS_QUERY_ATTRIBUTES;

BEGIN

  l_lang := userenv('LANG');

  FOR i IN 1..p_param.COUNT
  LOOP
    IF (p_param(i).parameter_name = 'AS_OF_DATE')
      THEN l_as_of_date := to_date(p_param(i).parameter_value, 'DD-MM-YYYY');
    END IF;

    IF (p_param(i).parameter_name = 'PERIOD_TYPE')
      THEN l_period_type := p_param(i).parameter_value;
    END IF;

    IF (p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES')
      THEN l_curr := p_param(i).parameter_id;
    END IF;

    IF (p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION')
      THEN l_inv_org := p_param(i).parameter_value;
    END IF;

    IF (p_param(i).parameter_name = 'ITEM+ENI_ITEM_VBH_CAT')
      THEN l_prod_cat := p_param(i).parameter_value;
    END IF;

    IF (p_param(i).parameter_name = 'ITEM+ENI_ITEM_ORG')
      THEN l_prod := p_param(i).parameter_value;
    END IF;

    IF (p_param(i).parameter_name = 'CUSTOMER+FII_CUSTOMERS')
      THEN l_cust := p_param(i).parameter_value;
    END IF;

    IF (p_param(i).parameter_name = 'ISC_ATTRIBUTE_6')
      THEN l_bucket := p_param(i).parameter_id;
    END IF;
  END LOOP;

  IF (l_curr = l_curr_g)
     THEN l_curr_suffix := 'g';
   ELSIF (l_curr = l_curr_g1)
     THEN l_curr_suffix :='g1';
     ELSE l_curr_suffix := 'f';
  END IF;

  IF (l_inv_org IS NULL OR l_inv_org = '' OR l_inv_org = 'All')
    THEN l_inv_org_where := '
	AND (EXISTS
		(SELECT 1
		FROM org_access o
		WHERE o.responsibility_id = fnd_global.resp_id
		AND o.resp_application_id = fnd_global.resp_appl_id
		AND o.organization_id = fact.inv_org_id)
	OR EXISTS
		(SELECT 1
		FROM mtl_parameters org
		WHERE org.organization_id = fact.inv_org_id
		AND NOT EXISTS
			(SELECT 1
			FROM org_access ora
			WHERE org.organization_id = ora.organization_id)))';
    ELSE l_inv_org_where := '
	    AND fact.inv_org_id = &ORGANIZATION+ORGANIZATION';
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
	    AND fact.item_category_id = eni_cat.child_id
	    AND eni_cat.parent_id IN (&ITEM+ENI_ITEM_VBH_CAT)
	    AND	eni_cat.dbi_flag = ''Y''
	    AND eni_cat.object_type = ''CATEGORY_SET''
	    AND eni_cat.object_id = mdcs.category_set_id
	    AND	mdcs.functional_area_id = 11';
  END IF;

  IF (l_prod IS NULL OR l_prod = '' OR l_prod = 'All')
    THEN l_prod_where := '';
    ELSE l_prod_where := '
	    AND fact.item_id IN (&ITEM+ENI_ITEM_ORG)';
  END IF;

  IF (l_cust IS NULL OR l_cust = '' OR l_cust = 'All')
    THEN l_cust_where := '';
    ELSE l_cust_where := '
	    AND fact.customer_id in (&CUSTOMER+FII_CUSTOMERS)';
  END IF;

-- Retrieve record to get bucket ranges
  bis_bucket_pub.RETRIEVE_BIS_BUCKET('ISC_DBI_PDUE_AGING', l_bucket_rec, l_status, l_error_tbl);

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
	    AND	fact.days_late >= :ISC_LOW';
  END IF;

  IF (l_high IS NULL)
    THEN l_bucket_high_where := '';
    ELSE l_bucket_high_where := '
	    AND	fact.days_late < :ISC_HIGH';
  END IF;

  BEGIN

    IF l_period_type = 'FII_TIME_ENT_YEAR'
      THEN l_effective_start_date := FII_TIME_API.Ent_Cyr_Start(l_as_of_date);
    ELSIF l_period_type = 'FII_TIME_ENT_QTR'
      THEN l_effective_start_date := FII_TIME_API.Ent_Cqtr_Start(l_as_of_date);
    ELSIF l_period_type = 'FII_TIME_ENT_PERIOD'
      THEN l_effective_start_date := FII_TIME_API.Ent_Cper_Start(l_as_of_date);
    ELSE -- l_period_type = 'FII_TIME_WEEK'
      l_effective_start_date := FII_TIME_API.Cwk_Start(l_as_of_date);
    END IF;

    l_cursor_id := DBMS_SQL.Open_Cursor;
    l_stmt := '
	SELECT 1
	  FROM ISC_DBI_CFM_013_MV	fact
	 WHERE fact.time_snapshot_date_id BETWEEN :l_effective_start_date
					      AND :l_as_of_date
	   AND rownum = 1 ';

    DBMS_SQL.Parse(l_cursor_id,l_stmt,DBMS_SQL.V7);
    DBMS_SQL.Bind_Variable(l_cursor_id,':l_effective_start_date',l_effective_start_date);
    DBMS_SQL.Bind_Variable(l_cursor_id,':l_as_of_date',l_as_of_date);

    l_dummy := DBMS_SQL.Execute(l_cursor_id);

    IF DBMS_SQL.Fetch_Rows(l_cursor_id) = 0 -- no snapshot taken
      THEN l_snapshot_taken := FALSE;
      ELSE l_snapshot_taken := TRUE;
    END IF;

    DBMS_SQL.Close_Cursor(l_cursor_id);

  EXCEPTION WHEN OTHERS
    THEN
      DBMS_SQL.Close_Cursor(l_cursor_id);
      l_snapshot_taken := TRUE;

  END;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  l_measures := 'ISC_ATTRIBUTE_2, ISC_ATTRIBUTE_3, ISC_ATTRIBUTE_5, ISC_ATTRIBUTE_7,
	ISC_MEASURE_1, ISC_MEASURE_2, ISC_MEASURE_3';

  IF NOT (l_snapshot_taken)
    THEN l_stmt := '
	 SELECT	0		ISC_ATTRIBUTE_2,
		0		ISC_ATTRIBUTE_3,
		0		ISC_ATTRIBUTE_8,
		0		ISC_ATTRIBUTE_4,
		null		ISC_ATTRIBUTE_5,
		0		ISC_ATTRIBUTE_7,
		0		ISC_MEASURE_1,
		0		ISC_MEASURE_2,
		0		ISC_MEASURE_3
	   FROM	dual
	  WHERE 1 = 2 -- no snapshot taken in the current period';
    ELSE
  l_stmt := '
 SELECT
	ISC_ATTRIBUTE_2,
	ISC_ATTRIBUTE_3,
	org.name						ISC_ATTRIBUTE_8,
	cust.value						ISC_ATTRIBUTE_4,
	ISC_ATTRIBUTE_5,
	ISC_ATTRIBUTE_7,
	ISC_MEASURE_1, ISC_MEASURE_2, ISC_MEASURE_3
   FROM
(SELECT	(rank() over (&ORDER_BY_CLAUSE, isc_attribute_7, isc_attribute_3)) - 1	rnk,
	customer_id,
	inv_org_id,
	'||l_measures||'
   FROM
(SELECT	fact.customer_id					CUSTOMER_ID,
	fact.inv_org_id						INV_ORG_ID,
	fact.order_number					ISC_ATTRIBUTE_2, -- order number
	fact.line_number					ISC_ATTRIBUTE_3, -- line number
	fact.time_booked_date_id				ISC_ATTRIBUTE_5, -- booked date
	fact.header_id						ISC_ATTRIBUTE_7, -- header_id
	fact.pdue_amt_'||l_curr_suffix||'			ISC_MEASURE_1, -- pdue
	fact.days_late						ISC_MEASURE_2, -- days late
	sum(fact.pdue_amt_'||l_curr_suffix||') over ()		ISC_MEASURE_3  -- gd total pdue
   FROM	ISC_DBI_CFM_013_MV			fact,
	(SELECT max(fact.time_snapshot_date_id)		day
	   FROM	ISC_DBI_CFM_013_MV			fact
	  WHERE	fact.time_snapshot_date_id BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE
					       AND &BIS_CURRENT_ASOF_DATE)	snap'||l_prod_cat_from||'
  WHERE	fact.time_snapshot_date_id = snap.day
    AND fact.late_schedule_flag = 1'
	||l_inv_org_where
	||l_prod_cat_where
	||l_prod_where
	||l_cust_where
	||l_bucket_low_where
	||l_bucket_high_where||'))	a,
	FII_CUSTOMERS_V			cust,
	HR_ALL_ORGANIZATION_UNITS_TL	org
  WHERE	a.customer_id = cust.id
    AND a.inv_org_id = org.organization_id
    AND org.language = :ISC_LANG
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
ORDER BY rnk';
  END IF;

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

END ISC_DBI_PDUE_SCH_DETAIL_PKG;

/
