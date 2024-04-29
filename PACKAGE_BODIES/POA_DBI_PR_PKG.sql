--------------------------------------------------------
--  DDL for Package Body POA_DBI_PR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."POA_DBI_PR_PKG" 
/* $Header: poadbiprb.pls 120.2 2006/08/11 07:48:58 sdiwakar noship $ */
as
  /*forward declarations of local functions*/
  function get_status_sel_clause(
             p_view_by_dim in varchar2,
             p_view_by_col in varchar2
           ) return varchar2;

  function get_status_sum_sel_clause(
             p_view_by_dim in varchar2,
             p_view_by_col in varchar2
           ) return varchar2;

  function get_amt_sel_clause(
             p_view_by_dim in varchar2,
             p_view_by_col in varchar2,
             p_bucket_rec in BIS_BUCKET_PUB.BIS_BUCKET_REC_TYPE
           )  return VARCHAR2;

  function get_age_sel_clause(
             p_view_by_dim in varchar2,
             p_view_by_col in varchar2,
             p_bucket_rec in BIS_BUCKET_PUB.BIS_BUCKET_REC_TYPE
           )  return VARCHAR2;

  function get_amt_trend_sel_clause return varchar2;
  function get_age_trend_sel_clause return varchar2;
  function get_au_trend_sel_clause return varchar2;
  function get_status_filter_where(p_view_by in VARCHAR2) return varchar2;
  function get_summary_filter_where(p_view_by in VARCHAR2) return varchar2;
  function get_amt_filter_where(p_view_by in VARCHAR2) return varchar2;
  function get_req_age_filter_where(p_view_by in VARCHAR2) return varchar2;
  /*public procedure definitions*/

  procedure status_sql(p_param in bis_pmv_page_parameter_tbl
                       ,x_custom_sql out nocopy varchar2
                       ,x_custom_output out nocopy bis_query_attributes_tbl)
  is
    l_col_tbl             poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl            poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_query               varchar2(10000);
    l_view_by             varchar2(120);
    l_view_by_col         varchar2(120);
    l_as_of_date          date;
    l_prev_as_of_date     date;
    l_xtd                 varchar2(10);
    l_comparison_type     varchar2(1);
    l_nested_pattern      number;
    l_cur_suffix          varchar2(2);
    l_in_join_tbl         poa_dbi_util_pkg.poa_dbi_in_join_tbl;
    l_join_rec            poa_dbi_util_pkg.poa_dbi_join_rec;
    l_where_clause        varchar2(2000);
    l_mv                  varchar2(30);
    l_view_by_value       varchar2(30);
    err_msg               varchar2(100);
    err_cde               number;
  begin
    l_comparison_type := 'Y';
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
    l_col_tbl :=  poa_dbi_util_pkg.POA_DBI_COL_TBL();

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
					,x_custom_output
                                        ,p_trend => 'N'
                                        ,p_func_area => 'PO'
                                        ,p_version => '7.1'
                                        ,p_role => 'VPP'
                                        ,p_mv_set => 'REQMP');

    poa_dbi_util_pkg.add_column(l_col_tbl
                    , 'processed_cnt_' || l_cur_suffix
                    , 'proc_cnt'
                    , p_grand_total => 'Y'
                    , p_prior_code => poa_dbi_util_pkg.both_priors
                    , p_to_date_type => 'RLX');

    poa_dbi_util_pkg.add_column(l_col_tbl
                    , 'processed_man_cnt_' || l_cur_suffix
                    , 'man_lines_cnt'
                    , p_grand_total => 'Y'
                    , p_prior_code => poa_dbi_util_pkg.both_priors
                    , p_to_date_type => 'RLX');

    poa_dbi_util_pkg.add_column(l_col_tbl
                    , 'processed_amt_'  || l_cur_suffix
                    , 'proc_amt'
                    , p_grand_total => 'Y'
                    , p_prior_code => poa_dbi_util_pkg.both_priors
                    , p_to_date_type => 'RLX');

    poa_dbi_util_pkg.add_column(l_col_tbl
                    , 'days_to_process'
                    , 'proc_days'
                    , p_grand_total => 'Y'
                    , p_prior_code => poa_dbi_util_pkg.both_priors
                    , p_to_date_type => 'RLX');

 if(l_view_by = 'ITEM+POA_ITEMS') then
    poa_dbi_util_pkg.add_column(l_col_tbl
                               ,'processed_qty'
                               ,'proc_qty'
                   , p_grand_total => 'N'
                  , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
                  , p_to_date_type => 'RLX');
end if;

    l_query := get_status_sel_clause(l_view_by, l_view_by_col) || ' from ';
    l_query := l_query ||
                 poa_dbi_template_pkg.status_sql(
                                        l_mv,
                                        l_where_clause,
                                        l_join_tbl,
                                        p_use_windowing => 'Y',
                                        p_col_name => l_col_tbl,
                                        p_use_grpid => 'N',
                                        p_filter_where => get_status_filter_where(l_view_by),
                                        p_in_join_tables => l_in_join_tbl
                                      );

    x_custom_sql := l_query;

  exception
   when others then
      err_msg := substr(sqlerrm,1,400);
   end;

  function get_status_sel_clause(p_view_by_dim in varchar2
                                ,p_view_by_col in varchar2)
  return varchar2 is
    l_sel_clause varchar2(6000);
  begin
    l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim
                                                              ,'PO'
                                                              ,'7.1');

    if(p_view_by_dim = 'ITEM+POA_ITEMS')
    then
      l_sel_clause := l_sel_clause || fnd_global.newline ||  '
      v.description POA_ATTRIBUTE1,                --Description
      v2.description POA_ATTRIBUTE2,              --UOM
      oset.POA_MEASURE10 POA_MEASURE10,        --Unfulfilled Quantity'|| fnd_global.newline;

    else
      l_sel_clause :=  l_sel_clause || fnd_global.newline ||  '
    null POA_ATTRIBUTE1,        --Description
    null POA_ATTRIBUTE2,        --UOM
    null POA_MEASURE10,        --Quantity' || fnd_global.newline;
    end if;

    l_sel_clause := l_sel_clause ||
