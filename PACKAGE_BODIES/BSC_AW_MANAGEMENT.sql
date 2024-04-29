--------------------------------------------------------
--  DDL for Package Body BSC_AW_MANAGEMENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BSC_AW_MANAGEMENT" AS
/*$Header: BSCAWMGB.pls 120.15 2006/04/20 10:58 vsurendr noship $*/

/*
workspace management is done here. adapter, loader will not try to acquire excluseve locks.
they will simply request attaching workspace and pass a list of objects.
this pack will check the db version and try to get the lock accordingly. if there is already a lock
this will lock and wait
10g:global var will keep track of which objects have been locked. when commit is encountered, these are
updated back, released and commit is issued. this is like db releasing locks on commit
*/

/*
get object lock (10g)
g_locked_objects.delete; happens when commit_aw happens
*/
procedure get_workspace_lock(p_objects dbms_sql.varchar2_table,p_options varchar2) is
Begin
  --we have bsc_aw_utility.add_option so that if "exclusive lock" is passed as an option we can hold it in bsc_aw_utility.g_options
  bsc_aw_utility.add_option(p_options,null,',');
  g_locked_objects.delete;
  if bsc_aw_utility.get_db_version>=10 and nvl(bsc_aw_utility.get_parameter_value('exclusive lock'),'N')='N' then
    g_locked_objects:=p_objects;
  end if;
  if g_locked_objects.count=0 then --no objects. have to go for full lock
    if g_debug then
      log_n('Called get_workspace_lock for objects, but, g_locked_objects.count=0. Going for full RW lock');
    end if;
    get_workspace_lock('rw',p_options);
  else
    get_lock('multi',p_options);
  end if;
Exception when others then
  log_n('Exception in get_workspace_lock '||sqlerrm);
  raise;
End;

/*
get exclusive lock. p_mode="r" when called from PMV. this will sleep and wait if there is
another session locking
*/
procedure get_workspace_lock(p_mode varchar2,p_options varchar2) is
Begin
  bsc_aw_utility.add_option(p_options,null,',');
  g_locked_objects.delete;
  get_lock(p_mode,p_options);
  if upper(p_mode)='RW' then
    create_default_elements; --only in rw mode
  end if;
Exception when others then
  log_n('Exception in get_workspace_lock '||sqlerrm);
  raise;
End;

--pvt
procedure get_lock(p_mode varchar2,p_options varchar2) is
l_name varchar2(300);
l_nowait varchar2(10);
l_exit boolean;
l_current_sessions current_sessions_tb;
Begin
  bsc_aw_utility.add_option(p_options,null,',');
  l_name:=get_aw_workspace_name;
  if nvl(bsc_aw_utility.get_parameter_value(p_options,'create workspace',','),'N')='Y' then
    if bsc_aw_md_api.check_workspace(l_name)='N' then
      create_workspace(p_options);
    end if;
  end if;
  l_nowait:=nvl(bsc_aw_utility.get_parameter_value(p_options,'nowait',','),'N');
  --
  l_exit:=false;
  loop
    begin
      get_lock(l_name,p_mode,g_locked_objects);
      l_exit:=true;
    exception when others then
      if l_nowait='Y' then
        raise;
      elsif sqlcode=-33290 or sqlcode=-37011 then
        bsc_aw_utility.sleep(60,15);
      else
        raise;
      end if;
    end;
    if l_exit then
      exit;
    end if;
  end loop;
  --
  exec_workspace_settings;
Exception when others then
  log_n('Exception in get_lock '||sqlerrm);
  raise;
End;

procedure get_lock(p_name varchar2,p_mode varchar2,p_locked_objects dbms_sql.varchar2_table) is
Begin
  attach_workspace(p_name,p_mode);
  get_lock(p_locked_objects=>p_locked_objects,p_options=>null);
Exception when others then
  log_n('Exception in get_lock '||sqlerrm);
  raise;
End;

procedure attach_workspace(p_name varchar2,p_mode varchar2) is
Begin
  if g_attached is null or g_attached=false or g_attached_mode is null or g_attached_mode<>upper(p_mode) then
    /*if there are any uncommited  objects, commit them
    5130982 this is really an AW issue. even after attach multi is specified, aw is not attaching the workspace. so we must detach and then attach*/
    if g_attached and g_attached_mode<>'RO' then
      commit_aw;/*commit any unsaved objects but not if the earlier attach mode was RO*/
    end if;
    /*Q:is serialization reqd here? as soon as session 1 releases WS, will there be a race by session 2? serializing just the ws attach may not be a
    solution anyway */
    detach_aw_workspace(p_name);
    bsc_aw_dbms_aw.execute('aw attach '||p_name||' '||p_mode);
  end if;
  g_attached:=true;
  g_attached_mode:=upper(p_mode);
