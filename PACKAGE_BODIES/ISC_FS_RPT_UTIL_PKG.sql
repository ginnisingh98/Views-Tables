--------------------------------------------------------
--  DDL for Package Body ISC_FS_RPT_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_FS_RPT_UTIL_PKG" 
/* $Header: iscfsrptutilb.pls 120.7 2006/04/12 20:45:18 kreardon noship $ */
as

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

  if p_dimension = G_CATEGORY then

    l_dimension_rec.dim_bmap := G_CATEGORY_BMAP;
    l_dimension_rec.dim_table_name :=
      '(select id, value, leaf_node_flag, item_assgn_flag from eni_item_vbh_nodes_v where parent_id = child_id)';
    l_dimension_rec.dim_table_alias := 'v1';
    l_dimension_rec.dim_outer_join := 'N';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'vbh_child_category_id';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.fact_filter_col_name := 'vbh_parent_category_id';
    x_dimension_tbl(p_dimension) := l_dimension_rec;

  elsif p_dimension = G_CUSTOMER then

    l_dimension_rec.dim_bmap := G_CUSTOMER_BMAP;
    l_dimension_rec.dim_table_name := 'aso_bi_prospect_v';
    l_dimension_rec.dim_table_alias := 'v2';
    l_dimension_rec.dim_outer_join := 'N';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'customer_id';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'customer_id';
    x_dimension_tbl(p_dimension) := l_dimension_rec;

  elsif p_dimension = G_DISTRICT then

    l_dimension_rec.dim_bmap := G_DISTRICT_BMAP;
    l_dimension_rec.dim_table_name :=
      '(select ''GROUP'' record_type, group_id id, group_name value from jtf_rs_groups_vl ' ||
       'union all ' ||
       'select ''RESOURCE'' record_type, resource_id id, resource_name value from jtf_rs_resource_extns_vl)';
       -- note: the above is modified in procedure process_parameters to include
       -- union all from jtf_rs_teams_vl, only if district parameters value = '-1'
    l_dimension_rec.dim_table_alias := 'v3';
    l_dimension_rec.dim_outer_join := 'N';
    l_dimension_rec.dim_col_name1 := 'record_type';
    l_dimension_rec.oset_col_name1 := 'record_type';
    l_dimension_rec.dim_col_name2 := 'id';
    l_dimension_rec.oset_col_name2 := 'district_id';
    -- R12 resource type impact
    l_dimension_rec.viewby_col_name :=
      'case when oset.record_type = ''GROUP'' and oset.district_id_c like ''%.%'' then replace(&ISC_FS_DIRECT,''&GROUP_NAME'',v3.value) else v3.value end';
    l_dimension_rec.viewby_id_col_name :=
       -- This code is to have some control over drill and pivot, ideally we
       -- would like to optionally suppress drill and pivot but we cannot so
       -- we modify the value of the VIEWBYID returned under certain
       -- conditions:
       -- . concatenated id contains '%.-1' which means the district parameter
       --   is set to Unassigned - in this situation we return '-1' as the
       --   drill and pivot cannot use the real ID as it may not be
       --   represented in LOV for Unassigned (which is a catch all).
       --   TEAM can only be in Unassigned.
       -- . record_type is GROUP and the concatenated id contains '%.%', which
       --   means that the task owner/assignee is a GROUP and not an
       --   individual resource - in this situation we return the district id.
       --   This conbination is not represented in the LOV.
       'case ' ||
         'when oset.district_id_c like ''%.-1'' then ''-1'' ' ||
         'when oset.record_type = ''GROUP'' and oset.district_id_c like ''%.%'' then to_char(oset.district_id) ' ||
         'else oset.district_id_c ' ||
       'end';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'parent_district_id';
    x_dimension_tbl(p_dimension) := l_dimension_rec;

  elsif p_dimension = G_PRODUCT then

    l_dimension_rec.dim_bmap := G_PRODUCT_BMAP;
    l_dimension_rec.dim_table_name := 'eni_item_v';
    l_dimension_rec.dim_table_alias := 'v4';
    l_dimension_rec.dim_outer_join := 'N';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'product_id';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'product_id';
    x_dimension_tbl(p_dimension) := l_dimension_rec;

  elsif p_dimension = G_TASK_TYPE then

    l_dimension_rec.dim_bmap := G_TASK_TYPE_BMAP;
    l_dimension_rec.dim_table_name :=
      '(select task_type_id id, name value from jtf_task_types_tl where language = userenv(''LANG''))';
    l_dimension_rec.dim_table_alias := 'v5';
    l_dimension_rec.dim_outer_join := 'N';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'task_type_id';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'task_type_id';
    x_dimension_tbl(p_dimension) := l_dimension_rec;

  elsif p_dimension = G_BACKLOG_AGING_DISTRIB then

    l_dimension_rec.dim_bmap := G_BACKLOG_AGING_DISTRIB_BMAP;
    l_dimension_rec.dim_table_name := 'biv_fs_backlog_aging_lvl_v';
    l_dimension_rec.dim_table_alias := 'v6';
    l_dimension_rec.dim_outer_join := 'R';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'bucket_num';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'bucket_num';
    x_dimension_tbl(p_dimension) := l_dimension_rec;

  elsif p_dimension = G_TIME_TO_RES_DISTRIB then

    l_dimension_rec.dim_bmap := G_TIME_TO_RES_DISTRIB_BMAP;
    l_dimension_rec.dim_table_name := 'biv_fs_time_to_res_lvl_v';
    l_dimension_rec.dim_table_alias := 'v7';
    l_dimension_rec.dim_outer_join := 'R';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'bucket_num';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'bucket_num';
    x_dimension_tbl(p_dimension) := l_dimension_rec;

  elsif p_dimension = G_TRVL_DIST_DISTRIB then

    l_dimension_rec.dim_bmap := G_TRVL_DIST_DISTRIB_BMAP;
    l_dimension_rec.dim_table_name := 'biv_fs_trvl_dist_lvl_v';
    l_dimension_rec.dim_table_alias := 'v8';
    l_dimension_rec.dim_outer_join := 'R';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'bucket_num';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'bucket_num';
    x_dimension_tbl(p_dimension) := l_dimension_rec;

  elsif p_dimension = G_TRVL_DIST_VAR_DISTRIB then

    l_dimension_rec.dim_bmap := G_TRVL_DIST_VAR_DISTRIB_BMAP;
    l_dimension_rec.dim_table_name := 'biv_fs_trvl_dist_var_lvl_v';
    l_dimension_rec.dim_table_alias := 'v9';
    l_dimension_rec.dim_outer_join := 'R';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'bucket_num';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'bucket_num';
    x_dimension_tbl(p_dimension) := l_dimension_rec;

  elsif p_dimension = G_TRVL_TIME_DISTRIB then

    l_dimension_rec.dim_bmap := G_TRVL_TIME_DISTRIB_BMAP;
    l_dimension_rec.dim_table_name := 'biv_fs_trvl_time_lvl_v';
    l_dimension_rec.dim_table_alias := 'v10';
    l_dimension_rec.dim_outer_join := 'R';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'bucket_num';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'bucket_num';
    x_dimension_tbl(p_dimension) := l_dimension_rec;

  elsif p_dimension = G_INV_CATEGORY then

    l_dimension_rec.dim_bmap := G_INV_CATEGORY_BMAP;
    l_dimension_rec.dim_table_name := 'eni_item_inv_cat_v';
    l_dimension_rec.dim_table_alias := 'v11';
    l_dimension_rec.dim_outer_join := 'N';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'inv_category_id';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'inv_category_id';
    x_dimension_tbl(p_dimension) := l_dimension_rec;

  elsif p_dimension = G_ITEM_ORG then

    l_dimension_rec.dim_bmap := G_ITEM_ORG_BMAP;
    l_dimension_rec.dim_table_name := 'eni_item_org_v';
    l_dimension_rec.dim_table_alias := 'v12';
    l_dimension_rec.dim_outer_join := 'N';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'item_org_id';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'item_org_id';
    x_dimension_tbl(p_dimension) := l_dimension_rec;

  elsif p_dimension = G_TRVL_TIME_VAR_DISTRIB then

    l_dimension_rec.dim_bmap := G_TRVL_TIME_VAR_DISTRIB_BMAP;
    l_dimension_rec.dim_table_name := 'biv_fs_trvl_time_var_lvl_v';
    l_dimension_rec.dim_table_alias := 'v13';
    l_dimension_rec.dim_outer_join := 'R';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'bucket_num';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'bucket_num';
    x_dimension_tbl(p_dimension) := l_dimension_rec;

  elsif p_dimension = G_TASK_OWNER then

    l_dimension_rec.dim_bmap := G_TASK_OWNER_BMAP;
    l_dimension_rec.dim_table_name :=
       -- R12 resource type impact
       -- add support for GROUP and TEAM
      '(select ''GROUP'' owner_type, group_id id, group_name value from jtf_rs_groups_vl ' ||
       'union all ' ||
       'select ''TEAM'' owner_type, team_id id, team_name value from jtf_rs_teams_vl ' ||
       'union all ' ||
       'select ''RESOURCE'' owner_type, resource_id id, resource_name value from jtf_rs_resource_extns_vl)';
    l_dimension_rec.dim_table_alias := 'v14';
    l_dimension_rec.dim_outer_join := 'Y';
    l_dimension_rec.dim_col_name1 := 'owner_type';
    l_dimension_rec.oset_col_name1 := 'owner_type';
    l_dimension_rec.dim_col_name2 := 'id';
    l_dimension_rec.oset_col_name2 := 'owner_id';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '''-2''';
    l_dimension_rec.fact_filter_col_name := 'owner_id';
    x_dimension_tbl(p_dimension) := l_dimension_rec;

  elsif p_dimension = G_BACKLOG_STATUS then

    l_dimension_rec.dim_bmap := G_BACKLOG_STATUS_BMAP;
    l_dimension_rec.dim_table_name := 'biv_fs_backlog_status_lvl_v';
    l_dimension_rec.dim_table_alias := 'v15';
    l_dimension_rec.dim_outer_join := 'N';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'backlog_status_code';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'backlog_status_code';
    x_dimension_tbl(p_dimension) := l_dimension_rec;

  elsif p_dimension = G_TASK_STATUS then

    l_dimension_rec.dim_bmap := G_TASK_STATUS_BMAP;
    l_dimension_rec.dim_table_name := 'jtf_task_statuses_vl';
    l_dimension_rec.dim_table_alias := 'v16';
    l_dimension_rec.dim_outer_join := 'N';
    l_dimension_rec.dim_col_name1 := 'task_status_id';
    l_dimension_rec.oset_col_name1 := 'task_status_id';
    l_dimension_rec.viewby_col_name := 'name';
    l_dimension_rec.viewby_id_col_name := 'task_status_id';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'task_status_id';
    x_dimension_tbl(p_dimension) := l_dimension_rec;

  elsif p_dimension = G_SR_TYPE then

    l_dimension_rec.dim_bmap := G_SR_TYPE_BMAP;
    l_dimension_rec.dim_table_name := 'cs_incident_types_vl';
    l_dimension_rec.dim_table_alias := 'v17';
    l_dimension_rec.dim_outer_join := 'N';
    l_dimension_rec.dim_col_name1 := 'incident_type_id';
    l_dimension_rec.oset_col_name1 := 'incident_type_id';
    l_dimension_rec.viewby_col_name := 'name';
    l_dimension_rec.viewby_id_col_name := 'incident_type_id';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'incident_type_id';
    x_dimension_tbl(p_dimension) := l_dimension_rec;

  elsif p_dimension = G_SR_STATUS then

    l_dimension_rec.dim_bmap := G_SR_STATUS_BMAP;
    l_dimension_rec.dim_table_name := 'cs_incident_statuses_vl';
    l_dimension_rec.dim_table_alias := 'v18';
    l_dimension_rec.dim_outer_join := 'Y';
    l_dimension_rec.dim_col_name1 := 'incident_status_id';
    l_dimension_rec.oset_col_name1 := 'incident_status_id';
    l_dimension_rec.viewby_col_name := 'name';
    l_dimension_rec.viewby_id_col_name := 'incident_status_id';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'incident_status_id';
    x_dimension_tbl(p_dimension) := l_dimension_rec;


  elsif p_dimension = G_SR_OWNER then

    l_dimension_rec.dim_bmap := G_SR_OWNER_BMAP;
    l_dimension_rec.dim_table_name :=
      '(select resource_id id, resource_name value from jtf_rs_resource_extns_vl)';
    l_dimension_rec.dim_table_alias := 'v19';
    l_dimension_rec.dim_outer_join := 'Y';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'incident_owner_id';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '''-2''';
    l_dimension_rec.fact_filter_col_name := 'incident_owner_id';
    x_dimension_tbl(p_dimension) := l_dimension_rec;

  elsif p_dimension = G_TASK_ASSIGNEE then

    l_dimension_rec.dim_bmap := G_TASK_ASSIGNEE_BMAP;
    l_dimension_rec.dim_table_name :=
       -- R12 resource type impact
       -- add support for GROUP and TEAM
      '(select ''GROUP'' assignee_type, group_id id, group_name value from jtf_rs_groups_vl ' ||
       'union all ' ||
       'select ''TEAM'' assignee_type, team_id id, team_name value from jtf_rs_teams_vl ' ||
       'union all ' ||
       'select ''RESOURCE'' assignee_type, resource_id id, resource_name value from jtf_rs_resource_extns_vl)';
    l_dimension_rec.dim_table_alias := 'v20';
    l_dimension_rec.dim_outer_join := 'Y';
    l_dimension_rec.dim_col_name1 := 'assignee_type';
    l_dimension_rec.oset_col_name1 := 'assignee_type';
    l_dimension_rec.dim_col_name2 := 'id';
    l_dimension_rec.oset_col_name2 := 'assignee_id';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '''-2''';
    l_dimension_rec.fact_filter_col_name := 'assignee_id';
    x_dimension_tbl(p_dimension) := l_dimension_rec;

  elsif p_dimension = G_TASK_ADDRESS then

    l_dimension_rec.dim_bmap := G_TASK_ADDRESS_BMAP;
    l_dimension_rec.dim_table_name :=
      '(select ''ADDRESS_ID'' address_type, party_site_id id, hz_format_pub.format_address(location_id) value from hz_party_sites ' ||
      'union all ' ||
      'select ''LOCATION_ID'' address_type, location_id id, hz_format_pub.format_address(location_id) value from hz_locations)';
    l_dimension_rec.dim_table_alias := 'v21';
    l_dimension_rec.dim_outer_join := 'Y';
    l_dimension_rec.dim_col_name1 := 'address_type';
    l_dimension_rec.oset_col_name1 := 'address_type';
    l_dimension_rec.dim_col_name2 := 'id';
    l_dimension_rec.oset_col_name2 := 'address_id';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'id';
    x_dimension_tbl(p_dimension) := l_dimension_rec;

  elsif p_dimension = G_SEVERITY then

    l_dimension_rec.dim_bmap := G_SEVERITY_BMAP;
    l_dimension_rec.dim_table_name := 'biv_severities_v';
    l_dimension_rec.dim_table_alias := 'v22';
    l_dimension_rec.dim_outer_join := 'N';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'incident_severity_id';
    l_dimension_rec.viewby_col_name := 'value';
    l_dimension_rec.viewby_id_col_name := 'id';
    l_dimension_rec.viewby_id_unassigned := '''-1''';
    l_dimension_rec.fact_filter_col_name := 'incident_severity_id';
    x_dimension_tbl(p_dimension) := l_dimension_rec;

  elsif p_dimension = 'DUMMY_DISTRICT' then

    l_dimension_rec.dim_bmap := G_DISTRICT_BMAP;
    l_dimension_rec.dim_table_name :=
      '(select null id from dual where 1=3)';
    l_dimension_rec.dim_table_alias := 'v0';
    l_dimension_rec.dim_outer_join := 'Y';
    l_dimension_rec.dim_col_name1 := 'id';
    l_dimension_rec.oset_col_name1 := 'district_id_c';
    x_dimension_tbl(p_dimension) := l_dimension_rec;

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

