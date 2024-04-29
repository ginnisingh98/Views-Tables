--------------------------------------------------------
--  DDL for Package Body ISC_MAINT_RPT_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_MAINT_RPT_UTIL_PKG" 
/* $Header: iscmaintrptutilb.pls 120.2 2006/02/03 03:23:22 nbhamidi noship $ */
as

G_ORGANIZATION_BMAP      constant number := 1;
G_DEPARTMENT_BMAP        constant number := 2;
G_ASSET_GROUP_BMAP       constant number := 4;
G_ASSET_NUMBER_BMAP      constant number := 8;
G_ACTIVITY_BMAP          constant number := 16;
G_COST_CATEGORY_BMAP     constant number := 32;
G_COST_ELEMENT_BMAP      constant number := 64;
G_WORK_ORDER_TYPE_BMAP   constant number := 128;
G_WORK_ORDER_STATUS_BMAP constant number := 256;
G_WIP_ENTITIES_BMAP      constant number := 512;
G_LATE_CMPL_AGING_BMAP   constant number := 1024;
G_PAST_DUE_AGING_BMAP    constant number := 2048;
G_ASSET_CATEGORY_BMAP    constant number := 4096;
G_ASSET_CRITICALITY_BMAP constant number := 8192;
G_REQUEST_TYPE_BMAP      constant number := 16384;
G_REQ_CMPL_AGING_BMAP    constant number := 32768;
G_REQUESTS_BMAP          constant number := 65536;
G_REQUEST_SEVERITIES_BMAP constant number := 131072;
G_RESOURCE_BMAP           constant number := 262144;

-- ---------------------------------------------------------------------- --
--      P R I V A T E   P R O C E D U R E S  A N D  F U N C T I O N S     --
-- ---------------------------------------------------------------------- --

-- this is a private procedure called from register_dimension_levels
-- that adds a single dimenision level to x_dimension_tbl and optionally
-- x_dim_map (based on p_filter_flag)
procedure init_dim_map
( p_dimension     in varchar2
, p_filter_flag   in varchar2
, x_dimension_tbl in out nocopy t_dimension_tbl
, x_dim_map       in out nocopy poa_dbi_util_pkg.poa_dbi_dim_map
)
is

  l_dimension_rec t_dimension_rec;
  l_dim_rec poa_dbi_util_pkg.poa_dbi_dim_rec;

