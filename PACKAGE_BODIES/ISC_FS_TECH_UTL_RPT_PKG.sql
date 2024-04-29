--------------------------------------------------------
--  DDL for Package Body ISC_FS_TECH_UTL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_FS_TECH_UTL_RPT_PKG" AS
/*$Header: iscfstutlrptb.pls 120.1 2005/11/24 18:36:07 kreardon noship $ */
function get_fact_mv_name
( p_report_type   in varchar2
, p_param         in bis_pmv_page_parameter_tbl
, p_dim_bmap      in number
, p_custom_output in out nocopy bis_query_attributes_tbl
)
return varchar2
is
begin

  if p_report_type = 'ACTUAL_HRS' then

      isc_fs_rpt_util_pkg.bind_group_id
        ( p_dim_bmap
        , p_custom_output
        , isc_fs_rpt_util_pkg.G_TASK_TYPE
        );

       -- R12 resource type
        return '(
      select
        f.record_type
       ,f.parent_district_id
       ,f.district_id
       ,district_id_c
       ,f.task_type_id
       ,f.time_id
       ,f.period_type_id
       ,f.actual_effort_hrs  Labor_Hrs
       ,f.actual_travel_duration_hrs  Travel_Hrs
       ,nvl(f.actual_effort_hrs,0) + nvl(f.actual_travel_duration_hrs,0) Total_Act_Hrs
      from isc_fs_013_mv f
      where f.grp_id = &ISC_GRP_ID)';

  elsif p_report_type = 'PLANNED_HRS' then

       -- R12 resource type
      return '(
      select
        f.record_type
       ,f.parent_district_id
       ,f.district_id
       ,district_id_c
       ,-999 task_type_id
       ,f.time_id
       ,f.period_type_id
       ,f.planned_hrs Total_Planned_Hrs
      from isc_fs_014_mv f)';

  else -- should not happen!!!
    return '';

  end if;

end get_fact_mv_name;


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

  l_col_tbl1         poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_col_tbl2         poa_dbi_util_pkg.poa_dbi_col_tbl;

  l_mv               VARCHAR2 (10000);
  l_mv_tbl          poa_dbi_util_pkg.poa_dbi_mv_tbl;
  l_view_by          varchar2(200);

  l_stmt             varchar2(32700);
  l_cur_planned_hours             varchar2(35);
  l_prev_planned_hours            varchar2(35);
  l_to_date_type     varchar2(20);

