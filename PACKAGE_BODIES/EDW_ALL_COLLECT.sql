--------------------------------------------------------
--  DDL for Package Body EDW_ALL_COLLECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_ALL_COLLECT" AS
/*$Header: EDWACOLB.pls 120.0 2005/06/01 16:43:59 appldev noship $*/
l_levels EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_level_status EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_child_level_number EDW_OWB_COLLECTION_UTIL.numberTableType;
l_child_levels EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_child_fk EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_parent_pk EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_mapping_ids	EDW_OWB_COLLECTION_UTIL.numberTableType;
l_primary_src EDW_OWB_COLLECTION_UTIL.numberTableType;
l_primary_target EDW_OWB_COLLECTION_UTIL.numberTableType;
l_number_levels integer;
l_rank EDW_OWB_COLLECTION_UTIL.numberTableType;
l_child_start EDW_OWB_COLLECTION_UTIL.numberTableType;--this stores where
             --in  the big array the child level for the parent start

g_exec_flag boolean;
g_dimension_collect boolean:=true;
g_debug boolean:=false;
g_all_level_found boolean :=true;

procedure Collect_Dimension(Errbuf out NOCOPY varchar2,
			    Retcode out NOCOPY varchar2,
                            p_dim_name in varchar2) IS

l_found boolean;
l_run number:=1;
l_var number;
l_load_pk number;
l_src_table EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_src_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_tgt_table EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_tgt_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_src_cols number;
--
l_exception exception;
--
Begin
g_collection_start_date:=sysdate;
g_collect_fact:=false;
g_collect_dim:=true;
g_status:=true;
g_conc_program_id:=0;
g_object_name:=upper(p_dim_name);
g_object_type:='DIMENSION';
g_conc_program_id:=FND_GLOBAL.Conc_request_id;--my conc id
g_resp_id:=FND_GLOBAL.RESP_ID;
g_conc_program_name :=p_dim_name||'_T'; --assume. no harm
retcode:='0';
g_logical_object_type:='DIMENSION';

--first set up the conc log
 --EDW_OWB_COLLECTION_UTIL.setup_conc_program_log(p_dim_name);
 EDW_OWB_COLLECTION_UTIL.init_all(p_dim_name,null,'bis.edw.loader_load_dimension');
 EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Collect Dimension for '||p_dim_name||get_time,FND_LOG.LEVEL_PROCEDURE);
 g_load_pk:=EDW_OWB_COLLECTION_UTIL.inc_g_load_pk;
 EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('g_load_pk='||g_load_pk,FND_LOG.LEVEL_STATEMENT);
 if g_load_pk is null then
   errbuf:=g_status_message;
   retcode:='2';
   return_with_error(g_load_pk,'LOG');
   return;
 end if;
EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Concurrent id '||g_conc_program_id||', and conc prog name '||g_conc_program_name,
FND_LOG.LEVEL_PROCEDURE);
 g_object_id:=EDW_OWB_COLLECTION_UTIL.get_object_id(g_object_name);
 if g_object_id=-1 then
   errbuf:=EDW_OWB_COLLECTION_UTIL.g_status_message;
   retcode:='2';
   return_with_error(g_load_pk,'LOG');
   return;
 end if;

--first make sure that another coll for the same object is not running
--if there is none, it inserts a row into edw_coll_progress_log
EDW_OWB_COLLECTION_UTIL.set_debug(true);
l_var:= EDW_OWB_COLLECTION_UTIL.is_another_coll_running(g_object_name, g_object_type);
EDW_OWB_COLLECTION_UTIL.set_debug(false);

if l_var=2 then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('All Clear to proceed',FND_LOG.LEVEL_STATEMENT);
end if;

if l_var=1 then
  g_status_message:=EDW_OWB_COLLECTION_UTIL.get_message('EDW_NEW_COLLECTION_RUNNING');
  errbuf:=g_status_message;
  retcode:='2';
  return_with_error(g_load_pk,'LOG');
  return;
elsif l_var=0 then
  g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
  errbuf:=g_status_message;
  retcode:='2';
  return_with_error(g_load_pk,'LOG');
  return;
end if;

 if EDW_OWB_COLLECTION_UTIL.log_collection_start(g_object_name,g_object_id,g_object_type,
   g_collection_start_date,g_conc_program_id,g_load_pk) =false then
   errbuf:=g_status_message;
   retcode:='2';
   return_with_error(g_load_pk,'LOG');
   return;
 end if;

init_all;

if g_status=false then
  errbuf:=g_status_message;
  retcode:='2';
  return_with_error(g_load_pk,'LOG');
  return;
end if;
if g_debug then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('pre_coll'||get_time,FND_LOG.LEVEL_PROCEDURE);
end if;
insert_into_load_progress(g_load_pk,g_object_name,g_object_id,'Pre Coll Hook',sysdate,null,'PRE-LEVEL',
'PRE-COLL-HOOK',10,'I');
if EDW_COLLECTION_HOOK.pre_coll(g_object_name) = true then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished pre_coll with success'||get_time,FND_LOG.LEVEL_PROCEDURE);
else
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished pre_coll with error'||get_time,FND_LOG.LEVEL_PROCEDURE);
  g_status_message:=EDW_OWB_COLLECTION_UTIL.get_message('EDW_FINISHED_PRECOLL_ERROR');
  errbuf:=g_status_message;
  retcode:='2';
  return_with_error(g_load_pk,'LOG');
  return;
end if;
insert_into_load_progress(g_load_pk,null,null,null,null,sysdate,null,null,10,'U');
if g_debug then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('pre_dimension_coll'||get_time,FND_LOG.LEVEL_PROCEDURE);
end if;
insert_into_load_progress(g_load_pk,g_object_name,g_object_id,'Pre Dimension Coll Hook',sysdate,null,'PRE-LEVEL',
'PRE-DIM-COLL-HOOK',11,'I');
if EDW_COLLECTION_HOOK.pre_dimension_coll(g_object_name) = true then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished pre_dimension_coll with success'||get_time,FND_LOG.LEVEL_PROCEDURE);
else
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished pre_dimension_coll with error'||get_time,FND_LOG.LEVEL_PROCEDURE);
  g_status_message:=EDW_OWB_COLLECTION_UTIL.get_message('EDW_FINISHED_PREDIM_ERROR');
  errbuf:=g_status_message;
  retcode:='2';
  return_with_error(g_load_pk,'LOG');
  return;
end if;
insert_into_load_progress(g_load_pk,null,null,null,null,sysdate,null,null,11,'U');

EDW_OWB_COLLECTION_UTIL.set_parallel(g_parallel);

--push naedw
insert_into_load_progress(g_load_pk,g_object_name,g_object_id,'Load NA_EDW',sysdate,null,'PRE-LEVEL',
'NAEDW_LOAD',12,'I');

EDW_NAEDW_PUSH.PUSH(Errbuf,retcode,g_object_name,g_debug);
if retcode ='2' then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('EDW_NAEDW_PUSH.PUSH returned with error',FND_LOG.LEVEL_ERROR);
  return;
end if;
insert_into_load_progress(g_load_pk,null,null,null,null,sysdate,null,null,12,'U');

EDW_OWB_COLLECTION_UTIL.set_up(p_dim_name);
if g_debug then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished EDW_OWB_COLLECTION_UTIL.setup , Time '||get_time,FND_LOG.LEVEL_PROCEDURE);
end if;

insert_into_load_progress(g_load_pk,g_object_name,g_object_id,'Read Metadata',sysdate,null,'PRE-LEVEL',
'METADATA_READ',13,'I');

EDW_OWB_COLLECTION_UTIL.Get_Level_Relations(
	l_levels,
	l_level_status,
	l_child_level_number,
	l_child_levels,
	l_child_fk,
    l_parent_pk,
    l_number_levels);
if g_debug then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished EDW_OWB_COLLECTION_UTIL.Get_Level_Relations, Time '||get_time,
  FND_LOG.LEVEL_PROCEDURE);
  EDW_OWB_COLLECTION_UTIL.write_to_log_file('Results',FND_LOG.LEVEL_STATEMENT);
  for i in 1..l_number_levels loop
    EDW_OWB_COLLECTION_UTIL.write_to_log_file(l_levels(i)||'('||l_level_status(i)||')  '||l_child_level_number(i),
    FND_LOG.LEVEL_STATEMENT);
  end loop;
  l_run:=0;
  for i in 1..l_number_levels loop
    for j in 1..l_child_level_number(i) loop
      l_run:=l_run+1;
      EDW_OWB_COLLECTION_UTIL.write_to_log_file(l_child_levels(l_run)||'  '||l_child_fk(l_run)||'  '||l_parent_pk(l_run),
      FND_LOG.LEVEL_STATEMENT);
    end loop;
  end loop;
end if;

if l_number_levels=0 then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('ERROR: In EDW_OWB_COLLECTION_UTIL.Get_Level_Relations,No levels found..'||get_time
  ,FND_LOG.LEVEL_PROCEDURE);
  g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
  g_status:=false;
  errbuf:=g_status_message;
  retcode:='2';
  return_with_error(g_load_pk,'LOG');
  return;
end if;

EDW_OWB_COLLECTION_UTIL.Get_mapping_ids(
	l_mapping_ids,
	l_primary_src,
	l_primary_target);

if g_debug then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished EDW_OWB_COLLECTION_UTIL.Get_mapping_ids, Time '||get_time,
  FND_LOG.LEVEL_PROCEDURE);
end if;

--find out NOCOPY any skipped levels
if EDW_OWB_COLLECTION_UTIL.get_col_col_in_map(null,p_dim_name,l_src_table,l_src_cols,l_tgt_table,
  l_tgt_cols,l_number_src_cols)=false then
  g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
  g_status:=false;
  errbuf:=g_status_message;
  retcode:='2';
  return_with_error(g_load_pk,'LOG');
end if;
if EDW_OWB_COLLECTION_UTIL.find_skip_attributes(g_object_name,g_object_type,g_skip_cols,
  g_number_skip_cols)=false then
  errbuf:=g_status_message;
  retcode:='2';
  return_with_error(g_load_pk,'LOG');
  return;
end if;

if g_number_skip_cols>0 then
  --see if in any level, all the cols are skipped. then the whole level is not needed
  declare
    l_found boolean;
    l_level_full_skip EDW_OWB_COLLECTION_UTIL.varcharTableType;
    l_number_level_full_skip number:=0;
    l_levels_copy EDW_OWB_COLLECTION_UTIL.varcharTableType;
    l_level_status_copy EDW_OWB_COLLECTION_UTIL.varcharTableType;
    l_child_level_number_copy EDW_OWB_COLLECTION_UTIL.numberTableType;
    l_child_levels_copy EDW_OWB_COLLECTION_UTIL.varcharTableType;
    l_child_fk_copy EDW_OWB_COLLECTION_UTIL.varcharTableType;
    l_parent_pk_copy EDW_OWB_COLLECTION_UTIL.varcharTableType;
    l_number_levels_copy number;
    l_mapping_ids_copy EDW_OWB_COLLECTION_UTIL.numberTableType;
    l_primary_src_copy EDW_OWB_COLLECTION_UTIL.numberTableType;
    l_primary_target_copy EDW_OWB_COLLECTION_UTIL.numberTableType;
    l_ptr number;
  begin
    for i in 1..l_number_levels loop
      l_found:=false;
      for j in 1..l_number_src_cols loop
        if l_src_table(j)=l_levels(i) then
          if EDW_OWB_COLLECTION_UTIL.value_in_table(g_skip_cols,g_number_skip_cols,l_tgt_cols(j))=false then
            l_found:=true;
            exit;
          end if;
        end if;
      end loop;
      if l_found=false then
        l_number_level_full_skip:=l_number_level_full_skip+1;
        l_level_full_skip(l_number_level_full_skip):=l_levels(i);
        g_number_skip_levels:=g_number_skip_levels+1;
        g_skip_levels(g_number_skip_levels):=l_levels(i);
      end if;
    end loop;
    if g_debug then
      EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Number of levels fully turned off '||l_number_level_full_skip,
      FND_LOG.LEVEL_STATEMENT);
      for i in 1..l_number_level_full_skip loop
        EDW_OWB_COLLECTION_UTIL.write_to_log_file(l_level_full_skip(i),FND_LOG.LEVEL_STATEMENT);
      end loop;
    end if;
    if l_number_level_full_skip>0 then
      l_levels_copy:=l_levels;
      l_level_status_copy:=l_level_status;
      l_child_level_number_copy:=l_child_level_number;
      l_child_levels_copy:=l_child_levels;
      l_child_fk_copy:=l_child_fk;
      l_parent_pk_copy:=l_parent_pk;
      l_number_levels_copy:=l_number_levels;
      l_mapping_ids_copy:=l_mapping_ids;
      l_primary_src_copy:=l_primary_src;
      l_primary_target_copy:=l_primary_target;
      l_run:=1;
      for i in 1..l_number_levels loop
        l_child_level_number(i):=0;
      end loop;
      l_number_levels:=0;
      l_ptr:=0;
      for i in 1..l_number_levels_copy loop
        if EDW_OWB_COLLECTION_UTIL.value_in_table(l_level_full_skip,l_number_level_full_skip,l_levels_copy(i))=false then
          l_number_levels:=l_number_levels+1;
          l_levels(l_number_levels):=l_levels_copy(i);
          l_level_status(l_number_levels):=l_level_status_copy(i);
          l_mapping_ids(l_number_levels):=l_mapping_ids_copy(i);
          l_primary_src(l_number_levels):=l_primary_src_copy(i);
          l_primary_target(l_number_levels):=l_primary_target_copy(i);
          if l_child_level_number_copy(i)>0 then
            for j in l_run..(l_run+l_child_level_number_copy(i)-1) loop
              if EDW_OWB_COLLECTION_UTIL.value_in_table(l_level_full_skip,l_number_level_full_skip,
                l_child_levels_copy(j))=false then
                l_child_level_number(l_number_levels):=l_child_level_number(l_number_levels)+1;
                l_ptr:=l_ptr+1;
                l_child_levels(l_ptr):=l_child_levels_copy(j);
                l_child_fk(l_ptr):=l_child_fk_copy(j);
                l_parent_pk(l_ptr):=l_parent_pk_copy(j);
              end if;
            end loop;
          end if;
          l_run:=l_run+l_child_level_number_copy(i);
          --l_child_level_number(l_number_levels):=l_child_level_number_copy(i);
        else
          l_run:=l_run+l_child_level_number_copy(i);
        end if;
      end loop;
    end if;--if l_number_level_full_skip>0 then
  end;
  --see how many cols are actually mapped
  declare
    l_count number;
  begin
    l_count:=0;
    for j in 1..l_number_src_cols loop
      if EDW_OWB_COLLECTION_UTIL.value_in_table(g_skip_cols,g_number_skip_cols,l_tgt_cols(j))=false then
        l_count:=l_count+1;
      end if;
    end loop;
    if l_count<=g_check_fk_change_number then
      g_check_fk_change:=false;
      if g_debug then
        EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('The number of columns mapped is < '||g_check_fk_change_number||'. Turning OFF fk '||
        'change check',FND_LOG.LEVEL_STATEMENT);
      end if;
    end if;
    --4207268
    /*
    when smart update is false, turn off fk change check. this means when dim is loaded, it will pull in all the levels
    in the select and from clause.
    */
    if g_smart_update=false then
      g_check_fk_change:=false;
      if g_debug then
        write_to_log_file_n('Smart Update false. Turning OFF fk change check');
      end if;
    end if;
  end;
end if;--if g_number_skip_cols>0 then

if l_number_levels=0 then
  g_status_message:=EDW_OWB_COLLECTION_UTIL.get_message('EDW_ALL_LEVELS_TURNED_OFF');
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(g_status_message,FND_LOG.LEVEL_STATEMENT);
  return_with_success('LOG',null,g_load_pk);
  return;
end if;

if g_number_skip_cols>0 then
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('After turning off levels that are not needed',FND_LOG.LEVEL_STATEMENT);
    for i in 1..l_number_levels loop
      EDW_OWB_COLLECTION_UTIL.write_to_log_file(l_levels(i)||'('||l_level_status(i)||')  '||l_child_level_number(i)||' '||l_mapping_ids(i)
      ||' '||l_primary_src(i)||' '||l_primary_target(i),FND_LOG.LEVEL_STATEMENT);
    end loop;
    l_run:=0;
    for i in 1..l_number_levels loop
      for j in 1..l_child_level_number(i) loop
        l_run:=l_run+1;
        EDW_OWB_COLLECTION_UTIL.write_to_log_file(l_child_levels(l_run)||'  '||l_child_fk(l_run)||'  '||l_parent_pk(l_run),
        FND_LOG.LEVEL_STATEMENT);
      end loop;
    end loop;
  end if;
