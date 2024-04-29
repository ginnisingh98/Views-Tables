--------------------------------------------------------
--  DDL for Package Body ISC_DBI_DAYS_SHIP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_DAYS_SHIP_PKG" AS
/* $Header: ISCRG70B.pls 120.1 2006/05/03 03:27:24 abhdixi noship $ */

PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt 			VARCHAR2(10000);
  l_formula_sql			VARCHAR2(10000);
  l_inner_sql			VARCHAR2(10000);
  l_outer_sql			VARCHAR2(10000);
  l_inv_org 			VARCHAR2(10000);
  l_inv_org_where     		VARCHAR2(10000);
  l_item			VARCHAR2(10000);
  l_item_where			VARCHAR2(10000);
  l_inv_cat			VARCHAR2(10000);
  l_inv_cat_where		VARCHAR2(10000);
  l_view_by			VARCHAR2(120);
  l_customer			VARCHAR2(10000);
  l_customer_where		VARCHAR2(10000);
  l_item_cat_flag		NUMBER; -- 0 for item, 1 for inv category
  l_customer_flag		NUMBER; -- 0 for customer level, 1 for no-customer level
  l_agg_level			NUMBER;
  l_lang  			VARCHAR2(10);
  l_custom_rec			BIS_QUERY_ATTRIBUTES;
  l_period_type			VARCHAR2(30);

BEGIN

  FOR i IN 1..p_param.COUNT
  LOOP
    IF( p_param(i).parameter_name= 'VIEW_BY')
      THEN l_view_by := p_param(i).parameter_value;
    END IF;

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
      THEN l_customer :=  p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'PERIOD_TYPE')
      THEN l_period_type :=  p_param(i).parameter_value;
    END IF;

  END LOOP;

  IF(l_inv_org IS NULL OR l_inv_org = 'All')
    THEN l_inv_org_where :=  '
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

    ELSE l_inv_org_where :=  '
	    AND f.inv_org_id = &ORGANIZATION+ORGANIZATION';
  END IF;

  IF (l_customer IS NULL OR l_customer = 'All')
    THEN l_customer_where :='';
    IF(l_view_by = 'CUSTOMER+FII_CUSTOMERS') THEN
       l_customer_flag := 0;
    ELSE
       l_customer_flag := 1; -- do not need customer id
    END IF;
  ELSE l_customer_where :='
	AND f.customer_id IN (&CUSTOMER+FII_CUSTOMERS)';
       l_customer_flag := 0; -- customer level
  END IF;

  IF (l_inv_cat IS NULL OR l_inv_cat = 'All')
    THEN l_inv_cat_where := '';
    ELSE l_inv_cat_where := '
	    AND f.item_category_id IN (&ITEM+ENI_ITEM_INV_CAT)';
  END IF;

  IF (l_item IS NULL OR l_item = 'All')
    THEN l_item_where := '';
    ELSE l_item_where := '
	    AND f.item_id IN (&ITEM+ENI_ITEM_ORG)';
  END IF;

  IF (l_item IS NULL OR l_item = 'All')
    THEN
      IF (l_view_by = 'ITEM+ENI_ITEM_ORG')
	THEN l_item_cat_flag := 0; -- item
      ELSIF (l_view_by = 'ITEM+ENI_ITEM_INV_CAT')
        THEN l_item_cat_flag := 1; -- inventory category
      ELSE
	IF (l_inv_cat IS NULL OR l_inv_cat = 'All')
	  THEN l_item_cat_flag := 3; -- all
	ELSE l_item_cat_flag := 1; -- inventory category
	END IF;
      END IF;
  ELSE
    l_item_cat_flag := 0; -- item
  END IF;

  CASE
    WHEN (l_item_cat_flag = 0 and l_customer_flag = 0) THEN l_agg_level := 0;
    WHEN (l_item_cat_flag = 1 and l_customer_flag = 0) THEN l_agg_level := 4;
    WHEN (l_item_cat_flag = 3 and l_customer_flag = 0) THEN l_agg_level := 2;
    WHEN (l_item_cat_flag = 0 and l_customer_flag = 1) THEN l_agg_level := 1;
    WHEN (l_item_cat_flag = 1 and l_customer_flag = 1) THEN l_agg_level := 5;
    WHEN (l_item_cat_flag = 3 and l_customer_flag = 1) THEN l_agg_level := 3;
  END CASE;

  l_lang := USERENV('LANG');

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  l_formula_sql := 'c.curr_booked_to_ship_days 				ISC_MEASURE_1,
	c.curr_shipped_line_cnt 				ISC_MEASURE_2,
	c.prev_booked_to_ship_days				ISC_MEASURE_3,
	c.prev_shipped_line_cnt					ISC_MEASURE_4,
	c.curr_booked_to_ship_days
	  / decode( c.curr_shipped_line_cnt,0,
		    NULL,
		    c.curr_shipped_line_cnt)			ISC_MEASURE_5, -- Days Ship
	sum(c.curr_booked_to_ship_days) over ()
	  / decode( sum(c.curr_shipped_line_cnt) over (),0,
		    NULL,
		    sum(c.curr_shipped_line_cnt) over ())	ISC_MEASURE_6, -- Gd Total for Days
 	CASE WHEN sum(c.curr_shipped_line_cnt) over() = 0 THEN to_number(NULL)
	     WHEN sum(c.prev_shipped_line_cnt) over() = 0 THEN to_number(NULL)
	     ELSE ((sum(c.curr_booked_to_ship_days) over ()
		     / sum(c.curr_shipped_line_cnt) over ()
		   - sum(c.prev_booked_to_ship_days) over ()
		     / sum(c.prev_shipped_line_cnt) over ())
		  ) END
								ISC_MEASURE_7, -- Gd Total for Change
	CASE WHEN c.curr_shipped_line_cnt = 0 THEN to_number(NULL)
	     WHEN c.prev_shipped_line_cnt = 0 THEN to_number(NULL)
	     ELSE ((c.curr_booked_to_ship_days/c.curr_shipped_line_cnt
		    - c.prev_booked_to_ship_days/c.prev_shipped_line_cnt)
		   ) END
								ISC_MEASURE_8, -- Days Ship Change
	c.curr_booked_to_ship_days
	  / decode( c.curr_shipped_line_cnt,0,
		    NULL,
		    c.curr_shipped_line_cnt)			ISC_MEASURE_9, -- KPI Days Ship
	c.prev_booked_to_ship_days
	  / decode( c.prev_shipped_line_cnt,0,
		    NULL,
		    c.prev_shipped_line_cnt)			ISC_MEASURE_10, -- KPI Days Ship - Prior
	sum(c.curr_booked_to_ship_days) over ()
	  / decode( sum(c.curr_shipped_line_cnt) over (),0,
		    NULL,
		    sum(c.curr_shipped_line_cnt) over ())	ISC_MEASURE_11, -- KPI Gd Total for Days
	sum(c.prev_booked_to_ship_days) over ()
	  / decode( sum(c.prev_shipped_line_cnt) over (),0,
		    NULL,
		    sum(c.prev_shipped_line_cnt) over ())	ISC_MEASURE_12, -- KPI Gd Total for Days Prior
	c.prev_booked_to_ship_days
	  / decode( c.prev_shipped_line_cnt,0,
		    NULL,
		    c.prev_shipped_line_cnt)			ISC_MEASURE_14, -- Compare to measure for KPI change
	sum(c.prev_booked_to_ship_days) over ()
	  / decode( sum(c.prev_shipped_line_cnt) over (),0,
		    NULL,
		    sum(c.prev_shipped_line_cnt) over ())	ISC_MEASURE_15, -- Gd total Compare to measure for KPI change
	null						CURRENCY -- obsolete from DBI 5.0';

