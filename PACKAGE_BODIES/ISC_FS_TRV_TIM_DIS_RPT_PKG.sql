--------------------------------------------------------
--  DDL for Package Body ISC_FS_TRV_TIM_DIS_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_FS_TRV_TIM_DIS_RPT_PKG" as
/*$Header: iscfstrvrptb.pls 120.2 2006/04/21 04:26:38 nbhamidi noship $ */

  g_task_rep_func        constant varchar2(100) := 'ISC_FS_TRV_TIM_DIS_TBL_REP';
  g_task_tim_dtr_func    constant varchar2(100) := 'ISC_FS_TRV_TIM_DTR_TBL_REP';
  g_task_dis_dtr_func    constant varchar2(100) := 'ISC_FS_TRV_DIS_DTR_TBL_REP';
  g_task_tim_dtl_func    constant varchar2(100) := 'ISC_FS_TRV_TIM_DIS_RPT_REP';
  g_tot_trd_rep_func     constant varchar2(100) := 'ISC_FS_TOT_TRV_TIM_DIS_TRD_REP';
  g_trd_rep_func         constant varchar2(100) := 'ISC_FS_TRV_TIM_DIS_TRD_REP';

function get_fact_mv_name
( p_report_type   in varchar2
, p_param         in bis_pmv_page_parameter_tbl
, p_custom_output in out NOCOPY bis_query_attributes_tbl
)
return varchar2
is

begin

  if p_report_type = 'TRAVEL_TIME_DISTANCE' then

    return '(
       select
         f.record_type
       , f.parent_district_id
       , f.district_id
       , f.district_id_c
       , f.time_id
       , f.period_type_id
       , f.actual_travel_duration_min tot_trv_dur_min
       , f.task_dist_count count_dist_task
       , f.actual_travel_distance_km * &ISC_FS_DIST_FACTOR tot_trv_dist
       , f.task_duration_count count_dur_task
       from isc_fs_017_mv f
     )' ;

  elsif p_report_type = 'TRAVEL_TIME_DISTRIBUTION' then

    return '(
       select
         f.record_type
       , f.parent_district_id
       , f.district_id
       , f.district_id_c
       , f.time_id
       , f.period_type_id
       , f.actual_travel_duration_min tot_trv_dur_min
       , f.task_duration_count count_dur_task
       , f.actual_travel_duration_min_b1
       , f.actual_travel_duration_min_b2
       , f.actual_travel_duration_min_b3
       , f.actual_travel_duration_min_b4
       , f.actual_travel_duration_min_b5
       , f.actual_travel_duration_min_b6
       , f.actual_travel_duration_min_b7
       , f.actual_travel_duration_min_b8
       , f.actual_travel_duration_min_b9
       , f.actual_travel_duration_min_b10
       from isc_fs_017_mv f
     )' ;

  elsif p_report_type = 'TRAVEL_TASK_DETAIL' then

    if isc_fs_rpt_util_pkg.get_parameter_id
       ( p_param
       , isc_fs_rpt_util_pkg.G_DISTRICT
       ) like '%.%' then
      return ' (
       select
         t.task_id
       , t.task_number
       , t.task_type_id
       , t.owner_id
       , t.owner_type
       , t.customer_id
       , decode( t.location_id
               , null, ''ADDRESS_ID''
               , ''LOCATION_ID''
               )  address_type
       , nvl(t.location_id, t.address_id)  address_id
       , ta.sched_travel_duration_min
       , ta.actual_travel_duration_min
       , (( ta.actual_travel_duration_min - ta.sched_travel_duration_min  )*100 )/
            ta.sched_travel_duration_min         travel_duration_var
       , ta.sched_travel_distance_km  * &ISC_FS_DIST_FACTOR sched_travel_distance
       , ta.actual_travel_distance_km * &ISC_FS_DIST_FACTOR actual_travel_distance
       , ((ta.actual_travel_distance_km - ta.sched_travel_distance_km  )*100 )/
           ta.sched_travel_distance_km          travel_dist_var
       , ta.resource_id  assignee_id
       , ta.resource_type  assignee_type
       , ta.resource_id  district_id
       , ta.district_id  parent_district_id
       , to_char(ta.resource_id) || ''.'' || ta.district_id district_id_c
       from
         isc_fs_task_assignmnts_f ta
       , isc_fs_tasks_f t
       where
           t.task_type_rule = ''DISPATCH''
       and t.task_id = ta.task_id
       and ta.deleted_flag <> ''Y''
       and t.source_object_type_code = ''SR''
       and ( ( ta.actual_travel_duration_min is not null and
               nvl(ta.sched_travel_duration_min,0) > 0 ) and /* Bug 5169178 */
             ( ta.actual_travel_distance_km is not null and
               nvl(ta.sched_travel_distance_km,0) > 0 )
           )
       and ta.report_date between &BIS_CURRENT_EFFECTIVE_START_DATE
                              and &BIS_CURRENT_ASOF_DATE
     )';

    else

      return ' (
       select
         t.task_id
       , t.task_number
       , t.task_type_id
       , t.owner_id
       , t.owner_type
       , t.customer_id
       , decode( t.location_id
               , null, ''ADDRESS_ID''
               , ''LOCATION_ID''
               )  address_type
       , nvl(t.location_id, t.address_id)  address_id
       , ta.sched_travel_duration_min
       , ta.actual_travel_duration_min
       , (( ta.actual_travel_duration_min - ta.sched_travel_duration_min  )*100 )/
            ta.sched_travel_duration_min         travel_duration_var
       , ta.sched_travel_distance_km * &ISC_FS_DIST_FACTOR sched_travel_distance
       , ta.actual_travel_distance_km * &ISC_FS_DIST_FACTOR actual_travel_distance
       , (( ta.actual_travel_distance_km - ta.sched_travel_distance_km  )*100 )/
            ta.sched_travel_distance_km          travel_dist_var
       , ta.resource_id  assignee_id
       , ta.resource_type  assignee_type
       , den.prg_id  district_id
       , den.parent_prg_id  parent_district_id
       , to_char(ta.resource_id) || ''.'' || ta.district_id district_id_c
       from
         isc_fs_task_assignmnts_f ta
       , isc_fs_tasks_f t
       , isc_fs_002_mv den
       where
           t.task_type_rule = ''DISPATCH''
       and t.task_id = ta.task_id
       and ta.deleted_flag <> ''Y''
       and ta.district_id = den.rg_id
       and t.source_object_type_code = ''SR''
       and ( ( ta.actual_travel_duration_min is not null and
               nvl(ta.sched_travel_duration_min,0) > 0 ) and /* bug 5169178 */
             ( ta.actual_travel_distance_km is not null and
               nvl(ta.sched_travel_distance_km,0) > 0 )
           )
       and ta.report_date between &BIS_CURRENT_EFFECTIVE_START_DATE
                              and &BIS_CURRENT_ASOF_DATE
     )';
    end if;

  elsif p_report_type = 'TRAVEL_DISTANCE_DISTRIBUTION' then

    return '(
       select
         f.record_type
       , f.parent_district_id
       , f.district_id
       , f.district_id_c
       , f.time_id
       , f.period_type_id
       , f.actual_travel_distance_km * &ISC_FS_DIST_FACTOR tot_trv_dist
       , f.task_dist_count count_dist_task
       , decode(&ISC_FS_DIST_FACTOR,1,f.actual_travel_dist_km_b1,f.actual_travel_dist_mi_b1) actual_travel_dist_b1
       , decode(&ISC_FS_DIST_FACTOR,1,f.actual_travel_dist_km_b2,f.actual_travel_dist_mi_b2) actual_travel_dist_b2
       , decode(&ISC_FS_DIST_FACTOR,1,f.actual_travel_dist_km_b3,f.actual_travel_dist_mi_b3) actual_travel_dist_b3
       , decode(&ISC_FS_DIST_FACTOR,1,f.actual_travel_dist_km_b4,f.actual_travel_dist_mi_b4) actual_travel_dist_b4
       , decode(&ISC_FS_DIST_FACTOR,1,f.actual_travel_dist_km_b5,f.actual_travel_dist_mi_b5) actual_travel_dist_b5
       , decode(&ISC_FS_DIST_FACTOR,1,f.actual_travel_dist_km_b6,f.actual_travel_dist_mi_b6) actual_travel_dist_b6
       , decode(&ISC_FS_DIST_FACTOR,1,f.actual_travel_dist_km_b7,f.actual_travel_dist_mi_b7) actual_travel_dist_b7
       , decode(&ISC_FS_DIST_FACTOR,1,f.actual_travel_dist_km_b8,f.actual_travel_dist_mi_b8) actual_travel_dist_b8
       , decode(&ISC_FS_DIST_FACTOR,1,f.actual_travel_dist_km_b9,f.actual_travel_dist_mi_b9) actual_travel_dist_b9
       , decode(&ISC_FS_DIST_FACTOR,1,f.actual_travel_dist_km_b10,f.actual_travel_dist_mi_b10) actual_travel_dist_b10
       from isc_fs_018_mv f
     )';

  else -- should not happen!!!
    return '';

  end if;

