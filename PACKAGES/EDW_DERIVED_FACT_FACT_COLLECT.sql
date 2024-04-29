--------------------------------------------------------
--  DDL for Package EDW_DERIVED_FACT_FACT_COLLECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_DERIVED_FACT_FACT_COLLECT" AUTHID CURRENT_USER AS
/*$Header: EDWFFCLS.pls 115.25 2003/07/29 00:22:56 vsurendr ship $*/
--Type varcharTableType is Table of varchar2(400) index by binary_integer;
--Type numberTableType is Table of number index by binary_integer;

g_thread_type varchar2(40);
g_pre_hook varchar2(10);
g_post_hook varchar2(10);
g_insert_lock_table varchar2(80);
g_log_file varchar2(200);
g_dbms_job_id number;
g_over boolean;
g_stmt varchar2(30000);
g_ilog_name varchar2(80);
g_dlog_name varchar2(80);
g_fact_name varchar2(400);
g_temp_fact_name varchar2(400);
g_temp_fact_name_temp varchar2(400);
g_summarize_temp2 varchar2(400);
g_summarize_temp3 varchar2(400);
g_fact_iv varchar2(400);
g_fact_id number;
g_mapping_id number;
g_fact_type varchar2(400);
g_src_object varchar2(400);
g_src_object_count number;
g_src_object_ilog varchar2(400);
g_src_object_dlog varchar2(400);
g_src_object_dlog_count number;
g_src_object_id number;
g_fact_fks EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_fact_fks_mapped EDW_OWB_COLLECTION_UTIL.booleanTableType;
g_higher_level EDW_OWB_COLLECTION_UTIL.booleanTableType;
g_higher_level_flag EDW_OWB_COLLECTION_UTIL.booleanTableType;
g_parent_dim EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_parent_dim_id EDW_OWB_COLLECTION_UTIL.numberTableType;
g_parent_level EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_prefix EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_pk  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_pk_key  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_dim_pk_key  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_fact_fks number;
g_src_fks EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_src_fks number;
g_filter_stmt varchar2(10000);
g_fact_dlog varchar2(400);

g_conc_id number;
g_conc_program_name varchar2(400);
g_debug boolean;
g_exec_flag boolean;
g_groupby_stmt varchar2(10000);
g_update_type varchar2(400);--what scheme should update follow...mass, row by row, delete insert...

g_input_params EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_output_params EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_input_params_is_fk EDW_OWB_COLLECTION_UTIL.booleanTableType;
g_group_by_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_output_group_by_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;--in the derived summary fact
g_number_group_by_cols number;
g_number_input_params number;
g_df_extra_fks  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_fk_flag  EDW_OWB_COLLECTION_UTIL.booleanTableType;--is the output col a fk?
g_fk_off_flag  EDW_OWB_COLLECTION_UTIL.booleanTableType;--turned off
g_groupby_col_flag  EDW_OWB_COLLECTION_UTIL.booleanTableType;--is the output col a group by col?
g_number_df_extra_fks number;

g_full_refresh boolean; --full refresh or not
g_naedw_pk number; --for now, put this as 0

/*************************************************************
                some temp holders
**************************************************************/
g_hold_relation EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_hold_item EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_hold_number number;
/*************************************************************/

g_ins_rows_processed number;
g_status_message varchar2(20000);
g_status boolean;

g_collection_size number;
g_parallel  number;
g_insert_rowid_table varchar2(400);
g_update_rowid_table varchar2(400);
g_delete_rowid_table varchar2(400);
g_insert_prot_log varchar2(400);
g_update_prot_log varchar2(400);
g_delete_prot_log varchar2(400);

g_ilog varchar2(400);
g_dlog varchar2(400);
g_bis_owner  varchar2(400);
g_table_owner varchar2(400);
g_df_table_owner varchar2(400);
g_data_temp_stmt varchar2(30000);--to move data into the temp table
g_delete_data_temp_stmt varchar2(32000);
g_temp_update_stmt varchar2(32000);
g_insert_stmt  varchar2(32000);
g_update_stmt  varchar2(32000);
g_update_stmt_row  varchar2(32000);
g_delete_stmt  varchar2(32000);
g_delete_stmt_row varchar2(32000);

