--------------------------------------------------------
--  DDL for Package Body POA_DBI_POP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_POP_PKG" 
/* $Header: poadbipopb.pls 120.4 2006/09/19 17:04:23 sriswami noship $ */

AS

-- private methods
FUNCTION get_status_sel_clause(p_view_by_col_name in VARCHAR2, p_url in VARCHAR2) return VARCHAR2;
FUNCTION get_trend_sel_clause return VARCHAR2;

FUNCTION get_view_by_col(view_by varchar2) return VARCHAR2;
  FUNCTION get_status_filter_where return VARCHAR2;

  FUNCTION get_kpi_filter_where return VARCHAR2;
----
-- public methods

PROCEDURE status_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
	l_query varchar2(4000);
        l_view_by varchar2(120);
	l_view_by_col varchar2(120);
        l_as_of_date date;
        l_prev_as_of_date date;
        l_xtd varchar2(10);
        l_comparison_type varchar2(1) := 'Y';
        l_nested_pattern number;
        l_cur_suffix varchar2(2);
        l_url varchar2(300);
        l_custom_sql varchar2(4000);
        l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
	l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
	l_in_join_tbl poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
	l_where_clause VARCHAR2(2000);
	l_view_by_value VARCHAR2(100);
	l_mv VARCHAR2(30);
	l_context_code VARCHAR2(10);
	l_to_date_type VARCHAR2(10);
BEGIN
   l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
   l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();

  poa_dbi_sutil_pkg.process_parameters(p_param,l_view_by,l_view_by_col,l_view_by_value, l_comparison_type, l_xtd, l_as_of_date, l_prev_as_of_date, l_cur_suffix, l_nested_pattern, l_where_clause, l_mv, l_join_tbl, l_in_join_tbl,
x_custom_output,
                                      'N','PO', '5.0', 'VPP','POD');

   l_context_code := poa_dbi_sutil_pkg.get_sec_context(p_param);
   IF(l_context_code = 'OU' or l_context_code = 'SUPPLIER') THEN
    l_to_date_type := 'RLX';
   ELSE
    l_to_date_type := 'XTD';
   END IF;
  poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix, 'purchase_amt',p_to_date_type => l_to_date_type);


  if((l_view_by = 'SUPPLIER+POA_SUPPLIERS') and (l_view_by_value is not null) and (instr(l_view_by_value,',') = 0)) then
    l_url := null;
  else
    l_url := 'pFunctionName=POA_DBI_POP_STATUS_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=SUPPLIER+POA_SUPPLIERS&pParamIds=Y';
 end if;

  l_query := get_status_sel_clause(l_view_by_col, l_url) || ' from
              '|| poa_dbi_template_pkg.status_sql(
                                              l_mv,
                                              l_where_clause,
                                              l_join_tbl,
                                              p_use_windowing => 'Y',
                                              p_col_name => l_col_tbl,
					      p_use_grpid => 'N',
					      p_filter_where => get_status_filter_where,
                                              p_in_join_tables => l_in_join_tbl);
  x_custom_sql := l_query;

END;


