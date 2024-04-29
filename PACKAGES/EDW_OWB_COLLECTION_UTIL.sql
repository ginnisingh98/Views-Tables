--------------------------------------------------------
--  DDL for Package EDW_OWB_COLLECTION_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EDW_OWB_COLLECTION_UTIL" AUTHID CURRENT_USER AS
/*$Header: EDWCOLUS.pls 120.0 2005/06/01 18:03:59 appldev noship $*/

Type varcharTableType is Table of varchar2(400) index by binary_integer;
Type L_varcharTableType is Table of varchar2(4000) index by binary_integer;
Type LL_varcharTableType is Table of varchar2(10000) index by binary_integer;
Type LLL_varcharTableType is Table of varchar2(20000) index by binary_integer;
Type numberTableType is Table of number index by binary_integer;
Type dateTableType is Table of date index by binary_integer;
Type booleanTableType is Table of boolean index by binary_integer;
Type rowidTableType is Table of rowid index by binary_integer;

g_conc_log_index number;
g_conc_id_log numberTableType;
g_conc_program_name_log varcharTableType;
g_object_type_log varcharTableType;
g_log_date_log dateTableType;
g_status_log varcharTableType;
g_message_log L_varcharTableType;
g_file utl_file.file_type;
g_file_flag boolean;
g_debug boolean;
g_parallel number;
g_conc_program_id number;
g_status_message varchar2(8000);
g_status boolean;
g_read_cfig_options boolean;
g_sqlcode number;
g_fnd_log_module varchar2(200);
------------------------------
g_oracle_apps_version varchar2(200);
g_version_GT_1159 boolean;--is version greater than 11.5.9
g_db_version varchar2(40);
------------------------------
/*
  variables for use
*/
g_lowest_level varchar2(400);
g_lowest_level_id number;
g_metedata_version varchar2(80);
g_stmt varchar2(30000);
g_session_id number;

PROCEDURE set_up(p_dimension_name in varchar2) ;

procedure Get_Level_Relations(
	p_levels out NOCOPY varcharTableType,
	p_level_status out NOCOPY varcharTableType,
	p_child_level_number out NOCOPY numberTableType,
	p_child_levels out NOCOPY varcharTableType,
	p_child_fk out NOCOPY varcharTableType,
    p_parent_pk out NOCOPY varcharTableType,
    p_number_levels out NOCOPY integer) ;

procedure get_lowest_level(
 p_level out NOCOPY varchar2,
 p_level_id out NOCOPY number);

PROCEDURE Get_lvl_dim_mapping(
    p_dim_col out NOCOPY varcharTableType,
    p_level_name out NOCOPY varcharTableType,
    p_level_col out NOCOPY varcharTableType,
    p_number_mapping out NOCOPY integer,
    p_flag in integer) ;

PROCEDURE Get_mapping_ids(p_level_map_id out NOCOPY numberTableType,
			p_level_primary_src out NOCOPY numberTableType,
			p_level_primary_target out NOCOPY numberTableType);

PROCEDURE Get_Fact_Ids(
	p_fact_name in varchar2,
	p_fact_map_id out NOCOPY number,
	p_fact_src out NOCOPY number,
	p_fact_target out NOCOPY number) ;
function get_log_for_table(p_table varchar2, p_log varchar2) return varchar2;
function get_columns_for_table(
    p_table varchar2,
    p_columns out NOCOPY varcharTableType,
    p_number_columns out NOCOPY number) return boolean ;
function get_db_columns_for_table(
    p_table varchar2,
    p_columns out NOCOPY varcharTableType,
    p_number_columns out NOCOPY number,
    p_owner varchar2) return boolean;
function get_db_columns_for_table(
    p_table varchar2,
    p_columns out NOCOPY varcharTableType,
    p_data_type out NOCOPY varcharTableType,
    p_number_columns out NOCOPY number,
    p_owner varchar2) return boolean ;
function get_db_columns_for_table(
    p_table varchar2,
    p_columns out NOCOPY varcharTableType,
    p_data_type out NOCOPY varcharTableType,
    p_data_length out NOCOPY varcharTableType,
    p_num_distinct out NOCOPY numberTableType,
    p_num_nulls out NOCOPY numberTableType,
    p_avg_col_length out NOCOPY numberTableType,
    p_number_columns out NOCOPY number,
    p_owner varchar2) return boolean;
function get_table_snapshot_log(p_table varchar2) return varchar2;
function delete_table(p_table varchar2) return boolean ;
function truncate_table(p_table varchar2) return boolean ;
function truncate_table(p_table varchar2,p_owner varchar2) return boolean ;
function get_fks_for_table(
    p_table varchar2,
    p_fks out NOCOPY varcharTableType,
    p_number_fks out NOCOPY number) return boolean ;
function get_fks_for_table(
    p_table varchar2,
    p_parent_table out NOCOPY varcharTableType,
    p_fks out NOCOPY varcharTableType,
    p_number_fks out NOCOPY number) return boolean;
function value_in_table(
    p_table varcharTableType,
    l_number_table number,
    p_value varchar2) return boolean;
function value_in_table(
    p_table numberTableType,
    l_number_table number,
    p_value number) return boolean ;
function value_in_table(
    p_table1 varcharTableType,
    p_table2 varcharTableType,
    l_number_table number,
    p_value1 varchar2,
    p_value2 varchar2) return boolean ;
procedure setup_conc_program_log ;
procedure setup_conc_program_log(p_object_name varchar2) ;
procedure set_conc_program_id(p_conc_program_id number) ;
procedure commit_conc_program_log ;
PROCEDURE Write_to_conc_prog_log(
		p_conc_id number,
		p_conc_name varchar2,
		p_object_type varchar2,
		p_conc_status varchar2,
		p_conc_message varchar2);
procedure write_to_log_file(p_message varchar2);
procedure write_to_log_file(p_message varchar2,p_severity number);
procedure write_to_log_file_n(p_message varchar2) ;
procedure write_to_log_file_n(p_message varchar2,p_severity number);
procedure write_to_out_file(p_message varchar2);
procedure print_stmt(l_stmt in varchar2);

