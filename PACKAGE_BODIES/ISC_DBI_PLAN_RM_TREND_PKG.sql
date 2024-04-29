--------------------------------------------------------
--  DDL for Package Body ISC_DBI_PLAN_RM_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_PLAN_RM_TREND_PKG" AS
/* $Header: ISCRGAJB.pls 120.0 2005/05/25 17:25:55 appldev noship $ */


PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt			VARCHAR2(10000);
  l_plan			VARCHAR2(10000);
  l_plan2			VARCHAR2(10000);
  l_org				VARCHAR2(10000);
  l_org_where			VARCHAR2(10000);
  l_prod			VARCHAR2(10000);
  l_prod_where			VARCHAR2(10000);
  l_prod_cat			VARCHAR2(10000);
  l_prod_cat_from		VARCHAR2(10000);
  l_prod_cat_where		VARCHAR2(10000);
  l_period_type 		VARCHAR2(10000);
  l_period_type_id		NUMBER;
  l_time_from			DATE;
  l_rpt_end_date		DATE;
  l_loop			NUMBER;
  l_item_cat_flag		NUMBER;
  l_union1_flag			NUMBER := 0;
  l_mv				VARCHAR2(100);
  l_flags_where			VARCHAR2(1000);
  l_custom_rec			BIS_QUERY_ATTRIBUTES;
  l_curr			VARCHAR2(10000);
  l_curr_g			VARCHAR2(15) := '''FII_GLOBAL1''';
  l_curr_g1			VARCHAR2(15) := '''FII_GLOBAL2''';
  l_curr_suffix                 VARCHAR2(15);

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

    IF (p_param(i).parameter_name = 'ITEM+ENI_ITEM_VBH_CAT')
      THEN l_prod_cat := p_param(i).parameter_value;
    END IF;

    IF (p_param(i).parameter_name = 'ITEM+ENI_ITEM_ORG')
      THEN l_prod := p_param(i).parameter_value;
    END IF;

    IF (p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES')
      THEN l_curr := p_param(i).parameter_id;
    END IF;

  END LOOP;

  IF (l_curr = l_curr_g)
    THEN
    	l_curr_suffix := '_g';
    ELSIF (l_curr = l_curr_g1)
	THEN
		l_curr_suffix := '_g1';
	ELSE
	    	l_curr_suffix := '';
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

  IF (l_prod_cat IS NULL OR l_prod_cat = 'All')
    THEN
      l_prod_cat_from := '';
      l_prod_cat_where := '';
    ELSE
      l_prod_cat_from := ',
		ENI_DENORM_HIERARCHIES		eni_cat,
		MTL_DEFAULT_CATEGORY_SETS	mdcs';
      l_prod_cat_where := '
	    AND f.vbh_category_id = eni_cat.child_id
	    AND eni_cat.parent_id IN (&ITEM+ENI_ITEM_VBH_CAT)
	    AND	eni_cat.dbi_flag = ''Y''
	    AND eni_cat.object_type = ''CATEGORY_SET''
	    AND eni_cat.object_id = mdcs.category_set_id
	    AND	mdcs.functional_area_id = 11';
  END IF;

  IF (l_prod IS NULL OR l_prod = 'All')
    THEN l_prod_where := '';
    ELSE l_prod_where := '
	    AND f.item_id IN (&ITEM+ENI_ITEM_ORG)';
  END IF;

  IF (l_prod IS NULL OR l_prod = 'All')
    THEN
      IF (l_prod_cat IS NULL OR l_prod_cat = 'All')
        THEN l_item_cat_flag := 3; -- all
        ELSE l_item_cat_flag := 2; -- category
      END IF;
    ELSE
      l_item_cat_flag := 0; -- product
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

  IF ((l_prod_cat IS NULL OR l_prod_cat = 'All') AND (l_prod IS NULL OR l_prod = 'All'))
    THEN
	l_mv := 'ISC_DBI_PM_0003_MV';
	l_flags_where := '';
    ELSE
	l_mv := 'ISC_DBI_PM_0001_MV';
	l_flags_where := '
	    AND f.item_cat_flag = :ISC_ITEM_CAT_FLAG
	    AND f.union1_flag <> :ISC_UNION1_FLAG';
  END IF;

  l_stmt := '
SELECT	fii.name			VIEWBY,
	nvl(c.rev,0)			ISC_MEASURE_1, -- Revenue
	nvl(c.comp_rev,0)		ISC_MEASURE_2, -- Compare Plan (Revenue)
	nvl((c.rev - c.comp_rev),0)	ISC_MEASURE_3, -- Variance (Revenue)
	nvl(c.cost,0)			ISC_MEASURE_4, -- Cost
	nvl(c.comp_cost,0)		ISC_MEASURE_5, -- Compare Plan (Cost)
	nvl((c.cost - c.comp_cost),0)	ISC_MEASURE_6, -- Variance (Cost)
	nvl((c.rev - c.cost),0)		ISC_MEASURE_7, -- Margin
	nvl((c.comp_rev - c.comp_cost),0)
					ISC_MEASURE_8, -- Compare Plan (Margin)
	nvl(((c.rev - c.cost) - (c.comp_rev - c.comp_cost)),0)
					ISC_MEASURE_9, -- Variance (Margin)
	(c.rev - c.cost) / decode(c.rev,0,NULL,c.rev) * 100
					ISC_MEASURE_10, -- Margin Percent
	(c.comp_rev - c.comp_cost) / decode(c.comp_rev,0,NULL,c.comp_rev) * 100
					ISC_MEASURE_11, -- Compare Plan (Margin Percent)
	((c.rev - c.cost) / decode(c.rev,0,NULL,c.rev) * 100)
	  - ((c.comp_rev - c.comp_cost) / decode(c.comp_rev,0,NULL,c.comp_rev) * 100)
					ISC_MEASURE_12 -- Variance (Margin Percent)
   FROM	(SELECT	f.start_date				START_DATE,
		sum(decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
			   f.mds_price'||l_curr_suffix||', 0))		REV,
		decode(&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2, -1, null,
			sum(decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
				   f.mds_price'||l_curr_suffix||', 0)))	COMP_REV,
		sum(decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
			   f.mds_cost'||l_curr_suffix||', 0))		COST,
		decode(&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2, -1, null,
			sum(decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
				   f.mds_cost'||l_curr_suffix||', 0)))	COMP_COST
	   FROM	'||l_mv||'		f'
		||l_prod_cat_from||'
	  WHERE	f.start_date BETWEEN :ISC_TIME_FROM AND :ISC_RPT_END_DATE
	    AND	f.period_type_id = :ISC_PERIOD_TYPE_ID
	    AND f.snapshot_id IN (&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2)'
		||l_flags_where
		||l_org_where||l_prod_cat_where||l_prod_where||'
       GROUP BY	f.start_date)		c,
	'||l_period_type||'		fii
  WHERE	fii.start_date BETWEEN :ISC_TIME_FROM AND :ISC_RPT_END_DATE
    AND	fii.start_date = c.start_date(+)
ORDER BY fii.start_date';

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

  l_custom_rec.attribute_name := ':ISC_UNION1_FLAG';
  l_custom_rec.attribute_value := to_char(l_union1_flag);
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.Bind_Type;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.Integer_Bind;
  x_custom_output.extend;
  x_custom_output(6) := l_custom_rec;

END Get_Sql;

END ISC_DBI_PLAN_RM_TREND_PKG ;


/
