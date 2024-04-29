--------------------------------------------------------
--  DDL for Package BSC_AW_LOAD_DIM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_AW_LOAD_DIM" AUTHID CURRENT_USER AS
/*$Header: BSCAWLDS.pls 120.6 2006/03/02 15:22 vsurendr noship $*/
--program runtime parameters
g_debug boolean;
g_stmt varchar2(32000);
--
type dim_level_delete_r is record( --hold level delete values
delete_name varchar2(100),
delete_values dbms_sql.varchar2_table
);
type dim_level_delete_tv is table of dim_level_delete_r index by varchar2(100);
-----------------procedures----------------------
procedure load_dim(p_dim_level_list dbms_sql.varchar2_table);
procedure load_dim_levels(p_dim_level_list dbms_sql.varchar2_table);
procedure load_aw_dim(p_dim varchar2,p_run_id number,p_job_name varchar2,p_options varchar2);
function check_initial_load(p_dim varchar2) return boolean;
procedure purge_dim(p_dim_level_list dbms_sql.varchar2_table);
procedure purge_dim(p_dim varchar2);
procedure load_dim_delete(
p_dim varchar2,
p_dim_property varchar2,
p_dim_level_delete in out nocopy dim_level_delete_tv,
p_delete_flag out nocopy boolean);
procedure dmp_dim_level_into_table(p_dim_level_list dbms_sql.varchar2_table);
procedure dmp_dim_level_into_table(p_dim_level varchar2);
procedure set_kpi_limit_variables(p_dim varchar2);
procedure lock_dim_objects(p_dim varchar2,p_dim_delete boolean);
procedure get_dim_objects_to_lock(p_dim varchar2,p_lock_objects out nocopy dbms_sql.varchar2_table);
procedure load_aw_dim_jobs(p_dim_list dbms_sql.varchar2_table);
procedure delete_dim_level_value(p_dim_level varchar2,p_delete_values dbms_sql.varchar2_table);
procedure load_recursive_norm_hier(p_denorm_source varchar2,p_child_col varchar2,p_parent_col varchar2);
procedure load_dimensions(p_dim_list dbms_sql.varchar2_table);
procedure load_dim_if_needed(p_dim dbms_sql.varchar2_table);
function check_dim_loaded(p_dim varchar2) return varchar2;
procedure mark_dim_loaded(p_dim varchar2);
procedure load_delete_dim_level_value(
p_dim_level varchar2,
p_select_level varchar2,--useful in case of rec dim. we need to delete the virtual parent level also
p_dim_level_delete in out nocopy dim_level_delete_tv);
procedure execute_dim_delete(
p_dim_level_delete dim_level_delete_tv
);
procedure clean_bsc_aw_dim_delete(p_dim_level_delete dim_level_delete_tv);
procedure upgrade_load_sync_all_dim;
procedure upgrade_load_sync_all_dim(p_dim varchar2);
procedure merge_delete_values_to_levels(p_dim_level_delete dim_level_delete_tv);
--procedures-------------------------------------------------------
procedure init_all;
procedure log(p_message varchar2);
procedure log_n(p_message varchar2);
-------------------------------------------------------------------

END BSC_AW_LOAD_DIM;

 

/
