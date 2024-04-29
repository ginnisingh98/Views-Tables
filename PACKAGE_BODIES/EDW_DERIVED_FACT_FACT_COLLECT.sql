--------------------------------------------------------
--  DDL for Package Body EDW_DERIVED_FACT_FACT_COLLECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_DERIVED_FACT_FACT_COLLECT" AS
/*$Header: EDWFFCLB.pls 120.1 2006/05/12 02:51:06 vsurendr ship $*/

/*
entry point for conc processes
*/
procedure COLLECT_FACT_MULTI_THREAD(
errbuf out nocopy varchar2,
retcode out nocopy varchar2,
p_fact_name varchar2,
p_fact_id number,
p_log_file varchar2,
p_input_table varchar2,
p_ilog varchar2,
p_dlog varchar2,
p_pre_hook varchar2,
p_post_hook varchar2,
p_thread_type varchar2
) is
Begin
  retcode:='0';
  COLLECT_FACT_MULTI_THREAD(
  p_fact_name
  ,p_fact_id
  ,p_log_file
  ,p_input_table
  ,p_ilog
  ,p_dlog
  ,p_pre_hook
  ,p_post_hook
  ,p_thread_type);
  if g_status=false then
    retcode:='2';
    errbuf:=g_status_message;
  end if;
Exception when others then
  errbuf:=sqlerrm;
  retcode:='2';
  write_to_log_file_n('Exception in COLLECT_FACT_MULTI_THREAD '||sqlerrm||get_time);
End;

/*
This is en entry point for job. called from EDWFCOLB
This can be called via a job or it can also be called serially
*/
procedure COLLECT_FACT_MULTI_THREAD(
p_fact_name varchar2,
p_fact_id number,
p_log_file varchar2,
p_input_table varchar2,
p_ilog varchar2,
p_dlog varchar2,
p_pre_hook varchar2,
p_post_hook varchar2,
p_thread_type varchar2
) is
Begin
  g_fact_name:=p_fact_name;
  g_fact_id:=p_fact_id;
  g_dbms_job_id:=-1;
  g_ilog:=p_ilog;
  g_dlog:=p_dlog;
  g_log_file:=p_log_file;
  g_pre_hook:=p_pre_hook;
  g_post_hook:=p_post_hook;
  g_status:=true;
  g_thread_type:=p_thread_type;
  EDW_OWB_COLLECTION_UTIL.init_all(g_log_file,null,'bis.edw.loader');
  write_to_log_file_n('In COLLECT_FACT_MULTI_THREAD'||get_time);
  if COLLECT_FACT_MULTI_THREAD(p_input_table)=false then
    g_status:=false;
    if EDW_OWB_COLLECTION_UTIL.log_into_job_status_table(
      g_job_status_table,
      g_fact_name,
      g_job_id,
      'ERROR',
      g_status_message)=false then
      null;
    end if;
    return;
  else
    if EDW_OWB_COLLECTION_UTIL.log_into_job_status_table(
      g_job_status_table,
      g_fact_name,
      g_job_id,
      'SUCCESS',
      g_status_message)=false then
      null;
    end if;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in COLLECT_FACT_MULTI_THREAD '||sqlerrm||get_time);
  return;
End;

