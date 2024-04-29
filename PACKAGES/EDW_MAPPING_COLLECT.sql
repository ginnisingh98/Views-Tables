--------------------------------------------------------
--  DDL for Package EDW_MAPPING_COLLECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_MAPPING_COLLECT" AUTHID CURRENT_USER AS
/*$Header: EDWMAPFS.pls 115.40 2004/04/06 16:36:03 vsurendr ship $*/

g_rownum_for_seq_num number;
g_sleep_time number;
g_min_job_load_size number;
g_dup_multi_thread_flag boolean;
g_analyze_freq number;
g_job_id number;
g_max_threads number;
g_thread_type varchar2(40);
g_trace boolean;
g_hash_area_size number;
g_sort_area_size number;
g_read_cfig_options boolean;
g_stmt varchar2(30000);
g_fstgTableName varchar2(240);
g_factTableName varchar2(240);
g_fstgPKName varchar2(240);
g_factPKName varchar2(240);
g_factPKNameKey varchar2(240);
g_fstgPKNameKey varchar2(240);
g_pk_direct_load boolean;
g_debug boolean;
g_ok_low_end number;
g_ok_high_end number;
g_main_ok_table_name varchar2(80);
g_dimTableName  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_dimTableName_kl  EDW_OWB_COLLECTION_UTIL.varcharTableType; --key lookup. used for representing the key look up
--table (facts and slowly changing dims)
g_dimTableId EDW_OWB_COLLECTION_UTIL.numberTableType;
g_dimUserPKName EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_dimActualPKName EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_job_status_table varchar2(80);--used to communicate between main thread and child threads
g_jobid_stmt varchar2(80);
--the sequences
g_sequence EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_sequence_id EDW_OWB_COLLECTION_UTIL.numberTableType;
g_number_sequence number:=1;

g_fstgUserFKName EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_fstgActualFKName EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_fstg_fk_direct_load EDW_OWB_COLLECTION_UTIL.booleanTableType;--if fk_key is populated by the push program,
g_fstg_all_fk_direct_load boolean; --true if all fks are direct load
--this is true else false and we need to look up and generate the surr key
g_fstg_fk_value_load EDW_OWB_COLLECTION_UTIL.booleanTableType;--if a value needs to be directly loaded like edwna
g_fstg_fk_load_value EDW_OWB_COLLECTION_UTIL.varcharTableType;--the value to load

g_skip_item  EDW_OWB_COLLECTION_UTIL.booleanTableType;--if a column needs to be skipped
--g_number_skip_item number;
g_skip_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_skip_cols number;
g_fact_count number;
g_factFKName EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_numberOfDimTables number:=1;
--g_numberOfDimTables should be the number of
--fk mappings because even if we have 2 fks to time
--dim, there will be 2 usages of time dim

--the mapping. only the measures. and PKs. FKs have already been taken care of...
g_fstg_mapping_columns EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_fact_mapping_columns EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_num_ff_map_cols number:=1;
g_number_groupby_cols number;
G_GROUPBY_COLS  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_update_type varchar2(400);--what scheme should update follow...mass, row by row, delete insert...
g_mode varchar2(400);
g_instance_type varchar2(400);

