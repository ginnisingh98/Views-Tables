--------------------------------------------------------
--  DDL for Package EDW_SUMMARY_COLLECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_SUMMARY_COLLECT" AUTHID CURRENT_USER AS
/*$Header: EDWSCOLS.pls 115.26 2004/04/06 16:37:33 vsurendr ship $*/

g_all_done boolean;
g_max_fk_density number;
g_dim_direct_load boolean;
g_exec_flag boolean;
g_slow_flag boolean:=true;
g_debug boolean:=true;
g_thread_type varchar2(40);
g_max_threads number;
g_job_status_table varchar2(80);
g_job_id number;
g_jobid_stmt varchar2(400);
g_dim_name varchar2(400);
g_dim_pk varchar2(400);
g_dim_user_pk varchar2(400);
g_ltc_pk varchar2(400); --the ltc value of g_dim_pk
g_ltc_user_pk varchar2(400);
g_dim_name_temp varchar2(400);--the temp table
g_dim_name_temp_int varchar2(400);--the temp table intermediate
g_dim_kl_table varchar2(400); --contains the key lookup. used in slow change
g_dim_kl_table_temp varchar2(400);
g_dim_name_hold varchar2(400);--the hole table, used only for star update
g_dim_name_rowid_hold varchar2(400);--will hold row_id from g_dim_name_hold
g_dim_id number;
g_dim_map_name varchar2(400);
g_dim_map_id number;
g_dim_name_with_slow varchar2(400);--a temp table that holds the dim pk, rowid and slow change cols
g_read_cfig_options boolean;
g_number_rows_inserted number;
g_number_rows_updated number;
g_number_rows_processed number;
g_dim_count number;
g_big_table number;--simply to demarcate a big table from a small table
g_levels EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_order EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_levels_pk EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_levels_alias EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_snapshot_logs EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_status EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_child_level_number EDW_OWB_COLLECTION_UTIL.numberTableType;
g_child_levels EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_child_fk EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_parent_pk EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_levels integer;
/*
store the format of child level, its alias, fk, parent, its alias and its pk
*/
g_fk_pk_child_level EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_fk_pk_child_alias EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_fk_pk_child_fk EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_fk_pk_parent_level EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_fk_pk_parent_alias EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_fk_pk_parent_pk EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_fk_pk_number number;

g_level_map_id EDW_OWB_COLLECTION_UTIL.numberTableType;
g_level_primary_src EDW_OWB_COLLECTION_UTIL.numberTableType;
g_level_primary_target EDW_OWB_COLLECTION_UTIL.numberTableType;
g_dim_col EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_name EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_col EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_mapping number;
g_flag boolean;
g_dim_empty_flag boolean;
g_all_level varchar2(500);
g_all_level_index number;
g_ilog varchar2(400);--the name of the ilog table
g_ilog_main_name varchar2(80);--used in multi threading
g_update_type varchar2(400);--what scheme should update follow...mass, row by row, delete insert...

g_status boolean;
g_status_message varchar2(4000);

G_SLOW_IMPLEMENTED boolean;
g_slow_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_slow_level EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_slow_level_alias EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_slow_level_col EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_slow_cols number;

g_seq_name varchar2(400);

g_temp_insert_stmt varchar2(30000);
g_temp_update_stmt varchar2(30000);
g_temp_int_tm_stmt varchar2(30000);--moves data from the int temp to the temp table
g_temp_pk_update_stmt varchar2(30000);
g_temp_rowid_update_stmt varchar2(30000);
g_insert_stmt_star varchar2(30000);
g_update_stmt_star varchar2(30000);
g_update_stmt_star_row varchar2(30000);
g_hold_insert_stmt  varchar2(30000);
g_forall_size number;
g_conc_id number;
g_conc_name varchar2(400);
g_object_type varchar2(200);
g_consider_snapshot EDW_OWB_COLLECTION_UTIL.booleanTableType;
g_slow_is_name varchar2(400); --name of the itemset containing the columns for the slow change dim
g_lowest_level varchar2(400);
g_lowest_level_index number;
g_lowest_level_global varchar2(400);
g_lowest_level_id number;
g_lowest_level_alias varchar2(40);
g_stmt varchar2(30000);
g_bis_owner varchar2(400);
g_parallel number;
g_collection_size number;
g_table_owner varchar2(400);
/*
the stmts to denormalize
g_from_stmt for example is the from all ltc tables with alias
*/
g_insert_stmt_nopk  varchar2(30000);--insert for all cols except the pk and user pk
g_select_stmt varchar2(30000);
g_select_stmt_nopk varchar2(30000);--select from all ltc but no pk and user pk
g_from_stmt  varchar2(30000);
g_from_stmt_global  varchar2(30000);
g_from_stmt_ilog  varchar2(30000);--for ilog
g_where_stmt  varchar2(30000);
g_where_snplog_stmt varchar2(30000);
g_where_snplog_stmt_ilog varchar2(30000);
g_update_star_flag boolean;
g_insert_star_flag boolean;