begin

  isc_fs_rpt_util_pkg.register_dimension_levels
  ( l_dimension_tbl
  , l_dim_filter_map
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

  l_col_tbl1 := poa_dbi_util_pkg.poa_dbi_col_tbl();
  l_col_tbl2 := poa_dbi_util_pkg.poa_dbi_col_tbl();
  l_mv_tbl := poa_dbi_util_pkg.poa_dbi_mv_tbl ();

  poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl1
                       , p_col_name     => 'Labor_Hrs'
                       , p_alias_name   => 'Labor_Hrs'
                       , p_grand_total  => 'Y'
                       , p_prior_code   => poa_dbi_util_pkg.both_priors
                       , p_to_date_type => l_to_date_type
                       );

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl1
                             , p_col_name     => 'Travel_Hrs'
                             , p_alias_name   => 'Travel_Hrs'
                             , p_grand_total  => 'Y'
                      , p_prior_code   => poa_dbi_util_pkg.both_priors
                             , p_to_date_type => l_to_date_type
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl1
                             , p_col_name     => 'Total_Act_Hrs'
                             , p_alias_name   => 'Total_Act_Hrs'
                             , p_grand_total  => 'Y'
                             , p_prior_code   => poa_dbi_util_pkg.both_priors
                             , p_to_date_type => l_to_date_type
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl2
                             , p_col_name     => 'Total_Planned_Hrs'
                             , p_alias_name   => 'Total_Planned_Hrs'
                             , p_grand_total  => 'Y'
                      , p_prior_code   => poa_dbi_util_pkg.both_priors
                             , p_to_date_type => l_to_date_type
                             );

  l_mv_tbl.extend;
  l_mv_tbl(1).mv_name := 'MV_PLACEHOLDER1';
  l_mv_tbl(1).mv_col := l_col_tbl1;
  l_mv_tbl(1).mv_where := l_where_clause;
  l_mv_tbl(1).in_join_tbls := NULL;
  l_mv_tbl(1).use_grp_id := 'N';

  l_mv_tbl.extend;
  l_mv_tbl(2).mv_name := 'MV_PLACEHOLDER2';
  l_mv_tbl(2).mv_col := l_col_tbl2;
  l_mv_tbl(2).mv_where := replace(l_where_clause, '&' || isc_fs_rpt_util_pkg.G_TASK_TYPE, '-999');
  l_mv_tbl(2).in_join_tbls := NULL;
  l_mv_tbl(2).use_grp_id := 'N';

  l_stmt := poa_dbi_template_pkg.union_all_status_sql
                   (p_mv       => l_mv_tbl
                   ,p_join_tables     => l_join_tbl
                   ,p_use_windowing   => 'Y'
                   ,p_paren_count     => 3
                   ,p_filter_where    => ' (ISC_Measure_1 > 0 or ISC_Measure_2 > 0 or ISC_Measure_3 > 0 or ISC_Measure_13 > 0 or ISC_Measure_6 > 0 ' ||
                                    'or ISC_Measure_10 > 0 or ISC_Measure_5 > 0 or ISC_Measure_7 > 0 or ISC_Measure_8 > 0 or ISC_Measure_9 > 0 ' ||
                                    'or ISC_Measure_11 > 0 or ISC_Measure_12 > 0 ' || ') ) iset'
                   ,p_generate_viewby => 'Y'
                   );

  l_mv := get_fact_mv_name
          ( 'ACTUAL_HRS'
          , p_param
          , l_dim_bmap
          , l_custom_output
          );

  l_stmt := replace( l_stmt, 'MV_PLACEHOLDER1', l_mv );

  l_mv := get_fact_mv_name
          ( 'PLANNED_HRS'
          , p_param
          , l_dim_bmap
          , l_custom_output
          );

  l_stmt := replace( l_stmt, 'MV_PLACEHOLDER2', l_mv );

  if l_view_by = isc_fs_rpt_util_pkg.G_TASK_TYPE then /* If View by Task Type, Total Plan hours are distributed to each task type */
    l_cur_planned_hours := 'c_Total_Planned_Hrs_total' ;
    l_prev_planned_hours := 'p_Total_Planned_Hrs_total';
  else
    l_cur_planned_hours := 'c_Total_Planned_Hrs' ;
    l_prev_planned_hours := 'p_Total_Planned_Hrs';
  end if;


  l_stmt := 'select
  ' || l_viewby_select || '
, ISC_MEASURE_1
, ISC_MEASURE_2
, ISC_MEASURE_3
, ISC_MEASURE_13
, ISC_MEASURE_6
, ISC_MEASURE_10
, ISC_MEASURE_5
, ISC_MEASURE_7
, ISC_MEASURE_8
, ISC_MEASURE_9
, ISC_MEASURE_11
, ISC_MEASURE_12
, ISC_MEASURE_15
, ISC_MEASURE_16
, ISC_MEASURE_17
, ISC_MEASURE_24
, ISC_MEASURE_18
, ISC_MEASURE_19
, ISC_MEASURE_20
, ISC_MEASURE_21
, ISC_MEASURE_22
, ISC_MEASURE_23
, ' || isc_fs_rpt_util_pkg.get_district_drill_down
       ( l_view_by
       , 'ISC_FS_TECH_UTL_TBL_REP'
       , 'ISC_ATTRIBUTE_2' ) || '
