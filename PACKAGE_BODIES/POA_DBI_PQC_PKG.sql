--------------------------------------------------------
--  DDL for Package Body POA_DBI_PQC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_PQC_PKG" 
/* $Header: poadbipqcb.pls 120.12 2006/09/15 10:44:29 nchava noship $*/
AS
FUNCTION get_status_sel_clause(p_view_by_dim    IN VARCHAR2
                              ,p_view_by_col    IN VARCHAR2
                              ,p_url            IN VARCHAR2
                              ,p_sameyear       IN NUMBER
                              ,p_sec_context    IN VARCHAR2) RETURN VARCHAR2;

FUNCTION get_kpi_sel_clause(p_view_by_dim   IN VARCHAR2
                           ,p_view_by_col   IN VARCHAR2
                           ,p_url           IN VARCHAR2
                           ,p_sameyear      IN NUMBER
                           ,p_prev_sameyear IN NUMBER) RETURN VARCHAR2;

FUNCTION get_status_filter_where(p_view_by IN VARCHAR2) return VARCHAR2;
FUNCTION get_dtl_filter_where return VARCHAR2;

  PROCEDURE status_sql(p_param            IN          BIS_PMV_PAGE_PARAMETER_TBL
                    ,x_custom_sql       OUT NOCOPY  VARCHAR2
                    ,x_custom_output    OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL)
  IS
    l_query             varchar2(10000);
    l_view_by           varchar2(120);
    l_view_by_col       varchar2(120);
    l_as_of_date        date;
    l_prev_as_of_date   date;
    l_xtd               varchar2(10);
    l_comparison_type   varchar2(1) := 'Y';
    l_nested_pattern    number;
    l_cur_suffix        varchar2(2);
    l_col_tbl           poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl          poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_in_join_tbl       poa_dbi_util_pkg.poa_dbi_in_join_tbl;
    l_in_join_tbl2      poa_dbi_util_pkg.poa_dbi_in_join_tbl;
    l_where_clause      varchar2(2000);
    l_where_clause2     varchar2(2000);
    l_view_by_value     varchar2(100);
    l_mv                varchar2(30);
    l_mv2               varchar2(30);
    l_asof_year         date;
    l_prev_asof_year    date;
    l_url               varchar2(300);
    l_sec_context       varchar2(10);
    l_use_only_agg_mv   varchar2(1);
    l_mv_tbl            poa_dbi_util_pkg.poa_dbi_mv_tbl;
  BEGIN
    l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();
    l_col_tbl  := poa_dbi_util_pkg.poa_dbi_col_tbl();

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
        p_mv_set             => 'PQC');

      poa_dbi_util_pkg.add_column(l_col_tbl, 'pbpcqco_amt_' || l_cur_suffix, 'benchmark_amt');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'pbcqco_amt_' || l_cur_suffix, 'fallback_amt');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix, 'amt');

      if(l_view_by = 'ITEM+POA_ITEMS') then
        poa_dbi_util_pkg.add_column(l_col_tbl, 'quantity', 'quantity');
      end if;

      if((l_view_by = 'SUPPLIER+POA_SUPPLIERS') and (l_view_by_value is not null) and (instr(l_view_by_value,',') = 0)) then
        l_url := null;
      else
        if(l_view_by = 'ITEM+POA_ITEMS') then
          l_url := 'pFunctionName=POA_DBI_PQC_DTL_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
        else
          l_url := 'pFunctionName=POA_DBI_PQC_STATUS_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=SUPPLIER+POA_SUPPLIERS&pParamIds=Y';
        end if;
      end if;

      l_asof_year := fii_time_api.ent_cyr_start(l_as_of_date);
      l_prev_asof_year := fii_time_api.ent_cyr_start(l_prev_as_of_date);

      l_query := get_status_sel_clause(
                   l_view_by,
                   l_view_by_col,
                   l_url,
                   l_asof_year - l_prev_asof_year,
                   l_sec_context) || ' from
                   ' ||
                   poa_dbi_template_pkg.status_sql(
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
        p_mv_set             => 'PQCA');

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
          p_mv_set             => 'PQCB');
      end if;
      poa_dbi_util_pkg.add_column(l_col_tbl, 'pbpcqco_amt_' || l_cur_suffix, 'benchmark_amt');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'pbcqco_amt_' || l_cur_suffix, 'fallback_amt');
      poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix, 'amt');

      if(l_view_by = 'ITEM+POA_ITEMS') then
        poa_dbi_util_pkg.add_column(l_col_tbl, 'quantity', 'quantity');
      end if;

      if((l_view_by = 'SUPPLIER+POA_SUPPLIERS') and (l_view_by_value is not null) and (instr(l_view_by_value,',') = 0)) then
        l_url := null;
      else
        if(l_view_by = 'ITEM+POA_ITEMS') then
          l_url := 'pFunctionName=POA_DBI_CC_PQC_DTL_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y';
        else
          l_url := 'pFunctionName=POA_DBI_CC_PQC_STATUS_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=SUPPLIER+POA_SUPPLIERS&pParamIds=Y';
        end if;
      end if;

      l_asof_year := fii_time_api.ent_cyr_start(l_as_of_date);
      l_prev_asof_year := fii_time_api.ent_cyr_start(l_prev_as_of_date);

      if(l_use_only_agg_mv = 'N') then
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

        l_query := get_status_sel_clause(
                     l_view_by,
                     l_view_by_col,
                     l_url,
                     l_asof_year - l_prev_asof_year,
                     l_sec_context) || ' from ('||fnd_global.newline||
                     poa_dbi_template_pkg.union_all_status_sql(
                       p_mv              => l_mv_tbl,
                       p_join_tables     => l_join_tbl,
                       p_use_windowing   => 'Y',
                       p_paren_count     => 3,
                       p_filter_where    => get_status_filter_where(l_view_by),
                       p_generate_viewby => 'Y',
                       p_diff_measures   => 'N');
      else
        l_query := get_status_sel_clause(
                     l_view_by,
                     l_view_by_col,
                     l_url,
                     l_asof_year - l_prev_asof_year,
                     l_sec_context) || ' from
                     ' ||
                     poa_dbi_template_pkg.status_sql(
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


  FUNCTION get_status_filter_where(p_view_by IN VARCHAR2) return VARCHAR2
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
    l_col_tbl(4) := 'POA_MEASURE4';
    l_col_tbl.extend;
    l_col_tbl(5) := 'POA_MEASURE5';
    l_col_tbl.extend;
    l_col_tbl(6) := 'POA_MEASURE6';
    l_col_tbl.extend;
    l_col_tbl(7) := 'POA_MEASURE17';

    if(p_view_by = 'ITEM+POA_ITEMS') then
       l_col_tbl.extend;
       l_col_tbl(8) := 'POA_MEASURE13';
       l_col_tbl.extend;
       l_col_tbl(9) := 'POA_MEASURE15';
       l_col_tbl.extend;
       l_col_tbl(10) := 'POA_MEASURE16';
    end if;
    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);
  END;


  FUNCTION get_status_sel_clause(p_view_by_dim    IN VARCHAR2
                              ,p_view_by_col    IN VARCHAR2
                              ,p_url            IN VARCHAR2
                              ,p_sameyear       IN NUMBER
                              ,p_sec_context    IN VARCHAR2) RETURN VARCHAR2
  IS
    l_sel_clause VARCHAR2(4000);
  BEGIN
    l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim, 'PO', '6.0');

    if(p_view_by_dim = 'ITEM+POA_ITEMS') then
      l_sel_clause := l_sel_clause || '
      v.description POA_ATTRIBUTE1,     --Description
      v2.description POA_ATTRIBUTE2,    --UOM
      oset.POA_MEASURE13 POA_MEASURE13, --Current Quantity
      oset.POA_MEASURE15 POA_MEASURE15, --Prior Quantity
      oset.POA_MEASURE16 POA_MEASURE16, --Quantity Change
