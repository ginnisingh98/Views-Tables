--------------------------------------------------------
--  DDL for Package Body EDW_MAPPING_COLLECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_MAPPING_COLLECT" AS
/*$Header: EDWMAPFB.pls 120.1 2006/04/25 15:17:08 vsurendr noship $*/

/*
This is the first point of entry called from edw_all_collect
*/
procedure COLLECT_MAIN(
    p_object_name in varchar2,
    p_mapping_id in number,
    p_map_type in varchar2,
    p_primary_src in number,
    p_primary_target in number,
    p_primary_target_name varchar2,
    p_object_type varchar2,
    p_conc_id in number,
    p_conc_program_name in varchar2,
    p_status out NOCOPY boolean,
    p_fact_audit boolean,
    p_net_change boolean,
    p_fact_audit_name varchar2,
    p_net_change_name varchar2,
    p_fact_audit_is_name varchar2,
    p_net_change_is_name varchar2,
    p_debug boolean,
    p_duplicate_collect boolean,
    p_execute_flag boolean,
    p_request_id number,
    p_collection_size number,
    p_parallel number,
    p_table_owner varchar2,
    p_bis_owner  varchar2,
    p_temp_log boolean,
    p_forall_size number,
    p_update_type varchar2,
    p_mode varchar2,
    p_explain_plan_check boolean,
    p_fact_dlog varchar2,
    p_key_set number,
    p_instance_type varchar2,
    p_load_pk number,
    p_skip_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_skip_cols number,
    p_fresh_restart boolean,
    p_op_table_space varchar2,
    p_da_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_da_cols number,
    p_da_table varchar2,
    p_pp_table varchar2,
    p_master_instance varchar2,
    p_rollback varchar2,
    p_skip_levels EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_skip_levels number,
    p_smart_update boolean,
    p_fk_use_nl number,
    p_fact_smart_update number,
    p_auto_dang_table_extn varchar2,
    p_log_dang_keys boolean,
    p_create_parent_table_records boolean,
    p_smart_update_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_smart_update_cols number,
    p_check_fk_change boolean,
    p_stg_join_nl_percentage number,
    p_ok_switch_update number,
    p_stg_make_copy_percentage number,
    p_hash_area_size number,
    p_sort_area_size number,
    p_trace boolean,
    p_read_cfig_options boolean,
    p_min_job_load_size number,
    p_sleep_time number,
    p_thread_type varchar2,
    p_max_threads number,
    p_job_status_table varchar2,
    p_analyze_frequency number,
    p_parallel_drill_down boolean,
    p_dd_status_table varchar2
    ) IS
Begin
  if p_max_threads>1 then
    --multi threading
    COLLECT_MULTI_THREAD(
    p_object_name,
    p_mapping_id,
    p_map_type,
    p_primary_src,
    p_primary_target,
    p_primary_target_name,
    p_object_type,
    p_conc_id,
    p_conc_program_name,
    p_status,
    p_fact_audit,
    p_net_change,
    p_fact_audit_name,
    p_net_change_name,
    p_fact_audit_is_name,
    p_net_change_is_name,
    p_debug,
    p_duplicate_collect,
    p_execute_flag,
    p_request_id,
    p_collection_size,
    p_parallel,
    p_table_owner,
    p_bis_owner,
    p_temp_log,
    p_forall_size,
    p_update_type,
    p_mode,
    p_explain_plan_check,
    p_fact_dlog,
    p_key_set,
    p_instance_type,
    p_load_pk,
    p_skip_cols,
    p_number_skip_cols,
    p_fresh_restart,
    p_op_table_space,
    p_da_cols,
    p_number_da_cols,
    p_da_table,
    p_pp_table,
    p_master_instance,
    p_rollback,
    p_skip_levels,
    p_number_skip_levels,
    p_smart_update,
    p_fk_use_nl,
    p_fact_smart_update,
    p_auto_dang_table_extn,
    p_log_dang_keys,
    p_create_parent_table_records,
    p_smart_update_cols,
    p_number_smart_update_cols,
    p_check_fk_change,
    p_stg_join_nl_percentage,
    p_ok_switch_update,
    p_stg_make_copy_percentage,
    p_hash_area_size,
    p_sort_area_size,
    p_trace,
    p_read_cfig_options,
    p_min_job_load_size,
    p_sleep_time,
    p_thread_type,
    p_max_threads,
    p_job_status_table,
    p_analyze_frequency,
    p_parallel_drill_down,
    p_dd_status_table
    );
  else
    --single threaded
    COLLECT(
    p_object_name,
    p_mapping_id,
	p_map_type,
	p_primary_src,
	p_primary_target,
	p_primary_target_name,
	p_object_type,
	p_conc_id,
	p_conc_program_name,
	p_status,
    p_fact_audit,
    p_net_change,
    p_fact_audit_name,
    p_net_change_name,
    p_fact_audit_is_name,
    p_net_change_is_name,
	p_debug,
    p_duplicate_collect,
    p_execute_flag,
    p_request_id,
    p_collection_size,
    p_parallel,
    p_table_owner,
    p_bis_owner,
    p_temp_log,
    p_forall_size,
    p_update_type,
    p_mode,
    p_explain_plan_check,
    p_fact_dlog,
    p_key_set,
    p_instance_type,
    p_load_pk,
    p_skip_cols,
    p_number_skip_cols,
    p_fresh_restart,
    p_op_table_space,
    p_da_cols,
    p_number_da_cols,
    p_da_table,
    p_pp_table,
    p_master_instance,
    p_rollback,
    p_skip_levels,
    p_number_skip_levels,
    p_smart_update,
    p_fk_use_nl,
    p_fact_smart_update,
    p_auto_dang_table_extn,
    p_log_dang_keys,
    p_create_parent_table_records,
    p_smart_update_cols,
    p_number_smart_update_cols,
    p_check_fk_change,
    p_stg_join_nl_percentage,
    p_ok_switch_update,
    p_stg_make_copy_percentage,
    p_read_cfig_options,
    p_analyze_frequency
    );
  end if;
Exception when others then
  write_to_log_file_n('Error in COLLECT_MAIN  '||sqlerrm||get_time);
  g_status_message:=sqlerrm;
  g_status:=false;
End;

procedure COLLECT_MULTI_THREAD(
    p_object_name in varchar2,
    p_mapping_id in number,
    p_map_type in varchar2,
    p_primary_src in number,
    p_primary_target in number,
    p_primary_target_name varchar2,
    p_object_type varchar2,
    p_conc_id in number,
    p_conc_program_name in varchar2,
    p_status out NOCOPY boolean,
    p_fact_audit boolean,
    p_net_change boolean,
    p_fact_audit_name varchar2,
    p_net_change_name varchar2,
    p_fact_audit_is_name varchar2,
    p_net_change_is_name varchar2,
    p_debug boolean,
    p_duplicate_collect boolean,
    p_execute_flag boolean,
    p_request_id number,
    p_collection_size number,
    p_parallel number,
    p_table_owner varchar2,
    p_bis_owner  varchar2,
    p_temp_log boolean,
    p_forall_size number,
    p_update_type varchar2,
    p_mode varchar2,
    p_explain_plan_check boolean,
    p_fact_dlog varchar2,
    p_key_set number,
    p_instance_type varchar2,
    p_load_pk number,
    p_skip_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_skip_cols number,
    p_fresh_restart boolean,
    p_op_table_space varchar2,
    p_da_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_da_cols number,
    p_da_table varchar2,
    p_pp_table varchar2,
    p_master_instance varchar2,
    p_rollback varchar2,
    p_skip_levels EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_skip_levels number,
    p_smart_update boolean,
    p_fk_use_nl number,
    p_fact_smart_update number,
    p_auto_dang_table_extn varchar2,
    p_log_dang_keys boolean,
    p_create_parent_table_records boolean,
    p_smart_update_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_smart_update_cols number,
    p_check_fk_change boolean,
    p_stg_join_nl_percentage number,
    p_ok_switch_update number,
    p_stg_make_copy_percentage number,
    p_hash_area_size number,
    p_sort_area_size number,
    p_trace boolean,
    p_read_cfig_options boolean,
    p_min_job_load_size number,
    p_sleep_time number,
    p_thread_type varchar2,
    p_max_threads number,
    p_job_status_table varchar2,
    p_analyze_frequency number,
    p_parallel_drill_down boolean,
    p_dd_status_table varchar2
    ) IS
l_input_table varchar2(200);
l_ok_table varchar2(80);
--the number of elements in these array=g_max_threads
l_ok_low_end EDW_OWB_COLLECTION_UTIL.numberTableType;
l_ok_high_end EDW_OWB_COLLECTION_UTIL.numberTableType;
l_ok_end_count integer;
l_job_id EDW_OWB_COLLECTION_UTIL.numberTableType;
l_number_jobs number;
l_rownum_for_seq_num number;
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
  g_debug:=p_debug;
  g_total_records:=0;
  g_analyze_freq:=p_analyze_frequency;
  g_min_job_load_size:=p_min_job_load_size;
  g_sleep_time:=p_sleep_time;
  g_thread_type:=p_thread_type;
  g_parallel_drill_down:=p_parallel_drill_down;
  g_dd_status_table:=p_dd_status_table;
  if g_debug then
    write_to_log_file_n('In COLLECT_MULTI_THREAD for '||p_primary_target_name||get_time);
  end if;
  l_input_table:=p_bis_owner||'.INP_TAB_'||p_primary_target;
  g_jobid_stmt:=null;
  p_status:=true;
  if p_mapping_id=0 OR p_primary_src=0 OR p_primary_target=0 then
    p_status:=false;
    write_to_log_file_n('Map or src or tgt not specified. Fatal...');
    return;
  end if;
  if EDW_OWB_COLLECTION_UTIL.create_load_input_table(
    l_input_table,
    p_object_name,
    p_mapping_id,
    p_map_type,
    p_primary_src,
    p_primary_target,
    p_primary_target_name,
    p_object_type,
    p_conc_id,
    p_conc_program_name,
    p_fact_audit,
    p_net_change,
    p_fact_audit_name,
    p_net_change_name,
    p_fact_audit_is_name,
    p_net_change_is_name,
    p_debug,
    p_duplicate_collect,
    p_execute_flag,
    p_request_id,
    p_collection_size,
    p_parallel,
    p_table_owner,
    p_bis_owner,
    p_temp_log,
    p_forall_size,
    p_update_type,
    p_mode,
    p_explain_plan_check,
    p_fact_dlog,
    p_key_set,
    p_instance_type,
    p_load_pk,
    p_skip_cols,
    p_number_skip_cols,
    p_fresh_restart,
    p_op_table_space,
    p_da_cols,
    p_number_da_cols,
    p_da_table,
    p_pp_table,
    p_master_instance,
    p_rollback,
    p_skip_levels,
    p_number_skip_levels,
    p_smart_update,
    p_fk_use_nl,
    p_fact_smart_update,
    p_auto_dang_table_extn,
    p_log_dang_keys,
    p_create_parent_table_records,
    p_smart_update_cols,
    p_number_smart_update_cols,
    p_check_fk_change,
    p_stg_join_nl_percentage,
    p_ok_switch_update,
    p_stg_make_copy_percentage,
    null,--ok table name
    p_hash_area_size,
    p_sort_area_size,
    p_trace,
    p_read_cfig_options,
    p_job_status_table,
    null,
    null,
    null,
    p_sleep_time,
    g_parallel_drill_down
    )=false then
    p_status:=false;
    g_status_message:=EDW_OWB_COLLECTION_UTIL.get_status_message;
    g_status:=false;
  end if;
  if p_status then
    if initial_set_up(
      l_input_table,
      p_max_threads,
      p_debug,
      l_ok_table)=false then
      p_status:=false;
      g_status:=false;
    end if;
    if p_status then
      if EDW_OWB_COLLECTION_UTIL.create_da_load_input_table(
        l_input_table||'_DC',
        g_op_table_space,
        g_da_cols,
        g_stg_da_cols,
        g_number_da_cols)=false then
        p_status:=false;
        g_status:=false;
      end if;
    end if;
    if p_status then
      if EDW_OWB_COLLECTION_UTIL.update_load_input_table(
        l_input_table,
        l_ok_table,
        g_max_round,
        g_update_dlog_lookup_table,
        g_dlog_has_data,
        g_total_records,
        g_stg_copy_table_flag
        )=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.get_status_message;
        p_status:=false;
        g_status:=false;
      end if;
      if p_status then
        --BRING IN THE CALL TO COLLECT
        --if l_ok_table is null, there are no records to load
        --if this stg table has no records to load,  l_ok_table will be null
        --initial_setup would not have given any value to it.
        if l_ok_table is not null then
          if EDW_OWB_COLLECTION_UTIL.find_ok_distribution(
            l_ok_table,
            p_bis_owner,
            p_max_threads,
            p_min_job_load_size,
            l_ok_low_end,
            l_ok_high_end,
            l_ok_end_count)=false then
            g_status_message:=EDW_OWB_COLLECTION_UTIL.get_status_message;
            p_status:=false;
            g_status:=false;
          end if;
          --l_ok_end_count decides the number of threads
          if p_status then
            if l_ok_end_count=1 then
              /*
              there is no need for multi threading
              */
              if g_debug then
                write_to_log_file_n('No need to launch multiple threads.  Single Thread');
              end if;
              if COLLECT(g_status)=false then
                p_status:=false;
                g_status:=false;
              end if;
            else
              /*
                we will go for active polling. this main session will sleep for g_sleep_time and then
                wake up and check the status of each of the jobs. If they are done, we can then proceed.
                DBMS_JOB.SUBMIT(id,'test_pack_2.run_pack;')
              */
              if g_debug then
                write_to_log_file_n('Launch multiple threads. Type of thread='||g_thread_type);
              end if;
              l_number_jobs:=0;
              l_temp_conc_name:='Sub-Proc Stg-'||p_primary_target;
              l_temp_conc_short_name:='CONC_MAP_'||p_primary_target||'_CONC';
              l_temp_exe_name:=l_temp_conc_name||'_EXE';
              l_bis_short_name:='BIS';
              if g_thread_type='CONC' then
                --create the executable, conc program etc
                if create_conc_program(l_temp_conc_name,l_temp_conc_short_name,l_temp_exe_name,
                  l_bis_short_name)=false then
                  if g_debug then
                    write_to_log_file_n('Could not create seed data for conc programs. Trying jobs');
                  end if;
                  g_thread_type:='JOB';
                end if;
              end if;
              for j in 1..l_ok_end_count loop
                l_number_jobs:=l_number_jobs+1;
                l_job_id(l_number_jobs):=null;
                l_rownum_for_seq_num:=g_rownum_for_seq_num+l_ok_low_end(j);
                if g_debug then
                  write_to_log_file_n('EDW_MAPPING_COLLECT.COLLECT('''||p_object_name||''','||
                  ''''||p_primary_target_name||''','''||l_input_table||''','||l_number_jobs||','||
                  l_ok_low_end(j)||','||l_ok_high_end(j)||','||l_rownum_for_seq_num||');');
                end if;
                begin
                  l_try_serial:=false;
                  if g_thread_type='CONC' then
                    l_job_id(l_number_jobs):=FND_REQUEST.SUBMIT_REQUEST(
                    application=>l_bis_short_name,
                    program=>l_temp_conc_short_name,
                    argument1=>p_object_name,
                    argument2=>p_primary_target_name,
                    argument3=>l_input_table,
                    argument4=>l_number_jobs,
                    argument5=>l_ok_low_end(j),
                    argument6=>l_ok_high_end(j),
                    argument7=>l_rownum_for_seq_num);
                    commit;
                    if g_debug then
                      write_to_log_file_n('Concurrent Request '||l_job_id(l_number_jobs)||' launched '||get_time);
                    end if;
                    if l_job_id(l_number_jobs)<=0 then
                      l_try_serial:=true;
                    end if;
                  else
                    DBMS_JOB.SUBMIT(l_job_id(l_number_jobs),'EDW_MAPPING_COLLECT.COLLECT('''||p_object_name||''','||
                    ''''||p_primary_target_name||''','''||l_input_table||''','||l_number_jobs||','||
                    l_ok_low_end(j)||','||l_ok_high_end(j)||','||l_rownum_for_seq_num||');');
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
                  EDW_MAPPING_COLLECT.COLLECT(
                  l_errbuf,
                  l_retcode,
                  p_object_name,
                  p_primary_target_name,
                  l_input_table,
                  l_number_jobs,
                  l_ok_low_end(j),
                  l_ok_high_end(j),
                  l_rownum_for_seq_num
                  );
                end if;
              end loop;
              --wait to make sure that all threads launched are complete.
              if EDW_OWB_COLLECTION_UTIL.wait_on_jobs(
                l_job_id,
                l_number_jobs,
                p_sleep_time,
                g_thread_type)=false then
                g_status_message:=EDW_OWB_COLLECTION_UTIL.get_status_message;
                p_status:=false;
                g_status:=false;
              end if;
              if p_status then
                --just to note. l_job_id is not used in check_all_child_jobs
                if EDW_OWB_COLLECTION_UTIL.check_all_child_jobs(p_job_status_table,l_job_id,
                  l_number_jobs,null)=false then
                  g_status:=false;
                  p_status:=false;
                  return;
                end if;
              end if;
            end if;
          end if;
        end if;
      end if;
    end if;
  end if;
  if p_status then
    --if this is a dim, launch dbms job to push changes to lower levels
    --if lowest level, merge rowids from snp log
    if g_object_type='DIMENSION' and g_parallel_drill_down then
      if drill_parent_to_children=false then
        p_status:=false;
        return;
      end if;
    end if;
    clean_up;
    if drop_input_tables(l_input_table)=false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_ok_table)=false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(p_job_status_table)=false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_update_dlog_lookup_table)=false then
      null;
    end if;
    if post_operations=false then
      p_status:=false;
    end if;
  end if;
Exception when others then
  write_to_log_file_n('Error in COLLECT_MULTI_THREAD '||sqlerrm||get_time);
  g_status_message:=sqlerrm;
  g_status:=false;
End;

/*
called by the Main load procedure to
1. pre map hook
2. read metadata for just the PK
3. create rowid table and see how many records need to be loaded
4. execute duplicate check. mark stg table etc
5. create ok table
called only in multi thread mode
*/
function initial_set_up(
p_table_name varchar2,
p_max_threads number,
p_debug boolean,
p_ok_table out nocopy varchar2) return boolean is
--
Begin
  if g_debug then
    write_to_log_file_n('In initial_set_up p_max_threads='||p_max_threads||' '||get_time);
  end if;
  g_max_threads:=p_max_threads;
  g_debug:=p_debug;
  if read_options_table(p_table_name)=false then
    return false;
  end if;
  g_total_records:=0;
  if EDW_OWB_COLLECTION_UTIL.create_job_status_table(g_job_status_table,g_op_table_space)=false then
    return false;
  end if;
  if g_debug then
    write_to_log_file_n('pre_mapping_coll'||get_time);
  end if;
  insert_into_load_progress_d(g_load_pk,g_primary_target_name,'Pre Mapping Collection Hook',sysdate,null,'MAPPING',
  'PRE-MAP',1010,'I');
  if EDW_COLLECTION_HOOK.pre_mapping_coll(g_primary_target_name)=false then
    write_to_log_file_n('EDW_COLLECTION_HOOK.pre_mapping_coll returned with error.'||get_time);
    return false;
  end if;
  write_to_log_file_n('EDW_COLLECTION_HOOK.pre_mapping_coll returned with success.'||get_time);
  insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,1010,'U');
  Init_all(null);
  insert_into_load_progress_d(g_load_pk,g_primary_target_name,'Read Metadata',sysdate,null,'MAPPING',
  'METADATA-READ',1020,'I');
  if g_debug then
    edw_owb_collection_util.dump_mem_stats;
  end if;
  Read_Metadata('PK');--?
  if g_debug then
    edw_owb_collection_util.dump_mem_stats;
  end if;
  insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,1020,'U');
  if g_status=false then
    return false;
  end if;
  insert_into_load_progress_d(g_load_pk,g_primary_target_name,'Recover from any Previous Error',sysdate,null,'MAPPING',
  'ERROR-RECOVERY',1040,'I');
  if g_object_type='FACT' and (g_is_source=true or g_is_custom_source=true) then
    if dlog_setup=false then
      return false;
    end if;
  end if;
  /*
  if the last run had multiple threads and there was failure, there will be multiple ok tables.
  we must merge all these tables together
  */
  if g_fresh_restart=false then
    if merge_all_ok_tables=false then
      return false;
    end if;
  end if;
  --at this point, there is one ok rowid table
  if recover_from_previous_error=false then
    return false;
  end if;
  insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,1040,'U');
  insert_into_load_progress_d(g_load_pk,g_primary_target_name,'Check Number of Records to Load',sysdate,null,'MAPPING',
  'LOAD-CHECK',1050,'I');
  if check_total_records_to_collect=false then
    return false;
  end if;
  insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,1050,'U');
  /*
  these ops must be done before total records are checked and exit is made. this is for upgrade. if 3.1 or 3.01
  customers implement data alignment, by running a load, the da and pp tables must be populated.
  */
  if g_number_da_cols > 0 then
    if get_stg_da_columns=false then
      return false;
    end if;
    insert_into_load_progress_d(g_load_pk,g_primary_target_name,'Create Data Alignment Tables',sysdate,null,'MAPPING',
    'CREATE-TABLE','DATC','I');
    if create_da_pp_tables=false then
      insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'DATC','U');
      return false;
    end if;
    if populate_da_pp_tables=false then
      insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'DATC','U');
      return false;
    end if;
    insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'DATC','U');
  end if;
  if g_total_records=0 then
    clean_up;
    write_to_log_file_n('There are no records in the staging table with READY collection status');
    write_to_log_file('Stopping collection for this object');
    return true;
  end if;
  --duplicate check and create ok table
  --first mark all the duplicate records
  --for duplicate check we need to consider the whole table at once.
  insert_into_load_progress_d(g_load_pk,g_primary_target_name,'Duplicate Check',sysdate,null,'MAPPING',
  'DUPLICATE-CHECK',1100,'I');
  if execute_duplicate_check= false then
    write_to_log_file_n('execute_duplicate_check  returned with error');
    insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,1100,'U');
    return false;
  end if;
  g_rownum_for_seq_num:=null;
  if g_max_threads>1 then
    if put_rownum_in_ok_table=false then
      return false;
    end if;
    if g_pk_key_seq is not null then
      g_rownum_for_seq_num:=EDW_OWB_COLLECTION_UTIL.get_seq_nextval(g_pk_key_seq);
    end if;
  end if;
  insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,1100,'U');
  p_ok_table:=g_ok_rowid_table;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 write_to_log_file_n('Error in initial_set_up '||g_status_message);
 g_status:=false;
 return false;
End;

--called after all the jobs are finished running.
function post_operations return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In post_operations '||get_time);
  end if;
  --drop the fk table. this is dropped here because the main process creates it and keeps it for
  --the child processes. then at the end, the main process drops it
  if edw_owb_collection_util.drop_stg_map_fk_details(g_bis_owner,g_mapping_id)=false then
    null;
  end if;
  analyze_target_tables;
  if g_debug then
    write_to_log_file_n('Calling post mapping collection hook '||get_time);
  end if;
  insert_into_load_progress_d(g_load_pk,g_primary_target_name,'Post Mapping Collection Hook',sysdate,null,'HOOK',
  'POST-MAP',1070,'I');
  if EDW_COLLECTION_HOOK.post_mapping_coll(g_primary_target_name)= false then
    write_to_log_file_n('EDW_COLLECTION_HOOK.post_mapping_coll returned with error.'||get_time);
    g_status:=false;
    return false;
  end if;
  insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,1070,'U');
  if g_debug then
    write_to_log_file_n('EDW_COLLECTION_HOOK.post_mapping_coll returned with success.'||get_time);
  end if;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 write_to_log_file_n('Error in post_operations '||g_status_message);
 g_status:=false;
 return false;
End;

/*
main entry point for each of the child concurrent requests
*/
procedure COLLECT(
errbuf out nocopy varchar2,
retcode out nocopy varchar2,
p_object_name varchar2,
p_target_name varchar2,
p_table_name varchar2,
p_job_id number,
p_ok_low_end number,
p_ok_high_end number,
p_rownum_for_seq_num number
) is
Begin
  retcode:='0';
  COLLECT(
  p_object_name,
  p_target_name,
  p_table_name,
  p_job_id,
  p_ok_low_end,
  p_ok_high_end,
  p_rownum_for_seq_num);
  if g_status=false then
    retcode:='2';
    errbuf:=g_status_message;
  end if;
Exception when others then
 errbuf:=sqlerrm;
 retcode:='2';
 write_to_log_file_n('Error in collect '||errbuf);
End;

/*
main entry point for each of the child jobs
*/
procedure COLLECT(
p_object_name varchar2,
p_target_name varchar2,
p_table_name varchar2,
p_job_id number,
p_ok_low_end number,
p_ok_high_end number,
p_rownum_for_seq_num number
) is
l_status boolean;
Begin
  l_status:=true;
  g_job_id:=p_job_id;
  g_jobid_stmt:='Job '||g_job_id||' ';
  g_status:=true;
  --g_job_id is not the dbms_job job_id. its just an identifier. goes from 1..n
  /*need to open log file
  this wont be conc manager log file
  */
  EDW_OWB_COLLECTION_UTIL.init_all(p_target_name||'_'||g_job_id,null,'bis.edw.loader');
  write_to_log_file_n('In COLLECT. p_object_name='||p_object_name||',p_target_name='||p_target_name||
  ', p_table_name='||p_table_name||', p_job_id='||p_job_id||', p_ok_low_end='||p_ok_low_end||
  ', p_ok_high_end='||p_ok_high_end||', p_rownum_for_seq_num='||p_rownum_for_seq_num||get_time);
  --null g_job_id means that this is single thread. 1 and up means that this is a thread
  --read_options_table populates all the global variables
  if read_options_table(p_table_name)=false then
    if EDW_OWB_COLLECTION_UTIL.log_into_job_status_table(
      g_job_status_table,
      p_object_name,
      g_job_id,
      'ERROR',
      g_status_message)=false then
      null;
    end if;
    return;
  end if;
  --g_conc_program_id is read from p_table_name
  EDW_OWB_COLLECTION_UTIL.set_conc_program_id(g_conc_program_id);
  EDW_OWB_COLLECTION_UTIL.set_debug(g_debug);
  EDW_OWB_COLLECTION_UTIL.set_parallel(g_parallel);
  EDW_OWB_COLLECTION_UTIL.set_g_read_cfig_options(g_read_cfig_options);
  if set_session_parameters=false then
    l_status:=false;
  end if;  --alter session etc
  if g_mapping_id =0 OR g_primary_src=0 OR g_primary_target=0 then
    l_status:=false;
    g_status_message:='Map or src or tgt not specified. Fatal...';
    write_to_log_file_n(g_status_message);
    if EDW_OWB_COLLECTION_UTIL.log_into_job_status_table(
      g_job_status_table,
      p_object_name,
      g_job_id,
      'ERROR',
      g_status_message)=false then
      null;
    end if;
  end if;
  Init_all(g_job_id);--all tables will get job_id appended to them
  g_ok_low_end:=p_ok_low_end;
  g_ok_high_end:=p_ok_high_end;
  g_rownum_for_seq_num:=p_rownum_for_seq_num;
  if g_ok_low_end is null then
    g_ok_rowid_table:=g_main_ok_table_name;
  else
    if make_ok_from_main_ok(
      g_main_ok_table_name,
      g_ok_low_end,
      g_ok_high_end)=false then
      l_status:=false;
    end if;
    if set_stg_nl_parameters(g_ok_rowid_number)=false then
      l_status:=false;
    end if;
  end if;
  if l_status then
    if COLLECT(l_status)=false then
      l_status:=false;
    end if;
  end if;
  if l_status=false then
    if EDW_OWB_COLLECTION_UTIL.log_into_job_status_table(
      g_job_status_table,
      p_object_name,
      g_job_id,
      'ERROR',
      g_status_message)=false then
      null;
    end if;
  else
    if EDW_OWB_COLLECTION_UTIL.log_into_job_status_table(
      g_job_status_table,
      p_object_name,
      g_job_id,
      'SUCCESS',
      g_status_message)=false then
      null;
    end if;
  end if;
Exception when others then
 g_status_message:=sqlerrm;
 write_to_log_file_n('Error in COLLECT '||g_status_message);
 g_status:=false;
End;

/*
This function can be called from a single thread or from a job
*/
function COLLECT(p_status out NOCOPY boolean) return boolean is
Begin
  p_status:=true;
  if g_job_id is not null then
    insert_into_load_progress_d(g_load_pk,g_primary_target_name,g_jobid_stmt||'Read Metadata',sysdate,null,'MAPPING',
    'METADATA-READ',g_jobid_stmt||'1020','I');
    if g_debug then
      edw_owb_collection_util.dump_mem_stats;
    end if;
    Read_Metadata('ALL');--?
    if g_debug then
      edw_owb_collection_util.dump_mem_stats;
    end if;
    insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'1020','U');
    if g_status=false then
      return false;
    end if;
  end if;
  if check_fk_direct_load=false then
    write_to_log_file_n('check_fk_direct_load returned with error');
    p_status:=false;
    return false;
  end if;
  --see if this is a case of single instance
  if g_instance_type='SINGLE' then
    if check_pk_direct_load=false then
      write_to_log_file_n('check_pk_direct_load returned with error');
      p_status:=false;
      return false;
    end if;
    /*
    if the pk_key is to be directly loaded from the staging table, then chahnge the mapping from
    seq to stg.pk_key
    */
    if g_pk_direct_load then
      if make_pk_direct_load('DIRECT-LOAD')=false then
        write_to_log_file_n('make_pk_direct_load returned with error');
        p_status:=false;
        return false;
      end if;
    end if;
  end if;
  /*
  collect records collects in chunks
  */
  if collect_records=false then
    write_to_log_file_n('collect_records returned with false.');
    p_status:=false;
    return false;
  end if;
  clean_up;
  return true;
Exception when others then
 write_to_log_file_n('Error in COLLECT '||g_primary_target_name||' '||sqlerrm||get_time);
 g_status_message:=sqlerrm;
 g_status:=false;
 return false;
End;

/*
This is called from conc programs when there is NO multi threading
*/
procedure COLLECT(
    p_object_name in varchar2,
    p_mapping_id in number,
	p_map_type in varchar2,
	p_primary_src in number,
	p_primary_target in number,
	p_primary_target_name varchar2,
	p_object_type varchar2,
	p_conc_id in number,
	p_conc_program_name in varchar2,
	p_status out NOCOPY boolean,
    p_fact_audit boolean,
    p_net_change boolean,
    p_fact_audit_name varchar2,
    p_net_change_name varchar2,
    p_fact_audit_is_name varchar2,
    p_net_change_is_name varchar2,
	p_debug boolean,
    p_duplicate_collect boolean,
    p_execute_flag boolean,
    p_request_id number,
    p_collection_size number,
    p_parallel number,
    p_table_owner varchar2,
    p_bis_owner  varchar2,
    p_temp_log boolean,
    p_forall_size number,
    p_update_type varchar2,
    p_mode varchar2,
    p_explain_plan_check boolean,
    p_fact_dlog varchar2,
    p_key_set number,
    p_instance_type varchar2,
    p_load_pk number,
    p_skip_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_skip_cols number,
    p_fresh_restart boolean,
    p_op_table_space varchar2,
    p_da_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_da_cols number,
    p_da_table varchar2,
    p_pp_table varchar2,
    p_master_instance varchar2,
    p_rollback varchar2,
    p_skip_levels EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_skip_levels number,
    p_smart_update boolean,
    p_fk_use_nl number,
    p_fact_smart_update number,
    p_auto_dang_table_extn varchar2,
    p_log_dang_keys boolean,
    p_create_parent_table_records boolean,
    p_smart_update_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_smart_update_cols number,
    p_check_fk_change boolean,
    p_stg_join_nl_percentage number,
    p_ok_switch_update number,
    p_stg_make_copy_percentage number,
    p_read_cfig_options boolean,
    p_analyze_frequency number
    ) IS
begin
g_object_name:=p_object_name; --name of the dim or fact
g_conc_program_id:=p_conc_id;--this is the request id
g_conc_program_name:=p_conc_program_name;
p_status:=true;
g_mapping_id:=p_mapping_id;
g_mapping_type:=p_map_type;
g_primary_src :=p_primary_src;
g_primary_target:=p_primary_target;
g_primary_target_name :=p_primary_target_name;
g_object_type:=p_object_type;
g_fact_audit:=p_fact_audit;
g_fact_net_change:=p_net_change;
g_fact_audit_name :=p_fact_audit_name;
g_fact_audit_is_name :=p_fact_audit_is_name;
g_fact_net_change_name :=p_net_change_name;
g_fact_net_change_is_name :=p_net_change_is_name;
g_parallel:=p_parallel;
g_table_owner := p_table_owner;
g_bis_owner:=p_bis_owner;
g_forall_size:=p_forall_size;
g_debug:=p_debug;
g_duplicate_collect:=p_duplicate_collect;
g_execute_flag:=p_execute_flag;
g_request_id:=p_request_id;
g_collection_size:=p_collection_size;
g_temp_log:=p_temp_log;
g_update_type :=p_update_type;
g_mode:=p_mode;
g_explain_plan_check:=p_explain_plan_check;
g_fact_dlog :=p_fact_dlog;
g_key_set:=p_key_set;
g_instance_type:=p_instance_type;
g_load_pk:=p_load_pk;
g_skip_cols:=p_skip_cols;
g_number_skip_cols:=p_number_skip_cols;
g_fresh_restart:=p_fresh_restart;
g_op_table_space:=p_op_table_space;
g_da_cols:=p_da_cols;
g_number_da_cols:=p_number_da_cols;
g_da_table:=p_da_table;
g_pp_table:=p_pp_table;
g_master_instance:=p_master_instance;
g_rollback:=p_rollback;
g_low_system_mem:=false;
g_skip_levels:=p_skip_levels;
g_number_skip_levels:=p_number_skip_levels;
g_smart_update:=p_smart_update;
g_fk_use_nl:=p_fk_use_nl;
g_fact_smart_update:=p_fact_smart_update;
g_auto_dang_table_extn:=p_auto_dang_table_extn;
g_log_dang_keys:=p_log_dang_keys;
g_create_parent_table_records:=p_create_parent_table_records;
g_object_id:=EDW_OWB_COLLECTION_UTIL.get_object_id(g_object_name);
g_smart_update_cols:=p_smart_update_cols;
g_number_smart_update_cols:=p_number_smart_update_cols;
g_check_fk_change:=p_check_fk_change;
g_stg_join_nl_percentage:=p_stg_join_nl_percentage;
g_ok_switch_update:=p_ok_switch_update;
g_stg_make_copy_percentage:=p_stg_make_copy_percentage;
g_read_cfig_options:=p_read_cfig_options;
g_jobid_stmt:=null;
g_job_id:=null;
g_analyze_freq:=p_analyze_frequency;
g_parallel_drill_down:=false;
if g_debug then
  write_to_log_file_n('Input parameters ');
  write_to_log_file('g_object_name='||g_object_name);
  write_to_log_file('g_object_id='||g_object_id);
  write_to_log_file('g_conc_program_id ='||g_conc_program_id);
  write_to_log_file('g_conc_program_name='||g_conc_program_name);
  write_to_log_file('g_mapping_id='||g_mapping_id);
  write_to_log_file('g_mapping_type='||g_mapping_type);
  write_to_log_file('g_primary_src='||g_primary_src);
  write_to_log_file('g_primary_target='||g_primary_target);
  write_to_log_file('g_primary_target_name='||g_primary_target_name);
  write_to_log_file('g_object_type='||g_object_type);
  if g_fact_audit then
    write_to_log_file('g_fact_audit=TRUE');
  else
    write_to_log_file('g_fact_audit=FALSE');
  end if;
  if g_fact_net_change then
    write_to_log_file('g_fact_net_change=TRUE');
  else
    write_to_log_file('g_fact_net_change=FALSE');
  end if;
  write_to_log_file('g_fact_audit_name='||g_fact_audit_name);
  write_to_log_file('g_fact_audit_is_name='||g_fact_audit_is_name);
  write_to_log_file('g_fact_net_change_name='||g_fact_net_change_name);
  write_to_log_file('g_fact_net_change_is_name='||g_fact_net_change_is_name);
  write_to_log_file('g_request_id='||g_request_id);
  write_to_log_file('g_collection_size='||g_collection_size);
  write_to_log_file('g_forall_size='||g_forall_size);
  write_to_log_file('g_parallel='||g_parallel);
  write_to_log_file('g_table_owner='||g_table_owner);
  write_to_log_file('g_bis_owner='||g_bis_owner);
  write_to_log_file('g_update_type='||g_update_type);
  write_to_log_file('g_mode='||g_mode);
  write_to_log_file('g_key_set='||g_key_set);
  write_to_log_file('g_instance_type='||g_instance_type);
  write_to_log_file('g_load_pk='||g_load_pk);
  write_to_log_file('g_op_table_space='||g_op_table_space);
  write_to_log_file('g_rollback='||g_rollback);
  if g_explain_plan_check then
    write_to_log_file('g_explain_plan_check= TRUE');
  else
    write_to_log_file('g_explain_plan_check= FALSE');
  end if;
  if g_temp_log then
    write_to_log_file('g_temp_log TRUE');
  else
    write_to_log_file('g_temp_log FALSE');
  end if;
  if g_duplicate_collect then
    write_to_log_file('g_duplicate_collect turned ON');
  else
    write_to_log_file('g_duplicate_collect turned OFF');
  end if;
  if g_execute_flag then
    write_to_log_file('g_execute_flag turned ON');
  else
    write_to_log_file('g_execute_flag turned OFF');
  end if;
  write_to_log_file('The skipped columns');
  for i in 1..g_number_skip_cols loop
    write_to_log_file(g_skip_cols(i));
  end loop;
  if g_fresh_restart then
    write_to_log_file('g_fresh_restart TRUE');
  else
    write_to_log_file('g_fresh_restart FALSE');
  end if;
  write_to_log_file('The Data Alignment Columns');
  for i in 1..g_number_da_cols loop
    write_to_log_file(g_da_cols(i));
  end loop;
  write_to_log_file('DA Table '||g_da_table);
  write_to_log_file('PP Table '||g_pp_table);
  write_to_log_file('Master Instance '||g_master_instance);
  write_to_log_file('Skipped levels');
  for i in 1..g_number_skip_levels loop
    write_to_log_file(g_skip_levels(i));
  end loop;
  if g_smart_update then
    write_to_log_file('g_smart_update TRUE');
  else
    write_to_log_file('g_smart_update FALSE');
  end if;
  write_to_log_file('g_fk_use_nl '||g_fk_use_nl);
  write_to_log_file('g_fact_smart_update '||g_fact_smart_update);
  write_to_log_file('g_auto_dang_table_extn '||g_auto_dang_table_extn);
  if g_log_dang_keys then
    --for facts or lowest levels
    write_to_log_file('g_log_dang_keys is TRUE');
  else
    write_to_log_file('g_log_dang_keys is FALSE');
  end if;
  if g_create_parent_table_records then
    write_to_log_file('g_create_parent_table_records is TRUE');
  else
    write_to_log_file('g_create_parent_table_records is FALSE');
  end if;
  write_to_log_file('Smart Update columns');
  for i in 1..g_number_smart_update_cols loop
    write_to_log_file(g_smart_update_cols(i));
  end loop;
  if g_check_fk_change then
    write_to_log_file('g_check_fk_change TRUE');
  else
    write_to_log_file('g_check_fk_change FALSE');
  end if;
  write_to_log_file('g_stg_join_nl_percentage = '||g_stg_join_nl_percentage);
  write_to_log_file('g_ok_switch_update='||g_ok_switch_update);
  write_to_log_file('g_stg_make_copy_percentage='||g_stg_make_copy_percentage);
  if g_read_cfig_options then
    write_to_log_file('g_read_cfig_options TRUE');
  else
    write_to_log_file('g_read_cfig_options FALSE');
  end if;
  write_to_log_file('g_analyze_freq='||g_analyze_freq);
end if;
g_total_records:=0;
if p_mapping_id =0 OR p_primary_src=0 OR p_primary_target=0 then
  p_status:=false;
  write_to_log_file_n('Map or src or tgt not specified. Fatal...');
  return;
end if;
--g_mapping_name :=p_mapping_name;
g_status:=true;
if g_debug then
    write_to_log_file_n('pre_mapping_coll'||get_time);
  end if;
insert_into_load_progress_d(g_load_pk,g_primary_target_name,'Pre Mapping Collection Hook',sysdate,null,'MAPPING',
'PRE-MAP',1010,'I');
if EDW_COLLECTION_HOOK.pre_mapping_coll(g_primary_target_name)= false then
   write_to_log_file_n('EDW_COLLECTION_HOOK.pre_mapping_coll returned with error.'||get_time);
   g_status:=false;
   p_status:=false;
   return;
end if;
write_to_log_file_n('EDW_COLLECTION_HOOK.pre_mapping_coll returned with success.'||get_time);
insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,1010,'U');
Init_all(null);
if g_status=false then
  p_status:=g_status;
  return;
end if;
insert_into_load_progress_d(g_load_pk,g_primary_target_name,'Read Metadata',sysdate,null,'MAPPING',
'METADATA-READ',1020,'I');
if g_debug then
  edw_owb_collection_util.dump_mem_stats;
end if;
Read_Metadata('ALL');
if g_debug then
  edw_owb_collection_util.dump_mem_stats;
end if;
insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,1020,'U');
if g_status=false then
  write_to_log_file_n('ERROR Read_Metadata for '||
	g_primary_target_name||' Error '||g_status_message||
        ', Time '||get_time);
  p_status:=false;
  return;
end if;
insert_into_load_progress_d(g_load_pk,g_primary_target_name,'Recover from any Previous Error',sysdate,null,'MAPPING',
'ERROR-RECOVERY',1040,'I');
if g_object_type='FACT' and (g_is_source=true or g_is_custom_source=true) then
  if dlog_setup=false then
    g_status:=false;
    p_status:=false;
    return;
  end if;
end if;
if g_fresh_restart=false then
  if merge_all_ok_tables=false then
    g_status:=false;
    p_status:=false;
    return;
  end if;
end if;
if recover_from_previous_error=false then
  write_to_log_file_n('ERROR in recover_from_previous_error ');
  p_status:=false;
  return;
end if;
insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,1040,'U');
insert_into_load_progress_d(g_load_pk,g_primary_target_name,'Check Number of Records to Load',sysdate,null,'MAPPING',
'LOAD-CHECK',1050,'I');
if check_total_records_to_collect=false then
  p_status:=false;
  return;
end if;
insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,1050,'U');
/*
these ops must be done before total records are checked and exit is made. this is for upgrade. if 3.1 or 3.01
customers implement data alignment, by running a load, the da and pp tables must be populated.
*/
if g_number_da_cols > 0 then
  if get_stg_da_columns=false then
    p_status:=false;
    return;
  end if;
  insert_into_load_progress_d(g_load_pk,g_primary_target_name,'Create Data Alignment Tables',sysdate,null,'MAPPING',
  'CREATE-TABLE','DATC','I');
  if create_da_pp_tables=false then
    insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'DATC','U');
    p_status:=false;
    return;
  end if;
  if populate_da_pp_tables =false then
    insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'DATC','U');
    p_status:=false;
    return;
  end if;
  insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'DATC','U');
end if;

if g_total_records=0 then
  clean_up;
  write_to_log_file_n('There are no records in the staging table with READY collection status');
  write_to_log_file('Stopping collection for this object');
  return;
end if;
--duplicate check and create ok table
--first mark all the duplicate records
--for duplicate check we need to consider the whole table at once.
insert_into_load_progress_d(g_load_pk,g_primary_target_name,'Duplicate Check',sysdate,null,'MAPPING',
'DUPLICATE-CHECK',1100,'I');
if execute_duplicate_check= false then
  write_to_log_file_n('execute_duplicate_check  returned with error');
  insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,1100,'U');
  p_status:=false;
  return;
end if;
insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,1100,'U');
if check_fk_direct_load=false then
  write_to_log_file_n('check_fk_direct_load returned with error');
  p_status:=false;
  return;
end if;
--see if this is a case of single instance
if g_instance_type='SINGLE' then
  if check_pk_direct_load=false then
    write_to_log_file_n('check_pk_direct_load returned with error');
    p_status:=false;
    return;
  end if;
  /*
  if the pk_key is to be directly loaded from the staging table, then chahnge the mapping from
  seq to stg.pk_key
  */
  if g_pk_direct_load then
    if make_pk_direct_load('DIRECT-LOAD')=false then
      write_to_log_file_n('make_pk_direct_load returned with error');
      p_status:=false;
      return;
    end if;
  end if;
end if;
/*
collect records collects in chunks
*/
if collect_records = false then
  write_to_log_file_n('collect_records returned with false.');
  p_status:=false;
  return;
end if;
clean_up;
if g_debug then
  write_to_log_file_n('post_mapping_coll'||get_time);
end if;
if post_operations=false then
  return;
end if;
Exception when others then
 write_to_log_file_n('Error in COLLECT '||g_primary_target_name||' '||sqlerrm||get_time);
 g_status_message:=sqlerrm;
 g_status:=false;
End;


function collect_records return boolean is
l_count number;
Begin
  if g_debug then
    write_to_log_file_n('In collect_records'||get_time);
  end if;
  l_count:=0;
  /*
    if g_fstg_all_fk_direct_load=false then there is no need to check the explain plan.
  */
  if g_fstg_all_fk_direct_load=false then
    if g_explain_plan_check then
      --check the explain plan. if there is a change reqd, call make_sql_surrogate_fk again
      insert_into_load_progress_d(g_load_pk,g_primary_target_name,g_jobid_stmt||'Generate Explain Plan',sysdate,null,'MAPPING',
      'EXPLAIN-PLAN',g_jobid_stmt||'1080','I');
      if generate_explain_plan(g_exp_plan_stmt) = true then
        insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'1080','U');
        if check_explain_plan=true then
          --generate the lookup tables
          insert_into_load_progress_d(g_load_pk,g_primary_target_name,g_jobid_stmt||'Generate Dimension Lookup Tables',sysdate,
          null,'MAPPING','LOOKUP',g_jobid_stmt||'1090','I');
          if generate_fts_lookups=false then
            write_to_log_file_n('generate_fts_lookups returned with error. going ahead with bad plan');
          end if;
          insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'1090','U');
        end if;
      else
        insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'1080','U');
      end if;
    end if;
  end if;
  --if fact audit is on, make the stmt
  if g_fact_audit then
    select_fact_audit;--make the stmts
    if g_status=false then
      write_to_log_file_n('select_fact_audit has errors');
      return false;
    end if;
  end if;
  --if net change is on, get it..
  if g_fact_net_change then
    select_net_change;--make the stmts
    if g_status=false then
      write_to_log_file_n('select_net_change ERROR');
      return false;
    end if;
  end if;
  if g_mapping_type='FACT' then
    make_data_into_dlog_stmt;--if this is a derived fact then we need to move the data into dlog for updates
    /*if g_dlog_has_data then
      if recreate_dlog_table=false then
        return false;
      end if;
    end if;
    if check_cols_in_dlog=false then
      return false;
    end if;*/
  end if;
  if g_status=false then
    return false;
  end if;
  g_collections_done:=false;
  if set_g_type_ok_generation=false then
    g_type_ok_generation:='CTAS';
  end if;
  loop
    --first make the records processing
    /*
    make_records_processing should not occur the first time that error recovery is active
    */
    --dynamic change of collection size
    l_count:=l_count+1;
    --if reset_profiles=false then
      --return false;
    --end if;
    if g_err_rec_flag=false then
      insert_into_load_progress_d(g_load_pk,g_primary_target_name,g_jobid_stmt||'Mark Records for Processing',sysdate,null,
      'MAPPING','UPDATE',g_jobid_stmt||'MKRP'||l_count,'I');
      if g_skip_ilog_update=false then
        make_records_processing; --makes ready records to processing.
      else
        g_skip_ilog_update:=false;
      end if;
      insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'MKRP'||l_count,'U');
    else
      if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_ok_rowid_table,' status=1 ')<2 then
        make_records_processing; --makes ready records to processing.
      end if;
    end if;
    g_err_rec_flag:=false;
    g_skip_ilog_update:=false;
    if g_status = false then
      return false;
    end if;
    /*
    make_records_processing tells if g_collections_done is true or not
    */
    if g_collections_done=true then
      exit;
    end if;
    --make the copy of the stg table if needed
    if g_stg_copy_table_flag then
      if make_stg_copy=false then
        return false;
      end if;
    end if;
    execute_all(l_count);
    if g_status=false then
      write_to_log_file_n('Error in execute_all '||g_status_message);
      return false;
    end if;
    if g_type_ok_generation='UPDATE' then
      --else, make_records_processing will create the ok table
      insert_into_load_progress_d(g_load_pk,g_primary_target_name,g_jobid_stmt||'Mark Records as Processed',sysdate,null,
      'MAPPING','UPDATE',g_jobid_stmt||'MKRPP'||l_count,'I');
      if update_ok_status_2= false then
        return false;
      end if;
      insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'MKRPP'||l_count,'U');
    end if;
    if g_fact_audit or g_fact_net_change then
      if drop_fa_nc_rec_tables=false then
        return false;
      end if;
    end if;
    /*
    we only need to insert into temp log and not worry about updates. the logic for updates are handled
    in get_lowest_level_log in EDW_ALL_COLLECT
    this ing is only for the lowest level. so we need to control that with g_temp_log
    also true for facts
    */
    if g_temp_log then
      if EDW_OWB_COLLECTION_UTIL.insert_temp_log_table(
          g_object_name,
          g_object_type,
          g_conc_program_id,
          g_ins_instance_name,
          g_ins_request_id_table,
          g_ins_rows_ready,
          g_ins_rows_processed,
          g_ins_rows_collected,
          g_ins_rows_dangling,
          g_ins_rows_duplicate,
          g_ins_rows_error,
          g_total_records,
          g_total_insert,
          g_total_update,
          g_total_delete,
          g_number_ins_req_coll) = false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        g_status:=false;
        write_to_log_file_n(g_status_message);
        return false;
      end if;
    end if;
    commit;
    if g_debug then
       write_to_log_file_n('commit');
    end if;
    --if execute_collect_to_collected(l_count)= false then
      --return false;
    --end if;
  end loop;
  if g_number_da_cols>0 then
    insert_into_load_progress_d(g_load_pk,g_primary_target_name,g_jobid_stmt||'Load Into PP Table',sysdate,null,
    'MAPPING','INSERT',g_jobid_stmt||'LOADPP','I');
    if load_dup_coll_into_pp=false then
      insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'LOADPP','U');
      return false;
    end if;
    insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'LOADPP','U');
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function drop_index_surr_table return boolean is
l_stmt varchar2(6000);
Begin
  if g_debug then
   write_to_log_file_n('In drop_index_surr_table'||get_time);
  end if;
  l_stmt:='drop index '||g_surr_table||'n1';
  begin
    execute immediate l_stmt;
  exception when others then
    write_to_log_file_n('Error executing '||l_stmt||' '||sqlerrm);
  end;
  l_stmt:='drop index '||g_surr_table||'u1';
  begin
    execute immediate l_stmt;
  exception when others then
    write_to_log_file_n('Error executing '||l_stmt||' '||sqlerrm);
  end;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function create_index_surr_table return boolean is
l_stmt varchar2(6000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_res number;
-----------------------------
l_table1 varchar2(200);
l_columns EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_columns number;
-----------------------------
Begin
  if g_debug then
   write_to_log_file_n('In create_index_surr_table'||get_time);
  end if;
  l_stmt:='select 1 from '||g_surr_table||' having count(*)>1 group by row_id';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  open cv for l_stmt;
  fetch cv into l_res;
  close cv;
  if l_res=1 then
    /*g_status_message:=EDW_OWB_COLLECTION_UTIL.get_message('EDW_DUPLICATE_ROW_FOUND');
    write_to_log_file_n(g_status_message);
    g_status:=false;
    return false;*/
    --remove the duplicates from g_surr_table
    if g_debug then
      write_to_log_file_n('Duplicate rows found...Deleting...');
    end if;
    if EDW_OWB_COLLECTION_UTIL.get_db_columns_for_table(substr(g_surr_table,
      instr(g_surr_table,'.')+1,length(g_surr_table)),l_columns,l_number_columns,
      g_bis_owner)=false then
      g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
      write_to_log_file_n(g_status_message);
      g_status:=false;
      return false;
    end if;
    l_table1:=g_surr_table||'_T1';
    if edw_owb_collection_util.drop_table(l_table1)=false then
      null;
    end if;
    l_stmt:='create table '||l_table1||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||' as select row_id';
    for i in 1..l_number_columns loop
      if l_columns(i)<>'ROW_ID' then
        l_stmt:=l_stmt||',max('||l_columns(i)||') '||l_columns(i);
      end if;
    end loop;
    l_stmt:=l_stmt||' from '||g_surr_table||' group by row_id';
    if g_debug then
      write_to_log_file_n(l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
    end if;
    if edw_owb_collection_util.drop_table(g_surr_table)=false then
      null;
    end if;
    l_stmt:='create table '||g_surr_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||' as select * from  '||l_table1;
    if g_debug then
      write_to_log_file_n(l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    g_surr_count:=sql%rowcount;
    if g_debug then
      write_to_log_file_n('Created with '||g_surr_count||' rows '||get_time);
    end if;
    if edw_owb_collection_util.drop_table(l_table1)=false then
      null;
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_surr_table,instr(g_surr_table,'.')+1,
    length(g_surr_table)),substr(g_surr_table,1,instr(g_surr_table,'.')-1));
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

procedure Read_Metadata(p_mode varchar2) IS
l_model_id number;
l_mapping_id number;
l_fstgTableUsageId number;
l_fstgTableId number;
l_factTableUsageId number;
l_factTableId number;
l_dimTableUsageId EDW_OWB_COLLECTION_UTIL.numberTableType ;
l_dimTableId EDW_OWB_COLLECTION_UTIL.numberTableType ;
l_fstgUserFKUsageId EDW_OWB_COLLECTION_UTIL.numberTableType ;
l_fstgUserFKId EDW_OWB_COLLECTION_UTIL.numberTableType ;
l_pk_extn varchar2(20);
l_option_value varchar2(40);
Begin
  l_pk_extn:='_KEY';
  write_to_debug_n('In Read_Metadata p_mode='||p_mode||' '||get_time);
  l_mapping_id:=g_mapping_id;
  g_numberOfDimTables :=1;
  g_num_ff_map_cols :=0;
  g_number_sequence :=1;
  begin
    --get the delatails about the primary source
    --not checked
    if EDW_OWB_COLLECTION_UTIL.get_stg_map_pk_params(
      l_mapping_id,
      l_fstgTableUsageId,
      l_fstgTableId,
      g_fstgTableName ,
      l_factTableUsageId,
      l_factTableId,
      g_factTableName ,
      g_fstgPKName,
      g_factPKName)=false then
      g_status:=false;
      g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
      return;
    end if;
    g_primary_src_name:=g_fstgTableName ;
    g_factPKNameKey:=g_factPKName||l_pk_extn;
    g_fstgPKNameKey:=g_fstgPKName||l_pk_extn;
    write_to_debug_n('fstg table usage id '||l_fstgTableUsageId||' fact table '||g_factTableName||' with Pk '||
    g_factPKName || ' and usage '||l_factTableUsageId);
  exception when others then
    g_status_message:=sqlerrm;
    write_to_log_file_n('Error in fetching primary source and target info :'||sqlerrm||get_time);
    g_status:=false;
    return;
  end;
  g_dim_auto_dang_table_dim:=g_bis_owner||'.'||g_auto_dang_table_extn||'_'||g_object_id;--need to add instance
  --this is only used for lowest level of dimensions
  Begin
    if EDW_OWB_COLLECTION_UTIL.get_stg_map_fk_details(
      l_fstgTableUsageId,
      l_fstgTableId,
      l_mapping_id,
      g_job_id,
      g_op_table_space,
      g_bis_owner,
      g_dimTableName,
      g_dim_row_count,
      g_dimTableId,
      g_dimUserPKName,
      g_fstgUserFKName,
      g_factFKName,
      g_numberOfDimTables
      )=false then
      g_status:=false;
      g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
      return;
    end if;
    for i in 1..g_numberOfDimTables loop
      g_dimActualPKName(i):=g_dimUserPKName(i)||l_pk_extn;
      g_fstgActualFKName(i):=g_fstgUserFKName(i)||l_pk_extn;
      if g_instance_column is null then
        if g_dimTableName(i)=g_instance_dim_name then
          g_instance_column:=g_fstgUserFKName(i);
        end if;
      end if;
    end loop;
    for i in 1..g_numberOfDimTables loop
      l_option_value:=null;
      if g_read_cfig_options then
        if edw_option.get_warehouse_option(null,g_dimTableId(i),'ALIGNMENT',l_option_value)=false then
          g_status_message:=edw_option.g_status_message;
          g_status:=false;
          return;
        end if;
      else
        if EDW_OWB_COLLECTION_UTIL.is_itemset_implemented(g_dimTableName(i),'DATA_ALIGNMENT')='Y' then
          l_option_value:='Y';
        else
          l_option_value:='N';
        end if;
      end if;
      if l_option_value='Y' then
        g_dimTable_da_flag(i):=true;
        g_dimTableName_kl(i):=EDW_OWB_COLLECTION_UTIL.get_PP_table(g_dimTableName(i));
        g_dimTableName_pp(i):=g_dimTableName_kl(i);
        g_dimTableName_da(i):=EDW_OWB_COLLECTION_UTIL.get_DA_table(g_dimTableName(i));
        if g_dimTableName_kl(i) is null then
          g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
          g_status:=false;
          return;
        end if;
      else
        g_dimTable_da_flag(i):=false;
        g_dimTableName_kl(i):=g_dimTableName(i); --this is used in make_sql_surrogate_stmt DEFAULT
        g_dimTableName_pp(i):=g_dimTableName(i);
        g_dimTableName_da(i):=g_dimTableName(i);
      end if;
      l_option_value:=null;
      if g_read_cfig_options then
        if edw_option.get_warehouse_option(null,g_dimTableId(i),'SLOWDIM',l_option_value)=false then
          g_status_message:=edw_option.g_status_message;
          g_status:=false;
          return;
        end if;
      else
        if EDW_OWB_COLLECTION_UTIL.is_itemset_implemented(g_dimTableName(i),'DIMENSION_HISTORY')='Y' then
          l_option_value:='Y';
        else
          l_option_value:='N';
        end if;
      end if;
      if l_option_value='Y' then
        g_dimTable_slow_flag(i):=true;
        g_dimTableName_kl(i):=g_dimTableName(i);
      else
        g_dimTable_slow_flag(i):=false;
      end if;
      g_fstg_fk_direct_load(i):=false;--need surr key lookup by default.
      if EDW_OWB_COLLECTION_UTIL.value_in_table(g_skip_cols,g_number_skip_cols,g_factFKName(i)) then
        g_fstg_fk_value_load(i):=true;
        g_fstg_fk_load_value(i):=g_naedw_value;
      elsif g_dimTableName(i)='EDW_NA' then
        g_fstg_fk_value_load(i):=true;
        g_fstg_fk_load_value(i):=g_naedw_value;
      elsif EDW_OWB_COLLECTION_UTIL.value_in_table(g_skip_levels,g_number_skip_levels,g_dimTableName(i)) then
        g_fstg_fk_value_load(i):=true;
        g_fstg_fk_load_value(i):=g_naedw_value;
      else
        g_fstg_fk_value_load(i):=false;
      end if;
      g_dim_auto_dang_table(i):=g_bis_owner||'.'||g_auto_dang_table_extn||'_'||g_dimTableId(i);--need to add instance
    end loop;
    g_fstg_all_fk_direct_load:=false;--by default
    if g_debug then
      write_to_log_file_n('Results of cursor c3 reading fk mappings');
      write_to_log_file('Mapping between Dimension and KL table');
      for i in 1..g_numberOfDimTables loop
        write_to_log_file(g_dimTableName(i)||' ('||g_dimTableName_kl(i)||')');
      end loop;
      write_to_log_file('parent table(parent pk)            stg fk           target fk');
      for i in 1..g_numberOfDimTables loop
        write_to_log_file(g_dimTableName(i)||'('||g_dimUserPKName(i)||')     '||
        g_fstgUserFKName(i)||'   '||g_factFKName(i));
      end loop;
    end if;
  exception when others then
    g_status_message:=sqlerrm;
    write_to_log_file_n('Error in opening c3 to get secondary source info:'||sqlerrm||get_time);
    g_status:=false;
    return;
  end;
  if g_parallel is not null then
    g_key_set:=g_numberOfDimTables;
  end if;
  --get the stg to tgt mapping details
  --get_src_tgt_map_details is only used here.
  if EDW_OWB_COLLECTION_UTIL.get_src_tgt_map_details(
    g_mapping_id,
    g_primary_target,
    g_primary_src,
    g_factPKNameKey ,
    g_dimTableName,
    g_numberOfDimTables,
    g_fact_mapping_columns,
    g_fstg_mapping_columns,
    g_num_ff_map_cols,
    g_groupby_cols,
    g_number_groupby_cols,
    g_instance_column,
    g_groupby_on,
    g_pk_key_seq_pos,
    g_pk_key_seq)=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    g_status:=false;
    return;
  end if;
  for i in 1..g_num_ff_map_cols loop
    g_skip_item(i):=false;
  end loop;
  --mark the attributes that are turned off
  if g_number_skip_cols>0 then
    for i in 1..g_num_ff_map_cols loop
      for j in 1..g_number_skip_cols loop
        if g_fact_mapping_columns(i)=g_skip_cols(j) then
          g_skip_item(i):=true;
          exit;
        end if;
      end loop;
    end loop;
  end if;
  if g_debug then
    write_to_log_file_n('The sequence for the pk_key and position');
    write_to_log_file(g_pk_key_seq||'    '||g_pk_key_seq_pos);
  end if;
  declare
    l_dim_list EDW_OWB_COLLECTION_UTIL.varcharTableType;
    l_number_dim_list number;
    l_index number;
  begin
    if EDW_OWB_COLLECTION_UTIL.get_dims_slow_change(g_dimTableName,g_numberOfDimTables,
      l_dim_list,l_number_dim_list) = false then
      g_status:=false;
      return;
    end if;
    for i in 1..g_numberOfDimTables loop
      l_index:=0;
      l_index:=EDW_OWB_COLLECTION_UTIL.index_in_table(l_dim_list,l_number_dim_list,
      g_dimTableName(i));
      g_slow_change_tables(i):=null;
      if l_index>0 then
        g_slow_change_tables(i):=g_dimTableName(i);
      end if;
    end loop;
  end;
  write_to_debug_n('Finished Read_Metadata'||get_time);
EXCEPTION when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in processing c4 to get mapping info:'||sqlerrm||get_time);
  return;
End; --end Read Metadata

procedure make_sql_surrogate_fk IS
--make the sql statement
l_stmt varchar2(30000);
l_alias EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_pk EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_pk_key EDW_OWB_COLLECTION_UTIL.varcharTableType;
begin
write_to_debug_n('In make_sql_surrogate_fk');
/*
if g_fstg_all_fk_direct_load is true then  g_user_fk_table is not going to be created at all
g_fstg_all_fk_direct_load is true or not, surr table is created
if g_fstg_all_fk_direct_load is true then, surr table only contains rowid, op code etc
*/
--if g_fstg_all_fk_direct_load then
  --g_user_fk_table:=g_fstgTableName;
--else
  --null;
--end if;
l_stmt:='create table '||g_surr_table||' tablespace '||g_op_table_space;
if g_parallel is not null then
  l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
end if;
l_stmt:=l_stmt||'  ';
l_stmt:=l_stmt||' as select ';
if g_user_fk_table=g_fstgTableName then
  if g_stg_join_nl and g_stg_copy_table_flag=false then
    l_stmt:=l_stmt||'/*+ORDERED USE_NL('||g_fstgTableName||')*/ ';
  else
    l_stmt:=l_stmt||'/*+ORDERED*/ ';
  end if;
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+PARALLEL('||g_fstgTableName||','||g_parallel||')*/ ';
  end if;
end if;
if g_user_fk_table=g_fstgTableName then
  l_stmt:=l_stmt||' '||g_user_fk_table||'.rowid row_id, ';
else
  l_stmt:=l_stmt||' '||g_user_fk_table||'.row_id row_id, ';
end if;
if g_stg_copy_table_flag or g_use_mti then
  l_stmt:=l_stmt||' '||g_opcode_table||'.row_id_copy row_id_copy,';
end if;
l_stmt:=l_stmt||' '||g_opcode_table||'.row_id1 row_id1, ';
l_stmt:=l_stmt||g_opcode_table||'.operation_code operation_code';
l_stmt:=l_stmt||','||g_opcode_table||'.'||g_fstgPKNameKey||' '||g_fstgPKNameKey;
for i in 1..g_numberOfDimTables loop
  if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
    l_alias(i):=substr(g_dimTableName_kl(i),instr(g_dimTableName_kl(i),'.')+1,
    length(g_dimTableName_kl(i)))||'_'||i;
    l_pk(i):=g_dimUserPKName(i);
    l_pk_key(i):=g_dimActualPKName(i);
    if g_dimTable_da_flag(i) and g_dimTable_slow_flag(i)=false then
      l_pk(i):='PK';
      l_pk_key(i):='PK_KEY';
    end if;
    if g_mode='TEST' then
      l_stmt:=l_stmt||', nvl('||l_alias(i)||'.'||l_pk_key(i)||',-1) '||g_fstgActualFKName(i);
    else
      l_stmt:=l_stmt||', '||l_alias(i)||'.'||l_pk_key(i)||' '||g_fstgActualFKName(i);
    end if;
  end if;
end loop;
if g_update_type='DELETE-INSERT' then
  l_stmt:=l_stmt||','||g_opcode_table||'.'||g_fstgPKName||' '||g_fstgPKName||','||
  g_opcode_table||'.CREATION_DATE CREATION_DATE';
end if;
l_stmt:=l_stmt||' from ';
for i in 1..g_numberOfDimTables loop
  if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
    l_stmt:=l_stmt||g_dimTableName_kl(i)||' '||l_alias(i)||', ';
  end if;
end loop;
if g_user_fk_table=g_fstgTableName and g_stg_copy_table_flag then
  l_stmt:=l_stmt||g_opcode_table||','||g_stg_copy_table||' '||g_user_fk_table;
else
  l_stmt:=l_stmt||g_opcode_table||','||g_user_fk_table||' ';
end if;
l_stmt:=l_stmt||' where ';
for i in 1..g_numberOfDimTables loop
  if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
    if g_mode='TEST' then
      l_stmt:=l_stmt||l_alias(i)||'.'||l_pk(i)||'(+)='||g_user_fk_table||'.'||
         g_fstgUserFKName(i)||' and ';
    else
      l_stmt:=l_stmt||l_alias(i)||'.'||l_pk(i)||'='||g_user_fk_table||'.'||
         g_fstgUserFKName(i)||' and ';
    end if;
  end if;
end loop;
if g_user_fk_table=g_fstgTableName then
  if g_stg_copy_table_flag then
    l_stmt:=l_stmt||g_user_fk_table||'.rowid='||g_opcode_table||'.row_id_copy ';
  else
    l_stmt:=l_stmt||g_user_fk_table||'.rowid='||g_opcode_table||'.row_id ';
  end if;
else
  l_stmt:=l_stmt||g_user_fk_table||'.row_id='||g_opcode_table||'.row_id ';
end if;
g_surrogate_stmt:=l_stmt;
if g_debug then
  write_to_debug_n('Surrogate stmt '||g_surrogate_stmt);
end if;
--generate the stmt for explain plan
g_exp_plan_stmt:=null;
if g_numberOfDimTables > 0 then
  l_stmt:=' select ';
  l_stmt:=l_stmt||' '||g_fstgTableName||'.rowid ';
  for i in 1..g_numberOfDimTables loop
    if g_fstg_fk_direct_load(i) = false and g_fstg_fk_value_load(i)=false then
      if g_mode='TEST' then
        l_stmt:=l_stmt||', nvl('||substr(g_dimTableName_kl(i),instr(g_dimTableName_kl(i),'.')+1,
          length(g_dimTableName_kl(i)))||'_'||i||'.'||g_dimActualPKName(i)||',-1) ';
      else
        l_stmt:=l_stmt||', '||substr(g_dimTableName_kl(i),instr(g_dimTableName_kl(i),'.')+1,length(g_dimTableName_kl(i)))
          ||'_'||i||'.'||g_dimActualPKName(i)||' ';
      end if;
    end if;
  end loop;
  l_stmt:=l_stmt||' from ';
  for i in 1..g_numberOfDimTables loop
    if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
      l_stmt:=l_stmt||g_dimTableName_kl(i)||' '||substr(g_dimTableName_kl(i),instr(g_dimTableName_kl(i),'.')+1,
        length(g_dimTableName_kl(i)))||'_'||i||', ';
    end if;
  end loop;
  if g_stg_copy_table_flag then
    l_stmt:=l_stmt||' '||g_stg_copy_table||' '||g_fstgTableName||' ';
  else
    l_stmt:=l_stmt||' '||g_fstgTableName||' ';
  end if;
  l_stmt:=l_stmt||' where ';
  for i in 1..g_numberOfDimTables loop
    if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
      if g_mode='TEST' then
        l_stmt:=l_stmt||g_dimTableName_kl(i)||'_'||i||'.'||g_dimUserPKName(i)||'(+)='||g_fstgTableName||'.'||
           g_fstgUserFKName(i)||' and   ';
      else
        l_stmt:=l_stmt||g_dimTableName_kl(i)||'_'||i||'.'||g_dimUserPKName(i)||'='||g_fstgTableName||'.'||
           g_fstgUserFKName(i)||' and   ';
      end if;
    end if;
  end loop;
  --the 6 is imp.
  l_stmt:=substr(l_stmt,1,length(l_stmt)-6);
  g_exp_plan_stmt:=l_stmt;
end if;
EXCEPTION when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
End; --end procedure make_sql_surrogate_fk IS

procedure make_hd_insert_stmt is
l_divide number:=2;
l_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_cols_datatype EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_cols_flag EDW_OWB_COLLECTION_UTIL.booleanTableType;
l_number_cols number;
l_data_length EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_num_distinct EDW_OWB_COLLECTION_UTIL.numberTableType;
l_num_nulls EDW_OWB_COLLECTION_UTIL.numberTableType;
l_avg_col_length EDW_OWB_COLLECTION_UTIL.numberTableType;
l_itemset_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_itemset_cols number;
l_extent number;
l_option_value varchar2(40);
l_index integer;
l_size integer;
l_count number;
Begin
  if g_debug then
    write_to_log_file_n('In make_hd_insert_stmt');
  end if;
  if EDW_OWB_COLLECTION_UTIL.get_table_next_extent(g_factTableName,g_table_owner,g_fact_next_extent)=false then
    g_fact_next_extent:=null;
  end if;
  if g_fact_next_extent is null or g_fact_next_extent=0 then
    g_fact_next_extent:=16777216;
  end if;
  l_size:=0;
  if g_smart_update then
    if edw_owb_collection_util.get_db_columns_for_table(
      g_factTableName,
      l_cols,
      l_cols_datatype,
      l_data_length,
      l_num_distinct,
      l_num_nulls,
      l_avg_col_length,
      l_number_cols,
      g_table_owner)=false then
      g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
      g_status:=false;
      return;
    end if;
    for i in 1..l_number_cols loop
      l_cols_flag(i):=false;
    end loop;
    l_number_itemset_cols:=g_number_smart_update_cols;
    l_itemset_cols:=g_smart_update_cols;
    if l_number_itemset_cols>0 then
      for i in 1..l_number_itemset_cols loop
        l_cols_flag(EDW_OWB_COLLECTION_UTIL.index_in_table(l_cols,l_number_cols,l_itemset_cols(i))):=true;
      end loop;
    else
      for i in 1..l_number_cols loop
        l_cols_flag(i):=true;
      end loop;
    end if;
    --we only check those columns that are not for skip
    for i in 1..l_number_cols loop
      l_index:=0;
      l_index:=edw_owb_collection_util.index_in_table(g_fact_mapping_columns,g_num_ff_map_cols,l_cols(i));
      if l_index>0 then
        if g_skip_item(l_index) then
          l_cols_flag(i):=false;
        else
          l_size:=l_size+l_avg_col_length(i);
        end if;
      end if;
    end loop;
    for i in 1..l_number_cols loop
      if l_cols_flag(i) then
        if not(instr(l_cols_datatype(i),'CHAR')>0 or l_cols_datatype(i) ='NUMBER'
          or l_cols_datatype(i) ='LONG' or l_cols_datatype(i) ='DATE' or
          l_cols_datatype(i) ='RAW' or l_cols_datatype(i) ='LONG RAW') then
          if g_debug then
           write_to_log_file_n('Column '||l_cols(i)||' has datatype '||l_cols_datatype(i)||
           ',cannot do smart update');
          end if;
          g_smart_update:=false;
          exit;
        end if;
      end if;
    end loop;
    if g_smart_update then
      l_count:=0;
      for i in 1..l_number_cols loop
        if l_cols_flag(i) then
          l_count:=l_count+1;
        end if;
      end loop;
      if g_fact_smart_update is not null and g_fact_smart_update>0 then
        if l_count>g_fact_smart_update then
          g_smart_update:=false;
        end if;
      end if;
    end if;
    if g_collection_size is null or g_number_rows_ready>g_collection_size then
      l_size:=l_size*g_number_rows_ready;
    else
      l_size:=l_size*g_collection_size;
    end if;
    if g_parallel is not null then
      l_size:=l_size/g_parallel;
    end if;
    l_size:=round(l_size/1048576)+1048576;
  end if;
  if g_debug then
    if g_smart_update then
      write_to_log_file_n('Smart update TRUE');
    else
      write_to_log_file_n('Smart update FALSE');
    end if;
  end if;
  if g_smart_update then
    g_hd_insert_stmt:='create table '||g_hold_table_temp||' tablespace '||g_op_table_space;
  else
    g_hd_insert_stmt:='create table '||g_hold_table||' tablespace '||g_op_table_space;
  end if;
  if g_fact_next_extent is not null or l_size>0 then
    if g_parallel is null then
      l_divide:=2;
    else
      l_divide:=g_parallel;
    end if;
    l_extent:=g_fact_next_extent/l_divide;
    if l_extent>16777216 then --16M
      l_extent:=16777216;
    end if;
    if l_extent is null or l_extent=0 then
      l_extent:=4194304;
    end if;
    if l_size>0 and l_size<l_extent then
      l_extent:=l_size;
    end if;
    g_hd_insert_stmt:=g_hd_insert_stmt||' storage(initial '||l_extent||' next '||
    l_extent||' pctincrease 0 MAXEXTENTS 2147483645) ';
  end if;
  if g_parallel is not null then
    g_hd_insert_stmt:=g_hd_insert_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  g_hd_insert_stmt:=g_hd_insert_stmt||' as select ';
  if g_stg_join_nl then
    g_hd_insert_stmt:=g_hd_insert_stmt||' /*+ORDERED USE_NL('||g_fstgTableName||')*/ ';
  else
    g_hd_insert_stmt:=g_hd_insert_stmt||' /*+ORDERED*/ ';
  end if;
  if g_parallel is not null then
    g_hd_insert_stmt:=g_hd_insert_stmt||' /*+PARALLEL ('||g_fstgTableName||','||g_parallel||')*/ ';
  end if;
  for i in 1..g_num_ff_map_cols loop
    if g_skip_item(i)=false then
      if g_update_type='DELETE-INSERT' then
        if g_fact_mapping_columns(i) <> g_factPKNameKey then
          g_hd_insert_stmt:=g_hd_insert_stmt||g_fstg_mapping_columns(i)||' '||g_fact_mapping_columns(i)||',';
        end if;
      else
        if g_fact_audit or g_fact_net_change then
          if g_fact_mapping_columns(i) <> g_factPKNameKey then
            g_hd_insert_stmt:=g_hd_insert_stmt||g_fstg_mapping_columns(i)||' '||g_fact_mapping_columns(i)||',';
          end if;
        else
          if g_fact_mapping_columns(i)<> g_factPKName and g_fact_mapping_columns(i) <> g_factPKNameKey then
            g_hd_insert_stmt:=g_hd_insert_stmt||g_fstg_mapping_columns(i)||' '||g_fact_mapping_columns(i)||',';
          end if;
        end if;
      end if;
    end if;
  end loop;
  if g_update_type='DELETE-INSERT' then
    g_hd_insert_stmt:=g_hd_insert_stmt||g_surr_table||'.'||g_fstgPKNameKey||' '||g_factPKNameKey||',';
    g_hd_insert_stmt:=g_hd_insert_stmt||g_surr_table||'.CREATION_DATE CREATION_DATE,';
  else
    if g_fact_audit or g_fact_net_change then
      g_hd_insert_stmt:=g_hd_insert_stmt||g_surr_table||'.'||g_fstgPKNameKey||' '||g_factPKNameKey||',';
    end if;
  end if;
  for i in 1..g_numberOfDimTables loop
   if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
     g_hd_insert_stmt:=g_hd_insert_stmt||g_surr_table||'.'||g_fstgActualFKName(i)||' '||g_factFKName(i)||',';
   elsif g_fstg_fk_value_load(i)=true then
     g_hd_insert_stmt:=g_hd_insert_stmt||g_fstg_fk_load_value(i)||' '||g_factFKName(i)||',';
   else
     g_hd_insert_stmt:=g_hd_insert_stmt||g_fstgTableName||'.'||g_fstgActualFKName(i)||' '||g_factFKName(i)||',';
   end if;
  end loop;
  -- op code of 0=insert 1=update and 2=delete
  g_hd_insert_stmt:=g_hd_insert_stmt||g_surr_table||'.row_id1 row_id1 from '||g_surr_table||',';
  if g_stg_copy_table_flag then
    g_hd_insert_stmt:=g_hd_insert_stmt||g_stg_copy_table||' '||g_fstgTableName;
    g_hd_insert_stmt:=g_hd_insert_stmt||' where '||g_surr_table||'.operation_code=1 and '||
    g_fstgTableName||'.rowid='||g_surr_table||'.row_id_copy';
  elsif g_use_mti then
    g_hd_insert_stmt:=g_hd_insert_stmt||g_user_measure_table||' '||g_fstgTableName;
    g_hd_insert_stmt:=g_hd_insert_stmt||' where '||g_surr_table||'.operation_code=1 and '||
    g_fstgTableName||'.rowid='||g_surr_table||'.row_id_copy';
  else
    g_hd_insert_stmt:=g_hd_insert_stmt||g_fstgTableName;
    g_hd_insert_stmt:=g_hd_insert_stmt||' where '||g_surr_table||'.operation_code=1 and '||
    g_fstgTableName||'.rowid='||g_surr_table||'.row_id';
  end if;
  if g_groupby_on=true then
    g_hd_insert_stmt:=g_hd_insert_stmt||' group by ';
    if g_number_groupby_cols> 0 then
      for i in 1..g_number_groupby_cols loop
        g_hd_insert_stmt:=g_hd_insert_stmt||g_fstgTableName||'.'||g_groupby_cols(i)||',';
      end loop;
    end if;
    for i in 1..g_numberOfDimTables loop
      if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
        g_hd_insert_stmt:=g_hd_insert_stmt||g_surr_table||'.'||g_fstgActualFKName(i)||',';
      elsif g_fstg_fk_direct_load(i)=true then
        g_hd_insert_stmt:=g_hd_insert_stmt||g_fstgTableName||'.'||g_fstgActualFKName(i)||',';
      end if;
    end loop;
    g_hd_insert_stmt:=g_hd_insert_stmt||g_surr_table||'.row_id1 ';
  end if;
  --g_hd_insert_stmt:=g_hd_insert_stmt||' ';
  if g_debug then
    write_to_log_file_n('g_hd_insert_stmt is '||g_hd_insert_stmt);
  end if;
EXCEPTION when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
End;

procedure make_insert_update_stmt IS
l_stmt varchar2(30000);
l_pk_index number;
l_pk_key_index number;
--g_creation_date_flag boolean;
--g_last_update_date_flag boolean;
begin
write_to_debug_n('In make_insert_update_stmt');
if EDW_OWB_COLLECTION_UTIL.value_in_table(g_fact_mapping_columns,
    g_num_ff_map_cols,'CREATION_DATE')= false then
  g_creation_date_flag:=true;
else
  g_creation_date_flag:=false;
end if;
if EDW_OWB_COLLECTION_UTIL.value_in_table(g_fact_mapping_columns,
      g_num_ff_map_cols,'LAST_UPDATE_DATE')= false then
  g_last_update_date_flag:=true;
else
  g_last_update_date_flag:=false;
end if;
if g_fact_audit or g_fact_net_change then
  l_stmt:='create table '||g_fact_audit_net_table||' tablespace '||g_op_table_space;
  --the table cannot be created in paralle mode because there is a sequence in the
  --select so paralle server complains. make select from this table parallel
  --the above is no more true since we are not inserting from a seq into this table now. the seq value is
  --already present in the op table
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||')';
  end if;
  l_stmt:=l_stmt||' as select ';
  if g_stg_join_nl then
    l_stmt:=l_stmt||' /*+ORDERED USE_NL('||g_fstgTableName||')*/ ';
  else
    l_stmt:=l_stmt||' /*+ORDERED*/ ';
  end if;
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+PARALLEL ('||g_fstgTableName||','||g_parallel||')*/  ';
  end if;
  if g_pk_key_seq is not null then
    l_stmt:=l_stmt||g_surr_table||'.'||g_fstgPKNameKey||' '||g_factPKNameKey||',';
  end if;
  for i in 1..g_num_ff_map_cols loop
    if i<>g_pk_key_seq_pos then
      if g_skip_item(i)=false then
        l_stmt:=l_stmt||g_fstg_mapping_columns(i)||' '||g_fact_mapping_columns(i)||',';
      end if;
    end if;
  end loop;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  --put the fks
  for i in 1..g_numberOfDimTables loop
    if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
      l_stmt:=l_stmt||','||g_surr_table||'.'||g_fstgActualFKName(i)||' '||g_factFKName(i);
    elsif g_fstg_fk_value_load(i)=true then
      l_stmt:=l_stmt||','||g_fstg_fk_load_value(i)||' '||g_factFKName(i);
    else
      l_stmt:=l_stmt||','||g_fstgTableName||'.'||g_fstgActualFKName(i)||' '||g_factFKName(i);
    end if;
  end loop;
else
  g_insert_stmt_ctas:='create table '||g_insert_ctas_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    g_insert_stmt_ctas:=g_insert_stmt_ctas||' parallel (degree '||g_parallel||')';
  end if;
  g_insert_stmt_ctas:=g_insert_stmt_ctas||'  as ';
  g_insert_stmt_row:=' insert into '||g_factTableName||'( ';
  l_stmt:=' insert ';
  if g_parallel is not null then
    if g_is_source=false and g_object_type='FACT' then
      l_stmt:=l_stmt||' /*+PARALLEL ('||g_factTableName||','||g_parallel||') */ ';
    end if;
  end if;
  l_stmt:=l_stmt||' into '||g_factTableName||'( ';
  if g_pk_key_seq is not null then
    l_stmt:=l_stmt||g_factPKNameKey||',';
    g_insert_stmt_row:=g_insert_stmt_row||g_factPKNameKey||',';
  end if;
  for i in 1..g_num_ff_map_cols loop
    if i<>g_pk_key_seq_pos then
      if g_skip_item(i)=false then
        l_stmt:=l_stmt||g_fact_mapping_columns(i)||',';
        g_insert_stmt_row:=g_insert_stmt_row||g_fact_mapping_columns(i)||',';
      end if;
    end if;
  end loop;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  g_insert_stmt_row:=substr(g_insert_stmt_row,1,length(g_insert_stmt_row)-1);
  --put the fks
  for i in 1..g_numberOfDimTables loop
   l_stmt:=l_stmt||','||g_factFKName(i)||' ';
   g_insert_stmt_row:=g_insert_stmt_row||','||g_factFKName(i)||' ';
  end loop;
  if g_creation_date_flag then
    l_stmt:=l_stmt||',CREATION_DATE ';
    g_insert_stmt_row:=g_insert_stmt_row||',CREATION_DATE ';
  end if;
  if g_last_update_date_flag then
    l_stmt:=l_stmt||',LAST_UPDATE_DATE ';
    g_insert_stmt_row:=g_insert_stmt_row||',LAST_UPDATE_DATE ';
  end if;
  l_stmt:=l_stmt||' ) select ';
  g_insert_stmt_row:=g_insert_stmt_row||' ) select ';
  if g_stg_join_nl then
    l_stmt:=l_stmt||' /*+ORDERED USE_NL('||g_fstgTableName||')*/ ';
    g_insert_stmt_ctas:=g_insert_stmt_ctas||' /*+ORDERED USE_NL('||g_fstgTableName||')*/ ';
  else
    l_stmt:=l_stmt||' /*+ORDERED*/ ';
    g_insert_stmt_ctas:=g_insert_stmt_ctas||' /*+ORDERED*/ ';
  end if;
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+PARALLEL ('||g_fstgTableName||','||g_parallel||')*/  ';
    g_insert_stmt_ctas:=g_insert_stmt_ctas||' /*+PARALLEL ('||g_fstgTableName||','||
    g_parallel||')*/  ';
  end if;
  if g_pk_key_seq is not null then
    l_stmt:=l_stmt||g_surr_table||'.'||g_fstgPKNameKey||',';
    g_insert_stmt_row:=g_insert_stmt_row||g_factPKNameKey||',';
    g_insert_stmt_ctas:=g_insert_stmt_ctas||g_surr_table||'.'||g_fstgPKNameKey||' '||g_factPKNameKey||',';
  end if;
  for i in 1..g_num_ff_map_cols loop
    if i<>g_pk_key_seq_pos then
      if g_skip_item(i)=false then
        l_stmt:=l_stmt||g_fstg_mapping_columns(i)||',';
        g_insert_stmt_row:=g_insert_stmt_row||g_fact_mapping_columns(i)||',';
        g_insert_stmt_ctas:=g_insert_stmt_ctas||g_fstg_mapping_columns(i)||' '||g_fact_mapping_columns(i)||',';
      end if;
    end if;
  end loop;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  g_insert_stmt_row:=substr(g_insert_stmt_row,1,length(g_insert_stmt_row)-1);
  g_insert_stmt_ctas:=substr(g_insert_stmt_ctas,1,length(g_insert_stmt_ctas)-1);
  --put the fks
  for i in 1..g_numberOfDimTables loop
    g_insert_stmt_row:=g_insert_stmt_row||','||g_factFKName(i)||' ';
    if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
      l_stmt:=l_stmt||','||g_surr_table||'.'||g_fstgActualFKName(i)||' ';
      g_insert_stmt_ctas:=g_insert_stmt_ctas||','||g_surr_table||'.'||g_fstgActualFKName(i)||' '||
      g_factFKName(i)||' ';
    elsif g_fstg_fk_value_load(i)=true then
      l_stmt:=l_stmt||','||g_fstg_fk_load_value(i)||' ';
      g_insert_stmt_ctas:=g_insert_stmt_ctas||','||g_fstg_fk_load_value(i)||' '||g_factFKName(i)||' ';
    else
      l_stmt:=l_stmt||','||g_fstgTableName||'.'||g_fstgActualFKName(i)||' ';
      g_insert_stmt_ctas:=g_insert_stmt_ctas||','||g_fstgTableName||'.'||g_fstgActualFKName(i)||' '||
      g_factFKName(i)||' ';
    end if;
  end loop;
  if g_creation_date_flag then
    l_stmt:=l_stmt||',SYSDATE ';
    g_insert_stmt_row:=g_insert_stmt_row||',SYSDATE ';
    g_insert_stmt_ctas:=g_insert_stmt_ctas||',SYSDATE CREATION_DATE ';
  end if;
  if g_last_update_date_flag then
    l_stmt:=l_stmt||',SYSDATE ';
    g_insert_stmt_row:=g_insert_stmt_row||',SYSDATE ';
    g_insert_stmt_ctas:=g_insert_stmt_ctas||',SYSDATE LAST_UPDATE_DATE ';
  end if;
end if;--if g_fact_audit or g_fact_net_change then
--op code of 0=insert 1=update and 2=delete
l_stmt:=l_stmt||' from '||g_surr_table||',';
g_insert_stmt_ctas:=g_insert_stmt_ctas||' from '||g_surr_table||',';
if g_stg_copy_table_flag then
  l_stmt:=l_stmt||g_stg_copy_table||' '||g_fstgTableName;
  l_stmt:=l_stmt||' where '||g_surr_table||'.operation_code=0 and '||
  g_fstgTableName||'.rowid='||g_surr_table||'.row_id_copy';
  g_insert_stmt_ctas:=g_insert_stmt_ctas||g_stg_copy_table||' '||g_fstgTableName;
  g_insert_stmt_ctas:=g_insert_stmt_ctas||' where '||g_surr_table||'.operation_code=0 and '||
  g_fstgTableName||'.rowid='||g_surr_table||'.row_id_copy';
elsif g_use_mti then
  l_stmt:=l_stmt||g_user_measure_table||' '||g_fstgTableName;
  l_stmt:=l_stmt||' where '||g_surr_table||'.operation_code=0 and '||
  g_fstgTableName||'.rowid='||g_surr_table||'.row_id_copy';
  g_insert_stmt_ctas:=g_insert_stmt_ctas||g_user_measure_table||' '||g_fstgTableName;
  g_insert_stmt_ctas:=g_insert_stmt_ctas||' where '||g_surr_table||'.operation_code=0 and '||
  g_fstgTableName||'.rowid='||g_surr_table||'.row_id_copy';
else
  l_stmt:=l_stmt||g_fstgTableName;
  l_stmt:=l_stmt||' where '||g_surr_table||'.operation_code=0 and '||
  g_fstgTableName||'.rowid='||g_surr_table||'.row_id';
  g_insert_stmt_ctas:=g_insert_stmt_ctas||g_fstgTableName;
  g_insert_stmt_ctas:=g_insert_stmt_ctas||' where '||g_surr_table||'.operation_code=0 and '||
  g_fstgTableName||'.rowid='||g_surr_table||'.row_id';
end if;
g_insert_stmt_row:=g_insert_stmt_row||' from '||g_insert_ctas_table||' where rowid=:a';
if g_groupby_on=true then
  l_stmt:=l_stmt||' group by ';
  g_insert_stmt_ctas:=g_insert_stmt_ctas||' group by ';
  if g_number_groupby_cols> 0 then
    for i in 1..g_number_groupby_cols loop
      l_stmt:=l_stmt||g_fstgTableName||'.'||g_groupby_cols(i)||',';
      g_insert_stmt_ctas:=g_insert_stmt_ctas||g_fstgTableName||'.'||g_groupby_cols(i)||',';
    end loop;
  end if;
  for i in 1..g_numberOfDimTables loop
    if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
      l_stmt:=l_stmt||g_surr_table||'.'||g_fstgActualFKName(i)||',';
      g_insert_stmt_ctas:=g_insert_stmt_ctas||g_surr_table||'.'||g_fstgActualFKName(i)||',';
    elsif g_fstg_fk_direct_load(i)=true then
      l_stmt:=l_stmt||g_fstgTableName||'.'||g_fstgActualFKName(i)||',';
      g_insert_stmt_ctas:=g_insert_stmt_ctas||g_fstgTableName||'.'||g_fstgActualFKName(i)||',';
    end if;
  end loop;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  g_insert_stmt_ctas:=substr(g_insert_stmt_ctas,1,length(g_insert_stmt_ctas)-1);
end if;
g_insert_stmt:=l_stmt;
if g_debug then
  write_to_log_file_n('Insert stmt '||g_insert_stmt);
end if;
if g_debug then
  write_to_log_file_n('Insert stmt row-by-row '||g_insert_stmt_row);
end if;
if g_fact_audit or g_fact_net_change then
  g_audit_net_insert_stmt_row:='insert into '||g_factTableName||'( ';
  if g_parallel is null then
    l_stmt:='insert into '||g_factTableName||'( ';
  else
    if g_is_source=false and g_object_type='FACT' then
      l_stmt:=' insert /*+PARALLEL ('||g_factTableName||','||g_parallel||') */ into '||
      g_factTableName||' ( ';
    else
      l_stmt:=' insert into '||g_factTableName||'( ';
    end if;
  end if;
  for i in 1..g_num_ff_map_cols loop
    if g_skip_item(i)=false then
      l_stmt:=l_stmt||g_fact_mapping_columns(i)||',';
      g_audit_net_insert_stmt_row:=g_audit_net_insert_stmt_row||g_fact_mapping_columns(i)||',';
    end if;
  end loop;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  g_audit_net_insert_stmt_row:=substr(g_audit_net_insert_stmt_row,1,length(g_audit_net_insert_stmt_row)-1);
  --put the fks
  for i in 1..g_numberOfDimTables loop
   l_stmt:=l_stmt||','||g_factFKName(i)||' ';
   g_audit_net_insert_stmt_row:=g_audit_net_insert_stmt_row||','||g_factFKName(i)||' ';
  end loop;
  if g_creation_date_flag then
    l_stmt:=l_stmt||',CREATION_DATE ';
    g_audit_net_insert_stmt_row:=g_audit_net_insert_stmt_row||',CREATION_DATE ';
  end if;
  if g_last_update_date_flag then
    l_stmt:=l_stmt||',LAST_UPDATE_DATE ';
    g_audit_net_insert_stmt_row:=g_audit_net_insert_stmt_row||',LAST_UPDATE_DATE ';
  end if;
  l_stmt:=l_stmt||' ) select ';
  g_audit_net_insert_stmt_row:=g_audit_net_insert_stmt_row||') select ';
  if g_parallel is not null then
    l_stmt:=l_stmt||'/*+PARALLEL('||g_fact_audit_net_table||','||g_parallel||')*/ ';
  end if;
  for i in 1..g_num_ff_map_cols loop
    if g_skip_item(i)=false then
      l_stmt:=l_stmt||g_fact_mapping_columns(i)||',';
      g_audit_net_insert_stmt_row:=g_audit_net_insert_stmt_row||g_fact_mapping_columns(i)||',';
    end if;
  end loop;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  g_audit_net_insert_stmt_row:=substr(g_audit_net_insert_stmt_row,1,length(g_audit_net_insert_stmt_row)-1);
  --put the fks
  for i in 1..g_numberOfDimTables loop
    l_stmt:=l_stmt||','||g_factFKName(i)||' ';
    g_audit_net_insert_stmt_row:=g_audit_net_insert_stmt_row||','||g_factFKName(i)||' ';
  end loop;
  if g_creation_date_flag then
    l_stmt:=l_stmt||',SYSDATE ';
    g_audit_net_insert_stmt_row:=g_audit_net_insert_stmt_row||',SYSDATE ';
  end if;
  if g_last_update_date_flag then
    l_stmt:=l_stmt||',SYSDATE ';
    g_audit_net_insert_stmt_row:=g_audit_net_insert_stmt_row||',SYSDATE ';
  end if;
  l_stmt:=l_stmt||' from '||g_fact_audit_net_table;
  g_audit_net_insert_stmt_row:=g_audit_net_insert_stmt_row||' from '||g_fact_audit_net_table||
  ' where rowid=:a';
  g_audit_net_insert_stmt:=l_stmt;
  if g_debug then
    write_to_log_file_n('g_audit_net_insert_stmt '||g_audit_net_insert_stmt);
  end if;
  if g_debug then
    write_to_log_file_n('g_audit_net_insert_stmt_row '||g_audit_net_insert_stmt_row);
  end if;
end if;
--UPDATE
if g_update_type='DELETE-INSERT' then
  --g_update_stmt:='insert /*+APPEND*/ into '||g_factTableName||'( ';
  --in append mode, snapshot logs dont get filed!!!
  if g_parallel is null then
    g_update_stmt:='insert into '||g_factTableName||'( ';
  else
    if g_is_source=false and g_object_type='FACT' then
      l_stmt:=' insert /*+PARALLEL ('||g_factTableName||','||g_parallel||') */ into '||
      g_factTableName||' ( ';
    else
      l_stmt:=' insert into '||g_factTableName||'( ';
    end if;
  end if;
  for i in 1..g_num_ff_map_cols loop
    if g_skip_item(i)=false then
      g_update_stmt:=g_update_stmt||g_fact_mapping_columns(i)||',';
    end if;
  end loop;
  for i in 1..g_numberOfDimTables loop
   g_update_stmt:=g_update_stmt||g_factFKName(i)||',';
  end loop;
  if g_creation_date_flag then
    g_update_stmt:=g_update_stmt||'CREATION_DATE,';
  end if;
  if g_last_update_date_flag then
    g_update_stmt:=g_update_stmt||'LAST_UPDATE_DATE,';
  end if;
  g_update_stmt:=substr(g_update_stmt,1,length(g_update_stmt)-1);
  g_update_stmt:=g_update_stmt||' )  select ';
  for i in 1..g_num_ff_map_cols loop
    if g_skip_item(i)=false then
      g_update_stmt:=g_update_stmt||g_fact_mapping_columns(i)||',';
    end if;
  end loop;
  for i in 1..g_numberOfDimTables loop
   g_update_stmt:=g_update_stmt||g_factFKName(i)||',';
  end loop;
  if g_creation_date_flag then
    g_update_stmt:=g_update_stmt||g_hold_table||'.CREATION_DATE,';
  end if;
  if g_last_update_date_flag then
    g_update_stmt:=g_update_stmt||'SYSDATE,';
  end if;
  g_update_stmt:=substr(g_update_stmt,1,length(g_update_stmt)-1);
  g_update_stmt:=g_update_stmt||' from '||g_hold_table;
else
  g_update_stmt_row:=' update '||g_factTableName||' set ( ';
  if g_update_type='ROW-BY-ROW' then
    g_update_stmt:=' update '||g_factTableName||' set ( ';
  elsif g_update_type='MASS' then
    g_update_stmt:=' update /*+ ORDERED USE_NL('||g_factTableName||')*/ ';
    if g_parallel is not null then
      if g_is_source=false and g_object_type='FACT' then
        g_update_stmt:=g_update_stmt||' /*+PARALLEL ('||g_factTableName||','||g_parallel||') */ ';
      end if;
    end if;
    g_update_stmt:=g_update_stmt||g_factTableName||' set ( ';
  end if;
  l_pk_index:=0;
  l_pk_key_index:=0;
  for i in 1..g_num_ff_map_cols loop
    if g_skip_item(i)=false then
      if g_fact_mapping_columns(i) <> g_factPKName and g_fact_mapping_columns(i) <> g_factPKNameKey then
        g_update_stmt:=g_update_stmt||g_fact_mapping_columns(i)||',';
        g_update_stmt_row:=g_update_stmt_row||g_fact_mapping_columns(i)||',';
      end if;
    end if;
  end loop;
  for i in 1..g_numberOfDimTables loop
   g_update_stmt:=g_update_stmt||g_factFKName(i)||',';
   g_update_stmt_row:=g_update_stmt_row||g_factFKName(i)||',';
  end loop;
  if g_last_update_date_flag then
    g_update_stmt:=g_update_stmt||' LAST_UPDATE_DATE ';
    g_update_stmt_row:=g_update_stmt_row||' LAST_UPDATE_DATE ';
  else
    g_update_stmt:=substr(g_update_stmt,1,length(g_update_stmt)-1);
    g_update_stmt_row:=substr(g_update_stmt_row,1,length(g_update_stmt_row)-1);
  end if;
  g_update_stmt:=g_update_stmt||')=( select ';
  g_update_stmt_row:=g_update_stmt_row||')=( select ';
  for i in 1..g_num_ff_map_cols loop
    if g_skip_item(i)=false then
      if g_fact_mapping_columns(i) <> g_factPKName and g_fact_mapping_columns(i) <> g_factPKNameKey then
        g_update_stmt:=g_update_stmt||g_fact_mapping_columns(i)||',';
        g_update_stmt_row:=g_update_stmt_row||g_fact_mapping_columns(i)||',';
      end if;
    end if;
  end loop;
  for i in 1..g_numberOfDimTables loop
   g_update_stmt:=g_update_stmt||g_factFKName(i)||',';
   g_update_stmt_row:=g_update_stmt_row||g_factFKName(i)||',';
  end loop;
  if g_last_update_date_flag then
    g_update_stmt:=g_update_stmt||' SYSDATE ';
    g_update_stmt_row:=g_update_stmt_row||' SYSDATE ';
  else
    g_update_stmt:=substr(g_update_stmt,1,length(g_update_stmt)-1);
    g_update_stmt_row:=substr(g_update_stmt_row,1,length(g_update_stmt_row)-1);
  end if;
  --g_update_stmt_row:=g_update_stmt;
  g_update_stmt_row:=g_update_stmt_row||' from '||g_hold_table||' where '||g_hold_table||'.row_id1=:a) where '||
      g_factTableName||'.rowid=:b';
  if g_update_type='ROW-BY-ROW' then
    g_update_stmt:=g_update_stmt||' from '||g_hold_table||' where '||g_hold_table||'.row_id1=:a) where '||
      g_factTableName||'.rowid=:b';
  elsif g_update_type='MASS' then
    g_update_stmt:=g_update_stmt||' from '||g_hold_table||' where '||g_factTableName||'.rowid='||
      g_hold_table||'.row_id1) where '||g_factTableName||'.rowid in (select row_id1 from '||g_hold_table||')';
  end if;
end if;
if g_debug then
  write_to_debug_n('Update  stmt '||g_update_stmt);
  write_to_debug_n('Update  stmt for ROW_BY_ROW is '||g_update_stmt_row);
end if;
--make the delete stmt
if g_update_type='ROW-BY-ROW' then
  g_delete_stmt :='delete '||g_factTableName||' where rowid=:a ';
elsif g_update_type='MASS' or g_update_type='DELETE-INSERT' then
  g_delete_stmt :='delete /*+ ORDERED USE_NL('||g_factTableName||')*/ '||
  g_factTableName||' where rowid in (select row_id1 from '||g_surr_table||' where operation_code=2 ';
  if g_load_type='INITIAL' then
    g_delete_stmt :=g_delete_stmt||'and row_id1<>''I'')';
  else
    g_delete_stmt :=g_delete_stmt||')';
  end if;
end if;
if g_debug then
  write_to_debug_n('Delete  stmt '||g_delete_stmt);
end if;
EXCEPTION when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
End;

/*
set the insert and update flags
*/
procedure set_execute_flags is
Begin
  g_insert_flag:=false;
  g_update_flag:=false;
  --op code of 0=insert 1=update and 2=delete
  if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_surr_table,'operation_code=0') = 2 then
    g_insert_flag:=true;
    if g_debug then
      write_to_log_file_n('Insert Needed');
    end if;
  else
    g_insert_flag:=false;
    if g_debug then
      write_to_log_file_n('NO Insert Needed');
    end if;
  end if;
  --op code of 0=insert 1=update and 2=delete
  if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_surr_table,'operation_code=1') = 2 then
    g_update_flag:=true;
    if g_debug then
      write_to_log_file_n('Update Needed');
    end if;
  else
    g_update_flag:=false;
    if g_debug then
      write_to_log_file_n('NO Update Needed');
    end if;
  end if;

  if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_surr_table,'operation_code=2') = 2 then
    g_delete_flag:=true;
    if g_debug then
      write_to_log_file_n('Delete Needed');
    end if;
  else
    g_delete_flag:=false;
    if g_debug then
      write_to_log_file_n('NO Delete Needed');
    end if;
  end if;

EXCEPTION when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
End;

function execute_duplicate_check return boolean is
l_status number;
Begin
  if g_debug then
    write_to_log_file_n('In execute_duplicate_check'||get_time);
  end if;
  l_status:=check_dup_err_rec;
  if l_status=0 then
    return false;
  elsif l_status=1 then
    write_to_log_file_n('No new records to check duplicates');
    return true;
  end if;
  if execute_dup_stmt=false then
    write_to_log_file_n('execute_dup_stmt returned with error');
    return false;
  end if;
  return true;
EXCEPTION when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function execute_dup_stmt return boolean is
l_status number;
l_dup_count number;
Begin
  if g_debug then
    write_to_log_file_n('In execute_dup_stmt'||get_time);
  end if;
  --move the real dup rows into
  if g_number_da_cols=0 then
    l_status:=move_dup_rowid_table;
  else
    l_status:=move_dup_rowid_table_general(g_da_cols,g_number_da_cols);
    if l_status= 0 then
      write_to_log_file_n('move_dup_rowid_table_general returned with error');
      return false;
    end if;
    if move_dup_pp_future=false then
      return false;
    end if;
  end if;
  if  l_status= 0 then
    write_to_log_file_n('move_dup_rowid_table returned with error');
    return false;
  elsif l_status=1 then --there are no duplicates
    if create_ok_table(1)=false then
      return false;
    end if;
    return true;
  end if;
  if create_ok_table(2)=false then
    return false;
  end if;
  --if g_duplicate_collect=false then
  l_dup_count:=execute_duplicate_stmt;
  if g_status=false then
    return false;
  end if;
  --end if;
  --l_dup_count:=get_number_of_duplicates;
  if g_temp_log then
    if g_duplicate_collect then --we need to say that duplicate-collect is collected
      if log_duplicate_records('DUPLICATE-COLLECT',l_dup_count) = false then
        write_to_log_file_n('log_duplicate_records returned with error');
      end if;
    else
      if log_duplicate_records('DUPLICATE',l_dup_count) = false then
        write_to_log_file_n('log_duplicate_records returned with error');
      end if;
    end if;
  end if;
  return true;
EXCEPTION when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function execute_duplicate_stmt return number is
Begin
  if g_debug then
    write_to_log_file_n('In execute_duplicate_stmt'||get_time);
  end if;
  if g_max_threads>1 and (g_dup_multi_thread_flag is not null and g_dup_multi_thread_flag) then
    return execute_duplicate_stmt_multi;
  else
    return execute_duplicate_stmt_single;
  end if;
EXCEPTION when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;

function execute_duplicate_stmt_multi return number is
l_count number;
l_total_count number;
l_status varchar2(40);
l_num_threads number;
l_ok_low_end EDW_OWB_COLLECTION_UTIL.numberTableType;
l_ok_high_end EDW_OWB_COLLECTION_UTIL.numberTableType;
l_ok_end_count number;
l_dup_hold_table varchar2(80);
l_job_id EDW_OWB_COLLECTION_UTIL.numberTableType;
l_number_jobs number;
l_debug varchar2(10);
l_duplicate_collect  varchar2(10);
l_low_system_mem varchar2(10);
l_status_table EDW_OWB_COLLECTION_UTIL.varcharTableType;
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_rollback varchar2(80);
l_parallel number;
--------------------------------
l_temp_conc_name varchar2(200);
l_temp_conc_short_name varchar2(200);
l_temp_exe_name varchar2(200);
l_bis_short_name varchar2(200);
l_try_serial boolean;
--------------------------------
l_errbuf varchar2(2000);
l_retcode varchar2(200);
-----------------------------------------
Begin
  if g_debug then
    write_to_log_file_n('In execute_duplicate_stmt_multi '||get_time);
  end if;
  l_ok_end_count:=0;
  if EDW_OWB_COLLECTION_UTIL.find_ok_distribution(
    g_dup_hold_table,
    g_bis_owner,
    g_max_threads,
    g_min_job_load_size,
    l_ok_low_end,
    l_ok_high_end,
    l_ok_end_count)=false then
    return execute_duplicate_stmt_single;
  end if;
  if l_ok_end_count>1 then
    l_number_jobs:=0;
    l_dup_hold_table:=g_dup_hold_table||'_N';
    if EDW_OWB_COLLECTION_UTIL.put_rownum_in_ilog_table(
      l_dup_hold_table,
      g_dup_hold_table,
      g_op_table_space,
      g_parallel)=false then
      return execute_duplicate_stmt_single;
    end if;
    l_debug:='N';
    l_duplicate_collect:='N';
    l_low_system_mem:='N';
    if g_debug then
      l_debug:='Y';
    end if;
    if g_duplicate_collect then
      l_duplicate_collect:='Y';
    end if;
    if g_low_system_mem then
      l_low_system_mem:='Y';
    end if;
    l_rollback:=g_rollback;
    if l_rollback is null then
      l_rollback:='null';
    end if;
    l_parallel:=g_parallel;
    if l_parallel is null then
      l_parallel:=0;
    end if;
    l_temp_conc_name:='Sub-Proc Dup-'||g_primary_target;
    l_temp_conc_short_name:='CONC_DUP_'||g_primary_target||'_CONC';
    l_temp_exe_name:=l_temp_conc_name||'_EXE';
    l_bis_short_name:='BIS';
    if g_thread_type='CONC' then
      --create the executable, conc program etc
      if create_conc_program_dup(l_temp_conc_name,l_temp_conc_short_name,l_temp_exe_name,l_bis_short_name)=false then
        if g_debug then
          write_to_log_file_n('Could not create seed data for conc programs. Trying jobs');
        end if;
        g_thread_type:='JOB';
      end if;
    end if;
    for i in 1..l_ok_end_count loop
      l_number_jobs:=l_number_jobs+1;
      l_status_table(l_number_jobs):=l_dup_hold_table||'_'||l_number_jobs||'_STS';
      if g_debug then
        write_to_log_file_n('EDW_MAPPING_COLLECT.execute_duplicate_stmt_multi('''||
        g_object_name||''','||''''||g_primary_target_name||''','''||g_fstgTableName||''','||l_number_jobs||','||
        l_ok_low_end(i)||','||l_ok_high_end(i)||','''||l_dup_hold_table||''','''||l_debug||''','''||
        g_bis_owner||''','''||g_op_table_space||''','||l_parallel||','''||l_duplicate_collect||''','''||
        g_update_type||''','''||l_low_system_mem||''','''||l_rollback||''','''||l_status_table(l_number_jobs)||''');');
      end if;
      begin
        l_try_serial:=false;
        if g_thread_type='CONC' then
          l_job_id(l_number_jobs):=FND_REQUEST.SUBMIT_REQUEST(
          application=>l_bis_short_name,
          program=>l_temp_conc_short_name,
          argument1=>g_object_name,
          argument2=>g_primary_target_name,
          argument3=>g_fstgTableName,
          argument4=>l_number_jobs,
          argument5=>l_ok_low_end(i),
          argument6=>l_ok_high_end(i),
          argument7=>l_dup_hold_table,
          argument8=>l_debug,
          argument9=>g_bis_owner,
          argument10=>g_op_table_space,
          argument11=>l_parallel,
          argument12=>l_duplicate_collect,
          argument13=>g_update_type,
          argument14=>l_low_system_mem,
          argument15=>l_rollback,
          argument16=>l_status_table(l_number_jobs));
          commit;
          if g_debug then
            write_to_log_file_n('Concurrent Request '||l_job_id(l_number_jobs)||' launched '||get_time);
          end if;
          if l_job_id(l_number_jobs)<=0 then
            l_try_serial:=true;
          end if;
        else
          DBMS_JOB.SUBMIT(l_job_id(l_number_jobs),'EDW_MAPPING_COLLECT.execute_duplicate_stmt_multi('''||
          g_object_name||''','||''''||g_primary_target_name||''','''||g_fstgTableName||''','||l_number_jobs||','||
          l_ok_low_end(i)||','||l_ok_high_end(i)||','''||l_dup_hold_table||''','''||l_debug||''','''||
          g_bis_owner||''','''||g_op_table_space||''','||l_parallel||','''||l_duplicate_collect||''','''||
          g_update_type||''','''||l_low_system_mem||''','''||l_rollback||''','''||l_status_table(l_number_jobs)||''');');
          commit;
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
        EDW_MAPPING_COLLECT.execute_duplicate_stmt_multi(
        l_errbuf,
        l_retcode,
        g_object_name,
        g_primary_target_name,
        g_fstgTableName,
        l_number_jobs,
        l_ok_low_end(i),
        l_ok_high_end(i),
        l_dup_hold_table,
        l_debug,
        g_bis_owner,
        g_op_table_space,
        l_parallel,
        l_duplicate_collect,
        g_update_type,
        l_low_system_mem,
        l_rollback,
        l_status_table(l_number_jobs)
        );
      end if;
    end loop;
    if EDW_OWB_COLLECTION_UTIL.wait_on_jobs(
      l_job_id,
      l_number_jobs,
      g_sleep_time,
      g_thread_type)=false then
      g_status_message:=EDW_OWB_COLLECTION_UTIL.get_status_message;
      g_status:=false;
    end if;
    --check the job status
    l_total_count:=0;
    for i in 1..l_number_jobs loop
      l_count:=0;
      g_stmt:='select status,count from '||l_status_table(i);
      open cv for g_stmt;
      fetch cv into l_status,l_count;
      close cv;
      l_total_count:=l_total_count+l_count;
      if l_status='ERROR' then
        g_status:=false;
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_status_table(i))=false then
        null;
      end if;
    end loop;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_hold_table)=false then
      null;
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
  else
    return execute_duplicate_stmt_single;
  end if;
  return l_total_count;
EXCEPTION when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;

--this is called from function execute_duplicate_stmt_multi for multi threading
procedure execute_duplicate_stmt_multi(
errbuf out nocopy varchar2,
retcode out nocopy varchar2,
p_object_name varchar2,
p_primary_target_name varchar2,
p_fstgTableName varchar2,
p_job_id number,
p_low_end number,
p_high_end number,
p_dup_hold_table varchar2,
p_debug varchar2,
p_bis_owner varchar2,
p_op_table_space varchar2,
p_parallel number,
p_duplicate_collect varchar2,
p_update_type varchar2,
p_low_system_mem varchar2,
p_rollback varchar2,
p_status_table varchar2
) is
Begin
  retcode:='0';
  execute_duplicate_stmt_multi(
  p_object_name,
  p_primary_target_name,
  p_fstgTableName,
  p_job_id,
  p_low_end,
  p_high_end,
  p_dup_hold_table,
  p_debug,
  p_bis_owner,
  p_op_table_space,
  p_parallel,
  p_duplicate_collect,
  p_update_type,
  p_low_system_mem,
  p_rollback,
  p_status_table);
  if g_status=false then
    retcode:='2';
    errbuf:=g_status_message;
  end if;
Exception when others then
  errbuf:=sqlerrm;
  retcode:='2';
  write_to_log_file_n('Exception in execute_duplicate_stmt_multi '||sqlerrm||get_time);
End;
--this is called from function execute_duplicate_stmt_multi for multi threading
procedure execute_duplicate_stmt_multi(
p_object_name varchar2,
p_primary_target_name varchar2,
p_fstgTableName varchar2,
p_job_id number,
p_low_end number,
p_high_end number,
p_dup_hold_table varchar2,
p_debug varchar2,
p_bis_owner varchar2,
p_op_table_space varchar2,
p_parallel number,
p_duplicate_collect varchar2,
p_update_type varchar2,
p_low_system_mem varchar2,
p_rollback varchar2,
p_status_table varchar2
) is
l_file_name varchar2(200);
l_dup_hold_table varchar2(200);
l_count number;
Begin
  l_file_name:='DUP_'||p_primary_target_name||'_'||p_job_id;
  l_dup_hold_table:=p_dup_hold_table||'_'||p_job_id;
  EDW_OWB_COLLECTION_UTIL.init_all(l_file_name,null,'bis.edw.loader');
  g_debug:=false;
  if p_debug='Y' then
    g_debug:=true;
  end if;
  g_duplicate_collect:=false;
  if p_duplicate_collect='Y' then
    g_duplicate_collect:=true;
  end if;
  g_low_system_mem:=false;
  if p_low_system_mem='Y' then
    g_low_system_mem:=true;
  end if;
  if p_parallel=0 then
    g_parallel:=null;
  else
    g_parallel:=p_parallel;
  end if;
  if p_rollback='null' then
    g_rollback:=null;
  else
    g_rollback:=p_rollback;
  end if;
  EDW_OWB_COLLECTION_UTIL.set_debug(g_debug);
  EDW_OWB_COLLECTION_UTIL.set_parallel(g_parallel);
  if g_parallel>1 then
    EDW_OWB_COLLECTION_UTIL.alter_session('PARALLEL');
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_status_table)=false then
    null;
  end if;
  if g_debug then
    edw_owb_collection_util.dump_mem_stats;
    edw_owb_collection_util.dump_parallel_stats;
    write_to_log_file_n('In execute_duplicate_stmt_multi for jobs '||p_object_name||' '||
    p_primary_target_name||' '||l_dup_hold_table);
  end if;
  --4161164 : remove IOT , replace with ordinary table and index
  --g_stmt:='create table '||l_dup_hold_table||'(row_id primary key) organization index '||
  g_stmt:='create table '||l_dup_hold_table||
  ' tablespace '||p_op_table_space;
  if g_parallel is not null then
    g_stmt:=g_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  g_stmt:=g_stmt||' as select row_id from '||p_dup_hold_table||' where row_num between '||p_low_end||' and '||
  p_high_end;
  if g_debug then
    write_to_log_file_n(g_stmt||get_time);
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_hold_table)=false then
    null;
  end if;
  execute immediate g_stmt;
  if g_debug then
    write_to_log_file_n('Created '||get_time);
  end if;
  --4161164 : remove IOT , replace with ordinary table and index
  EDW_OWB_COLLECTION_UTIL.create_iot_index(l_dup_hold_table,'row_id',p_op_table_space,g_parallel);
  l_count:=execute_duplicate_stmt_single(
  g_duplicate_collect,
  p_update_type,
  g_low_system_mem,
  p_fstgTableName,
  l_dup_hold_table,
  g_rollback);
  if g_debug then
    edw_owb_collection_util.dump_mem_stats;
    edw_owb_collection_util.dump_parallel_stats;
  end if;
  if g_status=false then
    --process error
    EDW_OWB_COLLECTION_UTIL.create_status_table(p_status_table,p_op_table_space,'ERROR',l_count);
  else
    EDW_OWB_COLLECTION_UTIL.create_status_table(p_status_table,p_op_table_space,'OK',l_count);
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_hold_table)=false then
      null;
    end if;
  end if;
EXCEPTION when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
End;

function execute_duplicate_stmt_single return number is
Begin
  if g_debug then
    write_to_log_file_n('In execute_duplicate_stmt_single'||get_time);
  end if;
  return execute_duplicate_stmt_single(
  g_duplicate_collect,
  g_update_type,
  g_low_system_mem,
  g_fstgTableName,
  g_dup_hold_table,
  g_rollback);
EXCEPTION when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;

function execute_duplicate_stmt_single(
p_duplicate_collect boolean,
p_update_type varchar2,
p_low_system_mem boolean,
p_fstgTableName varchar2,
p_dup_hold_table varchar2,
p_rollback varchar2
) return number is
l_stmt varchar2(5000);
l_count number;
l_status varchar2(400);
l_update_type varchar2(400);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_rowid rowid;
l_total_count number:=0;
l_stmt1 varchar2(5000);
Begin
  if g_debug then
    write_to_log_file_n('In execute_duplicate_stmt_single (with params)'||get_time);
  end if;
  if p_duplicate_collect then
    l_status:='DUPLICATE-COLLECT';
  else
    l_status:='DUPLICATE';
  end if;
  l_update_type:=p_update_type;
  if p_low_system_mem=true then
    l_update_type:='ROW-BY-ROW';
  end if;
  if l_update_type='MASS' or l_update_type='DELETE-INSERT' then
    l_stmt:='update /*+ORDERED USE_NL('||p_fstgTableName||')*/ ';
    if g_parallel is not null then
      l_stmt:=l_stmt||' /*+PARALLEL('||p_fstgTableName||','||g_parallel||')*/ ';
    end if;
    l_stmt:=l_stmt||p_fstgTableName||' set collection_status=:a where rowid in (select row_id from '||
    p_dup_hold_table||') ';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||' using '||l_status||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.set_rollback(p_rollback);
    execute immediate l_stmt using l_status;
    l_count:=sql%rowcount;
    commit;
    if g_debug then
      write_to_log_file_n('Executed duplicate marking for '||l_count||' records'||get_time);
      write_to_log_file('commit');
    end if;
  elsif l_update_type='ROW-BY-ROW' then
    l_stmt:='update '||p_fstgTableName||' set collection_status=:b where rowid=:a';
    l_stmt1:='select row_id from '||p_dup_hold_table;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt1||get_time);
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    open cv for l_stmt1;
    loop
      fetch cv into l_rowid;
      exit when cv%notfound;
      execute immediate l_stmt using l_status,l_rowid;
      l_total_count:=l_total_count+1;
    end loop;
    close cv;
    commit;
    if g_debug then
      write_to_log_file('Updated '||l_total_count||' rows in '||p_fstgTableName||' to '||l_status||get_time);
    end if;
  end if;
  return l_count;
EXCEPTION when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;

function execute_surr_insert return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In execute_surr_insert'||get_time);
  end if;
  if g_use_mti=false then --if true, insert_fm_ff_table will populate g_user_fk_table
    if g_user_fk_table <> g_fstgTableName then
      if create_user_fk_table=false then
        return false;
      end if;
    end if;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_surr_table)=false then
    null;
  end if;
  g_surr_table:=g_surr_table_name;
  if g_numberOfDimTables>0 or g_mapping_type='FACT' then --always use this
    if g_fstg_all_fk_direct_load=false then
      if create_surr_tables=false then
        return false;
      end if;
      --then create the surr table itself
      if g_surr_table_LHJM then
        if create_main_surr_table_LHJM=false then
          return false;
        end if;
      else
        if create_main_surr_table=false then
          return false;
        end if;
      end if;
    else
      --no need to even look at creating the individual surr tables
      if g_surr_table_LHJM then
        if create_main_surr_table_LHJM=false then
          return false;
        end if;
      else
        if create_main_surr_table=false then
          return false;
        end if;
      end if;
    end if;--if g_fstg_all_fk_direct_load=false then
  else --consider all fks at one time
    begin
      if EDW_OWB_COLLECTION_UTIL.drop_table(g_surr_table)=false then
        null;
      end if;
      if g_debug then
        write_to_log_file_n('Going to execute g_surrogate_stmt');
        write_to_log_file('Time='||get_time);
      end if;
      execute immediate g_surrogate_stmt; --this is create table as select
      g_surr_count:=sql%rowcount;
      if g_debug then
        write_to_log_file_n('Created '||g_surr_table||' with '||g_surr_count||' rows');
        write_to_log_file('Time='||get_time);
      end if;
    exception when others then
      g_status:=false;
      g_status_message:=sqlerrm;
      write_to_log_file_n(g_status_message);
      return false;
    end;
  end if;
  --make the indexes on g_surr_table
  if create_index_surr_table = false then
    write_to_log_file_n('create_index_surr_table returned with error');
    return false;
  end if;
  --analyze the table
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_surr_table,instr(g_surr_table,'.')+1,
  length(g_surr_table)),substr(g_surr_table,1,instr(g_surr_table,'.')-1));
  set_execute_flags; --is there insert and or update
  if g_status =false then
    write_to_log_file_n('set_execute_flags returned with error');
    return false;
  end if;
  if g_debug then
    if report_collection_status = false then
      write_to_log_file_n('Could not report the count and collection status. Not Fatal');
    end if;
  end if;
  return true;
EXCEPTION when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

/*
to boost the performance of the updates
*/
function create_hd_table(p_count number) return boolean is
l_stmt varchar2(32000);
l_table varchar2(400);
l_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_cols_datatype EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_cols_flag EDW_OWB_COLLECTION_UTIL.booleanTableType;
l_number_cols number;
l_itemset_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_itemset_cols number;
l_divide number;
l_extent number;
--
--
Begin
  if g_debug then
    write_to_log_file_n('In create_hd_table p_count='||p_count||get_time);
  end if;
  if g_smart_update then
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_hold_table_temp) = false then
      null;
    end if;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_hold_table) = false then
    null;
  end if;
  begin
    if g_debug then
      write_to_log_file_n('Going to execute g_hd_insert_stmt'||get_time);
    end if;
    execute immediate g_hd_insert_stmt;
    g_hold_table_count:=sql%rowcount;
    if g_debug then
      write_to_log_file_n('Created with '||g_hold_table_count||' rows'||get_time);
    end if;
  exception when others then
    g_status:=false;
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message);
    write_to_log_file('Problem stmt '||g_hd_insert_stmt);
    return false;
  end;
  if g_smart_update then
    l_number_itemset_cols:=g_number_smart_update_cols;
    l_itemset_cols:=g_smart_update_cols;
    l_table:=substr(g_hold_table_temp,instr(g_hold_table_temp,'.')+1,length(g_hold_table_temp));
    if EDW_OWB_COLLECTION_UTIL.get_db_columns_for_table(l_table,l_cols,l_cols_datatype,l_number_cols,
      g_bis_owner)=false then
      g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
      g_status:=false;
      return false;
    end if;
    if g_debug then
      write_to_log_file_n('The columns of '||g_hold_table_temp);
      for i in 1..l_number_cols loop
        write_to_log_file(l_cols(i)||'('||l_cols_datatype(i)||')');
      end loop;
    end if;
    for i in 1..l_number_cols loop
      l_cols_flag(i):=true;
      if not(l_cols_datatype(i) like '%CHAR%' or l_cols_datatype(i) ='NUMBER'
        or l_cols_datatype(i) ='LONG' or l_cols_datatype(i) ='DATE' or
        l_cols_datatype(i) ='RAW' or l_cols_datatype(i) ='LONG RAW') then
        l_cols_flag(i):=false;
      end if;
    end loop;
    if l_number_itemset_cols=0 then
      for i in 1..l_number_cols loop
        if l_cols_flag(i) then
          if l_cols(i)<>'LAST_UPDATE_DATE' and l_cols(i)<>'CREATION_DATE' and l_cols(i)<>'ROW_ID1' then
            l_cols_flag(i):=true;
          else
            l_cols_flag(i):=false;
          end if;
        end if;
      end loop;
    else
      for i in 1..l_number_cols loop
        if l_cols_flag(i) then
          if EDW_OWB_COLLECTION_UTIL.value_in_table(l_itemset_cols,l_number_itemset_cols,l_cols(i)) then
            if l_cols(i)<>'LAST_UPDATE_DATE' and l_cols(i)<>'CREATION_DATE' and l_cols(i)<>'ROW_ID1' then
              l_cols_flag(i):=true;
            else
              l_cols_flag(i):=false;
            end if;
          else
            l_cols_flag(i):=false;
          end if;
        end if;
      end loop;
    end if;
    if g_debug then
      write_to_log_file_n('The columns of '||g_hold_table_temp||' that are to be considered');
      for i in 1..l_number_cols loop
        if l_cols_flag(i) then
          write_to_log_file(l_cols(i)||'('||l_cols_datatype(i)||')');
        end if;
      end loop;
    end if;
    l_stmt:='create table '||g_hold_table||' tablespace '||g_op_table_space;
    if g_fact_next_extent is not null then
      if g_parallel is null then
        l_divide:=2;
      else
        l_divide:=g_parallel;
      end if;
      l_extent:=g_fact_next_extent/l_divide;
      if l_extent>16777216 then --16M
        l_extent:=16777216;
      end if;
      if l_extent is null or l_extent=0 then
        l_extent:=8388608;
      end if;
      l_stmt:=l_stmt||' storage(initial '||l_extent||' next '||
      l_extent||' pctincrease 0 MAXEXTENTS 2147483645) ';
    end if;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    if g_fact_use_nl then --g_fact_use_nl is set in create_opcode_...
      l_stmt:=l_stmt||'  as select /*+ordered use_nl('||g_factTableName||')*/ ';
    else
      l_stmt:=l_stmt||'  as select /*+ordered*/ ';
    end if;
    if g_parallel is not null then
      l_stmt:=l_stmt||' /*+parallel('||g_factTableName||','||g_parallel||')*/ ';
    end if;
    l_stmt:=l_stmt||g_hold_table_temp||'.* from '||g_hold_table_temp||','||g_factTableName||' where '||
    g_hold_table_temp||'.row_id1='||g_factTableName||'.rowid and NOT( ';
    for i in 1..l_number_cols loop
      if l_cols_flag(i) then
        if l_cols_datatype(i)='DATE' then
          l_stmt:=l_stmt||'nvl('||g_hold_table_temp||'.'||l_cols(i)||',sysdate)=nvl('||
          g_factTableName||'.'||l_cols(i)||',sysdate) and ';
        else
          l_stmt:=l_stmt||'nvl('||g_hold_table_temp||'.'||l_cols(i)||',0)=nvl('||
          g_factTableName||'.'||l_cols(i)||',0) and ';
        end if;
      end if;
    end loop;
    l_stmt:=substr(l_stmt,1,length(l_stmt)-4);
    l_stmt:=l_stmt||')';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;--create hold table
    g_hold_table_count:=sql%rowcount;
    if g_debug then
      write_to_log_file_n('Created with '||g_hold_table_count||' rows '||get_time);
    end if;
  end if;
  --create the unique index on row_id1
  l_stmt:='create unique index '||g_hold_table||'u1 on '||g_hold_table||'(row_id1) '||
  ' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel '||g_parallel;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created index on '||g_hold_table);
  end if;
  if g_smart_update then
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_hold_table_temp) = false then
      null;
    end if;
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_hold_table,instr(g_hold_table,'.')+1,
  length(g_hold_table)),substr(g_hold_table,1,instr(g_hold_table,'.')-1));
  if g_parallel_drill_down and g_temp_log=false then
    --g_temp_log=false means this is not the lowest level
    l_table:=g_bis_owner||'.TAB_'||g_primary_target||'_HDUR_'||g_job_id||'_'||p_count;
    l_stmt:='create table '||l_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||' as select row_id1 row_id from '||g_hold_table;
    if edw_owb_collection_util.drop_table(l_table)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n(l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created with '||sql%rowcount||' rows'||get_time);
    end if;
  end if;
  return true;
EXCEPTION when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  write_to_log_file('Problem stmt '||l_stmt);
  return false;
End;

function execute_update_stmt return number is
l_stmt varchar2(10000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_count number;
l_rowid EDW_OWB_COLLECTION_UTIL.rowidTableType;
l_total_update number:=0;
l_update_type varchar2(400);
l_hold_table varchar2(400);
Begin
  if g_debug then
    write_to_log_file_n('In execute_update_stmt'||get_time);
  end if;
  l_update_type:=g_update_type;
  if g_low_system_mem=true then
    l_update_type:='ROW-BY-ROW';
  end if;
  l_hold_table:=g_hold_table||'A';

  <<start_update>>

  if l_update_type='ROW-BY-ROW' then
    l_stmt:='create table '||l_hold_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  as select row_id1 from '||g_hold_table;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_hold_table)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created '||l_hold_table||' with '||sql%rowcount||' rows '||get_time);
    end if;
    l_stmt:='select row_id1 from '||l_hold_table;
    open cv for l_stmt;
    l_count:=1;
    loop
      fetch cv into l_rowid(l_count);
      exit when cv%notfound;
      if l_count>=g_forall_size then
        for i in 1..l_count loop
          execute immediate g_update_stmt_row using l_rowid(i),l_rowid(i);
        end loop;
        l_total_update:=l_total_update+l_count;
        l_count:=1;
        commit;
      else
        l_count:=l_count+1;
      end if;
    end loop;
    l_count:=l_count-1;
    if l_count>0 then
      for i in 1..l_count loop
        execute immediate g_update_stmt_row using l_rowid(i),l_rowid(i);
      end loop;
      l_total_update:=l_total_update+l_count;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_hold_table)=false then
      null;
    end if;
  elsif l_update_type='MASS' then
    begin
      EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
      execute immediate g_update_stmt;
      l_total_update:=sql%rowcount;
    exception when others then
      if sqlcode=-4030 then
        commit;
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
      end if;
      g_status:=false;
      g_status_message:=sqlerrm;
      write_to_log_file_n(g_status_message);
      write_to_log_file('Problem stmt '||g_update_stmt);
      return null;
    end;
  elsif l_update_type='DELETE-INSERT' then
    --first delete
    l_stmt:='delete '||g_factTableName||' where exists (select 1 from '||g_hold_table||' where '||
      g_hold_table||'.row_id1='||g_factTableName||'.rowid)';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    begin
      EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Deleted '||sql%rowcount||' rows'||get_time);
      end if;
    exception when others then
      g_status:=false;
      g_status_message:=sqlerrm;
      write_to_log_file_n(g_status_message);
      write_to_log_file('Problem stmt '||l_stmt);
      return null;
    end ;
    begin
      if g_debug then
        write_to_log_file_n('Going to execute g_update_stmt'||get_time);
      end if;
      EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
      execute immediate g_update_stmt;
      l_total_update:=sql%rowcount;
    exception when others then
      g_status:=false;
      g_status_message:=sqlerrm;
      write_to_log_file_n(g_status_message);
      write_to_log_file('Problem stmt '||g_update_stmt);
      return null;
    end ;
  end if;
  commit;
  if g_debug then
    write_to_log_file_n('Updated '||l_total_update||' records'||get_time);
    write_to_log_file('commit');
  end if;
  return l_total_update;
EXCEPTION when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;

function execute_delete_stmt return number is
l_stmt varchar2(10000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_count number;
l_rowid EDW_OWB_COLLECTION_UTIL.rowidTableType;
l_total_delete number:=0;
Begin
  if g_debug then
    write_to_log_file_n('In execute_delete_stmt'||get_time);
  end if;
  if g_update_type='ROW-BY-ROW' then
    l_stmt:='select row_id1 from '||g_surr_table||' where operation_code=2';
    open cv for l_stmt;
    l_count:=1;
    loop
      fetch cv into l_rowid(l_count);
      exit when cv%notfound;
      if l_count>=g_forall_size then
        for i in 1..l_count loop
          execute immediate g_delete_stmt using l_rowid(i);
        end loop;
        l_total_delete:=l_total_delete+l_count;
        l_count:=1;
        commit;
      else
        l_count:=l_count+1;
      end if;
    end loop;
    l_count:=l_count-1;
    if l_count>0 then
      for i in 1..l_count loop
        execute immediate g_delete_stmt using l_rowid(i);
      end loop;
      l_total_delete:=l_total_delete+l_count;
    end if;
  elsif g_update_type='MASS' or g_update_type='DELETE-INSERT' then
    begin
      --create a rowid table here and use that for deletes
      EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
      execute immediate g_delete_stmt;
      l_total_delete:=sql%rowcount;
    exception when others then
      g_status:=false;
      g_status_message:=sqlerrm;
      write_to_log_file_n(g_status_message);
      write_to_log_file('Problem stmt '||g_delete_stmt);
      return null;
    end;
  end if;
  commit;
  if g_debug then
    write_to_log_file_n('Deleted '||l_total_delete||' records'||get_time);
    write_to_log_file('commit');
  end if;
  return l_total_delete;
EXCEPTION when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;

function execute_fa_nc_insert(p_flag varchar2) return boolean is
Begin
  if p_flag='INSERT' then
    --here, if there is fact audit or net change, insert into those tables
    if g_fact_audit then
      if insert_fa_fact_insert=false then
        return false;
      end if;
    end if;
    if g_fact_net_change then
      if insert_nc_fact_insert=false then
        return false;
      end if;
    end if;
    --g_fact_audit_net_table is dropped here for error recovery
    if g_fact_audit or g_fact_net_change then
      if EDW_OWB_COLLECTION_UTIL.drop_table(g_fact_audit_net_table)=false then
        null;
      end if;
    end if;
  end if;
  if p_flag='UPDATE' then
    if g_fact_audit then
      if insert_fa_fact_update = false then
        return false;
      end if;
    end if;
    if g_fact_net_change then
      if insert_nc_fact_update = false then
        return false;
      end if;
    end if;
  end if;
  return true;
EXCEPTION when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function execute_insert_update_delete(p_count number) return boolean is
l_count number;
l_is_source boolean:=false;
Begin
  if g_debug then
    write_to_log_file_n('In execute_insert_update_delete'||get_time);
  end if;
  g_number_rows_processed:=0;
  if g_insert_flag then
    if execute_insert_stmt(p_count)=false then
      return false;
    end if;
  end if;
  if g_update_flag and g_skip_update=false then
    --create the hold table on the fly insert into it all the values
    insert_into_load_progress_d(g_load_pk,g_primary_target_name,g_jobid_stmt||'Create Hold Table',sysdate,
    null,'MAPPING','CREATE-TABLE',g_jobid_stmt||'CHT'||p_count,'I');
    if create_hd_table(p_count) = false then
      write_to_log_file_n('create_hd_table returned with false');
      insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'CHT'||p_count,'U');
      return false;
    end if;
    insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'CHT'||p_count,'U');
    if g_hold_table_count>0 then
      --if this is a fact and its a source for a derived fact, we first need to insert the FACT rows
      --into the dlog table
      if g_mapping_type='FACT' then
        if g_is_source=true or g_is_custom_source=true then
          insert_into_load_progress_d(g_load_pk,g_primary_target_name,g_jobid_stmt||'Move Update data into dlog ',sysdate,
          null,'MAPPING','INSERT',g_jobid_stmt||'MUDL'||p_count,'I');
          if excecute_data_into_dlog('UPDATE') = false then
            write_to_log_file_n('excecute_data_into_dlog returned with error');
            insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'MUDL'||p_count,'U');
            return false;
          end if;
          insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'MUDL'||p_count,'U');
        end if;
      end if;
      if g_fact_audit or g_fact_net_change then
        insert_into_load_progress_d(g_load_pk,g_primary_target_name,g_jobid_stmt||'Process Audit or Netchange Records',sysdate,
        null,'MAPPING','UPDATE',g_jobid_stmt||'PANU'||p_count,'I');
        if execute_fa_nc_insert('UPDATE') = false then
          insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'PANU'||p_count,'U');
          return false;
        end if;
        insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'PANU'||p_count,'U');
      end if;
      insert_into_load_progress_d(g_load_pk,g_primary_target_name,g_jobid_stmt||'Update '||g_primary_target_name,sysdate,
      null,'MAPPING','UPDATE',g_jobid_stmt||'UPDATE'||p_count,'I');
      if g_parallel is null then
        EDW_OWB_COLLECTION_UTIL.alter_session('NO-PARALLEL');
      else
        if g_is_source=false and g_object_type='FACT' then
          if edw_owb_collection_util.is_source_for_fast_refresh_mv(g_primary_target_name,g_table_owner)=1 then
            --3529591
            EDW_OWB_COLLECTION_UTIL.alter_session('NO-PARALLEL');
          else
            null;
          end if;
        else
          EDW_OWB_COLLECTION_UTIL.alter_session('NO-PARALLEL');
        end if;
      end if;
      l_count:=execute_update_stmt;
      g_total_update:=l_count;
      if l_count is null then
        return false;
      end if;
      if g_parallel is not null then
        EDW_OWB_COLLECTION_UTIL.alter_session('PARALLEL');
      end if;
      insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'UPDATE'||p_count,'U');
      g_number_rows_processed:=g_number_rows_processed+l_count;
    else
      g_total_update:=0;
      if g_debug then
        write_to_log_file_n('No change to update');
      end if;
    end if;--if g_hold_table_count>0 then
  end if;
  --delete
  if g_load_type <>'INITIAL' then
    if g_delete_flag and g_skip_delete=false then
      if g_mapping_type='FACT' then
        if g_is_source=true or g_is_custom_source=true then
          if g_is_delete_trigger_imp=false then
            insert_into_load_progress_d(g_load_pk,g_primary_target_name,g_jobid_stmt||'Move Delete data into dlog ',sysdate,
            null,'MAPPING','INSERT',g_jobid_stmt||'MDDDL'||p_count,'I');
            if excecute_data_into_dlog('DELETE') = false then
              write_to_log_file_n('excecute_data_into_dlog returned with error');
              insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'MDDDL'||p_count,'U');
              return false;
            end if;
            insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'MDDDL'||p_count,'U');
          end if;
        end if;
      end if;
      insert_into_load_progress_d(g_load_pk,g_primary_target_name,g_jobid_stmt||'Delete '||g_primary_target_name,sysdate,
      null,'MAPPING','DELETE',g_jobid_stmt||'DELETE'||p_count,'I');
      l_count:=execute_delete_stmt;
      insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'DELETE'||p_count,'U');
      g_total_delete:=l_count;
      if l_count is null then
        return false;
      end if;
    end if;
  end if;--if g_load_type <>'INITIAL' then
  /*
  how is deletes to be handled in fact audit and net change?
  */
  return true;
EXCEPTION when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

procedure execute_all(p_count number) IS
l_cursor number;
l_dummy number;
---
l_int_upd_status_table varchar2(100);
l_int_upd_job_id number;
l_job_time number;
---
Begin
  if g_debug then
    write_to_debug_n('In execute_all'||get_time);
    edw_owb_collection_util.dump_mem_stats;
    edw_owb_collection_util.dump_parallel_stats;
  end if;
  g_number_rows_dangling:=0;
  --executes all the statements
  if g_use_mti then
    insert_into_load_progress_d(g_load_pk,g_primary_target_name,g_jobid_stmt||'Create User Measure FK Table',
    sysdate,null,'MAPPING','CREATE-TABLE',g_jobid_stmt||'CRUSMESFK'||p_count,'I');
    if create_user_measure_fk_table=false then
      g_status:=false;
      return;
    end if;
    --insert into the user measure and user fk table
    if insert_fm_ff_table=false then
      g_status:=false;
      return;
    end if;
    --user fk table is now populated
    insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'CRUSMESFK'||p_count,'U');
  end if;
  insert_into_load_progress_d(g_load_pk,g_primary_target_name,g_jobid_stmt||'Create OP Code Table',sysdate,null,
  'MAPPING','CREATE-TABLE',g_jobid_stmt||'CROPTAB'||p_count,'I');
  if g_number_da_cols>0 then
    if create_opcode_table(g_da_cols,g_number_da_cols)= false then
      write_to_log_file_n('create_opcode_table returned with error');
      return;
    end if;
  else
    if create_opcode_table = false then
      write_to_log_file_n('create_opcode_table returned with error');
      return;
    end if;
  end if;
  insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'CROPTAB'||p_count,'U');
  --here we set the join to the stg table
  if g_debug then
    edw_owb_collection_util.dump_mem_stats;
    edw_owb_collection_util.dump_parallel_stats;
  end if;
  if set_stg_nl_parameters(g_number_rows_ready)=false then
    g_stg_join_nl:=true;
  end if;
  --here we make the sql translation stmt
  make_sql_surrogate_fk;
  if g_status=false then
    return;
  end if;
  make_hd_insert_stmt;
  if g_status=false then
    return;
  end if;
  make_insert_update_stmt;
  if g_status=false then
    return;
  end if;
  insert_into_load_progress_d(g_load_pk,g_primary_target_name,g_jobid_stmt||'Create FK Key Table',sysdate,null,
  'MAPPING','CREATE-TABLE',g_jobid_stmt||'CRFKT'||p_count,'I');
  if execute_surr_insert=false then
    write_to_log_file_n('execute_surr_insert returned with error');
    g_status:=false;
    return;
  end if;
  insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'CRFKT'||p_count,'U');
  if g_debug then
    edw_owb_collection_util.dump_mem_stats;
    edw_owb_collection_util.dump_parallel_stats;
  end if;
  --we launch a separate thread here to update the interface table with DANGLING or COLLECTED
  --if the job launched has not started by the time execute_insert_update_delete is done, then
  --kill the job and do manually
  --we launch a job only is this itself is a job or child conc request
  l_int_upd_job_id:=null;
  if g_job_id is not null and g_job_queue_processes>0 then
    l_int_upd_status_table:=g_bis_owner||'.'||g_int_upd_status_table_name||'_'||g_job_id;
    --call the procedure
    --if there is error launching thread, continue serial as usual
    if execute_dangling_collected(p_count,l_int_upd_status_table,l_int_upd_job_id)=false then
      l_int_upd_job_id:=null;
    end if;
  end if;
  if execute_insert_update_delete(p_count) = false then
    g_status:=false;
    write_to_log_file_n('execute_insert_update_delete returned with error');
    return;
  end if;
  if g_debug then
    edw_owb_collection_util.dump_mem_stats;
    edw_owb_collection_util.dump_parallel_stats;
  end if;
  if l_int_upd_job_id is not null then
    declare
      l_status varchar2(400);
      l_message varchar2(4000);
    begin
      if edw_owb_collection_util.check_and_wait_for_job(l_int_upd_job_id,l_int_upd_status_table,null,
        g_sleep_time,l_status,l_message)=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.get_status_message;
        g_status:=false;
        return;
      end if;
      if l_status='NO JOB' then
        l_int_upd_job_id:=null;
      else
        if l_status='ERROR' then
          g_status_message:=l_message;
          g_status:=false;
          return;
        end if;
      end if;
    end;
  end if;
  if edw_owb_collection_util.drop_table(l_int_upd_status_table)=false then
    null;
  end if;
  if l_int_upd_job_id is null then
    if execute_dangling_collected(p_count)=false then
      return;
    end if;
    if g_debug then
      edw_owb_collection_util.dump_mem_stats;
      edw_owb_collection_util.dump_parallel_stats;
    end if;
  end if;
  if calc_rows_processed_errors = false then
    return;
  end if;
  if drop_opcode_table = false then
    write_to_log_file_n('drop_opcode_table returned with false');
    return;
  end if;
  if g_debug then
    write_to_debug_n('Finished execute_all'||get_time);
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in execute all '||sqlerrm||get_time);
  g_status:=false;
End;--procedure execute_all IS

--procedure for multi threaded update of interface table
function execute_dangling_collected(
p_count number,
p_table varchar2,
p_job_id out nocopy number
) return boolean is
----
l_stmt varchar2(4000);
----
l_debug varchar2(20);
l_low_system_mem varchar2(20);
l_version_GT_1159 varchar2(20);
----
Begin
  if g_debug then
    write_to_log_file_n('In procedure execute_dangling_collected. Going to launch dbms job'||get_time);
  end if;
  --p_table is the status table
  if edw_owb_collection_util.drop_table(p_table)=false then
    null;
  end if;
  if g_debug then
    l_debug:='Y';
  else
    l_debug:='N';
  end if;
  if g_low_system_mem then
    l_low_system_mem:='Y';
  else
    l_low_system_mem:='N';
  end if;
  if edw_owb_collection_util.g_version_GT_1159 then
    l_version_GT_1159:='Y';
  else
    l_version_GT_1159:='N';
  end if;
  if g_debug then
    write_to_log_file_n('EDW_MAPPING_COLLECT.execute_dangling_collected('||
    ''||g_primary_target||','||
    ''''||g_primary_target_name||''','||
    ''''||g_fstgTableName||''','||
    ''''||g_fstgPKName||''','||
    ''''||g_instance_column||''','||
    ''''||g_surr_table||''','||
    ''''||g_error_rowid_table||''','||
    ''''||g_ok_rowid_table||''','||
    ----
    ''''||g_bis_owner||''','||
    ''||g_load_pk||','||
    ''||g_job_id||','||
    ''''||g_jobid_stmt||''','||
    ''||p_count||','||
    ''||g_number_rows_ready||','||
    ''||g_surr_count||','||
    ----
    ''''||l_debug||''','||
    ''''||g_update_type||''','||
    ''''||l_low_system_mem||''','||
    ''''||g_op_table_space||''','||
    ''||nvl(g_parallel,0)||','||
    ''||nvl(g_sort_area_size,0)||','||
    ''||nvl(g_hash_area_size,0)||','||
    ''''||nvl(g_rollback,'null')||''','||
    ''''||l_version_GT_1159||''','||
    ''''||p_table||''');');
  end if;
  DBMS_JOB.SUBMIT(p_job_id,'EDW_MAPPING_COLLECT.execute_dangling_collected('||
  ''||g_primary_target||','||
  ''''||g_primary_target_name||''','||
  ''''||g_fstgTableName||''','||
  ''''||g_fstgPKName||''','||
  ''''||g_instance_column||''','||
  ''''||g_surr_table||''','||
  ''''||g_error_rowid_table||''','||
  ''''||g_ok_rowid_table||''','||
  ----
  ''''||g_bis_owner||''','||
  ''||g_load_pk||','||
  ''||g_job_id||','||
  ''''||g_jobid_stmt||''','||
  ''||p_count||','||
  ''||g_number_rows_ready||','||
  ''||g_surr_count||','||
  ----
  ''''||l_debug||''','||
  ''''||g_update_type||''','||
  ''''||l_low_system_mem||''','||
  ''''||g_op_table_space||''','||
  ''||nvl(g_parallel,0)||','||
  ''||nvl(g_sort_area_size,0)||','||
  ''||nvl(g_hash_area_size,0)||','||
  ''''||nvl(g_rollback,'null')||''','||
  ''''||l_version_GT_1159||''','||
  ''''||p_table||''');');
  commit;--this commit is very imp
  if g_debug then
    write_to_log_file_n('Job '||p_job_id||' launched '||get_time);
  end if;
  return true;
Exception when others then
  write_to_log_file_n('Error in execute_dangling_collected '||sqlerrm||get_time);
  return false;
End;--procedure execute_all IS

--this is called as a dbms_job
procedure execute_dangling_collected(
---
p_primary_target number,
p_primary_target_name varchar2,
p_fstgTableName varchar2,
p_fstgPKName varchar2,
p_instance_column varchar2,
p_surr_table varchar2,
p_error_rowid_table varchar2,
p_ok_rowid_table varchar2,
---
p_bis_owner varchar2,
p_load_pk varchar2,
p_job_id number,
p_jobid_stmt varchar2,
p_count number,
p_number_rows_ready number,
p_surr_count number,
---
p_debug varchar2,
p_update_type varchar2,
p_low_system_mem varchar2,
p_op_table_space varchar2,
p_parallel number,
p_sort_area_size number,
p_hash_area_size number,
p_rollback varchar2,
p_version_GT_1159 varchar2,
p_table varchar2 --this is the status table
) is
---
l_stmt varchar2(3000);
---
Begin
  g_primary_target:=p_primary_target;
  g_primary_target_name:=p_primary_target_name;
  g_fstgTableName:=p_fstgTableName;
  g_fstgPKName:=p_fstgPKName;
  g_instance_column:=p_instance_column;
  g_surr_table:=p_surr_table;
  g_error_rowid_table:=p_error_rowid_table;
  g_ok_rowid_table:=p_ok_rowid_table;
  ----
  g_bis_owner:=p_bis_owner;
  g_load_pk:=p_load_pk;
  g_job_id:=p_job_id;
  g_jobid_stmt:=p_jobid_stmt;
  g_number_rows_ready:=p_number_rows_ready;
  g_surr_count:=p_surr_count;
  g_number_rows_processed:=p_surr_count;
  ----
  if p_version_GT_1159='Y' then
    edw_owb_collection_util.g_version_GT_1159:=true;
  else
    edw_owb_collection_util.g_version_GT_1159:=false;
  end if;
  if p_debug='Y' then
    g_debug:=true;
    edw_owb_collection_util.setup_conc_program_log('INT_UPD_'||g_primary_target||'_'||g_job_id);
  else
    g_debug:=false;
  end if;
  g_update_type:=p_update_type;
  if p_low_system_mem='Y' then
    g_low_system_mem:=true;
  else
    g_low_system_mem:=false;
  end if;
  g_op_table_space:=p_op_table_space;
  g_parallel:=p_parallel;
  if g_parallel=0 then
    g_parallel:=null;
  end if;
  if g_parallel is not null and g_parallel>0 then
    edw_owb_collection_util.alter_session('PARALLEL',g_parallel);
  end if;
  g_sort_area_size:=p_sort_area_size;
  if g_sort_area_size=0 then
    g_sort_area_size:=null;
  end if;
  g_hash_area_size:=p_hash_area_size;
  if g_hash_area_size=0 then
    g_hash_area_size:=null;
  end if;
  if g_sort_area_size is not null then
    edw_owb_collection_util.alter_session('SORT_AREA_SIZE',g_sort_area_size);
  end if;
  if g_hash_area_size is not null then
    edw_owb_collection_util.alter_session('HASH_AREA_SIZE',g_hash_area_size);
  end if;
  g_rollback:=p_rollback;
  if g_rollback='null' then
    g_rollback:=null;
  end if;
  ----
  g_number_dim_pk_structure:=0;
  g_number_dim_pk_structure_cols:=0;
  ----
  --create the table here. the presence of the table indicates that the job started
  l_stmt:='create table '||p_table||'(status varchar2(40),message varchar2(4000))'||
  ' tablespace '||g_op_table_space;
  if g_debug then
    write_to_log_file_n(l_stmt);
  end if;
  execute immediate l_stmt;
  if g_debug then
    edw_owb_collection_util.dump_mem_stats;
    edw_owb_collection_util.dump_parallel_stats;
  end if;
  ----
  if execute_dangling_collected(p_count)=false then
    execute immediate 'insert into '||p_table||'(status,message) values(:1,:2)' using
    'ERROR',g_status_message;
  else
    execute immediate 'insert into '||p_table||'(status,message) values(:1,:2)' using
    'SUCCESSS','SUCCESS';
  end if;
  if g_debug then
    edw_owb_collection_util.dump_mem_stats;
    edw_owb_collection_util.dump_parallel_stats;
  end if;
  commit;
Exception when others then
  execute immediate 'insert into '||p_table||'(status,message) values(:1,:2)' using
  'ERROR',sqlerrm;
  commit;
End;--procedure execute_all IS

function execute_dangling_collected(p_count number) return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In execute_dangling_collected '||
    'g_number_rows_ready='||g_number_rows_ready||' g_surr_count='||g_surr_count||
    get_time);
  end if;
  --if (g_number_rows_ready-g_number_rows_processed) > 0 then
  if (g_number_rows_ready-g_surr_count) > 0 then
    if execute_ready_to_dangling(p_count)=false then
      return false;
    end if;
  end if;
  if execute_collect_to_collected(p_count)=false then
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in execute_dangling_collected '||sqlerrm||get_time);
  g_status:=false;
  return false;
End;

function execute_ready_to_dangling(p_count number) return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In execute_ready_to_dangling '||get_time);
  end if;
  insert_into_load_progress_d(g_load_pk,g_primary_target_name,g_jobid_stmt||'Create Error Rowid Table',sysdate,null,
  'MAPPING','CREATE-TABLE',g_jobid_stmt||'CRERT'||p_count,'I');
  if create_error_rowid_table('DANGLING')= false then
    write_to_log_file_n('create_error_rowid_table returned with error');
    return false;
  end if;
  insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'CRERT'||p_count,'U');
  if g_object_type='DIMENSION' and g_temp_log and g_log_dang_keys then --this is the lowest level
    insert_into_load_progress_d(g_load_pk,g_primary_target_name,g_jobid_stmt||'Log dangling keys',sysdate,null,
    'MAPPING','CREATE-TABLE',g_jobid_stmt||'LDKD'||p_count,'I');
    if log_dimension_dang_keys(g_fstgPKName,g_object_id,g_object_name,g_dim_auto_dang_table_dim,
      g_primary_target)=false then
      return false;
    end if;
    insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'LDKD'||p_count,'U');
  end if;
  insert_into_load_progress_d(g_load_pk,g_primary_target_name,g_jobid_stmt||'Mark DANGLING in Interfact Table',sysdate,null,
  'MAPPING','UPDATE',g_jobid_stmt||'MKDNG'||p_count,'I');
  if move_dangling_records_log=false then
    write_to_log_file_n('move_dangling_records_log returned with error');
    return false;
  end if;
  insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'MKDNG'||p_count,'U');
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in execute_ready_to_dangling '||sqlerrm||get_time);
  g_status:=false;
  return false;
End;

function execute_collect_to_collected(p_count number) return boolean is
l_stmt varchar2(4000);
l_stmt1 varchar2(4000);
l_count number:=1;
l_surr_rowid_table varchar2(400);
l_update_type varchar2(400);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_rowid rowid;
l_total_count number:=0;
begin
  if g_debug then
    write_to_log_file_n('In execute_collect_to_collected'||get_time);
  end if;
  insert_into_load_progress_d(g_load_pk,g_primary_target_name,g_jobid_stmt||'Mark Records as COLLECTED',sysdate,null,
  'MAPPING','UPDATE',g_jobid_stmt||'MKRC'||p_count,'I');
  if update_stg_status_column(g_surr_table,'row_id',null,'COLLECTED',true)=false then
    return false;
  end if;
  insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'MKRC'||p_count,'U');
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in execute_collect_to_collected '||sqlerrm||get_time);
  g_status:=false;
  return false;
End;--procedure  IS

function update_stg_status_column(
p_src_table varchar2,
p_rowid_col varchar2,
p_where_stmt varchar2,
p_status varchar2, --COLLECTED OR READY
p_create_iot boolean
) return boolean is
---
l_stmt varchar2(4000);
l_stmt1 varchar2(4000);
l_count number:=1;
l_surr_rowid_table varchar2(400);
l_update_type varchar2(400);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_rowid rowid;
l_total_count number:=0;
---
begin
  if g_debug then
    write_to_log_file_n('In update_stg_status_column'||get_time);
  end if;
  l_update_type:=g_update_type;
  if g_low_system_mem=true then
    l_update_type:='ROW-BY-ROW';
  end if;
  if l_update_type='MASS' or l_update_type='DELETE-INSERT' then
    if p_create_iot then
      l_surr_rowid_table:=p_src_table||'R';
      --4161164 : remove IOT , replace with ordinary table and index
      --l_stmt:='create table '||l_surr_rowid_table||'('||p_rowid_col||' primary key) organization index '||
      l_stmt:='create table '||l_surr_rowid_table||
      ' tablespace '||g_op_table_space;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||' as select '||p_rowid_col||' from '||p_src_table||' '||p_where_stmt;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_surr_rowid_table)=false then
        null;
      end if;
      if g_debug then
        write_to_log_file_n('Going to execute '||l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Created '||l_surr_rowid_table||' with '||sql%rowcount||' records '||get_time);
      end if;
      --4161164 : remove IOT , replace with ordinary table and index
      EDW_OWB_COLLECTION_UTIL.create_iot_index(l_surr_rowid_table,p_rowid_col,g_op_table_space,g_parallel);
      EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_surr_rowid_table,instr(l_surr_rowid_table,'.')+1,
      length(l_surr_rowid_table)),substr(l_surr_rowid_table,1,instr(l_surr_rowid_table,'.')-1));
    else
      l_surr_rowid_table:=p_src_table;
    end if;
    l_stmt:='update /*+ORDERED USE_NL('||g_fstgTableName||')*/ ';
    if g_parallel is not null then
      l_stmt:=l_stmt||' /*+PARALLEL('||g_fstgTableName||','||g_parallel||')*/ ';
    end if;
    l_stmt:=l_stmt||g_fstgTableName||' set collection_status='''||p_status||''' where rowid in '||
    '(select '||p_rowid_col||' from '||l_surr_rowid_table||')';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Updated '||sql%rowcount||' records to '''||p_status||''''||get_time);
    end if;
    commit;
    if p_create_iot then
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_surr_rowid_table)=false then
        null;
      end if;
    end if;
  elsif l_update_type='ROW-BY-ROW' then
    l_stmt:='update '||g_fstgTableName||' set collection_status='''||p_status||''' where rowid=:a';
    l_stmt1:='select '||p_rowid_col||' row_id from '||p_src_table||' '||p_where_stmt;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt1||get_time);
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    open cv for l_stmt1;
    loop
      fetch cv into l_rowid;
      exit when cv%notfound;
      execute immediate l_stmt using l_rowid;
      l_total_count:=l_total_count+1;
    end loop;
    close cv;
    commit;
    if g_debug then
      write_to_log_file_n('Updated '||l_total_count||' records to '''||p_status||''''||get_time);
    end if;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in update_stg_status_column '||sqlerrm||get_time);
  g_status:=false;
  return false;
End;--procedure  IS

function create_dlog_lookup_table return boolean is
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  if g_debug then
    write_to_log_file_n('In create_dlog_lookup_table ');
  end if;
  if EDW_OWB_COLLECTION_UTIL.check_table_column(g_fact_dlog,'round') then
    l_stmt:='select max(round) from '||g_fact_dlog;
    if g_debug then
      write_to_log_file_n(l_stmt||get_time);
    end if;
    open cv for l_stmt;
    fetch cv into g_max_round;
    close cv;
    if g_max_round is not null then
      g_max_round:=g_max_round+1;
    end if;
  end if;
  if g_debug then
    write_to_log_file_n('Max(round)='||g_max_round||get_time);
  end if;
  l_stmt:='create table '||g_update_dlog_lookup_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  as select ';
  if g_parallel is not null and instr(g_fact_dlog,g_bis_owner||'.') = 0 then
    l_stmt:=l_stmt||' /*+PARALLEL('||g_fact_dlog||','||g_parallel||')*/ ';
  end if;
  l_stmt:=l_stmt||' row_id row_id, rowid row_id1 from '||g_fact_dlog;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_update_dlog_lookup_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file('Created '||g_update_dlog_lookup_table||' with '||sql%rowcount||' rows '||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_update_dlog_lookup_table,instr(g_update_dlog_lookup_table,'.')+1,
  length(g_update_dlog_lookup_table)),substr(g_update_dlog_lookup_table,1,instr(g_update_dlog_lookup_table,'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;


/*
if this is a source for derived facts, then we need to move the FACT data into the dlog table before update
*/
procedure make_data_into_dlog_stmt is
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_dlog varchar2(400);
l_owner varchar2(400);
Begin
  if g_debug then
    write_to_log_file_n('In make_data_into_dlog_stmt');
  end if;
  g_fact_dlog_stmt:=null;
  g_fact_delete_dlog_stmt:=null;
  g_number_dlog_columns:=0;
  if g_fact_dlog is null then
    write_to_log_file_n('No delete log');
    return;
  end if;
  if instr(g_fact_dlog,g_bis_owner||'.') <> 0 then
    l_dlog:=substr(g_fact_dlog,instr(g_fact_dlog,'.')+1,length(g_fact_dlog));
    l_owner:=g_bis_owner;
  else
    l_dlog:=g_fact_dlog;
    l_owner:=EDW_OWB_COLLECTION_UTIL.get_table_owner(g_fact_dlog);
  end if;
  if EDW_OWB_COLLECTION_UTIL.get_db_columns_for_table(l_dlog,g_dlog_columns,g_number_dlog_columns,l_owner) = false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    g_status:=false;
    write_to_log_file_n(g_status_message);
    return;
  end if;
  if g_number_dlog_columns=0 then
    write_to_log_file_n('No columns found for delete log '||g_fact_dlog);
    return;
  end if;
  if g_debug then
    write_to_log_file_n('The DLOG columns');
    for i in 1..g_number_dlog_columns loop
      write_to_log_file(g_dlog_columns(i));
    end loop;
  end if;
  if g_parallel is null then
    g_fact_dlog_stmt:='insert into '||g_fact_dlog||'(';
  else
    g_fact_dlog_stmt:='insert /*+PARALLEL ('||g_fact_dlog||','||g_parallel||')*/ into '||g_fact_dlog||'(';
  end if;
  for i in 1..g_number_dlog_columns loop
    if upper(g_dlog_columns(i)) <> 'ROW_ID' and upper(g_dlog_columns(i)) <> 'DLOG_LAST_UPDATE_DATE'
    and upper(g_dlog_columns(i)) <> 'PK_KEY' and upper(g_dlog_columns(i)) <> 'ROUND' then
      g_fact_dlog_stmt:=g_fact_dlog_stmt||g_dlog_columns(i)||',';
    end if;
  end loop;
  g_fact_dlog_stmt:=g_fact_dlog_stmt||'row_id,pk_key,round ';
  if EDW_OWB_COLLECTION_UTIL.value_in_table(g_dlog_columns,g_number_dlog_columns,'DLOG_LAST_UPDATE_DATE')=true then
    g_fact_dlog_stmt:=g_fact_dlog_stmt||',DLOG_LAST_UPDATE_DATE ';
  end if;
  g_fact_dlog_stmt:=g_fact_dlog_stmt||') select /*+ORDERED USE_NL('||g_object_name||')*/ ';
  if g_parallel is not null then
    g_fact_dlog_stmt:=g_fact_dlog_stmt||' /*+PARALLEL('||g_object_name||','||g_parallel||')*/ ';
  end if;
  for i in 1..g_number_dlog_columns loop
    if upper(g_dlog_columns(i)) <> 'ROW_ID' and upper(g_dlog_columns(i)) <> 'DLOG_LAST_UPDATE_DATE'
    and upper(g_dlog_columns(i)) <> 'PK_KEY' and upper(g_dlog_columns(i)) <> 'ROUND' then
      g_fact_dlog_stmt:=g_fact_dlog_stmt||g_object_name||'.'||g_dlog_columns(i)||',';
    end if;
  end loop;
  g_fact_dlog_stmt:=g_fact_dlog_stmt||g_object_name||'.rowid,'||g_object_name||'.'||g_factPKNameKey||
  ','||g_dlog_rowid_table||'.round';
  if EDW_OWB_COLLECTION_UTIL.value_in_table(g_dlog_columns,g_number_dlog_columns,'DLOG_LAST_UPDATE_DATE')=true then
    g_fact_dlog_stmt:=g_fact_dlog_stmt||',SYSDATE ';
  end if;
  g_fact_dlog_stmt:=g_fact_dlog_stmt||' from '||g_dlog_rowid_table||','||g_object_name;
  g_fact_dlog_stmt:=g_fact_dlog_stmt||' where '||g_dlog_rowid_table||'.row_id='||g_object_name||'.rowid';
  if g_debug then
    write_to_log_file_n('g_fact_dlog_stmt is '||g_fact_dlog_stmt);
  end if;
  if g_parallel is null then
    g_fact_delete_dlog_stmt:='insert into '||g_fact_dlog||'(';
  else
    g_fact_delete_dlog_stmt:='insert /*+PARALLEL ('||g_fact_dlog||','||g_parallel||')*/ into '||g_fact_dlog||'(';
  end if;
  for i in 1..g_number_dlog_columns loop
    if upper(g_dlog_columns(i)) <> 'ROW_ID' and upper(g_dlog_columns(i)) <> 'DLOG_LAST_UPDATE_DATE'
    and upper(g_dlog_columns(i)) <> 'PK_KEY' and upper(g_dlog_columns(i)) <> 'ROUND' then
      g_fact_delete_dlog_stmt:=g_fact_delete_dlog_stmt||g_dlog_columns(i)||',';
    end if;
  end loop;
  g_fact_delete_dlog_stmt:=g_fact_delete_dlog_stmt||'row_id,pk_key,round ';
  if EDW_OWB_COLLECTION_UTIL.value_in_table(g_dlog_columns,g_number_dlog_columns,'DLOG_LAST_UPDATE_DATE')=true then
    g_fact_delete_dlog_stmt:=g_fact_delete_dlog_stmt||',DLOG_LAST_UPDATE_DATE ';
  end if;
  g_fact_delete_dlog_stmt:=g_fact_delete_dlog_stmt||') select  /*+ORDERED USE_NL('||g_object_name||')*/ ';
  if g_parallel is not null then
    g_fact_delete_dlog_stmt:=g_fact_delete_dlog_stmt||' /*+PARALLEL('||g_object_name||','||g_parallel||')*/ ';
  end if;
  for i in 1..g_number_dlog_columns loop
    if upper(g_dlog_columns(i)) <> 'ROW_ID' and upper(g_dlog_columns(i)) <> 'DLOG_LAST_UPDATE_DATE'
    and upper(g_dlog_columns(i)) <> 'PK_KEY' and upper(g_dlog_columns(i)) <> 'ROUND' then
      g_fact_delete_dlog_stmt:=g_fact_delete_dlog_stmt||g_object_name||'.'||g_dlog_columns(i)||',';
    end if;
  end loop;
  g_fact_delete_dlog_stmt:=g_fact_delete_dlog_stmt||g_object_name||'.rowid,'||g_object_name||'.'||g_factPKNameKey||
  ','||g_dlog_rowid_table||'.round';
  if EDW_OWB_COLLECTION_UTIL.value_in_table(g_dlog_columns,g_number_dlog_columns,'DLOG_LAST_UPDATE_DATE')=true then
    g_fact_delete_dlog_stmt:=g_fact_delete_dlog_stmt||',SYSDATE ';
  end if;
  g_fact_delete_dlog_stmt:=g_fact_delete_dlog_stmt||' from '||g_dlog_rowid_table||','||g_object_name;
  g_fact_delete_dlog_stmt:=g_fact_delete_dlog_stmt||' where '||
                           g_dlog_rowid_table||'.row_id='||g_object_name||'.rowid';
  if g_debug then
    write_to_log_file_n('g_fact_delete_dlog_stmt is '||g_fact_delete_dlog_stmt);
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
End;

function create_dlog_rowid_table(p_mode varchar2) return boolean is
l_stmt varchar2(4000);
l_dlog_rowid_table varchar2(400);
l_distinct_table varchar2(400);
l_update_dlog_rowid_table varchar2(400);
Begin
  if g_debug then
    write_to_log_file_n('In create_dlog_rowid_table, p_mode is '||p_mode);
  end if;
  if g_dlog_has_data then
    l_dlog_rowid_table:=g_dlog_rowid_table||'T';
    l_distinct_table:=g_dlog_rowid_table||'D';
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_dlog_rowid_table)=false then
      null;
    end if;
    l_stmt:='create table '||l_dlog_rowid_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  ';
    if p_mode='UPDATE' then
      l_stmt:=l_stmt||' as select row_id1 row_id from '||g_hold_table;
    else
      l_stmt:=l_stmt||' as select row_id1 row_id from '||g_surr_table||' where operation_code=2';
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file('Created '||l_dlog_rowid_table||' with '||sql%rowcount||' rows '||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_dlog_rowid_table,instr(l_dlog_rowid_table,'.')+1,
    length(l_dlog_rowid_table)),substr(l_dlog_rowid_table,1,instr(l_dlog_rowid_table,'.')-1));
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_distinct_table)=false then
      null;
    end if;
    l_stmt:='create table '||l_distinct_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  as select distinct row_id from '||g_update_dlog_lookup_table;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_distinct_table)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file('Created with '||sql%rowcount||' rows '||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_distinct_table,instr(l_distinct_table,'.')+1,
    length(l_distinct_table)),substr(l_distinct_table,1,instr(l_distinct_table,'.')-1));
    l_stmt:='create table '||g_dlog_rowid_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  ';
    l_stmt:=l_stmt||' as select A.row_id,decode(B.rowid,null,0,'||g_max_round||') round from '||
    l_dlog_rowid_table||' A,'||l_distinct_table||' B where A.row_id=B.row_id(+)';
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_dlog_rowid_table)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file('Created '||g_dlog_rowid_table||' with '||sql%rowcount||' rows '||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_dlog_rowid_table,instr(g_dlog_rowid_table,'.')+1,
    length(g_dlog_rowid_table)),substr(g_dlog_rowid_table,1,instr(g_dlog_rowid_table,'.')-1));
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_dlog_rowid_table)=false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_distinct_table)=false then
      null;
    end if;
  else --if the dlog did not have any data
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_dlog_rowid_table)=false then
      null;
    end if;
    l_stmt:='create table '||g_dlog_rowid_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  ';
    if p_mode='UPDATE' then
      l_stmt:=l_stmt||' as select row_id1 row_id,0 round from '||g_hold_table;
    else
      l_stmt:=l_stmt||' as select row_id1 row_id,0 round from '||g_surr_table||' where operation_code=2';
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file('Created '||g_dlog_rowid_table||' with '||sql%rowcount||' rows '||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_dlog_rowid_table,instr(g_dlog_rowid_table,'.')+1,
      length(g_dlog_rowid_table)),substr(g_dlog_rowid_table,1,instr(g_dlog_rowid_table,'.')-1));
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  write_to_log_file('Problem stmt '||l_stmt);
  g_status:=false;
  return false;
End;

function insert_dlog_table(p_mode varchar2) return boolean is
l_stmt varchar2(32000);
Begin
  if g_debug then
    write_to_log_file_n('In insert_dlog_table , p_mode='||p_mode);
  end if;
  if p_mode='UPDATE' then
    l_stmt:=g_fact_dlog_stmt;
  elsif p_mode='DELETE' then
    l_stmt:=g_fact_delete_dlog_stmt;
  else
    write_to_log_file_n('Unknown mode');
    return false;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  if l_stmt is null then
    write_to_log_file_n('There is no delete log for this fact.');
    return true;
  end if;
  EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Moved '||sql%rowcount||' rows into the DLOG table '||get_time);
  end if;
  commit;
  if g_debug then
    write_to_log_file_n('commit');
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dlog_rowid_table)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;


/*
if this is a source for derived facts, then we need to move the FACT data into the dlog table before update
*/
function excecute_data_into_dlog(p_mode varchar2) return boolean is
l_stmt varchar2(32000);
Begin
  if g_debug then
    write_to_log_file_n('In excecute_data_into_dlog, p_mode is '||p_mode||get_time);
  end if;
  if create_dlog_rowid_table(p_mode)=false then
    return false;
  end if;
  --if g_dlog_has_data then
    --if update_dlog_table=false then
      --return false;
    --end if;
  --end if;
  if insert_dlog_table(p_mode)=false then
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  write_to_log_file('Problem stmt '||l_stmt);
  g_status:=false;
  return false;
End;

procedure get_tracked_columns is
l_description varchar2(4000):=null;
l_start number;
l_end number;
l_len number;
l_name varchar2(400);
cursor c2(p_fact_id number, p_is_name varchar2) is
select fact_item.column_name from
edw_attribute_sets_md_v sis,
edw_attribute_set_columns_md_v isu,
edw_pvt_columns_md_v fact_item
where sis.entity_id=p_fact_id
and sis.attribute_group_name=p_is_name
and isu.attribute_group_id=sis.attribute_group_id
and fact_item.column_id=isu.column_id
and fact_item.parent_object_id=p_fact_id;
Begin
 write_to_debug_n('In get_tracked_columns '||get_time);
 g_item_audit_number:=1;
 open c2(g_primary_target,g_fact_audit_is_name);
 loop
   fetch c2 into g_item_audit(g_item_audit_number);
   exit when c2%notfound;
   g_item_audit_number:=g_item_audit_number+1;
 end loop;
 g_item_audit_number:=g_item_audit_number-1;

Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
End;


procedure select_fact_audit is
--selects the rowids to audit
Begin
 write_to_debug_n('In select_fact_audit '||get_time);
 get_tracked_columns;
 if g_item_audit_number =0 then --there are no columns to be tracked
   write_to_log_file_n('No fact audit for '||g_primary_target_name||' No columns found for tracking.');
   g_fact_audit:=false;
   return;
 end if;
 if g_debug then
   write_to_log_file_n('The tracked columns for the FACT');
   for i in 1..g_item_audit_number loop
     write_to_log_file(g_item_audit(i));
   end loop;
 end if;
 --get all the columns of
 g_item_audit_number_all:=0;
 if EDW_OWB_COLLECTION_UTIL.get_columns_for_table(g_fact_audit_name,g_item_audit_all,
   g_item_audit_number_all)=false then
   g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
   g_status:=false;
   write_to_log_file_n(g_status_message);
   write_to_log_file(EDW_OWB_COLLECTION_UTIL.g_status_message);
 end if;
 if g_item_audit_number_all =0 then --there are no columns to be tracked
   write_to_log_file_n('No fact audit for '||g_primary_target_name||' No columns found in audit fact');
   g_fact_audit:=false;
   return;
 end if;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
End;

procedure get_tracked_columns_NC is
l_description varchar2(4000):=null;
l_start number;
l_end number;
l_len number;
l_name varchar2(400);
cursor c2(p_fact_id number, p_is_name varchar2) is
select fact_item.column_name from
edw_attribute_sets_md_v sis,
edw_attribute_set_columns_md_v isu,
edw_pvt_columns_md_v fact_item
where sis.entity_id=p_fact_id
and sis.attribute_group_name=p_is_name
and isu.attribute_group_id=sis.attribute_group_id
and fact_item.column_id=isu.column_id
and fact_item.parent_object_id=p_fact_id;
Begin
 write_to_debug_n('In get_tracked_columns_NC '||get_time);
 g_item_net_change_number:=1;
 open c2(g_primary_target,g_fact_net_change_is_name);
 loop
   fetch c2 into g_item_net_change(g_item_net_change_number);
   exit when c2%notfound;
   g_item_net_change_number:=g_item_net_change_number+1;
 end loop;
 g_item_net_change_number:=g_item_net_change_number-1;

Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
End;


procedure select_net_change is
l_count number:=0;
begin
 if g_debug then
   write_to_debug('In select_net_change '||get_time);
 end if;
 get_tracked_columns_NC;
 if g_item_net_change_number =0 then --there are no columns to be tracked
   write_to_log_file_n('No fact net change for '||
	g_primary_target_name||' No columns found for tracking.');
   return;
 end if;
 if g_debug then
   write_to_log_file_n('The tracked columns for the FACT in net change');
   for i in 1..g_item_net_change_number loop
     write_to_log_file(g_item_net_change(i));
   end loop;
 end if;
 --get all the columns of
 g_item_net_change_number_all  :=0;
 if EDW_OWB_COLLECTION_UTIL.get_columns_for_table(g_fact_net_change_name,g_item_net_change_all,
   g_item_net_change_number_all)=false then
   g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
   g_status:=false;
   write_to_log_file_n(g_status_message);
   write_to_log_file(EDW_OWB_COLLECTION_UTIL.g_status_message);
 end if;
 if g_item_net_change_number_all=0 then --there are no columns to be tracked
   write_to_log_file_n('No fact net change for '||g_primary_target_name||' No columns found in NC fact');
   g_fact_net_change:=false;
   return;
 end if;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
End;

Procedure Init_all(p_job_id number) is
l_primary_target_name varchar2(400);
l_var number;
l_option_value varchar2(40);
begin
 g_status_message:=' ';
 g_status:=true;
 g_groupby_on:=false;
 g_number_rows_processed:=0;
 g_instance_column:=null;
 g_number_ins_req_coll:=0;
 g_instance_dim_name:='EDW_INSTANCE_M';
 l_primary_target_name:='TAB_'||g_primary_target||'_';
 if p_job_id is not null then
   l_primary_target_name:=l_primary_target_name||p_job_id||'_';
 end if;
 g_dup_hold_table :=g_bis_owner||'.'||l_primary_target_name||'DH';--holds the real dup rowid
 g_dup_rownum :=g_bis_owner||'.'||l_primary_target_name||'DR';--holds the rownum and rowid(g_duplicate_collect)
 g_dup_rownum_rowid :=g_bis_owner||'.'||l_primary_target_name||'RR';--holds rowid of max rownum (g_duplicate_collect)
 g_dup_hold_pk_table:=g_bis_owner||'.'||l_primary_target_name||'DP';--holds the dup pks.
 g_surr_table_name:=g_bis_owner||'.'||l_primary_target_name||'S';
 g_surr_table:=g_surr_table_name;
 g_dlog_rowid_table:=g_bis_owner||'.'||l_primary_target_name||'SD';--joining the FS table and the fact table
 --was very time consuming. so creating this table in between to hold the fact rowids
 --g_update_dlog_rowid_table:=g_bis_owner||'.'||l_primary_target_name||'SDU';--dlog rowid for update
 --g_update_dlog_hold_table :=g_bis_owner||'.'||l_primary_target_name||'SDH';--hold table for dlog rowid  update
 if p_job_id is null then
   g_update_dlog_lookup_table:=g_bis_owner||'.'||l_primary_target_name||'SDL';
 end if;
 g_user_fk_table:=g_bis_owner||'.'||l_primary_target_name||'F';--holds the user fks from the staging table
 g_user_measure_table:=g_bis_owner||'.'||l_primary_target_name||'M';
 g_user_key_hold_table:=g_bis_owner||'.'||l_primary_target_name||'UK';--holds user keys
 g_opcode_table:=g_bis_owner||'.'||l_primary_target_name||'OP';
 g_hold_table:=g_bis_owner||'.'||l_primary_target_name||'HD';
 g_hold_table_temp:=g_bis_owner||'.'||l_primary_target_name||'HDT';
 g_reqid_table:=g_bis_owner||'.'||l_primary_target_name||'RO';
 -- g_ins_reqid_table:=g_bis_owner||'.'||l_primary_target_name||'IR';--this holds the instance and req id
 g_error_rowid_table:=g_bis_owner||'.'||l_primary_target_name||'ER';
 g_ok_rowid_table:=g_bis_owner||'.'||l_primary_target_name||'OK';
 g_ok_rowid_table_prev:=null;
 --g_dup_err_rec_table:=g_bis_owner||'.'||l_primary_target_name||'DE';
 g_dup_err_rec_flag:=false;
 g_plan_table:=g_bis_owner||'.'||l_primary_target_name||'PL';
 --g_fact_audit_net_table is used to hold insert data first before going into the fact, then insert into
 --audit and net change table and then from this table, move into the fact
 g_fact_audit_net_table:=g_bis_owner||'.'||l_primary_target_name||'AN';
 g_fa_ilog:=g_bis_owner||'.'||l_primary_target_name||'AI';
 g_nc_ilog:=g_bis_owner||'.'||l_primary_target_name||'NI';
 g_fa_rec_log:=g_bis_owner||'.'||l_primary_target_name||'AR';
 g_nc_rec_log:=g_bis_owner||'.'||l_primary_target_name||'NR';
 g_fa_rec_up_log:=g_bis_owner||'.'||l_primary_target_name||'RA';
 g_nc_rec_up_log:=g_bis_owner||'.'||l_primary_target_name||'RN';
 g_da_op_table:=g_bis_owner||'.'||l_primary_target_name||'MD';
 g_dup_pp_row_id_table:=g_bis_owner||'.'||l_primary_target_name||'PPR';
 g_dup_pp_table:=g_bis_owner||'.'||l_primary_target_name||'PPD';
 g_insert_ctas_table:=g_bis_owner||'.'||l_primary_target_name||'ICT';
 g_stg_copy_table:=g_bis_owner||'.'||l_primary_target_name||'CP';
 g_int_upd_status_table_name:='INT_UPD_'||g_primary_target;--used in error recovery.
 g_ul_table:=g_bis_owner||'.TAB_'||g_primary_target||'_UL';
 if edw_owb_collection_util.drop_table(g_ul_table)=false then
   null;
 end if;
 --the table is used in parallelization of COLLECTED and DANGLING update
 g_err_rec_flag:=false;
 g_num_slow_change_tables:=0;
 g_fstgTableName:=null;
 g_factTableName:=null;
 g_order_by_stmt:=null;
 --g_total_records:=0;
 g_number_groupby_cols:=0;
 g_number_drop_objects:=0;
 g_number_surr_tables :=0;
 g_fstg_all_fk_direct_load:=false;
 g_pk_direct_load:=false;
 g_naedw_value:=0;
 g_total_insert:=0;
 g_total_update:=0;
 g_total_delete:=0;
 g_surr_table_LHJM:=true;
 g_skip_ilog_update:=false;
 g_type_ok_generation:='CTAS'; --or UPDATE
 g_smart_update_name:='CHECK_COLUMNS_FOR_UPDATE';
 g_number_fks_dang_load:=0;
 g_number_dim_pk_structure:=0;
 g_number_dim_pk_structure_cols:=0;
 g_user_fk_table_count:=0;
 g_stg_join_nl:=true;--by default
 if p_job_id is null then
   g_stg_copy_table_flag:=false;
 end if;
 if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_primary_target_name)=1 then
   g_load_type:='INITIAL';
   write_to_log_file_n('Initial Load');
   g_target_rec_count:=0;
 else
   g_load_type:='INC';
   write_to_log_file_n('Incremental Load');
 end if;
 if g_mapping_type='FACT' then
   l_var:=EDW_OWB_COLLECTION_UTIL.is_source_for_inc_derived_fact(g_object_name);
   if l_var=-1 then
     g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
     write_to_log_file_n(g_status_message);
     g_status:=false;
     return;
   elsif l_var=1 then
     g_is_source:=true;
   else
     g_is_source:=false;
   end if;
   l_var:=EDW_OWB_COLLECTION_UTIL.is_src_of_custom_inc_derv_fact(g_object_name);
   if l_var=-1 then
     g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
     write_to_log_file_n(g_status_message);
     g_status:=false;
     return;
   elsif l_var=1 then
     g_is_custom_source:=true;
   else
     g_is_custom_source:=false;
   end if;
   --g_is_source:=EDW_OWB_COLLECTION_UTIL.is_object_a_source(g_object_name);
   if g_is_source  then
     write_to_log_file_n('The fact is a source for derived or summary facts');
   else
     write_to_log_file_n('The fact is NOT a source for derived or summary facts');
   end if;
   g_is_delete_trigger_imp:=EDW_OWB_COLLECTION_UTIL.is_delete_trigger_imp(g_primary_target_name,g_table_owner);
   if g_is_delete_trigger_imp  then
     write_to_log_file_n('Delete trigger implemented');
   else
     write_to_log_file_n('Delete trigger NOT implemented');
   end if;
 end if;
 declare
   l_table EDW_OWB_COLLECTION_UTIL.varcharTableType;
   l_number_table number;
 begin
   g_skip_update:=false;
   l_option_value:=null;
   if g_read_cfig_options then
     if edw_option.get_warehouse_option(g_object_name,null,'SKIPUPDATE',l_option_value)=false then
       null;
     end if;
     if l_option_value='Y' then
       if g_object_type='DIMENSION' then
         if edw_option.get_option_columns(g_object_name,null,'SKIPUPDATE',l_table,l_number_table)=false then
           null;
         end if;
         if l_number_table is null then
           l_number_table:=0;
         end if;
         g_skip_update:=true;
         if l_number_table>0 then
           if EDW_OWB_COLLECTION_UTIL.value_in_table(l_table,l_number_table,
             substr(g_primary_target_name,1,instr(g_primary_target_name,'_LTC')-1))=false then
             g_skip_update:=false;
           end if;
         end if;
       else
         g_skip_update:=true;
       end if;
     end if;
   else
     if EDW_OWB_COLLECTION_UTIL.is_itemset_implemented(g_primary_target_name,'SKIP_UPDATE')='Y' then
       g_skip_update:=true;
     end if;
   end if;
   if g_debug then
     if g_skip_update then
       write_to_log_file_n('Skip Update');
     end if;
   end if;
   g_skip_delete:=false;
   if g_read_cfig_options then
     l_option_value:=null;
     l_number_table:=0;
     if edw_option.get_warehouse_option(g_object_name,null,'SKIPDELETE',l_option_value)=false then
       null;
     end if;
     if l_option_value='Y' then
       if g_object_type='DIMENSION' then
         if edw_option.get_option_columns(g_object_name,null,'SKIPDELETE',l_table,l_number_table)=false then
           null;
         end if;
         g_skip_delete:=true;
         if l_number_table is null then
           l_number_table:=0;
         end if;
         if l_number_table>0 then
           if EDW_OWB_COLLECTION_UTIL.value_in_table(l_table,l_number_table,
             substr(g_primary_target_name,1,instr(g_primary_target_name,'_LTC')-1))=false then
             g_skip_delete:=false;
           end if;
         end if;
       else
         g_skip_delete:=true;
       end if;
     end if;
   else
     if EDW_OWB_COLLECTION_UTIL.is_itemset_implemented(g_primary_target_name,'SKIP_DELETE')='Y' then
       g_skip_delete:=true;
     end if;
   end if;
   if g_debug then
     if g_skip_delete then
       write_to_log_file_n('Skip Delete');
     end if;
   end if;
 end;
 g_use_mti:=false;
 if g_use_mti then
   declare
     l_value varchar2(40);
     l_db_version varchar2(40);
   begin
     l_db_version:=edw_owb_collection_util.get_db_version;
     if edw_owb_collection_util.is_db_version_gt(l_db_version,'9.2') then
       l_value:=edw_owb_collection_util.get_parameter_value('cluster_database');
       if l_value='FALSE' then
         g_use_mti:=true;
         g_stg_copy_table_flag:=false;
       else
         g_use_mti:=false;
       end if;
     end if;
   end;
 end if;
 g_job_queue_processes:=edw_owb_collection_util.get_parameter_value('job_queue_processes');
 if p_job_id is null then
   if edw_owb_collection_util.drop_tables_like('TAB_'||g_primary_target||'_HDUR_%',g_bis_owner)=false then
     null;
   end if;
 end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
End;--Procedure Init_all is

procedure clean_up is
Begin
  if g_debug then
    write_to_log_file_n('In clean_up'||get_time);
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_surr_table)= false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_hold_table)= false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_error_rowid_table)= false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dup_hold_table)= false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dup_hold_pk_table)= false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_opcode_table)= false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dup_rownum)= false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dup_rownum_rowid)= false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_ok_rowid_table)= false then
    null;
  end if;
  if g_ok_rowid_table_prev is not null then
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_ok_rowid_table_prev)= false then
      null;
    end if;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_plan_table)= false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_user_fk_table)= false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_user_measure_table)= false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_reqid_table)=false then
    null;
  end if;
  --if EDW_OWB_COLLECTION_UTIL.drop_table(g_update_dlog_lookup_table)=false then
    --null;
  --end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_insert_ctas_table)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_stg_copy_table)=false then
    null;
  end if;
  --if EDW_OWB_COLLECTION_UTIL.drop_table(g_update_dlog_rowid_table)=false then
    --null;
  --end if;
  if g_number_drop_objects>0 then
    for i in 1..g_number_drop_objects loop
      if EDW_OWB_COLLECTION_UTIL.drop_table(g_drop_objects(i))= false then
        null;
      end if;
    end loop;
  end if;
Exception when others then
   g_status_message:=sqlerrm;
   write_to_log_file_n(g_status_message);
   g_status:=false;
End;

function get_status_message return varchar2 is
begin
  return g_status_message;
End;--function get_status_mesage return varchar2 is

function get_rows_processed return number is
begin
  return g_number_rows_processed;
End;

procedure write_to_log_file(p_message varchar2) is
begin
  EDW_OWB_COLLECTION_UTIL.write_to_log_file(p_message);
Exception when others then
  null;
End;

procedure write_to_log_file_n(p_message varchar2) is
begin
  write_to_log_file('  ');
  write_to_log_file(p_message);
Exception when others then
  null;
End;

procedure write_to_out_file(p_message varchar2) is
begin
  EDW_OWB_COLLECTION_UTIL.write_to_out_file(p_message);
Exception when others then
  null;
End;

procedure write_to_out_file_n(p_message varchar2) is
begin
  write_to_out_file('  ');
  write_to_out_file(p_message);
Exception when others then
  null;
End;

procedure write_to_debug(p_message varchar2) is
begin
  if g_debug then
    write_to_log_file(p_message);
  end if;
Exception when others then
  null;
End;

procedure write_to_debug_n(p_message varchar2) is
begin
  if g_debug then
    write_to_log_file_n(p_message);
  end if;
Exception when others then
  null;
End;

function is_parent_table(p_table varchar2) return boolean is
begin
 for i in 1..g_numberOfDimTables loop
   if g_dimTableName(i)=p_table then
     return true;
   end if;
 end loop;
  return false;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n('Exception in  is_parent_table '||sqlerrm||' '||get_time);
  return false;
End;

function report_collection_status return boolean is
l_stmt varchar2(10000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_count number;
l_collection_status varchar2(400);
l_op_code varchar2(400);
Begin
  if g_debug then
    write_to_log_file_n('In report_collection_status'||get_time);
  end if;
  write_to_log_file('The count and collection status');
  l_stmt:='select count(*), operation_code from '||g_surr_table||
      '  group by operation_code';
  open cv for l_stmt;
  loop
    fetch cv into l_count,l_op_code;
    exit when cv%notfound;
    write_to_log_file(l_count||'    '||l_op_code);
  end loop;
  close cv;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  return false;
End;

function create_error_rowid_table(p_type varchar2) return boolean is
l_stmt varchar2(4000);
Begin
  if g_debug then
    write_to_log_file_n('In create_error_table, p_type is '||p_type||get_time);
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_error_rowid_table)=false then
    write_to_log_file_n('Table '||g_error_rowid_table||' not found for dropping');
  end if;
  --4161164 : remove IOT , replace with ordinary table and index
  --l_stmt:='create table '||g_error_rowid_table||'(row_id primary key) organization index '||
  l_stmt:='create table '||g_error_rowid_table||
  ' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  ';
  if p_type='DANGLING' then
    l_stmt:=l_stmt||' as select /*+ORDERED*/ ';
  else
    l_stmt:=l_stmt||' as select ';
  end if;
  if g_parallel is not null and p_type='DUPLICATE' then
    ----tiwang fixed bug 1552771. Added */ at the end
    l_stmt:=l_stmt||' /*+PARALLEL ('||g_fstgTableName||','||g_parallel||')*/  ';
  end if;
  if p_type='DUPLICATE' then
    l_stmt:=l_stmt||g_fstgTableName||'.rowid row_id from '||g_fstgTableName||' where '||
    ' collection_status=''DUPLICATE''';
  elsif p_type='DANGLING' then
    l_stmt:=l_stmt||g_ok_rowid_table||'.row_id row_id from '||g_ok_rowid_table||
    ' where '||g_ok_rowid_table||'.status=1 '||
    ' MINUS select row_id from '||g_surr_table;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file('Created '||g_error_rowid_table||' with '||sql%rowcount||' rows '||get_time);
  end if;
  --4161164 : remove IOT , replace with ordinary table and index
  EDW_OWB_COLLECTION_UTIL.create_iot_index(g_error_rowid_table,'row_id',g_op_table_space,g_parallel);
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_error_rowid_table,instr(g_error_rowid_table,'.')+1,
  length(g_error_rowid_table)),substr(g_error_rowid_table,1,instr(g_error_rowid_table,'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  write_to_log_file('Problem stmt '||l_stmt);
  return false;
End;

function move_dangling_records_log return boolean is
l_stmt varchar2(4000);
l_stmt1 varchar2(4000);
l_count number;
l_total_count number:=0;
l_update_type varchar2(400);
l_rowid rowid;
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  if g_debug then
    write_to_log_file_n('In move_dangling_records_log'||get_time);
  end if;
  if update_stg_status_column(g_error_rowid_table,'row_id',null,'DANGLING',false)=false then
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  return false;
End;

function calc_rows_processed_errors return boolean is
Begin
  if g_debug then
    write_to_debug_n('In calc_rows_processed_errors'||get_time);
  end if;
  g_number_rows_dangling:=g_number_rows_ready-g_surr_count;
  g_number_ins_req_coll:=1;
  g_ins_instance_name(g_number_ins_req_coll):=null;
  g_ins_request_id_table(g_number_ins_req_coll):=null;
  g_ins_rows_processed(g_number_ins_req_coll):=g_number_rows_ready;
  g_ins_rows_collected(g_number_ins_req_coll):=g_surr_count;
  g_ins_rows_dangling(g_number_ins_req_coll):=g_number_rows_dangling;--g_number_rows_ready-g_number_rows_processed;
  g_ins_rows_duplicate(g_number_ins_req_coll):=0;
  g_ins_rows_error(g_number_ins_req_coll):=0;
  g_ins_rows_ready(g_number_ins_req_coll):=g_number_rows_ready;
  write_to_out_file('Ready     Processed    Collected   Dangling');
  for i in 1..g_number_ins_req_coll loop
    write_to_out_file(g_ins_rows_ready(i)||'     '||g_ins_rows_processed(i)||'   '||
            g_ins_rows_collected(i)||'   '||g_ins_rows_dangling(i));
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  return false;
End;

function get_rows_processed_errored
        (p_object_name out NOCOPY varchar2,
         p_object_type out NOCOPY varchar2,
         p_ins_instance_name out NOCOPY EDW_OWB_COLLECTION_UTIL.varcharTableType,
         p_ins_request_id out NOCOPY EDW_OWB_COLLECTION_UTIL.numberTableType,
         p_ins_rows_ready out NOCOPY EDW_OWB_COLLECTION_UTIL.numberTableType,
         p_ins_rows_processed out NOCOPY EDW_OWB_COLLECTION_UTIL.numberTableType,
         p_ins_rows_collected out NOCOPY EDW_OWB_COLLECTION_UTIL.numberTableType,
         p_ins_rows_dangling out NOCOPY EDW_OWB_COLLECTION_UTIL.numberTableType,
         p_ins_rows_duplicate out NOCOPY EDW_OWB_COLLECTION_UTIL.numberTableType,
         p_ins_rows_error out NOCOPY EDW_OWB_COLLECTION_UTIL.numberTableType,
         p_number_ins_req_coll out NOCOPY number) return boolean is
begin
  p_object_name:= g_fstgTableName;
  p_object_type:=g_object_type;
  p_ins_instance_name:=g_ins_instance_name;
  p_ins_request_id:=g_ins_request_id_table;
  p_ins_rows_ready:=g_ins_rows_ready;
  p_ins_rows_processed:=g_ins_rows_processed;
  p_ins_rows_collected:=g_ins_rows_collected;
  p_ins_rows_dangling:=g_ins_rows_dangling;
  p_ins_rows_duplicate:=g_ins_rows_duplicate;
  p_ins_rows_error:=g_ins_rows_error;
  p_number_ins_req_coll:=g_number_ins_req_coll;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n('Exception in  get_rows_processed_errored '||sqlerrm||' '||get_time);
  return false;
End;

/*
if the previous run had errored out, we need to recover from it
*/
function recover_from_previous_error return boolean is
l_stmt varchar2(20000);
--l_err_rec_flag boolean:=false;
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  if g_debug then
    write_to_log_file_n('In recover_from_previous_error'||get_time);
  end if;
  if g_fresh_restart then
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_ok_rowid_table)=false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_ilog_tables(g_ok_rowid_table,'OK',g_bis_owner)=false then
      return false;
    end if;
  end if;
  if EDW_OWB_COLLECTION_UTIL.check_table(g_ok_rowid_table||'A')=true
    and EDW_OWB_COLLECTION_UTIL.check_table(g_ok_rowid_table)=false then
    g_ok_rowid_table:=g_ok_rowid_table||'A';
    if g_fresh_restart then
      if EDW_OWB_COLLECTION_UTIL.drop_table(g_ok_rowid_table)=false then
        null;
      end if;
    end if;
  end if;
  if check_ok_table(g_ok_rowid_table,g_err_rec_flag,g_number_rows_ready)=false then
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  return false;
End;

function check_ok_table(
p_ok_rowid_table varchar2,
p_err_rec_flag in out nocopy boolean,
p_number_rows_ready in out nocopy number
) return boolean is
l_stmt varchar2(20000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  if g_debug then
    write_to_log_file_n('In check_ok_table');
  end if;
  if EDW_OWB_COLLECTION_UTIL.check_table(p_ok_rowid_table)=false then
    return true;
  end if;
  if EDW_OWB_COLLECTION_UTIL.does_table_have_data(p_ok_rowid_table,' status=1 ')=2 then
    p_err_rec_flag:=true;
    l_stmt:='select count(*) from '||p_ok_rowid_table||' where status=1';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt);
    end if;
    open cv for l_stmt;
    fetch cv into p_number_rows_ready;
    close cv;
    if g_debug then
      write_to_log_file('p_number_rows_ready ='||p_number_rows_ready);
    end if;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  return false;
End;

function log_duplicate_records(p_coll_status varchar2, p_dup_number number) return boolean is
l_ins_instance_name  EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_ins_request_id_table  EDW_OWB_COLLECTION_UTIL.numberTableType;
l_ins_rows_ready  EDW_OWB_COLLECTION_UTIL.numberTableType;
l_ins_rows_processed  EDW_OWB_COLLECTION_UTIL.numberTableType;
l_ins_rows_collected  EDW_OWB_COLLECTION_UTIL.numberTableType;
l_ins_rows_dangling  EDW_OWB_COLLECTION_UTIL.numberTableType;
l_ins_rows_duplicate  EDW_OWB_COLLECTION_UTIL.numberTableType;
l_ins_rows_error  EDW_OWB_COLLECTION_UTIL.numberTableType;
l_number_ins_req_coll number;
l_count   EDW_OWB_COLLECTION_UTIL.numberTableType;
Begin
  if g_debug then
    write_to_log_file_n('In log_duplicate_records, p_coll_status is '||p_coll_status||get_time);
  end if;
  if g_temp_log then
    l_number_ins_req_coll:=1;
    l_ins_instance_name(l_number_ins_req_coll):=null;
    l_ins_request_id_table(l_number_ins_req_coll):=null;
    l_ins_rows_ready(l_number_ins_req_coll):=p_dup_number;
    if p_coll_status='DUPLICATE-COLLECT' then
      l_ins_rows_processed(l_number_ins_req_coll):=p_dup_number;
      l_ins_rows_collected(l_number_ins_req_coll):=0;
      l_ins_rows_duplicate(l_number_ins_req_coll):=p_dup_number;
    else
      l_ins_rows_processed(l_number_ins_req_coll):=0;
      l_ins_rows_collected(l_number_ins_req_coll):=0;
      l_ins_rows_duplicate(l_number_ins_req_coll):=p_dup_number;
    end if;
    l_ins_rows_dangling(l_number_ins_req_coll):=0;
    l_ins_rows_error(l_number_ins_req_coll):=0;
    if EDW_OWB_COLLECTION_UTIL.insert_temp_log_table(
        g_object_name,
        g_object_type,
        g_conc_program_id,
        l_ins_instance_name,
        l_ins_request_id_table,
        l_ins_rows_ready,
        l_ins_rows_processed,
        l_ins_rows_collected,
        l_ins_rows_dangling,
        l_ins_rows_duplicate,
        l_ins_rows_error,
        g_total_records,
        g_total_insert,
        g_total_update,
        g_total_delete,
        l_number_ins_req_coll) = false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        g_status:=false;
        write_to_log_file_n(g_status_message);
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

procedure make_records_processing is
l_stmt varchar2(4000);
l_ok_rowid_table_prev varchar2(400);
Begin
  if g_debug then
    write_to_log_file_n('In make_records_processing');
  end if;
  if g_type_ok_generation='UPDATE' then
    l_stmt:='update '||g_ok_rowid_table||' set status=1 where status=0 ';
    if g_collection_size > 0 then
      l_stmt:=l_stmt||' and rownum<='||g_collection_size;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
    execute immediate l_stmt;
    g_number_rows_ready:=sql%rowcount;
    if g_debug then
      write_to_log_file_n('Updated '||g_number_rows_ready||' records from ''READY'' to ''PROCESSING'' '||get_time);
    end if;
    commit;
    if g_number_rows_ready=0 then
      g_collections_done:=true;
    end if;
  elsif g_type_ok_generation='CTAS' then
    if g_ok_rowid_table_prev is null then
      g_ok_rowid_table_prev:=g_ok_rowid_table;
      if substr(g_ok_rowid_table,length(g_ok_rowid_table),1)='A' then
        g_ok_rowid_table:=substr(g_ok_rowid_table,1,length(g_ok_rowid_table)-1);
      else
        g_ok_rowid_table:=g_ok_rowid_table||'A';
      end if;
    else
      l_ok_rowid_table_prev:=g_ok_rowid_table_prev;
      g_ok_rowid_table_prev:=g_ok_rowid_table;
      g_ok_rowid_table:=l_ok_rowid_table_prev;
    end if;
    l_stmt:='create table '||g_ok_rowid_table||' tablespace '||g_op_table_space;
    l_stmt:=l_stmt||' storage (initial 4M next 4M pctincrease 0) ';
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    if g_collection_size > 0 then
      l_stmt:=l_stmt||'  as select row_id,decode(status,1,2,2,2,decode(sign(rownum-'||
      g_collection_size||'),1,0,1)) status from (select row_id,status from '||g_ok_rowid_table_prev||
      ' order by status) abc ';
    else
      l_stmt:=l_stmt||'  as select row_id,decode(status,1,2,0,1,2) status from '||
      g_ok_rowid_table_prev;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_ok_rowid_table)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_ok_rowid_table_prev)=false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_ok_rowid_table,' status=1 ')<2 then
      g_collections_done:=true;
    end if;
    if g_debug then
      write_to_log_file_n('Time'||get_time);
    end if;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
End;


function get_time return varchar2 is
begin
 return '  '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS');
Exception when others then
  write_to_log_file_n('Exception in  get_time '||sqlerrm);
  return null;
End;

function check_total_records_to_collect return boolean is
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_last_analyzed date;
Begin
  if g_debug then
    write_to_log_file_n('In check_total_records_to_collect'||get_time);
  end if;
  --if stg never analyzed, analyze it 1%
  l_last_analyzed:=EDW_OWB_COLLECTION_UTIL.get_last_analyzed_date(g_fstgTableName,g_table_owner);
  write_to_debug_n('Last analyzed date for interface table '||l_last_analyzed);
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(g_fstgTableName,g_table_owner,1);--1%
  l_stmt:='create table '||g_reqid_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  ';
  l_stmt:=l_stmt||' as select ';
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+PARALLEL('||g_fstgTableName||','||g_parallel||')*/ ';
  end if;
  l_stmt:=l_stmt||' rowid row_id from '||g_fstgTableName||' where collection_status in (''READY'',''DANGLING'')';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_reqid_table)=false then
    null;
  end if;
  execute immediate l_stmt;
  g_total_records:=sql%rowcount;
  write_to_log_file_n('Created '||g_reqid_table||get_time);
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_reqid_table,instr(g_reqid_table,'.')+1,
  length(g_reqid_table)),substr(g_reqid_table,1,instr(g_reqid_table,'.')-1));
  if g_debug then
    write_to_log_file('Result '||g_total_records||get_time);
  end if;
  if set_stg_nl_parameters(g_total_records)=false then
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  return false;
End;

function create_dup_rownum_table(p_col varchar2) return boolean is
l_stmt varchar2(4000);
Begin
  if g_debug then
    write_to_log_file_n('In create_dup_rownum_table '||p_col||get_time);
  end if;
  --create a table to hold the pk, rowid and rownum
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dup_rownum)=false then
    null;
  end if;
  if g_parallel is null then
    l_stmt:='create table '||g_dup_rownum||' tablespace '||g_op_table_space;
  else
    l_stmt:='create table '||g_dup_rownum||' tablespace '||g_op_table_space||
    ' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select /*+ORDERED*/ ';
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+PARALLEL ('||g_fstgTableName||','||g_parallel||')*/ ';
  end if;
  if p_col='LAST_UPDATE_DATE' then
    l_stmt:=l_stmt||' lstg.'||g_fstgPKName||' '||g_fstgPKName||',lstg.rowid row_id,'||
    ' lstg.'||p_col||' col_last_update_date, rownum col_rownum from '||g_dup_hold_pk_table||' aa,'||
    g_fstgTableName||' lstg where lstg.'||g_fstgPKName||'=aa.'||g_fstgPKName;
  else
    l_stmt:=l_stmt||' lstg.'||g_fstgPKName||' '||g_fstgPKName||',lstg.rowid row_id,'||
    ' rownum col_rownum from '||g_dup_hold_pk_table||' aa,'||g_fstgTableName||' lstg where '||
    'lstg.'||g_fstgPKName||'=aa.'||g_fstgPKName;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  begin
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created '||g_dup_rownum||' with '||sql%rowcount||' rows'||get_time);
    end if;
  exception when others then
    g_status_message:=sqlerrm;
    g_status:=false;
    write_to_log_file_n(g_status_message);
    return false;
  end;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_dup_rownum,instr(g_dup_rownum,'.')+1,
  length(g_dup_rownum)),substr(g_dup_rownum,1,instr(g_dup_rownum,'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  return false;
End;

function get_number_of_duplicates return number is
Begin
  return g_dup_hold_table_number;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  return 0;
End;

/*
 0:error
 1: no need to check for dups
 2: need to check dups
*/
function check_dup_err_rec return number is
l_stmt varchar2(4000);
l_count number;
l_ok_rowid_table varchar2(80); --temp storage
l_ok_copy_rowid_table varchar2(80); --temp storage
Begin
  if g_debug then
    write_to_log_file_n('In check_dup_err_rec'||get_time);
  end if;
  /*
  make sure that l_ok_rowid_table here and create_ok_table are the same!!
  */
  l_ok_rowid_table:=g_ok_rowid_table||'T';
  l_ok_copy_rowid_table:=g_ok_rowid_table||'C';
  --we must see if we need to regenerate the table
  if regenerate_ok_table(l_ok_rowid_table,l_ok_copy_rowid_table)=false then
    return 0;
  end if;
  if EDW_OWB_COLLECTION_UTIL.check_table(g_ok_rowid_table)=false then
    return 2;
  end if;
  if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_ok_rowid_table,' status=1 ')=2 then
    g_dup_err_rec_flag:=true;
  end if;
  return 2;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  return 0;
End;

/*
error recovery
*/
function regenerate_ok_table(p_ok_rowid_table varchar2,p_ok_copy_rowid_table varchar2) return boolean is
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_var number:=null;
Begin
  if g_debug then
    write_to_log_file_n('In regenerate_ok_table'||get_time);
  end if;
  l_stmt:='select 1 from edw_coll_progress_log where object_name=:a and object_type=:b';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using '||g_ok_rowid_table||',OK_ROWID');
  end if;
  open cv for l_stmt using g_ok_rowid_table,'OK_ROWID';
  fetch cv into l_var;
  close cv;
  if l_var=1 then
    --need to regenerate
    if g_debug then
      write_to_log_file_n('Need to regenerate the table');
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_ok_rowid_table)=false then
      null;
    end if;
    --first see if the tables exist. if not, start afresh
    if EDW_OWB_COLLECTION_UTIL.check_table(p_ok_copy_rowid_table)=true and
      EDW_OWB_COLLECTION_UTIL.check_table(p_ok_rowid_table)=true then
      --analyze the tables just in case
      EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(p_ok_copy_rowid_table,instr(p_ok_copy_rowid_table,'.')+1,
      length(p_ok_copy_rowid_table)),substr(p_ok_copy_rowid_table,1,instr(p_ok_copy_rowid_table,'.')-1));
      EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(p_ok_rowid_table,instr(p_ok_rowid_table,'.')+1,
      length(p_ok_rowid_table)),substr(p_ok_rowid_table,1,instr(p_ok_rowid_table,'.')-1));
      l_stmt:='create table '||g_ok_rowid_table||' tablespace '||g_op_table_space;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||' as select c.row_id ,c.status from '||p_ok_copy_rowid_table||' c,'||
                  p_ok_rowid_table||' a where c.row_id=a.row_id';
      if g_debug then
        write_to_log_file_n('Going to execute '||l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Regenerated '||g_ok_rowid_table||' with '||sql%rowcount||' rows'||get_time);
      end if;
      EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_ok_rowid_table,instr(g_ok_rowid_table,'.')+1,
      length(g_ok_rowid_table)),substr(g_ok_rowid_table,1,instr(g_ok_rowid_table,'.')-1));
      if EDW_OWB_COLLECTION_UTIL.drop_table(p_ok_copy_rowid_table)=false then
        null;
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(p_ok_rowid_table)=false then
        null;
      end if;
    else
      if g_debug then
        write_to_log_file_n(p_ok_copy_rowid_table||' or '||p_ok_rowid_table||' does not exist for recovery');
      end if;
    end if;
    l_stmt:='delete edw_coll_progress_log where object_name=:a and object_type=:b';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
    execute immediate l_stmt  using g_ok_rowid_table,'OK_ROWID';
    commit;
  else
    if g_debug then
      write_to_log_file_n('NO Need to regenerate the table');
    end if;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  return false;
End;


--create the ok table
/*
p_status = 1 there are no duplicates
2 there are duplicates
*/
function create_ok_table(p_status number) return boolean is
l_stmt varchar2(10000);
l_found boolean:=false;
l_ok_rowid_table varchar2(400); --temp storage
l_ok_copy_rowid_table varchar2(400); --temp storage
l_ok_rowid_table_el varchar2(400);
l_base_count number;
l_insert_count number;
begin
  --g_ok_rowid_table
  if g_debug then
    write_to_log_file_n('In create_ok_table'||get_time);
  end if;
  l_base_count:=0;
  l_insert_count:=0;
  l_ok_rowid_table:=g_ok_rowid_table||'T';
  l_ok_copy_rowid_table:=g_ok_rowid_table||'C';
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_ok_rowid_table)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_ok_copy_rowid_table)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.check_table(g_ok_rowid_table)=true then
    l_found:=true;
  end if;
  if l_found=false then
    l_stmt:='create table '||g_ok_rowid_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||' as select ';
    l_stmt:=l_stmt||' row_id , 0 status from '||g_reqid_table;
    if p_status <> 1 then
      l_stmt:=l_stmt||' MINUS select row_id , 0  status from '||g_dup_hold_table;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    g_ok_rowid_number:=sql%rowcount;
    commit;
    if g_debug then
      write_to_log_file_n('Created '||g_ok_rowid_table||' with '||g_ok_rowid_number||' rows'||get_time);
    end if;
  else --error recovery
    --eliminate those rowids that are no more present in the staging table
    if substr(g_ok_rowid_table,length(g_ok_rowid_table),1)='A' then
      l_ok_rowid_table_el:=substr(g_ok_rowid_table,1,length(g_ok_rowid_table)-1);
    else
      l_ok_rowid_table_el:=g_ok_rowid_table||'A';
    end if;
    l_stmt:='create table '||l_ok_rowid_table_el||' tablespace '||g_op_table_space;
    l_stmt:=l_stmt||' storage (initial 4M next 4M pctincrease 0) ';
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  as select A.row_id,A.status from '||g_ok_rowid_table||' A,'||g_reqid_table||' B '||
    ' where A.row_id=B.row_id';
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_ok_rowid_table_el)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    l_base_count:=sql%rowcount;
    if g_debug then
      write_to_log_file_n('Created '||l_ok_rowid_table_el||' with '||l_base_count||' rows'||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_ok_rowid_table_el,instr(l_ok_rowid_table_el,'.')+1,
    length(l_ok_rowid_table_el)),substr(l_ok_rowid_table_el,1,instr(l_ok_rowid_table_el,'.')-1));
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_ok_rowid_table)=false then
      null;
    end if;
    g_ok_rowid_table:=l_ok_rowid_table_el;
    l_stmt:='create table '||l_ok_rowid_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  ';
    l_stmt:=l_stmt||' as select ';
    l_stmt:=l_stmt||' row_id row_id from '||g_reqid_table;
    l_stmt:=l_stmt||' MINUS select row_id row_id from '||g_ok_rowid_table;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created '||l_ok_rowid_table||' with '||sql%rowcount||' rows'||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_ok_rowid_table,instr(l_ok_rowid_table,'.')+1,
      length(l_ok_rowid_table)),substr(l_ok_rowid_table,1,instr(l_ok_rowid_table,'.')-1));
    if p_status = 1 then --there are no duplicates
      l_stmt:='insert into '||g_ok_rowid_table||'(row_id, status) ';
      l_stmt:=l_stmt||' select ';
      l_stmt:=l_stmt||' row_id,0 from '||l_ok_rowid_table;
      if g_debug then
        write_to_log_file_n('Going to execute '||l_stmt||get_time);
      end if;
      EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
      execute immediate l_stmt;
      l_insert_count:=sql%rowcount;
      g_ok_rowid_number:=l_base_count+l_insert_count;
      commit;
      if g_debug then
        write_to_log_file_n('Inserted '||l_insert_count||' rows into '||g_ok_rowid_table||get_time);
        write_to_log_file('g_ok_rowid_number='||g_ok_rowid_number);
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_ok_rowid_table)=false then
        null;
      end if;
    else --there are duplicates
      l_stmt:='create table '||l_ok_copy_rowid_table||' tablespace '||g_op_table_space;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  ';
      l_stmt:=l_stmt||' as select row_id row_id, status status from '||g_ok_rowid_table||
      ' UNION ALL select row_id row_id,0 status from '||l_ok_rowid_table;
      if g_debug then
        write_to_log_file_n('Going to execute '||l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Created '||l_ok_copy_rowid_table||' with '||sql%rowcount||' rows'||get_time);
      end if;
      EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_ok_copy_rowid_table,instr(l_ok_copy_rowid_table,'.')+1,
        length(l_ok_copy_rowid_table)),substr(l_ok_copy_rowid_table,1,instr(l_ok_copy_rowid_table,'.')-1));
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_ok_rowid_table)=false then
        null;
      end if;
      l_stmt:='create table '||l_ok_rowid_table||' tablespace '||g_op_table_space;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  ';
      l_stmt:=l_stmt||' as select row_id from '||l_ok_copy_rowid_table||
              ' MINUS select row_id from '||g_dup_hold_table;
      if g_debug then
        write_to_log_file_n('Going to execute '||l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Created '||l_ok_rowid_table||' with '||sql%rowcount||' rows'||get_time);
      end if;
      EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_ok_rowid_table,instr(l_ok_rowid_table,'.')+1,
      length(l_ok_rowid_table)),substr(l_ok_rowid_table,1,instr(l_ok_rowid_table,'.')-1));
      if EDW_OWB_COLLECTION_UTIL.drop_table(g_ok_rowid_table)=false then
        null;
      end if;
      begin
        l_stmt:='create table '||g_ok_rowid_table||' tablespace '||g_op_table_space;
        if g_parallel is not null then
          l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
        end if;
        l_stmt:=l_stmt||' as select c.row_id ,c.status  from '||l_ok_copy_rowid_table||' c,'||
        l_ok_rowid_table||' a where c.row_id=a.row_id';
        if g_debug then
          write_to_log_file_n('Going to execute '||l_stmt||get_time);
        end if;
        execute immediate l_stmt;
        g_ok_rowid_number:=sql%rowcount;
        if g_debug then
          write_to_log_file_n('Created '||g_ok_rowid_table||' with '||g_ok_rowid_number||' rows'||get_time);
        end if;
      exception when others then
        /*
        if there is any problem creating the table then we need to log that and be able to re generate the
        g_ok_rowid_number for the next run
        we must not drop l_ok_rowid_table,l_ok_copy_rowid_table. they will be user for recovery
        */
        if EDW_OWB_COLLECTION_UTIL.insert_into_coll_progress(g_ok_rowid_table,'OK_ROWID',null,null)=false then
          null;
        end if;
        commit;
        g_status_message:=sqlerrm;
        g_status:=false;
        write_to_log_file_n(g_status_message);
        return false;
      end;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_ok_rowid_table)=false then
        null;
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_ok_copy_rowid_table)=false then
        null;
      end if;
    end if;--if p_status <> 1 then
  end if;--l_found=false then
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_ok_rowid_table,instr(g_ok_rowid_table,'.')+1,
  length(g_ok_rowid_table)),substr(g_ok_rowid_table,1,instr(g_ok_rowid_table,'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  return false;
End;


/*
0 : error
1: no dups
2: dups are there
*/
function move_dup_rowid_table return number is
l_stmt varchar2(4000);
l_col varchar2(400);--what col to use. last update date or rownum
l_col_use varchar2(80);
l_index EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_ind_col EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_index number;
l_fstg_index varchar2(400);
l_index_index number;
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_count number;
l_use_rownum_flag boolean:=false;
l_dup_rownum_rowid_count number;
l_dup_rownum_count number;
Begin
  if g_debug then
    write_to_log_file_n('In move_dup_rowid_table'||get_time);
  end if;
  g_dup_hold_table_number:=0;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dup_hold_pk_table) = false then
    null;
  end if;
  l_stmt:='create table '||g_dup_hold_pk_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  ';
  l_stmt:=l_stmt||' as select /*+ORDERED*/ ';
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+PARALLEL ('||g_fstgTableName||','||g_parallel||')*/ ';
  end if;
  l_stmt:=l_stmt||g_fstgPKName||' from '||g_reqid_table||','||g_fstgTableName||' where '||
  g_fstgTableName||'.rowid='||g_reqid_table||'.row_id '||
  ' having count('||g_fstgPKName||') > 1 group by '||g_fstgPKName;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  begin
    execute immediate l_stmt;
    l_count:=sql%rowcount;
    if g_debug then
      write_to_log_file_n('Created '||g_dup_hold_pk_table||' with '||l_count||' rows'||get_time);
    end if;
    if l_count = 0 then
      if g_debug then
        write_to_log_file_n('There are no duplicate records ');
      end if;
      return 1;
    end if;
  exception when others then
    g_status_message:=sqlerrm;
    g_status:=false;
    write_to_log_file_n(g_status_message);
    return 0;
  end ;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_dup_hold_pk_table,instr(g_dup_hold_pk_table,'.')+1,
      length(g_dup_hold_pk_table)),substr(g_dup_hold_pk_table,1,instr(g_dup_hold_pk_table,'.')-1));
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dup_hold_table) = false then
    write_to_log_file_n('Table '||g_dup_hold_table||' not found for dropping');
  end if;
  if g_duplicate_collect then
    if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_fstgTableName,'LAST_UPDATE_DATE IS NOT NULL')=2 then
      l_col:='LAST_UPDATE_DATE';
      l_col_use:='COL_LAST_UPDATE_DATE';
      l_use_rownum_flag:=false;
    else
      l_col:='ROWNUM';
      l_col_use:='COL_ROWNUM';
      l_use_rownum_flag:=true;
    end if;
    if create_dup_rownum_table(l_col)=false then
      return 0;
    end if;
    if l_col='LAST_UPDATE_DATE' then
      declare
        l_res number:=null;
      begin
        l_stmt:='select 1 from '||g_dup_rownum||' having count(*)>1 group by '||l_col_use||','||g_fstgPKName;
        if g_debug then
          write_to_log_file_n('Going to execute '||l_stmt||get_time);
          write_to_log_file('Col is last_update_date');
        end if;
        open cv for l_stmt;
        fetch cv into l_res;
        if g_debug then
          write_to_log_file_n(get_time);
        end if;
        close cv;
        if l_res=1 then
          if g_debug then
            write_to_log_file_n('Last_update_date repeats for same PK. Going to try ROWNUM');
          end if;
          l_use_rownum_flag:=true;
        end if;
      end;
      if l_use_rownum_flag then
        l_col_use:='COL_ROWNUM';
      end if;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_dup_rownum_rowid)=false then
      null;
    end if;
    l_stmt:='create table '||g_dup_rownum_rowid||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||' as select max('||l_col_use||') col,'||g_fstgPKName||' from '||
    g_dup_rownum||' group by '||g_fstgPKName;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    begin
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Created '||g_dup_rownum_rowid||' with '||sql%rowcount||' rows'||get_time);
      end if;
    exception when others then
      g_status_message:=sqlerrm;
      g_status:=false;
      write_to_log_file_n(g_status_message);
      return 0;
    end;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_dup_rownum_rowid,instr(g_dup_rownum_rowid,'.')+1,
    length(g_dup_rownum_rowid)),substr(g_dup_rownum_rowid,1,instr(g_dup_rownum_rowid,'.')-1));
  end if;--if g_duplicate_collect
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dup_hold_table)=false then
    null;
  end if;
  --need to multi thread this section
  --first see if multi threading is reqd
  l_dup_rownum_rowid_count:=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_dup_rownum_rowid,g_bis_owner);
  l_dup_rownum_count:=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_dup_rownum,g_bis_owner);
  if g_debug then
    write_to_log_file_n('l_dup_rownum_count='||l_dup_rownum_count||',l_dup_rownum_rowid_count='||
    l_dup_rownum_rowid_count||',g_min_job_load_size='||g_min_job_load_size);
  end if;
  g_dup_multi_thread_flag:=false;
  if g_max_threads>1 then
    if (l_dup_rownum_count-l_dup_rownum_rowid_count)>= 2*g_min_job_load_size then
      g_dup_multi_thread_flag:=true;
      if g_debug then
        write_to_log_file_n('g_dup_multi_thread_flag made true');
      end if;
    end if;
  end if;
  if g_dup_multi_thread_flag then
    l_stmt:='create table '||g_dup_hold_table||' tablespace '||g_op_table_space;
  else
    --4161164 : remove IOT , replace with ordinary table and index
    --l_stmt:='create table '||g_dup_hold_table||'(row_id primary key) organization index '||
    l_stmt:='create table '||g_dup_hold_table||
    ' tablespace '||g_op_table_space;
  end if;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select ';
  if g_duplicate_collect then
    l_stmt:=l_stmt||' row_id from '||g_dup_rownum||' MINUS select /*+ORDERED*/ row_id from '||
    g_dup_rownum_rowid||','||g_dup_rownum||' where '||g_dup_rownum||'.'||l_col_use||'='||
    g_dup_rownum_rowid||'.col and '||g_dup_rownum||'.'||g_fstgPKName||'='||g_dup_rownum_rowid||'.'||g_fstgPKName;
  else
    l_stmt:=l_stmt||'/*+ORDERED*/ ';
    if g_parallel is not null then
      l_stmt:=l_stmt||' /*+PARALLEL ('||g_fstgTableName||','||g_parallel||')*/ ';
    end if;
    l_stmt:=l_stmt||g_fstgTableName||'.rowid row_id from '||g_dup_hold_pk_table||','||g_fstgTableName||
    ' where '||g_fstgTableName||'.'||g_fstgPKName||'='||g_dup_hold_pk_table||'.'||g_fstgPKName;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  begin
    execute immediate l_stmt;
    g_dup_hold_table_number:=sql%rowcount;
  exception when others then
    g_status_message:=sqlerrm;
    g_status:=false;
    write_to_log_file_n(g_status_message);
    return 0;
  end ;
  --4161164 : remove IOT , replace with ordinary table and index
  if g_dup_multi_thread_flag=false then
    EDW_OWB_COLLECTION_UTIL.create_iot_index(g_dup_hold_table,'row_id',g_op_table_space,g_parallel);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_dup_hold_table,instr(g_dup_hold_table,'.')+1,
  length(g_dup_hold_table)),substr(g_dup_hold_table,1,instr(g_dup_hold_table,'.')-1));
  if g_dup_hold_table_number=0 then
    l_stmt:='select count(*) from '||g_dup_hold_table;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    open cv for l_stmt;
    fetch cv into g_dup_hold_table_number;
    close cv;
  end if;
  if g_debug then
    write_to_log_file_n('Created '||g_dup_hold_table||' with '||g_dup_hold_table_number||' rows'||get_time);
  end if;
  return 2;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  return 0;
End;

function create_opcode_table return boolean is
l_stmt varchar2(10000);
l_opcode_table varchar2(400);
l_table varchar2(400);
l_index_found boolean;
l_index EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_ind_col EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_ind_col_pos EDW_OWB_COLLECTION_UTIL.numberTableType;
l_number_index number;
l_table1 varchar2(400);
l_table2 varchar2(400);
l_max_pkkey_value number;
Begin
  if g_debug then
    write_to_log_file_n('In create_opcode_table'||get_time);
  end if;
  l_opcode_table:=g_opcode_table||'T';
  l_table:=g_opcode_table||'TA';
  l_table1:=l_opcode_table||'1';
  l_table2:=l_opcode_table||'2';
  g_fact_count:=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_FactTableName,g_table_owner);
  if g_stg_copy_table_flag=false and g_use_mti=false then
    l_stmt:='create table '||l_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  as select row_id from '||g_ok_rowid_table||' where status=1';
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_table)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_type_ok_generation='CTAS' then
      g_number_rows_ready:=sql%rowcount;
    end if;
    if g_debug then
      write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_table,instr(l_table,'.')+1,
    length(l_table)),substr(l_table,1,instr(l_table,'.')-1));
  end if;
  g_fact_use_nl:=EDW_OWB_COLLECTION_UTIL.get_join_nl(g_number_rows_ready,g_fact_count,g_stg_join_nl_percentage);
  l_stmt:='create table '||l_opcode_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select ';
  if g_stg_copy_table_flag=false and g_use_mti=false then
    if g_stg_join_nl then
      l_stmt:=l_stmt||' /*+ORDERED USE_NL('||g_fstgTableName||')*/ ';
    else
      l_stmt:=l_stmt||' /*+ORDERED*/ ';
    end if;
    if g_parallel is not null then
      l_stmt:=l_stmt||' /*+PARALLEL ('||g_fstgTableName||','||g_parallel||')*/ ';
    end if;
  else
    l_stmt:=l_stmt||' /*+ORDERED*/ ';
  end if;
  l_stmt:=l_stmt||g_fstgTableName||'.'||g_fstgPKName||' '||g_fstgPKName||',';
  if g_pk_key_seq is null then
    l_stmt:=l_stmt||g_fstgTableName||'.'||g_fstgPKNameKey||' '||g_fstgPKNameKey||',';
  end if;
  if g_stg_copy_table_flag or g_use_mti then
    --row_id is the original rowid of the staging table
    --g_fstgTableName is the alias for the stg copy or user measure table
    l_stmt:=l_stmt||g_fstgTableName||'.row_id row_id,'||g_fstgTableName||'.rowid row_id_copy, ';
  else
    l_stmt:=l_stmt||g_fstgTableName||'.rowid row_id,';
  end if;
  l_stmt:=l_stmt||g_fstgTableName||'.operation_code ';
  if g_stg_copy_table_flag then
    l_stmt:=l_stmt||' from '||g_stg_copy_table||' '||g_fstgTableName;
  elsif g_use_mti then
    l_stmt:=l_stmt||' from '||g_user_measure_table||' '||g_fstgTableName;
  else
    l_stmt:=l_stmt||' from '||l_table||','||g_fstgTableName;
    l_stmt:=l_stmt||' where '||l_table||'.row_id='||g_fstgTableName||'.rowid';
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_opcode_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created '||l_opcode_table||' with '||sql%rowcount||' rows '||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_opcode_table,instr(l_opcode_table,'.')+1,
  length(l_opcode_table)),substr(l_opcode_table,1,instr(l_opcode_table,'.')-1));
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table)=false then
    null;
  end if;
  l_index_found:=false;
  if EDW_OWB_COLLECTION_UTIL.get_table_index_col(g_FactTableName,g_table_owner,l_index,l_ind_col,
    l_ind_col_pos,l_number_index)=true then
    for i in 1..l_number_index loop
      if l_ind_col(i)=g_factPKName then
        if l_ind_col_pos(i)=1 then
          l_index_found:=true;
        end if;
      end if;
      if l_index_found then
        exit;
      end if;
    end loop;
  end if;
  if g_load_type<>'INITIAL' and g_pk_key_seq is not null then
    l_stmt:='create table '||l_table1||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  ';
    if l_index_found and g_fact_use_nl then
      l_stmt:=l_stmt||' as select /*+ORDERED USE_NL('||g_FactTableName||')*/ ';
    else
      l_stmt:=l_stmt||' as select /*+ORDERED*/ ';
    end if;
    if g_parallel is not null then
      l_stmt:=l_stmt||' /*+PARALLEL('||g_FactTableName||','||g_parallel||')*/ ';
    end if;
    --op code of 0=insert 1=update and 2=delete
    l_stmt:=l_stmt||l_opcode_table||'.rowid row_id, '||g_FactTableName||'.rowid row_id1 ';
    if g_fact_audit or g_fact_net_change or g_update_type='DELETE-INSERT' then
      l_stmt:=l_stmt||','||g_FactTableName||'.'||g_factPKNameKey||' '||g_fstgPKNameKey;
    end if;
    if g_update_type='DELETE-INSERT' then
      l_stmt:=l_stmt||','||g_FactTableName||'.'||g_factPKName||' '||g_fstgPKName;
      l_stmt:=l_stmt||','||g_FactTableName||'.CREATION_DATE CREATION_DATE';
    end if;
    l_stmt:=l_stmt||' from '||l_opcode_table||','||g_FactTableName||' where '||
    g_FactTableName||'.'||g_factPKName||'(+)='||l_opcode_table||'.'||g_fstgPKName;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_table1)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created '||l_table1||' with '||sql%rowcount||' rows '||get_time);
    end if;
    l_stmt:='create table '||l_table2||' tablespace '||g_op_table_space;
    if g_rownum_for_seq_num is not null and g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  as select row_id,row_id1,';
    if g_rownum_for_seq_num is not null then
      l_stmt:=l_stmt||'decode(row_id1,null,'||g_rownum_for_seq_num||'+rownum,0) '||g_fstgPKNameKey;
    else
      l_stmt:=l_stmt||'decode(row_id1,null,'||g_pk_key_seq||'.NEXTVAL,0) '||g_fstgPKNameKey;
    end if;
    if g_update_type='DELETE-INSERT' then
      l_stmt:=l_stmt||','||g_fstgPKName||',CREATION_DATE';
    end if;
    l_stmt:=l_stmt||' from '||l_table1;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_table2)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created '||l_table2||' with '||sql%rowcount||' rows '||get_time);
    end if;
    if g_rownum_for_seq_num is null and g_parallel is not null then
      l_stmt:='alter table '||l_table2||' parallel (degree '||g_parallel||')';
      if g_debug then
        write_to_log_file_n('Going to execute '||l_stmt||get_time);
      end if;
      execute immediate l_stmt;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_table1)=false then
      null;
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_table2,instr(l_table2,'.')+1,
    length(l_table2)),substr(l_table2,1,instr(l_table2,'.')-1));
    --may need to update the main seq
    --g_rownum_for_seq_num is passed for multi threading case
    --for single thread this may be null
    if g_rownum_for_seq_num is not null then
      l_max_pkkey_value:=EDW_OWB_COLLECTION_UTIL.get_max_value(l_table2,g_fstgPKNameKey);
      if l_max_pkkey_value>g_rownum_for_seq_num then
        g_rownum_for_seq_num:=l_max_pkkey_value;
      end if;
    end if;
  end if;
  --in initial load, create the table in serial mode and then make it parallel
  g_opcode_stmt:='create table '||g_opcode_table||' tablespace '||g_op_table_space;
  if (g_load_type<>'INITIAL' or g_rownum_for_seq_num is not null) and g_parallel is not null then
    g_opcode_stmt:=g_opcode_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  g_opcode_stmt:=g_opcode_stmt||'  ';
  if g_load_type='INITIAL' then
    g_opcode_stmt:=g_opcode_stmt||' as select ';
    g_opcode_stmt:=g_opcode_stmt||l_opcode_table||'.row_id row_id,'||'''I'' row_id1,'||
    'decode ('||l_opcode_table||'.operation_code,''DELETE'',2,0) operation_code, ';
    if g_stg_copy_table_flag or g_use_mti then
      g_opcode_stmt:=g_opcode_stmt||l_opcode_table||'.row_id_copy row_id_copy,';
    end if;
    if g_pk_key_seq is null then
      g_opcode_stmt:=g_opcode_stmt||l_opcode_table||'.'||g_fstgPKNameKey;
    else
      if g_rownum_for_seq_num is not null then
        g_opcode_stmt:=g_opcode_stmt||' '||g_rownum_for_seq_num||'+rownum '||g_fstgPKNameKey;
      else
        g_opcode_stmt:=g_opcode_stmt||g_pk_key_seq||'.NEXTVAL '||g_fstgPKNameKey;
      end if;
    end if;
    if g_update_type='DELETE-INSERT' then
      g_opcode_stmt:=g_opcode_stmt||',0 '||g_fstgPKName;
      g_opcode_stmt:=g_opcode_stmt||',sysdate CREATION_DATE ';
    end if;
    g_opcode_stmt:=g_opcode_stmt||' from '||l_opcode_table;
  else
    if g_pk_key_seq is null then
      if l_index_found and g_fact_use_nl then
        g_opcode_stmt:=g_opcode_stmt||' as select /*+ORDERED USE_NL('||g_FactTableName||')*/ ';
      else
        g_opcode_stmt:=g_opcode_stmt||' as select /*+ORDERED*/ ';
      end if;
      if g_parallel is not null then
        g_opcode_stmt:=g_opcode_stmt||' /*+PARALLEL('||g_FactTableName||','||g_parallel||')*/ ';
      end if;
      --op code of 0=insert 1=update and 2=delete
      g_opcode_stmt:=g_opcode_stmt||l_opcode_table||'.row_id row_id, '||g_FactTableName||'.rowid row_id1, '||
      ' decode ('||l_opcode_table||'.operation_code,''DELETE'',2,decode('||
      g_FactTableName||'.rowid,null,0,1)) operation_code, ';
      --g_opcode_stmt:=g_opcode_stmt||'decode('||g_FactTableName||'.rowid,null,'||l_opcode_table||'.'||g_fstgPKNameKey||
      --','||g_FactTableName||'.'||g_factPKNameKey||') '||g_fstgPKNameKey;
      g_opcode_stmt:=g_opcode_stmt||'decode('||g_FactTableName||'.rowid,null,'||l_opcode_table||'.'||g_fstgPKNameKey||
      ',0) '||g_fstgPKNameKey;
      if g_stg_copy_table_flag or g_use_mti then
        g_opcode_stmt:=g_opcode_stmt||','||l_opcode_table||'.row_id_copy row_id_copy ';
      end if;
      if g_update_type='DELETE-INSERT' then
        g_opcode_stmt:=g_opcode_stmt||','||g_FactTableName||'.'||g_factPKName||' '||g_fstgPKName;
        g_opcode_stmt:=g_opcode_stmt||','||g_FactTableName||'.CREATION_DATE CREATION_DATE';
      end if;
      g_opcode_stmt:=g_opcode_stmt||' from '||l_opcode_table||','||g_FactTableName||' where '||
      g_FactTableName||'.'||g_factPKName||'(+)='||l_opcode_table||'.'||g_fstgPKName;
    else --if g_pk_key_seq is NOT null then
      g_opcode_stmt:=g_opcode_stmt||' as select ';
      g_opcode_stmt:=g_opcode_stmt||l_opcode_table||'.row_id row_id, '||g_FactTableName||'.row_id1 row_id1, '||
      ' decode ('||l_opcode_table||'.operation_code,''DELETE'',2,decode('||
      g_FactTableName||'.row_id1,null,0,1)) operation_code, ';
      g_opcode_stmt:=g_opcode_stmt||g_FactTableName||'.'||g_fstgPKNameKey||' '||g_fstgPKNameKey;
      if g_stg_copy_table_flag or g_use_mti then
        g_opcode_stmt:=g_opcode_stmt||','||l_opcode_table||'.row_id_copy row_id_copy ';
      end if;
      if g_update_type='DELETE-INSERT' then
        g_opcode_stmt:=g_opcode_stmt||','||g_FactTableName||'.'||g_fstgPKName||' '||g_fstgPKName;
        g_opcode_stmt:=g_opcode_stmt||','||g_FactTableName||'.CREATION_DATE CREATION_DATE';
      end if;
      g_opcode_stmt:=g_opcode_stmt||' from '||l_opcode_table||','||l_table2||' '||g_FactTableName||' where '||
      g_FactTableName||'.row_id='||l_opcode_table||'.rowid';
    end if;
  end if;--load type
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_opcode_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||g_opcode_stmt||get_time);
  end if;
  execute immediate g_opcode_stmt;
  g_opcode_table_count:=sql%rowcount;
  if g_debug then
    write_to_log_file_n('Created '||g_opcode_table||' with '||g_opcode_table_count||' rows '||get_time);
  end if;
  if g_rownum_for_seq_num is not null then
    if l_max_pkkey_value is null then
      l_max_pkkey_value:=EDW_OWB_COLLECTION_UTIL.get_max_value(g_opcode_table,g_fstgPKNameKey);
      if l_max_pkkey_value>g_rownum_for_seq_num then
        g_rownum_for_seq_num:=l_max_pkkey_value;
      end if;
    end if;
  end if;
  if g_load_type='INITIAL' and g_parallel is not null then
    l_stmt:='alter table '||g_opcode_table||' parallel (degree '||g_parallel||')';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
  end if;
  if l_max_pkkey_value is not null and g_pk_key_seq is not null then
    if EDW_OWB_COLLECTION_UTIL.create_sequence(g_pk_key_seq,null,l_max_pkkey_value,'NO FORCE')=false then
      g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
      return false;
    end if;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table2)=false then
    null;
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_opcode_table,instr(g_opcode_table,'.')+1,
  length(g_opcode_table)),substr(g_opcode_table,1,instr(g_opcode_table,'.')-1));
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_opcode_table)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  return false;
End;

/*
for data alignment
*/
function create_opcode_table(p_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,p_number_cols number)
return boolean is
l_stmt varchar2(30000);
l_opcode_table varchar2(400);
l_opcode_pk_table varchar2(400);
l_next_pk  varchar2(400);
l_stg_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_index_found boolean;
l_index EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_ind_col EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_ind_col_pos EDW_OWB_COLLECTION_UTIL.numberTableType;
l_number_index number;
l_table varchar2(400);
l_table1 varchar2(400);
l_table11 varchar2(400);
l_table2 varchar2(400);
l_table_pp varchar2(400);
l_max_pkkey_value number;
Begin
  if g_debug then
    write_to_log_file_n('In create_opcode_table'||get_time);
  end if;
  l_opcode_table:=g_opcode_table||'T';
  l_opcode_pk_table:=g_opcode_table||'P';
  l_table:=g_opcode_table||'TA';
  l_table1:=l_opcode_table||'1';
  l_table11:=l_opcode_table||'11';
  l_table_pp:=l_opcode_table||'PP';
  l_table2:=l_opcode_table||'2';
  g_fact_count:=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_FactTableName,g_table_owner);
  for i in 1..p_number_cols loop
    l_stg_cols(i):=p_cols(i);
    for j in 1..g_number_da_cols loop
      if p_cols(i)=g_da_cols(j) then
        l_stg_cols(i):=g_stg_da_cols(j);
        exit;
      end if;
    end loop;
  end loop;
  if g_stg_copy_table_flag=false and g_use_mti=false then
    l_stmt:='create table '||l_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  as select row_id from '||g_ok_rowid_table||' where status=1';
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_table)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_type_ok_generation='CTAS' then
      g_number_rows_ready:=sql%rowcount;
    end if;
    if g_debug then
      write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_table,instr(l_table,'.')+1,
    length(l_table)),substr(l_table,1,instr(l_table,'.')-1));
  end if;
  g_fact_use_nl:=EDW_OWB_COLLECTION_UTIL.get_join_nl(g_number_rows_ready,g_fact_count,g_stg_join_nl_percentage);
  l_stmt:='create table '||l_opcode_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select ';
  if g_stg_copy_table_flag=false and g_use_mti=false then
    if g_stg_join_nl then
      l_stmt:=l_stmt||' /*+ORDERED USE_NL('||g_fstgTableName||')*/ ';
    else
    l_stmt:=l_stmt||' /*+ORDERED*/ ';
    end if;
    if g_parallel is not null then
      l_stmt:=l_stmt||' /*+PARALLEL ('||g_fstgTableName||','||g_parallel||')*/ ';
    end if;
  else
    l_stmt:=l_stmt||' /*+ORDERED*/ ';
  end if;
  l_stmt:=l_stmt||g_fstgTableName||'.'||g_fstgPKName||',';
  for i in 1..p_number_cols loop
    l_stmt:=l_stmt||g_fstgTableName||'.'||l_stg_cols(i)||' '||p_cols(i)||',';
  end loop;
  if g_instance_column is not null then
    l_stmt:=l_stmt||g_fstgTableName||'.'||g_instance_column||',';--used to populate DA
  end if;
  if g_pk_key_seq is null then
    l_stmt:=l_stmt||g_fstgTableName||'.'||g_fstgPKNameKey||',';
  end if;
  if g_stg_copy_table_flag or g_use_mti then
    l_stmt:=l_stmt||g_fstgTableName||'.row_id row_id,'||g_fstgTableName||'.rowid row_id_copy,';
  else
    l_stmt:=l_stmt||g_fstgTableName||'.rowid row_id,';
  end if;
  l_stmt:=l_stmt||g_fstgTableName||'.operation_code operation_code';
  if g_stg_copy_table_flag then
    l_stmt:=l_stmt||' from '||g_stg_copy_table||' '||g_fstgTableName;
  elsif g_use_mti then
    l_stmt:=l_stmt||' from '||g_user_measure_table||' '||g_fstgTableName;
  else
    l_stmt:=l_stmt||' from '||l_table||','||g_fstgTableName;
    l_stmt:=l_stmt||' where '||l_table||'.row_id='||g_fstgTableName||'.rowid';
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_opcode_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created '||l_opcode_table||' with '||sql%rowcount||' rows '||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_opcode_table,instr(l_opcode_table,'.')+1,
  length(l_opcode_table)),substr(l_opcode_table,1,instr(l_opcode_table,'.')-1));
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table)=false then
    null;
  end if;
  if g_pk_key_seq is null then
    l_next_pk:=l_opcode_table||'.'||g_fstgPKNameKey;
  else
    if g_rownum_for_seq_num is null then
      l_next_pk:=g_pk_key_seq||'.NEXTVAL';
    else
      l_next_pk:=g_rownum_for_seq_num||'+rownum';
    end if;
  end if;
  if g_debug then
    write_to_log_file_n('l_next_pk='||l_next_pk);
  end if;
  --l_table1 and l_table2 to overcome the problem created by the parallel server with sequence in the select
  --clause
  l_stmt:='create table '||l_table11||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  ';
  l_stmt:=l_stmt||' as select /*+ORDERED*/ ';
  l_table:=substr(g_da_table,instr(g_da_table,'.')+1,length(g_da_table));
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+PARALLEL('||l_table||','||g_parallel||')*/ ';
  end if;
  l_stmt:=l_stmt||l_opcode_table||'.rowid row_id,'||l_table||'.'||g_factPKName||' '||g_factPKName||',';
  l_stmt:=l_stmt||l_table||'.'||g_factPKNameKey||' '||g_factPKNameKey||','||l_table||'.rowid row_id2 ';
  l_stmt:=l_stmt||' from '||l_opcode_table||','||g_da_table||' '||l_table||' where ';
  for i in 1..p_number_cols loop
    l_stmt:=l_stmt||l_opcode_table||'.'||p_cols(i)||'='||l_table||'.'||p_cols(i)||'(+) and ';
  end loop;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-4);
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table11)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
  end if;
  l_stmt:='create table '||l_table_pp||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  ';
  l_stmt:=l_stmt||' as select /*+ORDERED*/ ';
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+PARALLEL(PP,'||g_parallel||')*/ ';
  end if;
  l_stmt:=l_stmt||'A.rowid row_id,A.'||g_fstgPKName||' pk,B.pk_key from '||l_opcode_table||' A,'||
  g_pp_table||' B where A.'||g_fstgPKName||'=B.pk';
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table_pp)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
  end if;
  l_stmt:='create table '||l_table1||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  as select A.row_id,A.'||g_factPKName||' '||g_factPKName||'1, '||
  'decode(A.'||g_factPKNameKey||',null,B.pk_key,A.'||g_factPKNameKey||') '||g_factPKNameKey||' ,'||
  'A.row_id2 from '||l_table11||' A,'||l_table_pp||' B where A.row_id=B.row_id(+)';
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table1)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table11)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table_pp)=false then
    null;
  end if;
  l_stmt:='create table '||l_table2||' tablespace '||g_op_table_space;
  if g_rownum_for_seq_num is not null and g_parallel is not null then
    l_stmt:=l_stmt||' /*+parallel (degree '||g_parallel||')*/ ';
  end if;
  l_stmt:=l_stmt||'  as select row_id,'||g_factPKName||'1,'||
  'decode('||g_factPKNameKey||',null,'||l_next_pk||','||g_factPKNameKey||') '||g_factPKNameKey||
  ',row_id2 from '||l_table1;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table2)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
  end if;
  if g_rownum_for_seq_num is null and g_parallel is not null then
    l_stmt:='alter table '||l_table2||' parallel (degree '||g_parallel||')';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table1)=false then
    null;
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_table2,instr(l_table2,'.')+1,
  length(l_table2)),substr(l_table2,1,instr(l_table2,'.')-1));
  if g_rownum_for_seq_num is not null then
    l_max_pkkey_value:=EDW_OWB_COLLECTION_UTIL.get_max_value(l_table2,g_factPKNameKey);
    if l_max_pkkey_value>g_rownum_for_seq_num then
      g_rownum_for_seq_num:=l_max_pkkey_value;
    end if;
    if l_max_pkkey_value is not null and g_pk_key_seq is not null then
      if EDW_OWB_COLLECTION_UTIL.create_sequence(g_pk_key_seq,null,l_max_pkkey_value,'NO FORCE')=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        return false;
      end if;
    end if;
  end if;
  l_stmt:='create table '||l_opcode_pk_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  ';
  l_stmt:=l_stmt||' as select ';
  l_table:=substr(g_da_table,instr(g_da_table,'.')+1,length(g_da_table));
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+PARALLEL('||l_table||','||g_parallel||')*/ ';
  end if;
  l_stmt:=l_stmt||l_opcode_table||'.'||g_fstgPKName||',';
  for i in 1..p_number_cols loop
    l_stmt:=l_stmt||l_opcode_table||'.'||p_cols(i)||',';
  end loop;
  if g_instance_column is not null then
    l_stmt:=l_stmt||l_opcode_table||'.'||g_instance_column||',';--used to populate DA
  end if;
  l_stmt:=l_stmt||l_opcode_table||'.row_id,'||l_opcode_table||'.operation_code,';
  if g_stg_copy_table_flag or g_use_mti then
    l_stmt:=l_stmt||l_opcode_table||'.row_id_copy row_id_copy,';
  end if;
  --we get g_da_table pk and pk_key because pp table may need these
  l_stmt:=l_stmt||'decode('||l_table||'.row_id2,null,'||l_opcode_table||'.'||g_fstgPKName||','||
  l_table||'.'||g_factPKName||'1) '||g_factPKName||'1,'||l_table||'.'||g_factPKNameKey||' '||g_factPKNameKey||
  ','||l_table||'.row_id2 row_id2 from '||l_opcode_table||','||l_table2||' '||l_table||' where ';
  l_stmt:=l_stmt||l_table||'.row_id='||l_opcode_table||'.rowid';
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_opcode_pk_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created '||l_opcode_pk_table||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_opcode_pk_table,instr(l_opcode_pk_table,'.')+1,
  length(l_opcode_pk_table)),substr(l_opcode_pk_table,1,instr(l_opcode_pk_table,'.')-1));
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table2)=false then
    null;
  end if;
  --the pk_key is decided by joining to the da table and not target table
  --but op code needs to look at the target table
  l_index_found:=false;
  if EDW_OWB_COLLECTION_UTIL.get_table_index_col(g_FactTableName,g_table_owner,l_index,l_ind_col,
    l_ind_col_pos,l_number_index)=true then
    for i in 1..l_number_index loop
      if l_ind_col(i)=g_factPKName then
        if l_ind_col_pos(i)=1 then
          l_index_found:=true;
        end if;
      end if;
      if l_index_found then
        exit;
      end if;
    end loop;
  end if;
  l_stmt:='create table '||g_opcode_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  ';
  if l_index_found and g_fact_use_nl then
    l_stmt:=l_stmt||' as select /*+ORDERED USE_NL('||g_FactTableName||')*/ ';
  else
    l_stmt:=l_stmt||' as select /*+ORDERED*/ ';
  end if;
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+PARALLEL('||g_FactTableName||','||g_parallel||')*/ ';
  end if;
  --op code of 0=insert 1=update and 2=delete
  l_stmt:=l_stmt||l_opcode_pk_table||'.row_id row_id, '||g_FactTableName||'.rowid row_id1, '||
  ' decode ('||l_opcode_pk_table||'.operation_code,''DELETE'',2,decode('||
  g_FactTableName||'.rowid,null,0,1)) operation_code, ';
  l_stmt:=l_stmt||l_opcode_pk_table||'.'||g_factPKNameKey||' '||g_fstgPKNameKey;
  if g_update_type='DELETE-INSERT' then
    l_stmt:=l_stmt||','||g_FactTableName||'.'||g_factPKName||' '||g_fstgPKName;
    l_stmt:=l_stmt||','||g_FactTableName||'.CREATION_DATE CREATION_DATE';
  end if;
  l_stmt:=l_stmt||' from '||l_opcode_pk_table||','||g_FactTableName||' where '||
  g_FactTableName||'.'||g_factPKNameKey||'(+)='||l_opcode_pk_table||'.'||g_factPKNameKey;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_opcode_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  g_opcode_table_count:=sql%rowcount;
  if g_debug then
    write_to_log_file_n('Created '||g_opcode_table||' with '||g_opcode_table_count||' rows '||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_opcode_table,instr(g_opcode_table,'.')+1,
  length(g_opcode_table)),substr(g_opcode_table,1,instr(g_opcode_table,'.')-1));
  if sync_da_pp_tables(l_opcode_pk_table)=false then
    return false;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_opcode_table)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_opcode_pk_table)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  return false;
End;

function drop_opcode_table return boolean is
l_stmt varchar2(2000);
Begin
  if g_debug then
    write_to_log_file_n('In drop_opcode_table'||get_time);
  end if;
  l_stmt:='drop table '||g_opcode_table;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  execute immediate l_stmt;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  return false;
End;

function update_ok_status_2 return boolean is
l_stmt varchar2(2000);
Begin
  l_stmt:='update '||g_ok_rowid_table||' set status=2 where status=1';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Updated '||sql%rowcount||' rows from status 1 to 2'||get_time);
  end if;
  commit;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  return false;
End;

function create_plan_table return boolean is
l_stmt varchar2(4000);
Begin
l_stmt:='CREATE TABLE '||g_plan_table||' ( '||
'STATEMENT_ID    VARCHAR2(30), '||
'TIMESTAMP       DATE, '||
'REMARKS         VARCHAR2(80), '||
'OPERATION       VARCHAR2(30), '||
'OPTIONS         VARCHAR2(30), '||
'OBJECT_NODE     VARCHAR2(128), '||
'OBJECT_OWNER    VARCHAR2(30), '||
'OBJECT_NAME     VARCHAR2(30), '||
'OBJECT_INSTANCE NUMERIC, '||
'OBJECT_TYPE     VARCHAR2(30), '||
'OPTIMIZER       VARCHAR2(255), '||
'SEARCH_COLUMNS  NUMBER, '||
'ID              NUMERIC, '||
'PARENT_ID       NUMERIC, '||
'POSITION        NUMERIC, '||
'COST            NUMERIC, '||
'CARDINALITY     NUMERIC, '||
'BYTES           NUMERIC, '||
'OTHER_TAG       VARCHAR2(255), '||
'PARTITION_START VARCHAR2(255), '||
'PARTITION_STOP  VARCHAR2(255), '||
'PARTITION_ID    NUMERIC, '||
'OTHER           LONG, '||
'DISTRIBUTION    VARCHAR2(30)) '||' tablespace '||g_op_table_space;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  execute immediate l_stmt;
  return true;
Exception when others then
  write_to_log_file_n('Error in create_plan_table '||sqlerrm);
  write_to_log_file('problem stmt '||l_stmt);
  return false;
End;

function generate_explain_plan(p_stmt varchar2) return boolean is
l_stmt varchar2(20000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  if g_debug then
    write_to_log_file_n('In generate_explain_plan'||get_time);
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_plan_table)=false then
    null;
  end if;
  if create_plan_table = false then
    write_to_log_file_n('could not create '||g_plan_table);
    return false;
  end if;
  l_stmt:='explain plan into '||g_plan_table||' for '||p_stmt;
  if g_debug then
    write_to_log_file_n('Going to generate explain plan for '||l_stmt||get_time);
  end if;
  begin
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Generated explain plan '||get_time);
    end if;
  exception when others then
    write_to_log_file_n('check explain plan had errors '||sqlerrm);
    write_to_log_file('problem stmt '||l_stmt);
    return false;
  end ;
  l_stmt:='select operation,options, object_name,cardinality from '||g_plan_table;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  g_number_exp_plan:=1;
  open cv for l_stmt;
  loop
    fetch cv into g_exp_operation(g_number_exp_plan),g_exp_options(g_number_exp_plan),
      g_exp_object_name(g_number_exp_plan),g_exp_cardinality(g_number_exp_plan);
    exit when cv%notfound;
    g_number_exp_plan:=g_number_exp_plan+1;
  end loop;
  g_number_exp_plan:=g_number_exp_plan-1;
  close cv;
  return true;
Exception when others then
  write_to_log_file_n('Error in generate_explain_plan '||sqlerrm);
  return false;
End;

function check_explain_plan return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In check_explain_plan'||get_time);
  end if;
  g_number_fts_tables:=0;
  for i in 1..g_number_exp_plan loop
    if g_exp_object_name(i) <> g_fstgTableName then
      if g_exp_operation(i)='TABLE ACCESS' and g_exp_options(i)='FULL' and g_exp_cardinality(i) > 1000 then
        if EDW_OWB_COLLECTION_UTIL.value_in_table(g_slow_change_tables,
          g_num_slow_change_tables,g_exp_object_name(i))=false then
          if EDW_OWB_COLLECTION_UTIL.value_in_table(g_fts_tables,
            g_number_fts_tables,g_exp_object_name(i))=false then
            g_number_fts_tables:=g_number_fts_tables+1;
            g_fts_tables(g_number_fts_tables):=g_exp_object_name(i);
          end if;
        end if;
      end if;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('The tables undergoing full table scan');
    for i in 1..g_number_fts_tables loop
      write_to_log_file(g_fts_tables(i));
    end loop;
  end if;
  if g_number_fts_tables > 0 then
    return true;
  else
    return false;
  end if;
Exception when others then
  write_to_log_file_n('Error in check_explain_plan '||sqlerrm);
  return false;
End;

/*
if there are full table scans, generate lookup tables
here we are not worried about direct load of key or now because the explain plan stmt
contains only the keys that are to be looked up
*/
function generate_fts_lookups return boolean is
l_stmt varchar2(20000);
l_kl_list_name  EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_i_index  EDW_OWB_COLLECTION_UTIL.numberTableType;
l_ok EDW_OWB_COLLECTION_UTIL.booleanTableType;
Begin
  for i in 1..g_number_fts_tables loop
    l_kl_list_name(i):=g_bis_owner||'.FTS_'||g_primary_target||'_'||g_job_id||'_DL'||i;
  end loop;
  for i in 1..g_numberOfDimTables loop
    for j in 1..g_number_fts_tables loop
      if g_dimTableName_kl(i)=g_fts_tables(j) then
        l_i_index(j):=i;
        exit;
      end if;
    end loop;
  end loop;
  if g_debug then
    write_to_log_file_n('The dimensions and the lookups  user pk and   surr pk ');
    for i in 1..g_number_fts_tables loop
      write_to_log_file(g_dimTableName(l_i_index(i))||'('||l_kl_list_name(i)||')  '||
         g_dimUserPKName(l_i_index(i))||'('||g_dimActualPKName(l_i_index(i))||')');
    end loop;
  end if;
  for i in 1..g_number_fts_tables loop
    if EDW_OWB_COLLECTION_UTIL.create_dim_key_lookup(g_fts_tables(i),g_dimUserPKName(l_i_index(i)),
               g_dimActualPKName(l_i_index(i)),l_kl_list_name(i),g_parallel,null,g_op_table_space) = false then
      write_to_log_file_n('EDW_OWB_COLLECTION_UTIL.create_dim_key_lookup failed for '||g_fts_tables(i));
      l_ok(i):=false;
    else
      EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_kl_list_name(i),instr(l_kl_list_name(i),'.')+1,
        length(l_kl_list_name(i))),substr(l_kl_list_name(i),1,instr(l_kl_list_name(i),'.')-1));
      l_ok(i):=true;
      write_to_log_file_n('Lookup '||l_kl_list_name(i)||' generated for '||g_fts_tables(i));
    end if;
  end loop;
  for i in 1..g_numberOfDimTables loop
    for j in 1..g_number_fts_tables loop
      if g_dimTableName_kl(i)=g_fts_tables(j) then
        if l_ok(j) then
          g_number_drop_objects:=g_number_drop_objects+1;
          g_drop_objects(g_number_drop_objects):=l_kl_list_name(j);--will need to drop this guy...
          g_dimTableName_kl(i):=l_kl_list_name(j);
        end if;
        exit;
      end if;
    end loop;
  end loop;
  return true;
Exception when others then
  write_to_log_file_n('Error in generate_fts_lookups '||sqlerrm);
  return false;
End;

function create_surr_tables return boolean is
l_count number:=0;
l_stmt varchar2(30000);
l_start number:=1;
l_end number;
l_found boolean;
l_user_fk_table varchar2(400);--to improve perf
l_user_fk_table_flag boolean;
l_alias EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_pk  EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_pk_key  EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_owner varchar2(200);
l_index_found boolean:=false;
l_index number;
l_ind_col EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_ind_col_pos EDW_OWB_COLLECTION_UTIL.numberTableType;
l_number_index number;
l_nl EDW_OWB_COLLECTION_UTIL.booleanTableType;
l_in_stmt varchar2(20000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_number number;
l_test_mode_fk EDW_OWB_COLLECTION_UTIL.booleanTableType;
l_pk1 varchar2(200);
l_pk2 varchar2(200);
l_table varchar2(200);
l_auto_dang_flag EDW_OWB_COLLECTION_UTIL.booleanTableType;
l_dang_instance EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_dang_instance number;
l_dang_table varchar2(200);
l_new_surr_table varchar2(200);
l_opcode_update_table varchar2(200);
l_slow_check_flag boolean;
l_surr_table_name varchar2(80);
l_dim_pk_pkkey_index EDW_OWB_COLLECTION_UTIL.booleanTableType;
--------------------------------------------------------------------------------
l_dim_looked_at EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_dim_looked_at_nl EDW_OWB_COLLECTION_UTIL.booleanTableType;
l_dim_looked_at_auto EDW_OWB_COLLECTION_UTIL.booleanTableType;
l_number_dim_looked_at number;
l_in_nl boolean;
l_in_hash  boolean;
l_prev number;
l_this number;
l_next number;
--------------------------------------------------------------------------------
l_number_dim_row_count number;
l_dim_row_count EDW_OWB_COLLECTION_UTIL.numberTableType;
l_fk_dim_table EDW_OWB_COLLECTION_UTIL.varcharTableType;
--------------------------------------------------------------------------------
Begin
  if g_debug then
    write_to_log_file_n('In create_surr_tables'||get_time);
  end if;
  l_opcode_update_table:=g_opcode_table||'U';
  if g_check_fk_change and g_object_type='DIMENSION' then
    l_stmt:='create table '||l_opcode_update_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  as select row_id, row_id1 from '||g_opcode_table||' where operation_code=1';
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_opcode_update_table)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n(l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
    end if;
  end if;
  --if there is dangling load option, get all dims involved
  if g_mode='TEST' then
    if g_read_cfig_options then
      if g_object_type='FACT' then
        declare
          l_option_value varchar2(20);
        begin
          g_number_fks_dang_load:=0;
          for i in 1..g_numberOfDimTables loop
            if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
              l_option_value:='N';
              if edw_option.get_warehouse_option(null,g_dimTableId(i),'AUTOKEYGEN',l_option_value)=false then
                l_option_value:='N';
              end if;
              if l_option_value='Y' then
                g_number_fks_dang_load:=g_number_fks_dang_load+1;
                g_fks_dang_load(g_number_fks_dang_load):=g_factFKName(i);
              end if;
            end if;
          end loop;
        end;
      end if;
    else
      if g_number_fks_dang_load=0 then --when there is no config form and test mode is true
        for i in 1..g_numberOfDimTables loop
          g_number_fks_dang_load:=g_number_fks_dang_load+1;
          g_fks_dang_load(g_number_fks_dang_load):=g_factFKName(i);
        end loop;
      end if;
    end if;
    if g_debug then
      write_to_log_file_n('The fks that are for test mode');
      for i in 1..g_number_fks_dang_load loop
        write_to_log_file(g_fks_dang_load(i));
      end loop;
    end if;
  end if;
  g_number_surr_tables:=0;
  l_number_dim_row_count:=0;
  --store the dim counts
  --get the dim row count from all_tables
  for i in 1..g_numberOfDimTables loop
    if edw_owb_collection_util.value_in_table(l_fk_dim_table,l_number_dim_row_count,
      g_dimTableName(i))=false then
      l_number_dim_row_count:=l_number_dim_row_count+1;
      l_dim_row_count(l_number_dim_row_count):=g_dim_row_count(i);
      l_fk_dim_table(l_number_dim_row_count):=g_dimTableName(i);
    end if;
  end loop;
  for i in 1..l_number_dim_row_count loop
    l_dim_pk_pkkey_index(i):=null;
  end loop;
  if g_debug then
    write_to_log_file_n('The dimension counts '||get_time);
    for i in 1..l_number_dim_row_count loop
      write_to_log_file(l_fk_dim_table(i)||'('||l_dim_row_count(i)||')');
    end loop;
  end if;
  if g_object_type='FACT' then
    declare
      l_dim_out EDW_OWB_COLLECTION_UTIL.varcharTableType;
      l_level_table EDW_OWB_COLLECTION_UTIL.varcharTableType;
      l_level_table_id EDW_OWB_COLLECTION_UTIL.numberTableType;
      l_number_dim_out number;
      l_index_in_table number;
    begin
      l_in_stmt:=null;
      for i in 1..g_numberOfDimTables loop
        if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
          l_in_stmt:=l_in_stmt||''''||g_dimTableName(i)||''',';
        end if;
      end loop;
      l_in_stmt:=substr(l_in_stmt,1,length(l_in_stmt)-1);
      if EDW_OWB_COLLECTION_UTIL.get_all_lowest_level_tables(l_in_stmt,l_dim_out,l_level_table,l_level_table_id,
        l_number_dim_out)=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        g_status:=false;
        return false;
      end if;
      for i in 1..g_numberOfDimTables loop
        l_index_in_table:=EDW_OWB_COLLECTION_UTIL.index_in_table(l_dim_out,l_number_dim_out,g_dimTableName(i));
        if l_index_in_table>0 then
          g_dim_lowest_ltc_id(i):=l_level_table_id(l_index_in_table);
          g_dim_lowest_ltc(i):=l_level_table(l_index_in_table);
        else
          g_dim_lowest_ltc_id(i):=null;
          g_dim_lowest_ltc(i):=null;
        end if;
      end loop;
    exception when others then
      g_status_message:=sqlerrm;
      write_to_log_file_n(g_status_message);
      return false;
    end;
  else
    for i in 1..g_numberOfDimTables loop
      g_dim_lowest_ltc_id(i):=null;
      g_dim_lowest_ltc(i):=null;
    end loop;
  end if;
  if g_object_type='FACT' then
    l_user_fk_table:=g_user_fk_table||'A';--only when there is data alignment and slowly changing dimension
  else
    l_user_fk_table:=null;
    l_user_fk_table_flag:=false;
  end if;
  for i in 1..g_numberOfDimTables loop
    l_test_mode_fk(i):=false;
    if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
      if EDW_OWB_COLLECTION_UTIL.value_in_table(g_fks_dang_load,g_number_fks_dang_load,
        g_factFKName(i)) then
        l_test_mode_fk(i):=true;
      end if;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('Checking for NL lookup ');
  end if;
  l_number_dim_looked_at:=0;
  for i in 1..g_numberOfDimTables loop
    l_nl(i):=false;
    l_auto_dang_flag(i):=false;
    if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
      l_index:=EDW_OWB_COLLECTION_UTIL.index_in_table(l_dim_looked_at,l_number_dim_looked_at,g_dimTableName(i));
      if l_index>0 then
        --l_index:=EDW_OWB_COLLECTION_UTIL.index_in_table(g_dimTableName,g_numberOfDimTables,g_dimTableName(i));
        l_nl(i):=l_dim_looked_at_nl(l_index);
        l_auto_dang_flag(i):=l_dim_looked_at_auto(l_index);
      else
        if g_debug then
          write_to_log_file_n('Check '||g_dimTableName_kl(i));
        end if;
        l_number_dim_looked_at:=l_number_dim_looked_at+1;
        l_dim_looked_at(l_number_dim_looked_at):=g_dimTableName(i);
        l_table:=substr(g_dimTableName_kl(i),instr(g_dimTableName_kl(i),'.')+1,length(g_dimTableName_kl(i)));
        if g_dimTable_da_flag(i) and g_dimTable_slow_flag(i)=false then
          l_pk1:='PK';
          l_pk2:='PK_KEY';
        else
          l_pk1:=g_dimUserPKName(i);
          l_pk2:=g_dimActualPKName(i);
        end if;
        l_number:=EDW_OWB_COLLECTION_UTIL.index_in_table(l_fk_dim_table,l_number_dim_row_count,
        l_table);
        --l_index_found:=true;
        l_index_found:=false;
        if l_number>0 then
          if l_dim_row_count(l_number)>0 then --and l_dim_row_count(l_number)<g_fk_use_nl then
            l_index_found:=EDW_OWB_COLLECTION_UTIL.get_join_nl(g_user_fk_table_count,l_dim_row_count(l_number),
            g_stg_join_nl_percentage);
          end if;
        end if;
        if l_index_found then
          l_number_index:=0;
          l_index_found:=false;
          if l_dim_pk_pkkey_index(l_number) is null then
            l_dim_pk_pkkey_index(l_number):=EDW_OWB_COLLECTION_UTIL.check_pk_pkkey_index(l_table,
            null,l_pk1,l_pk2);
          end if;
          if l_dim_pk_pkkey_index(l_number)=true then
            l_index_found:=true;
          end if;
          if l_index_found then
            l_nl(i):=true;
            if g_debug then
              write_to_log_file('NL for '||g_dimTableName_kl(i)||' i index='||i);
            end if;
          end if;
        end if;
        --check for auto dang recovery
        if g_object_type='FACT' then
          l_auto_dang_flag(i):=EDW_OWB_COLLECTION_UTIL.is_auto_dang_implemented(g_dimTableName(i));
        end if;
        l_dim_looked_at_nl(l_number_dim_looked_at):=l_nl(i);
        l_dim_looked_at_auto(l_number_dim_looked_at):=l_auto_dang_flag(i);
      end if;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('Starting the loop');
  end if;
  loop
    --first do a join of all parent tables that are for hash join
    --then one by one for NL tables
    l_end:=l_start;
    l_count:=0;
    l_in_nl:=false;
    l_in_hash:=false;
    l_prev:=l_start;
    l_this:=l_start;
    l_next:=l_start;
    for i in l_start..g_numberOfDimTables loop
      if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
        if l_nl(i)=false and l_auto_dang_flag(i)=false then
          if l_in_nl then
            exit;
          end if;
          l_in_hash:=true;
          l_end:=i;
          l_count:=l_count+1;
          --find l_next
          for j in i+1..g_numberOfDimTables loop
            if g_fstg_fk_direct_load(j)=false and g_fstg_fk_value_load(j)=false then
              l_next:=j;
              exit;
            end if;
          end loop;
          if i<>g_numberOfDimTables and g_dimTableName(i)<>g_dimTableName(l_next) and l_count>=g_key_set then
            exit;
          end if;
        else
          if l_in_hash then
            exit;
          end if;
          l_in_nl:=true;
          --group all those keys together for the same dimension if its NL
          if i<>l_start and g_dimTableName(i)<>g_dimTableName(l_prev) then
            exit;
          end if;
          l_end:=i;
        end if;
        l_prev:=i;
      end if;
    end loop;
    if l_end>g_numberOfDimTables then
      l_end:=g_numberOfDimTables;
    end if;
    if g_debug then
      write_to_log_file('l_start='||l_start||',l_end='||l_end);
    end if;
    l_found:=false;
    for i in l_start..l_end loop
      if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
        l_found:=true;
        exit;
      end if;
    end loop;
    if l_found then
      g_number_surr_tables :=g_number_surr_tables+1;
      g_surr_tables(g_number_surr_tables):=g_surr_table||g_number_surr_tables;
      if EDW_OWB_COLLECTION_UTIL.drop_table(g_surr_tables(g_number_surr_tables))=false then
        null;
      end if;
      --create l_user_fk_table for data alignment with slowly changing dimension
      --this table is created because when there is slow change, the dim pk_key are
      --different from that of the PP table. the PP table is a reflection of the LTC table
      if l_user_fk_table is not null then
        l_user_fk_table_flag:=false;
        for i in l_start..l_end loop
          if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
            if g_dimTable_da_flag(i) and g_dimTable_slow_flag(i) then --g_dimTable_slow_flag(i) then
              l_user_fk_table_flag:=true;
              exit;
            end if;
          end if;
        end loop;
        if l_user_fk_table_flag then
          if g_debug then
            write_to_log_file_n('Found fk with data alignment and slow change');
          end if;
          if EDW_OWB_COLLECTION_UTIL.drop_table(l_user_fk_table)=false then
            null;
          end if;
          /*
          we need to create l_user_fk_table because PK_KEY in PP table will not contain the
          latest PK_KEY from the dimension table when there is slowly changing dimension
          */
          l_stmt:='create table '||l_user_fk_table||' tablespace '||g_op_table_space;
          if g_parallel is not null then
            l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
          end if;
          l_stmt:=l_stmt||'  ';
          if g_user_fk_table=g_fstgTableName then
            if g_stg_join_nl and g_stg_copy_table_flag=false then
              l_stmt:=l_stmt||' as select /*+ORDERED USE_NL('||g_fstgTableName||')*/ ';
            else
              l_stmt:=l_stmt||' as select /*+ORDERED*/ ';
            end if;
            l_stmt:=l_stmt||' /*+PARALLEL('||g_fstgTableName||','||g_parallel||')*/ ';
          else
            l_stmt:=l_stmt||' as select /*+ORDERED*/ ';
          end if;
          if g_user_fk_table=g_fstgTableName then
            l_stmt:=l_stmt||g_user_fk_table||'.rowid row_id ';
          else
            l_stmt:=l_stmt||g_user_fk_table||'.row_id row_id ';
          end if;
          for i in l_start..l_end loop
            if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
              if g_dimTable_da_flag(i) and g_dimTable_slow_flag(i) then --g_dimTable_slow_flag(i) then
                l_alias(i):=substr(g_dimTableName_pp(i),instr(g_dimTableName_pp(i),'.')+1,
                length(g_dimTableName_pp(i)))||i;
                if l_test_mode_fk(i) and g_create_parent_table_records=false then
                    l_stmt:=l_stmt||',nvl('||l_alias(i)||'.LOADED_PK,''NA_ERR'') '||g_fstgUserFKName(i);
                else
                  l_stmt:=l_stmt||','||l_alias(i)||'.LOADED_PK '||g_fstgUserFKName(i);
                end if;
              else
                l_stmt:=l_stmt||','||g_user_fk_table||'.'||g_fstgUserFKName(i);
              end if;
            end if;
          end loop;
          if g_user_fk_table=g_fstgTableName then
            if g_stg_copy_table_flag then
              l_stmt:=l_stmt||' from '||g_stg_copy_table||' '||g_fstgTableName;
            else
              l_stmt:=l_stmt||' from '||g_opcode_table||','||g_fstgTableName;
            end if;
          else
            l_stmt:=l_stmt||' from '||g_user_fk_table;
          end if;
          for i in l_start..l_end loop
            if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
              if g_dimTable_da_flag(i) and g_dimTable_slow_flag(i) then --g_dimTable_slow_flag(i) then
                l_stmt:=l_stmt||','||g_dimTableName_pp(i)||' '||l_alias(i);
              end if;
            end if;
          end loop;
          l_stmt:=l_stmt||' where ';
          if g_user_fk_table=g_fstgTableName and g_stg_copy_table_flag=false then
            l_stmt:=l_stmt||g_opcode_table||'.row_id='||g_fstgTableName||'.rowid and ';
          end if;
          for i in l_start..l_end loop
            if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
              if g_dimTable_da_flag(i) and g_dimTable_slow_flag(i) then --g_dimTable_slow_flag(i) then
                if l_test_mode_fk(i) and g_create_parent_table_records=false then
                  l_stmt:=l_stmt||g_user_fk_table||'.'||g_fstgUserFKName(i)||'='||
                  l_alias(i)||'.PK(+) and ';
                else
                  l_stmt:=l_stmt||g_user_fk_table||'.'||g_fstgUserFKName(i)||'='||
                  l_alias(i)||'.PK and ';
                end if;
              end if;
            end if;
          end loop;
          l_stmt:=substr(l_stmt,1,length(l_stmt)-4);
          if EDW_OWB_COLLECTION_UTIL.drop_table(l_user_fk_table)=false then
            null;
          end if;
          if g_debug then
            write_to_log_file_n('Going to execute '||l_stmt||get_time);
          end if;
          begin
            execute immediate l_stmt;
          exception when others then
            g_status_message:=sqlerrm;
            write_to_log_file_n(g_status_message);
            g_status:=false;
            return false;
          end;
          if g_debug then
            write_to_log_file_n('Created '||l_user_fk_table||' with '||sql%rowcount||' rows '||get_time);
          end if;
          EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_user_fk_table,instr(l_user_fk_table,'.')+1,
          length(l_user_fk_table)),substr(l_user_fk_table,1,instr(l_user_fk_table,'.')-1));
        end if;--if l_user_fk_table_flag then
      end if;--if l_user_fk_table is not null then
      l_slow_check_flag:=false;
      for i in l_start..l_end loop
        if g_dimTable_slow_flag(i) then
          l_slow_check_flag:=true;
          exit;
        end if;
      end loop;
      if l_slow_check_flag then
        l_surr_table_name:=g_surr_tables(g_number_surr_tables)||'S';
      else
        l_surr_table_name:=g_surr_tables(g_number_surr_tables);
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_surr_table_name)=false then
        null;
      end if;
      l_stmt:='create table '||l_surr_table_name||' tablespace '||g_op_table_space;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||' as select /*+ORDERED ';
      for i in l_start..l_end loop
        if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
          l_table:=substr(g_dimTableName_kl(i),instr(g_dimTableName_kl(i),'.')+1,length(g_dimTableName_kl(i)));
          if l_nl(i) then
            l_stmt:=l_stmt||' USE_NL('||l_table||'_'||i||')';
          end if;
        end if;
      end loop;
      l_stmt:=l_stmt||'*/ ';
      if g_parallel is not null then
        l_stmt:=l_stmt||' /*+PARALLEL ';
        for i in l_start..l_end loop
          if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
            l_stmt:=l_stmt||'('||substr(g_dimTableName_kl(i),instr(g_dimTableName_kl(i),'.')+1,
            length(g_dimTableName_kl(i)))||'_'||i||','||g_parallel||') ';
          end if;
        end loop;
        l_stmt:=l_stmt||'*/ ';
      end if;
      if l_user_fk_table_flag=false then
        if g_user_fk_table=g_fstgTableName then
          l_stmt:=l_stmt||g_user_fk_table||'.rowid row_id ';
        else
          l_stmt:=l_stmt||g_user_fk_table||'.row_id row_id ';
        end if;
      else
        l_stmt:=l_stmt||l_user_fk_table||'.row_id row_id ';
      end if;
      for i in l_start..l_end loop
        if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
          --g_surr_tables_fk(g_number_surr_tables):=g_fstgActualFKName(i);
          l_alias(i):=substr(g_dimTableName_kl(i),instr(g_dimTableName_kl(i),'.')+1,
          length(g_dimTableName_kl(i)))||'_'||i;
          l_pk(i):=g_dimUserPKName(i);
          l_pk_key(i):=g_dimActualPKName(i);
          if g_dimTable_da_flag(i) and g_dimTable_slow_flag(i)=false then  --g_dimTable_slow_flag(i)=false then
            l_pk(i):='PK';
            l_pk_key(i):='PK_KEY';
          end if;
          if l_test_mode_fk(i) and g_create_parent_table_records=false then
            l_stmt:=l_stmt||',nvl('||l_alias(i)||'.'||l_pk_key(i)||',-1) '||g_fstgActualFKName(i);
          else
           l_stmt:=l_stmt||','||l_alias(i)||'.'||l_pk_key(i)||' '||g_fstgActualFKName(i);
          end if;
        end if;
      end loop;--for i in l_start..l_end loop
      l_stmt:=l_stmt||' from ';
      if l_user_fk_table_flag=false then
        l_stmt:=l_stmt||g_user_fk_table;
      else
        l_stmt:=l_stmt||l_user_fk_table;
      end if;
      for i in l_start..l_end loop
        if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
          l_stmt:=l_stmt||','||g_dimTableName_kl(i)||' '||l_alias(i);
        end if;
      end loop;
      l_stmt:=l_stmt||' where ';
      for i in l_start..l_end loop
        if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
          if l_test_mode_fk(i) and g_create_parent_table_records=false then
            if l_user_fk_table_flag=false then
              l_stmt:=l_stmt||l_alias(i)||'.'||l_pk(i)||'(+)='||g_user_fk_table||'.'||
               g_fstgUserFKName(i)||' and ';
            else
              l_stmt:=l_stmt||l_alias(i)||'.'||l_pk(i)||'(+)='||l_user_fk_table||'.'||
               g_fstgUserFKName(i)||' and ';
            end if;
          else
            if l_user_fk_table_flag=false then
              l_stmt:=l_stmt||l_alias(i)||'.'||l_pk(i)||'='||g_user_fk_table||'.'||
                g_fstgUserFKName(i)||' and ';
            else
              l_stmt:=l_stmt||l_alias(i)||'.'||l_pk(i)||'='||l_user_fk_table||'.'||
                g_fstgUserFKName(i)||' and ';
            end if;
          end if;
        end if;
      end loop;
      l_stmt:=substr(l_stmt,1,length(l_stmt)-4);
      if g_debug then
        write_to_log_file_n('Going to execute '||l_stmt);
        write_to_log_file_n('Time='||get_time);
      end if;
      begin
        execute immediate l_stmt;
      exception when others then
        g_status_message:=sqlerrm;
        write_to_log_file_n(g_status_message);
        g_status:=false;
        return false;
      end;
      g_surr_tables_count(g_number_surr_tables):=sql%rowcount;
      if g_debug then
        write_to_log_file_n('Created with '||g_surr_tables_count(g_number_surr_tables)||' rows '||get_time);
      end if;
      /*
      slow=true da=true join to dim
      slow=false da=true join to PP
      slow=true da=false join to dim
      slow=false da=false join to dim
      when there is slowly changing dimension, we will need to get the MAX for the pk_key
      l_table will contain duplidcate entries for those PK that have slow change. so we
      need to get the MAX
      */
      if l_slow_check_flag then
        /*
        if we have slow change and DA, then first l_user_fk_table is created by joining to PP
        then we have joined to the dim table. when joining to dim table, we can get duplicates
        due to slow change. so we need MAX
        */
        l_table:=l_surr_table_name;
        EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_table,instr(l_table,'.')+1,length(l_table)),
        substr(l_table,1,instr(l_table,'.')-1));
        l_stmt:='create table '||g_surr_tables(g_number_surr_tables)||' tablespace '||g_op_table_space;
        if g_parallel is not null then
          l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
        end if;
        l_stmt:=l_stmt||' as select row_id ';
        for i in l_start..l_end loop
          if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
            l_stmt:=l_stmt||',MAX('||g_fstgActualFKName(i)||') '||g_fstgActualFKName(i);
          end if;
        end loop;
        l_stmt:=l_stmt||' from '||l_table||' group by row_id';
        if g_debug then
          write_to_log_file_n('Going to execute '||l_stmt||get_time);
        end if;
        begin
          execute immediate l_stmt;
          g_surr_tables_count(g_number_surr_tables):=sql%rowcount;
        exception when others then
          g_status_message:=sqlerrm;
          write_to_log_file_n(g_status_message);
          g_status:=false;
          return false;
        end;
      end if;
      --if this is a level table and the there is change in parent fk, remember it.
      /*g_surr_tables(g_number_surr_tables)
        g_fstgActualFKName --surr table fk
        g_FactTableName --ltc name
        g_factFKName(i) --ltc fk
        g_primary_target --ltc id
        g_dimTableId(i) --parent ltc id
        l_opcode_update_table -- to join to
      */
      declare
        l_table1 varchar2(200);
        l_res number;
      begin
        if g_check_fk_change and g_object_type='DIMENSION' then
          for i in l_start..l_end loop
            l_table:=g_bis_owner||'.LTFC_'||g_primary_target||'_'||g_dimTableId(i);--this is a marker table
            l_table1:=l_table||'_'||g_job_id||'_T';
            if EDW_OWB_COLLECTION_UTIL.check_table(l_table)=false then
              l_stmt:='create table '||l_table1||' tablespace '||g_op_table_space;
              if g_parallel is not null then
                l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
              end if;
              l_stmt:=l_stmt||'  as select b.row_id1,a.'||g_fstgActualFKName(i)||' from '||
              l_opcode_update_table||' b,'||g_surr_tables(g_number_surr_tables)||' a where a.row_id=b.row_id';
              if EDW_OWB_COLLECTION_UTIL.drop_table(l_table1)=false then
                null;
              end if;
              if g_debug then
                write_to_log_file_n(l_stmt||get_time);
              end if;
              execute immediate l_stmt;
              if g_debug then
                write_to_log_file_n('created with '||sql%rowcount||' rows '||get_time);
              end if;
              EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_table1,instr(l_table1,'.')+1,
              length(l_table1)),substr(l_table1,1,instr(l_table1,'.')-1));
              l_stmt:='select /*+ordered ';
              if g_fact_use_nl then
                l_stmt:=l_stmt||' use_nl(B) ';
              end if;
              l_stmt:=l_stmt||'*/ ';
              if g_parallel is not null then
                l_stmt:=l_stmt||' /*+parallel(B,'||g_parallel||')*/ ';
              end if;
              l_stmt:=l_stmt||' 1 from '||l_table1||' A,'||g_FactTableName||' B where A.row_id1=B.rowid and '||
              'A.'||g_fstgActualFKName(i)||'<>B.'||g_factFKName(i)||' and rownum=1';
              if g_debug then
                write_to_log_file_n(l_stmt||get_time);
              end if;
              open cv for l_stmt;
              fetch cv into l_res;
              if g_debug then
                write_to_log_file_n('l_res='||l_res||get_time);
              end if;
              close cv;
              if l_res=1 then
                l_stmt:='create table '||l_table||'(x number) tablespace '||g_op_table_space;
                if g_debug then
                  write_to_log_file_n(l_stmt||get_time);
                end if;
                begin
                  execute immediate l_stmt;
                exception when others then
                  if sqlcode=-00955 then
                    if g_debug then
                      write_to_log_file_n('Table already created!');
                    end if;
                  end if;
                end;
              end if;
              if EDW_OWB_COLLECTION_UTIL.drop_table(l_table1)=false then
                null;
              end if;
            end if;
          end loop;
        end if;
      end;
      --log dangling keys
      if g_log_dang_keys then
        --this may need to be one key at a time. look at l_stmt:='insert into '||g_surr_tables(g_numb...
        --because we need to populate g_surr_tables(..) back with the new surr key values, this may need
        --to run one key at a time
        for i in l_start..l_end loop
          if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
            if l_auto_dang_flag(i) or (l_test_mode_fk(i)=true and g_create_parent_table_records) then
              if g_user_fk_table_count=0 or g_user_fk_table_count>g_surr_tables_count(g_number_surr_tables) then
                l_dang_table:=null;
                if create_auto_dang_tables(g_surr_tables(g_number_surr_tables),g_fstgUserFKName(i),
                  l_user_fk_table_flag,l_user_fk_table,l_dang_table)=false then
                  return false;
                end if;
                --g_log_dang_keys for facts
                if g_object_type='FACT' and l_auto_dang_flag(i) and l_dang_table is not null then
                  if create_dang_inst_tables(g_fstgUserFKName(i),g_dimTableId(i),g_dimTableName(i),
                    l_dang_table,l_dang_instance,l_number_dang_instance)=false then
                    return false;
                  end if;
                  if insert_into_parent_fk_log(l_dang_instance,l_number_dang_instance,
                    g_fstgUserFKName(i),g_dimTableId(i),g_dimTableName(i),g_dim_auto_dang_table(i),
                    g_dim_lowest_ltc_id(i))=false then
                    return false;
                  end if;
                  if drop_fk_inst_tables(l_dang_instance,l_number_dang_instance,g_dimTableId(i))=false then
                    return false;
                  end if;
                end if;
                --create parent table records
                if g_create_parent_table_records and l_dang_table is not null and l_test_mode_fk(i) then
                  declare
                    l_da_table varchar2(200);
                    l_pp_table varchar2(200);
                  begin
                    l_new_surr_table:=null;
                    if g_dimTable_da_flag(i) then
                      l_da_table:=g_dimTableName_da(i);
                      l_pp_table:=g_dimTableName_pp(i);
                    else
                      l_da_table:=null;
                      l_pp_table:=null;
                    end if;
                    if g_object_type='FACT' then
                      if create_dang_dim_records(l_dang_table,g_fstgUserFKName(i),l_da_table,l_pp_table,
                        g_dim_lowest_ltc(i),g_dimTableName(i),g_dimTableId(i),l_new_surr_table)=false then
                        return false;
                      end if;
                    else --this is the level from dimensions
                      if create_dang_dim_records(l_dang_table,g_fstgUserFKName(i),null,null,
                        g_dimTableName(i),null,null,l_new_surr_table)=false then
                        return false;
                      end if;
                    end if;
                    if l_new_surr_table is not null then
                      l_stmt:='insert into '||g_surr_tables(g_number_surr_tables)||'(row_id';
                      for i in l_start..l_end loop
                        if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
                          l_stmt:=l_stmt||','||g_fstgActualFKName(i);
                        end if;
                      end loop;
                      l_stmt:=l_stmt||') select row_id';
                      for i in l_start..l_end loop
                        if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
                          l_stmt:=l_stmt||',pk_key';
                        end if;
                      end loop;
                      l_stmt:=l_stmt||' from '||l_new_surr_table;
                      if g_debug then
                        write_to_log_file_n(l_stmt||get_time);
                      end if;
                      execute immediate l_stmt;
                      if g_debug then
                        write_to_log_file_n('Inserted '||sql%rowcount||' rows '||get_time);
                      end if;
                      commit;
                      if EDW_OWB_COLLECTION_UTIL.drop_table(l_new_surr_table)=false then
                        null;
                      end if;
                    end if;
                  exception when others then
                    g_status_message:=sqlerrm;
                    write_to_log_file_n('Error in trying to create dang rows in parent table '||g_status_message);
                    g_status:=false;
                    return false;
                  end;
                end if;
                if EDW_OWB_COLLECTION_UTIL.drop_table(l_dang_table)=false then
                  null;
                end if;
              else
                if g_debug then
                  write_to_log_file_n('No need to log dangling keys.');
                  write_to_log_file('g_user_fk_table_count='||g_user_fk_table_count||' and '||
                  'g_surr_tables_count(g_number_surr_tables)='||g_surr_tables_count(g_number_surr_tables));
                end if;
              end if;
            else
              if g_debug then
                write_to_log_file_n('NOT Logging dangling keys for '||g_fstgActualFKName(i)||'('||
                g_dimTableName(i)||')');
              end if;
            end if;
          end if;
        end loop;
      end if;--if g_log_dang_keys then
      --EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_surr_tables(g_number_surr_tables),
      --instr(g_surr_tables(g_number_surr_tables),'.')+1,length(g_surr_tables(g_number_surr_tables))),
      --substr(g_surr_tables(g_number_surr_tables),1,instr(g_surr_tables(g_number_surr_tables),'.')-1));
    end if;--if l_found then
    l_start:=l_end+1;
    if l_start>g_numberOfDimTables then
      exit;
    end if;
  end loop;--loop
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_user_fk_table)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_opcode_update_table)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;
/*
from all the surr tables, create the main surr table g_surr_table
*/
function create_main_surr_table return boolean is
l_stmt varchar2(32000);
Begin
  if g_debug then
    write_to_log_file_n('In create_main_surr_table'||get_time);
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_surr_table)=false then
    null;
  end if;
  g_surr_count:=0;
  if g_user_fk_table<>g_fstgTableName then
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_user_fk_table)=false then
      null;
    end if;
  end if;
  l_stmt:='create table '||g_surr_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  ';
  l_stmt:=l_stmt||' as select ';
  for i in 1..g_numberOfDimTables loop
    if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
      l_stmt:=l_stmt||g_fstgActualFKName(i)||',';
    end if;
  end loop;
  l_stmt:=l_stmt||g_opcode_table||'.row_id row_id';
  if g_stg_copy_table_flag or g_use_mti then
    l_stmt:=l_stmt||','||g_opcode_table||'.row_id_copy row_id_copy';
  end if;
  l_stmt:=l_stmt||','||g_opcode_table||'.row_id1 row_id1';
  l_stmt:=l_stmt||','||g_opcode_table||'.operation_code operation_code';
  l_stmt:=l_stmt||','||g_opcode_table||'.'||g_fstgPKNameKey||' '||g_fstgPKNameKey;
  if g_update_type='DELETE-INSERT' then
    l_stmt:=l_stmt||','||g_opcode_table||'.'||g_fstgPKName||' '||g_fstgPKName||','||
    g_opcode_table||'.CREATION_DATE CREATION_DATE';
  end if;
  l_stmt:=l_stmt||' from ';
  for i in 1..g_number_surr_tables loop
    l_stmt:=l_stmt||g_surr_tables(i)||',';
  end loop;
  l_stmt:=l_stmt||g_opcode_table;
  l_stmt:=l_stmt||' where ';
  --if g_fstg_all_fk_direct_load is true then g_number_surr_tables should be 0
  for i in 1..g_number_surr_tables loop
    l_stmt:=l_stmt||g_surr_tables(i)||'.row_id='||g_opcode_table||'.row_id and   ';
  end loop;
  --this 6 is very imp as is the space left after where  and "and" in
  --l_stmt:=l_stmt||g_surr_tables(i)||'.row_id='||g_opcode_table||'.row_id and   ';
  l_stmt:=substr(l_stmt,1,length(l_stmt)-6);
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
    write_to_log_file('Time='||get_time);
  end if;
  begin
    execute immediate l_stmt;
    g_surr_count:=sql%rowcount;
  exception when others then
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message);
    g_status:=false;
    return false;
  end ;
  if g_debug then
    write_to_log_file_n('Created '||g_surr_table||' with '||g_surr_count||' rows');
    write_to_log_file('Time='||get_time);
  end if;
  for i in 1..g_number_surr_tables loop
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_surr_tables(i))=false then
      null;
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

/*
from all the surr tables, create the main surr table g_surr_table
LHJM stands for low hash join memory
*/
function create_main_surr_table_LHJM return boolean is
l_stmt varchar2(32000);
l_index_table EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_index_table number;
l_index_table_copy EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_index_table_copy number;
l_start number;
l_end number;
l_max_count number;
l_table varchar2(200);
l_columns EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_columns number;
l_tables_at_a_time number;
Begin
  l_tables_at_a_time:=g_key_set;
  if g_debug then
    write_to_log_file_n('In create_main_surr_table_LHJM'||get_time);
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_surr_table)=false then
    null;
  end if;
  l_number_index_table:=0;
  g_surr_count:=0;
  for i in 1..g_number_surr_tables loop
    l_number_index_table:=l_number_index_table+1;
    l_index_table(l_number_index_table):=g_surr_tables(i);
  end loop;
  l_max_count:=g_number_surr_tables;
  loop --every loop creates a series of tables. the last loop creates 2 tables. main table is created later
    l_start:=1;
    --if l_number_index_table=1 or l_number_index_table=2 then
      --exit;
    --end if;
    if l_number_index_table<=l_tables_at_a_time then
      exit;
    end if;
    l_index_table_copy:=l_index_table;
    l_number_index_table_copy:=l_number_index_table;
    l_number_index_table:=0;
    loop --through l_index_table. each loop creates a table
      l_end:=l_start+(l_tables_at_a_time-1);
      if l_end>l_number_index_table_copy then
        l_end:=l_number_index_table_copy;
      elsif (l_end+1)=l_number_index_table_copy then
        l_end:=l_end+1;
      end if;
      l_max_count:=l_max_count+1;
      l_table:=g_surr_table||'O'||l_max_count;
      l_number_index_table:=l_number_index_table+1;
      l_index_table(l_number_index_table):=l_table;
      l_number_columns:=0;
      l_stmt:='create table '||l_table||' tablespace '||g_op_table_space;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  ';
      l_stmt:=l_stmt||' as select ';
      for i in l_start..l_end loop
        if EDW_OWB_COLLECTION_UTIL.get_db_columns_for_table(substr(l_index_table_copy(i),
        instr(l_index_table_copy(i),'.')+1,length(l_index_table_copy(i))),l_columns,l_number_columns,
        g_bis_owner)=false then
          g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
          write_to_log_file_n(g_status_message);
          g_status:=false;
          return false;
        end if;
        for j in 1..l_number_columns loop
          if upper(l_columns(j))<>'ROW_ID' then
            l_stmt:=l_stmt||l_columns(j)||',';
          end if;
        end loop;
      end loop;--for i in l_start..l_end loop
      l_stmt:=l_stmt||l_index_table_copy(l_end)||'.ROW_ID from ';
      for i in l_start..l_end loop
        l_stmt:=l_stmt||l_index_table_copy(i)||',';
      end loop;
      l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
      l_stmt:=l_stmt||' where ';
      for i in l_start..(l_end-1) loop
        l_stmt:=l_stmt||l_index_table_copy(i)||'.ROW_ID='||l_index_table_copy(i+1)||'.ROW_ID and ';
      end loop;
      l_stmt:=substr(l_stmt,1,length(l_stmt)-4);
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_table)=false then
        null;
      end if;
      if g_debug then
        write_to_log_file_n('Going to execute '||l_stmt||get_time);
      end if;
      begin
        execute immediate l_stmt;
        if g_debug then
          write_to_log_file_n('Created '||l_table||' with '||sql%rowcount||' rows '||get_time);
        end if;
      exception when others then
        g_status_message:=sqlerrm;
        write_to_log_file_n(g_status_message);
        g_status:=false;
        return false;
      end ;
      --drop the tables
      for i in l_start..l_end loop
        if EDW_OWB_COLLECTION_UTIL.drop_table(l_index_table_copy(i))=false then
          null;
        end if;
      end loop;
      l_start:=l_end+1;
      if l_start>l_number_index_table_copy then
        exit;
      end if;
    end loop;--each loop creates a table
  end loop;
  l_stmt:='create table '||g_surr_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  ';
  l_stmt:=l_stmt||' as select ';
  for i in 1..l_number_index_table loop
    if EDW_OWB_COLLECTION_UTIL.get_db_columns_for_table(substr(l_index_table(i),
        instr(l_index_table(i),'.')+1,length(l_index_table(i))),l_columns,l_number_columns,
    g_bis_owner)=false then
      g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
      write_to_log_file_n(g_status_message);
      g_status:=false;
      return false;
    end if;
    for j in 1..l_number_columns loop
      if upper(l_columns(j))<>'ROW_ID' then
        l_stmt:=l_stmt||l_columns(j)||',';
      end if;
    end loop;
  end loop;
  l_stmt:=l_stmt||g_opcode_table||'.row_id row_id';
  if g_stg_copy_table_flag or g_use_mti then
    l_stmt:=l_stmt||','||g_opcode_table||'.row_id_copy row_id_copy';
  end if;
  l_stmt:=l_stmt||','||g_opcode_table||'.row_id1 row_id1';
  l_stmt:=l_stmt||','||g_opcode_table||'.operation_code operation_code';
  l_stmt:=l_stmt||','||g_opcode_table||'.'||g_fstgPKNameKey||' '||g_fstgPKNameKey;
  if g_update_type='DELETE-INSERT' then
    l_stmt:=l_stmt||','||g_opcode_table||'.'||g_fstgPKName||' '||g_fstgPKName||','||
    g_opcode_table||'.CREATION_DATE CREATION_DATE';
  end if;
  l_stmt:=l_stmt||' from ';
  for i in 1..l_number_index_table loop
    l_stmt:=l_stmt||l_index_table(i)||',';
  end loop;
  l_stmt:=l_stmt||g_opcode_table;
  l_stmt:=l_stmt||' where ';
  --if g_fstg_all_fk_direct_load is true then g_number_surr_tables should be 0
  for i in 1..l_number_index_table loop
    l_stmt:=l_stmt||l_index_table(i)||'.row_id='||g_opcode_table||'.row_id and   ';
  end loop;
  --this 6 is very imp as is the space left after where  and "and" in
  --l_stmt:=l_stmt||g_surr_tables(i)||'.row_id='||g_opcode_table||'.row_id and   ';
  l_stmt:=substr(l_stmt,1,length(l_stmt)-6);
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
    write_to_log_file('Time='||get_time);
  end if;
  begin
    execute immediate l_stmt;
    g_surr_count:=sql%rowcount;
  exception when others then
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message);
    g_status:=false;
    return false;
  end;
  if g_debug then
    write_to_log_file_n('Created '||g_surr_table||' with '||g_surr_count||' rows'||get_time);
  end if;
  for i in 1..l_number_index_table loop
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_index_table(i))=false then
      null;
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

/*
not called if g_use_mti is true. in this case the user fk table is created in
create_user_measure_fk_table
*/
function create_user_fk_table return boolean is
l_stmt varchar2(30000);
Begin
--g_user_fk_table
  if g_debug then
    write_to_log_file_n('In create_user_fk_table'||get_time);
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_user_fk_table)=false then
    null;
  end if;
  if g_fstg_all_fk_direct_load then
    l_stmt:='create table '||g_user_fk_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  as select row_id from '||g_opcode_table;
  else
    l_stmt:='create table '||g_user_fk_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  ';
    if g_stg_join_nl and g_stg_copy_table_flag=false then
      l_stmt:=l_stmt||' as select /*+ORDERED USE_NL('||g_fstgTableName||')*/ ';
    else
      if g_stg_copy_table_flag=false then
        l_stmt:=l_stmt||' as select /*+ORDERED*/ ';
      else
        l_stmt:=l_stmt||' as select ';
      end if;
    end if;
    if g_parallel is not null then
      l_stmt:=l_stmt||' /*+PARALLEL ('||g_fstgTableName||','||g_parallel||')*/ ';
    end if;
    for i in 1..g_numberOfDimTables loop
      if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
        l_stmt:=l_stmt||g_fstgTableName||'.'||g_fstgUserFKName(i)||',';
      end if;
    end loop;
    if g_instance_column is not null then
      if EDW_OWB_COLLECTION_UTIL.value_in_table(g_fstgUserFKName,g_numberOfDimTables,g_instance_column)=false then
        l_stmt:=l_stmt||g_fstgTableName||'.'||g_instance_column||',';
      end if;
    end if;
    if g_stg_copy_table_flag then
      l_stmt:=l_stmt||g_fstgTableName||'.row_id row_id';
      l_stmt:=l_stmt||' from '||g_stg_copy_table||' '||g_fstgTableName;
    else
      l_stmt:=l_stmt||g_opcode_table||'.row_id row_id';
      l_stmt:=l_stmt||' from '||g_opcode_table;
      l_stmt:=l_stmt||','||g_fstgTableName;
      l_stmt:=l_stmt||' where '||g_fstgTableName||'.rowid='||g_opcode_table||'.row_id ';
    end if;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
    write_to_log_file('Time='||get_time);
  end if;
  begin
    execute immediate l_stmt;
  exception when others then
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message);
    g_status:=false;
    return false;
  end;
  g_user_fk_table_count:=sql%rowcount;
  if g_debug then
    write_to_log_file_n('Created '||g_user_fk_table||' with '||g_user_fk_table_count||' rows');
    write_to_log_file('Time='||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_user_fk_table,
    instr(g_user_fk_table,'.')+1,length(g_user_fk_table)),
    substr(g_user_fk_table,1,instr(g_user_fk_table,'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

/*
see the FK_KEY col in the staging table and see if its populated. if yes, then this key is to be
direct loaded
*/
function check_fk_direct_load return boolean is
l_found boolean;
l_fk_status number;
Begin
  if g_debug then
    write_to_log_file_n('In check_fk_direct_load'||get_time);
    write_to_log_file(get_time);
  end if;
  if g_instance_type='SINGLE' then
    for i in 1..g_numberOfDimTables loop
      l_fk_status:=check_fk_for_data(g_fstgActualFKName(i));
      if l_fk_status=2 then
        if g_debug then
          write_to_log_file_n('Key '||g_fstgActualFKName(i)||' is for direct load');
        end if;
        g_fstg_fk_direct_load(i):=true;
      else
        if g_debug then
          write_to_log_file_n('Key '||g_fstgActualFKName(i)||' is NOT for direct load');
        end if;
      end if;
    end loop;
  end if;
  l_found:=false;
  for i in 1..g_numberOfDimTables loop
    if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
      l_found:=true;
      exit;
    end if;
  end loop;
  if l_found=false then
    g_fstg_all_fk_direct_load:=true;
    if g_debug then
      write_to_log_file_n('g_fstg_all_fk_direct_load is TRUE');
    end if;
  end if;
  if g_debug then
    write_to_log_file(get_time);
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

/*
for performance we donr want to use EDW_OWB_COLLECTION_UTIL.does_table_have_data
*/
function check_fk_for_data(p_fk varchar2) return number is
l_stmt varchar2(4000);
l_fk_value number;
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  l_fk_value:=null;
  if g_debug then
    write_to_log_file_n('In check_fk_for_data p_fk='||p_fk);
  end if;
  l_stmt:='select '||p_fk||' from '||g_fstgTableName||' where rownum=1';
  open cv for l_stmt ;
  fetch cv into l_fk_value;
  close cv;
  if l_fk_value is null then
    return 1;
  end if;
  return 2;
Exception when others then
  write_to_log_file_n('Error in check_fk_for_data '||sqlerrm||get_time);
  return 0;
End;

function check_pk_direct_load return boolean is
l_found boolean;
l_pk_status number;
Begin
  if g_debug then
    write_to_log_file_n('In check_pk_direct_load'||get_time);
    write_to_log_file(get_time);
  end if;
  --g_pk_direct_load
  --see if the pk_key had any data in it.
  l_pk_status:=check_fk_for_data(g_fstgPKNameKey);
  if l_pk_status=2 then
    --there is data in the pk_key in the staging table
    if g_debug then
      write_to_log_file_n('g_pk_direct_load=TRUE');
    end if;
    g_pk_direct_load:=true;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

/*
if the pk_key is populated in the staging table and this is single source then change the
mapping from the sequence to the staging table pk_key
what about partitioning?
*/
function make_pk_direct_load(p_type varchar2) return boolean is
l_pk_index number;
Begin
  if g_debug then
    write_to_log_file_n('In make_pk_direct_load'||get_time);
    write_to_log_file('p_type='||p_type);
  end if;
  for i in 1..g_num_ff_map_cols loop
    if g_fact_mapping_columns(i)=g_factPKNameKey then
      l_pk_index:=i;
      exit;
    end if;
  end loop;
  if l_pk_index is null then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.get_message('EDW_PK_INDEX_NOT_FOUND');
    write_to_log_file_n(g_status_message);
    g_status:=false;
    return false;
  end if;
  if p_type='DIRECT-LOAD' then
    g_fstg_mapping_columns(l_pk_index):=g_fstgTableName||'.'||g_fstgPKNameKey;
  end if;
  if g_debug then
    write_to_log_file_n('l_pk_index='||l_pk_index);
    write_to_log_file_n('g_fstg_mapping_columns(l_pk_index)='||g_fstg_mapping_columns(l_pk_index));
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

/*
insert into fact audit all new rows of fact
*/
function insert_fa_fact_insert return boolean is
l_stmt varchar2(32000);
l_stmt1 varchar2(4000);
Begin
  if g_debug then
    write_to_log_file_n('In insert_fa_fact_insert'||get_time);
  end if;
  if EDW_OWB_COLLECTION_UTIL.check_table(g_fa_rec_log)=true then
    write_to_log_file_n(g_fa_rec_log||' table found. No need to execute this procedure');
    return true;
  end if;
  if g_parallel is null then
    l_stmt:='insert into '||g_fact_audit_name;
  else
    l_stmt:='insert /*+PARALLEL('||g_fact_audit_name||','||g_parallel||')*/ into '||g_fact_audit_name;
  end if;
  l_stmt:=l_stmt||'(';
  for i in 1..g_item_audit_number_all loop
    l_stmt:=l_stmt||g_item_audit_all(i)||',';
  end loop;
  if g_creation_date_flag then
    l_stmt:=l_stmt||'CREATION_DATE,';
  end if;
  if g_last_update_date_flag then
    l_stmt:=l_stmt||'LAST_UPDATE_DATE,';
  end if;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  l_stmt:=l_stmt||')';
  l_stmt:=l_stmt||' select ';
  --if g_parallel is not null then
    --l_stmt:=l_stmt||'/*+PARALLEL('||g_fact_audit_net_table||','||g_parallel||')*/ ';
  --end if;
  for i in 1..g_item_audit_number_all loop
    l_stmt:=l_stmt||g_item_audit_all(i)||',';
  end loop;
  if g_creation_date_flag then
    l_stmt:=l_stmt||'SYSDATE,';
  end if;
  if g_last_update_date_flag then
    l_stmt:=l_stmt||'SYSDATE,';
  end if;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  l_stmt:=l_stmt||' from '||g_fact_audit_net_table;

  /*
  we are dropping and recreating this table g_fact_audit_net_table. so what about error recovery?
  */
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  begin
    EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Inserted '||sql%rowcount||' rows into '||g_fact_audit_name||get_time);
    end if;
    commit;
  exception when others then
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message);
    g_status:=false;
    return false;
  end ;
  /*
  here g_fa_rec_log is being used for any future error recovery
  */
  l_stmt1:='create table '||g_fa_rec_log||'(row_id rowid)'||' tablespace '||g_op_table_space;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt1);
  end if;
  execute immediate l_stmt1;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_fa_ilog)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

/*
insert into fact audit all  update of fact
*/
function insert_fa_fact_update return boolean is
l_stmt varchar2(32000);
l_ilog varchar2(400);
l_stmt1 varchar2(4000);
Begin
  /*
   for columns that have changed, insert
  */
  if g_debug then
    write_to_log_file_n('In insert_fa_fact_update'||get_time);
  end if;
  if EDW_OWB_COLLECTION_UTIL.check_table(g_fa_rec_up_log)=true then
    write_to_log_file_n(g_fa_rec_up_log||' table found. No need to execute this procedure');
    return true;
  end if;
  l_ilog:=g_fa_ilog||'1';
  l_stmt:='create table '||l_ilog||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  ';
  if g_fact_use_nl then
    l_stmt:=l_stmt||' as select /*+ORDERED USE_NL('||g_factTableName||')*/ ';
  else
    l_stmt:=l_stmt||' as select /*+ORDERED*/ ';
  end if;
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+PARALLEL('||g_factTableName||','||g_parallel||')*/ ';
  end if;
  l_stmt:=l_stmt||g_hold_table||'.rowid row_id from '||g_hold_table||','||g_factTableName;
  l_stmt:=l_stmt||' where '||g_hold_table||'.row_id1='||g_factTableName||'.rowid ';
  for i in 1..g_item_audit_number loop
    l_stmt:=l_stmt||' and '||g_hold_table||'.'||g_item_audit(i)||'='||g_factTableName||'.'||g_item_audit(i);
  end loop;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  begin
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_ilog)=false then
      null;
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created '||l_ilog||' with '||sql%rowcount||' rows '||get_time);
    end if;
  exception when others then
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message);
    g_status:=false;
    return false;
  end ;
  l_stmt:='create table '||g_fa_ilog||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  ';
  l_stmt:=l_stmt||' as select '||g_hold_table||'.rowid row_id from '||g_hold_table||
    ' MINUS select row_id from '||l_ilog;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  begin
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_fa_ilog)=false then
      null;
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created '||g_fa_ilog||' with '||sql%rowcount||' rows '||get_time);
    end if;
  exception when others then
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message);
    g_status:=false;
    return false;
  end ;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_ilog)=false then
    null;
  end if;
  if g_parallel is null then
    l_stmt:='insert into '||g_fact_audit_name;
  else
    l_stmt:='insert /*+PARALLEL('||g_fact_audit_name||','||g_parallel||')*/ into '||g_fact_audit_name;
  end if;
  l_stmt:=l_stmt||'(';
  for i in 1..g_item_audit_number_all loop
    l_stmt:=l_stmt||g_item_audit_all(i)||',';
  end loop;
  if g_creation_date_flag then
    l_stmt:=l_stmt||'CREATION_DATE,';
  end if;
  if g_last_update_date_flag then
    l_stmt:=l_stmt||'LAST_UPDATE_DATE,';
  end if;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  l_stmt:=l_stmt||')';
  l_stmt:=l_stmt||' select /*+ORDERED ('||g_hold_table||')*/ ';
  for i in 1..g_item_audit_number_all loop
    l_stmt:=l_stmt||g_item_audit_all(i)||',';
  end loop;
  if g_creation_date_flag then
    l_stmt:=l_stmt||'SYSDATE,';
  end if;
  if g_last_update_date_flag then
    l_stmt:=l_stmt||'SYSDATE,';
  end if;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  l_stmt:=l_stmt||' from '||g_fa_ilog||','||g_hold_table||' where '||
  g_hold_table||'.rowid='||g_fa_ilog||'.row_id';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  begin
    EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Inserted '||sql%rowcount||' rows into '||g_fact_audit_name||get_time);
    end if;
    commit;
  exception when others then
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message);
    g_status:=false;
    return false;
  end ;
  /*
  here g_fa_rec_log is being used for any future error recovery
  */
  l_stmt1:='create table '||g_fa_rec_up_log||'(row_id rowid)'||' tablespace '||g_op_table_space;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt1);
  end if;
  execute immediate l_stmt1;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_fa_ilog)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

/*
insert into fact nc all new rows of fact
*/
function insert_nc_fact_insert return boolean is
l_stmt varchar2(32000);
l_stmt1 varchar2(4000);
Begin
  if g_debug then
    write_to_log_file_n('In insert_nc_fact_insert'||get_time);
  end if;
  if EDW_OWB_COLLECTION_UTIL.check_table(g_nc_rec_log)=true then
    write_to_log_file_n(g_nc_rec_log||' table found. No need to execute this procedure');
    return true;
  end if;
  if g_parallel is null then
    l_stmt:='insert into '||g_fact_net_change_name;
  else
    l_stmt:='insert /*+PARALLEL('||g_fact_net_change_name||','||g_parallel||')*/ into '||g_fact_net_change_name;
  end if;
  l_stmt:=l_stmt||'(';
  for i in 1..g_item_net_change_number_all loop
    l_stmt:=l_stmt||g_item_net_change_all(i)||',';
  end loop;
  if g_creation_date_flag then
    l_stmt:=l_stmt||'CREATION_DATE,';
  end if;
  if g_last_update_date_flag then
    l_stmt:=l_stmt||'LAST_UPDATE_DATE,';
  end if;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  l_stmt:=l_stmt||')';
  l_stmt:=l_stmt||' select ';
  --if g_parallel is not null then
    --l_stmt:=l_stmt||'/*+PARALLEL('||g_fact_audit_net_table||','||g_parallel||')*/ ';
  --end if;
  for i in 1..g_item_net_change_number_all loop
    l_stmt:=l_stmt||g_item_net_change_all(i)||',';
  end loop;
  if g_creation_date_flag then
    l_stmt:=l_stmt||'SYSDATE,';
  end if;
  if g_last_update_date_flag then
    l_stmt:=l_stmt||'SYSDATE,';
  end if;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  l_stmt:=l_stmt||' from '||g_fact_audit_net_table;

  /*
  we are dropping and recreating this table g_fact_net_change_net_table. so what about error recovery?
  */
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  begin
    EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Inserted '||sql%rowcount||' rows into '||g_fact_net_change_name||get_time);
    end if;
    commit;
  exception when others then
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message);
    g_status:=false;
    return false;
  end ;
  /*
  here g_nc_rec_log is being used for any future error recovery
  */
  l_stmt1:='create table '||g_nc_rec_log||'(row_id rowid)'||' tablespace '||g_op_table_space;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt1);
  end if;
  execute immediate l_stmt1;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_nc_ilog)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

/*
insert into fact net_change all  update of fact
*/
function insert_nc_fact_update return boolean is
l_stmt varchar2(32000);
l_ilog varchar2(400);
l_stmt1 varchar2(4000);
Begin
  /*
   for columns that have changed, insert
  */
  if g_debug then
    write_to_log_file_n('In insert_nc_fact_update'||get_time);
  end if;
  if EDW_OWB_COLLECTION_UTIL.check_table(g_nc_rec_up_log)=true then
    write_to_log_file_n(g_nc_rec_up_log||' table found. No need to execute this procedure');
    return true;
  end if;
  l_ilog:=g_nc_ilog||'1';
  l_stmt:='create table '||l_ilog||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  ';
  if g_fact_use_nl then
    l_stmt:=l_stmt||' as select /*+ORDERED USE_NL('||g_factTableName||')*/ ';
  else
    l_stmt:=l_stmt||' as select /*+ORDERED*/ ';
  end if;
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+PARALLEL('||g_factTableName||','||g_parallel||')*/ ';
  end if;
  l_stmt:=l_stmt||g_hold_table||'.rowid row_id from '||g_hold_table||','||g_factTableName;
  l_stmt:=l_stmt||' where '||g_hold_table||'.row_id1='||g_factTableName||'.rowid ';
  for i in 1..g_item_net_change_number loop
    l_stmt:=l_stmt||' and '||g_hold_table||'.'||g_item_net_change(i)||'='||
    g_factTableName||'.'||g_item_net_change(i);
  end loop;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  begin
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_ilog)=false then
      null;
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created '||l_ilog||' with '||sql%rowcount||' rows '||get_time);
    end if;
  exception when others then
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message);
    g_status:=false;
    return false;
  end ;
  l_stmt:='create table '||g_nc_ilog||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  ';
  l_stmt:=l_stmt||' as select '||g_hold_table||'.rowid row_id from '||g_hold_table||
    ' MINUS select row_id from '||l_ilog;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  begin
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_nc_ilog)=false then
      null;
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created '||g_nc_ilog||' with '||sql%rowcount||' rows '||get_time);
    end if;
  exception when others then
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message);
    g_status:=false;
    return false;
  end ;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_ilog)=false then
    null;
  end if;
  if g_parallel is null then
    l_stmt:='insert into '||g_fact_net_change_name;
  else
    l_stmt:='insert /*+PARALLEL('||g_fact_net_change_name||','||g_parallel||')*/ into '||g_fact_net_change_name;
  end if;
  l_stmt:=l_stmt||'(';
  for i in 1..g_item_net_change_number_all loop
    l_stmt:=l_stmt||g_item_net_change_all(i)||',';
  end loop;
  if g_creation_date_flag then
    l_stmt:=l_stmt||'CREATION_DATE,';
  end if;
  if g_last_update_date_flag then
    l_stmt:=l_stmt||'LAST_UPDATE_DATE,';
  end if;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  l_stmt:=l_stmt||')';
  if g_fact_use_nl then
    l_stmt:=l_stmt||' select /*+ORDERED USE_NL('||g_factTableName||')*/ ';
  else
    l_stmt:=l_stmt||' select /*+ORDERED*/ ';
  end if;
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+PARALLEL('||g_factTableName||','||g_parallel||')*/ ';
  end if;
  for i in 1..g_item_net_change_number_all loop
    if EDW_OWB_COLLECTION_UTIL.value_in_table(g_factFKName,g_numberOfDimTables,g_item_net_change_all(i)) then
      l_stmt:=l_stmt||g_hold_table||'.'||g_item_net_change_all(i)||',';
    else
      if g_item_net_change_all(i) <> g_factPKNameKey and g_item_net_change_all(i) <> g_factPKName then
        l_stmt:=l_stmt||g_hold_table||'.'||g_item_net_change_all(i)||'-'||
        g_factTableName||'.'||g_item_net_change_all(i)||',';
      else
        l_stmt:=l_stmt||g_hold_table||'.'||g_item_net_change_all(i)||',';
      end if;
    end if;
  end loop;
  if g_creation_date_flag then
    l_stmt:=l_stmt||'SYSDATE,';
  end if;
  if g_last_update_date_flag then
    l_stmt:=l_stmt||'SYSDATE,';
  end if;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  l_stmt:=l_stmt||' from '||g_nc_ilog||','||g_hold_table||','||g_factTableName||' where '||
  g_hold_table||'.rowid='||g_nc_ilog||'.row_id and '||g_hold_table||'.row_id1='||g_factTableName||'.rowid';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  begin
    EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Inserted '||sql%rowcount||' rows into '||g_fact_net_change_name||get_time);
    end if;
    commit;
  exception when others then
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message);
    g_status:=false;
    return false;
  end ;
  /*
  here g_nc_rec_log is being used for any future error recovery
  */
  l_stmt1:='create table '||g_nc_rec_up_log||'(row_id rowid)'||' tablespace '||g_op_table_space;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt1);
  end if;
  execute immediate l_stmt1;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_nc_ilog)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function drop_fa_nc_rec_tables return boolean is
Begin
  if g_fact_audit then
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_fa_rec_log)=false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_fa_rec_up_log)=false then
      null;
    end if;
  end if;
  if g_fact_net_change then
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_nc_rec_log)=false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_nc_rec_up_log)=false then
      null;
    end if;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function reset_profiles return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In reset_profiles'||get_time);
  end if;
  EDW_ALL_COLLECT.reset_profiles;
  g_collection_size:=EDW_ALL_COLLECT.g_collection_size;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

procedure insert_into_load_progress(p_load_fk number,p_object_name varchar2,p_load_progress varchar2,
  p_start_date date,p_end_date date,p_category varchar2, p_operation varchar2,p_seq_id varchar2,p_flag varchar2) is
Begin
  EDW_OWB_COLLECTION_UTIL.insert_into_load_progress(p_load_fk,p_object_name,g_primary_target,p_load_progress,
  p_start_date,p_end_date,p_category,p_operation,p_seq_id,p_flag,g_primary_target);
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
    EDW_OWB_COLLECTION_UTIL.insert_into_load_progress(p_load_fk,p_object_name,g_primary_target,p_load_progress,
    p_start_date,p_end_date,p_category,p_operation,p_seq_id,p_flag,g_primary_target);
    commit;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
End;

procedure analyze_target_tables is
l_date date;
l_analyze boolean:=false;
l_diff number;
l_use_job boolean;
---
l_fact_audit varchar2(20);
l_fact_net_change varchar2(20);
l_job_id number;
---
Begin
  l_date:=EDW_OWB_COLLECTION_UTIL.last_analyzed_date(g_primary_target_name,g_table_owner);
  if g_debug then
    write_to_log_file_n('Last analyzed date for '||g_primary_target_name||' '||
    to_char(l_date,'MM-DD-YYYY HH24:MI:SS'));
  end if;
  if g_object_type='FACT' then
    if (l_date is null or (sysdate-l_date)>=g_analyze_freq) then
      l_analyze:=true;
    end if;
  else
    if l_date is null or (sysdate-l_date)>=g_analyze_freq then
      l_analyze:=true;
    end if;
  end if;
  l_use_job:=false;
  if g_max_threads is not null and g_max_threads>1 and l_analyze and g_job_queue_processes>0
    and l_date is not null then
    l_use_job:=true;
  end if;
  if l_analyze then
    l_fact_audit:='N';
    l_fact_net_change:='N';
    if g_fact_audit then
      l_fact_audit:='Y';
    end if;
    if g_fact_net_change then
      l_fact_net_change:='Y';
    end if;
    if l_use_job then
      if g_debug then
        write_to_log_file_n('Going to launch dbms job for analyze '||get_time);
        write_to_log_file('EDW_MAPPING_COLLECT.analyze_target_tables('||
        ''||g_load_pk||','||
        ''''||g_table_owner||''','||
        ''''||g_primary_target_name||''','||
        ''||g_primary_target||','||
        ''''||l_fact_audit||''','||
        ''''||nvl(g_fact_audit_name,'null')||''','||
        ''''||l_fact_net_change||''','||
        ''''||nvl(g_fact_net_change_name,'null')||''','||
        ''||nvl(g_number_da_cols,0)||','||
        ''''||nvl(g_da_table,'null')||''','||
        ''''||nvl(g_pp_table,'null')||''');');
      end if;
      DBMS_JOB.SUBMIT(l_job_id,'EDW_MAPPING_COLLECT.analyze_target_tables('||
      ''||g_load_pk||','||
      ''''||g_table_owner||''','||
      ''''||g_primary_target_name||''','||
      ''||g_primary_target||','||
      ''''||l_fact_audit||''','||
      ''''||nvl(g_fact_audit_name,'null')||''','||
      ''''||l_fact_net_change||''','||
      ''''||nvl(g_fact_net_change_name,'null')||''','||
      ''||nvl(g_number_da_cols,0)||','||
      ''''||nvl(g_da_table,'null')||''','||
      ''''||nvl(g_pp_table,'null')||''');');
      commit;
      if g_debug then
        write_to_log_file_n('Job '||l_job_id||' launched '||get_time);
      end if;
    else
      if g_debug then
        write_to_log_file_n('Going to analyse target tables in serial manner '||get_time);
      end if;
      analyze_target_tables(g_load_pk,g_table_owner,g_primary_target_name,g_primary_target,
      l_fact_audit,g_fact_audit_name,l_fact_net_change,g_fact_net_change_name,
      g_number_da_cols,g_da_table,g_pp_table);
    end if;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
End;

--called as a job or in serial from analyze_target_tables
procedure analyze_target_tables(
p_load_pk number,
p_table_owner varchar2,
p_primary_target_name varchar2,
p_primary_target number,
p_fact_audit varchar2,
p_fact_audit_name varchar2,
p_fact_net_change varchar2,
p_fact_net_change_name varchar2,
p_number_da_cols number,
p_da_table varchar2,
p_pp_table varchar2
) is
Begin
  g_primary_target:=p_primary_target;
  g_primary_target_name:=p_primary_target_name;
  g_table_owner:=p_table_owner;
  insert_into_load_progress_d(p_load_pk,p_primary_target_name,'Analyze '||p_primary_target_name,sysdate,null,
  'MAPPING','ANALYZE','ANFT','I');
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(p_primary_target_name,p_table_owner,1);
  insert_into_load_progress_d(p_load_pk,null,null,null,sysdate,null,null,'ANFT','U');
  if p_fact_audit='Y' then
    insert_into_load_progress_d(p_load_pk,p_primary_target_name,'Analyze '||p_fact_audit_name,sysdate,null,
    'MAPPING','ANALYZE','ANFA','I');
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(p_fact_audit_name, p_table_owner,1);
    insert_into_load_progress_d(p_load_pk,null,null,null,sysdate,null,null,'ANFA','U');
  end if;
  if p_fact_net_change='Y' then
    insert_into_load_progress_d(p_load_pk,p_primary_target_name,'Analyze '||p_fact_net_change_name,sysdate,null,
    'MAPPING','ANALYZE','ANFN','I');
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(p_fact_net_change_name,p_table_owner,1);
    insert_into_load_progress_d(p_load_pk,null,null,null,sysdate,null,null,'ANFN','U');
  end if;
  if p_number_da_cols > 0 then
    declare
      l_owner varchar2(400);
    begin
      l_owner:=EDW_OWB_COLLECTION_UTIL.get_table_owner(p_da_table);
      EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(p_da_table,instr(p_da_table,'.')+1,
      length(p_da_table)),l_owner,1);
      EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(p_pp_table,instr(p_pp_table,'.')+1,
      length(p_pp_table)),l_owner,1);
    end;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
End;


function create_da_pp_tables return boolean is
l_stmt varchar2(2000);
l_table_space varchar2(400);
l_initial_extent number;
l_next_extent number;
l_pct_free number;
l_pct_used number;
l_pct_increase number;
l_max_extents number;
l_avg_row_len number;
l_da_table_found boolean;
l_pp_table_found boolean;
l_divide number;
Begin
  if g_debug then
    write_to_log_file_n('In create_da_pp_tables');
  end if;
  l_da_table_found:=EDW_OWB_COLLECTION_UTIL.check_table(g_da_table);
  l_pp_table_found:=EDW_OWB_COLLECTION_UTIL.check_table(g_pp_table);
  if l_da_table_found and l_pp_table_found then
    return true;
  end if;
  if EDW_OWB_COLLECTION_UTIL.get_table_storage(g_primary_target_name,g_table_owner,l_table_space,
  l_initial_extent,l_next_extent,l_pct_free,l_pct_used,l_pct_increase,l_max_extents,l_avg_row_len)=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    g_status:=false;
    return false;
  end if;
  l_next_extent:=nvl(l_next_extent,8388608);--8M
  l_pct_increase:=nvl(l_pct_increase,0);
  l_max_extents:=nvl(l_max_extents,2147483645);
  if g_parallel is null then
    l_divide:=2;
  else
    l_divide:=g_parallel;
  end if;
  if l_next_extent>16777216 then --16M
    l_next_extent:=16777216;
  end if;
  --create table a (x number) tablespace USER_DATA storage (initial 10K next 10 K pctincrease 0 maxextents 200)
  -- pctfree 10 pctused 40
  if l_da_table_found=false then
    if l_next_extent is not null then
      l_stmt:='create table '||g_da_table||' tablespace '||l_table_space||' storage (initial '||l_initial_extent||
      ' next '||(l_next_extent)||' pctincrease '||l_pct_increase||' maxextents '||l_max_extents||') pctfree '||
      l_pct_free||' pctused '||l_pct_used;
    else
      l_stmt:='create table '||g_da_table||' tablespace '||l_table_space;
    end if;
    l_stmt:=l_stmt||' as select ';
    for i in 1..g_number_da_cols loop
      l_stmt:=l_stmt||g_da_cols(i)||',';
    end loop;
    if g_instance_column is not null then
      l_stmt:=l_stmt||g_instance_column||',';
    end if;
    l_stmt:=l_stmt||g_factPKName||','||g_factPKNameKey||',sysdate CREATION_DATE,sysdate LAST_UPDATE_DATE from '||
    g_primary_target_name||' where 1=2';
    if g_debug then
      write_to_log_file_n('going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    --create index a_u on a(x) tablespace USER_DATA storage (initial 20000 next 20000 pctincrease 0 maxextents 200)
    l_stmt:='create unique index '||g_da_table||'u on '||g_da_table||'(';
    for i in 1..g_number_da_cols loop
      l_stmt:=l_stmt||g_da_cols(i)||',';
    end loop;
    l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
    if l_next_extent is not null then
      l_stmt:=l_stmt||') tablespace '||l_table_space||' storage (initial '||l_initial_extent||
      ' next '||((l_next_extent/l_divide)/l_divide)||' pctincrease '||l_pct_increase||' maxextents '||l_max_extents||')';
    else
      l_stmt:=l_stmt||') tablespace '||l_table_space;
    end if;
    if g_debug then
      write_to_log_file_n('going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
  end if;
  if l_pp_table_found=false then
    -- create table b (x primary key) organization index tablespace USER_DATA storage (initial 10K next 10 K
    --pctincrease 0 maxextents 200)  as select x from a;
    if l_next_extent is not null then
      l_stmt:='create table '||g_pp_table||'(PK primary key,PK_KEY,LOADED_PK,'||
      'CREATION_DATE) organization index tablespace '||l_table_space||' storage (initial '||l_initial_extent||
      ' next '||(l_next_extent/l_divide)||' pctincrease '||l_pct_increase||' maxextents '||l_max_extents||')';
    else
      l_stmt:='create table '||g_pp_table||'(PK primary key,PK_KEY,LOADED_PK,'||
      'CREATION_DATE) organization index tablespace '||l_table_space;
    end if;
    l_stmt:=l_stmt||' as select ';
    l_stmt:=l_stmt||g_factPKName||','||g_factPKNameKey||','||g_factPKName||' LOADED_PK,sysdate CREATION_DATE from '||
    g_primary_target_name||' where 1=2';
    if g_debug then
      write_to_log_file_n('going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

/*
given the da columns for the ltc table, what are the da columns of the stg table?
*/
--g_stg_da_cols
function get_stg_da_columns return boolean is
l_src_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_tgt_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_cols number;
Begin
  if g_debug then
    write_to_log_file_n('In get_stg_da_columns');
  end if;
  if EDW_OWB_COLLECTION_UTIL.get_obj_obj_map_details(g_primary_src_name,g_primary_target_name,
  null,l_src_cols,l_tgt_cols,l_number_cols )=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    g_status:=false;
    return false;
  end if;
  for i in 1..g_number_da_cols loop
    g_stg_da_cols(i):=g_da_cols(i);
    for j in 1..l_number_cols loop
      if g_da_cols(i)=l_tgt_cols(j) then
        g_stg_da_cols(i):=l_src_cols(j);
        exit;
      end if;
    end loop;
  end loop;
  if g_debug then
    write_to_log_file_n('g_da_cols  and g_stg_da_cols');
    for i in 1..g_number_da_cols loop
      write_to_log_file(g_da_cols(i)||'   '||g_stg_da_cols(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

/*
this function gets called only once when the customer is upgrading to data alignment.
na_edw and na_err are populated by the na_edw program into the pp table
*/
function populate_da_pp_tables return boolean is
l_stmt varchar2(10000);
l_da_table varchar2(400);
l_da_table_dis varchar2(400);
l_status number;
l_status_pp number;
l_status_dim number;
l_dis_count number;
l_da_count number;
l_owner varchar2(400);
l_master_da_table_dis1 varchar2(400);
l_master_da_table_dis2 varchar2(400);
l_master_da_table_dis3 varchar2(400);
l_pp_table_temp varchar2(400);
l_table varchar2(400);
Begin
  l_status:=EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_da_table);
  l_status_pp:=EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_pp_table);
  l_status_dim:=EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_primary_target_name);
  if l_status=0 or l_status_dim=0 or l_status_pp=0 then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    g_status:=false;
    return false;
  end if;
  if l_status=2 and l_status_pp=2 then
    return true;
  end if;
  if l_status_dim=1 then
    return true;
  end if;
  l_da_table:=g_da_op_table||'A';
  l_da_table_dis:=g_da_op_table||'B';
  l_master_da_table_dis1:=g_da_op_table||'C';
  l_master_da_table_dis2:=g_da_op_table||'D';
  l_master_da_table_dis3:=g_da_op_table||'E';
  l_pp_table_temp:=g_pp_table||'F';
  if g_master_instance is not null and g_instance_column is null then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.get_message('EDW_INSTANCE_COL_NOT_FOUND');
    write_to_log_file_n(g_status_message);
    g_status:=false;
    return false;
  end if;
  l_stmt:='create table '||l_da_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  as select ';
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+PARALLEL('||g_primary_target_name||','||g_parallel||')*/ ';
  end if;
  for i in 1..g_number_da_cols loop
    l_stmt:=l_stmt||g_da_cols(i)||',';
  end loop;
  l_stmt:=l_stmt||g_factPKName||','||g_factPKNameKey;
  if g_master_instance is not null then
    l_stmt:=l_stmt||','||g_instance_column;
  end if;
  l_stmt:=l_stmt||' from '||g_primary_target_name;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_da_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('created '||l_da_table||' with '||sql%rowcount||' rows '||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_da_table,instr(l_da_table,'.')+1,
  length(l_da_table)),substr(l_da_table,1,instr(l_da_table,'.')-1));
  if l_status=1 then
    l_stmt:='create table '||l_da_table_dis||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  as select ';
    for i in 1..g_number_da_cols loop
      l_stmt:=l_stmt||g_da_cols(i)||',';
    end loop;
    l_stmt:=l_stmt||'max('||g_factPKNameKey||') '||g_factPKNameKey||' from '||l_da_table||' group by ';
    for i in 1..g_number_da_cols loop
      l_stmt:=l_stmt||g_da_cols(i)||',';
    end loop;
    l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_da_table_dis)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('created '||l_da_table_dis||' with '||sql%rowcount||' rows '||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_da_table_dis,instr(l_da_table_dis,'.')+1,
    length(l_da_table_dis)),substr(l_da_table_dis,1,instr(l_da_table_dis,'.')-1));
    l_dis_count:=EDW_OWB_COLLECTION_UTIL.get_table_count(l_da_table_dis);
    l_da_count:=EDW_OWB_COLLECTION_UTIL.get_table_count(l_da_table);
    if g_debug then
      write_to_log_file_n('l_dis_count='||l_dis_count||'  ,l_da_count='||l_da_count);
    end if;
    if l_dis_count <> l_da_count and g_master_instance is not null then
      l_stmt:='create table '||l_master_da_table_dis1||' tablespace '||g_op_table_space;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  as select ';
      for i in 1..g_number_da_cols loop
        l_stmt:=l_stmt||g_da_cols(i)||',';
      end loop;
      l_stmt:=l_stmt||'max('||g_factPKNameKey||') '||g_factPKNameKey||' from '||l_da_table||' where '||
      g_instance_column||'='''||g_master_instance||''' group by ';
      for i in 1..g_number_da_cols loop
        l_stmt:=l_stmt||g_da_cols(i)||',';
      end loop;
      l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_master_da_table_dis1)=false then
        null;
      end if;
      if g_debug then
        write_to_log_file_n('going to execute '||l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('created '||l_master_da_table_dis1||' with '||sql%rowcount||' rows '||get_time);
      end if;
      EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_master_da_table_dis1,instr(l_master_da_table_dis1,'.')+1,
      length(l_master_da_table_dis1)),substr(l_master_da_table_dis1,1,instr(l_master_da_table_dis1,'.')-1));
      l_stmt:='create table '||l_master_da_table_dis2||' tablespace '||g_op_table_space;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  as select ';
      for i in 1..g_number_da_cols loop
        l_stmt:=l_stmt||g_da_cols(i)||',';
      end loop;
      l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
      l_stmt:=l_stmt||' from '||l_da_table_dis||' MINUS select ';
      for i in 1..g_number_da_cols loop
        l_stmt:=l_stmt||g_da_cols(i)||',';
      end loop;
      l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
      l_stmt:=l_stmt||' from '||l_master_da_table_dis1;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_master_da_table_dis2)=false then
        null;
      end if;
      if g_debug then
        write_to_log_file_n('going to execute '||l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('created '||l_master_da_table_dis2||' with '||sql%rowcount||' rows '||get_time);
      end if;
      EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_master_da_table_dis2,instr(l_master_da_table_dis2,'.')+1,
      length(l_master_da_table_dis2)),substr(l_master_da_table_dis2,1,instr(l_master_da_table_dis2,'.')-1));
      l_stmt:='create table '||l_master_da_table_dis3||' tablespace '||g_op_table_space;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  as select ';
      for i in 1..g_number_da_cols loop
        l_stmt:=l_stmt||g_da_cols(i)||',';
      end loop;
      l_stmt:=l_stmt||g_factPKNameKey||' from '||l_master_da_table_dis1||' UNION ALL select /*+ORDERED*/ ';
      for i in 1..g_number_da_cols loop
        l_stmt:=l_stmt||l_da_table_dis||'.'||g_da_cols(i)||',';
      end loop;
      l_stmt:=l_stmt||l_da_table_dis||'.'||g_factPKNameKey||' from '||l_master_da_table_dis2||','||l_da_table_dis||
      ' where ';
      for i in 1..g_number_da_cols loop
        l_stmt:=l_stmt||l_master_da_table_dis2||'.'||g_da_cols(i)||'='||l_da_table_dis||'.'||g_da_cols(i)||' and ';
      end loop;
      l_stmt:=substr(l_stmt,1,length(l_stmt)-4);
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_master_da_table_dis3)=false then
        null;
      end if;
      if g_debug then
        write_to_log_file_n('going to execute '||l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('created '||l_master_da_table_dis3||' with '||sql%rowcount||' rows '||get_time);
      end if;
      EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_master_da_table_dis3,instr(l_master_da_table_dis3,'.')+1,
      length(l_master_da_table_dis3)),substr(l_master_da_table_dis3,1,instr(l_master_da_table_dis3,'.')-1));
      --rename
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_da_table_dis)=false then
        null;
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_master_da_table_dis1)=false then
        null;
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_master_da_table_dis2)=false then
        null;
      end if;
      l_da_table_dis:=l_master_da_table_dis3;
    end if;
    l_stmt:='insert ';
    l_table:=substr(g_da_table,instr(g_da_table,'.')+1,length(g_da_table));
    if g_parallel is not null then
      l_stmt:=l_stmt||' /*+PARALLEL('||l_table||','||g_parallel||')*/ ';
    end if;
    l_stmt:=l_stmt||'into '||g_da_table||' '||l_table||'(';
    for i in 1..g_number_da_cols loop
      l_stmt:=l_stmt||g_da_cols(i)||',';
    end loop;
    if g_instance_column is not null then
      l_stmt:=l_stmt||g_instance_column||',';
    end if;
    l_stmt:=l_stmt||g_factPKName||','||g_factPKNameKey||',CREATION_DATE,LAST_UPDATE_DATE) select ';
    if g_parallel is not null then
      l_stmt:=l_stmt||' /*+PARALLEL('||g_primary_target_name||','||g_parallel||')*/ ';
    end if;
    if l_dis_count=l_da_count then
      for i in 1..g_number_da_cols loop
        l_stmt:=l_stmt||g_primary_target_name||'.'||g_da_cols(i)||',';
      end loop;
      if g_instance_column is not null then
        l_stmt:=l_stmt||g_primary_target_name||'.'||g_instance_column||',';
      end if;
      l_stmt:=l_stmt||g_primary_target_name||'.'||g_factPKName||','||g_primary_target_name||'.'||g_factPKNameKey||
      ',sysdate,sysdate from '||g_primary_target_name;
    else
      l_stmt:=l_stmt||'/*+ORDERED USE_NL('||g_primary_target_name||')*/ ';
      for i in 1..g_number_da_cols loop
        l_stmt:=l_stmt||g_primary_target_name||'.'||g_da_cols(i)||',';
      end loop;
      if g_instance_column is not null then
        l_stmt:=l_stmt||g_primary_target_name||'.'||g_instance_column||',';
      end if;
      l_stmt:=l_stmt||g_primary_target_name||'.'||g_factPKName||','||g_primary_target_name||'.'||g_factPKNameKey||
      ',sysdate,sysdate from '||l_da_table_dis||','||g_primary_target_name||' where '||
      l_da_table_dis||'.'||g_factPKNameKey||'='||g_primary_target_name||'.'||g_factPKNameKey;
    end if;
    if g_debug then
      write_to_log_file_n('going to execute '||l_stmt||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('inserted into '||g_da_table||'  '||sql%rowcount||' rows '||get_time);
    end if;
    commit;
    l_owner:=EDW_OWB_COLLECTION_UTIL.get_table_owner(g_da_table);
    --analysis here is ok because this code is executed only when the tables are empty to start with
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_da_table,instr(g_da_table,'.')+1,
    length(g_da_table)),l_owner);
  end if;
  --populate the pp table, assume its empty
  if l_status_pp=1 then
    l_table:=substr(g_da_table,instr(g_da_table,'.')+1,length(g_da_table));
    l_stmt:='create table '||l_pp_table_temp||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  as select ';
    if g_parallel is not null then
      l_stmt:=l_stmt||' /*+PARALLEL('||l_table||','||g_parallel||')*/ ';
    end if;
    l_stmt:=l_stmt||l_da_table||'.'||g_factPKName||' PK,'||l_table||'.'||g_factPKNameKey||' PK_KEY,'||l_table||'.'||
    g_factPKName||' LOADED_PK from '||l_da_table||','||g_da_table||' '||l_table||' where ';
    for i in 1..g_number_da_cols loop
      l_stmt:=l_stmt||l_da_table||'.'||g_da_cols(i)||'='||l_table||'.'||g_da_cols(i)||' and ';
    end loop;
    l_stmt:=substr(l_stmt,1,length(l_stmt)-4);
    if g_debug then
      write_to_log_file_n('going to execute '||l_stmt||get_time);
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_pp_table_temp)=false then
      null;
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created with '||sql%rowcount||get_time);
    end if;
    l_stmt:='insert ';
    l_table:=substr(g_pp_table,instr(g_pp_table,'.')+1,length(g_pp_table));
    if g_parallel is not null then
      l_stmt:=l_stmt||' /*+PARALLEL('||l_table||','||g_parallel||')*/ ';
    end if;
    l_stmt:=l_stmt||'into '||g_pp_table||' '||l_table||' (PK,PK_KEY,LOADED_PK,CREATION_DATE) select PK,PK_KEY,'||
    'LOADED_PK,SYSDATE from '||l_pp_table_temp;
    if g_debug then
      write_to_log_file_n('going to execute '||l_stmt||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('inserted into '||g_pp_table||'  '||sql%rowcount||' rows '||get_time);
    end if;
    commit;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_pp_table_temp)=false then
      null;
    end if;
    l_owner:=EDW_OWB_COLLECTION_UTIL.get_table_owner(g_pp_table);
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_pp_table,instr(g_pp_table,'.')+1,
    length(g_pp_table)),l_owner);
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_da_table)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_da_table_dis)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function sync_da_pp_tables(p_table varchar2) return boolean is
l_stmt varchar2(30000);
l_table1 varchar2(400);
l_table_A varchar2(400);
l_table varchar2(400);
Begin
  if g_debug then
    write_to_log_file_n('In sync_da_pp_tables '||get_time);
  end if;
  l_table_A:=p_table||'A';
  l_table1:=l_table_A||'1';
  l_stmt:='insert ';
  l_table:=substr(g_da_table,instr(g_da_table,'.')+1,length(g_da_table));
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+PARALLEL('||l_table||','||g_parallel||')*/ ';
  end if;
  l_stmt:=l_stmt||'into '||g_da_table||' '||l_table||'(';
  for i in 1..g_number_da_cols loop
    l_stmt:=l_stmt||g_da_cols(i)||',';
  end loop;
  if g_instance_column is not null then
    l_stmt:=l_stmt||g_instance_column||',';
  end if;
  l_stmt:=l_stmt||g_factPKName||','||g_factPKNameKey||',CREATION_DATE,LAST_UPDATE_DATE) select ';
  for i in 1..g_number_da_cols loop
    l_stmt:=l_stmt||g_da_cols(i)||',';
  end loop;
  if g_instance_column is not null then
    l_stmt:=l_stmt||p_table||'.'||g_instance_column||',';
  end if;
  l_stmt:=l_stmt||g_factPKName||'1,'||g_factPKNameKey||',sysdate,sysdate from '||p_table||' where row_id2 is null';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Inserted '||sql%rowcount||' rows into '||g_da_table||get_time);
  end if;
  commit;
  --l_table1
  loop
    l_table:=substr(g_pp_table,instr(g_pp_table,'.')+1,length(g_pp_table));
    l_stmt:='create table '||l_table1||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  ';
    l_stmt:=l_stmt||' as select /*+ORDERED*/ ';
    if g_parallel is not null then
      l_stmt:=l_stmt||' /*+PARALLEL('||l_table||','||g_parallel||')*/ ';
    end if;
    l_stmt:=l_stmt||l_table||'.PK from '||p_table||','||g_pp_table||' '||l_table||
    ' where '||p_table||'.'||g_fstgPKName||'='||l_table||'.PK';
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_table1)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created '||l_table1||' with '||sql%rowcount||' rows '||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_table1,instr(l_table1,'.')+1,
    length(l_table1)),substr(l_table1,1,instr(l_table1,'.')-1));
    l_stmt:='create table '||l_table_A||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  ';
    l_stmt:=l_stmt||' as select '||g_fstgPKName||' '||g_factPKName||' from '||p_table||' MINUS select ';
    l_stmt:=l_stmt||' PK '||g_factPKName||' from '||l_table1;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_table_A)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created '||l_table_A||' with '||sql%rowcount||' rows '||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_table_A,instr(l_table_A,'.')+1,
    length(l_table_A)),substr(l_table_A,1,instr(l_table_A,'.')-1));
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_table1)=false then
      null;
    end if;
    l_stmt:='insert ';
    l_table:=substr(g_pp_table,instr(g_pp_table,'.')+1,length(g_pp_table));
    if g_parallel is not null then
      l_stmt:=l_stmt||' /*+PARALLEL('||l_table||','||g_parallel||')*/ ';
    end if;
    l_stmt:=l_stmt||'into '||g_pp_table||' '||l_table||'(PK,PK_KEY,LOADED_PK,CREATION_DATE) '||
    'select /*+ORDERED*/ '||p_table||'.'||g_fstgPKName||','||p_table||'.'||g_factPKNameKey||','||
    p_table||'.'||g_factPKName||'1,sysdate from '||l_table_A||','||p_table||' where '||
    l_table_A||'.'||g_factPKName||'='||p_table||'.'||g_fstgPKName;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    begin
      EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Inserted '||sql%rowcount||' rows into '||g_pp_table||get_time);
      end if;
      commit;
      exit;
    exception when others then
      if g_debug then
        write_to_log_file_n('Error in insert '||sqlerrm);
      end if;
      if sqlcode=-00001 then
        rollback;
        if g_debug then
          write_to_log_file_n('Re-try insert ');
        end if;
      else
        g_status_message:=sqlerrm;
        g_status:=false;
        return false;
      end if;
    end;
  end loop;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table_A)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  return false;
End;

/*
for data alignment. if user pushes 2 instances. A from 1 and A from 2. A 2 is rejected because its duplicate.
but A 2 must have an entry in PP table for facts from 2. after creating the dup table, move row_ids to
a table. later, get the disitnct pks and p_col from stg into another table join with this row_id table. using this
new table, join to DA and populate PP
*/
function move_dup_pp_future return boolean is
l_stmt varchar2(10000);
l_dup_pp_row_id_table varchar2(400);
Begin
  if g_debug then
    write_to_log_file_n('In move_dup_pp_future');
  end if;
  if EDW_OWB_COLLECTION_UTIL.check_table(g_dup_hold_table)=false then
    return true;
  end if;
  l_dup_pp_row_id_table:=g_dup_pp_row_id_table||'A';
  if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_dup_pp_row_id_table) = 2 then
    l_stmt:='create table '||l_dup_pp_row_id_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  ';
    l_stmt:=l_stmt||' as select row_id from '||g_dup_hold_table||' MINUS select row_id from '||g_dup_pp_row_id_table;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_pp_row_id_table)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created '||l_dup_pp_row_id_table||' with '||sql%rowcount||' rows'||get_time);
    end if;
    l_stmt:='insert into '||g_dup_pp_row_id_table||'(row_id) select row_id from '||l_dup_pp_row_id_table;
    --we need l_dup_pp_row_id_table because we have encountered bug where we did insert into A select * from
    --B minus select * from A
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Inserted '||sql%rowcount||' rows into '||g_dup_pp_row_id_table||get_time);
    end if;
    commit;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_pp_row_id_table)=false then
      null;
    end if;
  else
    l_stmt:='create table '||g_dup_pp_row_id_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  ';
    l_stmt:=l_stmt||' as select row_id from '||g_dup_hold_table;
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_dup_pp_row_id_table)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created '||g_dup_pp_row_id_table||' with '||sql%rowcount||' rows'||get_time);
    end if;
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_dup_pp_row_id_table,instr(g_dup_pp_row_id_table,'.')+1,
  length(g_dup_pp_row_id_table)),substr(g_dup_pp_row_id_table,1,instr(g_dup_pp_row_id_table,'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

/*
at the end of the load, we need to look at the duplicate-collect records and insert into the PP table. we could have
pushed from instance 1 and instance 2 and loaded. we need to get the mapping between instance 1 and 2 into PP table
*/
function load_dup_coll_into_pp return boolean is
l_stmt varchar2(20000);
l_dup_pp_table varchar2(200);
l_dup_pp_table_B varchar2(200);
l_dup_pp_table_C varchar2(200);
l_table varchar2(200);
Begin
  if g_debug then
    write_to_log_file_n('In load_dup_coll_into_pp');
  end if;
  if EDW_OWB_COLLECTION_UTIL.check_table(g_dup_pp_row_id_table)=false then
    return true;
  end if;
  l_dup_pp_table:=g_dup_pp_table||'A';
  l_dup_pp_table_B:=g_dup_pp_table||'B';
  l_dup_pp_table_C:=g_dup_pp_table||'C';
  l_stmt:='create table '||l_dup_pp_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  ';
  l_stmt:=l_stmt||' as select /*+ORDERED*/ ';
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+PARALLEL('||g_fstgTableName||','||g_parallel||')*/ ';
  end if;
  l_stmt:=l_stmt||g_fstgPKName;
  for i in 1..g_number_da_cols loop
    l_stmt:=l_stmt||','||g_da_cols(i);
  end loop;
  l_stmt:=l_stmt||' from '||g_dup_pp_row_id_table||','||g_fstgTableName||' where '||
  g_dup_pp_row_id_table||'.row_id='||g_fstgTableName||'.rowid';
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_pp_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created '||l_dup_pp_table||' with '||sql%rowcount||' rows'||get_time);
  end if;
  --EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_dup_pp_table,instr(l_dup_pp_table,'.')+1,
  --length(l_dup_pp_table)),substr(l_dup_pp_table,1,instr(l_dup_pp_table,'.')-1));
  l_stmt:='create table '||l_dup_pp_table_B||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  ';
  l_stmt:=l_stmt||' as select distinct '||g_fstgPKName;
  for i in 1..g_number_da_cols loop
    l_stmt:=l_stmt||','||g_da_cols(i);
  end loop;
  l_stmt:=l_stmt||' from '||l_dup_pp_table;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_pp_table_B)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created '||l_dup_pp_table_B||' with '||sql%rowcount||' rows'||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_dup_pp_table_B,instr(l_dup_pp_table_B,'.')+1,
  length(l_dup_pp_table_B)),substr(l_dup_pp_table_B,1,instr(l_dup_pp_table_B,'.')-1));
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_pp_table)=false then
    null;
  end if;
  l_stmt:='create table '||g_dup_pp_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  ';
  l_stmt:=l_stmt||' as select /*+ORDERED*/ ';
  l_table:=substr(g_da_table,instr(g_da_table,'.')+1,length(g_da_table));
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+PARALLEL('||l_table||','||g_parallel||')*/ ';
  end if;
  l_stmt:=l_stmt||l_dup_pp_table_B||'.'||g_fstgPKName||' '||g_factPKName||','||l_table||'.'||g_factPKName||
  ' LOADED_PK,'||l_table||'.'||g_factPKNameKey||' from '||l_dup_pp_table_B||','||g_da_table||' '||l_table||' where ';
  for i in 1..g_number_da_cols loop
    l_stmt:=l_stmt||l_dup_pp_table_B||'.'||g_da_cols(i)||'='||l_table||'.'||g_da_cols(i)||' and ';
  end loop;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-4);
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dup_pp_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created '||g_dup_pp_table||' with '||sql%rowcount||' rows'||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_dup_pp_table,instr(g_dup_pp_table,'.')+1,
  length(g_dup_pp_table)),substr(g_dup_pp_table,1,instr(g_dup_pp_table,'.')-1));
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_pp_table_B)=false then
    null;
  end if;
  loop
    l_stmt:='create table '||l_dup_pp_table_C||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  ';
    l_stmt:=l_stmt||' as select '||g_factPKName||' from '||g_dup_pp_table||' MINUS select ';
    l_table:=substr(g_pp_table,instr(g_pp_table,'.')+1,length(g_pp_table));
    if g_parallel is not null then
      l_stmt:=l_stmt||' /*+PARALLEL('||l_table||','||g_parallel||')*/ ';
    end if;
    l_stmt:=l_stmt||'PK '||g_factPKName||' from '||g_pp_table||' '||l_table;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_pp_table_C)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created '||l_dup_pp_table_C||' with '||sql%rowcount||' rows'||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_dup_pp_table_C,instr(l_dup_pp_table_C,'.')+1,
    length(l_dup_pp_table_C)),substr(l_dup_pp_table_C,1,instr(l_dup_pp_table_C,'.')-1));
    l_stmt:='insert ';
    l_table:=substr(g_pp_table,instr(g_pp_table,'.')+1,length(g_pp_table));
    if g_parallel is not null then
      l_stmt:=l_stmt||' /*+PARALLEL('||l_table||','||g_parallel||')*/ ';
    end if;
    l_stmt:=l_stmt||'into '||g_pp_table||' '||l_table||'(PK,PK_KEY,LOADED_PK,CREATION_DATE) select /*+ORDERED*/ '||
    g_dup_pp_table||'.'||g_factPKName||','||g_dup_pp_table||'.'||g_factPKNameKey||','||g_dup_pp_table||'.LOADED_PK,'||
    'sysdate from '||l_dup_pp_table_C||','||g_dup_pp_table||' where '||l_dup_pp_table_C||'.'||g_factPKName||'='||
    g_dup_pp_table||'.'||g_factPKName;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    begin
      EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Inserted into '||g_pp_table||' '||sql%rowcount||' rows'||get_time);
      end if;
      commit;
      exit;
    exception when others then
      if g_debug then
        write_to_log_file_n('Error '||sqlerrm||get_time);
      end if;
      if sqlcode=-00001 then
        --value already present
        rollback;
        if g_debug then
          write_to_log_file_n('Re formulate tables and attempt '||get_time);
        end if;
      else
        g_status_message:=sqlerrm;
        g_status:=false;
        return false;
      end if;
    end;
  end loop;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dup_pp_row_id_table)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dup_pp_table)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_pp_table_C)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

/*
for data alignment, we need to mark as duplicate or duplicate collect based on NAME or other columns.
*/
function move_dup_rowid_table_general(p_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,p_number_cols number)
return number is
l_stmt varchar2(20000);
l_data_table varchar2(400);
l_data_table_count number;
l_data_table_B varchar2(400);
l_data_table_BO varchar2(400);
l_data_table_BA varchar2(400);
l_data_table_BB varchar2(400);
l_data_table_BC varchar2(400);
l_data_table_BD varchar2(400);
l_data_table_BE varchar2(400);
l_data_table_BF varchar2(400);
l_data_table_BG varchar2(400);
l_data_table_C varchar2(400);
l_data_table_D varchar2(400);
l_data_table_D_count number;
l_data_table_DM varchar2(400);
l_data_table_DM_count number;
l_data_table_DN varchar2(400);
l_data_table_DN_count number;
l_data_table_DR varchar2(400);
l_data_table_F varchar2(400);
l_data_table_G varchar2(400);
l_data_table_H varchar2(400);
l_data_table_I varchar2(400);
l_data_table_J varchar2(400);
l_dup_value_table  varchar2(400);
l_dup_table  varchar2(400);
l_dup_max_table  varchar2(400);
l_dup_max_rowid_table  varchar2(400);
l_count number;
l_col  varchar2(100);
l_instance_in_pcol boolean:=false;--instance column is a part of p_col
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_res number:=null;
l_table varchar2(400);
l_dup_hold_table_count number;
Begin
  if g_debug then
    write_to_log_file_n('In move_dup_rowid_table_general');
    for i in 1..p_number_cols loop
      write_to_log_file(p_cols(i));
    end loop;
  end if;
  --create a table that holds the rowid and col info
  l_data_table:=g_da_op_table||'A';
  l_data_table_BO:=g_da_op_table||'BO';--join data table with DA where p_col match
  l_data_table_BA:=g_da_op_table||'BA';--from BO where not master instance
  l_data_table_BB:=g_da_op_table||'BB';--p_col from BO where instance=master
  l_data_table_BC:=g_da_op_table||'BC';--p_col, row_id,row_id1 from BO and data where p_col match and instance match
  l_data_table_BD:=g_da_op_table||'BD';--BC-BB p_col
  l_data_table_BE:=g_da_op_table||'BE';--join BD and BC row_id,row_id1
  l_data_table_BF:=g_da_op_table||'BF';--to update DA. row_id2 from BB where not master instance
  l_data_table_BG:=g_da_op_table||'BG';--IOT.row_id from F. if dup coll=no,where count=1. else distinct row_id.update DA
  l_data_table_B:=g_da_op_table||'B';--BA-BE row_id,row_id1. those that must not go
  l_data_table_C:=g_da_op_table||'C';--A-B
  l_data_table_D:=g_da_op_table||'D';--all records that are either master intance or others. join A and C
  l_data_table_DM:=g_da_op_table||'DM';--from D where master instance
  l_data_table_DR:=g_da_op_table||'DR';--p_cols : D MINUS DM
  l_data_table_DN:=g_da_op_table||'DN';--from D where not master instance join D and DR
  l_data_table_F:=g_da_op_table||'F';--max(col) from DM group by p_col
  l_data_table_G:=g_da_op_table||'G';--row_id from DM join with F
  l_data_table_H:=g_da_op_table||'H';--max(col) from DN group by p_col
  l_data_table_I:=g_da_op_table||'I';--row_id from DN join with H
  l_data_table_J:=g_da_op_table||'J';--G union all I
  l_dup_value_table:=g_da_op_table||'E';
  l_dup_table:=g_da_op_table||'U';
  l_dup_max_table:=g_da_op_table||'M';
  l_dup_max_rowid_table:=g_da_op_table||'R';
  if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_fstgTableName,'LAST_UPDATE_DATE IS NOT NULL')=2 then
    l_col:='LAST_UPDATE_DATE';
  else
    l_col:='ROWNUM';
  end if;
  if g_master_instance is not null then
    if EDW_OWB_COLLECTION_UTIL.value_in_table(p_cols,p_number_cols,g_instance_column) then
      if g_debug then
        write_to_log_file_n(g_instance_column||' is a part of p_col');
      end if;
      l_instance_in_pcol:=true;
    end if;
  end if;
  <<start_dup_check>>
  l_stmt:='create table '||l_data_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  ';
  l_stmt:=l_stmt||' as select /*+ORDERED*/ ';
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+PARALLEL('||g_fstgTableName||','||g_parallel||')*/ ';
  end if;
  for i in 1..p_number_cols loop
    l_stmt:=l_stmt||g_fstgTableName||'.'||p_cols(i)||',';
  end loop;
  if g_master_instance is not null and l_instance_in_pcol=false then
    l_stmt:=l_stmt||g_fstgTableName||'.'||g_instance_column||',';
  end if;
  if l_col='LAST_UPDATE_DATE' then
    l_stmt:=l_stmt||g_fstgTableName||'.'||l_col||' col,';
  else
    l_stmt:=l_stmt||'ROWNUM col,';
  end if;
  l_stmt:=l_stmt||g_fstgTableName||'.rowid row_id from '||g_reqid_table||','||g_fstgTableName||' where '||
  g_reqid_table||'.row_id='||g_fstgTableName||'.rowid ';
  if EDW_OWB_COLLECTION_UTIL.create_table(l_data_table,l_stmt,l_count)=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    g_status:=false;
    return 0;
  end if;
  if l_col='LAST_UPDATE_DATE' then
    l_stmt:='select 1 from '||l_data_table||' having count(*)>1 group by col';
    for i in 1..p_number_cols loop
      l_stmt:=l_stmt||','||p_cols(i);
    end loop;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    open cv for l_stmt;
    fetch cv into l_res;
    if g_debug then
      write_to_log_file(get_time);
    end if;
    close cv;
    if l_res=1 then
      l_col:='ROWNUM';
      write_to_log_file_n('LAST_UPDATE_DATE is duplicate. Trying with ROWNUM');
      goto start_dup_check;
    end if;
  end if;
  l_data_table_D:=l_data_table;--initialize
  l_data_table_D_count:=l_data_table_count;
  if g_master_instance is not null then
    --master instance alone can update non master instance records
    --if DA table has a record from inst 2 and data table has the same record from instance 2
    --we must allow update
    --if DA table has a record from inst 2 and data table has the same record from master inst
    --only master can update
    l_stmt:='create table '||l_data_table_BO||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  ';
    l_stmt:=l_stmt||' as select /*+ORDERED*/ ';
    l_table:=substr(g_da_table,instr(g_da_table,'.')+1,length(g_da_table));
    if g_parallel is not null then
      l_stmt:=l_stmt||' /*+PARALLEL('||l_table||','||g_parallel||')*/ ';
    end if;
    for i in 1..p_number_cols loop
     l_stmt:=l_stmt||l_table||'.'||p_cols(i)||',';
    end loop;
    if l_instance_in_pcol=false then
      l_stmt:=l_stmt||l_table||'.'||g_instance_column||',';
    end if;
    l_stmt:=l_stmt||l_data_table||'.'||g_instance_column||' '||g_instance_column||'1,';
    l_stmt:=l_stmt||l_data_table||'.rowid row_id,'||l_data_table||'.row_id row_id1,'||
    l_table||'.rowid row_id2 from '||l_data_table||','||g_da_table||' '||l_table||' where ';
    for i in 1..p_number_cols loop
      l_stmt:=l_stmt||l_data_table||'.'||p_cols(i)||'='||l_table||'.'||p_cols(i)||' and ';
    end loop;
    l_stmt:=substr(l_stmt,1,length(l_stmt)-4);
    if EDW_OWB_COLLECTION_UTIL.create_table(l_data_table_BO,l_stmt,l_count)=false then
      g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
      g_status:=false;
      return 0;
    end if;
    if l_count>0 then
      l_stmt:='create table '||l_data_table_BA||' tablespace '||g_op_table_space;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  ';
      l_stmt:=l_stmt||' as select row_id,row_id1 from '||l_data_table_BO||' where '||
      g_instance_column||'1<>'''||g_master_instance||'''';
      if EDW_OWB_COLLECTION_UTIL.create_table(l_data_table_BA,l_stmt,l_count)=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        g_status:=false;
        return 0;
      end if;
      l_stmt:='create table '||l_data_table_BB||' tablespace '||g_op_table_space;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  ';
      l_stmt:=l_stmt||' as select ';
      for i in 1..p_number_cols loop
       l_stmt:=l_stmt||p_cols(i)||',';
      end loop;
      l_stmt:=l_stmt||'row_id2,'||g_instance_column;
      l_stmt:=l_stmt||' from '||l_data_table_BO||' where '||
      g_instance_column||'1='''||g_master_instance||'''';
      if EDW_OWB_COLLECTION_UTIL.create_table(l_data_table_BB,l_stmt,l_count)=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        g_status:=false;
        return 0;
      end if;
      --if B table has data,we may need to update the DA table
      --say instance in DA is 2 for A. now comes A from 1 which is master. so DA entry must update
      --to 1 so that next time A comes from 2, its rejected.
      if l_count>0 then
        l_stmt:='create table '||l_data_table_BF||' tablespace '||g_op_table_space;
        if g_parallel is not null then
          l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
        end if;
        l_stmt:=l_stmt||'  ';
        l_stmt:=l_stmt||' as select row_id2 from '||l_data_table_BB||' where '||
        g_instance_column||'<>'''||g_master_instance||'''';
        if EDW_OWB_COLLECTION_UTIL.create_table(l_data_table_BF,l_stmt,l_count)=false then
          g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
          g_status:=false;
          return 0;
        end if;
        if l_count>0 then
          if g_duplicate_collect then
            --4161164 : remove IOT , replace with ordinary table and index
            --l_stmt:='create table '||l_data_table_BG||'(row_id primary key) organization index '||
            l_stmt:='create table '||l_data_table_BG||
            ' tablespace '||g_op_table_space;
            if g_parallel is not null then
              l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
            end if;
            l_stmt:=l_stmt||'  ';
            l_stmt:=l_stmt||' as select distinct row_id2 row_id from '||l_data_table_BF;
          else
            --4161164 : remove IOT , replace with ordinary table and index
            --l_stmt:='create table '||l_data_table_BG||'(row_id primary key) organization index '||
            l_stmt:='create table '||l_data_table_BG||
            ' tablespace '||g_op_table_space;
            if g_parallel is not null then
              l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
            end if;
            l_stmt:=l_stmt||'  ';
            l_stmt:=l_stmt||' as select row_id2 row_id from '||l_data_table_BF||' having count(row_id2)=1 '||
            'group by row_id2';
          end if;
          if EDW_OWB_COLLECTION_UTIL.create_table(l_data_table_BG,l_stmt,l_count)=false then
            g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
            g_status:=false;
            return 0;
          end if;
          --4161164 : remove IOT , replace with ordinary table and index
          EDW_OWB_COLLECTION_UTIL.create_iot_index(l_data_table_BG,'row_id',g_op_table_space,g_parallel);
          l_table:=substr(g_da_table,instr(g_da_table,'.')+1,length(g_da_table));
          l_stmt:='update /*+ORDERED USE_NL('||l_table||')*/ ';
          if g_parallel is not null then
            l_stmt:=l_stmt||' /*+PARALLEL('||l_table||','||g_parallel||')*/ ';
          end if;
          l_stmt:=l_stmt||g_da_table||' '||l_table||' set '||g_instance_column||'='''||g_master_instance||''','||
          'LAST_UPDATE_DATE=sysdate where rowid in (select row_id from '||l_data_table_BG||')';
          if g_debug then
            write_to_log_file_n('Going to execute '||l_stmt||get_time);
          end if;
          execute immediate l_stmt;
          if g_debug then
            write_to_log_file_n('Updated '||sql%rowcount||' rows '||get_time);
          end if;
        end if;
      end if;
      l_stmt:='create table '||l_data_table_BC;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  ';
      l_stmt:=l_stmt||' as select ';
      for i in 1..p_number_cols loop
       l_stmt:=l_stmt||p_cols(i)||',';
      end loop;
      l_stmt:=l_stmt||'row_id,row_id1 from '||l_data_table_BO||' where '||
      g_instance_column||'='||g_instance_column||'1';
      if EDW_OWB_COLLECTION_UTIL.create_table(l_data_table_BC,l_stmt,l_count)=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        g_status:=false;
        return 0;
      end if;
      l_stmt:='create table '||l_data_table_BD;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  ';
      l_stmt:=l_stmt||' as select ';
      for i in 1..p_number_cols loop
        l_stmt:=l_stmt||p_cols(i)||',';
      end loop;
      l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
      l_stmt:=l_stmt||' from '||l_data_table_BC||' MINUS select ';
      for i in 1..p_number_cols loop
        l_stmt:=l_stmt||p_cols(i)||',';
      end loop;
      l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
      l_stmt:=l_stmt||' from '||l_data_table_BB;
      if EDW_OWB_COLLECTION_UTIL.create_table(l_data_table_BD,l_stmt,l_count)=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        g_status:=false;
        return 0;
      end if;
      l_stmt:='create table '||l_data_table_BE;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  ';
      l_stmt:=l_stmt||' as select /*+ORDERED*/ '||l_data_table_BC||'.row_id,'||l_data_table_BC||'.row_id1 from '||
      l_data_table_BD||','||l_data_table_BC||' where ';
      for i in 1..p_number_cols loop
        l_stmt:=l_stmt||l_data_table_BD||'.'||p_cols(i)||'='||l_data_table_BC||'.'||p_cols(i)||' and ';
      end loop;
      l_stmt:=substr(l_stmt,1,length(l_stmt)-4);
      if EDW_OWB_COLLECTION_UTIL.create_table(l_data_table_BE,l_stmt,l_count)=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        g_status:=false;
        return 0;
      end if;
      l_stmt:='create table '||l_data_table_B;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  ';
      l_stmt:=l_stmt||' as select row_id,row_id1 from '||l_data_table_BA||' MINUS select row_id,row_id1 from '||
      l_data_table_BE;
      if EDW_OWB_COLLECTION_UTIL.create_table(l_data_table_B,l_stmt,l_count)=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        g_status:=false;
        return 0;
      end if;
    end if;--if l_count>0 for BO
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table_BO) = false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table_BA) = false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table_BB) = false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table_BC) = false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table_BD) = false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table_BE) = false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table_BF) = false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table_BG) = false then
      null;
    end if;
    if l_count=0 then
      l_data_table_D:=l_data_table;
      l_data_table_D_count:=l_data_table_count;
    else
      l_stmt:='create table '||l_data_table_C;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  ';
      l_stmt:=l_stmt||' as select rowid row_id from '||l_data_table||' MINUS select row_id from '||l_data_table_B;
      if EDW_OWB_COLLECTION_UTIL.create_table(l_data_table_C,l_stmt,l_count)=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        g_status:=false;
        return 0;
      end if;
      l_data_table_D:=g_da_op_table||'D';
      l_stmt:='create table '||l_data_table_D;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  as select /*+ORDERED*/ ';
      for i in 1..p_number_cols loop
       l_stmt:=l_stmt||l_data_table||'.'||p_cols(i)||',';
      end loop;
      l_stmt:=l_stmt||l_data_table||'.'||g_instance_column||',';
      l_stmt:=l_stmt||l_data_table||'.col,'||l_data_table||'.row_id from '||l_data_table_C||','||l_data_table||
      ' where '||l_data_table||'.rowid='||l_data_table_C||'.row_id';
      if EDW_OWB_COLLECTION_UTIL.create_table(l_data_table_D,l_stmt,l_count)=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        g_status:=false;
        return 0;
      end if;
      if g_duplicate_collect then
        if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table_B) = false then
          null;
        end if;
      end if;
      --we cannot drop the B table if g_duplicate_collect=false because it needs to be used in the case
      --where master instance is turned on and duplicate collect is turned off
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table_C) = false then
        null;
      end if;
    end if;--else for if l_count=0 then
  end if;--if g_master_instance is not null and g_duplicate_collect then
  --get the duplicates
  l_stmt:='create table '||l_dup_value_table;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  ';
  l_stmt:=l_stmt||' as select ';
  for i in 1..p_number_cols loop
    l_stmt:=l_stmt||p_cols(i)||',';
  end loop;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  l_stmt:=l_stmt||' from '||l_data_table_D||' having count(*)>1 group by ';
  for i in 1..p_number_cols loop
    l_stmt:=l_stmt||p_cols(i)||',';
  end loop;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  if EDW_OWB_COLLECTION_UTIL.create_table(l_dup_value_table,l_stmt,l_count)=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    g_status:=false;
    return 0;
  end if;
  if l_count=0 then
    if g_debug then
      write_to_log_file_n('There are no duplicate records');
    end if;
    if g_master_instance is not null then
      if l_data_table_D_count=l_data_table_count then
        if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table_B) = false then
          null;
        end if;
        if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table_D) = false then
          null;
        end if;
        if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_value_table) = false then
          null;
        end if;
        return 1;
      end if;
      --4161164 : remove IOT , replace with ordinary table and index
      --l_stmt:='create table '||g_dup_hold_table||'(row_id primary key) organization index '||
      l_stmt:='create table '||g_dup_hold_table||
      ' tablespace '||g_op_table_space;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  ';
      l_stmt:=l_stmt||' as select row_id from '||l_data_table||' MINUS select row_id from '||l_data_table_D;
      if EDW_OWB_COLLECTION_UTIL.create_table(g_dup_hold_table,l_stmt,l_count)=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        g_status:=false;
        return 0;
      end if;
      --4161164 : remove IOT , replace with ordinary table and index
      EDW_OWB_COLLECTION_UTIL.create_iot_index(g_dup_hold_table,'row_id',g_op_table_space,g_parallel);
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table_B) = false then
        null;
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table_D) = false then
        null;
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_value_table) = false then
        null;
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table) = false then
        null;
      end if;
      return 2;
    else --if g_master_instance is not null then
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_value_table) = false then
        null;
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table) = false then
        null;
      end if;
      return 1;
    end if;
  end if;--if l_count=0 then
  if g_master_instance is not null then
    if g_duplicate_collect then --only then make DM and DN tables
      --split data into master instance and non master instance
      l_stmt:='create table '||l_data_table_DM;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  as select * from '||l_data_table_D||' where '||
      g_instance_column||'='''||g_master_instance||'''';
      if EDW_OWB_COLLECTION_UTIL.create_table(l_data_table_DM,l_stmt,l_count)=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        g_status:=false;
        return 0;
      end if;
      l_stmt:='create table '||l_data_table_DR;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  as select ';
      for i in 1..p_number_cols loop
       l_stmt:=l_stmt||p_cols(i)||',';
      end loop;
      l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
      l_stmt:=l_stmt||' from '||l_data_table_D||' MINUS select ';
      for i in 1..p_number_cols loop
       l_stmt:=l_stmt||p_cols(i)||',';
      end loop;
      l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
      l_stmt:=l_stmt||' from '||l_data_table_DM;
      if EDW_OWB_COLLECTION_UTIL.create_table(l_data_table_DR,l_stmt,l_count)=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        g_status:=false;
        return 0;
      end if;
      l_stmt:='create table '||l_data_table_DN;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  as select /*+ORDERED*/ '||l_data_table_D||'.* from '||l_data_table_DR||','||
      l_data_table_D||' where ';
      for i in 1..p_number_cols loop
       l_stmt:=l_stmt||l_data_table_D||'.'||p_cols(i)||'='||l_data_table_DR||'.'||p_cols(i)||' and ';
      end loop;
      l_stmt:=substr(l_stmt,1,length(l_stmt)-4);
      if EDW_OWB_COLLECTION_UTIL.create_table(l_data_table_DN,l_stmt,l_count)=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        g_status:=false;
        return 0;
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table_DR) = false then
        null;
      end if;
    end if;--if g_duplicate_collect then
  end if;--if g_master_instance is not null
  if g_duplicate_collect then
    if g_master_instance is null then
      --get the rowid of the base table for all the duplicates
      l_stmt:='create table '||l_dup_table;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  ';
      l_stmt:=l_stmt||' as select /*+ORDERED*/ ';
      for i in 1..p_number_cols loop
        l_stmt:=l_stmt||l_data_table_D||'.'||p_cols(i)||',';
      end loop;
      l_stmt:=l_stmt||l_data_table_D||'.col,'||l_data_table_D||'.row_id from '||l_dup_value_table||','||
      l_data_table_D||' where ';
      for i in 1..p_number_cols loop
        l_stmt:=l_stmt||l_data_table_D||'.'||p_cols(i)||'='||l_dup_value_table||'.'||p_cols(i)||' and ';
      end loop;
      l_stmt:=substr(l_stmt,1,length(l_stmt)-4);
      if EDW_OWB_COLLECTION_UTIL.create_table(l_dup_table,l_stmt,l_count)=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        g_status:=false;
        return 0;
      end if;
      l_stmt:='create table '||l_dup_max_table;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  ';
      l_stmt:=l_stmt||' as select ';
      for i in 1..p_number_cols loop
        l_stmt:=l_stmt||p_cols(i)||',';
      end loop;
      l_stmt:=l_stmt||'max(col) col from '||l_dup_table||' group by ';
      for i in 1..p_number_cols loop
        l_stmt:=l_stmt||p_cols(i)||',';
      end loop;
      l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
      if EDW_OWB_COLLECTION_UTIL.create_table(l_dup_max_table,l_stmt,l_count)=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        g_status:=false;
        return 0;
      end if;
      l_stmt:='create table '||l_dup_max_rowid_table;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  ';
      l_stmt:=l_stmt||' as select /*+ORDERED*/ '||l_dup_table||'.row_id from '||l_dup_max_table||','||
      l_dup_table||' where ';
      for i in 1..p_number_cols loop
        l_stmt:=l_stmt||l_dup_table||'.'||p_cols(i)||'='||l_dup_max_table||'.'||p_cols(i)||' and ';
      end loop;
      l_stmt:=l_stmt||l_dup_table||'.col='||l_dup_max_table||'.col';
      if EDW_OWB_COLLECTION_UTIL.create_table(l_dup_max_rowid_table,l_stmt,l_count)=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        g_status:=false;
        return 0;
      end if;
      --4161164 : remove IOT , replace with ordinary table and index
      --l_stmt:='create table '||g_dup_hold_table||'(row_id primary key) organization index '||
      l_stmt:='create table '||g_dup_hold_table||
      ' tablespace '||g_op_table_space;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  ';
      l_stmt:=l_stmt||' as select row_id from '||l_dup_table||' MINUS select row_id from '||l_dup_max_rowid_table;
      if EDW_OWB_COLLECTION_UTIL.create_table(g_dup_hold_table,l_stmt,l_count)=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        g_status:=false;
        return 0;
      end if;
      --4161164 : remove IOT , replace with ordinary table and index
      EDW_OWB_COLLECTION_UTIL.create_iot_index(g_dup_hold_table,'row_id',g_op_table_space,g_parallel);
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_table) = false then
        null;
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_max_table) = false then
        null;
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_max_rowid_table) = false then
        null;
      end if;
    else --there is master instance
      l_stmt:='create table '||l_data_table_F;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  ';
      l_stmt:=l_stmt||' as select max(col) col';
      for i in 1..p_number_cols loop
        l_stmt:=l_stmt||','||p_cols(i);
      end loop;
      l_stmt:=l_stmt||' from '||l_data_table_DM||' group by ';
      for i in 1..p_number_cols loop
        l_stmt:=l_stmt||p_cols(i)||',';
      end loop;
      l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
      if EDW_OWB_COLLECTION_UTIL.create_table(l_data_table_F,l_stmt,l_count)=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        g_status:=false;
        return 0;
      end if;
      if l_data_table_DM_count=l_count then
        l_data_table_G:=l_data_table_DM;
      else
        l_stmt:='create table '||l_data_table_G;
        if g_parallel is not null then
          l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
        end if;
        l_stmt:=l_stmt||'  ';
        l_stmt:=l_stmt||' as select /*+ORDERED*/ '||l_data_table_DM||'.row_id from '||l_data_table_F||','||
        l_data_table_DM||' where '||l_data_table_F||'.col='||l_data_table_DM||'.col and ';
        for i in 1..p_number_cols loop
          l_stmt:=l_stmt||l_data_table_F||'.'||p_cols(i)||'='||l_data_table_DM||'.'||p_cols(i)||' and ';
        end loop;
        l_stmt:=substr(l_stmt,1,length(l_stmt)-4);
        if EDW_OWB_COLLECTION_UTIL.create_table(l_data_table_G,l_stmt,l_count)=false then
          g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
          g_status:=false;
          return 0;
        end if;
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table_F) = false then
        null;
      end if;
      l_stmt:='create table '||l_data_table_H;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  ';
      l_stmt:=l_stmt||' as select max(col) col';
      for i in 1..p_number_cols loop
        l_stmt:=l_stmt||','||p_cols(i);
      end loop;
      l_stmt:=l_stmt||' from '||l_data_table_DN||' group by ';
      for i in 1..p_number_cols loop
        l_stmt:=l_stmt||p_cols(i)||',';
      end loop;
      l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
      if EDW_OWB_COLLECTION_UTIL.create_table(l_data_table_H,l_stmt,l_count)=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        g_status:=false;
        return 0;
      end if;
      if l_data_table_DN_count=l_count then
        l_data_table_I:=l_data_table_DN;
      else
        l_stmt:='create table '||l_data_table_I;
        if g_parallel is not null then
          l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
        end if;
        l_stmt:=l_stmt||'  ';
        l_stmt:=l_stmt||' as select /*+ORDERED*/ '||l_data_table_DN||'.row_id from '||l_data_table_H||','||
        l_data_table_DN||' where '||l_data_table_H||'.col='||l_data_table_DN||'.col and ';
        for i in 1..p_number_cols loop
          l_stmt:=l_stmt||l_data_table_H||'.'||p_cols(i)||'='||l_data_table_DN||'.'||p_cols(i)||' and ';
        end loop;
        l_stmt:=substr(l_stmt,1,length(l_stmt)-4);
        if EDW_OWB_COLLECTION_UTIL.create_table(l_data_table_I,l_stmt,l_count)=false then
          g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
          g_status:=false;
          return 0;
        end if;
      end if;--else for if l_data_table_DN_count=l_count then
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table_H) = false then
        null;
      end if;
      l_stmt:='create table '||l_data_table_J;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  ';
      l_stmt:=l_stmt||' as select row_id from '||l_data_table_G||' UNION ALL select row_id from '||l_data_table_I;
      if EDW_OWB_COLLECTION_UTIL.create_table(l_data_table_J,l_stmt,l_count)=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        g_status:=false;
        return 0;
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table_G) = false then
        null;
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table_I) = false then
        null;
      end if;
      --4161164 : remove IOT , replace with ordinary table and index
      --l_stmt:='create table '||g_dup_hold_table||'(row_id primary key) organization index '||
      l_stmt:='create table '||g_dup_hold_table||
      ' tablespace '||g_op_table_space;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  ';
      l_stmt:=l_stmt||' as select row_id from '||l_data_table||' MINUS select row_id from '||l_data_table_J;
      if EDW_OWB_COLLECTION_UTIL.create_table(g_dup_hold_table,l_stmt,l_count)=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        g_status:=false;
        return 0;
      end if;
      --4161164 : remove IOT , replace with ordinary table and index
      EDW_OWB_COLLECTION_UTIL.create_iot_index(g_dup_hold_table,'row_id',g_op_table_space,g_parallel);
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table_J) = false then
        null;
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table_DM) = false then
        null;
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table_DN) = false then
        null;
      end if;
    end if;--there is master instance
  else --else for if g_duplicate_collect then
    --here duplicate collect is turned off
    --4161164 : remove IOT , replace with ordinary table and index
    --l_stmt:='create table '||g_dup_hold_table||'(row_id primary key) organization index '||
    l_stmt:='create table '||g_dup_hold_table||
    ' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  ';
    l_stmt:=l_stmt||' as select /*+ORDERED*/ '||l_data_table_D||'.row_id from '||l_dup_value_table||','||
    l_data_table_D||' where ';
    for i in 1..p_number_cols loop
      l_stmt:=l_stmt||l_data_table_D||'.'||p_cols(i)||'='||l_dup_value_table||'.'||p_cols(i);
    end loop;
    if g_master_instance is not null and EDW_OWB_COLLECTION_UTIL.check_table(l_data_table_B) then
      l_stmt:=l_stmt||' UNION ALL select row_id1 row_id from '||l_data_table_B;
    end if;
    if EDW_OWB_COLLECTION_UTIL.create_table(g_dup_hold_table,l_stmt,l_count)=false then
      g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
      g_status:=false;
      return 0;
    end if;
    --4161164 : remove IOT , replace with ordinary table and index
    EDW_OWB_COLLECTION_UTIL.create_iot_index(g_dup_hold_table,'row_id',g_op_table_space,g_parallel);
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table) = false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_dup_value_table) = false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table_B) = false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_data_table_D) = false then
    null;
  end if;
  l_dup_hold_table_count:=EDW_OWB_COLLECTION_UTIL.get_table_count(g_dup_hold_table);
  g_dup_multi_thread_flag:=false;
  if g_max_threads>1 then
    if l_dup_hold_table_count>=2*g_min_job_load_size then
      g_dup_multi_thread_flag:=true;
      if g_debug then
        write_to_log_file_n('g_dup_multi_thread_flag made true');
      end if;
    end if;
  end if;
  return 2;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  return 0;
End;

function recreate_dlog_table return boolean is
l_stmt varchar2(32000);
l_dlog_table varchar2(100);
l_pk_key_found boolean;
l_owner varchar2(100);
l_next_extent number;
l_table varchar2(100);
l_divide number;
l_rowid_table varchar2(100);
l_rowid_table_count number;
l_fact_dlog_count number;
l_fact_count number;
l_use_nl_dlog boolean;
l_use_nl_fact boolean;
Begin
  if g_debug then
    write_to_log_file_n('In recreate_dlog_table'||get_time);
  end if;
  l_dlog_table:=g_dlog_rowid_table||'T';
  l_rowid_table:=g_dlog_rowid_table||'R';
  l_pk_key_found:=EDW_OWB_COLLECTION_UTIL.check_table_column(g_fact_dlog,'pk_key');
  if instr(g_fact_dlog,'.')<>0 then
    l_owner:=substr(g_fact_dlog,1,instr(g_fact_dlog,'.')-1);
  else
    l_owner:=EDW_OWB_COLLECTION_UTIL.get_table_owner(g_fact_dlog);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(g_fact_dlog,l_owner,1);
  l_fact_dlog_count:=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_fact_dlog,l_owner);
  l_fact_count:=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_FactTableName,g_table_owner);
  l_table:=substr(g_fact_dlog,instr(g_fact_dlog,'.')+1,length(g_fact_dlog));
  if EDW_OWB_COLLECTION_UTIL.get_table_next_extent(l_table,l_owner,l_next_extent)=false then
    l_next_extent:=4194304; --4M
  end if;
  if l_next_extent is null then
    l_next_extent:=4194304; --4M
  end if;
  if g_parallel is null then
    l_divide:=2;
  else
    l_divide:=g_parallel;
  end if;
  if l_next_extent>16777216 then --16M
    l_next_extent:=16777216;
  end if;
  if l_next_extent is null or l_next_extent=0 then
    l_next_extent:=8388608;
  end if;
  if l_pk_key_found=false then
    --create l_rowid_table to make sure there is no invalid rowid error
    l_stmt:='create table '||l_rowid_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  as select rowid row_id1, row_id from '||g_fact_dlog||' where row_id in '||
    '(select rowid from '||g_object_name||')';
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_rowid_table)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    l_rowid_table_count:=sql%rowcount;
    if g_debug then
      write_to_log_file('Created with '||l_rowid_table_count||' rows '||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_rowid_table,instr(l_rowid_table,'.')+1,
    length(l_rowid_table)),substr(l_rowid_table,1,instr(l_rowid_table,'.')-1));
  end if;
  l_use_nl_dlog:=true;
  l_use_nl_fact:=true;
  if l_pk_key_found=false then
    l_use_nl_dlog:=EDW_OWB_COLLECTION_UTIL.get_join_nl(l_rowid_table_count,l_fact_dlog_count,
    g_stg_join_nl_percentage);
    l_use_nl_fact:=EDW_OWB_COLLECTION_UTIL.get_join_nl(l_rowid_table_count,l_fact_count,
    g_stg_join_nl_percentage);
  else
    l_use_nl_fact:=EDW_OWB_COLLECTION_UTIL.get_join_nl(l_fact_dlog_count,l_fact_count,
    g_stg_join_nl_percentage);
  end if;
  if l_use_nl_fact and l_pk_key_found then
    if EDW_OWB_COLLECTION_UTIL.check_index_on_column(g_FactTableName,g_table_owner,g_factPKNameKey)=false then
      l_use_nl_fact:=false;
    end if;
  end if;
  --g_dlog_columns,g_number_dlog_columns
  l_stmt:='create table '||l_dlog_table||' tablespace '||g_op_table_space||
  ' storage(initial '||l_next_extent/l_divide||' next '||(l_next_extent/l_divide)||
  ' pctincrease 0 MAXEXTENTS 2147483645) ';
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  as select /*+ordered ';
  if l_use_nl_dlog then
    l_stmt:=l_stmt||'use_nl(B) ';
  end if;
  if l_use_nl_fact then
    l_stmt:=l_stmt||'use_nl(A) ';
  end if;
  l_stmt:=l_stmt||'*/ ';
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+parallel (A,'||g_parallel||') (B,'||g_parallel||')*/ ';
  end if;
  for i in 1..g_number_dlog_columns loop
    if g_dlog_columns(i)<>'ROW_ID' and g_dlog_columns(i)<>'PK_KEY' and g_dlog_columns(i)<>'ROUND' then
      l_stmt:=l_stmt||'B.'||g_dlog_columns(i)||',';
    end if;
  end loop;
  l_stmt:=l_stmt||'A.rowid row_id,';
  if l_pk_key_found then
    l_stmt:=l_stmt||'B.pk_key pk_key,B.round round ';
  else
    l_stmt:=l_stmt||'A.'||g_factPKNameKey||' pk_key,0 round ';
  end if;
  l_stmt:=l_stmt||' from ';
  if l_pk_key_found=false then
    l_stmt:=l_stmt||l_rowid_table||' C,';
  end if;
  l_stmt:=l_stmt||g_fact_dlog||' B,'||g_FactTableName||' A where ';
  if l_pk_key_found then
    l_stmt:=l_stmt||'A.'||g_factPKNameKey||'=B.pk_key';
  else
    l_stmt:=l_stmt||'C.row_id1=B.rowid and A.rowid=C.row_id';
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_dlog_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file('Created with '||sql%rowcount||' rows '||get_time);
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_rowid_table)=false then
    null;
  end if;
  /*the following line is modified for fixing bug 2406119.
  'ORA-03291: Invalid truncate option - missing STORAGE keyword'
  Since g_fact_dlog already contains owner information, l_owner should be passed in as null.
  This modified code should work on patch 2365233
  if EDW_OWB_COLLECTION_UTIL.truncate_table(g_fact_dlog,l_owner)=false then*/
  if EDW_OWB_COLLECTION_UTIL.truncate_table(g_fact_dlog,null)=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    g_status:=false;
    return false;
  end if;
  if l_pk_key_found=false then
    if EDW_OWB_COLLECTION_UTIL.check_table_column(g_fact_dlog,'round')=false then
      if EDW_OWB_COLLECTION_UTIL.add_column_to_table(l_table,l_owner,'ROUND','NUMBER')=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        g_status:=false;
        return false;
      end if;
    end if;
    if EDW_OWB_COLLECTION_UTIL.add_column_to_table(l_table,l_owner,'PK_KEY','NUMBER')=false then
      g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
      g_status:=false;
      return false;
    end if;
  end if;
  if g_parallel is null then
    l_stmt:='insert into '||g_fact_dlog||'(';
  else
    l_stmt:='insert /*+PARALLEL (A,'||g_parallel||')*/ into '||g_fact_dlog||' A (';
  end if;
  for i in 1..g_number_dlog_columns loop
    l_stmt:=l_stmt||g_dlog_columns(i)||',';
  end loop;
  if l_pk_key_found then
    l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  else
    l_stmt:=l_stmt||'PK_KEY,ROUND';
  end if;
  l_stmt:=l_stmt||') select ';
  for i in 1..g_number_dlog_columns loop
    l_stmt:=l_stmt||g_dlog_columns(i)||',';
  end loop;
  if l_pk_key_found then
    l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
  else
    l_stmt:=l_stmt||'PK_KEY,ROUND';
  end if;
  l_stmt:=l_stmt||' from '||l_dlog_table;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file('Inserted '||sql%rowcount||' rows '||get_time);
  end if;
  commit;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_dlog_table)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in recreate_dlog_table '||g_status_message);
  g_status:=false;
  return false;
End;

function check_cols_in_dlog return boolean is
l_owner varchar2(400);
l_table varchar2(400);
Begin
  if g_debug then
    write_to_log_file_n('In check_cols_in_dlog'||get_time);
  end if;
  if instr(g_fact_dlog,'.')<>0 then
    l_owner:=substr(g_fact_dlog,1,instr(g_fact_dlog,'.')-1);
  else
    l_owner:=EDW_OWB_COLLECTION_UTIL.get_table_owner(g_fact_dlog);
  end if;
  l_table:=substr(g_fact_dlog,instr(g_fact_dlog,'.')+1,length(g_fact_dlog));
  if EDW_OWB_COLLECTION_UTIL.check_table_column(g_fact_dlog,'pk_key')=false then
    if EDW_OWB_COLLECTION_UTIL.add_column_to_table(l_table,l_owner,'ROUND','NUMBER')=false then
      g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
      g_status:=false;
      return false;
    end if;
    if EDW_OWB_COLLECTION_UTIL.add_column_to_table(l_table,l_owner,'PK_KEY','NUMBER')=false then
      g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
      g_status:=false;
      return false;
    end if;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function create_auto_dang_tables(
p_surr_table varchar2,
p_fk_name varchar2,
p_user_fk_table_flag boolean,
p_user_fk_table varchar2,
p_dang_table out NOCOPY varchar2
) return boolean is
l_auto_dang_table1 varchar2(200);
l_auto_dang_table2 varchar2(200);
l_stmt varchar2(20000);
l_count number;
l_rowid_col varchar2(20);
l_user_fk_table_used varchar2(200);
Begin
  if g_debug then
    write_to_log_file_n('In create_auto_dang_tables '||get_time);
  end if;
  l_auto_dang_table1:=g_bis_owner||'.TAB_'||g_primary_target||'_'||g_job_id||'_AD1';
  l_auto_dang_table2:=g_bis_owner||'.TAB_'||g_primary_target||'_'||g_job_id||'_AD2';
  p_dang_table:=null;
  l_stmt:='create table '||l_auto_dang_table1||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  as select ';
  if g_user_fk_table=g_fstgTableName then --in this case g_stg_copy_table_flag=false and g_use_mti=false
    if g_parallel is not null then
      l_stmt:=l_stmt||' /*+PARALLEL('||g_fstgTableName||','||g_parallel||')*/ ';
    end if;
    l_rowid_col:='rowid';
  else
    l_rowid_col:='row_id';
  end if;
  l_stmt:=l_stmt||l_rowid_col||' row_id ';
  l_stmt:=l_stmt||' from ';
  if p_user_fk_table_flag=false then
   l_user_fk_table_used:=g_user_fk_table;
  else
    l_user_fk_table_used:=p_user_fk_table;
  end if;
  l_stmt:=l_stmt||l_user_fk_table_used;
  if g_user_fk_table=g_fstgTableName then
    l_stmt:=l_stmt||','||g_opcode_table||' where '||g_opcode_table||'.row_id='||
    g_fstgTableName||'.rowid';
  end if;
  l_stmt:=l_stmt||' MINUS select row_id from '||p_surr_table;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_auto_dang_table1)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  l_count:=sql%rowcount;
  if g_debug then
    write_to_log_file_n('Created with '||l_count||' rows '||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_auto_dang_table1,instr(l_auto_dang_table1,'.')+1,
  length(l_auto_dang_table1)),substr(l_auto_dang_table1,1,instr(l_auto_dang_table1,'.')-1));
  if l_count>0 then
    p_dang_table:=l_auto_dang_table2;
    l_stmt:='create table '||l_auto_dang_table2||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  as select '||l_auto_dang_table1||'.row_id,'||p_fk_name;
    if g_instance_column is not null and g_instance_column<>p_fk_name then
      l_stmt:=l_stmt||','||g_instance_column;
    else
      if g_debug then
        write_to_log_file_n('No instance column defined');
      end if;
    end if;
    l_stmt:=l_stmt||' from '||l_auto_dang_table1||','||l_user_fk_table_used||' where '||
    l_auto_dang_table1||'.row_id='||l_user_fk_table_used||'.'||l_rowid_col;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_auto_dang_table2)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n(l_stmt||get_time);
    end if;
    begin
      execute immediate l_stmt;
    exception when others then
      if g_debug then
        write_to_log_file_n('Error '||sqlerrm||get_time);
        write_to_log_file('Will not be able to implement auto dang and auto dim creation');
      end if;
      p_dang_table:=null;
      return true;
    end;
    if g_debug then
      write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_auto_dang_table1)=false then
      null;
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_auto_dang_table2,instr(l_auto_dang_table2,'.')+1,
    length(l_auto_dang_table2)),substr(l_auto_dang_table2,1,instr(l_auto_dang_table2,'.')-1));
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_auto_dang_tables '||g_status_message);
  g_status:=false;
  return false;
End;

function create_dang_inst_tables(
p_fk_name varchar2,
p_parent_table_id number,
p_parent_table_name varchar2,
p_dang_table varchar2,
p_dang_instance out NOCOPY EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_dang_instance out NOCOPY number
) return boolean is
l_user_fk_table_used varchar2(200);
l_rowid_col varchar2(20);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_auto_dang_table3 varchar2(200);
l_stmt varchar2(20000);
l_count number;
l_table varchar2(200);
l_pk_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_pk_cols number;
l_index number;
l_dim_pk_structure EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_dim_pk_structure number;
l_prev_index number;
Begin
  if g_debug then
    write_to_log_file_n('In create_dang_inst_tables '||get_time);
  end if;
  p_number_dang_instance:=0;
  l_number_pk_cols:=0;
  if g_instance_column is not null then
    p_number_dang_instance:=1;
    l_stmt:='select distinct '||g_instance_column||' from '||p_dang_table;
    if g_debug then
      write_to_log_file_n(l_stmt||get_time);
    end if;
    open cv for l_stmt;
    loop
      fetch cv into p_dang_instance(p_number_dang_instance);
      exit when cv%notfound;
      p_number_dang_instance:=p_number_dang_instance+1;
    end loop;
    p_number_dang_instance:=p_number_dang_instance-1;
    if g_debug then
      write_to_log_file_n('Results');
      for z in 1..p_number_dang_instance loop
        write_to_log_file(p_dang_instance(z));
      end loop;
    end if;
  else
    p_number_dang_instance:=1;
    p_dang_instance(1):=null;
  end if;
  --get the pk structure
  for z in 1..p_number_dang_instance loop
    if EDW_OWB_COLLECTION_UTIL.value_in_table(g_dim_pk_dim,g_dim_pk_instance,g_number_dim_pk_structure,
      p_parent_table_name,p_dang_instance(z))=false then
      l_number_dim_pk_structure:=0;
      if EDW_OWB_COLLECTION_UTIL.get_dim_pk_structure(p_parent_table_name,p_dang_instance(z),
        l_dim_pk_structure,l_number_dim_pk_structure)=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        g_status:=false;
        return false;
      end if;
      l_prev_index:=g_number_dim_pk_structure+1;
      if l_number_dim_pk_structure>0 then
        for y in 1..l_number_dim_pk_structure loop
          g_number_dim_pk_structure:=g_number_dim_pk_structure+1;
          g_dim_pk_dim(g_number_dim_pk_structure):=p_parent_table_name;
          g_dim_pk_instance(g_number_dim_pk_structure):=p_dang_instance(z);
          g_dim_pk_structure(g_number_dim_pk_structure):=l_dim_pk_structure(y);
        end loop;
      else
        g_number_dim_pk_structure:=g_number_dim_pk_structure+1;
        g_dim_pk_dim(g_number_dim_pk_structure):=p_parent_table_name;
        g_dim_pk_instance(g_number_dim_pk_structure):=p_dang_instance(z);
        g_dim_pk_structure(g_number_dim_pk_structure):=null;
      end if;
      for z in l_prev_index..g_number_dim_pk_structure loop
        l_number_pk_cols:=0;
        if EDW_OWB_COLLECTION_UTIL.parse_pk_structure(g_dim_pk_structure(z),l_pk_cols,
          l_number_pk_cols)=false then
          g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
          g_status:=false;
          return false;
        end if;
        for y in 1..l_number_pk_cols loop
          g_number_dim_pk_structure_cols:=g_number_dim_pk_structure_cols+1;
          g_dim_pk_structure_index(g_number_dim_pk_structure_cols):=z;
          g_dim_pk_structure_cols(g_number_dim_pk_structure_cols):=l_pk_cols(y);
        end loop;
      end loop;
    end if;
  end loop;
  if g_instance_column is not null then
    for z in 1..p_number_dang_instance loop
      if p_dang_instance(z) is null then
        l_auto_dang_table3:=g_bis_owner||'.D_'||g_primary_target||'_'||p_parent_table_id||'_'||g_job_id||'_null';
      else
        l_auto_dang_table3:=g_bis_owner||'.D_'||g_primary_target||'_'||p_parent_table_id||'_'||g_job_id||'_'||p_dang_instance(z);
      end if;
      l_table:=l_auto_dang_table3||'T';
      l_stmt:='create table '||l_table||' tablespace '||g_op_table_space;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      if p_dang_instance(z) is null then
        if g_instance_column is null then
          l_stmt:=l_stmt||'  as select distinct '||p_fk_name||' from '||p_dang_table;
        else
          l_stmt:=l_stmt||'  as select distinct '||p_fk_name||' from '||p_dang_table||
          ' where '||g_instance_column||' is null';
        end if;
      else
        l_stmt:=l_stmt||'  as select distinct '||p_fk_name||' from '||p_dang_table||
        ' where '||g_instance_column||'='''||p_dang_instance(z)||'''';
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_table)=false then
        null;
      end if;
      if g_debug then
        write_to_log_file_n(l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
      end if;
      l_stmt:='create table '||l_auto_dang_table3||' tablespace '||g_op_table_space;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  as select '||p_fk_name;
      for i in 1..g_number_dim_pk_structure loop
        if g_dim_pk_dim(i)=p_parent_table_name and g_dim_pk_instance(i)=p_dang_instance(z) then
          --l_index:=EDW_OWB_COLLECTION_UTIL.index_in_table(g_dim_pk_dim,g_dim_pk_instance,g_number_dim_pk_structure,
          --p_parent_table_name,p_dang_instance(z));
          l_index:=i;
          l_number_pk_cols:=0;
          for y in 1..g_number_dim_pk_structure_cols loop
            if g_dim_pk_structure_index(y)=l_index then
              l_number_pk_cols:=l_number_pk_cols+1;
              l_pk_cols(l_number_pk_cols):=g_dim_pk_structure_cols(y);
            end if;
          end loop;
          /*
          example:
          select
          substr(x,1,(decode((instr(x,'-',1,1)),0,length(x)+1,instr(x,'-',1,1))-1)),
          substr(x,decode(instr(x,'-',1,(2-1)),0,length(x)+1,instr(x,'-',1,(2-1)))+1,
          (decode((instr(x,'-',1,2)),0,length(x)+1,(instr(x,'-',1,2)))-(instr(x,'-',1,(2-1))+1)))
          from abc
          data in abc
          1011-1012-INST
          100011-1-INST
          1-100-INST
          */
          for j in 1..l_number_pk_cols loop
            if l_pk_cols(j)<>'INST' then
              if j=1 then
                l_stmt:=l_stmt||',substr('||p_fk_name||',1,(decode((instr('||p_fk_name||',''-'',1,1)),0,'||
                'length('||p_fk_name||'),instr('||p_fk_name||',''-'',1,1))-1)) '||l_pk_cols(j);
              else
                l_stmt:=l_stmt||',substr('||p_fk_name||',decode(instr('||p_fk_name||',''-'',1,('||j||'-1)),0,'||
                'length('||p_fk_name||')+1,instr('||p_fk_name||',''-'',1,('||j||'-1)))+1,'||
                '(decode((instr('||p_fk_name||',''-'',1,'||j||')),0,length('||p_fk_name||')+1,'||
                '(instr('||p_fk_name||',''-'',1,'||j||')))-'||
                '(instr('||p_fk_name||',''-'',1,('||j||'-1))+1))) '||l_pk_cols(j);
              end if;
            end if;
          end loop;
        end if;
      end loop;
      l_stmt:=l_stmt||' from '||l_table;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_auto_dang_table3)=false then
        null;
      end if;
      if g_debug then
        write_to_log_file_n(l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
      end if;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_table)=false then
        null;
      end if;
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_dang_inst_tables '||g_status_message);
  g_status:=false;
  return false;
End;

function insert_into_parent_fk_log(
p_dang_instance EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_dang_instance number,
p_fk_name varchar2,
p_parent_table_id number,
p_parent_table_name varchar2,
p_dim_auto_dang_table varchar2,
p_dim_lowest_ltc_id number) return boolean is
l_auto_dang_table3 varchar2(200);
l_auto_dang_table2 varchar2(200);
l_instance_column varchar2(200);
l_stmt varchar2(20000);
l_pk_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_pk_cols number;
l_index number;
l_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_cols_datatype EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_cols number;
l_owner varchar2(200);
l_found boolean;
Begin
  if g_debug then
    write_to_log_file_n('In insert_into_parent_fk_log');
  end if;
  l_instance_column:=g_instance_column;
  if l_instance_column is null then
    l_instance_column:='null';
  end if;
  for z in 1..p_number_dang_instance loop
    if p_dang_instance(z) is null then
      l_auto_dang_table2:=g_bis_owner||'.D_'||g_primary_target||'_'||p_parent_table_id||'_'||g_job_id||'_null';
      l_auto_dang_table3:=p_dim_auto_dang_table||'_null';
    else
      l_auto_dang_table2:=g_bis_owner||'.D_'||g_primary_target||'_'||p_parent_table_id||'_'||g_job_id||'_'||p_dang_instance(z);
      l_auto_dang_table3:=p_dim_auto_dang_table||'_'||p_dang_instance(z);
    end if;
    l_number_pk_cols:=0;
    for i in 1..g_number_dim_pk_structure loop
      if g_dim_pk_dim(i)=p_parent_table_name and g_dim_pk_instance(i)=p_dang_instance(z) then
        l_index:=i;
        for y in 1..g_number_dim_pk_structure_cols loop
          if g_dim_pk_structure_index(y)=l_index then
            l_number_pk_cols:=l_number_pk_cols+1;
            l_pk_cols(l_number_pk_cols):=g_dim_pk_structure_cols(y);
          end if;
        end loop;
      end if;
    end loop;
    if EDW_OWB_COLLECTION_UTIL.check_table(l_auto_dang_table3)=false then
      if EDW_OWB_COLLECTION_UTIL.create_auto_dang_table(l_auto_dang_table3,l_pk_cols,l_number_pk_cols)=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        g_status:=false;
        write_to_log_file_n(g_status_message);
        return false;
      end if;
    else
      --check the columns
      --l_auto_dang_table3 only gets truncated. what if in the future, the key structure changes?
      l_owner:=substr(l_auto_dang_table3,1,instr(l_auto_dang_table3,'.')-1);
      l_number_cols:=0;
      if EDW_OWB_COLLECTION_UTIL.get_db_columns_for_table(substr(l_auto_dang_table3,
        instr(l_auto_dang_table3,'.')+1),l_cols,l_cols_datatype,l_number_cols,l_owner)=false then
        null;
      end if;
      l_found:=true;
      for i in 1..l_number_pk_cols loop
        if l_pk_cols(i)<>'INST' then
          if EDW_OWB_COLLECTION_UTIL.value_in_table(l_cols,l_number_cols,l_pk_cols(i))=false then
            l_found:=false;
            exit;
          end if;
        end if;
      end loop;
      if l_found then
        for i in 1..l_number_cols loop
          if l_cols(i)<>'LEVEL_TABLE' and l_cols(i)<>'VALUE' then
            if EDW_OWB_COLLECTION_UTIL.value_in_table(l_pk_cols,l_number_pk_cols,l_cols(i))=false then
              l_found:=false;
              exit;
            end if;
          end if;
        end loop;
      end if;
      if l_found=false then
        if g_debug then
          write_to_log_file_n('There is a column descrepency. Re-creating '||l_auto_dang_table3);
        end if;
        if EDW_OWB_COLLECTION_UTIL.drop_table(l_auto_dang_table3)=false then
          null;
        end if;
        if EDW_OWB_COLLECTION_UTIL.create_auto_dang_table(l_auto_dang_table3,l_pk_cols,l_number_pk_cols)=false then
          g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
          g_status:=false;
          write_to_log_file_n(g_status_message);
          return false;
        end if;
      end if;
    end if;
    l_stmt:='insert into '||l_auto_dang_table3||'(level_table,value';
    for i in 1..l_number_pk_cols loop
      if l_pk_cols(i)<>'INST' then
        l_stmt:=l_stmt||','||l_pk_cols(i);
      end if;
    end loop;
    l_stmt:=l_stmt||') select '||p_dim_lowest_ltc_id||','||p_fk_name;
    for i in 1..l_number_pk_cols loop
      if l_pk_cols(i)<>'INST' then
        l_stmt:=l_stmt||','||l_pk_cols(i);
      end if;
    end loop;
    l_stmt:=l_stmt||' from '||l_auto_dang_table2;
    EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
    if g_debug then
      write_to_log_file_n(l_stmt||get_time);
    end if;
    begin
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Inserted '||sql%rowcount||' records '||get_time);
      end if;
      commit;
    exception when others then
      write_to_log_file_n('WARNING!!WARNING!! Error executing stmt '||sqlerrm||get_time);
    end;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_auto_dang_table2)=false then
      null;
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in insert_into_parent_fk_log '||g_status_message);
  g_status:=false;
  return false;
End;

function drop_fk_inst_tables(
p_dang_instance EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_dang_instance number,
p_parent_table_id number) return boolean is
l_auto_dang_table2 varchar2(200);
Begin
  for z in 1..p_number_dang_instance loop
    if p_dang_instance(z) is null then
      l_auto_dang_table2:=g_bis_owner||'.D_'||g_primary_target||'_'||p_parent_table_id||'_'||g_job_id||'_null';
    else
      l_auto_dang_table2:=g_bis_owner||'.D_'||g_primary_target||'_'||p_parent_table_id||'_'||g_job_id||'_'||p_dang_instance(z);
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_auto_dang_table2)=false then
      null;
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in drop_fk_inst_tables '||g_status_message);
  g_status:=false;
  return false;
End;

/*
called for the lowest level. logs the dangling keys for auto dang recovery
*/
function log_dimension_dang_keys(
p_pk_name varchar2,
p_parent_table_id number,
p_parent_table_name varchar2,
p_dim_auto_dang_table varchar2,
p_dim_lowest_ltc_id number)
return boolean is
l_dang_table varchar2(200);
l_dang_instance EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_dang_instance number:=0;
Begin
  if g_debug then
    write_to_log_file_n('In log_dimension_dang_keys '||get_time);
  end if;
  l_dang_table:=g_bis_owner||'.DPK_'||g_primary_target||'_'||g_job_id;
  if create_pk_dang_table(l_dang_table)=false then
    return false;
  end if;
  if create_dang_inst_tables(p_pk_name,p_parent_table_id,p_parent_table_name,
    l_dang_table,l_dang_instance,l_number_dang_instance)=false then
    return false;
  end if;
  if insert_into_parent_fk_log(l_dang_instance,l_number_dang_instance,p_pk_name,p_parent_table_id,
    p_parent_table_name,p_dim_auto_dang_table,p_dim_lowest_ltc_id)=false then
    return false;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_dang_table)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in log_dimension_dang_keys '||g_status_message);
  g_status:=false;
  return false;
End;

function create_pk_dang_table(p_dang_table varchar2) return boolean is
l_stmt varchar2(20000);
Begin
  if g_debug then
    write_to_log_file_n('In create_pk_dang_table '||get_time);
  end if;
  l_stmt:='create table '||p_dang_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  if g_stg_join_nl then
    l_stmt:=l_stmt||'  as select /*+ORDERED USE_NL('||g_fstgTableName||')*/ ';
  else
    l_stmt:=l_stmt||'  as select /*+ORDERED*/ ';
  end if;
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+PARALLEL('||g_fstgTableName||','||g_parallel||')*/ ';
  end if;
  l_stmt:=l_stmt||g_fstgTableName||'.'||g_fstgPKName;
  if g_instance_column is not null then
    l_stmt:=l_stmt||','||g_fstgTableName||'.'||g_instance_column;
  end if;
  --we cannot use g_stg_copy_table_flag here because g_error_rowid_table is an IOT
  --it contains only one column (also better for performance)
  l_stmt:=l_stmt||' from '||g_error_rowid_table||',';
  l_stmt:=l_stmt||g_fstgTableName;
  l_stmt:=l_stmt||' where '||g_error_rowid_table||'.row_id='||g_fstgTableName||'.rowid';
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_dang_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created with '||sql%rowcount||' rows'||get_time);
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_pk_dang_table '||g_status_message);
  g_status:=false;
  return false;
End;

--called by fact loading and level loading to create dim records
function create_dang_dim_records(
p_dang_table varchar2,
p_dang_pk varchar2,
p_da_table varchar2,
p_pp_table varchar2,
p_ltc_table varchar2,
p_dim_table varchar2,
p_dim_id number,
p_surr_table out NOCOPY varchar2 --output table with the pk and pk_key that needs to be added to g_surr_table
)return boolean is
l_pk varchar2(200);
l_pk_key varchar2(200);
l_seq varchar2(200);
l_dim_pk varchar2(200);
l_dim_pk_key varchar2(200);
Begin
  if g_debug then
    write_to_log_file_n('In create_dang_dim_records '||get_time);
  end if;
  --function get_table_surr_pk(p_table varchar2, p_pk out NOCOPY varchar2) return boolean;
  --function get_user_key(p_key varchar2) return varchar2 ;
  --get_dim_pk(p_dim_name varchar2,p_dim_id number) return varchar2 is
  if EDW_OWB_COLLECTION_UTIL.get_table_surr_pk(p_ltc_table,l_pk_key)=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    return false;
  end if;
  l_pk:=EDW_OWB_COLLECTION_UTIL.get_user_key(l_pk_key);
  if p_dim_id is not null then
    l_dim_pk_key:=EDW_OWB_COLLECTION_UTIL.get_dim_pk(null,p_dim_id);
    l_dim_pk:=EDW_OWB_COLLECTION_UTIL.get_user_key(l_dim_pk_key);
  end if;
  l_seq:=EDW_OWB_COLLECTION_UTIL.get_table_seq(p_ltc_table,null);
  if p_pp_table is null then
    if EDW_OWB_COLLECTION_UTIL.index_present(p_ltc_table,null,l_pk,'UNIQUE')=false then
      if g_debug then
        write_to_log_file_n('Cannot insert into level table '||p_ltc_table||'. Its missing a unique '||
        'index on '||l_pk);
      end if;
      return true;
    end if;
  end if;
  if create_dang_table_records(p_dang_table,p_dang_pk,p_da_table,p_pp_table,p_ltc_table,
    l_pk,l_pk_key,p_dim_table,p_dim_id,l_dim_pk,l_dim_pk_key,l_seq,p_surr_table)=false then
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_dang_dim_records '||g_status_message);
  g_status:=false;
  return false;
End;

function create_dang_table_records(
p_dang_table varchar2,
p_dang_pk varchar2,
p_da_table varchar2,
p_pp_table varchar2,
p_ltc_table varchar2,
p_pk varchar2,--ltc pk
p_pk_key varchar2,--ltc pk_key
p_dim_table varchar2,
p_dim_id number,
p_dim_pk varchar2,
p_dim_pk_key varchar2,
p_seq varchar2,--ltc seq
p_surr_table out NOCOPY varchar2 --output table with the pk and pk_key that needs to be added to g_surr_table
)return boolean is
l_table1 varchar2(200);
l_stmt varchar2(30000);
l_table_distinct varchar2(200);
l_table_old varchar2(200); --pk_key already in parent table
l_table_new varchar2(200); --pk_key NOT  in parent table. contains new pk_key
l_attempt_flag boolean;
l_fk EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_fk number;
l_pk EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_pk number;
l_name_col EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_name_col number;
l_unassigned varchar2(200);
l_table_union varchar2(200);
Begin
  if g_debug then
    write_to_log_file_n('In create_dang_table_records '||get_time);
  end if;
  l_table1:=p_dang_table||'1';
  l_table_old:=p_dang_table||'O';
  l_table_new:=p_dang_table||'N';
  l_table_distinct:=p_dang_table||'D';
  l_table_union:=p_dang_table||'U';
  p_surr_table:=p_dang_table||'S';
  FND_MESSAGE.SET_NAME('BIS','EDW_UNASSIGNED');
  l_unassigned:=FND_MESSAGE.GET;
  l_number_fk:=0;
  if EDW_OWB_COLLECTION_UTIL.get_fks_for_table(p_ltc_table,l_fk,l_number_fk)=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    return false;
  end if;
  l_stmt:='create table '||l_table_old||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  as select '||p_pk||','||p_pk_key||' from '||p_ltc_table||
  ' where 1=2';
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table_old)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created with '||sql%rowcount||' rows'||get_time);
  end if;
  l_stmt:='create table '||l_table_distinct||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  as select distinct '||p_dang_pk||' '||p_pk||' from '||p_dang_table;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table_distinct)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created with '||sql%rowcount||' rows'||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_table_distinct,instr(l_table_distinct,'.')+1,
  length(l_table_distinct)),substr(l_table_distinct,1,instr(l_table_distinct,'.')-1));
  loop
    l_attempt_flag:=false;
    l_stmt:='create table '||l_table1||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  as select '||p_pk||' from '||l_table_distinct||' MINUS select '||
    p_pk||' from '||l_table_old;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_table1)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n(l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created with '||sql%rowcount||' rows'||get_time);
    end if;
    l_stmt:='create table '||l_table_new||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  as select '||p_pk||','||p_seq||'.NEXTVAL '||p_pk_key||' from '||l_table1;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_table_new)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n(l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created with '||sql%rowcount||' rows'||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_table_new,instr(l_table_new,'.')+1,
    length(l_table_new)),substr(l_table_new,1,instr(l_table_new,'.')-1));
    if p_pp_table is not null then --data alignment
      l_stmt:='insert ';
      if g_parallel is not null then
        l_stmt:=l_stmt||' /*+parallel(A,'||g_parallel||')*/ ';
      end if;
      l_stmt:=l_stmt||' into '||p_pp_table||' A(pk,pk_key,loaded_pk,creation_date) '||
      'select '||p_pk||','||p_pk_key||','||p_pk||',sysdate from '||l_table_new;
    else
      l_stmt:='insert ';
      l_stmt:=l_stmt||' into '||p_ltc_table||' A('||p_pk||','||p_pk_key||',NAME';
      for i in 1..l_number_fk loop
        l_stmt:=l_stmt||','||l_fk(i);
      end loop;
      l_stmt:=l_stmt||',creation_date,last_update_date) '||
      'select '||p_pk||','||p_pk_key||','||p_pk;
      for i in 1..l_number_fk loop
        l_stmt:=l_stmt||',0';--na_edw
      end loop;
      l_stmt:=l_stmt||',sysdate,sysdate from '||l_table_new;
    end if;
    begin
      if g_debug then
        write_to_log_file_n(l_stmt||get_time);
      end if;
      EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Inserted '||sql%rowcount||' rows'||get_time);
      end if;
      commit;
    exception when others then
      if g_debug then
        write_to_log_file_n('Error '||sqlerrm||get_time);
      end if;
      if sqlcode=-00001 then
        --value already present
        rollback;
        if g_debug then
          write_to_log_file_n('Re formulate tables and attempt '||get_time);
        end if;
        l_attempt_flag:=true;
      else
        g_status_message:=sqlerrm;
        g_status:=false;
        return false;
      end if;
    end;
    if l_attempt_flag then
      l_stmt:='insert into '||l_table_old||'('||p_pk||','||p_pk_key||') ';
      if p_pp_table is not null then --data alignment
        l_stmt:=l_stmt||' select B.pk,B.pk_key from '||l_table_new||' A,'||p_pp_table||' B where '||
        'A.'||p_pk||'=B.pk';
      else
        l_stmt:=l_stmt||' select B.'||p_pk||',B.'||p_pk_key||' from '||l_table_new||' A,'||p_ltc_table||' B '||
        'where A.'||p_pk||'=B.'||p_pk;
      end if;
      if g_debug then
        write_to_log_file_n(l_stmt||get_time);
      end if;
      EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Inserted '||sql%rowcount||' rows'||get_time);
      end if;
      commit;
    else --insert into ltc and/or dim table
      l_stmt:='create table '||l_table_union||' tablespace '||g_op_table_space;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  as select '||p_pk||','||p_pk_key||' from '||l_table_old||' UNION ALL '||
      ' select '||p_pk||','||p_pk_key||' from '||l_table_new;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_table_union)=false then
        null;
      end if;
      if g_debug then
        write_to_log_file_n(l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Created with '||sql%rowcount||' rows'||get_time);
      end if;
      l_stmt:='create table '||p_surr_table||' tablespace '||g_op_table_space;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  as select B.row_id,A.'||p_pk_key||' pk_key '||
      ' from '||l_table_union||' A,'||p_dang_table||' B where A.'||p_pk||'=B.'||p_dang_pk;
      if EDW_OWB_COLLECTION_UTIL.drop_table(p_surr_table)=false then
        null;
      end if;
      if g_debug then
        write_to_log_file_n(l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Created with '||sql%rowcount||' rows'||get_time);
      end if;
      if EDW_OWB_COLLECTION_UTIL.truncate_table(l_table_old)=false then
        null;
      end if;
      if p_pp_table is not null then --data alignment
        loop
          l_attempt_flag:=false;
          --we dont insert into DA table!!
          l_stmt:='create table '||l_table_new||' tablespace '||g_op_table_space;
          if g_parallel is not null then
            l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
          end if;
          l_stmt:=l_stmt||'  as select '||p_pk||','||p_pk_key||' from '||l_table_union||
          ' MINUS select '||p_pk||','||p_pk_key||' from '||l_table_old;
          if EDW_OWB_COLLECTION_UTIL.drop_table(l_table_new)=false then
            null;
          end if;
          if g_debug then
            write_to_log_file_n(l_stmt||get_time);
          end if;
          execute immediate l_stmt;
          if g_debug then
            write_to_log_file_n('Created with '||sql%rowcount||' rows'||get_time);
          end if;
          l_stmt:='insert ';
          l_stmt:=l_stmt||' into '||p_ltc_table||' A('||p_pk||','||p_pk_key||',NAME';
          for i in 1..l_number_fk loop
            l_stmt:=l_stmt||','||l_fk(i);
          end loop;
          l_stmt:=l_stmt||',creation_date,last_update_date) select '||p_pk||','||p_pk_key||','||p_pk;
          for i in 1..l_number_fk loop
            l_stmt:=l_stmt||',0';--na_edw
          end loop;
          l_stmt:=l_stmt||',sysdate,sysdate from '||l_table_new;
          if g_debug then
            write_to_log_file_n(l_stmt||get_time);
          end if;
          begin
            EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
            execute immediate l_stmt;
            if g_debug then
              write_to_log_file_n('Inserted '||sql%rowcount||' rows'||get_time);
            end if;
            commit;
          exception when others then
            if g_debug then
              write_to_log_file_n('Error '||sqlerrm||get_time);
            end if;
            if sqlcode=-00001 then
              rollback;
              if g_debug then
                write_to_log_file_n('Re-try a insert into level table after recreating the data');
              end if;
              l_attempt_flag:=true;
            else
              g_status_message:=sqlerrm;
              g_status:=false;
              return false;
            end if;
          end;
          if l_attempt_flag then
            l_stmt:='insert into '||l_table_old||'('||p_pk||','||p_pk_key||') ';
            l_stmt:=l_stmt||' select A.'||p_pk||',A.'||p_pk_key||' from '||l_table_new||' A,'||p_ltc_table||' B '||
            'where A.'||p_pk||'=B.'||p_pk;
            if g_debug then
              write_to_log_file_n(l_stmt||get_time);
            end if;
            EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
            execute immediate l_stmt;
            if g_debug then
              write_to_log_file_n('Inserted '||sql%rowcount||' rows'||get_time);
            end if;
            commit;
          else
            exit;
          end if;
        end loop;
      end if;
      if EDW_OWB_COLLECTION_UTIL.truncate_table(l_table_old)=false then
        null;
      end if;
      if p_dim_table is not null then
        if EDW_OWB_COLLECTION_UTIL.get_dim_lvl_pk_keys(null,p_dim_id,l_pk,l_number_pk)=false then
          g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
          return false;
        end if;
        if EDW_OWB_COLLECTION_UTIL.get_dim_lvl_name_cols(null,p_dim_id,l_name_col,l_number_name_col)=false then
          g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
          return false;
        end if;
        loop
          l_attempt_flag:=false;
          --we dont insert into DA table!!
          l_stmt:='create table '||l_table_new||' tablespace '||g_op_table_space;
          if g_parallel is not null then
            l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
          end if;
          l_stmt:=l_stmt||'  as select '||p_pk||','||p_pk_key||' from '||l_table_union||
          ' MINUS select '||p_pk||','||p_pk_key||' from '||l_table_old;
          if EDW_OWB_COLLECTION_UTIL.drop_table(l_table_new)=false then
            null;
          end if;
          if g_debug then
            write_to_log_file_n(l_stmt||get_time);
          end if;
          execute immediate l_stmt;
          if g_debug then
            write_to_log_file_n('Created with '||sql%rowcount||' rows'||get_time);
          end if;
          l_stmt:='insert ';
          l_stmt:=l_stmt||' into '||p_dim_table||' A('||p_dim_pk||','||p_dim_pk_key;
          for i in 1..l_number_pk loop
            if l_pk(i)<>p_dim_pk_key then
              l_stmt:=l_stmt||','||l_pk(i);
            end if;
          end loop;
          for i in 1..l_number_name_col loop
            l_stmt:=l_stmt||','||l_name_col(i);
          end loop;
          l_stmt:=l_stmt||',creation_date,last_update_date) select '||p_pk||','||p_pk_key;
          for i in 1..l_number_pk loop
            if l_pk(i)<>p_dim_pk_key then
              l_stmt:=l_stmt||',0';
            end if;
          end loop;
          for i in 1..l_number_name_col loop
            l_stmt:=l_stmt||','''||l_unassigned||'''';
          end loop;
          l_stmt:=l_stmt||',sysdate,sysdate from '||l_table_new;
          if g_debug then
            write_to_log_file_n(l_stmt||get_time);
          end if;
          begin
            EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
            execute immediate l_stmt;
            if g_debug then
              write_to_log_file_n('Inserted '||sql%rowcount||' rows'||get_time);
            end if;
            commit;
          exception when others then
            if g_debug then
              write_to_log_file_n('Error '||sqlerrm||get_time);
            end if;
            if sqlcode=-00001 then
              rollback;
              if g_debug then
                write_to_log_file_n('Re-try a insert into dim table after recreating the data');
              end if;
              l_attempt_flag:=true;
            else
              g_status_message:=sqlerrm;
              g_status:=false;
              return false;
            end if;
          end;
          if l_attempt_flag then
            l_stmt:='insert into '||l_table_old||'('||p_pk||','||p_pk_key||') ';
            l_stmt:=l_stmt||' select A.'||p_pk||',A.'||p_pk_key||' from '||l_table_new||' A,'||p_dim_table||' B '||
            'where A.'||p_pk||'=B.'||p_dim_pk;
            if g_debug then
              write_to_log_file_n(l_stmt||get_time);
            end if;
            EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
            execute immediate l_stmt;
            if g_debug then
              write_to_log_file_n('Inserted '||sql%rowcount||' rows'||get_time);
            end if;
            commit;
          else
            exit;
          end if;
        end loop;
      end if;
      exit;
    end if;
  end loop;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table_union)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table_old)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table_new)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table1)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table_distinct)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_dang_table_records '||g_status_message);
  g_status:=false;
  return false;
End;

function refind_insert_rows return boolean is
l_table1 varchar2(200);
l_table2 varchar2(200);
l_table3 varchar2(200);
l_stmt varchar2(30000);
l_count number;
Begin
  if g_debug then
    write_to_log_file_n('In refind_insert_rows '||get_time);
  end if;
  l_table1:=g_surr_table||'1';
  l_table2:=g_surr_table||'2';
  l_table3:=g_surr_table||'3';
  l_stmt:='create table '||l_table1||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  as select rowid row_id1,';
  if g_stg_copy_table_flag or g_use_mti then
    l_stmt:=l_stmt||'row_id_copy row_id from '||g_surr_table||' where operation_code=0';
  else
    l_stmt:=l_stmt||'row_id from '||g_surr_table||' where operation_code=0';
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table1)=false then
    null;
  end if;
  /*
  Please note that row_id of l_table1 is row_id_copy!!!
  */
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created with '||sql%rowcount||' rows'||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_table1,instr(l_table1,'.')+1,
  length(l_table1)),substr(l_table1,1,instr(l_table1,'.')-1));
  l_stmt:='create table '||l_table2||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  if g_stg_join_nl and g_stg_copy_table_flag=false then
    l_stmt:=l_stmt||' as select /*+ORDERED USE_NL(B)*/ ';
  else
    l_stmt:=l_stmt||' as select /*+ORDERED*/ ';
  end if;
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+parallel(B,'||g_parallel||')*/ ';
  end if;
  l_stmt:=l_stmt||'A.row_id1 row_id,B.'||g_fstgPKName||' from '||l_table1||' A,';
  if g_stg_copy_table_flag then
    l_stmt:=l_stmt||g_stg_copy_table||' B where A.row_id=B.rowid';
  elsif g_use_mti then
    l_stmt:=l_stmt||g_user_measure_table||' B where A.row_id=B.rowid';
  else
    l_stmt:=l_stmt||g_fstgTableName||' B where A.row_id=B.rowid';
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table2)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created with '||sql%rowcount||' rows'||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_table2,instr(l_table2,'.')+1,
  length(l_table2)),substr(l_table2,1,instr(l_table2,'.')-1));
  --4161164 : remove IOT , replace with ordinary table and index
  --l_stmt:='create table '||l_table3||'(row_id primary key,row_id1) organization index tablespace '||g_op_table_space;
  l_stmt:='create table '||l_table3||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  if g_fact_use_nl then
    l_stmt:=l_stmt||'  as select /*+ordered use_nl(B)*/ ';
  else
    l_stmt:=l_stmt||'  as select /*+ordered*/ ';
  end if;
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+parallel(B,'||g_parallel||')*/ ';
  end if;
  l_stmt:=l_stmt||'A.row_id,B.rowid row_id1 from '||l_table2||' A,'||g_FactTableName||' B where '||
  ' A.'||g_fstgPKName||'=B.'||g_factPKName;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table3)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created with '||sql%rowcount||' rows'||get_time);
  end if;
  --4161164 : remove IOT , replace with ordinary table and index
  EDW_OWB_COLLECTION_UTIL.create_iot_index(l_table3,'row_id',g_op_table_space,g_parallel);
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_table3,instr(l_table3,'.')+1,
  length(l_table3)),substr(l_table3,1,instr(l_table3,'.')-1));
  l_stmt:='update /*+ORDERED USE_NL(A)*/ '||g_surr_table||' A set (row_id1,operation_code)='||
  '(select row_id1,1 from '||l_table3||' where '||l_table3||'.row_id=A.rowid) where A.rowid in '||
  '(select row_id from '||l_table3||')';
  EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  l_count:=sql%rowcount;
  if g_debug then
    write_to_log_file_n('Updated '||l_count||' rows'||get_time);
  end if;
  commit;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table1)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table2)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table3)=false then
    null;
  end if;
  if l_count=0 then
    write_to_log_file_n('Could not update any rows for insert/update. Some other error');
    g_status:=false;
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in refind_insert_rows '||g_status_message);
  g_status:=false;
  return false;
End;

function execute_insert_stmt(p_count number) return boolean is
l_insert_type varchar2(200);
l_stmt varchar2(20000);
l_table1 varchar2(200);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_rowid rowid;
l_unique_violation boolean:=false;
Begin
  if g_debug then
    write_to_log_file_n('In execute_insert_stmt '||get_time);
  end if;
  l_insert_type:='MASS';
  l_table1:=g_insert_ctas_table||'R';
  insert_into_load_progress_d(g_load_pk,g_primary_target_name,g_jobid_stmt||'Inserting into '||g_primary_target_name,sysdate,
  null,'MAPPING','INSERT',g_jobid_stmt||'INSERT'||p_count,'I');
  <<start_insert>>
  if g_fact_audit or g_fact_net_change then
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_fact_audit_net_table)= false then
      null;
    end if;
  end if;
  /*
  when there is audit or net change g_insert_stmt creates g_fact_audit_net_table
  */
  if g_debug then
    write_to_debug_n('Going to INSERT rows '||get_time);
  end if;
  if l_insert_type='ROW-BY-ROW' and g_fact_audit=false and g_fact_net_change=false then
    if g_debug then
      write_to_log_file_n('ROW-BY-ROW inserts '||get_time);
    end if;
    l_unique_violation:=false;
    g_number_rows_processed:=0;
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_insert_ctas_table)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n(g_insert_stmt_ctas||get_time);
    end if;
    execute immediate g_insert_stmt_ctas;
    if g_debug then
      write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
    end if;
    l_stmt:='create table '||l_table1||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  as select rowid row_id from '||g_insert_ctas_table;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_table1)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n(l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
    end if;
    l_stmt:='select row_id from '||l_table1;
    if g_debug then
      write_to_log_file_n(l_stmt||get_time);
    end if;
    open cv for l_stmt;
    loop
      fetch cv into l_rowid;
      exit when cv%notfound;
      begin
        execute immediate g_insert_stmt_row using l_rowid;
        commit;
        g_number_rows_processed:=g_number_rows_processed+1;
      exception when others then
        write_to_log_file_n('Error in insert '||sqlerrm||get_time);
        rollback;
        if sqlcode=-00001 then
          l_unique_violation:=true;
        else
          g_status:=false;
          g_status_message:=sqlerrm;
          write_to_log_file_n('Error in g_insert_stmt '||g_status_message);
          return false;
        end if;
      end;
    end loop;
    close cv;
    if l_unique_violation then
      if refind_insert_rows=false then
        return false;
      end if;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_table1)=false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_insert_ctas_table)=false then
      null;
    end if;
    g_total_insert:=g_number_rows_processed;
  else
    if g_debug then
      write_to_log_file_n('MASS inserts '||get_time);
    end if;
    if g_fact_audit=false and g_fact_net_change=false then
      if g_parallel is null then
        EDW_OWB_COLLECTION_UTIL.alter_session('NO-PARALLEL');
      else
        if g_is_source=false and g_object_type='FACT' then
          if edw_owb_collection_util.is_source_for_fast_refresh_mv(g_primary_target_name,g_table_owner)=1 then
            --3529591
            EDW_OWB_COLLECTION_UTIL.alter_session('NO-PARALLEL');
          else
            null;
          end if;
        else
          EDW_OWB_COLLECTION_UTIL.alter_session('NO-PARALLEL');
        end if;
      end if;
    end if;
    begin
      EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
      execute immediate g_insert_stmt;
      g_number_rows_processed:=sql%rowcount;
      g_total_insert:=g_number_rows_processed;
      if g_debug then
        write_to_log_file_n('Inserted '||sql%rowcount||' rows'||get_time);
      end if;
      commit;
    exception when others then
      write_to_log_file_n('Insert failed '||sqlerrm||get_time);
      if g_fact_audit=false and g_fact_net_change=false then
        rollback;
        if sqlcode=-00001 then
          if g_debug then
            write_to_log_file_n('Unique constraint violated. Attempting again after finding rows for insert');
          end if;
          if refind_insert_rows=false then
            return false;
          end if;
          goto start_insert;
        elsif sqlcode=-4030 then
          l_insert_type:='ROW-BY-ROW';
          goto start_insert;
        elsif sqlcode=-00060 then
          if g_debug then
            write_to_log_file_n('Deadlock detected. Try again after sleep');
          end if;
          DBMS_LOCK.SLEEP(g_sleep_time);
          goto start_insert;
        else
          g_status:=false;
          g_status_message:=sqlerrm;
          write_to_log_file_n('Error in g_insert_stmt '||g_status_message);
          return false;
        end if;
      else
        g_status:=false;
        g_status_message:=sqlerrm;
        write_to_log_file_n('Error in g_insert_stmt '||g_status_message);
        return false;
      end if;
    end;
  end if;
  if g_fact_audit=false and g_fact_net_change=false then
    if g_parallel is not null then
      EDW_OWB_COLLECTION_UTIL.alter_session('PARALLEL');
      if g_debug then
        write_to_log_file_n('Session made parallel dml enabled');
      end if;
    end if;
  end if;
  insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'INSERT'||p_count,'U');
  if g_fact_audit or g_fact_net_change then
    --analyze
    insert_into_load_progress_d(g_load_pk,g_primary_target_name,g_jobid_stmt||'Process Audit or Netchange Records',sysdate,
    null,'MAPPING','INSERT',g_jobid_stmt||'INSERTAN'||p_count,'I');
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_fact_audit_net_table,
    instr(g_fact_audit_net_table,'.')+1,length(g_fact_audit_net_table)),
    substr(g_fact_audit_net_table,1,instr(g_fact_audit_net_table,'.')-1));
    if l_insert_type='ROW-BY-ROW' then
      g_number_rows_processed:=0;
      l_unique_violation:=false;
      l_stmt:='create table '||l_table1||' tablespace '||g_op_table_space;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  as select rowid row_id from '||g_fact_audit_net_table;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_table1)=false then
        null;
      end if;
      if g_debug then
        write_to_log_file_n(l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
      end if;
      l_stmt:='select row_id from '||l_table1;
      if g_debug then
        write_to_log_file_n(l_stmt||get_time);
      end if;
      open cv for l_stmt;
      loop
        fetch cv into l_rowid;
        exit when cv%notfound;
        begin
          execute immediate g_audit_net_insert_stmt_row using l_rowid;
          commit;
          g_number_rows_processed:=g_number_rows_processed+1;
        exception when others then
          if sqlcode=-00001 then
            rollback;
            l_unique_violation:=true;
          else
            g_status:=false;
            g_status_message:=sqlerrm;
            write_to_log_file_n('Error in g_audit_net_insert_stmt_row '||g_status_message);
            return false;
          end if;
        end;
      end loop;
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_table1)=false then
        null;
      end if;
      g_total_insert:=g_number_rows_processed;
      if l_unique_violation then
        if refind_insert_rows=false then
          return false;
        end if;
        --recreate g_fact_audit_net_table
        if g_debug then
          write_to_log_file_n('Re-create g_fact_audit_net_table '||g_fact_audit_net_table||get_time);
        end if;
        execute immediate g_insert_stmt;
        if g_debug then
          write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
        end if;
      end if;
    else
      if g_debug then
        write_to_debug_n('MASS INSERT. Going to execute g_audit_net_insert_stmt'||get_time);
      end if;
      --insert into the fact
      if g_parallel is null then
        EDW_OWB_COLLECTION_UTIL.alter_session('NO-PARALLEL');
      else
        if g_is_source=false and g_object_type='FACT' then
          if edw_owb_collection_util.is_source_for_fast_refresh_mv(g_primary_target_name,g_table_owner)=1 then
            --3529591
            EDW_OWB_COLLECTION_UTIL.alter_session('NO-PARALLEL');
          else
            null;
          end if;
        else
          EDW_OWB_COLLECTION_UTIL.alter_session('NO-PARALLEL');
        end if;
      end if;
      begin
        EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
        execute immediate g_audit_net_insert_stmt;
        g_number_rows_processed:=sql%rowcount;
        g_total_insert:=g_number_rows_processed;
        commit;
        if g_debug then
          write_to_log_file_n('Inserted '||g_number_rows_processed||' rows '||get_time);
        end if;
      exception when others then
        if sqlcode=-00001 then
          rollback;
          if g_debug then
            write_to_log_file_n('Unique constraint violated. Attempting again after finding rows for insert');
          end if;
          if refind_insert_rows=false then
            return false;
          end if;
          goto start_insert;
        elsif sqlcode=-00060 then
          if g_debug then
            write_to_log_file_n('Deadlock detected. Try again after sleep');
          end if;
          DBMS_LOCK.SLEEP(g_sleep_time);
          goto start_insert;
        else
          g_status:=false;
          g_status_message:=sqlerrm;
          write_to_log_file_n('Error in g_audit_net_insert_stmt '||g_status_message);
          return false;
        end if;
      end;
    end if;
    if g_parallel is not null then
      EDW_OWB_COLLECTION_UTIL.alter_session('PARALLEL');
    end if;
    insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'INSERTAN'||p_count,'U');
  end if;
  if g_debug then
    write_to_log_file_n('Inserted '||g_number_rows_processed||' Rows '||get_time);
  end if;
  if g_fact_audit or g_fact_net_change then
    insert_into_load_progress_d(g_load_pk,g_primary_target_name,g_jobid_stmt||'Process Audit or Netchange Records',sysdate,
    null,'MAPPING','INSERT',g_jobid_stmt||'INSERTANN'||p_count,'I');
    if execute_fa_nc_insert('INSERT') = false then
      insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'INSERTANN'||p_count,'U');
      return false;
    end if;
    insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,g_jobid_stmt||'INSERTANN'||p_count,'U');
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in execute_insert_stmt '||g_status_message);
  g_status:=false;
  return false;
End;

function set_g_type_ok_generation return boolean is
l_percentage number;
--cut off kept at 5%
l_total_records number;
Begin
  if g_debug then
    write_to_log_file_n('In set_g_type_ok_generation '||g_total_records||' '||g_ok_rowid_number||' '||
    g_collection_size);
  end if;
  if g_ok_rowid_number is null then
    l_total_records:=g_total_records;
  else
    l_total_records:=g_ok_rowid_number;
  end if;
  if g_ok_switch_update=100 then
    g_type_ok_generation:='UPDATE';
    write_to_debug_n('g_type_ok_generation made UPDATE');
  else
    if g_collection_size>0 then
      if l_total_records>0 then
        l_percentage:=100*(g_collection_size/l_total_records);
        write_to_debug_n('l_percentage='||l_percentage);
        if l_percentage<g_ok_switch_update then
          g_type_ok_generation:='UPDATE';
          write_to_debug_n('g_type_ok_generation made UPDATE');
        end if;
      end if;
    end if;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in set_g_type_ok_generation '||g_status_message);
  return false;
End;

function check_stg_make_copy(p_load_size number, p_total_records number) return boolean is
l_percentage number;
Begin
  write_to_debug_n('In check_stg_make_copy p_load_size='||p_load_size||',p_total_records='||p_total_records);
  g_stg_copy_table_flag:=false;
  if p_load_size=0 then --there is no commit size
    g_stg_copy_table_flag:=false;
    write_to_debug_n('Commit size is ALL. So g_stg_copy_table_flag made FALSE');
  elsif g_stg_make_copy_percentage=0 then
    g_stg_copy_table_flag:=false;
    write_to_debug_n('g_stg_copy_table_flag made FALSE');
  elsif g_stg_make_copy_percentage=100 then
    g_stg_copy_table_flag:=true;
    g_use_mti:=false;
    write_to_debug_n('g_stg_copy_table_flag made TRUE');
  else
    if p_load_size>0 then
      if p_total_records>0 then
        l_percentage:=100*(p_load_size/p_total_records);
        write_to_debug_n('l_percentage='||l_percentage);
        if l_percentage<=g_stg_make_copy_percentage then
          g_stg_copy_table_flag:=true;
          g_use_mti:=false;
          write_to_debug_n('g_stg_copy_table_flag made TRUE');
        end if;
      end if;
    end if;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in check_stg_make_copy '||g_status_message);
  return false;
End;

function make_stg_copy return boolean is
l_extent number;
l_divide number;
l_table varchar2(200);
l_columns EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_columns number;
Begin
  write_to_debug_n('In make_stg_copy');
  if g_number_fstg_columns is null then
    if get_fstg_col_parameters=false then
      return false;
    end if;
  end if;
  l_number_columns:=0;
  l_table:=g_stg_copy_table||'T';
  g_stmt:='create table '||l_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    g_stmt:=g_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  g_stmt:=g_stmt||' as select row_id from '||g_ok_rowid_table||' where status=1';
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||g_stmt||get_time);
  end if;
  execute immediate g_stmt;
  if g_type_ok_generation='CTAS' then
    g_number_rows_ready:=sql%rowcount;
  end if;
  if g_debug then
    write_to_log_file_n('Created with '||g_number_rows_ready||' rows '||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_table,instr(l_table,'.')+1,
  length(l_table)),substr(l_table,1,instr(l_table,'.')-1));
  g_stmt:='create table '||g_stg_copy_table||' tablespace '||g_op_table_space;
  if g_fact_next_extent is not null then
    if g_parallel is null then
      l_divide:=2;
    else
      l_divide:=g_parallel;
    end if;
    l_extent:=g_fact_next_extent/l_divide;
    if l_extent>16777216 then --16M
      l_extent:=16777216;
    end if;
    if l_extent is null or l_extent=0 then
      l_extent:=8388608;
    end if;
    g_stmt:=g_stmt||' storage(initial '||l_extent||' next '||
    l_extent||' pctincrease 0 MAXEXTENTS 2147483645) ';
  end if;
  if g_parallel is not null then
    g_stmt:=g_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  if g_stg_join_nl then
    g_stmt:=g_stmt||' as select /*+ORDERED USE_NL('||g_fstgTableName||')*/ ';
  else
    g_stmt:=g_stmt||' as select /*+ORDERED*/ ';
  end if;
  if g_parallel is not null then
    g_stmt:=g_stmt||' /*+PARALLEL ('||g_fstgTableName||','||g_parallel||')*/  ';
  end if;
  g_stmt:=g_stmt||g_fstgTableName||'.rowid row_id,';
  if g_pk_key_seq is null then
    g_stmt:=g_stmt||g_fstgPKNameKey||',';
    l_number_columns:=l_number_columns+1;
    l_columns(l_number_columns):=g_fstgPKNameKey;
  end if;
  for i in 1..g_num_ff_map_cols loop
    if i<>g_pk_key_seq_pos then
      if g_skip_item(i)=false then
        if g_fact_mapping_columns(i)<>g_factPKNameKey then
          g_stmt:=g_stmt||g_fstg_mapping_columns(i)||',';
          l_number_columns:=l_number_columns+1;
          l_columns(l_number_columns):=substr(g_fstg_mapping_columns(i),instr(
          g_fstg_mapping_columns(i),'.')+1,length(g_fstg_mapping_columns(i)));
        end if;
      end if;
    end if;
  end loop;
  g_stmt:=substr(g_stmt,1,length(g_stmt)-1);
  --put the fks
  for i in 1..g_numberOfDimTables loop
    if EDW_OWB_COLLECTION_UTIL.value_in_table(l_columns,l_number_columns,
      g_fstgUserFKName(i))=false then
      if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
        g_stmt:=g_stmt||','||g_fstgUserFKName(i);
      elsif g_fstg_fk_value_load(i)=true then
        g_stmt:=g_stmt||','||g_fstg_fk_load_value(i)||' '||g_fstgUserFKName(i);
      else
        g_stmt:=g_stmt||','||g_fstgUserFKName(i);
      end if;
    end if;
  end loop;
  if g_creation_date_flag then
    g_stmt:=g_stmt||',creation_date';
  end if;
  if g_last_update_date_flag then
    g_stmt:=g_stmt||',last_update_date';
  end if;
  if EDW_OWB_COLLECTION_UTIL.value_in_table(l_columns,l_number_columns,'OPERATION_CODE')=false then
    g_stmt:=g_stmt||',operation_code';
  end if;
  g_stmt:=g_stmt||' from '||l_table||','||g_fstgTableName||' where '||l_table||'.row_id='||
  g_fstgTableName||'.rowid';
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_stg_copy_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||g_stmt||get_time);
  end if;
  execute immediate g_stmt;
  if g_debug then
    write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_stg_copy_table,instr(g_stg_copy_table,'.')+1,
  length(g_stg_copy_table)),substr(g_stg_copy_table,1,instr(g_stg_copy_table,'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in make_stg_copy '||g_status_message);
  return false;
End;

function drop_input_tables(p_table_name varchar2) return boolean is
Begin
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_table_name)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_table_name||'_SC')=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_table_name||'_DC')=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_table_name||'_SL')=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_table_name||'_SU')=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in drop_input_tables '||g_status_message);
  return false;
End;

function read_options_table(p_table_name varchar2) return boolean is
l_fact_audit varchar2(10);
l_net_change varchar2(10);
l_debug varchar2(10);
l_duplicate_collect varchar2(10);
l_execute_flag varchar2(10);
l_temp_log varchar2(10);
l_explain_plan_check varchar2(10);
l_fresh_restart varchar2(10);
l_smart_update varchar2(10);
l_log_dang_keys varchar2(10);
l_create_parent_table_records varchar2(10);
l_check_fk_change varchar2(10);
l_trace varchar2(10);
l_read_cfig_options varchar2(10);
l_dlog_has_data varchar2(10);
l_stg_copy_table_flag varchar2(10);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_skip_cols_table varchar2(80);
l_da_cols_table varchar2(80);
l_skip_levels_table varchar2(80);
l_smart_update_table varchar2(80);
l_parallel_drill_down varchar2(10);
Begin
  write_to_log_file_n('In read_options_table '||p_table_name);
  l_skip_cols_table:=p_table_name||'_SC';
  l_da_cols_table:=p_table_name||'_DC';
  l_skip_levels_table:=p_table_name||'_SL';
  l_smart_update_table:=p_table_name||'_SU';
  g_stmt:='select '||
  'object_name'||
  ',mapping_id'||
  ',map_type'||
  ',primary_src'||
  ',primary_target'||
  ',primary_target_name'||
  ',object_type'||
  ',conc_id'||
  ',conc_program_name'||
  ',fact_audit'||
  ',net_change'||
  ',fact_audit_name'||
  ',net_change_name'||
  ',fact_audit_is_name'||
  ',net_change_is_name'||
  ',debug'||
  ',duplicate_collect'||
  ',execute_flag'||
  ',request_id'||
  ',collection_size'||
  ',parallel'||
  ',table_owner'||
  ',bis_owner'||
  ',temp_log'||
  ',forall_size'||
  ',update_type'||
  ',p_mode'||
  ',explain_plan_check'||
  ',fact_dlog'||
  ',key_set'||
  ',instance_type'||
  ',load_pk'||
  ',fresh_restart'||
  ',op_table_space'||
  ',da_table'||
  ',pp_table'||
  ',master_instance'||
  ',rollback'||
  ',smart_update'||
  ',fk_use_nl'||
  ',fact_smart_update'||
  ',auto_dang_table_extn'||
  ',log_dang_keys'||
  ',create_parent_table_records'||
  ',check_fk_change'||
  ',stg_join_nl_percentage'||
  ',ok_switch_update'||
  ',stg_make_copy_percentage'||
  ',ok_table'||
  ',hash_area_size'||
  ',sort_area_size'||
  ',trace_mode'||
  ',read_cfig_options'||
  ',job_status_table'||
  ',max_round'||
  ',update_dlog_lookup_table'||
  ',dlog_has_data'||
  ',total_records'||
  ',stg_copy_table_flag,'||
  'sleep_time,'||
  'parallel_drill_down'||
  ' from '||p_table_name;
  if g_debug then
    write_to_log_file_n(g_stmt||get_time);
  end if;
  open cv for g_stmt;
  fetch cv into
   g_object_name
  ,g_mapping_id
  ,g_mapping_type
  ,g_primary_src
  ,g_primary_target
  ,g_primary_target_name
  ,g_object_type
  ,g_conc_program_id
  ,g_conc_program_name
  ,l_fact_audit
  ,l_net_change
  ,g_fact_audit_name
  ,g_fact_net_change_name
  ,g_fact_audit_is_name
  ,g_fact_net_change_is_name
  ,l_debug
  ,l_duplicate_collect
  ,l_execute_flag
  ,g_request_id
  ,g_collection_size
  ,g_parallel
  ,g_table_owner
  ,g_bis_owner
  ,l_temp_log
  ,g_forall_size
  ,g_update_type
  ,g_mode
  ,l_explain_plan_check
  ,g_fact_dlog
  ,g_key_set
  ,g_instance_type
  ,g_load_pk
  ,l_fresh_restart
  ,g_op_table_space
  ,g_da_table
  ,g_pp_table
  ,g_master_instance
  ,g_rollback
  ,l_smart_update
  ,g_fk_use_nl
  ,g_fact_smart_update
  ,g_auto_dang_table_extn
  ,l_log_dang_keys
  ,l_create_parent_table_records
  ,l_check_fk_change
  ,g_stg_join_nl_percentage
  ,g_ok_switch_update
  ,g_stg_make_copy_percentage
  ,g_main_ok_table_name
  ,g_hash_area_size
  ,g_sort_area_size
  ,l_trace
  ,l_read_cfig_options
  ,g_job_status_table
  ,g_max_round
  ,g_update_dlog_lookup_table
  ,l_dlog_has_data
  ,g_total_records
  ,l_stg_copy_table_flag
  ,g_sleep_time
  ,l_parallel_drill_down;
  close cv;
  --set the boolean values
  g_fact_audit:=false;
  g_fact_net_change:=false;
  g_debug:=false;
  g_duplicate_collect:=false;
  g_execute_flag:=false;
  g_temp_log:=false;
  g_explain_plan_check:=false;
  g_fresh_restart:=false;
  g_smart_update:=false;
  g_log_dang_keys:=false;
  g_create_parent_table_records:=false;
  g_check_fk_change:=false;
  g_trace:=false;
  g_read_cfig_options:=false;
  g_dlog_has_data:=false;
  g_stg_copy_table_flag:=false;
  g_parallel_drill_down:=false;
  if l_fact_audit='Y' then
    g_fact_audit:=true;
  end if;
  if l_net_change='Y' then
    g_fact_net_change:=true;
  end if;
  if l_debug='Y' then
    g_debug:=true;
  end if;
  if l_duplicate_collect='Y' then
    g_duplicate_collect:=true;
  end if;
  if l_execute_flag='Y' then
    g_execute_flag:=true;
  end if;
  if l_temp_log='Y' then
    g_temp_log:=true;
  end if;
  if l_explain_plan_check='Y' then
    g_explain_plan_check:=true;
  end if;
  if l_fresh_restart='Y' then
    g_fresh_restart:=true;
  end if;
  if l_smart_update='Y' then
    g_smart_update:=true;
  end if;
  if l_log_dang_keys='Y' then
    g_log_dang_keys:=true;
  end if;
  if l_create_parent_table_records='Y' then
    g_create_parent_table_records:=true;
  end if;
  if l_check_fk_change='Y' then
    g_check_fk_change:=true;
  end if;
  if l_trace='Y' then
    g_trace:=true;
  end if;
  if l_read_cfig_options='Y' then
    g_read_cfig_options:=true;
  end if;
  if l_dlog_has_data='Y' then
    g_dlog_has_data:=true;
  end if;
  if l_stg_copy_table_flag='Y' then
    g_stg_copy_table_flag:=true;
    g_use_mti:=false;
  end if;
  if l_parallel_drill_down='Y' then
    g_parallel_drill_down:=true;
  end if;
  if g_debug then
    write_to_log_file_n('Values read');
    write_to_log_file('g_object_name='||g_object_name);
    write_to_log_file('g_mapping_id='||g_mapping_id);
    write_to_log_file('g_mapping_type='||g_mapping_type);
    write_to_log_file('g_primary_src='||g_primary_src);
    write_to_log_file('g_primary_target='||g_primary_target);
    write_to_log_file('g_primary_target_name='||g_primary_target_name);
    write_to_log_file('g_object_type='||g_object_type);
    write_to_log_file('g_conc_program_id='||g_conc_program_id);
    write_to_log_file('g_conc_program_name='||g_conc_program_name);
    write_to_log_file('l_fact_audit='||l_fact_audit);
    write_to_log_file('l_net_change='||l_net_change);
    write_to_log_file('g_fact_audit_name='||g_fact_audit_name);
    write_to_log_file('g_fact_net_change_name='||g_fact_net_change_name);
    write_to_log_file('g_fact_audit_is_name='||g_fact_audit_is_name);
    write_to_log_file('g_fact_net_change_is_name='||g_fact_net_change_is_name);
    write_to_log_file('l_debug='||l_debug);
    write_to_log_file('l_duplicate_collect='||l_duplicate_collect);
    write_to_log_file('l_execute_flag='||l_execute_flag);
    write_to_log_file('g_request_id='||g_request_id);
    write_to_log_file('g_collection_size='||g_collection_size);
    write_to_log_file('g_parallel='||g_parallel);
    write_to_log_file('g_table_owner='||g_table_owner);
    write_to_log_file('g_bis_owner='||g_bis_owner);
    write_to_log_file('l_temp_log='||l_temp_log);
    write_to_log_file('g_forall_size='||g_forall_size);
    write_to_log_file('g_update_type='||g_update_type);
    write_to_log_file('g_mode='||g_mode);
    write_to_log_file('l_explain_plan_check='||l_explain_plan_check);
    write_to_log_file('g_fact_dlog='||g_fact_dlog);
    write_to_log_file('g_key_set='||g_key_set);
    write_to_log_file('g_instance_type='||g_instance_type);
    write_to_log_file('g_load_pk='||g_load_pk);
    write_to_log_file('l_fresh_restart='||l_fresh_restart);
    write_to_log_file('g_op_table_space='||g_op_table_space);
    write_to_log_file('g_da_table='||g_da_table);
    write_to_log_file('g_pp_table='||g_pp_table);
    write_to_log_file('g_master_instance='||g_master_instance);
    write_to_log_file('g_rollback='||g_rollback);
    write_to_log_file('l_smart_update='||l_smart_update);
    write_to_log_file('g_fk_use_nl='||g_fk_use_nl);
    write_to_log_file('g_fact_smart_update='||g_fact_smart_update);
    write_to_log_file('g_auto_dang_table_extn='||g_auto_dang_table_extn);
    write_to_log_file('l_log_dang_keys='||l_log_dang_keys);
    write_to_log_file('l_create_parent_table_records='||l_create_parent_table_records);
    write_to_log_file('l_check_fk_change='||l_check_fk_change);
    write_to_log_file('g_stg_join_nl_percentage='||g_stg_join_nl_percentage);
    write_to_log_file('g_ok_switch_update='||g_ok_switch_update);
    write_to_log_file('g_stg_make_copy_percentage='||g_stg_make_copy_percentage);
    write_to_log_file('g_main_ok_table_name='||g_main_ok_table_name);
    write_to_log_file('g_hash_area_size='||g_hash_area_size);
    write_to_log_file('g_sort_area_size='||g_sort_area_size);
    write_to_log_file('l_trace='||l_trace);
    write_to_log_file('l_read_cfig_options='||l_read_cfig_options);
    write_to_log_file('g_job_status_table='||g_job_status_table);
    write_to_log_file('g_max_round='||g_max_round);
    write_to_log_file('g_update_dlog_lookup_table='||g_update_dlog_lookup_table);
    write_to_log_file('l_dlog_has_data='||l_dlog_has_data);
    write_to_log_file('g_total_records='||g_total_records);
    write_to_log_file('l_stg_copy_table_flag='||l_stg_copy_table_flag);
    write_to_log_file('g_sleep_time='||g_sleep_time);
    write_to_log_file('l_parallel_drill_down='||l_parallel_drill_down);
  end if;
  --now read the skip cols
  g_stmt:='select col_name from '||l_skip_cols_table;
  if g_debug then
    write_to_log_file_n(g_stmt||get_time);
  end if;
  g_number_skip_cols:=1;
  open cv for g_stmt;
  loop
    fetch cv into g_skip_cols(g_number_skip_cols);
    exit when cv%notfound;
    g_number_skip_cols:=g_number_skip_cols+1;
  end loop;
  close cv;
  g_number_skip_cols:=g_number_skip_cols-1;
  if g_debug then
    write_to_log_file_n('Skip columns');
    for i in 1..g_number_skip_cols loop
      write_to_log_file(g_skip_cols(i));
    end loop;
  end if;
  --read the DA columns
  g_stmt:='select col_name,stg_col_name from '||l_da_cols_table;
  g_number_da_cols:=1;
  open cv for g_stmt;
  loop
    fetch cv into g_da_cols(g_number_da_cols),g_stg_da_cols(g_number_da_cols);
    exit when cv%notfound;
    g_number_da_cols:=g_number_da_cols+1;
  end loop;
  close cv;
  g_number_da_cols:=g_number_da_cols-1;
  if g_debug then
    write_to_log_file_n('DA columns');
    for i in 1..g_number_da_cols loop
      write_to_log_file(g_da_cols(i)||' '||g_stg_da_cols(i));
    end loop;
  end if;
  --read the skip levels
  g_stmt:='select col_name from '||l_skip_levels_table;
  g_number_skip_levels:=1;
  open cv for g_stmt;
  loop
    fetch cv into g_skip_levels(g_number_skip_levels);
    exit when cv%notfound;
    g_number_skip_levels:=g_number_skip_levels+1;
  end loop;
  close cv;
  g_number_skip_levels:=g_number_skip_levels-1;
  if g_debug then
    write_to_log_file_n('Skip Levels');
    for i in 1..g_number_skip_levels loop
      write_to_log_file(g_skip_levels(i));
    end loop;
  end if;
  --read the smart update columns
  g_stmt:='select col_name from '||l_smart_update_table;
  g_number_smart_update_cols:=1;
  open cv for g_stmt;
  loop
    fetch cv into g_smart_update_cols(g_number_smart_update_cols);
    exit when cv%notfound;
    g_number_smart_update_cols:=g_number_smart_update_cols+1;
  end loop;
  close cv;
  g_number_smart_update_cols:=g_number_smart_update_cols-1;
  if g_debug then
    write_to_log_file_n('Smart Update Columns');
    for i in 1..g_number_smart_update_cols loop
      write_to_log_file(g_smart_update_cols(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in read_options_table '||g_status_message);
  return false;
End;

function merge_all_ok_tables return boolean is
l_ok_rowid_table varchar2(80);
l_ok_rowid_table2 varchar2(80);
l_stmt varchar2(8000);
Begin
  --g_ok_rowid_table
  if g_debug then
    write_to_log_file_n('In merge_all_ok_tables');
  end if;
  if substr(g_ok_rowid_table,length(g_ok_rowid_table),1)='A' then
    l_ok_rowid_table:=substr(g_ok_rowid_table,1,length(g_ok_rowid_table)-1);
    l_ok_rowid_table2:=g_ok_rowid_table;
  else
    l_ok_rowid_table:=g_ok_rowid_table;
    l_ok_rowid_table2:=g_ok_rowid_table||'A';
  end if;
  if EDW_OWB_COLLECTION_UTIL.merge_all_ilog_tables(
    g_ok_rowid_table,
    l_ok_rowid_table,
    l_ok_rowid_table2,
    'OK',
    g_op_table_space,
    g_bis_owner,
    g_parallel)=false then
    return false;
  end if;
  --update the collection status of Interface table to ready if there is status 1 in ok tables
  if EDW_OWB_COLLECTION_UTIL.does_table_have_data(l_ok_rowid_table,' status=1 ')=2 then
    if g_debug then
      write_to_log_file_n(l_ok_rowid_table||' has status 1. we need to update interface table '||
      'to READY for these rows');
    end if;
    if update_stg_status_column(l_ok_rowid_table,'row_id',' where status=1 ','READY',true)=false then
      return false;
    end if;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in merge_all_ok_tables '||g_status_message);
  return false;
End;

/*
this function is executed if there is multi threading.
we need rownum in the ok table so that each child process can then take its part of the
ok table
*/
function put_rownum_in_ok_table return boolean is
l_ok_table varchar2(80);
Begin
  write_to_debug_n('In put_rownum_in_ok_table');
  l_ok_table:=g_ok_rowid_table;
  if substr(g_ok_rowid_table,length(g_ok_rowid_table),1)='A' then
    g_ok_rowid_table:=substr(g_ok_rowid_table,1,length(g_ok_rowid_table)-1);
  else
    g_ok_rowid_table:=g_ok_rowid_table||'A';
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_ok_rowid_table)=false then
    null;
  end if;
  g_stmt:='create table '||g_ok_rowid_table||' tablespace '||g_op_table_space;
  g_stmt:=g_stmt||' storage (initial 4M next 4M pctincrease 0) ';
  if g_parallel is not null then
    g_stmt:=g_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  g_stmt:=g_stmt||' as select '||l_ok_table||'.*,rownum row_num from '||l_ok_table;
  if g_debug then
    write_to_log_file_n(g_stmt||get_time);
  end if;
  execute immediate g_stmt;
  if g_debug then
    write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
  end if;
  --create the index
  g_stmt:='create unique index '||g_ok_rowid_table||'u on '||g_ok_rowid_table||'(row_num) '||
  'tablespace '||g_op_table_space;
  if g_parallel is not null then
    g_stmt:=g_stmt||' parallel '||g_parallel;
  end if;
  if g_debug then
    write_to_log_file_n(g_stmt||get_time);
  end if;
  execute immediate g_stmt;
  if g_debug then
    write_to_log_file_n('Created index '||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_ok_rowid_table,instr(g_ok_rowid_table,'.')+1,
  length(g_ok_rowid_table)),substr(g_ok_rowid_table,1,instr(g_ok_rowid_table,'.')-1));
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_ok_table)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in put_rownum_in_ok_table '||g_status_message);
  return false;
End;

function make_ok_from_main_ok(
p_ok_table varchar2,
p_low_end number,
p_high_end number
) return boolean is
l_err_rec_flag boolean;
Begin
  write_to_debug_n('In make_ok_from_main_ok '||p_ok_table||' '||p_low_end||' '||p_high_end);
  if EDW_OWB_COLLECTION_UTIL.make_ilog_from_main_ilog(
    g_ok_rowid_table,
    p_ok_table,
    p_low_end,
    p_high_end,
    g_op_table_space,
    g_bis_owner,
    g_parallel,
    g_ok_rowid_number)=false then
    return false;
  end if;
  l_err_rec_flag:=false;
  if check_ok_table(g_ok_rowid_table,l_err_rec_flag,g_number_rows_ready)=false then
    return false;
  end if;
  if l_err_rec_flag=true then
    g_skip_ilog_update:=true;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in make_ok_from_main_ok '||g_status_message);
  return false;
End;

/*
called when being run as a job
*/
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

function dlog_setup return boolean is
l_dlog varchar2(80);
l_owner varchar2(80);
Begin
  if g_debug then
    write_to_log_file_n('In dlog_setup');
  end if;
  g_dlog_has_data:=false;
  if instr(g_fact_dlog,g_bis_owner||'.') <> 0 then
    l_dlog:=substr(g_fact_dlog,instr(g_fact_dlog,'.')+1,length(g_fact_dlog));
    l_owner:=g_bis_owner;
  else
    l_dlog:=g_fact_dlog;
    l_owner:=EDW_OWB_COLLECTION_UTIL.get_table_owner(g_fact_dlog);
  end if;
  if EDW_OWB_COLLECTION_UTIL.get_db_columns_for_table(l_dlog,g_dlog_columns,g_number_dlog_columns,
    l_owner) = false then
    return false;
  end if;
  if EDW_OWB_COLLECTION_UTIL.check_table(g_fact_dlog) then
    if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_fact_dlog)=2 then
      g_dlog_has_data:=true;
      if create_dlog_lookup_table=false then
        return false;
      end if;
    else
      g_dlog_has_data:=false;
    end if;
    if g_dlog_has_data then
      if recreate_dlog_table=false then
        return false;
      end if;
    end if;
    if check_cols_in_dlog=false then
      return false;
    end if;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in dlog_setup '||g_status_message);
  return false;
End;

function set_stg_nl_parameters(p_load_size number) return boolean is
l_lstg_count number;
l_load_size number;
Begin
  if g_debug then
    write_to_log_file_n('In set_stg_nl_parameters '||p_load_size);
  end if;
  g_stg_join_nl:=true;
  l_lstg_count:=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_fstgTableName,g_table_owner);
  if p_load_size>g_collection_size then
    l_load_size:=g_collection_size;
  else
    l_load_size:=p_load_size;
  end if;
  write_to_debug_n('lstg count is '||l_lstg_count||', l_load_size='||l_load_size);
  if l_lstg_count is not null and l_lstg_count>0 then
    g_stg_join_nl:=EDW_OWB_COLLECTION_UTIL.get_join_nl(l_load_size,l_lstg_count,
    g_stg_join_nl_percentage);
    if g_use_mti=false then
      if check_stg_make_copy(l_load_size,l_lstg_count)=false then
        g_stg_copy_table_flag:=false;
      end if;
    end if;
  end if;
  if g_debug then
    if g_stg_join_nl then
      write_to_log_file_n('g_stg_join_nl TRUE');
    else
      write_to_log_file_n('g_stg_join_nl FALSE');
    end if;
    if g_stg_copy_table_flag then
      write_to_log_file_n('g_stg_copy_table_flag TRUE');
    else
      write_to_log_file_n('g_stg_copy_table_flag FALSE');
    end if;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in set_stg_nl_parameters '||g_status_message);
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
  l_exe_file_name:='EDW_MAPPING_COLLECT.COLLECT';
  l_parameter(1):='p_object_name';
  l_parameter_value_set(1):='FND_CHAR240';
  l_parameter(2):='p_target_name';
  l_parameter_value_set(2):='FND_CHAR240';
  l_parameter(3):='p_table_name';
  l_parameter_value_set(3):='FND_CHAR240';
  l_parameter(4):='p_job_id';
  l_parameter_value_set(4):='FND_NUMBER';
  l_parameter(5):='p_ok_low_end';
  l_parameter_value_set(5):='FND_NUMBER';
  l_parameter(6):='p_ok_high_end';
  l_parameter_value_set(6):='FND_NUMBER';
  l_parameter(7):='p_rownum_for_seq_num';
  l_parameter_value_set(7):='FND_NUMBER';
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

function create_conc_program_dup(
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
  l_exe_file_name:=upper('EDW_MAPPING_COLLECT.execute_duplicate_stmt_multi');
  l_parameter(1):='p_object_name';
  l_parameter_value_set(1):='FND_CHAR240';
  l_parameter(2):='p_primary_target_name';
  l_parameter_value_set(2):='FND_CHAR240';
  l_parameter(3):='p_fstgTableName';
  l_parameter_value_set(3):='FND_CHAR240';
  l_parameter(4):='p_job_id';
  l_parameter_value_set(4):='FND_NUMBER';
  l_parameter(5):='p_low_end';
  l_parameter_value_set(5):='FND_NUMBER';
  l_parameter(6):='p_high_end';
  l_parameter_value_set(6):='FND_NUMBER';
  l_parameter(7):='p_dup_hold_table';
  l_parameter_value_set(7):='FND_CHAR240';
  l_parameter(8):='p_debug';
  l_parameter_value_set(8):='FND_CHAR240';
  l_parameter(9):='p_bis_owner';
  l_parameter_value_set(9):='FND_CHAR240';
  l_parameter(10):='p_op_table_space';
  l_parameter_value_set(10):='FND_CHAR240';
  l_parameter(11):='p_parallel';
  l_parameter_value_set(11):='FND_NUMBER';
  l_parameter(12):='p_duplicate_collect';
  l_parameter_value_set(12):='FND_CHAR240';
  l_parameter(13):='p_update_type';
  l_parameter_value_set(13):='FND_CHAR240';
  l_parameter(14):='p_low_system_mem';
  l_parameter_value_set(14):='FND_CHAR240';
  l_parameter(15):='p_rollback';
  l_parameter_value_set(15):='FND_CHAR240';
  l_parameter(16):='p_status_table';
  l_parameter_value_set(16):='FND_CHAR240';
  l_number_parameters:=16;
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
  write_to_log_file_n('Error in create_conc_program_dup '||g_status_message);
  return false;
End;

function create_user_measure_fk_table
return boolean is
l_fstg_measures edw_owb_collection_util.varcharTableType;
l_fstg_data_type edw_owb_collection_util.varcharTableType;
l_fstg_data_len edw_owb_collection_util.varcharTableType;
l_num_fstg_measures number;
----
l_fstg_fk edw_owb_collection_util.varcharTableType;
l_fstg_fk_data_type edw_owb_collection_util.varcharTableType;
l_fstg_fk_data_len edw_owb_collection_util.varcharTableType;
l_num_fstg_fk number;
----
l_size number;
l_index integer;
----
l_std_columns edw_owb_collection_util.varcharTableType;
l_num_std_columns number;
----
Begin
  if g_debug then
    write_to_log_file_n('create_user_measure_fk_table ');
  end if;
  if g_number_fstg_columns is null then
    if get_fstg_col_parameters=false then
      return false;
    end if;
  end if;
  l_num_fstg_measures:=0;
  l_num_fstg_fk:=0;
  l_size:=0;
  for i in 1..g_number_fstg_columns loop
    for j in 1..g_num_ff_map_cols loop
      if g_skip_item(j)=false then
        if instr(g_fstg_mapping_columns(j),g_fstg_columns(i))>0 then
          l_num_fstg_measures:=l_num_fstg_measures+1;
          l_fstg_measures(l_num_fstg_measures):=g_fstg_columns(i);
          l_fstg_data_type(l_num_fstg_measures):=g_data_type(i);
          l_fstg_data_len(l_num_fstg_measures):=g_data_length(i);
          l_size:=l_size+nvl(g_avg_col_length(i),0);
          exit;
        end if;
      end if;
    end loop;
  end loop;
  --add the std columns like operation code
  l_num_std_columns:=1;
  l_std_columns(l_num_std_columns):='OPERATION_CODE';
  for i in 1..l_num_std_columns loop
    if edw_owb_collection_util.value_in_table(l_fstg_measures,l_num_fstg_measures,l_std_columns(i))=false then
      l_index:=edw_owb_collection_util.index_in_table(g_fstg_columns,g_number_fstg_columns,l_std_columns(i));
      if l_index>0 then
        l_num_fstg_measures:=l_num_fstg_measures+1;
        l_fstg_measures(l_num_fstg_measures):=g_fstg_columns(l_index);
        l_fstg_data_type(l_num_fstg_measures):=g_data_type(l_index);
        l_fstg_data_len(l_num_fstg_measures):=g_data_length(l_index);
        l_size:=l_size+nvl(g_avg_col_length(l_index),0);
      end if;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('The fstg measures going to used for fm table creation');
    for i in 1..l_num_fstg_measures loop
      write_to_log_file(l_fstg_measures(i));
    end loop;
  end if;
  if g_collection_size is null or g_number_rows_ready>g_collection_size then
    l_size:=l_size*g_number_rows_ready;
  else
    l_size:=l_size*g_collection_size;
  end if;
  l_size:=round(l_size/1048576)+1048576;
  g_stmt:='create table '||g_user_measure_table||'(';
  for i in 1..l_num_fstg_measures loop
    g_stmt:=g_stmt||l_fstg_measures(i)||' '||l_fstg_data_type(i);
    if instr(l_fstg_data_type(i),'CHAR')>0 then
      g_stmt:=g_stmt||'('||l_fstg_data_len(i)||')';
    end if;
    g_stmt:=g_stmt||',';
  end loop;
  g_stmt:=g_stmt||'row_id rowid ) tablespace '||g_op_table_space||' storage(initial '||l_size||' next '||
  l_size||' pctincrease 0 MAXEXTENTS 2147483645)';
  if g_parallel is not null then
    g_stmt:=g_stmt||' parallel(degree '||g_parallel||')';
  end if;
  if edw_owb_collection_util.drop_table(g_user_measure_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  execute immediate g_stmt;
  if g_debug then
    write_to_log_file_n('Created ');
  end if;
  --create the ff table
  l_size:=0;
  for i in 1..g_numberOfDimTables loop
    if g_fstg_fk_direct_load(i)=false and g_fstg_fk_value_load(i)=false then
      for j in 1..g_number_fstg_columns loop
        if g_fstgUserFKName(i)=g_fstg_columns(j) then
          l_num_fstg_fk:=l_num_fstg_fk+1;
          l_fstg_fk(l_num_fstg_fk):=g_fstg_columns(j);
          l_fstg_fk_data_type(l_num_fstg_fk):=g_data_type(j);
          l_fstg_fk_data_len(l_num_fstg_fk):=g_data_length(j);
          l_size:=l_size+nvl(g_avg_col_length(j),0);
          exit;
        end if;
      end loop;
    end if;
  end loop;
  if g_instance_column is not null then
    if EDW_OWB_COLLECTION_UTIL.value_in_table(l_fstg_fk,l_num_fstg_fk,g_instance_column)=false then
      l_num_fstg_fk:=l_num_fstg_fk+1;
      l_fstg_fk(l_num_fstg_fk):=g_instance_column;
      l_fstg_fk_data_type(l_num_fstg_fk):='VARCHAR2';
      l_fstg_fk_data_len(l_num_fstg_fk):='80';
      l_size:=l_size+nvl(10,0);
    end if;
  end if;
  if g_collection_size is null or g_number_rows_ready>g_collection_size then
    l_size:=l_size*g_number_rows_ready;
  else
    l_size:=l_size*g_collection_size;
  end if;
  l_size:=round(l_size/1048576)+1048576;
  g_stmt:='create table '||g_user_fk_table||'(';
  for i in 1..l_num_fstg_fk loop
    g_stmt:=g_stmt||l_fstg_fk(i)||' '||l_fstg_fk_data_type(i);
    if instr(l_fstg_fk_data_type(i),'CHAR')>0 then
      g_stmt:=g_stmt||'('||l_fstg_fk_data_len(i)||')';
    end if;
    g_stmt:=g_stmt||',';
  end loop;
  g_stmt:=g_stmt||'row_id rowid ) tablespace '||g_op_table_space||' storage(initial '||l_size||' next '||
  l_size||' pctincrease 0 MAXEXTENTS 2147483645)';
  if g_parallel is not null then
    g_stmt:=g_stmt||' parallel(degree '||g_parallel||')';
  end if;
  if edw_owb_collection_util.drop_table(g_user_fk_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  execute immediate g_stmt;
  if g_debug then
    write_to_log_file_n('Created ');
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in create_user_measure_fk_table '||g_status_message);
  return false;
End;

/*
if we are here, it means that g_stg_copy_table_flag is necessarily false.
*/
function insert_fm_ff_table
return boolean is
------
l_fstg_measures edw_owb_collection_util.varcharTableType;
l_num_fstg_measures number;
l_fstg_fk edw_owb_collection_util.varcharTableType;
l_num_fstg_fk number;
------
l_table varchar2(200);
l_stmt varchar2(5000);
------
Begin
  if g_debug then
    write_to_log_file_n('In insert_fm_ff_table '||get_time);
  end if;
  l_table:=g_ok_rowid_table||'A';
  if edw_owb_collection_util.get_db_columns_for_table(g_user_fk_table,l_fstg_fk,l_num_fstg_fk,g_bis_owner)=false then
    return false;
  end if;
  if g_debug then
    write_to_log_file_n('The user fk table columns');
    for i in 1..l_num_fstg_fk loop
      write_to_log_file(l_fstg_fk(i));
    end loop;
  end if;
  if edw_owb_collection_util.get_db_columns_for_table(g_user_measure_table,l_fstg_measures,
    l_num_fstg_measures,g_bis_owner)=false then
    return false;
  end if;
  if g_debug then
    write_to_log_file_n('The user measure table columns');
    for i in 1..l_num_fstg_measures loop
      write_to_log_file(l_fstg_measures(i));
    end loop;
  end if;
  g_stmt:='insert all into '||g_user_measure_table||'(';
  for i in 1..l_num_fstg_measures loop
    g_stmt:=g_stmt||l_fstg_measures(i)||',';
  end loop;
  g_stmt:=substr(g_stmt,1,length(g_stmt)-1)||') values (';
  for i in 1..l_num_fstg_measures loop
    g_stmt:=g_stmt||l_fstg_measures(i)||',';
  end loop;
  g_stmt:=substr(g_stmt,1,length(g_stmt)-1)||') into '||g_user_fk_table||'(';
  for i in 1..l_num_fstg_fk loop
    g_stmt:=g_stmt||l_fstg_fk(i)||',';
  end loop;
  g_stmt:=substr(g_stmt,1,length(g_stmt)-1)||') values (';
  for i in 1..l_num_fstg_fk loop
    g_stmt:=g_stmt||l_fstg_fk(i)||',';
  end loop;
  g_stmt:=substr(g_stmt,1,length(g_stmt)-1)||') select ';
  if g_stg_join_nl then
    g_stmt:=g_stmt||'/*+ORDERED USE_NL('||g_fstgTableName||')*/ ';
  else
    g_stmt:=g_stmt||'/*+ORDERED*/ ';
  end if;
  if g_parallel is not null then
    g_stmt:=g_stmt||' /*+PARALLEL ('||g_fstgTableName||','||g_parallel||')*/ ';
  end if;
  for i in 1..l_num_fstg_measures loop
    if l_fstg_measures(i)<>'ROW_ID' then
      g_stmt:=g_stmt||l_fstg_measures(i)||',';
    end if;
  end loop;
  for i in 1..l_num_fstg_fk loop
    if l_fstg_fk(i)<>'ROW_ID' then
      if edw_owb_collection_util.value_in_table(l_fstg_measures,l_num_fstg_measures,l_fstg_fk(i))=false then
        g_stmt:=g_stmt||l_fstg_fk(i)||',';
      end if;
    end if;
  end loop;
  g_stmt:=g_stmt||l_table||'.row_id from '||l_table||','||g_fstgTableName||
  ' where '||g_fstgTableName||'.rowid='||l_table||'.row_id';
  l_stmt:='create table '||l_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select row_id from '||g_ok_rowid_table||' where status=1';
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_type_ok_generation='CTAS' then
    g_number_rows_ready:=sql%rowcount;
  end if;
  if g_debug then
    write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_table,instr(l_table,'.')+1,
  length(l_table)),substr(l_table,1,instr(l_table,'.')-1));
  if g_debug then
    write_to_log_file_n(g_stmt||get_time);
  end if;
  execute immediate g_stmt;
  if g_debug then
    write_to_log_file_n('Loaded '||sql%rowcount||' rows '||get_time);
  end if;
  --drop the l_table
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table)=false then
    null;
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_user_measure_table,instr(g_user_measure_table,'.')+1,
  length(g_user_measure_table)),substr(g_user_measure_table,1,instr(g_user_measure_table,'.')-1));
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_user_fk_table,instr(g_user_fk_table,'.')+1,
  length(g_user_fk_table)),substr(g_user_fk_table,1,instr(g_user_fk_table,'.')-1));
  commit;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in insert_fm_ff_table '||g_status_message);
  return false;
End;

function get_fstg_col_parameters return boolean is
Begin
  if edw_owb_collection_util.get_db_columns_for_table(
    g_fstgTableName,
    g_fstg_columns,
    g_data_type,
    g_data_length,
    g_num_distinct,
    g_num_nulls,
    g_avg_col_length,
    g_number_fstg_columns,
    g_table_owner)=false then
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_fstg_col_parameters '||g_status_message);
  return false;
End;

/*
this function will launch a dbms job to push the changes to lower levels
this is only called if g_parallel_drill_down is true
*/
function drill_parent_to_children
return boolean is
--
l_ur_pattern varchar2(200);
l_debug varchar2(40);
--
Begin
  if g_debug then
    write_to_log_file_n('In drill_parent_to_children (Main Thread)'||get_time);
  end if;
  if check_dim_drill_down=false then
    g_status:=false;
    return false;
  end if;
  --now I am ready to move
  --the hdur tables will be like TAB_2233_HDUR_1_2; 1 is the job id and 2 is the count
  l_ur_pattern:='TAB_'||g_primary_target||'_HDUR_%';
  l_debug:='N';
  if g_debug then
    l_debug:='Y';
  end if;
  g_ltc_drill_down_job_id:=null;
  --for the lowest level, we dont want to launch a job
  if g_job_queue_processes>0 and g_temp_log=false then --this is not the lowest level
    if g_debug then
      write_to_log_file_n('EDW_MAPPING_COLLECT.drill_parent_to_children('||
    ''''||g_primary_target_name||''','||
    ''||g_primary_target||','||
    ''''||g_dd_status_table||''','||
    ''''||g_ul_table||''','||
    ''''||l_ur_pattern||''','||
    ''''||g_factPKNameKey||''','||
    ''''||l_debug||''','||
    ''''||g_table_owner||''','||
    ''||nvl(g_stg_join_nl_percentage,0)||','||
    ''''||g_op_table_space||''','||
    ''||nvl(g_parallel,0)||','||
    ''''||g_bis_owner||''','||
    ''||nvl(g_sort_area_size,0)||','||
    ''||nvl(g_hash_area_size,0)||','||
    ''||g_load_pk||','||
    ''||nvl(edw_owb_collection_util.g_conc_program_id,0)||','||
    '1);');
    end if;
    DBMS_JOB.SUBMIT(g_ltc_drill_down_job_id,'EDW_MAPPING_COLLECT.drill_parent_to_children('||
    ''''||g_primary_target_name||''','||
    ''||g_primary_target||','||
    ''''||g_dd_status_table||''','||
    ''''||g_ul_table||''','||
    ''''||l_ur_pattern||''','||
    ''''||g_factPKNameKey||''','||
    ''''||l_debug||''','||
    ''''||g_table_owner||''','||
    ''||nvl(g_stg_join_nl_percentage,0)||','||
    ''''||g_op_table_space||''','||
    ''||nvl(g_parallel,0)||','||
    ''''||g_bis_owner||''','||
    ''||nvl(g_sort_area_size,0)||','||
    ''||nvl(g_hash_area_size,0)||','||
    ''||g_load_pk||','||
    ''||nvl(edw_owb_collection_util.g_conc_program_id,0)||','||
    '1);');
  end if;
  if g_ltc_drill_down_job_id is not null and g_ltc_drill_down_job_id>0 then
    if g_debug then
      write_to_log_file_n('Job '||g_ltc_drill_down_job_id||' launched '||get_time);
    end if;
    --update the status table;
    if edw_owb_collection_util.update_status_table(g_dd_status_table,'status','RUNNING','where parent_ltc_id='||
      g_primary_target)=false then
      return false;
    end if;
    if edw_owb_collection_util.update_status_table(g_dd_status_table,'job_id',g_ltc_drill_down_job_id,
      'where parent_ltc_id='||g_primary_target)=false then
      return false;
    end if;
    commit;--job starts in the database
  else
    --manually push the changes down
    if g_debug then
      write_to_log_file_n('Job could not be launched. trying manually');
    end if;
    drill_parent_to_children(g_primary_target_name,g_primary_target,g_dd_status_table,g_ul_table,l_ur_pattern,
    g_factPKNameKey,null,null,null,null,null,null,null,null,null,null,0);
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in drill_parent_to_children '||g_status_message);
  return false;
End;

/*
this procedure is called when a ltc load is complete and its about to launch its own
job to drill the change down.
it needs to see if its parent ltc has finished the drill down
*/
function check_dim_drill_down return boolean is
--
l_status edw_owb_collection_util.varcharTableType;
l_num_status number;
l_names edw_owb_collection_util.varcharTableType;
l_num_names number;
l_parent varchar2(200);
l_parent_id number;
l_job_id number;
l_not_done boolean;
l_pci_table varchar2(100);
l_ul_table varchar2(100);
--
l_job_running boolean;
--
Begin
  if g_debug then
    write_to_log_file_n('In check_dim_drill_down '||get_time);
  end if;
  l_not_done:=false;
  --g_dd_status_table
  --first check the status. if done, we can proceed
  if edw_owb_collection_util.query_table_cols(g_dd_status_table,'status',' where child_ltc_id='||g_primary_target,
    l_status,l_num_status)=false then
    return false;
  end if;
  for i in 1..l_num_status loop
    if substr(l_status(i),1,3)='ERR' then
      g_status_message:=substr(l_status(i),instr(l_status(i),'+')+1);
      return false;
    end if;
  end loop;
  for i in 1..l_num_status loop
    if l_status(i)<>'DONE' then
      l_not_done:=true;
      exit;
    end if;
  end loop;
  --for all level l_not_done will be false since l_num_status=0
  if l_not_done then
    if g_debug then
      write_to_log_file_n('Not all jobs done');
    end if;
    --get all the job ids. see if they are running. then wait. after all are done, check the status. if
    --any one is not done, have to manually do it.
    l_num_status:=0;
    if edw_owb_collection_util.query_table_cols(g_dd_status_table,'parent_ltc||''+''||parent_ltc_id||''+''||job_id',
    ' where child_ltc_id='||g_primary_target||' and status<>''DONE''',l_status,l_num_status)=false then
      return false;
    end if;
    for i in 1..l_num_status loop
      if edw_owb_collection_util.parse_names(l_status(i),'+',l_names,l_num_names)=false then
        return false;
      end if;
      l_parent:=l_names(1);
      l_parent_id:=l_names(2);
      l_job_id:=to_number(l_names(3));
      l_job_running:=false;
      if edw_owb_collection_util.check_job_status(l_job_id)='Y' then
        if edw_owb_collection_util.check_table(g_bis_owner||'.TAB_MARKER_DD_'||l_parent_id) then
          l_job_running:=true;
        end if;
      end if;
      if l_job_running then
        if edw_owb_collection_util.wait_on_jobs(l_job_id,g_sleep_time,'JOB')=false then
          return false;
        end if;
        --then requery the status and see if its an error
        l_num_status:=0;
        if edw_owb_collection_util.query_table_cols(g_dd_status_table,'status',
          ' where child_ltc_id='||g_primary_target||' and parent_ltc_id='||l_parent_id,
          l_status,l_num_status)=false then
          return false;
        end if;
        if substr(l_status(1),1,3)='ERR' then
          g_status_message:=substr(l_status(1),instr(l_status(1),'+')+1);
          return false;
        end if;
      else
        --this is a crashed process
        --terminate it
        if edw_owb_collection_util.terminate_job(l_job_id)=false then
          null;
        end if;
        if g_debug then
          write_to_log_file_n(l_job_id||' has crashed...going to manually push down');
        end if;
        --manually push down from parent to this child
        l_pci_table:=g_bis_owner||'.TAB_'||l_parent_id||'_'||g_primary_target||'_PCI';
        l_ul_table:=g_bis_owner||'.TAB_'||l_parent_id||'_UL';
        if drill_parent_to_child(l_parent,l_parent_id,g_primary_target_name,g_primary_target,
          l_ul_table,l_pci_table)=false then
          return false;
        end if;
      end if;
    end loop;
  end if;
  return true;
Exception when others then
  write_to_log_file_n('Error in check_dim_drill_down '||sqlerrm);
  return false;
End;

/*
procedure ..called as a dbms job. given a parent level, drill down to all children
p_dd_table has the levels in the right order. this is very important. if level collection
order is A -<B,C,D then p_dd_table has
1 A   B
2 A   C
3 A   D
*/
procedure drill_parent_to_children(
p_parent varchar2,
p_parent_id number,
p_dd_table varchar2,
p_ul_table varchar2,
p_ur_pattern varchar2,
p_parent_pk varchar2,
--
p_debug varchar2,
p_table_owner varchar2,
p_stg_join_nl_percentage number,
p_op_table_space varchar2,
p_parallel number,
p_bis_owner varchar2,
p_sort_area_size number,
p_hash_area_size number,
p_load_pk number,
p_conc_program_id number,
p_job number --1 means that this is a job
--
)is
--
l_child_ltc EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_child_ltc_id EDW_OWB_COLLECTION_UTIL.numberTableType;
l_num_child_ltc number;
--
l_parent_ltc EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_parent_ltc_id EDW_OWB_COLLECTION_UTIL.numberTableType;
l_num_parent_ltc number;
l_pci_table EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_parent_pci_table EDW_OWB_COLLECTION_UTIL.varcharTableType;
--
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_exception  EXCEPTION;
--
l_marker_table varchar2(200);
--
Begin
  --
  --just a marker table. useful to see if the job started
  if p_job=1 then --this is a dbms job
    g_op_table_space:=p_op_table_space;
    g_bis_owner:=p_bis_owner;
    l_marker_table:=g_bis_owner||'.TAB_MARKER_DD_'||p_parent_id;
    if edw_owb_collection_util.create_prot_table(l_marker_table,g_op_table_space)=false then
      null;
    end if;
    if p_debug='Y' then
      g_debug:=true;
      edw_owb_collection_util.setup_conc_program_log('DD_'||p_parent);
      edw_owb_collection_util.set_debug(true);
    else
      g_debug:=false;
    end if;
    g_table_owner:=p_table_owner;
    g_stg_join_nl_percentage:=p_stg_join_nl_percentage;
    g_parallel:=p_parallel;
    if g_parallel=0 then
      g_parallel:=null;
    end if;
    g_sort_area_size:=p_sort_area_size;
    if g_sort_area_size>0 then
      edw_owb_collection_util.alter_session('SORT_AREA_SIZE',g_sort_area_size);
    end if;
    g_hash_area_size:=p_hash_area_size;
    if g_hash_area_size>0 then
      edw_owb_collection_util.alter_session('HASH_AREA_SIZE',g_hash_area_size);
    end if;
    g_load_pk:=p_load_pk;
    g_conc_program_id:=p_conc_program_id;
  end if;
  --
  if g_debug then
    write_to_log_file_n('In drill parent to children p_parent='||p_parent||',p_parent_id='||p_parent_id||','||
    'p_dd_table='||p_dd_table||',p_ul_table='||p_ul_table||',p_ur_pattern='||p_ur_pattern||',p_parent_pk='||
    p_parent_pk||get_time);
  end if;
  l_num_child_ltc:=1;
  l_stmt:='select child_ltc,child_ltc_id from '||p_dd_table||' where parent_ltc_id=:1 and '||
  'child_ltc_id is not null order by level_order';
  if g_debug then
    write_to_log_file_n(l_stmt);
  end if;
  open cv for l_stmt using p_parent_id;
  loop
    fetch cv into l_child_ltc(l_num_child_ltc),l_child_ltc_id(l_num_child_ltc);
    exit when cv%notfound;
    l_pci_table(l_num_child_ltc):=g_bis_owner||'.TAB_'||p_parent_id||'_'||l_child_ltc_id(l_num_child_ltc)||'_PCI';
    l_num_child_ltc:=l_num_child_ltc+1;
  end loop;
  l_num_child_ltc:=l_num_child_ltc-1;
  close cv;
  if g_debug then
    for i in 1..l_num_child_ltc loop
      write_to_log_file(l_child_ltc(i)||' '||l_child_ltc_id(i)||' '||l_pci_table(i));
    end loop;
  end if;
  --
  l_num_parent_ltc:=1;
  l_stmt:='select parent_ltc,parent_ltc_id from '||p_dd_table||' where child_ltc_id=:1 order by level_order';
  if g_debug then
    write_to_log_file_n(l_stmt);
  end if;
  open cv for l_stmt using p_parent_id; --p_parent_id is me.
  loop
    fetch cv into l_parent_ltc(l_num_parent_ltc),l_parent_ltc_id(l_num_parent_ltc);
    exit when cv%notfound;
    l_parent_pci_table(l_num_parent_ltc):=g_bis_owner||'.TAB_'||l_parent_ltc_id(l_num_parent_ltc)||'_'||p_parent_id||'_PCI';
    l_num_parent_ltc:=l_num_parent_ltc+1;
  end loop;
  l_num_parent_ltc:=l_num_parent_ltc-1;
  close cv;
  if g_debug then
    for i in 1..l_num_parent_ltc loop
      write_to_log_file(l_parent_ltc(i)||' '||l_parent_ltc_id(i)||' '||l_parent_pci_table(i));
    end loop;
  end if;
  --
  --merge_all_update_rowids happens for all ltc including the lowest ltc(for merging pci tables)
  if merge_all_update_rowids(p_parent_id,p_ul_table,p_ur_pattern,l_parent_pci_table,l_num_parent_ltc)=false then
    raise l_exception;
  end if;
  if l_num_child_ltc>0 then    --dont do this for the lowest level
    --if there is an error, all children of this parent are marked as error.
    for i in 1..l_num_child_ltc loop
      if drill_parent_to_child(p_parent,p_parent_id,l_child_ltc(i),l_child_ltc_id(i),p_ul_table,
        l_pci_table(i))=false then
        raise l_exception;
      else
        --we want to update the status to success so that this child can proceed with its own dril down
        if edw_owb_collection_util.update_status_table(p_dd_table,'status','DONE','where parent_ltc_id='||
          p_parent_id||' and child_ltc_id='||l_child_ltc_id(i))=false then
          null;
        end if;
        commit;
      end if;
    end loop;
  else
    if g_debug then
      write_to_log_file_n('Lowest level...No children for this level...Merge the snplog data with PCI data');
    end if;
    if merge_pci_snplog(p_parent,p_parent_id,g_table_owner,p_parent_pk,p_ul_table)=false then
      raise l_exception;
    end if;
    if edw_owb_collection_util.update_status_table(p_dd_table,'status','DONE','where parent_ltc_id='||
      p_parent_id)=false then
      null;
    end if;
    commit;
  end if;
  if edw_owb_collection_util.drop_table(l_marker_table)=false then
    null;
  end if;
  --dbms job is done
Exception
  when l_exception then
    --put into status table
    write_to_log_file_n(g_status_message);
    if edw_owb_collection_util.update_status_table(p_dd_table,'status','ERROR+++'||g_status_message,
      'where parent_ltc_id='||p_parent_id)=false then
      null;
    end if;
    commit;
    if edw_owb_collection_util.drop_table(l_marker_table)=false then
      null;
    end if;
    raise;
  when others then
    --put into status table
    write_to_log_file_n('Error in drill_parent_to_children '||sqlerrm);
    if edw_owb_collection_util.update_status_table(p_dd_table,'status','ERROR+++'||sqlerrm,'where parent_ltc_id='||
      p_parent_id)=false then
      null;
    end if;
    commit;
    if edw_owb_collection_util.drop_table(l_marker_table)=false then
      null;
    end if;
    raise;
  --end of dbms job
End;

/*
given a parent level and child level, drill down the changes from parent to child
*/
function drill_parent_to_child(
p_parent varchar2,
p_parent_id number,
p_child varchar2,
p_child_id number,
p_ul_table varchar2,
p_pci_table varchar2 --parent child impact table
)return boolean is
--
--given a parent, find the children
--p_parent_id and child id are the ltc id
cursor c1(p_parent_id number,p_child_id number) is
select distinct
pk_col.column_name,
fk_col.column_name
from
edw_level_relations_md_v lvl_rel,
edw_pvt_key_columns_md_v pk_key,
edw_pvt_columns_md_v pk_col,
edw_pvt_key_columns_md_v fk_key,
edw_pvt_columns_md_v fk_col
where
lvl_rel.PARENT_LVLTBL_ID=p_parent_id
and lvl_rel.CHILD_LVLTBL_ID=p_child_id
and pk_key.key_id=lvl_rel.uk_id
and pk_col.column_id=pk_key.column_id
and fk_key.key_id=lvl_rel.fk_id
and fk_col.column_id=fk_key.column_id;
--
l_pk_col EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_fk_col EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_num_keys number;
--
l_parent_count number;
l_ul_count number;
l_use_nl boolean;
--
l_stmt varchar2(10000);
--
Begin
  if g_debug then
    write_to_log_file_n('In drill_parent_to_child '||p_parent_id||' '||p_child_id||' '||get_time);
  end if;
  if edw_owb_collection_util.drop_table(p_pci_table)=false then
    null;
  end if;
  if edw_owb_collection_util.check_table(p_ul_table)=false then --if the parent ul table does not exist
    if g_debug then
      write_to_log_file_n('Parent UL table '||p_ul_table||' does not exist. Returning...');
    end if;
    return true;
  end if;
  if g_debug then
    write_to_log_file_n('cursor c1(p_parent_id number,p_child_id number) is '||
    'select distinct '||
    'pk_col.column_name, '||
    'fk_col.column_name '||
    'from '||
    'edw_level_relations_md_v lvl_rel, '||
    'edw_pvt_key_columns_md_v pk_key, '||
    'edw_pvt_columns_md_v pk_col, '||
    'edw_pvt_key_columns_md_v fk_key, '||
    'edw_pvt_columns_md_v fk_col '||
    'where  '||
    'lvl_rel.PARENT_LVLTBL_ID=p_parent_id '||
    'and lvl_rel.CHILD_LVLTBL_ID=p_child_id '||
    'and pk_key.key_id=lvl_rel.uk_id '||
    'and pk_col.column_id=pk_key.column_id '||
    'and fk_key.key_id=lvl_rel.fk_id '||
    'and fk_col.column_id=fk_key.column_id; ');
  end if;
  l_num_keys:=1;
  open c1(p_parent_id,p_child_id);
  loop
    fetch c1 into l_pk_col(l_num_keys),l_fk_col(l_num_keys);
    exit when c1%notfound;
    l_num_keys:=l_num_keys+1;
  end loop;
  l_num_keys:=l_num_keys-1;
  close c1;
  if g_debug then
    write_to_log_file_n('Result');
    for i in 1..l_num_keys loop
      write_to_log_file(l_pk_col(i)||' '||l_fk_col(i));
    end loop;
  end if;
  l_ul_count:=edw_owb_collection_util.get_table_count_stats(p_ul_table,null);
  l_parent_count:=edw_owb_collection_util.get_table_count_stats(p_parent,g_table_owner);
  l_use_nl:=EDW_OWB_COLLECTION_UTIL.get_join_nl(l_ul_count,l_parent_count,g_stg_join_nl_percentage);
  l_stmt:='create table '||p_pci_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select ';
  if l_use_nl then
    l_stmt:=l_stmt||' /*+ordered use_nl(p_ltc) ';
  end if;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel(p_ltc,'||g_parallel||') (ltc,'||g_parallel||')';
  end if;
  if l_use_nl or g_parallel is not null then
    l_stmt:=l_stmt||'*/ ';
  end if;
  l_stmt:=l_stmt||' ltc.rowid row_id from '||p_ul_table||' ul,'||p_parent||' p_ltc,'||p_child||' ltc '||
  'where ul.row_id=p_ltc.rowid and ';
  for i in 1..l_num_keys loop
    l_stmt:=l_stmt||'p_ltc.'||l_pk_col(i)||'=ltc.'||l_fk_col(i)||' and ';
  end loop;
  l_stmt:=substr(l_stmt,1,length(l_stmt)-4);
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in drill_parent_to_child '||g_status_message);
  return false;
End;

/*
for a ltc, find out all update rowid tables and merge into UL table.
UL=update L
if UL table does not exist, create one.
we dont care for checking to see if ul table exists because in case of error
recovery, we go the old route of snplog
*/
function merge_all_update_rowids(
p_ltc_id number,
p_ul_table varchar2,
p_ur_pattern varchar2,
p_pci_tables EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_num_pci_tables number
)return boolean is
--
l_table EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_num_table number;
l_pci_table EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_num_pci_table number;
--
l_stmt varchar2(20000);
--
Begin
  if g_debug then
    write_to_log_file_n('In merge_all_update_rowids '||get_time);
  end if;
  l_num_table:=0;
  --p_ul_table needs to be dropped in init_all
  --if edw_owb_collection_util.drop_table(p_ul_table)=false then
    --null;
  --end if;
  --
  if edw_owb_collection_util.get_tables_matching_pattern(p_ur_pattern,g_bis_owner,l_table,l_num_table)=false then
    return false;
  end if;
  for i in 1..l_num_table loop
    l_table(i):=g_bis_owner||'.'||l_table(i);
  end loop;
  l_num_pci_table:=0;
  for i in 1..p_num_pci_tables loop
    if edw_owb_collection_util.check_table(p_pci_tables(i)) then
      l_num_pci_table:=l_num_pci_table+1;
      l_pci_table(l_num_pci_table):=p_pci_tables(i);
    end if;
  end loop;
  --
  if l_num_table>0 or l_num_pci_table>0 then
    l_stmt:='create table '||p_ul_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||' as ';
    if l_num_table>0 then
      l_stmt:=l_stmt||' (';
      for i in 1..l_num_table loop
        l_stmt:=l_stmt||' select row_id from '||l_table(i)||' union all';
      end loop;
      l_stmt:=substr(l_stmt,1,length(l_stmt)-9);
      l_stmt:=l_stmt||') union';
    end if;
    for i in 1..l_num_pci_table loop
      l_stmt:=l_stmt||' select row_id from '||l_pci_table(i)||' union';
    end loop;
    l_stmt:=substr(l_stmt,1,length(l_stmt)-5);
    if g_debug then
      write_to_log_file_n(l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('created with '||sql%rowcount||' rows '||get_time);
    end if;
    ------
    for i in 1..l_num_table loop
      if edw_owb_collection_util.drop_table(l_table(i))=false then
        null;
      end if;
    end loop;
    for i in 1..l_num_pci_table loop
      if edw_owb_collection_util.drop_table(l_pci_table(i))=false then
        null;
      end if;
    end loop;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(p_ul_table,instr(p_ul_table,'.')+1,
    length(p_ul_table)),substr(p_ul_table,1,instr(p_ul_table,'.')-1));
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in merge_all_update_rowids '||g_status_message);
  return false;
End;

function merge_pci_snplog(
p_ltc varchar2,
p_ltc_id number,
p_table_owner varchar2,
p_ltc_pk varchar2,
p_ul_table varchar2
)return boolean is
--
cursor c1(p_ltc varchar2,p_table_owner varchar2) is
select LOG_TABLE from all_snapshot_logs where master=p_ltc and LOG_OWNER=p_table_owner;
cursor c2(p_ltc varchar2) is
select dim_id,LEVEL_PREFIX from edw_levels_md_v where LEVEL_TABLE_NAME=p_ltc;
--
l_snplog varchar2(100);
l_table varchar2(100);
l_ll_snplog_has_pk boolean:=false;
l_snplogs_L varchar2(100);
l_dim_id number;
l_prefix varchar2(100);
l_ul_found boolean;
--
l_stmt varchar2(4000);
--
Begin
  if g_debug then
    write_to_log_file_n('In merge_pci_snplog'||get_time);
  end if;
  if g_debug then
    write_to_log_file_n('select dim_id,LEVEL_PREFIX from edw_levels_md_v where LEVEL_TABLE_NAME='||p_ltc);
  end if;
  open c2(p_ltc);
  fetch c2 into l_dim_id,l_prefix;
  close c2;
  l_snplogs_L:=g_bis_owner||'.TAB_'||l_dim_id||'_'||l_prefix||'_L';
  if g_debug then
    write_to_log_file_n('l_snplogs_L='||l_snplogs_L);
  end if;
  if edw_owb_collection_util.drop_table(l_snplogs_L)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('select LOG_TABLE from all_snapshot_logs where master='||p_ltc||
    ' and LOG_OWNER='||p_table_owner);
  end if;
  open c1(p_ltc,p_table_owner);
  fetch c1 into l_snplog;
  close c1;
  if g_debug then
    write_to_log_file(l_snplog);
  end if;
  if edw_owb_collection_util.check_table(p_ul_table) then
    l_ul_found:=true;
  else
    l_ul_found:=false;
  end if;
  if l_snplog is not null then
    if EDW_OWB_COLLECTION_UTIL.is_column_in_table(l_snplog,p_ltc_pk,p_table_owner) then
      l_ll_snplog_has_pk:=true;
    end if;
    if l_ul_found then
      l_table:=g_bis_owner||'.TAB_'||p_ltc_id||'_SNPLOG';
      if edw_owb_collection_util.drop_table(l_table)=false then
        null;
      end if;
    else
      --if ul table is not there, we can directly create the L table
      l_table:=l_snplogs_L;
      --already dropped
    end if;
    l_stmt:='create table '||l_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||' as select ';
    if g_parallel is not null then
      l_stmt:=l_stmt||' /*+parallel (snplog,'||g_parallel||')*/ ';
    end if;
    l_stmt:=l_stmt||' distinct CHARTOROWID(snplog.m_row$$) row_id';
    if l_ll_snplog_has_pk then
      l_stmt:=l_stmt||',snplog.'||p_ltc_pk;
    end if;
    l_stmt:=l_stmt||' from '||p_table_owner||'.'||l_snplog||' snplog';
    if g_debug then
      write_to_log_file_n(l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('created with '||sql%rowcount||' rows '||get_time);
    end if;
    if l_ul_found then
      l_stmt:='create table '||l_snplogs_L||' tablespace '||g_op_table_space;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||' as select ';
      if g_parallel is not null then
        if l_ll_snplog_has_pk then
          l_stmt:=l_stmt||' /*+parallel (ltc,'||g_parallel||')*/ ';
        end if;
      end if;
      l_stmt:=l_stmt||'pci.row_id';
      if l_ll_snplog_has_pk then
        l_stmt:=l_stmt||',ltc.'||p_ltc_pk;
      end if;
      l_stmt:=l_stmt||' from '||p_ul_table||' pci';
      if l_ll_snplog_has_pk then
        l_stmt:=l_stmt||','||p_ltc||' ltc where ltc.rowid=pci.row_id';
      end if;
      --we dont need to validate the rowids in snplog since this patch is only used if
      --there is no error recovery
      l_stmt:=l_stmt||' union select row_id row_id';
      if l_ll_snplog_has_pk then
        l_stmt:=l_stmt||','||p_ltc_pk;
      end if;
      l_stmt:=l_stmt||' from '||l_table;
      if g_debug then
        write_to_log_file_n(l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('created with '||sql%rowcount||' rows '||get_time);
      end if;
      if edw_owb_collection_util.drop_table(l_table)=false then
        null;
      end if;
    end if;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in merge_pci_snplog '||g_status_message);
  return false;
End;

END EDW_MAPPING_COLLECT;

/
