--------------------------------------------------------
--  DDL for Package Body ISC_MAINT_REQ_CMPL_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_MAINT_REQ_CMPL_RPT_PKG" 
/* $Header: iscmaintreqcmrpb.pls 120.2 2006/02/03 03:24:59 nbhamidi noship $ */
as

procedure bind_request_id
( p_custom_output in out nocopy bis_query_attributes_tbl
, p_param         in bis_pmv_page_parameter_tbl
) is

  l_custom_rec BIS_QUERY_ATTRIBUTES;

begin

  if p_custom_output is null then
    p_custom_output := bis_query_attributes_tbl();
  end if;

  l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;

  l_custom_rec.attribute_name := '&ISC_REQUEST_ID' ;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_value := isc_maint_rpt_util_pkg.get_parameter_value
                                  ( p_param
                                  , 'BIV_ATTRIBUTE9'
                                  );
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
  p_custom_output.extend;
  p_custom_output(p_custom_output.count) := l_custom_rec;

end bind_request_id;

function get_fact_mv_name
( p_report_type   in varchar2
, p_param         in bis_pmv_page_parameter_tbl
, p_dim_bmap      in number
, p_custom_output in out nocopy bis_query_attributes_tbl
)
return varchar2
is

  l_org_id varchar2(200);
  l_view_by varchar2(200);
  l_bucket_num varchar2(200);