'    oset.POA_MEASURE1  POA_MEASURE1,  -- Processed Lines
    oset.POA_MEASURE11 POA_MEASURE11,  -- Processed Lines Prior
    oset.POA_PERCENT1  POA_PERCENT1,  -- Change
    oset.POA_MEASURE2  POA_MEASURE2,  -- Manual Lines
    oset.POA_PERCENT2  POA_PERCENT2,  -- Manual Lines Rate
    oset.POA_PERCENT3  POA_PERCENT3,  -- Change
    oset.POA_MEASURE3  POA_MEASURE3,  -- Processed Amount
    oset.POA_MEASURE12 POA_MEASURE12, -- Processed Amount Prior
    oset.POA_PERCENT4  POA_PERCENT4,  -- Change
    oset.POA_MEASURE4  POA_MEASURE4,  -- Average Age (Days)
    oset.POA_MEASURE13 POA_MEASURE13, -- Average Age (Days) Prior
    oset.POA_PERCENT5  POA_PERCENT5,  -- Change
    oset.POA_MEASURE6  POA_MEASURE6,  -- Total Processed Lines
    oset.POA_MEASURE14  POA_MEASURE14,  -- Total Processed Lines Prior
    oset.POA_PERCENT6  POA_PERCENT6,  -- Total Change
    oset.POA_MEASURE7  POA_MEASURE7,  -- Total Manual Lines
    oset.POA_PERCENT7  POA_PERCENT7,  -- Total Manual Lines Rate
    oset.POA_PERCENT8  POA_PERCENT8,  -- Total Change
    oset.POA_MEASURE8  POA_MEASURE8,  -- Total Processed Amount
    oset.POA_MEASURE15  POA_MEASURE15,  -- Total Processed Amount Prior
    oset.POA_PERCENT9  POA_PERCENT9,  -- Total Change
    oset.POA_MEASURE9  POA_MEASURE9,  -- Total Average Age (Days)
    oset.POA_MEASURE16  POA_MEASURE16,  -- Total Average Age (Days) Prior
    oset.POA_PERCENT10 POA_PERCENT10, -- Total Change
    oset.POA_MEASURE2 POA_ATTRIBUTE5,  -- Manual (Graph 1)
    oset.POA_ATTRIBUTE6 POA_ATTRIBUTE6
    from
    (select (rank() over(&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col;

    if(p_view_by_dim = 'ITEM+POA_ITEMS')
    then
      l_sel_clause := l_sel_clause || ', base_uom';
    end if;

    l_sel_clause := l_sel_clause || ')) - 1 rnk,' || p_view_by_col;
    if(p_view_by_dim = 'ITEM+POA_ITEMS')
    then
      l_sel_clause := l_sel_clause || ',
                         base_uom,
                         POA_MEASURE10';
    end if;

    l_sel_clause := l_sel_clause || ',
    POA_MEASURE1,
    POA_MEASURE11,
    POA_PERCENT1,
    POA_MEASURE2,
    POA_PERCENT2,
    POA_PERCENT3,
    POA_MEASURE3,
    POA_MEASURE12,
    POA_PERCENT4,
    POA_MEASURE4,
    POA_MEASURE13,
    POA_PERCENT5,
    POA_MEASURE6,
    POA_PERCENT6,
    POA_MEASURE14,
    POA_MEASURE7,
    POA_PERCENT7,
    POA_PERCENT8,
    POA_MEASURE8,
    POA_MEASURE15,
    POA_PERCENT9,
    POA_MEASURE9,
    POA_MEASURE16,
    POA_PERCENT10,
    POA_ATTRIBUTE6
    from   (select ' || p_view_by_col || ',' || p_view_by_col || ' VIEWBY,' || p_view_by_col || ' VIEWBYID, ';

    if(p_view_by_dim = 'ITEM+POA_ITEMS')
    then
      l_sel_clause := l_sel_clause || ' base_uom,
                         decode(base_uom,null,to_number(null),nvl(c_proc_qty,0)) POA_MEASURE10, ';
    end if;

    l_sel_clause := l_sel_clause || '
         nvl(c_proc_cnt, 0) POA_MEASURE1,
         nvl(p_proc_cnt, 0) POA_MEASURE11,
    ' || poa_dbi_util_pkg.change_clause('c_proc_cnt','p_proc_cnt','NP') || ' POA_PERCENT1,
        nvl(c_man_lines_cnt,0) POA_MEASURE2,
     ' || poa_dbi_util_pkg.rate_clause('c_man_lines_cnt','c_proc_cnt', 'P') || ' POA_PERCENT2,
  ' || poa_dbi_util_pkg.change_clause(poa_dbi_util_pkg.rate_clause('c_man_lines_cnt','c_proc_cnt','P'),poa_dbi_util_pkg.rate_clause('p_man_lines_cnt','p_proc_cnt', 'P'),'P') || ' POA_PERCENT3,
         nvl(c_proc_amt,0) POA_MEASURE3,
         nvl(p_proc_amt,0) POA_MEASURE12,
    ' || poa_dbi_util_pkg.change_clause('c_proc_amt','p_proc_amt', 'NP') || ' POA_PERCENT4,
     ' || poa_dbi_util_pkg.rate_clause('c_proc_days','c_proc_cnt', 'NP') || ' POA_MEASURE4,
     ' || poa_dbi_util_pkg.rate_clause('p_proc_days','p_proc_cnt', 'NP') || ' POA_MEASURE13,
' || poa_dbi_util_pkg.change_clause(poa_dbi_util_pkg.rate_clause('c_proc_days','c_proc_cnt', 'NP'),poa_dbi_util_pkg.rate_clause('p_proc_days','p_proc_cnt', 'NP'),'P') || ' POA_PERCENT5,
        nvl(c_proc_cnt_total,0) POA_MEASURE6,
        nvl(p_proc_cnt_total,0) POA_MEASURE14,
    ' || poa_dbi_util_pkg.change_clause('c_proc_cnt_total','p_proc_cnt_total', 'NP') || ' POA_PERCENT6,
        nvl(c_man_lines_cnt_total,0) POA_MEASURE7,
     ' || poa_dbi_util_pkg.rate_clause('c_man_lines_cnt_total','c_proc_cnt_total', 'P') || ' POA_PERCENT7,
  ' || poa_dbi_util_pkg.change_clause(
         poa_dbi_util_pkg.rate_clause('c_man_lines_cnt_total','c_proc_cnt_total', 'P'),
         poa_dbi_util_pkg.rate_clause('p_man_lines_cnt_total','p_proc_cnt_total', 'P'),
         'P'
       ) || ' POA_PERCENT8,
        nvl(c_proc_amt_total,0) POA_MEASURE8,
        nvl(p_proc_amt_total,0) POA_MEASURE15,
    ' || poa_dbi_util_pkg.change_clause('c_proc_amt_total','p_proc_amt_total', 'NP') || ' POA_PERCENT9,
             ' || poa_dbi_util_pkg.rate_clause('c_proc_days_total','c_proc_cnt_total', 'NP') || ' POA_MEASURE9,
             ' || poa_dbi_util_pkg.rate_clause('p_proc_days_total','p_proc_cnt_total', 'NP') ||' POA_MEASURE16,
    ' || poa_dbi_util_pkg.change_clause(
           poa_dbi_util_pkg.rate_clause('c_proc_days_total','c_proc_cnt_total', 'NP'),
           poa_dbi_util_pkg.rate_clause('p_proc_days_total','p_proc_cnt_total', 'NP'),
           'P'
         ) || ' POA_PERCENT10,
    nvl(c_proc_cnt,0) - nvl(c_man_lines_cnt,0) POA_ATTRIBUTE6
';

    return l_sel_clause;
  end;

 function get_status_filter_where(p_view_by in VARCHAR2) return varchar2
  is
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  begin
    l_col_tbl := poa_dbi_sutil_pkg.poa_dbi_filter_tbl();
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
    l_col_tbl(7) := 'POA_PERCENT4';
    l_col_tbl.extend;
    l_col_tbl(8) := 'POA_MEASURE4';
    l_col_tbl.extend;
    l_col_tbl(9) := 'POA_PERCENT5';

    if(p_view_by = 'ITEM+POA_ITEMS') then
     l_col_tbl.extend;
     l_col_tbl(10) := 'POA_MEASURE10';
    end if;
    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);
  end;


  procedure status_sum_sql(
              p_param in bis_pmv_page_parameter_tbl,
              x_custom_sql out nocopy varchar2,
              x_custom_output out nocopy bis_query_attributes_tbl
            )
  is
    l_col_tbl             poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl            poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_query               varchar2(10000);
    l_view_by             varchar2(120);
    l_view_by_col         varchar2(120);
    l_as_of_date          date;
    l_prev_as_of_date     date;
    l_xtd                 varchar2(10);
    l_comparison_type     varchar2(1);
    l_nested_pattern      number;
    l_cur_suffix          varchar2(2);
    l_in_join_tbl         poa_dbi_util_pkg.poa_dbi_in_join_tbl;
    l_join_rec            poa_dbi_util_pkg.poa_dbi_join_rec;
    l_where_clause        varchar2(2000);
    l_mv                  varchar2(30);
    l_view_by_value       varchar2(30);
    err_msg               varchar2(100);
    err_cde               number;
  begin
    l_comparison_type := 'Y';
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
    l_col_tbl :=  poa_dbi_util_pkg.POA_DBI_COL_TBL();

    poa_dbi_sutil_pkg.process_parameters(
                        p_param,
                        l_view_by,
                        l_view_by_col,
                        l_view_by_value,
                        l_comparison_type,
                        l_xtd,
                        l_as_of_date,
                        l_prev_as_of_date,
                        l_cur_suffix,
                        l_nested_pattern,
                        l_where_clause,
                        l_mv,
                        l_join_tbl,
                        l_in_join_tbl,
			x_custom_output,
                        p_trend => 'N',
                        p_func_area => 'PO',
                        p_version => '7.1',
                        p_role => 'VPP',
                        p_mv_set => 'REQMP'
                      );

    poa_dbi_util_pkg.add_column(
                       l_col_tbl,
                       'processed_cnt_' || l_cur_suffix,
                       'proc_cnt',
                       p_grand_total => 'Y',
                       p_prior_code => poa_dbi_util_pkg.both_priors,
                       p_to_date_type => 'RLX'
                     );

    poa_dbi_util_pkg.add_column(
                       l_col_tbl,
                       'processed_man_cnt_' || l_cur_suffix,
                       'man_lines_cnt',
                       p_grand_total => 'Y',
                       p_prior_code => poa_dbi_util_pkg.both_priors,
                       p_to_date_type => 'RLX'
                     );

    if(l_view_by = 'ITEM+POA_ITEMS')
    then
      poa_dbi_util_pkg.add_column(
                         l_col_tbl,
                         'processed_qty',
                         'proc_qty',
                         p_grand_total => 'N',
                         p_prior_code => poa_dbi_util_pkg.no_priors,
                         p_to_date_type => 'RLX'
                       );
    end if;

    l_query := get_status_sum_sel_clause(l_view_by, l_view_by_col) || ' from ';
    l_query := l_query ||
                 poa_dbi_template_pkg.status_sql(
                                        l_mv,
                                        l_where_clause,
                                        l_join_tbl,
                                        p_use_windowing => 'Y',
                                        p_col_name => l_col_tbl,
                                        p_use_grpid => 'N',
                                        p_filter_where => get_summary_filter_where(l_view_by),
                                        p_in_join_tables => l_in_join_tbl
                                      );

    x_custom_sql := l_query;

  exception
    when others then
      err_msg := substr(sqlerrm,1,400);
  end;

  function get_status_sum_sel_clause(
             p_view_by_dim in varchar2,
             p_view_by_col in varchar2
           )
  return varchar2 is
    l_sel_clause varchar2(4000);
  begin
    l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(
                                        p_view_by_dim,
                                        'PO',
                                        '7.1'
                                      );

  if(p_view_by_dim = 'ITEM+POA_ITEMS')
  then
    l_sel_clause := l_sel_clause || fnd_global.newline ||
      ' v.description POA_ATTRIBUTE1,            --Description' || fnd_global.newline ||
      ' v2.description POA_ATTRIBUTE2,           --UOM' || fnd_global.newline ||
      ' oset.POA_MEASURE10 POA_MEASURE10,        --Unfulfilled Quantity' || fnd_global.newline;
  else
    l_sel_clause :=  l_sel_clause || fnd_global.newline ||
      '  null POA_ATTRIBUTE1,        --Description' || fnd_global.newline ||
      '  null POA_ATTRIBUTE2,        --UOM' || fnd_global.newline ||
      '  null POA_MEASURE10,        --Quantity' || fnd_global.newline;

  end if;

    l_sel_clause := l_sel_clause ||
'    oset.POA_MEASURE1  POA_MEASURE1,  -- Processed Lines
    oset.POA_PERCENT1  POA_PERCENT1,  -- Change
    oset.POA_MEASURE2  POA_MEASURE2,  -- Manual Lines
    oset.POA_PERCENT2  POA_PERCENT2,  -- Manual Lines Rate
    oset.POA_PERCENT3  POA_PERCENT3,  -- Change
    oset.POA_MEASURE6  POA_MEASURE6,  -- Total Processed Lines
    oset.POA_PERCENT6  POA_PERCENT6,  -- Total Change
    oset.POA_MEASURE7  POA_MEASURE7,  -- Total Manual Lines
    oset.POA_PERCENT7  POA_PERCENT7,  -- Total Manual Lines Rate
    oset.POA_PERCENT8  POA_PERCENT8,  -- Total Change
    oset.POA_MEASURE2 POA_ATTRIBUTE5,  -- Manual (Graph 1)
    oset.POA_MEASURE4 POA_MEASURE4    -- Automated
    from
    (select (rank() over(&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col;

  if(p_view_by_dim = 'ITEM+POA_ITEMS')
  then
    l_sel_clause := l_sel_clause || ', base_uom';
  end if;

  l_sel_clause := l_sel_clause || ')) - 1 rnk,' || p_view_by_col;

  if(p_view_by_dim = 'ITEM+POA_ITEMS')
  then
    l_sel_clause := l_sel_clause || ',
                       base_uom,
                       POA_MEASURE10';
  end if;

  l_sel_clause := l_sel_clause || ',
    POA_MEASURE1,
    POA_PERCENT1,
    POA_MEASURE2,
    POA_PERCENT2,
    POA_PERCENT3,
    POA_MEASURE6,
    POA_PERCENT6,
    POA_MEASURE7,
    POA_PERCENT7,
    POA_PERCENT8,
    POA_MEASURE4
    from   (select ' || p_view_by_col || ',' || p_view_by_col || ' VIEWBY,' || p_view_by_col || ' VIEWBYID, ';

  if(p_view_by_dim = 'ITEM+POA_ITEMS')
  then
    l_sel_clause := l_sel_clause || ' base_uom,
                         decode(base_uom,null,to_number(null),nvl(c_proc_qty,0)) POA_MEASURE10, ';
  end if;

  l_sel_clause := l_sel_clause || '
      nvl(c_proc_cnt, 0) POA_MEASURE1,
      ' || poa_dbi_util_pkg.change_clause('c_proc_cnt','p_proc_cnt','NP') || ' POA_PERCENT1,
      nvl(c_man_lines_cnt,0) POA_MEASURE2,
      ' || poa_dbi_util_pkg.rate_clause('c_man_lines_cnt','c_proc_cnt','P') || ' POA_PERCENT2,
      ' || poa_dbi_util_pkg.change_clause(
                          poa_dbi_util_pkg.rate_clause('c_man_lines_cnt','c_proc_cnt','P'),
                          poa_dbi_util_pkg.rate_clause('p_man_lines_cnt','p_proc_cnt','P'),
                          'P'
                        ) || ' POA_PERCENT3,
      nvl(c_proc_cnt_total,0) POA_MEASURE6,
      ' || poa_dbi_util_pkg.change_clause('c_proc_cnt_total','p_proc_cnt_total','NP') || ' POA_PERCENT6,
      nvl(c_man_lines_cnt_total,0) POA_MEASURE7,
      ' || poa_dbi_util_pkg.rate_clause('c_man_lines_cnt_total','c_proc_cnt_total','P') || ' POA_PERCENT7,
      ' || poa_dbi_util_pkg.change_clause(
                          poa_dbi_util_pkg.rate_clause('c_man_lines_cnt_total','c_proc_cnt_total','P'),
                          poa_dbi_util_pkg.rate_clause('p_man_lines_cnt_total','p_proc_cnt_total','P'),
                          'P'
                        ) || ' POA_PERCENT8,
      nvl(c_proc_cnt,0) - nvl(c_man_lines_cnt,0) POA_MEASURE4
';
    return l_sel_clause;
  end;

  function get_summary_filter_where(p_view_by in VARCHAR2) return varchar2
  is
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  begin
    l_col_tbl := poa_dbi_sutil_pkg.poa_dbi_filter_tbl();
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

    if(p_view_by = 'ITEM+POA_ITEMS') then
     l_col_tbl.extend;
     l_col_tbl(6) := 'POA_MEASURE10';
    end if;

    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);
  end;


  /* PROCESSED REQUISITIONS AMOUNT REPORT */

  procedure amt_sql(p_param in bis_pmv_page_parameter_tbl
                       ,x_custom_sql out nocopy varchar2
                       ,x_custom_output out nocopy bis_query_attributes_tbl)
  is
    l_col_tbl             poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl            poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_query               varchar2(10000);
    l_view_by             varchar2(120);
    l_view_by_col         varchar2(120);
    l_as_of_date          date;
    l_prev_as_of_date     date;
    l_xtd                 varchar2(10);
    l_comparison_type     varchar2(1);
    l_nested_pattern      number;
    l_cur_suffix          varchar2(2);
    l_in_join_tbl         poa_dbi_util_pkg.poa_dbi_in_join_tbl;
    l_join_rec            poa_dbi_util_pkg.poa_dbi_join_rec;
    l_where_clause        varchar2(2000);
    l_mv                  varchar2(30);
    l_view_by_value       varchar2(30);
    l_bucket_rec          BIS_BUCKET_PUB.BIS_BUCKET_REC_TYPE;
    err_msg               varchar2(100);
    err_cde               number;
  begin
    l_comparison_type := 'Y';
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
    l_col_tbl :=  poa_dbi_util_pkg.POA_DBI_COL_TBL();

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
					,x_custom_output
                                        ,p_trend => 'N'
                                        ,p_func_area => 'PO'
                                        ,p_version => '7.1'
                                        ,p_role => 'VPP'
                                        ,p_mv_set => 'REQMP');


    poa_dbi_util_pkg.add_column(l_col_tbl
                    , 'processed_amt_' || l_cur_suffix
                    , 'proc_amt'
                    , p_grand_total => 'Y'
                    , p_prior_code => poa_dbi_util_pkg.both_priors
                    , p_to_date_type => 'RLX');

    poa_dbi_util_pkg.add_column(l_col_tbl
                    , 'processed_man_amt_' || l_cur_suffix
                    , 'man_amt'
                    , p_grand_total => 'Y'
                    , p_prior_code => poa_dbi_util_pkg.both_priors
                    , p_to_date_type => 'RLX');

    poa_dbi_util_pkg.add_bucket_columns(
                    p_short_name => 'POA_DBI_PR_BUCKET'
                   ,p_col_tbl => l_col_tbl
                   ,p_col_name => 'processed_amt_'|| l_cur_suffix || '_age'
                   ,p_alias_name => 'proc_amt_age'
                   ,x_bucket_rec => l_bucket_rec
                   ,p_grand_total => 'Y'
                   ,p_prior_code => poa_dbi_util_pkg.NO_PRIORS
                   ,p_to_date_type => 'RLX');

    if(l_view_by = 'ITEM+POA_ITEMS')
    then
      poa_dbi_util_pkg.add_column(l_col_tbl
                      ,'processed_qty'
                      ,'proc_qty'
                      , p_grand_total => 'N'
                      , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
                      , p_to_date_type => 'RLX');
    end if;

    l_query := get_amt_sel_clause(l_view_by, l_view_by_col, l_bucket_rec) || ' from ';
    l_query := l_query ||
                 poa_dbi_template_pkg.status_sql(
                   l_mv,
                   l_where_clause,
                   l_join_tbl,
                   p_use_windowing => 'Y',
                   p_col_name => l_col_tbl,
                   p_use_grpid => 'N',
                   p_filter_where => get_amt_filter_where(l_view_by),
                   p_in_join_tables => l_in_join_tbl);

    x_custom_sql := l_query;

  exception
   when others then
      err_msg := substr(sqlerrm,1,400);
   end;


  function get_amt_sel_clause(
             p_view_by_dim in varchar2,
             p_view_by_col in varchar2,
             p_bucket_rec in BIS_BUCKET_PUB.BIS_BUCKET_REC_TYPE
           )
  return varchar2 is
    l_sel_clause varchar2(4000);
  begin
    l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim
                                                              ,'PO'
                                                              ,'7.1');

  if(p_view_by_dim = 'ITEM+POA_ITEMS')
  then
    l_sel_clause := l_sel_clause
        || fnd_global.newline
        ||  '
    v.description POA_ATTRIBUTE1,                --Description
    v2.description POA_ATTRIBUTE2,              --UOM
    oset.POA_MEASURE10 POA_MEASURE10,        --Quantity
