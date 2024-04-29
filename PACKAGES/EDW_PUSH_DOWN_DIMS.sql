--------------------------------------------------------
--  DDL for Package EDW_PUSH_DOWN_DIMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_PUSH_DOWN_DIMS" AUTHID CURRENT_USER AS
/*$Header: EDWPSDNS.pls 115.8 2003/07/29 00:22:24 vsurendr ship $*/

g_skip_ilog_update EDW_OWB_COLLECTION_UTIL.booleanTableType;
g_job_id number;
g_jobid_stmt varchar2(200);
g_log_file varchar2(2000);
g_input_table varchar2(200);
g_stmt varchar2(32000);
g_thread_type varchar2(40);
g_max_threads number;
g_min_job_load_size number;
g_sleep_time number;
g_hash_area_size number;
g_sort_area_size number;
g_trace boolean;
g_read_cfig_options boolean;
g_status_message varchar2(4000);
g_status boolean;
g_dim_name varchar2(400);
g_dim_id number;
g_lowest_level varchar2(400);
g_levels EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_ids EDW_OWB_COLLECTION_UTIL.numberTableType;
g_level_pk  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_seq EDW_OWB_COLLECTION_UTIL.varcharTableType;
--g_lstg_tables EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_child_level_number  EDW_OWB_COLLECTION_UTIL.numberTableType;
g_child_levels  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_child_fk  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_parent_pk EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_order EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_snapshot_logs EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_ilog  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_ilog_count  EDW_OWB_COLLECTION_UTIL.numberTableType;
g_level_ilog_name  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_ilog_main  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_ilog_found  EDW_OWB_COLLECTION_UTIL.booleanTableType;
g_level_full_insert EDW_OWB_COLLECTION_UTIL.booleanTableType;
g_level_consider  EDW_OWB_COLLECTION_UTIL.booleanTableType;
g_insert_rowid  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_update_rowid  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_analyze_needed  EDW_OWB_COLLECTION_UTIL.booleanTableType;
g_number_levels number;
g_debug boolean;
g_parallel number;
g_collection_size number;
g_bis_owner  varchar2(400);
g_table_owner  varchar2(400);
g_full_refresh boolean;

g_level_prefix EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_display_prefix EDW_OWB_COLLECTION_UTIL.varcharTableType;

g_final_levels  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_final_child_levels EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_final_next_parent  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_final_fk  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_final_next_pk  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_final_pk_value  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_final_pk_prefix EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_final_fk_prefix EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_final number;
g_forall_size number;
g_update_type varchar2(400);
g_join_nl_percentage number;

--REMOVE
g_count number;
g_insert_stmt  EDW_OWB_COLLECTION_UTIL.LLL_varcharTableType;
g_insert_flag  EDW_OWB_COLLECTION_UTIL.booleanTableType;
g_update_stmt  EDW_OWB_COLLECTION_UTIL.LLL_varcharTableType;
g_update_stmt_row EDW_OWB_COLLECTION_UTIL.LLL_varcharTableType;
g_update_flag  EDW_OWB_COLLECTION_UTIL.booleanTableType;
g_level_id number;
g_load_pk number;
g_op_table_space varchar2(400);
g_rollback  varchar2(400);
g_snplog_has_pk EDW_OWB_COLLECTION_UTIL.booleanTableType;
g_type_ilog_generation varchar2(200);
g_ltc_copy EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_diamond_level EDW_OWB_COLLECTION_UTIL.varcharTableType;--levels that are at the head of a diamond
g_number_diamond_level number;
g_parent_ltc EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_child_ltc EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_hier EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_ltc number;
g_distinct_hier EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_distinct_hier number;

function push_down_all_levels(
   p_dim_name varchar2,
   p_levels EDW_OWB_COLLECTION_UTIL.varcharTableType,
   p_child_level_number EDW_OWB_COLLECTION_UTIL.numberTableType,
   p_child_levels EDW_OWB_COLLECTION_UTIL.varcharTableType,
   p_child_fk EDW_OWB_COLLECTION_UTIL.varcharTableType,
   p_parent_pk EDW_OWB_COLLECTION_UTIL.varcharTableType,
   p_number_levels number,
   p_level_order  EDW_OWB_COLLECTION_UTIL.varcharTableType,
   p_level_snapshot_logs  EDW_OWB_COLLECTION_UTIL.varcharTableType,
   p_debug boolean,
   p_parallel number,
   p_collection_size number,
   p_bis_owner  varchar2,
   p_table_owner varchar2,
   p_full_refresh boolean,
   p_forall_size number,
   p_update_type varchar2,
   p_load_pk number,
   p_op_table_space varchar2,
   p_dim_push_down out NOCOPY boolean,
   p_rollback varchar2,
   p_thread_type varchar2,
   p_max_threads number,
   p_min_job_load_size number,
   p_sleep_time number,
   p_hash_area_size number,
   p_sort_area_size number,
   p_trace boolean,
   p_read_cfig_options boolean,
   p_join_nl_percentage number
   ) return boolean ;
