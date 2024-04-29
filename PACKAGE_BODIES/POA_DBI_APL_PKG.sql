--------------------------------------------------------
--  DDL for Package Body POA_DBI_APL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_APL_PKG" 
/* $Header: poadbiaplb.pls 120.5 2006/04/21 02:27:03 sdiwakar noship $ */

AS

  FUNCTION get_status_sel_clause(
             p_view_by_dim in varchar2,
             p_view_by_col in varchar2,
             p_url in varchar2,
             p_sec_context in varchar2
           ) return varchar2;
  FUNCTION get_trend_sel_clause(p_type in varchar2 := 'trend') return VARCHAR2;
  FUNCTION get_status_filter_where return VARCHAR2;
  FUNCTION get_kpi_filter_where return VARCHAR2;

  procedure status_sql(p_param in bis_pmv_page_parameter_tbl,
                      x_custom_sql  out nocopy varchar2,
                      x_custom_output out nocopy bis_query_attributes_tbl)
  is
    l_query            varchar2(10000);
    l_view_by          varchar2(120);
    l_view_by_col      varchar2(120);
    l_as_of_date       date;
    l_prev_as_of_date  date;
    l_xtd              varchar2(10);
    l_comparison_type  varchar2(1) := 'Y';
    l_nested_pattern   number;
    l_cur_suffix       varchar2(2);
    l_url              varchar2(300);
    l_custom_sql       varchar2(4000);
    l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl         poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_in_join_tbl      poa_dbi_util_pkg.poa_dbi_in_join_tbl;
    l_in_join_tbl2     poa_dbi_util_pkg.poa_dbi_in_join_tbl;
    l_where_clause     varchar2(2000);
    l_where_clause2    varchar2(2000);
    l_view_by_value    varchar2(100);
    l_mv               varchar2(30);
    l_mv2              varchar2(30);
    l_sec_context      varchar2(10);
    l_mv_tbl           poa_dbi_util_pkg.poa_dbi_mv_tbl;
    l_use_only_agg_mv  varchar2(1);
    err_msg            varchar2(100);
  begin
    l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();
    l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();

    l_sec_context := poa_dbi_sutil_pkg.get_sec_context(p_param);
    if(l_sec_context = 'OU' or l_sec_context = 'OU/COM') then
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
        p_func_area          => 'AP',
        p_version            => '5.0',
        p_role               => 'VPP',
        p_mv_set             => 'IDL');

      poa_dbi_util_pkg.add_column(l_col_tbl, 'leakage_amount_' || l_cur_suffix, 'leakage_amount');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'amount_' || l_cur_suffix, 'amount');

      if((l_view_by = 'HRI_PERSON+HRI_PER') and (l_view_by_value is not null) and (instr(l_view_by_value,',') = 0)) then
        l_url := null;
      else
        l_url := 'pFunctionName=POA_DBI_APL_STATUS_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=HRI_PERSON+HRI_PER&pParamIds=Y';
      end if;

      l_query := get_status_sel_clause(l_view_by, l_view_by_col, l_url, l_sec_context) ||
                 ' from '|| fnd_global.newline ||
                 poa_dbi_template_pkg.status_sql(
                   p_fact_name      => l_mv,
                   p_where_clause   => l_where_clause,
                   p_join_tables    => l_join_tbl,
                   p_use_windowing  => 'Y',
                   p_col_name       => l_col_tbl,
                   p_use_grpid      => 'N',
                   p_filter_where   => get_status_filter_where,
                   p_in_join_tables => l_in_join_tbl);
    elsif(l_sec_context = 'COMP') then
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
        p_func_area          => 'AP',
        p_version            => '8.0',
        p_role               => 'VPP',
        p_mv_set             => 'IDLA');

      poa_dbi_util_pkg.add_column(l_col_tbl, 'leakage_amount_' || l_cur_suffix, 'leakage_amount');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'amount_' || l_cur_suffix, 'amount');

      if((l_view_by = 'HRI_PERSON+HRI_PER') and (l_view_by_value is not null) and (instr(l_view_by_value,',') = 0)) then
        l_url := null;
      else
        l_url := 'pFunctionName=POA_DBI_CC_APL_STATUS_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=HRI_PERSON+HRI_PER&pParamIds=Y';
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
          p_func_area          => 'AP',
          p_version            => '8.0',
          p_role               => 'VPP',
          p_mv_set             => 'IDLB');

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
        l_query := get_status_sel_clause(l_view_by, l_view_by_col, l_url, l_sec_context) ||
                   ' from ( '||fnd_global.newline ||
                   poa_dbi_template_pkg.union_all_status_sql(
                     p_mv              => l_mv_tbl,
                     p_join_tables     => l_join_tbl,
                     p_use_windowing   => 'Y',
                     p_paren_count     => 3,
                     p_filter_where    => get_status_filter_where,
                     p_generate_viewby => 'Y',
                     p_diff_measures   => 'N');
      else
        l_query := get_status_sel_clause(l_view_by, l_view_by_col, l_url, l_sec_context) ||
                   ' from '|| fnd_global.newline ||
                   poa_dbi_template_pkg.status_sql(
                     p_fact_name      => l_mv,
                     p_where_clause   => l_where_clause,
                     p_join_tables    => l_join_tbl,
                     p_use_windowing  => 'Y',
                     p_col_name       => l_col_tbl,
                     p_use_grpid      => 'N',
                     p_filter_where   => get_status_filter_where,
                     p_in_join_tables => l_in_join_tbl);
      end if; /* l_use_only_agg_mv = 'N' */
    end if; /* l_sec_context = 'OU' or l_sec_context = 'OU/COM' */
    x_custom_sql := l_query;
  end;

  procedure trend_sql(p_param in bis_pmv_page_parameter_tbl,
                      x_custom_sql  out nocopy varchar2,
                      x_custom_output out nocopy bis_query_attributes_tbl)
  is
    l_query            varchar2(10000);
    l_view_by          varchar2(120);
    l_view_by_col      varchar2(120);
    l_as_of_date       date;
    l_prev_as_of_date  date;
    l_xtd              varchar2(10);
    l_comparison_type  varchar2(1) := 'Y';
    l_nested_pattern   number;
    l_cur_suffix       varchar2(2);
    l_custom_sql       varchar2(4000);
    l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl         poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_in_join_tbl      poa_dbi_util_pkg.poa_dbi_in_join_tbl;
    l_in_join_tbl2     poa_dbi_util_pkg.poa_dbi_in_join_tbl;
    l_mv               varchar2(30);
    l_mv2              varchar2(30);
    l_where_clause     varchar2(2000);
    l_where_clause2    varchar2(2000);
    l_view_by_value    varchar2(100);
    l_mv_tbl           poa_dbi_util_pkg.poa_dbi_mv_tbl;
    l_sec_context      varchar2(10);
    l_use_only_agg_mv  varchar2(1);
    err_msg            varchar2(100);
  begin
    l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();
    l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();

    l_sec_context := poa_dbi_sutil_pkg.get_sec_context(p_param);
    if(l_sec_context = 'OU' or l_sec_context = 'OU/COM') then
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
        p_func_area          => 'AP',
        p_version            => '5.0',
        p_role               => 'VPP',
        p_mv_set             => 'IDL');

      poa_dbi_util_pkg.add_column(l_col_tbl, 'leakage_amount_' || l_cur_suffix, 'leakage_amount', 'N');

      poa_dbi_util_pkg.add_column(l_col_tbl, 'amount_' || l_cur_suffix, 'amount', 'N');

      l_query := get_trend_sel_clause || ' from '|| fnd_global.newline ||
                 poa_dbi_template_pkg.trend_sql(
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
        p_func_area          => 'AP',
        p_version            => '8.0',
        p_role               => 'VPP',
        p_mv_set             => 'IDLA');

      poa_dbi_util_pkg.add_column(l_col_tbl, 'leakage_amount_' || l_cur_suffix, 'leakage_amount', 'N');

      poa_dbi_util_pkg.add_column(l_col_tbl, 'amount_' || l_cur_suffix, 'amount', 'N');

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
          p_func_area          => 'AP',
          p_version            => '8.0',
          p_role               => 'VPP',
          p_mv_set             => 'IDLB');

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

        l_query := get_trend_sel_clause('union') || ' from ' ||fnd_global.newline ||
                   poa_dbi_template_pkg.union_all_trend_sql(
                     p_mv              => l_mv_tbl,
                     p_comparison_type =>  l_comparison_type,
                     p_diff_measures   =>  'N');
      else
        l_query := get_trend_sel_clause || ' from ' || fnd_global.newline ||
                   poa_dbi_template_pkg.trend_sql(
                     p_xtd             => l_xtd,
                     p_comparison_type => l_comparison_type,
                     p_fact_name       => l_mv,
                     p_where_clause    => l_where_clause,
                     p_col_name        => l_col_tbl,
                     p_use_grpid       => 'N',
                     p_in_join_tables  => l_in_join_tbl);
      end if; /*l_use_only_agg_mv = 'N' */
    end if; /* l_sec_context = 'OU' or l_sec_context = 'OU/COM' */

    x_custom_sql := l_query;
  end;