begin

  l_org_id := isc_maint_rpt_util_pkg.get_parameter_id
              ( p_param
              , isc_maint_rpt_util_pkg.G_ORGANIZATION
              );

  if p_report_type = 'REQUEST_TO_COMPLETION' then

    l_view_by := isc_maint_rpt_util_pkg.get_parameter_value
                 ( p_param
                 , 'VIEW_BY'
                 );

    isc_maint_rpt_util_pkg.bind_group_id
    ( p_dim_bmap
    , p_custom_output
    , isc_maint_rpt_util_pkg.G_ASSET_GROUP
    , isc_maint_rpt_util_pkg.G_ASSET_NUMBER
    , isc_maint_rpt_util_pkg.G_DEPARTMENT
    , isc_maint_rpt_util_pkg.G_REQ_CMPL_AGING
    );

    return '(
    select
      time_id
    , period_type_id
    , grp_id
    , ' ||
      case l_view_by /* replaced asset_number with instance_id */
        when isc_maint_rpt_util_pkg.G_DEPARTMENT then
          'decode(department_id,-1,-1,organization_id) organization_id'
        when isc_maint_rpt_util_pkg.G_ASSET_GROUP then
          'decode(asset_group_id,-1,-1,organization_id) organization_id'
        when isc_maint_rpt_util_pkg.G_ASSET_NUMBER then
          'decode(instance_id,-1,-1,organization_id) organization_id'
        else
          'organization_id'
      end ||'
    , request_type
    , ' ||
      case l_view_by
        when isc_maint_rpt_util_pkg.G_ASSET_NUMBER then /* replaced asset_number with instance_id */
          'decode(instance_id,-1,-1,asset_group_id) asset_group_id'
        else
          'asset_group_id'
      end || '
    , instance_id
    , to_char(department_id) department_id
    , bucket_num
    , organization_id organization_id_c
    , decode(asset_group_id,-1,-1,asset_group_id) asset_group_id_c /* removed concatenation to org. to make asset group independent of org. */
    , decode(instance_id,-1,-1,instance_id) instance_id_c /* replaced asset_number with instance_id */
    , decode(department_id,-1,''-1'',department_id||''-1'') department_id_c
    , total_requests
    , total_response_days
    , total_completion_days
    from isc_maint_003_mv fact
    where fact.grp_id = &ISC_GRP_ID' ||
    case
      when l_org_id is null then
        '
    and ' || isc_maint_rpt_util_pkg.get_sec_where_clause( 'fact', l_org_id )
    end || '
)';

  elsif p_report_type = 'REQUEST_TO_COMPLETION_DTL' then

    l_bucket_num := isc_maint_rpt_util_pkg.get_parameter_id
                    ( p_param
                    , isc_maint_rpt_util_pkg.G_REQ_CMPL_AGING
                    );

    return '(
    select
      f.completion_date report_date
    , f.organization_id
    , f.request_type
    , f.maint_request_id
    , f.request_number
    , f.asset_group_id
    , f.instance_id /* replaced asset_number with instance_id */
    , to_char(f.department_id) department_id
    , f.request_severity_id
    , f.request_start_date
    , f.response_days
    , f.completion_days
    , f.work_order_count
    , f.organization_id organization_id_c
    , decode(f.asset_group_id,-1,-1,f.asset_group_id) asset_group_id_c /* removed concatenation to org. to make asset group independent of org. */
    , decode(f.instance_id,-1,-1,f.instance_id) instance_id_c /* replaced asset_number with instance_id */
    , decode(f.department_id,-1,''-1'',f.department_id||''-1'') department_id_c' ||
    case
      when l_bucket_num is not null then '
    , case
        when f.completion_days < b.range1_high or
             b.range1_high is null then 1
        when f.completion_days >= b.range1_high and
             (f.completion_days < b.range2_high or
              b.range2_high is null) then 2
        when f.completion_days >= b.range2_high and
             (f.completion_days < b.range3_high or
              b.range3_high is null) then 3
        when f.completion_days >= b.range3_high and
             (f.completion_days < b.range4_high or
              b.range4_high is null) then 4
        when f.completion_days >= b.range4_high and
             (f.completion_days < b.range5_high or
              b.range5_high is null) then 5
        when f.completion_days >= b.range5_high and
             (f.completion_days < b.range6_high or
              b.range6_high is null) then 6
        when f.completion_days >= b.range6_high and
             (f.completion_days < b.range7_high or
              b.range7_high is null) then 7
        when f.completion_days >= b.range7_high and
             (f.completion_days < b.range8_high or
              b.range8_high is null) then 8
        when f.completion_days >= b.range8_high and
             (f.completion_days < b.range9_high or
              b.range9_high is null) then 9
        when f.completion_days >= b.range9_high and
             (f.completion_days < b.range10_high or
              b.range10_high is null) then 10
        else 0
      end bucket_num
      '
    end || '
    from
      isc_maint_req_wo_f f' ||
    case
      when l_bucket_num is not null then '
    , bis_bucket_customizations b
    , bis_bucket bb
      '
    end || '
    where f.work_order_id is not null ' ||
    case
      when l_bucket_num is not null then '
    and bb.short_name = ''BIV_MAINT_REQ_COMP_AGING''
    and bb.bucket_id = b.bucket_id
      '
    end ||
    case
      when l_org_id is null then
        '
    and ' || isc_maint_rpt_util_pkg.get_sec_where_clause( 'f', l_org_id )
    end || '
  )';


  else

    return '(
    select
      &BIS_CURRENT_ASOF_DATE report_date
    , f.request_type
    , w.organization_id
    , w.work_order_id
    , w.work_order_name
    , w.work_order_type
    , w.activity_id
    , w.user_defined_status_id /* bug 5002342 */
    , w.scheduled_start_date
    , w.scheduled_completion_date
    , w.completion_date
    , f.organization_id organization_id_c
    , decode(f.asset_group_id,-1,-1,f.asset_group_id) asset_group_id_c /* removed concatenation to org. to make it independent of org. */
    , decode(f.instance_id,-1,-1,f.instance_id) instance_id_c /* replaced asset_number with instance_id */
    , decode(f.department_id,-1,''-1'',f.department_id||''-1'') department_id_c
    from
      isc_maint_req_wo_f f
    , isc_maint_work_orders_f w
    where f.work_order_id = w.work_order_id
    and f.organization_id = w.organization_id
    and w.status_type <> 7
    and f.maint_request_id = &ISC_REQUEST_ID' ||
    case
      when l_org_id is null then
        '
    and ' || isc_maint_rpt_util_pkg.get_sec_where_clause( 'f', l_org_id )
    end || '
  )';

  end if;

end get_fact_mv_name;

procedure get_tbl_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
)
is

  l_dimension_tbl    isc_maint_rpt_util_pkg.t_dimension_tbl;
  l_dim_filter_map   poa_dbi_util_pkg.poa_dbi_dim_map;
  l_custom_output    bis_query_attributes_tbl;
  l_curr_suffix      varchar2(3);
  l_where_clause     varchar2(10000);
  l_viewby_select    varchar2(200);
  l_join_tbl         poa_dbi_util_pkg.poa_dbi_join_tbl;
  l_dim_bmap         number;
  l_comparison_type  varchar2(200);
  l_xtd              varchar2(200);
  l_mv               varchar2(10000);
  l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_stmt             varchar2(32767);
  l_asset_grp_column varchar2(200);
  l_inner_query      varchar2(5000);
