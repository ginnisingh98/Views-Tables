--------------------------------------------------------
--  DDL for Package Body ISC_DBI_SAM_AGR_ORD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_SAM_AGR_ORD_PKG" as
/* $Header: ISCRGCDB.pls 120.6 2005/12/15 16:57:00 scheung noship $ */

procedure get_sql (	p_param		in		bis_pmv_page_parameter_tbl,
			x_custom_sql	out nocopy	varchar2,
			x_custom_output	out nocopy	bis_query_attributes_tbl) is

  l_view_by              varchar2(32000);
  l_sgid                 varchar2(32000);
  l_class                varchar2(32000);
  l_cust                 varchar2(32000);
  l_curr                 varchar2(32000);
  l_curr_suffix          varchar2(32000);
  l_sg_sg                number;
  l_sg_res               number;
  l_sg_where             varchar2(32000);
  l_class_where          varchar2(32000);
  l_cust_where           varchar2(32000);
  l_class_needed         boolean;
  l_cust_needed          boolean;
  l_agg_level            number;
  l_sg_drill_str         varchar2(32000);
  l_class_drill_str      varchar2(32000);
  l_col_drill_str        varchar2(32000);
  l_viewby_col_str       varchar2(32000);
  l_viewby_select_str    varchar2(32000);
  l_viewbyid_select_str  varchar2(32000);
  l_dim_join_str         varchar2(32000);
  l_query                varchar2(32000);
  l_custom_rec           bis_query_attributes;

