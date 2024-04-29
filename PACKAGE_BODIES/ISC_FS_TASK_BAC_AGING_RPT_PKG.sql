--------------------------------------------------------
--  DDL for Package Body ISC_FS_TASK_BAC_AGING_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_FS_TASK_BAC_AGING_RPT_PKG" 
/* $Header: iscfstkbarptb.pls 120.3 2006/04/12 20:47:07 kreardon noship $ */
as

  g_detail_rep_func  constant varchar2(50) := 'ISC_FS_TASK_BAC_AGING_RPT_REP';
  g_task_rep_func    constant varchar2(50) := 'ISC_FS_TASK_BAC_AGING_TBL_REP';
  g_trend_rep_func    constant varchar2(50) := 'ISC_FS_TASK_BAC_AGING_TRD_REP';

function get_fact_mv_name
( p_report_type   in varchar2
, p_param         in bis_pmv_page_parameter_tbl
, p_dim_bmap      in number
, p_custom_output in out nocopy bis_query_attributes_tbl
)
return varchar2
is

  l_top_node varchar2(1);
  l_resource varchar2(1);
  l_district_leaf_node varchar2(1);

begin

  if nvl(isc_fs_rpt_util_pkg.get_parameter_value
         ( p_param
         , isc_fs_rpt_util_pkg.G_CATEGORY
         ),'All') = 'All' then
    l_top_node := 'Y';
  else
    l_top_node := 'N';
  end if;

  if p_report_type = 'TASK_BACKLOG_AGING' then

    l_district_leaf_node := isc_fs_rpt_util_pkg.is_district_leaf_node
                            ( p_param );

    isc_fs_rpt_util_pkg.bind_group_id
    ( p_dim_bmap
    , p_custom_output
    , isc_fs_rpt_util_pkg.G_CATEGORY
    , isc_fs_rpt_util_pkg.G_PRODUCT
    , isc_fs_rpt_util_pkg.G_CUSTOMER
    );

    if bitand(p_dim_bmap,isc_fs_rpt_util_pkg.G_CATEGORY_BMAP) = isc_fs_rpt_util_pkg.G_CATEGORY_BMAP then

      return '(
select
  v.top_node_flag vbh_top_node_flag
, v.parent_id vbh_parent_category_id
, v.imm_child_id vbh_child_category_id
, f.report_date ' || case
                       when l_district_leaf_node = 'N' then '
, den.parent_prg_id parent_district_id
, decode( den.record_type, ''GROUP'', den.record_type, f.record_type ) record_type
, decode( den.record_type, ''GROUP'', den.prg_id , f.district_id ) district_id
, decode( den.record_type, ''GROUP'', to_char(den.prg_id), f.district_id_c )  district_id_c'
                       else '
, f.parent_district_id
, f.record_type
, f.district_id
, f.district_id_c'
                     end || '
, f.task_type_id
, f.customer_id
, f.product_id
, f.backlog_count
, f.total_backlog_age
, f.backlog_age_b1
, f.backlog_age_b2
, f.backlog_age_b3
, f.backlog_age_b4
, f.backlog_age_b5
, f.backlog_age_b6
, f.backlog_age_b7
, f.backlog_age_b8
, f.backlog_age_b9
, f.backlog_age_b10
from
  isc_fs_007_mv f' || case
                        when l_district_leaf_node = 'N' then '
, isc_fs_002_mv den'
                      end || '
, eni_denorm_hierarchies v
, mtl_default_category_sets m
where
    m.functional_area_id = 11
and v.object_id = m.category_set_id
and v.dbi_flag = ''Y''
and v.object_type = ''CATEGORY_SET''
and f.vbh_category_id = v.child_id
and f.grp_id = &ISC_GRP_ID' || case
                                 when l_district_leaf_node = 'N' then '
and f.parent_district_id = den.rg_id'
                               end ||
                               case
                                 when l_top_node = 'Y' then '