FUNCTION get_wh_language return VARCHAR2 ;
FUNCTION get_wh_lookup_value(p_lookup_type IN VARCHAR2,
                                p_lookup_code in varchar2) return VARCHAR2 ;

/************************************************************
     for VBH
************************************************************/
function get_vbh_mapping(
		p_src_name varchar2,
        p_tgt_name varchar2,
		p_map varchar2,
		p_src_table out NOCOPY varcharTableType,
		p_src_col out NOCOPY varcharTableType,
		p_tgt_table out NOCOPY varcharTableType,
		p_tgt_col out NOCOPY varcharTableType,
		p_number_maps out NOCOPY number,
        p_debug boolean) return boolean;

/**************************************************************/

procedure set_debug(p_debug boolean);
function get_time return varchar2;
function is_slowly_changing_dimension(p_dim_name varchar2) return varchar2;
function write_to_collection_log(
        p_object varchar2,
        p_object_id number,
        p_object_type varchar2,
        p_conc_program_id number,
        p_start_date date,
        p_end_date date,
        p_rows_ready number,
        p_rows_processed number,
        p_rows_collected number,/*not same as p_rows_processed when duplicate collect is yes*/
        p_number_insert number,
        p_number_update number,
        p_number_delete number,
        p_collection_message varchar2,
        p_status varchar2,
        p_load_pk number) return boolean;

function write_to_general_log
        (OBJECT_NAME     VARCHAR2,
         OBJECT_TYPE    VARCHAR2,
         LOG_TYPE  VARCHAR2,
         CONCURRENT_ID   NUMBER,
         START_DATE DATE,
         END_DATE DATE,
         MESSAGE   VARCHAR2,
         STATUS   VARCHAR2) return boolean;
function write_to_error_log
        (OBJECT_NAME     VARCHAR2,
         OBJECT_TYPE    VARCHAR2,
         ERROR_TYPE  VARCHAR2,
         CONCURRENT_ID   NUMBER,
         START_DATE DATE,
         END_DATE DATE,
         MESSAGE   VARCHAR2,
         STATUS   VARCHAR2,
         RESP_ID NUMBER) return boolean;

function insert_temp_log_table(
        p_object_name varchar2,
        p_object_type varchar2,
        p_concurrent_req_id number,
        p_ins_instance_name varcharTableType,
        p_ins_request_id_table numberTableType,
        p_ins_rows_ready numberTableType,
        p_ins_rows_processed numberTableType,
        p_ins_rows_collected numberTableType,
        p_ins_rows_dangling numberTableType,
        p_ins_rows_duplicate numberTableType,
        p_ins_rows_error numberTableType,
        p_number_ready number,
        p_number_insert number,
        p_number_update number,
        p_number_delete number,
        p_number_ins_req_coll number) return boolean;
function check_table(p_table varchar2) return boolean ;
function check_table(p_table varchar2, p_owner varchar2) return boolean ;
function check_iv_trigger(p_iv varchar2) return boolean;
function get_all_derived_facts(
    p_object varchar2,
    p_derived_facts out NOCOPY varcharTableType,
    p_derived_fact_ids out NOCOPY numberTableType,
    p_map_id  out NOCOPY numberTableType,
    p_number_derived_facts out NOCOPY number) return boolean ;
function create_table(
    p_table_name varchar2,
    p_table_owner varchar2,
    p_table_cols varcharTableType,
    p_table_data_type varcharTableType,
    p_number_table_cols number,
    p_table_storage varchar2) return boolean ;
function drop_table(p_table_name varchar2) return boolean;
function drop_table(
    p_table_name varchar2,
    p_owner varchar2) return boolean ;
function get_db_user(p_product varchar2) return varchar2;
procedure analyze_table_stats(
p_table varchar2);
procedure analyze_table_stats(
p_table varchar2,
p_owner varchar2);
procedure analyze_table_stats(
p_table varchar2,
p_owner varchar2,
p_percentage number);
function get_table_owner(p_table varchar2) return varchar2 ;
function record_coll_progress(
    p_object_name varchar2,
    p_object_type varchar2,
    p_number_rows_processed number,
    p_status varchar2,
    p_action varchar2) return boolean;
function is_another_coll_running(p_object_name varchar2, p_object_type varchar2) return number ;
procedure alter_session(p_param varchar2) ;
procedure alter_session(p_param varchar2,p_value varchar2);
function does_table_have_data(p_table varchar2) return number ;
function does_table_have_data(p_table varchar2, p_where varchar2) return number ;
function does_table_have_only_n_row(p_table varchar2,p_row_count number) return number ;
function does_table_have_only_n_row(p_table varchar2, p_where varchar2,p_row_count number) return number ;
function is_object_a_source(p_object_name varchar2)  return boolean ;
function create_dim_key_lookup(p_dim_name varchar2, p_dim_user_pk varchar2, p_dim_pk varchar2,
          p_lookup_table varchar2, p_parallel number,p_mode varchar2,
          p_op_table_space varchar2) return boolean;
function get_dims_slow_change(p_dim_names varcharTableType,p_number_dims number,
          p_dim_list out NOCOPY varcharTableType ,p_number_dim_list out NOCOPY number)
          return boolean;
function get_dims_slow_change(p_dim_names varcharTableType,p_number_dims number,
          p_dim_list out NOCOPY varcharTableType ,p_number_dim_list out NOCOPY number,
          p_is_name varchar2)
          return boolean;
function is_slow_change_implemented(p_dim_name varchar2) return boolean ;
function is_slow_change_implemented(p_dim_name varchar2,p_is_name varchar2) return boolean ;
function execute_stmt(p_stmt varchar2) return boolean ;
function get_table_surr_pk(p_table varchar2, p_pk out NOCOPY varchar2) return boolean;
function get_user_key(p_key varchar2) return varchar2 ;
function is_push_down_implemented(p_dim varchar2) return boolean ;
function is_inc_refresh_implemented(p_fact varchar2) return boolean;
procedure set_parallel(p_parallel number) ;
function is_delete_trigger_imp(p_object varchar2, p_owner varchar2) return boolean ;
function insert_into_coll_progress(
  OBJECT_NAME                              VARCHAR2
, OBJECT_TYPE                              VARCHAR2
, STATUS                                   VARCHAR2
, NUMBER_PROCESSED                         NUMBER) return boolean;
function get_sec_source_info(
    p_map_id number,
    p_sec_source out NOCOPY varcharTableType,
    p_sec_source_id out NOCOPY numberTableType,
    p_sec_source_child out NOCOPY varcharTableType,
    p_sec_source_child_id out NOCOPY numberTableType,
    p_pk  out NOCOPY varcharTableType,
    p_fk  out NOCOPY varcharTableType,
    p_sec_source_usage out NOCOPY numberTableType,
    p_sec_source_usage_name out NOCOPY varcharTableType,
    p_sec_source_child_usage out NOCOPY numberTableType,
    p_sec_source_number out NOCOPY number) return boolean;