Exception when others then
  log_n('Exception in attach_workspace '||sqlerrm);
  raise;
End;

--called from bsc_aw_load_kpi for copy target to actual and aggregate measures in parallel
procedure get_lock(p_locked_objects dbms_sql.varchar2_table,p_options varchar2) is
--
l_count number;
l_resync varchar2(20);
l_wait varchar2(20);
l_resync_object dbms_sql.varchar2_table;
l_wait_object dbms_sql.varchar2_table;
Begin
  l_resync:=null;
  l_wait:=null;
  bsc_aw_utility.add_option(p_options,null,',');
  if bsc_aw_utility.get_db_version>=10 and nvl(bsc_aw_utility.get_parameter_value('exclusive lock'),'N')='N' and p_locked_objects.count>0  then --10g
    /*initially there was if g_attached=false then. we remove this because attach_workspace already takes care of this */
    attach_workspace(get_aw_workspace_name,'multi');/*since this is for multiple objects, its multi lock */
    l_count:=0;
    if nvl(bsc_aw_utility.get_parameter_value(p_options,'resync',','),'N')='Y' then
      l_resync:='resync';
    end if;
    l_wait:=bsc_aw_utility.get_parameter_value(p_options,'wait type',',');--wait or active wait or null
    for i in 1..p_locked_objects.count loop  --init
      l_resync_object(i):=l_resync;
      l_wait_object(i):=l_wait;
    end loop;
    for i in 1..p_locked_objects.count loop
      get_lock_object(p_locked_objects(i),l_resync_object(i),l_wait_object(i));
      l_count:=i;
      --we add the object to the list of locked objects if not already there
      if bsc_aw_utility.in_array(g_locked_objects,p_locked_objects(i))=false then
        g_locked_objects(g_locked_objects.count+1):=p_locked_objects(i);
      end if;
    end loop;
  end if;
Exception when others then
  --we have to release the locks, else there may be a deadlock
  --we cannot rollback. it has to be an explicit release
  --even if bsc_aw_dbms_aw.execute raises an exception, this will not go into an infinite loop
  if l_count is not null and l_count>0 then --release them
    for i in 1..l_count loop
      bsc_aw_dbms_aw.execute('release '||p_locked_objects(i));
    end loop;
  end if;
  log_n('Exception in get_lock '||sqlerrm);
  raise;
End;

procedure get_lock_object(p_object varchar2,p_resync varchar2,p_wait varchar2) is
l_exit boolean;
l_resync varchar2(40);
l_wait varchar2(40);
l_start_time number;
Begin
  l_start_time:=bsc_aw_utility.get_dbms_time;
  l_resync:=p_resync;
  if p_wait='wait' then --p_wait can be wait, active wait or null
    l_wait:=p_wait;
  end if;
  loop
    begin
      bsc_aw_dbms_aw.execute('acquire '||l_resync||' '||p_object||' '||l_wait);
      exit;
    exception when others then
      if sqlcode=-37014 then --lock already acquired by the same session
        if g_debug then
          log('Object '||p_object||' already acquired.');
        end if;
        exit;
      elsif sqlcode=-37011 or sqlcode=-37013 or sqlcode=-37040 or sqlcode=-37042 then
        if (bsc_aw_utility.get_dbms_time-l_start_time)/100 > bsc_aw_utility.g_max_wait_time then
          if g_debug then
            log('Wait time has exceeded '||bsc_aw_utility.g_max_wait_time||'. Aborting...');
          end if;
          raise bsc_aw_utility.g_exception;
        elsif p_wait='active wait' then
          bsc_aw_utility.sleep(5,7);
        else
          raise;
        end if;
      elsif sqlcode=-37044 then --needs resync
        if l_resync='resync' then
          if g_debug then
            log_n('Tried to get object in resync mode. again failing with ORA-37044. Abort...');
          end if;
          raise;
        end if;
        l_resync:='resync';
      else
        raise;
      end if;
    end;
  end loop;
Exception when others then
  log_n('Exception in get_lock_object '||sqlerrm);
  raise;
End;

procedure release_lock(p_objects dbms_sql.varchar2_table) is
Begin
  for i in 1..p_objects.count loop
    release_lock(p_objects(i));
  end loop;
