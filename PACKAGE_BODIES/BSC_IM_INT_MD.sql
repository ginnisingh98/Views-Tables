--------------------------------------------------------
--  DDL for Package Body BSC_IM_INT_MD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_IM_INT_MD" AS
/*$Header: BSCIMDUB.pls 115.0 2003/12/09 00:50:15 vsurendr ship $*/

--=================PUBLIC CREATE API============================================
function create_dimension(
p_dim_name varchar2,
p_apps_origin varchar2,
p_description varchar2,
p_property varchar2
)return boolean is
l_found boolean;
l_index number;
Begin
  if number_im_md_dimensions is null then
    number_im_md_dimensions:=0;
    im_md_dimensions:=im_md_dimensions_t(im_md_dimensions_i);
    number_im_md_dimensions:=number_im_md_dimensions+1;
    l_index:=number_im_md_dimensions;
  elsif number_im_md_dimensions>0 then
    l_found:=false;
    for i in 1..number_im_md_dimensions loop
      if im_md_dimensions(i).dim_name=p_dim_name and im_md_dimensions(i).apps_origin=p_apps_origin then
        l_found:=true;
        l_index:=i;
        exit;
      end if;
    end loop;
    if l_found=false then
      im_md_dimensions.extend;
      number_im_md_dimensions:=number_im_md_dimensions+1;
      l_index:=number_im_md_dimensions;
    end if;
  else
    im_md_dimensions.extend;
    number_im_md_dimensions:=number_im_md_dimensions+1;
    l_index:=number_im_md_dimensions;
  end if;
  im_md_dimensions(l_index).dim_name:=p_dim_name;
  im_md_dimensions(l_index).apps_origin:=p_apps_origin;
  im_md_dimensions(l_index).description:=p_description;
  im_md_dimensions(l_index).property:=p_property;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_dimension '||sqlerrm);
  return false;
End;

function create_level(
p_level_name varchar2,
p_apps_origin varchar2,
p_dim_name varchar2,
p_number_children number,
p_description varchar2,
p_property varchar2
)return boolean is
l_found boolean;
l_index number;
Begin
  if number_im_md_levels is null then
    number_im_md_levels:=0;
    im_md_levels:=im_md_levels_t(im_md_levels_i);
    number_im_md_levels:=number_im_md_levels+1;
    l_index:=number_im_md_levels;
  elsif number_im_md_levels>0 then
    l_found:=false;
    for i in 1..number_im_md_levels loop
      if im_md_levels(i).level_name=p_level_name and im_md_levels(i).dim_name=p_dim_name and
        im_md_levels(i).apps_origin=p_apps_origin then
        l_found:=true;
        l_index:=i;
        exit;
      end if;
    end loop;
    if l_found=false then
      im_md_levels.extend;
      number_im_md_levels:=number_im_md_levels+1;
      l_index:=number_im_md_levels;
    end if;
  else
    im_md_levels.extend;
    number_im_md_levels:=number_im_md_levels+1;
    l_index:=number_im_md_levels;
  end if;
  im_md_levels(l_index).level_name:=p_level_name;
  im_md_levels(l_index).apps_origin:=p_apps_origin;
  im_md_levels(l_index).dim_name:=p_dim_name;
  im_md_levels(l_index).number_children:=p_number_children;
  im_md_levels(l_index).description:=p_description;
  im_md_levels(l_index).property:=p_property;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_level '||sqlerrm);
  return false;
End;

function create_column(
p_column_name varchar2,
p_column_type varchar2,
p_column_data_type varchar2,
p_apps_origin varchar2,
p_column_origin varchar2,
p_aggregation_type varchar2,
p_description varchar2,
p_parent_name varchar2,
p_property varchar2
)return boolean is
l_found boolean;
l_index number;
Begin
  if number_im_md_columns is null then
    number_im_md_columns:=0;
    im_md_columns:=im_md_columns_t(im_md_columns_i);
    number_im_md_columns:=number_im_md_columns+1;
    l_index:=number_im_md_columns;
  elsif number_im_md_columns>0 then
    l_found:=false;
    for i in 1..number_im_md_columns loop
      if im_md_columns(i).column_name=p_column_name and im_md_columns(i).apps_origin=p_apps_origin and
        im_md_columns(i).parent_name=p_parent_name then
        l_found:=true;
        l_index:=i;
        exit;
      end if;
    end loop;
    if l_found=false then
      im_md_columns.extend;
      number_im_md_columns:=number_im_md_columns+1;
      l_index:=number_im_md_columns;
    end if;
  else
    im_md_columns.extend;
    number_im_md_columns:=number_im_md_columns+1;
    l_index:=number_im_md_columns;
  end if;
  im_md_columns(l_index).column_name:=p_column_name;
  im_md_columns(l_index).column_type:=p_column_type;
  im_md_columns(l_index).column_data_type:=p_column_data_type;
  im_md_columns(l_index).apps_origin:=p_apps_origin;
  im_md_columns(l_index).column_origin:=p_column_origin;
  im_md_columns(l_index).aggregation_type:=p_aggregation_type;
  im_md_columns(l_index).description:=p_description;
  im_md_columns(l_index).parent_name:=p_parent_name;
  im_md_columns(l_index).property:=p_property;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_column '||sqlerrm);
  return false;
End;

