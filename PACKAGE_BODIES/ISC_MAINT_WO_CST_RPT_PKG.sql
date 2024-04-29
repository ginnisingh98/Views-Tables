--------------------------------------------------------
--  DDL for Package Body ISC_MAINT_WO_CST_RPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_MAINT_WO_CST_RPT_PKG" 
/* $Header: iscmaintwocstrpb.pls 120.2 2005/11/16 20:36:32 nbhamidi noship $ */
as

  g_summary_rep_func  constant varchar2(50) := 'ISC_MAINT_WO_CST_SUM_TBL_REP';

function get_fact_mv_name
( p_report_type   in varchar2
, p_param         in bis_pmv_page_parameter_tbl
, p_dim_bmap      in number
, p_custom_output in out nocopy bis_query_attributes_tbl
, p_estimated     in varchar2
)
return varchar2
is

  l_org_id varchar2(200);
  l_view_by varchar2(200);

begin

  l_org_id := isc_maint_rpt_util_pkg.get_parameter_id
              ( p_param
              , isc_maint_rpt_util_pkg.G_ORGANIZATION
              );

  if p_report_type = 'WORK_ORDER_COST' then

    l_view_by := isc_maint_rpt_util_pkg.get_parameter_value
                 ( p_param
                 , 'VIEW_BY'
                 );

    isc_maint_rpt_util_pkg.bind_group_id
    ( p_dim_bmap
    , p_custom_output
    , isc_maint_rpt_util_pkg.G_ASSET_GROUP
    , isc_maint_rpt_util_pkg.G_ASSET_NUMBER
    , isc_maint_rpt_util_pkg.G_ACTIVITY
    );

    return '(
    select
      time_id
    , period_type_id
    , grp_id
    , ' ||
      case l_view_by
        when isc_maint_rpt_util_pkg.G_DEPARTMENT then
          'decode(department_id,-1,-1,organization_id) organization_id'
        when isc_maint_rpt_util_pkg.G_ASSET_GROUP then
          'decode(asset_group_id,-1,-1,organization_id) organization_id'
        when isc_maint_rpt_util_pkg.G_ASSET_NUMBER then /* replaced asset_number with instance_id */
          'decode(instance_id,-1,-1,organization_id) organization_id'
        when isc_maint_rpt_util_pkg.G_ACTIVITY then
          'decode(activity_id,-1,-1,organization_id) organization_id'
        when isc_maint_rpt_util_pkg.G_COST_CATEGORY then
          'decode(maint_cost_category,-1,-1,organization_id) organization_id'
        else
          'organization_id'
      end ||'
    , ' ||
      case l_view_by
        when isc_maint_rpt_util_pkg.G_ASSET_NUMBER then
          'decode(instance_id,-1,-1,asset_group_id) asset_group_id' /* replaced asset_number with instance_id */
        else
          'asset_group_id'
      end || '
    , instance_id /* replaced asset_number with instance_id */
    , activity_id
    , to_char(department_id) department_id
    , maint_cost_category
    , organization_id organization_id_c
    , asset_group_id	asset_group_id_c /* removed concatenation to org. to make it independent of org. */
    , decode(instance_id,-1,-1,instance_id) instance_id_c /* replaced asset_number with instance_id */
    , decode(activity_id,-1,''-1'',activity_id||''-''||organization_id) activity_id_c
    , department_id||''-1'' department_id_c
    , ' ||
    case
      when p_estimated = 'NONZERO' then
     'e_actual_mat_cost_b actual_mat_cost_b
    , e_actual_lab_cost_b actual_lab_cost_b
    , e_actual_eqp_cost_b actual_eqp_cost_b
    , e_actual_mat_cost_b + e_actual_lab_cost_b + e_actual_eqp_cost_b actual_tot_cost_b
    , e_actual_mat_cost_g actual_mat_cost_g
    , e_actual_lab_cost_g actual_lab_cost_g
    , e_actual_eqp_cost_g actual_eqp_cost_g
    , e_actual_mat_cost_g + e_actual_lab_cost_g + e_actual_eqp_cost_g actual_tot_cost_g
    , e_actual_mat_cost_sg actual_mat_cost_sg
    , e_actual_lab_cost_sg actual_lab_cost_sg
    , e_actual_eqp_cost_sg actual_eqp_cost_sg
    , e_actual_mat_cost_sg + e_actual_lab_cost_sg + e_actual_eqp_cost_sg actual_tot_cost_sg'
      when p_estimated = 'ZERO' then
     'ne_actual_mat_cost_b actual_mat_cost_b
    , ne_actual_lab_cost_b actual_lab_cost_b
    , ne_actual_eqp_cost_b actual_eqp_cost_b
    , ne_actual_mat_cost_b + ne_actual_lab_cost_b + ne_actual_eqp_cost_b actual_tot_cost_b
    , ne_actual_mat_cost_g actual_mat_cost_g
    , ne_actual_lab_cost_g actual_lab_cost_g
    , ne_actual_eqp_cost_g actual_eqp_cost_g
    , ne_actual_mat_cost_g + ne_actual_lab_cost_g + ne_actual_eqp_cost_g actual_tot_cost_g
    , ne_actual_mat_cost_sg actual_mat_cost_sg
    , ne_actual_lab_cost_sg actual_lab_cost_sg
    , ne_actual_eqp_cost_sg actual_eqp_cost_sg
    , ne_actual_mat_cost_sg + ne_actual_lab_cost_sg + ne_actual_eqp_cost_sg actual_tot_cost_sg'
      else
     'e_actual_mat_cost_b + ne_actual_mat_cost_b actual_mat_cost_b
    , e_actual_lab_cost_b + ne_actual_lab_cost_b actual_lab_cost_b
    , e_actual_eqp_cost_b + ne_actual_eqp_cost_b actual_eqp_cost_b
    , e_actual_mat_cost_b + e_actual_lab_cost_b + e_actual_eqp_cost_b
      + ne_actual_mat_cost_b + ne_actual_lab_cost_b + ne_actual_eqp_cost_b actual_tot_cost_b
    , e_actual_mat_cost_g + ne_actual_mat_cost_g actual_mat_cost_g
    , e_actual_lab_cost_g + ne_actual_lab_cost_g actual_lab_cost_g
    , e_actual_eqp_cost_g + ne_actual_eqp_cost_g actual_eqp_cost_g
    , e_actual_mat_cost_g + e_actual_lab_cost_g + e_actual_eqp_cost_g
      + ne_actual_mat_cost_g + ne_actual_lab_cost_g + ne_actual_eqp_cost_g actual_tot_cost_g
    , e_actual_mat_cost_sg + ne_actual_mat_cost_sg actual_mat_cost_sg
    , e_actual_lab_cost_sg + ne_actual_lab_cost_sg actual_lab_cost_sg
    , e_actual_eqp_cost_sg + ne_actual_eqp_cost_sg actual_eqp_cost_sg
    , e_actual_mat_cost_sg + e_actual_lab_cost_sg + e_actual_eqp_cost_sg
      + ne_actual_mat_cost_sg + ne_actual_lab_cost_sg + ne_actual_eqp_cost_sg actual_tot_cost_sg
    '
    end || '
    , ' ||
    case
      when p_estimated = 'ZERO' then
     '0 estimated_mat_cost_b
    , 0 estimated_lab_cost_b
    , 0 estimated_eqp_cost_b
    , 0 estimated_tot_cost_b
    , 0 estimated_mat_cost_g
    , 0 estimated_lab_cost_g
    , 0 estimated_eqp_cost_g
    , 0 estimated_tot_cost_g
    , 0 estimated_mat_cost_sg
    , 0 estimated_lab_cost_sg
    , 0 estimated_eqp_cost_sg
    , 0 estimated_tot_cost_sg '
      else
    ' estimated_mat_cost_b
    , estimated_lab_cost_b
    , estimated_eqp_cost_b
    , estimated_mat_cost_b + estimated_lab_cost_b + estimated_eqp_cost_b estimated_tot_cost_b
    , estimated_mat_cost_g
    , estimated_lab_cost_g
    , estimated_eqp_cost_g
    , estimated_mat_cost_g + estimated_lab_cost_g + estimated_eqp_cost_g estimated_tot_cost_g
    , estimated_mat_cost_sg
    , estimated_lab_cost_sg
    , estimated_eqp_cost_sg
    , estimated_mat_cost_sg + estimated_lab_cost_sg + estimated_eqp_cost_sg estimated_tot_cost_sg'
    end || '
    , ' ||
    case
      when p_estimated = 'NONZERO' then
     'estimated_mat_cost_b - e_actual_mat_cost_b variance_mat_cost_b
    , estimated_lab_cost_b - e_actual_lab_cost_b variance_lab_cost_b
    , estimated_eqp_cost_b - e_actual_eqp_cost_b variance_eqp_cost_b
    , (estimated_mat_cost_b + estimated_lab_cost_b + estimated_eqp_cost_b)
      - ( e_actual_mat_cost_b + e_actual_lab_cost_b + e_actual_eqp_cost_b) variance_tot_cost_b
    , estimated_mat_cost_g - e_actual_mat_cost_g variance_mat_cost_g
    , estimated_lab_cost_g - e_actual_lab_cost_g variance_lab_cost_g
    , estimated_eqp_cost_g - e_actual_eqp_cost_g variance_eqp_cost_g
    , (estimated_mat_cost_g + estimated_lab_cost_g + estimated_eqp_cost_g)
      - ( e_actual_mat_cost_g + e_actual_lab_cost_g + e_actual_eqp_cost_g) variance_tot_cost_g
    , estimated_mat_cost_sg - e_actual_mat_cost_sg variance_mat_cost_sg
    , estimated_lab_cost_sg - e_actual_lab_cost_sg variance_lab_cost_sg
    , estimated_eqp_cost_sg - e_actual_eqp_cost_sg variance_eqp_cost_sg
    , (estimated_mat_cost_sg + estimated_lab_cost_sg + estimated_eqp_cost_sg)
      - ( e_actual_mat_cost_sg + e_actual_lab_cost_sg + e_actual_eqp_cost_sg) variance_tot_cost_sg'
      when p_estimated = 'ZERO' then
     '0 - ne_actual_mat_cost_b variance_mat_cost_b
    , 0 - ne_actual_lab_cost_b variance_lab_cost_b
    , 0 - ne_actual_eqp_cost_b variance_eqp_cost_b
    , 0
      - ( ne_actual_mat_cost_b + ne_actual_lab_cost_b + ne_actual_eqp_cost_b) variance_tot_cost_b
    , 0 - ne_actual_mat_cost_g variance_mat_cost_g
    , 0 - ne_actual_lab_cost_g variance_lab_cost_g
    , 0 - ne_actual_eqp_cost_g variance_eqp_cost_g
    , 0
      - ( ne_actual_mat_cost_g + ne_actual_lab_cost_g + ne_actual_eqp_cost_g) variance_tot_cost_g
    , 0 - ne_actual_mat_cost_sg variance_mat_cost_sg
    , 0 - ne_actual_lab_cost_sg variance_lab_cost_sg
    , 0 - ne_actual_eqp_cost_sg variance_eqp_cost_sg
    , 0
      - ( ne_actual_mat_cost_sg + ne_actual_lab_cost_sg + ne_actual_eqp_cost_sg) variance_tot_cost_sg'
      else
     'estimated_mat_cost_b - (e_actual_mat_cost_b + ne_actual_mat_cost_b) variance_mat_cost_b
    , estimated_lab_cost_b - (e_actual_lab_cost_b + ne_actual_lab_cost_b) variance_lab_cost_b
    , estimated_eqp_cost_b - (e_actual_eqp_cost_b + ne_actual_eqp_cost_b) variance_eqp_cost_b
    , (estimated_mat_cost_b + estimated_lab_cost_b + estimated_eqp_cost_b)
      - (e_actual_mat_cost_b + e_actual_lab_cost_b + e_actual_eqp_cost_b
         + ne_actual_mat_cost_b + ne_actual_lab_cost_b + ne_actual_eqp_cost_b) variance_tot_cost_b
    , estimated_mat_cost_g - (e_actual_mat_cost_g + ne_actual_mat_cost_g) variance_mat_cost_g
    , estimated_lab_cost_g - (e_actual_lab_cost_g + ne_actual_lab_cost_g) variance_lab_cost_g
    , estimated_eqp_cost_g - (e_actual_eqp_cost_g + ne_actual_eqp_cost_g) variance_eqp_cost_g
    , (estimated_mat_cost_g + estimated_lab_cost_g + estimated_eqp_cost_g)
      - (e_actual_mat_cost_g + e_actual_lab_cost_g + e_actual_eqp_cost_g
         + ne_actual_mat_cost_g + ne_actual_lab_cost_g + ne_actual_eqp_cost_g) variance_tot_cost_g
    , estimated_mat_cost_sg - (e_actual_mat_cost_sg + ne_actual_mat_cost_sg) variance_mat_cost_sg
    , estimated_lab_cost_sg - (e_actual_lab_cost_sg + ne_actual_lab_cost_sg) variance_lab_cost_sg
    , estimated_eqp_cost_sg - (e_actual_eqp_cost_sg + ne_actual_eqp_cost_sg) variance_eqp_cost_sg
    , (estimated_mat_cost_sg + estimated_lab_cost_sg + estimated_eqp_cost_sg)
      - (e_actual_mat_cost_sg + e_actual_lab_cost_sg + e_actual_eqp_cost_sg
         + ne_actual_mat_cost_sg + ne_actual_lab_cost_sg + ne_actual_eqp_cost_sg) variance_tot_cost_sg'
      end || '
    from isc_maint_005_mv fact
    where fact.grp_id = &ISC_GRP_ID' ||
    case
      when l_org_id is null then
        '
    and ' || isc_maint_rpt_util_pkg.get_sec_where_clause( 'fact', l_org_id )
    end || '
)';

  else
    return '(
    select
      f.completion_date report_date
    , f.organization_id
    , f.work_order_id
    , wo.work_order_name
    , wo.description
    , wo.asset_group_id asset_group_id
    , nvl(wo.instance_id,-1) instance_id	/* replaced asset_number with instance_id */
    , nvl(wo.activity_id,-1) activity_id
    , to_char(f.department_id) department_id
    , f.maint_cost_category
    , f.estimated_flag
    , f.organization_id organization_id_c
    , wo.asset_group_id asset_group_id_c
    , decode(wo.instance_id,-1,-1,wo.instance_id) instance_id_c /* replaced asset_number with instance_id */
    , decode(wo.activity_id,-1,''-1'',wo.activity_id||''-''||f.organization_id) activity_id_c
    , f.department_id||''-1'' department_id_c
    , nvl(wo.work_order_type,-1) work_order_type
    , to_char(nvl(wo.status_type,-1)) status_type
    , actual_mat_cost_b
    , actual_lab_cost_b
    , actual_eqp_cost_b
    , actual_mat_cost_b + actual_lab_cost_b + actual_eqp_cost_b actual_tot_cost_b
    , estimated_mat_cost_b + estimated_lab_cost_b + estimated_eqp_cost_b estimated_tot_cost_b
    , (estimated_mat_cost_b + estimated_lab_cost_b + estimated_eqp_cost_b)
      -(actual_mat_cost_b + actual_lab_cost_b + actual_eqp_cost_b) variance_tot_cost_b
    , actual_mat_cost_b * conversion_rate1 actual_mat_cost_g
    , actual_lab_cost_b * conversion_rate1 actual_lab_cost_g
    , actual_eqp_cost_b * conversion_rate1 actual_eqp_cost_g
    , (actual_mat_cost_b + actual_lab_cost_b + actual_eqp_cost_b) * conversion_rate1 actual_tot_cost_g
    , (estimated_mat_cost_b + estimated_lab_cost_b + estimated_eqp_cost_b) * conversion_rate1 estimated_tot_cost_g
    , ((estimated_mat_cost_b + estimated_lab_cost_b + estimated_eqp_cost_b)
       -(actual_mat_cost_b + actual_lab_cost_b + actual_eqp_cost_b)) * conversion_rate1 variance_tot_cost_g
    , actual_mat_cost_b * conversion_rate2 actual_mat_cost_sg
    , actual_lab_cost_b * conversion_rate2 actual_lab_cost_sg
    , actual_eqp_cost_b * conversion_rate2 actual_eqp_cost_sg
    , (actual_mat_cost_b + actual_lab_cost_b + actual_eqp_cost_b) * conversion_rate2 actual_tot_cost_sg
    , (estimated_mat_cost_b + estimated_lab_cost_b + estimated_eqp_cost_b) * conversion_rate2 estimated_tot_cost_sg
    , ((estimated_mat_cost_b + estimated_lab_cost_b + estimated_eqp_cost_b)
       -(actual_mat_cost_b + actual_lab_cost_b + actual_eqp_cost_b)) * conversion_rate2 variance_tot_cost_sg
    , status.value status_name
    from
      isc_maint_wo_cst_sum_f f
    , isc_maint_work_orders_f wo
    , biv_maint_wo_status_lvl_v status
    where f.work_order_id = wo.work_order_id
    and f.organization_id = wo.organization_id
    and wo.user_defined_status_id = status.id
    and (actual_mat_cost_b <> 0 or actual_lab_cost_b <> 0 or actual_eqp_cost_b <> 0 or
         estimated_mat_cost_b + estimated_lab_cost_b + estimated_eqp_cost_b <> 0)' ||
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
  l_cost_element     varchar2(200);
  l_estimated        varchar2(200);
  l_col_tbl          poa_dbi_util_pkg.poa_dbi_col_tbl;
  l_stmt             varchar2(32767);
  l_asset_grp_column varchar2(200);
  l_inner_query	     varchar2(5000);
