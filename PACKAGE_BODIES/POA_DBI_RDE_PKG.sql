--------------------------------------------------------
--  DDL for Package Body POA_DBI_RDE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_RDE_PKG" 
/* $Header: poadbirdeb.pls 120.1 2005/08/04 06:13:24 sriswami noship $ */
AS
  FUNCTION get_status_sel_clause(p_view_by_dim in VARCHAR2, p_url in VARCHAR2,p_view_by_col in VARCHAR2) return VARCHAR2;
  FUNCTION get_trend_sel_clause return VARCHAR2;
  FUNCTION get_rate_trend_sel_clause return VARCHAR2;
  FUNCTION get_status_it_sel_clause(p_view_by_dim IN VARCHAR2,p_view_by_col in VARCHAR2) return VARCHAR2;
  FUNCTION get_status_filter_where return VARCHAR2;
  FUNCTION get_it_rpt_filter_where return VARCHAR2;
  FUNCTION get_amt_rpt_sel_clause(p_view_by_dim in VARCHAR2, p_url in VARCHAR2,p_view_by_col in VARCHAR2) return VARCHAR2;
  FUNCTION get_txn_rpt_sel_clause(p_view_by_dim in VARCHAR2, p_url in VARCHAR2,p_view_by_col in VARCHAR2) return VARCHAR2;

 FUNCTION get_amt_rpt_filter_where return VARCHAR2;
 FUNCTION get_txn_rpt_filter_where return VARCHAR2;


  PROCEDURE status_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                       x_custom_sql  OUT NOCOPY VARCHAR2,
                       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
   IS
    l_query             varchar2(20000);
    l_view_by_col       varchar2(120);
    l_view_by_value     varchar2(300);
    l_view_by           varchar2(120);
    l_as_of_date        date;
    l_prev_as_of_date   date;
    l_xtd               varchar2(10);

    l_comparison_type   varchar2(1) := 'Y';
    l_nested_pattern    number;
    l_cur_suffix        varchar2(2);
    l_custom_sql        varchar2(10000);
    l_col_tbl           poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_url               varchar2(300);
    l_join_tbl          poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
    l_in_join_tbl       poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
    l_where_clause      VARCHAR2(2000);
    l_mv                VARCHAR2(30);
    ERR_MSG             VARCHAR2(100);
    ERR_CDE             NUMBER;
    l_context_code      VARCHAR2(10);
    l_to_date_type      VARCHAR2(10);
   BEGIN
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();

    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();
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
                                        ,'RTX');
   l_context_code := poa_dbi_sutil_pkg.get_sec_context(p_param);
   IF(l_context_code = 'OU' or l_context_code = 'SUPPLIER') THEN
    l_to_date_type := 'RLX';
   ELSE
    l_to_date_type := 'XTD';
   END IF;

   poa_dbi_util_pkg.add_column(l_col_tbl, 'amt_expt_' || l_cur_suffix, 'amt_expt',p_to_date_type => l_to_date_type);
   poa_dbi_util_pkg.add_column(l_col_tbl, 'num_txns_early_cnt', 'early_cnt',p_to_date_type => l_to_date_type);
   poa_dbi_util_pkg.add_column(l_col_tbl, 'num_txns_late_cnt', 'late_cnt',p_to_date_type => l_to_date_type);
   poa_dbi_util_pkg.add_column(l_col_tbl, 'amt_receipt_' || l_cur_suffix, 'amt_receipt',p_to_date_type => l_to_date_type);

    poa_dbi_util_pkg.add_column(l_col_tbl, 'num_txns_receipt_cnt', 'cnt_receipt',p_to_date_type => l_to_date_type);
 if((l_view_by = 'ITEM+POA_ITEMS')) then
    l_url :=
'pFunctionName=POA_DBI_RDE_IT_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+POA_ITEMS&pParamIds=Y';

else
  l_url := null;

end if;
   l_query := get_status_sel_clause(l_view_by, l_url,l_view_by_col) || ' from ' ||
             poa_dbi_template_pkg.status_sql(l_mv,
			l_where_clause,
			l_join_tbl,
			p_use_windowing => 'Y',
			p_col_name => l_col_tbl,
			p_use_grpid => 'N',
			p_filter_where => get_status_filter_where,
			p_in_join_tables => l_in_join_tbl);

   x_custom_sql := l_query;

end;


PROCEDURE rate_trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                    x_custom_sql  OUT NOCOPY VARCHAR2,
                    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
    l_query             varchar2(10000);
    l_view_by           varchar2(120);
    l_view_by_col       varchar2(120);
    l_view_by_value     VARCHAR2(300);
    l_as_of_date        date;
    l_prev_as_of_date   date;
    l_xtd               varchar2(10);
    l_comparison_type   varchar2(1) := 'Y';
    l_nested_pattern    number;
    l_cur_suffix        varchar2(2);
    l_custom_sql        varchar2(10000);
    l_col_tbl           poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_join_tbl          poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
    l_in_join_tbl       poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
    l_mv                VARCHAR2(30);
    l_where_clause      VARCHAR2(2000);
    l_context_code      VARCHAR2(10);
    l_to_date_type      VARCHAR2(10);
   BEGIN
   l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
   l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();
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
                                       ,l_join_tbl,l_in_join_tbl
					,x_custom_output,
					'Y','PO', '6.0', 'COM','RTX');
   l_context_code := poa_dbi_sutil_pkg.get_sec_context(p_param);
   IF(l_context_code = 'OU' or l_context_code = 'SUPPLIER') THEN
    l_to_date_type := 'RLX';
   ELSE
    l_to_date_type := 'XTD';
   END IF;

   poa_dbi_util_pkg.add_column(l_col_tbl, 'amt_receipt_' || l_cur_suffix,'amt_receipt', 'N',p_to_date_type => l_to_date_type);
   poa_dbi_util_pkg.add_column(l_col_tbl, 'amt_expt_' || l_cur_suffix,'amt_expt', 'N',p_to_date_type => l_to_date_type);
   poa_dbi_util_pkg.add_column(l_col_tbl, 'num_txns_receipt_cnt', 'cnt_receipt', 'N',p_to_date_type => l_to_date_type);
   poa_dbi_util_pkg.add_column(l_col_tbl, 'num_txns_early_cnt','cnt_early', 'N',p_to_date_type => l_to_date_type);
   poa_dbi_util_pkg.add_column(l_col_tbl, 'num_txns_late_cnt','cnt_late', 'N',p_to_date_type => l_to_date_type);




   l_query := get_rate_trend_sel_clause || ' from
              '|| poa_dbi_template_pkg.trend_sql(l_xtd,
                                               l_comparison_type,
                                               l_mv,
                                               l_where_clause,
                                               l_col_tbl,
					       p_use_grpid => 'N',
                                               p_in_join_tables => l_in_join_tbl);
   x_custom_sql := l_query;
   END;


  FUNCTION get_rate_trend_sel_clause return VARCHAR2 IS
    l_sel_clause varchar2(4000);
  BEGIN
  l_sel_clause :='select cal.name VIEWBY,
  ' || poa_dbi_util_pkg.rate_clause('c_amt_expt','c_amt_receipt') || ' POA_PERCENT1,
  ' || poa_dbi_util_pkg.change_clause(poa_dbi_util_pkg.rate_clause('c_amt_expt','c_amt_receipt'),poa_dbi_util_pkg.rate_clause('p_amt_expt','p_amt_receipt'),'P') || ' POA_MEASURE1,
    ' ||
