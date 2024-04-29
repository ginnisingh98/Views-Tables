--------------------------------------------------------
--  DDL for Package Body ISC_DBI_RETURN_VALUE_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_RETURN_VALUE_TREND_PKG" AS
/* $Header: ISCRGACB.pls 120.1 2006/06/26 06:59:04 abhdixi noship $ */


PROCEDURE GET_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,x_custom_sql OUT NOCOPY VARCHAR2,
	x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt 		VARCHAR2(32000);
  l_flags_where		VARCHAR2(1000);
  l_org 		VARCHAR2(32000);
  l_org_where		VARCHAR2(32000);
  l_prod		VARCHAR2(32000);
  l_prod_where		VARCHAR2(32000);
  l_prod_cat		VARCHAR2(32000);
  l_prod_cat_from	VARCHAR2(32000);
  l_prod_cat_where	VARCHAR2(32000);
  l_cust		VARCHAR2(32000);
  l_cust_where		VARCHAR2(32000);
  l_ret_reason		VARCHAR2(32000);
  l_ret_reason_where	VARCHAR2(32000);
  l_period_type		VARCHAR2(32000);
  l_return_amt		VARCHAR2(20);
  l_currency		VARCHAR2(480);
  l_temp		VARCHAR2(480);
  l_sql_stmt		VARCHAR2(32000);
  l_g_currency		VARCHAR2(48);
  l_g1_currency		VARCHAR2(48);
  l_item_cat_flag	NUMBER; -- 0 for product, 1 for product category, 3 for no grouping on item dimension
  l_cust_flag		NUMBER; -- 0 for customer and 1 for no customer selected
  l_reason_flag		NUMBER; -- 0 for reason and 1 for all reasons
  l_mv			VARCHAR2(10);
  l_custom_rec 		BIS_QUERY_ATTRIBUTES;

BEGIN

  l_g_currency		:= '''FII_GLOBAL1''';
  l_g1_currency		:= '''FII_GLOBAL2''';

  FOR i IN 1..p_param.COUNT
  LOOP

    IF(p_param(i).parameter_name = 'PERIOD_TYPE')
      THEN l_period_type := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION')
      THEN l_org := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_VBH_CAT') THEN
       l_prod_cat := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_ORG') THEN
       l_prod := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES')
      THEN l_currency := p_param(i).parameter_id;
    END IF;

    IF(p_param(i).parameter_name = 'CUSTOMER+FII_CUSTOMERS')
      THEN l_cust := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ORDER_ITEM_RETURN_REASON+ORDER_ITEM_RETURN_REASON')
      THEN l_ret_reason := p_param(i).parameter_id;
    END IF;

  END LOOP;


  IF(l_currency = l_g_currency)
    THEN l_return_amt := 'returned_amt_g';
    ELSIF (l_currency = l_g1_currency)
      THEN l_return_amt := 'returned_amt_g1';
    ELSE l_return_amt := 'returned_amt_f';
  END IF;

  IF ( l_org IS NULL OR l_org = '' OR l_org = 'All')
    THEN
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

  IF (l_prod_cat IS NULL OR l_prod_cat = '' OR l_prod_cat = 'All')
    THEN
      l_prod_cat_from := '';
      l_prod_cat_where := '';
    ELSE
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
  END IF;

  IF ( l_prod IS NULL OR l_prod = '' OR l_prod = 'All' )
    THEN l_prod_where := '';
    ELSE l_prod_where := '
	    AND fact.item_id in (&ITEM+ENI_ITEM_ORG)';
  END IF;


  IF (l_cust IS NULL OR l_cust = '' OR l_cust = 'All')
    THEN
      l_cust_where:='';
      l_cust_flag := 1; -- all customers
    ELSE
      l_cust_where :='
	    AND fact.customer_id in (&CUSTOMER+FII_CUSTOMERS)';
      l_cust_flag := 0; -- customer selected
  END IF;

  IF (l_prod IS NULL OR l_prod = '' OR l_prod = 'All')
    THEN
      IF (l_prod_cat IS NULL OR l_prod_cat = '' OR l_prod_cat = 'All')
        THEN l_item_cat_flag := 3; -- all
        ELSE l_item_cat_flag := 1; -- category
      END IF;
    ELSE
      l_item_cat_flag := 0; -- product
  END IF;

  IF ( l_ret_reason IS NULL OR l_ret_reason = '' OR l_ret_reason = 'All' )
    THEN
      l_ret_reason_where := '
	    AND fact.return_flag = 1';
      l_mv := '002';
      l_reason_flag := 1;
    ELSE
      l_ret_reason_where := '
	    AND fact.return_reason IN (&ORDER_ITEM_RETURN_REASON+ORDER_ITEM_RETURN_REASON)
	    AND fact.return_reason_flag = :ISC_REASON_FLAG';
      l_mv := '007';
      l_reason_flag := 0;
  END IF;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  IF ((l_prod IS NULL OR l_prod = '' OR l_prod = 'All') AND
      (l_cust IS NULL OR l_cust = '' OR l_cust = 'All') AND
      (l_ret_reason IS NULL OR l_ret_reason = '' OR l_ret_reason = 'All'))
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
      l_mv := '011';
      l_flags_where := '
	    AND	fact.inv_org_flag = 0';
    ELSE
	l_flags_where := '
	    AND fact.item_cat_flag = :ISC_ITEM_CAT_FLAG
	    AND fact.customer_flag = :ISC_CUST_FLAG';
  END IF;

      l_stmt := '
SELECT	fii.name				VIEWBY,
	s.pre_return_amt			ISC_MEASURE_2, -- prev return value
	s.cur_return_amt			ISC_MEASURE_1, -- curr return value
	(s.cur_return_amt - s.pre_return_amt)
	  / decode( s.pre_return_amt,0,
		    NULL,
		    abs(s.pre_return_amt)) * 100	ISC_MEASURE_3 -- return value change
   FROM (SELECT dates.start_date						START_DATE,
		sum(decode(dates.period, ''C'', fact.'||l_return_amt||', 0))	CUR_RETURN_AMT,
		sum(decode(dates.period, ''P'', fact.'||l_return_amt||', 0))	PRE_RETURN_AMT
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
		  WHERE	p1.id(+) = p2.id)						dates,
		ISC_DBI_CFM_'||l_mv||'_MV			fact,
		FII_TIME_RPT_STRUCT_V			cal'
		||l_prod_cat_from||'
	  WHERE	cal.report_date = dates.report_date
	    AND bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id
	    AND fact.time_id = cal.time_id
	    AND fact.period_type_id = cal.period_type_id'
	||l_flags_where||l_org_where||l_prod_cat_where||l_prod_where||l_cust_where||l_ret_reason_where||'
    	  GROUP BY dates.start_date) 	s,
		'||l_period_type||' 		fii
  WHERE fii.start_date = s.start_date(+)
    AND fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
			   AND &BIS_CURRENT_ASOF_DATE
  ORDER BY fii.start_date ';

  x_custom_sql := l_stmt;

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
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_REASON_FLAG';
  l_custom_rec.attribute_value := to_char(l_reason_flag);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

END get_sql;

END ISC_DBI_RETURN_VALUE_TREND_PKG ;


/