function create_level_relation(
p_child_level varchar2,
p_parent_level varchar2,
p_child_fk  varchar2,
p_parent_pk  varchar2,
p_hier_name varchar2,
p_dim_name varchar2,
p_apps_origin varchar2,
p_property varchar2
)return boolean is
l_found boolean;
l_index number;
Begin
  if number_im_md_level_relations is null then
    number_im_md_level_relations:=0;
    im_md_level_relations:=im_md_level_relations_t(im_md_level_relations_i);
    number_im_md_level_relations:=number_im_md_level_relations+1;
    l_index:=number_im_md_level_relations;
  elsif number_im_md_level_relations>0 then
    l_found:=false;
    for i in 1..number_im_md_level_relations loop
      if im_md_level_relations(i).child_level=p_child_level and im_md_level_relations(i).parent_level=p_parent_level
      and im_md_level_relations(i).hier_name=p_hier_name and im_md_level_relations(i).dim_name=p_dim_name
      and im_md_level_relations(i).apps_origin=p_apps_origin then
        l_found:=true;
        l_index:=i;
        exit;
      end if;
    end loop;
    if l_found=false then
      im_md_level_relations.extend;
      number_im_md_level_relations:=number_im_md_level_relations+1;
      l_index:=number_im_md_level_relations;
    end if;
  else
    im_md_level_relations.extend;
    number_im_md_level_relations:=number_im_md_level_relations+1;
    l_index:=number_im_md_level_relations;
  end if;
  im_md_level_relations(l_index).child_level:=p_child_level;
  im_md_level_relations(l_index).parent_level:=p_parent_level;
  im_md_level_relations(l_index).child_fk:=p_child_fk;
  im_md_level_relations(l_index).parent_pk:=p_parent_pk;
  im_md_level_relations(l_index).hier_name:=p_hier_name;
  im_md_level_relations(l_index).dim_name:=p_dim_name;
  im_md_level_relations(l_index).apps_origin:=p_apps_origin;
  im_md_level_relations(l_index).property:=p_property;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_level_relation '||sqlerrm);
  return false;
End;

function create_hierarchy(
p_hier_name varchar2,
p_dim_name varchar2,
p_apps_origin varchar2,
p_description varchar2,
p_property varchar2
)return boolean is
l_found boolean;
l_index number;
Begin
  if number_im_md_hierarchies is null then
    number_im_md_hierarchies:=0;
    im_md_hierarchies:=im_md_hierarchies_t(im_md_hierarchies_i);
    number_im_md_hierarchies:=number_im_md_hierarchies+1;
    l_index:=number_im_md_hierarchies;
  elsif number_im_md_hierarchies>0 then
    l_found:=false;
    for i in 1..number_im_md_hierarchies loop
      if im_md_hierarchies(i).hier_name=p_hier_name and im_md_hierarchies(i).dim_name=p_dim_name
        and im_md_hierarchies(i).apps_origin=p_apps_origin then
        l_found:=true;
        l_index:=i;
        exit;
      end if;
    end loop;
    if l_found=false then
      im_md_hierarchies.extend;
      number_im_md_hierarchies:=number_im_md_hierarchies+1;
      l_index:=number_im_md_hierarchies;
    end if;
  else
    im_md_hierarchies.extend;
    number_im_md_hierarchies:=number_im_md_hierarchies+1;
    l_index:=number_im_md_hierarchies;
  end if;
  im_md_hierarchies(l_index).hier_name:=p_hier_name;
  im_md_hierarchies(l_index).dim_name:=p_dim_name;
  im_md_hierarchies(l_index).apps_origin:=p_apps_origin;
  im_md_hierarchies(l_index).description:=p_description;
  im_md_hierarchies(l_index).property:=p_property;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_hierarchy '||sqlerrm);
  return false;
End;

function create_mapping(
p_map_name varchar2,
p_apps_origin varchar2,
p_map_type varchar2,
p_object_name varchar2,
p_property varchar2
)return boolean is
l_found boolean;
l_index number;
Begin
  if number_im_md_mapping is null then
    number_im_md_mapping:=0;
    im_md_mapping:=im_md_mapping_t(im_md_mapping_i);
    number_im_md_mapping:=number_im_md_mapping+1;
    l_index:=number_im_md_mapping;
  elsif number_im_md_mapping>0 then
    l_found:=false;
    for i in 1..number_im_md_mapping loop
      if im_md_mapping(i).map_name=p_map_name and im_md_mapping(i).apps_origin=p_apps_origin then
        l_found:=true;
        l_index:=i;
        exit;
      end if;
    end loop;
    if l_found=false then
      im_md_mapping.extend;
      number_im_md_mapping:=number_im_md_mapping+1;
      l_index:=number_im_md_mapping;
    end if;
  else
    im_md_mapping.extend;
    number_im_md_mapping:=number_im_md_mapping+1;
    l_index:=number_im_md_mapping;
  end if;
  im_md_mapping(l_index).map_name:=p_map_name;
  im_md_mapping(l_index).apps_origin:=p_apps_origin;
  im_md_mapping(l_index).map_type:=p_map_type;
  im_md_mapping(l_index).object_name:=p_object_name;
  im_md_mapping(l_index).property:=p_property;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_mapping '||sqlerrm);
  return false;
End;

function create_mapping_detail(
p_map_name varchar2,
p_apps_origin varchar2,
p_line varchar2,
p_line_type varchar2,
p_property varchar2
)return boolean is
l_found boolean;
l_index number;
Begin
  if number_im_md_mapping_details is null then
    number_im_md_mapping_details:=0;
    im_md_mapping_details:=im_md_mapping_details_t(im_md_mapping_details_i);
    number_im_md_mapping_details:=number_im_md_mapping_details+1;
    l_index:=number_im_md_mapping_details;
  elsif number_im_md_mapping_details>0 then
    l_found:=false;
    for i in 1..number_im_md_mapping_details loop
      if im_md_mapping_details(i).map_name=p_map_name and im_md_mapping_details(i).apps_origin=p_apps_origin and
        im_md_mapping_details(i).line=p_line and im_md_mapping_details(i).line_type=p_line_type and
        im_md_mapping_details(i).property=p_property then
        l_found:=true;
        l_index:=i;
        exit;
      end if;
    end loop;
    if l_found=false then
      im_md_mapping_details.extend;
      number_im_md_mapping_details:=number_im_md_mapping_details+1;
      l_index:=number_im_md_mapping_details;
    end if;
  else
    im_md_mapping_details.extend;
    number_im_md_mapping_details:=number_im_md_mapping_details+1;
    l_index:=number_im_md_mapping_details;
  end if;
  im_md_mapping_details(l_index).map_name:=p_map_name;
  im_md_mapping_details(l_index).apps_origin:=p_apps_origin;
  im_md_mapping_details(l_index).line:=p_line;
  im_md_mapping_details(l_index).line_type:=p_line_type;
  im_md_mapping_details(l_index).property:=p_property;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_mapping_detail '||sqlerrm);
  return false;