poa_dbi_util_pkg.rate_clause('(nvl(c_cnt_early,0) + nvl(c_cnt_late,0))','c_cnt_receipt') || ' POA_PERCENT3,
  ' || poa_dbi_util_pkg.change_clause(
	poa_dbi_util_pkg.rate_clause('(nvl(c_cnt_early,0) + nvl(c_cnt_late,0))','c_cnt_receipt'),
	poa_dbi_util_pkg.rate_clause('(nvl(p_cnt_early,0) + nvl(p_cnt_late,0))','p_cnt_receipt'),'P') || ' POA_MEASURE2';
  return l_sel_clause;
  END;



PROCEDURE amt_rpt_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                       x_custom_sql  OUT NOCOPY VARCHAR2,
                       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
   IS
    l_query             varchar2(20000);
    l_view_by_col       varchar2(120);
    l_view_by_value     varchar2(300);
    l_view_by           varchar2(120);
    l_as_of_date        date;
    l_prev_as_of_date   date;
    l_xtd               varchar2(10);

    l_comparison_type   varchar2(1) := 'Y';
    l_nested_pattern    number;
    l_cur_suffix        varchar2(2);
    l_custom_sql        varchar2(10000);
    l_col_tbl           poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_url               varchar2(300);
    l_join_tbl          poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
    l_in_join_tbl       poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
    l_where_clause      VARCHAR2(2000);
    l_mv                VARCHAR2(30);
    ERR_MSG             VARCHAR2(100);
    ERR_CDE             NUMBER;
    l_context_code      VARCHAR2(10);
    l_to_date_type      VARCHAR2(10);
   BEGIN
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();

    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();
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
                                        ,'RTX');
   l_context_code := poa_dbi_sutil_pkg.get_sec_context(p_param);
   IF(l_context_code = 'OU' or l_context_code = 'SUPPLIER') THEN
    l_to_date_type := 'RLX';
   ELSE
    l_to_date_type := 'XTD';
   END IF;

   poa_dbi_util_pkg.add_column(l_col_tbl, 'amt_expt_' || l_cur_suffix, 'amt_expt',p_to_date_type => l_to_date_type);
   poa_dbi_util_pkg.add_column(l_col_tbl, 'amt_receipt_' || l_cur_suffix, 'amt_receipt',p_to_date_type => l_to_date_type);
   poa_dbi_util_pkg.add_column(l_col_tbl, 'amt_beforedue_' || l_cur_suffix, 'amt_early',p_to_date_type => l_to_date_type);
   poa_dbi_util_pkg.add_column(l_col_tbl, 'num_days_early', 'num_days_early',p_to_date_type => l_to_date_type);
   poa_dbi_util_pkg.add_column(l_col_tbl, 'num_txns_early_cnt', 'early_cnt',p_to_date_type => l_to_date_type);
   poa_dbi_util_pkg.add_column(l_col_tbl, 'amt_afterdue_' || l_cur_suffix, 'amt_late',p_to_date_type => l_to_date_type);
   poa_dbi_util_pkg.add_column(l_col_tbl, 'num_days_late', 'num_days_late',p_to_date_type => l_to_date_type);
   poa_dbi_util_pkg.add_column(l_col_tbl, 'num_txns_late_cnt', 'late_cnt',p_to_date_type => l_to_date_type);
 if((l_view_by = 'ITEM+POA_ITEMS')) then
    l_url :=
'pFunctionName=POA_DBI_RDE_IT_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+POA_ITEMS&pParamIds=Y';

else
  l_url := null;

end if;
   l_query := get_amt_rpt_sel_clause(l_view_by, l_url,l_view_by_col) || ' from ' ||
             poa_dbi_template_pkg.status_sql(l_mv,
			l_where_clause,
			l_join_tbl,
			p_use_windowing => 'Y',
			p_col_name => l_col_tbl,
			p_use_grpid => 'N',
			p_filter_where => get_amt_rpt_filter_where,
			p_in_join_tables => l_in_join_tbl);

   x_custom_sql := l_query;

end;



