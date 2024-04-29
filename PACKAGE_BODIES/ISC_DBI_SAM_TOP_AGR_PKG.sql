--------------------------------------------------------
--  DDL for Package Body ISC_DBI_SAM_TOP_AGR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_SAM_TOP_AGR_PKG" as
/* $Header: ISCRGCGB.pls 120.7 2005/12/13 18:16:26 scheung noship $ */

procedure get_sql (	p_param		in		bis_pmv_page_parameter_tbl,
			x_custom_sql	out nocopy	varchar2,
			x_custom_output	out nocopy	bis_query_attributes_tbl) is

  l_func                 varchar2(32000);
  l_sgid                 varchar2(32000);
  l_agree                varchar2(32000);
  l_class                varchar2(32000);
  l_cust                 varchar2(32000);
  l_curr                 varchar2(32000);
  l_curr_suffix          varchar2(32000);
  l_class_from           varchar2(32000);
  l_sg_sg                number;
  l_sg_res               number;
  l_sg_where             varchar2(32000);
  l_agree_where          varchar2(32000);
  l_class_where          varchar2(32000);
  l_cust_where           varchar2(32000);
  l_time_where           varchar2(32000);
  l_col                  varchar2(32000);
  l_query                varchar2(32000);
  l_custom_rec           bis_query_attributes;

begin

  -- Get all necessary parameters from PMV
  for i in 1..p_param.count loop

    if (p_param(i).parameter_name = 'BIS_FXN_NAME') then
      l_func :=  p_param(i).parameter_value;
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
    l_sg_where := ' and f.sales_grp_id = (&ORGANIZATION+JTF_ORG_SALES_GROUP) ';
  else -- when the LOV parameter is a Salesrep (no need to go through the SG hierarchy)
    l_sg_where := ' and f.sales_grp_id = :ISC_SG and f.salesrep_id = :ISC_RES';
  end if;

  if (l_agree is null) then
    l_agree_where := '';
  else
    l_agree_where := ' and f.agreement_type_id in (&ISC_AGREEMENT_TYPE+ISC_AGREEMENT_TYPE)';
  end if;

  if (l_class is null) then
    l_class_where := '';
    l_class_from := '';
  else
    l_class_where := ' and f.customer_id = cc.party_id and cc.class_code in (&FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS)';
    l_class_from := ', fii_party_mkt_class cc ';
  end if;

  if (l_cust is null) then
    l_cust_where := '';
  else
    l_cust_where := ' and f.customer_id in (&CUSTOMER+FII_CUSTOMERS)';
  end if;

  if (l_func = 'ISC_DBI_SAM_TOP_AGR') then
    l_time_where := ' and &BIS_CURRENT_ASOF_DATE >= f.time_activation_date_id
and &BIS_CURRENT_ASOF_DATE < nvl(f.time_effective_end_date_id, trunc(&BIS_CURRENT_ASOF_DATE) + 1)';
    l_col := 'expiration';
  elsif (l_func = 'ISC_DBI_SAM_NEW_AGR') then
    l_time_where := ' and f.time_activation_date_id between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE';
    l_col := 'expiration';
  elsif (l_func = 'ISC_DBI_SAM_EXD_AGR') then
    l_time_where := ' and f.time_expiration_date_id between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE
and &BIS_CURRENT_ASOF_DATE < nvl(f.time_termination_date_id, trunc(&BIS_CURRENT_ASOF_DATE)+1)';
    l_col := 'expiration';
  elsif (l_func = 'ISC_DBI_SAM_TRM_AGR') then
    l_time_where := ' and f.time_termination_date_id is not null
and f.time_termination_date_id between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE';
    l_col := 'termination';
  elsif (l_func = 'ISC_DBI_SAM_EXG_AGR') then
    l_time_where := ' and &BIS_CURRENT_ASOF_DATE >= f.time_activation_date_id
and &BIS_CURRENT_ASOF_DATE < nvl(f.time_effective_end_date_id, trunc(&BIS_CURRENT_ASOF_DATE) + 1)
and f.time_expiration_date_id between &BIS_CURRENT_ASOF_DATE and &BIS_CURRENT_EFFECTIVE_END_DATE';
    l_col := 'expiration';
  end if;

  l_query := '
