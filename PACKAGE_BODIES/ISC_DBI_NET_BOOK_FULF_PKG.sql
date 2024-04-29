--------------------------------------------------------
--  DDL for Package Body ISC_DBI_NET_BOOK_FULF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_NET_BOOK_FULF_PKG" AS
/* $Header: ISCRGBEB.pls 120.0 2005/05/25 17:13:00 appldev noship $ */

PROCEDURE GET_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,x_custom_sql OUT NOCOPY VARCHAR2,
	x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_inner_sql		VARCHAR2(32000);
  l_stmt 		VARCHAR2(32000);
  l_view_by		VARCHAR2(32000);
  l_sgid 		VARCHAR2(32000);
  l_sg_where     	VARCHAR2(32000);
  l_prod_cat		VARCHAR2(32000);
  l_prod_cat_from	VARCHAR2(32000);
  l_prod_cat_where	VARCHAR2(32000);
  l_cust		VARCHAR2(32000);
  l_cust_where		VARCHAR2(32000);
  l_class		VARCHAR2(32000);
  l_class_where		VARCHAR2(32000);
  l_viewby_col		VARCHAR2(200);
  l_sg_sg		NUMBER;
  l_sg_res		NUMBER;
  l_item_cat_flag	NUMBER;
  l_cust_flag		NUMBER; -- 0 for customer, 1 for cust classification, 3 for all
  l_drill_ord		VARCHAR2(10000);
  l_drill_ret		VARCHAR2(10000);
  l_cat_join		VARCHAR2(50);
  l_flags		VARCHAR2(32000);
  l_mv			VARCHAR2(100);
  l_curr		VARCHAR2(10000);
  l_curr_suffix		VARCHAR2(120);
  l_invalid_curr	BOOLEAN;
  l_custom_rec 		BIS_QUERY_ATTRIBUTES ;