begin

  isc_maint_rpt_util_pkg.register_dimension_levels
  ( l_dimension_tbl
  , l_dim_filter_map
  , isc_maint_rpt_util_pkg.G_ASSET_GROUP, 'Y'
  , isc_maint_rpt_util_pkg.G_ASSET_NUMBER, 'Y'
  , isc_maint_rpt_util_pkg.G_ACTIVITY, 'Y'
  , isc_maint_rpt_util_pkg.G_COST_CATEGORY, 'Y'
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

  l_estimated := isc_maint_rpt_util_pkg.get_parameter_id
                 ( p_param
                 , isc_maint_rpt_util_pkg.G_ESTIMATED
                 );

  l_mv := get_fact_mv_name
          ( 'WORK_ORDER_COST'
          , p_param
          , l_dim_bmap
          , l_custom_output
          , l_estimated
          );

  l_cost_element := isc_maint_rpt_util_pkg.get_parameter_id
                   ( p_param
                   , isc_maint_rpt_util_pkg.G_COST_ELEMENT
                   );

  if l_cost_element = '1' then
    l_cost_element := 'eqp';
  elsif l_cost_element = '2' then
    l_cost_element := 'lab';
  elsif l_cost_element = '3' then
    l_cost_element := 'mat';
  else
    l_cost_element := 'tot';
  end if;

  l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'estimated_' || l_cost_element || '_cost_' || l_curr_suffix
                             , p_alias_name => 'estimated_cost'
                             , p_to_date_type => 'XTD'
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'actual_' || l_cost_element || '_cost_' || l_curr_suffix
                             , p_alias_name => 'actual_cost'
                             , p_to_date_type => 'XTD'
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'variance_' || l_cost_element || '_cost_' || l_curr_suffix
                             , p_alias_name => 'variance_cost'
                             , p_to_date_type => 'XTD'
                             );