g_insert_rowid_stmt  varchar2(32000);
g_update_rowid_stmt  varchar2(32000);
g_delete_rowid_stmt  varchar2(32000);
g_forall_size number;

g_err_rec_flag boolean;
g_err_rec_flag_d  boolean;--for delete

/**************Record the number of rows processed and errors*****/
g_ins_rows_ready EDW_OWB_COLLECTION_UTIL.numberTableType;
g_ins_rows_processed_tab EDW_OWB_COLLECTION_UTIL.numberTableType;
g_ins_rows_collected EDW_OWB_COLLECTION_UTIL.numberTableType;
g_ins_rows_dangling EDW_OWB_COLLECTION_UTIL.numberTableType;
g_ins_rows_duplicate EDW_OWB_COLLECTION_UTIL.numberTableType;
g_ins_rows_error EDW_OWB_COLLECTION_UTIL.numberTableType;
g_ins_instance_name EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_ins_request_id_table  EDW_OWB_COLLECTION_UTIL.numberTableType;
g_number_ins_req_coll number;
g_total_insert number;
g_total_update number;
g_total_delete number;
/*******************************************************/
g_load_fk number;
g_skip_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_skip_cols number;
g_skip_item EDW_OWB_COLLECTION_UTIL.booleanTableType;
g_fk_value_load EDW_OWB_COLLECTION_UTIL.booleanTableType;--if a value needs to be directly loaded like edwna
g_fk_load_value EDW_OWB_COLLECTION_UTIL.varcharTableType;--the value to load
--------------------sec sources-----------------------
g_sec_sources EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_sec_sources_alias EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_sec_sources number;
g_sec_sources_pk EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_sec_sources_fk EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_sec_key number;
--------------------sec sources-----------------------
g_mode varchar2(400);
g_skip_ilog boolean;--for performance
g_fresh_restart boolean;
g_op_table_space varchar2(400);
g_rollback  varchar2(400);
----------propogate inc changes in dim to derv facts--------------------------------------
g_bu_tables EDW_OWB_COLLECTION_UTIL.varcharTableType;--before update tables.prop dim change to derv fact.
g_bu_dimensions EDW_OWB_COLLECTION_UTIL.varcharTableType;--which are the dims with the before update tables
g_number_bu_tables number;
g_bu_src_fact varchar2(400);
g_load_mode varchar2(400);
g_skip_ilog_update boolean;
g_skip_dlog_update boolean;
g_type_ilog_generation varchar2(400);
g_type_dlog_generation varchar2(400);
g_dlog_prev varchar2(400);
g_ilog_prev varchar2(400);
g_ilog_small varchar2(400);
g_dlog_small varchar2(400);
g_fact_next_extent number;
g_src_pk varchar2(400);
g_src_uk varchar2(400);
g_src_snplog_has_pk boolean;
g_src_join_nl_percentage number;
g_src_join_nl boolean;
/*
for g_bu_src_fact the mapping details are got from the metadata and in the place of the src fact,g_bu_src_fact is
substituted.
so g_bu_src_fact must have the same col names as the src fact
*/
--------------------------------------------------------------------------------
g_max_threads number;
g_min_job_load_size number;
g_sleep_time number;
g_job_status_table varchar2(80);
g_hash_area_size number;
g_sort_area_size number;
g_trace boolean;
g_read_cfig_options boolean;
g_jobid_stmt varchar2(1000);
g_job_id number;

