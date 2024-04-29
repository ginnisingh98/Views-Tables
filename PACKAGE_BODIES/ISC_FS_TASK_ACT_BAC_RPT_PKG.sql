--------------------------------------------------------
--  DDL for Package Body ISC_FS_TASK_ACT_BAC_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_FS_TASK_ACT_BAC_RPT_PKG" 
/* $Header: iscfstkabrptb.pls 120.3 2006/04/12 20:46:04 kreardon noship $ */
as

  g_detail_rep_func  constant varchar2(50) := 'ISC_FS_TASK_BAC_STATUS_RPT_REP';
  g_task_rep_func    constant varchar2(50) := 'ISC_FS_TASK_ACT_BAC_TBL_REP';

function get_detail_drill
( p_view_by in varchar2
, p_col_alias in varchar2
)
return varchar2
is
  l_column_name varchar2(30);
begin

  return
    case
      when p_view_by in ( isc_fs_rpt_util_pkg.G_PRODUCT
                        , isc_fs_rpt_util_pkg.G_CUSTOMER
                        , isc_fs_rpt_util_pkg.G_TASK_TYPE ) then
        '''pFunctionName=' || g_detail_rep_func ||
        '&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'''
      when p_view_by = isc_fs_rpt_util_pkg.G_DISTRICT then
        'decode(''-1'',&'|| isc_fs_rpt_util_pkg.G_DISTRICT_SHORT || ',null,decode(oset.record_type,''RESOURCE'',''pFunctionName=' || g_detail_rep_func ||
        '&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'',null))'
      else
        'null'
    end || ' ' || p_col_alias;

end get_detail_drill;

procedure get_tbl_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
)
is

  l_dimension_tbl    isc_fs_rpt_util_pkg.t_dimension_tbl;
  l_dim_filter_map   poa_dbi_util_pkg.poa_dbi_dim_map;
  l_custom_output    bis_query_attributes_tbl;
  l_curr_suffix      varchar2(3);
  l_where_clause     varchar2(10000);
  l_viewby_select    varchar2(400); -- needed to be increased from 200
  l_join_tbl         poa_dbi_util_pkg.poa_dbi_join_tbl;
  l_dim_bmap         number;
  l_comparison_type  varchar2(200);
  l_xtd              varchar2(200);
  l_mv               varchar2(10000);
  l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_view_by          varchar2(200);
  l_product          varchar2(50);
  l_stmt             varchar2(32700);
  l_to_date_type     varchar2(200);

  l_union_mv_tbl     poa_dbi_util_pkg.poa_dbi_mv_tbl;
  l_union_mv_rec     poa_dbi_util_pkg.poa_dbi_mv_rec;

begin

  isc_fs_rpt_util_pkg.register_dimension_levels
  ( l_dimension_tbl
  , l_dim_filter_map
  , isc_fs_rpt_util_pkg.G_CATEGORY, 'Y'
  , isc_fs_rpt_util_pkg.G_PRODUCT, 'Y'
  , isc_fs_rpt_util_pkg.G_CUSTOMER, 'Y'
  , isc_fs_rpt_util_pkg.G_DISTRICT, 'Y'
  , isc_fs_rpt_util_pkg.G_TASK_TYPE, 'Y'
  );

  isc_fs_rpt_util_pkg.check_district_filter
  ( p_param
  , l_dim_filter_map
  );

  isc_fs_rpt_util_pkg.process_parameters
  ( p_param            => p_param
  , p_dimension_tbl    => l_dimension_tbl
  , p_dim_filter_map   => l_dim_filter_map
  , p_trend            => 'N'
  , p_custom_output    => l_custom_output
  , x_cur_suffix       => l_curr_suffix
  , x_where_clause     => l_where_clause
  , x_viewby_select    => l_viewby_select
  , x_join_tbl         => l_join_tbl
  , x_dim_bmap         => l_dim_bmap
  , x_comparison_type  => l_comparison_type
  , x_xtd              => l_xtd
  );

  if l_xtd in ('DAY','WTD','MTD','QTD','YTD') then
    l_to_date_type := 'XTD';
  else
    l_to_date_type := 'RLX';
  end if;

  l_view_by := isc_fs_rpt_util_pkg.get_parameter_value
               ( p_param
               , 'VIEW_BY'
               );

  if l_view_by = isc_fs_rpt_util_pkg.G_PRODUCT then
    l_product := 'v4.description ISC_ATTRIBUTE_2';
  else
    l_product := 'null ISC_ATTRIBUTE_2';
  end if;

  l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl
                             , p_col_name     => 'backlog_count'
                             , p_alias_name   => 'backlog'
                             , p_to_date_type => 'BAL'
                             , p_prior_code   => poa_dbi_util_pkg.OPENING_PRIOR_CURR
                             );

  l_union_mv_tbl   := poa_dbi_util_pkg.poa_dbi_mv_tbl();
  l_union_mv_rec.mv_name := 'ISC_FS_MV_PLACEHOLDER_1'; -- poa restrict this to 300 characters so we use a placeholder, see below
  l_union_mv_rec.mv_col := l_col_tbl;
  l_union_mv_rec.mv_where := l_where_clause;
  l_union_mv_rec.in_join_tbls := null;
  l_union_mv_rec.use_grp_id   := 'N';
  l_union_mv_tbl.extend();
  l_union_mv_tbl(l_union_mv_tbl.count) := l_union_mv_rec;

  l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl
                             , p_col_name     => 'first_opened'
                             , p_alias_name   => 'first_opened'
                             , p_to_date_type => l_to_date_type
                             , p_prior_code   => poa_dbi_util_pkg.NO_PRIORS
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl
                             , p_col_name     => 'reopened'
                             , p_alias_name   => 'reopened'
                             , p_to_date_type => l_to_date_type
                             , p_prior_code   => poa_dbi_util_pkg.NO_PRIORS
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl
                             , p_col_name     => 'opened'
                             , p_alias_name   => 'opened'
                             , p_to_date_type => l_to_date_type
                             , p_prior_code   => poa_dbi_util_pkg.NO_PRIORS
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl
                             , p_col_name     => 'closed'
                             , p_alias_name   => 'closed'
                             , p_to_date_type => l_to_date_type
                             , p_prior_code   => poa_dbi_util_pkg.NO_PRIORS
                             );

  l_union_mv_rec.mv_name := 'ISC_FS_MV_PLACEHOLDER_2'; -- poa restrict this to 300 characters so we use a placeholder, see below
  l_union_mv_rec.mv_col := l_col_tbl;
  l_union_mv_rec.mv_where := l_where_clause;
  l_union_mv_rec.in_join_tbls := null;
  l_union_mv_rec.use_grp_id   := 'N';
  l_union_mv_tbl.extend();
  l_union_mv_tbl(l_union_mv_tbl.count) := l_union_mv_rec;

  l_stmt := poa_dbi_template_pkg.union_all_status_sql
            ( p_mv                  => l_union_mv_tbl
            , p_join_tables         => l_join_tbl
            , p_use_windowing       => 'Y'
            , p_paren_count         => 3
            , p_filter_where        => '(isc_measure_1 >0 or isc_measure_2>0 or isc_measure_4>0 or isc_measure_7>0 or isc_measure_8>0) ) iset '
            , p_generate_viewby     => 'Y'
            );

  l_mv := isc_fs_task_backlog_rpt_pkg.get_fact_mv_name
          ( 'TASK_BACKLOG_STATUS'
          , p_param
          , l_dim_bmap
          , l_custom_output
          );

  l_stmt := replace( l_stmt, 'ISC_FS_MV_PLACEHOLDER_1', l_mv );

  l_mv := isc_fs_task_activity_rpt_pkg.get_fact_mv_name
          ( 'TASK_ACTIVITY'
          , p_param
          , l_dim_bmap
          , l_custom_output
          );

  l_stmt := replace( l_stmt, 'ISC_FS_MV_PLACEHOLDER_2', l_mv );

  l_stmt := 'select
  ' || l_viewby_select || '
