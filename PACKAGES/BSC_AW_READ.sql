--------------------------------------------------------
--  DDL for Package BSC_AW_READ
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_AW_READ" AUTHID CURRENT_USER AS
/*$Header: BSCAWRDS.pls 120.13.12000000.3 2007/07/02 08:55:12 rkumar ship $*/
--program runtime parameters
g_debug boolean;
g_apps_owner varchar2(200);
g_bsc_owner varchar2(200);
g_workspace_attached boolean; --is the workspace attached
g_init boolean;
g_stmt varchar2(4000);
g_std_dim dbms_sql.varchar2_table;
g_log_type varchar2(20);--file log or fnd log
--------types-------------------------
/*
given a level name , quickly get the dim name and the position. if this is empty, then we will have to query
from bsc olap metadata
*/
type level_dim_r is record(
level_name varchar2(300),
dim_name varchar2(300),
level_name_dim varchar2(300),
relation_name varchar2(300),
agg_map varchar2(300), --dim agg map
zero_level varchar2(300),
rec_parent_level varchar2(300),
position number,
aggregated varchar2(10), --Y or N is data aggregated to this level
zero_aggregated varchar2(10) --Y or N
);
type level_dim_tv is table of level_dim_r index by varchar2(100);
--
type child_level_r is record(
child_level dbms_sql.varchar2_table,
rel_level_name dbms_sql.varchar2_table --holds 'parent.child' that will be used to limit the level name dim
);
type child_level_tv is table of child_level_r index by varchar2(100);
--
--indexed by periodicity id
type periodicity_r is record(
aw_dim varchar2(300),
aggregated varchar2(10),
current_period varchar2(40),
calendar_aw_dim varchar2(300)
);
type periodicity_tv is table of periodicity_r index by varchar2(100);
--
type calendar_r is record(
aw_dim varchar2(100),
periodicity periodicity_tv,
drill_down_levels child_level_tv
);
--
type measure_tv is table of bsc_aw_adapter_kpi.measure_r index by varchar2(100);
--
/*
this type is used to store limit values.
this will have dim and time
dim_type='DIMENSION' or 'PERIODICITY'
we will first load this and then use it to limit
*/
type limit_dim_r is record(
level_name varchar2(300),
dim_name varchar2(300),--can be null. null means limit the level but do not add the level to dim status..for zero code
dim_type varchar2(100),
value varchar2(500)
);
type limit_dim_tb is table of limit_dim_r index by pls_integer;
--
--this keeps track of the limits on the kpi
--this is stored as a table within a kpi. the last one is the latest limit
--will be used later to see if aggregation has already been done
--and if so, no need to re-aggregate etc. now, its only used to limit
type limit_track_r is record(
seq_no number,
limit_dim limit_dim_tb
);
type limit_track_tb is table of limit_track_r index by pls_integer;
--
/*
drill_down_levels: given a level, this stores what are the levels to drill down to do the online agg
drill_down_levels will store only those levels that are required so we can limit level_name_dim
consider
      4
  2      3
       2-    1
we have these levels with the positions indicated. if adv sum profile is 2 then we only store
"3". this is because given "4" in the query, we will limit level name dim to 4 and then add "3".
then we say drill down dim to children using relation. this will get the status to 2, 3 and then 2-, 1

this is no more true. with the enhancement for handling diamond hierarchies, we have changed level name dim
to hold 'parent.child' as the hier, not just 'parent'
this means, we store in drill down levels '4.2', '4.3', '3.2-'

the local dim_set_r is a container for bsc_aw_adapter_kpi.dim_set_r. we have it so that we can have
levels level_dim_tv and drill_down_levels child_level_tv inside the dimset

the index for dim_set_tv is the dim set id. not the olap metadata dim set name. when ui calls the package,
it will pass kpi and dim set id. so with this info, we need to looup metadata from levels,drill_down_levels

dim_set_id is simply a collection of dimsets so that we can loop through it to see the various dimsets we have
in the kpi. for example, to dmp the kpi info

levels will have
multi level dim
single level dim
std dim
rec dim
we need level_names so we can find out the missing levels
*/
type dim_set_r is record(
level_names dbms_sql.varchar2_table, --all the levels
levels level_dim_tv,
drill_down_levels child_level_tv,
calendar calendar_r,
measure measure_tv,
dim_set bsc_aw_adapter_kpi.dim_set_r,
limit_track limit_track_tb
);
type dim_set_tv is table of dim_set_r index by varchar2(100);
--
type property_r is record(
last_update_date date
);
--
type kpi_r is record(
kpi varchar2(100),
status varchar2(40),
dim_set dim_set_tv,
dim_set_id dbms_sql.varchar2_table,
property property_r
);
type kpi_tv is table of kpi_r index by varchar2(100);

---------globals----------------------------------------
g_kpi kpi_tv;

