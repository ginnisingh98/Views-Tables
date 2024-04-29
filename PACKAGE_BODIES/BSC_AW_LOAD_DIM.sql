--------------------------------------------------------
--  DDL for Package Body BSC_AW_LOAD_DIM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_AW_LOAD_DIM" AS
/*$Header: BSCAWLDB.pls 120.11 2006/04/20 11:39 vsurendr noship $*/

/*
the top procedure is called with a list of dim levels. from RSG, a list of dim levels affecting a kpi or base table
are passed in. we will resolve into aw dim and call procedure and pass in aw dim
this procedure must then resolve all info and load. in 10g, these procedures will be launched in parallel as jobs
*/
procedure load_dim(p_dim_level_list dbms_sql.varchar2_table) is
Begin
  --p_dim_level_list is an assorted list.can contain city,product, state etc
  if g_debug then
    log_n('Load Dim');
    log('Levels to load ');
    for i in 1..p_dim_level_list.count loop
      log(p_dim_level_list(i));
    end loop;
  end if;
  --get the dimensions for the levels
  load_dim_levels(p_dim_level_list);
Exception when others then
  log_n('Exception in load_dim '||sqlerrm);
  raise;
End;

procedure load_dim_levels(p_dim_level_list dbms_sql.varchar2_table) is
l_dim_list dbms_sql.varchar2_table;
l_dim varchar2(300);
--
Begin
  for i in 1..p_dim_level_list.count loop
    bsc_aw_md_api.get_dim_for_level(p_dim_level_list(i),l_dim);
    if bsc_aw_utility.in_array(l_dim_list,l_dim)=false then
      l_dim_list(l_dim_list.count+1):=l_dim;
    end if;
  end loop;
  if g_debug then
    log_n('Load the following AW Dim');
    for i in 1..l_dim_list.count loop
      log(l_dim_list(i));
    end loop;
  end if;
  --
  load_dimensions(l_dim_list);
Exception when others then
  log_n('Exception in load_dim_levels '||sqlerrm);
  raise;
End;

procedure load_dimensions(p_dim_list dbms_sql.varchar2_table) is
l_parallel boolean;
Begin
  --if 10g, we can launcg parallel jobs.
  l_parallel:=false;
  if bsc_aw_utility.can_launch_jobs(p_dim_list.count)='Y' then
    l_parallel:=true;
  end if;
  if l_parallel=false then
    for i in 1..p_dim_list.count loop
      load_aw_dim(p_dim_list(i),null,null,null);
    end loop;
  else --launch jobs and wait
    load_aw_dim_jobs(p_dim_list);
  end if;
Exception when others then
  log_n('Exception in load_dimensions '||sqlerrm);
  raise;
End;

procedure load_dim_if_needed(p_dim dbms_sql.varchar2_table) is
--
l_load_dim dbms_sql.varchar2_table;
l_dim_lock dbms_sql.varchar2_table;
Begin
  if g_debug then
    log('load_dim_if_needed, the dimensions to check for load are');
    for i in 1..p_dim.count loop
      log(p_dim(i));
    end loop;
  end if;
  l_load_dim.delete;
  l_dim_lock.delete;
  for i in 1..p_dim.count loop
    l_dim_lock(l_dim_lock.count+1):='lock_aw_dim_'||p_dim(i);
    bsc_aw_utility.get_db_lock(l_dim_lock(l_dim_lock.count));
    if check_dim_loaded(p_dim(i))='N' or bsc_aw_adapter_dim.check_dim_view_based(p_dim(i))='Y' then
      l_load_dim(l_load_dim.count+1):=p_dim(i);
    else
      bsc_aw_utility.release_db_lock(l_dim_lock(l_dim_lock.count));
      l_dim_lock.delete(l_dim_lock.count);
    end if;
  end loop;
  if g_debug then
    log('Dimensions to load');
    for i in 1..l_load_dim.count loop
      log(l_load_dim(i));
    end loop;
  end if;
  --
  load_dimensions(l_load_dim);--will parallelize if needed
  --
  for i in 1..l_dim_lock.count loop
    bsc_aw_utility.release_db_lock(l_dim_lock(i));
  end loop;
Exception when others then
  for i in 1..l_dim_lock.count loop
    bsc_aw_utility.release_db_lock(l_dim_lock(i));
  end loop;
  log_n('Exception in load_dim_if_needed '||sqlerrm);
  raise;
End;

