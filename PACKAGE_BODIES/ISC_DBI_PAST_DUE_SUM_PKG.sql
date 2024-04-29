--------------------------------------------------------
--  DDL for Package Body ISC_DBI_PAST_DUE_SUM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_PAST_DUE_SUM_PKG" AS
/* $Header: ISCRG77B.pls 120.1 2006/06/26 06:29:24 abhdixi noship $ */


PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_formula_sql			VARCHAR2(10000);
  l_inner_sql			VARCHAR2(10000);
  l_outer_sql			VARCHAR2(10000);
  l_sql_stmt			VARCHAR2(10000);
  l_stmt			VARCHAR2(10000);
  l_view_by			VARCHAR2(10000);
  l_bucket			VARCHAR2(10000);
  l_customer			VARCHAR2(10000);
  l_customer_where		VARCHAR2(10000);
  l_item			VARCHAR2(10000);
  l_item_where			VARCHAR2(10000);
  l_inv_cat			VARCHAR2(10000);
  l_inv_cat_where		VARCHAR2(10000);
  l_inv_org			VARCHAR2(10000);
  l_inv_org_where		VARCHAR2(10000);
  l_item_cat_flag		NUMBER; -- 0 for item, 1 for inv category
  l_customer_flag		NUMBER; -- 0 for customer level, 1 for no-customer level

  l_qty				VARCHAR2(10000);
  l_lines			VARCHAR2(10000);
  l_days			VARCHAR2(10000);

  l_period_type			VARCHAR2(240);
  l_snapshot_taken		BOOLEAN		:= TRUE;
  l_as_of_date			DATE;
  l_effective_start_date	DATE;
  l_cursor_id			NUMBER;
  l_dummy			NUMBER;
  l_lang			VARCHAR2(10);
  l_custom_rec			BIS_QUERY_ATTRIBUTES;

BEGIN

  FOR i IN 1..p_param.COUNT
  LOOP
    IF( p_param(i).parameter_name= 'VIEW_BY')
      THEN l_view_by := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'CUSTOMER+FII_CUSTOMERS')
      THEN l_customer :=  p_param(i).parameter_value;
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

    IF(p_param(i).parameter_name = 'AS_OF_DATE')
      THEN l_as_of_date := to_date(p_param(i).parameter_value, 'DD-MM-YYYY');
    END IF;

    IF(p_param(i).parameter_name = 'PERIOD_TYPE')
      THEN l_period_type :=  p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ISC_ATTRIBUTE_3')
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

  IF (l_customer IS NULL OR l_customer = 'All')
    THEN l_customer_where :='';
    IF(l_view_by = 'CUSTOMER+FII_CUSTOMERS') THEN
       l_customer_flag := 0;
    ELSE
       l_customer_flag := 1; -- do not need customer id
    END IF;
    ELSE l_customer_where :='
	    AND mv.customer_id IN (&CUSTOMER+FII_CUSTOMERS)';
         l_customer_flag := 0; -- customer level
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

  IF (l_bucket = '' OR l_bucket IS NULL)
    THEN l_qty := 'mv.pdue_qty';
	 l_lines := 'mv.pdue_line_cnt';
	 l_days := 'mv.days_late';
  ELSIF(l_bucket = 1)
    THEN l_qty := 'mv.bucket1_qty';
	 l_lines := 'mv.bucket1_line_cnt';
	 l_days := 'mv.bucket1_days_late';
  ELSIF (l_bucket = 2)
    THEN l_qty := 'mv.bucket2_qty';
	 l_lines := 'mv.bucket2_line_cnt';
	 l_days := 'mv.bucket2_days_late';
  ELSIF (l_bucket = 3)
    THEN l_qty := 'mv.bucket3_qty';
	 l_lines := 'mv.bucket3_line_cnt';
	 l_days := 'mv.bucket3_days_late';
  ELSIF (l_bucket = 4)
    THEN l_qty := 'mv.bucket4_qty';
	 l_lines := 'mv.bucket4_line_cnt';
	 l_days := 'mv.bucket4_days_late';
  ELSIF (l_bucket = 5)
    THEN l_qty := 'mv.bucket5_qty';
	 l_lines := 'mv.bucket5_line_cnt';
	 l_days := 'mv.bucket5_days_late';
  ELSIF (l_bucket = 6)
    THEN l_qty := 'mv.bucket6_qty';
	 l_lines := 'mv.bucket6_line_cnt';
	 l_days := 'mv.bucket6_days_late';
  ELSIF (l_bucket = 7)
    THEN l_qty := 'mv.bucket7_qty';
	 l_lines := 'mv.bucket7_line_cnt';
	 l_days := 'mv.bucket7_days_late';
  ELSIF (l_bucket = 8)
    THEN l_qty := 'mv.bucket8_qty';
	 l_lines := 'mv.bucket8_line_cnt';
	 l_days := 'mv.bucket8_days_late';
  ELSIF (l_bucket = 9)
    THEN l_qty := 'mv.bucket9_qty';
	 l_lines := 'mv.bucket9_line_cnt';
	 l_days := 'mv.bucket9_days_late';
  ELSIF (l_bucket = 10)
    THEN l_qty := 'mv.bucket10_qty';
	 l_lines := 'mv.bucket10_line_cnt';
	 l_days := 'mv.bucket10_days_late';
  ELSE l_qty := 'mv.pdue_qty';
       l_lines := 'mv.pdue_line_cnt';
       l_days := 'mv.days_late';
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
	  FROM ISC_BOOK_SUM2_PDUE_F	mv
	 WHERE mv.time_snapshot_date_id BETWEEN :l_effective_start_date
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

  l_lang := USERENV('LANG');

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