function COLLECT_FACT_MULTI_THREAD(
p_input_table varchar2
) return boolean is
l_ilog_table varchar2(100);
l_dlog_table varchar2(100);
l_ilog varchar2(100);
l_dlog varchar2(100);
l_log_low_end EDW_OWB_COLLECTION_UTIL.numberTableType;
l_log_high_end EDW_OWB_COLLECTION_UTIL.numberTableType;
l_log_end_count integer;
l_job_id EDW_OWB_COLLECTION_UTIL.numberTableType;
l_number_jobs number;
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
  if read_options_table(p_input_table)=false then
    return false;
  end if;
  EDW_OWB_COLLECTION_UTIL.set_conc_program_id(g_conc_id);
  EDW_OWB_COLLECTION_UTIL.set_debug(g_debug);
  EDW_OWB_COLLECTION_UTIL.set_parallel(g_parallel);
  EDW_OWB_COLLECTION_UTIL.set_g_read_cfig_options(g_read_cfig_options);
  if set_session_parameters=false then
    return false;
  end if;  --alter session etc
  if g_pre_hook='Y' then
    if pre_fact_load_hook(g_fact_name,g_src_object)=false then
      return false;
    end if;
  end if;
  g_exec_flag:=true;
  g_jobid_stmt:=null;--?
  g_job_id:=null;--?
  g_ilog_name:=g_ilog;
  g_dlog_name:=g_dlog;
  /*
  g_load_mode is BU-DELETE when inc dim changes are propogated to derived/summary facts
  In initial_set_up g_ilog and g_dlog will change names
  */
  if initial_set_up(
    p_input_table,
    g_max_threads,
    l_ilog_table,
    l_dlog_table)=false then
    return false;
  end if;
  if g_over then
    return true;
  end if;
  /*
  if this is full refresh, there will be no multi threading
  */
  if g_full_refresh then
    if COLLECT_FACT('ALL')=false then
      return false;
    end if;
    if g_debug then
      write_to_log_file_n('EDW_DERIVED_FACT_FACT_COLLECT.collect_fact done for '||
      g_src_object||' to '||g_fact_name||'. Time '||get_time);
    end if;
  else
    if EDW_OWB_COLLECTION_UTIL.update_derv_fact_input_table(
      p_input_table,
      l_ilog_table,--the g_ilog_name
      l_dlog_table, --the g_dlog_name
      g_skip_ilog_update,
      g_skip_dlog_update,
      g_skip_ilog,
      g_load_mode,
      g_full_refresh,
      g_src_object_ilog,
      g_src_object_dlog,
      g_src_snplog_has_pk,
      g_err_rec_flag,
      g_err_rec_flag_d
      )=false then
      return false;
    end if;
    --once for ilog and once for dlog
    if EDW_OWB_COLLECTION_UTIL.find_ok_distribution(
      l_ilog_table,
      g_bis_owner,
      g_max_threads,
      g_min_job_load_size,
      l_log_low_end,
      l_log_high_end,
      l_log_end_count)=false then
      return false;
    end if;
    l_number_jobs:=0;
    l_temp_conc_name:='Sub-Proc '||g_src_object_id||'-'||g_fact_id;
    l_temp_conc_short_name:='C_FCLB_'||g_fact_id||'_'||g_src_object_id||'C';
    l_temp_exe_name:='E_FFCLB_'||g_fact_id||'_'||g_src_object_id||'_E';
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
    for j in 1..l_log_end_count loop
      l_number_jobs:=l_number_jobs+1;
      l_job_id(l_number_jobs):=null;
      l_ilog:=g_ilog_name||'_'||l_number_jobs||'_IL';
      l_dlog:=g_dlog_name||'_'||l_number_jobs||'_DL';
      if g_debug then
        write_to_log_file_n('EDW_DERIVED_FACT_FACT_COLLECT.COLLECT_FACT(''ILOG'','''||g_fact_name||''','||
        ''''||p_input_table||''','||l_number_jobs||','||l_log_low_end(j)||','||l_log_high_end(j)||','''||
        l_ilog||''','''||l_dlog||''','''||g_log_file||''','''||g_thread_type||''');');
      end if;
      begin
        l_try_serial:=false;
        if g_thread_type='CONC' then
          l_job_id(l_number_jobs):=FND_REQUEST.SUBMIT_REQUEST(
          application=>l_bis_short_name,
          program=>l_temp_conc_short_name,
          argument1=>'ILOG',
          argument2=>g_fact_name,
          argument3=>p_input_table,
          argument4=>l_number_jobs,
          argument5=>l_log_low_end(j),
          argument6=>l_log_high_end(j),
          argument7=>l_ilog,
          argument8=>l_dlog,
          argument9=>g_log_file,
          argument10=>g_thread_type
          );
          if g_debug then
            write_to_log_file_n('Concurrent process '||l_job_id(l_number_jobs)||' launched '||get_time);
          end if;
          if EDW_OWB_COLLECTION_UTIL.update_inp_table_jobid(p_input_table,l_job_id(l_number_jobs))=false then
            return false;
          end if;
          if l_job_id(l_number_jobs)<=0 then
            l_try_serial:=true;
          end if;
          commit;--this commit is very imp
        else
          DBMS_JOB.SUBMIT(l_job_id(l_number_jobs),'EDW_DERIVED_FACT_FACT_COLLECT.COLLECT_FACT(''ILOG'','''||
          g_fact_name||''','||''''||p_input_table||''','||l_number_jobs||','||l_log_low_end(j)||','||
          l_log_high_end(j)||','''||l_ilog||''','''||l_dlog||''','''||g_log_file||''','''||g_thread_type||''');');
          if g_debug then
            write_to_log_file_n('Job '||l_job_id(l_number_jobs)||' launched '||get_time);
          end if;
          if EDW_OWB_COLLECTION_UTIL.update_inp_table_jobid(p_input_table,l_job_id(l_number_jobs))=false then
            return false;
          end if;
          if l_job_id(l_number_jobs)<=0 then
            l_try_serial:=true;
          end if;
          commit;--this commit is very imp
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
        if EDW_OWB_COLLECTION_UTIL.update_inp_table_jobid(p_input_table,l_job_id(l_number_jobs))=false then
          return false;
        end if;
        commit;--this commit is very imp
        EDW_DERIVED_FACT_FACT_COLLECT.COLLECT_FACT(
        l_errbuf,
        l_retcode,
        'ILOG',
        g_fact_name,
        p_input_table,
        l_number_jobs,
        l_log_low_end(j),
        l_log_high_end(j),
        l_ilog,
        l_dlog,
        g_log_file,
        g_thread_type
        );
      end if;
    end loop;
    if EDW_OWB_COLLECTION_UTIL.wait_on_jobs(
      l_job_id,
      l_number_jobs,
      g_sleep_time,
      g_thread_type)=false then
      return false;
    end if;
    if EDW_OWB_COLLECTION_UTIL.check_all_child_jobs(
      g_job_status_table,
      l_job_id,
      l_number_jobs,
      g_fact_name)=false then
      return false;
    end if;
    /*
    Now launch threads to process the dlog rows
    */
    if g_debug then
      write_to_log_file_n('Processing DLOG Threads '||get_time);
    end if;
    l_log_end_count:=0;
    if EDW_OWB_COLLECTION_UTIL.find_ok_distribution(
      l_dlog_table,
      g_bis_owner,
      g_max_threads,
      g_min_job_load_size,
      l_log_low_end,
      l_log_high_end,
      l_log_end_count)=false then
      return false;
    end if;
    l_number_jobs:=0;
    if EDW_OWB_COLLECTION_UTIL.truncate_table(g_job_status_table)=false then
      null;
    end if;
    for j in 1..l_log_end_count loop
      l_number_jobs:=l_number_jobs+1;
      l_job_id(l_number_jobs):=null;
      l_ilog:=g_ilog_name||'_'||l_number_jobs||'_IL';
      l_dlog:=g_dlog_name||'_'||l_number_jobs||'_DL';
      if g_debug then
        write_to_log_file_n('EDW_DERIVED_FACT_FACT_COLLECT.COLLECT_FACT(''DLOG'','''||g_fact_name||''','||
        ''''||p_input_table||''','||l_number_jobs||','||l_log_low_end(j)||','||l_log_high_end(j)||','''||
        l_ilog||''','''||l_dlog||''','''||g_log_file||''','''||g_thread_type||''');');
      end if;
      begin
        l_try_serial:=false;
        if g_thread_type='CONC' then
          l_job_id(l_number_jobs):=FND_REQUEST.SUBMIT_REQUEST(
          application=>l_bis_short_name,
          program=>l_temp_conc_short_name,
          argument1=>'DLOG',
          argument2=>g_fact_name,
          argument3=>p_input_table,
          argument4=>l_number_jobs,
          argument5=>l_log_low_end(j),
          argument6=>l_log_high_end(j),
          argument7=>l_ilog,
          argument8=>l_dlog,
          argument9=>g_log_file,
          argument10=>g_thread_type
          );
          if g_debug then
            write_to_log_file_n('Concurrent Request '||l_job_id(l_number_jobs)||' launched '||get_time);
          end if;
          if EDW_OWB_COLLECTION_UTIL.update_inp_table_jobid(p_input_table,l_job_id(l_number_jobs))=false then
            return false;
          end if;
          if l_job_id(l_number_jobs)<=0 then
            l_try_serial:=true;
          end if;
          commit;--this commit is very imp
        else
          DBMS_JOB.SUBMIT(l_job_id(l_number_jobs),'EDW_DERIVED_FACT_FACT_COLLECT.COLLECT_FACT(''DLOG'','''||
          g_fact_name||''','||''''||p_input_table||''','||l_number_jobs||','||l_log_low_end(j)||','||
          l_log_high_end(j)||','''||l_ilog||''','''||l_dlog||''','''||g_log_file||''','''||g_thread_type||''');');
          if g_debug then
            write_to_log_file_n('Job '||l_job_id(l_number_jobs)||' launched '||get_time);
          end if;
          if EDW_OWB_COLLECTION_UTIL.update_inp_table_jobid(p_input_table,l_job_id(l_number_jobs))=false then
            return false;
          end if;
          if l_job_id(l_number_jobs)<=0 then
            l_try_serial:=true;
          end if;
          commit;--this commit is very imp
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
        if EDW_OWB_COLLECTION_UTIL.update_inp_table_jobid(p_input_table,l_job_id(l_number_jobs))=false then
          return false;
        end if;
        commit;--this commit is very imp
        EDW_DERIVED_FACT_FACT_COLLECT.COLLECT_FACT(
        l_errbuf,
        l_retcode,
        'DLOG',
        g_fact_name,
        p_input_table,
        l_number_jobs,
        l_log_low_end(j),
        l_log_high_end(j),
        l_ilog,
        l_dlog,
        g_log_file,
        g_thread_type
        );
      end if;
    end loop;
    if EDW_OWB_COLLECTION_UTIL.wait_on_jobs(
      l_job_id,
      l_number_jobs,
      g_sleep_time,
      g_thread_type)=false then
      return false;
    end if;
    if EDW_OWB_COLLECTION_UTIL.check_all_child_jobs(
      g_job_status_table,
      l_job_id,
      l_number_jobs,
      g_fact_name)=false then
      return false;
    end if;
  end if;
  --clean up etc
  clean_up;
  if g_post_hook='Y' then
    if post_fact_load_hook(g_fact_name,g_src_object)=false then
      return false;
    end if;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in COLLECT_FACT_MULTI_THREAD '||sqlerrm||get_time);
  return false;
End;

/*
entry point for child concurrent requests
*/
procedure COLLECT_FACT(
errbuf out nocopy varchar2,
retcode out nocopy varchar2,
p_mode varchar2,
p_fact_name varchar2,
p_input_table varchar2,
p_job_id number,
p_ilog_low_end number,
p_ilog_high_end number,
p_ilog varchar2,
p_dlog varchar2,
p_log_file varchar2,
p_thread_type varchar2
) is
Begin
  retcode:='0';
  COLLECT_FACT(
  p_mode,
  p_fact_name,
  p_input_table,
  p_job_id,
  p_ilog_low_end,
  p_ilog_high_end,
  p_ilog,
  p_dlog,
  p_log_file,
  p_thread_type);
  if g_status=false then
    retcode:='2';
    errbuf:=g_status_message;
  end if;
Exception when others then
  errbuf:=sqlerrm;
  retcode:='2';
  write_to_log_file_n('Exception in COLLECT_FACT '||sqlerrm||get_time);
End;

/*
entry point for child threads
*/
procedure COLLECT_FACT(
p_mode varchar2,
p_fact_name varchar2,
p_input_table varchar2,
p_job_id number,
p_ilog_low_end number,
p_ilog_high_end number,
p_ilog varchar2,
p_dlog varchar2,
p_log_file varchar2,
p_thread_type varchar2
) is
Begin
  g_job_id:=p_job_id;
  g_jobid_stmt:=' Job '||g_job_id||' ';
  g_fact_name:=p_fact_name;
  g_ilog:=p_ilog;
  g_dlog:=p_dlog;
  g_log_file:=p_log_file;
  g_thread_type:=p_thread_type;
  EDW_OWB_COLLECTION_UTIL.init_all(g_log_file||'_'||g_job_id||'_'||p_mode,null,'bis.edw.loader');
  write_to_log_file_n('In COLLECT_FACT p_fact_name='||p_fact_name||',p_input_table='||p_input_table||
  ',p_job_id='||p_job_id||',p_ilog_low_end='||p_ilog_low_end||',p_ilog_high_end='||p_ilog_high_end||
  ',p_mode='||p_mode||' p_thread_type='||p_thread_type);
  if COLLECT_FACT(p_mode,p_input_table,p_ilog_low_end,p_ilog_high_end)=false then
    if EDW_OWB_COLLECTION_UTIL.log_into_job_status_table(
      g_job_status_table,
      g_fact_name,
      g_job_id,
      'ERROR',
      g_status_message)=false then
      null;
    end if;
  else
    if EDW_OWB_COLLECTION_UTIL.log_into_job_status_table(
      g_job_status_table,
      g_fact_name,
      g_job_id,
      'SUCCESS',
      g_status_message)=false then
      null;
    end if;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in COLLECT_FACT '||sqlerrm||get_time);
End;

function COLLECT_FACT(
p_mode varchar2,
p_input_table varchar2,
p_ilog_low_end number,
p_ilog_high_end number
) return boolean is
l_log_name varchar2(80);
l_log varchar2(80);
Begin
  if read_options_table(p_input_table)=false then
    return false;
  end if;
  init_all(g_job_id);
  --have to read again as init_all resets many of the variables
  if read_options_table(p_input_table)=false then
    return false;
  end if;
  --g_conc_program_id is read from p_table_name
  EDW_OWB_COLLECTION_UTIL.set_conc_program_id(g_conc_id);
  EDW_OWB_COLLECTION_UTIL.set_debug(g_debug);
  EDW_OWB_COLLECTION_UTIL.set_parallel(g_parallel);
  EDW_OWB_COLLECTION_UTIL.set_g_read_cfig_options(g_read_cfig_options);
  if set_session_parameters=false then
    return false;
  end if;--alter session etc
  if p_mode='ILOG' then
    l_log_name:=g_ilog_name;
    l_log:=g_ilog;
  elsif p_mode='DLOG' then
    l_log_name:=g_dlog_name;
    l_log:=g_dlog;
  end if;
  if make_ok_from_main_ok(l_log_name,l_log,p_ilog_low_end,p_ilog_high_end,p_mode)=false then
    return false;
  end if;
  if read_metadata=false then
    return false;
  end if;
  if COLLECT_FACT(p_mode)=false then
    return false;
  end if;
  clean_up;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in COLLECT_FACT '||sqlerrm||get_time);
  return false;
End;

function initial_set_up(
p_input_table varchar2,
p_max_threads number,
p_ilog_table out nocopy varchar2,
p_dlog_table out nocopy varchar2
) return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In initial_set_up');
  end if;
  if EDW_OWB_COLLECTION_UTIL.create_job_status_table(g_job_status_table,g_op_table_space)=false then
    return false;
  end if;
  if initialize(true)=false then
    return false;
  end if;
  /*please note that the following are reset to the values shown in init_all in initialize
    g_err_rec_flag:=false;
    g_err_rec_flag_d:=false;
    g_skip_ilog:=false;
    g_skip_ilog_update:=false;
    g_skip_dlog_update:=false;
  */
  if g_over then
    return true;
  end if;
  if g_full_refresh=false then
    insert_into_load_progress_d(g_load_fk,g_fact_name,'ILOG DLOG Processing'||g_jobid_stmt,sysdate,null,'DF',
    'INSERT','ILOGPROC'||g_jobid_stmt,'I');
    if put_rownum_in_log_table=false then
      return false;
    end if;
    insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'ILOGPROC'||g_jobid_stmt,'U');
  end if;
  p_ilog_table:=g_ilog;
  p_dlog_table:=g_dlog;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in initial_set_up '||sqlerrm||get_time);
  return false;
End;

function initialize(p_multi_thread boolean) return boolean is
l_ilog_old varchar2(200);
l_dlog_old varchar2(200);
Begin
  --if the fact has no data then, its full refresh
  if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_fact_name)=1 then
    g_full_refresh:=true;
    if g_debug then
      write_to_log_file_n(g_fact_name||' has no data. full refresh');
    end if;
  end if;
  init_all(null);
  if read_metadata=false then
    return false;
  end if;
  if g_over then
    return true;
  end if;
  if g_full_refresh=false and g_fresh_restart=false then
    if EDW_OWB_COLLECTION_UTIL.merge_all_ilog_tables(
      g_ilog||'_IL',
      g_ilog,
      g_ilog||'A',
      null,
      g_op_table_space,
      g_bis_owner,
      g_parallel)=false then
      return false;
    end if;
    if EDW_OWB_COLLECTION_UTIL.merge_all_ilog_tables(
      g_dlog||'_DL',
      g_dlog,
      g_dlog||'A',
      null,
      g_op_table_space,
      g_bis_owner,
      g_parallel)=false then
      return false;
    end if;
  end if;
  if EDW_OWB_COLLECTION_UTIL.check_table(g_ilog||'A') and EDW_OWB_COLLECTION_UTIL.check_table(g_ilog)=false then
    l_ilog_old:=g_ilog;
    g_ilog:=g_ilog||'A';
  end if;
  if EDW_OWB_COLLECTION_UTIL.check_table(g_dlog||'A') and EDW_OWB_COLLECTION_UTIL.check_table(g_dlog)=false then
    l_dlog_old:=g_dlog;
    g_dlog:=g_dlog||'A';
  end if;
  if g_full_refresh=false and g_fresh_restart=false then
    if recover_from_prot=false then
      return false;
    end if;
  end if;
  if g_full_refresh or g_fresh_restart then
    if EDW_OWB_COLLECTION_UTIL.drop_prot_tables(g_insert_prot_log,'PI',g_bis_owner)=false then
      return false;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_prot_tables(g_update_prot_log,'PU',g_bis_owner)=false then
      return false;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_prot_tables(g_delete_prot_log,'PD',g_bis_owner)=false then
      return false;
    end if;
    if drop_prot_tables=false then
      null;
    end if;
  end if;
  /*
  the position of the next two stmt is very imp. dont put it before merge_all_ilog_tables!!
  */
  if g_fresh_restart then
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_ilog)=false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_dlog)=false then
      null;
    end if;
    if drop_ilog_dlog_tables(g_ilog_name,g_dlog_name)=false then
      return false;
    end if;
  end if;
  if g_full_refresh=false then
    insert_into_load_progress_d(g_load_fk,g_fact_name,'Recover from any Previous Error'||g_jobid_stmt,sysdate,null,'DF',
    'RECOVER','DFRPE'||g_jobid_stmt,'I');
    if recover_from_previous_error= false then
      write_to_log_file_n('recover_from_previous_error returned with false');
      return false;
    end if;
    insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'DFRPE'||g_jobid_stmt,'U');
  end if;
  if check_src_fact_snplog=-1 then
    return false;
  end if;
  g_skip_ilog:=false;
  if g_full_refresh then
    if g_debug then
      write_to_log_file_n('Full refresh. Making g_collection_size=0');
    end if;
    g_collection_size:=0;--this is for performance reasons when loading a derived fact
  end if;
  g_src_object_count:=get_base_fact_count;
  if set_g_src_join_nl(g_collection_size,g_src_object_count)=false then
    g_src_join_nl:=true;
  end if;
  if g_full_refresh then
    --cannot do this for incremental load because snapshot log can have non distinct values
    if g_collection_size=0 or (g_src_object_count<=g_collection_size and g_src_object_count<>-1) then
      g_skip_ilog:=true;
    end if;
  elsif g_load_mode='BU-DELETE' then
    if g_collection_size=0 then
      g_skip_ilog:=true;
    end if;
  elsif g_load_mode='BU-UPDATE' then
    if g_collection_size=0 then
      g_skip_ilog:=true;
    end if;
  end if;
  if g_debug then
    if g_skip_ilog then
      write_to_log_file_n('Skip ILOG TRUE');
    end if;
  end if;
  --move the snapshot data into some ilog table
  --and update the status of the delete log
  if g_err_rec_flag and g_full_refresh = false and g_load_mode <>'BU-DELETE' and g_load_mode <>'BU-UPDATE' then
    insert_into_load_progress_d(g_load_fk,g_fact_name,'Error Recovery into ILOG,DLOG'||g_jobid_stmt,sysdate,null,'DF',
    'INSERT','ERRECDI'||g_jobid_stmt,'I');
    if load_new_update_data= false then
      insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'ERRECDI'||g_jobid_stmt,'U');
      return false;
    end if;
    insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'ERRECDI'||g_jobid_stmt,'U');
  end if;
  if g_skip_ilog=false then
    insert_into_load_progress_d(g_load_fk,g_fact_name,'Move Data into ILOG'||g_jobid_stmt,sysdate,null,'DF',
    'INSERT','DFILOG'||g_jobid_stmt,'I');
    if move_data_into_local_ilog(p_multi_thread)=false then
      write_to_log_file_n('move_data_into_local_ilog returned with error');
      insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'DFILOG'||g_jobid_stmt,'U');
      return false;
    end if;
    insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'DFILOG'||g_jobid_stmt,'U');
  else
    if create_temp_gilog=false then
      return false;
    end if;
    g_type_ilog_generation:='UPDATE';
    g_type_dlog_generation:='UPDATE';
  end if;
  if g_load_mode <>'BU-DELETE' and g_load_mode <>'BU-UPDATE' then
    if g_src_object_dlog is not null and g_full_refresh = false then
      insert_into_load_progress_d(g_load_fk,g_fact_name,'Move Data into DLOG'||g_jobid_stmt,sysdate,null,'DF',
      'INSERT','DFDLOG'||g_jobid_stmt,'I');
      if move_data_into_local_dlog(p_multi_thread)= false then
        write_to_log_file_n('move_data_into_local_dlog returned with error');
        insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'DFDLOG'||g_jobid_stmt,'U');
        return false;
      end if;
      insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'DFDLOG'||g_jobid_stmt,'U');
    else
      if create_temp_gdlog=false then
        return false;
      end if;
      g_type_dlog_generation:='UPDATE';
    end if;
  else
    if create_temp_gdlog=false then
      return false;
    end if;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in initialize '||sqlerrm||get_time);
  return false;
End;

function read_metadata return boolean is
Begin
  insert_into_load_progress_d(g_load_fk,g_fact_name,'Read Metadata'||g_jobid_stmt,sysdate,null,'DF',
  'METADAT','DFRM'||g_jobid_stmt,'I');
  if get_ilog_dlog = false then
    return false;
  end if;
  if g_full_refresh=false and g_src_object_ilog is null then
    write_to_log_file_n('Source snapshot log not found. Returning...');
    insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'DFRM'||g_jobid_stmt,'U');
    g_over:=true;
    return true; --there is nothing to do.
  end if;
  if get_src_fks = false then
    return false;
  end if;
  if get_mapping_details = false then
    return false;
  end if;
  if get_df_extra_fks=false then
    return false;
  end if;
  if make_is_groupby_col= false then
    write_to_log_file_n('make_is_groupby_col returned with false');
    return false;
  end if;
  if make_is_fk_flag = false then
    write_to_log_file_n('make_is_fk_flag returned with false');
    return false;
  end if;
  if is_tgt_fk_mapped= false then
    write_to_log_file_n('is_tgt_fk_mapped returned with false');
    return false;
  end if;
  if make_g_higher_level_flag= false then
    write_to_log_file_n('make_g_higher_level_flag returned with false');
    return false;
  end if;
  insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'DFRM'||g_jobid_stmt,'U');
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in read_metadata '||sqlerrm||get_time);
  return false;
End;

--single thread
function COLLECT_FACT(p_fact_name varchar2,
  p_fact_id number,
  p_mapping_id number,
  p_src_object varchar2,
  p_src_object_id number,
  p_fact_fks EDW_OWB_COLLECTION_UTIL.varcharTableType,
  p_higher_level EDW_OWB_COLLECTION_UTIL.booleanTableType,
  p_parent_dim EDW_OWB_COLLECTION_UTIL.varcharTableType,
  p_parent_level EDW_OWB_COLLECTION_UTIL.varcharTableType,
  p_level_prefix EDW_OWB_COLLECTION_UTIL.varcharTableType,
  p_level_pk EDW_OWB_COLLECTION_UTIL.varcharTableType,
  p_level_pk_key EDW_OWB_COLLECTION_UTIL.varcharTableType,
  p_dim_pk_key EDW_OWB_COLLECTION_UTIL.varcharTableType,
  p_number_fact_fks number,
  p_conc_id number,
  p_conc_program_name varchar2,
  p_debug boolean,
  p_collection_size number,
  p_parallel number,
  p_bis_owner varchar2,
  p_table_owner  varchar2,
  p_ins_rows_processed out NOCOPY number,
  p_full_refresh boolean,
  p_ilog varchar2,
  p_dlog varchar2,
  p_forall_size number,
  p_update_type varchar2,
  p_fact_dlog varchar2,
  p_skip_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
  p_number_skip_cols number,
  p_load_fk number,
  p_fresh_restart boolean,
  p_op_table_space varchar2,
  p_bu_tables EDW_OWB_COLLECTION_UTIL.varcharTableType,--before update tables.prop dim change to derv
  p_bu_dimensions EDW_OWB_COLLECTION_UTIL.varcharTableType,
  p_number_bu_tables number,
  p_bu_src_fact varchar2,--what table to look at as the src fact. if null, scan full the src fact
  p_load_mode varchar2,
  p_rollback varchar2,
  p_src_join_nl_percentage number,
  p_pre_hook varchar2,
  p_post_hook varchar2
) return boolean is
Begin
  g_fact_name:=p_fact_name;
  g_fact_id:=p_fact_id;
  g_mapping_id:=p_mapping_id;
  g_src_object:=p_src_object;
  g_src_object_id:=p_src_object_id;
  g_fact_fks:=p_fact_fks;
  g_higher_level:=p_higher_level;
  g_parent_dim:=p_parent_dim;
  g_parent_level:=p_parent_level;
  g_level_prefix:=p_level_prefix;
  g_level_pk:=p_level_pk;
  g_level_pk_key:=p_level_pk_key;
  g_dim_pk_key:=p_dim_pk_key;
  g_number_fact_fks:=p_number_fact_fks;
  g_conc_id:=p_conc_id;
  g_conc_program_name:=p_conc_program_name;
  g_debug:=p_debug;
  g_exec_flag:=true;
  g_ins_rows_processed:=0;
  g_full_refresh:=p_full_refresh;
  g_collection_size:=p_collection_size;
  g_parallel:=p_parallel;
  g_bis_owner:=p_bis_owner;
  g_table_owner :=p_table_owner;
  g_ilog:=p_ilog;
  g_dlog:=p_dlog;
  g_ilog_name:=p_ilog;
  g_dlog_name:=p_dlog;
  g_forall_size:=p_forall_size;
  g_update_type :=p_update_type;
  g_fact_dlog:=p_fact_dlog;
  g_load_fk:=p_load_fk;
  g_skip_cols:=p_skip_cols;
  g_number_skip_cols:=p_number_skip_cols;
  g_fresh_restart:=p_fresh_restart;
  g_op_table_space:=p_op_table_space;
  g_bu_tables:=p_bu_tables;
  g_bu_dimensions:=p_bu_dimensions;
  g_number_bu_tables:=p_number_bu_tables;
  g_load_mode:=p_load_mode;
  g_rollback:=p_rollback;
  if g_load_mode is null then
    g_load_mode:='NORMAL';
  end if;
  g_bu_src_fact:=p_bu_src_fact;
  if g_number_bu_tables is null then
    g_number_bu_tables:=0;
  end if;
  g_src_join_nl_percentage:=p_src_join_nl_percentage;
  g_pre_hook:=p_pre_hook;
  g_post_hook:=p_post_hook;
  g_dbms_job_id:=-1;
  /*
  g_load_mode is BU-DELETE when inc dim changes are propogated to derived/summary facts
  */
  write_to_log_file_n('In EDW_DERIVED_FACT_FACT_COLLECT.COLLECT_FACT'||get_time);
  if g_debug then
    write_to_log_file('g_collection_size='||g_collection_size);
    write_to_log_file('g_parallel='||g_parallel);
    write_to_log_file('g_bis_owner='||g_bis_owner);
    write_to_log_file('g_table_owner='||g_table_owner);
    write_to_log_file('g_ilog='||g_ilog);
    write_to_log_file('g_dlog='||g_dlog);
    write_to_log_file('p_fact_dlog='||p_fact_dlog);
    write_to_log_file('g_load_fk='||g_load_fk);
    write_to_log_file('g_forall_size='||g_forall_size);
    write_to_log_file('g_op_table_space='||g_op_table_space);
    write_to_log_file('g_rollback='||g_rollback);
    if g_full_refresh then
      write_to_log_file('Full refresh ON');
    else
      write_to_log_file('Full refresh OFF');
    end if;
    write_to_log_file_n('g_fact_id '||g_fact_id||', g_mapping_id '||g_mapping_id||', g_src_object_id '||
    g_src_object_id);
    write_to_log_file_n('Skipped Columns');
    for i in 1..g_number_skip_cols loop
      write_to_log_file(g_skip_cols(i));
    end loop;
    write_to_log_file_n('Keys pointing to higher levels');
    for i in 1..g_number_fact_fks loop
      if g_higher_level(i) then
        write_to_log_file(g_fact_fks(i));
      end if;
    end loop;
    if g_fresh_restart then
      write_to_log_file('g_fresh_restart is TRUE');
    else
      write_to_log_file('g_fresh_restart is FALSE');
    end if;
    write_to_log_file_n('g_load_mode='||g_load_mode);
    write_to_log_file_n('g_bu_src_fact='||g_bu_src_fact);
    write_to_log_file_n('g_number_bu_tables='||g_number_bu_tables);
    write_to_log_file('BU Tables(Dimension)');
    for i in 1..g_number_bu_tables loop
      write_to_log_file(g_bu_tables(i)||'('||g_bu_dimensions(i)||')');
    end loop;
    write_to_log_file_n('g_src_join_nl_percentage='||g_src_join_nl_percentage);
    write_to_log_file_n('g_pre_hook='||g_pre_hook);
    write_to_log_file_n('g_post_hook='||g_post_hook);
  end if;
  if g_pre_hook='Y' then
    if pre_fact_load_hook(g_fact_name,g_src_object)=false then
      return false;
    end if;
  end if;
  if initialize(false)=false then
    return false;
  end if;
  if g_over then
    return true; --there is nothing to do.
  end if;
  if COLLECT_FACT('ALL')=false then
    return false;
  end if;
  --drop the df temp table
  clean_up;
  if g_debug then
    write_to_log_file_n('Delete Tables Done');
  end if;
  if g_post_hook='Y' then
    if post_fact_load_hook(g_fact_name,g_src_object)=false then
      return false;
    end if;
  end if;
  write_to_log_file_n('EDW_DERIVED_FACT_FACT_COLLECT.collect_fact done for '||
  g_src_object||' to '||g_fact_name||'. Time '||get_time);
  p_ins_rows_processed :=g_ins_rows_processed;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in COLLECT_FACT '||sqlerrm||get_time);
  return false;
End;

function COLLECT_FACT(p_mode varchar2) return boolean is
l_count number:=0;
l_status number;
Begin
  if g_debug then
    write_to_log_file_n('In Internal COLLECT_FACT p_mode='||p_mode);
  end if;
  if update_rowid_table_stmt = false then
    write_to_log_file_n('update_rowid_table_stmt returned with error');
    return false;
  end if;
  if delete_rowid_table_stmt = false then
    write_to_log_file_n('delete_rowid_table_stmt returned with error');
    return false;
  end if;
  if insert_rowid_table_stmt = false then
    write_to_log_file_n('insert_rowid_table_stmt returned with error');
    return false;
  end if;
  if make_insert_into_fact  = false then --make the stmt
    write_to_log_file_n('make_insert_into_fact_iv returned with error');
    return false;
  end if;
  if make_update_into_fact  = false then --make the stmt
    write_to_log_file_n('make_update_into_fact returned with error');
    return false;
  end if;
  if make_delete_into_fact  = false then --make the stmt
    write_to_log_file_n('make_delete_into_fact returned with error');
    return false;
  end if;
  --p_mode in single thread mode
  if p_mode='ILOG' or p_mode='ALL' then
    if g_load_mode<>'BU-DELETE' then
      if g_debug then
        write_to_log_file_n('In update mode. derv fact getting added');
      end if;
      loop
        --move the data into the temp table
        /*
        if g_err_rec_flag is true then there is data in the ilog with status 1
        */
        --reset_profiles;
        --g_ins_rows_processed:=0; bug 5197441
        g_total_insert:=0;
        g_total_update:=0;
        g_total_delete:=0;
        l_count:=l_count+1;
        if g_err_rec_flag=false then
          if g_skip_ilog_update=false then
            l_status:=set_gilog_status;
          else
            l_status:=2;
            g_skip_ilog_update:=false;
          end if;
        else
          if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_ilog,'status=1')=2 then
            l_status:=2;
          else
            l_status:=set_gilog_status;
          end if;
          g_err_rec_flag:=false;
          g_skip_ilog_update:=false;
        end if;
        if l_status=0 then --error
          write_to_log_file_n('set_gilog_status returned with error');
          return false;
        elsif l_status=1 then
          if g_debug then
            write_to_log_file_n('No More ILOG data in '||g_ilog||' to go into derived fact');
          end if;
          exit;
        else
          --data still to go
          insert_into_load_progress_d(g_load_fk,g_fact_name,'Move Data into Temp'||g_jobid_stmt,sysdate,null,'DF',
          'INSERT','DFTEMP'||l_count||g_jobid_stmt,'I');
          l_status:=execute_data_into_temp;
          if l_status=0 then
            insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'DFTEMP'||l_count||g_jobid_stmt,'U');
            return false;
          end if;
          insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'DFTEMP'||l_count||g_jobid_stmt,'U');
          if l_status=2 then
            /*
            for summary facts, summarization to higher levels must take place after data has moved into
            temp table
            */
            if g_fact_type='SUMMARY' then
              insert_into_load_progress_d(g_load_fk,g_fact_name,'Summarize Base Fact Data'||g_jobid_stmt,sysdate,null,'DF',
              'CREATE-TABLE','DFSUM'||l_count||g_jobid_stmt,'I');
              if summarize_fact_data=false then
                insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'DFSUM'||l_count||g_jobid_stmt,'U');
                return false;
              end if;
            end if;
            insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'DFSUM'||l_count||g_jobid_stmt,'U');
            insert_into_load_progress_d(g_load_fk,g_fact_name,'Create Update/Insert rowid Tables'||g_jobid_stmt,sysdate,null,'DF',
            'CREATE-TABLE','DFROWID'||l_count||g_jobid_stmt,'I');
            if execute_data_into_rowid_table = false then --creates update and insert rowid tables as select
              write_to_log_file_n('execute_data_into_rowid_table returned with error');
              insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'DFROWID'||l_count||g_jobid_stmt,'U');
              return false;
            end if;
            insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'DFROWID'||l_count||g_jobid_stmt,'U');
            if move_data_into_derived_fact(l_count) = false then
              write_to_log_file_n('move_data_into_derived_fact returned with error');
              return false;
            end if;
            insert_into_temp_log('+');
          end if;--if l_status=2 then
          if g_type_ilog_generation='UPDATE' then
            if update_ilog_status_2 = false then
              return false;
            end if;
          end if;
          if drop_prot_tables=false then
            return false;
          end if;
          commit;
          if g_debug then
            write_to_log_file_n('commit');
          end if;
        end if;
      end loop;
    end if;--if g_load_mode<>'BU-DELETE' then
  end if;
  if p_mode='DLOG' or p_mode='ALL' then
    --if this is full refresh, no need to delete data
    --we take the rowids from the src fact itself and populate the ilog table
    --the derived fact is truncated before the full refresh begins
    if g_load_mode='BU-DELETE' or (g_full_refresh=false and g_src_object_dlog is not null and
      g_load_mode<>'BU-UPDATE') then
      if g_debug then
        write_to_log_file_n('In delete mode. derv fact getting subtracted');
      end if;
      l_count:=0;
      loop
        --reset_profiles;
        l_count:=l_count+1;
        --move the delete data
        --g_ins_rows_processed:=0; bug 5197441
        g_total_insert:=0;
        g_total_update:=0;
        g_total_delete:=0;
        if g_err_rec_flag_d=false then
          if g_skip_dlog_update=false then
            l_status:=set_gdlog_status;
          else
            l_status:=2;
            g_skip_dlog_update:=false;
          end if;
        else
          if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_dlog,'status=1')=2 then
            l_status:=2;
          else
            l_status:=set_gdlog_status;
          end if;
          g_err_rec_flag_d:=false;
          g_skip_dlog_update:=false;
        end if;
        if l_status=0 then --error
          return false;
        elsif l_status=1 then
          if g_debug then
            write_to_log_file_n('No More DLOG data in '||g_ilog||' to go into derived fact');
          end if;
          exit;
        else
          insert_into_load_progress_d(g_load_fk,g_fact_name,'Move Update/Delete Data into Temp'||g_jobid_stmt,sysdate,null,'DF',
          'INSERT','DFDTEMP'||l_count||g_jobid_stmt,'I');
          l_status:=execute_delete_data_into_temp;
          if  l_status= 0 then
            insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'DFDTEMP'||l_count||g_jobid_stmt,'U');
            return false;
          end if;
          insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'DFDTEMP'||l_count||g_jobid_stmt,'U');
          if l_status=2 then
            /*
            for summary facts, summarization to higher levels must take place after data has moved into
            temp table
            */
            if g_fact_type='SUMMARY' then
              insert_into_load_progress_d(g_load_fk,g_fact_name,'Summarize Base Fact Data'||g_jobid_stmt,sysdate,null,'DF',
              'CREATE-TABLE','DFDSUM'||l_count||g_jobid_stmt,'I');
              if summarize_fact_data=false then
                insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'DFDSUM'||l_count||g_jobid_stmt,'U');
                return false;
              end if;
              insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'DFDSUM'||l_count||g_jobid_stmt,'U');
            end if;
            insert_into_load_progress_d(g_load_fk,g_fact_name,'Create Delete rowid Tables'||g_jobid_stmt,sysdate,null,'DF',
            'CREATE-TABLE','DFDROWID'||l_count||g_jobid_stmt,'I');
            if execute_ddata_into_rowid_table = false then --moves data into delete
              write_to_log_file_n('execute_ddata_into_rowid_table returned with error');
              insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'DFDROWID'||l_count||g_jobid_stmt,'U');
              return false;
            end if;
            insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'DFDROWID'||l_count||g_jobid_stmt,'U');
            if move_ddata_into_derived_fact(l_count) = false then
              write_to_log_file_n('move_ddata_into_derived_fact returned with error');
              return false;
            end if;
            insert_into_temp_log('-');
          end if;--if l_status=2 then
          if g_type_dlog_generation='UPDATE' then
            if update_dlog_status_2 = false then
             return false;
            end if;
          end if;
          if drop_d_prot_tables=false then
            return false;
          end if;
          commit;
          if g_debug then
           write_to_log_file_n('commit');
          end if;
        end if;
      end loop;
    end if;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in Internal COLLECT_FACT '||sqlerrm||get_time);
  return false;
End;

function move_ddata_into_derived_fact(p_count number) return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In move_ddata_into_derived_fact');
  end if;
  if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_delete_rowid_table) = 2 then
    insert_into_load_progress_d(g_load_fk,g_fact_name,'Update Derived/Summary Fact with Delete Data'||g_jobid_stmt,sysdate,
    null,'DF','UPDATE','DFDDEL'||p_count||g_jobid_stmt,'I');
    if delete_into_fact = false then
      write_to_log_file_n('delete_into_fact returned with false');
      insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'DFDDEL'||p_count||g_jobid_stmt,'U');
      return false;
    end if;
    insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'DFDDEL'||p_count||g_jobid_stmt,'U');
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;


function move_data_into_derived_fact(p_count number) return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In move_data_into_derived_fact');
  end if;
  if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_insert_rowid_table)=2 then
    insert_into_load_progress_d(g_load_fk,g_fact_name,'Insert Into Derived/Summary Fact'||g_jobid_stmt,sysdate,null,'DF',
    'INSERT','DFDINS'||p_count||g_jobid_stmt,'I');
    if insert_into_fact = false then
      write_to_log_file_n('insert_into_fact returned with false');
      insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'DFDINS'||p_count||g_jobid_stmt,'U');
      return false;
    end if;
    insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'DFDINS'||p_count||g_jobid_stmt,'U');
  end if;
  if drop_insert_lock_table=false then
    return false;
  end if;
  if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_update_rowid_table) =2 then
    insert_into_load_progress_d(g_load_fk,g_fact_name,'Update Derived/Summary Fact'||g_jobid_stmt,sysdate,null,'DF',
    'UPDATE','DFDUPD'||p_count||g_jobid_stmt,'I');
    if update_into_fact = false then
      write_to_log_file_n('update_into_fact returned with false');
      insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'DFDUPD'||p_count||g_jobid_stmt,'U');
      return false;
    end if;
    insert_into_load_progress_d(g_load_fk,null,null,null,sysdate,null,null,'DFDUPD'||p_count||g_jobid_stmt,'U');
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

/*
a temp function here only because m_row$$ is varchar2 while row_id is rowid, see MINUS
*/
function create_gilog_T(p_table varchar2,p_ilog_temp varchar2) return boolean is
l_stmt varchar2(4000);
Begin
  if g_debug then
    write_to_log_file_n('In create_gilog_T');
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_ilog_temp)=false then
    null;
  end if;
  if g_src_snplog_has_pk then
    --l_stmt:='create table '||p_ilog_temp||'(row_id varchar2(255),'||g_src_pk||' number) tablespace '||g_op_table_space;
    l_stmt:='create table '||p_ilog_temp||'(row_id rowid,'||g_src_pk||' number) tablespace '||g_op_table_space;
  else
    --l_stmt:='create table '||p_ilog_temp||'(row_id varchar2(255)) '||' tablespace '||g_op_table_space;
    l_stmt:='create table '||p_ilog_temp||'(row_id rowid) '||' tablespace '||g_op_table_space;
  end if;
  if g_parallel is not null then
   l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  begin
    execute immediate l_stmt;
  exception when others then
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message);
    return false;
  end;
  if g_src_snplog_has_pk then
    l_stmt:='insert into '||p_ilog_temp||' (row_id,'||g_src_pk||') select ';
  else
    l_stmt:='insert into '||p_ilog_temp||' (row_id) select ';
  end if;
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+PARALLEL ('||p_table||','||g_parallel||')*/ ';
  end if;
  if g_src_snplog_has_pk then
    l_stmt:=l_stmt||' rowid,'||g_src_pk||' from '||p_table;
  else
    l_stmt:=l_stmt||' rowid from '||p_table;
  end if;
  if g_debug then
     write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  begin
    EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
    execute immediate l_stmt;
    commit;
    if g_debug then
      write_to_log_file_n('Moved '||sql%rowcount||' rows into '||p_ilog_temp||get_time);
    end if;
    if sql%rowcount > 0 then
      EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(p_ilog_temp,instr(p_ilog_temp,'.')+1,
        length(p_ilog_temp)),substr(p_ilog_temp,1,instr(p_ilog_temp,'.')-1));
    end if;
  exception when others then
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message);
    return false;
  end;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function drop_ilog_index return boolean is
l_stmt varchar2(4000);
Begin
  l_stmt:='drop index '||g_ilog||'u';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  l_stmt:='drop index '||g_ilog||'n';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function move_data_into_local_ilog(p_multi_thread boolean) return boolean is
l_stmt varchar2(20000);
l_stmt1 varchar2(20000);
l_ilog varchar2(400);
l_ilog_found boolean;
l_ilog_has_data  boolean;
l_ilog_temp varchar2(400);
l_ilog_el varchar2(400);
l_round_found boolean;
l_src_object_ilog varchar2(400);
l_use_nl boolean;
l_ilog_count number;
Begin
  if g_debug then
    write_to_log_file_n('In move_data_into_local_ilog');
  end if;
  l_src_object_ilog:=g_ilog||'SRC';
  if g_full_refresh then
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_ilog)=false then
      write_to_log_file_n('Table '||g_ilog||' not found for dropping');
    end if;
    l_ilog_found:=false;
    l_ilog_has_data:=false;
  else
    if EDW_OWB_COLLECTION_UTIL.check_table(g_ilog) = false then
      l_ilog_found:=false;
    else
      l_ilog_found:=true;
      if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_ilog) = 1 then
        l_ilog_has_data:=false;
        l_ilog_found:=false;
        if EDW_OWB_COLLECTION_UTIL.drop_table(g_ilog)=false then
          write_to_log_file_n('Table '||g_ilog||' not found for dropping');
        end if;
      else
        l_ilog_has_data:=true;
      end if;
    end if;
  end if;
  if l_ilog_found=false then
    g_skip_ilog_update:=true;
    l_stmt:='create table '||g_ilog||' tablespace '||g_op_table_space||
    ' storage(initial 4M next 4M pctincrease 0) ';
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||' as select ';
    if g_full_refresh then
      l_ilog_temp:=g_ilog||'T';
      if create_gilog_T(g_src_object,l_ilog_temp) = false then
        write_to_log_file_n('create_gilog_T returned with error');
        return false;
      end if;
      if g_collection_size>0 and p_multi_thread=false then
        if g_src_snplog_has_pk then
          l_stmt:=l_stmt||' row_id row_id,'||g_src_pk||',decode(sign(rownum-'||
          g_collection_size||'),1,0,1) status,0 round from '||l_ilog_temp;
        else
          l_stmt:=l_stmt||' row_id row_id,decode(sign(rownum-'||g_collection_size||'),1,0,1) status,0 round from '||
          l_ilog_temp;
        end if;
      else
        if g_src_snplog_has_pk then
          if p_multi_thread then
            l_stmt:=l_stmt||' row_id row_id,'||g_src_pk||', 0 status,0 round from '||l_ilog_temp;
          else
            l_stmt:=l_stmt||' row_id row_id,'||g_src_pk||', 1 status,0 round from '||l_ilog_temp;
          end if;
        else
          if p_multi_thread then
            l_stmt:=l_stmt||' row_id row_id, 0 status,0 round from '||l_ilog_temp;
          else
            l_stmt:=l_stmt||' row_id row_id, 1 status,0 round from '||l_ilog_temp;
          end if;
        end if;
      end if;
    else
      l_stmt1:='create table '||l_src_object_ilog||' tablespace '||g_op_table_space;
      if g_parallel is not null then
        l_stmt1:=l_stmt1||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt1:=l_stmt1||' as select ';
      if g_parallel is not null then
        l_stmt1:=l_stmt1||'/*+PARALLEL ('||g_src_object_ilog||','||g_parallel||')*/ ';
      end if;
      if g_src_snplog_has_pk then
        l_stmt1:=l_stmt1||' distinct m_row$$ row_id,'||g_src_pk||' from '||g_src_object_ilog;
      else
        l_stmt1:=l_stmt1||' distinct m_row$$ row_id from '||g_src_object_ilog;
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_src_object_ilog)=false then
        null;
      end if;
      if g_debug then
        write_to_log_file_n('Going to execute '||l_stmt1||get_time);
      end if;
      execute immediate l_stmt1;
      if g_debug then
        write_to_log_file_n('Created '||l_src_object_ilog||' with '||sql%rowcount||' records'||get_time);
      end if;
      EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_src_object_ilog,instr(l_src_object_ilog,'.')+1,
      length(l_src_object_ilog)), substr(l_src_object_ilog,1,instr(l_src_object_ilog,'.')-1));
      if g_collection_size>0 and p_multi_thread=false then
        if g_src_snplog_has_pk then
          l_stmt:=l_stmt||' chartorowid(row_id) row_id,'||g_src_pk||',decode(sign(rownum-'||
          g_collection_size||'),1,0,1) status,0 round from '||l_src_object_ilog;
        else
          l_stmt:=l_stmt||' chartorowid(row_id) row_id,decode(sign(rownum-'||g_collection_size||'),1,0,1) status,0 round '||
          'from '||l_src_object_ilog;
        end if;
      else
        if g_src_snplog_has_pk then
          if p_multi_thread then
            l_stmt:=l_stmt||' chartorowid(row_id) row_id,'||g_src_pk||',0 status,0 round from '||l_src_object_ilog;
          else
            l_stmt:=l_stmt||' chartorowid(row_id) row_id,'||g_src_pk||',1 status,0 round from '||l_src_object_ilog;
          end if;
        else
          if p_multi_thread then
            l_stmt:=l_stmt||' chartorowid(row_id) row_id,0 status,0 round from '||l_src_object_ilog;
          else
            l_stmt:=l_stmt||' chartorowid(row_id) row_id,1 status,0 round from '||l_src_object_ilog;
          end if;
        end if;
      end if;
    end if;
  else
    if EDW_OWB_COLLECTION_UTIL.check_table_column(g_ilog,'round') then
      l_round_found:=true;
    else
      l_round_found:=false;
    end if;
    if substr(g_ilog,length(g_ilog),1)='A' then
      l_ilog_el:=substr(g_ilog,1,length(g_ilog)-1);
    else
      l_ilog_el:=g_ilog||'A';
    end if;
    l_stmt:='create table '||l_ilog_el||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    if g_src_object_count is null then
      g_src_object_count:=get_base_fact_count;
    end if;
    l_ilog_count:=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_ilog,g_bis_owner);
    l_use_nl:=EDW_OWB_COLLECTION_UTIL.get_join_nl(l_ilog_count,g_src_object_count,g_src_join_nl_percentage);
    l_stmt:=l_stmt||' as select /*+ORDERED ';
    if l_use_nl then
      l_stmt:=l_stmt||'use_nl(B)';
    end if;
    l_stmt:=l_stmt||'*/ ';
    if g_parallel is not null then
      l_stmt:=l_stmt||' /*+PARALLEL(B,'||g_parallel||')*/ ';
    end if;
    if g_src_snplog_has_pk then
      if l_round_found then
        l_stmt:=l_stmt||' B.rowid row_id,B.'||g_src_pk||',A.status,A.round from '||g_ilog||' A,'||
        g_src_object||' B where A.'||g_src_pk||'=B.'||g_src_pk;
      else
        l_stmt:=l_stmt||' B.rowid row_id,B.'||g_src_pk||',A.status,0 round from '||g_ilog||' A,'||
        g_src_object||' B where A.'||g_src_pk||'=B.'||g_src_pk;
      end if;
    else
      if l_round_found then
        l_stmt:=l_stmt||' A.row_id,A.status,A.round from '||g_ilog||' A,'||g_src_object||' B where A.row_id=B.rowid';
      else
        l_stmt:=l_stmt||' A.row_id,A.status,0 round from '||g_ilog||' A,'||g_src_object||' B where A.row_id=B.rowid';
      end if;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_ilog_el)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created '||l_ilog_el||' with '||sql%rowcount||' records'||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_ilog_el,instr(l_ilog_el,'.')+1,length(l_ilog_el)),
    substr(l_ilog_el,1,instr(l_ilog_el,'.')-1));
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_ilog)=false then
      null;
    end if;
    g_ilog:=l_ilog_el;
    l_ilog_temp:=g_ilog||'T';
    l_stmt:='create table '||l_ilog_temp||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||' ';
    if g_parallel is not null then
      if g_src_snplog_has_pk then
        l_stmt:=l_stmt||' as select /*+PARALLEL ('||g_src_object_ilog||','||g_parallel||')*/ '||
        ' distinct chartorowid(m_row$$) row_id,'||g_src_pk||',0 status  from '||g_src_object_ilog||
        ' MINUS select row_id row_id,'||g_src_pk||',0 status from '||g_ilog;
      else
        l_stmt:=l_stmt||' as select /*+PARALLEL ('||g_src_object_ilog||','||g_parallel||')*/ '||
        ' distinct chartorowid(m_row$$) row_id ,0 status  from '||g_src_object_ilog||
        ' MINUS select row_id row_id ,0 status from '||g_ilog;
      end if;
    else
      if g_src_snplog_has_pk then
        l_stmt:=l_stmt||' as select distinct chartorowid(m_row$$) row_id,'||g_src_pk||',0 status  from '||
        g_src_object_ilog||' MINUS select row_id row_id,'||g_src_pk||',0 status from '||g_ilog;
      else
        l_stmt:=l_stmt||' as select distinct chartorowid(m_row$$) row_id ,0 status  from '||g_src_object_ilog||
        ' MINUS select row_id row_id ,0 status from '||g_ilog;
      end if;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_ilog_temp)=false then
      null;
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created '||l_ilog_temp||' with '||sql%rowcount||' records'||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_ilog_temp,instr(l_ilog_temp,'.')+1,length(l_ilog_temp)),
    substr(l_ilog_temp,1,instr(l_ilog_temp,'.')-1));
     /*
    if drop_ilog_index=false then
      null;
    end if;*/
    if g_src_snplog_has_pk then
      l_stmt:='insert into '||g_ilog||'(row_id,'||g_src_pk||',status,round) select row_id,'||g_src_pk||
      ',status,0 from '||l_ilog_temp;
    else
      l_stmt:='insert into '||g_ilog||'(row_id, status,round) select row_id,status,0 from '||l_ilog_temp;
    end if;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  begin
    EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Inserted '||g_ilog||' with '||sql%rowcount||' records'||get_time);
    end if;
    commit;
    if g_debug then
      write_to_log_file_n('commit');
    end if;
  exception when others then
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message);
    write_to_log_file('Error executing '||l_stmt);
    return false;
  end;
  if l_ilog_temp is not null then
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_ilog_temp)=false then
      null;
    end if;
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_ilog,instr(g_ilog,'.')+1,length(g_ilog)),
   substr(g_ilog,1,instr(g_ilog,'.')-1));
  commit;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_src_object_ilog)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function drop_dlog_index return boolean is
l_stmt varchar2(4000);
Begin
  l_stmt:='drop index '||g_dlog||'u';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  l_stmt:='drop index '||g_dlog||'n';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function move_data_into_local_dlog(p_multi_thread boolean) return boolean is
l_stmt varchar2(20000);
l_dlog varchar2(400);
l_dlog_temp varchar2(400);
l_dlog_found boolean;
l_pk_key_found boolean;
l_rowid1_found boolean;
l_dlog_el varchar2(400);
l_use_nl boolean;
l_dlog_count number;
Begin
  if g_debug then
    write_to_log_file_n('In move_data_into_local_dlog');
  end if;
  if EDW_OWB_COLLECTION_UTIL.check_table_column(g_src_object_dlog,'PK_KEY') then
    l_pk_key_found:=true;
  else
    l_pk_key_found:=false;
  end if;
  if EDW_OWB_COLLECTION_UTIL.check_table(g_dlog) = false then
    l_dlog_found:=false;
  else
    l_dlog_found:=true;
    if EDW_OWB_COLLECTION_UTIL.check_table_column(g_dlog,'pk_key')=false then
      l_dlog_found:=false;
      if EDW_OWB_COLLECTION_UTIL.drop_table(g_dlog)=false then
        null;
      end if;
    else
      if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_dlog) =  1 then
        l_dlog_found:=false;
        if EDW_OWB_COLLECTION_UTIL.drop_table(g_dlog)=false then
          write_to_log_file_n('Table '||g_dlog||' not found for dropping');
        end if;
      end if;
    end if;
  end if;
  if l_dlog_found=false then
    g_skip_dlog_update:=true;
    l_stmt:='create table '||g_dlog||' tablespace '||g_op_table_space||
    ' storage (initial 4M next 4M pctincrease 0) ';
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||' as select ';
    if g_parallel is not null then
      l_stmt:=l_stmt||'/*+PARALLEL ('||g_src_object_dlog||','||g_parallel||')*/ ';
    end if;
    if g_collection_size>0 and p_multi_thread=false then
      if l_pk_key_found then
        l_stmt:=l_stmt||' rowid row_id,row_id row_id1,decode(sign(rownum-'||g_collection_size||'),1,0,1) status,'||
        'pk_key,0 round from '||g_src_object_dlog||' where round=0';
      else
        l_stmt:=l_stmt||' rowid row_id,row_id row_id1,decode(sign(rownum-'||g_collection_size||'),1,0,1) status,'||
        '0 pk_key,0 round from '||g_src_object_dlog;
      end if;
    else
      if l_pk_key_found then
        if p_multi_thread then
          l_stmt:=l_stmt||' rowid row_id,row_id row_id1,0 status,pk_key,0 round from '||g_src_object_dlog||
          ' where round=0';
        else
          l_stmt:=l_stmt||' rowid row_id,row_id row_id1,1 status,pk_key,0 round from '||g_src_object_dlog||
          ' where round=0';
        end if;
      else
        if p_multi_thread then
          l_stmt:=l_stmt||' rowid row_id,row_id row_id1,0 status,0 pk_key,0 round from '||g_src_object_dlog;
        else
          l_stmt:=l_stmt||' rowid row_id,row_id row_id1,1 status,0 pk_key,0 round from '||g_src_object_dlog;
        end if;
      end if;
    end if;
  else
    --recreate the D table
    if EDW_OWB_COLLECTION_UTIL.check_table_column(g_src_object_dlog,'PK_KEY') then
      if substr(g_dlog,length(g_dlog),1)='A' then
        l_dlog_el:=substr(g_dlog,1,length(g_dlog)-1);
      else
        l_dlog_el:=g_dlog||'A';
      end if;
      l_stmt:='create table '||l_dlog_el||' tablespace '||g_op_table_space||
      ' storage (initial 4M next 4M pctincrease 0) ';
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      if g_src_object_dlog_count is null then
        g_src_object_dlog_count:=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_src_object_dlog,null);
      end if;
      l_dlog_count:=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_dlog,g_bis_owner);
      l_use_nl:=EDW_OWB_COLLECTION_UTIL.get_join_nl(l_dlog_count,g_src_object_dlog_count,g_src_join_nl_percentage);
      l_stmt:=l_stmt||' as select /*+ORDERED ';
      if l_use_nl then
        l_stmt:=l_stmt||'use_nl(B)';
      end if;
      l_stmt:=l_stmt||'*/ ';
      if g_parallel is not null then
        l_stmt:=l_stmt||' /*+PARALLEL(B,'||g_parallel||')*/ ';
      end if;
      l_stmt:=l_stmt||'B.rowid row_id,B.row_id row_id1,A.status,A.pk_key,A.round from '||
      g_dlog||' A,'||g_src_object_dlog||' B where A.pk_key=B.pk_key and A.round=B.round';
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_dlog_el)=false then
        null;
      end if;
      if g_debug then
        write_to_log_file_n('Going to execute '||l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Created '||l_dlog_el||' with '||sql%rowcount||' records'||get_time);
      end if;
      EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_dlog_el,instr(l_dlog_el,'.')+1,length(l_dlog_el)),
      substr(l_dlog_el,1,instr(l_dlog_el,'.')-1));
      if EDW_OWB_COLLECTION_UTIL.drop_table(g_dlog)=false then
        null;
      end if;
      g_dlog:=l_dlog_el;
    end if;
    if EDW_OWB_COLLECTION_UTIL.check_table_column(g_dlog,'row_id1') then
      l_rowid1_found:=true;
    else
      l_rowid1_found:=false;
    end if;
    --create dlog temp
    l_dlog:=g_dlog||'T';
    l_dlog_temp:=g_dlog||'TM';
    l_stmt:='create table '||l_dlog||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||' ';
    l_stmt:=l_stmt||' as select ';
    if g_parallel is not null then
      l_stmt:=l_stmt||'/*+PARALLEL ('||g_src_object_dlog||','||g_parallel||')*/ ';
    end if;
    if l_pk_key_found then
      l_stmt:=l_stmt||' rowid row_id from '||g_src_object_dlog||' where round=0';
    else
      l_stmt:=l_stmt||' rowid row_id from '||g_src_object_dlog;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_dlog)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created '||l_dlog||' with '||sql%rowcount||' records'||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_dlog,instr(l_dlog,'.')+1,length(l_dlog)),
     substr(l_dlog,1,instr(l_dlog,'.')-1));
    l_stmt:='create table '||l_dlog_temp||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||' ';
    l_stmt:=l_stmt||' as select row_id,0 status from '||l_dlog||' MINUS select row_id,0 status from '||g_dlog;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_dlog_temp)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created '||l_dlog_temp||' with '||sql%rowcount||' records'||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_dlog_temp,instr(l_dlog_temp,'.')+1,length(l_dlog_temp)),
    substr(l_dlog_temp,1,instr(l_dlog_temp,'.')-1));
    if l_rowid1_found then
      l_stmt:='insert into '||g_dlog||'(row_id,row_id1,status,pk_key,round) select ';
      if g_parallel is not null then
        l_stmt:=l_stmt||' /*+parallel(B,'||g_parallel||')*/ ';
      end if;
      l_stmt:=l_stmt||'A.row_id,B.row_id,A.status,';
      if l_pk_key_found then
        l_stmt:=l_stmt||'B.pk_key,B.round from '||l_dlog_temp||' A,'||g_src_object_dlog||' B where A.row_id=B.rowid';
      else
        l_stmt:=l_stmt||'0,0 from '||l_dlog_temp||' A,'||g_src_object_dlog||' B where A.row_id=B.rowid';
      end if;
    else
      l_stmt:='insert into '||g_dlog||'(row_id,status) select row_id,status  from '||l_dlog_temp;
    end if;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  begin
    EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Inserted '||g_dlog||' with '||sql%rowcount||' records'||get_time);
    end if;
    commit;
    if g_debug then
      write_to_log_file_n('commit');
    end if;
  exception when others then
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message);
    write_to_log_file('Error executing '||l_stmt);
    return false;
  end;
  if l_dlog_found  then
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_dlog)=false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_dlog_temp)=false then
      null;
    end if;
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_dlog,instr(g_dlog,'.')+1,length(g_dlog)),
  substr(g_dlog,1,instr(g_dlog,'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
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
function set_gilog_status return number is
l_stmt varchar2(10000);
l_count number;
L_ILOG_PREV varchar2(400);
Begin
  --update
  if g_debug then
    write_to_log_file_n('In set_gilog_status type='||g_type_ilog_generation);
  end if;
  --no need to explictly say parallel for g_ilog because its created with parallel option
  --(if the g_parallel option is not null of course
  if g_type_ilog_generation='UPDATE' then
    if g_collection_size =0 then
      l_stmt:='update '||g_ilog||' set status=1 where status=0';
    else
      l_stmt:='update '||g_ilog||' set status=1 where status=0 and rownum <='||g_collection_size;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
    execute immediate l_stmt;
    l_count:=sql%rowcount;
    if g_debug then
      write_to_log_file_n('Updated '||l_count||' rows in '||g_ilog||get_time);
    end if;
    commit;
    if g_debug then
      write_to_log_file_n('commit');
    end if;
  elsif g_type_ilog_generation='CTAS' then
    if g_ilog_prev is null then
      g_ilog_prev:=g_ilog;
      if substr(g_ilog,length(g_ilog),1)='A' then
        g_ilog:=substr(g_ilog,1,length(g_ilog)-1);
      else
        g_ilog:=g_ilog||'A';
      end if;
    else
      l_ilog_prev:=g_ilog_prev;
      g_ilog_prev:=g_ilog;
      g_ilog:=l_ilog_prev;
    end if;
    l_stmt:='create table '||g_ilog||' tablespace '||g_op_table_space;
    l_stmt:=l_stmt||' storage (initial 4M next 4M pctincrease 0) ';
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    if g_collection_size>0 then
      if g_src_snplog_has_pk then
        l_stmt:=l_stmt||' as select row_id,'||g_src_pk||',decode(status,1,2,2,2,decode(sign(rownum-'||
        g_collection_size||'),1,0,1)) status,round from (select row_id,'||g_src_pk||',status,round from '||
        g_ilog_prev||' order by status) abc ';
      else
        l_stmt:=l_stmt||' as select row_id,decode(status,1,2,2,2,decode(sign(rownum-'||
        g_collection_size||'),1,0,1)) status,round from (select row_id,status,round from '||
        g_ilog_prev||' order by status) abc ';
      end if;
    else
      if g_src_snplog_has_pk then
        l_stmt:=l_stmt||' as select row_id,'||g_src_pk||',decode(status,1,2,0,1,2) status,round from '||
        g_ilog_prev;
      else
        l_stmt:=l_stmt||' as select row_id,decode(status,1,2,0,1,2) status,round from '||
        g_ilog_prev;
      end if;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_ilog)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_ilog_prev)=false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_ilog,' status=1 ')<2 then
      l_count:=0;
    else
      l_count:=1;
    end if;
    if g_debug then
      write_to_log_file_n('Time'||get_time);
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
  return 0;
End;

/*
 this function sets the status of the dlog from 0 to 1 and also deletes those that are 1 first
 returns:
 0: error
 1: no more records to change from 0 to 1
 2: success
*/
function set_gdlog_status return number is
l_stmt varchar2(10000);
l_count number;
l_dlog_prev varchar2(200);
l_pk_key_found boolean;
Begin
  --update
  if g_debug then
    write_to_log_file_n('In set_gdlog_status type='||g_type_dlog_generation);
  end if;
  --no need to explictly say parallel for g_dlog because its created with parallel option
  --(if the g_parallel option is not null of course
  if g_type_dlog_generation='UPDATE' then
    if g_collection_size =0 then
      l_stmt:='update '||g_dlog||' set status=1 where status=0';
    else
      l_stmt:='update '||g_dlog||' set status=1 where status=0 and rownum <='||g_collection_size;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    l_count:=sql%rowcount;
    if g_debug then
      write_to_log_file_n('Updated '||l_count||' rows in '||g_dlog||get_time);
    end if;
    commit;
  elsif g_type_dlog_generation='CTAS' then
    if g_dlog_prev is null then
      g_dlog_prev:=g_dlog;
      if substr(g_dlog,length(g_dlog),1)='A' then
        g_dlog:=substr(g_dlog,1,length(g_dlog)-1);
      else
        g_dlog:=g_dlog||'A';
      end if;
    else
      l_dlog_prev:=g_dlog_prev;
      g_dlog_prev:=g_dlog;
      g_dlog:=l_dlog_prev;
    end if;
    l_pk_key_found:=EDW_OWB_COLLECTION_UTIL.check_table_column(g_dlog_prev,'pk_key');
    l_stmt:='create table '||g_dlog||' tablespace '||g_op_table_space;
    l_stmt:=l_stmt||' storage (initial 4M next 4M pctincrease 0) ';
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    if g_collection_size > 0 then
      if l_pk_key_found then
        l_stmt:=l_stmt||' as select row_id,decode(status,1,2,2,2,decode(sign(rownum-'||
        g_collection_size||'),1,0,1)) status,row_id1,pk_key,round from (select row_id,status,row_id1,pk_key,'||
        'round from '||g_dlog_prev||' order by status) abc ';
      else
        l_stmt:=l_stmt||' as select row_id,decode(status,1,2,2,2,decode(sign(rownum-'||
        g_collection_size||'),1,0,1)) status from (select row_id,status from '||g_dlog_prev||' order by status) abc ';
      end if;
    else
      if l_pk_key_found then
        l_stmt:=l_stmt||' as select row_id,decode(status,1,2,0,1,2) status,row_id1,pk_key,round from '||
        g_dlog_prev;
      else
        l_stmt:=l_stmt||' as select row_id,decode(status,1,2,0,1,2) status from '||
        g_dlog_prev;
      end if;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_dlog)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_dlog_prev)=false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_dlog,' status=1 ')<2 then
      l_count:=0;
    else
      l_count:=1;
    end if;
    if g_debug then
      write_to_log_file_n('Time'||get_time);
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
  return 0;
End;

function get_ilog_dlog return boolean is
l_ilog_desc varchar2(400);
l_dlog_desc varchar2(400);
begin
if g_debug then
  write_to_log_file_n('In get_ilog_dlog');
end if;
l_ilog_desc :='SNAPSHOT-LOG';
l_dlog_desc :='Delete Log';
g_src_object_ilog:=EDW_OWB_COLLECTION_UTIL.get_log_for_table(g_src_object,l_ilog_desc);
if g_src_object_ilog is null then
  null;
end if;
if g_fact_dlog is null then
  g_src_object_dlog:=EDW_OWB_COLLECTION_UTIL.get_log_for_table(g_src_object,l_dlog_desc);
else
  g_src_object_dlog:=g_fact_dlog;
end if;
if g_src_object_dlog is null then
  null;
end if;
if g_debug then
 write_to_log_file_n('ILog Table is '||g_src_object_ilog);
 write_to_log_file_n('DLog Table is '||g_src_object_dlog);
end if;
return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Exception in get_ilog_dlog '||sqlerrm||get_time);
  return false;
End;

function get_src_fks return boolean is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt varchar2(5000);
begin
  if EDW_OWB_COLLECTION_UTIL.get_ltc_fact_unique_key(g_src_object_id,null,g_src_uk,g_src_pk)=false then
    return false;
  end if;
  l_stmt:='select fk_item.column_name from edw_foreign_keys_md_v fk, '||
  'edw_pvt_key_columns_md_v isu,  '||
  'edw_pvt_columns_md_v fk_item  '||
  'where  '||
  'fk.entity_id=:s  '||
  'and isu.key_id=fk.foreign_key_id '||
  'and fk_item.column_id=isu.column_id';
  g_number_src_fks:=1;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using '||g_src_object_id);
  end if;
  open cv for l_stmt using g_src_object_id;
  loop
    fetch cv into g_src_fks(g_number_src_fks);
    exit when cv%notfound;
    g_number_src_fks:=g_number_src_fks+1;
  end loop;
  g_number_src_fks:=g_number_src_fks-1;
  if g_debug then
    write_to_log_file_n('The source fact fks, number '||g_number_src_fks);
    for i in 1..g_number_src_fks loop
      write_to_log_file(g_src_fks(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_src_fks '||sqlerrm||' '||get_time);
  return false;
End;

function get_mapping_details return boolean is
begin
  if EDW_OWB_COLLECTION_UTIL.get_derv_mapping_details(
    g_mapping_id,
    g_src_object_id,
    g_number_skip_cols,
    g_skip_cols,
    g_fact_fks,
    g_number_fact_fks,
    g_src_fks,
    g_number_src_fks,
    g_fact_id,
    g_src_object,
    g_temp_fact_name_temp,
    g_number_sec_sources,
    g_sec_sources,
    g_sec_sources_alias,
    g_number_sec_key,
    g_sec_sources_pk,
    g_sec_sources_fk,
    g_groupby_stmt,
    g_hold_number,
    g_number_group_by_cols,
    g_hold_relation,
    g_hold_item,
    g_group_by_cols,
    g_output_group_by_cols,
    g_number_input_params,
    g_output_params,
    g_input_params,
    g_filter_stmt)=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_mapping_details '||sqlerrm||' '||get_time);
  return false;
End;

function get_df_extra_fks return boolean is
l_found boolean;
Begin
  if g_debug then
    write_to_log_file_n('In get_df_extra_fks');
  end if;
  g_number_df_extra_fks:=0;
  for i in 1..g_number_fact_fks loop
    l_found:=false;
    for j in 1..g_number_input_params loop
      if g_output_params(j)=g_fact_fks(i) then
        l_found:=true;
        exit;
      end if;
    end loop;
    if l_found=false then
      g_number_df_extra_fks:=g_number_df_extra_fks+1;
      g_df_extra_fks(g_number_df_extra_fks):=g_fact_fks(i);
    end if;
  end loop;
  if g_debug then
    if g_number_df_extra_fks>0 then
      write_to_log_file_n('The extra keys obtained');
      for i in 1..g_number_df_extra_fks loop
        write_to_log_file(g_df_extra_fks(i));
      end loop;
    end if;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function make_data_into_temp(p_use_ordered_hint boolean) return boolean is
l_stmt varchar2(30000);
l_index number;
l_use_nl boolean;
l_ilog_count number;
begin
  l_stmt:='create table '||g_temp_fact_name||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' ';
  l_stmt:=l_stmt||' as select ';
  l_use_nl:=false;
  if g_temp_fact_name_temp=g_src_object then
    if g_src_object_count is null then
      g_src_object_count:=get_base_fact_count;
    end if;
    if g_skip_ilog=false and g_bu_src_fact is null then
      l_ilog_count:=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_ilog_small,g_bis_owner);
      l_use_nl:=EDW_OWB_COLLECTION_UTIL.get_join_nl(l_ilog_count,g_src_object_count,g_src_join_nl_percentage);
    else
      l_use_nl:=false;
    end if;
    if p_use_ordered_hint then
      if l_use_nl then
        l_stmt:=l_stmt||' /*+ORDERED USE_NL('||g_src_object||')*/ ';
      else
        l_stmt:=l_stmt||' /*+ORDERED */ ';
      end if;
    end if;
  end if;
  if g_skip_ilog or g_temp_fact_name_temp=g_src_object then
    if g_parallel is not null then
      l_stmt:=l_stmt||' /*+PARALLEL('||g_src_object||','||g_parallel||')*/ ';
    end if;
  end if;
  for i in 1..g_number_input_params loop
    l_stmt:=l_stmt||' '||g_input_params(i)||' '||g_output_params(i)||',';
  end loop;
  if g_number_df_extra_fks > 0 then
    for i in 1..g_number_df_extra_fks loop
      l_stmt:=l_stmt||' '||g_naedw_pk||' '||g_df_extra_fks(i)||',';
    end loop;
  end if;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  if g_skip_ilog=false then
    if g_bu_src_fact is not null then
      if g_temp_fact_name_temp=g_src_object then
        l_stmt:=l_stmt||' from '||g_ilog_small||','||g_bu_src_fact||' '||g_src_object;
      else
        l_stmt:=l_stmt||' from '||g_bu_src_fact||','||g_temp_fact_name_temp||' '||g_src_object;
      end if;
    else
      if g_temp_fact_name_temp=g_src_object then
        l_stmt:=l_stmt||' from '||g_ilog_small||','||g_src_object;
      else
        l_stmt:=l_stmt||' from '||g_temp_fact_name_temp||' '||g_src_object;
      end if;
    end if;
  else
    if g_bu_src_fact is not null then
      l_stmt:=l_stmt||' from '||g_bu_src_fact||' '||g_src_object;
    else
      l_stmt:=l_stmt||' from '||g_src_object;
    end if;
  end if;
  --add the secondary sources here
  if g_number_sec_sources > 0 then
    for i in 1..g_number_sec_sources loop
      if g_number_bu_tables>0 then
        l_index:=0;
        l_index:=EDW_OWB_COLLECTION_UTIL.index_in_table(g_bu_dimensions,g_number_bu_tables,g_sec_sources(i));
        if l_index > 0 then
          l_stmt:=l_stmt||','||g_bu_tables(l_index)||' '||g_sec_sources_alias(i);
        else
          l_stmt:=l_stmt||','||g_sec_sources(i)||' '||g_sec_sources_alias(i);
        end if;
      else
        l_stmt:=l_stmt||','||g_sec_sources(i)||' '||g_sec_sources_alias(i);
      end if;
    end loop;
  end if;
  if g_skip_ilog=false then
    if g_temp_fact_name_temp=g_src_object then
      l_stmt:=l_stmt||' where '||g_ilog_small||'.row_id='||g_src_object||'.rowid ';
    else
      l_stmt:=l_stmt||' where 1=1';
    end if;
  else
    l_stmt:=l_stmt||' where 1=1';
  end if;
  if g_number_sec_sources > 0 then
    for i in 1..g_number_sec_key loop
      l_stmt:=l_stmt||' and '||g_sec_sources_pk(i)||'='||g_sec_sources_fk(i);
    end loop;
  end if;
  if g_filter_stmt is not null then
    l_stmt:=l_stmt||' and '||g_filter_stmt;
  end if;
  --there is group by only when there are common keys
  if g_number_group_by_cols > 0 then
    l_stmt:=l_stmt||' group by ';
    for i in 1..g_number_group_by_cols loop
      l_stmt:=l_stmt||' '||g_group_by_cols(i)||',';
    end loop;
    l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  end if;
  g_data_temp_stmt:=l_stmt;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in make_data_into_temp '||sqlerrm||' '||get_time);
  return false;
End;

function execute_data_into_temp return number is
l_status number:=0;
l_divide number:=2;
l_stmt varchar2(32000);
l_use_nl boolean;
l_ilog_count number;
l_use_ordered_hint boolean;
Begin
  if g_debug then
    write_to_log_file_n('In execute_data_into_temp');
  end if;
  l_use_ordered_hint:=true;
  <<start_data_into_temp>>
  if g_skip_ilog=false then
    l_stmt:='create table '||g_ilog_small||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||' ';
    l_stmt:=l_stmt||' as select row_id from '||g_ilog||' where status=1';
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_ilog_small)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created '||g_ilog_small||' with '||sql%rowcount||' rows '||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_ilog_small,instr(g_ilog_small,'.')+1,
    length(g_ilog_small)),substr(g_ilog_small,1,instr(g_ilog_small,'.')-1));
    if g_number_sec_sources>0 then
      l_stmt:='create table '||g_temp_fact_name_temp||' tablespace '||g_op_table_space;
      if g_fact_next_extent is not null then
        if g_parallel is null then
          l_divide:=2;
        else
          l_divide:=g_parallel;
        end if;
        l_stmt:=l_stmt||' storage(initial '||g_fact_next_extent/2||' next '||
        (g_fact_next_extent/l_divide)||' pctincrease 0 MAXEXTENTS 2147483645) ';
      end if;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||' ';
      l_stmt:=l_stmt||' as select ';
      if g_src_object_count is null then
        g_src_object_count:=get_base_fact_count;
      end if;
      l_ilog_count:=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_ilog_small,g_bis_owner);
      l_use_nl:=EDW_OWB_COLLECTION_UTIL.get_join_nl(l_ilog_count,g_src_object_count,g_src_join_nl_percentage);
      if l_use_ordered_hint then
        if l_use_nl then
          l_stmt:=l_stmt||' /*+ORDERED USE_NL('||g_src_object||')*/ ';
        else
          l_stmt:=l_stmt||' /*+ORDERED */ ';
        end if;
      end if;
      if g_parallel is not null then
        l_stmt:=l_stmt||' /*+ PARALLEL('||g_src_object||','||g_parallel||')*/ ';
      end if;
      l_stmt:=l_stmt||g_src_object||'.* from '||g_ilog_small||','||g_src_object||' where '||
      g_ilog_small||'.row_id='||g_src_object||'.rowid';
      if EDW_OWB_COLLECTION_UTIL.drop_table(g_temp_fact_name_temp)=false then
        null;
      end if;
      if g_debug then
        write_to_log_file_n('Going to execute '||l_stmt||get_time);
      end if;
      begin
        execute immediate l_stmt;
      exception when others then
        write_to_log_file_n('Error '||sqlerrm||get_time);
        if sqlcode=-01410 then --invalid rowid error
          if l_use_ordered_hint then
            l_use_ordered_hint:=false;
            goto start_data_into_temp;
          else
            write_to_log_file_n('Unrecoverable invalid rowid error');
            raise;
          end if;
        end if;
      end;
      if g_debug then
        write_to_log_file_n('Created '||g_temp_fact_name_temp||' with '||sql%rowcount||' rows '||get_time);
      end if;
      EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_temp_fact_name_temp,instr(g_temp_fact_name_temp,'.')+1,
      length(g_temp_fact_name_temp)),substr(g_temp_fact_name_temp,1,instr(g_temp_fact_name_temp,'.')-1));
      if EDW_OWB_COLLECTION_UTIL.drop_table(g_ilog_small)=false then
        null;
      end if;
    end if;
  end if;--if g_skip_ilog=false then
  if make_data_into_temp(l_use_ordered_hint)=false then
    return 0;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_temp_fact_name)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||g_data_temp_stmt||get_time);
  end if;
  begin
    execute immediate g_data_temp_stmt;
    l_status:=sql%rowcount;
  exception when others then
    write_to_log_file_n('Error '||sqlerrm||get_time);
    if sqlcode=-01410 then --invalid rowid error
      if l_use_ordered_hint then
        l_use_ordered_hint:=false;
        goto start_data_into_temp;
      else
        write_to_log_file_n('Unrecoverable invalid rowid error');
        raise;
      end if;
    end if;
  end;
  if g_debug then
    write_to_log_file_n('Moved '||l_status||' rows into the temp table from the ILOG'||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_temp_fact_name,instr(g_temp_fact_name,'.')+1,
  length(g_temp_fact_name)),substr(g_temp_fact_name,1,instr(g_temp_fact_name,'.')-1));
  if g_skip_ilog=false then
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_ilog_small)=false then
      null;
    end if;
  end if;
  if g_src_object<>g_temp_fact_name_temp then
    if instr(g_temp_fact_name_temp,'.')<>0 then
      if EDW_OWB_COLLECTION_UTIL.drop_table(g_temp_fact_name_temp)=false then
        null;
      end if;
    end if;
  end if;
  if l_status>0 then
    return 2;
  else
    return 1;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in execute_data_into_temp '||sqlerrm||' '||get_time);
  return 0;
End;

function make_delete_data_into_temp return boolean is
l_stmt varchar2(30000);
l_index number;
begin
  if g_debug then
    write_to_log_file_n('In move_delete_data_into_temp');
  end if;
  l_stmt:='create table '||g_temp_fact_name||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' ';
  l_stmt:=l_stmt||' as select ';
  l_stmt:=l_stmt||' /*+ORDERED */ ';
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+ PARALLEL('||g_src_object||','||g_parallel||')*/ ';
  end if;
  for i in 1..g_number_input_params loop
    l_stmt:=l_stmt||' '||g_input_params(i)||' '||g_output_params(i)||',';
  end loop;
  if g_number_df_extra_fks > 0 then
    for i in 1..g_number_df_extra_fks loop
      l_stmt:=l_stmt||' '||g_naedw_pk||' '||g_df_extra_fks(i)||',';
    end loop;
  end if;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  if g_skip_ilog=false then
    if g_bu_src_fact is not null then
      l_stmt:=l_stmt||' from '||g_dlog_small||','||g_bu_src_fact||' '||g_src_object;
    else
      l_stmt:=l_stmt||' from '||g_dlog_small||','||g_src_object_dlog||' '||g_src_object;
    end if;
  else
    if g_bu_src_fact is not null then
      l_stmt:=l_stmt||' from '||g_bu_src_fact||' '||g_src_object;
    else
      l_stmt:=l_stmt||' from '||g_src_object_dlog||' '||g_src_object;
    end if;
  end if;
  --we need to alias g_src_object_dlog to g_src_object because g_input_params is all g_src_object.col
  --add the secondary sources here
  if g_number_sec_sources > 0 then
    for i in 1..g_number_sec_sources loop
      if g_number_bu_tables>0 then
        l_index:=0;
        l_index:=EDW_OWB_COLLECTION_UTIL.index_in_table(g_bu_dimensions,g_number_bu_tables,g_sec_sources(i));
        if l_index > 0 then
          l_stmt:=l_stmt||','||g_bu_tables(l_index)||' '||g_sec_sources_alias(i);
        else
          l_stmt:=l_stmt||','||g_sec_sources(i)||' '||g_sec_sources_alias(i);
        end if;
      else
        l_stmt:=l_stmt||','||g_sec_sources(i)||' '||g_sec_sources_alias(i);
      end if;
    end loop;
  end if;
  if g_skip_ilog=false then
    l_stmt:=l_stmt||' where '||g_dlog_small||'.row_id='||g_src_object||'.rowid ';
  else
    l_stmt:=l_stmt||' where 1=1';
  end if;
  if g_number_sec_sources > 0 then
    for i in 1..g_number_sec_key loop
      l_stmt:=l_stmt||' and '||g_sec_sources_pk(i)||'='||g_sec_sources_fk(i);
    end loop;
  end if;
  if g_filter_stmt is not null then
    l_stmt:=l_stmt||' and '||g_filter_stmt;
  end if;
  if g_number_group_by_cols > 0 then
    l_stmt:=l_stmt||' group by ';
    for i in 1..g_number_group_by_cols loop
      l_stmt:=l_stmt||' '||g_group_by_cols(i)||',';
    end loop;
    l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  end if;
  g_delete_data_temp_stmt:=l_stmt;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in make_delete_data_into_temp '||sqlerrm||' '||get_time);
  return false;
End;

function execute_delete_data_into_temp return number is
l_status number :=0;
l_stmt varchar2(8000);
Begin
  if g_debug then
    write_to_log_file_n('In execute_delete_data_into_temp');
  end if;
  if g_skip_ilog=false then
    l_stmt:='create table '||g_dlog_small||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||' ';
    l_stmt:=l_stmt||' as select row_id from '||g_dlog||' where status=1';
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_dlog_small)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created '||g_dlog_small||' with '||sql%rowcount||' rows '||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_dlog_small,instr(g_dlog_small,'.')+1,
    length(g_dlog_small)),substr(g_dlog_small,1,instr(g_dlog_small,'.')-1));
  end if;
  if make_delete_data_into_temp=false then
    return 0;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_temp_fact_name)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Goint to execute '||g_delete_data_temp_stmt);
  end if;
  execute immediate g_delete_data_temp_stmt;
  l_status:=sql%rowcount;
  if g_debug then
    write_to_log_file_n('Moved '||l_status||' rows into the temp table from the DLOG'||get_time);
  end if;
  commit;
  if g_debug then
    write_to_log_file_n('commit');
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_temp_fact_name,instr(g_temp_fact_name,'.')+1,
  length(g_temp_fact_name)),substr(g_temp_fact_name,1,instr(g_temp_fact_name,'.')-1));
  commit;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dlog_small)=false then
    null;
  end if;
  if l_status >0 then
    return 2;
  else
    return 1;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in execute_delete_data_into_temp '||sqlerrm||' '||get_time);
  return 0;
End;


function is_src_fk(p_fk varchar2) return boolean is
l_fk varchar2(400);
begin
  if g_debug then
    write_to_log_file_n('in is_src_fk,p_fk='||p_fk);
  end if;
  --if the fk is abc.xyz then parse the xyz out
  if instr(p_fk,'.') <> 0 then
    l_fk:=substr(p_fk,instr(p_fk,'.')+1,length(p_fk));
  else
    l_fk:=p_fk;
  end if;
  if g_debug then
    write_to_log_file('l_fk='||l_fk);
  end if;
  for i in 1..g_number_src_fks loop
    if l_fk=g_src_fks(i) then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in is_src_fk for '||p_fk||' '||sqlerrm||get_time);
  return false;
End;

function is_tgt_fk(p_fk varchar2) return boolean is
begin
  for i in 1..g_number_fact_fks loop
    if p_fk=g_fact_fks(i) then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in is_tgt_fk for '||p_fk||' '||sqlerrm||get_time);
  return false;
End;

function is_groupby_col (p_col varchar2) return boolean is
begin
  for i in 1..g_number_group_by_cols loop
    if p_col=g_output_group_by_cols(i) then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in is_groupby_col for '||p_col||' '||sqlerrm);
  return false;
End;

function is_input_groupby_col(p_col varchar2) return boolean is
begin
  for i in 1..g_number_group_by_cols loop
    if p_col=g_group_by_cols(i) then
      return true;
    end if;
  end loop;
  return false;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in is_input_groupby_col for '||p_col||' '||sqlerrm);
  return false;
End;

function make_delete_into_fact  return boolean is
l_last_update_date_flag boolean;
l_creation_date_flag  boolean;
Begin
  if g_debug then
    write_to_log_file_n('In make_delete_into_fact');
  end if;
 if EDW_OWB_COLLECTION_UTIL.value_in_table(g_output_params,
      g_number_input_params,'LAST_UPDATE_DATE')= false then
    l_last_update_date_flag:=true;
  else
    l_last_update_date_flag:=false;
  end if;
  if EDW_OWB_COLLECTION_UTIL.value_in_table(g_output_params,
      g_number_input_params,'CREATION_DATE')= false then
    l_creation_date_flag:=true;
  else
    l_creation_date_flag:=false;
  end if;
  if g_update_type='DELETE-INSERT' then
    g_delete_stmt:='insert into '||g_fact_name||' ( ';
    for i in 1..g_number_input_params loop
      g_delete_stmt:=g_delete_stmt||g_output_params(i)||',';
    end loop;
    if l_creation_date_flag then
      g_delete_stmt:=g_delete_stmt||'CREATION_DATE,';
    end if;
    if l_last_update_date_flag then
      g_delete_stmt:=g_delete_stmt||'LAST_UPDATE_DATE,';
    end if;
    g_delete_stmt:=substr(g_delete_stmt,1,length(g_delete_stmt)-1);
    g_delete_stmt:=g_delete_stmt||') select ';
    for i in 1..g_number_input_params loop
      g_delete_stmt:=g_delete_stmt||g_delete_rowid_table||'.'||g_output_params(i)||',';
    end loop;
    if l_creation_date_flag then
      g_delete_stmt:=g_delete_stmt||'SYSDATE,';
    end if;
    if l_last_update_date_flag then
      g_delete_stmt:=g_delete_stmt||'SYSDATE,';
    end if;
    g_delete_stmt:=substr(g_delete_stmt,1,length(g_delete_stmt)-1);
    g_delete_stmt:=g_delete_stmt||' from '||g_delete_rowid_table;
  else
    g_delete_stmt_row:='update '||g_fact_name||' set ( ';
    if g_update_type='ROW-BY-ROW' then
      g_delete_stmt:='update '||g_fact_name||' set ( ';
    elsif g_update_type='MASS' then
      if g_parallel is null then
        g_delete_stmt:='update /*+ ORDERED USE_NL('||g_fact_name||')*/ '||g_fact_name||' set ( ';
      else
        g_delete_stmt:='update /*+ ORDERED USE_NL('||g_fact_name||')*/ /*+ PARALLEL ('||g_fact_name||','||
        g_parallel||')*/  '||g_fact_name||' set ( ';
      end if;
    end if;
    for i in 1..g_number_input_params loop
      if g_fk_flag(i)=false and g_groupby_col_flag(i)=false  then
        g_delete_stmt:=g_delete_stmt||g_output_params(i)||',';
        g_delete_stmt_row:=g_delete_stmt_row||g_output_params(i)||',';
      end if;
    end loop;
    if EDW_OWB_COLLECTION_UTIL.value_in_table(g_output_params,
        g_number_input_params,'LAST_UPDATE_DATE')= false then
      l_last_update_date_flag:=true;
      g_delete_stmt:=g_delete_stmt||'LAST_UPDATE_DATE,';
      g_delete_stmt_row:=g_delete_stmt_row||'LAST_UPDATE_DATE,';
    else
      l_last_update_date_flag:=false;
    end if;
    g_delete_stmt:=substr(g_delete_stmt,1,length(g_delete_stmt)-1);
    g_delete_stmt_row:=substr(g_delete_stmt_row,1,length(g_delete_stmt_row)-1);
    g_delete_stmt:=g_delete_stmt||') = (select ';
    g_delete_stmt_row:=g_delete_stmt_row||') = (select ';
    for i in 1..g_number_input_params loop
      if g_fk_flag(i)=false and g_groupby_col_flag(i)=false  then
        --g_delete_stmt:=g_delete_stmt||' nvl('||g_fact_name||'.'||g_output_params(i)||',0)-nvl('||
          --  g_delete_rowid_table||'.'||g_output_params(i)||',0),';
       g_delete_stmt:=g_delete_stmt||' nvl('||g_fact_name||'.'||g_output_params(i)||',0)-'||
       g_delete_rowid_table||'.'||g_output_params(i)||',';
       g_delete_stmt_row:=g_delete_stmt_row||' nvl('||g_fact_name||'.'||g_output_params(i)||',0)-'||
       g_delete_rowid_table||'.'||g_output_params(i)||',';
      end if;
    end loop;
    if l_last_update_date_flag then
      g_delete_stmt:=g_delete_stmt||'SYSDATE,';
      g_delete_stmt_row:=g_delete_stmt_row||'SYSDATE,';
    end if;
    g_delete_stmt:=substr(g_delete_stmt,1,length(g_delete_stmt)-1);
    g_delete_stmt_row:=substr(g_delete_stmt_row,1,length(g_delete_stmt_row)-1);
    g_delete_stmt:=g_delete_stmt||' from '||g_delete_rowid_table||' where ';
    g_delete_stmt_row:=g_delete_stmt_row||' from '||g_delete_rowid_table||' where ';
    g_delete_stmt_row:=g_delete_stmt_row||g_delete_rowid_table||'.row_id1=:a) where '||g_fact_name||'.rowid=:b';
    if g_update_type='ROW-BY-ROW' then
      g_delete_stmt:=g_delete_stmt||g_delete_rowid_table||'.row_id1=:a) where '||g_fact_name||'.rowid=:b';
    elsif g_update_type='MASS' then
      g_delete_stmt:=g_delete_stmt||g_delete_rowid_table||'.row_id1='||g_fact_name||'.rowid ) where '||
      g_fact_name||'.rowid in (select row_id1 from '||g_delete_rowid_table||')';
    end if;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in make_delete_into_fact '||sqlerrm||' '||get_time);
  return false;
End;

function make_update_into_fact return boolean is
l_last_update_date_flag boolean;
l_creation_date_flag boolean;
Begin
  if g_debug then
    write_to_log_file_n('In make_update_into_fact');
  end if;
  if EDW_OWB_COLLECTION_UTIL.value_in_table(g_output_params,
      g_number_input_params,'LAST_UPDATE_DATE')= false then
    l_last_update_date_flag:=true;
  else
    l_last_update_date_flag:=false;
  end if;
  if EDW_OWB_COLLECTION_UTIL.value_in_table(g_output_params,
      g_number_input_params,'CREATION_DATE')= false then
    l_creation_date_flag:=true;
  else
    l_creation_date_flag:=false;
  end if;
  if g_update_type='DELETE-INSERT' then
    g_update_stmt:='insert into '||g_fact_name||' ( ';
    for i in 1..g_number_input_params loop
      g_update_stmt:=g_update_stmt||g_output_params(i)||',';
    end loop;
    if l_creation_date_flag then
      g_update_stmt:=g_update_stmt||'CREATION_DATE,';
    end if;
    if l_last_update_date_flag then
      g_update_stmt:=g_update_stmt||'LAST_UPDATE_DATE,';
    end if;
    g_update_stmt:=substr(g_update_stmt,1,length(g_update_stmt)-1);
    g_update_stmt:=g_update_stmt||') select ';
    for i in 1..g_number_input_params loop
      g_update_stmt:=g_update_stmt||g_update_rowid_table||'.'||g_output_params(i)||',';
    end loop;
    if l_creation_date_flag then
      g_update_stmt:=g_update_stmt||'SYSDATE,';
    end if;
    if l_last_update_date_flag then
      g_update_stmt:=g_update_stmt||'SYSDATE,';
    end if;
    g_update_stmt:=substr(g_update_stmt,1,length(g_update_stmt)-1);
    g_update_stmt:=g_update_stmt||' from '||g_update_rowid_table;
  else
    g_update_stmt_row:='update '||g_fact_name||' set ( ';
    if g_update_type='ROW-BY-ROW' then
      g_update_stmt:='update '||g_fact_name||' set ( ';
    elsif g_update_type='MASS' then
      if g_parallel is null then
        g_update_stmt:='update  /*+ ORDERED USE_NL('||g_fact_name||')*/ '||g_fact_name||' set ( ';
      else
        g_update_stmt:='update /*+ ORDERED USE_NL('||g_fact_name||')*/ /*+ PARALLEL ('||g_fact_name||','||
        g_parallel||')*/  '||g_fact_name||' set ( ';
      end if;
    end if;
    for i in 1..g_number_input_params loop
      if g_fk_flag(i)=false  and g_groupby_col_flag(i)=false then
        g_update_stmt:=g_update_stmt||g_output_params(i)||',';
        g_update_stmt_row:=g_update_stmt_row||g_output_params(i)||',';
      end if;
    end loop;
    if l_last_update_date_flag then
      g_update_stmt:=g_update_stmt||'LAST_UPDATE_DATE,';
      g_update_stmt_row:=g_update_stmt_row||'LAST_UPDATE_DATE,';
    end if;
    g_update_stmt:=substr(g_update_stmt,1,length(g_update_stmt)-1);
    g_update_stmt_row:=substr(g_update_stmt_row,1,length(g_update_stmt_row)-1);
    g_update_stmt:=g_update_stmt||') = (select ';
    g_update_stmt_row:=g_update_stmt_row||') = (select ';
    for i in 1..g_number_input_params loop
      if g_fk_flag(i)=false  and g_groupby_col_flag(i)=false then
        g_update_stmt:=g_update_stmt||' nvl('||g_fact_name||'.'||g_output_params(i)||',0)+'||
        g_update_rowid_table||'.'||g_output_params(i)||',';
        g_update_stmt_row:=g_update_stmt_row||' nvl('||g_fact_name||'.'||g_output_params(i)||',0)+'||
        g_update_rowid_table||'.'||g_output_params(i)||',';
      end if;
    end loop;
    if l_last_update_date_flag then
      g_update_stmt:=g_update_stmt||'SYSDATE,';
      g_update_stmt_row:=g_update_stmt_row||'SYSDATE,';
    end if;
    g_update_stmt:=substr(g_update_stmt,1,length(g_update_stmt)-1);
    g_update_stmt_row:=substr(g_update_stmt_row,1,length(g_update_stmt_row)-1);
    g_update_stmt:=g_update_stmt||' from '||g_update_rowid_table||' where ';
    g_update_stmt_row:=g_update_stmt_row||' from '||g_update_rowid_table||' where ';
    g_update_stmt_row:=g_update_stmt_row||g_update_rowid_table||'.row_id1=:a) where '||g_fact_name||'.rowid=:b';
    if g_update_type='ROW-BY-ROW' then
      g_update_stmt:=g_update_stmt||g_update_rowid_table||'.row_id1=:a) where '||g_fact_name||'.rowid=:b';
    elsif g_update_type='MASS' then
      g_update_stmt:=g_update_stmt||g_update_rowid_table||'.row_id1='||g_fact_name||'.rowid ) where '||
      g_fact_name||'.rowid in (select row_id1 from '||g_update_rowid_table||')';
    end if;
  end if;
  /*
  if g_debug then
    write_to_log_file_n('g_update_stmt is '||g_update_stmt);
  end if;*/
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in make_update_into_fact '||sqlerrm||' '||get_time);
  return false;
End;


function make_insert_into_fact return boolean is
l_creation_date_flag boolean;
l_last_update_date_flag boolean;
Begin
  if g_debug then
    write_to_log_file_n('In make_insert_into_fact');
  end if;
  if g_parallel is null then
    g_insert_stmt:='insert into '||g_fact_name||'(';
  else
    g_insert_stmt:='insert /*+ PARALLEL ('||g_fact_name||','||g_parallel||')*/ into '||g_fact_name||'(';
  end if;
  for i in 1..g_number_input_params loop
    g_insert_stmt:=g_insert_stmt||' '||g_output_params(i)||',';
  end loop;
  if g_number_df_extra_fks > 0 then
    for i in 1..g_number_df_extra_fks loop
     g_insert_stmt:=g_insert_stmt||' '||g_df_extra_fks(i)||',';
    end loop;
  end if;
  if EDW_OWB_COLLECTION_UTIL.value_in_table(g_output_params,
      g_number_input_params,'CREATION_DATE')= false then
    l_creation_date_flag:=true;
    g_insert_stmt:=g_insert_stmt||'CREATION_DATE,';
  else
    l_creation_date_flag:=false;
  end if;
  if EDW_OWB_COLLECTION_UTIL.value_in_table(g_output_params,
      g_number_input_params,'LAST_UPDATE_DATE')= false then
    l_last_update_date_flag:=true;
    g_insert_stmt:=g_insert_stmt||'LAST_UPDATE_DATE,';
  else
    l_last_update_date_flag:=false;
  end if;
  g_insert_stmt:=substr(g_insert_stmt,1,length(g_insert_stmt)-1);
  g_insert_stmt:=g_insert_stmt||' ) select /*+ORDERED */ ';
  for i in 1..g_number_input_params loop
    g_insert_stmt:=g_insert_stmt||' '||g_output_params(i)||',';
  end loop;
  if g_number_df_extra_fks > 0 then
    for i in 1..g_number_df_extra_fks loop
     g_insert_stmt:=g_insert_stmt||' '||g_df_extra_fks(i)||',';
    end loop;
  end if;
  if l_creation_date_flag then
    g_insert_stmt:=g_insert_stmt||'SYSDATE,';
  end if;
  if l_last_update_date_flag then
    g_insert_stmt:=g_insert_stmt||'SYSDATE,';
  end if;
  g_insert_stmt:=substr(g_insert_stmt,1,length(g_insert_stmt)-1);
  g_insert_stmt:=g_insert_stmt||' from '||g_insert_rowid_table||','||g_temp_fact_name||
  ' where '||g_temp_fact_name||'.rowid='||g_insert_rowid_table||'.row_id';
  /*
  if g_debug then
    write_to_log_file('The statement to insert into the IV');
    write_to_log_file_n(g_insert_stmt);
  end if;*/
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in make_insert_into_fact '||sqlerrm||' '||get_time);
  return false;
End;

function delete_into_fact return boolean is
l_stmt varchar2(5000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_rowid EDW_OWB_COLLECTION_UTIL.rowidTableType;
l_count number;
l_total_count number:=0;
l_update_type varchar2(400);
begin
  if g_debug then
    write_to_log_file_n('In delete_into_fact');
  end if;
  l_update_type:=g_update_type;
  <<start_delete>>
  if l_update_type='ROW-BY-ROW' then
    l_stmt:='select row_id1 from '||g_delete_rowid_table;
    if g_debug then
      write_to_log_file_n('Goint to execute '||l_stmt);
    end if;
    if g_debug then
      write_to_log_file('Going to execute '||g_delete_stmt_row||get_time);
    end if;
    l_count:=1;
    open cv for l_stmt;
    loop
      fetch cv into l_rowid(l_count);
      exit when cv%notfound;
      if l_count>=g_forall_size then
        for i in 1..l_count loop
          execute immediate g_delete_stmt_row using l_rowid(i),l_rowid(i);
        end loop;
        l_total_count:=l_total_count+l_count;
        l_count:=1;
        commit;
      else
        l_count:=l_count+1;
      end if;
    end loop;
    close cv;
    l_count:=l_count-1;
    if l_count>0 then
      for i in 1..l_count loop
        execute immediate g_delete_stmt_row using l_rowid(i),l_rowid(i);
      end loop;
      l_total_count:=l_total_count+l_count;
    end if;
  elsif l_update_type='MASS' then
    begin
      if g_debug then
        write_to_log_file_n('Going to execute '||g_delete_stmt||get_time);
      end if;
      EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
      execute immediate g_delete_stmt;
      l_total_count:=sql%rowcount;
    exception when others then
      if sqlcode=-4030 then
        commit;--release any rollback
        --if there is a out NOCOPY of memory issue, retry an update using row by row
        if g_debug then
          write_to_log_file_n('Memory issue with Mass Update. Retrying using ROW_BY_ROW');
        end if;
        l_update_type:='ROW-BY-ROW';
        goto start_delete;
      elsif sqlcode=-00060 then
        if g_debug then
          write_to_log_file_n('Deadlock detected. Try again after sleep');
        end if;
        DBMS_LOCK.SLEEP(g_sleep_time);
        goto start_delete;
      else
        g_status_message:=sqlerrm;
        write_to_log_file_n(g_status_message);
        write_to_log_file('Problem stmt '||g_delete_stmt);
        return false;
      end if;
    end ;
  elsif l_update_type='DELETE-INSERT' then
    l_stmt:='delete '||g_fact_name||' where exists (select 1 from '||g_delete_rowid_table||' where '||
    g_delete_rowid_table||'.row_id1='||g_fact_name||'.rowid)';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    begin
      EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file('Deleted '||sql%rowcount||' rows'||get_time);
      end if;
    exception when others then
      g_status_message:=sqlerrm;
      write_to_log_file_n(g_status_message);
      write_to_log_file('Problem stmt '||l_stmt);
      return false;
    end ;
    begin
      if g_debug then
        write_to_log_file_n('Going to execute '||g_delete_stmt||get_time);
      end if;
      EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
      execute immediate g_delete_stmt;--this is actually an insert
      l_total_count:=sql%rowcount;
    exception when others then
      g_status_message:=sqlerrm;
      write_to_log_file_n(g_status_message);
      write_to_log_file('Problem stmt '||g_delete_stmt);
      return false;
    end ;
  end if;
  if g_debug then
    write_to_log_file(get_time);
  end if;
  if make_delete_prot_log=false then --this is the commit
    write_to_log_file_n('make_delete_prot_log returned with error');
    rollback;
    return false;
  end if;
  g_ins_rows_processed:=nvl(g_ins_rows_processed,0)+l_total_count;
  g_total_delete:=nvl(g_total_delete,0)+l_total_count;
  if g_debug then
    write_to_log_file_n('Number of rows updated for delete in the fact '||l_total_count);
    write_to_log_file('Number of rows Processed So Far into the fact '||g_ins_rows_processed);
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in delete_into_fact '||sqlerrm||' '||get_time);
  return false;
End;

function update_into_fact return boolean is
l_stmt varchar2(5000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_rowid EDW_OWB_COLLECTION_UTIL.rowidTableType;
l_count number;
l_total_count number:=0;
l_update_type varchar2(400);
begin
  if g_debug then
    write_to_log_file_n('In update_into_fact');
  end if;
  l_update_type:=g_update_type;
  <<start_update>>
  if l_update_type='ROW-BY-ROW' then
    l_stmt:='select row_id1 from '||g_update_rowid_table;
    if g_debug then
      write_to_log_file_n('Goint to execute '||l_stmt);
    end if;
    if g_debug then
      write_to_log_file_n('Goint to execute '||g_update_stmt_row||get_time);
    end if;
    l_count:=1;
    open cv for l_stmt;
    loop
      fetch cv into l_rowid(l_count);
      exit when cv%notfound;
      if l_count>=g_forall_size then
        for i in 1..l_count loop
          execute immediate g_update_stmt_row using l_rowid(i),l_rowid(i);
        end loop;
        l_total_count:=l_total_count+l_count;
        l_count:=1;
        commit;
      else
        l_count:=l_count+1;
      end if;
    end loop;
    close cv;
    l_count:=l_count-1;
    if l_count>0 then
      for i in 1..l_count loop
        execute immediate g_update_stmt_row using l_rowid(i),l_rowid(i);
      end loop;
      l_total_count:=l_total_count+l_count;
    end if;
  elsif g_update_type='MASS' then
    begin
      if g_debug then
        write_to_log_file('Going to execute '||g_update_stmt);
        write_to_log_file(get_time);
      end if;
      EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
      execute immediate g_update_stmt;
      l_total_count:=sql%rowcount;
    exception when others then
      if sqlcode=-4030 then
        commit;--release any rollback
        --if there is a out NOCOPY of memory issue, retry an update using row by row
        write_to_log_file_n('Memory issue with Mass Update. Retrying using ROW_BY_ROW');
        l_update_type:='ROW-BY-ROW';
        goto start_update;
      elsif sqlcode=-00060 then
        if g_debug then
          write_to_log_file_n('Deadlock detected. Try again after sleep');
        end if;
        DBMS_LOCK.SLEEP(g_sleep_time);
        goto start_update;
      else
        g_status_message:=sqlerrm;
        write_to_log_file_n(g_status_message);
        write_to_log_file('Problem stmt '||g_update_stmt);
        return false;
      end if;
    end ;
  elsif g_update_type='DELETE-INSERT' then
    l_stmt:='delete '||g_fact_name||' where exists (select 1 from '||g_update_rowid_table||' where '||
    g_update_rowid_table||'.row_id1='||g_fact_name||'.rowid)';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt);
    end if;
    begin
      EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file('Deleted '||sql%rowcount||' rows');
      end if;
    exception when others then
      g_status_message:=sqlerrm;
      write_to_log_file_n(g_status_message);
      write_to_log_file('Problem stmt '||l_stmt);
      return false;
    end ;
    begin
      if g_debug then
        write_to_log_file('Going to execute '||g_update_stmt);
      end if;
      EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
      execute immediate g_update_stmt;--this is actually an insert
      l_total_count:=sql%rowcount;
    exception when others then
      g_status_message:=sqlerrm;
      write_to_log_file_n(g_status_message);
      write_to_log_file('Problem stmt '||g_update_stmt);
      return false;
    end ;
  end if;
  if g_debug then
    write_to_log_file(get_time);
  end if;
  if make_update_prot_log=false then --this is the commit
    write_to_log_file_n('make_update_prot_log returned with error');
    rollback;
    return false;
  end if;
  g_ins_rows_processed:=nvl(g_ins_rows_processed,0)+l_total_count;
  g_total_update:=nvl(g_total_update,0)+l_total_count;
  if g_debug then
    write_to_log_file_n('Number of rows updated in the fact '||l_total_count);
    write_to_log_file('Number of rows Processed So Far into the fact '||g_ins_rows_processed);
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in update_into_fact '||sqlerrm||' '||get_time);
  return false;
End;

function insert_into_fact return boolean is
l_count number;
begin
  if g_debug then
    write_to_log_file_n('In insert_into_fact');
  end if;
  if g_debug then
    write_to_log_file('Going to execute '||g_insert_stmt);
    write_to_log_file(get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
  execute immediate g_insert_stmt;
  l_count:=sql%rowcount;
  if g_debug then
    write_to_log_file(get_time);
  end if;
  if make_insert_prot_log=false then --this is the commit!!
    write_to_log_file_n('make_insert_prot_log returned with error');
    rollback;
    return false;
  end if;
  g_ins_rows_processed:=nvl(g_ins_rows_processed,0)+l_count;
  g_total_insert:=nvl(g_total_insert,0)+l_count;
  if g_debug then
    write_to_log_file_n('Number of rows moved into the fact '||l_count);
    write_to_log_file('Number of rows Processed So Far into the fact '||g_ins_rows_processed);
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in insert_into_fact '||sqlerrm||' '||get_time);
  return false;
End;

procedure clean_up is
l_table_owner varchar2(400);
l_date date;
l_analyze boolean:=false;
l_diff number;
l_target_rec_count number;
Begin
  l_table_owner:=EDW_OWB_COLLECTION_UTIL.get_table_owner(g_fact_name);
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_temp_fact_name)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_insert_rowid_table)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_update_rowid_table)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_delete_rowid_table)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_summarize_temp2)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_summarize_temp3)=false then
    null;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
End;

function update_log_status_0(p_log varchar2) return boolean is
l_stmt varchar2(2000);
Begin
  if g_debug then
    write_to_log_file_n('In update_ilog_status_2');
  end if;
  l_stmt:='update '||p_log||' set status=0 where status=1';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
  execute immediate l_stmt;
  commit;
  if g_debug then
    write_to_log_file_n('commit');
  end if;
  if g_debug then
    write_to_log_file_n('Updated '||sql%rowcount||' rows in '||p_log||' from status 1 to status 0'||get_time);
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function update_ilog_status_2 return boolean is
l_stmt varchar2(2000);
Begin
  if g_debug then
    write_to_log_file_n('In update_ilog_status_2');
  end if;
  l_stmt:='update '||g_ilog||' set status=2 where status=1';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
  execute immediate l_stmt;
  commit;
  if g_debug then
    write_to_log_file_n('Updated '||sql%rowcount||' rows in '||g_ilog||' from status 1 to status 2'||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_ilog,instr(g_ilog,'.')+1,
  length(g_ilog)),substr(g_ilog,1,instr(g_ilog,'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function update_dlog_status_2 return boolean is
l_stmt varchar2(2000);
Begin
  if g_debug then
    write_to_log_file_n('In update_dlog_status_2');
  end if;
  l_stmt:='update '||g_dlog||' set status=2 where status=1';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
  execute immediate l_stmt;
  commit;
  if g_debug then
    write_to_log_file_n('Updated '||sql%rowcount||' rows in '||g_dlog||' from status 1 to status 2'||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_dlog,instr(g_dlog,'.')+1,
  length(g_dlog)),substr(g_dlog,1,instr(g_dlog,'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function delete_rowid_table_stmt return boolean is
l_divide number:=2;
l_table_owner varchar2(200);
l_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_data_type EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_cols number;
l_index number;
Begin
  if g_debug then
    write_to_log_file_n('In delete_rowid_table_stmt');
  end if;
  if EDW_OWB_COLLECTION_UTIL.get_db_columns_for_table(g_fact_name,l_cols,l_data_type,
    l_number_cols,g_df_table_owner)=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    return false;
  end if;
  g_delete_rowid_stmt:='create table '||g_delete_rowid_table||' tablespace '||g_op_table_space;
  if g_fact_next_extent is not null then
    if g_parallel is null then
      l_divide:=2;
    else
      l_divide:=g_parallel;
    end if;
    g_delete_rowid_stmt:=g_delete_rowid_stmt||' storage(initial '||g_fact_next_extent/2||' next '||
   (g_fact_next_extent/l_divide)||' pctincrease 0 MAXEXTENTS 2147483645) ';
  end if;
  if g_parallel is not null then
    g_delete_rowid_stmt:=g_delete_rowid_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  g_delete_rowid_stmt:=g_delete_rowid_stmt||' ';
  g_delete_rowid_stmt:=g_delete_rowid_stmt||' as select /*+ ORDERED */ ';
  if g_update_type='DELETE-INSERT' then
    for i in 1..g_number_input_params loop
      if g_fk_flag(i)=false and g_groupby_col_flag(i)=false  then
        g_delete_rowid_stmt:=g_delete_rowid_stmt||'nvl('||g_fact_name||'.'||g_output_params(i)||',0)-nvl('||
          g_temp_fact_name||'.'||g_output_params(i)||',0) '||g_output_params(i)||',';
      else
        g_delete_rowid_stmt:=g_delete_rowid_stmt||g_temp_fact_name||'.'||g_output_params(i)||' '||
          g_output_params(i)||',';
      end if;
    end loop;
  else
    for i in 1..g_number_input_params loop
      if g_fk_flag(i)=false and g_groupby_col_flag(i)=false then
        g_delete_rowid_stmt:=g_delete_rowid_stmt||' nvl('||g_temp_fact_name||'.'||g_output_params(i)||',0) '||
        g_output_params(i)||',';
      end if;
    end loop;
  end if;
  if g_update_type='DELETE-INSERT' then
    g_delete_rowid_stmt:=g_delete_rowid_stmt||g_fact_name||'.rowid row_id1,'||
    g_fact_name||'.CREATION_DATE CREATION_DATE from '||g_temp_fact_name||','||g_fact_name||' where ';
  else
    g_delete_rowid_stmt:=g_delete_rowid_stmt||g_fact_name||'.rowid row_id1 from '||g_temp_fact_name||','||
    g_fact_name||' where ';
  end if;
  /*
  in the where clause, if we use nvl(...), we lose index use
  so for fk, we dont use nvl . this is because. fk cannot be null  and the index
  is on the fks.
  */
  if g_number_group_by_cols > 0 then
    for i in 1..g_number_group_by_cols loop
      l_index:=0;
      l_index:=EDW_OWB_COLLECTION_UTIL.index_in_table(g_fact_fks,g_number_fact_fks,g_output_group_by_cols(i));
      if l_index>0 then --if this is a fk
        g_delete_rowid_stmt:=g_delete_rowid_stmt||' '||g_fact_name||'.'||g_output_group_by_cols(i)||'='||
          g_temp_fact_name||'.'||g_output_group_by_cols(i)||' and ';
      else
        l_index:=EDW_OWB_COLLECTION_UTIL.index_in_table(l_cols,l_number_cols,upper(g_output_group_by_cols(i)));
        if l_index >0 then
          if l_data_type(l_index) like '%CHAR%' or l_data_type(l_index) ='NUMBER' or
            l_data_type(l_index) ='LONG' or l_data_type(l_index) ='RAW' or l_data_type(l_index) ='LONG RAW' then
            g_delete_rowid_stmt:=g_delete_rowid_stmt||' nvl('||g_fact_name||'.'||g_output_group_by_cols(i)||',0)=nvl('||
            g_temp_fact_name||'.'||g_output_group_by_cols(i)||',0) and ';
          elsif l_data_type(l_index) ='DATE' then
            g_delete_rowid_stmt:=g_delete_rowid_stmt||' nvl('||g_fact_name||'.'||g_output_group_by_cols(i)||
            ',sysdate)=nvl('||g_temp_fact_name||'.'||g_output_group_by_cols(i)||',sysdate) and ';
          else
            g_delete_rowid_stmt:=g_delete_rowid_stmt||' '||g_fact_name||'.'||g_output_group_by_cols(i)||'='||
            g_temp_fact_name||'.'||g_output_group_by_cols(i)||' and ';
          end if;
        else
          g_delete_rowid_stmt:=g_delete_rowid_stmt||' '||g_fact_name||'.'||g_output_group_by_cols(i)||'='||
          g_temp_fact_name||'.'||g_output_group_by_cols(i)||' and ';
        end if;
      end if;
    end loop;
    g_delete_rowid_stmt:=substr(g_delete_rowid_stmt,1,length(g_delete_rowid_stmt)-4);
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function update_rowid_table_stmt return boolean is
l_divide number:=2;
l_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_data_type EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_cols number;
l_index number;
Begin
  if g_debug then
    write_to_log_file_n('In update_rowid_table_stmt');
  end if;
  if EDW_OWB_COLLECTION_UTIL.get_db_columns_for_table(g_fact_name,l_cols,l_data_type,
    l_number_cols,g_df_table_owner)=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    return false;
  end if;
  g_update_rowid_stmt:='create table '||g_update_rowid_table||' tablespace '||g_op_table_space;
  if g_fact_next_extent is not null then
    if g_parallel is null then
      l_divide:=2;
    else
      l_divide:=g_parallel;
    end if;
    g_update_rowid_stmt:=g_update_rowid_stmt||' storage(initial '||g_fact_next_extent/2||' next '||
   (g_fact_next_extent/l_divide)||' pctincrease 0 MAXEXTENTS 2147483645) ';
  end if;
  if g_parallel is not null then
    g_update_rowid_stmt:=g_update_rowid_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  g_update_rowid_stmt:=g_update_rowid_stmt||' ';
  g_update_rowid_stmt:=g_update_rowid_stmt||' as select /*+ ORDERED */ ';
  if g_update_type='DELETE-INSERT' then
    for i in 1..g_number_input_params loop
      if g_fk_flag(i)=false and g_groupby_col_flag(i)=false then
        g_update_rowid_stmt:=g_update_rowid_stmt||' nvl('||g_fact_name||'.'||g_output_params(i)||',0)+nvl('||
          g_temp_fact_name||'.'||g_output_params(i)||',0) '||g_output_params(i)||',';
      else --we need the keys also in this update mode for inserts
        g_update_rowid_stmt:=g_update_rowid_stmt||g_temp_fact_name||'.'||g_output_params(i)||' '||
          g_output_params(i)||',';
      end if;
    end loop;
  else
    for i in 1..g_number_input_params loop
      if g_fk_flag(i)=false and g_groupby_col_flag(i)=false then
        g_update_rowid_stmt:=g_update_rowid_stmt||' nvl('||g_temp_fact_name||'.'||g_output_params(i)||',0) '||
        g_output_params(i)||',';
      end if;
    end loop;
  end if;
  if g_update_type='DELETE-INSERT' then
    g_update_rowid_stmt:=g_update_rowid_stmt||g_fact_name||'.rowid row_id1,'||
    g_fact_name||'.CREATION_DATE CREATION_DATE from '||g_temp_fact_name||','||g_fact_name||' where ';
  else
    g_update_rowid_stmt:=g_update_rowid_stmt||g_fact_name||'.rowid row_id1,'||g_temp_fact_name||'.rowid row_id '||
    ' from '||g_temp_fact_name||','||g_fact_name||' where ';
  end if;
  /*
  in the where clause, if we use nvl(...), we lose index use
  so for fk, we dont use nvl . this is because. fk cannot be null  and the index
  is on the fks.
  */
  if g_number_group_by_cols > 0 then
    for i in 1..g_number_group_by_cols loop
      l_index:=0;
      l_index:=EDW_OWB_COLLECTION_UTIL.index_in_table(g_fact_fks,g_number_fact_fks,g_output_group_by_cols(i));
      if l_index>0 then --if this is a fk
        g_update_rowid_stmt:=g_update_rowid_stmt||' '||g_fact_name||'.'||g_output_group_by_cols(i)||'='||
        g_temp_fact_name||'.'||g_output_group_by_cols(i)||' and ';
      else
        l_index:=EDW_OWB_COLLECTION_UTIL.index_in_table(l_cols,l_number_cols,upper(g_output_group_by_cols(i)));
        if l_index >0  then
          if l_data_type(l_index) like '%CHAR%' or l_data_type(l_index) ='NUMBER' or
            l_data_type(l_index) ='LONG' or l_data_type(l_index) ='RAW' or l_data_type(l_index) ='LONG RAW' then
            g_update_rowid_stmt:=g_update_rowid_stmt||' nvl('||g_fact_name||'.'||g_output_group_by_cols(i)||',0)=nvl('||
            g_temp_fact_name||'.'||g_output_group_by_cols(i)||',0) and ';
          elsif l_data_type(l_index) ='DATE' then
            g_update_rowid_stmt:=g_update_rowid_stmt||' nvl('||g_fact_name||'.'||g_output_group_by_cols(i)||
            ',sysdate)=nvl('||g_temp_fact_name||'.'||g_output_group_by_cols(i)||',sysdate) and ';
          else
            g_update_rowid_stmt:=g_update_rowid_stmt||' '||g_fact_name||'.'||g_output_group_by_cols(i)||'='||
            g_temp_fact_name||'.'||g_output_group_by_cols(i)||' and ';
          end if;
        else
          g_update_rowid_stmt:=g_update_rowid_stmt||' '||g_fact_name||'.'||g_output_group_by_cols(i)||'='||
          g_temp_fact_name||'.'||g_output_group_by_cols(i)||' and ';
        end if;
      end if;
    end loop;
    g_update_rowid_stmt:=substr(g_update_rowid_stmt,1,length(g_update_rowid_stmt)-4);
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function insert_rowid_table_stmt return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In insert_rowid_table_stmt');
  end if;
  g_insert_rowid_stmt:='create table '||g_insert_rowid_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    g_insert_rowid_stmt:=g_insert_rowid_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  g_insert_rowid_stmt:=g_insert_rowid_stmt||' ';
  g_insert_rowid_stmt:=g_insert_rowid_stmt||' as select rowid row_id from '||
     g_temp_fact_name||' MINUS select row_id row_id from '||g_update_rowid_table||'  ';
  /*
  if g_debug then
    write_to_log_file_n('g_insert_rowid_stmt is '||g_insert_rowid_stmt);
  end if;*/
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function execute_ddata_into_rowid_table return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In execute_ddata_into_rowid_table');
  end if;
  begin
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_delete_rowid_table) = false then
      write_to_log_file_n('Table '||g_delete_rowid_table||' not found for dropping');
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||g_delete_rowid_stmt||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
    execute immediate g_delete_rowid_stmt;
    if g_debug then
      write_to_log_file_n('Moved '||sql%rowcount||' rows into the delete rowid table');
    end if;
  exception when others then
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message);
    return false;
  end;
  if create_index_drowid_table = false then
    write_to_log_file_n('create_index_drowid_table returned with error');
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;


function execute_data_into_rowid_table return boolean is
l_stmt varchar2(4000);
l_count number;
Begin
  if g_debug then
    write_to_log_file_n('In execute_data_into_rowid_table');
  end if;
  --create the insert lock table
  if create_insert_lock_table=false then
    return false;
  end if;
  begin
    --drop the update rowid table first
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_update_rowid_table) = false then
      write_to_log_file_n('Table '||g_update_rowid_table||' not found for dropping');
    end if;
    if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_fact_name)=1 then
      l_stmt:='create table '||g_update_rowid_table||'(row_id rowid,row_id1 rowid)'||
      ' tablespace '||g_op_table_space;
      if g_debug then
        write_to_log_file_n('Going to execute '||l_stmt||get_time);
      end if;
      execute immediate l_stmt;
    else
      if g_debug then
        write_to_log_file_n('Going to execute '||g_update_rowid_stmt||get_time);
      end if;
      EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
      execute immediate g_update_rowid_stmt;
      if g_debug then
        write_to_log_file_n('Moved '||sql%rowcount||' rows into the update rowid table');
      end if;
    end if;
  exception when others then
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message);
    return false;
  end;
  begin
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_insert_rowid_table) = false then
      write_to_log_file_n('Table '||g_insert_rowid_table||' not found for dropping');
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||g_insert_rowid_stmt);
    end if;
    EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
    execute immediate g_insert_rowid_stmt;
    l_count:=sql%rowcount;
    if g_debug then
      write_to_log_file_n('Moved '||l_count||' rows into the insert rowid table');
    end if;
  exception when others then
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message);
    return false;
  end;
  if l_count=0 then --then there is no need to keep this table as a lock as there are going to be no inserts
    if drop_insert_lock_table=false then
      return false;
    end if;
  end if;
  if create_index_rowid_table = false then
    write_to_log_file_n('create_index_rowid_table returned with error');
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function create_index_drowid_table return boolean is
l_stmt varchar2(2000);
Begin
  if g_debug then
    write_to_log_file_n('In create_index_drowid_table');
  end if;
  l_stmt:='create unique index '||g_delete_rowid_table||'u1 on '||g_delete_rowid_table||'(row_id1) '||
  ' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel '||g_parallel;
  end if;
  if g_debug then
    write_to_log_file('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_delete_rowid_table,instr(g_delete_rowid_table,'.')+1,
  length(g_delete_rowid_table)),substr(g_delete_rowid_table,1,instr(g_delete_rowid_table,'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  write_to_log_file('problem statement '||l_stmt);
  return false;
End;

function create_index_rowid_table return boolean is
l_stmt varchar2(2000);
Begin
  if g_debug then
    write_to_log_file_n('In create_index_rowid_table');
  end if;
  l_stmt:='create unique index '||g_update_rowid_table||'u1 on '||g_update_rowid_table||'(row_id1) '||
  ' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel '||g_parallel;
  end if;
  if g_debug then
    write_to_log_file('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_insert_rowid_table,instr(g_insert_rowid_table,'.')+1,
  length(g_insert_rowid_table)),substr(g_insert_rowid_table,1,instr(g_insert_rowid_table,'.')-1));
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_update_rowid_table,instr(g_update_rowid_table,'.')+1,
  length(g_update_rowid_table)),substr(g_update_rowid_table,1,instr(g_update_rowid_table,'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  write_to_log_file('problem statement '||l_stmt);
  return false;
End;

function make_is_groupby_col  return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In make_is_groupby_col');
  end if;
  for i in 1..g_number_input_params loop
    if is_groupby_col(g_output_params(i))=false then
      g_groupby_col_flag(i):=false;
    else
      g_groupby_col_flag(i):=true;
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function make_is_fk_flag return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In make_is_fk_flag');
  end if;
  for i in 1..g_number_input_params loop
    if is_tgt_fk(g_output_params(i))=false then
      g_fk_flag(i):=false;
    else
      if g_groupby_col_flag(i) then
        g_fk_flag(i):=true;
      else
        g_fk_flag(i):=false;
      end if;
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function is_tgt_fk_mapped return boolean is
l_found boolean;
Begin
  for i in 1..g_number_fact_fks loop
    l_found:=false;
    for j in 1..g_number_input_params loop
      if g_fk_flag(j) then
        if g_output_params(j)=g_fact_fks(i) then
          l_found:=true;
          exit;
        end if;
      end if;
    end loop;
    g_fact_fks_mapped(i):=l_found;
  end loop;
  --g_fact_fks_mapped
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

procedure init_all(p_job_id number) is
l_fact_name varchar2(400);
l_fact_name_org varchar2(400);
Begin
  if p_job_id is null then
    l_fact_name:='TAB_'||g_fact_id||'_'||g_src_object_id||'_';
  else
    l_fact_name:='TAB_'||g_fact_id||'_'||g_src_object_id||'_'||p_job_id||'_';
  end if;
  l_fact_name_org:='TAB_'||g_fact_id||'_'||g_src_object_id||'_';
  g_insert_lock_table:=g_bis_owner||'.INSERT_LOCK_'||g_fact_id;--should this be a passed down parameter?
  g_naedw_pk:=0;
  g_temp_fact_name:=g_bis_owner||'.'||l_fact_name||'T';
  g_summarize_temp2:=g_bis_owner||'.'||l_fact_name||'T2';
  g_summarize_temp3:=g_bis_owner||'.'||l_fact_name||'T3';
  g_insert_rowid_table:=g_bis_owner||'.'||l_fact_name||'IR';
  g_update_rowid_table:=g_bis_owner||'.'||l_fact_name||'UR';
  g_delete_rowid_table:=g_bis_owner||'.'||l_fact_name||'DR';
  g_insert_prot_log :=g_bis_owner||'.'||l_fact_name||'PI';
  g_update_prot_log :=g_bis_owner||'.'||l_fact_name||'PU';
  g_delete_prot_log :=g_bis_owner||'.'||l_fact_name||'PD';
  g_ins_rows_processed:=0;
  g_fact_type:='DERIVED';
  g_filter_stmt:=null;
  g_err_rec_flag:=false;
  g_err_rec_flag_d:=false;
  g_total_insert:=0;
  g_total_update:=0;
  g_total_delete:=0;
  g_skip_ilog:=false;
  g_skip_ilog_update:=false;
  g_skip_dlog_update:=false;
  g_type_ilog_generation:='CTAS';
  g_type_dlog_generation:='CTAS';
  g_ilog_prev:=null;
  g_dlog_prev:=null;
  g_temp_fact_name_temp:=g_temp_fact_name||'A';
  g_df_table_owner:=EDW_OWB_COLLECTION_UTIL.get_table_owner(g_fact_name);
  if EDW_OWB_COLLECTION_UTIL.get_table_next_extent(g_fact_name,g_df_table_owner,g_fact_next_extent)=false then
    g_fact_next_extent:=null;
  end if;
  if g_fact_next_extent is null or g_fact_next_extent=0 then
    g_fact_next_extent:=16777216;
  end if;
  g_src_join_nl:=true;
  g_ilog_small:=g_ilog||'S';
  g_dlog_small:=g_dlog||'S';
  g_over:=false;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
End;

function get_status_message return varchar2 is
begin
  return g_status_message;
Exception when others then
 write_to_log_file_n('Error  in get_status_message '||sqlerrm);
 return null;
End;

function get_time return varchar2 is
begin
  return '   Time:'||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS');
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
  write_to_log_file(' ');
  write_to_log_file(p_message);
Exception when others then
 null;
End;

function summarize_fact_data return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In summarize_fact_data');
  end if;
  if create_summarize_temp2=false then
    return false;
  end if;
  if create_summarize_temp3=false then
    return false;
  end if;
  if create_summarize_temp=false then
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function create_summarize_temp2 return boolean is
l_stmt varchar2(10000);
l_summarize_temp2 varchar2(400);
l_parent_ltc  EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_parent_pk  EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_parent_pk_key  EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_use_dim_pk  EDW_OWB_COLLECTION_UTIL.booleanTableType;--if higher level pk_key is not present, use the pk
Begin
  if g_debug then
    write_to_log_file_n('In create_summarize_temp2');
  end if;
  l_summarize_temp2:=g_summarize_temp2||'A';
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_summarize_temp2)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_summarize_temp2)=false then
    null;
  end if;
  for i in 1..g_number_fact_fks loop
    if g_higher_level(i)=true and g_fact_fks_mapped(i) then
      l_use_dim_pk(i):=false;--default
      if EDW_OWB_COLLECTION_UTIL.is_column_in_table(g_parent_dim(i),g_level_pk_key(i))=false or
      g_parent_dim(i) like 'EDW_GL_ACCT%' then
        l_use_dim_pk(i):=true;
      end if;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('The dimensions using the PK');
    for i in 1..g_number_fact_fks loop
      if g_higher_level(i)=true and g_fact_fks_mapped(i) and l_use_dim_pk(i) then
        write_to_log_file(g_parent_dim(i)||'  '||g_level_pk(i));
      end if;
    end loop;
    write_to_log_file_n('The dimensions using the PK_KEY');
    for i in 1..g_number_fact_fks loop
      if g_higher_level(i)=true and g_fact_fks_mapped(i) and l_use_dim_pk(i)=false then
        write_to_log_file(g_parent_dim(i)||'  '||g_level_pk_key(i));
      end if;
    end loop;
  end if;
  --get the higher level pks
  for i in 1..g_number_fact_fks loop
    if g_higher_level(i)=true and g_fact_fks_mapped(i) and l_use_dim_pk(i)=false then
      l_parent_ltc(i):=g_parent_level(i)||'_LTC';
      l_parent_pk(i):=EDW_OWB_COLLECTION_UTIL.get_user_pk(l_parent_ltc(i));
      l_parent_pk_key(i):=l_parent_pk(i)||'_KEY';
    end if;
  end loop;

  l_stmt:='create table '||l_summarize_temp2||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' ';
  l_stmt:=l_stmt||' as select ';
  --measures
  for i in 1..g_number_input_params loop
    if g_groupby_col_flag(i)=false then
      l_stmt:=l_stmt||' SUM(temp.'||g_output_params(i)||') '||g_output_params(i)||',';
    else
      --this will include the fks that are not rolling upto higher levels and cols that are grouped by
      if g_higher_level_flag(i) =false then
        l_stmt:=l_stmt||' temp.'||g_output_params(i)||' '||g_output_params(i)||',';
      end if;
    end if;
  end loop;
  for i in 1..g_number_fact_fks loop
    if g_higher_level(i)=true and g_fact_fks_mapped(i) then
      if l_use_dim_pk(i) then
        l_stmt:=l_stmt||g_parent_dim(i)||i||'.'||g_level_pk(i)||' '||g_fact_fks(i)||',';
      else
        l_stmt:=l_stmt||g_parent_dim(i)||i||'.'||g_level_pk_key(i)||' '||g_fact_fks(i)||',';
      end if;
    end if;
  end loop;
  if g_number_df_extra_fks > 0 then
    for i in 1..g_number_df_extra_fks loop
      --l_stmt:=l_stmt||' temp.'||g_df_extra_fks(i)||' '||g_df_extra_fks(i)||',';
      l_stmt:=l_stmt||g_naedw_pk||' '||g_df_extra_fks(i)||',';
    end loop;
  end if;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  l_stmt:=l_stmt||' from '||g_temp_fact_name||' temp,';
  for i in 1..g_number_fact_fks loop
    if g_higher_level(i)=true and g_fact_fks_mapped(i) then
      l_stmt:=l_stmt||g_parent_dim(i)||' '||g_parent_dim(i)||i||',';
    end if;
  end loop;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  l_stmt:=l_stmt||' where ';
  for i in 1..g_number_fact_fks loop
    if g_higher_level(i)=true and g_fact_fks_mapped(i) then
      l_stmt:=l_stmt||g_parent_dim(i)||i||'.'||g_dim_pk_key(i)||'=temp.'||g_fact_fks(i)||' and ';
    end if;
  end loop;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-4);
  l_stmt:=l_stmt||' group by ';
  for i in 1..g_number_fact_fks loop
    if g_higher_level(i)=true and g_fact_fks_mapped(i) then
      if l_use_dim_pk(i) then
        l_stmt:=l_stmt||g_parent_dim(i)||i||'.'||g_level_pk(i)||',';
      else
        l_stmt:=l_stmt||g_parent_dim(i)||i||'.'||g_level_pk_key(i)||',';
      end if;
    end if;
  end loop;
  if g_number_group_by_cols > 0 then
    for i in 1..g_number_group_by_cols loop
      for j in 1..g_number_fact_fks loop
        if g_higher_level(j)=false and g_fact_fks(j)=g_output_group_by_cols(i) then
          l_stmt:=l_stmt||'temp.'||g_output_group_by_cols(i)||',';
          exit;
        end if;
      end loop;
    end loop;
    for i in 1..g_number_group_by_cols loop
      if EDW_OWB_COLLECTION_UTIL.value_in_table(g_fact_fks,g_number_fact_fks,g_output_group_by_cols(i))=false then
        l_stmt:=l_stmt||'temp.'||g_output_group_by_cols(i)||',';
      end if;
    end loop;
  end if;
  /*
  if g_number_df_extra_fks > 0 then
    for i in 1..g_number_df_extra_fks loop
      l_stmt:=l_stmt||' temp.'||g_df_extra_fks(i)||',';
    end loop;
  end if;*/

  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  if EDW_OWB_COLLECTION_UTIL.execute_stmt(l_stmt)=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    write_to_log_file_n(g_status_message);
    return false;
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_summarize_temp2,instr(l_summarize_temp2,'.')+1,
  length(l_summarize_temp2)),substr(l_summarize_temp2,1,instr(l_summarize_temp2,'.')-1));


  l_stmt:='create table '||g_summarize_temp2||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' ';
  l_stmt:=l_stmt||' as select ';
  for i in 1..g_number_input_params loop
    if g_groupby_col_flag(i)=false then
      l_stmt:=l_stmt||l_summarize_temp2||'.'||g_output_params(i)||',';
    else
      --this will include the fks that are not rolling upto higher levels and cols that are grouped by
      if g_higher_level_flag(i) =false then
        l_stmt:=l_stmt||l_summarize_temp2||'.'||g_output_params(i)||',';
      end if;
    end if;
  end loop;
  for i in 1..g_number_fact_fks loop
    if g_higher_level(i)=true and g_fact_fks_mapped(i) then
      if l_use_dim_pk(i) then
        l_stmt:=l_stmt||l_summarize_temp2||'.'||g_fact_fks(i)||' '||g_fact_fks(i)||',';
      else
        l_stmt:=l_stmt||l_parent_ltc(i)||i||'.'||l_parent_pk(i)||' '||g_fact_fks(i)||',';
      end if;
    end if;
  end loop;
  if g_number_df_extra_fks > 0 then
    for i in 1..g_number_df_extra_fks loop
      l_stmt:=l_stmt||l_summarize_temp2||'.'||g_df_extra_fks(i)||',';
    end loop;
  end if;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  l_stmt:=l_stmt||' from '||l_summarize_temp2||',';
  for i in 1..g_number_fact_fks loop
    if g_higher_level(i)=true and g_fact_fks_mapped(i) and l_use_dim_pk(i)=false then
      l_stmt:=l_stmt||l_parent_ltc(i)||' '||l_parent_ltc(i)||i||',';
    end if;
  end loop;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  l_stmt:=l_stmt||' where ';
  for i in 1..g_number_fact_fks loop
    if g_higher_level(i)=true and g_fact_fks_mapped(i) and l_use_dim_pk(i)=false then
      l_stmt:=l_stmt||l_parent_ltc(i)||i||'.'||l_parent_pk_key(i)||'='||
      l_summarize_temp2||'.'||g_fact_fks(i)||' and ';
    end if;
  end loop;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-4);
  if EDW_OWB_COLLECTION_UTIL.execute_stmt(l_stmt)=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    write_to_log_file_n(g_status_message);
    return false;
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_summarize_temp2,instr(g_summarize_temp2,'.')+1,
  length(g_summarize_temp2)),substr(g_summarize_temp2,1,instr(g_summarize_temp2,'.')-1));
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_summarize_temp2)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function create_summarize_temp3 return boolean is
l_stmt varchar2(10000);
Begin
  if g_debug then
    write_to_log_file_n('In create_summarize_temp3');
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_summarize_temp3)=false then
    null;
  end if;
  l_stmt:='create table '||g_summarize_temp3||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' ';
  l_stmt:=l_stmt||' as select ';
  l_stmt:=l_stmt||' temp2.rowid row_id,';
  for i in 1..g_number_fact_fks loop
    if g_higher_level(i) and g_fact_fks_mapped(i) then
      l_stmt:=l_stmt||g_parent_dim(i)||i||'.'||g_dim_pk_key(i)||' '||g_fact_fks(i)||',';
    end if;
  end loop;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  l_stmt:=l_stmt||' from '||g_summarize_temp2||' temp2,';
  for i in 1..g_number_fact_fks loop
    if g_higher_level(i)=true and g_fact_fks_mapped(i) then
      l_stmt:=l_stmt||g_parent_dim(i)||' '||g_parent_dim(i)||i||',';
    end if;
  end loop;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  l_stmt:=l_stmt||' where ';
  for i in 1..g_number_fact_fks loop
    if g_higher_level(i)=true  and g_fact_fks_mapped(i) then
      if g_parent_dim(i) like 'EDW_GL_ACCT%' then
        l_stmt:=l_stmt||'temp2.'||g_fact_fks(i)||'='||
        g_parent_dim(i)||i||'.'||EDW_OWB_COLLECTION_UTIL.get_user_key(g_dim_pk_key(i))||' and ';
      else
        l_stmt:=l_stmt||'temp2.'||g_fact_fks(i)||'||''-'||g_level_prefix(i)||'''='||
        g_parent_dim(i)||i||'.'||EDW_OWB_COLLECTION_UTIL.get_user_key(g_dim_pk_key(i))||' and ';
      end if;
    end if;
  end loop;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-4);
  if EDW_OWB_COLLECTION_UTIL.execute_stmt(l_stmt)=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    write_to_log_file_n(g_status_message);
    return false;
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_summarize_temp3,instr(g_summarize_temp3,'.')+1,
  length(g_summarize_temp3)),substr(g_summarize_temp3,1,instr(g_summarize_temp3,'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function create_summarize_temp return boolean is
l_stmt varchar2(10000);
Begin
  if g_debug then
    write_to_log_file_n('In create_summarize_temp');
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_temp_fact_name)=false then
    null;
  end if;
  l_stmt:='create table '||g_temp_fact_name||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' ';
  l_stmt:=l_stmt||' as select ';
  for i in 1..g_number_input_params loop
    if g_groupby_col_flag(i)=false then
      l_stmt:=l_stmt||'temp2.'||g_output_params(i)||',';
    else
      if g_higher_level_flag(i) =false then
        l_stmt:=l_stmt||'temp2.'||g_output_params(i)||',';
      end if;
    end if;
  end loop;
  for i in 1..g_number_fact_fks loop
    if g_higher_level(i)=true  and g_fact_fks_mapped(i) then
      l_stmt:=l_stmt||'temp3.'||g_fact_fks(i)||',';
    end if;
  end loop;
  if g_number_df_extra_fks > 0 then
    for i in 1..g_number_df_extra_fks loop
      l_stmt:=l_stmt||' temp2.'||g_df_extra_fks(i)||',';
    end loop;
  end if;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  l_stmt:=l_stmt||' from '||g_summarize_temp2||' temp2,'||g_summarize_temp3||' temp3 where '||
    'temp2.rowid=temp3.row_id';
  if EDW_OWB_COLLECTION_UTIL.execute_stmt(l_stmt)=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    write_to_log_file_n(g_status_message);
    return false;
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_temp_fact_name,instr(g_temp_fact_name,'.')+1,
        length(g_temp_fact_name)),substr(g_temp_fact_name,1,instr(g_temp_fact_name,'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function drop_prot_tables return boolean is
Begin
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_insert_prot_log)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_update_prot_log)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function drop_d_prot_tables return boolean is
Begin
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_delete_prot_log)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function make_insert_prot_log return boolean is
l_stmt varchar2(2000);
Begin
  --l_stmt:='create table '||g_insert_prot_log||' (row_id rowid) '||' tablespace '||g_op_table_space;
  l_stmt:='create table '||g_insert_prot_log||' tablespace '||g_op_table_space||
  ' storage(initial 4M next 4M pctincrease 0) ';
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select row_id from '||g_ilog||' where status=1';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  execute immediate l_stmt;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_insert_prot_log,instr(g_insert_prot_log,'.')+1,
  length(g_insert_prot_log)),substr(g_insert_prot_log,1,instr(g_insert_prot_log,'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in make_insert_prot_log '||g_status_message);
  return false;
End;

function make_update_prot_log return boolean is
l_stmt varchar2(2000);
Begin
  --l_stmt:='create table '||g_update_prot_log||' (row_id rowid) '||' tablespace '||g_op_table_space;
  l_stmt:='create table '||g_update_prot_log||' tablespace '||g_op_table_space||
  ' storage(initial 4M next 4M pctincrease 0) ';
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select row_id from '||g_ilog||' where status=1';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  execute immediate l_stmt;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_update_prot_log,instr(g_update_prot_log,'.')+1,
  length(g_update_prot_log)),substr(g_update_prot_log,1,instr(g_update_prot_log,'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function make_delete_prot_log return boolean is
l_stmt varchar2(2000);
Begin
  --l_stmt:='create table '||g_delete_prot_log||' (row_id rowid) '||' tablespace '||g_op_table_space;
  l_stmt:='create table '||g_delete_prot_log||' tablespace '||g_op_table_space||
  ' storage(initial 4M next 4M pctincrease 0) ';
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select row_id from '||g_dlog||' where status=1';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  execute immediate l_stmt;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_delete_prot_log,instr(g_delete_prot_log,'.')+1,
  length(g_delete_prot_log)),substr(g_delete_prot_log,1,instr(g_delete_prot_log,'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function recover_from_previous_error return boolean is
Begin
  if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_ilog) = 2 then
    g_err_rec_flag:=true;
  end if;
  if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_dlog) = 2 then
    g_err_rec_flag_d:=true;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

procedure insert_into_temp_log(p_flag varchar2) is
Begin
  g_number_ins_req_coll:=1;
  g_ins_instance_name(1):=null;
  g_ins_request_id_table(1):=g_load_fk;
  g_ins_rows_dangling(1):=0;
  g_ins_rows_duplicate(1):=0;
  g_ins_rows_error(1):=0;
  if p_flag='+' then
    g_ins_rows_ready(1):=g_ins_rows_processed;
    g_ins_rows_processed_tab(1):=g_ins_rows_processed;
    g_ins_rows_collected(1):=g_ins_rows_processed;
  else --delete data
    g_ins_rows_ready(1):=g_ins_rows_processed;
    g_ins_rows_processed_tab(1):=g_ins_rows_processed;
    g_ins_rows_collected(1):=g_ins_rows_processed;
  end if;
  if EDW_OWB_COLLECTION_UTIL.insert_temp_log_table(
      g_fact_name,
      'FACT',
      g_conc_id,
      g_ins_instance_name,
      g_ins_request_id_table,
      g_ins_rows_ready,
      g_ins_rows_processed_tab,
      g_ins_rows_collected,
      g_ins_rows_dangling,
      g_ins_rows_duplicate,
      g_ins_rows_error,
      null,
      g_total_insert,
      g_total_update,
      g_total_delete,
      g_number_ins_req_coll) = false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    write_to_log_file_n(g_status_message);
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
End;

procedure insert_into_load_progress(p_load_fk number,p_object_name varchar2,p_load_progress varchar2,
  p_start_date date,p_end_date date,p_category varchar2, p_operation varchar2,p_seq_id varchar2,p_flag varchar2) is
Begin
  EDW_OWB_COLLECTION_UTIL.insert_into_load_progress(p_load_fk,p_object_name,g_fact_id,p_load_progress,p_start_date,
  p_end_date,p_category,p_operation,p_seq_id,p_flag,g_fact_id);
  commit;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
End;

--if g_debug is on...
procedure insert_into_load_progress_d(p_load_fk number,p_object_name varchar2,p_load_progress varchar2,
  p_start_date date,p_end_date date,p_category varchar2, p_operation varchar2,p_seq_id varchar2,p_flag varchar2) is
Begin
  if g_debug then
    EDW_OWB_COLLECTION_UTIL.insert_into_load_progress(p_load_fk,p_object_name,g_fact_id,p_load_progress,p_start_date,
    p_end_date,p_category,p_operation,p_seq_id,p_flag,g_fact_id);
    commit;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
End;

function make_g_higher_level_flag return boolean is
l_found boolean;
Begin
  for i in 1..g_number_input_params loop
    l_found:=false;
    for j in 1..g_number_fact_fks loop
      if g_output_params(i)=g_fact_fks(j) and g_higher_level(j) and g_fact_fks_mapped(j) then
        l_found:=true;
        exit;
      end if;
    end loop;
    if l_found then
      g_higher_level_flag(i):=true;
    else
      g_higher_level_flag(i):=false;
    end if;
  end loop;
  for i in 1..g_number_fact_fks loop
    if g_higher_level(i) and g_fact_fks_mapped(i) then
      g_fact_type:='SUMMARY';
      exit;
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

procedure reset_profiles is
Begin
  if g_debug then
    write_to_log_file_n('In reset_profiles'||get_time);
  end if;
  --EDW_ALL_COLLECT.reset_profiles;
  --g_collection_size:=EDW_ALL_COLLECT.g_collection_size;
  --g_mode:=EDW_ALL_COLLECT.g_mode;
Exception when others then
  write_to_log_file_n('Error in reset_profiles '||sqlerrm||get_time);
End;

function get_base_fact_count return number is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt varchar2(5000);
l_num number;
l_num_blks number;
l_avg_rowlen number;
l_table_owner varchar2(200);
Begin
  l_table_owner:=EDW_OWB_COLLECTION_UTIL.get_table_owner(g_src_object);
  l_num:=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_src_object,l_table_owner);
  if l_num is null or l_num=0 then
    if g_parallel is not null then
      l_stmt:='select /*+parallel('||g_src_object||','||g_parallel||')*/ count(*) from '||g_src_object;
    else
      l_stmt:='select count(*) from '||g_src_object;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    open cv for l_stmt;
    fetch cv into l_num;
    close cv;
  end if;
  if g_debug then
    write_to_log_file_n('count='||l_num||get_time);
  end if;
  return l_num;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return -1;
