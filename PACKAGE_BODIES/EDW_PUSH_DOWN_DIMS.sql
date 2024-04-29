--------------------------------------------------------
--  DDL for Package Body EDW_PUSH_DOWN_DIMS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_PUSH_DOWN_DIMS" AS
/*$Header: EDWPSDNB.pls 115.15 2003/11/06 00:56:50 vsurendr ship $*/

function push_down_all_levels(
   p_dim_name varchar2,
   p_levels EDW_OWB_COLLECTION_UTIL.varcharTableType,
   p_child_level_number EDW_OWB_COLLECTION_UTIL.numberTableType,
   p_child_levels EDW_OWB_COLLECTION_UTIL.varcharTableType,
   p_child_fk EDW_OWB_COLLECTION_UTIL.varcharTableType,
   p_parent_pk EDW_OWB_COLLECTION_UTIL.varcharTableType,
   p_number_levels number,
   p_level_order  EDW_OWB_COLLECTION_UTIL.varcharTableType,
   p_level_snapshot_logs  EDW_OWB_COLLECTION_UTIL.varcharTableType,
   p_debug boolean,
   p_parallel number,
   p_collection_size number,
   p_bis_owner  varchar2,
   p_table_owner varchar2,
   p_full_refresh boolean,
   p_forall_size number,
   p_update_type varchar2,
   p_load_pk number,
   p_op_table_space varchar2,
   p_dim_push_down out NOCOPY boolean,
   p_rollback varchar2,
   p_thread_type varchar2,
   p_max_threads number,
   p_min_job_load_size number,
   p_sleep_time number,
   p_hash_area_size number,
   p_sort_area_size number,
   p_trace boolean,
   p_read_cfig_options boolean,
   p_join_nl_percentage number
   ) return boolean is
l_status number;
Begin
  write_to_log_file_n('In push_down_all_levels , dim name is '||p_dim_name);
  g_dim_name:=p_dim_name;
  g_levels :=p_levels;
  g_child_level_number:=p_child_level_number;
  g_child_levels:=p_child_levels;
  g_child_fk:=p_child_fk;
  g_parent_pk:=p_parent_pk;
  g_number_levels:=p_number_levels;
  g_level_order:=p_level_order;
  g_level_snapshot_logs:=p_level_snapshot_logs;
  g_debug:=p_debug;
  g_full_refresh:=p_full_refresh;
  g_parallel :=p_parallel;
  g_collection_size :=p_collection_size;
  g_bis_owner:=p_bis_owner;
  g_table_owner:=p_table_owner;
  g_forall_size:=g_forall_size;
  g_update_type:=p_update_type;
  g_load_pk:=p_load_pk;
  g_op_table_space:=p_op_table_space;
  g_rollback:=p_rollback;
  g_max_threads:=p_max_threads;
  g_min_job_load_size:=p_min_job_load_size;
  g_sleep_time:=p_sleep_time;
  g_hash_area_size:=p_hash_area_size;
  g_sort_area_size:=p_sort_area_size;
  g_trace:=p_trace;
  g_read_cfig_options:=p_read_cfig_options;
  g_join_nl_percentage:=p_join_nl_percentage;
  g_job_id:=null;
  g_jobid_stmt:=null;
  g_thread_type:=p_thread_type;
  if g_update_type='DELETE-INSERT' then
    g_update_type:='MASS';
  end if;
  if g_debug then
    if g_full_refresh then
      write_to_log_file('FULL Refresh ON');
    else
      write_to_log_file('FULL Refresh OFF');
    end if;
  end if;
  if g_debug then
    write_to_log_file_n('The inputs');
    write_to_log_file('Levels');
    for i in 1..g_number_levels loop
      write_to_log_file(g_levels(i)||'('||g_child_level_number(i)||') '||g_level_snapshot_logs(i));
    end loop;
    declare
     l_run number:=0;
    begin
      write_to_log_file('Child Levels');
      for i in 1..g_number_levels loop
        for j in 1..g_child_level_number(i) loop
          l_run:=l_run+1;
          write_to_log_file(l_run||' '||g_child_levels(l_run)||'  '||g_child_fk(l_run)||'  '||
           g_parent_pk(l_run));
        end loop;
      end loop;
    exception when others then
      write_to_log_file(sqlerrm);
    end;
    write_to_log_file('g_max_threads='||g_max_threads);
    write_to_log_file('g_min_job_load_size='||g_min_job_load_size);
    write_to_log_file('g_sleep_time='||g_sleep_time);
    write_to_log_file('g_hash_area_size='||g_hash_area_size);
    write_to_log_file('g_sort_area_size='||g_sort_area_size);
    if g_trace then
      write_to_log_file('TRACE TRUE');
    else
      write_to_log_file('TRACE FALSE');
    end if;
    if g_read_cfig_options then
      write_to_log_file('g_read_cfig_options TRUE');
    else
      write_to_log_file('g_read_cfig_options FALSE');
    end if;
    write_to_log_file('g_join_nl_percentage='||g_join_nl_percentage);
    write_to_log_file('g_thread_type='||p_thread_type);
  end if;
  l_status:=find_ltc_to_push_down;
  if l_status=0 then
    write_to_log_file_n('find_ltc_to_push_down returned with error');
    p_dim_push_down:=false;
    return false;
  elsif l_status=1 then
    write_to_log_file_n('Level Push Down not implemented');
    p_dim_push_down:=false;
    return true;
  end if;
  p_dim_push_down:=true;
  if g_number_levels <=1 then
    write_to_log_file_n('Only one level dimension. No need to push down.');
    return true;
  end if;
  g_dim_id:=EDW_OWB_COLLECTION_UTIL.get_dim_id(g_dim_name);
  init_all(null);
  if find_lowest_level =false then
    write_to_log_file_n('find_lowest_level returned with error');
    return false;
  end if;
  if get_all_level_pk=false then
    write_to_log_file_n('get_all_level_pk returned with error');
    return false;
  end if;
  if get_level_prefix=false then
    write_to_log_file_n('get_level_prefix returned with error');
    return false;
  end if;
  if get_level_display_prefix=false then
    write_to_log_file_n('get_level_display_prefix returned with error');
    return false;
  end if;
  if get_level_seq=false then
    write_to_log_file_n('get_level_seq returned with error');
    return false;
  end if;
  if get_all_children_main=false then
    write_to_log_file_n('get_all_children_main returned with error');
    return false;
  end if;
  if find_diamond_levels=false then
    return false;
  end if;
  if check_level_for_column=false then
    return false;
  end if;
  if check_levels_for_data=false then
    write_to_log_file_n('check_levels_for_data returned with error');
    return false;
  end if;
  if merge_all_ilog_tables=false then
    write_to_log_file_n('merge_all_ilog_tables returned with error');
    return false;
  end if;
  if create_ilog_tables=false then
    write_to_log_file_n('create_ilog_tables returned with error');
    return false;
  end if;
  if move_data_into_ilog=false then
    write_to_log_file_n('move_data_into_ilog returned with error');
    return false;
  end if;
  if push_down_all_levels=false then
    write_to_log_file_n('push_down_all_levels returned with error');
    return false;
  end if;
  /*if analyze_ltc_tables=false then
    write_to_log_file_n('analyze_ltc_tables returned with error');
    return false;
  end if;*/
  clean_up;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function push_down_all_levels return boolean is
Begin
  if g_max_threads>1 then
    if push_down_all_levels_multi=false then
      return false;
    end if;
  else
    if push_down_all_levels_single=false then
      return false;
    end if;
  end if;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n('Error in push_down_all_levels '||g_status_message);
 return false;
End;

