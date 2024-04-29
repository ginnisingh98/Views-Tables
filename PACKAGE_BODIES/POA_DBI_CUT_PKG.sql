--------------------------------------------------------
--  DDL for Package Body POA_DBI_CUT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_CUT_PKG" 
/* $Header: poadbicutb.pls 120.11 2006/01/09 01:48:21 sdiwakar noship $*/
AS
FUNCTION get_status_sel_clause(
           p_view_by_dim in VARCHAR2,
           p_view_by_col in VARCHAR2,
           p_sec_context in VARCHAR2
         ) return VARCHAR2;
FUNCTION get_con_rpt_sel_clause(
           p_view_by_dim in VARCHAR2,
           p_view_by_col in VARCHAR2,
           p_sec_context in VARCHAR2
         ) return VARCHAR2;
FUNCTION get_ncp_rpt_sel_clause(
           p_view_by_dim in VARCHAR2,
           p_view_by_col in VARCHAR2,
           p_sec_context in VARCHAR2
         ) return VARCHAR2;
FUNCTION get_pcl_rpt_sel_clause(
           p_view_by_dim in VARCHAR2,
           p_view_by_col in VARCHAR2,
           p_sec_context in VARCHAR2
         ) return VARCHAR2;
FUNCTION get_pop_trend_sel_clause(p_type in varchar2 := 'trend') return VARCHAR2;
FUNCTION get_trend_sel_clause(p_type in varchar2 := 'trend') return VARCHAR2;
FUNCTION get_status_filter_where(p_view_by IN VARCHAR2) return VARCHAR2;
FUNCTION get_con_rpt_filter_where(p_view_by IN VARCHAR2) return VARCHAR2;
FUNCTION get_ncp_rpt_filter_where(p_view_by IN VARCHAR2) return VARCHAR2;
FUNCTION get_pcl_rpt_filter_where(p_view_by IN VARCHAR2) return VARCHAR2;
FUNCTION get_doctype_filter_where return VARCHAR2;
FUNCTION get_doctype_sel_clause(p_view_by_col_name in VARCHAR2, p_url in VARCHAR2)
  return VARCHAR2;

  PROCEDURE status_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
    l_query varchar2(10000);
    l_view_by varchar2(120);
    l_view_by_col varchar2(120);
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
    l_in_join_tbl2 poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
    l_view_by_value VARCHAR2(100);
    l_where_clause VARCHAR2(2000);
    l_where_clause2 VARCHAR2(2000);
    l_mv VARCHAR2(30);
    l_mv2 VARCHAR2(30);
    l_sec_context varchar2(10);
    l_use_only_agg_mv varchar2(1);
    l_mv_tbl poa_dbi_util_pkg.poa_dbi_mv_tbl;

  BEGIN
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();

    l_sec_context := poa_dbi_sutil_pkg.get_sec_context(p_param);
    if (l_sec_context = 'OU' or l_sec_context = 'OU/COM')then
      poa_dbi_sutil_pkg.process_parameters(
        p_param              => p_param,
        p_view_by            => l_view_by,
        p_view_by_col_name   => l_view_by_col,
        p_view_by_value      => l_view_by_value,
        p_comparison_type    => l_comparison_type,
        p_xtd                => l_xtd,
        p_as_of_date         => l_as_of_date,
        p_prev_as_of_date    => l_prev_as_of_date,
        p_cur_suffix         => l_cur_suffix,
        p_nested_pattern     => l_nested_pattern,
        p_where_clause       => l_where_clause,
        p_mv                 => l_mv,
        p_join_tbl           => l_join_tbl,
        p_in_join_tbl        => l_in_join_tbl,
        x_custom_output      => x_custom_output,
        p_trend              => 'N',
        p_func_area          => 'PO',
        p_version            => '6.0',
        p_role               => 'COM',
        p_mv_set             => 'PODCUT');

      poa_dbi_util_pkg.add_column(l_col_tbl, 'n_contract_amt_' || l_cur_suffix, 'n_contract_amt');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'contract_amt_' || l_cur_suffix, 'contract_amt');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'p_contract_amt_' || l_cur_suffix, 'p_contract_amt');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix, 'purchase_amt');

      if(l_view_by = 'ITEM+POA_ITEMS') then
        poa_dbi_util_pkg.add_column(l_col_tbl, 'quantity', 'quantity');
      end if;

      l_query := get_status_sel_clause(l_view_by, l_view_by_col, l_sec_context) || ' from
              ' || poa_dbi_template_pkg.status_sql(
                     p_fact_name      => l_mv,
                     p_where_clause   => l_where_clause,
                     p_join_tables    => l_join_tbl,
                     p_use_windowing  => 'Y',
                     p_col_name       => l_col_tbl,
                     p_use_grpid      => 'N',
                     p_filter_where   => get_status_filter_where(l_view_by),
                     p_in_join_tables => l_in_join_tbl);

    elsif (l_sec_context = 'COMP') then
      poa_dbi_sutil_pkg.process_parameters(
        p_param              => p_param,
        p_view_by            => l_view_by,
        p_view_by_col_name   => l_view_by_col,
        p_view_by_value      => l_view_by_value,
        p_comparison_type    => l_comparison_type,
        p_xtd                => l_xtd,
        p_as_of_date         => l_as_of_date,
        p_prev_as_of_date    => l_prev_as_of_date,
        p_cur_suffix         => l_cur_suffix,
        p_nested_pattern     => l_nested_pattern,
        p_where_clause       => l_where_clause,
        p_mv                 => l_mv,
        p_join_tbl           => l_join_tbl,
        p_in_join_tbl        => l_in_join_tbl,
        x_custom_output      => x_custom_output,
        p_trend              => 'N',
        p_func_area          => 'PO',
        p_version            => '8.0',
        p_role               => 'COM',
        p_mv_set             => 'PODCUTA');

      poa_dbi_util_pkg.add_column(l_col_tbl, 'n_contract_amt_' || l_cur_suffix, 'n_contract_amt');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'contract_amt_' || l_cur_suffix, 'contract_amt');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'p_contract_amt_' || l_cur_suffix, 'p_contract_amt');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix, 'purchase_amt');

      if(l_view_by = 'ITEM+POA_ITEMS') then
        poa_dbi_util_pkg.add_column(l_col_tbl, 'quantity', 'quantity');
      end if;

      /*check if we can get everything from aggregated mv*/
      l_use_only_agg_mv := 'Y';
      for i in 1..l_in_join_tbl.count loop
        if(l_in_join_tbl(i).table_alias = 'com' or l_in_join_tbl(i).table_alias = 'cc') then
          if(l_in_join_tbl(i).aggregated_flag = 'N')then
            l_use_only_agg_mv := 'N';
          end if;
        end if;
      end loop;

      if(l_use_only_agg_mv = 'N') then
        poa_dbi_sutil_pkg.process_parameters(
        p_param              => p_param,
        p_view_by            => l_view_by,
        p_view_by_col_name   => l_view_by_col,
        p_view_by_value      => l_view_by_value,
        p_comparison_type    => l_comparison_type,
        p_xtd                => l_xtd,
        p_as_of_date         => l_as_of_date,
        p_prev_as_of_date    => l_prev_as_of_date,
        p_cur_suffix         => l_cur_suffix,
        p_nested_pattern     => l_nested_pattern,
        p_where_clause       => l_where_clause2,
        p_mv                 => l_mv2,
        p_join_tbl           => l_join_tbl,
        p_in_join_tbl        => l_in_join_tbl2,
        x_custom_output      => x_custom_output,
        p_trend              => 'N',
        p_func_area          => 'PO',
        p_version            => '8.0',
        p_role               => 'COM',
        p_mv_set             => 'PODCUTB');

        l_mv_tbl := poa_dbi_util_pkg.poa_dbi_mv_tbl();
        l_mv_tbl.extend;
        l_mv_tbl(1).mv_name := l_mv;
        l_mv_tbl(1).mv_col := l_col_tbl;
        l_mv_tbl(1).mv_where := l_where_clause;
        l_mv_tbl(1).in_join_tbls := l_in_join_tbl;
        l_mv_tbl(1).use_grp_id := 'N';

        l_mv_tbl.extend;
        l_mv_tbl(2).mv_name := l_mv2;
        l_mv_tbl(2).mv_col := l_col_tbl;
        l_mv_tbl(2).mv_where := l_where_clause2;
        l_mv_tbl(2).in_join_tbls := l_in_join_tbl2;
        l_mv_tbl(2).use_grp_id := 'N';

        l_query := get_status_sel_clause(l_view_by, l_view_by_col, l_sec_context) || ' from (
              ' || poa_dbi_template_pkg.union_all_status_sql(
                    p_mv              => l_mv_tbl,
                    p_join_tables     => l_join_tbl,
                    p_use_windowing   => 'Y',
                    p_paren_count     => 3,
                    p_filter_where    => get_status_filter_where(l_view_by),
                    p_generate_viewby => 'Y',
                    p_diff_measures   => 'N');
      else
        l_query := get_status_sel_clause(l_view_by, l_view_by_col, l_sec_context) || ' from
              ' || poa_dbi_template_pkg.status_sql(
                     p_fact_name      => l_mv,
                     p_where_clause   => l_where_clause,
                     p_join_tables    => l_join_tbl,
                     p_use_windowing  => 'Y',
                     p_col_name       => l_col_tbl,
                     p_use_grpid      => 'N',
                     p_filter_where   => get_status_filter_where(l_view_by),
                     p_in_join_tables => l_in_join_tbl);
      end if; /* l_use_only_agg_mv = 'N' */
    end if; /* l_sec_context = 'OU' or l_sec_context = 'OU/COM' */
    x_custom_sql := l_query;
  end;


  FUNCTION get_status_filter_where(p_view_by in VARCHAR2) return VARCHAR2
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

    if(p_view_by= 'ITEM+POA_ITEMS') then
      l_col_tbl.extend;
      l_col_tbl(6) := 'POA_MEASURE12';
    end if;

    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

  END;


  FUNCTION get_status_sel_clause(
             p_view_by_dim in VARCHAR2,
             p_view_by_col in VARCHAR2,
             p_sec_context in VARCHAR2) return VARCHAR2
  IS
    l_sel_clause varchar2(8000);
  BEGIN
    l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim, 'PO', '6.0');

    if(p_view_by_dim = 'ITEM+POA_ITEMS') then
      l_sel_clause := l_sel_clause || ' v.description POA_ATTRIBUTE1,
        v2.description POA_ATTRIBUTE2, oset.POA_MEASURE12 POA_MEASURE12, ';
    else
    l_sel_clause := l_sel_clause || '
      null POA_MEASURE12, --Quantity
      null POA_ATTRIBUTE1, --Description
      null POA_ATTRIBUTE2, --UOM
