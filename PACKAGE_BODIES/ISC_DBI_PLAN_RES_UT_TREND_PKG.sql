--------------------------------------------------------
--  DDL for Package Body ISC_DBI_PLAN_RES_UT_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_PLAN_RES_UT_TREND_PKG" AS
/* $Header: ISCRGAVB.pls 115.4 2004/04/23 23:36:41 chu noship $ */


PROCEDURE GET_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,x_custom_sql OUT NOCOPY VARCHAR2,
	x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt 		VARCHAR2(32000);
  l_plan		VARCHAR2(10000);
  l_plan2		VARCHAR2(10000);
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
  l_time_to		DATE;
  l_cur_start		DATE;
  l_cur_end		DATE;
  l_period_type_id	NUMBER;
  l_loop		NUMBER;
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

    IF(p_param(i).parameter_name = 'TIME+FII_TIME_ENT_PERIOD_TO') THEN
       l_time_to :=  p_param(i).period_date;
    END IF;

    IF(p_param(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_FROM') THEN
       l_time_from :=  p_param(i).period_date;
    END IF;

    IF(p_param(i).parameter_name = 'TIME+FII_TIME_ENT_QTR_TO') THEN
       l_time_to :=  p_param(i).period_date;
    END IF;

    IF(p_param(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_FROM') THEN
       l_time_from :=  p_param(i).period_date;
    END IF;

    IF(p_param(i).parameter_name = 'TIME+FII_TIME_ENT_YEAR_TO') THEN
       l_time_to :=  p_param(i).period_date;
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


  IF((l_res IS NULL OR l_res = 'All') AND (l_res_dept IS NULL OR l_res_dept='All')
		AND (l_res_group IS NULL OR l_res_group='All'))
	THEN l_res_gp_flag := 3; -- all
  ELSIF ((l_res IS NULL OR l_res = 'All') AND (l_res_dept IS NULL OR l_res_dept='All') )
	THEN l_res_gp_flag := 2; -- res.group

  ELSIF((l_res IS NULL OR l_res = 'All') AND (l_res_group IS NULL OR l_res_group='All'))
	THEN l_res_gp_flag :=1; --dept
  ELSE
	l_res_gp_flag :=0; -- resource
  END IF;


  IF l_period_type = 'FII_TIME_ENT_YEAR' THEN
   l_loop :=3;
   l_period_type_id := 128;

  ELSIF (l_period_type='FII_TIME_ENT_QTR') THEN
   l_loop := 7;
   l_period_type_id := 64;

  ELSE
   l_loop :=11;
   l_period_type_id := 32;

  END IF;


  l_cur_start := l_time_from;
  l_cur_end := l_time_from;

  FOR i IN 1..l_loop
  LOOP
    l_cur_end := FII_TIME_API.next_period_end_date(l_cur_end, l_period_type);
  END LOOP;


  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  IF (l_plan IS NULL OR l_plan2 IS NULL)
    THEN l_stmt := '
SELECT	0 	ISC_MEASURE_1,
	0 	ISC_MEASURE_2,
	0 	ISC_MEASURE_3
  FROM	dual
 WHERE	1 = 2 /* PLAN_SNAPSHOT dimension has not been populated */';
    ELSE

  l_stmt:='SELECT s.period_name					VIEWBY,
		sum(s.plan_required_hr)/decode(sum(s.plan_available_hr),
			0,null,sum(s.plan_available_hr))*100		ISC_MEASURE_1,
		sum(s.comp_required_hr)/decode(sum(s.comp_available_hr),
			0,null,sum(s.comp_available_hr))*100		ISC_MEASURE_2,
		(sum(s.plan_required_hr)/decode(sum(s.plan_available_hr),
			0,null,sum(s.plan_available_hr)))*100-
		(sum(s.comp_required_hr)/decode(sum(s.comp_available_hr),
			0,null,sum(s.comp_available_hr)))*100		ISC_MEASURE_3
		FROM(
		SELECT time.start_date		PERIOD_ID,
		time.name			PERIOD_NAME,
		decode(f.snapshot_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
		sum(f.required_hours),null)	plan_required_hr,
		decode(f.snapshot_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
		sum(f.available_hours),null)	plan_available_hr,
		decode(f.snapshot_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
		sum(f.required_hours),null)	comp_required_hr,
		decode(f.snapshot_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
		sum(f.available_hours),null)	comp_available_hr
		FROM
		(SELECT start_date,name
		 FROM '||l_period_type||'
		 WHERE start_date between :ISC_CUR_START and :ISC_CUR_END) time
		LEFT OUTER JOIN
		ISC_DBI_PM_0002_MV f
		ON f.start_date = time.start_date
		AND f.period_type_id = :ISC_PERIOD_TYPE_ID
		AND f.res_gp_flag = :ISC_RES_GP_FLAG
		AND f.snapshot_id in (&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2)
		'||l_org_where||l_res_group_where||l_res_dept_where||l_res_where||
		'GROUP BY time.name,time.start_date,f.snapshot_id) s
		GROUP BY s.period_name,s.period_id
		ORDER BY s.period_id';

  END IF;

  x_custom_sql := l_stmt;

  l_custom_rec.attribute_name := ':ISC_PERIOD_TYPE_ID';
  l_custom_rec.attribute_value := to_char(l_period_type_id);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_CUR_START';
  l_custom_rec.attribute_value := to_char(l_cur_start,'DD/MM/YYYY');
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_CUR_END';
  l_custom_rec.attribute_value := to_char(l_cur_end,'DD/MM/YYYY');
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_RES_GP_FLAG';
  l_custom_rec.attribute_value := to_char(l_res_gp_flag);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
  l_custom_rec.attribute_value := 'TIME+'||l_period_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;

END get_sql;

END ISC_DBI_PLAN_RES_UT_TREND_PKG ;


/
