--------------------------------------------------------
--  DDL for Package Body POA_DBI_PC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_PC_PKG" 
/* $Header: poadbipcb.pls 120.5 2006/08/25 13:00:19 ankgoyal noship $ */
AS

FUNCTION get_status_filter_where(p_view_by IN VARCHAR2) return VARCHAR2;
FUNCTION get_dtl_filter_where return VARCHAR2;
  FUNCTION get_status_sel_clause(p_view_by_dim	IN VARCHAR2
				,p_url		IN VARCHAR2
				,p_view_by_col	IN VARCHAR2) RETURN VARCHAR2;


  PROCEDURE status_sql(p_param		IN	    BIS_PMV_PAGE_PARAMETER_TBL
		      ,x_custom_sql	OUT NOCOPY  VARCHAR2,
		       x_custom_output	OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL)
  IS
    l_query		VARCHAR2(20000);
    l_view_by_col	VARCHAR2(120);
    l_view_by_value	VARCHAR2(300);
    l_view_by		VARCHAR2(120);
    l_as_of_date	DATE;
    l_prev_as_of_date	DATE;
    l_xtd		VARCHAR2(10);
    l_comparison_type	VARCHAR2(1) := 'Y';

    l_nested_pattern	NUMBER;
    l_cur_suffix	VARCHAR2(2);
    l_col_tbl		POA_DBI_UTIL_PKG.POA_DBI_COL_TBL;
    l_url		VARCHAR2(300);
    l_join_tbl		POA_DBI_UTIL_PKG.POA_DBI_JOIN_TBL;
    l_in_join_tbl	POA_DBI_UTIL_PKG.POA_DBI_IN_JOIN_TBL;
    l_where_clause	VARCHAR2(2000);
    l_mv		VARCHAR2(30);
    ERR_MSG		VARCHAR2(100);
    ERR_CDE		NUMBER;
    l_context_code VARCHAR2(10);
    l_to_date_type VARCHAR2(10);
   BEGIN
     l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
     l_col_tbl	:= poa_dbi_util_pkg.POA_DBI_COL_TBL();
     poa_dbi_sutil_pkg.process_parameters(p_param
					 ,l_view_by
					 ,l_view_by_col
					 ,l_view_by_value
					 ,l_comparison_type
					 ,l_xtd
					 ,l_as_of_date
					 ,l_prev_as_of_date
					 ,l_cur_suffix
					 ,l_nested_pattern
					 ,l_where_clause
					 ,l_mv
					 ,l_join_tbl
					 ,l_in_join_tbl
					, x_custom_output
					 ,'N'
					 ,'PO'
					 ,'6.0'
					 ,'COM'
					 ,'PQC');
   l_context_code := poa_dbi_sutil_pkg.get_sec_context(p_param);
   IF(l_context_code = 'OU' or l_context_code = 'SUPPLIER') THEN
    l_to_date_type := 'RLX';
   ELSE
    l_to_date_type := 'XTD';
   END IF;


   poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_'
		|| l_cur_suffix, 'purchase_amt',p_to_date_type => l_to_date_type);

   poa_dbi_util_pkg.add_column(l_col_tbl,
		'pbpcqcs_amt_' || l_cur_suffix, 'pbpcqcs_amt',p_to_date_type => l_to_date_type);


   if(l_view_by= 'ITEM+POA_ITEMS') then
     poa_dbi_util_pkg.add_column(l_col_tbl, 'quantity' , 'quantity',p_to_date_type => l_to_date_type);
   end if;

   if((l_view_by='ITEM+ENI_ITEM_PO_CAT') and (l_view_by_value is not null)
	and (instr(l_view_by_value,',') =0)) then
     	l_url := null;
   else
     if(l_view_by = 'ITEM+POA_ITEMS') then
       l_url:='pFunctionName=POA_DBI_PC_DTL_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
     else
       l_url:='pFunctionName=POA_DBI_PC_STATUS_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+ENI_ITEM_PO_CAT&pParamIds=Y';
     end if;
    end if;

   l_query := get_status_sel_clause(l_view_by, l_url,l_view_by_col)
	|| ' from ' ||
	poa_dbi_template_pkg.status_sql(l_mv,l_where_clause,
					l_join_tbl,
					p_use_windowing => 'Y',
					p_col_name => l_col_tbl,
					p_use_grpid => 'N',
					p_filter_where => get_status_filter_where(l_view_by),
					p_in_join_tables => l_in_join_tbl);


   x_custom_sql := l_query;

END;

