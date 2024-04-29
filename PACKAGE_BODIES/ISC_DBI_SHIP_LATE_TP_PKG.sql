--------------------------------------------------------
--  DDL for Package Body ISC_DBI_SHIP_LATE_TP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_SHIP_LATE_TP_PKG" AS
/* $Header: ISCRG90B.pls 120.1 2006/06/26 06:23:07 abhdixi noship $ */

PROCEDURE GET_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,x_custom_sql OUT NOCOPY VARCHAR2,
	x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_formula_sql		VARCHAR2(32000);
  l_inner_sql		VARCHAR2(32000);
  l_stmt 		VARCHAR2(32000);
  l_outer_sql 		VARCHAR2(32000);
  l_view_by		VARCHAR2(32000);
  l_org 		VARCHAR2(32000);
  l_org_where     	VARCHAR2(32000);
  l_item		VARCHAR2(32000);
  l_item_where		VARCHAR2(32000);
  l_inv_cat		VARCHAR2(32000);
  l_inv_cat_where	VARCHAR2(32000);
  l_cust		VARCHAR2(32000);
  l_cust_where		VARCHAR2(32000);
  l_lang		VARCHAR2(10);
  l_item_cat_flag	NUMBER; -- 0 for item and 1 for inv. category
  l_cust_flag		NUMBER; -- 0 for customer level, 1 for no-customer level
  l_agg_level		NUMBER;
  l_custom_rec 		BIS_QUERY_ATTRIBUTES ;
  l_const		NUMBER:=0; -- used for the zero row filter


