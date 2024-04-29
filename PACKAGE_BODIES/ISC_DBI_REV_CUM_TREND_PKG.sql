--------------------------------------------------------
--  DDL for Package Body ISC_DBI_REV_CUM_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_REV_CUM_TREND_PKG" AS
/* $Header: ISCRGBNB.pls 120.2 2006/06/26 07:05:23 abhdixi noship $ */

PROCEDURE GET_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,x_custom_sql OUT NOCOPY VARCHAR2,
	x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt 		VARCHAR2(32000);
  l_period_type		VARCHAR2(32000);
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

  l_as_of_date		DATE;
  l_prev_asof		DATE;
  l_adjust1		VARCHAR2(100);
  l_adjust2		VARCHAR2(100);
  l_id			VARCHAR2(200);	-- l_id and l_id2 are parts of WHERE clause,
  l_id2			VARCHAR2(200);	--   through which we restrict the date
  l_day_id1		NUMBER;	 -- l_day_id1 and l_day_id2 are used to store day-ids
  l_day_id2		NUMBER;	 --   for start date and end date of the period
  l_curr_start 		DATE;
  l_curr_end 		DATE;
  l_prior_start   	DATE;
  l_prior_end   	DATE;
  l_temp		DATE;

BEGIN

  fii_gl_util_pkg.reset_globals;
  fii_gl_util_pkg.get_parameters(p_param);

  l_invalid_curr := FALSE;

  FOR i IN 1..p_param.COUNT
  LOOP

    IF(p_param(i).parameter_name = 'AS_OF_DATE')
      THEN l_as_of_date := to_date(p_param(i).parameter_value, 'DD-MM-YYYY');
    END IF;

    IF(p_param(i).parameter_name = 'BIS_PREVIOUS_ASOF_DATE')
      THEN l_prev_asof := to_date(p_param(i).parameter_value, 'DD-MM-YYYY');
    END IF;

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

  IF l_period_type = 'FII_TIME_ENT_YEAR' THEN
    l_adjust1     := NULL;
    l_adjust2     := NULL;
    l_curr_start  := fii_time_api.ent_cyr_start(l_as_of_date);
    l_curr_end 	  := fii_time_api.ent_cyr_end(l_as_of_date);
    l_prior_start := fii_time_api.ent_cyr_start(l_prev_asof);
    l_prior_end   := fii_time_api.ent_cyr_end(l_prev_asof);
    l_temp        := fii_time_api.ent_cper_end(l_as_of_date);

  ELSIF l_period_type = 'FII_TIME_ENT_QTR' THEN
    l_adjust1     := ':ISC_CURR_START-:ISC_CURR_END';
    l_adjust2     := ':ISC_PRIOR_START-:ISC_PRIOR_END';
    l_curr_start  := fii_time_api.ent_cqtr_start(l_as_of_date);
    l_curr_end    := fii_time_api.ent_cqtr_end(l_as_of_date);
    l_prior_start := fii_time_api.ent_cqtr_start(l_prev_asof);
    l_prior_end   := fii_time_api.ent_cqtr_end(l_prev_asof);
    l_temp        := NULL;

  ELSIF l_period_type = 'FII_TIME_ENT_PERIOD' THEN
    l_adjust1     := '1';
    l_adjust2     := '1';
    l_curr_start  := fii_time_api.ent_cper_start(l_as_of_date);
    l_curr_end    := fii_time_api.ent_cper_end(l_as_of_date);
    l_prior_start := fii_time_api.ent_cper_start(l_prev_asof);
    l_prior_end   := fii_time_api.ent_cper_end(l_prev_asof);
    l_temp        := NULL;

  ELSE -- l_period_type = 'FII_TIME_WEEK'
    l_adjust1     := '1';
    l_adjust2     := '1';
    l_curr_start  := fii_time_api.cwk_start(l_as_of_date);
    l_curr_end    := fii_time_api.cwk_end(l_as_of_date);
    l_prior_start := fii_time_api.cwk_start(l_prev_asof);
    l_prior_end   := fii_time_api.cwk_end(l_prev_asof);
    l_temp        := NULL;

  END IF;

  SELECT report_date_julian INTO l_day_id1 FROM fii_time_day WHERE report_date = l_curr_start;
  SELECT report_date_julian INTO l_day_id2 FROM fii_time_day WHERE report_date = l_curr_end;
  l_id := '(g.report_date_julian  between '||l_day_id1|| ' and ' ||l_day_id2 ||')';

  SELECT report_date_julian INTO l_day_id1 FROM fii_time_day WHERE report_date = l_prior_start;
  SELECT report_date_julian INTO l_day_id2 FROM fii_time_day WHERE report_date = l_prior_end;
  l_id2 := '(g.report_date_julian  between '||l_day_id1|| ' and ' ||l_day_id2 ||')';

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
SELECT	0 	ISC_MEASURE_2,
	0	ISC_MEASURE_1,
	0 	ISC_MEASURE_4,
	0 	ISC_MEASURE_3

  FROM	dual
 WHERE	1 = 2';

  ELSE