begin

  if p_dimension = G_ORGANIZATION then

    l_dimension_rec.dim_bmap := G_ORGANIZATION_BMAP;
    l_dimension_rec.dim_table_name :=
       '(select organization_id id, name value ' ||
        'from hr_all_organization_units_tl ' ||
        'where language = userenv(''LANG''))';
    l_dimension_rec.dim_table_alias := 'v1';
    l_dimension_rec.dim_outer_join := 'N';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'organization_id';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.fact_filter_col_name := 'organization_id_c';
    x_dimension_tbl(G_ORGANIZATION) := l_dimension_rec;

  elsif p_dimension = G_DEPARTMENT then

    l_dimension_rec.dim_bmap := G_DEPARTMENT_BMAP;
    l_dimension_rec.dim_table_name := 'eni_resource_department_v';
    l_dimension_rec.dim_table_alias := 'v2';
    l_dimension_rec.dim_outer_join := 'Y';
    l_dimension_rec.dim_col_name1 := 'department_id';
    l_dimension_rec.oset_col_name1 := 'department_id';
    l_dimension_rec.dim_col_name2 := 'organization_id';
    l_dimension_rec.oset_col_name2 := 'organization_id';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'department_id_c';
    x_dimension_tbl(G_DEPARTMENT) := l_dimension_rec;

  elsif p_dimension = G_ASSET_GROUP then /* modified to make asset group independent of the org */

    l_dimension_rec.dim_bmap := G_ASSET_GROUP_BMAP;
    l_dimension_rec.dim_table_name :=
      '(select ' ||
         'star.inventory_item_id  id ' ||
       ', msi.concatenated_segments value ' ||
       'from ' ||
         'mtl_system_items_kfv msi, ' ||
         'ENI_OLTP_ITEM_STAR star ' ||
       'where msi.eam_item_type in (1,3) ' ||
       'and msi.inventory_item_id = star.inventory_item_id ' ||
       'and msi.organization_id = star.organization_id ' ||
       ' group by star.inventory_item_id, msi.concatenated_segments)';
    l_dimension_rec.dim_table_alias := 'v3';
    l_dimension_rec.dim_outer_join := 'Y';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'asset_group_id';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '-1';
    l_dimension_rec.fact_filter_col_name := 'asset_group_id_c';
    x_dimension_tbl(G_ASSET_GROUP) := l_dimension_rec;

  elsif p_dimension = G_ASSET_NUMBER then /* modified the asset_number to contain the instance_id */

    l_dimension_rec.dim_bmap := G_ASSET_NUMBER_BMAP;
    l_dimension_rec.dim_table_name :=
      '(select ' ||
         'cii.instance_id id ' ||
       ', cii.instance_number value ' ||
       ', cii.serial_number ' ||
       ', CII.LAST_VLD_ORGANIZATION_ID ' ||
       ', MSI.INVENTORY_ITEM_ID ' ||
       ', MSI.CONCATENATED_SEGMENTS ASSET_GROUP '||
       ', MP.MAINT_ORGANIZATION_ID ' ||
       'from ' ||
         'mtl_system_items_kfv msi ' ||
       ', CSI_ITEM_INSTANCES CII ' ||
       ', MTL_PARAMETERS MP '||
       'where msi.eam_item_type in (1,3) ' ||
       'and serial_number_control_code <> 1 '||
       'and msi.inventory_item_id = cii.inventory_item_id '||
       'and msi.organization_id = cii.last_vld_organization_id '||
       'and msi.organization_id = mp.organization_id) ';
    l_dimension_rec.dim_table_alias := 'v4';
    l_dimension_rec.dim_outer_join := 'Y';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'instance_id';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '-1';
    l_dimension_rec.fact_filter_col_name := 'instance_id_c';
    x_dimension_tbl(G_ASSET_NUMBER) := l_dimension_rec;

  elsif p_dimension = G_ACTIVITY then

    l_dimension_rec.dim_bmap := G_ACTIVITY_BMAP;
    l_dimension_rec.dim_table_name := 'biv_maint_activity_lvl_v';
    l_dimension_rec.dim_table_name :=
       '(select '  ||
          'kfv.inventory_item_id || ''-'' || kfv.organization_id id ' ||
        ', kfv.concatenated_segments || '' ('' || mp.organization_code || '')'' value ' ||
        ', tl.description ' ||
        ', kfv.inventory_item_id activity_id ' ||
        ', kfv.organization_id ' ||
        'from ' ||
          'mtl_system_items_kfv kfv ' ||
        ', mtl_system_items_tl tl ' ||
        ', mtl_parameters mp ' ||
        'where kfv.eam_item_type = 2 ' ||
        'and kfv.inventory_item_id = tl.inventory_item_id(+) ' ||
        'and kfv.organization_id = tl.organization_id(+) ' ||
        'and tl.language (+) = userenv(''LANG'') ' ||
        'and kfv.organization_id = mp.organization_id)';
    l_dimension_rec.dim_table_alias := 'v5';
    l_dimension_rec.dim_outer_join := 'Y';
    l_dimension_rec.dim_col_name1 := 'activity_id';
    l_dimension_rec.oset_col_name1 := 'activity_id';
    l_dimension_rec.dim_col_name2 := 'organization_id';
    l_dimension_rec.oset_col_name2 := 'organization_id';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'activity_id_c';
    x_dimension_tbl(G_ACTIVITY) := l_dimension_rec;

  elsif p_dimension = G_COST_CATEGORY then

    l_dimension_rec.dim_bmap := G_COST_CATEGORY_BMAP;
    l_dimension_rec.dim_table_name := 'biv_maint_cst_category_lvl_v';
    l_dimension_rec.dim_table_alias := 'v6';
    l_dimension_rec.dim_outer_join := 'N';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'maint_cost_category';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.fact_filter_col_name := 'maint_cost_category';
    x_dimension_tbl(G_COST_CATEGORY) := l_dimension_rec;

  elsif p_dimension = G_WORK_ORDER_TYPE then

    l_dimension_rec.dim_bmap := G_WORK_ORDER_TYPE_BMAP;
    l_dimension_rec.dim_table_name := 'biv_maint_wk_order_type_lvl_v';
    l_dimension_rec.dim_table_alias := 'v7';
    l_dimension_rec.dim_outer_join := 'N';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'work_order_type';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.fact_filter_col_name := 'work_order_type';
    x_dimension_tbl(G_WORK_ORDER_TYPE) := l_dimension_rec;

  elsif p_dimension = G_WORK_ORDER_STATUS then /* modified to contain the view definition which contains the system
						and user defined work order statues */
    l_dimension_rec.dim_bmap := G_WORK_ORDER_STATUS_BMAP;
    l_dimension_rec.dim_table_name :='biv_maint_wo_status_lvl_v'; /* bug 5002342 */
    l_dimension_rec.dim_table_alias := 'v8';
    l_dimension_rec.dim_outer_join := 'N';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'user_defined_status_id';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.fact_filter_col_name := 'user_defined_status_id';
    x_dimension_tbl(G_WORK_ORDER_STATUS) := l_dimension_rec;

  elsif p_dimension = G_WIP_ENTITIES then

    l_dimension_rec.dim_bmap := G_WIP_ENTITIES_BMAP;
    l_dimension_rec.dim_table_name := 'wip_entities';
    l_dimension_rec.dim_table_alias := 'v9';
    l_dimension_rec.dim_outer_join := 'N';
    l_dimension_rec.dim_col_name1 := 'wip_entity_id';
    l_dimension_rec.oset_col_name1 := 'work_order_id';
    l_dimension_rec.viewby_col_name := 'wip_entity_name';
    l_dimension_rec.viewby_id_col_name := 'null';
    l_dimension_rec.fact_filter_col_name := 'null';
    x_dimension_tbl(G_WIP_ENTITIES) := l_dimension_rec;

  elsif p_dimension = G_LATE_CMPL_AGING then

    l_dimension_rec.dim_bmap := G_LATE_CMPL_AGING_BMAP;
    l_dimension_rec.dim_table_name := 'biv_maint_late_comp_aging_v';
    l_dimension_rec.dim_table_alias := 'v10';
    l_dimension_rec.dim_outer_join := 'R';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'bucket_num';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'bucket_num';
    x_dimension_tbl(G_LATE_CMPL_AGING) := l_dimension_rec;

  elsif p_dimension = G_PAST_DUE_AGING then

    l_dimension_rec.dim_bmap := G_PAST_DUE_AGING_BMAP;
    l_dimension_rec.dim_table_name := 'BIV_MAINT_PAST_DUE_AGING_V';
    l_dimension_rec.dim_table_alias := 'v11';
    l_dimension_rec.dim_outer_join := 'R';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'bucket_num';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'bucket_num';
    x_dimension_tbl(G_PAST_DUE_AGING) := l_dimension_rec;

  elsif p_dimension = G_ASSET_CATEGORY then

    l_dimension_rec.dim_bmap := G_ASSET_CATEGORY_BMAP;
    l_dimension_rec.dim_table_name := 'BIV_MAINT_ASSET_CATEGORY_LVL_V';
    l_dimension_rec.dim_table_alias := 'v12';
    l_dimension_rec.dim_outer_join := 'Y';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'category_id';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'category_id';
    x_dimension_tbl(G_ASSET_CATEGORY) := l_dimension_rec;

  elsif p_dimension = G_ASSET_CRITICALITY then

    l_dimension_rec.dim_bmap := G_ASSET_CRITICALITY_BMAP;
    l_dimension_rec.dim_table_name := 'BIV_MAINT_ASSET_CRITICAL_LVL_V';
    l_dimension_rec.dim_table_alias := 'v13';
    l_dimension_rec.dim_outer_join := 'Y';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'asset_criticality_code';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'asset_criticality_code';
    x_dimension_tbl(G_ASSET_CRITICALITY) := l_dimension_rec;

  elsif p_dimension = G_REQUEST_TYPE then

    l_dimension_rec.dim_bmap := G_REQUEST_TYPE_BMAP;
    l_dimension_rec.dim_table_name := 'BIV_MAINT_REQUEST_TYPE_LVL_V';
    l_dimension_rec.dim_table_alias := 'v14';
    l_dimension_rec.dim_outer_join := 'N';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'request_type';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'request_type';
    x_dimension_tbl(G_REQUEST_TYPE) := l_dimension_rec;

  elsif p_dimension = G_REQ_CMPL_AGING then

    l_dimension_rec.dim_bmap := G_REQ_CMPL_AGING_BMAP;
    l_dimension_rec.dim_table_name := 'BIV_MAINT_REQ_COMP_AGING_V';
    l_dimension_rec.dim_table_alias := 'v15';
    l_dimension_rec.dim_outer_join := 'R';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'bucket_num';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'bucket_num';
    x_dimension_tbl(G_REQ_CMPL_AGING) := l_dimension_rec;

  elsif p_dimension = G_REQUESTS then

    l_dimension_rec.dim_bmap := G_REQUESTS_BMAP;
    l_dimension_rec.dim_table_name :=
       '(select ''2'' request_type' ||
        ', incident_id maint_request_id' ||
        ', summary description ' ||
        'from cs_incidents_all_tl ' ||
        'where LANGUAGE = userenv(''LANG'') ' ||
        'union all ' ||
        'select ''1''' ||
        ', work_request_id' ||
        ', description ' ||
        'from wip_eam_work_requests ' ||
       ')';
    l_dimension_rec.dim_table_alias := 'v16';
    l_dimension_rec.dim_outer_join := 'N';
    l_dimension_rec.dim_col_name1 := 'request_type';
    l_dimension_rec.oset_col_name1 := 'request_type';
    l_dimension_rec.dim_col_name2 := 'maint_request_id';
    l_dimension_rec.oset_col_name2 := 'maint_request_id';
    l_dimension_rec.viewby_col_name := 'null';
    l_dimension_rec.viewby_id_col_name := 'null';
    l_dimension_rec.fact_filter_col_name := 'null';
    x_dimension_tbl(G_REQUESTS) := l_dimension_rec;

  elsif p_dimension = G_REQUEST_SEVERITIES then

    l_dimension_rec.dim_bmap := G_REQUEST_SEVERITIES_BMAP;
    l_dimension_rec.dim_table_name :=
       '(select ''1'' request_type' ||
        ', lookup_code request_severity_id' ||
        ', meaning name ' ||
        'from fnd_lookup_values ' ||
        'where lookup_type = ''WIP_EAM_ACTIVITY_PRIORITY'' ' ||
        'and language = userenv(''LANG'') ' ||
        'and view_application_id = 700 ' ||
        'and security_group_id = ' ||
        'fnd_global.lookup_security_group(lookup_type,view_application_id) ' ||
        'union all ' ||
        'select ''2''' ||
        ', to_char(incident_severity_id)' ||
        ', name ' ||
        'from cs_incident_severities_tl ' ||
        'where LANGUAGE = userenv(''LANG'') ' ||
       ')';
    l_dimension_rec.dim_table_alias := 'v17';
    l_dimension_rec.dim_outer_join := 'Y';
    l_dimension_rec.dim_col_name1 := 'request_type';
    l_dimension_rec.oset_col_name1 := 'request_type';
    l_dimension_rec.dim_col_name2 := 'request_severity_id';
    l_dimension_rec.oset_col_name2 := 'request_severity_id';
    l_dimension_rec.viewby_col_name := 'null';
    l_dimension_rec.viewby_id_col_name := 'null';
    l_dimension_rec.fact_filter_col_name := 'null';
    x_dimension_tbl(G_REQUEST_SEVERITIES) := l_dimension_rec;

  elsif  p_dimension = G_RESOURCE then

    l_dimension_rec.dim_bmap := G_RESOURCE_BMAP;
    l_dimension_rec.dim_table_name := 'ENI_RESOURCE_V';
    l_dimension_rec.dim_table_alias := 'v18';
    l_dimension_rec.dim_outer_join := 'N';
    l_dimension_rec.dim_col_name1 := 'resource_id';
    l_dimension_rec.oset_col_name1 := 'resource_id';
    l_dimension_rec.dim_col_name2 := 'department_id';
    l_dimension_rec.oset_col_name2 := 'department_id';
    l_dimension_rec.dim_col_name3 := 'organization_id';
    l_dimension_rec.oset_col_name3 := 'organization_id';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'resource_id_c';
    x_dimension_tbl(G_RESOURCE) := l_dimension_rec;
  end if;

  if p_filter_flag <> 'N' then
    l_dim_rec.col_name := l_dimension_rec.fact_filter_col_name;
    l_dim_rec.bmap := l_dimension_rec.dim_bmap;
    x_dim_map(p_dimension) := l_dim_rec;
  end if;

