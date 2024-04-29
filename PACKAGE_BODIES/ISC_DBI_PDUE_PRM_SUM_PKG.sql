--------------------------------------------------------
--  DDL for Package Body ISC_DBI_PDUE_PRM_SUM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_PDUE_PRM_SUM_PKG" AS
/* $Header: ISCRGA7B.pls 120.0 2005/05/25 17:29:12 appldev noship $ */


PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt			VARCHAR2(10000);
  l_measures			VARCHAR2(10000);
  l_select_stmt			VARCHAR2(10000);
  l_inner_select_stmt		VARCHAR2(10000);
  l_inner_group_by_stmt		VARCHAR2(10000);
  l_where_stmt			VARCHAR2(10000);
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
  l_curr_suffix			VARCHAR2(120);
  l_view_by			VARCHAR2(120);
  l_bucket			VARCHAR2(120);
  l_pdue_qty			VARCHAR2(120);
  l_pdue_amt			VARCHAR2(120);
  l_days_late			VARCHAR2(120);
  l_line_cnt			VARCHAR2(120);
  l_lang			VARCHAR2(10);
  l_mv				VARCHAR2(10000);
  l_flags_where			VARCHAR2(10000);
  l_item_cat_flag		NUMBER;
  l_cust_flag			NUMBER;
  l_snapshot_taken		BOOLEAN;
  l_as_of_date			DATE;
  l_effective_start_date	DATE;
  l_cursor_id			NUMBER;
  l_dummy			NUMBER;
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

    IF (p_param(i).parameter_name = 'VIEW_BY')
      THEN l_view_by := p_param(i).parameter_value;
    END IF;

    IF (p_param(i).parameter_name = 'ISC_ATTRIBUTE_6')
      THEN l_bucket := p_param(i).parameter_id;
    END IF;
  END LOOP;

  IF (l_curr = '''FII_GLOBAL1''')
    THEN l_curr_suffix := 'g';
  ELSIF (l_curr = '''FII_GLOBAL2''')
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
      IF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT')
	THEN
	  l_prod_cat_from := ',
		ENI_DENORM_HIERARCHIES		eni_cat,
		MTL_DEFAULT_CATEGORY_SETS	mdcs';
	  l_prod_cat_where := '
	    AND fact.item_category_id = eni_cat.child_id
	    AND eni_cat.top_node_flag = ''Y''
	    AND	eni_cat.dbi_flag = ''Y''
	    AND eni_cat.object_type = ''CATEGORY_SET''
	    AND	eni_cat.object_id = mdcs.category_set_id
	    AND	mdcs.functional_area_id = 11';
	ELSE
	  l_prod_cat_from := '';
	  l_prod_cat_where := '';
      END IF;
    ELSE
      l_prod_cat_from := ',
		ENI_DENORM_HIERARCHIES		eni_cat,
		MTL_DEFAULT_CATEGORY_SETS	mdcs';
      l_prod_cat_where := '
	    AND fact.item_category_id = eni_cat.child_id
	    AND eni_cat.parent_id IN (&ITEM+ENI_ITEM_VBH_CAT)
	    AND	eni_cat.dbi_flag = ''Y''
	    AND	eni_cat.object_type = ''CATEGORY_SET''
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
      IF (l_view_by = 'CUSTOMER+FII_CUSTOMERS')
        THEN l_cust_flag := 0;
	ELSE l_cust_flag := 1;
      END IF;
    ELSE
      l_cust_where := '
	    AND fact.customer_id in (&CUSTOMER+FII_CUSTOMERS)';
      l_cust_flag := 0;
  END IF;

  IF (l_prod IS NULL OR l_prod = '' OR l_prod = 'All')
    THEN
      IF (l_view_by = 'ITEM+ENI_ITEM_ORG')
	THEN l_item_cat_flag := 0; -- product
      ELSIF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT')
        THEN l_item_cat_flag := 1; -- category
      ELSE
	IF (l_prod_cat IS NULL OR l_prod_cat = '' OR l_prod_cat = 'All')
	  THEN l_item_cat_flag := 3; -- all
	  ELSE l_item_cat_flag := 1; -- category
	END IF;
      END IF;
  ELSE
    l_item_cat_flag := 0; -- product
  END IF;

  IF (l_bucket IS NULL OR l_bucket = '')
    THEN
      l_pdue_qty := 'pdue_qty';
      l_pdue_amt := 'pdue_amt_'||l_curr_suffix;
      l_days_late := 'days_late_promise';
      l_line_cnt := 'pdue_line_cnt';
    ELSE
      l_pdue_qty := 'bucket'||l_bucket||'_qty_p';
      l_pdue_amt := 'bucket'||l_bucket||'_pdue_amt_'||l_curr_suffix||'_p';
      l_days_late := 'bucket'||l_bucket||'_days_late_p';
      l_line_cnt := 'bucket'||l_bucket||'_line_cnt_p';
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

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  l_measures := 'ISC_MEASURE_1,ISC_MEASURE_2,ISC_MEASURE_3,ISC_MEASURE_4,ISC_MEASURE_5,
		 ISC_MEASURE_6,ISC_MEASURE_7,ISC_MEASURE_8,ISC_MEASURE_9';

  IF l_view_by = 'ITEM+ENI_ITEM_ORG'
    THEN l_select_stmt := '
 SELECT	items.value						VIEWBY,
	items.id						VIEWBYID,
	NULL							ISC_ATTRIBUTE_3, -- drill across url
	items.description					ISC_ATTRIBUTE_4, -- item description
	mtl.unit_of_measure					ISC_ATTRIBUTE_5, -- item uom
	'||l_measures||'
   FROM
