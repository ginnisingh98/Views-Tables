--------------------------------------------------------
--  DDL for Package Body ISC_DBI_SHIP_OT_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_SHIP_OT_TREND_PKG" AS
/* $Header: ISCRG92B.pls 120.0 2005/05/25 17:21:57 appldev noship $ */

PROCEDURE GET_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,x_custom_sql OUT NOCOPY VARCHAR2,
	x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS


	l_SQLText 			VARCHAR2(15000);
        l_period_type 			VARCHAR2(30);
        l_org 				VARCHAR2(100);
        l_org_where 			VARCHAR2(500);
  	l_item				VARCHAR2(32000);
	l_item_where			VARCHAR2(32000);
	l_inv_cat 			VARCHAR2(32000);
	l_inv_cat_where			VARCHAR2(32000);
	l_cust				VARCHAR2(32000);
	l_cust_where			VARCHAR2(32000);
	l_item_cat_flag			NUMBER; -- 0 for product and 1 for product category
  	l_cust_flag			NUMBER; -- 0 for customer level, 1 for no-customer level
	l_agg_level			NUMBER;
	l_custom_rec 			BIS_QUERY_ATTRIBUTES ;

BEGIN

  FOR i IN 1..p_param.COUNT
  LOOP

    IF(p_param(i).parameter_name = 'PERIOD_TYPE')
      THEN  l_period_type := p_param(i).parameter_value;
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
    l_org_where := 'WHERE (EXISTS
		(SELECT 1
		FROM org_access o
		WHERE o.responsibility_id = fnd_global.resp_id
		AND o.resp_application_id = fnd_global.resp_appl_id
		AND o.organization_id = inv_org_id)
		OR EXISTS
		(SELECT 1
		FROM mtl_parameters org
		WHERE org.organization_id = inv_org_id
		AND NOT EXISTS
			(SELECT 1
			FROM org_access ora
			WHERE org.organization_id = ora.organization_id)))';

  ELSE
    l_org_where := 'WHERE inv_org_id = &ORGANIZATION+ORGANIZATION';
  END IF;

  IF ( l_inv_cat IS NULL OR l_inv_cat = 'All' ) THEN
    l_inv_cat_where :='';
  ELSE
    l_inv_cat_where := '
	AND fact.item_category_id in (&ITEM+ENI_ITEM_INV_CAT)';
  END IF;

  IF ( l_item IS NULL OR l_item = 'All' )
    THEN l_item_where := '';
    ELSE l_item_where := '
		AND fact.item_id in (&ITEM+ENI_ITEM_ORG)';
  END IF;

  IF((l_inv_cat IS NULL OR l_inv_cat = 'All' ) AND ( l_item IS NULL OR l_item = 'All'))
   THEN l_item_cat_flag := 3;  -- no grouping on item dimension

   ELSE
	IF (l_item IS NULL OR l_item = 'All')
    	THEN l_item_cat_flag := 1; -- inv, category
    	ELSE l_item_cat_flag := 0; -- item is needed
	END IF;
  END IF;

  IF (l_cust IS NULL OR l_cust = 'All') THEN
    l_cust_where:='';
    l_cust_flag := 1; -- do not need customer id
  ELSE
    l_cust_where :='
	AND fact.customer_id in (&CUSTOMER+FII_CUSTOMERS)';
    l_cust_flag := 0; -- customer level
  END IF;

  CASE
    WHEN (l_item_cat_flag = 0 and l_cust_flag = 0) THEN l_agg_level := 0;
    WHEN (l_item_cat_flag = 1 and l_cust_flag = 0) THEN l_agg_level := 4;
    WHEN (l_item_cat_flag = 3 and l_cust_flag = 0) THEN l_agg_level := 2;
    WHEN (l_item_cat_flag = 0 and l_cust_flag = 1) THEN l_agg_level := 1;
    WHEN (l_item_cat_flag = 1 and l_cust_flag = 1) THEN l_agg_level := 5;
    WHEN (l_item_cat_flag = 3 and l_cust_flag = 1) THEN l_agg_level := 3;
  END CASE;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  l_SQLText := 'SELECT	fii.name 					VIEWBY,
			nvl(sum(s.early_line_cnt),0)			ISC_MEASURE_1,
			nvl(sum(s.early_line_cnt),0)/
				decode(sum(s.shipped_line_cnt),0,null,
					sum(s.shipped_line_cnt))*100	ISC_MEASURE_2,
			nvl(sum(s.on_time_line_cnt),0)	 		ISC_MEASURE_3,
			nvl(sum(s.on_time_line_cnt),0)/
				decode(sum(s.shipped_line_cnt),0,null,
					sum(s.shipped_line_cnt))*100	ISC_MEASURE_4,
			nvl(sum(s.late_line_cnt),0) 			ISC_MEASURE_5,
			nvl(sum(s.early_line_cnt),0)/
				decode(sum(s.shipped_line_cnt),0,null,
					sum(s.shipped_line_cnt))*100	ISC_MEASURE_10,--duplicate row for graph
			nvl(sum(s.on_time_line_cnt),0)/
				decode(sum(s.shipped_line_cnt),0,null,
					sum(s.shipped_line_cnt))*100	ISC_MEASURE_11, --duplicate row for graph
			nvl(sum(s.late_line_cnt),0)/
				decode(sum(s.shipped_line_cnt),0,null,
					sum(s.shipped_line_cnt))*100 	ISC_MEASURE_6,
			nvl(sum(s.shipped_line_cnt),0)			ISC_MEASURE_7,
			nvl(sum(s.scheduled_line_cnt),0)		ISC_MEASURE_8,
			nvl(sum(s.shipped_line_cnt),0)/
				decode(sum(scheduled_line_cnt),0,null,
					sum(scheduled_line_cnt))*100		ISC_MEASURE_9
		   FROM	(SELECT start_date,early_line_cnt,on_time_line_cnt,
				late_line_cnt,shipped_line_cnt,scheduled_line_cnt
		   FROM (SELECT	dates.start_date	START_DATE,
			fact.early_line_cnt		EARLY_LINE_CNT,
			fact.on_time_line_cnt		ON_TIME_LINE_CNT,
			fact.late_line_cnt		LATE_LINE_CNT,
			fact.shipped_line_cnt		SHIPPED_LINE_CNT,
			0				SCHEDULED_LINE_CNT,
			fact.inv_org_id			INV_ORG_ID
 			FROM (SELECT fii.start_date				START_DATE,
				least(fii.end_date, &BIS_CURRENT_ASOF_DATE)	CURR_DAY
			   	FROM	'||l_period_type||'	fii
			  	WHERE	fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
						   AND &BIS_CURRENT_ASOF_DATE
				ORDER BY fii.start_date DESC)	dates,
         		ISC_DBI_FM_0000_MV	fact,
			FII_TIME_RPT_STRUCT_V	cal
   		WHERE fact.agg_level = :ISC_AGG_LEVEL
		AND cal.report_date IN (dates.curr_day)
		AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN) = cal.record_type_id
		AND fact.time_id = cal.time_id
		AND fact.period_type_id = cal.period_type_id'
		||l_inv_cat_where||l_item_where||l_cust_where||'
	UNION ALL
			SELECT	dates.start_date	START_DATE,
			0				EARLY_LINE_CNT,
			0				ON_TIME_LINE_CNT,
			0				LATE_LINE_CNT,
			0				SHIPPED_LINE_CNT,
			schedule_line_cnt		SCHEDULED_LINE_CNT,
			fact.inv_org_id			INV_ORG_ID
 			FROM (SELECT fii.start_date				START_DATE,
				least(fii.end_date,&BIS_CURRENT_ASOF_DATE)	CURR_DAY
			   	FROM	'||l_period_type||'	fii
			  	WHERE	fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
						   AND &BIS_CURRENT_ASOF_DATE
				ORDER BY fii.start_date DESC)	dates,
         		ISC_DBI_FM_0001_MV	fact,
			FII_TIME_RPT_STRUCT_V	cal
   		WHERE fact.item_cat_flag = :ISC_ITEM_CAT_FLAG
		AND fact.customer_flag = :ISC_CUST_FLAG
		AND cal.report_date = dates.curr_day
		AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN) = cal.record_type_id
		AND fact.time_id = cal.time_id
		AND fact.period_type_id = cal.period_type_id'
		||l_inv_cat_where||l_item_where||l_cust_where||')
		'||l_org_where||')s,
		'|| l_period_type ||' 	fii
		WHERE fii.start_date = s.start_date(+)
		AND fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
						AND &BIS_CURRENT_ASOF_DATE
		GROUP BY fii.name,fii.start_date
		ORDER BY fii.start_date';

  x_custom_sql := l_SQLText;

  l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
  l_custom_rec.attribute_value := 'TIME+'||l_period_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_ITEM_CAT_FLAG';
  l_custom_rec.attribute_value := to_char(l_item_cat_flag);
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_CUST_FLAG';
  l_custom_rec.attribute_value := to_char(l_cust_flag);
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_AGG_LEVEL';
  l_custom_rec.attribute_value := to_char(l_agg_level);
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;


END GET_SQL;

END ISC_DBI_SHIP_OT_TREND_PKG;


/