function bubble_sort(p_input numberTableType,p_input_number number, p_output out NOCOPY numberTableType)
 return boolean ;
function make_transforms_rec(
  p_hold_func varcharTableType,
  p_hold_func_category varcharTableType,
  p_hold_item varcharTableType,
  p_hold_item_id numberTableType,
  p_hold_item_is_fk booleanTableType,
  p_hold_relation numberTableType,
  p_hold_relation_usage numberTableType,
  p_hold_item_usage numberTableType,
  p_hold_aggregatefunction varcharTableType,
  p_hold_is_distinct numberTableType,
  p_hold_relation_name varcharTableType,
  p_hold_func_usage numberTableType,
  p_hold_func_position numberTableType,
  p_hold_func_dvalue varcharTableType,
  p_sec_sources  varcharTableType,
  p_number_sec_sources number,
  p_target_id number,
  p_src_object varchar2,
  p_hold_number number,
  p_index  number,
  p_agg_flag out NOCOPY varchar2
) return varchar2;
function is_source_for_inc_derived_fact(p_fact varchar2) return number ;
function index_in_table(
    p_table varcharTableType,
    l_number_table number,
    p_value varchar2) return number;
function index_in_table(
    p_table1 varcharTableType,
    p_table2 varcharTableType,
    l_number_table number,
    p_value1 varchar2,
    p_value2 varchar2) return number ;