end init_dim_map;

-- this is a private procedure that adds the bind variable
-- &ISC_UNASSIGNED and the appropriate (translated) text.
-- it is called from process_parameters
procedure bind_unassigned
( p_custom_output in out nocopy bis_query_attributes_tbl
) is

  l_custom_rec BIS_QUERY_ATTRIBUTES;

begin

  if p_custom_output is null then
    p_custom_output := bis_query_attributes_tbl();
  end if;

  l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;

  l_custom_rec.attribute_name := '&ISC_UNASSIGNED' ;
  l_custom_rec.attribute_value := fnd_message.get_string('BIS','BIS_UNASSIGNED');
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.varchar2_bind;
  p_custom_output.extend;
  p_custom_output(p_custom_output.count) := l_custom_rec;

end bind_unassigned;

-- this is a private function that returns a snippet of select list
-- code to manage the calculation of the grp_id bitmap value.
-- it is called from bind_group_id
function add_bin_column
( p_column  in varchar2
)
return varchar2
is
begin
  if p_column is null then
    return '';
  end if;
  return ', ' ||
         case
           when p_column = G_ASSET_GROUP then
             'case when bitand(:p_bmap,'||G_ASSET_GROUP_BMAP||') = '||G_ASSET_GROUP_BMAP||' or ' ||
                       'bitand(:p_bmap,'||G_ASSET_NUMBER_BMAP||') = '||G_ASSET_NUMBER_BMAP||' then 0 else 1 end'
           when p_column = G_ASSET_NUMBER then
             'case when bitand(:p_bmap,'||G_ASSET_NUMBER_BMAP||') = '||G_ASSET_NUMBER_BMAP||' then 0 else 1 end'
           when p_column = G_DEPARTMENT then
              'case when bitand(:p_bmap,'||G_DEPARTMENT_BMAP||') = '||G_DEPARTMENT_BMAP||' or ' ||
                       'bitand(:p_bmap,'||G_RESOURCE_BMAP||') = '||G_RESOURCE_BMAP||' then 0 else 1 end'
           when p_column = G_ACTIVITY then
             'case when bitand(:p_bmap,'||G_ACTIVITY_BMAP||') = '||G_ACTIVITY_BMAP||' then 0 else 1 end'
           when p_column = G_COST_CATEGORY then
             'case when bitand(:p_bmap,'||G_COST_CATEGORY_BMAP||') = '||G_COST_CATEGORY_BMAP||' then 0 else 1 end'
           when p_column = G_WORK_ORDER_TYPE then
             'case when bitand(:p_bmap,'||G_WORK_ORDER_TYPE_BMAP||') = '||G_WORK_ORDER_TYPE_BMAP||' then 0 else 1 end'
           when p_column = G_WORK_ORDER_STATUS then
             'case when bitand(:p_bmap,'||G_WORK_ORDER_STATUS_BMAP||') = '||G_WORK_ORDER_STATUS_BMAP||' then 0 else 1 end'
           when p_column = G_ASSET_CRITICALITY then
             'case when bitand(:p_bmap,'||G_ASSET_CRITICALITY_BMAP||') = '||G_ASSET_CRITICALITY_BMAP||' then 0 else 1 end'
           when p_column = G_ASSET_CATEGORY then
             'case when bitand(:p_bmap,'||G_ASSET_CATEGORY_BMAP||') = '||G_ASSET_CATEGORY_BMAP||' then 0 else 1 end'
           when p_column = G_REQ_CMPL_AGING then
             'case when bitand(:p_bmap,'||G_REQ_CMPL_AGING_BMAP||') = '||G_REQ_CMPL_AGING_BMAP||' then 0 else 1 end'
           when p_column = G_RESOURCE then
             'case when bitand(:p_bmap,'||G_RESOURCE_BMAP||') = '||G_RESOURCE_BMAP||' then 0 else 1 end'
           else
             ''
         end;
