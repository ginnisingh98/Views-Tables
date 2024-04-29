--------------------------------------------------------
--  DDL for Package Body ISC_DBI_PLAN_PUR_COST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_PLAN_PUR_COST_PKG" AS
/* $Header: ISCRGAOB.pls 120.0 2005/05/25 17:17:56 appldev noship $ */


PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt			VARCHAR2(10000);
  l_plan			VARCHAR2(10000);
  l_plan2			VARCHAR2(10000);
  l_outer_sql			VARCHAR2(10000);
  l_formula_sql			VARCHAR2(10000);
  l_inner_sql			VARCHAR2(10000);
  l_view_by			VARCHAR2(10000);
  l_org				VARCHAR2(10000);
  l_org_where			VARCHAR2(10000);
  l_item			VARCHAR2(10000);
  l_item_where			VARCHAR2(10000);
  l_inv_cat			VARCHAR2(10000);
  l_inv_cat_where		VARCHAR2(10000);
  l_supplier			VARCHAR2(10000);
  l_supplier_where		VARCHAR2(10000);
  l_period_type 		VARCHAR2(10000);
  l_period_type_id		NUMBER;
  l_time_from			DATE;
  l_lang			VARCHAR2(10);
  l_item_cat_flag		NUMBER;
  l_row_filter			VARCHAR2(10000);
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

    IF (p_param(i).parameter_name = 'VIEW_BY')
      THEN l_view_by := p_param(i).parameter_value;
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

    IF (p_param(i).parameter_name = 'SUPPLIER+POA_SUPPLIERS')
      THEN l_supplier := p_param(i).parameter_value;
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

  IF(l_inv_cat IS NULL OR l_inv_cat = 'All')
    THEN l_inv_cat_where := '';
    ELSE l_inv_cat_where := '
	AND f.item_category_id IN (&ITEM+ENI_ITEM_INV_CAT)';
  END IF;

  IF(l_item IS NULL OR l_item = 'All')
    THEN l_item_where := '';
    ELSE l_item_where := '
	AND f.item_id IN (&ITEM+ENI_ITEM_ORG)';
  END IF;

  IF(l_supplier IS NULL OR l_supplier = 'All')
    THEN l_supplier_where := '';
    ELSE l_supplier_where := '
	AND f.sr_supplier_id in (&SUPPLIER+POA_SUPPLIERS)';
  END IF;

  IF (l_period_type = 'FII_TIME_ENT_PERIOD') THEN
	l_period_type_id := 32;
  ELSIF (l_period_type = 'FII_TIME_ENT_QTR') THEN
	l_period_type_id := 64;
  ELSE -- l_period_type = 'FII_TIME_ENT_YEAR'
	l_period_type_id := 128;
  END IF;

  IF (l_item IS NULL OR l_item = 'All')
    THEN
      IF (l_view_by = 'ITEM+ENI_ITEM_ORG')
	THEN l_item_cat_flag := 0; -- item
      ELSIF (l_view_by = 'ITEM+ENI_ITEM_INV_CAT')
        THEN l_item_cat_flag := 1; -- inventory category
      ELSE
	IF (l_inv_cat IS NULL OR l_inv_cat = 'All')
	  THEN l_item_cat_flag := 3; -- all
	ELSE l_item_cat_flag := 1; -- inventory category
	END IF;
      END IF;
  ELSE
    l_item_cat_flag := 0; -- item
  END IF;

  l_lang := USERENV('LANG');

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();


  IF (l_plan IS NULL OR l_plan2 IS NULL)
    THEN l_stmt := '
SELECT	0	VIEWBY,
	0	VIEWBYID,
	0	ISC_ATTRIBUTE_1,
	0 	ISC_MEASURE_1,
	0 	ISC_MEASURE_2,
	0 	ISC_MEASURE_3,
	0 	ISC_MEASURE_4,
	0 	ISC_MEASURE_5
  FROM	dual
 WHERE	1 = 2 /* PLAN_SNAPSHOT dimension has not been populated */';
    ELSE

-- Filter out rows with only 0 or N/A
   l_row_filter := '
	WHERE (ISC_MEASURE_1 IS NOT NULL AND ISC_MEASURE_1 <> 0)
	   OR (ISC_MEASURE_2 IS NOT NULL AND ISC_MEASURE_2 <> 0)';

  l_outer_sql := 'ISC_MEASURE_1, ISC_MEASURE_2, ISC_MEASURE_3, ISC_MEASURE_4, ISC_MEASURE_5';

  l_formula_sql :=	'c.cost					ISC_MEASURE_1, -- Purchasing Cost
			c.comp_cost				ISC_MEASURE_2, -- Compare Plan (Purchasing Cost)
			(c.cost - c.comp_cost)			ISC_MEASURE_3, -- Variance (Purchasing Cost)
			sum(c.cost) over ()			ISC_MEASURE_4, -- Grand Total - Purchasing Cost
			sum(c.cost - c.comp_cost) over ()	ISC_MEASURE_5 -- Grand Total - Variance (Purchasing Cost)';

  l_inner_sql := 		'sum(decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
					    f.purchasing_cost'||l_curr_suffix||', 0))	COST,
				decode(&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2, -1,
					null,
					sum(decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
						   f.purchasing_cost'||l_curr_suffix||', 0)))	COMP_COST
			   FROM	ISC_DBI_PM_0000_MV f
			  WHERE	f.start_date = :ISC_TIME_FROM
			    AND	f.period_type_id =:ISC_PERIOD_TYPE_ID
			    AND	f.item_cat_flag = :ISC_ITEM_CAT_FLAG
			    AND f.snapshot_id IN (&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2)'
				||l_org_where
				||l_inv_cat_where
				||l_item_where
				||l_supplier_where;

  IF l_view_by = 'ITEM+ENI_ITEM_ORG'
    THEN l_stmt := '
