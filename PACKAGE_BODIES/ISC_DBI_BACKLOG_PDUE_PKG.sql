--------------------------------------------------------
--  DDL for Package Body ISC_DBI_BACKLOG_PDUE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_BACKLOG_PDUE_PKG" AS
/* $Header: ISCRGA2B.pls 120.0 2005/05/25 17:29:57 appldev noship $ */

PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt			VARCHAR2(32000);
  l_measures			VARCHAR2(10000);
  l_select_stmt			VARCHAR2(10000);
  l_union_select_stmt		VARCHAR2(10000);
  l_union_group_by_stmt		VARCHAR2(10000);
  l_inner_select_stmt		VARCHAR2(10000);
  l_where_stmt			VARCHAR2(10000);
  l_mv1				VARCHAR2(100);
  l_mv2				VARCHAR2(100);
  l_mv_book			VARCHAR2(100);
  l_mv_fulf			VARCHAR2(100);
  l_flags_where			VARCHAR2(1000);
  l_flags_where2		VARCHAR2(1000);
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
  l_lang			VARCHAR2(10);
  l_item_cat_flag		NUMBER;
  l_cust_flag			NUMBER;
  l_custom_rec			BIS_QUERY_ATTRIBUTES;

BEGIN

  l_lang := userenv('LANG');

  FOR i IN 1..p_param.COUNT
  LOOP
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
  END LOOP;

  IF (l_curr = '''FII_GLOBAL1''')
    THEN l_curr_suffix := 'g';
  ELSIF (l_curr = '''FII_GLOBAL2''')
    THEN l_curr_suffix := 'g1';
    ELSE l_curr_suffix := 'f';
  END IF;

  IF (l_inv_org IS NULL OR l_inv_org = 'All')
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

  IF (l_prod_cat IS NULL OR l_prod_cat = 'All')
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

  IF (l_prod IS NULL OR l_prod = 'All')
    THEN l_prod_where := '';
    ELSE l_prod_where := '
	    AND fact.item_id IN (&ITEM+ENI_ITEM_ORG)';
  END IF;

  IF (l_cust IS NULL OR l_cust = 'All')
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

  IF (l_prod IS NULL OR l_prod = 'All')
    THEN
      IF (l_view_by = 'ITEM+ENI_ITEM_ORG')
	THEN l_item_cat_flag := 0; -- product
      ELSIF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT')
        THEN l_item_cat_flag := 1; -- category
      ELSE
	IF (l_prod_cat IS NULL OR l_prod_cat = 'All')
	  THEN l_item_cat_flag := 3; -- all
	  ELSE l_item_cat_flag := 1; -- category
	END IF;
      END IF;
  ELSE
    l_item_cat_flag := 0; -- product
  END IF;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  l_measures := 'ISC_MEASURE_1,ISC_MEASURE_2,ISC_MEASURE_3,ISC_MEASURE_4,ISC_MEASURE_5,
	ISC_MEASURE_6,ISC_MEASURE_7,ISC_MEASURE_8,ISC_MEASURE_9,ISC_MEASURE_10,
	ISC_MEASURE_11,ISC_MEASURE_12,ISC_MEASURE_13,ISC_MEASURE_14,ISC_MEASURE_15,
	ISC_MEASURE_16,ISC_MEASURE_17,ISC_MEASURE_18,ISC_MEASURE_19,ISC_MEASURE_20,
	ISC_MEASURE_22,ISC_MEASURE_23';

  IF l_view_by = 'ITEM+ENI_ITEM_ORG'
    THEN l_select_stmt := '
 SELECT	items.value			VIEWBY,
	items.id			VIEWBYID,
	NULL				ISC_ATTRIBUTE_3, -- drill across url
	items.description		ISC_ATTRIBUTE_4, -- item description
	mtl.unit_of_measure		ISC_ATTRIBUTE_5, -- item uom
	'||l_measures||'
   FROM