end get_fact_mv_name;

procedure get_tbl_sql
( p_param in bis_pmv_page_parameter_tbl
, x_custom_sql out nocopy varchar2
, x_custom_output out nocopy bis_query_attributes_tbl
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
  l_drill_down       varchar2(1000);
  l_drill_across     varchar2 (1000);

  l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;

  l_join_tbl         poa_dbi_util_pkg.poa_dbi_join_tbl;

  l_custom_output    bis_query_attributes_tbl;
  l_cost_element     varchar2(200);
  l_curr_suffix      varchar2(2);
  l_to_date_type     varchar2(100);
  l_viewby_select    varchar2(400); -- needed to be increased from 200
  l_view_by          varchar2(200);
  l_distance         varchar2(100);

begin

  l_col_tbl  := poa_dbi_util_pkg.poa_dbi_col_tbl();
  l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

  isc_fs_rpt_util_pkg.register_dimension_levels
  ( l_dimension_tbl
  , l_dim_filter_map
  , isc_fs_rpt_util_pkg.G_DISTRICT, 'Y'
--  , isc_fs_rpt_util_pkg.G_DISTANCE_UOM, 'Y'
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

  poa_dbi_util_pkg.add_column
  ( p_col_tbl      => l_col_tbl
  , p_col_name     => 'tot_trv_dur_min'
  , p_alias_name   => 'tot_trv_dur_min'
  , p_grand_total  => 'Y'
  , p_prior_code   => poa_dbi_util_pkg.both_priors
  , p_to_date_type => l_to_date_type
  );

  poa_dbi_util_pkg.add_column
  ( p_col_tbl       => l_col_tbl
  , p_col_name     => 'count_dur_task'
  , p_alias_name   => 'count_dur_task'
  , p_grand_total  => 'Y'
  , p_prior_code   => poa_dbi_util_pkg.both_priors
  , p_to_date_type => l_to_date_type
  );

  poa_dbi_util_pkg.add_column
  ( p_col_tbl      => l_col_tbl
  , p_col_name     => 'tot_trv_dist'
  , p_alias_name   => 'tot_trv_dist'
  , p_grand_total  => 'Y'
  , p_prior_code   => poa_dbi_util_pkg.both_priors
  , p_to_date_type => l_to_date_type
  );

  poa_dbi_util_pkg.add_column
  ( p_col_tbl      => l_col_tbl
  , p_col_name     => 'count_dist_task'
  , p_alias_name   => 'count_dist_task'
  , p_grand_total  => 'Y'
  , p_prior_code   => poa_dbi_util_pkg.both_priors
  , p_to_date_type => l_to_date_type
  );

  l_view_by := isc_fs_rpt_util_pkg.get_parameter_value
               ( p_param
               , 'VIEW_BY'
               );

  l_mv := get_fact_mv_name
          ( 'TRAVEL_TIME_DISTANCE'
          , p_param
          , l_custom_output
          );

  l_stmt := 'select
  ' || l_viewby_select || '
, ISC_MEASURE_1
, ISC_MEASURE_2
, ISC_MEASURE_3
, ISC_MEASURE_4
, ISC_MEASURE_5
, ISC_MEASURE_1 ISC_MEASURE_6
, ISC_MEASURE_8 ISC_MEASURE_8
, ISC_MEASURE_3 ISC_MEASURE_9
, ISC_MEASURE_11
, ISC_MEASURE_12
, ISC_MEASURE_13
, ISC_MEASURE_14
, ISC_MEASURE_15
, ISC_MEASURE_11 ISC_MEASURE_16
, ISC_MEASURE_12 ISC_MEASURE_17
, ISC_MEASURE_18 ISC_MEASURE_18
, ISC_MEASURE_13 ISC_MEASURE_19
, ISC_MEASURE_14 ISC_MEASURE_20
, ' || isc_fs_rpt_util_pkg.get_district_drill_down
       ( l_view_by
       , g_task_rep_func
       , 'ISC_ATTRIBUTE_4'
       ) || '
from ( select
row_number() over(&ORDER_BY_CLAUSE nulls last, ' || isc_fs_rpt_util_pkg.get_inner_select_col(l_join_tbl) || ')-1 rnk
, iset.*
from ( select * from (
select
  record_type
, district_id
, district_id_c
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_tot_trv_dur_min'
       , 'c_count_dur_task'
       , 'ISC_MEASURE_1'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'p_tot_trv_dur_min'
       , 'p_count_dur_task'
       , 'ISC_MEASURE_5'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.change_column
       ( isc_fs_rpt_util_pkg.rate_column
         ( 'c_tot_trv_dur_min'
         , 'c_count_dur_task'
         , null
         , 'N'
         )
       , isc_fs_rpt_util_pkg.rate_column
         ( 'p_tot_trv_dur_min'
         , 'p_count_dur_task'
         , null
         , 'N'
         )
       , 'ISC_MEASURE_2'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_tot_trv_dist'
       , 'c_count_dist_task'
       , 'ISC_MEASURE_3'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'p_tot_trv_dist'
       , 'p_count_dist_task'
       , 'ISC_MEASURE_8'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.change_column
       ( isc_fs_rpt_util_pkg.rate_column
         ( 'c_tot_trv_dist'
         , 'c_count_dist_task'
         , null
         , 'N'
         )
       , isc_fs_rpt_util_pkg.rate_column
         ( 'p_tot_trv_dist'
         , 'p_count_dist_task'
         , null
         , 'N'
         )
       , 'ISC_MEASURE_4'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_tot_trv_dur_min_total'
       , 'c_count_dur_task_total'
       , 'ISC_MEASURE_11'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.change_column
       ( isc_fs_rpt_util_pkg.rate_column
         ( 'c_tot_trv_dur_min_total'
         , 'c_count_dur_task_total'
         , null
         , 'N'
         )
       , isc_fs_rpt_util_pkg.rate_column
         ( 'p_tot_trv_dur_min_total'
         , 'p_count_dur_task_total'
         , null
         , 'N'
         )
       , 'ISC_MEASURE_12'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_tot_trv_dist_total'
       , 'c_count_dist_task_total'
       , 'ISC_MEASURE_13'
       , 'N'
       ) ||'
, ' || isc_fs_rpt_util_pkg.change_column
       ( isc_fs_rpt_util_pkg.rate_column
         ( 'c_tot_trv_dist_total'
         , 'c_count_dist_task_total'
         , null
         , 'N'
         )
       , isc_fs_rpt_util_pkg.rate_column
         ( 'p_tot_trv_dist_total'
         , 'p_count_dist_task_total'
         , null
         , 'N'
         )
       , 'ISC_MEASURE_14'
       , 'N'
       ) || '
, p_tot_trv_dur_min_total ISC_MEASURE_15
, p_tot_trv_dist_total ISC_MEASURE_18
from ' || poa_dbi_template_pkg.status_sql
          ( p_fact_name            => l_mv
          , p_where_clause         => l_where_clause
          , p_join_tables          => l_join_tbl
          , p_use_windowing        => 'Y'
          , p_col_name             => l_col_tbl
          , p_use_grpid            => 'N'
          , p_paren_count          => 3
          , p_filter_where         => '1=1 ) iset '
          , p_generate_viewby      => 'Y'
          );

  --  l_stmt := l_stmt || isc_fs_rpt_util_pkg.dump_parameters(p_param);
  poa_dbi_util_pkg.get_custom_rolling_binds
  ( p_custom_output => l_custom_output
  , p_xtd           => l_xtd
  );

  isc_fs_rpt_util_pkg.enhance_time_join
  ( p_query => l_stmt
  , p_trend => 'N'
  );

  x_custom_output := l_custom_output;
  x_custom_sql    := l_stmt;

end get_tbl_sql;

-----start of  detailed report ------------------------------------------

procedure get_dtl_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
)
as

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
  l_cost_element     varchar2(200);
  l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_stmt             varchar2(32767);
  l_rank_order       varchar2(200);
  l_detail_col_tbl   isc_fs_rpt_util_pkg.t_detail_column_tbl;
  l_order_by         varchar2(200);
  l_asc_desc         varchar2(100);
  l_distance         varchar2(100);

begin

  l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();
  l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

  isc_fs_rpt_util_pkg.register_dimension_levels
  ( l_dimension_tbl
  , l_dim_filter_map
  , isc_fs_rpt_util_pkg.G_CUSTOMER, 'N'
  , isc_fs_rpt_util_pkg.G_DISTRICT, 'Y'
  , isc_fs_rpt_util_pkg.G_TASK_TYPE, 'N'
  , isc_fs_rpt_util_pkg.G_TASK_OWNER, 'N'
  , isc_fs_rpt_util_pkg.G_TASK_ADDRESS, 'N'
  , isc_fs_rpt_util_pkg.G_TASK_ASSIGNEE, 'N'
  );

  isc_fs_rpt_util_pkg.process_parameters
  ( p_param            => p_param
  , p_dimension_tbl    => l_dimension_tbl
  , p_dim_filter_map   => l_dim_filter_map
  , p_trend            => 'D'
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

  l_mv := get_fact_mv_name
          ( 'TRAVEL_TASK_DETAIL'
          , p_param
          , l_custom_output
          );

  isc_fs_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'task_number'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'task_number'
  );

  isc_fs_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'task_id'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'task_id'
  );

  isc_fs_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_dimension_level    => isc_fs_rpt_util_pkg.G_TASK_TYPE
  , p_column_key         => 'task_type'
  );

  isc_fs_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_dimension_level    => isc_fs_rpt_util_pkg.G_TASK_OWNER
  , p_column_key         => 'task_owner'
  );

  isc_fs_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_dimension_level    => isc_fs_rpt_util_pkg.G_TASK_ASSIGNEE
  , p_column_key         => 'task_assignee'
  );

  isc_fs_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'sched_travel_duration_min'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'sched_travel_duration_min'
  );

  isc_fs_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'actual_travel_duration_min'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'actual_travel_duration_min'
  );

  isc_fs_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'travel_duration_var'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'travel_duration_var'
  );

  isc_fs_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'sched_travel_distance'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'sched_travel_distance'
  );

  isc_fs_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'actual_travel_distance'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'actual_travel_distance'
  );

  isc_fs_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'travel_dist_var'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'travel_dist_var'
  );

  isc_fs_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_dimension_level    => isc_fs_rpt_util_pkg.G_CUSTOMER
  , p_column_key         => 'customer'
  );

  isc_fs_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_dimension_level    => isc_fs_rpt_util_pkg.G_TASK_ADDRESS
  , p_column_key         => 'address'
  );

  l_order_by := isc_fs_rpt_util_pkg.get_parameter_value
                ( p_param
                , 'ORDERBY'
                );

  if l_order_by like '% DESC%' then
    l_asc_desc := ' desc ';
  else
    l_asc_desc := ' asc ';
  end if;

  l_rank_order := 'order by ' ||
                  case
                    when l_order_by like '%ISC_MEASURE_1%' then
                      'sched_travel_duration_min'
                    when l_order_by like '%ISC_MEASURE_2%' then
                      'actual_travel_duration_min'
                    when l_order_by like '%ISC_MEASURE_3%' then
                      'travel_duration_var'
                    when l_order_by like '%ISC_MEASURE_4%' then
                      'sched_travel_distance'
                    when l_order_by like '%ISC_MEASURE_5%' then
                      'actual_travel_distance'
                    when l_order_by like '%ISC_MEASURE_6%' then
                      'travel_dist_var'
                  end ||
                  l_asc_desc ||
                  'nulls last, task_number';

   l_stmt := 'select
  oset.task_number ISC_ATTRIBUTE_1
