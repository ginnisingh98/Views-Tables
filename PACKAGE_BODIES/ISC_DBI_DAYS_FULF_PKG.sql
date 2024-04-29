--------------------------------------------------------
--  DDL for Package Body ISC_DBI_DAYS_FULF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_DAYS_FULF_PKG" AS
/* $Header: ISCRG73B.pls 120.0 2005/05/25 17:28:20 appldev noship $ */

PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt			VARCHAR2(10000);
  l_measures			VARCHAR2(10000);
  l_select_stmt			VARCHAR2(10000);
  l_inner_select_stmt		VARCHAR2(10000);
  l_inner_group_by_stmt		VARCHAR2(10000);
  l_where_stmt			VARCHAR2(10000);
  l_inv_org			VARCHAR2(10000);
  l_inv_org_where		VARCHAR2(10000);
  l_prod			VARCHAR2(10000);
  l_prod_where			VARCHAR2(10000);
  l_prod_cat			VARCHAR2(10000);
  l_prod_cat_from		VARCHAR2(10000);
  l_prod_cat_where		VARCHAR2(10000);
  l_cust			VARCHAR2(10000);
  l_cust_where			VARCHAR2(10000);
  l_mv				VARCHAR2(10000);
  l_flags_where			VARCHAR2(10000);
  l_view_by			VARCHAR2(120);
  l_lang			VARCHAR2(10);
  l_item_cat_flag		NUMBER;
  l_cust_flag			NUMBER;

  l_custom_rec			BIS_QUERY_ATTRIBUTES;

BEGIN

  l_lang := userenv('LANG');

  FOR i IN 1..p_param.COUNT
  LOOP
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

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  l_measures := 'ISC_MEASURE_1,ISC_MEASURE_2,ISC_MEASURE_3,ISC_MEASURE_4,ISC_MEASURE_5,
		 ISC_MEASURE_6,ISC_MEASURE_7,ISC_MEASURE_8,CURRENCY,FND_CATEGORY,FND_PRODUCT';

  IF l_view_by = 'ITEM+ENI_ITEM_ORG'
    THEN l_select_stmt := '
 SELECT	items.value						VIEWBY,
	NULL							ISC_ATTRIBUTE_2,
	NULL							ISC_ATTRIBUTE_3, -- drill across url
	items.description					ISC_ATTRIBUTE_4, -- item description
	'||l_measures||'
   FROM
