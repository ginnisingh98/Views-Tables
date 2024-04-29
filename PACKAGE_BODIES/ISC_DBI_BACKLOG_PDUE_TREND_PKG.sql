--------------------------------------------------------
--  DDL for Package Body ISC_DBI_BACKLOG_PDUE_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_BACKLOG_PDUE_TREND_PKG" AS
/* $Header: ISCRGA3B.pls 120.0 2005/05/25 17:45:07 appldev noship $ */



PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt			VARCHAR2(32000);
  l_mv1				VARCHAR2(100);
  l_mv2				VARCHAR2(100);
  l_mv_book			VARCHAR2(100);
  l_mv_fulf			VARCHAR2(100);
  l_flags_where			VARCHAR2(1000);
  l_flags_where2		VARCHAR2(1000);
  l_period_type			VARCHAR2(10000);
  l_inv_org			VARCHAR2(10000);
  l_inv_org_where		VARCHAR2(10000);
  l_prod			VARCHAR2(10000);
  l_prod_where			VARCHAR2(10000);
  l_prod_cat			VARCHAR2(10000);
  l_prod_cat_from		VARCHAR2(10000);
  l_prod_cat_where		VARCHAR2(10000);
  l_cust			VARCHAR2(10000);
  l_cust_where			VARCHAR2(10000);
  l_curr			VARCHAR2(10000);
  l_curr_g			VARCHAR2(15);
  l_curr_g1			VARCHAR2(15);
  l_curr_suffix			VARCHAR2(120);
  l_item_cat_flag		NUMBER;
  l_cust_flag			NUMBER;

  l_custom_rec			BIS_QUERY_ATTRIBUTES;