begin

  add_custom_bind_parameter
  ( p_custom_output       => p_custom_output
  , p_parameter_name      => '&ISC_UNASSIGNED'
  , p_parameter_data_type => bis_pmv_parameters_pub.varchar2_bind
  , p_parameter_value     => fnd_message.get_string('BIS','BIS_UNASSIGNED')
  );

  add_custom_bind_parameter
  ( p_custom_output       => p_custom_output
  , p_parameter_name      => '&ISC_FS_DIRECT'
  , p_parameter_data_type => bis_pmv_parameters_pub.varchar2_bind
  , p_parameter_value     => fnd_message.get_string('ISC','ISC_FS_DIRECT')
  );

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
           when p_column = G_INV_CATEGORY then
              'case when bitand(:p_bmap,'||G_INV_CATEGORY_BMAP||') = '||G_INV_CATEGORY_BMAP||' or ' ||
                         'bitand(:p_bmap,'||G_ITEM_ORG_BMAP||') = '||G_ITEM_ORG_BMAP||' then 0 else 1 end'
           when p_column = G_ITEM_ORG then
                 'case when bitand(:p_bmap,'||G_ITEM_ORG_BMAP||') = '||G_ITEM_ORG_BMAP||' then 0 else 1 end'

           when p_column = G_CUSTOMER then
             'case when bitand(:p_bmap,'||G_CUSTOMER_BMAP||') = '||G_CUSTOMER_BMAP||' then 0 else 1 end'
           when p_column = G_PRODUCT then
             'case when bitand(:p_bmap,'||G_CUSTOMER_BMAP||') = '||G_CUSTOMER_BMAP||' or ' ||
                       'bitand(:p_bmap,'||G_PRODUCT_BMAP||') = '||G_PRODUCT_BMAP||' then 0 else 1 end'
           when p_column = G_CATEGORY then
             'case when bitand(:p_bmap,'||G_CUSTOMER_BMAP||') = '||G_CUSTOMER_BMAP||' or ' ||
                       'bitand(:p_bmap,'||G_PRODUCT_BMAP||') = '||G_PRODUCT_BMAP||' or ' ||
                       'bitand(:p_bmap,'||G_CATEGORY_BMAP||') = '||G_CATEGORY_BMAP||' then 0 else 1 end'
           when p_column = G_SEVERITY then
             'case when bitand(:p_bmap,'||G_CUSTOMER_BMAP||') = '||G_CUSTOMER_BMAP||' or ' ||
                       'bitand(:p_bmap,'||G_PRODUCT_BMAP||') = '||G_PRODUCT_BMAP||' or ' ||
                       'bitand(:p_bmap,'||G_CATEGORY_BMAP||') = '||G_CATEGORY_BMAP||' or ' ||
                       'bitand(:p_bmap,'||G_SEVERITY_BMAP||') = '||G_SEVERITY_BMAP||' then 0 else 1 end'
           when p_column = G_TASK_TYPE then
             'case when bitand(:p_bmap,'||G_CUSTOMER_BMAP||') = '||G_CUSTOMER_BMAP||' or ' ||
                       'bitand(:p_bmap,'||G_PRODUCT_BMAP||') = '||G_PRODUCT_BMAP||' or ' ||
                       'bitand(:p_bmap,'||G_CATEGORY_BMAP||') = '||G_CATEGORY_BMAP||' or ' ||
                       'bitand(:p_bmap,'||G_TASK_TYPE_BMAP||') = '||G_TASK_TYPE_BMAP||' then 0 else 1 end'
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
, p_dimension_tbl in out nocopy t_dimension_tbl
)
return poa_dbi_util_pkg.poa_dbi_join_tbl
is
  l_join_rec poa_dbi_util_pkg.poa_dbi_join_rec;
  l_join_tbl poa_dbi_util_pkg.poa_dbi_join_tbl;
  l_dimension_rec t_dimension_rec;
  l_key varchar2(200);
  l_dim_map poa_dbi_util_pkg.poa_dbi_dim_map;
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

  if p_view_by = G_DISTRICT then

    init_dim_map
    ( p_dimension     => 'DUMMY_DISTRICT'
    , p_filter_flag   => 'N'
    , x_dimension_tbl => p_dimension_tbl
    , x_dim_map       => l_dim_map
    );

    l_key := add_view_by
             ( 'DUMMY_DISTRICT'
             , p_dimension_tbl
             , l_join_tbl
             );

  end if;

  return l_join_tbl;