g_duplicate_collect boolean;
g_collection_size number;
g_forall_size number;
g_request_id number;
g_surrogate_stmt varchar2(32000); --insert into the surr table
g_exp_plan_stmt varchar2(32000);
g_opcode_stmt varchar2(20000);
g_surrogate_update_stmt varchar2(32000); --update the staging table coll status and op code
g_duplicate_stmt varchar2(30000);
g_dup_insert_stmt  varchar2(10000);
g_insert_stmt varchar2(32000);
g_insert_stmt_row varchar2(32000);
g_insert_stmt_ctas varchar2(32000);
g_insert_ctas_table varchar2(200);
g_audit_net_insert_stmt varchar2(32000);
g_audit_net_insert_stmt_row varchar2(32000);
g_update_stmt varchar2(32000);
g_update_stmt_row varchar2(32000);
g_hd_insert_stmt  varchar2(32000);
g_delete_stmt varchar2(30000);
G_COLLECT_COLLECTED_STMT  varchar2(10000);
g_fact_dlog varchar2(400);
g_fact_dlog_stmt  varchar2(32000); --for moving the data from the fact to the dlog for inserts
g_fact_delete_dlog_stmt varchar2(32000);
g_mapping_name varchar2(400);
g_mapping_id number;
g_mapping_type varchar2(200);
g_object_type varchar2(400);
g_primary_src number;
g_primary_src_name varchar2(400);
g_primary_target number;
g_primary_target_name varchar2(400);
g_object_type_name varchar2(400);
g_dup_table  varchar2(400);--for holding the max(rowids)
g_dup_hold_table varchar2(400);--for holding the real dup rowids
g_dup_hold_table_number number;
g_dup_hold_pk_table varchar2(400);--for holding the dup pks. only temp use
g_dup_rownum varchar2(400);
g_dup_rownum_rowid varchar2(400);
g_surr_table  varchar2(400);--for holding the surr keys
g_surr_table_name varchar2(400);
g_user_fk_table varchar2(400);
g_user_fk_table_count number;
g_user_key_hold_table varchar2(400);
g_opcode_table  varchar2(400);--will hold the op code and rowid.
g_opcode_table_count number;
g_hold_table  varchar2(400);--for speeding up updates
g_error_rowid_table varchar2(400);--for holding the rowid of staging when there is dup and dang
g_ok_rowid_table varchar2(400);--after duplicate cheking, all the good rowids are stored here
g_dup_err_rec_table varchar2(400); --for error recovery dup check
g_dup_err_rec_flag boolean;
g_ok_rowid_number number; --number of rows in g_ok_rowid_table
g_dup_insert_number number;--number of rows inserted into g_dup_table
g_collections_done boolean;--maeks when the collections are done
g_err_rec_flag boolean;
g_drop_objects EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_drop_objects number;

g_status boolean;
g_status_message varchar2(4000);

g_conc_program_id number;--this is actually the request id...
g_conc_program_name varchar2(200);
g_key_set number;--how many fk to consider at a time to do key transformation
g_execute_flag boolean;
g_number_rows_processed number;
g_number_rows_ready  number; --how many ready in each cycle
g_fact_audit boolean;
g_fact_net_change boolean;
g_item_audit EDW_OWB_COLLECTION_UTIL.varcharTableType;--the columns that are in audit for the fac
g_item_audit_number number;
g_item_audit_all EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_item_audit_number_all number;

g_item_net_change EDW_OWB_COLLECTION_UTIL.varcharTableType;--the columns that are in audit for the fac
g_item_net_change_number number;
g_item_net_change_all EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_item_net_change_number_all number;

g_fact_audit_name varchar2(400);
g_fact_net_change_name varchar2(400);
g_fact_audit_is_name varchar2(400); --the name of the item set
g_fact_net_change_is_name varchar2(400); --the name of the item set
g_fact_rowid EDW_OWB_COLLECTION_UTIL.rowidTableType;
g_number_fact_rowid number;
g_groupby_on boolean;
g_groupby_stmt varchar2(10000);
g_request_id_stmt varchar2(10000);

g_request_id_table EDW_OWB_COLLECTION_UTIL.numberTableType; --the request ids in  this collection
g_request_id_count EDW_OWB_COLLECTION_UTIL.numberTableType;--the count(*) for the req ids
g_number_request_id_table number;
g_total_records number;--the grand total of all the records to collect
g_target_rec_count number;
g_stg_join_nl_percentage number;
g_stg_join_nl boolean;
g_ok_switch_update number;
g_stg_make_copy_percentage number;/*this is the % below which we firt make a copy from the stg table
for all processing. this will minimize repeated join to the large stg table*/
g_stg_copy_table varchar2(200);
g_stg_copy_table_flag boolean;
/*******************************************************/
/**************Record the number of rows processed and errors*****/
g_ins_rows_ready EDW_OWB_COLLECTION_UTIL.numberTableType;
g_ins_rows_processed EDW_OWB_COLLECTION_UTIL.numberTableType;
g_ins_rows_collected EDW_OWB_COLLECTION_UTIL.numberTableType;
g_ins_rows_dangling EDW_OWB_COLLECTION_UTIL.numberTableType;
g_ins_rows_duplicate EDW_OWB_COLLECTION_UTIL.numberTableType;
g_ins_rows_error EDW_OWB_COLLECTION_UTIL.numberTableType;
g_ins_instance_name EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_ins_request_id_table  EDW_OWB_COLLECTION_UTIL.numberTableType;
g_ins_collection_status EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_ins_req_coll number;
g_instance_column varchar2(400);--this is the col that is either instance_fk or instance or instance_code
g_instance_dim_name varchar2(400); --the instance dimension name
/*******************************************************/

