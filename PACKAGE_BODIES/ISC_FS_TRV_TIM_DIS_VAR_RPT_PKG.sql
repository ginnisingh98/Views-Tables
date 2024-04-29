--------------------------------------------------------
--  DDL for Package Body ISC_FS_TRV_TIM_DIS_VAR_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_FS_TRV_TIM_DIS_VAR_RPT_PKG" as
/*$Header: iscfstrvvarrptb.pls 120.2 2005/12/13 19:41:24 kreardon noship $ */


  g_task_tim_var_tbl_func        constant varchar2(100) := 'ISC_FS_TRV_TIM_VAR_TBL_REP';
  g_task_tim_var_dtr_tbl_func    constant varchar2(100) := 'ISC_FS_TRV_TIM_VAR_DTR_TBL_REP';
  g_task_dis_var_tbl_func        constant varchar2(100) := 'ISC_FS_TRV_DIS_VAR_TBL_REP';
  g_task_dis_var_dtr_tbl_func    constant varchar2(100) := 'ISC_FS_TRV_DIS_VAR_DTR_TBL_REP';
  g_task_tim_dtl_func            constant varchar2(100) := 'ISC_FS_TRV_TIM_DIS_RPT_REP';

function get_fact_mv_name
( p_report_type   in varchar2
, p_param         in bis_pmv_page_parameter_tbl
, p_custom_output in out NOCOPY bis_query_attributes_tbl
)
return varchar2
is

  l_resource varchar2(10);

begin

  if p_report_type = 'TRAVEL_TIME_VAR' then

    return '(
        select
          record_type
        , parent_district_id
        , district_id
        , decode( den_record_type, ''GROUP'', to_char(district_id), to_char(district_id) || ''.'' || parent_district_id ) district_id_c
        , bucket_num
        , time_id
        , period_type_id
        , actual_travel_duration_min tot_trv_dur_min_act
        , sched_travel_duration_min  tot_trv_dur_min_sch
        , task_duration_count count_dur_task
        , decode(bucket_num,1,task_duration_count,0)  actual_travel_time_var_b1
        , decode(bucket_num,2,task_duration_count,0)  actual_travel_time_var_b2
        , decode(bucket_num,3,task_duration_count,0)  actual_travel_time_var_b3
        , decode(bucket_num,4,task_duration_count,0)  actual_travel_time_var_b4
        , decode(bucket_num,5,task_duration_count,0)  actual_travel_time_var_b5
        , decode(bucket_num,6,task_duration_count,0)  actual_travel_time_var_b6
        , decode(bucket_num,7,task_duration_count,0)  actual_travel_time_var_b7
        , decode(bucket_num,8,task_duration_count,0)  actual_travel_time_var_b8
        , decode(bucket_num,9,task_duration_count,0)  actual_travel_time_var_b9
        , decode(bucket_num,10,task_duration_count,0) actual_travel_time_var_b10
        from isc_fs_019_mv
      )';

  elsif p_report_type = 'TRAVEL_DIST_VAR' then

    return '(
        select
          record_type
        , parent_district_id
        , district_id
        , decode( den_record_type, ''GROUP'', to_char(district_id), to_char(district_id) || ''.'' || parent_district_id ) district_id_c
        , bucket_num
        , time_id
        , period_type_id
        , actual_travel_distance_km * &ISC_FS_DIST_FACTOR tot_trv_dist_act
        , sched_travel_distance_km  * &ISC_FS_DIST_FACTOR tot_trv_dist_sch
        , task_distance_count count_dist_task
        , decode(bucket_num,1,task_distance_count,0)  actual_travel_dist_var_b1
        , decode(bucket_num,2,task_distance_count,0)  actual_travel_dist_var_b2
        , decode(bucket_num,3,task_distance_count,0)  actual_travel_dist_var_b3
        , decode(bucket_num,4,task_distance_count,0)  actual_travel_dist_var_b4
        , decode(bucket_num,5,task_distance_count,0)  actual_travel_dist_var_b5
        , decode(bucket_num,6,task_distance_count,0)  actual_travel_dist_var_b6
        , decode(bucket_num,7,task_distance_count,0)  actual_travel_dist_var_b7
        , decode(bucket_num,8,task_distance_count,0)  actual_travel_dist_var_b8
        , decode(bucket_num,9,task_distance_count,0)  actual_travel_dist_var_b9
        , decode(bucket_num,10,task_distance_count,0) actual_travel_dist_var_b10
        from isc_fs_020_mv
      )';

  else -- should not happen!!!
    return '';

  end if;

