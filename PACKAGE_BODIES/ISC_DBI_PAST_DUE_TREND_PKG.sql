--------------------------------------------------------
--  DDL for Package Body ISC_DBI_PAST_DUE_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_PAST_DUE_TREND_PKG" AS
/* $Header: ISCRG75B.pls 120.1 2006/06/26 06:26:43 abhdixi noship $ */


PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_sql_stmt 			VARCHAR2(10000);
  l_period_type 		VARCHAR2(10000);
  l_inv_org 			VARCHAR2(10000);
  l_inv_org_where		VARCHAR2(10000);
  l_item			VARCHAR2(10000);
  l_item_where			VARCHAR2(10000);
  l_inv_cat			VARCHAR2(10000);
  l_inv_cat_where		VARCHAR2(10000);
  l_customer			VARCHAR2(10000);
  l_customer_where		VARCHAR2(10000);
  l_item_cat_flag		NUMBER; -- 0 for item, 1 for inv category
  l_customer_flag		NUMBER; -- 0 for customer level, 1 for no-customer level

  l_custom_rec			BIS_QUERY_ATTRIBUTES;

BEGIN

  FOR i IN 1..p_param.COUNT
  LOOP

    IF(p_param(i).parameter_name = 'PERIOD_TYPE')
      THEN l_period_type := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION')
      THEN l_inv_org := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_INV_CAT')
      THEN l_inv_cat := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_ORG')
      THEN l_item := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'CUSTOMER+FII_CUSTOMERS')
      THEN l_customer :=  p_param(i).parameter_value;
    END IF;

  END LOOP;

  IF(l_inv_org IS NULL OR l_inv_org = 'All')
    THEN l_inv_org_where := '
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
    ELSE l_inv_org_where := '
	    AND inv_org_id = &ORGANIZATION+ORGANIZATION';
  END IF;

  IF (l_customer IS NULL OR l_customer = 'All')
    THEN l_customer_where :='';
	 l_customer_flag := 1; -- do not need customer id
    ELSE l_customer_where :='
	    AND mv.customer_id IN (&CUSTOMER+FII_CUSTOMERS)';
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

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := bis_query_attributes_tbl();

  l_sql_stmt := '
SELECT  fii.name		VIEWBY,
	fii.name		ISC_ATTRIBUTE_2,
	s.prev_pdue		ISC_MEASURE_2,
	s.curr_pdue		ISC_MEASURE_1,
	(s.curr_pdue - s.prev_pdue)
	  / decode( s.prev_pdue, 0, NULL,
		    abs(s.prev_pdue)) * 100
				ISC_MEASURE_4,
	null			ISC_MEASURE_3,  -- obsolete from DBI 5.0
	null			ISC_MEASURE_5,  -- obsolete from DBI 5.0
	null			CURRENCY	-- obsolete from DBI 5.0
   FROM	(SELECT	dates.start_date					START_DATE,
		sum(decode(mv.time_snapshot_date_id, dates.curr_day,
			   mv.pdue_line_cnt, NULL))			CURR_PDUE,
		sum(decode(mv.time_snapshot_date_id, dates.prev_day,
			   mv.pdue_line_cnt, NULL))			PREV_PDUE
	   FROM	(SELECT	curr.start_date	START_DATE,
			curr.day	CURR_DAY,
			prev.day	PREV_DAY
		   FROM	(SELECT start_date,
				day,
				rownum	ID
			   FROM
			(SELECT	fii.start_date				START_DATE,
				max(mv.time_snapshot_date_id)		DAY
			   FROM	'||l_period_type||'		fii,
				ISC_DBI_FM_0006_MV		mv
			  WHERE	fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
						   AND &BIS_CURRENT_ASOF_DATE
			    AND	mv.time_snapshot_date_id (+) >= fii.start_date
			    AND	mv.time_snapshot_date_id (+) <= fii.end_date
			    AND	mv.time_snapshot_date_id (+) <= &BIS_CURRENT_ASOF_DATE
			GROUP BY fii.start_date)
			ORDER BY start_date DESC)		curr,
			(SELECT start_date,
				day,
				rownum	ID
			   FROM
			(SELECT	fii.start_date				START_DATE,
				max(mv.time_snapshot_date_id)		DAY
			   FROM	'||l_period_type||'		fii,
				ISC_DBI_FM_0006_MV		mv
			  WHERE	fii.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE
						   AND &BIS_PREVIOUS_ASOF_DATE
			    AND	mv.time_snapshot_date_id (+) >= fii.start_date
			    AND	mv.time_snapshot_date_id (+) <= fii.end_date
			    AND	mv.time_snapshot_date_id (+) <= &BIS_PREVIOUS_ASOF_DATE
			GROUP BY fii.start_date)
			ORDER BY start_date DESC)		prev
		  WHERE	curr.id = prev.id(+))			dates,
		ISC_DBI_FM_0006_MV 				mv
	  WHERE	mv.time_snapshot_date_id IN (dates.curr_day, dates.prev_day)
	    AND ((mv.item_cat_flag = :ISC_ITEM_CAT_FLAG
	    AND	mv.customer_flag = :ISC_CUSTOMER_FLAG'
		||l_inv_org_where
		||l_inv_cat_where
		||l_item_where
		||l_customer_where
		||')
	     OR mv.inv_org_id IS NULL)  -- snapshot taken but no data
       GROUP BY	dates.start_date)	s,
	'||l_period_type||'		fii
  WHERE	fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
			   AND &BIS_CURRENT_ASOF_DATE
    AND	fii.start_date = s.start_date(+)
ORDER BY fii.start_date';

  x_custom_sql := l_sql_stmt;

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

  l_custom_rec.attribute_name := ':ISC_CUSTOMER_FLAG';
  l_custom_rec.attribute_value := to_char(l_customer_flag);
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

END Get_Sql;

END ISC_DBI_PAST_DUE_TREND_PKG ;


/