begin

  -- Get all necessary parameters from PMV
  for i in 1..p_param.count loop

    if (p_param(i).parameter_name = 'VIEW_BY') then
      l_view_by := p_param(i).parameter_value;
    end if;

    if (p_param(i).parameter_name = 'ORGANIZATION+JTF_ORG_SALES_GROUP') then
      l_sgid :=  p_param(i).parameter_id;
    end if;

    if (p_param(i).parameter_name = 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS') then
      l_class :=  p_param(i).parameter_id;
    end if;

    if (p_param(i).parameter_name = 'CUSTOMER+FII_CUSTOMERS') then
      l_cust :=  p_param(i).parameter_id;
    end if;

    if (p_param(i).parameter_name = 'CURRENCY+FII_CURRENCIES') then
      l_curr := p_param(i).parameter_id;
    end if;

  end loop;

  if (l_curr = '''FII_GLOBAL1''') then
    l_curr_suffix := 'g';
  else -- (l_curr = '''FII_GLOBAL2''')
    l_curr_suffix := 'g1';
  end if;

  -- Figure out where clauses
  l_sg_sg   := to_number(replace(substr(l_sgid,instr(l_sgid,'.') + 1),''''));
  l_sg_res  := to_number(replace(substr(l_sgid,1,instr(l_sgid,'.') - 1),''''));

  if (l_sg_res is null) then -- when a sales group is chosen
    l_col_drill_str := 'null  ISC_ATTRIBUTE_5,
null    ISC_ATTRIBUTE_7,';
    if (l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP') then
      l_sg_where := ' and f.parent_grp_id = (&ORGANIZATION+JTF_ORG_SALES_GROUP) and f.grp_marker <> ''TOP GROUP'''; -- exclude the top groups when VB=SG
    else -- other view bys
      l_sg_where := ' and f.sales_grp_id = (&ORGANIZATION+JTF_ORG_SALES_GROUP) and f.resource_id is null';
    end if;
  else -- when the LOV parameter is a Salesrep (no need to go through the SG hierarchy)
    l_col_drill_str := '''pFunctionName=ISC_DBI_SAM_AGR_ORD_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''  ISC_ATTRIBUTE_5,
''pFunctionName=ISC_DBI_SAM_NAGR_ORD_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''    ISC_ATTRIBUTE_7,';
    l_sg_where := ' and f.sales_grp_id = :ISC_SG and f.resource_id = :ISC_RES';
  end if;

  if (l_class is null) then
    l_class_where := '';
  else
    l_class_where := ' and f.class_code in (&FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS)';
  end if;

  if (l_cust is null) then
    l_cust_where := '';
  else
    l_cust_where := ' and f.customer_id in (&CUSTOMER+FII_CUSTOMERS)';
  end if;

  -- Figure out agg_level flag value
  l_class_needed := false;
  l_cust_needed := false;

  if (l_view_by = 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS' or l_class is not null) then
    l_class_needed := true;
  end if;

  if (l_view_by = 'CUSTOMER+FII_CUSTOMERS' or l_cust is not null) then
    l_cust_needed := true;
  end if;

  case
    when (    l_class_needed and     l_cust_needed) then l_agg_level := 0;
    when (    l_class_needed and not l_cust_needed) then l_agg_level := 1;
    when (not l_class_needed and     l_cust_needed) then l_agg_level := 0;
    when (not l_class_needed and not l_cust_needed) then l_agg_level := 3;
  end case;

  -- Figure out pieces of strings to fill in the query
  if (l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP') then
    l_sg_drill_str := 'decode(oset.resource_id, null, ''pFunctionName=ISC_DBI_SAM_AGR_ORD&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'', null)';
    l_class_drill_str := 'null';
    l_col_drill_str := 'decode(oset.resource_id, null, null, ''pFunctionName=ISC_DBI_SAM_AGR_ORD_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'')    ISC_ATTRIBUTE_5,
decode(oset.resource_id, null, null, ''pFunctionName=ISC_DBI_SAM_NAGR_ORD_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'')    ISC_ATTRIBUTE_7,';
    l_viewby_col_str := 'resource_id, sales_grp_id';
    l_viewby_select_str := 'decode(oset.resource_id, null, g.group_name, r.resource_name)';
    l_viewbyid_select_str := 'decode(oset.resource_id, null, to_char(oset.sales_grp_id), oset.resource_id||''.''||oset.sales_grp_id)';
    l_dim_join_str := ' jtf_rs_groups_vl  g, jtf_rs_resource_extns_vl  r
 where oset.sales_grp_id = g.group_id
 and oset.resource_id = r.resource_id (+) ';

  elsif (l_view_by = 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS') then
    l_sg_drill_str := 'null';
    l_class_drill_str := '''pFunctionName=ISC_DBI_SAM_AGR_ORD&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMERS&pParamIds=Y''';
    l_viewby_col_str := 'class_code';
    l_viewby_select_str := 'v.value';
    l_viewbyid_select_str := 'v.id';
    l_dim_join_str := ' fii_partner_mkt_class_v  v
 where oset.class_code = v.id ';

  else -- (l_view_by = 'CUSTOMER+FII_CUSTOMERS')
    l_sg_drill_str := 'null';
    l_class_drill_str := 'null';
    l_viewby_col_str := 'customer_id';
    l_viewby_select_str := 'v.value';
    l_viewbyid_select_str := 'v.id';
    l_dim_join_str := ' fii_customers_v  v
 where oset.customer_id = v.id ';
  end if;

  l_query := '
 select '||l_viewby_select_str||'  VIEWBY,
'||l_viewbyid_select_str||'  VIEWBYID,
'||l_sg_drill_str||'    ISC_ATTRIBUTE_3,
'||l_col_drill_str||'
'||l_class_drill_str||'     ISC_ATTRIBUTE_8,
ISC_MEASURE_5,ISC_MEASURE_6,ISC_MEASURE_8,ISC_MEASURE_9,
ISC_MEASURE_11,ISC_MEASURE_12,ISC_MEASURE_13,ISC_MEASURE_15,
ISC_MEASURE_16,ISC_MEASURE_18,ISC_MEASURE_19,
ISC_MEASURE_21,ISC_MEASURE_22,ISC_MEASURE_23,ISC_MEASURE_24,ISC_MEASURE_25,
ISC_MEASURE_26,ISC_MEASURE_27,ISC_MEASURE_28,ISC_MEASURE_30,
ISC_MEASURE_31,ISC_MEASURE_32,ISC_MEASURE_33,ISC_MEASURE_35,
ISC_MEASURE_36,ISC_MEASURE_37,ISC_MEASURE_38,ISC_MEASURE_40,
ISC_MEASURE_41
   from (select '||l_viewby_col_str||',
(rank() over (&ORDER_BY_CLAUSE nulls last, '||l_viewby_col_str||'))-1  rnk,
ISC_MEASURE_5,ISC_MEASURE_6,ISC_MEASURE_8,ISC_MEASURE_9,
ISC_MEASURE_11,ISC_MEASURE_12,ISC_MEASURE_13,ISC_MEASURE_15,
ISC_MEASURE_16,ISC_MEASURE_18,ISC_MEASURE_19,
ISC_MEASURE_21,ISC_MEASURE_22,ISC_MEASURE_23,ISC_MEASURE_24,ISC_MEASURE_25,
ISC_MEASURE_26,ISC_MEASURE_27,ISC_MEASURE_28,ISC_MEASURE_30,
ISC_MEASURE_31,ISC_MEASURE_32,ISC_MEASURE_33,ISC_MEASURE_35,
ISC_MEASURE_36,ISC_MEASURE_37,ISC_MEASURE_38,ISC_MEASURE_40,
ISC_MEASURE_41
  from (select '||l_viewby_col_str||',
c_agr ISC_MEASURE_5,
(c_agr - p_agr) / decode(p_agr,0,null,abs(p_agr)) * 100 ISC_MEASURE_6,
c_nagr ISC_MEASURE_8,
(c_nagr - p_nagr) / decode(p_nagr,0,null,abs(p_nagr)) * 100 ISC_MEASURE_9,
c_agr+c_nagr ISC_MEASURE_11,
(c_agr+c_nagr-p_agr-p_nagr) / decode(p_agr+p_nagr,0,null,abs(p_agr+p_nagr)) * 100 ISC_MEASURE_12,
c_nagr / decode(c_agr+c_nagr,0,null,abs(c_agr+c_nagr)) * 100 ISC_MEASURE_13,
ct_agr ISC_MEASURE_15,
(ct_agr - pt_agr) / decode(pt_agr,0,null,abs(pt_agr)) * 100 ISC_MEASURE_16,
ct_nagr ISC_MEASURE_18,
(ct_nagr - pt_nagr) / decode(pt_nagr,0,null,abs(pt_nagr)) * 100 ISC_MEASURE_19,
ct_agr+ct_nagr ISC_MEASURE_21,
(ct_agr+ct_nagr-pt_agr-pt_nagr) / decode(pt_agr+pt_nagr,0,null,abs(pt_agr+pt_nagr)) * 100 ISC_MEASURE_22,
ct_nagr / decode(ct_agr+ct_nagr,0,null,abs(ct_agr+ct_nagr)) * 100 ISC_MEASURE_23,
c_agr ISC_MEASURE_24,
c_agr ISC_MEASURE_25,
c_nagr ISC_MEASURE_26,
c_agr ISC_MEASURE_27,
p_agr ISC_MEASURE_28,
ct_agr ISC_MEASURE_30,
pt_agr ISC_MEASURE_31,
c_nagr ISC_MEASURE_32,
p_nagr ISC_MEASURE_33,
ct_nagr ISC_MEASURE_35,
pt_nagr ISC_MEASURE_36,
c_agr / decode(c_agr+c_nagr,0,null,abs(c_agr+c_nagr)) * 100 ISC_MEASURE_37,
p_agr / decode(p_agr+p_nagr,0,null,abs(p_agr+p_nagr)) * 100 ISC_MEASURE_38,
ct_nagr / decode(ct_agr+ct_nagr,0,null,abs(ct_agr+ct_nagr)) * 100 ISC_MEASURE_40,
pt_nagr / decode(pt_agr+pt_nagr,0,null,abs(pt_agr+pt_nagr)) * 100 ISC_MEASURE_41
  from (
select '||l_viewby_col_str||',
sum(c_agr) c_agr,
sum(p_agr) p_agr,
sum(c_nagr) c_nagr,
sum(p_nagr) p_nagr,
sum(sum(c_agr))over() ct_agr,
sum(sum(p_agr))over() pt_agr,
sum(sum(c_nagr))over() ct_nagr,
sum(sum(p_nagr))over() pt_nagr
  from (
select '||l_viewby_col_str||',
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.fulfill_amt_'||l_curr_suffix||',0), 0)  c_agr,
decode(t.report_date, &BIS_PREVIOUS_ASOF_DATE, nvl(f.fulfill_amt_'||l_curr_suffix||',0), 0)  p_agr,
0 c_nagr,
0 p_nagr
  from isc_sam_007_mv f,  -- agreement fulfilled
fii_time_rpt_struct_v t
 where f.time_id = t.time_id
   and t.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
   and bitand(t.record_type_id, &BIS_NESTED_PATTERN) = t.record_type_id
   and f.agg_level = :ISC_AGG_LEVEL
'||l_sg_where||l_class_where||l_cust_where||'
union all
select '||l_viewby_col_str||',
0 c_agr,
0 p_agr,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.fulfill_amt_'||l_curr_suffix||',0), 0)  c_nagr,
decode(t.report_date, &BIS_PREVIOUS_ASOF_DATE, nvl(f.fulfill_amt_'||l_curr_suffix||',0), 0)  p_nagr
  from isc_sam_006_mv f,  -- non-agreement fulfilled
fii_time_rpt_struct_v t
 where f.time_id = t.time_id
   and t.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
   and bitand(t.record_type_id, &BIS_NESTED_PATTERN) = t.record_type_id
   and f.agg_level = :ISC_AGG_LEVEL
'||l_sg_where||l_class_where||l_cust_where||'
) oset
 group by '||l_viewby_col_str||'
) ) where isc_measure_5 <> 0
or isc_measure_6 <> 0
or isc_measure_8 <> 0
or isc_measure_9 <> 0
)  oset,
'||l_dim_join_str||'
    and ((oset.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
order by oset.rnk
';

  l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;
  x_custom_output := bis_query_attributes_tbl();

  l_custom_rec.attribute_name := ':ISC_AGG_LEVEL';
  l_custom_rec.attribute_value := l_agg_level;
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_Rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.EXTEND;
  x_custom_output(x_custom_output.count) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_SG';
  l_custom_rec.attribute_value := to_char(l_sg_sg);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.extend;
  x_custom_output(x_custom_output.count) := l_custom_rec;

  l_custom_rec.attribute_name := ':ISC_RES';
  l_custom_rec.attribute_value := to_char(l_sg_res);
  l_custom_Rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
  x_custom_output.extend;
  x_custom_output(x_custom_output.count) := l_custom_rec;

  x_custom_sql := l_query;

end get_sql;

end isc_dbi_sam_agr_ord_pkg;

/
