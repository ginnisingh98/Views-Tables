--------------------------------------------------------
--  DDL for Package BSC_IM_INT_MD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_IM_INT_MD" AUTHID CURRENT_USER AS
/*$Header: BSCIMDUS.pls 115.0 2003/12/09 00:50:27 vsurendr ship $*/

g_debug boolean;
g_stmt varchar2(20000);
g_status_message varchar2(4000);
--==========RECORD TYPES of METADATA TABLES==========================
type im_md_dimensions_r is record(
dim_name varchar2(200),
apps_origin varchar2(80),--BSC or DBI or EDW
description varchar2(800),
property varchar2(10000)
);
type im_md_dimensions_t is table of im_md_dimensions_r;
type im_md_levels_r is record(
level_name varchar2(200),
apps_origin varchar2(80),
dim_name varchar2(80),--fk
number_children number,
description varchar2(800),
property varchar2(10000)
);
type im_md_levels_t is table of im_md_levels_r;
type im_md_columns_r is record(
column_name varchar2(200),
column_type varchar2(80),--pk, uk etc
column_data_type varchar2(200),
apps_origin varchar2(80),
column_origin varchar2(200),--BASE or SUMMARY
aggregation_type varchar2(200),
description varchar2(800),
parent_name varchar2(200),
property varchar2(10000)
);
type im_md_columns_t is table of im_md_columns_r;
type im_md_level_relations_r is record(
child_level varchar2(200),
parent_level varchar2(200),
child_fk  varchar2(200),
parent_pk  varchar2(200),
hier_name varchar2(200),
dim_name varchar2(200),
apps_origin varchar2(80),
property varchar2(10000)
);
type im_md_level_relations_t is table of im_md_level_relations_r;
type im_md_hierarchies_r is record(
hier_name varchar2(200),
dim_name varchar2(200),
apps_origin varchar2(80),
description varchar2(800),
property varchar2(10000)
);
type im_md_hierarchies_t is table of im_md_hierarchies_r;
type im_md_mapping_r is record(
map_name varchar2(200),
apps_origin varchar2(80),
map_type varchar2(200),--BASE OR SUMMARY
object_name varchar2(200),--summary mv name
property varchar2(32000)
);
type im_md_mapping_t is table of im_md_mapping_r;
type im_md_mapping_details_r is record(
map_name varchar2(200),
apps_origin varchar2(80),
line varchar2(32000),
line_type varchar2(80),
property varchar2(32000)
);
type im_md_mapping_details_t is table of im_md_mapping_details_r;
type im_md_cube_r is record(
cube_name varchar2(200),
cube_id number,
cube_periodicity varchar2(400),
apps_origin varchar2(80),
description varchar2(800),
property varchar2(10000)
);
type im_md_cube_t is table of im_md_cube_r;
type im_md_fk_r is record(
fk_name varchar2(200),
fk_type varchar2(40),
owner_name varchar2(200),
uk_name varchar2(200),
uk_parent_name varchar2(200),
description varchar2(800),
apps_origin varchar2(80),
property varchar2(10000)
);
type im_md_fk_t is table of im_md_fk_r;
type im_md_uk_r is record(
uk_name varchar2(200),
uk_type varchar2(40),
description varchar2(800),
owner_name varchar2(200),
apps_origin varchar2(80),
property varchar2(10000)
);
type im_md_uk_t is table of im_md_uk_r;
type im_md_object_r is record(
object_name varchar2(200),
object_type varchar2(200),
apps_origin varchar2(80),
parent_name varchar2(200),--fk
description varchar2(800),
property varchar2(32000)
);
type im_md_object_t is table of im_md_object_r;
--===================================================================

