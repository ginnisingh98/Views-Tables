--------------------------------------------------------
--  DDL for Package Body ISC_DBI_DAYS_SHIP_AGING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_DAYS_SHIP_AGING_PKG" AS
/* $Header: ISCRG93B.pls 120.3 2006/06/26 06:24:41 abhdixi noship $ */

PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt 			VARCHAR2(10000);
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

  l_row_line_cnts		VARCHAR2(10000);
  l_bucket_rec			bis_bucket_pub.BIS_BUCKET_REC_TYPE;
  l_error_tbl			bis_utilities_pub.ERROR_TBL_TYPE;
  l_status			VARCHAR2(10000);

  l_custom_rec			BIS_QUERY_ATTRIBUTES;
  l_period_type			VARCHAR2(30);

BEGIN

  FOR i IN 1..p_param.COUNT
  LOOP
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
	 l_customer_flag := 1; -- do not need customer id
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
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

-- Retrieve record to get bucket labels
  bis_bucket_pub.RETRIEVE_BIS_BUCKET('ISC_DBI_DAYS_SHIP_AGING', l_bucket_rec, l_status, l_error_tbl);

-- Returns a single row containing the current and previous line counts for each bucket

IF(l_period_type = 'FII_TIME_DAY')
THEN
  l_row_line_cnts :='
	 (SELECT sum(decode(to_date(f.time_id,''j''), &BIS_CURRENT_ASOF_DATE,
			    f.bucket1_line_cnt, 0))			CURR1,
		sum(decode(to_date(f.time_id,''j''), &BIS_CURRENT_ASOF_DATE,
		   	   f.bucket2_line_cnt, 0))			CURR2,
		sum(decode(to_date(f.time_id,''j''), &BIS_CURRENT_ASOF_DATE,
		   	   f.bucket3_line_cnt, 0))			CURR3,
		sum(decode(to_date(f.time_id,''j''), &BIS_CURRENT_ASOF_DATE,
			   f.bucket4_line_cnt, 0))			CURR4,
		sum(decode(to_date(f.time_id,''j''), &BIS_CURRENT_ASOF_DATE,
		           f.bucket5_line_cnt, 0))			CURR5,
		sum(decode(to_date(f.time_id,''j''), &BIS_CURRENT_ASOF_DATE,
		   	   f.bucket6_line_cnt, 0))			CURR6,
		sum(decode(to_date(f.time_id,''j''), &BIS_CURRENT_ASOF_DATE,
		   	   f.bucket7_line_cnt, 0))			CURR7,
		sum(decode(to_date(f.time_id,''j''), &BIS_CURRENT_ASOF_DATE,
		   	   f.bucket8_line_cnt, 0))			CURR8,
		sum(decode(to_date(f.time_id,''j''), &BIS_CURRENT_ASOF_DATE,
			   f.bucket9_line_cnt, 0))			CURR9,
		sum(decode(to_date(f.time_id,''j''), &BIS_CURRENT_ASOF_DATE,
			   f.bucket10_line_cnt, 0))			CURR10,
		sum(decode(to_date(f.time_id,''j''), &BIS_PREVIOUS_ASOF_DATE,
			   f.bucket1_line_cnt, 0))			PREV1,
		sum(decode(to_date(f.time_id,''j''), &BIS_PREVIOUS_ASOF_DATE,
			   f.bucket2_line_cnt, 0))			PREV2,
		sum(decode(to_date(f.time_id,''j''), &BIS_PREVIOUS_ASOF_DATE,
			   f.bucket3_line_cnt, 0))			PREV3,
		sum(decode(to_date(f.time_id,''j''), &BIS_PREVIOUS_ASOF_DATE,
			   f.bucket4_line_cnt, 0))			PREV4,
		sum(decode(to_date(f.time_id,''j''), &BIS_PREVIOUS_ASOF_DATE,
			   f.bucket5_line_cnt, 0))			PREV5,
		sum(decode(to_date(f.time_id,''j''), &BIS_PREVIOUS_ASOF_DATE,
		   	   f.bucket6_line_cnt, 0))			PREV6,
		sum(decode(to_date(f.time_id,''j''), &BIS_PREVIOUS_ASOF_DATE,
			   f.bucket7_line_cnt, 0))			PREV7,
		sum(decode(to_date(f.time_id,''j''), &BIS_PREVIOUS_ASOF_DATE,
			   f.bucket8_line_cnt, 0))			PREV8,
		sum(decode(to_date(f.time_id,''j''), &BIS_PREVIOUS_ASOF_DATE,
			   f.bucket9_line_cnt, 0))			PREV9,
		sum(decode(to_date(f.time_id,''j''), &BIS_PREVIOUS_ASOF_DATE,
			   f.bucket10_line_cnt, 0))			PREV10
   	   FROM ISC_DBI_FM_0000_MV 		f
   	   WHERE f.time_id in
	   (to_char(&BIS_CURRENT_ASOF_DATE,''j''),to_char(&BIS_PREVIOUS_ASOF_DATE,''j''))
	   	AND f.period_type_id = 1
		AND f.agg_level = :ISC_AGG_LEVEL';
ELSE
  l_row_line_cnts :='
	 (SELECT sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
			    f.bucket1_line_cnt, 0))			CURR1,
		sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
		   	   f.bucket2_line_cnt, 0))			CURR2,
		sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
		   	   f.bucket3_line_cnt, 0))			CURR3,
		sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
			   f.bucket4_line_cnt, 0))			CURR4,
		sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
		           f.bucket5_line_cnt, 0))			CURR5,
		sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
		   	   f.bucket6_line_cnt, 0))			CURR6,
		sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
		   	   f.bucket7_line_cnt, 0))			CURR7,
		sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
		   	   f.bucket8_line_cnt, 0))			CURR8,
		sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
			   f.bucket9_line_cnt, 0))			CURR9,
		sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
			   f.bucket10_line_cnt, 0))			CURR10,
		sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
			   f.bucket1_line_cnt, 0))			PREV1,
		sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
			   f.bucket2_line_cnt, 0))			PREV2,
		sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
			   f.bucket3_line_cnt, 0))			PREV3,
		sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
			   f.bucket4_line_cnt, 0))			PREV4,
		sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
			   f.bucket5_line_cnt, 0))			PREV5,
		sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
		   	   f.bucket6_line_cnt, 0))			PREV6,
		sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
			   f.bucket7_line_cnt, 0))			PREV7,
		sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
			   f.bucket8_line_cnt, 0))			PREV8,
		sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
			   f.bucket9_line_cnt, 0))			PREV9,
		sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
			   f.bucket10_line_cnt, 0))			PREV10
   	   FROM ISC_DBI_FM_0000_MV 		f,
	     	FII_TIME_RPT_STRUCT_V		cal
   	   WHERE f.time_id = cal.time_id
		AND f.agg_level = :ISC_AGG_LEVEL
		AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
		AND cal.period_type_id = f.period_type_id
		AND bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id';