BEGIN

  l_invalid_curr := FALSE;

  FOR i IN 1..p_param.COUNT
  LOOP

    IF( p_param(i).parameter_name= 'VIEW_BY') THEN
      l_view_by := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ORGANIZATION+JTF_ORG_SALES_GROUP') THEN
      l_sgid :=  p_param(i).parameter_id;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_VBH_CAT') THEN
       l_prod_cat :=  p_param(i).parameter_id;
    END IF;

    IF(p_param(i).parameter_name = 'CUSTOMER+FII_CUSTOMERS') THEN
       l_cust :=  p_param(i).parameter_id;
    END IF;

    IF(p_param(i).parameter_name = 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS') THEN
       l_class :=  p_param(i).parameter_id;
    END IF;

    IF (p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES')
      THEN l_curr := p_param(i).parameter_id;
    END IF;

  END LOOP;

  IF (l_curr = '''FII_GLOBAL1''')
    THEN l_curr_suffix := 'g';
  ELSIF (l_curr = '''FII_GLOBAL2''')
    THEN l_curr_suffix := 'g1';
  ELSE
    l_invalid_curr := TRUE;
  END IF;

  l_sg_sg   := to_number(replace(substr(l_sgid,instr(l_sgid,'.') + 1),''''));
  l_sg_res  := to_number(replace(substr(l_sgid,1,instr(l_sgid,'.') - 1),''''));

  IF (l_sg_res IS NULL) -- when a sales group is chosen
    THEN
      l_drill_ord := 'NULL';
      l_drill_ret := 'NULL';
      IF l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP'
        THEN
          l_sg_where := '
		AND f.parent_grp_id = (&ORGANIZATION+JTF_ORG_SALES_GROUP)
		AND f.grp_marker <> ''TOP GROUP'''; -- exclude the top groups when VB=SG
      ELSE -- other view bys
          l_sg_where := '
		AND f.sales_grp_id = (&ORGANIZATION+JTF_ORG_SALES_GROUP)
		AND f.resource_id IS NULL';
      END IF;
  ELSE -- when the LOV parameter is a SRep (no need to go through the SG hierarchy MV
      l_drill_ord := '''pFunctionName=ISC_DBI_BK_DETAIL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''';
      l_drill_ret := '''pFunctionName=ISC_DBI_RET_DETAIL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''';
      l_sg_where := '
		AND f.sales_grp_id = :ISC_SG
		AND f.resource_id = :ISC_RES';
  END IF;


  IF (l_cust IS NULL)
    THEN
      l_cust_where:='';
      IF (l_view_by = 'CUSTOMER+FII_CUSTOMERS')
	THEN l_cust_flag := 0; -- customer
      ELSIF (l_view_by = 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS')
        THEN l_cust_flag := 1; -- customer classification
      ELSE
	IF (l_class IS NULL)
	  THEN l_cust_flag := 3; -- all
	  ELSE l_cust_flag := 1; -- customer classification
	END IF;
      END IF;
  ELSE
    l_cust_where :='
		AND f.customer_id in (&CUSTOMER+FII_CUSTOMERS)';
    l_cust_flag := 0; -- customer
  END IF;

  IF (l_class IS NULL) THEN
    l_class_where:='';
  ELSE
    l_class_where :='
		AND f.class_code in (&FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS)';
  END IF;


  IF (l_view_by <> 'CUSTOMER+FII_CUSTOMERS' AND l_cust IS NULL
      AND l_view_by <> 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS'
      AND l_class IS NULL) THEN -- use double rollup without cust
    l_flags := '';
    l_mv := 'ISC_DBI_SCR_002_MV';
    IF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') THEN
      l_prod_cat_from := ',
			ENI_DENORM_HIERARCHIES		eni_cat,
			MTL_DEFAULT_CATEGORY_SETS	mdcs';
	IF (l_prod_cat IS NULL) THEN
		l_prod_cat_where := '
		AND f.cat_top_node_flag = ''Y''
		AND f.item_category_id = eni_cat.imm_child_id
		AND eni_cat.top_node_flag = ''Y''
		AND eni_cat.dbi_flag = ''Y''
		AND eni_cat.object_type = ''CATEGORY_SET''
		AND eni_cat.object_id = mdcs.category_set_id
		AND mdcs.functional_area_id = 11';
	ELSE l_prod_cat_where := '
		AND f.item_category_id = eni_cat.imm_child_id
		AND ((eni_cat.leaf_node_flag = ''N'' and
			eni_cat.child_id <> eni_cat.parent_id and imm_child_id = child_id)
			OR (eni_cat.leaf_node_flag = ''Y''))
		AND eni_cat.parent_id IN (&ITEM+ENI_ITEM_VBH_CAT)
		AND eni_cat.dbi_flag = ''Y''
		AND eni_cat.object_type = ''CATEGORY_SET''
		AND eni_cat.object_id = mdcs.category_set_id
		AND mdcs.functional_area_id = 11';
	END IF;
    ELSE -- view by <> cat.
      l_prod_cat_from := ''; -- do not need to join to denorm table
      IF (l_prod_cat IS NULL) THEN
        l_prod_cat_where :='
		AND f.cat_top_node_flag = ''Y''';
      ELSE -- view by sales group, prod.cat selected
        l_prod_cat_where :='
		AND f.item_category_id IN (&ITEM+ENI_ITEM_VBH_CAT)';
      END IF;
    END IF;

  ELSE -- use single rollup with customer dimension
    l_flags := '
		AND f.item_cat_flag = :ISC_ITEM_CAT_FLAG
		AND f.customer_flag = :ISC_CUST';
    l_mv := 'ISC_DBI_SCR_001_MV';
    IF (l_prod_cat IS NULL) THEN
      IF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') THEN
        l_prod_cat_from := ',
		ENI_DENORM_HIERARCHIES		eni_cat,
		MTL_DEFAULT_CATEGORY_SETS	mdcs';
        l_prod_cat_where := '
	    AND f.item_category_id = eni_cat.child_id
	    AND eni_cat.top_node_flag = ''Y''
	    AND	eni_cat.dbi_flag = ''Y''
	    AND eni_cat.object_type = ''CATEGORY_SET''
	    AND	eni_cat.object_id = mdcs.category_set_id
	    AND	mdcs.functional_area_id = 11';
      ELSE
        l_prod_cat_from := '';
        l_prod_cat_where := '';
      END IF;
    ELSE -- a prod cat has been selected
      l_prod_cat_from := ',
		ENI_DENORM_HIERARCHIES		eni_cat,
		MTL_DEFAULT_CATEGORY_SETS	mdcs';
      l_prod_cat_where := '
	    AND f.item_category_id = eni_cat.child_id
	    AND eni_cat.parent_id IN (&ITEM+ENI_ITEM_VBH_CAT)
	    AND	eni_cat.dbi_flag = ''Y''
	    AND	eni_cat.object_type = ''CATEGORY_SET''
	    AND eni_cat.object_id = mdcs.category_set_id
	    AND	mdcs.functional_area_id = 11';
    END IF;
  END IF;


  IF (l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP') THEN
	l_viewby_col :='resource_id, sales_grp_id';

  ELSIF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') THEN
	IF (l_prod_cat is null) THEN
	l_viewby_col := 'parent_id';
	ElSE
	l_viewby_col :='imm_child_id';
	END IF;

  ELSIF (l_view_by = 'CUSTOMER+FII_CUSTOMERS') THEN
	l_viewby_col :='customer_id';

  ELSIF (l_view_by = 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS') THEN
	l_viewby_col :='class_code';

  END IF;

  IF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT' OR l_prod_cat IS NOT NULL)
    THEN l_item_cat_flag := 0; -- Product Category
    ELSE l_item_cat_flag := 1; -- All
  END IF;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  IF (l_invalid_curr)
    THEN l_stmt := '
/* Unsupported currency */
SELECT	0	VIEWBY,
	0	VIEWBYID,
	0	ISC_ATTRIBUTE_2,
	0	ISC_ATTRIBUTE_3,
	0	ISC_ATTRIBUTE_4,
	0	ISC_ATTRIBUTE_5,
	0 	ISC_MEASURE_2,
	0 	ISC_MEASURE_3,
	0 	ISC_MEASURE_4,
	0 	ISC_MEASURE_5,
	0 	ISC_MEASURE_6,
	0 	ISC_MEASURE_7,
	0 	ISC_MEASURE_8,
	0 	ISC_MEASURE_9,
	0 	ISC_MEASURE_10,
	0 	ISC_MEASURE_11,
	0 	ISC_MEASURE_12,
	0 	ISC_MEASURE_13
  FROM	dual
 WHERE	1 = 2';

  ELSE

  l_inner_sql:='
		ISC_MEASURE_2,ISC_MEASURE_3,ISC_MEASURE_4,ISC_MEASURE_5,ISC_MEASURE_6,ISC_MEASURE_7,
		ISC_MEASURE_8,ISC_MEASURE_9,ISC_MEASURE_10,ISC_MEASURE_11,ISC_MEASURE_12,ISC_MEASURE_13
		FROM(SELECT
		(rank() over (&ORDER_BY_CLAUSE nulls last,'||l_viewby_col||'))-1 rnk,
		'||l_viewby_col||',
		ISC_MEASURE_2,ISC_MEASURE_3,ISC_MEASURE_4,ISC_MEASURE_5,ISC_MEASURE_6,ISC_MEASURE_7,
		ISC_MEASURE_8,ISC_MEASURE_9,ISC_MEASURE_10,ISC_MEASURE_11,ISC_MEASURE_12,ISC_MEASURE_13
		FROM
		(SELECT '||l_viewby_col||',
		nvl(a.c_book, 0)					ISC_MEASURE_2,
		(a.c_book-a.p_book)
		  / abs(decode(a.p_book,0,null,a.p_book))*100		ISC_MEASURE_3,
		nvl(a.c_book_ret, 0)					ISC_MEASURE_4,
		(a.c_book_ret - a.p_book_ret)
		  / abs(decode(a.p_book_ret,0,null,a.p_book_ret))*100	ISC_MEASURE_5,
		nvl((a.c_book - a.c_book_ret), 0)			ISC_MEASURE_6,
		((a.c_book-a.c_book_ret) - (a.p_book-a.p_book_ret))
		  / abs(decode((a.p_book-a.p_book_ret), 0,
				null,(a.p_book-a.p_book_ret)))*100	ISC_MEASURE_7,
		nvl(sum(a.c_book) over (), 0)				ISC_MEASURE_8,
		(sum(a.c_book) over () - sum(a.p_book) over ())
		  / abs(decode(sum(a.p_book) over (), 0,
				null,sum(a.p_book) over ()))*100	ISC_MEASURE_9,
		nvl(sum(a.c_book_ret) over (), 0)			ISC_MEASURE_10,
		(sum(a.c_book_ret) over () - sum(a.p_book_ret) over ())
		  / abs(decode(sum(a.p_book_ret) over (), 0,
				null,sum(a.p_book_ret) over ()))*100	ISC_MEASURE_11,
		nvl(sum(a.c_book - a.c_book_ret) over (), 0)		ISC_MEASURE_12,
		(sum(a.c_book-a.c_book_ret) over () - sum(a.p_book-a.p_book_ret) over ())
		  / abs(decode(sum(a.p_book-a.p_book_ret) over (), 0,
			  null,sum(a.p_book-a.p_book_ret) over ()))*100	ISC_MEASURE_13
		FROM
		(SELECT '||l_viewby_col||',
		sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
			   nvl(booked_amt_'||l_curr_suffix||',0),0))	C_BOOK,
		sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
			   nvl(booked_amt_'||l_curr_suffix||',0),0))	P_BOOK,
		sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE,
			   nvl(returned_amt_'||l_curr_suffix||',0),0))	C_BOOK_RET,
		sum(decode(cal.report_date,&BIS_PREVIOUS_ASOF_DATE,
			   nvl(returned_amt_'||l_curr_suffix||',0),0))	P_BOOK_RET
		FROM '||l_mv||' 	f,
		FII_TIME_RPT_STRUCT_V		cal'
		||l_prod_cat_from||'
     		WHERE f.time_id = cal.time_id
		AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
		AND cal.period_type_id = f.period_type_id
		AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN) = cal.record_type_id'
		||l_flags
		||l_sg_where||l_prod_cat_where||l_cust_where||l_class_where||'
		GROUP BY '||l_viewby_col||') a)) c,';



  IF l_view_by = 'ITEM+ENI_ITEM_VBH_CAT' THEN
    IF (l_prod_cat is null) THEN
	l_cat_join := 'AND c.parent_id = ecat.id';
    ElSE
	l_cat_join := 'AND c.imm_child_id = ecat.id';
    END IF;

    l_stmt := '	SELECT ecat.value 	VIEWBY,
		ecat.id			VIEWBYID,
		null			ISC_ATTRIBUTE_2, -- Drill - Sales Group
		decode(ecat.leaf_node_flag, ''Y'',
			NULL,
			''pFunctionName=ISC_DBI_NET_BOOK_FULF&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&pParamIds=Y'')
					ISC_ATTRIBUTE_3, -- Drill - Product Category
		'||l_drill_ord||'	ISC_ATTRIBUTE_4, -- Drill - Orders Value
		'||l_drill_ret||'	ISC_ATTRIBUTE_5, -- Drill - Returns Value'
		||l_inner_sql||'
		ENI_ITEM_VBH_NODES_V 	ecat
		WHERE ecat.parent_id = ecat.child_id
		'||l_cat_join||'
		AND ((c.rnk between &START_INDEX and &END_INDEX) OR(&END_INDEX = -1))
		ORDER BY rnk';

  ELSIF l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP' THEN
     l_stmt := 'SELECT
		decode(c.resource_id,null,g.group_name,
			r.resource_name)  VIEWBY,
		decode(c.resource_id,null,to_char(c.sales_grp_id),
			c.resource_id||''.''||c.sales_grp_id)
					VIEWBYID,
		decode(c.resource_id, NULL,
			''pFunctionName=ISC_DBI_NET_BOOK_FULF&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&VIEW_BY=VIEW_BY'',
			NULL)		ISC_ATTRIBUTE_2, -- Drill - Sales Group
		null			ISC_ATTRIBUTE_3, -- Drill - Product Category
		decode(c.resource_id, NULL,
			NULL,
			decode(c.sales_grp_id, -1, NULL,
				''pFunctionName=ISC_DBI_BK_DETAIL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''	))
					ISC_ATTRIBUTE_4, -- Drill - Orders Value
		decode(c.resource_id, NULL,
			NULL,
			decode(c.sales_grp_id, -1, NULL,
				''pFunctionName=ISC_DBI_RET_DETAIL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''))
					ISC_ATTRIBUTE_5, -- Drill - Returns Value'
		||l_inner_sql||'
		JTF_RS_GROUPS_VL		g,
		JTF_RS_RESOURCE_EXTNS_VL	r
		WHERE c.sales_grp_id = g.group_id
		AND c.resource_id = r.resource_id(+)
		AND ((c.rnk between &START_INDEX and &END_INDEX) OR(&END_INDEX = -1))
		ORDER BY rnk' ;

  ELSIF l_view_by = 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS' THEN
     l_stmt := '