'|| fnd_global.newline;

  else
    l_sel_clause :=  l_sel_clause
        || fnd_global.newline
        ||  '
    null POA_ATTRIBUTE1,        --Description
    null POA_ATTRIBUTE2,        --UOM
    null POA_MEASURE10,        --Quantity'
|| fnd_global.newline;

  end if;
  l_sel_clause := l_sel_clause || fnd_global.newline ||
'    oset.POA_MEASURE1  POA_MEASURE1,  -- Processed Amount
    oset.POA_PERCENT1  POA_PERCENT1,  -- Change
    oset.POA_MEASURE2  POA_MEASURE2,  -- Manual Amount
    oset.POA_PERCENT2  POA_PERCENT2,  -- Manual Amount Rate
    oset.POA_MEASURE3  POA_MEASURE3   -- Change
        '|| poa_dbi_util_pkg.get_bucket_outer_query(
               p_bucket_rec
             , p_col_name => 'oset.POA_MEASURE4'
             , p_alias_name => 'POA_MEASURE4'
             , p_prefix => ''
             , p_suffix => ''
             , p_total_flag => 'N') ||',
    oset.POA_MEASURE5  POA_MEASURE5,  -- Total Processed Amount
    oset.POA_PERCENT3  POA_PERCENT3,  -- Total Change
    oset.POA_MEASURE6  POA_MEASURE6,  -- Total Manual Amount
    oset.POA_PERCENT4  POA_PERCENT4,  -- Total Manual Amount Rate
    oset.POA_MEASURE7  POA_MEASURE7   -- Total Change
        '|| poa_dbi_util_pkg.get_bucket_outer_query(
               p_bucket_rec
             , p_col_name => 'oset.POA_MEASURE8'
             , p_alias_name => 'POA_MEASURE8'
             , p_prefix => ''
             , p_suffix => ''
             , p_total_flag => 'N') ||'
        '|| poa_dbi_util_pkg.get_bucket_drill_url(
                               p_bucket_rec,
                               'POA_ATTRIBUTE6',
                               '''pFunctionName=POA_DBI_PR_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=1&POA_BUCKET+REQUISITION_AGING=',
                               '''',
                               p_add_bucket_num => 'Y'
                             ) || '
    from
    (select (rank() over(&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col;
 if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ', base_uom';
 end if;

l_sel_clause := l_sel_clause || ')) - 1 rnk,' || p_view_by_col;
  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ',
                       base_uom,
                       POA_MEASURE10';
  end if;

    l_sel_clause := l_sel_clause || ',
    POA_MEASURE1,
    POA_PERCENT1,
    POA_MEASURE2,
    POA_PERCENT2,
    POA_MEASURE3
    '|| poa_dbi_util_pkg.get_bucket_outer_query(
        p_bucket_rec
      , p_col_name => 'POA_MEASURE4'
      , p_alias_name => 'POA_MEASURE4'
      , p_prefix => ''
      , p_suffix => ''
      , p_total_flag => 'N') ||',
    POA_MEASURE5,
    POA_PERCENT3,
    POA_MEASURE6,
    POA_PERCENT4,
    POA_MEASURE7
    '|| poa_dbi_util_pkg.get_bucket_outer_query(
          p_bucket_rec
       , p_col_name => 'POA_MEASURE8'
        , p_alias_name => 'POA_MEASURE8'
        , p_prefix => ''
        , p_suffix => ''
        , p_total_flag => 'N') ||'
     from   (select ' || p_view_by_col || ',' || p_view_by_col || ' VIEWBY,' || p_view_by_col || ' VIEWBYID, ';
   if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ' base_uom,
                         decode(base_uom,null,to_number(null),nvl(c_proc_qty,0)) POA_MEASURE10, ';

   end if;
    l_sel_clause := l_sel_clause || '
        nvl(c_proc_amt,0) POA_MEASURE1,
        ' || poa_dbi_util_pkg.change_clause('c_proc_amt','p_proc_amt', 'NP') || ' POA_PERCENT1,
        nvl(c_man_amt,0) POA_MEASURE2,
     ' || poa_dbi_util_pkg.rate_clause('c_man_amt','c_proc_amt', 'P') || ' POA_PERCENT2,
     ' || poa_dbi_util_pkg.change_clause(
            poa_dbi_util_pkg.rate_clause('c_man_amt','c_proc_amt', 'P'),
            poa_dbi_util_pkg.rate_clause('p_man_amt','p_proc_amt', 'P'),
            'P') || ' POA_MEASURE3
     '|| poa_dbi_util_pkg.get_bucket_outer_query(
           p_bucket_rec
         , p_col_name => 'c_proc_amt_age'
         , p_alias_name => 'POA_MEASURE4'
         , p_prefix => 'nvl('
         , p_suffix => ',0)'
         , p_total_flag => 'N') ||',
     nvl(c_proc_amt_total,0) POA_MEASURE5,
     ' || poa_dbi_util_pkg.change_clause('c_proc_amt_total','p_proc_amt_total', 'NP') || ' POA_PERCENT3,
     nvl(c_man_amt_total,0) POA_MEASURE6,
     ' || poa_dbi_util_pkg.rate_clause('c_man_amt_total','c_proc_amt_total','P') || ' POA_PERCENT4,
     ' || poa_dbi_util_pkg.change_clause(
            poa_dbi_util_pkg.rate_clause('c_man_amt_total','c_proc_amt_total', 'P'),
            poa_dbi_util_pkg.rate_clause('p_man_amt_total','p_proc_amt_total', 'P'),
            'P') || ' POA_MEASURE7
     '|| poa_dbi_util_pkg.get_bucket_outer_query(
           p_bucket_rec
         , p_col_name => 'c_proc_amt_age'
         , p_alias_name => 'POA_MEASURE8'
         , p_prefix => 'nvl('
         , p_suffix => ',0)'
         , p_total_flag => 'Y') ||'