end get_join_info;

-- this procedure adds bind variable values to p_custom_output for
-- the travel distance conversion factor
-- p_param: the parameter table passed into your report from PMV.
-- p_distance: the distance suffix as returned by process_parameters
--             "mi" for miles, "km" for kilometers
procedure bind_distance_factor
( p_custom_output in out nocopy bis_query_attributes_tbl
, p_distance      in varchar2
)
is
begin
  add_custom_bind_parameter
  ( p_custom_output
  , '&ISC_FS_DIST_FACTOR'
  , BIS_PMV_PARAMETERS_PUB.NUMERIC_BIND
  , case
      when p_distance = 'mi' then 0.62137
      else 1
    end
  );
end bind_distance_factor;

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

  add_custom_bind_parameter
  ( p_custom_output       => p_custom_output
  , p_parameter_name      => '&ISC_GRP_ID'
  , p_parameter_data_type => bis_pmv_parameters_pub.integer_bind
  , p_parameter_value     => to_char(l_grp_id)
  );

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
  return '';
/*
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
*/

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

  if not x_dimension_tbl.exists(G_DISTRICT) then
    init_dim_map( G_DISTRICT
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
, x_uom_suffix       out nocopy varchar2
) is

  l_as_of_date      date;
  l_prev_as_of_date date;
  l_nested_pattern  number;
  l_dim_bmap        number;
  l_view_by         varchar2(100);
  l_where_clause    varchar2(10000);

  l_district_id     constant varchar2(100) := get_parameter_id
                                             ( p_param
                                             , G_DISTRICT
                                             );
