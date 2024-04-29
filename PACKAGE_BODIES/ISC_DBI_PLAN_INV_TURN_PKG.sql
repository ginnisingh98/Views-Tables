--------------------------------------------------------
--  DDL for Package Body ISC_DBI_PLAN_INV_TURN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_PLAN_INV_TURN_PKG" AS
/* $Header: ISCRGAQB.pls 120.1 2006/06/26 06:34:16 abhdixi noship $ */


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
  l_time_to		DATE;
  l_cur_start		DATE;
  l_cur_end		DATE;
  l_pre_start		DATE;
  l_pre_end		DATE;
  l_lang		varchar2(10);
  l_viewby_id		varchar2(100);
  l_mon_num		NUMBER; -- number of months in the selected period
  l_custom_rec 		BIS_QUERY_ATTRIBUTES ;
  l_curr		VARCHAR2(10000);
  l_curr_g		VARCHAR2(15) := '''FII_GLOBAL1''';
  l_curr_g1		VARCHAR2(15) := '''FII_GLOBAL2''';
  l_curr_suffix         VARCHAR2(15);

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

  IF ( l_org IS NULL OR l_org = 'All' )
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


  l_cur_start := l_time_from;
  l_cur_end := l_time_to;
  l_pre_start := FII_TIME_API.ent_pper_start(l_time_from); -- get the previous month
  l_pre_end := FII_TIME_API.ent_pper_end(l_time_to); -- get the previous month


  l_lang := USERENV('LANG');


 IF l_period_type = 'FII_TIME_ENT_YEAR' THEN
   l_mon_num :=12;

  ELSIF (l_period_type='FII_TIME_ENT_QTR') THEN
   l_mon_num :=3;

  ELSE
   l_mon_num :=1;

  END IF;


  IF l_view_by = 'ORGANIZATION+ORGANIZATION' THEN
    l_viewby_id :='organization_id';

  ELSIF l_view_by = 'ITEM+ENI_ITEM_ORG' THEN
    l_viewby_id :='item_id';

  ELSIF l_view_by = 'ITEM+ENI_ITEM_INV_CAT' THEN
    l_viewby_id :='inv_category_id';

  END if;


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
		ISC_MEASURE_9, ISC_MEASURE_10
	FROM(select (rank() over (&ORDER_BY_CLAUSE nulls last,viewby_id))-1 rnk,
		viewby_id,
		ISC_MEASURE_1,ISC_MEASURE_2,ISC_MEASURE_3,
		sum(ISC_MEASURE_7) over ()*365/(:ISC_CUR_END - :ISC_CUR_START+1)/
		decode(sign(sum(ISC_MEASURE_8) over()),0,null,-1,null,
		sum(ISC_MEASURE_8) over()) 				ISC_MEASURE_4,
		sum(comp_mds) over ()*365/(:ISC_CUR_END - :ISC_CUR_START+1)/
		decode(sign(sum(comp_avg_inv) over()),0,null,-1,null,
		sum(comp_avg_inv) over())				 ISC_MEASURE_5,
		ISC_MEASURE_7,ISC_MEASURE_8,
		sum(ISC_MEASURE_7) over ()				ISC_MEASURE_9,
		sum(ISC_MEASURE_8) over ()				ISC_MEASURE_10
	FROM (select viewby_id,
		sum(plan_inv_turns)					ISC_MEASURE_1,
		sum(comp_inv_turns)					ISC_MEASURE_2,
		sum(plan_inv_turns)-sum(comp_inv_turns)			ISC_MEASURE_3,
		sum(plan_mds_total)					ISC_MEASURE_7,
		sum(plan_avg_inv)					ISC_MEASURE_8,
		sum(comp_mds_total)					comp_mds,
		sum(comp_avg_inv)					comp_avg_inv
	FROM(	SELECT s.viewby_id,
		decode(s.plan_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
		sum(s.mds)*365/(:ISC_CUR_END - :ISC_CUR_START+1)/
		decode(sign(sum(s.begin_inv+s.end_inv)),0,null,-1,null,
		sum(s.begin_inv+s.end_inv)/2/:ISC_MON_NUM),null) 		plan_inv_turns,
		decode(s.plan_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
		sum(s.begin_inv+s.end_inv)/2/:ISC_MON_NUM,null) 		plan_avg_inv,
		decode(s.plan_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
		sum(s.mds)*365/(:ISC_CUR_END - :ISC_CUR_START+1)/
		decode(sign(sum(s.begin_inv+s.end_inv)),0,null,-1,null,
		sum(s.begin_inv+s.end_inv)/2/:ISC_MON_NUM),null) 		comp_inv_turns,
		decode(s.plan_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
		sum(s.mds),null)						plan_mds_total,
		decode(s.plan_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
		sum(s.mds),null)						comp_mds_total,
		decode(s.plan_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
		sum(s.begin_inv+s.end_inv)/2/:ISC_MON_NUM,null)			comp_avg_inv
		FROM
		(SELECT f.'||l_viewby_id||'	VIEWBY_ID,
		dates.start_date		PERIOD,
		f.snapshot_id			PLAN_ID,
		sum(decode(dates.period_type,''P'',f.inventory_cost'||l_curr_suffix||',0))	begin_inv,
		sum(decode(dates.period_type,''C'',f.inventory_cost'||l_curr_suffix||',0))	end_inv,
		sum(decode(dates.period_type,''C'',f.mds_cost'||l_curr_suffix||',0))	mds
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
		AND f.period_type_id = 32
		AND f.union1_flag <> 0
		AND item_cat_flag = :ISC_ITEM_CAT_FLAG
		AND f.snapshot_id in (&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2)
		'||l_org_where||l_inv_cat_where||l_item_where||
		'GROUP BY f.'||l_viewby_id||',dates.start_date,f.snapshot_id) s
		GROUP BY s.viewby_id,s.plan_id) c
		GROUP BY c.viewby_id)
		WHERE (ISC_MEASURE_7 <>0 OR ISC_MEASURE_8 <>0)
		OR (comp_mds <> 0 OR comp_avg_inv <>0)) a,';

  IF l_view_by = 'ORGANIZATION+ORGANIZATION' THEN
    l_stmt := 'SELECT org.name				VIEWBY,
		org.organization_id			VIEWBYID,
		null					ISC_ATTRIBUTE_1,
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
		AND((a.rnk between &START_INDEX and &END_INDEX) OR &END_INDEX=-1)
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

  l_custom_rec.attribute_name := ':ISC_CUR_START';
  l_custom_rec.attribute_value := to_char(l_cur_start,'DD/MM/YYYY');
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
  x_custom_output.EXTEND;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_CUR_END';
  l_custom_rec.attribute_value := to_char(l_cur_end,'DD/MM/YYYY');
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
  x_custom_output.EXTEND;
  x_custom_output(2) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_PRE_START';
  l_custom_rec.attribute_value := to_char(l_pre_start,'DD/MM/YYYY');
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
  x_custom_output.EXTEND;
  x_custom_output(3) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_PRE_END';
  l_custom_rec.attribute_value := to_char(l_pre_end,'DD/MM/YYYY');
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_LANG';
  l_custom_rec.attribute_value := l_lang;
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.VARCHAR2_BIND;
  x_custom_output.EXTEND;
  x_custom_output(5) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_ITEM_CAT_FLAG';
  l_custom_rec.attribute_value := to_char(l_item_cat_flag);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(6) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_MON_NUM';
  l_custom_rec.attribute_value := to_char(l_mon_num);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(7) := l_custom_rec;


END get_sql;

END ISC_DBI_PLAN_INV_TURN_PKG ;


/