/* For period type = Year:
     - 1st inner sql gives the prior year bookings & revenue
     - 2nd inner sql gives the bookings & revenue of all completed months in the current year
     - 3rd inner sql gives NULL bookings & revenue for the months ranging from
         current month to the end of current year

   For period type = Week / Month / Quarter:
     - 1st inner sql gives current period bookings & revenue
     - 2nd inner sql gives the prior period bookings & revenue
*/

IF l_period_type = 'FII_TIME_ENT_YEAR' THEN
l_stmt := '
SELECT	SUBSTR(month_name,1,3)								VIEWBY,
	SUM(P_NET_BOOK)	OVER (ORDER BY FII_EFFECTIVE_NUM ROWS UNBOUNDED PRECEDING)	ISC_MEASURE_2,
	CASE WHEN c_net_book IS NULL THEN to_number(NULL)
	     ELSE SUM(C_NET_BOOK) OVER (ORDER BY FII_EFFECTIVE_NUM ROWS UNBOUNDED PRECEDING)
	     END									ISC_MEASURE_1,
	SUM(P_REV) OVER (ORDER BY FII_EFFECTIVE_NUM ROWS UNBOUNDED PRECEDING)		ISC_MEASURE_4,
	CASE WHEN c_rev IS NULL THEN to_number(NULL)
	     ELSE SUM(C_REV) OVER (ORDER BY FII_EFFECTIVE_NUM ROWS UNBOUNDED PRECEDING)
	     END									ISC_MEASURE_3

 FROM