, ISC_MEASURE_1
, ISC_MEASURE_2
, ISC_MEASURE_3
, ISC_MEASURE_4
, ISC_MEASURE_2 ISC_MEASURE_9
, ISC_MEASURE_5
, ISC_MEASURE_6
, ISC_MEASURE_7
, ISC_MEASURE_8
, ISC_MEASURE_21
, ISC_MEASURE_22
, ISC_MEASURE_23
, ISC_MEASURE_24
, ISC_MEASURE_25
, ISC_MEASURE_26
, ISC_MEASURE_27
, ISC_MEASURE_28
, ' || l_product || '
, ' || isc_fs_rpt_util_pkg.get_district_drill_down
       ( l_view_by
       , g_task_rep_func
       , 'ISC_ATTRIBUTE_3' ) || '
, ' || isc_fs_rpt_util_pkg.get_category_drill_down
       ( l_view_by
       , g_task_rep_func
       , 'ISC_ATTRIBUTE_4' ) || '
, ' || get_detail_drill( l_view_by, 'ISC_ATTRIBUTE_5' ) || '
from (
select
  row_number() over(&ORDER_BY_CLAUSE nulls last, '|| isc_fs_rpt_util_pkg.get_inner_select_col(l_join_tbl) || ')-1 rnk
, iset.*
from ( select * from (
select ' || isc_fs_rpt_util_pkg.get_inner_select_col(l_join_tbl) || '
, nvl(p_backlog,0) ISC_MEASURE_1
, nvl(c_backlog,0) ISC_MEASURE_2
, ' || isc_fs_rpt_util_pkg.change_column
       ( 'c_backlog'
       , 'p_backlog'
       , 'ISC_MEASURE_3' ) || '
, nvl(o_backlog,0) ISC_MEASURE_4
, nvl(c_first_opened,0) ISC_MEASURE_5
, nvl(c_reopened,0) ISC_MEASURE_6
, nvl(c_opened,0) ISC_MEASURE_7
, nvl(c_closed,0) ISC_MEASURE_8
, nvl(p_backlog_total,0) ISC_MEASURE_21
, nvl(c_backlog_total,0) ISC_MEASURE_22
, ' || isc_fs_rpt_util_pkg.change_column
       ( 'c_backlog_total'
       , 'p_backlog_total'
       , 'ISC_MEASURE_23' ) || '
, nvl(o_backlog_total,0) ISC_MEASURE_24
, nvl(c_first_opened_total,0) ISC_MEASURE_25
, nvl(c_reopened_total,0) ISC_MEASURE_26
, nvl(c_opened_total,0) ISC_MEASURE_27
, nvl(c_closed_total,0) ISC_MEASURE_28
from (' || l_stmt;

  isc_fs_rpt_util_pkg.enhance_time_join
  ( l_stmt
  , 'N'
  );

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  -- l_stmt := l_stmt || isc_fs_rpt_util_pkg.dump_parameters(p_param);

  x_custom_sql      := l_stmt;

  poa_dbi_util_pkg.get_custom_balance_binds
  ( p_custom_output => l_custom_output
  , p_balance_fact  => isc_fs_task_act_bac_etl_pkg.g_object_name
  , p_xtd           => l_xtd
  );

  poa_dbi_util_pkg.get_custom_rolling_binds
  ( p_custom_output => l_custom_output
  , p_xtd           => l_xtd
  );

  x_custom_output := l_custom_output;

end get_tbl_sql;

end isc_fs_task_act_bac_rpt_pkg;

/