procedure load_aw_dim_jobs(p_dim_list dbms_sql.varchar2_table) is
--
l_job_name varchar2(100);
l_process varchar2(8000);
l_job_status bsc_aw_utility.parallel_job_tb;
l_exception exception;
pragma exception_init(l_exception,-20000);
--
Begin
  bsc_aw_utility.clean_up_jobs('all');
  for i in 1..p_dim_list.count loop
    l_job_name:='bsc_aw_job_dim_'||bsc_aw_utility.get_session_id||'_'||i;
    l_process:='bsc_aw_load_dim.load_aw_dim('''||p_dim_list(i)||''','||i||','''||l_job_name||''','''||bsc_aw_utility.get_option_string||''');';
    bsc_aw_utility.start_job(l_job_name,i,l_process,null);
  end loop;
  --wait (this will lock and wait)
  bsc_aw_utility.wait_on_jobs(null,l_job_status);
  --check the status
  for i in 1..l_job_status.count loop
    if l_job_status(i).status='error' then
      --raise error
      raise l_exception;
    end if;
  end loop;
Exception when others then
  log_n('Exception in load_aw_dim_jobs '||sqlerrm);
  raise;
End;

/*
this procedure is the atomic unit, given the aw dim, loads it.
it decides inc vs full etc. in 10g jobs also, this is the procedure that is called in the job

for now, lets start with full refresh all the time. otherwise we need to check the aw dim to see if there are
values in it. or we may need to check the temp table for the levels and see if there is data in the temp table
if there is data, assume inc refresh. else full
we commit after each dim load. if these are dbms jobs, there needs to be a commit after each dim load
(lets do this as part of 10g enhancements)
p_options: to support parallel jobs
*/
procedure load_aw_dim(p_dim varchar2,p_run_id number,p_job_name varchar2,p_options varchar2) is
l_initial_load_pgm varchar2(300);
l_inc_load_pgm varchar2(300);
l_dim_property varchar2(4000);
l_oo bsc_aw_md_wrapper.bsc_olap_object_tb;
l_denorm_src varchar2(4000);
l_dim_level_delete dim_level_delete_tv;
l_dim_delete_flag boolean;
Begin
  --for the dim, get the program name,
  --get the lock on the dim objects
  if p_run_id is not null then
    --this is a dbms job. we have to do the initializations since this is a new session
    bsc_aw_utility.g_options.delete;
    bsc_aw_utility.parse_parameter_values(p_options,',',bsc_aw_utility.g_options);
    bsc_aw_utility.open_file(p_dim||'_'||p_run_id);
    bsc_aw_utility.dmp_g_options(bsc_aw_utility.g_options);
    bsc_aw_utility.init_all_procedures;
  end if;
  log_n('load_aw_dim, p_dim='||p_dim||', p_run_id='||p_run_id||', p_job_name='||p_job_name||
  ', p_options='||p_options);
  l_oo.delete;
  bsc_aw_md_api.get_bsc_olap_object(null,null,p_dim,'dimension',l_oo);
  for i in 1..l_oo.count loop
    if l_oo(i).object_type='dml program' then
      if l_oo(i).olap_object_type='dml program initial load' then
        l_initial_load_pgm:=l_oo(i).object;
      elsif l_oo(i).olap_object_type='dml program inc load' then
        l_inc_load_pgm:=l_oo(i).object;
      end if;
    end if;
  end loop;
  for i in 1..l_oo.count loop
    if l_oo(i).object_type='dimension' then
      l_dim_property:=l_oo(i).property1;
      exit;
    end if;
  end loop;
  /*we cannot get multi locks if there are deletes. so we first pre-load delete values into memory. if deletes are involved, we get full lock */
  load_dim_delete(p_dim,l_dim_property,l_dim_level_delete,l_dim_delete_flag);
  lock_dim_objects(p_dim,l_dim_delete_flag);
  if l_dim_delete_flag then
    merge_delete_values_to_levels(l_dim_level_delete);
  end if;
  l_oo.delete;
  /*if this is a rec dim and implemented with normal hier, we need to populate bsc_aw_temp_pc */
  if nvl(bsc_aw_utility.get_parameter_value(l_dim_property,'recursive',','),'N')='Y' and
  nvl(bsc_aw_utility.get_parameter_value(l_dim_property,'normal hier',','),'N')='Y' then
    l_denorm_src:=bsc_aw_utility.get_parameter_value(l_dim_property,'denorm source',',');
    if l_denorm_src is not null then --dbi rec dim
      load_recursive_norm_hier(replace(l_denorm_src,'*^',','),
      bsc_aw_utility.get_parameter_value(l_dim_property,'child col',','),
      bsc_aw_utility.get_parameter_value(l_dim_property,'parent col',','));
    end if;
  end if;
  /*4646329 for some reason, the dim levels were missing the value 0. maybe the dim was purged. we need a way to get the std values back into the dim
  we do this for std and custom dim for now. projection dim is not loaded via program. now we assume text datatype. later we can have property as
  pk data type in oo for dim level. for rec dim, 0 is never all
  */
  for i in 1..l_oo.count loop
    if l_oo(i).object_type='dimension level' then
      if l_oo(i).olap_object is not null then
        bsc_aw_dbms_aw.execute('maintain '||l_oo(i).olap_object||' merge ''0''');
      end if;
    end if;
  end loop;
  --launch the aw program
  if g_debug then
    log_n('Going to load '||p_dim);
  end if;
  if check_initial_load(p_dim) then
    bsc_aw_dbms_aw.execute('call '||l_initial_load_pgm);
  else
    bsc_aw_dbms_aw.execute('call '||l_inc_load_pgm);
  end if;
  if g_debug then
    log_n('Finished load '||p_dim);
  end if;
  /*we now need to handle any deletes*/
  if l_dim_delete_flag then
    execute_dim_delete(l_dim_level_delete);
    clean_bsc_aw_dim_delete(l_dim_level_delete);
  end if;
  --
  set_kpi_limit_variables(p_dim);
  bsc_aw_management.commit_aw;--will release the locks on the dim objects in 10g
  bsc_aw_management.detach_workspace;
  --if this is a job, send success message to pipe...update bsc_olap_object saying operation_flag='loaded'
  mark_dim_loaded(p_dim);
  --
  if p_run_id is not null then
    bsc_aw_utility.send_pipe_message(p_job_name,'status=success');
  end if;
  commit;