function push_down_all_levels_multi return boolean is
l_input_table varchar2(80);
l_max_ilog_count number;
l_index number;
l_ok_low_end EDW_OWB_COLLECTION_UTIL.numberTableType;
l_ok_high_end EDW_OWB_COLLECTION_UTIL.numberTableType;
l_ok_end_count integer;
l_job_id EDW_OWB_COLLECTION_UTIL.numberTableType;
l_number_jobs number;
l_job_status_table varchar2(80);
l_log_file varchar2(1000);
-----------------------------------------
l_temp_conc_name varchar2(200);
l_temp_conc_short_name varchar2(200);
l_temp_exe_name varchar2(200);
l_bis_short_name varchar2(200);
l_try_serial boolean;
-----------------------------------------
l_errbuf varchar2(2000);
l_retcode varchar2(200);
-----------------------------------------
Begin
  if g_debug then
    write_to_log_file_n('In push_down_all_levels_multi '||get_time);
  end if;
  for i in 1..g_number_levels loop
    if g_level_consider(i) and g_levels(i)<>g_lowest_level then
      if put_rownum_in_ilog_table(i)=false then
        return false;
      end if;
    end if;
  end loop;
  l_input_table:=g_bis_owner||'.INP_TAB_'||g_dim_id;
  l_job_status_table:=g_bis_owner||'.JOB_STATUS_'||g_dim_id;
  if EDW_OWB_COLLECTION_UTIL.create_input_table_push_down(
    l_input_table,
    g_dim_name,
    g_dim_id,
    g_levels,
    g_child_level_number,
    g_child_levels,
    g_child_fk,
    g_parent_pk,
    g_number_levels,
    g_level_order,
    g_level_snapshot_logs,
    g_level_ilog,
    g_level_consider,
    g_level_full_insert,
    g_debug,
    g_parallel,
    g_collection_size,
    g_bis_owner,
    g_table_owner,
    g_full_refresh,
    g_forall_size,
    g_update_type,
    g_load_pk,
    g_op_table_space,
    g_rollback,
    g_max_threads,
    g_min_job_load_size,
    g_sleep_time,
    g_hash_area_size,
    g_sort_area_size,
    g_trace,
    g_read_cfig_options,
    g_join_nl_percentage
    )=false then
    return false;
  end if;
  if EDW_OWB_COLLECTION_UTIL.create_job_status_table(l_job_status_table,g_op_table_space)=false then
    return false;
  end if;
  for i in 1..g_number_levels loop
    g_level_ilog_count(i):=0;
    if g_level_consider(i) and g_levels(i)<>g_lowest_level then
      g_level_ilog_count(i):=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_level_ilog(i),
      g_bis_owner);
    end if;
  end loop;
  l_max_ilog_count:=EDW_OWB_COLLECTION_UTIL.get_max_in_array(g_level_ilog_count,g_number_levels,l_index);
  if l_index<=0 then
    return false;
  end if;
  /*
  for the ilog with the largest number of records, find the ok dist
  */
  if EDW_OWB_COLLECTION_UTIL.find_ok_distribution(
    g_level_ilog(l_index),
    g_bis_owner,
    g_max_threads,
    g_min_job_load_size,
    l_ok_low_end,
    l_ok_high_end,
    l_ok_end_count)=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.get_status_message;
    return false;
  end if;
  /*
  launch the threads
  */
  if l_ok_end_count>0 then
    if g_debug then
      write_to_log_file_n('Launch multiple threads.');
    end if;
    l_number_jobs:=0;
    l_temp_conc_name:='Sub-Proc Pdn-'||g_dim_id;
    l_temp_conc_short_name:='CONC_PDN_'||g_dim_id||'_CONC';
    l_temp_exe_name:=l_temp_conc_name||'_EXE';
    l_bis_short_name:='BIS';
    if g_thread_type='CONC' then
      --create the executable, conc program etc
      if create_conc_program(l_temp_conc_name,l_temp_conc_short_name,l_temp_exe_name,l_bis_short_name)=false then
        if g_debug then
          write_to_log_file_n('Could not create seed data for conc programs. Trying jobs');
        end if;
        g_thread_type:='JOB';
      end if;
    end if;
    for i in 1..l_ok_end_count loop
      l_number_jobs:=l_number_jobs+1;
      l_job_id(l_number_jobs):=null;
      l_log_file:='LOG_'||g_dim_id||'_PD';
      if g_debug then
        write_to_log_file_n('EDW_PUSH_DOWN_DIMS.PUSH_DOWN_ALL_LEVELS('''||g_dim_name||''','||
        ''''||l_log_file||''','''||l_input_table||''','||l_number_jobs||','||
        l_ok_low_end(i)||','||l_ok_high_end(i)||','''||l_job_status_table||''');');
      end if;
      begin
        l_try_serial:=false;
        if g_thread_type='CONC' then
          l_job_id(l_number_jobs):=FND_REQUEST.SUBMIT_REQUEST(
          application=>l_bis_short_name,
          program=>l_temp_conc_short_name,
          argument1=>g_dim_name,
          argument2=>l_log_file,
          argument3=>l_input_table,
          argument4=>l_number_jobs,
          argument5=>l_ok_low_end(i),
          argument6=>l_ok_high_end(i),
          argument7=>l_job_status_table);
          commit;
          if g_debug then
            write_to_log_file_n('Concurrent Request '||l_job_id(l_number_jobs)||' launched '||get_time);
          end if;
          if l_job_id(l_number_jobs)<=0 then
            l_try_serial:=true;
          end if;
        else
          DBMS_JOB.SUBMIT(l_job_id(l_number_jobs),'EDW_PUSH_DOWN_DIMS.PUSH_DOWN_ALL_LEVELS('''||g_dim_name||''','||
          ''''||l_log_file||''','''||l_input_table||''','||l_number_jobs||','||
          l_ok_low_end(i)||','||l_ok_high_end(i)||','''||l_job_status_table||''');');
          commit;--this commit is very imp
          if g_debug then
            write_to_log_file_n('Job '||l_job_id(l_number_jobs)||' launched '||get_time);
          end if;
          if l_job_id(l_number_jobs)<=0 then
            l_try_serial:=true;
          end if;
        end if;
      exception when others then
        if g_debug then
          write_to_log_file_n('Error launching parallel slaves '||sqlerrm||'. Attempt serial load');
        end if;
        l_try_serial:=true;
      end;
      if l_try_serial then
        if g_debug then
          write_to_log_file_n('Attempt serial load');
        end if;
        l_job_id(l_number_jobs):=0-l_number_jobs;
        EDW_PUSH_DOWN_DIMS.PUSH_DOWN_ALL_LEVELS(
        l_errbuf,
        l_retcode,
        g_dim_name,
        l_log_file,
        l_input_table,
        l_number_jobs,
        l_ok_low_end(i),
        l_ok_high_end(i),
        l_job_status_table
        );
      end if;
    end loop;
    if EDW_OWB_COLLECTION_UTIL.wait_on_jobs(
      l_job_id,
      l_number_jobs,
      g_sleep_time,
      g_thread_type)=false then
      g_status_message:=EDW_OWB_COLLECTION_UTIL.get_status_message;
      return false;
    end if;
    if g_status then
      if EDW_OWB_COLLECTION_UTIL.check_all_child_jobs(
        l_job_status_table,
        l_job_id,
        l_number_jobs,
        null)=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.get_status_message;
        return false;
      end if;
    end if;
    /*if g_thread_type='CONC' then
      --drop the conc programs
      if EDW_OWB_COLLECTION_UTIL.delete_conc_program(
        l_temp_conc_short_name,
        l_temp_exe_name,
        l_bis_short_name,
        'SHORT')=false then
        null;
      end if;
    end if;*/
    if g_status=false then
      return false;
    end if;
  else
    --single thread
    if g_debug then
      write_to_log_file_n('Launch single thread');
    end if;
    if push_down_all_levels_single=false then
      return false;
    end if;
  end if;
  if drop_input_tables(l_input_table)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_job_status_table)=false then
    null;
  end if;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n('Error in push_down_all_levels_multi '||g_status_message);
 return false;
End;

/*
entry point for concurrent requests
*/
procedure PUSH_DOWN_ALL_LEVELS(
errbuf out nocopy varchar2,
retcode out nocopy varchar2,
p_dim_name varchar2,
p_log_file varchar2,
p_input_table varchar2,
p_job_id number,
p_ok_low_end number,
p_ok_high_end number,
p_job_status_table varchar2
) is
Begin
  retcode:='0';
  PUSH_DOWN_ALL_LEVELS(
  p_dim_name,
  p_log_file,
  p_input_table,
  p_job_id,
  p_ok_low_end,
  p_ok_high_end,
  p_job_status_table);
  if g_status=false then
    retcode:='2';
    errbuf:=g_status_message;
  end if;
Exception when others then
  errbuf:=sqlerrm;
  retcode:='2';
  write_to_log_file_n('Exception in PUSH_DOWN_ALL_LEVELS '||sqlerrm||get_time);
End;
/*
entry point for threads
*/
procedure PUSH_DOWN_ALL_LEVELS(
p_dim_name varchar2,
p_log_file varchar2,
p_input_table varchar2,
p_job_id number,
p_ok_low_end number,
p_ok_high_end number,
p_job_status_table varchar2
) is
Begin
  g_dim_name:=p_dim_name;
  g_log_file:=p_log_file;
  g_input_table:=p_input_table;
  g_job_id:=p_job_id;
  g_jobid_stmt:=' Job '||g_job_id||' ';
  EDW_OWB_COLLECTION_UTIL.init_all(g_log_file||'_'||g_job_id,null,'bis.edw.loader');
  if PUSH_DOWN_ALL_LEVELS(p_ok_low_end,p_ok_high_end)=false then
    if EDW_OWB_COLLECTION_UTIL.log_into_job_status_table(
      p_job_status_table,
      g_dim_name,
      g_job_id,
      'ERROR',
      g_status_message)=false then
      null;
    end if;
  else
    if EDW_OWB_COLLECTION_UTIL.log_into_job_status_table(
      p_job_status_table,
      g_dim_name,
      g_job_id,
      'SUCCESS',
      g_status_message)=false then
      null;
    end if;
  end if;
Exception when others then
 g_status_message:=sqlerrm;
 write_to_log_file_n('Error in PUSH_DOWN_ALL_LEVELS '||g_status_message);
End;

function PUSH_DOWN_ALL_LEVELS(
p_ok_low_end number,
p_ok_high_end number
) return boolean is
Begin
  if read_options_table(g_input_table)=false then
    return false;
  end if;
  EDW_OWB_COLLECTION_UTIL.set_debug(g_debug);
  EDW_OWB_COLLECTION_UTIL.set_parallel(g_parallel);
  EDW_OWB_COLLECTION_UTIL.set_g_read_cfig_options(g_read_cfig_options);
  if g_debug then
    write_to_log_file_n('In PUSH_DOWN_ALL_LEVELS, p_ok_low_end='||p_ok_low_end||',p_ok_high_end='||p_ok_high_end);
  end if;
  if set_session_parameters=false then
    return false;
  end if;  --alter session etc
  init_all(g_job_id);
  if find_lowest_level =false then
    write_to_log_file_n('find_lowest_level returned with error');
    return false;
  end if;
  if get_all_level_pk=false then
    write_to_log_file_n('get_all_level_pk returned with error');
    return false;
  end if;
  if get_level_prefix=false then
    write_to_log_file_n('get_level_prefix returned with error');
    return false;
  end if;
  if get_level_display_prefix=false then
    write_to_log_file_n('get_level_display_prefix returned with error');
    return false;
  end if;
  if get_level_seq=false then
    write_to_log_file_n('get_level_seq returned with error');
    return false;
  end if;
  if get_all_children_main=false then
    write_to_log_file_n('get_all_children_main returned with error');
    return false;
  end if;
  if find_diamond_levels=false then
    return false;
  end if;
  if create_ilog_from_main(p_ok_low_end,p_ok_high_end)=false then
    write_to_log_file_n('create_ilog_from_main returned with error');
    return false;
  end if;
  /*
  even we are multi thread here, we need to call push_down_all_levels_single
  */
  if push_down_all_levels_single=false then
    write_to_log_file_n('push_down_all_levels_single returned with error');
    return false;
  end if;
  /*if analyze_ltc_tables=false then
    write_to_log_file_n('analyze_ltc_tables returned with error');
    return false;
  end if;*/
  clean_up;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 write_to_log_file_n('Error in PUSH_DOWN_ALL_LEVELS '||g_status_message);
 return false;
End;

function get_level_prefix return boolean is
l_stmt varchar2(20000);
l_in_stmt varchar2(20000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_ltc  EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_prefix EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_ltc number;
Begin
  if g_debug then
    write_to_log_file_n('In get_level_prefix');
  end if;
  l_in_stmt:=null;
  for i in 1..g_number_levels loop
    if i=1 then
      l_in_stmt:=''''||substr(g_levels(i),1,instr(g_levels(i),'_LTC')-1)||'''';
    else
      l_in_stmt:=l_in_stmt||','''||substr(g_levels(i),1,instr(g_levels(i),'_LTC')-1)||'''';
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('The in stmt is '||l_in_stmt);
  end if;
  l_stmt:='select lvl.level_prefix, lvl.level_name||''_LTC'' from edw_levels_md_v lvl where lvl.level_name '||
  'in ('||l_in_stmt||')';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  l_number_ltc:=1;
  open cv for l_stmt;
  loop
    fetch cv into l_prefix(l_number_ltc),l_ltc(l_number_ltc);
    exit when cv%notfound;
    l_number_ltc:=l_number_ltc+1;
  end loop;
  close cv;
  l_number_ltc:=l_number_ltc-1;
  for i in 1..g_number_levels loop
    g_level_prefix(i):=null;
  end loop;
  for i in 1..g_number_levels loop
    for j in 1..l_number_ltc loop
      if g_levels(i)=l_ltc(j) then
        g_level_prefix(i):=l_prefix(j);
        exit;
      end if;
    end loop;
  end loop;
  if g_debug then
    write_to_log_file_n('The final list of PREFIX and LTC');
    for i in 1..g_number_levels loop
      write_to_log_file(g_level_prefix(i)||'  '||g_levels(i));
    end loop;
  end if;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function get_level_display_prefix return boolean is
l_stmt varchar2(20000);
l_in_stmt varchar2(20000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_meaning  EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_code EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_ltc number;
Begin
  if g_debug then
    write_to_log_file_n('In get_level_display_prefix');
  end if;
  for i in 1..g_number_levels loop
    g_level_display_prefix(i):=null;
  end loop;
  l_in_stmt:=null;
  for i in 1..g_number_levels loop
    if i=1 then
      l_in_stmt:=l_in_stmt||''''||g_dim_name||'_'||g_level_prefix(i)||'''';
    else
      l_in_stmt:=l_in_stmt||','''||g_dim_name||'_'||g_level_prefix(i)||'''';
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('The in stmt is '||l_in_stmt);
  end if;
  l_stmt:='select lookup_code,meaning from FND_LOOKUP_VALUES_VL where lookup_type=''EDW_LEVEL_PUSH_DOWN'' '||
  ' and lookup_code in ('||l_in_stmt||')';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  l_number_ltc:=1;
  open cv for l_stmt;
  loop
    fetch cv into l_code(l_number_ltc),l_meaning(l_number_ltc);
    exit when cv%notfound;
    l_number_ltc:=l_number_ltc+1;
  end loop;
  close cv;
  l_number_ltc:=l_number_ltc-1;

  for i in 1..g_number_levels loop
    for j in 1..l_number_ltc loop
      if g_dim_name||'_'||g_level_prefix(i)=l_code(j) then
        g_level_display_prefix(i):=l_meaning(j);
        exit;
      end if;
    end loop;
  end loop;
  if g_debug then
    write_to_log_file_n('The final list of levels and meaning');
    for i in 1..g_number_levels loop
      write_to_log_file(g_levels(i)||'  '||g_level_display_prefix(i));
    end loop;
  end if;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function get_all_children_main return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In get_all_children_main');
  end if;
  for i in 1..g_number_levels loop
    if get_all_children(i)=false then
      write_to_log_file_n('get_all_children returned with error for '||g_levels(i));
      return false;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('The Final result');
    for i in 1..g_number_final loop
      write_to_log_file(g_final_levels(i)||' '||g_final_child_levels(i)||' '||g_final_next_parent(i)||' '||
        g_final_fk(i)||' '||g_final_next_pk(i)||' '||g_final_pk_value(i)||' '||g_final_pk_prefix(i));
    end loop;
  end if;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function get_all_children(p_index number) return boolean is
l_prefix varchar2(400);
l_pk varchar2(400);
Begin
  if g_debug then
    write_to_log_file_n('In get_all_children');
    write_to_log_file('p_index='||p_index);
    write_to_log_file('The level='||g_levels(p_index));
  end if;
  if g_child_level_number(p_index) > 0 then
    l_prefix:=g_level_prefix(p_index);
    l_pk:=g_level_pk(p_index);
    if get_all_children_rec(p_index,g_levels(p_index),l_prefix,l_pk)=false then
      write_to_log_file_n('get_all_children_rec returned with error for '||g_levels(p_index));
      return false;
    end if;
  end if;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function get_all_children_rec(p_index number, p_level varchar2,
                              p_prefix varchar2,p_pk varchar2) return boolean is
l_child_count number:=0;
l_index number;
l_found boolean;
Begin
  /*
  if g_debug then
    write_to_log_file_n('In get_all_children_rec');
    write_to_log_file('p_index='||p_index);
    write_to_log_file('p_level='||p_level);
    write_to_log_file('p_prefix='||p_prefix);
    write_to_log_file('p_pk='||p_pk);
  end if;*/
  /*--REMOVE---------------------------------
  g_count:=g_count+1;
  if g_count > 200 then
   return false;
  end if;
  -----------------------------------------*/
  if p_index > 1 then
    for i in 1..(p_index-1) loop
      l_child_count:=l_child_count+g_child_level_number(i);
    end loop;
  end if;
  if g_debug then
    write_to_log_file_n('l_child_count='||l_child_count);
  end if;
  for i in 1..g_child_level_number(p_index) loop
    --if level_child_found(p_level,g_child_levels(l_child_count+i)) = true then
      --return true;
    --end if;
    l_found:=false;
    for j in 1..g_number_final loop
      if g_final_levels(j)=p_level and g_final_child_levels(j)=g_child_levels(l_child_count+i)
        and g_final_fk(j)=g_child_fk(l_child_count+i) and g_final_next_pk(j)=g_parent_pk(l_child_count+i) then
        l_found:=true;
        exit;
      end if;
    end loop;
    if l_found=false then
      g_number_final:=g_number_final+1;
      g_final_levels(g_number_final):=p_level;--main parent
      g_final_child_levels(g_number_final):=g_child_levels(l_child_count+i);
      g_final_next_parent(g_number_final):=g_levels(p_index);--immediate parent
      g_final_fk(g_number_final):=g_child_fk(l_child_count+i);
      g_final_next_pk(g_number_final):=g_parent_pk(l_child_count+i);
      g_final_pk_value(g_number_final):=p_pk;
      g_final_pk_prefix(g_number_final):=p_prefix; --only if FNP=FL this is needed
      if g_levels(p_index) = p_level then
        g_final_fk_prefix(g_number_final):=null;
      else
        g_final_fk_prefix(g_number_final):=p_prefix;
      end if;
    end if;
  end loop;
  for i in 1..g_child_level_number(p_index) loop
    l_index:=get_level_index(g_child_levels(l_child_count+i));
    if g_child_level_number(l_index) > 0 then
      if get_all_children_rec(l_index,p_level,p_prefix,p_pk)=false then
        write_to_log_file_n('get_all_children_rec returned with false for '||l_index||' '||
           p_level||' '||p_prefix);
        return false;
      end if;
    end if;
  end loop;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function level_child_found(p_level varchar2, p_child_level varchar2) return boolean is
Begin
  /*
  if g_debug then
    write_to_log_file_n('In level_child_found');
    write_to_log_file('p_level='||p_level);
    write_to_log_file('p_child_level='||p_child_level);
  end if;*/
  for i in 1..g_number_final loop
    if g_final_levels(i)=p_level and g_final_child_levels(i)=p_child_level then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function get_level_index(p_level varchar2) return number is
Begin
  if g_debug then
    write_to_log_file_n('In get_level_index, p_level='||p_level);
  end if;
  for i in 1..g_number_levels loop
    if g_levels(i)=p_level then
      return i;
    end if;
  end loop;
  return null;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return null;
End;

function get_all_level_pk return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In get_all_level_pk');
  end if;
  for i in 1..g_number_levels loop
    if g_levels(i) = g_lowest_level then
      if EDW_OWB_COLLECTION_UTIL.get_table_surr_pk(g_lowest_level,g_level_pk(i))=false then
        write_to_log_file_n('EDW_OWB_COLLECTION_UTIL.get_table_surr_pk returned with error');
        return false;
      end if;
    else
      g_level_pk(i):=get_ltc_pk(g_levels(i));
    end if;
  end loop;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function get_ltc_pk(p_level varchar2) return varchar2 is
Begin
  if g_debug then
    write_to_log_file_n('In get_ltc_pk, p_level='||p_level);
  end if;
  return get_ltc_pk(get_level_index(p_level));
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return null;
End;


function get_ltc_pk(p_index number) return varchar2 is
l_child_count number:=0;
Begin
  if g_debug then
    write_to_log_file_n('In get_ltc_pk, p_index='||p_index);
  end if;
  if p_index > 1 then
    for i in 1..(p_index-1) loop
      l_child_count:=l_child_count+g_child_level_number(i);
    end loop;
  end if;
  if g_debug then
    write_to_log_file_n('l_child_count+1='||(l_child_count+1));
  end if;
  return g_parent_pk(l_child_count+1);
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return null;
End;

function push_down_all_levels_single return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In push_down_all_levels_single');
  end if;
  for i in 1..(g_number_levels-1) loop --no need to push down the lowest level
    if g_level_consider(get_index_for_level(g_level_order(i))) then
      g_level_id:=EDW_OWB_COLLECTION_UTIL.get_object_id(g_level_order(i));
      if g_level_id=-1 then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        return false;
      end if;
      insert_into_load_progress_d(g_load_pk,g_level_order(i),'Push Down Level '||g_jobid_stmt,sysdate,null,'LEVEL',
      'LEVEL-PUSH-DOWN','LPD'||i||g_jobid_stmt,'I');
      if push_down_level(g_level_order(i))=false then
        write_to_log_file_n('push_down_level returned with error for '||g_level_order(i));
        insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'LPD'||i||g_jobid_stmt,'U');
        return false;
      end if;
      insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'LPD'||i||g_jobid_stmt,'U');
    else
      if g_debug then
        write_to_log_file_n('Level '||g_level_order(i)||' has no incremental data');
      end if;
    end if;
  end loop;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n('Error in push_down_all_levels_single '||g_status_message);
 return false;
End;

function push_down_level(p_level varchar2) return boolean is
l_status number;
l_index number;
Begin
  if g_debug then
    write_to_log_file_n('In push_down_level');
    write_to_log_file('The level to push down '||p_level);
  end if;
  l_index:=get_index_for_level(p_level);
  if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_level_ilog(l_index))=2 then
    if make_sql_stmts(p_level)=false then --also executes them
      write_to_log_file_n('make_sql_stmts returned with error');
      return false;
    end if;
  else
    if g_debug then
      write_to_log_file_n('ILOG '||g_level_ilog(l_index)||' has no data '||get_time);
    end if;
  end if;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function execute_update_stmt(p_update_stmt varchar2,p_update_stmt_row varchar2,p_update_rowid_table varchar2)
return boolean is
l_stmt varchar2(5000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_rowid EDW_OWB_COLLECTION_UTIL.rowidTableType;
l_count number;
l_total_count number:=0;
l_update_type varchar2(400);
Begin
  if g_debug then
    write_to_log_file_n('In execute_update_stmt '||get_time);
  end if;
  l_update_type:=g_update_type;
  <<start_update>>
  if l_update_type='ROW-BY-ROW' then
    l_stmt:='select row_id from '||p_update_rowid_table;
    if g_debug then
      write_to_log_file_n('Goint to execute '||l_stmt);
    end if;
    l_count:=1;
    open cv for l_stmt;
    loop
      fetch cv into l_rowid(l_count);
      exit when cv%notfound;
      if l_count>=g_forall_size then
        for i in 1..l_count loop
          execute immediate p_update_stmt_row using l_rowid(i),l_rowid(i);
        end loop;
        l_total_count:=l_total_count+l_count;
        l_count:=1;
      else
        l_count:=l_count+1;
      end if;
    end loop;
    close cv;
    l_count:=l_count-1;
    if l_count>0 then
      for i in 1..l_count loop
        execute immediate p_update_stmt_row using l_rowid(i),l_rowid(i);
      end loop;
      l_total_count:=l_total_count+l_count;
    end if;
  elsif l_update_type='MASS' then
    EDW_OWB_COLLECTION_UTIL.alter_session('NO-PARALLEL');
    begin
      EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
      execute immediate p_update_stmt;
      l_total_count:=sql%rowcount;
      if g_parallel is not null then
        EDW_OWB_COLLECTION_UTIL.alter_session('PARALLEL');
      end if;
    exception when others then
      if sqlcode=-4030 then
        commit;
        write_to_log_file_n('Memory issue with Mass Update. Retrying using ROW_BY_ROW');
        l_update_type:='ROW-BY-ROW';
        goto start_update;
      end if;
      g_status_message:=sqlerrm;
      write_to_log_file_n(g_status_message);
      write_to_log_file('Problem stmt '||p_update_stmt);
      if g_parallel is not null then
        EDW_OWB_COLLECTION_UTIL.alter_session('PARALLEL');
      end if;
      return false;
    end ;
  end if;
  commit;
  if g_debug then
    write_to_log_file_n('Number of rows updated '||l_total_count||get_time);
  end if;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function make_sql_stmts(p_level varchar2) return boolean is
l_child_level EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_child_level number;
l_parent_index number;
l_level_ilog varchar2(200);
l_status number;
Begin
  if g_debug then
    write_to_log_file_n('In make_sql_stmts(p_level)');
    write_to_log_file('P_level is '||p_level);
  end if;
  l_parent_index:=get_index_for_level(p_level);
  loop
    if g_skip_ilog_update(l_parent_index)=false then
      l_status:=set_gilog_status(g_level_ilog(l_parent_index),l_parent_index);
    else
      l_status:=2;
      g_skip_ilog_update(l_parent_index):=false;
    end if;
    if l_status=0 then --error
      write_to_log_file_n('ERROR set_gilog_status returned with status 0');
      g_status:=false;
      return false;
    elsif l_status=1 then
      exit;
    else
      l_level_ilog:=g_level_ilog(l_parent_index)||'T';
      if create_ilog_copy(g_level_ilog(l_parent_index),l_level_ilog)=false then
        return false;
      end if;
      l_number_child_level:=0;
      for i in 1..g_number_levels loop
        if g_level_order(i)<>p_level then
          for j in 1..g_number_final loop
            if g_final_levels(j)=p_level and g_final_child_levels(j)=g_level_order(i) then
              if EDW_OWB_COLLECTION_UTIL.value_in_table(l_child_level,l_number_child_level,g_level_order(i))=false then
                l_number_child_level:=l_number_child_level+1;
                l_child_level(l_number_child_level):=g_level_order(i);
                if make_and_exec_sql_stmts(p_level,g_level_order(i),l_level_ilog)=false then
                  return false;
                end if;
              else
                if g_debug then
                  write_to_log_file_n('Level '||p_level||' already pushed down to '||g_level_order(i));
                end if;
              end if;
            end if;
          end loop;
        end if;
      end loop;
      if g_type_ilog_generation='UPDATE' then
        if update_gilog(g_level_ilog(l_parent_index))=false then
          write_to_log_file_n('Error in update_gilog');
          return false;
        end if;
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_level_ilog)=false then
        null;
      end if;
    end if;
  end loop;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function make_and_exec_sql_stmts(p_parent_level varchar2,p_child_level varchar2,p_ilog varchar2) return boolean is
l_parent_index number;
l_child_index number;
l_number_final number;
l_final EDW_OWB_COLLECTION_UTIL.numberTableType;
l_level_copy EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_level_copy number;
l_level_copy_index EDW_OWB_COLLECTION_UTIL.numberTableType;
l_final_index EDW_OWB_COLLECTION_UTIL.numberTableType;
l_index number;
l_stmt varchar2(30000);
l_table varchar2(200);
l_pk varchar2(200);
l_user_pk varchar2(200);
l_parent_pk varchar2(200);
l_parent_user_pk varchar2(200);
l_opcode_table varchar2(200);
l_update_stmt varchar2(32000);
l_update_stmt_row varchar2(32000);
l_insert_stmt varchar2(32000);
l_other_fks EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_other_fks number;
l_other_fks_hold EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_other_fks_hold number;
l_found boolean;
l_diamond_fk_table varchar2(400):=null;
l_below_diamond_flag EDW_OWB_COLLECTION_UTIL.booleanTableType;
l_parent_level_count number;
l_ilog_count number;
l_use_nl boolean;
Begin
  if g_debug then
    write_to_log_file_n('In make_and_exec_sql_stmts parent='||p_parent_level||',child='||p_child_level||
    ',p_ilog='||p_ilog);
  end if;
  l_parent_index:=get_index_for_level(p_parent_level);
  l_child_index:=get_index_for_level(p_child_level);
  l_number_final:=0;
  for i in 1..g_number_final loop
    if g_final_levels(i)=p_parent_level and g_final_child_levels(i)=p_child_level then
      l_number_final:=l_number_final+1;
      l_final(l_number_final):=i;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('The indexes ');
    for i in 1..l_number_final loop
      write_to_log_file(l_final(i));
    end loop;
  end if;
  l_number_level_copy:=0;--for all the levels that are not parent or child create copies
  for i in 1..l_number_final loop
    l_index:=l_final(i);
    if g_final_next_parent(l_index)<>p_parent_level then
      if EDW_OWB_COLLECTION_UTIL.value_in_table(l_level_copy,l_number_level_copy,g_final_next_parent(l_index))=false then
        l_number_level_copy:=l_number_level_copy+1;
        l_level_copy(l_number_level_copy):=g_final_next_parent(l_index);
        l_level_copy_index(l_number_level_copy):=get_index_for_level(g_final_next_parent(l_index));
        l_final_index(l_number_level_copy):=l_final(i);
      end if;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('The other levels for whom copies are going to be made ');
    for i in 1..l_number_level_copy loop
      write_to_log_file(l_level_copy(i)||'('||l_level_copy_index(i)||')');
    end loop;
  end if;
  --make the level copies
  if l_number_level_copy>0 then
    for i in 1..l_number_level_copy loop
      l_index:=l_final_index(i);
      l_stmt:='create table '||g_ltc_copy(l_level_copy_index(i))||' tablespace '||g_op_table_space;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      if l_parent_level_count is null then
        l_parent_level_count:=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(p_parent_level,g_table_owner);
      end if;
      if l_ilog_count is null then
        l_ilog_count:=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(p_ilog,g_bis_owner);
      end if;
      l_use_nl:=EDW_OWB_COLLECTION_UTIL.get_join_nl(l_ilog_count,l_parent_level_count,g_join_nl_percentage);
      l_stmt:=l_stmt||' as select /*+ordered ';
      if l_use_nl then
        l_stmt:=l_stmt||'use_nl(A)';
      end if;
      l_stmt:=l_stmt||'*/ ';
      if g_parallel is not null then
        l_stmt:=l_stmt||' /*+parallel(A,'||g_parallel||') (B,'||g_parallel||')*/ ';
      end if;
      l_stmt:=l_stmt||'B.'||g_final_next_pk(l_index)||',B.'||get_user_key(g_final_next_pk(l_index))||
      ',A.rowid row_id from '||p_ilog||','||p_parent_level||' A,'||l_level_copy(i)||' B where '||
      'A.'||get_user_key(g_final_pk_value(l_index))||'||''-'||g_final_pk_prefix(l_index)||'''=B.'||
      get_user_key(g_final_next_pk(l_index))||' and '||p_ilog||'.row_id=A.rowid';
      if EDW_OWB_COLLECTION_UTIL.drop_table(g_ltc_copy(l_level_copy_index(i)))=false then
        null;
      end if;
      if g_debug then
        write_to_log_file_n('Going to execute '||l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
      end if;
      l_table:=g_ltc_copy(l_level_copy_index(i));
      EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_table,instr(l_table,'.')+1,
      length(l_table)),substr(l_table,1,instr(l_table,'.')-1));
    end loop;
  else
    write_to_log_file_n('There are no other levels to make copies of');
  end if;
  l_number_other_fks:=0;
  l_number_other_fks_hold:=0;
  --if get_fks_without_fk(p_child_level,null,l_other_fks_hold,l_number_other_fks_hold)=false then
    --return false;
  --end if;
  l_number_other_fks_hold:=0;
  if EDW_OWB_COLLECTION_UTIL.get_fks_for_table(p_child_level,l_other_fks_hold,l_number_other_fks_hold)=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    g_status:=false;
    return false;
  end if;
  if g_debug then
    write_to_log_file_n('ALL the fks');
    for i in 1..l_number_other_fks_hold loop
      write_to_log_file(l_other_fks_hold(i));
    end loop;
  end if;
  for i in 1..l_number_other_fks_hold loop
    l_found:=false;
    for j in 1..l_number_final loop
      if l_other_fks_hold(i)=g_final_fk(l_final(j)) then
        l_found:=true;
        exit;
      end if;
    end loop;
    if l_found=false then
      l_number_other_fks:=l_number_other_fks+1;
      l_other_fks(l_number_other_fks):=l_other_fks_hold(i);
    end if;
  end loop;
  for i in 1..l_number_other_fks loop
    l_below_diamond_flag(i):=false;
  end loop;
  if g_debug then
    write_to_log_file_n('ALL the OTHER fks');
    for i in 1..l_number_other_fks loop
      write_to_log_file(l_other_fks(i));
    end loop;
  end if;
  /*
  find out diamond keys and create tables to take care of the issue
  */
  if g_number_diamond_level>0 then
    declare
      l_diamond_tops EDW_OWB_COLLECTION_UTIL.varcharTableType;
      l_number_diamond_tops number:=0;
      l_other_fk_level EDW_OWB_COLLECTION_UTIL.varcharTableType;
      l_parent_level_order EDW_OWB_COLLECTION_UTIL.varcharTableType;
      l_child_level_order EDW_OWB_COLLECTION_UTIL.varcharTableType;
      l_parent_pk_order EDW_OWB_COLLECTION_UTIL.varcharTableType;
      l_child_fk_order EDW_OWB_COLLECTION_UTIL.varcharTableType;
      l_number_level_order number;
    begin
      --see if the parent is in a hier that belongs to diamond
      if get_diamond_tops(p_parent_level,l_diamond_tops,l_number_diamond_tops)=false then
        return false;
      end if;
      if l_number_diamond_tops>0 then
        --check all the other fks to get the other levels
        for i in 1..l_number_other_fks loop
          l_other_fk_level(i):=get_level_for_fk(p_child_level,l_other_fks(i));
          if l_other_fk_level(i) is null then
            return false;
          end if;
        end loop;
        if g_debug then
          write_to_log_file_n('The fks and levels');
          for i in 1..l_number_other_fks loop
            write_to_log_file(l_other_fks(i)||'('||l_other_fk_level(i)||')');
          end loop;
        end if;
        --see if these levels are below the diamond tops
        for i in 1..l_number_diamond_tops loop
          for j in 1..l_number_other_fks loop
            if is_below_diamond_top(l_other_fk_level(j),l_diamond_tops(i)) then
              l_below_diamond_flag(j):=true;
            end if;
          end loop;
        end loop;
        if g_debug then
          write_to_log_file_n('The levels below and not below diamonds');
          for i in 1..l_number_other_fks loop
            if l_below_diamond_flag(i) then
              write_to_log_file(l_other_fk_level(i)||' below diamond');
            else
              write_to_log_file(l_other_fk_level(i)||' NOT below diamond');
            end if;
          end loop;
        end if;
        l_found:=false;
        for i in 1..l_number_other_fks loop
          if l_below_diamond_flag(i) then
            l_found:=true;
            exit;
          end if;
        end loop;
        if l_found then
          --from the parent,find the way to the child
          if get_way_to_child(p_parent_level,p_child_level,l_parent_level_order,l_child_level_order,
          l_parent_pk_order,l_child_fk_order,l_number_level_order)=false then
            return false;
          end if;
          if create_child_dia_fk_table(p_parent_level,p_child_level,l_parent_level_order,l_child_level_order,
            l_parent_pk_order,l_child_fk_order,l_number_level_order,p_ilog,l_other_fks,l_below_diamond_flag,
            l_number_other_fks,l_diamond_fk_table)=false then
            return false;
          end if;
        else
          if g_debug then
            write_to_log_file_n('There are no other levels that belong to a diamond top shared by '||p_parent_level);
          end if;
        end if;
      else
        if g_debug then
          write_to_log_file_n('This level '||p_parent_level||' is not a child of any diamond top');
        end if;
      end if;
    exception when others then
      g_status_message:=sqlerrm;
      g_status:=false;
      write_to_log_file_n(g_status_message);
      return false;
    end;
  end if;
  l_pk:=g_level_pk(l_child_index);
  l_user_pk:=get_user_key(l_pk);
  l_parent_pk:=g_level_pk(l_parent_index);
  l_parent_user_pk:=get_user_key(l_parent_pk);
  if g_level_full_insert(l_child_index) then
    --only insert
    if g_debug then
      write_to_log_file_n('Full Insert');
    end if;
    l_stmt:='insert into '||p_child_level||'('||l_user_pk||','||l_pk;
    for i in 1..l_number_final loop
      l_stmt:=l_stmt||','||g_final_fk(l_final(i));
    end loop;
    for i in 1..l_number_other_fks loop
      l_stmt:=l_stmt||','||l_other_fks(i);
    end loop;
    l_stmt:=l_stmt||',NAME,CREATION_DATE,LAST_UPDATE_DATE,PUSHED_DOWN_FLAG) select ';
    if g_parallel is not null then
      l_stmt:=l_stmt||' /*+parallel(A,'||g_parallel||')*/ ';
    end if;
    l_stmt:=l_stmt||'A.'||l_parent_user_pk||'||''-'||g_level_prefix(l_parent_index)||''''||
    ','||g_level_seq(l_child_index)||'.NEXTVAL';
    for i in 1..l_number_final loop
      if g_final_next_parent(l_final(i))=p_parent_level then
        l_stmt:=l_stmt||',A.'||g_final_pk_value(l_final(i));
      else
        l_index:=EDW_OWB_COLLECTION_UTIL.index_in_table(l_level_copy,l_number_level_copy,
        g_final_next_parent(l_final(i)));
        l_stmt:=l_stmt||','||g_ltc_copy(l_level_copy_index(l_index))||'.'||g_final_next_pk(l_final(i));
      end if;
    end loop;
    for i in 1..l_number_other_fks loop
      if l_below_diamond_flag(i) then
        l_stmt:=l_stmt||','||l_diamond_fk_table||'.'||l_other_fks(i);
      else
        l_stmt:=l_stmt||',0';--NA_EDW
      end if;
    end loop;
    l_stmt:=l_stmt||','''||g_level_display_prefix(l_child_index)||'(''||A.NAME||'')'',SYSDATE,SYSDATE,''Y'' from '||
    p_parent_level||' A ';
    for i in 1..l_number_level_copy loop
      l_stmt:=l_stmt||','||g_ltc_copy(l_level_copy_index(i));
    end loop;
    if l_diamond_fk_table is not null then
      l_stmt:=l_stmt||','||l_diamond_fk_table;
    end if;
    l_stmt:=l_stmt||','||p_ilog||' where '||p_ilog||'.row_id=A.rowid and ';
    for i in 1..l_number_level_copy loop
      l_stmt:=l_stmt||'A.rowid='||g_ltc_copy(l_level_copy_index(i))||'.row_id and ';
    end loop;
    if l_diamond_fk_table is not null then
      l_stmt:=l_stmt||'A.rowid='||l_diamond_fk_table||'.row_id and ';
    end if;
    l_stmt:=substr(l_stmt,1,length(l_stmt)-4);
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.alter_session('NO-PARALLEL');
    EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Inserted '||sql%rowcount||' rows '||get_time);
    end if;
    commit;
    if g_parallel is not null then
      EDW_OWB_COLLECTION_UTIL.alter_session('PARALLEL');
    end if;
  else
    --insert and update most of the time here
    l_opcode_table:=g_update_rowid(l_child_index)||'O';
    l_stmt:='create table '||l_opcode_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  as select ';
    if g_parallel is not null then
      l_stmt:=l_stmt||'/*+parallel(A,'||g_parallel||') (B,'||g_parallel||')*/ ';
    end if;
    l_stmt:=l_stmt||'A.rowid row_id,B.rowid row_id1,decode(B.rowid,null,0,1) status from '||
    p_ilog||','||p_parent_level||' A,'||p_child_level||' B where '||p_ilog||'.row_id=A.rowid '||
    'and A.'||l_parent_user_pk||'||''-'||g_level_prefix(l_parent_index)||'''=B.'||l_user_pk||'(+)';
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_opcode_table)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_opcode_table,instr(l_opcode_table,'.')+1,
    length(l_opcode_table)),substr(l_opcode_table,1,instr(l_opcode_table,'.')-1));
    if EDW_OWB_COLLECTION_UTIL.does_table_have_data(l_opcode_table,'status=1')=2 then
      if g_debug then
        write_to_log_file_n('Update needed for child level');
      end if;
      l_stmt:='create table '||g_update_rowid(l_child_index)||' tablespace '||g_op_table_space;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  as select ';
      if g_parallel is not null then
        l_stmt:=l_stmt||' /*+parallel(A,'||g_parallel||')*/ ';
      end if;
      l_stmt:=l_stmt||l_opcode_table||'.row_id1 row_id ';
      for i in 1..l_number_final loop
        if g_final_next_parent(l_final(i))=p_parent_level then
          l_stmt:=l_stmt||',A.'||g_final_pk_value(l_final(i))||' '||g_final_fk(l_final(i));
        else
          l_index:=EDW_OWB_COLLECTION_UTIL.index_in_table(l_level_copy,l_number_level_copy,
          g_final_next_parent(l_final(i)));
          l_stmt:=l_stmt||','||g_ltc_copy(l_level_copy_index(l_index))||'.'||g_final_next_pk(l_final(i))||' '||
          g_final_fk(l_final(i));
        end if;
      end loop;
      for i in 1..l_number_other_fks loop
        if l_below_diamond_flag(i) then
          l_stmt:=l_stmt||','||l_diamond_fk_table||'.'||l_other_fks(i);
        else
          l_stmt:=l_stmt||',0 '||l_other_fks(i);
        end if;
      end loop;
      l_stmt:=l_stmt||','''||g_level_display_prefix(l_child_index)||'(''||A.NAME||'')'' NAME '||
      ' from '||p_parent_level||' A ';
      for i in 1..l_number_level_copy loop
        l_stmt:=l_stmt||','||g_ltc_copy(l_level_copy_index(i));
      end loop;
      if l_diamond_fk_table is not null then
        l_stmt:=l_stmt||','||l_diamond_fk_table;
      end if;
      l_stmt:=l_stmt||','||l_opcode_table||' where '||l_opcode_table||'.row_id=A.rowid and '||
      l_opcode_table||'.status=1 and ';
      for i in 1..l_number_level_copy loop
        l_stmt:=l_stmt||'A.rowid='||g_ltc_copy(l_level_copy_index(i))||'.row_id and ';
      end loop;
      if l_diamond_fk_table is not null then
        l_stmt:=l_stmt||'A.rowid='||l_diamond_fk_table||'.row_id and ';
      end if;
      l_stmt:=substr(l_stmt,1,length(l_stmt)-4);
      if EDW_OWB_COLLECTION_UTIL.drop_table(g_update_rowid(l_child_index))=false then
        null;
      end if;
      if g_debug then
        write_to_log_file_n('Going to execute '||l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
      end if;
      l_stmt:='create unique index '||g_update_rowid(l_child_index)||'u on '||
      g_update_rowid(l_child_index)||'(row_id) tablespace '||g_op_table_space;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel '||g_parallel;
      end if;
      if g_debug then
        write_to_log_file_n('Going to execute '||l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      l_table:=g_update_rowid(l_child_index);
      EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_table,instr(l_table,'.')+1,
      length(l_table)),substr(l_table,1,instr(l_table,'.')-1));
      --call update
      l_update_stmt:='update /*+ORDERED USE_NL('||p_child_level||')*/ '||p_child_level||' set '||
      '(NAME,LAST_UPDATE_DATE,PUSHED_DOWN_FLAG';
      l_update_stmt_row:='update '||p_child_level||' set (NAME,LAST_UPDATE_DATE,PUSHED_DOWN_FLAG';
      for i in 1..l_number_final loop
        l_update_stmt:=l_update_stmt||','||g_final_fk(l_final(i));
        l_update_stmt_row:=l_update_stmt_row||','||g_final_fk(l_final(i));
      end loop;
      for i in 1..l_number_other_fks loop
        l_update_stmt:=l_update_stmt||','||l_other_fks(i);
        l_update_stmt_row:=l_update_stmt_row||','||l_other_fks(i);
      end loop;
      l_update_stmt:=l_update_stmt||')=(select NAME,SYSDATE,''Y''';
      l_update_stmt_row:=l_update_stmt_row||')=(select NAME,SYSDATE,''Y''';
      for i in 1..l_number_final loop
        l_update_stmt:=l_update_stmt||','||g_final_fk(l_final(i));
        l_update_stmt_row:=l_update_stmt_row||','||g_final_fk(l_final(i));
      end loop;
      for i in 1..l_number_other_fks loop
        l_update_stmt:=l_update_stmt||','||l_other_fks(i);
        l_update_stmt_row:=l_update_stmt_row||','||l_other_fks(i);
      end loop;
      l_update_stmt:=l_update_stmt||' from '||g_update_rowid(l_child_index)||' where '||
      g_update_rowid(l_child_index)||'.row_id='||p_child_level||'.rowid) where '||p_child_level||'.rowid in '||
      '(select row_id from '||g_update_rowid(l_child_index)||')';
      l_update_stmt_row:=l_update_stmt_row||' from '||g_update_rowid(l_child_index)||' where '||
      g_update_rowid(l_child_index)||'.row_id=:a) where '||p_child_level||'.rowid=:b';
      --execute update
      if g_debug then
        write_to_log_file_n('MASS Update stmt '||l_update_stmt);
        write_to_log_file_n('ROW-BY-ROW Update stmt '||l_update_stmt_row);
      end if;
      if execute_update_stmt(l_update_stmt,l_update_stmt_row,g_update_rowid(l_child_index))=false then
        return false;
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(g_update_rowid(l_child_index))=false then
        null;
      end if;
    end if;
    if EDW_OWB_COLLECTION_UTIL.does_table_have_data(l_opcode_table,'status=0')=2 then
      if g_debug then
        write_to_log_file_n('Insert needed for child level');
      end if;
      l_insert_stmt:='insert into '||p_child_level||'('||l_user_pk||','||l_pk;
      for i in 1..l_number_final loop
        l_insert_stmt:=l_insert_stmt||','||g_final_fk(l_final(i));
      end loop;
      for i in 1..l_number_other_fks loop
        l_insert_stmt:=l_insert_stmt||','||l_other_fks(i);
      end loop;
      l_insert_stmt:=l_insert_stmt||',NAME,CREATION_DATE,LAST_UPDATE_DATE,PUSHED_DOWN_FLAG) select ';
      if g_parallel is not null then
        l_insert_stmt:=l_insert_stmt||' /*+parallel(A,'||g_parallel||')*/ ';
      end if;
      l_insert_stmt:=l_insert_stmt||'A.'||l_parent_user_pk||'||''-'||g_level_prefix(l_parent_index)||''''||
      ','||g_level_seq(l_child_index)||'.NEXTVAL';
      for i in 1..l_number_final loop
        if g_final_next_parent(l_final(i))=p_parent_level then
          l_insert_stmt:=l_insert_stmt||',A.'||g_final_pk_value(l_final(i));
        else
          l_index:=EDW_OWB_COLLECTION_UTIL.index_in_table(l_level_copy,l_number_level_copy,
          g_final_next_parent(l_final(i)));
          l_insert_stmt:=l_insert_stmt||','||g_ltc_copy(l_level_copy_index(l_index))||'.'||g_final_next_pk(l_final(i));
        end if;
      end loop;
      for i in 1..l_number_other_fks loop
        if l_below_diamond_flag(i) then
          l_insert_stmt:=l_insert_stmt||','||l_diamond_fk_table||'.'||l_other_fks(i);
        else
          l_insert_stmt:=l_insert_stmt||',0 ';
        end if;
      end loop;
      l_insert_stmt:=l_insert_stmt||','''||g_level_display_prefix(l_child_index)||
      '(''||A.NAME||'')'',SYSDATE,SYSDATE,''Y'' from '||l_opcode_table||','||p_parent_level||' A ';
      for i in 1..l_number_level_copy loop
        l_insert_stmt:=l_insert_stmt||','||g_ltc_copy(l_level_copy_index(i));
      end loop;
      if l_diamond_fk_table is not null then
        l_insert_stmt:=l_insert_stmt||','||l_diamond_fk_table;
      end if;
      l_insert_stmt:=l_insert_stmt||' where '||l_opcode_table||'.row_id=A.rowid and '||
      l_opcode_table||'.status=0 and ';
      for i in 1..l_number_level_copy loop
        l_insert_stmt:=l_insert_stmt||'A.rowid='||g_ltc_copy(l_level_copy_index(i))||'.row_id and ';
      end loop;
      if l_diamond_fk_table is not null then
        l_insert_stmt:=l_insert_stmt||'A.rowid='||l_diamond_fk_table||'.row_id and ';
      end if;
      l_insert_stmt:=substr(l_insert_stmt,1,length(l_insert_stmt)-4);
      if g_debug then
        write_to_log_file_n('Going to execute Insert stmt '||l_insert_stmt||get_time);
      end if;
      EDW_OWB_COLLECTION_UTIL.alter_session('NO-PARALLEL');
      EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
      execute immediate l_insert_stmt;
      if g_debug then
        write_to_log_file_n('Inserted '||sql%rowcount||' rows '||get_time);
      end if;
      if g_parallel is not null then
        EDW_OWB_COLLECTION_UTIL.alter_session('PARALLEL');
      end if;
      commit;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_opcode_table)=false then
      null;
    end if;
  end if;
  if l_number_level_copy>0 then
    for i in 1..l_number_level_copy loop
      if EDW_OWB_COLLECTION_UTIL.drop_table(g_ltc_copy(l_level_copy_index(i)))=false then
        null;
      end if;
    end loop;
  end if;
  if l_diamond_fk_table is not null then
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_diamond_fk_table)=false then
      null;
    end if;
  end if;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function update_gilog(p_ilog varchar2) return boolean is
