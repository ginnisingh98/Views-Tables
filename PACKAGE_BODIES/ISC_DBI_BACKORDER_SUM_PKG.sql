--------------------------------------------------------
--  DDL for Package Body ISC_DBI_BACKORDER_SUM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_BACKORDER_SUM_PKG" AS
/* $Header: ISCRGAYB.pls 120.2 2006/05/04 03:53:58 abhdixi noship $ */


PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_formula_sql			VARCHAR2(10000);
  l_inner_sql			VARCHAR2(10000);
  l_outer_sql			VARCHAR2(10000);
  l_sql_stmt			VARCHAR2(10000);
  l_stmt			VARCHAR2(10000);
  l_view_by			VARCHAR2(10000);
  l_customer			VARCHAR2(10000);
  l_customer_where		VARCHAR2(10000);
  l_item			VARCHAR2(10000);
  l_item_where			VARCHAR2(10000);
  l_inv_cat			VARCHAR2(10000);
  l_inv_cat_where		VARCHAR2(10000);
  l_inv_org			VARCHAR2(10000);
  l_inv_org_where		VARCHAR2(10000);

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
    ELSE l_customer_where :='
	    AND mv.customer_id IN (&CUSTOMER+FII_CUSTOMERS)';
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

    IF(l_period_type = 'FII_TIME_DAY')
    THEN
	    l_stmt := '
		SELECT 1
		  FROM ISC_DBI_FM_0007_MV	mv
		 WHERE mv.time_snapshot_date_id = :l_as_of_date
		   AND rownum = 1 ';

	    DBMS_SQL.Parse(l_cursor_id,l_stmt,DBMS_SQL.V7);
            DBMS_SQL.Bind_Variable(l_cursor_id,':l_as_of_date',l_as_of_date);

    ELSE
	    l_stmt := '
		SELECT 1
		  FROM ISC_DBI_FM_0007_MV	mv
		 WHERE mv.time_snapshot_date_id BETWEEN :l_effective_start_date
					    AND :l_as_of_date
		   AND rownum = 1 ';

	    DBMS_SQL.Parse(l_cursor_id,l_stmt,DBMS_SQL.V7);
	    DBMS_SQL.Bind_Variable(l_cursor_id,':l_effective_start_date',l_effective_start_date);
            DBMS_SQL.Bind_Variable(l_cursor_id,':l_as_of_date',l_as_of_date);
    END IF;

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
	0		ISC_ATTRIBUTE_1, -- Description
	0		ISC_ATTRIBUTE_2, -- UOM
	0		ISC_MEASURE_1, -- Backordered Quantity
	0		ISC_MEASURE_2, -- Backordered Lines
	0		ISC_MEASURE_3, -- Backordered Lines - prior
	0		ISC_MEASURE_4, -- (Backordered Lines) Change
	0		ISC_MEASURE_5, -- Backordered Items
	0		ISC_MEASURE_6, -- Backordered Items - prior
	0		ISC_MEASURE_7, -- (Backordered Items) Change
	0		ISC_MEASURE_8, -- Grand Total - Backordered Lines
	0		ISC_MEASURE_9, -- Grand Total - (Backordered Lines) Change
	0		ISC_MEASURE_10, -- Grand Total - Backordered Items
	0		ISC_MEASURE_11 -- Grand Total - (Backordered Items) Change
   FROM	dual
  WHERE 1 = 2 /* No snapshot has been taken during this period */';

    ELSE

      l_formula_sql :=
	'c.quantity				ISC_MEASURE_1, -- Backordered Quantity
	c.line_cnt				ISC_MEASURE_2, -- Backordered Lines
        c.prev_line_cnt				ISC_MEASURE_3, -- Backordered Lines - prior
	(c.line_cnt - c.prev_line_cnt)
	  / decode( c.prev_line_cnt,0,
		    NULL,
		    abs(c.prev_line_cnt))* 100	ISC_MEASURE_4, -- (Backordered Lines) Change
	c.item_cnt				ISC_MEASURE_5, -- Backordered Items
	c.prev_item_cnt				ISC_MEASURE_6, -- Backordered Items - prior
	(c.item_cnt - c.prev_item_cnt)
	  / decode( c.prev_item_cnt,0,
		    NULL,
		    abs(c.prev_item_cnt))* 100	ISC_MEASURE_7, -- (Backordered Items) Change
	sum(c.line_cnt) over ()			ISC_MEASURE_8, -- Grand Total - Backordered Lines
	(sum(c.line_cnt) over () - sum(c.prev_line_cnt) over ())
	  / decode( sum(c.prev_line_cnt) over(),0,
		    NULL,
		    abs(sum(c.prev_line_cnt) over())) * 100
						ISC_MEASURE_9, -- Grand Total - (Backordered Lines) Change
	sum(c.item_cnt) over ()			ISC_MEASURE_10, -- Grand Total - Backordered Items
	(sum(c.item_cnt) over () - sum(c.prev_item_cnt) over ())
	  / decode( sum(c.prev_item_cnt) over(),0,
		    NULL,
		    abs(sum(c.prev_item_cnt) over())) * 100
						ISC_MEASURE_11 -- Grand Total - (Backordered Items) Change';
   IF(l_period_type = 'FII_TIME_DAY')
   THEN
   l_inner_sql :=
	'	sum(decode(mv.time_snapshot_date_id, &BIS_CURRENT_ASOF_DATE,
			mv.backorder_qty, 0))			QUANTITY,
		sum(decode(mv.time_snapshot_date_id, &BIS_CURRENT_ASOF_DATE,
			mv.backorder_line_cnt, 0))		LINE_CNT,
		sum(decode(mv.time_snapshot_date_id, &BIS_PREVIOUS_ASOF_DATE,
			mv.backorder_line_cnt, 0))		PREV_LINE_CNT,
		count(distinct(decode(mv.time_snapshot_date_id,&BIS_CURRENT_ASOF_DATE,
				mv.item_id, null)))		ITEM_CNT,
		count(distinct(decode(mv.time_snapshot_date_id,
		&BIS_PREVIOUS_ASOF_DATE,
				mv.item_id, null)))		PREV_ITEM_CNT
    	  FROM	ISC_DBI_FM_0007_MV		mv
	  WHERE	mv.time_snapshot_date_id IN (&BIS_CURRENT_ASOF_DATE,
	  &BIS_PREVIOUS_ASOF_DATE)';

   ELSE
   l_inner_sql :=
	'	sum(decode(mv.time_snapshot_date_id, a.day,
			mv.backorder_qty, 0))			QUANTITY,
		sum(decode(mv.time_snapshot_date_id, a.day,
			mv.backorder_line_cnt, 0))		LINE_CNT,
		sum(decode(mv.time_snapshot_date_id, b.day,
			mv.backorder_line_cnt, 0))		PREV_LINE_CNT,
		count(distinct(decode(mv.time_snapshot_date_id, a.day,
				mv.item_id, null)))		ITEM_CNT,
		count(distinct(decode(mv.time_snapshot_date_id, b.day,
				mv.item_id, null)))		PREV_ITEM_CNT
	   FROM (SELECT max(time_snapshot_date_id)		DAY
		   FROM	ISC_DBI_FM_0007_MV			mv
		  WHERE	mv.time_snapshot_date_id BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE
						     AND &BIS_CURRENT_ASOF_DATE
					)	a,
		(SELECT max(time_snapshot_date_id)		DAY
		   FROM	ISC_DBI_FM_0007_MV			mv
		  WHERE	mv.time_snapshot_date_id BETWEEN &BIS_PREVIOUS_EFFECTIVE_START_DATE
						     AND &BIS_PREVIOUS_ASOF_DATE
					)	b,
		ISC_DBI_FM_0007_MV		mv
	  WHERE	mv.time_snapshot_date_id IN (a.day, b.day)';
    END IF;

     l_inner_sql := l_inner_sql||l_inv_org_where||l_inv_cat_where||l_item_where||l_customer_where;

     l_outer_sql:= 'ISC_MEASURE_1,ISC_MEASURE_2,ISC_MEASURE_3,ISC_MEASURE_4,ISC_MEASURE_5,ISC_MEASURE_6,
	ISC_MEASURE_7,ISC_MEASURE_8,ISC_MEASURE_9,ISC_MEASURE_10,ISC_MEASURE_11';

      IF l_view_by = 'CUSTOMER+FII_CUSTOMERS' THEN
	 l_sql_stmt := '
 SELECT	cust.value			VIEWBY,
	cust.id				VIEWBYID,
	null				ISC_ATTRIBUTE_1, -- Description
	null				ISC_ATTRIBUTE_2, -- UOM
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
	null				ISC_ATTRIBUTE_1, -- Description
	null				ISC_ATTRIBUTE_2, -- UOM
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
	items.description			ISC_ATTRIBUTE_1, -- Description
	mtl.unit_of_measure			ISC_ATTRIBUTE_2, -- UOM
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
	null					ISC_ATTRIBUTE_1, -- Description
	null					ISC_ATTRIBUTE_2, -- UOM
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

  l_custom_rec.attribute_name := ':ISC_LANG';
  l_custom_rec.attribute_value := l_lang;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

END Get_Sql;

END ISC_DBI_BACKORDER_SUM_PKG ;


/
