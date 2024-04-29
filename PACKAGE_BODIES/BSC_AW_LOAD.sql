--------------------------------------------------------
--  DDL for Package Body BSC_AW_LOAD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_AW_LOAD" AS
/*$Header: BSCAWLOB.pls 120.7 2006/04/20 11:27 vsurendr noship $*/
/*
the top package to handle all AW data loads, aggregations and forecasts
handles dim loads and kpi loads
*/

/*
load dim handles aw dim loads. input to this procedure is a list of dim and options
*/
procedure load_dim(
p_dim_level_list dbms_sql.varchar2_table,
p_options varchar2
) is
Begin
  bsc_aw_utility.g_options.delete;
  bsc_aw_utility.parse_parameter_values(p_options,',',bsc_aw_utility.g_options);
  bsc_aw_utility.open_file('TEST');
  bsc_aw_utility.dmp_g_options(bsc_aw_utility.g_options);
  init_all;
  bsc_aw_adapter.upgrade(p_options);/*serial across all processes. we call upgrade(p_options) to invoke workspace attach in that api*/
  bsc_aw_load_dim.load_dim(p_dim_level_list);
  bsc_aw_management.detach_workspace;
Exception when others then
  bsc_aw_management.detach_workspace;
  rollback;
  log_n('Exception in load_dim '||sqlerrm);
  raise;
End;

/*
the aw dim corresponding to the level being purged is completely cleaned up, not just the level. if city is to
be purged, geog dim and all its levels will be purged.

NOTE!!! when dim is purged, all related kpi are completely purged. if a dim is to be removed from a kpi, the kpi has
to be recreated. so if a dim is purged, data in the kpi makes no sense anymore
*/
procedure purge_dim(
p_dim_level_list dbms_sql.varchar2_table,
p_options varchar2
) is
Begin
  bsc_aw_utility.g_options.delete;
  bsc_aw_utility.parse_parameter_values(p_options,',',bsc_aw_utility.g_options);
  bsc_aw_utility.open_file('TEST');
  bsc_aw_utility.dmp_g_options(bsc_aw_utility.g_options);
  init_all;
  bsc_aw_load_dim.purge_dim(p_dim_level_list);
  bsc_aw_management.detach_workspace;
Exception when others then
  bsc_aw_management.detach_workspace;
  rollback;
  log_n('Exception in purge_dim '||sqlerrm);
  raise;
End;

/*
this procedure will dmp the dim level data into table bsc_aw_dim_data
used for bis dimensions that are not materialized. bsc loader needs the dim values
to know which values have got deleted

this creates the program on the fly, executes it and drops the program
NO COMMIT!!!
*/
procedure dmp_dim_level_into_table(
p_dim_level_list dbms_sql.varchar2_table,
p_options varchar2
) is
Begin
  bsc_aw_utility.g_options.delete;
  bsc_aw_utility.parse_parameter_values(p_options,',',bsc_aw_utility.g_options);
  bsc_aw_utility.open_file('TEST');
  bsc_aw_utility.dmp_g_options(bsc_aw_utility.g_options);
  init_all;
  bsc_aw_management.get_workspace_lock('ro',null);
  bsc_aw_load_dim.dmp_dim_level_into_table(p_dim_level_list);
  bsc_aw_management.detach_workspace;
Exception when others then
  bsc_aw_management.detach_workspace;
  rollback;
  log_n('Exception in dmp_dim_level_into_table '||sqlerrm);
  raise;
End;

/*
for kpi, there are 2 ways to load
1 load a kpi
2 load base table and kpi associated with them
*/

procedure load_kpi(
p_kpi_list dbms_sql.varchar2_table,
p_options varchar2
) is
Begin
  bsc_aw_utility.g_options.delete;
  bsc_aw_utility.parse_parameter_values(p_options,',',bsc_aw_utility.g_options);
  bsc_aw_utility.open_file('TEST');
  bsc_aw_utility.dmp_g_options(bsc_aw_utility.g_options);
  init_all;
  bsc_aw_adapter.upgrade(p_options);/*serial across all processes*/
  bsc_aw_load_kpi.load_kpi(p_kpi_list);
  bsc_aw_management.detach_workspace;