-- SQL statement generation: SELECT

  IF NOT(l_snapshot_taken)
    THEN l_sql_stmt := '
 SELECT	0		VIEWBY,
	0		VIEWBYID,
	0		ISC_ATTRIBUTE_2,
	0		ISC_ATTRIBUTE_4, -- description
	0		ISC_ATTRIBUTE_5, -- UOM
	0		ISC_MEASURE_2, --  past due quantity
	0		ISC_MEASURE_1, -- line count
	0		ISC_MEASURE_11, -- change line count
	0		ISC_MEASURE_4, -- line count - prior
	0		ISC_MEASURE_5, -- avg days late
	0		ISC_MEASURE_6, -- gd total line count
	0		ISC_MEASURE_9, -- gd total avg days late
	0		ISC_MEASURE_10, -- gd total change line count
	0		ISC_MEASURE_12, -- KPI past due schedule lines
	0		ISC_MEASURE_13, -- KPI past due schedule lines - prior
	0		ISC_MEASURE_3, -- obsolete from DBI 5.0
	0		ISC_MEASURE_7, -- obsolete from DBI 5.0
	0		CURRENCY	-- obsolete from DBI 5.0
   FROM	dual
  WHERE 1 = 2 /* No snapshot has been taken during this period*/';

    ELSE

      l_formula_sql :=
	'c.line_cnt				ISC_MEASURE_1, -- line count
	c.quantity				ISC_MEASURE_2, -- past due quantity
        c.prev_line_cnt				ISC_MEASURE_4, -- line count - prior
	c.avg_days_late				ISC_MEASURE_5, -- avg days late
	sum(c.line_cnt) over ()			ISC_MEASURE_6, -- gd total line count
	sum(c.days_late) over()
	  / decode( sum(c.line_cnt) over(),0,
		    NULL,
		    sum(c.line_cnt) over())
						ISC_MEASURE_9, -- gd total avg days late
	(sum(c.line_cnt) over () - sum(c.prev_line_cnt) over ())
	  / decode( sum(c.prev_line_cnt) over(),0,
		    NULL,
		    abs(sum(c.prev_line_cnt) over())) * 100
						ISC_MEASURE_10, -- gd total change past due lines
	(c.line_cnt - c.prev_line_cnt)
	  / decode( c.prev_line_cnt,0,
		    NULL,
		    abs(c.prev_line_cnt))* 100	ISC_MEASURE_11, -- change past due lines
	c.line_cnt				ISC_MEASURE_12, -- KPI past due schedule lines
	c.prev_line_cnt				ISC_MEASURE_13, -- KPI past due schedule lines - prior
	sum(c.line_cnt) over ()			ISC_MEASURE_3, -- KPI past due schedule lines - grand total
	sum(c.prev_line_cnt) over ()		ISC_MEASURE_7, -- KPI past due schedule lines - prior grand total
	null					CURRENCY -- obsolete';

   l_inner_sql :=
	'	sum(decode(mv.time_snapshot_date_id, a.day,
			'||l_qty||', 0))			QUANTITY,
		sum(decode(mv.time_snapshot_date_id, a.day,
			'||l_lines||', 0))			LINE_CNT,
		sum(decode(mv.time_snapshot_date_id, b.day,
			'||l_lines||', 0))			PREV_LINE_CNT,
		sum(decode(mv.time_snapshot_date_id, a.day,
			'||l_days||', 0))			DAYS_LATE,
		sum(decode(mv.time_snapshot_date_id, a.day,
			'||l_days||', 0))
		  / decode( sum(decode(mv.time_snapshot_date_id, a.day,
					'||l_lines||', 0)), 0,
			    NULL,
			    sum(decode(	mv.time_snapshot_date_id, a.day,
					'||l_lines||', 0)) )	AVG_DAYS_LATE
	   FROM (SELECT max(time_snapshot_date_id)		DAY
		   FROM	ISC_DBI_FM_0006_MV			mv
		  WHERE	mv.time_snapshot_date_id BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE
						     AND &BIS_CURRENT_ASOF_DATE
					)	a,
		(SELECT max(time_snapshot_date_id)		DAY
		   FROM	ISC_DBI_FM_0006_MV			mv
		  WHERE	mv.time_snapshot_date_id BETWEEN &BIS_PREVIOUS_EFFECTIVE_START_DATE
						     AND &BIS_PREVIOUS_ASOF_DATE
					)	b,
		ISC_DBI_FM_0006_MV		mv
	  WHERE	mv.time_snapshot_date_id IN (a.day, b.day)
	    AND mv.item_cat_flag = :ISC_ITEM_CAT_FLAG
	    AND mv.customer_flag = :ISC_CUSTOMER_FLAG
	    AND '||l_lines||' > 0'
		 ||l_inv_org_where||l_inv_cat_where||l_item_where||l_customer_where;

     l_outer_sql:= 'ISC_MEASURE_2,ISC_MEASURE_1,ISC_MEASURE_11,ISC_MEASURE_4,ISC_MEASURE_5,
	ISC_MEASURE_6,ISC_MEASURE_9,ISC_MEASURE_10,ISC_MEASURE_12,
	ISC_MEASURE_13,ISC_MEASURE_3,ISC_MEASURE_7,CURRENCY';

      IF l_view_by = 'CUSTOMER+FII_CUSTOMERS' THEN
	 l_sql_stmt := '
 SELECT	cust.value			VIEWBY,
	cust.id				VIEWBYID,
	cust.value			ISC_ATTRIBUTE_2,
	null				ISC_ATTRIBUTE_4,
	null				ISC_ATTRIBUTE_5,
	'||l_outer_sql||'
 FROM (SELECT (rank() over (&ORDER_BY_CLAUSE NULLS LAST,customer_id))-1 rnk,
	customer_id,
	'||l_outer_sql||'
  FROM (SELECT customer_id,
	'||l_formula_sql||'
   FROM (SELECT mv.customer_id				CUSTOMER_ID,
	'||l_inner_sql||'
	GROUP BY mv.customer_id) c))	a,
	FII_CUSTOMERS_V			cust
  WHERE a.customer_id = cust.id
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
  ORDER BY rnk';

      ELSIF l_view_by = 'ORGANIZATION+ORGANIZATION' THEN
	 l_sql_stmt := '
 SELECT	org.name			VIEWBY,
	org.organization_id		VIEWBYID,
	org.name			ISC_ATTRIBUTE_2,
	null				ISC_ATTRIBUTE_4,
	null				ISC_ATTRIBUTE_5,
	'||l_outer_sql||'
 FROM (SELECT (rank() over (&ORDER_BY_CLAUSE NULLS LAST,inv_org_id))-1 rnk,
	inv_org_id,
	'||l_outer_sql||'
  FROM (SELECT inv_org_id,
	'||l_formula_sql||'
   FROM (SELECT mv.inv_org_id				INV_ORG_ID,
	'||l_inner_sql||'
	  GROUP BY mv.inv_org_id) c))	a,
	HR_ALL_ORGANIZATION_UNITS_TL	org
  WHERE a.inv_org_id = org.organization_id
    AND org.language = :ISC_LANG
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
  ORDER BY rnk';

      ELSIF l_view_by = 'ITEM+ENI_ITEM_ORG' THEN
	 l_sql_stmt := '
 SELECT	items.value				VIEWBY,
	items.id				VIEWBYID,
	items.value				ISC_ATTRIBUTE_2,
	items.description			ISC_ATTRIBUTE_4, -- item description
	mtl.unit_of_measure			ISC_ATTRIBUTE_5, -- UOM
	'||l_outer_sql||'
 FROM (SELECT (rank() over (&ORDER_BY_CLAUSE NULLS LAST,item_id))-1 rnk,
	item_id,
	uom,
	'||l_outer_sql||'
  FROM (SELECT item_id,
	uom,
	'||l_formula_sql||'
   FROM (SELECT mv.item_id					ITEM_ID,
		mv.uom						UOM,
	'||l_inner_sql||'
	GROUP BY mv.item_id, mv.uom) c))	a,
	ENI_ITEM_ORG_V				items,
	MTL_UNITS_OF_MEASURE_TL 		mtl
  WHERE a.item_id = items.id
    AND a.uom = mtl.uom_code
    AND mtl.language = :ISC_LANG
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
  ORDER BY rnk';

      ELSE -- l_view_by = 'ITEM+ENI_ITEM_INV_CAT'
	l_sql_stmt := '
 SELECT	eni.value				VIEWBY,
	eni.id				 	VIEWBYID,
	eni.value				ISC_ATTRIBUTE_2,
	null					ISC_ATTRIBUTE_4,
	null					ISC_ATTRIBUTE_5,
	'||l_outer_sql||'
 FROM (SELECT (rank() over (&ORDER_BY_CLAUSE NULLS LAST,item_category_id))-1 rnk,
	item_category_id,
	'||l_outer_sql||'
  FROM (SELECT item_category_id,
	'||l_formula_sql||'
   FROM (SELECT mv.item_category_id			ITEM_CATEGORY_ID,
	'||l_inner_sql||'
	GROUP BY mv.item_category_id) c))	a,
	ENI_ITEM_INV_CAT_V			eni
  WHERE a.item_category_id = eni.id
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
  ORDER BY rnk';

      END IF;

  END IF;

  x_custom_sql := l_sql_stmt;

  l_custom_rec.attribute_name := ':ISC_ITEM_CAT_FLAG';
  l_custom_rec.attribute_value := to_char(l_item_cat_flag);
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_CUSTOMER_FLAG';
  l_custom_rec.attribute_value := to_char(l_customer_flag);
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_LANG';
  l_custom_rec.attribute_value := l_lang;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

END Get_Sql;

END ISC_DBI_PAST_DUE_SUM_PKG ;


/