';
    return l_sel_clause;
  end;


  function get_amt_filter_where(p_view_by in VARCHAR2) return varchar2
  is
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  begin
    l_col_tbl := poa_dbi_sutil_pkg.poa_dbi_filter_tbl();
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
    if(p_view_by = 'ITEM+POA_ITEMS') then
       l_col_tbl.extend;
       l_col_tbl(6) := 'POA_MEASURE10';
    end if;
    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);
  end;

/* PROCESSED REQUISITIONS AGING REPORT */

  procedure age_sql(p_param in bis_pmv_page_parameter_tbl
                       ,x_custom_sql out nocopy varchar2
                       ,x_custom_output out nocopy bis_query_attributes_tbl)
  is
    l_col_tbl             poa_dbi_util_pkg.poa_dbi_col_tbl;
    l_join_tbl            poa_dbi_util_pkg.poa_dbi_join_tbl;
    l_query               varchar2(10000);
    l_view_by             varchar2(120);
    l_view_by_col         varchar2(120);
    l_as_of_date          date;
    l_prev_as_of_date     date;
    l_xtd                 varchar2(10);
    l_comparison_type     varchar2(1);
    l_nested_pattern      number;
    l_cur_suffix          varchar2(2);
    l_in_join_tbl         poa_dbi_util_pkg.poa_dbi_in_join_tbl;
    l_join_rec            poa_dbi_util_pkg.poa_dbi_join_rec;
    l_where_clause        varchar2(2000);
    l_mv                  varchar2(30);
    l_view_by_value       varchar2(30);
    l_bucket_rec          BIS_BUCKET_PUB.BIS_BUCKET_REC_TYPE;
    err_msg               varchar2(100);
    err_cde               number;
  begin
    l_comparison_type := 'Y';
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
    l_col_tbl :=  poa_dbi_util_pkg.POA_DBI_COL_TBL();

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
					,x_custom_output
                                        ,p_trend => 'N'
                                        ,p_func_area => 'PO'
                                        ,p_version => '7.1'
                                        ,p_role => 'VPP'
                                        ,p_mv_set => 'REQMP');


    poa_dbi_util_pkg.add_column(l_col_tbl
                    , 'days_to_process'
                    , 'proc_days'
                    , p_grand_total => 'Y'
                    , p_prior_code => poa_dbi_util_pkg.both_priors
                    , p_to_date_type => 'RLX');


    poa_dbi_util_pkg.add_column(l_col_tbl
                    , 'processed_cnt_' || l_cur_suffix
                    , 'proc_cnt'
                    , p_grand_total => 'Y'
                    , p_prior_code => poa_dbi_util_pkg.both_priors
                    , p_to_date_type => 'RLX');

    poa_dbi_util_pkg.add_column(l_col_tbl
                    , 'processed_man_cnt_' || l_cur_suffix
                    , 'man_lines_cnt'
                    , p_grand_total => 'Y'
                    , p_prior_code => poa_dbi_util_pkg.both_priors
                    , p_to_date_type => 'RLX');

 poa_dbi_util_pkg.add_bucket_columns(
                    p_short_name => 'POA_DBI_PR_BUCKET'
                   ,p_col_tbl => l_col_tbl
                   ,p_col_name => 'processed_cnt_'||l_cur_suffix||'_age'
                   ,p_alias_name => 'proc_cnt_age'
                   ,x_bucket_rec => l_bucket_rec
                   ,p_grand_total => 'Y'
                   ,p_prior_code => poa_dbi_util_pkg.NO_PRIORS
                   ,p_to_date_type => 'RLX');

 if(l_view_by = 'ITEM+POA_ITEMS') then
    poa_dbi_util_pkg.add_column(l_col_tbl
                               ,'processed_qty'
                               ,'proc_qty'
                   , p_grand_total => 'N'
                  , p_prior_code => poa_dbi_util_pkg.NO_PRIORS
                  , p_to_date_type => 'RLX');