end if;

--arrange according to the reqd order. implement the rank scheme
--init the rank
Set_Rank;
if g_status = false then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Could not determine the ranks for the levels in the hierarchies, Time '||get_time,
  FND_LOG.LEVEL_STATEMENT);
  g_status_message:=EDW_OWB_COLLECTION_UTIL.get_message('EDW_NO_RANK_HIER');
  errbuf:=g_status_message;
  retcode:='2';
  return_with_error(g_load_pk,'LOG');
  return;
end if;

if g_debug then
  for i in 1..l_number_levels loop
    EDW_OWB_COLLECTION_UTIL.write_to_log_file('level '||l_levels(i)||', rank '||l_rank(i),FND_LOG.LEVEL_STATEMENT);
  end loop;
end if;

--arrange in the order of the rank
Order_by_Rank;

if g_status = false then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Could not order by ranks, Time '||get_time,FND_LOG.LEVEL_STATEMENT);
  g_status_message:=EDW_OWB_COLLECTION_UTIL.get_message('EDW_NO_ORDER_BY_RANK');
  errbuf:=g_status_message;
  retcode:='2';
  return_with_error(g_load_pk,'LOG');
  return;
end if;

if g_debug then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('The ordered levels'||get_time,FND_LOG.LEVEL_STATEMENT);
  for i in 1..l_number_levels loop
   EDW_OWB_COLLECTION_UTIL.write_to_log_file('level '||g_level_order(i),FND_LOG.LEVEL_STATEMENT);
  end loop;
end if;

if get_snapshot_log = false then
  errbuf:=g_status_message;
  retcode:='2';
  return_with_error(g_load_pk,'LOG');
  return;
end if;

if find_data_alignment_cols(g_object_name)=false then
  errbuf:=g_status_message;
  retcode:='2';
  return_with_error(g_load_pk,'LOG');
  return;
end if;
--see if the dim can have parallel drill down where a dbms job is launched after a level is
--loaded . this job will drill down the changes to the child levels
--this approach cannot be used if
--if error recovery
--or if there is na_edw update
--or if this is initial load
--or if there is push down
find_parallel_drill_down(g_level_order,l_number_levels);
if g_debug then
  if g_parallel_drill_down then
    write_to_log_file_n('Parallel drill down Enabled');
  else
    write_to_log_file_n('Parallel drill down Disabled');
  end if;
end if;
if g_parallel_drill_down then
  if EDW_OWB_COLLECTION_UTIL.create_dd_status_table(
    g_dd_status_table,
    g_level_order,
    l_number_levels
    )=false then
    raise l_exception;
  end if;
else
  --create dummy g_dd_status_table table. this table is used to
  --check for error recovery
  if EDW_OWB_COLLECTION_UTIL.create_dd_status_table(
    g_dd_status_table,
    g_level_order,
    null
    )=false then
    raise l_exception;
  end if;
end if;
insert_into_load_progress(g_load_pk,null,null,null,null,sysdate,null,null,13,'U');

Collect_Each_Level;
if g_status=false then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('ERROR: IN Collect_Each_Level '||g_status_message,FND_LOG.LEVEL_ERROR);
  errbuf:='FINISH COLLECT EACH LEVEL WITH ERROR '||g_status_message;
  retcode:='2';
  return_with_error(g_load_pk,'LOG');
  return;
end if;

insert_into_load_progress_nd(g_load_pk,g_object_name,g_object_id,'Push Down Levels',sysdate,null,'LEVEL',
'DIMENSION','PD10','I');
--inside EDW_PUSH_DOWN_DIMS.push_down_all_levels we see which all levels need push down
if EDW_PUSH_DOWN_DIMS.push_down_all_levels(g_object_name,
    l_levels,
	l_child_level_number,
	l_child_levels,
	l_child_fk,
	l_parent_pk,
    l_number_levels,
    g_level_order,
    g_level_snapshot_logs,
    g_debug,
    g_parallel,
    g_collection_size,
    g_bis_owner,
    g_table_owner,
    false,
    g_forall_size,
    g_update_type,
    g_load_pk,
    g_op_table_space,
    g_dim_push_down,
    g_rollback,
    g_thread_type,
    g_max_threads,
    g_min_job_load_size,
    g_sleep_time,
    g_hash_area_size,
    g_sort_area_size,
    g_trace,
    g_read_cfig_options,
    g_stg_join_nl
  ) =false then
  errbuf:='FINISH push_down_all_levels WITH ERROR '||EDW_PUSH_DOWN_DIMS.g_status_message;
  retcode:='2';
  insert_into_load_progress_nd(g_load_pk,null,null,null,null,sysdate,null,null,'PD10','U');
  return_with_error(g_load_pk,'LOG');
  return;
end if;
insert_into_load_progress_nd(g_load_pk,null,null,null,null,sysdate,null,null,'PD10','U');

if g_dimension_collect then
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Going to call EDW_SUMMARY_COLLECT.collect_dimension',FND_LOG.LEVEL_PROCEDURE);
  end if;
  insert_into_load_progress_nd(g_load_pk,g_object_name,g_object_id,'Dimension Collection',sysdate,null,'DIMENSION',
  'DIMENSION','DC10','I');
  EDW_SUMMARY_COLLECT.collect_dimension_main(
    g_conc_program_id,
    g_conc_program_name,
    p_dim_name,
    l_levels,
    l_child_level_number,
    l_child_levels,
    l_child_fk,
    l_parent_pk,
    g_level_snapshot_logs,
    l_number_levels,
    g_debug,
    g_exec_flag,
    g_bis_owner,
    g_parallel,
    g_collection_size,
    g_table_owner,
    g_forall_size,
    g_update_type,
    g_level_order,
    g_skip_cols,
    g_number_skip_cols,
    g_load_pk,
    g_fresh_restart,
    g_op_table_space,
    g_rollback,
    g_ltc_merge_use_nl,
    g_dim_inc_refresh_derv,
    g_check_fk_change,
    g_ok_switch_update,
    g_stg_join_nl,
    g_thread_type,
    g_max_threads,
    g_min_job_load_size,
    g_sleep_time,
    g_job_status_table,
    g_hash_area_size,
    g_sort_area_size,
    g_trace,
    g_read_cfig_options,
    g_max_fk_density,
    g_analyze_frequency,
    g_parallel_drill_down,
    g_dd_status_table
    );
  insert_into_load_progress_nd(g_load_pk,null,null,null,null,sysdate,null,null,'DC10','U');
  if EDW_SUMMARY_COLLECT.check_error=false then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('ERROR:EDW_SUMMARY_COLLECT.Collect_Dimension, '||
        EDW_SUMMARY_COLLECT.get_status_message||' Time '||get_time,FND_LOG.LEVEL_ERROR);
    g_status_message:=EDW_SUMMARY_COLLECT.get_status_message;
    errbuf:=g_status_message;
    retcode:='2';
    return_with_error(g_load_pk,'LOG');
    return;
  else
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished EDW_SUMMARY_COLLECT.Collect_Dimension,Time '||get_time,
    FND_LOG.LEVEL_PROCEDURE);
    /*
      get the record of the lowest level collection from the table edw_temp_collection_log
    */
    if get_temp_log_data(g_object_name, g_object_type)=false then
      errbuf:=g_status_message;
      retcode:='2';
      return_with_error(g_load_pk,'NO-LOG');
      return;
    end if;
  end if;

end if;--if g_dimension_collect then
--g_dd_status_table present in the database shows there was an error
if edw_owb_collection_util.drop_level_UL_tables(g_object_id,g_bis_owner)=false then
  null;
end if;
if edw_owb_collection_util.drop_table(g_dd_status_table)=false then
  null;
end if;
if g_debug then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('post_dimension_coll'||get_time,FND_LOG.LEVEL_PROCEDURE);
end if;
insert_into_load_progress(g_load_pk,g_object_name,g_object_id,'Post Dimension Coll Hook',sysdate,null,'POST-LEVEL',
'POST-DIM-COLL-HOOK',14,'I');
if EDW_COLLECTION_HOOK.post_dimension_coll(g_object_name) = true then
 EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished post_dimension_coll with success'||get_time,FND_LOG.LEVEL_PROCEDURE);
 insert_into_load_progress(g_load_pk,null,null,null,null,sysdate,null,null,14,'U');
 return_with_success('LOG',null,g_load_pk);
 if g_status=false then
  return;
 end if;
 --if there is a diamond issue then flag the user
 if g_diamond_issue then
   retcode:='1';
   errbuf:=g_status_message;
 end if;
else
 EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished post_dimension_coll with error'||get_time,FND_LOG.LEVEL_ERROR);
 g_status_message:=EDW_OWB_COLLECTION_UTIL.get_message('EDW_FINISHED_POSTDIM_ERROR');
 insert_into_load_progress(g_load_pk,null,null,null,null,sysdate,null,null,14,'U');
 errbuf:=g_status_message;
 retcode:='2';
 return_with_error(g_load_pk,'LOG');
 return;
end if;
if g_dim_inc_refresh_derv then
  if refresh_dim_derv_facts(g_object_name,l_load_pk)=false then
    errbuf:=g_status_message;
    retcode:='2';
    return_with_error(l_load_pk,'NO-LOG');
    return;
  end if;
end if;
clean_up;--cleans up the progress log
/* this call is for workflow for now...*/
 if g_debug then
   EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('post_coll'||get_time,FND_LOG.LEVEL_PROCEDURE);
 end if;
 if EDW_COLLECTION_HOOK.post_coll(g_object_name) = true then
   EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished post_coll with success'||get_time,FND_LOG.LEVEL_PROCEDURE);
 else
   EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished post_coll with error'||get_time,FND_LOG.LEVEL_ERROR);
 end if;
