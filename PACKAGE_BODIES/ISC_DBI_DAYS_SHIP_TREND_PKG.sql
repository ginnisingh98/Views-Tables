--------------------------------------------------------
--  DDL for Package Body ISC_DBI_DAYS_SHIP_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_DAYS_SHIP_TREND_PKG" AS
/* $Header: ISCRG71B.pls 120.3 2006/05/03 03:08:39 achandak noship $ */


PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt 			VARCHAR2(10000);
  l_period_type			VARCHAR2(10000);
  l_inv_org 			VARCHAR2(10000);
  l_inv_org_where     		VARCHAR2(10000);
  l_item			VARCHAR2(10000);
  l_item_where			VARCHAR2(10000);
  l_inv_cat			VARCHAR2(10000);
  l_inv_cat_where		VARCHAR2(10000);
  l_customer			VARCHAR2(10000);
  l_customer_where		VARCHAR2(10000);
  l_item_cat_flag		NUMBER; -- 0 for item, 1 for inv category
  l_customer_flag		NUMBER; -- 0 for customer level, 1 for no-customer level
  l_agg_level			NUMBER;

  l_custom_rec			BIS_QUERY_ATTRIBUTES;
  l_att_2                VARCHAR2(255);
BEGIN

  FOR i IN 1..p_param.COUNT
  LOOP

    IF(p_param(i).parameter_name = 'PERIOD_TYPE')
      THEN l_period_type := p_param(i).parameter_value;
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

  END LOOP;

  IF(l_inv_cat IS NULL OR l_inv_cat = 'All')
    THEN l_inv_cat_where := '';
    ELSE l_inv_cat_where := '
	AND fact.item_category_id IN (&ITEM+ENI_ITEM_INV_CAT)';
  END IF;

  IF(l_item IS NULL OR l_item = 'All')
    THEN l_item_where := '';
    ELSE l_item_where := '
	AND fact.item_id IN (&ITEM+ENI_ITEM_ORG)';
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

    ELSE l_inv_org_where :=  '
	AND fact.inv_org_id = &ORGANIZATION+ORGANIZATION';
  END IF;

  IF (l_customer IS NULL OR l_customer = 'All')
    THEN l_customer_where :='';
	 l_customer_flag := 1; -- do not need customer id
    ELSE l_customer_where :='
	AND fact.customer_id IN (&CUSTOMER+FII_CUSTOMERS)';
	 l_customer_flag := 0; -- customer level
  END IF;

  IF((l_inv_cat IS NULL OR l_inv_cat = 'All') AND (l_item IS NULL OR l_item = 'All'))
    THEN l_item_cat_flag := 3;  -- no grouping on item dimension
    ELSE
      IF (l_item IS NULL OR l_item = 'All')
	THEN l_item_cat_flag := 1; -- inventory category
    	ELSE l_item_cat_flag := 0; -- item
      END IF;
  END IF;

  CASE
    WHEN (l_item_cat_flag = 0 and l_customer_flag = 0) THEN l_agg_level := 0;
    WHEN (l_item_cat_flag = 1 and l_customer_flag = 0) THEN l_agg_level := 4;
    WHEN (l_item_cat_flag = 3 and l_customer_flag = 0) THEN l_agg_level := 2;
    WHEN (l_item_cat_flag = 0 and l_customer_flag = 1) THEN l_agg_level := 1;
    WHEN (l_item_cat_flag = 1 and l_customer_flag = 1) THEN l_agg_level := 5;
    WHEN (l_item_cat_flag = 3 and l_customer_flag = 1) THEN l_agg_level := 3;
  END CASE;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := bis_query_attributes_tbl();

  If l_period_type = 'FII_TIME_WEEK' then
     l_att_2 := '''AS_OF_DATE=''||'|| 'to_char(fii1.end_date,''DD/MM/YYYY'')' || '||''&pFunctionName=ISC_DBI_DAYS_SHIP_TREND&TIME+FII_TIME_DAY=TIME+FII_TIME_DAY&pParameters=pParamIds@Y''';
  else
     l_att_2 := 'NULL ';
  end if;

  If l_period_type = 'FII_TIME_DAY' then
	l_stmt := 'SELECT	fii1.start_date  VIEWBY, 	fii1.start_date	ISC_ATTRIBUTE_2, '
	 || l_att_2 ||  ' ISC_ATTRIBUTE_3, nvl(s.curr_book_to_ship_days,0) 	ISC_MEASURE_1,
     	nvl(s.curr_shipped_line_cnt,0)		ISC_MEASURE_2,
        nvl(s.prev_book_to_ship_days,0) /
           decode(nvl(s.prev_shipped_line_cnt,0), 0, NULL,
                  abs(nvl(s.prev_shipped_line_cnt,0)))   ISC_MEASURE_5,
	nvl(s.prev_book_to_ship_days,0)		ISC_MEASURE_3,
	nvl(s.prev_shipped_line_cnt,0)		ISC_MEASURE_4,
        nvl(s.curr_book_to_ship_days,0) /
           decode(nvl(s.curr_shipped_line_cnt,0), 0, NULL,
                  abs(nvl(s.curr_shipped_line_cnt,0)))   ISC_MEASURE_6,
        nvl(s.curr_book_to_ship_days,0) /
           decode(nvl(s.curr_shipped_line_cnt,0), 0, NULL,
                  abs(nvl(s.curr_shipped_line_cnt,0))) -
        nvl(s.prev_book_to_ship_days,0) /
           decode(nvl(s.prev_shipped_line_cnt,0), 0, NULL,
                  abs(nvl(s.prev_shipped_line_cnt,0)))   ISC_MEASURE_7,
	null					CURRENCY,  -- obsolete
        null					ISC_CALC_ITEM_2,  -- obsolete
        null					ISC_CALC_ITEM_1,  -- obsolete
        null					ISC_CALC_ITEM_3  -- obsolete
   FROM	(SELECT	dates.start_date				START_DATE,
		sum(decode(dates.period, ''C'',
			nvl(fact.book_to_ship_days,0), 0))	CURR_BOOK_TO_SHIP_DAYS,
		sum(decode(dates.period, ''P'',
			nvl(fact.book_to_ship_days,0), 0))	PREV_BOOK_TO_SHIP_DAYS,
		sum(decode(dates.period, ''C'',
			nvl(fact.shipped_line_cnt,0), 0))	CURR_SHIPPED_LINE_CNT,
		sum(decode(dates.period, ''P'',
			nvl(fact.shipped_line_cnt,0), 0))	PREV_SHIPPED_LINE_CNT
	   FROM	(SELECT	fii1.start_date					START_DATE,
			''C''						PERIOD,
			least(fii1.end_date, &BIS_CURRENT_ASOF_DATE)	REPORT_DATE
		   FROM	'||l_period_type||'	fii1
		  WHERE	fii1.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
					   AND &BIS_CURRENT_ASOF_DATE
		UNION ALL
		 SELECT	p2.start_date					START_DATE,
			''P''						PERIOD,
			p1.report_date					REPORT_DATE
		   FROM	(SELECT	least(fii1.end_date, &BIS_PREVIOUS_ASOF_DATE)	REPORT_DATE,
				rownum						ID
			   FROM	'||l_period_type||'	fii1
			  WHERE	fii1.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE
						   AND &BIS_PREVIOUS_ASOF_DATE
			  ORDER BY fii1.start_date DESC) p1,
			(SELECT	fii1.start_date					START_DATE,
				rownum						ID
			   FROM	'||l_period_type||'	fii1
			  WHERE	fii1.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
						   AND &BIS_CURRENT_ASOF_DATE
			  ORDER BY fii1.start_date DESC) p2
		  WHERE	p1.id(+) = p2.id)			dates,
		ISC_DBI_FM_0000_MV 				fact
	   WHERE fact.agg_level = :ISC_AGG_LEVEL
		AND fact.time_id = to_char(dates.report_date,''j'')
		AND fact.period_type_id = 1 '
		||l_inv_org_where
		||l_inv_cat_where
		||l_item_where
		||l_customer_where||'
	GROUP BY dates.start_date)	s,
	'||l_period_type||'		fii1
  WHERE	fii1.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
			   AND &BIS_CURRENT_ASOF_DATE
    AND	fii1.start_date = s.start_date(+)
     ORDER BY fii1.start_date';
  else
     l_stmt := 'SELECT	fii1.NAME   VIEWBY, fii1.NAME ISC_ATTRIBUTE_2, '
     	|| l_att_2 || ' ISC_ATTRIBUTE_3, nvl(s.curr_book_to_ship_days,0) 	ISC_MEASURE_1,
     	     	nvl(s.curr_shipped_line_cnt,0)		ISC_MEASURE_2,
        nvl(s.prev_book_to_ship_days,0) /
           decode(nvl(s.prev_shipped_line_cnt,0), 0, NULL,
                  abs(nvl(s.prev_shipped_line_cnt,0)))   ISC_MEASURE_5,
	nvl(s.prev_book_to_ship_days,0)		ISC_MEASURE_3,
	nvl(s.prev_shipped_line_cnt,0)		ISC_MEASURE_4,
        nvl(s.curr_book_to_ship_days,0) /
           decode(nvl(s.curr_shipped_line_cnt,0), 0, NULL,
                  abs(nvl(s.curr_shipped_line_cnt,0)))   ISC_MEASURE_6,
        nvl(s.curr_book_to_ship_days,0) /
           decode(nvl(s.curr_shipped_line_cnt,0), 0, NULL,
                  abs(nvl(s.curr_shipped_line_cnt,0))) -
        nvl(s.prev_book_to_ship_days,0) /
           decode(nvl(s.prev_shipped_line_cnt,0), 0, NULL,
                  abs(nvl(s.prev_shipped_line_cnt,0)))   ISC_MEASURE_7,
	null					CURRENCY,  -- obsolete
        null					ISC_CALC_ITEM_2,  -- obsolete
        null					ISC_CALC_ITEM_1,  -- obsolete
        null					ISC_CALC_ITEM_3  -- obsolete
   FROM	(SELECT	dates.start_date				START_DATE,
		sum(decode(dates.period, ''C'',
			nvl(fact.book_to_ship_days,0), 0))	CURR_BOOK_TO_SHIP_DAYS,
		sum(decode(dates.period, ''P'',
			nvl(fact.book_to_ship_days,0), 0))	PREV_BOOK_TO_SHIP_DAYS,
		sum(decode(dates.period, ''C'',
			nvl(fact.shipped_line_cnt,0), 0))	CURR_SHIPPED_LINE_CNT,
		sum(decode(dates.period, ''P'',
			nvl(fact.shipped_line_cnt,0), 0))	PREV_SHIPPED_LINE_CNT
	   FROM	(SELECT	fii1.start_date					START_DATE,
			''C''						PERIOD,
			least(fii1.end_date, &BIS_CURRENT_ASOF_DATE)	REPORT_DATE
		   FROM	'||l_period_type||'	fii1
		  WHERE	fii1.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
					   AND &BIS_CURRENT_ASOF_DATE
		UNION ALL
		 SELECT	p2.start_date					START_DATE,
			''P''						PERIOD,
			p1.report_date					REPORT_DATE
		   FROM	(SELECT	least(fii1.end_date, &BIS_PREVIOUS_ASOF_DATE)	REPORT_DATE,
				rownum						ID
			   FROM	'||l_period_type||'	fii1
			  WHERE	fii1.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE
						   AND &BIS_PREVIOUS_ASOF_DATE
			  ORDER BY fii1.start_date DESC) p1,
			(SELECT	fii1.start_date					START_DATE,
				rownum						ID
			   FROM	'||l_period_type||'	fii1
			  WHERE	fii1.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
						   AND &BIS_CURRENT_ASOF_DATE
			  ORDER BY fii1.start_date DESC) p2
		  WHERE	p1.id(+) = p2.id)			dates,
		ISC_DBI_FM_0000_MV 				fact,
		FII_TIME_RPT_STRUCT_V				cal
	  WHERE	cal.report_date = dates.report_date
	    AND bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id
	    AND fact.time_id = cal.time_id
	    AND fact.period_type_id = cal.period_type_id
	    AND fact.agg_level = :ISC_AGG_LEVEL'
		||l_inv_org_where
		||l_inv_cat_where
		||l_item_where
		||l_customer_where||'
	GROUP BY dates.start_date)	s,
	'||l_period_type||'		fii1
  WHERE	fii1.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
			   AND &BIS_CURRENT_ASOF_DATE
    AND	fii1.start_date = s.start_date(+)
     ORDER BY fii1.start_date';
end if;


  x_custom_sql := l_stmt;

  l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.View_By_Value;
  l_custom_rec.attribute_value := 'TIME+'||l_period_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.View_By_Type;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_AGG_LEVEL';
  l_custom_rec.attribute_value := to_char(l_agg_level);
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.Bind_Type;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.Integer_Bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

END Get_Sql;
END ISC_DBI_DAYS_SHIP_TREND_PKG;

/