end if;

    l_query := get_age_sel_clause(l_view_by, l_view_by_col, l_bucket_rec) || ' from ';
    l_query := l_query ||
                 poa_dbi_template_pkg.status_sql(
                                                     l_mv,
                                                     l_where_clause,
                                                     l_join_tbl,
                                                     p_use_windowing => 'Y',
                                                     p_col_name => l_col_tbl,
                                                     p_use_grpid => 'N',
                                                     p_filter_where => get_req_age_filter_where(l_view_by),
                                                     p_in_join_tables => l_in_join_tbl);

    x_custom_sql := l_query;

  exception
   when others then
      err_msg := substr(sqlerrm,1,400);
   end;


  function get_age_sel_clause(p_view_by_dim in varchar2
                         ,p_view_by_col in varchar2
             , p_bucket_rec in BIS_BUCKET_PUB.BIS_BUCKET_REC_TYPE)
  return varchar2 is
    l_sel_clause varchar2(6000);
  begin
    l_sel_clause := poa_dbi_sutil_pkg.get_viewby_select_clause(p_view_by_dim
                                                              ,'PO'
                                                              ,'7.1');

  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
     l_sel_clause := l_sel_clause
        || fnd_global.newline
        ||  '
    v.description POA_ATTRIBUTE1,                --Description
        v2.description POA_ATTRIBUTE2,              --UOM
        oset.POA_MEASURE10 POA_MEASURE10,        --Quantity

'|| fnd_global.newline;

  else
    l_sel_clause :=  l_sel_clause
        || fnd_global.newline
        ||  '
    null POA_ATTRIBUTE1,        --Description
     null POA_ATTRIBUTE2,        --UOM
    null POA_MEASURE10,        --Quantity'


|| fnd_global.newline;

  end if;
    l_sel_clause := l_sel_clause || fnd_global.newline ||
'    oset.POA_MEASURE1  POA_MEASURE1,  -- Average Age (Days)
    oset.POA_MEASURE2  POA_MEASURE2,  -- Change
    oset.POA_MEASURE3  POA_MEASURE3,  -- Processed Lines
    oset.POA_PERCENT1  POA_PERCENT1,  -- Change
    oset.POA_MEASURE4  POA_MEASURE4,  -- Manual Lines
    oset.POA_PERCENT2  POA_PERCENT2,  -- Manual Lines Rate
    oset.POA_MEASURE5  POA_MEASURE5   -- Change
        '|| poa_dbi_util_pkg.get_bucket_outer_query(
               p_bucket_rec
             , p_col_name => 'oset.POA_MEASURE6'
             , p_alias_name => 'POA_MEASURE6'
             , p_prefix => ''
             , p_suffix => ''
             , p_total_flag => 'N') ||',
    oset.POA_MEASURE7  POA_MEASURE7,  -- Total Average Age (Days)
    oset.POA_MEASURE8  POA_MEASURE8,  -- Total Change
    oset.POA_MEASURE9  POA_MEASURE9,  -- Total Processed Lines
    oset.POA_PERCENT3  POA_PERCENT3,  -- Total Change
    oset.POA_MEASURE11  POA_MEASURE11, -- Total Manual Lines
    oset.POA_PERCENT4  POA_PERCENT4,  -- Total Manual Lines Rate
    oset.POA_MEASURE12  POA_MEASURE12   -- Total Change
        '|| poa_dbi_util_pkg.get_bucket_outer_query(
               p_bucket_rec
             , p_col_name => 'oset.POA_MEASURE13'
             , p_alias_name => 'POA_MEASURE13'
             , p_prefix => ''
             , p_suffix => ''
             , p_total_flag => 'N') ||'
        '|| poa_dbi_util_pkg.get_bucket_drill_url(
                               p_bucket_rec,
                               'POA_ATTRIBUTE6',
                               '''pFunctionName=POA_DBI_PR_DTL&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y&POA_ATTRIBUTE10=1&POA_BUCKET+REQUISITION_AGING=',
                               '''',
                               p_add_bucket_num => 'Y'
                             ) || '
    from
    (select (rank() over(&ORDER_BY_CLAUSE nulls last, ' || p_view_by_col;
 if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ', base_uom';
 end if;

l_sel_clause := l_sel_clause || ')) - 1 rnk,' || p_view_by_col;
  if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ',
                       base_uom,
                       POA_MEASURE10';
  end if;

    l_sel_clause := l_sel_clause || ',
    POA_MEASURE1,
    POA_MEASURE2,
    POA_MEASURE3,
    POA_PERCENT1,
    POA_MEASURE4,
    POA_PERCENT2,
    POA_MEASURE5
    '|| poa_dbi_util_pkg.get_bucket_outer_query(
        p_bucket_rec
      , p_col_name => 'POA_MEASURE6'
      , p_alias_name => 'POA_MEASURE6'
      , p_prefix => ''
      , p_suffix => ''
      , p_total_flag => 'N') ||',
    POA_MEASURE7,
    POA_MEASURE8,
    POA_MEASURE9,
    POA_PERCENT3,
    POA_MEASURE11,
    POA_PERCENT4,
    POA_MEASURE12
    '|| poa_dbi_util_pkg.get_bucket_outer_query(
          p_bucket_rec
       , p_col_name => 'POA_MEASURE13'
        , p_alias_name => 'POA_MEASURE13'
        , p_prefix => ''
        , p_suffix => ''
        , p_total_flag => 'N') ||'
     from   (select ' || p_view_by_col || ',' || p_view_by_col || ' VIEWBY,' || p_view_by_col || ' VIEWBYID, ';
   if(p_view_by_dim = 'ITEM+POA_ITEMS') then
    l_sel_clause := l_sel_clause || ' base_uom,
                         decode(base_uom,null,to_number(null),nvl(c_proc_qty,0)) POA_MEASURE10, ';

   end if;
    l_sel_clause := l_sel_clause || '
     ' || poa_dbi_util_pkg.rate_clause('c_proc_days','c_proc_cnt', 'NP') || ' POA_MEASURE1,
     ' || poa_dbi_util_pkg.change_clause(
            poa_dbi_util_pkg.rate_clause('c_proc_days','c_proc_cnt', 'NP'),
            poa_dbi_util_pkg.rate_clause('p_proc_days','p_proc_cnt', 'NP'),
            'P') || ' POA_MEASURE2,
         nvl(c_proc_cnt, 0) POA_MEASURE3,
    ' || poa_dbi_util_pkg.change_clause('c_proc_cnt','p_proc_cnt', 'NP') || ' POA_PERCENT1,
        nvl(c_man_lines_cnt,0) POA_MEASURE4,
     ' || poa_dbi_util_pkg.rate_clause('c_man_lines_cnt','c_proc_cnt', 'P') || ' POA_PERCENT2,
     ' || poa_dbi_util_pkg.change_clause(
            poa_dbi_util_pkg.rate_clause('c_man_lines_cnt','c_proc_cnt', 'P'),
            poa_dbi_util_pkg.rate_clause('p_man_lines_cnt','p_proc_cnt', 'P'),
            'P') || ' POA_MEASURE5
     '|| poa_dbi_util_pkg.get_bucket_outer_query(
           p_bucket_rec
         , p_col_name => 'c_proc_cnt_age'
         , p_alias_name => 'POA_MEASURE6'
         , p_prefix => 'nvl('
         , p_suffix => ',0)'
         , p_total_flag => 'N') ||',
     ' || poa_dbi_util_pkg.rate_clause('c_proc_days_total','c_proc_cnt_total', 'NP') || ' POA_MEASURE7,
     ' || poa_dbi_util_pkg.change_clause(
            poa_dbi_util_pkg.rate_clause('c_proc_days_total','c_proc_cnt_total', 'NP'),
            poa_dbi_util_pkg.rate_clause('p_proc_days_total','p_proc_cnt_total', 'NP'),
            'P') || ' POA_MEASURE8,
         nvl(c_proc_cnt_total, 0) POA_MEASURE9,
    ' || poa_dbi_util_pkg.change_clause('c_proc_cnt_total','p_proc_cnt_total', 'NP') || ' POA_PERCENT3,
        nvl(c_man_lines_cnt_total,0) POA_MEASURE11,
     ' || poa_dbi_util_pkg.rate_clause('c_man_lines_cnt_total','c_proc_cnt_total', 'P') || ' POA_PERCENT4,
     ' || poa_dbi_util_pkg.change_clause(
            poa_dbi_util_pkg.rate_clause('c_man_lines_cnt_total','c_proc_cnt_total', 'P'),
            poa_dbi_util_pkg.rate_clause('p_man_lines_cnt_total','p_proc_cnt_total', 'P'),
            'P') || ' POA_MEASURE12
     '|| poa_dbi_util_pkg.get_bucket_outer_query(
             p_bucket_rec
           , p_col_name => 'c_proc_cnt_age'
           , p_alias_name => 'POA_MEASURE13'
           , p_prefix => 'nvl('
           , p_suffix => ',0)'
           , p_total_flag => 'Y') ||'
