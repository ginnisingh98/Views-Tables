--------------------------------------------------------
--  DDL for Package Body ISC_DBI_RETURN_VALUE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_RETURN_VALUE_PKG" AS
/* $Header: ISCRGABB.pls 120.1 2006/06/26 06:57:50 abhdixi noship $ */

PROCEDURE GET_SQL( p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
		   x_custom_sql		OUT NOCOPY	VARCHAR2,
		   x_custom_output 	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt 		VARCHAR2(32000);
  l_measures		VARCHAR2(32000);
  l_select_stmt		VARCHAR2(32000);
  l_inner_sql		VARCHAR2(32000);
  l_inner_select_stmt	VARCHAR2(32000);
  l_inner_group_by_stmt	VARCHAR2(32000);
  l_union_select_stmt	VARCHAR2(32000);
  l_union_group_by_stmt	VARCHAR2(32000);
  l_where_stmt		VARCHAR2(32000);
  l_mv1			VARCHAR2(100);
  l_flags_where		VARCHAR2(1000);
  l_view_by		VARCHAR2(32000);
  l_org 		VARCHAR2(32000);
  l_org_where		VARCHAR2(32000);
  l_prod		VARCHAR2(32000);
  l_prod_where		VARCHAR2(32000);
  l_cust_where		VARCHAR2(32000);
  l_cust		VARCHAR2(32000);
  l_prod_cat		VARCHAR2(32000);
  l_prod_cat_from	VARCHAR2(32000);
  l_prod_cat_where	VARCHAR2(32000);
  l_ret_reason		VARCHAR2(32000);
  l_ret_reason_where	VARCHAR2(32000);
  l_curr		VARCHAR2(50);
  l_curr_suffix		VARCHAR2(10);
  l_lang		VARCHAR2(10);
  l_item_cat_flag	NUMBER; -- 0 for product and 1 for product category
  l_cust_flag		NUMBER; -- 0 for customer and 1 for no customer selected
  l_reason_flag		NUMBER; -- 0 for reason and 1 for all reasons
  l_custom_rec 		BIS_QUERY_ATTRIBUTES ;

BEGIN

  l_lang := userenv('LANG');

  FOR i IN 1..p_param.COUNT
  LOOP
    IF( p_param(i).parameter_name= 'VIEW_BY')
      THEN l_view_by := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION')
      THEN l_org := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_VBH_CAT')
      THEN l_prod_cat := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_ORG')
      THEN l_prod := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES')
      THEN l_curr := p_param(i).parameter_id;
    END IF;

    IF(p_param(i).parameter_name = 'CUSTOMER+FII_CUSTOMERS')
      THEN l_cust := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ORDER_ITEM_RETURN_REASON+ORDER_ITEM_RETURN_REASON')
      THEN l_ret_reason := p_param(i).parameter_id;
    END IF;
  END LOOP;

  IF(l_curr = '''FII_GLOBAL1''')
    THEN l_curr_suffix := 'g';
    ELSIF (l_curr = '''FII_GLOBAL2''')
    THEN l_curr_suffix := 'g1';
    ELSE l_curr_suffix := 'f';
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

  IF (l_org IS NULL OR l_org = '' OR l_org = 'All')
    THEN l_org_where := '
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
    ELSE l_org_where := '
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

  IF ( l_prod IS NULL OR l_prod = '' OR l_prod = 'All' )
    THEN l_prod_where := '';
    ELSE l_prod_where := '
	    AND fact.item_id in (&ITEM+ENI_ITEM_ORG)';
  END IF;

  IF (l_cust IS NULL OR l_cust = '' OR l_cust = 'All')
    THEN
      l_cust_where:='';
      IF(l_view_by = 'CUSTOMER+FII_CUSTOMERS')
	THEN l_cust_flag := 0; -- customer selected
	ELSE l_cust_flag := 1; -- all customers and not viewed by customer
      END IF;
    ELSE
      l_cust_where :='
	    AND fact.customer_id in (&CUSTOMER+FII_CUSTOMERS)';
      l_cust_flag := 0; -- customer selected
  END IF;

  IF ( l_ret_reason IS NULL OR l_ret_reason = '' OR l_ret_reason = 'All' )
    THEN l_ret_reason_where := '';
	 l_reason_flag := 1;
    ELSE l_ret_reason_where := '
	    AND fact.return_reason IN (&ORDER_ITEM_RETURN_REASON+ORDER_ITEM_RETURN_REASON)';
	 l_reason_flag := 0;
  END IF;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  l_measures := 'ISC_MEASURE_1,ISC_MEASURE_2,ISC_MEASURE_3,ISC_MEASURE_4,ISC_MEASURE_5,
		 ISC_MEASURE_6,ISC_MEASURE_7,ISC_MEASURE_8,ISC_MEASURE_9,ISC_MEASURE_10,
		 ISC_MEASURE_11,ISC_MEASURE_12,ISC_MEASURE_13,ISC_MEASURE_14,ISC_MEASURE_15';

  IF l_view_by = 'ORGANIZATION+ORGANIZATION'
    THEN l_select_stmt := '
 SELECT	org.name						VIEWBY,
	org.organization_id					VIEWBYID,
	NULL							ISC_ATTRIBUTE_3, -- item description
	NULL							ISC_ATTRIBUTE_4, -- item uom
	NULL							ISC_ATTRIBUTE_6, -- drill across url
	'||l_measures||'
   FROM
(SELECT (rank() over (&ORDER_BY_CLAUSE nulls last, inv_org_id)) - 1		rnk,
	inv_org_id,
	'||l_measures||'
   FROM
(SELECT	c.inv_org_id,	';
	l_inner_select_stmt := '
		 SELECT	fact.inv_org_id			INV_ORG_ID,';
	l_union_select_stmt := '
		 SELECT	inv_org_id			INV_ORG_ID,';
	l_inner_group_by_stmt := '
		GROUP BY fact.inv_org_id';
	l_union_group_by_stmt := '
		GROUP BY inv_org_id';
	l_where_stmt := '
	HR_ALL_ORGANIZATION_UNITS_TL	org
  WHERE a.inv_org_id = org.organization_id
    AND org.language = :ISC_LANG
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
 ORDER BY rnk';

  ELSIF l_view_by = 'ITEM+ENI_ITEM_ORG'
    THEN l_select_stmt := '
 SELECT	items.value						VIEWBY,
	items.id						VIEWBYID,
	items.description					ISC_ATTRIBUTE_3, -- item description
	mtl.unit_of_measure					ISC_ATTRIBUTE_4, -- item uom
	NULL							ISC_ATTRIBUTE_6, -- drill across url
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
		 SELECT	fact.item_id			ITEM_ID,
			fact.uom				UOM,';
	l_union_select_stmt := '
		 SELECT item_id				ITEM_ID,
			uom				UOM,';
	l_inner_group_by_stmt := '
		GROUP BY fact.item_id, fact.uom';
	l_union_group_by_stmt := '
		GROUP BY item_id, uom';
	l_where_stmt := '
	ENI_ITEM_ORG_V			items,
	MTL_UNITS_OF_MEASURE_TL		mtl
  WHERE	a.uom = mtl.uom_code
    AND mtl.language = :ISC_LANG
    AND	a.item_id = items.id
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
 ORDER BY rnk';

  ELSIF l_view_by = 'CUSTOMER+FII_CUSTOMERS'
    THEN l_select_stmt := '
 SELECT	cust.value						VIEWBY,
	cust.id							VIEWBYID,
	NULL							ISC_ATTRIBUTE_3, -- item description
	NULL							ISC_ATTRIBUTE_4, -- item uom
	NULL							ISC_ATTRIBUTE_6, -- drill across url
	'||l_measures||'
   FROM
(SELECT	(rank() over (&ORDER_BY_CLAUSE nulls last, customer_id)) - 1		rnk,
	customer_id,
	'||l_measures||'
   FROM
(SELECT	c.customer_id,	';
	l_inner_select_stmt := '
		 SELECT	fact.customer_id			CUSTOMER_ID,';
	l_union_select_stmt := '
		 SELECT customer_id			CUSTOMER_ID,';
	l_inner_group_by_stmt := '
		GROUP BY fact.customer_id';
	l_union_group_by_stmt := '
		GROUP BY customer_id';
	l_where_stmt := '
 	FII_CUSTOMERS_V 		cust
  WHERE a.customer_id = cust.id
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
 ORDER BY rnk';

  ELSE -- l_view_by = 'ITEM+ENI_ITEM_VBH_CAT'
    l_select_stmt := '
 SELECT	ecat.value					VIEWBY,
	ecat.id						VIEWBYID,
	NULL							ISC_ATTRIBUTE_3, -- item description
	NULL							ISC_ATTRIBUTE_4, -- item uom
	decode(ecat.leaf_node_flag, ''Y'',
		''pFunctionName=ISC_DBI_RETURN_VALUE_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_ORG&pParamIds=Y'',
		''pFunctionName=ISC_DBI_RETURN_VALUE_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&pParamIds=Y'')
								ISC_ATTRIBUTE_6, -- drill across url
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
	l_union_select_stmt := '
		 SELECT item_category_id				ITEM_CATEGORY_ID,';
	l_union_group_by_stmt := '
		GROUP BY item_category_id';
	l_where_stmt := '
	ENI_ITEM_VBH_NODES_V 		ecat
  WHERE a.item_category_id = ecat.id
    AND ecat.parent_id = ecat.child_id
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
 ORDER BY rnk';
  END IF;

  IF ((l_view_by = 'ITEM+ENI_ITEM_VBH_CAT' OR l_view_by = 'ORGANIZATION+ORGANIZATION') AND
      (l_prod IS NULL OR l_prod = '' OR l_prod = 'All') AND
      (l_cust IS NULL OR l_cust = '' OR l_cust = 'All') AND
      (l_ret_reason IS NULL OR l_ret_reason = '' OR l_ret_reason = 'All'))
    THEN
    	IF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') THEN
	  IF (l_prod_cat IS NULL OR l_prod_cat = '' OR l_prod_cat = 'All')
	    THEN
	      l_inner_select_stmt := '
		 SELECT	fact.parent_id					ITEM_CATEGORY_ID,';
	      l_inner_group_by_stmt := '
		GROUP BY fact.parent_id';
	    ELSE
	      l_inner_select_stmt := '
		 SELECT	fact.imm_child_id				ITEM_CATEGORY_ID,';
	      l_inner_group_by_stmt := '
		GROUP BY fact.imm_child_id';
	  END IF;
	END IF;

        IF (l_prod_cat IS NULL OR l_prod_cat = '' OR l_prod_cat = 'All')
	  THEN
	    l_prod_cat_from := '';
	    l_prod_cat_where := '
		    AND fact.top_node_flag = ''Y''';
	  ELSE
	    l_prod_cat_from := '';
	    l_prod_cat_where := '
		    AND fact.parent_id = &ITEM+ENI_ITEM_VBH_CAT';
	END IF;

	l_mv1 := 'ISC_DBI_CFM_011_MV';
	l_flags_where := '
	    AND	fact.inv_org_flag = 0';
    ELSE
	l_mv1 := 'ISC_DBI_CFM_002_MV';
	l_flags_where := '
	    AND fact.item_cat_flag = :ISC_ITEM_CAT_FLAG
	    AND fact.customer_flag = :ISC_CUST_FLAG';
  END IF;

  IF l_reason_flag = 0 -- use of ISC_DBI_CFM_007_MV (return reason)
    THEN l_inner_sql := l_union_select_stmt||'
	 	sum(curr_return)					CURR_RETURN,
		sum(prev_return)					PREV_RETURN,
		sum(curr_ship)						CURR_SHIP,
		sum(prev_ship)						PREV_SHIP,
		sum(lines_cnt)						LINES_CNT,
		sum(return_qty)						RETURN_QTY
	   FROM ('||l_inner_select_stmt||'
		sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
			   fact.returned_amt_'||l_curr_suffix||', 0))		CURR_RETURN,
		sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
			   fact.returned_amt_'||l_curr_suffix||', 0))		PREV_RETURN,
		0								CURR_SHIP,
		0								PREV_SHIP,
		sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
			   fact.lines_cnt, 0))					LINES_CNT,
		sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
			   fact.returned_qty, 0))					RETURN_QTY
	   FROM ISC_DBI_CFM_007_MV	fact,
		FII_TIME_RPT_STRUCT_V	cal'||l_prod_cat_from||'
	  WHERE fact.time_id = cal.time_id
	    AND fact.period_type_id = cal.period_type_id
	    AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN) = cal.record_type_id
	    AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
	    AND fact.customer_flag = :ISC_CUST_FLAG
	    AND fact.item_cat_flag = :ISC_ITEM_CAT_FLAG
	    AND fact.return_reason_flag = :ISC_REASON_FLAG'
		||l_org_where
		||l_prod_cat_where
		||l_prod_where
		||l_cust_where
		||l_ret_reason_where
		||l_inner_group_by_stmt||'
	  UNION ALL
	 	'||l_inner_select_stmt||'
		0								CURR_RETURN,
		0								PREV_RETURN,
		sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
			   fact.fulfilled_amt2_'||l_curr_suffix||', 0))		CURR_SHIP,
		sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
			   fact.fulfilled_amt2_'||l_curr_suffix||', 0))		PREV_SHIP,
		0								LINES_CNT,
		0								RETURN_QTY
	   FROM ISC_DBI_CFM_002_MV 	fact,
		FII_TIME_RPT_STRUCT_V	cal'||l_prod_cat_from||'
	  WHERE fact.time_id = cal.time_id
	    AND fact.return_flag = 0
	    AND fact.period_type_id = cal.period_type_id
	    AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN) = cal.record_type_id
	    AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
	    AND fact.customer_flag = :ISC_CUST_FLAG
	    AND fact.item_cat_flag = :ISC_ITEM_CAT_FLAG'
		||l_org_where
		||l_prod_cat_where
		||l_prod_where
		||l_cust_where
		||l_inner_group_by_stmt||')'
		||l_union_group_by_stmt;

    ELSE -- l_reason_flag = 1 -- use of ISC_DBI_CFM_002_MV (no return reason)
      l_inner_sql := l_inner_select_stmt||'
		sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
			   decode(fact.return_flag, 1,
				  fact.returned_amt_'||l_curr_suffix||', 0), 0))		CURR_RETURN,
		sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
			   decode(fact.return_flag, 1,
				  fact.returned_amt_'||l_curr_suffix||', 0), 0))		PREV_RETURN,
		sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
			   decode(fact.return_flag, 0,
				  fact.fulfilled_amt2_'||l_curr_suffix||', 0), 0))		CURR_SHIP,
		sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
			   decode(fact.return_flag, 0,
				  fact.fulfilled_amt2_'||l_curr_suffix||', 0), 0))		PREV_SHIP,
		sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
			   decode(fact.return_flag, 1,
				  fact.lines_cnt, 0), 0))					LINES_CNT,
		sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
			   decode(fact.return_flag, 1,
				  fact.returned_qty, 0), 0))				RETURN_QTY
	   FROM '||l_mv1||'	 	fact,
		FII_TIME_RPT_STRUCT_V	cal'||l_prod_cat_from||'
	  WHERE fact.time_id = cal.time_id
	    AND fact.period_type_id = cal.period_type_id
	    AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN) = cal.record_type_id
	    AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)'
		||l_flags_where
		||l_org_where
		||l_prod_cat_where
		||l_prod_where
		||l_cust_where
		||l_inner_group_by_stmt;
  END IF;

  l_stmt := l_select_stmt||'
	c.return_qty						ISC_MEASURE_1, -- return qty
	c.curr_return						ISC_MEASURE_2, -- return value
	(c.curr_return - c.prev_return)
	  / decode(c.prev_return, 0, NULL,
		   abs(c.prev_return)) * 100			ISC_MEASURE_3, -- return value change
	c.curr_return
	  / decode(c.curr_ship, 0, NULL,
		   c.curr_ship) * 100				ISC_MEASURE_4, -- return rate
	c.curr_return
	  / decode(c.curr_ship, 0, NULL,
		   c.curr_ship) * 100 -
	c.prev_return
	  / decode(c.prev_ship, 0, NULL,
		   c.prev_ship) * 100				ISC_MEASURE_5, -- return rate change
	c.lines_cnt						ISC_MEASURE_6, -- past due lines
	sum(c.curr_return) over () 				ISC_MEASURE_7, -- gd total return value
	(sum(c.curr_return) over () - sum(c.prev_return) over ())
	  / decode(sum(c.prev_return) over (), 0, NULL,
		   abs(sum(c.prev_return) over ())) * 100	ISC_MEASURE_8, -- gd total return change
	sum(c.curr_return) over ()
	  / decode(sum(c.curr_ship) over (), 0, NULL,
		   sum(c.curr_ship) over ()) * 100		ISC_MEASURE_9, -- gd total return rate
	sum(c.curr_return) over ()
	  / decode(sum(c.curr_ship) over (), 0, NULL,
		   sum(c.curr_ship) over ()) * 100 -
	sum(c.prev_return) over()
	  / decode(sum(c.prev_ship) over (), 0, NULL,
		   sum(c.prev_ship) over ()) * 100		ISC_MEASURE_10, -- gd total return rate change
	c.curr_return						ISC_MEASURE_11, -- KPI return value
	c.prev_return						ISC_MEASURE_12, -- KPI return value - prior
	sum(c.lines_cnt) over ()				ISC_MEASURE_13,	-- gd total past due lines
	sum(c.curr_return) over ()				ISC_MEASURE_14, -- gd total KPI return value
	sum(c.prev_return) over ()				ISC_MEASURE_15	-- gd total KPI return value - prior
   FROM	('||l_inner_sql||') c)
  WHERE	ISC_MEASURE_2 <> 0
     OR	ISC_MEASURE_3 IS NOT NULL
     OR	ISC_MEASURE_4 IS NOT NULL
     OR	ISC_MEASURE_5 IS NOT NULL
     OR	ISC_MEASURE_6 <> 0)	a,'
	||l_where_stmt;

  x_custom_sql := l_stmt;

  l_custom_rec.attribute_name := ':ISC_ITEM_CAT_FLAG';
  l_custom_rec.attribute_value := to_char(l_item_cat_flag);
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_CUST_FLAG';
  l_custom_rec.attribute_value := to_char(l_cust_flag);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_REASON_FLAG';
  l_custom_rec.attribute_value := to_char(l_reason_flag);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_LANG';
  l_custom_rec.attribute_value := l_lang;
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

END get_sql;

END ISC_DBI_RETURN_VALUE_PKG ;


/