Exception when others then
  bsc_aw_management.detach_workspace;
  rollback;
  log_n('Exception in load_kpi '||sqlerrm);
  raise;
End;

/*
p_base_table_list and p_kpi_list are 1 to 1. the entries can look as
BSC_B_1     3014
BSC_B_1     4000
BSC_B_2     3014
*/
procedure load_base_table(
p_base_table_list dbms_sql.varchar2_table,
p_kpi_list dbms_sql.varchar2_table,
p_options varchar2
) is
Begin
  bsc_aw_utility.g_options.delete;
  bsc_aw_utility.parse_parameter_values(p_options,',',bsc_aw_utility.g_options);
  bsc_aw_utility.open_file('TEST');
  bsc_aw_utility.dmp_g_options(bsc_aw_utility.g_options);
  init_all;
  bsc_aw_adapter.upgrade(p_options);/*serial across all processes*/
  bsc_aw_load_kpi.load_base_table(p_base_table_list,p_kpi_list);
  bsc_aw_management.detach_workspace;
Exception when others then
  bsc_aw_management.detach_workspace;
  rollback;
  log_n('Exception in load_base_table '||sqlerrm);
  raise;
End;

procedure purge_kpi(p_kpi varchar2,p_options varchar2) is
Begin
  bsc_aw_utility.g_options.delete;
  bsc_aw_utility.parse_parameter_values(p_options,',',bsc_aw_utility.g_options);
  bsc_aw_utility.open_file('TEST');
  bsc_aw_utility.dmp_g_options(bsc_aw_utility.g_options);
  init_all;
  bsc_aw_load_kpi.purge_kpi(p_kpi);
  bsc_aw_management.detach_workspace;
Exception when others then
  bsc_aw_management.detach_workspace;
  rollback;
  log_n('Exception in purge_kpi '||sqlerrm);
  raise;
End;

/*
pass a kpi. this will loop over all dimset, all dim and levels. it eill create tables
as p_table_name||dimset||1,2 etc. then these table names will be returned in p_tables
*/
procedure dmp_kpi_cubes_into_table(
p_kpi varchar2,
p_table_name varchar2,
p_options varchar2,
p_tables out nocopy dbms_sql.varchar2_table
) is
Begin
  bsc_aw_utility.g_options.delete;
  bsc_aw_utility.parse_parameter_values(p_options,',',bsc_aw_utility.g_options);
  bsc_aw_utility.open_file('TEST');
  bsc_aw_utility.dmp_g_options(bsc_aw_utility.g_options);
  init_all;
  --read lock only
  bsc_aw_management.get_workspace_lock('ro',null);
  bsc_aw_load_kpi.dmp_kpi_cubes_into_table(p_kpi,p_table_name,p_tables);
  bsc_aw_management.detach_workspace;
Exception when others then
  bsc_aw_management.detach_workspace;
  rollback;
  log_n('Exception in dmp_kpi_cubes_into_table '||sqlerrm);
  raise;
End;

procedure dmp_kpi_cubes_into_table(
p_kpi varchar2,
p_dimset varchar2,
p_dim_levels dbms_sql.varchar2_table,
p_table_name varchar2,
p_options varchar2) is
Begin
  bsc_aw_utility.g_options.delete;
  bsc_aw_utility.parse_parameter_values(p_options,',',bsc_aw_utility.g_options);
  bsc_aw_utility.open_file('TEST');
  bsc_aw_utility.dmp_g_options(bsc_aw_utility.g_options);
  init_all;
  --read lock only
  bsc_aw_management.get_workspace_lock('ro',null);
  bsc_aw_load_kpi.dmp_kpi_cubes_into_table(p_kpi,p_dimset,p_dim_levels,p_table_name);
  bsc_aw_management.detach_workspace;