';
    return l_sel_clause;
  end;


  function get_req_age_filter_where(p_view_by in VARCHAR2) return varchar2
  is
    l_col_tbl poa_dbi_sutil_pkg.poa_dbi_filter_tbl;
  begin
    l_col_tbl := poa_dbi_sutil_pkg.poa_dbi_filter_tbl();
    l_col_tbl.extend;
    l_col_tbl(1) := 'POA_MEASURE1';
    l_col_tbl.extend;
    l_col_tbl(2) := 'POA_MEASURE2';
    l_col_tbl.extend;
    l_col_tbl(3) := 'POA_MEASURE3';
    l_col_tbl.extend;
    l_col_tbl(4) := 'POA_PERCENT1';
    l_col_tbl.extend;
    l_col_tbl(5) := 'POA_MEASURE4';
    l_col_tbl.extend;
    l_col_tbl(6) := 'POA_PERCENT2';
    l_col_tbl.extend;
    l_col_tbl(7) := 'POA_MEASURE5';

    if(p_view_by = 'ITEM+POA_ITEMS') then
     l_col_tbl.extend;
     l_col_tbl(8) := 'POA_MEASURE10';
    end if;

    return poa_dbi_sutil_pkg.get_filter_where(l_col_tbl);
  end;





/* PROCESSED LINES AMOUNT TREND REPORT */

  procedure amt_trend_sql(p_param in bis_pmv_page_parameter_tbl
                       ,x_custom_sql out nocopy varchar2
                       ,x_custom_output out nocopy bis_query_attributes_tbl)
  is
    l_query               varchar2(10000);
    l_view_by             varchar2(120);
    l_view_by_col_name    varchar2(120);
    l_as_of_date          date;
    l_prev_as_of_date     date;
    l_org                 varchar2(100);
    l_category            varchar2(2000);
    l_commodity           varchar2(2000);
    l_commodity_where     varchar2(2000);
    l_item                varchar2(2000);
    l_buyer               varchar2(2000);
    l_mv                  VARCHAR2(90);
    l_supplier            varchar2(2000);
    l_supplier_site       VARCHAR2(2000);
    l_xtd                 varchar2(10);
    l_comparison_type     varchar2(1);
    l_nested_pattern      number;
    l_dim_bmap            number;
    l_org_where           varchar2(240);
    l_category_where      varchar2(120);
    l_item_where          varchar2(120);
    l_buyer_where         varchar2(1000);
    l_supplier_where      varchar2(120);
    l_supplier_site_where varchar2(120);
    l_cur_suffix          varchar2(2);
    l_url                 varchar2(300);
    l_impact_amount       varchar2(15);
    l_leakage_amount      varchar2(25);
    l_purchase_amount     varchar2(25);
    l_custom_sql          varchar2(9000);
    l_view_by_value       varchar2(30);
    l_dim_in_tbl          poa_dbi_util_pkg.POA_DBI_DIM_TBL;
    l_dim_out_tbl         poa_dbi_util_pkg.POA_DBI_DIM_TBL;
    l_col_rec             poa_dbi_util_pkg.POA_DBI_COL_REC;
    l_col_tbl             poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_total_col_tbl       poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_join_tbl            poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
    l_in_join_tbl         poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
    l_join_rec            poa_dbi_util_pkg.POA_DBI_JOIN_REC;
    l_where_clause        VARCHAR2(2000);
    ERR_MSG               VARCHAR2(100);
    ERR_CDE               NUMBER;
  begin
    l_comparison_type := 'Y';
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();

    poa_dbi_sutil_pkg.process_parameters(p_param,
                                         l_view_by,
                                         l_view_by_col_name,
                                         l_view_by_value,
                                         l_comparison_type,
                                         l_xtd,
                                         l_as_of_date,
                                         l_prev_as_of_date,
                                         l_cur_suffix,
                                         l_nested_pattern,
                                         l_where_clause,
                                         l_mv,
                                         l_join_tbl,
                                         l_in_join_tbl,
					 x_custom_output,
                                         p_trend => 'Y',
                                         p_func_area => 'PO',
                                         p_version => '7.1',
                                         p_role => 'VPP',
                                         p_mv_set => 'REQMP');


    poa_dbi_util_pkg.add_column(l_col_tbl
                    , 'processed_amt_'  || l_cur_suffix
                    , 'proc_amt'
                    , p_grand_total => 'N'
                    , p_prior_code => poa_dbi_util_pkg.both_priors
                    , p_to_date_type => 'RLX');

    poa_dbi_util_pkg.add_column(l_col_tbl
                    , 'processed_man_amt_'  || l_cur_suffix
                    , 'man_amt'
                    , p_grand_total => 'N'
                    , p_prior_code => poa_dbi_util_pkg.both_priors
                    , p_to_date_type => 'RLX');

    l_query := get_amt_trend_sel_clause || '
                      from '
                      || poa_dbi_template_pkg.trend_sql(
                          l_xtd,
                          l_comparison_type,
                          l_mv,
                          l_where_clause,
                          l_col_tbl,
                          p_use_grpid => 'N',
                          p_in_join_tables => l_in_join_tbl);

    x_custom_sql := l_query;
  exception
   when others then
     err_msg := substr(sqlerrm,1,400);
  end;

  function get_amt_trend_sel_clause return varchar2
  is
    l_sel_clause varchar2(4000);
  begin
    l_sel_clause := 'select cal.name VIEWBY,';
    l_sel_clause := l_sel_clause || '
              nvl(c_proc_amt,0) POA_MEASURE1,
              ' || poa_dbi_util_pkg.change_clause('c_proc_amt','p_proc_amt','NP') || ' POA_PERCENT1,
              nvl(c_man_amt,0) POA_MEASURE2,
    ' || poa_dbi_util_pkg.rate_clause('c_man_amt','c_proc_amt', 'P') || ' POA_PERCENT2,
    ' || poa_dbi_util_pkg.change_clause(
           poa_dbi_util_pkg.rate_clause('c_man_amt','c_proc_amt', 'P'),
           poa_dbi_util_pkg.rate_clause('p_man_amt','p_proc_amt', 'P'),
           'P') || ' POA_MEASURE3,
    nvl(p_proc_amt,0) POA_ATTRIBUTE3,
    nvl(p_man_amt,0) POA_ATTRIBUTE4
