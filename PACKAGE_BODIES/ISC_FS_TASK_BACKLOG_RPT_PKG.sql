--------------------------------------------------------
--  DDL for Package Body ISC_FS_TASK_BACKLOG_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_FS_TASK_BACKLOG_RPT_PKG" 
/* $Header: iscfstkbsrptb.pls 120.3 2006/04/12 20:47:29 kreardon noship $ */
as

  g_detail_rep_func  constant varchar2(50) := 'ISC_FS_TASK_BAC_STATUS_RPT_REP';
  g_task_rep_func    constant varchar2(50) := 'ISC_FS_TASK_BAC_STATUS_TBL_REP';

function get_detail_drill
( p_view_by in varchar2
, p_column  in varchar2
, p_col_alias in varchar2
)
return varchar2
is
  l_column_name varchar2(30);
begin

  return
    -- R12 resource type
    isc_fs_rpt_util_pkg.get_detail_drill_down
    ( p_view_by       => p_view_by
    , p_function_name => g_detail_rep_func
    , p_check_column_name => 'ISC_MEASURE_4_B' || p_column
    , p_extra_params  => '&BIV_FS_BACKLOG_STATUS=' || p_column
    , p_column_alias  => p_col_alias || '_B' || p_column
    , p_check_resource => 'Y'
    );

end get_detail_drill;

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

  if p_report_type = 'TASK_BACKLOG_STATUS' then

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
, c.report_date ' || case
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
, f.in_planning_count
, f.assigned_count
, f.working_count
, f.completed_count
, f.other_count
from
  isc_fs_005_mv f' || case
                        when l_district_leaf_node = 'N' then '
, isc_fs_002_mv den'
                      end || '
, eni_denorm_hierarchies v
, mtl_default_category_sets m
, fii_time_structures c
where
    m.functional_area_id = 11
and v.object_id = m.category_set_id
and v.dbi_flag = ''Y''
and v.object_type = ''CATEGORY_SET''
and f.vbh_category_id = v.child_id
and f.time_id = c.time_id
and f.period_type_id = c.period_type_id
and f.time_id = c.time_id
and bitand(c.record_type_id,512) = 512
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
  c.report_date ' || case
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
, f.in_planning_count
, f.assigned_count
, f.working_count
, f.completed_count
, f.other_count
from
  isc_fs_005_mv f' || case
                        when l_district_leaf_node = 'N' then '
, isc_fs_002_mv den'
                      end || '
, fii_time_structures c
where
    f.period_type_id = c.period_type_id
and f.time_id = c.time_id
and bitand(c.record_type_id,512) = 512
and f.grp_id = &ISC_GRP_ID' || case
                                 when l_district_leaf_node = 'N' then '
and f.parent_district_id = den.rg_id'
                               end || '
)';

    else

      return '(
select
  c.report_date
, f.parent_district_id
, f.record_type
, f.district_id
, f.district_id_c
, f.backlog_count
, f.in_planning_count
, f.assigned_count
, f.working_count
, f.completed_count
, f.other_count
from
  isc_fs_006_mv f
, fii_time_structures c
where
    f.period_type_id = c.period_type_id
and f.time_id = c.time_id
and bitand(c.record_type_id,512) = 512
)';

    end if;

  elsif p_report_type = 'TASK_BACKLOG_DETAIL' then

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
    , b.backlog_date_from
    , b.backlog_date_to
    , b.backlog_status_code
    , t.task_type_id
    , t.owner_id
    -- R12 resource type
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
    l_product := 'v4.description ISC_ATTRIBUTE_1';
  else
    l_product := 'null ISC_ATTRIBUTE_1';
  end if;

  l_mv := get_fact_mv_name
          ( 'TASK_BACKLOG_STATUS'
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
                             , p_col_name     => 'in_planning_count'
                             , p_alias_name   => 'in_planning'
                             , p_to_date_type => 'BAL'
                             , p_prior_code   => poa_dbi_util_pkg.no_priors
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl
                             , p_col_name     => 'working_count'
                             , p_alias_name   => 'working'
                             , p_to_date_type => 'BAL'
                             , p_prior_code   => poa_dbi_util_pkg.no_priors
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl
                             , p_col_name     => 'assigned_count'
                             , p_alias_name   => 'assigned'
                             , p_to_date_type => 'BAL'
                             , p_prior_code   => poa_dbi_util_pkg.no_priors
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl
                             , p_col_name     => 'completed_count'
                             , p_alias_name   => 'completed'
                             , p_to_date_type => 'BAL'
                             , p_prior_code   => poa_dbi_util_pkg.no_priors
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl
                             , p_col_name     => 'other_count'
                             , p_alias_name   => 'other'
                             , p_to_date_type => 'BAL'
                             , p_prior_code   => poa_dbi_util_pkg.no_priors
                             );

  l_stmt := 'select
  ' || l_viewby_select || '
, ISC_MEASURE_1
, ISC_MEASURE_2
, ISC_MEASURE_3
, ISC_MEASURE_4_B1
, ISC_MEASURE_4_B2
, ISC_MEASURE_4_B3
, ISC_MEASURE_4_B4
, ISC_MEASURE_4_B5
, ISC_MEASURE_21
, ISC_MEASURE_22
, ISC_MEASURE_23
, ISC_MEASURE_24_B1
, ISC_MEASURE_24_B2
, ISC_MEASURE_24_B3
, ISC_MEASURE_24_B4
, ISC_MEASURE_24_B5
, ' || l_product || '
, ' || isc_fs_rpt_util_pkg.get_district_drill_down
       ( l_view_by
       , g_task_rep_func
       , 'ISC_ATTRIBUTE_2' ) || '
