--------------------------------------------------------
--  DDL for Package Body EDW_DERIVED_FACT_COLLECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_DERIVED_FACT_COLLECT" AS
/*$Header: EDWFCOLB.pls 120.1 2006/05/12 02:46:49 vsurendr ship $*/

/*
this api is used to collect a particular src fact to a derived fact
*/
FUNCTION COLLECT_FACT(
  p_fact_name varchar2,--derived fact
  p_fact_id number,--derived fact
  p_src_fact_name varchar2,
  p_src_fact_id number,
  p_map_id number,
  p_conc_id in number,
  p_conc_program_name in varchar2,
  p_debug boolean,
  p_collection_size number,
  p_parallel  number,
  p_bis_owner varchar2,
  p_table_owner varchar2,
  p_ins_rows_processed out NOCOPY number,
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
  p_bu_src_fact varchar2,--what table to look at as the src fact. if null, scan the actual src fact
  p_load_mode varchar2,
  p_rollback varchar2,
  p_src_join_nl_percentage number,
  p_thread_type varchar2,
  p_max_threads number,
  p_min_job_load_size number,
  p_sleep_time number,
  p_hash_area_size number,
  p_sort_area_size number,
  p_trace boolean,
  p_read_cfig_options boolean
) return boolean is
l_pre_hook varchar2(10);
l_post_hook varchar2(10);
Begin
  g_debug:=p_debug;
  g_fact_name:=p_fact_name;
  g_fact_id:=p_fact_id;
  g_number_mapping_ids:=1;--we are looking at this mapping only
  g_mapping_ids(g_number_mapping_ids):=p_map_id;
  g_src_objects(g_number_mapping_ids):=p_src_fact_name;
  g_src_object_ids(g_number_mapping_ids):=p_src_fact_id;
  g_collection_size :=p_collection_size;
  g_parallel:=p_parallel;
  g_bis_owner:=p_bis_owner;
  g_table_owner:=p_table_owner;
  g_ilog:=p_ilog;
  g_dlog:=p_dlog;
  g_forall_size:=p_forall_size;
  g_fresh_restart:=p_fresh_restart;
  g_thread_type:=p_thread_type;
  write_to_log_file_n('In COLLECT_FACT where the src and derived facts are specified');
  write_to_log_file('g_fact_name='||g_fact_name);
  write_to_log_file('g_fact_id='||g_fact_id);
  write_to_log_file('p_map_id='||p_map_id);
  write_to_log_file('p_src_fact_name='||p_src_fact_name);
  write_to_log_file('p_src_fact_id='||p_src_fact_id);
  write_to_log_file('g_collection_size='||g_collection_size);
  write_to_log_file('g_parallel='||g_parallel);
  write_to_log_file('g_bis_owner='||g_bis_owner);
  write_to_log_file('g_table_owner='||g_table_owner);
  write_to_log_file('g_ilog='||g_ilog);
  write_to_log_file('g_dlog='||g_dlog);
  write_to_log_file('p_fact_dlog='||p_fact_dlog);
  write_to_log_file('p_op_table_space='||p_op_table_space);
  write_to_log_file('p_rollback='||p_rollback);
  write_to_log_file('p_src_join_nl_percentage='||p_src_join_nl_percentage);
  write_to_log_file('g_thread_type='||g_thread_type);
  if g_fresh_restart then
    write_to_log_file('g_fresh_restart is TRUE');
  else
    write_to_log_file('g_fresh_restart is FALSE');
  end if;
  g_ins_rows_processed:=0;
  g_ins_rows_dangling :=0;
  g_ins_rows_duplicate :=0;
  g_ins_rows_error :=0;
  p_ins_rows_processed:=0;
  init_all; --sets the temp table and iv name
  if get_fact_fks = false then --get all the fks of the derived fact
    write_to_log_file_n('get_fact_fks returned with false');
    return false;
  end if;
  l_pre_hook:='N';
  l_post_hook:='N';
  if EDW_DERIVED_FACT_FACT_COLLECT.COLLECT_FACT(
    g_fact_name,
    g_fact_id,
    g_mapping_ids(g_number_mapping_ids),
    g_src_objects(g_number_mapping_ids),
    g_src_object_ids(g_number_mapping_ids),
    g_fact_fks,
    g_higher_level,
    g_parent_dim,
    g_parent_level,
    g_level_prefix,
    g_level_pk,
    g_level_pk_key,
    g_dim_pk_key,
    g_number_fact_fks,
    p_conc_id,
    p_conc_program_name,
    g_debug,
    g_collection_size,
    g_parallel,
    g_bis_owner,
    g_table_owner,
    p_ins_rows_processed,
    false,
    g_ilog,
    g_dlog,
    g_forall_size,
    p_update_type,
    p_fact_dlog,
    p_skip_cols,
    p_number_skip_cols,
    p_load_fk,
    g_fresh_restart,
    p_op_table_space,
    p_bu_tables,
    p_bu_dimensions,
    p_number_bu_tables,
    p_bu_src_fact,
    p_load_mode,
    p_rollback,
    p_src_join_nl_percentage,
    l_pre_hook,
    l_post_hook
    ) = false then
    write_to_log_file_n('EDW_DERIVED_FACT_FACT_COLLECT.COLLECT_FACT returned with error '||get_time);
    g_status_message:=EDW_DERIVED_FACT_FACT_COLLECT.get_status_message;
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in COLLECT_FACT '||sqlerrm||get_time);
 return false;
End;