End;


function create_temp_gilog return boolean is
l_stmt varchar2(5000);
Begin
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_ilog)=false then
    null;
  end if;
  g_skip_ilog_update:=true;
  if g_src_snplog_has_pk then
    l_stmt:='create table '||g_ilog||' tablespace '||g_op_table_space||
    ' as select rowid row_id,-10 '||g_src_pk||', 1 status from dual ';
  else
    l_stmt:='create table '||g_ilog||' tablespace '||g_op_table_space||
    ' as select rowid row_id, 1 status from dual ';
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function create_temp_gdlog return boolean is
l_stmt varchar2(5000);
Begin
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dlog)=false then
    null;
  end if;
  g_skip_dlog_update:=true;
  l_stmt:='create table '||g_dlog||' tablespace '||g_op_table_space||
  ' as select rowid row_id, 1 status from dual ';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function check_src_fact_snplog return number is
Begin
  --g_src_snplog_has_pk
  --g_src_uk
  --g_src_pk
  --g_src_object_ilog
  if EDW_OWB_COLLECTION_UTIL.is_column_in_table(g_src_object_ilog,g_src_pk,g_table_owner) then
    g_src_snplog_has_pk:=true;
    if g_debug then
      write_to_log_file_n('g_src_snplog_has_pk set to TRUE');
    end if;
    return 1;
  end if;
  return 0;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return -1;
