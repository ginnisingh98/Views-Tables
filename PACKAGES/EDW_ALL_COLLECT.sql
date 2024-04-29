--------------------------------------------------------
--  DDL for Package EDW_ALL_COLLECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_ALL_COLLECT" AUTHID CURRENT_USER AS
/*$Header: EDWACOLS.pls 115.29 2004/04/06 16:29:15 vsurendr ship $*/

g_level_order EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_of_levels number:=0;
g_mapping_ids EDW_OWB_COLLECTION_UTIL.numberTableType;
g_primary_src EDW_OWB_COLLECTION_UTIL.numberTableType;
g_primary_target EDW_OWB_COLLECTION_UTIL.numberTableType;
g_target_input_table EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_level_snapshot_logs EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_fact_src number;
g_fact_target number;
g_fact_map_id number;
g_request_id number;
g_resp_id number;
g_max_threads number;--either dbms_job or fnd_conc child request
g_job_queue_processes number;
g_thread_type varchar2(60);--JOB or CONC
g_status boolean;
g_status_message varchar2(4000);
g_job_status_table varchar2(80);
g_conc_program_id number;--needed for logging
g_conc_program_name varchar2(200);
g_object_name varchar2(400);
g_object_input_table varchar2(400);
g_object_id number;
g_object_type varchar2(400);
g_collection_start_date date;
g_collection_end_date date;
g_number_rows_processed number;
g_collect_fact boolean;
g_collect_dim boolean;
g_duplicate_collect boolean;
g_dim_push_down boolean;
g_trace boolean;
g_explain_plan_check boolean;
g_collection_size number;
g_parallel  number;
g_forall_size number;
g_update_type varchar2(400);
g_hash_area_size number;
g_sort_area_size number;
g_stg_join_nl number; --when to use nl in stg table lookup
g_ok_switch_update number; --when to swith to update for ok table
g_auto_dang_recovery boolean; --main switch to turn off on or auto dang and dim rec creation
g_auto_dang_table_extn varchar2(40);
g_stg_make_copy_percentage number;--percentage value below which make a copy of stg to process
g_min_job_load_size number; --this is the minimum number of rows / job
g_sleep_time number;
/*******************************************************/
/**************Record the number of rows processed and errors*****/
g_ins_rows_ready EDW_OWB_COLLECTION_UTIL.numberTableType;
g_ins_rows_processed EDW_OWB_COLLECTION_UTIL.numberTableType;
g_ins_rows_collected EDW_OWB_COLLECTION_UTIL.numberTableType;
g_ins_rows_dangling EDW_OWB_COLLECTION_UTIL.numberTableType;
g_ins_rows_duplicate EDW_OWB_COLLECTION_UTIL.numberTableType;
g_ins_rows_error EDW_OWB_COLLECTION_UTIL.numberTableType;
g_ins_rows_insert EDW_OWB_COLLECTION_UTIL.numberTableType;
g_ins_rows_update EDW_OWB_COLLECTION_UTIL.numberTableType;
g_ins_rows_delete EDW_OWB_COLLECTION_UTIL.numberTableType;
g_ins_instance_name EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_ins_request_id_table EDW_OWB_COLLECTION_UTIL.numberTableType;
g_ins_collection_status EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_ins_req_coll number;
g_dim_rows_processed number;
g_diamond_issue boolean;
/*
assume that all the objects for a dim or fact are in the same schems for stats analysis
*/
g_table_owner varchar2(200);
g_bis_owner varchar2(200);
g_mode varchar2(400);
g_instance_type  varchar2(400);--single versus multiple

/***********************************************/
/*********for derived facts**********/
g_number_derived_facts number;
g_ilog  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_dlog  EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_df_load_pk EDW_OWB_COLLECTION_UTIL.numberTableType;
g_df_start_date EDW_OWB_COLLECTION_UTIL.dateTableType;
g_fact_dlog varchar2(400);
g_skip_levels EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_skip_levels number;
/*******************************************************/
g_key_set number;--how many keys considered in one shot
g_load_pk number;
g_logical_object_type varchar2(400);
g_skip_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_skip_cols number;
g_analyze_frequency number;
g_fresh_restart boolean;
g_op_table_space varchar2(400);
g_rollback  varchar2(400);
g_dim_inc_refresh_derv boolean;--if true, propogate dim changes to derv facts.
g_smart_update boolean;
g_smart_update_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_smart_update_cols number;
g_fk_use_nl number;
g_ltc_merge_use_nl boolean;
g_fact_smart_update number;
g_read_cfig_options boolean;
--------------------inc refresh derv facts from dimensions---
g_dim_derv_map_id EDW_OWB_COLLECTION_UTIL.numberTableType;
g_derv_fact_id EDW_OWB_COLLECTION_UTIL.numberTableType;
g_dim_derv_map_refresh EDW_OWB_COLLECTION_UTIL.booleanTableType;
g_dim_derv_map_full_refresh EDW_OWB_COLLECTION_UTIL.booleanTableType;
g_number_dim_derv_map_id number;
g_derv_fact_full_refresh EDW_OWB_COLLECTION_UTIL.numberTableType;--these derv need to be fully refreshed
g_num_derv_fact_full_refresh number;
g_before_update_table EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_before_update_table number;
g_max_fk_density number;
g_tables_to_drop EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_tables_to_drop number;
g_before_update_table_prot  varchar2(400);
g_create_parent_table_records boolean;
g_check_fk_change boolean;
g_check_fk_change_number number;
-------------------------------------------------------------
---------data alignment----------
g_da_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
g_number_da_cols number;
g_da_table varchar2(400);
g_pp_table varchar2(400);
g_master_instance varchar2(400);
g_parallel_drill_down boolean;
g_dd_status_table varchar2(40);
---------------------------------

