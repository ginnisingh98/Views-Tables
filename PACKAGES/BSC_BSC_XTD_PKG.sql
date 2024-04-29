--------------------------------------------------------
--  DDL for Package BSC_BSC_XTD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_BSC_XTD_PKG" AUTHID CURRENT_USER AS
/*$Header: BSCRPTCS.pls 120.3 2006/02/14 11:55:28 vsurendr noship $*/
--program runtime parameters
Type varchar_tabletype is Table of varchar2(800) index by binary_integer;
Type number_tabletype is Table of number index by binary_integer;
Type boolean_tabletype is Table of boolean index by binary_integer;
Type date_tabletype is Table of date index by binary_integer;
--------
--support for rolling periods
g_roll_year_range number:=365;
g_roll_qtr_range number:=90;
g_roll_period_range number:=30;
g_roll_week_range number:=7;
g_exception exception;
--------

type xtd_record is record(
session_id number,
kpi number,
report_date date,
xtd_periodicity number);
type xtd_record_table is table of xtd_record;
--------
g_kpi_xtd xtd_record_table;--keeps track of what is already in bsc_rpt_cal_keys
g_num_kpi_xtd number:=0;
g_session_id number;
g_debug boolean;
g_status number;
g_status_message varchar2(4000);
g_file boolean;
g_options BSC_IM_UTILS.varchar_tabletype;
g_number_options number;
g_bsc_owner varchar2(40);--schema
g_fnd_owner varchar2(40);--schema
g_option_string varchar2(20000);
-------------------------------------------------
procedure open_file;
procedure populate_rpt_keys(
p_table_name varchar2,
p_session_id number,
p_kpi number,
p_report_date varchar2,
p_xtd_period varchar2,
p_xtd_year varchar2,
p_xtd_periodicity number,
p_option_string varchar2,
p_error_message out nocopy varchar2
);
procedure populate_rpt_keys(
p_table_name varchar2,
p_session_id number,
p_kpi number,
p_report_date varchar2,
p_xtd_period varchar2,
p_xtd_year varchar2,
p_xtd_periodicity number,
p_xtd_type varchar2,--ROLLING vs XTD
p_option_string varchar2,
p_error_message out nocopy varchar2
);
function populate_rpt_keys(
p_table_name varchar2,--name of the rpt_cal_keys table
p_session_id number,
p_kpi number,
p_report_date date_tabletype,
p_num_report_date number,
p_xtd_period number_tabletype,--use p_num_report_date for count
p_xtd_year number_tabletype,--use p_num_report_date for count
p_xtd_periodicity number,
p_xtd_type varchar2
)return boolean;
function parse_values(
p_list varchar2,
p_separator varchar2,
p_names out nocopy number_tabletype,
p_number_names out nocopy number) return boolean;
function parse_values(
p_list varchar2,
p_separator varchar2,
p_names out nocopy varchar_tabletype,
p_number_names out nocopy number) return boolean;
function insert_rpt_cal_keys(
p_table_name varchar2,
p_report_date date,
p_report_date_insert date,--used to insert into bsc_rpt_keys table
p_xtd_periodicity number,
p_xtd_period number,
p_xtd_year number,
p_hier varchar2,
p_xtd_pattern number,
p_calendar_id number,
p_roll_flag varchar2,
p_periodicity_missing boolean,
p_period_periodicity number_tabletype,
p_period_missing boolean_tabletype,
p_num_pattern_period number
)return boolean;
function correct_rpt_cal_keys(
p_table_name varchar2,
p_report_date date,
p_xtd_periodicity number,
p_periodicity_missing number,
p_periodicity_present number,
p_calendar_id number,
p_roll_flag varchar2
)return boolean;
procedure delete_rpt_keys(
p_table_name varchar2,
p_session_id number,
p_error_message out nocopy varchar2
);
procedure create_rpt_key_table(
p_user_id number,
p_table_name out nocopy varchar2,
p_error_message out nocopy varchar2
);
procedure drop_rpt_key_table(
p_user_id number,
p_error_message out nocopy varchar2
);
procedure get_bsc_fnd_owner;
procedure init;
function get_day_count(
p_table_name varchar2,
p_session_id number,
p_report_date date,
p_roll_flag varchar2) return number;
procedure delete_table(
p_table_name varchar2,
p_session_id number,
p_report_date date,
p_roll_flag varchar2);
function populate_rolling_rpt_keys(
p_table_name varchar2,--name of the rpt_cal_keys table
p_session_id number,
p_hier varchar2,
p_xtd_pattern varchar2,
p_calendar_id number,
p_report_date date_tabletype,
p_num_report_date number,
p_xtd_period number_tabletype,--use p_num_report_date for count
p_xtd_year number_tabletype,--use p_num_report_date for count
p_xtd_periodicity number,
p_periodicity number_tabletype,
p_period_num_of_periods number_tabletype,
p_num_periodicity number,
--
p_periodicity_missing boolean,
p_period_periodicity number_tabletype,
p_period_missing boolean_tabletype,
p_num_pattern_period number
)return boolean ;
procedure correct_rolling_data_92_91(
p_table_name varchar2);
procedure correct_rolling_data(
p_table_name varchar2,
p_session_id number,
p_xtd_report_date date,
p_rtd_report_date date,
p_xtd_periodicity number,
p_xtd_period number,
p_xtd_year number,
p_hier varchar2,
p_xtd_pattern number,
p_calendar_id number,
p_periodicity_missing boolean,
p_period_periodicity number_tabletype,
p_period_missing boolean_tabletype,
p_num_pattern_period number
);
procedure populate_rpt_keys_daily(
p_table_name varchar2,--name of the rpt_cal_keys table
p_session_id number,
p_calendar_id number,
p_report_date date_tabletype,
p_num_report_date number,
p_xtd_period number_tabletype,--use p_num_report_date for count
p_xtd_year number_tabletype,--use p_num_report_date for count
p_xtd_periodicity number,
p_xtd_type varchar2
);
function is_daily_periodicity(p_periodicity number) return boolean ;
-------------------------------------------
function get_time return varchar2;
-------------------------------------------------

--TYPE clskeys IS RECORD (  keysRow BSC_RPT_KEYS%ROWTYPE);
TYPE tab_clsKeys IS TABLE of BSC_RPT_KEYS%ROWTYPE INDEX BY BINARY_INTEGER;

gKeysTable tab_clsKeys;

END BSC_BSC_XTD_PKG;

 

/