Exception when others then
  log_n('Exception in load_aw_dim '||sqlerrm);
  if p_run_id is not null then
    bsc_aw_utility.send_pipe_message(p_job_name,'status=error,sqlcode='||sqlcode||',message='||sqlerrm);
    rollback;
    bsc_aw_management.detach_workspace;
  else
    raise;
  end if;
End;

/*
delete are handled in the following way
    delete table has 2 columns. dim_level and delete_value. say we have geog dim. city,state,country
    we want to delete all cities in ca and ca
    the table has
    'city'    'SF'
    'city'    'LA'
    'state'   'CA'
the program already has support for marking limit cubes. once the program runs, this already has happened.
we now need to clean up the values from the dim.
Q:if we clean up CA and we still retail some cities in ca, what will happen to the relation. for example, sacramento
will say parent=ca while ca is gone. will agg on this relation error out? No. did a prototype to verify this. if CA is gone,
AW will take care of removing CA from the relation or at-least not considering it anymore
*/
procedure load_dim_delete(
p_dim varchar2,
p_dim_property varchar2,
p_dim_level_delete in out nocopy dim_level_delete_tv,
p_delete_flag out nocopy boolean) is
--
l_level varchar2(300);
l_oo bsc_aw_md_wrapper.bsc_olap_object_tb;
Begin
  p_delete_flag:=false;
  p_dim_level_delete('ALL').delete_name:='ALL';
  p_dim_level_delete('ALL').delete_values.delete;
  --get the dim levels
  l_oo.delete;
  bsc_aw_md_api.get_bsc_olap_object(null,'dimension level',p_dim,'dimension',l_oo);
  --
  if l_oo.count>0 then
    for i in 1..l_oo.count loop
      bsc_aw_utility.merge_value(p_dim_level_delete('ALL').delete_values,l_oo(i).object);--ALL will hold the levels involved
      load_delete_dim_level_value(l_oo(i).object,upper(l_oo(i).object),p_dim_level_delete);
      if p_dim_level_delete(l_oo(i).object).delete_values.count>0 then
        p_delete_flag:=true;
      end if;
    end loop;
    --
    if nvl(bsc_aw_utility.get_parameter_value(p_dim_property,'recursive',','),'N')='Y' then
      l_level:=l_oo(1).object;
      l_oo.delete;
      bsc_aw_md_api.get_bsc_olap_object(null,'recursive level',p_dim,'dimension',l_oo);
      for i in 1..l_oo.count loop
        bsc_aw_utility.merge_value(p_dim_level_delete('ALL').delete_values,l_oo(i).object);--ALL will hold the levels involved
        load_delete_dim_level_value(l_oo(i).object,upper(l_level),p_dim_level_delete);
      end loop;
    end if;
  end if;
Exception when others then
  log_n('Exception in load_dim_delete '||sqlerrm);
  raise;
End;