from (
select
  row_number() over(&ORDER_BY_CLAUSE nulls last, '|| isc_fs_rpt_util_pkg.get_inner_select_col(l_join_tbl) || ')-1 rnk
, iset.*
from ( select * from (
select ' || isc_fs_rpt_util_pkg.get_inner_select_col(l_join_tbl) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'p_Total_Act_Hrs'
       , l_prev_planned_hours
       , 'ISC_MEASURE_1'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_Total_Act_Hrs'
       , l_cur_planned_hours
       , 'ISC_MEASURE_2'
       ) || '
, ' || isc_fs_rpt_util_pkg.change_column
       ( isc_fs_rpt_util_pkg.rate_column
         ( 'c_Total_Act_Hrs'
         , l_cur_planned_hours
         , null
         )
       , isc_fs_rpt_util_pkg.rate_column
         ( 'p_Total_Act_Hrs'
         , l_prev_planned_hours
         , null
         )
       , 'ISC_MEASURE_3'
       , 'N'
       ) || '
, nvl(c_Total_Planned_Hrs,0)  ISC_MEASURE_13
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'p_Labor_Hrs'
       , l_prev_planned_hours
       , 'ISC_MEASURE_6'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'p_Travel_Hrs'
       , l_cur_planned_hours
       , 'ISC_MEASURE_10'
       ) || '
, nvl(c_Labor_Hrs,0)  ISC_MEASURE_5
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_Labor_Hrs'
       , l_cur_planned_hours
       , 'ISC_MEASURE_7'
       ) || '
, ' || isc_fs_rpt_util_pkg.change_column
       ( isc_fs_rpt_util_pkg.rate_column
         ( 'c_Labor_Hrs'
         , l_cur_planned_hours
         , null
         )
       , isc_fs_rpt_util_pkg.rate_column
         ( 'p_Labor_Hrs'
         , l_prev_planned_hours
         , null
         )
       , 'ISC_MEASURE_8'
       , 'N'
       ) || '
, nvl(c_Travel_Hrs,0)  ISC_MEASURE_9
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_Travel_Hrs'
       , l_cur_planned_hours
       , 'ISC_MEASURE_11'
       ) || '
, ' || isc_fs_rpt_util_pkg.change_column
       ( isc_fs_rpt_util_pkg.rate_column
         ( 'c_Travel_Hrs'
         , l_cur_planned_hours
         , null
         )
       , isc_fs_rpt_util_pkg.rate_column
         ( 'p_Travel_Hrs'
         , l_prev_planned_hours
         , null
         )
       , 'ISC_MEASURE_12'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'p_Total_Act_Hrs_total'
       , 'p_Total_Planned_Hrs_total'
       , 'ISC_MEASURE_15'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_Total_Act_Hrs_total'
       , 'c_Total_Planned_Hrs_total'
       , 'ISC_MEASURE_16'
       ) || '
, ' || isc_fs_rpt_util_pkg.change_column
       ( isc_fs_rpt_util_pkg.rate_column
         ( 'c_Total_Act_Hrs_total'
         , 'c_Total_Planned_Hrs_total'
         , null
         )
       , isc_fs_rpt_util_pkg.rate_column
         ( 'p_Total_Act_Hrs_total'
         , 'p_Total_Planned_Hrs_total'
         , null
         )
       , 'ISC_MEASURE_17'
       , 'N'
       ) || '
, nvl(c_Total_Planned_Hrs_total,0)  ISC_MEASURE_24
, nvl(c_Labor_Hrs_total,0)  ISC_MEASURE_18
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_Labor_Hrs_total'
       , 'c_Total_Planned_Hrs_total'
       , 'ISC_MEASURE_19'
       ) || '
, ' || isc_fs_rpt_util_pkg.change_column
       ( isc_fs_rpt_util_pkg.rate_column
         ( 'c_Labor_Hrs_total'
         , 'c_Total_Planned_Hrs_total'
         , null
         )
       , isc_fs_rpt_util_pkg.rate_column
         ( 'p_Labor_Hrs_total'
         , 'p_Total_Planned_Hrs_total'
         , null
         )
       , 'ISC_MEASURE_20'
       , 'N'
       ) || '
, nvl(c_Travel_Hrs_total,0)  ISC_MEASURE_21
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_Travel_Hrs_total'
       , 'c_Total_Planned_Hrs_total'
       , 'ISC_MEASURE_22'
       ) || '
