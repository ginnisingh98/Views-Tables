--------------------------------------------------------
--  DDL for Package Body ISC_DBI_PLAN_PRS_REASON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_PLAN_PRS_REASON_PKG" AS
/* $Header: ISCRGB5B.pls 120.0 2005/05/25 17:18:52 appldev noship $ */


PROCEDURE GET_SQL(p_param IN BIS_PMV_PAGE_PARAMETER_TBL,x_custom_sql OUT NOCOPY VARCHAR2,
	x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt 		VARCHAR2(32000);
  l_plan		VARCHAR2(10000);
  l_plan2		VARCHAR2(10000);
  l_inner_sql		VARCHAR2(32000);
  l_org 		VARCHAR2(32000);
  l_org_where     	VARCHAR2(32000);
  l_period_type		VARCHAR2(1000);
  l_item		VARCHAR2(32000);
  l_item_from		VARCHAR2(32000);
  l_item_where		VARCHAR2(32000);
  l_sup			VARCHAR2(32000);
  l_sup_where		VARCHAR2(32000);
  l_res			VARCHAR2(32000);
  l_res_where		VARCHAR2(32000);
  l_res_org		VARCHAR2(32000);
  l_res_org_where	VARCHAR2(32000);
  l_curr		VARCHAR2(10000);
  l_curr_g		VARCHAR2(15) := '''FII_GLOBAL1''';
  l_curr_g1		VARCHAR2(15) := '''FII_GLOBAL2''';
  l_curr_suffix		VARCHAR2(15);
  l_time_from		DATE;
  l_period_type_id	NUMBER;
  l_lang		varchar2(10);
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

    IF(p_param(i).parameter_name = 'PERIOD_TYPE') THEN
       l_period_type :=  p_param(i).parameter_value;
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

    IF(p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION+ORGANIZAT_D1')
      THEN l_org :=  p_param(i).parameter_value;
    END IF;

    IF (p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES')
      THEN l_curr := p_param(i).parameter_id;
    END IF;

    IF(p_param(i).parameter_name = 'SUPPLIER+POA_SUPPLIERS') THEN
       l_sup :=  p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ITEM+ENI_ITEM_ORG') THEN
       l_item :=  p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'ORGANIZATION+ORGANIZATION+BIS_ORGANIZATION')
      THEN l_res_org :=  p_param(i).parameter_value;
    END IF;

    IF(p_param(i).parameter_name = 'RESOURCE+ENI_RESOURCE') THEN
       l_res :=  p_param(i).parameter_value;
    END IF;
  END LOOP;

  IF (l_curr = l_curr_g)
    THEN
	l_curr_suffix := '_g';
    ELSIF (l_curr = l_curr_g1)
	THEN
		l_curr_suffix := '_g1' ;
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
				AND f.organization_id =(&ORGANIZATION+ORGANIZATION+ORGANIZAT_D1)';
  END IF;


  IF ( l_sup IS NULL OR l_sup = 'All' ) THEN
    l_sup_where :='';
  ELSE
    l_sup_where := '
				AND f.r_supplier_id in (&SUPPLIER+POA_SUPPLIERS)';
  END IF;


  IF ( l_item IS NULL OR l_item = 'All' )
  THEN l_item_from := '';
       l_item_where := '';
  ELSE l_item_from := ',
					ENI_OLTP_ITEM_STAR	star';
       l_item_where := '
				AND star.inventory_item_id = f.r_item_id
				AND star.organization_id = f.r_org_id
				AND star.id in (&ITEM+ENI_ITEM_ORG)';
  END IF;

  IF ( l_res IS NULL OR l_res = 'All' )
  THEN l_res_where := '';
  ELSE l_res_where := '
				AND f.r_resource_id in (&RESOURCE+ENI_RESOURCE)';
  END IF;

  IF ( l_res_org IS NULL OR l_res_org = 'All' ) THEN
    l_res_org_where :='';
  ELSE
    l_res_org_where := '
				AND f.r_org_id in (&ORGANIZATION+ORGANIZATION+BIS_ORGANIZATION)';
  END IF;

  l_lang := USERENV('LANG');


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
SELECT	0	ISC_ATTRIBUTE_1,
	0	ISC_ATTRIBUTE_2,
	0	ISC_ATTRIBUTE_3,
	0	ISC_ATTRIBUTE_4,
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
	0 	ISC_MEASURE_11
  FROM	dual
 WHERE	1 = 2 /* PLAN_SNAPSHOT dimension has not been populated */';
    ELSE
    l_stmt := '
 SELECT	decode(a.type, 	''ITEM'', 	items.value,
			''RESOURCE'', 	res.value,
			''TRANSPORT'', 	items.value,
			''UNASSIGNED'',	null)		ISC_ATTRIBUTE_1,
	type.meaning					ISC_ATTRIBUTE_2,
	decode(a.type,	''ITEM'',	sp.value,
			''RESOURCE'',	org.name,
			''TRANSPORT'',	org.name,
			''UNASSIGNED'',	null)		ISC_ATTRIBUTE_3,
	decode(a.type,	''ITEM'',	sps.value,
			''RESOURCE'',	resd.value,
			''TRANSPORT'',	null,
			''UNASSIGNED'',	null)		ISC_ATTRIBUTE_4,
	ISC_MEASURE_1, ISC_MEASURE_2, ISC_MEASURE_3, ISC_MEASURE_4, ISC_MEASURE_5,
	ISC_MEASURE_6, ISC_MEASURE_7, ISC_MEASURE_8, ISC_MEASURE_9, ISC_MEASURE_10,
	ISC_MEASURE_11
   FROM (select (rank() over (&ORDER_BY_CLAUSE nulls last, r_item_id, r_item_org_id, r_resource_id, r_supplier_id,
							   r_supplier_site_id, r_org_id, r_department_id)) - 1	rnk,
		r_item_id,
		r_item_org_id,
		r_supplier_id,
		r_supplier_site_id,
		r_resource_id,
		r_org_id,
		r_department_id,
		type,
		ISC_MEASURE_1, ISC_MEASURE_2, ISC_MEASURE_3, ISC_MEASURE_4, ISC_MEASURE_5,
		ISC_MEASURE_6, ISC_MEASURE_7, ISC_MEASURE_8, ISC_MEASURE_9, ISC_MEASURE_10,
		ISC_MEASURE_11
	   FROM	(SELECT	c.r_item_id,
			c.r_item_org_id,
			c.r_supplier_id,
			c.r_supplier_site_id,
			c.r_resource_id,
			c.r_org_id,
			c.r_department_id,
			c.type,
			c.rev_sf							ISC_MEASURE_1,
			c.comp_rev_sf							ISC_MEASURE_2,
			c.rev_sf - c.comp_rev_sf					ISC_MEASURE_3,
			sum(c.rev_sf) over ()						ISC_MEASURE_4,
			sum(c.rev_sf) over () - sum(c.comp_rev_sf) over ()		ISC_MEASURE_5,
			c.rev_sf
			  / decode(sum(c.rev_sf) over (), 0, null,
				   sum(c.rev_sf) over ())
			  * 100								ISC_MEASURE_6,
			sum(c.rev_sf) over ()
			  / decode(sum(c.rev_sf) over (), 0, null,
				   sum(c.rev_sf) over ())
			  * 100								ISC_MEASURE_7,
			c.rev_sf - c.cost_sf						ISC_MEASURE_8,
			sum(c.rev_sf) over () - sum(c.cost_sf) over ()			ISC_MEASURE_9,
			(c.rev_sf - c.cost_sf)
			  / decode(c.rev_sf, 0, null,
				   c.rev_sf)
			  * 100								ISC_MEASURE_10,
			(sum(c.rev_sf) over () - sum(c.cost_sf) over ())
			  / decode(sum(rev_sf) over (), 0, null,
				   sum(rev_sf) over ())
			  * 100								ISC_MEASURE_11
		   FROM (select	r_item_id,
				r_item_org_id,
				r_supplier_id,
				r_supplier_site_id,
				r_resource_id,
				r_org_id,
				r_department_id,
				type,
				sum(rev_sf)		REV_SF,
				sum(cost_sf)		COST_SF,
				sum(comp_rev_sf)	COMP_REV_SF,
				sum(comp_cost_sf)	COMP_COST_SF
			   FROM (SELECT	decode(f.reason_type, 1, f.r_item_id,		3, f.r_item_id,	  -1, null)		r_item_id,
					decode(f.reason_type, 1, f.r_org_id, 		3, f.r_org_id,	  -1, null)		r_item_org_id,
					decode(f.reason_type, 1, f.r_supplier_id,	3, null, 	  -1, null)		r_supplier_id,
					decode(f.reason_type, 1, f.r_supplier_site_id,	3, null, 	  -1, null)		r_supplier_site_id,
					null											r_resource_id,
					null											r_org_id,
					null											r_department_id,
					decode(f.reason_type, 1, ''ITEM'',		3, ''TRANSPORT'', -1, ''UNASSIGNED'')	type,
					decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
						f.rev_shortfall'||l_curr_suffix||', 0)		rev_sf,
					decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
						f.cost_shortfall'||l_curr_suffix||', 0)		cost_sf,
					decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
						f.rev_shortfall'||l_curr_suffix||', 0)		comp_rev_sf,
					decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
						f.cost_shortfall'||l_curr_suffix||', 0)		comp_cost_sf
				   FROM	ISC_DBI_SHORTFALL_SNAPSHOTS f'||l_item_from||'
				  WHERE	f.start_date = :ISC_CUR_START
				    AND	f.period_type_id = :ISC_PERIOD_TYPE_ID
				    AND	f.reason_type in (1,3,-1)
				    AND	f.snapshot_id in (&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2)
				'||l_org_where||l_item_where||l_sup_where||'
				UNION ALL
				 SELECT	null			r_item_id,
					null			r_item_org_id,
					null			r_supplier_id,
					null			r_supplier_site_id,
					f.r_resource_id		r_resource_id,
					f.r_org_id		r_org_id,
					f.r_department_id	r_department_id,
					''RESOURCE''		type,
					decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
						f.rev_shortfall'||l_curr_suffix||', 0)		rev_sf,
					decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,
						f.cost_shortfall'||l_curr_suffix||', 0)		cost_sf,
					decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
						f.rev_shortfall'||l_curr_suffix||', 0)		comp_rev_sf,
					decode(f.snapshot_id, &PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2,
						f.cost_shortfall'||l_curr_suffix||', 0)		comp_cost_sf
				   FROM	ISC_DBI_PM_0004_MV f
				  WHERE	f.start_date = :ISC_CUR_START
				    AND	f.period_type_id = :ISC_PERIOD_TYPE_ID
				    AND	f.snapshot_id in (&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT,&PLAN_SNAPSHOT+PLAN_SNAPSHOT+PLAN_SNAPSHOT_2)
				'||l_org_where||l_res_where||l_res_org_where||')
			GROUP BY
				r_item_id,
				r_item_org_id,
				r_supplier_id,
				r_supplier_site_id,
				r_resource_id,
				r_org_id,
				r_department_id,
				type)			c)) a,
	HR_ALL_ORGANIZATION_UNITS_TL 	org,
	ENI_ITEM_ORG_V 			items,
	POA_SUPPLIERS_V 		sp,
	POA_SUPPLIER_SITES_V 		sps,
	ENI_RESOURCE_V			res,
	ENI_RESOURCE_DEPARTMENT_V	resd,
	FND_LOOKUPS			type
  WHERE	org.organization_id (+)= a.r_org_id
    AND	org.language (+)= :ISC_LANG
    AND	items.inventory_item_id(+) = a.r_item_id
    AND items.organization_id(+) = a.r_item_org_id
    AND	sp.id (+)= a.r_supplier_id
    AND	sps.id (+)= a.r_supplier_site_id
    AND	res.id (+)= to_char(a.r_resource_id)
    AND	resd.id (+)= to_char(a.r_department_id)
    AND type.lookup_type = ''ISC_DBI_PLAN_PRS_REASON_TYPE''
    AND type.lookup_code = a.type
    AND	((a.rnk between &START_INDEX and &END_INDEX) OR &END_INDEX=-1)
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


END get_sql;

END ISC_DBI_PLAN_PRS_REASON_PKG ;


/
