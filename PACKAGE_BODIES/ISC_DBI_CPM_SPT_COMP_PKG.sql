--------------------------------------------------------
--  DDL for Package Body ISC_DBI_CPM_SPT_COMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_CPM_SPT_COMP_PKG" AS
/* $Header: ISCRGB8B.pls 120.0 2005/05/25 17:16:16 appldev noship $ */

FUNCTION simplify_all (
p_param			in 		varchar2
) return varchar2 is
begin
  if (	p_param is null	or
	p_param = '' or
	upper(p_param) = 'ALL')
    then return 'All';
    else return p_param;
  end if;
end simplify_all;

FUNCTION get_parameter_value (
p_param_rec		in		bis_pmv_page_parameter_rec
) return varchar2 is
begin
  case p_param_rec.parameter_name
    when 'VIEW_BY'			then return p_param_rec.parameter_value;
    when 'PERIOD_TYPE'			then return p_param_rec.parameter_value;
    when 'ITEM+ENI_ITEM_VBH_CAT' 	then return simplify_all(p_param_rec.parameter_value);
    when 'ITEM+ENI_ITEM_PROD_LEAF_CAT' 	then return simplify_all(p_param_rec.parameter_value);
    when 'ITEM+ENI_ITEM' 		then return simplify_all(p_param_rec.parameter_value);
    when 'CUSTOMER+PROSPECT' 		then return simplify_all(p_param_rec.parameter_value);
    when 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS'
					then return simplify_all(p_param_rec.parameter_value);
    when 'CURRENCY+FII_CURRENCIES' 	then return p_param_rec.parameter_id;
    else return null;
  end case;
end get_parameter_value;

PROCEDURE Get_Sql (	p_param		IN		BIS_PMV_PAGE_PARAMETER_TBL,
			x_custom_sql	OUT NOCOPY	VARCHAR2,
			x_custom_output	OUT NOCOPY	BIS_QUERY_ATTRIBUTES_TBL) IS

  l_stmt			VARCHAR2(32000);

  l_view_by			VARCHAR2(32000);
  l_prod_cat			VARCHAR2(32000) := 'All';
  l_leaf_cat			VARCHAR2(32000) := 'All';
  l_prod			VARCHAR2(32000) := 'All';
  l_cust			VARCHAR2(32000) := 'All';
  l_class			VARCHAR2(32000) := 'All';
  l_curr			VARCHAR2(32000);

  l_curr_g			VARCHAR2(100) := '''FII_GLOBAL1''';
  l_curr_g1			VARCHAR2(100) := '''FII_GLOBAL2''';
  sfx				VARCHAR2(100);

  l_drill_prod_cat		VARCHAR2(32000);
  l_drill_leaf_cat		VARCHAR2(32000);
  l_dimension_id		VARCHAR2(32000);
  l_dimension_view		VARCHAR2(32000);
  l_dim_where_clause		VARCHAR2(32000);

  l_prod_where			VARCHAR2(32000) := '';
  l_leaf_cat_where		VARCHAR2(32000) := '';
  l_prod_cat_where		VARCHAR2(32000) := '';
  l_cust_where			VARCHAR2(32000) := '';
  l_class_where			VARCHAR2(32000) := '';

  l_prod_cat_from		VARCHAR2(32000) := '';

  l_item_cat_flag		NUMBER;
  l_cust_flag			NUMBER;

  l_mv1				VARCHAR2(1000);
  l_mv2				VARCHAR2(1000);

  l_measures			VARCHAR2(32000);

  l_custom_rec			BIS_QUERY_ATTRIBUTES;

