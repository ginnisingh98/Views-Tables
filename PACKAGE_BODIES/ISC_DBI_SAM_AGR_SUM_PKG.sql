--------------------------------------------------------
--  DDL for Package Body ISC_DBI_SAM_AGR_SUM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_SAM_AGR_SUM_PKG" as
/* $Header: ISCRGCBB.pls 120.8 2005/12/15 16:54:32 scheung noship $ */

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
null    ISC_ATTRIBUTE_10,
null    ISC_ATTRIBUTE_11,
null    ISC_ATTRIBUTE_12,';
    if (l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP') then
      l_sg_where := ' and f.parent_grp_id = (&ORGANIZATION+JTF_ORG_SALES_GROUP) and f.grp_marker <> ''TOP GROUP'''; -- exclude the top groups when VB=SG
    else -- other view bys
      l_sg_where := ' and f.sales_grp_id = (&ORGANIZATION+JTF_ORG_SALES_GROUP) and f.resource_id is null';
    end if;
  else -- when the LOV parameter is a Salesrep (no need to go through the SG hierarchy)
    l_col_drill_str := '''pFunctionName=ISC_DBI_SAM_NEW_AGR&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''  ISC_ATTRIBUTE_7,
''pFunctionName=ISC_DBI_SAM_NEW_AGR&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''    ISC_ATTRIBUTE_8,
''pFunctionName=ISC_DBI_SAM_EXD_AGR&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''    ISC_ATTRIBUTE_9,
''pFunctionName=ISC_DBI_SAM_TRM_AGR&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''    ISC_ATTRIBUTE_10,
''pFunctionName=ISC_DBI_SAM_TOP_AGR&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''    ISC_ATTRIBUTE_11,
''pFunctionName=ISC_DBI_SAM_EXG_AGR&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y''    ISC_ATTRIBUTE_12,';
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
    l_sg_drill_str := 'decode(oset.resource_id, null, ''pFunctionName=ISC_DBI_SAM_AGR_SUM&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'', null)';
    l_class_drill_str := 'null';
    l_col_drill_str := 'decode(oset.resource_id, null, null, ''pFunctionName=ISC_DBI_SAM_NEW_AGR&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'')    ISC_ATTRIBUTE_7,
decode(oset.resource_id, null, null, ''pFunctionName=ISC_DBI_SAM_NEW_AGR&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'')    ISC_ATTRIBUTE_8,
decode(oset.resource_id, null, null, ''pFunctionName=ISC_DBI_SAM_EXD_AGR&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'')    ISC_ATTRIBUTE_9,
decode(oset.resource_id, null, null, ''pFunctionName=ISC_DBI_SAM_TRM_AGR&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'')    ISC_ATTRIBUTE_10,
decode(oset.resource_id, null, null, ''pFunctionName=ISC_DBI_SAM_TOP_AGR&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'')    ISC_ATTRIBUTE_11,
decode(oset.resource_id, null, null, ''pFunctionName=ISC_DBI_SAM_EXG_AGR&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'')    ISC_ATTRIBUTE_12,';
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
    l_class_drill_str := '''pFunctionName=ISC_DBI_SAM_AGR_SUM&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=CUSTOMER+FII_CUSTOMERS&pParamIds=Y''';
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
'||l_sg_drill_str||'    ISC_ATTRIBUTE_6,
'||l_col_drill_str||'
'||l_class_drill_str||'     ISC_ATTRIBUTE_13,
ISC_MEASURE_7,ISC_MEASURE_8,ISC_MEASURE_9,ISC_MEASURE_10,ISC_MEASURE_11,ISC_MEASURE_12,ISC_MEASURE_13,ISC_MEASURE_14,ISC_MEASURE_15,
ISC_MEASURE_16,ISC_MEASURE_17,ISC_MEASURE_18,ISC_MEASURE_19,ISC_MEASURE_20,ISC_MEASURE_21,ISC_MEASURE_22,ISC_MEASURE_23,ISC_MEASURE_24,ISC_MEASURE_25,
ISC_MEASURE_26,ISC_MEASURE_27,ISC_MEASURE_28,ISC_MEASURE_29,ISC_MEASURE_30,ISC_MEASURE_31,ISC_MEASURE_32,ISC_MEASURE_33,ISC_MEASURE_34,ISC_MEASURE_35,
ISC_MEASURE_36,ISC_MEASURE_38,ISC_MEASURE_39,ISC_MEASURE_40,ISC_MEASURE_41,ISC_MEASURE_43,ISC_MEASURE_44,ISC_MEASURE_45,
ISC_MEASURE_46,ISC_MEASURE_48,ISC_MEASURE_49,ISC_MEASURE_50,ISC_MEASURE_51,ISC_MEASURE_53,ISC_MEASURE_54,ISC_MEASURE_55,
ISC_MEASURE_56,ISC_MEASURE_58,ISC_MEASURE_59,ISC_MEASURE_60,ISC_MEASURE_61,ISC_MEASURE_63,ISC_MEASURE_64
   from (select '||l_viewby_col_str||',
(rank() over (&ORDER_BY_CLAUSE nulls last, '||l_viewby_col_str||'))-1  rnk,
ISC_MEASURE_7,ISC_MEASURE_8,ISC_MEASURE_9,ISC_MEASURE_10,ISC_MEASURE_11,ISC_MEASURE_12,ISC_MEASURE_13,ISC_MEASURE_14,ISC_MEASURE_15,
ISC_MEASURE_16,ISC_MEASURE_17,ISC_MEASURE_18,ISC_MEASURE_19,ISC_MEASURE_20,
ISC_MEASURE_21,ISC_MEASURE_22,ISC_MEASURE_23,ISC_MEASURE_24,ISC_MEASURE_25,
ISC_MEASURE_26,ISC_MEASURE_27,ISC_MEASURE_28,ISC_MEASURE_29,ISC_MEASURE_30,
ISC_MEASURE_31,ISC_MEASURE_32,ISC_MEASURE_33,ISC_MEASURE_34,ISC_MEASURE_35,
ISC_MEASURE_36,ISC_MEASURE_38,ISC_MEASURE_39,ISC_MEASURE_40,
ISC_MEASURE_41,ISC_MEASURE_43,ISC_MEASURE_44,ISC_MEASURE_45,
ISC_MEASURE_46,ISC_MEASURE_48,ISC_MEASURE_49,ISC_MEASURE_50,
ISC_MEASURE_51,ISC_MEASURE_53,ISC_MEASURE_54,ISC_MEASURE_55,
ISC_MEASURE_56,ISC_MEASURE_58,ISC_MEASURE_59,ISC_MEASURE_60,
ISC_MEASURE_61,ISC_MEASURE_63,ISC_MEASURE_64
  from (select '||l_viewby_col_str||',
c_ba	ISC_MEASURE_7,
(c_ba-p_ba)/decode(p_ba,0,null,abs(p_ba)) * 100	ISC_MEASURE_8,
c_nc	ISC_MEASURE_9,
c_new	ISC_MEASURE_10,
(c_new-p_new)/decode(p_new,0,null,abs(p_new)) * 100	ISC_MEASURE_11,
c_exp	ISC_MEASURE_12,
(c_exp-p_exp)/decode(p_exp,0,null,abs(p_exp)) * 100	ISC_MEASURE_13,
c_trm	ISC_MEASURE_14,
(c_trm-p_trm)/decode(p_trm,0,null,abs(p_trm)) * 100	ISC_MEASURE_15,
p_ta	ISC_MEASURE_16,
c_ta	ISC_MEASURE_17,
c_ta	ISC_MEASURE_18,
(c_ta-p_ta)/decode(p_ta,0,null,abs(p_ta)) * 100	ISC_MEASURE_19,
c_exg	ISC_MEASURE_20,
(c_exg-p_exg)/decode(p_exg,0,null,abs(p_exg)) * 100	ISC_MEASURE_21,
ct_ba	ISC_MEASURE_22,
(ct_ba-pt_ba)/decode(pt_ba,0,null,abs(pt_ba)) * 100	ISC_MEASURE_23,
ct_nc	ISC_MEASURE_24,
ct_new	ISC_MEASURE_25,
(ct_new-pt_new)/decode(pt_new,0,null,abs(pt_new)) * 100	ISC_MEASURE_26,
ct_exp	ISC_MEASURE_27,
(ct_exp-pt_exp)/decode(pt_exp,0,null,abs(pt_exp)) * 100	ISC_MEASURE_28,
ct_trm	ISC_MEASURE_29,
(ct_trm-pt_trm)/decode(pt_trm,0,null,abs(pt_trm)) * 100	ISC_MEASURE_30,
ct_ta	ISC_MEASURE_31,
(ct_ta-pt_ta)/decode(pt_ta,0,null,abs(pt_ta)) * 100	ISC_MEASURE_32,
ct_exg	ISC_MEASURE_33,
(ct_exg-pt_exg)/decode(pt_exg,0,null,abs(pt_exg)) * 100	ISC_MEASURE_34,
c_ba	ISC_MEASURE_35,
p_ba	ISC_MEASURE_36,
ct_ba	ISC_MEASURE_38,
pt_ba	ISC_MEASURE_39,
c_new	ISC_MEASURE_40,
p_new	ISC_MEASURE_41,
ct_new	ISC_MEASURE_43,
pt_new	ISC_MEASURE_44,
c_exp	ISC_MEASURE_45,
p_exp	ISC_MEASURE_46,
ct_exp	ISC_MEASURE_48,
pt_exp	ISC_MEASURE_49,
c_trm	ISC_MEASURE_50,
p_trm	ISC_MEASURE_51,
ct_trm	ISC_MEASURE_53,
pt_trm	ISC_MEASURE_54,
c_ta	ISC_MEASURE_55,
p_ta	ISC_MEASURE_56,
ct_ta	ISC_MEASURE_58,
pt_ta	ISC_MEASURE_59,
c_exg	ISC_MEASURE_60,
p_exg	ISC_MEASURE_61,
ct_exg	ISC_MEASURE_63,
pt_exg	ISC_MEASURE_64
  from (
select '||l_viewby_col_str||',
sum(c_ba1)+sum(c_ba2)-sum(c_ba3)  c_ba,
sum(p_ba1)+sum(p_ba2)-sum(p_ba3)  p_ba,
sum(c_ta1)+sum(c_ta2)-sum(c_ta3)  c_ta,
sum(p_ta1)+sum(p_ta2)-sum(p_ta3)  p_ta,
sum(c_nc) c_nc,
sum(c_new1)  c_new,
sum(p_new1)  p_new,
sum(c_exp1)-sum(c_exp2)  c_exp,
sum(p_exp1)-sum(p_exp2)  p_exp,
sum(c_trm1)  c_trm,
sum(p_trm1)  p_trm,
sum(c_exg1)-sum(c_exg2)-sum(c_exg3)+sum(c_exg4)-sum(c_exg5)+sum(c_exg6)  c_exg,
sum(p_exg1)-sum(p_exg2)-sum(p_exg3)+sum(p_exg4)-sum(p_exg5)+sum(p_exg6)  p_exg,
sum(sum(c_ba1))over()+sum(sum(c_ba2))over()-sum(sum(c_ba3))over()  ct_ba,
sum(sum(p_ba1))over()+sum(sum(p_ba2))over()-sum(sum(p_ba3))over()  pt_ba,
sum(sum(c_ta1))over()+sum(sum(c_ta2))over()-sum(sum(c_ta3))over()  ct_ta,
sum(sum(p_ta1))over()+sum(sum(p_ta2))over()-sum(sum(p_ta3))over()  pt_ta,
sum(sum(c_nc)) over() ct_nc,
sum(sum(c_new1))over()  ct_new,
sum(sum(p_new1))over()  pt_new,
sum(sum(c_exp1))over()-sum(sum(c_exp2))over()  ct_exp,
sum(sum(p_exp1))over()-sum(sum(p_exp2))over()  pt_exp,
sum(sum(c_trm1))over()  ct_trm,
sum(sum(p_trm1))over()  pt_trm,
sum(sum(c_exg1))over()-sum(sum(c_exg2))over()-sum(sum(c_exg3))over()+sum(sum(c_exg4))over()
- sum(sum(c_exg5))over()+sum(sum(c_exg6))over()  ct_exg,
sum(sum(p_exg1))over()-sum(sum(p_exg2))over()-sum(sum(p_exg3))over()+sum(sum(p_exg4))over()
- sum(sum(p_exg5))over()+sum(sum(p_exg6))over()  pt_exg
  from (
select '||l_viewby_col_str||',
decode(t.report_date, &BIS_CURRENT_EFFECTIVE_START_DATE-1, nvl(f.commit_amt_'||l_curr_suffix||',0), 0)  c_ba1,
decode(t.report_date, &BIS_PREVIOUS_EFFECTIVE_START_DATE-1, nvl(f.commit_amt_'||l_curr_suffix||',0), 0)  p_ba1,
0 c_ba2, 0 p_ba2, 0 c_ba3, 0 p_ba3,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.commit_amt_'||l_curr_suffix||',0), 0)  c_ta1,
decode(t.report_date, &BIS_PREVIOUS_ASOF_DATE, nvl(f.commit_amt_'||l_curr_suffix||',0), 0)  p_ta1,
0 c_ta2, 0 p_ta2, 0 c_ta3, 0 p_ta3, 0 c_nc, 0 c_new1, 0 p_new1, 0 c_exp1, 0 p_exp1, 0 c_exp2,
0 p_exp2, 0 c_trm1, 0 p_trm1, 0 c_exg1, 0 p_exg1, 0 c_exg2, 0 p_exg2, 0 c_exg3, 0 p_exg3, 0 c_exg4,
0 p_exg4, 0 c_exg5, 0 p_exg5, 0 c_exg6, 0 p_exg6
  from isc_sam_003_mv f, -- active balance
fii_time_day t
 where t.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE-1,&BIS_PREVIOUS_EFFECTIVE_START_DATE-1,
 &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
   and t.ent_year_id = f.ent_year_id
   and f.agg_level = :ISC_AGG_LEVEL
'||l_sg_where||l_agree_where||l_class_where||l_cust_where||'
union all
select '||l_viewby_col_str||',
0 c_ba1, 0 p_ba1, 0 c_ba2, 0 p_ba2, 0 c_ba3, 0 p_ba3, 0 c_ta1, 0 p_ta1,
0 c_ta2, 0 p_ta2, 0 c_ta3, 0 p_ta3, 0 c_nc, 0 c_new1, 0 p_new1,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.commit_e_t_amt_'||l_curr_suffix||',0), 0)  c_exp1,
decode(t.report_date, &BIS_PREVIOUS_ASOF_DATE, nvl(f.commit_e_t_amt_'||l_curr_suffix||',0), 0)  p_exp1,
0 c_exp2, 0 p_exp2, 0 c_trm1, 0 p_trm1,
decode(t.report_date, &BIS_CURRENT_EFFECTIVE_END_DATE,
nvl(f.commit_calc1_t'||l_period_str||'_amt_'||l_curr_suffix||',0), 0)  c_exg1,
decode(t.report_date, &BIS_PREVIOUS_EFFECTIVE_END_DATE,
nvl(f.commit_calc1_t'||l_period_str||'_amt_'||l_curr_suffix||',0), 0)  p_exg1,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE,
nvl(f.commit_calc1_t'||l_period_str||'_amt_'||l_curr_suffix||',0), 0)  c_exg2,
decode(t.report_date, &BIS_PREVIOUS_ASOF_DATE,
nvl(f.commit_calc1_t'||l_period_str||'_amt_'||l_curr_suffix||',0), 0)  p_exg2,
0 c_exg3, 0 p_exg3, 0 c_exg4, 0 p_exg4, 0 c_exg5, 0 p_exg5,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.commit_t_e_t'||l_period_str||'_amt_'||l_curr_suffix||',0),0)  c_exp6,
decode(t.report_date, &BIS_PREVIOUS_ASOF_DATE, nvl(f.commit_t_e_t'||l_period_str||'_amt_'||l_curr_suffix||',0),0)  p_exp6
  from isc_sam_000_mv f,  -- expiration
fii_time_rpt_struct_v t
 where f.time_id = t.time_id
   and t.report_date in (&BIS_CURRENT_EFFECTIVE_END_DATE,&BIS_PREVIOUS_EFFECTIVE_END_DATE,
      &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
   and bitand(t.record_type_id, &BIS_NESTED_PATTERN) = t.record_type_id
   and f.agg_level = :ISC_AGG_LEVEL
'||l_sg_where||l_agree_where||l_class_where||l_cust_where||'
union all
select '||l_viewby_col_str||',
0 c_ba1, 0 p_ba1, 0 c_ba2, 0 p_ba2, 0 c_ba3, 0 p_ba3, 0 c_ta1, 0 p_ta1,
0 c_ta2, 0 p_ta2, 0 c_ta3, 0 p_ta3,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.new_agr_cnt,0), 0)  c_nc,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.commit_amt_'||l_curr_suffix||',0), 0)  c_new1,
decode(t.report_date, &BIS_PREVIOUS_ASOF_DATE, nvl(f.commit_amt_'||l_curr_suffix||',0), 0)  p_new1,
0 c_exp1, 0 p_exp1, 0 c_exp2, 0 p_exp2, 0 c_trm1, 0 p_trm1, 0 c_exg1, 0 p_exg1, 0 c_exg2, 0 p_exg2,
decode(t.report_date, &BIS_CURRENT_EFFECTIVE_END_DATE,
nvl(f.commit_e'||l_period_str||'_amt_'||l_curr_suffix||',0), 0)  c_exg3,
decode(t.report_date, &BIS_PREVIOUS_EFFECTIVE_END_DATE,
nvl(f.commit_e'||l_period_str||'_amt_'||l_curr_suffix||',0), 0)  p_exg3,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE,
nvl(f.commit_e'||l_period_str||'_amt_'||l_curr_suffix||',0), 0)  c_exg4,
decode(t.report_date, &BIS_PREVIOUS_ASOF_DATE,
nvl(f.commit_e'||l_period_str||'_amt_'||l_curr_suffix||',0), 0)  p_exg4,
0 c_exg5, 0 p_exg5, 0 c_exg6, 0 p_exg6
  from isc_sam_001_mv f,  -- activation
fii_time_rpt_struct_v t
 where f.time_id = t.time_id
   and t.report_date in (&BIS_CURRENT_EFFECTIVE_END_DATE,&BIS_PREVIOUS_EFFECTIVE_END_DATE,
      &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
   and bitand(t.record_type_id, &BIS_NESTED_PATTERN) = t.record_type_id
   and f.agg_level = :ISC_AGG_LEVEL
'||l_sg_where||l_agree_where||l_class_where||l_cust_where||'
union all
select '||l_viewby_col_str||',
0 c_ba1, 0 p_ba1,
decode(t.report_date, &BIS_CURRENT_EFFECTIVE_START_DATE-1, nvl(f.commit_amt_'||l_curr_suffix||',0), 0)  c_ba2,
decode(t.report_date, &BIS_PREVIOUS_EFFECTIVE_START_DATE-1, nvl(f.commit_amt_'||l_curr_suffix||',0), 0)  p_ba2,
0 c_ba3, 0 p_ba3, 0 c_ta1, 0 p_ta1,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.commit_amt_'||l_curr_suffix||',0), 0)  c_ta2,
decode(t.report_date, &BIS_PREVIOUS_ASOF_DATE, nvl(f.commit_amt_'||l_curr_suffix||',0), 0)  p_ta2,
0 c_ta3, 0 p_ta3, 0 c_nc, 0 c_new1, 0 p_new1, 0 c_exp1, 0 p_exp1, 0 c_exp2, 0 p_exp2, 0 c_trm1, 0 p_trm1,
0 c_exg1, 0 p_exg1, 0 c_exg2, 0 p_exg2, 0 c_exg3, 0 p_exg3, 0 c_exg4, 0 p_exg4, 0 c_exg5, 0 p_exg5,
0 c_exg6, 0 p_exg6
  from isc_sam_001_mv f,  -- activation
fii_time_rpt_struct_v t
 where f.time_id = t.time_id
   and t.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE-1,&BIS_PREVIOUS_EFFECTIVE_START_DATE-1,
 &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
   and bitand(t.record_type_id, 119) = t.record_type_id
   and f.agg_level = :ISC_AGG_LEVEL
'||l_sg_where||l_agree_where||l_class_where||l_cust_where||'
union all
select '||l_viewby_col_str||',
0 c_ba1, 0 p_ba1, 0 c_ba2, 0 p_ba2, 0 c_ba3, 0 p_ba3, 0 c_ta1, 0 p_ta1,
0 c_ta2, 0 p_ta2, 0 c_ta3, 0 p_ta3, 0 c_nc, 0 c_new1, 0 p_new1, 0 c_exp1, 0 p_exp1,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.commit_e_t_e'||l_period_str||'_amt_'||l_curr_suffix||',0),0)  c_exp2,
decode(t.report_date, &BIS_PREVIOUS_ASOF_DATE, nvl(f.commit_e_t_e'||l_period_str||'_amt_'||l_curr_suffix||',0),0) p_exp2,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.commit_amt_'||l_curr_suffix||',0), 0)  c_trm1,
decode(t.report_date, &BIS_PREVIOUS_ASOF_DATE, nvl(f.commit_amt_'||l_curr_suffix||',0), 0)  p_trm1,
0 c_exg1, 0 p_exg1, 0 c_exg2, 0 p_exg2, 0 c_exg3, 0 p_exg3, 0 c_exg4, 0 p_exg4,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.commit_t_e_e'||l_period_str||'_amt_'||l_curr_suffix||',0),0)  c_exg5,
decode(t.report_date, &BIS_PREVIOUS_ASOF_DATE, nvl(f.commit_t_e_e'||l_period_str||'_amt_'||l_curr_suffix||',0),0) p_exg5,
0 c_exg6, 0 p_exg6
  from isc_sam_002_mv f,  -- termination
fii_time_rpt_struct_v t
 where f.time_id = t.time_id
   and t.report_date in (&BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
   and bitand(t.record_type_id, &BIS_NESTED_PATTERN) = t.record_type_id
   and f.agg_level = :ISC_AGG_LEVEL
'||l_sg_where||l_agree_where||l_class_where||l_cust_where||'
union all
select '||l_viewby_col_str||',
0 c_ba1, 0 p_ba1, 0 c_ba2, 0 p_ba2,
decode(t.report_date, &BIS_CURRENT_EFFECTIVE_START_DATE-1, nvl(f.commit_amt_'||l_curr_suffix||',0), 0)  c_ba3,
decode(t.report_date, &BIS_PREVIOUS_EFFECTIVE_START_DATE-1, nvl(f.commit_amt_'||l_curr_suffix||',0), 0)  p_ba3,
0 c_ta1, 0 p_ta1, 0 c_ta2, 0 p_ta2,
decode(t.report_date, &BIS_CURRENT_ASOF_DATE, nvl(f.commit_amt_'||l_curr_suffix||',0), 0)  c_ta3,
decode(t.report_date, &BIS_PREVIOUS_ASOF_DATE, nvl(f.commit_amt_'||l_curr_suffix||',0), 0)  p_ta3,
0 c_nc, 0 c_new1, 0 p_new1, 0 c_exp1, 0 p_exp1, 0 c_exp2, 0 p_exp2, 0 c_trm1, 0 p_trm1, 0 c_exg1, 0 p_exg1,
0 c_exg2, 0 p_exg2, 0 c_exg3, 0 p_exg3, 0 c_exg4, 0 p_exg4, 0 c_exg5, 0 p_exg5, 0 c_exg6, 0 p_exg6
  from isc_sam_004_mv f,  -- effective_end
fii_time_rpt_struct_v t
 where f.time_id = t.time_id
   and t.report_date in (&BIS_CURRENT_EFFECTIVE_START_DATE-1,&BIS_PREVIOUS_EFFECTIVE_START_DATE-1,
 &BIS_CURRENT_ASOF_DATE,&BIS_PREVIOUS_ASOF_DATE)
   and bitand(t.record_type_id, 119) = t.record_type_id
   and f.agg_level = :ISC_AGG_LEVEL
'||l_sg_where||l_agree_where||l_class_where||l_cust_where||'
) oset
 group by '||l_viewby_col_str||'
) ) where isc_measure_7 <> 0
or isc_measure_8 <> 0
or isc_measure_9 <> 0
or isc_measure_10 <> 0
or isc_measure_11 <> 0
or isc_measure_12 <> 0
or isc_measure_13 <> 0
or isc_measure_14 <> 0
or isc_measure_15 <> 0
or isc_measure_18 <> 0
or isc_measure_19 <> 0
or isc_measure_20 <> 0
or isc_measure_21 <> 0
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

function ttl1 (p_param in bis_pmv_page_parameter_tbl) return varchar2 is

  l_view_by varchar2(10000);
  l_title varchar2(10000);

begin

  for i in 1..p_param.count loop

    if (p_param(i).parameter_name = 'VIEW_BY') then
      l_view_by := p_param(i).parameter_value;
    end if;

  end loop;

  if (l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP') then
    l_title := fnd_message.get_string('ISC','ISC_DBI_TITLE1_SALES_GROUP');
  elsif (l_view_by = 'ISC_AGREEMENT_TYPE+ISC_AGREEMENT_TYPE') then
    l_title := fnd_message.get_string('ISC','ISC_DBI_TITLE1_AGREEMENT_TYPE');
  elsif (l_view_by = 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS') then
    l_title := fnd_message.get_string('ISC','ISC_DBI_TITLE1_CUST_CLASS');
  elsif (l_view_by = 'CUSTOMER+FII_CUSTOMERS') then
    l_title := fnd_message.get_string('ISC','ISC_DBI_TITLE1_CUSTOMER');
  end if;

  return l_title;

end ttl1;

function ttl2 (p_param in bis_pmv_page_parameter_tbl) return varchar2 is

  l_view_by varchar2(10000);
  l_title varchar2(10000);

begin

  for i in 1..p_param.count loop

    if (p_param(i).parameter_name = 'VIEW_BY') then
      l_view_by := p_param(i).parameter_value;
    end if;

  end loop;

  if (l_view_by = 'ORGANIZATION+JTF_ORG_SALES_GROUP') then
    l_title := fnd_message.get_string('ISC','ISC_DBI_TITLE2_SALES_GROUP');
  elsif (l_view_by = 'ISC_AGREEMENT_TYPE+ISC_AGREEMENT_TYPE') then
    l_title := fnd_message.get_string('ISC','ISC_DBI_TITLE2_AGREEMENT_TYPE');
  elsif (l_view_by = 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS') then
    l_title := fnd_message.get_string('ISC','ISC_DBI_TITLE2_CUST_CLASS');
  elsif (l_view_by = 'CUSTOMER+FII_CUSTOMERS') then
    l_title := fnd_message.get_string('ISC','ISC_DBI_TITLE2_CUSTOMER');
  end if;

  return l_title;

end ttl2;


end isc_dbi_sam_agr_sum_pkg;


/