END IF;

   l_row_line_cnts := l_row_line_cnts||l_inv_org_where
			||l_inv_cat_where
			||l_item_where
			||l_customer_where||'),';

-- Construction of the SQL statement here

   l_stmt := '
SELECT	bucket					ISC_ATTRIBUTE_2,
	bucket_type				ISC_ATTRIBUTE_3,
	sum(c.prev_shipped_line_cnt)		ISC_MEASURE_2, -- Lines Shipped - prior
	sum(c.curr_shipped_line_cnt) 		ISC_MEASURE_1, -- Lines Shipped
 	(sum(c.curr_shipped_line_cnt) - sum(c.prev_shipped_line_cnt))
	  / decode( sum(c.prev_shipped_line_cnt),0,
		    NULL,
		    abs(sum(c.prev_shipped_line_cnt))) * 100
						ISC_MEASURE_3, -- Lines Shipped Change
	sum(c.curr_shipped_line_cnt)
	  / decode ( sum(sum(c.curr_shipped_line_cnt)) over (), 0,
		     NULL,
		     sum(sum(c.curr_shipped_line_cnt)) over ()) * 100
						ISC_MEASURE_4, -- Percent of Total
	sum(sum(c.curr_shipped_line_cnt)) over ()
						ISC_MEASURE_5, -- Gd Total for Lines Shipped
 	(sum(sum(c.curr_shipped_line_cnt)) over ()
	  - sum(sum(c.prev_shipped_line_cnt)) over ())
	  / decode( sum(sum(c.prev_shipped_line_cnt)) over (),0,
		    NULL,
		    abs(sum(sum(c.prev_shipped_line_cnt)) over())) * 100
						ISC_MEASURE_6, -- Gd Total for Change
	sum(sum(c.curr_shipped_line_cnt)) over ()
	  / decode ( sum(sum(c.curr_shipped_line_cnt)) over (), 0,
		     NULL,
		     sum(sum(c.curr_shipped_line_cnt)) over ()) * 100
						ISC_MEASURE_7 -- Gd Total for Percent of Total
   FROM	(SELECT decode(rownum,
			1, :ISC_R1,
			2, :ISC_R2,
			3, :ISC_R3,
			4, :ISC_R4,
			5, :ISC_R5,
			6, :ISC_R6,
			7, :ISC_R7,
			8, :ISC_R8,
			9, :ISC_R9,
			10, :ISC_R10,
			null)			BUCKET,
		rownum				BUCKET_TYPE,
		decode(rownum,
			1, CURR1,
			2, CURR2,
			3, CURR3,
			4, CURR4,
			5, CURR5,
			6, CURR6,
			7, CURR7,
			8, CURR8,
			9, CURR9,
			10, CURR10,
			null)			CURR_SHIPPED_LINE_CNT,
		decode(rownum,
			1, PREV1,
			2, PREV2,
			3, PREV3,
			4, PREV4,
			5, PREV5,
			6, PREV6,
			7, PREV7,
			8, PREV8,
			9, PREV9,
			10, PREV10,
			null)			PREV_SHIPPED_LINE_CNT
   	FROM'
	||l_row_line_cnts||'
	(SELECT 1 FROM DUAL		-- dummy table with 10 rows
	 UNION ALL SELECT 1 FROM DUAL
	 UNION ALL SELECT 1 FROM DUAL
	 UNION ALL SELECT 1 FROM DUAL
	 UNION ALL SELECT 1 FROM DUAL
	 UNION ALL SELECT 1 FROM DUAL
	 UNION ALL SELECT 1 FROM DUAL
	 UNION ALL SELECT 1 FROM DUAL
	 UNION ALL SELECT 1 FROM DUAL
	 UNION ALL SELECT 1 FROM DUAL)
	) c