procedure insert_into_load_progress(p_load_fk number,p_object_name varchar2,p_object_id number,
p_load_progress varchar2,p_start_date date,p_end_date date,p_category varchar2, p_operation varchar2,
p_seq_id varchar2,p_flag varchar2,p_obj_id number) ;
function get_item_set_cols(p_cols out NOCOPY varcharTableType, p_number_cols out NOCOPY number,
p_object varchar2,p_item_set varchar2) return boolean ;
function get_level_prefix(p_level varchar2) return varchar2 ;
function get_obj_obj_map_details(p_src_object varchar2,p_tgt_object varchar2,p_map_name varchar2,
p_src_cols out NOCOPY varcharTableType, p_tgt_cols out NOCOPY varcharTableType, p_number_cols out NOCOPY number) return boolean ;
function get_table_index_col(p_table varchar2,p_owner varchar2,
p_index out NOCOPY varcharTableType,p_ind_col out NOCOPY varcharTableType,p_ind_col_pos out NOCOPY numberTableType,
p_number_index out NOCOPY number) return boolean ;
function get_object_id(p_object varchar2) return number;
function last_analyzed_date(p_table varchar2) return date;
function last_analyzed_date(p_table varchar2,p_owner varchar2) return date;
function get_table_count(p_table varchar2) return number ;
function get_table_count(p_table varchar2,p_where varchar2) return number ;
function get_table_next_extent(p_table varchar2,p_owner varchar2,p_next_extent out NOCOPY number) return boolean ;
function get_user_pk(p_table varchar2) return varchar2 ;
function is_column_in_table(p_table varchar2,p_column varchar2) return boolean;
function is_column_in_table(p_table varchar2,p_column varchar2,p_owner varchar2) return boolean;
function get_table_space(p_owner varchar2) return varchar2;
function index_present(p_table varchar2,p_owner varchar2,p_key varchar2,
p_type varchar2) return boolean ;
function get_mapping_details(
 p_mapping_id number
,p_hold_func out NOCOPY varcharTableType
,p_hold_func_category out NOCOPY varcharTableType
,p_hold_item out NOCOPY varcharTableType
,p_hold_item_id out NOCOPY numberTableType
,p_hold_item_usage out NOCOPY numberTableType
,p_hold_aggregatefunction out NOCOPY varcharTableType
,p_hold_is_distinct out NOCOPY numberTableType
,p_hold_relation out NOCOPY numberTableType
,p_hold_relation_name out NOCOPY varcharTableType
,p_hold_relation_usage out NOCOPY numberTableType
,p_hold_relation_type out NOCOPY varcharTableType
,p_hold_func_usage out NOCOPY numberTableType
,p_hold_func_position out NOCOPY numberTableType
,p_hold_func_dvalue out NOCOPY varcharTableType
,p_hold_number out NOCOPY number
,p_metedata_version varchar2
) return boolean ;
function get_mapid_dim_in_derv_map(
p_dim varchar2,
p_mapid out NOCOPY numberTableType,
p_derv_fact_id out NOCOPY numberTableType,
p_src_fact_id out NOCOPY numberTableType,
p_number_mapid out NOCOPY number,
p_type varchar2) return boolean;
function get_dim_fk_summary_fact(
p_fact_id number,
p_dim_id number,
p_dim_fk out NOCOPY varcharTableType,
p_number_dim_fk out NOCOPY number
) return boolean ;
function get_object_name(p_object_id number) return varchar2 ;
function inc_g_load_pk return number ;
function get_column_stats(
p_owner varchar2,
p_object varchar2,
p_fk varchar2,
p_distcnt out NOCOPY number,
p_density out NOCOPY number,
p_nullcnt out NOCOPY number,
p_srec out NOCOPY DBMS_STATS.StatRec,
p_avgclen out NOCOPY number
) return boolean;
function get_table_stats(
p_owner varchar2,
p_object varchar2,
p_numrows out NOCOPY number,
p_numblks out NOCOPY number,
p_avgrlen out NOCOPY number
) return boolean;
function get_fk_pk(p_child number,p_parent number,p_map_id number,
p_fk out NOCOPY varcharTableType,p_pk out NOCOPY varcharTableType,
p_number_fk out NOCOPY number) return boolean;
function create_prot_table(p_table varchar2,p_op_table_space varchar2) return boolean ;
function drop_prot_table(p_table varchar2) return boolean;
function get_all_maps_for_tgt(p_object_id number,p_maps out NOCOPY numberTableType,p_number_maps out NOCOPY number)
return boolean ;
function get_table_avg_row_len(p_table varchar2,p_owner varchar2,p_avg_row_len out NOCOPY number)
return boolean;
function get_table_storage(p_table varchar2,p_owner varchar2,p_table_space out NOCOPY varchar2,
p_initial_extent out NOCOPY number,p_next_extent out NOCOPY number,p_pct_free out NOCOPY number,p_pct_used out NOCOPY number,
p_pct_increase out NOCOPY number, p_max_extents out NOCOPY number,p_avg_row_len out NOCOPY number) return boolean;
function create_table(p_table varchar2,p_stmt varchar2,p_count out NOCOPY number) return boolean ;
function is_itemset_implemented(p_object_name varchar2,
p_item_set varchar2)
return varchar2;
function is_itemset_implemented(p_object_name varchar2,
p_item_set varchar2,
p_object_id number)
return varchar2;
function get_DA_table(p_object varchar2) return varchar2;
function get_DA_table(p_object varchar2,p_owner varchar2) return varchar2;
function get_PP_table(p_object varchar2) return varchar2;
function get_PP_table(p_object varchar2,p_owner varchar2) return varchar2;
function get_master_instance(p_object_name varchar2) return varchar2 ;
function log_into_cdi_results_table(
p_object varchar2
,p_object_type  varchar2
,p_object_id number
,p_interface_table varchar2
,p_interface_table_id number
,p_interface_table_pk varchar2
,p_interface_table_pk_id number
,p_interface_table_fk varchar2
,p_interface_table_fk_id number
,p_parent_table varchar2
,p_parent_table_id number
,p_parent_table_pk varchar2
,p_parent_table_pk_id number
,p_number_dangling number
,p_number_duplicate number
,p_number_error number
,p_total_records number
,p_error_type varchar2) return boolean ;
function log_into_cdi_dang_table(p_key_id number,p_table_id number,p_parent_table_id number,
p_key_value varchar2,p_number_key_value number,p_instance varchar2,p_bad_key varchar2) return boolean;
function get_column_id(p_column varchar2,p_table varchar2) return number ;
function get_instance_col(p_table varchar2) return varchar2;
function create_synonym(p_synonym varchar2,p_table varchar2) return boolean ;
procedure create_bad_key_table(p_table varchar2,p_op_table_space varchar2,p_wh_parallel number);
function is_src_of_custom_inc_derv_fact(p_fact varchar2) return number;
function get_pk_view(p_dim varchar2,p_db_link varchar2) return varchar2 ;
function get_logical_name(p_obj_id number) return varchar2 ;
function parse_names(p_list varchar2,p_names out NOCOPY varcharTableType,p_number_names out NOCOPY number)
return boolean ;
function parse_names(
p_list varchar2,
p_separator varchar2,
p_names out NOCOPY varcharTableType,
p_number_names out NOCOPY number)
return boolean;
function get_status_message return varchar2;
procedure set_rollback(p_rollback varchar2) ;
function get_ltc_fact_unique_key(p_object_id number,p_object_name varchar2,
p_unique_key out NOCOPY varchar2,p_pk_key out NOCOPY varchar2) return boolean ;
function get_col_col_in_map(
p_map_id number,
p_object varchar2,
p_src_tables out NOCOPY varcharTableType,
p_src_cols out NOCOPY varcharTableType,
p_tgt_tables out NOCOPY varcharTableType,
p_tgt_cols out NOCOPY varcharTableType,
p_number_cols out NOCOPY number) return boolean ;
function get_fks_in_map(p_tgt varchar2,p_src out NOCOPY varcharTableType,
p_fk out NOCOPY varcharTableType,p_number_src out NOCOPY number) return boolean ;
function get_fks_in_dim(p_tgt varchar2,p_src out NOCOPY varcharTableType,
p_fk out NOCOPY varcharTableType,p_number_src out NOCOPY number) return boolean ;
function get_app_version(p_instance varchar2) return varchar2 ;
function get_app_version(p_instance varchar2,p_db_link varchar2) return varchar2 ;
function check_table_column(p_table varchar2,p_col varchar2) return boolean ;
function add_column_to_table(p_table varchar2,p_owner varchar2,p_col varchar2,
p_datatype varchar2) return boolean ;
function get_dim_id(p_object varchar2) return number ;
procedure set_g_read_cfig_options(p_read_cfig_options boolean) ;
function check_pk_pkkey_index(p_table varchar2,p_owner varchar2,p_pk varchar2,p_pk_key varchar2) return boolean ;
function check_load_status(p_object varchar2) return boolean ;
function get_message(p_message  varchar2) return varchar2 ;
function get_message(p_message  varchar2,p_product varchar2) return varchar2 ;
function get_object_type(p_object_name varchar2) return varchar2 ;
function get_ltc_lstg(p_object_name varchar2,p_lstg out NOCOPY varcharTableType,
p_ltc out NOCOPY varcharTableType,p_number_ltc out NOCOPY number) return boolean ;
function is_auto_dang_implemented(p_dim_name varchar2) return boolean;
function create_auto_dang_table(p_dim_auto_dang_table varchar2,
p_pk_cols varcharTableType,p_number_pk_cols number) return boolean;
function get_lowest_level_table(p_dim varchar2,p_lowest_level_table out NOCOPY varchar2,
p_lowest_level_table_id out NOCOPY number) return boolean;
function get_all_lowest_level_tables(
p_dim_in varchar2,
p_dim out NOCOPY varcharTableType,
p_level_table out NOCOPY varcharTableType,
p_level_table_id out NOCOPY numberTableType,
p_number_dim out NOCOPY number) return boolean ;
function get_lowest_level_table(p_dim varchar2) return varchar2 ;
function get_lowest_level_table(p_dim varchar2,p_dim_id number) return varchar2 ;
function get_db_link_for_instance(p_instance varchar2) return varchar2 ;
function test_db_link(p_db_link varchar2) return boolean;
function get_dim_pk_structure(p_parent_table_name varchar2,p_instance varchar2,
p_dim_pk_structure out NOCOPY varcharTableType,p_number_dim_pk_structure out NOCOPY number) return boolean;
function parse_pk_structure(p_dim_pk_structure varchar2,p_pk_cols out NOCOPY varcharTableType,
p_number_pk_cols out NOCOPY number) return boolean ;
function get_dim_pk(p_dim_name varchar2) return varchar2 ;
function get_dim_pk(p_dim_name varchar2,p_dim_id number) return varchar2 ;
procedure truncate_table(p_table varchar2) ;
function get_dim_lvl_pk_keys(p_dim_name varchar2,p_dim_id number,
p_pk_key out NOCOPY varcharTableType,
p_number_pk_key out NOCOPY number) return boolean ;
function get_dim_lvl_name_cols(p_dim_name varchar2,p_dim_id number,
p_name out NOCOPY varcharTableType,
p_number_name out NOCOPY number) return boolean ;
function get_table_seq(p_table varchar2,p_table_id number) return varchar2 ;
function get_lookup_code(p_lookup_type varchar2,p_lookup_code out NOCOPY varcharTableType,
p_number_lookup_code out NOCOPY number) return boolean ;
function get_object_unique_key(p_object varchar2,p_object_id number,
p_pk out NOCOPY varcharTableType,p_number_pk out NOCOPY number) return boolean ;
function get_table_count_stats(p_table varchar2,p_owner varchar2) return number ;
function get_src_tgt_map_details(
p_mapping_id number,
p_primary_target number,
p_primary_src number,
p_factPKNameKey varchar2,
p_dimTableName varcharTableType,
p_numberOfDimTables number,
p_fact_mapping_columns out NOCOPY varcharTableType,
p_fstg_mapping_columns out NOCOPY varcharTableType,
p_num_ff_map_cols out NOCOPY number,
p_groupby_cols out NOCOPY varcharTableType,
p_number_groupby_cols out NOCOPY number,
p_instance_column out NOCOPY varchar2,
p_groupby_on out NOCOPY boolean,
p_pk_key_seq_pos out NOCOPY number,
p_pk_key_seq out NOCOPY varchar2) return boolean ;
function get_src_tgt_map_details_owb(
p_mapping_id number,
p_primary_target number,
p_primary_src number,
p_factPKNameKey varchar2,
p_dimTableName varcharTableType,
p_numberOfDimTables number,
p_fact_mapping_columns out NOCOPY varcharTableType,
p_fstg_mapping_columns out NOCOPY varcharTableType,
p_num_ff_map_cols out NOCOPY number,
p_groupby_cols out NOCOPY varcharTableType,
p_number_groupby_cols out NOCOPY number,
p_instance_column out NOCOPY varchar2,
p_groupby_on out NOCOPY boolean,
p_pk_key_seq_pos out NOCOPY number,
p_pk_key_seq out NOCOPY varchar2,
p_metedata_version varchar2) return boolean ;
function get_src_tgt_map_details_edw(
p_mapping_id number,
p_primary_target number,
p_primary_src number,
p_factPKNameKey varchar2,
p_dimTableName varcharTableType,
p_numberOfDimTables number,
p_fact_mapping_columns out NOCOPY varcharTableType,
p_fstg_mapping_columns out NOCOPY varcharTableType,
p_num_ff_map_cols out NOCOPY number,
p_groupby_cols out NOCOPY varcharTableType,
p_number_groupby_cols out NOCOPY number,
p_instance_column out NOCOPY varchar2,
p_groupby_on out NOCOPY boolean,
p_pk_key_seq_pos out NOCOPY number,
p_pk_key_seq out NOCOPY varchar2) return boolean;
function find_metadata_version return varchar2;
function get_derv_mapping_details(
p_mapping_id number,
p_src_object_id number,
p_number_skip_cols number,
p_skip_cols varcharTableType,
p_fact_fks varcharTableType,
p_number_fact_fks number,
p_src_fks varcharTableType,
p_number_src_fks number,
p_fact_id number,
p_src_object varchar2,
p_temp_fact_name_temp in out NOCOPY varchar2,
p_number_sec_sources out NOCOPY number,
p_sec_sources out NOCOPY varcharTableType,
p_sec_sources_alias out NOCOPY varcharTableType,
p_number_sec_key out NOCOPY number,
p_sec_sources_pk out NOCOPY varcharTableType,
p_sec_sources_fk out NOCOPY varcharTableType,
p_groupby_stmt out NOCOPY varchar2,
p_hold_number out NOCOPY number,
p_number_group_by_cols out NOCOPY number,
p_hold_relation out NOCOPY varcharTableType,
p_hold_item out NOCOPY varcharTableType,
p_group_by_cols out NOCOPY varcharTableType,
p_output_group_by_cols out NOCOPY varcharTableType,
p_number_input_params out NOCOPY number,
p_output_params out NOCOPY varcharTableType,
p_input_params out NOCOPY varcharTableType,
p_filter_stmt out NOCOPY varchar2
) return boolean;
function get_derv_mapping_details_owb(
p_mapping_id number,
p_src_object_id number,
p_number_skip_cols number,
p_skip_cols varcharTableType,
p_fact_fks varcharTableType,
p_number_fact_fks number,
p_src_fks varcharTableType,
p_number_src_fks number,
p_fact_id number,
p_src_object varchar2,
p_temp_fact_name_temp in out NOCOPY varchar2,
p_number_sec_sources out NOCOPY number,
p_sec_sources out NOCOPY varcharTableType,
p_sec_sources_alias out NOCOPY varcharTableType,
p_number_sec_key out NOCOPY number,
p_sec_sources_pk out NOCOPY varcharTableType,
p_sec_sources_fk out NOCOPY varcharTableType,
p_groupby_stmt out NOCOPY varchar2,
p_hold_number out NOCOPY number,
p_number_group_by_cols out NOCOPY number,
p_hold_relation out NOCOPY varcharTableType,
p_hold_item out NOCOPY varcharTableType,
p_group_by_cols out NOCOPY varcharTableType,
p_output_group_by_cols out NOCOPY varcharTableType,
p_number_input_params out NOCOPY number,
p_output_params out NOCOPY varcharTableType,
p_input_params out NOCOPY varcharTableType,
p_filter_stmt out NOCOPY varchar2,
p_metedata_version varchar2
) return boolean ;
function get_derv_mapping_details_edw(
p_mapping_id number,
p_src_object_id number,
p_number_skip_cols number,
p_skip_cols varcharTableType,
p_fact_fks varcharTableType,
p_number_fact_fks number,
p_src_fks varcharTableType,
p_number_src_fks number,
p_fact_id number,
p_src_object varchar2,
p_temp_fact_name_temp in out NOCOPY varchar2,
p_number_sec_sources out NOCOPY number,
p_sec_sources out NOCOPY varcharTableType,
p_sec_sources_alias out NOCOPY varcharTableType,
p_number_sec_key out NOCOPY number,
p_sec_sources_pk out NOCOPY varcharTableType,
p_sec_sources_fk out NOCOPY varcharTableType,
p_groupby_stmt out NOCOPY varchar2,
p_hold_number out NOCOPY number,
p_number_group_by_cols out NOCOPY number,
p_hold_relation out NOCOPY varcharTableType,
p_hold_item out NOCOPY varcharTableType,
p_group_by_cols out NOCOPY varcharTableType,
p_output_group_by_cols out NOCOPY varcharTableType,
p_number_input_params out NOCOPY number,
p_output_params out NOCOPY varcharTableType,
p_input_params out NOCOPY varcharTableType,
p_filter_stmt out NOCOPY varchar2
) return boolean ;
function is_src_fk(p_fk varchar2,p_src_fks varcharTableType,p_number_src_fks number) return boolean ;
function get_metadata_version return varchar2;
function get_dim_hier_levels(p_dim_name varchar2,
p_hier out NOCOPY varcharTableType,
p_parent_ltc out NOCOPY varcharTableType,
p_parent_ltc_id out NOCOPY numberTableType,
p_child_ltc out NOCOPY varcharTableType,
p_child_ltc_id out NOCOPY numberTableType,
p_number_hier out NOCOPY number) return boolean ;
function get_target_map(p_object_id number,p_object_name varchar2) return number ;
function get_last_analyzed_date(p_table varchar2) return date ;
function get_last_analyzed_date(p_table varchar2, p_owner varchar2) return date ;
function create_load_input_table(
  p_table_name varchar2,
  p_object_name in varchar2,
  p_mapping_id in number,
  p_map_type in varchar2,
  p_primary_src in number,
  p_primary_target in number,
  p_primary_target_name varchar2,
  p_object_type varchar2,
  p_conc_id in number,
  p_conc_program_name in varchar2,
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
  p_ok_table varchar2,
  p_hash_area_size number,
  p_sort_area_size number,
  p_trace boolean,
  p_read_cfig_options boolean,
  p_job_status_table varchar2,
  p_max_round number,
  p_update_dlog_lookup_table varchar2,
  p_dlog_has_data boolean,
  p_sleep_time number,
  p_parallel_drill_down boolean
  ) return boolean ;
