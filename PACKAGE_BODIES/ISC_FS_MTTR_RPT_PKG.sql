--------------------------------------------------------
--  DDL for Package Body ISC_FS_MTTR_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_FS_MTTR_RPT_PKG" 
/* $Header: iscfsmttrrptb.pls 120.5 2006/04/12 20:44:48 kreardon noship $ */
as

  g_detail_rep_func  constant varchar2(50) := 'ISC_FS_MTTR_RPT_REP';
  g_task_rep_func    constant varchar2(50) := 'ISC_FS_MTTR_TBL_REP';
  g_trd_rep_func     constant varchar2(50) := 'ISC_FS_MTTR_TRD_REP';

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

  if p_report_type = 'MTTR' then

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
, f.time_id
, f.period_type_id ' || case
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
, f.customer_id
, f.product_id
, f.incident_severity_id
, f.resolved_count
, f.total_time_to_resolve
, f.time_to_resolve_b1
, f.time_to_resolve_b2
, f.time_to_resolve_b3
, f.time_to_resolve_b4
, f.time_to_resolve_b5
, f.time_to_resolve_b6
, f.time_to_resolve_b7
, f.time_to_resolve_b8
, f.time_to_resolve_b9
, f.time_to_resolve_b10
from
  isc_fs_009_mv f' || case
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
and f.vbh_category_id = v.child_id' || case
                                         when l_district_leaf_node = 'N' then '
and f.parent_district_id = den.rg_id'
                                       end || '
and f.grp_id = &ISC_GRP_ID' || case
                                 when l_top_node = 'Y' then '