Exception
  when l_exception then
    errbuf:=g_status_message;
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(g_status_message,FND_LOG.LEVEL_ERROR);
    retcode:='2';
    return_with_error(g_load_pk,'LOG');
  when others then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('ERROR In EDW_ALL_COLLECT.Collect_Dimension,
      Error mesg:'||sqlerrm||' Time '||get_time,FND_LOG.LEVEL_ERROR);
    g_status_message:=sqlerrm;
    errbuf:=g_status_message;
    retcode:='2';
    return_with_error(g_load_pk,'LOG');
End;--procedure Collect_Dimension(p_dim_name varchar2) IS

PROCEDURE Order_by_Rank IS
l_temp varchar2(400);
l_temp_rank number;
l_temp_map number;
l_temp_src number;
l_temp_target number;

--bubble sort?? :( for a few levels its more than enough!
Begin
 if g_debug then
   EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('In Order by Rank'||get_time,FND_LOG.LEVEL_STATEMENT);
 end if;
 g_level_order:=l_levels;
 g_mapping_ids:=l_mapping_ids;
 g_primary_src:=l_primary_src;
 g_primary_target:=l_primary_target;

 for i in 1..l_number_levels-1 loop
   for j in i..l_number_levels-1 loop
     if l_rank(j) < l_rank(j+1) then
	l_temp:= g_level_order(j+1);
        g_level_order(j+1):=g_level_order(j);
        g_level_order(j):=l_temp;
        l_temp_rank:=l_rank(j+1);
        l_rank(j+1):=l_rank(j);
        l_rank(j):=l_temp_rank;
        l_temp_map:=g_mapping_ids(j+1);
        g_mapping_ids(j+1):=g_mapping_ids(j);
        g_mapping_ids(j):=l_temp_map;
	l_temp_src:=g_primary_src(j+1);
	g_primary_src(j+1):=g_primary_src(j);
	g_primary_src(j):=l_temp_src;
	l_temp_target:=g_primary_target(j+1);
	g_primary_target(j+1):=g_primary_target(j);
	g_primary_target(j):=l_temp_target;
     end if;
   end loop;
 end loop;
 if g_debug then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished order by Rank'||get_time,FND_LOG.LEVEL_STATEMENT);
 end if;
Exception when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Error in order by rank '||sqlerrm||' Time '||get_time,FND_LOG.LEVEL_ERROR);
End;--PROCEDURE Order_by_Rank IS



PROCEDURE Set_Rank IS

l_run integer:=0;
Begin
if g_debug then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('In set rank'||get_time,FND_LOG.LEVEL_STATEMENT);
end if;
--init the rank
for i in 1..l_number_levels loop
  l_rank(i):=0;
end loop;
Set_l_child_start;
Set_Rank_Recursive(l_levels(1),l_rank(1));
if g_debug then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished set rank'||get_time,FND_LOG.LEVEL_STATEMENT);
end if;
Exception when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Error in set rank '||sqlerrm||' Time '||get_time,FND_LOG.LEVEL_ERROR);
End;--PROCEDURE Set_Rank


PROCEDURE Set_l_child_start IS
l_run integer :=1;
Begin
 if g_debug then
   EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('In Set_l_child_start'||get_time,FND_LOG.LEVEL_STATEMENT);
 end if;
 for i in 1..l_number_levels loop
   l_child_start(i):=l_run;
   for j in 1..l_child_level_number(i) loop
     l_run:=l_run+1;
   end loop;
 end loop;
 if g_debug then
   EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished Set_l_child_start'||get_time,FND_LOG.LEVEL_STATEMENT);
 end if;
Exception when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Error in Set_l_child_start '||sqlerrm||' Time '||get_time,FND_LOG.LEVEL_ERROR);
End;--PROCEDURE Set_l_child_start IS


PROCEDURE Set_Rank_Recursive(p_level_in varchar2, p_rank number) IS
l_index integer;
Begin
--for a level , set the rank of all levels underneath to my rank-1;
--do this as a recursion
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('In Set_Rank_Recursive, params: '||p_level_in||','||p_rank||get_time,
    FND_LOG.LEVEL_STATEMENT);
  end if;
  l_index:=Get_index(p_level_in);
  if l_rank(l_index) >= p_rank then --only if this rank is greater...
    Set_Level_Rank(l_index,p_rank);
    for i in 1..l_child_level_number(l_index) loop
       Set_Rank_Recursive(l_child_levels(l_child_start(l_index)+(i-1)),p_rank-1);
    end loop;
  end if;
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished Set_Rank_Recursive'||get_time,FND_LOG.LEVEL_STATEMENT);
  end if;
Exception when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Error in Set_Rank_Recursive '||sqlerrm||' Time '||get_time,FND_LOG.LEVEL_ERROR);
End;--PROCEDURE Set_Rank_Recursive(p_level_in varchar2)



FUNCTION Get_index(p_level_in varchar2) RETURN NUMBER IS
Begin
if g_debug then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('In Get_index, params: '||p_level_in||get_time,FND_LOG.LEVEL_STATEMENT);
end if;
for i in 1..l_number_levels loop
  if l_levels(i)=p_level_in then
    return i;
  end if;
end loop;
if g_debug then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished Get_index'||get_time,FND_LOG.LEVEL_STATEMENT);
end if;
return 0;
End;--FUNCTION Get_index(p_level_in varchar2) RETURN NUMBER IS



PROCEDURE Set_Level_Rank(p_index_in integer, p_rank number) IS
Begin
  l_rank(p_index_in):=p_rank;
End;


FUNCTION Get_Rank(p_level_in varchar2) RETURN NUMBER IS
Begin
for i in 1..l_number_levels loop
 if l_levels(i)=p_level_in then
  return l_rank(i);
 end if;
end loop;
return 0;--should never come here
End;--FUNCTION Get_Rank(p_level_in varchar2) RETURN NUMBER

PROCEDURE Collect_Each_Level IS
l_status boolean:=true;
l_latest number:=0;
l_start_index number:=1;
l_object_name varchar2(400);
l_object_type varchar2(400);
l_temp_log_flag boolean:=false;
----------skipping-----------------------------
l_skip_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_skip_cols number;
l_src_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_tgt_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_numer_cols number;
-----------------------------------------------
-----------data alignment----------------------
l_da_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_da_cols number;
l_da_table varchar2(400);
l_pp_table varchar2(400);
-----------------------------------------------
-----------smart update---------------------
l_smart_update_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_smart_update_cols number;
---------------------------------------------
l_ok_table varchar2(80);
--the number of elements in these array=g_max_threads
l_ok_low_end EDW_OWB_COLLECTION_UTIL.numberTableType;
l_ok_high_end EDW_OWB_COLLECTION_UTIL.numberTableType;
l_ok_end_count integer;
l_job_id EDW_OWB_COLLECTION_UTIL.numberTableType;
l_number_jobs number;
Begin
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('In Collect_Each_Level'||get_time,FND_LOG.LEVEL_STATEMENT);
  end if;
 --for each level, get the mapping id and call the collection program
 --why start from 2? because the top level need not be collected
 if upper(g_level_order(1)) = substr(g_object_name,1,length(g_object_name)-2)||'_A_LTC' then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('The all level '||g_level_order(1)||' found',FND_LOG.LEVEL_STATEMENT);
  g_all_level_found:=true;
  l_start_index:=2;
 else
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('All level '||substr(g_object_name,1,length(g_object_name)-2)||'_A_LTC not found'
  ,FND_LOG.LEVEL_STATEMENT);
  g_all_level_found:=false;
  l_start_index:=1;
 end if;
 for i in l_start_index..l_number_levels loop
   EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Going to collect for '||g_level_order(i),FND_LOG.LEVEL_STATEMENT);
   l_latest:=i;
  --pass g_level_order(i)
   if i=l_number_levels then --log into the temp log table only if this is the lowest level
     l_temp_log_flag:=true;
   end if;
   l_numer_cols:=0;
   l_number_skip_cols:=0;
   if EDW_OWB_COLLECTION_UTIL.get_obj_obj_map_details(g_level_order(i),g_object_name,null,l_src_cols,l_tgt_cols,
   l_numer_cols)=false then
     g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
     EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('EDW_OWB_COLLECTION_UTIL.get_obj_obj_map_details returned with error',
     FND_LOG.LEVEL_STATEMENT);
     EDW_OWB_COLLECTION_UTIL.write_to_log_file(g_status_message,FND_LOG.LEVEL_STATEMENT);
     g_status:=false;
     return;
   end if;
   -------------skip columns------------------------
   for j in 1..l_numer_cols loop
     for k in 1..g_number_skip_cols loop
       if l_tgt_cols(j)=g_skip_cols(k) then
         l_number_skip_cols:=l_number_skip_cols+1;
         l_skip_cols(l_number_skip_cols):=l_src_cols(j);
         exit;
       end if;
     end loop;
   end loop;
   -------------get data alignment columns---------
   l_number_da_cols:=0;
   if g_number_da_cols>0 then
     for j in 1..l_numer_cols loop
       for k in 1..g_number_da_cols loop
         if l_tgt_cols(j)=g_da_cols(k) then
           l_number_da_cols:=l_number_da_cols+1;
           l_da_cols(l_number_da_cols):=l_src_cols(j);
           exit;
         end if;
       end loop;
     end loop;
   end if;
   if i=l_number_levels then --this is the lowest level
     l_da_table:=g_da_table;
     l_pp_table:=g_pp_table;
   else
     l_da_table:=EDW_OWB_COLLECTION_UTIL.get_DA_table(g_level_order(i),g_table_owner);
     l_pp_table:=EDW_OWB_COLLECTION_UTIL.get_PP_table(g_level_order(i),g_table_owner);
   end if;
   -------------smart update columns------------------
   l_number_smart_update_cols:=0;
   for k in 1..g_number_smart_update_cols loop
     for j in 1..l_numer_cols loop
       if g_smart_update_cols(k)=l_tgt_cols(j) then
         l_number_smart_update_cols:=l_number_smart_update_cols+1;
         l_smart_update_cols(l_number_smart_update_cols):=l_src_cols(j);
         exit;
       end if;
     end loop;
   end loop;
   -------------------------------------------------
   insert_into_load_progress_nd(g_load_pk,g_level_order(i),g_primary_target(i),'Collect Level',sysdate,null,'LEVEL',
   'LEVEL-LOAD',100+i,'I');
   EDW_MAPPING_COLLECT.COLLECT_MAIN(
   g_object_name,
   g_mapping_ids(i),
   'LEVEL',
   g_primary_src(i), --LSTG id
   g_primary_target(i), --LTC id
   g_level_order(i), --just the name of the LTC for logging
   g_object_type,
   g_conc_program_id,
   g_conc_program_name,
   l_status,
   false, --fact audit
   false, --net change
   null, --fact audit name
   null, --net change name
   null, --fact audit is name
   null, --net change is name
   g_debug,
   g_duplicate_collect,
   g_exec_flag,
   g_request_id,
   g_collection_size,
   g_parallel,
   g_table_owner,
   g_bis_owner,
   l_temp_log_flag,
   g_forall_size,
   g_update_type,
   g_mode,
   g_explain_plan_check,
   null,
   g_key_set,
   g_instance_type,
   g_load_pk,
   l_skip_cols,
   l_number_skip_cols,
   g_fresh_restart,
   g_op_table_space,
   l_da_cols,
   l_number_da_cols,
   l_da_table,
   l_pp_table,
   g_master_instance,
   g_rollback,
   g_skip_levels,
   g_number_skip_levels,
   g_smart_update,
   g_fk_use_nl,
   g_fact_smart_update,
   g_auto_dang_table_extn,
   g_auto_dang_recovery,--all the levels get the same flag
   g_create_parent_table_records,
   l_smart_update_cols,
   l_number_smart_update_cols,
   g_check_fk_change,
   g_stg_join_nl,
   g_ok_switch_update,
   g_stg_make_copy_percentage,
   g_hash_area_size,
   g_sort_area_size,
   g_trace,
   g_read_cfig_options,
   g_min_job_load_size,
   g_sleep_time,
   g_thread_type,
   g_max_threads,
   g_job_status_table,
   g_analyze_frequency,
   g_parallel_drill_down,
   g_dd_status_table
   );
   insert_into_load_progress_nd(g_load_pk,null,null,null,null,sysdate,null,null,100+i,'U');
   if l_status=true then
     EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Collect_Each_Level finish collect level '||g_level_order(i)||get_time
     ,FND_LOG.LEVEL_PROCEDURE);
   else
     g_status_message:=EDW_MAPPING_COLLECT.get_status_message;
     EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('ERROR Collect_Each_Level finish collect level '||g_level_order(i)||
     ' WITH ERROR '||g_status_message||get_time,FND_LOG.LEVEL_ERROR);
     g_status:=false;
     return;
   end if;
   --commit is handled inside mapping_collect please see procedure collect_records
 end loop; --each ltc collection
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished Collect_Each_Level'||get_time,FND_LOG.LEVEL_PROCEDURE);
  end if;
Exception when others then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('ERROR:EDW_ALL_COLLECT.Collect_Each_Level, finish '||
   ' collect level '||g_primary_target(l_latest)||' WITH ERROR::'||sqlerrm||' Time '||get_time,FND_LOG.LEVEL_ERROR);
  g_status:=false;
  g_status_message:=sqlerrm;
  return;
End;--PROCEDURE Collect_Each_Level IS

function get_temp_log_data(g_object_name varchar2, g_object_type varchar2) return boolean is
Begin
  g_number_ins_req_coll:=1;
  if EDW_OWB_COLLECTION_UTIL.get_temp_log_data(
    g_object_name,
    g_object_type,
    null,
    g_ins_rows_ready(1),
    g_ins_rows_processed(1),
    g_ins_rows_collected(1),
    g_ins_rows_dangling(1),
    g_ins_rows_duplicate(1),
    g_ins_rows_error(1),
    g_ins_rows_insert(1),
    g_ins_rows_update(1),
    g_ins_rows_delete(1),
    g_ins_instance_name(1),
    g_ins_request_id_table(1))=false then
    null;
  end if;
  return true;
EXCEPTION when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(g_status_message,FND_LOG.LEVEL_ERROR);
  return false;
End;

function check_if_fact_exists(p_fact_name varchar2) return boolean is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt varchar2(2000);
l_var number:=null;
begin
  l_stmt:='select 1 from EDW_FACTS_MD_V where fact_name=:s';
  open cv for l_stmt using p_fact_name;
  fetch cv into l_var;
  close cv;
  if l_var is null then
    return false;
  end if;
  return true;
EXCEPTION when others then
  begin
    close cv;
  exception when others then
    null;
  end;
  g_status:=false;
  g_status_message:=sqlerrm;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(g_status_message,FND_LOG.LEVEL_ERROR);
  return false;
End;


procedure Collect_Fact(Errbuf out NOCOPY varchar2,
		       Retcode out NOCOPY varchar2,
                       p_fact_name in varchar2) IS

l_status boolean:=true;
l_fact_audit boolean:=true;
l_fact_net_change boolean:=true;
l_audit_name varchar2(400):=null;
l_net_change_name varchar2(400):=null;
l_audit_is_name varchar2(400):=null;
l_net_change_is_name varchar2(400):=null;
l_object_name varchar2(400);
l_object_type varchar2(400);
l_ins_rows_processed number;
l_var number;
Begin
g_collection_start_date:=sysdate;
g_collect_fact:=true;
g_collect_dim:=false;
g_status:=true;
g_conc_program_id:=0;
g_object_name:=p_fact_name;
g_object_type:='FACT';
l_audit_is_name:='FACT_AUDIT';
l_net_change_is_name:='FACT_NET_CHANGE';
g_logical_object_type:='FACT';
g_conc_program_id:=FND_GLOBAL.Conc_request_id;--my conc id
g_conc_program_name :=upper(p_fact_name)||'_T';
retcode:='0';
--EDW_OWB_COLLECTION_UTIL.setup_conc_program_log(p_fact_name);
EDW_OWB_COLLECTION_UTIL.init_all(p_fact_name,null,'bis.edw.loader.load_fact');
EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Collect Fact for '||p_fact_name||get_time,FND_LOG.LEVEL_PROCEDURE);
g_load_pk:=EDW_OWB_COLLECTION_UTIL.inc_g_load_pk;
EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('g_load_pk='||g_load_pk,FND_LOG.LEVEL_STATEMENT);
if g_load_pk is null then
  errbuf:=g_status_message;
  retcode:='2';
  return_with_error(g_load_pk,'LOG');
  return;
end if;
 g_object_id:=EDW_OWB_COLLECTION_UTIL.get_object_id(g_object_name);
 if g_object_id=-1 then
   errbuf:=EDW_OWB_COLLECTION_UTIL.g_status_message;
   retcode:='2';
   return_with_error(g_load_pk,'LOG');
   return;
 end if;

EDW_OWB_COLLECTION_UTIL.set_debug(true);
l_var:= EDW_OWB_COLLECTION_UTIL.is_another_coll_running(g_object_name, g_object_type);
EDW_OWB_COLLECTION_UTIL.set_debug(false);

if l_var=2 then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Ok to proceed',FND_LOG.LEVEL_STATEMENT);
elsif l_var=1 then
  g_status_message:=EDW_OWB_COLLECTION_UTIL.get_message('EDW_NEW_COLLECTION_RUNNING');
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(g_status_message,FND_LOG.LEVEL_STATEMENT);
  errbuf:=g_status_message;
  retcode:='2';
  return_with_error(g_load_pk,'LOG');
  return;
elsif l_var=0 then
  g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(g_status_message,FND_LOG.LEVEL_STATEMENT);
  errbuf:=g_status_message;
  retcode:='2';
  return_with_error(g_load_pk,'LOG');
  return;
end if;
 if EDW_OWB_COLLECTION_UTIL.log_collection_start(g_object_name,g_object_id,g_object_type,
   g_collection_start_date,g_conc_program_id,g_load_pk)=false then
   errbuf:=g_status_message;
   retcode:='2';
   return_with_error(g_load_pk,'LOG');
   return;
 end if;

if check_if_fact_exists(p_fact_name) = false then
  retcode:='2';
  g_status_message:=EDW_OWB_COLLECTION_UTIL.get_message('EDW_FACT_NOT_FOUND');
  errbuf:=g_status_message;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('The fact '||p_fact_name||' not found in the metadata ',FND_LOG.LEVEL_STATEMENT);
  return_with_error(g_load_pk,'LOG');
  return;
end if;
init_all;
if g_status=false then
  errbuf:=g_status_message;
  retcode:='2';
  return_with_error(g_load_pk,'LOG');
  return;
end if;
if g_debug then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('pre_coll'||get_time,FND_LOG.LEVEL_PROCEDURE);
end if;
insert_into_load_progress(g_load_pk,g_object_name,g_object_id,'Pre Coll Hook',sysdate,null,'FACT',
'PRE-COLL-HOOK',20,'I');
if EDW_COLLECTION_HOOK.pre_coll(g_object_name) = true then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished pre_coll with success'||get_time,FND_LOG.LEVEL_PROCEDURE);
else
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished pre_coll with error'||get_time,FND_LOG.LEVEL_ERROR);
  g_status_message:=EDW_OWB_COLLECTION_UTIL.get_message('EDW_FINISHED_PRECOLL_ERROR');
  errbuf:=g_status_message;
  retcode:='2';
  return_with_error(g_load_pk,'LOG');
  return;
end if;
insert_into_load_progress(g_load_pk,null,null,null,null,sysdate,null,null,20,'U');
if g_debug then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('pre_fact_coll'||get_time,FND_LOG.LEVEL_PROCEDURE);
end if;
insert_into_load_progress(g_load_pk,g_object_name,g_object_id,'Pre Fact Coll Hook',sysdate,null,'FACT',
'PRE-FACT-COLL-HOOK',21,'I');
if EDW_COLLECTION_HOOK.pre_fact_coll(g_object_name) = true then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished pre_fact_coll with success'||get_time,FND_LOG.LEVEL_PROCEDURE);
else
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished pre_fact_coll with error '||get_time,FND_LOG.LEVEL_ERROR);
  g_status_message:=EDW_OWB_COLLECTION_UTIL.get_message('EDW_PREFACT_COLL_ERROR');
  errbuf:=g_status_message;
  retcode:='2';
  insert_into_load_progress(g_load_pk,null,null,null,null,sysdate,null,null,21,'U');
  return_with_error(g_load_pk,'LOG');
  return;
end if;
insert_into_load_progress(g_load_pk,null,null,null,null,sysdate,null,null,21,'U');
EDW_OWB_COLLECTION_UTIL.set_parallel(g_parallel);
  /*
    Find if the fact is derived fact or ordinary fact.
  */
 if EDW_OWB_COLLECTION_UTIL.find_skip_attributes(g_object_name,g_object_type,g_skip_cols,g_number_skip_cols)=false then
   errbuf:=g_status_message;
   retcode:='2';
   return_with_error(g_load_pk,'LOG');
   return;
 end if;
 if get_fact_dlog=false then
   errbuf:=g_status_message;
   retcode:='2';
   return_with_error(g_load_pk,'LOG');
   return;
 end if;
 if is_derived_fact(g_object_name)= true then
   g_logical_object_type:='DERIVED FACT';
   EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Derived Fact ',FND_LOG.LEVEL_STATEMENT);
   --call the derived fact collection
   l_ins_rows_processed:=0;
   insert_into_load_progress(g_load_pk,g_object_name,g_object_id,'Derived Fact Collect',sysdate,null,'FACT',
  'DERIVED-FACT-COLLECT',22,'I');
   if EDW_DERIVED_FACT_COLLECT.COLLECT_FACT(
     g_object_name,
     g_conc_program_id,
     g_conc_program_name,
     g_debug,
     g_collection_size,
     g_parallel,
     g_bis_owner,
     g_table_owner,
     l_ins_rows_processed,
     g_forall_size,
     g_update_type,
     g_skip_cols,
     g_number_skip_cols,
     g_load_pk,
     g_fresh_restart,
     g_op_table_space,
     g_rollback,
     g_stg_join_nl,
     g_thread_type,
     g_max_threads,
     g_min_job_load_size,
     g_sleep_time,
     g_hash_area_size,
     g_sort_area_size,
     g_trace,
     g_read_cfig_options
     ) = true then
     EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('EDW_DERIVED_FACT_COLLECT.COLLECT_FACT returned with success '||get_time
     ,FND_LOG.LEVEL_PROCEDURE);
     insert_into_load_progress(g_load_pk,null,null,null,null,sysdate,null,null,22,'U');
   else
     g_status_message:=EDW_DERIVED_FACT_COLLECT.get_status_message;
     EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(g_status_message,FND_LOG.LEVEL_STATEMENT);
     insert_into_load_progress(g_load_pk,null,null,null,null,sysdate,null,null,22,'U');
     g_status:=false;
     errbuf:=g_status_message;
     retcode:='2';
     return_with_error(g_load_pk,'LOG');
     return;
   end if;
   if get_temp_log_data(g_object_name,g_object_type)=false then
     errbuf:=g_status_message;
     retcode:='2';
     return_with_error(g_load_pk,'NO-LOG');
     return;
   end if;
 else
   EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Normal Fact',FND_LOG.LEVEL_STATEMENT);
   --first find out NOCOPY if the fact needs to be tracked or not
   begin
     select fact_name  into l_audit_name from edw_facts_md_v where fact_name=p_fact_name||'_AU' ;
   Exception when others then
    l_audit_name:=null;
   end;
   if l_audit_name is null then
     l_fact_audit:=false;
     EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('NO Auditing for fact '||p_fact_name,FND_LOG.LEVEL_STATEMENT);
   end if;
   if l_fact_audit then
      EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Audit on for fact '||p_fact_name,FND_LOG.LEVEL_STATEMENT);
   end if;
   begin
     select fact_name  into l_net_change_name from edw_facts_md_v where fact_name=p_fact_name||'_NC' ;
   Exception when others then
    l_net_change_name:=null;
   end;
   if l_net_change_name is null then
     l_fact_net_change:=false;
     EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('NO Net Change for fact '||p_fact_name,FND_LOG.LEVEL_ERROR);
   end if;
   if l_fact_net_change then
      EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Net Change on for fact '||p_fact_name,FND_LOG.LEVEL_STATEMENT);
   end if;
   --get the primary src and target and call collect
   EDW_OWB_COLLECTION_UTIL.Get_Fact_Ids(
   p_fact_name,
   g_fact_map_id,
   g_fact_src,
   g_fact_target) ;
   EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished EDW_OWB_COLLECTION_UTIL.Get_Fact_Ids,
   Time '||get_time,FND_LOG.LEVEL_STATEMENT);
   -------
   /*
   3529591
   */
   if edw_owb_collection_util.clean_ilog_dlog_base_fact(g_object_name,g_table_owner,g_bis_owner,
     g_fact_target,g_fact_dlog)=false then
     errbuf:=edw_owb_collection_util.g_status_message;
     retcode:='2';
     return_with_error(g_load_pk,'LOG');
     return;
   end if;
   -------
   insert_into_load_progress_nd(g_load_pk,g_object_name,g_object_id,'Load Fact',sysdate,null,'FACT','FACT','LF','I');
   EDW_MAPPING_COLLECT.COLLECT_MAIN(
   g_object_name,
   g_fact_map_id,
   'FACT',
   g_fact_src,
   g_fact_target,
   p_fact_name,
   g_object_type,
   g_conc_program_id,
   g_conc_program_name,
   l_status,
   l_fact_audit,
   l_fact_net_change,
   l_audit_name,
   l_net_change_name,
   l_audit_is_name,
   l_net_change_is_name,
   g_debug,
   g_duplicate_collect,
   g_exec_flag,
   g_request_id,
   g_collection_size,
   g_parallel,
   g_table_owner,
   g_bis_owner,
   true,
   g_forall_size,
   g_update_type,--for facts, we need to log into temp log table
   g_mode,
   g_explain_plan_check,
   g_fact_dlog,
   g_key_set,
   g_instance_type,
   g_load_pk,
   g_skip_cols,
   g_number_skip_cols,
   g_fresh_restart,
   g_op_table_space,
   g_da_cols,
   g_number_da_cols,
   null,--g_da_table
   null,--g_pp_table
   g_master_instance,
   g_rollback,
   g_skip_levels,
   g_number_skip_levels,
   g_smart_update,
   g_fk_use_nl,
   g_fact_smart_update,
   g_auto_dang_table_extn,
   g_auto_dang_recovery,
   g_create_parent_table_records,
   g_smart_update_cols,
   g_number_smart_update_cols,
   g_check_fk_change,
   g_stg_join_nl,
   g_ok_switch_update,
   g_stg_make_copy_percentage,
   g_hash_area_size,
   g_sort_area_size,
   g_trace,
   g_read_cfig_options,
   g_min_job_load_size,
   g_sleep_time,
   g_thread_type,
   g_max_threads,
   g_job_status_table,
   g_analyze_frequency,
   false,
   null
   );
   insert_into_load_progress_nd(g_load_pk,null,null,null,null,sysdate,null,null,'LF','U');
   if l_status=true then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('FINISH : EDW_ALL_COLLECT.Collect_Fact, Time '||
    get_time,FND_LOG.LEVEL_PROCEDURE);
   else
     EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('FINISH with ERROR: EDW_ALL_COLLECT.Collect_Fact '||
     EDW_MAPPING_COLLECT.get_status_message||' Time '||get_time,FND_LOG.LEVEL_PROCEDURE);
     g_status:=false;
     g_status_message:=EDW_MAPPING_COLLECT.get_status_message;
     errbuf:=g_status_message;
     retcode:='2';
     return_with_error(g_load_pk,'LOG');
     return;
   end if;
   if get_temp_log_data(g_object_name, g_object_type)=false then
     errbuf:=g_status_message;
     retcode:='2';
     return_with_error(g_load_pk,'NO-LOG');
     return;
   end if;
 end if; --if this is normal fact
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('post_fact_coll'||get_time,FND_LOG.LEVEL_PROCEDURE);
  end if;
  insert_into_load_progress(g_load_pk,g_object_name,g_object_id,'Post Fact Coll Hook',sysdate,null,'POST-FACT',
  'POST-FACT',23,'I');
  if EDW_COLLECTION_HOOK.post_fact_coll(g_object_name) = true then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished post_fact_coll with success'||get_time,FND_LOG.LEVEL_PROCEDURE);
  else
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished post_fact_coll with error'||get_time,FND_LOG.LEVEL_ERROR);
    g_status_message:=EDW_OWB_COLLECTION_UTIL.get_message('EDW_POSTFACT_COLL_ERROR');
    errbuf:=g_status_message;
    retcode:='2';
    insert_into_load_progress(g_load_pk,null,null,null,null,sysdate,null,null,23,'U');
    return_with_error(g_load_pk,'LOG');
    return;
  end if;
  insert_into_load_progress(g_load_pk,null,null,null,null,sysdate,null,null,23,'U');
  return_with_success('LOG',null,g_load_pk);--log into edw_collection_detail_log
  declare
  l_load_pk number:=null;
  /*
  delete_object_log_tables is contained in refresh_all_derived_facts
  In this the snp log of base fact is truncated
  */
  begin
    if g_logical_object_type='FACT' then
      if refresh_all_derived_facts=false then
        errbuf:=g_status_message;
        g_status:=false;
        retcode:='2';
        return;
      end if;
    end if;
  end;
  clean_up;--cleans up the progress log
 /***************************************************************************/
 /******************this call is for workflow for now...*********************/
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('post_coll'||get_time,FND_LOG.LEVEL_PROCEDURE);
  end if;
  if EDW_COLLECTION_HOOK.post_coll(g_object_name) = true then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished post_coll with success'||get_time,FND_LOG.LEVEL_PROCEDURE);
  else
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished post_coll with error'||get_time,FND_LOG.LEVEL_ERROR);
  end if;
/*******************END WORKFLOW API*****************************************/
Exception when others then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('ERROR:EDW_ALL_COLLECT.Collect_Fact,
    ERROR '||sqlerrm||' Time '||get_time,FND_LOG.LEVEL_ERROR);
    g_status:=false;
    g_status_message:=sqlerrm;
    errbuf:=g_status_message;
    retcode:='2';
    return_with_error(g_load_pk,'LOG');
    return;
End;--procedure Collect_Fact(p_fact_name varchar2) IS

procedure clean_up is
Begin
  if EDW_OWB_COLLECTION_UTIL.record_coll_progress(
    g_object_name,
    g_object_type,
    null,
    null,
    'DELETE') = false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(g_status_message,FND_LOG.LEVEL_STATEMENT);
    g_status:=false;
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Util.record_coll_progress returned with error for delete',
    FND_LOG.LEVEL_STATEMENT);
 end if;
 --if there is push down, drop the ilogs
 if g_dim_push_down then
   EDW_PUSH_DOWN_DIMS.drop_ilog;
 end if;
Exception when others then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Error in clean up',FND_LOG.LEVEL_ERROR);
End;

procedure init_all IS
l_hash_area_size number;
l_sort_area_size number;
l_key_set varchar2(400);
begin
  g_status:=true;
  g_status_message:=' ';
  g_number_rows_processed:=0;
  g_ok_switch_update:=5;--% when to swith to update for ok table
  g_stg_join_nl:=25; --% when to force using NL in staging table lookup
  g_stg_make_copy_percentage:=0; --% below which make a copy of stg to process 0 means turned off
  g_max_threads:=1; --increasing this also means that the db parameter job_queue_processes must be set
  --correctly. if g_max_threads=10, then job_queue_processes >=10
  g_min_job_load_size:=50000;
  g_sleep_time:=15; --15 seconds sleep time. Its used to sync multiple threads
  g_auto_dang_recovery:=false;
  if EDW_OWB_COLLECTION_UTIL.does_table_have_data('EDW_CFIG_OPTIONS')=2 then
    g_read_cfig_options:=true;
  else
    g_read_cfig_options:=false;
  end if;
  EDW_OWB_COLLECTION_UTIL.set_g_read_cfig_options(g_read_cfig_options);
  if g_read_cfig_options then
    if read_config_options=false then
      return;
    end if;
  else
    if read_profile_options=false then
      return;
    end if;
  end if;
 /*************************************************************************************/
 g_instance_type:='MULTIPLE';--SINGLE vs MULTIPLE
 g_exec_flag:=true;
 g_number_ins_req_coll:=0;
 g_diamond_issue:=false;
 g_number_derived_facts:=0;
 g_table_owner:=EDW_OWB_COLLECTION_UTIL.get_table_owner(g_object_name);
 EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('The owner for table '||g_object_name||' is '||g_table_owner,
 FND_LOG.LEVEL_STATEMENT);
 g_forall_size:=5000;
 g_fact_dlog:=g_bis_owner||'.'||substr(g_object_name,1,26)||'DLG'; --delete log for facts
 g_analyze_frequency:=30;
 g_max_fk_density:=5; --5% see EDWSCOLB.pls
 g_number_tables_to_drop:=0;
 g_number_da_cols:=0;
 g_da_table:=EDW_OWB_COLLECTION_UTIL.get_DA_table(g_object_name,g_table_owner);
 g_pp_table:=EDW_OWB_COLLECTION_UTIL.get_PP_table(g_object_name,g_table_owner);
 g_master_instance:=EDW_OWB_COLLECTION_UTIL.get_master_instance(g_object_name);
 EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Master Instance '||g_master_instance,FND_LOG.LEVEL_STATEMENT);
 g_number_skip_levels:=0;
 set_g_fact_smart_update;
 g_auto_dang_table_extn:='EDW_ADR';
 if g_object_type='DIMENSION' then
   if EDW_OWB_COLLECTION_UTIL.drop_table(g_bis_owner||'.'||substr(g_object_name,1,27)||
     g_auto_dang_table_extn)=false then
     null;
   end if;
 end if;
 g_check_fk_change:=true;
 g_check_fk_change_number:=60;
 EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('MAX Threads='||g_max_threads,FND_LOG.LEVEL_STATEMENT);
 g_job_status_table:=g_bis_owner||'.MAIN_'||g_object_id||'_JOB_STATUS';
 g_job_queue_processes:=EDW_OWB_COLLECTION_UTIL.get_job_queue_processes;
 g_thread_type:=set_thread_type(g_max_threads,g_job_queue_processes);
 if g_thread_type is null then
   g_thread_type:='JOB';
 end if;
 if g_job_queue_processes is null then
   g_job_queue_processes:=g_max_threads;
 end if;
 if g_thread_type='JOB' then
   if g_max_threads>g_job_queue_processes then
     g_max_threads:=g_job_queue_processes;
     if g_debug then
       EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('MAX Threads reset to max jobs ='||g_max_threads,FND_LOG.LEVEL_STATEMENT);
     end if;
   end if;
 end if;
 g_parallel_drill_down:=false;
 g_dd_status_table:=g_bis_owner||'.TAB_DD_'||g_object_id;--used in parallel drill down
Exception when others then
  g_status_message:=sqlerrm;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(g_status_message,FND_LOG.LEVEL_ERROR);
  g_status:=false;
End;--procedure init_all IS

procedure set_g_fact_smart_update is
Begin
  g_fact_smart_update:=50;--number of columns below which there is smart update for facts
  if g_parallel is not null and g_parallel>1 then
    g_fact_smart_update:=150;
    if g_max_threads is not null and g_max_threads>1 then
      g_fact_smart_update:=g_fact_smart_update+(g_max_threads/2)*(g_fact_smart_update/2);
    end if;
  end if;
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('g_fact_smart_update='||g_fact_smart_update,FND_LOG.LEVEL_STATEMENT);
  end if;
Exception when others then
  g_fact_smart_update:=50;
End;

function get_status_message return varchar2 is
begin
 return g_status_message;
End;--function get_status_message return varchar2 is


procedure return_with_error(p_load_pk number,p_log varchar2) is
l_status_message EDW_OWB_COLLECTION_UTIL.varcharTableType;
begin
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('In return_with_error'||get_time,FND_LOG.LEVEL_ERROR);
    EDW_OWB_COLLECTION_UTIL.write_to_log_file('p_load_pk='||p_load_pk,FND_LOG.LEVEL_ERROR);
  end if;
  rollback;
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('rollback',FND_LOG.LEVEL_ERROR);
  end if;
  if p_log<>'NO-LOG' then
    if get_temp_log_data(g_object_name, g_object_type)=false then
      null;
    end if;
    get_rows_processed;
  end if;
  for i in 1..g_number_ins_req_coll loop
    l_status_message(i):=g_status_message;
  end loop;
  write_to_collection_log(false,l_status_message,null, p_load_pk);
  commit;
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('commit',FND_LOG.LEVEL_STATEMENT);
  end if;
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished return_with_error'||get_time,FND_LOG.LEVEL_ERROR);
  end if;
Exception when others then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Error in return_with_error '||sqlerrm||get_time,FND_LOG.LEVEL_ERROR);
  g_status_message:=sqlerrm;
  g_status:=false;
End;--procedure return_with_error is

procedure return_with_success(p_command varchar2,p_start_date date, p_load_pk number) is
l_status_message EDW_OWB_COLLECTION_UTIL.varcharTableType;
begin
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('In return_with_success, p_command is '||p_command,FND_LOG.LEVEL_STATEMENT);
    EDW_OWB_COLLECTION_UTIL.write_to_log_file('p_start_date='||p_start_date||',p_load_pk='||p_load_pk,FND_LOG.LEVEL_STATEMENT);
  end if;
  if p_command='LOG' then
    if g_debug then
      EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Going to Log',FND_LOG.LEVEL_STATEMENT);
    end if;
    get_rows_processed;
    if g_collect_dim then
      EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Rows Processed into the dimension '||g_dim_rows_processed,
      FND_LOG.LEVEL_STATEMENT);
    end if;
    g_status_message:=make_collection_log_message(l_status_message);
    write_to_collection_log(true,l_status_message,p_start_date,p_load_pk);
  end if;
  commit;
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('commit',FND_LOG.LEVEL_STATEMENT);
  end if;
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Finished return_with_success'||get_time,FND_LOG.LEVEL_STATEMENT);
  end if;