(SELECT	(rank() over (&ORDER_BY_CLAUSE nulls last, item_id)) - 1		rnk,
	item_id,
	uom,
	'||l_measures||'
   FROM
(SELECT	c.item_id,
	c.uom,		';
	l_inner_select_stmt := '
		 SELECT	fact.item_id					ITEM_ID,
			fact.uom					UOM,';
	l_inner_group_by_stmt := '
		GROUP BY fact.item_id, fact.uom';
	l_where_stmt := '
	ENI_ITEM_ORG_V			items,
	MTL_UNITS_OF_MEASURE_TL		mtl
  WHERE a.item_id = items.id
    AND	a.uom = mtl.uom_code
    AND	mtl.language = :ISC_LANG
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))';

  ELSIF l_view_by = 'ORGANIZATION+ORGANIZATION'
    THEN l_select_stmt := '
 SELECT	org.name						VIEWBY,
	org.organization_id					VIEWBYID,
	NULL							ISC_ATTRIBUTE_3, -- drill across url
	NULL							ISC_ATTRIBUTE_4, -- item description
	NULL							ISC_ATTRIBUTE_5, -- item uom
	'||l_measures||'
   FROM
(SELECT (rank() over (&ORDER_BY_CLAUSE nulls last, inv_org_id)) - 1		rnk,
	inv_org_id,
	'||l_measures||'
   FROM
(SELECT	c.inv_org_id,	';
	l_inner_select_stmt := '
		 SELECT	fact.inv_org_id					INV_ORG_ID,';
	l_inner_group_by_stmt := '
		GROUP BY fact.inv_org_id';
	l_where_stmt := '
	HR_ALL_ORGANIZATION_UNITS_TL	org
  WHERE a.inv_org_id = org.organization_id
    AND org.language = :ISC_LANG
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))';

  ELSIF l_view_by = 'ITEM+ENI_ITEM_VBH_CAT'
    THEN l_select_stmt := '
 SELECT	ecat.value					VIEWBY,
	ecat.id						VIEWBYID,
	decode(ecat.leaf_node_flag, ''Y'',
		''pFunctionName=ISC_DBI_PDUE_PRM_SUM&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_ORG&pParamIds=Y'',
		''pFunctionName=ISC_DBI_PDUE_PRM_SUM&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&pParamIds=Y'')
								ISC_ATTRIBUTE_3, -- drill across url
	NULL							ISC_ATTRIBUTE_4, -- item description
	NULL							ISC_ATTRIBUTE_5, -- item uom
	'||l_measures||'
   FROM
