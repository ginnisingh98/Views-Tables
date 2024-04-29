--------------------------------------------------------
--  DDL for Package Body ISC_DBI_PLAN_OT_SHIP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_PLAN_OT_SHIP_PKG" AS
/* $Header: ISCRGASB.pls 120.1 2006/06/26 06:35:58 abhdixi noship $ */


PROCEDURE GET_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,x_custom_sql OUT NOCOPY VARCHAR2,
	x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt 		VARCHAR2(32000);
  l_plan		VARCHAR2(10000);
  l_plan2		VARCHAR2(10000);
  l_inner_sql		VARCHAR2(32000);
  l_view_by		VARCHAR2(32000);
  l_org 		VARCHAR2(32000);
  l_org_where     	VARCHAR2(32000);
  l_period_type		VARCHAR2(1000);
  l_inv_cat		VARCHAR2(32000);
  l_item		VARCHAR2(32000);
  l_inv_cat_where	VARCHAR2(32000);
  l_item_where		VARCHAR2(32000);
  l_item_cat_flag	NUMBER; -- 0 for item, 1 for inv.cat, 3 for all
  l_time_from		DATE;
  l_period_type_id	NUMBER;
  l_lang		varchar2(10);
  l_viewby_id		varchar2(100);
  l_custom_rec 		BIS_QUERY_ATTRIBUTES ;



