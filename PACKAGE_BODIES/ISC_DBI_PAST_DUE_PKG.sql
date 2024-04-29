--------------------------------------------------------
--  DDL for Package Body ISC_DBI_PAST_DUE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_PAST_DUE_PKG" AS
/* $Header: ISCRG74B.pls 115.21 2003/10/08 03:46:39 chu noship $ */


PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sql_stmt 			VARCHAR2(10000);
  l_stmt			VARCHAR2(10000);
  l_inv_org 			VARCHAR2(10000);
  l_inv_org_where     		VARCHAR2(10000);
  l_customer			VARCHAR2(10000);
  l_customer_where		VARCHAR2(10000);
  l_item			VARCHAR2(10000);
  l_item_where			VARCHAR2(10000);
  l_inv_cat			VARCHAR2(10000);
  l_inv_cat_where		VARCHAR2(10000);
  l_item_cat_flag		NUMBER; -- 0 for item, 1 for inv category
  l_customer_flag		NUMBER; -- 0 for customer level, 1 for no-customer level

  l_period_type			VARCHAR2(240);

  l_snapshot_taken		BOOLEAN		:= TRUE;

  l_as_of_date			DATE;
  l_effective_start_date	DATE;

  l_cursor_id			NUMBER;
  l_dummy			NUMBER;

  l_row_line_cnts		VARCHAR2(10000);
  l_bucket_rec			bis_bucket_pub.BIS_BUCKET_REC_TYPE;
  l_error_tbl			bis_utilities_pub.ERROR_TBL_TYPE;
  l_status			VARCHAR2(10000);

  l_custom_rec			BIS_QUERY_ATTRIBUTES;

BEGIN

  FOR i IN 1..p_param.COUNT
  LOOP
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
	AND inv_org_id = &ORGANIZATION+ORGANIZATION';
  END IF;

  IF (l_customer IS NULL OR l_customer = 'All')
    THEN l_customer_where :='';
	 l_customer_flag := 1; -- do not need customer id
    ELSE l_customer_where :='
	AND customer_id IN (&CUSTOMER+FII_CUSTOMERS)';
	 l_customer_flag := 0; -- customer level
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

  IF((l_inv_cat IS NULL OR l_inv_cat = 'All') AND (l_item IS NULL OR l_item = 'All'))
    THEN l_item_cat_flag := 3;  -- no grouping on item dimension
    ELSE
      IF (l_item IS NULL OR l_item = 'All')
	THEN l_item_cat_flag := 1; -- inventory category
    	ELSE l_item_cat_flag := 0; -- item
      END IF;
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
	   AND rownum = 1';

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

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