Exception when others then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Error in return_with_success '||sqlerrm||get_time,FND_LOG.LEVEL_ERROR);
  g_status_message:=sqlerrm;
  g_status:=false;
End;--procedure return_with_success

function make_collection_log_message(l_status_message out NOCOPY EDW_OWB_COLLECTION_UTIL.varcharTableType)
     return varchar2 is
l_status varchar2(2000);
l_ready number:=0;
l_processed number:=0;
l_collected  number:=0;
l_dangling  number:=0;
l_duplicate  number:=0;
l_error  number:=0;
begin
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('In make_collection_log_message',FND_LOG.LEVEL_STATEMENT);
  end if;
  for i in 1..g_number_ins_req_coll loop
    l_ready:=l_ready+g_ins_rows_ready(i);
    l_processed:=l_processed+g_ins_rows_processed(i);
    l_collected:=l_collected+g_ins_rows_collected(i);
    l_dangling:=l_dangling+g_ins_rows_dangling(i);
    l_duplicate:=l_duplicate+g_ins_rows_duplicate(i);
    l_error:=l_error+g_ins_rows_error(i);
    FND_MESSAGE.SET_NAME('BIS','EDW_COLL_DETAIL_LOG_MESSAGE');
    FND_MESSAGE.SET_TOKEN('READY',g_ins_rows_ready(i));
    FND_MESSAGE.SET_TOKEN('PROCESSED',g_ins_rows_processed(i));
    FND_MESSAGE.SET_TOKEN('COLLECTED',g_ins_rows_collected(i));
    FND_MESSAGE.SET_TOKEN('DANGLING',g_ins_rows_dangling(i));
    FND_MESSAGE.SET_TOKEN('DUPLICATE',g_ins_rows_duplicate(i));
    FND_MESSAGE.SET_TOKEN('ERROR',g_ins_rows_error(i));
    l_status_message(i):=FND_MESSAGE.GET;
  end loop;
  l_status:=null;
  if l_collected > g_dim_rows_processed then
    --l_status:='WARNING! Rows processed into star table:'||g_dim_rows_processed||' and '||
        --' rows processed into lowest level level table is:'||l_collected||'. ';
    l_status:='Please make sure that the dimension table and lowest level LTC table are in sync';
    g_diamond_issue:=true;
  end if;
  l_status:=l_status||'Ready records '||l_ready||', Processed '||l_processed||', Actually Collected '||
    l_collected||', Dangling '||l_dangling||', Duplicate '||l_duplicate||', Error '||l_error;
  return l_status;