End;

function create_cube(
p_cube_name varchar2,
p_cube_id number,
p_cube_periodicity varchar2,
p_apps_origin varchar2,
p_description varchar2,
p_property varchar2
)return boolean is
l_found boolean;
l_index number;
Begin
  if number_im_md_cube is null then
    number_im_md_cube:=0;
    im_md_cube:=im_md_cube_t(im_md_cube_i);
    number_im_md_cube:=number_im_md_cube+1;
    l_index:=number_im_md_cube;
  elsif number_im_md_cube>0 then
    l_found:=false;
    for i in 1..number_im_md_cube loop
      if im_md_cube(i).cube_name=p_cube_name and im_md_cube(i).apps_origin=p_apps_origin then
        l_found:=true;
        l_index:=i;
        exit;
      end if;
    end loop;
    if l_found=false then
      im_md_cube.extend;
      number_im_md_cube:=number_im_md_cube+1;
      l_index:=number_im_md_cube;
    end if;
  else
    im_md_cube.extend;
    number_im_md_cube:=number_im_md_cube+1;
    l_index:=number_im_md_cube;
  end if;
  im_md_cube(l_index).cube_name:=p_cube_name;
  im_md_cube(l_index).cube_id:=p_cube_id;
  im_md_cube(l_index).cube_periodicity:=p_cube_periodicity;
  im_md_cube(l_index).apps_origin:=p_apps_origin;
  im_md_cube(l_index).description:=p_description;
  im_md_cube(l_index).property:=p_property;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_cube '||sqlerrm);
  return false;
End;

function create_fk(
p_fk_name varchar2,
p_fk_type varchar2,
p_owner_name varchar2,
p_uk_name varchar2,
p_uk_parent_name varchar2,
p_description varchar2,
p_apps_origin varchar2,
p_property varchar2
)return boolean is
l_found boolean;
l_index number;
Begin
  if number_im_md_fk is null then
    number_im_md_fk:=0;
    im_md_fk:=im_md_fk_t(im_md_fk_i);
    number_im_md_fk:=number_im_md_fk+1;
    l_index:=number_im_md_fk;
  elsif number_im_md_fk>0 then
    l_found:=false;
    for i in 1..number_im_md_fk loop
      if im_md_fk(i).fk_name=p_fk_name and im_md_fk(i).owner_name=p_owner_name
        and im_md_fk(i).apps_origin=p_apps_origin then
        l_found:=true;
        l_index:=i;
        exit;
      end if;
    end loop;
    if l_found=false then
      im_md_fk.extend;
      number_im_md_fk:=number_im_md_fk+1;
      l_index:=number_im_md_fk;
    end if;
  else
    im_md_fk.extend;
    number_im_md_fk:=number_im_md_fk+1;
    l_index:=number_im_md_fk;
  end if;
  im_md_fk(l_index).fk_name:=p_fk_name;
  im_md_fk(l_index).fk_type:=p_fk_type;
  im_md_fk(l_index).uk_name:=p_uk_name;
  im_md_fk(l_index).description:=p_description;
  im_md_fk(l_index).owner_name:=p_owner_name;
  im_md_fk(l_index).uk_parent_name:=p_uk_parent_name;
  im_md_fk(l_index).apps_origin:=p_apps_origin;
  im_md_fk(l_index).property:=p_property;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_fk '||sqlerrm);
  return false;
End;

function create_uk(
p_uk_name varchar2,
p_uk_type varchar2,
p_description varchar2,
p_owner_name varchar2,
p_apps_origin varchar2,
p_property varchar2
)return boolean is
l_found boolean;
l_index number;
Begin
  if number_im_md_uk is null then
    number_im_md_uk:=0;
    im_md_uk:=im_md_uk_t(im_md_uk_i);
    number_im_md_uk:=number_im_md_uk+1;
    l_index:=number_im_md_uk;
  elsif number_im_md_uk>0 then
    l_found:=false;
    for i in 1..number_im_md_uk loop
      if im_md_uk(i).uk_name=p_uk_name and im_md_uk(i).owner_name=p_owner_name
        and im_md_uk(i).apps_origin=p_apps_origin then
        l_found:=true;
        l_index:=i;
        exit;
      end if;
    end loop;
    if l_found=false then
      im_md_uk.extend;
      number_im_md_uk:=number_im_md_uk+1;
      l_index:=number_im_md_uk;
    end if;
  else
    im_md_uk.extend;
    number_im_md_uk:=number_im_md_uk+1;
    l_index:=number_im_md_uk;
  end if;
  im_md_uk(l_index).uk_name:=p_uk_name;
  im_md_uk(l_index).uk_type:=p_uk_type;
  im_md_uk(l_index).description:=p_description;
  im_md_uk(l_index).owner_name:=p_owner_name;
  im_md_uk(l_index).apps_origin:=p_apps_origin;
  im_md_uk(l_index).property:=p_property;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_uk '||sqlerrm);
  return false;
End;