begin

  isc_maint_rpt_util_pkg.register_dimension_levels
  ( l_dimension_tbl
  , l_dim_filter_map
  , isc_maint_rpt_util_pkg.G_ASSET_GROUP, 'Y'
  , isc_maint_rpt_util_pkg.G_ASSET_NUMBER, 'Y'
  , isc_maint_rpt_util_pkg.G_REQUEST_TYPE, 'Y'
  );

  isc_maint_rpt_util_pkg.process_parameters
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

  l_mv := get_fact_mv_name
          ( 'REQUEST_TO_COMPLETION'
          , p_param
          , l_dim_bmap
          , l_custom_output
          );

  l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'total_requests'
                             , p_alias_name => 'requests'
                             , p_to_date_type => 'XTD'
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'total_response_days'
                             , p_alias_name => 'response_days'
                             , p_to_date_type => 'XTD'
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'total_completion_days'
                             , p_alias_name => 'completion_days'
                             , p_to_date_type => 'XTD'
                             );

/* if view by is asset_number then add the asset_group column */
if(isc_maint_rpt_util_pkg.get_parameter_id(p_param,'VIEW_BY')) =
isc_maint_rpt_util_pkg.G_ASSET_NUMBER then
        l_asset_grp_column := isc_maint_rpt_util_pkg.add_asset_group_column(isc_maint_rpt_util_pkg.G_ASSET_NUMBER,l_dimension_tbl);
else
        l_asset_grp_column :='NULL';
end if ;

/* to enable windowing we are using an addition inline view */
l_stmt := ' select ' || l_viewby_select ||
        ',biv_measure1
        ,biv_measure2
        ,biv_measure3
        ,biv_measure4
        ,biv_measure5
        ,biv_measure6
        ,biv_measure7
        ,biv_measure8
        ,biv_measure9
        ,biv_measure10
        ,biv_measure11
        ,biv_measure12
        ,biv_measure13
        ,biv_measure14
        ,biv_measure15
        ,biv_measure17, ' ||
        l_asset_grp_column ||' BIV_MEASURE20,
        biv_attribute1 ';