function COLLECT_FACT(p_fact_name varchar2,
                    p_fact_id number,
                    p_mapping_id number,
                    p_src_object varchar2,
                    p_src_object_id number,
                    p_fact_fks EDW_OWB_COLLECTION_UTIL.varcharTableType,
                    p_higher_level EDW_OWB_COLLECTION_UTIL.booleanTableType,
                    p_parent_dim EDW_OWB_COLLECTION_UTIL.varcharTableType,
                    p_parent_level EDW_OWB_COLLECTION_UTIL.varcharTableType,
                    p_level_prefix EDW_OWB_COLLECTION_UTIL.varcharTableType,
                    p_level_pk EDW_OWB_COLLECTION_UTIL.varcharTableType,
                    p_level_pk_key EDW_OWB_COLLECTION_UTIL.varcharTableType,
                    p_dim_pk_key EDW_OWB_COLLECTION_UTIL.varcharTableType,
                    p_number_fact_fks number,
                    p_conc_id number,
                    p_conc_program_name varchar2,
                    p_debug boolean,
                    p_collection_size number,
                    p_parallel number,
                    p_bis_owner varchar2,
                    p_table_owner  varchar2,
                    p_ins_rows_processed out NOCOPY number,
                    p_full_refresh boolean,
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
                    p_bu_tables EDW_OWB_COLLECTION_UTIL.varcharTableType,
                    --before update tables.prop dim change to derv
                    p_bu_dimensions EDW_OWB_COLLECTION_UTIL.varcharTableType,
                    p_number_bu_tables number,
                    p_bu_src_fact varchar2,
                    --what table to look at as the src fact. if null, scan full the src fact
                    p_load_mode varchar2,
                    p_rollback varchar2,
                    p_src_join_nl_percentage number,
                    p_pre_hook varchar2,
                    p_post_hook varchar2
                    ) return boolean ;
