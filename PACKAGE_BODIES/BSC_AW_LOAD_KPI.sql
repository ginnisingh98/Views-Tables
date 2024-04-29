--------------------------------------------------------
--  DDL for Package Body BSC_AW_LOAD_KPI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_AW_LOAD_KPI" AS
/*$Header: BSCAWLKB.pls 120.24 2006/04/20 11:22 vsurendr noship $*/

/*
for kpi, there are 2 ways to load
1 load a kpi
2 load base table and kpi associated with them

in 10g, each kpi can run in parallel
    within each kpi, each dim set can run in parallel
10g:each kpi may be a separate conc process
*/

procedure load_kpi(
p_kpi_list dbms_sql.varchar2_table
) is
--
l_parallel boolean;
Begin
  --if 10g, we can launcg parallel jobs.
  l_parallel:=false;
  if bsc_aw_utility.can_launch_jobs(p_kpi_list.count)='Y' then
    l_parallel:=true;
  end if;
  if l_parallel=false then
    for i in 1..p_kpi_list.count loop
      load_kpi(p_kpi_list(i),null,null,null,null);
    end loop;
  else
    --start jobs and wait
    load_kpi_jobs(p_kpi_list,null);
  end if;
Exception when others then
  log_n('Exception in load_kpi '||sqlerrm);
  raise;
End;

--p_base_table_list : comma separated list of base tables
procedure load_kpi_jobs(p_kpi_list dbms_sql.varchar2_table,p_base_table_list varchar2) is
--
l_job_name varchar2(100);
l_process varchar2(8000);
l_job_status bsc_aw_utility.parallel_job_tb;
Begin
  bsc_aw_utility.clean_up_jobs('all');
  for i in 1..p_kpi_list.count loop
    l_job_name:='bsc_aw_load_kpi_'||bsc_aw_utility.get_dbms_time||'_'||i;
    l_process:='bsc_aw_load_kpi.load_kpi('''||p_kpi_list(i)||''','''||nvl(p_base_table_list,'null')||''','||i||','''||l_job_name||''','''||
    bsc_aw_utility.get_option_string||''');';
    bsc_aw_utility.start_job(l_job_name,i,l_process,null);
  end loop;
  bsc_aw_utility.wait_on_jobs(null,l_job_status);
  for i in 1..l_job_status.count loop
    if l_job_status(i).status='error' then
      raise bsc_aw_utility.g_exception;
    end if;
  end loop;
Exception when others then
  log_n('Exception in load_kpi_jobs '||sqlerrm);
  raise;
End;

/*
p_base_table_list and p_kpi_list are 1 to 1. the entries can look as
BSC_B_1     3014
BSC_B_1     4000
BSC_B_2     3014
in 10g, we can parallelize each B -> KPI load
*/
procedure load_base_table(
p_base_table_list dbms_sql.varchar2_table,
p_kpi_list dbms_sql.varchar2_table
) is
--
l_kpi_list dbms_sql.varchar2_table; --distinct list of kpi
--l_base_table_list dbms_sql.varchar2_table;--base tables in each kpi
l_parallel boolean;
Begin
  for i in 1..p_kpi_list.count loop
    if bsc_aw_utility.in_array(l_kpi_list,p_kpi_list(i))=false then
      l_kpi_list(l_kpi_list.count+1):=p_kpi_list(i);
    end if;
  end loop;
  l_parallel:=false;
  if bsc_aw_utility.can_launch_jobs(l_kpi_list.count)='Y' then
    l_parallel:=true;
  end if;
  --NOTE!!! >>> load_kpi loads and aggregates
  if l_parallel=false then
    for i in 1..l_kpi_list.count loop
      load_kpi(l_kpi_list(i),bsc_aw_utility.make_string_from_list(p_base_table_list),null,null,null);
    end loop;
  else
    load_kpi_jobs(p_kpi_list,bsc_aw_utility.make_string_from_list(p_base_table_list));
  end if;
Exception when others then
  log_n('Exception in load_base_table '||sqlerrm);
  raise;
End;

-------------private api--------------------------------------
/*
in 10g, this will be called as a dbms job (each kpi will be a conc process)
find out the dimsets for the kpi. each dim set in 10g can be loaded in parallel
dimsets can be parallelized using dbms jobs

in 10g, the aggregation of dimsets can be in parallel, and within each dimset, the agg of cubes
can be in parallel

we are going to follow this:
load all dimsets of the kpi.
then aggregate all dimsets

when loading base tables,
load all base tables for a kpi.
then aggregate all dimsets involved

aggregation is tricky. we have to aggregate actuals and related target dimsets together since the status
of limit cubes have to be kept in mind p_base_table_list is comma separated list of base tables

This is the single point of entry for both loading kpi and base tables
p_base_table_list can contain all the base tables. this means base tables of the kpi and not of the kpi
*/
procedure load_kpi(p_kpi varchar2,p_base_table_list varchar2,p_run_id number,p_job_name varchar2,p_options varchar2) is
l_dim_set dbms_sql.varchar2_table; --this is all the dimsets, actuals and targets
l_aggregate_dim_set dbms_sql.varchar2_table; --dimsets used in aggregation. (Targets eliminated)
l_oo_dimset bsc_aw_md_wrapper.bsc_olap_object_tb;
l_base_table_list dbms_sql.varchar2_table;
l_varchar_table dbms_sql.varchar2_table;--temp
--
l_parallel boolean;
l_aggregation aggregation_r;
l_dim_set_parallel dbms_sql.varchar2_table;
l_dim_set_r bsc_aw_adapter_kpi.dim_set_r;
l_pl_base_tables dbms_sql.varchar2_table;
Begin
  if p_run_id is not null then
    --this is a dbms job. we have to do the initializations since this is a new session
    bsc_aw_utility.g_options.delete;
    bsc_aw_utility.parse_parameter_values(p_options,',',bsc_aw_utility.g_options);
    bsc_aw_utility.open_file('Load_kpi_'||p_kpi||'_'||p_run_id);
    bsc_aw_utility.dmp_g_options(bsc_aw_utility.g_options);
    bsc_aw_utility.init_all_procedures;
  end if;
  log_n('load_kpi, p_kpi='||p_kpi||',p_base_table_list='||p_base_table_list||
  ', p_run_id='||p_run_id||', p_job_name='||p_job_name||', p_options='||p_options);
  --
  set_aggregation(p_kpi,l_aggregation);
  --if the calendar is not loaded, load it now
  load_calendar_if_needed(p_kpi);
  --get md info on all dimsets
  --l_aggregation has all the dimsets, actuals and targets
  if p_base_table_list is not null and p_base_table_list <> 'null' then --loading base tables
    bsc_aw_utility.parse_parameter_values(p_base_table_list,',',l_varchar_table);
    get_kpi_base_tables(p_kpi,l_varchar_table,l_base_table_list);
    --l_base_table_list contains base tables that belong to the kpi from "p_base_table_list"
    get_dimset_for_base_table(p_kpi,l_base_table_list,l_dim_set);
  else --loading kpi
    --!!! l_oo_dimset contains all the dimset, actuals and targets
    bsc_aw_md_api.get_kpi_dimset(p_kpi,l_oo_dimset);
    for i in 1..l_oo_dimset.count loop
      l_dim_set(l_dim_set.count+1):=l_oo_dimset(i).object;
    end loop;
  end if;
  if g_debug then
    log_n('Load and Aggregate the following dimsets');
    for i in 1..l_dim_set.count loop
      log(l_dim_set(i));
    end loop;
    if l_base_table_list.count>0 then
      log('With the following base tables');
      for i in 1..l_base_table_list.count loop
        log(l_base_table_list(i));
      end loop;
    end if;
  end if;
  --first, load dim if needed
  load_dim_if_needed(p_kpi,l_dim_set);
  --
  /*detach workspace . found an interesting issue. if a diff session updates and commits an object, then if the workspace is
  not detached and attached again, update to that object raises error. dim load touches the LB. then when we try to save
  these back in the load of the kpi, it raises an error
  this is true when we try to get lock resync on a cube. the error is that dependent dim also must be relocked because they
  have changed in the dim load. so best is to release the WS and reacquire the WS
  ideally, we should first save lock set, commit lock set, then detach and then lock the lock set back again. since at this point, there are no
  objects waiting to be saved or locked, we skip that step
  */
  bsc_aw_management.detach_workspace;
  /*need logic to handle load. if all dimsets are parallelized and each dimset has partitions, then too many jobs are launched
  logic:check dimsets for partitions. dimsets with partitions are launched serially. then the remaining dimsets are launched in
  parallel if possible */
  l_dim_set_parallel.delete;
  for i in 1..l_dim_set.count loop
    l_dim_set_r:=l_aggregation.dim_set(get_dim_set_index(l_aggregation,l_dim_set(i)));
    if l_dim_set_r.number_partitions>0 then
      if g_debug then
        log(l_dim_set(i)||' has partitions. Load run serially');
      end if;
      load_kpi_dimset(p_kpi,l_dim_set(i),l_base_table_list);/*if there are partitions for the dimset, launch them serially */
    else
      l_dim_set_parallel(l_dim_set_parallel.count+1):=l_dim_set(i);
    end if;
  end loop;
  l_parallel:=false;
  if l_dim_set_parallel.count>0 then
    if bsc_aw_utility.can_launch_jobs(l_dim_set_parallel.count)='Y' then
      l_parallel:=true;
    end if;
    --note>> if l_base_table_list is specified, l_dim_set_parallel will only be the dimsets which contain the base tabkes
    --as a src. this is done in get_dimset_for_base_table above
    /* */
    if l_parallel then
      l_pl_base_tables.delete;
      get_base_table_for_dimset(p_kpi,l_base_table_list,l_dim_set_parallel,l_pl_base_tables);
      /*l_pl_base_tables contains the B tables that belong to l_dim_set_parallel and belonging to l_base_table_list if l_base_table_list.count>0
      to be 100 percent accurate, we have to only pick B tables that have inc data. But to keep this simple, just look at total B table
      size*/
      if is_parallel_load(l_pl_base_tables,bsc_aw_utility.g_parallel_load_cutoff)=false then
        if g_debug then
          log('Due to insufficient load, Parallel load of dimsets made serial');
        end if;
        l_parallel:=false;
      end if;
    end if;
    if l_parallel=false then
      for i in 1..l_dim_set_parallel.count loop
        load_kpi_dimset(p_kpi,l_dim_set_parallel(i),l_base_table_list);
      end loop;
    else
      load_kpi_dimset_job(p_kpi,l_dim_set_parallel,l_base_table_list);
    end if;
  end if;
  /*must detach workspace
  ideally, we should first save lock set, commit lock set, then detach and then lock the lock set back again. since at this point, there are no
  objects waiting to be saved or locked, we skip that step*/
  bsc_aw_management.detach_workspace;
  --aggregate the dimsets
  --aggregate_kpi_dimset will only aggregate actual dimsets if there is a corresponding target also
  get_aggregate_dimsets(p_kpi,l_dim_set,l_aggregate_dim_set);
  if l_aggregate_dim_set.count>0 then
    if g_debug then
      log_n('Aggregate the following dimsets. After eliminating targets');
      for i in 1..l_aggregate_dim_set.count loop
        log(l_aggregate_dim_set(i));
      end loop;
    end if;
    --
    --now, we can aggregate these dimsets
    --aggregate_kpi_dimset handled targets. note: targets have already been loaded in load_kpi_dimset in the prev step...
    --reset_dim_limits also happens in aggregate_kpi_dimset
    --we will only try and aggregate the actuals. when aggregating the actuals, aggregate_kpi_dimset will also aggregate the
    --corresponding target dimset. this is why we pass l_aggregation. we must aggregate only the actuals here. the reason is that
    --if we try aggregating targets first, ahead of actuals, then when we aggregate the actuals, it will overwrite the target info
    --we aggregate all measures of the dimset. cost is in composite creation. so aggregating only the measures affected by the B tables
    --does not get better perf.
    /*to manage load better, if dimset has partitions, we launch them serially */
    l_dim_set_parallel.delete;
    for i in 1..l_aggregate_dim_set.count loop
      l_dim_set_r:=l_aggregation.dim_set(get_dim_set_index(l_aggregation,l_aggregate_dim_set(i)));
      if l_dim_set_r.number_partitions>0 then
        if g_debug then
          log(l_aggregate_dim_set(i)||' has partitions. Aggregation run serially');
        end if;
        aggregate_kpi_dimset(p_kpi,l_aggregate_dim_set(i),null,null,null);/*to aggregate in parallel on partitions or not is checked inside this api*/
      else
        l_dim_set_parallel(l_dim_set_parallel.count+1):=l_aggregate_dim_set(i);
      end if;
    end loop;
    l_parallel:=false;
    if l_dim_set_parallel.count>0 then
      if bsc_aw_utility.can_launch_jobs(l_dim_set_parallel.count)='Y' then
        l_parallel:=true;
      end if;
      /*check to see if there is sufficient load to warrant parallel load .
      earlier we had is_parallel_aggregate test here. we cannot do this. when we aggregate, 100 nodes can explode into 100000 nodes
      depending on the hier depths. this means we cannot disable parallel aggregation just because there are onlyu 100 nodes. load could
      bring in 100 nodes.the only time we can do is_parallel_aggregate test is for formula and target copy because the nodes are
      not increasing in these cases
      */
      if l_parallel=false then
        for i in 1..l_dim_set_parallel.count loop
          aggregate_kpi_dimset(p_kpi,l_dim_set_parallel(i),null,null,null);
        end loop;
      else
        aggregate_kpi_dimset_job(p_kpi,l_dim_set_parallel);
      end if;
    end if;
    if p_run_id is not null then
      bsc_aw_utility.send_pipe_message(p_job_name,'status=success');
      bsc_aw_management.detach_workspace;
    end if;
  else
    if g_debug then
      log('No dimsets to aggregate');
    end if;
  end if;
  commit;
Exception when others then
  log_n('Exception in load_kpi '||sqlerrm);
  if p_run_id is not null then
    bsc_aw_utility.send_pipe_message(p_job_name,'status=error,sqlcode='||sqlcode||',message='||sqlerrm);
    rollback;
    bsc_aw_management.detach_workspace;
  else
    raise;
  end if;
End;

/*
p_base_tables will be base tables belonging to the kpi
*/
procedure load_kpi_dimset_job(p_kpi varchar2,p_dimset_list dbms_sql.varchar2_table,p_base_tables dbms_sql.varchar2_table) is
--
l_job_name varchar2(100);
l_process varchar2(8000);
l_job_status bsc_aw_utility.parallel_job_tb;
Begin
  bsc_aw_utility.clean_up_jobs('all');
  for i in 1..p_dimset_list.count loop
    l_job_name:='bsc_aw_load_kpi_dimset_'||bsc_aw_utility.get_dbms_time||'_'||i;
    l_process:='bsc_aw_load_kpi.load_kpi_dimset('''||p_kpi||''','''||p_dimset_list(i)||''','''||
    nvl(bsc_aw_utility.make_string_from_list(p_base_tables),'null')||''','||i||','''||l_job_name||''','''||
    bsc_aw_utility.get_option_string||''');';
    bsc_aw_utility.start_job(l_job_name,i,l_process,null);
  end loop;
  bsc_aw_utility.wait_on_jobs(null,l_job_status);
  for i in 1..l_job_status.count loop
    if l_job_status(i).status='error' then
      raise bsc_aw_utility.g_exception;
    end if;
  end loop;
Exception when others then
  log_n('Exception in load_kpi_dimset_job '||sqlerrm);
  raise;
End;

--just a wrapper to call load_kpi_dimset as a job. we cannot pass dbms_sql.varchar2_table when launching a job
procedure load_kpi_dimset(p_kpi varchar2,p_dim_set varchar2,p_base_tables varchar2,
p_run_id number,p_job_name varchar2,p_options varchar2) is
--
l_base_tables dbms_sql.varchar2_table;
Begin
  if p_base_tables is not null and p_base_tables <> 'null' then
    bsc_aw_utility.parse_parameter_values(p_base_tables,',',l_base_tables);
  end if;
  if p_run_id is not null then
    --this is a dbms job. we have to do the initializations since this is a new session
    bsc_aw_utility.g_options.delete;
    bsc_aw_utility.parse_parameter_values(p_options,',',bsc_aw_utility.g_options);
    bsc_aw_utility.open_file('Load_KD_'||p_dim_set||'_'||p_run_id);
    bsc_aw_utility.dmp_g_options(bsc_aw_utility.g_options);
    bsc_aw_utility.init_all_procedures;
  end if;
  load_kpi_dimset(p_kpi,p_dim_set,l_base_tables);
  if p_run_id is not null then
    bsc_aw_utility.send_pipe_message(p_job_name,'status=success');
    bsc_aw_management.detach_workspace;
  end if;
  commit;
Exception when others then
  log_n('Exception in load_kpi_dimset '||sqlerrm);
  if p_run_id is not null then
    bsc_aw_utility.send_pipe_message(p_job_name,'status=error,sqlcode='||sqlcode||',message='||sqlerrm);
    rollback;
    bsc_aw_management.detach_workspace;
  else
    raise;
  end if;
End;

/*
given a dimset, find out the cubes and load them
also do the calculations like forecasts, aggregations etc

this will be called as a dbms job in 10g. commit happens here

logic:
find out the base tables.
if any of the base tables is full load, the whole dimset is full load. check the _aw tables for data.
if they have data, inc load. else check b table. if there are rows, then full load

Once a dimset has been loaded, we can aggregate the cubes in the dimset
--
base tables can also have corresponding prj tables. p_base_tables will not contain the prj tables. however, get_ds_bt_parameters will grab
the correspnding string that contains the prj table also. so for now, we are not adding the prj tables to p_base_tables or l_oor_dimsets
*/
procedure load_kpi_dimset(p_kpi varchar2,p_dim_set varchar2,p_base_tables dbms_sql.varchar2_table) is
--
l_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
l_load_type varchar2(40); --initial or inc
l_oor_dimsets bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
Begin
  --
  l_olap_object_relation.delete;
  --get the base tables l_olap_object_relation(i).object are the base tables
  bsc_aw_md_api.get_dimset_base_table(p_kpi,p_dim_set,'base table dim set',l_olap_object_relation);
  --if base tables are specified, filter out the un-needed dimsets
  --there must be atleast one base table belonging to any dimset
  if p_base_tables.count>0 then
    for i in 1..l_olap_object_relation.count loop
      if bsc_aw_utility.in_array(p_base_tables,l_olap_object_relation(i).object) then
        l_oor_dimsets(l_oor_dimsets.count+1):=l_olap_object_relation(i);
      end if;
    end loop;
  else
    l_oor_dimsets:=l_olap_object_relation;
  end if;
  load_kpi_dimset_base_table(l_oor_dimsets);
Exception when others then
  log_n('Exception in load_kpi_dimset '||sqlerrm);
  raise;
End;

/*
this is the atomic procedure. a table of olap relations are passed . this can be 2 types.
1. load of a kpi. im this case we will have
B1  dimset1     kpi1
B2  dimset1     kpi1
diff base tables for the same dimset and kpi

2. load of a baes table. in this case we will have
B1  dimset1     kpi1
or
B1  dimset2     kpi1
or
B1  dimset1     kpi2
the reason for the or is that in caes of base table loading, there will be only 1 entry in the table. each of them
can be run in parallel in 10g.

this api desiced inc vs full refresh
note: in this api, we load essentially one dimset for a kpi. it can be multiple base tables or single base table

here we call the aggregate marker program. this api is running in parallel for various dim sets in the same kpi. so
its ok to call the aggregate marker program since this program is processing each dim set. the same dimset cannot be loaded
at the same time by 2 diff sessions. we have lock_dimset_objects here.
*/
procedure load_kpi_dimset_base_table(
p_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb
) is
--
l_load_type varchar2(40); --initial or inc
l_dimset_oor bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
l_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
l_aggregate_marker_program varchar2(300);
l_load_program varchar2(300);
l_load_program_parallel varchar2(300);
--
l_kpi varchar2(300);
l_dimset varchar2(300);
--
l_pl_base_tables dbms_sql.varchar2_table;/*to check parallel load */
l_pl_change_vector dbms_sql.number_table;
l_min_value dbms_sql.number_table;
l_max_value dbms_sql.number_table;
l_bt_current_period dbms_sql.varchar2_table;
l_measures dbms_sql.varchar2_table;--to see if we can launch parallel jobs, we need the count of the no. of measures in the dimset
l_property varchar2(3000);
l_aggregation aggregation_r;
l_LB_resync_program varchar2(200);
parallel_flag varchar2(10);
--
Begin
  if g_debug then
    log_n('load_kpi_dimset_base_table ');
    log('Entries');
    for i in 1..p_olap_object_relation.count loop
      log('kpi='||p_olap_object_relation(i).parent_object||' base table='||p_olap_object_relation(i).object
      ||' objtype='||p_olap_object_relation(i).object_type||' reltype='||p_olap_object_relation(i).relation_type
      ||' dimset='||p_olap_object_relation(i).relation_object||' relobjtype='||p_olap_object_relation(i).relation_object_type);
    end loop;
    bsc_aw_utility.clean_stats('group.load_kpi_dimset_base_table');
    bsc_aw_utility.load_stats('Start Of Process. Load kpi dimset base table','group.load_kpi_dimset_base_table');
  end if;
  --note!! >> there is only 1 dimset in this api. there can be 1 or more base tables
  l_kpi:=p_olap_object_relation(1).parent_object;
  l_dimset:=p_olap_object_relation(1).relation_object;
  --
  set_aggregation(l_kpi,l_aggregation);
  --get lock
  lock_dimset_objects(l_kpi,l_dimset,null,null);
  --before we call the load programs, we will first run aggregate_marker_program. this will set the limit cubes to true
  --all the values that need to be re-aggregated because dim hierarchies changed
  l_dimset_oor.delete;
  l_aggregate_marker_program:=null;
  bsc_aw_md_api.get_bsc_olap_object_relation(l_dimset,'kpi dimension set',null,l_kpi,'kpi',l_dimset_oor);
  for i in 1..l_dimset_oor.count loop
    if l_dimset_oor(i).relation_type='aggregate marker program' then
      l_aggregate_marker_program:=l_dimset_oor(i).relation_object;
      exit;
    end if;
  end loop;
  if l_aggregate_marker_program is not null then
    bsc_aw_dbms_aw.execute('call '||l_aggregate_marker_program);
  end if;
  --
  --for each dim set, for each base table, see if inc or full. then
  --if there is initial for any of the baestables for the dimset, full refresh for the dim ste
  --a dimset is unique only in the context of a kpi. but since the kpi name is a part of the dimset, dimset name is unique
  for i in 1..p_olap_object_relation.count loop
    l_load_type:=check_load_type(p_olap_object_relation(i).property1);
    if l_load_type='initial' then
      exit;
    end if;
  end loop;
  --p_olap_object_relation(1).relation_object is the dimset. we assume only 1 dimset in this api
  l_load_program:=null;
  l_load_program_parallel:=null;
  for i in 1..l_dimset_oor.count loop
    if (l_load_type='initial' and l_dimset_oor(i).relation_type='dml program initial load') or
    (l_load_type='inc' and l_dimset_oor(i).relation_type='dml program inc load') then
      l_load_program:=l_dimset_oor(i).relation_object;
      exit;
    end if;
  end loop;
  for i in 1..l_dimset_oor.count loop
    if (l_load_type='initial' and l_dimset_oor(i).relation_type='dml program initial load parallel') or
    (l_load_type='inc' and l_dimset_oor(i).relation_type='dml program inc load parallel') then
      l_load_program_parallel:=l_dimset_oor(i).relation_object;
      exit;
    end if;
  end loop;
  --
  for i in 1..l_dimset_oor.count loop
    if l_dimset_oor(i).relation_type='LB resync program' then
      l_LB_resync_program:=l_dimset_oor(i).relation_object;
      exit;
    end if;
  end loop;
  --get base table change vector value  . insert a row into bsc_aw_temp_cv for each base table
  l_pl_base_tables.delete;
  l_pl_change_vector.delete;
  for i in 1..p_olap_object_relation.count loop
    l_min_value(i):=to_number(bsc_aw_utility.get_parameter_value(p_olap_object_relation(i).property1,'current change vector',','))+1;
    l_olap_object_relation.delete;
    bsc_aw_md_api.get_bsc_olap_object_relation(p_olap_object_relation(i).object,'base table',null,
    p_olap_object_relation(i).object,'base table',l_olap_object_relation);
    l_max_value(i):=null;
    l_bt_current_period(i):=null;
    for j in 1..l_olap_object_relation.count loop
      if l_olap_object_relation(j).relation_type='base table change vector' then
        l_max_value(i):=to_number(l_olap_object_relation(j).relation_object);
        if l_max_value(i) is not null and (l_min_value(i) is null or l_max_value(i)>=l_min_value(i)) then
          l_pl_base_tables(l_pl_base_tables.count+1):=p_olap_object_relation(i).object;
          l_pl_change_vector(l_pl_change_vector.count+1):=l_max_value(i);
        end if;
      elsif l_olap_object_relation(j).relation_type='base table current period' then
        l_bt_current_period(i):=l_olap_object_relation(j).relation_object;
      end if;
    end loop;
    if l_max_value(i) is null then
      log_n('Error!!! No change vector value found for base table '||p_olap_object_relation(i).object);
      raise bsc_aw_utility.g_exception;
    end if;
    if l_bt_current_period(i) is null then
      l_bt_current_period(i):='null';
    end if;
  end loop;
  /*
  to see if we can parallelize, we will take a count of the number of measures in the dimset.
  in 10g, we can parallelize load of measures if they have diff composites
  now, for 10g, we parallelize based on partitions
  */
  l_measures.delete;
  bsc_aw_md_api.get_relation_object(l_dimset_oor,'dim set measure',l_measures);
  parallel_flag:=can_launch_jobs(l_kpi,l_aggregation.dim_set(get_dim_set_index(l_aggregation,l_dimset)),l_measures);
  if parallel_flag='Y' then
    if l_pl_base_tables.count>0 then
      /*check to see if there is sufficient data load to go for parallel load. otherwise, serial load is faster */
      if is_parallel_load(l_pl_base_tables,l_pl_change_vector,bsc_aw_utility.g_parallel_load_cutoff)=false then
        if g_debug then
          log('Due to insufficient load Parallel load of cubes and partitions made serial');
        end if;
        parallel_flag:='N';
      end if;
    else
      if g_debug then
        log('There is no new B table data to load. Parallel load of cubes and partitions made serial');
      end if;
      parallel_flag:='N';
    end if;
  end if;
  if parallel_flag='Y' then
    load_kpi_dimset_base_table_job(l_kpi,l_dimset,p_olap_object_relation,l_dimset_oor,l_load_program_parallel,l_LB_resync_program,
    l_min_value,l_max_value,l_bt_current_period);
  else
    load_kpi_dimset_base_table(l_kpi,l_dimset,p_olap_object_relation,l_dimset_oor,l_load_program,
    l_min_value,l_max_value,l_bt_current_period);
  end if;
  --base table dimset combination for a change vector is unique
  --update the current change vector for a B table->dimset combination
  for i in 1..p_olap_object_relation.count loop
    l_property:=p_olap_object_relation(i).property1;
    bsc_aw_utility.update_property(l_property,'current change vector',to_char(l_max_value(i)),',');
    if l_bt_current_period(i) is not null and l_bt_current_period(i)<>'null' then
      bsc_aw_utility.update_property(l_property,'base table current period',l_bt_current_period(i),',');
    end if;
    bsc_aw_md_api.update_olap_object_relation(p_olap_object_relation(i).object,p_olap_object_relation(i).object_type,
    p_olap_object_relation(i).relation_type,p_olap_object_relation(i).parent_object,p_olap_object_relation(i).parent_object_type,
    'relation_object,relation_object_type',p_olap_object_relation(i).relation_object||','||p_olap_object_relation(i).relation_object_type,
    'property1',l_property);
  end loop;
  --
  bsc_aw_management.commit_aw;--release the dimset objects
  commit;
  if g_debug then
    bsc_aw_utility.load_stats('End Of Process. Load kpi dimset base table','group.load_kpi_dimset_base_table');
    bsc_aw_utility.print_stats('group.load_kpi_dimset_base_table');
  end if;
Exception when others then
  --lock release happens in an exxeption when the workspace is eventually detached and the session ends
  log_n('Exception in load_kpi_dimset_base_table '||sqlerrm);
  raise;
End;

/*
This procedure loads the base table dimset combination in single thread. this means it calls the dimset load
program and passes the base table as parameter
load_kpi_dimset_base_table_job on the other hand loads the measures in parallel
*/
procedure load_kpi_dimset_base_table(
p_kpi varchar2,
p_dimset varchar2,
p_base_table_dimset_oor bsc_aw_md_wrapper.bsc_olap_object_relation_tb, --to get baes table, dimset and bt measures
p_dimset_oor bsc_aw_md_wrapper.bsc_olap_object_relation_tb, --to get measures etc
p_load_program varchar2,
p_min_value dbms_sql.number_table,
p_max_value dbms_sql.number_table,
p_bt_current_period dbms_sql.varchar2_table /*null are indicated as 'null'. this has to be in sync with p_base_table_dimset_oor*/
) is
--
l_base_tables dbms_sql.varchar2_table;
l_bt_current_period dbms_sql.varchar2_table;
l_flag boolean;
l_ds_parameters dbms_sql.varchar2_table;
l_aggregation aggregation_r;
l_dim_set bsc_aw_adapter_kpi.dim_set_r;
--
l_cubes dbms_sql.varchar2_table;
l_measures dbms_sql.varchar2_table;
l_bt_measures dbms_sql.varchar2_table;
Begin
  l_flag:=false;
  for i in 1..p_base_table_dimset_oor.count loop
    if p_min_value(i)<=p_max_value(i) then
      insert_bsc_aw_temp_cv(p_min_value(i),p_max_value(i),upper(p_base_table_dimset_oor(i).object));
      l_flag:=true;
    end if;
  end loop;
  for i in 1..p_base_table_dimset_oor.count loop
    l_base_tables(l_base_tables.count+1):=upper(p_base_table_dimset_oor(i).object);
    l_bt_current_period(l_bt_current_period.count+1):=p_bt_current_period(i);
  end loop;
  set_aggregation(p_kpi,l_aggregation);
  l_dim_set:=l_aggregation.dim_set(get_dim_set_index(l_aggregation,p_dimset));
  for i in 1..p_base_table_dimset_oor.count loop
    l_bt_measures.delete;
    bsc_aw_utility.parse_parameter_values(bsc_aw_utility.get_parameter_value(p_base_table_dimset_oor(i).property1,'measures',','),'+',
    l_bt_measures);
    for j in 1..l_bt_measures.count loop
      bsc_aw_utility.merge_value(l_measures,l_bt_measures(j));
    end loop;
  end loop;
  for i in 1..p_dimset_oor.count loop
    if p_dimset_oor(i).relation_type='dim set measure' then
      if bsc_aw_utility.in_array(l_measures,p_dimset_oor(i).relation_object) then
        bsc_aw_utility.merge_value(l_cubes,bsc_aw_utility.get_parameter_value(p_dimset_oor(i).property1,'cube',','));
      end if;
    end if;
  end loop;
  /*see if we need to correct projection or bal values with a change to base table current period */
  check_bt_current_period_change(p_kpi,l_dim_set,l_cubes,l_measures,l_base_tables,l_bt_current_period,null);
  if l_flag then
    /*set the cal end period rel for balance aggregation in the kpi load programs*/
    limit_calendar_end_period_rel(l_dim_set.calendar);
    get_ds_BT_parameters(p_kpi,p_dimset,p_load_program,l_base_tables,l_ds_parameters);
    if g_debug then
      log('Before Load, Composite Counts');
      dmp_dimset_composite_count(l_dim_set);
    end if;
    for i in 1..l_ds_parameters.count loop
      bsc_aw_dbms_aw.execute('call '||p_load_program||'('''||l_ds_parameters(i)||''')');
    end loop;
    if g_debug then
      log('After Load, Composite Counts');
      dmp_dimset_composite_count(l_dim_set);
    end if;
    reset_calendar_end_period_rel(l_dim_set.calendar);
  end if;
Exception when others then
  log_n('Exception in load_kpi_dimset_base_table '||sqlerrm);
  raise;
End;

/*
In 10g, the cubes can be loaded in parallel in addition to being aggregated in parallel. this brings true parallelization
each cube has its own composite. if not loaded in parallel, load takes time as N composites are created at the load time
in parallel, these N composites can be created in parallel.
this procedure is a wrapper.
p_olap_object_relation contains 1 dimset but multiple base tables
for 10g, we now have datacubes and load/aggregate in parallel
*/
procedure load_kpi_dimset_base_table_job(
p_kpi varchar2,
p_dimset varchar2,
p_base_table_dimset_oor bsc_aw_md_wrapper.bsc_olap_object_relation_tb, --to get baes table, dimset and bt measures
p_dimset_oor bsc_aw_md_wrapper.bsc_olap_object_relation_tb, --to get measures etc
p_load_program varchar2,
p_LB_resync_program varchar2,
p_min_value dbms_sql.number_table,
p_max_value dbms_sql.number_table,
p_bt_current_period dbms_sql.varchar2_table /*null are indicated as 'null' */
) is
--
l_job_name varchar2(100);
l_process varchar2(8000);
l_job_status bsc_aw_utility.parallel_job_tb;
--
l_measures dbms_sql.varchar2_table;
l_cubes dbms_sql.varchar2_table;
l_start_lock_objects varchar2(3000);
l_end_lock_objects varchar2(3000);
l_parameter_string varchar2(2000);
l_base_table_stmt varchar2(2000);
l_min_stmt varchar2(2000);
l_max_stmt varchar2(2000);
l_bt_current_period_stmt varchar2(2000);
l_lock_object_cubes dbms_sql.varchar2_table;
l_lock_object_limit_cubes dbms_sql.varchar2_table;
l_lock_object_reset_cubes dbms_sql.varchar2_table;
l_run_id number;
l_cubes_to_load dbms_sql.varchar2_table;
l_measures_to_load dbms_sql.varchar2_table;
--
l_aggregation aggregation_r;
l_dim_set bsc_aw_adapter_kpi.dim_set_r;
l_cube_pt bsc_aw_adapter_kpi.partition_template_r;
l_bt_considered dbms_sql.varchar2_table;
l_partition_options varchar2(2000); /*hold partition dim value */
Begin
  bsc_aw_utility.clean_up_jobs('all');
  for i in 1..p_dimset_oor.count loop
    --p_dimset_oor contains info pertaining to p_dimset only
    if p_dimset_oor(i).relation_type='dim set measure' then
      l_measures(l_measures.count+1):=p_dimset_oor(i).relation_object;
      l_cubes(l_cubes.count+1):=bsc_aw_utility.get_parameter_value(p_dimset_oor(i).property1,'cube',',');
      if bsc_aw_utility.in_array(l_cubes_to_load,l_cubes(l_cubes.count))=false then
        l_cubes_to_load(l_cubes_to_load.count+1):=l_cubes(l_cubes.count);
      end if;
    end if;
  end loop;
  /*
  we now have support for partitions. we need to have a thread per cube...not per measure
  then for each cube, we can parallelize based on partitions
  technically, we need to group cubes by PT or comp.lets assume that diff cubes have diff PT or comp so they can be loaded in
  parallel
  for each measure, find out all base tables that carry this measure.
  release the lock on the cubes. we release all cubes and countvar cubes of the dimset. this is ok since 2 base tables feeding a dimset
  have to go one after the other anyway . we need l_aggregation to get the dimset info
  */
  --
  set_aggregation(p_kpi,l_aggregation);
  l_dim_set:=l_aggregation.dim_set(get_dim_set_index(l_aggregation,p_dimset));
  --
  get_measure_objects_to_lock(p_kpi,p_dimset,l_measures,l_lock_object_cubes);
  get_dimset_objects_to_lock(p_kpi,p_dimset,'dim limit cube',l_lock_object_limit_cubes);
  get_dimset_objects_to_lock(p_kpi,p_dimset,'dim reset cube',l_lock_object_reset_cubes);
  --we must save these objects back to the system first, especially the limit cubes that can change due to aggregate marker pgm
  --for perf reasons, at present, we will not save the cube...it could not have changed
  --reset cubes share the composite with limit cubes.
  bsc_aw_management.commit_aw(l_lock_object_limit_cubes,'no release lock');
  bsc_aw_management.release_lock(l_lock_object_cubes);
  bsc_aw_management.release_lock(l_lock_object_limit_cubes);
  bsc_aw_management.release_lock(l_lock_object_reset_cubes);
  --
  /*
  if the cube is partitioned, we load the partitions in parallel, job per partition for the cube
  if the cube is not partitioned, its one job per cube
  */
  --
  l_run_id:=0;
  for i in 1..l_cubes_to_load.count loop
    l_base_table_stmt:=null;
    l_min_stmt:=null;
    l_max_stmt:=null;
    l_bt_current_period_stmt:=null;
    l_bt_considered.delete;
    l_measures_to_load.delete;
    for j in 1..l_measures.count loop
      if l_cubes(j)=l_cubes_to_load(i) then
        for k in 1..p_base_table_dimset_oor.count loop
          if instr(p_base_table_dimset_oor(k).property1,l_measures(j)||'+')>0 then
            bsc_aw_utility.merge_value(l_measures_to_load,l_measures(j));
            if bsc_aw_utility.in_array(l_bt_considered,p_base_table_dimset_oor(k).object)=false then
              l_base_table_stmt:=l_base_table_stmt||p_base_table_dimset_oor(k).object||',';
              l_min_stmt:=l_min_stmt||p_min_value(k)||',';
              l_max_stmt:=l_max_stmt||p_max_value(k)||',';
              l_bt_current_period_stmt:=l_bt_current_period_stmt||p_bt_current_period(k)||',';
              l_bt_considered(l_bt_considered.count+1):=p_base_table_dimset_oor(k).object;
            end if;
          end if;
        end loop;
      end if;
    end loop;
    if l_base_table_stmt is not null then
      --l_base_table_stmt can be null. we may be loading base table that is feeding 2 out of 5 measures for example
      --see if the cube is partitioned or not
      l_cube_pt.template_name:=bsc_aw_adapter_kpi.get_cube_axis(l_cubes_to_load(i),l_dim_set,'partition template');
      if l_cube_pt.template_name is not null then --this is a partitioned cube
        l_cube_pt:=bsc_aw_adapter_kpi.get_partition_template_r(l_cube_pt.template_name,l_dim_set);
        l_end_lock_objects:=null;
        --end lock objects are the limit cubes
        for j in 1..l_lock_object_limit_cubes.count loop
          l_end_lock_objects:=l_end_lock_objects||l_lock_object_limit_cubes(j)||',';
        end loop;
        for j in 1..l_cube_pt.template_partitions.count loop
          l_job_name:='bsc_aw_lc_'||p_dimset||'_'||l_cubes_to_load(i)||'_part_'||l_cube_pt.template_partitions(j).partition_name||'_'||
          bsc_aw_utility.get_dbms_time;
          l_parameter_string:=l_cubes_to_load(i)||','''',''''partition='||l_cube_pt.template_partitions(j).partition_name||',';
          l_partition_options:='partition='||l_cube_pt.template_partitions(j).partition_name||',partition dim value='||
          l_cube_pt.template_partitions(j).partition_dim_value;
          l_start_lock_objects:=l_cubes_to_load(i)||' (partition '||l_cube_pt.template_partitions(j).partition_name||'),';
          l_run_id:=l_run_id+1;
          l_process:='bsc_aw_load_kpi.load_cube_base_table('''||p_kpi||''','''||p_dimset||''','''||l_parameter_string||''','''||
          l_cubes_to_load(i)||''','''||bsc_aw_utility.make_string_from_list(l_measures_to_load)||''','''||
          l_base_table_stmt||''','''||l_start_lock_objects||''','''||l_end_lock_objects||''','''||p_load_program||''','''||
          p_LB_resync_program||''','''||l_min_stmt||''','''||l_max_stmt||''','''||l_bt_current_period_stmt||''','''||l_partition_options||''','||
          l_run_id||','''||l_job_name||''','''||bsc_aw_utility.get_option_string||''');';
          bsc_aw_utility.start_job(l_job_name,l_run_id,l_process,null);
        end loop;
      else --non partitioned cube
        l_job_name:='bsc_aw_lc_'||p_dimset||'_'||l_cubes_to_load(i)||'_'||bsc_aw_utility.get_dbms_time;
        l_start_lock_objects:=l_cubes_to_load(i)||',';
        l_run_id:=l_run_id+1;
        l_process:='bsc_aw_load_kpi.load_cube_base_table('''||p_kpi||''','''||p_dimset||''','''||l_start_lock_objects||''','''||
        l_cubes_to_load(i)||''','''||bsc_aw_utility.make_string_from_list(l_measures_to_load)||''','''||
        l_base_table_stmt||''','''||l_start_lock_objects||''','''||l_end_lock_objects||''','''||p_load_program||''',''null'','''||l_min_stmt||''','''||
        l_max_stmt||''','''||l_bt_current_period_stmt||''',''null'','||
        l_run_id||','''||l_job_name||''','''||bsc_aw_utility.get_option_string||''');';
        bsc_aw_utility.start_job(l_job_name,l_run_id,l_process,null);
      end if;
    end if;
  end loop;
  /*
  in the case where we have partitions, we do not need to launch the process for limit cubes. if we call the program with
  LIMIT CUBE, it will do nothing. but best if we do not call the procedure at all
  */
  if l_dim_set.cube_design <> 'datacube' then
    l_base_table_stmt:=null;
    l_min_stmt:=null;
    l_max_stmt:=null;
    l_bt_current_period_stmt:=null;
    for i in 1..p_base_table_dimset_oor.count loop
      l_base_table_stmt:=l_base_table_stmt||p_base_table_dimset_oor(i).object||',';
      l_min_stmt:=l_min_stmt||p_min_value(i)||',';
      l_max_stmt:=l_max_stmt||p_max_value(i)||',';
      l_bt_current_period_stmt:=l_bt_current_period_stmt||p_bt_current_period(i)||',';
    end loop;
    if l_base_table_stmt is not null then
      l_job_name:='bsc_aw_load_limit_cube_'||p_dimset||'_'||bsc_aw_utility.get_dbms_time||'_'||l_run_id;
      l_start_lock_objects:=null;
      for i in 1..l_lock_object_limit_cubes.count loop --l_lock_object_limit_cubes are the limit cubes
        l_start_lock_objects:=l_start_lock_objects||l_lock_object_limit_cubes(i)||',';
      end loop;
      l_run_id:=l_run_id+1;
      l_process:='bsc_aw_load_kpi.load_cube_base_table('''||p_kpi||''','''||p_dimset||''',''LIMIT CUBE'','||
      '''null'',''null'','''||
      l_base_table_stmt||''','''||l_start_lock_objects||''',''null'','''||p_load_program||''',''null'','''||l_min_stmt||''','''||
      l_max_stmt||''','''||l_bt_current_period_stmt||''',''null'','||l_run_id||','''||l_job_name||''','''||bsc_aw_utility.get_option_string||''');';
      bsc_aw_utility.start_job(l_job_name,l_run_id,l_process,null);
    end if;
  end if;
  --
  bsc_aw_utility.wait_on_jobs(null,l_job_status);
  for i in 1..l_job_status.count loop
    if l_job_status(i).status='error' then
      raise bsc_aw_utility.g_exception;
    end if;
  end loop;
  --get the locks back
  bsc_aw_management.get_lock(l_lock_object_cubes,'resync');
  if l_lock_object_limit_cubes.count>0 then
    bsc_aw_management.get_lock(l_lock_object_limit_cubes,'resync');
  end if;
  if l_lock_object_reset_cubes.count>0 then
    bsc_aw_management.get_lock(l_lock_object_reset_cubes,'resync');
  end if;