BEGIN

  l_curr_g			:= '''FII_GLOBAL1''';
  l_curr_g1			:= '''FII_GLOBAL2''';

  FOR i IN 1..p_param.COUNT
  LOOP
    IF (p_param(i).parameter_name = 'PERIOD_TYPE')
      THEN l_period_type := p_param(i).parameter_value;
    END IF;

    IF (p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES')
      THEN l_curr := p_param(i).parameter_id;
    END IF;

    IF (p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION')
      THEN l_inv_org := p_param(i).parameter_value;
    END IF;

    IF (p_param(i).parameter_name = 'ITEM+ENI_ITEM_VBH_CAT')
      THEN l_prod_cat := p_param(i).parameter_value;
    END IF;

    IF (p_param(i).parameter_name = 'ITEM+ENI_ITEM_ORG')
      THEN l_prod := p_param(i).parameter_value;
    END IF;

    IF (p_param(i).parameter_name = 'CUSTOMER+FII_CUSTOMERS')
      THEN l_cust := p_param(i).parameter_value;
    END IF;
  END LOOP;

  IF (l_curr = l_curr_g)
    THEN l_curr_suffix := 'g';
  ELSIF (l_curr = l_curr_g1)
    THEN l_curr_suffix :='g1';
    ELSE l_curr_suffix := 'f';
  END IF;

  IF (l_inv_org IS NULL OR l_inv_org = 'All')
    THEN l_inv_org_where := '
	WHERE (EXISTS
		(SELECT 1
		FROM org_access o
		WHERE o.responsibility_id = fnd_global.resp_id
		AND o.resp_application_id = fnd_global.resp_appl_id
		AND o.organization_id = inv_org)
	OR EXISTS
		(SELECT 1
		FROM mtl_parameters org
		WHERE org.organization_id = inv_org
		AND NOT EXISTS
			(SELECT 1
			FROM org_access ora
			WHERE org.organization_id = ora.organization_id)))';
    ELSE l_inv_org_where := '
	WHERE inv_org = &ORGANIZATION+ORGANIZATION';
  END IF;

  IF (l_prod_cat IS NULL OR l_prod_cat = 'All')
    THEN
      l_prod_cat_from := '';
      l_prod_cat_where := '';
    ELSE
      IF (l_prod IS NULL OR l_prod = 'All')
        THEN
	  l_prod_cat_from := ',
		ENI_DENORM_HIERARCHIES		eni_cat,
		MTL_DEFAULT_CATEGORY_SETS	mdcs';
	  l_prod_cat_where := '
	    AND fact.item_category_id = eni_cat.child_id
	    AND eni_cat.parent_id IN (&ITEM+ENI_ITEM_VBH_CAT)
	    AND	eni_cat.dbi_flag = ''Y''
	    AND eni_cat.object_type = ''CATEGORY_SET''
	    AND eni_cat.object_id = mdcs.category_set_id
	    AND	mdcs.functional_area_id = 11';
        ELSE
	  l_prod_cat_from := '';
	  l_prod_cat_where := '';
      END IF;
  END IF;

  IF (l_prod IS NULL OR l_prod = 'All')
    THEN l_prod_where := '';
    ELSE l_prod_where := '
	    AND fact.item_id IN (&ITEM+ENI_ITEM_ORG)';
  END IF;

  IF (l_cust IS NULL OR l_cust = 'All')
    THEN
      l_cust_where := '';
      l_cust_flag := 1;
    ELSE
      l_cust_where := '
	    AND fact.customer_id in (&CUSTOMER+FII_CUSTOMERS)';
      l_cust_flag := 0;
  END IF;

  IF (l_prod IS NULL OR l_prod = 'All')
    THEN
      IF (l_prod_cat IS NULL OR l_prod_cat = 'All')
        THEN l_item_cat_flag := 3; -- category
        ELSE l_item_cat_flag := 1; -- all
      END IF;
    ELSE
      l_item_cat_flag := 0; -- product
  END IF;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  IF ((l_prod IS NULL OR l_prod = 'All') AND
      (l_cust IS NULL OR l_cust = 'All'))
    THEN
        IF (l_prod_cat IS NULL OR l_prod_cat = '' OR l_prod_cat = 'All')
	  THEN
	    l_prod_cat_from := '';
	    l_prod_cat_where := '
	    	    AND	fact.top_node_flag = ''Y''';
	  ELSE
	    l_prod_cat_from := '';
	    l_prod_cat_where := '
	    	    AND fact.parent_id = &ITEM+ENI_ITEM_VBH_CAT';
        END IF;
	l_mv1 := 'ISC_DBI_CFM_001_MV';
	l_mv_book := 'ISC_DBI_CFM_009_MV';
	l_mv_fulf := 'ISC_DBI_CFM_011_MV';
	l_mv2 := 'ISC_DBI_CFM_012_MV';
	l_flags_where := '';
	l_flags_where2 := '
	    AND	fact.inv_org_flag = 0';
    ELSE
	l_mv1 := 'ISC_DBI_CFM_010_MV';
	l_mv_book := 'ISC_DBI_CFM_000_MV';
	l_mv_fulf := 'ISC_DBI_CFM_002_MV';
	l_mv2 := 'ISC_DBI_CFM_008_MV';
	l_flags_where := '
	    AND	fact.item_cat_flag = :ISC_ITEM_CAT_FLAG
	    AND fact.customer_flag = :ISC_CUST_FLAG';
	l_flags_where2 := '
	    AND	fact.item_cat_flag = :ISC_ITEM_CAT_FLAG
	    AND fact.customer_flag = :ISC_CUST_FLAG';
  END IF;

  l_stmt := '
 SELECT	fii.name					VIEWBY,
	s.prev_bklg_value				ISC_MEASURE_1, -- bklg prior
	s.curr_bklg_value				ISC_MEASURE_2, -- bklg
	(s.curr_bklg_value - s.prev_bklg_value)
	  / decode(s.prev_bklg_value, 0, NULL,
		   abs(s.prev_bklg_value)) * 100	ISC_MEASURE_3, -- bklg change
	s.prev_pdue_value				ISC_MEASURE_4, -- pdue prior
	s.curr_pdue_value				ISC_MEASURE_5, -- pdue
	(s.curr_pdue_value - s.prev_pdue_value)
	  / decode(s.prev_pdue_value, 0, NULL,
		   abs(s.prev_pdue_value)) * 100	ISC_MEASURE_6  -- pdue change
   FROM	(SELECT	start_date			START_DATE,
		sum(c_y_bklg) + sum(c_book_ytd)
		  - sum(c_fulf_ytd)		CURR_BKLG_VALUE,
		sum(p_y_bklg) + sum(p_book_ytd)
		  - sum(p_fulf_ytd)		PREV_BKLG_VALUE,
		sum(curr_pdue_value)		CURR_PDUE_VALUE,
		sum(prev_pdue_value)		PREV_PDUE_VALUE
	   FROM /* Compute year backlog balance */
	(SELECT	dates.start_date		START_DATE,
		fact.inv_org_id			INV_ORG,
		decode(dates.period, ''C'',
		       fact.bklg_amt_'||l_curr_suffix||', 0)	C_Y_BKLG,
		decode(dates.period, ''P'',
		       fact.bklg_amt_'||l_curr_suffix||', 0)	P_Y_BKLG,
		0				C_BOOK_YTD,
		0				P_BOOK_YTD,
		0				C_FULF_YTD,
		0				P_FULF_YTD,
		NULL				CURR_PDUE_VALUE,
		NULL				PREV_PDUE_VALUE
	   FROM	(SELECT	fii.start_date					START_DATE,
			''C''						PERIOD,
			least(fii.end_date, &BIS_CURRENT_ASOF_DATE)	REPORT_DATE
		   FROM	'||l_period_type||'	fii
		  WHERE	fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
					   AND &BIS_CURRENT_ASOF_DATE
		UNION ALL
		 SELECT	p2.start_date					START_DATE,
			''P''						PERIOD,
			p1.report_date					REPORT_DATE
		   FROM	(SELECT	least(fii.end_date, &BIS_PREVIOUS_ASOF_DATE)	REPORT_DATE,
				rownum						ID
			   FROM	'||l_period_type||'	fii
			  WHERE	fii.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE
						   AND &BIS_PREVIOUS_ASOF_DATE
			  ORDER BY fii.start_date DESC) p1,
			(SELECT	fii.start_date					START_DATE,
				rownum						ID
			   FROM	'||l_period_type||'	fii
			  WHERE	fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
						   AND &BIS_CURRENT_ASOF_DATE
			  ORDER BY fii.start_date DESC) p2
		  WHERE	p1.id(+) = p2.id)			dates,
		'||l_mv1||' 				fact,
		FII_TIME_DAY					day'||l_prod_cat_from||'
	  WHERE	day.report_date = dates.report_date
	    AND day.ent_year_start_date = fact.time_snapshot_date_id'
	    	||l_flags_where
		||l_prod_cat_where
		||l_prod_where
		||l_cust_where||'
	UNION ALL /* Computer YTD net Booking */
	 SELECT	dates.start_date		START_DATE,
		fact.inv_org_id			INV_ORG,
		0				C_Y_BKLG,
		0				P_Y_BKLG,
		decode(dates.period, ''C'',
		       fact.booked_amt2_'||l_curr_suffix||', 0)	C_BOOK_YTD,
		decode(dates.period, ''P'',
		       fact.booked_amt2_'||l_curr_suffix||', 0)	P_BOOK_YTD,
		0				C_FULF_YTD,
		0				P_FULF_YTD,
		NULL				CURR_PDUE_VALUE,
		NULL				PREV_PDUE_VALUE
	   FROM	(SELECT	fii.start_date					START_DATE,
			''C''						PERIOD,
			least(fii.end_date, &BIS_CURRENT_ASOF_DATE)	REPORT_DATE
		   FROM	'||l_period_type||'	fii
		  WHERE	fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
					   AND &BIS_CURRENT_ASOF_DATE
		UNION ALL
		 SELECT	p2.start_date					START_DATE,
			''P''						PERIOD,
			p1.report_date					REPORT_DATE
		   FROM	(SELECT	least(fii.end_date, &BIS_PREVIOUS_ASOF_DATE)	REPORT_DATE,
				rownum						ID
			   FROM	'||l_period_type||'	fii
			  WHERE	fii.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE
						   AND &BIS_PREVIOUS_ASOF_DATE
			  ORDER BY fii.start_date DESC) p1,
			(SELECT	fii.start_date					START_DATE,
				rownum						ID
			   FROM	'||l_period_type||'	fii
			  WHERE	fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
						   AND &BIS_CURRENT_ASOF_DATE
			  ORDER BY fii.start_date DESC) p2
		  WHERE	p1.id(+) = p2.id)			dates,
		'||l_mv_book||' 			fact,
		FII_TIME_RPT_STRUCT_V				cal'||l_prod_cat_from||'
	  WHERE	cal.report_date = dates.report_date
	    AND fact.time_id = cal.time_id
	    AND fact.period_type_id = cal.period_type_id
	    AND bitand(cal.record_type_id, 119) = cal.record_type_id'
	    	||l_flags_where2
		||l_prod_cat_where
		||l_prod_where
		||l_cust_where||'
	UNION ALL /* Computer YTD net fulfillment */
	 SELECT	dates.start_date		START_DATE,
		fact.inv_org_id			INV_ORG,
		0				C_Y_BKLG,
		0				P_Y_BKLG,
		0				C_BOOK_YTD,
		0				P_BOOK_YTD,
		decode(dates.period, ''C'',
		       fact.booked_amt_'||l_curr_suffix||', 0)	C_FULF_YTD,
		decode(dates.period, ''P'',
		       fact.booked_amt_'||l_curr_suffix||', 0)	P_FULF_YTD,
		NULL				CURR_PDUE_VALUE,
		NULL				PREV_PDUE_VALUE
	   FROM	(SELECT	fii.start_date					START_DATE,
			''C''						PERIOD,
			least(fii.end_date, &BIS_CURRENT_ASOF_DATE)	REPORT_DATE
		   FROM	'||l_period_type||'	fii
		  WHERE	fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
					   AND &BIS_CURRENT_ASOF_DATE
		UNION ALL
		 SELECT	p2.start_date					START_DATE,
			''P''						PERIOD,
			p1.report_date					REPORT_DATE
		   FROM	(SELECT	least(fii.end_date, &BIS_PREVIOUS_ASOF_DATE)	REPORT_DATE,
				rownum						ID
			   FROM	'||l_period_type||'	fii
			  WHERE	fii.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE
						   AND &BIS_PREVIOUS_ASOF_DATE
			  ORDER BY fii.start_date DESC) p1,
			(SELECT	fii.start_date					START_DATE,
				rownum						ID
			   FROM	'||l_period_type||'	fii
			  WHERE	fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
						   AND &BIS_CURRENT_ASOF_DATE
			  ORDER BY fii.start_date DESC) p2
		  WHERE	p1.id(+) = p2.id)			dates,
		'||l_mv_fulf||' 			fact,
		FII_TIME_RPT_STRUCT_V				cal'||l_prod_cat_from||'
	  WHERE	cal.report_date = dates.report_date
	    AND fact.time_id = cal.time_id
	    AND fact.period_type_id = cal.period_type_id
	    AND bitand(cal.record_type_id, 119) = cal.record_type_id'
		||l_flags_where2
		||l_prod_cat_where
		||l_prod_where
		||l_cust_where||'
	UNION ALL
	 SELECT	dates.start_date		START_DATE,
		fact.inv_org_id			INV_ORG,
		0				C_Y_BKLG,
		0				P_Y_BKLG,
		0				C_BOOK_YTD,
		0				P_BOOK_YTD,
		0				C_FULF_YTD,
		0				P_FULF_YTD,
		decode(fact.time_snapshot_date_id, dates.curr_day,
		       fact.pdue_amt_'||l_curr_suffix||', NULL)	CURR_PDUE_VALUE,
		decode(fact.time_snapshot_date_id, dates.prev_day,
		       fact.pdue_amt_'||l_curr_suffix||', NULL)	PREV_PDUE_VALUE
	   FROM	(SELECT	curr.start_date	START_DATE,
			curr.day	CURR_DAY,
			prev.day	PREV_DAY
		   FROM	(SELECT start_date,
				day,
				rownum	ID
			   FROM
			(SELECT	fii.start_date					START_DATE,
				max(fact.time_snapshot_date_id)			DAY
			   FROM	'||l_period_type||'		fii,
				'||l_mv2||'		fact
			  WHERE	fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
						   AND &BIS_CURRENT_ASOF_DATE
			    AND	fact.time_snapshot_date_id (+) >= fii.start_date
			    AND	fact.time_snapshot_date_id (+) <= fii.end_date
			    AND	fact.time_snapshot_date_id (+) <= &BIS_CURRENT_ASOF_DATE
			GROUP BY fii.start_date)
			ORDER BY start_date DESC)		curr,
			(SELECT start_date,
				day,
				rownum	ID
			   FROM
			(SELECT	fii.start_date					START_DATE,
				max(fact.time_snapshot_date_id)			DAY
			   FROM	'||l_period_type||'		fii,
				'||l_mv2||'		fact
			  WHERE	fii.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE
						   AND &BIS_PREVIOUS_ASOF_DATE
			    AND	fact.time_snapshot_date_id (+) >= fii.start_date
			    AND	fact.time_snapshot_date_id (+) <= fii.end_date
			    AND	fact.time_snapshot_date_id (+) <= &BIS_PREVIOUS_ASOF_DATE
			GROUP BY fii.start_date)
			ORDER BY start_date DESC)		prev
		  WHERE	curr.id = prev.id(+))			dates,
		'||l_mv2||' 				fact'||l_prod_cat_from||'
	  WHERE	fact.time_snapshot_date_id IN (dates.curr_day, dates.prev_day)
	    AND	fact.late_schedule_flag = 1'
	    	||l_flags_where
		||l_prod_cat_where
		||l_prod_where
		||l_cust_where||')'
	||l_inv_org_where||'
	GROUP BY start_date)		s,
	'||l_period_type||'		fii
  WHERE	fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
			   AND &BIS_CURRENT_ASOF_DATE
    AND	fii.start_date = s.start_date(+)
ORDER BY fii.start_date';

  x_custom_sql := l_stmt;

  l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.View_By_Value;
  l_custom_rec.attribute_value := 'TIME+'||l_period_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.View_By_Type;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_ITEM_CAT_FLAG';
  l_custom_rec.attribute_value := to_char(l_item_cat_flag);
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.Bind_Type;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.Integer_Bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_CUST_FLAG';
  l_custom_rec.attribute_value := to_char(l_cust_flag);
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

END Get_Sql;

END ISC_DBI_BACKLOG_PDUE_TREND_PKG;

/