Exception when others then
  bsc_aw_management.detach_workspace;
  rollback;
  log_n('Exception in dmp_kpi_cubes_into_table '||sqlerrm);
  raise;
End;

/*
for base table change vector management
we will handle inc load using the change vector column in the base table. we will not have the b_aw table anymore
we hold meradata on the latest change vector for a base table. to begin, its 0. when loader loads from I table,
calculates projections etc, it will load the value it gets from get_bt_next_change_vector into the change vector
...
init_bt_change_vector('BSC_B_1');
l_cv:=get_bt_next_change_vector('BSC_B_1');
...
load from I -> B
commit
...
projections
commit
...
update_bt_change_vector('BSC_B_1',l_cv);
commit;
truncate I table

init_bt_change_vector will create a metadata entry for B table if it does not exist
we cannot have a situation where change_vector column in B table is null
if the change vector in the B table > in the metadata, it is due to some loader failure before update_bt_change_vector
was called
when a B table is dropped by the MO, it needs to call drop_bt_change_vector
*/
procedure init_bt_change_vector(p_base_table varchar2) is
Begin
  bsc_aw_md_api.create_bt_change_vector(upper(p_base_table)); /*creates cv and current period */
Exception when others then
  log_n('Exception in init_bt_change_vector '||sqlerrm);
  raise;
End;

procedure drop_bt_change_vector(p_base_table varchar2) is
Begin
  bsc_aw_md_api.drop_bt_change_vector(upper(p_base_table)); /*drops cv and cp */
Exception when others then
  log_n('Exception in drop_bt_change_vector '||sqlerrm);
  raise;
End;

function get_bt_next_change_vector(p_base_table varchar2) return number is
l_value number;
Begin
  l_value:=bsc_aw_md_api.get_bt_change_vector(upper(p_base_table))+1;
  return l_value;
Exception when others then
  log_n('Exception in get_bt_next_change_vector '||sqlerrm);
  raise;
End;

--for base table change vector management
procedure update_bt_change_vector(p_base_table varchar2, p_value number) is
Begin
  bsc_aw_md_api.update_bt_change_vector(upper(p_base_table),p_value);
Exception when others then
  log_n('Exception in update_bt_change_vector '||sqlerrm);
  raise;
End;

/*to set the current period of the B table , p_value is period.year format at the periodicity of the B table
we need this value to set projection and balance aggregations on time to null when the cp moves forward*/
procedure update_bt_current_period(p_base_table varchar2,p_period number,p_year number) is
Begin
  bsc_aw_md_api.update_bt_current_period(upper(p_base_table),p_period||'.'||p_year);
Exception when others then
  log_n('Exception in update_bt_current_period '||sqlerrm);
  raise;
End;

--------------------------------------------------------
procedure init_all is
Begin
  if bsc_aw_utility.get_parameter_value(bsc_aw_utility.g_options,'DEBUG LOG')='Y'
  or bsc_aw_utility.g_log_level>=FND_LOG.G_CURRENT_RUNTIME_LEVEL then
    g_debug:=true;
  else
    g_debug:=false;
  end if;
  bsc_aw_utility.init_all(g_debug);
  bsc_aw_load_dim.init_all;
  bsc_aw_load_kpi.init_all;
  bsc_aw_dbms_aw.init_all;
  bsc_aw_md_api.init_all;
  bsc_aw_md_wrapper.init_all;
  bsc_aw_management.init_all;
Exception when others then
  log_n('Exception in init_all '||sqlerrm);
  raise;
End;

procedure log(p_message varchar2) is
Begin
  bsc_aw_utility.log(p_message);
Exception when others then
  null;
End;

procedure log_n(p_message varchar2) is
Begin
  log('  ');
  log(p_message);
Exception when others then
  null;
End;

END BSC_AW_LOAD;

/