Exception when others then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Error in make_collection_log_message '||sqlerrm||get_time,FND_LOG.LEVEL_ERROR);
  g_status_message:=sqlerrm;
  g_status:=false;
  return null;
End;

procedure get_rows_processed is
begin
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('In get_rows_processed'||get_time,FND_LOG.LEVEL_STATEMENT);
  end if;
  /*
  if g_collect_dim then
    g_dim_rows_processed:=EDW_SUMMARY_COLLECT.get_number_rows_processed;
    for i in 1..g_number_ins_req_coll loop
      g_ins_rows_collected(i):=g_dim_rows_processed;
    end loop;
  end if;*/
Exception when others then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Error in get_rows_processed '||sqlerrm||get_time,FND_LOG.LEVEL_ERROR);
  g_status_message:=sqlerrm;
  g_status:=false;
End;--procedure get_rows_processed is

procedure write_to_collection_log(p_flag boolean, p_message EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_collection_start_date date, p_load_pk number) is
/*
right now we go with logging into the table only if there is no error in the
collection engine (retcode='2')
*/
l_status varchar2(200);
begin
  if g_debug then
    if p_flag then
      EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('In write_to_collection_log, status is OK',FND_LOG.LEVEL_STATEMENT);
    else
      EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('In write_to_collection_log, status is ERROR',FND_LOG.LEVEL_STATEMENT);
    end if;
  end if;
  g_collection_end_date:=sysdate;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('The end time for collection '||g_collection_end_date,FND_LOG.LEVEL_PROCEDURE);
  for i in 1..g_number_ins_req_coll loop
    if p_flag then
      if g_ins_rows_collected(i)<g_ins_rows_ready(i) then
        l_status:='PARTIAL';
      else
        l_status:='SUCCESS';
      end if;
    else
      l_status:='ERROR';
    end if;
   if EDW_OWB_COLLECTION_UTIL.write_to_collection_log(
        g_object_name,
        g_object_id,
        g_object_type,
        g_conc_program_id,
        g_collection_start_date,
        g_collection_end_date,
        g_ins_rows_ready(i),
        g_ins_rows_processed(i),
        g_ins_rows_collected(i),
        g_ins_rows_insert(i),
        g_ins_rows_update(i),
        g_ins_rows_delete(i),
        p_message(i),
        l_status,
        p_load_pk)= false then
          g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
          g_status:=false;
          return;
     end if;
   end loop;
Exception when others then
  g_status_message:=sqlerrm;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(g_status_message,FND_LOG.LEVEL_ERROR);
  g_status:=false;
End;

procedure write_to_error_log(p_message varchar2) is
l_type varchar2(200);
l_status varchar2(200);
begin
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('In write_to_error_log, p_message is '||p_message,FND_LOG.LEVEL_PROCEDURE);
  end if;
  l_type:='COLLECTION';  --NLS?
  l_status:='ERROR';
  g_collection_end_date:=sysdate;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('The end time for collection '||g_collection_end_date,FND_LOG.LEVEL_PROCEDURE);
  if EDW_OWB_COLLECTION_UTIL.write_to_error_log(
      g_object_name,
      g_object_type,
      l_type,
      g_conc_program_id,
      g_collection_start_date,
      g_collection_end_date,
      p_message,
      l_status,
      g_resp_id) = false then
        g_status_message:=sqlerrm;
        g_status:=false;
        return;
   end if;
Exception when others then
  g_status_message:=sqlerrm;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(g_status_message,FND_LOG.LEVEL_ERROR);
  g_status:=false;
End;

function is_derived_fact(p_fact varchar2) return boolean is
l_stmt varchar2(2000);
l_var number:=null;
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
begin
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('In is_derived_fact, params :'||p_fact||get_time,FND_LOG.LEVEL_STATEMENT);
  end if;
  --not checked
  l_stmt:='select 1 from edw_pvt_map_properties_md_v map, EDW_FACTS_MD_V tgt, EDW_FACTS_MD_V src '||
  ' where tgt.fact_name=:a and map.Primary_target=tgt.fact_id and map.Primary_source=src.fact_id and rownum=1';
  open cv for l_stmt using p_fact;
  fetch cv into l_var;
  close cv;
  if l_var =1 then
    return true;
  end if;
  return false;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Error in is_derived_fact '||sqlerrm||get_time,FND_LOG.LEVEL_ERROR);
  return false;
End;