';
    else
      l_sel_clause := l_sel_clause || '
      null POA_MEASURE13,  --Current Quantity
      null POA_MEASURE15,  --Prior Quantity
      null POA_MEASURE16,  --Quantity Change
      null POA_ATTRIBUTE1, --Description
      null POA_ATTRIBUTE2, --UOM
    ';
    end if;

    l_sel_clause := l_sel_clause || '
      oset.POA_MEASURE1 POA_MEASURE1,   --Price Savings Amount
      oset.POA_MEASURE2 POA_MEASURE2,   --Savings Rate
      oset.POA_MEASURE3 POA_MEASURE3,   --Current Amount at PO Price
      oset.POA_MEASURE4 POA_MEASURE4,   --Current Amount
      oset.POA_MEASURE5 POA_MEASURE5,   --Prior Amount
      oset.POA_MEASURE6 POA_MEASURE6,   --Quantity Change Amount
      oset.POA_MEASURE17 POA_MEASURE17, --Quantity Change Amount at Benchmark
      oset.POA_MEASURE7 POA_MEASURE7,   --Total Price Savings Amount[
      oset.POA_MEASURE8 POA_MEASURE8,   --Total Savings Rate
      oset.POA_MEASURE9 POA_MEASURE9,   --Total Current Amount at PO Price
      oset.POA_MEASURE10 POA_MEASURE10, --Total Current Amount
      oset.POA_MEASURE11 POA_MEASURE11, --Total Prior Amount
      oset.POA_MEASURE12 poa_measure12, --Total Quantity Change Amount
      oset.POA_MEASURE12 poa_measure18, --Total Quantity Change Amount at Benchmark
      ''' || p_url || ''' POA_ATTRIBUTE3,';

   if (p_view_by_dim = 'FII_COMPANIES+FII_COMPANIES' or
       p_view_by_dim = 'ORGANIZATION+HRI_CL_ORGCC') then
     l_sel_clause := l_sel_clause || '
       decode(v.summary_flag,''Y'',''pFunctionName=POA_DBI_CC_PQC_STATUS_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'',null) POA_ATTRIBUTE6,
       decode(v.summary_flag,''Y'',''pFunctionName=POA_DBI_CC_PQC_STATUS_RPT&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'',null) POA_ATTRIBUTE7,';
   else
     l_sel_clause := l_sel_clause || '
       null POA_ATTRIBUTE6,
       null POA_ATTRIBUTE7,';
   end if;

   if (p_sec_context = 'COMP') then
     l_sel_clause := l_sel_clause ||'
       ''pFunctionName=POA_DBI_CC_PQC_STATUS_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+POA_ITEMS&pParamIds=Y'' POA_ATTRIBUTE8 ';
   else
     l_sel_clause := l_sel_clause ||'
       ''pFunctionName=POA_DBI_PQC_STATUS_RPT&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=ITEM+POA_ITEMS&pParamIds=Y'' POA_ATTRIBUTE8 ';
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
      l_sel_clause := l_sel_clause || ', base_uom, POA_MEASURE13,POA_MEASURE15,POA_MEASURE16';
    end if;

    l_sel_clause := l_sel_clause || ',
        POA_MEASURE1, POA_MEASURE2,
        POA_MEASURE3, POA_MEASURE4,
        POA_MEASURE5, POA_MEASURE6,
        POA_MEASURE7, POA_MEASURE8,
        POA_MEASURE9, POA_MEASURE10,
        POA_MEASURE11, POA_MEASURE12,
        POA_MEASURE17
        from
        (select ' || p_view_by_col || ',
             ' || p_view_by_col || ' VIEWBY,';


    if(p_view_by_dim = 'ITEM+POA_ITEMS') then
     l_sel_clause := l_sel_clause || ' base_uom, nvl(c_quantity,0) POA_MEASURE13,
      nvl(p_quantity,0) POA_MEASURE15, nvl(c_quantity,0) - Nvl(p_quantity,0) POA_MEASURE16,';
    end if;

    IF (p_sameyear = 0) then
      l_sel_clause := l_sel_clause || '
      nvl(c_benchmark_amt,0) - nvl(c_amt,0) POA_MEASURE1,
      ' || poa_dbi_util_pkg.rate_clause('c_benchmark_amt','c_amt') || '-100 POA_MEASURE2,
      nvl(c_amt,0) POA_MEASURE3,
      nvl(c_benchmark_amt,0) POA_MEASURE4,
      nvl(p_benchmark_amt,0) POA_MEASURE5,
      Nvl(c_benchmark_amt,0) - Nvl(p_benchmark_amt, 0) POA_MEASURE6,
      Nvl(c_benchmark_amt,0) - Nvl(p_benchmark_amt, 0) POA_MEASURE17,
      nvl(c_benchmark_amt_total,0) - nvl(c_amt_total,0) POA_MEASURE7,
      ' || poa_dbi_util_pkg.rate_clause('c_benchmark_amt_total','c_amt_total') || '-100 POA_MEASURE8,
      nvl(c_amt_total,0) poa_measure9,
      nvl(c_benchmark_amt_total,0) POA_MEASURE10,
      nvl(p_benchmark_amt_total,0) POA_MEASURE11,
      nvl(c_benchmark_amt_total,0) - Nvl(p_benchmark_amt_total, 0) POA_MEASURE12
      ';
    ELSE
      l_sel_clause := l_sel_clause || '
      nvl(c_benchmark_amt,0) - nvl(c_amt,0)  POA_MEASURE1,
      ' || poa_dbi_util_pkg.rate_clause('c_benchmark_amt','c_amt') || '-100 POA_MEASURE2,
      nvl(c_amt,0) POA_MEASURE3,
      nvl(c_benchmark_amt,0) POA_MEASURE4,
      nvl(p_fallback_amt,0) POA_MEASURE5,
      nvl(c_benchmark_amt,0) - Nvl(p_fallback_amt, 0) POA_MEASURE6,
      nvl(c_benchmark_amt,0) - Nvl(p_fallback_amt, 0) POA_MEASURE17,
      nvl(c_benchmark_amt_total,0) - nvl(c_amt_total,0) POA_MEASURE7,
      ' || poa_dbi_util_pkg.rate_clause('c_benchmark_amt_total','c_amt_total') || '-100 POA_MEASURE8,
      nvl(c_amt_total,0) poa_measure9,
      nvl(c_benchmark_amt_total,0) POA_MEASURE10,
      nvl(p_fallback_amt_total,0) POA_MEASURE11,
      nvl(c_benchmark_amt_total,0) - Nvl(p_fallback_amt_total, 0) POA_MEASURE12
    ';
    END IF;

    RETURN l_sel_clause;
  END;

  PROCEDURE kpi_sql(p_param         IN         BIS_PMV_PAGE_PARAMETER_TBL
                   ,x_custom_sql    OUT NOCOPY VARCHAR2
                   ,x_custom_output OUT NOCOPY BIS_QUERY_ATTRIBUTES_TBL)
  is
    l_query                    varchar2(10000);
    l_view_by                  varchar2(120);
    l_as_of_date               date;
    l_prev_as_of_date          date;
    l_prev_prev_as_of_date     date;
    l_view_by_col              varchar2(120);
    l_asof_year                date;
    l_prev_asof_year           date;
    l_prev_prev_asof_year      date;
    l_url                      varchar2(300);
    l_mv                       varchar2(30);
    l_mv2                      varchar2(30);
    l_view_by_value            varchar2(100);
    l_xtd                      varchar2(10);
    l_where_clause             varchar2(2000);
    l_where_clause2            varchar2(2000);
    l_comparison_type          varchar2(1) := 'Y';
    l_nested_pattern           number;
    l_cur_suffix               varchar2(2);
    l_col_tbl                  poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl                 poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_in_join_tbl              poa_dbi_util_pkg.poa_dbi_in_join_tbl;
    l_in_join_tbl2             poa_dbi_util_pkg.poa_dbi_in_join_tbl;
    l_custom_rec               bis_query_attributes;
    l_sec_context              varchar2(10);
    l_use_only_agg_mv          varchar2(1);
    l_mv_tbl                   poa_dbi_util_pkg.poa_dbi_mv_tbl;
  begin
    l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();
    l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();
    l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;

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
        p_mv_set             => 'PQC');

      poa_dbi_util_pkg.add_column(l_col_tbl, 'pbpcqco_amt_' || l_cur_suffix, 'benchmark_amt','Y',poa_dbi_util_pkg.PREV_PREV);
      poa_dbi_util_pkg.add_column(l_col_tbl, 'pbcqco_amt_' || l_cur_suffix, 'fallback_amt','Y',poa_dbi_util_pkg.PREV_PREV);
      poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix, 'amt','Y');

      l_prev_prev_as_of_date := poa_dbi_calendar_pkg.previous_period_asof_date(l_prev_as_of_date, l_xtd, l_comparison_type);

      l_asof_year := fii_time_api.ent_cyr_start(l_as_of_date);
      l_prev_asof_year := fii_time_api.ent_cyr_start(l_prev_as_of_date);

       begin
           l_prev_prev_asof_year := fii_time_api.ent_cyr_start(l_prev_prev_as_of_date);
           exception
            when no_data_found then
            l_prev_prev_asof_year := null;
       end;



      l_query := get_kpi_sel_clause(l_view_by
                                   ,l_view_by_col
                                   ,l_url
                                   ,l_asof_year - l_prev_asof_year
                                   ,l_prev_asof_year-l_prev_prev_asof_year);
      l_query := l_query || ' from ';

      l_query := l_query ||
                   poa_dbi_template_pkg.status_sql(
                     p_fact_name      => l_mv,
                     p_where_clause   => l_where_clause,
                     p_join_tables    => l_join_tbl,
                     p_use_windowing  => 'Y',
                     p_col_name       => l_col_tbl,
                     p_use_grpid      => 'N',
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
        p_func_area          => 'PO',
        p_version            => '8.0',
        p_role               => 'COM',
        p_mv_set             => 'PQCA');

      poa_dbi_util_pkg.add_column(l_col_tbl, 'pbpcqco_amt_' || l_cur_suffix, 'benchmark_amt','Y',poa_dbi_util_pkg.PREV_PREV);
      poa_dbi_util_pkg.add_column(l_col_tbl, 'pbcqco_amt_' || l_cur_suffix, 'fallback_amt','Y',poa_dbi_util_pkg.PREV_PREV);
      poa_dbi_util_pkg.add_column(l_col_tbl, 'purchase_amt_' || l_cur_suffix, 'amt','Y');

      l_prev_prev_as_of_date := poa_dbi_calendar_pkg.previous_period_asof_date(l_prev_as_of_date, l_xtd, l_comparison_type);

      l_asof_year := fii_time_api.ent_cyr_start(l_as_of_date);
      l_prev_asof_year := fii_time_api.ent_cyr_start(l_prev_as_of_date);
      l_prev_prev_asof_year := fii_time_api.ent_cyr_start(l_prev_prev_as_of_date);

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
          p_mv_set             => 'PQCB');

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
        l_query := get_kpi_sel_clause(l_view_by
                                     ,l_view_by_col
                                     ,l_url
                                     ,l_asof_year - l_prev_asof_year
                                     ,l_prev_asof_year-l_prev_prev_asof_year);

        l_query := l_query || ' from ( ' ||
                     poa_dbi_template_pkg.union_all_status_sql(
                       p_mv              => l_mv_tbl,
                       p_join_tables     => l_join_tbl,
                       p_use_windowing   => 'Y',
                       p_paren_count     => 3,
                       p_generate_viewby => 'Y',
                       p_diff_measures   => 'N');
      else
        l_query := get_kpi_sel_clause(l_view_by
                                     ,l_view_by_col
                                     ,l_url
                                     ,l_asof_year - l_prev_asof_year
                                     ,l_prev_asof_year-l_prev_prev_asof_year);

        l_query := l_query || ' from ' ||
                     poa_dbi_template_pkg.status_sql(
                       p_fact_name      => l_mv,
                       p_where_clause   => l_where_clause,
                       p_join_tables    => l_join_tbl,
                       p_use_windowing  => 'Y',
                       p_col_name       => l_col_tbl,
                       p_use_grpid      => 'N',
                       p_in_join_tables => l_in_join_tbl);
      end if; /* l_use_only_agg_mv = 'N' */
    end if; /* l_sec_context = 'OU' or l_sec_context = 'OU/COM' */
    x_custom_sql := l_query;

    l_custom_rec.attribute_name := '&PREV_PREV_DATE';
    l_custom_rec.attribute_value := TO_CHAR(l_prev_prev_as_of_date, 'DD/MM/YYYY');
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.DATE_BIND;
    x_custom_output.EXTEND;
    x_custom_output(x_custom_output.COUNT) := l_custom_rec;
  end kpi_sql;