FUNCTION get_kpi_filter_where return VARCHAR2
  IS
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  BEGIN
    l_col_tbl := poa_dbi_sutil_pkg.POA_DBI_FILTER_TBL();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_PERCENT2';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_PERCENT1';


    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);

  END;

  procedure kpi_sql(p_param in bis_pmv_page_parameter_tbl,
                      x_custom_sql  out nocopy varchar2,
                      x_custom_output out nocopy bis_query_attributes_tbl)
  is
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
    l_view_by_value varchar2(100);
  begin
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();

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
      p_func_area          => 'AP',
      p_version            => '5.0',
      p_role               => 'VPP',
      p_mv_set             => 'IDL');

    poa_dbi_util_pkg.add_column(l_col_tbl, 'leakage_amount_' || l_cur_suffix, 'leakage_amount');
    poa_dbi_util_pkg.add_column(l_col_tbl, 'amount_' || l_cur_suffix, 'amount');

    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();

    l_join_rec.table_name :=
          poa_dbi_sutil_pkg.get_table('ORGANIZATION+FII_OPERATING_UNITS', 'AP', '5.0');
    l_join_rec.table_alias := 'v';
    l_join_rec.fact_column :=
          poa_dbi_sutil_pkg.get_col_name('ORGANIZATION+FII_OPERATING_UNITS', 'AP', '5.0', 'IDL');
    l_join_rec.column_name := 'id';

    l_join_tbl.extend;
    l_join_tbl(l_join_tbl.count) :=l_join_rec;

    l_query := 'select v.value VIEWBY,
          oset.POA_PERCENT1 POA_PERCENT1,  --Current
          oset.POA_PERCENT2 POA_PERCENT2,  --Prior
          oset.POA_MEASURE1 POA_MEASURE1,  --Current Leakage Amount
          oset.POA_MEASURE2 POA_MEASURE2   --Current Amount
           from
      (select * from
        (select org_id,
             ' || poa_dbi_util_pkg.rate_clause('c_leakage_amount','c_amount') || ' POA_PERCENT1,
             ' || poa_dbi_util_pkg.rate_clause('p_leakage_amount','p_amount') || ' POA_PERCENT2,
             ' || poa_dbi_util_pkg.rate_clause('c_leakage_amount_total','c_amount_total') || ' POA_MEASURE1,
             ' || poa_dbi_util_pkg.rate_clause('p_leakage_amount_total','p_amount_total') || ' POA_MEASURE2
     from
    ' || poa_dbi_template_pkg.status_sql(
           p_fact_name      => l_mv,
           p_where_clause   => l_where_clause,
           p_join_tables    => l_join_tbl,
           p_use_windowing  => 'N',
           p_col_name       => l_col_tbl,
           p_use_grpid      => 'N',
           p_filter_where   => get_kpi_filter_where,
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


  FUNCTION get_status_sel_clause(
             p_view_by_dim in varchar2,
             p_view_by_col in varchar2,
             p_url in varchar2,
             p_sec_context in varchar2
           ) return varchar2
  IS
    l_sel_clause varchar2(4000);
  BEGIN
    l_sel_clause :=
    'select ' || case p_view_by_col
               when 'inv_d_created_by' then 'decode(v.value, null, fnd_message.get_string(''POA'', ''POA_DBI_APL_UNASSIGNED''), v.value) '
               else 'v.value ' end ||
               'VIEWBY,
    decode(v.id, null, -1, v.id) VIEWBYID,
    oset.POA_MEASURE1 POA_MEASURE1,  --Leakage Amount
    oset.POA_MEASURE1 POA_MEASURE2,  --Leakage
    oset.POA_PERCENT1 POA_PERCENT1,  --Change
    oset.POA_MEASURE3 POA_MEASURE3,  --Invoice Amount
    oset.POA_PERCENT2 POA_PERCENT2,  --Leakage Rate
    oset.POA_MEASURE4 POA_MEASURE4,  --Total Leakage Amount
    oset.POA_MEASURE5 POA_MEASURE5,  --Total Invoice Amount
    oset.POA_MEASURE6 POA_MEASURE6,  --Total Change
    oset.POA_MEASURE7 POA_MEASURE7,  --Total Leakage Rate
    ''' || p_url || ''' POA_MEASURE8,
    ''' || p_url || ''' POA_MEASURE9,';

    if (p_view_by_dim = 'FII_COMPANIES+FII_COMPANIES' or
        p_view_by_dim = 'ORGANIZATION+HRI_CL_ORGCC') then
      l_sel_clause := l_sel_clause || '
        decode(v.summary_flag,''Y'',''pFunctionName=POA_DBI_CC_APL_STATUS_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'',null) POA_ATTRIBUTE3,
        decode(v.summary_flag,''Y'',''pFunctionName=POA_DBI_CC_APL_STATUS_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'',null) POA_ATTRIBUTE4,';
    else
      l_sel_clause := l_sel_clause || '
        null POA_ATTRIBUTE3,
        null POA_ATTRIBUTE4,';
    end if;

    if (p_sec_context = 'COMP') then
      l_sel_clause := l_sel_clause || '
        ''pFunctionName=POA_DBI_CC_APL_TREND_RPT&VIEW_BY_NAME=VIEW_BY_VALUE&VIEW_BY=TIME+FII_TIME_ENT_YEAR'' POA_ATTRIBUTE5';
    else
      l_sel_clause := l_sel_clause || '
        ''pFunctionName=POA_DBI_APL_TREND_RPT&VIEW_BY_NAME=VIEW_BY_VALUE&VIEW_BY=TIME+FII_TIME_ENT_YEAR'' POA_ATTRIBUTE5';
    end if;
    l_sel_clause := l_sel_clause || '
    from
    (select (rank() over (&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col || ')) - 1 rnk,'
        || p_view_by_col || ',
           POA_MEASURE1, POA_PERCENT1, POA_MEASURE3, POA_PERCENT2, POA_MEASURE4,
           POA_MEASURE5, POA_MEASURE6, POA_MEASURE7 from
     (select ' || p_view_by_col || ',
             ' || p_view_by_col || ' VIEWBY,
           nvl(c_leakage_amount,0) POA_MEASURE1,
           ' || poa_dbi_util_pkg.change_clause('c_leakage_amount','p_leakage_amount') || ' POA_PERCENT1,
           nvl(c_amount,0) POA_MEASURE3,
           ' || poa_dbi_util_pkg.rate_clause('c_leakage_amount','c_amount') || ' POA_PERCENT2,
           nvl(c_leakage_amount_total,0) POA_MEASURE4,
           nvl(c_amount_total,0) POA_MEASURE5,
           ' || poa_dbi_util_pkg.change_clause('c_leakage_amount_total','p_leakage_amount_total') || ' POA_MEASURE6,
           ' || poa_dbi_util_pkg.rate_clause('c_leakage_amount_total','c_amount_total') || ' POA_MEASURE7';

    return l_sel_clause;
  END;

  FUNCTION get_trend_sel_clause(p_type in varchar2 := 'trend') return VARCHAR2
  IS

  l_sel_clause varchar2(4000);

  BEGIN
  if (p_type = 'trend') then
    l_sel_clause := 'select cal.name VIEWBY,'||fnd_global.newline;
  else
    l_sel_clause := 'select cal_name VIEWBY,'||fnd_global.newline;
  end if;
  l_sel_clause := l_sel_clause || 'nvl(p_leakage_amount,0) POA_MEASURE1,
             nvl(c_leakage_amount,0) POA_MEASURE2,
       nvl(p_leakage_amount,0) POA_PERCENT1,
          ' || poa_dbi_util_pkg.change_clause('c_leakage_amount','p_leakage_amount') || ' POA_PERCENT3,
       nvl(c_leakage_amount,0) POA_PERCENT2';

  return l_sel_clause;

  END;

end poa_dbi_apl_pkg;

/