';
    return l_sel_clause;
  end;


/* PROCESSED AVERAGE AGE TREND REPORT */

  procedure age_trend_sql(p_param in bis_pmv_page_parameter_tbl
                       ,x_custom_sql out nocopy varchar2
                       ,x_custom_output out nocopy bis_query_attributes_tbl)
  is
    l_query               varchar2(10000);
    l_view_by             varchar2(120);
    l_view_by_col_name    varchar2(120);
    l_as_of_date          date;
    l_prev_as_of_date     date;
    l_org                 varchar2(100);
    l_category            varchar2(2000);
    l_commodity           varchar2(2000);
    l_commodity_where     varchar2(2000);
    l_item                varchar2(2000);
    l_buyer               varchar2(2000);
    l_mv                  VARCHAR2(90);
    l_supplier            varchar2(2000);
    l_supplier_site       VARCHAR2(2000);
    l_xtd                 varchar2(10);
    l_comparison_type     varchar2(1);
    l_nested_pattern      number;
    l_dim_bmap            number;
    l_org_where           varchar2(240);
    l_category_where      varchar2(120);
    l_item_where          varchar2(120);
    l_buyer_where         varchar2(1000);
    l_supplier_where      varchar2(120);
    l_supplier_site_where varchar2(120);
    l_cur_suffix          varchar2(2);
    l_url                 varchar2(300);
    l_impact_amount       varchar2(15);
    l_leakage_amount      varchar2(25);
    l_purchase_amount     varchar2(25);
    l_custom_sql          varchar2(9000);
    l_view_by_value       varchar2(30);
    l_dim_in_tbl          poa_dbi_util_pkg.POA_DBI_DIM_TBL;
    l_dim_out_tbl         poa_dbi_util_pkg.POA_DBI_DIM_TBL;
    l_col_rec             poa_dbi_util_pkg.POA_DBI_COL_REC;
    l_col_tbl             poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_total_col_tbl       poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_join_tbl            poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
    l_in_join_tbl         poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
    l_join_rec            poa_dbi_util_pkg.POA_DBI_JOIN_REC;
    l_where_clause        VARCHAR2(2000);
    ERR_MSG               VARCHAR2(100);
    ERR_CDE               NUMBER;
  begin
    l_comparison_type := 'Y';
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();

    poa_dbi_sutil_pkg.process_parameters(p_param,
                                         l_view_by,
                                         l_view_by_col_name,
                                         l_view_by_value,
                                         l_comparison_type,
                                         l_xtd,
                                         l_as_of_date,
                                         l_prev_as_of_date,
                                         l_cur_suffix,
                                         l_nested_pattern,
                                         l_where_clause,
                                         l_mv,
                                         l_join_tbl,
                                         l_in_join_tbl,
					 x_custom_output,
                                         p_trend => 'Y',
                                         p_func_area => 'PO',
                                         p_version => '7.1',
                                         p_role => 'VPP',
                                         p_mv_set => 'REQMP');


    poa_dbi_util_pkg.add_column(
                       l_col_tbl,
                       'days_to_process',
                       'days_to_proc',
                       p_grand_total => 'N',
                       p_prior_code => poa_dbi_util_pkg.both_priors,
                       p_to_date_type => 'RLX'
                     );

    poa_dbi_util_pkg.add_column(
                       l_col_tbl,
                       'days_to_process_cnt',
                       'days_to_proc_cnt',
                       p_grand_total => 'N',
                       p_prior_code => poa_dbi_util_pkg.both_priors,
                       p_to_date_type => 'RLX'
                     );

    l_query := get_age_trend_sel_clause || 'from '|| fnd_global.newline
                 || poa_dbi_template_pkg.trend_sql(
                      l_xtd,
                      l_comparison_type,
                      l_mv,
                      l_where_clause,
                      l_col_tbl,
		      p_use_grpid => 'N',
                      p_in_join_tables => l_in_join_tbl
                    );

    x_custom_sql := l_query;
  exception
   when others then
     err_msg := substr(sqlerrm,1,400);
  end;

  function get_age_trend_sel_clause return varchar2
  is
    l_sel_clause varchar2(4000);
  begin
    l_sel_clause := 'select cal.name VIEWBY,';
    l_sel_clause := l_sel_clause || '
' || poa_dbi_util_pkg.rate_clause(
                        'c_days_to_proc',
                        'c_days_to_proc_cnt',
                        'NP'
                      ) ||' POA_MEASURE1,
' || poa_dbi_util_pkg.change_clause(
                        poa_dbi_util_pkg.rate_clause('c_days_to_proc','c_days_to_proc_cnt','NP'),
                        poa_dbi_util_pkg.rate_clause('p_days_to_proc','p_days_to_proc_cnt','NP'),
                        'P'
                      ) || ' POA_MEASURE2,
' || poa_dbi_util_pkg.rate_clause(
                        'p_days_to_proc',
                        'p_days_to_proc_cnt',
                        'NP'
                      ) ||' POA_ATTRIBUTE2
';
    return l_sel_clause;
  end;


/* PROCESSED LINES AUTOMATION TREND REPORT */

  procedure au_trend_sql(p_param in bis_pmv_page_parameter_tbl
                       ,x_custom_sql out nocopy varchar2
                       ,x_custom_output out nocopy bis_query_attributes_tbl)
  is
    l_query               varchar2(10000);
    l_view_by             varchar2(120);
    l_view_by_col_name    varchar2(120);
    l_as_of_date          date;
    l_prev_as_of_date     date;
    l_org                 varchar2(100);
    l_category            varchar2(2000);
    l_commodity           varchar2(2000);
    l_commodity_where     varchar2(2000);
    l_item                varchar2(2000);
    l_buyer               varchar2(2000);
    l_mv                  VARCHAR2(90);
    l_supplier            varchar2(2000);
    l_supplier_site       VARCHAR2(2000);
    l_xtd                 varchar2(10);
    l_comparison_type     varchar2(1);
    l_nested_pattern      number;
    l_dim_bmap            number;
    l_org_where           varchar2(240);
    l_category_where      varchar2(120);
    l_item_where          varchar2(120);
    l_buyer_where         varchar2(1000);
    l_supplier_where      varchar2(120);
    l_supplier_site_where varchar2(120);
    l_cur_suffix          varchar2(2);
    l_url                 varchar2(300);
    l_impact_amount       varchar2(15);
    l_leakage_amount      varchar2(25);
    l_purchase_amount     varchar2(25);
    l_custom_sql          varchar2(9000);
    l_view_by_value       varchar2(30);
    l_dim_in_tbl          poa_dbi_util_pkg.POA_DBI_DIM_TBL;
    l_dim_out_tbl         poa_dbi_util_pkg.POA_DBI_DIM_TBL;
    l_col_rec             poa_dbi_util_pkg.POA_DBI_COL_REC;
    l_col_tbl             poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_total_col_tbl       poa_dbi_util_pkg.POA_DBI_COL_TBL;
    l_join_tbl            poa_dbi_util_pkg.POA_DBI_JOIN_TBL;
    l_in_join_tbl         poa_dbi_util_pkg.POA_DBI_IN_JOIN_TBL;
    l_join_rec            poa_dbi_util_pkg.POA_DBI_JOIN_REC;
    l_where_clause        VARCHAR2(2000);
    ERR_MSG               VARCHAR2(100);
    ERR_CDE               NUMBER;
  begin
    l_comparison_type := 'Y';
    l_join_tbl := poa_dbi_util_pkg.POA_DBI_JOIN_TBL();
    l_col_tbl := poa_dbi_util_pkg.POA_DBI_COL_TBL();

    poa_dbi_sutil_pkg.process_parameters(p_param,
                                         l_view_by,
                                         l_view_by_col_name,
                                         l_view_by_value,
                                         l_comparison_type,
                                         l_xtd,
                                         l_as_of_date,
                                         l_prev_as_of_date,
                                         l_cur_suffix,
                                         l_nested_pattern,
                                         l_where_clause,
                                         l_mv,
                                         l_join_tbl,
                                         l_in_join_tbl,
					 x_custom_output,
                                         p_trend => 'Y',
                                         p_func_area => 'PO',
                                         p_version => '7.1',
                                         p_role => 'VPP',
                                         p_mv_set => 'REQMP');


    poa_dbi_util_pkg.add_column(l_col_tbl
                    , 'processed_cnt_'||l_cur_suffix
                    , 'proc_cnt'
                    , p_grand_total => 'N'
                    , p_prior_code => poa_dbi_util_pkg.both_priors
                    , p_to_date_type => 'RLX');

    poa_dbi_util_pkg.add_column(l_col_tbl
                    , 'processed_man_cnt_'||l_cur_suffix
                    , 'man_cnt'
                    , p_grand_total => 'N'
                    , p_prior_code => poa_dbi_util_pkg.both_priors
                    , p_to_date_type => 'RLX');

    l_query := get_au_trend_sel_clause || '
                      from '
                      || poa_dbi_template_pkg.trend_sql(
                          l_xtd,
                          l_comparison_type,
                          l_mv,
                          l_where_clause,
                          l_col_tbl,
			  p_use_grpid => 'N',
                          p_in_join_tables => l_in_join_tbl);

    x_custom_sql := l_query;
  exception
   when others then
     err_msg := substr(sqlerrm,1,400);
  end;

  function get_au_trend_sel_clause return varchar2
  is
    l_sel_clause varchar2(4000);
  begin
    l_sel_clause := 'select cal.name VIEWBY,';
    l_sel_clause := l_sel_clause || '