, ' || isc_fs_rpt_util_pkg.get_category_drill_down
       ( l_view_by
       , g_task_rep_func
       , 'ISC_ATTRIBUTE_3' ) || '
, ' || get_detail_drill( l_view_by, '1', 'ISC_ATTRIBUTE_4' ) || '
, ' || get_detail_drill( l_view_by, '2', 'ISC_ATTRIBUTE_4' ) || '
, ' || get_detail_drill( l_view_by, '3', 'ISC_ATTRIBUTE_4' ) || '
, ' || get_detail_drill( l_view_by, '4', 'ISC_ATTRIBUTE_4' ) || '
, ' || get_detail_drill( l_view_by, '5', 'ISC_ATTRIBUTE_4' ) || '
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
       ( 'c_in_planning'
       , 'c_backlog'
       , 'ISC_MEASURE_4_B1'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_assigned'
       , 'c_backlog'
       , 'ISC_MEASURE_4_B2'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_working'
       , 'c_backlog'
       , 'ISC_MEASURE_4_B3'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_completed'
       , 'c_backlog'
       , 'ISC_MEASURE_4_B4'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_other'
       , 'c_backlog'
       , 'ISC_MEASURE_4_B5'
       ) || '
, nvl(p_backlog_total,0) ISC_MEASURE_21
, nvl(c_backlog_total,0) ISC_MEASURE_22
, ' || isc_fs_rpt_util_pkg.change_column
       ( 'c_backlog_total'
       , 'p_backlog_total'
       , 'ISC_MEASURE_23' ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_in_planning_total'
       , 'c_backlog_total'
       , 'ISC_MEASURE_24_B1'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_assigned_total'
       , 'c_backlog_total'
       , 'ISC_MEASURE_24_B2'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_working_total'
       , 'c_backlog_total'
       , 'ISC_MEASURE_24_B3'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_completed_total'
       , 'c_backlog_total'
       , 'ISC_MEASURE_24_B4'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_other_total'
       , 'c_backlog_total'
       , 'ISC_MEASURE_24_B5'
       ) || '
from ' || poa_dbi_template_pkg.status_sql
        ( p_fact_name            => l_mv
        , p_where_clause         => l_where_clause
        , p_join_tables          => l_join_tbl
        , p_use_windowing        => 'Y' --'N'
        , p_col_name             => l_col_tbl
        , p_use_grpid            => 'N'
        , p_paren_count          => 3
        , p_filter_where         => '(isc_measure_1 >0 or isc_measure_2>0)) iset ' --null
        , p_generate_viewby      => 'Y'
        );

  poa_dbi_util_pkg.get_custom_balance_binds
  ( p_custom_output => l_custom_output
  , p_balance_fact  => isc_fs_task_act_bac_etl_pkg.g_object_name
  , p_xtd           => l_xtd
  );

  isc_fs_rpt_util_pkg.enhance_time_join
  ( l_stmt
  , 'N'
  );

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  -- l_stmt := l_stmt || isc_fs_rpt_util_pkg.dump_parameters(p_param);

  x_custom_output := l_custom_output;

  x_custom_sql      := l_stmt;

end get_tbl_sql;

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
  , isc_fs_rpt_util_pkg.G_BACKLOG_STATUS, 'Y'
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
          ( 'TASK_BACKLOG_DETAIL'
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
  , p_dimension_level    => isc_fs_rpt_util_pkg.G_BACKLOG_STATUS
  , p_column_key         => 'task_status'
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
       (l_detail_col_tbl,'task_status','ISC_ATTRIBUTE_2') || '
, ' || isc_fs_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'task_type','ISC_ATTRIBUTE_3') || '
, ' || isc_fs_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'task_owner','ISC_ATTRIBUTE_4') || '
, ' || isc_fs_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'task_assignee','ISC_ATTRIBUTE_5') || '
, oset.actual_start_date ISC_MEASURE_1
, oset.actual_end_date ISC_MEASURE_2
, oset.planned_start_date ISC_MEASURE_3
, oset.source_object_name ISC_ATTRIBUTE_6
, oset.incident_date ISC_MEASURE_4
, ' || isc_fs_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'customer','ISC_ATTRIBUTE_7') || '
, ' || isc_fs_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'product','ISC_ATTRIBUTE_8') || '
, ' || isc_fs_rpt_util_pkg.get_sr_detail_page_function('oset.source_object_id') || ' ISC_ATTRIBUTE_9
, null ISC_ATTRIBUTE_10'
-- above is needed to associate bucket set with report
    || '
, ' || isc_fs_rpt_util_pkg.get_task_detail_page_function('oset.task_id') || ' ISC_ATTRIBUTE_11
from
' || isc_fs_rpt_util_pkg.detail_sql
     ( p_detail_col_tbl => l_detail_col_tbl
     , p_dimension_tbl  => l_dimension_tbl
     , p_mv_name        => l_mv
     , p_where_clause   => l_where_clause
     , p_rank_order     => l_rank_order
     , p_override_date_clause => 'least(&LAST_COLLECTION,&BIS_CURRENT_ASOF_DATE) between fact.backlog_date_from and fact.backlog_date_to'
     );

  poa_dbi_util_pkg.get_custom_balance_binds
  ( p_custom_output => l_custom_output
  , p_balance_fact  => isc_fs_task_act_bac_etl_pkg.g_object_name
  , p_xtd           => l_xtd
  );

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  -- l_stmt := l_stmt || isc_fs_rpt_util_pkg.dump_parameters(p_param);

  x_custom_sql      := l_stmt;

  x_custom_output := l_custom_output;

end get_dtl_rpt_sql;

end isc_fs_task_backlog_rpt_pkg;

/
