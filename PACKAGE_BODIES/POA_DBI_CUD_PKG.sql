--------------------------------------------------------
--  DDL for Package Body POA_DBI_CUD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_CUD_PKG" 
/* $Header: poadbicudb.pls 120.7 2006/08/08 11:00:06 nchava noship $*/
AS
  FUNCTION get_con_dtl_filter_where return VARCHAR2;
  FUNCTION get_ncp_dtl_filter_where return VARCHAR2;
  FUNCTION get_pcl_dtl_filter_where return VARCHAR2;

  PROCEDURE con_drill_rpt_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
    l_query varchar2(8000);
    l_cur_suffix varchar2(2);
    l_where_clause varchar2(2000);
    l_in_join_tbl poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
    l_in_join_tables VARCHAR2(1000) ;
    l_sec_context varchar2(10);
  BEGIN
    l_in_join_tables := '';
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

    l_sec_context := poa_dbi_sutil_pkg.get_sec_context(p_param);
    if(l_sec_context = 'OU' or l_sec_context = 'OU/COM') then
      poa_dbi_sutil_pkg.drill_process_parameters(
        p_param        => p_param,
        p_cur_suffix   => l_cur_suffix,
        p_where_clause => l_where_clause,
        p_in_join_tbl  => l_in_join_tbl,
        p_func_area    => 'PO',
        p_version      => '6.0',
        p_role         => 'COM',
        p_mv_set       => 'PODCUT');
    elsif(l_sec_context = 'COMP') then
      poa_dbi_sutil_pkg.drill_process_parameters(
        p_param        => p_param,
        p_cur_suffix   => l_cur_suffix,
        p_where_clause => l_where_clause,
        p_in_join_tbl  => l_in_join_tbl,
        p_func_area    => 'PO',
        p_version      => '8.0',
        p_role         => 'COM',
        p_mv_set       => 'PODCUTB');
    end if;

    IF(l_in_join_tbl is not null) then
      FOR i in 1 .. l_in_join_tbl.COUNT LOOP
        l_in_join_tables := l_in_join_tables || ', ' ||  l_in_join_tbl(i).table_name || ' ' || l_in_join_tbl(i).table_alias;
      END LOOP;
    END IF;

    l_query :=
    'select poh.segment1 || decode(rel.release_num, null, null, ''-'' || rel.release_num) POA_ATTRIBUTE1,                    -- PO Number
     (case when (i.shipment_type in (''BLANKET'',''SCHEDULED'')) then poh.segment1
           when (i.shipment_type = ''STANDARD'' and bl.type_lookup_code = ''BLANKET'') then bl.segment1
           when (i.POA_MEASURE2 > 0) then ''Catalog''
           else '''' end) POA_ATTRIBUTE2,        -- Contract Number
     item.value POA_ATTRIBUTE3,                  -- Item
     item.description POA_ATTRIBUTE4,            -- Description
     uom.description POA_ATTRIBUTE5,             -- UOM
     POA_MEASURE1,                               -- Quantity
     POA_MEASURE2,                               -- Contract Purchases Amt
     POA_MEASURE3,                               -- Total Contract Purchases
     i.po_header_id POA_ATTRIBUTE6,              -- PO Header ID
     i.po_release_id POA_ATTRIBUTE7,             -- PO Release ID
     poorg.name      POA_ATTRIBUTE8,             -- Operating Unit
     (case when (i.shipment_type in (''BLANKET'',''SCHEDULED'')) then poorg.name
          when (i.shipment_type = ''STANDARD'' and bl.type_lookup_code = ''BLANKET'') then blorg.name
          when (i.POA_MEASURE2 > 0) then '' ''
          else '''' end) POA_ATTRIBUTE9,         -- Operating Unit
     (case when (i.shipment_type in (''BLANKET'',''SCHEDULED''))
           then ''pFunctionName=POA_DBI_ISP_DRILL&PoHeaderId=''||poh.po_header_id||''&addBreadCrumb=Y&retainAM=Y''
           when (i.shipment_type = ''STANDARD'' and bl.type_lookup_code = ''BLANKET'')
           then ''pFunctionName=POA_DBI_ISP_DRILL&PoHeaderId=''||bl.po_header_id||''&addBreadCrumb=Y&retainAM=Y''
           when (i.POA_MEASURE2 > 0) then NULL
           else NULL end) POA_ATTRIBUTE10        -- Contract Number Drill
     from
     ( select (rank() over
       (&ORDER_BY_CLAUSE nulls last, po_header_id, po_item_id, base_uom,
       shipment_type, from_document_id, po_release_id, org_id)) - 1 rnk,
       po_header_id,
       po_item_id,
       org_id,
       base_uom,
       shipment_type,
       from_document_id,
       po_release_id,
       decode(base_uom,null,to_number(null),nvl(POA_MEASURE1,0)) POA_MEASURE1,
       nvl(POA_MEASURE2,0) POA_MEASURE2,
       nvl(POA_MEASURE3,0) POA_MEASURE3
       from
       ( select fact.po_header_id,
         fact.po_item_id,
         fact.base_uom,
         fact.shipment_type,
         fact.from_document_id,
         fact.po_release_id,
         fact.org_id,
         sum(quantity) POA_MEASURE1,
         sum(contract_amt_' || l_cur_suffix || ') POA_MEASURE2,
         sum(sum(contract_amt_' || l_cur_suffix || ')) over () POA_MEASURE3
         from poa_dbi_pod_f_v fact
         ' || l_in_join_tables || '
         where fact.approved_date between &BIS_CURRENT_EFFECTIVE_START_DATE
         and &BIS_CURRENT_ASOF_DATE
         ' || l_where_clause || '
         and fact.consigned_code <> 1
         and fact.contract_type is not null ';
    if (l_sec_context = 'OU/COM') then
      l_query := l_query || fnd_global.newline||
         'and fact.commodity_id <> -1 ';
    elsif (l_sec_context = 'COMP') then
      l_query := l_query ||
         'and fact.company_id = com.child_company_id
          and fact.cost_center_id = cc.child_cc_id'||fnd_global.newline;
    end if;
    l_query := l_query ||
        'group by fact.po_header_id,
         fact.po_item_id,
         fact.base_uom,
         fact.shipment_type,
         fact.from_document_id,
         fact.po_release_id,
         fact.org_id
       )
       where ' || get_con_dtl_filter_where || '
     ) i,
     po_headers_all bl,
     po_releases_all rel,
     po_headers_all poh,
     poa_items_v item,
     mtl_units_of_measure_vl uom,
     hr_all_organization_units_vl poorg,
     hr_all_organization_units_vl blorg
     where i.po_header_id = poh.po_header_id
     and i.po_item_id = item.id
     and i.base_uom = uom.unit_of_measure(+)
     and i.org_id = poorg.organization_id
     and bl.org_id = blorg.organization_id(+)
     and i.from_document_id = bl.po_header_id (+)
     and i.po_release_id = rel.po_release_id (+)
     and (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
     ORDER BY rnk ';

    x_custom_sql := l_query;
    poa_dbi_util_pkg.get_custom_status_binds(x_custom_output);
    if(l_sec_context = 'COMP')then
      poa_dbi_sutil_pkg.bind_com_cc_values(x_custom_output, p_param);
    end if;
  end;


  PROCEDURE ncp_drill_rpt_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
    l_query varchar2(10000);
    l_cur_suffix varchar2(2);
    l_where_clause varchar2(2000);
    l_in_join_tbl poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
    l_in_join_tables VARCHAR2(1000);
    l_sec_context varchar2(10);
  BEGIN
    l_in_join_tables := '';
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

    l_sec_context := poa_dbi_sutil_pkg.get_sec_context(p_param);
    if(l_sec_context = 'OU' or l_sec_context = 'OU/COM') then
      poa_dbi_sutil_pkg.drill_process_parameters(
        p_param        => p_param,
        p_cur_suffix   => l_cur_suffix,
        p_where_clause => l_where_clause,
        p_in_join_tbl  => l_in_join_tbl,
        p_func_area    => 'PO',
        p_version      => '6.0',
        p_role         => 'COM',
        p_mv_set       => 'PODCUT');
    elsif (l_sec_context = 'COMP') then
      poa_dbi_sutil_pkg.drill_process_parameters(
        p_param        => p_param,
        p_cur_suffix   => l_cur_suffix,
        p_where_clause => l_where_clause,
        p_in_join_tbl  => l_in_join_tbl,
        p_func_area    => 'PO',
        p_version      => '8.0',
        p_role         => 'COM',
        p_mv_set       => 'PODCUTB');
    end if;

    IF(l_in_join_tbl is not null) then
      FOR i in 1 .. l_in_join_tbl.COUNT LOOP
        l_in_join_tables := l_in_join_tables || ', ' ||  l_in_join_tbl(i).table_name || ' ' || l_in_join_tbl(i).table_alias;
      END LOOP;
    END IF;

    l_query :=
     'select poh.segment1 || decode(rel.release_num, null, null, ''-'' || rel.release_num) POA_ATTRIBUTE1, -- PO Number-release number
      item.value POA_ATTRIBUTE2,           -- Item
      item.description POA_ATTRIBUTE3,     -- Description
      uom.description POA_ATTRIBUTE4,      -- UOM
      POA_MEASURE1,                        -- Quantity
      POA_MEASURE2,                        -- NC Purchases Amount
      POA_MEASURE3,                        -- Total NC Purchases
      i.po_header_id POA_ATTRIBUTE5,       -- PO Header ID
      org.name       POA_ATTRIBUTE6        -- OU
      from
      ( select (rank() over (&ORDER_BY_CLAUSE nulls last,po_header_id, po_item_id, base_uom, org_id)) - 1 rnk,
        po_header_id,
	po_release_id,
        po_item_id,
        base_uom,
        org_id,
        decode(base_uom,null,to_number(null),nvl(POA_MEASURE1,0)) POA_MEASURE1,
        nvl(POA_MEASURE2,0) POA_MEASURE2,
        nvl(POA_MEASURE3,0) POA_MEASURE3
        from
        ( select fact.po_header_id,
	  fact.po_release_id,
          fact.po_item_id,
          fact.base_uom,
          fact.org_id,
          sum(quantity) POA_MEASURE1,
          sum(n_contract_amt_' || l_cur_suffix || ') POA_MEASURE2,
          sum(sum(n_contract_amt_' || l_cur_suffix || ')) over () POA_MEASURE3
          from poa_dbi_pod_f_v fact
          ' || l_in_join_tables || '
          where fact.approved_date between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE
          ' || l_where_clause || '
          and fact.consigned_code <> 1
          and fact.contract_type is null ';
    if (l_sec_context = 'OU/COM') then
      l_query := l_query || fnd_global.newline||
         'and fact.commodity_id <> -1 ';
    elsif (l_sec_context = 'COMP') then
      l_query := l_query ||
         'and fact.company_id = com.child_company_id
          and fact.cost_center_id = cc.child_cc_id'||fnd_global.newline;
    end if;
    l_query := l_query ||
          'group by fact.po_header_id, fact.po_release_id,fact.po_item_id, fact.base_uom, fact.org_id
        )
        where ' || get_ncp_dtl_filter_where || '
      ) i,
      po_headers_all poh,
      poa_items_v item,
      po_releases_all rel,
      mtl_units_of_measure_vl uom,
      hr_all_organization_units_vl org
      where i.po_header_id = poh.po_header_id
      and i.po_release_id = rel.po_release_id (+)
      and i.po_item_id = item.id
      and i.org_id = org.organization_id
      and i.base_uom = uom.unit_of_measure(+)
      and (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
      ORDER BY rnk';

    x_custom_sql := l_query;
    poa_dbi_util_pkg.get_custom_status_binds(x_custom_output);
    if(l_sec_context = 'COMP')then
      poa_dbi_sutil_pkg.bind_com_cc_values(x_custom_output, p_param);
    end if;
  end;

  PROCEDURE pcl_drill_rpt_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
    l_query varchar2(10000);
    l_cur_suffix varchar2(2);
    l_where_clause varchar2(2000);
    l_in_join_tbl poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
    l_in_join_tables    VARCHAR2(1000) ;
    l_sec_context varchar2(10);
  BEGIN
    l_in_join_tables := '';
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

    l_sec_context := poa_dbi_sutil_pkg.get_sec_context(p_param);
    if(l_sec_context = 'OU' or l_sec_context = 'OU/COM') then
      poa_dbi_sutil_pkg.drill_process_parameters(
        p_param        => p_param,
        p_cur_suffix   => l_cur_suffix,
        p_where_clause => l_where_clause,
        p_in_join_tbl  => l_in_join_tbl,
        p_func_area    => 'PO',
        p_version      => '6.0',
        p_role         => 'COM',
        p_mv_set       => 'PODCUT');
    elsif(l_sec_context = 'COMP') then
      poa_dbi_sutil_pkg.drill_process_parameters(
        p_param        => p_param,
        p_cur_suffix   => l_cur_suffix,
        p_where_clause => l_where_clause,
        p_in_join_tbl  => l_in_join_tbl,
        p_func_area    => 'PO',
        p_version      => '8.0',
        p_role         => 'COM',
        p_mv_set       => 'PODCUTB');
    end if;

    IF(l_in_join_tbl is not null) then
      FOR i in 1 .. l_in_join_tbl.COUNT LOOP
        l_in_join_tables := l_in_join_tables || ', ' ||  l_in_join_tbl(i).table_name || ' ' || l_in_join_tbl(i).table_alias;
      END LOOP;
    END IF;

    l_query :=
   'select  poh.segment1 POA_ATTRIBUTE1,    -- PO Number
    poorg.name POA_ATTRIBUTE10,             -- Unused Contract URL
    sup.value POA_ATTRIBUTE2,               -- Supplier
    item.value POA_ATTRIBUTE3,              -- Item
    item.description POA_ATTRIBUTE4,        -- Description
    uom.description POA_ATTRIBUTE5,         -- UOM
    POA_MEASURE1,                           -- Quantity
    POA_MEASURE3,                           -- Contract Leakage Amount
    POA_MEASURE2,                           -- Leakage Impact Amount
    bl.segment1 POA_ATTRIBUTE6,             -- Unused Contract Number
    blorg.name POA_ATTRIBUTE12,             -- Operating  Unit
    bl_sup.value POA_ATTRIBUTE7,            -- Unused Supplier
    POA_MEASURE4,                           -- Total Leakage Impact Amount
    POA_MEASURE5,                           -- Total Contract Leakage Amt
    i.po_header_id POA_ATTRIBUTE8,          -- PO Header ID
    i.potential_contract_id POA_ATTRIBUTE9, -- PO Release ID
    decode(bl.segment1,null,null,''pFunctionName=POA_DBI_ISP_DRILL&PoHeaderId=''||i.potential_contract_id||''&PoReleaseId=&addBreadCrumb=Y&retainAM=Y'') POA_ATTRIBUTE11
    from
    ( select (rank() over (&ORDER_BY_CLAUSE nulls last,po_header_id,po_item_id,
        base_uom, potential_contract_id,
        supplier_id, org_id)) - 1 rnk,
      po_header_id,
      po_item_id,
      base_uom,
      potential_contract_id,
      supplier_id,
      org_id,
      decode(base_uom,null,to_number(null),nvl(POA_MEASURE1,0)) POA_MEASURE1,
      nvl(POA_MEASURE2,0) POA_MEASURE2,
      nvl(POA_MEASURE3,0) POA_MEASURE3,
      nvl(POA_MEASURE4,0) POA_MEASURE4,
      nvl(POA_MEASURE5,0) POA_MEASURE5
      from
      ( select fact.po_header_id,
        fact.po_item_id,
        fact.base_uom,
        fact.potential_contract_id,
        fact.supplier_id,
        fact.org_id,
        sum(quantity) POA_MEASURE1,
        sum(p_savings_amt_' || l_cur_suffix || ') POA_MEASURE2,
        sum(p_contract_amt_' || l_cur_suffix || ') POA_MEASURE3,
        sum(sum(p_savings_amt_' || l_cur_suffix || ')) over () POA_MEASURE4,
        sum(sum(p_contract_amt_' || l_cur_suffix || ')) over () POA_MEASURE5
        from poa_dbi_pod_f_v fact
        ' || l_in_join_tables || '
        where fact.approved_date between &BIS_CURRENT_EFFECTIVE_START_DATE
        and &BIS_CURRENT_ASOF_DATE
        ' || l_where_clause || '
        and fact.consigned_code <> 1
        and fact.contract_type is null
        and ((fact.p_contract_amt_b is not null and fact.p_contract_amt_b != 0) or (fact.p_savings_amt_b is not null and fact.p_savings_amt_b != 0)) ';
    if (l_sec_context = 'OU/COM') then
      l_query := l_query || fnd_global.newline||
         'and fact.commodity_id <> -1 ';
    elsif (l_sec_context = 'COMP') then
      l_query := l_query ||
         'and fact.company_id = com.child_company_id
          and fact.cost_center_id = cc.child_cc_id'||fnd_global.newline;
    end if;
    l_query := l_query ||
       'group by fact.po_header_id,
        fact.po_item_id,
        fact.base_uom,
        fact.potential_contract_id,
        fact.supplier_id, fact.org_id
      )
      where ' || get_pcl_dtl_filter_where || '
    )i,
    po_headers_all poh,
    poa_items_v item,
    mtl_units_of_measure_vl uom,
    po_headers_all bl,
    poa_suppliers_v sup,
    poa_suppliers_v bl_sup,
    hr_all_organization_units_vl poorg,
    hr_all_organization_units_vl blorg
    where i.po_header_id = poh.po_header_id
    and i.po_item_id = item.id
    and i.org_id = poorg.organization_id
    and bl.org_id = blorg.organization_id(+)
    and i.base_uom = uom.unit_of_measure
    and i.potential_contract_id = bl.po_header_id (+)
    and i.supplier_id = sup.id
    and bl.vendor_id = bl_sup.id (+)
    and (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
    ORDER BY rnk';

    x_custom_sql := l_query;
    poa_dbi_util_pkg.get_custom_status_binds(x_custom_output);
    if(l_sec_context = 'COMP')then
      poa_dbi_sutil_pkg.bind_com_cc_values(x_custom_output, p_param);
    end if;
  end;

FUNCTION get_con_dtl_filter_where return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_MEASURE1';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_MEASURE2';
    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

END;

FUNCTION get_ncp_dtl_filter_where return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_MEASURE1';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_MEASURE2';
    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

END;

FUNCTION get_pcl_dtl_filter_where return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_MEASURE1';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_MEASURE2';
    l_col_tbl.extend;
    l_col_tbl(3) := 'POA_MEASURE3';
    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

END;


end poa_dbi_cud_pkg;

/