function is_source_for_derived_fact return boolean is
l_stmt varchar2(5000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_var number:=null;
begin
if g_debug then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('In is_source_for_derived_fact',FND_LOG.LEVEL_STATEMENT);
end if;
--not checked
l_stmt:='select 1 from edw_pvt_map_properties_md_v map, edw_facts_md_v tgt '||
' where map.primary_target=tgt.fact_id and map.primary_source=:a and rownum=1';
open cv for l_stmt using g_fact_target;
fetch cv into l_var;
close cv;
if l_var =1 then
  return true;
else
  return false;
end if;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Error in is_source_for_derived_fact '||sqlerrm||get_time,FND_LOG.LEVEL_ERROR);
  return false;
End;

function refresh_all_derived_facts return boolean is
l_load_pk EDW_OWB_COLLECTION_UTIL.numberTableType;
l_ins_rows_processed EDW_OWB_COLLECTION_UTIL.numberTableType;
l_status EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_message EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_derv_facts number;
l_bu_tables EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_bu_dimensions EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_bu_tables number:=0;
l_bu_src_fact varchar2(400):=null;
l_load_mode varchar2(400);
l_date date;
l_derived_facts EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_derived_fact_ids EDW_OWB_COLLECTION_UTIL.numberTableType;
l_map_ids EDW_OWB_COLLECTION_UTIL.numberTableType;
l_number_derived_facts number;
Begin
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('In refresh_all_derived_facts',FND_LOG.LEVEL_STATEMENT);
  end if;
  if is_source_for_derived_fact = false then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('This fact is not a source for any derived fact',FND_LOG.LEVEL_STATEMENT);
    return true;
  end if;
  if g_status=false then
    return false;
  end if;
  --if this base fact is not analyzed, analye it
  l_date:=EDW_OWB_COLLECTION_UTIL.get_last_analyzed_date(g_object_name,g_table_owner);
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Last analyzed date for '||g_object_name||' is '||l_date,FND_LOG.LEVEL_STATEMENT);
  end if;
  if l_date is null then
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(g_object_name,g_table_owner,1);
  end if;
  l_number_derived_facts:=0;
  if EDW_DERIVED_FACT_COLLECT.COLLECT_FACT_INC(
    g_object_name,
    g_fact_target,
    l_derived_facts,--dummy
    l_derived_fact_ids,--dummy
    l_map_ids,--dummy
    l_number_derived_facts,--dummy
    g_conc_program_id,
    g_conc_program_name,
    g_debug,
    g_collection_size,
    g_parallel,
    g_bis_owner,
    g_table_owner,--src fact owner
    l_load_pk,
    l_ins_rows_processed,
    l_status,
    l_message,
    l_number_derv_facts,
    g_forall_size,
    g_update_type,
    g_fact_dlog,
    g_fresh_restart,
    g_op_table_space,
    l_bu_tables,--dummy
    l_bu_dimensions,--dummy
    l_number_bu_tables,--dummy
    l_bu_src_fact,--dummy
    l_load_mode,--dummy
    g_rollback,
    g_stg_join_nl,
    g_thread_type,
    g_max_threads,
    g_min_job_load_size,
    g_sleep_time,
    g_hash_area_size,
    g_sort_area_size,
    g_trace,
    g_read_cfig_options,
    g_job_queue_processes
    )=false then
    g_status_message:=EDW_DERIVED_FACT_COLLECT.get_status_message;
    g_status:=false;
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Error in refresh_all_derived_facts '||g_status_message,FND_LOG.LEVEL_ERROR);
  return false;
End;

function get_snapshot_log return boolean is
Begin
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('In get_snapshot_log',FND_LOG.LEVEL_STATEMENT);
  end if;
  for i in 1..l_number_levels loop
    g_level_snapshot_logs(i):=EDW_OWB_COLLECTION_UTIL.get_table_snapshot_log(l_levels(i));
  end loop;
  return true;
Exception when others then
 g_status:=false;
 g_status_message:=sqlerrm;
 EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(g_status_message,FND_LOG.LEVEL_ERROR);
 return false;
End;


function get_time return varchar2 is
begin
  return ' '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS');
Exception when others then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Error in get_time '||sqlerrm,FND_LOG.LEVEL_ERROR);
End;

procedure write_to_log_file(p_message varchar2) is
begin
  EDW_OWB_COLLECTION_UTIL.write_to_log_file(p_message);
Exception when others then
 null;
End;

procedure write_to_log_file_n(p_message varchar2) is
begin
  EDW_OWB_COLLECTION_UTIL.write_to_log_file('   ');
  EDW_OWB_COLLECTION_UTIL.write_to_log_file(p_message);
Exception when others then
 null;
End;

procedure Collect_Object(Errbuf out NOCOPY varchar2,
		       Retcode out NOCOPY varchar2,
               p_object_name in varchar2) is
l_stmt varchar2(20000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_object_name varchar2(400);
Begin
  --p_object_name can be long name or short name
  Retcode:='0';
  l_stmt:='select dim_name from edw_dimensions_md_v where dim_name=:a or dim_long_name=:b';
  l_object_name:=null;
  open cv for l_stmt using p_object_name,p_object_name;
  fetch cv into l_object_name;
  close cv;
  if l_object_name is not null then
    Collect_Dimension(errbuf,retcode,l_object_name);
    return;
  end if;
  l_stmt:='select fact_name from edw_facts_md_v where fact_name=:a or fact_longname=:b';
  l_object_name:=null;
  open cv for l_stmt using p_object_name,p_object_name;
  fetch cv into l_object_name;
  close cv;
  if l_object_name is not null then
    Collect_Fact(errbuf,retcode,l_object_name);
    return;
  end if;
Exception when others then
 g_status:=false;
 g_status_message:=sqlerrm;
 Errbuf:=g_status_message;
 Retcode:='2';
End;

function get_fact_dlog return boolean is
l_dlog varchar2(400):=null;
l_stmt varchar2(4000);
l_owner varchar2(400);
Begin
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('In get_fact_dlog',FND_LOG.LEVEL_STATEMENT);
  end if;
  l_dlog:=EDW_OWB_COLLECTION_UTIL.get_log_for_table(g_object_name,'Delete Log');
  if l_dlog is null then
    l_dlog:=g_fact_dlog;
    if g_fresh_restart then
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_dlog)=false then
        null;
      end if;
    end if;
    if EDW_OWB_COLLECTION_UTIL.check_table(l_dlog)=false then
      l_stmt:='create table '||l_dlog||' tablespace '||g_op_table_space||
      ' as select '||g_object_name||'.*,'||g_object_name||'.rowid row_id from '||
      g_object_name||' where 1=2';
      if g_debug then
        EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Going to execute '||l_stmt,FND_LOG.LEVEL_STATEMENT);
      end if;
      execute immediate l_stmt;
    end if;
  else
    g_fact_dlog:=l_dlog;
    l_owner:=EDW_OWB_COLLECTION_UTIL.get_table_owner(g_fact_dlog);
    if g_fresh_restart then
      if EDW_OWB_COLLECTION_UTIL.truncate_table(g_fact_dlog,l_owner)=false then
        null;
      end if;
    end if;
    l_stmt:='alter table '||l_owner||'.'||g_fact_dlog||' add (row_id rowid)';
    begin
      if g_debug then
        EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Going to execute '||l_stmt,FND_LOG.LEVEL_STATEMENT);
      end if;
      execute immediate l_stmt;
    exception when others then
      EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Column already there',FND_LOG.LEVEL_STATEMENT);
    end;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(g_status_message,FND_LOG.LEVEL_ERROR);
  return false;
End;

procedure insert_into_load_progress(p_load_fk number,p_object_name varchar2,p_object_id number,p_load_progress varchar2,
  p_start_date date,p_end_date date,p_category varchar2, p_operation varchar2,p_seq_id varchar2,p_flag varchar2) is
Begin
  EDW_OWB_COLLECTION_UTIL.insert_into_load_progress(p_load_fk,p_object_name,p_object_id,p_load_progress,p_start_date,
  p_end_date,p_category,p_operation,p_seq_id,p_flag,1);
  commit;
Exception when others then
  g_status_message:=sqlerrm;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(g_status_message,FND_LOG.LEVEL_ERROR);
End;

--if debug is turned off
procedure insert_into_load_progress_nd(p_load_fk number,p_object_name varchar2,p_object_id number,p_load_progress varchar2,
  p_start_date date,p_end_date date,p_category varchar2, p_operation varchar2,p_seq_id varchar2,p_flag varchar2) is
Begin
  if g_debug=false then
    EDW_OWB_COLLECTION_UTIL.insert_into_load_progress(p_load_fk,p_object_name,p_object_id,p_load_progress,p_start_date,
    p_end_date,p_category,p_operation,p_seq_id,p_flag,1);
    commit;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(g_status_message,FND_LOG.LEVEL_ERROR);
End;

procedure reset_profiles is
Begin
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('In reset_profiles'||get_time,FND_LOG.LEVEL_STATEMENT);
  end if;
  if g_read_cfig_options then
    if read_config_options=false then
      return;
    end if;
  else
    if read_profile_options=false then
      return;
    end if;
  end if;
Exception when others then
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Error in reset_profiles '||sqlerrm||get_time,FND_LOG.LEVEL_ERROR);
End;

/*
refresh all derv facts that have this dim in their map
*/
function refresh_dim_derv_facts(p_dim_name varchar2,p_load_fk out NOCOPY number) return boolean is
l_fact_name varchar2(400);
l_src_fact_name varchar2(400);
l_src_fact_id number;
l_table_owner varchar2(400);
l_ins_rows_processed number;
l_ilog  varchar2(400);
l_dlog  varchar2(400);
l_skip_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_skip_cols number;
l_df_load_pk EDW_OWB_COLLECTION_UTIL.numberTableType;
l_bu_tables EDW_OWB_COLLECTION_UTIL.varcharTableType;--before update tables.prop dim change to derv
l_bu_dimensions EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_bu_tables number;
l_bu_src_fact varchar2(400);--what table to look at as the src fact. if null, scan the actual src fact
l_load_mode varchar2(400);
l_dim_id number;
l_derv_bu_map_src_table varchar2(400);
l_prot_delete varchar2(400);
l_prot_update varchar2(400);
l_looked_at EDW_OWB_COLLECTION_UTIL.numberTableType;
l_number_looked_at number;
l_inc_flag boolean;
l_found boolean;
L_DERV_MAPS EDW_OWB_COLLECTION_UTIL.numberTableType;
l_number_derv_maps number;
Begin
  --get an idea about which all maps to refresh. find out NOCOPY what cols belong to what maps.
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('In refresh_dim_derv_facts '||get_time,FND_LOG.LEVEL_STATEMENT);
  end if;
  g_dim_derv_map_id:=EDW_SUMMARY_COLLECT.g_dim_derv_map_id;
  g_derv_fact_id:=EDW_SUMMARY_COLLECT.g_derv_fact_id;
  g_dim_derv_map_refresh:=EDW_SUMMARY_COLLECT.g_dim_derv_map_refresh;
  g_dim_derv_map_full_refresh:=EDW_SUMMARY_COLLECT.g_dim_derv_map_full_refresh;
  g_number_dim_derv_map_id:=EDW_SUMMARY_COLLECT.g_number_dim_derv_map_id;
  g_before_update_table:=EDW_SUMMARY_COLLECT.g_before_update_table;--pl/sql table
  g_number_before_update_table:=EDW_SUMMARY_COLLECT.g_number_before_update_table;
  l_dim_id:=EDW_SUMMARY_COLLECT.g_dim_id;
  if g_before_update_table.count=0 then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('There are no update tables created to refresh the derived facts',
    FND_LOG.LEVEL_STATEMENT);
    return true;
  end if;
  if EDW_SUMMARY_COLLECT.g_dim_empty_flag then
    if g_debug then
      EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('This dimension was fully refreshed. So no need to inc refresh derv/summ facts'
      ,FND_LOG.LEVEL_STATEMENT);
      return true;
    end if;
  end if;
  g_num_derv_fact_full_refresh:=0;
  if g_number_dim_derv_map_id=0 then
    if g_debug then
      EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('There are no derv maps to inc refresh for this dimension',
      FND_LOG.LEVEL_STATEMENT);
    end if;
    return true;
  end if;
  --see if any revf facts need a full refresh
  l_number_looked_at:=0;
  for i in 1..g_number_dim_derv_map_id loop
    if EDW_OWB_COLLECTION_UTIL.value_in_table(l_looked_at,l_number_looked_at,g_derv_fact_id(i))=false then
      l_inc_flag:=false;
      for j in 1..g_number_dim_derv_map_id loop
        if g_derv_fact_id(j)=g_derv_fact_id(i) then
          if g_dim_derv_map_full_refresh(j)=false then
            l_inc_flag:=true;
            exit;
          end if;
        end if;
      end loop;
      if l_inc_flag=false then --all maps are for full refresh
        if EDW_OWB_COLLECTION_UTIL.get_all_maps_for_tgt(g_derv_fact_id(i),l_derv_maps,l_number_derv_maps)=false then
          g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
          g_status:=false;
          return false;
        end if;
        if g_debug then
          EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('l_number_derv_maps='||l_number_derv_maps,FND_LOG.LEVEL_STATEMENT);
          for j in 1..l_number_derv_maps loop
            EDW_OWB_COLLECTION_UTIL.write_to_log_file('l_derv_maps='||l_derv_maps(j),FND_LOG.LEVEL_STATEMENT);
          end loop;
        end if;
        l_found:=false;
        for j in 1..l_number_derv_maps loop
          if EDW_OWB_COLLECTION_UTIL.value_in_table(g_dim_derv_map_id,g_number_dim_derv_map_id,l_derv_maps(j))=
          false then
            l_found:=true;
            exit;
          end if;
        end loop;
        if l_found=false then --all maps are for full refresh and this der fact only has these maps.
          g_num_derv_fact_full_refresh:=g_num_derv_fact_full_refresh+1;
          g_derv_fact_full_refresh(g_num_derv_fact_full_refresh):=g_derv_fact_id(i);
          for j in 1..g_number_dim_derv_map_id loop
            if g_derv_fact_id(j)=g_derv_fact_full_refresh(g_num_derv_fact_full_refresh) then
              g_dim_derv_map_refresh(i):=false;
            end if;
          end loop;
        end if;
      end if;--if l_inc_flag=false then --all maps are for full refresh
      l_number_looked_at:=l_number_looked_at+1;
      l_looked_at(l_number_looked_at):=g_derv_fact_id(i);
    end if;--if EDW_OWB_COLLECTION_UTIL.value_in_table(l_looked_at,l_number_looked_at,g_derv_fact_id(i))=false then
  end loop;--for i in 1..g_number_dim_derv_map_id loop
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('The Derived/summary facts that are for full refresh',FND_LOG.LEVEL_STATEMENT);
    for i in 1..g_num_derv_fact_full_refresh loop
      EDW_OWB_COLLECTION_UTIL.write_to_log_file(g_derv_fact_full_refresh(i),FND_LOG.LEVEL_STATEMENT);
    end loop;
  end if;
  for i in 1..g_number_dim_derv_map_id loop
    if g_dim_derv_map_refresh(i) then
      l_fact_name:=EDW_OWB_COLLECTION_UTIL.get_object_name(g_derv_fact_id(i));
      if get_map_properties(g_dim_derv_map_id(i),l_src_fact_name,l_src_fact_id)=false then
        return false;
      end if;
      l_table_owner:=EDW_OWB_COLLECTION_UTIL.get_table_owner(l_fact_name);
      l_ilog:=g_bis_owner||'.I'||l_dim_id||'_'||g_dim_derv_map_id(i);--need to drop at the end
      l_dlog:=g_bis_owner||'.D'||l_dim_id||'_'||g_dim_derv_map_id(i);
      g_number_tables_to_drop:=g_number_tables_to_drop+1;
      g_tables_to_drop(g_number_tables_to_drop):=l_ilog;
      g_number_tables_to_drop:=g_number_tables_to_drop+1;
      g_tables_to_drop(g_number_tables_to_drop):=l_dlog;
      g_number_tables_to_drop:=g_number_tables_to_drop+1;
      g_tables_to_drop(g_number_tables_to_drop):=l_ilog||'A';
      g_number_tables_to_drop:=g_number_tables_to_drop+1;
      g_tables_to_drop(g_number_tables_to_drop):=l_dlog||'A';
      l_df_load_pk(i):=EDW_OWB_COLLECTION_UTIL.inc_g_load_pk;
      p_load_fk:=l_df_load_pk(i);
      if g_debug then
        EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('For object '||l_fact_name||', load pk='||l_df_load_pk(i),
        FND_LOG.LEVEL_STATEMENT);
      end if;
      if EDW_OWB_COLLECTION_UTIL.log_collection_start(l_fact_name,g_derv_fact_id(i),'FACT',sysdate,
        g_conc_program_id,l_df_load_pk(i)) =false then
        return false;
      end if;
      l_number_skip_cols:=0;
      if EDW_OWB_COLLECTION_UTIL.find_skip_attributes(l_fact_name,'DERIVED FACT',l_skip_cols,
        l_number_skip_cols)=false then
        return false;
      end if;
      for j in 1..g_number_before_update_table loop
        l_number_bu_tables:=1;
        l_bu_tables(1):=g_before_update_table(j);
        l_bu_dimensions(1):=p_dim_name;
        l_prot_delete:=g_bis_owner||'.PD'||l_dim_id||'_'||g_dim_derv_map_id(i)||'_'||j;
        l_prot_update:=g_bis_owner||'.PU'||l_dim_id||'_'||g_dim_derv_map_id(i)||'_'||j;
        g_number_tables_to_drop:=g_number_tables_to_drop+1;
        g_tables_to_drop(g_number_tables_to_drop):=l_prot_delete;
        g_number_tables_to_drop:=g_number_tables_to_drop+1;
        g_tables_to_drop(g_number_tables_to_drop):=l_prot_update;
        if g_dim_derv_map_full_refresh(i) then
          l_bu_src_fact:=null;
        else
          if EDW_OWB_COLLECTION_UTIL.check_table(l_prot_delete)=false or
          EDW_OWB_COLLECTION_UTIL.check_table(l_prot_update)=false then
            l_derv_bu_map_src_table:=g_bis_owner||'.BUS'||l_dim_id||'_'||g_dim_derv_map_id(i)||'_'||j;
            if create_bu_src_fact(l_src_fact_name,l_src_fact_id,p_dim_name,l_dim_id,g_dim_derv_map_id(i),
            l_derv_bu_map_src_table,g_before_update_table(j),l_bu_src_fact)=false then
              return false;
            end if;
            g_number_tables_to_drop:=g_number_tables_to_drop+1;
            g_tables_to_drop(g_number_tables_to_drop):=l_derv_bu_map_src_table;
          end if;
        end if;
        for k in 1..2 loop
          if k=1 then
            l_load_mode:='BU-DELETE';
            if EDW_OWB_COLLECTION_UTIL.check_table(l_prot_delete) then
              goto loopend;
            end if;
          else
            l_load_mode:='BU-UPDATE';
            l_number_bu_tables:=0;
            if EDW_OWB_COLLECTION_UTIL.check_table(l_prot_update) then
              goto loopend;
            end if;
          end if;
          --what about progress logging?
          if g_debug then
            EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Load '||l_fact_name||' from '||l_src_fact_name,
            FND_LOG.LEVEL_STATEMENT);
            EDW_OWB_COLLECTION_UTIL.write_to_log_file('l_load_mode='||l_load_mode||',l_bu_src_fact='||l_bu_src_fact,
            FND_LOG.LEVEL_STATEMENT);
            for z in 1..l_number_bu_tables loop
              EDW_OWB_COLLECTION_UTIL.write_to_log_file('l_bu_tables='||l_bu_tables(z)||',l_bu_dimensions='||l_bu_dimensions(z),
              FND_LOG.LEVEL_STATEMENT);
            end loop;
          end if;
          if EDW_DERIVED_FACT_COLLECT.COLLECT_FACT(
            l_fact_name,
            g_derv_fact_id(i),
            l_src_fact_name,
            l_src_fact_id,
            g_dim_derv_map_id(i),
            g_conc_program_id,
            g_conc_program_name,
            g_debug,
            0,--g_collection_size
            g_parallel,
            g_bis_owner,
            l_table_owner,
            l_ins_rows_processed,--an out NOCOPY parameter
            l_ilog,
            l_dlog,
            g_forall_size,
            g_update_type,
            null,--the fact dlog
            l_skip_cols ,
            l_number_skip_cols ,
            l_df_load_pk(i),
            false,--fresh restart
            g_op_table_space,
            l_bu_tables ,--before update tables.prop dim change to derv
            l_bu_dimensions ,
            l_number_bu_tables ,
            l_bu_src_fact ,--what table to look at as the src fact. if null, scan the actual src fact
            l_load_mode,
            g_rollback,
            g_stg_join_nl,
            g_thread_type,
            g_max_threads,
            g_min_job_load_size,
            g_sleep_time,
            g_hash_area_size,
            g_sort_area_size,
            g_trace,
            g_read_cfig_options
            )=false then
            g_status_message:=EDW_DERIVED_FACT_COLLECT.g_status_message;
            g_status:=false;
            return false;
          end if;
          if l_load_mode='BU-DELETE' then
            if EDW_OWB_COLLECTION_UTIL.create_prot_table(l_prot_delete,g_op_table_space)=false then
              return false;
            end if;
          else
            if EDW_OWB_COLLECTION_UTIL.create_prot_table(l_prot_update,g_op_table_space)=false then
              return false;
            end if;
          end if;
          <<loopend>>
          null;
        end loop;--for k in 1..2 loop
      end loop;--for j in 1..g_number_before_update_table loop
      if get_temp_log_data(l_fact_name, 'FACT')=false then
        return_with_error(l_df_load_pk(i),'LOG');
        return false;
      end if;
      return_with_success('LOG',null,l_df_load_pk(i));
    end if;
  end loop;
  --full refresh of all the needed derv/summary facts
  for i in 1..g_num_derv_fact_full_refresh loop
    l_df_load_pk(i):=EDW_OWB_COLLECTION_UTIL.inc_g_load_pk;
    p_load_fk:=l_df_load_pk(i);
    l_fact_name:=EDW_OWB_COLLECTION_UTIL.get_object_name(g_derv_fact_id(i));
    if g_debug then
      EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Going to fully refresh '||l_fact_name||'('||g_derv_fact_full_refresh(i)||')'
      ,FND_LOG.LEVEL_STATEMENT);
    end if;
    if EDW_OWB_COLLECTION_UTIL.log_collection_start(l_fact_name,g_derv_fact_id(i),'FACT',sysdate,g_conc_program_id,
      l_df_load_pk(i)) =false then
      return false;
    end if;
    l_number_skip_cols:=0;
    if EDW_OWB_COLLECTION_UTIL.find_skip_attributes(l_fact_name,'DERIVED FACT',l_skip_cols,l_number_skip_cols)=false then
      return false;
    end if;
    if EDW_DERIVED_FACT_COLLECT.COLLECT_FACT(
      l_fact_name,
      g_conc_program_id,
      g_conc_program_name,
      g_debug,
      0,--g_collection_size,
      g_parallel,
      g_bis_owner,
      g_table_owner,
      l_ins_rows_processed,
      g_forall_size,
      g_update_type,
      l_skip_cols,
      l_number_skip_cols,
      l_df_load_pk(i),--p_load_pk
      false,--g_fresh_restart
      g_op_table_space,
      g_rollback,
      g_stg_join_nl,
      g_thread_type,
      g_max_threads,
      g_min_job_load_size,
      g_sleep_time,
      g_hash_area_size,
      g_sort_area_size,
      g_trace,
      g_read_cfig_options
      ) = false then
      g_status_message:=EDW_DERIVED_FACT_COLLECT.get_status_message;
      g_status:=false;
      return false;
    end if;
    if get_temp_log_data(l_fact_name, 'FACT')=false then
      return_with_error(l_df_load_pk(i),'LOG');
      return false;
    end if;
    return_with_success('LOG',null,l_df_load_pk(i));
  end loop;
  for i in 1..g_number_tables_to_drop loop
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_tables_to_drop(i))=false then
      null;
    end if;
  end loop;
  for i in 1..g_number_before_update_table loop
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_before_update_table(i))=false then
      null;
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(g_status_message,FND_LOG.LEVEL_ERROR);
  g_status:=false;
  return false;
End;