function create_object(
p_object_name varchar2,
p_object_type varchar2,
p_apps_origin varchar2,
p_parent_name varchar2,
p_description varchar2,
p_property varchar2
)return boolean is
l_found boolean;
l_index number;
Begin
  if number_im_md_object is null then
    number_im_md_object:=0;
    im_md_object:=im_md_object_t(im_md_object_i);
    number_im_md_object:=number_im_md_object+1;
    l_index:=number_im_md_object;
  elsif number_im_md_object>0 then
    l_found:=false;
    for i in 1..number_im_md_object loop
      if im_md_object(i).object_name=p_object_name and im_md_object(i).apps_origin=p_apps_origin and
        im_md_object(i).object_type=p_object_type and im_md_object(i).property=p_property and
        im_md_object(i).parent_name=p_parent_name then
        l_found:=true;
        l_index:=i;
        exit;
      end if;
    end loop;
    if l_found=false then
      im_md_object.extend;
      number_im_md_object:=number_im_md_object+1;
      l_index:=number_im_md_object;
    end if;
  else
    im_md_object.extend;
    number_im_md_object:=number_im_md_object+1;
    l_index:=number_im_md_object;
  end if;
  im_md_object(l_index).object_name:=p_object_name;
  im_md_object(l_index).object_type:=p_object_type;
  im_md_object(l_index).apps_origin:=p_apps_origin;
  im_md_object(l_index).parent_name:=p_parent_name;
  im_md_object(l_index).description:=p_description;
  im_md_object(l_index).property:=p_property;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_object '||sqlerrm);
  return false;
End;

--==============================================================================

--============================PUBLIC DELETE API=================================
procedure reset_int_metadata is
Begin
  if number_im_md_dimensions>0 then
    im_md_dimensions.delete;
  end if;
  number_im_md_dimensions:=null;
  if number_im_md_levels>0 then
    im_md_levels.delete;
  end if;
  number_im_md_levels:=null;
  if number_im_md_columns>0 then
    im_md_columns.delete;
  end if;
  number_im_md_columns:=null;
  if number_im_md_level_relations>0 then
    im_md_level_relations.delete;
  end if;
  number_im_md_level_relations:=null;
  if number_im_md_hierarchies>0 then
    im_md_hierarchies.delete;
  end if;
  number_im_md_hierarchies:=null;
  if number_im_md_mapping>0 then
    im_md_mapping.delete;
  end if;
  number_im_md_mapping:=null;
  if number_im_md_mapping_details>0 then
    im_md_mapping_details.delete;
  end if;
  number_im_md_mapping_details:=null;
  if number_im_md_cube>0 then
    im_md_cube.delete;
  end if;
  number_im_md_cube:=null;
  if number_im_md_fk>0 then
    im_md_fk.delete;
  end if;
  number_im_md_fk:=null;
  if number_im_md_uk>0 then
    im_md_uk.delete;
  end if;
  number_im_md_uk:=null;
  if number_im_md_object>0 then
    im_md_object.delete;
  end if;
  number_im_md_object:=null;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in reset_int_metadata '||sqlerrm);
  raise;
End;
--==============================================================================

--============================PUBLIC GET API====================================
function get_dimension(
p_dim_name varchar2,
p_apps_origin varchar2,
p_description out nocopy varchar2,
p_property out nocopy varchar2
)return boolean is
Begin
  if number_im_md_dimensions is null then
    return true;
  end if;
  for i in 1..number_im_md_dimensions loop
    if im_md_dimensions(i).dim_name=p_dim_name and im_md_dimensions(i).apps_origin=p_apps_origin then
      p_description:=im_md_dimensions(i).description;
      p_property:=im_md_dimensions(i).property;
      exit;
    end if;
  end loop;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_dimension '||sqlerrm);
  return false;
End;

function get_level(
p_dim_name varchar2,
p_apps_origin varchar2,
p_level_name out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_children out nocopy BSC_IM_UTILS.number_tabletype,
p_description out nocopy BSC_IM_UTILS.varchar_tabletype,
p_property out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_levels out nocopy number
)return boolean is
Begin
  p_number_levels:=0;
  if number_im_md_levels is null then
    return true;
  end if;
  for i in 1..number_im_md_levels loop
    if im_md_levels(i).dim_name=p_dim_name and im_md_levels(i).apps_origin=p_apps_origin then
      p_number_levels:=p_number_levels+1;
      p_level_name(p_number_levels):=im_md_levels(i).level_name;
      p_number_children(p_number_levels):=im_md_levels(i).number_children;
      p_description(p_number_levels):=im_md_levels(i).description;
      p_property(p_number_levels):=im_md_levels(i).property;
    end if;
  end loop;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_level '||sqlerrm);
  return false;
End;

function get_dim_for_level(
p_level varchar2,
p_apps_origin varchar2,
p_dim_name out nocopy varchar2) return boolean is
Begin
  if number_im_md_levels is null then
    return true;
  end if;
  for i in 1..number_im_md_levels loop
    if im_md_levels(i).level_name=p_level and im_md_levels(i).apps_origin=p_apps_origin then
      p_dim_name:=im_md_levels(i).dim_name;
      exit;
    end if;
  end loop;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_dim_for_level '||sqlerrm);
  return false;
End;

function get_column(
p_parent_name varchar2,
p_apps_origin varchar2,
p_column_name out nocopy BSC_IM_UTILS.varchar_tabletype,
p_column_type out nocopy BSC_IM_UTILS.varchar_tabletype,
p_column_data_type out nocopy BSC_IM_UTILS.varchar_tabletype,
p_column_origin out nocopy BSC_IM_UTILS.varchar_tabletype,
p_aggregation_type out nocopy BSC_IM_UTILS.varchar_tabletype,
p_description out nocopy BSC_IM_UTILS.varchar_tabletype,
p_property out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_columns out nocopy number
)return boolean is
Begin
  p_number_columns:=0;
  if number_im_md_columns is null then
    return true;
  end if;
  for i in 1..number_im_md_columns loop
    if im_md_columns(i).parent_name=p_parent_name and im_md_columns(i).apps_origin=p_apps_origin then
      p_number_columns:=p_number_columns+1;
      p_column_name(p_number_columns):=im_md_columns(i).column_name;
      p_column_type(p_number_columns):=im_md_columns(i).column_type;
      p_column_data_type(p_number_columns):=im_md_columns(i).column_data_type;
      p_column_origin(p_number_columns):=im_md_columns(i).column_origin;
      p_aggregation_type(p_number_columns):=im_md_columns(i).aggregation_type;
      p_description(p_number_columns):=im_md_columns(i).description;
      p_property(p_number_columns):=im_md_columns(i).property;
    end if;
  end loop;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_column '||sqlerrm);
  return false;
