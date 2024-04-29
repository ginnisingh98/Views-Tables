--------------------------------------------------------
--  DDL for Package Body ISC_DBI_PLAN_RM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_PLAN_RM_PKG" AS
/* $Header: ISCRGAIB.pls 120.0 2005/05/25 17:26:52 appldev noship $ */


PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt			VARCHAR2(10000);
  l_plan			VARCHAR2(10000);
  l_plan2			VARCHAR2(10000);
  l_outer_sql			VARCHAR2(10000);
  l_formula_sql			VARCHAR2(10000);
  l_inner_sql			VARCHAR2(10000);
  l_inner_select_stmt		VARCHAR2(10000);
  l_inner_group_by_stmt		VARCHAR2(10000);
  l_flags_where 		VARCHAR2(1000);
  l_mv				VARCHAR2(100);
  l_qty_select			VARCHAR2(10000);
  l_view_by			VARCHAR2(10000);
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
  l_item_cat_flag		NUMBER;
  l_lang			VARCHAR2(10);
  l_union1_flag			NUMBER := 0;
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
      IF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT')
	THEN
	  l_prod_cat_from := ',
		ENI_DENORM_HIERARCHIES		eni_cat,
		MTL_DEFAULT_CATEGORY_SETS	mdcs';
	  l_prod_cat_where := '
	    AND f.vbh_category_id = eni_cat.child_id
	    AND eni_cat.top_node_flag = ''Y''
	    AND	eni_cat.dbi_flag = ''Y''
	    AND eni_cat.object_type = ''CATEGORY_SET''
	    AND	eni_cat.object_id = mdcs.category_set_id
	    AND	mdcs.functional_area_id = 11';
	ELSE
	  l_prod_cat_from := '';
	  l_prod_cat_where := '';
      END IF;
    ELSE
      l_prod_cat_from := ',
		ENI_DENORM_HIERARCHIES		eni_cat,
		MTL_DEFAULT_CATEGORY_SETS	mdcs';
      l_prod_cat_where := '
	    AND f.vbh_category_id = eni_cat.child_id
	    AND eni_cat.parent_id IN (&ITEM+ENI_ITEM_VBH_CAT)
	    AND	eni_cat.dbi_flag = ''Y''
	    AND	eni_cat.object_type = ''CATEGORY_SET''
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
      IF (l_view_by = 'ITEM+ENI_ITEM_ORG')
	THEN l_item_cat_flag := 0; -- product
      ELSIF (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT')
        THEN l_item_cat_flag := 2; -- category
      ELSE
	IF (l_prod_cat IS NULL OR l_prod_cat = 'All')
	  THEN l_item_cat_flag := 3; -- all
	  ELSE l_item_cat_flag := 2; -- category
	END IF;
      END IF;
  ELSE
    l_item_cat_flag := 0; -- product
  END IF;

  IF (l_period_type = 'FII_TIME_ENT_PERIOD') THEN
	l_period_type_id := 32;
  ELSIF (l_period_type = 'FII_TIME_ENT_QTR') THEN
	l_period_type_id := 64;
  ELSE -- l_period_type = 'FII_TIME_ENT_YEAR'
	l_period_type_id := 128;
  END IF;

  l_lang := USERENV('LANG');

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  IF (l_plan IS NULL OR l_plan2 IS NULL)
    THEN l_stmt := '
SELECT	0	VIEWBY,
	0	VIEWBYID,
	0	ISC_ATTRIBUTE_1,
	0	ISC_ATTRIBUTE_2,
	0	ISC_ATTRIBUTE_3,
	0 	ISC_MEASURE_1,
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
	0 	ISC_MEASURE_12,
	0 	ISC_MEASURE_13,
	0 	ISC_MEASURE_14,
	0 	ISC_MEASURE_15,
	0 	ISC_MEASURE_16,
	0 	ISC_MEASURE_17,
	0 	ISC_MEASURE_18,
	0 	ISC_MEASURE_19,
	0 	ISC_MEASURE_20,
	0 	ISC_MEASURE_21,
	0 	ISC_MEASURE_22,
	0 	ISC_MEASURE_23,
	0 	ISC_MEASURE_24
  FROM	dual
 WHERE	1 = 2 /* PLAN_SNAPSHOT dimension has not been populated */';
    ELSE

  IF ((l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') AND
      (l_prod_cat IS NULL OR l_prod_cat = 'All'))
    THEN
	l_inner_select_stmt := 'SELECT eni_cat.parent_id			VBH_CATEGORY_ID,';
	l_inner_group_by_stmt := '
	      GROUP BY eni_cat.parent_id';
    ELSE
	l_inner_select_stmt := 'SELECT eni_cat.imm_child_id			VBH_CATEGORY_ID,';
	l_inner_group_by_stmt := '
	      GROUP BY eni_cat.imm_child_id';
  END IF;

  IF ((l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') AND
      (l_prod_cat IS NULL OR l_prod_cat = 'All') AND
      (l_prod IS NULL OR l_prod = 'All'))
    THEN
	l_inner_select_stmt := 'SELECT f.parent_id			VBH_CATEGORY_ID,';
	l_inner_group_by_stmt := '
	      GROUP BY f.parent_id';
	l_prod_cat_from := '';
	l_prod_cat_where := '';
	l_mv := 'ISC_DBI_PM_0003_MV';
	l_flags_where := '';
    ELSE
  	l_mv := 'ISC_DBI_PM_0001_MV';
  	l_flags_where := '
	    AND f.item_cat_flag = :ISC_ITEM_CAT_FLAG
	    AND f.union1_flag <> :ISC_UNION1_FLAG';
  END IF;

  IF l_view_by = 'ITEM+ENI_ITEM_ORG'
    THEN l_qty_select := '
		sum(decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
			   f.mds_quantity, 0))		QTY,';
    ELSE l_qty_select := '
		null					QTY,';
  END IF;

-- Filter out rows with only 0 or N/A
  l_row_filter := '
	WHERE (ISC_MEASURE_2 IS NOT NULL AND ISC_MEASURE_2 <> 0)
	   OR (ISC_MEASURE_3 IS NOT NULL AND ISC_MEASURE_3 <> 0)
	   OR (ISC_MEASURE_5 IS NOT NULL AND ISC_MEASURE_5 <> 0)
	   OR (ISC_MEASURE_6 IS NOT NULL AND ISC_MEASURE_6 <> 0)';

  l_outer_sql:= 'ISC_MEASURE_1, ISC_MEASURE_2, ISC_MEASURE_3, ISC_MEASURE_4, ISC_MEASURE_5, ISC_MEASURE_6,
	ISC_MEASURE_7, ISC_MEASURE_8, ISC_MEASURE_9, ISC_MEASURE_10, ISC_MEASURE_11, ISC_MEASURE_12,
	ISC_MEASURE_13, ISC_MEASURE_14, ISC_MEASURE_15, ISC_MEASURE_16, ISC_MEASURE_17, ISC_MEASURE_18,
	ISC_MEASURE_19, ISC_MEASURE_20, ISC_MEASURE_21, ISC_MEASURE_22, ISC_MEASURE_23, ISC_MEASURE_24';

  l_formula_sql := '
	c.qty					ISC_MEASURE_1, -- Shipment Quantity
	c.rev					ISC_MEASURE_2, -- Revenue
	c.comp_rev				ISC_MEASURE_3, -- Compare Plan (Revenue)
	(c.rev - c.comp_rev)			ISC_MEASURE_4, -- Variance (Revenue)
	c.cost					ISC_MEASURE_5, -- Cost
	c.comp_cost				ISC_MEASURE_6, -- Compare Plan (Cost)
	(c.cost - c.comp_cost)			ISC_MEASURE_7, -- Variance (Cost)
	(c.rev - c.cost)			ISC_MEASURE_8, -- Margin
	(c.comp_rev - c.comp_cost)		ISC_MEASURE_9, -- Compare Plan (Margin)
	(c.rev - c.cost)
	  - (c.comp_rev - c.comp_cost)		ISC_MEASURE_10, -- Variance (Margin)
	(c.rev - c.cost)
	 / decode(c.rev,0,NULL,c.rev) * 100	ISC_MEASURE_11, -- Margin Percent
	(c.comp_rev - c.comp_cost) / decode(c.comp_rev,0,NULL,c.comp_rev) * 100
						ISC_MEASURE_12, -- Compare Plan (Margin Percent)
	((c.rev - c.cost) / decode(c.rev,0,NULL,c.rev) * 100)
	  - ((c.comp_rev - c.comp_cost) / decode(c.comp_rev,0,NULL,c.comp_rev) * 100)
						ISC_MEASURE_13, -- Variance (Margin Percent)
	sum(c.rev) over ()			ISC_MEASURE_14, -- Grand Total - Revenue
	sum((c.rev - c.comp_rev)) over ()	ISC_MEASURE_15, -- Grand Total - Variance (Revenue)
	sum(c.cost) over ()			ISC_MEASURE_16, -- Grand Total - Cost
	sum(c.cost - c.comp_cost) over ()	ISC_MEASURE_17, -- Grand Total - Variance (Cost)
	sum((c.rev - c.cost)) over ()		ISC_MEASURE_18, -- Grand Total - Margin
	sum((c.rev - c.cost) - (c.comp_rev - c.comp_cost)) over ()
						ISC_MEASURE_19, -- Grand Total - Variance (Margin)
	sum(c.rev - c.cost) over ()
	 / decode(sum(c.rev) over (),0,NULL,sum(c.rev) over ()) * 100
						ISC_MEASURE_20, -- Grand Total - Margin Percent
	(sum(c.rev - c.cost) over ()
	   / decode(sum(c.rev) over (),0,NULL,sum(c.rev) over ()) * 100)
	 - (sum(c.comp_rev - c.comp_cost) over ()
	     / decode(sum(c.comp_rev) over (),0,NULL,sum(c.comp_rev) over ()) * 100)
						ISC_MEASURE_21, -- Grand Total - Variance (Margin Percent)
	sum(c.comp_rev)	over ()			ISC_MEASURE_22, -- Grand Total - Compare Revenue
	sum(c.comp_rev - c.comp_cost) over ()	ISC_MEASURE_23, -- Grand Total - Compare Margin
	sum(c.comp_rev - c.comp_cost) over ()
	 / decode(sum(c.comp_rev) over (),0,NULL,sum(c.comp_rev) over ()) * 100
						ISC_MEASURE_24 -- Grand Total - Compare Margin Percent';

  l_inner_sql := l_qty_select||'
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
	  WHERE	f.start_date = :ISC_TIME_FROM
	    AND	f.period_type_id =:ISC_PERIOD_TYPE_ID
	    AND f.snapshot_id IN (&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2)'
		||l_flags_where
		||l_org_where
		||l_prod_cat_where
		||l_prod_where;

  IF l_view_by = 'ITEM+ENI_ITEM_ORG'
    THEN l_stmt := '
SELECT	items.value		VIEWBY,
	items.id		VIEWBYID,
	null		 	ISC_ATTRIBUTE_1, -- drill across URL
	items.description	ISC_ATTRIBUTE_2, -- Description
	mtl.unit_of_measure	ISC_ATTRIBUTE_3, -- UOM
	'||l_outer_sql||'
  FROM	(SELECT	(rank() over (&ORDER_BY_CLAUSE NULLS LAST,item_id))-1 RNK,
	item_id, uom,
	'||l_outer_sql||'
    FROM (SELECT c.item_id, c.uom,'
	 ||l_formula_sql||'
     FROM (SELECT f.item_id				ITEM_ID,
		  f.uom_code				UOM,'
	   ||l_inner_sql||'
	      GROUP BY f.item_id, f.uom_code) c)'
		||l_row_filter||'
	   OR (ISC_MEASURE_1 IS NOT NULL AND ISC_MEASURE_1 <> 0)
	)			a,
	ENI_ITEM_ORG_V		items,
	MTL_UNITS_OF_MEASURE_TL	mtl
  WHERE a.item_id = items.id
    AND a.uom = mtl.uom_code
    AND mtl.language = :ISC_LANG
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
  ORDER BY rnk';

  ELSIF l_view_by = 'ORGANIZATION+ORGANIZATION'
    THEN l_stmt := '
SELECT	org.name 		VIEWBY,
	org.organization_id	VIEWBYID,
	null			ISC_ATTRIBUTE_1, -- drill across URL
	null			ISC_ATTRIBUTE_2, -- Description
	null			ISC_ATTRIBUTE_3, -- UOM
	'||l_outer_sql||'
  FROM	(SELECT	(rank() over (&ORDER_BY_CLAUSE NULLS LAST,organization_id))-1 RNK,
	organization_id,
	'||l_outer_sql||'
    FROM (SELECT c.organization_id,'
	  ||l_formula_sql||'
   	FROM (SELECT f.organization_id			ORGANIZATION_ID,'
	      ||l_inner_sql||'
	      GROUP BY f.organization_id) c)'
		||l_row_filter||'
	)				a,
	HR_ALL_ORGANIZATION_UNITS_TL	org
  WHERE org.organization_id = a.organization_id
    AND org.language = :ISC_LANG
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
  ORDER BY rnk';

  ELSE -- l_view_by = 'ITEM+ENI_ITEM_VBH_CAT'
    l_stmt := '
SELECT	eni.value 		VIEWBY,
	eni.id			VIEWBYID,
	decode(eni.leaf_node_flag, ''Y'',
		''pFunctionName=ISC_DBI_PLAN_RM&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_ORG&pParamIds=Y'',
		''pFunctionName=ISC_DBI_PLAN_RM&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&pParamIds=Y'')
				ISC_ATTRIBUTE_1, -- drill across URL
	null			ISC_ATTRIBUTE_2, -- Description
	null			ISC_ATTRIBUTE_3, -- UOM
	'||l_outer_sql||'
  FROM	(SELECT	(rank() over (&ORDER_BY_CLAUSE NULLS LAST,vbh_category_id))-1 RNK,
	vbh_category_id,
	'||l_outer_sql||'
    FROM (SELECT c.vbh_category_id,'
	  ||l_formula_sql||'
   	FROM ('||l_inner_select_stmt
	       ||l_inner_sql
	       ||l_inner_group_by_stmt||') c)'
		||l_row_filter||'
	)			a,
	ENI_ITEM_VBH_NODES_V	eni
  WHERE a.vbh_category_id = eni.id
    AND	eni.parent_id = eni.child_id
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
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.Bind_Type;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.Integer_Bind;
  x_custom_output.extend;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_UNION1_FLAG';
  l_custom_rec.attribute_value := to_char(l_union1_flag);
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.Bind_Type;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.Integer_Bind;
  x_custom_output.extend;
  x_custom_output(5) := l_custom_rec;

END Get_Sql;

END ISC_DBI_PLAN_RM_PKG ;


/