';
    end if;

    l_sel_clause := l_sel_clause || '
    oset.POA_MEASURE1 POA_MEASURE1,   --PO Purchases Amount
    oset.POA_PERCENT1 POA_PERCENT1,   --Contract Purchases Rate
    oset.POA_MEASURE2 POA_MEASURE2,   --Change
    oset.POA_PERCENT2 POA_PERCENT2,   --Non-Contract Purchases Rate
    oset.POA_MEASURE3 POA_MEASURE3,   --Change
    null              POA_PERCENT3,   --(Obsoleted)Contract Leakage Rate
    null              POA_MEASURE4,   --(Obsoleted)Change
    oset.POA_MEASURE5 POA_MEASURE5,   --Total PO Purchases Amount
    oset.POA_MEASURE6 POA_MEASURE6,   --Total Contract Purchases Rate
    oset.POA_MEASURE7 POA_MEASURE7,   --Total Change
    oset.POA_MEASURE8 POA_MEASURE8,   --Total Non-Contract Purchases Rate
    oset.POA_MEASURE9 POA_MEASURE9,   --Total Change
    null              POA_PERCENT3,   --(Obsoleted)Contract Leakage Rate
    null              POA_MEASURE4,   --(Obsoleted)Change';

    if (p_view_by_dim = 'FII_COMPANIES+FII_COMPANIES' or
        p_view_by_dim = 'ORGANIZATION+HRI_CL_ORGCC') then
      l_sel_clause := l_sel_clause || '
        decode(v.summary_flag,''Y'',''pFunctionName=POA_DBI_CC_CUT_STATUS_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'',null) POA_ATTRIBUTE5,
        decode(v.summary_flag,''Y'',''pFunctionName=POA_DBI_CC_CUT_STATUS_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'',null) POA_ATTRIBUTE6,';
    else
      l_sel_clause := l_sel_clause || '
        null POA_ATTRIBUTE5,
        null POA_ATTRIBUTE6,';
    end if;

    if (p_sec_context = 'COMP') then
      l_sel_clause := l_sel_clause ||'
        ''pFunctionName=POA_DBI_CC_CUT_STATUS_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+POA_ITEMS&pParamIds=Y'' POA_ATTRIBUTE7,
        ''pFunctionName=POA_DBI_CC_CUT_CON_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=SUPPLIER+POA_SUPPLIERS&pParamIds=Y'' POA_ATTRIBUTE8,
        ''pFunctionName=POA_DBI_CC_CUT_NCP_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=SUPPLIER+POA_SUPPLIERS&pParamIds=Y'' POA_ATTRIBUTE9 ';
    else
      l_sel_clause := l_sel_clause ||'
        ''pFunctionName=POA_DBI_CUT_STATUS_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+POA_ITEMS&pParamIds=Y'' POA_ATTRIBUTE7,
        ''pFunctionName=POA_DBI_CUT_CON_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=SUPPLIER+POA_SUPPLIERS&pParamIds=Y'' POA_ATTRIBUTE8,
        ''pFunctionName=POA_DBI_CUT_NCP_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=SUPPLIER+POA_SUPPLIERS&pParamIds=Y'' POA_ATTRIBUTE9 ';
    end if;

    l_sel_clause := l_sel_clause || '
    from
    (select (rank() over ( &ORDER_BY_CLAUSE nulls last, ' || p_view_by_col;

    if(p_view_by_dim = 'ITEM+POA_ITEMS') then
      l_sel_clause := l_sel_clause || ', base_uom';
    end if;

    l_sel_clause := l_sel_clause || ')) - 1 rnk,'
        || p_view_by_col;

    if(p_view_by_dim = 'ITEM+POA_ITEMS') then
      l_sel_clause := l_sel_clause || ', base_uom, POA_MEASURE12';
    end if;

    l_sel_clause := l_sel_clause || ',
        POA_PERCENT1, POA_MEASURE1,
        POA_PERCENT2, POA_MEASURE2,
        POA_MEASURE3, POA_MEASURE5,
        POA_MEASURE6, POA_MEASURE7,
        POA_MEASURE8, POA_MEASURE9
     from
     (select ' || p_view_by_col || ',
             ' || p_view_by_col || ' VIEWBY,';

    if(p_view_by_dim = 'ITEM+POA_ITEMS') then
      l_sel_clause := l_sel_clause || ' base_uom, decode(base_uom,null,to_number(null),nvl(c_quantity,0)) POA_MEASURE12, ';
    end if;

    l_sel_clause := l_sel_clause || '
    nvl(c_purchase_amt,0) POA_MEASURE1,
    ' ||
    poa_dbi_util_pkg.rate_clause('c_contract_amt', 'c_purchase_amt')
    || ' POA_PERCENT1,
    ' ||
    poa_dbi_util_pkg.change_clause(
        poa_dbi_util_pkg.rate_clause(    'c_contract_amt',
                        'c_purchase_amt'),
        poa_dbi_util_pkg.rate_clause(    'p_contract_amt',
                        'p_purchase_amt'),
        'P')
    || ' POA_MEASURE2,
    ' ||
    poa_dbi_util_pkg.rate_clause('c_n_contract_amt', 'c_purchase_amt')
    || ' POA_PERCENT2,
    ' ||
    poa_dbi_util_pkg.change_clause(
        poa_dbi_util_pkg.rate_clause('c_n_contract_amt', 'c_purchase_amt'),
        poa_dbi_util_pkg.rate_clause('p_n_contract_amt', 'p_purchase_amt'),
        'P')
    || ' POA_MEASURE3,
    nvl(c_purchase_amt_total,0) POA_MEASURE5,
    ' ||
    poa_dbi_util_pkg.rate_clause(    'c_contract_amt_total',
                    'c_purchase_amt_total')
    || ' POA_MEASURE6,
    ' ||
    poa_dbi_util_pkg.change_clause(
        poa_dbi_util_pkg.rate_clause(    'c_contract_amt_total',
                        'c_purchase_amt_total'),
        poa_dbi_util_pkg.rate_clause(    'p_contract_amt_total',
                        'p_purchase_amt_total'),
        'P')
    || ' POA_MEASURE7,
    ' ||
    poa_dbi_util_pkg.rate_clause(    'c_n_contract_amt_total',
                    'c_purchase_amt_total')
    || ' POA_MEASURE8,
    ' ||
    poa_dbi_util_pkg.change_clause(
        poa_dbi_util_pkg.rate_clause(    'c_n_contract_amt_total',
                    'c_purchase_amt_total'),
        poa_dbi_util_pkg.rate_clause(    'p_n_contract_amt_total',
                    'p_purchase_amt_total'),
        'P')
    || ' POA_MEASURE9 ';
     return l_sel_clause;
  END;


  PROCEDURE con_rpt_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY  VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
    l_query varchar2(10000);
    l_view_by varchar2(120);
    l_view_by_col varchar2(120);
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
    l_in_join_tbl2 poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
    l_view_by_value VARCHAR2(100);
    l_where_clause VARCHAR2(2000);
    l_where_clause2 VARCHAR2(2000);
    l_mv VARCHAR2(30);
    l_mv2 VARCHAR2(30);
    l_sec_context varchar2(10);
    l_use_only_agg_mv varchar2(1);
    l_mv_tbl poa_dbi_util_pkg.poa_dbi_mv_tbl;
  BEGIN
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();

    l_sec_context := poa_dbi_sutil_pkg.get_sec_context(p_param);
    if (l_sec_context = 'OU' or l_sec_context = 'OU/COM')then
      poa_dbi_sutil_pkg.process_parameters(
        p_param              => p_param,
        p_view_by            => l_view_by,
        p_view_by_col_name   => l_view_by_col,
        p_view_by_value      => l_view_by_value,
        p_comparison_type    => l_comparison_type,
        p_xtd                => l_xtd,
        p_as_of_date         => l_as_of_date,
        p_prev_as_of_date    => l_prev_as_of_date,
        p_cur_suffix         => l_cur_suffix,
        p_nested_pattern     => l_nested_pattern,
        p_where_clause       => l_where_clause,
        p_mv                 => l_mv,
        p_join_tbl           => l_join_tbl,
        p_in_join_tbl        => l_in_join_tbl ,
        x_custom_output      => x_custom_output,
        p_trend              => 'N',
        p_func_area          => 'PO',
        p_version            => '6.0',
        p_role               => 'COM',
        p_mv_set             => 'PODCUT');

      poa_dbi_util_pkg.add_column(l_col_tbl, 'contract_amt_' || l_cur_suffix, 'contract_amt');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix, 'purchase_amt');

      if(l_view_by = 'ITEM+POA_ITEMS') then
        poa_dbi_util_pkg.add_column(l_col_tbl, 'quantity', 'quantity');
      end if;

      l_query := get_con_rpt_sel_clause(l_view_by, l_view_by_col, l_sec_context) || ' from
              ' ||poa_dbi_template_pkg.status_sql(
                    p_fact_name      => l_mv,
                    p_where_clause   => l_where_clause,
                    p_join_tables    => l_join_tbl,
                    p_use_windowing  => 'Y',
                    p_col_name       => l_col_tbl,
                    p_use_grpid      => 'N',
                    p_filter_where   => get_con_rpt_filter_where(l_view_by),
                    p_in_join_tables => l_in_join_tbl);

    elsif (l_sec_context = 'COMP') then
      poa_dbi_sutil_pkg.process_parameters(
        p_param              => p_param,
        p_view_by            => l_view_by,
        p_view_by_col_name   => l_view_by_col,
        p_view_by_value      => l_view_by_value,
        p_comparison_type    => l_comparison_type,
        p_xtd                => l_xtd,
        p_as_of_date         => l_as_of_date,
        p_prev_as_of_date    => l_prev_as_of_date,
        p_cur_suffix         => l_cur_suffix,
        p_nested_pattern     => l_nested_pattern,
        p_where_clause       => l_where_clause,
        p_mv                 => l_mv,
        p_join_tbl           => l_join_tbl,
        p_in_join_tbl        => l_in_join_tbl ,
        x_custom_output      => x_custom_output,
        p_trend              => 'N',
        p_func_area          => 'PO',
        p_version            => '8.0',
        p_role               => 'COM',
        p_mv_set             => 'PODCUTA');

      poa_dbi_util_pkg.add_column(l_col_tbl, 'contract_amt_' || l_cur_suffix, 'contract_amt');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix, 'purchase_amt');

      if(l_view_by = 'ITEM+POA_ITEMS') then
        poa_dbi_util_pkg.add_column(l_col_tbl, 'quantity', 'quantity');
      end if;

      /*check if we can get everything from aggregated mv*/
      l_use_only_agg_mv := 'Y';
      for i in 1..l_in_join_tbl.count loop
        if(l_in_join_tbl(i).table_alias = 'com' or l_in_join_tbl(i).table_alias = 'cc') then
          if(l_in_join_tbl(i).aggregated_flag = 'N')then
            l_use_only_agg_mv := 'N';
          end if;
        end if;
      end loop;

      if(l_use_only_agg_mv = 'N') then
        poa_dbi_sutil_pkg.process_parameters(
          p_param              => p_param,
          p_view_by            => l_view_by,
          p_view_by_col_name   => l_view_by_col,
          p_view_by_value      => l_view_by_value,
          p_comparison_type    => l_comparison_type,
          p_xtd                => l_xtd,
          p_as_of_date         => l_as_of_date,
          p_prev_as_of_date    => l_prev_as_of_date,
          p_cur_suffix         => l_cur_suffix,
          p_nested_pattern     => l_nested_pattern,
          p_where_clause       => l_where_clause2,
          p_mv                 => l_mv2,
          p_join_tbl           => l_join_tbl,
          p_in_join_tbl        => l_in_join_tbl2,
          x_custom_output      => x_custom_output,
          p_trend              => 'N',
          p_func_area          => 'PO',
          p_version            => '8.0',
          p_role               => 'COM',
          p_mv_set             => 'PODCUTB');

        l_mv_tbl := poa_dbi_util_pkg.poa_dbi_mv_tbl();
        l_mv_tbl.extend;
        l_mv_tbl(1).mv_name := l_mv;
        l_mv_tbl(1).mv_col := l_col_tbl;
        l_mv_tbl(1).mv_where := l_where_clause;
        l_mv_tbl(1).in_join_tbls := l_in_join_tbl;
        l_mv_tbl(1).use_grp_id := 'N';

        l_mv_tbl.extend;
        l_mv_tbl(2).mv_name := l_mv2;
        l_mv_tbl(2).mv_col := l_col_tbl;
        l_mv_tbl(2).mv_where := l_where_clause2;
        l_mv_tbl(2).in_join_tbls := l_in_join_tbl2;
        l_mv_tbl(2).use_grp_id := 'N';

        l_query := get_con_rpt_sel_clause(l_view_by, l_view_by_col, l_sec_context) || ' from (
              ' ||poa_dbi_template_pkg.union_all_status_sql(
                    p_mv              => l_mv_tbl,
                    p_join_tables     => l_join_tbl,
                    p_use_windowing   => 'Y',
                    p_paren_count     => 3,
                    p_filter_where    => get_con_rpt_filter_where(l_view_by),
                    p_generate_viewby => 'Y',
                    p_diff_measures   => 'N');

      else
        l_query := get_con_rpt_sel_clause(l_view_by, l_view_by_col, l_sec_context) || ' from
              ' ||poa_dbi_template_pkg.status_sql(
                    p_fact_name      => l_mv,
                    p_where_clause   => l_where_clause,
                    p_join_tables    => l_join_tbl,
                    p_use_windowing  => 'Y',
                    p_col_name       => l_col_tbl,
                    p_use_grpid      => 'N',
                    p_filter_where   => get_con_rpt_filter_where(l_view_by),
                    p_in_join_tables => l_in_join_tbl);

      end if; /* l_use_only_agg_mv = 'N' */
    end if; /*l_sec_context = 'OU' or l_sec_context = 'OU/COM' */
    x_custom_sql := l_query;
  end;


  FUNCTION get_con_rpt_filter_where(p_view_by in VARCHAR2) return VARCHAR2
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
    l_col_tbl(4) := 'POA_MEASURE3';
   if(p_view_by= 'ITEM+POA_ITEMS') then
     l_col_tbl.extend;
     l_col_tbl(5) := 'POA_MEASURE12';
   end if;

    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

  END;


  FUNCTION get_con_rpt_sel_clause(
             p_view_by_dim in VARCHAR2,
             p_view_by_col in VARCHAR2,
             p_sec_context in VARCHAR2) return VARCHAR2
  IS
    l_sel_clause varchar2(8000);
  BEGIN
    l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim, 'PO', '6.0');

    if(p_view_by_dim = 'ITEM+POA_ITEMS') then
      l_sel_clause := l_sel_clause || ' v.description POA_ATTRIBUTE1,
        v2.description POA_ATTRIBUTE2, oset.POA_MEASURE12 POA_MEASURE12, ';
    else
      l_sel_clause := l_sel_clause || '
      null POA_MEASURE12,
      null POA_ATTRIBUTE1,
      null POA_ATTRIBUTE2, ';
    end if;

    l_sel_clause := l_sel_clause || '
      oset.POA_MEASURE1 POA_MEASURE1,  --PO Purchases Amount
      oset.POA_PERCENT1 POA_PERCENT1,  --Contract Purchases Rate
      oset.POA_MEASURE2 POA_MEASURE2,  --Change for Con Purch Rate
      oset.POA_MEASURE3 POA_MEASURE3,  --Contract Purchases Amount
      oset.POA_MEASURE5 POA_MEASURE5,  --Total PO Purchases Amount
      oset.POA_MEASURE6 POA_MEASURE6,  --Total Contract Purchases Rate
      oset.POA_MEASURE7 POA_MEASURE7,  --Total Change
      oset.POA_MEASURE8 POA_MEASURE8,  --Total Contract Purchases Amount';

    if (p_view_by_dim = 'FII_COMPANIES+FII_COMPANIES' or
        p_view_by_dim = 'ORGANIZATION+HRI_CL_ORGCC') then
      l_sel_clause := l_sel_clause || '
        decode(v.summary_flag,''Y'',''pFunctionName=POA_DBI_CC_CUT_CON_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'',null) POA_ATTRIBUTE4,
        decode(v.summary_flag,''Y'',''pFunctionName=POA_DBI_CC_CUT_CON_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'',null) POA_ATTRIBUTE5,';
    else
      l_sel_clause := l_sel_clause || '
        null POA_ATTRIBUTE4,
        null POA_ATTRIBUTE5,';
    end if;

   if (p_sec_context = 'COMP') then
     l_sel_clause := l_sel_clause ||'
       ''pFunctionName=POA_DBI_CC_CUT_CON_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+POA_ITEMS&pParamIds=Y'' POA_ATTRIBUTE6,
       ''pFunctionName=POA_DBI_CC_CUT_CDT_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=LOOKUP+CONTRACT_DOCTYPE&pParamIds=Y'' POA_ATTRIBUTE7 ';
   else
     l_sel_clause := l_sel_clause ||'
       ''pFunctionName=POA_DBI_CUT_CON_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+POA_ITEMS&pParamIds=Y'' POA_ATTRIBUTE6,
       ''pFunctionName=POA_DBI_CUT_CDT_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=LOOKUP+CONTRACT_DOCTYPE&pParamIds=Y'' POA_ATTRIBUTE7 ';
   end if;

   l_sel_clause := l_sel_clause || '
      from
      (select (rank() over ( &ORDER_BY_CLAUSE nulls last, ' || p_view_by_col;

if(p_view_by_dim = 'ITEM+POA_ITEMS') then
  l_sel_clause := l_sel_clause || ', base_uom';
end if;

l_sel_clause := l_sel_clause || ')) - 1 rnk,'
     || p_view_by_col;

 if(p_view_by_dim = 'ITEM+POA_ITEMS') then
   l_sel_clause := l_sel_clause || ', base_uom, POA_MEASURE12';
 end if;

l_sel_clause := l_sel_clause || ',
    POA_PERCENT1, POA_MEASURE1,
    POA_MEASURE2,
    POA_MEASURE3,
    POA_MEASURE5,
    POA_MEASURE6, POA_MEASURE7,
    POA_MEASURE8
   from
     (select ' || p_view_by_col || ',
             ' || p_view_by_col || ' VIEWBY,';


 if(p_view_by_dim = 'ITEM+POA_ITEMS') then
   l_sel_clause := l_sel_clause || ' base_uom, decode(base_uom,null,to_number(null),nvl(c_quantity,0)) POA_MEASURE12, ';
 end if;

l_sel_clause := l_sel_clause || '
  nvl(c_purchase_amt,0) POA_MEASURE1,
  ' || poa_dbi_util_pkg.rate_clause('c_contract_amt','c_purchase_amt') || ' POA_PERCENT1,
  ' || poa_dbi_util_pkg.change_clause( poa_dbi_util_pkg.rate_clause('c_contract_amt','c_purchase_amt'), poa_dbi_util_pkg.rate_clause('p_contract_amt','p_purchase_amt'),'P') || ' POA_MEASURE2,
  nvl(c_contract_amt,0) POA_MEASURE3,
  nvl(c_purchase_amt_total,0) POA_MEASURE5,
  ' || poa_dbi_util_pkg.rate_clause('c_contract_amt_total','c_purchase_amt_total') || ' POA_MEASURE6,
  ' || poa_dbi_util_pkg.change_clause( poa_dbi_util_pkg.rate_clause('c_contract_amt_total','c_purchase_amt_total'), poa_dbi_util_pkg.rate_clause('p_contract_amt_total','p_purchase_amt_total'),'P') || ' POA_MEASURE7,
  nvl(c_contract_amt_total,0) POA_MEASURE8';
   return l_sel_clause;
  END;


  PROCEDURE ncp_rpt_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
    l_query varchar2(10000);
    l_view_by varchar2(120);
    l_view_by_col varchar2(120);
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
    l_in_join_tbl2 poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
    l_where_clause VARCHAR2(2000);
    l_where_clause2 VARCHAR2(2000);
    l_view_by_value VARCHAR2(100);
    l_mv VARCHAR2(30);
    l_mv2 VARCHAR2(30);
    l_sec_context varchar2(10);
    l_use_only_agg_mv varchar2(1);
    l_mv_tbl poa_dbi_util_pkg.poa_dbi_mv_tbl;
  BEGIN
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();

    l_sec_context := poa_dbi_sutil_pkg.get_sec_context(p_param);
    if (l_sec_context = 'OU' or l_sec_context = 'OU/COM')then
      poa_dbi_sutil_pkg.process_parameters(
        p_param              => p_param,
        p_view_by            => l_view_by,
        p_view_by_col_name   => l_view_by_col,
        p_view_by_value      => l_view_by_value,
        p_comparison_type    => l_comparison_type,
        p_xtd                => l_xtd,
        p_as_of_date         => l_as_of_date,
        p_prev_as_of_date    => l_prev_as_of_date,
        p_cur_suffix         => l_cur_suffix,
        p_nested_pattern     => l_nested_pattern,
        p_where_clause       => l_where_clause,
        p_mv                 => l_mv,
        p_join_tbl           => l_join_tbl,
        p_in_join_tbl        => l_in_join_tbl ,
        x_custom_output      => x_custom_output,
        p_trend              => 'N',
        p_func_area          => 'PO',
        p_version            => '6.0',
        p_role               => 'COM',
        p_mv_set             => 'PODCUT');

      poa_dbi_util_pkg.add_column(l_col_tbl, 'n_contract_amt_' || l_cur_suffix, 'n_contract_amt');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix,'purchase_amt');

      if(l_view_by = 'ITEM+POA_ITEMS') then
        poa_dbi_util_pkg.add_column(l_col_tbl, 'quantity', 'quantity');
      end if;

      l_query := get_ncp_rpt_sel_clause(l_view_by, l_view_by_col, l_sec_context) || ' from
              ' || poa_dbi_template_pkg.status_sql(
                     p_fact_name      => l_mv,
                     p_where_clause   => l_where_clause,
                     p_join_tables    => l_join_tbl,
                     p_use_windowing  => 'Y',
                     p_col_name       => l_col_tbl,
                     p_use_grpid      => 'N',
                     p_filter_where   => get_ncp_rpt_filter_where(l_view_by),
                     p_in_join_tables => l_in_join_tbl);
    elsif(l_sec_context = 'COMP')then
      poa_dbi_sutil_pkg.process_parameters(
        p_param              => p_param,
        p_view_by            => l_view_by,
        p_view_by_col_name   => l_view_by_col,
        p_view_by_value      => l_view_by_value,
        p_comparison_type    => l_comparison_type,
        p_xtd                => l_xtd,
        p_as_of_date         => l_as_of_date,
        p_prev_as_of_date    => l_prev_as_of_date,
        p_cur_suffix         => l_cur_suffix,
        p_nested_pattern     => l_nested_pattern,
        p_where_clause       => l_where_clause,
        p_mv                 => l_mv,
        p_join_tbl           => l_join_tbl,
        p_in_join_tbl        => l_in_join_tbl ,
        x_custom_output      => x_custom_output,
        p_trend              => 'N',
        p_func_area          => 'PO',
        p_version            => '8.0',
        p_role               => 'COM',
        p_mv_set             => 'PODCUTA');

      poa_dbi_util_pkg.add_column(l_col_tbl, 'n_contract_amt_' || l_cur_suffix, 'n_contract_amt');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix,'purchase_amt');

      if(l_view_by = 'ITEM+POA_ITEMS') then
        poa_dbi_util_pkg.add_column(l_col_tbl, 'quantity', 'quantity');
      end if;

      /*check if we can get everything from aggregated mv*/
      l_use_only_agg_mv := 'Y';
      for i in 1..l_in_join_tbl.count loop
        if(l_in_join_tbl(i).table_alias = 'com' or l_in_join_tbl(i).table_alias = 'cc') then
          if(l_in_join_tbl(i).aggregated_flag = 'N')then
            l_use_only_agg_mv := 'N';
          end if;
        end if;
      end loop;

      if(l_use_only_agg_mv = 'N') then
        poa_dbi_sutil_pkg.process_parameters(
          p_param              => p_param,
          p_view_by            => l_view_by,
          p_view_by_col_name   => l_view_by_col,
          p_view_by_value      => l_view_by_value,
          p_comparison_type    => l_comparison_type,
          p_xtd                => l_xtd,
          p_as_of_date         => l_as_of_date,
          p_prev_as_of_date    => l_prev_as_of_date,
          p_cur_suffix         => l_cur_suffix,
          p_nested_pattern     => l_nested_pattern,
          p_where_clause       => l_where_clause2,
          p_mv                 => l_mv2,
          p_join_tbl           => l_join_tbl,
          p_in_join_tbl        => l_in_join_tbl2,
          x_custom_output      => x_custom_output,
          p_trend              => 'N',
          p_func_area          => 'PO',
          p_version            => '8.0',
          p_role               => 'COM',
          p_mv_set             => 'PODCUTB');

        l_mv_tbl := poa_dbi_util_pkg.poa_dbi_mv_tbl();
        l_mv_tbl.extend;
        l_mv_tbl(1).mv_name := l_mv;
        l_mv_tbl(1).mv_col := l_col_tbl;
        l_mv_tbl(1).mv_where := l_where_clause;
        l_mv_tbl(1).in_join_tbls := l_in_join_tbl;
        l_mv_tbl(1).use_grp_id := 'N';

        l_mv_tbl.extend;
        l_mv_tbl(2).mv_name := l_mv2;
        l_mv_tbl(2).mv_col := l_col_tbl;
        l_mv_tbl(2).mv_where := l_where_clause2;
        l_mv_tbl(2).in_join_tbls := l_in_join_tbl2;
        l_mv_tbl(2).use_grp_id := 'N';

        l_query := get_ncp_rpt_sel_clause(l_view_by, l_view_by_col, l_sec_context) || ' from (
              ' || poa_dbi_template_pkg.union_all_status_sql(
                    p_mv              => l_mv_tbl,
                    p_join_tables     => l_join_tbl,
                    p_use_windowing   => 'Y',
                    p_paren_count     => 3,
                    p_filter_where    => get_ncp_rpt_filter_where(l_view_by),
                    p_generate_viewby => 'Y',
                    p_diff_measures   => 'N');
      else
        l_query := get_ncp_rpt_sel_clause(l_view_by, l_view_by_col, l_sec_context) || ' from
              ' || poa_dbi_template_pkg.status_sql(
                     p_fact_name      => l_mv,
                     p_where_clause   => l_where_clause,
                     p_join_tables    => l_join_tbl,
                     p_use_windowing  => 'Y',
                     p_col_name       => l_col_tbl,
                     p_use_grpid      => 'N',
                     p_filter_where   => get_ncp_rpt_filter_where(l_view_by),
                     p_in_join_tables => l_in_join_tbl);

      end if; /* l_use_only_agg_mv = 'N' */
    end if; /* l_sec_context = 'OU' or l_sec_context = 'OU/COM' */
    x_custom_sql := l_query;

  end;


  FUNCTION get_ncp_rpt_filter_where(p_view_by in VARCHAR2) return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_MEASURE1';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_MEASURE2';
    l_col_tbl.extend;
    l_col_tbl(3) := 'POA_PERCENT2';
    l_col_tbl.extend;
    l_col_tbl(4) := 'POA_MEASURE3';

    if(p_view_by= 'ITEM+POA_ITEMS') then
       l_col_tbl.extend;
       l_col_tbl(5) := 'POA_MEASURE12';
   end if;

    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

  END;


  FUNCTION get_ncp_rpt_sel_clause(
             p_view_by_dim in VARCHAR2,
             p_view_by_col in VARCHAR2,
             p_sec_context in VARCHAR2) return VARCHAR2
  IS

  l_sel_clause varchar2(8000);


  BEGIN
  l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim, 'PO', '6.0');

  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
  l_sel_clause := l_sel_clause || ' v.description POA_ATTRIBUTE1,
     v2.description POA_ATTRIBUTE2, oset.POA_MEASURE12 POA_MEASURE12, ';
  else
  l_sel_clause := l_sel_clause || '
  null POA_MEASURE12,
  null POA_ATTRIBUTE1,
  null POA_ATTRIBUTE2, ';
  end if;

  l_sel_clause := l_sel_clause || '
  oset.POA_MEASURE1 POA_MEASURE1,    --PO Purchases Amount
  oset.POA_MEASURE2 POA_MEASURE2,    --Non-Contract Purchases Amount
  oset.POA_PERCENT2 POA_PERCENT2,    --Non-Contract Purchases Rate
  oset.POA_MEASURE3 POA_MEASURE3,    --Change
  oset.POA_MEASURE5 POA_MEASURE5,    --Total PO Purchases Amount
  oset.POA_MEASURE7 POA_MEASURE7,    --Total Non-Contract Purchases Amount
  oset.POA_MEASURE8 POA_MEASURE8,    --Total Non-Contract Purchases Rate
  oset.POA_MEASURE9 POA_MEASURE9,    --Total Change';

  if(p_view_by_dim = 'FII_COMPANIES+FII_COMPANIES' or p_view_by_dim = 'ORGANIZATION+HRI_CL_ORGCC') then
    l_sel_clause := l_sel_clause || fnd_global.newline ||'
        decode(v.summary_flag,''Y'',''pFunctionName=POA_DBI_CC_CUT_NCP_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'',null) POA_ATTRIBUTE4,
        decode(v.summary_flag,''Y'',''pFunctionName=POA_DBI_CC_CUT_NCP_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'',null) POA_ATTRIBUTE5,';
  else
    l_sel_clause := l_sel_clause || fnd_global.newline ||
      'null POA_ATTRIBUTE4,'||fnd_global.newline||
      'null POA_ATTRIBUTE5,'||fnd_global.newline;
  end if;

  if (p_sec_context = 'COMP') then
    l_sel_clause := l_sel_clause ||'
      ''pFunctionName=POA_DBI_CC_CUT_NCP_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+POA_ITEMS&pParamIds=Y'' POA_ATTRIBUTE6,
      ''pFunctionName=POA_DBI_CC_CUD_NCP_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'' POA_ATTRIBUTE7 ';
  else
    l_sel_clause := l_sel_clause ||'
      ''pFunctionName=POA_DBI_CUT_NCP_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+POA_ITEMS&pParamIds=Y'' POA_ATTRIBUTE6,
      ''pFunctionName=POA_DBI_CUD_NCP_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'' POA_ATTRIBUTE7 ';
  end if;

  l_sel_clause := l_sel_clause || fnd_global.newline || 'from
    (select (rank() over
        ( &ORDER_BY_CLAUSE nulls last, ' || p_view_by_col;

if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ', base_uom';
end if;

l_sel_clause := l_sel_clause || ')) - 1 rnk,'
        || p_view_by_col;

 if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ', base_uom, POA_MEASURE12';
 end if;

l_sel_clause := l_sel_clause || ',
    POA_MEASURE1,
    POA_PERCENT2, POA_MEASURE2,
    POA_MEASURE3,
    POA_MEASURE5,
    POA_MEASURE7,
    POA_MEASURE8, POA_MEASURE9
   from
     (select ' || p_view_by_col || ',
             ' || p_view_by_col || ' VIEWBY,';


 if(p_view_by_dim = 'ITEM+POA_ITEMS') then
   l_sel_clause := l_sel_clause || ' base_uom, decode(base_uom,null,to_number(null),nvl(c_quantity,0)) POA_MEASURE12, ';
 end if;

l_sel_clause := l_sel_clause || '
    nvl(c_purchase_amt,0) POA_MEASURE1,
    nvl(c_n_contract_amt,0) POA_MEASURE2,    ' ||
    poa_dbi_util_pkg.rate_clause('c_n_contract_amt', 'c_purchase_amt')
                                || ' POA_PERCENT2,
     ' ||
    poa_dbi_util_pkg.rate_clause('c_n_contract_amt', 'c_purchase_amt') || ' - ' ||
        poa_dbi_util_pkg.rate_clause('p_n_contract_amt', 'p_purchase_amt')
                                || ' POA_MEASURE3,
    nvl(c_purchase_amt_total,0) POA_MEASURE5,
    nvl(c_n_contract_amt_total,0) POA_MEASURE7,    ' ||
    poa_dbi_util_pkg.rate_clause('c_n_contract_amt_total', 'c_purchase_amt_total')
                                || ' POA_MEASURE8,
    ' ||

    poa_dbi_util_pkg.rate_clause('c_n_contract_amt_total', 'c_purchase_amt_total')
        || ' - ' ||
        poa_dbi_util_pkg.rate_clause('p_n_contract_amt_total',
                    'p_purchase_amt_total') ||
                                ' POA_MEASURE9
    ';

     return l_sel_clause;
  END;

  PROCEDURE pcl_rpt_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
    l_query varchar2(10000);
    l_view_by varchar2(120);
    l_view_by_col varchar2(120);
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
    l_in_join_tbl2 poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
    l_where_clause VARCHAR2(2000);
    l_where_clause2 VARCHAR2(2000);
    l_mv VARCHAR2(30);
    l_mv2 VARCHAR2(30);
    l_view_by_value VARCHAR2(100);
    l_sec_context varchar2(10);
    l_use_only_agg_mv varchar2(1);
    l_mv_tbl poa_dbi_util_pkg.poa_dbi_mv_tbl;
  BEGIN
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();

    l_sec_context := poa_dbi_sutil_pkg.get_sec_context(p_param);
    if (l_sec_context = 'OU' or l_sec_context = 'OU/COM')then
      poa_dbi_sutil_pkg.process_parameters(
        p_param              => p_param,
        p_view_by            => l_view_by,
        p_view_by_col_name   => l_view_by_col,
        p_view_by_value      => l_view_by_value,
        p_comparison_type    => l_comparison_type,
        p_xtd                => l_xtd,
        p_as_of_date         => l_as_of_date,
        p_prev_as_of_date    => l_prev_as_of_date,
        p_cur_suffix         => l_cur_suffix,
        p_nested_pattern     => l_nested_pattern,
        p_where_clause       => l_where_clause,
        p_mv                 => l_mv,
        p_join_tbl           => l_join_tbl,
        p_in_join_tbl        => l_in_join_tbl ,
        x_custom_output      => x_custom_output,
        p_trend              => 'N',
        p_func_area          => 'PO',
        p_version            => '6.0',
        p_role               => 'COM',
        p_mv_set             => 'PODCUT');

      poa_dbi_util_pkg.add_column(l_col_tbl, 'p_contract_amt_' || l_cur_suffix, 'p_contract_amt');  poa_dbi_util_pkg.add_column(l_col_tbl, 'above_contract_amt_' || l_cur_suffix,
          'above_contract_amt');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'below_contract_amt_' || l_cur_suffix,
          'below_contract_amt');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix, 'purchase_amt');

      if(l_view_by = 'ITEM+POA_ITEMS') then
        poa_dbi_util_pkg.add_column(l_col_tbl, 'quantity', 'quantity');
      end if;

      l_query := get_pcl_rpt_sel_clause(l_view_by, l_view_by_col, l_sec_context) || ' from
              ' || poa_dbi_template_pkg.status_sql(
                     p_fact_name      => l_mv,
                     p_where_clause   => l_where_clause,
                     p_join_tables    => l_join_tbl,
                     p_use_windowing  => 'Y',
                     p_col_name       => l_col_tbl,
                     p_use_grpid      => 'N',
                     p_filter_where   => get_pcl_rpt_filter_where(l_view_by),
                     p_in_join_tables => l_in_join_tbl);

    elsif(l_sec_context = 'COMP')then
      poa_dbi_sutil_pkg.process_parameters(
        p_param              => p_param,
        p_view_by            => l_view_by,
        p_view_by_col_name   => l_view_by_col,
        p_view_by_value      => l_view_by_value,
        p_comparison_type    => l_comparison_type,
        p_xtd                => l_xtd,
        p_as_of_date         => l_as_of_date,
        p_prev_as_of_date    => l_prev_as_of_date,
        p_cur_suffix         => l_cur_suffix,
        p_nested_pattern     => l_nested_pattern,
        p_where_clause       => l_where_clause,
        p_mv                 => l_mv,
        p_join_tbl           => l_join_tbl,
        p_in_join_tbl        => l_in_join_tbl,
        x_custom_output      => x_custom_output,
        p_trend              => 'N',
        p_func_area          => 'PO',
        p_version            => '8.0',
        p_role               => 'COM',
        p_mv_set             => 'PODCUTA');

      poa_dbi_util_pkg.add_column(l_col_tbl, 'p_contract_amt_' || l_cur_suffix, 'p_contract_amt');  poa_dbi_util_pkg.add_column(l_col_tbl, 'above_contract_amt_' || l_cur_suffix,
          'above_contract_amt');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'below_contract_amt_' || l_cur_suffix,
          'below_contract_amt');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix, 'purchase_amt');

      if(l_view_by = 'ITEM+POA_ITEMS') then
        poa_dbi_util_pkg.add_column(l_col_tbl, 'quantity', 'quantity');
      end if;

      /*check if we can get everything from aggregated mv*/
      l_use_only_agg_mv := 'Y';
      for i in 1..l_in_join_tbl.count loop
        if(l_in_join_tbl(i).table_alias = 'com' or l_in_join_tbl(i).table_alias = 'cc') then
          if(l_in_join_tbl(i).aggregated_flag = 'N')then
            l_use_only_agg_mv := 'N';
          end if;
        end if;
      end loop;

      if(l_use_only_agg_mv = 'N') then
        poa_dbi_sutil_pkg.process_parameters(
          p_param              => p_param,
          p_view_by            => l_view_by,
          p_view_by_col_name   => l_view_by_col,
          p_view_by_value      => l_view_by_value,
          p_comparison_type    => l_comparison_type,
          p_xtd                => l_xtd,
          p_as_of_date         => l_as_of_date,
          p_prev_as_of_date    => l_prev_as_of_date,
          p_cur_suffix         => l_cur_suffix,
          p_nested_pattern     => l_nested_pattern,
          p_where_clause       => l_where_clause2,
          p_mv                 => l_mv2,
          p_join_tbl           => l_join_tbl,
          p_in_join_tbl        => l_in_join_tbl2,
          x_custom_output      => x_custom_output,
          p_trend              => 'N',
          p_func_area          => 'PO',
          p_version            => '8.0',
          p_role               => 'COM',
          p_mv_set             => 'PODCUTB');

        l_mv_tbl := poa_dbi_util_pkg.poa_dbi_mv_tbl();
        l_mv_tbl.extend;
        l_mv_tbl(1).mv_name := l_mv;
        l_mv_tbl(1).mv_col := l_col_tbl;
        l_mv_tbl(1).mv_where := l_where_clause;
        l_mv_tbl(1).in_join_tbls := l_in_join_tbl;
        l_mv_tbl(1).use_grp_id := 'N';

        l_mv_tbl.extend;
        l_mv_tbl(2).mv_name := l_mv2;
        l_mv_tbl(2).mv_col := l_col_tbl;
        l_mv_tbl(2).mv_where := l_where_clause2;
        l_mv_tbl(2).in_join_tbls := l_in_join_tbl2;
        l_mv_tbl(2).use_grp_id := 'N';

        l_query := get_pcl_rpt_sel_clause(l_view_by, l_view_by_col, l_sec_context) || ' from (
              ' || poa_dbi_template_pkg.union_all_status_sql(
                    p_mv              => l_mv_tbl,
                    p_join_tables     => l_join_tbl,
                    p_use_windowing   => 'Y',
                    p_paren_count     => 3,
                    p_filter_where    => get_pcl_rpt_filter_where(l_view_by),
                    p_generate_viewby => 'Y',
                    p_diff_measures   => 'N');
      else
        l_query := get_pcl_rpt_sel_clause(l_view_by, l_view_by_col, l_sec_context) || ' from
              ' || poa_dbi_template_pkg.status_sql(
                     p_fact_name      => l_mv,
                     p_where_clause   => l_where_clause,
                     p_join_tables    => l_join_tbl,
                     p_use_windowing  => 'Y',
                     p_col_name       => l_col_tbl,
                     p_use_grpid      => 'N',
                     p_filter_where   => get_pcl_rpt_filter_where(l_view_by),
                     p_in_join_tables => l_in_join_tbl);
      end if; /* l_use_only_agg_mv = 'N' */
    end if; /* l_sec_context = 'OU' or l_sec_context = 'OU/COM' */
    x_custom_sql := l_query;
  end;


  FUNCTION get_pcl_rpt_filter_where(p_view_by in VARCHAR2) return VARCHAR2
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
    l_col_tbl.extend;
    l_col_tbl(4) := 'POA_PERCENT3';
    l_col_tbl.extend;
    l_col_tbl(5) := 'POA_MEASURE4';
    l_col_tbl.extend;
    l_col_tbl(6) := 'POA_MEASURE6';
    l_col_tbl.extend;
    l_col_tbl(7) := 'POA_MEASURE13';

   if(p_view_by= 'ITEM+POA_ITEMS') then
    l_col_tbl.extend;
    l_col_tbl(8) := 'POA_MEASURE12';
   end if;
    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

  END;


  FUNCTION get_pcl_rpt_sel_clause(
             p_view_by_dim in VARCHAR2,
             p_view_by_col in VARCHAR2,
             p_sec_context in VARCHAR2) return VARCHAR2
  IS
    l_sel_clause varchar2(8000);
  BEGIN
    l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim, 'PO', '6.0');

    if(p_view_by_dim = 'ITEM+POA_ITEMS') then
      l_sel_clause := l_sel_clause || ' v.description POA_ATTRIBUTE1,
           v2.description POA_ATTRIBUTE2, oset.POA_MEASURE12 POA_MEASURE12, ';
    else
      l_sel_clause := l_sel_clause || '
      null POA_MEASURE12,
      null POA_ATTRIBUTE1,
      null POA_ATTRIBUTE2, ';
    end if;

    l_sel_clause := l_sel_clause || '
      oset.POA_MEASURE1 POA_MEASURE1,   --PO Purchases Amount
      oset.POA_MEASURE2 POA_MEASURE2,   --Leakage Impact Amount
      oset.POA_MEASURE3 POA_MEASURE3,   --Below Contract Amount
      oset.POA_PERCENT3 POA_PERCENT3,   --Contract Leakage Rate
      oset.POA_MEASURE4 POA_MEASURE4,   --Change
      oset.POA_MEASURE5 POA_MEASURE5,   --PO Purchases Amount Total
      oset.POA_MEASURE6 POA_MEASURE6,   --Above Contract Amount
      oset.POA_MEASURE7 POA_MEASURE7,   --Leakage Impact Amount Total
      oset.POA_MEASURE8 POA_MEASURE8,   --Below Contract Amount Total
      oset.POA_MEASURE9 POA_MEASURE9,   --Above Contract Amount Total
      oset.POA_MEASURE10 POA_MEASURE10, --Contract Leakage Rate Total
      oset.POA_MEASURE11 POA_MEASURE11, --Change Total
      oset.POA_MEASURE13 POA_MEASURE13, --Contract Leakage Amount
      oset.POA_MEASURE14 POA_MEASURE14, --Contract Leakage Amount Total';

    if (p_view_by_dim = 'FII_COMPANIES+FII_COMPANIES' or
        p_view_by_dim = 'ORGANIZATION+HRI_CL_ORGCC') then
      l_sel_clause := l_sel_clause || '
        decode(v.summary_flag,''Y'',''pFunctionName=POA_DBI_CC_CUT_PCL_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'',null) POA_ATTRIBUTE4,
        decode(v.summary_flag,''Y'',''pFunctionName=POA_DBI_CC_CUT_PCL_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'',null) POA_ATTRIBUTE5,';
    else
      l_sel_clause := l_sel_clause || '
        null POA_ATTRIBUTE4,
        null POA_ATTRIBUTE5,';
    end if;

   if (p_sec_context = 'COMP') then
     l_sel_clause := l_sel_clause ||'
       ''pFunctionName=POA_DBI_CC_CUT_PCL_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+POA_ITEMS&pParamIds=Y'' POA_ATTRIBUTE6,
       ''pFunctionName=POA_DBI_CC_CUD_PCL_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'' POA_ATTRIBUTE7 ';
   else
     l_sel_clause := l_sel_clause ||'
       ''pFunctionName=POA_DBI_CUT_PCL_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+POA_ITEMS&pParamIds=Y'' POA_ATTRIBUTE6,
       ''pFunctionName=POA_DBI_CUD_PCL_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'' POA_ATTRIBUTE7 ';
   end if;

    l_sel_clause := l_sel_clause || '
      from
      (select (rank() over ( &ORDER_BY_CLAUSE nulls last, ' || p_view_by_col;

    if(p_view_by_dim = 'ITEM+POA_ITEMS') then
      l_sel_clause := l_sel_clause || ', base_uom';
    end if;

    l_sel_clause := l_sel_clause || ')) - 1 rnk,' || p_view_by_col;

    if(p_view_by_dim = 'ITEM+POA_ITEMS') then
       l_sel_clause := l_sel_clause || ', base_uom, POA_MEASURE12';
    end if;

    l_sel_clause := l_sel_clause || ',
        POA_MEASURE1,
        POA_MEASURE2,
        POA_PERCENT3, POA_MEASURE3,
        POA_MEASURE4, POA_MEASURE5,
        POA_MEASURE6, POA_MEASURE7,
        POA_MEASURE8, POA_MEASURE9,
        POA_MEASURE10, POA_MEASURE11,
        POA_MEASURE13, POA_MEASURE14
     from
     (select ' || p_view_by_col || ',
             ' || p_view_by_col || ' VIEWBY,';

    if(p_view_by_dim = 'ITEM+POA_ITEMS') then
      l_sel_clause := l_sel_clause || ' base_uom, decode(base_uom,null,to_number(null),nvl(c_quantity,0)) POA_MEASURE12, ';
    end if;

    l_sel_clause := l_sel_clause || '
    nvl(c_purchase_amt,0) POA_MEASURE1,
    nvl(c_above_contract_amt, 0) + nvl(c_below_contract_amt, 0) POA_MEASURE2,
    nvl(c_below_contract_amt,0) POA_MEASURE3,
    ' || poa_dbi_util_pkg.rate_clause('c_p_contract_amt','c_purchase_amt') || ' POA_PERCENT3,
    ' || poa_dbi_util_pkg.change_clause(poa_dbi_util_pkg.rate_clause('c_p_contract_amt','c_purchase_amt'),poa_dbi_util_pkg.rate_clause('p_p_contract_amt','p_purchase_amt'),'P') || ' POA_MEASURE4,
    nvl(c_purchase_amt_total,0) POA_MEASURE5,
    nvl(c_above_contract_amt,0) POA_MEASURE6,
    nvl(c_above_contract_amt_total,0) + nvl(c_below_contract_amt_total,0) POA_MEASURE7,
    nvl(c_below_contract_amt_total,0) POA_MEASURE8,
    nvl(c_above_contract_amt_total,0) POA_MEASURE9,
    ' || poa_dbi_util_pkg.rate_clause('c_p_contract_amt_total','c_purchase_amt_total') || ' POA_MEASURE10,
    ' || poa_dbi_util_pkg.change_clause(poa_dbi_util_pkg.rate_clause('c_p_contract_amt_total','c_purchase_amt_total'),poa_dbi_util_pkg.rate_clause('p_p_contract_amt_total','p_purchase_amt_total'),'P') || ' POA_MEASURE11,
    nvl(c_p_contract_amt,0) POA_MEASURE13,
    nvl(c_p_contract_amt_total,0) POA_MEASURE14';
    return l_sel_clause;
  END;


  PROCEDURE pop_trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
    l_query varchar2(10000);
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
    l_in_join_tbl2 poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
    l_mv VARCHAR2(30);
    l_mv2 VARCHAR2(30);
    l_where_clause VARCHAR2(2000);
    l_where_clause2 VARCHAR2(2000);
    l_view_by_value VARCHAR2(100);
    l_sec_context varchar2(10);
    l_use_only_agg_mv varchar2(1);
    l_mv_tbl poa_dbi_util_pkg.poa_dbi_mv_tbl;
  BEGIN
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();

    l_sec_context := poa_dbi_sutil_pkg.get_sec_context(p_param);
    if (l_sec_context = 'OU' or l_sec_context = 'OU/COM')then
      poa_dbi_sutil_pkg.process_parameters(
        p_param              => p_param,
        p_view_by            => l_view_by,
        p_view_by_col_name   => l_view_by_col,
        p_view_by_value      => l_view_by_value,
        p_comparison_type    => l_comparison_type,
        p_xtd                => l_xtd,
        p_as_of_date         => l_as_of_date,
        p_prev_as_of_date    => l_prev_as_of_date,
        p_cur_suffix         => l_cur_suffix,
        p_nested_pattern     => l_nested_pattern,
        p_where_clause       => l_where_clause,
        p_mv                 => l_mv,
        p_join_tbl           => l_join_tbl,
        p_in_join_tbl        => l_in_join_tbl,
        x_custom_output      => x_custom_output,
        p_trend              => 'Y',
        p_func_area          => 'PO',
        p_version            => '6.0',
        p_role               => 'COM',
        p_mv_set             => 'PODCUT');

      poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix, 'purchase_amt', 'N');

      l_query := get_pop_trend_sel_clause || ' from
             '|| poa_dbi_template_pkg.trend_sql(
                   p_xtd             => l_xtd,
                   p_comparison_type => l_comparison_type,
                   p_fact_name       => l_mv,
                   p_where_clause    => l_where_clause,
                   p_col_name        => l_col_tbl,
                   p_use_grpid       => 'N',
                   p_in_join_tables  => l_in_join_tbl);

    elsif(l_sec_context = 'COMP')then
      poa_dbi_sutil_pkg.process_parameters(
        p_param              => p_param,
        p_view_by            => l_view_by,
        p_view_by_col_name   => l_view_by_col,
        p_view_by_value      => l_view_by_value,
        p_comparison_type    => l_comparison_type,
        p_xtd                => l_xtd,
        p_as_of_date         => l_as_of_date,
        p_prev_as_of_date    => l_prev_as_of_date,
        p_cur_suffix         => l_cur_suffix,
        p_nested_pattern     => l_nested_pattern,
        p_where_clause       => l_where_clause,
        p_mv                 => l_mv,
        p_join_tbl           => l_join_tbl,
        p_in_join_tbl        => l_in_join_tbl,
        x_custom_output      => x_custom_output,
        p_trend              => 'Y',
        p_func_area          => 'PO',
        p_version            => '8.0',
        p_role               => 'COM',
        p_mv_set             => 'PODCUTA');

      poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix, 'purchase_amt', 'N');

      /*check if we can get everything from aggregated mv*/
      l_use_only_agg_mv := 'Y';
      for i in 1..l_in_join_tbl.count loop
        if(l_in_join_tbl(i).table_alias = 'com' or l_in_join_tbl(i).table_alias = 'cc') then
          if(l_in_join_tbl(i).aggregated_flag = 'N')then
            l_use_only_agg_mv := 'N';
          end if;
        end if;
      end loop;

      if(l_use_only_agg_mv = 'N') then
        poa_dbi_sutil_pkg.process_parameters(
          p_param              => p_param,
          p_view_by            => l_view_by,
          p_view_by_col_name   => l_view_by_col,
          p_view_by_value      => l_view_by_value,
          p_comparison_type    => l_comparison_type,
          p_xtd                => l_xtd,
          p_as_of_date         => l_as_of_date,
          p_prev_as_of_date    => l_prev_as_of_date,
          p_cur_suffix         => l_cur_suffix,
          p_nested_pattern     => l_nested_pattern,
          p_where_clause       => l_where_clause2,
          p_mv                 => l_mv2,
          p_join_tbl           => l_join_tbl,
          p_in_join_tbl        => l_in_join_tbl2,
          x_custom_output      => x_custom_output,
          p_trend              => 'Y',
          p_func_area          => 'PO',
          p_version            => '8.0',
          p_role               => 'COM',
          p_mv_set             => 'PODCUTB');

        l_mv_tbl := poa_dbi_util_pkg.poa_dbi_mv_tbl();
        l_mv_tbl.extend;
        l_mv_tbl(1).mv_name := l_mv;
        l_mv_tbl(1).mv_col := l_col_tbl;
        l_mv_tbl(1).mv_where := l_where_clause;
        l_mv_tbl(1).in_join_tbls := l_in_join_tbl;
        l_mv_tbl(1).use_grp_id := 'N';
        l_mv_tbl(1).mv_xtd := l_xtd;

        l_mv_tbl.extend;
        l_mv_tbl(2).mv_name := l_mv2;
        l_mv_tbl(2).mv_col := l_col_tbl;
        l_mv_tbl(2).mv_where := l_where_clause2;
        l_mv_tbl(2).in_join_tbls := l_in_join_tbl2;
        l_mv_tbl(2).use_grp_id := 'N';
        l_mv_tbl(2).mv_xtd := l_xtd;

        l_query := get_pop_trend_sel_clause('union') || ' from
             '|| poa_dbi_template_pkg.union_all_trend_sql(
                p_mv               => l_mv_tbl
                ,p_comparison_type =>  l_comparison_type
                ,p_diff_measures   =>  'N');

      else
        l_query := get_pop_trend_sel_clause || ' from
             '|| poa_dbi_template_pkg.trend_sql(
                   p_xtd             => l_xtd,
                   p_comparison_type => l_comparison_type,
                   p_fact_name       => l_mv,
                   p_where_clause    => l_where_clause,
                   p_col_name        => l_col_tbl,
                   p_use_grpid       => 'N',
                   p_in_join_tables  => l_in_join_tbl);
      end if; /* l_use_only_agg_mv = 'N' */
    end if; /* l_sec_context = 'OU' or l_sec_context = 'OU/COM' */
    x_custom_sql := l_query;
  end;


  function get_pop_trend_sel_clause(p_type in varchar2 := 'trend' ) return varchar2
  is
    l_sel_clause varchar2(4000);
  begin
    if (p_type = 'trend') then
      l_sel_clause := 'select cal.name VIEWBY,'||fnd_global.newline;
    else
      l_sel_clause := 'select cal_name VIEWBY,'||fnd_global.newline;
    end if;
    l_sel_clause := l_sel_clause ||
       'nvl(c_purchase_amt,0) POA_MEASURE1,
    p_purchase_amt POA_MEASURE2,
    ' || poa_dbi_util_pkg.change_clause('c_purchase_amt','p_purchase_amt') || ' POA_PERCENT1';

    return l_sel_clause;
  end;

  PROCEDURE trend_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
    l_query varchar2(10000);
    l_view_by varchar2(120);
    l_view_by_col varchar2(120);
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
    l_in_join_tbl2 poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
    l_mv VARCHAR2(30);
    l_mv2 VARCHAR2(30);
    l_where_clause VARCHAR2(2000);
    l_where_clause2 VARCHAR2(2000);
    l_view_by_value VARCHAR2(100);
    l_sec_context varchar2(10);
    l_use_only_agg_mv varchar2(1);
    l_mv_tbl poa_dbi_util_pkg.poa_dbi_mv_tbl;
  BEGIN
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();

    l_sec_context := poa_dbi_sutil_pkg.get_sec_context(p_param);
    if (l_sec_context = 'OU' or l_sec_context = 'OU/COM')then
      poa_dbi_sutil_pkg.process_parameters(
        p_param              => p_param,
        p_view_by            => l_view_by,
        p_view_by_col_name   => l_view_by_col,
        p_view_by_value      => l_view_by_value,
        p_comparison_type    => l_comparison_type,
        p_xtd                => l_xtd,
        p_as_of_date         => l_as_of_date,
        p_prev_as_of_date    => l_prev_as_of_date,
        p_cur_suffix         => l_cur_suffix,
        p_nested_pattern     => l_nested_pattern,
        p_where_clause       => l_where_clause,
        p_mv                 => l_mv,
        p_join_tbl           => l_join_tbl,
        p_in_join_tbl        => l_in_join_tbl,
        x_custom_output      => x_custom_output,
        p_trend              => 'Y',
        p_func_area          => 'PO',
        p_version            => '6.0',
        p_role               => 'COM',
        p_mv_set             => 'PODCUT');

      poa_dbi_util_pkg.add_column(l_col_tbl, 'n_contract_amt_' || l_cur_suffix, 'n_contract_amt', 'N');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'contract_amt_' || l_cur_suffix, 'contract_amt', 'N');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix, 'purchase_amt', 'N');

      l_query := get_trend_sel_clause || ' from
             '|| poa_dbi_template_pkg.trend_sql(
                   p_xtd             => l_xtd,
                   p_comparison_type => l_comparison_type,
                   p_fact_name       => l_mv,
                   p_where_clause    => l_where_clause,
                   p_col_name        => l_col_tbl,
                   p_use_grpid       => 'N',
                   p_in_join_tables  => l_in_join_tbl);

    elsif(l_sec_context = 'COMP')then
      poa_dbi_sutil_pkg.process_parameters(
        p_param              => p_param,
        p_view_by            => l_view_by,
        p_view_by_col_name   => l_view_by_col,
        p_view_by_value      => l_view_by_value,
        p_comparison_type    => l_comparison_type,
        p_xtd                => l_xtd,
        p_as_of_date         => l_as_of_date,
        p_prev_as_of_date    => l_prev_as_of_date,
        p_cur_suffix         => l_cur_suffix,
        p_nested_pattern     => l_nested_pattern,
        p_where_clause       => l_where_clause,
        p_mv                 => l_mv,
        p_join_tbl           => l_join_tbl,
        p_in_join_tbl        => l_in_join_tbl,
        x_custom_output      => x_custom_output,
        p_trend              => 'Y',
        p_func_area          => 'PO',
        p_version            => '8.0',
        p_role               => 'COM',
        p_mv_set             => 'PODCUTA');

      poa_dbi_util_pkg.add_column(l_col_tbl, 'n_contract_amt_' || l_cur_suffix, 'n_contract_amt', 'N');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'contract_amt_' || l_cur_suffix, 'contract_amt', 'N');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'p_contract_amt_' || l_cur_suffix, 'p_contract_amt', 'N');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix, 'purchase_amt', 'N');

      /*check if we can get everything from aggregated mv*/
      l_use_only_agg_mv := 'Y';
      for i in 1..l_in_join_tbl.count loop
        if(l_in_join_tbl(i).table_alias = 'com' or l_in_join_tbl(i).table_alias = 'cc') then
          if(l_in_join_tbl(i).aggregated_flag = 'N')then
            l_use_only_agg_mv := 'N';
          end if;
        end if;
      end loop;

      if(l_use_only_agg_mv = 'N') then
        poa_dbi_sutil_pkg.process_parameters(
          p_param              => p_param,
          p_view_by            => l_view_by,
          p_view_by_col_name   => l_view_by_col,
          p_view_by_value      => l_view_by_value,
          p_comparison_type    => l_comparison_type,
          p_xtd                => l_xtd,
          p_as_of_date         => l_as_of_date,
          p_prev_as_of_date    => l_prev_as_of_date,
          p_cur_suffix         => l_cur_suffix,
          p_nested_pattern     => l_nested_pattern,
          p_where_clause       => l_where_clause2,
          p_mv                 => l_mv2,
          p_join_tbl           => l_join_tbl,
          p_in_join_tbl        => l_in_join_tbl2,
          x_custom_output      => x_custom_output,
          p_trend              => 'Y',
          p_func_area          => 'PO',
          p_version            => '8.0',
          p_role               => 'COM',
          p_mv_set             => 'PODCUTB');

        l_mv_tbl := poa_dbi_util_pkg.poa_dbi_mv_tbl();
        l_mv_tbl.extend;
        l_mv_tbl(1).mv_name := l_mv;
        l_mv_tbl(1).mv_col := l_col_tbl;
        l_mv_tbl(1).mv_where := l_where_clause;
        l_mv_tbl(1).in_join_tbls := l_in_join_tbl;
        l_mv_tbl(1).use_grp_id := 'N';
        l_mv_tbl(1).mv_xtd := l_xtd;

        l_mv_tbl.extend;
        l_mv_tbl(2).mv_name := l_mv2;
        l_mv_tbl(2).mv_col := l_col_tbl;
        l_mv_tbl(2).mv_where := l_where_clause2;
        l_mv_tbl(2).in_join_tbls := l_in_join_tbl2;
        l_mv_tbl(2).use_grp_id := 'N';
        l_mv_tbl(2).mv_xtd := l_xtd;

        l_query := get_trend_sel_clause('union') || ' from
             '|| poa_dbi_template_pkg.union_all_trend_sql(
                p_mv               => l_mv_tbl,
                p_comparison_type  =>  l_comparison_type,
                p_diff_measures    =>  'N');
      else
        l_query := get_trend_sel_clause || ' from
             '|| poa_dbi_template_pkg.trend_sql(
                   p_xtd             => l_xtd,
                   p_comparison_type => l_comparison_type,
                   p_fact_name       => l_mv,
                   p_where_clause    => l_where_clause,
                   p_col_name        => l_col_tbl,
                   p_use_grpid       => 'N',
                   p_in_join_tables  => l_in_join_tbl);
      end if; /* l_use_only_agg_mv = 'N' */
    end if; /* l_sec_context = 'OU' or l_sec_context = 'OU/COM' */
    x_custom_sql := l_query;
  end;

  FUNCTION get_trend_sel_clause(p_type in varchar2 := 'trend') return VARCHAR2
  IS

  l_sel_clause varchar2(4000);

  BEGIN
  if (p_type = 'trend') then
    l_sel_clause := 'select cal.name VIEWBY,';
  else
    l_sel_clause := 'select cal_name VIEWBY,';
  end if;

  l_sel_clause := l_sel_clause || '
  ' || poa_dbi_util_pkg.rate_clause('c_contract_amt','c_purchase_amt') || ' POA_PERCENT1,
  ' || poa_dbi_util_pkg.change_clause(poa_dbi_util_pkg.rate_clause('c_contract_amt','c_purchase_amt'),poa_dbi_util_pkg.rate_clause('p_contract_amt','p_purchase_amt'),'P') || ' POA_MEASURE2,
  ' || poa_dbi_util_pkg.rate_clause('c_n_contract_amt','c_purchase_amt') || ' POA_PERCENT2,
  ' || poa_dbi_util_pkg.change_clause(poa_dbi_util_pkg.rate_clause('c_n_contract_amt','c_purchase_amt'),poa_dbi_util_pkg.rate_clause('p_n_contract_amt','p_purchase_amt'),'P') || ' POA_MEASURE3,
  null POA_PERCENT3, -- (Obsoleted)Contract Leakage Rate
  null POA_MEASURE4 -- (Obsoleted)Change '||fnd_global.newline;
   return l_sel_clause;
  END;


  PROCEDURE kpi_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
    l_query varchar2(10000);
    l_view_by varchar2(120);
    l_view_by_col varchar2(120);
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
    l_in_join_tbl2 poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
    l_where_clause varchar2(2000);
    l_where_clause2 varchar2(2000);
    l_mv varchar2(30);
    l_mv2 varchar2(30);
    l_org_where varchar2(500);
    l_commodity_where varchar2(500);
    l_view_by_value varchar2(100);
    l_join_rec poa_dbi_util_pkg.POA_DBI_JOIN_REC;
    l_sec_context varchar2(10);
    l_use_only_agg_mv varchar2(1);
    l_mv_tbl poa_dbi_util_pkg.poa_dbi_mv_tbl;
  BEGIN
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();

    l_sec_context := poa_dbi_sutil_pkg.get_sec_context(p_param);
    if (l_sec_context = 'OU' or l_sec_context = 'OU/COM')then
      poa_dbi_sutil_pkg.process_parameters(
        p_param              => p_param,
        p_view_by            => l_view_by,
        p_view_by_col_name   => l_view_by_col,
        p_view_by_value      => l_view_by_value,
        p_comparison_type    => l_comparison_type,
        p_xtd                => l_xtd,
        p_as_of_date         => l_as_of_date,
        p_prev_as_of_date    => l_prev_as_of_date,
        p_cur_suffix         => l_cur_suffix,
        p_nested_pattern     => l_nested_pattern,
        p_where_clause       => l_where_clause,
        p_mv                 => l_mv,
        p_join_tbl           => l_join_tbl,
        p_in_join_tbl        => l_in_join_tbl,
        x_custom_output      => x_custom_output,
        p_trend              => 'N',
        p_func_area          => 'PO',
        p_version            => '6.0',
        p_role               => 'COM',
        p_mv_set             => 'PODCUT');

      poa_dbi_util_pkg.add_column(l_col_tbl, 'n_contract_amt_' || l_cur_suffix, 'n_contract_amt');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'contract_amt_' || l_cur_suffix, 'contract_amt');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'p_contract_amt_' || l_cur_suffix, 'p_contract_amt');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix, 'purchase_amt');

      l_query :=  poa_dbi_sutil_pkg.get_viewby_select_clause(l_view_by, 'PO','6.0');

      l_query := l_query || '
        oset.POA_PERCENT1 POA_PERCENT1,
        oset.POA_PERCENT2 POA_PERCENT2,
        oset.POA_PERCENT3 POA_PERCENT3,
        oset.POA_MEASURE1 POA_MEASURE1,
        oset.POA_MEASURE2 POA_MEASURE2,
        oset.POA_MEASURE3 POA_MEASURE3,
        oset.POA_MEASURE4 POA_MEASURE4,
        oset.POA_MEASURE5 POA_MEASURE5,
        oset.POA_MEASURE6 POA_MEASURE6,
        oset.POA_MEASURE7 POA_MEASURE7,
        oset.POA_MEASURE8 POA_MEASURE8,
        oset.POA_MEASURE9 POA_MEASURE9
        from
     (select * from (select ' || l_view_by_col || ',
      ' || poa_dbi_util_pkg.rate_clause('p_contract_amt','p_purchase_amt') || ' POA_MEASURE1,
      ' || poa_dbi_util_pkg.rate_clause('c_contract_amt','c_purchase_amt') || ' POA_PERCENT1,
      ' || poa_dbi_util_pkg.rate_clause('p_n_contract_amt','p_purchase_amt') || ' POA_MEASURE2,
      ' || poa_dbi_util_pkg.rate_clause('c_n_contract_amt','c_purchase_amt') || ' POA_PERCENT2,
      ' || poa_dbi_util_pkg.rate_clause('p_p_contract_amt','p_purchase_amt') || ' POA_MEASURE3,
      ' || poa_dbi_util_pkg.rate_clause('c_p_contract_amt','c_purchase_amt') || ' POA_PERCENT3,
      ' || poa_dbi_util_pkg.rate_clause('p_contract_amt_total','p_purchase_amt_total') || ' POA_MEASURE4,
      ' || poa_dbi_util_pkg.rate_clause('c_contract_amt_total','c_purchase_amt_total') || ' POA_MEASURE5,
      ' || poa_dbi_util_pkg.rate_clause('p_n_contract_amt_total','p_purchase_amt_total') || ' POA_MEASURE6,
      ' || poa_dbi_util_pkg.rate_clause('c_n_contract_amt_total','c_purchase_amt_total') || ' POA_MEASURE7,
      ' || poa_dbi_util_pkg.rate_clause('p_p_contract_amt_total','p_purchase_amt_total') || ' POA_MEASURE8,
      ' || poa_dbi_util_pkg.rate_clause('c_p_contract_amt_total','c_purchase_amt_total') || ' POA_MEASURE9
      from
      ' || poa_dbi_template_pkg.status_sql(
             p_fact_name      => l_mv,
             p_where_clause   => l_where_clause,
             p_join_tables    => l_join_tbl,
             p_use_windowing  => 'N',
             p_col_name       => l_col_tbl,
             p_use_grpid      => 'N',
             p_in_join_tables => l_in_join_tbl);

    elsif(l_sec_context = 'COMP')then
      poa_dbi_sutil_pkg.process_parameters(
        p_param              => p_param,
        p_view_by            => l_view_by,
        p_view_by_col_name   => l_view_by_col,
        p_view_by_value      => l_view_by_value,
        p_comparison_type    => l_comparison_type,
        p_xtd                => l_xtd,
        p_as_of_date         => l_as_of_date,
        p_prev_as_of_date    => l_prev_as_of_date,
        p_cur_suffix         => l_cur_suffix,
        p_nested_pattern     => l_nested_pattern,
        p_where_clause       => l_where_clause,
        p_mv                 => l_mv,
        p_join_tbl           => l_join_tbl,
        p_in_join_tbl        => l_in_join_tbl,
        x_custom_output      => x_custom_output,
        p_trend              => 'N',
        p_func_area          => 'PO',
        p_version            => '8.0',
        p_role               => 'COM',
        p_mv_set             => 'PODCUTA');

      poa_dbi_util_pkg.add_column(l_col_tbl, 'n_contract_amt_' || l_cur_suffix, 'n_contract_amt');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'contract_amt_' || l_cur_suffix, 'contract_amt');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'p_contract_amt_' || l_cur_suffix, 'p_contract_amt');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix, 'purchase_amt');

      /*check if we can get everything from aggregated mv*/
      l_use_only_agg_mv := 'Y';
      for i in 1..l_in_join_tbl.count loop
        if(l_in_join_tbl(i).table_alias = 'com' or l_in_join_tbl(i).table_alias = 'cc') then
          if(l_in_join_tbl(i).aggregated_flag = 'N')then
            l_use_only_agg_mv := 'N';
          end if;
        end if;
      end loop;

      if(l_use_only_agg_mv = 'N') then
        poa_dbi_sutil_pkg.process_parameters(
          p_param              => p_param,
          p_view_by            => l_view_by,
          p_view_by_col_name   => l_view_by_col,
          p_view_by_value      => l_view_by_value,
          p_comparison_type    => l_comparison_type,
          p_xtd                => l_xtd,
          p_as_of_date         => l_as_of_date,
          p_prev_as_of_date    => l_prev_as_of_date,
          p_cur_suffix         => l_cur_suffix,
          p_nested_pattern     => l_nested_pattern,
          p_where_clause       => l_where_clause2,
          p_mv                 => l_mv2,
          p_join_tbl           => l_join_tbl,
          p_in_join_tbl        => l_in_join_tbl2,
          x_custom_output      => x_custom_output,
          p_trend              => 'N',
          p_func_area          => 'PO',
          p_version            => '8.0',
          p_role               => 'COM',
          p_mv_set             => 'PODCUTB');

        l_mv_tbl := poa_dbi_util_pkg.poa_dbi_mv_tbl();
        l_mv_tbl.extend;
        l_mv_tbl(1).mv_name := l_mv;
        l_mv_tbl(1).mv_col := l_col_tbl;
        l_mv_tbl(1).mv_where := l_where_clause;
        l_mv_tbl(1).in_join_tbls := l_in_join_tbl;
        l_mv_tbl(1).use_grp_id := 'N';

        l_mv_tbl.extend;
        l_mv_tbl(2).mv_name := l_mv2;
        l_mv_tbl(2).mv_col := l_col_tbl;
        l_mv_tbl(2).mv_where := l_where_clause2;
        l_mv_tbl(2).in_join_tbls := l_in_join_tbl2;
        l_mv_tbl(2).use_grp_id := 'N';

        l_query :=  poa_dbi_sutil_pkg.get_viewby_select_clause(l_view_by, 'PO','6.0');

        l_query := l_query || '
          oset.POA_PERCENT1 POA_PERCENT1,
          oset.POA_PERCENT2 POA_PERCENT2,
          oset.POA_PERCENT3 POA_PERCENT3,
          oset.POA_MEASURE1 POA_MEASURE1,
          oset.POA_MEASURE2 POA_MEASURE2,
          oset.POA_MEASURE3 POA_MEASURE3,
          oset.POA_MEASURE4 POA_MEASURE4,
          oset.POA_MEASURE5 POA_MEASURE5,
          oset.POA_MEASURE6 POA_MEASURE6,
          oset.POA_MEASURE7 POA_MEASURE7,
          oset.POA_MEASURE8 POA_MEASURE8,
          oset.POA_MEASURE9 POA_MEASURE9
          from
       (select * from (select company_id,
        ' || poa_dbi_util_pkg.rate_clause('p_contract_amt','p_purchase_amt') || ' POA_MEASURE1,
        ' || poa_dbi_util_pkg.rate_clause('c_contract_amt','c_purchase_amt') || ' POA_PERCENT1,
        ' || poa_dbi_util_pkg.rate_clause('p_n_contract_amt','p_purchase_amt') || ' POA_MEASURE2,
        ' || poa_dbi_util_pkg.rate_clause('c_n_contract_amt','c_purchase_amt') || ' POA_PERCENT2,
        ' || poa_dbi_util_pkg.rate_clause('p_p_contract_amt','p_purchase_amt') || ' POA_MEASURE3,
        ' || poa_dbi_util_pkg.rate_clause('c_p_contract_amt','c_purchase_amt') || ' POA_PERCENT3,
        ' || poa_dbi_util_pkg.rate_clause('p_contract_amt_total','p_purchase_amt_total') || ' POA_MEASURE4,
        ' || poa_dbi_util_pkg.rate_clause('c_contract_amt_total','c_purchase_amt_total') || ' POA_MEASURE5,
        ' || poa_dbi_util_pkg.rate_clause('p_n_contract_amt_total','p_purchase_amt_total') || ' POA_MEASURE6,
        ' || poa_dbi_util_pkg.rate_clause('c_n_contract_amt_total','c_purchase_amt_total') || ' POA_MEASURE7,
        ' || poa_dbi_util_pkg.rate_clause('p_p_contract_amt_total','p_purchase_amt_total') || ' POA_MEASURE8,
        ' || poa_dbi_util_pkg.rate_clause('c_p_contract_amt_total','c_purchase_amt_total') || ' POA_MEASURE9
        from (
        ' || poa_dbi_template_pkg.union_all_status_sql(
                    p_mv              => l_mv_tbl,
                    p_join_tables     => l_join_tbl,
                    p_use_windowing   => 'N',
                    p_paren_count     => 3,
                    p_generate_viewby => 'Y',
                    p_diff_measures   => 'N');
      else
        l_query :=  poa_dbi_sutil_pkg.get_viewby_select_clause(l_view_by, 'PO','6.0');

        l_query := l_query || '
          oset.POA_PERCENT1 POA_PERCENT1,
          oset.POA_PERCENT2 POA_PERCENT2,
          oset.POA_PERCENT3 POA_PERCENT3,
          oset.POA_MEASURE1 POA_MEASURE1,
          oset.POA_MEASURE2 POA_MEASURE2,
          oset.POA_MEASURE3 POA_MEASURE3,
          oset.POA_MEASURE4 POA_MEASURE4,
          oset.POA_MEASURE5 POA_MEASURE5,
          oset.POA_MEASURE6 POA_MEASURE6,
          oset.POA_MEASURE7 POA_MEASURE7,
          oset.POA_MEASURE8 POA_MEASURE8,
          oset.POA_MEASURE9 POA_MEASURE9
          from
       (select * from (select company_id,
        ' || poa_dbi_util_pkg.rate_clause('p_contract_amt','p_purchase_amt') || ' POA_MEASURE1,
        ' || poa_dbi_util_pkg.rate_clause('c_contract_amt','c_purchase_amt') || ' POA_PERCENT1,
        ' || poa_dbi_util_pkg.rate_clause('p_n_contract_amt','p_purchase_amt') || ' POA_MEASURE2,
        ' || poa_dbi_util_pkg.rate_clause('c_n_contract_amt','c_purchase_amt') || ' POA_PERCENT2,
        ' || poa_dbi_util_pkg.rate_clause('p_p_contract_amt','p_purchase_amt') || ' POA_MEASURE3,
        ' || poa_dbi_util_pkg.rate_clause('c_p_contract_amt','c_purchase_amt') || ' POA_PERCENT3,
        ' || poa_dbi_util_pkg.rate_clause('p_contract_amt_total','p_purchase_amt_total') || ' POA_MEASURE4,
        ' || poa_dbi_util_pkg.rate_clause('c_contract_amt_total','c_purchase_amt_total') || ' POA_MEASURE5,
        ' || poa_dbi_util_pkg.rate_clause('p_n_contract_amt_total','p_purchase_amt_total') || ' POA_MEASURE6,
        ' || poa_dbi_util_pkg.rate_clause('c_n_contract_amt_total','c_purchase_amt_total') || ' POA_MEASURE7,
        ' || poa_dbi_util_pkg.rate_clause('p_p_contract_amt_total','p_purchase_amt_total') || ' POA_MEASURE8,
        ' || poa_dbi_util_pkg.rate_clause('c_p_contract_amt_total','c_purchase_amt_total') || ' POA_MEASURE9
        from
        ' || poa_dbi_template_pkg.status_sql(
               p_fact_name      => l_mv,
               p_where_clause   => l_where_clause,
               p_join_tables    => l_join_tbl,
               p_use_windowing  => 'N',
               p_col_name       => l_col_tbl,
               p_use_grpid      => 'N',
               p_in_join_tables => l_in_join_tbl);
      end if; /* l_use_only_agg_mv = 'N' */
    end if; /* l_sec_context = 'OU' or l_sec_context = 'OU/COM' */
    x_custom_sql := l_query;
  end;


  PROCEDURE pie_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
    l_query varchar2(10000);
    l_view_by varchar2(120);
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
    l_in_join_tbl2 poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
    l_join_rec poa_dbi_util_pkg.POA_DBI_JOIN_REC;
    l_where_clause VARCHAR2(2000);
    l_where_clause2 VARCHAR2(2000);
    l_mv VARCHAR2(30);
    l_mv2 VARCHAR2(30);
    l_view_by_col VARCHAR2(30);
    l_view_by_value VARCHAR2(100);
    l_in_join_tables VARCHAR2(1000) := '';
    l_in_join_tables2 VARCHAR2(1000) := '';
    l_sec_context varchar2(10);
    l_use_only_agg_mv varchar2(1);
    l_mv_tbl poa_dbi_util_pkg.poa_dbi_mv_tbl;
  BEGIN
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();

    l_sec_context := poa_dbi_sutil_pkg.get_sec_context(p_param);
    if (l_sec_context = 'OU' or l_sec_context = 'OU/COM')then
      poa_dbi_sutil_pkg.process_parameters(
        p_param              => p_param,
        p_view_by            => l_view_by,
        p_view_by_col_name   => l_view_by_col,
        p_view_by_value      => l_view_by_value,
        p_comparison_type    => l_comparison_type,
        p_xtd                => l_xtd,
        p_as_of_date         => l_as_of_date,
        p_prev_as_of_date    => l_prev_as_of_date,
        p_cur_suffix         => l_cur_suffix,
        p_nested_pattern     => l_nested_pattern,
        p_where_clause       => l_where_clause,
        p_mv                 => l_mv,
        p_join_tbl           => l_join_tbl,
        p_in_join_tbl        => l_in_join_tbl,
        x_custom_output      => x_custom_output,
        p_trend              => 'N',
        p_func_area          => 'PO',
        p_version            => '6.0',
        p_role               => 'COM',
        p_mv_set             => 'PODCUT');

      if(l_in_join_tbl is not null) then
        for i in 1 .. l_in_join_tbl.count loop
          l_in_join_tables := l_in_join_tables || ', ' ||  l_in_join_tbl(i).table_name || ' ' || l_in_join_tbl(i).table_alias;
        end loop;
      end if;

      l_query := 'select description VIEWBY,
      nvl(c_con_type_amt_total,0) POA_MEASURE1,
      c_con_type_amt_total/decode(c_purchase_amt_total, 0, null, c_purchase_amt_total)*100 POA_PERCENT1,
      (c_con_type_amt_total/decode(c_purchase_amt_total, 0, null, c_purchase_amt_total) -
      p_con_type_amt_total/decode(p_purchase_amt_total, 0, null, p_purchase_amt_total))*100 POA_MEASURE2,
      nvl(c_purchase_amt_total,0) POA_MEASURE3,
      c_purchase_amt_total/decode(c_purchase_amt_total, 0, null, c_purchase_amt_total)*100 POA_MEASURE4
      from
      ( select lookup_code, description, p_purchase_amt_total, c_purchase_amt_total,
        decode(lookup_code, ''1'', c_contract_amt_total, c_n_contract_amt_total) c_con_type_amt_total,
        decode(lookup_code, ''1'', p_contract_amt_total, p_n_contract_amt_total) p_con_type_amt_total
        from
        ( select fl.lookup_code,
          fl.meaning description,
          c_n_contract_amt_total,
          p_n_contract_amt_total,
          c_contract_amt_total,
          p_contract_amt_total,
          c_purchase_amt_total,
          p_purchase_amt_total
          from
          ( select
            sum(sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE, n_contract_amt_' || l_cur_suffix || ', null))) over () c_n_contract_amt_total,
            sum(sum(decode(cal.report_date,  &BIS_PREVIOUS_ASOF_DATE, n_contract_amt_' || l_cur_suffix || ', null))) over () p_n_contract_amt_total,
            sum(sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE , contract_amt_' || l_cur_suffix || ', null))) over () c_contract_amt_total,
            sum(sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE , contract_amt_' || l_cur_suffix || ', null))) over () p_contract_amt_total,
            sum(sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE, purchase_amt_' || l_cur_suffix || ', null))) over () c_purchase_amt_total,
            sum(sum(decode(cal.report_date,  &BIS_PREVIOUS_ASOF_DATE, purchase_amt_' || l_cur_suffix || ', null))) over () p_purchase_amt_total
            from ' || l_mv ||' fact,
            fii_time_rpt_struct_v cal
            ' || l_in_join_tables || '
            where
            fact.time_id = cal.time_id '
            || l_where_clause ||
           'and cal.report_date in (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE )
            and bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id
          ) oset,
          fnd_lookups fl
          where fl.lookup_type=''POA_CONTRACT_UTILIZATION_TYPES''
          and fl.enabled_flag = ''Y''
        )
      )';
    elsif(l_sec_context = 'COMP')then
      poa_dbi_sutil_pkg.process_parameters(
        p_param              => p_param,
        p_view_by            => l_view_by,
        p_view_by_col_name   => l_view_by_col,
        p_view_by_value      => l_view_by_value,
        p_comparison_type    => l_comparison_type,
        p_xtd                => l_xtd,
        p_as_of_date         => l_as_of_date,
        p_prev_as_of_date    => l_prev_as_of_date,
        p_cur_suffix         => l_cur_suffix,
        p_nested_pattern     => l_nested_pattern,
        p_where_clause       => l_where_clause,
        p_mv                 => l_mv,
        p_join_tbl           => l_join_tbl,
        p_in_join_tbl        => l_in_join_tbl,
        x_custom_output      => x_custom_output,
        p_trend              => 'N',
        p_func_area          => 'PO',
        p_version            => '8.0',
        p_role               => 'COM',
        p_mv_set             => 'PODCUTA');

      if(l_in_join_tbl is not null) then
        for i in 1 .. l_in_join_tbl.count loop
          l_in_join_tables := l_in_join_tables || ', ' ||  l_in_join_tbl(i).table_name || ' ' || l_in_join_tbl(i).table_alias;
        end loop;
      end if;

      /*check if we can get everything from aggregated mv*/
      l_use_only_agg_mv := 'Y';
      for i in 1..l_in_join_tbl.count loop
        if(l_in_join_tbl(i).table_alias = 'com' or l_in_join_tbl(i).table_alias = 'cc') then
          if(l_in_join_tbl(i).aggregated_flag = 'N')then
            l_use_only_agg_mv := 'N';
          end if;
        end if;
      end loop;

      if(l_use_only_agg_mv = 'N') then
        poa_dbi_sutil_pkg.process_parameters(
          p_param              => p_param,
          p_view_by            => l_view_by,
          p_view_by_col_name   => l_view_by_col,
          p_view_by_value      => l_view_by_value,
          p_comparison_type    => l_comparison_type,
          p_xtd                => l_xtd,
          p_as_of_date         => l_as_of_date,
          p_prev_as_of_date    => l_prev_as_of_date,
          p_cur_suffix         => l_cur_suffix,
          p_nested_pattern     => l_nested_pattern,
          p_where_clause       => l_where_clause2,
          p_mv                 => l_mv2,
          p_join_tbl           => l_join_tbl,
          p_in_join_tbl        => l_in_join_tbl2,
          x_custom_output      => x_custom_output,
          p_trend              => 'N',
          p_func_area          => 'PO',
          p_version            => '8.0',
          p_role               => 'COM',
          p_mv_set             => 'PODCUTB');

        if(l_in_join_tbl2 is not null) then
          for i in 1 .. l_in_join_tbl2.count loop
            l_in_join_tables2 := l_in_join_tables2 || ', ' ||  l_in_join_tbl2(i).table_name || ' ' || l_in_join_tbl2(i).table_alias;
          end loop;
        end if;

        l_query := 'select description VIEWBY,
        nvl(c_con_type_amt_total,0) POA_MEASURE1,
        c_con_type_amt_total/decode(c_purchase_amt_total, 0, null, c_purchase_amt_total)*100 POA_PERCENT1,
        (c_con_type_amt_total/decode(c_purchase_amt_total, 0, null, c_purchase_amt_total) -
        p_con_type_amt_total/decode(p_purchase_amt_total, 0, null, p_purchase_amt_total))*100 POA_MEASURE2,
        nvl(c_purchase_amt_total,0) POA_MEASURE3,
        c_purchase_amt_total/decode(c_purchase_amt_total, 0, null, c_purchase_amt_total)*100 POA_MEASURE4
        from
        ( select lookup_code, description, p_purchase_amt_total, c_purchase_amt_total,
          decode(lookup_code, ''1'', c_contract_amt_total, ''2'', c_n_contract_amt_total, c_p_contract_amt_total) c_con_type_amt_total,
          decode(lookup_code, ''1'', p_contract_amt_total,''2'', p_n_contract_amt_total, p_p_contract_amt_total) p_con_type_amt_total
          from
          ( select fl.lookup_code,
            fl.meaning description,
            sum(c_n_contract_amt_total) c_n_contract_amt_total,
            sum(p_n_contract_amt_total) p_n_contract_amt_total,
            sum(c_contract_amt_total) c_contract_amt_total,
            sum(p_contract_amt_total) p_contract_amt_total,
            sum(c_p_contract_amt_total) c_p_contract_amt_total,
            sum(p_p_contract_amt_total) p_p_contract_amt_total,
            sum(c_purchase_amt_total) c_purchase_amt_total,
            sum(p_purchase_amt_total) p_purchase_amt_total
            from
            (
              ( select
                sum(sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE, n_contract_amt_' || l_cur_suffix || ', null))) over () c_n_contract_amt_total,
                sum(sum(decode(cal.report_date,  &BIS_PREVIOUS_ASOF_DATE, n_contract_amt_' || l_cur_suffix || ', null))) over () p_n_contract_amt_total,
                sum(sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE , contract_amt_' || l_cur_suffix || ', null))) over () c_contract_amt_total,
                sum(sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE , contract_amt_' || l_cur_suffix || ', null))) over () p_contract_amt_total,
                sum(sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE , p_contract_amt_' || l_cur_suffix || ', null))) over () c_p_contract_amt_total,
                sum(sum(decode(cal.report_date,  &BIS_PREVIOUS_ASOF_DATE, p_contract_amt_' || l_cur_suffix || ', null))) over () p_p_contract_amt_total,
                sum(sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE, purchase_amt_' || l_cur_suffix || ', null))) over () c_purchase_amt_total,
                sum(sum(decode(cal.report_date,  &BIS_PREVIOUS_ASOF_DATE, purchase_amt_' || l_cur_suffix || ', null))) over () p_purchase_amt_total
                from ' || l_mv ||' fact,
                fii_time_rpt_struct_v cal
                ' || l_in_join_tables || '
                where
                fact.time_id = cal.time_id '
                || l_where_clause ||
               'and cal.report_date in (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE )
                and bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id
              )
              union all
              ( select
                sum(sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE, n_contract_amt_' || l_cur_suffix || ', null))) over () c_n_contract_amt_total,
                sum(sum(decode(cal.report_date,  &BIS_PREVIOUS_ASOF_DATE, n_contract_amt_' || l_cur_suffix || ', null))) over () p_n_contract_amt_total,
                sum(sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE , contract_amt_' || l_cur_suffix || ', null))) over () c_contract_amt_total,
                sum(sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE , contract_amt_' || l_cur_suffix || ', null))) over () p_contract_amt_total,
                sum(sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE , p_contract_amt_' || l_cur_suffix || ', null))) over () c_p_contract_amt_total,
                sum(sum(decode(cal.report_date,  &BIS_PREVIOUS_ASOF_DATE, p_contract_amt_' || l_cur_suffix || ', null))) over () p_p_contract_amt_total,
                sum(sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE, purchase_amt_' || l_cur_suffix || ', null))) over () c_purchase_amt_total,
                sum(sum(decode(cal.report_date,  &BIS_PREVIOUS_ASOF_DATE, purchase_amt_' || l_cur_suffix || ', null))) over () p_purchase_amt_total
                from ' || l_mv2 ||' fact,
                fii_time_rpt_struct_v cal
                ' || l_in_join_tables2 || '
                where
                fact.time_id = cal.time_id '
                || l_where_clause2 ||
               'and cal.report_date in (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE )
                and bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id
              )
            ) oset,
            fnd_lookups fl
            where fl.lookup_type=''POA_CONTRACT_UTILIZATION_TYPES''
            and fl.enabled_flag = ''Y''
            group by fl.lookup_code, fl.meaning
          )
        )';
      else
        l_query := 'select description VIEWBY,
        nvl(c_con_type_amt_total,0) POA_MEASURE1,
        c_con_type_amt_total/decode(c_purchase_amt_total, 0, null, c_purchase_amt_total)*100 POA_PERCENT1,
        (c_con_type_amt_total/decode(c_purchase_amt_total, 0, null, c_purchase_amt_total) -
        p_con_type_amt_total/decode(p_purchase_amt_total, 0, null, p_purchase_amt_total))*100 POA_MEASURE2,
        nvl(c_purchase_amt_total,0) POA_MEASURE3,
        c_purchase_amt_total/decode(c_purchase_amt_total, 0, null, c_purchase_amt_total)*100 POA_MEASURE4
        from
        ( select lookup_code, description, p_purchase_amt_total, c_purchase_amt_total,
          decode(lookup_code, ''1'', c_contract_amt_total, ''2'', c_n_contract_amt_total, c_p_contract_amt_total) c_con_type_amt_total,
          decode(lookup_code, ''1'', p_contract_amt_total,''2'', p_n_contract_amt_total, p_p_contract_amt_total) p_con_type_amt_total
          from
          ( select fl.lookup_code,
            fl.meaning description,
            c_n_contract_amt_total,
            p_n_contract_amt_total,
            c_contract_amt_total,
            p_contract_amt_total,
            c_p_contract_amt_total,
            p_p_contract_amt_total,
            c_purchase_amt_total,
            p_purchase_amt_total
            from
            ( select
              sum(sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE, n_contract_amt_' || l_cur_suffix || ', null))) over () c_n_contract_amt_total,
              sum(sum(decode(cal.report_date,  &BIS_PREVIOUS_ASOF_DATE, n_contract_amt_' || l_cur_suffix || ', null))) over () p_n_contract_amt_total,
              sum(sum(decode(cal.report_date,&BIS_CURRENT_ASOF_DATE , contract_amt_' || l_cur_suffix || ', null))) over () c_contract_amt_total,
              sum(sum(decode(cal.report_date, &BIS_PREVIOUS_ASOF_DATE , contract_amt_' || l_cur_suffix || ', null))) over () p_contract_amt_total,
              sum(sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE , p_contract_amt_' || l_cur_suffix || ', null))) over () c_p_contract_amt_total,
              sum(sum(decode(cal.report_date,  &BIS_PREVIOUS_ASOF_DATE, p_contract_amt_' || l_cur_suffix || ', null))) over () p_p_contract_amt_total,
              sum(sum(decode(cal.report_date, &BIS_CURRENT_ASOF_DATE, purchase_amt_' || l_cur_suffix || ', null))) over () c_purchase_amt_total,
              sum(sum(decode(cal.report_date,  &BIS_PREVIOUS_ASOF_DATE, purchase_amt_' || l_cur_suffix || ', null))) over () p_purchase_amt_total
              from ' || l_mv ||' fact,
              fii_time_rpt_struct_v cal
              ' || l_in_join_tables || '
              where
              fact.time_id = cal.time_id '
              || l_where_clause ||
             'and cal.report_date in (&BIS_CURRENT_ASOF_DATE, &BIS_PREVIOUS_ASOF_DATE )
              and bitand(cal.record_type_id, &BIS_NESTED_PATTERN) = cal.record_type_id
            ) oset,
            fnd_lookups fl
            where fl.lookup_type=''POA_CONTRACT_UTILIZATION_TYPES''
            and fl.enabled_flag = ''Y''
          )
        )';
      end if; /* l_use_only_agg_mv = 'N' */
    end if; /* l_sec_context = 'OU' or l_sec_context = 'OU/COM' */
    x_custom_sql := l_query;
  end;


 FUNCTION get_doctype_filter_where return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'c_purchase_amt_total';
    l_col_tbl.extend;
    l_col_tbl(2) := 'c_purchase_amt';


    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

  END;


  PROCEDURE doctype_sql(p_param in BIS_PMV_PAGE_PARAMETER_TBL,
                      x_custom_sql  OUT NOCOPY VARCHAR2,
                      x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  IS
    l_query varchar2(10000);
    l_view_by varchar2(120);
    l_view_by_col varchar2(120);
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
    l_in_join_tbl2 poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
    l_view_by_value VARCHAR2(100);
    l_where_clause VARCHAR2(2000);
    l_where_clause2 VARCHAR2(2000);
    l_mv VARCHAR2(30);
    l_mv2 VARCHAR2(30);
    l_sec_context varchar2(10);
    l_use_only_agg_mv varchar2(1);
    l_mv_tbl poa_dbi_util_pkg.poa_dbi_mv_tbl;
  BEGIN
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();

    l_sec_context := poa_dbi_sutil_pkg.get_sec_context(p_param);
    if (l_sec_context = 'OU' or l_sec_context = 'OU/COM')then
      poa_dbi_sutil_pkg.process_parameters(
        p_param              => p_param,
        p_view_by            => l_view_by,
        p_view_by_col_name   => l_view_by_col,
        p_view_by_value      => l_view_by_value,
        p_comparison_type    => l_comparison_type,
        p_xtd                => l_xtd,
        p_as_of_date         => l_as_of_date,
        p_prev_as_of_date    => l_prev_as_of_date,
        p_cur_suffix         => l_cur_suffix,
        p_nested_pattern     => l_nested_pattern,
        p_where_clause       => l_where_clause,
        p_mv                 => l_mv,
        p_join_tbl           => l_join_tbl,
        p_in_join_tbl        => l_in_join_tbl ,
        x_custom_output      => x_custom_output,
        p_trend              => 'N',
        p_func_area          => 'PO',
        p_version            => '6.0',
        p_role               => 'COM',
        p_mv_set             => 'PODCUT');

      poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix, 'purchase_amt');

      l_query := get_doctype_sel_clause(l_view_by,l_view_by_col) || ' from ' ||
                 poa_dbi_template_pkg.status_sql(
                   p_fact_name      => l_mv,
                   p_where_clause   => l_where_clause || ' and (contract_type is not null) ',
                   p_join_tables    => l_join_tbl,
                   p_use_windowing  => 'N',
                   p_col_name       => l_col_tbl,
                   p_use_grpid      => 'N',
                   p_paren_count    => 2,
                   p_filter_where   => get_doctype_filter_where,
                   p_in_join_tables => l_in_join_tbl);

    elsif(l_sec_context = 'COMP')then
      poa_dbi_sutil_pkg.process_parameters(
        p_param              => p_param,
        p_view_by            => l_view_by,
        p_view_by_col_name   => l_view_by_col,
        p_view_by_value      => l_view_by_value,
        p_comparison_type    => l_comparison_type,
        p_xtd                => l_xtd,
        p_as_of_date         => l_as_of_date,
        p_prev_as_of_date    => l_prev_as_of_date,
        p_cur_suffix         => l_cur_suffix,
        p_nested_pattern     => l_nested_pattern,
        p_where_clause       => l_where_clause,
        p_mv                 => l_mv,
        p_join_tbl           => l_join_tbl,
        p_in_join_tbl        => l_in_join_tbl ,
        x_custom_output      => x_custom_output,
        p_trend              => 'N',
        p_func_area          => 'PO',
        p_version            => '8.0',
        p_role               => 'COM',
        p_mv_set             => 'PODCUTA');

      poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix, 'purchase_amt');

      /*check if we can get everything from aggregated mv*/
      l_use_only_agg_mv := 'Y';
      for i in 1..l_in_join_tbl.count loop
        if(l_in_join_tbl(i).table_alias = 'com' or l_in_join_tbl(i).table_alias = 'cc') then
          if(l_in_join_tbl(i).aggregated_flag = 'N')then
            l_use_only_agg_mv := 'N';
          end if;
        end if;
      end loop;

      if(l_use_only_agg_mv = 'N') then
        poa_dbi_sutil_pkg.process_parameters(
          p_param              => p_param,
          p_view_by            => l_view_by,
          p_view_by_col_name   => l_view_by_col,
          p_view_by_value      => l_view_by_value,
          p_comparison_type    => l_comparison_type,
          p_xtd                => l_xtd,
          p_as_of_date         => l_as_of_date,
          p_prev_as_of_date    => l_prev_as_of_date,
          p_cur_suffix         => l_cur_suffix,
          p_nested_pattern     => l_nested_pattern,
          p_where_clause       => l_where_clause2,
          p_mv                 => l_mv2,
          p_join_tbl           => l_join_tbl,
          p_in_join_tbl        => l_in_join_tbl2,
          x_custom_output      => x_custom_output,
          p_trend              => 'N',
          p_func_area          => 'PO',
          p_version            => '8.0',
          p_role               => 'COM',
          p_mv_set             => 'PODCUTB');

        l_mv_tbl := poa_dbi_util_pkg.poa_dbi_mv_tbl();
        l_mv_tbl.extend;
        l_mv_tbl(1).mv_name := l_mv;
        l_mv_tbl(1).mv_col := l_col_tbl;
        l_mv_tbl(1).mv_where := l_where_clause;
        l_mv_tbl(1).in_join_tbls := l_in_join_tbl;
        l_mv_tbl(1).use_grp_id := 'N';

        l_mv_tbl.extend;
        l_mv_tbl(2).mv_name := l_mv2;
        l_mv_tbl(2).mv_col := l_col_tbl;
        l_mv_tbl(2).mv_where := l_where_clause2;
        l_mv_tbl(2).in_join_tbls := l_in_join_tbl2;
        l_mv_tbl(2).use_grp_id := 'N';

        l_query := get_doctype_sel_clause(l_view_by,l_view_by_col) || ' from (' ||
          poa_dbi_template_pkg.union_all_status_sql(
                    p_mv              => l_mv_tbl,
                    p_join_tables     => l_join_tbl,
                    p_use_windowing   => 'N',
                    p_paren_count     => 2,
                    p_filter_where    => get_doctype_filter_where,
                    p_generate_viewby => 'Y',
                    p_diff_measures   => 'N');
      else
        l_query := get_doctype_sel_clause(l_view_by,l_view_by_col) || ' from ' ||
                   poa_dbi_template_pkg.status_sql(
                     p_fact_name      => l_mv,
                     p_where_clause   => l_where_clause || ' and (contract_type is not null) ',
                     p_join_tables    => l_join_tbl,
                     p_use_windowing  => 'N',
                     p_col_name       => l_col_tbl,
                     p_use_grpid      => 'N',
                     p_paren_count    => 2,
                     p_filter_where   => get_doctype_filter_where,
                     p_in_join_tables => l_in_join_tbl);
      end if;
    end if;
    x_custom_sql := l_query;
  end;

  FUNCTION get_doctype_sel_clause(p_view_by_col_name in VARCHAR2, p_url in VARCHAR2) return VARCHAR2
    IS
       l_sel_clause varchar2(4000);
  BEGIN
  l_sel_clause :=
  'select v.value VIEWBY, v.id VIEWBYID,
    oset.POA_MEASURE1 POA_MEASURE1,
    oset.POA_MEASURE1 POA_MEASURE3,
    oset.POA_PERCENT1 POA_PERCENT1,
    oset.POA_PERCENT2 POA_PERCENT2,
    oset.POA_MEASURE2 POA_MEASURE2,
    oset.POA_PERCENT3 POA_PERCENT3,
           ''' || 'pFunctionName=POA_DBI_CUD_CON_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y' || ''' POA_ATTRIBUTE1
     from
     (select ' || 'contract_type' || ',
             ' || 'contract_type' || ' VIEWBY,
      c_purchase_amt POA_MEASURE1, '
      || poa_dbi_util_pkg.rate_clause( 'c_purchase_amt', 'c_purchase_amt_total' ) || ' POA_PERCENT1,
      '
      || poa_dbi_util_pkg.change_clause (
           poa_dbi_util_pkg.rate_clause( 'c_purchase_amt', 'c_purchase_amt_total' ) ,
           poa_dbi_util_pkg.rate_clause( 'p_purchase_amt', 'p_purchase_amt_total' ) ,
           'P') || ' POA_PERCENT2,
      c_purchase_amt_total POA_MEASURE2,
      decode(c_purchase_amt_total, null, null, 100) POA_PERCENT3';

  return l_sel_clause;

  END;


end poa_dbi_cut_pkg;

/