/* calculate the rank on the sorting column in the inline view */
l_inner_query := 'from ( select row_number() over(&ORDER_BY_CLAUSE)-1 rnk,iset.*
		  from (select
  nvl(oset05.p_requests,0) BIV_MEASURE1
, nvl(oset05.c_requests,0) BIV_MEASURE2' || '
, ' ||
  isc_maint_rpt_util_pkg.change_column
    ( 'oset05.c_requests'
    , 'oset05.p_requests'
    , 'BIV_MEASURE3' ) || '
, ' ||
  isc_maint_rpt_util_pkg.rate_column
    ( 'oset05.p_response_days'
    , 'oset05.p_requests'
    , 'BIV_MEASURE4' -- prior response days
    , 'N' ) || '
, ' ||
  isc_maint_rpt_util_pkg.rate_column
    ( 'oset05.c_response_days'
    , 'oset05.c_requests'
    , 'BIV_MEASURE5' -- current response days
    , 'N' ) || '
, ' ||
  isc_maint_rpt_util_pkg.change_column
    ( isc_maint_rpt_util_pkg.rate_column
        ( 'oset05.c_response_days'
        , 'oset05.c_requests'
        , null
        , 'N' )
    , isc_maint_rpt_util_pkg.rate_column
        ( 'oset05.p_response_days'
        , 'oset05.p_requests'
        , null
        , 'N' )
    , 'BIV_MEASURE6' -- change response days (as float)
    , 'N' ) || '
, ' ||
  isc_maint_rpt_util_pkg.rate_column
    ( 'oset05.p_completion_days'
    , 'oset05.p_requests'
    , 'BIV_MEASURE7' -- prior completion days
    , 'N' ) || '
, ' ||
  isc_maint_rpt_util_pkg.rate_column
    ( 'oset05.c_completion_days'
    , 'oset05.c_requests'
    , 'BIV_MEASURE8' -- current completion days
    , 'N' ) || '
, ' ||
  isc_maint_rpt_util_pkg.change_column
    ( isc_maint_rpt_util_pkg.rate_column
        ( 'oset05.c_completion_days'
        , 'oset05.c_requests'
        , null
        , 'N' )
    , isc_maint_rpt_util_pkg.rate_column
        ( 'oset05.p_completion_days'
        , 'oset05.p_requests'
        , null
        , 'N' )
    , 'BIV_MEASURE9' -- change completion days (as float)
    , 'N' ) || '
, nvl(oset05.c_requests_total,0) BIV_MEASURE10' || '
, ' ||
  isc_maint_rpt_util_pkg.change_column
    ( 'oset05.c_requests_total'
    , 'oset05.p_requests_total'
    , 'BIV_MEASURE11' ) || '
, ' ||
  isc_maint_rpt_util_pkg.rate_column
    ( 'oset05.c_response_days_total'
    , 'oset05.c_requests_total'
    , 'BIV_MEASURE12' -- grand total current response days
    , 'N' ) || '
, ' ||
  isc_maint_rpt_util_pkg.change_column
    ( isc_maint_rpt_util_pkg.rate_column
        ( 'oset05.c_response_days_total'
        , 'oset05.c_requests_total'
        , null
        , 'N' )
    , isc_maint_rpt_util_pkg.rate_column
        ( 'oset05.p_response_days_total'
        , 'oset05.p_requests_total'
        , null
        , 'N' )
    , 'BIV_MEASURE13' -- grand total change response days (as float)
    , 'N' ) || '
, ' ||
  isc_maint_rpt_util_pkg.rate_column
    ( 'oset05.c_completion_days_total'
    , 'oset05.c_requests_total'
    , 'BIV_MEASURE14' -- grand total current completion days
    , 'N' ) || '
, ' ||
  isc_maint_rpt_util_pkg.change_column
    ( isc_maint_rpt_util_pkg.rate_column
        ( 'oset05.c_completion_days_total'
        , 'oset05.c_requests_total'
        , null
        , 'N' )
    , isc_maint_rpt_util_pkg.rate_column
        ( 'oset05.p_completion_days_total'
        , 'oset05.p_requests_total'
        , null
        , 'N' )
    , 'BIV_MEASURE15' -- grand total change completion days (as float)
    , 'N' ) || '
, ' ||
  isc_maint_rpt_util_pkg.rate_column
    ( 'oset05.p_completion_days_total'
    , 'oset05.p_requests_total'
    , 'BIV_MEASURE17' -- grand total prior completion days
    , 'N' ) ||
    case
      when isc_maint_rpt_util_pkg.get_parameter_value
           ( p_param
           , 'VIEW_BY'
           ) in ( isc_maint_rpt_util_pkg.G_ASSET_GROUP
                , isc_maint_rpt_util_pkg.G_ASSET_NUMBER ) then
        '
, ''pFunctionName=ISC_MAINT_REQ_CMPL_DTL_RPT_REP'' ||
  ''&VIEW_BY_NAME=VIEW_BY_ID'' ||
  ''&pParamIds=Y'' BIV_ATTRIBUTE1, '
      else
        '
, null BIV_ATTRIBUTE1, '
    end  || isc_maint_rpt_util_pkg.get_inner_select_col(l_join_tbl)||' from ';

l_stmt := l_stmt || l_inner_query ||
	 poa_dbi_template_pkg.status_sql
        ( p_fact_name            => l_mv
        , p_where_clause         => l_where_clause
        , p_join_tables          => l_join_tbl
        , p_use_windowing        => 'Y'
        , p_col_name             => l_col_tbl
        , p_use_grpid            => 'N'
        , p_paren_count          => 2
        , p_filter_where         => '1=1)iset'
        , p_generate_viewby      => 'Y'
        );

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  -- l_stmt := l_stmt || isc_maint_rpt_util_pkg.dump_parameters(p_param);
x_custom_output := l_custom_output;
x_custom_sql      := l_stmt;

end get_tbl_sql;

procedure get_trd_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
)
is

  l_dimension_tbl    isc_maint_rpt_util_pkg.t_dimension_tbl;
  l_dim_filter_map   poa_dbi_util_pkg.poa_dbi_dim_map;
  l_custom_output    bis_query_attributes_tbl;
  l_curr_suffix      varchar2(3);
  l_where_clause     varchar2(10000);
  l_viewby_select    varchar2(200);
  l_join_tbl         poa_dbi_util_pkg.poa_dbi_join_tbl;
  l_dim_bmap         number;
  l_comparison_type  varchar2(200);
  l_xtd              varchar2(200);
  l_mv               varchar2(10000);
  l_cost_element     varchar2(200);
  l_estimated        varchar2(200);
  l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_stmt             varchar2(32767);

begin

  isc_maint_rpt_util_pkg.register_dimension_levels
  ( l_dimension_tbl
  , l_dim_filter_map
  , isc_maint_rpt_util_pkg.G_ASSET_GROUP, 'Y'
  , isc_maint_rpt_util_pkg.G_ASSET_NUMBER, 'Y'
  , isc_maint_rpt_util_pkg.G_REQUEST_TYPE, 'Y'
  );

  isc_maint_rpt_util_pkg.process_parameters
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

  l_mv := get_fact_mv_name
          ( 'REQUEST_TO_COMPLETION'
          , p_param
          , l_dim_bmap
          , l_custom_output
          );

  l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'total_requests'
                             , p_alias_name => 'requests'
                             , p_to_date_type => 'XTD'
                             , p_grand_total => 'N'
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'total_response_days'
                             , p_alias_name => 'response_days'
                             , p_to_date_type => 'XTD'
                             , p_grand_total => 'N'
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'total_completion_days'
                             , p_alias_name => 'completion_days'
                             , p_to_date_type => 'XTD'
                             , p_grand_total => 'N'
                             );

  l_stmt := 'select
  cal.name VIEWBY