PROCEDURE trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
IS
	l_query varchar2(32000);
        l_view_by varchar2(120);
	l_view_by_col varchar2(120);
        l_as_of_date date;
        l_prev_as_of_date date;
        l_xtd varchar2(10);
        l_comparison_type varchar2(1) := 'Y';
        l_nested_pattern number;
        l_cur_suffix varchar2(2);
        l_custom_sql varchar2(4000);
        l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
	l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
	l_in_join_tbl poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
	l_mv VARCHAR2(30);
	l_where_clause VARCHAR2(2000);
	l_view_by_value VARCHAR2(100);
        l_context_code VARCHAR2(10);
	l_to_date_type VARCHAR2(10);
  BEGIN
   l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
  l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();

 poa_dbi_sutil_pkg.process_parameters(p_param,l_view_by,l_view_by_col,l_view_by_value,l_comparison_type, l_xtd, l_as_of_date, l_prev_as_of_date, l_cur_suffix, l_nested_pattern, l_where_clause, l_mv, l_join_tbl, l_in_join_tbl,
x_custom_output,
                                     'Y','PO', '5.0', 'VPP','POD');
 l_context_code := poa_dbi_sutil_pkg.get_sec_context(p_param);
 IF(l_context_code = 'OU' or l_context_code = 'SUPPLIER') THEN
   l_to_date_type := 'RLX';
 ELSE
   l_to_date_type := 'XTD';
 END IF;

 poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix, 'purchase_amt', 'N',p_to_date_type => l_to_date_type);

  l_query := get_trend_sel_clause || ' from
             '|| poa_dbi_template_pkg.trend_sql(
                                              l_xtd,
                                              l_comparison_type,
                                              l_mv,
                                              l_where_clause,
                                              l_col_tbl,
					      p_use_grpid => 'N',
                                              p_in_join_tables => l_in_join_tbl);

  x_custom_sql := l_query;

  END;

  PROCEDURE kpi_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS

  l_query varchar2(4000);
  l_view_by varchar2(120);
  l_view_by_col varchar2(120);
  l_as_of_date date;
  l_prev_as_of_date date;
  l_prev_as_of_date2 date;
  l_xtd varchar2(10);
  l_comparison_type varchar2(1) := 'Y';
  l_nested_pattern number;
  l_cur_suffix varchar2(2);
  l_custom_sql varchar2(4000);
  l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
  l_mv varchar2(30);
  l_org_where varchar2(500);
  l_where_clause varchar2(1000);
  l_join_rec poa_dbi_util_pkg.POA_DBI_JOIN_REC;
  l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
  l_in_join_tbl poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
  l_custom_rec BIS_QUERY_ATTRIBUTES;
  l_view_by_value VARCHAR2(100);
  l_sel_clause VARCHAR2(4000);
  l_context_code VARCHAR2(10);
  l_to_date_type VARCHAR2(10);
  l_cols         VARCHAR2(600);
  BEGIN
  l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
  l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();
  l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

 poa_dbi_sutil_pkg.process_parameters(p_param,l_view_by,l_view_by_col,l_view_by_value,l_comparison_type, l_xtd, l_as_of_date, l_prev_as_of_date, l_cur_suffix, l_nested_pattern, l_where_clause, l_mv, l_join_tbl, l_in_join_tbl,
x_custom_output,
                                     'N','PO', '5.0', 'VPP','POD');

  l_prev_as_of_date2 := poa_dbi_calendar_pkg.previous_period_asof_date(l_prev_as_of_date, l_xtd, l_comparison_type);
  l_context_code := poa_dbi_sutil_pkg.get_sec_context(p_param);

  IF(l_context_code = 'OU' or l_context_code = 'SUPPLIER') THEN
    l_to_date_type := 'RLX';
    poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix, 'purchase_amt', 'Y',
     p_to_date_type => l_to_date_type);
     l_cols := poa_dbi_util_pkg.change_clause('c_purchase_amt','p_purchase_amt') || ' POA_PERCENT1,
              null POA_PERCENT2,
            ' || poa_dbi_util_pkg.change_clause('c_purchase_amt_total','p_purchase_amt_total') || ' POA_MEASURE1,
              null POA_MEASURE2, ';
  ELSE
    l_to_date_type := 'XTD';
    poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix, 'purchase_amt',
	'Y', poa_dbi_util_pkg.PREV_PREV, p_to_date_type => l_to_date_type);
	 l_cols := poa_dbi_util_pkg.change_clause('c_purchase_amt','p_purchase_amt') || ' POA_PERCENT1,
            ' || poa_dbi_util_pkg.change_clause('p_purchase_amt','p2_purchase_amt') || ' POA_PERCENT2,
            ' || poa_dbi_util_pkg.change_clause('c_purchase_amt_total','p_purchase_amt_total') || ' POA_MEASURE1,
            ' || poa_dbi_util_pkg.change_clause('p_purchase_amt_total','p2_purchase_amt_total') || ' POA_MEASURE2, ';
  END IF;