/*
we need to decide if we need to create a copy of the src fact. look at the col stats and then decide.
return null if there is no need to create a copy table
this api is called per map
*/
function create_bu_src_fact(p_src_fact varchar2,p_src_fact_id number,
p_dim_name varchar2,p_dim_id number, p_map_id number,p_derv_bu_map_src_table varchar2,
p_derv_before_update_table varchar2,p_bu_src_table out NOCOPY varchar2)
return boolean is
l_stmt varchar2(10000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_owner varchar2(200);
l_fk EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_pk EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_fk number;
l_count number;
l_derv_bu_map_src_table varchar2(200);
Begin
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('In create_bu_src_fact',FND_LOG.LEVEL_STATEMENT);
  end if;
  p_bu_src_table:=null;
  l_derv_bu_map_src_table:=p_derv_bu_map_src_table||'R';
  l_owner:=EDW_OWB_COLLECTION_UTIL.get_table_owner(p_src_fact);
  l_number_fk:=0;
  if EDW_OWB_COLLECTION_UTIL.get_fk_pk(p_src_fact_id,p_dim_id,p_map_id,l_fk,l_pk,l_number_fk)=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    g_status:=false;
    return false;
  end if;
  if EDW_OWB_COLLECTION_UTIL.check_table(p_derv_bu_map_src_table) then
    p_bu_src_table:=p_derv_bu_map_src_table;
    return true;
  else
    if l_number_fk=1 then
      l_stmt:='create table '||p_derv_bu_map_src_table||' tablespace '||g_op_table_space;--storage?
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||' as select /*+ORDERED*/ ';
      if g_parallel is not null then
        l_stmt:=l_stmt||' /*+PARALLEL('||p_src_fact||','||g_parallel||')*/ ';
      end if;
      l_stmt:=l_stmt||p_src_fact||'.* from '||p_derv_before_update_table||','||p_src_fact||' where '||
      p_derv_before_update_table||'.'||l_pk(1)||'='||p_src_fact||'.'||l_fk(1);
    else
      l_stmt:='create table '||l_derv_bu_map_src_table||' tablespace '||g_op_table_space;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||' as ';
      for i in 1..l_number_fk loop
        l_stmt:=l_stmt||' select /*+ORDERED*/ ';
        if g_parallel is not null then
          l_stmt:=l_stmt||' /*+PARALLEL('||p_src_fact||','||g_parallel||')*/ ';
        end if;
        l_stmt:=l_stmt||p_src_fact||'.rowid row_id from '||p_derv_before_update_table||','||p_src_fact||
        ' where '||p_derv_before_update_table||'.'||l_pk(i)||'='||p_src_fact||'.'||l_fk(i)||' UNION ';
      end loop;
      l_stmt:=substr(l_stmt,1,length(l_stmt)-6);
      if g_debug then
        EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Going to execute '||l_stmt||get_time,FND_LOG.LEVEL_STATEMENT);
      end if;
      execute immediate l_stmt;
      l_count:=sql%rowcount;
      if g_debug then
        EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Created '||l_derv_bu_map_src_table||' with '||l_count||' rows '||get_time
        ,FND_LOG.LEVEL_STATEMENT);
      end if;
      EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_derv_bu_map_src_table,
      instr(l_derv_bu_map_src_table,'.')+1,length(l_derv_bu_map_src_table)),
      substr(l_derv_bu_map_src_table,1,instr(l_derv_bu_map_src_table,'.')-1));
      l_stmt:='create table '||p_derv_bu_map_src_table||' tablespace '||g_op_table_space;--storage?
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||' as select /*+ORDERED*/ ';
      if g_parallel is not null then
        l_stmt:=l_stmt||' /*+PARALLEL('||p_src_fact||','||g_parallel||')*/ ';
      end if;
      l_stmt:=l_stmt||p_src_fact||'.* from '||l_derv_bu_map_src_table||','||p_src_fact||' where '||
      l_derv_bu_map_src_table||'.row_id='||p_src_fact||'.rowid';
    end if;
    if g_debug then
      EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Going to execute '||l_stmt||get_time,FND_LOG.LEVEL_STATEMENT);
    end if;
    execute immediate l_stmt;
    l_count:=sql%rowcount;
    if g_debug then
      EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Created '||p_derv_bu_map_src_table||' with '||l_count||' rows '||get_time
      ,FND_LOG.LEVEL_STATEMENT);
    end if;
    p_bu_src_table:=p_derv_bu_map_src_table;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(p_derv_bu_map_src_table,
        instr(p_derv_bu_map_src_table,'.')+1,length(p_derv_bu_map_src_table)),
        substr(p_derv_bu_map_src_table,1,instr(p_derv_bu_map_src_table,'.')-1));
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_derv_bu_map_src_table)=false then
      null;
    end if;
  end if;--else for if EDW_OWB_COLLECTION_UTIL.check_table(p_derv_bu_map_src_table) then
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(g_status_message,FND_LOG.LEVEL_ERROR);
  g_status:=false;
  return false;
End;

function get_map_properties(p_map_id number,p_src_fact_name out NOCOPY varchar2,p_src_fact_id out NOCOPY number)
return boolean is
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  --not checked
  l_stmt:='select rel.relation_name,rel.relation_id '||
  'from '||
  'edw_pvt_map_properties_md_v map, '||
  'edw_relations_md_v rel '||
  'where map.mapping_id=:a '||
  'and rel.relation_id=map.primary_source ';
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Going to execute '||l_stmt||' using '||p_map_id,FND_LOG.LEVEL_STATEMENT);
  end if;
  open cv for l_stmt using p_map_id;
  fetch cv into p_src_fact_name,p_src_fact_id;
  close cv;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(g_status_message,FND_LOG.LEVEL_ERROR);
  g_status:=false;
  return false;
End;

function find_data_alignment_cols(p_object_name varchar2) return boolean is
Begin
  g_number_da_cols:=0;
  if g_read_cfig_options then
    if edw_option.get_option_columns(p_object_name,null,'ALIGNMENT',g_da_cols,g_number_da_cols)=false then
      g_status_message:=edw_option.g_status_message;
      EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(g_status_message,FND_LOG.LEVEL_STATEMENT);
      g_status:=false;
      return false;
    end if;
  else
    if EDW_OWB_COLLECTION_UTIL.get_item_set_cols(g_da_cols,g_number_da_cols,p_object_name,'DATA_ALIGNMENT')=false then
      g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
      EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(g_status_message,FND_LOG.LEVEL_STATEMENT);
      g_status:=false;
      return false;
    end if;
  end if;
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('The data alignment columns('||g_number_da_cols||')',FND_LOG.LEVEL_STATEMENT);
    for i in 1..g_number_da_cols loop
      EDW_OWB_COLLECTION_UTIL.write_to_log_file(g_da_cols(i),FND_LOG.LEVEL_STATEMENT);
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(g_status_message,FND_LOG.LEVEL_ERROR);
  g_status:=false;
  return false;
End;

function read_config_options return boolean is
l_option_value varchar2(200);
l_hash_area_size number;
l_sort_area_size number;
l_num number;
Begin
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('In read_config_options',FND_LOG.LEVEL_STATEMENT);
  l_option_value:=null;
  if edw_option.get_warehouse_option(null,g_object_id,'TRACE',l_option_value)=false then
    null;
  end if;
  if l_option_value='Y' then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Trace turned ON',FND_LOG.LEVEL_STATEMENT);
    g_trace:=true;
  else
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Trace turned OFF',FND_LOG.LEVEL_STATEMENT);
    g_trace:=false;
  end if;
  if g_trace then
    EDW_OWB_COLLECTION_UTIL.alter_session('TRACE');
  end if;
  l_option_value:=null;
  if edw_option.get_warehouse_option(null,g_object_id,'DEBUG',l_option_value)=false then
    null;
  end if;
  if l_option_value='Y' or FND_LOG.G_CURRENT_RUNTIME_LEVEL=FND_LOG.LEVEL_STATEMENT then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Debug turned ON',FND_LOG.LEVEL_STATEMENT);
    g_debug:=true;
  else
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Debug turned OFF',FND_LOG.LEVEL_STATEMENT);
    g_debug:=false;
  end if;
  EDW_OWB_COLLECTION_UTIL.set_debug(g_debug);
  l_option_value:=null;
  if edw_option.get_warehouse_option(null,g_object_id,'DUPLICATE',l_option_value)=false then
    null;
  end if;
  if l_option_value='Y' then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Duplicate Load turned ON',FND_LOG.LEVEL_STATEMENT);
    g_duplicate_collect:=true;
  else
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Duplicate Load turned OFF',FND_LOG.LEVEL_STATEMENT);
    g_duplicate_collect:=false;
  end if;
  l_option_value:=null;
  if edw_option.get_warehouse_option(null,g_object_id,'COMMITSIZE',l_option_value)=false then
    null;
  end if;
  if l_option_value is not null then
    g_collection_size:=to_number(l_option_value);
  else
    g_collection_size:=0;
  end if;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Collection size= '||g_collection_size,FND_LOG.LEVEL_STATEMENT);
  g_bis_owner:=EDW_OWB_COLLECTION_UTIL.get_db_user('BIS');
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('BIS Owner is '||g_bis_owner,FND_LOG.LEVEL_STATEMENT);
  l_option_value:=null;
  if edw_option.get_warehouse_option(null,g_object_id,'PARALLELISM',l_option_value)=false then
    null;
  end if;
  if l_option_value is not null then
    g_parallel:=to_number(l_option_value);
    if g_parallel=0 then
      g_parallel:=null;
    end if;
  else
    g_parallel:=null;
  end if;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n ('Degree of parallelism (null is default)='||g_parallel,FND_LOG.LEVEL_STATEMENT);
  if g_parallel is not null then
    EDW_OWB_COLLECTION_UTIL.alter_session('PARALLEL');
    commit;
  end if;
  l_option_value:=null;
  if g_object_type='FACT' then
    l_option_value:='Y';
  else
    if edw_option.get_warehouse_option(null,g_object_id,'AUTOKEYGEN',l_option_value)=false then
      null;
    end if;
  end if;
  if l_option_value='Y' then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Dangling Load turned ON',FND_LOG.LEVEL_STATEMENT);
    g_mode:='TEST';
  else
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Dangling Load turned OFF',FND_LOG.LEVEL_STATEMENT);
    g_mode:='NORMAL';
  end if;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Mode is '||g_mode,FND_LOG.LEVEL_STATEMENT);
  g_explain_plan_check:=FALSE;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Explain plan check OFF',FND_LOG.LEVEL_STATEMENT);
  l_option_value:=null;
  if edw_option.get_warehouse_option(null,g_object_id,'HASHAREA',l_option_value)=false then
    null;
  end if;
  if l_option_value is not null then
    l_hash_area_size:=to_number(l_option_value);
    if l_hash_area_size=0 then
      l_hash_area_size:=null;
    end if;
  else
    l_hash_area_size:=null;
  end if;
  if l_hash_area_size is not null then
    execute immediate 'alter session set hash_area_size='||l_hash_area_size;
  end if;
  l_option_value:=null;
  if edw_option.get_warehouse_option(null,g_object_id,'SORTAREA',l_option_value)=false then
    null;
  end if;
  if l_option_value is not null then
    l_sort_area_size:=to_number(l_option_value);
    if l_sort_area_size=0 then
      l_sort_area_size:=null;
    end if;
  else
    l_sort_area_size:=null;
  end if;
  if l_sort_area_size is not null then
    execute immediate 'alter session set sort_area_size='||l_sort_area_size;
  end if;
  l_option_value:=null;
  if edw_option.get_warehouse_option(null,g_object_id,'KEYSETSIZE',l_option_value)=false then
    null;
  end if;
  if l_option_value is not null then
    g_key_set:=to_number(l_option_value);
    if g_key_set<2 then
      g_key_set:=2;
    end if;
  else
    g_key_set:=2;
  end if;
  if g_parallel>1 and g_key_set<10 then
    g_key_set:=10;
  end if;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('g_key_set='||g_key_set,FND_LOG.LEVEL_STATEMENT);
  l_option_value:=null;
  if edw_option.get_warehouse_option(null,g_object_id,'FRESHSTART',l_option_value)=false then
    null;
  end if;
  if l_option_value='Y' then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Fresh Restart TRUE',FND_LOG.LEVEL_STATEMENT);
    g_fresh_restart:=true;
  else
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Fresh Restart FALSE',FND_LOG.LEVEL_STATEMENT);
    g_fresh_restart:=false;
  end if;
  l_option_value:=null;
  if edw_option.get_warehouse_option(null,g_object_id,'OPTABLESPACE',l_option_value)=false then
    null;
  end if;
  if l_option_value is not null then
    g_op_table_space:=l_option_value;
  else
    g_op_table_space:=EDW_OWB_COLLECTION_UTIL.get_table_space(g_bis_owner);
  end if;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Operation table space='||g_op_table_space,FND_LOG.LEVEL_STATEMENT);
  l_option_value:=null;
  if edw_option.get_warehouse_option(null,g_object_id,'ROLLBACK',l_option_value)=false then
    null;
  end if;
  g_rollback:=l_option_value;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Rollback Segment='||g_rollback,FND_LOG.LEVEL_STATEMENT);
  l_option_value:=null;
  if edw_option.get_warehouse_option(null,g_object_id,'UPDATETYPE',l_option_value)=false then
    null;
  end if;
  if l_option_value is not null then
    g_update_type:=l_option_value;
  else
    g_update_type:='MASS';
  end if;
  if g_update_type<>'MASS' and g_update_type<>'ROW-BY-ROW' then
    g_update_type:='MASS';
  end if;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Update Type='||g_update_type,FND_LOG.LEVEL_STATEMENT);
  l_option_value:=null;
  if edw_option.get_warehouse_option(null,g_object_id,'SMARTUPDATE',l_option_value)=false then
    null;
  end if;
  if l_option_value='Y' then
    g_smart_update:=true;
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Smart Update TRUE',FND_LOG.LEVEL_STATEMENT);
  else
    g_smart_update:=false;
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Smart Update FALSE',FND_LOG.LEVEL_STATEMENT);
  end if;
  g_number_smart_update_cols:=0;
  if g_smart_update then
    if edw_option.get_option_columns(null,g_object_id,'SMARTUPDATE',g_smart_update_cols,
      g_number_smart_update_cols)=false then
      EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Error in getting columns for smart update '||edw_option.g_status_message,
      FND_LOG.LEVEL_STATEMENT);
      g_number_smart_update_cols:=0;
    end if;
    if g_debug then
      EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('The smart update columns',FND_LOG.LEVEL_STATEMENT);
      for i in 1..g_number_smart_update_cols loop
        EDW_OWB_COLLECTION_UTIL.write_to_log_file(g_smart_update_cols(i),FND_LOG.LEVEL_STATEMENT);
      end loop;
    end if;
  end if;
  l_option_value:=null;
  if edw_option.get_warehouse_option(null,g_object_id,'FK_USE_NL',l_option_value)=false then
    null;
  end if;
  if l_option_value is not null then
    g_fk_use_nl:=to_number(l_option_value);
    if g_fk_use_nl<0 then
      g_fk_use_nl:=0;
    end if;
  else
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('g_fk_use_nl null. setting to 100,000',FND_LOG.LEVEL_STATEMENT);
    g_fk_use_nl:=100000;
  end if;
  l_option_value:=null;
  if edw_option.get_warehouse_option(null,g_object_id,'LTC_COPY_MERGE_NL',l_option_value)=false then
    null;
  end if;
  if l_option_value='Y' then
    g_ltc_merge_use_nl:=true;
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('LTC Copy Merge TRUE',FND_LOG.LEVEL_STATEMENT);
  else
    g_ltc_merge_use_nl:=false;
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('LTC Copy Merge FALSE',FND_LOG.LEVEL_STATEMENT);
  end if;
  l_option_value:=null;
  g_dim_inc_refresh_derv:=false;
  if g_object_type='DIMENSION' then
    if edw_option.get_warehouse_option(null,g_object_id,'INCREMENTAL',l_option_value)=false then
      null;
    end if;
    if l_option_value='Y' then
      g_dim_inc_refresh_derv:=true;--propogate dim changes to derv facts
    else
      g_dim_inc_refresh_derv:=false;
    end if;
  end if;
  if edw_option.get_warehouse_option(null,g_object_id,'STG_JOIN_NL',l_option_value)=false then
    null;
  end if;
  if l_option_value is not null then
    if l_option_value>0 and l_option_value<=100 then
      g_stg_join_nl:=to_number(l_option_value);
    end if;
  end if;
  if edw_option.get_warehouse_option(null,g_object_id,'OK_UPDATE',l_option_value)=false then
    null;
  end if;
  if l_option_value is not null then
    if l_option_value>0 and l_option_value<=100 then
      g_ok_switch_update:=to_number(l_option_value);
    end if;
  end if;
  if edw_option.get_warehouse_option(null,g_object_id,'STG_MAKE_COPY',l_option_value)=false then
    null;
  end if;
  if l_option_value is not null then
    if l_option_value>0 and l_option_value<=100 then
      g_stg_make_copy_percentage:=to_number(l_option_value);
    end if;
  end if;
  g_auto_dang_recovery:=false;
  l_option_value:=null;
  if edw_option.get_warehouse_option(null,g_object_id,'AUTODANG',l_option_value)=false then
    null;
  end if;
  if l_option_value='Y' then
    g_auto_dang_recovery:=true;
  end if;
  g_create_parent_table_records:=false;
  if g_auto_dang_recovery then
    g_create_parent_table_records:=true;
  end if;
  l_option_value:=null;
  if edw_option.get_warehouse_option(null,g_object_id,'MAX_THREADS',l_option_value)=false then
    null;
  end if;
  begin
    l_num:=to_number(l_option_value);
  exception when others then
    l_option_value:='AUTO';
  end;
  if l_option_value='AUTO' then
    l_num:=EDW_OWB_COLLECTION_UTIL.get_job_queue_processes;
  end if;
  if l_num is not null and l_num>0 then
    g_max_threads:=l_num;
  end if;
  l_option_value:=null;
  if edw_option.get_warehouse_option(null,g_object_id,'MIN_JOB_LOAD_SIZE',l_option_value)=false then
    null;
  end if;
  if l_option_value is not null and l_option_value>0 then
    g_min_job_load_size:=to_number(l_option_value);
  end if;
  l_option_value:=null;
  if edw_option.get_warehouse_option(null,g_object_id,'SLEEP_TIME',l_option_value)=false then
    null;
  end if;
  if l_option_value is not null and l_option_value>0 then
    g_sleep_time:=to_number(l_option_value);
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(g_status_message,FND_LOG.LEVEL_ERROR);
  g_status:=false;
  return false;