/* if view by is asset number add the asset_group column */

if(isc_maint_rpt_util_pkg.get_parameter_id(p_param,'VIEW_BY')) =
isc_maint_rpt_util_pkg.G_ASSET_NUMBER then
        l_asset_grp_column := isc_maint_rpt_util_pkg.add_asset_group_column(isc_maint_rpt_util_pkg.G_ASSET_NUMBER,l_dimension_tbl);
else
        l_asset_grp_column :='NULL';
end if ;


/* to enable windowing we are using an addition inline view */

 l_stmt := ' select ' || l_viewby_select ||
 ', biv_measure1
 , biv_measure2
 , biv_measure3
 , biv_measure4
 , biv_measure5
 , biv_measure6
 , biv_measure7
 , biv_measure8
 , biv_measure9
 , biv_measure10
 ,biv_measure11
 , biv_measure12
 , biv_measure13
 , biv_measure14
 , biv_measure15
 , biv_measure16
 , biv_measure17
 , biv_measure18
 , biv_measure19
 , biv_measure20
 , biv_measure22 ,
 ' || l_asset_grp_column ||' BIV_MEASURE23 , biv_attribute1  ';

/* calculate the rank on the sorting column in the inline view */

l_inner_query := 'from ( select row_number() over(&ORDER_BY_CLAUSE)-1 rnk,iset.*
		  from (select '||
' nvl(oset05.p_estimated_cost,0) BIV_MEASURE1
, nvl(oset05.c_estimated_cost,0) BIV_MEASURE2' || '
, ' ||
  isc_maint_rpt_util_pkg.change_column
    ( 'oset05.c_estimated_cost'
    , 'oset05.p_estimated_cost'
    , 'BIV_MEASURE3' ) || '
, nvl(oset05.p_actual_cost,0) BIV_MEASURE4
, nvl(oset05.c_actual_cost,0) BIV_MEASURE5' || '
, ' ||
  isc_maint_rpt_util_pkg.change_column
    ( 'oset05.c_actual_cost'
    , 'oset05.p_actual_cost'
    , 'BIV_MEASURE6' ) || '
, nvl(oset05.p_variance_cost,0) BIV_MEASURE7
, nvl(oset05.c_variance_cost,0) BIV_MEASURE8' || '
, ' ||
  isc_maint_rpt_util_pkg.change_column
    ( 'oset05.c_variance_cost'
    , 'oset05.p_variance_cost'
    , 'BIV_MEASURE9' ) || '
, ' ||
  isc_maint_rpt_util_pkg.rate_column
    ( 'oset05.p_variance_cost'
    , 'oset05.p_estimated_cost'
    , 'BIV_MEASURE10' -- prior variance percent
    , 'Y' ) || '
, ' ||
  isc_maint_rpt_util_pkg.rate_column
    ( 'oset05.c_variance_cost'
    , 'oset05.c_estimated_cost'
    , 'BIV_MEASURE11' -- current variance percent
    , 'Y' ) || '
, ' ||
  isc_maint_rpt_util_pkg.change_column
    ( isc_maint_rpt_util_pkg.rate_column
        ( 'oset05.c_variance_cost'
        , 'oset05.c_estimated_cost'
        , null
        , 'Y' )
    , isc_maint_rpt_util_pkg.rate_column
        ( 'oset05.p_variance_cost'
        , 'oset05.p_estimated_cost'
        , null
        , 'Y' )
    , 'BIV_MEASURE12' -- change variance percent (as float)
    , 'N' ) || '
, nvl(oset05.c_estimated_cost_total,0) BIV_MEASURE13' || '
, ' ||
  isc_maint_rpt_util_pkg.change_column
    ( 'oset05.c_estimated_cost_total'
    , 'oset05.p_estimated_cost_total'
    , 'BIV_MEASURE14' ) || '
, nvl(oset05.c_actual_cost_total,0) BIV_MEASURE15' || '
, ' ||
  isc_maint_rpt_util_pkg.change_column
    ( 'oset05.c_actual_cost_total'
    , 'oset05.p_actual_cost_total'
    , 'BIV_MEASURE16' ) || '
, nvl(oset05.c_variance_cost_total,0) BIV_MEASURE17' || '
, ' ||
  isc_maint_rpt_util_pkg.change_column
    ( 'oset05.c_variance_cost_total'
    , 'oset05.p_variance_cost_total'
    , 'BIV_MEASURE18' ) || '
, ' ||
  isc_maint_rpt_util_pkg.rate_column
    ( 'oset05.c_variance_cost_total'
    , 'oset05.c_estimated_cost_total'
    , 'BIV_MEASURE19'
    , 'Y' ) || '
, ' ||
  isc_maint_rpt_util_pkg.change_column
    ( isc_maint_rpt_util_pkg.rate_column
      ( 'oset05.c_variance_cost_total'
      , 'oset05.c_estimated_cost_total'
      , null
      , 'Y'
      )
    , isc_maint_rpt_util_pkg.rate_column
      ( 'oset05.p_variance_cost_total'
      , 'oset05.p_estimated_cost_total'
      , null
      , 'Y'
      )
    , 'BIV_MEASURE20'
    , 'N' ) --|| '
--, ' ||
--  isc_maint_rpt_util_pkg.change_column
--    ( isc_maint_rpt_util_pkg.rate_column
--        ( 'oset05.c_variance_cost_total'
--        , 'oset05.c_estimated_cost_total'
--        , ''
--        , 'Y' )
--    , isc_maint_rpt_util_pkg.rate_column
--        ( 'oset05.p_variance_cost_total'
--        , 'oset05.p_estimated_cost_total'
--        , ''
--        , 'Y' )
--    , 'BIV_MEASURE21'
--    , 'N' ) || '
            || '
, nvl(oset05.p_actual_cost_total,0) BIV_MEASURE22
, ''pFunctionName=ISC_MAINT_WO_CST_SUM_TBL_REP'' ||
  ''&VIEW_BY_NAME=VIEW_BY_ID'' ||
  ''&VIEW_BY=BIV_MAINT_ASSET+BIV_MAINT_ASSET_NUMBER_LVL'' ||
  ''&pParamIds=Y'' BIV_ATTRIBUTE1,'||
    isc_maint_rpt_util_pkg.get_inner_select_col(l_join_tbl)||' from ';

l_stmt := l_stmt || l_inner_query ||
	  poa_dbi_template_pkg.status_sql
        ( p_fact_name            => l_mv
        , p_where_clause         => l_where_clause
        , p_join_tables          => l_join_tbl
        , p_use_windowing        => 'N'
        , p_col_name             => l_col_tbl
        , p_use_grpid            => 'N'
        , p_paren_count          => 2
        , p_filter_where         => '(p_estimated_cost<>0 or c_estimated_cost<>0 or ' ||
                                     'p_actual_cost<>0 or c_actual_cost<>0))iset'
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
  , isc_maint_rpt_util_pkg.G_ACTIVITY, 'Y'
  , isc_maint_rpt_util_pkg.G_COST_CATEGORY, 'Y'
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

  l_estimated := isc_maint_rpt_util_pkg.get_parameter_id
                 ( p_param
                 , isc_maint_rpt_util_pkg.G_ESTIMATED
                 );
  l_mv := get_fact_mv_name
          ( 'WORK_ORDER_COST'
          , p_param
          , l_dim_bmap
          , l_custom_output
          , l_estimated
          );

  l_cost_element := isc_maint_rpt_util_pkg.get_parameter_id
                   ( p_param
                   , isc_maint_rpt_util_pkg.G_COST_ELEMENT
                   );
  if l_cost_element = '1' then
    l_cost_element := 'eqp';
  elsif l_cost_element = '2' then
    l_cost_element := 'lab';
  elsif l_cost_element = '3' then
    l_cost_element := 'mat';
  else
    l_cost_element := 'tot';
  end if;

  l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'estimated_' || l_cost_element || '_cost_' || l_curr_suffix
                             , p_alias_name => 'estimated_cost'
                             , p_to_date_type => 'XTD'
                             , p_grand_total => 'N'
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'actual_' || l_cost_element || '_cost_' || l_curr_suffix
                             , p_alias_name => 'actual_cost'
                             , p_to_date_type => 'XTD'
                             , p_grand_total => 'N'
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'variance_' || l_cost_element || '_cost_' || l_curr_suffix
                             , p_alias_name => 'variance_cost'
                             , p_to_date_type => 'XTD'
                             , p_grand_total => 'N'
                             );

  l_stmt := 'select
  cal.name VIEWBY
, nvl(iset.p_estimated_cost,0) BIV_MEASURE1
, nvl(iset.c_estimated_cost,0) BIV_MEASURE2' || '
, ' ||
  isc_maint_rpt_util_pkg.change_column
    ( 'iset.c_estimated_cost'
    , 'iset.p_estimated_cost'
    , 'BIV_MEASURE3' ) || '
, nvl(iset.p_actual_cost,0) BIV_MEASURE4
, nvl(iset.c_actual_cost,0) BIV_MEASURE5' || '
, ' ||
  isc_maint_rpt_util_pkg.change_column
    ( 'iset.c_actual_cost'
    , 'iset.p_actual_cost'
    , 'BIV_MEASURE6' ) || '
, nvl(iset.p_variance_cost,0) BIV_MEASURE7
, nvl(iset.c_variance_cost,0) BIV_MEASURE8' || '
, ' ||
  isc_maint_rpt_util_pkg.change_column
    ( 'iset.c_variance_cost'
    , 'iset.p_variance_cost'
    , 'BIV_MEASURE9' ) || '
, ' ||
  isc_maint_rpt_util_pkg.rate_column
    ( 'iset.p_variance_cost'
    , 'iset.p_estimated_cost'
    , 'BIV_MEASURE10'
    , 'Y' ) || '
, ' ||
  isc_maint_rpt_util_pkg.rate_column
    ( 'iset.c_variance_cost'
    , 'iset.c_estimated_cost'
    , 'BIV_MEASURE11'
    , 'Y' ) || '
, ' ||
  isc_maint_rpt_util_pkg.change_column
    ( isc_maint_rpt_util_pkg.rate_column
        ( 'iset.c_variance_cost'
        , 'iset.c_estimated_cost'
        , null
        , 'Y' )
    , isc_maint_rpt_util_pkg.rate_column
        ( 'iset.p_variance_cost'
        , 'iset.p_estimated_cost'
        , null
        , 'Y' )
    , 'BIV_MEASURE12'
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

procedure get_sum_tbl_sql
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
  l_inner_query	     varchar2(5000);
  l_asset_grp_column varchar2(200);
begin

  isc_maint_rpt_util_pkg.register_dimension_levels
  ( l_dimension_tbl
  , l_dim_filter_map
  , isc_maint_rpt_util_pkg.G_ASSET_GROUP, 'Y'
  , isc_maint_rpt_util_pkg.G_ASSET_NUMBER, 'Y'
  , isc_maint_rpt_util_pkg.G_ACTIVITY, 'Y'
  , isc_maint_rpt_util_pkg.G_COST_CATEGORY, 'Y'
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

  l_estimated := isc_maint_rpt_util_pkg.get_parameter_id
                 ( p_param
                 , isc_maint_rpt_util_pkg.G_ESTIMATED
                 );

  l_mv := get_fact_mv_name
          ( 'WORK_ORDER_COST'
          , p_param
          , l_dim_bmap
          , l_custom_output
          , l_estimated
          );

  l_col_tbl := poa_dbi_util_pkg.poa_dbi_col_tbl();

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'estimated_mat_cost_' || l_curr_suffix
                             , p_alias_name => 'estimated_mat_cost'
                             , p_to_date_type => 'XTD'
                             , p_prior_code => poa_dbi_util_pkg.no_priors
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'actual_mat_cost_' || l_curr_suffix
                             , p_alias_name => 'actual_mat_cost'
                             , p_to_date_type => 'XTD'
                             , p_prior_code => poa_dbi_util_pkg.no_priors
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'variance_mat_cost_' || l_curr_suffix
                             , p_alias_name => 'variance_mat_cost'
                             , p_to_date_type => 'XTD'
                             , p_prior_code => poa_dbi_util_pkg.no_priors
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'estimated_lab_cost_' || l_curr_suffix
                             , p_alias_name => 'estimated_lab_cost'
                             , p_to_date_type => 'XTD'
                             , p_prior_code => poa_dbi_util_pkg.no_priors
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'actual_lab_cost_' || l_curr_suffix
                             , p_alias_name => 'actual_lab_cost'
                             , p_to_date_type => 'XTD'
                             , p_prior_code => poa_dbi_util_pkg.no_priors
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'variance_lab_cost_' || l_curr_suffix
                             , p_alias_name => 'variance_lab_cost'
                             , p_to_date_type => 'XTD'
                             , p_prior_code => poa_dbi_util_pkg.no_priors
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'estimated_eqp_cost_' || l_curr_suffix
                             , p_alias_name => 'estimated_eqp_cost'
                             , p_to_date_type => 'XTD'
                             , p_prior_code => poa_dbi_util_pkg.no_priors
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'actual_eqp_cost_' || l_curr_suffix
                             , p_alias_name => 'actual_eqp_cost'
                             , p_to_date_type => 'XTD'
                             , p_prior_code => poa_dbi_util_pkg.no_priors
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'variance_eqp_cost_' || l_curr_suffix
                             , p_alias_name => 'variance_eqp_cost'
                             , p_to_date_type => 'XTD'
                             , p_prior_code => poa_dbi_util_pkg.no_priors
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'estimated_tot_cost_' || l_curr_suffix
                             , p_alias_name => 'estimated_tot_cost'
                             , p_to_date_type => 'XTD'
                             , p_prior_code => poa_dbi_util_pkg.no_priors
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'actual_tot_cost_' || l_curr_suffix
                             , p_alias_name => 'actual_tot_cost'
                             , p_to_date_type => 'XTD'
                             , p_prior_code => poa_dbi_util_pkg.no_priors
                             );

  poa_dbi_util_pkg.add_column( p_col_tbl    => l_col_tbl
                             , p_col_name   => 'variance_tot_cost_' || l_curr_suffix
                             , p_alias_name => 'variance_tot_cost'
                             , p_to_date_type => 'XTD'
                             , p_prior_code => poa_dbi_util_pkg.no_priors
                             );

/* if view by is asset number add the asset_group column */
if(isc_maint_rpt_util_pkg.get_parameter_id(p_param,'VIEW_BY')) =
isc_maint_rpt_util_pkg.G_ASSET_NUMBER then
        l_asset_grp_column := isc_maint_rpt_util_pkg.add_asset_group_column(isc_maint_rpt_util_pkg.G_ASSET_NUMBER,l_dimension_tbl);
else
        l_asset_grp_column :='NULL';
end if ;

/* to enable windowing we are using an addition inline view */
 l_stmt := ' select ' || l_viewby_select ||
 ', biv_measure1
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
  ,biv_measure21
  ,biv_measure22
  ,biv_measure23
  ,biv_measure24
  ,biv_measure25
  ,biv_measure26
  ,biv_measure27
  ,biv_measure28
  ,biv_measure29
  ,biv_measure30
  ,biv_measure31
  ,biv_measure32
  ,biv_measure33
  ,biv_measure34 ,  '
 || l_asset_grp_column ||' BIV_MEASURE35 , biv_attribute5 ';

/* calculate the rank on the sorting column in the inline view */
l_inner_query := 'from ( select row_number() over(&ORDER_BY_CLAUSE)-1 rnk,iset.*
		  from (select '||
 ' oset05.c_estimated_mat_cost  BIV_MEASURE1
, oset05.c_actual_mat_cost  BIV_MEASURE2
, oset05.c_variance_mat_cost  BIV_MEASURE3' || '
, ' ||
  isc_maint_rpt_util_pkg.rate_column
    ( 'oset05.c_variance_mat_cost'
    , 'oset05.c_estimated_mat_cost'
    , 'BIV_MEASURE4'
    , 'Y' ) || '
, oset05.c_estimated_lab_cost  BIV_MEASURE5
, oset05.c_actual_lab_cost  BIV_MEASURE6
, oset05.c_variance_lab_cost  BIV_MEASURE7' || '
, ' ||
  isc_maint_rpt_util_pkg.rate_column
    ( 'oset05.c_variance_lab_cost'
    , 'oset05.c_estimated_lab_cost'
    , 'BIV_MEASURE8'
    , 'Y' ) || '
, oset05.c_estimated_eqp_cost  BIV_MEASURE9
, oset05.c_actual_eqp_cost  BIV_MEASURE10
, oset05.c_variance_eqp_cost  BIV_MEASURE11' || '
, ' ||
  isc_maint_rpt_util_pkg.rate_column
    ( 'oset05.c_variance_eqp_cost'
    , 'oset05.c_estimated_eqp_cost'
    , 'BIV_MEASURE12'
    , 'Y' ) || '
, oset05.c_estimated_tot_cost  BIV_MEASURE13
, oset05.c_actual_tot_cost  BIV_MEASURE14
, oset05.c_estimated_mat_cost_total  BIV_MEASURE21
, oset05.c_actual_mat_cost_total  BIV_MEASURE22
, oset05.c_variance_mat_cost_total  BIV_MEASURE23' || '
, ' ||
  isc_maint_rpt_util_pkg.rate_column
    ( 'oset05.c_variance_mat_cost_total'
    , 'oset05.c_estimated_mat_cost_total'
    , 'BIV_MEASURE24'
    , 'Y' ) || '
, oset05.c_estimated_lab_cost_total  BIV_MEASURE25
, oset05.c_actual_lab_cost_total  BIV_MEASURE26
, oset05.c_variance_lab_cost_total  BIV_MEASURE27' || '
, ' ||
  isc_maint_rpt_util_pkg.rate_column
    ( 'oset05.c_variance_lab_cost_total'
    , 'oset05.c_estimated_lab_cost_total'
    , 'BIV_MEASURE28'
    , 'Y' ) || '
, oset05.c_estimated_eqp_cost_total  BIV_MEASURE29
, oset05.c_actual_eqp_cost_total  BIV_MEASURE30
, oset05.c_variance_eqp_cost_total  BIV_MEASURE31' || '
, ' ||
  isc_maint_rpt_util_pkg.rate_column
    ( 'oset05.c_variance_eqp_cost_total'
    , 'oset05.c_estimated_eqp_cost_total'
    , 'BIV_MEASURE32'
    , 'Y' ) || '
, oset05.c_estimated_tot_cost_total  BIV_MEASURE33
, oset05.c_actual_tot_cost_total  BIV_MEASURE34' ||
  case
    when isc_maint_rpt_util_pkg.get_parameter_id
         ( p_param
         , 'VIEW_BY'
         ) in ( isc_maint_rpt_util_pkg.G_ASSET_GROUP
              , isc_maint_rpt_util_pkg.G_ASSET_NUMBER
              , isc_maint_rpt_util_pkg.G_ACTIVITY ) then
      '
, ''pFunctionName=ISC_MAINT_WO_CST_DTL_RPT_REP'' ||
  ''&VIEW_BY_NAME=VIEW_BY_ID'' ||
  ''&pParamIds=Y'' BIV_ATTRIBUTE5 '
    else '
, null BIV_ATTRIBUTE5'
  end || ', ' ||
isc_maint_rpt_util_pkg.get_inner_select_col(l_join_tbl)||' from ';
l_stmt := l_stmt || l_inner_query || poa_dbi_template_pkg.status_sql
        ( p_fact_name            => l_mv
        , p_where_clause         => l_where_clause
        , p_join_tables          => l_join_tbl
        , p_use_windowing        => 'Y'
        , p_col_name             => l_col_tbl
        , p_use_grpid            => 'N'
        , p_paren_count          => 2
        , p_filter_where         => '(c_estimated_mat_cost<>0 or c_actual_mat_cost<>0 or '||
                                     'c_estimated_lab_cost<>0 or c_actual_lab_cost<>0 or '||
                                     'c_estimated_eqp_cost<>0 or c_actual_eqp_cost<>0))iset'
        , p_generate_viewby      => 'Y'
        );


 -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
 -- l_stmt := l_stmt || isc_maint_rpt_util_pkg.dump_parameters(p_param);
x_custom_sql      := l_stmt;
x_custom_output := l_custom_output;

end get_sum_tbl_sql;

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
  , isc_maint_rpt_util_pkg.G_ACTIVITY, 'Y'
  , isc_maint_rpt_util_pkg.G_COST_CATEGORY, 'Y'
  , isc_maint_rpt_util_pkg.G_WORK_ORDER_TYPE, 'Y'
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

  l_estimated := isc_maint_rpt_util_pkg.get_parameter_id
                 ( p_param
                 , isc_maint_rpt_util_pkg.G_ESTIMATED
                 );

  if l_estimated = 'NONZERO' then
    l_where_clause := l_where_clause || ' and fact.estimated_flag = ''Y''';
  elsif l_estimated = 'ZERO' then
    l_where_clause := l_where_clause || ' and fact.estimated_flag = ''N''';
  end if;

  l_mv := get_fact_mv_name
          ( 'WORK_ORDER_COST_DTL'
          , p_param
          , l_dim_bmap
          , l_custom_output
          , null
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
                    when l_order_by like '%BIV_ATTRIBUTE6%' then
                      'NLSSORT(status_name, ''NLS_SORT=BINARY'')'
                    when l_order_by like '%BIV_MEASURE1 %' then
                      'actual_mat_cost_' || l_curr_suffix
                    when l_order_by like '%BIV_MEASURE2 %' then
                      'actual_lab_cost_' || l_curr_suffix
                    when l_order_by like '%BIV_MEASURE3 %' then
                      'actual_eqp_cost_' || l_curr_suffix
                    when l_order_by like '%BIV_MEASURE4 %' then
                      'actual_tot_cost_' || l_curr_suffix
                    when l_order_by like '%BIV_MEASURE5 %' then
                      'estimated_tot_cost_' || l_curr_suffix
                    when l_order_by like '%BIV_MEASURE6 %' then
                      'variance_tot_cost_' || l_curr_suffix
                    else -- '%BIV_MEASURE7 %'
                       isc_maint_rpt_util_pkg.rate_column
                       ( 'variance_tot_cost_' || l_curr_suffix
                       , 'estimated_tot_cost_' || l_curr_suffix
                       , null
                       , 'Y' )
                  end ||
                  l_asc_desc ||
                  'nulls last, organization_id, work_order_id';

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
  , p_dimension_level    => isc_maint_rpt_util_pkg.G_ACTIVITY
  , p_column_key         => 'activity'
  );

  isc_maint_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'status_name'
  , p_fact_col_total     => 'N'
  , p_column_key         => 'wo_status'
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
  , p_fact_col_name      => 'actual_mat_cost_' || l_curr_suffix
  , p_fact_col_total     => 'Y'
  , p_column_key         => 'actual_mat_cost'
  );

  isc_maint_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'actual_lab_cost_' || l_curr_suffix
  , p_fact_col_total     => 'Y'
  , p_column_key         => 'actual_lab_cost'
  );

  isc_maint_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'actual_eqp_cost_' || l_curr_suffix
  , p_fact_col_total     => 'Y'
  , p_column_key         => 'actual_eqp_cost'
  );

  isc_maint_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'actual_tot_cost_' || l_curr_suffix
  , p_fact_col_total     => 'Y'
  , p_column_key         => 'actual_tot_cost'
  );

  isc_maint_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'estimated_tot_cost_' || l_curr_suffix
  , p_fact_col_total     => 'Y'
  , p_column_key         => 'estimated_tot_cost'
  );

  isc_maint_rpt_util_pkg.add_detail_column
  ( p_detail_col_tbl     => l_detail_col_tbl
  , p_dimension_tbl      => l_dimension_tbl
  , p_fact_col_name      => 'variance_tot_cost_' || l_curr_suffix
  , p_fact_col_total     => 'Y'
  , p_column_key         => 'variance_tot_cost'
  );

  l_stmt := 'select
  oset.work_order_name BIV_ATTRIBUTE1
