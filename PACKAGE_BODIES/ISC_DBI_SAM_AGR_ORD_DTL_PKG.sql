--------------------------------------------------------
--  DDL for Package Body ISC_DBI_SAM_AGR_ORD_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_DBI_SAM_AGR_ORD_DTL_PKG" as
/* $Header: ISCRGCLB.pls 120.6 2006/01/04 16:07:22 scheung noship $ */

procedure get_sql (	p_param		in		bis_pmv_page_parameter_tbl,
			x_custom_sql	out nocopy	varchar2,
			x_custom_output	out nocopy	bis_query_attributes_tbl) is

  l_sgid                 varchar2(32000);
  l_class                varchar2(32000);
  l_cust                 varchar2(32000);
  l_prod_cat             varchar2(32000);
  l_item                 varchar2(32000);
  l_curr                 varchar2(32000);
  l_curr_suffix          varchar2(32000);
  l_sg_sg                number;
  l_sg_res               number;
  l_sg_where             varchar2(32000);
  l_class_from           varchar2(32000);
  l_class_where          varchar2(32000);
  l_cust_where           varchar2(32000);
  l_prod_cat_from        varchar2(32000);
  l_prod_cat_where       varchar2(32000);
  l_item_where           varchar2(32000);
  l_query                varchar2(32000);
  l_custom_rec           bis_query_attributes;

begin

  -- Get all necessary parameters from PMV
  for i in 1..p_param.count loop

    if (p_param(i).parameter_name = 'ORGANIZATION+JTF_ORG_SALES_GROUP') then
      l_sgid :=  p_param(i).parameter_id;
    end if;

    if (p_param(i).parameter_name = 'FII_TRADING_PARTNER_MKT_CLASS+FII_TRADING_PARTNER_MKT_CLASS') then
      l_class :=  p_param(i).parameter_id;
    end if;

    if (p_param(i).parameter_name = 'CUSTOMER+FII_CUSTOMERS') then
      l_cust :=  p_param(i).parameter_id;
    end if;

    if (p_param(i).parameter_name = 'ITEM+ENI_ITEM_VBH_CAT') then
      l_prod_cat :=  p_param(i).parameter_id;
    end if;

    if (p_param(i).parameter_name = 'ITEM+ENI_ITEM_ORG') then
      l_item :=  p_param(i).parameter_id;
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
    l_sg_where := ' and sc.sales_grp_id = (&ORGANIZATION+JTF_ORG_SALES_GROUP) ';
  else -- when the LOV parameter is a Salesrep (no need to go through the SG hierarchy)
    l_sg_where := ' and sc.sales_grp_id = :ISC_SG and sc.resource_id = :ISC_RES';
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

  if (l_prod_cat is null and l_item is null) then
    l_prod_cat_from := '';
    l_prod_cat_where := '';
    l_item_where := '';
  elsif (l_item is null) then
    l_prod_cat_from := ',
			eni_denorm_hierarchies		eni_cat,
			mtl_default_category_sets	mdcs';
    l_prod_cat_where := '
		    AND star.vbh_category_id = eni_cat.child_id
		    AND eni_cat.parent_id IN (&ITEM+ENI_ITEM_VBH_CAT)
		    AND	eni_cat.dbi_flag = ''Y''
		    AND eni_cat.object_type = ''CATEGORY_SET''
		    AND eni_cat.object_id = mdcs.category_set_id
		    AND	mdcs.functional_area_id = 11';
    l_item_where := '';
  else
    l_prod_cat_from := '';
    l_prod_cat_where := '';
    l_item_where := '
		    AND star.master_id IN (&ITEM+ENI_ITEM_ORG)';
  end if;

  l_query := '
select oset.isc_attribute_1   ISC_ATTRIBUTE_1,
        oset.isc_attribute_2   ISC_ATTRIBUTE_2,
        oset.isc_attribute_3  ISC_ATTRIBUTE_3,
        oset.isc_attribute_4   ISC_ATTRIBUTE_4,
        cust.value    ISC_ATTRIBUTE_5,
        ccv.value    ISC_ATTRIBUTE_6,
        item.value   ISC_ATTRIBUTE_7,
        item.description   ISC_ATTRIBUTE_8,
        sg.group_name   ISC_ATTRIBUTE_9,
        sr.resource_name   ISC_ATTRIBUTE_10,
        oset.isc_measure_1   ISC_MEASURE_1,
        oset.isc_measure_2  ISC_MEASURE_2,
        oset.isc_attribute_11 ISC_ATTRIBUTE_11,
        ''pFunctionName=OKC_REP_SALES_BSA_HEADER_VIEW&mode=view&headerId=''||oset.blanket_header_id||''&moContextOrgId=''||oset.org_id||''&addBreadCrumb=Y&retainAM=Y'' ISC_ATTRIBUTE_12
from
(select (rank() over (&ORDER_BY_CLAUSE nulls last, isc_attribute_1, isc_attribute_2))-1 rnk,
blanket_header_id, org_id, customer_id, item_id, sales_grp_id, resource_id,
isc_attribute_1,isc_attribute_2,isc_attribute_3,isc_attribute_4,isc_measure_1,isc_measure_2,
isc_attribute_11
from
(select f.order_number isc_attribute_1,
        f.line_number isc_attribute_2,
        f.blanket_number isc_attribute_3,
        f.time_fulfilled_date_id isc_attribute_4,
        f.order_line_header_id isc_attribute_11,
	f.blanket_header_id,
	f.org_id,
        f.customer_id,
        star.id item_id,
        sc.sales_grp_id,
        sc.resource_id,
        f.fulfilled_amt_'||l_curr_suffix||' * sc.sales_credit_percent / 100 isc_measure_1,
        sum(f.fulfilled_amt_'||l_curr_suffix||' * sc.sales_credit_percent / 100)over() isc_measure_2
from isc_dbi_bsa_order_lines_f f,
     isc_sales_credits_f sc,
     eni_oltp_item_star star'||l_prod_cat_from||l_class_from||'
where f.time_fulfilled_date_id between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE
and f.order_line_id = sc.line_id
and f.inventory_item_id = star.inventory_item_id
and f.item_inv_org_id = star.organization_id
and f.transaction_phase_code = ''F''
and f.commit_prorated_amt_g is not null
and f.blanket_line_id is not null
and nvl(f.time_termination_date_id, f.time_activation_date_id + 1) >= f.time_activation_date_id
'||l_sg_where||l_class_where||l_cust_where||l_prod_cat_where||l_item_where||'
) )oset,
     fii_party_mkt_class cc,
     fii_partner_mkt_class_v ccv,
     fii_customers_v cust,
     eni_item_org_v item,
     jtf_rs_groups_vl sg,
     jtf_rs_resource_extns_vl  sr
where oset.customer_id = cc.party_id
and cc.class_code = ccv.id
and oset.customer_id = cust.id
and oset.item_id = item.id
and oset.sales_grp_id = sg.group_id
and oset.resource_id = sr.resource_id
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

end isc_dbi_sam_agr_ord_dtl_pkg;

/