SELECT	cc.value		VIEWBY,
	cc.id			VIEWBYID,
	null			ISC_ATTRIBUTE_2, -- Drill - Sales Group
	null			ISC_ATTRIBUTE_3, -- Drill - Product Category
	'||l_drill_ord||'	ISC_ATTRIBUTE_4, -- Drill - Orders Value
	'||l_drill_ret||'	ISC_ATTRIBUTE_5, -- Drill - Returns Value'
	||l_inner_sql||'
	FII_PARTNER_MKT_CLASS_V cc
WHERE c.class_code = cc.id
AND ((c.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
ORDER BY rnk';

  ELSE -- l_view_by = 'CUSTOMER+FII_CUSTOMERS'
     l_stmt := 'SELECT cust.value	VIEWBY,
		cust.id			VIEWBYID,
		null			ISC_ATTRIBUTE_2, -- Drill - Sales Group
		null			ISC_ATTRIBUTE_3, -- Drill - Product Category
		'||l_drill_ord||'	ISC_ATTRIBUTE_4, -- Drill - Orders Value
		'||l_drill_ret||'	ISC_ATTRIBUTE_5, -- Drill - Returns Value'
		||l_inner_sql||'
		FII_CUSTOMERS_V 	cust
  		WHERE c.customer_id = cust.id
		AND ((c.rnk between &START_INDEX and &END_INDEX) OR(&END_INDEX = -1))
		ORDER BY rnk';

  END IF;

  END IF;

  x_custom_sql := l_stmt;

  l_custom_rec.attribute_name := ':ISC_CUST';
  l_custom_rec.attribute_value := l_cust_flag;
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_SG';
  l_custom_rec.attribute_value := to_char(l_sg_sg);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_RES';
  l_custom_rec.attribute_value := to_char(l_sg_res);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_ITEM_CAT_FLAG';
  l_custom_rec.attribute_value := to_char(l_item_cat_flag);
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
  x_custom_output.extend;
  x_custom_output(4) := l_custom_rec;

END get_sql;

END ISC_DBI_NET_BOOK_FULF_PKG ;


/