BEGIN

  FOR i IN 1..p_param.COUNT
  LOOP
    IF (p_param(i).parameter_name = 'PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT')
      THEN l_plan := p_param(i).parameter_value;
    END IF;

    IF (p_param(i).parameter_name = 'PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2')
      THEN l_plan2 := p_param(i).parameter_value;
    END IF;

    IF( p_param(i).parameter_name= 'VIEW_BY')
      THEN l_view_by := p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION')
      THEN l_org :=  p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'PERIOD_TYPE') THEN
       l_period_type :=  p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_INV_CAT') THEN
       l_inv_cat :=  p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_ORG') THEN
       l_item :=  p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_FROM') THEN
       l_time_from :=  p_param(i).period_date;
    END IF;

    IF(p_param(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM') THEN
       l_time_from :=  p_param(i).period_date;
    END IF;

    IF(p_param(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM') THEN
       l_time_from :=  p_param(i).period_date;
    END IF;


  END LOOP;


    IF ( l_org IS NULL OR l_org = 'All' ) THEN
    l_org_where := '
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

  ELSE
    l_org_where := '
		AND f.organization_id =(&ORGANIZATION+ORGANIZATION)';
  END IF;


  IF ( l_inv_cat IS NULL OR l_inv_cat = 'All' ) THEN
    l_inv_cat_where :='';
  ELSE
    l_inv_cat_where := '
	AND f.inv_category_id in (&ITEM+ENI_ITEM_INV_CAT)';
  END IF;


  IF ( l_item IS NULL OR l_item = 'All' )
  THEN l_item_where := '';
  ELSE l_item_where := '
	AND f.item_id in (&ITEM+ENI_ITEM_ORG)';
  END IF;

  IF (l_item IS NULL OR l_item = 'All')
    THEN
      IF (l_view_by = 'ITEM+ENI_ITEM_ORG')
	THEN l_item_cat_flag := 0; -- item
      ELSIF (l_view_by = 'ITEM+ENI_ITEM_INV_CAT')
        THEN l_item_cat_flag := 1; -- category
      ELSE
	IF (l_inv_cat IS NULL OR l_inv_cat = 'All')
	  THEN l_item_cat_flag := 3; -- all
	ELSE l_item_cat_flag := 1; -- category
	END IF;
      END IF;
  ELSE
    l_item_cat_flag := 0; -- item
  END IF;




  l_lang := USERENV('LANG');

  IF l_view_by = 'ORGANIZATION+ORGANIZATION' THEN
    l_viewby_id :='organization_id';

  ELSIF l_view_by = 'ITEM+ENI_ITEM_ORG' THEN
    l_viewby_id :='item_id';

  ELSIF l_view_by = 'ITEM+ENI_ITEM_INV_CAT' THEN
    l_viewby_id :='inv_category_id';

  END if;


  IF l_period_type = 'FII_TIME_ENT_YEAR' THEN
   l_period_type_id := 128;

  ELSIF (l_period_type='FII_TIME_ENT_QTR') THEN
   l_period_type_id := 64;

  ELSE
   l_period_type_id := 32;

  END IF;


  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();


  IF (l_plan IS NULL OR l_plan2 IS NULL)
    THEN l_stmt := '
SELECT	0	VIEWBY,
	0	VIEWBYID,
	0	ISC_ATTRIBUTE_1,
	0 	ISC_MEASURE_7,
	0 	ISC_MEASURE_8,
	0 	ISC_MEASURE_1,
	0 	ISC_MEASURE_2,
	0 	ISC_MEASURE_3,
	0 	ISC_MEASURE_4,
	0 	ISC_MEASURE_5,
	0 	ISC_MEASURE_6,
	0 	ISC_MEASURE_9,
	0 	ISC_MEASURE_10
  FROM	dual
 WHERE	1 = 2 /* PLAN_SNAPSHOT dimension has not been populated */';
    ELSE

  l_inner_sql:='ISC_MEASURE_7,ISC_MEASURE_8,ISC_MEASURE_1,ISC_MEASURE_2,ISC_MEASURE_3,
		ISC_MEASURE_4,ISC_MEASURE_5,
		ISC_MEASURE_4-ISC_MEASURE_5 ISC_MEASURE_6,
		ISC_MEASURE_9,ISC_MEASURE_10
		FROM(select (rank() over (&ORDER_BY_CLAUSE nulls last,viewby_id))-1 rnk,
		viewby_id,
		ISC_MEASURE_1,ISC_MEASURE_2,ISC_MEASURE_3,
		sum(ISC_MEASURE_7) over ()/decode(sum(ISC_MEASURE_8) over(),0,null,
		sum(ISC_MEASURE_8) over())*100	ISC_MEASURE_4,
		sum(comp_ontime_total) over ()/decode(sum(comp_total_lines) over(),0,null,
		sum(comp_total_lines) over())*100	ISC_MEASURE_5,
		ISC_MEASURE_7, ISC_MEASURE_8,
		sum(ISC_MEASURE_7) over () ISC_MEASURE_9,
		sum(ISC_MEASURE_8) over () ISC_MEASURE_10
		FROM(select s.viewby_id,
		sum(s.plan_ontime_lines)/decode(sum(s.plan_total_lines),0,null,
			sum(s.plan_total_lines))*100	ISC_MEASURE_1,
		sum(s.comp_ontime_lines)/decode(sum(s.comp_total_lines),0,null,
			sum(s.comp_total_lines))*100	ISC_MEASURE_2,
		(sum(s.plan_ontime_lines)/decode(sum(s.plan_total_lines),0,null,
			sum(s.plan_total_lines)))*100-
		(sum(s.comp_ontime_lines)/decode(sum(s.comp_total_lines),0,null,
			sum(s.comp_total_lines)))*100	ISC_MEASURE_3,
		sum(s.plan_ontime_lines) 		ISC_MEASURE_7,
		sum(s.plan_total_lines)			ISC_MEASURE_8,
		sum(s.comp_ontime_lines)		comp_ontime_total,
		sum(s.comp_total_lines)			comp_total_lines
		FROM
		(SELECT f.'||l_viewby_id||'	VIEWBY_ID,
		decode(f.snapshot_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
		sum(f.total_lines)-sum(f.late_lines),null)		plan_ontime_lines,
		decode(f.snapshot_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
		sum(f.total_lines),null)				plan_total_lines,
		decode(f.snapshot_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
		sum(f.total_lines)-sum(f.late_lines),null)		comp_ontime_lines,
		decode(f.snapshot_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
		sum(f.total_lines),null)				comp_total_lines
		FROM
		ISC_DBI_PM_0001_MV f
		WHERE f.start_date = :ISC_CUR_START
		AND f.period_type_id = :ISC_PERIOD_TYPE_ID
		AND f.union2_flag <> 0
		AND f.item_cat_flag = :ISC_ITEM_CAT_FLAG
		AND f.snapshot_id in (&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2)
		'||l_org_where||l_inv_cat_where||l_item_where||
		'GROUP BY f.'||l_viewby_id||',f.snapshot_id) s
		GROUP BY s.viewby_id)
		WHERE (ISC_MEASURE_7 <>0 OR ISC_MEASURE_8 <>0)
		OR (comp_ontime_total <>0 OR comp_total_lines <>0)) a,';

  IF l_view_by = 'ORGANIZATION+ORGANIZATION' THEN
    l_stmt := 'SELECT org.name		VIEWBY,
		org.organization_id	VIEWBYID,
		null			ISC_ATTRIBUTE_1,
		'||l_inner_sql||'
		HR_ALL_ORGANIZATION_UNITS_TL org
		WHERE org.organization_id = a.viewby_id
		AND org.language = :ISC_LANG
		AND ((a.rnk between &START_INDEX and &END_INDEX) OR &END_INDEX=-1)
		ORDER BY rnk';

  ELSIF l_view_by = 'ITEM+ENI_ITEM_ORG' THEN
    l_stmt :='SELECT items.value	VIEWBY,
		items.id		VIEWBYID,
		items.description	ISC_ATTRIBUTE_1,
		'||l_inner_sql||'
		ENI_ITEM_ORG_V items
  		WHERE a.viewby_id = items.id
		AND ((a.rnk between &START_INDEX and &END_INDEX) OR &END_INDEX=-1)
		ORDER BY rnk';

  ELSIF l_view_by = 'ITEM+ENI_ITEM_INV_CAT' THEN
    l_stmt := 'SELECT 	ecat.value 	VIEWBY,
		ecat.id			VIEWBYID,
		null			ISC_ATTRIBUTE_1,
		'||l_inner_sql||'
 		ENI_ITEM_INV_CAT_V 	ecat
		WHERE a.viewby_id = ecat.id
		AND ((a.rnk between &START_INDEX and &END_INDEX) OR &END_INDEX=-1)
  		ORDER BY rnk';
  END IF;
  END IF;

  x_custom_sql := l_stmt;

  l_custom_rec.attribute_name := ':ISC_PERIOD_TYPE_ID';
  l_custom_rec.attribute_value := to_char(l_period_type_id);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_CUR_START';
  l_custom_rec.attribute_value := to_char(l_time_from,'DD/MM/YYYY');
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_LANG';
  l_custom_rec.attribute_value := l_lang;
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_ITEM_CAT_FLAG';
  l_custom_rec.attribute_value := to_char(l_item_cat_flag);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;


END get_sql;

END ISC_DBI_PLAN_OT_SHIP_PKG ;


/
