--------------------------------------------------------
--  DDL for Package Body ISC_DBI_PLAN_OT_SHIP_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_PLAN_OT_SHIP_TREND_PKG" AS
/* $Header: ISCRGATB.pls 115.4 2004/04/24 01:38:05 scheung noship $ */


PROCEDURE GET_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,x_custom_sql OUT NOCOPY VARCHAR2,
	x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt 		VARCHAR2(32000);
  l_plan		VARCHAR2(10000);
  l_plan2		VARCHAR2(10000);
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
		sum(s.plan_ontime_lines)/decode(sum(s.plan_total_lines),
		0,null,sum(s.plan_total_lines))*100	ISC_MEASURE_1,
		sum(s.comp_ontime_lines)/decode(sum(s.comp_total_lines),
		0,null,sum(s.comp_total_lines))*100	ISC_MEASURE_2,
		(sum(s.plan_ontime_lines)/decode(sum(s.plan_total_lines),
		0,null,sum(s.plan_total_lines)))*100-
		(sum(s.comp_ontime_lines)/decode(sum(s.comp_total_lines)
		,0,null,sum(s.comp_total_lines)))*100	ISC_MEASURE_3
		FROM(
		SELECT time.start_date		PERIOD_ID,
		time.name			PERIOD_NAME,
		decode(f.snapshot_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
		sum(f.total_lines)-sum(f.late_lines),null)		plan_ontime_lines,
		decode(f.snapshot_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
		sum(f.total_lines),null)				plan_total_lines,
		decode(f.snapshot_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
		sum(f.total_lines)-sum(f.late_lines),null)		comp_ontime_lines,
		decode(f.snapshot_id,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
		sum(f.total_lines),null)				comp_total_lines
		FROM
		(SELECT start_date,name
		 FROM '||l_period_type||'
		 WHERE start_date between :ISC_CUR_START and :ISC_CUR_END) time
		LEFT OUTER JOIN
		ISC_DBI_PM_0001_MV f
		ON f.start_date = time.start_date
		AND f.period_type_id = :ISC_PERIOD_TYPE_ID
		AND f.union2_flag <> 0
		AND f.item_cat_flag = :ISC_ITEM_CAT_FLAG
		AND f.snapshot_id in (&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2)
		'||l_org_where||l_inv_cat_where||l_item_where||
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

  l_custom_rec.attribute_name := ':ISC_ITEM_CAT_FLAG';
  l_custom_rec.attribute_value := to_char(l_item_cat_flag);
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

END ISC_DBI_PLAN_OT_SHIP_TREND_PKG ;


/