(SELECT	MAX(month_name)			MONTH_NAME,
	FII_EFFECTIVE_NUM		FII_EFFECTIVE_NUM,
	SUM(C_NET_BOOK)			C_NET_BOOK,
	SUM(P_NET_BOOK)			P_NET_BOOK,
	SUM(C_REV)			C_REV,
	SUM(P_REV)			P_REV
  FROM (
	SELECT	per.sequence 		FII_EFFECTIVE_NUM,
		per.name 		MONTH_NAME,
		per.ent_period_id 	ID,
   		NULL 			C_NET_BOOK,
		   (CASE WHEN per.end_date <= :ISC_PRIOR_END
			 THEN f.net_booked_amt_'||l_curr_suffix||'
			 ELSE to_number(NULL) END
		   ) 			P_NET_BOOK,
   		NULL 			C_REV,
		   (CASE WHEN per.end_date <= :ISC_PRIOR_END
			 THEN f.recognized_amt_'||l_curr_suffix||'
			 ELSE to_number(NULL) END
		   ) 			P_REV
	  FROM	FII_TIME_ENT_PERIOD   		per,
		'||l_mv||'  		f'
		||l_prod_cat_from||'
	 WHERE	per.ent_period_id = f.time_id
	   AND	per.start_date >= :ISC_PRIOR_START
	   AND	per.end_date   <= :ISC_PRIOR_END
	   AND	f.period_type_id = 32'
    		||l_flags
		||l_sg_where||l_prod_cat_where||l_cust_where||l_class_where||'
     UNION ALL
	(
	 SELECT	per.sequence 		FII_EFFECTIVE_NUM,
		per.name 		MONTH_NAME,
		per.ent_period_id 	ID,
		   (CASE WHEN per.start_date >= :ISC_CURR_START
			  AND per.end_date < &BIS_CURRENT_ASOF_DATE
                	 THEN f.net_booked_amt_'||l_curr_suffix||'
  		  	 ELSE to_number(NULL) END
		   )  			C_NET_BOOK,
		0 			P_NET_BOOK,
		   (CASE WHEN per.start_date >= :ISC_CURR_START
			  AND per.end_date < &BIS_CURRENT_ASOF_DATE
               		 THEN f.recognized_amt_'||l_curr_suffix||'
		    	 ELSE to_number(NULL) END
		   ) 			C_REV,
		0 			P_REV
  	  FROM	FII_TIME_ENT_PERIOD   		per,
		'||l_mv||'  		f'
		||l_prod_cat_from||'
	 WHERE	per.ent_period_id = f.time_id
	   AND	per.start_date >= :ISC_CURR_START
	   AND	per.end_date   < &BIS_CURRENT_ASOF_DATE
	   AND	f.period_type_id = 32'
		||l_flags
		||l_sg_where||l_prod_cat_where||l_cust_where||l_class_where||'
     UNION ALL
	 SELECT	per.sequence 		FII_EFFECTIVE_NUM,
		per.name 		MONTH_NAME,
		per.ent_period_id 	ID,
		f.net_booked_amt_'||l_curr_suffix||'	C_NET_BOOK,
		0 					P_NET_BOOK,
		f.recognized_amt_'||l_curr_suffix||'	C_REV,
		0 					P_REV
  	  FROM	FII_TIME_RPT_STRUCT_V   	cal,
		FII_TIME_ENT_PERIOD		per,
		'||l_mv||'  		f'
		||l_prod_cat_from||'
	 WHERE	cal.time_id = f.time_id
	   AND	cal.report_date between per.start_date and per.end_date
	   AND	cal.report_date = &BIS_CURRENT_ASOF_DATE
	   AND	bitand(cal.record_type_id, 23) = cal.record_type_id'
		||l_flags
		||l_sg_where||l_prod_cat_where||l_cust_where||l_class_where||'
     UNION ALL
	SELECT  per.sequence 		FII_EFFECTIVE_NUM,
		per.name 		MONTH_NAME,
		per.ent_period_id 	ID,
   		CASE WHEN per.end_date > :ISC_TEMP
		     THEN to_number(NULL)
		     ELSE 0 END		C_NET_BOOK,
		0  			P_NET_BOOK,
   		CASE WHEN per.end_date > :ISC_TEMP
		     THEN to_number(NULL)
		     ELSE 0 END		C_REV,
		0  			P_REV
	  FROM	FII_TIME_ENT_PERIOD per
         WHERE	per.start_date >= :ISC_CURR_START
	   AND	per.end_date   <= :ISC_CURR_END
	))
GROUP BY FII_EFFECTIVE_NUM
ORDER BY FII_EFFECTIVE_NUM
)';

