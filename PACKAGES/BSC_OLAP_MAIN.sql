--------------------------------------------------------
--  DDL for Package BSC_OLAP_MAIN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_OLAP_MAIN" AUTHID CURRENT_USER AS
/*$Header: BSCMAINS.pls 120.1 2005/09/08 14:06:45 arsantha noship $*/

--program runtime parameters
g_debug boolean;
g_status boolean;
G_CLOB clob;
g_aw_workspace varchar2(200);
g_init_all varchar2(10);
g_status_message varchar2(4000);
g_options BSC_IM_UTILS.varchar_tabletype;
g_number_options number;
b_table_col_type_created boolean := false;  --Bug 3878968
g_col_type_table_name VARCHAR2(30):= 'BSC_TMP_COL_TYPE_'||userenv('SESSIONID');

g_summary_table_tbs_clause varchar2(4000);
g_summary_index_tbs_clause varchar2(4000);
g_summary_table_tbs_name varchar(1000);
g_summary_index_tbs_name varchar2(1000);
--------------------PUBLIC API-------------------------------------
function implement_bsc_mv(
p_kpi varchar2,
p_option_string varchar2,
p_error_message out nocopy varchar2)return boolean;
function drop_bsc_mv(
p_kpi varchar2,
p_option_string varchar2,
p_error_message out nocopy varchar2)return boolean;
function drop_summary_mv(
p_mv varchar2,
p_option_string varchar2,
p_error_message out nocopy varchar2)return boolean;
function refresh_bsc_mv(
p_kpi varchar2,
p_option_string varchar2,
p_error_message out nocopy varchar2)return boolean ;
function refresh_summary_mv(
p_mv varchar2,
p_kpi varchar2,
p_option_string varchar2,
p_error_message out nocopy varchar2)return boolean;
--------------------------------------
function load_reporting_calendar(
p_apps varchar2,
p_option_string varchar2,
p_error_message out nocopy varchar2)return boolean;
--Fix bug#4027813: Added this function to load reporting calendar for only
--the specified calendar id
function load_reporting_calendar(
p_calendar_id number,
p_apps varchar2,
p_option_string varchar2,
p_error_message out nocopy varchar2)return boolean;
--------------------------------------
--for PMV to handle recursive dimensions
procedure get_list_of_rec_dim(
p_dim_list out nocopy bsc_varchar2_table_type,
p_num_dim_list out nocopy number,
p_error_message out nocopy varchar2);
procedure set_and_get_dim_sql(
p_dim_level_short_name bsc_varchar2_table_type,
p_dim_level_value bsc_varchar2_table_type,
p_num_dim_level number,
p_dim_level_sql out nocopy bsc_varchar2_table_type,
p_error_message out nocopy varchar2
);
--------------------------------------
procedure reset;
procedure open_file;
--------------------------------------
--functions--------------------------------------------------------
function get_time return varchar2 ;
function init_all(
p_options BSC_IM_UTILS.varchar_tabletype,
p_number_options number) return boolean;
--procedures-------------------------------------------------------
procedure write_to_log_file(p_message varchar2);
procedure write_to_log_file_n(p_message varchar2);
procedure write_to_debug_n(p_message varchar2);
procedure write_to_debug(p_message varchar2);
-------------------------------------------------------------------
procedure drop_tmp_col_type_table; --bug 3878968
--bug 3899523
function create_tmp_col_type_table(p_error_message out nocopy varchar2) return boolean;
END BSC_OLAP_MAIN;

 

/