select	oset.isc_attribute_1 ISC_ATTRIBUTE_1,
        ccv.value ISC_ATTRIBUTE_2,
        cust.value ISC_ATTRIBUTE_3,
        sg.group_name ISC_ATTRIBUTE_4,
        agree.value ISC_ATTRIBUTE_5,
        ISC_MEASURE_1,
        ISC_MEASURE_2,
        ISC_MEASURE_3,
        ISC_MEASURE_4,
        ISC_MEASURE_5,
        ISC_MEASURE_6,
        ISC_MEASURE_7,
        ISC_MEASURE_8,
	oset.isc_attribute_6 ISC_ATTRIBUTE_6,
	oset.isc_attribute_7 ISC_ATTRIBUTE_7,
        ''pFunctionName=OKC_REP_SALES_BSA_HEADER_VIEW&mode=view&headerId=''||oset.blanket_header_id||''&moContextOrgId=''||oset.org_id||''&addBreadCrumb=Y&retainAM=Y'' ISC_ATTRIBUTE_8
from
(
select (rank() over (&ORDER_BY_CLAUSE nulls last, isc_attribute_1))-1 rnk,
isc_attribute_1,
isc_attribute_6,
isc_attribute_7,
blanket_header_id,
org_id,
customer_id,
sales_grp_id,
agreement_type_id,
isc_measure_1,
isc_measure_2,
isc_measure_3,
isc_measure_4,
sum(isc_measure_1) over () isc_measure_5,
sum(isc_measure_2) over () isc_measure_6,
sum(isc_measure_3) over () isc_measure_7,
sum(isc_measure_4) over () isc_measure_8
from
(
select f.blanket_number ISC_ATTRIBUTE_1,
       f.time_activation_date_id ISC_ATTRIBUTE_6,
       f.time_'||l_col||'_date_id ISC_ATTRIBUTE_7,
       f.blanket_header_id,
       f.org_id,
       f.customer_id,
       f.sales_grp_id,
       f.agreement_type_id,
       sum(case when f.order_line_id is null then 0 else 1 end)  ISC_MEASURE_1,
       sum(case when (f.time_fulfilled_date_id <= &BIS_CURRENT_ASOF_DATE)
           then f.fulfilled_amt_'||l_curr_suffix||' else 0 end)  ISC_MEASURE_2,
       sum(f.commit_prorated_amt_'||l_curr_suffix||')
       - sum(case when (f.time_fulfilled_date_id <= &BIS_CURRENT_ASOF_DATE)
             then f.fulfilled_outstand_amt_'||l_curr_suffix||' else 0 end) ISC_MEASURE_3,
       sum(f.commit_prorated_amt_'||l_curr_suffix||') ISC_MEASURE_4
from isc_dbi_bsa_order_lines_f f'||l_class_from||'
where f.transaction_phase_code = ''F''
and f.commit_prorated_amt_g is not null
and f.blanket_line_id is not null
and nvl(f.time_termination_date_id, f.time_activation_date_id + 1) >= f.time_activation_date_id
'||l_time_where||l_sg_where||l_agree_where||l_class_where||l_cust_where||'
group by f.blanket_number,
       f.blanket_header_id,
       f.org_id,
       f.time_activation_date_id,
       f.time_'||l_col||'_date_id,
       f.customer_id,
       f.sales_grp_id,
       f.agreement_type_id
) ) oset,
     fii_party_mkt_class cc,
     fii_partner_mkt_class_v ccv,
     fii_customers_v cust,
     jtf_rs_groups_vl sg,
     isc_agreement_type_v agree
where oset.customer_id = cc.party_id
and cc.class_code = ccv.id
and oset.customer_id = cust.id
and oset.sales_grp_id = sg.group_id
and oset.agreement_type_id = agree.id
and((oset.rnk between &START_INDEX and &END_INDEX) OR (&END_INDEX = -1))
&ORDER_BY_CLAUSE nulls last
';


  l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;
  x_custom_output := bis_query_attributes_tbl();

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

end isc_dbi_sam_top_agr_pkg;

/