g_levels_I EDW_OWB_COLLECTION_UTIL.varcharTableType; /*to enhance perf of insert into ilog, we
first create copy of the LTC table with only the rowid, pk and fk. these hold the names*/
g_levels_copy EDW_OWB_COLLECTION_UTIL.varcharTableType; /*these hold the changes records from the
level tables that need to be denormalized*/
g_snplogs_L EDW_OWB_COLLECTION_UTIL.varcharTableType;/* similarly for the snapshot logs*/
g_snplogs_LT EDW_OWB_COLLECTION_UTIL.varcharTableType;/* similarly for the snapshot logs, temp*/
g_considered_parent EDW_OWB_COLLECTION_UTIL.varcharTableType;/* If a parent level is considered to see if
any rowids of the child need to go, it need not be considered in any other hierarchy again.*/
g_number_considered_parent number;
g_level_change boolean;--means the same as incremental collection

------skipping-------------------------------------
g_skip_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_skip_cols number;
g_skip_item EDW_OWB_COLLECTION_UTIL.booleanTableType;
---------------------------------------------------
g_load_pk number;
g_dim_next_extent number;--storage parameter
g_fresh_restart boolean;
g_op_table_space varchar2(400);
g_rollback varchar2(400);
g_dim_derv_col EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_dim_derv_col_ltc EDW_OWB_COLLECTION_UTIL.varcharTableType;--the corresponding ltc table
g_dim_derv_col_map EDW_OWB_COLLECTION_UTIL.numberTableType;
g_number_dim_derv_col number;
g_dim_derv_col_map_all EDW_OWB_COLLECTION_UTIL.numberTableType;
g_num_dim_derv_col_map_all number;
g_dim_derv_pk_key EDW_OWB_COLLECTION_UTIL.varcharTableType;--what pk_key is needed for higher levels.
g_number_dim_derv_pk_key number;
g_dim_derv_map_id EDW_OWB_COLLECTION_UTIL.numberTableType;
g_derv_fact_id EDW_OWB_COLLECTION_UTIL.numberTableType;
g_derv_fact_full_id EDW_OWB_COLLECTION_UTIL.numberTableType;--for full refresh
g_number_derv_fact_full_id number;
g_src_fact_id EDW_OWB_COLLECTION_UTIL.numberTableType;
g_dim_derv_map_refresh EDW_OWB_COLLECTION_UTIL.booleanTableType;
g_dim_derv_map_full_refresh EDW_OWB_COLLECTION_UTIL.booleanTableType; --does it need full refresh
g_number_dim_derv_map_id number;
g_before_update_table EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_before_update_table_final varchar2(80);--passed to children
g_number_before_update_table number;
g_before_update_table_name varchar2(200);
g_before_update_load_pk number;
g_derv_snp_change_flag boolean;--is there snspshot log change for the cols of interest
g_count_dim_name_hold number;
-------------protection tables------------
g_insert_prot_table varchar2(200);
g_insert_prot_table_active varchar2(200);
g_bu_insert_prot_table varchar2(200);
g_bu_insert_prot_table_active varchar2(200);
-------------------------------------------
g_error_rec_flag boolean;
g_ilog_prev varchar2(400);
g_type_ilog_generation varchar2(400);
g_skip_ilog_update boolean;
g_ilog_small varchar2(400);
g_ll_snplog_has_pk boolean;--does the lowest level snapshot log have the pk_key column in it
g_consider_level EDW_OWB_COLLECTION_UTIL.booleanTableType;
g_consider_col EDW_OWB_COLLECTION_UTIL.booleanTableType;--which cols in the dimension to consider.if there is
--no change to the levels, then why consider those cols
g_insert_stmt_nopk_ins  varchar2(32000);--insert for all cols except the pk and user pk
g_select_stmt_ins varchar2(32000);
g_select_stmt_nopk_ins varchar2(32000);--select from all ltc but no pk and user pk
g_from_stmt_ins  varchar2(32000);
g_from_stmt_global_ins  varchar2(32000);
g_where_stmt_ins  varchar2(32000);
g_called_ltc_ilog_create boolean;
g_use_ltc_ilog EDW_OWB_COLLECTION_UTIL.booleanTableType;
g_src_fk_table EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_src_fk  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_src_fk_table number;
g_ltc_merge_use_nl boolean;
g_hold_insert_stmt_row varchar2(32000);
g_from_stmt_hd_row varchar2(8000);
g_levels_copy_low_hd_ins varchar2(400);--used if g_ltc_merge_use_nl is set to true
g_insert_stmt_star_row varchar2(32000);
g_from_stmt_ins_row  varchar2(8000);
g_dim_inc_refresh_derv boolean;
g_check_fk_change boolean;
g_objects_to_drop EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_objects_to_drop number;
g_ok_switch_update number; --when to swith to update for ok table
g_join_nl_percentage number;--below this %, create index to help NL
G_MIN_JOB_LOAD_SIZE number;
G_SLEEP_TIME number;
G_HASH_AREA_SIZE number;
G_SORT_AREA_SIZE number;
G_TRACE boolean;
g_level_count EDW_OWB_COLLECTION_UTIL.numberTableType;--number of rows in the level tables
g_analyze_freq number;
g_parallel_drill_down boolean;
g_dd_status_table varchar2(100);
procedure collect_dimension(
    p_conc_id number,
	p_conc_name varchar2,
	p_dim_name varchar2,
	p_levels EDW_OWB_COLLECTION_UTIL.varcharTableType,
	p_child_level_number EDW_OWB_COLLECTION_UTIL.numberTableType,
	p_child_levels EDW_OWB_COLLECTION_UTIL.varcharTableType,
	p_child_fk EDW_OWB_COLLECTION_UTIL.varcharTableType,
	p_parent_pk EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_level_snapshot_logs EDW_OWB_COLLECTION_UTIL.varcharTableType,
	p_number_levels number,
	p_debug boolean,
    p_exec_flag boolean,
    p_bis_owner varchar2,
    p_parallel number,
    p_collection_size number,
    p_table_owner varchar2,
    p_forall_size number,
    p_update_type varchar2,
    p_level_order EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_skip_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_skip_cols number,
    p_load_pk number,
    p_fresh_restart boolean,
    p_op_table_space varchar2,
    p_rollback varchar2,
    p_ltc_merge_use_nl boolean,
    p_dim_inc_refresh_derv boolean,
    p_check_fk_change boolean,
    p_ok_switch_update number,
    p_join_nl_percentage number,
    p_read_cfig_options boolean,
    p_max_fk_density number,
    p_analyze_frequency number
    ) ;
