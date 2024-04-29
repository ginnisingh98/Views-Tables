--------------------------------------------------------
--  DDL for Package BSC_AW_CALENDAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_AW_CALENDAR" AUTHID CURRENT_USER AS
/*$Header: BSCAWCAS.pls 120.8 2006/01/30 15:54 vsurendr noship $*/
--program runtime parameters
g_debug boolean;
g_stmt varchar2(10000);
g_commands dbms_sql.varchar2_table;
g_init boolean;
---types-----------------------------------------------------------
type periodicity_r is record(
db_column_name varchar2(40),
periodicity_id number,
periodicity_type number,--of 9=day, =1 is year
source varchar2(400),
dim_name varchar2(400), --this is the name of the dim in AW
aw_time_dim_name varchar2(400), --this is the corresponding AW time dim like aw_day or aw_month
aw_bsc_aw_rel_name varchar2(400), --given bsc period value, what is the aw time value
aw_aw_bsc_rel_name varchar2(400), --given aw time value, what is the bsc time value
property varchar2(2000)
);
type periodicity_tb is table of periodicity_r index by pls_integer;
--
type parent_child_r is record(
parent number,
parent_dim_name varchar2(300),
child number,
child_dim_name varchar2(300)
);
type parent_child_tb is table of parent_child_r index by pls_integer;
--
type misc_r is record(
object_name varchar2(300),  --used for olap table function
object_type varchar2(100),
datatype varchar2(40)
);
type misc_tb is table of misc_r index by pls_integer;
--
/*
end_period_relation_name is 2 axis. X is periods like day,month etc. Y is level names
given a month on X and Y is "day", rel gives end period
SQL> ------------------------------------------------------BSC_DBI_ENT.REL_BALANCE-----------------------------------------
------------------------------------------------------------BSC_DBI_ENT--------------------------------------------------
BSC_DBI_ENT.LE <BSC_MONTH <BSC_MONTH <BSC_MONTH <BSC_MONTH <BSC_MONTH <BSC_MONTH <BSC_MONTH <BSC_MONTH <BSC_MONTH <BSC_MONTH
<BSC_MONTH <BSC_MONTH
VELS           : 1.2004>  : 2.2004>  : 3.2004>  : 4.2004>  : 5.2004>  : 6.2004>  : 7.2004>  : 8.2004>  : 9.2004>  : 10.2004> :
11.2004> : 12.2004>
-------------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ---------- ----------
---------- ----------
DAY            <BSC_DAY:  <BSC_DAY:  <BSC_DAY:  <BSC_DAY:  <BSC_DAY:  <BSC_DAY:  <BSC_DAY:  <BSC_DAY:  <BSC_DAY:  <BSC_DAY:
<BSC_DAY:  <BSC_DAY:
31.2004>   60.2004>   91.2004>   121.2004>  152.2004>  182.2004>  213.2004>  244.2004>  274.2004>  305.2004>  335.2004>  366.2004>

OR
QTR end periods as DAY
SQL> ----------BSC_DBI_ENT.REL_BALANCE----------
----------------BSC_DBI_ENT----------------
<BSC_QUART <BSC_QUART <BSC_QUART <BSC_QUART
BSC_DBI_ENT.LE    ER:        ER:        ER:        ER:
VELS            1.2004>    2.2004>    3.2004>    4.2004>
-------------- ---------- ---------- ---------- ----------
DAY            <BSC_DAY:  <BSC_DAY:  <BSC_DAY:  <BSC_DAY:
91.2004>   182.2004>  274.2004>  366.2004>

OR
QTR end period as MONTH
SQL> ----------BSC_DBI_ENT.REL_BALANCE----------
----------------BSC_DBI_ENT----------------
<BSC_QUART <BSC_QUART <BSC_QUART <BSC_QUART
BSC_DBI_ENT.LE    ER:        ER:        ER:        ER:
VELS            1.2004>    2.2004>    3.2004>    4.2004>
-------------- ---------- ---------- ---------- ----------
MONTH          <BSC_MONTH <BSC_MONTH <BSC_MONTH <BSC_MONTH
: 3.2004>  : 6.2004>  : 9.2004>  : 12.2004>


*/
type calendar_r is record(
calendar_id number,
property varchar2(1000),
periodicity periodicity_tb,
parent_child parent_child_tb,
dim_name varchar2(300),
relation_name varchar2(300),
denorm_relation_name varchar2(300), --used for balance aggregations during kpi load
levels_name varchar2(300), --this is parent.child format
end_period_relation_name varchar2(300),--this relation is used for balance measures
end_period_levels_name varchar2(300), --this is just the level names. also used for denorm relation
load_program varchar2(300),
kpi_for_dim bsc_aw_adapter_dim.kpi_for_dim_tb,
misc_object misc_tb
);
type calendar_tb is table of calendar_r index by pls_integer;
---variables--------------------------------------------------------
--procedures-------------------------------------------------------
procedure create_calendar(p_calendar number,p_options varchar2,p_affected_kpi out nocopy dbms_sql.varchar2_table);
procedure create_calendar_objects(
p_calendar in out nocopy calendar_r);
procedure create_calendar_program(
p_calendar in out nocopy calendar_r
);
function get_periodicity_dim_name(p_periodicity periodicity_tb, p_periodicity_id number) return varchar2;
procedure normalize_per_relation(p_calendar in out nocopy calendar_r);
procedure dmp_calendar(p_calendar calendar_r);
procedure create_calendar_metadata(p_calendar calendar_r);
procedure get_kpi_for_calendar(p_calendar in out nocopy calendar_r);
procedure set_calendar_properties(p_calendar in out nocopy calendar_r);
procedure attach_workspace(p_options varchar2);
procedure get_calendar_current_year(p_calendar number,p_year out nocopy number);
procedure load_calendar(p_calendar number,p_options varchar2);
procedure get_all_lower_periodicities(
p_periodicity periodicity_r,
p_calendar calendar_r,
p_lower_periodicities in out nocopy periodicity_tb
);
procedure get_child_periodicities(
p_periodicity periodicity_r,
p_calendar calendar_r,
p_lower_periodicities out nocopy periodicity_tb
);
function get_periodicity_r(
p_periodicity_id number,
p_periodicities periodicity_tb
) return periodicity_r;
procedure check_calendar_create(
p_calendar calendar_r,
p_recreate out nocopy varchar2,
p_affected_kpi out nocopy dbms_sql.varchar2_table);
procedure drop_calendar_objects(p_calendar_name varchar2,p_object_type varchar2,p_affected_kpi out nocopy dbms_sql.varchar2_table);
function get_calendar_name(p_calendar number) return varchar2 ;
procedure purge_calendar(p_calendar number,p_options varchar2) ;
procedure create_calendar(p_calendar number,p_affected_kpi out nocopy dbms_sql.varchar2_table);
function check_calendar_loaded(p_calendar number) return varchar2;
procedure load_calendar(p_calendar number);
procedure purge_calendar(p_calendar number);
procedure get_bsc_calendar_data(
p_calendar in out nocopy calendar_r);
procedure set_aw_object_names(p_calendar in out nocopy calendar_r);
procedure get_missing_periodicity(
p_calendar_dim varchar2,
p_periodicity_dim in out nocopy dbms_sql.varchar2_table,
p_lowest_level out nocopy dbms_sql.varchar2_table
);
function is_child_present(
p_parent varchar2,
p_periodicity_dim dbms_sql.varchar2_table,
p_parent_child parent_child_tb) return boolean;
procedure get_missing_level_down(
p_parent varchar2,
p_periodicity_dim dbms_sql.varchar2_table,
p_parent_child parent_child_tb,
p_missing_levels_in dbms_sql.varchar2_table,
p_missing_levels_out out nocopy dbms_sql.varchar2_table,
p_found in out nocopy boolean --indicates if child is found and its time to stop
);
procedure get_calendar_parent_child(p_calendar_dim varchar2,p_parent_child out nocopy parent_child_tb);
function is_parent_present(
p_child varchar2,
p_periodicity_dim dbms_sql.varchar2_table,
p_parent_child parent_child_tb) return boolean ;
procedure get_missing_level_up(
p_child varchar2,
p_periodicity_dim dbms_sql.varchar2_table,
p_parent_child parent_child_tb,
p_missing_levels_in dbms_sql.varchar2_table,
p_missing_levels_out out nocopy dbms_sql.varchar2_table,
p_found in out nocopy boolean --indicates if child is found and its time to stop
) ;
procedure lock_calendar_objects(p_calendar number);
procedure get_calendar_objects_to_lock(p_calendar number,p_lock_objects out nocopy dbms_sql.varchar2_table);
procedure correct_calendar(p_calendar calendar_r,p_recreate out nocopy varchar2);
procedure create_calendar(p_calendar number,p_options varchar2);
function compare_pc_relations(p_pc_1 parent_child_tb,p_pc_2 parent_child_tb) return number;
procedure get_parent_periodicities(
p_periodicity periodicity_r,
p_calendar calendar_r,
p_upper_periodicities out nocopy periodicity_tb
);
procedure get_all_upper_periodicities(
p_periodicity periodicity_r,
p_calendar calendar_r,
p_upper_periodicities in out nocopy periodicity_tb
);
procedure get_calendar_periodicities(p_calendar_dim varchar2,p_periodicity out nocopy periodicity_tb);
procedure get_calendar(p_calendar_name varchar2,p_calendar out nocopy calendar_r);
procedure upgrade(p_new_version number,p_old_version number);
procedure reimplement_all_calendars;
procedure reimplement_calendar(p_calendar_id number);
--procedures-------------------------------------------------------
procedure init_all;
procedure log(p_message varchar2);
procedure log_n(p_message varchar2);
-------------------------------------------------------------------

END BSC_AW_CALENDAR;

 

/