and v.top_node_flag = ''Y'''   end || '
)';

    elsif bitand(p_dim_bmap,isc_fs_rpt_util_pkg.G_PRODUCT_BMAP) = isc_fs_rpt_util_pkg.G_PRODUCT_BMAP or
          bitand(p_dim_bmap,isc_fs_rpt_util_pkg.G_CUSTOMER_BMAP) = isc_fs_rpt_util_pkg.G_CUSTOMER_BMAP or
          bitand(p_dim_bmap,isc_fs_rpt_util_pkg.G_TASK_TYPE_BMAP) = isc_fs_rpt_util_pkg.G_TASK_TYPE_BMAP then

      return '(
select
  f.report_date ' || case
                       when l_district_leaf_node = 'N' then '
, den.parent_prg_id parent_district_id
, decode( den.record_type, ''GROUP'', den.record_type, f.record_type ) record_type
, decode( den.record_type, ''GROUP'', den.prg_id , f.district_id ) district_id
, decode( den.record_type, ''GROUP'', to_char(den.prg_id), f.district_id_c )  district_id_c'
                       else '
, f.parent_district_id
, f.record_type
, f.district_id
, f.district_id_c'
                     end || '
, f.task_type_id
, f.customer_id
, f.product_id
, f.backlog_count
, f.total_backlog_age
, f.backlog_age_b1
, f.backlog_age_b2
, f.backlog_age_b3
, f.backlog_age_b4
, f.backlog_age_b5
, f.backlog_age_b6
, f.backlog_age_b7
, f.backlog_age_b8
, f.backlog_age_b9
, f.backlog_age_b10
from
  isc_fs_007_mv f' || case
                        when l_district_leaf_node = 'N' then '
, isc_fs_002_mv den'
                      end || '
where
    f.grp_id = &ISC_GRP_ID' || case
                                 when l_district_leaf_node = 'N' then '
and f.parent_district_id = den.rg_id'
                               end || '
)';

    else

      return '(
select
  f.report_date
, f.parent_district_id
, f.record_type
, f.district_id
, f.district_id_c
, f.backlog_count
, f.total_backlog_age
, f.backlog_age_b1
, f.backlog_age_b2
, f.backlog_age_b3
, f.backlog_age_b4
, f.backlog_age_b5
, f.backlog_age_b6
, f.backlog_age_b7
, f.backlog_age_b8
, f.backlog_age_b9
, f.backlog_age_b10
from isc_fs_008_mv f
)';

    end if;

  elsif p_report_type = 'TASK_BACKLOG_AGING_DETAIL' then

    if isc_fs_rpt_util_pkg.get_parameter_id
       ( p_param
       , isc_fs_rpt_util_pkg.G_DISTRICT
       ) like '%.%' then
      l_resource := 'Y';
    else
      l_resource := 'N';
    end if;

    return '(
    select
      t.task_id
    , t.task_number
    , b.backlog_date_to
    , b.backlog_status_code
    , t.task_type_id
    , t.owner_id
    , t.owner_type
    , decode(t.first_asgn_creation_date,null,to_number(null),t.act_bac_assignee_id) assignee_id
    , decode(t.first_asgn_creation_date,null,null,t.act_bac_assignee_type) assignee_type ' ||
      case
        when l_resource = 'N' then '
    , d.parent_prg_id parent_district_id '
        else '
    , t.act_bac_assignee_id || ''.'' || t.act_bac_district_id district_id_c '
      end  || '
    , t.actual_start_date
    , t.actual_end_date
    , t.planned_start_date
    , greatest( 0 + ((&ISC_FS_CURRENT_ASOF_DATE + &ISC_FS_CURRENT_TIME) - nvl(t.planned_start_date,sysdate+365)), 0) age_days
    , t.source_object_name
    , t.source_object_id
    , t.incident_date
    , t.customer_id
    , nvl(s.master_id,s.id) product_id ' ||
      case
        when bitand(p_dim_bmap,isc_fs_rpt_util_pkg.G_CATEGORY_BMAP) = isc_fs_rpt_util_pkg.G_CATEGORY_BMAP then
          '
    , v.top_node_flag vbh_top_node_flag
    , v.parent_id vbh_parent_category_id
    , v.imm_child_id vbh_child_category_id'
      end || '
    from
      isc_fs_tasks_f t
    , isc_fs_task_backlog_f b
    , eni_oltp_item_star s' ||
      case
        when bitand(p_dim_bmap,isc_fs_rpt_util_pkg.G_CATEGORY_BMAP) = isc_fs_rpt_util_pkg.G_CATEGORY_BMAP then
          '
    , eni_denorm_hierarchies v
    , mtl_default_category_sets m'
      end ||
      case
        when l_resource = 'N' then '
    , isc_fs_002_mv d'
      end || '
    where
        t.task_id = b.task_id
    and t.task_type_rule = ''DISPATCH''
    and t.source_object_type_code = ''SR''
    and t.deleted_flag = ''N''
    and t.inventory_item_id = s.inventory_item_id
    and t.inv_organization_id = s.organization_id' ||
      case
        when bitand(p_dim_bmap,isc_fs_rpt_util_pkg.G_CATEGORY_BMAP) = isc_fs_rpt_util_pkg.G_CATEGORY_BMAP then
          '
    and m.functional_area_id = 11
    and v.object_id = m.category_set_id
    and v.dbi_flag = ''Y''
    and v.object_type = ''CATEGORY_SET''
    and s.vbh_category_id = v.child_id' ||
        case l_top_node when 'Y' then ' and v.top_node_flag = ''Y''' end
      end ||
      case
        when l_resource = 'N' then '
    and d.rg_id = t.act_bac_district_id'
      end || '
    )';

  else -- should not happen!!!
    return '';

  end if;