(SELECT	(rank() over (&ORDER_BY_CLAUSE nulls last, item_id)) - 1		rnk,
	item_id,
	'||l_measures||'
   FROM
(SELECT	c.item_id,';
	l_inner_select_stmt := '
		 SELECT	fact.item_id					ITEM_ID,';
	l_inner_group_by_stmt := '
		GROUP BY fact.item_id';
	l_where_stmt := '
	ENI_ITEM_ORG_V			items
  WHERE a.item_id = items.id
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
  ORDER BY rnk';

  ELSIF l_view_by = 'ORGANIZATION+ORGANIZATION'
    THEN l_select_stmt := '
 SELECT	org.name						VIEWBY,
	NULL							ISC_ATTRIBUTE_2,
	NULL							ISC_ATTRIBUTE_3, -- drill across url
	NULL							ISC_ATTRIBUTE_4, -- item description
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
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
  ORDER BY rnk';

  ELSIF l_view_by = 'CUSTOMER+FII_CUSTOMERS'
    THEN l_select_stmt := '
 SELECT	cust.value						VIEWBY,
	NULL							ISC_ATTRIBUTE_2,
	NULL							ISC_ATTRIBUTE_3, -- drill across url
	NULL							ISC_ATTRIBUTE_4, -- item description
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
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
  ORDER BY rnk';

  ELSE -- l_view_by = 'ITEM+ENI_ITEM_VBH_CAT'
    l_select_stmt := '
 SELECT	ecat.value					VIEWBY,
	ecat.id						VIEWBYID,
	NULL						ISC_ATTRIBUTE_2,
	decode(ecat.leaf_node_flag, ''Y'',
		''pFunctionName=ISC_DBI_DAYS_FULF&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_ORG&pParamIds=Y'',
		''pFunctionName=ISC_DBI_DAYS_FULF&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&pParamIds=Y'')
								ISC_ATTRIBUTE_3, -- drill across url
	NULL							ISC_ATTRIBUTE_4, -- item description
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
    AND	ecat.parent_id = ecat.child_id
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
  ORDER BY rnk';
  END IF;

  IF ((l_view_by = 'ITEM+ENI_ITEM_VBH_CAT' OR l_view_by = 'ORGANIZATION+ORGANIZATION') AND
      (l_prod IS NULL OR l_prod = '' OR l_prod = 'All') AND
      (l_cust IS NULL OR l_cust = '' OR l_cust = 'All'))
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
		 SELECT fact.imm_child_id				ITEM_CATEGORY_ID,';
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
	l_mv := 'ISC_DBI_CFM_011_MV';
	l_flags_where := '
	    AND	fact.inv_org_flag = 0';
    ELSE
	l_mv := 'ISC_DBI_CFM_002_MV';
	l_flags_where := '
	    AND fact.item_cat_flag = :ISC_ITEM_CAT_FLAG
	    AND fact.customer_flag = :ISC_CUST_FLAG';
  END IF;

  l_stmt := l_select_stmt || '
	c.curr_fulf_days
	  / decode(c.curr_fulf_cnt, 0, NULL,
		   c.curr_fulf_cnt)				ISC_MEASURE_1, -- days fulf
	c.curr_fulf_days
	  / decode(c.curr_fulf_cnt, 0, NULL,
		   c.curr_fulf_cnt) -
	c.prev_fulf_days
	  / decode(c.prev_fulf_cnt, 0, NULL,
		   c.prev_fulf_cnt)				ISC_MEASURE_2, -- days fulf change
	sum(c.curr_fulf_days) over ()
	  / decode(sum(c.curr_fulf_cnt) over (), 0, NULL,
		   sum(c.curr_fulf_cnt) over ())		ISC_MEASURE_3, -- gd total days fulf
	sum(c.curr_fulf_days) over ()
	  / decode(sum(c.curr_fulf_cnt) over (), 0, NULL,
		   sum(c.curr_fulf_cnt) over ()) -
	sum(c.prev_fulf_days) over ()
	  / decode(sum(c.prev_fulf_cnt) over (), 0, NULL,
		   sum(c.prev_fulf_cnt) over ())		ISC_MEASURE_4, -- gd total days fulf change
	NULL							ISC_MEASURE_5,
	NULL							ISC_MEASURE_6,
	NULL							ISC_MEASURE_7,
	NULL							ISC_MEASURE_8,
	NULL							CURRENCY,	-- obsoleted from 5.0
	NULL							FND_CATEGORY,	-- obsoleted from 5.0
	NULL							FND_PRODUCT	-- obsoleted from 5.0
	   FROM	('||l_inner_select_stmt||'
		sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
			   fact.book_to_fulfill_days, 0))		CURR_FULF_DAYS,
		sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
			   fact.book_to_fulfill_days, 0))		PREV_FULF_DAYS,
		sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
			   fact.book_to_fulfill_cnt, 0))		CURR_FULF_CNT,
		sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
			   fact.book_to_fulfill_cnt, 0))		PREV_FULF_CNT
	   FROM '||l_mv||'			fact,
		FII_TIME_RPT_STRUCT_V		cal'||l_prod_cat_from||'
	  WHERE fact.time_id = cal.time_id
	    AND fact.return_flag = 0'||l_flags_where||'
	    AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
	    AND cal.period_type_id = fact.period_type_id
	    AND bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id'
		||l_inv_org_where
		||l_prod_cat_where
		||l_prod_where
		||l_cust_where
		||l_inner_group_by_stmt||')	c)
	  WHERE	ISC_MEASURE_1 IS NOT NULL
	     OR	ISC_MEASURE_2 IS NOT NULL)	a,'
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

END ISC_DBI_DAYS_FULF_PKG;

/