, ' || isc_fs_rpt_util_pkg.change_column
       ( isc_fs_rpt_util_pkg.rate_column
         ( 'c_Travel_Hrs_total'
         , 'c_Total_Planned_Hrs_total'
         , null
         )
       , isc_fs_rpt_util_pkg.rate_column
         ( 'p_Travel_Hrs_total'
         , 'p_Total_Planned_Hrs_total'
         , null
         )
       , 'ISC_MEASURE_23'
       , 'N'
       ) || '
from (' || l_stmt;


  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
--  l_stmt := l_stmt || isc_fs_rpt_util_pkg.dump_parameters(p_param);

  poa_dbi_util_pkg.get_custom_rolling_binds
  ( p_custom_output => l_custom_output
  , p_xtd           => l_xtd
  );

  x_custom_output := l_custom_output;

  isc_fs_rpt_util_pkg.enhance_time_join
  ( l_stmt
  , 'N'
  );

  x_custom_sql      := l_stmt;

end get_tbl_sql;


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
  l_mv_tbl          poa_dbi_util_pkg.poa_dbi_mv_tbl;
  l_col_tbl1         poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_col_tbl2         poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_col_tbl3         poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_stmt             varchar2(32767);
  l_to_date_type     varchar2(20);

begin

  isc_fs_rpt_util_pkg.register_dimension_levels
  ( l_dimension_tbl
  , l_dim_filter_map
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
  , p_trend            => 'Y'
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

  l_col_tbl1 := poa_dbi_util_pkg.poa_dbi_col_tbl();
  l_col_tbl2 := poa_dbi_util_pkg.poa_dbi_col_tbl();

  l_mv_tbl := poa_dbi_util_pkg.poa_dbi_mv_tbl ();


  poa_dbi_util_pkg.add_column (p_col_tbl      => l_col_tbl1
                       , p_col_name     => 'Labor_Hrs'
                       , p_alias_name   => 'Labor_Hrs'
                       , p_grand_total  => 'N'
                       , p_prior_code   => poa_dbi_util_pkg.both_priors
                       , p_to_date_type => l_to_date_type
                       );

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl1
                             , p_col_name     => 'Travel_Hrs'
                             , p_alias_name   => 'Travel_Hrs'
                             , p_grand_total  => 'N'
                      , p_prior_code   => poa_dbi_util_pkg.both_priors
                             , p_to_date_type => l_to_date_type
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl1
                             , p_col_name     => 'Total_Act_Hrs'
                             , p_alias_name   => 'Total_Act_Hrs'
                             , p_grand_total  => 'N'
                             , p_prior_code   => poa_dbi_util_pkg.both_priors
                             , p_to_date_type => l_to_date_type
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl2
                             , p_col_name     => 'Total_Planned_Hrs'
                             , p_alias_name   => 'Total_Planned_Hrs'
                             , p_grand_total  => 'N'
                      , p_prior_code   => poa_dbi_util_pkg.both_priors
                             , p_to_date_type => l_to_date_type
                             );

  l_mv_tbl.extend;
  l_mv_tbl(1).mv_name := 'MV_PLACEHOLDER1';
  l_mv_tbl(1).mv_col := l_col_tbl1;
  l_mv_tbl(1).mv_where := l_where_clause;
  l_mv_tbl(1).in_join_tbls := NULL;
  l_mv_tbl(1).use_grp_id := 'N';
  l_mv_tbl(1).mv_xtd := l_xtd;

  l_mv_tbl.extend;
  l_mv_tbl(2).mv_name := 'MV_PLACEHOLDER2';
  l_mv_tbl(2).mv_col := l_col_tbl2;
  l_mv_tbl(2).mv_where := replace(l_where_clause, '&' || isc_fs_rpt_util_pkg.G_TASK_TYPE, '-999');
  l_mv_tbl(2).in_join_tbls := NULL;
  l_mv_tbl(2).use_grp_id := 'N';
  l_mv_tbl(2).mv_xtd := l_xtd;

  l_stmt := poa_dbi_template_pkg.union_all_trend_sql(
               p_mv         => l_mv_tbl,
               p_comparison_type   => l_comparison_type,
               p_filter_where     => NULL
               );


  l_mv := get_fact_mv_name
          ( 'ACTUAL_HRS'
          , p_param
          , l_dim_bmap
          , l_custom_output
          );

  l_stmt := replace( l_stmt, 'MV_PLACEHOLDER1', l_mv );

  l_mv := get_fact_mv_name
          ( 'PLANNED_HRS'
          , p_param
          , l_dim_bmap
          , l_custom_output
          );

  l_stmt := replace( l_stmt, 'MV_PLACEHOLDER2', l_mv );

  l_stmt := 'select
  cal_name VIEWBY ' || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'p_Total_Act_Hrs'
       , 'p_Total_Planned_Hrs'
       , 'ISC_MEASURE_1'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_Total_Act_Hrs'
       , 'c_Total_Planned_Hrs'
       , 'ISC_MEASURE_2'
       ) || '