end get_fact_mv_name;

procedure get_time_bit_patterns
( p_xtd              in varchar2
, p_comparison_type  in varchar2
, x_current_bit      out nocopy number
, x_previous_bit     out nocopy number
)
is

  l_period_bit_tbl isc_fs_task_bac_age_etl_pkg.t_period_bit_tbl;

begin

  x_current_bit := l_period_bit_tbl(p_xtd).curr;
  x_previous_bit := case p_comparison_type
                      when 'S' then l_period_bit_tbl(p_xtd).prior_period
                      else l_period_bit_tbl(p_xtd).prior_year
                    end;

end get_time_bit_patterns;

function get_calendar
( p_xtd              in varchar2
)
return varchar2
is

  l_prefix       varchar2(20);

begin

  case p_xtd
    when 'WTD' then l_prefix := 'week';
    when 'MTD' then l_prefix := 'ent_period';
    when 'QTD' then l_prefix := 'ent_qtr';
    when 'YTD' then l_prefix := 'ent_year';
    when 'DAY' then l_prefix := 'day';
  end case;

  return '(
select ' || l_prefix || '_start_date start_date
, trunc(aging_date) end_date
, trunc(aging_date) report_date
from isc_fs_task_bac_dates_c
where bitand(record_type_id,&ISC_FS_CURRENT_BIT)=&ISC_FS_CURRENT_BIT
   or bitand(record_type_id,&ISC_FS_PREVIOUS_BIT)=&ISC_FS_PREVIOUS_BIT )';

end get_calendar;

procedure get_curr_prior_dates
( p_xtd             in varchar2
, p_comparison_type in varchar2
, p_custom_output   in out nocopy bis_query_attributes_tbl
)
is

  l_period_bit_tbl constant isc_fs_task_bac_age_etl_pkg.t_period_bit_tbl :=
    isc_fs_task_bac_age_etl_pkg.get_period_bit_tbl;

  l_current_as_of_date date;
  l_previous_as_of_date date;
  l_current_start_date date;
  l_previous_start_date date;

  l_current_bit  number;
  l_previous_bit number;