--============logical variable dfns==================================
---init variables-------
im_md_dimensions_i im_md_dimensions_r;
im_md_levels_i im_md_levels_r;
im_md_columns_i im_md_columns_r;
im_md_level_relations_i im_md_level_relations_r;
im_md_hierarchies_i im_md_hierarchies_r;
im_md_mapping_i im_md_mapping_r;
im_md_mapping_details_i im_md_mapping_details_r;
im_md_cube_i im_md_cube_r;
im_md_fk_i im_md_fk_r;
im_md_uk_i im_md_uk_r;
im_md_object_i im_md_object_r;
------------------------
im_md_dimensions im_md_dimensions_t;
number_im_md_dimensions number;
im_md_levels im_md_levels_t;
number_im_md_levels number;
im_md_columns im_md_columns_t;
number_im_md_columns number;
im_md_level_relations im_md_level_relations_t;
number_im_md_level_relations number;
im_md_hierarchies im_md_hierarchies_t;
number_im_md_hierarchies number;
im_md_mapping im_md_mapping_t;
number_im_md_mapping number;
im_md_mapping_details im_md_mapping_details_t;
number_im_md_mapping_details number;
im_md_cube im_md_cube_t;
number_im_md_cube number;
im_md_fk im_md_fk_t;
number_im_md_fk number;
im_md_uk im_md_uk_t;
number_im_md_uk number;
im_md_object im_md_object_t;
number_im_md_object number;
--===================================================================

--functions--------------------------------------------------------
function get_time return varchar2 ;
-------------------------------------------------------------------
--==============================================================================
--**************** PUBLIC CREATE API  ******************************************
function create_dimension(
p_dim_name varchar2,
p_apps_origin varchar2,
p_description varchar2,
p_property varchar2
)return boolean;
function create_level(
p_level_name varchar2,
p_apps_origin varchar2,
p_dim_name varchar2,
p_number_children number,
p_description varchar2,
p_property varchar2
)return boolean;
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
)return boolean;
function create_level_relation(
p_child_level varchar2,
p_parent_level varchar2,
p_child_fk  varchar2,
p_parent_pk  varchar2,
p_hier_name varchar2,
p_dim_name varchar2,
p_apps_origin varchar2,
p_property varchar2
)return boolean;
function create_hierarchy(
p_hier_name varchar2,
p_dim_name varchar2,
p_apps_origin varchar2,
p_description varchar2,
p_property varchar2
)return boolean;
function create_mapping(
p_map_name varchar2,
p_apps_origin varchar2,
p_map_type varchar2,
p_object_name varchar2,
p_property varchar2
)return boolean;
function create_mapping_detail(
p_map_name varchar2,
p_apps_origin varchar2,
p_line varchar2,
p_line_type varchar2,
p_property varchar2
)return boolean;
function create_cube(
p_cube_name varchar2,
p_cube_id number,
p_cube_periodicity varchar2,
p_apps_origin varchar2,
p_description varchar2,
p_property varchar2
)return boolean;
function create_fk(
p_fk_name varchar2,
p_fk_type varchar2,
p_owner_name varchar2,
p_uk_name varchar2,
p_uk_parent_name varchar2,
p_description varchar2,
p_apps_origin varchar2,
p_property varchar2
)return boolean;
function create_uk(
p_uk_name varchar2,
p_uk_type varchar2,
p_description varchar2,
p_owner_name varchar2,
p_apps_origin varchar2,
p_property varchar2
)return boolean;
function create_object(
p_object_name varchar2,
p_object_type varchar2,
p_apps_origin varchar2,
p_parent_name varchar2,
p_description varchar2,
p_property varchar2
)return boolean;
--==============================================================================