, nvl(iset.p_requests,0) BIV_MEASURE1
, nvl(iset.c_requests,0) BIV_MEASURE2' || '
, ' ||
  isc_maint_rpt_util_pkg.change_column
    ( 'iset.c_requests'
    , 'iset.p_requests'
    , 'BIV_MEASURE3' ) || '
, ' ||
  isc_maint_rpt_util_pkg.rate_column
    ( 'iset.p_response_days'
    , 'iset.p_requests'
    , 'BIV_MEASURE4' -- prior response days
    , 'N' ) || '
, ' ||
  isc_maint_rpt_util_pkg.rate_column
    ( 'iset.c_response_days'
    , 'iset.c_requests'
    , 'BIV_MEASURE5' -- current response days
    , 'N' ) || '
, ' ||
  isc_maint_rpt_util_pkg.change_column
    ( isc_maint_rpt_util_pkg.rate_column
        ( 'iset.c_response_days'
        , 'iset.c_requests'
        , null
        , 'N' )
    , isc_maint_rpt_util_pkg.rate_column
        ( 'iset.p_response_days'
        , 'iset.p_requests'
        , null
        , 'N' )
    , 'BIV_MEASURE6' -- change response days (as float)
    , 'N' ) || '
, ' ||
  isc_maint_rpt_util_pkg.rate_column
    ( 'iset.p_completion_days'
    , 'iset.p_requests'
    , 'BIV_MEASURE7' -- prior completion days
    , 'N' ) || '
, ' ||
  isc_maint_rpt_util_pkg.rate_column
    ( 'iset.c_completion_days'
    , 'iset.c_requests'
    , 'BIV_MEASURE8' -- current completion days
    , 'N' ) || '
, ' ||
  isc_maint_rpt_util_pkg.change_column
    ( isc_maint_rpt_util_pkg.rate_column
        ( 'iset.c_completion_days'
        , 'iset.c_requests'
        , null
        , 'N' )
    , isc_maint_rpt_util_pkg.rate_column
        ( 'iset.p_completion_days'
        , 'iset.p_requests'
        , null
        , 'N' )
    , 'BIV_MEASURE9' -- change completion days (as float)
    , 'N' ) || '
from
  ' || poa_dbi_template_pkg.trend_sql
        ( p_xtd                  => l_xtd
        , p_comparison_type      => l_comparison_type
        , p_fact_name            => l_mv
        , p_where_clause         => l_where_clause
        , p_col_name             => l_col_tbl
        , p_use_grpid            => 'N'
        );

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  -- l_stmt := l_stmt || isc_maint_rpt_util_pkg.dump_parameters(p_param);

  x_custom_sql      := l_stmt;

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

procedure get_dbn_tbl_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
)
as

  l_dimension_tbl    isc_maint_rpt_util_pkg.t_dimension_tbl;
  l_dim_filter_map   poa_dbi_util_pkg.poa_dbi_dim_map;
  l_custom_output    bis_query_attributes_tbl;
  l_curr_suffix      varchar2(3);
  l_where_clause     varchar2(10000);
  l_viewby_select    varchar2(200);
  l_join_tbl         poa_dbi_util_pkg.poa_dbi_join_tbl;
  l_dim_bmap         number;
  l_comparison_type  varchar2(200);
  l_xtd              varchar2(200);
  l_mv               varchar2(10000);
  l_cost_element     varchar2(200);
  l_estimated        varchar2(200);
  l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_stmt             varchar2(32767);