begin

  l_current_bit := l_period_bit_tbl(p_xtd).curr;
  l_previous_bit := case p_comparison_type
                      when 'S' then l_period_bit_tbl(p_xtd).prior_period
                      else l_period_bit_tbl(p_xtd).prior_year
                    end;

  select
    max( decode( bitand(record_type_id,l_current_bit)
                , l_current_bit, aging_date
                , null
                ) ) current_asof_date
  , max( decode( bitand(record_type_id,l_previous_bit)
               , l_previous_bit, aging_date
               , null
               ) ) previous_asof_date
  , min( decode( bitand(record_type_id,l_current_bit)
               , l_current_bit, decode( l_current_bit
                                      , isc_fs_task_bac_age_etl_pkg.G_WTD, week_start_date
                                      , isc_fs_task_bac_age_etl_pkg.G_MTD, ent_period_start_date
                                      , isc_fs_task_bac_age_etl_pkg.G_QTD, case
                                                 when p_comparison_type = 'Y' then
                                                   case
                                                     when rnk <=4 then ent_qtr_start_date
                                                     else null
                                                   end
                                                 else ent_qtr_start_date
                                               end
                                      , isc_fs_task_bac_age_etl_pkg.G_YTD, ent_year_start_date
                                      , isc_fs_task_bac_age_etl_pkg.G_DAY, day_start_date
                                      )
               , null
               ) ) current_report_start_date
  , min( decode( bitand(record_type_id,l_previous_bit)
               , l_previous_bit, decode( l_current_bit
                                       , isc_fs_task_bac_age_etl_pkg.G_WTD, week_start_date
                                       , isc_fs_task_bac_age_etl_pkg.G_MTD, ent_period_start_date
                                       , isc_fs_task_bac_age_etl_pkg.G_QTD, ent_qtr_start_date
                                       , isc_fs_task_bac_age_etl_pkg.G_YTD, ent_year_start_date
                                       , isc_fs_task_bac_age_etl_pkg.G_DAY, day_start_date
                                       )
               , null
               ) ) previous_report_start_date
  into
    l_current_as_of_date
  , l_previous_as_of_date
  , l_current_start_date
  , l_previous_start_date
  from
    ( select record_type_id
      , aging_date
      , week_start_date
      , ent_period_start_date
      , ent_qtr_start_date
      , ent_year_start_date
      , day_start_date
      , rank() over(partition by bitand(record_type_id,l_current_bit) order by aging_date desc) rnk
      from isc_fs_task_bac_dates_c
      where
         bitand(record_type_id,l_current_bit) = l_current_bit
      or bitand(record_type_id,l_previous_bit) = l_previous_bit
    );

  isc_fs_rpt_util_pkg.add_custom_bind_parameter
  ( p_custom_output => p_custom_output
  , p_parameter_name => '&ISC_FS_CURRENT_ASOF_DATE'
  , p_parameter_data_type => bis_pmv_parameters_pub.date_bind
  , p_parameter_value     => to_char(l_current_as_of_date,'dd/mm/yyyy')
  );

  isc_fs_rpt_util_pkg.add_custom_bind_parameter
  ( p_custom_output => p_custom_output
  , p_parameter_name => '&ISC_FS_PREVIOUS_ASOF_DATE'
  , p_parameter_data_type => bis_pmv_parameters_pub.date_bind
  , p_parameter_value     => to_char(l_previous_as_of_date,'dd/mm/yyyy')
  );

  isc_fs_rpt_util_pkg.add_custom_bind_parameter
  ( p_custom_output => p_custom_output
  , p_parameter_name => '&ISC_FS_CURRENT_TIME'
  , p_parameter_data_type => bis_pmv_parameters_pub.numeric_bind
  , p_parameter_value     => l_current_as_of_date - trunc(l_current_as_of_date)
  );

  isc_fs_rpt_util_pkg.add_custom_bind_parameter
  ( p_custom_output => p_custom_output
  , p_parameter_name => '&ISC_FS_CURR_REPORT_START_DATE'
  , p_parameter_data_type => bis_pmv_parameters_pub.date_bind
  , p_parameter_value     => to_char(l_current_start_date,'dd/mm/yyyy')
  );

  isc_fs_rpt_util_pkg.add_custom_bind_parameter
  ( p_custom_output => p_custom_output
  , p_parameter_name => '&ISC_FS_PREV_REPORT_START_DATE'
  , p_parameter_data_type => bis_pmv_parameters_pub.date_bind
  , p_parameter_value     => to_char(l_previous_start_date,'dd/mm/yyyy')
  );

  isc_fs_rpt_util_pkg.add_custom_bind_parameter
  ( p_custom_output => p_custom_output
  , p_parameter_name => '&ISC_FS_CURRENT_BIT'
  , p_parameter_data_type => bis_pmv_parameters_pub.numeric_bind
  , p_parameter_value     => l_current_bit
  );

  isc_fs_rpt_util_pkg.add_custom_bind_parameter
  ( p_custom_output => p_custom_output
  , p_parameter_name => '&ISC_FS_PREVIOUS_BIT'
  , p_parameter_data_type => bis_pmv_parameters_pub.numeric_bind
  , p_parameter_value     => l_previous_bit
  );

