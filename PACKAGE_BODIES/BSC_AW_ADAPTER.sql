--------------------------------------------------------
--  DDL for Package Body BSC_AW_ADAPTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_AW_ADAPTER" AS
/*$Header: BSCAWAPB.pls 120.14 2006/04/20 11:49 vsurendr noship $*/

/*
implement_kpi_aw is the top procedure. optimizer calls this api, passes a list of kpi to be implemented
in aw. also is passed options like debug log or any other parameter

p_options:
RECREATE DIM : will recreate dim except std dim
RECREATE STD DIM : will recreate std dim
RECREATE KPI : will recreate kpi
DEBUG LOG : turns on logging
TABLESPACE : which tablespace to create aw workspace
SEGMENTSIZE : segment size to use
*/
procedure implement_kpi_aw(
p_kpi_list dbms_sql.varchar2_table,
p_options varchar2
) is
--
l_affected_kpi dbms_sql.varchar2_table;
Begin
  implement_kpi_aw(p_kpi_list,p_options,l_affected_kpi);
Exception when others then
  log_n('Exception in implement_kpi_aw '||sqlerrm);
  raise;
End;

procedure implement_kpi_aw(
p_kpi_list dbms_sql.varchar2_table,
p_options varchar2,
p_affected_kpi out nocopy dbms_sql.varchar2_table
) is
l_options varchar2(8000);
Begin
  l_options:='create workspace,'||p_options;
  upgrade(l_options);
  set_up(l_options);
  bsc_aw_management.get_workspace_lock('rw',l_options);
  implement_kpi_aw(p_kpi_list,p_affected_kpi);
  bsc_aw_management.commit_aw;
  bsc_aw_md_api.analyze_md_tables;
  commit;
  bsc_aw_management.detach_workspace;
Exception when others then
  bsc_aw_management.detach_workspace;
  rollback;
  log_n('Exception in implement_kpi_aw '||sqlerrm);
  raise;
End;

procedure implement_kpi_aw(
p_kpi_list dbms_sql.varchar2_table,
p_affected_kpi out nocopy dbms_sql.varchar2_table
) is
--
l_dim_list dbms_sql.varchar2_table;
l_calendar number;
l_affected_kpi dbms_sql.varchar2_table;
l_calendar_processed dbms_sql.number_table;
Begin
  --drop the kpi that are going to be processed
  drop_kpi(p_kpi_list);
  --for the list of kpi, get the dim list...then call the dim adapter
  --l_dim_list will be the BSC dim levels
  bsc_aw_bsc_metadata.get_dims_for_kpis(p_kpi_list,l_dim_list);
  bsc_aw_adapter_dim.create_dim(l_dim_list,p_affected_kpi);
  --check to see if we need to create calendar
  --create calendar will only create if needed
  if bsc_aw_utility.g_debug then
    bsc_aw_calendar.g_debug:=true;
  end if;
  for i in 1..p_kpi_list.count loop
    bsc_metadata.get_kpi_calendar(p_kpi_list(i),l_calendar);
    l_affected_kpi.delete;
    if bsc_aw_utility.in_array(l_calendar_processed,l_calendar)=false then
      bsc_aw_calendar.create_calendar(l_calendar,l_affected_kpi);
      bsc_aw_utility.merge_array(p_affected_kpi,l_affected_kpi);
      l_calendar_processed(l_calendar_processed.count+1):=l_calendar;
    end if;
  end loop;
  --
  bsc_aw_adapter_kpi.create_kpi(p_kpi_list);
  bsc_aw_utility.subtract_array(p_affected_kpi,p_kpi_list);
  bsc_aw_utility.dmp_values(p_affected_kpi,'Affected KPIs');
Exception when others then
  rollback;
  log_n('Exception in implement_kpi_aw '||sqlerrm);
  raise;
End;

/*
this procedure drops the kpi objects from aw, relational and also cleans up the olap metadata
should not error if the kpi does not exist
when we drop kpi, we must also process the dim. we can have a case like
city,state, country. one kpi on all three. this kpi is dropped. we have to correct the existing dim to city
state. if the kpi is dropped and we do not correct the dim, we can have issues later when country is deleted.
*/
procedure drop_kpi(p_kpi_list dbms_sql.varchar2_table,p_options varchar2) is
--
l_dim_list dbms_sql.varchar2_table;
Begin
  set_up(p_options);
  bsc_aw_management.get_workspace_lock('rw',p_options);
  bsc_aw_bsc_metadata.get_dims_for_kpis(p_kpi_list,l_dim_list);
  bsc_aw_adapter_dim.create_dim(l_dim_list);
  drop_kpi(p_kpi_list);
  bsc_aw_management.commit_aw;
  bsc_aw_management.detach_workspace;
  commit;
Exception when others then
  bsc_aw_management.detach_workspace;
  rollback;
  log_n('Exception in drop_kpi '||sqlerrm);
  raise;