/*5064802. cannot delete in multi mode. pre-load deletes into memory. if there are any deletes, then get rw lock */
procedure load_delete_dim_level_value(
p_dim_level varchar2,
p_select_level varchar2,--useful in case of rec dim. we need to delete the virtual parent level also
p_dim_level_delete in out nocopy dim_level_delete_tv) is
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  l_stmt:='select distinct delete_value from bsc_aw_dim_delete where dim_level=:1';
  if g_debug then
    log(l_stmt||' '||p_select_level||bsc_aw_utility.get_time);
  end if;
  p_dim_level_delete(p_dim_level).delete_name:=p_dim_level;
  p_dim_level_delete(p_dim_level).delete_values.delete;
  open cv for l_stmt using p_select_level;
  loop
    fetch cv bulk collect into p_dim_level_delete(p_dim_level).delete_values;
    exit when cv%notfound;
  end loop;
  if g_debug then
    log('Fetched '||p_dim_level_delete(p_dim_level).delete_values.count||' rows'||bsc_aw_utility.get_time);
  end if;
  close cv;
Exception when others then
  log_n('Exception in load_delete_dim_level_value '||sqlerrm);
  raise;
End;

procedure execute_dim_delete(p_dim_level_delete dim_level_delete_tv) is
l_levels dbms_sql.varchar2_table;
Begin
  l_levels:=p_dim_level_delete('ALL').delete_values; --levels also include virtual rec dim parent level
  for i in 1..l_levels.count loop
    delete_dim_level_value(l_levels(i),p_dim_level_delete(l_levels(i)).delete_values);
  end loop;
Exception when others then
  log_n('Exception in execute_dim_delete '||sqlerrm);
  raise;
End;

