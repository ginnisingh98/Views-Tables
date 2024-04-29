--------------------------------------------------------
--  DDL for Package Body ISC_DBI_PLAN_INV_T_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_PLAN_INV_T_TREND_PKG" AS
/* $Header: ISCRGARB.pls 115.4 2004/01/30 07:57:06 chu noship $ */


PROCEDURE GET_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,x_custom_sql OUT NOCOPY VARCHAR2,
	x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt 		VARCHAR2(32000);
  l_plan		VARCHAR2(10000);
  l_plan2		VARCHAR2(10000);
  l_org 		VARCHAR2(32000);
  l_org_where     	VARCHAR2(32000);
  l_period_type		VARCHAR2(1000);
  l_period_id		VARCHAR2(1000);
  l_inv_cat		VARCHAR2(32000);
  l_item		VARCHAR2(32000);
  l_inv_cat_where	VARCHAR2(32000);
  l_item_where		VARCHAR2(32000);
  l_item_cat_flag	NUMBER; -- 0 for item, 1 for inv.cat, 3 for all
  l_union_flag		NUMBER:=0; -- for inventory turns report
  l_time_from		DATE;
  l_time_to		DATE;
  l_cur_start		DATE;
  l_cur_end		DATE;
  l_pre_start		DATE;
  l_pre_end		DATE;
  l_period_type_id	NUMBER:=32; --only select month buckets
  l_loop		NUMBER;
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

  IF((l_inv_cat IS NULL OR l_inv_cat = 'All' ) AND ( l_item IS NULL OR l_item = 'All'))
   THEN l_item_cat_flag := 3;  -- no grouping on item dimension

   ELSE
	IF (l_item IS NULL OR l_item = 'All')
    	THEN l_item_cat_flag := 1; -- inv, category
    	ELSE l_item_cat_flag := 0; -- item is needed
	END IF;
  END IF;

  IF l_period_type = 'FII_TIME_ENT_YEAR' THEN
   l_loop :=3;
   l_period_id := 'ent_year_id';
   l_mon_num :=12;

  ELSIF (l_period_type='FII_TIME_ENT_QTR') THEN
   l_loop := 7;
   l_period_id := 'ent_qtr_id';
   l_mon_num :=3;

  ELSE
   l_loop :=11;
   l_period_id := 'ent_period_id';
   l_mon_num :=1;

  END IF;


  l_cur_start := l_time_from;
  l_cur_end := l_time_from;

  FOR i IN 1..l_loop
  LOOP
    l_cur_end := FII_TIME_API.next_period_end_date(l_cur_end, l_period_type);
  END LOOP;

  l_pre_start := FII_TIME_API.ent_pper_start(l_cur_start); -- get the previous month
  l_pre_end := FII_TIME_API.ent_pper_end(l_cur_end); -- get the previous month


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

  l_stmt:='SELECT a.name					VIEWBY,
		sum(plan_inv_turns)				ISC_MEASURE_1,
		sum(comp_inv_turns)				ISC_MEASURE_2,
		sum(plan_inv_turns)-sum(comp_inv_turns)		ISC_MEASURE_3
		FROM(
		SELECT fii.name,
		fii.start_date,
		s.period_id,
		decode(s.plan_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
		sum(s.mds)*365/(fii.end_date - fii.start_date +1)/
		decode(sign(sum(s.begin_inv+s.end_inv)),0,null,-1,null,
		sum(s.begin_inv+s.end_inv)/2/:ISC_MON_NUM),null) plan_inv_turns,
		decode(s.plan_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
		sum(s.mds)*365/(fii.end_date - fii.start_date +1)/
		decode(sign(sum(s.begin_inv+s.end_inv)),0,null,-1,null,
		sum(s.begin_inv+s.end_inv)/2/:ISC_MON_NUM),null) comp_inv_turns
		FROM
		(SELECT dates.'||l_period_id||'	PERIOD_ID,
		f.snapshot_id			PLAN_ID,
		sum(decode(dates.period_type,''P'',f.inventory_cost,0))	begin_inv,
		sum(decode(dates.period_type,''C'',f.inventory_cost,0))	end_inv,
		sum(decode(dates.period_type,''C'',f.mds_cost,0))		mds
		FROM
		(SELECT fii.start_date	REPORT_DATE,
		 fii.start_date		START_DATE,
		 ent_period_id		ENT_PERIOD_ID,
		 ent_qtr_id		ENT_QTR_ID,
		 ent_year_id		ENT_YEAR_ID,
		 ''C''			PERIOD_TYPE
		 FROM FII_TIME_ENT_PERIOD fii
		 WHERE fii.start_date between :ISC_CUR_START and :ISC_CUR_END
		UNION ALL
		SELECT pre.start_date  REPORT_DATE,
			cur.start_date	START_DATE,
			cur.period_id	ENT_PERIOD_ID,
			cur.qtr_id	ENT_QTR_ID,
			cur.year_id	ENT_YEAR_ID,
			''P''		PERIOD_TYPE
		FROM
		(SELECT fii.start_date	START_DATE,
		 rownum			ID
		 FROM FII_TIME_ENT_PERIOD fii
		 WHERE fii.start_date between :ISC_PRE_START and :ISC_PRE_END
		 ORDER by fii.start_date DESC)		pre,
		(SELECT fii.start_date	START_DATE,
		 rownum			ID,
		 ent_period_id		PERIOD_ID,
		 ent_qtr_id		QTR_ID,
		 ent_year_id		YEAR_ID
		 FROM FII_TIME_ENT_PERIOD fii
		 WHERE fii.start_date between :ISC_CUR_START and :ISC_CUR_END
		 ORDER by fii.start_date DESC)		cur
		WHERE cur.id = pre.id(+))	dates,
		ISC_DBI_PM_0001_MV f
		WHERE f.start_date = dates.report_date
		AND f.period_type_id = :ISC_PERIOD_TYPE_ID
		AND f.union1_flag <> :ISC_UNION_FLAG
		AND f.item_cat_flag = :ISC_ITEM_CAT_FLAG
		AND f.snapshot_id in (&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2)
		'||l_org_where||l_inv_cat_where||l_item_where||
		'GROUP BY dates.'||l_period_id||',f.snapshot_id) s,
		'|| l_period_type ||' 	fii
		WHERE fii.'||l_period_id||' = s.period_id(+)
		AND fii.start_date BETWEEN :ISC_CUR_START and :ISC_CUR_END
		GROUP BY fii.name,fii.start_date,fii.end_date,s.period_id,s.plan_id) a
		GROUP BY a.name, a.start_date
		ORDER BY a.start_date';

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

  l_custom_rec.attribute_name := ':ISC_ITEM_CAT_FLAG';
  l_custom_rec.attribute_value := to_char(l_item_cat_flag);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(6) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_UNION_FLAG';
  l_custom_rec.attribute_value := to_char(l_union_flag);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(7) := l_custom_rec;

  l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
  l_custom_rec.attribute_value := 'TIME+'||l_period_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
  x_custom_output.EXTEND;
  x_custom_output(8) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_MON_NUM';
  l_custom_rec.attribute_value := to_char(l_mon_num);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(9) := l_custom_rec;

END get_sql;

END ISC_DBI_PLAN_INV_T_TREND_PKG ;


/