End;

procedure drop_kpi(p_kpi_list dbms_sql.varchar2_table) is
Begin
  for i in 1..p_kpi_list.count loop
    bsc_aw_adapter_kpi.drop_kpi_objects(p_kpi_list(i));
  end loop;
Exception when others then
  log_n('Exception in drop_kpi '||sqlerrm);
  raise;
End;

/*
this procedure lets anyone create a dim or recreate a dim
*/
procedure create_dim(
p_dim_level_list dbms_sql.varchar2_table,
p_options varchar2
) is
l_options varchar2(8000);
Begin
  l_options:='create workspace,'||p_options;
  upgrade(l_options);
  set_up(l_options);
  bsc_aw_management.get_workspace_lock('rw',l_options);
  bsc_aw_adapter_dim.create_dim(p_dim_level_list);
  bsc_aw_management.commit_aw;
  commit;
  bsc_aw_management.detach_workspace;
Exception when others then
  bsc_aw_management.detach_workspace;
  rollback;
  log_n('Exception in create_dim '||sqlerrm);
  raise;
End;

/*handles cal, dim and kpi upgrade
process is serial
must be careful with cache. once the upgrade version is updated back in the system, then only must other process read
olap metadata*/
procedure upgrade(p_options varchar2) is  /*call from upgrade script etc */
l_old_upgrade_version number;
Begin
  bsc_aw_utility.get_db_lock('bsc_aw_system_upgrade');
  set_up(p_options);
  bsc_aw_md_api.clear_all_cache;
  l_old_upgrade_version:=bsc_aw_md_api.get_upgrade_version;
  log('System Upgrade, New version='||bsc_aw_utility.g_upgrade_version||', Old version='||l_old_upgrade_version);
  if bsc_aw_utility.g_upgrade_version>l_old_upgrade_version then
    bsc_aw_management.get_workspace_lock('rw',p_options);
    upgrade(bsc_aw_utility.g_upgrade_version,l_old_upgrade_version);
    bsc_aw_management.commit_aw;
    commit;
    bsc_aw_management.detach_workspace;
  end if;
  bsc_aw_utility.release_db_lock('bsc_aw_system_upgrade');
Exception when others then
  rollback;
  bsc_aw_utility.release_db_lock('bsc_aw_system_upgrade');
  bsc_aw_management.detach_workspace;
  log_n('Exception in upgrade '||sqlerrm);
  raise;
End;

procedure upgrade(p_new_version number,p_old_version number) is
Begin
  /*cal upgrade*/
  bsc_aw_calendar.upgrade(p_new_version,p_old_version);
  /*dim upgrade*/
  bsc_aw_adapter_dim.upgrade(p_new_version,p_old_version);
  /*kpi upgrade*/
  bsc_aw_adapter_kpi.upgrade(p_new_version,p_old_version);
  /*update the latest upgrade version */
  bsc_aw_md_api.set_upgrade_version(p_new_version);
Exception when others then
  log_n('Exception in upgrade '||sqlerrm);
  raise;
End;

--------------------------------------------

procedure set_up(p_options varchar2) is
Begin
  bsc_aw_utility.open_file('TEST');
  bsc_aw_utility.g_options.delete;
  bsc_aw_utility.parse_parameter_values(p_options,',',bsc_aw_utility.g_options);
  bsc_aw_utility.dmp_g_options(bsc_aw_utility.g_options);
  init_all;
Exception when others then
  rollback;
  log_n('Exception in set_up '||sqlerrm);
  raise;
End;

procedure init_all is
Begin
  --set g_adv_sum_profile
    g_adv_sum_profile:=0;
    /*serialize entry here */
    bsc_aw_utility.get_db_lock('bsc_aw_table_create_lock');
    bsc_aw_utility.create_temp_tables;
    bsc_aw_utility.create_perm_tables;
    bsc_aw_utility.release_db_lock('bsc_aw_table_create_lock');
    /* */
    if bsc_aw_utility.get_parameter_value(bsc_aw_utility.g_options,'DEBUG LOG')='Y'
    or bsc_aw_utility.g_log_level>=FND_LOG.G_CURRENT_RUNTIME_LEVEL then
      g_debug:=true;
    else
      g_debug:=false;
    end if;
    /* */
    bsc_aw_utility.init_all(g_debug);
    bsc_aw_adapter_dim.init_all;
    bsc_aw_adapter_kpi.init_all;
    bsc_aw_load_dim.init_all;
    bsc_aw_load_kpi.init_all;
    bsc_aw_dbms_aw.init_all;
    bsc_aw_md_api.init_all;
    bsc_aw_md_wrapper.init_all;
    bsc_aw_bsc_metadata.init_all;
    bsc_metadata.init_all;
    bsc_aw_management.init_all;
    g_init:=true;
Exception when others then
  rollback;
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

END BSC_AW_ADAPTER;

/