Exception when others then
  log_n('Exception in release_lock '||sqlerrm);
  raise;
End;

procedure release_lock(p_object varchar2) is
Begin
  if bsc_aw_utility.get_db_version>=10 and nvl(bsc_aw_utility.get_parameter_value('exclusive lock'),'N')='N' then
    bsc_aw_dbms_aw.execute('release '||p_object);
  end if;
Exception when others then
  if sqlcode=-37021 then
    log_n('Object '||p_object||' not acquired');
  else
    log_n('Exception in release_lock '||sqlerrm);
    raise;
  end if;
End;

procedure detach_workspace is
Begin
  detach_workspace(get_aw_workspace_name);
Exception when others then
  log_n('Exception in detach_workspace '||sqlerrm);
  raise;
End;

procedure detach_workspace(p_workspace varchar2) is
Begin
  detach_aw_workspace(p_workspace);
  g_locked_objects.delete;
Exception when others then
  log_n('Exception in detach_workspace '||sqlerrm);
  raise;
End;

procedure detach_aw_workspace(p_workspace varchar2) is
Begin
  if g_attached then
    bsc_aw_utility.add_sqlerror(-34344,'ignore',null);--ignore if the ws is not already attached
    bsc_aw_dbms_aw.execute('aw detach '||p_workspace);
    bsc_aw_utility.remove_sqlerror(-34344,'ignore');
  end if;
  g_attached:=false;
  g_attached_mode:=null;
Exception when others then
  bsc_aw_utility.remove_sqlerror(-34344,'ignore');
  log_n('Exception in detach_aw_workspace '||sqlerrm);
  raise;
End;

/*
in 10g, commit will release the locks on the objects. however, it does not detach the workspace.
so if optimizer wants exclusive locks, it must wait till load is complete and workspace is
detached.
even if we have attached objects in multi mode, we can simply use update instead of update multi
--
from olap doc:
When you do not specify any parameters, the command updates all analytic
workspaces that are attached in read/write non-exclusive and read/write exclusive
modes and all acquired objects (that is, all acquired variables, relations, valuesets,
and dimensions) in all analytic workspaces that are attached in multiwriter mode.
--
*/
procedure commit_aw is
Begin
  commit_aw(p_options=>null);
Exception when others then
  log_n('Exception in commit_aw '||sqlerrm);
  raise;
End;

procedure commit_aw(p_options varchar2) is
Begin
  if g_locked_objects.count>0 then --10g
    commit_aw_multi;
    bsc_aw_dbms_aw.execute('commit');
    if not(nvl(bsc_aw_utility.get_parameter_value(p_options,'no release lock',','),'N')='Y') then
      for i in 1..g_locked_objects.count loop
        release_lock(g_locked_objects(i));
      end loop;
      g_locked_objects.delete;
    end if;
  else
    update_aw;
  end if;
  bsc_aw_dbms_aw.execute('commit');
Exception when others then
  log_n('Exception in commit_aw '||sqlerrm);
  raise;
End;

/*
this procedure will update and commit selected objects
this is called from kpi loading just before measures are aggregated in parallel. the main process
will still lock the limit cubes, but must release the measure cubes
*/
procedure commit_aw(p_locked_objects dbms_sql.varchar2_table) is
Begin
  commit_aw(p_locked_objects=>p_locked_objects,p_options=>null);
Exception when others then
  log_n('Exception in commit_aw '||sqlerrm);
  raise;
End;

/*
when we aggregate measures in parallel, just prior to aggregating the measures, we would like to update all the objects
so far, but we would not like the lock to be released
*/
procedure commit_aw(p_locked_objects dbms_sql.varchar2_table,p_options varchar2) is
Begin
  commit_aw_multi(p_locked_objects);
  if not(nvl(bsc_aw_utility.get_parameter_value(p_options,'no release lock',','),'N')='Y') then
    for i in 1..p_locked_objects.count loop
      release_lock(p_locked_objects(i));
    end loop;
    for i in 1..p_locked_objects.count loop
      bsc_aw_utility.remove_array_element(g_locked_objects,p_locked_objects(i));
    end loop;
  end if;
  bsc_aw_dbms_aw.execute('commit');
Exception when others then
  log_n('Exception in commit_aw '||sqlerrm);
  raise;
End;