begin

  if not p_dimension_tbl.exists(G_DISTRICT) then
    register_dimension_levels
    ( p_dimension_tbl
    , p_dim_filter_map
    , G_DISTRICT, 'Y'
    );
  end if;

  if l_district_id like '%.%' then
    p_dim_filter_map(G_DISTRICT).col_name := 'district_id_c';
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

  -- R12 resource type impact
  if l_view_by = G_DISTRICT and
     l_district_id = '-1' then
      -- add support for TEAM
    p_dimension_tbl(G_DISTRICT).dim_table_name :=
      replace( p_dimension_tbl(G_DISTRICT).dim_table_name
             , 'union all '
             , 'union all ' ||
               'select ''TEAM'' record_type, team_id id, team_name value from jtf_rs_teams_vl ' ||
               'union all '
             );
  end if;

  if l_view_by = G_CATEGORY and
     get_parameter_id
     ( p_param
     , G_CATEGORY
     ) is null then
    p_dimension_tbl(G_CATEGORY).oset_col_name1 := 'vbh_parent_category_id';
  end if;

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


  -- if the user does not have a valid district (as manager)
  -- then JTF_RS_DBI_CONC_PUB.GET_FSG_ID will return NULL
  -- if NULL is returned, PMV does not do the bind variable
  -- substitution which results in "&ORGANIZATION+JTF_ORG_SALES_GROUP"
  -- appearing in the SQL statement that is about to executed.  this leaves
  -- the statement is invalid and will error.
  -- to work around this problem we force the parameter into the custom
  -- output so that PMV do the substitution for us.

  -- due to a restriction on the length of BIS_QUERY_ATTRIBUTES.ATTRIBUTE_NAME
  -- we cannot pass G_DISTRICT as it is too long.  So we pass G_DISTRICT_SHORT.
  -- this means that we need to always provide a value for it, either the value
  -- of l_district_id or "ALL"
  add_custom_bind_parameter
  ( p_custom_output
  , '&' || G_DISTRICT_SHORT
  , bis_pmv_parameters_pub.varchar2_bind
  , nvl(l_district_id,'ALL')
  );

  if l_district_id is null then

    -- but we don't want a blind query against district to be run so we
    -- add a "1 = 2" to the query to cause the query to never return
    -- rows.
    l_where_clause := l_where_clause || '
