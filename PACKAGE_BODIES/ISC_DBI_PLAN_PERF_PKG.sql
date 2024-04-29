--------------------------------------------------------
--  DDL for Package Body ISC_DBI_PLAN_PERF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_PLAN_PERF_PKG" AS
/* $Header: ISCRGAPB.pls 120.1 2006/06/01 06:37:09 achandak noship $ */


PROCEDURE GET_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,x_custom_sql OUT NOCOPY VARCHAR2,
	x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt 		VARCHAR2(32000);
  l_plan		VARCHAR2(10000);
  l_plan2		VARCHAR2(10000);
  l_inner_sql	 	VARCHAR2(32000);
  l_org 		VARCHAR2(300);
  l_org_where     	VARCHAR2(32000);
  l_period_type		VARCHAR2(1000);
  l_cur_start		DATE;
  l_cur_end		DATE;
  l_pre_start		DATE;
  l_pre_end		DATE;
  l_time_from		DATE;
  l_time_to		DATE;
  l_mon_period_id	NUMBER:=32; --only select month buckets
  l_period_type_id	NUMBER;
  l_lang		varchar2(10);
  l_item_cat_flag	NUMBER:=3; -- no grouping on item dimension
  l_res_gp_flag		NUMBER :=3; -- no grouping on resource dimension
  l_union_flag		NUMBER:=0; -- for inventory turns report
  l_mon_num		NUMBER; -- number of months in the selected period
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
	WHERE (EXISTS
		(SELECT 1
		FROM org_access o
		WHERE o.responsibility_id = fnd_global.resp_id
		AND o.resp_application_id = fnd_global.resp_appl_id
		AND o.organization_id = c.viewby_id)
		OR EXISTS
		(SELECT 1
		FROM mtl_parameters org
		WHERE org.organization_id = c.viewby_id
		AND NOT EXISTS
			(SELECT 1
			FROM org_access ora
			WHERE org.organization_id = ora.organization_id)))';

  ELSE
    l_org_where := '
		WHERE c.viewby_id = (&ORGANIZATION+ORGANIZATION)';
  END IF;


  IF l_period_type = 'FII_TIME_ENT_YEAR' THEN
   l_period_type_id := 128;
   l_mon_num :=12;

  ELSIF (l_period_type='FII_TIME_ENT_QTR') THEN
   l_period_type_id := 64;
   l_mon_num :=3;

  ELSE
   l_period_type_id := 32;
   l_mon_num :=1;

  END IF;


  l_cur_start := l_time_from;
  l_cur_end := l_time_to;
  l_pre_start := FII_TIME_API.ent_pper_start(l_time_from); -- get the previous month
  l_pre_end := FII_TIME_API.ent_pper_end(l_time_to); -- get the previous month

  l_lang := USERENV('LANG');

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();


  IF (l_plan IS NULL OR l_plan2 IS NULL)
    THEN l_stmt := '