Exception when others then
  log_n('Exception in load_kpi_dimset_base_table_job '||sqlerrm);
  raise;
End;

/*
this procedure is called from a dbms job. this loads a measure given the base table.
p_base_table is a concat list of base tables ...b1,b2, format
p_measure can also be "LIMIT CUBE" which is to load limit cubes
p_min_value is in the format 1,2, etc. min value and max value match base tables
if p_parameter ='LIMIT CUBE' then p_cubes will contain the limit cubes
p_start_lock_objects : we lock them in the begining itself
p_end_lock_objects : these we lock only after executing the load.
*/
procedure load_cube_base_table(
p_kpi varchar2,
p_dim_set varchar2,
p_parameter varchar2,
p_cubes varchar2,--c1,c2 format
p_measures  varchar2,--m1,m2 format
p_base_table varchar2, --B1,B2,B3, format
p_start_lock_objects varchar2, --usually 1 cube c1, format
p_end_lock_objects varchar2, --in case of partitions, limit cubes
p_load_program varchar2,
p_LB_resync_program varchar2,
p_min_value varchar2,
p_max_value varchar2,
p_bt_current_period varchar2,
p_partition_options varchar2,
p_run_id number,p_job_name varchar2,p_options varchar2) is
--
l_cubes dbms_sql.varchar2_table;
l_measures dbms_sql.varchar2_table;
l_start_lock_objects dbms_sql.varchar2_table;
l_end_lock_objects dbms_sql.varchar2_table;
l_base_tables dbms_sql.varchar2_table;
l_stmt varchar2(4000);
l_min_values dbms_sql.varchar2_table;
l_max_values dbms_sql.varchar2_table;
l_bt_current_period dbms_sql.varchar2_table;
l_lock_objects dbms_sql.varchar2_table;
l_flag boolean;
l_ds_parameters dbms_sql.varchar2_table;
--
l_aggregation aggregation_r;
l_dim_set bsc_aw_adapter_kpi.dim_set_r;
l_partition_options varchar2(2000);
Begin
  if p_run_id is not null then
    --this is a dbms job. we have to do the initializations since this is a new session
    bsc_aw_utility.g_options.delete;
    bsc_aw_utility.parse_parameter_values(p_options,',',bsc_aw_utility.g_options);
    bsc_aw_utility.open_file(p_job_name);
    bsc_aw_utility.dmp_g_options(bsc_aw_utility.g_options);
    bsc_aw_utility.init_all_procedures;
    if g_debug then
      bsc_aw_utility.clean_stats('group.load_cube_base_table');
      bsc_aw_utility.load_stats('Start Of Process. Load kpi dimset cube base table','group.load_cube_base_table');
    end if;
  end if;
  --
  bsc_aw_utility.parse_parameter_values(p_start_lock_objects,',',l_start_lock_objects);
  if p_end_lock_objects <> 'null' then
    bsc_aw_utility.parse_parameter_values(p_end_lock_objects,',',l_end_lock_objects);
  end if;
  if p_cubes<>'null' then
    bsc_aw_utility.parse_parameter_values(p_cubes,',',l_cubes);
  end if;
  if p_measures<>'null' then
    bsc_aw_utility.parse_parameter_values(p_measures,',',l_measures);
  end if;
  l_partition_options:=p_partition_options;
  if l_partition_options='null' then
    l_partition_options:=null;
  end if;
  bsc_aw_utility.parse_parameter_values(p_base_table,',',l_base_tables);
  bsc_aw_utility.parse_parameter_values(p_min_value,',',l_min_values);
  bsc_aw_utility.parse_parameter_values(p_max_value,',',l_max_values);
  bsc_aw_utility.parse_parameter_values(p_bt_current_period,',',l_bt_current_period);
  l_base_tables:=bsc_aw_utility.make_upper(l_base_tables);
  --
  --get the lock. if measure, on the cube. if LIMIT CUBE, on all the limit cubes. note that when its LIMIT CUBE
  --l_cubes will contain the limit cubes
  bsc_aw_management.get_workspace_lock(l_start_lock_objects,null);
  --
  l_flag:=false;
  for i in 1..l_base_tables.count loop
    if to_number(l_min_values(i))<=to_number(l_max_values(i)) then
      insert_bsc_aw_temp_cv(to_number(l_min_values(i)),to_number(l_max_values(i)),l_base_tables(i));
      l_flag:=true;
    end if;
  end loop;
  --
  set_aggregation(p_kpi,l_aggregation);
  l_dim_set:=l_aggregation.dim_set(get_dim_set_index(l_aggregation,p_dim_set));
  if p_parameter<>'LIMIT CUBE' then
    /*see if we need to correct projection values or bal values with a change to current period in the base table */
    check_bt_current_period_change(p_kpi,l_dim_set,l_cubes,l_measures,l_base_tables,l_bt_current_period,l_partition_options);
  end if;
  if l_flag then
    /*set the cal end period rel for balance aggregation in the kpi load programs*/
    limit_calendar_end_period_rel(l_dim_set.calendar);
    get_ds_BT_parameters(p_kpi,p_dim_set,p_load_program,l_base_tables,l_ds_parameters);
    if g_debug then
      log('Before Load, Composite Counts');
      dmp_dimset_composite_count(l_dim_set);
    end if;
    for i in 1..l_ds_parameters.count loop
      --p_parameter contains cube and partition info
      bsc_aw_dbms_aw.execute('call '||p_load_program||'('''||l_ds_parameters(i)||''','''||p_parameter||''')');
    end loop;
    if g_debug then
      log('After Load, Composite Counts');
      dmp_dimset_composite_count(l_dim_set);
    end if;
    reset_calendar_end_period_rel(l_dim_set.calendar);
  end if;
  --get the lock on the end lock objects . must spin till lock is acquired. if not careful, wait can lead to deadlock. in this case,
  --all processes will start with the same order, say A then B then C. so the process to get A will get B and C. then others queue up for A.
  --once process 2 gets A, its guaranteed to get B and C. get_lock will also add the end lock objects to the global list, so commit_aw will
  --save then back to db
  --p_LB_resync_program is very important when we have partitions. without them, the LB will lose their information when we acquire the lock
  --in resync mode
  if l_end_lock_objects.count>0 then
    if p_LB_resync_program <> 'null' then
      bsc_aw_dbms_aw.execute('call '||p_LB_resync_program||'(''PRE'')');
    end if;
    bsc_aw_management.get_lock(l_end_lock_objects,'resync,wait type=active wait');
    if p_LB_resync_program <> 'null' then
      bsc_aw_dbms_aw.execute('call '||p_LB_resync_program||'(''POST'')');
    end if;
  end if;
  --
  --save the cubes back to database. also releases the lock
  bsc_aw_management.commit_aw;
  --
  if p_run_id is not null then
    bsc_aw_utility.send_pipe_message(p_job_name,'status=success');
    bsc_aw_management.detach_workspace;
  end if;
  commit;
  if p_run_id is not null and g_debug then
    bsc_aw_utility.load_stats('End Of Process. Load kpi dimset cube base table','group.load_cube_base_table');
    bsc_aw_utility.print_stats('group.load_cube_base_table');
  end if;
Exception when others then
  log_n('Exception in load_cube_base_table '||sqlerrm);
  if p_run_id is not null then
    bsc_aw_utility.send_pipe_message(p_job_name,'status=error,sqlcode='||sqlcode||',message='||sqlerrm);
    rollback;
    bsc_aw_management.detach_workspace;
  else
    raise;
  end if;
End;

function check_load_type(p_property varchar2) return varchar2 is
l_cv_value number;
Begin
  --ping the aw table for data
  l_cv_value:=to_number(bsc_aw_utility.get_parameter_value(p_property,'current change vector',','));
  if l_cv_value=0 then
    return 'initial';
  else
    return 'inc';
  end if;
Exception when others then
  log_n('Exception in check_load_type '||sqlerrm);
  raise;
End;

/*
dbms job wrapper for aggregate_kpi_dimset
*/
procedure aggregate_kpi_dimset_job(p_kpi varchar2,p_dim_set dbms_sql.varchar2_table) is
--
l_job_name varchar2(100);
l_process varchar2(8000);
l_job_status bsc_aw_utility.parallel_job_tb;
Begin
  bsc_aw_utility.clean_up_jobs('all');
  for i in 1..p_dim_set.count loop
    l_job_name:='bsc_aw_aggregate_kpi_dimset_'||bsc_aw_utility.get_dbms_time||'_'||i;
    l_process:='bsc_aw_load_kpi.aggregate_kpi_dimset('''||p_kpi||''','''||p_dim_set(i)||''','||i||','''||l_job_name||''','''||
    bsc_aw_utility.get_option_string||''');';
    bsc_aw_utility.start_job(l_job_name,i,l_process,null);
  end loop;
  bsc_aw_utility.wait_on_jobs(null,l_job_status);
  for i in 1..l_job_status.count loop
    if l_job_status(i).status='error' then
      raise bsc_aw_utility.g_exception;
    end if;
  end loop;
Exception when others then
  log_n('Exception in aggregate_kpi_dimset_job '||sqlerrm);
  raise;
End;

/*
given a kpi and dimset, aggregate the cubes involved. just a wrapper for
procedure aggregate_kpi_dimset(p_aggregation aggregation_r)
*/
procedure aggregate_kpi_dimset(p_kpi varchar2,p_dim_set varchar2,
p_run_id number,p_job_name varchar2,p_options varchar2) is
l_aggregation aggregation_r;
l_dimset_index number;
Begin
  if p_run_id is not null then
    --this is a dbms job. we have to do the initializations since this is a new session
    bsc_aw_utility.g_options.delete;
    bsc_aw_utility.parse_parameter_values(p_options,',',bsc_aw_utility.g_options);
    bsc_aw_utility.open_file('Aggregate_KD_'||p_dim_set||'_'||p_run_id);
    bsc_aw_utility.dmp_g_options(bsc_aw_utility.g_options);
    bsc_aw_utility.init_all_procedures;
  end if;
  --l_aggregation has info on all dimsets for the kpi
  set_aggregation(p_kpi,l_aggregation);
  --find the actual and target pairs
  l_dimset_index:=0;
  l_dimset_index:=get_dim_set_index(l_aggregation,p_dim_set);
  aggregate_kpi_dimset(p_kpi,l_aggregation,l_aggregation.dim_set(l_dimset_index));
  if p_run_id is not null then
    bsc_aw_utility.send_pipe_message(p_job_name,'status=success');
    bsc_aw_management.detach_workspace;
  end if;
  commit;
Exception when others then
  log_n('Exception in aggregate_kpi_dimset '||sqlerrm);
  if p_run_id is not null then
    bsc_aw_utility.send_pipe_message(p_job_name,'status=error,sqlcode='||sqlcode||',message='||sqlerrm);
    rollback;
    bsc_aw_management.detach_workspace;
  else
    raise;
  end if;
End;

/*
this procedure looks at the list of dimsets and then eliminates targets when corresponding actuals exist
when there is a pair, aggregate only the actual. aggregating actuals will aggregate targets also
then we aggregate standalone targets
*/
procedure get_aggregate_dimsets(
p_kpi varchar2,
p_dim_set dbms_sql.varchar2_table,
p_aggregate_dimset out nocopy dbms_sql.varchar2_table
) is
l_aggregation aggregation_r;
l_agg_flag dbms_sql.varchar2_table;--will be used to eliminate "target" dimsets that have "actual" dimsets aggregating
Begin
  --l_aggregation has info on all dimsets for the kpi
  set_aggregation(p_kpi,l_aggregation);
  --find the actual and target pairs
  for i in 1..l_aggregation.dim_set.count loop
    l_agg_flag(i):='N';
    if bsc_aw_utility.in_array(p_dim_set,l_aggregation.dim_set(i).dim_set_name) then
      --see if the dimset does not need agg (if pre-calc)
      if l_aggregation.dim_set(i).pre_calculated='N' then
        l_agg_flag(i):='Y';
      else
        if g_debug then
          log('Dimset '||p_dim_set(i)||' is pre calculated');
        end if;
      end if;
    end if;
  end loop;
  for i in 1..l_aggregation.dim_set.count loop
    if l_aggregation.dim_set(i).dim_set_type='actual' and l_agg_flag(i)='Y' then
      --see if there is a target too
      for j in 1..l_aggregation.dim_set.count loop
        if l_aggregation.dim_set(j).dim_set_type='target' and l_aggregation.dim_set(j).base_dim_set=l_aggregation.dim_set(i).dim_set_name then
          l_agg_flag(j):='N';
          exit;
        end if;
      end loop;
    end if;
  end loop;
  for i in 1..l_aggregation.dim_set.count loop
    if l_agg_flag(i)='Y' then
      p_aggregate_dimset(p_aggregate_dimset.count+1):=l_aggregation.dim_set(i).dim_set_name;
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_aggregate_dimsets '||sqlerrm);
  raise;
End;

/*
This procedure is only called as a part of the kpi dimset load
its also called when base tables are loaded. with B tables, we find out the affected
dimsets and aggregate them
logic
for the dim set get the dim
for the dim get the limit cubes
find out the levels of the dim for this dim set
get the level positions. limit levels to within adv sum profile.
see if there is zero code. for the levels with zero code, get the zero code level name

look at adv sum profile
limit the dim to the limit cube
for time, limit to all applicable periodicities
for rec dim, call api to find out the levels to limit to. for now, aggregate all levels
get the cubes.
look at the agg formula. if its simple, we can aggregate it
if its a formula, we need to execute the formula after we aggregate the cubes

if there are targets at higher levels we do
1. load the dimset
2. aggregate the dimset
3. load the targets
4. aggregate the dimset

after each agg, the limit cubes are reset

read the measures of the dimset.
in 9i, we aggregate all measures together
1. we aggregate normal measures
2. we aggregate balance measures
3. we aggregate measures with formula. this is one by one

In 10g, we can aggregate cubes in parallel
in 10g, we can launch aggregate_measure in parallel

if the measure is balance, we dont aggregate it with other measures, we use the agg_map_notime to aggregate
balance measures

if aggregation is complex with formula, then we cannot launch the aggregaqtion of the measure in paralle because
this measure needs the other measures to be aggregated before it can execute the formula
this means when we set the dim status, we have to set the status to the higher levels and then aggregate

forecast or projections are handled like this:
each kpi has default dim "projection". when we aggregate we have projection dim as Y and N.
then we limit the dim to Y. then for each periodicity, for those periods where there is a mix of
real and projected data, we make the cube data=0
look at correct_forecast_aggregation

if there are measures with average, we aggergate them separately from measures with sum or other agg functions

please note that the agg maps have opvar and argvar. we aggregate sum, average measures together

if dimset=actual then
aggregate actuals
aggregate targets of corresponding target dimset
if dimset=target then
aggregate targets of corresponding target dimset

"aggregate targets of corresponding target dimset" has both the copy from targets to actuals and the aggregation of actuals
*/
procedure aggregate_kpi_dimset(
p_kpi varchar2,
p_aggregation aggregation_r,
p_dim_set bsc_aw_adapter_kpi.dim_set_r) is
--
l_dim_set bsc_aw_adapter_kpi.dim_set_r;
Begin
  --get the full dimset lock
  lock_dimset_objects(p_kpi,p_dim_set.dim_set_name,null,null);
  if p_dim_set.dim_set_type='actual' then
    --get corresponding target dimset
    l_dim_set.dim_set_name:=null;
    for i in 1..p_aggregation.dim_set.count loop
      if p_aggregation.dim_set(i).dim_set_type='target' and p_aggregation.dim_set(i).base_dim_set=p_dim_set.dim_set_name then
        l_dim_set:=p_aggregation.dim_set(i);
        exit;
      end if;
    end loop;
    aggregate_kpi_dimset_actuals(p_kpi,p_dim_set);
    if l_dim_set.dim_set_name is not null then
      --aggregate targets only if there are targets
      --p_dim_set=actual, l_dim_set=target
      --lock the target limit cubes only!!
      lock_dimset_objects(p_kpi,l_dim_set.dim_set_name,'dim limit cube','inc');
      aggregate_kpi_dimset_targets(p_kpi,p_dim_set,l_dim_set);
    end if;
  elsif p_dim_set.dim_set_type='target' then
    --get corresponding actual dimset
    l_dim_set.dim_set_name:=null;
    for i in 1..p_aggregation.dim_set.count loop
      if p_aggregation.dim_set(i).dim_set_type='actual' and p_aggregation.dim_set(i).dim_set_name=p_dim_set.base_dim_set then
        l_dim_set:=p_aggregation.dim_set(i);
        exit;
      end if;
    end loop;
    --l_dim_set=actual, p_dim_set=target
    --if l_dim_set.dim_set_name is null, its an error, every target must have an actuals
    aggregate_kpi_dimset_targets(p_kpi,l_dim_set,p_dim_set);
  end if;
  --set status to allstat in reset_dim_limits. in 10g parallelism, the dim status here is not what we need.
  --so best to set the status to allstat. N: reset_dim_limits sets status to allstat!!
  --NOTE!!! reset_dim_limits is permanently changing the limit cubes
  reset_dim_limits(p_dim_set);
  if l_dim_set.dim_set_name is not null then
    reset_dim_limits(l_dim_set);
  end if;
  bsc_aw_management.commit_aw;
  commit;
Exception when others then
  log_n('Exception in aggregate_kpi_dimset '||sqlerrm);
  raise;
End;

/*
this procedure is used to aggregate actuals cubes
N:
assumption>>>> when we enter this procedure, all changes have been updated and commited
the process before this is load. load will update and commit for every dimset/base table combination
whether called as a job or in the same session
must be very careful. commit_aw releases locks. so may have to call commit_aw('no release lock') option we have to
do a commit here
*/
procedure aggregate_kpi_dimset_actuals(p_kpi varchar2,p_dim_set bsc_aw_adapter_kpi.dim_set_r) is
--
l_measures dbms_sql.varchar2_table;
l_parallel boolean;
l_aggregate_option varchar2(2000);
Begin
  --we aggregate all measures that are not BALANCE aggregation
  if g_debug then
    log_n('=====================================');
    log('aggregate_kpi_dimset_actuals '||p_dim_set.dim_set_name);
    log('=====================================');
  end if;
  --
  --limit the dim for aggregate_measure and aggregate_measure_formula
  --so these 2 api do not have to call limit of dim
  --aggregate_measure_job will launch jobs to aggregate the cubes. there are 2 pre-reqs
  --1. dim limit cubes are saved back to the database
  --2. the cubes are saved back to the database
  --at this point, we come from either load or aggregate targets. so the limit cubes and cubes are in saved state
  --N: the above is the assumption!!
  --N:when we have compressed composites, we cannot limit dim status before aggregations. also we cannot copy data into the higher
  --levels. this means we cannot have targets at higher levels when we have compressed composites
  limit_all_dim(p_dim_set);
  --
  /*new logic
  if there are non bal measures and bal measures then
    first, aggregate non bal and bal measures on notime
    then aggregate non bal on only time
  elsif there is only non bal then
    aggregate on dimset agg map
  elsif there is only bal then
    this is covered by first if itself
  end if
  this is 25 percent faster than old method of aggregating first the non bal on all dim and then bal mesures on notime
  if we take 2 years of data, only 730 distinct days can exist. an equal or more combinations belong to other dimensions. so one time
  aggregation on other dim for all measures is faster
  another approach using parallelism is to have bal measures on separate composite so bal and non bal measures can be aggregated in parallel
  however, this is not useful because launching 8 processes on 4 cpu box is no point. aggregation is cpu intensive. it doubles storage too
  --
  the best way would have been if we could aggregate bal and non bal measures in one shot. when the aggregation is on time, measurename dim
  must be limited to non bal measures. for other dim, to bal and non bal measures. tried having a diff opvar for time with entry for bal measures
  null. aw simply assumed SUM aggregation. so did not work. then tried placing value like NONE for bal measures. aw nulled out higher values
  we cannot use precompute or valueset because both can only constrain time values, not values of another dim
  */
  l_measures.delete;
  for i in 1..p_dim_set.measure.count loop
    if p_dim_set.measure(i).agg_formula.std_aggregation='Y' then
      l_measures(l_measures.count+1):=p_dim_set.measure(i).measure;
    end if;
  end loop;
  if dimset_has_bal_measures(p_dim_set) then
    l_aggregate_option:='notime';
  else
    l_aggregate_option:=null;
  end if;
  --aggregate these measures that are like sum etc
  if l_measures.count>0 then
    l_parallel:=false;
    if can_launch_jobs(p_kpi,p_dim_set,l_measures)='Y' then
      l_parallel:=true;
    end if;
    /*check to see if there is sufficient load to warrant parallel load .
    earlier we had is_parallel_aggregate test here. we cannot do this. when we aggregate, 100 nodes can explode into 100000 nodes
    depending on the hier depths. this means we cannot disable parallel aggregation just because there are onlyu 100 nodes. load could
    bring in 100 nodes. the only time we can do is_parallel_aggregate test is for formula and target copy because the nodes are
    not increasing in these cases
    */
    if l_parallel=false then
      aggregate_measure(p_kpi,p_dim_set,l_measures,l_aggregate_option);
    else
      aggregate_measure_job(p_kpi,p_dim_set,l_measures,l_aggregate_option,'normal');
    end if;
  end if;
  ----------------
  /*now we aggregate non balance measures on time alone. we do this if the dimset needs to aggregate on time
  if the dimset is partitioned at the lowest time, there is no agg on time*/
  if bsc_aw_adapter_kpi.is_calendar_aggregated(p_dim_set.calendar) then
    l_measures.delete;
    if dimset_has_bal_measures(p_dim_set) then
      for i in 1..p_dim_set.measure.count loop
        if p_dim_set.measure(i).agg_formula.std_aggregation='Y' and p_dim_set.measure(i).measure_type='NORMAL' then
          l_measures(l_measures.count+1):=p_dim_set.measure(i).measure;
        end if;
      end loop;
    end if;
    if l_measures.count>0 then
      l_aggregate_option:='onlytime';
      --aggregate these measures that are non BALANCE
      --aggregate_measure will first aggregate on all dim except time then aggregate on time for non bal measures
      --we will check each time l_parallel because some other load may have launched many jobs.
      l_parallel:=false;
      if can_launch_jobs(p_kpi,p_dim_set,l_measures)='Y' then
        l_parallel:=true;
      end if;
      /*earlier we had is_parallel_aggregate test here. we cannot do this */
      if l_parallel=false then
        aggregate_measure(p_kpi,p_dim_set,l_measures,l_aggregate_option);
      else
        aggregate_measure_job(p_kpi,p_dim_set,l_measures,l_aggregate_option,'onlytime');
      end if;
    end if;
  else
    if g_debug then
      log('Aggregation not specified on time');
    end if;
  end if;
  -----------------
  --now aggregate the formulas
  l_measures.delete;
  for i in 1..p_dim_set.measure.count loop
    if p_dim_set.measure(i).agg_formula.std_aggregation='N' and p_dim_set.measure(i).sql_aggregated='N' then
      l_measures(l_measures.count+1):=p_dim_set.measure(i).measure;
    end if;
  end loop;
  l_parallel:=false;
  if can_launch_jobs(p_kpi,p_dim_set,l_measures)='Y' then
    l_parallel:=true;
  end if;
  if l_measures.count>0 then
    if l_parallel and p_dim_set.compressed='N' then
      /*cannot do is_parallel_aggregate test for CC,comp count is compressed node count*/
      if is_parallel_aggregate(p_dim_set,bsc_aw_utility.g_parallel_aggregate_cutoff)=false then
        if g_debug then
          log('Due to insufficient load, Parallel aggregate for dimset measures made serial');
        end if;
        l_parallel:=false;
      end if;
    end if;
    if l_parallel=false then
      aggregate_measure_formula(p_kpi,p_dim_set,l_measures,null);
    else
      aggregate_measure_job(p_kpi,p_dim_set,l_measures,null,'formula');
    end if;
  end if;
Exception when others then
  log_n('Exception in aggregate_kpi_dimset_actuals '||sqlerrm);
  raise;
End;

/*
this procedure is used to aggregate actuals cubes
procedure called when there is targets at higher levels
logic:
limit all dim to bool status
limit all dim add ancestors
limit all dim add target bool status
set limit  variables to false
--
limit all dim -> keep only level of target
set limit.bool to true by looping across target composite (take any 1 measure)
limit dim to limit.bool
copy data from target to actuals, across target composite
aggregate again

time: targets must have the same periodicity as dim set
*/
procedure aggregate_kpi_dimset_targets(
p_kpi varchar2,
p_actual_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_target_dim_set bsc_aw_adapter_kpi.dim_set_r
) is
--
l_dim_set_reagg bsc_aw_adapter_kpi.dim_set_r;
l_parallel boolean;
l_measures dbms_sql.varchar2_table;
l_lock_object_limit_cubes dbms_sql.varchar2_table;
Begin
  if g_debug then
    log_n('=====================================');
    log('aggregate_kpi_dimset_targets');
    log('=====================================');
  end if;
  --
  --N:we cannot have compressed composites and targets at higher levels since targets need to copy data into the higher
  --levels.
  limit_all_dim(p_actual_dim_set);
  --
  limit_dim_ancestors(p_actual_dim_set.dim,'ADD');
  limit_calendar_ancestors(p_actual_dim_set.calendar,'ADD');
  --
  limit_dim_values(p_target_dim_set.dim,'ADD');--note>> targets abd actuals have the same dim, diff levels
  limit_dim_values(p_target_dim_set.std_dim,'ADD');
  limit_calendar_values(p_target_dim_set.calendar,'ADD');
  --
  --the status of dim is actuals + targets.
  --limit all dim -> keep only level of target. this does NOT limit TIME
  limit_dim_target_level_only(p_actual_dim_set,p_target_dim_set);
  --
  --set limit.bool to true by looping across target composite (take any 1 measure)
  --to get the target composite name, we can simply take 1 measure. even in 10g, we need to consider
  --only 1 measure. so we look at measure(1)
  --earlier: limit_dim_limit_cube(p_target_dim_set.dim,'TRUE',p_target_dim_set.measure(1).composite_name);
  limit_dim_limit_cube(p_target_dim_set.dim,'TRUE');
  limit_dim_limit_cube(p_target_dim_set.std_dim,'TRUE');
  limit_dim_limit_cube(p_target_dim_set.calendar.limit_cube,'TRUE',p_target_dim_set.calendar.limit_cube_composite);
  --
  l_measures.delete;
  for i in 1..p_actual_dim_set.measure.count loop
    l_measures(l_measures.count+1):=p_actual_dim_set.measure(i).measure;
  end loop;
  --
  l_parallel:=false;
  if can_launch_jobs(p_kpi,p_actual_dim_set,l_measures)='Y' then
    l_parallel:=true;
  end if;
  if l_parallel and p_target_dim_set.compressed='N' then
    if is_parallel_aggregate(p_target_dim_set,bsc_aw_utility.g_parallel_target_cutoff)=false then
      if g_debug then
        log('Due to insufficient load, Parallel copy from Target to Actuals made serial');
      end if;
      l_parallel:=false;
    end if;
  end if;
  if l_parallel=false then
    copy_target_to_actual_serial(p_actual_dim_set,p_target_dim_set,l_measures);
  else
    --even if there is one cube and the cube is partitioned, can_launch_jobs will return Y
    copy_target_to_actual_job(p_kpi,p_actual_dim_set,p_target_dim_set,l_measures);
  end if;
  --aggregate again
  /*
  once we copy the targets and we are ready to re-aggregate, we have to be careful. we cannot do
  aggregate_kpi_dimset_actuals(p_kpi,p_actual_dim_set);
  this is because the levels of p_actual_dim_set are lower than the targets. so we should do
  aggregate_kpi_dimset_actuals(p_kpi,target_dim_set);
  but this also does not work since the measures in target_dim_set is not the ones we are  aggregating.
  so we create a new l_dim_set_reagg. we place calendar and dim from targets and rest from actuals and aggregate it
  */
  /*
  we need to solve a complex issue here. say we have a hier change in the upper levels. say the dim are
  component > product > prod family, release and geog (city > state > country > region) now, the target is at prod, release
  city. there is a change to country > region hier. agg of the actuals will null out target data in the following levels
  prod  release   country
  fam  release   country
  prod release   region
  fam release   region
  this is because, data tries to aggregate for actuals from component level. here, there is no data for targets. so the aggregates
  get null. the copy in the code above will not bring in the data since grog is at country level. there is target data at
  prod   release   state level. we need to reaggregate this data. now, the limit cubes not only reflect the hier changes but also
  the inc data.so to keep symmetey, we will drill the dim down to descendents and then keep the target level. then re-aggregate the
  target data
  N:we assume that the actuals limit cubes are intact and have not been reset
  */
  --===
  limit_all_dim(p_actual_dim_set);
  limit_dim_descendents(p_actual_dim_set.dim,'ADD','DESCENDANTS');
  limit_calendar_descendents(p_actual_dim_set.calendar,'ADD','DESCENDANTS');
  limit_dim_target_level_only(p_actual_dim_set,p_target_dim_set); --does not limit TIME
  /*here there is no more agg for balance. balance agg has already happened in the kpi load programs
  both for actuals and targets. so we can limit time also to the level of target */
  limit_cal_target_level_only(p_actual_dim_set,p_target_dim_set);
  limit_dim_limit_cube(p_target_dim_set.dim,'TRUE');
  limit_dim_limit_cube(p_target_dim_set.std_dim,'TRUE');
  limit_dim_limit_cube(p_target_dim_set.calendar.limit_cube,'TRUE',p_target_dim_set.calendar.limit_cube_composite);
  get_dimset_objects_to_lock(p_kpi,p_target_dim_set.dim_set_name,'dim limit cube',l_lock_object_limit_cubes);
  bsc_aw_management.commit_aw(l_lock_object_limit_cubes,'no release lock');
  --===
  l_dim_set_reagg:=p_actual_dim_set;
  l_dim_set_reagg.dim:=p_target_dim_set.dim;
  l_dim_set_reagg.std_dim:=p_target_dim_set.std_dim;
  l_dim_set_reagg.calendar:=p_target_dim_set.calendar; --we need the target limit cubes, periodicities
  l_dim_set_reagg.calendar.agg_map:=p_actual_dim_set.calendar.agg_map;/*copy info missing in target calendar */
  --
  aggregate_kpi_dimset_actuals(p_kpi,l_dim_set_reagg);
  --
Exception when others then
  log_n('Exception in aggregate_kpi_dimset_targets '||sqlerrm);
  raise;
End;

/*
copy in serial or non parallel mode
this converts measures to cubes and calls copy_target_to_actual
*/
procedure copy_target_to_actual_serial(
p_actual_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_target_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_actual_measures dbms_sql.varchar2_table) is
--
l_cubes dbms_sql.varchar2_table;
Begin
  get_cubes_for_measures(p_actual_measures,p_actual_dim_set,l_cubes);
  copy_target_to_actual(p_actual_dim_set,p_target_dim_set,l_cubes,null,null);
Exception when others then
  log_n('Exception in copy_target_to_actual_serial '||sqlerrm);
  raise;
End;

/*
we commit the target limit cubes.
the actual cubes are in a saved state. aggregate_kpi_dimset_actuals would have saved the cubes
N: when copying targets to actuals, we cannot parallelize by partitions since target and actuals
are in diff partition templates we can only parallelize by cubes
when there are targets, the actuals cannot be partitioned at all. only the targets can be partitioned
--
the above is not true anymore. with hash partitions on time, we can partition when there are targets as long as actuals and targets have the
same periodicity. this way, data at a particular period is guaranteed to be in P.x for both actuals and targets. this is true even when there
are balance (end period) and the load has agg bal measure. we need to launch jobs for cubes+partitions
*/
procedure copy_target_to_actual_job(
p_kpi varchar2,
p_actual_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_target_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_actual_measures dbms_sql.varchar2_table
) is
--
l_lock_cubes dbms_sql.varchar2_table;
--
l_job_name varchar2(100);
l_process varchar2(8000);
l_job_status bsc_aw_utility.parallel_job_tb;
--
l_cubes dbms_sql.varchar2_table;
pt_comp dbms_sql.varchar2_table;/*for each l_cubes */
pt_comp_type dbms_sql.varchar2_table;
agg_cubes dbms_sql.varchar2_table;
agg_pt_comp dbms_sql.varchar2_table;
cube_pt bsc_aw_adapter_kpi.partition_template_r;
aggregate_options varchar2(2000);
l_run_id number;
Begin
  bsc_aw_management.save_lock_set('target copy');
  bsc_aw_management.commit_lock_set('target copy','no release lock');
  --release locks on the actual cubes
  l_lock_cubes.delete;
  get_measure_objects_to_lock(p_actual_dim_set,p_actual_measures,l_lock_cubes);
  bsc_aw_management.release_lock(l_lock_cubes); --release lock on the cube and countvar cube. locks still exist on LB
  --
  get_cubes_for_measures(p_actual_measures,p_actual_dim_set,l_cubes);
  --
  /*we find the distinct pt_comp. then for each, partitions. then launch as many jobs */
  for i in 1..l_cubes.count loop
    pt_comp(i):=null;
    pt_comp_type(i):=null;
    pt_comp(i):=bsc_aw_adapter_kpi.get_cube_pt_comp(l_cubes(i),p_actual_dim_set,pt_comp_type(i));/*l_cubes are actuals cubes */
  end loop;
  /* */
  l_run_id:=0;
  aggregate_options:=null;
  bsc_aw_utility.clean_up_jobs('all');
  agg_cubes.delete;
  for i in 1..pt_comp.count loop /*first all cubes that do not have composite or PT */
    if pt_comp(i) is null then
      agg_cubes(agg_cubes.count+1):=l_cubes(i);
    end if;
  end loop;
  if agg_cubes.count>0 then
    l_run_id:=l_run_id+1;
    l_job_name:='bsc_aw_copy_target_actual_'||bsc_aw_utility.get_dbms_time||'_'||l_run_id;
    l_process:='bsc_aw_load_kpi.copy_target_to_actual_job('''||p_kpi||''','''||p_actual_dim_set.dim_set_name||''','''||
    p_target_dim_set.dim_set_name||''','''||bsc_aw_utility.make_string_from_list(agg_cubes)||''',''null'','||
    l_run_id||','''||l_job_name||''','''||bsc_aw_utility.get_option_string||''');';
    bsc_aw_utility.start_job(l_job_name,l_run_id,l_process,null);
  end if;
  for i in 1..pt_comp.count loop
    if pt_comp(i) is not null then
      bsc_aw_utility.merge_value(agg_pt_comp,pt_comp(i));
    end if;
  end loop;
  if agg_pt_comp.count>0 then
    for i in 1..agg_pt_comp.count loop
      agg_cubes.delete;
      for j in 1..pt_comp.count loop
        if agg_pt_comp(i)=pt_comp(j) then
          agg_cubes(agg_cubes.count+1):=l_cubes(j);
        end if;
      end loop;
      if agg_cubes.count>0 then
        aggregate_options:=null;
        cube_pt:=bsc_aw_adapter_kpi.get_partition_template_r(agg_pt_comp(i),p_actual_dim_set);
        if cube_pt.template_name is not null then /*this is a PT */
          for j in 1..cube_pt.template_partitions.count loop
            aggregate_options:='partition='||cube_pt.template_partitions(j).partition_name||',partition dim value='||
            cube_pt.template_partitions(j).partition_dim_value;
            l_run_id:=l_run_id+1;
            l_job_name:='bsc_aw_copy_target_actual_PT_'||bsc_aw_utility.get_dbms_time||'_'||l_run_id;
            l_process:='bsc_aw_load_kpi.copy_target_to_actual_job('''||p_kpi||''','''||p_actual_dim_set.dim_set_name||''','''||
            p_target_dim_set.dim_set_name||''','''||bsc_aw_utility.make_string_from_list(agg_cubes)||''','''||aggregate_options||''','||
            l_run_id||','''||l_job_name||''','''||bsc_aw_utility.get_option_string||''');';
            bsc_aw_utility.start_job(l_job_name,l_run_id,l_process,null);
          end loop;
        else /*this is a composite */
          l_run_id:=l_run_id+1;
          l_job_name:='bsc_aw_copy_target_actual_'||bsc_aw_utility.get_dbms_time||'_'||l_run_id;
          l_process:='bsc_aw_load_kpi.copy_target_to_actual_job('''||p_kpi||''','''||p_actual_dim_set.dim_set_name||''','''||
          p_target_dim_set.dim_set_name||''','''||bsc_aw_utility.make_string_from_list(agg_cubes)||''',''null'','||
          l_run_id||','''||l_job_name||''','''||bsc_aw_utility.get_option_string||''');';
          bsc_aw_utility.start_job(l_job_name,l_run_id,l_process,null);
        end if;
      end if;
    end loop;
  end if;
  bsc_aw_utility.wait_on_jobs(null,l_job_status);
  for i in 1..l_job_status.count loop
    if l_job_status(i).status='error' then
      raise bsc_aw_utility.g_exception;
    end if;
  end loop;
  /*we will detach and attach the workspace here to prevent errors due to resync*/
  bsc_aw_management.detach_workspace;
  bsc_aw_management.lock_lock_set('target copy',null);/*gets lock on LB and cubes. resync will be done is needed
  this will also attach the workspace back*/
Exception when others then
  log_n('Exception in copy_target_to_actual_job '||sqlerrm);
  raise;
End;

/* this procedure is only launched as a job. this is just a wrapper for copy_target_to_actual*/
procedure copy_target_to_actual_job(
p_kpi varchar2,
p_actual_dimset varchar2,
p_target_dimset varchar2,
p_cubes varchar2,
p_aggregate_options varchar2,/*all p_actual_cubes must have the same partition value*/
p_run_id number,p_job_name varchar2,p_options varchar2) is
--
l_aggregation aggregation_r;
l_actual_dimset bsc_aw_adapter_kpi.dim_set_r;
l_target_dimset bsc_aw_adapter_kpi.dim_set_r;
l_cubes dbms_sql.varchar2_table;
l_lock_objects dbms_sql.varchar2_table;
partition_value varchar2(40);
partition_dim_value varchar2(40);
Begin
  if p_run_id is not null then
    --this is a dbms job. we have to do the initializations since this is a new session
    bsc_aw_utility.g_options.delete;
    bsc_aw_utility.parse_parameter_values(p_options,',',bsc_aw_utility.g_options);
    bsc_aw_utility.open_file('Copy_TA_'||p_target_dimset||'_'||p_run_id);
    bsc_aw_utility.dmp_g_options(bsc_aw_utility.g_options);
    bsc_aw_utility.init_all_procedures;
  end if;
  partition_value:=bsc_aw_utility.get_parameter_value(p_aggregate_options,'partition',',');/*P.0, P.1 etc */
  partition_dim_value:=bsc_aw_utility.get_parameter_value(p_aggregate_options,'partition dim value',','); /*1, 2 etc */
  bsc_aw_utility.parse_parameter_values(p_cubes,',',l_cubes);
  set_aggregation(p_kpi,l_aggregation);
  l_actual_dimset:=l_aggregation.dim_set(get_dim_set_index(l_aggregation,p_actual_dimset));
  l_target_dimset:=l_aggregation.dim_set(get_dim_set_index(l_aggregation,p_target_dimset));
  --get locks
  l_lock_objects:=l_cubes;
  if partition_value is not null then
    for i in 1..l_lock_objects.count loop
      l_lock_objects(i):=l_lock_objects(i)||'(partition '||partition_value||')';
    end loop;
  end if;
  bsc_aw_management.get_workspace_lock(l_lock_objects,null);
  --
  copy_target_to_actual(l_actual_dimset,l_target_dimset,l_cubes,partition_value,partition_dim_value);
  --save the cubes back to database
  bsc_aw_management.commit_aw(l_lock_objects);
  --
  if p_run_id is not null then
    bsc_aw_utility.send_pipe_message(p_job_name,'status=success');
    bsc_aw_management.detach_workspace;--release the lock
  end if;
  commit;
Exception when others then
  log_n('Exception in copy_target_to_actual_job '||sqlerrm);
  if p_run_id is not null then
    bsc_aw_utility.send_pipe_message(p_job_name,'status=error,sqlcode='||sqlcode||',message='||sqlerrm);
    rollback;
    bsc_aw_management.detach_workspace; --this will release the locks
  else
    raise;
  end if;
End;

/*
copy_target_to_actual for serial processing
copy_target_to_actual_job for parallel processing
we pass a list of actual cubes here. from the cubes, we find the measures and then from the measures, we find the target cube
N:we assume that if in actuals, measures m1,m2,m3 belong to c1, then for targets, the 3 measures belong to a corresponding
cube, say c1.tgt
when there are targets, actuals cannot have partitions!!
*/
procedure copy_target_to_actual(
p_actual_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_target_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_actual_cubes dbms_sql.varchar2_table,
p_partition_value varchar2,
p_partition_dim_value varchar2
) is
--
l_pt_comp varchar2(200);
l_pt_comp_type varchar2(200);
l_measures bsc_aw_adapter_kpi.measure_tb;
l_target_cube bsc_aw_adapter_kpi.cube_r;
Begin
  if g_debug then
    bsc_aw_utility.clean_stats('group.copy_target_to_actual');
    bsc_aw_utility.load_stats('Start Of Process. Copy Target to Actual','group.copy_target_to_actual');
  end if;
  /* */
  push_dim(p_target_dim_set.dim);
  push_dim(p_target_dim_set.std_dim);
  push_dim(p_target_dim_set.calendar.aw_dim);
  /* */
  limit_dim_values(p_target_dim_set.dim,'to');
  limit_dim_values(p_target_dim_set.std_dim,'to');
  limit_calendar_values(p_target_dim_set.calendar,'to');
  if p_partition_value is not null then /*p_partition_value P.0 etc */
    push_dim(p_actual_dim_set.partition_dim);
    limit_dim(p_actual_dim_set.partition_dim,p_partition_dim_value,'TO');
  end if;
  /* */
  if g_debug then
    dmp_dimset_dim_statlen(p_target_dim_set);
    log('Target Composite Counts');
    dmp_dimset_composite_count(p_target_dim_set);
    log('Actual Composite Counts');
    dmp_dimset_composite_count(p_actual_dim_set);
  end if;
  --copy data from target to actuals, across target composite
  for i in 1..p_actual_cubes.count loop
    --get target cube
    bsc_aw_adapter_kpi.get_measures_for_cube(p_actual_cubes(i),p_actual_dim_set,l_measures);
    --all measures must be in the same tgt cube
    --limit measurename dim to the measures of the cube. actual and target share the same measurename_dim
    /*when we have targets, we do not have compressed composite */
    push_dim(p_actual_dim_set.measurename_dim);
    limit_dim(p_actual_dim_set.measurename_dim,'NULL','TO');
    for j in 1..l_measures.count loop
      limit_dim(p_actual_dim_set.measurename_dim,''''||l_measures(j).measure||'''','ADD');
    end loop;
    --
    l_target_cube:=bsc_aw_adapter_kpi.get_cube_set_for_measure(l_measures(1).measure,p_target_dim_set).cube;
    --get target cube PT or comp
    l_pt_comp:=bsc_aw_adapter_kpi.get_cube_pt_comp(l_target_cube.cube_name,p_target_dim_set,l_pt_comp_type);
    copy_target_to_actual(p_actual_cubes(i),l_target_cube.cube_name,l_pt_comp);
    if g_debug then
      log('After Target Copy, Actual Composite Counts');
      dmp_dimset_composite_count(p_actual_dim_set);
    end if;
    pop_dim(p_actual_dim_set.measurename_dim);
  end loop;
  if g_debug then
    bsc_aw_utility.load_stats('End Of Process. Copy Target to Actual','group.copy_target_to_actual');
    bsc_aw_utility.print_stats('group.copy_target_to_actual');
  end if;
  if p_partition_value is not null then
    pop_dim(p_actual_dim_set.partition_dim);
  end if;
  pop_dim(p_target_dim_set.calendar.aw_dim);
  pop_dim(p_target_dim_set.std_dim);
  pop_dim(p_target_dim_set.dim);
Exception when others then
  log_n('Exception in copy_target_to_actual '||sqlerrm);
  raise;
End;

/*
there was a question on whether the copy from one PT to another will produce accurate results
datacube.1=datacube.2 across PT.2  if they 2 PT share the same partition dim, then the operation results in loop across the
partition dim. pdim=0, then execute the stmt. then pdim=2, execute the stmt etc. this will make sure that the data from one
partition is taken to just another partition. since partitioning is done on an independent dim, at this point, its as if that dim is
just another dim. there is no migration across partitions. tested this with a prototype.
--
more complications: when targets exist, actuals cannot be partitioned. targets can be. targets have diff levels. so if we partition the
actuals, to which partition will we copy the target data?
*/
procedure copy_target_to_actual(
p_actual_cube varchar2,
p_target_cube varchar2,
p_composite varchar2
) is
Begin
  /*now that balance aggregations are done in the kpi program itself, targets for non balance measures will be null at higher levels
  of time */
  g_stmt:=p_actual_cube||'=if '||p_target_cube||' EQ NA then '||p_actual_cube||' else '||p_target_cube;
  if p_composite is not null then
    g_stmt:=g_stmt||' across '||p_composite;
  end if;
  bsc_aw_dbms_aw.execute(g_stmt);
Exception when others then
  log_n('Exception in copy_target_to_actual '||sqlerrm);
  raise;
End;

/*
we follow this logic
create a temp virtual kpi . naming: <kpi>_<dimset>_aggregate
then create the metadata using bsc_aw_md_wrapper.create_kpi
then the threads will use this to aggregate
then delete it from bsc olap metadata bsc_aw_md_wrapper.drop_kpi;
this proc has to release the locks for the measures and then re-acquire them at the end
N: we do not call bsc_aw_management.commit_aw   aggregate_kpi_dimset_actuals must manage that.
we have p_measure_agg_type so we do not have to create a api called "aggregate_measure_formula_job"
and repeat all the code in aggregate_measure_job in aggregate_measure_formula_job
*/
procedure aggregate_measure_job(
p_kpi varchar2,
p_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_measures dbms_sql.varchar2_table,
p_options varchar2,
p_measure_agg_type varchar2 --normal, balance or formula
) is
--
l_kpi_r bsc_aw_adapter_kpi.kpi_r;
l_lock_objects dbms_sql.varchar2_table;
--
l_job_name varchar2(100);
l_process varchar2(8000);
l_job_status bsc_aw_utility.parallel_job_tb;
l_api_name varchar2(200);
l_run_id number;
--
l_cube_set bsc_aw_adapter_kpi.cube_set_r;
l_cube_pt bsc_aw_adapter_kpi.partition_template_r;
l_cubes_to_aggregate dbms_sql.varchar2_table;
l_aggregate_options varchar2(2000);
l_cube_for_measure dbms_sql.varchar2_table;
l_measures_for_cube dbms_sql.varchar2_table;
Begin
  if g_debug then
    log('aggregate_measure_job '||p_kpi);
  end if;
  l_kpi_r.kpi:=p_kpi||'_'||p_dim_set.dim_set_name||'_aggregate';
  l_kpi_r.parent_kpi:=p_kpi;
  l_kpi_r.dim_set(1):=p_dim_set;
  --first drop the metadata if it exists
  bsc_aw_md_wrapper.drop_kpi(l_kpi_r.kpi);
  --then create
  bsc_aw_md_wrapper.create_kpi(l_kpi_r);
  commit;
  --release locks on the cubes, l_lock_objects are the cubes and the countvar cubes
  get_measure_objects_to_lock(p_dim_set,p_measures,l_lock_objects);
  --N:> we are making an assumption here that the cubes can be released and that there are no outstanding
  --changes to be updated and commited for the cubes!!!!!
  bsc_aw_management.release_lock(l_lock_objects);
  --
  l_api_name:='bsc_aw_load_kpi.aggregate_measure';
  --
  bsc_aw_utility.clean_up_jobs('all');
  for i in 1..p_measures.count loop
    l_cube_set:=bsc_aw_adapter_kpi.get_cube_set_for_measure(p_measures(i),p_dim_set);
    l_cube_for_measure(i):=l_cube_set.cube.cube_name;
    if bsc_aw_utility.in_array(l_cubes_to_aggregate,l_cube_set.cube.cube_name)=false then
      l_cubes_to_aggregate(l_cubes_to_aggregate.count+1):=l_cube_set.cube.cube_name;
    end if;
  end loop;
  --
  /*
  if the cube is partitioned, its a job per partition. else its a job per cube
  */
  l_run_id:=0;
  for i in 1..l_cubes_to_aggregate.count loop
    l_measures_for_cube.delete;
    for j in 1..p_measures.count loop
      if l_cube_for_measure(j)=l_cubes_to_aggregate(i) then
        if bsc_aw_utility.in_array(l_measures_for_cube,p_measures(j))=false then
          l_measures_for_cube(l_measures_for_cube.count+1):=p_measures(j);
        end if;
      end if;
    end loop;
    l_cube_pt.template_name:=bsc_aw_adapter_kpi.get_cube_axis(l_cubes_to_aggregate(i),p_dim_set,'partition template');
    if l_cube_pt.template_name is not null then --this is a partitioned cube. job per partition
      l_cube_pt:=bsc_aw_adapter_kpi.get_partition_template_r(l_cube_pt.template_name,p_dim_set);
      for j in 1..l_cube_pt.template_partitions.count loop
        l_aggregate_options:=p_options||',partition='||l_cube_pt.template_partitions(j).partition_name||',partition dim value='||
        l_cube_pt.template_partitions(j).partition_dim_value;
        l_run_id:=l_run_id+1;
        l_job_name:='bsc_aw_aggregate_measure_'||bsc_aw_utility.get_dbms_time||'_'||l_run_id;
        l_process:=l_api_name||'('''||l_kpi_r.kpi||''','''||bsc_aw_utility.make_string_from_list(l_measures_for_cube)||''','''||
        l_aggregate_options||''','''||p_measure_agg_type||''','||l_run_id||','''||l_job_name||''','''||
        bsc_aw_utility.get_option_string||''');';
        bsc_aw_utility.start_job(l_job_name,l_run_id,l_process,null);
      end loop;
    else --non partitioned cube. launch job per cube
      l_aggregate_options:=p_options;
      l_run_id:=l_run_id+1;
      l_job_name:='bsc_aw_aggregate_measure_'||bsc_aw_utility.get_dbms_time||'_'||l_run_id;
      l_process:=l_api_name||'('''||l_kpi_r.kpi||''','''||bsc_aw_utility.make_string_from_list(l_measures_for_cube)||''','''||
      l_aggregate_options||''','''||p_measure_agg_type||''','||l_run_id||','''||l_job_name||''','''||
      bsc_aw_utility.get_option_string||''');';
      bsc_aw_utility.start_job(l_job_name,l_run_id,l_process,null);
    end if;
  end loop;
  bsc_aw_utility.wait_on_jobs(null,l_job_status);
  for i in 1..l_job_status.count loop
    if l_job_status(i).status='error' then
      raise bsc_aw_utility.g_exception;
    end if;
  end loop;
  --get lock back on the cubes
  bsc_aw_management.get_lock(l_lock_objects,'resync');
  --
  bsc_aw_md_wrapper.drop_kpi(l_kpi_r.kpi);
  commit;
Exception when others then
  log_n('Exception in aggregate_measure_job '||sqlerrm);
  rollback;
  if g_debug is null or g_debug=false then
    bsc_aw_md_wrapper.drop_kpi(l_kpi_r.kpi);
    commit;
  end if;
  raise;
End;

/*
wrapper for aggregate_measure. this is called from aggregate_measure_job as dbms job
N:!!!! p_kpi here is p_kpi||'_'||p_dim_set.dim_set_name||'_aggregate';
any query going to olap metadata with p_kpi is going for p_kpi||'_'||p_dim_set.dim_set_name||'_aggregate'
p_measure_agg_type is used so we dont have to un-necessarily code a wrapper for aggregate_measure_formula
with the same logic as this procedure
*/
procedure aggregate_measure(
p_kpi varchar2, -- is p_kpi||'_'||p_dim_set.dim_set_name||'_aggregate';
p_measures varchar2,
p_aggregate_options varchar2,
p_measure_agg_type varchar2, --normal, balance or formula
p_run_id number,p_job_name varchar2,p_options varchar2) is
--
l_measures dbms_sql.varchar2_table;
l_aggregation aggregation_r;
l_dimset bsc_aw_adapter_kpi.dim_set_r;
--
l_lock_objects dbms_sql.varchar2_table;
l_partition_value varchar2(200);
l_partition_dim_value varchar2(200);
Begin
  if p_run_id is not null then
    --this is a dbms job. we have to do the initializations since this is a new session
    bsc_aw_utility.g_options.delete;
    bsc_aw_utility.parse_parameter_values(p_options,',',bsc_aw_utility.g_options);
    bsc_aw_utility.open_file('Agg_M_'||p_kpi||'_'||p_measure_agg_type||'_'||bsc_aw_utility.get_dbms_time||'_'||p_run_id);
    bsc_aw_utility.dmp_g_options(bsc_aw_utility.g_options);
    bsc_aw_utility.init_all_procedures;
  end if;
  --
  bsc_aw_utility.parse_parameter_values(p_measures,',',l_measures);
  --
  set_aggregation(p_kpi,l_aggregation);
  --N: l_aggregation must have only 1 dimset
  l_dimset:=l_aggregation.dim_set(1);
  --get lock we only lock the cube and countvar cube
  get_measure_objects_to_lock(l_dimset,l_measures,l_lock_objects);
  --if there is partition, then add the partition stmt to the lock objects
  l_partition_value:=bsc_aw_utility.get_parameter_value(p_aggregate_options,'partition',',');
  l_partition_dim_value:=bsc_aw_utility.get_parameter_value(p_aggregate_options,'partition dim value',',');
  if l_partition_value is not null then
    for i in 1..l_lock_objects.count loop
      l_lock_objects(i):=l_lock_objects(i)||'(partition '||l_partition_value||')';
    end loop;
  end if;
  bsc_aw_management.get_workspace_lock(l_lock_objects,null);
  --
  limit_all_dim(l_dimset);
  --
  if p_measure_agg_type='formula' then
    aggregate_measure_formula(p_kpi,l_dimset,l_measures,p_aggregate_options);
  else
    aggregate_measure(p_kpi,l_dimset,l_measures,p_aggregate_options);
  end if;
  --release locks. cubes have already been saved in aggregate_measure and aggregate_measure_formula
  bsc_aw_management.release_lock(l_lock_objects);
  if p_run_id is not null then
    bsc_aw_utility.send_pipe_message(p_job_name,'status=success');
    bsc_aw_management.detach_workspace;--release the lock
  end if;
  commit;
Exception when others then
  log_n('Exception in aggregate_measure '||sqlerrm);
  if p_run_id is not null then
    bsc_aw_utility.send_pipe_message(p_job_name,'status=error,sqlcode='||sqlcode||',message='||sqlerrm);
    rollback;
    bsc_aw_management.detach_workspace; --this will release the locks
  else
    raise;
  end if;
End;

/*
given a dimset and a list of measures, this procedure will aggregate them
in 10g, this may be called from another api which is launched as a dbms job

correct_forecast_aggregation has to happen for normal measures only as these are aggregated on time
and for balance measures
if Jan 20 is the current period and from jan 21 we have projection, for the month of jan, we should
only consider data till Jan 20 for aggregation. so for jan, we make month value with projection=Y as 0
*/
procedure aggregate_measure(
p_kpi varchar2,
p_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_measures dbms_sql.varchar2_table,
p_aggregate_options varchar2
) is
--
l_agg_stmt varchar2(4000);
l_flag dbms_sql.varchar2_table;
l_measures bsc_aw_adapter_kpi.measure_tb;
l_aggregate_flag boolean;
--
l_lock_objects dbms_sql.varchar2_table;
l_cubes_to_aggregate dbms_sql.varchar2_table;
l_cube_set bsc_aw_adapter_kpi.cube_set_tb;
l_partition_value varchar2(200);
l_partition_dim_value varchar2(200);
l_agg_map varchar2(200);
l_countvar_stmt varchar2(4000);
Begin
  if g_debug then
    log_n('In aggregate_measure, kpi='||p_kpi||', dim set='||p_dim_set.dim_set_name||
    ', p_aggregate_options='||p_aggregate_options);
    log('Measures:-');
    for i in 1..p_measures.count loop
      log(p_measures(i));
    end loop;
    bsc_aw_utility.clean_stats('group.aggregate_measure');
    bsc_aw_utility.load_stats('Start Of Process. Aggregate Measure','group.aggregate_measure');
  end if;
  l_partition_value:=bsc_aw_utility.get_parameter_value(p_aggregate_options,'partition',',');
  l_partition_dim_value:=bsc_aw_utility.get_parameter_value(p_aggregate_options,'partition dim value',',');
  --first mark the measures that need to aggregated
  for i in 1..p_dim_set.measure.count loop
    if bsc_aw_utility.in_array(p_measures,p_dim_set.measure(i).measure) then
      l_flag(i):='Y';
      l_measures(l_measures.count+1):=p_dim_set.measure(i);
    else
      l_flag(i):='N';
    end if;
  end loop;
  --
  for i in 1..l_measures.count loop
    if bsc_aw_utility.in_array(l_cubes_to_aggregate,l_measures(i).cube)=false then
      l_cubes_to_aggregate(l_cubes_to_aggregate.count+1):=l_measures(i).cube;
      l_cube_set(l_cube_set.count+1):=bsc_aw_adapter_kpi.get_cube_set_r(l_measures(i).cube,p_dim_set);
    end if;
  end loop;
  --
  if p_dim_set.compressed='N' then /*we can limit measurename dim only when the comp is non compressed */
    limit_dim(p_dim_set.measurename_dim,'NULL','TO');
    for i in 1..l_measures.count loop
      limit_dim(p_dim_set.measurename_dim,''''||l_measures(i).measure||'''','ADD');
    end loop;
  end if;
  /*when the dimset is compressed, we cannot limit the partition dim. we need to mention the partition in the aggregate
  command
  */
  if p_dim_set.compressed='N' and l_partition_value is not null then
    push_dim(p_dim_set.partition_dim);
    limit_dim(p_dim_set.partition_dim,l_partition_dim_value,'TO');
    /*tried to see if dimensioning LB with hash partition dim can improve perf of partition aggregations. the idea was that the dim must be
    limited to only the values in the partition. it did not help perf. firstly, since the partition is on time, all partitions contian all other
    dim values. agg cost is in index traversal. if there are 1000 values of a dim in P.0, there is good change there are the same 1000 values in P.1
    cost in traversing the index is the same. so timing with and without partitions seem equal
    some more investigation into the log file found that even after limiting the partition dim, the thread aggregates all partitions.
    we have to specify the partition to make sure only that partition is agregated (aggregate cube (partition P.0) ...
    for this, we have to make entry in measuredim for cube (partition P.n)
    */
  end if;
  /*
  issue when we specify (partition P.0) with countvar cube.
  ORA-33852: You provided extra input starting at '('. so we will limit the partition dim and not specify the (part...) clause
  */
  l_agg_stmt:='aggregate';
  for i in 1..l_cube_set.count loop
    l_agg_stmt:=l_agg_stmt||' '||l_cube_set(i).cube.cube_name;
    if l_partition_value is not null then
      l_agg_stmt:=l_agg_stmt||' (partition '||l_partition_value||')';
    end if;
    l_lock_objects(l_lock_objects.count+1):=l_cube_set(i).cube.cube_name;
    if l_partition_value is not null then
      l_lock_objects(l_lock_objects.count):=l_lock_objects(l_lock_objects.count)||'(partition '||l_partition_value||')';
    end if;
  end loop;
  l_aggregate_flag:=true;
  if bsc_aw_utility.get_parameter_value(p_aggregate_options,'notime',',')='Y' then
    l_agg_map:=p_dim_set.agg_map_notime.agg_map;
  elsif bsc_aw_utility.get_parameter_value(p_aggregate_options,'onlytime',',')='Y' then
    l_agg_map:=p_dim_set.calendar.agg_map.agg_map;
  else
    l_agg_map:=p_dim_set.agg_map.agg_map;
  end if;
  if l_agg_map is null then
    l_aggregate_flag:=false;
  else
    l_countvar_stmt:=null;
    for i in 1..l_cube_set.count loop
      if l_cube_set(i).countvar_cube.cube_name is not null then
        l_countvar_stmt:=l_countvar_stmt||' '||l_cube_set(i).countvar_cube.cube_name;
        l_lock_objects(l_lock_objects.count+1):=l_cube_set(i).countvar_cube.cube_name;
        if l_partition_value is not null then
          l_lock_objects(l_lock_objects.count):=l_lock_objects(l_lock_objects.count)||'(partition '||l_partition_value||')';
        end if;
      end if;
    end loop;
    l_agg_stmt:=l_agg_stmt||' using '||l_agg_map;
    if l_countvar_stmt is not null then
      l_countvar_stmt:=' countvar '||l_countvar_stmt;
      l_agg_stmt:=l_agg_stmt||l_countvar_stmt;
    end if;
  end if;
  --
  if l_aggregate_flag then
    --before we execute agg maps we must limit the measuredim to the measures we are aggregating. measuredim contains all
    --the measures
    /*if we are aggregating measures in time alone, we need to limit all other dim add parents
    this happens when there are balance measures and non bal measures in the dimset*/
    if bsc_aw_utility.get_parameter_value(p_aggregate_options,'onlytime',',')='Y' then
      push_dim(p_dim_set.dim);
      limit_dim_ancestors(p_dim_set.dim,'ADD');
    end if;
    limit_measure_dim(p_dim_set.aggmap_operator,l_cubes_to_aggregate,l_partition_value);
    /*I:if countvar cube is needed, we cannot have partitions. cannot have stmt like
    aggregate datacube.4.4014 (partition P.0) using aggmap.4.4014.notime countvar test.cube (partition P.0) */
    if g_debug then
      log('Before Aggregate');
      dmp_dimset_dim_statlen(p_dim_set);
      dmp_dimset_composite_count(p_dim_set);
    end if;
    bsc_aw_dbms_aw.execute(l_agg_stmt);
    if bsc_aw_utility.get_parameter_value(p_aggregate_options,'onlytime',',')='Y' then
      pop_dim(p_dim_set.dim);
    end if;
    --if this is balance measures, then aggregate on time
    if bsc_aw_utility.get_parameter_value(p_aggregate_options,'notime',',')='Y' then
      --aggregate_balance_time(p_kpi,p_dim_set,l_measures,p_aggregate_options);
      /*balance aggregation are now done in the kpi load programs. we had issues aggregating balances here because looping across
      comp or PT is not possible to create higher periodicity balances. without looping across comp or PT, perf is very bad since
      its creating all logical records*/
      null;
    else
      --if there is forecast, we need to correct the forecast periods(periods where real and forecast data mix)
      --this is called for normal measures and balance measures
      correct_forecast_aggregation(p_kpi,p_dim_set,l_measures,p_aggregate_options);
    end if;
    --save the changes
    --we need to save the changes after aggregating the measures because in 10g, the subsequent operations can be in parallel
    --in diff sessions. for example, there can be aggregate formula which is m3=m1/m2. if we do not save m1 and m2, when
    --m3 is computed in a dbms job, it will not get the aggregated values of m1 and m2.
    bsc_aw_management.commit_aw(l_lock_objects,'no release lock');
    if g_debug then
      log('After Aggregate');
      dmp_dimset_composite_count(p_dim_set);
    end if;
  end if;
  if l_partition_value is not null then
    pop_dim(p_dim_set.partition_dim);
  end if;
  if g_debug then
    bsc_aw_utility.load_stats('End Of Process. Aggregate Measure','group.aggregate_measure');
    bsc_aw_utility.print_stats('group.aggregate_measure');
  end if;
Exception when others then
  log_n('Exception in aggregate_measure '||sqlerrm);
  raise;
End;

/*
this procedure executes agg formula. this is called only for those measures that have agg formula

given a dimset and a list of measures, this procedure will aggregate them
in 10g, this may be called from another api which is launched as a dbms job

handles on those measure that have agg formula like average at the lowest level
here we do the following
limit the dim values
limit the levels
limit the periods and periodicities
each dim, limit status to ancestors
limit time values to ancestors

note: when we limit dimensions, we limit all dim, whether there is rollup or not (single level).
when we take the dim to the ancestors, we do so if there is a relation defined on the dim

when this api is called, we have already checked and seen that p_measure has a non-std formula
based agg
*/
procedure aggregate_measure_formula(
p_kpi varchar2,
p_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_measures dbms_sql.varchar2_table,
p_aggregate_options varchar2
) is
--
l_agg_stmt varchar2(4000);
l_flag dbms_sql.varchar2_table;
l_measures bsc_aw_adapter_kpi.measure_tb;
l_lock_objects dbms_sql.varchar2_table;
--
l_cube_set bsc_aw_adapter_kpi.cube_set_tb;
l_pt_name dbms_sql.varchar2_table;
l_pt_type dbms_sql.varchar2_table;
l_partition_value varchar2(200);
l_partition_dim_value varchar2(200);
Begin
  --in 10g, l_aggregation will be null if this is a new thread. in 9i, this is already set in aggregate_kpi_dimset
  if g_debug then
    log_n('In aggregate_measure_formula, kpi='||p_kpi||', dim set='||p_dim_set.dim_set_name||
    ', p_aggregate_options='||p_aggregate_options);
    log('Measures:-');
    for i in 1..p_measures.count loop
      log(p_measures(i));
    end loop;
    bsc_aw_utility.clean_stats('group.aggregate_measure_formula');
    bsc_aw_utility.load_stats('Start Of Process. Aggregate Measure Formula','group.aggregate_measure_formula');
  end if;
  --first mark the measures that need to aggregated
  --take the dim values to the parents
  push_dim(p_dim_set.dim);
  push_dim(p_dim_set.calendar.aw_dim);
  --
  for i in 1..p_dim_set.measure.count loop
    if bsc_aw_utility.in_array(p_measures,p_dim_set.measure(i).measure) then
      l_flag(i):='Y';
      l_measures(l_measures.count+1):=p_dim_set.measure(i);
      l_lock_objects(l_lock_objects.count+1):=l_measures(l_measures.count).cube;
    else
      l_flag(i):='N';
    end if;
  end loop;
  --
  for i in 1..l_measures.count loop
    l_cube_set(i):=bsc_aw_adapter_kpi.get_cube_set_r(l_measures(i).cube,p_dim_set);
    l_pt_name(i):=null;
    l_pt_type(i):=null;
    l_pt_name(i):=bsc_aw_adapter_kpi.get_cube_pt_comp(l_measures(i).cube,p_dim_set,l_pt_type(i));
  end loop;
  l_partition_value:=bsc_aw_utility.get_parameter_value(p_aggregate_options,'partition',',');
  l_partition_dim_value:=bsc_aw_utility.get_parameter_value(p_aggregate_options,'partition dim value',',');
  /*
  if this procedure has been called for a partition, we limit the partition dim.
  if there is partitions, we must save back to the system the partitions of the cube
  we do not have compressed composite when we have formula
  */
  if l_partition_value is not null then
    push_dim(p_dim_set.partition_dim);
    limit_dim(p_dim_set.partition_dim,l_partition_dim_value,'TO');
    for i in 1..l_lock_objects.count loop
      l_lock_objects(i):=l_lock_objects(i)||'(partition '||l_partition_value||')';
    end loop;
  end if;
  /*limit measurename dim to all measures of the dimset
  when we have formulas that are non sql aggregated, we cannot be having compressed composites*/
  limit_dim(p_dim_set.measurename_dim,'NULL','TO');
  for i in 1..p_dim_set.measure.count loop
    limit_dim(p_dim_set.measurename_dim,''''||p_dim_set.measure(i).measure||'''','ADD');
  end loop;
  /*
  when aggregating formulas, we have to aggregate over each dim. say there is
  prod > cat > zero
  city > state > zero
  type
  day > month > year
  we have to aggregate over each dim, keeping other dim at all their levels.
  this means prod limited to cat and zero. other dim limited to all levels
  then geog limited to state and zero. other dim limited to all levels
  same for time
  */
  --across all dim except time
  --if this is a non rec single level dim, skpi it. no agg on this dim
  limit_dim_ancestors(p_dim_set.dim,'ADD');
  limit_calendar_ancestors(p_dim_set.calendar,'ADD');
  --now the dim and time are limited to all values including lowest level.
  --for each dim, we need to start remoivng the lowest level
  --dim push and pop go in pairs
  --d1 =1 to 10. push d1. then d1 changed to 4 to 8. then push d1. then pop d1. d1 is 4 to 8, then again pop d1
  --d1 is now 1 to 10
  --about the REMOVE...this was designed at the time we had zero code as a virtual level and we created a level for this
  --now, zero is only a value in the level. zero code level is a pure virtual level that just dimensions the relation, so we
  --can aggregate . this means, if we simply remove the level, then formula does not get calculated for zero values.
  --we need to do this : if there is only 1 level and there is agg, its zero code agg. so we limit the value of the level to "0"
  --limit dim to the level
  for i in 1..p_dim_set.dim.count loop
    if is_aggregation_on_dim(p_dim_set.dim(i)) then
      if p_dim_set.dim(i).levels.count=1 and p_dim_set.dim(i).recursive='N' then
        push_dim(p_dim_set.dim(i).dim_name);
        bsc_aw_dbms_aw.execute('limit '||p_dim_set.dim(i).levels(1).level_name||' to ''0''');
        limit_dim(p_dim_set.dim(i).dim_name,p_dim_set.dim(i).levels(1).level_name,'TO');
      else
        --remove the lowest level
        push_dim(p_dim_set.dim(i).dim_name);
        limit_dim(p_dim_set.dim(i).dim_name,p_dim_set.dim(i).levels(1).level_name,'REMOVE');
      end if;
      --aggregate
      /*in 10g, when this is running as a job, we cannot use across composite. the composite for the formula cube does nothave
      the higher dim values. this means across composite will not apply the formula to any higher level dim value
      say we have cube per measure in 10g and each measure has its own composite. then we cannot say across
      we do not have this case where we have measure cube and separate composites. if its 10g, its datacube
      if its 9i its measurecube with the same composite. so taking off check on db version*/
      for j in 1..l_measures.count loop
        l_agg_stmt:=l_measures(j).cube;
        if l_cube_set(j).cube_set_type='datacube' then
          l_agg_stmt:=l_agg_stmt||'('||l_cube_set(j).measurename_dim||' '''||l_measures(j).measure||''')';
        end if;
        l_agg_stmt:=l_agg_stmt||'=('||l_measures(j).agg_formula.agg_formula||')';
        if l_pt_name(j) is not null then
          l_agg_stmt:=l_agg_stmt||' across '||l_pt_name(j);
        end if;
        if g_debug then
          dmp_dimset_dim_statlen(p_dim_set);
          dmp_dimset_composite_count(p_dim_set);
        end if;
        bsc_aw_dbms_aw.execute(l_agg_stmt);
        if g_debug then
          dmp_dimset_composite_count(p_dim_set);
        end if;
      end loop;
      pop_dim(p_dim_set.dim(i).dim_name);
    end if;
  end loop;
  --now do the same on time
  /*there is a question here as to what we need to do if the formula is loading a balance column. balance agg on time has happened at load
  time. however, a user has defined a formula also. this means the formula takes precedence over the agg at load time. i dont think there is
  a case where balance measure has formula to aggregate */
  if is_aggregation_on_time(p_dim_set.calendar) then
    push_dim(p_dim_set.calendar.aw_dim);
    for i in 1..p_dim_set.calendar.periodicity.count loop
      if p_dim_set.calendar.periodicity(i).lowest_level='Y' then
        limit_dim(p_dim_set.calendar.aw_dim,p_dim_set.calendar.periodicity(i).aw_dim,'REMOVE');
      end if;
    end loop;
    --aggregate
    for i in 1..l_measures.count loop
      l_agg_stmt:=l_measures(i).cube;
      if l_cube_set(i).cube_set_type='datacube' then
        l_agg_stmt:=l_agg_stmt||'('||l_cube_set(i).measurename_dim||' '''||l_measures(i).measure||''')';
      end if;
      l_agg_stmt:=l_agg_stmt||'=('||l_measures(i).agg_formula.agg_formula||')';
      if l_pt_name(i) is not null then
        l_agg_stmt:=l_agg_stmt||' across '||l_pt_name(i);
      end if;
      if g_debug then
        dmp_dimset_dim_statlen(p_dim_set);
        dmp_dimset_composite_count(p_dim_set);
      end if;
      bsc_aw_dbms_aw.execute(l_agg_stmt);
      if g_debug then
        dmp_dimset_composite_count(p_dim_set);
      end if;
    end loop;
    pop_dim(p_dim_set.calendar.aw_dim);
  end if;
  pop_dim(p_dim_set.dim);
  pop_dim(p_dim_set.calendar.aw_dim);
  if l_partition_value is not null then
    pop_dim(p_dim_set.partition_dim);
  end if;
  --save the changes
  bsc_aw_management.commit_aw(l_lock_objects,'no release lock');
  if g_debug then
    bsc_aw_utility.load_stats('End Of Process. Aggregate Measure Formula','group.aggregate_measure_formula');
    bsc_aw_utility.print_stats('group.aggregate_measure_formula');
  end if;
Exception when others then
  log_n('Exception in aggregate_measure_formula '||sqlerrm);
  raise;
End;

/*
this procedure is called only if the measure has projections on it. in this case,
we limit the projection dim to Y, then we look at each periodicity for the cube. for
each periodicity, we choose the period where the real and projected data are present.
we then set the value of the cube to 0

at this time, all dim are limited to the values for aggregation.
projection dim is limited to Y and N
time is limited to all the affected lowest level values (days)

we limit projection to Y
we loop through each periodicity, remove the affected periods from the status of time dim

then we set cube=0

we set the cube=0 only for those measures that have forecast. if a measure does not have forecast, we do not
have to do this.
*/
procedure correct_forecast_aggregation(
p_kpi varchar2,
p_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_measures bsc_aw_adapter_kpi.measure_tb,
p_aggregate_options varchar2
) is
--
l_period varchar2(100);
l_pt_comp varchar2(200);
l_pt_comp_type varchar2(200);
l_partition_value varchar2(200);
l_partition_dim_value varchar2(200);
l_cubes dbms_sql.varchar2_table;
l_measures_to_limit dbms_sql.varchar2_table;
Begin
  if bsc_aw_adapter_kpi.is_calendar_aggregated(p_dim_set.calendar) then
    push_dim(get_projection_dim(p_dim_set));
    push_dim(p_dim_set.dim);
    push_dim(p_dim_set.calendar.aw_dim);
    limit_dim_ancestors(p_dim_set.dim,'ADD');
    g_stmt:='limit '||get_projection_dim(p_dim_set)||' to ''Y''';
    bsc_aw_dbms_aw.execute(g_stmt);
    g_stmt:='limit '||p_dim_set.calendar.aw_dim||' to null';
    bsc_aw_dbms_aw.execute(g_stmt);
    l_partition_value:=bsc_aw_utility.get_parameter_value(p_aggregate_options,'partition',',');
    l_partition_dim_value:=bsc_aw_utility.get_parameter_value(p_aggregate_options,'partition dim value',',');
    if l_partition_value is not null then
      push_dim(p_dim_set.partition_dim);
      limit_dim(p_dim_set.partition_dim,l_partition_dim_value,'TO');
    end if;
    --loop through each periodicity. we dont have to do this for lowest periodicity
    for i in 1..p_dim_set.calendar.periodicity.count loop
      --we specify the calendar and periodicity and expect to get back the period for which there is
      --real and projected data
      --if p_dim_set.calendar.periodicity(i).lowest_level='N' then
      if p_dim_set.calendar.periodicity(i).aggregated='Y' then
        l_period:=bsc_aw_utility.get_parameter_value(p_dim_set.calendar.periodicity(i).property,'current period',',');
        g_stmt:='limit '||p_dim_set.calendar.periodicity(i).aw_dim||' to '''||l_period||'''';
        bsc_aw_dbms_aw.execute(g_stmt);
        g_stmt:='limit '||p_dim_set.calendar.aw_dim||' add '||p_dim_set.calendar.periodicity(i).aw_dim;
        bsc_aw_dbms_aw.execute(g_stmt);
      end if;
    end loop;
    /*
    when we had =0, aw gave error that we cannot change the values when looping across PT.
    does this mean that this is generating new values? so far no perf issues.=na is fine
    we cannot have cube(partition P)=na across PT. error : DATACUBE.1.4014 is not a command.
    found later that having=na is fine but it does not NA the values. so we have to leave the PT out
    --
    in 10.2, found that across PT does work. data is set to na, however, composite is not cleared. since we set =na only for the actuals
    cube, we shound be fine.
    */
    l_measures_to_limit.delete;
    for i in 1..p_measures.count loop
      if p_measures(i).forecast='Y' then
        l_measures_to_limit(l_measures_to_limit.count+1):=''''||p_measures(i).measure||'''';
        if bsc_aw_utility.in_array(l_cubes,p_measures(i).cube)=false then
          l_cubes(l_cubes.count+1):=p_measures(i).cube;
        end if;
      end if;
    end loop;
    if g_debug then
      dmp_dimset_dim_statlen(p_dim_set);
    end if;
    --N: if the dimset has multiple cubes, the cubes cannot share measures. so we can set the measurename_dim to all
    --measures
    /*when we are here, the composite cannot be compressed */
    push_dim(p_dim_set.measurename_dim);
    limit_dim(p_dim_set.measurename_dim,'NULL','TO');
    limit_dim(p_dim_set.measurename_dim,l_measures_to_limit,'ADD');
    for i in 1..l_cubes.count loop
      l_pt_comp:=bsc_aw_adapter_kpi.get_cube_pt_comp(l_cubes(i),p_dim_set,l_pt_comp_type);
      g_stmt:=l_cubes(i)||'=NA';
      --if l_pt_comp is not null and l_pt_comp_type='composite' then
      if l_pt_comp is not null then --for both composite and PT(10.2)(composite values are not cleared)
        g_stmt:=g_stmt||' across '||l_pt_comp;
      end if;
      bsc_aw_dbms_aw.execute(g_stmt);
    end loop;
    pop_dim(get_projection_dim(p_dim_set));
    pop_dim(p_dim_set.dim);
    pop_dim(p_dim_set.calendar.aw_dim);
    if l_partition_value is not null then
      pop_dim(p_dim_set.partition_dim);
    end if;
    pop_dim(p_dim_set.measurename_dim);
  end if;
Exception when others then
  log_n('Exception in correct_forecast_aggregation '||sqlerrm);
  raise;
End;

/*
this procedure gives the period in which there is a mix of forecast and real data
we need the following
kpi and periodicity : we use this to hit bsc_db_tables that will indicate the current period
calendar : with this, we will get the current year.
then we can say make the period
*/
procedure get_forecast_current_period(
p_aggregation in out nocopy aggregation_r) is
--
l_period varchar2(100);
Begin
  for i in 1..p_aggregation.dim_set.count loop
    for j in 1..p_aggregation.dim_set(i).calendar.periodicity.count loop
      get_forecast_current_period(nvl(p_aggregation.parent_kpi,p_aggregation.kpi),p_aggregation.dim_set(i).calendar.calendar,
      p_aggregation.dim_set(i).calendar.periodicity(j).periodicity,l_period);
      p_aggregation.dim_set(i).calendar.periodicity(j).property:=p_aggregation.dim_set(i).calendar.periodicity(j).property||
      'current period='||l_period||',';
    end loop;
  end loop;
Exception when others then
  log_n('Exception in get_forecast_current_period '||sqlerrm);
  raise;
End;

procedure get_forecast_current_period(
p_kpi varchar2,
p_calendar number,
p_periodicity number,
p_period out nocopy varchar2
) is
Begin
  bsc_aw_bsc_metadata.get_forecast_current_period(p_kpi,p_calendar,p_periodicity,p_period);
Exception when others then
  log_n('Exception in get_forecast_current_period '||sqlerrm);
  raise;
End;

/*
this procedure is used for aggregatingbalance measures on time
this limist teh time dim end period relation to the current period
Q:do we need to set the proj values for missing periodicities to null? for now, lets do this, so the data is in sync
across all periodicities of the kpi
*/
procedure limit_calendar_end_period_rel(p_calendar bsc_aw_adapter_kpi.calendar_r) is
--
l_period_lowest varchar2(100); --current period of the lowest periodicity
l_period varchar2(100);
Begin
  if g_debug then
    log('--limit_calendar_end_period_rel------');
  end if;
  push_dim(p_calendar.aw_dim);
  push_dim(p_calendar.end_period_level_name_dim);
  g_stmt:='limit '||p_calendar.aw_dim||' to null';
  bsc_aw_dbms_aw.execute(g_stmt);
  --
  for i in 1..p_calendar.periodicity.count loop
    if p_calendar.periodicity(i).lowest_level='Y' then
      l_period_lowest:=bsc_aw_utility.get_parameter_value(p_calendar.periodicity(i).property,'current period',',');
      g_stmt:='limit '||p_calendar.end_period_level_name_dim||' TO '''||p_calendar.periodicity(i).aw_dim||'''';
      bsc_aw_dbms_aw.execute(g_stmt);
      --for all upper levels, back up original relation value
      for j in 1..p_calendar.periodicity.count loop
        if p_calendar.periodicity(j).lowest_level <> 'Y' then
          l_period:=bsc_aw_utility.get_parameter_value(p_calendar.periodicity(j).property,'current period',',');
          g_stmt:='limit '||p_calendar.periodicity(j).aw_dim||' to '''||l_period||'''';
          bsc_aw_dbms_aw.execute(g_stmt);
          g_stmt:='limit '||p_calendar.aw_dim||' to '||p_calendar.periodicity(j).aw_dim;
          bsc_aw_dbms_aw.execute(g_stmt);
          --set the rel.end_period relation
          --save the value for use in reset_calendar_end_period_rel
          g_stmt:=p_calendar.end_period_relation_name||'.temp = '||p_calendar.end_period_relation_name;
          bsc_aw_dbms_aw.execute(g_stmt);
          --we have to be careful here. imagine there is a hier like this
          --  M >- Q >- S >- Y
          --  W >- BiW >- Y
          --if we simply put the value of l_period_lowest for all upper levels, we may put month value into BiW. this is wrong.
          --month does not rollup to BiW.
          g_stmt:=p_calendar.end_period_relation_name||'= if '||p_calendar.end_period_relation_name||' EQ NA then NA else '||
          p_calendar.aw_dim||'('||p_calendar.periodicity(i).aw_dim||' '''||l_period_lowest||''')';
          bsc_aw_dbms_aw.execute(g_stmt);
        end if;
      end loop;
    end if;
  end loop;
  pop_dim(p_calendar.aw_dim);
  pop_dim(p_calendar.end_period_level_name_dim);
  if g_debug then
    log('----');
  end if;
Exception when others then
  log_n('Exception in limit_calendar_end_period_rel '||sqlerrm);
  raise;
End;

/*
this procedure restores the relation p_calendar.end_period_relation_name
limit_calendar_end_period_rel has altered the relation. if we commit the changes, the relation is forever
altered.
another strategy is not to alter the relation. in this case, we first do the copy, then for each
higher periodicity, we can copy based on the current period.
This has the isue that the copy occurs several times. its more efficient to do  it once.
resetting the relation back is easier. we need to store the values in global variables
*/
procedure reset_calendar_end_period_rel(p_calendar bsc_aw_adapter_kpi.calendar_r) is
--
l_period varchar2(100);
Begin
  if g_debug then
    log('--reset_calendar_end_period_rel------');
  end if;
  push_dim(p_calendar.aw_dim);
  push_dim(p_calendar.end_period_level_name_dim);
  --we limit level name dim to the lowest level of the kpi dimset
  g_stmt:='limit '||p_calendar.aw_dim||' to null';
  bsc_aw_dbms_aw.execute(g_stmt);
  for i in 1..p_calendar.periodicity.count loop
    if p_calendar.periodicity(i).lowest_level='Y' then
      g_stmt:='limit '||p_calendar.end_period_level_name_dim||' to '''||p_calendar.periodicity(i).aw_dim||'''';
      bsc_aw_dbms_aw.execute(g_stmt);
      for j in 1..p_calendar.periodicity.count loop
        if p_calendar.periodicity(j).lowest_level <> 'Y' then
          l_period:=bsc_aw_utility.get_parameter_value(p_calendar.periodicity(j).property,'current period',',');
          g_stmt:='limit '||p_calendar.periodicity(j).aw_dim||' to '''||l_period||'''';
          bsc_aw_dbms_aw.execute(g_stmt);
          g_stmt:='limit '||p_calendar.aw_dim||' to '||p_calendar.periodicity(j).aw_dim;
          bsc_aw_dbms_aw.execute(g_stmt);
          g_stmt:=p_calendar.end_period_relation_name||'='||p_calendar.end_period_relation_name||'.temp';
          bsc_aw_dbms_aw.execute(g_stmt);
        end if;
      end loop;
    end if;
  end loop;
  --
  pop_dim(p_calendar.aw_dim);
  pop_dim(p_calendar.end_period_level_name_dim);
  if g_debug then
    log('----');
  end if;
Exception when others then
  log_n('Exception in reset_calendar_end_period_rel '||sqlerrm);
  raise;
End;

--limit a given dim to a given value
procedure limit_dim(p_dim varchar2,p_value varchar2,p_mode varchar2) is
Begin
  g_stmt:='limit '||p_dim||' '||p_mode||' '||p_value;
  bsc_aw_dbms_aw.execute(g_stmt);
Exception when others then
  log_n('Exception in limit_dim '||sqlerrm);
  raise;
End;

--limit a given dim to a given set of value
procedure limit_dim(p_dim varchar2,p_value dbms_sql.varchar2_table,p_mode varchar2) is
Begin
  for i in 1..p_value.count loop
    limit_dim(p_dim,p_value(i),p_mode);
  end loop;
Exception when others then
  log_n('Exception in limit_dim '||sqlerrm);
  raise;
End;

/*
this procedures limits the dim values
*/
procedure limit_dim_values(p_dim bsc_aw_adapter_kpi.dim_tb,p_mode varchar2) is
Begin
  for i in 1..p_dim.count loop
    g_stmt:='limit '||p_dim(i).dim_name||' '||p_mode||' '||p_dim(i).limit_cube;
    bsc_aw_dbms_aw.execute(g_stmt);
  end loop;
Exception when others then
  log_n('Exception in limit_dim_values '||sqlerrm);
  raise;
End;

/*
given a adv sum profile value, this procedure limits the dim levels

for actuals, the dim will have all the levels
when called for targets, the dim's lowest level will be the level of the target, like state for example

for rec dim, we limit the levels only in the case where the rec dim is implemented as denorm hier
if implemented as normal hier, we aggregate to all levels. in this case, we have to aggregate all levels
to reach the top node.
*/
procedure limit_dim_levels(p_dim bsc_aw_adapter_kpi.dim_tb) is
Begin
  for i in 1..p_dim.count loop
    if p_dim(i).recursive<>'Y' then
      limit_dim_levels(p_dim(i));
    end if;
  end loop;
  --now, set the levels for the rec dim
  for i in 1..p_dim.count loop
    if p_dim(i).recursive='Y' and p_dim(i).recursive_norm_hier='N' then
      limit_dim_levels(p_dim(i));
    end if;
  end loop;
Exception when others then
  log_n('Exception in limit_dim_levels '||sqlerrm);
  raise;
End;

/*
the algo:
start from the lowest level. limit level name dim to all parent.child and recursively go up
as long as the level is a part of the dim
now, in bsc_aw_md_api, when we load the parent child relation for both dim and calendar,
we only bring in the parent child that belong to the kpi
*/
procedure limit_dim_levels(p_dim bsc_aw_adapter_kpi.dim_r) is
Begin
  if p_dim.recursive='N' then
    g_stmt:='limit '||p_dim.level_name_dim||' to null';
    bsc_aw_dbms_aw.execute(g_stmt);
    --we start the process with the lowest level. this procedure is called rec for the parents
    limit_dim_levels(p_dim,p_dim.levels(1).level_name);
  else --now, set the levels for the rec dim
    --p_dim.level_name_dim||'.position is the variable with the position for each rec dim value, larry=1, john wookey=2
    /*this api is only called when the rec dim is implemented in denorm fashion */
    g_stmt:='limit '||p_dim.level_name_dim||' to '||p_dim.level_name_dim||'.position LE '||p_dim.agg_level;
    bsc_aw_dbms_aw.execute(g_stmt);
  end if;
Exception when others then
  log_n('Exception in limit_dim_levels '||sqlerrm);
  raise;
End;

/*
this procedure fires recursively
p_level is the child level
parent_child will onky have the parent child belonging to the kpi
*/
procedure limit_dim_levels(p_dim bsc_aw_adapter_kpi.dim_r,p_level varchar2) is
l_this_level bsc_aw_adapter_kpi.level_r;
l_parent_level bsc_aw_adapter_kpi.level_r;
l_flag bsc_aw_utility.boolean_table;
Begin
  --first the zero code
  l_this_level:=bsc_aw_adapter_kpi.get_dim_level_r(p_dim,p_level);
  if l_this_level.aggregated='Y' then
    if l_this_level.zero_code='Y' and l_this_level.zero_aggregated='Y' then
      g_stmt:='limit '||p_dim.level_name_dim||' add '''||l_this_level.zero_code_level||'.'||
      l_this_level.level_name||'''';
      bsc_aw_dbms_aw.execute(g_stmt);
    end if;
  end if;
  for i in 1..p_dim.parent_child.count loop
    l_flag(i):=false;
    if p_dim.parent_child(i).child_level=p_level and p_dim.parent_child(i).parent_level is not null then
      l_parent_level:=bsc_aw_adapter_kpi.get_dim_level_r(p_dim,p_dim.parent_child(i).parent_level);
      if l_parent_level.aggregated='Y' then
        l_flag(i):=true;
        g_stmt:='limit '||p_dim.level_name_dim||' add '''||p_dim.parent_child(i).parent_level||'.'||
        p_dim.parent_child(i).child_level||'''';
        bsc_aw_dbms_aw.execute(g_stmt);
      end if;
    end if;
  end loop;
  --rec do this for the parent levels
  for i in 1..p_dim.parent_child.count loop
    if l_flag(i) then
      limit_dim_levels(p_dim,p_dim.parent_child(i).parent_level);
    end if;
  end loop;
Exception when others then
  log_n('Exception in limit_dim_levels '||sqlerrm);
  raise;
End;

/*
limits the dim values to only the upper levels.
p_operator is "to" or "add"
*/
procedure limit_dim_ancestors(p_dim bsc_aw_adapter_kpi.dim_tb,p_operator varchar2) is
Begin
  --we cannot use if p_dim(i).levels.count> 1 and p_dim(i).relation_name is not null then
  --because rec dim only have 1 level. single level dim do not have relation_name
  --we use an api is_aggregation_on_dim that says if there is agg on a dim or not for this dimset
  --i think we should not use is_aggregation_on_dim here. if we are using only 1 level of a dim here,
  --we would have limited the level_name_dim before.
  for i in 1..p_dim.count loop
    if p_dim(i).relation_name is not null then
      g_stmt:='limit '||p_dim(i).dim_name||' '||p_operator||' ancestors using '||p_dim(i).relation_name;
      bsc_aw_dbms_aw.execute(g_stmt);
    end if;
  end loop;
Exception when others then
  log_n('Exception in limit_dim_ancestors '||sqlerrm);
  raise;
End;

procedure limit_dim_descendents(p_dim bsc_aw_adapter_kpi.dim_tb,p_operator varchar2,p_depth varchar2) is
Begin
  for i in 1..p_dim.count loop
    if p_dim(i).relation_name is not null then
      g_stmt:='limit '||p_dim(i).dim_name||' '||p_operator||' '||p_depth||' using '||p_dim(i).relation_name;
      bsc_aw_dbms_aw.execute(g_stmt);
    end if;
  end loop;
Exception when others then
  log_n('Exception in limit_dim_descendents '||sqlerrm);
  raise;
End;

/*
after aggregation, we reset the limit cubes. at this time, when the api is called,
the dim is limited to those values where the limit cube was TRUE
*/
procedure reset_dim_limit_cubes(p_dim bsc_aw_adapter_kpi.dim_tb) is
Begin
  for i in 1..p_dim.count loop
    g_stmt:=p_dim(i).limit_cube||'=FALSE';
    if p_dim(i).limit_cube_composite is not null then
      g_stmt:=g_stmt||' across '||p_dim(i).limit_cube_composite;
    end if;
    bsc_aw_dbms_aw.execute(g_stmt);
  end loop;
Exception when others then
  log_n('Exception in reset_dim_limit_cubes '||sqlerrm);
  raise;
End;

/*
limits the time values
*/
procedure limit_calendar_values(p_calendar bsc_aw_adapter_kpi.calendar_r,p_mode varchar2) is
Begin
  g_stmt:='limit '||p_calendar.aw_dim||' '||p_mode||' '||p_calendar.limit_cube;
  bsc_aw_dbms_aw.execute(g_stmt);
Exception when others then
  log_n('Exception in limit_calendar_values '||sqlerrm);
  raise;
End;

/*
this procedure limits the periodities to the ones applicable to the dim set for agg
*/
procedure limit_calendar_levels(p_calendar bsc_aw_adapter_kpi.calendar_r) is
Begin
  g_stmt:='limit '||p_calendar.level_name_dim||' to null';
  bsc_aw_dbms_aw.execute(g_stmt);
  --start the process. this procedure is called  rec for parent levels
  --start from the child and go all the way up
  for i in 1..p_calendar.periodicity.count loop
    if p_calendar.periodicity(i).lowest_level='Y' then
      limit_calendar_levels(p_calendar,p_calendar.periodicity(i).aw_dim);
    end if;
  end loop;
Exception when others then
  log_n('Exception in limit_calendar_levels '||sqlerrm);
  raise;
End;

/*
this procedure is called rec for the parent levels
*/
procedure limit_calendar_levels(
p_calendar bsc_aw_adapter_kpi.calendar_r,
p_periodicity_dim varchar2) is
--
l_flag bsc_aw_utility.boolean_table;
l_periodicity bsc_aw_adapter_kpi.periodicity_r;
Begin
  l_periodicity:=bsc_aw_adapter_kpi.get_periodicity_r(p_calendar.periodicity,p_periodicity_dim);
  if l_periodicity.aggregated='Y' then
    for i in 1..p_calendar.parent_child.count loop
      l_flag(i):=false;
      if p_calendar.parent_child(i).child_dim_name=p_periodicity_dim and p_calendar.parent_child(i).parent_dim_name is not null then
        l_periodicity:=bsc_aw_adapter_kpi.get_periodicity_r(p_calendar.periodicity,p_calendar.parent_child(i).parent_dim_name);
        if l_periodicity.aggregated='Y' then
          l_flag(i):=true;
          g_stmt:='limit '||p_calendar.level_name_dim||' add '''||p_calendar.parent_child(i).parent_dim_name||'.'||
          p_calendar.parent_child(i).child_dim_name||'''';
          bsc_aw_dbms_aw.execute(g_stmt);
        end if;
      end if;
    end loop;
    for i in 1..p_calendar.parent_child.count loop
      if l_flag(i) then
        limit_calendar_levels(p_calendar,p_calendar.parent_child(i).parent_dim_name);
      end if;
    end loop;
  end if;
Exception when others then
  log_n('Exception in limit_calendar_levels '||sqlerrm);
  raise;
End;

--limit the calendar vlues to the parents
--p_operator is "to" or "add"
procedure limit_calendar_ancestors(p_calendar bsc_aw_adapter_kpi.calendar_r,p_operator varchar2) is
Begin
  g_stmt:='limit '||p_calendar.aw_dim||' '||p_operator||' ancestors using '||p_calendar.relation_name;
  bsc_aw_dbms_aw.execute(g_stmt);
Exception when others then
  log_n('Exception in limit_calendar_ancestors '||sqlerrm);
  raise;
End;

procedure limit_calendar_descendents(p_calendar bsc_aw_adapter_kpi.calendar_r,p_operator varchar2,p_depth varchar2) is
Begin
  g_stmt:='limit '||p_calendar.aw_dim||' '||p_operator||' '||p_depth||' using '||p_calendar.relation_name;
  bsc_aw_dbms_aw.execute(g_stmt);
Exception when others then
  log_n('Exception in limit_calendar_descendents '||sqlerrm);
  raise;
End;

/*
reset the calendar limit cube after aggregation. at this time calendar is limited to those
values where the limit cube was TRUE
*/
procedure reset_calendar_limit_cubes(p_calendar bsc_aw_adapter_kpi.calendar_r) is
Begin
  g_stmt:=p_calendar.limit_cube||'=FALSE';
  if p_calendar.limit_cube_composite is not null then
    g_stmt:=g_stmt||' across '||p_calendar.limit_cube_composite;
  end if;
  bsc_aw_dbms_aw.execute(g_stmt);
Exception when others then
  log_n('Exception in reset_calendar_limit_cubes '||sqlerrm);
  raise;
End;

procedure set_aggregation(p_kpi varchar2,p_aggregation out nocopy aggregation_r) is
l_cache_aggregation_r aggregation_r;
Begin
  p_aggregation:=null;
  p_aggregation.kpi:=p_kpi;
  l_cache_aggregation_r:=get_cache_aggregation_r(p_kpi);
  if l_cache_aggregation_r.kpi is null then
    bsc_aw_md_api.get_aggregation_r(p_aggregation);
    get_forecast_current_period(p_aggregation);
    dmp_aggregation_r(p_aggregation);
    g_cache_aggregation_r(g_cache_aggregation_r.count+1):=p_aggregation;
  else
    p_aggregation:=l_cache_aggregation_r;
  end if;
Exception when others then
  log_n('Exception in set_aggregation '||sqlerrm);
  raise;
End;

procedure dmp_aggregation_r(p_aggregation aggregation_r) is
Begin
  log_n('Dmp Aggregation:- KPI='||p_aggregation.kpi);
  for i in 1..p_aggregation.dim_set.count loop
    bsc_aw_adapter_kpi.dmp_dimset(p_aggregation.dim_set(i));
  end loop;
Exception when others then
  log_n('Exception in dmp_aggregation_r '||sqlerrm);
  raise;
End;

procedure push_dim(p_dim bsc_aw_adapter_kpi.dim_tb) is
Begin
  for i in 1..p_dim.count loop
    push_dim(p_dim(i).dim_name);
  end loop;
Exception when others then
  log_n('Exception in push_dim '||sqlerrm);
  raise;
End;

procedure push_dim(p_dim varchar2) is
Begin
  bsc_aw_dbms_aw.execute('push '||p_dim);
Exception when others then
  log_n('Exception in push_dim '||sqlerrm);
  raise;
End;

procedure pop_dim(p_dim bsc_aw_adapter_kpi.dim_tb) is
Begin
  for i in 1..p_dim.count loop
    pop_dim(p_dim(i).dim_name);
  end loop;
Exception when others then
  log_n('Exception in pop_dim '||sqlerrm);
  raise;
End;

procedure pop_dim(p_dim varchar2) is
Begin
  bsc_aw_dbms_aw.execute('pop '||p_dim);
Exception when others then
  log_n('Exception in pop_dim '||sqlerrm);
  raise;
End;

/*
during aggregation, we set the status of various dimensions. we want to be able to restore the
status of the dim back to the level before the agg. otherwise it becomes hard to track the dim
status from api to api

in push level, we must use context. the reason is that pushlevel command in aw can be used only within programs
" You can use PUSHLEVEL only within programs"

For now, not used.
*/
procedure push_level(p_marker varchar2) is
Begin
  null;
Exception when others then
  log_n('Exception in push_level '||sqlerrm);
  raise;
End;

procedure pop_level(p_marker varchar2) is
Begin
  null;
Exception when others then
  log_n('Exception in pop_level '||sqlerrm);
  raise;
End;

/*
this procedure purges the kpi. i
*/
procedure purge_kpi(p_kpi varchar2) is
--
l_bsc_olap_object bsc_aw_md_wrapper.bsc_olap_object_tb;
Begin
  if g_debug then
    log_n('Purge KPI '||p_kpi);
  end if;
  --for purge, we need exclusive lock. else we cannot delete composites
  bsc_aw_management.get_workspace_lock('rw',null);
  bsc_aw_md_api.get_bsc_olap_object(null,null,p_kpi,'kpi',l_bsc_olap_object);
  --clear the cubes
  for i in 1..l_bsc_olap_object.count loop
    if l_bsc_olap_object(i).object_type='data cube' then
      bsc_aw_dbms_aw.execute('clear all from '||l_bsc_olap_object(i).olap_object);
    end if;
  end loop;
  --clear fcst cubes if there are any
  --clear the limit cubes
  for i in 1..l_bsc_olap_object.count loop
    if l_bsc_olap_object(i).object_type='dim limit cube' then
      bsc_aw_dbms_aw.execute('clear all from '||l_bsc_olap_object(i).olap_object);
    end if;
  end loop;
  for i in 1..l_bsc_olap_object.count loop
    if l_bsc_olap_object(i).object_type='limit cube composite' then
      bsc_aw_dbms_aw.execute('maintain '||l_bsc_olap_object(i).olap_object||' delete all');
    end if;
  end loop;
  --clear the countvar cubes
  for i in 1..l_bsc_olap_object.count loop
    if l_bsc_olap_object(i).object_type='countvar cube' then
      bsc_aw_dbms_aw.execute('clear all from '||l_bsc_olap_object(i).olap_object);
    end if;
  end loop;
  --clear the composites
  for i in 1..l_bsc_olap_object.count loop
    if l_bsc_olap_object(i).object_type='measure composite' then
      bsc_aw_dbms_aw.execute('maintain '||l_bsc_olap_object(i).olap_object||' delete all');
    end if;
  end loop;
  --set the dimset current change vector to 0 for all dimsets of the kpi
  reset_dimset_change_vector(p_kpi);
  --
  bsc_aw_management.commit_aw;
  commit;
Exception when others then
  log_n('Exception in purge_kpi '||sqlerrm);
  raise;
End;

procedure get_dimset_objects(p_kpi varchar2,p_dim_set varchar2,p_oo out nocopy bsc_aw_md_wrapper.bsc_olap_object_tb) is
l_oo_kpi bsc_aw_md_wrapper.bsc_olap_object_tb;
Begin
  bsc_aw_md_api.get_bsc_olap_object(null,null,p_kpi,'kpi',l_oo_kpi);
  for i in 1..l_oo_kpi.count loop
    if bsc_aw_utility.get_parameter_value(l_oo_kpi(i).property1,'dim set name',',')=p_dim_set then
      p_oo(p_oo.count+1):=l_oo_kpi(i);
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_dimset_objects '||sqlerrm);
  raise;
End;

/*
this will set the current change vector to 0. called from purge_kpi
*/
procedure reset_dimset_change_vector(p_kpi varchar2) is
l_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
l_property varchar2(4000);
Begin
  bsc_aw_md_api.get_bsc_olap_object_relation(null,null,'base table dim set',p_kpi,'kpi',l_olap_object_relation);
  for i in 1..l_olap_object_relation.count loop
    --we must not lose the measures=m1,m2, from the property of base table dim set after we reset the change vector
    l_property:=l_olap_object_relation(i).property1;
    bsc_aw_utility.update_property(l_property,'current change vector','0',',');
    bsc_aw_md_api.update_olap_object_relation(l_olap_object_relation(i).object,l_olap_object_relation(i).object_type,
    l_olap_object_relation(i).relation_type,l_olap_object_relation(i).parent_object,l_olap_object_relation(i).parent_object_type,
    'relation_object,relation_object_type',l_olap_object_relation(i).relation_object||','||l_olap_object_relation(i).relation_object_type,
    'property1',l_property);
  end loop;
Exception when others then
  log_n('Exception in reset_dimset_change_vector '||sqlerrm);
  raise;
End;

--limit the measuredim to the measures that we are going to aggregate
procedure limit_measure_dim(
p_aggmap_operator bsc_aw_adapter_kpi.aggmap_operator_r,
p_cubes dbms_sql.varchar2_table,
p_partition_value varchar2
) is
Begin
  bsc_aw_dbms_aw.execute('limit '||p_aggmap_operator.measure_dim||' to NULL');
  for i in 1..p_cubes.count loop
    if p_partition_value is not null then
      bsc_aw_dbms_aw.execute('limit '||p_aggmap_operator.measure_dim||' add '''||p_cubes(i)||' (PARTITION '||p_partition_value||')''');
    else
      bsc_aw_dbms_aw.execute('limit '||p_aggmap_operator.measure_dim||' add '''||p_cubes(i)||'''');
    end if;
  end loop;
Exception when others then
  log_n('Exception in limit_measure_dim '||sqlerrm);
  raise;
End;

procedure reset_dim_limits(p_dim_set bsc_aw_adapter_kpi.dim_set_r) is
Begin
  --now, we reset the limit cubes
  --in 10g, we call these 2 api to after all the threads have completed
  --set status to allstat in reset_dim_limits. in 10g parallelism, the dim status here is not what we need.
  --so best to set the status to allstat
  bsc_aw_dbms_aw.execute('allstat');
  reset_dim_limit_cubes(p_dim_set.dim);
  reset_dim_limit_cubes(p_dim_set.std_dim);
  reset_calendar_limit_cubes(p_dim_set.calendar);
Exception when others then
  log_n('Exception in reset_dim_limits '||sqlerrm);
  raise;
End;

/*
this procedure limits the dim to the lowest level of targets. say target is at state level.
say geog is at city, state and vountry level. when this procedure executes, geog is
limited to "KEEP" state
p_actual_dim_set and p_target_dim_set will be related actual and target dim sets
*/
procedure limit_dim_target_level_only(
p_actual_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_target_dim_set bsc_aw_adapter_kpi.dim_set_r
) is
Begin
  for i in 1..p_actual_dim_set.dim.count loop
    for j in 1..p_target_dim_set.dim.count loop
      if p_target_dim_set.dim(j).dim_name=p_actual_dim_set.dim(i).dim_name then
        /*
        This is critical...if p_actual_dim_set.dim(i).levels.count>1 then
        encountered the issue when we did the change for handling hanging parent values. ie initial hier:
          A     C       changing to    A     C
          a    b  d                         a b d
        in this case the value for A in the cubes must be reset to 0. during this time,it was found that when we limit
        a concat dim to its level, when the concat had only 1 level, limited the value of the dim to the first value in
        the status. release dim had values 0,1,2 in status. then "KEEP" made the value of the concat dim just 0. this meant
        that the copy from the target to the actual did not happen and the values in the cube for targets were nulled out.
        they get nulled out before this during the actual agg. the copy is supposed to restore the value and then the
        subsequent agg will correct the higher level rollup for targets. if the copy does not happen, data is messed up for targets
        we keep the level if this is a normal dom with more than 1 level or if this is a rec dim implemented with denorm hier
        */
        if p_actual_dim_set.dim(i).levels.count>1 or
        (p_actual_dim_set.dim(i).recursive='Y' and p_actual_dim_set.dim(i).recursive_norm_hier='N') then
          limit_dim(p_actual_dim_set.dim(i).dim_name,p_target_dim_set.dim(j).levels(1).level_name,'KEEP');
        end if;
        exit;
      end if;
    end loop;
  end loop;
Exception when others then
  log_n('Exception in limit_dim_target_level_only '||sqlerrm);
  raise;
End;

procedure limit_cal_target_level_only(
p_actual_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_target_dim_set bsc_aw_adapter_kpi.dim_set_r
) is
Begin
  --calendar
  --remove all levels that are not the lowest level
  for i in 1..p_target_dim_set.calendar.periodicity.count loop
    if p_target_dim_set.calendar.periodicity(i).lowest_level='Y' then
      limit_dim(p_target_dim_set.calendar.periodicity(i).aw_dim,p_actual_dim_set.calendar.aw_dim,'TO');
    end if;
  end loop;
  limit_dim(p_actual_dim_set.calendar.aw_dim,'NULL','TO');
  for i in 1..p_target_dim_set.calendar.periodicity.count loop
    if p_target_dim_set.calendar.periodicity(i).lowest_level='Y' then
      limit_dim(p_actual_dim_set.calendar.aw_dim,p_target_dim_set.calendar.periodicity(i).aw_dim,'ADD');
    end if;
  end loop;
Exception when others then
  log_n('Exception in limit_cal_target_level_only '||sqlerrm);
  raise;
End;

/*
this procedure sets the limit cubes of dimensions to the value , if a composite is specified, it loops
across it. used in aggregate_kpi_dimset_targets
--
earlier, we passed p_composite_name varchar2 as a parameter. this used to be p_target_dim_set.measure(1).composite_name
but, each limit cube has its own composite. so its best to limit the limit cube to its own composite.
9i and 10g, both have limit cube composite. N: limit cube composite has values only for the level at which data
is loaded. but this is ok since we do not aggregate target cubes
*/
procedure limit_dim_limit_cube(
p_dim bsc_aw_adapter_kpi.dim_tb,
p_value varchar2
) is
Begin
  for i in 1..p_dim.count loop
    limit_dim_limit_cube(p_dim(i).limit_cube,p_value,p_dim(i).limit_cube_composite);
  end loop;
Exception when others then
  log_n('Exception in limit_dim_limit_cube '||sqlerrm);
  raise;
End;

--have to specify p_composite_name. limit cubes use named composites
procedure limit_dim_limit_cube(
p_limit_cube varchar2,
p_value varchar2,
p_composite_name varchar2
) is
Begin
  g_stmt:=p_limit_cube||'='||p_value;
  if p_composite_name is not null then
    g_stmt:=g_stmt||' across '||p_composite_name;
  end if;
  bsc_aw_dbms_aw.execute(g_stmt);
Exception when others then
  log_n('Exception in limit_dim_limit_cube '||sqlerrm);
  raise;
End;

function get_projection_dim(p_dim_set bsc_aw_adapter_kpi.dim_set_r) return varchar2 is
Begin
  return bsc_aw_adapter_kpi.get_projection_dim(p_dim_set);
Exception when others then
  log_n('Exception in get_projection_dim '||sqlerrm);
  raise;
End;

/*
this function sees if agg is implemented on a dim. if this is a non rec dim and there is only 1 level and no zero code,
there is no agg on it
*/
function is_aggregation_on_dim(p_dim bsc_aw_adapter_kpi.dim_r) return boolean is
Begin
  if p_dim.recursive='N' and p_dim.levels.count=1 then
    if p_dim.levels(1).zero_code='Y' then
      return true;
    else
      return false;
    end if;
  else
    return true;
  end if;
Exception when others then
  log_n('Exception in is_aggregation_on_dim '||sqlerrm);
  raise;
End;

/*
this procedure sees if there is agg on calendar.
looks to see if there is more than 1 periodicity
*/
function is_aggregation_on_time(p_calendar bsc_aw_adapter_kpi.calendar_r) return boolean is
Begin
  if p_calendar.periodicity.count>1 then
    return true;
  else
    return false;
  end if;
Exception when others then
  log_n('Exception in is_aggregation_on_time '||sqlerrm);
  raise;
End;

/*
given a dim table and a dim, returns the index of where the dim was found
*/
function get_dim_index(
p_dim bsc_aw_adapter_kpi.dim_tb,
p_dim_name varchar2
)return number is
Begin
  for i in 1..p_dim.count loop
    if p_dim(i).dim_name=p_dim_name then
      return i;
    end if;
  end loop;
  return null;
Exception when others then
  log_n('Exception in get_dim_index '||sqlerrm);
  raise;
End;

/*
given a table of measure and a measure name, returns the index where it occured
*/
function get_measure_index(
p_measure bsc_aw_adapter_kpi.measure_tb,
p_measure_name varchar2
)return number is
Begin
  for i in 1..p_measure.count loop
    if p_measure(i).measure=p_measure_name then
      return i;
    end if;
  end loop;
  return null;
Exception when others then
  log_n('Exception in get_measure_index '||sqlerrm);
  raise;
End;

/*
when we use compressed composites, we cannot limit the dim values that make up the composite.
we can limit the levels of the relation. its important to do so since we can have a kpi at the month level. without limiting
the levels, aggregation will start from day. this means aggregate values will all be null
*/
procedure limit_all_dim(p_dim_set bsc_aw_adapter_kpi.dim_set_r) is
Begin
  if p_dim_set.compressed='N' then
    limit_dim_values(p_dim_set.dim,'to');
    limit_dim_values(p_dim_set.std_dim,'to');
    limit_calendar_values(p_dim_set.calendar,'to');
  end if;
  limit_dim_levels(p_dim_set.dim); --l_aggregation.dim has the agg_level in it
  limit_calendar_levels(p_dim_set.calendar);--limit the periodicities
Exception when others then
  log_n('Exception in limit_all_dim '||sqlerrm);
  raise;
End;

/*
calendar is getting special treatment compared to other dim. we do not load other dim when we load kpi.
we need to handle the case where a user has already bsc implemented. they make no changes to their calendars. in this case,
we need to create and load the calendars. its best if we load the calendar here
*/
procedure load_calendar_if_needed(p_kpi varchar2) is
--
l_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
l_calendar number;
l_lock_name varchar2(40);
Begin
  bsc_aw_md_api.get_bsc_olap_object_relation(null,null,null,p_kpi,'kpi',l_olap_object_relation);
  for i in 1..l_olap_object_relation.count loop
    if l_olap_object_relation(i).relation_type='dim set calendar' then
      l_calendar:=to_number(bsc_aw_utility.get_parameter_value(l_olap_object_relation(i).property1,'calendar',','));
      exit;
    end if;
  end loop;
  l_lock_name:='lock_aw_calendar_'||l_calendar;
  if l_calendar is not null then
    --serialize access
    bsc_aw_utility.get_db_lock(l_lock_name);
    if bsc_aw_calendar.check_calendar_loaded(l_calendar)='N' then
      --get lock for calendar
      bsc_aw_calendar.lock_calendar_objects(l_calendar);
      bsc_aw_calendar.load_calendar(l_calendar);
      bsc_aw_management.commit_aw;
      commit;
    end if;
    bsc_aw_utility.release_db_lock(l_lock_name);
  else
    log_n('Could not locate kpi calendar in load_calendar_if_needed');
  end if;
Exception when others then
  bsc_aw_utility.release_db_lock(l_lock_name);
  log_n('Exception in load_calendar_if_needed '||sqlerrm);
  raise;
End;

/*enh needed to load dim on demand. two scenarios. aw kpi created fresh. aw dim are empty. case II view based dim.
*/
procedure load_dim_if_needed(p_kpi varchar2,p_dim_set dbms_sql.varchar2_table) is
l_oor bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
l_dim dbms_sql.varchar2_table;
Begin
  bsc_aw_md_api.get_bsc_olap_object_relation(null,null,null,p_kpi,'kpi',l_oor);
  for i in 1..l_oor.count loop
    if l_oor(i).object_type='kpi dimension set' and (l_oor(i).relation_type='dim set dim' or l_oor(i).relation_type='dim set std dim')
    and l_oor(i).relation_object_type='dimension' then
      if bsc_aw_utility.in_array(p_dim_set,l_oor(i).object) then
        bsc_aw_utility.merge_value(l_dim,l_oor(i).relation_object);
      end if;
    end if;
  end loop;
  --
  bsc_aw_load_dim.load_dim_if_needed(l_dim);
  --
Exception when others then
  log_n('Exception in load_dim_if_needed '||sqlerrm);
  raise;
End;

procedure dmp_kpi_cubes_into_table(
p_kpi varchar2,
p_dimset varchar2,
p_dim_levels dbms_sql.varchar2_table,
p_table_name varchar2) is
--
l_name varchar2(200);
Begin
  l_name:='dmp_kpi_'||p_kpi||'_'||p_dimset;
  bsc_aw_dbms_aw.execute_ne('delete '||l_name);
  bsc_aw_adapter_kpi.create_dmp_program(p_kpi,p_dimset,p_dim_levels,l_name,p_table_name);
  bsc_aw_dbms_aw.execute('call '||l_name);
  bsc_aw_dbms_aw.execute('delete '||l_name);
Exception when others then
  log_n('Exception in dmp_kpi_cubes_into_table '||sqlerrm);
  raise;
End;

/*
pass a kpi. this will loop over all dimset, all dim and levels. it eill create tables
as p_table_name||dimset||1,2 etc. then these table names will be returned in p_tables
*/
procedure dmp_kpi_cubes_into_table(
p_kpi varchar2,
p_table_name varchar2,
p_tables out nocopy dbms_sql.varchar2_table
) is
--
l_oo_dimset bsc_aw_md_wrapper.bsc_olap_object_tb;
l_oo_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
l_dimset varchar2(100);
l_dimset_name varchar2(200);
l_combinations dbms_sql.varchar2_table;
l_combinations_copy dbms_sql.varchar2_table;
l_dimensions dbms_sql.varchar2_table;
l_levels dbms_sql.varchar2_table;
l_values bsc_aw_utility.value_tb;
l_count number;
Begin
  bsc_aw_md_api.get_kpi_dimset_actual(p_kpi,l_oo_dimset);
  --loop across the dimset
  for i in 1..l_oo_dimset.count loop
    l_dimset:=bsc_aw_utility.get_parameter_value(l_oo_dimset(i).property1,'dim set',',');
    l_dimset_name:=l_oo_dimset(i).object;
    l_count:=0;
    --get the dim
    l_combinations.delete;
    l_dimensions.delete;
    --
    l_oo_relation.delete;
    bsc_aw_md_api.get_bsc_olap_object_relation(l_dimset_name,'kpi dimension set','dim set dim',p_kpi,'kpi',l_oo_relation);
    for j in 1..l_oo_relation.count loop
      l_dimensions(l_dimensions.count+1):=l_oo_relation(j).relation_object;
    end loop;
    l_oo_relation.delete;
    bsc_aw_md_api.get_bsc_olap_object_relation(l_dimset_name,'kpi dimension set','dim set std dim',p_kpi,'kpi',l_oo_relation);
    for j in 1..l_oo_relation.count loop
      l_dimensions(l_dimensions.count+1):=l_oo_relation(j).relation_object;
    end loop;
    l_oo_relation.delete;
    bsc_aw_md_api.get_bsc_olap_object_relation(null,null,'dim set dim level',p_kpi,'kpi',l_oo_relation);
    --loop over each dim
    for j in 1..l_dimensions.count loop
      l_levels.delete;
      for k in 1..l_oo_relation.count loop
        if l_oo_relation(k).object=l_dimensions(j)||'+'||l_dimset_name then
          l_levels(l_levels.count+1):=l_oo_relation(k).relation_object;
        end if;
      end loop;
      --
      if l_combinations.count=0 then
        --add the levels to the combinations
        for k in 1..l_levels.count loop
          l_combinations(l_combinations.count+1):=l_levels(k);
        end loop;
      else
        l_combinations_copy.delete;
        l_combinations_copy:=l_combinations;
        --now cartesian
        for k in 1..l_levels.count loop
          for m in 1..l_combinations_copy.count loop
            l_combinations(l_combinations.count+1):=l_combinations_copy(m)||','||l_levels(k);
          end loop;
        end loop;
      end if;
    end loop;
    --
    for j in 1..l_combinations.count loop
      l_levels.delete;
      l_values.delete;
      bsc_aw_utility.parse_parameter_values(l_combinations(j),',',l_values);
      for k in 1..l_values.count loop
        l_levels(l_levels.count+1):=l_values(k).parameter;
      end loop;
      if l_levels.count=l_dimensions.count then
        --each combination is a table
        l_count:=l_count+1;
        p_tables(p_tables.count+1):=p_table_name||'_'||l_dimset||'_'||l_count;
        dmp_kpi_cubes_into_table(p_kpi,l_dimset,l_levels,p_tables(p_tables.count));
        p_tables(p_tables.count):=p_tables(p_tables.count)||' ('||l_dimset_name||')-> '||l_combinations(j);
      end if;
    end loop;
  end loop;
Exception when others then
  log_n('Exception in dmp_kpi_cubes_into_table '||sqlerrm);
  raise;
End;

/*p_dimset of null means all dimsets
null p_object_type means any object
p_lock_type of inc means do not call bsc_aw_management.get_workspace_lock(). get_workspace_lock will do g_lockec_objects.delete
it refreshes the internal info on current locked objects.
inc means only go for additional locks.let the existing locks remain as they are
*/
procedure lock_dimset_objects(p_kpi varchar2,p_dimset varchar2,p_object_type varchar2,p_lock_type varchar2) is
--
l_lock_objects dbms_sql.varchar2_table;
Begin
  get_dimset_objects_to_lock(p_kpi,p_dimset,p_object_type,l_lock_objects);
  if p_lock_type='inc' then
    bsc_aw_management.get_lock(l_lock_objects,null);
  else
    bsc_aw_management.get_workspace_lock(l_lock_objects,null);
  end if;
Exception when others then
  log_n('Exception in lock_dimset_objects '||sqlerrm);
  raise;
End;

procedure get_dimset_objects_to_lock(
p_kpi varchar2,
p_dimset varchar2,
p_object_type varchar2,
p_lock_objects out nocopy dbms_sql.varchar2_table) is
l_bsc_olap_object bsc_aw_md_wrapper.bsc_olap_object_tb;
l_objects dbms_sql.varchar2_table;
Begin
  bsc_aw_md_api.get_bsc_olap_object(null,null,p_kpi,'kpi',l_bsc_olap_object);
  for i in 1..l_bsc_olap_object.count loop
    if l_bsc_olap_object(i).olap_object_type='dimension' and l_bsc_olap_object(i).object_type<>'agg map measure dim'
    and l_bsc_olap_object(i).object_type<>'measurename dim' and
    (p_dimset is null or bsc_aw_utility.get_parameter_value(l_bsc_olap_object(i).property1,'dim set name',',')=p_dimset) and
    (p_object_type is null or nvl(bsc_aw_utility.get_parameter_value(p_object_type,l_bsc_olap_object(i).object_type,','),'N')='Y') then
      l_objects(l_objects.count+1):=l_bsc_olap_object(i).olap_object;
    end if;
  end loop;
  for i in 1..l_bsc_olap_object.count loop
    if l_bsc_olap_object(i).olap_object_type='cube' and
    (p_dimset is null or bsc_aw_utility.get_parameter_value(l_bsc_olap_object(i).property1,'dim set name',',')=p_dimset) and
    (p_object_type is null or nvl(bsc_aw_utility.get_parameter_value(p_object_type,l_bsc_olap_object(i).object_type,','),'N')='Y') then
      l_objects(l_objects.count+1):=l_bsc_olap_object(i).olap_object;
    end if;
  end loop;
  for i in 1..l_bsc_olap_object.count loop
    if l_bsc_olap_object(i).olap_object_type='variable' and
    (p_dimset is null or bsc_aw_utility.get_parameter_value(l_bsc_olap_object(i).property1,'dim set name',',')=p_dimset) and
    (p_object_type is null or nvl(bsc_aw_utility.get_parameter_value(p_object_type,l_bsc_olap_object(i).object_type,','),'N')='Y') then
      l_objects(l_objects.count+1):=l_bsc_olap_object(i).olap_object;
    end if;
  end loop;
  --
  for i in 1..l_objects.count loop
    if bsc_aw_utility.in_array(p_lock_objects,l_objects(i))=false then
      p_lock_objects(p_lock_objects.count+1):=l_objects(i);
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_dimset_objects_to_lock '||sqlerrm);
  raise;
End;

/*
given a base table list, get the list of dimsets
p_base_table_list may not be a part of the kpi.
in that case l_oor_dimset.count will be 0
*/
procedure get_dimset_for_base_table(
p_kpi varchar2,
p_base_table_list dbms_sql.varchar2_table,
p_dim_set out nocopy dbms_sql.varchar2_table
) is
--
l_oor_dimset bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
Begin
  for i in 1..p_base_table_list.count loop
    l_oor_dimset.delete;
    bsc_aw_md_api.get_base_table_dimset(p_kpi,p_base_table_list(i),'base table dim set',l_oor_dimset);
    for j in 1..l_oor_dimset.count loop
      if bsc_aw_utility.in_array(p_dim_set,l_oor_dimset(j).relation_object)=false then
        p_dim_set(p_dim_set.count+1):=l_oor_dimset(j).relation_object;
      end if;
    end loop;
  end loop;
Exception when others then
  log_n('Exception in get_dimset_for_base_table '||sqlerrm);
  raise;
End;

/*given a set of dimsets and B tables, finds out the list of B tables from p_base_table_list that belong to the dimset */
procedure get_base_table_for_dimset(p_kpi varchar2,p_base_table_list dbms_sql.varchar2_table,p_dim_set dbms_sql.varchar2_table,
p_dimset_base_tables out nocopy dbms_sql.varchar2_table) is
l_oor bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
Begin
  for i in 1..p_dim_set.count loop
    l_oor.delete;
    bsc_aw_md_api.get_dimset_base_table(p_kpi,p_dim_set(i),'base table dim set',l_oor);
    for j in 1..l_oor.count loop
      if p_base_table_list.count=0 or bsc_aw_utility.in_array(p_base_table_list,l_oor(j).object) then
        bsc_aw_utility.merge_value(p_dimset_base_tables,l_oor(j).object);
      end if;
    end loop;
  end loop;
Exception when others then
  log_n('Exception in get_base_table_for_dimset '||sqlerrm);
  raise;
End;

/*
we have this procedure so we can eliminate all base tables that are not part of the kpi
p_base_table_list will have all the base tables.
*/
procedure get_kpi_base_tables(
p_kpi varchar2,
p_base_table_list dbms_sql.varchar2_table,
p_kpi_base_tables out nocopy dbms_sql.varchar2_table
) is
--
l_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
l_base_table varchar2(100);
Begin
  bsc_aw_md_api.get_bsc_olap_object_relation(null,null,'base table dim set',p_kpi,'kpi',l_olap_object_relation);
  for i in 1..l_olap_object_relation.count loop
    l_base_table:=null;
    if p_base_table_list.count>0 then
      if bsc_aw_utility.in_array(p_base_table_list,l_olap_object_relation(i).object) then
        l_base_table:=l_olap_object_relation(i).object;
      end if;
    else
      l_base_table:=l_olap_object_relation(i).object;
    end if;
    if l_base_table is not null and bsc_aw_utility.in_array(p_kpi_base_tables,l_base_table)=false then
      p_kpi_base_tables(p_kpi_base_tables.count+1):=l_base_table;
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_kpi_base_tables '||sqlerrm);
  raise;
End;

function get_cache_aggregation_r(p_kpi varchar2) return aggregation_r is
Begin
  for i in 1..g_cache_aggregation_r.count loop
    if g_cache_aggregation_r(i).kpi=p_kpi then
      return g_cache_aggregation_r(i);
    end if;
  end loop;
  return null;
Exception when others then
  log_n('Exception in get_cache_aggregation_r '||sqlerrm);
  raise;
End;

function get_dim_set_index(p_aggregation aggregation_r,p_dim_set varchar2) return number is
Begin
  for i in 1..p_aggregation.dim_set.count loop
    if p_aggregation.dim_set(i).dim_set_name=p_dim_set then
      return i;
    end if;
  end loop;
  log_n('Could not locate dimset '||p_dim_set||' in kpi ');
  raise bsc_aw_utility.g_exception;
Exception when others then
  log_n('Exception in get_dim_set_index '||sqlerrm);
  raise;
End;

/*
used by aggregate_measure in dbms job mode to get the locks on the cubes given the measures
we return
cube of the measure
N: in the case of partitions, we make the assumption that the objects returned from this api can lock the same
partition with the same name. example cube(partition P0) and countvarcube(partition P0). P0 can belong to diff PT
(compressed)
*/
procedure get_measure_objects_to_lock(
p_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_measures dbms_sql.varchar2_table,
p_lock_objects out nocopy dbms_sql.varchar2_table
) is
Begin
  for i in 1..p_dim_set.measure.count loop
    if bsc_aw_utility.in_array(p_measures,p_dim_set.measure(i).measure) then
      if p_dim_set.measure(i).cube is not null then
        if bsc_aw_utility.in_array(p_lock_objects,p_dim_set.measure(i).cube)=false then
          p_lock_objects(p_lock_objects.count+1):=p_dim_set.measure(i).cube;
        end if;
      end if;
      if p_dim_set.measure(i).countvar_cube is not null then
        if bsc_aw_utility.in_array(p_lock_objects,p_dim_set.measure(i).countvar_cube)=false then
          p_lock_objects(p_lock_objects.count+1):=p_dim_set.measure(i).countvar_cube;
        end if;
      end if;
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_measure_objects_to_lock '||sqlerrm);
  raise;
End;

--overloaded. first find dim_set_r, then call get_measure_objects_to_lock
procedure get_measure_objects_to_lock(
p_kpi varchar2,
p_dimset varchar2,
p_measures dbms_sql.varchar2_table,
p_lock_objects out nocopy dbms_sql.varchar2_table
) is
--
l_aggregation aggregation_r;
l_index number;
Begin
  set_aggregation(p_kpi,l_aggregation);
  l_index:=get_dim_set_index(l_aggregation,p_dimset);
  if l_index is null then
    log_n('Could not find dimset '||p_dimset||', kpi '||p_kpi||' in aggregation_r. Fatal!');
    raise bsc_aw_utility.g_exception;
  end if;
  get_measure_objects_to_lock(l_aggregation.dim_set(l_index),p_measures,p_lock_objects);
Exception when others then
  log_n('Exception in get_measure_objects_to_lock '||sqlerrm);
  raise;
End;

procedure insert_bsc_aw_temp_cv(p_min_value number,p_max_value number,p_base_table varchar2) is
l_stmt varchar2(3000);
Begin
  l_stmt:='insert into bsc_aw_temp_cv(change_vector_min_value,change_vector_max_value,change_vector_base_table) values(:1,:2,:3)';
  if g_debug then
    log(l_stmt||' using '||p_min_value||','||p_max_value||','||p_base_table);
  end if;
  execute immediate l_stmt using p_min_value,p_max_value,p_base_table;
Exception when others then
  log_n('Exception in insert_bsc_aw_temp_cv '||sqlerrm);
  raise;
End;

/*
we will look at how many cubes are involved and whether partitions are involved
*/
function can_launch_jobs(p_kpi varchar2,p_dimset bsc_aw_adapter_kpi.dim_set_r,p_measures dbms_sql.varchar2_table) return varchar2 is
l_cubes dbms_sql.varchar2_table;
l_pt_comp varchar2(200);
l_pt_comp_type varchar2(200);
l_number_jobs number;
l_cube_set bsc_aw_adapter_kpi.cube_set_r;
Begin
  if p_dimset.cube_design='single composite' then
    return 'N';
  else
    /*for the measures, get cubes. for the cubes get pt comps. we can parallelize for each distinct pt comp */
    for i in 1..p_measures.count loop
      l_cube_set:=bsc_aw_adapter_kpi.get_cube_set_for_measure(p_measures(i),p_dimset);
      if bsc_aw_utility.in_array(l_cubes,l_cube_set.cube.cube_name)=false then
        l_cubes(l_cubes.count+1):=l_cube_set.cube.cube_name;
      end if;
    end loop;
    l_number_jobs:=0;
    bsc_aw_utility.init_is_new_value(1);
    for i in 1..l_cubes.count loop
      l_pt_comp:=bsc_aw_adapter_kpi.get_cube_pt_comp(l_cubes(i),p_dimset,l_pt_comp_type);
      if l_pt_comp is not null then
        if bsc_aw_utility.is_new_value(l_pt_comp,1) then
          l_number_jobs:=l_number_jobs+1;
        end if;
      end if;
      if p_dimset.number_partitions>0 then
        l_number_jobs:=l_number_jobs*p_dimset.number_partitions;
      end if;
    end loop;
    return bsc_aw_utility.can_launch_jobs(l_number_jobs);
  end if;
Exception when others then
  log_n('Exception in can_launch_jobs '||sqlerrm);
  raise;
End;

procedure get_cubes_for_measures(
p_measures dbms_sql.varchar2_table,
p_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_cubes out nocopy dbms_sql.varchar2_table) is
l_cube_set bsc_aw_adapter_kpi.cube_set_r;
Begin
  for i in 1..p_measures.count loop
    l_cube_set:=bsc_aw_adapter_kpi.get_cube_set_for_measure(p_measures(i),p_dim_set);
    if bsc_aw_utility.in_array(p_cubes,l_cube_set.cube.cube_name)=false then
      p_cubes(p_cubes.count+1):=l_cube_set.cube.cube_name;
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_cubes_for_measures '||sqlerrm);
  raise;
End;

procedure dmp_dimset_dim_statlen(p_dim_set bsc_aw_adapter_kpi.dim_set_r) is
l_val varchar2(2000);
Begin
  for i in 1..p_dim_set.dim.count loop
    l_val:=bsc_aw_dbms_aw.interp('show statlen('||p_dim_set.dim(i).dim_name||')');
  end loop;
  for i in 1..p_dim_set.std_dim.count loop
    l_val:=bsc_aw_dbms_aw.interp('show statlen('||p_dim_set.std_dim(i).dim_name||')');
  end loop;
  l_val:=bsc_aw_dbms_aw.interp('show statlen('||p_dim_set.calendar.aw_dim||')');
Exception when others then
  log_n('Exception in dmp_dimset_dim_statlen '||sqlerrm);
  raise;
End;

/*
given a list of base tables and the load program, api decides how many times to call the load program and what B table parameters to
pass. if the DS has these entries : DS=B1+B2+B3+B1^B2^B3 then if the B tables to load are B2,B1 and B3, we will use B1,B2,B3 parameter
the DS tables are stored in sorted order.
*/
procedure get_ds_BT_parameters(
p_kpi varchar2,
p_dimset varchar2,
p_load_program varchar2,
p_b_tables dbms_sql.varchar2_table,
p_ds_parameters out nocopy dbms_sql.varchar2_table) is
--
l_bt_string varchar2(4000);
l_oo bsc_aw_md_wrapper.bsc_olap_object_tb;
l_ds_parameters dbms_sql.varchar2_table;
l_ds_tables dbms_sql.varchar2_table;
l_flag boolean;
l_bt_flag dbms_sql.varchar2_table;
Begin
  l_bt_string:=bsc_aw_utility.make_string_from_list(bsc_aw_utility.order_array(p_b_tables));
  --
  bsc_aw_md_api.get_bsc_olap_object(p_load_program,'dml program',p_kpi,'kpi',l_oo);
  bsc_aw_utility.parse_parameter_values(bsc_aw_utility.get_parameter_value(l_oo(1).property1,'DS',','),'+',l_ds_parameters);
  for i in 1..l_ds_parameters.count loop
    l_ds_parameters(i):=replace(l_ds_parameters(i),'^',',');
  end loop;
  if g_debug then
    log('For load program '||p_load_program||', DS Parameters found');
    for i in 1..l_ds_parameters.count loop
      log(l_ds_parameters(i));
    end loop;
    log('BT string='||l_bt_string);
  end if;
  --
  if l_ds_parameters.count=0 then
    p_ds_parameters(p_ds_parameters.count+1):=l_bt_string;
  end if;
  --
  --quick search to see if we can find the string in the DS
  if p_ds_parameters.count=0 then
    for i in 1..l_ds_parameters.count loop
      if l_ds_parameters(i)=l_bt_string then
        p_ds_parameters(p_ds_parameters.count+1):=l_ds_parameters(i);
        exit;
      end if;
    end loop;
  end if;
  --
  --see if all tables are in any DS
  if p_ds_parameters.count=0 then --more involved search..
    for i in 1..l_ds_parameters.count loop
      l_ds_tables.delete;
      l_flag:=true;
      bsc_aw_utility.parse_parameter_values(l_ds_parameters(i),',',l_ds_tables);
      for j in 1..p_b_tables.count loop
        if bsc_aw_utility.in_array(l_ds_tables,p_b_tables(j))=false then
          l_flag:=false;
          exit;
        end if;
      end loop;
      if l_flag then
        p_ds_parameters(p_ds_parameters.count+1):=l_ds_parameters(i);
        exit;
      end if;
    end loop;
  end if;
  --
  /*
  more complex. no DS contains all the tables in p_b_tables. this can be very common. dimset contains B1 and B2. B1 and B2 are
  week and month.
  the for i in reverse 1..l_ds_parameters.count loop is a quick fix. ideally, we need to find the DS with the best match
  */
  if p_ds_parameters.count=0 then
    for i in 1..p_b_tables.count loop
      l_bt_flag(i):='N';
    end loop;
    for i in reverse 1..l_ds_parameters.count loop
      l_ds_tables.delete;
      l_flag:=false;
      bsc_aw_utility.parse_parameter_values(l_ds_parameters(i),',',l_ds_tables);
      for j in 1..p_b_tables.count loop
        if l_bt_flag(j)='N' and bsc_aw_utility.in_array(l_ds_tables,p_b_tables(j)) then
          l_bt_flag(j):='Y';
          l_flag:=true;
        end if;
      end loop;
      if l_flag then
        p_ds_parameters(p_ds_parameters.count+1):=l_ds_parameters(i);
      end if;
      l_flag:=false;
      for j in 1..l_bt_flag.count loop
        if l_bt_flag(j)='N' then
          l_flag:=true;
          exit;
        end if;
      end loop;
      if l_flag=false then --we are done
        exit;
      end if;
    end loop;
  end if;
  if g_debug then
    log('get_ds_BT_parameters, DS parameters');
    for i in 1..p_ds_parameters.count loop
      log(p_ds_parameters(i));
    end loop;
  end if;
Exception when others then
  log_n('Exception in get_ds_BT_parameters '||sqlerrm);
  raise;
End;

/*this will check the base tables given and see if there is a current period change in the base table. if there is, we need to set the projection
and balance measures to na
we fire this for actual and target dimsets*/
procedure check_bt_current_period_change(
p_kpi varchar2,
p_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_cubes dbms_sql.varchar2_table,
p_measures dbms_sql.varchar2_table,
p_base_tables dbms_sql.varchar2_table,
p_bt_current_period dbms_sql.varchar2_table,
p_options varchar2
) is
--
l_oor bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
l_cube_measures bsc_aw_adapter_kpi.measure_tb;
l_bt_periodicity dbms_sql.number_table;
l_start_period dbms_sql.varchar2_table;
l_end_period dbms_sql.varchar2_table;
--
type bt_r is record(
table_name varchar2(100),
periodicity number,
current_period varchar2(40),
ds_current_period varchar2(40),
measures dbms_sql.varchar2_table
);
type bt_tb is table of bt_r index by pls_integer;
l_base_tables bt_tb;
--
Begin
  if g_debug then
    log('check_bt_current_period_change for kpi '||p_kpi||', dimset '||p_dim_set.dim_set_name);
    log('Cubes');
    for i in 1..p_cubes.count loop
      log(p_cubes(i));
    end loop;
    log('Measures');
    for i in 1..p_measures.count loop
      log(p_measures(i));
    end loop;
    log('Base Tables and current period');
    for i in 1..p_base_tables.count loop
      log(p_base_tables(i)||' '||p_bt_current_period(i));
    end loop;
    log('Options '||p_options);
    log('--');
  end if;
  /*we do not have base table info in p_dim_set. so we have to go back to olap metadata */
  bsc_aw_md_api.get_dimset_base_table(p_kpi,p_dim_set.dim_set_name,'base table dim set',l_oor);
  /*load base table structures */
  for i in 1..p_base_tables.count loop
    l_base_tables(i).table_name:=p_base_tables(i);
    if p_bt_current_period(i) is not null and p_bt_current_period(i)<>'null' then
      l_base_tables(i).current_period:=p_bt_current_period(i);
    end if;
    for j in 1..l_oor.count loop
      if l_oor(j).object=p_base_tables(i) then
        l_base_tables(i).periodicity:=to_number(bsc_aw_utility.get_parameter_value(l_oor(j).property1,'base table periodicity',','));
        l_base_tables(i).ds_current_period:=bsc_aw_utility.get_parameter_value(l_oor(j).property1,'base table current period',',');
        bsc_aw_utility.parse_parameter_values(bsc_aw_utility.get_parameter_value(l_oor(j).property1,'measures',','),'+',
        l_base_tables(i).measures);
        exit;
      end if;
    end loop;
  end loop;
  /*we have to drive from cubes */
  for i in 1..p_cubes.count loop
    l_cube_measures.delete;
    l_bt_periodicity.delete;
    l_start_period.delete;
    l_end_period.delete;
    for j in 1..p_dim_set.measure.count loop
      if p_dim_set.measure(j).cube=p_cubes(i) and bsc_aw_utility.in_array(p_measures,p_dim_set.measure(j).measure) then
        l_cube_measures(l_cube_measures.count+1):=p_dim_set.measure(j);
      end if;
    end loop;
    for j in 1..l_base_tables.count loop
      if l_base_tables(j).current_period is not null and l_base_tables(j).ds_current_period is not null
      and l_base_tables(j).ds_current_period<>l_base_tables(j).current_period then
        for k in 1..l_cube_measures.count loop
          if bsc_aw_utility.in_array(l_base_tables(j).measures,l_cube_measures(k).measure) then
            l_bt_periodicity(l_bt_periodicity.count+1):=l_base_tables(j).periodicity;
            l_start_period(l_start_period.count+1):=l_base_tables(j).ds_current_period;
            l_end_period(l_end_period.count+1):=l_base_tables(j).current_period;
            exit;
          end if;
        end loop;
      end if;
    end loop;
    if l_cube_measures.count>0 and l_bt_periodicity.count>0 then
      check_bt_current_period_change(p_kpi,p_dim_set,p_cubes(i),l_cube_measures,l_bt_periodicity,l_start_period,l_end_period,p_options);
    else
      if g_debug then
        log('For cube '||p_cubes(i)||', no forecast or balance correction required for current period change in B table');
      end if;
    end if;
  end loop;
Exception when others then
  log_n('Exception in check_bt_current_period_change '||sqlerrm);
  raise;
End;

/*when we have projections or balance, we cannot have compressed composites */
procedure check_bt_current_period_change(
p_kpi varchar2,
p_dim_set bsc_aw_adapter_kpi.dim_set_r,
p_cube varchar2,
p_measures bsc_aw_adapter_kpi.measure_tb,
p_bt_periodicity dbms_sql.number_table, /*p_bt_periodicity,p_start_period and p_end_period match in count*/
p_start_period dbms_sql.varchar2_table,
p_end_period dbms_sql.varchar2_table,
p_options varchar2 /*contains partition info */
) is
--
l_prj_measures bsc_aw_adapter_kpi.measure_tb;
l_bal_measures bsc_aw_adapter_kpi.measure_tb;
l_partition_dim_value varchar2(100);
l_bt_periodicity bsc_aw_adapter_kpi.periodicity_tb;
l_pt_name varchar2(100);
l_pt_type varchar2(100);
l_stmt varchar2(2000);
Begin
  /*correct projections if the measures have projections in them
  when this api is called, locks are already in place
  */
  for i in 1..p_measures.count loop
    if p_measures(i).forecast='Y' then
      l_prj_measures(l_prj_measures.count+1):=p_measures(i);
    end if;
    /*if we have default balance columns ie balance based on last period, have to na the old current period */
    if p_measures(i).measure_type='BALANCE' then
      l_bal_measures(l_bal_measures.count+1):=p_measures(i);
    end if;
  end loop;
  l_partition_dim_value:=bsc_aw_utility.get_parameter_value(p_options,'partition dim value',',');
  for i in 1..p_bt_periodicity.count loop
    l_bt_periodicity(i):=bsc_aw_adapter_kpi.get_periodicity_r(p_dim_set.calendar.periodicity,p_bt_periodicity(i));
  end loop;
  l_pt_name:=bsc_aw_adapter_kpi.get_cube_pt_comp(p_cube,p_dim_set,l_pt_type);
  if l_prj_measures.count>0 or l_bal_measures.count>0 then
    push_dim(p_dim_set.calendar.aw_dim);
    bsc_aw_utility.init_is_new_value(1);
    for i in 1..l_bt_periodicity.count loop
      if bsc_aw_utility.is_new_value(l_bt_periodicity(i).aw_dim,1) then
        push_dim(l_bt_periodicity(i).aw_dim);
      end if;
    end loop;
    push_dim(get_projection_dim(p_dim_set));
    push_dim(p_dim_set.measurename_dim);
    if l_partition_dim_value is not null and p_dim_set.partition_dim is not null then
      push_dim(p_dim_set.partition_dim);
    end if;
    if l_partition_dim_value is not null and p_dim_set.partition_dim is not null then
      limit_dim(p_dim_set.partition_dim,l_partition_dim_value,'TO');
    end if;
    /*all other dimensions are limited to all */
  end if;
  /*set the projections */
  if l_prj_measures.count>0 then
    limit_dim(p_dim_set.calendar.aw_dim,'NULL','TO');
    for i in 1..l_bt_periodicity.count loop
      bsc_aw_dbms_aw.execute('limit '||l_bt_periodicity(i).aw_dim||' TO '''||p_start_period(i)||''' TO '''||p_end_period(i)||'''');
      limit_dim(p_dim_set.calendar.aw_dim,l_bt_periodicity(i).aw_dim,'ADD');
    end loop;
    limit_calendar_ancestors(p_dim_set.calendar,'ADD');
    bsc_aw_dbms_aw.execute('limit '||get_projection_dim(p_dim_set)||' to ''Y''');
    /*when we are here, there cannot be compressed composite.CC cannot be when there are projections or balance */
    limit_dim(p_dim_set.measurename_dim,'NULL','TO');
    for i in 1..l_prj_measures.count loop
      limit_dim(p_dim_set.measurename_dim,''''||l_prj_measures(i).measure||'''','ADD');
    end loop;
    if g_debug then
      dmp_dimset_dim_statlen(p_dim_set);
    end if;
    l_stmt:=p_cube||'=NA';
    if l_pt_name is not null then
      l_stmt:=l_stmt||' across '||l_pt_name; /*both pt and composite */
    end if;
    bsc_aw_dbms_aw.execute(l_stmt);
  end if;
  /*set the balance */
  if l_bal_measures.count>0 then
    limit_dim(p_dim_set.calendar.aw_dim,'NULL','TO');
    for i in 1..l_bt_periodicity.count loop
      bsc_aw_dbms_aw.execute('limit '||l_bt_periodicity(i).aw_dim||' TO '''||p_start_period(i)||'''');
      limit_dim(p_dim_set.calendar.aw_dim,l_bt_periodicity(i).aw_dim,'ADD');
    end loop;
    limit_calendar_ancestors(p_dim_set.calendar,'ADD');
    /*for balance, we cannot limit projection dim to Y */
    limit_dim(p_dim_set.measurename_dim,'NULL','TO');
    for i in 1..l_bal_measures.count loop
      limit_dim(p_dim_set.measurename_dim,''''||l_bal_measures(i).measure||'''','ADD');
    end loop;
    if g_debug then
      dmp_dimset_dim_statlen(p_dim_set);
    end if;
    l_stmt:=p_cube||'=NA';
    if l_pt_name is not null then
      l_stmt:=l_stmt||' across '||l_pt_name; /*both pt and composite */
    end if;
    bsc_aw_dbms_aw.execute(l_stmt);
  end if;
  /*restore dim status */
  if l_prj_measures.count>0 or l_bal_measures.count>0 then
    pop_dim(p_dim_set.calendar.aw_dim);
    bsc_aw_utility.init_is_new_value(1);
    for i in 1..l_bt_periodicity.count loop
      if bsc_aw_utility.is_new_value(l_bt_periodicity(i).aw_dim,1) then
        pop_dim(l_bt_periodicity(i).aw_dim);
      end if;
    end loop;
    pop_dim(get_projection_dim(p_dim_set));
    pop_dim(p_dim_set.measurename_dim);
    if l_partition_dim_value is not null and p_dim_set.partition_dim is not null then
      pop_dim(p_dim_set.partition_dim);
    end if;
  end if;
Exception when others then
  log_n('Exception in check_bt_current_period_change '||sqlerrm);
  raise;
End;

function dimset_has_bal_measures(p_dim_set bsc_aw_adapter_kpi.dim_set_r) return boolean is
Begin
  for i in 1..p_dim_set.measure.count loop
    if substr(p_dim_set.measure(i).measure_type,1,7)='BALANCE' then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  log_n('Exception in dimset_has_bal_measures '||sqlerrm);
  raise;
End;

procedure dmp_dimset_composite_count(p_dim_set bsc_aw_adapter_kpi.dim_set_r) is
l_val varchar2(2000);
Begin
  for i in 1..p_dim_set.composite.count loop
    l_val:=bsc_aw_dbms_aw.interp('show obj(dimmax '''||p_dim_set.composite(i).composite_name||''')');
  end loop;
Exception when others then
  log_n('Exception in dmp_dimset_composite_count '||sqlerrm);
  raise;
End;

/*need ability to control when to turn on parallel threads. parallelism enabled for large objects */
/*for loads, we look at stats for the B tables and check the total count . if the stats is current, get an idea of count for this load */
function is_parallel_load(p_base_tables dbms_sql.varchar2_table,p_cutoff number) return boolean is
change_vector dbms_sql.number_table;
Begin
  if p_base_tables.count>0 then
    for i in 1..p_base_tables.count loop
      change_vector(i):=bsc_aw_md_api.get_bt_change_vector(p_base_tables(i));
    end loop;
    return is_parallel_load(p_base_tables,change_vector,p_cutoff);
  else
    if g_debug then
      log('is_parallel_load(1), p_base_tables.count=0. Go for parallel');
    end if;
    return true;/*default is to parallelize */
  end if;
Exception when others then
  log_n('Exception in is_parallel_load '||sqlerrm);
  raise;
End;

function is_parallel_load(p_base_tables dbms_sql.varchar2_table,p_change_vector dbms_sql.number_table,p_cutoff number) return boolean is
table_count number;
total_table_count number;
Begin
   if p_base_tables.count=0 then
     if g_debug then
       log('is_parallel_load(2), p_base_tables.count=0. Go for parallel');
     end if;
     return true;
   end if;
   total_table_count:=0;
   for i in 1..p_base_tables.count loop
     table_count:=get_table_load_count(p_base_tables(i),p_change_vector(i));
     if g_debug then
       log('For table '||p_base_tables(i)||' with change vector '||p_change_vector(i)||', Table Count='||table_count);
     end if;
     if table_count<0 then /*could not get the count */
       if g_debug then
         log('is_parallel_load, table_count<0. Go for parallel');
       end if;
       return true;/*go for parallel load. dont know if the table is small */
     end if;
     total_table_count:=total_table_count+table_count;
   end loop;
   if g_debug then
     log('is_parallel_load, total_table_count='||total_table_count||' and p_cutoff='||p_cutoff);
   end if;
   if total_table_count<=p_cutoff then
     return false;
   end if;
   return true;
Exception when others then
  log_n('Exception in is_parallel_load '||sqlerrm);
  raise;
End;

/*tries to get this load count. if the stats are old, returns -1 */
function get_table_load_count(p_table varchar2,p_change_vector number) return number is
all_tables bsc_aw_utility.all_tables_tb;
table_count number;
Begin
  all_tables:=bsc_aw_utility.get_db_table_parameters(p_table,bsc_aw_utility.get_table_owner(p_table));
  if all_tables(1).last_analyzed is null or (sysdate-all_tables(1).last_analyzed)>30 then
    return -1;/*no stats or too old stats. cannot get count */
  end if;
  if p_change_vector is null or p_change_vector=1 then /*for initial load, just get the table row count */
    return nvl(all_tables(1).NUM_ROWS,-1);
  else
    /*assume there is bitmap on the change vector */
    table_count:=bsc_aw_utility.get_table_count(p_table,'change_vector='||p_change_vector);
    return nvl(table_count,-1);
  end if;
  return -1;
Exception when others then
  log_n('Exception in get_table_load_count '||sqlerrm);
  raise;
End;

/*given a set of dimsets, checks total comp count to determine if parallel is true or false */
function is_parallel_aggregate(p_dim_set bsc_aw_adapter_kpi.dim_set_tb,p_cutoff number) return boolean is
comp_count number;
total_comp_count number;
Begin
  total_comp_count:=0;
  for i in 1..p_dim_set.count loop
    comp_count:=get_dimset_composite_count(p_dim_set(i));
    if comp_count<0 then
      if g_debug then
        log('is_parallel_aggregate, comp_count<0. Go for parallel');
      end if;
      return true;
    else
      total_comp_count:=total_comp_count+comp_count;
    end if;
  end loop;
  if g_debug then
    log('is_parallel_aggregate, total_comp_count='||total_comp_count||' and p_cutoff='||p_cutoff);
  end if;
  if total_comp_count<=p_cutoff then
    return false;
  end if;
  return true;
Exception when others then
  log_n('Exception in is_parallel_aggregate '||sqlerrm);
  raise;
End;

function is_parallel_aggregate(p_dim_set bsc_aw_adapter_kpi.dim_set_r,p_cutoff number) return boolean is
comp_count number;
Begin
  comp_count:=get_dimset_composite_count(p_dim_set);
  if comp_count<0 then /*could not determine comp count */
    if g_debug then
      log('is_parallel_aggregate, comp_count<0. Go for parallel aggregate');
    end if;
    return true;/*try parallel */
  end if;
  if g_debug then
    log('is_parallel_aggregate, comp_count='||comp_count||' and p_cutoff='||p_cutoff);
  end if;
  if comp_count<=p_cutoff then
    return false;
  end if;
  return true;
Exception when others then
  log_n('Exception in is_parallel_aggregate '||sqlerrm);
  raise;
End;

function get_dimset_composite_count(p_dim_set bsc_aw_adapter_kpi.dim_set_r) return number is
l_val varchar2(2000);
comp_count number;
Begin
  comp_count:=0;
  for i in 1..p_dim_set.composite.count loop
    l_val:=bsc_aw_dbms_aw.interp('show obj(dimmax '''||p_dim_set.composite(i).composite_name||''')');
    if bsc_aw_utility.is_number(l_val) then
      comp_count:=comp_count+to_number(l_val);
    else
      return -1;
    end if;
  end loop;
  return comp_count;
Exception when others then
  log_n('Exception in get_dimset_composite_count '||sqlerrm);
  raise;
End;

----------------------------------------------------
procedure init_all is
Begin
  g_debug:=bsc_aw_utility.g_debug;
Exception when others then
  null;
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

END BSC_AW_LOAD_KPI;

/
