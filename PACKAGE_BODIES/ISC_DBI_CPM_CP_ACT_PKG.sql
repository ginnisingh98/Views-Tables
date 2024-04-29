--------------------------------------------------------
--  DDL for Package Body ISC_DBI_CPM_CP_ACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_CPM_CP_ACT_PKG" AS
/* $Header: ISCRGB7B.pls 120.0 2005/05/25 17:41:50 appldev noship $ */

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

FUNCTION biv_column_name (
p_param			in		varchar2
) return varchar2 is
  l_param 	varchar2(1000);
begin
  l_param := p_param;
  l_param := replace(l_param, 'fact.top_node_flag',	'fact.vbh_top_node_flag');
  l_param := replace(l_param, 'fact.parent_id',		'fact.vbh_parent_category_id');
  l_param := replace(l_param, 'fact.imm_child_id',	'fact.vbh_child_category_id');
  l_param := replace(l_param, 'fact.item_category_id', 	'fact.vbh_category_id');
  return l_param;
end biv_column_name;

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
  l_drill_active		VARCHAR2(32000);
  l_drill_leaf_cat		VARCHAR2(32000);
  l_dimension_id		VARCHAR2(32000);
  l_dimension_view		VARCHAR2(32000);
  l_dim_where_clause		VARCHAR2(32000);

  l_prod_where			VARCHAR2(32000) := '';
  l_leaf_cat_where		VARCHAR2(32000) := '';
  l_prod_cat_where		VARCHAR2(32000) := '';
  l_cust_where			VARCHAR2(32000) := '';
  l_class_where			VARCHAR2(32000) := '';
  l_biv_flag_where		VARCHAR2(32000) := '';

  l_prod_cat_from		VARCHAR2(32000) := '';

  l_item_cat_flag		NUMBER;
  l_cust_flag			NUMBER;
  l_biv_flag			NUMBER;

  l_mv1				VARCHAR2(1000);
  l_mv2				VARCHAR2(1000);
  l_mv3				VARCHAR2(1000);
  l_mv4				VARCHAR2(1000);

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
    l_drill_active	:= '''pFunctionName=ISC_DBI_CPM_SPT_COMP&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+PROSPECT&pParamIds=Y''';
    l_drill_leaf_cat	:= 'null';
    l_dimension_id	:= 'fact.customer_id';
    l_dimension_view	:= 'ASO_BI_PROSPECT_V';
    l_dim_where_clause	:= '';

  elsif (l_view_by = 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS') then
    l_drill_prod_cat	:= 'null';
    l_drill_active	:= 'null';
    l_drill_leaf_cat	:= 'null';
    l_dimension_id	:= 'fact.class_code';
    l_dimension_view	:= 'FII_PARTNER_MKT_CLASS_V';
    l_dim_where_clause	:= '';

  elsif (l_view_by = 'ITEM+ENI_ITEM') then
    l_drill_prod_cat	:= 'null';
    l_drill_active	:= '''pFunctionName=ISC_DBI_CPM_SPT_COMP&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+PROSPECT&pParamIds=Y''';
    l_drill_leaf_cat	:= 'null';
    l_dimension_id	:= 'fact.product_id';
    l_dimension_view	:= 'ENI_OLTP_ITEM_STAR';
    l_dim_where_clause	:= '
    AND dim_view.master_id is null';

  elsif (l_view_by = 'ITEM+ENI_ITEM_PROD_LEAF_CAT') then
    l_drill_prod_cat	:= 'null';
    l_drill_active	:= '''pFunctionName=ISC_DBI_CPM_SPT_COMP&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+PROSPECT&pParamIds=Y''';
    l_drill_leaf_cat	:= '''pFunctionName=ISC_DBI_CPM_CP_ACT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM&pParamIds=Y''';
    l_dimension_id	:= 'fact.item_category_id';
    l_dimension_view	:= 'ENI_ITEM_PROD_LEAF_CAT_V';
    l_dim_where_clause	:= '';

  else -- l_view_by = 'ITEM+ENI_ITEM_VBH_CAT'
    l_drill_prod_cat	:= 'decode(dim_view.leaf_node_flag, ''Y'',
	''pFunctionName=ISC_DBI_CPM_CP_ACT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM&pParamIds=Y'',
	''pFunctionName=ISC_DBI_CPM_CP_ACT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_VBH_CAT&pParamIds=Y'')';
    l_drill_active	:= 'decode(dim_view.leaf_node_flag, ''Y'',
	''pFunctionName=ISC_DBI_CPM_SPT_COMP&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+PROSPECT&pParamIds=Y'', null)';
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

  if (((l_prod <> 'All' or l_view_by = 'ITEM+ENI_ITEM') and (l_cust <> 'All' or l_view_by = 'CUSTOMER+PROSPECT'))
      or
      ((l_prod <> 'All' or l_view_by = 'ITEM+ENI_ITEM') and (l_class <> 'All' or l_view_by = 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS')))
         then
    l_biv_flag := 0;
  elsif (l_cust <> 'All' or l_view_by = 'CUSTOMER+PROSPECT') then
    l_biv_flag := 2;
  elsif (l_class <> 'All' or l_view_by = 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS') then
    l_biv_flag := 4;
  elsif (l_prod <> 'All' or l_view_by = 'ITEM+ENI_ITEM') then
    l_biv_flag := 1;
  else
    l_biv_flag := 5;
  end if;

  if (l_view_by = 'ITEM+ENI_ITEM_VBH_CAT' and l_leaf_cat = 'All' and l_prod = 'All' and l_cust = 'All' and l_class = 'All') then
    l_mv1 := 'ISC_DBI_CPM_003_MV';
    l_mv2 := 'ISC_DBI_CPM_004_MV';
    l_mv3 := 'ISC_DBI_CPM_005_MV';
    l_mv4 := 'BIV_ACT_H_SUM_MV';
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
    l_mv3 := 'ISC_DBI_CPM_002_MV';
    l_mv4 := 'BIV_ACT_SUM_MV';
    l_biv_flag_where := '
			    AND fact.grp_id = :ISC_BIV_FLAG';
  end if;

  l_custom_rec := BIS_PMV_PARAMETERS_PUB.Initialize_Query_Type;
  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  l_measures := 'isc_measure_1,  isc_measure_2,  isc_measure_3,  isc_measure_4,  isc_measure_5,
	isc_measure_6,  isc_measure_7,  isc_measure_8,  isc_measure_9,  isc_measure_10,
	isc_measure_11, isc_measure_12, isc_measure_13, isc_measure_14, isc_measure_15,
	isc_measure_16, isc_measure_17, isc_measure_19, isc_measure_20,
	isc_measure_21, isc_measure_22, isc_measure_23, isc_measure_24, isc_measure_25,
	isc_measure_26, isc_measure_27, isc_measure_28, isc_measure_29, isc_measure_30,
	isc_measure_31';

  l_stmt := '
 SELECT	/*+ LEADING(a) INDEX(dim_view) */ dim_view.value	VIEWBY,
	dim_view.id						VIEWBYID,
	'||l_drill_prod_cat||'					ISC_ATTRIBUTE_1,
	'||l_drill_leaf_cat||'					ISC_ATTRIBUTE_2,
	'||l_drill_active||'					ISC_ATTRIBUTE_3,
	'||l_measures||'
   FROM
(SELECT	(rank() over (&ORDER_BY_CLAUSE nulls last, dimension_id)) - 1	RNK,
	dimension_id,
	'||l_measures||'
   FROM	(SELECT	c.dimension_id						DIMENSION_ID,
		c.curr_book						ISC_MEASURE_1,
		(c.curr_book - c.prev_book)
		  / decode(c.prev_book, 0, null, abs(c.prev_book))
		  * 100							ISC_MEASURE_2,
		c.curr_serv						ISC_MEASURE_3,
		(c.curr_serv - c.prev_serv)
		  / decode(c.prev_serv, 0, null, abs(c.prev_serv))
		  * 100							ISC_MEASURE_4,
		c.curr_active						ISC_MEASURE_5,
		(c.curr_active - c.prev_active)
		  / decode(c.prev_active, 0, null, abs(c.prev_active))
		  * 100							ISC_MEASURE_6,
		c.curr_active
		  / decode(sum(c.curr_active) over (), 0, null,
			   sum(c.curr_active) over ())
		  * 100							ISC_MEASURE_7,
		c.curr_active
		  / decode(sum(c.curr_active) over (), 0, null,
			   sum(c.curr_active) over ()) * 100
		- c.prev_active
		  / decode(sum(c.prev_active) over (), 0, null,
			   sum(c.prev_active) over ()) * 100		ISC_MEASURE_8,
		0							ISC_MEASURE_9,
		0							ISC_MEASURE_10,
		sum(c.curr_book) over ()				ISC_MEASURE_11,
		(sum(c.curr_book) over () - sum(c.prev_book) over ())
		  / decode(sum(c.prev_book) over (), 0, null,
			   abs(sum(c.prev_book) over ()))
		  * 100							ISC_MEASURE_12,
		sum(c.curr_serv) over ()				ISC_MEASURE_13,
		(sum(c.curr_serv) over () - sum(c.prev_serv) over ())
		  / decode(sum(c.prev_serv) over (), 0, null,
			   abs(sum(c.prev_serv) over ()))
		  * 100							ISC_MEASURE_14,
		sum(c.curr_active) over ()				ISC_MEASURE_15,
		(sum(c.curr_active) over () - sum(c.prev_active) over ())
		  / decode(sum(c.prev_active) over (), 0, null,
			   abs(sum(c.prev_active) over ()))
		  * 100							ISC_MEASURE_16,
		sum(c.curr_active) over ()
		  / decode(sum(c.curr_active) over (), 0, null,
			   sum(c.curr_active) over ()) * 100		ISC_MEASURE_17,
		0							ISC_MEASURE_19,
		0							ISC_MEASURE_20,
		c.prev_book						ISC_MEASURE_21,
		c.prev_serv						ISC_MEASURE_22,
		c.prev_active						ISC_MEASURE_23,
		c.curr_active						ISC_MEASURE_24,
		c.prev_active						ISC_MEASURE_25,
		c.curr_serv						ISC_MEASURE_26,
		c.prev_serv						ISC_MEASURE_27,
		sum(c.curr_active) over ()				ISC_MEASURE_28,
		sum(c.prev_active) over ()				ISC_MEASURE_29,
		sum(c.curr_serv) over ()				ISC_MEASURE_30,
		sum(c.prev_serv) over ()				ISC_MEASURE_31
	   FROM	(SELECT dimension_id			DIMENSION_ID,
			sum(curr_book)			CURR_BOOK,
			sum(prev_book)			PREV_BOOK,
			sum(curr_serv)			CURR_SERV,
			sum(prev_serv)			PREV_SERV,
			sum(curr_active)		CURR_ACTIVE,
			sum(prev_active)		PREV_ACTIVE
		   FROM	(SELECT '||l_dimension_id||'								DIMENSION_ID,
				0										CURR_BOOK,
				0										PREV_BOOK,
				0										CURR_SERV,
				0										PREV_SERV,
				decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
					nvl(fact.activated'||sfx||',0)-nvl(fact.expired'||sfx||',0), 0)		CURR_ACTIVE,
				decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
					nvl(fact.activated'||sfx||',0)-nvl(fact.expired'||sfx||',0), 0)		PREV_ACTIVE
			   FROM	'||l_mv1     ||'		fact,
				FII_TIME_RPT_STRUCT_V		cal'||l_prod_cat_from||'
			  WHERE	cal.report_date in (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
			    AND	bitand(cal.record_type_id, 119) = cal.record_type_id
			    AND cal.time_id = fact.time_id
			    AND fact.item_cat_flag = :ISC_ITEM_CAT_FLAG
			    AND fact.customer_flag = :ISC_CUST_FLAG		'||l_prod_cat_where||l_leaf_cat_where||l_prod_where||l_cust_where||l_class_where||'
			UNION ALL
			 SELECT	'||l_dimension_id||'					DIMENSION_ID,
				0							CURR_BOOK,
				0							PREV_BOOK,
				0							CURR_SERV,
				0							PREV_SERV,
				decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
					nvl(fact.active'||sfx||',0), 0)			CURR_ACTIVE,
				decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
					nvl(fact.active'||sfx||',0), 0)			PREV_ACTIVE
			   FROM	'||l_mv2     ||'		fact,
				FII_TIME_DAY			cal'||l_prod_cat_from||'
			  WHERE	cal.report_date in (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
			    AND	cal.ent_year_id = fact.ent_year_id
			    AND fact.item_cat_flag = :ISC_ITEM_CAT_FLAG
			    AND fact.customer_flag = :ISC_CUST_FLAG		'||l_prod_cat_where||l_leaf_cat_where||l_prod_where||l_cust_where||l_class_where||'
			UNION ALL
			 SELECT	'||l_dimension_id||'									DIMENSION_ID,
				decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
					nvl(fact.booked_amt'||sfx||',0)-nvl(fact.returned_amt'||sfx||',0), 0)		CURR_BOOK,
				decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
					nvl(fact.booked_amt'||sfx||',0)-nvl(fact.returned_amt'||sfx||',0), 0)		PREV_BOOK,
				0											CURR_SERV,
				0											PREV_SERV,
				0											CURR_ACTIVE,
				0											PREV_ACTIVE
			   FROM	'||l_mv3     ||'		fact,
				FII_TIME_RPT_STRUCT_V		cal'||l_prod_cat_from||'
			  WHERE	cal.report_date in (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
			    AND	bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id
			    AND cal.time_id = fact.time_id
			    AND fact.item_cat_flag = :ISC_ITEM_CAT_FLAG
			    AND fact.customer_flag = :ISC_CUST_FLAG	'||l_prod_cat_where||l_leaf_cat_where||l_prod_where||l_cust_where||l_class_where||'
			UNION ALL
			 SELECT	'||biv_column_name(l_dimension_id)||'			DIMENSION_ID,
				0							CURR_BOOK,
				0							PREV_BOOK,
				decode(cal.report_date, &BIS_CURRENT_ASOF_DATE,
					nvl(fact.first_opened_count,0), 0)		CURR_SERV,
				decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE,
					nvl(fact.first_opened_count,0), 0)		PREV_SERV,
				0							CURR_ACTIVE,
				0							PREV_ACTIVE
			   FROM	'||l_mv4	||'		fact,
				FII_TIME_RPT_STRUCT_V		cal'||l_prod_cat_from||'
			  WHERE	cal.report_date in (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE)
			    AND	bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id
			    AND cal.time_id = fact.time_id
			    AND cal.period_type_id = fact.period_type_id	'
			||l_biv_flag_where
			||biv_column_name(l_prod_cat_where)
			||biv_column_name(l_leaf_cat_where)
			||l_prod_where
			||l_cust_where||l_class_where||'	)
		GROUP BY dimension_id)	c
	  WHERE	c.curr_book <> 0
	     OR	c.prev_book <> 0
	     OR	c.curr_serv <> 0
	     OR c.prev_serv <> 0
	     OR	c.curr_active <> 0
	     OR	c.prev_active <> 0))		a,
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

  l_custom_rec.attribute_name := ':ISC_BIV_FLAG';
  l_custom_rec.attribute_value := to_char(l_biv_flag);
  l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
  x_custom_output.extend;
  x_custom_output(3) := l_custom_rec;

END Get_Sql;

END ISC_DBI_CPM_CP_ACT_PKG;

/