function create_da_load_input_table(
p_da_cols_table varchar2,
p_op_table_space varchar2,
p_da_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_stg_da_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_da_cols number
) return boolean;
function update_load_input_table(
  p_table_name varchar2,
  p_ok_table varchar2,
  p_max_round number,
  p_update_dlog_lookup_table varchar2,
  p_dlog_has_data boolean,
  p_total_records number,
  p_stg_copy_table_flag boolean
)return boolean;
function check_job_status(p_job_id number) return varchar2 ;
function wait_on_jobs(
p_job_id number,
p_sleep_time number,
p_thread_type varchar2
) return boolean;
function wait_on_jobs(
p_job_id numberTableType,
p_number_jobs number,
p_sleep_time number,
p_thread_type varchar2
) return boolean ;
function terminate_jobs(
p_job_id numberTableType,
p_number_jobs number
)return boolean;
procedure dummy_proc;
function get_sid_for_job(p_job_id number) return number;
function get_session_parameters(
p_sid number,
p_serial out nocopy number
) return boolean;
function kill_session(
p_sid number,
p_serial number
)return boolean;
function remove_job(p_job_id number) return boolean ;
function find_ok_distribution(
p_ok_table varchar2,
p_table_owner varchar2,
p_max_threads number,
p_min_job_load_size number,
p_ok_low_end out NOCOPY EDW_OWB_COLLECTION_UTIL.numberTableType,
p_ok_high_end out NOCOPY EDW_OWB_COLLECTION_UTIL.numberTableType,
p_ok_end_count out NOCOPY integer
) return boolean;
function create_job_status_table(
p_table varchar2,
p_op_table_space varchar2
) return boolean ;
function get_join_nl(
p_load_size number,
p_total_records number,
p_cut_off_percentage number
) return boolean;
function set_session_parameters(
p_hash_area_size number,
p_sort_area_size number,
p_trace boolean,
p_parallel number
 )return boolean;