begin

  isc_maint_rpt_util_pkg.register_dimension_levels
  ( l_dimension_tbl
  , l_dim_filter_map
  , isc_maint_rpt_util_pkg.G_ASSET_GROUP, 'Y'
  , isc_maint_rpt_util_pkg.G_ASSET_NUMBER, 'Y'
  , isc_maint_rpt_util_pkg.G_REQUEST_TYPE, 'Y'
  , isc_maint_rpt_util_pkg.G_REQ_CMPL_AGING, 'Y'
  );

  isc_maint_rpt_util_pkg.process_parameters
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

  l_mv := get_fact_mv_name
          ( 'REQUEST_TO_COMPLETION'
          , p_param
          , l_dim_bmap
          , l_custom_output
          );

  l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'total_requests'
                             , p_alias_name => 'requests'
                             , p_to_date_type => 'XTD'
                             , p_grand_total => 'Y'
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'total_completion_days'
                             , p_alias_name => 'completion_days'
                             , p_to_date_type => 'XTD'
                             , p_grand_total => 'Y'
                             );


  l_stmt := 'select
  ' || l_viewby_select || '
, nvl(oset.p_requests,0) BIV_MEASURE1 /* prior requests */
, nvl(oset.c_requests,0) BIV_MEASURE2 /* current requests */' || '
, ' ||
  isc_maint_rpt_util_pkg.change_column
    ( 'oset.c_requests'
    , 'oset.p_requests'
    , 'BIV_MEASURE3' ) || ' /* change requests */
, ' ||
  isc_maint_rpt_util_pkg.rate_column
    ( 'oset.c_requests'
    , 'avg(oset.c_requests_total) over()'
    , 'BIV_MEASURE4'
    , 'Y' ) || ' /* percent of total */
, nvl(avg(oset.c_requests_total) over(),0) BIV_MEASURE5 /* grand total current requests */' || '
, ' ||
  isc_maint_rpt_util_pkg.change_column
    ( 'avg(oset.c_requests_total) over()'
    , 'avg(oset.p_requests_total) over()'
    , 'BIV_MEASURE6' ) || ' /* grand total change requests */
, ' ||
  isc_maint_rpt_util_pkg.change_column
    ( 'avg(oset.c_requests_total) over()'
    , 'avg(oset.c_requests_total) over()'
    , 'BIV_MEASURE7' ) || ' /* grand total current percent of total */
, ''pFunctionName=ISC_MAINT_REQ_CMPL_DTL_RPT_REP'' ||
  ''&VIEW_BY_NAME=VIEW_BY_ID'' ||
  ''&pParamIds=Y'' BIV_ATTRIBUTE1
, null BIV_ATTRIBUTE2' -- this is needed for bucket to region association
|| '
from
( select * from ( ' || poa_dbi_template_pkg.status_sql
        ( p_fact_name            => l_mv
        , p_where_clause         => l_where_clause
        , p_join_tables          => l_join_tbl
        , p_use_windowing        => 'N'
        , p_col_name             => l_col_tbl
        , p_use_grpid            => 'N'
        , p_paren_count          => 3
        , p_filter_where         => null
        , p_generate_viewby      => 'Y'
        );

  l_stmt := replace( l_stmt
                   , '&ORDER_BY_CLAUSE'
                   , 'ORDER BY VIEWBYID'
                   );

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  -- l_stmt := l_stmt || isc_maint_rpt_util_pkg.dump_parameters(p_param);

  x_custom_sql      := l_stmt;

  x_custom_output := l_custom_output;

end get_dbn_tbl_sql;

procedure get_dtl_rpt_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
)
as

  l_dimension_tbl    isc_maint_rpt_util_pkg.t_dimension_tbl;
  l_dim_filter_map   poa_dbi_util_pkg.poa_dbi_dim_map;
  l_custom_output    bis_query_attributes_tbl;
  l_curr_suffix      varchar2(3);
  l_where_clause     varchar2(10000);
  l_viewby_select    varchar2(200);
  l_join_tbl         poa_dbi_util_pkg.poa_dbi_join_tbl;
  l_dim_bmap         number;
  l_comparison_type  varchar2(200);
  l_xtd              varchar2(200);
  l_mv               varchar2(10000);
  l_cost_element     varchar2(200);
  l_estimated        varchar2(200);
  l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_stmt             varchar2(32767);
  l_rank_order       varchar2(200);
  l_detail_col_tbl isc_maint_rpt_util_pkg.t_detail_column_tbl;
  l_order_by         varchar2(200);
  l_asc_desc         varchar2(100);

begin

  isc_maint_rpt_util_pkg.register_dimension_levels
  ( l_dimension_tbl
  , l_dim_filter_map
  , isc_maint_rpt_util_pkg.G_ASSET_GROUP, 'Y'
  , isc_maint_rpt_util_pkg.G_ASSET_NUMBER, 'Y'
  , isc_maint_rpt_util_pkg.G_REQUEST_TYPE, 'Y'
  , isc_maint_rpt_util_pkg.G_REQ_CMPL_AGING, 'Y'
  , isc_maint_rpt_util_pkg.G_REQUESTS, 'N'
  , isc_maint_rpt_util_pkg.G_REQUEST_SEVERITIES, 'N'
  );

  isc_maint_rpt_util_pkg.process_parameters
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
          ( 'REQUEST_TO_COMPLETION_DTL'
          , p_param
          , l_dim_bmap
          , l_custom_output
          );

  l_order_by := isc_maint_rpt_util_pkg.get_parameter_value
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
                    when l_order_by like '%BIV_MEASURE1%' then
                      'request_start_date'
                    when l_order_by like '%BIV_MEASURE2%' then
                      'response_days'
                    else --  l_order_by like '%BIV_MEASURE3%' then
                      'completion_days'
                  end ||
                  l_asc_desc ||
                  'nulls last, organization_id, request_type, maint_request_id';

  isc_maint_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'request_number'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'request_number'
  );

  isc_maint_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_dimension_level    => isc_maint_rpt_util_pkg.G_REQUESTS
  , p_dim_level_col_name => 'description'
  , p_column_key         => 'description'
  );

  isc_maint_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_dimension_level    => isc_maint_rpt_util_pkg.G_REQUEST_TYPE
  , p_column_key         => 'request_type'
  );

  isc_maint_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'work_order_count'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'work_order_count'
  );

  isc_maint_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_dimension_level    => isc_maint_rpt_util_pkg.G_ASSET_NUMBER
  , p_column_key         => 'asset_number'
  );

  isc_maint_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_dimension_level    => isc_maint_rpt_util_pkg.G_ASSET_GROUP
  , p_column_key         => 'asset_group'
  );

  isc_maint_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_dimension_level    => isc_maint_rpt_util_pkg.G_DEPARTMENT
  , p_column_key         => 'department'
  );

  isc_maint_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_dimension_level    => isc_maint_rpt_util_pkg.G_REQUEST_SEVERITIES
  , p_dim_level_col_name => 'name'
  , p_column_key         => 'request_severity'
  );

  isc_maint_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'request_start_date'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'request_start_date'
  );


  isc_maint_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'response_days'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'response_days'
  );

  isc_maint_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'completion_days'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'completion_days'
  );

  l_stmt := 'select
  oset.request_number BIV_ATTRIBUTE1