End;

function get_level_relation(
p_dim_name varchar2,
p_apps_origin varchar2,
p_child_level out nocopy BSC_IM_UTILS.varchar_tabletype,
p_parent_level out nocopy BSC_IM_UTILS.varchar_tabletype,
p_child_fk  out nocopy BSC_IM_UTILS.varchar_tabletype,
p_parent_pk  out nocopy BSC_IM_UTILS.varchar_tabletype,
p_hier_name out nocopy BSC_IM_UTILS.varchar_tabletype,
p_property out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_level_relations out nocopy number
)return boolean is
Begin
  p_number_level_relations:=0;
  if number_im_md_level_relations is null then
    return true;
  end if;
  for i in 1..number_im_md_level_relations loop
    if im_md_level_relations(i).dim_name=p_dim_name and im_md_level_relations(i).apps_origin=p_apps_origin then
      p_number_level_relations:=p_number_level_relations+1;
      p_child_level(p_number_level_relations):=im_md_level_relations(i).child_level;
      p_parent_level(p_number_level_relations):=im_md_level_relations(i).parent_level;
      p_child_fk(p_number_level_relations):=im_md_level_relations(i).child_fk;
      p_parent_pk(p_number_level_relations):=im_md_level_relations(i).parent_pk;
      p_hier_name(p_number_level_relations):=im_md_level_relations(i).hier_name;
      p_property(p_number_level_relations):=im_md_level_relations(i).property;
    end if;
  end loop;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_level_relation '||sqlerrm);
  return false;
End;

function get_hierarchy(
p_dim_name varchar2,
p_apps_origin varchar2,
p_hier_name out nocopy BSC_IM_UTILS.varchar_tabletype,
p_description out nocopy BSC_im_UTILS.varchar_tabletype,
p_property out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_hierarchy out nocopy number
)return boolean is
Begin
  p_number_hierarchy:=0;
  if number_im_md_hierarchies is null then
    return true;
  end if;
  for i in 1..number_im_md_hierarchies loop
    if im_md_hierarchies(i).dim_name=p_dim_name and im_md_hierarchies(i).apps_origin=p_apps_origin then
      p_number_hierarchy:=p_number_hierarchy+1;
      p_hier_name(p_number_hierarchy):=im_md_hierarchies(i).hier_name;
      p_description(p_number_hierarchy):=im_md_hierarchies(i).description;
      p_property(p_number_hierarchy):=im_md_hierarchies(i).property;
    end if;
  end loop;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_hierarchy '||sqlerrm);
  return false;
End;

function get_mapping(
p_owner_name varchar2,
p_apps_origin varchar2,
p_map_name out nocopy BSC_IM_UTILS.varchar_tabletype,
p_map_type out nocopy BSC_IM_UTILS.varchar_tabletype,
p_object_name out nocopy BSC_IM_UTILS.varchar_tabletype,
p_property out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_mapping out nocopy number
)return boolean is
Begin
  p_number_mapping:=0;
  if number_im_md_mapping is null then
    return true;
  end if;
  for i in 1..number_im_md_mapping loop
    if im_md_mapping(i).apps_origin=p_apps_origin and im_md_mapping(i).object_name=p_owner_name then
      p_number_mapping:=p_number_mapping+1;
      p_map_name(p_number_mapping):=im_md_mapping(i).map_name;
      p_map_type(p_number_mapping):=im_md_mapping(i).map_type;
      p_object_name(p_number_mapping):=im_md_mapping(i).object_name;
      p_property(p_number_mapping):=im_md_mapping(i).property;
    end if;
  end loop;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_mapping '||sqlerrm);
  return false;
End;

function get_mapping_detail(
p_map_name varchar2,
p_apps_origin varchar2,
p_line out nocopy BSC_IM_UTILS.varchar_tabletype,
p_line_type out nocopy BSC_IM_UTILS.varchar_tabletype,
p_property out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_map_detail out nocopy number
)return boolean is
Begin
  p_number_map_detail:=0;
  if number_im_md_mapping_details is null then
    return true;
  end if;
  for i in 1..number_im_md_mapping_details loop
    if im_md_mapping_details(i).map_name=p_map_name and im_md_mapping_details(i).apps_origin=p_apps_origin then
      p_number_map_detail:=p_number_map_detail+1;
      p_line(p_number_map_detail):=im_md_mapping_details(i).line;
      p_line_type(p_number_map_detail):=im_md_mapping_details(i).line_type;
      p_property(p_number_map_detail):=im_md_mapping_details(i).property;
    end if;
  end loop;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_mapping_detail '||sqlerrm);
  return false;
End;

function get_cube(
p_cube_name varchar2,
p_apps_origin varchar2,
p_cube_id out nocopy number,
p_cube_periodicity out nocopy varchar2,
p_description out nocopy varchar2,
p_property out nocopy varchar2
)return boolean is
Begin
  if number_im_md_cube is null then
    return true;
  end if;
  for i in 1..number_im_md_cube loop
    if im_md_cube(i).cube_name=p_cube_name and im_md_cube(i).apps_origin=p_apps_origin then
      p_cube_id:=im_md_cube(i).cube_id;
      p_cube_periodicity:=im_md_cube(i).cube_periodicity;
      p_description:=im_md_cube(i).description;
      p_property:=im_md_cube(i).property;
      exit;
    end if;
  end loop;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_cube '||sqlerrm);
  return false;