end get_curr_prior_dates;

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
  l_product          varchar2(200);
  l_stmt             varchar2(32700);
  l_to_date_type     varchar2(200);

  l_bucket_rec bis_bucket_pub.bis_bucket_rec_type;

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

  l_to_date_type := 'XTD';

  l_view_by := isc_fs_rpt_util_pkg.get_parameter_value
               ( p_param
               , 'VIEW_BY'
               );

  if l_view_by = isc_fs_rpt_util_pkg.G_PRODUCT then
    l_product := 'v4.description ISC_ATTRIBUTE_1';
  else
    l_product := 'null ISC_ATTRIBUTE_1';
  end if;

  l_mv := get_fact_mv_name
          ( 'TASK_BACKLOG_AGING'
          , p_param
          , l_dim_bmap
          , l_custom_output
          );

  l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl
                             , p_col_name     => 'backlog_count'
                             , p_alias_name   => 'backlog'
                             , p_to_date_type => 'BAL'
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl
                             , p_col_name     => 'total_backlog_age'
                             , p_alias_name   => 'backlog_age'
                             , p_to_date_type => 'BAL'
                             );

  poa_dbi_util_pkg.add_bucket_columns
  ( p_short_name   => 'BIV_FS_BACKLOG_AGING'
  , p_col_tbl      => l_col_tbl
  , p_col_name     => 'backlog_age'
  , p_alias_name   => 'backlog'
  , p_prior_code   => poa_dbi_util_pkg.no_priors
  , p_to_date_type => 'BAL'
  , x_bucket_rec   => l_bucket_rec
  );

  l_stmt := 'select
  ' || l_viewby_select || '
, ISC_MEASURE_1
, ISC_MEASURE_2
, ISC_MEASURE_3
, ISC_MEASURE_4
, ISC_MEASURE_5
, ISC_MEASURE_6
'   || poa_dbi_util_pkg.get_bucket_outer_query
       ( p_bucket_rec => l_bucket_rec
       , p_col_name   => 'ISC_MEASURE_7'
       , p_alias_name => 'ISC_MEASURE_7'
       , p_prefix     => null
       , p_suffix     => null
       , p_total_flag => 'N'
       ) || '
, ISC_MEASURE_21
, ISC_MEASURE_22
, ISC_MEASURE_23
, ISC_MEASURE_24
, ISC_MEASURE_25
, ISC_MEASURE_26
'   || poa_dbi_util_pkg.get_bucket_outer_query
       ( p_bucket_rec => l_bucket_rec
       , p_col_name   => 'ISC_MEASURE_27'
       , p_alias_name => 'ISC_MEASURE_27'
       , p_prefix     => null
       , p_suffix     => null
       , p_total_flag => 'N'
       ) || '
, ' || l_product || '
, ' || isc_fs_rpt_util_pkg.get_district_drill_down
       ( l_view_by
       , g_task_rep_func
       , 'ISC_ATTRIBUTE_2' ) || '
, ' || isc_fs_rpt_util_pkg.get_category_drill_down
       ( l_view_by
       , g_task_rep_func
       , 'ISC_ATTRIBUTE_3' ) || '
, ' || isc_fs_rpt_util_pkg.get_bucket_drill_down
       ( p_bucket_rec        => l_bucket_rec
       , p_view_by           => l_view_by
       , p_function_name     => g_detail_rep_func
       , p_check_column_name => 'ISC_MEASURE_7'
       , p_column_alias      => 'ISC_ATTRIBUTE_4'
       , p_extra_params      => '&BIV_FS_BACKLOG_AGING='
       , p_check_resource    => 'Y'
     ) || '
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
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'p_backlog_age'
       , 'p_backlog'
       , 'ISC_MEASURE_4'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_backlog_age'
       , 'c_backlog'
       , 'ISC_MEASURE_5'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.change_column
       ( isc_fs_rpt_util_pkg.rate_column
         ( 'c_backlog_age'
         , 'c_backlog'
         , null
         , 'N'
         )
       , isc_fs_rpt_util_pkg.rate_column
         ( 'p_backlog_age'
         , 'p_backlog'
         , null
         , 'N'
         )
       , 'ISC_MEASURE_6'
       , 'N'
       ) || '
'   || poa_dbi_util_pkg.get_bucket_outer_query
       ( p_bucket_rec => l_bucket_rec
       , p_col_name   => 'backlog'
       , p_alias_name => 'ISC_MEASURE_7'
       , p_prefix     => 'nvl(c_'
       , p_suffix     => ',0)/abs(decode(c_backlog,0,null,c_backlog))*100'
       , p_total_flag => 'N'
       ) || '