function get_time return varchar2 ;
procedure write_to_log_file(p_message varchar2) ;
procedure write_to_log_file_n(p_message varchar2) ;
function get_mapping_details return boolean ;
function get_src_fks return boolean ;
function is_src_fk(p_fk varchar2) return boolean ;
function is_tgt_fk(p_fk varchar2) return boolean ;
function make_data_into_temp(p_use_ordered_hint boolean) return boolean ;
function make_delete_data_into_temp return boolean ;
function execute_data_into_temp return number ;
function execute_delete_data_into_temp return number ;
function insert_into_fact return boolean ;
function get_ilog_dlog return boolean ;
function get_status_message return varchar2 ;
function get_df_extra_fks return boolean ;
procedure init_all(p_job_id number) ;
function move_data_into_local_ilog(p_multi_thread boolean) return boolean ;
function move_data_into_local_dlog(p_multi_thread boolean) return boolean ;
function COLLECT_FACT(p_mode varchar2) return boolean ;
function move_data_into_derived_fact(p_count number) return boolean ;
function make_insert_into_fact return boolean ;
function set_gilog_status return number ;
function set_gdlog_status return number ;
procedure clean_up ;
function update_dlog_status_2 return boolean;
function update_ilog_status_2 return boolean;
function execute_data_into_rowid_table return boolean ;
function insert_rowid_table_stmt return boolean ;
function update_rowid_table_stmt return boolean ;
function create_index_rowid_table return boolean ;
function make_update_into_fact return boolean ;
function make_delete_into_fact  return boolean ;
function delete_rowid_table_stmt return boolean ;
function create_index_drowid_table return boolean ;
function move_ddata_into_derived_fact(p_count number) return boolean ;
function execute_ddata_into_rowid_table return boolean;
function update_into_fact return boolean ;
function delete_into_fact return boolean ;
function create_gilog_T(p_table varchar2,p_ilog_temp varchar2) return boolean ;
function make_is_fk_flag return boolean ;
function is_tgt_fk_mapped return boolean ;
function summarize_fact_data return boolean ;
function create_summarize_temp2 return boolean ;
function create_summarize_temp3 return boolean ;
function create_summarize_temp return boolean ;
function update_log_status_0(p_log varchar2) return boolean;
function make_is_groupby_col  return boolean ;
function is_groupby_col (p_col varchar2) return boolean;
function drop_prot_tables return boolean ;
function drop_d_prot_tables return boolean;
function make_insert_prot_log return boolean ;
function make_update_prot_log return boolean ;
function make_delete_prot_log return boolean ;
function recover_from_previous_error return boolean;
function is_input_groupby_col(p_col varchar2) return boolean;
procedure insert_into_temp_log(p_flag varchar2) ;
function drop_ilog_index return boolean;
function drop_dlog_index return boolean;
procedure insert_into_load_progress(p_load_fk number,p_object_name varchar2,p_load_progress varchar2,
p_start_date date,p_end_date date,p_category varchar2, p_operation varchar2,p_seq_id varchar2,p_flag varchar2);
procedure insert_into_load_progress_d(p_load_fk number,p_object_name varchar2,p_load_progress varchar2,
p_start_date date,p_end_date date,p_category varchar2, p_operation varchar2,p_seq_id varchar2,p_flag varchar2);
function make_g_higher_level_flag return boolean;
procedure reset_profiles;
function get_base_fact_count return number ;
function create_temp_gilog return boolean;
function create_temp_gdlog return boolean ;
function check_src_fact_snplog return number ;
function load_new_update_data return boolean ;
function set_g_src_join_nl(p_load_size number, p_total_records number) return boolean ;
function recover_from_prot return boolean ;
function read_metadata return boolean;
function initialize(p_multi_thread boolean) return boolean ;
function read_options_table(p_table varchar2) return boolean ;
function COLLECT_FACT_MULTI_THREAD(
p_input_table varchar2
) return boolean ;
procedure COLLECT_FACT_MULTI_THREAD(
p_fact_name varchar2,
p_fact_id number,
p_log_file varchar2,
p_input_table varchar2,
p_ilog varchar2,
p_dlog varchar2,
p_pre_hook varchar2,
p_post_hook varchar2,
p_thread_type varchar2
);
procedure COLLECT_FACT_MULTI_THREAD(
errbuf out nocopy varchar2,
retcode out nocopy varchar2,
p_fact_name varchar2,
p_fact_id number,
p_log_file varchar2,
p_input_table varchar2,
p_ilog varchar2,
p_dlog varchar2,
p_pre_hook varchar2,
p_post_hook varchar2,
p_thread_type varchar2
);
procedure COLLECT_FACT(
errbuf out nocopy varchar2,
retcode out nocopy varchar2,
p_mode varchar2,
p_fact_name varchar2,
p_input_table varchar2,
p_job_id number,
p_ilog_low_end number,
p_ilog_high_end number,
p_ilog varchar2,
p_dlog varchar2,
p_log_file varchar2,
p_thread_type varchar2
);
procedure COLLECT_FACT(
p_mode varchar2,
p_fact_name varchar2,
p_input_table varchar2,
p_job_id number,
p_ilog_low_end number,
p_ilog_high_end number,
p_ilog varchar2,
p_dlog varchar2,
p_log_file varchar2,
p_thread_type varchar2
);
function COLLECT_FACT(
p_mode varchar2,
p_input_table varchar2,
p_ilog_low_end number,
p_ilog_high_end number
) return boolean ;
function initial_set_up(
p_input_table varchar2,
p_max_threads number,
p_ilog_table out nocopy varchar2,
p_dlog_table out nocopy varchar2
) return boolean ;
function set_session_parameters return boolean ;
function make_ok_from_main_ok(
p_main_ok_table_name varchar2,
p_ilog_table varchar2,
p_low_end number,
p_high_end number,
p_mode varchar2
) return boolean ;
function put_rownum_in_log_table return boolean ;
function drop_ilog_dlog_tables(p_ilog varchar2,p_dlog varchar2) return boolean ;
function create_insert_lock_table return boolean;
function drop_insert_lock_table return boolean;
function pre_fact_load_hook(p_derv_fact varchar2,p_src_fact varchar2) return boolean;
function post_fact_load_hook(p_derv_fact varchar2,p_src_fact varchar2) return boolean;
function create_conc_program(
p_temp_conc_name varchar2,
p_temp_conc_short_name varchar2,
p_temp_exe_name varchar2,
p_bis_short_name varchar2
) return boolean;
END;

 

/
