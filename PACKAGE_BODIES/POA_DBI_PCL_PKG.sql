--------------------------------------------------------
--  DDL for Package Body POA_DBI_PCL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_PCL_PKG" 
/* $Header: poadbipclb.pls 120.0 2005/06/01 14:39:15 appldev noship $ */

AS

  FUNCTION get_status_sel_clause(p_view_by_col in VARCHAR2, p_url in VARCHAR2) return VARCHAR2;
  FUNCTION get_trend_sel_clause return VARCHAR2;
  FUNCTION get_status_filter_where return VARCHAR2;

  FUNCTION get_kpi_filter_where return VARCHAR2;

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

  BEGIN
   l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
   l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();

  poa_dbi_sutil_pkg.process_parameters(p_param,l_view_by,l_view_by_col,l_view_by_value, l_comparison_type, l_xtd, l_as_of_date, l_prev_as_of_date, l_cur_suffix, l_nested_pattern, l_where_clause, l_mv, l_join_tbl, l_in_join_tbl,
x_custom_output,
                                       'N','PO', '5.0', 'VPP','POD');

   poa_dbi_util_pkg.add_column(l_col_tbl, 'p_contract_amt_' || l_cur_suffix, 'p_contract_amt');
   poa_dbi_util_pkg.add_column(l_col_tbl, 'p_savings_amt_' || l_cur_suffix, 'p_savings_amt');
   poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix, 'purchase_amt');

  if((l_view_by = 'HRI_PERSON+HRI_PER') and (l_view_by_value is not null) and (instr(l_view_by_value,',') = 0)) then
    l_url := null;
  else
    l_url := 'pFunctionName=POA_DBI_PCL_STATUS_RPT&VIEW_BY_NAME=VIEW_BY_VALUE&VIEW_BY=HRI_PERSON+HRI_PER';
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

  end;

  PROCEDURE trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
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
        l_custom_sql varchar2(4000);
        l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
	l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
	l_in_join_tbl poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
	l_mv VARCHAR2(30);
	l_where_clause VARCHAR2(2000);
	l_view_by_value VARCHAR2(100);
  BEGIN
  l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
  l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();

 poa_dbi_sutil_pkg.process_parameters(p_param,l_view_by,l_view_by_col,l_view_by_value,l_comparison_type, l_xtd, l_as_of_date, l_prev_as_of_date, l_cur_suffix, l_nested_pattern, l_where_clause, l_mv, l_join_tbl, l_in_join_tbl,
x_custom_output,
                                     'Y','PO', '5.0', 'VPP','POD');

 poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix, 'purchase_amt', 'N');
 poa_dbi_util_pkg.add_column(l_col_tbl, 'p_contract_amt_' || l_cur_suffix, 'p_contract_amt', 'N');

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
       l_xtd varchar2(10);
       l_comparison_type varchar2(1) := 'Y';
       l_nested_pattern number;
       l_org_where varchar2(500);
       l_cur_suffix varchar2(2);
  	l_custom_sql varchar2(4000);
       	l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
	l_where_clause varchar2(1000);
	l_mv varchar2(30);
  	l_join_rec poa_dbi_util_pkg.POA_DBI_JOIN_REC;
	l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
	l_in_join_tbl poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
  	l_custom_rec BIS_QUERY_ATTRIBUTES;
	l_view_by_value VARCHAR2(100);
  begin                                                                           l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
  l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();

 poa_dbi_sutil_pkg.process_parameters(p_param,l_view_by,l_view_by_col,l_view_by_value,l_comparison_type, l_xtd, l_as_of_date, l_prev_as_of_date, l_cur_suffix, l_nested_pattern, l_where_clause, l_mv, l_join_tbl, l_in_join_tbl,
x_custom_output,
                                      'N','PO', '5.0', 'VPP','POD');

  poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix, 'purchase_amt');
  poa_dbi_util_pkg.add_column(l_col_tbl, 'p_contract_amt_' || l_cur_suffix, 'p_contract_amt');
  poa_dbi_util_pkg.add_column(l_col_tbl, 'n_contract_amt_' || l_cur_suffix, 'n_contract_amt');

  l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();

  l_join_rec.table_name :=
	poa_dbi_sutil_pkg.get_table('ORGANIZATION+FII_OPERATING_UNITS', 'PO', '5.0');
  l_join_rec.table_alias := 'v';
  l_join_rec.fact_column :=
	poa_dbi_sutil_pkg.get_col_name('ORGANIZATION+FII_OPERATING_UNITS', 'PO', '5.0', 'POD');
  l_join_rec.column_name := 'id';

  l_join_tbl.extend;
  l_join_tbl(l_join_tbl.count) :=l_join_rec;

  l_query :=
  'select v.value VIEWBY,
          oset.POA_PERCENT1 POA_PERCENT1,
          oset.POA_PERCENT2 POA_PERCENT2,
          oset.POA_PERCENT3 POA_PERCENT3,
          oset.POA_PERCENT4 POA_PERCENT4,
          oset.POA_MEASURE1 POA_MEASURE1,
          oset.POA_MEASURE2 POA_MEASURE2,
          oset.POA_MEASURE3 POA_MEASURE3,
          oset.POA_MEASURE4 POA_MEASURE4 from
   (select * from
     (select org_id,
             ' || poa_dbi_util_pkg.rate_clause('c_p_contract_amt','c_purchase_amt') || ' POA_PERCENT1,
             ' || poa_dbi_util_pkg.rate_clause('p_p_contract_amt','p_purchase_amt') || ' POA_PERCENT2,
             ' || poa_dbi_util_pkg.rate_clause('c_n_contract_amt','c_purchase_amt') || ' POA_PERCENT3,
             ' || poa_dbi_util_pkg.rate_clause('p_n_contract_amt','p_purchase_amt') || ' POA_PERCENT4,
             ' || poa_dbi_util_pkg.rate_clause('c_p_contract_amt_total','c_purchase_amt_total') || ' POA_MEASURE1,
             ' || poa_dbi_util_pkg.rate_clause('p_p_contract_amt_total','p_purchase_amt_total') || ' POA_MEASURE2,
             ' || poa_dbi_util_pkg.rate_clause('c_n_contract_amt_total','c_purchase_amt_total') || ' POA_MEASURE3,
             ' || poa_dbi_util_pkg.rate_clause('p_n_contract_amt_total','p_purchase_amt_total') || ' POA_MEASURE4
   from
  ' || poa_dbi_template_pkg.status_sql(      l_mv,
                                              l_where_clause,
                                             l_join_tbl,
                                              p_use_windowing => 'N',
                                              p_col_name => l_col_tbl,
					      p_use_grpid => 'N',
						p_filter_where => get_kpi_filter_where,
                                              p_in_join_tables => l_in_join_tbl);

  x_custom_sql := l_query;

  end;


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
    l_col_tbl(3) := 'POA_PERCENT1';
    l_col_tbl.extend;
    l_col_tbl(4) := 'POA_MEASURE3';

    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

  END;

 FUNCTION get_kpi_filter_where return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_PERCENT3';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_PERCENT2';
    l_col_tbl.extend;
    l_col_tbl(3) := 'POA_PERCENT1';
    l_col_tbl.extend;
    l_col_tbl(4) := 'POA_PERCENT4';

    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

  END;




  FUNCTION get_status_sel_clause(p_view_by_col in VARCHAR2, p_url in VARCHAR2) return VARCHAR2
  IS

  l_sel_clause varchar2(4000);


  BEGIN
  l_sel_clause :=
  'select v.value VIEWBY,
	oset.POA_MEASURE1 POA_MEASURE1,		--Leakage Amount
	oset.POA_PERCENT1 POA_PERCENT1, 	--Change
	oset.POA_MEASURE3 POA_MEASURE3,		--Leakage Impact Amount
	oset.POA_PERCENT2 POA_PERCENT2,		--Leakage Rate
	oset.POA_MEASURE4 POA_MEASURE4, 	--Total Leakage Amount
	oset.POA_MEASURE5 POA_MEASURE5,		--Total Leakage Impact Amount
	oset.POA_MEASURE6 POA_MEASURE6, 	--Total Change
	oset.POA_MEASURE7 POA_MEASURE7,		-- Total Leakage Rate
           ''' || p_url || ''' POA_MEASURE8
     from
     (select (rank() over
                   (&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col || ')) - 1 rnk,'
        || p_view_by_col || ',
           POA_MEASURE1, POA_PERCENT1, POA_MEASURE3, POA_PERCENT2, POA_MEASURE4,
           POA_MEASURE5, POA_MEASURE6, POA_MEASURE7 from
     (select ' || p_view_by_col || ',
             ' || p_view_by_col || ' VIEWBY,
           nvl(c_p_contract_amt,0) POA_MEASURE1,
           ' || poa_dbi_util_pkg.change_clause('c_p_contract_amt','p_p_contract_amt') || ' POA_PERCENT1,
           nvl(c_p_savings_amt,0) POA_MEASURE3,
           '|| poa_dbi_util_pkg.rate_clause('c_p_contract_amt','c_purchase_amt') ||' POA_PERCENT2,
           nvl(c_p_contract_amt_total,0) POA_MEASURE4,
           nvl(c_p_savings_amt_total,0) POA_MEASURE5,
           '||poa_dbi_util_pkg.change_clause('c_p_contract_amt_total','p_p_contract_amt_total') || ' POA_MEASURE6,
           '||poa_dbi_util_pkg.rate_clause('c_p_contract_amt_total','c_purchase_amt_total')||' POA_MEASURE7';

  return l_sel_clause;

  END;

  FUNCTION get_trend_sel_clause return VARCHAR2
  IS

  l_sel_clause varchar2(4000);

  BEGIN


  l_sel_clause :=
  'select cal.name VIEWBY,
             nvl(p_p_contract_amt,0) POA_MEASURE1,
             nvl(c_p_contract_amt,0) POA_MEASURE2,
	     nvl(p_p_contract_amt,0) POA_PERCENT1,
          ' || poa_dbi_util_pkg.change_clause('c_p_contract_amt','p_p_contract_amt') || ' POA_PERCENT3,
	     nvl(c_p_contract_amt,0) POA_PERCENT2';

  return l_sel_clause;

  END;

end poa_dbi_pcl_pkg;

/