, ' || isc_fs_rpt_util_pkg.get_detail_column
       ( l_detail_col_tbl
       , 'task_type'
       , 'ISC_ATTRIBUTE_2'
       ) || '
, ' || isc_fs_rpt_util_pkg.get_detail_column
       ( l_detail_col_tbl
       , 'task_owner'
       , 'ISC_ATTRIBUTE_3'
       ) || '
, ' || isc_fs_rpt_util_pkg.get_detail_column
       ( l_detail_col_tbl
       , 'task_assignee'
       , 'ISC_ATTRIBUTE_4'
       ) || '
, oset.sched_travel_duration_min ISC_MEASURE_1
, oset.actual_travel_duration_min ISC_MEASURE_2
, oset.travel_duration_var ISC_MEASURE_3
, oset.sched_travel_distance ISC_MEASURE_4
, oset.actual_travel_distance ISC_MEASURE_5
, oset.travel_dist_var ISC_MEASURE_6
, ' || isc_fs_rpt_util_pkg.get_detail_column
       ( l_detail_col_tbl
       , 'customer'
       , 'ISC_ATTRIBUTE_6'
       ) || '
, ' || isc_fs_rpt_util_pkg.get_detail_column
       ( l_detail_col_tbl
       , 'address'
       , 'ISC_ATTRIBUTE_7'
       ) || '
