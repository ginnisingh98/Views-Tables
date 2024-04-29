--------------------------------------------------------
--  DDL for Package Body ISC_DBI_PLAN_PRS_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_PLAN_PRS_TREND_PKG" AS
/* $Header: ISCRGB4B.pls 120.0 2005/05/25 17:39:55 appldev noship $ */


PROCEDURE GET_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,x_custom_sql OUT NOCOPY VARCHAR2,
	x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt 		VARCHAR2(32000);
  l_plan		VARCHAR2(10000);
  l_plan2		VARCHAR2(10000);
  l_org 		VARCHAR2(32000);
  l_org_where     	VARCHAR2(32000);
  l_period_type		VARCHAR2(1000);
  l_time_from		DATE;
  l_time_to		DATE;
  l_cur_start		DATE;
  l_cur_end		DATE;
  l_curr		VARCHAR2(10000);
  l_curr_g		VARCHAR2(15) := '''FII_GLOBAL1''';
  l_curr_g1		VARCHAR2(15) := '''FII_GLOBAL2''';
  l_curr_suffix		VARCHAR2(15);
  l_period_type_id	NUMBER;
  l_period_id		VARCHAR2(30);
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

    IF (p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES')
      THEN l_curr := p_param(i).parameter_id;
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


  IF (l_curr = l_curr_g)
    THEN
	l_curr_suffix := '_g';
    ELSIF (l_curr = l_curr_g1)
	THEN
		l_curr_suffix := '_g1';
	ELSE
		l_curr_suffix := '';
  END IF;

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


  IF l_period_type = 'FII_TIME_ENT_YEAR' THEN
   l_loop :=3;
   l_period_type_id := 128;
   l_period_id :='ent_year_id';

  ELSIF (l_period_type='FII_TIME_ENT_QTR') THEN
   l_loop := 7;
   l_period_type_id := 64;
   l_period_id :='ent_qtr_id';

  ELSE
   l_loop :=11;
   l_period_type_id := 32;
   l_period_id :='ent_period_id';

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
SELECT	0	VIEWBY,
	0	ISC_ATTRIBUTE_1,
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
	0 	ISC_MEASURE_13
  FROM	dual
 WHERE	1 = 2 /* PLAN_SNAPSHOT dimension has not been populated */';
    ELSE
  l_stmt:='
	 SELECT	s.period_name					VIEWBY,
		s.period_id					ISC_ATTRIBUTE_1,
		sum(s.plan_rev)					ISC_MEASURE_1,
		sum(s.rev_sf)					ISC_MEASURE_2,
		sum(s.comp_rev_sf)				ISC_MEASURE_3,
		sum(s.rev_sf) - sum(s.comp_rev_sf)		ISC_MEASURE_4,
		sum(s.rev_sf)
		  / decode(sum(s.plan_rev), 0, null,
			   sum(s.plan_rev))
		  * 100						ISC_MEASURE_5,
		sum(s.rev_sf)
		  / decode(sum(s.plan_rev), 0, null,
			   sum(s.plan_rev))
		  * 100
		- sum(s.comp_rev_sf)
		  / decode(sum(s.comp_plan_rev), 0, null,
			   sum(s.comp_plan_rev))
		  * 100						ISC_MEASURE_6,
		sum(s.rev_sf)					ISC_MEASURE_7,
		sum(s.plan_rev) - sum(s.rev_sf)			ISC_MEASURE_8,
		sum(s.rev_sf) - sum(s.cost_sf)			ISC_MEASURE_9,
		sum(s.comp_rev_sf) - sum(s.comp_cost_sf)	ISC_MEASURE_10,
		sum(s.rev_sf) - sum(s.cost_sf)
		  - (sum(s.comp_rev_sf) - sum(s.comp_cost_sf))	ISC_MEASURE_11,
		(sum(s.rev_sf) - sum(s.cost_sf))
		  / decode(sum(s.rev_sf), 0, null,
			   sum(s.rev_sf))
		  * 100						ISC_MEASURE_12,
		(sum(s.rev_sf) - sum(s.cost_sf))
		  / decode(sum(s.rev_sf), 0, null,
			   sum(s.rev_sf))
		  * 100 -
		(sum(s.comp_rev_sf) - sum(s.comp_cost_sf))
		  / decode(sum(s.comp_rev_sf), 0, null,
			   sum(s.comp_rev_sf))
		  * 100						ISC_MEASURE_13
	   FROM	(SELECT	time.start_date				START_DATE,
			time.name				PERIOD_NAME,
			time.'||l_period_id||'			PERIOD_ID,
			decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
				f.mds_price'||l_curr_suffix||', 0)		PLAN_REV,
			decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
				f.mds_price'||l_curr_suffix||', 0)		COMP_PLAN_REV,
			decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
				f.rev_shortfall'||l_curr_suffix||', 0)		REV_SF,
			decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
				f.rev_shortfall'||l_curr_suffix||', 0)		COMP_REV_SF,
			decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
				f.cost_shortfall'||l_curr_suffix||', 0)		COST_SF,
			decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
				f.cost_shortfall'||l_curr_suffix||', 0)		COMP_COST_SF
		   FROM (SELECT	start_date,
				name,
				'||l_period_id||'
		 	   FROM	'||l_period_type||'
			  WHERE	start_date between :ISC_CUR_START and :ISC_CUR_END) 	time
			LEFT OUTER JOIN
			ISC_DBI_PM_0001_MV 						f
		     ON	f.start_date = time.start_date
		    AND	f.period_type_id = :ISC_PERIOD_TYPE_ID
		    AND	f.union1_flag <> 0
		    AND	f.item_cat_flag = 3
		    AND	f.snapshot_id in (&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2)
		'||l_org_where||') s
	GROUP BY
		s.period_name,
		s.period_id,
		s.start_date
	ORDER BY
		s.start_date';
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

  l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
  l_custom_rec.attribute_value := 'TIME+'||l_period_type;
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.VIEW_BY_TYPE;
  x_custom_output.EXTEND;
  x_custom_output(4) := l_custom_rec;


END get_sql;

END ISC_DBI_PLAN_PRS_TREND_PKG ;


/
