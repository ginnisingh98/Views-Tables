--------------------------------------------------------
--  DDL for Package BSC_DBI_CALENDAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_DBI_CALENDAR" AUTHID CURRENT_USER AS
/*$Header: BSCDBICS.pls 120.7 2005/11/30 16:47 vsurendr noship $*/
----
g_exception EXCEPTION;
g_debug boolean;
g_status_message varchar2(4000);
g_who number;
g_lang BSC_IM_UTILS.varchar_tabletype;
g_num_lang number;
g_src_lang varchar2(100);
----
g_options BSC_IM_UTILS.varchar_tabletype;
g_number_options number;
g_bsc_greg_fiscal_year number;
-----
g_db_cal_modified boolean;
--
g_init_mem boolean;
--
------records
type dbi_cal_record is record(
report_date date,
cal_day varchar2(40),
cal_month varchar2(40),
cal_year varchar2(40),
month_id varchar2(40),
ent_period_id varchar2(40),
week_id varchar2(40),
ent_week_id number,
row_num number,
ent_day number, --day 365
greg_day number, --day 365
p445_day number, --day 365,
start_date date,
end_date date
);
type dbi_cal_record_t is table of dbi_cal_record index by binary_integer;
g_dbi_cal_record dbi_cal_record_t;
g_num_dbi_cal_record number;
---------------ent---------------------------
---
type dbi_ent_period is record(
ent_period_id number,
ent_year_id number,
sequence number,
name varchar2(400),
start_date date,
end_date date
);
type dbi_ent_period_t is table of dbi_ent_period index by binary_integer;
g_dbi_ent_period dbi_ent_period_t;
g_num_dbi_ent_period number;
---
type dbi_ent_qtr is record(
ent_qtr_id number,
ent_year_id number,
sequence number,
name varchar2(400),
start_date date,
end_date date
);
type dbi_ent_qtr_t is table of dbi_ent_qtr index by binary_integer;
g_dbi_ent_qtr dbi_ent_qtr_t;
g_num_dbi_ent_qtr number;
---
type dbi_ent_year is record(
ent_year_id number,
sequence number,
name varchar2(400),
start_date date,
end_date date
);
type dbi_ent_year_t is table of dbi_ent_year index by binary_integer;
g_dbi_ent_year dbi_ent_year_t;
g_num_dbi_ent_year number;
---
------------------445----------------------------
type dbi_445_week is record(
week_id number,
year_id number,
sequence number,
name varchar2(400),
ent_week_id number,
ent_year_id number,
start_date date,
end_date date
);
type dbi_445_week_t is table of dbi_445_week index by binary_integer;
g_dbi_445_week dbi_445_week_t;
g_num_dbi_445_week number;
--3990678
g_ent_week dbi_445_week_t;--holds only the extra weeks at ent year boundary
g_num_ent_week number;
---
type dbi_445_p445 is record(
period445_id number,
year445_id number,
sequence number,
name varchar2(400),
start_date date,
end_date date
);
type dbi_445_p445_t is table of dbi_445_p445 index by binary_integer;
g_dbi_445_p445 dbi_445_p445_t;
g_num_dbi_445_p445 number;
---
type dbi_445_year is record(
year445_id number,
sequence number,
name varchar2(400),
start_date date,
end_date date
);
type dbi_445_year_t is table of dbi_445_year index by binary_integer;
g_dbi_445_year dbi_445_year_t;
g_num_dbi_445_year number;
---
---------------greg----------------------------
type dbi_greg_period is record(
month_id number,
year_id number,
sequence number,
name varchar2(400),
start_date date,
end_date date
);
type dbi_greg_period_t is table of dbi_greg_period index by binary_integer;
g_dbi_greg_period dbi_greg_period_t;
g_num_dbi_greg_period number;
---
type dbi_greg_qtr is record(
quarter_id number,
year_id number,
sequence number,
name varchar2(400),
start_date date,
end_date date
);
type dbi_greg_qtr_t is table of dbi_greg_qtr index by binary_integer;
g_dbi_greg_qtr dbi_greg_qtr_t;
g_num_dbi_greg_qtr number;
---
type dbi_greg_year is record(
year_id number,
sequence number,
name varchar2(400),
start_date date,
end_date date
);
type dbi_greg_year_t is table of dbi_greg_year index by binary_integer;
g_dbi_greg_year dbi_greg_year_t;
g_num_dbi_greg_year number;
----------
g_ent_cal_id number;
g_ent_fiscal_change number;
g_ent_start_date date;
g_ent_day_per_id number;
g_ent_week_per_id number;
g_ent_period_per_id number;
g_ent_qtr_per_id number;
g_ent_year_per_id number;
---
g_445_cal_id number;
g_445_fiscal_change number;
g_445_cal_short_name varchar2(100);
g_445_start_date date;
g_445_day_per_id number;
g_445_day_short_name varchar2(100);
g_445_week_per_id number;
g_445_week_short_name varchar2(100);
g_445_p445_per_id number;
g_445_p445_short_name varchar2(100);
g_445_year_per_id number;
g_445_year_short_name varchar2(100);
---
g_greg_cal_id number;
g_greg_fiscal_change number;
g_greg_cal_short_name varchar2(100);
g_greg_start_date date;
g_greg_day_per_id number;
g_greg_day_short_name varchar2(100);
g_greg_period_per_id number;
g_greg_period_short_name varchar2(100);
g_greg_qtr_per_id number;
g_greg_qtr_short_name varchar2(100);
g_greg_year_per_id number;
g_greg_year_short_name varchar2(100);
----------
-----------------------------------------------------------------
--PUBLIC
-----------------------------------------------------------------
procedure load_dbi_cal_into_bsc(
p_option_string varchar2,
p_error_message out nocopy varchar2
);
procedure load_dbi_cal_into_bsc(
Errbuf out nocopy varchar2,
Retcode out nocopy varchar2,
p_option_string varchar2
);
-----------------------------------------------------------------
--PRIVATE
-----------------------------------------------------------------
procedure load_dbi_cal_into_bsc_full;
procedure load_dbi_ent_cal;
procedure load_dbi_445_cal;
procedure load_dbi_greg_cal;
procedure delete_dbi_calendars;
procedure analyze_tables;
procedure init_all;
procedure write_to_log_file(p_message varchar2);
procedure write_to_log_file_n(p_message varchar2);
function get_time return varchar2;
function get_periodicity_nextval return number;
function get_calendar_nextval return number;
procedure init_cal_per_ids;
procedure load_fii_time_day_full;
procedure loadmem_ent_full;
procedure loadmem_445_full;
procedure loadmem_greg_full;
procedure load_dbi_ent_cal_data;
procedure load_dbi_445_cal_data;
procedure load_dbi_greg_cal_data;
function get_day365(
p_cal_start_date date,
p_this_date date
)return number;
procedure get_bsc_greg_fiscal_year;
procedure get_ent_cal_start_date(p_mode varchar2);
procedure get_445_cal_start_date(p_mode varchar2);
procedure get_greg_cal_start_date(p_mode varchar2);
procedure load_fii_time_day_inc;
procedure loadmem_ent_inc;
procedure loadmem_445_inc;
procedure loadmem_greg_inc;
procedure LOAD_DBI_CAL_INTO_BSC_INC;
function check_for_inc_refresh return number;
function get_bis_dim_long_name(p_dim varchar2, p_lang varchar2, p_source_lang out nocopy varchar2) return varchar2;
function get_lookup_value(p_lookup_type varchar2,
p_lookup_code varchar2,
p_lang varchar2,
p_source_lang out nocopy varchar2
) return varchar2;
function get_bsc_Periodicity(
p_time_level_name varchar2,
x_periodicity_id out nocopy number,
x_calendar_id out nocopy number,
x_message out nocopy varchar2
)return boolean;
--for PMV
procedure get_bsc_Periodicity_jdbc(
p_time_level_name varchar2,
x_periodicity_id out nocopy number,
x_calendar_id out nocopy number,
x_status out nocopy number,
x_message out nocopy varchar2
);
procedure load_dbi_cal_metadata(
p_error_message out nocopy varchar2
);
function is_dbi_cal_metadata_loaded return boolean;
procedure delete_dbi_calendar_metadata;
function check_for_dbi return boolean ;
procedure init_mem_values(p_mode varchar2);
procedure update_dbi_445_ent_week(
p_prev_fii_week varchar2,
p_prev_week number,
p_prev_year number);
procedure correct_ent_week(p_mode varchar2);
function get_dbi_445_year(p_prev_fii_week varchar2) return number ;
procedure dmp_g_dbi_cal_record;
procedure calculate_day365(p_mode varchar2,p_cal_id number) ;
procedure calculate_day365_445(p_mode varchar2);
--AW_INTEGRATION: New procedure
procedure load_dbi_calendars_into_aw;
procedure refresh_reporting_calendars(p_error_message out nocopy varchar2);
END BSC_DBI_CALENDAR;

 

/