end get_fact_mv_name;

procedure get_time_var_sql
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
  l_view_by          varchar2(200);
  l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_product          varchar2(50);
  l_stmt             varchar2(32700);
  l_distance         varchar2(300);
  l_bucket_rec bis_bucket_pub.bis_bucket_rec_type;
  l_to_date_type     varchar2(200);
  l_drill_across_task  varchar2(1000);

begin

  l_col_tbl  := poa_dbi_util_pkg.poa_dbi_col_tbl();
  l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

  isc_fs_rpt_util_pkg.register_dimension_levels
  ( l_dimension_tbl
  , l_dim_filter_map
  , isc_fs_rpt_util_pkg.G_DISTRICT, 'Y'
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

  l_mv := get_fact_mv_name
          ( 'TRAVEL_TIME_VAR'
          , p_param
          , l_custom_output
          );

  poa_dbi_util_pkg.add_column
  ( p_col_tbl      => l_col_tbl
  , p_col_name     => 'tot_trv_dur_min_act'
  , p_alias_name   => 'tot_trv_dur_min_act'
  , p_to_date_type => l_to_date_type
  );

  poa_dbi_util_pkg.add_column
  ( p_col_tbl      => l_col_tbl
  , p_col_name     => 'tot_trv_dur_min_sch'
  , p_alias_name   => 'tot_trv_dur_min_sch'
  , p_to_date_type => l_to_date_type
  );

  poa_dbi_util_pkg.add_column
  ( p_col_tbl        => l_col_tbl
  , p_col_name     => 'count_dur_task'
  , p_alias_name   => 'count_dur_task'
  , p_to_date_type => l_to_date_type
  );

  poa_dbi_util_pkg.add_bucket_columns
  ( p_short_name   => 'BIV_FS_TRVL_TIME_VAR'
  , p_col_tbl      => l_col_tbl
  , p_col_name     => 'ACTUAL_TRAVEL_TIME_VAR'
  , p_alias_name   => 'bucket'
  , p_prior_code   => poa_dbi_util_pkg.no_priors
  , p_to_date_type => l_to_date_type
  , x_bucket_rec   => l_bucket_rec
  );

  l_view_by := isc_fs_rpt_util_pkg.get_parameter_value
               ( p_param
               , 'VIEW_BY'
               );

  l_stmt := 'select
  ' || l_viewby_select || '
, ' || isc_fs_rpt_util_pkg.get_district_drill_down
       ( l_view_by
       , g_task_tim_var_tbl_func
       , 'ISC_ATTRIBUTE_2'
       ) || '
, ' || isc_fs_rpt_util_pkg.get_detail_drill_down
       ( p_view_by           => l_view_by
       , p_function_name     => g_task_tim_var_dtr_tbl_func
       , p_check_column_name => 'ISC_MEASURE_4'
       , p_column_alias      => 'ISC_ATTRIBUTE_3'
       , p_check_resource    => 'Y'
       ) || '
, ' || isc_fs_rpt_util_pkg.get_bucket_drill_down
       ( p_bucket_rec        => l_bucket_rec
       , p_view_by           => l_view_by
       , p_function_name     => g_task_tim_dtl_func
       , p_check_column_name => 'ISC_MEASURE_5'
       , p_column_alias      => 'ISC_ATTRIBUTE_4'
       , p_extra_params      => '&BIV_FS_TRVL_TIME_VAR='
       , p_check_resource    => 'Y'
     ) || '
, ISC_MEASURE_1
, ISC_MEASURE_2
, ISC_MEASURE_13
, ISC_MEASURE_3
, ISC_MEASURE_12
, ISC_MEASURE_3 ISC_MEASURE_14
, ISC_MEASURE_4
'   || poa_dbi_util_pkg.get_bucket_outer_query
       ( p_bucket_rec => l_bucket_rec
       , p_col_name   => 'ISC_MEASURE_5'
       , p_alias_name => 'ISC_MEASURE_5'
       , p_prefix     => null
       , p_suffix     => null
       , p_total_flag => 'N'
       ) || '
, ISC_MEASURE_21
, ISC_MEASURE_22
, case nvl(isc_measure_22,0) * nvl(isc_measure_21,0)
    when 0 then null
    else ' || isc_fs_rpt_util_pkg.change_column
              ( 'abs(isc_measure_22 - isc_measure_21)'
              , 'prior_diff_total'
              , null
              , 'Y'
              ) || '
  end ISC_MEASURE_23
, ISC_MEASURE_24
'   || poa_dbi_util_pkg.get_bucket_outer_query
       ( p_bucket_rec => l_bucket_rec
       , p_col_name   => 'ISC_MEASURE_25'
       , p_alias_name => 'ISC_MEASURE_25'
       , p_prefix     => null
       , p_suffix     => null
       , p_total_flag => 'N'
       ) || '
, abs( isc_measure_22 - isc_measure_21) ISC_MEASURE_26
from (
select
row_number() over(&ORDER_BY_CLAUSE nulls last , '|| isc_fs_rpt_util_pkg.get_inner_select_col(l_join_tbl) || ')-1 rnk
,iset.* from ( select * from (
select
  record_type
, district_id
, district_id_c
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_tot_trv_dur_min_sch'
       , 'c_count_dur_task'
       , 'ISC_MEASURE_1'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_tot_trv_dur_min_act'
       , 'c_count_dur_task'
       , 'ISC_MEASURE_2'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'abs(p_tot_trv_dur_min_act - p_tot_trv_dur_min_sch)'
       , 'p_count_dur_task'
       , 'ISC_MEASURE_13'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'abs(c_tot_trv_dur_min_act - c_tot_trv_dur_min_sch)'
       , 'c_count_dur_task'
       , 'ISC_MEASURE_3'
       , 'N'
       ) || '
, case nvl(c_tot_trv_dur_min_act,0) * nvl(c_tot_trv_dur_min_sch,0)
    when 0 then null
    else ' || isc_fs_rpt_util_pkg.change_column
              ( isc_fs_rpt_util_pkg.rate_column
                ( 'abs(c_tot_trv_dur_min_act - c_tot_trv_dur_min_sch )'
                , 'c_count_dur_task'
                , null
                , 'N'
                )
              , isc_fs_rpt_util_pkg.rate_column
                ( 'abs(p_tot_trv_dur_min_act - p_tot_trv_dur_min_sch )'
                , 'p_count_dur_task'
                , null
                , 'N'
                )
              , null
              , 'Y'
              ) || '
  end ISC_MEASURE_12
, nvl(c_count_dur_task,0) ISC_MEASURE_4
'   || poa_dbi_util_pkg.get_bucket_outer_query
       ( p_bucket_rec => l_bucket_rec
       , p_col_name   => 'bucket'
       , p_alias_name => 'ISC_MEASURE_5'
       , p_prefix     => 'c_'
       , p_suffix     => '/abs(decode(nvl(c_count_dur_task,0),0,1,c_count_dur_task))*100'
       , p_total_flag => 'N'
       ) ||'
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_tot_trv_dur_min_sch_total'
       , 'c_count_dur_task_total'
       , 'ISC_MEASURE_21'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_tot_trv_dur_min_act_total'
       , 'c_count_dur_task_total'
       , 'ISC_MEASURE_22'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'abs(p_tot_trv_dur_min_act_total - p_tot_trv_dur_min_sch_total) '
       , 'p_count_dur_task_total'
       , 'prior_diff_total'
       , 'N'
       ) || '
, nvl(c_count_dur_task_total,0) ISC_MEASURE_24
'   || poa_dbi_util_pkg.get_bucket_outer_query
       ( p_bucket_rec => l_bucket_rec
       , p_col_name   => 'bucket'
       , p_alias_name => 'ISC_MEASURE_25'
       , p_prefix     => 'c_'
       , p_suffix     => '/abs(decode(c_count_dur_task_total,0,null,c_count_dur_task_total))*100'
       , p_total_flag => 'Y'
       ) || '
from ' || poa_dbi_template_pkg.status_sql
          ( p_fact_name            => l_mv
          , p_where_clause         => l_where_clause
          , p_join_tables          => l_join_tbl
          , p_use_windowing        => 'Y' --'N'
          , p_col_name             => l_col_tbl
          , p_use_grpid            => 'N'
          , p_paren_count          => 3
          , p_filter_where         => '1=1 ) iset '
          , p_generate_viewby      => 'Y'
          );

  --l_stmt := l_stmt || isc_fs_rpt_util_pkg.dump_parameters(p_param);

  poa_dbi_util_pkg.get_custom_rolling_binds
  ( p_custom_output => l_custom_output
  , p_xtd           => l_xtd
  );

  isc_fs_rpt_util_pkg.enhance_time_join
  ( p_query => l_stmt
  , p_trend => 'N'
  );

  x_custom_output := l_custom_output;
  x_custom_sql := l_stmt;

end get_time_var_sql;

procedure get_dist_var_sql
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
  l_view_by          varchar2(200);
  l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_product          varchar2(50);
  l_stmt             varchar2(32700);
  l_distance         varchar2(300);
  l_bucket_rec bis_bucket_pub.bis_bucket_rec_type;
  l_to_date_type     varchar2(200);
  l_drill_across_task  varchar2(1000);

begin

  l_col_tbl  := poa_dbi_util_pkg.poa_dbi_col_tbl();
  l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

  isc_fs_rpt_util_pkg.register_dimension_levels
  ( l_dimension_tbl
  , l_dim_filter_map
  , isc_fs_rpt_util_pkg.G_DISTRICT, 'Y'
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
  , x_uom_suffix       => l_distance
  );

  if l_xtd in ('DAY','WTD','MTD','QTD','YTD') then
    l_to_date_type := 'XTD';
  else
    l_to_date_type := 'RLX';
  end if;

  l_mv := get_fact_mv_name
          ( 'TRAVEL_DIST_VAR'
          , p_param
          , l_custom_output
          );

  poa_dbi_util_pkg.add_column
  ( p_col_tbl      => l_col_tbl
  , p_col_name     => 'tot_trv_dist_act'
  , p_alias_name   => 'tot_trv_dist_act'
  , p_to_date_type => l_to_date_type
  );

  poa_dbi_util_pkg.add_column
  ( p_col_tbl      => l_col_tbl
  , p_col_name     => 'tot_trv_dist_sch'
  , p_alias_name   => 'tot_trv_dist_sch'
  , p_to_date_type => l_to_date_type
  );

  poa_dbi_util_pkg.add_column
  ( p_col_tbl        => l_col_tbl
  , p_col_name     => 'count_dist_task'
  , p_alias_name   => 'count_dist_task'
  , p_to_date_type => l_to_date_type
  );

  poa_dbi_util_pkg.add_bucket_columns
  ( p_short_name   => 'BIV_FS_TRVL_DIST_VAR'
  , p_col_tbl      => l_col_tbl
  , p_col_name     => 'ACTUAL_TRAVEL_DIST_VAR'
  , p_alias_name   => 'bucket'
  , p_prior_code   => poa_dbi_util_pkg.no_priors
  , p_to_date_type => l_to_date_type
  , x_bucket_rec   => l_bucket_rec
  );

  l_view_by := isc_fs_rpt_util_pkg.get_parameter_value
               ( p_param
               , 'VIEW_BY'
               );

  l_stmt := 'select
  ' || l_viewby_select || '
, ' || isc_fs_rpt_util_pkg.get_district_drill_down
       ( l_view_by
       , g_task_dis_var_tbl_func
       , 'ISC_ATTRIBUTE_2'
       ) || '
, ' || isc_fs_rpt_util_pkg.get_detail_drill_down
       ( p_view_by           => l_view_by
       , p_function_name     => g_task_dis_var_dtr_tbl_func
       , p_check_column_name => 'ISC_MEASURE_4'
       , p_column_alias      => 'ISC_ATTRIBUTE_3'
       , p_check_resource    => 'Y'
       ) || '
, ' || isc_fs_rpt_util_pkg.get_bucket_drill_down
       ( p_bucket_rec        => l_bucket_rec
       , p_view_by           => l_view_by
       , p_function_name     => g_task_tim_dtl_func
       , p_check_column_name => 'ISC_MEASURE_5'
       , p_column_alias      => 'ISC_ATTRIBUTE_4'
       , p_extra_params      => '&BIV_FS_TRVL_DIST_VAR='
       , p_check_resource    => 'Y'
       ) || '
, ISC_MEASURE_1
, ISC_MEASURE_2
, ISC_MEASURE_13
, ISC_MEASURE_3
, ISC_MEASURE_12
, ISC_MEASURE_3 ISC_MEASURE_14
, ISC_MEASURE_4
'   || poa_dbi_util_pkg.get_bucket_outer_query
       ( p_bucket_rec => l_bucket_rec
       , p_col_name   => 'ISC_MEASURE_5'
       , p_alias_name => 'ISC_MEASURE_5'
       , p_prefix     => null
       , p_suffix     => null
       , p_total_flag => 'N'
       ) || '
, ISC_MEASURE_21
, ISC_MEASURE_22
, case nvl(isc_measure_22,0) * nvl(isc_measure_21,0)
    when 0 then null
    else ' || isc_fs_rpt_util_pkg.change_column
              ( 'abs(isc_measure_22 - isc_measure_21)'
              , 'prior_diff_total'
              , null
              , 'Y'
              ) || '
  end ISC_MEASURE_23
, ISC_MEASURE_24
'  ||  poa_dbi_util_pkg.get_bucket_outer_query
       ( p_bucket_rec => l_bucket_rec
       , p_col_name   => 'ISC_MEASURE_25'
       , p_alias_name => 'ISC_MEASURE_25'
       , p_prefix     => null
       , p_suffix     => null
       , p_total_flag => 'N'
       ) || '
, abs( isc_measure_22 - isc_measure_21 ) ISC_MEASURE_26
from (
select
row_number() over(&ORDER_BY_CLAUSE nulls last , '|| isc_fs_rpt_util_pkg.get_inner_select_col(l_join_tbl) || ')-1 rnk
, iset.* from ( select * from (
select
  record_type
, district_id
, district_id_c
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_tot_trv_dist_sch'
       , 'c_count_dist_task'
       , 'ISC_MEASURE_1'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_tot_trv_dist_act'
       , 'c_count_dist_task'
       , 'ISC_MEASURE_2'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'abs(p_tot_trv_dist_act - p_tot_trv_dist_sch)'
       , 'p_count_dist_task'
       , 'ISC_MEASURE_13'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'abs(c_tot_trv_dist_act - c_tot_trv_dist_sch)'
       , 'c_count_dist_task'
       , 'ISC_MEASURE_3'
       , 'N'
       ) || '
, case nvl(c_tot_trv_dist_act,0) * nvl(p_tot_trv_dist_sch,0)
    when 0 then NULL
    else ' || isc_fs_rpt_util_pkg.change_column
              ( isc_fs_rpt_util_pkg.rate_column
                ( 'abs(c_tot_trv_dist_act - c_tot_trv_dist_sch)'
                , 'c_count_dist_task'
                , null
                , 'N'
                )
              , isc_fs_rpt_util_pkg.rate_column
                ( 'abs(p_tot_trv_dist_act - p_tot_trv_dist_sch)'
                , 'p_count_dist_task'
                , null
                , 'N'
                )
              , null
              , 'Y'
              ) || '
  end ISC_MEASURE_12
, nvl(c_count_dist_task,0) ISC_MEASURE_4
'   || poa_dbi_util_pkg.get_bucket_outer_query
       ( p_bucket_rec => l_bucket_rec
       , p_col_name   => 'bucket'
       , p_alias_name => 'ISC_MEASURE_5'
       , p_prefix     => 'c_'
       , p_suffix     => '/abs(decode(nvl(c_count_dist_task,0),0,1,c_count_dist_task))*100'
       , p_total_flag => 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_tot_trv_dist_sch_total'
       , 'c_count_dist_task_total'
       , 'ISC_MEASURE_21'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_tot_trv_dist_act_total'
       , 'c_count_dist_task_total'
       , 'ISC_MEASURE_22'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'abs(p_tot_trv_dist_act_total-p_tot_trv_dist_sch_total)'
       , 'p_count_dist_task_total'
       , 'prior_diff_total'
       , 'N'
       ) || '
, nvl(c_count_dist_task_total,0) ISC_MEASURE_24
'   || poa_dbi_util_pkg.get_bucket_outer_query
       ( p_bucket_rec => l_bucket_rec
       , p_col_name   => 'bucket'
       , p_alias_name => 'ISC_MEASURE_25'
       , p_prefix     => 'c_'
       , p_suffix     => '/abs(decode(c_count_dist_task_total,0,null,c_count_dist_task_total))*100'
       , p_total_flag => 'Y'
       ) || '
from ' || poa_dbi_template_pkg.status_sql
          ( p_fact_name            => l_mv
          , p_where_clause         => l_where_clause
          , p_join_tables          => l_join_tbl
          , p_use_windowing        => 'Y' --'N'
          , p_col_name             => l_col_tbl
          , p_use_grpid            => 'N'
          , p_paren_count          => 3
          , p_filter_where         => '1=1 ) iset '
          , p_generate_viewby      => 'Y'
          );

  --l_stmt := l_stmt || isc_fs_rpt_util_pkg.dump_parameters(p_param);

  poa_dbi_util_pkg.get_custom_rolling_binds
  ( p_custom_output => l_custom_output
  , p_xtd           => l_xtd
  );

  isc_fs_rpt_util_pkg.enhance_time_join
  ( p_query => l_stmt
  , p_trend => 'N'
  );

  x_custom_output := l_custom_output;
  x_custom_sql := l_stmt;

end get_dist_var_sql;

procedure get_time_var_dtr_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
)
is

  l_dimension_tbl    isc_fs_rpt_util_pkg.t_dimension_tbl;
  l_dim_filter_map   poa_dbi_util_pkg.poa_dbi_dim_map;
  l_dim_bmap         number;
  l_comparison_type  varchar2(200);
  l_xtd              varchar2(200);
  l_where_clause     varchar2(10000);
  l_mv               varchar2(10000);
  l_stmt             varchar2(32767);

  l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_join_tbl         poa_dbi_util_pkg.poa_dbi_join_tbl;

  l_custom_output    bis_query_attributes_tbl;

  l_curr_suffix      varchar2(2);

  l_rank_order       varchar2(100);

  l_viewby_select    varchar2(400); -- needed to be increased from 200

  l_orderby       varchar2(40);
  l_to_date_type     varchar2(200);
  l_detail_col_tbl isc_fs_rpt_util_pkg.t_detail_column_tbl;

begin

  -- clear out the tables.
  l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();
  l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

  isc_fs_rpt_util_pkg.register_dimension_levels
  ( l_dimension_tbl
  , l_dim_filter_map
  , isc_fs_rpt_util_pkg.G_DISTRICT, 'Y'
  , isc_fs_rpt_util_pkg.G_TRVL_TIME_VAR_DISTRIB, 'N'
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

  l_mv := get_fact_mv_name
          ( 'TRAVEL_TIME_VAR'
          , p_param
          , l_custom_output
          );

   poa_dbi_util_pkg.add_column
   ( p_col_tbl       => l_col_tbl
   , p_col_name     => 'count_dur_task'
   , p_alias_name   => 'count_dur_task'
   , p_to_date_type => l_to_date_type
   );

   l_stmt := 'select
  ' || l_viewby_select || '
, nvl(oset.c_count_dur_task,0) ISC_MEASURE_1
, case avg(oset.c_count_dur_task_total) over() * avg(oset.p_count_dur_task_total) over()
    when 0 then NULL
    else ' || isc_fs_rpt_util_pkg.change_column
              ( isc_fs_rpt_util_pkg.rate_column
                ( 'nvl(oset.c_count_dur_task,0)*100'
                , 'avg(oset.c_count_dur_task_total) over()'
                , NULL
                , 'N'
                )
              , isc_fs_rpt_util_pkg.rate_column
                ( 'nvl(oset.p_count_dur_task,0)*100'
                , 'avg(oset.p_count_dur_task_total) over()'
                , NULL
                , 'N' )
              , NULL
              , 'N'
              ) || '
  end ISC_MEASURE_3
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'oset.c_count_dur_task'
       , 'avg(oset.c_count_dur_task_total) over()'
       , 'ISC_MEASURE_2'
       , 'Y' ) || '
, nvl(avg(c_count_dur_task_total) over(),0) ISC_MEASURE_4
, decode(avg(c_count_dur_task_total) over(),null,null,100) ISC_MEASURE_5
, ''pFunctionName=ISC_FS_TRV_TIM_DIS_RPT_REP&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'' ISC_ATTRIBUTE_1
from
( select * from ( ' || poa_dbi_template_pkg.status_sql
                      ( p_fact_name            => l_mv
                      , p_where_clause         => l_where_clause
                      , p_join_tables          => l_join_tbl
                      , p_use_windowing        => 'N'
                      , p_col_name             => l_col_tbl
                      , p_use_grpid            => 'N'
                      , p_paren_count          => 3
                      , p_filter_where         => ''
                      , p_generate_viewby      => 'Y'
                      );

  l_stmt:= replace( l_stmt
                  , '&ORDER_BY_CLAUSE'
                  , 'ORDER BY NLSSORT(VIEWBYID,''NLS_SORT=BINARY'') ASC '
                  );

  --l_stmt := l_stmt || isc_fs_rpt_util_pkg.dump_parameters(p_param);

  poa_dbi_util_pkg.get_custom_rolling_binds
  ( p_custom_output => l_custom_output
  , p_xtd           => l_xtd
  );

  isc_fs_rpt_util_pkg.enhance_time_join
  ( p_query => l_stmt
  , p_trend => 'N'
  );

  x_custom_sql := l_stmt;
  x_custom_output := l_custom_output;

end get_time_var_dtr_sql;

procedure get_dist_var_dtr_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
)
is
  l_dimension_tbl    isc_fs_rpt_util_pkg.t_dimension_tbl;
  l_dim_filter_map   poa_dbi_util_pkg.poa_dbi_dim_map;
  l_dim_bmap         number;
  l_comparison_type  varchar2(200);
  l_xtd              varchar2(200);
  l_where_clause     varchar2(10000);
  l_mv               varchar2(10000);
  l_stmt             varchar2(32767);

  l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_join_tbl         poa_dbi_util_pkg.poa_dbi_join_tbl;

  l_custom_output    bis_query_attributes_tbl;

  l_curr_suffix      varchar2(2);

  l_rank_order       varchar2(100);

  l_viewby_select    varchar2(400); -- needed to be increased from 200

  l_orderby          varchar2(40);
  l_to_date_type     varchar2(200);
  l_detail_col_tbl   isc_fs_rpt_util_pkg.t_detail_column_tbl;

begin

  -- clear out the tables.
  l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();
  l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

  isc_fs_rpt_util_pkg.register_dimension_levels
  ( l_dimension_tbl
  , l_dim_filter_map
  , isc_fs_rpt_util_pkg.G_DISTRICT, 'Y'
  , isc_fs_rpt_util_pkg.G_TRVL_DIST_VAR_DISTRIB, 'N'
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

  l_mv := get_fact_mv_name
          ( 'TRAVEL_DIST_VAR'
          , p_param
          , l_custom_output
          );

  poa_dbi_util_pkg.add_column
  ( p_col_tbl       => l_col_tbl
  , p_col_name     => 'count_dist_task'
  , p_alias_name   => 'count_dist_task'
  , p_to_date_type => l_to_date_type
  );

  l_stmt := 'select
  ' || l_viewby_select || '
, nvl(oset.c_count_dist_task,0) ISC_MEASURE_1
, case avg(oset.p_count_dist_task_total) over () *  avg(oset.p_count_dist_task_total) over ()
    when  0 then NULL
    else ' || isc_fs_rpt_util_pkg.change_column
              ( isc_fs_rpt_util_pkg.rate_column
                ( 'nvl(oset.c_count_dist_task,0)*100'
                , 'avg(oset.c_count_dist_task_total) over()'
                , NULL
                , 'N'
                )
              , isc_fs_rpt_util_pkg.rate_column
                ( 'nvl(oset.p_count_dist_task,0)*100'
                , 'avg(oset.p_count_dist_task_total) over()'
                , NULL
                , 'N'
                )
              , null
              , 'N'
              ) || '
  end ISC_MEASURE_3
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'oset.c_count_dist_task'
       , 'avg(oset.c_count_dist_task_total) over()'
       , 'ISC_MEASURE_2'
       ,'Y'
       ) || '
, nvl(avg(c_count_dist_task_total) over(),0) ISC_MEASURE_4
, decode (avg(c_count_dist_task_total) over(),null,null,100) ISC_MEASURE_5
, ''pFunctionName=ISC_FS_TRV_TIM_DIS_RPT_REP&VIEW_BY_NAME=VIEW_BY_ID&pParamIds=Y'' ISC_ATTRIBUTE_1
from
( select * from ( ' || poa_dbi_template_pkg.status_sql
                       ( p_fact_name            => l_mv
                       , p_where_clause         => l_where_clause
                       , p_join_tables          => l_join_tbl
                       , p_use_windowing        => 'N'
                       , p_col_name             => l_col_tbl
                       , p_use_grpid            => 'N'
                       , p_paren_count          => 3
                       , p_filter_where         => ''
                       , p_generate_viewby      => 'Y'
                       );

  l_stmt:= replace( l_stmt
                  , '&ORDER_BY_CLAUSE'
                  , 'ORDER BY NLSSORT(VIEWBYID,''NLS_SORT=BINARY'') ASC '
                  );

  poa_dbi_util_pkg.get_custom_rolling_binds
  ( p_custom_output => l_custom_output
  , p_xtd           => l_xtd
  );

  --l_stmt := l_stmt || isc_fs_rpt_util_pkg.dump_parameters(p_param);

  isc_fs_rpt_util_pkg.enhance_time_join
  ( p_query => l_stmt
  , p_trend => 'N'
  );

  x_custom_sql := l_stmt;
  x_custom_output := l_custom_output;

end get_dist_var_dtr_sql;

end ISC_FS_TRV_TIM_DIS_VAR_RPT_PKG;


/