SELECT	0	VIEWBY,
	0	VIEWBYID,
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
	0 	ISC_MEASURE_18
  FROM	dual
 WHERE	1 = 2 /* PLAN_SNAPSHOT dimension has not been populated */';
    ELSE

    l_inner_sql := 'ISC_MEASURE_1,ISC_MEASURE_2,ISC_MEASURE_3, ISC_MEASURE_4,ISC_MEASURE_5,
		ISC_MEASURE_4-ISC_MEASURE_5 ISC_MEASURE_6,ISC_MEASURE_7,ISC_MEASURE_8,
		ISC_MEASURE_9,ISC_MEASURE_10,ISC_MEASURE_11,ISC_MEASURE_10-ISC_MEASURE_11 ISC_MEASURE_12,
		ISC_MEASURE_13,ISC_MEASURE_14,ISC_MEASURE_15,
		ISC_MEASURE_16,ISC_MEASURE_17,ISC_MEASURE_16-ISC_MEASURE_17 ISC_MEASURE_18
	FROM(select (rank() over (&ORDER_BY_CLAUSE nulls last,viewby_id))-1 rnk,
		viewby_id,
		ISC_MEASURE_1,ISC_MEASURE_2,ISC_MEASURE_3,
		sum(plan_mds) over ()*365/(:ISC_CUR_END - :ISC_CUR_START+1)/
		decode(sign(sum(plan_begin_inv) over()+sum(plan_end_inv) over()),0,null,-1,null,
		(sum(plan_begin_inv) over()+sum(plan_end_inv) over())/2/:ISC_MON_NUM) ISC_MEASURE_4,
		sum(comp_mds) over ()*365/(:ISC_CUR_END - :ISC_CUR_START+1)/
		decode(sign(sum(comp_begin_inv) over()+sum(comp_end_inv) over()),0,null,-1,null,
		(sum(comp_begin_inv) over()+sum(comp_end_inv) over())/2/:ISC_MON_NUM) ISC_MEASURE_5,
		ISC_MEASURE_7,ISC_MEASURE_8,ISC_MEASURE_9,
		sum(plan_ontime_total) over ()/decode(sum(plan_total_lines) over(),0,null,
		sum(plan_total_lines) over())*100	ISC_MEASURE_10,
		sum(comp_ontime_total) over ()/decode(sum(comp_total_lines) over(),0,null,
		sum(comp_total_lines) over())*100	ISC_MEASURE_11,
		ISC_MEASURE_13,ISC_MEASURE_14,ISC_MEASURE_15,
		sum(plan_required_hr_total) over()/decode(sum(plan_available_hr_total) over(),0,null,
			sum(plan_available_hr_total)over())*100	ISC_MEASURE_16,
		sum(comp_required_hr_total) over()/decode(sum(comp_available_hr_total) over(),0,null,
			sum(comp_available_hr_total)over())*100	ISC_MEASURE_17
		FROM (select c.viewby_id,
		sum(c.plan_inv_turns)					ISC_MEASURE_1,
		sum(c.comp_inv_turns)					ISC_MEASURE_2,
		sum(c.plan_inv_turns)-sum(comp_inv_turns)		ISC_MEASURE_3,
		sum(c.plan_mds_total)					plan_mds,
		sum(c.plan_begin_inv_total)				plan_begin_inv,
		sum(c.plan_end_inv_total)				plan_end_inv,
		sum(c.comp_mds_total)					comp_mds,
		sum(c.comp_begin_inv_total)				comp_begin_inv,
		sum(c.comp_end_inv_total)				comp_end_inv,
		sum(c.plan_ontime_lines)/decode(sum(c.plan_total_lines),0,null,
			sum(c.plan_total_lines))*100			ISC_MEASURE_7,
		sum(c.comp_ontime_lines)/decode(sum(c.comp_total_lines),0,null,
			sum(c.comp_total_lines))*100			ISC_MEASURE_8,
		(sum(c.plan_ontime_lines)/decode(sum(c.plan_total_lines),0,null,
			sum(c.plan_total_lines)))*100-
		(sum(c.comp_ontime_lines)/decode(sum(c.comp_total_lines),0,null,
			sum(c.comp_total_lines)))*100			ISC_MEASURE_9,
		sum(c.plan_ontime_lines) 				plan_ontime_total,
		sum(c.plan_total_lines)					plan_total_lines,
		sum(c.comp_ontime_lines)				comp_ontime_total,
		sum(c.comp_total_lines)					comp_total_lines,
		sum(c.plan_required_hr)/decode(sum(c.plan_available_hr),0,null,
			sum(c.plan_available_hr))*100			ISC_MEASURE_13,
		sum(c.comp_required_hr)/decode(sum(c.comp_available_hr),0,null,
			sum(c.comp_available_hr))*100			ISC_MEASURE_14,
		(sum(c.plan_required_hr)/decode(sum(c.plan_available_hr),0,null,
			sum(c.plan_available_hr)))*100-
		(sum(c.comp_required_hr)/decode(sum(c.comp_available_hr),0,null,
			sum(c.comp_available_hr)))*100			ISC_MEASURE_15,
		sum(c.plan_required_hr) 				plan_required_hr_total,
		sum(c.plan_available_hr) 				plan_available_hr_total,
		sum(c.comp_required_hr)					comp_required_hr_total,
		sum(c.comp_available_hr) 				comp_available_hr_total
		FROM (
		SELECT s.viewby_id,
		decode(s.plan_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
		sum(s.mds)*365/(:ISC_CUR_END - :ISC_CUR_START+1)/
		decode(sign(sum(s.begin_inv+s.end_inv)),0,null,-1,null,
		sum(s.begin_inv+s.end_inv)/2/:ISC_MON_NUM),null) 	plan_inv_turns,
		decode(s.plan_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
		sum(s.mds)*365/(:ISC_CUR_END - :ISC_CUR_START+1)/
		decode(sign(sum(s.begin_inv+s.end_inv)),0,null,-1,null,
		sum(s.begin_inv+s.end_inv)/2/:ISC_MON_NUM),null) 	comp_inv_turns,
		decode(s.plan_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
		sum(s.mds),null)					plan_mds_total,
		decode(s.plan_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
		sum(s.begin_inv),null)					plan_begin_inv_total,
		decode(s.plan_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
		sum(s.end_inv),null)					plan_end_inv_total,
		decode(s.plan_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
		sum(s.mds),null)					comp_mds_total,
		decode(s.plan_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
		sum(s.begin_inv),null)					comp_begin_inv_total,
		decode(s.plan_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
		sum(s.end_inv),null)					comp_end_inv_total,
		null		plan_ontime_lines,
		null		plan_total_lines,
		null		comp_ontime_lines,
		null		comp_total_lines,
		null		plan_required_hr,
		null		plan_available_hr,
		null		comp_required_hr,
		null		comp_available_hr
		FROM
		(SELECT f.organization_id	VIEWBY_ID,
		dates.start_date		PERIOD,
		f.snapshot_id			PLAN_ID,
		sum(decode(dates.period_type,''P'',f.inventory_cost_g,0))	begin_inv,
		sum(decode(dates.period_type,''C'',f.inventory_cost_g,0))	end_inv,
		sum(decode(dates.period_type,''C'',f.mds_cost_g,0))	mds
		FROM
		(SELECT fii.start_date	START_DATE,
			fii.start_date  REPORT_DATE,
			''C''		PERIOD_TYPE
		 FROM FII_TIME_ENT_PERIOD fii
		 WHERE fii.start_date between :ISC_CUR_START and :ISC_CUR_END
		UNION ALL
		SELECT 	cur.start_date	start_date,
			pre.start_date  report_date,
			''P''		period_type
		FROM
		(SELECT fii.start_date	START_DATE,
		 rownum			ID
		 FROM FII_TIME_ENT_PERIOD fii
		 WHERE fii.start_date between :ISC_PRE_START and :ISC_PRE_END
		 ORDER by fii.start_date DESC)		pre,
		(SELECT fii.start_date	START_DATE,
		 rownum			ID
		 FROM FII_TIME_ENT_PERIOD fii
		 WHERE fii.start_date between :ISC_CUR_START and :ISC_CUR_END
		 ORDER by fii.start_date DESC)		cur
		WHERE cur.id = pre.id(+))	dates,
		ISC_DBI_PM_0001_MV f
		WHERE f.start_date = dates.report_date
		AND f.period_type_id = :ISC_MON_PERIOD_ID
		AND f.union1_flag <>:ISC_UNION_FLAG
		AND f.item_cat_flag = :ISC_ITEM_CAT_FLAG
		AND f.snapshot_id in (&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2)
		GROUP BY f.organization_id,dates.start_date,f.snapshot_id) s
		GROUP BY s.viewby_id,s.plan_id
		UNION ALL
		SELECT f.organization_id	VIEWBY_ID,
		null	plan_inv_turns,
		null	comp_inv_turns,
		null	plan_mds_total,
		null	plan_begin_inv_total,
		null	plan_end_inv_total,
		null	comp_mds_total,
		null	comp_begin_inv_total,
		null	comp_end_inv_total,
		decode(f.snapshot_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
		sum(f.total_lines)-sum(f.late_lines),null)		plan_ontime_lines,
		decode(f.snapshot_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
		sum(f.total_lines),null)				plan_total_lines,
		decode(f.snapshot_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
		sum(f.total_lines)-sum(f.late_lines),null)		comp_ontime_lines,
		decode(f.snapshot_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
		sum(f.total_lines),null)				comp_total_lines,
		null		plan_required_hr,
		null		plan_available_hr,
		null		comp_required_hr,
		null		comp_available_hr
		FROM
		ISC_DBI_PM_0001_MV f
		WHERE f.start_date = :ISC_CUR_START
		AND f.period_type_id = :ISC_PERIOD_TYPE_ID
		AND f.union2_flag <>:ISC_UNION_FLAG
		AND f.item_cat_flag = :ISC_ITEM_CAT_FLAG
		AND f.snapshot_id in (&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2)
		GROUP BY f.organization_id,f.snapshot_id
		UNION ALL
		SELECT f.organization_id	VIEWBY_ID,
		null	plan_inv_turns,
		null	comp_inv_turns,
		null	plan_mds_total,
		null	plan_begin_inv_total,
		null	plan_end_inv_total,
		null	comp_mds_total,
		null	comp_begin_inv_total,
		null	comp_end_inv_total,
		null	plan_ontime_lines,
		null	plan_total_lines,
		null	comp_ontime_lines,
		null	comp_total_lines,
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
		AND f.snapshot_id in (&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2)
		GROUP BY f.organization_id,f.snapshot_id) c
		'||l_org_where||'
		GROUP BY c.viewby_id)
		WHERE (ISC_MEASURE_1 is not null OR ISC_MEASURE_2 is not null
			OR ISC_MEASURE_7 is not null OR ISC_MEASURE_7 is not null
			OR ISC_MEASURE_13 is not null OR ISC_MEASURE_14 is not null)) a,';

  l_stmt := 'SELECT org.name				VIEWBY,
		org.organization_id			VIEWBYID,
		'||l_inner_sql||'
		HR_ALL_ORGANIZATION_UNITS_TL org
		WHERE org.organization_id = a.viewby_id
		AND org.language = :ISC_LANG
		AND ((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX=-1))
		ORDER BY rnk';

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

  l_custom_rec.attribute_name := ':ISC_PRE_START';
  l_custom_rec.attribute_value := to_char(l_pre_start,'DD/MM/YYYY');
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_PRE_END';
  l_custom_rec.attribute_value := to_char(l_pre_end,'DD/MM/YYYY');
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;


  l_custom_rec.attribute_name := ':ISC_LANG';
  l_custom_rec.attribute_value := l_lang;
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(6) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_ITEM_CAT_FLAG';
  l_custom_rec.attribute_value := to_char(l_item_cat_flag);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(7) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_UNION_FLAG';
  l_custom_rec.attribute_value := to_char(l_union_flag);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(8) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_RES_GP_FLAG';
  l_custom_rec.attribute_value := to_char(l_res_gp_flag);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(9) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_MON_PERIOD_ID';
  l_custom_rec.attribute_value := to_char(l_mon_period_id);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(10) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_MON_NUM';
  l_custom_rec.attribute_value := to_char(l_mon_num);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(11) := l_custom_rec;

END get_sql;

END ISC_DBI_PLAN_PERF_PKG ;


/