l_stmt varchar2(2000);
Begin
 if g_debug then
   write_to_log_file_n('In update_gilog for '||p_ilog||get_time);
 end if;
 l_stmt:='update '||p_ilog||' set status=2 where status=1';
 EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
 execute immediate l_stmt;
 commit;
 if g_debug then
   write_to_log_file_n('Updated '||sql%rowcount||' rows from 1 to 2 for '||p_ilog||get_time);
 end if;
 return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;
/*
 this function sets the status of the ilog from 0 to 1 and also deletes those that are 1 first
 returns:
 0: error
 1: no more records to change from 0 to 1
 2: success
*/
function set_gilog_status(p_ilog in out NOCOPY varchar2,p_index number) return number is
l_stmt varchar2(10000);
l_count number;
l_ilog varchar2(400);
l_ltc_pk varchar2(400);
Begin
  --update
  if g_debug then
    write_to_log_file_n('In set_gilog_status');
  end if;
  if g_type_ilog_generation='UPDATE' then
    if EDW_OWB_COLLECTION_UTIL.does_table_have_data(p_ilog,'status=1')=2 then
      return 2;
    end if;
    if g_collection_size =0 then
      l_stmt:='update '||p_ilog||' set status=1 where status=0';
    else
      l_stmt:='update '||p_ilog||' set status=1 where status=0 and rownum <='||g_collection_size;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
    execute immediate l_stmt;
    l_count:=sql%rowcount;
    commit;
    if g_debug then
      write_to_log_file_n('commit'||get_time);
    end if;
    if g_debug then
      write_to_log_file_n('Updated '||l_count||' rows in '||p_ilog||get_time);
    end if;
  elsif g_type_ilog_generation='CTAS' then
    l_ltc_pk:=g_level_pk(p_index);
    if substr(p_ilog,length(p_ilog),1)='A' then
      l_ilog:=substr(p_ilog,1,length(p_ilog)-1);
    else
      l_ilog:=p_ilog||'A';
    end if;
    l_stmt:='create table '||l_ilog||' tablespace '||g_op_table_space;
    l_stmt:=l_stmt||' storage (initial 4M next 4M pctincrease 0) ';
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    if g_collection_size > 0 then
      if g_snplog_has_pk(p_index) then
        l_stmt:=l_stmt||'  as select row_id,'||l_ltc_pk||',decode(status,1,2,2,2,decode(sign(rownum-'||
        g_collection_size||'),1,0,1)) status from (select row_id,'||l_ltc_pk||',status from '||p_ilog||
        ' order by status) abc ';
      else
        l_stmt:=l_stmt||'  as select row_id,decode(status,1,2,2,2,decode(sign(rownum-'||
        g_collection_size||'),1,0,1)) status from (select row_id,status from '||p_ilog||' order by status) abc ';
      end if;
    else
      if g_snplog_has_pk(p_index) then
        l_stmt:=l_stmt||'  as select row_id,'||l_ltc_pk||',decode(status,1,2,0,1,2) status from '||
        p_ilog;
      else
        l_stmt:=l_stmt||'  as select row_id,decode(status,1,2,0,1,2) status from '||
        p_ilog;
      end if;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_ilog)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(p_ilog)=false then
      null;
    end if;
    p_ilog:=l_ilog;
    if EDW_OWB_COLLECTION_UTIL.does_table_have_data(p_ilog,' status=1 ')<2 then
      l_count:=0;
    else
      l_count:=1;
    end if;
    if g_debug then
      write_to_log_file_n('Time '||get_time);
    end if;
  end if;
  if l_count=0 then
    return 1;
  else
    return 2;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return 0;