End;

function load_new_update_data return boolean is
l_stmt varchar2(10000);
l_table_i_and_d varchar2(400);
l_table_dlog varchar2(400);
l_col varchar2(400);
l_dlog_col varchar2(400);
l_round varchar2(400);
l_count number;
l_table_1 varchar2(400);
l_table_2 varchar2(400);
Begin
  if g_debug then
    write_to_log_file_n('In load_new_update_data'||get_time);
  end if;
  l_col:='pk_key';
  l_dlog_col:='pk_key';
  l_round:='round';
  --use is_column_in_table
  if EDW_OWB_COLLECTION_UTIL.check_table(g_dlog)=false then
    if g_debug then
      write_to_log_file_n(g_dlog||' not found'||get_time);
    end if;
    return true;
  end if;
  if EDW_OWB_COLLECTION_UTIL.check_table_column(g_ilog,l_round)=false then
    if g_debug then
      write_to_log_file_n(l_round||' column not in '||g_ilog||get_time);
    end if;
    return true;
  end if;
  if EDW_OWB_COLLECTION_UTIL.check_table_column(g_dlog,l_round)=false then
    if g_debug then
      write_to_log_file_n(l_round||' column not in '||g_dlog||get_time);
    end if;
    return true;
  end if;
  if EDW_OWB_COLLECTION_UTIL.check_table_column(g_src_object_dlog,'PK_KEY')=false then
    if g_debug then
      write_to_log_file_n('PK_KEY column not in '||g_src_object_dlog||get_time);
    end if;
    return true;
  end if;
  l_table_i_and_d:=g_ilog||'ID';
  l_table_dlog:=g_ilog||'DL';
  l_table_1:=g_ilog||'T1';
  l_table_2:=g_ilog||'T2';
  l_stmt:='create table '||l_table_i_and_d||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select B.'||l_col||',B.'||l_round||' from '||g_ilog||' A,'||g_dlog||' B where '||
  ' A.row_id=B.row_id1 and A.status=2';
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table_i_and_d)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to exec '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  l_count:=sql%rowcount;
  if g_debug then
    write_to_log_file_n('Created with '||l_count||' rows '||get_time);
  end if;
  if l_count=0 then
    if g_debug then
      write_to_log_file_n('There is no need to get any new rows for DLOG and ILOG');
    end if;
    return true;
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_table_i_and_d,instr(l_table_i_and_d,'.')+1,
  length(l_table_i_and_d)),substr(l_table_i_and_d,1,instr(l_table_i_and_d,'.')-1));
  l_stmt:='create table '||l_table_dlog||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select /*+ordered*/ ';
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+parallel(A,'||g_parallel||')*/ ';
  end if;
  l_stmt:=l_stmt||'A.rowid row_id,A.row_id row_id1,A.'||l_round||',A.'||l_dlog_col;
  l_stmt:=l_stmt||' from '||l_table_i_and_d||' B,'||g_src_object_dlog||' A where A.'||l_dlog_col||'=B.'||l_col||
  ' and A.'||l_round||' > B.'||l_round;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table_dlog)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to exec '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  l_count:=sql%rowcount;
  if g_debug then
    write_to_log_file_n('Created with '||l_count||' rows '||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_table_dlog,instr(l_table_dlog,'.')+1,
  length(l_table_dlog)),substr(l_table_dlog,1,instr(l_table_dlog,'.')-1));
  if l_count>0 then
    l_stmt:='create table '||l_table_1||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||' as select A.rowid row_id from '||l_table_dlog||' A,'||g_ilog||' B where ';
    if g_src_snplog_has_pk then
      l_stmt:=l_stmt||'A.pk_key=B.'||g_src_pk||' and A.round=B.round';
    else
      l_stmt:=l_stmt||'A.row_id1=B.row_id and A.round=B.round';
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_table_1)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to exec '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    l_count:=sql%rowcount;
    if g_debug then
      write_to_log_file_n('Created with '||l_count||' rows '||get_time);
    end if;
    l_stmt:='create table '||l_table_2||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||' as select rowid row_id from '||l_table_dlog||' MINUS select row_id from '||
    l_table_1;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_table_2)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to exec '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    l_count:=sql%rowcount;
    if g_debug then
      write_to_log_file_n('Created with '||l_count||' rows '||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_table_2,instr(l_table_2,'.')+1,
    length(l_table_2)),substr(l_table_2,1,instr(l_table_2,'.')-1));
    if g_src_snplog_has_pk then
      l_stmt:='insert into '||g_ilog||'(row_id,status,'||l_round||','||g_src_pk||') select row_id1,0,'||
      l_round||','||l_dlog_col||' from '||l_table_2||','||l_table_dlog||' where '||l_table_2||'.row_id='||
      l_table_dlog||'.rowid';
    else
      l_stmt:='insert into '||g_ilog||'(row_id,status,'||l_round||') select row_id1,0,'||l_round||
      ' from '||l_table_2||','||l_table_dlog||' where '||l_table_2||'.row_id='||l_table_dlog||'.rowid';
    end if;
    if g_debug then
      write_to_log_file_n('Going to exec '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    l_count:=sql%rowcount;
    commit;
    if g_debug then
      write_to_log_file_n('Inserted '||l_count||' rows '||get_time);
    end if;
    --insert into D
    l_stmt:='insert into '||g_dlog||'(row_id,row_id1,status,'||l_round||','||l_col||') select B.row_id,B.row_id1,'||
    '0,B.'||l_round||',B.'||l_dlog_col||' from '||l_table_2||' A,'||l_table_dlog||' B where '||
    'A.row_id=B.rowid';
    if g_debug then
      write_to_log_file_n('Going to exec '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    l_count:=sql%rowcount;
    commit;
    if g_debug then
      write_to_log_file_n('Inserted '||l_count||' rows '||get_time);
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_table_1)=false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_table_2)=false then
      null;
    end if;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table_i_and_d)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table_dlog)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function set_g_src_join_nl(p_load_size number,p_total_records number) return boolean is