PROCEDURE txn_rpt_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                       x_custom_sql  OUT NOCOPY VARCHAR2,
                       x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
   IS
    l_query             varchar2(20000);
    l_view_by_col       varchar2(120);
    l_view_by_value     varchar2(300);
    l_view_by           varchar2(120);
    l_as_of_date        date;
    l_prev_as_of_date   date;
    l_xtd               varchar2(10);

    l_comparison_type   varchar2(1) := 'Y';
    l_nested_pattern    number;
    l_cur_suffix        varchar2(2);
    l_custom_sql        varchar2(10000);
    l_col_tbl           poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_url               varchar2(300);
    l_join_tbl          poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
    l_in_join_tbl       poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
    l_where_clause      VARCHAR2(2000);
    l_mv                VARCHAR2(30);
    ERR_MSG             VARCHAR2(100);
    ERR_CDE             NUMBER;
    l_context_code      VARCHAR2(10);
    l_to_date_type      VARCHAR2(10);
   BEGIN
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();

    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();
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
                                        ,'RTX');
   l_context_code := poa_dbi_sutil_pkg.get_sec_context(p_param);
   IF(l_context_code = 'OU' or l_context_code = 'SUPPLIER') THEN
    l_to_date_type := 'RLX';
   ELSE
    l_to_date_type := 'XTD';
   END IF;

     poa_dbi_util_pkg.add_column(l_col_tbl, 'num_txns_receipt_cnt', 'cnt_receipt',p_to_date_type => l_to_date_type);
     poa_dbi_util_pkg.add_column(l_col_tbl, 'num_days_early', 'num_days_early',p_to_date_type => l_to_date_type);
     poa_dbi_util_pkg.add_column(l_col_tbl, 'num_txns_early_cnt', 'early_cnt',p_to_date_type => l_to_date_type);
     poa_dbi_util_pkg.add_column(l_col_tbl, 'num_days_late', 'num_days_late',p_to_date_type => l_to_date_type);
     poa_dbi_util_pkg.add_column(l_col_tbl, 'num_txns_late_cnt', 'late_cnt',p_to_date_type => l_to_date_type);
 if((l_view_by = 'ITEM+POA_ITEMS')) then
    l_url :=
'pFunctionName=POA_DBI_RDE_IT_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+POA_ITEMS&pParamIds=Y';

else
  l_url := null;

end if;
   l_query := get_txn_rpt_sel_clause(l_view_by, l_url,l_view_by_col) || ' from ' ||
             poa_dbi_template_pkg.status_sql(l_mv,
			l_where_clause,
			l_join_tbl,
			p_use_windowing => 'Y',
			p_col_name => l_col_tbl,
			p_use_grpid => 'N',
			p_filter_where => get_amt_rpt_filter_where,
			p_in_join_tables => l_in_join_tbl);

   x_custom_sql := l_query;

end;





PROCEDURE it_rpt_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
        l_query varchar2(10000);
        l_view_by varchar2(120);
        l_view_by_col varchar2(120);
        l_view_by_value VARCHAR2(300);
        l_as_of_date date;
        l_prev_as_of_date date;
        l_xtd varchar2(10);
        l_comparison_type varchar2(1) := 'Y';
        l_nested_pattern number;
        l_cur_suffix varchar2(2);
        l_custom_sql varchar2(10000);
        l_col_tbl poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_join_tbl poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
    l_in_join_tbl poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
    l_where_clause VARCHAR2(2000);
    l_mv VARCHAR2(30);
    l_context_code VARCHAR2(10);
    l_to_date_type VARCHAR2(10);
   BEGIN
     l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
     l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();

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
                                       ,'RTX');
   l_context_code := poa_dbi_sutil_pkg.get_sec_context(p_param);
   IF(l_context_code = 'OU' or l_context_code = 'SUPPLIER') THEN
    l_to_date_type := 'RLX';
   ELSE
    l_to_date_type := 'XTD';
   END IF;

   poa_dbi_util_pkg.add_column(l_col_tbl, 'num_txns_early_cnt', 'early_cnt',p_to_date_type => l_to_date_type);
   poa_dbi_util_pkg.add_column(l_col_tbl, 'num_txns_late_cnt', 'late_cnt',p_to_date_type => l_to_date_type);
   poa_dbi_util_pkg.add_column(l_col_tbl, 'qty_beforedue', 'qty_beforedue',p_to_date_type => l_to_date_type);

   poa_dbi_util_pkg.add_column(l_col_tbl, 'qty_intol', 'qty_intol',p_to_date_type => l_to_date_type);
   poa_dbi_util_pkg.add_column(l_col_tbl, 'qty_afterdue', 'qty_afterdue',p_to_date_type => l_to_date_type);
   poa_dbi_util_pkg.add_column(l_col_tbl, 'amt_receipt_' || l_cur_suffix, 'amt_receipt',p_to_date_type => l_to_date_type);
    poa_dbi_util_pkg.add_column(l_col_tbl, 'num_txns_receipt_cnt', 'cnt_receipt',p_to_date_type => l_to_date_type);
   poa_dbi_util_pkg.add_column(l_col_tbl, 'amt_expt_' || l_cur_suffix, 'amt_expt',p_to_date_type => l_to_date_type);
   l_query := get_status_it_sel_clause(l_view_by,l_view_by_col) || ' from
               ' || poa_dbi_template_pkg.status_sql(l_mv,
                    l_where_clause,
                    l_join_tbl,
                    p_use_windowing => 'Y',
                    p_col_name => l_col_tbl,
		    p_use_grpid => 'N',
		    p_filter_where => get_it_rpt_filter_where,
                    p_in_join_tables => l_in_join_tbl);
   x_custom_sql := l_query;


END;


FUNCTION get_status_filter_where return VARCHAR2

  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_MEASURE1';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_PERCENT1';
    l_col_tbl.extend;
    l_col_tbl(3) := 'POA_MEASURE2';
    l_col_tbl.extend;
    l_col_tbl(4) := 'POA_PERCENT2';
    l_col_tbl.extend;
    l_col_tbl(5) := 'POA_PERCENT3';
    l_col_tbl.extend;
    l_col_tbl(6) := 'POA_MEASURE3';
    l_col_tbl.extend;
    l_col_tbl(7) := 'POA_MEASURE14';
    l_col_tbl.extend;
    l_col_tbl(8) := 'POA_MEASURE15';
    l_col_tbl.extend;
    l_col_tbl(9) := 'POA_ATTRIBUTE3';

    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

