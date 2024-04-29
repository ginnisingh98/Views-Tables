--------------------------------------------------------
--  DDL for Package Body ISC_DBI_PDUE_PRM_AGING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_PDUE_PRM_AGING_PKG" AS
/* $Header: ISCRGA9B.pls 120.0 2005/05/25 17:16:19 appldev noship $ */


PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt			VARCHAR2(10000);
  l_period_type			VARCHAR2(10000);
  l_mv1				VARCHAR2(100);
  l_flags_where			VARCHAR2(10000);
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
  l_curr_g			VARCHAR2(15);
  l_curr_g1			VARCHAR2(15);
  l_curr_suffix			VARCHAR2(120);
  l_item_cat_flag		NUMBER;
  l_cust_flag			NUMBER;
  l_snapshot_taken		BOOLEAN	:= TRUE;
  l_as_of_date			DATE;
  l_effective_start_date	DATE;
  l_cursor_id			NUMBER;
  l_dummy			NUMBER;
  l_bucket_rec			bis_bucket_pub.BIS_BUCKET_REC_TYPE;
  l_error_tbl			bis_utilities_pub.ERROR_TBL_TYPE;
  l_status			VARCHAR2(10000);
  l_custom_rec			BIS_QUERY_ATTRIBUTES;

BEGIN

  l_curr_g			:= '''FII_GLOBAL1''';
  l_curr_g1			:= '''FII_GLOBAL2''';

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
    THEN
      l_cust_where := '';
      l_cust_flag := 1;
    ELSE
      l_cust_where := '
	    AND fact.customer_id in (&CUSTOMER+FII_CUSTOMERS)';
      l_cust_flag := 0;
  END IF;

  IF (l_prod IS NULL OR l_prod = '' OR l_prod = 'All')
    THEN
      IF (l_prod_cat IS NULL OR l_prod_cat = '' OR l_prod_cat = 'All')
        THEN l_item_cat_flag := 3; -- category
        ELSE l_item_cat_flag := 1; -- all
      END IF;
    ELSE
      l_item_cat_flag := 0; -- product
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
	  FROM ISC_DBI_CFM_008_MV	fact
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