, ' || isc_fs_rpt_util_pkg.get_task_detail_page_function
       ( 'oset.task_id' ) || ' ISC_ATTRIBUTE_8
from
' || isc_fs_rpt_util_pkg.detail_sql
     ( p_detail_col_tbl => l_detail_col_tbl
     , p_dimension_tbl  => l_dimension_tbl
     , p_mv_name        => l_mv
     , p_where_clause   => l_where_clause
     , p_rank_order     => l_rank_order
     , p_override_date_clause => ' actual_travel_duration_min >= &ISC_FS_LOW and' ||
                                 ' actual_travel_duration_min < &ISC_FS_HIGH and' ||
                                 ' actual_travel_distance >= &ISC_FS_LOW1 and' ||
                                 ' actual_travel_distance < &ISC_FS_HIGH1 and' ||
                                 ' travel_duration_var >= &ISC_FS_LOW2 and' ||
                                 ' travel_duration_var < &ISC_FS_HIGH2 and' ||
                                 ' travel_dist_var >= &ISC_FS_LOW3 and' ||
                                 ' travel_dist_var < &ISC_FS_HIGH3 '
     );

  isc_fs_rpt_util_pkg.bind_low_high
  ( p_param
  , isc_fs_rpt_util_pkg.G_TRVL_TIME_DISTRIB
  , 'BIV_FS_TRVL_TIME'
  , l_custom_output
  );

  isc_fs_rpt_util_pkg.bind_low_high
  ( p_param
  , isc_fs_rpt_util_pkg.G_TRVL_DIST_DISTRIB
  , 'BIV_FS_TRVL_DIST'
  , l_custom_output
  , '&ISC_FS_LOW1'
  , '&ISC_FS_HIGH1'
  );


  isc_fs_rpt_util_pkg.bind_low_high
  ( p_param
  , isc_fs_rpt_util_pkg.G_TRVL_TIME_VAR_DISTRIB
  , 'BIV_FS_TRVL_TIME_VAR'
  , l_custom_output
  , '&ISC_FS_LOW2'
  , '&ISC_FS_HIGH2'
  );

  isc_fs_rpt_util_pkg.bind_low_high
  ( p_param
  , isc_fs_rpt_util_pkg.G_TRVL_DIST_VAR_DISTRIB
  , 'BIV_FS_TRVL_DIST_VAR'
  , l_custom_output
  , '&ISC_FS_LOW3'
  , '&ISC_FS_HIGH3'
  );

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  --l_stmt := l_stmt || isc_fs_rpt_util_pkg.dump_parameters(p_param);
  isc_fs_rpt_util_pkg.enhance_time_join
  ( p_query => l_stmt
  , p_trend => 'N'
  );

  x_custom_sql    := l_stmt;
  x_custom_output := l_custom_output;