ELSE
l_stmt := '
SELECT  days					VIEWBY,
	SUM(DECODE(SIGN(report_date - &BIS_CURRENT_ASOF_DATE),
		   1, NULL, C_NET_BOOK))	ISC_MEASURE_1,
	SUM(DECODE(SIGN(report_date - :ISC_PRIOR_END),
		   1, NULL, P_NET_BOOK)) 	ISC_MEASURE_2,
	SUM(DECODE(SIGN(report_date - &BIS_CURRENT_ASOF_DATE),
		   1, NULL, C_REV))		ISC_MEASURE_3,
	SUM(DECODE(SIGN(report_date - :ISC_PRIOR_END),
		   1, NULL, P_REV)) 		ISC_MEASURE_4
  FROM (
	SELECT	g.report_date - :ISC_CURR_START + to_number('||l_adjust1||')
						DAYS,
		report_date,
		NVL(SUM(SUM(f.c_book_xtd)) OVER
		   (ORDER BY g.report_date - :ISC_CURR_START + to_number('||l_adjust1||')
		   ROWS UNBOUNDED PRECEDING),0) C_NET_BOOK,
		0 				P_NET_BOOK,
		NVL(SUM(SUM(f.c_rev_xtd)) OVER
		   (ORDER BY g.report_date - :ISC_CURR_START + to_number('||l_adjust1||')
 		   ROWS UNBOUNDED PRECEDING),0)	C_REV,
		0				P_REV
	  FROM	FII_TIME_DAY	g,
		(SELECT time_id,
			net_booked_amt_'||l_curr_suffix||'	C_BOOK_XTD,
			recognized_amt_'||l_curr_suffix||'	C_REV_XTD
		   FROM	'||l_mv||'  	f'
			||l_prod_cat_from||'
	 	  WHERE	f.period_type_id (+) = 1'
			||l_flags
			||l_sg_where||l_prod_cat_where||l_cust_where||l_class_where||'
		)  		f
	 WHERE	g.report_date_julian  = f.time_id (+)
	   AND	'||l_id||'
      GROUP BY	g.report_date - :ISC_CURR_START + to_number('||l_adjust1||'),
		report_date
  UNION ALL
	SELECT	g.report_date - :ISC_PRIOR_START + to_number('||l_adjust2||')
						DAYS,
		report_date,
		to_number(NULL) 		C_NET_BOOK,
		NVL(SUM(SUM(f.p_book_xtd)) OVER
		   (ORDER BY g.report_date - :ISC_PRIOR_START + to_number('||l_adjust2||')
		   ROWS UNBOUNDED PRECEDING),0)	P_NET_BOOK,
		to_number(NULL) 		C_REV,
		NVL(SUM(SUM(f.p_rev_xtd)) OVER
		   (ORDER BY g.report_date-:ISC_PRIOR_START+to_number('||l_adjust2||')
		   ROWS UNBOUNDED PRECEDING),0)	P_REV
	  FROM	FII_TIME_DAY	g,
		(SELECT	time_id,
			net_booked_amt_'||l_curr_suffix||'	P_BOOK_XTD,
			recognized_amt_'||l_curr_suffix||'	P_REV_XTD
		   FROM	'||l_mv||'  	f'
			||l_prod_cat_from||'
	 	  WHERE	f.period_type_id (+) = 1'
			||l_flags
			||l_sg_where||l_prod_cat_where||l_cust_where||l_class_where||'
		)		f
	 WHERE	g.report_date_julian  = f.time_id (+)
	   AND	'||l_id2||'
      GROUP BY	g.report_date - :ISC_PRIOR_START + to_number('||l_adjust2||'),
		report_date
	)
GROUP BY days
ORDER BY days';
  END IF;

  END IF;

  x_custom_sql := l_stmt;

  l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.View_By_Value;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.View_By_Type;
   IF l_period_type = 'FII_TIME_ENT_YEAR' THEN
    l_custom_rec.attribute_value := 'TIME+FII_TIME_ENT_PERIOD';
  ELSE -- l_period_type = 'FII_TIME_ENT_QTR', 'FII_TIME_ENT_PERIOD', 'FII_TIME_WEEK'
    l_custom_rec.attribute_value := 'TIME+FII_TIME_DAY';
  END IF;
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

  l_custom_rec.attribute_name := ':ISC_CURR_START';
  l_custom_rec.attribute_value := to_char(l_curr_start,'DD-MM-YYYY');
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.date_bind;
  x_custom_output.extend;
  x_custom_output(6) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_CURR_END';
  l_custom_rec.attribute_value := to_char(l_curr_end,'DD-MM-YYYY');
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.date_bind;
  x_custom_output.extend;
  x_custom_output(7) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_PRIOR_START';
  l_custom_rec.attribute_value := to_char(l_prior_start,'DD-MM-YYYY');
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.date_bind;
  x_custom_output.extend;
  x_custom_output(8) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_PRIOR_END';
  l_custom_rec.attribute_value := to_char(l_prior_end,'DD-MM-YYYY');
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.date_bind;
  x_custom_output.extend;
  x_custom_output(9) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_TEMP';
  l_custom_rec.attribute_value := to_char(l_temp,'DD-MM-YYYY');
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.date_bind;
  x_custom_output.extend;
  x_custom_output(10) := l_custom_rec;

END get_sql;

END ISC_DBI_REV_CUM_TREND_PKG;

/