begin

  for i in 1..p_param.count
  loop
    case p_param(i).parameter_name
      when 'VIEW_BY'				then l_view_by 	:= get_parameter_value(p_param(i));
      when 'ITEM+ENI_ITEM_VBH_CAT' 		then l_prod_cat	:= get_parameter_value(p_param(i));
      when 'ITEM+ENI_ITEM_PROD_LEAF_CAT'	then l_leaf_cat	:= get_parameter_value(p_param(i));
      when 'ITEM+ENI_ITEM' 			then l_prod	:= get_parameter_value(p_param(i));
      when 'CUSTOMER+PROSPECT' 			then l_cust	:= get_parameter_value(p_param(i));
      when 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS'
						then l_class	:= get_parameter_value(p_param(i));
      when 'CURRENCY+FII_CURRENCIES' 		then l_curr	:= get_parameter_value(p_param(i));
      else null;
    end case;
  end loop;

  if (l_curr = l_curr_g1) then
    sfx := '_g1';
  else
    sfx := '_g';
  end if;

  if (l_view_by = 'CUSTOMER+PROSPECT') then
    l_drill_prod_cat	:= 'null';
    l_drill_leaf_cat	:= 'null';
    l_dimension_id	:= 'fact.customer_id';
    l_dimension_view	:= 'ASO_BI_PROSPECT_V';
    l_dim_where_clause	:= '';

  elsif (l_view_by = 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS') then
    l_drill_prod_cat	:= 'null';
    l_drill_leaf_cat	:= 'null';
    l_dimension_id	:= 'fact.class_code';
    l_dimension_view	:= 'FII_PARTNER_MKT_CLASS_V';
    l_dim_where_clause	:= '';

  elsif (l_view_by = 'ITEM+ENI_ITEM') then
    l_drill_prod_cat	:= 'null';
    l_drill_leaf_cat	:= 'null';
    l_dimension_id	:= 'fact.product_id';
    l_dimension_view	:= 'ENI_OLTP_ITEM_STAR';
    l_dim_where_clause	:= '
    AND dim_view.master_id is null';

  elsif (l_view_by = 'ITEM+ENI_ITEM_PROD_LEAF_CAT') then
    l_drill_prod_cat	:= 'null';
    l_drill_leaf_cat	:= '''pFunctionName=ISC_DBI_CPM_SPT_COMP&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM&pParamIds=Y''';
    l_dimension_id	:= 'fact.item_category_id';
    l_dimension_view	:= 'ENI_ITEM_PROD_LEAF_CAT_V';
    l_dim_where_clause	:= '';

  else -- l_view_by = 'ITEM+ENI_ITEM_VBH_CAT'
    l_drill_prod_cat	:= 'decode(dim_view.leaf_node_flag, ''Y'',
	''pFunctionName=ISC_DBI_CPM_SPT_COMP&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM&pParamIds=Y'',
	''pFunctionName=ISC_DBI_CPM_SPT_COMP&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&pParamIds=Y'')';
    l_drill_leaf_cat	:= 'null';
    if (l_prod_cat = 'All') then
      l_dimension_id	:= 'eni_cat.parent_id';
    else
      l_dimension_id	:= 'eni_cat.imm_child_id';
    end if;
    l_dimension_view	:= 'ENI_ITEM_VBH_NODES_V';
    l_dim_where_clause	:= '
    AND	dim_view.parent_id = dim_view.child_id';
  end if;

  if (l_cust <> 'All') then
    l_cust_where := '
			    AND fact.customer_id in (&CUSTOMER+PROSPECT)';
  end if;

  if (l_class <> 'All') then
    l_class_where := '
			    AND fact.class_code in (&FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS)';
  end if;

  if (l_prod <> 'All') then
    l_prod_where := '
			    AND fact.product_id in (&ITEM+ENI_ITEM)';
  else
    if (l_leaf_cat <> 'All') then
      l_leaf_cat_where := '
			    AND fact.item_category_id = &ITEM+ENI_ITEM_PROD_LEAF_CAT';
    else
      if (l_prod_cat <> 'All') then
	l_prod_cat_from  := ',
				ENI_DENORM_HIERARCHIES		eni_cat,
				MTL_DEFAULT_CATEGORY_SETS	mdcs';
	l_prod_cat_where := '
			    AND fact.item_category_id 	= eni_cat.child_id
			    AND eni_cat.parent_id 	= &ITEM+ENI_ITEM_VBH_CAT
			    AND eni_cat.dbi_flag 	= ''Y''
			    AND eni_cat.object_type 	= ''CATEGORY_SET''
			    AND eni_cat.object_id 	= mdcs.category_set_id
			    AND mdcs.functional_area_id	= 11';
      end if;
    end if;
  end if;

  if (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then
    l_prod_cat_from  := ',
				ENI_DENORM_HIERARCHIES		eni_cat,
				MTL_DEFAULT_CATEGORY_SETS	mdcs';
    l_prod_cat_where := '
			    AND fact.item_category_id = eni_cat.child_id
			    AND eni_cat.dbi_flag = ''Y''
			    AND eni_cat.object_type = ''CATEGORY_SET''
			    AND eni_cat.object_id = mdcs.category_set_id
			    AND mdcs.functional_area_id = 11';
    if (l_prod_cat = 'All') then
      l_prod_cat_where := l_prod_cat_where||'
			    AND eni_cat.top_node_flag = ''Y''';
    else
      l_prod_cat_where := l_prod_cat_where||'
			    AND eni_cat.parent_id = &ITEM+ENI_ITEM_VBH_CAT';
    end if;
  end if;

  if (l_prod <> 'All' or l_view_by = 'ITEM+ENI_ITEM') then
    l_item_cat_flag := 0;
  else
    if (l_leaf_cat <> 'All' or l_view_by = 'ITEM+ENI_ITEM_PROD_LEAF_CAT' or
	l_prod_cat <> 'All' or l_view_by = 'ITEM+ENI_ITEM_VBH_CAT') then
      l_item_cat_flag := 1;
    else
      l_item_cat_flag := 3;
    end if;
  end if;

  if (l_cust = 'All') then
    if (l_view_by = 'CUSTOMER+PROSPECT')
      then l_cust_flag := 0; -- customer
    elsif (l_view_by = 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS')
      then l_cust_flag := 1; -- customer classification
    else
      if (l_class = 'All')
	then l_cust_flag := 3; -- all
	else l_cust_flag := 1; -- customer classification
      end if;
    end if;
  else
    l_cust_flag := 0; -- customer
  end if;

  if (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT' and l_leaf_cat = 'All' and l_prod = 'All' and l_cust = 'All' and l_class = 'All') then
    l_mv1 := 'ISC_DBI_CPM_003_MV';
    l_mv2 := 'ISC_DBI_CPM_004_MV';
    l_prod_cat_from := '';
    if (l_prod_cat = 'All') then
      l_dimension_id := 'fact.parent_id';
      l_prod_cat_where := '
			    AND fact.top_node_flag = ''Y''';
    else
      l_dimension_id := 'fact.imm_child_id';
      l_prod_cat_where := '
			    AND fact.parent_id = &ITEM+ENI_ITEM_VBH_CAT';
    end if;
  else
    l_mv1 := 'ISC_DBI_CPM_000_MV';
    l_mv2 := 'ISC_DBI_CPM_001_MV';
  end if;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  l_measures := 'isc_measure_1,  isc_measure_2,  isc_measure_3,  isc_measure_4,  isc_measure_5,
	isc_measure_6,  isc_measure_7,  isc_measure_8,  isc_measure_9,  isc_measure_10,
	isc_measure_11, isc_measure_12, isc_measure_13, isc_measure_14, isc_measure_15,
	isc_measure_16, isc_measure_17';

  l_stmt := '
 SELECT	/*+ LEADING(a) INDEX(dim_view) */ dim_view.value	VIEWBY,
	dim_view.id				VIEWBYID,
	'||l_drill_prod_cat||'			ISC_ATTRIBUTE_1,
	'||l_drill_leaf_cat||'			ISC_ATTRIBUTE_2,
	'||l_measures||'
   FROM
(SELECT	(rank() over (&ORDER_BY_CLAUSE nulls last, dimension_id)) - 1	RNK,
	dimension_id,
	'||l_measures||'
   FROM	(SELECT	c.dimension_id						DIMENSION_ID,
		c.curr_active						ISC_MEASURE_1,
		(c.curr_active - c.prev_active)
		  / decode(c.prev_active, 0, null,
			   abs(c.prev_active))
		  * 100							ISC_MEASURE_2,
		c.curr_new						ISC_MEASURE_3,
		(c.curr_new - c.prev_new)
		  / decode(c.prev_new, 0, null,
			   abs(c.prev_new))
		  * 100							ISC_MEASURE_4,
		c.curr_new
		  / decode(c.curr_active, 0, null,
			   c.curr_active)
		  * 100							ISC_MEASURE_5,
		c.curr_new
		  / decode(c.curr_active, 0, null,
			   c.curr_active)
		  * 100
		- c.prev_new
		  / decode(c.prev_active, 0, null,
			   c.prev_active)
		  * 100							ISC_MEASURE_6,
		c.curr_renew						ISC_MEASURE_7,
		(c.curr_renew - c.prev_renew)
		  / decode(c.prev_renew, 0, null,
			   abs(c.prev_renew))
		  * 100							ISC_MEASURE_8,
		sum(c.curr_active) over ()				ISC_MEASURE_9,
		(sum(c.curr_active) over () - sum(c.prev_active) over ())
		  / decode(sum(c.prev_active) over (), 0, null,
			   abs(sum(c.prev_active) over ()))
		  * 100							ISC_MEASURE_10,
		sum(c.curr_new) over ()					ISC_MEASURE_11,
		(sum(c.curr_new) over () - sum(c.prev_new) over ())
		  / decode(sum(c.prev_new) over (), 0, null,
			   abs(sum(c.prev_new) over ()))
		  * 100							ISC_MEASURE_12,
		sum(c.curr_new) over ()
		  / decode(sum(c.curr_active) over (), 0, null,
			   sum(c.curr_active) over ())
		  * 100							ISC_MEASURE_13,
		sum(c.curr_new) over ()
		  / decode(sum(c.curr_active) over (), 0, null,
			   sum(c.curr_active) over ())
		  * 100
		- sum(c.prev_new) over ()
		  / decode(sum(c.prev_active) over (), 0, null,
			   sum(c.prev_active) over ())
		  * 100							ISC_MEASURE_14,
		sum(c.curr_renew) over ()				ISC_MEASURE_15,
		(sum(c.curr_renew) over () - sum(c.prev_renew) over ())
		  / decode(sum(c.prev_renew) over (), 0, null,
			   abs(sum(c.prev_renew) over ()))
		  * 100							ISC_MEASURE_16,
		c.prev_active						ISC_MEASURE_17
	   FROM	(SELECT dimension_id			DIMENSION_ID,
			sum(curr_active)		CURR_ACTIVE,
			sum(prev_active)		PREV_ACTIVE,
			sum(curr_new)			CURR_NEW,
			sum(prev_new)			PREV_NEW,
			sum(curr_renew)			CURR_RENEW,
			sum(prev_renew)			PREV_RENEW
		   FROM	(SELECT '||l_dimension_id||'									DIMENSION_ID,
				decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
					nvl(fact.activated'||sfx||',0)-nvl(fact.expired'||sfx||',0), 0)			CURR_ACTIVE,
				decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
					nvl(fact.activated'||sfx||',0)-nvl(fact.expired'||sfx||',0), 0)			PREV_ACTIVE,
				decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
					nvl(fact.activated_new'||sfx||',0)-nvl(fact.expired_new'||sfx||',0), 0)		CURR_NEW,
				decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
					nvl(fact.activated_new'||sfx||',0)-nvl(fact.expired_new'||sfx||',0), 0)		PREV_NEW,
				decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
					nvl(fact.activated_renew'||sfx||',0)-nvl(fact.expired_renew'||sfx||',0), 0)	CURR_RENEW,
				decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
					nvl(fact.activated_renew'||sfx||',0)-nvl(fact.expired_renew'||sfx||',0), 0)	PREV_RENEW
			   FROM	'||l_mv1     ||'		fact,
				FII_TIME_RPT_STRUCT_V		cal'||l_prod_cat_from||'
			  WHERE	cal.report_date in (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
			    AND	bitand(cal.record_type_id, 119) = cal.record_type_id
			    AND cal.time_id = fact.time_id
			    AND fact.item_cat_flag = :ISC_ITEM_CAT_FLAG
			    AND fact.customer_flag = :ISC_CUST_FLAG		'||l_prod_cat_where||l_leaf_cat_where||l_prod_where||l_cust_where||l_class_where||'
			UNION ALL
			 SELECT	'||l_dimension_id||'							DIMENSION_ID,
				decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
					nvl(fact.active'||sfx||',0), 0)					CURR_ACTIVE,
				decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
					nvl(fact.active'||sfx||',0), 0)					PREV_ACTIVE,
				decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
					nvl(fact.active_new'||sfx||',0), 0)				CURR_NEW,
				decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
					nvl(fact.active_new'||sfx||',0), 0)				PREV_NEW,
				decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
					nvl(fact.active_renew'||sfx||',0), 0)				CURR_RENEW,
				decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
					nvl(fact.active_renew'||sfx||',0), 0)				PREV_RENEW
			   FROM	'||l_mv2     ||'		fact,
				FII_TIME_DAY			cal'||l_prod_cat_from||'
			  WHERE	cal.report_date in (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
			    AND	cal.ent_year_id = fact.ent_year_id
			    AND fact.item_cat_flag = :ISC_ITEM_CAT_FLAG
			    AND fact.customer_flag = :ISC_CUST_FLAG		'||l_prod_cat_where||l_leaf_cat_where||l_prod_where||l_cust_where||l_class_where||'	)
		GROUP BY dimension_id)	c
	  WHERE	c.curr_active <> 0
	     OR	c.prev_active <> 0
	     OR	c.curr_new <> 0
	     OR c.prev_new <> 0
	     OR	c.curr_renew <> 0
	     OR	c.prev_renew <> 0))	a,
	'||l_dimension_view||'			dim_view
  WHERE	a.dimension_id = dim_view.id
    AND ((a.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))'||l_dim_where_clause||'
ORDER BY rnk';

  x_custom_sql := l_stmt;

  l_custom_rec.attribute_name := ':ISC_ITEM_CAT_FLAG';
  l_custom_rec.attribute_value := to_char(l_item_cat_flag);
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
  x_custom_output.extend;
  x_custom_output(1) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_CUST_FLAG';
  l_custom_rec.attribute_value := to_char(l_cust_flag);
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
  x_custom_output.extend;
  x_custom_output(2) := l_custom_rec;

END Get_Sql;

END ISC_DBI_CPM_SPT_COMP_PKG;

/