/*
Given a Base fact, refresh all the derv facts
This has inputs
1. the src fact
Best design is where each base fact to derv fact refresh is a conc program
*/
FUNCTION COLLECT_FACT_INC(
  p_src_fact_name varchar2,
  p_src_fact_id number,
  p_derived_facts EDW_OWB_COLLECTION_UTIL.varcharTableType,
  p_derived_fact_ids EDW_OWB_COLLECTION_UTIL.numberTableType,
  p_map_ids EDW_OWB_COLLECTION_UTIL.numberTableType,
  p_number_derived_facts number,
  p_conc_id in number,
  p_conc_program_name in varchar2,
  p_debug boolean,
  p_collection_size number,
  p_parallel  number,
  p_bis_owner varchar2,
  p_table_owner varchar2,--src fact owner
  p_load_pk out nocopy EDW_OWB_COLLECTION_UTIL.numberTableType,
  p_ins_rows_processed out NOCOPY EDW_OWB_COLLECTION_UTIL.numberTableType,
  p_status out nocopy EDW_OWB_COLLECTION_UTIL.varcharTableType,
  p_message out nocopy EDW_OWB_COLLECTION_UTIL.varcharTableType,
  p_number_derv_facts out nocopy number,
  p_forall_size number,
  p_update_type varchar2,
  p_fact_dlog varchar2,
  p_fresh_restart boolean,
  p_op_table_space varchar2,
  p_bu_tables EDW_OWB_COLLECTION_UTIL.varcharTableType,--before update tables.prop dim change to derv
  p_bu_dimensions EDW_OWB_COLLECTION_UTIL.varcharTableType,
  p_number_bu_tables number,
  p_bu_src_fact varchar2,--what table to look at as the src fact. if null, scan the actual src fact
  p_load_mode varchar2,
  p_rollback varchar2,
  p_src_join_nl_percentage number,
  p_thread_type varchar2,
  p_max_threads number,
  p_min_job_load_size number,
  p_sleep_time number,
  p_hash_area_size number,
  p_sort_area_size number,
  p_trace boolean,
  p_read_cfig_options boolean,
  p_job_queue_processes number
)return boolean is
ll_derived_facts EDW_OWB_COLLECTION_UTIL.varcharTableType;
ll_derived_fact_ids EDW_OWB_COLLECTION_UTIL.numberTableType;
ll_map_ids EDW_OWB_COLLECTION_UTIL.numberTableType;
ll_number_derived_facts number;
l_derived_facts EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_derived_fact_ids EDW_OWB_COLLECTION_UTIL.numberTableType;
l_map_ids EDW_OWB_COLLECTION_UTIL.numberTableType;
l_number_derived_facts number;
i integer;
l_end integer;
l_job_id EDW_OWB_COLLECTION_UTIL.numberTableType;
l_job_status EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_count number;
l_diff number;
l_pre_hook varchar2(10);
l_post_hook varchar2(10);
l_skip_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_skip_cols number;
l_found boolean;
l_job_status_table EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_input_table EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_ilog EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_dlog EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_start_date date;
l_end_date date;
l_looked_at EDW_OWB_COLLECTION_UTIL.numberTableType;
l_number_looked_at number;
l_bool_flag boolean;
l_log_file varchar2(200);
l_number_jobs number;
l_max_main_jobs integer;
--------------------------------------
l_temp_conc_name varchar2(200);
l_temp_conc_short_name varchar2(200);
l_temp_exe_name varchar2(200);
l_bis_short_name varchar2(100);
l_flag boolean;
l_parallel_flag varchar2(10);
l_try_serial boolean;
-------------------------------------
l_errbuf varchar2(2000);
l_retcode varchar2(200);
-------------------------------------
Begin
  g_debug:=p_debug;
  if g_debug then
    write_to_log_file_n('In COLLECT_FACT_INC where the src and derived facts are specified');
    write_to_log_file('p_src_fact_name='||p_src_fact_name);
    write_to_log_file('p_max_threads='||p_max_threads||', p_thread_type='||p_thread_type);
  end if;
  g_collection_size:=p_collection_size;
  g_parallel:=p_parallel;
  g_bis_owner:=p_bis_owner;
  g_table_owner:=p_table_owner;
  g_forall_size:=p_forall_size;
  g_fresh_restart:=p_fresh_restart;
  g_thread_type:=p_thread_type;
  l_pre_hook:='Y';
  l_post_hook:='Y';
  l_number_looked_at:=0;
  l_temp_conc_name:='Sub-Proc DFInc-'||p_src_fact_id;
  l_temp_conc_short_name:='CONC_FINC_'||p_src_fact_id||'_CONC';
  l_temp_exe_name:='EXE_FINC_'||p_src_fact_id||'_EXE';
  l_bis_short_name:='BIS';
  l_parallel_flag:='N';
  --is derv facts are specified, use them. else use
  if p_number_derived_facts=0 or p_number_derived_facts is null then
    if EDW_OWB_COLLECTION_UTIL.get_all_derived_facts(
      p_src_fact_name,
      ll_derived_facts,
      ll_derived_fact_ids,
      ll_map_ids,--the map id of the derived fact and this source fact
      ll_number_derived_facts)=false then
      g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
      return false;
    end if;
    l_number_derived_facts:=0;
    for i in 1..ll_number_derived_facts loop
      if EDW_OWB_COLLECTION_UTIL.is_inc_refresh_implemented(ll_derived_facts(i))=true then
        l_number_derived_facts:=l_number_derived_facts+1;
        l_derived_facts(l_number_derived_facts):=ll_derived_facts(i);
        l_derived_fact_ids(l_number_derived_facts):=ll_derived_fact_ids(i);
        l_map_ids(l_number_derived_facts):=ll_map_ids(i);
      end if;
    end loop;
  else
    l_derived_facts:=p_derived_facts;
    l_derived_fact_ids:=p_derived_fact_ids;
    l_map_ids:=p_map_ids;
    l_number_derived_facts:=p_number_derived_facts;
  end if;
  if g_debug then
    write_to_log_file_n('The derived facts for inc update');
    for i in 1..l_number_derived_facts loop
      write_to_log_file(l_derived_facts(i)||' '||l_derived_fact_ids(i)||' '||l_map_ids(i));
    end loop;
  end if;
  if l_number_derived_facts>0 then
    if p_max_threads>1 then
      if g_debug then
        write_to_log_file_n('Multi threaded');
      end if;
      l_parallel_flag:='Y';
      if g_thread_type='CONC' then
        if create_conc_program(l_temp_conc_name,l_temp_conc_short_name,l_temp_exe_name,l_bis_short_name)=false then
          g_thread_type:='JOB';
        end if;
      end if;
      if g_debug then
        if g_thread_type='CONC' then
          write_to_log_file_n('Use Concurrent Requests');
        else
          write_to_log_file_n('DONT Use Concurrent Requests');
        end if;
      end if;
      if g_thread_type='CONC' then
        l_max_main_jobs:=p_max_threads;--launch as many as possible
      else
        l_max_main_jobs:=trunc(p_job_queue_processes/(p_max_threads+1))+
        sign(mod(p_job_queue_processes,(p_max_threads+1)));
      end if;
      if l_max_main_jobs<=0 then
        l_max_main_jobs:=1;
      end if;
      if g_debug then
        write_to_log_file_n('l_max_main_jobs='||l_max_main_jobs);
        if g_thread_type='JOB' then
          write_to_log_file_n('Use Jobs, Parallel operation');
        elsif g_thread_type='CONC' then
          write_to_log_file_n('Use Concurrent Requests, Parallel operation');
        else
          write_to_log_file_n('Serial operation');
        end if;
      end if;
      i:=0;
      loop
        if i<=l_number_derived_facts then
          l_count:=0;
          for j in 1..i loop
            if l_job_status(j)='R' then
              l_count:=l_count+1;
            end if;
          end loop;
          l_diff:=l_max_main_jobs-l_count;--how many are active at each time
          l_end:=i+l_diff;
          if l_diff>0 then
            --launch more threads
            loop
              i:=i+1;
              if i>l_number_derived_facts then
                exit;
              end if;
              if i>l_end then
                i:=i-1;
                exit;
              end if;
              g_fact_name:=l_derived_facts(i);
              g_fact_id:=l_derived_fact_ids(i);
              g_number_mapping_ids:=1;--we are looking at this mapping only
              g_mapping_ids(g_number_mapping_ids):=l_map_ids(i);
              g_src_objects(g_number_mapping_ids):=p_src_fact_name;
              g_src_object_ids(g_number_mapping_ids):=p_src_fact_id;
              g_number_fact_fks:=0;
              if get_fact_fks = false then --get all the fks of the derived fact
                return false;
              end if;
              p_load_pk(i):=EDW_OWB_COLLECTION_UTIL.inc_g_load_pk ;
              if p_load_pk(i) is null then
                return false;
              end if;
              l_number_skip_cols:=0;
              if EDW_OWB_COLLECTION_UTIL.find_skip_attributes(l_derived_facts(i),'DERIVED FACT',l_skip_cols,
                l_number_skip_cols)=false then
                return false;
              end if;
              l_start_date:=sysdate;
              if EDW_OWB_COLLECTION_UTIL.log_collection_start(l_derived_facts(i),l_derived_fact_ids(i),
                'FACT',l_start_date,p_conc_id,p_load_pk(i))=false then
                return false;
              end if;
              p_ins_rows_processed(i):=0;
              --l_ilog(i):=g_bis_owner||'.I_'||p_src_fact_id||'_'||l_derived_fact_ids(i);
              --l_dlog(i):=g_bis_owner||'.D_'||p_src_fact_id||'_'||l_derived_fact_ids(i);
              l_ilog(i):=edw_owb_collection_util.get_fact_dfact_ilog(g_bis_owner,p_src_fact_id,l_derived_fact_ids(i));
              l_dlog(i):=edw_owb_collection_util.get_fact_dfact_dlog(g_bis_owner,p_src_fact_id,l_derived_fact_ids(i));
              l_input_table(i):=g_bis_owner||'.INP_TAB_'||p_src_fact_id||'_'||l_derived_fact_ids(i);
              l_log_file:='LOG_'||p_src_fact_id||'_'||l_derived_fact_ids(i);
              l_job_status_table(i):=g_bis_owner||'.JOB_STATUS_'||p_src_fact_id||'_'||l_derived_fact_ids(i);
              if EDW_OWB_COLLECTION_UTIL.create_derv_fact_inp_table(
                l_derived_facts(i),
                l_input_table(i),
                l_derived_fact_ids(i),
                l_map_ids(i),
                p_src_fact_name,
                p_src_fact_id,
                g_fact_fks,
                g_higher_level,
                g_parent_dim,
                g_parent_level,
                g_level_prefix,
                g_level_pk,
                g_level_pk_key,
                g_dim_pk_key,
                g_number_fact_fks,
                p_conc_id,
                p_conc_program_name,
                g_debug,
                g_collection_size,
                g_parallel,
                g_bis_owner,
                g_table_owner,
                false,--full refresh
                g_forall_size,
                p_update_type,
                p_fact_dlog,
                l_skip_cols,
                l_number_skip_cols,
                p_load_pk(i),
                g_fresh_restart,
                p_op_table_space,
                p_bu_tables,
                p_bu_dimensions,
                p_number_bu_tables,
                p_bu_src_fact,
                p_load_mode,
                p_rollback,
                p_src_join_nl_percentage,
                p_max_threads,
                p_min_job_load_size,
                p_sleep_time,
                l_job_status_table(i),
                p_hash_area_size,
                p_sort_area_size,
                p_trace,
                p_read_cfig_options
                )=false then
                return false;
              end if;
              /*
              Launch the thread
              */
              begin
                l_try_serial:=false;
                if g_thread_type='CONC' then
                  if g_debug then
                    write_to_log_file_n('Launch conc process '||l_temp_conc_name||' '||i);
                  end if;
                  if g_debug then
                    write_to_log_file_n('EDW_DERIVED_FACT_FACT_COLLECT.COLLECT_FACT_MULTI_THREAD('''||g_fact_name||''','||
                    g_fact_id||','''||l_log_file||''','''||l_input_table(i)||''','''||l_ilog(i)||''','''||l_dlog(i)||''','''||
                    l_pre_hook||''','''||l_post_hook||''','''||g_thread_type||''');');
                  end if;
                  l_flag:=true;
                  l_job_status(i):='R';
                  if EDW_OWB_COLLECTION_UTIL.update_inp_table_jobid(l_input_table(i),-1)=false then
                    return false;
                  end if;
                  l_job_id(i):=FND_REQUEST.SUBMIT_REQUEST(
                  application=>l_bis_short_name,
                  program=>l_temp_conc_short_name,
                  argument1=>g_fact_name,
                  argument2=>g_fact_id,
                  argument3=>l_log_file,
                  argument4=>l_input_table(i),
                  argument5=>l_ilog(i),
                  argument6=>l_dlog(i),
                  argument7=>l_pre_hook,
                  argument8=>l_post_hook,
                  argument9=>g_thread_type);
                  if EDW_OWB_COLLECTION_UTIL.update_inp_table_concid(l_input_table(i),l_job_id(i))=false then
                    return false;
                  end if;
                  if l_job_id(i)<=0 then
                    l_try_serial:=true;
                  end if;
                  commit;--commit very imp, starts the conc request
                else --here g_thread_type='JOB'
                  if g_debug then
                    write_to_log_file_n('EDW_DERIVED_FACT_FACT_COLLECT.COLLECT_FACT_MULTI_THREAD('''||g_fact_name||''','||
                    g_fact_id||','''||l_log_file||''','''||l_input_table(i)||''','''||l_ilog(i)||''','''||l_dlog(i)||''','''||
                    l_pre_hook||''','''||l_post_hook||''','''||g_thread_type||''');');
                  end if;
                  DBMS_JOB.SUBMIT(l_job_id(i),'EDW_DERIVED_FACT_FACT_COLLECT.COLLECT_FACT_MULTI_THREAD('''||
                  g_fact_name||''','||g_fact_id||','''||l_log_file||''','''||l_input_table(i)||''','''||
                  l_ilog(i)||''','''||l_dlog(i)||''','''||l_pre_hook||''','''||l_post_hook||''','''||
                  g_thread_type||''');');
                  l_job_status(i):='R';
                  if g_debug then
                    write_to_log_file_n('Job '||l_job_id(i)||' launched for '||g_fact_name||' and '||
                    p_src_fact_name||get_time);
                  end if;
                  /*
                  update the inp table for the job id
                  */
                  if EDW_OWB_COLLECTION_UTIL.update_inp_table_jobid(l_input_table(i),l_job_id(i))=false then
                    return false;
                  end if;
                  if l_job_id(i)<=0 then
                    l_try_serial:=true;
                  end if;
                  commit;--commit only after updating the inp table
                end if;
              exception when others then
                if g_debug then
                  write_to_log_file_n('Error '||sqlerrm||'. Attemting a serial load '||get_time);
                end if;
                l_try_serial:=true;
              end;
              if l_try_serial then
                if g_debug then
                  write_to_log_file_n('Attempt serial load');
                end if;
                l_job_id(i):=0-i;--this is just a temp setting. There is really no job. we need this for log_collection_detail
                if EDW_OWB_COLLECTION_UTIL.update_inp_table_jobid(l_input_table(i),l_job_id(i))=false then
                  return false;
                end if;
                commit;
                l_job_status(i):='R';
                EDW_DERIVED_FACT_FACT_COLLECT.COLLECT_FACT_MULTI_THREAD(
                l_errbuf,
                l_retcode,
                g_fact_name,
                g_fact_id,
                l_log_file,
                l_input_table(i),
                l_ilog(i),
                l_dlog(i),
                l_pre_hook,
                l_post_hook,
                g_thread_type
                );
                l_job_status(i):='Y';
              end if;
            end loop;
          end if;
        else --here i>g_number_mapping_ids
          --see if there are any threads still running. if yes, must wait. else exit.
          if i>l_number_derived_facts then
            l_number_jobs:=l_number_derived_facts;
          else
            l_number_jobs:=i;
          end if;
          l_found:=false;
          for j in 1..l_number_jobs loop
            if l_job_status(j)='R' then
              l_found:=true;
            end if;
          end loop;
          if l_found=false then
            --all processes are done.
            exit;
          end if;
        end if;
        if i>l_number_derived_facts then
          l_number_jobs:=l_number_derived_facts;
        else
          l_number_jobs:=i;
        end if;
        --wait for threads or conc requests
        if wait_on_jobs(
          l_job_id,
          l_job_status,
          l_number_jobs,
          p_sleep_time,
          g_thread_type)=false then
          return false;
        end if;
        for j in 1..l_number_jobs loop
          if l_job_status(j)<>'R' and EDW_OWB_COLLECTION_UTIL.value_in_table(l_looked_at,l_number_looked_at,
            l_job_id(j))=false then
            if get_temp_log_data(g_fact_name,'FACT',p_load_pk(j),p_ins_rows_processed(j))=false then
              null;
            end if;
            if g_debug then
              write_to_log_file_n('Job '||l_job_id(j)||' rows processed '||p_ins_rows_processed(j));
            end if;
            if get_child_job_status(l_job_status_table(j),p_status(j),p_message(j))=false then
              null;
            end if;
            if p_status(j)='SUCCESS' then
              p_message(j):='Processed '||p_ins_rows_processed(j)||' Rows';
            end if;
            l_end_date:=sysdate;
            if log_collection_detail(
              g_fact_name,
              g_fact_id,
              'FACT',
              p_conc_id,
              l_start_date,
              l_end_date,
              p_ins_rows_processed(j),
              p_ins_rows_processed(j),
              p_ins_rows_processed(j),
              null,
              null,
              null,
              p_message(j),
              p_status(j),
              p_load_pk(j)
              )=false then
              null;
            end if;
            l_number_looked_at:=l_number_looked_at+1;
            l_looked_at(l_number_looked_at):=l_job_id(j);
          end if;
        end loop;
        /*must calculate rows processed per thread
          must also call something similar to return_with_success
          must have delete_object_log_tables and inp tables etc
          must terminate jobs if there is error
        */
      end loop;
      --drop the inp tables and the status tables
      for i in 1..l_number_derived_facts loop
        if p_status(i)='SUCCESS' then
          if drop_inp_status_table(l_input_table(i),l_job_status_table(i))=false then
            null;
          end if;
        end if;
      end loop;
      --dont delete the conc pgm. we may need the conc request log file
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
    else --single thread
      for i in 1..l_number_derived_facts loop
        g_fact_name:=l_derived_facts(i);
        g_fact_id:=l_derived_fact_ids(i);
        g_number_mapping_ids:=1;--we are looking at this mapping only
        g_mapping_ids(g_number_mapping_ids):=l_map_ids(i);
        g_src_objects(g_number_mapping_ids):=p_src_fact_name;
        g_src_object_ids(g_number_mapping_ids):=p_src_fact_id;
        if get_fact_fks = false then --get all the fks of the derived fact
          return false;
        end if;
        p_load_pk(i):=EDW_OWB_COLLECTION_UTIL.inc_g_load_pk ;
        if p_load_pk(i) is null then
          return false;
        end if;
        if EDW_OWB_COLLECTION_UTIL.find_skip_attributes(l_derived_facts(i),'DERIVED FACT',l_skip_cols,
          l_number_skip_cols)=false then
          return false;
        end if;
        if EDW_OWB_COLLECTION_UTIL.log_collection_start(l_derived_facts(i),l_derived_fact_ids(i),
          'FACT',sysdate,p_conc_id,p_load_pk(i))=false then
          return false;
        end if;
        p_ins_rows_processed(i):=0;
        l_start_date:=sysdate;
        --l_ilog(i):=g_bis_owner||'.I_'||p_src_fact_id||'_'||l_derived_fact_ids(i);
        --l_dlog(i):=g_bis_owner||'.D_'||p_src_fact_id||'_'||l_derived_fact_ids(i);
        l_ilog(i):=edw_owb_collection_util.get_fact_dfact_ilog(g_bis_owner,p_src_fact_id,l_derived_fact_ids(i));
        l_dlog(i):=edw_owb_collection_util.get_fact_dfact_dlog(g_bis_owner,p_src_fact_id,l_derived_fact_ids(i));
        l_bool_flag:=EDW_DERIVED_FACT_FACT_COLLECT.COLLECT_FACT(
        g_fact_name,
        g_fact_id,
        g_mapping_ids(g_number_mapping_ids),
        g_src_objects(g_number_mapping_ids),
        g_src_object_ids(g_number_mapping_ids),
        g_fact_fks,
        g_higher_level,
        g_parent_dim,
        g_parent_level,
        g_level_prefix,
        g_level_pk,
        g_level_pk_key,
        g_dim_pk_key,
        g_number_fact_fks,
        p_conc_id,
        p_conc_program_name,
        g_debug,
        g_collection_size,
        g_parallel,
        g_bis_owner,
        g_table_owner,
        p_ins_rows_processed(i),
        false,
        l_ilog(i),
        l_dlog(i),
        g_forall_size,
        p_update_type,
        p_fact_dlog,
        l_skip_cols,
        l_number_skip_cols,
        p_load_pk(i),
        g_fresh_restart,
        p_op_table_space,
        p_bu_tables,
        p_bu_dimensions,
        p_number_bu_tables,
        p_bu_src_fact,
        p_load_mode,
        p_rollback,
        p_src_join_nl_percentage,
        l_pre_hook,
        l_post_hook
        );
        if l_bool_flag=false then
          g_status_message:=EDW_DERIVED_FACT_FACT_COLLECT.get_status_message;
          p_status(i):='ERROR';
          p_message(i):=g_status_message;
        else
          p_status(i):='SUCCESS';
          p_message(i):='Processed '||p_ins_rows_processed(i)||' Rows';
        end if;
        l_end_date:=sysdate;
        if log_collection_detail(
          g_fact_name,
          g_fact_id,
          'FACT',
          p_conc_id,
          l_start_date,
          l_end_date,
          p_ins_rows_processed(i),
          p_ins_rows_processed(i),
          p_ins_rows_processed(i),
          null,
          null,
          null,
          p_message(i),
          p_status(i),
          p_load_pk(i)
          )=false then
          null;
        end if;
      end loop;
    end if;
  else
    if g_debug then
      write_to_log_file_n('Not a source for any derived fact');
    end if;
  end if;
  /*
  drop the ilog and dlog after truncating the base fact snapshot log
  this is to be done only if all loads are a sucsess
  */
  l_bool_flag:=true;
  for i in 1..l_number_derived_facts loop
    if p_status(i)='ERROR' then
      l_bool_flag:=false;
      exit;
    end if;
  end loop;
  if l_bool_flag then
    if delete_object_log_tables(
      p_src_fact_name,
      p_table_owner,
      p_bis_owner,
      p_fact_dlog,
      l_ilog,
      l_dlog,
      l_number_derived_facts)=false then
      return false;
    end if;
  end if;
  return l_bool_flag;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in COLLECT_FACT_INC '||sqlerrm||get_time);
 return false;
End;

/*
given a derv fact, do a full refresh
this api is for the case where only the derived fact is specified and it does collection of
all source facts to the derived fact. when this api is called, it must do a full refresh of the
derived fact
*/
FUNCTION COLLECT_FACT(
  p_fact_name varchar2,
  p_conc_id in number,
  p_conc_program_name in varchar2,
  p_debug boolean,
  p_collection_size number,
  p_parallel  number,
  p_bis_owner varchar2,
  p_table_owner varchar2,
  p_ins_rows_processed out NOCOPY number,
  p_forall_size number,
  p_update_type varchar2,
  p_skip_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
  p_number_skip_cols number,
  p_load_fk number,
  p_fresh_restart boolean,
  p_op_table_space varchar2,
  p_rollback varchar2,
  p_src_join_nl_percentage number,
  p_thread_type varchar2,
  p_max_threads number,
  p_min_job_load_size number,
  p_sleep_time number,
  p_hash_area_size number,
  p_sort_area_size number,
  p_trace boolean,
  p_read_cfig_options boolean
) return boolean is
l_ins_rows_processed number;
l_bu_tables EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_bu_dimensions EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_bu_tables number:=0;
l_bu_src_fact varchar2(400):=null;
l_load_mode varchar2(400);
l_input_table EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_job_id EDW_OWB_COLLECTION_UTIL.numberTableType;
l_job_status EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_jobs number;
l_count number;
l_diff number;
i integer;
l_end integer;
l_found boolean;
l_log_file varchar2(200);
l_pre_hook varchar2(10);
l_post_hook varchar2(10);
l_job_status_table EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_ilog EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_dlog EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_start_date date;
l_end_date date;
l_status EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_message EDW_OWB_COLLECTION_UTIL.varcharTableType;
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
begin
 --get the fks and the mapping details;
 g_fact_name:=p_fact_name;
 g_debug:=p_debug;
 g_collection_size:=p_collection_size;
 g_parallel:=p_parallel;
 g_ins_rows_processed:=0;
 g_ins_rows_dangling :=0;
 g_ins_rows_duplicate :=0;
 g_ins_rows_error :=0;
 p_ins_rows_processed:=0;
 g_bis_owner:=p_bis_owner;
 g_table_owner:=p_table_owner;
 g_forall_size:=p_forall_size;
 g_fresh_restart:=p_fresh_restart;
 g_thread_type:=p_thread_type;
 l_number_jobs:=0;
 write_to_log_file_n('In COLLECT_FACT where only the derived facts is specified, Full Refresh');
 write_to_log_file('g_fact_name='||g_fact_name);
 write_to_log_file('g_collection_size='||g_collection_size);
 write_to_log_file('g_parallel='||g_parallel);
 write_to_log_file('g_bis_owner='||g_bis_owner);
 write_to_log_file('g_table_owner='||g_table_owner);
 write_to_log_file('p_op_table_space='||p_op_table_space);
 write_to_log_file('p_rollback='||p_rollback);
 write_to_log_file('p_src_join_nl_percentage='||p_src_join_nl_percentage);
 write_to_log_file('g_thread_type='||g_thread_type);
 if g_fresh_restart then
    write_to_log_file('g_fresh_restart is TRUE');
 else
   write_to_log_file('g_fresh_restart is FALSE');
 end if;
 init_all;
 if get_fact_id = false then
   return false;
 end if;
 if get_fact_fks = false then
   return false;
 end if;
 if get_fact_mappings = false then
   return false;
 end if;
 --first truncate the derived fact
 if truncate_derived_fact=false then
   write_to_log_file_n('truncate_derived_fact returned with error');
   return false;
 end if;
 --pre hook and post hook only for inc refresh
 l_pre_hook:='N';
 l_post_hook:='N';
 if p_max_threads>1 then
   if g_debug then
     write_to_log_file_n('Multi threaded');
   end if;
   l_number_jobs:=0;
   i:=0;
   l_temp_conc_name:='Sub-Proc DFFull-'||g_fact_id;
   l_temp_conc_short_name:='CONC_FFULL_'||g_fact_id||'_CONC';
   l_temp_exe_name:='EXE_FFULL_'||g_fact_id||'_EXE';
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
   loop
     if i<=g_number_mapping_ids then
       l_count:=0;
       for j in 1..l_number_jobs loop
         if l_job_status(j)='R' then
           l_count:=l_count+1;
         end if;
       end loop;
       l_diff:=p_max_threads-l_count;
       l_end:=i+l_diff;
       if l_diff>0 then
         --launch more threads
         loop
           i:=i+1;
           if i>g_number_mapping_ids then
             exit;
           end if;
           if i>l_end then
             i:=i-1;
             exit;
           end if;
           l_ins_rows_processed:=0;
           --l_ilog(i):=g_bis_owner||'.I_'||g_fact_id||'_'||g_src_object_ids(i);
           --l_dlog(i):=g_bis_owner||'.D_'||g_fact_id||'_'||g_src_object_ids(i);
           l_ilog(i):=edw_owb_collection_util.get_fact_dfact_ilog(g_bis_owner,g_fact_id,g_src_object_ids(i));
           l_dlog(i):=edw_owb_collection_util.get_fact_dfact_dlog(g_bis_owner,g_fact_id,g_src_object_ids(i));
           l_input_table(i):=g_bis_owner||'.INP_TAB_'||g_fact_id||'_'||g_src_object_ids(i);
           l_log_file:='LOG_'||g_fact_id||'_'||g_src_object_ids(i);
           l_job_status_table(i):=g_bis_owner||'.JOB_STATUS_'||g_fact_id||'_'||g_src_object_ids(i);
           if EDW_OWB_COLLECTION_UTIL.create_derv_fact_inp_table(
             g_fact_name,
             l_input_table(i),
             g_fact_id,
             g_mapping_ids(i),
             g_src_objects(i),
             g_src_object_ids(i),
             g_fact_fks,
             g_higher_level,
             g_parent_dim,
             g_parent_level,
             g_level_prefix,
             g_level_pk,
             g_level_pk_key,
             g_dim_pk_key,
             g_number_fact_fks,
             p_conc_id,
             p_conc_program_name,
             g_debug,
             g_collection_size,
             g_parallel,
             g_bis_owner,
             g_table_owner,
             true,--full refresh
             g_forall_size,
             p_update_type,
             null,
             p_skip_cols,
             p_number_skip_cols,
             p_load_fk,
             g_fresh_restart,
             p_op_table_space,
             l_bu_tables,
             l_bu_dimensions,
             l_number_bu_tables,
             l_bu_src_fact,
             l_load_mode,
             p_rollback,
             p_src_join_nl_percentage,
             p_max_threads,
             p_min_job_load_size,
             p_sleep_time,
             l_job_status_table(i),
             p_hash_area_size,
             p_sort_area_size,
             p_trace,
             p_read_cfig_options
             )=false then
             return false;
           end if;
           /*
           Launch the thread
           */
           l_number_jobs:=l_number_jobs+1;
           if g_debug then
             write_to_log_file_n('EDW_DERIVED_FACT_FACT_COLLECT.COLLECT_FACT_MULTI_THREAD('''||g_fact_name||''','||
             g_fact_id||','''||l_log_file||''','''||l_input_table(i)||''','''||l_ilog(i)||''','''||l_dlog(i)||''','''||
             l_pre_hook||''','''||l_post_hook||''','''||g_thread_type||''');');
           end if;
           begin
             l_try_serial:=false;
             if g_thread_type='CONC' then
               l_job_id(l_number_jobs):=FND_REQUEST.SUBMIT_REQUEST(
               application=>l_bis_short_name,
               program=>l_temp_conc_short_name,
               argument1=>g_fact_name,
               argument2=>g_fact_id,
               argument3=>l_log_file,
               argument4=>l_input_table(i),
               argument5=>l_ilog(i),
               argument6=>l_dlog(i),
               argument7=>l_pre_hook,
               argument8=>l_post_hook,
               argument9=>g_thread_type);
               l_job_status(l_number_jobs):='R';
               if g_debug then
                 write_to_log_file_n('Concurrent Request '||l_job_id(l_number_jobs)||' launched for '||g_fact_name||' and '||
                 g_src_objects(i)||get_time);
               end if;
               if EDW_OWB_COLLECTION_UTIL.update_inp_table_jobid(l_input_table(i),l_job_id(l_number_jobs))=false then
                 return false;
               end if;
               if l_job_id(l_number_jobs)<=0 then
                 l_try_serial:=true;
               end if;
               commit;--commit only after updating the inp table
             else
               DBMS_JOB.SUBMIT(l_job_id(l_number_jobs),'EDW_DERIVED_FACT_FACT_COLLECT.COLLECT_FACT_MULTI_THREAD('''||
               g_fact_name||''','||g_fact_id||','''||l_log_file||''','''||l_input_table(i)||''','''||
               l_ilog(i)||''','''||l_dlog(i)||''','''||l_pre_hook||''','''||l_post_hook||''','''||g_thread_type||
               ''');');
               l_job_status(l_number_jobs):='R';
               if g_debug then
                 write_to_log_file_n('Job '||l_job_id(l_number_jobs)||' launched for '||g_fact_name||' and '||
                 g_src_objects(i)||get_time);
               end if;
               if EDW_OWB_COLLECTION_UTIL.update_inp_table_jobid(l_input_table(i),l_job_id(l_number_jobs))=false then
                 return false;
               end if;
               if l_job_id(l_number_jobs)<=0 then
                 l_try_serial:=true;
               end if;
               commit;--commit only after updating the inp table
             end if;
           exception when others then
             if g_debug then
               write_to_log_file_n('Error launching dbms job '||sqlerrm||'. Attempting serial load'||
               get_time);
             end if;
             l_try_serial:=true;
           end;
           if l_try_serial then
             if g_debug then
               write_to_log_file_n('Attempt serial load');
             end if;
             l_job_id(l_number_jobs):=0-i;--give negative ids
             if EDW_OWB_COLLECTION_UTIL.update_inp_table_jobid(l_input_table(i),l_job_id(l_number_jobs))=false then
               return false;
             end if;
             commit;--commit only after updating the inp table
             EDW_DERIVED_FACT_FACT_COLLECT.COLLECT_FACT_MULTI_THREAD(
             l_errbuf,
             l_retcode,
             g_fact_name,
             g_fact_id,
             l_log_file,
             l_input_table(i),
             l_ilog(i),
             l_dlog(i),
             l_pre_hook,
             l_post_hook,
             g_thread_type
             );
             l_job_status(l_number_jobs):='Y';
           end if;
         end loop;
       end if;
     else --here i>g_number_mapping_ids
       --see if there are any threads still running. if yes, must wait. else exit.
       l_found:=false;
       for j in 1..l_number_jobs loop
         if l_job_status(j)='R' then
           l_found:=true;
         end if;
       end loop;
       if l_found=false then
         --all processes are done.
         exit;
       end if;
     end if;
     --wait for threads
     if wait_on_jobs(
       l_job_id,
       l_job_status,
       l_number_jobs,
       p_sleep_time,
       g_thread_type)=false then
       return false;
     end if;
   end loop;
   for i in 1..g_number_mapping_ids loop
     if get_child_job_status(l_job_status_table(i),l_status(i),l_message(i))=false then
       null;
     end if;
     if g_debug then
       write_to_log_file_n('Job '||l_job_id(i)||' status '||l_status(i)||', message '||l_message(i));
     end if;
     if l_status(i)='ERROR' then
       g_status_message:=l_message(i);
       return false;
     end if;
   end loop;
   --drop the inp tables and the status tables
   for i in 1..g_number_mapping_ids loop
     if drop_inp_status_table(l_input_table(i),l_job_status_table(i))=false then
       null;
     end if;
   end loop;
 else
   if g_debug then
     write_to_log_file_n('Single thread');
   end if;
   for i in 1..g_number_mapping_ids loop
     --call the detailed fact to fact collection
     l_ins_rows_processed:=0;
     --l_ilog(i):=g_bis_owner||'.I_'||g_fact_id||'_'||g_src_object_ids(i);
     --l_dlog(i):=g_bis_owner||'.D_'||g_fact_id||'_'||g_src_object_ids(i);
     l_ilog(i):=edw_owb_collection_util.get_fact_dfact_ilog(g_bis_owner,g_fact_id,g_src_object_ids(i));
     l_dlog(i):=edw_owb_collection_util.get_fact_dfact_dlog(g_bis_owner,g_fact_id,g_src_object_ids(i));
     if g_debug then
       write_to_log_file_n('Going to collect mapping: id='||g_mapping_ids(i)||', src='||g_src_objects(i));
     end if;
     -- the last true is for yes to full refresh
     if EDW_DERIVED_FACT_FACT_COLLECT.COLLECT_FACT(
       g_fact_name,
       g_fact_id,
       g_mapping_ids(i),
       g_src_objects(i),
       g_src_object_ids(i),
       g_fact_fks,
       g_higher_level,
       g_parent_dim,
       g_parent_level,
       g_level_prefix,
       g_level_pk,
       g_level_pk_key,
       g_dim_pk_key,
       g_number_fact_fks,
       p_conc_id,
       p_conc_program_name,
       g_debug,
       g_collection_size,
       g_parallel,
       g_bis_owner,
       g_table_owner,
       l_ins_rows_processed,
       true,
       l_ilog(i),
       l_dlog(i),
       g_forall_size,
       p_update_type,
       null,
       p_skip_cols,
       p_number_skip_cols,
       p_load_fk,
       g_fresh_restart,
       p_op_table_space,
       l_bu_tables,
       l_bu_dimensions,
       l_number_bu_tables,
       l_bu_src_fact,
       l_load_mode,
       p_rollback,
       p_src_join_nl_percentage,
       l_pre_hook,
       l_post_hook) = false then
       write_to_log_file_n('EDW_DERIVED_FACT_FACT_COLLECT.COLLECT_FACT returned with error '||get_time);
       g_status_message:=EDW_DERIVED_FACT_FACT_COLLECT.get_status_message;
       return false;
     else
       g_ins_rows_processed:=g_ins_rows_processed+l_ins_rows_processed;
       write_to_log_file_n('EDW_DERIVED_FACT_FACT_COLLECT.COLLECT_FACT returned with success '||get_time);
     end if;
   end loop;
 end if;
 p_ins_rows_processed:=g_ins_rows_processed;
 --drop the ilog and dlog table
 for i in 1..g_number_mapping_ids loop
   if EDW_OWB_COLLECTION_UTIL.drop_table(edw_owb_collection_util.get_fact_dfact_ilog(
     g_bis_owner,g_fact_id,g_src_object_ids(i)))= false then
     null;
   end if;
   if EDW_OWB_COLLECTION_UTIL.drop_table(edw_owb_collection_util.get_fact_dfact_ilog(
     g_bis_owner,g_fact_id,g_src_object_ids(i))||'A') = false then
     null;
   end if;
   if EDW_OWB_COLLECTION_UTIL.drop_table(edw_owb_collection_util.get_fact_dfact_dlog(
     g_bis_owner,g_fact_id,g_src_object_ids(i))) = false then
     null;
   end if;
   if EDW_OWB_COLLECTION_UTIL.drop_table(edw_owb_collection_util.get_fact_dfact_dlog(
     g_bis_owner,g_fact_id,g_src_object_ids(i))||'A') = false then
     null;
   end if;
 end loop;
 if g_debug then
   write_to_log_file_n('EDW_DERIVED_FACT_FACT_COLLECT.COLLECT_FACT done. Total rows processed ='||g_ins_rows_processed);
 end if;
 return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in COLLECT_FACT '||sqlerrm||get_time);
  return false;
End;

function truncate_derived_fact return boolean is
l_stmt varchar2(2000);
l_snplog varchar2(400);
Begin
  if g_debug then
    write_to_log_file_n('In truncate_derived_fact');
  end if;
  l_stmt:='truncate table '||g_table_owner||'.'||g_fact_name;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  execute immediate l_stmt;
  --truncate any snapshot log also
  l_snplog:=EDW_OWB_COLLECTION_UTIL.get_table_snapshot_log(g_fact_name);
  if l_snplog is not null then
    l_stmt:='truncate table '||g_table_owner||'.'||l_snplog;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt);
    end if;
    execute immediate l_stmt;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
 write_to_log_file_n(g_status_message);
 return false;
End;

function get_fact_id return boolean is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt varchar2(1000);
begin
 if g_debug then
   write_to_log_file_n('Entered get_fact_id');
 end if;
 l_stmt:='select fact_id from edw_facts_md_v where fact_name=:s';
 open cv for l_stmt using g_fact_name;
 fetch cv into g_fact_id;
 close cv;
 if g_debug then
   write_to_log_file_n('Finished get_fact_id');
 end if;
 return true;
Exception when others then
  begin
   close cv;
  exception when others then
   null;
  end;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_fact_id '||sqlerrm||' '||get_time);
  return false;
End;

function get_fact_fks return boolean is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt varchar2(10000);
l_fk_cons EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_in_stmt varchar2(10000);
l_lvl_name  EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_lvl_prefix  EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_lvl_dim  EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_lvl number;
l_prefix varchar2(100);
l_dim_fk  EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_prefix_fk  EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_dim_fk number;
begin
 if g_debug then
   write_to_log_file_n('Entered get_fact_fks');
 end if;
 l_stmt:='select fk_item.column_name, fk.foreign_key_name, dim.dim_name, '||
 'dim.dim_id,pk_item.column_name '||
 'from '||
 'edw_foreign_keys_md_v fk,  '||
 'edw_pvt_key_columns_md_v isu, '||
 'edw_pvt_columns_md_v fk_item, '||
 'edw_unique_keys_md_v pk, '||
 'edw_pvt_key_columns_md_v pisu,  '||
 'edw_pvt_columns_md_v pk_item, '||
 'edw_dimensions_md_v dim '||
 'where   '||
 'fk.entity_id=:a '||
 'and isu.key_id=fk.foreign_key_id '||
 'and fk_item.column_id=isu.column_id '||
 'and fk.key_id=pk.key_id '||
 'and pisu.key_id=pk.key_id '||
 'and pk_item.column_id=pisu.column_id '||
 'and dim.dim_id=pk.entity_id ';
 if g_debug then
   write_to_log_file_n('Going to execute '||l_stmt);
 end if;
 open cv for l_stmt using g_fact_id;
 g_number_fact_fks:=1;
 loop
   fetch cv into
    g_fact_fks(g_number_fact_fks),
    l_fk_cons(g_number_fact_fks),
    g_parent_dim(g_number_fact_fks),
    g_parent_dim_id(g_number_fact_fks),
    g_dim_pk_key(g_number_fact_fks);
   exit when cv%notfound;
   g_number_fact_fks:=g_number_fact_fks+1;
 end loop;
 close cv;
 g_number_fact_fks:=g_number_fact_fks-1;
 for i in 1..g_number_fact_fks loop
   g_higher_level(i):=false;
   g_level_prefix(i):=null;
   g_parent_level(i):=null;
   g_level_pk_key(i):=null;
   g_level_pk(i):=null;
 end loop;
 if g_debug then
   write_to_log_file('Results');
   for i in 1..g_number_fact_fks loop
     write_to_log_file(g_fact_fks(i)||' '||l_fk_cons(i)||' '||g_parent_dim(i)||' '||g_dim_pk_key(i));
   end loop;
 end if;
 --get the dim level prefix
 l_in_stmt:=null;
 for i in 1..g_number_fact_fks loop
   if i=1 then
     l_in_stmt:=l_in_stmt||''''||g_parent_dim(i)||'''';
   else
     l_in_stmt:=l_in_stmt||','''||g_parent_dim(i)||'''';
   end if;
 end loop;
 l_stmt:='select lvl.level_name,lvl.level_prefix, dim.dim_name from edw_dimensions_md_v dim, '||
 'edw_levels_md_v lvl where dim.dim_name in ('||l_in_stmt||') and lvl.dim_id=dim.dim_id';
 if g_debug then
   write_to_log_file_n('Going to execute '||l_stmt);
 end if;
 l_number_lvl:=1;
 open cv for l_stmt;
 loop
   fetch cv into l_lvl_name(l_number_lvl),l_lvl_prefix(l_number_lvl),l_lvl_dim(l_number_lvl);
   exit when cv%notfound;
   l_number_lvl:=l_number_lvl+1;
 end loop;
 close cv;
 l_number_lvl:=l_number_lvl-1;
 --find if the fks are pointing to higher levels
 for i in 1..g_number_fact_fks loop
   l_prefix:=substr(l_fk_cons(i),instr(l_fk_cons(i),'_',-1)+1,length(l_fk_cons(i)));
   if l_prefix <> l_fk_cons(i) then
     for j in 1..l_number_lvl loop
       if l_prefix=l_lvl_prefix(j) and g_parent_dim(i)=l_lvl_dim(j) then
         g_higher_level(i):=true;
         g_parent_level(i):=l_lvl_name(j);
         g_level_prefix(i):=l_prefix;
         exit;
       end if;
     end loop;
   end if;
 end loop;
 if g_debug then
   write_to_log_file_n('The keys that point to higher levels');
   for i in 1..g_number_fact_fks loop
     if g_higher_level(i) then
       write_to_log_file(g_fact_fks(i)||' '||l_fk_cons(i)||' '||g_parent_level(i)||' '||g_parent_dim(i));
     end if;
   end loop;
 end if;
 --for the higer levels, find the level pk and pk_key
 for i in 1..g_number_fact_fks loop
   if g_higher_level(i) then
     l_stmt:='select pk_item.column_name, substr(pk_item.column_name,1,instr(pk_item.column_name,''_'',1)-1) '||
     'from edw_unique_keys_md_v pk,edw_pvt_key_columns_md_v isu, edw_pvt_columns_md_v pk_item '||
     'where  pk.entity_id=:a and isu.key_id=pk.key_id and pk_item.column_id=isu.column_id';
     if g_debug then
       write_to_log_file_n('Going to execute '||l_stmt||' using '||g_parent_dim_id(i));
     end if;
     l_number_dim_fk:=1;
     open cv for l_stmt using g_parent_dim_id(i);
     loop
       fetch cv into l_dim_fk(l_number_dim_fk),l_prefix_fk(l_number_dim_fk);
       exit when cv%notfound;
       l_number_dim_fk:=l_number_dim_fk+1;
     end loop;
     close cv;
     l_number_dim_fk:=l_number_dim_fk-1;
     if g_debug then
       write_to_log_file('Results');
       for j in 1..l_number_dim_fk loop
         write_to_log_file(l_dim_fk(j)||' '||l_prefix_fk(j));
       end loop;
     end if;
     for j in 1..l_number_dim_fk loop
       if g_level_prefix(i)=l_prefix_fk(j) then
         g_level_pk_key(i):=l_dim_fk(j);
         g_level_pk(i):=EDW_OWB_COLLECTION_UTIL.get_user_key(l_dim_fk(j));
         if g_level_pk(i) is null then
           g_level_pk(i):=g_level_pk_key(i);
           g_level_pk_key(i):=g_level_pk(i)||'_KEY';
         end if;
         exit;
       end if;
     end loop;
   end if;
 end loop;
 if g_debug then
   write_to_log_file_n('The fks, levels and pks');
   for i in 1..g_number_fact_fks loop
     if g_higher_level(i) then
       write_to_log_file(g_fact_fks(i)||' '||g_parent_dim(i)||' '||g_level_pk_key(i));
     end if;
   end loop;
 end if;
 return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_fact_fks '||sqlerrm||' '||get_time);
  return false;
End;

function get_fact_mappings return boolean is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt varchar2(1000);
begin
 if g_debug then
   write_to_log_file_n('Started get_fact_mappings');
 end if;
 --not checked
 l_stmt:='select map.mapping_id, src.relation_name, src.relation_id '||
    'from '||
    'edw_pvt_map_properties_md_v map, '||
    'edw_relations_md_v src '||
    'where map.primary_target=:s '||
    'and src.relation_id=map.primary_source';
 open cv for l_stmt using g_fact_id;
 g_number_mapping_ids:=1;
 loop
   fetch cv into g_mapping_ids(g_number_mapping_ids),
                g_src_objects(g_number_mapping_ids),
                g_src_object_ids(g_number_mapping_ids);
   exit when cv%notfound;
   g_number_mapping_ids:=g_number_mapping_ids+1;
 end loop;
 g_number_mapping_ids:=g_number_mapping_ids-1;
 if g_debug then
   write_to_log_file_n('The mapping ids, src objects, total number '||g_number_mapping_ids);
   for i in 1..g_number_mapping_ids loop
     write_to_log_file(g_mapping_ids(i)||'  '||g_src_objects(i)||'  '||g_src_object_ids(i));
   end loop;
 end if;

 if g_debug then
   write_to_log_file_n('Finished get_fact_mappings');
 end if;
 return true;
Exception when others then
  begin
   close cv;
  exception when others then
   null;
  end;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_fact_mappings '||sqlerrm||' '||get_time);
  return false;
End;

function get_status_message return varchar2 is
begin
  return g_status_message;
Exception when others then
 write_to_log_file_n('Error  in get_status_message');
 return null;
End;

procedure init_all is
begin
g_temp_fact_name:=g_fact_name||'_TEMP';
g_fact_iv:=g_fact_name||'_IV';
g_status_message:='  ';
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

function wait_on_jobs(
p_job_id EDW_OWB_COLLECTION_UTIL.numberTableType,
p_job_status in out nocopy EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_jobs number,
p_sleep_time number,
p_mode varchar2
) return boolean is
l_running boolean;
l_changed boolean;
l_status varchar2(10);
Begin
  if g_debug then
    write_to_log_file_n('In wait_on_jobs p_sleep_time='||p_sleep_time||get_time);
    write_to_log_file('p_number_jobs='||p_number_jobs);
    for i in 1..p_number_jobs loop
      write_to_log_file(p_job_id(i)||' '||p_job_status(i));
    end loop;
  end if;
  l_changed:=false;
  l_running:=false;
  loop
    for i in 1..p_number_jobs loop
      if p_job_status(i)='R' then
        --the two api must be able to handle -ve p_job_id
        if p_mode='JOB' then
          l_status:=EDW_OWB_COLLECTION_UTIL.check_job_status(p_job_id(i));
        elsif p_mode='CONC' then
          l_status:=EDW_OWB_COLLECTION_UTIL.check_conc_process_status(p_job_id(i));
        end if;
        if l_status is null then
          return false;
        elsif l_status='N' then
          l_changed:=true;
          p_job_status(i):='Y';--complete
          if g_debug then
            write_to_log_file_n('Job '||p_job_id(i)||' Completed '||get_time);
          end if;
        else
          l_running:=true;--still running
        end if;
      end if;
    end loop;
    if l_changed then
      exit;
    elsif l_running then
      DBMS_LOCK.SLEEP(p_sleep_time);
    else
      exit;
    end if;
  end loop;
  if g_debug then
    write_to_log_file(get_time);
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in wait_on_jobs '||sqlerrm||' '||get_time);
  return false;
End;

function log_collection_detail(
p_object_name varchar2,
p_object_id number,
p_object_type varchar2,
p_conc_program_id number,
p_collection_start_date date,
p_collection_end_date date,
p_ins_rows_ready number,
p_ins_rows_processed number,
p_ins_rows_collected number,
p_ins_rows_insert number,
p_ins_rows_update number,
p_ins_rows_delete number,
p_message varchar2,
p_status varchar2,
p_load_pk number
) return boolean is
Begin
  if EDW_OWB_COLLECTION_UTIL.write_to_collection_log(
    p_object_name,
    p_object_id,
    p_object_type,
    p_conc_program_id,
    p_collection_start_date,
    p_collection_end_date,
    p_ins_rows_ready,
    p_ins_rows_processed,
    p_ins_rows_collected,
    p_ins_rows_insert,
    p_ins_rows_update,
    p_ins_rows_delete,
    p_message,
    p_status,
    p_load_pk)= false then
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in log_collection_detail '||sqlerrm||' '||get_time);
  return false;
End;

function get_temp_log_data(
p_object_name varchar2,
p_object_type varchar2,
p_load_pk number,
p_rows_processed out nocopy number
) return boolean is
l_rows_ready number;
l_ins_rows_collected number;
l_ins_rows_dangling number;
l_ins_rows_duplicate number;
l_ins_rows_error number;
l_ins_rows_insert number;
l_ins_rows_update number;
l_ins_rows_delete number;
l_ins_instance_name varchar2(80);
l_ins_request_id_table varchar2(80);
Begin
  if EDW_OWB_COLLECTION_UTIL.get_temp_log_data(
    p_object_name,
    p_object_type,
    p_load_pk,
    l_rows_ready,
    p_rows_processed,
    l_ins_rows_collected,
    l_ins_rows_dangling,
    l_ins_rows_duplicate,
    l_ins_rows_error,
    l_ins_rows_insert,
    l_ins_rows_update,
    l_ins_rows_delete,
    l_ins_instance_name,
    l_ins_request_id_table)=false then
    null;
  end if;
  return true;
EXCEPTION when others then
  write_to_log_file_n('Error in get_temp_log_data '||sqlerrm);
  return false;
End;

function get_child_job_status(
p_job_status_table varchar2,
p_status out nocopy varchar2,
p_message out nocopy varchar2
) return boolean is
l_id EDW_OWB_COLLECTION_UTIL.numberTableType;
l_job_id EDW_OWB_COLLECTION_UTIL.numberTableType;
l_status EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_message EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_jobs number;
Begin
  if EDW_OWB_COLLECTION_UTIL.get_child_job_status(
    p_job_status_table,
    null,
    l_id,
    l_job_id,
    l_status,
    l_message,
    l_number_jobs)=false then
    null;
  end if;
  for i in 1..l_number_jobs loop
    if l_status(i)='ERROR' then
      p_status:='ERROR';
      p_message:=l_message(i);
      return true;
    end if;
  end loop;
  p_status:='SUCCESS';
  p_message:=null;
  return true;
EXCEPTION when others then
  write_to_log_file_n('Error in get_child_job_status '||sqlerrm);
  return false;
End;

function delete_object_log_tables(
p_src_fact varchar2,
p_table_owner varchar2,
p_bis_owner varchar2,
p_fact_dlog varchar2,
p_ilog EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_dlog EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_derv_fact number
)return boolean is
l_snp_log varchar2(400);
l_mv_fast_refresh number;
Begin
  if g_debug then
    write_to_log_file_n('In delete_object_log_tables');
  end if;
  /*3529591
  before we truncate the mv log of the base fact, we need to check to see
  if this is a src for a fast refresh mv.
  */
  l_mv_fast_refresh:=edw_owb_collection_util.is_source_for_fast_refresh_mv(p_src_fact,p_table_owner);
  if l_mv_fast_refresh is null or l_mv_fast_refresh<>1 then
    l_snp_log:=EDW_OWB_COLLECTION_UTIL.get_table_snapshot_log(p_src_fact);
    if g_debug then
      write_to_log_file_n('l_snp_log is '||l_snp_log);
    end if;
    if l_snp_log is not null then
      if EDW_OWB_COLLECTION_UTIL.truncate_table(l_snp_log,p_table_owner) = false then
        return false;
      end if;
    end if;
    if p_fact_dlog is not null then
      if instr(p_fact_dlog,p_bis_owner||'.') <> 0 then
        if EDW_OWB_COLLECTION_UTIL.drop_table(p_fact_dlog)=false then
          return false;
        end if;
      else
        if EDW_OWB_COLLECTION_UTIL.truncate_table(p_fact_dlog,p_table_owner)=false then
          return false;
        end if;
      end if;
    end if;
    --drop the ilog and dlog tables
    for i in 1..p_number_derv_fact loop
      if EDW_OWB_COLLECTION_UTIL.drop_table(p_ilog(i))=false then
        null;
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(p_ilog(i)||'A')=false then
        null;
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_ilog_tables(p_ilog(i)||'_IL',null,p_bis_owner)=false then
        return false;
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(p_dlog(i))=false then
        null;
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(p_dlog(i)||'A')=false then
        null;
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_ilog_tables(p_dlog(i)||'_DL',null,p_bis_owner)=false then
        return false;
      end if;
    end loop;
  end if;--if l_mv_fast_refresh is null or l_mv_fast_refresh<>1 then
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in delete_object_log_tables '||g_status_message);
  return false;
End;

function drop_inp_status_table(
p_input_table varchar2,
p_job_status_table varchar2
)return boolean is
Begin
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_input_table)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_job_status_table)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_input_table||'_FK')=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_input_table||'_SK')=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_input_table||'_BU')=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in drop_inp_status_table '||g_status_message);
  return false;
End;

function create_conc_program(
p_temp_conc_name varchar2,
p_temp_conc_short_name varchar2,
p_temp_exe_name varchar2,
p_bis_short_name varchar2
) return boolean is
l_bis_long_name varchar2(240);
l_parameter EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_parameter_value_set EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_parameters number;
Begin
  if g_debug then
    write_to_log_file_n('In create_conc_program '||get_time);
  end if;
  l_parameter(1):='p_fact_name';
  l_parameter_value_set(1):='FND_CHAR240';
  l_parameter(2):='p_fact_id';
  l_parameter_value_set(2):='FND_NUMBER';
  l_parameter(3):='p_log_file';
  l_parameter_value_set(3):='FND_CHAR240';
  l_parameter(4):='p_input_table';
  l_parameter_value_set(4):='FND_CHAR240';
  l_parameter(5):='p_ilog';
  l_parameter_value_set(5):='FND_CHAR240';
  l_parameter(6):='p_dlog';
  l_parameter_value_set(6):='FND_CHAR240';
  l_parameter(7):='p_pre_hook';
  l_parameter_value_set(7):='FND_CHAR240';
  l_parameter(8):='p_post_hook';
  l_parameter_value_set(8):='FND_CHAR240';
  l_parameter(9):='p_thread_type';
  l_parameter_value_set(9):='FND_CHAR240';
  l_number_parameters:=9;
  if EDW_OWB_COLLECTION_UTIL.create_conc_program(
    p_temp_conc_name,
    p_temp_conc_short_name,
    p_temp_exe_name,
    'EDW_DERIVED_FACT_FACT_COLLECT.COLLECT_FACT_MULTI_THREAD',
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
  write_to_log_file_n('FND_PROGRAM.MESSAGE='||FND_PROGRAM.MESSAGE);
  return false;
End;

END;

/
