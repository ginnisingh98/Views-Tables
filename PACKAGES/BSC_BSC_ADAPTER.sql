--------------------------------------------------------
--  DDL for Package BSC_BSC_ADAPTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_BSC_ADAPTER" AUTHID CURRENT_USER AS
/*$Header: BSCBSCMS.pls 120.6 2006/02/15 17:57:53 arsantha noship $*/
--program runtime parameters
g_debug boolean;
g_status boolean;
g_status_message varchar2(4000);
g_apps_owner varchar2(200);
g_bsc_owner varchar2(200);
g_prod_owner varchar2(200);
g_options BSC_IM_UTILS.varchar_tabletype;
g_number_options number;
g_stmt varchar2(32000);
---
g_periodicity_id_for_type BSC_IM_UTILS.number_tabletype;
---
g_rec_count number;
g_create_dbi_dim_tables boolean;
---
type cal_refreshed is record(
calendar_id number);
type tab_cal_refreshed is table of cal_refreshed index by pls_integer;

g_calendars_refreshed tab_cal_refreshed;

---
type cal_record is record(
calendar_year number,
calendar_month number,
calendar_day number,
year number,
semester number,
bimester number,
quarter number,
month number,
week52 number,
day365 number,
custom_1 number,
custom_2 number,
custom_3 number,
custom_4 number,
custom_5 number,
custom_6 number,
custom_7 number,
custom_8 number,
custom_9 number,
custom_10 number,
custom_11 number,
custom_12 number,
custom_13 number,
custom_14 number,
custom_15 number,
custom_16 number,
custom_17 number,
custom_18 number,
custom_19 number,
custom_20 number);
type cal_record_table is table of cal_record;
------------
type cal_periodicity is record(
periodicity_id number,
source varchar2(4000),
db_column_name varchar2(200),
periodicity_type number,
period_type_id integer,
record_type_id integer,
xtd_pattern varchar2(4000));
type cal_periodicity_table is table of cal_periodicity;
-----------
g_rec_dbi_dim BSC_UPDATE_DIM.t_array_dbi_dim_data;
-----------
--functions--------------------------------------------------------
function get_time return varchar2 ;
function init_all return boolean;
function load_metadata_for_indicators(
p_indicator varchar2,
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number
)return boolean;
function read_metadata(
p_indicators BSC_IM_UTILS.number_tabletype,
p_number_indicators number,
p_final_dimensions out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_final_dimensions out nocopy number
) return boolean;
function read_kpi_required(
p_indicators BSC_IM_UTILS.number_tabletype,
p_indicator_names BSC_IM_UTILS.varchar_tabletype,
p_number_indicators number
) return boolean;
function get_table_cols(
p_table_name varchar2,
p_col_table in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_cols in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_col_type in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_source_column in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_source_formula in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_cols in out nocopy number
) return boolean;
function get_table_periodicity(p_table_name varchar2) return number;
function get_s_sb_tables(
p_indicator_id number,
p_s_tables out nocopy BSC_IM_UTILS.varchar_tabletype,
p_s_periodicity out nocopy BSC_IM_UTILS.number_tabletype,
p_number_s_tables out nocopy number
)return boolean;
function get_kpi_periodicity(
p_indicator_id number,
p_periodicity out nocopy BSC_IM_UTILS.number_tabletype,
p_number_periodicity out nocopy number
)return boolean;
function get_db_calculation(
p_indicator number,
p_s_table varchar2,
p_type number,
p_calculation_table in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_calculation_type in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_parameter1 in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_parameter2 in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_parameter3 in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_parameter4 in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_parameter5 in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_parameters in out nocopy number
) return boolean;
function get_table_relations(
p_table varchar2,
p_tables in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_source_tables in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_relation_type in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_tables in out nocopy number
) return boolean ;
function get_summarize_calendar(
p_periodicity number,
p_calendar out nocopy varchar2,
p_calendar_tables out nocopy varchar2,
p_calendar_alias out nocopy varchar2,
p_calendar_join_1 out nocopy varchar2,
p_calendar_join_2 out nocopy varchar2
)return boolean ;
function get_columns_in_formula(
p_expression varchar2,
p_measure BSC_IM_UTILS.varchar_tabletype,
p_number_measure number,
p_table out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_table out nocopy number
)return boolean;
function get_period_type_id(p_level varchar2) return number;
function find_xtd_levels(
p_periodicity number,
p_xtd_levels out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_xtd_levels out nocopy number
)return boolean ;
function load_reporting_calendar(
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number
)return boolean;
--Fix bug#4027813 This function created to load reporting calendar only for the specified
--calendar id
function load_reporting_calendar(
p_calendar_id number,
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number
)return boolean;
function load_reporting_calendar(
p_calendar_id number,
p_calendar_type varchar2,
p_hierarchy varchar2,
p_hierarchy_type varchar2,
p_periodicity_data cal_periodicity_table,
p_number_periodicity_data number
)return boolean;
function load_reporting_calendar_DBI(
p_calendar_id number,
p_calendar_type varchar2,
p_hierarchy varchar2,
p_hierarchy_type varchar2,
p_calendar_data cal_record_table,
p_number_calendar_data number,
p_periodicity_data cal_periodicity_table,
p_number_periodicity_data number
)return boolean;
function get_calendar_data(
p_calendar_id number,
p_calendar_data out nocopy cal_record_table,
p_number_calendar_data out nocopy number
) return boolean;
function get_periodicity_data(
p_calendar_id number,
p_calendar_type number,
p_periodicity_data out nocopy cal_periodicity_table,
p_number_periodicity_data out nocopy number
)return boolean;
function get_calendar_for_periodicity(p_periodicity number) return number;
function get_reporting_calendar_name return varchar2;
function get_table_fks(
p_s_tables BSC_IM_UTILS.varchar_tabletype,
p_number_s_tables number,
p_fk out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_fk out nocopy number
) return boolean;
function get_table_fks(
p_table varchar2,
p_fk out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_fk out nocopy number
) return boolean;
function get_table_measures(
p_s_tables BSC_IM_UTILS.varchar_tabletype,
p_number_s_tables number,
p_measures out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_measures out nocopy number
) return boolean;
function get_table_measures(
p_table varchar2,
p_measures out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_measures out nocopy number
) return boolean;
function get_level_for_pk(
p_level_pk varchar2,
p_level out nocopy varchar2,
p_src_object out nocopy varchar2, --only populated if this is a DBI dimension
p_special_dim out nocopy varchar2,
p_rec_dim out nocopy boolean,
p_rec_dim_key out nocopy varchar2
)return boolean;
function get_table_sql(
p_table varchar2,
p_table_sql out nocopy varchar2,
p_b_tables in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_b_tables in out nocopy number,
p_dim_level_tables in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_dim_level_tables in out nocopy number
)return boolean;
function read_kpi_map_info(
p_indicator number,
p_periodicity BSC_IM_UTILS.number_tabletype,
p_number_periodicity number
)return boolean;
function create_kpi_map_info(
p_indicator number,
p_map_name varchar2,
p_mv_name varchar2,
p_zero_code_mv_name varchar2,
p_zero_code_map_name varchar2,
p_s_tables BSC_IM_UTILS.varchar_tabletype,
p_number_s_tables number
)return boolean ;
function get_filter_stmt(
p_indicator number,
p_table varchar2,
p_filter_from out nocopy BSC_IM_UTILS.varchar_tabletype,
p_filter_where out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_filter out nocopy number,
p_dim_level_tables in out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_dim_level_tables in out nocopy number,
p_filter_first_level out nocopy BSC_IM_UTILS.varchar_tabletype,
p_filter_first_level_alias out nocopy BSC_IM_UTILS.varchar_tabletype, --this will be the alias L1
p_filter_first_level_fk out nocopy BSC_IM_UTILS.varchar_tabletype,
p_num_filter_first_level out nocopy number
) return boolean;
function get_dim_level_cols(
p_level varchar2,
p_columns out nocopy BSC_IM_UTILS.varchar_tabletype,
p_column_type out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_columns out nocopy number
)return boolean;
function get_s_tables_for_mv(
p_mv varchar2,
p_s_tables out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_s_tables out nocopy number
)return boolean;
function built_hier(
p_calendar_id number,
p_calendar_type number,
p_periodicity_data cal_periodicity_table,
p_number_periodicity_data number,
p_hier out nocopy BSC_IM_UTILS.varchar_tabletype,
p_hier_type out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_hier out nocopy number
)return boolean;
function get_periodicity_for_type(
p_periodicity_type number,
p_periodicity_data cal_periodicity_table,
p_number_periodicity_data number
)return number;
function built_hier_rec(
p_parent number,
p_parent_hier BSC_IM_UTILS.number_tabletype,
p_child_hier BSC_IM_UTILS.number_tabletype,
p_parent_type BSC_IM_UTILS.varchar_tabletype,
p_number_rel number,
p_hier out nocopy BSC_IM_UTILS.varchar_tabletype,
p_hier_type out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_hier out nocopy number
)return boolean;
function set_xtd_pattern(
p_calendar_id number,
p_periodicity_data in out nocopy cal_periodicity_table,
p_number_periodicity_data number,
p_hier BSC_IM_UTILS.varchar_tabletype,
p_hier_type BSC_IM_UTILS.varchar_tabletype,
p_number_hier number
)return boolean;
function get_xtd_pattern(
p_periodicity_id number,
p_hier varchar2,
p_periodicity_data cal_periodicity_table,
p_number_periodicity_data number
) return number;
function get_period_type_id_for_period(
p_periodicity_id number,
p_periodicity_data cal_periodicity_table,
p_number_periodicity_data number
)return number;
function get_period_type_id_for_period(
p_periodicity_id number
)return number;
------
--bug 3324876
function get_filter_view_params(
p_indicator number,
p_level varchar2,
p_source_type out nocopy number,
p_source_code out nocopy number,
p_dim_level_id out nocopy number
) return number;
function get_filter_stmt_rec(
p_indicator number,
p_child_level varchar,
p_child_level_pk varchar,
p_count in out nocopy number,
p_level_count in out nocopy number,
p_from_stmt in out nocopy varchar2,
p_where_stmt in out nocopy varchar2,
--added by arun
p_pk_cols  BSC_IM_UTILS.varchar_tabletype
) return boolean;
function get_parent_level(
p_child_level varchar2,
p_level_fk out nocopy BSC_IM_UTILS.varchar_tabletype,
p_parent_level out nocopy BSC_IM_UTILS.varchar_tabletype,
p_num_parent_levels out nocopy number
) return boolean;
function load_rpt_cal_DBI_rolling(
p_calendar_id number,
p_calendar_type varchar2,
p_hierarchy varchar2,
p_hierarchy_type varchar2,
p_calendar_data cal_record_table,
p_number_calendar_data number,
p_periodicity_data cal_periodicity_table,
p_number_periodicity_data number
)return boolean ;
function get_level_short_name(p_table_name varchar2) return varchar2 ;
function create_dbi_dim_tables return boolean ;
procedure get_list_of_rec_dim(
p_dim_list out nocopy bsc_varchar2_table_type,
p_num_dim_list out nocopy number,
p_error_message out nocopy varchar2);
procedure get_list_of_rec_dim(
p_dim_list out nocopy BSC_UPDATE_DIM.t_array_dbi_dim_data
);
procedure set_and_get_dim_sql(
p_dim_level_short_name bsc_varchar2_table_type,
p_dim_level_value bsc_varchar2_table_type,
p_num_dim_level number,
p_dim_level_sql out nocopy bsc_varchar2_table_type,
p_error_message out nocopy varchar2
);
procedure create_int_md_fk(
p_mv_name varchar2
);
--procedures-------------------------------------------------------
procedure write_to_log_file(p_message varchar2);
procedure write_to_log_file_n(p_message varchar2);
procedure write_to_debug_n(p_message varchar2);
procedure write_to_debug(p_message varchar2);
procedure set_globals(p_debug boolean);
-------------------------------------------------------------------

END BSC_BSC_ADAPTER;
 

/
