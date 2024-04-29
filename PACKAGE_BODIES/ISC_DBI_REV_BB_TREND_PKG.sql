--------------------------------------------------------
--  DDL for Package Body ISC_DBI_REV_BB_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_REV_BB_TREND_PKG" AS
/* $Header: ISCRGBCB.pls 120.1 2006/06/26 07:13:26 abhdixi noship $ */

PROCEDURE GET_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,x_custom_sql OUT NOCOPY VARCHAR2,
	x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt 		VARCHAR2(32000);
  l_period_type		VARCHAR2(32000);
  l_rev_book		VARCHAR2(32000);
  l_sgid 		VARCHAR2(32000);
  l_sg_where     	VARCHAR2(32000);
  l_prod_cat		VARCHAR2(32000);
  l_prod_cat_from	VARCHAR2(32000);
  l_prod_cat_where	VARCHAR2(32000);
  l_cust		VARCHAR2(32000);
  l_cust_where		VARCHAR2(32000);
  l_class		VARCHAR2(32000);
  l_class_where		VARCHAR2(32000);
  l_sg_sg		NUMBER;
  l_sg_res		NUMBER;
  l_item_cat_flag	NUMBER;
  l_cust_flag		NUMBER; -- 0 for customer, 1 for cust class, 3 for all
  l_flags		VARCHAR2(32000);
  l_mv			VARCHAR2(100);
  l_curr		VARCHAR2(10000);
  l_curr_suffix		VARCHAR2(120);
  l_invalid_curr	BOOLEAN;
  l_custom_rec 		BIS_QUERY_ATTRIBUTES;


