--------------------------------------------------------
--  DDL for Package BSC_AW_BSC_METADATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_AW_BSC_METADATA" AUTHID CURRENT_USER AS
/*$Header: BSCAWMDS.pls 120.7 2006/01/14 20:54 vsurendr noship $*/
--program runtime parameters
g_debug boolean;
g_stmt varchar2(32000);
g_count number;
g_exception exception;
--procedures-------------------------------------------------------
procedure get_all_parent_child(
p_dim_level_list dbms_sql.varchar2_table,
p_dim_parent_child out nocopy BSC_AW_ADAPTER_DIM.dim_parent_child_tb,
p_dim_levels out nocopy BSC_AW_ADAPTER_DIM.levels_tv
);
procedure get_parent_children(
p_level varchar2,
p_level_considered in out nocopy dbms_sql.varchar2_table,
p_dim_parent_child in out nocopy BSC_AW_ADAPTER_DIM.dim_parent_child_tb
);
procedure get_all_distinct_levels(
p_levels dbms_sql.varchar2_table,
p_dim_levels out nocopy BSC_AW_ADAPTER_DIM.levels_tv
);
procedure get_kpi_for_dim(
p_dim in out nocopy bsc_aw_adapter_dim.dimension_r
);
procedure create_rec_data_source(
p_dimension in out nocopy bsc_aw_adapter_dim.dimension_r
);
procedure create_data_source(
p_dimension in out nocopy bsc_aw_adapter_dim.dimension_r
);
procedure get_dims_for_kpis(
p_kpi_list dbms_sql.varchar2_table,
p_dim_list out nocopy dbms_sql.varchar2_table
);
procedure set_dim_recursive(p_dimension in out nocopy bsc_aw_adapter_dim.dimension_r);
procedure get_kpi_for_calendar(p_calendar in out nocopy bsc_aw_calendar.calendar_r) ;
procedure get_kpi_properties(p_kpi in out nocopy bsc_aw_adapter_kpi.kpi_r);
procedure get_kpi_dim_sets(p_kpi in out nocopy bsc_aw_adapter_kpi.kpi_r);
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
p_measure in out nocopy bsc_aw_adapter_kpi.measure_tb
);
procedure get_s_views(p_kpi varchar2,p_dim_set in out nocopy bsc_aw_adapter_kpi.dim_set_r);
function is_target_at_higher_level(p_kpi varchar2,p_dim_set varchar2) return varchar2;
procedure get_target_dim_levels(p_kpi varchar2,p_target_dim_set in out nocopy bsc_aw_adapter_kpi.dim_set_r);
procedure check_dim_zero_code(p_kpi varchar2,p_dim_set in out nocopy bsc_aw_adapter_kpi.dim_set_r);
procedure get_dim_level_properties(p_kpi varchar2,p_dim in out nocopy bsc_aw_adapter_kpi.dim_r);
procedure get_dim_set_data_source(p_kpi varchar2,p_dim_set in out nocopy bsc_aw_adapter_kpi.dim_set_r);
procedure get_base_table_data_source(p_kpi varchar2,
p_dim_set varchar2,
p_base_table varchar2,
p_data_source in out nocopy bsc_aw_adapter_kpi.data_source_r);
procedure get_dim_set_calendar(p_kpi varchar2,p_dim_set in out nocopy bsc_aw_adapter_kpi.dim_set_r);
function get_db_calendar_column(p_calendar number,p_periodicity number) return varchar2;
procedure get_forecast_current_period(
p_kpi varchar2,
p_calendar number,
p_periodicity number,
p_period out nocopy varchar2
);
procedure get_dim_level_filter(p_kpi varchar2,p_level in out nocopy bsc_aw_adapter_kpi.level_r);
procedure get_target_dim_periodicity(p_kpi varchar2,p_target_dim_set in out nocopy bsc_aw_adapter_kpi.dim_set_r);
procedure get_all_kpi_in_aw(
p_kpi out nocopy dbms_sql.varchar2_table,
p_kpi_dimset out nocopy dbms_sql.varchar2_table
);
procedure fill_in_target_periodicity(
p_target_calendar in out nocopy bsc_aw_adapter_kpi.calendar_r,
p_source_calendar bsc_aw_adapter_kpi.calendar_r,
p_periodicity varchar2
);
procedure get_measures_for_short_names(
p_short_name dbms_sql.varchar2_table,
p_measure_name out nocopy dbms_sql.varchar2_table
);
procedure get_dim_levels_for_short_names(
p_short_name dbms_sql.varchar2_table,
p_dim_level_name out nocopy dbms_sql.varchar2_table
);
function is_level_used_by_aw_kpi(p_level varchar2) return boolean;
procedure get_parent_level(p_level varchar2,p_parents out nocopy dbms_sql.varchar2_table);
procedure get_child_level(p_level varchar2,p_children out nocopy dbms_sql.varchar2_table);
procedure get_B_table_feed_periodicity(p_kpi varchar2,p_dim_set varchar2,p_base_table varchar2,p_feed_periodicity out nocopy dbms_sql.number_table);
procedure get_ds_relevant_cal_hier(p_calendar in out nocopy bsc_aw_adapter_kpi.calendar_r);
procedure set_measure_properties(p_dim_set bsc_aw_adapter_kpi.dim_set_r,p_data_source in out nocopy bsc_aw_adapter_kpi.data_source_r);
procedure get_table_current_period(p_table varchar2,p_period out nocopy varchar2);
--procedures-------------------------------------------------------
procedure init_all;
procedure log(p_message varchar2);
procedure log_n(p_message varchar2);
-------------------------------------------------------------------

END BSC_AW_BSC_METADATA;

 

/