procedure Collect_Dimension(Errbuf out NOCOPY varchar2,
			    Retcode out NOCOPY varchar2,
		            p_dim_name in varchar2);
procedure Collect_Fact(Errbuf out NOCOPY varchar2,
		       Retcode out NOCOPY varchar2,
                       p_fact_name in varchar2);
procedure Collect_Object(Errbuf out NOCOPY varchar2,
		       Retcode out NOCOPY varchar2,
               p_object_name in varchar2);
PROCEDURE Set_Rank ;
PROCEDURE Set_l_child_start ;
PROCEDURE Set_Rank_Recursive(p_level_in varchar2, p_rank number) ;
FUNCTION Get_index(p_level_in varchar2) RETURN NUMBER;
PROCEDURE Set_Level_Rank(p_index_in integer, p_rank number);
FUNCTION Get_Rank(p_level_in varchar2) RETURN NUMBER;
PROCEDURE Collect_Each_Level;
PROCEDURE Order_by_Rank;
function get_status_message return varchar2;
procedure init_all;
procedure return_with_error(p_load_pk number,p_log varchar2);
procedure return_with_success(p_command varchar2,p_start_date date, p_load_pk number);
procedure get_rows_processed ;
procedure write_to_log_file(p_message varchar2);
procedure write_to_log_file_n(p_message varchar2) ;
function get_time return varchar2;
function is_derived_fact(p_fact varchar2) return boolean ;
--procedure write_to_coll_detail_log(p_flag boolean, p_message varchar2) ;
procedure write_to_collection_log(p_flag boolean, p_message EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_collection_start_date date, p_load_pk number);
function is_source_for_derived_fact return boolean ;
function check_if_fact_exists(p_fact_name varchar2) return boolean ;
function make_collection_log_message(l_status_message out NOCOPY EDW_OWB_COLLECTION_UTIL.varcharTableType)
return varchar2 ;
procedure write_to_error_log(p_message varchar2) ;
function get_temp_log_data(g_object_name varchar2, g_object_type varchar2) return boolean ;
function refresh_all_derived_facts return boolean;
function get_snapshot_log return boolean ;
function get_fact_dlog return boolean ;
procedure clean_up;
procedure insert_into_load_progress(p_load_fk number,p_object_name varchar2,p_object_id number,p_load_progress varchar2,
p_start_date date,p_end_date date,p_category varchar2, p_operation varchar2,p_seq_id varchar2,p_flag varchar2) ;
procedure insert_into_load_progress_nd(p_load_fk number,p_object_name varchar2,p_object_id number,p_load_progress varchar2,
p_start_date date,p_end_date date,p_category varchar2, p_operation varchar2,p_seq_id varchar2,p_flag varchar2) ;
procedure reset_profiles;
function refresh_dim_derv_facts(p_dim_name varchar2,p_load_fk out NOCOPY number) return boolean;
function create_bu_src_fact(p_src_fact varchar2,p_src_fact_id number,
p_dim_name varchar2,p_dim_id number, p_map_id number,p_derv_bu_map_src_table varchar2,
p_derv_before_update_table varchar2,p_bu_src_table out NOCOPY varchar2)
return boolean ;
function get_map_properties(p_map_id number,p_src_fact_name out NOCOPY varchar2,p_src_fact_id out NOCOPY number)
return boolean;
function find_data_alignment_cols(p_object_name varchar2) return boolean ;
function read_config_options return boolean ;
function read_profile_options return boolean ;
procedure set_g_fact_smart_update ;
function set_thread_type(
p_max_threads number,
p_job_queue_processes number
) return varchar2;
procedure find_parallel_drill_down(
p_levels EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_num_levels number);
END EDW_ALL_COLLECT;

 

/