FUNCTION get_kpi_sel_clause(p_view_by_dim   IN VARCHAR2
                           ,p_view_by_col   IN VARCHAR2
                           ,p_url           IN VARCHAR2
                           ,p_sameyear      IN NUMBER
                           ,p_prev_sameyear IN NUMBER) RETURN VARCHAR2
IS
  l_sel_clause VARCHAR2(4000);
BEGIN
  l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim, 'PO', '6.0') ;
  l_sel_clause := l_sel_clause || '
  oset.POA_MEASURE1 POA_MEASURE1,
  oset.POA_MEASURE3 POA_MEASURE3,
  oset.POA_MEASURE5 POA_MEASURE5,
  oset.POA_MEASURE6 POA_MEASURE6,
  oset.POA_MEASURE2 POA_MEASURE2,
  oset.POA_MEASURE4 POA_MEASURE4,
  oset.POA_MEASURE8 POA_MEASURE8,
  oset.POA_MEASURE9 POA_MEASURE9

  from
   (select (rank() over
       ( &ORDER_BY_CLAUSE nulls last, ' || p_view_by_col || ')) - 1 rnk,'
       || p_view_by_col;

  l_sel_clause := l_sel_clause || ',
       POA_MEASURE1,  -- Price Savings Amount
       POA_MEASURE3,  -- Prior Price Savings Amount
       POA_MEASURE5,  -- Total Price Savings Amount
       POA_MEASURE6,  -- Total Prior Price Savings Amount
       POA_MEASURE2,  -- Qty Savings @ Benchmark
       POA_MEASURE4,  -- Prior Qty Savings @ Benchmark
       POA_MEASURE8,  -- Total Qty Savings @ Benchmark
       POA_MEASURE9   -- Total Prior Qty Savings @ Benchmark
    from
    (select ' || p_view_by_col || ',
            ' || p_view_by_col || ' VIEWBY,';


  if (p_sameyear = 0)
  then
   l_sel_clause := l_sel_clause || '
   nvl(c_benchmark_amt,0) - nvl(c_amt,0) POA_MEASURE1,
   nvl(p_benchmark_amt,0) - nvl(p_amt,0) POA_MEASURE3,
   nvl(c_benchmark_amt_total,0) - nvl(c_amt_total,0) POA_MEASURE5,
   nvl(p_benchmark_amt_total,0) - nvl(p_amt_total,0) POA_MEASURE6,
   nvl(c_benchmark_amt,0) - nvl(p_benchmark_amt, 0) POA_MEASURE2,
   nvl(c_benchmark_amt_total,0) - Nvl(p_benchmark_amt_total, 0) POA_MEASURE8,';
  else
   l_sel_clause := l_sel_clause || '
   nvl(c_benchmark_amt,0) - nvl(c_amt,0) POA_MEASURE1,
   nvl(p_benchmark_amt,0) - nvl(p_amt,0) POA_MEASURE3,
   nvl(c_benchmark_amt_total,0) - nvl(c_amt_total,0) POA_MEASURE5,
   nvl(p_benchmark_amt_total,0) - nvl(p_amt_total,0) POA_MEASURE6,
   nvl(c_benchmark_amt,0) - Nvl(p_fallback_amt, 0) POA_MEASURE2,
   nvl(c_benchmark_amt_total,0) - Nvl(p_fallback_amt_total, 0) POA_MEASURE8,';
  end if;

  if(p_prev_sameyear = 0)
  then
   l_sel_clause := l_sel_clause || '
   nvl(p_benchmark_amt,0) - Nvl(p2_benchmark_amt,0) POA_MEASURE4,
   nvl(p_benchmark_amt_total,0) - Nvl(p2_benchmark_amt_total,0) POA_MEASURE9
   ';
  else
   l_sel_clause := l_sel_clause || '
   nvl(p_benchmark_amt,0) - Nvl(p2_fallback_amt,0) POA_MEASURE4,
   nvl(p_benchmark_amt_total,0) - Nvl(p2_fallback_amt_total,0) POA_MEASURE9
   ';
  end if;

  return l_sel_clause;

END GET_KPI_SEL_CLAUSE;




/*
FUNCTION get_kpi_sel_clause(p_view_by_dim   IN VARCHAR2
                           ,p_view_by_col   IN VARCHAR2
                           ,p_url           IN VARCHAR2
                           ,p_sameyear      IN NUMBER
                           ,p_prev_sameyear IN NUMBER) RETURN VARCHAR2
IS
  l_sel_clause VARCHAR2(4000);
BEGIN
  l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim, 'PO', '6.0') ;
  l_sel_clause := l_sel_clause || '
  oset.POA_MEASURE1 POA_MEASURE1,
  oset.POA_MEASURE3 POA_MEASURE3,
  oset.POA_MEASURE5 POA_MEASURE5,
  oset.POA_MEASURE6 POA_MEASURE6,
  oset.POA_MEASURE2 POA_MEASURE2,
  oset.POA_MEASURE4 POA_MEASURE4,
  oset.POA_MEASURE8 POA_MEASURE8,
  oset.POA_MEASURE9 POA_MEASURE9
  from
   (select (rank() over
       ( &ORDER_BY_CLAUSE nulls last, ' || p_view_by_col || ')) - 1 rnk,'
       || p_view_by_col;

  l_sel_clause := l_sel_clause || ',
       POA_MEASURE1,    --Price Savings Amount
       POA_MEASURE3,    --Prior Price Savings Amount
       POA_MEASURE5,    --Total Price Savings Amount
       POA_MEASURE6,    --Total Prior Price Savings Amount
       POA_MEASURE2,    --Qty Savings at Benchmark
       POA_MEASURE4,    --Prior Qty Savings at Benchmark
       POA_MEASURE8,    --Total Qty Savings at Benchmark
       POA_MEASURE9     --Total Prior Qty Savings at Benchmark
    from
    (select ' || p_view_by_col || ',
            ' || p_view_by_col || ' VIEWBY,';


  if (p_sameyear = 0)
  then
   l_sel_clause := l_sel_clause || '
   nvl(c_benchmark_amt,0) - nvl(c_amt,0) POA_MEASURE1,
   nvl(p_benchmark_amt,0) - nvl(p_amt,0) POA_MEASURE3,
   nvl(c_benchmark_amt_total,0) - nvl(c_amt_total,0) POA_MEASURE5,
   nvl(p_benchmark_amt_total,0) - nvl(p_amt_total,0) POA_MEASURE6,
   nvl(c_benchmark_amt,0) - nvl(p_benchmark_amt, 0) POA_MEASURE2,
   nvl(c_benchmark_amt_total,0) - nvl(p_benchmark_amt_total,0) POA_MEASURE8,';
  else
   l_sel_clause := l_sel_clause || '
   nvl(c_benchmark_amt,0) - nvl(c_amt,0) POA_MEASURE1,
   nvl(p_benchmark_amt,0) - nvl(p_amt,0) POA_MEASURE3,
   nvl(c_benchmark_amt_total,0) - nvl(c_amt_total,0) POA_MEASURE5,
   nvl(p_benchmark_amt_total,0) - nvl(p_amt_total,0) POA_MEASURE6,
   nvl(c_benchmark_amt,0) - Nvl(p_fallback_amt, 0) POA_MEASURE2,
   nvl(c_benchmark_amt_total,0) - nvl(p_fallback_amt_total,0) POA_MEASURE8,';
  end if;

  if(p_prev_sameyear = 0)
  then
   l_sel_clause := l_sel_clause || '
   Nvl(p_benchmark_amt,0) - Nvl(p2_benchmark_amt,0) POA_MEASURE4,
   nvl(p_benchmark_amt_total,0) - nvl(p2_benchmark_amt_total,0) POA_MEASURE9
   ';
  else
   l_sel_clause := l_sel_clause || '
   Nvl(p_benchmark_amt,0) - Nvl(p2_fallback_amt,0) POA_MEASURE4,
   nvl(p_benchmark_amt_total,0) - nvl(p2_fallback_amt_total,0) POA_MEASURE9,
   ';
  end if;

  return l_sel_clause;

END GET_KPI_SEL_CLAUSE;
*/

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
    l_col_tbl(3) := 'POA_MEASURE5';
    l_col_tbl.extend;
    l_col_tbl(4) := 'POA_MEASURE6';

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
    l_in_join_tables    VARCHAR2(1000) := '';
    l_filter_where VARCHAR2(1000);
    l_sec_context varchar2(10);
  BEGIN
    x_custom_output := BIS_QUERY_ATTRIBUTES_TBL();
    l_filter_where := get_dtl_filter_where;

    l_sec_context := poa_dbi_sutil_pkg.get_sec_context(p_param);
    if(l_sec_context = 'OU' or l_sec_context = 'OU/COM') then
      poa_dbi_sutil_pkg.drill_process_parameters(
        p_param,
        l_cur_suffix,
        l_where_clause,
        l_in_join_tbl,
        'PO',
        '6.0',
        'COM',
        'PQC');
    else
      poa_dbi_sutil_pkg.drill_process_parameters(
        p_param,
        l_cur_suffix,
        l_where_clause,
        l_in_join_tbl,
        'PO',
        '8.0',
        'COM',
        'PQCB');
    end if;

    IF(l_in_join_tbl is not null) then
      FOR i in 1 .. l_in_join_tbl.COUNT LOOP
        l_in_join_tables := l_in_join_tables || ', ' ||  l_in_join_tbl(i).table_name || ' ' || l_in_join_tbl(i).table_alias;
      END LOOP;
    END IF;

    l_query :=
    'select poh.segment1 || decode(rel.release_num, null, null, ''-'' || rel.release_num) POA_ATTRIBUTE1, --PO Number
     pol.line_num POA_ATTRIBUTE2,   --Line Number
     poorg.name POA_ATTRIBUTE3,    --Operating Unit
     item.value POA_ATTRIBUTE4,    --Item
     uom.description POA_ATTRIBUTE5,  --UOM
     POA_MEASURE1,  --Quantity
     POA_MEASURE2,  --Benchmark Price
     POA_MEASURE3,  --PO Price
     POA_MEASURE4,  --Price Difference
     POA_MEASURE5,  --Price Savings Amount
     POA_MEASURE6,  --Current Amount At PO Price
     POA_MEASURE7,  --Price Saving Total
     POA_MEASURE8,  --Cur amt po price total
     i.po_header_id POA_ATTRIBUTE6,  -- Header_id (hidden)
     i.po_release_id POA_ATTRIBUTE7  -- release_id (hidden)
     from
     ( select (rank() over (&ORDER_BY_CLAUSE nulls last,
         po_header_id, po_line_id, po_item_id, base_uom,
         po_release_id, org_id, POA_MEASURE2, POA_MEASURE3)) - 1 rnk,
       po_header_id,
       po_line_id,
       po_item_id,
       org_id,
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
       ( select f.po_header_id,
         f.po_line_id,
         f.po_item_id,
         f.base_uom,
         f.po_release_id,
         f.org_id,
         sum(f.quantity) POA_MEASURE1,
         nvl(f.pip_amt_' || l_cur_suffix || '/f.pip_quantity, cip.purchase_amt_' || l_cur_suffix || '/cip.quantity) POA_MEASURE2,
         f.purchase_amt_' || l_cur_suffix || '/f.quantity POA_MEASURE3,
         ((nvl(f.pip_amt_' || l_cur_suffix || '/f.pip_quantity, cip.purchase_amt_' || l_cur_suffix || '/cip.quantity))-(
         f.purchase_amt_' || l_cur_suffix || '/f.quantity)) POA_MEASURE4,
         sum(f.quantity * (nvl(f.pip_amt_' || l_cur_suffix || '/f.pip_quantity, cip.purchase_amt_' || l_cur_suffix || '/cip.quantity) - f.purchase_amt_' || l_cur_suffix || '/f.quantity)) POA_MEASURE5,
         sum(f.purchase_amt_' || l_cur_suffix || ') POA_MEASURE6,
         sum(sum(f.quantity * (nvl(f.pip_amt_' || l_cur_suffix || '/f.pip_quantity, cip.purchase_amt_' || l_cur_suffix || '/cip.quantity) - f.purchase_amt_' || l_cur_suffix || '/f.quantity))) over () POA_MEASURE7,
         sum(sum(f.purchase_amt_' || l_cur_suffix || ')) over () POA_MEASURE8
         from  poa_bm_item_o_mv cip,
         ( select /*+ NO_MERGE */ fact.po_header_id,
           fact.po_line_id,
           fact.po_item_id,
           fact.base_uom,
           fact.po_release_id,
           fact.org_id,
           fact.ent_year_id,
           fact.pip_amt_b,
           fact.pip_amt_g,
           fact.pip_amt_sg,
           fact.purchase_amt_b,
           fact.purchase_amt_g,
           fact.purchase_amt_sg,
           fact.quantity,
           fact.pip_quantity
           from poa_pqc_bs_j2_mv fact
      ' || l_in_join_tables || '
           where fact.approved_date between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE
           and fact.complex_work_flag = ''N''
           and fact.consigned_code <> 1
           and fact.order_type = ''QUANTITY''
      ' || l_where_clause;
    if(l_sec_context = 'COMP')then
      l_query := l_query || '
           and fact.company_id = com.child_company_id
           and fact.cost_center_id = cc.child_cc_id'||fnd_global.newline;
    end if;
    l_query :=l_query || '
         ) f
         where f.ent_year_id = cip.ent_year_id
         and   f.org_id = cip.org_id
         and   f.po_item_id = cip.po_item_id
         and   f.base_uom = cip.base_uom
         group by f.po_header_id, f.po_line_id, f.po_item_id, f.base_uom, f.po_release_id, f.org_id,
         nvl(f.pip_amt_' || (case l_cur_suffix when 'b' then 'g' else l_cur_suffix end) || '/f.pip_quantity, cip.purchase_amt_' || (case l_cur_suffix when 'b' then 'g' else l_cur_suffix end) || '/cip.quantity),
         nvl(f.pip_amt_b/f.pip_quantity, cip.purchase_amt_b/cip.quantity), f.purchase_amt_' || (case l_cur_suffix when 'b' then 'g' else l_cur_suffix end) || '/f.quantity,  f.purchase_amt_b/f.quantity
       )
       where ' || l_filter_where ||'
     ) i,
     po_headers_all poh,
     po_lines_all pol,
     po_releases_all rel,
     poa_items_v item,
     mtl_units_of_measure_vl uom,
     hr_all_organization_units_vl poorg
     where i.po_header_id = poh.po_header_id
     and i.po_line_id = pol.po_line_id
     and i.po_item_id = item.id
     and i.base_uom = uom.unit_of_measure
     and i.org_id = poorg.organization_id
     and i.po_release_id = rel.po_release_id (+)
     and (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
     ORDER BY rnk';

     x_custom_sql := l_query;
     poa_dbi_util_pkg.get_custom_status_binds(x_custom_output);
     if(l_sec_context = 'COMP')then
       poa_dbi_sutil_pkg.bind_com_cc_values(x_custom_output, p_param);
     end if;
  end;


  PROCEDURE trend_sql(p_param             IN          BIS_PMV_PAGE_PARAMETER_TBL
                   ,x_custom_sql        OUT NOCOPY  VARCHAR2
                   ,x_custom_output     OUT NOCOPY  BIS_QUERY_ATTRIBUTES_TBL)
  IS
    l_query             varchar2(20000);
    l_view_by           varchar2(120);
    l_view_by_col       varchar2(120);
    l_as_of_date        date;
    l_prev_as_of_date   date;
    l_xtd               varchar2(10);
    l_comparison_type   varchar2(1) := 'Y';
    l_nested_pattern    number;
    l_cur_suffix        varchar2(2);
    l_col_tbl           poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl          poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_in_join_tbl       poa_dbi_util_pkg.poa_dbi_in_join_tbl;
    l_in_join_tbl2      poa_dbi_util_pkg.poa_dbi_in_join_tbl;
    l_mv                varchar2(30);
    l_mv2               varchar2(30);
    l_where_clause      varchar2(2000);
    l_where_clause2     varchar2(2000);
    l_view_by_value     varchar2(100);
    l_cal_tbl           varchar2(30);
    l_rec_type          number;
    l_custom_rec        bis_query_attributes;
    l_in_join_tables    varchar2(1000) := '';
    l_in_join_tables2   varchar2(1000) := '';
    l_adjust1           varchar2(100);
    l_adjust2           varchar2(100);
    l_curr_start        date;
    l_curr_end          date;
    l_prior_start       date;
    l_prior_end         date;
    l_cur_month_start   date;
    l_cur_month_end     date;
    l_cur_where_clause  varchar2(2000);
    l_prev_where_clause varchar2(2000);
    l_record_type1      number;
    l_record_type2      number;
    l_sec_context       varchar2(10);
    l_use_only_agg_mv   varchar2(1);
  BEGIN

    /* sets up calls to  ("fii_msg.get_curr_label") for col labels */
    /*fii_gl_util_pkg.reset_globals;*/
    poa_dbi_sutil_pkg.get_parameters(p_param);

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
        p_mv_set             => 'PQC');
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
        p_trend              => 'Y',
        p_func_area          => 'PO',
        p_version            => '8.0',
        p_role               => 'COM',
        p_mv_set             => 'PQCA');

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
          p_mv_set             => 'PQCB');
       end if;
     end if;

    IF l_xtd = 'YTD' THEN
      l_adjust1     := NULL;
      l_adjust2     := NULL;
      l_curr_start  := fii_time_api.ent_cyr_start(l_as_of_date);
      l_curr_end    := fii_time_api.ent_cyr_end(l_as_of_date);
      l_prior_start := fii_time_api.ent_cyr_start(l_prev_as_of_date);
      l_prior_end   := fii_time_api.ent_cyr_end(l_prev_as_of_date);
      l_record_type1 := 119;
      l_record_type2 := 23;
    ELSIF l_xtd = 'QTD' THEN
      l_adjust1     := ':POA_CURR_START-:POA_CURR_END';
      l_adjust2     := ':POA_PRIOR_START-:POA_PRIOR_END';
      l_curr_start  := fii_time_api.ent_cqtr_start(l_as_of_date);
      l_curr_end    := fii_time_api.ent_cqtr_end(l_as_of_date);
      l_prior_start := fii_time_api.ent_cqtr_start(l_prev_as_of_date);
      l_prior_end   := fii_time_api.ent_cqtr_end(l_prev_as_of_date);
      l_record_type1 := 11;
      l_record_type2 := 1;
    ELSIF l_xtd = 'MTD' THEN
      l_adjust1     := '1';
      l_adjust2     := '1';
      l_curr_start  := fii_time_api.ent_cper_start(l_as_of_date);
      l_curr_end    := fii_time_api.ent_cper_end(l_as_of_date);
      l_prior_start := fii_time_api.ent_cper_start(l_prev_as_of_date);
      l_prior_end   := fii_time_api.ent_cper_end(l_prev_as_of_date);
      l_record_type1 := 11;
      l_record_type2 := 1;
    ELSE -- l_period_type = 'FII_TIME_WEEK'
      l_adjust1     := '1';
      l_adjust2     := '1';
      l_curr_start  := fii_time_api.cwk_start(l_as_of_date);
      l_curr_end    := fii_time_api.cwk_end(l_as_of_date);
      l_prior_start := fii_time_api.cwk_start(l_prev_as_of_date);
      l_prior_end   := fii_time_api.cwk_end(l_prev_as_of_date);
      l_record_type1 := 11;
      l_record_type2 := 1;
    END IF;

    IF(l_in_join_tbl is not null) then
      FOR i in 1 .. l_in_join_tbl.COUNT LOOP
        l_in_join_tables := l_in_join_tables || ', ' ||  l_in_join_tbl(i).table_name || ' ' || l_in_join_tbl(i).table_alias;
      END LOOP;
    END IF;

    if(l_in_join_tbl2 is not null) then
      for i in 1 .. l_in_join_tbl2.count loop
        l_in_join_tables2 := l_in_join_tables2 || ', ' ||  l_in_join_tbl2(i).table_name || ' ' || l_in_join_tbl2(i).table_alias;
      end loop;
    end if;

    l_cur_where_clause :=
      '(
          &BIS_CURRENT_ASOF_DATE
          BETWEEN cal.start_date AND cal.end_date
          OR cal.end_date BETWEEN :POA_CURR_START
          AND &BIS_CURRENT_ASOF_DATE
      )
      AND n.report_date BETWEEN  :POA_CURR_START
      AND &BIS_CURRENT_ASOF_DATE
      AND n.report_date = least(cal.end_date, &BIS_CURRENT_ASOF_DATE
      )
      AND
      (
          CASE
              WHEN cal.start_date <  :POA_CURR_START
              THEN bitand(n.record_type_id, ' || l_record_type1 || ')
              ELSE bitand(n.record_type_id, ' || l_record_type2 || ')
          END
      )
      = n.record_type_id
      AND fact.time_id = n.time_id
    ';

    l_prev_where_clause :=