/*
   order by stmt for collect duplicates
*/
g_order_by_stmt varchar2(10000);
g_object_name varchar2(400);
g_object_id number;
g_temp_log boolean;
g_parallel number;
g_table_owner varchar2(400);
g_bis_owner varchar2(400);
g_insert_flag boolean;
g_update_flag boolean;
g_delete_flag boolean;
g_creation_date_flag boolean;
g_last_update_date_flag boolean;

g_slow_change_tables EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_num_slow_change_tables number;
g_exp_operation EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_exp_object_name EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_exp_options EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_exp_cardinality EDW_OWB_COLLECTION_UTIL.numberTableType;
g_number_exp_plan number;
g_fts_tables EDW_OWB_COLLECTION_UTIL.varcharTableType; --full table scan tables
g_number_fts_tables number;
g_plan_table varchar2(400);
g_explain_plan_check boolean;
g_fact_audit_net_table  varchar2(400);
g_fa_ilog   varchar2(400);
g_nc_ilog   varchar2(400);
g_fa_rec_log   varchar2(400);--used only for error recovery
g_nc_rec_log   varchar2(400);
g_fa_rec_up_log   varchar2(400);--used only for error recovery
g_nc_rec_up_log   varchar2(400);

g_is_source boolean;
g_is_custom_source boolean;
g_is_delete_trigger_imp boolean;

g_surr_tables EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_surr_tables number;
g_surr_tables_fk EDW_OWB_COLLECTION_UTIL.varcharTableType;--what fk is each holding
g_surr_tables_count EDW_OWB_COLLECTION_UTIL.numberTableType;

g_dlog_rowid_table varchar2(400);
--g_update_dlog_rowid_table varchar2(400);
--g_update_dlog_hold_table  varchar2(400);
g_update_dlog_lookup_table varchar2(400);--contains the row_id and rowid from g_fact_dlog when there is error recovery
g_naedw_value number;

g_total_insert number;
g_total_update number;
g_total_delete number;
g_reqid_table varchar2(400);
g_load_pk number;
g_load_type varchar2(400);--INITIAL or INC
g_ok_rowid_table_prev varchar2(400);
g_type_ok_generation varchar2(400);
g_skip_ilog_update boolean;
g_dlog_columns EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_dlog_columns number;
g_dlog_has_data boolean;
g_fresh_restart boolean;
g_op_table_space varchar2(400);
g_rollback varchar2(400);
g_surr_table_LHJM boolean;--decides if create main surr tables runs 2 tables at a time.
g_low_system_mem boolean;
g_skip_update boolean;
g_skip_delete boolean;
g_smart_update boolean;
g_hold_table_temp varchar2(400);
g_smart_update_name varchar2(400);
g_smart_update_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_smart_update_cols number;
g_fact_next_extent number;
g_hold_table_count number;
g_skip_levels EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_skip_levels number;
g_number_rows_dangling number;
g_max_round number;
g_fk_use_nl number;
g_fact_use_nl boolean;
g_dim_row_count EDW_OWB_COLLECTION_UTIL.numberTableType;
g_fact_smart_update number;
g_fks_dang_load EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_fks_dang_load number;
g_dim_auto_dang_table EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_dim_auto_dang_table_dim varchar2(200);
g_dim_lowest_ltc EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_dim_lowest_ltc_id EDW_OWB_COLLECTION_UTIL.numberTableType;
g_auto_dang_table_extn varchar2(40);
g_log_dang_keys boolean;
g_create_parent_table_records boolean;--in test mode do we create parent table records?
g_check_fk_change boolean;
-----------------------------------------------------------
g_dim_pk_structure EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_dim_pk_dim  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_dim_pk_instance EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_dim_pk_structure number;
g_dim_pk_structure_index  EDW_OWB_COLLECTION_UTIL.numberTableType;
g_dim_pk_structure_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_dim_pk_structure_cols number;
-----------------------------------------------------------