/*
when we update object by object, for dim, interdependency is complex. a child level cannot be updated without
the parent. so we will loop and update
this does not work. we have to try and create 1 stmt with all objects and see if that works
we got errors like
update multi BSC_CCDIM_100_101_102_103.levels  (S: 04/13/2005 18:30:06  ,E: 04/13/2005 18:30:07 )
update multi BSC_D_BUG_COMPONENTS_AW  (S: 04/13/2005 18:30:07
Exception in execute update multi BSC_D_BUG_COMPONENTS_AW ORA-37023: Object BSC_AW!BSC_D_BUG_COMPONENTS_AW
cannot be updated without dimension BSC_AW!BSC_D_MANAGER_AW.
*/
procedure commit_aw_multi is
Begin
  commit_aw_multi(g_locked_objects);
Exception when others then
  log_n('Exception in commit_aw_multi '||sqlerrm);
  raise;
End;

procedure commit_aw_multi(p_locked_objects dbms_sql.varchar2_table) is
l_update_stmt varchar2(5000);
l_multi_update boolean;
Begin
  l_multi_update:=false;
  if bsc_aw_utility.get_db_version>=10 and nvl(bsc_aw_utility.get_parameter_value('exclusive lock'),'N')='N' then
    l_update_stmt:='update multi ';
    l_multi_update:=true;
    for i in 1..p_locked_objects.count loop
      if length(l_update_stmt||' '||p_locked_objects(i))<4000 then
        l_update_stmt:=l_update_stmt||' '||p_locked_objects(i);
      else
        l_multi_update:=false;
        exit;
      end if;
    end loop;
  end if;
  if l_multi_update then
    bsc_aw_dbms_aw.execute(l_update_stmt);
  else
    update_aw;
  end if;
Exception when others then
  log_n('Exception in commit_aw_multi '||sqlerrm);
  raise;
End;

procedure create_workspace(p_options varchar2) is
l_name varchar2(200);
Begin
  l_name:=get_aw_workspace_name;
  create_workspace(l_name,p_options);
  g_locked_objects.delete;
  g_attached:=true;
  g_attached_mode:='RW';
Exception when others then
  log_n('Exception in create_workspace '||sqlerrm);
  raise;
End;

procedure create_workspace(p_name varchar2,p_options varchar2) is
l_tablespace varchar2(100);
l_segmentsize varchar2(40);
Begin
  bsc_aw_utility.g_options.delete;
  bsc_aw_utility.parse_parameter_values(p_options,',',bsc_aw_utility.g_options);
  l_tablespace:=bsc_aw_utility.get_parameter_value(bsc_aw_utility.g_options,'TABLESPACE');
  if l_tablespace is null then
    bsc_aw_dbms_aw.execute('aw create '||p_name);
  else
    bsc_aw_dbms_aw.execute('aw create '||p_name||' tablespace '||l_tablespace);
  end if;
  l_segmentsize:=bsc_aw_utility.get_parameter_value(bsc_aw_utility.g_options,'SEGMENTSIZE');
  if l_segmentsize is not null then
    bsc_aw_dbms_aw.execute('aw SEGMENTSIZE '||l_segmentsize||' '||p_name);
    bsc_aw_dbms_aw.execute('aw ALLOCATE '||l_segmentsize||' '||p_name);
  end if;
  create_default_elements;
  --make the LOB nologging. this is the suggestion of the AW team as per Vladimir
  bsc_aw_utility.execute_stmt_ne('ALTER TABLE aw$'||p_name||' MODIFY LOB(awlob) (PCTVERSION 0 CACHE READS NOLOGGING)');
  bsc_aw_md_api.create_workspace(p_name);
  bsc_aw_md_api.set_upgrade_version(bsc_aw_utility.g_upgrade_version);
Exception when others then
  if sqlcode=-33270 then
    log_n('Workspace '||p_name||' already exists');
  else
    log_n('Exception in create_workspace '||sqlerrm);
    raise;
  end if;
End;

procedure drop_workspace(p_options varchar2) is
l_name varchar2(200);
Begin
  l_name:=get_aw_workspace_name;
  drop_workspace(l_name,p_options);
  g_locked_objects.delete;
Exception when others then
  log_n('Exception in drop_workspace '||sqlerrm);
  raise;
End;
--
procedure drop_workspace(p_name varchar2,p_options varchar2) is
Begin
  attach_workspace(p_name,'rw');
  bsc_aw_dbms_aw.execute('aw detach '||p_name);
  bsc_aw_dbms_aw.execute('aw delete '||p_name);
  g_attached:=false;
  g_attached_mode:=null;
  bsc_aw_md_api.drop_workspace(p_name);