IF(l_period_type = 'FII_TIME_DAY')
THEN

  l_inner_sql := '	sum(decode(to_date(f.time_id,''j''), &BIS_CURRENT_ASOF_DATE,
			   f.book_to_ship_days, 0))	CURR_BOOKED_TO_SHIP_DAYS,
		sum(decode(to_date(f.time_id,''j''), &BIS_PREVIOUS_ASOF_DATE,
			   f.book_to_ship_days, 0))	PREV_BOOKED_TO_SHIP_DAYS,
		sum(decode(to_date(f.time_id,''j''), &BIS_CURRENT_ASOF_DATE,
			   f.shipped_line_cnt, 0))	CURR_SHIPPED_LINE_CNT,
		sum(decode(to_date(f.time_id,''j''), &BIS_PREVIOUS_ASOF_DATE,
			   f.shipped_line_cnt, 0))	PREV_SHIPPED_LINE_CNT
     	   FROM ISC_DBI_FM_0000_MV			f
     	  WHERE f.time_id in (to_char(&BIS_CURRENT_ASOF_DATE,''j''),
	  to_char(&BIS_PREVIOUS_ASOF_DATE,''j''))
	    AND f.period_type_id = 1
	    AND f.agg_level = :ISC_AGG_LEVEL';
ELSE
  l_inner_sql := '	sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
			   f.book_to_ship_days, 0))	CURR_BOOKED_TO_SHIP_DAYS,
		sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
			   f.book_to_ship_days, 0))	PREV_BOOKED_TO_SHIP_DAYS,
		sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
			   f.shipped_line_cnt, 0))	CURR_SHIPPED_LINE_CNT,
		sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
			   f.shipped_line_cnt, 0))	PREV_SHIPPED_LINE_CNT
     	   FROM ISC_DBI_FM_0000_MV			f,
		FII_TIME_RPT_STRUCT_V			cal
     	  WHERE f.time_id = cal.time_id
	    AND f.agg_level = :ISC_AGG_LEVEL
	    AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
	    AND cal.period_type_id = f.period_type_id
	    AND bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id';
