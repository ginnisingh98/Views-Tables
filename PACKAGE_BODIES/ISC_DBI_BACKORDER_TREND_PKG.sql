--------------------------------------------------------
--  DDL for Package Body ISC_DBI_BACKORDER_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_BACKORDER_TREND_PKG" AS
/* $Header: ISCRGAWB.pls 120.2 2006/06/26 06:31:37 abhdixi noship $ */


PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sql_stmt 			VARCHAR2(10000);
  l_period_type			VARCHAR2(10000);
  l_inv_org 			VARCHAR2(10000);
  l_inv_org_where		VARCHAR2(10000);
  l_item			VARCHAR2(10000);
  l_item_where			VARCHAR2(10000);
  l_inv_cat			VARCHAR2(10000);
  l_inv_cat_where		VARCHAR2(10000);
  l_customer			VARCHAR2(10000);
  l_customer_where		VARCHAR2(10000);

  l_custom_rec			BIS_QUERY_ATTRIBUTES;
  l_att_2                VARCHAR2(255);
BEGIN

  FOR i IN 1..p_param.COUNT
  LOOP

    IF(p_param(i).parameter_name = 'PERIOD_TYPE')
      THEN l_period_type := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION')
      THEN l_inv_org := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_INV_CAT')
      THEN l_inv_cat := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_ORG')
      THEN l_item := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'CUSTOMER+FII_CUSTOMERS')
      THEN l_customer :=  p_param(i).parameter_value;
    END IF;

  END LOOP;

  IF(l_inv_org IS NULL OR l_inv_org = 'All')
    THEN l_inv_org_where := '
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
    ELSE l_inv_org_where := '
	    AND inv_org_id = &ORGANIZATION+ORGANIZATION';
  END IF;

  IF (l_customer IS NULL OR l_customer = 'All')
    THEN l_customer_where :='';
    ELSE l_customer_where :='
	    AND mv.customer_id IN (&CUSTOMER+FII_CUSTOMERS)';
  END IF;

  IF(l_inv_cat IS NULL OR l_inv_cat = 'All')
    THEN l_inv_cat_where := '';
    ELSE l_inv_cat_where := '
	    AND item_category_id IN (&ITEM+ENI_ITEM_INV_CAT)';
  END IF;

  IF(l_item IS NULL OR l_item = 'All')
    THEN l_item_where := '';
    ELSE l_item_where := '
	    AND item_id IN (&ITEM+ENI_ITEM_ORG)';
  END IF;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := bis_query_attributes_tbl();

  If l_period_type = 'FII_TIME_WEEK' then
     l_att_2 := '''AS_OF_DATE=''||'|| 'to_char(fii1.end_date,''DD/MM/YYYY'')' || '||''&pFunctionName=ISC_DBI_BACKORDER_TREND&TIME+FII_TIME_DAY=TIME+FII_TIME_DAY&pParameters=pParamIds@Y''';
  else
     l_att_2 := 'NULL ';
  end if;

  If l_period_type = 'FII_TIME_DAY' then
	l_sql_stmt := 'SELECT	fii1.start_date  VIEWBY,';
	l_sql_stmt := l_sql_stmt || l_att_2 ||  ' ISC_ATTRIBUTE_2,
	s.prev_bkord_lines	ISC_MEASURE_2, -- Backordered Lines - prior
	s.curr_bkord_lines	ISC_MEASURE_1, -- Backordered Lines
	(s.curr_bkord_lines - s.prev_bkord_lines)
	  / decode( s.prev_bkord_lines, 0, NULL,
		    abs(s.prev_bkord_lines)) * 100
				ISC_MEASURE_3, -- (Backordered Lines) Change
	s.prev_bkord_items	ISC_MEASURE_5, -- Backordered Items - prior
	s.curr_bkord_items	ISC_MEASURE_4, -- Backordered Items
	(s.curr_bkord_items - s.prev_bkord_items)
	  / decode( s.prev_bkord_items, 0, NULL,
		    abs(s.prev_bkord_items)) * 100
				ISC_MEASURE_6 -- (Backordered Items) Change
   FROM	(SELECT	dates.start_date					START_DATE,
		sum(decode(mv.time_snapshot_date_id, dates.curr_day,
			   mv.backorder_line_cnt, NULL))		CURR_BKORD_LINES,
		sum(decode(mv.time_snapshot_date_id, dates.prev_day,
			   mv.backorder_line_cnt, NULL))		PREV_BKORD_LINES,
		count(distinct(decode(mv.time_snapshot_date_id, dates.curr_day,
				      decode(mv.item_id,''-'',null,mv.item_id),
				      null)))				CURR_BKORD_ITEMS,
		count(distinct(decode(mv.time_snapshot_date_id, dates.prev_day,
				      decode(mv.item_id,''-'',null,mv.item_id),
				      null)))				PREV_BKORD_ITEMS
	   FROM	(SELECT	curr.start_date	START_DATE,
			curr.day	CURR_DAY,
			prev.day	PREV_DAY
		   FROM	(SELECT start_date,
				day,
				rownum	ID
			   FROM
			(SELECT	fii1.start_date				START_DATE,
				     fii1.start_date			DAY
			   FROM	'||l_period_type||'		fii1
			  WHERE	fii1.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
						   AND &BIS_CURRENT_ASOF_DATE
			   )
			ORDER BY start_date DESC)		curr,
			(SELECT start_date,
				day,
				rownum	ID
			   FROM
			(SELECT	fii1.start_date				START_DATE,
				     fii1.start_date			DAY
			   FROM	'||l_period_type||'		fii1
			  WHERE	fii1.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE
						   AND &BIS_PREVIOUS_ASOF_DATE)
			ORDER BY start_date DESC)		prev
		  WHERE	curr.id = prev.id(+))			dates,
		ISC_DBI_FM_0007_MV 				mv
	  WHERE	mv.time_snapshot_date_id IN (dates.curr_day, dates.prev_day)
	    AND ((1=1'
		||l_inv_org_where
		||l_inv_cat_where
		||l_item_where
		||l_customer_where
		||')
	     OR	mv.inv_org_id IS NULL) -- snapshot taken but no data
	GROUP BY dates.start_date)	s,
	'||l_period_type||'		fii1
     WHERE	fii1.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
			   AND &BIS_CURRENT_ASOF_DATE
     AND	fii1.start_date = s.start_date(+)
     ORDER BY fii1.start_date';
  else
	l_sql_stmt := 'SELECT	fii1.NAME   VIEWBY,';
	l_sql_stmt := l_sql_stmt || l_att_2 ||  ' ISC_ATTRIBUTE_2,
	s.prev_bkord_lines	ISC_MEASURE_2, -- Backordered Lines - prior
	s.curr_bkord_lines	ISC_MEASURE_1, -- Backordered Lines
	(s.curr_bkord_lines - s.prev_bkord_lines)
	  / decode( s.prev_bkord_lines, 0, NULL,
		    abs(s.prev_bkord_lines)) * 100
				ISC_MEASURE_3, -- (Backordered Lines) Change
	s.prev_bkord_items	ISC_MEASURE_5, -- Backordered Items - prior
	s.curr_bkord_items	ISC_MEASURE_4, -- Backordered Items
	(s.curr_bkord_items - s.prev_bkord_items)
	  / decode( s.prev_bkord_items, 0, NULL,
		    abs(s.prev_bkord_items)) * 100
				ISC_MEASURE_6 -- (Backordered Items) Change
   FROM	(SELECT	dates.start_date					START_DATE,
		sum(decode(mv.time_snapshot_date_id, dates.curr_day,
			   mv.backorder_line_cnt, NULL))		CURR_BKORD_LINES,
		sum(decode(mv.time_snapshot_date_id, dates.prev_day,
			   mv.backorder_line_cnt, NULL))		PREV_BKORD_LINES,
		count(distinct(decode(mv.time_snapshot_date_id, dates.curr_day,
				      decode(mv.item_id,''-'',null,mv.item_id),
				      null)))				CURR_BKORD_ITEMS,
		count(distinct(decode(mv.time_snapshot_date_id, dates.prev_day,
				      decode(mv.item_id,''-'',null,mv.item_id),
				      null)))				PREV_BKORD_ITEMS
	   FROM	(SELECT	curr.start_date	START_DATE,
			curr.day	CURR_DAY,
			prev.day	PREV_DAY
		   FROM	(SELECT start_date,
				day,
				rownum	ID
			   FROM
			(SELECT	fii1.start_date				START_DATE,
				max(mv.time_snapshot_date_id)		DAY
			   FROM	'||l_period_type||'		fii1,
				ISC_DBI_FM_0007_MV		mv
			  WHERE	fii1.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
						   AND &BIS_CURRENT_ASOF_DATE
			    AND	mv.time_snapshot_date_id (+) >= fii1.start_date
			    AND	mv.time_snapshot_date_id (+) <= fii1.end_date
			    AND	mv.time_snapshot_date_id (+) <= &BIS_CURRENT_ASOF_DATE
			GROUP BY fii1.start_date)
			ORDER BY start_date DESC)		curr,
			(SELECT start_date,
				day,
				rownum	ID
			   FROM
			(SELECT	fii1.start_date				START_DATE,
				max(mv.time_snapshot_date_id)		DAY
			   FROM	'||l_period_type||'		fii1,
				ISC_DBI_FM_0007_MV		mv
			  WHERE	fii1.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE
						   AND &BIS_PREVIOUS_ASOF_DATE
			    AND	mv.time_snapshot_date_id (+) >= fii1.start_date
			    AND	mv.time_snapshot_date_id (+) <= fii1.end_date
			    AND	mv.time_snapshot_date_id (+) <= &BIS_PREVIOUS_ASOF_DATE
			GROUP BY fii1.start_date)
			ORDER BY start_date DESC)		prev
		  WHERE	curr.id = prev.id(+))			dates,
		ISC_DBI_FM_0007_MV 				mv
	  WHERE	mv.time_snapshot_date_id IN (dates.curr_day, dates.prev_day)
	    AND ((1=1'
		||l_inv_org_where
		||l_inv_cat_where
		||l_item_where
		||l_customer_where
		||')
	     OR	mv.inv_org_id IS NULL) -- snapshot taken but no data
	GROUP BY dates.start_date)	s,
	'||l_period_type||'		fii1
     WHERE	fii1.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
			   AND &BIS_CURRENT_ASOF_DATE
     AND	fii1.start_date = s.start_date(+)
     ORDER BY fii1.start_date';
end if;

  x_custom_sql := l_sql_stmt;

  l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.View_By_Value;
  l_custom_rec.attribute_value := 'TIME+'||l_period_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.View_By_Type;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

END Get_Sql;

END ISC_DBI_BACKORDER_TREND_PKG ;


/
