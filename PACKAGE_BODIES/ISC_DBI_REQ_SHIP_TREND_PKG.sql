--------------------------------------------------------
--  DDL for Package Body ISC_DBI_REQ_SHIP_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_REQ_SHIP_TREND_PKG" AS
/* $Header: ISCRGA1B.pls 120.0 2005/05/25 17:17:33 appldev noship $ */

PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt			VARCHAR2(10000);
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
  l_mv				VARCHAR2(10000);
  l_flags_where			VARCHAR2(10000);
  l_item_cat_flag		NUMBER;
  l_cust_flag			NUMBER;

  l_custom_rec			BIS_QUERY_ATTRIBUTES;

BEGIN

  FOR i IN 1..p_param.COUNT
  LOOP
    IF (p_param(i).parameter_name = 'PERIOD_TYPE')
      THEN l_period_type := p_param(i).parameter_value;
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

  IF (l_inv_org IS NULL OR l_inv_org = '' OR l_inv_org = 'All')
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
    ELSE l_inv_org_where := '
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

  IF (l_prod IS NULL OR l_prod = '' OR l_prod = 'All')
    THEN l_prod_where := '';
    ELSE l_prod_where := '
	    AND fact.item_id IN (&ITEM+ENI_ITEM_ORG)';
  END IF;

  IF (l_cust IS NULL OR l_cust = '' OR l_cust = 'All')
    THEN
      l_cust_where := '';
      l_cust_flag := 1;
    ELSE
      l_cust_where := '
	    AND fact.customer_id in (&CUSTOMER+FII_CUSTOMERS)';
      l_cust_flag := 0;
  END IF;

  IF (l_prod IS NULL OR l_prod = '' OR l_prod = 'All')
    THEN
      IF (l_prod_cat IS NULL OR l_prod_cat = '' OR l_prod_cat = 'All')
        THEN l_item_cat_flag := 3; -- category
        ELSE l_item_cat_flag := 1; -- all
      END IF;
    ELSE
      l_item_cat_flag := 0; -- product
  END IF;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  IF (l_prod IS NULL OR l_prod = '' OR l_prod = 'All') AND
     (l_cust IS NULL OR l_cust = '' OR l_cust = 'All')
    THEN
      l_mv := 'ISC_DBI_CFM_009_MV';
      l_flags_where := '
	    AND	fact.inv_org_flag = 0';
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
    ELSE
      l_mv := 'ISC_DBI_CFM_000_MV';
      l_flags_where := '
	    AND fact.item_cat_flag = :ISC_ITEM_CAT_FLAG
	    AND fact.customer_flag = :ISC_CUST_FLAG';
  END IF;

  l_stmt := '
 SELECT	fii.name						VIEWBY,
	s.scheduled_days
	  / decode(s.booked_line_cnt, 0, NULL,
		   s.booked_line_cnt)				ISC_MEASURE_1, -- avg scheduled days
	s.requested_days
	  / decode(s.booked_line_cnt, 0, NULL,
		   s.booked_line_cnt)				ISC_MEASURE_2, -- avg requested days
	s.scheduled_days
	  / decode(s.booked_line_cnt, 0, NULL,
		   s.booked_line_cnt) -
	s.requested_days
	  / decode(s.booked_line_cnt, 0, NULL,
		   s.booked_line_cnt)				ISC_MEASURE_3  -- deviation
   FROM	(SELECT	fii.start_date						START_DATE,
		sum(nvl(fact.scheduled_days, 0))			SCHEDULED_DAYS,
		sum(nvl(fact.requested_days, 0))			REQUESTED_DAYS,
		sum(nvl(fact.booked_line_cnt, 0))			BOOKED_LINE_CNT
	   FROM	'||l_mv||'	 				fact,
		'||l_period_type||'				fii,
		FII_TIME_RPT_STRUCT_V				cal'||l_prod_cat_from||'
	  WHERE	fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
				   AND &BIS_CURRENT_ASOF_DATE
	    AND	cal.report_date = least(fii.end_date, &BIS_CURRENT_ASOF_DATE)
	    AND fact.time_id = cal.time_id
	    AND fact.period_type_id = cal.period_type_id'||l_flags_where||'
	    AND bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id'
		||l_inv_org_where
		||l_prod_cat_where
		||l_prod_where
		||l_cust_where||'
	GROUP BY fii.start_date)	s,
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

END ISC_DBI_REQ_SHIP_TREND_PKG;

/