End;


function get_user_key(p_key varchar2) return varchar2 is
Begin
  return substr(p_key,1,instr(p_key,'_KEY')-1);
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return null;
End;

procedure init_all(p_job_id number) is
l_name varchar2(200);
l_name_org varchar2(200);
Begin
  g_number_final:=0;
  g_count:=0;
  /*
  the ilog and milog are dropped ONLY AFTER THE LTC SNAPSHOT LOGS have been TRUNCATED!!
  */
  if g_debug then
    write_to_log_file_n('In init_all p_job_id='||p_job_id);
  end if;
  for i in 1..g_number_levels loop
    g_level_ids(i):=EDW_OWB_COLLECTION_UTIL.get_object_id(g_levels(i));
    g_skip_ilog_update(i):=false;
    if p_job_id is null then
      l_name:='TAB_'||g_level_ids(i)||'_';
    else
      l_name:='TAB_'||g_level_ids(i)||'_'||p_job_id||'_';
    end if;
    l_name_org:='TAB_'||g_level_ids(i)||'_';
    g_level_ilog(i):=g_bis_owner||'.'||l_name||'IL';
    g_level_ilog_name(i):=g_level_ilog(i);
    if p_job_id is null then
      if EDW_OWB_COLLECTION_UTIL.check_table(g_level_ilog(i)||'A') then
        g_level_ilog(i):=g_level_ilog(i)||'A';
      end if;
    end if;
    g_level_ilog_found(i):=false;
    g_insert_rowid(i):=g_bis_owner||'.'||l_name||'IR';
    g_update_rowid(i):=g_bis_owner||'.'||l_name||'UR';
    g_snplog_has_pk(i):=false;
    g_analyze_needed(i):=false;
    g_ltc_copy(i):=g_bis_owner||'.'||l_name||'LC';
  end loop;
  g_type_ilog_generation:='CTAS';
  g_number_diamond_level:=0;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
