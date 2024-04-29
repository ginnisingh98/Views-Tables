--------------------------------------------------------
--  DDL for Package Body ISC_DBI_CPM_CP_ACT_TREND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_CPM_CP_ACT_TREND_PKG" AS
/* $Header: ISCRGBMB.pls 120.0 2005/05/25 17:30:42 appldev noship $ */

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

  l_period_type			VARCHAR2(32000);
  l_prod_cat			VARCHAR2(32000) := 'All';
  l_leaf_cat			VARCHAR2(32000) := 'All';
  l_prod			VARCHAR2(32000) := 'All';
  l_cust			VARCHAR2(32000) := 'All';
  l_class			VARCHAR2(32000) := 'All';
  l_curr			VARCHAR2(32000);

  l_curr_g			VARCHAR2(100) := '''FII_GLOBAL1''';
  l_curr_g1			VARCHAR2(100) := '''FII_GLOBAL2''';
  sfx				VARCHAR2(100);

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

  l_dates_subquery		VARCHAR2(32000);

  l_custom_rec			BIS_QUERY_ATTRIBUTES;

begin

  for i in 1..p_param.count
  loop
    case p_param(i).parameter_name
      when 'PERIOD_TYPE'			then l_period_type := get_parameter_value(p_param(i));
      when 'ITEM+ENI_ITEM_VBH_CAT' 		then l_prod_cat	   := get_parameter_value(p_param(i));
      when 'ITEM+ENI_ITEM_PROD_LEAF_CAT'	then l_leaf_cat	   := get_parameter_value(p_param(i));
      when 'ITEM+ENI_ITEM' 			then l_prod	   := get_parameter_value(p_param(i));
      when 'CUSTOMER+PROSPECT' 			then l_cust	   := get_parameter_value(p_param(i));
      when 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS'
						then l_class	:= get_parameter_value(p_param(i));
      when 'CURRENCY+FII_CURRENCIES' 		then l_curr	   := get_parameter_value(p_param(i));
      else null;
    end case;
  end loop;

  if (l_curr = l_curr_g1) then
    sfx := '_g1';
  else
    sfx := '_g';
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

  if (l_prod <> 'All') then
    l_item_cat_flag := 0;
  else
    if (l_leaf_cat <> 'All' or l_prod_cat <> 'All') then
      l_item_cat_flag := 1;
    else
      l_item_cat_flag := 3;
    end if;
  end if;

  if (l_cust = 'All') then
    if (l_class = 'All')
      then l_cust_flag := 3; -- all
      else l_cust_flag := 1; -- customer classification
    end if;
  else
    l_cust_flag := 0; -- customer
  end if;

  if ((l_cust <> 'All' and l_prod <> 'All') or
      (l_class <> 'All' and l_prod <> 'All')) then
    l_biv_flag := 0;
  elsif (l_cust <> 'All') then
    l_biv_flag := 2;
  elsif (l_class <> 'All') then
    l_biv_flag := 4;
  elsif (l_prod <> 'All') then
    l_biv_flag := 1;
  else
    l_biv_flag := 5;
  end if;

  if (l_leaf_cat = 'All' and l_prod = 'All' and l_cust = 'All' and l_class = 'All') then
    l_mv1 := 'ISC_DBI_CPM_003_MV';
    l_mv2 := 'ISC_DBI_CPM_004_MV';
    l_mv3 := 'ISC_DBI_CPM_005_MV';
    l_mv4 := 'BIV_ACT_H_SUM_MV';
    l_prod_cat_from := '';
    l_item_cat_flag := 1;
    l_cust_flag     := 3;
    if (l_prod_cat = 'All') then
      l_prod_cat_where := '
			    AND fact.top_node_flag = ''Y''';
    else
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

  l_dates_subquery := '		(SELECT	fii.start_date					START_DATE,
					''C''						PERIOD,
					least(fii.end_date, &BIS_CURRENT_ASOF_DATE)	REPORT_DATE
				   FROM	'||l_period_type||'	fii
				  WHERE	fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
							   AND &BIS_CURRENT_ASOF_DATE
				UNION ALL
				 SELECT	p2.start_date					START_DATE,
					''P''						PERIOD,
					p1.report_date					REPORT_DATE
				   FROM	(SELECT	least(fii.end_date, &BIS_PREVIOUS_ASOF_DATE)	REPORT_DATE,
						rownum						ID
					   FROM	'||l_period_type||'	fii
					  WHERE	fii.start_date BETWEEN &BIS_PREVIOUS_REPORT_START_DATE
								   AND &BIS_PREVIOUS_ASOF_DATE
					  ORDER BY fii.start_date DESC) p1,
					(SELECT	fii.start_date					START_DATE,
						rownum						ID
					   FROM	'||l_period_type||'	fii
					  WHERE	fii.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
								   AND &BIS_CURRENT_ASOF_DATE
					  ORDER BY fii.start_date DESC) p2
				  WHERE	p1.id(+) = p2.id)';

  l_stmt := '
	 SELECT	dim_view.name						VIEWBY,
		nvl(c.prev_book,0)					ISC_MEASURE_1,
		nvL(c.curr_book,0)					ISC_MEASURE_2,
		(c.curr_book - c.prev_book)
		  / decode(c.prev_book, 0, null, abs(c.prev_book))
		  * 100							ISC_MEASURE_3,
		nvl(c.prev_serv,0)					ISC_MEASURE_4,
		nvl(c.curr_serv,0)					ISC_MEASURE_5,
		(c.curr_serv - c.prev_serv)
		  / decode(c.prev_serv, 0, null, abs(c.prev_serv))
		  * 100							ISC_MEASURE_6,
		nvl(c.prev_active,0)					ISC_MEASURE_7,
		nvl(c.curr_active,0)					ISC_MEASURE_8,
		(c.curr_active - c.prev_active)
		  / decode(c.prev_active, 0, null, abs(c.prev_active))
		  * 100							ISC_MEASURE_9
	   FROM	(SELECT dimension_id			DIMENSION_ID,
			sum(curr_book)			CURR_BOOK,
			sum(prev_book)			PREV_BOOK,
			sum(curr_serv)			CURR_SERV,
			sum(prev_serv)			PREV_SERV,
			sum(curr_active)		CURR_ACTIVE,
			sum(prev_active)		PREV_ACTIVE
		   FROM	(SELECT dates.start_date								DIMENSION_ID,
				0										CURR_BOOK,
				0										PREV_BOOK,
				0										CURR_SERV,
				0										PREV_SERV,
				decode(dates.period, ''C'',
					nvl(fact.activated'||sfx||',0)-nvl(fact.expired'||sfx||',0), 0)		CURR_ACTIVE,
				decode(dates.period, ''P'',
					nvl(fact.activated'||sfx||',0)-nvl(fact.expired'||sfx||',0), 0)		PREV_ACTIVE
			   FROM	'||l_dates_subquery||'		dates,
				'||l_mv1     ||'		fact,
				FII_TIME_RPT_STRUCT_V		cal'||l_prod_cat_from||'
			  WHERE	cal.report_date = dates.report_date
			    AND	bitand(cal.record_type_id, 119) = cal.record_type_id
			    AND cal.time_id = fact.time_id
			    AND fact.item_cat_flag = :ISC_ITEM_CAT_FLAG
			    AND fact.customer_flag = :ISC_CUST_FLAG		'||l_prod_cat_where||l_leaf_cat_where||l_prod_where||l_cust_where||l_class_where||'
			UNION ALL
			 SELECT	dates.start_date					DIMENSION_ID,
				0							CURR_BOOK,
				0							PREV_BOOK,
				0							CURR_SERV,
				0							PREV_SERV,
				decode(dates.period, ''C'',
					nvl(fact.active'||sfx||',0), 0)			CURR_ACTIVE,
				decode(dates.period, ''P'',
					nvl(fact.active'||sfx||',0), 0)			PREV_ACTIVE
			   FROM	'||l_dates_subquery||'		dates,
				'||l_mv2     ||'		fact,
				FII_TIME_DAY			cal'||l_prod_cat_from||'
			  WHERE	cal.report_date = dates.report_date
			    AND	cal.ent_year_id = fact.ent_year_id
			    AND fact.item_cat_flag = :ISC_ITEM_CAT_FLAG
			    AND fact.customer_flag = :ISC_CUST_FLAG		'||l_prod_cat_where||l_leaf_cat_where||l_prod_where||l_cust_where||l_class_where||'
			UNION ALL
			 SELECT	dates.start_date									DIMENSION_ID,
				decode(dates.period, ''C'',
					nvl(fact.booked_amt'||sfx||',0)-nvl(fact.returned_amt'||sfx||',0), 0)		CURR_BOOK,
				decode(dates.period, ''P'',
					nvl(fact.booked_amt'||sfx||',0)-nvl(fact.returned_amt'||sfx||',0), 0)		PREV_BOOK,
				0											CURR_SERV,
				0											PREV_SERV,
				0											CURR_ACTIVE,
				0											PREV_ACTIVE
			   FROM	'||l_dates_subquery||'		dates,
				'||l_mv3     ||'		fact,
				FII_TIME_RPT_STRUCT_V		cal'||l_prod_cat_from||'
			  WHERE	cal.report_date = dates.report_date
			    AND	bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id
			    AND cal.time_id = fact.time_id
			    AND fact.item_cat_flag = :ISC_ITEM_CAT_FLAG
			    AND fact.customer_flag = :ISC_CUST_FLAG	'||l_prod_cat_where||l_leaf_cat_where||l_prod_where||l_cust_where||l_class_where||'
			UNION ALL
			 SELECT	dates.start_date					DIMENSION_ID,
				0							CURR_BOOK,
				0							PREV_BOOK,
				decode(dates.period, ''C'',
					nvl(fact.first_opened_count,0), 0)		CURR_SERV,
				decode(dates.period, ''P'',
					nvl(fact.first_opened_count,0), 0)		PREV_SERV,
				0							CURR_ACTIVE,
				0							PREV_ACTIVE
			   FROM	'||l_dates_subquery||'		dates,
				'||l_mv4	||'		fact,
				FII_TIME_RPT_STRUCT_V		cal'||l_prod_cat_from||'
			  WHERE	cal.report_date = dates.report_date
			    AND	bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id
			    AND cal.time_id = fact.time_id
			    AND cal.period_type_id = fact.period_type_id	'
			||l_biv_flag_where
			||biv_column_name(l_prod_cat_where)
			||biv_column_name(l_leaf_cat_where)
			||l_prod_where
			||l_cust_where||l_class_where||'	)
		GROUP BY dimension_id)		c,
	'||l_period_type||'			dim_view
  WHERE	dim_view.start_date BETWEEN &BIS_CURRENT_REPORT_START_DATE
				AND &BIS_CURRENT_ASOF_DATE
    AND	dim_view.start_date = c.dimension_id(+)
ORDER BY dim_view.start_date';

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

END ISC_DBI_CPM_CP_ACT_TREND_PKG;

/