/*  l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();

 IF(l_context_code = 'OU' or l_context_code = 'SUPPLIER') THEN
    l_join_rec.table_name :=
  	  poa_dbi_sutil_pkg.get_table('SUPPLIER+POA_SUPPLIERS', 'PO', '5.0');
    l_join_rec.table_alias := 'v';
    l_join_rec.fact_column :=
  	  poa_dbi_sutil_pkg.get_col_name('SUPPLIER+POA_SUPPLIERS', 'PO', '5.0', 'POD');
    l_join_rec.column_name := 'id';
  ELSE
    l_join_rec.table_name :=
  	  poa_dbi_sutil_pkg.get_table('ORGANIZATION+FII_OPERATING_UNITS', 'PO', '5.0');
    l_join_rec.table_alias := 'v';
    l_join_rec.fact_column :=
  	  poa_dbi_sutil_pkg.get_col_name('ORGANIZATION+FII_OPERATING_UNITS', 'PO', '5.0', 'POD');
    l_join_rec.column_name := 'id';
  END IF;

  l_join_tbl.extend;
  l_join_tbl(l_join_tbl.count) :=l_join_rec;
*/
  if(l_view_by_col = 'commodity_id') then
     l_sel_clause := 'select decode(v.name,null, fnd_message.get_string(''POA'', ''POA_DBI_APL_UNASSIGNED''), v.name) VIEWBY,
		        decode(v.commodity_id,null, -1, v.commodity_id) VIEWBYID,';
  else
     l_sel_clause := 'select v.value VIEWBY, v.id VIEWBYID, ';
  end if;

   l_query :=
       l_sel_clause || '
          oset.POA_PERCENT1 POA_PERCENT1,
          oset.POA_PERCENT2 POA_PERCENT2,
          oset.POA_MEASURE1 POA_MEASURE1,
          oset.POA_MEASURE2 POA_MEASURE2,
      	  oset.POA_MEASURE4 POA_MEASURE4,
          oset.POA_MEASURE5 POA_MEASURE5,
	        oset.POA_MEASURE6 POA_MEASURE6,
          oset.POA_MEASURE7 POA_MEASURE7
	  from
   (select * from (select ' || l_view_by_col || ',' || l_cols ||
        '       nvl(c_purchase_amt,0) POA_MEASURE4,
	              p_purchase_amt POA_MEASURE5,
	              nvl(c_purchase_amt_total,0) POA_MEASURE6,
	              p_purchase_amt_total POA_MEASURE7
		   from
   ' ||  poa_dbi_template_pkg.status_sql(
                                             l_mv,
                                              l_where_clause,
                                              l_join_tbl,
                                              p_use_windowing => 'N',
                                              p_col_name => l_col_tbl,
					      p_use_grpid => 'N',
					      p_filter_where => get_kpi_filter_where,
                                              p_in_join_tables => l_in_join_tbl);

  x_custom_sql := l_query;

 l_custom_rec.attribute_name := '&PREV_PREV_DATE';
 l_custom_rec.attribute_value := TO_CHAR(l_prev_as_of_date2, 'DD/MM/YYYY');
  l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
  l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
  x_custom_output.EXTEND;
  x_custom_output(x_custom_output.COUNT) := l_custom_rec;


  END;

  FUNCTION get_status_filter_where return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_MEASURE1';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_PERCENT2';
    l_col_tbl.extend;
    l_col_tbl(3) := 'POA_PERCENT3';
    l_col_tbl.extend;
    l_col_tbl(4) := 'POA_MEASURE3';
    l_col_tbl.extend;
    l_col_tbl(5) := 'POA_MEASURE4';
    l_col_tbl.extend;
    l_col_tbl(6) := 'POA_MEASURE5';
    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

  END;

  FUNCTION get_kpi_filter_where return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_PERCENT1';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_PERCENT2';
    l_col_tbl.extend;
    l_col_tbl(3) := 'POA_MEASURE4';
    l_col_tbl.extend;
    l_col_tbl(4) := 'POA_MEASURE5';
    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

  END;




  FUNCTION get_status_sel_clause(p_view_by_col_name in VARCHAR2, p_url in VARCHAR2) return VARCHAR2
  IS
  	l_sel_clause varchar2(4000);
  BEGIN

  if(p_view_by_col_name = 'commodity_id') then
     l_sel_clause := 'select decode(v.name,null, fnd_message.get_string(''POA'', ''POA_DBI_APL_UNASSIGNED''), v.name) VIEWBY,
		        decode(v.commodity_id,null, -1, v.commodity_id) VIEWBYID,';
  else
     l_sel_clause := 'select v.value VIEWBY, v.id VIEWBYID, ';
  end if;
  l_sel_clause := l_sel_clause ||
  '        oset.POA_MEASURE1 POA_MEASURE1, 	--PO Purchases Amount
           oset.POA_MEASURE1 POA_MEASURE2,	--PO Purchases Amount
           oset.POA_PERCENT3 POA_PERCENT3, 	--Growth Rate
           oset.POA_MEASURE3 POA_MEASURE3,	--Percent of Total
           oset.POA_PERCENT2 POA_PERCENT2,	--Change
           oset.POA_MEASURE4 POA_MEASURE4, 	--Total PO Purchases Amount
           oset.POA_MEASURE5 POA_MEASURE5,	--Total Growth Rate
           oset.POA_MEASURE6 POA_MEASURE6,	--Total Percent of Total
           ''' || p_url || ''' POA_MEASURE7,
           ''' || p_url || ''' POA_MEASURE8
     from
     (select (rank() over
                   (&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col_name || ')) - 1 rnk,'
        || p_view_by_col_name || ',
           POA_MEASURE1, POA_PERCENT3, POA_MEASURE3, POA_PERCENT2, POA_MEASURE4,
           POA_MEASURE5, POA_MEASURE6 from
     (select ' || p_view_by_col_name || ',
             ' || p_view_by_col_name || ' VIEWBY,
           nvl(c_purchase_amt,0) POA_MEASURE1,
		   ' || poa_dbi_util_pkg.change_clause('c_purchase_amt','p_purchase_amt') || ' POA_PERCENT3,
		   ' || poa_dbi_util_pkg.rate_clause('c_purchase_amt','c_purchase_amt_total') || ' POA_MEASURE3,
		   ' || poa_dbi_util_pkg.change_clause(poa_dbi_util_pkg.rate_clause('c_purchase_amt','c_purchase_amt_total'),poa_dbi_util_pkg.rate_clause('p_purchase_amt','p_purchase_amt_total'),'P') || ' POA_PERCENT2,
           nvl(c_purchase_amt_total,0) POA_MEASURE4,
		   ' || poa_dbi_util_pkg.change_clause('c_purchase_amt_total','p_purchase_amt_total') || ' POA_MEASURE5,
           decode(c_purchase_amt_total, null, null, 100) POA_MEASURE6';

  return l_sel_clause;

  END;


FUNCTION get_trend_sel_clause return VARCHAR2
  IS
  	l_sel_clause varchar2(4000);
BEGIN

  l_sel_clause :=
  'select cal.name VIEWBY,
          nvl(p_purchase_amt,0) POA_MEASURE1,
          nvl(c_purchase_amt,0) POA_MEASURE2,
          ' || poa_dbi_util_pkg.change_clause('c_purchase_amt','p_purchase_amt') || ' POA_MEASURE3,
          nvl(p_purchase_amt,0) POA_MEASURE4,
          nvl(c_purchase_amt,0) POA_MEASURE5';

  return l_sel_clause;

END;


FUNCTION get_view_by_col(view_by varchar2) return varchar2
is
BEGIN
   return (case view_by
	   	when 'ORGANIZATION+FII_OPERATING_UNITS' then 'org_id'
	   	when 'ITEM+ENI_ITEM_PO_CAT' then 'category_id'
	   	when 'ITEM+POA_ITEMS' then 'po_item_id'
	   	when 'SUPPLIER+POA_SUPPLIERS' then 'supplier_id'
	   	when 'SUPPLIER+POA_SUPPLIER_SITES' then 'supplier_site_id'
	   	when 'HRI_PERSON+HRI_PER' then 'buyer_id'
	   	else ''
	   end);
END;

END POA_DBI_POP_PKG;

/