---------data alignment----------
g_da_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_da_cols number;
g_stg_da_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;--corresponding stg columns
g_da_table varchar2(400);
g_da_op_table varchar2(400);--mother of all da op tables
g_pp_table varchar2(400);
g_master_instance varchar2(400);
g_pk_key_seq varchar2(400);
g_pk_key_seq_pos number;--position in the mapping
g_dup_pp_row_id_table varchar2(400);--row_ids from g_dup_table. will be used to populate g_dup_pp_table.
g_dup_pp_table  varchar2(400);--will contain the rejected dup rows. will be used to populate pp table
g_dimTable_da_flag EDW_OWB_COLLECTION_UTIL.booleanTableType;--is data alignment implemented
g_dimTableName_pp EDW_OWB_COLLECTION_UTIL.varcharTableType;--the pp table for data alignment
g_dimTableName_da EDW_OWB_COLLECTION_UTIL.varcharTableType;--the DA table for data alignment
g_dimTable_slow_flag EDW_OWB_COLLECTION_UTIL.booleanTableType;--if slowly chaging dim is implemented or not
---------------------------------
g_use_mti boolean;--perf improvement with multi table insert for 9i
g_user_measure_table varchar2(400);
g_user_measure_table_count number;
g_fstg_columns EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_fstg_columns number;
g_data_type edw_owb_collection_util.varcharTableType;
g_data_length edw_owb_collection_util.varcharTableType;
g_num_distinct edw_owb_collection_util.numberTableType;
g_num_nulls edw_owb_collection_util.numberTableType;
g_avg_col_length edw_owb_collection_util.numberTableType;
---------------------------------
g_surr_count number;
g_int_upd_status_table_name varchar2(40);
g_job_queue_processes number;
g_ltc_drill_down_job_id number;
g_parallel_drill_down boolean;
g_dd_status_table varchar2(100);
g_ul_table varchar2(100);
---------------------------------
procedure COLLECT_MAIN(
    p_object_name in varchar2,
    p_mapping_id in number,
    p_map_type in varchar2,
    p_primary_src in number,
    p_primary_target in number,
    p_primary_target_name varchar2,
    p_object_type varchar2,
    p_conc_id in number,
    p_conc_program_name in varchar2,
    p_status out NOCOPY boolean,
    p_fact_audit boolean,
    p_net_change boolean,
    p_fact_audit_name varchar2,
    p_net_change_name varchar2,
    p_fact_audit_is_name varchar2,
    p_net_change_is_name varchar2,
    p_debug boolean,
    p_duplicate_collect boolean,
    p_execute_flag boolean,
    p_request_id number,
    p_collection_size number,
    p_parallel number,
    p_table_owner varchar2,
    p_bis_owner  varchar2,
    p_temp_log boolean,
    p_forall_size number,
    p_update_type varchar2,
    p_mode varchar2,
    p_explain_plan_check boolean,
    p_fact_dlog varchar2,
    p_key_set number,
    p_instance_type varchar2,
    p_load_pk number,
    p_skip_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_skip_cols number,
    p_fresh_restart boolean,
    p_op_table_space varchar2,
    p_da_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_da_cols number,
    p_da_table varchar2,
    p_pp_table varchar2,
    p_master_instance varchar2,
    p_rollback varchar2,
    p_skip_levels EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_skip_levels number,
    p_smart_update boolean,
    p_fk_use_nl number,
    p_fact_smart_update number,
    p_auto_dang_table_extn varchar2,
    p_log_dang_keys boolean,
    p_create_parent_table_records boolean,
    p_smart_update_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_smart_update_cols number,
    p_check_fk_change boolean,
    p_stg_join_nl_percentage number,
    p_ok_switch_update number,
    p_stg_make_copy_percentage number,
    p_hash_area_size number,
    p_sort_area_size number,
    p_trace boolean,
    p_read_cfig_options boolean,
    p_min_job_load_size number,
    p_sleep_time number,
    p_thread_type varchar2,
    p_max_threads number,
    p_job_status_table varchar2,
    p_analyze_frequency number,
    p_parallel_drill_down boolean,
    p_dd_status_table varchar2
    ) ;