--procedures-------------------------------------------------------
procedure init_filters(
p_user_name varchar2,
p_user_id number,
p_resp_name varchar2,
p_resp_id number
);
procedure limit_dimensions(
p_kpi varchar2,
p_dim_set varchar2,
p_parameters BIS_PMV_PAGE_PARAMETER_TBL
);
procedure load_kpi_metadata(p_kpi varchar2);
procedure load_level_lookup(p_dim_set in out nocopy dim_set_r);
procedure load_level_lookup(
p_dim bsc_aw_adapter_kpi.dim_r,
p_dim_set in out nocopy dim_set_r
);
procedure load_periodicity_lookup(p_kpi kpi_r,p_dim_set in out nocopy dim_set_r);
procedure load_level_drilldown(p_dim_set in out nocopy dim_set_r);
procedure get_child_level(
p_level varchar2,
p_level_dim level_dim_tv,
p_parent_child bsc_aw_adapter_kpi.parent_child_tb,
p_child_levels in out nocopy dbms_sql.varchar2_table,
p_rel_level_name in out nocopy dbms_sql.varchar2_table
);
procedure load_measures(p_dim_set in out nocopy dim_set_r);
procedure find_dimset_dimensions(
p_dim_set in out nocopy dim_set_r,
p_parameters BIS_PMV_PAGE_PARAMETER_TBL
);
procedure aggregate_dimset_dimensions(
p_dim_set dim_set_r,
p_parameters BIS_PMV_PAGE_PARAMETER_TBL
);
procedure aggregate_cubes_dim(
p_dim_set dim_set_r,
p_measures dbms_sql.varchar2_table,
p_dim varchar2
);
function check_kpi(p_kpi varchar2) return boolean ;
procedure get_measures(
p_parameters BIS_PMV_PAGE_PARAMETER_TBL,
p_measures out nocopy dbms_sql.varchar2_table
);
procedure check_limit_track_seq(
p_dim_set in out nocopy dim_set_r,
p_parameters BIS_PMV_PAGE_PARAMETER_TBL,
p_status out nocopy varchar2
);
procedure limit_dimset(
p_dim_set dim_set_r,
p_parameters BIS_PMV_PAGE_PARAMETER_TBL
);
procedure find_dimset_xtd(
p_dim_set in out nocopy dim_set_r,
p_parameters BIS_PMV_PAGE_PARAMETER_TBL
);
procedure dmp_kpi(p_kpi kpi_r);
procedure dmp_dimset(p_dimset dim_set_r);
procedure dmp_level_dim_r(p_level level_dim_r);
procedure dmp_periodicity_r(p_periodicity periodicity_r);
procedure limit_dim_to_composite(
p_dim_set dim_set_r,
p_parameters BIS_PMV_PAGE_PARAMETER_TBL
);
function is_zero_specified_for_level(p_dim_set dim_set_r,p_level_name varchar2) return boolean;
procedure limit_dimensions_pmv(
p_kpi varchar2,
p_dim_set varchar2,
p_parameters BIS_PMV_PAGE_PARAMETER_TBL
);
procedure attach_workspace;
procedure dmp_parameters(p_parameters BIS_PMV_PAGE_PARAMETER_TBL);
procedure set_viewby_dimensions(
p_dim_set in out nocopy dim_set_r,
p_parameters BIS_PMV_PAGE_PARAMETER_TBL,
p_limit_track in out nocopy limit_track_r
);
procedure detach_workspace;
procedure clear_all_cache;
function check_kpi_change(p_kpi varchar2) return boolean;
function find_agg_status(p_dim_set dim_set_r) return varchar2;
procedure load_periodicity_drilldown(p_dim_set in out nocopy dim_set_r) ;
procedure get_child_periodicity(p_periodicity varchar2,p_cal_periodicity periodicity_tv,p_parent_child bsc_aw_adapter_kpi.cal_parent_child_tb,
p_child_levels in out nocopy dbms_sql.varchar2_table,p_rel_level_name in out nocopy dbms_sql.varchar2_table);
procedure aggregate_cubes(p_dim_set dim_set_r,p_std_measures dbms_sql.varchar2_table,p_agg_map varchar2);
procedure correct_forecast(p_dim_set dim_set_r,p_measures dbms_sql.varchar2_table,p_periodicity dbms_sql.varchar2_table);
procedure aggregate_cubes_calendar(p_dim_set dim_set_r,p_measures dbms_sql.varchar2_table);
procedure get_measures_aggregate(p_dim_set dim_set_r,p_measures dbms_sql.varchar2_table,p_agg_measures out nocopy dbms_sql.varchar2_table);
procedure copy_data_display_cubes(p_dim_set dim_set_r,p_parameters BIS_PMV_PAGE_PARAMETER_TBL);
procedure copy_data_display_cubes(p_dim_set dim_set_r,p_measures dbms_sql.varchar2_table);
procedure copy_data_display_cubes(p_dim_set dim_set_r,p_cube varchar2,p_display_cube varchar2);
procedure aggregate_formula(p_dim_set dim_set_r,p_measures dbms_sql.varchar2_table);
procedure add_relevant_measures(p_dim_set dim_set_r,p_parameters in out nocopy BIS_PMV_PAGE_PARAMETER_TBL);
--procedures-------------------------------------------------------
procedure init_all;
procedure log(p_message varchar2);
procedure log_n(p_message varchar2);
-------------------------------------------------------------------
--rkumar:bug#5954342
procedure validate_limit_range(p_lower_period in out nocopy varchar2,p_upper_period in out nocopy varchar2, p_parameters  BIS_PMV_PAGE_PARAMETER_TBL);
END BSC_AW_READ;

 

/
