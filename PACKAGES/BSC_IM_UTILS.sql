--------------------------------------------------------
--  DDL for Package BSC_IM_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_IM_UTILS" AUTHID CURRENT_USER AS
/*$Header: BSCOLUTS.pls 120.1 2006/02/16 15:18:03 arsantha noship $*/

Type varchar_tabletype is Table of varchar2(32000) index by binary_integer;
Type number_tabletype is Table of number index by binary_integer;
Type boolean_tabletype is Table of boolean index by binary_integer;
Type date_tabletype is Table of date index by binary_integer;
g_debug boolean;
G_CLOB clob;
g_stmt varchar2(32000);
g_in_stmt varchar2(29000);
g_number_global_dimension number;
g_global_dimension varchar_tabletype;
g_id number;
g_aw_installed boolean;
g_status_message varchar2(10000);
g_db_version varchar2(40);
g_apps_owner varchar2(200);
--functions--------------------------------------------------------
procedure open_file(p_object_name varchar2);
procedure write_to_log(p_message varchar2,p_new_line boolean);
procedure write_to_log_file_s(p_message varchar2);
procedure write_to_log_file(p_message varchar2);
procedure write_to_log_file_n(p_message varchar2);
procedure write_to_debug_n(p_message varchar2);
procedure write_to_debug(p_message varchar2);
procedure write_to_out_file(p_message varchar2);
procedure write_to_out_file_s(p_message varchar2);
procedure write_to_out_file_n(p_message varchar2);

-- Start of apis added by arun for bug 3876730
FUNCTION getParsedIndicNumber(p_Stable IN VARCHAR2) RETURN VARCHAR2;
function needs_zero_code_mv(p_mv_name varchar2,p_kpi varchar2,p_fk varchar2) return boolean ;
function needs_zero_code_b_pt(p_b_pt_table_name varchar2,p_fk varchar2) return boolean ;
-- End of apis added by arun for bug 3876730