end get_dtl_sql; -- the detail query ends here

-------------------------trend query--------------------------------------------
procedure get_trd_sql
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
  l_stmt             varchar2(32767);
  l_to_date_type     varchar2(200);
  l_distance         varchar2(30);
  l_view_by          varchar2(100);

begin

  l_col_tbl  := poa_dbi_util_pkg.poa_dbi_col_tbl();
  l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

  isc_fs_rpt_util_pkg.register_dimension_levels
  ( l_dimension_tbl
  , l_dim_filter_map
  , isc_fs_rpt_util_pkg.G_DISTRICT, 'Y'
  --  , isc_fs_rpt_util_pkg.G_DISTANCE_UOM, 'Y'
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

  poa_dbi_util_pkg.add_column
  ( p_col_tbl      => l_col_tbl
  , p_col_name     => 'tot_trv_dur_min'
  , p_alias_name   => 'tot_trv_dur_min'
  , p_grand_total  => 'N'
  , p_prior_code   => poa_dbi_util_pkg.both_priors
  , p_to_date_type => l_to_date_type
  );

  poa_dbi_util_pkg.add_column
  ( p_col_tbl      => l_col_tbl
  , p_col_name     => 'count_dur_task'
  , p_alias_name   => 'count_dur_task'
  , p_grand_total  => 'N'
  , p_prior_code   => poa_dbi_util_pkg.both_priors
  , p_to_date_type => l_to_date_type
  );

  poa_dbi_util_pkg.add_column
  ( p_col_tbl      => l_col_tbl
  , p_col_name     => 'tot_trv_dist'
  , p_alias_name   => 'tot_trv_dist'
  , p_grand_total  => 'N'
  , p_prior_code   => poa_dbi_util_pkg.both_priors
  , p_to_date_type => l_to_date_type
  );

  poa_dbi_util_pkg.add_column
  ( p_col_tbl      => l_col_tbl
  , p_col_name     => 'count_dist_task'
  , p_alias_name   => 'count_dist_task'
  , p_grand_total  => 'N'
  , p_prior_code   => poa_dbi_util_pkg.both_priors
  , p_to_date_type => l_to_date_type
  );

  l_mv := get_fact_mv_name
          ( 'TRAVEL_TIME_DISTANCE'
          , p_param
          , l_custom_output
          );

  l_stmt := 'select
  cal.name VIEWBY ' ||
     isc_fs_rpt_util_pkg.get_trend_drill
     ( l_xtd
     , g_trd_rep_func
     , 'ISC_ATTRIBUTE_3'
     , 'ISC_ATTRIBUTE_4'
     ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_tot_trv_dur_min'
       , 'c_count_dur_task'
       , 'ISC_MEASURE_2'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.change_column
       ( isc_fs_rpt_util_pkg.rate_column
         ( 'c_tot_trv_dur_min'
         , 'c_count_dur_task'
         , NULL
         , 'N'
         )
       , isc_fs_rpt_util_pkg.rate_column
         ( 'p_tot_trv_dur_min'
         , 'p_count_dur_task'
         , NULL
         , 'N'
         )
       , 'ISC_MEASURE_3'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_tot_trv_dist'
       , 'c_count_dist_task'
       , NULL
       , 'N'
       ) || ' ISC_MEASURE_5
, ' || isc_fs_rpt_util_pkg.change_column
       ( isc_fs_rpt_util_pkg.rate_column
         ( 'c_tot_trv_dist'
         , 'c_count_dist_task'
         , NULL
         , 'N'
         )
       , isc_fs_rpt_util_pkg.rate_column
         ( 'p_tot_trv_dist'
         , 'p_count_dist_task'
         , NULL
         , 'N'
         )
       , 'ISC_MEASURE_6'
       , 'N'
       ) || '
from ' || poa_dbi_template_pkg.trend_sql
          ( p_xtd                  => l_xtd
          , p_comparison_type      => l_comparison_type
          , p_fact_name            => l_mv
          , p_where_clause         => l_where_clause
          , p_col_name             => l_col_tbl
          , p_use_grpid            => 'N'
          );

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  --  l_stmt := l_stmt || isc_fs_rpt_util_pkg.dump_parameters(p_param);

  isc_fs_rpt_util_pkg.enhance_time_join
  ( p_query => l_stmt
  , p_trend => 'Y'
  );

  x_custom_sql := l_stmt;

  x_custom_output := l_custom_output;

  poa_dbi_util_pkg.get_custom_rolling_binds
  ( p_custom_output => l_custom_output
  , p_xtd           => l_xtd
  );

  x_custom_output := l_custom_output;

  poa_dbi_util_pkg.get_custom_trend_binds
  ( x_custom_output     => l_custom_output
  , p_xtd               => l_xtd
  , p_comparison_type   => l_comparison_type
  );

  if l_custom_output is not null then
    for i in 1..l_custom_output.count loop
      x_custom_output.extend;
      x_custom_output(x_custom_output.count) := l_custom_output(i);
    end loop;
  end if;

end get_trd_sql;

procedure get_tot_trd_sql
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
  l_stmt             varchar2(32767);
  l_to_date_type     varchar2(200);
  l_distance         varchar2(30);
  l_view_by          varchar2(100);

begin

  l_col_tbl  := poa_dbi_util_pkg.poa_dbi_col_tbl();
  l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

  isc_fs_rpt_util_pkg.register_dimension_levels
  ( l_dimension_tbl
  , l_dim_filter_map
  , isc_fs_rpt_util_pkg.G_DISTRICT, 'Y'
  --  , isc_fs_rpt_util_pkg.G_DISTANCE_UOM, 'Y'
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

  poa_dbi_util_pkg.add_column
  ( p_col_tbl      => l_col_tbl
  , p_col_name     => 'tot_trv_dur_min'
  , p_alias_name   => 'tot_trv_dur_min'
  , p_grand_total  => 'N'
  , p_prior_code   => poa_dbi_util_pkg.both_priors
  , p_to_date_type => l_to_date_type
  );

  poa_dbi_util_pkg.add_column
  ( p_col_tbl      => l_col_tbl
  , p_col_name     => 'count_dur_task'
  , p_alias_name   => 'count_dur_task'
  , p_grand_total  => 'N'
  , p_prior_code   => poa_dbi_util_pkg.both_priors
  , p_to_date_type => l_to_date_type
  );

  poa_dbi_util_pkg.add_column
  ( p_col_tbl      => l_col_tbl
  , p_col_name     => 'tot_trv_dist'
  , p_alias_name   => 'tot_trv_dist'
  , p_grand_total  => 'N'
  , p_prior_code   => poa_dbi_util_pkg.both_priors
  , p_to_date_type => l_to_date_type
  );

  poa_dbi_util_pkg.add_column
  ( p_col_tbl      => l_col_tbl
  , p_col_name     => 'count_dist_task'
  , p_alias_name   => 'count_dist_task'
  , p_grand_total  => 'N'
  , p_prior_code   => poa_dbi_util_pkg.both_priors
  , p_to_date_type => l_to_date_type
  );

  l_mv := get_fact_mv_name
          ( 'TRAVEL_TIME_DISTANCE'
          , p_param
          , l_custom_output
          );

  l_stmt := 'select
  cal.name VIEWBY ' ||
     isc_fs_rpt_util_pkg.get_trend_drill
     ( l_xtd
     , g_tot_trd_rep_func
     , 'ISC_ATTRIBUTE_3'
     , 'ISC_ATTRIBUTE_4'
     ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_tot_trv_dur_min'
       , '60'
       , 'ISC_MEASURE_2'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.change_column
       ( isc_fs_rpt_util_pkg.rate_column
         ( 'c_tot_trv_dur_min'
         , '60'
         , NULL
         , 'N'
         )
       , isc_fs_rpt_util_pkg.rate_column
         ( 'p_tot_trv_dur_min'
         , '60'
         , NULL
         , 'N'
         )
       , 'ISC_MEASURE_3'
       , 'N'
       ) || '
, c_tot_trv_dist ISC_MEASURE_5
, ' || isc_fs_rpt_util_pkg.change_column
       ( 'c_tot_trv_dist'
       , 'p_tot_trv_dist'
       , 'ISC_MEASURE_6'
       , 'N'
       ) || '
from ' || poa_dbi_template_pkg.trend_sql
          ( p_xtd                  => l_xtd
          , p_comparison_type      => l_comparison_type
          , p_fact_name            => l_mv
          , p_where_clause         => l_where_clause
          , p_col_name             => l_col_tbl
          , p_use_grpid            => 'N'
          );

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  --  l_stmt := l_stmt || isc_fs_rpt_util_pkg.dump_parameters(p_param);

  isc_fs_rpt_util_pkg.enhance_time_join
  ( p_query => l_stmt
  , p_trend => 'Y'
  );

  x_custom_sql := l_stmt;

  x_custom_output := l_custom_output;

  poa_dbi_util_pkg.get_custom_rolling_binds
  ( p_custom_output => l_custom_output
  , p_xtd           => l_xtd
  );

  x_custom_output := l_custom_output;

  poa_dbi_util_pkg.get_custom_trend_binds
  ( x_custom_output     => l_custom_output
  , p_xtd               => l_xtd
  , p_comparison_type   => l_comparison_type
  );

  if l_custom_output is not null then
    for i in 1..l_custom_output.count loop
      x_custom_output.extend;
      x_custom_output(x_custom_output.count) := l_custom_output(i);
    end loop;
  end if;

end get_tot_trd_sql;

procedure get_time_bucket_sql
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
  , isc_fs_rpt_util_pkg.G_DISTRICT , 'Y'
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
          ( 'TRAVEL_TIME_DISTRIBUTION'
          , p_param
          , l_custom_output
          );

  poa_dbi_util_pkg.add_column
  ( p_col_tbl      => l_col_tbl
  , p_col_name     => 'tot_trv_dur_min'
  , p_alias_name   => 'tot_trv_dur_min'
  , p_to_date_type => l_to_date_type
  );

  poa_dbi_util_pkg.add_column
  ( p_col_tbl      => l_col_tbl
  , p_col_name     => 'count_dur_task'
  , p_alias_name   => 'count_dur_task'
  , p_to_date_type => l_to_date_type
  );

  poa_dbi_util_pkg.add_bucket_columns
  ( p_short_name   => 'BIV_FS_TRVL_TIME'
  , p_col_tbl      => l_col_tbl
  , p_col_name     => 'actual_travel_duration_min'
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
       , g_task_tim_dtr_func
       , 'ISC_ATTRIBUTE_2'
       ) || '
, ' || isc_fs_rpt_util_pkg.get_detail_drill_down
       ( p_view_by           => l_view_by
       , p_function_name     => g_task_tim_dtl_func
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
       , p_extra_params      => '&BIV_FS_TRVL_TIME='
       , p_check_resource    => 'Y'
       ) || '
, ISC_MEASURE_2
, ISC_MEASURE_3
, ISC_MEASURE_4
' || poa_dbi_util_pkg.get_bucket_outer_query
     ( p_bucket_rec => l_bucket_rec
     , p_col_name   => 'ISC_MEASURE_5'
     , p_alias_name => 'ISC_MEASURE_5'
     , p_prefix     => null
     , p_suffix     => null
     , p_total_flag => 'N'
     ) || '
, ISC_MEASURE_22
, ISC_MEASURE_23
, ISC_MEASURE_24
' ||  poa_dbi_util_pkg.get_bucket_outer_query
      ( p_bucket_rec => l_bucket_rec
      , p_col_name   => 'ISC_MEASURE_25'
      , p_alias_name => 'ISC_MEASURE_25'
      , p_prefix     => null
      , p_suffix     => null
      , p_total_flag => 'N'
      ) || '
from (
select
row_number() over(&ORDER_BY_CLAUSE nulls last, '|| isc_fs_rpt_util_pkg.get_inner_select_col(l_join_tbl) || ')-1 rnk
,iset.* from ( select * from (
select
  record_type
, district_id
, district_id_c
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_tot_trv_dur_min'
       , 'c_count_dur_task'
       , 'ISC_MEASURE_2'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.change_column
       ( isc_fs_rpt_util_pkg.rate_column
         ( 'c_tot_trv_dur_min'
         , 'c_count_dur_task'
         , null
         , 'N'
         )
       , isc_fs_rpt_util_pkg.rate_column
         ( 'p_tot_trv_dur_min'
         , 'p_count_dur_task'
         , null
         , 'N'
         )
       , 'ISC_MEASURE_3'
       , 'N'
       ) || '
,  nvl(c_count_dur_task,0)  ISC_MEASURE_4
' || poa_dbi_util_pkg.get_bucket_outer_query
     ( p_bucket_rec => l_bucket_rec
     , p_col_name   => 'bucket'
     , p_alias_name => 'ISC_MEASURE_5'
     , p_prefix     => 'nvl(c_'
     , p_suffix     => ',0)/abs(decode(c_count_dur_task,0,null,c_count_dur_task))*100'
     , p_total_flag => 'N'
     ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_tot_trv_dur_min_total'
       , 'c_count_dur_task_total'
       , 'ISC_MEASURE_22'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.change_column
       ( isc_fs_rpt_util_pkg.rate_column
         ( 'c_tot_trv_dur_min_total'
         , 'c_count_dur_task_total'
         , null
         , 'N'
         )
       , isc_fs_rpt_util_pkg.rate_column
         ( 'p_tot_trv_dur_min_total'
         , 'p_count_dur_task_total'
         , null
         , 'N'
         )
       , 'ISC_MEASURE_23'
       , 'N'
       ) || '
, nvl(c_count_dur_task_total,0) ISC_MEASURE_24
' || poa_dbi_util_pkg.get_bucket_outer_query
     ( p_bucket_rec => l_bucket_rec
     , p_col_name   => 'bucket'
     , p_alias_name => 'ISC_MEASURE_25'
     , p_prefix     => 'nvl(c_'
     , p_suffix     => ',0)/abs(decode(c_count_dur_task_total,0,null,c_count_dur_task_total))*100'
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
          , p_filter_where         => 'isc_measure_4 <> 0 ) iset '
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
  x_custom_sql      := l_stmt;

end get_time_bucket_sql;

procedure get_distance_bucket_sql
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
  l_bucket_rec       bis_bucket_pub.bis_bucket_rec_type;
  l_bucket_name      varchar2(100);
  l_to_date_type     varchar2(200);
  l_drill_across_task  varchar2(1000);
  l_distance         varchar2(100);

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
  , x_uom_suffix        => l_distance
  );

  if l_xtd in ('DAY','WTD','MTD','QTD','YTD') then
    l_to_date_type := 'XTD';
  else
    l_to_date_type := 'RLX';
  end if;

  l_mv := get_fact_mv_name
          ( 'TRAVEL_DISTANCE_DISTRIBUTION'
          , p_param
          , l_custom_output
          );

  poa_dbi_util_pkg.add_column
  ( p_col_tbl      => l_col_tbl
  , p_col_name     => 'tot_trv_dist'
  , p_alias_name   => 'tot_trv_dist'
  , p_to_date_type => l_to_date_type
  );

  poa_dbi_util_pkg.add_column
  ( p_col_tbl        => l_col_tbl
  , p_col_name     => 'count_dist_task'
  , p_alias_name   => 'count_dist_task'
  , p_to_date_type => l_to_date_type
  );

  poa_dbi_util_pkg.add_bucket_columns
  ( p_short_name   => 'BIV_FS_TRVL_DIST'
  , p_col_tbl      => l_col_tbl
  , p_col_name     => 'actual_travel_dist'
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
       , g_task_dis_dtr_func
       , 'ISC_ATTRIBUTE_2'
       ) || '
, ' || isc_fs_rpt_util_pkg.get_detail_drill_down
       ( p_view_by           => l_view_by
       , p_function_name     => g_task_tim_dtl_func
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
       , p_extra_params      => '&BIV_FS_TRVL_DIST='
       , p_check_resource    => 'Y'
       ) || '
, ISC_MEASURE_2
, ISC_MEASURE_3
, ISC_MEASURE_4
' || poa_dbi_util_pkg.get_bucket_outer_query
     ( p_bucket_rec => l_bucket_rec
     , p_col_name   => 'ISC_MEASURE_5'
     , p_alias_name => 'ISC_MEASURE_5'
     , p_prefix     => null
     , p_suffix     => null
     , p_total_flag => 'N'
     ) || '
, ISC_MEASURE_22
, ISC_MEASURE_23
, ISC_MEASURE_24
' || poa_dbi_util_pkg.get_bucket_outer_query
     ( p_bucket_rec => l_bucket_rec
     , p_col_name   => 'ISC_MEASURE_25'
     , p_alias_name => 'ISC_MEASURE_25'
     , p_prefix     => null
     , p_suffix     => null
     , p_total_flag => 'N'
     ) || '
from (
select
row_number() over(&ORDER_BY_CLAUSE nulls last , '|| isc_fs_rpt_util_pkg.get_inner_select_col(l_join_tbl) || ')-1 rnk
,iset.* from ( select * from (
select
  record_type
, district_id
, district_id_c
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_tot_trv_dist'
       , 'c_count_dist_task'
       , 'ISC_MEASURE_2'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.change_column
       ( isc_fs_rpt_util_pkg.rate_column
         ( 'c_tot_trv_dist'
         , 'c_count_dist_task'
         , null
         , 'N'
         )
       , isc_fs_rpt_util_pkg.rate_column
         ( 'p_tot_trv_dist'
         , 'p_count_dist_task'
         , null
         , 'N'
         )
       , 'ISC_MEASURE_3'
       , 'N'
       ) || '
,  nvl(c_count_dist_task,0)  ISC_MEASURE_4
' || poa_dbi_util_pkg.get_bucket_outer_query
     ( p_bucket_rec => l_bucket_rec
     , p_col_name   => 'bucket'
     , p_alias_name => 'ISC_MEASURE_5'
     , p_prefix     => 'nvl(c_'
     , p_suffix     => ',0)/abs(decode(c_count_dist_task,0,null,c_count_dist_task))*100'
     , p_total_flag => 'N'
     ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_tot_trv_dist_total'
       , 'c_count_dist_task_total'
       , 'ISC_MEASURE_22'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.change_column
       ( isc_fs_rpt_util_pkg.rate_column
         ( 'c_tot_trv_dist_total'
         , 'c_count_dist_task_total'
         , null
         , 'N'
         )
       , isc_fs_rpt_util_pkg.rate_column
         ( 'p_tot_trv_dist_total'
         , 'p_count_dist_task_total'
         , null
         , 'N'
         )
       , 'ISC_MEASURE_23'
       , 'N'
       ) ||'
, nvl(c_count_dist_task_total,0) ISC_MEASURE_24
' || poa_dbi_util_pkg.get_bucket_outer_query
     ( p_bucket_rec => l_bucket_rec
     , p_col_name   => 'bucket'
     , p_alias_name => 'ISC_MEASURE_25'
     , p_prefix     => 'nvl(c_'
     , p_suffix     => ',0)/abs(decode(c_count_dist_task_total,0,null,c_count_dist_task_total))*100'
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
          , p_filter_where         => 'isc_measure_4 <> 0 ) iset '
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

end get_distance_bucket_sql;

end ISC_FS_TRV_TIM_DIS_RPT_PKG;

/