nvl(c_proc_cnt,0) POA_MEASURE1,
' || poa_dbi_util_pkg.change_clause('c_proc_cnt','p_proc_cnt','NP') || ' POA_PERCENT1,
nvl(c_man_cnt,0) POA_MEASURE2,
' || poa_dbi_util_pkg.change_clause('c_man_cnt','p_man_cnt','NP') || ' POA_PERCENT2,
(nvl(c_proc_cnt,0) - nvl(c_man_cnt,0)) POA_MEASURE3,
' || poa_dbi_util_pkg.change_clause('(nvl(c_proc_cnt,0) - nvl(c_man_cnt,0))','(nvl(p_proc_cnt,0) - nvl(p_man_cnt,0))','NP') || ' POA_PERCENT3
';
    return l_sel_clause;
  end;

  procedure dtl_sql(p_param in bis_pmv_page_parameter_tbl
                       ,x_custom_sql out nocopy varchar2
                       ,x_custom_output out nocopy bis_query_attributes_tbl)
  is
    l_query               varchar2(10000);
    l_option              number;
    l_cur_suffix          varchar2(2);
    l_where_clause        varchar2(2000);
    l_in_join_tbl         poa_dbi_util_pkg.poa_dbi_in_join_tbl;
    l_in_join_tables      varchar2(240) ;
    l_xtd                 varchar2(10);
    err_msg               varchar2(100);
    l_bucket              varchar2(50);
    l_bucket_where        varchar2(440);
  begin
    poa_dbi_sutil_pkg.drill_process_parameters(
                        p_param,
                        l_cur_suffix,
                        l_where_clause,
                        l_in_join_tbl,
                        'PO',
                        '7.1',
                        'VPP',
                        'REQMP'
                      );

    for i in 1..p_param.count
    loop
      if (p_param(i).parameter_name = 'POA_ATTRIBUTE10')
      then
        l_option := p_param(i).parameter_id;
      end if;
      if (p_param(i).parameter_name = 'POA_BUCKET+REQUISITION_AGING')
      then
        l_bucket := p_param(i).parameter_id;
      end if;
    end loop;

    if (l_option = 2) then --manual reqs
      l_where_clause := l_where_clause || fnd_global.newline || ' and fact.po_creation_method = ''M'' ';
    end if;

    if(l_bucket is not null)
    then
      l_bucket_where := 'and (&RANGE_LOW is null or '
          || 'greatest(0,(fact.po_approved_date-fact.req_approved_date))'
          || ' >= &RANGE_LOW)'
          || fnd_global.newline
          || 'and (&RANGE_HIGH is null or '
          || 'greatest(0,(fact.po_approved_date-fact.req_approved_date))'
          || ' < &RANGE_HIGH)';

      poa_dbi_util_pkg.bind_low_high(p_param
          , 'POA_DBI_PR_BUCKET'
          , 'POA_BUCKET+REQUISITION_AGING'
          , '&RANGE_LOW'
          , '&RANGE_HIGH'
          , x_custom_output);
    else
      l_bucket_where := '';
    end if;



    ---Begin MOAC changes
    ---Following block is removed from custom_sql as l_where_clause is already
    --- having a security clause
       --        per_organization_list orgl
       --       where
       --        fact.org_id=orgl.organization_id
       --        and orgl.security_profile_id=' || poa_dbi_util_pkg.get_sec_profile ||
    ---End  MOAC changes

    x_custom_sql := '
    select
    prh.segment1 POA_MEASURE1,                                -- Requisition Number
    prl.line_num POA_PERCENT1,                                -- Line Num
    rorg.name POA_MEASURE5,                                   -- Req Creation OU
    substrb(perf.first_name,1,1) || ''. '' || perf.last_name POA_MEASURE2,  -- Requestor Name
    POA_PERCENT2 POA_PERCENT2,                                -- Req Approved Date
    POA_MEASURE7 POA_MEASURE7,                                -- Processed Date
    POA_MEASURE8 POA_MEASURE8,                                -- Fulfilled Date
    item.value POA_PERCENT3,                                  -- Item
    supplier.value POA_PERCENT4,                              -- Supplier
    i.POA_MEASURE3 POA_MEASURE3,                              -- Amount
    decode(pll.po_release_id,null,
           poh.segment1,
           poh.segment1||''-''||por.release_num) POA_PERCENT5,   -- PO Number
    porg.name POA_MEASURE4,                                   -- PO OU
    POA_MEASURE6 POA_MEASURE6,                                -- Grand Total for Amount
    prh.requisition_header_id POA_ATTRIBUTE3,
    prl.requisition_line_id POA_ATTRIBUTE4,
    poh.po_header_id POA_ATTRIBUTE5,
    pll.po_release_id POA_ATTRIBUTE6
    from (select (rank() over (&ORDER_BY_CLAUSE nulls last, req_header_id, req_line_id))-1 rnk,
          req_header_id,
          req_line_id,
          req_creation_ou_id,
          requester_id,
          POA_PERCENT2 POA_PERCENT2,
          POA_MEASURE7 POA_MEASURE7,
          POA_MEASURE8 POA_MEASURE8,
          POA_MEASURE9 POA_MEASURE9,
          po_item_id,
          supplier_id,
          nvl(POA_MEASURE3,0) POA_MEASURE3,
          nvl(POA_MEASURE6,0) POA_MEASURE6,
          po_line_location_id,
          po_creation_ou_id
          from ( select
                 fact.req_header_id,
                 fact.req_line_id,
                 fact.req_creation_ou_id,
                 fact.requester_id,
                 fact.req_approved_date POA_PERCENT2,
                 fact.po_approved_date POA_MEASURE7,
                 fact.req_fulfilled_date POA_MEASURE8,
                 fact.expected_date POA_MEASURE9,
                 fact.po_item_id,
                 fact.supplier_id,
                 fact.line_amount_'||l_cur_suffix||' POA_MEASURE3,
                 sum(fact.line_amount_'||l_cur_suffix||') over() POA_MEASURE6,
                 fact.po_line_location_id,
                 fact.po_creation_ou_id
                 from
                 poa_dbi_req_f fact
                 where fact.po_approved_date between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_EFFECTIVE_END_DATE + (86399/86400) '
                 || fnd_global.newline || l_where_clause
                 || fnd_global.newline || l_bucket_where ||
              ')
         ) i,
         po_requisition_headers_all prh,
         po_requisition_lines_all prl,
         po_headers_all poh,
         po_line_locations_all pll,
         poa_items_v item,
         poa_suppliers_v supplier,
         per_all_people_f perf,
         hr_all_organization_units_vl rorg,
         hr_all_organization_units_vl porg,
         po_releases_all por
    where i.req_header_id=prh.requisition_header_id
    and   i.req_line_id=prl.requisition_line_id
    and   prh.requisition_header_id=prl.requisition_header_id
    and   i.po_item_id=item.id
    and   i.req_creation_ou_id=rorg.organization_id
    and   i.requester_id=perf.person_id
    and   sysdate between perf.effective_start_date and perf.effective_end_date
    and   i.supplier_id=supplier.id(+)
    and   i.po_line_location_id=pll.line_location_id(+)
    and   pll.po_header_id=poh.po_header_id(+)
    and   poh.org_id=porg.organization_id(+)
    and   pll.po_header_id = por.po_header_id(+)
    and   pll.po_release_id = por.po_release_id(+)
    and   (rnk between &START_INDEX and &END_INDEX or &END_INDEX = -1)
    ORDER BY rnk ';

    poa_dbi_util_pkg.get_custom_status_binds(x_custom_output);
    poa_dbi_util_pkg.get_custom_rolling_binds(x_custom_output,l_xtd);
  exception
    when others then
      err_msg := substr(sqlerrm,1,400);
  end;

end poa_dbi_pr_pkg;

/
