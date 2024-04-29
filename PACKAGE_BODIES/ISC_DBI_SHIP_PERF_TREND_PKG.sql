--------------------------------------------------------
--  DDL for Package Body ISC_DBI_SHIP_PERF_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_SHIP_PERF_TREND_PKG" AS
/* $Header: ISCRG66B.pls 120.2 2006/06/26 06:17:33 abhdixi noship $ */

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
     l_att_2                  varchar(255);
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
    l_org_where := '
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

  ELSE
    l_org_where := '
  	    AND fact.inv_org_id = &ORGANIZATION+ORGANIZATION';
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

     If l_period_type = 'FII_TIME_WEEK' then
          l_att_2 := '''AS_OF_DATE=''||'|| 'to_char(fii1.end_date,''DD/MM/YYYY'')' || '||''&pFunctionName=ISC_DBI_SHIP_PERF_TREND&TIME+FII_TIME_DAY=TIME+FII_TIME_DAY&pParameters=pParamIds@Y''';
   else
     l_att_2 := 'NULL ';
   end if;

  If l_period_type = 'FII_TIME_DAY' then
	l_SQLText := 'SELECT	fii1.start_date  VIEWBY, '
	          || l_att_2 || ' ISC_ATTRIBUTE_2,
	          	nvl(s.p_line_shipped, 0) 	ISC_MEASURE_2,
			nvl(s.c_line_shipped, 0) 	ISC_MEASURE_1,
			nvl(s.c_late_schedule, 0) 	ISC_MEASURE_3,
			nvl(s.p_late_schedule, 0) 	ISC_MEASURE_4,
			nvl(s.p_late_promise, 0) 	ISC_MEASURE_6,
			nvl(s.c_late_promise, 0) 	ISC_MEASURE_5,
			null				CURRENCY -- obsoleted item from DBI 5.0
		   FROM	(SELECT	dates.start_date	START_DATE,
			sum(decode(dates.period, ''C'',
				fact.shipped_line_cnt, 0))	C_LINE_SHIPPED,
			sum(decode(dates.period, ''P'',
				fact.shipped_line_cnt, 0))	P_LINE_SHIPPED,
			sum(decode(dates.period, ''C'',
				fact.late_line_cnt, 0))		C_LATE_SCHEDULE,
			sum(decode(dates.period, ''P'',
				fact.late_line_cnt, 0))		P_LATE_SCHEDULE,
			sum(decode(dates.period, ''C'',
				fact.late_line_promise_cnt, 0))	C_LATE_PROMISE,
			sum(decode(dates.period, ''P'',
				fact.late_line_promise_cnt, 0))	P_LATE_PROMISE
 		FROM (SELECT fii1.start_date					START_DATE,
				''C''						PERIOD,
				least(fii1.end_date, &BIS_CURRENT_ASOF_DATE)	REPORT_DATE
			   	FROM	'||l_period_type||'	fii1
			  	WHERE	fii1.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
						   AND &BIS_CURRENT_ASOF_DATE
		     UNION ALL
			SELECT p1.start_date					START_DATE,
				''P''						PERIOD,
				p2.day						REPORT_DATE
			FROM (SELECT fii1.start_date				START_DATE,
				ROWNUM						ID
			   	FROM	'||l_period_type||'	fii1
			  	WHERE	fii1.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
						   AND &BIS_CURRENT_ASOF_DATE
				ORDER BY fii1.start_date DESC)				p1,
				(SELECT	least(fii1.end_date, &BIS_PREVIOUS_ASOF_DATE)	DAY,
					ROWNUM						ID
			   	FROM	'||l_period_type||'	fii1
			  	WHERE	fii1.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE
						   AND &BIS_PREVIOUS_ASOF_DATE
				ORDER BY fii1.start_date DESC)				p2
			WHERE p1.id = p2.id(+))	dates,
         		ISC_DBI_FM_0000_MV	fact
   		WHERE fact.agg_level = :ISC_AGG_LEVEL
		AND fact.time_id = to_char(dates.report_date,''j'')
		AND fact.period_type_id = 1 '
		||l_org_where||l_inv_cat_where||l_item_where||l_cust_where||'
    		GROUP BY dates.start_date) s,
		'|| l_period_type ||' 	fii1
		WHERE fii1.start_date = s.start_date(+)
		AND fii1.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
						AND &BIS_CURRENT_ASOF_DATE
		ORDER BY fii1.start_date';
    else
	l_SQLText := 'SELECT	fii1.NAME   VIEWBY, '
	          || l_att_2 || ' ISC_ATTRIBUTE_2,
			nvl(s.p_line_shipped, 0) 	ISC_MEASURE_2,
			nvl(s.c_line_shipped, 0)	ISC_MEASURE_1,
			nvl(s.c_late_schedule, 0) 	ISC_MEASURE_3,
			nvl(s.p_late_schedule, 0) 	ISC_MEASURE_4,
			nvl(s.p_late_promise, 0) 	ISC_MEASURE_6,
			nvl(s.c_late_promise, 0) 	ISC_MEASURE_5,
			null				CURRENCY -- obsoleted item from DBI 5.0
		   FROM	(SELECT	dates.start_date	START_DATE,
			sum(decode(dates.period, ''C'',
				fact.shipped_line_cnt, 0))	C_LINE_SHIPPED,
			sum(decode(dates.period, ''P'',
				fact.shipped_line_cnt, 0))	P_LINE_SHIPPED,
			sum(decode(dates.period, ''C'',
				fact.late_line_cnt, 0))		C_LATE_SCHEDULE,
			sum(decode(dates.period, ''P'',
				fact.late_line_cnt, 0))		P_LATE_SCHEDULE,
			sum(decode(dates.period, ''C'',
				fact.late_line_promise_cnt, 0))	C_LATE_PROMISE,
			sum(decode(dates.period, ''P'',
				fact.late_line_promise_cnt, 0))	P_LATE_PROMISE
 		FROM (SELECT fii1.start_date					START_DATE,
				''C''						PERIOD,
				least(fii1.end_date, &BIS_CURRENT_ASOF_DATE)	REPORT_DATE
			   	FROM	'||l_period_type||'	fii1
			  	WHERE	fii1.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
						   AND &BIS_CURRENT_ASOF_DATE
		     UNION ALL
			SELECT p1.start_date					START_DATE,
				''P''						PERIOD,
				p2.day						REPORT_DATE
			FROM (SELECT fii1.start_date				START_DATE,
				ROWNUM						ID
			   	FROM	'||l_period_type||'	fii1
			  	WHERE	fii1.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
						   AND &BIS_CURRENT_ASOF_DATE
				ORDER BY fii1.start_date DESC)				p1,
				(SELECT	least(fii1.end_date, &BIS_PREVIOUS_ASOF_DATE)	DAY,
					ROWNUM						ID
			   	FROM	'||l_period_type||'	fii1
			  	WHERE	fii1.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE
						   AND &BIS_PREVIOUS_ASOF_DATE
				ORDER BY fii1.start_date DESC)				p2
			WHERE p1.id = p2.id(+))	dates,
         		ISC_DBI_FM_0000_MV	fact,
			FII_TIME_RPT_STRUCT_V	cal
   		WHERE fact.agg_level = :ISC_AGG_LEVEL
		AND cal.report_date = dates.report_date
		AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN) = cal.record_type_id
		AND fact.time_id = cal.time_id
		AND fact.period_type_id = cal.period_type_id'
		||l_org_where||l_inv_cat_where||l_item_where||l_cust_where||'
    		GROUP BY dates.start_date) s,
		'|| l_period_type ||' 	fii1
		WHERE fii1.start_date = s.start_date(+)
		AND fii1.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
						AND &BIS_CURRENT_ASOF_DATE
		ORDER BY fii1.start_date';
   end if;

  x_custom_sql := l_SQLText;

  l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
  l_custom_rec.attribute_value := 'TIME+'||l_period_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_AGG_LEVEL';
  l_custom_rec.attribute_value := to_char(l_agg_level);
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;


END GET_SQL;

END ISC_DBI_SHIP_PERF_TREND_PKG;


/