END IF;

  l_inner_sql := l_inner_sql||l_inv_org_where
		||l_inv_cat_where
		||l_item_where
		||l_customer_where;

  l_outer_sql:= 'ISC_MEASURE_1,ISC_MEASURE_2,ISC_MEASURE_5,ISC_MEASURE_6,ISC_MEASURE_3,
	ISC_MEASURE_4,ISC_MEASURE_8,ISC_MEASURE_7,ISC_MEASURE_9,ISC_MEASURE_10,
	ISC_MEASURE_11,ISC_MEASURE_12,ISC_MEASURE_14,ISC_MEASURE_15,CURRENCY';

-- Construction of the SQL statement here

  IF l_view_by = 'ITEM+ENI_ITEM_ORG'
    THEN l_stmt := '
SELECT	items.value					 	VIEWBY,
	items.id						VIEWBYID,
	items.value					  	ISC_ATTRIBUTE_2,
	items.description  					ISC_ATTRIBUTE_3,
	'||l_outer_sql||'
FROM (SELECT (rank() over (&ORDER_BY_CLAUSE NULLS LAST,item_id))-1 rnk,item_id,
	'||l_outer_sql||'
  FROM (SELECT item_id,
	'||l_formula_sql||'
   FROM	(SELECT f.item_id				ITEM_ID,
	'||l_inner_sql||'
	GROUP BY f.item_id) c)
	WHERE ISC_MEASURE_5 IS NOT NULL OR ISC_MEASURE_8 IS NOT NULL) a,
	ENI_ITEM_ORG_V 			items
  WHERE a.item_id = items.id
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
  ORDER BY rnk';

  ELSIF l_view_by = 'ORGANIZATION+ORGANIZATION'
    THEN l_stmt := '
SELECT	org.name 						VIEWBY,
	org.organization_id					VIEWBYID,
	org.name						ISC_ATTRIBUTE_2,
	null							ISC_ATTRIBUTE_3,
	'||l_outer_sql||'
FROM (SELECT (rank() over (&ORDER_BY_CLAUSE NULLS LAST,inv_org_id))-1 rnk,inv_org_id,
	'||l_outer_sql||'
  FROM (SELECT inv_org_id,
	'||l_formula_sql||'
   FROM	(SELECT f.inv_org_id				INV_ORG_ID,
	'||l_inner_sql||'
	GROUP BY f.inv_org_id) c)
	WHERE ISC_MEASURE_5 IS NOT NULL OR ISC_MEASURE_8 IS NOT NULL) a,
	HR_ALL_ORGANIZATION_UNITS_TL 	org
  WHERE org.organization_id = a.inv_org_id
    AND org.language = :ISC_LANG
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
  ORDER BY rnk';

  ELSIF l_view_by = 'CUSTOMER+FII_CUSTOMERS'
    THEN l_stmt := '
SELECT	cust.value						VIEWBY,
	cust.id							VIEWBYID,
	cust.value						ISC_ATTRIBUTE_2,
	null							ISC_ATTRIBUTE_3,
	'||l_outer_sql||'
FROM (SELECT (rank() over (&ORDER_BY_CLAUSE NULLS LAST,customer_id))-1 rnk,customer_id,
	'||l_outer_sql||'
  FROM (SELECT customer_id,
	'||l_formula_sql||'
   FROM	(SELECT f.customer_id				CUSTOMER_ID,
	'||l_inner_sql||'
	GROUP BY f.customer_id)	c)
	WHERE ISC_MEASURE_5 IS NOT NULL OR ISC_MEASURE_8 IS NOT NULL) a,
	FII_CUSTOMERS_V			cust
  WHERE a.customer_id = cust.id
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
  ORDER BY rnk';

  ELSE -- l_view_by = 'ITEM+ENI_ITEM_INV_CAT'
    l_stmt := '
SELECT	eni.value 						VIEWBY,
	eni.id				 			VIEWBYID,
	eni.value					  	ISC_ATTRIBUTE_2,
	null							ISC_ATTRIBUTE_3,
	'||l_outer_sql||'
FROM (SELECT (rank() over (&ORDER_BY_CLAUSE NULLS LAST,item_category_id))-1 rnk,item_category_id,
	'||l_outer_sql||'
  FROM (SELECT item_category_id,
	'||l_formula_sql||'
   FROM	(SELECT f.item_category_id			ITEM_CATEGORY_ID,
	'||l_inner_sql||'
	GROUP BY f.item_category_id) c)
	WHERE ISC_MEASURE_5 IS NOT NULL OR ISC_MEASURE_8 IS NOT NULL) a,
	ENI_ITEM_INV_CAT_V		eni
  WHERE a.item_category_id = eni.id
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
  ORDER BY rnk';
  END IF;

  x_custom_sql := l_stmt;

  l_custom_rec.attribute_name := ':ISC_AGG_LEVEL';
  l_custom_rec.attribute_value := to_char(l_agg_level);
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_LANG';
  l_custom_rec.attribute_value := l_lang;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

END Get_Sql;

END ISC_DBI_DAYS_SHIP_PKG ;


/