END;

FUNCTION get_status_sel_clause(p_view_by_dim in VARCHAR2, p_url in VARCHAR2, p_view_by_col  in VARCHAR2) return VARCHAR2
  IS
  l_sel_clause          varchar2(8000);
  l_view_by_col_name    varchar2(40);
  BEGIN
  l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim, 'PO', '6.0');
     if(p_view_by_dim = 'ITEM+POA_ITEMS') then
       l_sel_clause :=  l_sel_clause ||'
	v.description POA_ATTRIBUTE1, 		--Description
';
     else
       l_sel_clause := l_sel_clause || ' null POA_ATTRIBUTE1,		--Description
';
     end if;
l_sel_clause := l_sel_clause ||
       	  ' oset.POA_MEASURE1 POA_MEASURE1,		-- Exception Amount
           oset.POA_PERCENT1 POA_PERCENT1,		-- Change
           oset.POA_MEASURE2 POA_MEASURE2,		-- Receipt Amount
           oset.POA_PERCENT2 POA_PERCENT2,		-- Exception Amount Rate
           oset.POA_PERCENT3 POA_PERCENT3,		-- Change
           oset.POA_MEASURE3 POA_MEASURE3,		-- Exception Transactions
           oset.POA_MEASURE14 POA_MEASURE14,		-- Change
           oset.POA_MEASURE15 POA_MEASURE15,		-- Exception Transactions Rate
           oset.POA_ATTRIBUTE3 POA_ATTRIBUTE3,		-- Change
           oset.POA_MEASURE4 POA_MEASURE4,		-- Total Exception Amount
 	   oset.POA_MEASURE5 POA_MEASURE5,		-- Total Change
           oset.POA_MEASURE6 POA_MEASURE6,		-- Total Receipt Amount
           oset.POA_MEASURE7 POA_MEASURE7,		-- Total Exception Amount Rate
            oset.POA_MEASURE8 POA_MEASURE8,		-- Total Change
           oset.POA_MEASURE9 POA_MEASURE9,		-- Total Exception Transactions
           oset.POA_MEASURE10 POA_MEASURE10,		-- Total Change
           oset.POA_MEASURE11 POA_MEASURE11,		-- Total Exception Transaction Rate
           oset.POA_MEASURE12 POA_MEASURE12,		-- Total Change
	   oset.POA_MEASURE1 POA_MEASURE13,		-- Exception Amount for horiz bar chart
	   oset.POA_MEASURE16 POA_MEASURE16, 		-- KPI Prior Amt Rate