and 1 = 2 /* no district */';

  elsif l_district_id like '%.%' and
        p_trend in ('Y','N') then
    l_where_clause := l_where_clause || '
and fact.parent_district_id = &ISC_FS_PARENT_DISTRICT';
    add_custom_bind_parameter
    ( p_custom_output
    , '&ISC_FS_PARENT_DISTRICT'
    , bis_pmv_parameters_pub.numeric_bind
    , substr(l_district_id, instr(l_district_id,'.')+1)
    );

  end if;

  x_where_clause := l_where_clause;

  if p_trend in ('N', 'K') and
    (p_dimension_tbl.exists(l_view_by)) then
    x_viewby_select := case
                         when l_view_by = G_DISTRICT then
                           p_dimension_tbl(l_view_by).viewby_col_name
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
                               case
                                 when p_dimension_tbl(l_view_by).viewby_id_col_name not like '%.%' then
                                   p_dimension_tbl(l_view_by).dim_table_alias || '.'
                               end ||
                               p_dimension_tbl(l_view_by).viewby_id_col_name
                           end ||
                           ' VIEWBYID'
                       end;

  end if;

  if p_trend in ('N', 'D', 'K') then
    bind_unassigned( p_custom_output );
  end if;

  x_join_tbl := get_join_info(l_view_by, p_dimension_tbl );

  x_dim_bmap := l_dim_bmap;

  x_uom_suffix := case get_parameter_id( p_param, G_DISTANCE_UOM )
                    when 'MILE' then 'mi'
                    else 'km'
                  end;

  bind_distance_factor
  ( p_custom_output
  , x_uom_suffix
  );

end process_parameters;

-- this is an overload of process_parameters that does not return x_uom_suffix
-- as there are many reports already that do not use this parameter.
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

  l_uom_suffix varchar2(30);