, nvl(p_backlog_total,0) ISC_MEASURE_21
, nvl(c_backlog_total,0) ISC_MEASURE_22
, ' || isc_fs_rpt_util_pkg.change_column
       ( 'c_backlog_total'
       , 'p_backlog_total'
       , 'ISC_MEASURE_23' ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'p_backlog_age_total'
       , 'p_backlog_total'
       , 'ISC_MEASURE_24'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_backlog_age_total'
       , 'c_backlog_total'
       , 'ISC_MEASURE_25'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.change_column
       ( isc_fs_rpt_util_pkg.rate_column
         ( 'c_backlog_age_total'
         , 'c_backlog_total'
         , null
         , 'N'
         )
       , isc_fs_rpt_util_pkg.rate_column
         ( 'p_backlog_age_total'
         , 'p_backlog_total'
         , null
         , 'N'
         )
       , 'ISC_MEASURE_26'
       , 'N'
       ) || '
'   || poa_dbi_util_pkg.get_bucket_outer_query
       ( p_bucket_rec => l_bucket_rec
       , p_col_name   => 'backlog'
       , p_alias_name => 'ISC_MEASURE_27'
       , p_prefix     => 'nvl(c_'
       , p_suffix     => ',0)/abs(decode(c_backlog_total,0,null,c_backlog_total))*100'
       , p_total_flag => 'Y'
       ) || '
from
  ' || poa_dbi_template_pkg.status_sql
        ( p_fact_name            => l_mv
        , p_where_clause         => l_where_clause
        , p_join_tables          => l_join_tbl
        , p_use_windowing        => 'Y' --'N'
        , p_col_name             => l_col_tbl
        , p_use_grpid            => 'N'
        , p_paren_count          => 3
        , p_filter_where         => '(isc_measure_1 >0 or isc_measure_2>0)) iset '
        , p_generate_viewby      => 'Y'
        );

  poa_dbi_util_pkg.get_custom_balance_binds
  ( p_custom_output => l_custom_output
  , p_balance_fact  => isc_fs_task_act_bac_etl_pkg.g_object_name
  , p_xtd           => l_xtd
  );

  get_curr_prior_dates
  ( l_xtd
  , l_comparison_type
  , l_custom_output
  );

  l_stmt := replace( l_stmt, 'BIS_PREVIOUS_EFFECTIVE_END_DATE', 'ISC_FS_PREVIOUS_ASOF_DATE' );
  l_stmt := replace( l_stmt, 'BIS_CURRENT_EFFECTIVE_END_DATE', 'ISC_FS_CURRENT_ASOF_DATE' );

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  -- l_stmt := l_stmt || isc_fs_rpt_util_pkg.dump_parameters(p_param);

  x_custom_output := l_custom_output;

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
  l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_stmt             varchar2(32767);
  l_to_date_type     varchar2(200);

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

  l_to_date_type := 'XTD';

  l_mv := get_fact_mv_name
          ( 'TASK_BACKLOG_AGING'
          , p_param
          , l_dim_bmap
          , l_custom_output
          );

  l_stmt := 'select
  cal.name VIEWBY
, nvl(iset.p_backlog,0) ISC_MEASURE_1
, nvl(iset.c_backlog,0) ISC_MEASURE_2
, ' || isc_fs_rpt_util_pkg.change_column
       ( 'c_backlog'
       , 'p_backlog'
       , 'ISC_MEASURE_3' ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'p_backlog_age'
       , 'p_backlog'
       , 'ISC_MEASURE_4'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_backlog_age'
       , 'c_backlog'
       , 'ISC_MEASURE_5'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.change_column
       ( isc_fs_rpt_util_pkg.rate_column
         ( 'c_backlog_age'
         , 'c_backlog'
         , null
         , 'N'
         )
       , isc_fs_rpt_util_pkg.rate_column
         ( 'p_backlog_age'
         , 'p_backlog'
         , null
         , 'N'
         )
       , 'ISC_MEASURE_6'
       , 'N'
       ) || '
from
  ( select
      n.start_date
    , sum(case
            when (n.start_date between &ISC_FS_CURR_REPORT_START_DATE and &ISC_FS_CURRENT_ASOF_DATE and i.report_date =  LEAST (n.end_date, &ISC_FS_CURRENT_ASOF_DATE) ) then
              backlog
            else
              null
            end) c_backlog
    , lag(sum(case
                when (n.start_date between &ISC_FS_PREV_REPORT_START_DATE and &ISC_FS_PREVIOUS_ASOF_DATE and i.report_date =  LEAST (n.end_date, &ISC_FS_PREVIOUS_ASOF_DATE)  ) then
                  backlog
                else
                  null
              end), &LAG) over (order by n.start_date) p_backlog
    , sum(case
            when (n.start_date between &ISC_FS_CURR_REPORT_START_DATE and &ISC_FS_CURRENT_ASOF_DATE and i.report_date =  LEAST (n.end_date, &ISC_FS_CURRENT_ASOF_DATE) ) then
              backlog_age
            else
              null
          end) c_backlog_age
    , lag(sum(case
                when (n.start_date between &ISC_FS_PREV_REPORT_START_DATE and &ISC_FS_PREVIOUS_ASOF_DATE and i.report_date =  LEAST (n.end_date, &ISC_FS_PREVIOUS_ASOF_DATE)  ) then
                  backlog_age
                else
                  null
              end), &LAG) over (order by n.start_date) p_backlog_age
    from
      ( select
          n.start_date
        , n.report_date
        , sum(backlog_count) backlog
        , sum(total_backlog_age) backlog_age
        from ' || l_mv || ' fact
        , ' || get_calendar(l_xtd) || ' n
        where fact.report_date = n.report_date
        and n.start_date between &ISC_FS_PREV_REPORT_START_DATE and &ISC_FS_CURRENT_ASOF_DATE
        ' || l_where_clause || '
        group by
          n.start_date
        , n.report_date
      ) i
    , ' || poa_dbi_util_pkg.get_calendar_table
           ( period_type => l_xtd
           , p_include_prior => 'N'
           ) || ' n
    where i.start_date(+) = n.start_date
    and n.start_date between &ISC_FS_PREV_REPORT_START_DATE and &ISC_FS_CURRENT_ASOF_DATE
    group by
      n.start_date
  ) iset
, ' || poa_dbi_util_pkg.get_calendar_table
       ( period_type => l_xtd
       , p_include_prior => 'N'
       ) || ' cal
where cal.start_date between &ISC_FS_CURR_REPORT_START_DATE and &ISC_FS_CURRENT_ASOF_DATE
and cal.start_date = iset.start_date(+)
order by cal.start_date';

  l_stmt := replace( l_stmt
                   , '&BIS_PREVIOUS_EFFECTIVE_END_DATE'
                   , '&ISC_FS_PREVIOUS_ASOF_DATE'
                   );
  l_stmt := replace( l_stmt
                   , '&BIS_CURRENT_EFFECTIVE_END_DATE'
                   , '&ISC_FS_CURRENT_ASOF_DATE'
                   );
  l_stmt := replace( l_stmt
                   , '&BIS_PREVIOUS_REPORT_START_DATE'
                   , '&ISC_FS_PREV_REPORT_START_DATE'
                   );
  l_stmt := replace( l_stmt
                   , '&BIS_PREVIOUS_ASOF_DATE'
                   , '&ISC_FS_PREVIOUS_ASOF_DATE'
                   );
  l_stmt := replace( l_stmt
                   , '&BIS_CURRENT_REPORT_START_DATE'
                   , '&ISC_FS_CURR_REPORT_START_DATE'
                   );
  l_stmt := replace( l_stmt
                   , '&BIS_CURRENT_ASOF_DATE'
                   , '&ISC_FS_CURRENT_ASOF_DATE'
                   );
  l_stmt := replace( l_stmt
                   , '&BIS_CURRENT_EFFECTIVE_START_DATE'
                   , 'sysdate' -- never actually used
                   );

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  -- l_stmt := l_stmt || isc_fs_rpt_util_pkg.dump_parameters(p_param);

  x_custom_sql      := l_stmt;

  poa_dbi_util_pkg.get_custom_balance_binds
  ( p_custom_output => l_custom_output
  , p_balance_fact  => isc_fs_task_act_bac_etl_pkg.g_object_name
  , p_xtd           => l_xtd
  );

  get_curr_prior_dates
  ( l_xtd
  , l_comparison_type
  , l_custom_output
  );

  x_custom_output := l_custom_output;

  poa_dbi_util_pkg.get_custom_trend_binds
  ( p_xtd             => l_xtd
  , p_comparison_type => l_comparison_type
  , x_custom_output   => l_custom_output
  );

  if l_custom_output is not null then
    for i in 1..l_custom_output.count loop
      x_custom_output.extend;
      x_custom_output(x_custom_output.count) := l_custom_output(i);
    end loop;
  end if;

end get_trd_sql;

procedure get_dtl_rpt_sql
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

begin

  isc_fs_rpt_util_pkg.register_dimension_levels
  ( l_dimension_tbl
  , l_dim_filter_map
  , isc_fs_rpt_util_pkg.G_CATEGORY, 'Y'
  , isc_fs_rpt_util_pkg.G_PRODUCT, 'Y'
  , isc_fs_rpt_util_pkg.G_CUSTOMER, 'Y'
  , isc_fs_rpt_util_pkg.G_DISTRICT, 'Y'
  , isc_fs_rpt_util_pkg.G_TASK_TYPE, 'Y'
  , isc_fs_rpt_util_pkg.G_TASK_OWNER, 'N'
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
  );

  l_mv := get_fact_mv_name
          ( 'TASK_BACKLOG_AGING_DETAIL'
          , p_param
          , l_dim_bmap
          , l_custom_output
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
                    when l_order_by like '%ISC_MEASURE_1 %' then
                      'actual_start_date'
                    when l_order_by like '%ISC_MEASURE_2 %' then
                      'actual_end_date'
                    when l_order_by like '%ISC_MEASURE_3 %' then
                      'planned_start_date'
                    when l_order_by like '%ISC_MEASURE_4 %' then
                      'age_days'
                    when l_order_by like '%ISC_MEASURE_5 %' then
                      'incident_date'
                  end ||
                  l_asc_desc ||
                  'nulls last, task_id';

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
  , p_fact_col_name      => 'actual_start_date'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'actual_start_date'
  );

  isc_fs_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'actual_end_date'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'actual_end_date'
  );

  isc_fs_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'planned_start_date'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'planned_start_date'
  );

  isc_fs_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'age_days'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'age_days'
  );

  isc_fs_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'source_object_name'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'source_object_name'
  );

  isc_fs_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'incident_date'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'incident_date'
  );

  isc_fs_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'source_object_id'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'source_object_id'
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
  , p_dimension_level    => isc_fs_rpt_util_pkg.G_PRODUCT
  , p_column_key         => 'product'
  );

  l_stmt := 'select
  oset.task_number ISC_ATTRIBUTE_1