--	   oset.POA_MEASURE7 POA_MEASURE19, 		-- KPI Total Amt Rate
	   oset.POA_MEASURE20 POA_MEASURE20, 		-- KPI Total Prior Amt Rate
	   oset.POA_MEASURE17 POA_MEASURE17,		-- KPI prior txn rate
	   oset.POA_MEASURE22 POA_MEASURE22,		-- KPI Total Prior txn rate ';
         if(p_view_by_dim = 'ITEM+POA_ITEMS') then
          l_sel_clause := l_sel_clause || '
           ''' || p_url || ''' POA_ATTRIBUTE5';
          else
          l_sel_clause := l_sel_clause || '
           null POA_ATTRIBUTE5';
          end if;
    l_sel_clause := l_sel_clause || '
     from
     (select (rank() over
        ( &ORDER_BY_CLAUSE nulls last, ' || p_view_by_col ;

if(p_view_by_dim = 'ITEM+POA_ITEMS') then
	l_sel_clause := l_sel_clause || ', base_uom';
end if;

l_sel_clause := l_sel_clause || ')) - 1 rnk,'|| p_view_by_col ||',' ;

if(p_view_by_dim = 'ITEM+POA_ITEMS') then
       l_sel_clause :=  l_sel_clause ||' base_uom,';
     end if;
	  l_sel_clause :=  l_sel_clause ||' POA_MEASURE1, POA_PERCENT1,
          POA_MEASURE2, POA_PERCENT2,
	  POA_PERCENT3, POA_MEASURE3,
	  POA_MEASURE14, POA_MEASURE15,
	  POA_ATTRIBUTE3, POA_MEASURE4,
	  POA_MEASURE5, POA_MEASURE6,
          POA_MEASURE7, POA_MEASURE8,
          POA_MEASURE9, POA_MEASURE10,
          POA_MEASURE11, POA_MEASURE12,
	  POA_MEASURE16,POA_MEASURE20,
	  POA_MEASURE17, POA_MEASURE22

       from
  (select ' || p_view_by_col || ',
	' || p_view_by_col || ' VIEWBY,
	';
   if(p_view_by_dim = 'ITEM+POA_ITEMS') then
     l_sel_clause :=  l_sel_clause ||' base_uom,';
   end if;
l_sel_clause :=  l_sel_clause ||
	' nvl(c_amt_expt,0) POA_MEASURE1,
	' || poa_dbi_util_pkg.change_clause('c_amt_expt','p_amt_expt') || ' POA_PERCENT1,
	nvl(c_amt_receipt,0) POA_MEASURE2,
	' || poa_dbi_util_pkg.rate_clause('c_amt_expt','c_amt_receipt') || ' POA_PERCENT2,
	' || poa_dbi_util_pkg.change_clause(
poa_dbi_util_pkg.rate_clause('c_amt_expt', 'c_amt_receipt'),
poa_dbi_util_pkg.rate_clause('p_amt_expt', 'p_amt_receipt'),
'P') ||
		' POA_PERCENT3,
	nvl(c_early_cnt,0) + nvl(c_late_cnt,0) POA_MEASURE3,
	' || poa_dbi_util_pkg.change_clause('(nvl(c_early_cnt,0)+nvl(c_late_cnt,0))','(nvl(p_early_cnt,0)+nvl(p_late_cnt,0))') || ' POA_MEASURE14,
	' || poa_dbi_util_pkg.rate_clause('(nvl(c_early_cnt,0) + nvl(c_late_cnt,0))','(nvl(c_cnt_receipt,0))') || ' POA_MEASURE15,
	' || poa_dbi_util_pkg.change_clause(
poa_dbi_util_pkg.rate_clause('(nvl(c_early_cnt,0) + nvl(c_late_cnt,0))','(nvl(c_cnt_receipt,0))'),
poa_dbi_util_pkg.rate_clause('(nvl(p_early_cnt,0) + nvl(p_late_cnt,0))','(nvl(p_cnt_receipt,0))'),
'P') ||
		' POA_ATTRIBUTE3,
	nvl(c_amt_expt_total,0) POA_MEASURE4,
	' || poa_dbi_util_pkg.change_clause('c_amt_expt_total','p_amt_expt_total')
		|| ' POA_MEASURE5,
	nvl(c_amt_receipt_total,0) POA_MEASURE6,
	' || poa_dbi_util_pkg.rate_clause('c_amt_expt_total','c_amt_receipt_total')
		|| ' POA_MEASURE7,
	' || poa_dbi_util_pkg.change_clause(
		poa_dbi_util_pkg.rate_clause('c_amt_expt_total', 'c_amt_receipt_total'),
		poa_dbi_util_pkg.rate_clause('p_amt_expt_total', 'p_amt_receipt_total'),
		'P') ||
		' POA_MEASURE8,
	nvl(c_early_cnt_total,0) + nvl(c_late_cnt_total,0) POA_MEASURE9,
	' || poa_dbi_util_pkg.change_clause('(nvl(c_early_cnt_total,0)+nvl(c_late_cnt_total,0))','(nvl(p_early_cnt_total,0)+nvl(p_late_cnt_total,0))') || ' POA_MEASURE10,
	' || poa_dbi_util_pkg.rate_clause('(nvl(c_early_cnt_total,0) + nvl(c_late_cnt_total,0))','(nvl(c_cnt_receipt_total,0))') || ' POA_MEASURE11,
	' || poa_dbi_util_pkg.change_clause(
poa_dbi_util_pkg.rate_clause('(nvl(c_early_cnt_total,0) + nvl(c_late_cnt_total,0))','(nvl(c_cnt_receipt_total,0))'),
poa_dbi_util_pkg.rate_clause('(nvl(p_early_cnt_total,0) + nvl(p_late_cnt_total,0))','(nvl(p_cnt_receipt_total,0))'),
'P') ||
		' POA_MEASURE12,
	' || poa_dbi_util_pkg.rate_clause('p_amt_expt','p_amt_receipt') || ' POA_MEASURE16,
	' || poa_dbi_util_pkg.rate_clause('p_amt_expt_total','p_amt_receipt_total') || ' POA_MEASURE20,
	' || poa_dbi_util_pkg.rate_clause('(nvl(p_early_cnt,0) + nvl(p_late_cnt,0))','(nvl(p_cnt_receipt,0))') || ' POA_MEASURE17,
	' || poa_dbi_util_pkg.rate_clause('(nvl(p_early_cnt_total,0) + nvl(p_late_cnt_total,0))','(nvl(p_cnt_receipt_total,0))') || ' POA_MEASURE22';

     return l_sel_clause;
  END;



  FUNCTION get_amt_rpt_sel_clause(p_view_by_dim  in VARCHAR2
                                ,p_url          in VARCHAR2
                                ,p_view_by_col  in VARCHAR2) return VARCHAR2
  IS
  l_sel_clause          varchar2(4000);
  l_view_by_col_name    varchar2(40);
  BEGIN
  l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim, 'PO', '6.0');
       if(p_view_by_dim = 'ITEM+POA_ITEMS') then
       l_sel_clause :=  l_sel_clause ||'
	v.description POA_ATTRIBUTE1, 		--Description
';
     else
       l_sel_clause := l_sel_clause || ' null POA_ATTRIBUTE1,		--Description