-- Retrieve record to get bucket labels
  bis_bucket_pub.RETRIEVE_BIS_BUCKET('ISC_DBI_PAST_DUE', l_bucket_rec, l_status, l_error_tbl);

  IF (l_snapshot_taken)
    THEN

  l_row_line_cnts :='
	 (SELECT sum(decode(mv.time_snapshot_date_id,a.day,
			    mv.bucket1_line_cnt, 0))			CURR1,
		sum(decode(mv.time_snapshot_date_id,a.day,
		   	   mv.bucket2_line_cnt, 0))			CURR2,
		sum(decode(mv.time_snapshot_date_id,a.day,
		   	   mv.bucket3_line_cnt, 0))			CURR3,
		sum(decode(mv.time_snapshot_date_id,a.day,
			   mv.bucket4_line_cnt, 0))			CURR4,
		sum(decode(mv.time_snapshot_date_id,a.day,
		           mv.bucket5_line_cnt, 0))			CURR5,
		sum(decode(mv.time_snapshot_date_id,a.day,
		   	   mv.bucket6_line_cnt, 0))			CURR6,
		sum(decode(mv.time_snapshot_date_id,a.day,
		   	   mv.bucket7_line_cnt, 0))			CURR7,
		sum(decode(mv.time_snapshot_date_id,a.day,
		   	   mv.bucket8_line_cnt, 0))			CURR8,
		sum(decode(mv.time_snapshot_date_id,a.day,
			   mv.bucket9_line_cnt, 0))			CURR9,
		sum(decode(mv.time_snapshot_date_id,a.day,
			   mv.bucket10_line_cnt, 0))			CURR10,
		sum(decode(mv.time_snapshot_date_id, b.day,
			   mv.bucket1_line_cnt, 0))			PREV1,
		sum(decode(mv.time_snapshot_date_id, b.day,
			   mv.bucket2_line_cnt, 0))			PREV2,
		sum(decode(mv.time_snapshot_date_id, b.day,
			   mv.bucket3_line_cnt, 0))			PREV3,
		sum(decode(mv.time_snapshot_date_id, b.day,
			   mv.bucket4_line_cnt, 0))			PREV4,
		sum(decode(mv.time_snapshot_date_id, b.day,
			   mv.bucket5_line_cnt, 0))			PREV5,
		sum(decode(mv.time_snapshot_date_id, b.day,
		   	   mv.bucket6_line_cnt, 0))			PREV6,
		sum(decode(mv.time_snapshot_date_id, b.day,
			   mv.bucket7_line_cnt, 0))			PREV7,
		sum(decode(mv.time_snapshot_date_id, b.day,
			   mv.bucket8_line_cnt, 0))			PREV8,
		sum(decode(mv.time_snapshot_date_id, b.day,
			   mv.bucket9_line_cnt, 0))			PREV9,
		sum(decode(mv.time_snapshot_date_id, b.day,
			   mv.bucket10_line_cnt, 0))			PREV10
	   FROM	(SELECT max(mv.time_snapshot_date_id)		DAY
		   FROM	ISC_DBI_FM_0006_MV		mv
		  WHERE	mv.time_snapshot_date_id BETWEEN &BIS_CURRENT_EFFECTIVE_START_DATE
						     AND &BIS_CURRENT_ASOF_DATE
				)	a,
		(SELECT max(mv.time_snapshot_date_id)		DAY
		   FROM	ISC_DBI_FM_0006_MV		mv
		  WHERE	mv.time_snapshot_date_id BETWEEN &BIS_PREVIOUS_EFFECTIVE_START_DATE
						     AND &BIS_PREVIOUS_ASOF_DATE
				)	b,
		ISC_DBI_FM_0006_MV	mv
	  WHERE mv.time_snapshot_date_id IN (a.day, b.day)
		AND mv.item_cat_flag = :ISC_ITEM_CAT_FLAG
		AND mv.customer_flag = :ISC_CUSTOMER_FLAG'
		||l_inv_org_where||l_inv_cat_where||l_item_where||l_customer_where||'),';

l_sql_stmt := '
 SELECT	bucket				ISC_ATTRIBUTE_2,
	bucket_type			ISC_ATTRIBUTE_3,
	line_cnt			ISC_MEASURE_2,
	prev_line_cnt			ISC_MEASURE_3,
 	(line_cnt - prev_line_cnt)
	  / decode( prev_line_cnt,0,
		    NULL,
		    abs(prev_line_cnt)) * 100
					ISC_MEASURE_4, -- Past Due Schedule Line Change
	line_cnt
	  / decode ( sum(line_cnt) over (),0,
		     NULL,
		     sum(line_cnt) over ()) * 100
					ISC_MEASURE_5, -- Percent of Total
	sum(line_cnt) over ()		ISC_MEASURE_6, -- Grand Total for Past Due Schedule Lines
 	(sum(line_cnt) over () - sum(prev_line_cnt) over())
	  / decode( sum(prev_line_cnt) over (),0,
		    NULL,
		    abs(sum(prev_line_cnt) over ())) * 100
					ISC_MEASURE_7, -- Grand Total Past Due Schedule Line Change
	sum(line_cnt) over ()
	  / decode ( sum(line_cnt) over (),0,
		     NULL,
		     sum(line_cnt) over ()) * 100
					ISC_MEASURE_1, -- Grand Total for Percent of Total
	null				CURRENCY -- obsolete from DBI 5.0
   FROM	( SELECT decode(rownum,
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
			null)			LINE_CNT,
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
			null)			PREV_LINE_CNT
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
ORDER BY BUCKET_TYPE';

    ELSE l_sql_stmt := '
 SELECT	0		ISC_ATTRIBUTE_2,
	0		ISC_ATTRIBUTE_3,
	0		ISC_MEASURE_1,
	0		ISC_MEASURE_2,
	0		ISC_MEASURE_3,
	0		ISC_MEASURE_4,
	0		ISC_MEASURE_5,
	0		ISC_MEASURE_6,
	0		ISC_MEASURE_7,
	0		ISC_MEASURE_8,
	0		CURRENCY
   FROM	dual
  WHERE 1 = 2 /* No snapshot has been taken during this period*/';
  END IF;

  x_custom_sql := l_sql_stmt;

  l_custom_rec.attribute_name := ':ISC_ITEM_CAT_FLAG';
  l_custom_rec.attribute_value := to_char(l_item_cat_flag);
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_CUSTOMER_FLAG';
  l_custom_rec.attribute_value := to_char(l_customer_flag);
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R1';
  l_custom_rec.attribute_value := l_bucket_rec.range1_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R2';
  l_custom_rec.attribute_value := l_bucket_rec.range2_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R3';
  l_custom_rec.attribute_value := l_bucket_rec.range3_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R4';
  l_custom_rec.attribute_value := l_bucket_rec.range4_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(6) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R5';
  l_custom_rec.attribute_value := l_bucket_rec.range5_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(7) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R6';
  l_custom_rec.attribute_value := l_bucket_rec.range6_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(8) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R7';
  l_custom_rec.attribute_value := l_bucket_rec.range7_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(9) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R8';
  l_custom_rec.attribute_value := l_bucket_rec.range8_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(10) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R9';
  l_custom_rec.attribute_value := l_bucket_rec.range9_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(11) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_R10';
  l_custom_rec.attribute_value := l_bucket_rec.range10_name;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  x_custom_output.extend;
  x_custom_output(12) := l_custom_rec;

END Get_Sql;

END ISC_DBI_PAST_DUE_PKG ;


/