, ' || isc_fs_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'task_type','ISC_ATTRIBUTE_2') || '
, ' || isc_fs_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'task_owner','ISC_ATTRIBUTE_3') || '
, ' || isc_fs_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'task_assignee','ISC_ATTRIBUTE_4') || '
, oset.actual_start_date ISC_MEASURE_1
, oset.actual_end_date ISC_MEASURE_2
, oset.planned_start_date ISC_MEASURE_3
, oset.age_days ISC_MEASURE_4
, oset.source_object_name ISC_ATTRIBUTE_5
, oset.incident_date ISC_MEASURE_5
, ' || isc_fs_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'customer','ISC_ATTRIBUTE_6') || '
, ' || isc_fs_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'product','ISC_ATTRIBUTE_7') || '
, ' || isc_fs_rpt_util_pkg.get_sr_detail_page_function('oset.source_object_id') || ' ISC_ATTRIBUTE_8
, null ISC_ATTRIBUTE_9'
-- above is needed to associate bucket set with report
    || '
, ' || isc_fs_rpt_util_pkg.get_task_detail_page_function('oset.task_id') || ' ISC_ATTRIBUTE_10
from
' || isc_fs_rpt_util_pkg.detail_sql
     ( p_detail_col_tbl => l_detail_col_tbl
     , p_dimension_tbl  => l_dimension_tbl
     , p_mv_name        => l_mv
     , p_where_clause   => l_where_clause
     , p_rank_order     => l_rank_order
     , p_override_date_clause => 'backlog_date_to = to_date(''4712/12/31'',''yyyy/mm/dd'') and age_days between &ISC_FS_LOW and &ISC_FS_HIGH'
     );

  poa_dbi_util_pkg.get_custom_balance_binds
  ( p_custom_output => l_custom_output
  , p_balance_fact  => isc_fs_task_act_bac_etl_pkg.g_object_name
  , p_xtd           => l_xtd
  );

  -- needed because used in calculating the age at ISC_FS_CURRENT_ASOF_DATE + &ISC_FS_CURRENT_TIME
  get_curr_prior_dates
  ( l_xtd
  , l_comparison_type
  , l_custom_output
  );

  isc_fs_rpt_util_pkg.bind_low_high
  ( p_param
  , isc_fs_rpt_util_pkg.G_BACKLOG_AGING_DISTRIB
  , 'BIV_FS_BACKLOG_AGING'
  , l_custom_output
  );

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  -- l_stmt := l_stmt || isc_fs_rpt_util_pkg.dump_parameters(p_param);

  x_custom_sql      := l_stmt;

  x_custom_output := l_custom_output;

end get_dtl_rpt_sql;

end isc_fs_task_bac_aging_rpt_pkg;

/