End;

function get_fk(
p_owner_name varchar2,
p_apps_origin varchar2,
p_fk_name out nocopy BSC_IM_UTILS.varchar_tabletype,
p_fk_type out nocopy BSC_IM_UTILS.varchar_tabletype,
p_uk_name out nocopy BSC_IM_UTILS.varchar_tabletype,
p_uk_parent_name out nocopy BSC_IM_UTILS.varchar_tabletype,
p_description out nocopy BSC_IM_UTILS.varchar_tabletype,
p_property out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_fk out nocopy number
)return boolean is
Begin
  p_number_fk:=0;
  if number_im_md_fk is null then
    return true;
  end if;
  for i in 1..number_im_md_fk loop
    if im_md_fk(i).owner_name=p_owner_name and im_md_fk(i).apps_origin=p_apps_origin then
      p_number_fk:=p_number_fk+1;
      p_fk_name(p_number_fk):=im_md_fk(i).fk_name;
      p_fk_type(p_number_fk):=im_md_fk(i).fk_type;
      p_uk_name(p_number_fk):=im_md_fk(i).uk_name;
      p_description(p_number_fk):=im_md_fk(i).description;
      p_uk_parent_name(p_number_fk):=im_md_fk(i).uk_parent_name;
      p_property(p_number_fk):=im_md_fk(i).property;
    end if;
  end loop;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_fk '||sqlerrm);
  return false;
End;

function get_uk(
p_owner_name varchar2,
p_apps_origin varchar2,
p_uk_name out nocopy BSC_IM_UTILS.varchar_tabletype,
p_uk_type out nocopy BSC_IM_UTILS.varchar_tabletype,
p_description out nocopy BSC_IM_UTILS.varchar_tabletype,
p_property out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_uk out nocopy number
)return boolean is
Begin
  p_number_uk:=0;
  if number_im_md_uk is null then
    return true;
  end if;
  for i in 1..number_im_md_uk loop
    if im_md_uk(i).owner_name=p_owner_name and im_md_uk(i).apps_origin=p_apps_origin then
      p_number_uk:=p_number_uk+1;
      p_uk_name(p_number_uk):=im_md_uk(i).uk_name;
      p_uk_type(p_number_uk):=im_md_uk(i).uk_type;
      p_description(p_number_uk):=im_md_uk(i).description;
      p_property(p_number_uk):=im_md_uk(i).property;
    end if;
  end loop;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_uk '||sqlerrm);
  return false;
End;

function get_object(
p_parent_name varchar2,
p_apps_origin varchar2,
p_object_name out nocopy BSC_IM_UTILS.varchar_tabletype,
p_object_type out nocopy BSC_IM_UTILS.varchar_tabletype,
p_description out nocopy BSC_IM_UTILS.varchar_tabletype,
p_property out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_object out nocopy number
)return boolean is
Begin
  p_number_object:=0;
  if number_im_md_object is null then
    return true;
  end if;
  for i in 1..number_im_md_object loop
    if im_md_object(i).parent_name=p_parent_name and im_md_object(i).apps_origin=p_apps_origin then
      p_number_object:=p_number_object+1;
      p_object_name(p_number_object):=im_md_object(i).object_name;
      p_object_type(p_number_object):=im_md_object(i).object_type;
      p_description(p_number_object):=im_md_object(i).description;
      p_property(p_number_object):=im_md_object(i).property;
    end if;
  end loop;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_object '||sqlerrm);
  return false;
End;

function get_object(
p_parent_name varchar2,
p_apps_origin varchar2,
p_property varchar2,
p_object_name out nocopy BSC_IM_UTILS.varchar_tabletype,
p_object_type out nocopy BSC_IM_UTILS.varchar_tabletype,
p_description out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_object out nocopy number
)return boolean is
Begin
  p_number_object:=0;
  if number_im_md_object is null then
    return true;
  end if;
  for i in 1..number_im_md_object loop
    if im_md_object(i).parent_name=p_parent_name and im_md_object(i).apps_origin=p_apps_origin and
      im_md_object(i).property=p_property then
      p_number_object:=p_number_object+1;
      p_object_name(p_number_object):=im_md_object(i).object_name;
      p_object_type(p_number_object):=im_md_object(i).object_type;
      p_description(p_number_object):=im_md_object(i).description;
    end if;
  end loop;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_object '||sqlerrm);
  return false;
End;

function get_object(
p_object_name varchar2,
p_apps_origin varchar2,
p_parent_name out nocopy varchar2,
p_object_type out nocopy varchar2,
p_description out nocopy varchar2,
p_property out nocopy varchar2
)return boolean is
Begin
  if number_im_md_object is null then
    return true;
  end if;
  for i in 1..number_im_md_object loop
    if im_md_object(i).object_name=p_object_name and im_md_object(i).apps_origin=p_apps_origin then
      p_parent_name:=im_md_object(i).parent_name;
      p_object_type:=im_md_object(i).object_type;
      p_description:=im_md_object(i).description;
      p_property:=im_md_object(i).property;
      exit;
    end if;
  end loop;
  return true;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_object '||sqlerrm);
  return false;
End;

