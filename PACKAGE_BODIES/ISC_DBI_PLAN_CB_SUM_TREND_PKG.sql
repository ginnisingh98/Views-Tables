--------------------------------------------------------
--  DDL for Package Body ISC_DBI_PLAN_CB_SUM_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_PLAN_CB_SUM_TREND_PKG" AS
/* $Header: ISCRGANB.pls 120.0 2005/05/25 17:22:51 appldev noship $ */


PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt			VARCHAR2(10000);
  l_plan			VARCHAR2(10000);
  l_plan2			VARCHAR2(10000);
  l_org				VARCHAR2(10000);
  l_org_where			VARCHAR2(10000);
  l_item			VARCHAR2(10000);
  l_item_where			VARCHAR2(10000);
  l_inv_cat			VARCHAR2(10000);
  l_inv_cat_where		VARCHAR2(10000);
  l_period_type 		VARCHAR2(10000);
  l_period_type_id		NUMBER;
  l_time_from			DATE;
  l_rpt_end_date		DATE;
  l_loop			NUMBER;
  l_item_cat_flag		NUMBER;
  l_custom_rec			BIS_QUERY_ATTRIBUTES;
  l_curr			VARCHAR2(10000);
  l_curr_g			VARCHAR2(15) := '''FII_GLOBAL1''';
  l_curr_g1			VARCHAR2(15) := '''FII_GLOBAL2''';
  l_col1			VARCHAR2(100);
  l_col2			VARCHAR2(100);
  l_col3			VARCHAR2(100);