(SELECT (rank() over (&ORDER_BY_CLAUSE nulls last, item_category_id)) - 1	rnk,
	item_category_id,
	'||l_measures||'
   FROM
(SELECT	c.item_category_id,	';
  IF (l_prod_cat IS NULL OR l_prod_cat = '' OR l_prod_cat = 'All')
    THEN
	l_inner_select_stmt := '
		 SELECT	eni_cat.parent_id				ITEM_CATEGORY_ID,';
	l_inner_group_by_stmt := '
		GROUP BY eni_cat.parent_id';
    ELSE
	l_inner_select_stmt := '
		 SELECT	eni_cat.imm_child_id				ITEM_CATEGORY_ID,';
	l_inner_group_by_stmt := '
		GROUP BY eni_cat.imm_child_id';
  END IF;
	l_where_stmt := '
	ENI_ITEM_VBH_NODES_V		ecat
  WHERE a.item_category_id = ecat.id
    AND ecat.parent_id = ecat.child_id
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))';

  ELSE -- l_view_by = 'CUSTOMER+FII_CUSTOMERS'
    l_select_stmt := '
 SELECT	cust.value						VIEWBY,
	cust.id							VIEWBYID,
	NULL							ISC_ATTRIBUTE_3, -- drill across url
	NULL							ISC_ATTRIBUTE_4, -- item description
	NULL							ISC_ATTRIBUTE_5, -- item uom
	'||l_measures||'
   FROM