FUNCTION IsNumber (str IN VARCHAR2) RETURN BOOLEAN ;
function get_time return varchar2;
function is_column_in_object(p_object varchar2,p_column varchar2) return boolean;
function in_array(p_table varchar_tabletype,p_number_table number,p_value varchar2) return boolean;
function in_array(p_table number_tabletype,p_number_table number,p_value number) return boolean;
function in_array(p_table number_tabletype, p_table2 varchar_tabletype,
p_number_table number,p_value number,p_value2 varchar2) return boolean;
function in_array(p_table number_tabletype, p_table2 number_tabletype,
p_number_table number,p_value number,p_value2 number) return boolean;
function in_array(p_table varchar_tabletype, p_table2 varchar_tabletype,
p_number_table number,p_value varchar2,p_value2 varchar2) return boolean;
function in_array(p_table1 number_tabletype, p_table2 number_tabletype,
p_table3 number_tabletype,p_number_table number,p_value1 number,
p_value2 number,p_value3 number) return boolean;
function add_distinct_values_to_table(
p_table in out nocopy varchar_tabletype,
p_number_table in out nocopy number,
p_values_table varchar_tabletype,
p_number_values_table number,
p_options varchar2) return boolean;
function add_distinct_values_to_table(
p_table in out nocopy varchar_tabletype,
p_number_table in out nocopy number,
p_value varchar2,
p_options varchar2) return boolean;
procedure set_globals(p_debug boolean);
function get_db_user(
p_product varchar2,
p_db_user out nocopy varchar2
)return boolean;
function read_global return number;
function read_sequence(p_seq varchar) return number;
function sort_number_array(
p_list number_tabletype,
p_number_list number,
p_direction varchar2,
p_sorted_list out nocopy number_tabletype) return boolean;
function get_index(p_table varchar_tabletype,p_number_table number,p_value varchar2) return number;
function get_index(p_table number_tabletype,p_number_table number,p_value number) return number;
function get_index(
p_table_1 varchar_tabletype,
p_table_2 number_tabletype,
p_number_table number,
p_value_1 varchar2,
p_value_2 number
) return number;
function get_index(
p_table_1 varchar_tabletype,
p_table_2 varchar_tabletype,
p_number_table number,
p_value_1 varchar2,
p_value_2 varchar2
) return number;
function get_rank(
p_parent_array varchar_tabletype,
p_child_array varchar_tabletype,
p_number_array number,
p_rep_array out nocopy varchar_tabletype,
p_rep_rank out nocopy number_tabletype,
p_number_rep_array out nocopy number,
p_max_rank out nocopy number
) return boolean;
function set_rank(
p_parent_array varchar_tabletype,
p_child_array varchar_tabletype,
p_number_array number,
p_child_level varchar2,
p_rank number,
p_rep_array in out nocopy varchar_tabletype,
p_rep_rank in out nocopy number_tabletype,
p_number_rep_array in out nocopy number
) return boolean;
function get_distinct_list(
p_input varchar_tabletype,
p_number_input number,
p_dist_list out nocopy varchar_tabletype,
p_number_dist_list out nocopy number
) return boolean;
function get_distinct_list(
p_input number_tabletype,
p_number_input number,
p_dist_list out nocopy number_tabletype,
p_number_dist_list out nocopy number
) return boolean;
function parse_values(
p_list varchar2,
p_separator varchar2,
p_names out nocopy varchar_tabletype,
p_number_names out nocopy number) return boolean;
function parse_values(
p_list varchar2,
p_separator varchar2,
p_names out nocopy number_tabletype,
p_number_names out nocopy number) return boolean;
function parse_and_find(
p_list varchar2,
p_separator varchar2,
p_string  varchar2
)return boolean;
function get_value(
p_list varchar_tabletype,
p_list_values varchar_tabletype,
p_number_list number,
p_list_name varchar2
)return varchar2;
function get_seq_nextval(p_seq varchar2) return number;
function drop_db_object(p_object varchar2,p_type varchar2,p_owner varchar2) return boolean;
function set_global_dimensions return boolean;
function get_global_dimensions(
p_global_dimensions out nocopy varchar_tabletype,
p_number_global_dimensions out nocopy number
) return boolean;
function is_global_dimension(
p_column varchar2
)return boolean;
function check_package(p_package varchar2) return boolean;
function get_table_owner(p_table varchar2) return varchar2;
function get_object_owner(p_object varchar2) return varchar2;
function get_table_constraints(
p_table_name varchar2,
p_table_owner varchar2,
p_constraint_name out nocopy varchar_tabletype,
p_constraint_type out nocopy varchar_tabletype,
p_status out nocopy varchar_tabletype,
p_validated out nocopy varchar_tabletype,
p_index_name out nocopy varchar_tabletype,
p_number_constraints out nocopy number
)return boolean;
function create_mv_log_on_table(
p_table_name varchar2,
p_table_owner varchar2,
p_options varchar_tabletype,
p_number_options number,
p_uk_columns varchar_tabletype,
p_numbet_uk_columns number,
p_columns varchar_tabletype,
p_number_columns number,
p_snplog_creates out nocopy boolean
)return boolean;
function check_snapshot_log(
p_table_name varchar2,
p_table_owner varchar2
)return boolean;
function get_mv_owner(p_mv_name varchar2) return varchar2;
function get_mv_properties(
p_mv_name varchar2,
p_mv_owner in out nocopy varchar2,
p_refresh_mode out nocopy varchar2,
p_refresh_method out nocopy varchar2,
p_build_mode out nocopy varchar2,
p_last_refresh_type out nocopy varchar2,
p_last_refresh_date out nocopy date,
p_staleness out nocopy varchar2
)return boolean;
function drop_materialized_view(p_mview varchar2,p_owner varchar2) return boolean;
function check_mv(
p_mv_name varchar2,
p_mv_owner varchar2
)return boolean;
function drop_table(p_table varchar2,p_owner varchar2) return boolean;
function get_table_properties(
p_table varchar2,
p_owner varchar2,
p_columns out nocopy varchar_tabletype,
p_columns_data_type out nocopy varchar_tabletype,
p_number_columns out nocopy number
)return boolean;
function drop_synonym(p_syn_name varchar2) return boolean;
function get_ordered_levels(
p_dim_name varchar2,
p_apps_origin varchar2,
p_levels varchar_tabletype,
p_number_levels number,
p_ordered_levels out nocopy varchar_tabletype,
p_number_children out nocopy number_tabletype
)return boolean;
function get_ordered_levels(
p_levels varchar_tabletype,
p_level_number_children number_tabletype,
p_number_levels number,
p_ordered_levels out nocopy varchar_tabletype) return boolean;
function get_all_levels_between(
p_dim_name varchar2,
p_apps_origin varchar2,
p_level_1 varchar2,
p_level_2 varchar2,
p_child_level out nocopy varchar_tabletype,
p_child_level_fk out nocopy varchar_tabletype,
p_parent_level out nocopy varchar_tabletype,
p_parent_level_pk out nocopy varchar_tabletype,
p_hier out nocopy varchar_tabletype,
p_number_hier out nocopy number
)return boolean;
function get_all_levels_between(
p_level_1 varchar2,
p_level_2 varchar2,
p_hier varchar2,
p_child_level varchar_tabletype,
p_parent_level varchar_tabletype,
p_child_fk varchar_tabletype,
p_parent_pk varchar_tabletype,
p_hier_rel varchar_tabletype,
p_number_rels number,
po_child_level out nocopy varchar_tabletype,
po_child_level_fk out nocopy varchar_tabletype,
po_parent_level out nocopy varchar_tabletype,
po_parent_level_pk out nocopy varchar_tabletype,
po_hier out nocopy varchar_tabletype,
po_number_hier out nocopy number
)return boolean;
function get_option_value(
p_options varchar_tabletype,
p_number_options number,
p_check_option varchar2
)return varchar2;
function get_option_value(
p_options varchar2,
p_separator varchar2,
p_check_option varchar2
)return varchar2;
function drop_mv_log(
p_table_name varchar2,
p_table_owner varchar2
)return boolean;
function drop_constraint(
p_table_name varchar2,
p_table_owner varchar2,
p_constraint varchar2
)return boolean;
function get_table_storage(
p_table varchar2,
p_owner varchar2,
p_table_space out nocopy varchar2,
p_initial_extent out nocopy number,
p_next_extent out nocopy number,
p_pct_free out nocopy number,
p_pct_used out nocopy number,
p_pct_increase out nocopy number,
p_max_extents out nocopy number,
p_avg_row_len out nocopy number
) return boolean;
function drop_mv(
p_mv varchar2,
p_mv_owner varchar2
)return boolean ;
function get_object_type(
p_object varchar2,
p_owner varchar2
) return varchar2;
function get_table_indexes(
p_table_name varchar2,
p_table_owner varchar2,
p_index out nocopy varchar_tabletype,
p_uniqueness out nocopy varchar_tabletype,
p_tablespace out nocopy varchar_tabletype,
p_initial_extent out nocopy number_tabletype,
p_next_extent out nocopy number_tabletype,
p_max_extents out nocopy number_tabletype,
p_pct_increase  out nocopy number_tabletype,
p_number_index out nocopy number
) return boolean ;
function get_table_indexes(
p_table_name varchar2,
p_table_owner varchar2,
p_index out nocopy varchar_tabletype,
p_uniqueness out nocopy varchar_tabletype,
p_tablespace out nocopy varchar_tabletype,
p_initial_extent out nocopy number_tabletype,
p_next_extent out nocopy number_tabletype,
p_max_extents out nocopy number_tabletype,
p_pct_increase  out nocopy number_tabletype,
p_number_index out nocopy number,
p_ind_name out nocopy varchar_tabletype,
p_ind_col out nocopy varchar_tabletype,
p_number_ind_col out nocopy number
) return boolean;
function get_synonym_property(
p_synonym varchar2,
p_syn_owner out nocopy varchar2,
p_syn_object out nocopy varchar2
)return boolean;
function create_synonym(
p_synonym varchar2,
p_syn_owner varchar2,
p_syn_object varchar2
)return boolean;
procedure set_trace;
procedure analyze_object(
p_object varchar2,
p_owner varchar2,
p_sample number,
p_parallel number,
p_partname varchar2
);
function get_object_name(p_object_name varchar2) return varchar2 ;
function get_corrected_map_table(
p_map_table varchar2,--could be sql stmt
p_map_table_list varchar2,
p_options varchar_tabletype,
p_number_options number,
p_apps_src varchar2,
p_olap_target varchar2,
p_corr_table_name out nocopy varchar2,
p_corr_table_list out nocopy varchar_tabletype,
p_original_table_list out nocopy varchar_tabletype,
p_number_corr_table out nocopy number
)return boolean;
function get_corrected_map_table_bsc_mv(
p_map_table varchar2,--could be sql stmt
p_map_table_list varchar2,
p_options varchar_tabletype,
p_number_options number,
p_corr_table_name out nocopy varchar2,
p_corr_table_list out nocopy varchar_tabletype,
p_original_table_list out nocopy varchar_tabletype,
p_number_corr_table out nocopy number
)return boolean;
function get_db_version return varchar2;
function drop_object(
p_object varchar2,
p_owner varchar2
) return boolean;
function is_mview(
p_mview varchar2,
p_owner varchar2
)return boolean ;
function does_table_have_data(p_table varchar2, p_where varchar2) return number;
function does_table_have_data(p_table varchar2, p_where varchar2,p_bind varchar2) return boolean;
function truncate_table(p_table varchar2, p_owner varchar2) return boolean;
function find_aggregation_columns(
p_formula varchar2,
p_columns out nocopy varchar_tabletype,
p_number_columns out nocopy number
)return boolean;
function refresh_mv(
p_mv_name varchar2,
p_mv_owner varchar2,
p_kpi varchar2,
p_options varchar_tabletype,
p_number_options number
)return boolean;
function drop_view(
p_view varchar2,
p_view_owner varchar2
)return boolean;
function check_view(
p_view_name varchar2,
p_view_owner varchar2
)return boolean;
function get_bsc_owner return varchar2;
function get_lang return varchar2;
function is_like(p_string varchar2,p_comp_string varchar2) return boolean;
function create_index(
p_table_name varchar2,
p_table_owner varchar2,
p_index varchar_tabletype,
p_uniqueness varchar_tabletype,
p_tablespace varchar_tabletype,
p_initial_extent number_tabletype,
p_next_extent number_tabletype,
p_max_extents number_tabletype,
p_pct_increase  number_tabletype,
p_number_index number,
------
p_ind_name varchar_tabletype,
p_ind_col varchar_tabletype,
p_number_ind_col number
)return boolean;
function create_index(
p_stmt varchar2,
p_options varchar2
)return boolean;
function execute_immediate(
p_stmt varchar2,
p_options varchar2
) return boolean;
function is_cube_present(
p_cube varchar2,
p_apps_origin varchar2
)return boolean;
function get_snapshot_log(
p_table_name varchar2,
p_table_owner varchar2,
p_snplog out nocopy varchar2
)return boolean;
function is_view_present(p_view_like varchar2) return boolean;
function get_parent_mv(
p_mv varchar2,
p_parent_mv out nocopy varchar_tabletype,
p_number_parent_mv out nocopy number
)return boolean ;
function get_child_mv(
p_mv varchar2,
p_child_mv out nocopy varchar_tabletype,
p_number_child_mv out nocopy number
)return boolean;
function is_parent_of_type_present(
p_object varchar2,
p_parent_type varchar2
)return boolean;
function get_apps_owner return varchar2;
END BSC_IM_UTILS;

 

/