BEGIN

  FOR i IN 1..p_param.COUNT
  LOOP
    IF (p_param(i).parameter_name = 'PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT')
      THEN l_plan := p_param(i).parameter_value;
    END IF;

    IF (p_param(i).parameter_name = 'PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2')
      THEN l_plan2 := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'PERIOD_TYPE')
      THEN l_period_type := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM')
      THEN l_time_from :=  p_param(i).period_date;
    END IF;

    IF(p_param(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM')
      THEN l_time_from :=  p_param(i).period_date;
    END IF;

    IF(p_param(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM')
      THEN l_time_from :=  p_param(i).period_date;
    END IF;

    IF (p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION')
      THEN l_org := p_param(i).parameter_value;
    END IF;

    IF (p_param(i).parameter_name = 'ITEM+ENI_ITEM_INV_CAT')
      THEN l_inv_cat := p_param(i).parameter_value;
    END IF;

    IF (p_param(i).parameter_name = 'ITEM+ENI_ITEM_ORG')
      THEN l_item := p_param(i).parameter_value;
    END IF;

    IF (p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES')
      THEN l_curr := p_param(i).parameter_id;
    END IF;

  END LOOP;

  IF (l_curr = l_curr_g)
    THEN
	l_col1 := 'pro_cost_g';
	l_col2 := 'carrying_cost_g';
	l_col3 := 'pur_cost_g';
    ELSIF (l_curr = l_curr_g1)
	THEN
		l_col1 := 'pro_cost_g1';
		l_col2 := 'carrying_cost_g1';
		l_col3 := 'pur_cost_g1';
	ELSE
		l_col1 := 'production_cost';
		l_col2 := 'carrying_cost';
		l_col3 := 'purchasing_cost';
  END IF;

  IF (l_org IS NULL OR l_org = 'All')
    THEN l_org_where := '
	AND (EXISTS
		(SELECT 1
		FROM org_access o
		WHERE o.responsibility_id = fnd_global.resp_id
		AND o.resp_application_id = fnd_global.resp_appl_id
		AND o.organization_id = f.organization_id)
	     OR EXISTS
		(SELECT 1
		FROM mtl_parameters org
		WHERE org.organization_id = f.organization_id
		AND NOT EXISTS
			(SELECT 1
			FROM org_access ora
			WHERE org.organization_id = ora.organization_id)))';
    ELSE l_org_where := '
	    AND f.organization_id = &ORGANIZATION+ORGANIZATION';
  END IF;

  IF(l_inv_cat IS NULL OR l_inv_cat = 'All')
    THEN l_inv_cat_where := '';
    ELSE l_inv_cat_where := '
	AND f.inv_category_id IN (&ITEM+ENI_ITEM_INV_CAT)';
  END IF;

  IF(l_item IS NULL OR l_item = 'All')
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

  IF (l_period_type = 'FII_TIME_ENT_PERIOD') THEN
	l_period_type_id := 32;
	l_loop := 11;
  ELSIF (l_period_type = 'FII_TIME_ENT_QTR') THEN
	l_period_type_id := 64;
	l_loop := 7;
  ELSE -- l_period_type = 'FII_TIME_ENT_YEAR'
	l_period_type_id := 128;
	l_loop := 3;
  END IF;

 -- Get report end date
  l_rpt_end_date := l_time_from;

  FOR i IN 1..l_loop
  LOOP
    l_rpt_end_date := FII_TIME_API.next_period_end_date(l_rpt_end_date, l_period_type);
  END LOOP;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  IF (l_plan IS NULL OR l_plan2 IS NULL)
    THEN l_stmt := '
SELECT	0 	ISC_MEASURE_1,
	0 	ISC_MEASURE_2,
	0 	ISC_MEASURE_3,
	0 	ISC_MEASURE_4,
	0 	ISC_MEASURE_5,
	0 	ISC_MEASURE_6,
	0 	ISC_MEASURE_7,
	0 	ISC_MEASURE_8,
	0 	ISC_MEASURE_9,
	0 	ISC_MEASURE_10,
	0 	ISC_MEASURE_11,
	0 	ISC_MEASURE_12
  FROM	dual
 WHERE	1 = 2 /* PLAN_SNAPSHOT dimension has not been populated */';
    ELSE

  l_stmt := '
SELECT	c.period_name			VIEWBY,
	nvl(c.prod,0)			ISC_MEASURE_1, -- Production Cost
	nvl(c.comp_prod,0)		ISC_MEASURE_2, -- Compare Plan (Production Cost)
	nvl((c.prod - c.comp_prod),0)	ISC_MEASURE_3, -- Variance (Production Cost)
	nvl(c.carry,0)			ISC_MEASURE_4, -- Carrying Cost
	nvl(c.comp_carry,0)		ISC_MEASURE_5, -- Compare Plan (Carrying Cost)
	nvl((c.carry - c.comp_carry),0)	ISC_MEASURE_6, -- Variance (Carrying Cost)
	nvl(c.purch,0)			ISC_MEASURE_7, -- Purchasing Cost
	nvl(c.comp_purch,0)		ISC_MEASURE_8, -- Compare Plan (Purchasing Cost)
	nvl((c.purch - c.comp_purch),0)	ISC_MEASURE_9, -- Variance (Purchasing Cost)
	nvl((c.prod + c.carry + c.purch),0)
					ISC_MEASURE_10, -- Combined Cost
	nvl((c.comp_prod + c.comp_carry + c.comp_purch),0)
					ISC_MEASURE_11, -- Compare Plan (Combined Cost)
	nvl(((c.prod + c.carry + c.purch)
	       - (c.comp_prod + c.comp_carry + c.comp_purch)),0)
					ISC_MEASURE_12 -- Variance (Combined Cost)
   FROM	(SELECT	time.start_date					PERIOD_ID,
		time.name					PERIOD_NAME,
		sum(decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
			   f.'||l_col1||', 0))		PROD,
		decode(&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2, -1, null,
			sum(decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
				   f.'||l_col1||', 0)))	COMP_PROD,
		sum(decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
			   f.'||l_col2||', 0))			CARRY,
		decode(&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2, -1, null,
			sum(decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
				   f.'||l_col2||', 0)))	COMP_CARRY,
		sum(decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
			   f.'||l_col3||', 0))		PURCH,
		decode(&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2, -1, null,
			sum(decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
				   f.'||l_col3||', 0)))	COMP_PURCH
	   FROM	(SELECT start_date, name
		   FROM	'||l_period_type||'
		  WHERE	start_date BETWEEN :ISC_TIME_FROM AND :ISC_RPT_END_DATE
		 )			time
	   LEFT OUTER JOIN
		ISC_DBI_PM_0001_MV	f
	    ON f.start_date = time.start_date
	    AND	f.period_type_id = :ISC_PERIOD_TYPE_ID
	    AND f.item_cat_flag = :ISC_ITEM_CAT_FLAG
	    AND f.union1_flag <> 0
	    AND f.snapshot_id IN (&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2)'
		||l_org_where||l_inv_cat_where||l_item_where||'
       GROUP BY	time.name, time.start_date)	c
ORDER BY c.period_id';

  END IF;

  x_custom_sql := l_stmt;

  l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
  l_custom_rec.attribute_value := 'TIME+'||l_period_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_PERIOD_TYPE_ID';
  l_custom_rec.attribute_value := to_char(l_period_type_id);
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_TIME_FROM';
  l_custom_rec.attribute_value := to_char(l_time_from,'DD/MM/YYYY');
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.date_bind;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_RPT_END_DATE';
  l_custom_rec.attribute_value := to_char(l_rpt_end_date,'DD/MM/YYYY');
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.date_bind;
  x_custom_output.extend;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_ITEM_CAT_FLAG';
  l_custom_rec.attribute_value := to_char(l_item_cat_flag);
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
  x_custom_output.extend;
  x_custom_output(5) := l_custom_rec;

END Get_Sql;

END ISC_DBI_PLAN_CB_SUM_TREND_PKG ;


/
