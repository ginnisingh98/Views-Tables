--------------------------------------------------------
--  DDL for Package Body ISC_DBI_PLAN_RES_UT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_PLAN_RES_UT_PKG" AS
/* $Header: ISCRGAUB.pls 120.1 2006/06/26 06:37:55 abhdixi noship $ */


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
  l_res			VARCHAR2(32000);
  l_res_group		VARCHAR2(32000);
  l_res_dept		VARCHAR2(32000);
  l_res_where		VARCHAR2(32000);
  l_res_group_where	VARCHAR2(32000);
  l_res_dept_where	VARCHAR2(32000);
  l_res_gp_flag		NUMBER; -- 0 for resource, 1 for dept,2 for res.group, 3 for all
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

    IF(p_param(i).parameter_name = 'RESOURCE+ENI_RESOURCE') THEN
       l_res :=  p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'RESOURCE+ENI_RESOURCE_GROUP') THEN
       l_res_group :=  p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'RESOURCE+ENI_RESOURCE_DEPARTMENT') THEN
       l_res_dept :=  p_param(i).parameter_value;
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


  IF ( l_res IS NULL OR l_res = 'All' ) THEN
    l_res_where :='';
  ELSE
    l_res_where := '
	AND f.resource_id in (&RESOURCE+ENI_RESOURCE)';
  END IF;


  IF ( l_res_group IS NULL OR l_res_group = 'All' )
  THEN l_res_group_where := '';
  ELSE l_res_group_where := '
	AND f.resource_group_id in (&RESOURCE+ENI_RESOURCE_GROUP)';
  END IF;

  IF ( l_res_dept IS NULL OR l_res_dept = 'All' )
  THEN l_res_dept_where := '';
  ELSE l_res_dept_where := '
	AND f.department_id in (&RESOURCE+ENI_RESOURCE_DEPARTMENT)';
  END IF;


  IF (l_view_by = 'RESOURCE+ENI_RESOURCE')
	THEN l_res_gp_flag := 0; -- resource

  ELSIF (l_view_by = 'RESOURCE+ENI_RESOURCE_DEPARTMENT') THEN
        IF ((l_res IS NULL OR l_res = 'All') AND (l_res_group IS NULL OR l_res_group='All'))
	THEN l_res_gp_flag := 1; -- dept
	ELSE
	     l_res_gp_flag :=0;
	END IF;

  ELSIF (l_view_by = 'RESOURCE+ENI_RESOURCE_GROUP') THEN
	IF ((l_res IS NULL OR l_res = 'All') AND (l_res_dept IS NULL OR l_res_dept='All'))
	THEN l_res_gp_flag := 2; -- res.group
	ELSE
	     l_res_gp_flag :=0;
	END IF;

  ELSE -- view by org
    	IF ((l_res IS NULL OR l_res = 'All') AND (l_res_dept IS NULL OR l_res_dept='All')
		AND (l_res_group IS NULL OR l_res_group='All'))
		THEN l_res_gp_flag := 3; -- all

	ELSIF((l_res IS NULL OR l_res = 'All') AND (l_res_dept IS NULL OR l_res_dept='All'))
		THEN l_res_gp_flag := 2; -- res.group

	ELSIF((l_res IS NULL OR l_res = 'All') AND (l_res_group IS NULL OR l_res_group='All'))
		THEN l_res_gp_flag :=1; --dept

	ELSE
		l_res_gp_flag :=0; --resource
	END IF;

  END IF;


  l_lang := USERENV('LANG');

  IF l_view_by = 'ORGANIZATION+ORGANIZATION' THEN
    l_viewby_id :='organization_id';

  ELSIF l_view_by = 'RESOURCE+ENI_RESOURCE_GROUP' THEN
    l_viewby_id :='resource_group_id';

  ELSIF l_view_by = 'RESOURCE+ENI_RESOURCE_DEPARTMENT' THEN
    l_viewby_id :='department_id';

  ELSIF l_view_by = 'RESOURCE+ENI_RESOURCE' THEN
    l_viewby_id :='resource_id';

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

  l_inner_sql:='ISC_MEASURE_7,ISC_MEASURE_8,ISC_MEASURE_1,ISC_MEASURE_2,
		ISC_MEASURE_3, ISC_MEASURE_4,ISC_MEASURE_5,
		ISC_MEASURE_4-ISC_MEASURE_5 ISC_MEASURE_6,
		ISC_MEASURE_9,ISC_MEASURE_10
		FROM(select (rank() over (&ORDER_BY_CLAUSE nulls last,viewby_id))-1 rnk,
		viewby_id,
		ISC_MEASURE_1,ISC_MEASURE_2,ISC_MEASURE_3,
		sum(ISC_MEASURE_7) over()/decode(sum(ISC_MEASURE_8) over(),0,null,
			sum(ISC_MEASURE_8)over())*100	ISC_MEASURE_4,
		sum(comp_required_hr_total) over()/decode(sum(comp_available_hr_total) over(),0,null,
			sum(comp_available_hr_total)over())*100	ISC_MEASURE_5,
		ISC_MEASURE_7, ISC_MEASURE_8,
		sum(ISC_MEASURE_7) over () ISC_MEASURE_9,
		sum(ISC_MEASURE_8) over () ISC_MEASURE_10
		FROM(select s.viewby_id,
		sum(s.plan_required_hr)/decode(sum(s.plan_available_hr),0,null,
			sum(s.plan_available_hr))*100		ISC_MEASURE_1,
		sum(s.comp_required_hr)/decode(sum(s.comp_available_hr),0,null,
			sum(s.comp_available_hr))*100		ISC_MEASURE_2,
		(sum(s.plan_required_hr)/decode(sum(s.plan_available_hr),0,null,
			sum(s.plan_available_hr)))*100-
		(sum(s.comp_required_hr)/decode(sum(s.comp_available_hr),0,null,
			sum(s.comp_available_hr)))*100		ISC_MEASURE_3,
		sum(s.plan_required_hr) 		ISC_MEASURE_7,
		sum(s.plan_available_hr) 		ISC_MEASURE_8,
		sum(s.comp_required_hr)			comp_required_hr_total,
		sum(s.comp_available_hr) 		comp_available_hr_total
		FROM
		(SELECT f.'||l_viewby_id||'	VIEWBY_ID,
		decode(f.snapshot_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
		sum(f.required_hours),null)	plan_required_hr,
		decode(f.snapshot_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
		sum(f.available_hours),null)	plan_available_hr,
		decode(f.snapshot_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
		sum(f.required_hours),null)	comp_required_hr,
		decode(f.snapshot_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
		sum(f.available_hours),null)	comp_available_hr
		FROM
		ISC_DBI_PM_0002_MV f
		WHERE f.start_date = :ISC_CUR_START
		AND f.period_type_id = :ISC_PERIOD_TYPE_ID
		AND f.res_gp_flag =:ISC_RES_GP_FLAG
		AND f.snapshot_id in (&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2)'
		||l_org_where||l_res_where||l_res_group_where||l_res_dept_where||
		'GROUP BY f.'||l_viewby_id||',f.snapshot_id) s
		GROUP BY s.viewby_id)
		WHERE (ISC_MEASURE_7<>0 OR ISC_MEASURE_8<>0)
		OR (comp_required_hr_total <>0 OR comp_available_hr_total <>0)) a,';


  IF l_view_by = 'ORGANIZATION+ORGANIZATION' THEN
    l_stmt := 'SELECT org.name		VIEWBY,
		org.organization_id	VIEWBYID,
		'||l_inner_sql||'
		HR_ALL_ORGANIZATION_UNITS_TL org
		WHERE org.organization_id = a.viewby_id
		AND org.language = :ISC_LANG
		AND ((a.rnk between &START_INDEX and &END_INDEX) OR &END_INDEX=-1)
		ORDER BY rnk';

  ELSIF l_view_by = 'RESOURCE+ENI_RESOURCE' THEN
    l_stmt :='SELECT res.value	VIEWBY,
		res.id		VIEWBYID,
		'||l_inner_sql||'
		ENI_RESOURCE_V res
  		WHERE a.viewby_id = res.id
		AND ((a.rnk between &START_INDEX and &END_INDEX) OR &END_INDEX=-1)
		ORDER BY rnk';

  ELSIF l_view_by = 'RESOURCE+ENI_RESOURCE_DEPARTMENT' THEN
    l_stmt := 'SELECT 	res.value 	VIEWBY,
		res.id			VIEWBYID,
		'||l_inner_sql||'
 		ENI_RESOURCE_DEPARTMENT_V 	res
		WHERE a.viewby_id = res.id
		AND ((a.rnk between &START_INDEX and &END_INDEX) OR &END_INDEX=-1)
  		ORDER BY rnk';

  ELSE -- l_view_by = 'RESOURCE+ENI_RESOURCE_GROUP'
    l_stmt := 'SELECT 	res.value 	VIEWBY,
		res.id			VIEWBYID,
		'||l_inner_sql||'
 		ENI_RESOURCE_GROUP_V 	res
		WHERE a.viewby_id = res.id
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

  l_custom_rec.attribute_name := ':ISC_RES_GP_FLAG';
  l_custom_rec.attribute_value := to_char(l_res_gp_flag);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;


END get_sql;

END ISC_DBI_PLAN_RES_UT_PKG ;


/