function log_into_job_status_table(
p_table varchar2,
p_object_name varchar2,
p_id number,
p_status varchar2,
p_message varchar2
)return boolean ;
function log_into_job_status_table(
p_table varchar2,
p_object_name varchar2,
p_id number,
p_status varchar2,
p_message varchar2,
p_measure1 number,
p_measure2 number,
p_measure3 number,
p_measure4 number,
p_measure5 number
)return boolean ;
function check_all_child_jobs(
p_job_status_table varchar2,
p_job_id numberTableType,
p_number_jobs number,
p_object_name varchar2
) return boolean;
function create_dim_load_input_table(
    p_dim_name varchar2,
    p_table varchar2,
    p_conc_id number,
    p_conc_name varchar2,
    p_levels varcharTableType,
    p_child_level_number numberTableType,
    p_child_levels varcharTableType,
    p_child_fk varcharTableType,
    p_parent_pk varcharTableType,
    p_level_snapshot_logs varcharTableType,
    p_number_levels number,
    p_debug boolean,
    p_exec_flag boolean,
    p_bis_owner varchar2,
    p_parallel number,
    p_collection_size number,
    p_table_owner varchar2,
    p_forall_size number,
    p_update_type varchar2,
    p_level_order varcharTableType,
    p_skip_cols varcharTableType,
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
    p_max_threads number,
    p_min_job_load_size number,
    p_sleep_time number,
    p_job_status_table varchar2,
    p_hash_area_size number,
    p_sort_area_size number,
    p_trace boolean,
    p_read_cfig_options boolean,
    p_max_fk_density number
    ) return boolean ;