, ' || isc_fs_rpt_util_pkg.change_column
       ( isc_fs_rpt_util_pkg.rate_column
         ( 'c_Total_Act_Hrs'
         , 'c_Total_Planned_Hrs'
         , null
         )
       , isc_fs_rpt_util_pkg.rate_column
         ( 'p_Total_Act_Hrs'
         , 'p_Total_Planned_Hrs'
         , null
         )
       , 'ISC_MEASURE_3'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'p_Labor_Hrs'
       , 'p_Total_Planned_Hrs'
       , 'ISC_MEASURE_6'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_Labor_Hrs'
       , 'c_Total_Planned_Hrs'
       , 'ISC_MEASURE_7'
       ) || '
, ' || isc_fs_rpt_util_pkg.change_column
       ( isc_fs_rpt_util_pkg.rate_column
         ( 'c_Labor_Hrs'
         , 'c_Total_Planned_Hrs'
         , null
         )
       , isc_fs_rpt_util_pkg.rate_column
         ( 'p_Labor_Hrs'
         , 'p_Total_Planned_Hrs'
         , null
         )
       , 'ISC_MEASURE_8'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'p_Travel_Hrs'
       , 'p_Total_Planned_Hrs'
       , 'ISC_MEASURE_10'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_Travel_Hrs'
       , 'c_Total_Planned_Hrs'
       , 'ISC_MEASURE_11'
       ) || '
, ' || isc_fs_rpt_util_pkg.change_column
       ( isc_fs_rpt_util_pkg.rate_column
         ( 'c_Travel_Hrs'
         , 'c_Total_Planned_Hrs'
         , null
         )
       , isc_fs_rpt_util_pkg.rate_column
         ( 'p_Travel_Hrs'
         , 'p_Total_Planned_Hrs'
         , null
         )
       , 'ISC_MEASURE_12'
       , 'N'
       ) ||
  isc_fs_rpt_util_pkg.get_trend_drill
  ( l_xtd
  , 'ISC_FS_TECH_UTL_TRD_REP'
  , 'ISC_ATTRIBUTE_1'
  , 'ISC_ATTRIBUTE_2'
  , p_override_end_date =>  'cal_end_date'
  ) || '
from
  ' || l_stmt;

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  -- l_stmt := l_stmt || isc_fs_rpt_util_pkg.dump_parameters(p_param);

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

  l_stmt := replace( l_stmt, ', cal.start_date cal_start_date', ', cal.start_date cal_start_date, cal.end_date cal_end_date');
  l_stmt := replace( l_stmt, ', cal_start_date', ', cal_start_date, cal_end_date');
--  l_stmt := replace( l_stmt, 'group by cal_name, cal_start_date', 'group by cal_name, cal_start_date, cal_end_date');

  isc_fs_rpt_util_pkg.enhance_time_join
  ( l_stmt
  , 'Y'
  );

  x_custom_sql      := l_stmt;

end get_trd_sql;



END ISC_FS_TECH_UTL_RPT_PKG;

/
