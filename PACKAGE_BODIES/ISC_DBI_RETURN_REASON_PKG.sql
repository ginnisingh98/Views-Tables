--------------------------------------------------------
--  DDL for Package Body ISC_DBI_RETURN_REASON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_RETURN_REASON_PKG" AS
/* $Header: ISCRGADB.pls 120.1 2006/06/26 07:00:24 abhdixi noship $ */


PROCEDURE GET_SQL(	p_param 	IN 		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql 	OUT NOCOPY	VARCHAR2,
			x_custom_output OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt 		VARCHAR2(32000);
  l_org 		VARCHAR2(32000);
  l_org_where     	VARCHAR2(32000);
  l_prod		VARCHAR2(32000);
  l_prod_where		VARCHAR2(32000);
  l_prod_cat		VARCHAR2(32000);
  l_prod_cat_from	VARCHAR2(32000);
  l_prod_cat_where	VARCHAR2(32000);
  l_cust		VARCHAR2(32000);
  l_cust_where		VARCHAR2(32000);
  l_ret_reason		VARCHAR2(32000);
  l_ret_reason_where	VARCHAR2(32000);
  l_currency		VARCHAR2(20);
  l_item_cat_flag	NUMBER; -- 0 for product and 1 for product category
  l_cust_flag		NUMBER; -- 0 for customer and 1 for no customer selected
  l_return_amt		VARCHAR2(20);
  l_g_currency		VARCHAR2(15) := '''FII_GLOBAL1''';
  l_g1_currency		VARCHAR2(15) := '''FII_GLOBAL2''';
  l_custom_rec 		BIS_QUERY_ATTRIBUTES ;

BEGIN
  FOR i IN 1..p_param.COUNT
  LOOP

    IF(p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION')
      THEN l_org :=  p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_VBH_CAT') THEN
       l_prod_cat :=  p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_ORG') THEN
       l_prod :=  p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'CUSTOMER+FII_CUSTOMERS') THEN
       l_cust :=  p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES')
      THEN l_currency := p_param(i).parameter_id;
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

  IF (l_prod IS NULL OR l_prod = '' OR l_prod = 'All')
    THEN
      IF (l_prod_cat IS NULL OR l_prod_cat = '' OR l_prod_cat = 'All')
        THEN l_item_cat_flag := 3; -- all
        ELSE l_item_cat_flag := 1; -- category
      END IF;
    ELSE
      l_item_cat_flag := 0; -- product
  END IF;

  IF (l_org IS NULL OR l_org = '' OR l_org = 'All') THEN
    l_org_where := '
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
  ELSE
    l_org_where := '
	    AND mv.inv_org_id = &ORGANIZATION+ORGANIZATION';
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
	    AND mv.item_category_id = eni_cat.child_id
	    AND eni_cat.parent_id IN (&ITEM+ENI_ITEM_VBH_CAT)
	    AND	eni_cat.dbi_flag = ''Y''
	    AND eni_cat.object_type = ''CATEGORY_SET''
	    AND eni_cat.object_id = mdcs.category_set_id
	    AND	mdcs.functional_area_id = 11';
  END IF;

  IF ( l_prod IS NULL OR l_prod = '' OR l_prod = 'All' )
    THEN l_prod_where := '';
    ELSE l_prod_where := '
	    AND mv.item_id in (&ITEM+ENI_ITEM_ORG)';
  END IF;

  IF (l_cust IS NULL OR l_cust = '' OR l_cust = 'All')
    THEN
      l_cust_where:='';
      l_cust_flag := 1; -- all customers and not viewed by customer
    ELSE
      l_cust_where :='
	    AND mv.customer_id in (&CUSTOMER+FII_CUSTOMERS)';
      l_cust_flag := 0; -- customer selected
  END IF;

  IF ( l_ret_reason IS NULL OR l_ret_reason = '' OR l_ret_reason = 'All' )
    THEN l_ret_reason_where := '';
    ELSE l_ret_reason_where := '
	    AND mv.return_reason IN (&ORDER_ITEM_RETURN_REASON+ORDER_ITEM_RETURN_REASON)';
  END IF;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

      l_stmt := '
 SELECT	ret.value				VIEWBY, -- return reason
	ret.id					VIEWBYID,
	c.prev_return				ISC_MEASURE_7, -- return value (prior)
	c.curr_return				ISC_MEASURE_1, -- return value
	(c.curr_return - c.prev_return)
	  / decode(c.prev_return, 0, NULL,
		   abs(c.prev_return)) * 100	ISC_MEASURE_2, -- change (return value),
	c.curr_return
	  / decode(sum(c.curr_return) over(), 0, NULL,
		   sum(c.curr_return) over())
	  * 100					ISC_MEASURE_3, -- Percent of Total
	c.lines_cnt				ISC_MEASURE_4, -- lines affected
	sum(c.curr_return) over()		ISC_MEASURE_5, -- grand total for return value
	(sum(c.curr_return) over() - sum(c.prev_return) over())
	  / decode(sum(c.prev_return) over(), 0, NULL,
		   abs(sum(c.prev_return) over()))
	  * 100					ISC_MEASURE_6, -- grand total for return value change
	sum(c.lines_cnt) over()			ISC_MEASURE_8 -- grand total for lines affected
   FROM (SELECT	mv.return_reason				REASON,
		sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
			   mv.'||l_return_amt||', 0))		CURR_RETURN,
		sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
			   mv.'||l_return_amt||', 0))		PREV_RETURN,
		sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
			   mv.lines_cnt, 0))			LINES_CNT
	   FROM ISC_DBI_CFM_007_MV	mv,
		FII_TIME_RPT_STRUCT_V	cal'
		||l_prod_cat_from||'
	  WHERE mv.time_id = cal.time_id
	    AND mv.period_type_id = cal.period_type_id
	    AND bitand(cal.record_type_id,&BIS_NESTED_PATTERN) = cal.record_type_id
	    AND cal.report_date IN (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
	    AND mv.customer_flag = :ISC_CUST_FLAG
	    AND mv.item_cat_flag = :ISC_ITEM_CAT_FLAG
	    AND mv.return_reason_flag = 0'
		||l_org_where||l_prod_cat_where||l_prod_where||l_cust_where||l_ret_reason_where||'
	GROUP BY mv.return_reason)	c,
	BIS_ORDER_ITEM_RET_REASON_V	ret
  WHERE c.reason = ret.id
 &ORDER_BY_CLAUSE NULLS LAST';

  x_custom_sql := l_stmt;

  l_custom_rec.attribute_name := ':ISC_ITEM_CAT_FLAG';
  l_custom_rec.attribute_value := to_char(l_item_cat_flag);
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_CUST_FLAG';
  l_custom_rec.attribute_value := to_char(l_cust_flag);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

END get_sql;

END ISC_DBI_RETURN_REASON_PKG;


/