l_percentage number;
Begin
  if g_debug then
    write_to_log_file_n('In set_g_src_join_nl '||p_load_size||' '||p_total_records);
  end if;
  g_src_join_nl:=EDW_OWB_COLLECTION_UTIL.get_join_nl(p_load_size,p_total_records,g_src_join_nl_percentage);
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in set_g_src_join_nl '||g_status_message);
  return false;
End;

/*
This function sets the status of g_ilog and g_dlog if there are prot tables left around
*/
function recover_from_prot return boolean is
l_found boolean;
Begin
  if g_debug then
    write_to_log_file_n('In recover_from_prot');
  end if;
  if EDW_OWB_COLLECTION_UTIL.merge_all_prot_tables(g_insert_prot_log,'PI',g_op_table_space,g_bis_owner,
    g_parallel)=false then
    return false;
  end if;
  if EDW_OWB_COLLECTION_UTIL.merge_all_prot_tables(g_update_prot_log,'PU',g_op_table_space,g_bis_owner,
    g_parallel)=false then
    return false;
  end if;
  if EDW_OWB_COLLECTION_UTIL.merge_all_prot_tables(g_delete_prot_log,'PD',g_op_table_space,g_bis_owner,
    g_parallel)=false then
    return false;
  end if;
  l_found:=false;
  if EDW_OWB_COLLECTION_UTIL.check_table(g_insert_prot_log) then
    g_stmt:='update '||g_ilog||' set status=2 where row_id in (select row_id from '||g_insert_prot_log||')';
    l_found:=true;
  elsif EDW_OWB_COLLECTION_UTIL.check_table(g_update_prot_log) then
    g_stmt:='update '||g_ilog||' set status=2 where row_id in (select row_id from '||g_update_prot_log||')';
    l_found:=true;
  elsif EDW_OWB_COLLECTION_UTIL.check_table(g_delete_prot_log) then
    g_stmt:='update '||g_dlog||' set status=2 where row_id in (select row_id from '||g_delete_prot_log||')';
    l_found:=true;
  end if;
  if l_found then
    if g_debug then
      write_to_log_file_n(g_stmt||get_time);
    end if;
    execute immediate g_stmt;
    if g_debug then
      write_to_log_file_n('Updated '||sql%rowcount||' rows '||get_time);
    end if;
    commit;
  end if;
  if drop_prot_tables=false then
    null;
  end if;
  if drop_d_prot_tables=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in recover_from_prot '||g_status_message);
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