End;

function get_time return varchar2 is
begin
  return ' '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS');
Exception when others then
  write_to_log_file_n('Error in get_time '||sqlerrm);
End;

procedure write_to_log_file(p_message varchar2) is
begin
 EDW_OWB_COLLECTION_UTIL.write_to_log_file(p_message);
Exception when others then
 null;
End;

procedure write_to_log_file_n(p_message varchar2) is
begin
 write_to_log_file('   ');
 write_to_log_file(p_message);
Exception when others then
 null;
End;

function does_snp_have_data(p_level varchar2) return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In does_snp_have_data, p_level is '||p_level);
  end if;
  for i in 1..g_number_levels loop
    if g_levels(i)=p_level then
      if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_level_snapshot_logs(i))=2 then
        return true;
      else
        return false;
      end if;
      exit;
    end if;
  end loop;
  return false;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function get_level_snplog(p_level varchar2) return varchar2 is
Begin
  if g_debug then
    write_to_log_file_n('In get_level_snplog, p_level='||p_level);
  end if;
  for i in 1..g_number_levels loop
    if g_levels(i)=p_level then
      return g_level_snapshot_logs(i);
    end if;
  end loop;
  return null;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return null;
End;

function check_levels_for_data return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In check_levels_for_data');
  end if;
  if g_full_refresh then
    for i in 1..g_number_levels loop
      if g_level_consider(i) then --this may be false if the user does not want this level pushed down
        if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_levels(i))=2 then
          g_level_consider(i):=true;
        else
          g_level_consider(i):=false;
        end if;
      end if;
    end loop;
  else
    for i in 1..g_number_levels loop
      if g_level_consider(i) then
        if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_level_snapshot_logs(i))=2 then
          g_level_consider(i):=true;
        else
          g_level_consider(i):=false;
        end if;
      end if;
    end loop;
  end if;
  /*is this reqd ? will a ltc table have only 2 rows?
  */
  for i in 1..g_number_levels loop
    g_level_full_insert(i):=false;--default
    if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_levels(i))=1 then
      g_level_full_insert(i):=true;
      if g_debug then
        write_to_log_file_n('Level '||g_levels(i)||' Empty');
      end if;
    elsif EDW_OWB_COLLECTION_UTIL.does_table_have_only_n_row(g_levels(i),2)=2
       and (EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_levels(i),g_level_pk(i)||'=0')=2
       and EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_levels(i),g_level_pk(i)||'=-1')=2) then
      g_level_full_insert(i):=true;
      if g_debug then
        write_to_log_file_n('Level '||g_levels(i)||' only has NA_EDW and NA_ERR rows');
      end if;
    end if;
  end loop;
  if g_debug then
    for i in 1..g_number_levels loop
      if g_level_consider(i) then
        write_to_log_file_n('Push down implemented for     '||g_levels(i));
      else
        write_to_log_file_n('Push down NOT implemented for '||g_levels(i));
      end if;
    end loop;
  end if;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function get_index_for_level(p_level varchar2) return number is
Begin
  if g_debug then
    write_to_log_file_n('In get_index_for_level, plevel is '||p_level);
  end if;
  for i in 1..g_number_levels loop
    if g_levels(i)=p_level then
      return i;
    end if;
  end loop;
  return null;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return null;
End;

function get_fks_without_fk(p_level varchar2, p_fk varchar2,
    p_fks_out out NOCOPY  EDW_OWB_COLLECTION_UTIL.varcharTableType,p_number_fks_out out NOCOPY number) return boolean is
l_count number;
Begin
  if g_debug then
    write_to_log_file_n('In get_fks_without_fk');
    write_to_log_file('p_level='||p_level);
    write_to_log_file('p_fk='||p_fk);
  end if;
  p_number_fks_out:=0;
  l_count:=0;
  for i in 1..g_number_levels loop
    l_count:=l_count+g_child_level_number(i);
  end loop;
  for i in 1..l_count loop
    if g_child_levels(i)=p_level then
      p_number_fks_out:=p_number_fks_out+1;
      p_fks_out(p_number_fks_out):=g_child_fk(i);
    end if;
  end loop;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function get_level_seq return boolean is
