--------------------------------------------------------
--  DDL for Package BSC_AW_MD_API
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_AW_MD_API" AUTHID CURRENT_USER AS
/*$Header: BSCAWMAS.pls 120.8 2006/01/30 16:00 vsurendr noship $*/
--program runtime parameters
g_debug boolean;
g_stmt varchar2(32000);
g_olap_object bsc_aw_md_wrapper.bsc_olap_object_tb;
g_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
----cache--------------------------------------------------------
type olap_object_cache_r is record(
object varchar2(100),
object_type varchar2(100),
parent_object varchar2(100),
parent_object_type varchar2(100),
bsc_olap_object bsc_aw_md_wrapper.bsc_olap_object_tb
);
type olap_object_cache_tb is table of olap_object_cache_r index by pls_integer;
g_oo_cache olap_object_cache_tb;
--
type olap_object_relation_cache_r is record(
object varchar2(100),
object_type varchar2(100),
relation_type varchar2(100),
parent_object varchar2(100),
parent_object_type varchar2(100),
bsc_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb
);
type olap_object_relation_cache_tb is table of olap_object_relation_cache_r index by pls_integer;
g_oor_cache olap_object_relation_cache_tb;
--procedures-------------------------------------------------------
function is_dim_present(
p_dimension varchar2
) return boolean;
procedure get_kpi_for_dim(
p_dim_name varchar2,
p_kpi_list out nocopy dbms_sql.varchar2_table
);
procedure mark_kpi_recreate(p_kpi varchar2);
procedure get_dim_olap_objects(
p_dim_name varchar2,
p_objects out nocopy bsc_aw_md_wrapper.bsc_olap_object_tb,
p_type varchar2
);
procedure drop_dim(p_dim_name varchar2);
procedure get_ccdim_for_levels(
p_dimension bsc_aw_adapter_dim.dimension_r,
p_dim_list out nocopy dbms_sql.varchar2_table
);
procedure create_dim_objects(
p_dimension bsc_aw_adapter_dim.dimension_r
);
function get_level_position(
p_dim_level varchar2
) return number;
procedure drop_kpi(p_kpi varchar2);
procedure get_kpi_olap_objects(
p_kpi varchar2,
p_objects out nocopy bsc_aw_utility.object_tb,
p_type varchar2
);
procedure delete_calendar(p_calendar bsc_aw_calendar.calendar_r);
procedure create_calendar(p_calendar bsc_aw_calendar.calendar_r);
procedure get_dim_for_level(p_level varchar2,p_dim out nocopy varchar2);
procedure get_dim_parent_child(p_dim varchar2,p_parent_child out nocopy bsc_aw_adapter_dim.dim_parent_child_tb);
procedure get_bsc_olap_object(
p_object varchar2,
p_type varchar2,
p_parent_object varchar2,
p_parent_type varchar2,
p_bsc_olap_object out nocopy bsc_aw_md_wrapper.bsc_olap_object_tb
);
procedure get_bsc_olap_object_relation(
p_object varchar2,
p_object_type varchar2,
p_relation_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
p_bsc_olap_object_relation out nocopy bsc_aw_md_wrapper.bsc_olap_object_relation_tb
);
procedure get_dim_for_kpi(
p_kpi varchar2,
p_dim_list out nocopy dbms_sql.varchar2_table
);
procedure create_kpi(p_kpi bsc_aw_adapter_kpi.kpi_r);
procedure get_dim_properties(p_dim in out nocopy bsc_aw_adapter_kpi.dim_r);
procedure get_dim_set_calendar(
p_kpi bsc_aw_adapter_kpi.kpi_r,
p_dim_set in out nocopy bsc_aw_adapter_kpi.dim_set_r
) ;
function is_kpi_present(
p_kpi varchar2
)return boolean;
procedure get_kpi_dimset(
p_kpi varchar2,
p_bsc_olap_object out nocopy bsc_aw_md_wrapper.bsc_olap_object_tb
);
procedure get_dimset_base_table(
p_kpi varchar2,
p_dimset varchar2,
p_base_table_type varchar2,--base table dim set"
p_olap_object_relation out nocopy bsc_aw_md_wrapper.bsc_olap_object_relation_tb
);
procedure get_base_table_dimset(
p_kpi varchar2,
p_base_table varchar2,
p_base_table_type varchar2,--base table dim set"
p_olap_object_relation out nocopy bsc_aw_md_wrapper.bsc_olap_object_relation_tb
);
procedure get_dimset_measure(
p_kpi varchar2,
p_dimset varchar2,
p_measure out nocopy bsc_aw_adapter_kpi.measure_tb
);
procedure get_kpi_dimset_md(
p_kpi varchar2,
p_dimset_name varchar2,
p_dimset out nocopy bsc_aw_adapter_kpi.dim_set_r
);
procedure get_kpi_dimset_dim_md(
p_kpi varchar2,
p_dimset_name varchar2,
p_dim out nocopy bsc_aw_adapter_kpi.dim_tb,
p_std_dim out nocopy bsc_aw_adapter_kpi.dim_tb
);
procedure get_kpi_dimset_dim_md(
p_kpi varchar2,
p_dimset_name varchar2,
p_dim in out nocopy bsc_aw_adapter_kpi.dim_r,
p_dim_type varchar2,
p_level_type varchar2
);
procedure get_kpi_dimset_calendar_md(
p_kpi varchar2,
p_dimset_name varchar2,
p_calendar out nocopy bsc_aw_adapter_kpi.calendar_r
);
procedure get_aggregation_r(p_aggregation in out nocopy bsc_aw_load_kpi.aggregation_r);
procedure create_workspace(p_name varchar2);
procedure drop_workspace(p_name varchar2);
function check_workspace(p_workspace_name varchar2) return varchar2;
procedure get_calendar_properties(p_calendar in out nocopy bsc_aw_adapter_kpi.calendar_r);
procedure update_olap_object(
p_object varchar2,
p_object_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
p_match_columns varchar2, --comma separated
p_match_values varchar2, --comma separated
p_set_columns varchar2, --comma separated
p_set_values varchar2 --^ separated
);
procedure update_olap_object_relation(
p_object varchar2,
p_object_type varchar2,
p_relation_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
p_match_columns varchar2, --comma separated
p_match_values varchar2, --comma separated
p_set_columns varchar2, --comma separated
p_set_values varchar2 --^ separated
);
function is_level_in_dim(
p_dim bsc_aw_adapter_kpi.dim_r,
p_level varchar2) return boolean;
function is_periodicity_in_dim(
p_calendar bsc_aw_adapter_kpi.calendar_r,
p_periodicty_dim varchar2
)return boolean;
procedure get_kpi_dimset_actual(
p_kpi varchar2,
p_bsc_olap_object out nocopy bsc_aw_md_wrapper.bsc_olap_object_tb
);
procedure create_bt_change_vector(p_base_table varchar2);
function get_bt_change_vector(p_base_table varchar2) return number;
procedure update_bt_change_vector(p_base_table varchar2, p_value number);
procedure drop_bt_change_vector(p_base_table varchar2);
procedure get_relation_object(
p_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb,
p_relation_type varchar2,
p_relation_object in out nocopy dbms_sql.varchar2_table
);
procedure get_dimset_comp_PT(
p_kpi varchar2,
p_dimset_name varchar2,
p_partition_template out nocopy bsc_aw_adapter_kpi.partition_template_tb,
p_composite out nocopy bsc_aw_adapter_kpi.composite_tb);
procedure get_dimset_cube_set(
p_kpi varchar2,
p_dimset_name varchar2,
p_cube_set out nocopy bsc_aw_adapter_kpi.cube_set_tb);
procedure get_dimset_cube(
p_kpi varchar2,
p_dimset_name varchar2,
p_cube_set_name varchar2,
p_cube_type varchar2,
p_cube out nocopy bsc_aw_adapter_kpi.cube_r) ;
function get_oo_cache(
p_object varchar2,
p_type varchar2,
p_parent_object varchar2,
p_parent_type varchar2,
p_bsc_olap_object out nocopy bsc_aw_md_wrapper.bsc_olap_object_tb
) return varchar2;
procedure add_oo_cache(
p_object varchar2,
p_type varchar2,
p_parent_object varchar2,
p_parent_type varchar2,
p_bsc_olap_object bsc_aw_md_wrapper.bsc_olap_object_tb
);
function get_oor_cache(
p_object varchar2,
p_object_type varchar2,
p_relation_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
p_bsc_olap_object_relation out nocopy bsc_aw_md_wrapper.bsc_olap_object_relation_tb
) return varchar2;
procedure add_oor_cache(
p_object varchar2,
p_object_type varchar2,
p_relation_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
p_bsc_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb
);
procedure clear_all_cache;
procedure get_dim_md(p_dim_name varchar2,p_dimension out nocopy bsc_aw_adapter_dim.dimension_r);
procedure get_dims_for_level(p_level varchar2,p_dim out nocopy dbms_sql.varchar2_table);
procedure analyze_md_tables;
procedure get_kpi(p_kpi in out nocopy bsc_aw_adapter_kpi.kpi_r);
procedure update_bt_current_period(p_base_table varchar2,p_value varchar2);
function get_bt_current_period(p_base_table varchar2) return varchar2;
procedure insert_olap_object(
p_object varchar2,
p_object_type varchar2,
p_olap_object varchar2,
p_olap_object_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
p_property1 varchar2
);
procedure insert_olap_object_relation(
p_object varchar2,
p_object_type varchar2,
p_relation_object varchar2,
p_relation_object_type varchar2,
p_relation_type varchar2,
p_parent_object varchar2,
p_parent_object_type varchar2,
p_property1 varchar2
);
procedure set_upgrade_version(p_version number);
function get_upgrade_version return number;
--procedures-------------------------------------------------------
procedure init_all;
procedure log(p_message varchar2);
procedure log_n(p_message varchar2);
-------------------------------------------------------------------

END BSC_AW_MD_API;

 

/
