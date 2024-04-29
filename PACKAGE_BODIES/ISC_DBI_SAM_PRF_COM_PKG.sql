--------------------------------------------------------
--  DDL for Package Body ISC_DBI_SAM_PRF_COM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_SAM_PRF_COM_PKG" as
/* $Header: ISCRGCCB.pls 120.6 2006/02/20 14:14:40 scheung noship $ */

procedure get_sql( p_param in bis_pmv_page_parameter_tbl,
	  	   x_custom_sql out nocopy varchar2,
		   x_custom_output out nocopy bis_query_attributes_tbl) is

  l_view_by              varchar2(32000);
  l_sgid                 varchar2(32000);
  l_agree                varchar2(32000);
  l_class                varchar2(32000);
  l_cust                 varchar2(32000);
  l_curr                 varchar2(32000);
  l_period_type          varchar2(32000);
  l_curr_suffix          varchar2(32000);
  l_period_str           varchar2(32000);
  l_sg_sg                number;
  l_sg_res               number;
  l_sg_where             varchar2(32000);
  l_agree_where          varchar2(32000);
  l_class_where          varchar2(32000);
  l_cust_where           varchar2(32000);
  l_agree_needed         boolean;
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

    if (p_param(i).parameter_name = 'ISC_AGREEMENT_TYPE+ISC_AGREEMENT_TYPE') then
      l_agree :=  p_param(i).parameter_id;
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

    if (p_param(i).parameter_name = 'PERIOD_TYPE') then
      l_period_type := p_param(i).parameter_value;
    end if;

  end loop;

  if (l_curr = '''FII_GLOBAL1''') then
    l_curr_suffix := 'g';
  else -- (l_curr = '''FII_GLOBAL2''')
    l_curr_suffix := 'g1';
  end if;

  if (l_period_type = 'FII_TIME_ENT_YEAR') then
    l_period_str := 'yr';
  elsif (l_period_type = 'FII_TIME_ENT_QTR') then
    l_period_str := 'qr';
  elsif (l_period_type = 'FII_TIME_ENT_PERIOD') then
    l_period_str := 'pd';
  else -- (l_period_type = 'FII_TIME_WEEK')
    l_period_str := 'wk';
  end if;

  -- Figure out where clauses
  l_sg_sg   := to_number(replace(substr(l_sgid,instr(l_sgid,'.') + 1),''''));
  l_sg_res  := to_number(replace(substr(l_sgid,1,instr(l_sgid,'.') - 1),''''));

  if (l_sg_res is null) then -- when a sales group is chosen
    l_col_drill_str := 'null  ISC_ATTRIBUTE_7,
null    ISC_ATTRIBUTE_8,
null    ISC_ATTRIBUTE_9,
null    ISC_ATTRIBUTE_10,';
    if (l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP') then
      l_sg_where := ' and f.parent_grp_id = (&ORGANIZATION+JTF_ORG_SALES_GROUP) and f.grp_marker <> ''TOP GROUP'''; -- exclude the top groups when VB=SG
    else -- other view bys
      l_sg_where := ' and f.sales_grp_id = (&ORGANIZATION+JTF_ORG_SALES_GROUP) and f.resource_id is null';
    end if;
  else -- when the LOV parameter is a Salesrep (no need to go through the SG hierarchy)
    l_col_drill_str := '''pFunctionName=ISC_DBI_SAM_TOP_AGR&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''  ISC_ATTRIBUTE_7,
''pFunctionName=ISC_DBI_SAM_EXG_AGR&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''    ISC_ATTRIBUTE_8,
''pFunctionName=ISC_DBI_SAM_TRM_AGR&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''    ISC_ATTRIBUTE_9,
''pFunctionName=ISC_DBI_SAM_EXD_AGR&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''    ISC_ATTRIBUTE_10,';
    l_sg_where := ' and f.sales_grp_id = :ISC_SG and f.resource_id = :ISC_RES';
  end if;

  if (l_agree is null) then
    l_agree_where := '';
  else
    l_agree_where := ' and f.agreement_type_id in (&ISC_AGREEMENT_TYPE+ISC_AGREEMENT_TYPE)';
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
  l_agree_needed := false;
  l_class_needed := false;
  l_cust_needed := false;

  if (l_view_by = 'ISC_AGREEMENT_TYPE+ISC_AGREEMENT_TYPE' or l_agree is not null) then
    l_agree_needed := true;
  end if;

  if (l_view_by = 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS' or l_class is not null) then
    l_class_needed := true;
  end if;

  if (l_view_by = 'CUSTOMER+FII_CUSTOMERS' or l_cust is not null) then
    l_cust_needed := true;
  end if;

  case
    when (    l_agree_needed and     l_class_needed and     l_cust_needed) then l_agg_level := 0;
    when (    l_agree_needed and     l_class_needed and not l_cust_needed) then l_agg_level := 2;
    when (    l_agree_needed and not l_class_needed and     l_cust_needed) then l_agg_level := 0;
    when (not l_agree_needed and     l_class_needed and     l_cust_needed) then l_agg_level := 1;
    when (    l_agree_needed and not l_class_needed and not l_cust_needed) then l_agg_level := 4;
    when (not l_agree_needed and     l_class_needed and not l_cust_needed) then l_agg_level := 3;
    when (not l_agree_needed and not l_class_needed and     l_cust_needed) then l_agg_level := 1;
    when (not l_agree_needed and not l_class_needed and not l_cust_needed) then l_agg_level := 5;
  end case;

  -- Figure out pieces of strings to fill in the query
  if (l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP') then
    l_sg_drill_str := 'decode(oset.resource_id, null, ''pFunctionName=ISC_DBI_SAM_PRF_COM&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'', null)';
    l_class_drill_str := 'null';
    l_col_drill_str := 'decode(oset.resource_id, null, null, ''pFunctionName=ISC_DBI_SAM_TOP_AGR&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'')    ISC_ATTRIBUTE_7,
decode(oset.resource_id, null, null, ''pFunctionName=ISC_DBI_SAM_EXG_AGR&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'')    ISC_ATTRIBUTE_8,
decode(oset.resource_id, null, null, ''pFunctionName=ISC_DBI_SAM_TRM_AGR&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'')    ISC_ATTRIBUTE_9,
decode(oset.resource_id, null, null, ''pFunctionName=ISC_DBI_SAM_EXD_AGR&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'')    ISC_ATTRIBUTE_10,';
    l_viewby_col_str := 'resource_id, sales_grp_id';
    l_viewby_select_str := 'decode(oset.resource_id, null, g.group_name, r.resource_name)';
    l_viewbyid_select_str := 'decode(oset.resource_id, null, to_char(oset.sales_grp_id), oset.resource_id||''.''||oset.sales_grp_id)';
    l_dim_join_str := ' jtf_rs_groups_vl  g, jtf_rs_resource_extns_vl  r
 where oset.sales_grp_id = g.group_id
 and oset.resource_id = r.resource_id (+) ';
  elsif (l_view_by = 'ISC_AGREEMENT_TYPE+ISC_AGREEMENT_TYPE') then
    l_sg_drill_str := 'null';
    l_class_drill_str := 'null';
    l_viewby_col_str := 'agreement_type_id';
    l_viewby_select_str := 'v.value';
    l_viewbyid_select_str := 'v.id';
    l_dim_join_str := ' isc_agreement_type_v  v
 where oset.agreement_type_id = v.id ';
  elsif (l_view_by = 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS') then
    l_sg_drill_str := 'null';
    l_class_drill_str := '''pFunctionName=ISC_DBI_SAM_PRF_COM&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMERS&pParamIds=Y''';
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
'||l_sg_drill_str||'	ISC_ATTRIBUTE_1,
'||l_class_drill_str||'     ISC_ATTRIBUTE_6,
'||l_col_drill_str||'
ISC_MEASURE_5,ISC_MEASURE_6,ISC_MEASURE_7,ISC_MEASURE_8,ISC_MEASURE_9,ISC_MEASURE_10,
ISC_MEASURE_11,ISC_MEASURE_12,ISC_MEASURE_13,ISC_MEASURE_14,ISC_MEASURE_15,ISC_MEASURE_16,ISC_MEASURE_17,ISC_MEASURE_18,ISC_MEASURE_19,ISC_MEASURE_20,
ISC_MEASURE_21,ISC_MEASURE_22,ISC_MEASURE_23,ISC_MEASURE_24,ISC_MEASURE_25,ISC_MEASURE_26,ISC_MEASURE_27,ISC_MEASURE_28,ISC_MEASURE_29,ISC_MEASURE_30,
ISC_MEASURE_32,ISC_MEASURE_33
   from (select '||l_viewby_col_str||',
(rank() over (&ORDER_BY_CLAUSE nulls last, '||l_viewby_col_str||'))-1  rnk,
ISC_MEASURE_5,ISC_MEASURE_6,ISC_MEASURE_7,ISC_MEASURE_8,ISC_MEASURE_9,ISC_MEASURE_10,
ISC_MEASURE_11,ISC_MEASURE_12,ISC_MEASURE_13,ISC_MEASURE_14,ISC_MEASURE_15,ISC_MEASURE_16,ISC_MEASURE_17,ISC_MEASURE_18,ISC_MEASURE_19,ISC_MEASURE_20,
ISC_MEASURE_21,ISC_MEASURE_22,ISC_MEASURE_23,ISC_MEASURE_24,ISC_MEASURE_25,ISC_MEASURE_26,ISC_MEASURE_27,ISC_MEASURE_28,ISC_MEASURE_29,ISC_MEASURE_30,
ISC_MEASURE_32,ISC_MEASURE_33
  from (select '||l_viewby_col_str||',
c_ta ISC_MEASURE_5,
c_to ISC_MEASURE_6,
c_exg ISC_MEASURE_7,
c_ego ISC_MEASURE_8,
c_trm ISC_MEASURE_9,
c_tmo ISC_MEASURE_10,
c_exp ISC_MEASURE_11,
c_epo ISC_MEASURE_12,
sum(c_ta)over() ISC_MEASURE_13,
sum(c_to)over() ISC_MEASURE_14,
sum(c_exg)over() ISC_MEASURE_15,
sum(c_ego)over() ISC_MEASURE_16,
sum(c_trm)over() ISC_MEASURE_17,
sum(c_tmo)over() ISC_MEASURE_18,
sum(c_exp)over() ISC_MEASURE_19,
sum(c_epo)over() ISC_MEASURE_20,
c_to ISC_MEASURE_21,
c_ta-c_to ISC_MEASURE_22,
c_ego ISC_MEASURE_23,
c_exg-c_ego ISC_MEASURE_24,
c_tmo ISC_MEASURE_25,
c_trm-c_tmo ISC_MEASURE_26,
c_epo ISC_MEASURE_27,
c_exp-c_epo ISC_MEASURE_28,
c_ego ISC_MEASURE_29,
p_ego ISC_MEASURE_30,
sum(c_ego)over() ISC_MEASURE_32,
sum(p_ego)over() ISC_MEASURE_33
  from (
select '||l_viewby_col_str||',
sum(c_ta1)+sum(c_ta2)-sum(c_ta3) c_ta,
sum(c_ta1)+sum(c_ta2)-sum(c_ta3)-sum(c_to1)+sum(c_to2) c_to,
sum(p_ta1)+sum(p_ta2)-sum(p_ta3)-sum(p_to1)+sum(p_to2) p_to,
sum(c_exg1)-sum(c_exg2)-sum(c_exg3)+sum(c_exg4)-sum(c_exg5) c_exg,
sum(c_exg1)-sum(c_exg2)-sum(c_exg3)+sum(c_exg4)-sum(c_exg5)-sum(c_ego1)+sum(c_ego2)+sum(c_ego3)-sum(c_ego4)+sum(c_ego5) c_ego,
sum(p_exg1)-sum(p_exg2)-sum(p_exg3)+sum(p_exg4)-sum(p_exg5)-sum(p_ego1)+sum(p_ego2)+sum(p_ego3)-sum(p_ego4)+sum(p_ego5) p_ego,
sum(c_trm1) c_trm,
sum(c_trm1)-sum(c_tmo1)-sum(c_tmo2) c_tmo,
sum(c_exp1)-sum(c_exp2) c_exp,
sum(c_exp1)-sum(c_exp2)-sum(c_epo1)+sum(c_epo2)-sum(c_epo3) c_epo
  from (
select '||l_viewby_col_str||',
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.commit_amt_'||l_curr_suffix||',0), 0) c_ta1,
0 c_ta2, 0 c_ta3,
0 c_to1, 0 c_to2,
decode(t.report_date, &BIS_PREVIOUS_ASOF_DATE, nvl(f.commit_amt_'||l_curr_suffix||',0), 0) p_ta1,
0 p_ta2, 0 p_ta3, 0 p_to1, 0 p_to2,
0 c_exg1, 0 c_exg2, 0 c_exg3, 0 c_exg4, 0 c_exg5,
0 c_ego1, 0 c_ego2, 0 c_ego3, 0 c_ego4, 0 c_ego5,
0 p_exg1, 0 p_exg2, 0 p_exg3, 0 p_exg4, 0 p_exg5,
0 p_ego1, 0 p_ego2, 0 p_ego3, 0 p_ego4, 0 p_ego5,
0 c_trm1,
0 c_tmo1, 0 c_tmo2,
0 c_exp1, 0 c_exp2,
0 c_epo1, 0 c_epo2, 0 c_epo3
  from isc_sam_003_mv f, -- active balance
fii_time_day t
 where t.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
   and t.ent_year_id = f.ent_year_id
   and f.agg_level = :ISC_AGG_LEVEL
'||l_sg_where||l_agree_where||l_class_where||l_cust_where||'
union all
select '||l_viewby_col_str||',
0 c_ta1,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.commit_amt_'||l_curr_suffix||',0), 0) c_ta2,
0 c_ta3,
0 c_to1, 0 c_to2,
0 p_ta1,
decode(t.report_date, &BIS_PREVIOUS_ASOF_DATE, nvl(f.commit_amt_'||l_curr_suffix||',0), 0) p_ta2,
0 p_ta3, 0 p_to1, 0 p_to2,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0 c_trm1,
0 c_tmo1, 0 c_tmo2,
0 c_exp1, 0 c_exp2,
0 c_epo1, 0 c_epo2, 0 c_epo3
  from isc_sam_001_mv f, -- activation
fii_time_rpt_struct_v t
 where f.time_id = t.time_id
   and t.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
   and bitand(t.record_type_id, 119) = t.record_type_id
   and f.agg_level = :ISC_AGG_LEVEL
'||l_sg_where||l_agree_where||l_class_where||l_cust_where||'
union all
select '||l_viewby_col_str||',
0 c_ta1, 0 c_ta2,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.commit_amt_'||l_curr_suffix||',0), 0) c_ta3,
0 c_to1, 0 c_to2,
0 p_ta1, 0 p_ta2,
decode(t.report_date, &BIS_PREVIOUS_ASOF_DATE, nvl(f.commit_amt_'||l_curr_suffix||',0), 0) p_ta3,
0 p_to1, 0 p_to2,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0 c_trm1,
0 c_tmo1, 0 c_tmo2,
0 c_exp1, 0 c_exp2,
0 c_epo1, 0 c_epo2, 0 c_epo3
  from isc_sam_004_mv f, -- effective end
fii_time_rpt_struct_v t
 where f.time_id = t.time_id
   and t.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
   and bitand(t.record_type_id, 119) = t.record_type_id
   and f.agg_level = :ISC_AGG_LEVEL
'||l_sg_where||l_agree_where||l_class_where||l_cust_where||'
union all
select '||l_viewby_col_str||',
0 c_ta1, 0 c_ta2, 0 c_ta3,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.fulfill_out_f_ee_amt_'||l_curr_suffix||',0), 0) c_to1,
0 c_to2,
0 p_ta1, 0 p_ta2, 0 p_ta3,
decode(t.report_date, &BIS_PREVIOUS_ASOF_DATE, nvl(f.fulfill_out_f_ee_amt_'||l_curr_suffix||',0), 0) p_to1,
0 p_to2,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0 c_trm1,
0 c_tmo1, 0 c_tmo2,
0 c_exp1, 0 c_exp2,
0 c_epo1, 0 c_epo2, 0 c_epo3
  from isc_sam_005_mv f, -- fulfilled
fii_time_rpt_struct_v t
 where f.time_id = t.time_id
   and t.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
   and bitand(t.record_type_id, 1143) = t.record_type_id
   and f.agg_level = :ISC_AGG_LEVEL
'||l_sg_where||l_agree_where||l_class_where||l_cust_where||'
union all
select '||l_viewby_col_str||',
0 c_ta1, 0 c_ta2, 0 c_ta3,
0 c_to1,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.fulfill_out_f_ee_amt_'||l_curr_suffix||',0), 0) c_to2,
0 p_ta1, 0 p_ta2, 0 p_ta3, 0 p_to1,
decode(t.report_date, &BIS_PREVIOUS_ASOF_DATE, nvl(f.fulfill_out_f_ee_amt_'||l_curr_suffix||',0), 0) p_to2,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0 c_trm1,
0 c_tmo1, 0 c_tmo2,
0 c_exp1, 0 c_exp2,
0 c_epo1, 0 c_epo2, 0 c_epo3
  from isc_sam_004_mv f, -- effective end
fii_time_rpt_struct_v t
 where f.time_id = t.time_id
   and t.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
   and bitand(t.record_type_id, 1143) = t.record_type_id
   and f.agg_level = :ISC_AGG_LEVEL
'||l_sg_where||l_agree_where||l_class_where||l_cust_where||'
union all
select '||l_viewby_col_str||',
0 c_ta1, 0 c_ta2, 0 c_ta3,
0 c_to1, 0 c_to2,
0 p_ta1, 0 p_ta2, 0 p_ta3, 0 p_to1, 0 p_to2,
decode(t.report_date, &BIS_CURRENT_EFFECTIVE_END_DATE, nvl(f.commit_calc1_t'||l_period_str||'_amt_'||l_curr_suffix||',0), 0) c_exg1,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE,
nvl(f.commit_calc1_t'||l_period_str||'_amt_'||l_curr_suffix||',0)-nvl(f.commit_t_e_t'||l_period_str||'_amt_'||l_curr_suffix||',0), 0) c_exg2,
0 c_exg3, 0 c_exg4, 0 c_exg5,
decode(t.report_date, &BIS_CURRENT_EFFECTIVE_END_DATE, nvl(f.fulfill_out_calc2_t'||l_period_str||'_amt_'||l_curr_suffix||',0), 0) c_ego1,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE,
nvl(f.fulfill_out_calc2_t'||l_period_str||'_amt_'||l_curr_suffix||',0)-nvl(f.fulfill_out_f_t_e_t'||l_period_str||'_amt_'||l_curr_suffix||',0), 0) c_ego2,
0 c_ego3, 0 c_ego4, 0 c_ego5,
decode(t.report_date, &BIS_PREVIOUS_EFFECTIVE_END_DATE, nvl(f.commit_calc1_t'||l_period_str||'_amt_'||l_curr_suffix||',0), 0) p_exg1,
decode(t.report_date, &BIS_PREVIOUS_ASOF_DATE,
nvl(f.commit_calc1_t'||l_period_str||'_amt_'||l_curr_suffix||',0)-nvl(f.commit_t_e_t'||l_period_str||'_amt_'||l_curr_suffix||',0), 0) p_exg2,
0 p_exg3, 0 p_exg4, 0 p_exg5,
decode(t.report_date, &BIS_PREVIOUS_EFFECTIVE_END_DATE, nvl(f.fulfill_out_calc2_t'||l_period_str||'_amt_'||l_curr_suffix||',0), 0) p_ego1,
decode(t.report_date, &BIS_PREVIOUS_ASOF_DATE,
nvl(f.fulfill_out_calc2_t'||l_period_str||'_amt_'||l_curr_suffix||',0)-nvl(f.fulfill_out_f_t_e_t'||l_period_str||'_amt_'||l_curr_suffix||',0), 0) p_ego2,
0 p_ego3, 0 p_ego4, 0 p_ego5,
0 c_trm1,
0 c_tmo1, 0 c_tmo2,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.commit_e_t_amt_'||l_curr_suffix||',0), 0) c_exp1,
0 c_exp2,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.fulfill_out_f_e_t_amt_'||l_curr_suffix||',0), 0) c_epo1,
0 c_epo2, 0 c_epo3
  from isc_sam_000_mv f,  -- expiration
fii_time_rpt_struct_v t
 where f.time_id = t.time_id
   and t.report_date in (&BIS_CURRENT_EFFECTIVE_END_DATE,&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_EFFECTIVE_END_DATE,&BIS_PREVIOUS_ASOF_DATE)
   and bitand(t.record_type_id, &BIS_NESTED_PATTERN) = t.record_type_id
   and f.agg_level = :ISC_AGG_LEVEL
'||l_sg_where||l_agree_where||l_class_where||l_cust_where||'
union all
select '||l_viewby_col_str||',
0 c_ta1, 0 c_ta2, 0 c_ta3,
0 c_to1, 0 c_to2,
0 p_ta1, 0 p_ta2, 0 p_ta3, 0 p_to1, 0 p_to2,
0 c_exg1, 0 c_exg2,
decode(t.report_date, &BIS_CURRENT_EFFECTIVE_END_DATE, nvl(f.commit_e'||l_period_str||'_amt_'||l_curr_suffix||',0), 0) c_exg3,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.commit_e'||l_period_str||'_amt_'||l_curr_suffix||',0), 0) c_exg4,
0 c_exg5,
0 c_ego1, 0 c_ego2, 0 c_ego3, 0 c_ego4, 0 c_ego5,
0 p_exg1, 0 p_exg2,
decode(t.report_date, &BIS_PREVIOUS_EFFECTIVE_END_DATE, nvl(f.commit_e'||l_period_str||'_amt_'||l_curr_suffix||',0), 0) p_exg3,
decode(t.report_date, &BIS_PREVIOUS_ASOF_DATE, nvl(f.commit_e'||l_period_str||'_amt_'||l_curr_suffix||',0), 0) p_exg4,
0 p_exg5,
0 p_ego1, 0 p_ego2, 0 p_ego3, 0 p_ego4, 0 p_ego5,
0 c_trm1,
0 c_tmo1, 0 c_tmo2,
0 c_exp1, 0 c_exp2,
0 c_epo1, 0 c_epo2, 0 c_epo3
  from isc_sam_001_mv f,  -- activation
fii_time_rpt_struct_v t
 where f.time_id = t.time_id
   and t.report_date in (&BIS_CURRENT_EFFECTIVE_END_DATE,&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_EFFECTIVE_END_DATE,&BIS_PREVIOUS_ASOF_DATE)
   and bitand(t.record_type_id, &BIS_NESTED_PATTERN) = t.record_type_id
   and f.agg_level = :ISC_AGG_LEVEL
'||l_sg_where||l_agree_where||l_class_where||l_cust_where||'
union all
select '||l_viewby_col_str||',
0 c_ta1, 0 c_ta2, 0 c_ta3,
0 c_to1, 0 c_to2,
0 p_ta1, 0 p_ta2, 0 p_ta3, 0 p_to1, 0 p_to2,
0 c_exg1, 0 c_exg2, 0 c_exg3, 0 c_exg4,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.commit_t_e_e'||l_period_str||'_amt_'||l_curr_suffix||',0), 0) c_exg5,
0 c_ego1, 0 c_ego2, 0 c_ego3, 0 c_ego4,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.fulfill_out_f_t_e_e'||l_period_str||'_amt_'||l_curr_suffix||',0), 0) c_ego5,
0 p_exg1, 0 p_exg2, 0 p_exg3, 0 p_exg4,
decode(t.report_date, &BIS_PREVIOUS_ASOF_DATE, nvl(f.commit_t_e_e'||l_period_str||'_amt_'||l_curr_suffix||',0), 0) p_exg5,
0 p_ego1, 0 p_ego2, 0 p_ego3, 0 p_ego4,
decode(t.report_date, &BIS_PREVIOUS_ASOF_DATE, nvl(f.fulfill_out_f_t_e_e'||l_period_str||'_amt_'||l_curr_suffix||',0), 0) p_ego5,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.commit_amt_'||l_curr_suffix||',0), 0) c_trm1,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.fulfill_out_f_t_amt_'||l_curr_suffix||',0), 0) c_tmo1,
0 c_tmo2,
0 c_exp1,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.commit_e_t_e'||l_period_str||'_amt_'||l_curr_suffix||',0), 0) c_exp2,
0 c_epo1,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.fulfill_out_ef_t_e'||l_period_str||'_amt_'||l_curr_suffix||',0), 0) c_epo2,
0 c_epo3
  from isc_sam_002_mv f,  -- termination
fii_time_rpt_struct_v t
 where f.time_id = t.time_id
   and t.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
   and bitand(t.record_type_id, &BIS_NESTED_PATTERN) = t.record_type_id
   and f.agg_level = :ISC_AGG_LEVEL
'||l_sg_where||l_agree_where||l_class_where||l_cust_where||'
union all
select '||l_viewby_col_str||',
0 c_ta1, 0 c_ta2, 0 c_ta3,
0 c_to1, 0 c_to2,
0 p_ta1, 0 p_ta2, 0 p_ta3, 0 p_to1, 0 p_to2,
0 c_exg1, 0 c_exg2, 0 c_exg3, 0 c_exg4, 0 c_exg5,
0 c_ego1, 0 c_ego2,
decode(t.report_date, &BIS_CURRENT_EFFECTIVE_END_DATE, nvl(f.fulfill_out_f_et_e'||l_period_str||'_amt_'||l_curr_suffix||',0), 0) c_ego3,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.fulfill_out_f_et_e'||l_period_str||'_amt_'||l_curr_suffix||',0), 0) c_ego4,
0 c_ego5,
0 p_exg1, 0 p_exg2, 0 p_exg3, 0 p_exg4, 0 p_exg5,
0 p_ego1, 0 p_ego2,
decode(t.report_date, &BIS_PREVIOUS_EFFECTIVE_END_DATE, nvl(f.fulfill_out_f_et_e'||l_period_str||'_amt_'||l_curr_suffix||',0), 0) p_ego3,
decode(t.report_date, &BIS_PREVIOUS_ASOF_DATE, nvl(f.fulfill_out_f_et_e'||l_period_str||'_amt_'||l_curr_suffix||',0), 0) p_ego4,
0 p_ego5,
0 c_trm1,
0 c_tmo1,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.fulfill_out_t_f_t'||l_period_str||'_amt_'||l_curr_suffix||',0), 0) c_tmo2,
0 c_exp1, 0 c_exp2,
0 c_epo1, 0 c_epo2,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.fulfill_out_e_ft_e'||l_period_str||'_amt_'||l_curr_suffix||',0), 0) c_epo3
  from isc_sam_005_mv f,  -- fulfilled
fii_time_rpt_struct_v t
 where f.time_id = t.time_id
   and t.report_date in (&BIS_CURRENT_EFFECTIVE_END_DATE,&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_EFFECTIVE_END_DATE,&BIS_PREVIOUS_ASOF_DATE)
   and bitand(t.record_type_id, &BIS_NESTED_PATTERN) = t.record_type_id
   and f.agg_level = :ISC_AGG_LEVEL
'||l_sg_where||l_agree_where||l_class_where||l_cust_where||'
) oset
 group by '||l_viewby_col_str||'
) ) where isc_measure_5 <> 0
or isc_measure_6 <> 0
or isc_measure_7 <> 0
or isc_measure_8 <> 0
or isc_measure_9 <> 0
or isc_measure_10 <> 0
or isc_measure_11 <> 0
or isc_measure_12 <> 0
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

end isc_dbi_sam_prf_com_pkg ;


/