-- Retrieve record to get bucket labels
  bis_bucket_pub.RETRIEVE_BIS_BUCKET('ISC_DBI_PDUE_AGING', l_bucket_rec, l_status, l_error_tbl);

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  IF ((l_prod IS NULL OR l_prod = '' OR l_prod = 'All') AND
      (l_cust IS NULL OR l_cust = '' OR l_cust = 'All'))
    THEN
      IF (l_prod_cat IS NULL OR l_prod_cat = '' OR l_prod_cat = 'All')
	THEN
	  l_prod_cat_from := '';
	  l_prod_cat_where := '
		    AND	fact.top_node_flag = ''Y''';
	ELSE
	  l_prod_cat_from := '';
	  l_prod_cat_where := '
		    AND fact.parent_id = &ITEM+ENI_ITEM_VBH_CAT';
      END IF;
      l_mv1 := 'ISC_DBI_CFM_012_MV';
      l_flags_where := '';
    ELSE
      l_mv1 := 'ISC_DBI_CFM_008_MV';
      l_flags_where := '
	    AND fact.item_cat_flag = :ISC_ITEM_CAT_FLAG
	    AND fact.customer_flag = :ISC_CUST_FLAG';
  END IF;

  IF NOT (l_snapshot_taken)
    THEN l_stmt := '
	 SELECT	0		ISC_ATTRIBUTE_2,
		0		ISC_ATTRIBUTE_3,
		0		ISC_MEASURE_1,
		0		ISC_MEASURE_2,
		0		ISC_MEASURE_3,
		0		ISC_MEASURE_4,
		0		ISC_MEASURE_5,
		0		ISC_MEASURE_6,
		0		ISC_MEASURE_7,
		0		ISC_MEASURE_8,
		0		ISC_MEASURE_9
	   FROM	dual
	  WHERE 1 = 2 -- no snapshot taken in the current period';
    ELSE
  l_stmt := '
 SELECT	c.bucket						ISC_ATTRIBUTE_2, -- bucket name
	c.bucket_type						ISC_ATTRIBUTE_3, -- bucket type
	c.curr_line_cnt						ISC_MEASURE_1, -- pdue line cnt
	c.prev_pdue_value					ISC_MEASURE_2, -- pdue prior
	c.curr_pdue_value					ISC_MEASURE_3, -- pdue
	(c.curr_pdue_value - c.prev_pdue_value)
	  / decode(c.prev_pdue_value, 0, NULL,
		   abs(c.prev_pdue_value)) * 100		ISC_MEASURE_4, -- pdue change
	c.curr_pdue_value
	  / decode(sum(c.curr_pdue_value) over (), 0, NULL,
		   abs(sum(c.curr_pdue_value) over ())) * 100	ISC_MEASURE_5, -- pdue % of total
	sum(c.curr_line_cnt) over ()				ISC_MEASURE_6, -- gd total pdue line cnt
	sum(c.curr_pdue_value) over ()				ISC_MEASURE_7, -- gd total pdue
	(sum(c.curr_pdue_value) over () - sum(c.prev_pdue_value) over ())
	  / decode(sum(c.prev_pdue_value) over (), 0, NULL,
		   abs(sum(c.prev_pdue_value) over ())) * 100	ISC_MEASURE_8, -- gd total pdue change
	sum(c.curr_pdue_value) over ()
	  / decode(sum(c.curr_pdue_value) over (), 0, NULL,
		   abs(sum(c.curr_pdue_value) over ())) * 100	ISC_MEASURE_9  -- gd total pdue % of total
   FROM
(SELECT decode(rownum,
		1, :ISC_R1,
		2, :ISC_R2,
		3, :ISC_R3,
		4, :ISC_R4,
		5, :ISC_R5,
		6, :ISC_R6,
		7, :ISC_R7,
		8, :ISC_R8,
		9, :ISC_R9,
		10, :ISC_R10,
		NULL)			BUCKET,
	rownum				BUCKET_TYPE,
	decode(rownum,
		1, m.curr_line_cnt_1,
		2, m.curr_line_cnt_2,
		3, m.curr_line_cnt_3,
		4, m.curr_line_cnt_4,
		5, m.curr_line_cnt_5,
		6, m.curr_line_cnt_6,
		7, m.curr_line_cnt_7,
		8, m.curr_line_cnt_8,
		9, m.curr_line_cnt_9,
		10, m.curr_line_cnt_10,
		NULL)			CURR_LINE_CNT,
	decode(rownum,
		1, m.curr_pdue_value_1,
		2, m.curr_pdue_value_2,
		3, m.curr_pdue_value_3,
		4, m.curr_pdue_value_4,
		5, m.curr_pdue_value_5,
		6, m.curr_pdue_value_6,
		7, m.curr_pdue_value_7,
		8, m.curr_pdue_value_8,
		9, m.curr_pdue_value_9,
		10, m.curr_pdue_value_10,
		NULL)			CURR_PDUE_VALUE,
	decode(rownum,
		1, m.prev_pdue_value_1,
		2, m.prev_pdue_value_2,
		3, m.prev_pdue_value_3,
		4, m.prev_pdue_value_4,
		5, m.prev_pdue_value_5,
		6, m.prev_pdue_value_6,
		7, m.prev_pdue_value_7,
		8, m.prev_pdue_value_8,
		9, m.prev_pdue_value_9,
		10, m.prev_pdue_value_10,
		NULL)			PREV_PDUE_VALUE
   FROM	(SELECT	sum(decode(fact.time_snapshot_date_id, a.day,
			   fact.bucket1_line_cnt_p, 0))				CURR_LINE_CNT_1,
		sum(decode(fact.time_snapshot_date_id, a.day,
			   fact.bucket2_line_cnt_p, 0))				CURR_LINE_CNT_2,
		sum(decode(fact.time_snapshot_date_id, a.day,
			   fact.bucket3_line_cnt_p, 0))				CURR_LINE_CNT_3,
		sum(decode(fact.time_snapshot_date_id, a.day,
			   fact.bucket4_line_cnt_p, 0))				CURR_LINE_CNT_4,
		sum(decode(fact.time_snapshot_date_id, a.day,
			   fact.bucket5_line_cnt_p, 0))				CURR_LINE_CNT_5,
		sum(decode(fact.time_snapshot_date_id, a.day,
			   fact.bucket6_line_cnt_p, 0))				CURR_LINE_CNT_6,
		sum(decode(fact.time_snapshot_date_id, a.day,
			   fact.bucket7_line_cnt_p, 0))				CURR_LINE_CNT_7,
		sum(decode(fact.time_snapshot_date_id, a.day,
			   fact.bucket8_line_cnt_p, 0))				CURR_LINE_CNT_8,
		sum(decode(fact.time_snapshot_date_id, a.day,
			   fact.bucket9_line_cnt_p, 0))				CURR_LINE_CNT_9,
		sum(decode(fact.time_snapshot_date_id, a.day,
			   fact.bucket10_line_cnt_p, 0))			CURR_LINE_CNT_10,
		sum(decode(fact.time_snapshot_date_id, a.day,
			   fact.bucket1_pdue_amt_'||l_curr_suffix||'_p, 0))	CURR_PDUE_VALUE_1,
		sum(decode(fact.time_snapshot_date_id, a.day,
			   fact.bucket2_pdue_amt_'||l_curr_suffix||'_p, 0))	CURR_PDUE_VALUE_2,
		sum(decode(fact.time_snapshot_date_id, a.day,
			   fact.bucket3_pdue_amt_'||l_curr_suffix||'_p, 0))	CURR_PDUE_VALUE_3,
		sum(decode(fact.time_snapshot_date_id, a.day,
			   fact.bucket4_pdue_amt_'||l_curr_suffix||'_p, 0))	CURR_PDUE_VALUE_4,
		sum(decode(fact.time_snapshot_date_id, a.day,
			   fact.bucket5_pdue_amt_'||l_curr_suffix||'_p, 0))	CURR_PDUE_VALUE_5,
		sum(decode(fact.time_snapshot_date_id, a.day,
			   fact.bucket6_pdue_amt_'||l_curr_suffix||'_p, 0))	CURR_PDUE_VALUE_6,
		sum(decode(fact.time_snapshot_date_id, a.day,
			   fact.bucket7_pdue_amt_'||l_curr_suffix||'_p, 0))	CURR_PDUE_VALUE_7,
		sum(decode(fact.time_snapshot_date_id, a.day,
			   fact.bucket8_pdue_amt_'||l_curr_suffix||'_p, 0))	CURR_PDUE_VALUE_8,
		sum(decode(fact.time_snapshot_date_id, a.day,
			   fact.bucket9_pdue_amt_'||l_curr_suffix||'_p, 0))	CURR_PDUE_VALUE_9,
		sum(decode(fact.time_snapshot_date_id, a.day,
			   fact.bucket10_pdue_amt_'||l_curr_suffix||'_p, 0))	CURR_PDUE_VALUE_10,
		sum(decode(fact.time_snapshot_date_id, b.day,
			   fact.bucket1_pdue_amt_'||l_curr_suffix||'_p, 0))	PREV_PDUE_VALUE_1,
		sum(decode(fact.time_snapshot_date_id, b.day,
			   fact.bucket2_pdue_amt_'||l_curr_suffix||'_p, 0))	PREV_PDUE_VALUE_2,
		sum(decode(fact.time_snapshot_date_id, b.day,
			   fact.bucket3_pdue_amt_'||l_curr_suffix||'_p, 0))	PREV_PDUE_VALUE_3,
		sum(decode(fact.time_snapshot_date_id, b.day,
			   fact.bucket4_pdue_amt_'||l_curr_suffix||'_p, 0))	PREV_PDUE_VALUE_4,
		sum(decode(fact.time_snapshot_date_id, b.day,
			   fact.bucket5_pdue_amt_'||l_curr_suffix||'_p, 0))	PREV_PDUE_VALUE_5,
		sum(decode(fact.time_snapshot_date_id, b.day,
			   fact.bucket6_pdue_amt_'||l_curr_suffix||'_p, 0))	PREV_PDUE_VALUE_6,
		sum(decode(fact.time_snapshot_date_id, b.day,
			   fact.bucket7_pdue_amt_'||l_curr_suffix||'_p, 0))	PREV_PDUE_VALUE_7,
		sum(decode(fact.time_snapshot_date_id, b.day,
			   fact.bucket8_pdue_amt_'||l_curr_suffix||'_p, 0))	PREV_PDUE_VALUE_8,
		sum(decode(fact.time_snapshot_date_id, b.day,
			   fact.bucket9_pdue_amt_'||l_curr_suffix||'_p, 0))	PREV_PDUE_VALUE_9,
		sum(decode(fact.time_snapshot_date_id, b.day,
			   fact.bucket10_pdue_amt_'||l_curr_suffix||'_p, 0))	PREV_PDUE_VALUE_10
	   FROM (SELECT max(time_snapshot_date_id)		day
		   FROM	'||l_mv1||'			fact
		  WHERE	fact.time_snapshot_date_id BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE
						       AND &BIS_CURRENT_ASOF_DATE
					)	a,
		(SELECT max(time_snapshot_date_id)		day
		   FROM	'||l_mv1||'			fact
		  WHERE	fact.time_snapshot_date_id BETWEEN &BIS_PREVIOUS_EFFECTIVE_START_DATE
						       AND &BIS_PREVIOUS_ASOF_DATE
					)	b,
		'||l_mv1||'		fact'||l_prod_cat_from||'
	  WHERE fact.time_snapshot_date_id IN (a.day, b.day)
	    AND fact.late_promise_flag = 1'
		||l_flags_where
		||l_inv_org_where
		||l_prod_cat_where
		||l_prod_where
		||l_cust_where
		||')			m,
	(SELECT 1 FROM DUAL		-- dummy table with 10 rows
	 UNION ALL SELECT 1 FROM DUAL
	 UNION ALL SELECT 1 FROM DUAL
	 UNION ALL SELECT 1 FROM DUAL
	 UNION ALL SELECT 1 FROM DUAL
	 UNION ALL SELECT 1 FROM DUAL
	 UNION ALL SELECT 1 FROM DUAL
	 UNION ALL SELECT 1 FROM DUAL
	 UNION ALL SELECT 1 FROM DUAL
	 UNION ALL SELECT 1 FROM DUAL)	)	c
   WHERE c.bucket IS NOT NULL
ORDER BY c.bucket_type';
  END IF;

  x_custom_sql := l_stmt;

  l_custom_rec.attribute_name := ':ISC_ITEM_CAT_FLAG';
  l_custom_rec.attribute_value := to_char(l_item_cat_flag);
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_CUST_FLAG';
  l_custom_rec.attribute_value := to_char(l_cust_flag);
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R1';
  l_custom_rec.attribute_value := l_bucket_rec.range1_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R2';
  l_custom_rec.attribute_value := l_bucket_rec.range2_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R3';
  l_custom_rec.attribute_value := l_bucket_rec.range3_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R4';
  l_custom_rec.attribute_value := l_bucket_rec.range4_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(6) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R5';
  l_custom_rec.attribute_value := l_bucket_rec.range5_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(7) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R6';
  l_custom_rec.attribute_value := l_bucket_rec.range6_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(8) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R7';
  l_custom_rec.attribute_value := l_bucket_rec.range7_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(9) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R8';
  l_custom_rec.attribute_value := l_bucket_rec.range8_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(10) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R9';
  l_custom_rec.attribute_value := l_bucket_rec.range9_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(11) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R10';
  l_custom_rec.attribute_value := l_bucket_rec.range10_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(12) := l_custom_rec;

END Get_Sql;

END ISC_DBI_PDUE_PRM_AGING_PKG;

/