BEGIN

  l_invalid_curr := FALSE;


  FOR i IN 1..p_param.COUNT
  LOOP

    IF (p_param(i).parameter_name = 'PERIOD_TYPE')
      THEN l_period_type := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ORGANIZATION+JTF_ORG_SALES_GROUP') THEN
      l_sgid := p_param(i).parameter_id;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_VBH_CAT') THEN
       l_prod_cat := p_param(i).parameter_id;
    END IF;

    IF(p_param(i).parameter_name = 'CUSTOMER+FII_CUSTOMERS') THEN
       l_cust := p_param(i).parameter_id;
    END IF;

    IF(p_param(i).parameter_name = 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS') THEN
       l_class :=  p_param(i).parameter_id;
    END IF;

    IF (p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES')
      THEN l_curr := p_param(i).parameter_id;
    END IF;

  END LOOP;

  IF (l_curr = '''FII_GLOBAL1''')
    THEN l_curr_suffix := 'g';
  ELSIF (l_curr = '''FII_GLOBAL2''')
    THEN l_curr_suffix := 'g1';
  ELSE
    l_invalid_curr := TRUE;
  END IF;

  IF l_period_type = 'FII_TIME_ENT_YEAR'
    THEN l_rev_book := 'booked_rev_yr_'||l_curr_suffix;
  ELSIF l_period_type = 'FII_TIME_ENT_QTR'
    THEN l_rev_book := 'booked_rev_qr_'||l_curr_suffix;
  ELSIF l_period_type = 'FII_TIME_ENT_PERIOD'
    THEN l_rev_book := 'booked_rev_pe_'||l_curr_suffix;
  ELSE -- l_period_type = 'FII_TIME_WEEK'
    l_rev_book := 'booked_rev_wk_'||l_curr_suffix;
  END IF;

  l_sg_sg   := to_number(replace(substr(l_sgid,instr(l_sgid,'.') + 1),''''));
  l_sg_res  := to_number(replace(substr(l_sgid,1,instr(l_sgid,'.') - 1),''''));

  IF (l_sg_res IS NULL) -- when a sales group is chosen
    THEN
	l_sg_where := '
		AND f.sales_grp_id = (&ORGANIZATION+JTF_ORG_SALES_GROUP)
		AND f.resource_id IS NULL';
  ELSE -- when the LOV parameter is a SRep (no need to go through the SG hierarchy MV
	l_sg_where := '
		AND f.sales_grp_id = :ISC_SG
		AND f.resource_id = :ISC_RES';
  END IF;

  IF (l_cust IS NULL)
    THEN
    l_cust_where := '';
      IF (l_class IS NULL)
        THEN l_cust_flag := 3; -- all
        ELSE l_cust_flag := 1; -- customer classification
      END IF;
    ELSE
      l_cust_where := '
		AND f.customer_id in (&CUSTOMER+FII_CUSTOMERS)';
      l_cust_flag := 0; -- customer
  END IF;

  IF (l_class IS NULL) THEN
    l_class_where:='';
  ELSE
    l_class_where :='
		AND f.class_code in (&FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS)';
  END IF;

  IF (l_cust IS NULL AND l_class IS NULL) THEN -- use double rollup without cust
    l_flags := '';
    l_mv := 'ISC_DBI_SCR_002_MV';
    l_prod_cat_from := ''; -- do not need to join to denorm table
    IF (l_prod_cat IS NULL) THEN
      l_prod_cat_where :='
		AND f.cat_top_node_flag = ''Y''';
    ELSE -- view by sales group, prod.cat selected
      l_prod_cat_where :='
		AND f.item_category_id IN (&ITEM+ENI_ITEM_VBH_CAT)';
    END IF;

  ELSE -- use single rollup with customer dimension
    l_flags := '
		AND f.item_cat_flag = :ISC_ITEM_CAT_FLAG
		AND f.customer_flag = :ISC_CUST';
    l_mv := 'ISC_DBI_SCR_001_MV';
    IF (l_prod_cat IS NULL)
      THEN l_prod_cat_from := '';
	 l_prod_cat_where := '';
      ELSE
        l_prod_cat_from := ',
		ENI_DENORM_HIERARCHIES		eni_cat,
		MTL_DEFAULT_CATEGORY_SETS	mdcs';
        l_prod_cat_where := '
	    AND f.item_category_id = eni_cat.child_id
	    AND eni_cat.parent_id IN (&ITEM+ENI_ITEM_VBH_CAT)
	    AND	eni_cat.dbi_flag = ''Y''
	    AND	eni_cat.object_type = ''CATEGORY_SET''
	    AND eni_cat.object_id = mdcs.category_set_id
	    AND	mdcs.functional_area_id = 11';
    END IF;
  END IF;

  IF (l_prod_cat IS NULL)
    THEN l_item_cat_flag := 1; -- All
    ELSE l_item_cat_flag := 0; -- Product Category
  END IF;


  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  IF (l_invalid_curr)
    THEN l_stmt := '
/* Unsupported currency */
SELECT	0	ISC_MEASURE_2,
	0 	ISC_MEASURE_1,
	0 	ISC_MEASURE_3,
	0 	ISC_MEASURE_8,
	0 	ISC_MEASURE_7,
	0 	ISC_MEASURE_9,
	0 	ISC_MEASURE_10,
	0 	ISC_MEASURE_11,
	0 	ISC_MEASURE_12,
	0 	ISC_MEASURE_5,
	0 	ISC_MEASURE_4,
	0 	ISC_MEASURE_6

  FROM	dual
 WHERE	1 = 2';

  ELSE

  l_stmt := '
 SELECT	fii.name					VIEWBY,
	nvl(s.p_net_book, 0)				ISC_MEASURE_2, -- Prior (Net Booked)
	nvl(s.c_net_book, 0)				ISC_MEASURE_1, -- Net Booked
	(s.c_net_book - s.p_net_book)
	  / decode(s.p_net_book, 0, NULL,
		   abs(s.p_net_book)) * 100		ISC_MEASURE_3, -- Change (Net Booked)
	nvl(s.p_rev_rec, 0)				ISC_MEASURE_8, -- Prior (Revenue)
	nvl(s.c_rev_rec, 0)				ISC_MEASURE_7, -- Revenue
	(s.c_rev_rec - s.p_rev_rec)
	  / decode(s.p_rev_rec, 0, NULL,
		   abs(s.p_rev_rec)) * 100		ISC_MEASURE_9, -- Change (Revenue)
	nvl(s.p_rev_book, 0)				ISC_MEASURE_10, -- Prior (Rev Booked this Per)
	nvl(s.c_rev_book, 0)				ISC_MEASURE_11, -- Revenue Booked this Period
	(s.c_rev_book - s.p_rev_book)
	  / decode(s.p_rev_book, 0, null,
		   abs(s.p_rev_book)) *100		ISC_MEASURE_12, -- Change (Rev Booked this Per)
	nvl(s.p_rev_backlog, 0)				ISC_MEASURE_5, -- Prior (Revenue Backlog)
	nvl(s.c_rev_backlog, 0)				ISC_MEASURE_4, -- Revenue Backlog
	(s.c_rev_backlog - s.p_rev_backlog)
	  / decode(s.p_rev_backlog, 0, NULL,
		   abs(s.p_rev_backlog)) * 100		ISC_MEASURE_6 /* Change (Revenue Backlog) */

   FROM	(SELECT	start_date					START_DATE,
		sum(c_book_xtd)					C_NET_BOOK,
		sum(p_book_xtd)					P_NET_BOOK,
		sum(c_backlog) + sum(c_defer_rev)		C_REV_BACKLOG,
		sum(p_backlog) + sum(p_defer_rev)		P_REV_BACKLOG,
		sum(c_rev_rec_xtd)				C_REV_REC,
		sum(p_rev_rec_xtd)				P_REV_REC,
		sum(c_rev_book_xtd)				C_REV_BOOK,
		sum(p_rev_book_xtd)				P_REV_BOOK
	   FROM /* Compute XTD components */
	(SELECT	dates.start_date			START_DATE,
		decode(dates.period, ''C'',
			nvl(net_booked_amt_'||l_curr_suffix||', 0), 0)	C_BOOK_XTD,
		decode(dates.period, ''P'',
			nvl(net_booked_amt_'||l_curr_suffix||', 0), 0)	P_BOOK_XTD,
		decode(dates.period, ''C'',
			nvl(recognized_amt_'||l_curr_suffix||', 0), 0)	C_REV_REC_XTD,
		decode(dates.period, ''P'',
			nvl(recognized_amt_'||l_curr_suffix||', 0), 0)	P_REV_REC_XTD,
		decode(dates.period, ''C'',
			nvl('||l_rev_book||', 0), 0)	C_REV_BOOK_XTD,
		decode(dates.period, ''P'',
			nvl('||l_rev_book||', 0), 0)	P_REV_BOOK_XTD,
		0					C_BACKLOG,
		0					P_BACKLOG,
		0					C_DEFER_REV,
		0					P_DEFER_REV
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
		'||l_mv||'  				f,
		FII_TIME_RPT_STRUCT_V				cal'
		||l_prod_cat_from||'
	  WHERE	cal.report_date = dates.report_date
	    AND f.time_id = cal.time_id
	    AND f.period_type_id = cal.period_type_id
	    AND bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id'
		||l_flags
		||l_sg_where||l_prod_cat_where||l_cust_where||l_class_where||'
	UNION ALL /* Compute ITD components */
	 SELECT	dates.start_date			START_DATE,
		0					C_BOOK_XTD,
		0					P_BOOK_XTD,
		0					C_REV_REC_XTD,
		0					P_REV_REC_XTD,
		0					C_REV_BOOK_XTD,
		0					P_REV_BOOK_XTD,
		decode(dates.period, ''C'',
			nvl(backlog_amt_'||l_curr_suffix||', 0), 0)	C_BACKLOG,
		decode(dates.period, ''P'',
			nvl(backlog_amt_'||l_curr_suffix||', 0), 0)	P_BACKLOG,
		decode(dates.period, ''C'',
			nvl(deferred_amt_'||l_curr_suffix||', 0), 0)	C_DEFER_REV,
		decode(dates.period, ''P'',
			nvl(deferred_amt_'||l_curr_suffix||', 0), 0)	P_DEFER_REV
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
		'||l_mv||'  				f,
		FII_TIME_RPT_STRUCT_V				cal'
		||l_prod_cat_from||'
	  WHERE	cal.report_date = dates.report_date
	    AND f.time_id = cal.time_id
	    AND f.period_type_id = cal.period_type_id
	    AND bitand(cal.record_type_id, 1143) = cal.record_type_id'
		||l_flags
		||l_sg_where||l_prod_cat_where||l_cust_where||l_class_where||')
	GROUP BY start_date)		s,
	'||l_period_type||'		fii
  WHERE	fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
			   AND &BIS_CURRENT_ASOF_DATE
    AND	fii.start_date = s.start_date(+)
ORDER BY fii.start_date';

  END IF;

  x_custom_sql := l_stmt;

  l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.View_By_Value;
  l_custom_rec.attribute_value := 'TIME+'||l_period_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.View_By_Type;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_CUST';
  l_custom_rec.attribute_value := l_cust_flag;
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_SG';
  l_custom_rec.attribute_value := to_char(l_sg_sg);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_RES';
  l_custom_rec.attribute_value := to_char(l_sg_res);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.extend;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_ITEM_CAT_FLAG';
  l_custom_rec.attribute_value := to_char(l_item_cat_flag);
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
  x_custom_output.extend;
  x_custom_output(5) := l_custom_rec;

END get_sql;

END ISC_DBI_REV_BB_TREND_PKG;

/