(SELECT	(rank() over (&ORDER_BY_CLAUSE nulls last, item_id)) - 1	rnk,
	item_id,
	uom,
	'||l_measures||'
   FROM
(SELECT	c.item_id,
	c.uom,		';
	l_inner_select_stmt := '
		 SELECT	fact.item_id		ITEM_ID,
			fact.uom		UOM,';
	l_union_select_stmt := '
		 SELECT item_id			ITEM_ID,
			uom			UOM,';
	l_union_group_by_stmt := '
		GROUP BY item_id, uom';
	l_where_stmt := '
	ENI_ITEM_ORG_V			items,
	MTL_UNITS_OF_MEASURE_TL		mtl
  WHERE a.item_id = items.id
    AND	a.uom = mtl.uom_code
    AND	mtl.language = :ISC_LANG
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
  ORDER BY rnk';

  ELSIF l_view_by = 'ORGANIZATION+ORGANIZATION'
    THEN l_select_stmt := '
 SELECT	org.name			VIEWBY,
	org.organization_id		VIEWBYID,
	NULL				ISC_ATTRIBUTE_3, -- drill across url
	NULL				ISC_ATTRIBUTE_4, -- item description
	NULL				ISC_ATTRIBUTE_5, -- item uom
	'||l_measures||'
   FROM
(SELECT (rank() over (&ORDER_BY_CLAUSE nulls last, inv_org_id)) - 1	rnk,
	inv_org_id,
	'||l_measures||'
   FROM
(SELECT	c.inv_org_id,	';
	l_inner_select_stmt := '
		 SELECT	fact.inv_org_id		INV_ORG_ID,';
	l_union_select_stmt := '
		 SELECT inv_org_id		INV_ORG_ID,';
	l_union_group_by_stmt := '
		GROUP BY inv_org_id';
	l_where_stmt := '
	HR_ALL_ORGANIZATION_UNITS_TL	org
  WHERE a.inv_org_id = org.organization_id
    AND org.language = :ISC_LANG
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
  ORDER BY rnk';

  ELSIF l_view_by = 'CUSTOMER+FII_CUSTOMERS'
    THEN l_select_stmt := '
 SELECT	cust.value			VIEWBY,
	cust.id				VIEWBYID,
	NULL				ISC_ATTRIBUTE_3, -- drill across url
	NULL				ISC_ATTRIBUTE_4, -- item description
	NULL				ISC_ATTRIBUTE_5, -- item uom
	'||l_measures||'
   FROM
(SELECT	(rank() over (&ORDER_BY_CLAUSE nulls last, customer_id)) - 1	rnk,
	customer_id,
	'||l_measures||'
   FROM
(SELECT	c.customer_id,	';
	l_inner_select_stmt := '
		 SELECT	fact.customer_id	CUSTOMER_ID,';
	l_union_select_stmt := '
		 SELECT customer_id		CUSTOMER_ID,';
	l_union_group_by_stmt := '
		GROUP BY customer_id';
	l_where_stmt := '
	FII_CUSTOMERS_V			cust
  WHERE a.customer_id = cust.id
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
  ORDER BY rnk';

  ELSE -- l_view_by = 'ITEM+ENI_ITEM_VBH_CAT'
    l_select_stmt := '
 SELECT	ecat.value			VIEWBY,
	ecat.id				VIEWBYID,
	decode(ecat.leaf_node_flag, ''Y'',
		''pFunctionName=ISC_DBI_BACKLOG_PDUE&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_ORG&pParamIds=Y'',
		''pFunctionName=ISC_DBI_BACKLOG_PDUE&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&pParamIds=Y'')
					ISC_ATTRIBUTE_3, -- drill across url
	NULL				ISC_ATTRIBUTE_4, -- item description
	NULL				ISC_ATTRIBUTE_5, -- item uom
	'||l_measures||'
   FROM
(SELECT (rank() over (&ORDER_BY_CLAUSE nulls last, item_category_id)) - 1	rnk,
	item_category_id,
	'||l_measures||'
   FROM
(SELECT	c.item_category_id,	';
  IF (l_prod_cat IS NULL OR l_prod_cat = 'All')
    THEN
	l_inner_select_stmt := '
		 SELECT	eni_cat.parent_id	ITEM_CATEGORY_ID,';
    ELSE
	l_inner_select_stmt := '
		 SELECT	eni_cat.imm_child_id	ITEM_CATEGORY_ID,';
  END IF;
	l_union_select_stmt := '
		 SELECT item_category_id	ITEM_CATEGORY_ID,';
	l_union_group_by_stmt := '
		GROUP BY item_category_id';
	l_where_stmt := '
	ENI_ITEM_VBH_NODES_V		ecat
  WHERE a.item_category_id = ecat.id
    AND	ecat.parent_id = ecat.child_id
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
  ORDER BY rnk';
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
	    ELSE
	      l_inner_select_stmt := '
		 SELECT fact.imm_child_id	ITEM_CATEGORY_ID,';
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
	l_mv1 := 'ISC_DBI_CFM_001_MV';
	l_mv_book := 'ISC_DBI_CFM_009_MV';
	l_mv_fulf := 'ISC_DBI_CFM_011_MV';
	l_mv2 := 'ISC_DBI_CFM_012_MV';
	l_flags_where := '';
	l_flags_where2 := '
	    AND fact.inv_org_flag = 0';
    ELSE
	l_mv1 := 'ISC_DBI_CFM_010_MV';
	l_mv_book := 'ISC_DBI_CFM_000_MV';
	l_mv_fulf := 'ISC_DBI_CFM_002_MV';
	l_mv2 := 'ISC_DBI_CFM_008_MV';
	l_flags_where := '
	    AND fact.item_cat_flag = :ISC_ITEM_CAT_FLAG
	    AND fact.customer_flag = :ISC_CUST_FLAG';
	l_flags_where2 := '
	    AND fact.item_cat_flag = :ISC_ITEM_CAT_FLAG
	    AND fact.customer_flag = :ISC_CUST_FLAG';
  END IF;

  l_stmt := l_select_stmt || '
	c.curr_bklg_qty						ISC_MEASURE_1, -- bklg qty
	c.curr_bklg_value					ISC_MEASURE_2, -- bklg
	(c.curr_bklg_value - c.prev_bklg_value)
	  / decode(c.prev_bklg_value, 0, NULL,
		   abs(c.prev_bklg_value)) * 100		ISC_MEASURE_3, -- bklg change
	c.curr_bklg_value
	  / decode(sum(c.curr_bklg_value) over (), 0, NULL,
		   sum(c.curr_bklg_value) over ()) * 100	ISC_MEASURE_4, -- bklg % of total
	c.curr_pdue_qty						ISC_MEASURE_5, -- pdue qty
	c.curr_pdue_value					ISC_MEASURE_6, -- pdue
	(c.curr_pdue_value - c.prev_pdue_value)
	  / decode(c.prev_pdue_value, 0, NULL,
		   abs(c.prev_pdue_value)) * 100		ISC_MEASURE_7, -- pdue change
	c.curr_pdue_value
	  / decode(sum(c.curr_pdue_value) over (), 0, NULL,
		   sum(c.curr_pdue_value) over ()) * 100	ISC_MEASURE_8, -- pdue % of total
	sum(c.curr_bklg_value) over ()				ISC_MEASURE_9, -- gd total bklg
	(sum(c.curr_bklg_value) over () - sum(c.prev_bklg_value) over ())
	  / decode(sum(c.prev_bklg_value) over (), 0, NULL,
		   abs(sum(c.prev_bklg_value) over ())) * 100	ISC_MEASURE_10, -- gd total bklg change
	sum(c.curr_bklg_value) over ()
	  / decode(sum(c.curr_bklg_value) over (), 0, NULL,
		   sum(c.curr_bklg_value) over ()) * 100	ISC_MEASURE_11, -- gd total bklg % of total
	sum(c.curr_pdue_value) over ()				ISC_MEASURE_12, -- gd total pdue
	(sum(c.curr_pdue_value) over () - sum(c.prev_pdue_value) over ())
	  / decode(sum(c.prev_pdue_value) over (), 0, NULL,
		   abs(sum(c.prev_pdue_value) over ())) * 100	ISC_MEASURE_13, -- gd total pdue change
	sum(c.curr_pdue_value) over ()
	  / decode(sum(c.curr_pdue_value) over (), 0, NULL,
		   sum(c.curr_pdue_value) over ()) * 100	ISC_MEASURE_14, -- gd total pdue % of total
	c.curr_bklg_value					ISC_MEASURE_15, -- KPI bklg
	c.prev_bklg_value					ISC_MEASURE_16, -- KPI bklg prior
	c.curr_pdue_value					ISC_MEASURE_17, -- KPI pdue
	c.prev_pdue_value					ISC_MEASURE_18, -- KPI pdue prior
	sum(c.curr_bklg_value) over ()				ISC_MEASURE_19, -- gd total KPI bklg
	sum(c.prev_bklg_value) over ()				ISC_MEASURE_20, -- gd total KPI bklg prior
	sum(c.curr_pdue_value) over ()				ISC_MEASURE_22,	-- gd total KPI pdue
	sum(c.prev_pdue_value) over ()				ISC_MEASURE_23	-- gd.total KPI pdue prior
	   FROM	('||l_union_select_stmt||'
		sum(y_bklg_qty) + sum(book_qty_ytd)
		  - sum(fulf_qty_ytd)		CURR_BKLG_QTY,
		sum(c_y_bklg) + sum(c_book_ytd)
		  - sum(c_fulf_ytd)		CURR_BKLG_VALUE,
		sum(p_y_bklg) + sum(p_book_ytd)
		  - sum(p_fulf_ytd)		PREV_BKLG_VALUE,
		sum(curr_pdue_qty)		CURR_PDUE_QTY,
		sum(curr_pdue_value)		CURR_PDUE_VALUE,
		sum(prev_pdue_value)		PREV_PDUE_VALUE
	   FROM /* Compute year backlog balance */
		('||l_inner_select_stmt||'
		decode(time.report_date, &BIS_CURRENT_ASOF_DATE,
			fact.bklog_qty, 0)	Y_BKLG_QTY,
		0				BOOK_QTY_YTD,
		0				FULF_QTY_YTD,
		decode(time.report_date, &BIS_CURRENT_ASOF_DATE,
			fact.bklg_amt_'||l_curr_suffix||', 0)	C_Y_BKLG,
		decode(time.report_date, &BIS_PREVIOUS_ASOF_DATE,
			fact.bklg_amt_'||l_curr_suffix||', 0)	P_Y_BKLG,
		0				C_BOOK_YTD,
		0				P_BOOK_YTD,
		0				C_FULF_YTD,
		0				P_FULF_YTD,
		NULL				CURR_PDUE_QTY,
		NULL				CURR_PDUE_VALUE,
		NULL				PREV_PDUE_VALUE
	   FROM '||l_mv1||'		fact,
		FII_TIME_DAY			time'||l_prod_cat_from||'
	  WHERE time.report_date IN (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
	    AND time.ent_year_start_date = fact.time_snapshot_date_id'
	    	||l_flags_where
		||l_inv_org_where
		||l_prod_cat_where
		||l_prod_where
		||l_cust_where||'
	UNION ALL /* Computer YTD net Booking */'
		||l_inner_select_stmt||'
		0				Y_BKLG_QTY,
		decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
			fact.booked_qty2, 0)	BOOK_QTY_YTD,
		0				FULF_QTY_YTD,
		0				C_Y_BKLG,
		0				P_Y_BKLG,
		decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
		       fact.booked_amt2_'||l_curr_suffix||', 0)	C_BOOK_YTD,
		decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
		       fact.booked_amt2_'||l_curr_suffix||', 0)	P_BOOK_YTD,
		0				C_FULF_YTD,
		0				P_FULF_YTD,
		NULL				CURR_PDUE_QTY,
		NULL				CURR_PDUE_VALUE,
		NULL				PREV_PDUE_VALUE
	   FROM '||l_mv_book||'		fact,
		FII_TIME_RPT_STRUCT_V		cal'||l_prod_cat_from||'
	  WHERE	cal.report_date IN (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
	    AND fact.time_id = cal.time_id
	    AND fact.period_type_id = cal.period_type_id
	    AND bitand(cal.record_type_id, 119) = cal.record_type_id'
	    	||l_flags_where2
		||l_inv_org_where
		||l_prod_cat_where
		||l_prod_where
		||l_cust_where||'
	UNION ALL /* Computer YTD net Fulfillment */'
		||l_inner_select_stmt||'
		0				Y_BKLG_QTY,
		0				BOOK_QTY_YTD,
		decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
			fact.booked_qty, 0)	FULF_QTY_YTD,
		0				C_Y_BKLG,
		0				P_Y_BKLG,
		0				C_BOOK_YTD,
		0				P_BOOK_YTD,
		decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
			fact.booked_amt_'||l_curr_suffix||', 0)	C_FULF_YTD,
		decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
			fact.booked_amt_'||l_curr_suffix||', 0)	P_FULF_YTD,
		NULL				CURR_PDUE_QTY,
		NULL				CURR_PDUE_VALUE,
		NULL				PREV_PDUE_VALUE
	   FROM '||l_mv_fulf||'		fact,
		FII_TIME_RPT_STRUCT_V		cal'||l_prod_cat_from||'
	  WHERE	cal.report_date IN (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
	    AND fact.time_id = cal.time_id
	    AND fact.period_type_id = cal.period_type_id
	    AND bitand(cal.record_type_id, 119) = cal.record_type_id'
	    	||l_flags_where2
		||l_inv_org_where
		||l_prod_cat_where
		||l_prod_where
		||l_cust_where||'
	UNION ALL'
		||l_inner_select_stmt||'
		0				Y_BKLG_QTY,
		0				BOOK_QTY_YTD,
		0				FULF_QTY_YTD,
		0				C_Y_BKLG,
		0				P_Y_BKLG,
		0				C_BOOK_YTD,
		0				P_BOOK_YTD,
		0				C_FULF_YTD,
		0				P_FULF_YTD,
		decode(fact.time_snapshot_date_id, a.day,
		       fact.pdue_qty, NULL)	CURR_PDUE_QTY,
		decode(fact.time_snapshot_date_id, a.day,
		       fact.pdue_amt_'||l_curr_suffix||', NULL)	CURR_PDUE_VALUE,
		decode(fact.time_snapshot_date_id, b.day,
		       fact.pdue_amt_'||l_curr_suffix||', NULL)	PREV_PDUE_VALUE
	   FROM (SELECT max(time_snapshot_date_id)		day
		   FROM	'||l_mv2||'			fact
		  WHERE	fact.time_snapshot_date_id BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE
						       AND &BIS_CURRENT_ASOF_DATE
					)	a,
		(SELECT max(time_snapshot_date_id)		day
		   FROM	'||l_mv2||'			fact
		  WHERE	fact.time_snapshot_date_id BETWEEN &BIS_PREVIOUS_EFFECTIVE_START_DATE
						       AND &BIS_PREVIOUS_ASOF_DATE
					)	b,
		'||l_mv2||'		fact'||l_prod_cat_from||'
	  WHERE fact.time_snapshot_date_id IN (a.day, b.day)
	    AND fact.late_schedule_flag = 1'
		||l_flags_where
		||l_inv_org_where
		||l_prod_cat_where
		||l_prod_where
		||l_cust_where||')'	-- end of A UNION ALL B
		||l_union_group_by_stmt||')	c))	a,'
		||l_where_stmt;

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

END ISC_DBI_BACKLOG_PDUE_PKG;

/