procedure init_all(p_job_id number);
procedure get_dim_map_ids ;
Procedure get_lvl_relations ;
Procedure make_temp_insert_sql;
function check_error return boolean ;
Function get_status_message return varchar2 ;
Procedure execute_temp_insert_sql;
PROCEDURE identify_slow_cols;
PROCEDURE make_insert_update_stmt_star;

PROCEDURE execute_insert_update_star(p_count number);

PROCEDURE truncate_ltc_snapshot_logs;
PROCEDURE insert_into_star ;
function initial_insert_into_star(p_multi_thread boolean) return boolean;
PROCEDURE check_dim_star_empty;
function get_number_rows_inserted return number;
function get_number_rows_updated return number;
function get_number_rows_processed return number;
function check_snapshot_logs return boolean;
function get_time return varchar2 ;
procedure write_to_log_file(p_message varchar2) ;
procedure write_to_log_file_n(p_message varchar2) ;
procedure count_temp_table_records ;
procedure make_select_from_where_stmt ;
procedure collect_dimension;
procedure collect_dim_via_temp ;
function set_gilog_status return number;
function delete_gilog_status return boolean ;
procedure insert_into_ilog(p_multi_thread boolean) ;
function create_temp_table return boolean ;
procedure clean_up ;
function recover_from_previous_error return boolean ;
procedure analyze_snplogs ;
procedure make_level_alias ;
function get_level_alias(p_level varchar2) return varchar2 ;
/*
check_temp_table_for_update and check_temp_table_for_insert are to boost performance
*/
function check_temp_table_for_status(p_status varchar2) return boolean ;
procedure execute_hold_insert_stmt;
procedure make_hold_insert_stmt;
function create_ilog_table return boolean ;
function get_snapshot_log return boolean ;
function create_temp_table_int return boolean ;
function create_index_temp_int return boolean ;
function drop_index_temp_int return boolean ;
function create_kl_table return boolean ;
procedure make_temp_int_to_tm_stmt ;
function create_index_temp return boolean ;
function drop_index_temp return boolean ;
procedure execute_temp_int_to_tm_stmt ;
function create_gilog_T(p_snp_log varchar2,p_ilog_temp varchar2) return boolean;
function execute_update_stmt return number;
function create_ltc_ilog_table(p_mode varchar2) return boolean ;
function drill_down_net_change(p_multi_thread boolean) return boolean ;
function create_snp_L_tables return boolean ;
function insert_into_LT(p_child_level varchar2, p_parent_level varchar2,p_mode varchar2) return boolean ;
function find_rowid_parent_change(p_level varchar2) return boolean ;
function insert_into_ilog_from_L(p_multi_thread boolean) return boolean ;
function create_ltc_copies(p_mode varchar2) return boolean ;
function find_rowid_child_change(p_level varchar2,p_mode varchar2) return boolean ;
function drill_up_net_change(p_mode varchar2) return boolean ;
function recreate_from_stmt return boolean ;
function drop_L_tables return boolean ;
function drop_I_tables return boolean ;
function drop_ltc_copies return boolean ;
function create_L_from_ilog return boolean ;
function name_op_tables(p_job_id number) return boolean;
function create_g_dim_name_with_slow return boolean;
function create_hold_index return boolean ;
function create_dim_name_rowid_hold return boolean ;
function reset_profiles return boolean;
procedure insert_into_load_progress(p_load_fk number,p_object_name varchar2,p_load_progress varchar2,
  p_start_date date,p_end_date date,p_category varchar2, p_operation varchar2,p_seq_id varchar2,p_flag varchar2);