';
     end if;
  l_sel_clause := l_sel_clause ||
       	   'oset.POA_MEASURE1 POA_MEASURE1,		--Exception Amount
           oset.POA_PERCENT1 POA_PERCENT1,		--Change
           oset.POA_MEASURE2 POA_MEASURE2,		--Receipt Amount
           oset.POA_PERCENT2 POA_PERCENT2,		--Exception Amount Rate
           oset.POA_MEASURE3 POA_MEASURE3,		--Early Amount
           oset.POA_MEASURE4 POA_MEASURE4,		--Avg Days Early
           oset.POA_MEASURE5 POA_MEASURE5,		--Late Amount
           oset.POA_MEASURE6 POA_MEASURE6,		--Avg Days Late
           oset.POA_MEASURE7 POA_MEASURE7,		--Total Exception Amount Rate
           oset.POA_MEASURE8 POA_MEASURE8,		--Total Change
           oset.POA_MEASURE9 POA_MEASURE9,		--Total Receipt Amount
           oset.POA_MEASURE10 POA_MEASURE10,		--Total Exception Amount Rate
            oset.POA_MEASURE11 POA_MEASURE11,		--Total Early Amount
           oset.POA_MEASURE12 POA_MEASURE12,		--Total Avg Days Early
	   oset.POA_MEASURE13 POA_MEASURE13,		--Total Late Amt
	   oset.POA_MEASURE14 POA_MEASURE14,		--Total Avg Days Late
	   oset.POA_MEASURE15 POA_MEASURE15,		--In Tolerance Amt';
         if(p_view_by_dim = 'ITEM+POA_ITEMS') then
          l_sel_clause := l_sel_clause || '
           ''' || p_url || ''' POA_ATTRIBUTE4';
          else
          l_sel_clause := l_sel_clause || '
           null POA_ATTRIBUTE4';
          end if;
    l_sel_clause := l_sel_clause || '
     from
     (select (rank() over
        ( &ORDER_BY_CLAUSE nulls last, ' || p_view_by_col;

if(p_view_by_dim = 'ITEM+POA_ITEMS') then
	l_sel_clause := l_sel_clause || ', base_uom';
end if;

l_sel_clause := l_sel_clause || ')) - 1 rnk,'|| p_view_by_col ||',' ;
     if(p_view_by_dim = 'ITEM+POA_ITEMS') then
       l_sel_clause :=  l_sel_clause ||' base_uom,';
     end if;
          l_sel_clause :=  l_sel_clause ||' POA_MEASURE1, POA_PERCENT1,
          POA_MEASURE2, POA_PERCENT2,
	  POA_MEASURE3, POA_MEASURE4,
	  POA_MEASURE5, POA_MEASURE6,
          POA_MEASURE7, POA_MEASURE8,
          POA_MEASURE9, POA_MEASURE10,
          POA_MEASURE11, POA_MEASURE12,
          POA_MEASURE13, POA_MEASURE14,
	  POA_MEASURE15
       from
  (select ' || p_view_by_col || ',
	' || p_view_by_col || ' VIEWBY,';
   if(p_view_by_dim = 'ITEM+POA_ITEMS') then
     l_sel_clause :=  l_sel_clause ||' base_uom,';
   end if;
l_sel_clause :=  l_sel_clause ||
	'nvl(c_amt_expt,0) POA_MEASURE1,
	' || poa_dbi_util_pkg.change_clause('c_amt_expt','p_amt_expt') || ' POA_PERCENT1,
	nvl(c_amt_receipt,0) POA_MEASURE2,
	' || poa_dbi_util_pkg.rate_clause('c_amt_expt','c_amt_receipt') || ' POA_PERCENT2,
	nvl(c_amt_early,0) POA_MEASURE3,
        c_num_days_early/decode(c_early_cnt, 0, null, c_early_cnt) POA_MEASURE4,
	nvl(c_amt_late,0) POA_MEASURE5,
        c_num_days_late/decode(c_late_cnt, 0, null, c_late_cnt) POA_MEASURE6,
	nvl(c_amt_expt_total,0) POA_MEASURE7,
	' || poa_dbi_util_pkg.change_clause('c_amt_expt_total','p_amt_expt_total') || ' POA_MEASURE8,
	nvl(c_amt_receipt_total,0) POA_MEASURE9,
	' || poa_dbi_util_pkg.rate_clause('c_amt_expt_total','c_amt_receipt_total') || ' POA_MEASURE10,
	nvl(c_amt_early_total,0) POA_MEASURE11,
        c_num_days_early_total/decode(c_early_cnt_total, 0, null, c_early_cnt_total) POA_MEASURE12,
	nvl(c_amt_late_total,0) POA_MEASURE13,
        c_num_days_late_total/decode(c_late_cnt_total, 0, null, c_late_cnt_total) POA_MEASURE14,
        nvl(c_amt_receipt,0) - nvl(c_amt_early,0) - nvl(c_amt_late,0) POA_MEASURE15';


     return l_sel_clause;
  END;


  FUNCTION get_txn_rpt_sel_clause(p_view_by_dim  in VARCHAR2
                                ,p_url          in VARCHAR2
                                ,p_view_by_col  in VARCHAR2) return VARCHAR2
  IS
  l_sel_clause          varchar2(4000);
  l_view_by_col_name    varchar2(40);
  BEGIN
  l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim, 'PO', '6.0');
   if(p_view_by_dim = 'ITEM+POA_ITEMS') then
     l_sel_clause :=  l_sel_clause ||'
   v.description POA_ATTRIBUTE1, 		--Description
';
     else
       l_sel_clause := l_sel_clause || ' null POA_ATTRIBUTE1,  --Description
';
     end if;

l_sel_clause := l_sel_clause ||
	   'oset.POA_MEASURE1 POA_MEASURE1,		--Exception Trans
           oset.POA_PERCENT1 POA_PERCENT1,		--Change
           oset.POA_MEASURE2 POA_MEASURE2,		--Receipt Trans
           oset.POA_PERCENT2 POA_PERCENT2,		--Exception Trans Rate
           oset.POA_MEASURE3 POA_MEASURE3,		--Early Trans
           oset.POA_MEASURE4 POA_MEASURE4,		--Avg Days Early
           oset.POA_MEASURE5 POA_MEASURE5,		--Late Trans
           oset.POA_MEASURE6 POA_MEASURE6,		--Avg Days Late
           oset.POA_MEASURE7 POA_MEASURE7,		--Total Exception Trans
           oset.POA_MEASURE8 POA_MEASURE8,		--Total Change
           oset.POA_MEASURE9 POA_MEASURE9,		--Total Receipt Trans
           oset.POA_MEASURE10 POA_MEASURE10,		--Total Exception Trans Rate
            oset.POA_MEASURE11 POA_MEASURE11,		--Total Early Trans
           oset.POA_MEASURE12 POA_MEASURE12,		--Total Avg Days Early
	   oset.POA_MEASURE13 POA_MEASURE13,		--Total Late Trans
	   oset.POA_MEASURE14 POA_MEASURE14,		--Total Avg Days Late
	   oset.POA_MEASURE15 POA_MEASURE15,		--In Tolerance Trans.';
          if(p_view_by_dim = 'ITEM+POA_ITEMS') then
          l_sel_clause := l_sel_clause || '
           ''' || p_url || ''' POA_ATTRIBUTE4';
          else
          l_sel_clause := l_sel_clause || '
           null POA_ATTRIBUTE4';
          end if;
    l_sel_clause := l_sel_clause || '
     from
     (select (rank() over
        ( &ORDER_BY_CLAUSE nulls last, ' || p_view_by_col;

if(p_view_by_dim = 'ITEM+POA_ITEMS') then
	l_sel_clause := l_sel_clause || ', base_uom';
end if;

l_sel_clause := l_sel_clause || ')) - 1 rnk,'|| p_view_by_col ||',' ;
     if(p_view_by_dim = 'ITEM+POA_ITEMS') then
       l_sel_clause :=  l_sel_clause ||' base_uom,';
     end if;
          l_sel_clause :=  l_sel_clause ||' POA_MEASURE1, POA_PERCENT1,
          POA_MEASURE2, POA_PERCENT2,
	  POA_MEASURE3, POA_MEASURE4,
	  POA_MEASURE5, POA_MEASURE6,
          POA_MEASURE7, POA_MEASURE8,
          POA_MEASURE9, POA_MEASURE10,
          POA_MEASURE11, POA_MEASURE12,
          POA_MEASURE13, POA_MEASURE14,
	  POA_MEASURE15
       from
  (select ' || p_view_by_col || ',
	' || p_view_by_col || ' VIEWBY,';
   if(p_view_by_dim = 'ITEM+POA_ITEMS') then
     l_sel_clause :=  l_sel_clause ||' base_uom,';
   end if;
l_sel_clause :=  l_sel_clause ||
	'nvl(c_early_cnt,0) + nvl(c_late_cnt,0) POA_MEASURE1,
	' || poa_dbi_util_pkg.change_clause('(nvl(c_early_cnt,0)+nvl(c_late_cnt,0))','(nvl(p_early_cnt,0)+nvl(p_late_cnt,0))') || ' POA_PERCENT1,
	nvl(c_cnt_receipt,0) POA_MEASURE2,
	' || poa_dbi_util_pkg.rate_clause('(nvl(c_early_cnt,0) + nvl(c_late_cnt,0))','c_cnt_receipt') || ' POA_PERCENT2,
	nvl(c_early_cnt,0) POA_MEASURE3,
        c_num_days_early/decode(c_early_cnt, 0, null, c_early_cnt) POA_MEASURE4,
	nvl(c_late_cnt,0) POA_MEASURE5,
        c_num_days_late/decode(c_late_cnt, 0, null, c_late_cnt) POA_MEASURE6,
	nvl(c_early_cnt_total,0) + nvl(c_late_cnt_total, 0) POA_MEASURE7,
	' || poa_dbi_util_pkg.change_clause('(nvl(c_early_cnt_total,0) + nvl(c_late_cnt_total,0))','(nvl(p_early_cnt_total,0) + nvl(p_late_cnt_total,0))') || ' POA_MEASURE8,
	nvl(c_cnt_receipt_total,0) POA_MEASURE9,
	' || poa_dbi_util_pkg.rate_clause('(nvl(c_early_cnt_total,0) + nvl(c_late_cnt_total,0))','c_cnt_receipt_total') || ' POA_MEASURE10,
	nvl(c_early_cnt_total,0) POA_MEASURE11,
        c_num_days_early_total/decode(c_early_cnt_total, 0, null, c_early_cnt_total) POA_MEASURE12,
	nvl(c_late_cnt_total,0) POA_MEASURE13,
        c_num_days_late_total/decode(c_late_cnt_total, 0, null, c_late_cnt_total) POA_MEASURE14,
        nvl(c_cnt_receipt,0) - nvl(c_early_cnt,0) - nvl(c_late_cnt,0) POA_MEASURE15';


     return l_sel_clause;
  END;


FUNCTION get_it_rpt_filter_where return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_MEASURE2';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_MEASURE3';
    l_col_tbl.extend;
    l_col_tbl(3) := 'POA_MEASURE4';
    l_col_tbl.extend;
    l_col_tbl(4) := 'POA_MEASURE5';
    l_col_tbl.extend;
    l_col_tbl(5) := 'POA_MEASURE6';
    l_col_tbl.extend;
    l_col_tbl(6) := 'POA_MEASURE7';
    l_col_tbl.extend;
    l_col_tbl(7) := 'POA_MEASURE8';
    l_col_tbl.extend;
    l_col_tbl(8) := 'POA_MEASURE9';
    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

END;

FUNCTION get_amt_rpt_filter_where return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_MEASURE1';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_PERCENT1';
    l_col_tbl.extend;
    l_col_tbl(3) := 'POA_MEASURE2';
    l_col_tbl.extend;
    l_col_tbl(4) := 'POA_PERCENT2';
    l_col_tbl.extend;
    l_col_tbl(5) := 'POA_MEASURE3';
    l_col_tbl.extend;
    l_col_tbl(6) := 'POA_MEASURE4';
    l_col_tbl.extend;
    l_col_tbl(7) := 'POA_MEASURE5';
    l_col_tbl.extend;
    l_col_tbl(8) := 'POA_MEASURE6';
    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

END;

FUNCTION get_txn_rpt_filter_where return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_MEASURE1';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_PERCENT1';
    l_col_tbl.extend;
    l_col_tbl(3) := 'POA_MEASURE2';
    l_col_tbl.extend;
    l_col_tbl(4) := 'POA_PERCENT2';
    l_col_tbl.extend;
    l_col_tbl(5) := 'POA_MEASURE3';
    l_col_tbl.extend;
    l_col_tbl(6) := 'POA_MEASURE4';
    l_col_tbl.extend;
    l_col_tbl(7) := 'POA_MEASURE5';
    l_col_tbl.extend;
    l_col_tbl(8) := 'POA_MEASURE6';
    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

END;

FUNCTION get_status_it_sel_clause(p_view_by_dim IN VARCHAR2,p_view_by_col in VARCHAR2) return VARCHAR2 IS
  l_sel_clause varchar2(4000);
  l_view_by_col_name varchar2(40);
  BEGIN
  --
  --
  l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim, 'PO', '6.0');
  --
  l_sel_clause := l_sel_clause ||'
	v.description POA_ATTRIBUTE1,		--Description
	v2.description POA_ATTRIBUTE2,		--UOM
	oset.POA_MEASURE2 POA_MEASURE2,		--Early
	oset.POA_MEASURE3 POA_MEASURE3,		--In Tolerance
	oset.POA_MEASURE4 POA_MEASURE4,		--Late
	oset.POA_MEASURE5 POA_MEASURE5,		--Total
	oset.POA_MEASURE6 POA_MEASURE6,		--Exception Amount
	oset.POA_MEASURE7 POA_MEASURE7,		--Receipt Amount
	oset.POA_MEASURE8 POA_MEASURE8,		--Exception Transactions
	oset.POA_MEASURE9 POA_MEASURE9,		--Receipt Transactions
	oset.POA_MEASURE10 POA_MEASURE10,	--Total Exception Amount
	oset.POA_MEASURE11 POA_MEASURE11,	--Total Receipt Amount
	oset.POA_MEASURE12 POA_MEASURE12,	--Total Exception Transactions
	oset.POA_MEASURE13 POA_MEASURE13	--Total Receipt Transactions
    from
     (select (rank() over

                   (&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col || ', base_uom)) - 1 rnk,'

        || p_view_by_col || ',
           base_uom, POA_MEASURE2, POA_MEASURE3, POA_MEASURE4,
           POA_MEASURE5, POA_MEASURE6, POA_MEASURE7,
           POA_MEASURE8, POA_MEASURE9, POA_MEASURE10,
	   POA_MEASURE11, POA_MEASURE12,POA_MEASURE13 from
     (select ' || p_view_by_col || ',
             ' || p_view_by_col || ' VIEWBY,
           base_uom,
           decode(base_uom,null,to_number(null),nvl(c_qty_beforedue,0)) POA_MEASURE2,
           decode(base_uom,null,to_number(null),nvl(c_qty_intol,0)) POA_MEASURE3,
           decode(base_uom,null,to_number(null),nvl(c_qty_afterdue,0)) POA_MEASURE4,
           decode(base_uom,null,to_number(null),(nvl(c_qty_beforedue,0)+nvl(c_qty_intol,0)+nvl(c_qty_afterdue,0))) POA_MEASURE5,

           nvl(c_amt_expt,0) POA_MEASURE6,
	   nvl(c_amt_receipt,0) POA_MEASURE7,
	   nvl(c_early_cnt,0)+nvl(c_late_cnt,0) POA_MEASURE8,
	   nvl(c_cnt_receipt,0) POA_MEASURE9,
           nvl(c_amt_expt_total,0) POA_MEASURE10,
	   nvl(c_amt_receipt_total,0) POA_MEASURE11,
	   nvl(c_early_cnt_total,0)+nvl(c_late_cnt_total,0) POA_MEASURE12,
           nvl(c_cnt_receipt_total,0) POA_MEASURE13';

  return l_sel_clause;

  END;

PROCEDURE trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                    x_custom_sql  OUT NOCOPY VARCHAR2,
                    x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
    l_query             varchar2(10000);
    l_view_by           varchar2(120);
    l_view_by_col       varchar2(120);
    l_view_by_value     VARCHAR2(300);
    l_as_of_date        date;
    l_prev_as_of_date   date;
    l_xtd               varchar2(10);
    l_comparison_type   varchar2(1) := 'Y';
    l_nested_pattern    number;
    l_cur_suffix        varchar2(2);
    l_custom_sql        varchar2(10000);
    l_col_tbl           poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_join_tbl          poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
    l_in_join_tbl       poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
    l_mv                VARCHAR2(30);
    l_where_clause      VARCHAR2(2000);
    l_context_code      VARCHAR2(10);
    l_to_date_type      VARCHAR2(10);
   BEGIN
   l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
   l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();
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
					,'Y','PO', '6.0', 'COM','RTX');
   l_context_code := poa_dbi_sutil_pkg.get_sec_context(p_param);
   IF(l_context_code = 'OU' or l_context_code = 'SUPPLIER') THEN
    l_to_date_type := 'RLX';
   ELSE
    l_to_date_type := 'XTD';
   END IF;

   poa_dbi_util_pkg.add_column(l_col_tbl, 'num_txns_early_cnt', 'early_cnt', 'N',p_to_date_type => l_to_date_type);
   poa_dbi_util_pkg.add_column(l_col_tbl, 'num_txns_late_cnt', 'late_cnt', 'N',p_to_date_type => l_to_date_type);
   poa_dbi_util_pkg.add_column(l_col_tbl, 'amt_expt_' || l_cur_suffix,'amt_expt', 'N',p_to_date_type => l_to_date_type);

   l_query := get_trend_sel_clause || ' from
              '|| poa_dbi_template_pkg.trend_sql(l_xtd,
                                               l_comparison_type,
                                               l_mv,
                                               l_where_clause,
                                               l_col_tbl,
					   	p_use_grpid => 'N',
                                               p_in_join_tables => l_in_join_tbl);
   x_custom_sql := l_query;
   END;

  FUNCTION get_trend_sel_clause return VARCHAR2 IS
    l_sel_clause varchar2(4000);
  BEGIN
  l_sel_clause :='select cal.name VIEWBY,
  nvl(p_amt_expt,0) POA_MEASURE3,
  nvl(c_amt_expt,0) POA_MEASURE1,
  ' || poa_dbi_util_pkg.change_clause('c_amt_expt','p_amt_expt') || ' POA_PERCENT1,
  nvl(p_early_cnt,0)+nvl(p_late_cnt,0) POA_MEASURE4,
  nvl(c_early_cnt,0)+nvl(c_late_cnt,0) POA_MEASURE2,
  ' || poa_dbi_util_pkg.change_clause('(nvl(c_early_cnt,0)+nvl(c_late_cnt,0))','(nvl(p_early_cnt,0)+nvl(p_late_cnt,0))') || ' POA_PERCENT3';
  return l_sel_clause;
  END;
end poa_dbi_rde_pkg;

/