l_stmt varchar2(10000);
l_in_stmt varchar2(10000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_level EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_seq EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_level number;
Begin
  if g_debug then
    write_to_log_file_n('In get_level_seq');
  end if;
  l_in_stmt:=null;
  for i in 1..g_number_levels loop
    if i=1 then
      l_in_stmt:=l_in_stmt||''''||g_levels(i)||'''';
    else
      l_in_stmt:=l_in_stmt||','''||g_levels(i)||'''';
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('In stmt='||l_in_stmt);
  end if;
  --not checked
  l_stmt:='select seq.sequence_name, rel.name from edw_tables_md_v rel, edw_pvt_sequences_md_v seq, '||
  'edw_pvt_map_properties_md_v map, edw_pvt_map_sources_md_v ru where rel.name in ('||l_in_stmt||') '||
  'and map.primary_target=rel.elementid and ru.mapping_id=map.mapping_id '||
  'and ru.source_id=seq.sequence_id  ';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  l_number_level:=1;
  begin
    open cv for l_stmt;
    loop
      fetch cv into l_seq(l_number_level),l_level(l_number_level);
      exit when cv%notfound;
      l_number_level:=l_number_level+1;
    end loop;
    l_number_level:=l_number_level-1;
    close cv;
  exception when others then
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message);
    write_to_log_file('Problem stmt '||l_stmt);
  end;
  /*
  if g_debug then
    write_to_log_file_n('Results');
    for i in 1..l_number_level loop
      write_to_log_file(l_level(i)||'('||l_seq(i)||')');
    end loop;
  end if;*/
  for i in 1..g_number_levels loop
    g_level_seq(i):=null;
  end loop;
  for i in 1..g_number_levels loop
    for j in 1..l_number_level loop
      if g_levels(i)=l_level(j) then
        g_level_seq(i):=l_seq(j);
        exit;
      end if;
    end loop;
  end loop;
  if g_debug then
    write_to_log_file_n('Results');
    for i in 1..g_number_levels loop
      write_to_log_file(g_levels(i)||'('||g_level_seq(i)||')');
    end loop;
  end if;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function find_lowest_level return boolean is
l_found boolean;
l_stmt varchar2(4000);
Begin
  if g_debug then
    write_to_log_file_n('In find_lowest_level');
  end if;
  g_lowest_level:=g_level_order(g_number_levels);
  /*
  for i in 1..g_number_levels loop
    if g_child_level_number(i)=0 then
      g_lowest_level:=g_levels(i);
      exit;
    end if;
  end loop;
  */
  if g_debug then
    write_to_log_file_n('The lowest level is '||g_lowest_level);
  end if;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

procedure clean_up is
Begin
  if g_debug then
    write_to_log_file_n('In clean_up');
  end if;
  for i in 1..g_number_levels loop
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_update_rowid(i))=false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_insert_rowid(i))=false then
      null;
    end if;
  end loop;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
End;

function create_ilog_tables return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In create_ilog_tables');
  end if;
  for i in 1..(g_number_levels-1) loop
    if create_ilog_tables(i)=false then
      write_to_log_file_n('create_ilog_tables returned with error for '||g_level_order(i));
    end if;
  end loop;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function create_ilog_tables(p_index number) return boolean is
l_stmt varchar2(10000);
l_index number;
Begin
  if g_debug then
    write_to_log_file_n('In create_ilog_tables('||p_index||')');
  end if;
  l_index:=get_index_for_level(g_level_order(p_index));
  if EDW_OWB_COLLECTION_UTIL.is_column_in_table(g_level_snapshot_logs(l_index),g_level_pk(l_index),
  g_table_owner) then
    g_snplog_has_pk(l_index):=true;
  end if;
  if EDW_OWB_COLLECTION_UTIL.check_table(g_level_ilog(l_index))=false then
    l_stmt:='create table '||g_level_ilog(l_index)||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  as select chartorowid(M_ROW$$) row_id ';
    if g_snplog_has_pk(l_index) then
      l_stmt:=l_stmt||','||g_level_pk(l_index);
    end if;
    l_stmt:=l_stmt||',0 status from '||g_level_snapshot_logs(l_index)||' where 1=2';
    if EDW_OWB_COLLECTION_UTIL.execute_stmt(l_stmt)=false then
      g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
      g_status:=false;
      write_to_log_file_n(g_status_message);
      return false;
    end if;
  else
    g_level_ilog_found(l_index):=true;
  end if;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;


function move_data_into_ilog return boolean is
l_index number;
Begin
  if g_debug then
    write_to_log_file_n('In move_data_into_ilog');
  end if;
  for i in 1..g_number_levels loop
    l_index:=get_index_for_level(g_level_order(i));
    if g_debug then
      if g_level_consider(l_index) and g_levels(l_index)<>g_lowest_level then
        write_to_log_file_n('for level '||g_levels(l_index)||' move_data_into_ilog');
      else
        write_to_log_file_n('for level '||g_levels(l_index)||' NO move_data_into_ilog');
      end if;
    end if;
    if g_level_consider(l_index) and g_levels(l_index)<>g_lowest_level then
      if move_data_into_ilog(i)=false then
        write_to_log_file_n('move_data_into_ilog returned with error for '||g_level_order(i));
        return false;
      end if;
    end if;
  end loop;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function move_data_into_ilog(p_index number) return boolean is
l_stmt varchar2(10000);
l_index number;
l_ilog varchar2(400);
l_level_ilogm_el varchar2(400);
l_level_ilog_el varchar2(400);
l_level_count number;
l_ilog_count number;
l_use_nl boolean;
Begin
  if g_debug then
    write_to_log_file_n('In move_data_into_ilog(int), pindex='||p_index);
  end if;
  l_index:=get_index_for_level(g_level_order(p_index));
  if g_level_ilog_found(l_index)=false then
    if g_full_refresh then
      if g_snplog_has_pk(l_index) then
        l_stmt:='insert into '||g_level_ilog(l_index)||'(row_id,'||g_level_pk(l_index)||',status) select ';
        if g_parallel  is not null then
          l_stmt:=l_stmt||' /*+PARALLEL ('||g_levels(l_index)||','||g_parallel||')*/ ';
        end if;
        l_stmt:=l_stmt||' rowid,'||g_level_pk(l_index)||',0 from '||g_levels(l_index);
      else
        l_stmt:='insert into '||g_level_ilog(l_index)||'(row_id, status) select ';
        if g_parallel  is not null then
          l_stmt:=l_stmt||' /*+PARALLEL ('||g_levels(l_index)||','||g_parallel||')*/ ';
        end if;
        l_stmt:=l_stmt||' rowid,0 from '||g_levels(l_index);
      end if;
      l_stmt:=l_stmt||' where PUSHED_DOWN_FLAG is null';
    else
      if g_snplog_has_pk(l_index) then
        l_stmt:='insert into '||g_level_ilog(l_index)||'(row_id,'||g_level_pk(l_index)||',status) select ';
        if g_parallel  is not null then
          l_stmt:=l_stmt||' /*+PARALLEL ('||g_level_snapshot_logs(l_index)||','||g_parallel||')*/ ';
        end if;
        l_stmt:=l_stmt||' distinct chartorowid(M_ROW$$),'||g_level_snapshot_logs(l_index)||'.'||g_level_pk(l_index)||
        ',0 from '||g_level_snapshot_logs(l_index);
      else
        l_stmt:='insert into '||g_level_ilog(l_index)||'(row_id, status) select ';
        if g_parallel  is not null then
          l_stmt:=l_stmt||' /*+PARALLEL ('||g_level_snapshot_logs(l_index)||','||g_parallel||')*/ ';
        end if;
        l_stmt:=l_stmt||' distinct chartorowid(M_ROW$$),0 from '||g_level_snapshot_logs(l_index);
      end if;
      l_stmt:=l_stmt||','||g_levels(l_index)||' where '||g_levels(l_index)||'.rowid='||
      g_level_snapshot_logs(l_index)||'.M_ROW$$ and '||g_levels(l_index)||'.PUSHED_DOWN_FLAG is null';
    end if;
    EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
    if EDW_OWB_COLLECTION_UTIL.execute_stmt(l_stmt)=false then
      g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
      g_status:=false;
      write_to_log_file_n(g_status_message);
      return false;
    end if;
    commit;
  else --table already there...part of error recovery
    --recreate g_level_ilog
    --recover g_level_ilog
    if substr(g_level_ilog(l_index),length(g_level_ilog(l_index)),1)='A' then
      l_level_ilog_el:=substr(g_level_ilog(l_index),1,length(g_level_ilog(l_index))-1);
    else
      l_level_ilog_el:=g_level_ilog(l_index)||'A';
    end if;
    l_stmt:='create table '||l_level_ilog_el||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    if g_snplog_has_pk(l_index) then
      l_stmt:=l_stmt||'  as select /*+ordered*/ A.rowid row_id';
      l_stmt:=l_stmt||',A.'||g_level_pk(l_index)||',B.status';
      l_stmt:=l_stmt||' from '||g_level_ilog(l_index)||' B,'||g_levels(l_index)||
      ' A where A.'||g_level_pk(l_index)||'=B.'||g_level_pk(l_index);
    else
      l_level_count:=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_levels(l_index),g_table_owner);
      l_ilog_count:=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_level_ilog(l_index),g_bis_owner);
      l_use_nl:=EDW_OWB_COLLECTION_UTIL.get_join_nl(l_ilog_count,l_level_count,g_join_nl_percentage);
      l_stmt:=l_stmt||'  as select /*+ordered ';
      if l_use_nl then
        l_stmt:=l_stmt||'use_nl(A)';
      end if;
      l_stmt:=l_stmt||'*/ ';
      if g_parallel is not null then
        l_stmt:=l_stmt||'/*+parallel(A,'||g_parallel||')*/ ';
      end if;
      l_stmt:=l_stmt||'B.row_id,B.status';
      l_stmt:=l_stmt||' from '||g_level_ilog(l_index)||' B,'||g_levels(l_index)||' A where A.rowid=B.row_id';
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_level_ilog_el)=false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.execute_stmt(l_stmt)=false then
      g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
      g_status:=false;
      write_to_log_file_n(g_status_message);
      return false;
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_level_ilog_el,instr(l_level_ilog_el,'.')+1,
    length(l_level_ilog_el)),substr(l_level_ilog_el,1,instr(l_level_ilog_el,'.')-1));
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_level_ilog(l_index))=false then
      null;
    end if;
    g_level_ilog(l_index):=l_level_ilog_el;
    l_level_ilog_el:=g_level_ilog(l_index)||'T';
    l_stmt:='create table '||l_level_ilog_el||' tablespace '||g_op_table_space;
    if g_parallel  is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||' as select ';
    if g_parallel  is not null then
      l_stmt:=l_stmt||' /*+PARALLEL ('||g_level_snapshot_logs(l_index)||','||g_parallel||')*/ ';
    end if;
    if g_snplog_has_pk(l_index) then
      l_stmt:=l_stmt||' distinct chartorowid(M_ROW$$) row_id,'||g_level_snapshot_logs(l_index)||'.'||g_level_pk(l_index)||
      ',0 status from '||g_level_snapshot_logs(l_index);
    else
      l_stmt:=l_stmt||' distinct chartorowid(M_ROW$$) row_id,0 status from '||g_level_snapshot_logs(l_index);
    end if;
    l_stmt:=l_stmt||','||g_levels(l_index)||' where '||g_levels(l_index)||'.rowid='||
    g_level_snapshot_logs(l_index)||'.M_ROW$$ and '||g_levels(l_index)||'.PUSHED_DOWN_FLAG is null '||
    'MINUS select ';
    if g_snplog_has_pk(l_index) then
      l_stmt:=l_stmt||'row_id,'||g_level_pk(l_index)||',0 status from '||g_level_ilog(l_index);
    else
      l_stmt:=l_stmt||'row_id,'||'0 status from '||g_level_ilog(l_index);
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_level_ilog_el)=false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.execute_stmt(l_stmt)=false then
      g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
      g_status:=false;
      write_to_log_file_n(g_status_message);
      return false;
    end if;
    if g_snplog_has_pk(l_index) then
      l_stmt:='insert into '||g_level_ilog(l_index)||'(row_id,'||g_level_pk(l_index)||',status) select '||
      'row_id,'||g_level_pk(l_index)||',status from '||l_level_ilog_el;
    else
      l_stmt:='insert into '||g_level_ilog(l_index)||'(row_id, status) select '||
      'row_id,status from '||l_level_ilog_el;
    end if;
    if EDW_OWB_COLLECTION_UTIL.execute_stmt(l_stmt)=false then
      g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
      g_status:=false;
      write_to_log_file_n(g_status_message);
      return false;
    end if;
    commit;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_level_ilog_el)=false then
      null;
    end if;
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_level_ilog(l_index),instr(g_level_ilog(l_index),'.')+1,
  length(g_level_ilog(l_index))),substr(g_level_ilog(l_index),1,instr(g_level_ilog(l_index),'.')-1));
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function analyze_ltc_tables return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In analyze_ltc_tables');
  end if;
  for i in 1..g_number_levels loop
    if g_analyze_needed(i)=true then
      EDW_OWB_COLLECTION_UTIL.analyze_table_stats(g_levels(i), g_table_owner);
      if g_debug then
        write_to_log_file_n('Analyzed '||g_levels(i));
      end if;
    end if;
  end loop;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;
/*
drop_ilog is called from all collect in clean_up
*/
procedure drop_ilog is
Begin
  if g_debug then
    write_to_log_file_n('In drop_ilog');
  end if;
  for i in 1..g_number_levels loop
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_level_ilog(i))=false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_level_ilog(i)||'A')=false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_ilog_tables(g_level_ilog(i)||'_IL',null,g_bis_owner)=false then
      null;
    end if;
  end loop;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
End;

procedure insert_into_load_progress_d(p_load_fk number,p_object_name varchar2,p_load_progress varchar2,
  p_start_date date,p_end_date date,p_category varchar2, p_operation varchar2,p_seq_id varchar2,p_flag varchar2) is
Begin
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.insert_into_load_progress(p_load_fk,p_object_name,g_level_id,p_load_progress,
    p_start_date,p_end_date,p_category,p_operation,p_seq_id,p_flag,g_level_id);
    commit;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
End;

/*
0 error
1 no need to push down
2 need to push down
*/
function find_ltc_to_push_down return number is
l_found boolean;
l_option_value varchar2(20);
l_itemset_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_itemset_cols number;
Begin
  l_found:=false;
  if g_read_cfig_options then
    if g_debug then
      write_to_log_file_n('Reading the cfig data for levels to push down');
    end if;
    if edw_option.get_warehouse_option(g_dim_name,null,'LEVELPUSHDOWN',l_option_value)=false then
      g_status_message:=edw_option.g_status_message;
      g_status:=false;
      write_to_log_file_n(g_status_message);
      return 0;
    end if;
    if l_option_value='Y' then
      if g_debug then
        write_to_log_file_n('Push down implemented for the dimension');
      end if;
      for i in 1..g_number_levels loop
        g_level_consider(i):=true;
      end loop;
      if edw_option.get_option_columns(g_dim_name,null,'LEVELPUSHDOWN',l_itemset_cols,
        l_number_itemset_cols)=false then
        g_status_message:=edw_option.g_status_message;
        g_status:=false;
        return 0;
      end if;
      if l_number_itemset_cols>0 then
        for i in 1..g_number_levels loop
          if EDW_OWB_COLLECTION_UTIL.value_in_table(l_itemset_cols,l_number_itemset_cols,
            substr(g_levels(i),1,instr(g_levels(i),'_LTC',-1)-1))=false then
            g_level_consider(i):=false;
          end if;
        end loop;
      end if;
      if g_debug then
        for i in 1..g_number_levels loop
          if g_level_consider(i) then
            write_to_log_file_n('Push down implemented for     '||g_levels(i));
          else
            write_to_log_file_n('Push down NOT implemented for '||g_levels(i));
          end if;
        end loop;
      end if;
      return 2;
    else
      return 1;
    end if;
  else
    if EDW_OWB_COLLECTION_UTIL.is_itemset_implemented(g_dim_name,'EDW_LEVEL_PUSH_DOWN')='Y' then
      --all levels
      for i in 1..g_number_levels loop
        g_level_consider(i):=true;
      end loop;
      if g_debug then
        write_to_log_file_n('Push down implemented for all levels of the dimension');
      end if;
      return 2;
    end if;
    for i in 1..g_number_levels loop
      --g_levels
      if EDW_OWB_COLLECTION_UTIL.is_itemset_implemented(g_levels(i),'EDW_LEVEL_PUSH_DOWN')='Y' then
        g_level_consider(i):=true;
        l_found:=true;
      else
        g_level_consider(i):=false;
      end if;
    end loop;
  end if;
  if g_debug then
    for i in 1..g_number_levels loop
      if g_level_consider(i) then
        write_to_log_file_n('Push down implemented for     '||g_levels(i));
      else
        write_to_log_file_n('Push down NOT implemented for '||g_levels(i));
      end if;
    end loop;
  end if;
  if l_found then
    return 2;
  else
    return 1;
  end if;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return 0;
End;

function create_ilog_copy(p_ilog varchar2,p_ilog_copy varchar2) return boolean is
l_stmt varchar2(10000);
Begin
  l_stmt:='create table '||p_ilog_copy||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  as select row_id from '||p_ilog||' where status=1';
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_ilog_copy)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(p_ilog_copy,instr(p_ilog_copy,'.')+1,
  length(p_ilog_copy)),substr(p_ilog_copy,1,instr(p_ilog_copy,'.')-1));
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function find_diamond_levels return boolean is
l_stmt varchar2(10000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_top_level varchar2(200);
l_hier_hold varchar2(200);
l_child_hold varchar2(200);
l_parent_ltc EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_child_ltc EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_hier EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_ltc number;
Begin
  l_stmt:='select parent_level.level_name||''_LTC'',child_level.level_name||''_LTC'', hier.hier_name '||
  'from  '||
  'edw_pvt_level_relation_md_v lvl_rel,  '||
  'edw_hierarchies_md_v hier,  '||
  'edw_dimensions_md_v dim,  '||
  'edw_levels_md_v child_level,  '||
  'edw_levels_md_v parent_level  '||
  'where  '||
  'dim.dim_name=:a '||
  'and hier.dim_id=dim.dim_id '||
  'and lvl_rel.hierarchy_id=hier.hier_id '||
  'and child_level.level_id=lvl_rel.child_level_id '||
  'and parent_level.level_id=lvl_rel.parent_level_id';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using '||g_dim_name);
  end if;
  l_number_ltc:=1;
  open cv for l_stmt using g_dim_name;
  loop
    fetch cv into l_parent_ltc(l_number_ltc),l_child_ltc(l_number_ltc),l_hier(l_number_ltc);
    exit when cv%notfound;
    l_number_ltc:=l_number_ltc+1;
  end loop;
  l_number_ltc:=l_number_ltc-1;
  if g_debug then
    write_to_log_file_n('Results');
    for i in 1..l_number_ltc loop
      write_to_log_file(l_parent_ltc(i)||' '||l_child_ltc(i)||' '||l_hier(i));
    end loop;
  end if;
  --see what all levels are allowed and allocate them
  --g_number_levels
  g_number_ltc:=0;
  for i in 1..l_number_ltc loop
    if EDW_OWB_COLLECTION_UTIL.value_in_table(g_levels,g_number_levels,l_parent_ltc(i)) and
      EDW_OWB_COLLECTION_UTIL.value_in_table(g_levels,g_number_levels,l_child_ltc(i)) then
      g_number_ltc:=g_number_ltc+1;
      g_parent_ltc(g_number_ltc):=l_parent_ltc(i);
      g_child_ltc(g_number_ltc):=l_child_ltc(i);
      g_hier(g_number_ltc):=l_hier(i);
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('After considering the included levels turned ON');
    for i in 1..g_number_ltc loop
      write_to_log_file(g_parent_ltc(i)||' '||g_child_ltc(i)||' '||g_hier(i));
    end loop;
  end if;
  g_number_distinct_hier:=0;
  for i in 1..g_number_ltc loop
    if EDW_OWB_COLLECTION_UTIL.value_in_table(g_distinct_hier,g_number_distinct_hier,g_hier(i))=false then
      g_number_distinct_hier:=g_number_distinct_hier+1;
      g_distinct_hier(g_number_distinct_hier):=g_hier(i);
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('Distinct list of hierarchies');
    for i in 1..g_number_distinct_hier loop
      write_to_log_file(g_distinct_hier(i));
    end loop;
  end if;
  --g_levels
  l_top_level:=g_level_order(1);
  if g_debug then
    write_to_log_file_n('Top level='||l_top_level);
  end if;
  for i in 1..g_number_levels loop
    if g_levels(i)<>l_top_level then
      l_hier_hold:=null;
      l_child_hold:=null;
      for j in 1..g_number_ltc loop
        if g_parent_ltc(j)=g_levels(i) then
          if l_hier_hold is null then
            l_hier_hold:=g_hier(j);
            l_child_hold:=g_child_ltc(j);
          else
            if g_hier(j)<>l_hier_hold and g_child_ltc(j)<>l_child_hold then
              g_number_diamond_level:=g_number_diamond_level+1;
              g_diamond_level(g_number_diamond_level):=g_levels(i);
              exit;
            end if;
          end if;
        end if;
      end loop;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('The diamond top levels');
    for i in 1..g_number_diamond_level loop
      write_to_log_file(g_diamond_level(i));
    end loop;
  end if;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function get_diamond_tops(p_parent_level varchar2,p_diamond_tops out NOCOPY EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_diamond_tops out NOCOPY number) return boolean is
Begin
  p_number_diamond_tops:=0;
  for i in 1..g_number_diamond_level loop
    for j in 1..g_number_final loop
      if g_diamond_level(i)=g_final_levels(j) and p_parent_level=g_final_child_levels(j) then
        p_number_diamond_tops:=p_number_diamond_tops+1;
        p_diamond_tops(p_number_diamond_tops):=g_diamond_level(i);
        exit;
      end if;
    end loop;
  end loop;
  if g_debug then
    write_to_log_file_n('The diamond tops for '||p_parent_level);
    for i in 1..p_number_diamond_tops loop
      write_to_log_file(p_diamond_tops(i));
    end loop;
  end if;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function get_level_for_fk(p_child_level varchar2,p_fk varchar2) return varchar2 is
Begin
  for i in 1..g_number_final loop
    if p_child_level=g_final_child_levels(i) and p_fk=g_final_fk(i) then
      return g_final_next_parent(i);
    end if;
  end loop;
  return null;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return null;
End;

function is_below_diamond_top(p_other_fk_level varchar2,p_diamond_tops varchar2) return boolean is
Begin
  if p_other_fk_level=p_diamond_tops then
    return true;
  end if;
  for i in 1..g_number_final loop
    if g_final_levels(i)=p_diamond_tops and g_final_child_levels(i)=p_other_fk_level then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function get_way_to_child(p_parent_level varchar2,p_child_level varchar2,
p_parent_level_order out NOCOPY EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_child_level_order out NOCOPY EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_parent_pk_order out NOCOPY EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_child_fk_order out NOCOPY EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_level_order out NOCOPY number) return boolean is
l_cost EDW_OWB_COLLECTION_UTIL.numberTableType;
l_parent varchar2(200);
l_child varchar2(200);
l_found boolean;
l_level_in_hier EDW_OWB_COLLECTION_UTIL.booleanTableType;--both parent and child in the hier
l_parent_found boolean;
l_child_found boolean;
l_min number;
l_min_hier number;
Begin
  if g_debug then
    write_to_log_file_n('In get_way_to_child');
  end if;
  for i in 1..g_number_distinct_hier loop
    l_level_in_hier(i):=false;
    l_parent_found:=false;
    l_child_found:=false;
    for j in 1..g_number_ltc loop
      if g_distinct_hier(i)=g_hier(j) and g_parent_ltc(j)=p_parent_level then
        l_parent_found:=true;
      end if;
      if g_distinct_hier(i)=g_hier(j) and g_child_ltc(j)=p_child_level then
        l_child_found:=true;
      end if;
    end loop;
    if l_parent_found and l_child_found then
      l_level_in_hier(i):=true;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('Hierarchies that have both the parent '||p_parent_level||' and child '||p_child_level);
    for i in 1..g_number_distinct_hier loop
      if l_level_in_hier(i) then
        write_to_log_file(g_distinct_hier(i));
      end if;
    end loop;
  end if;
  for i in 1..g_number_distinct_hier loop
    l_cost(i):=-1;
    if l_level_in_hier(i) then
      l_parent:=p_parent_level;
      l_cost(i):=0;
      l_found:=false;
      loop
        for j in 1..g_number_ltc loop
          if g_parent_ltc(j)=l_parent and g_hier(j)=g_distinct_hier(i) then
            l_parent:=g_child_ltc(j);
            l_cost(i):=l_cost(i)+1;
            if l_parent=p_child_level then
              l_found:=true;
            end if;
            exit;
          end if;
        end loop;
        if l_found then
          exit;
        end if;
      end loop;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('The cost for each hier');
    for i in 1..g_number_distinct_hier loop
      write_to_log_file(g_distinct_hier(i)||'='||l_cost(i));
    end loop;
  end if;
  --find the min cost
  l_min:=1000000;
  l_min_hier:=0;
  for i in 1..g_number_distinct_hier loop
    if l_level_in_hier(i) then
      if l_min>l_cost(i) then
        l_min:=l_cost(i);
        l_min_hier:=i;
      end if;
    end if;
  end loop;
  if l_min_hier=0 then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.get_message('EDW_NO_MIN_COST_HIER');
    g_status:=false;
    write_to_log_file_n(g_status_message);
    return false;
  end if;
  if g_debug then
    write_to_log_file_n('The min cost and hier '||l_min||' and '||g_distinct_hier(l_min_hier));
  end if;
  p_number_level_order:=0;
  l_parent:=p_parent_level;
  l_found:=false;
  loop
    for i in 1..g_number_ltc loop
      if g_parent_ltc(i)=l_parent and g_hier(i)=g_distinct_hier(l_min_hier) then
        l_child:=g_child_ltc(i);
        for j in 1..g_number_final loop
          if g_final_next_parent(j)=l_parent and g_final_child_levels(j)=l_child then
            p_number_level_order:=p_number_level_order+1;
            p_parent_level_order(p_number_level_order):=l_parent;
            p_child_level_order(p_number_level_order):=l_child;
            p_parent_pk_order(p_number_level_order):=g_final_next_pk(j);
            p_child_fk_order(p_number_level_order):=g_final_fk(j);
            exit;
          end if;
        end loop;
        l_parent:=g_child_ltc(i);
        if l_parent=p_child_level then
          l_found:=true;
        end if;
        exit;
      end if;
    end loop;
    if l_found then
      exit;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('The way to the child level');
    for i in 1..p_number_level_order loop
      write_to_log_file(p_parent_level_order(i)||'('||p_parent_pk_order(i)||') '||p_child_level_order(i)||
      '('||p_child_fk_order(i)||')');
    end loop;
  end if;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function create_child_dia_fk_table(
p_parent_level varchar2,
p_child_level varchar2,
p_parent_level_order  EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_child_level_order  EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_parent_pk_order  EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_child_fk_order  EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_level_order  number,
p_ilog varchar2,
p_other_fks EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_below_diamond_flag EDW_OWB_COLLECTION_UTIL.booleanTableType,
p_number_other_fks number,
p_diamond_fk_table out NOCOPY varchar2) return boolean is
l_diamond_table varchar2(200);
l_max_rownum_table varchar2(200);
l_stmt varchar2(32000);
Begin
  if g_debug then
    write_to_log_file_n('In create_child_dia_fk_table ');
  end if;
  l_diamond_table:=g_bis_owner||'.'||p_parent_level||'DK';
  l_max_rownum_table:=g_bis_owner||'.'||p_parent_level||'DM';
  p_diamond_fk_table:=g_bis_owner||'.'||p_parent_level||'DF';
  l_stmt:='create table '||l_diamond_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select /*+ordered*/ ';
  if g_parallel is not null then
    l_stmt:=l_stmt||'/*+parallel('||p_child_level||','||g_parallel||')*/ ';
  end if;
  l_stmt:=l_stmt||'rownum row_num,'||p_parent_level||'.rowid row_id';
  for i in 1..p_number_other_fks loop
    if p_below_diamond_flag(i) then
      l_stmt:=l_stmt||','||p_child_level||'.'||p_other_fks(i);
    end if;
  end loop;
  l_stmt:=l_stmt||','||p_child_level||'.'||p_child_fk_order(p_number_level_order);
  l_stmt:=l_stmt||' from '||p_ilog;
  for i in 1..p_number_level_order loop
    l_stmt:=l_stmt||','||p_parent_level_order(i);
  end loop;
  l_stmt:=l_stmt||','||p_child_level||' where ';
  for i in 1..p_number_level_order loop
    l_stmt:=l_stmt||p_parent_level_order(i)||'.'||p_parent_pk_order(i)||'='||p_child_level_order(i)||'.'||
    p_child_fk_order(i)||' and ';
  end loop;
  l_stmt:=l_stmt||p_ilog||'.row_id='||p_parent_level||'.rowid';
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_diamond_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_diamond_table,instr(l_diamond_table,'.')+1,
  length(l_diamond_table)),substr(l_diamond_table,1,instr(l_diamond_table,'.')-1));
  --get the max of rownum
  l_stmt:='create table '||l_max_rownum_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  as select max(row_num) row_num,'||p_child_fk_order(p_number_level_order)||' from '||
  l_diamond_table||' group by '||p_child_fk_order(p_number_level_order);
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_max_rownum_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_max_rownum_table,instr(l_max_rownum_table,'.')+1,
  length(l_max_rownum_table)),substr(l_max_rownum_table,1,instr(l_max_rownum_table,'.')-1));
  l_stmt:='create table '||p_diamond_fk_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  as select /*+ordered*/ A.row_id';
  for i in 1..p_number_other_fks loop
    if p_below_diamond_flag(i) then
      l_stmt:=l_stmt||',A.'||p_other_fks(i);
    end if;
  end loop;
  l_stmt:=l_stmt||' from '||l_max_rownum_table||' B,'||l_diamond_table||' A where A.row_num=B.row_num and '||
  'A.'||p_child_fk_order(p_number_level_order)||'=B.'||p_child_fk_order(p_number_level_order);
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_diamond_fk_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(p_diamond_fk_table,instr(p_diamond_fk_table,'.')+1,
  length(p_diamond_fk_table)),substr(p_diamond_fk_table,1,instr(p_diamond_fk_table,'.')-1));
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_diamond_table)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_max_rownum_table)=false then
    null;
  end if;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n(g_status_message);
 return false;
End;

function merge_all_ilog_tables return boolean is
Begin
  for i in 1..g_number_levels loop
    if EDW_OWB_COLLECTION_UTIL.merge_all_ilog_tables(
      g_level_ilog_name(i),
      g_level_ilog_name(i),
      g_level_ilog_name(i)||'A',
      'IL',
      g_op_table_space,
      g_bis_owner,
      g_parallel)=false then
      g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
      return false;
    end if;
    if EDW_OWB_COLLECTION_UTIL.check_table(g_level_ilog_name(i)||'A') then
      g_level_ilog(i):=g_level_ilog_name(i)||'A';
    else
      g_level_ilog(i):=g_level_ilog_name(i);
    end if;
  end loop;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n('Error in merge_all_ilog_tables '||g_status_message);
 return false;
End;

function check_level_for_column return boolean is
l_col varchar2(200);
l_owner varchar2(80);
Begin
  l_col:='PUSHED_DOWN_FLAG';
  for i in 1..g_number_levels loop
    l_owner:=EDW_OWB_COLLECTION_UTIL.get_table_owner(g_levels(i));
    if EDW_OWB_COLLECTION_UTIL.check_table_column(g_levels(i),l_owner,l_col)=false then
      g_stmt:='alter table '||l_owner||'.'||g_levels(i)||' add ('||l_col||' varchar2(10))';
      if g_debug then
        write_to_log_file_n(g_stmt);
      end if;
      execute immediate g_stmt;
    end if;
  end loop;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 g_status:=false;
 write_to_log_file_n('Error in check_level_for_column '||g_status_message);
 return false;
End;

function put_rownum_in_ilog_table(p_index number) return boolean is
l_ilog_table varchar2(80);
Begin
  if g_debug then
    write_to_log_file_n('In put_rownum_in_ilog_table for '||g_levels(p_index));
  end if;
  l_ilog_table:=g_level_ilog(p_index);
  if substr(g_level_ilog(p_index),length(g_level_ilog(p_index)),1)='A' then
    g_level_ilog(p_index):=substr(g_level_ilog(p_index),1,length(g_level_ilog(p_index))-1);
  else
    g_level_ilog(p_index):=g_level_ilog(p_index)||'A';
  end if;
  if EDW_OWB_COLLECTION_UTIL.put_rownum_in_ilog_table(
    g_level_ilog(p_index),
    l_ilog_table,
    g_op_table_space,
    g_parallel)=false then
    return false;
  end if;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 write_to_log_file_n('Error in put_rownum_in_ilog_table '||g_status_message);
 return false;
End;

function create_ilog_from_main(p_low_end number,p_high_end number) return boolean is
l_ilog_number number;
Begin
  if g_debug then
    write_to_log_file_n('In create_ilog_from_main');
  end if;
  for i in 1..g_number_levels loop
    if g_level_consider(i) and g_levels(i)<>g_lowest_level then
      if EDW_OWB_COLLECTION_UTIL.make_ilog_from_main_ilog(
        g_level_ilog(i),
        g_level_ilog_main(i),
        p_low_end,
        p_high_end,
        g_op_table_space,
        g_bis_owner,
        g_parallel,
        l_ilog_number)=false then
        return false;
      end if;
      if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_level_ilog(i),' status=1 ')=2 then
        g_skip_ilog_update(i):=true;
      end if;
    end if;
  end loop;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 write_to_log_file_n('Error in create_ilog_from_main '||g_status_message);
 return false;
End;

function set_session_parameters return boolean is
Begin
  if EDW_OWB_COLLECTION_UTIL.set_session_parameters(g_hash_area_size,g_sort_area_size,
    g_trace,g_parallel)=false then
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in set_session_parameters '||g_status_message);
  return false;
End;

function read_options_table(p_input_table varchar2) return boolean is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_level_table varchar2(80);
l_level_child_table varchar2(80);
l_debug varchar2(10);
l_full_refresh varchar2(10);
l_trace varchar2(10);
l_read_cfig_options varchar2(10);
l_level_consider varchar2(10);
l_level_full_insert varchar2(10);
l_run number;
Begin
  write_to_log_file_n('In read_options_table '||p_input_table);
  l_level_table:=p_input_table||'_LT';
  l_level_child_table:=p_input_table||'_LC';
  g_stmt:='select '||
  'dim_id'||
  ',debug'||
  ',parallel'||
  ',collection_size'||
  ',bis_owner'||
  ',table_owner'||
  ',full_refresh'||
  ',forall_size'||
  ',update_type'||
  ',load_pk'||
  ',op_table_space'||
  ',rollback'||
  ',max_threads'||
  ',min_job_load_size'||
  ',sleep_time'||
  ',hash_area_size'||
  ',sort_area_size'||
  ',trace'||
  ',read_cfig_options'||
  ',join_nl_percentage'||
  ' from '||p_input_table;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  open cv for g_stmt;
  fetch cv into
  g_dim_id
  ,l_debug
  ,g_parallel
  ,g_collection_size
  ,g_bis_owner
  ,g_table_owner
  ,l_full_refresh
  ,g_forall_size
  ,g_update_type
  ,g_load_pk
  ,g_op_table_space
  ,g_rollback
  ,g_max_threads
  ,g_min_job_load_size
  ,g_sleep_time
  ,g_hash_area_size
  ,g_sort_area_size
  ,l_trace
  ,l_read_cfig_options
  ,g_join_nl_percentage;
  if l_debug='Y' then
    write_to_log_file('g_dim_id='||g_dim_id);
    write_to_log_file('l_debug='||l_debug);
    write_to_log_file('g_parallel='||g_parallel);
    write_to_log_file('g_collection_size='||g_collection_size);
    write_to_log_file('g_bis_owner='||g_bis_owner);
    write_to_log_file('g_table_owner='||g_table_owner);
    write_to_log_file('l_full_refresh='||l_full_refresh);
    write_to_log_file('g_forall_size='||g_forall_size);
    write_to_log_file('g_update_type='||g_update_type);
    write_to_log_file('g_load_pk='||g_load_pk);
    write_to_log_file('g_op_table_space='||g_op_table_space);
    write_to_log_file('g_rollback='||g_rollback);
    write_to_log_file('g_max_threads='||g_max_threads);
    write_to_log_file('g_min_job_load_size='||g_min_job_load_size);
    write_to_log_file('g_sleep_time='||g_sleep_time);
    write_to_log_file('g_hash_area_size='||g_hash_area_size);
    write_to_log_file('g_sort_area_size='||g_sort_area_size);
    write_to_log_file('l_trace='||l_trace);
    write_to_log_file('l_read_cfig_options='||l_read_cfig_options);
    write_to_log_file('g_join_nl_percentage='||g_join_nl_percentage);
  end if;
  g_debug:=false;
  g_full_refresh:=false;
  g_trace:=false;
  g_read_cfig_options:=false;
  if l_debug='Y' then
    g_debug:=true;
  end if;
  if l_full_refresh='Y' then
    g_full_refresh:=true;
  end if;
  if l_trace='Y' then
    g_trace:=true;
  end if;
  if l_read_cfig_options='Y' then
    g_read_cfig_options:=true;
  end if;
  g_stmt:='select '||
  'levels'||
  ',child_level_number'||
  ',level_order'||
  ',level_snapshot_logs'||
  ',level_ilog'||
  ',level_consider'||
  ',level_full_insert '||
  ' from '||l_level_table||' order by level_number';
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  g_number_levels:=1;
  open cv for g_stmt;
  loop
    fetch cv into
    g_levels(g_number_levels)
    ,g_child_level_number(g_number_levels)
    ,g_level_order(g_number_levels)
    ,g_level_snapshot_logs(g_number_levels)
    ,g_level_ilog_main(g_number_levels)
    ,l_level_consider
    ,l_level_full_insert;
    exit when cv%notfound;
    g_level_consider(g_number_levels):=false;
    g_level_full_insert(g_number_levels):=false;
    if l_level_consider='Y' then
      g_level_consider(g_number_levels):=true;
    end if;
    if l_level_full_insert='Y' then
      g_level_full_insert(g_number_levels):=true;
    end if;
    g_number_levels:=g_number_levels+1;
  end loop;
  g_number_levels:=g_number_levels-1;
  close cv;
  if g_debug then
    write_to_log_file_n('The levels, snp logs etc');
    for i in 1..g_number_levels loop
      write_to_log_file(g_levels(i)||' '||g_child_level_number(i)||' '||g_level_order(i)||' '||
      g_level_snapshot_logs(i)||' '||g_level_ilog_main(i));
      if g_level_consider(i) then
        write_to_log_file('g_level_consider('||i||') TRUE');
      else
        write_to_log_file('g_level_consider('||i||') FALSE');
      end if;
      if g_level_full_insert(i) then
        write_to_log_file('g_level_full_insert('||i||') TRUE');
      else
        write_to_log_file('g_level_full_insert('||i||') FALSE');
      end if;
    end loop;
  end if;
  l_run:=1;
  g_stmt:='select '||
  'child_levels'||
  ',child_fk'||
  ',parent_pk from '||l_level_child_table||' order by run_number';
  open cv for g_stmt;
  loop
    fetch cv into g_child_levels(l_run),g_child_fk(l_run),g_parent_pk(l_run);
    exit when cv%notfound;
    l_run:=l_run+1;
  end loop;
  close cv;
  l_run:=l_run-1;
  if g_debug then
    write_to_log_file_n('The child levels and fk and pk');
    for i in 1..l_run loop
      write_to_log_file(g_child_levels(i)||' '||g_child_fk(i)||' '||g_parent_pk(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in read_options_table '||g_status_message);
  return false;
End;

function drop_input_tables(p_table_name varchar2) return boolean is
Begin
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_table_name)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_table_name||'_LT')=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_table_name||'_LC')=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in drop_input_tables '||g_status_message);
  return false;
End;

function create_conc_program(
p_temp_conc_name varchar2,
p_temp_conc_short_name varchar2,
p_temp_exe_name varchar2,
p_bis_short_name varchar2
) return boolean is
l_exe_file_name varchar2(200);
l_parameter EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_parameter_value_set EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_parameters number;
Begin
  l_exe_file_name:='EDW_PUSH_DOWN_DIMS.PUSH_DOWN_ALL_LEVELS';
  l_parameter(1):='p_dim_name';
  l_parameter_value_set(1):='FND_CHAR240';
  l_parameter(2):='p_log_file';
  l_parameter_value_set(2):='FND_CHAR240';
  l_parameter(3):='p_input_table';
  l_parameter_value_set(3):='FND_CHAR240';
  l_parameter(4):='p_job_id';
  l_parameter_value_set(4):='FND_NUMBER';
  l_parameter(5):='p_ok_low_end';
  l_parameter_value_set(5):='FND_NUMBER';
  l_parameter(6):='p_ok_high_end';
  l_parameter_value_set(6):='FND_NUMBER';
  l_parameter(7):='p_job_status_table';
  l_parameter_value_set(7):='FND_CHAR240';
  l_number_parameters:=7;
  if EDW_OWB_COLLECTION_UTIL.create_conc_program(
    p_temp_conc_name,
    p_temp_conc_short_name,
    p_temp_exe_name,
    l_exe_file_name,
    p_bis_short_name,
    l_parameter,
    l_parameter_value_set,
    l_number_parameters
    )=false then
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_conc_program '||g_status_message);
  return false;
End;

END EDW_PUSH_DOWN_DIMS;

/