End;

function read_profile_options return boolean is
l_hash_area_size number;
l_sort_area_size number;
l_key_set varchar2(400);
l_num number;
l_var varchar2(400);
check_tspace_exist varchar(1);
check_ts_mode varchar(1);
physical_tspace_name varchar2(100);

Begin
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('In read_profile_options',FND_LOG.LEVEL_STATEMENT);
  if fnd_profile.value('EDW_TRACE')='Y' then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Trace turned ON',FND_LOG.LEVEL_STATEMENT);
    g_trace:=true;
  else
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Trace turned OFF',FND_LOG.LEVEL_STATEMENT);
    g_trace:=false;
  end if;
  commit;
  if g_trace then
    EDW_OWB_COLLECTION_UTIL.alter_session('TRACE');
    commit;
  end if;
  if fnd_profile.value('EDW_DEBUG')='Y' or FND_LOG.G_CURRENT_RUNTIME_LEVEL=FND_LOG.LEVEL_STATEMENT then
    g_debug:=true;--look at the profile value for this
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Debug turned ON',FND_LOG.LEVEL_STATEMENT);
  else
    g_debug:=false;
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Debug turned OFF',FND_LOG.LEVEL_STATEMENT);
  end if;
  EDW_OWB_COLLECTION_UTIL.set_debug(g_debug);
  if fnd_profile.value('EDW_DUPLICATE_COLLECT')='Y' then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Duplicate collect is turned ON',FND_LOG.LEVEL_STATEMENT);
    g_duplicate_collect:=true;--look at the profile value for this
  else
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Duplicate collect is turned OFF',FND_LOG.LEVEL_STATEMENT);
    g_duplicate_collect:=false;
  end if;
  if g_object_type='DIMENSION' then
    g_dim_push_down:=EDW_OWB_COLLECTION_UTIL.is_push_down_implemented(g_object_name);
    if g_dim_push_down then
      EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Dimension Push Down Implemented',FND_LOG.LEVEL_STATEMENT);
    else
      EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Dimension Push Down NOT Implemented',FND_LOG.LEVEL_STATEMENT);
    end if;
  end if;
  g_collection_size:=fnd_profile.value('EDW_COLLECTION_SIZE');
  if g_collection_size is null then
    g_collection_size:=0;
  end if;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Collection size= '||g_collection_size,FND_LOG.LEVEL_STATEMENT);
  g_bis_owner:=EDW_OWB_COLLECTION_UTIL.get_db_user('BIS');
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('BIS Owner is '||g_bis_owner,FND_LOG.LEVEL_STATEMENT);
  g_parallel:=fnd_profile.value('EDW_PARALLEL');
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n ('Degree of parallelism (null is default)='||g_parallel,FND_LOG.LEVEL_STATEMENT);
  if g_parallel=0 then
    g_parallel:=null;
  end if;
  commit;
  if g_parallel is not null then
    EDW_OWB_COLLECTION_UTIL.alter_session('PARALLEL');
    commit;
  end if;
  if fnd_profile.value('EDW_TEST_MODE')='Y' then
    g_mode:='TEST';
  else
    g_mode:='NORMAL';
  end if;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Mode is '||g_mode,FND_LOG.LEVEL_STATEMENT);
  if fnd_profile.value('EDW_USE_EXP_PLAN')='Y' then
    g_explain_plan_check:=TRUE;
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Explain plan check ON',FND_LOG.LEVEL_STATEMENT);
  else
    g_explain_plan_check:=FALSE;
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Explain plan check OFF',FND_LOG.LEVEL_STATEMENT);
  end if;
  l_hash_area_size:=null;
  l_hash_area_size:=fnd_profile.value('EDW_HASH_AREA_SIZE');
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('l_hash_area_size='||l_hash_area_size,FND_LOG.LEVEL_STATEMENT);
  if l_hash_area_size is not null then
    execute immediate 'alter session set hash_area_size='||l_hash_area_size;
  end if;
  l_sort_area_size:=null;
  l_sort_area_size:=fnd_profile.value('EDW_SORT_AREA_SIZE');
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('l_sort_area_size='||l_sort_area_size,FND_LOG.LEVEL_STATEMENT);
  if l_sort_area_size is not null then
    execute immediate 'alter session set sort_area_size='||l_sort_area_size;
  end if;
  if fnd_profile.value('EDW_FRESH_RESTART')='Y' then
     g_fresh_restart:=true;
     EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Fresh Restart TRUE',FND_LOG.LEVEL_STATEMENT);
  else
    g_fresh_restart:=false;
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Fresh Restart FALSE',FND_LOG.LEVEL_STATEMENT);
  end if;

  g_op_table_space:=fnd_profile.value('EDW_OP_TABLE_SPACE');
  if g_op_table_space is null then
	AD_TSPACE_UTIL.is_new_ts_mode (check_ts_mode);
	If check_ts_mode ='Y' then
		AD_TSPACE_UTIL.get_tablespace_name ('BIS', 'INTERFACE','Y',check_tspace_exist, physical_tspace_name);
		if check_tspace_exist='Y' and physical_tspace_name is not null then
			g_op_table_space :=  physical_tspace_name;
		end if;
	end if;
   end if;
  if g_op_table_space is null then
    g_op_table_space:=EDW_OWB_COLLECTION_UTIL.get_table_space(g_bis_owner);
  end if;

  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Operation table space='||g_op_table_space,FND_LOG.LEVEL_STATEMENT);
  g_rollback:=fnd_profile.value('EDW_LOAD_ROLLBACK');
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Rollback Segment='||g_rollback,FND_LOG.LEVEL_STATEMENT);
  g_update_type:=fnd_profile.value('EDW_UPDATE_TYPE');
  if g_update_type is null then
    g_update_type:='MASS';
  end if;
  if g_update_type<>'MASS' and g_update_type<>'ROW-BY-ROW' then
    g_update_type:='MASS';
  end if;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Update Type='||g_update_type,FND_LOG.LEVEL_STATEMENT);
  if fnd_profile.value('EDW_SMART_UPDATE')='Y' then
    g_smart_update:=true;
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Smart Update TRUE',FND_LOG.LEVEL_STATEMENT);
  else
    g_smart_update:=false;
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Smart Update FALSE',FND_LOG.LEVEL_STATEMENT);
  end if;
  g_number_smart_update_cols:=0;
  if g_smart_update then
    if EDW_OWB_COLLECTION_UTIL.get_item_set_cols(g_smart_update_cols,g_number_smart_update_cols,g_object_name,
      'CHECK_COLUMNS_FOR_UPDATE')=false then
      EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(EDW_OWB_COLLECTION_UTIL.g_status_message,FND_LOG.LEVEL_STATEMENT);
    end if;
    if g_debug then
      EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('The smart update columns',FND_LOG.LEVEL_STATEMENT);
      for i in 1..g_number_smart_update_cols loop
        EDW_OWB_COLLECTION_UTIL.write_to_log_file(g_smart_update_cols(i),FND_LOG.LEVEL_STATEMENT);
      end loop;
    end if;
  end if;
  begin
    g_fk_use_nl:=fnd_profile.value('EDW_FK_USE_NL');
    if g_fk_use_nl is null then
      EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('g_fk_use_nl null. setting to 100,000',FND_LOG.LEVEL_STATEMENT);
      g_fk_use_nl:=100000;
    end if;
  exception when others then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('EDW_FK_USE_NL is still boolean. Setting to 100,000',FND_LOG.LEVEL_STATEMENT);
    g_fk_use_nl:=100000;
  end;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('FK Use NL ='||g_fk_use_nl,FND_LOG.LEVEL_STATEMENT);
  g_ltc_merge_use_nl:=false;
  if fnd_profile.value('EDW_LTC_COPY_MERGE_NL')='Y' then
    g_ltc_merge_use_nl:=true;
  end if;
  if g_ltc_merge_use_nl then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('LTC Copy Merge TRUE',FND_LOG.LEVEL_STATEMENT);
  else
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('LTC Copy Merge FALSE',FND_LOG.LEVEL_STATEMENT);
  end if;
  g_dim_inc_refresh_derv:=false;
  if g_object_type='DIMENSION' then
    if EDW_OWB_COLLECTION_UTIL.is_itemset_implemented(g_object_name,'EDW_INC_REFRESH',null)='Y' then
      g_dim_inc_refresh_derv:=true; --propogate dim changes to derv facts
    else
      g_dim_inc_refresh_derv:=false;
    end if;
  end if;
  l_num:=fnd_profile.value('EDW_STG_JOIN_NL');
  if l_num is not null then
    if l_num>0 and l_num<101 then
      g_stg_join_nl:=l_num;
    end if;
  end if;
  l_num:=fnd_profile.value('EDW_OK_UPDATE');
  if l_num is not null then
    if l_num>0 and l_num<101 then
      g_ok_switch_update:=l_num;
    end if;
  end if;
  l_num:=fnd_profile.value('EDW_STG_MAKE_COPY');
  if l_num is not null then
    if l_num>0 and l_num<101 then
      g_stg_make_copy_percentage:=l_num;
    end if;
  end if;
  g_auto_dang_recovery:=false;
  if fnd_profile.value('EDW_AUTO_DANG_RECOVERY')='Y' then
    g_auto_dang_recovery:=true;
  end if;
  g_create_parent_table_records:=false;
  if g_auto_dang_recovery then
    g_create_parent_table_records:=true;
  end if;
  l_num:=null;
  l_var:=null;
  l_var:=fnd_profile.value('EDW_MAX_THREADS');
  begin
    l_num:=to_number(l_var);
  exception when others then
    l_var:='AUTO';
  end;
  if l_var='AUTO' then
    l_num:=EDW_OWB_COLLECTION_UTIL.get_job_queue_processes;
  end if;
  if l_num is not null and l_num>0 then
    g_max_threads:=l_num;
  end if;
  l_num:=null;
  l_num:=fnd_profile.value('EDW_MIN_JOB_LOAD_SIZE');
  if l_num is not null and l_num>0 then
    g_min_job_load_size:=l_num;
  end if;
  l_num:=null;
  l_num:=fnd_profile.value('EDW_SLEEP_TIME');
  if l_num is not null and l_num>0 then
    g_sleep_time:=l_num;
  end if;
  l_key_set:=fnd_profile.value('EDW_FK_SET_SIZE');
  if l_key_set is null then
    g_key_set:=5;
  else
    g_key_set:=to_number(l_key_set);
    if g_key_set<=1 then
      g_key_set:=2;
    end if;
  end if;
  if g_parallel>1 and g_key_set<10 then
    g_key_set:=10;
  end if;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('g_key_set='||g_key_set,FND_LOG.LEVEL_STATEMENT);
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(g_status_message,FND_LOG.LEVEL_ERROR);
  g_status:=false;
  return false;
End;

function set_thread_type(
p_max_threads number,
p_job_queue_processes number
) return varchar2 is
l_thread_type varchar2(80);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt varchar2(2000);
l_processes number;
Begin
  if g_conc_program_id >0 then
    --this process is a conc program
    l_thread_type:='CONC';
    --this is if someone insists on having dbms jobs when launched through oracle apps
    if fnd_profile.value('EDW_FORCE_DBMS_JOB')='Y' then
      l_thread_type:='JOB';
    end if;
    begin
      l_stmt:='select running_processes from FND_CONCURRENT_QUEUES where concurrent_queue_name=''STANDARD''';
      if g_debug then
        EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(l_stmt);
      end if;
      open cv for l_stmt;
      fetch cv into l_processes ;
      close cv;
      if g_debug then
        EDW_OWB_COLLECTION_UTIL.write_to_log_file('l_processes='||l_processes);
      end if;
      if p_job_queue_processes>l_processes then
        if g_debug then
          EDW_OWB_COLLECTION_UTIL.write_to_log_file('p_job_queue_processes>l_processes. Using dbms jobs...');
        end if;
        l_thread_type:='JOB';
      end if;
    exception when others then
      null;
    end;
  else
    --not a conc program
    l_thread_type:='JOB';
  end if;
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('l_thread_type='||l_thread_type,FND_LOG.LEVEL_STATEMENT);
  end if;
  return l_thread_type;
Exception when others then
  g_status_message:='Error in set_thread_type '||sqlerrm;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n(g_status_message,FND_LOG.LEVEL_ERROR);
  return null;
End;

--see if the dim can have parallel drill down where a dbms job is launched after a level is
--loaded . this job will drill down the changes to the child levels
--this approach cannot be used if
--if error recovery
--or if there is na_edw update
--or if this is initial load
--or if there is push down
procedure find_parallel_drill_down(
p_levels EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_num_levels number) is
--
l_ilog varchar2(40);
l_job_queue_processes number;
--
Begin
  if g_debug then
    write_to_log_file_n('In find_parallel_drill_down');
  end if;
  g_parallel_drill_down:=true;
  if g_max_threads is null or g_max_threads<2 then
    if g_debug then
      write_to_log_file('g_max_threads is null or g_max_threads<2');
    end if;
    g_parallel_drill_down:=false;
    return;
  end if;
  --see if job_queue_processes > 0
  l_job_queue_processes:=edw_owb_collection_util.get_parameter_value('job_queue_processes');
  if l_job_queue_processes<1 or l_job_queue_processes<g_max_threads then
    if g_debug then
      write_to_log_file('job_queue_processes<1 or l_job_queue_processes<g_max_threads');
    end if;
    g_parallel_drill_down:=false;
    return;
  end if;
  --check for initial load
  if edw_owb_collection_util.does_table_have_data(g_object_name)<2 then --no data present
    if g_debug then
      write_to_log_file('initial load');
    end if;
    g_parallel_drill_down:=false;
    return;
  end if;
  --check for error recovery
  if edw_owb_collection_util.check_table(g_dd_status_table) then
    if g_debug then
      write_to_log_file(g_dd_status_table||' present');
    end if;
    g_parallel_drill_down:=false;
    return;
  end if;
  l_ilog:=g_bis_owner||'.'||g_object_name||'IL';
  if EDW_OWB_COLLECTION_UTIL.check_table(l_ilog) then
    if g_debug then
      write_to_log_file(l_ilog||' present');
    end if;
    g_parallel_drill_down:=false;
    return;
  end if;
  l_ilog:=g_bis_owner||'.'||g_object_name||'ILA';
  if EDW_OWB_COLLECTION_UTIL.check_table(l_ilog) then
    if g_debug then
      write_to_log_file(l_ilog||' present');
    end if;
    g_parallel_drill_down:=false;
    return;
  end if;
  --check for na_edw update
  --this is not reqd. in naedw there is no update
  --check for push down
  if edw_owb_collection_util.is_push_down_implemented(g_object_name)=true then
    if g_debug then
      write_to_log_file('push down implemented');
    end if;
    g_parallel_drill_down:=false;
    return;
  end if;
  --check for partiotions on ltc table. if the ltc are partitioned, we cannot use this process
  for i in 1..p_num_levels loop
    if edw_owb_collection_util.is_table_partitioned(p_levels(i),g_table_owner)<>'NO' then
      if g_debug then
        write_to_log_file('partitioned');
      end if;
      g_parallel_drill_down:=false;
      return;
    end if;
  end loop;
  --if there is only 1 level, turn this off
  if p_num_levels=1 then
    if g_debug then
      write_to_log_file('only 1 level');
    end if;
    g_parallel_drill_down:=false;
    return;
  end if;
  --just in case we want to turn off parallel drill down
  if fnd_profile.value('EDW_NO_PARALLEL_DD')='Y' then
    if g_debug then
      write_to_log_file('profile EDW_NO_PARALLEL_DD defined');
    end if;
    g_parallel_drill_down:=false;
    return;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  EDW_OWB_COLLECTION_UTIL.write_to_log_file_n('Error in find_parallel_drill_down '||
  g_status_message,FND_LOG.LEVEL_ERROR);
  g_status:=false;
  raise;
End;


END EDW_ALL_COLLECT;

/