procedure COLLECT_MULTI_THREAD(
    p_object_name in varchar2,
    p_mapping_id in number,
    p_map_type in varchar2,
    p_primary_src in number,
    p_primary_target in number,
    p_primary_target_name varchar2,
    p_object_type varchar2,
    p_conc_id in number,
    p_conc_program_name in varchar2,
    p_status out NOCOPY boolean,
    p_fact_audit boolean,
    p_net_change boolean,
    p_fact_audit_name varchar2,
    p_net_change_name varchar2,
    p_fact_audit_is_name varchar2,
    p_net_change_is_name varchar2,
    p_debug boolean,
    p_duplicate_collect boolean,
    p_execute_flag boolean,
    p_request_id number,
    p_collection_size number,
    p_parallel number,
    p_table_owner varchar2,
    p_bis_owner  varchar2,
    p_temp_log boolean,
    p_forall_size number,
    p_update_type varchar2,
    p_mode varchar2,
    p_explain_plan_check boolean,
    p_fact_dlog varchar2,
    p_key_set number,
    p_instance_type varchar2,
    p_load_pk number,
    p_skip_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_skip_cols number,
    p_fresh_restart boolean,
    p_op_table_space varchar2,
    p_da_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_da_cols number,
    p_da_table varchar2,
    p_pp_table varchar2,
    p_master_instance varchar2,
    p_rollback varchar2,
    p_skip_levels EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_skip_levels number,
    p_smart_update boolean,
    p_fk_use_nl number,
    p_fact_smart_update number,
    p_auto_dang_table_extn varchar2,
    p_log_dang_keys boolean,
    p_create_parent_table_records boolean,
    p_smart_update_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_smart_update_cols number,
    p_check_fk_change boolean,
    p_stg_join_nl_percentage number,
    p_ok_switch_update number,
    p_stg_make_copy_percentage number,
    p_hash_area_size number,
    p_sort_area_size number,
    p_trace boolean,
    p_read_cfig_options boolean,
    p_min_job_load_size number,
    p_sleep_time number,
    p_thread_type varchar2,
    p_max_threads number,
    p_job_status_table varchar2,
    p_analyze_frequency number,
    p_parallel_drill_down boolean,
    p_dd_status_table varchar2
    );
procedure COLLECT(
    p_object_name in varchar2,
    p_mapping_id in number,
	p_map_type in varchar2,
	p_primary_src in number,
	p_primary_target in number,
	p_primary_target_name varchar2,
	p_object_type varchar2,
	p_conc_id in number,
	p_conc_program_name in varchar2,
	p_status out NOCOPY boolean,
    p_fact_audit boolean,
    p_net_change boolean,
    p_fact_audit_name varchar2,
    p_net_change_name varchar2,
    p_fact_audit_is_name varchar2,
    p_net_change_is_name varchar2,
	p_debug boolean,
    p_duplicate_collect boolean,
    p_execute_flag boolean,
    p_request_id number,
    p_collection_size number,
    p_parallel number,
    p_table_owner varchar2,
    p_bis_owner  varchar2,
    p_temp_log boolean,
    p_forall_size number,
    p_update_type varchar2,
    p_mode varchar2,
    p_explain_plan_check boolean,
    p_fact_dlog varchar2,
    p_key_set number,
    p_instance_type varchar2,
    p_load_pk number,
    p_skip_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_skip_cols number,
    p_fresh_restart boolean,
    p_op_table_space varchar2,
    p_da_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_da_cols number,
    p_da_table varchar2,
    p_pp_table varchar2,
    p_master_instance varchar2,
    p_rollback varchar2,
    p_skip_levels EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_skip_levels number,
    p_smart_update boolean,
    p_fk_use_nl number,
    p_fact_smart_update number,
    p_auto_dang_table_extn varchar2,
    p_log_dang_keys boolean,
    p_create_parent_table_records boolean,
    p_smart_update_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_smart_update_cols number,
    p_check_fk_change boolean,
    p_stg_join_nl_percentage number,
    p_ok_switch_update number,
    p_stg_make_copy_percentage number,
    p_read_cfig_options boolean,
    p_analyze_frequency number
    ) ;
