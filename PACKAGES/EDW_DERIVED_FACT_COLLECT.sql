--------------------------------------------------------
--  DDL for Package EDW_DERIVED_FACT_COLLECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_DERIVED_FACT_COLLECT" AUTHID CURRENT_USER AS
/*$Header: EDWFCOLS.pls 115.19 2003/07/29 00:22:43 vsurendr ship $*/

Type varcharTableType is Table of varchar2(400) index by binary_integer;
Type numberTableType is Table of number index by binary_integer;

g_temp_conc_name varchar2(400);
g_temp_exe_name varchar2(400);
g_debug boolean;
g_fact_name varchar2(400);
g_fact_id number;
g_temp_fact_name  varchar2(400);
g_fact_iv  varchar2(400);
g_stmt varchar2(32000);
g_fact_fks EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_higher_level EDW_OWB_COLLECTION_UTIL.booleanTableType;
g_parent_dim EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_parent_dim_id EDW_OWB_COLLECTION_UTIL.numberTableType;
g_parent_level EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_prefix  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_pk  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_pk_key  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_dim_pk_key  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_fact_fks number;
g_forall_size number;
g_thread_type varchar2(40);
g_mapping_ids numberTableType;
g_number_mapping_ids number;
g_src_objects varcharTableType;
g_src_object_ids numberTableType;
g_src_object_type varcharTableType;
g_bis_owner varchar2(400);
g_table_owner varchar2(400);
g_status_message varchar2(20000);

/*****************************************************************/
/**************Record the number of rows processed and errors*****/
g_ins_rows_processed number;
g_ins_rows_dangling number;
g_ins_rows_duplicate number;
g_ins_rows_error number;
g_collection_size number;
g_parallel  number;
g_ilog varchar2(400);
g_dlog varchar2(400);
g_fresh_restart boolean;

/******************************************************************/
FUNCTION COLLECT_FACT(
  p_fact_name varchar2,--derived fact
  p_fact_id number,--derived fact
  p_src_fact_name varchar2,
  p_src_fact_id number,
  p_map_id number,
  p_conc_id in number,
  p_conc_program_name in varchar2,
  p_debug boolean,
  p_collection_size number,
  p_parallel  number,
  p_bis_owner varchar2,
  p_table_owner varchar2,
  p_ins_rows_processed out NOCOPY number,
  p_ilog varchar2,
  p_dlog varchar2,
  p_forall_size number,
  p_update_type varchar2,
  p_fact_dlog varchar2,
  p_skip_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
  p_number_skip_cols number,
  p_load_fk number,
  p_fresh_restart boolean,
  p_op_table_space varchar2,
  p_bu_tables EDW_OWB_COLLECTION_UTIL.varcharTableType,--before update tables.prop dim change to derv
  p_bu_dimensions EDW_OWB_COLLECTION_UTIL.varcharTableType,
  p_number_bu_tables number,
  p_bu_src_fact varchar2,--what table to look at as the src fact. if null, scan the actual src fact
  p_load_mode varchar2,
  p_rollback varchar2,
  p_src_join_nl_percentage number,
  p_thread_type varchar2,
  p_max_threads number,
  p_min_job_load_size number,
  p_sleep_time number,
  p_hash_area_size number,
  p_sort_area_size number,
  p_trace boolean,
  p_read_cfig_options boolean
) return boolean;
FUNCTION COLLECT_FACT_INC(
p_src_fact_name varchar2,
p_src_fact_id number,
p_derived_facts EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_derived_fact_ids EDW_OWB_COLLECTION_UTIL.numberTableType,
p_map_ids EDW_OWB_COLLECTION_UTIL.numberTableType,
p_number_derived_facts number,
p_conc_id in number,
p_conc_program_name in varchar2,
p_debug boolean,
p_collection_size number,
p_parallel  number,
p_bis_owner varchar2,
p_table_owner varchar2,--src fact owner
p_load_pk out nocopy EDW_OWB_COLLECTION_UTIL.numberTableType,
p_ins_rows_processed out NOCOPY EDW_OWB_COLLECTION_UTIL.numberTableType,
p_status out nocopy EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_message out nocopy EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_derv_facts out nocopy number,
p_forall_size number,
p_update_type varchar2,
p_fact_dlog varchar2,
p_fresh_restart boolean,
p_op_table_space varchar2,
p_bu_tables EDW_OWB_COLLECTION_UTIL.varcharTableType,--before update tables.prop dim change to derv
p_bu_dimensions EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_bu_tables number,
p_bu_src_fact varchar2,--what table to look at as the src fact. if null, scan the actual src fact
p_load_mode varchar2,
p_rollback varchar2,
p_src_join_nl_percentage number,
p_thread_type varchar2,
p_max_threads number,
p_min_job_load_size number,
p_sleep_time number,
p_hash_area_size number,
p_sort_area_size number,
p_trace boolean,
p_read_cfig_options boolean,
p_job_queue_processes number
)return boolean ;
FUNCTION COLLECT_FACT(
p_fact_name varchar2,
p_conc_id in number,
p_conc_program_name in varchar2,
p_debug boolean,
p_collection_size number,
p_parallel  number,
p_bis_owner varchar2,
p_table_owner varchar2,
p_ins_rows_processed out NOCOPY number,
p_forall_size number,
p_update_type varchar2,
p_skip_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_skip_cols number,
p_load_fk number,
p_fresh_restart boolean,
p_op_table_space varchar2,
p_rollback varchar2,
p_src_join_nl_percentage number,
p_thread_type varchar2,
p_max_threads number,
p_min_job_load_size number,
p_sleep_time number,
p_hash_area_size number,
p_sort_area_size number,
p_trace boolean,
p_read_cfig_options boolean
) return boolean ;
procedure write_to_log_file(p_message varchar2) ;
procedure init_all;
function get_fact_fks return boolean ;
function get_fact_id return boolean ;
function get_fact_mappings return boolean;
function get_time return varchar2;
procedure write_to_log_file_n(p_message varchar2);
function get_status_message return varchar2;
function truncate_derived_fact return boolean ;
function wait_on_jobs(
p_job_id EDW_OWB_COLLECTION_UTIL.numberTableType,
p_job_status in out nocopy EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_jobs number,
p_sleep_time number,
p_mode varchar2
) return boolean ;
function get_temp_log_data(
p_object_name varchar2,
p_object_type varchar2,
p_load_pk number,
p_rows_processed out nocopy number
) return boolean ;
function get_child_job_status(
p_job_status_table varchar2,
p_status out nocopy varchar2,
p_message out nocopy varchar2
) return boolean;
function log_collection_detail(
p_object_name varchar2,
p_object_id number,
p_object_type varchar2,
p_conc_program_id number,
p_collection_start_date date,
p_collection_end_date date,
p_ins_rows_ready number,
p_ins_rows_processed number,
p_ins_rows_collected number,
p_ins_rows_insert number,
p_ins_rows_update number,
p_ins_rows_delete number,
p_message varchar2,
p_status varchar2,
p_load_pk number
) return boolean;
function delete_object_log_tables(
p_src_fact varchar2,
p_table_owner varchar2,
p_bis_owner varchar2,
p_fact_dlog varchar2,
p_ilog EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_dlog EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_derv_fact number
)return boolean ;
function drop_inp_status_table(
p_input_table varchar2,
p_job_status_table varchar2
)return boolean;
function create_conc_program(
p_temp_conc_name varchar2,
p_temp_conc_short_name varchar2,
p_temp_exe_name varchar2,
p_bis_short_name varchar2
) return boolean ;
END;

 

/