function get_object_type(p_object varchar2) return varchar2 is
Begin
  --dim
  if number_im_md_dimensions is not null then
    for i in 1..number_im_md_dimensions loop
      if im_md_dimensions(i).dim_name=p_object then
        return 'DIMENSION';
      end if;
    end loop;
  end if;
  --level
  if number_im_md_levels is not null then
    for i in 1..number_im_md_levels loop
      if im_md_levels(i).level_name=p_object then
        return 'LEVEL';
      end if;
    end loop;
  end if;
  --hier
  if number_im_md_hierarchies is not null then
    for i in 1..number_im_md_hierarchies loop
      if im_md_hierarchies(i).hier_name=p_object then
        return 'HIERARCHY';
      end if;
    end loop;
  end if;
  --mapping
  if number_im_md_mapping is not null then
    for i in 1..number_im_md_mapping loop
      if im_md_mapping(i).map_name=p_object then
        return 'MAPPING';
      end if;
    end loop;
  end if;
  --cube
  if number_im_md_cube is not null then
    for i in 1..number_im_md_cube loop
      if im_md_cube(i).cube_name=p_object then
        return 'CUBE';
      end if;
    end loop;
  end if;
  --object
  if number_im_md_object is not null then
    for i in 1..number_im_md_object loop
      if im_md_object(i).object_name=p_object then
        return 'OBJECT';
      end if;
    end loop;
  end if;
  --fk
  if number_im_md_fk is not null then
    for i in 1..number_im_md_fk loop
      if im_md_fk(i).fk_name=p_object then
        return 'FK';
      end if;
    end loop;
  end if;
  --uk
  if number_im_md_uk is not null then
    for i in 1..number_im_md_uk loop
      if im_md_uk(i).uk_name=p_object then
        return 'UK';
      end if;
    end loop;
  end if;
  return 'OTHER';
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_object_type '||sqlerrm);
  return null;
End;

--==============================================================================
--****************** GET COUNTS ***********************************************
function get_cube_count return number is
Begin
  if number_im_md_cube is null then
    return 0;
  else
    return number_im_md_cube;
  end if;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_object_type '||sqlerrm);
  return null;
End;

--==============================================================================
--****************** DEBUG DUMPS ***********************************************
procedure dump_dimension is
Begin
  write_to_log_file_n('Dump dimension');
  if number_im_md_dimensions is null then
    return;
  end if;
  write_to_log_file('dim_name apps_origin description property');
  for i in 1..number_im_md_dimensions loop
    write_to_log_file_s(im_md_dimensions(i).dim_name);
    write_to_log_file_s(im_md_dimensions(i).apps_origin);
    write_to_log_file_s(im_md_dimensions(i).description);
    write_to_log_file_s(im_md_dimensions(i).property);
    write_to_log_file(' ');
  end loop;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in dump_dimension '||sqlerrm);
End;

procedure dump_level is
Begin
  write_to_log_file_n('Level level');
  if number_im_md_levels is null then
    return;
  end if;
  write_to_log_file('dim_name apps_origin level_name number_children description property');
  for i in 1..number_im_md_levels loop
    write_to_log_file_s(im_md_levels(i).dim_name);
    write_to_log_file_s(im_md_levels(i).apps_origin);
    write_to_log_file_s(im_md_levels(i).level_name);
    write_to_log_file_s(im_md_levels(i).number_children);
    write_to_log_file_s(im_md_levels(i).description);
    write_to_log_file_s(im_md_levels(i).property);
    write_to_log_file(' ');
  end loop;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in dump_level '||sqlerrm);
End;

procedure dump_column is
Begin
  write_to_log_file_n('dump columns');
  if number_im_md_columns is null then
    return;
  end if;
  write_to_log_file('parent_name apps_origin column_name column_type column_data_type '||
  'column_origin aggregation_type description property');
  for i in 1..number_im_md_columns loop
    write_to_log_file_s(im_md_columns(i).parent_name);
    write_to_log_file_s(im_md_columns(i).apps_origin);
    write_to_log_file_s(im_md_columns(i).column_name);
    write_to_log_file_s(im_md_columns(i).column_type);
    write_to_log_file_s(im_md_columns(i).column_data_type);
    write_to_log_file_s(im_md_columns(i).column_origin);
    write_to_log_file_s(im_md_columns(i).aggregation_type);
    write_to_log_file_s(im_md_columns(i).description);
    write_to_log_file_s(im_md_columns(i).property);
    write_to_log_file(' ');
  end loop;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in dump_column '||sqlerrm);
End;

procedure dump_level_relation is
Begin
  write_to_log_file_n('dump level relations');
  if number_im_md_level_relations is null then
    return;
  end if;
  write_to_log_file('dim_name apps_origin child_level parent_level child_fk parent_pk hier_name property');
  for i in 1..number_im_md_level_relations loop
    write_to_log_file_s(im_md_level_relations(i).dim_name);
    write_to_log_file_s(im_md_level_relations(i).apps_origin);
    write_to_log_file_s(im_md_level_relations(i).child_level);
    write_to_log_file_s(im_md_level_relations(i).parent_level);
    write_to_log_file_s(im_md_level_relations(i).child_fk);
    write_to_log_file_s(im_md_level_relations(i).parent_pk);
    write_to_log_file_s(im_md_level_relations(i).hier_name);
    write_to_log_file_s(im_md_level_relations(i).property);
    write_to_log_file(' ');
  end loop;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in dump_level_relation '||sqlerrm);
End;

procedure dump_hierarchy is
Begin
  write_to_log_file_n('dump hierarchy');
  if number_im_md_hierarchies is null then
    return;
  end if;
  write_to_log_file('dim_name apps_origin hier_name description property');
  for i in 1..number_im_md_hierarchies loop
    write_to_log_file_s(im_md_hierarchies(i).dim_name);
    write_to_log_file_s(im_md_hierarchies(i).apps_origin);
    write_to_log_file_s(im_md_hierarchies(i).hier_name);
    write_to_log_file_s(im_md_hierarchies(i).description);
    write_to_log_file_s(im_md_hierarchies(i).property);
    write_to_log_file(' ');
  end loop;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in dump_hierarchy '||sqlerrm);
End;