SELECT	items.value		VIEWBY,
	items.id		VIEWBYID,
	items.description  	ISC_ATTRIBUTE_1, -- Description
	'||l_outer_sql||'
  FROM	(SELECT	(rank() over (&ORDER_BY_CLAUSE NULLS LAST,item_id))-1 RNK,
		item_id,
		'||l_outer_sql||'
  	   FROM	(SELECT	item_id,
			'||l_formula_sql||'
   		   FROM	(SELECT	f.item_id			ITEM_ID,
				'||l_inner_sql||'
		       GROUP BY	f.item_id) c)'
		||l_row_filter||'
	)		a,
	ENI_ITEM_ORG_V	items
  WHERE a.item_id = items.id
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
  ORDER BY rnk';

  ELSIF l_view_by = 'ORGANIZATION+ORGANIZATION'
    THEN l_stmt := '
SELECT	org.name 		VIEWBY,
	org.organization_id	VIEWBYID,
	null			ISC_ATTRIBUTE_1, -- Description
	'||l_outer_sql||'
  FROM	(SELECT	(rank() over (&ORDER_BY_CLAUSE NULLS LAST,organization_id))-1 RNK,
		organization_id,
		'||l_outer_sql||'
  	   FROM	(SELECT	organization_id,
			'||l_formula_sql||'
   		   FROM	(SELECT f.organization_id			ORGANIZATION_ID,
				'||l_inner_sql||'
	      	       GROUP BY	f.organization_id) c)'
		||l_row_filter||'
	)				a,
	HR_ALL_ORGANIZATION_UNITS_TL	org
  WHERE org.organization_id = a.organization_id
    AND org.language = :ISC_LANG
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
  ORDER BY rnk';

  ELSIF l_view_by = 'ITEM+ENI_ITEM_INV_CAT'
    THEN l_stmt := '
SELECT	eni.value 		VIEWBY,
	eni.id			VIEWBYID,
	null			ISC_ATTRIBUTE_1, -- Description
	'||l_outer_sql||'
  FROM	(SELECT	(rank() over (&ORDER_BY_CLAUSE NULLS LAST,item_category_id))-1 RNK,
		item_category_id,
		'||l_outer_sql||'
  	   FROM	(SELECT	item_category_id,
			'||l_formula_sql||'
   		   FROM	(SELECT	f.item_category_id		ITEM_CATEGORY_ID,
				'||l_inner_sql||'
		      GROUP BY	f.item_category_id) c)'
		||l_row_filter||'
	)			a,
	ENI_ITEM_INV_CAT_V	eni
  WHERE a.item_category_id = eni.id
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
  ORDER BY rnk';

  ELSE -- l_view_by = 'SUPPLIER+POA_SUPPLIERS'
    l_stmt := '
SELECT	decode(	sup.value, NULL,
		fnd_message.get_string(''POA'', ''POA_DBI_APL_UNASSIGNED''),
		sup.value) 	VIEWBY,
	sup.id			VIEWBYID,
	null			ISC_ATTRIBUTE_1, -- Description
	'||l_outer_sql||'
  FROM	(SELECT	(rank() over (&ORDER_BY_CLAUSE NULLS LAST,supplier_id))-1 RNK,
		supplier_id,
		'||l_outer_sql||'
  	   FROM	(SELECT	supplier_id,
			'||l_formula_sql||'
   		   FROM	(SELECT f.sr_supplier_id			SUPPLIER_ID,
				'||l_inner_sql||'
	      	       GROUP BY	f.sr_supplier_id) c)'
		||l_row_filter||'
	)			a,
	POA_SUPPLIERS_V		sup
  WHERE a.supplier_id = sup.id(+)
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
  ORDER BY rnk';

  END IF;
  END IF;

  x_custom_sql := l_stmt;

  l_custom_rec.attribute_name := ':ISC_LANG';
  l_custom_rec.attribute_value := l_lang;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
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

  l_custom_rec.attribute_name := ':ISC_ITEM_CAT_FLAG';
  l_custom_rec.attribute_value := to_char(l_item_cat_flag);
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
  x_custom_output.extend;
  x_custom_output(4) := l_custom_rec;

END Get_Sql;

END ISC_DBI_PLAN_PUR_COST_PKG ;


/