/*bsc_aw_dim_delete is created by loader. so keep the sql dynamic
5064802: when we delete values, we cannot be in multi attach mode. must get full rw lock
lock_dim_objects will lock the dim in full mode if there are deletes reqd*/
procedure delete_dim_level_value(p_dim_level varchar2,p_delete_values dbms_sql.varchar2_table) is
Begin
  for i in 1..p_delete_values.count loop
    bsc_aw_dbms_aw.execute('mnt '||p_dim_level||' delete '''||p_delete_values(i)||'''');
  end loop;
Exception when others then
  log_n('Exception in delete_dim_level_value '||sqlerrm);
  raise;
End;

procedure clean_bsc_aw_dim_delete(p_dim_level_delete dim_level_delete_tv) is
l_levels dbms_sql.varchar2_table;
l_stmt varchar2(4000);
Begin
  l_levels:=p_dim_level_delete('ALL').delete_values;
  for i in 1..l_levels.count loop
    l_stmt:='delete bsc_aw_dim_delete where dim_level=:1';
    if g_debug then
      log(l_stmt||' '||l_levels(i)||bsc_aw_utility.get_time);
    end if;
    execute immediate l_stmt using l_levels(i);
    if g_debug then
      log('Deleted '||sql%rowcount||' rows '||bsc_aw_utility.get_time);
    end if;
  end loop;
Exception when others then
  log_n('Exception in clean_bsc_aw_dim_delete '||sqlerrm);
  raise;
End;

/*
to check initial vs inc laod, check the temp table.
*/
function check_initial_load(p_dim varchar2) return boolean is
Begin
  --for now, full refresh
  return true;
Exception when others then
  log_n('Exception in check_initial_load '||sqlerrm);
  raise;
End;

/*
purge a dim completely from the given list of levels
*/
procedure purge_dim(p_dim_level_list dbms_sql.varchar2_table) is
l_dim_list dbms_sql.varchar2_table;
l_dim varchar2(300);
Begin
  for i in 1..p_dim_level_list.count loop
    bsc_aw_md_api.get_dim_for_level(p_dim_level_list(i),l_dim);
    if bsc_aw_utility.in_array(l_dim_list,l_dim)=false then
      l_dim_list(l_dim_list.count+1):=l_dim;
    end if;
  end loop;
  for i in 1..l_dim_list.count loop
    purge_dim(l_dim_list(i));
  end loop;
Exception when others then
  log_n('Exception in purge_dim '||sqlerrm);
  raise;
End;

/*purge a dim
logic:
purge all related kpi
purge dim related data objects
purge dim levels
*/
procedure purge_dim(p_dim varchar2) is
--
l_olap_object bsc_aw_md_wrapper.bsc_olap_object_tb;
l_kpi_list dbms_sql.varchar2_table;
Begin
  if g_debug then
    log_n('Purge dim '||p_dim);
  end if;
  --get lock, for purge, we need exclusive locks. otherwise we cannot delete dimensions
  bsc_aw_management.get_workspace_lock('rw',null);
  --purge kpi
  bsc_aw_md_api.get_kpi_for_dim(p_dim,l_kpi_list);
  for i in 1..l_kpi_list.count loop
    bsc_aw_load_kpi.purge_kpi(l_kpi_list(i));
  end loop;
  --
  bsc_aw_md_api.get_bsc_olap_object(null,null,p_dim,'dimension',l_olap_object);
  --purge variables
  for i in 1..l_olap_object.count loop
    if l_olap_object(i).object_type='limit cube' or l_olap_object(i).object_type='filter cube' then
      bsc_aw_dbms_aw.execute('clear all from '||l_olap_object(i).olap_object);
    end if;
  end loop;
  --
  for i in 1..l_olap_object.count loop
    if l_olap_object(i).object_type='dimension level' then
      bsc_aw_dbms_aw.execute('mnt '||l_olap_object(i).olap_object||' delete all');
    end if;
  end loop;
  --
  bsc_aw_management.commit_aw;
  commit;
Exception when others then
  log_n('Exception in purge_dim '||sqlerrm);
  raise;
End;

/*
this procedure will dmp the dim level data into table bsc_aw_dim_data
used for bis dimensions that are not materialized. bsc loader needs the dim values
to know which values have got deleted

this creates the program on the fly, executes it and drops the program
NO COMMIT!!!
remember: multiple dim loads can be happening. so we cannot have just one program for all
dim levels. the same level cannot be loaded in 2 sessions
*/
procedure dmp_dim_level_into_table(p_dim_level_list dbms_sql.varchar2_table) is
Begin
  for i in 1..p_dim_level_list.count loop
    dmp_dim_level_into_table(upper(p_dim_level_list(i)));
  end loop;
Exception when others then
  log_n('Exception in dmp_dim_level_into_table '||sqlerrm);
  raise;
End;
--
procedure dmp_dim_level_into_table(p_dim_level varchar2) is
--
l_name varchar2(300);
Begin
  l_name:='dmp_'||p_dim_level;
  bsc_aw_dbms_aw.execute_ne('delete '||l_name);
  bsc_aw_adapter_dim.create_dmp_program(p_dim_level,l_name);
  bsc_aw_dbms_aw.execute('call '||l_name);
  bsc_aw_dbms_aw.execute('delete '||l_name);
Exception when others then
  log_n('Exception in dmp_dim_level_into_table '||sqlerrm);
  raise;
End;

/*
say there are hier changes. we need to make sure we mark the kpi limit variables accordingly.
example:
if any(BSC_CCDIM_100_101_102_103.limit.bool) --limit bool now represented as .LB to reduce length of name
then do
limit BSC_CCDIM_100_101_102_103 to BSC_CCDIM_100_101_102_103.limit.bool
kpi_3014_1.BSC_CCDIM_100_101_102_103.limit.bool=TRUE
doend
earlier this was in the dim program. but there is an issue here. when creating the dim programs, we cannot
know which kpi are implemented. if we assume that all kpi marked for aw are implemented, we can run into an
issue if a kpi ends up not implemented. so better do this at runtime, after reading the olap metadata

here we will limit the dim to whatever hier changed. then we will set the kpi.dim.limit.bool to these values
at this time, the levels for which the hier changed maynot even be a level of the kpi. this is ok. at the time
when we are about to aggregate the kpi, we will eliminate all the levels that are not involved
we also set the aggregate marker for the kpi dimset to true
*/
procedure set_kpi_limit_variables(p_dim varchar2) is
--
l_olap_object_relation bsc_aw_md_wrapper.bsc_olap_object_relation_tb;
l_olap_object bsc_aw_md_wrapper.bsc_olap_object_tb;
l_dim_limit_cube varchar2(300);
l_kpi_limit_cubes dbms_sql.varchar2_table;
l_kpi_aggregate_markers dbms_sql.varchar2_table;
l_kpi_reset_cubes dbms_sql.varchar2_table;
l_statlen varchar2(200);
l_relation varchar2(200);
Begin
  bsc_aw_md_api.get_bsc_olap_object_relation(null,null,'dim limit cube',p_dim,'dimension',l_olap_object_relation);
  bsc_aw_md_api.get_bsc_olap_object(null,'relation',p_dim,'dimension',l_olap_object);
  if l_olap_object.count>0 then
    l_relation:=l_olap_object(1).olap_object;
  else
    if g_debug then
      log_n('No relation found for dim '||p_dim);
    end if;
  end if;
  --there must be only 1 limit cube
  --see which kpi and which dim sets have this dim. get the kpi limit cube from the property
  if l_olap_object_relation.count > 0 then
    l_dim_limit_cube:=l_olap_object_relation(1).relation_object;
    --get the cube limit cubes
    --see if we need to set the aggregate marker
    --the output comes in formats like 321,667...so do not want to use to_number(...)
    bsc_aw_dbms_aw.execute('push '||p_dim);
    bsc_aw_dbms_aw.execute('limit '||p_dim||' to '||l_dim_limit_cube);
    l_statlen:=bsc_aw_dbms_aw.interp('show statlen('||p_dim||')');
    if l_statlen <> '0' then
      if l_relation is not null then
        bsc_aw_dbms_aw.execute('limit '||p_dim||' to children using '||l_relation);
      end if;
      l_statlen:=bsc_aw_dbms_aw.interp('show statlen('||p_dim||')');
      if l_statlen <> '0' then
        l_kpi_limit_cubes.delete;
        l_kpi_aggregate_markers.delete;
        bsc_aw_adapter_dim.get_dim_kpi_limit_cubes(p_dim,l_kpi_limit_cubes,l_kpi_aggregate_markers,l_kpi_reset_cubes);
        for i in 1..l_kpi_limit_cubes.count loop
          bsc_aw_dbms_aw.execute(l_kpi_limit_cubes(i)||'=TRUE');
        end loop;
        for i in 1..l_kpi_aggregate_markers.count loop
          bsc_aw_dbms_aw.execute(l_kpi_aggregate_markers(i)||'=TRUE');
        end loop;
      end if;
      --handle setting reset cubes
      /*
      we cannot have this part inside if l_statlen <> '0' (after drill down to children). imagine we have A >- B.
      now, A does not have a manager. so we have A and B. in this case, l_statlen will be 0. but we need to set the
      reset cubes to 0 for B.
      reset cubes are reqd because a parent node can be left with no children in which case, we need to set the values for
      the node to NA in the cube
      example:     A          C               changes to    A         C
                   a         b  d                                    a  b  d
      in this case, we need to set the aggregated value for A to na in the cubes. AW will not re-agg A. it will re-agg only if
      A has at-least another child node, even if this child node is not a part of the cube
      */
      if l_relation is not null then
        bsc_aw_dbms_aw.execute('limit '||p_dim||' to parents using '||l_relation);
        bsc_aw_dbms_aw.execute(l_dim_limit_cube||'=false');
        bsc_aw_dbms_aw.execute('limit '||p_dim||' to '||l_dim_limit_cube);--only hanging nodes left
        l_statlen:=bsc_aw_dbms_aw.interp('show statlen('||p_dim||')');
        if l_statlen <> '0' then
          for i in 1..l_kpi_reset_cubes.count loop
            bsc_aw_dbms_aw.execute(l_kpi_reset_cubes(i)||'=TRUE');
          end loop;
        end if;
      end if;
      --dim limit cube will be set to false at the start of the dim load
    end if;
    bsc_aw_dbms_aw.execute('pop '||p_dim);
  end if;
Exception when others then
  log_n('Exception in set_kpi_limit_variables '||sqlerrm);
  raise;
End;

procedure lock_dim_objects(p_dim varchar2,p_dim_delete boolean) is
--
l_lock_objects dbms_sql.varchar2_table;
Begin
  if p_dim_delete then --full rw lock
    bsc_aw_management.get_workspace_lock('rw',null);
  else
    get_dim_objects_to_lock(p_dim,l_lock_objects);
    bsc_aw_management.get_workspace_lock(l_lock_objects,null);
  end if;
Exception when others then
  log_n('Exception in lock_dim_objects '||sqlerrm);
  raise;
End;

/*
we cannot lock concat dim. got error
acquire BSC_CCDIM_100_101_102_103  (S: 04/13/2005 17:34:10
Exception in execute acquire BSC_CCDIM_100_101_102_103 ORA-37018:Multiwriter operations are not supported for object BSC_AW!BSC_CCDIM_100_101_102_103.
--
we have to acquire locks and update in a certain order . else we get
ORA-37023: (XSMLTUPD01) Object workspace object cannot be updated without dimension workspace object.
we cannot update a relation before a dim. so when we get locks, we first get dim, then relations, then variables
*/
procedure get_dim_objects_to_lock(p_dim varchar2,p_lock_objects out nocopy dbms_sql.varchar2_table) is
--
l_bsc_olap_object bsc_aw_md_wrapper.bsc_olap_object_tb;
l_kpi_limit_cubes dbms_sql.varchar2_table;
l_kpi_reset_cubes dbms_sql.varchar2_table;
l_kpi_aggregate_markers dbms_sql.varchar2_table;
l_objects dbms_sql.varchar2_table;
Begin
  l_bsc_olap_object.delete;
  bsc_aw_md_api.get_bsc_olap_object(null,null,p_dim,'dimension',l_bsc_olap_object);
  for i in 1..l_bsc_olap_object.count loop
    if l_bsc_olap_object(i).olap_object_type is not null and l_bsc_olap_object(i).olap_object_type='dimension' then
      l_objects(l_objects.count+1):=l_bsc_olap_object(i).olap_object;
    end if;
  end loop;
  for i in 1..l_bsc_olap_object.count loop
    if l_bsc_olap_object(i).olap_object_type is not null and l_bsc_olap_object(i).olap_object_type='relation' then
      l_objects(l_objects.count+1):=l_bsc_olap_object(i).olap_object;
    end if;
  end loop;
  for i in 1..l_bsc_olap_object.count loop
    if l_bsc_olap_object(i).olap_object_type is not null and l_bsc_olap_object(i).olap_object_type='variable' then
      l_objects(l_objects.count+1):=l_bsc_olap_object(i).olap_object;
    end if;
  end loop;
  --also, we have to lock the kpi limit cubes
  bsc_aw_adapter_dim.get_dim_kpi_limit_cubes(p_dim,l_kpi_limit_cubes,l_kpi_aggregate_markers,l_kpi_reset_cubes);
  for i in 1..l_kpi_limit_cubes.count loop
    l_objects(l_objects.count+1):=l_kpi_limit_cubes(i);
  end loop;
  for i in 1..l_kpi_aggregate_markers.count loop
    l_objects(l_objects.count+1):=l_kpi_aggregate_markers(i);
  end loop;
  --
  for i in 1..l_objects.count loop
    if bsc_aw_utility.in_array(p_lock_objects,l_objects(i))=false then
      p_lock_objects(p_lock_objects.count+1):=l_objects(i);
    end if;
  end loop;
Exception when others then
  log_n('Exception in get_dim_objects_to_lock '||sqlerrm);
  raise;
End;

/*
this is called only for rec dim implemented with normal hier. in this case, we take the data from denorm
table and normalize it into a temp table bsc_aw_temp_pc. the dim load program for the rec dim will
pick up data from here
to support multiple parents, we use the rank fn. if a child has 2 parents (example 3), we will see
         C          P RANK()OVER(PARTITIONBYCORDERBYROWNUM)
---------- ---------- -------------------------------------
         2          1                                     1
         3          1                                     1
         3          6                                     2
order by parent col is imp. it makes the result repeatable
this api is only fired for dbi based rec dim
*/
procedure load_recursive_norm_hier(p_denorm_source varchar2,p_child_col varchar2,p_parent_col varchar2) is
--
l_stmt varchar2(8000);
Begin
  if p_denorm_source is not null then
    bsc_aw_utility.execute_stmt('delete bsc_aw_temp_pc');
    bsc_aw_utility.execute_stmt('delete bsc_aw_temp_vn');
    --
    l_stmt:='insert into bsc_aw_temp_vn(name,id) select '||p_child_col||',count(*) from '||p_denorm_source||' group by '||p_child_col;
    bsc_aw_utility.execute_stmt(l_stmt);
    --
    l_stmt:='insert into bsc_aw_temp_pc(parent,child,id) select '||p_parent_col||','||p_child_col||',rank() over(partition by '||
    p_child_col||' order by '||p_parent_col||') from (select denorm.'||p_parent_col||',denorm.'||p_child_col||' from '||
    p_denorm_source||' denorm,bsc_aw_temp_vn t1,bsc_aw_temp_vn t2 where denorm.'||p_parent_col||'=t1.name(+) and '||
    'denorm.'||p_child_col||'=t2.name and t2.id=nvl(t1.id,0)+1)';
    bsc_aw_utility.execute_stmt(l_stmt);
  end if;
Exception when others then
  log_n('Exception in load_recursive_norm_hier '||sqlerrm);
  raise;
End;

function check_dim_loaded(p_dim varchar2) return varchar2 is
l_oo bsc_aw_md_wrapper.bsc_olap_object_tb;
Begin
  if bsc_aw_utility.in_array(bsc_aw_adapter_dim.get_preloaded_dim_list,p_dim)=false then
    bsc_aw_md_api.get_bsc_olap_object(p_dim,'dimension',p_dim,'dimension',l_oo);
    if l_oo(1).operation_flag is not null and l_oo(1).operation_flag='loaded' then
      return 'Y';
    else
      return 'N';
    end if;
  else
    return 'Y';
  end if;
Exception when others then
  log_n('Exception in check_dim_loaded '||sqlerrm);
  raise;
End;

procedure mark_dim_loaded(p_dim varchar2) is
l_oo bsc_aw_md_wrapper.bsc_olap_object_tb;
Begin
  bsc_aw_md_api.update_olap_object(p_dim,'dimension',p_dim,'dimension',null,null,'operation_flag','loaded');
  bsc_aw_md_api.get_bsc_olap_object(null,'dimension level',p_dim,'dimension',l_oo);
  for i in 1..l_oo.count loop --mark snowflake impl as loaded
    bsc_aw_md_api.update_olap_object(l_oo(i).object,'dimension',l_oo(i).object,'dimension',null,null,'operation_flag','loaded');
  end loop;
Exception when others then
  log_n('Exception in mark_dim_loaded '||sqlerrm);
  raise;
End;

/* 5064802 cannot recreate dim programs. do this: load all dim once again and also load the values from bsc_aw_dim_delete table
from now on, hopefully, there will not be attempt to delete values that do not exist in dimensions. newly created dim will have robust strategy
to handle cases where dim delete values are not yet in aw dim*/
procedure upgrade_load_sync_all_dim is
l_oo bsc_aw_md_wrapper.bsc_olap_object_tb;
l_dim varchar2(200);
l_dim_list dbms_sql.varchar2_table;
Begin
  bsc_aw_md_api.get_bsc_olap_object(null,'dimension level',null,'dimension',l_oo);
  for i in 1..l_oo.count loop
    if bsc_aw_utility.get_parameter_value(l_oo(i).property1,'periodicity',',') is null then --this is not a calendar dim level
      bsc_aw_md_api.get_dim_for_level(l_oo(i).object,l_dim);
      bsc_aw_utility.merge_value(l_dim_list,l_dim);
    end if;
  end loop;
  --
  for i in 1..l_dim_list.count loop
    upgrade_load_sync_all_dim(l_dim_list(i));
  end loop;
Exception when others then
  log_n('Exception in upgrade_load_sync_all_dim '||sqlerrm);
  raise;
End;

procedure upgrade_load_sync_all_dim(p_dim varchar2) is
l_oo bsc_aw_md_wrapper.bsc_olap_object_tb;
l_dim_level_delete dim_level_delete_tv;
l_delete_flag boolean;
Begin
  if g_debug then
    log('upgrade_load_sync_all_dim '||p_dim);
  end if;
  /*add delete values into the dim levels */
  bsc_aw_md_api.get_bsc_olap_object(p_dim,'dimension',p_dim,'dimension',l_oo);
  if l_oo.count>0 then
    load_dim_delete(p_dim,l_oo(1).property1,l_dim_level_delete,l_delete_flag);
    if l_delete_flag then
      merge_delete_values_to_levels(l_dim_level_delete);
    end if;
  end if;
  /*refresh the dim */
  l_oo.delete;
  bsc_aw_md_api.get_bsc_olap_object(null,'dml program',p_dim,'dimension',l_oo);
  for i in 1..l_oo.count loop
    if l_oo(i).olap_object_type='dml program initial load' then
      begin
        bsc_aw_dbms_aw.execute('call '||l_oo(i).object);
      exception when others then
        null;
      end;
      exit;
    end if;
  end loop;
Exception when others then
  log_n('Exception in upgrade_load_sync_all_dim '||sqlerrm);
  raise;
End;

/*5074869 in the load programs, the delete values are handled only when the dim levels have parents. if this is the top level and
bsc_aw_dim_delete has values not in the dim, we can run into the issue of value not valid error
best way is to merge these delete values into the dim levels anyway */
procedure merge_delete_values_to_levels(p_dim_level_delete dim_level_delete_tv) is
l_levels dbms_sql.varchar2_table;
Begin
  l_levels:=p_dim_level_delete('ALL').delete_values;
  for i in 1..l_levels.count loop
    for j in 1..p_dim_level_delete(l_levels(i)).delete_values.count loop
      bsc_aw_dbms_aw.execute('mnt '||l_levels(i)||' merge '''||p_dim_level_delete(l_levels(i)).delete_values(j)||'''');
    end loop;
  end loop;
Exception when others then
  log_n('Exception in merge_delete_values_to_levels '||sqlerrm);
  raise;
End;

------------------------------------------
procedure init_all is
Begin
  g_debug:=bsc_aw_utility.g_debug;
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

END BSC_AW_LOAD_DIM;

/