end add_bin_column;

-- this is a private function, it returns a poa_dbi_join_tbl based
-- on p_dimension_tbl and the user selected view by (or null for a
-- non-viewby report).
-- it is called from process_parameters and detail_sql
function get_join_info
( p_view_by       in varchar2
, p_dimension_tbl in t_dimension_tbl
)
return poa_dbi_util_pkg.poa_dbi_join_tbl
is
  l_join_rec poa_dbi_util_pkg.poa_dbi_join_rec;
  l_join_tbl poa_dbi_util_pkg.poa_dbi_join_tbl;
  l_dimension_rec t_dimension_rec;
  l_key varchar2(200);
  --
begin
  -- reinitialize the join table
  l_join_tbl := poa_dbi_util_pkg.poa_dbi_join_tbl();

  if p_view_by is not null then
    if p_dimension_tbl.exists(p_view_by) then
      l_dimension_rec := p_dimension_tbl(p_view_by);

      l_join_rec.column_name := l_dimension_rec.dim_col_name1;
      l_join_rec.table_name := l_dimension_rec.dim_table_name;
      l_join_rec.table_alias := l_dimension_rec.dim_table_alias;
      l_join_rec.fact_column := l_dimension_rec.oset_col_name1;
      l_join_rec.dim_outer_join := l_dimension_rec.dim_outer_join;
      l_join_rec.additional_where_clause := l_dimension_rec.additional_where_clause;

      l_join_tbl.extend;
      l_join_tbl(l_join_tbl.count) := l_join_rec;

      if l_dimension_rec.dim_col_name2 is not null then
        l_join_rec.column_name := l_dimension_rec.dim_col_name2;
        l_join_rec.fact_column := l_dimension_rec.oset_col_name2;
        l_join_rec.additional_where_clause := null;

        l_join_tbl.extend;
        l_join_tbl(l_join_tbl.count) := l_join_rec;

      end if;

      if l_dimension_rec.dim_col_name3 is not null then
        l_join_rec.column_name := l_dimension_rec.dim_col_name3;
        l_join_rec.fact_column := l_dimension_rec.oset_col_name3;
        l_join_rec.additional_where_clause := null;

        l_join_tbl.extend;
        l_join_tbl(l_join_tbl.count) := l_join_rec;

      end if;
    end if;

  else
    l_key := p_dimension_tbl.first;
    while l_key is not null loop
      l_dimension_rec := p_dimension_tbl(l_key);

      l_join_rec.column_name := l_dimension_rec.dim_col_name1;
      l_join_rec.table_name := l_dimension_rec.dim_table_name;
      l_join_rec.table_alias := l_dimension_rec.dim_table_alias;
      l_join_rec.fact_column := l_dimension_rec.oset_col_name1;
      l_join_rec.dim_outer_join := l_dimension_rec.dim_outer_join;
      l_join_rec.additional_where_clause := l_dimension_rec.additional_where_clause;

      l_join_tbl.extend;
      l_join_tbl(l_join_tbl.count) := l_join_rec;

      if l_dimension_rec.dim_col_name2 is not null then
        l_join_rec.column_name := l_dimension_rec.dim_col_name2;
        l_join_rec.fact_column := l_dimension_rec.oset_col_name2;
        l_join_rec.additional_where_clause := null;

        l_join_tbl.extend;
        l_join_tbl(l_join_tbl.count) := l_join_rec;

      end if;

      if l_dimension_rec.dim_col_name3 is not null then
        l_join_rec.column_name := l_dimension_rec.dim_col_name3;
        l_join_rec.fact_column := l_dimension_rec.oset_col_name3;
        l_join_rec.additional_where_clause := null;

        l_join_tbl.extend;
        l_join_tbl(l_join_tbl.count) := l_join_rec;

      end if;

      l_key := p_dimension_tbl.next(l_key);
    end loop;

  end if;

  return l_join_tbl;