and v.top_node_flag = ''Y'''   end || '
)';

    elsif bitand(p_dim_bmap,isc_fs_rpt_util_pkg.G_PRODUCT_BMAP) = isc_fs_rpt_util_pkg.G_PRODUCT_BMAP or
          bitand(p_dim_bmap,isc_fs_rpt_util_pkg.G_CUSTOMER_BMAP) = isc_fs_rpt_util_pkg.G_CUSTOMER_BMAP or
          bitand(p_dim_bmap,isc_fs_rpt_util_pkg.G_SEVERITY_BMAP) = isc_fs_rpt_util_pkg.G_SEVERITY_BMAP then

      return '(
select
  f.time_id
, f.period_type_id ' || case
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
, f.customer_id
, f.product_id
, f.incident_severity_id
, f.resolved_count
, f.total_time_to_resolve
, f.time_to_resolve_b1
, f.time_to_resolve_b2
, f.time_to_resolve_b3
, f.time_to_resolve_b4
, f.time_to_resolve_b5
, f.time_to_resolve_b6
, f.time_to_resolve_b7
, f.time_to_resolve_b8
, f.time_to_resolve_b9
, f.time_to_resolve_b10
from
  isc_fs_009_mv f' || case
                         when l_district_leaf_node = 'N' then '
, isc_fs_002_mv den'
                       end || '
where
    f.grp_id = &ISC_GRP_ID ' || case
                                  when l_district_leaf_node = 'N' then '
and f.parent_district_id = den.rg_id'
                                end || '
)';

    else

      return '(
select
  f.time_id
, f.period_type_id
, f.parent_district_id
, f.record_type
, f.district_id
, f.district_id_c
, f.resolved_count
, f.total_time_to_resolve
, f.time_to_resolve_b1
, f.time_to_resolve_b2
, f.time_to_resolve_b3
, f.time_to_resolve_b4
, f.time_to_resolve_b5
, f.time_to_resolve_b6
, f.time_to_resolve_b7
, f.time_to_resolve_b8
, f.time_to_resolve_b9
, f.time_to_resolve_b10
from isc_fs_010_mv f
)';

    end if;

  elsif p_report_type = 'MTTR_DETAIL' then

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
    , t.owner_id
    , t.owner_type
    , t.ttr_assignee_id assignee_id
    , t.ttr_assignee_type assignee_type ' ||
      case
        when l_resource = 'N' then '
    , d.parent_prg_id parent_district_id '
        else '
    , decode( t.ftf_ttr_district_rule, ''0'', t.ttr_assignee_id, t.owner_id ) || ''.'' || decode( t.ftf_ttr_district_rule, ''0'', t.ttr_district_id, t.owner_district_id ) district_id_c '
      end  || '
    , t.source_object_name
    , t.source_object_id
    , t.incident_date
    , r.customer_id
    , r.time_to_resolution*24 time_to_resolve
    , r.report_date
    , nvl(s.master_id,s.id) product_id ' ||
      case
        when bitand(p_dim_bmap,isc_fs_rpt_util_pkg.G_CATEGORY_BMAP) = isc_fs_rpt_util_pkg.G_CATEGORY_BMAP then
          '
    , v.top_node_flag vbh_top_node_flag
    , v.parent_id vbh_parent_category_id
    , v.imm_child_id vbh_child_category_id'
      end || '
    , r.incident_severity_id
    from
      isc_fs_tasks_f t
    , biv_dbi_resolution_sum_f r
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
        t.include_task_in_ttr_flag = ''Y''
    and t.source_object_id = r.incident_id
    and r.time_to_resolution is not null
    and r.inventory_item_id = s.inventory_item_id
    and r.inv_organization_id = s.organization_id' ||
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
    and d.rg_id = decode( t.ftf_ttr_district_rule, ''0'', t.ttr_district_id, t.owner_district_id )'
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

  l_bucket_rec bis_bucket_pub.bis_bucket_rec_type;
  l_to_date_type     varchar2(200);

begin

  isc_fs_rpt_util_pkg.register_dimension_levels
  ( l_dimension_tbl
  , l_dim_filter_map
  , isc_fs_rpt_util_pkg.G_CATEGORY, 'Y'
  , isc_fs_rpt_util_pkg.G_PRODUCT, 'Y'
  , isc_fs_rpt_util_pkg.G_CUSTOMER, 'Y'
  , isc_fs_rpt_util_pkg.G_DISTRICT, 'Y'
  , isc_fs_rpt_util_pkg.G_SEVERITY, 'Y'
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

  l_mv := get_fact_mv_name
          ( 'MTTR'
          , p_param
          , l_dim_bmap
          , l_custom_output
          );

  l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl
                             , p_col_name     => 'resolved_count'
                             , p_alias_name   => 'count'
                             , p_to_date_type => l_to_date_type
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl
                             , p_col_name     => 'total_time_to_resolve'
                             , p_alias_name   => 'total_hours'
                             , p_to_date_type => l_to_date_type
                             );

  poa_dbi_util_pkg.add_bucket_columns
  ( p_short_name   => 'BIV_FS_TIME_TO_RES'
  , p_col_tbl      => l_col_tbl
  , p_col_name     => 'time_to_resolve'
  , p_alias_name   => 'bucket'
  , p_prior_code   => poa_dbi_util_pkg.no_priors
  , p_to_date_type => l_to_date_type
  , x_bucket_rec   => l_bucket_rec
  );


  l_stmt := 'select
  ' || l_viewby_select || '
, ISC_MEASURE_1
, ISC_MEASURE_2
, ISC_MEASURE_3
, ISC_MEASURE_4
'   || poa_dbi_util_pkg.get_bucket_outer_query
       ( p_bucket_rec => l_bucket_rec
       , p_col_name   => 'ISC_MEASURE_5'
       , p_alias_name => 'ISC_MEASURE_5'
       , p_prefix     => null
       , p_suffix     => null
       , p_total_flag => 'N'
       ) || '
, ISC_MEASURE_1 ISC_MEASURE_6
, ISC_MEASURE_2 ISC_MEASURE_7
, ISC_MEASURE_2 ISC_MEASURE_8
, ISC_MEASURE_3 ISC_MEASURE_9
, ISC_MEASURE_21
, ISC_MEASURE_22
, ISC_MEASURE_23
, ISC_MEASURE_24
'   || poa_dbi_util_pkg.get_bucket_outer_query
       ( p_bucket_rec => l_bucket_rec
       , p_col_name   => 'ISC_MEASURE_25'
       , p_alias_name => 'ISC_MEASURE_25'
       , p_prefix     => null
       , p_suffix     => null
       , p_total_flag => 'N'
       ) || '
, ISC_MEASURE_21 ISC_MEASURE_26
, ISC_MEASURE_22 ISC_MEASURE_27
, ISC_MEASURE_22 ISC_MEASURE_28
, ISC_MEASURE_23 ISC_MEASURE_29
, ' || l_product || '
, ' || isc_fs_rpt_util_pkg.get_district_drill_down
       ( l_view_by
       , g_task_rep_func
       , 'ISC_ATTRIBUTE_3' ) || '
, ' || isc_fs_rpt_util_pkg.get_category_drill_down
       ( l_view_by
       , g_task_rep_func
       , 'ISC_ATTRIBUTE_4' ) || '
, ' || isc_fs_rpt_util_pkg.get_bucket_drill_down
       ( p_bucket_rec     => l_bucket_rec
       , p_view_by        => l_view_by
       , p_function_name  => case
                               when l_view_by in ( isc_fs_rpt_util_pkg.G_PRODUCT
                                                 , isc_fs_rpt_util_pkg.G_CUSTOMER
                                                 , isc_fs_rpt_util_pkg.G_SEVERITY
                                                 , isc_fs_rpt_util_pkg.G_DISTRICT ) then
                                 g_detail_rep_func
                               else null
                             end
       , p_check_column_name => 'ISC_MEASURE_5'
       , p_column_alias   => 'ISC_ATTRIBUTE_5'
       , p_extra_params   => '&BIV_FS_TIME_TO_RES='
       , p_check_resource => 'Y'
       ) || '
from (
select
  row_number() over(&ORDER_BY_CLAUSE nulls last, '|| isc_fs_rpt_util_pkg.get_inner_select_col(l_join_tbl) || ')-1 rnk
, iset.*
from ( select * from (
select ' || isc_fs_rpt_util_pkg.get_inner_select_col(l_join_tbl) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'p_total_hours'
       , 'p_count'
       , 'ISC_MEASURE_1'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_total_hours'
       , 'c_count'
       , 'ISC_MEASURE_2'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.change_column
       ( isc_fs_rpt_util_pkg.rate_column
         ( 'c_total_hours'
         , 'c_count'
         , null
         , 'N'
         )
       , isc_fs_rpt_util_pkg.rate_column
         ( 'p_total_hours'
         , 'p_count'
         , null
         , 'N'
         )
       , 'ISC_MEASURE_3'
       , 'N'
       ) || '
, nvl(c_count,0) ISC_MEASURE_4
'   || poa_dbi_util_pkg.get_bucket_outer_query
       ( p_bucket_rec => l_bucket_rec
       , p_col_name   => 'bucket'
       , p_alias_name => 'ISC_MEASURE_5'
       , p_prefix     => 'nvl(c_'
       , p_suffix     => ',0)/abs(decode(c_count,0,null,c_count))*100'
       , p_total_flag => 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'p_total_hours_total'
       , 'p_count_total'
       , 'ISC_MEASURE_21'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'c_total_hours_total'
       , 'c_count_total'
       , 'ISC_MEASURE_22'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.change_column
       ( isc_fs_rpt_util_pkg.rate_column
         ( 'c_total_hours_total'
         , 'c_count_total'
         , null
         , 'N'
         )
       , isc_fs_rpt_util_pkg.rate_column
         ( 'p_total_hours_total'
         , 'p_count_total'
         , null
         , 'N'
         )
       , 'ISC_MEASURE_23'
       , 'N'
       ) || '
, nvl(c_count_total,0) ISC_MEASURE_24
'   || poa_dbi_util_pkg.get_bucket_outer_query
       ( p_bucket_rec => l_bucket_rec
       , p_col_name   => 'bucket'
       , p_alias_name => 'ISC_MEASURE_25'
       , p_prefix     => 'nvl(c_'
       , p_suffix     => ',0)/abs(decode(c_count_total,0,null,c_count_total))*100'
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

  isc_fs_rpt_util_pkg.enhance_time_join
  ( l_stmt
  , 'N'
  );

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  -- l_stmt := l_stmt || isc_fs_rpt_util_pkg.dump_parameters(p_param);

  poa_dbi_util_pkg.get_custom_rolling_binds
  ( p_custom_output => l_custom_output
  , p_xtd           => l_xtd
  );

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
  , isc_fs_rpt_util_pkg.G_SEVERITY, 'Y'
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

  --l_where_clause := l_where_clause || ' and fact.closed > 0';

  l_mv := get_fact_mv_name
          ( 'MTTR'
          , p_param
          , l_dim_bmap
          , l_custom_output
          );

  l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl
                             , p_col_name     => 'resolved_count'
                             , p_alias_name   => 'count'
                             , p_to_date_type => l_to_date_type
                             , p_grand_total => 'N'
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl      => l_col_tbl
                             , p_col_name     => 'total_time_to_resolve'
                             , p_alias_name   => 'total_hours'
                             , p_to_date_type => l_to_date_type
                             , p_grand_total => 'N'
                             );

  l_stmt := 'select
  cal.name VIEWBY
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'iset.p_total_hours'
       , 'iset.p_count'
       , 'ISC_MEASURE_1'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.rate_column
       ( 'iset.c_total_hours'
       , 'iset.c_count'
       , 'ISC_MEASURE_2'
       , 'N'
       ) || '
, ' || isc_fs_rpt_util_pkg.change_column
       ( isc_fs_rpt_util_pkg.rate_column
         ( 'iset.c_total_hours'
         , 'iset.c_count'
         , null
         , 'N'
         )
       , isc_fs_rpt_util_pkg.rate_column
         ( 'iset.p_total_hours'
         , 'iset.p_count'
         , null
         , 'N'
         )
       , 'ISC_MEASURE_3'
       , 'N'
       )  ||
  isc_fs_rpt_util_pkg.get_trend_drill
  ( l_xtd
  , g_trd_rep_func
  , 'ISC_ATTRIBUTE_2'
  , 'ISC_ATTRIBUTE_3'
  ) || '
from
  ' || poa_dbi_template_pkg.trend_sql
        ( p_xtd                  => l_xtd
        , p_comparison_type      => l_comparison_type
        , p_fact_name            => l_mv
        , p_where_clause         => l_where_clause
        , p_col_name             => l_col_tbl
        , p_use_grpid            => 'N'
        );

  isc_fs_rpt_util_pkg.enhance_time_join
  ( l_stmt
  , 'Y'
  );

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  -- l_stmt := l_stmt || isc_fs_rpt_util_pkg.dump_parameters(p_param);

  x_custom_sql      := l_stmt;

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
  , isc_fs_rpt_util_pkg.G_SEVERITY, 'Y'
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
          ( 'MTTR_DETAIL'
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
                      'report_date'
                    when l_order_by like '%ISC_MEASURE_2 %' then
                      'time_to_resolve'
                  end ||
                  l_asc_desc ||
                  'nulls last, task_id';

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
  , p_fact_col_name      => 'report_date'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'report_date'
  );

  isc_fs_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'time_to_resolve'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'time_to_resolve'
  );

  l_stmt := 'select
  oset.source_object_name ISC_ATTRIBUTE_1
, ' || isc_fs_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'customer','ISC_ATTRIBUTE_2') || '
, ' || isc_fs_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'product','ISC_ATTRIBUTE_3') || '
, oset.task_number ISC_ATTRIBUTE_4
, ' || isc_fs_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'task_owner','ISC_ATTRIBUTE_5') || '
, ' || isc_fs_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'task_assignee','ISC_ATTRIBUTE_6') || '
, oset.report_date ISC_MEASURE_1
, oset.time_to_resolve ISC_MEASURE_2
, ' || isc_fs_rpt_util_pkg.get_sr_detail_page_function('oset.source_object_id') || ' ISC_ATTRIBUTE_7
, null ISC_ATTRIBUTE_8'
-- above is needed to associate bucket set with report
    || '
, ' || isc_fs_rpt_util_pkg.get_task_detail_page_function('oset.task_id') || ' ISC_ATTRIBUTE_9
from
' || isc_fs_rpt_util_pkg.detail_sql
     ( p_detail_col_tbl => l_detail_col_tbl
     , p_dimension_tbl  => l_dimension_tbl
     , p_mv_name        => l_mv
     , p_where_clause   => l_where_clause || ' and time_to_resolve between &ISC_FS_LOW and &ISC_FS_HIGH'
     , p_rank_order     => l_rank_order
     , p_override_date_clause => 'report_date >= &BIS_CURRENT_EFFECTIVE_START_DATE and report_date < &BIS_CURRENT_ASOF_DATE +1'
     );

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  -- l_stmt := l_stmt || isc_fs_rpt_util_pkg.dump_parameters(p_param);

  x_custom_sql      := l_stmt;

  isc_fs_rpt_util_pkg.bind_low_high
  ( p_param
  , isc_fs_rpt_util_pkg.G_TIME_TO_RES_DISTRIB
  , 'BIV_FS_TIME_TO_RES'
  , l_custom_output
  );

  x_custom_output := l_custom_output;

end get_dtl_rpt_sql;

end isc_fs_mttr_rpt_pkg;

/