procedure PUSH_DOWN_ALL_LEVELS(
errbuf out nocopy varchar2,
retcode out nocopy varchar2,
p_dim_name varchar2,
p_log_file varchar2,
p_input_table varchar2,
p_job_id number,
p_ok_low_end number,
p_ok_high_end number,
p_job_status_table varchar2
);
procedure PUSH_DOWN_ALL_LEVELS(
p_dim_name varchar2,
p_log_file varchar2,
p_input_table varchar2,
p_job_id number,
p_ok_low_end number,
p_ok_high_end number,
p_job_status_table varchar2
) ;
function PUSH_DOWN_ALL_LEVELS(
p_ok_low_end number,
p_ok_high_end number
) return boolean;
function push_down_all_levels_multi return boolean ;
procedure init_all(p_job_id number);
function get_time return varchar2 ;
procedure write_to_log_file(p_message varchar2) ;
procedure write_to_log_file_n(p_message varchar2) ;
function get_level_prefix return boolean ;
function get_level_display_prefix return boolean ;
function get_all_children_main return boolean ;
function get_level_index(p_level varchar2) return number ;
function get_all_children(p_index number) return boolean;
function get_all_children_rec(p_index number, p_level varchar2,
                              p_prefix varchar2,p_pk varchar2) return boolean ;
function level_child_found(p_level varchar2, p_child_level varchar2) return boolean ;
function get_ltc_pk(p_index number) return varchar2;
function get_ltc_pk(p_level varchar2) return varchar2 ;
function push_down_all_levels_single return boolean ;
function push_down_level(p_level varchar2) return boolean ;
function get_user_key(p_key varchar2) return varchar2;
function get_all_level_pk return boolean ;
function does_snp_have_data(p_level varchar2) return boolean ;
function get_level_snplog(p_level varchar2) return varchar2 ;
function set_gilog_status(p_ilog in out NOCOPY varchar2,p_index number) return number;
function check_levels_for_data return boolean;
function get_index_for_level(p_level varchar2) return number;
function get_fks_without_fk(p_level varchar2, p_fk varchar2,
    p_fks_out out NOCOPY  EDW_OWB_COLLECTION_UTIL.varcharTableType,p_number_fks_out out NOCOPY number) return boolean ;
function make_sql_stmts(p_level varchar2) return boolean;
function get_level_seq return boolean ;
function find_lowest_level return boolean ;
procedure clean_up;
function update_gilog(p_ilog varchar2) return boolean ;
function move_data_into_ilog return boolean ;
function move_data_into_ilog(p_index number) return boolean;
function create_ilog_tables return boolean;
function create_ilog_tables(p_index number) return boolean;
function analyze_ltc_tables return boolean ;
procedure drop_ilog;
function execute_update_stmt(p_update_stmt varchar2,p_update_stmt_row varchar2,p_update_rowid_table varchar2)
return boolean;
procedure insert_into_load_progress_d(p_load_fk number,p_object_name varchar2,p_load_progress varchar2,
  p_start_date date,p_end_date date,p_category varchar2, p_operation varchar2,p_seq_id varchar2,p_flag varchar2) ;
function find_ltc_to_push_down return number;
function make_and_exec_sql_stmts(p_parent_level varchar2,p_child_level varchar2,p_ilog varchar2) return boolean ;
function create_ilog_copy(p_ilog varchar2,p_ilog_copy varchar2) return boolean ;
function find_diamond_levels return boolean ;
function get_diamond_tops(p_parent_level varchar2,p_diamond_tops out NOCOPY EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_diamond_tops out NOCOPY number) return boolean ;
function get_level_for_fk(p_child_level varchar2,p_fk varchar2) return varchar2 ;
function is_below_diamond_top(p_other_fk_level varchar2,p_diamond_tops varchar2) return boolean ;
function get_way_to_child(p_parent_level varchar2,p_child_level varchar2,
p_parent_level_order out NOCOPY EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_child_level_order out NOCOPY EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_parent_pk_order out NOCOPY EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_child_fk_order out NOCOPY EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_level_order out NOCOPY number) return boolean ;
function create_child_dia_fk_table(
p_parent_level varchar2,
p_child_level varchar2,
p_parent_level_order  EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_child_level_order  EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_parent_pk_order  EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_child_fk_order  EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_level_order  number,
p_ilog varchar2,
p_other_fks EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_below_diamond_flag EDW_OWB_COLLECTION_UTIL.booleanTableType,
p_number_other_fks number,
p_diamond_fk_table out NOCOPY varchar2) return boolean ;
function check_level_for_column return boolean ;
function merge_all_ilog_tables return boolean ;
function push_down_all_levels return boolean ;
function put_rownum_in_ilog_table(p_index number) return boolean ;
function create_ilog_from_main(p_low_end number,p_high_end number) return boolean ;
function set_session_parameters return boolean ;
function read_options_table(p_input_table varchar2) return boolean ;
function drop_input_tables(p_table_name varchar2) return boolean ;
function create_conc_program(
p_temp_conc_name varchar2,
p_temp_conc_short_name varchar2,
p_temp_exe_name varchar2,
p_bis_short_name varchar2
) return boolean;
END EDW_PUSH_DOWN_DIMS;

 

/