Exception when others then
  if sqlcode=-33262 then
    log_n('workspace '||p_name||' does not exist');
  else
    log_n('Exception in drop_workspace '||sqlerrm);
    raise;
  end if;
End;

procedure exec_workspace_settings is
Begin
  --bsc_aw_dbms_aw.execute('SORTCOMPOSITE=FALSE');
  bsc_aw_dbms_aw.execute('MULTIPATHHIER=TRUE');
  bsc_aw_dbms_aw.execute('NASKIP=TRUE');
  bsc_aw_dbms_aw.execute('NASKIP2=TRUE');
  bsc_aw_dbms_aw.execute('DIVIDEBYZERO=TRUE');
  bsc_aw_dbms_aw.execute('OKNULLSTATUS=TRUE');
  bsc_aw_dbms_aw.execute('LIMIT.SORTREL=FALSE');
  bsc_aw_dbms_aw.execute('COMMAS=FALSE');
  bsc_aw_dbms_aw.execute('AWWAITTIME='||bsc_aw_utility.g_max_wait_time);
Exception when others then
  log_n('Exception in exec_workspace_settings '||sqlerrm);
  raise;
End;

function get_aw_workspace_name return varchar2 is
Begin
  return 'BSC_AW';
Exception when others then
  log_n('Exception in get_aw_workspace_name '||sqlerrm);
  raise;
End;

procedure create_default_elements is
Begin
  bsc_aw_dbms_aw.execute_ne('define temp_text text');
  bsc_aw_dbms_aw.execute_ne('define temp_number number');
  bsc_aw_dbms_aw.execute_ne('define temp_decimal decimal');
  bsc_aw_dbms_aw.execute_ne('define temp_integer integer');
  set_hash_partition_dim;
Exception when others then
  log_n('Exception in create_default_elements '||sqlerrm);
  raise;
End;

procedure set_hash_partition_dim is
l_cpu_count number;
Begin
  l_cpu_count:=bsc_aw_utility.get_cpu_count;
  bsc_aw_dbms_aw.execute_ne('dfn HASH_PARTITION_DIM dimension number(4)');
  for i in 0..l_cpu_count-1 loop
    bsc_aw_dbms_aw.execute('mnt HASH_PARTITION_DIM merge '||i);
  end loop;
Exception when others then
  log_n('Exception in set_hash_partition_dim '||sqlerrm);
  raise;
End;

procedure save_lock_set(p_set_name varchar2) is
Begin
  if g_lock_set.exists(p_set_name) then
    null;
  else
    g_lock_set(p_set_name).lock_set:=p_set_name;
  end if;
  g_lock_set(p_set_name).locked_objects.delete;
  g_lock_set(p_set_name).locked_objects:=g_locked_objects;
Exception when others then
  log_n('Exception in save_lock_set '||sqlerrm);
  raise;
End;

/*p_options:resync */
procedure lock_lock_set(p_set_name varchar2,p_options varchar2) is
l_lock_objects dbms_sql.varchar2_table;
Begin
  if g_lock_set.exists(p_set_name) then
    for i in 1..g_lock_set(p_set_name).locked_objects.count loop
      if bsc_aw_utility.in_array(g_locked_objects,g_lock_set(p_set_name).locked_objects(i))=false then
        l_lock_objects(l_lock_objects.count+1):=g_lock_set(p_set_name).locked_objects(i);
      end if;
    end loop;
    if l_lock_objects.count>0 then
      bsc_aw_utility.merge_array(g_locked_objects,l_lock_objects);
      get_lock(l_lock_objects,p_options);
    end if;
  end if;
Exception when others then
  log_n('Exception in lock_lock_set '||sqlerrm);
  raise;
End;

procedure commit_lock_set(p_set_name varchar2,p_options varchar2) is
Begin
  if g_lock_set.exists(p_set_name) then
    commit_aw(g_lock_set(p_set_name).locked_objects,p_options);
  end if;
Exception when others then
  log_n('Exception in commit_lock_set '||sqlerrm);
  raise;
End;

procedure update_aw is
Begin
  bsc_aw_utility.add_sqlerror(-34684,'ignore',null);--ignore if the ws is not alreay attached and there are no objects to update
  bsc_aw_dbms_aw.execute('update');
  bsc_aw_utility.remove_sqlerror(-34684,'ignore');
Exception when others then
  log_n('Exception in update_aw '||sqlerrm);
  raise;
End;

--------------------------------------------------------------------------------
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

END BSC_AW_MANAGEMENT;

/