procedure dump_mapping is
Begin
  write_to_log_file_n('dump mapping');
  if number_im_md_mapping is null then
    return;
  end if;
  write_to_log_file('apps_origin object_name map_name map_type object_name property');
  for i in 1..number_im_md_mapping loop
    write_to_log_file_s(im_md_mapping(i).apps_origin);
    write_to_log_file_s(im_md_mapping(i).object_name);
    write_to_log_file_s(im_md_mapping(i).map_name);
    write_to_log_file_s(im_md_mapping(i).map_type);
    write_to_log_file_s(im_md_mapping(i).object_name);
    write_to_log_file_s(im_md_mapping(i).property);
    write_to_log_file(' ');
  end loop;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in dump_mapping '||sqlerrm);
End;

procedure dump_mapping_detail is
Begin
  write_to_log_file_n('dump mapping detail');
  if number_im_md_mapping_details is null then
    return;
  end if;
  write_to_log_file('map_name apps_origin line line_type property');
  for i in 1..number_im_md_mapping_details loop
    write_to_log_file_s(im_md_mapping_details(i).map_name);
    write_to_log_file_s(im_md_mapping_details(i).apps_origin);
    write_to_log_file_s(im_md_mapping_details(i).line);
    write_to_log_file_s(im_md_mapping_details(i).line_type);
    write_to_log_file_s(im_md_mapping_details(i).property);
    write_to_log_file(' ');
  end loop;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in dump_mapping_detail '||sqlerrm);
End;

procedure dump_cube is
Begin
  write_to_log_file_n('dump cube');
  if number_im_md_cube is null then
    return;
  end if;
  write_to_log_file('cube_name apps_origin cube_id cube_periodicity description property');
  for i in 1..number_im_md_cube loop
    write_to_log_file_s(im_md_cube(i).cube_name);
    write_to_log_file_s(im_md_cube(i).apps_origin);
    write_to_log_file_s(im_md_cube(i).cube_id);
    write_to_log_file_s(im_md_cube(i).cube_periodicity);
    write_to_log_file_s(im_md_cube(i).description);
    write_to_log_file_s(im_md_cube(i).property);
    write_to_log_file(' ');
  end loop;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in dump_cube '||sqlerrm);
End;

procedure dump_fk is
Begin
  write_to_log_file_n('dump fk');
  if number_im_md_fk is null then
    return;
  end if;
  write_to_log_file('owner_name apps_origin fk_name fk_type uk_name description uk_parent_name'||
  'top_parent_name property');
  for i in 1..number_im_md_fk loop
    write_to_log_file_s(im_md_fk(i).owner_name);
    write_to_log_file_s(im_md_fk(i).apps_origin);
    write_to_log_file_s(im_md_fk(i).fk_name);
    write_to_log_file_s(im_md_fk(i).fk_type);
    write_to_log_file_s(im_md_fk(i).uk_name);
    write_to_log_file_s(im_md_fk(i).description);
    write_to_log_file_s(im_md_fk(i).uk_parent_name);
    write_to_log_file_s(im_md_fk(i).property);
    write_to_log_file(' ');
  end loop;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in dump_fk '||sqlerrm);
End;

procedure dump_uk is
Begin
  write_to_log_file_n('dump uk');
  if number_im_md_uk is null then
    return;
  end if;
  write_to_log_file('owner_name apps_origin uk_name uk_type description property');
  for i in 1..number_im_md_uk loop
    write_to_log_file_s(im_md_uk(i).owner_name);
    write_to_log_file_s(im_md_uk(i).apps_origin);
    write_to_log_file_s(im_md_uk(i).uk_name);
    write_to_log_file_s(im_md_uk(i).uk_type);
    write_to_log_file_s(im_md_uk(i).description);
    write_to_log_file_s(im_md_uk(i).property);
    write_to_log_file(' ');
  end loop;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in dump_uk '||sqlerrm);
End;

procedure dump_object is
Begin
  write_to_log_file_n('dump object');
  if number_im_md_object is null then
    return;
  end if;
  write_to_log_file('parent_name apps_origin object_name object_type description property');
  for i in 1..number_im_md_object loop
    write_to_log_file_s(im_md_object(i).parent_name);
    write_to_log_file_s(im_md_object(i).apps_origin);
    write_to_log_file_s(im_md_object(i).object_name);
    write_to_log_file_s(im_md_object(i).object_type);
    write_to_log_file_s(im_md_object(i).description);
    write_to_log_file_s(im_md_object(i).property);
    write_to_log_file(' ');
  end loop;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in dump_object '||sqlerrm);
End;

procedure dump_all is
Begin
  dump_dimension;
  dump_level;
  dump_column;
  dump_level_relation;
  dump_hierarchy;
  dump_mapping;
  dump_mapping_detail;
  dump_cube;
  dump_fk;
  dump_uk;
  dump_object;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in dump_all '||sqlerrm);
End;


--==============================================================================
procedure write_to_log_file(p_message varchar2) is
Begin
  BSC_IM_UTILS.write_to_log_file(p_message);
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  null;
End;

procedure write_to_log_file_s(p_message varchar2) is
Begin
  BSC_IM_UTILS.write_to_log_file_s(p_message);
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  null;
End;

procedure write_to_log_file_n(p_message varchar2) is
begin
  write_to_log_file('  ');
  write_to_log_file(p_message);
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  null;
end;

procedure write_to_debug_n(p_message varchar2) is
begin
  if g_debug then
    write_to_log_file_n(p_message);
  end if;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  null;
end;

procedure write_to_debug(p_message varchar2) is
begin
  if g_debug then
    write_to_log_file(p_message);
  end if;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  null;
end;

function get_time return varchar2 is
begin
  return ' '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS');
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  null;
End;

procedure set_globals(p_debug boolean) is
Begin
  g_debug:=p_debug;
Exception when others then
  BSC_IM_UTILS.g_status_message:=sqlerrm;
  write_to_log_file_n('Error in set_globals '||sqlerrm);
End;


END BSC_IM_INT_MD;

/