FUNCTION get_status_filter_where(p_view_by in VARCHAR2) return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_MEASURE1';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_PERCENT2';
    l_col_tbl.extend;
    l_col_tbl(3) := 'POA_PERCENT1';
    l_col_tbl.extend;
    l_col_tbl(4) := 'POA_MEASURE2';

   if(p_view_by= 'ITEM+POA_ITEMS') then
	l_col_tbl.extend;
	l_col_tbl(5) := 'POA_MEASURE12';
   end if;


    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

  END;


FUNCTION get_status_sel_clause(p_view_by_dim	IN VARCHAR2
			      ,p_url		IN VARCHAR2
			      ,p_view_by_col	IN VARCHAR2) RETURN VARCHAR2
IS
  l_sel_clause		VARCHAR2(8000);
  l_view_by_col_name	VARCHAR2(40);
BEGIN
  l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim,
	 'PO', '6.0');

  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause :=  l_sel_clause ||' v.description POA_ATTRIBUTE1,
	v2.description POA_ATTRIBUTE2,
	oset.POA_MEASURE12 POA_MEASURE12,';
  else
    l_sel_clause := l_sel_clause || ' null POA_ATTRIBUTE1,
	null POA_ATTRIBUTE2,null POA_MEASURE12,';

  end if;

  l_sel_clause := l_sel_clause || '
	oset.POA_MEASURE1 POA_MEASURE1, 	--Price Change Amount
	oset.POA_PERCENT1 POA_PERCENT1,	--Price Change Rate
	oset.POA_MEASURE2 POA_MEASURE2,	--PO Purchases Amount
	oset.POA_PERCENT2 POA_PERCENT2,	--Change
	oset.POA_MEASURE3 POA_MEASURE3,	--Total Price Change Amount
	oset.POA_MEASURE4 POA_MEASURE4,	--Total Price Change Rate
	oset.POA_MEASURE5 POA_MEASURE5,	--Total PO Purchases Amount
	oset.POA_MEASURE6 POA_MEASURE6,	--Total Change
	''' || p_url || ''' POA_ATTRIBUTE4,
	oset.POA_MEASURE1 POA_MEASURE7,	--KPI Current Amount
	oset.POA_MEASURE8 POA_MEASURE8,	--KPI Prior Amount
	oset.POA_MEASURE3 POA_MEASURE9,	--Total KPI Current Amount
	oset.POA_MEASURE10 POA_MEASURE10	--Total KPI Prior Amount