WHERE BUCKET IS NOT NULL
GROUP BY BUCKET_TYPE,BUCKET
ORDER BY BUCKET_TYPE';

  x_custom_sql := l_stmt;

  l_custom_rec.attribute_name := ':ISC_AGG_LEVEL';
  l_custom_rec.attribute_value := to_char(l_agg_level);
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R1';
  l_custom_rec.attribute_value := l_bucket_rec.range1_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R2';
  l_custom_rec.attribute_value := l_bucket_rec.range2_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R3';
  l_custom_rec.attribute_value := l_bucket_rec.range3_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R4';
  l_custom_rec.attribute_value := l_bucket_rec.range4_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R5';
  l_custom_rec.attribute_value := l_bucket_rec.range5_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(6) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R6';
  l_custom_rec.attribute_value := l_bucket_rec.range6_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(7) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R7';
  l_custom_rec.attribute_value := l_bucket_rec.range7_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(8) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R8';
  l_custom_rec.attribute_value := l_bucket_rec.range8_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(9) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R9';
  l_custom_rec.attribute_value := l_bucket_rec.range9_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(10) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R10';
  l_custom_rec.attribute_value := l_bucket_rec.range10_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(11) := l_custom_rec;

END Get_Sql;

END ISC_DBI_DAYS_SHIP_AGING_PKG ;


/