end get_join_info;

-- ---------------------------------------------------------------------- --
--       P U B L I C   P R O C E D U R E S  A N D  F U N C T I O N S      --
-- ---------------------------------------------------------------------- --

-- this is a public procedure, see package specification for it's
-- description
procedure bind_group_id
( p_dim_bmap      in number
, p_custom_output in out nocopy bis_query_attributes_tbl
, p_column1       in varchar2 default null
, p_column2       in varchar2 default null
, p_column3       in varchar2 default null
, p_column4       in varchar2 default null
, p_column5       in varchar2 default null
, p_column6       in varchar2 default null
, p_column7       in varchar2 default null
, p_column8       in varchar2 default null
) is

  l_custom_rec bis_query_attributes;
  l_cur_hdl integer;
  l_stmt varchar2(1000);
  l_grp_id number;

begin

  if p_custom_output is null then
    p_custom_output := bis_query_attributes_tbl();
  end if;

  if p_column1 is null then
    return;
  end if;

  l_stmt := 'select bin_to_num( 0' ||
            add_bin_column(p_column1) ||
            add_bin_column(p_column2) ||
            add_bin_column(p_column3) ||
            add_bin_column(p_column4) ||
            add_bin_column(p_column5) ||
            add_bin_column(p_column6) ||
            add_bin_column(p_column7) ||
            add_bin_column(p_column8) ||
            ') grp_id from dual';

  -- we use dbms_sql rather than execute immediate
  -- as we don't know how many binds we need, dbms_sql
  -- allows us to "bind by name"
  l_cur_hdl := dbms_sql.open_cursor;
  dbms_sql.parse(l_cur_hdl, l_stmt, dbms_sql.native);
  dbms_sql.bind_variable(l_cur_hdl, 'p_bmap', p_dim_bmap);
  dbms_sql.define_column(l_cur_hdl, 1, l_grp_id);
  l_grp_id := dbms_sql.execute(l_cur_hdl);
  if dbms_sql.fetch_rows(l_cur_hdl) > 0 then
    dbms_sql.column_value(l_cur_hdl, 1, l_grp_id);
  end if;
  dbms_sql.close_cursor(l_cur_hdl);

  l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;

  l_custom_rec.attribute_name := '&ISC_GRP_ID' ;
  l_custom_rec.attribute_value := l_grp_id;
  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_data_type := bis_pmv_parameters_pub.integer_bind;
  p_custom_output.extend;
  p_custom_output(p_custom_output.count) := l_custom_rec;

end bind_group_id;

-- this is a public function, see the package specification for it's
-- description
function get_sec_where_clause
( p_fact_alias  in varchar2
, p_org_id      in varchar2
)
return varchar2
is
begin
  if p_org_id is not null then
    return '';
  end if;
  return '
        ( exists
            ( select 1
              from org_access o
              where o.responsibility_id = fnd_global.resp_id
              and o.resp_application_id = fnd_global.resp_appl_id
              and o.organization_id = ' || p_fact_alias ||'.organization_id ) or
          exists
            ( select 1
              from mtl_parameters org
              where org.organization_id = ' || p_fact_alias ||'.organization_id
              and not exists ( select 1
                               from org_access ora
                               where org.organization_id = ora.organization_id
                             )
            )
        )';

end get_sec_where_clause;

-- this is a public procedure, see package specification for it's
-- description
procedure register_dimension_levels
( x_dimension_tbl  in out nocopy t_dimension_tbl
, x_dim_filter_map in out nocopy poa_dbi_util_pkg.poa_dbi_dim_map
, p_dimension1     in varchar2
, p_filter_flag1   in varchar2
, p_dimension2     in varchar2 default null
, p_filter_flag2   in varchar2 default null
, p_dimension3     in varchar2 default null
, p_filter_flag3   in varchar2 default null
, p_dimension4     in varchar2 default null
, p_filter_flag4   in varchar2 default null
, p_dimension5     in varchar2 default null
, p_filter_flag5   in varchar2 default null
, p_dimension6     in varchar2 default null
, p_filter_flag6   in varchar2 default null
, p_dimension7     in varchar2 default null
, p_filter_flag7   in varchar2 default null
, p_dimension8     in varchar2 default null
, p_filter_flag8   in varchar2 default null
, p_dimension9     in varchar2 default null
, p_filter_flag9   in varchar2 default null
, p_dimension10    in varchar2 default null
, p_filter_flag10  in varchar2 default null
)
is