, ' || isc_maint_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'description','BIV_ATTRIBUTE2') || '
, ' || isc_maint_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'request_type','BIV_ATTRIBUTE3') || '
, oset.work_order_count BIV_ATTRIBUTE4'  || '
, ' || isc_maint_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'asset_number','BIV_ATTRIBUTE5') || '
, ' || isc_maint_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'asset_group','BIV_ATTRIBUTE6') || '
, ' || isc_maint_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'department','BIV_ATTRIBUTE7') || '
, ' || isc_maint_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'request_severity','BIV_ATTRIBUTE8') || '
, oset.request_start_date BIV_MEASURE1
, oset.response_days BIV_MEASURE2
, oset.completion_days BIV_MEASURE3
, ''pFunctionName=ISC_MAINT_REQ_WO_DTL_RPT_REP'' || ' ||
  '''&pParamIds=Y'' || ' ||
  '''&ORGANIZAT_D1='' || oset.organization_id ||' ||
  '''&ENI_RESOURCE_DEPARTMENT=''  || decode(oset.department_id,-1,''-1'',oset.department_id||''-1'') ||' ||
  '''&BIV_MAINT_ASSET_GROUP_LVL='' || decode(oset.asset_group_id,-1,''-1'',oset.asset_group_id) ||' ||
  '''&BIV_MAINT_ASSET_NUMBER_LVL='' || decode(oset.instance_id,-1,-1,oset.instance_id) ||' ||
  '''&BIV_MAINT_REQUEST_TYPE_LVL='' || oset.request_type ||' ||
  '''&BIV_ATTRIBUTE9='' || oset.maint_request_id || ' ||
  '''&BIV_ATTRIBUTE6='' || oset.request_number || ' ||
  '''&BIV_ATTRIBUTE8='' || to_char(oset.request_start_date,fnd_profile.value(''ICX_DATE_FORMAT_MASK'')) || ' ||
  '''&BIV_ATTRIBUTE7='' || ' || isc_maint_rpt_util_pkg.get_detail_column
                                (l_detail_col_tbl,'request_severity',null) || ' || ' ||
  '''''  BIV_ATTRIBUTE9
, null BIV_ATTRIBUTE10' -- this is needed for bucket to AK region association
|| '
from
' || isc_maint_rpt_util_pkg.detail_sql
     ( p_detail_col_tbl => l_detail_col_tbl
     , p_dimension_tbl  => l_dimension_tbl
     , p_mv_name        => l_mv
     , p_where_clause   => l_where_clause
     , p_rank_order     => l_rank_order
     );

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  --l_stmt := l_stmt || isc_maint_rpt_util_pkg.dump_parameters(p_param);

  x_custom_sql      := l_stmt;

  x_custom_output := l_custom_output;

end get_dtl_rpt_sql;

procedure get_wo_dtl_rpt_sql
( p_param           in bis_pmv_page_parameter_tbl
, x_custom_sql      out nocopy varchar2
, x_custom_output   out nocopy bis_query_attributes_tbl
)
as

  l_dimension_tbl    isc_maint_rpt_util_pkg.t_dimension_tbl;
  l_dim_filter_map   poa_dbi_util_pkg.poa_dbi_dim_map;
  l_custom_output    bis_query_attributes_tbl;
  l_curr_suffix      varchar2(3);
  l_where_clause     varchar2(10000);
  l_viewby_select    varchar2(200);
  l_join_tbl         poa_dbi_util_pkg.poa_dbi_join_tbl;
  l_dim_bmap         number;
  l_comparison_type  varchar2(200);
  l_xtd              varchar2(200);
  l_mv               varchar2(10000);
  l_cost_element     varchar2(200);
  l_estimated        varchar2(200);
  l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_stmt             varchar2(32767);
  l_rank_order       varchar2(200);
  l_detail_col_tbl isc_maint_rpt_util_pkg.t_detail_column_tbl;

begin

  isc_maint_rpt_util_pkg.register_dimension_levels
  ( l_dimension_tbl
  , l_dim_filter_map
  , isc_maint_rpt_util_pkg.G_ORGANIZATION, 'Y'
  , isc_maint_rpt_util_pkg.G_DEPARTMENT, 'N'
  , isc_maint_rpt_util_pkg.G_REQUEST_TYPE, 'Y'
  , isc_maint_rpt_util_pkg.G_WORK_ORDER_TYPE, 'N'
  , isc_maint_rpt_util_pkg.G_ACTIVITY, 'N'
  , isc_maint_rpt_util_pkg.G_WORK_ORDER_STATUS, 'N'
  );

  isc_maint_rpt_util_pkg.process_parameters
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
          ( 'REQUESTED_WORK_ORDER'
          , p_param
          , l_dim_bmap
          , l_custom_output
          );

  isc_maint_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'work_order_id'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'work_order_id'
  );

  isc_maint_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'work_order_name'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'work_order_name'
  );

  isc_maint_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_dimension_level    => isc_maint_rpt_util_pkg.G_WORK_ORDER_TYPE
  , p_column_key         => 'work_order_type'
  );

  isc_maint_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_dimension_level    => isc_maint_rpt_util_pkg.G_ACTIVITY
  , p_column_key         => 'activity'
  );

  isc_maint_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_dimension_level    => isc_maint_rpt_util_pkg.G_WORK_ORDER_STATUS
  , p_column_key         => 'work_order_status'
  );

  isc_maint_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'scheduled_start_date'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'scheduled_start_date'
  );

  isc_maint_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'scheduled_completion_date'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'scheduled_completion_date'
  );

  isc_maint_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'completion_date'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'completion_date'
  );

  l_stmt := 'select
  oset.work_order_name BIV_ATTRIBUTE1
, ' || isc_maint_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'work_order_type','BIV_ATTRIBUTE2') || '
, ' || isc_maint_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'activity','BIV_ATTRIBUTE3') || '
, ' || isc_maint_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'work_order_status','BIV_ATTRIBUTE4') || '
, oset.scheduled_start_date BIV_MEASURE1
, oset.scheduled_completion_date BIV_MEASURE2
, oset.completion_date BIV_MEASURE3
, ' ||
  isc_maint_rpt_util_pkg.get_drill_detail('BIV_ATTRIBUTE5') || '
from
' || isc_maint_rpt_util_pkg.detail_sql
     ( p_detail_col_tbl => l_detail_col_tbl
     , p_dimension_tbl  => l_dimension_tbl
     , p_mv_name        => l_mv
     , p_where_clause   => l_where_clause
     , p_rank_order     => null
     );

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  -- l_stmt := l_stmt || isc_maint_rpt_util_pkg.dump_parameters(p_param);

  x_custom_sql      := l_stmt;

  bind_request_id( l_custom_output, p_param );

  x_custom_output := l_custom_output;

end get_wo_dtl_rpt_sql;

end isc_maint_req_cmpl_rpt_pkg;

/