, ' || isc_maint_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'work_order_type','BIV_ATTRIBUTE2') || '
, ' || isc_maint_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'asset_number','BIV_ATTRIBUTE3') || '
, ' || isc_maint_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'asset_group','BIV_ATTRIBUTE4') || '
, ' || isc_maint_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'activity','BIV_ATTRIBUTE5') || '
, oset.wo_status BIV_ATTRIBUTE6
, ' || isc_maint_rpt_util_pkg.get_detail_column
       (l_detail_col_tbl,'department','BIV_ATTRIBUTE7') || '
, oset.actual_mat_cost BIV_MEASURE1
, oset.actual_lab_cost BIV_MEASURE2
, oset.actual_eqp_cost BIV_MEASURE3
, oset.actual_tot_cost BIV_MEASURE4
, oset.estimated_tot_cost BIV_MEASURE5
, oset.variance_tot_cost BIV_MEASURE6
, ' ||
  isc_maint_rpt_util_pkg.rate_column
    ( 'oset.variance_tot_cost'
    , 'oset.estimated_tot_cost'
    , 'BIV_MEASURE7'
    , 'Y' ) || '
, ' ||
  isc_maint_rpt_util_pkg.get_drill_detail('BIV_ATTRIBUTE8') || '
, oset.actual_mat_cost_total BIV_MEASURE8
, oset.actual_lab_cost_total BIV_MEASURE9
, oset.actual_eqp_cost_total BIV_MEASURE10
, oset.actual_tot_cost_total BIV_MEASURE11
, oset.estimated_tot_cost_total BIV_MEASURE12
, oset.variance_tot_cost_total BIV_MEASURE13
, ' ||
  isc_maint_rpt_util_pkg.rate_column
    ( 'oset.variance_tot_cost_total'
    , 'oset.estimated_tot_cost_total'
    , 'BIV_MEASURE14'
    , 'Y' ) || '
from
' || isc_maint_rpt_util_pkg.detail_sql
     ( p_detail_col_tbl => l_detail_col_tbl
     , p_dimension_tbl  => l_dimension_tbl
     , p_mv_name        => l_mv
     , p_where_clause   => l_where_clause
     , p_rank_order     => l_rank_order
     );

  -- the next line can be used to dump the contents of the PMV parameters as comments into stmt
  -- l_stmt := l_stmt || isc_maint_rpt_util_pkg.dump_parameters(p_param);

  x_custom_sql      := l_stmt;

  x_custom_output := l_custom_output;

end get_dtl_rpt_sql;

end isc_maint_wo_cst_rpt_pkg;

/