from
		  (select (rank() over (&ORDER_BY_CLAUSE nulls last, '
			|| p_view_by_col;

if(p_view_by_dim = 'ITEM+POA_ITEMS') then
	l_sel_clause := l_sel_clause || ', base_uom';
end if;

l_sel_clause := l_sel_clause ||
')) - 1 rnk,'|| p_view_by_col
			||',' ;

	 if(p_view_by_dim = 'ITEM+POA_ITEMS') then

	   l_sel_clause :=  l_sel_clause ||
		' base_uom,POA_MEASURE12, ';

	 end if;
	l_sel_clause :=  l_sel_clause ||' POA_MEASURE1, POA_PERCENT1,
					  POA_MEASURE2, POA_PERCENT2,
					  POA_MEASURE3, POA_MEASURE4,
					  POA_MEASURE5, POA_MEASURE6,
					  POA_MEASURE8,
					  POA_MEASURE10
	from
       (select ' || p_view_by_col || ',
	       ' || p_view_by_col || ' VIEWBY,'|| p_view_by_col || ' VIEWBYID,';

      if(p_view_by_dim = 'ITEM+POA_ITEMS') then
	l_sel_clause :=  l_sel_clause ||'base_uom,
		nvl(c_quantity,0) POA_MEASURE12, ';

      end if;

      l_sel_clause :=	l_sel_clause ||
		'nvl(c_purchase_amt,0) - nvl(c_pbpcqcs_amt,0) POA_MEASURE1,
  ((c_purchase_amt - c_pbpcqcs_amt)/decode(c_purchase_amt,0,null,c_purchase_amt))*100 POA_PERCENT1,
   nvl(c_purchase_amt,0) POA_MEASURE2,
   ' ||  poa_dbi_util_pkg.change_clause('c_purchase_amt','p_purchase_amt') || ' POA_PERCENT2,
   nvl(c_purchase_amt_total,0) - nvl(c_pbpcqcs_amt_total,0) POA_MEASURE3,
   ((c_purchase_amt_total - c_pbpcqcs_amt_total)/decode(c_purchase_amt_total,0,null,c_purchase_amt_total))*100 POA_MEASURE4,
   nvl(c_purchase_amt_total,0) POA_MEASURE5,
   ' ||  poa_dbi_util_pkg.change_clause('c_purchase_amt_total','p_purchase_amt_total') || ' POA_MEASURE6,
   nvl(p_purchase_amt,0) - nvl(p_pbpcqcs_amt,0) POA_MEASURE8,
   nvl(p_purchase_amt_total,0) - nvl(p_pbpcqcs_amt_total,0) POA_MEASURE10';

     RETURN l_sel_clause;
END;


FUNCTION get_dtl_filter_where return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_MEASURE1';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_MEASURE3';
    l_col_tbl.extend;
    l_col_tbl(3) := 'POA_MEASURE4';
    l_col_tbl.extend;
    l_col_tbl(4) := 'POA_MEASURE5';
    l_col_tbl.extend;
    l_col_tbl(5) := 'POA_MEASURE6';

    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

  END;

PROCEDURE dtl_rpt_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
        l_query varchar2(8000);
        l_cur_suffix varchar2(2);
        l_where_clause varchar2(2000);
        l_in_join_tbl poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
        l_in_join_tables    VARCHAR2(240) := '';
	l_filter_where VARCHAR2(240);
  BEGIN

  x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();

  poa_dbi_sutil_pkg.drill_process_parameters(p_param, l_cur_suffix, l_where_clause, l_in_join_tbl, 'PO', '6.0', 'COM','PQC');

  IF(l_in_join_tbl is not null) then

        FOR i in 1 .. l_in_join_tbl.COUNT
        LOOP
          l_in_join_tables := l_in_join_tables || ', ' ||  l_in_join_tbl(i).table_name || ' ' || l_in_join_tbl(i).table_alias;
        END LOOP;
  END IF;


  l_filter_where := get_dtl_filter_where;

  l_query :=
  'select poh.segment1 || decode(rel.release_num, null, null, ''-'' || rel.release_num) POA_ATTRIBUTE1, -- Po Number
   pol.line_num POA_ATTRIBUTE2, 	--Line Number
   poorg.name POA_ATTRIBUTE3,		--Operating Unit
   supplier.value POA_ATTRIBUTE8,	--Supplier
   item.value POA_ATTRIBUTE4,		--Item
   uom.description POA_ATTRIBUTE5,	--UOM
   POA_MEASURE1,			--Quantity
   POA_MEASURE2,			--Supplier Benchmark Price
   POA_MEASURE3,			--PO Price
   POA_MEASURE4,			--Price Difference
   POA_MEASURE5,			--Price Change Amount
   POA_MEASURE6,			--PO Purchases Amount
   POA_MEASURE7,			--Price Ch.Amt Total
   POA_MEASURE8,			--PO Purch amt Total
   i.po_header_id POA_ATTRIBUTE6,	--PO Header Id (hidden)
   i.po_release_id POA_ATTRIBUTE7	--PO Release Id (hidden)
  from
   (select (rank() over
            (&ORDER_BY_CLAUSE nulls last, po_header_id, po_line_id,
		po_item_id, base_uom, po_release_id, org_id,
		supplier_id, POA_MEASURE2, POA_MEASURE6)) - 1 rnk,
            po_header_id,
            po_line_id,
            po_item_id,
            org_id,
            supplier_id,
            base_uom,
            po_release_id,
	    decode(base_uom,null,to_number(null),nvl(POA_MEASURE1,0)) POA_MEASURE1,
            POA_MEASURE2,
            POA_MEASURE3,
            POA_MEASURE4,
            nvl(POA_MEASURE5,0) POA_MEASURE5,
            nvl(POA_MEASURE6,0) POA_MEASURE6,
            nvl(POA_MEASURE7,0) POA_MEASURE7,
            nvl(POA_MEASURE8,0) POA_MEASURE8
    from
      (select f.po_header_id,
        f.po_line_id,
        f.po_item_id,
        f.base_uom,
        f.po_release_id,
        f.org_id,
        f.supplier_id,
     sum(f.quantity) POA_MEASURE1,
        nvl(f.pisp_amt_'
	|| (case l_cur_suffix when 'b' then 'g' else l_cur_suffix end)
	|| '/f.pisp_quantity, cisp.purchase_amt_'
	|| (case l_cur_suffix when 'b' then 'g' else l_cur_suffix end)
	|| '/cisp.quantity)'
	|| (case l_cur_suffix when 'b' then '/decode(f.global_cur_conv_rate,0,1,f.global_cur_conv_rate)' end)
	|| ' POA_MEASURE2,
        f.purchase_amt_' || l_cur_suffix || '/f.quantity POA_MEASURE3,
        ((f.purchase_amt_' || l_cur_suffix || '/f.quantity) - (
        nvl(f.pisp_amt_'
	|| (case l_cur_suffix when 'b' then 'g' else l_cur_suffix end)
	|| '/f.pisp_quantity, cisp.purchase_amt_'
	|| (case l_cur_suffix when 'b' then 'g' else l_cur_suffix end)
	|| '/cisp.quantity)'
	|| (case l_cur_suffix when 'b' then '/decode(f.global_cur_conv_rate,0,1,f.global_cur_conv_rate)' end)
	|| '))  POA_MEASURE4 ,
        sum(f.quantity * (f.purchase_amt_'
 --Start fix for bug#5227377
	--|| (case l_cur_suffix when 'b' then 'g' else l_cur_suffix end)
	|| l_cur_suffix
 --End fix for bug#5227377
	|| '/f.quantity - nvl(f.pisp_amt_'
	||  (case l_cur_suffix when 'b' then 'g' else l_cur_suffix end)
	     || '/f.pisp_quantity, cisp.purchase_amt_'
	||  (case l_cur_suffix when 'b' then 'g' else l_cur_suffix end)
	|| '/cisp.quantity)'
	|| (case l_cur_suffix when 'b' then '/decode(f.global_cur_conv_rate,0,1,f.global_cur_conv_rate)' end) || ')) POA_MEASURE5,
        sum(f.purchase_amt_' || l_cur_suffix || ') POA_MEASURE6,
        sum(sum(f.quantity * (f.purchase_amt_'
 --Start fix for bug#5353831
	--|| (case l_cur_suffix when 'b' then 'g' else l_cur_suffix end)
	|| l_cur_suffix
 --End fix for bug#5353831
	|| '/f.quantity - nvl(f.pisp_amt_'
	||  (case l_cur_suffix when 'b' then 'g' else l_cur_suffix end)
	|| '/f.pisp_quantity, cisp.purchase_amt_'
	||  (case l_cur_suffix when 'b' then 'g' else l_cur_suffix end)
	|| '/cisp.quantity)'
           || (case l_cur_suffix when 'b' then '/decode(f.global_cur_conv_rate,0,1,f.global_cur_conv_rate)' end)
	|| '))) over () POA_MEASURE7,
        sum(sum(f.purchase_amt_' || l_cur_suffix || ')) over () POA_MEASURE8
      from      poa_bm_item_s_mv cisp,
	(select /*+ NO_MERGE */ fact.po_header_id,
        fact.po_line_id,
        fact.po_item_id,
        fact.base_uom,
        fact.po_release_id,
        fact.org_id,
        fact.supplier_id,
	fact.global_cur_conv_rate,
	fact.ent_year_id,
	fact.purchase_amt_b,
	fact.purchase_amt_sg,
	fact.purchase_amt_g,
	fact.pisp_quantity,
	fact.pisp_amt_g,
	fact.pisp_amt_sg,
	fact.quantity
 from poa_pqc_bs_j2_mv fact
      ' || l_in_join_tables || '
      where fact.approved_date between &BIS_CURRENT_EFFECTIVE_START_DATE
         and &BIS_CURRENT_ASOF_DATE
         and fact.consigned_code <> 1
	 and fact.order_type = ''QUANTITY''
      and fact.complex_work_flag = ''N''
      ' || l_where_clause  ||') f
      where    f.ent_year_id = cisp.ent_year_id
      and   f.supplier_id = cisp.supplier_id
      and   f.po_item_id = cisp.po_item_id
      and   f.base_uom = cisp.base_uom
      group by f.po_header_id, f.po_line_id, f.po_item_id, f.base_uom, f.po_release_id, f.org_id, f.supplier_id, f.global_cur_conv_rate,
          nvl(f.pisp_amt_' ||  (case l_cur_suffix when 'b' then 'g' else l_cur_suffix end) || '/f.pisp_quantity, cisp.purchase_amt_' ||  (case l_cur_suffix when 'b' then 'g' else l_cur_suffix end) || '/cisp.quantity),
		f.purchase_amt_' || (case l_cur_suffix when 'b' then 'g' else l_cur_suffix end) || '/f.quantity,
	f.purchase_amt_b/f.quantity
)'
|| ' where ' || l_filter_where ||
'     ) i,
      po_headers_all poh,
      po_lines_all pol,
      po_releases_all rel,
      poa_items_v item,
      poa_suppliers_v supplier,
      mtl_units_of_measure_vl uom,
      hr_all_organization_units_vl poorg
  where i.po_header_id = poh.po_header_id
    and i.po_line_id = pol.po_line_id
  and i.po_item_id = item.id
  and i.base_uom = uom.unit_of_measure
  and i.org_id = poorg.organization_id
  and i.supplier_id = supplier.id
  and i.po_release_id = rel.po_release_id (+)
  and (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
ORDER BY rnk';

  x_custom_sql := l_query;

  poa_dbi_util_pkg.get_custom_status_binds(x_custom_output);

end;

END POA_DBI_PC_PKG;

/