begin

  if p_dimension1 is not null then
    init_dim_map( p_dimension1
                , p_filter_flag1
                , x_dimension_tbl
                , x_dim_filter_map
                );

  end if;

  if p_dimension2 is not null then
    init_dim_map( p_dimension2
                , p_filter_flag2
                , x_dimension_tbl
                , x_dim_filter_map
                );
  end if;

  if p_dimension3 is not null then
    init_dim_map( p_dimension3
                , p_filter_flag3
                , x_dimension_tbl
                , x_dim_filter_map );
  end if;

  if p_dimension4 is not null then
    init_dim_map( p_dimension4
                , p_filter_flag4
                , x_dimension_tbl
                , x_dim_filter_map );
  end if;

  if p_dimension5 is not null then
    init_dim_map( p_dimension5
                , p_filter_flag5
                , x_dimension_tbl
                , x_dim_filter_map );
  end if;

  if p_dimension6 is not null then
    init_dim_map( p_dimension6
                , p_filter_flag6
                , x_dimension_tbl
                , x_dim_filter_map );
  end if;

  if p_dimension7 is not null then
    init_dim_map( p_dimension7
                , p_filter_flag7
                , x_dimension_tbl
                , x_dim_filter_map );
  end if;

  if p_dimension8 is not null then
    init_dim_map( p_dimension8
                , p_filter_flag8
                , x_dimension_tbl
                , x_dim_filter_map );
  end if;

  if p_dimension9 is not null then
    init_dim_map( p_dimension9
                , p_filter_flag9
                , x_dimension_tbl
                , x_dim_filter_map );
  end if;

  if p_dimension10 is not null then
    init_dim_map( p_dimension10
                , p_filter_flag10
                , x_dimension_tbl
                , x_dim_filter_map );
  end if;

  if not x_dimension_tbl.exists(G_ORGANIZATION) then
    init_dim_map( G_ORGANIZATION
                , 'Y'
                , x_dimension_tbl
                , x_dim_filter_map
                );
  end if;

  if not x_dimension_tbl.exists(G_DEPARTMENT) then
    init_dim_map( G_DEPARTMENT
                , 'Y'
                , x_dimension_tbl
                , x_dim_filter_map
                );
  end if;

end register_dimension_levels;

-- this is a public procedure, see the package specification for it's
-- description
procedure process_parameters
( p_param            in bis_pmv_page_parameter_tbl
, p_dimension_tbl    in out nocopy t_dimension_tbl
, p_dim_filter_map   in out nocopy poa_dbi_util_pkg.poa_dbi_dim_map
, p_trend            in varchar2
, p_custom_output in out nocopy bis_query_attributes_tbl
, x_cur_suffix       out nocopy varchar2
, x_where_clause     out nocopy varchar2
, x_viewby_select    out nocopy varchar2
, x_join_tbl         out nocopy poa_dbi_util_pkg.poa_dbi_join_tbl
, x_dim_bmap         out nocopy number
, x_comparison_type  out nocopy varchar2
, x_xtd              out nocopy varchar2
) is

  l_as_of_date      date;
  l_prev_as_of_date date;
  l_nested_pattern  number;
  l_dim_bmap        number;
  l_view_by         varchar2(100);
  l_where_clause    varchar2(10000);

begin

  if not p_dimension_tbl.exists(G_ORGANIZATION) then
    register_dimension_levels
    ( p_dimension_tbl
    , p_dim_filter_map
    , G_ORGANIZATION, 'Y'
    );
  end if;

  if not p_dimension_tbl.exists(G_DEPARTMENT) then
    register_dimension_levels
    ( p_dimension_tbl
    , p_dim_filter_map
    , G_DEPARTMENT, 'Y'
    );
  end if;

  l_dim_bmap := 0;

  poa_dbi_util_pkg.get_parameter_values
  ( p_param           => p_param            -- in, passed in
  , p_dim_map         => p_dim_filter_map   -- in, passed in, extended by register_dimension_levels
  , p_view_by         => l_view_by          -- out, used locally
  , p_cur_suffix      => x_cur_suffix       -- out, returned to caller
  , p_dim_bmap        => l_dim_bmap         -- out, returned to caller
  , p_comparison_type => x_comparison_type  -- out, returned to caller
  , p_xtd             => x_xtd              -- out, returned to caller
  , p_as_of_date      => l_as_of_date       -- out, ignored
  , p_prev_as_of_date => l_prev_as_of_date  -- out, ignored
  , p_nested_pattern  => l_nested_pattern   -- out, ignored
  );

  l_where_clause := poa_dbi_util_pkg.get_where_clauses
                    ( p_dim_filter_map
                    , case
                        when p_trend = 'Y' then 'Y'
                        else 'N'
                      end
                    );

  if p_trend = 'K' and l_where_clause is not null then
    l_where_clause := '1=1 ' || l_where_clause;
  end if;

  if p_trend = 'Y' then
    l_where_clause := l_where_clause || '
and fact.period_type_id = n.period_type_id ';
  elsif p_trend = 'N' then
    l_where_clause := l_where_clause || '
and fact.period_type_id = cal.period_type_id ';
  end if;

  x_where_clause := l_where_clause;

  if p_trend in ('N', 'K') and
    (p_dimension_tbl.exists(l_view_by)) then
    x_viewby_select := case
                         when p_dimension_tbl(l_view_by).dim_outer_join = 'Y' then
                           'nvl(' ||
                           p_dimension_tbl(l_view_by).dim_table_alias ||
                           '.' || p_dimension_tbl(l_view_by).viewby_col_name ||
                           ',&ISC_UNASSIGNED)'
                         else
                           p_dimension_tbl(l_view_by).dim_table_alias ||
                           '.' || p_dimension_tbl(l_view_by).viewby_col_name
                         end ||
                       ' VIEWBY
' ||
                       case
                         when p_dimension_tbl(l_view_by).viewby_id_col_name is not null then
                           case
                             when p_dimension_tbl(l_view_by).dim_outer_join = 'Y' then
                               ', nvl(' ||
                               p_dimension_tbl(l_view_by).dim_table_alias ||
                               '.' || p_dimension_tbl(l_view_by).viewby_id_col_name ||
                               ',' || p_dimension_tbl(l_view_by).viewby_id_unassigned ||
                               ')'
                             else
                               ', ' ||
                               p_dimension_tbl(l_view_by).dim_table_alias ||
                               '.' || p_dimension_tbl(l_view_by).viewby_id_col_name
                           end ||
                           ' VIEWBYID'
                       end;

  end if;

  if p_trend in ('N', 'D', 'K') then
    bind_unassigned( p_custom_output );
  end if;

  x_join_tbl := get_join_info(l_view_by, p_dimension_tbl );

  x_dim_bmap := l_dim_bmap;