function initial_set_up(
p_table_name varchar2,
p_max_threads number,
p_debug boolean,
p_ok_table out nocopy varchar2
) return boolean ;
procedure COLLECT(
p_object_name varchar2,
p_target_name varchar2,
p_table_name varchar2,
p_job_id number,
p_ok_low_end number,
p_ok_high_end number,
p_rownum_for_seq_num number
);
procedure COLLECT(
errbuf out nocopy varchar2,
retcode out nocopy varchar2,
p_object_name varchar2,
p_target_name varchar2,
p_table_name varchar2,
p_job_id number,
p_ok_low_end number,
p_ok_high_end number,
p_rownum_for_seq_num number
);
function COLLECT(p_status out NOCOPY boolean) return boolean;
function read_options_table(p_table_name varchar2) return boolean;--get all the global values
procedure Read_Metadata(p_mode varchar2) ;
procedure make_sql_surrogate_fk;
procedure make_insert_update_stmt;
procedure execute_all(p_count number) ;
FUNCTION get_status_message return varchar2;
procedure init_all(p_job_id number);
function get_rows_processed return number;
procedure select_fact_audit ;
procedure select_net_change;
procedure get_tracked_columns ;
procedure get_tracked_columns_nc ;
procedure write_to_log_file(p_message varchar2);
procedure write_to_log_file_n(p_message varchar2);
procedure write_to_out_file(p_message varchar2);
procedure write_to_out_file_n(p_message varchar2);
function is_parent_table(p_table varchar2) return boolean;
function calc_rows_processed_errors return boolean ;
function get_rows_processed_errored
        (p_object_name out NOCOPY varchar2,
         p_object_type out NOCOPY varchar2,
         p_ins_instance_name out NOCOPY EDW_OWB_COLLECTION_UTIL.varcharTableType,
         p_ins_request_id out NOCOPY EDW_OWB_COLLECTION_UTIL.numberTableType,
         p_ins_rows_ready out NOCOPY EDW_OWB_COLLECTION_UTIL.numberTableType,
         p_ins_rows_processed out NOCOPY EDW_OWB_COLLECTION_UTIL.numberTableType,
         p_ins_rows_collected out NOCOPY EDW_OWB_COLLECTION_UTIL.numberTableType,
         p_ins_rows_dangling out NOCOPY EDW_OWB_COLLECTION_UTIL.numberTableType,
         p_ins_rows_duplicate out NOCOPY EDW_OWB_COLLECTION_UTIL.numberTableType,
         p_ins_rows_error out NOCOPY EDW_OWB_COLLECTION_UTIL.numberTableType,
         p_number_ins_req_coll out NOCOPY number) return boolean ;