begin
  process_parameters
  ( p_param
  , p_dimension_tbl
  , p_dim_filter_map
  , p_trend
  , p_custom_output
  , x_cur_suffix
  , x_where_clause
  , x_viewby_select
  , x_join_tbl
  , x_dim_bmap
  , x_comparison_type
  , x_xtd
  , l_uom_suffix -- throw away this return value
  );
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
, p_percent         in varchar2 default null -- treated as 'Y'
) return varchar2
is
begin
  if nvl(p_percent,'Y') = 'Y' then
    return poa_dbi_util_pkg.change_clause(p_current_column,p_prior_column) ||
           ' ' || p_column_alias;
  end if;
  return poa_dbi_util_pkg.change_clause(p_current_column,p_prior_column,'X') ||
         ' ' || p_column_alias;
end change_column;

-- this is a public function, see the package specification for it's
-- description
function rate_column
( p_numerator       in varchar2
, p_denominator     in varchar2
, p_column_alias    in varchar2
, p_percent         in varchar2 default null -- treated as 'Y'
) return varchar2
is
begin
  return poa_dbi_util_pkg.rate_clause( p_numerator
                                     , p_denominator
                                     , case nvl(p_percent,'Y')
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

-- this is a public function, see the package specification for it's
-- description
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

-- this is a public procedure, see the package specification for it's
-- description
procedure check_district_filter
( p_param     in bis_pmv_page_parameter_tbl
, p_dim_map   in out nocopy poa_dbi_util_pkg.poa_dbi_dim_map
)
is
begin
  null;
end check_district_filter;

-- this is a public function, see the package specification for it's
-- description
function get_inner_select_col
( p_join_tables in poa_dbi_util_pkg.poa_dbi_join_tbl
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

-- this is a public function, see the package specification for it's
-- description
function get_category_drill_down
( p_view_by       in varchar2
, p_function_name in varchar2
, p_column_alias  in varchar2 default null
)
return varchar2
is
begin
  if p_view_by = G_CATEGORY then
    return 'decode(leaf_node_flag, ''Y''' ||
                 ',''pFunctionName=' || p_function_name || '&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=' || G_PRODUCT || '&pParamIds=Y''' ||
                 ',''pFunctionName=' || p_function_name || '&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=' || G_CATEGORY || '&pParamIds=Y''' ||
                 ') ' || p_column_alias;
  end if;

  return 'null ' || p_column_alias;

end get_category_drill_down;

-- this is a public function, see the package specification for it's
-- description
function get_district_drill_down
( p_view_by       in varchar2
, p_function_name in varchar2
, p_column_alias  in varchar2 default null
)
return varchar2
is
  l_drill_enabled constant varchar2(300) := '''pFunctionName=' ||
                                            p_function_name ||
                                            '&pParamIds=Y' ||
                                            '&VIEW_BY_NAME=VIEW_BY_ID&VIEW_BY=' ||
                                            G_DISTRICT || '''';
begin
  if p_view_by = G_DISTRICT then
    -- R12 resource type impact
    -- determine if reached a leaf node in the district hierarchy if
    -- the concatenated id contains '%.%'
    return 'case ' ||
              'when oset.district_id_c like ''%.%'' then null ' ||
              'else ' || l_drill_enabled || ' ' ||
           'end ' || p_column_alias;
  end if;

  return 'null ' || p_column_alias;

end get_district_drill_down;


-- this is a public function, see the package specification for it's
-- description
function get_sr_detail_page_function
( p_sr_id_col in varchar2
)
return varchar2
is

begin

  return '''pFunctionName=CSZ_SR_UP_RO_FN' ||
         '&cszReadOnlySRPageMode=REGULARREADONLY' ||
         -- R12 - no longer need to pass return URL parameters
         --'&cszReadOnlySRRetURL=null' ||
         --'&cszReadOnlySRRetLabel=null' ||
         '&OAPB=BIV_DBI_SR_BRAND' ||
         '&cszIncidentId=''||' || p_sr_id_col;

end get_sr_detail_page_function;

-- this is a public procedure, see the package specification for it's
-- description
procedure add_custom_bind_parameter
( p_custom_output in out nocopy bis_query_attributes_tbl
, p_parameter_name      in varchar2
, p_parameter_data_type in varchar2
, p_parameter_value     in varchar2
)
is

  l_custom_rec BIS_QUERY_ATTRIBUTES;

begin

  if p_custom_output is null then
    p_custom_output := bis_query_attributes_tbl();
  end if;

  l_custom_rec := bis_pmv_parameters_pub.initialize_query_type;

  l_custom_rec.attribute_type := bis_pmv_parameters_pub.bind_type;
  l_custom_rec.attribute_name := p_parameter_name ;
  l_custom_rec.attribute_data_type := p_parameter_data_type;
  l_custom_rec.attribute_value := p_parameter_value;
  p_custom_output.extend;
  p_custom_output(p_custom_output.count) := l_custom_rec;

end add_custom_bind_parameter;

-- this is a public procedure, see the package specification for it's
-- description
procedure bind_low_high
( p_param         in bis_pmv_page_parameter_tbl
, p_param_name    in varchar2
, p_short_name    in varchar2
, p_custom_output in out nocopy bis_query_attributes_tbl
, p_low_token     in varchar2 default null
, p_high_token    in varchar2 default null
)
is

  l_range_low number;
  l_range_high number;

  l_range_id varchar2(10);
  l_bucket_rec bis_bucket_pub.bis_bucket_rec_type;
  l_return_status varchar2(3);
  l_error_tbl bis_utilities_pub.error_tbl_type;

  l_custom_rec BIS_QUERY_ATTRIBUTES;

begin

  l_range_id :=  get_parameter_id
                 ( p_param
                 , p_param_name
                 );

  bis_bucket_pub.retrieve_bis_bucket
  ( p_short_name     => p_short_name
  , x_bis_bucket_rec => l_bucket_rec
  , x_return_status  => l_return_status
  , x_error_tbl      => l_error_tbl
  );

  if l_return_status = 'S' then

    if l_range_id = '1' then
      l_range_low := l_bucket_rec.range1_low;
      l_range_high := l_bucket_rec.range1_high;
    elsif l_range_id = '2' then
      l_range_low := l_bucket_rec.range2_low;
      l_range_high := l_bucket_rec.range2_high;
    elsif l_range_id = '3' then
      l_range_low := l_bucket_rec.range3_low;
      l_range_high := l_bucket_rec.range3_high;
    elsif l_range_id = '4' then
      l_range_low := l_bucket_rec.range4_low;
      l_range_high := l_bucket_rec.range4_high;
    elsif l_range_id = '5' then
      l_range_low := l_bucket_rec.range5_low;
      l_range_high := l_bucket_rec.range5_high;
    elsif l_range_id = '6' then
      l_range_low := l_bucket_rec.range6_low;
      l_range_high := l_bucket_rec.range6_high;
    elsif l_range_id = '7' then
      l_range_low := l_bucket_rec.range7_low;
      l_range_high := l_bucket_rec.range7_high;
    elsif l_range_id = '8' then
      l_range_low := l_bucket_rec.range8_low;
      l_range_high := l_bucket_rec.range8_high;
    elsif l_range_id = '9' then
      l_range_low := l_bucket_rec.range9_low;
      l_range_high := l_bucket_rec.range9_high;
    elsif l_range_id = '10' then
      l_range_low := l_bucket_rec.range10_low;
      l_range_high := l_bucket_rec.range10_high;
    end if;
  end if;

  add_custom_bind_parameter
  ( p_custom_output       => p_custom_output
  , p_parameter_name      => nvl(p_low_token,'&ISC_FS_LOW')
  , p_parameter_data_type => BIS_PMV_PARAMETERS_PUB.INTEGER_BIND
  , p_parameter_value     => nvl(l_range_low, -99999999)
  );

  add_custom_bind_parameter
  ( p_custom_output       => p_custom_output
  , p_parameter_name      => nvl(p_high_token,'&ISC_FS_HIGH')
  , p_parameter_data_type => BIS_PMV_PARAMETERS_PUB.INTEGER_BIND
  , p_parameter_value     => nvl(l_range_high, 99999999)
  );

end bind_low_high;

-- this is a public function, see the package specification for it's
-- description
function get_trend_drill
( p_xtd in varchar2
, p_function_name in varchar2
, p_alias_wtd in varchar2
, p_alias_rlw in varchar2
, p_override_end_date in varchar2 default null
)
return varchar2
is

  l_base_function constant varchar2(200) :=
      '''AS_OF_DATE=''||to_char(' ||
      nvl(p_override_end_date,'cal.end_date') ||
      ',''dd/mm/yyyy'')||''&pFunctionName=' ||
      p_function_name || '&pParamIds=Y&VIEW_BY=TIME+FII_TIME_DAY&FII_TIME_DAY=FII_TIME_DAY'' ';

begin

  return case p_xtd

           when 'WTD' then '
, ' || l_base_function || p_alias_wtd || '
, null ' || p_alias_rlw

           when 'RLW' then '
, null ' || p_alias_wtd || '
, ' || l_base_function || p_alias_rlw

           else '
, null ' || p_alias_wtd || '
, null ' || p_alias_rlw

         end;

end get_trend_drill;

-- this is a public function, see the package specification for it's
-- description
function default_params
( p_region_code   in varchar2
)
return varchar2
is

begin

  return '&AS_OF_DATE=' || fnd_date.date_to_chardate(TRUNC(sysdate)) ||
         '&SEQUENTIAL=TIME_COMPARISON_TYPE+SEQUENTIAL' ||
         '&FII_TIME_WEEK=TIME+FII_TIME_WEEK' ||
         '&JTF_ORG_SALES_GROUP=' || jtf_rs_dbi_conc_pub.get_fsg_id ||
         '&FII_CURRENCIES=FII_GLOBAL1' ||
         '&BIV_FS_DISTANCE_UOM_LVL=KM' ||
         case
           when p_region_code like '%TRD' then
             '&VIEW_BY=TIME+FII_TIME_WEEK'
           when p_region_code like '%TBL' then
             '&VIEW_BY=ORGANIZATION+JTF_ORG_SALES_GROUP'
         end;

end default_params;

-- this is a public procedure, see the package specification for it's
-- description
procedure enhance_time_join
( p_query in out nocopy varchar2
, p_trend in varchar2
)
is

begin

  if p_query like '%fii_time_rpt_struct_v%' then
    if p_trend = 'Y' then
      p_query := replace( p_query
                         , 'fact.time_id = n.time_id'
                         , 'fact.time_id = n.time_id and fact.period_type_id = n.period_type_id'
                         );
    elsif p_trend = 'N' then
      p_query := replace( p_query
                        , 'fact.time_id = cal.time_id'
                        , 'fact.time_id = cal.time_id and fact.period_type_id = cal.period_type_id'
                        );
    end if;
  end if;

  if p_trend = 'N' and
     p_query like '%, (select null id from dual where 1=3) v0%' then
    p_query := replace( p_query
                      , ', (select null id from dual where 1=3) v0'
                      , null
                      );
    p_query := replace( p_query
                      , ' and oset.district_id_c=v0.id(+)'
                      , null
                      );
  end if;

end enhance_time_join;

-- this is a public function, see the package specification for it's
-- description
function get_task_detail_page_function
( p_task_id_col in varchar2
)
return varchar2
is

begin

  return '''pFunctionName=CSF_PO_TASK_DETAILS' ||
         '&OAPB=ISC_FS_DRILL_BRAND' ||
         '&csfPoDbiTaskId=''||' || p_task_id_col;

end get_task_detail_page_function;

-- R12 resource type impact
-- this is a public function, see the package specification for it's
-- description
function get_detail_drill_down
( p_view_by           in varchar2
, p_check_column_name in varchar2
, p_function_name     in varchar2
, p_column_alias      in varchar2 default null
, p_extra_params      in varchar2 default null
, p_check_column      in varchar2 default null
, p_check_resource    in varchar2 default null
)
return varchar2
is
  l_drill_enabled constant varchar2(300) := '''pFunctionName=' ||
                                            p_function_name ||
                                            '&pParamIds=Y&VIEW_BY_NAME=VIEW_BY_ID' ||
                                            p_extra_params || ''' '; -- note trailing space
  l_return varchar2(4000);
  l_check_column constant varchar2(1) := nvl(p_check_column,'N');

begin

  if p_function_name is null then

    l_return := 'null ';

  else

    if p_check_column_name is not null and
       l_check_column = 'Y' then
      l_return := 'decode(nvl(' || p_check_column_name || ',0),0,null,';
    end if;

    if p_view_by = G_DISTRICT then
      -- no detail drill if concatenated id contains '%.-1' -- Unassigned
      -- no detail drill if 'GROUP' and concatenated id contains '%.%'
      l_return := l_return ||
                  'case ' ||
                    'when oset.district_id_c like ''%.-1'' ' ||
                    'or (oset.record_type = ''GROUP'' and oset.district_id_c like ''%.%'') ' ||
                    case
                      when p_check_resource = 'Y' then
                        'or oset.district_id_c not like ''%.%'' '
                    end ||
                  'then null else ' || l_drill_enabled ||
                'end ';
    else
      l_return := l_return || l_drill_enabled;
    end if;

    if p_check_column_name is not null and
       l_check_column = 'Y' then
      l_return := l_return || ') ';
    end if;

  end if;

  if p_column_alias is not null then
    l_return := l_return || p_column_alias;
  end if;

  return l_return;

end get_detail_drill_down;

-- R12 resource type impact
-- this is a public function, see the package specification for it's
-- description
function get_bucket_drill_down
( p_bucket_rec        in bis_bucket_pub.bis_bucket_rec_type
, p_view_by           in varchar2
, p_check_column_name in varchar2
, p_function_name     in varchar2
, p_column_alias      in varchar2
, p_extra_params      in varchar2
, p_check_column      in varchar2 default null
, p_check_resource    in varchar2 default null
)
return varchar2
is

  l_return varchar2(4000);
  l_range_name varchar2(80);

begin

  for i in 1..10 loop

    l_range_name := case i
                      when 1 then p_bucket_rec.range1_name
                      when 2 then p_bucket_rec.range2_name
                      when 3 then p_bucket_rec.range3_name
                      when 4 then p_bucket_rec.range4_name
                      when 5 then p_bucket_rec.range5_name
                      when 6 then p_bucket_rec.range6_name
                      when 7 then p_bucket_rec.range7_name
                      when 8 then p_bucket_rec.range8_name
                      when 9 then p_bucket_rec.range9_name
                      when 10 then p_bucket_rec.range10_name
                    end;

    if l_range_name is not null then
      l_return := case
                    when l_return is not null then
                      l_return || '
, '
                  end || get_detail_drill_down
                         ( p_view_by           => p_view_by
                         , p_function_name     => p_function_name
                         , p_check_column_name => case
                                                    when p_check_column_name is null then null
                                                    else p_check_column_name || '_B' || i
                                                  end
                         , p_column_alias      => p_column_alias || '_B' || i
                         , p_extra_params      => p_extra_params || i
                         , p_check_column      => p_check_column
                         , p_check_resource    => p_check_resource
                         );
    else
      exit; -- loop
    end if;

  end loop;

  return l_return;

end get_bucket_drill_down;

-- this is a public function, see the package specification for it's
-- description
function is_district_leaf_node
( p_param            in bis_pmv_page_parameter_tbl
)
return varchar2
is

  l_district_id  constant varchar2(100) := get_parameter_id
                                           ( p_param
                                           , G_DISTRICT
                                           );

  cursor c_node_count is
    select count(*)
    from isc_fs_002_mv
    where parent_prg_id = to_number(l_district_id);

  l_node_count number;

begin

  if l_district_id like '%.%' then
    return 'Y';
  end if;

  open c_node_count;
  fetch c_node_count into l_node_count;
  close c_node_count;

  if l_node_count > 1 then
    return 'N';
  end if;

  return 'Y';

end is_district_leaf_node;

end isc_fs_rpt_util_pkg;

/