end process_parameters;

-- this is a public function, see the package specification for it's
-- description
function get_parameter_value
( p_param            in bis_pmv_page_parameter_tbl
, p_parameter_name   in varchar2
)
return varchar2
is

begin
  for i in 1..p_param.count loop
    if p_param(i).parameter_name = p_parameter_name then
      return p_param(i).parameter_value;
    end if;
  end loop;
  return null;
end get_parameter_value;

-- this is a public function, see the package specification for it's
-- description
function get_parameter_id
( p_param            in bis_pmv_page_parameter_tbl
, p_parameter_name   in varchar2
, p_no_replace_all   in varchar2 default null
)
return varchar2
is

  l_param_id varchar2(1000);

begin
  for i in 1..p_param.count loop
    if p_param(i).parameter_name = p_parameter_name then
      l_param_id := replace(p_param(i).parameter_id,'''',null);
      if nvl(p_no_replace_all,'N') <> 'Y' then
        if l_param_id = 'All' then -- mixed case is correct
          l_param_id := null;
        end if;
      end if;
      return l_param_id;
    end if;
  end loop;
  return null;
end get_parameter_id;

-- this is a public procedure, see the package specification for it's
-- description
procedure add_detail_column
( p_detail_col_tbl     in out nocopy t_detail_column_tbl
, p_dimension_tbl      in t_dimension_tbl
, p_dimension_level    in varchar2 default null
, p_dim_level_col_name in varchar2 default null
, p_fact_col_name      in varchar2 default null
, p_fact_col_total     in varchar2 default null
, p_column_key         in varchar2
)
is

  l_detail_column_rec t_detail_column_rec;
  l_dimension_rec t_dimension_rec;
begin

  if p_dimension_level is not null then
    l_dimension_rec := p_dimension_tbl(p_dimension_level);
    l_detail_column_rec.dimension_level := p_dimension_level;
    if p_dim_level_col_name is null then
      l_detail_column_rec.dim_level_col_name := l_dimension_rec.dim_table_alias ||
                                                '.' || l_dimension_rec.viewby_col_name;
    else
      l_detail_column_rec.dim_level_col_name := l_dimension_rec.dim_table_alias ||
                                                '.' || p_dim_level_col_name;
    end if;
    if l_dimension_rec.dim_outer_join = 'Y' then
      l_detail_column_rec.dim_level_col_name := 'nvl(' ||
                                                l_detail_column_rec.dim_level_col_name ||
                                                ',&ISC_UNASSIGNED)';
    end if;
  else
    l_detail_column_rec.fact_col_name := p_fact_col_name;
    l_detail_column_rec.fact_col_total := p_fact_col_total;
  end if;
  p_detail_col_tbl(p_column_key) := l_detail_column_rec;

end add_detail_column;

-- this is a public function, see the package specification for it's
-- description
function get_detail_column
( p_detail_col_tbl in t_detail_column_tbl
, p_column_key     in varchar2
, p_alias          in varchar2 default null
)
return varchar2
is
begin
  return
    p_detail_col_tbl(p_column_key).dim_level_col_name ||
    case
      when p_alias is not null then
        ' ' || p_alias
    end;
end get_detail_column;

-- this is a public function, see the package specification for it's
-- description
function detail_sql
( p_detail_col_tbl     in t_detail_column_tbl
, p_dimension_tbl      in t_dimension_tbl
, p_mv_name            in varchar2
, p_where_clause       in varchar2
, p_rank_order         in varchar2 default null
, p_filter_where       in varchar2 default null
, p_override_date_clause in varchar2 default null
)
return varchar2
is
  l_detail_column_rec t_detail_column_rec;
  l_dimension_rec t_dimension_rec;
  l_dimension_tbl t_dimension_tbl;
  l_select_list varchar2(4000);
  l_fact_select_list varchar2(4000);
  l_key varchar2(200);
  l_join_tbl poa_dbi_util_pkg.poa_dbi_join_tbl;
  l_col_name varchar2(200);
begin
  -- build fact select list
  l_key := p_detail_col_tbl.first;
  while l_key is not null loop
    l_detail_column_rec := p_detail_col_tbl(l_key);
    if l_detail_column_rec.dimension_level is not null then
      l_dimension_rec := p_dimension_tbl(l_detail_column_rec.dimension_level);
      l_dimension_tbl(l_detail_column_rec.dimension_level) := l_dimension_rec;
      l_col_name := l_dimension_rec.oset_col_name1;
      if l_select_list is null or
         l_select_list not like '%, ' || l_col_name || '%' then
        l_select_list := l_select_list || '
  , ' || l_col_name;
      end if;
      l_col_name := l_dimension_rec.oset_col_name2;
      if l_col_name is not null and l_select_list not like '%, '||l_col_name || '%' then
        l_select_list := l_select_list || '
  , ' || l_col_name;
      end if;
    else
      l_fact_select_list := l_fact_select_list ||
                            '
  , ' || l_detail_column_rec.fact_col_name ||
                            ' ' || l_key;
      if l_detail_column_rec.fact_col_total = 'Y' then
        l_fact_select_list := l_fact_select_list ||
                              '
  , sum(' || l_detail_column_rec.fact_col_name || ') over()' ||
                              ' ' || l_key || '_total';
      end if;
    end if;
    l_key := p_detail_col_tbl.next(l_key);
  end loop;

  l_join_tbl := get_join_info( null, l_dimension_tbl );

  return '( select
    ' || case
           when p_rank_order is null then
             '-1 rnk'
           else
             'rank() over(' || p_rank_order || ')-1 rnk'
         end || l_select_list || l_fact_select_list || '
  from
  ' || p_mv_name || ' fact
  where ' ||
    case
      when p_override_date_clause is not null then
        p_override_date_clause
      else
        'report_date between &BIS_CURRENT_EFFECTIVE_START_DATE and &BIS_CURRENT_ASOF_DATE'
    end || '
  ' || p_where_clause || ' ' || p_filter_where || '
) oset
, ' || poa_dbi_template_pkg.get_viewby_rank_clause
                            ( l_join_tbl
                            , case
                                when p_rank_order is null then 'N'
                                else 'Y'
                              end );

end detail_sql;

-- this is a public function, see the package specification for it's
-- description
function change_column
( p_current_column  in varchar2
, p_prior_column    in varchar2
, p_column_alias    in varchar2
, p_percent         in varchar2 default 'Y'
) return varchar2
is
begin
  if p_percent = 'Y' then
    return poa_dbi_util_pkg.change_clause(p_current_column,p_prior_column) ||
           ' ' || p_column_alias;
  end if;
--  return poa_dbi_util_pkg.change_clause('nvl('||p_current_column||',0)',p_prior_column,'X') ||
  return poa_dbi_util_pkg.change_clause(p_current_column,p_prior_column,'X') ||
         ' ' || p_column_alias;
end change_column;

-- this is a public function, see the package specification for it's
-- description
function rate_column
( p_numerator       in varchar2
, p_denominator     in varchar2
, p_column_alias    in varchar2
, p_percent         in varchar2 default 'Y'
) return varchar2
is
begin
  return poa_dbi_util_pkg.rate_clause( p_numerator
                                     , p_denominator
                                     , case p_percent
                                         when 'Y' then 'P'
                                         else 'NP'
                                       end ) ||
         ' ' || p_column_alias;
end rate_column;

-- this is a public function, see the package specification for it's
-- description
function dump_parameters
( p_param in bis_pmv_page_parameter_tbl )
return varchar2
is
  l_stmt varchar2(10000);
begin
  l_stmt := '
/*
';
  for i in 1..p_param.count loop
    l_stmt := l_stmt || '"' || p_param(i).parameter_name ||
                        ',' || p_param(i).parameter_value ||
                        ',' || p_param(i).parameter_id ||
                        ',' || p_param(i).dimension ||
                        ',' || p_param(i).period_date ||
                        '"
';
  end loop;
  l_stmt := l_stmt || '*/';
  return l_stmt;
end dump_parameters;

function add_view_by
( p_view_by          in varchar2
, p_dimension_tbl    in t_dimension_tbl
, p_join_tbl         in out nocopy poa_dbi_util_pkg.poa_dbi_join_tbl
)
return varchar2
is

  l_join_rec poa_dbi_util_pkg.poa_dbi_join_rec;
  l_dimension_rec t_dimension_rec;
  l_return varchar2(200);

begin

  l_dimension_rec := p_dimension_tbl(p_view_by);

  l_join_rec.column_name := l_dimension_rec.dim_col_name1;
  l_join_rec.table_name := l_dimension_rec.dim_table_name;
  l_join_rec.table_alias := l_dimension_rec.dim_table_alias;
  l_join_rec.fact_column := l_dimension_rec.oset_col_name1;
  l_join_rec.dim_outer_join := l_dimension_rec.dim_outer_join;
  l_join_rec.additional_where_clause := l_dimension_rec.additional_where_clause;

  l_return := l_dimension_rec.dim_table_alias || '.' || l_dimension_rec.viewby_col_name;

  if l_dimension_rec.dim_outer_join = 'Y' then
    l_return := 'nvl(' || l_return || ',&ISC_UNASSIGNED)';
  end if;

  p_join_tbl.extend;
  p_join_tbl(p_join_tbl.count) := l_join_rec;

  if l_dimension_rec.dim_col_name2 is not null then
    l_join_rec.column_name := l_dimension_rec.dim_col_name2;
    l_join_rec.fact_column := l_dimension_rec.oset_col_name2;
    l_join_rec.additional_where_clause := null;

    p_join_tbl.extend;
    p_join_tbl(p_join_tbl.count) := l_join_rec;
  end if;

  return l_return;

end add_view_by;

function get_drill_detail
( p_column_alias     in varchar2
, p_org_id_column    in varchar2 default null
, p_wo_id_column     in varchar2 default null
)
return varchar2
is

begin

  return '''pFunctionName=EAM_WORK_RELATIONSHIP'
         || '&OAPB=ISC_MAINT_DRILL_BRAND' -- branding
         || '&dbiHideReturn=Y' -- this must be 'Y' or 'N'
         || '&dbiReturnUrl=' -- pass an empty parameter until PMV can provide value
         || '&dbiReturnText=' -- pass an empty parameter until PMV can provide value
         || '&WipEntityId=''||'
         || nvl(p_wo_id_column,'oset.work_order_id')
         || '||''&OrgId=''||'
         || nvl(p_org_id_column,'oset.organization_id')
         || ' ' || p_column_alias;

end get_drill_detail;

-- this is a public function, see the package specification for it's
-- description
function add_asset_group_column
( p_view_by in varchar2
, p_dimension_tbl in t_dimension_tbl
)
return varchar2
is
l_dimension_rec t_dimension_rec;
viewby varchar2(200);
begin
l_dimension_rec := p_dimension_tbl(p_view_by);       --locate the asset_number_dimension in the dimension table
viewby := l_dimension_rec.dim_table_alias||'.asset_group'; -- return the asset_group curresponding to the asset number.
return viewby;
end add_asset_group_column;

-- this is a public function, see the package specification for it's
-- description
function get_inner_select_col
(p_join_tables in poa_dbi_util_pkg.poa_dbi_join_tbl
) return varchar2
is
l_select_list varchar2(500);
begin
  for i in 1 .. p_join_tables.count loop
    if i > 1 then
      l_select_list := l_select_list || ', ';
    end if;
    l_select_list := l_select_list || p_join_tables(i).fact_column;
  end loop;
  return l_select_list;
end get_inner_select_col;



end isc_maint_rpt_util_pkg;

/