procedure insert_into_load_progress_d(p_load_fk number,p_object_name varchar2,p_load_progress varchar2,
  p_start_date date,p_end_date date,p_category varchar2, p_operation varchar2,p_seq_id varchar2,p_flag varchar2);
procedure analyze_star_table ;
function get_dim_storage return boolean ;
function is_dim_in_derv_map return boolean ;
function get_derv_fact_map_details(p_mapping_id number) return boolean;
function log_before_update_data return boolean ;
function create_before_update_table return boolean ;
function get_ltc_for_dim_col(p_col varchar2) return varchar2 ;
function get_max_fk_density(p_dim_id number,p_src_fact_id number,p_dim_derv_map_id number) return number;
function create_prot_table(p_table varchar2,p_table_active varchar2) return boolean ;
function drop_prot_table(p_table varchar2,p_table_active varchar2) return boolean ;
function drop_restart_tables return boolean;
function create_gilog_small return boolean;
function create_dummy_ilog return boolean;
function check_ll_snplog_col return number;
procedure make_select_from_where_ins ;
function set_level_I_flag return boolean ;
function create_ltc_copy_low_hd_ins(p_mode varchar2) return boolean;
function create_hold_table return boolean ;
function execute_insert_stmt return boolean ;
function reset_temp_opcode return boolean;
function find_all_affected_levels(
p_job_id number,
p_affected_levels out NOCOPY EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_affected_levels out NOCOPY number) return boolean ;
function get_parent(p_child_level varchar2,p_parent_ltc EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_child_ltc EDW_OWB_COLLECTION_UTIL.varcharTableType, p_number_hier number,
p_parent out NOCOPY EDW_OWB_COLLECTION_UTIL.varcharTableType, p_number_parent out NOCOPY number) return boolean ;
function set_g_type_ilog_generation return boolean;
function log_pk_into_insert_prot return boolean ;
function log_pk_into_bu_insert_prot return boolean ;
function get_before_update_table_name return boolean;
function read_options_table(p_table_name varchar2) return boolean;
procedure clean_up_job;
function make_ok_from_main_ok(
p_main_ok_table_name varchar2,
p_low_end number,
p_high_end number
) return boolean;
procedure collect_dimension_main(
    p_conc_id number,
    p_conc_name varchar2,
    p_dim_name varchar2,
    p_levels EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_child_level_number EDW_OWB_COLLECTION_UTIL.numberTableType,
    p_child_levels EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_child_fk EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_parent_pk EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_level_snapshot_logs EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_levels number,
    p_debug boolean,
    p_exec_flag boolean,
    p_bis_owner varchar2,
    p_parallel number,
    p_collection_size number,
    p_table_owner varchar2,
    p_forall_size number,
    p_update_type varchar2,
    p_level_order EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_skip_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_skip_cols number,
    p_load_pk number,
    p_fresh_restart boolean,
    p_op_table_space varchar2,
    p_rollback varchar2,
    p_ltc_merge_use_nl boolean,
    p_dim_inc_refresh_derv boolean,
    p_check_fk_change boolean,
    p_ok_switch_update number,
    p_join_nl_percentage number,
    p_thread_type varchar2,
    p_max_threads number,
    p_min_job_load_size number,
    p_sleep_time number,
    p_job_status_table varchar2,
    p_hash_area_size number,
    p_sort_area_size number,
    p_trace boolean,
    p_read_cfig_options boolean,
    p_max_fk_density number,
    p_analyze_frequency number,
    p_parallel_drill_down boolean,
    p_dd_status_table varchar2
    ) ;