function read_options_table(p_table varchar2) return boolean is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_fk_table varchar2(80);
l_skip_table varchar2(80);
l_bu_table varchar2(80);
l_debug varchar2(2);
l_fresh_restart varchar2(2);
l_trace varchar2(2);
l_read_cfig_options varchar2(2);
l_higher_level EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_skip_ilog_update varchar2(2);
l_skip_dlog_update varchar2(2);
l_skip_ilog varchar2(2);
l_full_refresh varchar2(2);
l_src_snplog_has_pk varchar2(2);
l_err_rec_flag varchar2(2);
l_err_rec_flag_d varchar2(2);
Begin
  write_to_log_file_n('In read_options_table '||p_table);
  l_fk_table:=p_table||'_FK';
  l_skip_table:=p_table||'_SK';
  l_bu_table:=p_table||'_BU';
  g_stmt:='select '||
  'fact_id,'||
  'mapping_id,'||
  'src_object,'||
  'src_object_id,'||
  'conc_id,'||
  'conc_program_name,'||
  'debug,'||
  'collection_size,'||
  'parallel,'||
  'bis_owner,'||
  'table_owner ,'||
  'full_refresh,'||
  'forall_size,'||
  'update_type,'||
  'fact_dlog,'||
  'load_fk,'||
  'fresh_restart,'||
  'op_table_space,'||
  'bu_src_fact,'||
  'load_mode,'||
  'rollback,'||
  'src_join_nl_percentage,'||
  'max_threads,'||
  'min_job_load_size,'||
  'sleep_time,'||
  'job_status_table,'||
  'hash_area_size,'||
  'sort_area_size,'||
  'trace,'||
  'read_cfig_options,'||
  'ilog_table,'||
  'dlog_table,'||
  'skip_ilog_update,'||
  'skip_dlog_update,'||
  'skip_ilog,'||
  'src_object_ilog,'||
  'src_object_dlog,'||
  'src_snplog_has_pk,'||
  'err_rec_flag,'||
  'err_rec_flag_d,'||
  'dbms_job_id '||
  ' from '||p_table;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  open cv for g_stmt;
  fetch cv into
  g_fact_id
  ,g_mapping_id
  ,g_src_object
  ,g_src_object_id
  ,g_conc_id
  ,g_conc_program_name
  ,l_debug
  ,g_collection_size
  ,g_parallel
  ,g_bis_owner
  ,g_table_owner
  ,l_full_refresh
  ,g_forall_size
  ,g_update_type
  ,g_fact_dlog
  ,g_load_fk
  ,l_fresh_restart
  ,g_op_table_space
  ,g_bu_src_fact
  ,g_load_mode
  ,g_rollback
  ,g_src_join_nl_percentage
  ,g_max_threads
  ,g_min_job_load_size
  ,g_sleep_time
  ,g_job_status_table
  ,g_hash_area_size
  ,g_sort_area_size
  ,l_trace
  ,l_read_cfig_options
  ,g_ilog_name
  ,g_dlog_name
  ,l_skip_ilog_update
  ,l_skip_dlog_update
  ,l_skip_ilog
  ,g_src_object_ilog
  ,g_src_object_dlog
  ,l_src_snplog_has_pk
  ,l_err_rec_flag
  ,l_err_rec_flag_d
  ,g_dbms_job_id;
  close cv;
  if g_load_mode is null then
    g_load_mode:='NORMAL';
  end if;
  if l_debug='Y' then
    write_to_log_file_n('The values read');
    write_to_log_file('g_fact_id='||g_fact_id);
    write_to_log_file('g_mapping_id='||g_mapping_id);
    write_to_log_file('g_src_object='||g_src_object);
    write_to_log_file('g_src_object_id='||g_src_object_id);
    write_to_log_file('g_conc_id='||g_conc_id);
    write_to_log_file('g_conc_program_name='||g_conc_program_name);
    write_to_log_file('l_debug='||l_debug);
    write_to_log_file('g_collection_size='||g_collection_size);
    write_to_log_file('g_parallel='||g_parallel);
    write_to_log_file('g_bis_owner='||g_bis_owner);
    write_to_log_file('g_table_owner='||g_table_owner);
    write_to_log_file('l_full_refresh='||l_full_refresh);
    write_to_log_file('g_forall_size='||g_forall_size);
    write_to_log_file('g_update_type='||g_update_type);
    write_to_log_file('g_fact_dlog='||g_fact_dlog);
    write_to_log_file('g_load_fk='||g_load_fk);
    write_to_log_file('l_fresh_restart='||l_fresh_restart);
    write_to_log_file('g_op_table_space='||g_op_table_space);
    write_to_log_file('g_bu_src_fact='||g_bu_src_fact);
    write_to_log_file('g_load_mode='||g_load_mode);
    write_to_log_file('g_rollback='||g_rollback);
    write_to_log_file('g_src_join_nl_percentage='||g_src_join_nl_percentage);
    write_to_log_file('g_max_threads='||g_max_threads);
    write_to_log_file('g_min_job_load_size='||g_min_job_load_size);
    write_to_log_file('g_sleep_time='||g_sleep_time);
    write_to_log_file('g_job_status_table='||g_job_status_table);
    write_to_log_file('g_hash_area_size='||g_hash_area_size);
    write_to_log_file('g_sort_area_size='||g_sort_area_size);
    write_to_log_file('l_trace='||l_trace);
    write_to_log_file('l_read_cfig_options='||l_read_cfig_options);
    write_to_log_file('g_ilog_name='||g_ilog_name);
    write_to_log_file('g_dlog_name='||g_dlog_name);
    write_to_log_file('l_skip_ilog_update='||l_skip_ilog_update);
    write_to_log_file('l_skip_dlog_update='||l_skip_dlog_update);
    write_to_log_file('l_skip_ilog='||l_skip_ilog);
    write_to_log_file('g_src_object_ilog='||g_src_object_ilog);
    write_to_log_file('g_src_object_dlog='||g_src_object_dlog);
    write_to_log_file('l_src_snplog_has_pk='||l_src_snplog_has_pk);
    write_to_log_file('l_err_rec_flag='||l_err_rec_flag);
    write_to_log_file('l_err_rec_flag_d='||l_err_rec_flag_d);
    write_to_log_file('g_dbms_job_id='||g_dbms_job_id);
    --g_dbms_job_id can the id of a dbms job or conc process. depends on g_thread_type
  end if;
  g_debug:=false;
  g_full_refresh:=false;
  g_fresh_restart:=false;
  g_trace:=false;
  g_read_cfig_options:=false;
  g_skip_ilog_update:=false;
  g_skip_dlog_update:=false;
  g_skip_ilog:=false;
  g_src_snplog_has_pk:=false;
  g_err_rec_flag:=false;
  g_err_rec_flag_d:=false;
  if l_debug='Y' then
    g_debug:=true;
  end if;
  if l_full_refresh='Y' then
    g_full_refresh:=true;
  end if;
  if l_fresh_restart='Y' then
    g_fresh_restart:=true;
  end if;
  if l_trace='Y' then
    g_trace:=true;
  end if;
  if l_read_cfig_options='Y' then
    g_read_cfig_options:=true;
  end if;
  if l_skip_ilog_update='Y' then
    g_skip_ilog_update:=true;
  end if;
  if l_skip_dlog_update='Y' then
    g_skip_dlog_update:=true;
  end if;
  if l_skip_ilog='Y' then
    g_skip_ilog:=true;
  end if;
  if l_src_snplog_has_pk='Y' then
    g_src_snplog_has_pk:=true;
  end if;
  if l_err_rec_flag='Y' then
    g_err_rec_flag:=true;
  end if;
  if l_err_rec_flag_d='Y' then
    g_err_rec_flag_d:=true;
  end if;
  g_stmt:='select '||
  'fact_fks,'||
  'higher_level,'||
  'parent_dim,'||
  'parent_level,'||
  'level_prefix,'||
  'level_pk,'||
  'level_pk_key,'||
  'dim_pk_key '||
  ' from '||l_fk_table;
  g_number_fact_fks:=1;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  open cv for g_stmt;
  loop
    fetch cv into
    g_fact_fks(g_number_fact_fks),
    l_higher_level(g_number_fact_fks),
    g_parent_dim(g_number_fact_fks),
    g_parent_level(g_number_fact_fks),
    g_level_prefix(g_number_fact_fks),
    g_level_pk(g_number_fact_fks),
    g_level_pk_key(g_number_fact_fks),
    g_dim_pk_key(g_number_fact_fks);
    exit when cv%notfound;
    g_number_fact_fks:=g_number_fact_fks+1;
  end loop;
  close cv;
  g_number_fact_fks:=g_number_fact_fks-1;
  for i in 1..g_number_fact_fks loop
    if l_higher_level(i)='Y' then
      g_higher_level(i):=true;
    else
      g_higher_level(i):=false;
    end if;
  end loop;
  if g_debug then
    for i in 1..g_number_fact_fks loop
      write_to_log_file(g_fact_fks(i)||' '|| l_higher_level(i)||' '||g_parent_dim(i)||' '||
      g_parent_level(i)||' '||g_level_prefix(i)||' '||g_level_pk(i)||' '||g_level_pk_key(i)||' '||
      g_dim_pk_key(i));
    end loop;
  end if;
  g_stmt:='select skip_cols from '||l_skip_table;
  g_number_skip_cols:=1;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  open cv for g_stmt;
  loop
    fetch cv into g_skip_cols(g_number_skip_cols);
    exit when cv%notfound;
    g_number_skip_cols:=g_number_skip_cols+1;
  end loop;
  close cv;
  g_number_skip_cols:=g_number_skip_cols-1;
  if g_debug then
    for i in 1..g_number_skip_cols loop
      write_to_log_file(g_skip_cols(i));
    end loop;
  end if;
  g_stmt:='select bu_tables,bu_dimensions from '||l_bu_table;
  g_number_bu_tables:=1;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  open cv for g_stmt;
  loop
    fetch cv into g_bu_tables(g_number_bu_tables),g_bu_dimensions(g_number_bu_tables);
    exit when cv%notfound;
    g_number_bu_tables:=g_number_bu_tables+1;
  end loop;
  close cv;
  g_number_bu_tables:=g_number_bu_tables-1;
  if g_debug then
    for i in 1..g_number_bu_tables loop
      write_to_log_file(g_bu_tables(i)||' '||g_bu_dimensions(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in read_options_table '||g_status_message);
  return false;
End;

--in case of multi threading. each job here
function make_ok_from_main_ok(
p_main_ok_table_name varchar2,
p_ilog_table varchar2,
p_low_end number,
p_high_end number,
p_mode varchar2
) return boolean is
l_ilog_number number;
Begin
  if g_debug then
    write_to_log_file_n('In make_ok_from_main_ok '||p_main_ok_table_name||' '||p_ilog_table||' '||p_low_end||' '||
    p_high_end);
  end if;
  if EDW_OWB_COLLECTION_UTIL.make_ilog_from_main_ilog(
    p_ilog_table,
    p_main_ok_table_name,
    p_low_end,
    p_high_end,
    g_op_table_space,
    g_bis_owner,
    g_parallel,
    l_ilog_number)=false then
    return false;
  end if;
  if p_mode='ILOG' then
    g_skip_ilog_update:=false;
    if EDW_OWB_COLLECTION_UTIL.does_table_have_data(p_ilog_table,' status=1 ')=2 then
      g_skip_ilog_update:=true;
    end if;
  else
    g_skip_dlog_update:=false;
    if EDW_OWB_COLLECTION_UTIL.does_table_have_data(p_ilog_table,' status=1 ')=2 then
      g_skip_dlog_update:=true;
    end if;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in make_ok_from_main_ok '||g_status_message);
  return false;
End;

function put_rownum_in_log_table return boolean is
l_ilog_table varchar2(80);
Begin
  if g_debug then
    write_to_log_file_n('In put_rownum_in_log_table');
  end if;
  l_ilog_table:=g_ilog;
  if substr(g_ilog,length(g_ilog),1)='A' then
    g_ilog:=substr(g_ilog,1,length(g_ilog)-1);
  else
    g_ilog:=g_ilog||'A';
  end if;
  if EDW_OWB_COLLECTION_UTIL.put_rownum_in_ilog_table(
    g_ilog,
    l_ilog_table,
    g_op_table_space,
    g_parallel)=false then
    return false;
  end if;
  --for dlog
  l_ilog_table:=g_dlog;
  if substr(g_dlog,length(g_dlog),1)='A' then
    g_dlog:=substr(g_dlog,1,length(g_dlog)-1);
  else
    g_dlog:=g_dlog||'A';
  end if;
  if EDW_OWB_COLLECTION_UTIL.put_rownum_in_ilog_table(
    g_dlog,
    l_ilog_table,
    g_op_table_space,
    g_parallel)=false then
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in put_rownum_in_log_table '||g_status_message);
  return false;
End;

function drop_ilog_dlog_tables(p_ilog varchar2,p_dlog varchar2) return boolean is
Begin
  if EDW_OWB_COLLECTION_UTIL.drop_ilog_tables(p_ilog,null,g_bis_owner)=false then
    return false;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_ilog_tables(p_dlog,null,g_bis_owner)=false then
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in drop_ilog_dlog_tables '||g_status_message);
  return false;
End;

/*
this function will prevent data corruption in derv fact. if there are 2 conc processes or jobs
both trying to insert into the fact, there will be duplicate rows.
so keep insert locked. so inserts will be single threaded.
*/
function create_insert_lock_table return boolean is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_conc_id number;
l_dbms_job_id number;
l_status varchar2(20);
----------------------------
l_my_conc_id number;
l_my_job_id number;
----------------------------
Begin
  if g_debug then
    write_to_log_file_n('In create_insert_lock_table '||get_time);
  end if;
  if g_conc_id is null then
    g_conc_id:=-1;
  end if;
  if g_dbms_job_id is null then
    g_dbms_job_id:=-1;
  end if;
  -------------------------------------------------------
  l_my_conc_id:=FND_GLOBAL.Conc_request_id;--my conc id
  if l_my_conc_id is null or l_my_conc_id<=0 then
    l_my_conc_id:=-1;
    l_my_job_id:=g_dbms_job_id;
  else
    l_my_job_id:=-1;
  end if;
  -------------------------------------------------------
  g_stmt:='create table '||g_insert_lock_table||' tablespace '||g_op_table_space||
  ' as select nvl('||l_my_conc_id||',-1) conc_id, nvl('||l_my_job_id||',-1) dbms_job_id from dual';
  l_stmt:='select conc_id,dbms_job_id from '||g_insert_lock_table;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  loop
    begin
      execute immediate g_stmt;
      if g_debug then
        write_to_log_file_n('Created '||g_insert_lock_table||get_time);
      end if;
      exit;
    exception when others then
      if sqlcode=-00955 then --already exists
        null;
      else
        return false;
      end if;
    end;
    --see if the processes mentioned are still running
    begin
      if g_debug then
        write_to_log_file_n(l_stmt);
      end if;
      open cv for l_stmt;
      fetch cv into l_conc_id,l_dbms_job_id;
      close cv;
      if g_debug then
        write_to_log_file(l_conc_id||' '||l_dbms_job_id);
      end if;
      --for single threaded case, g_thread_type is null
      if l_dbms_job_id <> -1 then
        l_status:=EDW_OWB_COLLECTION_UTIL.check_job_status(l_dbms_job_id);
        if l_status is null then
          return false;
        elsif l_status='N' then
          if EDW_OWB_COLLECTION_UTIL.drop_table(g_insert_lock_table)=false then
            null;
          end if;
        else
          DBMS_LOCK.SLEEP(g_sleep_time);
        end if;
      else
        l_status:=EDW_OWB_COLLECTION_UTIL.check_conc_process_status(l_conc_id);
        if l_status is null then
          return false;
        elsif l_status='N' then
          if EDW_OWB_COLLECTION_UTIL.drop_table(g_insert_lock_table)=false then
            null;
          end if;
        else
          DBMS_LOCK.SLEEP(g_sleep_time);
        end if;
      end if;
    exception when others then
      if sqlcode=-00942 then --object does not exist
        null;
      end if;
    end;
  end loop;
  return true;
Exception when others then
  write_to_log_file_n('Error in create_insert_lock_table '||g_status_message);
  return false;
End;

function drop_insert_lock_table return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In drop_insert_lock_table');
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_insert_lock_table)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in drop_insert_lock_table '||g_status_message);
  return false;
End;

function pre_fact_load_hook(p_derv_fact varchar2,p_src_fact varchar2) return boolean is
Begin
  if g_debug then
    write_to_log_file_n('Calling pre_fact_load_hook '||p_derv_fact||' '||p_src_fact||get_time);
  end if;
  insert_into_load_progress(g_load_fk,g_fact_name,'Pre Fact Load Hook',sysdate,null,'DF',
  'PRE-FACT-HOOK','PREDFHOOK'||g_fact_id||'-'||g_src_object_id,'I');
  if EDW_COLLECTION_HOOK.pre_derived_fact_coll(p_derv_fact)=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.get_message('EDW_PREDERVFACT_COLL_ERROR');
    write_to_log_file_n(g_status_message||' for '||p_derv_fact);
    return false;
  end if;
  insert_into_load_progress(g_load_fk,null,null,null,sysdate,null,null,'PREDFHOOK'||g_fact_id||'-'||g_src_object_id,
  'U');
  if g_debug then
    write_to_log_file_n('Finished pre_fact_load_hook '||get_time);
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in pre_fact_load_hook '||g_status_message);
  return false;
End;

function post_fact_load_hook(p_derv_fact varchar2,p_src_fact varchar2) return boolean is
Begin
  if g_debug then
    write_to_log_file_n('Calling post_fact_load_hook '||p_derv_fact||' '||p_src_fact||get_time);
  end if;
  insert_into_load_progress(g_load_fk,g_fact_name,'Post Fact Load Hook',sysdate,null,'DF',
  'POST-FACT-HOOK','PDFHOOK'||g_fact_id||'-'||g_src_object_id,'I');
  if EDW_COLLECTION_HOOK.post_derived_fact_coll(p_derv_fact)=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.get_message('EDW_POSTDERVFACT_COLL_ERROR');
    write_to_log_file_n(g_status_message||' for '||p_derv_fact||get_time);
    return false;
  end if;
  insert_into_load_progress(g_load_fk,null,null,null,sysdate,null,null,'PDFHOOK'||g_fact_id||'-'||g_src_object_id,
  'U');
  if g_debug then
    write_to_log_file_n('Finished post_fact_load_hook '||get_time);
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in post_fact_load_hook '||g_status_message);
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
  l_exe_file_name:='EDW_DERIVED_FACT_FACT_COLLECT.COLLECT_FACT';
  l_parameter(1):='p_mode';
  l_parameter_value_set(1):='FND_CHAR240';
  l_parameter(2):='p_fact_name';
  l_parameter_value_set(2):='FND_CHAR240';
  l_parameter(3):='p_input_table';
  l_parameter_value_set(3):='FND_CHAR240';
  l_parameter(4):='p_job_id';
  l_parameter_value_set(4):='FND_NUMBER';
  l_parameter(5):='p_ilog_low_end';
  l_parameter_value_set(5):='FND_NUMBER';
  l_parameter(6):='p_ilog_high_end';
  l_parameter_value_set(6):='FND_NUMBER';
  l_parameter(7):='p_ilog';
  l_parameter_value_set(7):='FND_CHAR240';
  l_parameter(8):='p_dlog';
  l_parameter_value_set(8):='FND_CHAR240';
  l_parameter(9):='p_log_file';
  l_parameter_value_set(9):='FND_CHAR240';
  l_parameter(10):='p_thread_type';
  l_parameter_value_set(10):='FND_CHAR240';
  l_number_parameters:=10;
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


END;

/
