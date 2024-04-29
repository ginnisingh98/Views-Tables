--------------------------------------------------------
--  DDL for Package BSC_METADATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_METADATA" AUTHID CURRENT_USER AS
/*$Header: BSCMTDTS.pls 120.9 2006/01/20 18:00 vsurendr noship $*/
--program runtime parameters
g_debug boolean;
g_stmt varchar2(32000);
--procedures-------------------------------------------------------
procedure get_parent_level(
p_level varchar2,
p_parents out nocopy BSC_AW_ADAPTER_DIM.dim_parent_child_tb
);
procedure get_child_level(
p_level varchar2,
p_children out nocopy BSC_AW_ADAPTER_DIM.dim_parent_child_tb
);
procedure get_level_pk(
p_level varchar2,
p_level_id out nocopy number,
p_level_pk out nocopy varchar2,
p_level_pk_datatype out nocopy varchar2,
p_level_source out nocopy varchar2
);
procedure get_kpi_for_dim(
p_levels varchar2,
p_kpi out nocopy dbms_sql.varchar2_table,
p_dimset out nocopy dbms_sql.varchar2_table
);
procedure get_dims_for_kpis(
p_kpi_list dbms_sql.varchar2_table,
p_dim_list out nocopy dbms_sql.varchar2_table
);
function is_dim_recursive(p_dim_level varchar2) return varchar2;
procedure get_dim_data_source(
p_level_list dbms_sql.varchar2_table,
p_level_pk_col out nocopy dbms_sql.varchar2_table,
p_data_source out nocopy varchar2,
p_inc_data_source out nocopy varchar2
);
procedure get_denorm_data_source(
p_dim_level varchar2,
p_child_col out nocopy varchar2,
p_parent_col out nocopy varchar2,
p_position_col out nocopy varchar2,
p_denorm_data_source out nocopy varchar2,
p_denorm_change_data_source out nocopy varchar2
);
procedure get_kpi_for_calendar(p_calendar_id number,p_kpi_list out nocopy dbms_sql.varchar2_table);
procedure get_kpi_calendar(p_kpi varchar2,p_calendar out nocopy number) ;
procedure get_kpi_dim_sets(
p_kpi varchar2,
p_dim_set out nocopy dbms_sql.varchar2_table
);
procedure get_dim_set_dims(
p_kpi varchar2,
p_dim_set varchar2,
p_dim_level out nocopy dbms_sql.varchar2_table,
p_mo_dim_group out nocopy dbms_sql.varchar2_table,
p_skip_level out nocopy dbms_sql.varchar2_table
);
procedure get_dim_set_measures(
p_kpi varchar2,
p_dim_set varchar2,
p_measure out nocopy dbms_sql.varchar2_table,
p_measure_type out nocopy dbms_sql.varchar2_table,
p_data_type out nocopy dbms_sql.varchar2_table,
p_agg_formula out nocopy dbms_sql.varchar2_table,
p_forecast out nocopy dbms_sql.varchar2_table,
p_property out nocopy dbms_sql.varchar2_table
);
function is_target_at_higher_level(p_kpi varchar2,p_dim_set varchar2) return varchar2;
procedure get_target_levels(
p_kpi varchar2,
p_dim_set varchar2,
p_dim_level out nocopy dbms_sql.varchar2_table);
procedure get_dim_level_properties(p_level varchar2,
p_pk out nocopy varchar2,
p_fk out nocopy varchar2,
p_datatype out nocopy varchar2,
p_level_source out nocopy varchar2);
procedure get_dim_level_filter(
p_kpi varchar2,
p_level varchar2,
p_filter out nocopy dbms_sql.varchar2_table);
procedure get_s_views(
p_kpi varchar2,
p_dim_set varchar2,
p_s_views out nocopy dbms_sql.varchar2_table);
procedure get_s_view_levels(
p_s_view varchar2,
p_levels out nocopy dbms_sql.varchar2_table);
procedure get_base_table_levels(p_kpi varchar2,
p_dim_set varchar2,
p_base_table varchar2,
p_bt_levels out nocopy dbms_sql.varchar2_table,
p_bt_level_fks out nocopy dbms_sql.varchar2_table,
p_bt_level_pks out nocopy dbms_sql.varchar2_table,
p_bt_feed_level out nocopy dbms_sql.varchar2_table
);
procedure get_base_table_measures(p_kpi varchar2,
p_dim_set varchar2,
p_base_table varchar2,
p_measures out nocopy dbms_sql.varchar2_table,
p_bt_formula out nocopy dbms_sql.varchar2_table
);
procedure get_kpi_periodicities(
p_kpi varchar2,
p_dim_set varchar2,
p_periodicity out nocopy dbms_sql.number_table
);
procedure get_base_table_periodicity(
p_base_table varchar2,
p_periodicity out nocopy number);
function get_db_calendar_column(
p_calendar number,
p_periodicity number) return varchar2;
procedure get_zero_code_levels(
p_kpi varchar2,
p_dim_set varchar2,
p_levels out nocopy dbms_sql.varchar2_table) ;
procedure get_dim_set_base_tables(
p_kpi varchar2,
p_dim_set varchar2,
p_base_tables out nocopy dbms_sql.varchar2_table);
procedure get_dim_set_target_base_tables(
p_kpi varchar2,
p_dim_set varchar2,
p_base_tables out nocopy dbms_sql.varchar2_table);
procedure get_kpi_current_period(
p_kpi varchar2,
p_periodicity number,
p_period out nocopy number,
p_year out nocopy number);
procedure get_target_periodicity(
p_kpi varchar2,
p_dim_set varchar2,
p_periodicities out nocopy dbms_sql.number_table
);
procedure get_all_kpi_in_aw(p_kpi_list out nocopy dbms_sql.varchar2_table);
--get the z mvs
procedure get_z_s_views(
p_kpi varchar2,
p_dim_set varchar2,
p_s_views out nocopy dbms_sql.varchar2_table);
function get_level_short_name(p_level_table_name varchar2) return varchar2;
procedure get_measures_for_short_names(
p_short_name dbms_sql.varchar2_table,
p_measure_name out nocopy dbms_sql.varchar2_table
);
procedure get_dim_levels_for_short_names(
p_short_name dbms_sql.varchar2_table,
p_dim_level_name out nocopy dbms_sql.varchar2_table
);
function is_level_used_by_aw_kpi(p_level varchar2) return boolean ;
procedure get_B_table_feed_periodicity(p_kpi varchar2,p_dim_set varchar2,p_base_table varchar2,p_feed_periodicity out nocopy dbms_sql.number_table);
function get_kpi_LUD(p_kpi varchar2) return date;
procedure get_base_table_properties(
p_base_table varchar2,
p_prj_table out nocopy varchar2,
p_partition out nocopy bsc_aw_utility.object_partition_r);
procedure get_table_current_period(p_table varchar2,p_period out nocopy number,p_year out nocopy number);
--procedures-------------------------------------------------------
procedure init_all;
procedure log(p_message varchar2);
procedure log_n(p_message varchar2);
-------------------------------------------------------------------

END BSC_METADATA;

 

/