procedure collect_dimension_multi_thread(
    p_conc_id number,
    p_conc_name varchar2,
    p_dim_name varchar2,
    p_levels EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_child_level_number EDW_OWB_COLLECTION_UTIL.numberTableType,
    p_child_levels EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_child_fk EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_parent_pk EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_level_snapshot_logs EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_levels number,
    p_debug boolean,
    p_exec_flag boolean,
    p_bis_owner varchar2,
    p_parallel number,
    p_collection_size number,
    p_table_owner varchar2,
    p_forall_size number,
    p_update_type varchar2,
    p_level_order EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_skip_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_skip_cols number,
    p_load_pk number,
    p_fresh_restart boolean,
    p_op_table_space varchar2,
    p_rollback varchar2,
    p_ltc_merge_use_nl boolean,
    p_dim_inc_refresh_derv boolean,
    p_check_fk_change boolean,
    p_ok_switch_update number,
    p_join_nl_percentage number,
    p_thread_type varchar2,
    p_max_threads number,
    p_min_job_load_size number,
    p_sleep_time number,
    p_job_status_table varchar2,
    p_hash_area_size number,
    p_sort_area_size number,
    p_trace boolean,
    p_read_cfig_options boolean,
    p_max_fk_density number,
    p_analyze_frequency number,
    p_parallel_drill_down boolean,
    p_dd_status_table varchar2
    ) ;
function initial_set_up(
p_table_name varchar2,
p_max_threads number,
p_debug boolean,
p_ok_table out nocopy varchar2) return boolean;
procedure COLLECT_DIMENSION(
errbuf out nocopy varchar2,
retcode out nocopy varchar2,
p_dim_name varchar2,
p_table_name varchar2,--input table
p_job_id number,
p_ok_low_end number,
p_ok_high_end number
);
procedure COLLECT_DIMENSION(
p_dim_name varchar2,
p_table_name varchar2,--input table
p_job_id number,
p_ok_low_end number,
p_ok_high_end number
);
function COLLECT_DIMENSION(
p_table_name varchar2,--input table
p_ok_low_end number,
p_ok_high_end number
) return boolean;
function drop_input_tables(p_table_name varchar2) return boolean;
function set_session_parameters return boolean ;
function put_rownum_in_ok_table return boolean;
function create_conc_program(
p_temp_conc_name varchar2,
p_temp_conc_short_name varchar2,
p_temp_exe_name varchar2,
p_bis_short_name varchar2
) return boolean;
function insert_L_ilog_parallel_dd(p_multi_thread boolean) return boolean;
END EDW_SUMMARY_COLLECT;

 

/