function get_time return varchar2 ;
procedure write_to_debug(p_message varchar2) ;
procedure write_to_debug_n(p_message varchar2);
function execute_collect_to_collected(p_count number) return boolean ;
function collect_records return boolean ;
function recover_from_previous_error return boolean;
procedure clean_up ;
function report_collection_status return boolean ;
procedure set_execute_flags;
function drop_index_surr_table return boolean ;
function create_index_surr_table return boolean ;
function execute_dup_stmt return boolean ;
function execute_surr_insert return boolean;
function execute_duplicate_check return boolean ;
function execute_insert_update_delete(p_count number) return boolean ;
function log_duplicate_records(p_coll_status varchar2, p_dup_number number) return boolean ;
procedure make_data_into_dlog_stmt ;
function excecute_data_into_dlog(p_mode varchar2) return boolean ;
procedure make_records_processing ;
function check_total_records_to_collect return boolean;
procedure make_hd_insert_stmt ;
function create_hd_table(p_count number) return boolean ;
function move_dangling_records_log return boolean ;
function create_error_rowid_table(p_type varchar2) return boolean ;
function move_dup_rowid_table return number ;
function create_opcode_table return boolean ;
function drop_opcode_table return boolean ;
function execute_duplicate_stmt return number ;
function execute_update_stmt return number ;
function execute_delete_stmt return number;
function create_dup_rownum_table(p_col varchar2) return boolean;
function create_ok_table(p_status number) return boolean;
function get_number_of_duplicates return number;
function update_ok_status_2 return boolean ;
function create_plan_table return boolean ;
function generate_explain_plan(p_stmt varchar2) return boolean ;
function check_explain_plan return boolean;
function generate_fts_lookups return boolean ;
function check_dup_err_rec return number ;
function regenerate_ok_table(p_ok_rowid_table varchar2,p_ok_copy_rowid_table varchar2) return boolean;
function create_surr_tables return boolean ;
function create_main_surr_table return boolean;
function create_main_surr_table_LHJM return boolean ;
function create_user_fk_table return boolean;
function check_fk_direct_load return boolean;
function check_fk_for_data(p_fk varchar2) return number;
function check_pk_direct_load return boolean ;
function make_pk_direct_load(p_type varchar2) return boolean;
function insert_fa_fact_insert return boolean ;
function insert_fa_fact_update return boolean;
function insert_nc_fact_insert return boolean ;
function insert_nc_fact_update return boolean;
function execute_fa_nc_insert(p_flag varchar2) return boolean;
function drop_fa_nc_rec_tables return boolean;
function create_dlog_rowid_table(p_mode varchar2) return boolean;
function reset_profiles return boolean;
procedure insert_into_load_progress(p_load_fk number,p_object_name varchar2,p_load_progress varchar2,
p_start_date date,p_end_date date,p_category varchar2, p_operation varchar2,p_seq_id varchar2,p_flag varchar2);
procedure insert_into_load_progress_d(p_load_fk number,p_object_name varchar2,p_load_progress varchar2,
p_start_date date,p_end_date date,p_category varchar2, p_operation varchar2,p_seq_id varchar2,p_flag varchar2);
function create_dlog_lookup_table return boolean ;
function insert_dlog_table(p_mode varchar2) return boolean;
procedure analyze_target_tables ;
function move_dup_rowid_table_general(p_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,p_number_cols number)
return number;
function create_da_pp_tables return boolean ;
function get_stg_da_columns return boolean ;
function populate_da_pp_tables return boolean ;
function create_opcode_table(p_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,p_number_cols number) return boolean;
function sync_da_pp_tables(p_table varchar2) return boolean ;
function move_dup_pp_future return boolean ;
function load_dup_coll_into_pp return boolean ;
function recreate_dlog_table return boolean ;
function check_cols_in_dlog return boolean ;
function create_dang_inst_tables(
p_fk_name varchar2,
p_parent_table_id number,
p_parent_table_name varchar2,
p_dang_table varchar2,
p_dang_instance out NOCOPY EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_dang_instance out NOCOPY number
) return boolean;
function insert_into_parent_fk_log(
p_dang_instance EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_dang_instance number,
p_fk_name varchar2,
p_parent_table_id number,
p_parent_table_name varchar2,
p_dim_auto_dang_table varchar2,
p_dim_lowest_ltc_id number) return boolean ;
function drop_fk_inst_tables(
p_dang_instance EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_dang_instance number,
p_parent_table_id number) return boolean ;
function create_auto_dang_tables(
p_surr_table varchar2,
p_fk_name varchar2,
p_user_fk_table_flag boolean,
p_user_fk_table varchar2,
p_dang_table out NOCOPY varchar2
) return boolean ;
function create_pk_dang_table(p_dang_table varchar2) return boolean ;
function log_dimension_dang_keys(
p_pk_name varchar2,
p_parent_table_id number,
p_parent_table_name varchar2,
p_dim_auto_dang_table varchar2,
p_dim_lowest_ltc_id number)
return boolean ;
function create_dang_dim_records(
p_dang_table varchar2,
p_dang_pk varchar2,
p_da_table varchar2,
p_pp_table varchar2,
p_ltc_table varchar2,
p_dim_table varchar2,
p_dim_id number,
p_surr_table out NOCOPY varchar2 --output table with the pk and pk_key that needs to be added to g_surr_table
)return boolean;
function create_dang_table_records(
p_dang_table varchar2,
p_dang_pk varchar2,
p_da_table varchar2,
p_pp_table varchar2,
p_ltc_table varchar2,
p_pk varchar2,--ltc pk
p_pk_key varchar2,--ltc pk_key
p_dim_table varchar2,
p_dim_id number,
p_dim_pk varchar2,
p_dim_pk_key varchar2,
p_seq varchar2,--ltc seq
p_surr_table out NOCOPY varchar2 --output table with the pk and pk_key that needs to be added to g_surr_table
)return boolean;
function refind_insert_rows return boolean ;
function execute_insert_stmt(p_count number) return boolean;
function set_g_type_ok_generation return boolean;
function check_stg_make_copy(p_load_size number, p_total_records number) return boolean ;
function make_stg_copy return boolean ;
function merge_all_ok_tables return boolean;
function put_rownum_in_ok_table return boolean ;
function make_ok_from_main_ok(
p_ok_table varchar2,
p_low_end number,
p_high_end number
) return boolean ;
function post_operations return boolean ;
function set_session_parameters return boolean ;
function dlog_setup return boolean ;
function drop_input_tables(p_table_name varchar2) return boolean ;
function set_stg_nl_parameters(p_load_size number) return boolean;
function execute_duplicate_stmt_single return number ;
function execute_duplicate_stmt_single(
p_duplicate_collect boolean,
p_update_type varchar2,
p_low_system_mem boolean,
p_fstgTableName varchar2,
p_dup_hold_table varchar2,
p_rollback varchar2
) return number;
function execute_duplicate_stmt_multi return number ;
procedure execute_duplicate_stmt_multi(
errbuf out nocopy varchar2,
retcode out nocopy varchar2,
p_object_name varchar2,
p_primary_target_name varchar2,
p_fstgTableName varchar2,
p_job_id number,
p_low_end number,
p_high_end number,
p_dup_hold_table varchar2,
p_debug varchar2,
p_bis_owner varchar2,
p_op_table_space varchar2,
p_parallel number,
p_duplicate_collect varchar2,
p_update_type varchar2,
p_low_system_mem varchar2,
p_rollback varchar2,
p_status_table varchar2);
procedure execute_duplicate_stmt_multi(
p_object_name varchar2,
p_primary_target_name varchar2,
p_fstgTableName varchar2,
p_job_id number,
p_low_end number,
p_high_end number,
p_dup_hold_table varchar2,
p_debug varchar2,
p_bis_owner varchar2,
p_op_table_space varchar2,
p_parallel number,
p_duplicate_collect varchar2,
p_update_type varchar2,
p_low_system_mem varchar2,
p_rollback varchar2,
p_status_table varchar2
);
function check_ok_table(
p_ok_rowid_table varchar2,
p_err_rec_flag in out nocopy boolean,
p_number_rows_ready in out nocopy  number
) return boolean;
function create_conc_program(
p_temp_conc_name varchar2,
p_temp_conc_short_name varchar2,
p_temp_exe_name varchar2,
p_bis_short_name varchar2
) return boolean;
function create_conc_program_dup(
p_temp_conc_name varchar2,
p_temp_conc_short_name varchar2,
p_temp_exe_name varchar2,
p_bis_short_name varchar2
) return boolean;
function create_user_measure_fk_table
return boolean;
function insert_fm_ff_table
return boolean;
function get_fstg_col_parameters return boolean;
function execute_ready_to_dangling(p_count number) return boolean;
function execute_dangling_collected(p_count number) return boolean;
function execute_dangling_collected(
p_count number,
p_table varchar2,
p_job_id out nocopy number
) return boolean;
procedure execute_dangling_collected(
---
p_primary_target number,
p_primary_target_name varchar2,
p_fstgTableName varchar2,
p_fstgPKName varchar2,
p_instance_column varchar2,
p_surr_table varchar2,
p_error_rowid_table varchar2,
p_ok_rowid_table varchar2,
---
p_bis_owner varchar2,
p_load_pk varchar2,
p_job_id number,
p_jobid_stmt varchar2,
p_count number,
p_number_rows_ready number,
p_surr_count number,
---
p_debug varchar2,
p_update_type varchar2,
p_low_system_mem varchar2,
p_op_table_space varchar2,
p_parallel number,
p_sort_area_size number,
p_hash_area_size number,
p_rollback varchar2,
p_version_GT_1159 varchar2,
p_table varchar2 --this is the status table
);
function update_stg_status_column(
p_src_table varchar2,
p_rowid_col varchar2,
p_where_stmt varchar2,
p_status varchar2, --COLLECTED OR READY
p_create_iot boolean
) return boolean;
procedure analyze_target_tables(
p_load_pk number,
p_table_owner varchar2,
p_primary_target_name varchar2,
p_primary_target number,
p_fact_audit varchar2,
p_fact_audit_name varchar2,
p_fact_net_change varchar2,
p_fact_net_change_name varchar2,
p_number_da_cols number,
p_da_table varchar2,
p_pp_table varchar2
);
function drill_parent_to_children
return boolean;
function check_dim_drill_down return boolean;
procedure drill_parent_to_children(
p_parent varchar2,
p_parent_id number,
p_dd_table varchar2,
p_ul_table varchar2,
p_ur_pattern varchar2,
p_parent_pk varchar2,
--
p_debug varchar2,
p_table_owner varchar2,
p_stg_join_nl_percentage number,
p_op_table_space varchar2,
p_parallel number,
p_bis_owner varchar2,
p_sort_area_size number,
p_hash_area_size number,
p_load_pk number,
p_conc_program_id number,
p_job number --1 means that this is a job
--
);
function drill_parent_to_child(
p_parent varchar2,
p_parent_id number,
p_child varchar2,
p_child_id number,
p_ul_table varchar2,
p_pci_table varchar2 --parent child impact table
)return boolean;
function merge_all_update_rowids(
p_ltc_id number,
p_ul_table varchar2,
p_ur_pattern varchar2,
p_pci_tables EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_num_pci_tables number
)return boolean;
function merge_pci_snplog(
p_ltc varchar2,
p_ltc_id number,
p_table_owner varchar2,
p_ltc_pk varchar2,
p_ul_table varchar2
)return boolean;
END EDW_MAPPING_COLLECT;

 

/