'    (
          :POA_PRIOR_END
          BETWEEN cal.start_date AND cal.end_date
          OR cal.end_date BETWEEN :POA_PRIOR_START
          AND :POA_PRIOR_END
      )
      AND n.report_date BETWEEN :POA_PRIOR_START
      AND :POA_PRIOR_END
      AND n.report_date = least(cal.end_date, :POA_PRIOR_END
      )
      AND
      (
          CASE
              WHEN cal.start_date < :POA_PRIOR_START
              THEN bitand(n.record_type_id, ' || l_record_type1 ||')
              ELSE bitand(n.record_type_id, ' || l_record_type2 ||')
          END
      )
      = n.record_type_id
      AND fact.time_id = n.time_id
';

    if(l_xtd='YTD') then
      l_query := '
    select VIEWBY,
    CASE WHEN start_date > &BIS_CURRENT_ASOF_DATE
    THEN to_number(NULL)
    ELSE c_cumulative_ps_amt END    POA_MEASURE1,
    p_cumulative_ps_amt POA_MEASURE2,
    CASE WHEN start_date >= &BIS_CURRENT_ASOF_DATE
    THEN to_number(NULL)
    ELSE c_ps_amt END    POA_MEASURE3,
    p_ps_amt POA_MEASURE4
    from
    ( select month_name VIEWBY,
      sum(ent_period_id) period_id,
      max(start_date) start_date,
      sum(p_cumulative_ps_amt)    p_cumulative_ps_amt,
      sum(c_cumulative_ps_amt)   c_cumulative_ps_amt,
      sum(p_ps_amt)    p_ps_amt,
      sum(c_ps_amt)   c_ps_amt
      from
      (
        ( select
          substr(cal.name,1,3) month_name,
          ent_period_id,
          cal.start_date,
          c_ps_amt,
          sum(nvl(c_ps_amt,0)) over ( ORDER BY ent_period_id ROWS UNBOUNDED PRECEDING) c_cumulative_ps_amt,
          null p_ps_amt,
          null p_cumulative_ps_amt
          from
          ( SELECT
            cal.start_date,
            sum(pbpcqco_amt_' || l_cur_suffix || ' - purchase_amt_' || l_cur_suffix || ') c_ps_amt
            FROM ' || l_mv || ' fact,
            FII_TIME_ENT_PERIOD   cal,
            fii_time_rpt_struct_v n
            ' || l_in_join_tables || '
            WHERE
            ' || l_cur_where_clause || l_where_clause || '
            GROUP BY  cal.start_date,cal.end_date
          ) iset,
          FII_TIME_ENT_PERIOD cal
          where cal.start_date = iset.start_date(+)
          AND cal.start_date <= :POA_CURR_END
          AND  cal.end_date   >= :POA_CURR_START
        )
        UNION ALL
        ( select
          substr(cal.name,1,3) month_name,
          null ent_period_id,
          null start_date,
          null c_ps_amt,
          null c_cumulative_ps_amt,
          p_ps_amt,
          sum(nvl(p_ps_amt,0)) over ( ORDER BY ent_period_id ROWS UNBOUNDED PRECEDING) p_cumulative_ps_amt
          from
          ( SELECT
            cal.start_date,
            sum(pbpcqco_amt_' || l_cur_suffix || ' - purchase_amt_' || l_cur_suffix || ') p_ps_amt
            FROM ' || l_mv || ' fact,
            FII_TIME_ENT_PERIOD cal,
            fii_time_rpt_struct_v n
            ' || l_in_join_tables || '
            WHERE
            ' ||    l_prev_where_clause || l_where_clause || '
            GROUP BY cal.start_date,cal.end_date
          ) iset,
          FII_TIME_ENT_PERIOD cal
          where cal.start_date = iset.start_date(+)
          AND cal.start_date <= :POA_PRIOR_END
          AND cal.end_date   >= :POA_PRIOR_START
        )';
      if(l_use_only_agg_mv = 'N') then
        l_query := l_query ||'
       UNION ALL
       ( select
          substr(cal.name,1,3) month_name,
          ent_period_id,
          cal.start_date,
          c_ps_amt,
          sum(nvl(c_ps_amt,0)) over ( ORDER BY ent_period_id ROWS UNBOUNDED PRECEDING) c_cumulative_ps_amt,
          null p_ps_amt,
          null p_cumulative_ps_amt
          from
          ( SELECT
            cal.start_date,
            sum(pbpcqco_amt_' || l_cur_suffix || ' - purchase_amt_' || l_cur_suffix || ') c_ps_amt
            FROM ' || l_mv2 || ' fact,
            FII_TIME_ENT_PERIOD   cal,
            fii_time_rpt_struct_v n
            ' || l_in_join_tables2 || '
            WHERE
            ' || l_cur_where_clause || l_where_clause2 || '
            GROUP BY  cal.start_date,cal.end_date
          ) iset,
          FII_TIME_ENT_PERIOD cal
          where cal.start_date = iset.start_date(+)
          AND cal.start_date <= :POA_CURR_END
          AND  cal.end_date   >= :POA_CURR_START
        )
        UNION ALL
        ( select
          substr(cal.name,1,3) month_name,
          null ent_period_id,
          null start_date,
          null c_ps_amt,
          null c_cumulative_ps_amt,
          p_ps_amt,
          sum(nvl(p_ps_amt,0)) over ( ORDER BY ent_period_id ROWS UNBOUNDED PRECEDING) p_cumulative_ps_amt
          from
          ( SELECT
            cal.start_date,
            sum(pbpcqco_amt_' || l_cur_suffix || ' - purchase_amt_' || l_cur_suffix || ') p_ps_amt
            FROM ' || l_mv2 || ' fact,
            FII_TIME_ENT_PERIOD cal,
            fii_time_rpt_struct_v n
            ' || l_in_join_tables2 || '
            WHERE
            ' ||    l_prev_where_clause || l_where_clause2 || '
            GROUP BY cal.start_date,cal.end_date
          ) iset,
          FII_TIME_ENT_PERIOD cal
          where cal.start_date = iset.start_date(+)
          AND cal.start_date <= :POA_PRIOR_END
          AND cal.end_date   >= :POA_PRIOR_START
        )';
      end if; /* l_use_only_agg_mv = 'N' */
        l_query := l_query ||
     ')
      group by month_name
      order by period_id
    )';
    ELSE --Quarter Week or Month
      l_query := '
    select days VIEWBY,
    sum(DECODE(SIGN(report_date - &BIS_CURRENT_ASOF_DATE),
    1, NULL,
    decode(SIGN(:POA_CURR_START-report_date),1,NULL,c_cumulative_ps_amt)))
    POA_MEASURE1,
    SUM(DECODE(SIGN(report_date - :POA_PRIOR_END),
    1, NULL, p_cumulative_ps_amt))     POA_MEASURE2,
    sum(DECODE(SIGN(report_date - &BIS_CURRENT_ASOF_DATE),
    1, NULL,
    decode(SIGN(:POA_CURR_START-report_date),1,NULL,nvl(c_ps_amt,0))))
    POA_MEASURE3,
    SUM(DECODE(SIGN(report_date - :POA_PRIOR_END),
    1, NULL, nvl(p_ps_amt,0)))     POA_MEASURE4
    from
    (
      ( select
        cal.report_date -  :POA_CURR_START + to_number('
        || l_adjust1 || ') days,
        report_date,
        c_ps_amt,
        sum(nvl(c_ps_amt,0)) over (
        ORDER BY
        (cal.report_date -  :POA_CURR_START + to_number('
        || l_adjust1 || '))
        ROWS UNBOUNDED PRECEDING) c_cumulative_ps_amt,
        null p_ps_amt,
        null p_cumulative_ps_amt
        from
        ( SELECT
          cal.start_date,
          cal.end_date,
          sum(pbpcqco_amt_' || l_cur_suffix || ' - purchase_amt_' || l_cur_suffix || ') c_ps_amt
          FROM ' || l_mv || ' fact,
          fii_time_day cal,
          fii_time_rpt_struct_v n
          ' || l_in_join_tables || '
          WHERE
          ' || l_cur_where_clause || l_where_clause || '
          GROUP BY  cal.start_date,cal.end_date
        ) iset, fii_time_day cal
        where cal.start_date = iset.start_date(+)
        AND cal.start_date <= :POA_CURR_END
        AND cal.end_date   >= :POA_CURR_START
      )
      UNION ALL
      ( select
        cal.report_date -  :POA_PRIOR_START + to_number('|| l_adjust2 || ') days,
        report_date,
        null c_ps_amt,
        null c_cumulative_ps_amt,
        p_ps_amt,
        sum(nvl(p_ps_amt,0)) over (
        ORDER BY
           cal.report_date - :POA_PRIOR_START + to_number('||l_adjust2||')
        ROWS UNBOUNDED PRECEDING) p_cumulative_ps_amt
        from
        ( SELECT
          cal.start_date,
          cal.end_date,
          sum(pbpcqco_amt_' || l_cur_suffix || ' - purchase_amt_' || l_cur_suffix || ') p_ps_amt
          FROM ' || l_mv || ' fact,
          fii_time_day cal,
          fii_time_rpt_struct_v n
          ' || l_in_join_tables || '
          WHERE
          ' || l_prev_where_clause || l_where_clause || '
          GROUP BY cal.start_date,cal.end_date
        ) iset, fii_time_day cal
        where cal.start_date = iset.start_date(+)
        AND cal.start_date <= :POA_PRIOR_END
        AND cal.end_date   >= :POA_PRIOR_START
      )';
      if(l_use_only_agg_mv = 'N') then
        l_query := l_query ||'
     UNION ALL
     ( select
        cal.report_date -  :POA_CURR_START + to_number('
        || l_adjust1 || ') days,
        report_date,
        c_ps_amt,
        sum(nvl(c_ps_amt,0)) over (
        ORDER BY
        (cal.report_date -  :POA_CURR_START + to_number('
        || l_adjust1 || '))
        ROWS UNBOUNDED PRECEDING) c_cumulative_ps_amt,
        null p_ps_amt,
        null p_cumulative_ps_amt
        from
        ( SELECT
          cal.start_date,
          cal.end_date,
          sum(pbpcqco_amt_' || l_cur_suffix || ' - purchase_amt_' || l_cur_suffix || ') c_ps_amt
          FROM ' || l_mv2 || ' fact,
          fii_time_day cal,
          fii_time_rpt_struct_v n
          ' || l_in_join_tables2 || '
          WHERE
          ' || l_cur_where_clause || l_where_clause2 || '
          GROUP BY  cal.start_date,cal.end_date
        ) iset, fii_time_day cal
        where cal.start_date = iset.start_date(+)
        AND cal.start_date <= :POA_CURR_END
        AND cal.end_date   >= :POA_CURR_START
      )
      UNION ALL
      ( select
        cal.report_date -  :POA_PRIOR_START + to_number('|| l_adjust2 || ') days,
        report_date,
        null c_ps_amt,
        null c_cumulative_ps_amt,
        p_ps_amt,
        sum(nvl(p_ps_amt,0)) over (
        ORDER BY
           cal.report_date - :POA_PRIOR_START + to_number('||l_adjust2||')
        ROWS UNBOUNDED PRECEDING) p_cumulative_ps_amt
        from
        ( SELECT
          cal.start_date,
          cal.end_date,
          sum(pbpcqco_amt_' || l_cur_suffix || ' - purchase_amt_' || l_cur_suffix || ') p_ps_amt
          FROM ' || l_mv2 || ' fact,
          fii_time_day cal,
          fii_time_rpt_struct_v n
          ' || l_in_join_tables2 || '
          WHERE
          ' || l_prev_where_clause || l_where_clause2 || '
          GROUP BY cal.start_date,cal.end_date
        ) iset, fii_time_day cal
        where cal.start_date = iset.start_date(+)
        AND cal.start_date <= :POA_PRIOR_END
        AND cal.end_date   >= :POA_PRIOR_START
      )';
      end if; /* l_use_only_agg_mv = 'N' */
   l_query := l_query || ')
    group by days
    order by days';
    end if; /* l_xtd='YTD' */
    x_custom_sql := l_query;

    l_custom_rec := BIS_PMV_PARAMETERS_PUB.INITIALIZE_QUERY_TYPE;

    l_custom_rec.attribute_name := BIS_PMV_PARAMETERS_PUB.VIEW_BY_VALUE;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.View_By_Type;
    if(l_xtd = 'YTD') then
      l_custom_rec.attribute_value := 'TIME+FII_TIME_ENT_PERIOD';
    elsif(l_xtd = 'QTD') then
      l_custom_rec.attribute_value := 'TIME+FII_TIME_DAY';
    elsif(l_xtd = 'MTD') then
      l_custom_rec.attribute_value := 'TIME+FII_TIME_DAY';
    else
      l_custom_rec.attribute_value := 'TIME+FII_TIME_DAY';
    end if;
    x_custom_output.EXTEND;
    x_custom_output(x_custom_output.COUNT) := l_custom_rec;

    l_custom_rec.attribute_name := '&FND_USER_ID';
    l_custom_rec.attribute_value := poa_dbi_util_pkg.get_fnd_user_profile;
    l_custom_rec.attribute_type := BIS_PMV_PARAMETERS_PUB.BIND_TYPE;
    l_custom_rec.attribute_data_type := BIS_PMV_PARAMETERS_PUB.INTEGER_BIND;
    x_custom_output.EXTEND;
    x_custom_output(x_custom_output.COUNT) := l_custom_rec;

    l_custom_rec.attribute_name := ':POA_CURR_START';
    l_custom_rec.attribute_value := to_char(l_curr_start,'DD-MM-YYYY');
    l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.date_bind;
    x_custom_output.extend;
    x_custom_output(x_custom_output.COUNT) := l_custom_rec;

    l_custom_rec.attribute_name := ':POA_CURR_END';
    l_custom_rec.attribute_value := to_char(l_curr_end,'DD-MM-YYYY');
    l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.date_bind;
    x_custom_output.extend;
    x_custom_output(x_custom_output.COUNT) := l_custom_rec;

    l_custom_rec.attribute_name := ':POA_PRIOR_START';
    l_custom_rec.attribute_value := to_char(l_prior_start,'DD-MM-YYYY');
    l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.date_bind;
    x_custom_output.extend;
    x_custom_output(x_custom_output.COUNT) := l_custom_rec;

    l_custom_rec.attribute_name := ':POA_PRIOR_END';
    l_custom_rec.attribute_value := to_char(l_prior_end,'DD-MM-YYYY');
    l_custom_Rec.attribute_type := bis_pmv_parameters_pub.bind_type;
    l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.date_bind;
    x_custom_output.extend;
    x_custom_output(x_custom_output.COUNT) := l_custom_rec;

  END trend_sql;

END POA_DBI_PQC_PKG;

/