--============================PUBLIC DELETE API====================================
procedure reset_int_metadata;
--==============================================================================
--**************** PUBLIC GET API  *********************************************
function get_dimension(
p_dim_name varchar2,
p_apps_origin varchar2,
p_description out nocopy varchar2,
p_property out nocopy varchar2
)return boolean;
function get_level(
p_dim_name varchar2,
p_apps_origin varchar2,
p_level_name out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_children out nocopy BSC_IM_UTILS.number_tabletype,
p_description out nocopy BSC_IM_UTILS.varchar_tabletype,
p_property out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_levels out nocopy number
)return boolean;
function get_dim_for_level(
p_level varchar2,
p_apps_origin varchar2,
p_dim_name out nocopy varchar2) return boolean;
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
)return boolean;
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
)return boolean;
function get_hierarchy(
p_dim_name varchar2,
p_apps_origin varchar2,
p_hier_name out nocopy BSC_IM_UTILS.varchar_tabletype,
p_description out nocopy BSC_im_UTILS.varchar_tabletype,
p_property out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_hierarchy out nocopy number
)return boolean;
function get_mapping(
p_owner_name varchar2,
p_apps_origin varchar2,
p_map_name out nocopy BSC_IM_UTILS.varchar_tabletype,
p_map_type out nocopy BSC_IM_UTILS.varchar_tabletype,
p_object_name out nocopy BSC_IM_UTILS.varchar_tabletype,
p_property out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_mapping out nocopy number
)return boolean;
function get_mapping_detail(
p_map_name varchar2,
p_apps_origin varchar2,
p_line out nocopy BSC_IM_UTILS.varchar_tabletype,
p_line_type out nocopy BSC_IM_UTILS.varchar_tabletype,
p_property out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_map_detail out nocopy number
)return boolean;
function get_cube(
p_cube_name varchar2,
p_apps_origin varchar2,
p_cube_id out nocopy number,
p_cube_periodicity out nocopy varchar2,
p_description out nocopy varchar2,
p_property out nocopy varchar2
)return boolean;
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
)return boolean;
function get_uk(
p_owner_name varchar2,
p_apps_origin varchar2,
p_uk_name out nocopy BSC_IM_UTILS.varchar_tabletype,
p_uk_type out nocopy BSC_IM_UTILS.varchar_tabletype,
p_description out nocopy BSC_IM_UTILS.varchar_tabletype,
p_property out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_uk out nocopy number
)return boolean;
function get_object(
p_parent_name varchar2,
p_apps_origin varchar2,
p_object_name out nocopy BSC_IM_UTILS.varchar_tabletype,
p_object_type out nocopy BSC_IM_UTILS.varchar_tabletype,
p_description out nocopy BSC_IM_UTILS.varchar_tabletype,
p_property out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_object out nocopy number
)return boolean;
function get_object(
p_parent_name varchar2,
p_apps_origin varchar2,
p_property varchar2,
p_object_name out nocopy BSC_IM_UTILS.varchar_tabletype,
p_object_type out nocopy BSC_IM_UTILS.varchar_tabletype,
p_description out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_object out nocopy number
)return boolean;
function get_object(
p_object_name varchar2,
p_apps_origin varchar2,
p_parent_name out nocopy varchar2,
p_object_type out nocopy varchar2,
p_description out nocopy varchar2,
p_property out nocopy varchar2
)return boolean;
--==============================================================================
--==============================================================================
--****************** GET COUNTS ***********************************************
function get_cube_count return number;
--==============================================================================
--==============================================================================
--****************** DEBUG DUMPS ***********************************************
procedure dump_dimension;
procedure dump_level;
procedure dump_column;
procedure dump_level_relation;
procedure dump_hierarchy;
procedure dump_mapping;
procedure dump_mapping_detail;
procedure dump_cube;
procedure dump_fk;
procedure dump_uk;
procedure dump_object;
procedure dump_all;
--==============================================================================
--GENERAL PURPOSE-------------------------------------------------------
procedure write_to_log_file(p_message varchar2);
procedure write_to_log_file_n(p_message varchar2);
procedure write_to_log_file_s(p_message varchar2);
procedure write_to_debug_n(p_message varchar2);
procedure write_to_debug(p_message varchar2);
procedure set_globals(p_debug boolean);
-------------------------------------------------------------------

END BSC_IM_INT_MD;

 

/