function update_dim_load_input_table(
p_input_table varchar2,
p_ilog_table varchar2,
p_skip_ilog_update boolean,
p_level_change boolean,
p_dim_empty_flag boolean,
p_before_update_table_final varchar2,
p_error_rec_flag boolean,
p_consider_snapshot booleanTableType,
p_levels_I varcharTableType,
p_use_ltc_ilog booleanTableType,
p_number_levels number
)return boolean ;
function create_derv_fact_inp_table(
p_fact_name varchar2,
p_input_table varchar2,
p_fact_id number,
p_mapping_id number,
p_src_object varchar2,
p_src_object_id number,
p_fact_fks varcharTableType,
p_higher_level booleanTableType,
p_parent_dim varcharTableType,
p_parent_level varcharTableType,
p_level_prefix varcharTableType,
p_level_pk varcharTableType,
p_level_pk_key varcharTableType,
p_dim_pk_key varcharTableType,
p_number_fact_fks number,
p_conc_id number,
p_conc_program_name varchar2,
p_debug boolean,
p_collection_size number,
p_parallel number,
p_bis_owner varchar2,
p_table_owner  varchar2,
p_full_refresh boolean,
p_forall_size number,
p_update_type varchar2,
p_fact_dlog varchar2,
p_skip_cols varcharTableType,
p_number_skip_cols number,
p_load_fk number,
p_fresh_restart boolean,
p_op_table_space varchar2,
p_bu_tables varcharTableType,--before update tables.prop dim change to derv
p_bu_dimensions varcharTableType,
p_number_bu_tables number,
p_bu_src_fact varchar2,--what table to look at as the src fact. if null, scan full the src fact
p_load_mode varchar2,
p_rollback varchar2,
p_src_join_nl_percentage number,
p_max_threads number,
p_min_job_load_size number,
p_sleep_time number,
p_job_status_table varchar2,
p_hash_area_size number,
p_sort_area_size number,
p_trace boolean,
p_read_cfig_options boolean
) return boolean;
function update_derv_fact_input_table(
p_input_table varchar2,
p_ilog_table varchar2,
p_dlog_table varchar2,
p_skip_ilog_update boolean,
p_skip_dlog_update boolean,
p_skip_ilog boolean,
p_load_mode varchar2,
p_full_refresh boolean,
p_src_object_ilog varchar2,
p_src_object_dlog varchar2,
p_src_snplog_has_pk boolean,
p_err_rec_flag boolean,
p_err_rec_flag_d boolean
) return boolean;
function merge_all_ilog_tables (
p_ilog_pattern varchar2,
p_ilog_table varchar2,
p_ilog_table2 varchar2,
p_ilog_table_extn varchar2,
p_op_table_space varchar2,
p_bis_owner varchar2,
p_parallel number
)return boolean;
function merge_all_prot_tables(
p_prot_table varchar2,
p_prot_table_extn varchar2,
p_op_table_space varchar2,
p_bis_owner varchar2,
p_parallel number
)return boolean ;
function put_rownum_in_ilog_table(
p_ilog varchar2,
p_ilog_old varchar2,
p_op_table_space varchar2,
p_parallel number
)return boolean;
function get_ilog_tables_from_db(
p_ilog_table varchar2,
p_ilog_table_extn varchar2,
p_bis_owner varchar2,
p_ilog_tables out nocopy EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_ilog_tables out nocopy number
)return boolean ;
function drop_prot_tables(
p_prot_table varchar2,
p_prot_table_extn varchar2,
p_bis_owner varchar2
) return boolean ;
function drop_ilog_tables(
p_ilog_table varchar2,
p_ilog_table_extn varchar2,
p_bis_owner varchar2
) return boolean ;
function check_conc_process_status(p_conc_id number) return varchar2;
function update_inp_table_jobid(
p_input_table varchar2,
p_job_id number
)return boolean ;
function find_skip_attributes(
p_object_name varchar2,
p_object_type varchar2,
p_skip_cols out NOCOPY varcharTableType,
p_number_skip_cols out NOCOPY number
) return boolean;
function log_collection_start(
p_object_name varchar2,
p_object_id number,
p_object_type varchar2,
p_start_date date,
p_conc_program_id number,
p_load_pk number
) return boolean ;
function get_temp_log_data(
p_object_name varchar2,
p_object_type varchar2,
p_load_pk number,
p_ins_rows_ready out nocopy number,
p_ins_rows_processed out nocopy number,
p_ins_rows_collected out nocopy number,
p_ins_rows_dangling out nocopy number,
p_ins_rows_duplicate out nocopy number,
p_ins_rows_error out nocopy number,
p_ins_rows_insert out nocopy number,
p_ins_rows_update out nocopy number,
p_ins_rows_delete out nocopy number,
p_ins_instance_name out nocopy varchar2,
p_ins_request_id_table out nocopy varchar2
) return boolean ;
function get_child_job_status(
p_job_status_table varchar2,
p_object_name varchar2,
p_id out nocopy numberTableType,
p_job_id out nocopy numberTableType,
p_status out nocopy varcharTableType,
p_message out nocopy varcharTableType,
p_number_jobs out nocopy number
)return boolean ;
function get_job_queue_processes return number;
function get_app_long_name(
p_app_name varchar2,
p_app_long_name out nocopy varchar2
) return boolean ;
function update_inp_table_concid(
p_input_table varchar2,
p_conc_id number
)return boolean ;
function check_table_column(p_table varchar2,p_owner varchar2,p_col varchar2) return boolean;
function get_max_in_array(p_array numberTableType,p_number_array number,
p_index out nocopy number) return number;
function get_min_in_array(p_array numberTableType,p_number_array number,
p_index out nocopy number) return number;
function create_input_table_push_down(
  p_input_table varchar2,
  p_dim_name varchar2,
  p_dim_id number,
  p_levels varcharTableType,
  p_child_level_number numberTableType,
  p_child_levels varcharTableType,
  p_child_fk varcharTableType,
  p_parent_pk varcharTableType,
  p_number_levels number,
  p_level_order varcharTableType,
  p_level_snapshot_logs varcharTableType,
  p_level_ilog varcharTableType,
  p_level_consider booleanTableType,
  p_level_full_insert booleanTableType,
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
  p_rollback varchar2,
  p_max_threads number,
  p_min_job_load_size number,
  p_sleep_time number,
  p_hash_area_size number,
  p_sort_area_size number,
  p_trace boolean,
  p_read_cfig_options boolean,
  p_join_nl_percentage number
) return boolean;
function make_ilog_from_main_ilog(
p_ilog_rowid_table varchar2,
p_ilog_table varchar2,
p_low_end number,
p_high_end number,
p_op_table_space varchar2,
p_bis_owner varchar2,
p_parallel number,
p_ilog_rowid_number out nocopy number
) return boolean;
function check_index_on_column(
p_table varchar2,
p_owner varchar2,
p_column varchar2
)return boolean;
procedure create_status_table(p_table varchar2,p_op_table_space varchar2,
p_status varchar2,p_count number);
function drop_seq(p_seq varchar2,p_owner varchar2) return boolean;
function create_sequence(
p_seq varchar2,
p_owner varchar2,
p_start_with number,
p_flag varchar2
) return boolean;
function get_seq_nextval(p_seq varchar2) return number;
function get_max_value(p_table varchar2,p_col varchar2) return number;
function get_stg_map_fk_details(
p_fstg_usage_id number,
p_fstg_id number,
p_mapping_id number,
p_job_id number,
p_op_tablespace varchar2,
p_bis_owner varchar2,
p_dimTableName out nocopy varcharTableType,
p_dim_row_count out nocopy numberTableType,
p_dimTableId out nocopy numberTableType,
p_dimUserPKName out nocopy varcharTableType,
p_fstgUserFKName out nocopy varcharTableType,
p_factFKName out nocopy varcharTableType,
p_numberOfDimTables out nocopy number
)return boolean;
function get_stg_map_pk_params(
p_mapping_id number,
p_fstgTableUsageId out nocopy number,
p_fstgTableId out nocopy number,
p_fstgTableName out nocopy varchar2,
p_factTableUsageId out nocopy number,
p_factTableId out nocopy number,
p_factTableName out nocopy varchar2,
p_fstgPKName out nocopy varchar2,
p_factPKName out nocopy varchar2
) return boolean ;
function create_conc_program(
p_conc_name varchar2,
p_conc_short_name varchar2,
p_exe_name varchar2,
p_exe_file_name varchar2,
p_bis_short_name varchar2,
p_parameter varcharTableType,
p_parameter_value_set varcharTableType,
p_number_parameters number
) return boolean;
function delete_conc_program(
p_conc_name varchar2,
p_exe_name varchar2,
p_bis_name varchar2,
p_name_type varchar2
) return boolean;
procedure write_to_fnd_log(
p_message varchar2,
p_severity number);
function is_oracle_apps_GT_1159 return boolean;
procedure write_to_conc_log_file(p_message varchar2);
procedure init_all(
p_object_name varchar2,
p_debug boolean,
p_fnd_log_module varchar2
);
function get_parameter_value(
p_name varchar2
)return varchar2;
function get_db_version return varchar2;
function is_db_version_gt(p_db_version varchar2,p_version varchar2) return boolean;
function drop_stg_map_fk_details(
p_bis_owner varchar2,
p_mapping_id number
)return boolean;
function get_job_execute_time(p_job_id number) return varchar2;
function query_table_cols(
p_table varchar2,
p_col varchar2,
p_where varchar2,
p_output out nocopy varcharTableType,
p_num_output out nocopy number
) return boolean;
function terminate_job(p_job_id number) return boolean;
procedure dump_mem_stats;
procedure dump_parallel_stats;
function check_and_wait_for_job(
p_job_id number,
p_status_table varchar2,
p_where varchar2,
p_sleep_time number,
p_status out nocopy varchar2,
p_message out nocopy varchar2
)return boolean;
function get_tables_matching_pattern(
p_pattern varchar2,
p_owner varchar2,
p_table in out nocopy varcharTableType,
p_num_table in out nocopy number
)return boolean;
function update_status_table(
p_table varchar2,
p_col varchar2,
p_value varchar2,
p_where varchar2
) return boolean;
function create_dd_status_table(
p_table varchar2,
p_level_order varcharTableType,
p_number_levels number
) return boolean;
function is_table_partitioned(p_table varchar2,p_owner varchar2) return varchar2;
function drop_level_UL_tables(
p_dim_id number,
p_bis_owner varchar2
) return boolean;
function is_source_for_fast_refresh_mv(
p_object varchar2,
p_owner varchar2
) return number;
function drop_tables_like(p_string varchar2,p_owner varchar2)return boolean;
procedure create_rownum_index_ilog(
p_ilog varchar2,
p_op_table_space varchar2,
p_parallel number
);
function get_all_derived_facts_inc(
p_object varchar2,
p_derived_facts out NOCOPY varcharTableType,
p_derived_fact_ids out NOCOPY numberTableType,
p_map_id  out NOCOPY numberTableType,
p_number_derived_facts out NOCOPY number) return boolean;
function get_fact_dfact_ilog(
p_bis_owner varchar2,
p_src_fact_id number,
p_derived_fact_id number) return varchar2;
function get_fact_dfact_dlog(
p_bis_owner varchar2,
p_src_fact_id number,
p_derived_fact_id number) return varchar2;
function clean_ilog_dlog_base_fact(
p_fact varchar2,
p_owner varchar2,
p_bis_owner varchar2,
p_fact_id number,
p_fact_dlog varchar2
)return boolean ;
procedure create_iot_index(
p_table varchar2,
p_column varchar2,
p_tablespace varchar2,
p_parallel number);
FUNCTION get_apps_schema_name RETURN VARCHAR2;
END EDW_OWB_COLLECTION_UTIL;

 

/
