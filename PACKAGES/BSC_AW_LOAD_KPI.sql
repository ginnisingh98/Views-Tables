--------------------------------------------------------
--  DDL for Package BSC_AW_LOAD_KPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_AW_LOAD_KPI" AUTHID CURRENT_USER AS
/*$Header: BSCAWLKS.pls 120.15 2006/03/25 12:32 vsurendr noship $*/
--program runtime parameters
g_debug boolean;
g_stmt varchar2(32000);
g_bsc_olap_object bsc_aw_md_wrapper.bsc_olap_object_tb;
g_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
------------types--------------------------------------------------
--
--a kpi has multiple dimsets, here we only consider 1 dimset at a time
--both actual and target dimsets are contained in dim_set
type aggregation_r is record(
kpi varchar2(200),
parent_kpi varchar2(200),
dim_set bsc_aw_adapter_kpi.dim_set_tb
);
type aggregation_tb is table of aggregation_r index by pls_integer;
--g_aggregation aggregation_r;
----cache--------------------------------------------------------
g_cache_aggregation_r bsc_aw_load_kpi.aggregation_tb;
-----procedures----------------------------------------------------
procedure load_kpi(
p_kpi_list dbms_sql.varchar2_table
);
procedure load_base_table(
p_base_table_list dbms_sql.varchar2_table,
p_kpi_list dbms_sql.varchar2_table
);
procedure load_kpi(p_kpi varchar2,p_base_table_list varchar2,p_run_id number,p_job_name varchar2,p_options varchar2);
procedure load_kpi_dimset(p_kpi varchar2,p_dim_set varchar2,p_base_tables varchar2,
p_run_id number,p_job_name varchar2,p_options varchar2);
procedure load_kpi_dimset(p_kpi varchar2,p_dim_set varchar2,p_base_tables dbms_sql.varchar2_table);
procedure load_kpi_dimset_base_table(
p_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb
);
function check_load_type(p_property varchar2) return varchar2;
--procedure aggregate_kpi_base_table(p_kpi varchar2,p_base_tables dbms_sql.varchar2_table);
procedure aggregate_kpi_dimset(p_kpi varchar2,p_dim_set varchar2,
p_run_id number,p_job_name varchar2,p_options varchar2);
procedure aggregate_kpi_dimset(
p_kpi varchar2,
p_aggregation aggregation_r,
p_dim_set bsc_aw_adapter_kpi.dim_set_r);
procedure aggregate_kpi_dimset_actuals(p_kpi varchar2,p_dim_set bsc_aw_adapter_kpi.dim_set_r);
procedure aggregate_kpi_dimset_targets(
p_kpi varchar2,
p_actual_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_target_dim_set bsc_aw_adapter_kpi.dim_set_r
);
procedure aggregate_measure(
p_kpi varchar2,
p_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_measures dbms_sql.varchar2_table,
p_aggregate_options varchar2
);
procedure aggregate_measure_formula(
p_kpi varchar2,
p_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_measures dbms_sql.varchar2_table,
p_aggregate_options varchar2
);
procedure correct_forecast_aggregation(
p_kpi varchar2,
p_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_measures bsc_aw_adapter_kpi.measure_tb,
p_aggregate_options varchar2
);
procedure get_forecast_current_period(
p_aggregation in out nocopy aggregation_r);
procedure get_forecast_current_period(
p_kpi varchar2,
p_calendar number,
p_periodicity number,
p_period out nocopy varchar2
);
procedure limit_calendar_end_period_rel(p_calendar bsc_aw_adapter_kpi.calendar_r);
procedure reset_calendar_end_period_rel(p_calendar bsc_aw_adapter_kpi.calendar_r);
procedure limit_dim_values(p_dim bsc_aw_adapter_kpi.dim_tb,p_mode varchar2);
procedure limit_dim_levels(p_dim bsc_aw_adapter_kpi.dim_tb);
procedure limit_dim_ancestors(p_dim bsc_aw_adapter_kpi.dim_tb,p_operator varchar2);
procedure reset_dim_limit_cubes(p_dim bsc_aw_adapter_kpi.dim_tb);
procedure limit_calendar_values(p_calendar bsc_aw_adapter_kpi.calendar_r,p_mode varchar2);
procedure limit_calendar_levels(p_calendar bsc_aw_adapter_kpi.calendar_r);
procedure limit_calendar_ancestors(p_calendar bsc_aw_adapter_kpi.calendar_r,p_operator varchar2);
procedure reset_calendar_limit_cubes(p_calendar bsc_aw_adapter_kpi.calendar_r);
procedure set_aggregation(p_kpi varchar2,p_aggregation out nocopy aggregation_r);
procedure dmp_aggregation_r(p_aggregation aggregation_r);
procedure push_dim(p_dim bsc_aw_adapter_kpi.dim_tb);
procedure push_dim(p_dim varchar2);
procedure pop_dim(p_dim bsc_aw_adapter_kpi.dim_tb);
procedure pop_dim(p_dim varchar2);
procedure push_level(p_marker varchar2);
procedure pop_level(p_marker varchar2);
procedure purge_kpi(p_kpi varchar2);
procedure limit_measure_dim(
p_aggmap_operator bsc_aw_adapter_kpi.aggmap_operator_r,
p_cubes dbms_sql.varchar2_table,
p_partition_value varchar2
);
procedure reset_dim_limits(p_dim_set bsc_aw_adapter_kpi.dim_set_r);
procedure limit_dim_target_level_only(
p_actual_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_target_dim_set bsc_aw_adapter_kpi.dim_set_r
);
procedure limit_dim_limit_cube(
p_dim bsc_aw_adapter_kpi.dim_tb,
p_value varchar2
);
procedure limit_dim_limit_cube(
p_limit_cube varchar2,
p_value varchar2,
p_composite_name varchar2
);
function get_projection_dim(p_dim_set bsc_aw_adapter_kpi.dim_set_r) return varchar2;
function is_aggregation_on_dim(p_dim bsc_aw_adapter_kpi.dim_r) return boolean ;
function is_aggregation_on_time(p_calendar bsc_aw_adapter_kpi.calendar_r) return boolean;
function get_dim_index(
p_dim bsc_aw_adapter_kpi.dim_tb,
p_dim_name varchar2
)return number;
function get_measure_index(
p_measure bsc_aw_adapter_kpi.measure_tb,
p_measure_name varchar2
)return number;
procedure limit_all_dim(p_dim_set bsc_aw_adapter_kpi.dim_set_r);
procedure load_calendar_if_needed(p_kpi varchar2) ;
procedure limit_dim_levels(p_dim bsc_aw_adapter_kpi.dim_r);
procedure limit_dim_levels(p_dim bsc_aw_adapter_kpi.dim_r,p_level varchar2);
procedure limit_calendar_levels(
p_calendar bsc_aw_adapter_kpi.calendar_r,
p_periodicity_dim varchar2);
procedure dmp_kpi_cubes_into_table(
p_kpi varchar2,
p_dimset varchar2,
p_dim_levels dbms_sql.varchar2_table,
p_table_name varchar2) ;
procedure limit_dim(p_dim varchar2,p_value varchar2,p_mode varchar2);
procedure dmp_kpi_cubes_into_table(
p_kpi varchar2,
p_table_name varchar2,
p_tables out nocopy dbms_sql.varchar2_table
);
procedure lock_dimset_objects(p_kpi varchar2,p_dimset varchar2,p_object_type varchar2,p_lock_type varchar2);
procedure get_dimset_objects_to_lock(
p_kpi varchar2,
p_dimset varchar2,
p_object_type varchar2,
p_lock_objects out nocopy dbms_sql.varchar2_table) ;
procedure load_kpi_jobs(p_kpi_list dbms_sql.varchar2_table,p_base_table_list varchar2);
procedure get_dimset_for_base_table(
p_kpi varchar2,
p_base_table_list dbms_sql.varchar2_table,
p_dim_set out nocopy dbms_sql.varchar2_table);
procedure get_aggregate_dimsets(
p_kpi varchar2,
p_dim_set dbms_sql.varchar2_table,
p_aggregate_dimset out nocopy dbms_sql.varchar2_table
);
function get_cache_aggregation_r(p_kpi varchar2) return aggregation_r;
procedure load_kpi_dimset_job(p_kpi varchar2,p_dimset_list dbms_sql.varchar2_table,p_base_tables dbms_sql.varchar2_table);
procedure get_kpi_base_tables(
p_kpi varchar2,
p_base_table_list dbms_sql.varchar2_table,
p_kpi_base_tables out nocopy dbms_sql.varchar2_table
);
procedure aggregate_kpi_dimset_job(p_kpi varchar2,p_dim_set dbms_sql.varchar2_table);
function get_dim_set_index(p_aggregation aggregation_r,p_dim_set varchar2) return number;
procedure get_measure_objects_to_lock(
p_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_measures dbms_sql.varchar2_table,
p_lock_objects out nocopy dbms_sql.varchar2_table
);
procedure aggregate_measure_job(
p_kpi varchar2,
p_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_measures dbms_sql.varchar2_table,
p_options varchar2,
p_measure_agg_type varchar2 --normal, balance or formula
);
procedure aggregate_measure(
p_kpi varchar2, -- is p_kpi||'_'||p_dim_set.dim_set_name||'_aggregate';
p_measures varchar2,
p_aggregate_options varchar2,
p_measure_agg_type varchar2, --normal, balance or formula
p_run_id number,p_job_name varchar2,p_options varchar2);
procedure copy_target_to_actual_job(
p_kpi varchar2,
p_actual_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_target_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_actual_measures dbms_sql.varchar2_table
);
procedure copy_target_to_actual_job(
p_kpi varchar2,
p_actual_dimset varchar2,
p_target_dimset varchar2,
p_cubes varchar2,
p_aggregate_options varchar2,
p_run_id number,p_job_name varchar2,p_options varchar2) ;
procedure copy_target_to_actual(
p_actual_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_target_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_actual_cubes dbms_sql.varchar2_table,
p_partition_value varchar2,
p_partition_dim_value varchar2
);
procedure copy_target_to_actual(
p_actual_cube varchar2,
p_target_cube varchar2,
p_composite varchar2
);
procedure reset_dimset_change_vector(p_kpi varchar2);
procedure load_kpi_dimset_base_table(
p_kpi varchar2,
p_dimset varchar2,
p_base_table_dimset_oor bsc_aw_md_wrapper.bsc_olap_object_relation_tb, --to get baes table, dimset and bt measures
p_dimset_oor bsc_aw_md_wrapper.bsc_olap_object_relation_tb, --to get measures etc
p_load_program varchar2,
p_min_value dbms_sql.number_table,
p_max_value dbms_sql.number_table,
p_bt_current_period dbms_sql.varchar2_table
);
procedure load_kpi_dimset_base_table_job(
p_kpi varchar2,
p_dimset varchar2,
p_base_table_dimset_oor bsc_aw_md_wrapper.bsc_olap_object_relation_tb, --to get baes table, dimset and bt measures
p_dimset_oor bsc_aw_md_wrapper.bsc_olap_object_relation_tb, --to get measures etc
p_load_program varchar2,
p_LB_resync_program varchar2,
p_min_value dbms_sql.number_table,
p_max_value dbms_sql.number_table,
p_bt_current_period dbms_sql.varchar2_table
);
procedure load_cube_base_table(
p_kpi varchar2,
p_dim_set varchar2,
p_parameter varchar2,
p_cubes varchar2,--c1,c2 format
p_measures  varchar2,--m1,m2 format
p_base_table varchar2, --B1,B2,B3, format
p_start_lock_objects varchar2, --usually 1 cube c1, format
p_end_lock_objects varchar2, --in case of partitions, limit cubes
p_load_program varchar2,
p_LB_resync_program varchar2,
p_min_value varchar2,
p_max_value varchar2,
p_bt_current_period varchar2,
p_partition_options varchar2,
p_run_id number,p_job_name varchar2,p_options varchar2);
procedure insert_bsc_aw_temp_cv(p_min_value number,p_max_value number,p_base_table varchar2);
procedure get_measure_objects_to_lock(
p_kpi varchar2,
p_dimset varchar2,
p_measures dbms_sql.varchar2_table,
p_lock_objects out nocopy dbms_sql.varchar2_table
);
procedure limit_dim_descendents(p_dim bsc_aw_adapter_kpi.dim_tb,p_operator varchar2,p_depth varchar2);
procedure limit_calendar_descendents(p_calendar bsc_aw_adapter_kpi.calendar_r,p_operator varchar2,p_depth varchar2) ;
function can_launch_jobs(p_kpi varchar2,p_dimset bsc_aw_adapter_kpi.dim_set_r,p_measures dbms_sql.varchar2_table) return varchar2;
procedure get_cubes_for_measures(
p_measures dbms_sql.varchar2_table,
p_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_cubes out nocopy dbms_sql.varchar2_table);
procedure copy_target_to_actual_serial(
p_actual_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_target_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_actual_measures dbms_sql.varchar2_table);
procedure dmp_dimset_dim_statlen(p_dim_set bsc_aw_adapter_kpi.dim_set_r);
procedure limit_dim(p_dim varchar2,p_value dbms_sql.varchar2_table,p_mode varchar2);
procedure get_ds_BT_parameters(
p_kpi varchar2,
p_dimset varchar2,
p_load_program varchar2,
p_b_tables dbms_sql.varchar2_table,
p_ds_parameters out nocopy dbms_sql.varchar2_table);
procedure get_dimset_objects(p_kpi varchar2,p_dim_set varchar2,p_oo out nocopy bsc_aw_md_wrapper.bsc_olap_object_tb);
procedure load_dim_if_needed(p_kpi varchar2,p_dim_set dbms_sql.varchar2_table);
procedure limit_cal_target_level_only(
p_actual_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_target_dim_set bsc_aw_adapter_kpi.dim_set_r
);
procedure check_bt_current_period_change(
p_kpi varchar2,
p_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_cubes dbms_sql.varchar2_table,
p_measures dbms_sql.varchar2_table,
p_base_tables dbms_sql.varchar2_table,
p_bt_current_period dbms_sql.varchar2_table,
p_options varchar2
);
procedure check_bt_current_period_change(
p_kpi varchar2,
p_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_cube varchar2,
p_measures bsc_aw_adapter_kpi.measure_tb,
p_bt_periodicity dbms_sql.number_table, /*p_bt_periodicity,p_start_period and p_end_period match in count*/
p_start_period dbms_sql.varchar2_table,
p_end_period dbms_sql.varchar2_table,
p_options varchar2 /*contains partition info */
);
function dimset_has_bal_measures(p_dim_set bsc_aw_adapter_kpi.dim_set_r) return boolean;
procedure dmp_dimset_composite_count(p_dim_set bsc_aw_adapter_kpi.dim_set_r);
function is_parallel_load(p_base_tables dbms_sql.varchar2_table,p_cutoff number) return boolean;
function is_parallel_load(p_base_tables dbms_sql.varchar2_table,p_change_vector dbms_sql.number_table,p_cutoff number) return boolean;
function get_table_load_count(p_table varchar2,p_change_vector number) return number;
function is_parallel_aggregate(p_dim_set bsc_aw_adapter_kpi.dim_set_tb,p_cutoff number) return boolean ;
function is_parallel_aggregate(p_dim_set bsc_aw_adapter_kpi.dim_set_r,p_cutoff number) return boolean ;
function get_dimset_composite_count(p_dim_set bsc_aw_adapter_kpi.dim_set_r) return number;
procedure get_base_table_for_dimset(p_kpi varchar2,p_base_table_list dbms_sql.varchar2_table,p_dim_set dbms_sql.varchar2_table,
p_dimset_base_tables out nocopy dbms_sql.varchar2_table);
--procedures-------------------------------------------------------
procedure init_all;
procedure log(p_message varchar2);
procedure log_n(p_message varchar2);
-------------------------------------------------------------------
END BSC_AW_LOAD_KPI;

 

/