BEGIN
  FOR i IN 1..p_param.COUNT
  LOOP

    IF( p_param(i).parameter_name= 'VIEW_BY')
      THEN l_view_by := p_param(i).parameter_value;
    END IF;

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

    IF(l_view_by = 'CUSTOMER+FII_CUSTOMERS') THEN
       l_cust_flag := 0;
    ELSE
       l_cust_flag := 1; -- do not need customer id
    END IF;
  ELSE
    l_cust_where :='
	AND f.customer_id in (&CUSTOMER+FII_CUSTOMERS)';
    l_cust_flag := 0; -- customer level
  END IF;


  IF (l_item IS NULL OR l_item = 'All')
    THEN
      IF (l_view_by = 'ITEM+ENI_ITEM_ORG')
	THEN l_item_cat_flag := 0; -- item
      ELSIF (l_view_by = 'ITEM+ENI_ITEM_INV_CAT')
        THEN l_item_cat_flag := 1; -- category
      ELSE
	IF (l_inv_cat IS NULL OR l_inv_cat = 'All')
	  THEN l_item_cat_flag := 3; -- all
	ELSE l_item_cat_flag := 1; -- category
	END IF;
      END IF;
  ELSE
    l_item_cat_flag := 0; -- item
  END IF;

  CASE
    WHEN (l_item_cat_flag = 0 and l_cust_flag = 0) THEN l_agg_level := 0;
    WHEN (l_item_cat_flag = 1 and l_cust_flag = 0) THEN l_agg_level := 4;
    WHEN (l_item_cat_flag = 3 and l_cust_flag = 0) THEN l_agg_level := 2;
    WHEN (l_item_cat_flag = 0 and l_cust_flag = 1) THEN l_agg_level := 1;
    WHEN (l_item_cat_flag = 1 and l_cust_flag = 1) THEN l_agg_level := 5;
    WHEN (l_item_cat_flag = 3 and l_cust_flag = 1) THEN l_agg_level := 3;
  END CASE;

  l_lang := USERENV('LANG');

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  l_formula_sql :='
		a.late_line_cnt				ISC_MEASURE_1,
		a.late_line_cnt/decode(a.shipped_line_cnt,
			0,null,a.shipped_line_cnt)*100	ISC_MEASURE_2,
		a.days_late_promise/ decode(a.late_line_cnt,
			0,null,a.late_line_cnt)		ISC_MEASURE_4,
		a.book_to_ship_days/ decode(a.late_line_cnt,
			0,null,a.late_line_cnt)		ISC_MEASURE_5,
		sum(a.late_line_cnt) over()			ISC_MEASURE_6,
		sum(a.late_line_cnt) over()/
			decode(sum(a.shipped_line_cnt) over(),
			0,null,sum(a.shipped_line_cnt) over())*100  ISC_MEASURE_7,
		sum(a.days_late_promise) over()/
			decode(sum(a.late_line_cnt) over(),
			0,null,sum(a.late_line_cnt) over()) ISC_MEASURE_8,
		sum(a.book_to_ship_days) over()/
			decode(sum(a.late_line_cnt) over(),
			0,null,sum(a.late_line_cnt) over()) ISC_MEASURE_9,
		a.late_qty				ISC_MEASURE_10';

  l_outer_sql:= 'ISC_MEASURE_10,ISC_MEASURE_1,ISC_MEASURE_2,ISC_MEASURE_4,ISC_MEASURE_5,
		ISC_MEASURE_6,ISC_MEASURE_7,ISC_MEASURE_8,ISC_MEASURE_9';

  l_inner_sql:='sum(shipped_line_cnt)		SHIPPED_LINE_CNT,
		sum(late_line_promise_cnt)	LATE_LINE_CNT,
		sum(days_late_promise)		DAYS_LATE_PROMISE,
		sum(book_to_ship_days_late_p)	BOOK_TO_SHIP_DAYS,
		sum(shipped_late_p_qty)		LATE_QTY
		FROM ISC_DBI_FM_0000_MV 	f,
		FII_TIME_RPT_STRUCT_V		cal
     		WHERE f.time_id = cal.time_id
		AND f.agg_level = :ISC_AGG_LEVEL
		AND cal.report_date = &BIS_CURRENT_ASOF_DATE
		AND cal.period_type_id = f.period_type_id
		AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN) = cal.record_type_id'
		||l_org_where||l_inv_cat_where||l_item_where||l_cust_where;


  IF l_view_by = 'ITEM+ENI_ITEM_INV_CAT' THEN
    l_stmt := '	SELECT eni.value 	VIEWBY,
		eni.id			VIEWBYID,
		eni.id  		ISC_ATTRIBUTE_2,
		null			ISC_ATTRIBUTE_3,
		null			ISC_ATTRIBUTE_4,
		'||l_outer_sql||'
		FROM(select (rank() over (&ORDER_BY_CLAUSE nulls last,item_category_id))-1 rnk,
		item_category_id,
		'||l_outer_sql||'
		FROM (select item_category_id,
		'||l_formula_sql||'
		FROM (SELECT f.item_category_id	ITEM_CATEGORY_ID,
		'||l_inner_sql||'
		group by f.item_category_id) a)
		WHERE ISC_MEASURE_1<>:ISC_CONST) c,
		ENI_ITEM_INV_CAT_V 	eni
		WHERE c.item_category_id = eni.id
		AND ((c.rnk between &START_INDEX and &END_INDEX) OR(&END_INDEX = -1))
		ORDER BY rnk';

  ELSIF l_view_by = 'ORGANIZATION+ORGANIZATION' THEN
     l_stmt := 'SELECT org.name 		VIEWBY,
		org.organization_id		VIEWBYID,
		org.organization_id		ISC_ATTRIBUTE_2,
		null				ISC_ATTRIBUTE_3,
		null				ISC_ATTRIBUTE_4,
		'||l_outer_sql||'
		FROM(select
		(rank() over (&ORDER_BY_CLAUSE nulls last,inv_org_id))-1 rnk,
		inv_org_id,
		'||l_outer_sql||'
		FROM (select inv_org_id,
	   	'||l_formula_sql||'
		FROM (SELECT f.inv_org_id	INV_ORG_ID,
		'||l_inner_sql||'
		group by f.inv_org_id) a)
		WHERE ISC_MEASURE_1<>:ISC_CONST) c,
		HR_ALL_ORGANIZATION_UNITS_TL org
		WHERE org.organization_id = c.inv_org_id
		AND org.language = :ISC_LANG
		AND ((c.rnk between &START_INDEX and &END_INDEX) OR(&END_INDEX = -1))
		ORDER BY rnk' ;

  ELSIF l_view_by = 'ITEM+ENI_ITEM_ORG' THEN
     l_stmt := 'SELECT items.value	VIEWBY,
		items.id		VIEWBYID,
		items.id		ISC_ATTRIBUTE_2,
		items.description	ISC_ATTRIBUTE_3,
		uom.unit_of_measure	ISC_ATTRIBUTE_4,
		'||l_outer_sql||'
		FROM(select (rank() over (&ORDER_BY_CLAUSE nulls last,item_id))-1 rnk,
		item_id,uom,
		'||l_outer_sql||'
		FROM (select item_id, uom,
		'||l_formula_sql||'
		FROM (SELECT f.item_id ITEM_ID,f.uom UOM,
		'||l_inner_sql||'
		group by f.item_id,f.uom) a)
		WHERE ISC_MEASURE_1<>:ISC_CONST) c,
		 ENI_ITEM_ORG_V 	items,
		 MTL_UNITS_OF_MEASURE_TL uom
  		WHERE c.item_id = items.id
		AND uom.uom_code = c.uom
		AND uom.language = :ISC_LANG
		AND ((c.rnk between &START_INDEX and &END_INDEX) OR(&END_INDEX = -1))
		ORDER BY rnk';

  ELSE -- l_view_by = 'CUSTOMER+FII_CUSTOMERS'
     l_stmt := 'SELECT cust.value 	VIEWBY,
		cust.id			VIEWBYID,
		cust.id  		ISC_ATTRIBUTE_2,
		null			ISC_ATTRIBUTE_3,
		null			ISC_ATTRIBUTE_4,
		'||l_outer_sql||'
		FROM(select (rank() over (&ORDER_BY_CLAUSE nulls last,customer_id))-1 rnk,
		customer_id,
		'||l_outer_sql||'
		FROM (select customer_id,
		'||l_formula_sql||'
		FROM (SELECT f.customer_id	CUSTOMER_ID,
		'||l_inner_sql||'
		group by f.customer_id) a)
		WHERE ISC_MEASURE_1<>:ISC_CONST) c,
		FII_CUSTOMERS_V 	cust
  		WHERE c.customer_id = cust.id
		AND ((c.rnk between &START_INDEX and &END_INDEX) OR(&END_INDEX = -1))
		ORDER BY rnk';

  END IF;

  x_custom_sql := l_stmt;

  l_custom_rec.attribute_name := ':ISC_AGG_LEVEL';
  l_custom_rec.attribute_value := to_char(l_agg_level);
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

  l_custom_rec.attribute_name := ':ISC_CONST';
  l_custom_rec.attribute_value := l_const;
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

END get_sql;

END ISC_DBI_SHIP_LATE_TP_PKG ;


/