(SELECT	(rank() over (&ORDER_BY_CLAUSE nulls last, customer_id)) - 1		rnk,
	customer_id,
	'||l_measures||'
   FROM
(SELECT	c.customer_id,	';
	l_inner_select_stmt := '
		 SELECT	fact.customer_id				CUSTOMER_ID,';
	l_inner_group_by_stmt := '
		GROUP BY fact.customer_id';
	l_where_stmt := '
	FII_CUSTOMERS_V			cust
  WHERE a.customer_id = cust.id
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))';
  END IF;

  IF ((l_view_by = 'ITEM+ENI_ITEM_VBH_CAT' OR l_view_by = 'ORGANIZATION+ORGANIZATION') AND
      (l_prod IS NULL OR l_prod = 'All') AND
      (l_cust IS NULL OR l_cust = 'All'))
    THEN
    	IF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') THEN
	  IF (l_prod_cat IS NULL OR l_prod_cat = 'All')
	    THEN
	      l_inner_select_stmt := '
		 SELECT	fact.parent_id		ITEM_CATEGORY_ID,';
	      l_inner_group_by_stmt := '
		GROUP BY fact.parent_id';
	    ELSE
	      l_inner_select_stmt := '
		 SELECT fact.imm_child_id	ITEM_CATEGORY_ID,';
	      l_inner_group_by_stmt := '
		GROUP BY fact.imm_child_id';
	  END IF;
	END IF;

	IF (l_prod_cat IS NULL OR l_prod_cat = 'All')
	  THEN
	    l_prod_cat_from := '';
	    l_prod_cat_where := '
		    AND	fact.top_node_flag = ''Y''';
	  ELSE
	    l_prod_cat_from := '';
	    l_prod_cat_where := '
		    AND fact.parent_id = &ITEM+ENI_ITEM_VBH_CAT';
	END IF;
	l_mv := 'ISC_DBI_CFM_012_MV';
	l_flags_where := '';
    ELSE
	l_mv := 'ISC_DBI_CFM_008_MV';
	l_flags_where := '
	    AND fact.item_cat_flag = :ISC_ITEM_CAT_FLAG
	    AND fact.customer_flag = :ISC_CUST_FLAG';
  END IF;

  IF NOT (l_snapshot_taken)
    THEN l_stmt := '
	 SELECT	0		VIEWBY,
		0		ISC_ATTRIBUTE_3,
		0		ISC_ATTRIBUTE_4,
		0		ISC_ATTRIBUTE_5,
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
  l_stmt := l_select_stmt || '
	c.curr_pdue_qty						ISC_MEASURE_1, -- pdue qty
	c.curr_pdue_value					ISC_MEASURE_2, -- pdue
	(c.curr_pdue_value - c.prev_pdue_value)
	  / decode(c.prev_pdue_value, 0, NULL,
		   abs(c.prev_pdue_value)) * 100		ISC_MEASURE_3, -- pdue change
	c.curr_line_cnt						ISC_MEASURE_4, -- pdue line cnt
	c.curr_days_late
	  / decode(c.curr_line_cnt, 0, NULL,
		   c.curr_line_cnt)				ISC_MEASURE_5, -- pdue avg days late
	sum(c.curr_pdue_value) over ()				ISC_MEASURE_6, -- gd total pdue
	(sum(c.curr_pdue_value) over () - sum(c.prev_pdue_value) over ())
	  / decode(sum(c.prev_pdue_value) over (), 0, NULL,
		   abs(sum(c.prev_pdue_value) over ())) * 100	ISC_MEASURE_7, -- gd total pdue change
	sum(c.curr_line_cnt) over ()				ISC_MEASURE_8, -- gd total pdue line cnt
	sum(c.curr_days_late) over ()
	  / decode(sum(c.curr_line_cnt) over (), 0, NULL,
		   sum(c.curr_line_cnt) over ())		ISC_MEASURE_9  -- gd total avg days late
	   FROM	('||l_inner_select_stmt||'
		sum(decode(fact.time_snapshot_date_id, a.day,
			   fact.'||l_pdue_qty||', 0))			CURR_PDUE_QTY,
		sum(decode(fact.time_snapshot_date_id, a.day,
			   fact.'||l_pdue_amt||', 0))			CURR_PDUE_VALUE,
		sum(decode(fact.time_snapshot_date_id, b.day,
			   fact.'||l_pdue_amt||', 0))			PREV_PDUE_VALUE,
		sum(decode(fact.time_snapshot_date_id, a.day,
			   fact.'||l_days_late||', 0))			CURR_DAYS_LATE,
		sum(decode(fact.time_snapshot_date_id, a.day,
			   fact.'||l_line_cnt||', 0))			CURR_LINE_CNT
	   FROM (SELECT max(time_snapshot_date_id)		day
		   FROM	'||l_mv||'			fact
		  WHERE	fact.time_snapshot_date_id BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE
						       AND &BIS_CURRENT_ASOF_DATE
					)	a,
		(SELECT max(time_snapshot_date_id)		day
		   FROM	'||l_mv||'			fact
		  WHERE	fact.time_snapshot_date_id BETWEEN &BIS_PREVIOUS_EFFECTIVE_START_DATE
						       AND &BIS_PREVIOUS_ASOF_DATE
					)	b,
		'||l_mv||'		fact'||l_prod_cat_from||'
	  WHERE fact.time_snapshot_date_id IN (a.day, b.day)
	    AND fact.late_promise_flag = 1'||l_flags_where||'
	    AND fact.'||l_line_cnt||' <> 0'
		||l_inv_org_where
		||l_prod_cat_where
		||l_prod_where
		||l_cust_where
		||l_inner_group_by_stmt||')	c))	a,'
		||l_where_stmt||'
  ORDER BY rnk';
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

  l_custom_rec.attribute_name := ':ISC_LANG';
  l_custom_rec.attribute_value := l_lang;
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

END Get_Sql;

END ISC_DBI_PDUE_PRM_SUM_PKG;

/
