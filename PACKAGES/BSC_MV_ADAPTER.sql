--------------------------------------------------------
--  DDL for Package BSC_MV_ADAPTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_MV_ADAPTER" AUTHID CURRENT_USER AS
/*$Header: BSCMVLDS.pls 120.1 2005/08/10 16:51:27 arsantha noship $*/

--program runtime parameters
g_debug boolean;
g_status boolean;
g_stmt varchar2(32000);
g_apps_origin varchar2(100);
g_parallel number;
g_status_message varchar2(2000);
g_bsc_owner varchar2(100);
g_all_levels_mv boolean;
g_kpi varchar2(200);--to improve perf and reduce hits on the DB
--functions--------------------------------------------------------
function get_time return varchar2 ;
function init_all return boolean;
function create_mv_normal(
p_kpi varchar2,
p_mv_name varchar2,
p_mv_owner varchar2,
p_child_mv BSC_IM_UTILS.varchar_tabletype,
p_number_child_mv number,
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number,
p_apps_origin varchar2,
p_type varchar2,
p_create_non_unique_index boolean
)return boolean;
function create_mv_kpi(
p_kpi varchar2,
p_apps_origin varchar2,
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number
) return boolean ;
function create_mv_synonym(
p_level varchar2,
p_mv_name varchar2,
p_mv_owner varchar2
)return boolean;
function alter_mv_to_refresh_demand(
p_mv_name varchar2,
p_mv_owner varchar2
)return boolean;
function create_mv_log_on_table(
p_object varchar2,
p_apps_origin varchar2,
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number,
p_snplog_created out nocopy boolean
)return boolean;
function refresh_mv_kpi(
p_kpi varchar2,
p_apps_origin varchar2,
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number
) return boolean;
function drop_mv_kpi(
p_kpi varchar2,
p_apps_origin varchar2,
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number
) return boolean;
function drop_summary_objects(
p_mv_list varchar2,
p_synonym_list varchar2,
p_options varchar2,
p_error_message out nocopy varchar2
) return boolean;
function get_ordered_mv_list(
p_kpi varchar2,
p_apps_origin varchar2,
p_parent_summary_mv out nocopy BSC_IM_UTILS.varchar_tabletype,
p_child_summary_mv out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_pc_mv out nocopy number,
p_ordered_summary_mv out nocopy BSC_IM_UTILS.varchar_tabletype,
p_ordered_summary_mv_rank out nocopy BSC_IM_UTILS.number_tabletype,
p_number_ordered_summary_mv out nocopy number,
p_max_rank out nocopy number
)return boolean ;
function create_dummy_mv(
p_b_tables BSC_IM_UTILS.varchar_tabletype,
p_number_b_tables number,
p_mv_name varchar2,
p_mv_owner varchar2
)return boolean;
function get_dummy_mv(
p_mv_name varchar2,
p_mv_owner varchar2,
p_dummy_mv out nocopy BSC_IM_UTILS.varchar_tabletype,
p_number_dummy_mv out nocopy number
)return boolean ;
function create_mv_index(
p_mv_name varchar2,
p_mv_owner varchar2,
p_kpi varchar2,
p_apps_origin varchar2,
p_tablespace varchar2,
p_storage varchar2,
p_create_non_unique_index boolean,
p_called_from_refresh boolean default false
)return boolean;
function refresh_mv(
p_mv varchar2,
p_kpi varchar2,
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number
) return boolean;
function drop_mv(
p_mv varchar2,
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number
)return boolean;
function create_zero_code_mv_kpi(
p_kpi varchar2,
p_apps_origin varchar2,
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number,
p_max_rank number,
p_bsc_owner varchar2,
p_max_mv_levels number,
p_ordered_summary_mv BSC_IM_UTILS.varchar_tabletype,
p_ordered_summary_mv_rank BSC_IM_UTILS.number_tabletype,
p_number_ordered_summary_mv number
) return boolean ;
function object_index_validation(
p_object varchar2,
p_owner varchar2,
p_kpi varchar2,
p_apps_origin varchar2,
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number,
p_create_non_unique_index boolean
)return boolean;
function check_old_mv_view(
p_mv_name varchar2,
p_mv_owner varchar2,
p_type varchar2,
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number
)return varchar2;
--procedures-------------------------------------------------------
procedure write_to_log_file(p_message varchar2);
procedure write_to_log_file_n(p_message varchar2);
procedure write_to_debug_n(p_message varchar2);
procedure write_to_debug(p_message varchar2);
procedure set_globals(p_debug boolean);
-------------------------------------------------------------------

END BSC_MV_ADAPTER;

 

/
