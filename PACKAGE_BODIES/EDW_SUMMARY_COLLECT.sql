--------------------------------------------------------
--  DDL for Package Body EDW_SUMMARY_COLLECT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EDW_SUMMARY_COLLECT" AS
/*$Header: EDWSCOLB.pls 120.0 2005/05/31 18:10:44 appldev noship $*/

--MAIN ACCESS POINT
procedure collect_dimension_main(
    p_conc_id number,
    p_conc_name varchar2,
    p_dim_name varchar2,
    p_levels EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_child_level_number EDW_OWB_COLLECTION_UTIL.numberTableType,
    p_child_levels EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_child_fk EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_parent_pk EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_level_snapshot_logs EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_levels number,
    p_debug boolean,
    p_exec_flag boolean,
    p_bis_owner varchar2,
    p_parallel number,
    p_collection_size number,
    p_table_owner varchar2,
    p_forall_size number,
    p_update_type varchar2,
    p_level_order EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_skip_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_skip_cols number,
    p_load_pk number,
    p_fresh_restart boolean,
    p_op_table_space varchar2,
    p_rollback varchar2,
    p_ltc_merge_use_nl boolean,
    p_dim_inc_refresh_derv boolean,
    p_check_fk_change boolean,
    p_ok_switch_update number,
    p_join_nl_percentage number,
    p_thread_type varchar2,
    p_max_threads number,
    p_min_job_load_size number,
    p_sleep_time number,
    p_job_status_table varchar2,
    p_hash_area_size number,
    p_sort_area_size number,
    p_trace boolean,
    p_read_cfig_options boolean,
    p_max_fk_density number,
    p_analyze_frequency number,
    p_parallel_drill_down boolean,
    p_dd_status_table varchar2
    ) is
Begin
  if p_max_threads>1 then
    --multi threaded
    collect_dimension_multi_thread(
    p_conc_id,
    p_conc_name,
    p_dim_name,
    p_levels,
    p_child_level_number,
    p_child_levels,
    p_child_fk,
    p_parent_pk,
    p_level_snapshot_logs,
    p_number_levels,
    p_debug,
    p_exec_flag,
    p_bis_owner,
    p_parallel,
    p_collection_size,
    p_table_owner,
    p_forall_size,
    p_update_type,
    p_level_order,
    p_skip_cols,
    p_number_skip_cols,
    p_load_pk,
    p_fresh_restart,
    p_op_table_space,
    p_rollback,
    p_ltc_merge_use_nl,
    p_dim_inc_refresh_derv,
    p_check_fk_change,
    p_ok_switch_update,
    p_join_nl_percentage,
    p_thread_type,
    p_max_threads,
    p_min_job_load_size,
    p_sleep_time,
    p_job_status_table,
    p_hash_area_size,
    p_sort_area_size,
    p_trace,
    p_read_cfig_options,
    p_max_fk_density,
    p_analyze_frequency,
    p_parallel_drill_down,
    p_dd_status_table
    );
  else
    --single threaded
    collect_dimension(
    p_conc_id,
    p_conc_name,
    p_dim_name,
    p_levels,
    p_child_level_number,
    p_child_levels,
    p_child_fk,
    p_parent_pk,
    p_level_snapshot_logs,
    p_number_levels,
    p_debug,
    p_exec_flag,
    p_bis_owner,
    p_parallel,
    p_collection_size,
    p_table_owner,
    p_forall_size,
    p_update_type,
    p_level_order,
    p_skip_cols,
    p_number_skip_cols,
    p_load_pk,
    p_fresh_restart,
    p_op_table_space,
    p_rollback,
    p_ltc_merge_use_nl,
    p_dim_inc_refresh_derv,
    p_check_fk_change,
    p_ok_switch_update,
    p_join_nl_percentage,
    p_read_cfig_options,
    p_max_fk_density,
    p_analyze_frequency
    );
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
End;

procedure collect_dimension_multi_thread(
    p_conc_id number,
    p_conc_name varchar2,
    p_dim_name varchar2,
    p_levels EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_child_level_number EDW_OWB_COLLECTION_UTIL.numberTableType,
    p_child_levels EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_child_fk EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_parent_pk EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_level_snapshot_logs EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_levels number,
    p_debug boolean,
    p_exec_flag boolean,
    p_bis_owner varchar2,
    p_parallel number,
    p_collection_size number,
    p_table_owner varchar2,
    p_forall_size number,
    p_update_type varchar2,
    p_level_order EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_skip_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_skip_cols number,
    p_load_pk number,
    p_fresh_restart boolean,
    p_op_table_space varchar2,
    p_rollback varchar2,
    p_ltc_merge_use_nl boolean,
    p_dim_inc_refresh_derv boolean,
    p_check_fk_change boolean,
    p_ok_switch_update number,
    p_join_nl_percentage number,
    p_thread_type varchar2,
    p_max_threads number,
    p_min_job_load_size number,
    p_sleep_time number,
    p_job_status_table varchar2,
    p_hash_area_size number,
    p_sort_area_size number,
    p_trace boolean,
    p_read_cfig_options boolean,
    p_max_fk_density number,
    p_analyze_frequency number,
    p_parallel_drill_down boolean,
    p_dd_status_table varchar2
    ) is
l_input_table varchar2(200);
l_ilog_table varchar2(100);
l_ok_low_end EDW_OWB_COLLECTION_UTIL.numberTableType;
l_ok_high_end EDW_OWB_COLLECTION_UTIL.numberTableType;
l_ok_end_count integer;
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
  g_dim_name:=p_dim_name;
  g_jobid_stmt:=null;
  g_job_id:=null;
  g_conc_id :=p_conc_id;
  g_conc_name:=p_conc_name;
  g_object_type:='DIMENSION';
  g_levels:=p_levels;
  g_child_level_number:=p_child_level_number;
  g_child_levels:=p_child_levels;
  g_child_fk:=p_child_fk;
  g_parent_pk:=p_parent_pk;
  g_level_snapshot_logs:=p_level_snapshot_logs;
  g_number_levels:=p_number_levels;
  g_exec_flag:=p_exec_flag;
  g_debug:=p_debug;
  g_bis_owner:=p_bis_owner;
  g_parallel:=p_parallel;
  g_collection_size:=p_collection_size;
  g_table_owner :=p_table_owner;
  g_forall_size:=p_forall_size;
  g_update_type :=p_update_type;
  g_level_order:=p_level_order;
  g_skip_cols:=p_skip_cols;
  g_number_skip_cols:=p_number_skip_cols;
  g_load_pk:=p_load_pk;
  g_fresh_restart:=p_fresh_restart;
  g_op_table_space:=p_op_table_space;
  g_rollback:=p_rollback;
  g_ltc_merge_use_nl:=p_ltc_merge_use_nl;
  g_dim_inc_refresh_derv:=p_dim_inc_refresh_derv;
  g_check_fk_change:=p_check_fk_change;
  g_ok_switch_update:=p_ok_switch_update;
  g_join_nl_percentage:=p_join_nl_percentage;
  g_read_cfig_options:=p_read_cfig_options;
  g_max_threads:=p_max_threads;
  g_min_job_load_size:=p_min_job_load_size;
  g_sleep_time:=p_sleep_time;
  g_job_status_table:=p_job_status_table;
  g_hash_area_size:=p_hash_area_size;
  g_sort_area_size:=p_sort_area_size;
  g_trace:=p_trace;
  g_max_fk_density:=p_max_fk_density;
  g_analyze_freq:=p_analyze_frequency;
  g_thread_type:=p_thread_type;
  g_parallel_drill_down:=p_parallel_drill_down;
  g_dd_status_table:=p_dd_status_table;
  if g_debug then
    write_to_log_file_n('In collect_dimension_multi_thread for '||p_dim_name||get_time);
    if g_parallel_drill_down then
      write_to_log_file('Parallel drill down true table='||g_dd_status_table);
    else
      write_to_log_file('Parallel drill down false');
    end if;
  end if;
  g_dim_id:=EDW_OWB_COLLECTION_UTIL.get_object_id(g_dim_name);
  if g_debug then
    write_to_log_file_n('g_dim_id='||g_dim_id);
  end if;
  if g_dim_id=-1 then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    g_status:=false;
    return;
  end if;
  l_input_table:=p_bis_owner||'.INP_TAB_'||g_dim_id;
  g_jobid_stmt:=null;
  g_job_id:=null;
  g_status:=true;
  g_job_status_table:=p_job_status_table;
  g_all_done:=false;
  if EDW_OWB_COLLECTION_UTIL.create_dim_load_input_table(
    p_dim_name,
    l_input_table,
    p_conc_id,
    p_conc_name,
    p_levels,
    p_child_level_number,
    p_child_levels,
    p_child_fk,
    p_parent_pk,
    p_level_snapshot_logs,
    p_number_levels,
    p_debug,
    p_exec_flag,
    p_bis_owner,
    p_parallel,
    p_collection_size,
    p_table_owner,
    p_forall_size,
    p_update_type,
    p_level_order,
    p_skip_cols,
    p_number_skip_cols,
    p_load_pk,
    p_fresh_restart,
    p_op_table_space,
    p_rollback,
    p_ltc_merge_use_nl,
    p_dim_inc_refresh_derv,
    p_check_fk_change,
    p_ok_switch_update,
    p_join_nl_percentage,
    p_max_threads,
    p_min_job_load_size,
    p_sleep_time,
    p_job_status_table,
    p_hash_area_size,
    p_sort_area_size,
    p_trace,
    p_read_cfig_options,
    p_max_fk_density
    )=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.get_status_message;
    g_status:=false;
  end if;
  if g_status then
    if initial_set_up(
      l_input_table,
      p_max_threads,
      p_debug,
      l_ilog_table)=false then
      g_status:=false;
    end if;
    if g_all_done then
      return;
    end if;
    if g_status then
      if g_dim_direct_load then
        insert_into_star;
      else
        if EDW_OWB_COLLECTION_UTIL.update_dim_load_input_table(
          l_input_table,
          l_ilog_table,
          g_skip_ilog_update,
          g_level_change,--to recreate from stmt etc
          g_dim_empty_flag,
          g_before_update_table_final,
          g_error_rec_flag,
          g_consider_snapshot,
          g_levels_I,
          g_use_ltc_ilog,
          g_number_levels
          )=false then
          g_status_message:=EDW_OWB_COLLECTION_UTIL.get_status_message;
          g_status:=false;
        end if;
        if g_status then
          --BRING IN THE CALL TO COLLECT
          --if l_ilog_table is null, there are no records to load
          if l_ilog_table is not null then
            if EDW_OWB_COLLECTION_UTIL.find_ok_distribution(
              l_ilog_table,
              g_bis_owner,
              p_max_threads,
              p_min_job_load_size,
              l_ok_low_end,
              l_ok_high_end,
              l_ok_end_count)=false then
              g_status_message:=EDW_OWB_COLLECTION_UTIL.get_status_message;
              g_status:=false;
            end if;
            --l_ok_end_count decides the number of threads
            if g_status then
              /*
               we will go for active polling. this main session will sleep for g_sleep_time and then
               wake up and check the status of each of the jobs. If they are done, we can then proceed.
               DBMS_JOB.SUBMIT(id,'test_pack_2.run_pack;')
              */
              l_number_jobs:=0;
              l_temp_conc_name:='Sub-Proc Dim-'||g_dim_id;
              l_temp_conc_short_name:='CONC_DIM_'||g_dim_id||'_CONC';
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
                if g_debug then
                  write_to_log_file_n('EDW_SUMMARY_COLLECT.COLLECT_DIMENSION('''||p_dim_name||''','||
                  ''''||l_input_table||''','||l_number_jobs||','||l_ok_low_end(j)||','||
                  l_ok_high_end(j)||');');
                end if;
                begin
                  l_try_serial:=false;
                  if g_thread_type='CONC' then
                    l_job_id(l_number_jobs):=FND_REQUEST.SUBMIT_REQUEST(
                    application=>l_bis_short_name,
                    program=>l_temp_conc_short_name,
                    argument1=>p_dim_name,
                    argument2=>l_input_table,
                    argument3=>l_number_jobs,
                    argument4=>l_ok_low_end(j),
                    argument5=>l_ok_high_end(j));
                    commit;
                    if g_debug then
                      write_to_log_file_n('Concurrent Request '||l_job_id(l_number_jobs)||' launched '||get_time);
                    end if;
                    if l_job_id(l_number_jobs)<=0 then
                      l_try_serial:=true;
                    end if;
                  else
                    DBMS_JOB.SUBMIT(l_job_id(l_number_jobs),'EDW_SUMMARY_COLLECT.COLLECT_DIMENSION('''||p_dim_name||''','||
                    ''''||l_input_table||''','||l_number_jobs||','||l_ok_low_end(j)||','||
                    l_ok_high_end(j)||');');
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
                    write_to_log_file_n('Error launching parallel slaves '||sqlerrm);
                  end if;
                  l_try_serial:=true;
                end;
                if l_try_serial then
                  if g_debug then
                    write_to_log_file_n('Attempt serial load');
                  end if;
                  l_job_id(l_number_jobs):=0-l_number_jobs;
                  EDW_SUMMARY_COLLECT.COLLECT_DIMENSION(
                  l_errbuf,
                  l_retcode,
                  p_dim_name,
                  l_input_table,
                  l_number_jobs,
                  l_ok_low_end(j),
                  l_ok_high_end(j)
                  );
                end if;
              end loop;
              if EDW_OWB_COLLECTION_UTIL.wait_on_jobs(
                l_job_id,
                l_number_jobs,
                p_sleep_time,
                g_thread_type)=false then
                g_status_message:=EDW_OWB_COLLECTION_UTIL.get_status_message;
                g_status:=false;
                g_status:=false;
              end if;
              if g_status then
                if EDW_OWB_COLLECTION_UTIL.check_all_child_jobs(
                  p_job_status_table,
                  l_job_id,
                  l_number_jobs,
                  p_dim_name)=false then
                  g_status:=false;
                  return;
                end if;
              end if;
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
            end if;
          end if;
        end if;
      end if;
    end if;
  end if;
  if g_status then
    if drop_input_tables(l_input_table)=false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_ilog_table)=false then
      null;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(p_job_status_table)=false then
      null;
    end if;
    if drop_prot_table(g_insert_prot_table,g_insert_prot_table_active)=false then
      null;
    end if;
    if drop_prot_table(g_bu_insert_prot_table,g_bu_insert_prot_table_active)=false then
      null;
    end if;
    analyze_star_table;
    clean_up;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
End;--procedure collect_dimension IS

function initial_set_up(
p_table_name varchar2,
p_max_threads number,
p_debug boolean,
p_ok_table out nocopy varchar2) return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In initial_set_up p_max_threads='||p_max_threads||' '||get_time);
  end if;
  /*
  the following must be updated into the inp table
  g_skip_ilog_update
  g_level_change  --to recreate from stmt etc
  g_dim_empty_flag
  g_before_update_table_final
  */
  g_max_threads:=p_max_threads;
  g_debug:=p_debug;
  if EDW_OWB_COLLECTION_UTIL.create_job_status_table(g_job_status_table,g_op_table_space)=false then
    return false;
  end if;
  init_all(g_job_id);
  /*
  see if the star is empty. if it is then load the rowid of the lowest level into the ilog
  */
  check_dim_star_empty; --reqd
  if check_error = false then
    return false;
  end if;
  if g_fresh_restart or g_dim_empty_flag then
    if drop_restart_tables=false then
      return false;
    end if;
  else
    if EDW_OWB_COLLECTION_UTIL.merge_all_ilog_tables(g_ilog,g_ilog,g_ilog||'A','IL',g_op_table_space,g_bis_owner,
      g_parallel)=false then
      return false;
    end if;
  end if;
  if get_dim_storage=false then
    g_dim_next_extent:=16000000;--16M default
  end if;
  if g_debug then
    write_to_log_file_n('Next extent ='||g_dim_next_extent);
  end if;
  insert_into_load_progress_d(g_load_pk,g_dim_name,'Read Metadata'||g_jobid_stmt,sysdate,null,'DIMENSION',
  'METADAT','RM'||g_job_id,'I');
  if get_snapshot_log = false then
    insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'RM'||g_job_id,'U');
    return false;
  end if;
  if g_dim_empty_flag = false then
    if check_snapshot_logs = false then
      if EDW_OWB_COLLECTION_UTIL.drop_table(g_ilog)=false then
        null;
      end if;
      insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'RM'||g_job_id,'U');
      write_to_log_file_n('No incremental data to be considered for any level ');
      g_all_done:=true;
      return true;
    end if;
    if g_status=false then
      return false;
    end if;
  end if;
  make_level_alias;
  if check_error = false then
    return false;
  end if;
  /*
   get the mapping details for the star
  */
  get_lvl_relations;
  if check_error = false then
    return false;
  end if;
  /*
  get the dim star table pks
  */
  get_dim_map_ids;
  if g_status=false then
    return false;
  end if;
  if recover_from_previous_error= false then
    return false;
  end if;
  --get the fks in the map
  if EDW_OWB_COLLECTION_UTIL.get_fks_in_dim(g_dim_name,g_src_fk_table,g_src_fk,g_number_src_fk_table)=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    g_status:=false;
    return false;
  end if;
  if g_debug then
    write_to_log_file_n('The FK used in the dim');
    for i in 1..g_number_src_fk_table loop
      write_to_log_file(g_src_fk_table(i)||'('||g_src_fk(i)||')');
    end loop;
  end if;
  --make the select, from and where clause
  make_select_from_where_stmt;
  if check_error = false then
    return false;
  end if;
  make_select_from_where_ins;
  if check_error = false then
    return false;
  end if;
  if name_op_tables(g_job_id)=false then
    return false;
  end if;
  if drop_I_tables=false then
    null;
  end if;
  insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'RM'||g_job_id,'U');
  --identify the slow changing cols
  identify_slow_cols;
  if check_error = false then
    return false;
  end if;
  if g_dim_inc_refresh_derv then
    if is_dim_in_derv_map= false then
      return false;
    end if;
  end if;
  if check_ll_snplog_col=-1 then --required
    return false;
  end if;
  if g_dim_empty_flag then
    if initial_insert_into_star(true)=false then
      return false;
    end if;
  else
    insert_into_load_progress_d(g_load_pk,g_dim_name,'Load ILOG'||g_jobid_stmt,sysdate,null,'DIMENSION',
    'INSERT','IL2010'||g_job_id,'I');
    insert_into_ilog(true);--multi threading true
    insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'IL2010'||g_job_id,'U');
    if g_status=false then
      return false;
    end if;
  end if;
  insert_into_load_progress_d(g_load_pk,g_dim_name,'Create Protection Table'||g_jobid_stmt,sysdate,null,'DIMENSION',
  'INSERT','CPTBL'||g_job_id,'I');
  if g_dim_inc_refresh_derv then
    if create_prot_table(g_bu_insert_prot_table,g_bu_insert_prot_table_active)=false then
      g_status:=false;
      return false;
    end if;
    if get_before_update_table_name=false then
      g_status:=false;
      return false;
    end if;
  end if;
  insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'CPTBL'||g_job_id,'U');
  if edw_owb_collection_util.is_column_in_table(g_ilog,'row_num',g_bis_owner)=false then
    if put_rownum_in_ok_table=false then
      g_status:=false;
      return false;
    end if;
  end if;
  p_ok_table:=g_ilog;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in initial_set_up '||g_status_message);
  return false;
End;

/*
main entry point for each of the child concurrent request
*/
procedure COLLECT_DIMENSION(
errbuf out nocopy varchar2,
retcode out nocopy varchar2,
p_dim_name varchar2,
p_table_name varchar2,--input table
p_job_id number,
p_ok_low_end number,
p_ok_high_end number
) is
Begin
  retcode:='0';
  COLLECT_DIMENSION(
  p_dim_name,
  p_table_name,
  p_job_id,
  p_ok_low_end,
  p_ok_high_end
  );
  if g_status=false then
    retcode:='2';
    errbuf:=g_status_message;
  end if;
Exception when others then
  errbuf:=sqlerrm;
  retcode:='2';
  write_to_log_file_n('Exception in COLLECT_DIMENSION '||sqlerrm||get_time);
End;

/*
main entry point for each of the child jobs
*/
procedure COLLECT_DIMENSION(
p_dim_name varchar2,
p_table_name varchar2,--input table
p_job_id number,
p_ok_low_end number,
p_ok_high_end number
) is
Begin
  g_job_id:=p_job_id;
  g_jobid_stmt:=' Job '||g_job_id||' ';
  g_status:=true;
  g_dim_name:=p_dim_name;
  EDW_OWB_COLLECTION_UTIL.init_all(g_dim_name||'_'||g_job_id,null,'bis.edw.loader');
  write_to_log_file_n('In COLLECT_DIMENSION. p_dim_name='||p_dim_name||', p_table_name='||p_table_name||
  ', p_job_id='||p_job_id||', p_ok_low_end='||p_ok_low_end||', p_ok_high_end='||p_ok_high_end||get_time);
  --g_job_id is not the dbms_job job_id. its just an identifier. goes from 1..n
  /*need to open log file
  this wont be conc manager log file
  */
  if COLLECT_DIMENSION(p_table_name,p_ok_low_end,p_ok_high_end)=false then
    if EDW_OWB_COLLECTION_UTIL.log_into_job_status_table(
      g_job_status_table,
      g_dim_name,
      g_job_id,
      'ERROR',
      g_status_message)=false then
      null;
    end if;
  else
    if EDW_OWB_COLLECTION_UTIL.log_into_job_status_table(
      g_job_status_table,
      g_dim_name,
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

function COLLECT_DIMENSION(
p_table_name varchar2,--input table
p_ok_low_end number,
p_ok_high_end number
) return boolean is
Begin
  if read_options_table(p_table_name)=false then
    return false;
  end if;
  --g_conc_program_id is read from p_table_name
  EDW_OWB_COLLECTION_UTIL.set_conc_program_id(g_conc_id);
  EDW_OWB_COLLECTION_UTIL.set_debug(g_debug);
  EDW_OWB_COLLECTION_UTIL.set_parallel(g_parallel);
  EDW_OWB_COLLECTION_UTIL.set_g_read_cfig_options(g_read_cfig_options);
  if set_session_parameters=false then
    g_status:=false;
    return false;
  end if;  --alter session etc
  g_dim_id:=EDW_OWB_COLLECTION_UTIL.get_object_id(g_dim_name);
  if g_dim_id=-1 then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    return false;
  end if;
  Init_all(g_job_id);--all tables will get job_id appended to them
  /*
  becasue init_all resets many of the global variables that we updated into the inp table,
  will have to read again
  */
  if read_options_table(p_table_name)=false then
    return false;
  end if;
  EDW_OWB_COLLECTION_UTIL.set_up(g_dim_name);
  --if set_level_I_flag=false then
    --return false;
  --end if;
  if get_dim_storage=false then
    g_dim_next_extent:=16000000;--16M default
  end if;
  if g_debug then
    write_to_log_file_n('Next extent ='||g_dim_next_extent);
  end if;
  insert_into_load_progress_d(g_load_pk,g_dim_name,'Read Metadata'||g_jobid_stmt,sysdate,null,'DIMENSION',
  'METADAT','RM'||g_job_id,'I');
  make_level_alias;
  if g_status=false then
    return false;
  end if;
  get_lvl_relations;
  if g_status=false then
    return false;
  end if;
  get_dim_map_ids;
  if g_status=false then
    return false;
  end if;
  if EDW_OWB_COLLECTION_UTIL.get_fks_in_dim(g_dim_name,g_src_fk_table,g_src_fk,g_number_src_fk_table)=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    g_status:=false;
    return false;
  end if;
  if g_debug then
    write_to_log_file_n('The FK used in the dim');
    for i in 1..g_number_src_fk_table loop
      write_to_log_file(g_src_fk_table(i)||'('||g_src_fk(i)||')');
    end loop;
  end if;
  if name_op_tables(g_job_id)=false then
    return false;
  end if;
  make_select_from_where_stmt;
  if g_status=false then
    return false;
  end if;
  make_select_from_where_ins;
  if g_status=false then
    return false;
  end if;
  identify_slow_cols;
  if g_status=false then
    return false;
  end if;
  if g_dim_inc_refresh_derv then
    if is_dim_in_derv_map= false then
      return false;
    end if;
  end if;
  if g_level_change then --g_level_change comes from inp table
    if recreate_from_stmt=false then
      return false;
    end if;
  end if;
  insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'RM'||g_job_id,'U');
  if p_ok_low_end is null then
    g_ilog:=g_ilog_main_name;
  else
    if make_ok_from_main_ok(
      g_ilog_main_name,
      p_ok_low_end,
      p_ok_high_end)=false then
      return false;
    end if;
  end if;
  if g_status then
    if g_dim_empty_flag then
      insert_into_star;
    else
      collect_dim_via_temp;
    end if;
  end if;
  if g_status then
    clean_up_job;
  else
    return false;
  end if;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 write_to_log_file_n('Error in COLLECT '||g_status_message);
 g_status:=false;
 return false;
End;

--for single thread
procedure collect_dimension(
    p_conc_id number,
    p_conc_name varchar2,
    p_dim_name varchar2,
    p_levels EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_child_level_number EDW_OWB_COLLECTION_UTIL.numberTableType,
    p_child_levels EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_child_fk EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_parent_pk EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_level_snapshot_logs EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_levels number,
    p_debug boolean,
    p_exec_flag boolean,
    p_bis_owner varchar2,
    p_parallel number,
    p_collection_size number,
    p_table_owner varchar2,
    p_forall_size number,
    p_update_type varchar2,
    p_level_order EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_skip_cols EDW_OWB_COLLECTION_UTIL.varcharTableType,
    p_number_skip_cols number,
    p_load_pk number,
    p_fresh_restart boolean,
    p_op_table_space varchar2,
    p_rollback varchar2,
    p_ltc_merge_use_nl boolean,
    p_dim_inc_refresh_derv boolean,
    p_check_fk_change boolean,
    p_ok_switch_update number,
    p_join_nl_percentage number,
    p_read_cfig_options boolean,
    p_max_fk_density number,
    p_analyze_frequency number
    ) is
--get the mapping details for dim
--also used to see if slowly changing dim is implemented
begin
g_dim_name:=p_dim_name;
g_jobid_stmt:=null;
g_job_id:=null;
g_conc_id :=p_conc_id;
g_conc_name:=p_conc_name;
g_object_type:='DIMENSION';
g_levels:=p_levels;
g_child_level_number:=p_child_level_number;
g_child_levels:=p_child_levels;
g_child_fk:=p_child_fk;
g_parent_pk:=p_parent_pk;
g_level_snapshot_logs:=p_level_snapshot_logs;
g_number_levels:=p_number_levels;
g_exec_flag:=p_exec_flag;
g_debug:=p_debug;
g_bis_owner:=p_bis_owner;
g_parallel:=p_parallel;
g_collection_size:=p_collection_size;
g_table_owner :=p_table_owner;
g_forall_size:=p_forall_size;
g_update_type :=p_update_type;
g_level_order:=p_level_order;
g_skip_cols:=p_skip_cols;
g_number_skip_cols:=p_number_skip_cols;
g_load_pk:=p_load_pk;
g_fresh_restart:=p_fresh_restart;
g_op_table_space:=p_op_table_space;
g_rollback:=p_rollback;
g_ltc_merge_use_nl:=p_ltc_merge_use_nl;
g_dim_inc_refresh_derv:=p_dim_inc_refresh_derv;
g_check_fk_change:=p_check_fk_change;
g_ok_switch_update:=p_ok_switch_update;
g_join_nl_percentage:=p_join_nl_percentage;
g_read_cfig_options:=p_read_cfig_options;
g_max_fk_density:=p_max_fk_density;
g_analyze_freq:=p_analyze_frequency;
if g_debug then
  write_to_log_file_n('In Summary Collect');
  write_to_log_file('Input parameters');
  write_to_log_file('g_dim_name='||g_dim_name);
  write_to_log_file('g_bis_owner='||g_bis_owner);
  write_to_log_file('g_parallel='||g_parallel);
  write_to_log_file('g_collection_size='||g_collection_size);
  write_to_log_file('g_table_owner='||g_table_owner);
  write_to_log_file('g_forall_size='||g_forall_size);
  write_to_log_file('g_number_levels='||g_number_levels);
  write_to_log_file('g_load_pk='||g_load_pk);
  write_to_log_file('g_op_table_space='||g_op_table_space);
  write_to_log_file('g_rollback='||g_rollback);
  if g_exec_flag then
    write_to_log_file('Execute flag turned ON');
  else
    write_to_log_file('Execute flag turned OFF');
  end if;
  write_to_log_file('Level tables(snapshot log)');
  for i in 1..g_number_levels loop
    write_to_log_file(g_levels(i)||'('||g_level_snapshot_logs(i)||')');
  end loop;
  write_to_log_file('Ordered levels');
  for i in 1..g_number_levels loop
    write_to_log_file(g_level_order(i));
  end loop;
  write_to_log_file('The Skipped Columns');
  for i in 1..g_number_skip_cols loop
    write_to_log_file(g_skip_cols(i));
  end loop;
  if g_fresh_restart then
    write_to_log_file('g_fresh_restart TRUE');
  else
    write_to_log_file('g_fresh_restart FALSE');
  end if;
  if g_ltc_merge_use_nl then
    write_to_log_file('g_ltc_merge_use_nl TRUE');
  else
    write_to_log_file('g_ltc_merge_use_nl FALSE');
  end if;
  if g_dim_inc_refresh_derv then
    write_to_log_file('g_dim_inc_refresh_derv TRUE');
  else
    write_to_log_file('g_dim_inc_refresh_derv FALSE');
  end if;
  if g_check_fk_change then
    write_to_log_file('g_check_fk_change TRUE');
  else
    write_to_log_file('g_check_fk_change FALSE');
  end if;
  write_to_log_file('g_ok_switch_update='||g_ok_switch_update);
  write_to_log_file('g_join_nl_percentage='||g_join_nl_percentage);
  if g_read_cfig_options then
    write_to_log_file('g_read_cfig_options TRUE');
  else
    write_to_log_file('g_read_cfig_options FALSE');
  end if;
  write_to_log_file('g_max_fk_density='||g_max_fk_density);
  write_to_log_file('g_analyze_freq='||g_analyze_freq);
end if;
g_dim_id:=EDW_OWB_COLLECTION_UTIL.get_object_id(g_dim_name);
 if g_dim_id=-1 then
   g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
   return;
 end if;
init_all(g_job_id);
/*
see if the star is empty. if it is then load the rowid of the lowest level into the ilog
*/
check_dim_star_empty;
if check_error = false then
  return;
end if;
if g_fresh_restart or g_dim_empty_flag then
  if drop_restart_tables=false then
    return;
  end if;
else
  if EDW_OWB_COLLECTION_UTIL.merge_all_ilog_tables(g_ilog,g_ilog,g_ilog||'A','IL',g_op_table_space,g_bis_owner,
    g_parallel)=false then
    g_status:=false;
    return;
  end if;
end if;
if get_dim_storage=false then
  g_dim_next_extent:=16000000;--16M default
end if;
if g_debug then
  write_to_log_file_n('Next extent ='||g_dim_next_extent);
end if;
insert_into_load_progress_d(g_load_pk,g_dim_name,'Read Metadata'||g_jobid_stmt,sysdate,null,'DIMENSION',
'METADAT','RM'||g_job_id,'I');
if get_snapshot_log = false then
  insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'RM'||g_job_id,'U');
  return;
end if;
if g_dim_empty_flag = false then
  if check_snapshot_logs = false then
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_ilog)=false then
      null;
    end if;
    insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'RM'||g_job_id,'U');
    write_to_log_file_n('No incremental data to be considered for any level ');
    return;
  end if;
  if g_status=false then
    insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'RM'||g_job_id,'U');
    return;
  end if;
end if;
make_level_alias;
if check_error = false then
  insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'RM'||g_job_id,'U');
  return;
end if;
/*
 get the mapping details for the star
*/
get_lvl_relations;
if check_error = false then
  insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'RM'||g_job_id,'U');
  return;
end if;
/*
get the dim star table pks
*/
get_dim_map_ids;
if g_status=false then
  insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'RM'||g_job_id,'U');
  return;
end if;
if recover_from_previous_error= false then
  return;
end if;
--get the fks in the map
if EDW_OWB_COLLECTION_UTIL.get_fks_in_dim(g_dim_name,g_src_fk_table,g_src_fk,g_number_src_fk_table)=false then
  g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
  g_status:=false;
  return;
end if;
if g_debug then
  write_to_log_file_n('The FK used in the dim');
  for i in 1..g_number_src_fk_table loop
    write_to_log_file(g_src_fk_table(i)||'('||g_src_fk(i)||')');
  end loop;
end if;
--make the select, from and where clause
make_select_from_where_stmt;
if check_error = false then
  insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'RM'||g_job_id,'U');
  return;
end if;
make_select_from_where_ins;
if check_error = false then
  insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'RM'||g_job_id,'U');
  return;
end if;
if name_op_tables(g_job_id)=false then
  insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'RM'||g_job_id,'U');
  return;
end if;
if drop_I_tables=false then
  null;
end if;
insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'RM'||g_job_id,'U');
--identify the slow changing cols
 identify_slow_cols;
 if check_error = false then
   return;
 end if;
 if g_dim_inc_refresh_derv then
   if is_dim_in_derv_map= false then
     return;
   end if;
 end if;
 insert_into_load_progress_d(g_load_pk,g_dim_name,'Create Protection Table'||g_jobid_stmt,sysdate,null,'DIMENSION',
 'INSERT','CPTBL'||g_job_id,'I');
 /*
 if g_slow_implemented then
   if create_prot_table(g_insert_prot_table,g_insert_prot_table_active)=false then
      g_status:=false;
      return ;
    end if;
  end if;*/
  if g_dim_inc_refresh_derv then
    if create_prot_table(g_bu_insert_prot_table,g_bu_insert_prot_table_active)=false then
      g_status:=false;
      return ;
    end if;
    if get_before_update_table_name=false then
      g_status:=false;
      return ;
    end if;
  end if;
  insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'CPTBL'||g_job_id,'U');
  collect_dimension;
  if check_error = false then
    return;
  end if;
  /*
    drop the temp, ilog tables etc
  */
  if drop_prot_table(g_insert_prot_table,g_insert_prot_table_active)=false then
    null;
  end if;
  if drop_prot_table(g_bu_insert_prot_table,g_bu_insert_prot_table_active)=false then
    null;
  end if;
  analyze_star_table;
  clean_up;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
End;--procedure collect_dimension IS

/*
the actual movement of data from the ltc to star
here only in case of single thread
*/
procedure collect_dimension is
l_count number;
Begin
  --now for performance optimization, see if the star table is empty.
  --if it is, then simple insert
  --check if the star had crashed previously. if yes, what is the number of processed records
  --from previous run?
  if g_debug then
    write_to_log_file_n('In Internal collect_dimension');
  end if;
  if check_ll_snplog_col=-1 then
    return;
  end if;
  if g_dim_empty_flag then
    if initial_insert_into_star(false)=false then
      return;
    end if;
    insert_into_star;
  else
    --INCREMENTAL DATA
    insert_into_load_progress_d(g_load_pk,g_dim_name,'Load ILOG'||g_jobid_stmt,sysdate,null,'DIMENSION',
    'INSERT','IL2010'||g_job_id,'I');
    insert_into_ilog(false);
    insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'IL2010'||g_job_id,'U');
    if g_status=false then
      return;
    end if;
    collect_dim_via_temp;
  end if;--if g_dim_empty_flag then
  return;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
End;--procedure collect_dimension IS

procedure collect_dim_via_temp is
l_count number:=0;
l_status number;
Begin
  if g_debug then
    write_to_log_file_n('In collect_dim_via_temp');
  end if;
  make_temp_insert_sql;--to insert into the temp int table
  if check_error = false then
    return;
  end if;
  if g_debug then
    write_to_log_file_n('g_temp_insert_stmt is ');
    write_to_log_file(g_temp_insert_stmt);
  end if;
  --make_update_stmt_temp;
  make_temp_int_to_tm_stmt;
  if check_error = false then
    return;
  end if;
  make_hold_insert_stmt;
  if check_error = false then
    return;
  end if;
  if g_debug then
    write_to_log_file_n('The hold table insert stmt is '||g_hold_insert_stmt);
  end if;
  make_insert_update_stmt_star;
  if check_error = false then
    return;
  end if;
  if g_debug then
    write_to_log_file_n('The insert stmt into star is '||g_insert_stmt_star);
  end if;
  if g_debug then
    write_to_log_file_n('The update stmt into star is '||g_update_stmt_star);
  end if;
  if create_temp_table = false then
    write_to_log_file_n('create_temp_table returned with error ');
    return;
  end if;
  if create_temp_table_int = false then
    write_to_log_file_n('create_temp_table_int returned with error ');
    return;
  end if;
  if set_g_type_ilog_generation=false then
    g_type_ilog_generation:='CTAS';
  end if;
  loop
    l_count:=l_count+1;
    --if reset_profiles=false then
      --g_status:=false;
      --return;
    --end if;
    if g_error_rec_flag=false then --no error recovery
      if g_skip_ilog_update=false then
        l_status:=set_gilog_status;
      else
        g_skip_ilog_update:=false;
        l_status:=2;
      end if;
    else
      if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_ilog,' status=1 ')=2 then
        l_status:=2;
      else
        l_status:=set_gilog_status;
      end if;
      g_error_rec_flag:=false;
      g_skip_ilog_update:=false;
    end if;
    if l_status=0 then --error
      write_to_log_file_n('ERROR set_gilog_status returned with status 0');
      g_status:=false;
      return;
    elsif l_status=1 then
      --no more records to move to star
      write_to_log_file_n('All incremental data moved into the star');
      write_to_log_file('Moved a total of '||g_number_rows_inserted||' records into the star table');
      exit;
    else
       --process still going on
       insert_into_load_progress_d(g_load_pk,g_dim_name,'Determine Incremental Data'||g_jobid_stmt,
       sysdate,null,'DIMENSION','CREATE-TABLE','CDVT2000'||l_count||' '||g_job_id,'I');
       if g_level_change then
         if create_L_from_ilog=false then
           g_status:=false;
           insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'CDVT2000'||l_count||' '||
           g_job_id,'U');
           return;
         end if;
         if drill_up_net_change('SNP')=false then--create L tables for upper levels
           g_status:=false;
           insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'CDVT2000'||l_count||' '||
           g_job_id,'U');
           return;
         end if;
         if drop_ltc_copies=false then
           g_status:=false;
           insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'CDVT2000'||l_count||' '||g_job_id,'U');
           return;
         end if;
         if create_ltc_copies('SNP')=false then
            g_status:=false;
            insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'CDVT2000'||l_count||' '||g_job_id,'U');
           return;
         end if;
         --create_ltc_copies drops all the L tables
       end if;
       insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'CDVT2000'||l_count||' '||g_job_id,'U');
       insert_into_load_progress_d(g_load_pk,g_dim_name,'Pre proccess Dimension Data'||g_jobid_stmt,
       sysdate,null,'DIMENSION','INSERT','CDVT2010'||l_count||' '||g_job_id,'I');
       execute_temp_insert_sql;--move the data into int temp table
       if check_error = false then
         insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'CDVT2010'||l_count||' '||g_job_id,'U');
         return;
       end if;
       if g_slow_implemented then
         --make the key lookup table
         if create_kl_table = false then --contains the user pk and max(rowid)
           write_to_log_file_n('create_kl_table returned with error');
           insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'CDVT2010'||l_count||' '||g_job_id,'U');
           return ;
         end if;
       end if;
       if create_g_dim_name_with_slow=false then
         g_status:=false;
         return;
       end if;
       execute_temp_int_to_tm_stmt;
       if check_error = false then
         insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'CDVT2010'||l_count||' '||g_job_id,'U');
         return;
       end if;
       insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'CDVT2010'||l_count||' '||g_job_id,'U');
       --if there is insert, we need to create ltc copies for all those levels that have g_level_consider=false
       --insert needs to join all levels. update needs to join only the needed levels
       if g_level_change then
         if g_insert_star_flag then
           insert_into_load_progress_d(g_load_pk,g_dim_name,'Drill Up for all levels'||g_jobid_stmt,
           sysdate,null,'DIMENSION','CREATE-TABLE','DUPALL000'||l_count||' '||g_job_id,'I');
           if g_debug then
             write_to_log_file_n('Drill up for non considered levels');
           end if;
           if g_called_ltc_ilog_create=false then
             if create_ltc_ilog_table('NON-SNP')=false then
               g_status:=false;
               insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'DUPALL000'||l_count||' '||g_job_id,'U');
               return;
             end if;
           else
             g_called_ltc_ilog_create:=true;
           end if;
           if drill_up_net_change('NON-SNP')=false then
             g_status:=false;
             insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'DUPALL000'||l_count||' '||g_job_id,'U');
             return;
           end if;
           if create_ltc_copies('NON-SNP')=false then
              g_status:=false;
              insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'DUPALL000'||l_count||' '||g_job_id,'U');
             return;
           end if;
           insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'DUPALL000'||l_count||' '||g_job_id,'U');
         end if;
         if drop_L_tables=false then
           g_status:=false;
           insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'DUPALL000'||l_count||' '||g_job_id,'U');
           return;
         end if;
       end if;
       --if there are rows for update, move the data into hold table
       if g_update_star_flag then
         insert_into_load_progress_d(g_load_pk,g_dim_name,'Move Update Data into Hold Table'||g_jobid_stmt,
         sysdate,null,'DIMENSION','CREATE-TABLE','CDVT2020'||l_count||' '||g_job_id,'I');
         execute_hold_insert_stmt;
         if check_error = false then
           insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'CDVT2020'||l_count||' '||g_job_id,'U');
           return;
         end if;
         insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'CDVT2020'||l_count||' '||g_job_id,'U');
       end if;
       execute_insert_update_star(l_count);
       g_number_rows_processed:=g_number_rows_processed+g_number_rows_inserted;
       if g_debug then
         write_to_log_file_n('Moved '||g_number_rows_inserted||' into star table');
         write_to_log_file('Total moved so far '||g_number_rows_processed);
       end if;
       if check_error = false then
         return;
       end if;
       if g_type_ilog_generation='UPDATE' then
         if delete_gilog_status = false then  --delete where status=1
           return;
         end if;
       end if;
       if EDW_OWB_COLLECTION_UTIL.record_coll_progress(g_dim_name, g_object_type,
         g_number_rows_processed,'PROCESSING','UPDATE')=false then
         g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
         write_to_log_file_n(g_status_message);
         g_status:=false;
         return;
       end if;
       commit;
       if g_debug then
         write_to_log_file_n('commit');
       end if;
       if EDW_OWB_COLLECTION_UTIL.truncate_table(g_dim_name_temp_int) = false then
         return;
       end if;
       if EDW_OWB_COLLECTION_UTIL.truncate_table(g_dim_name_temp) = false then
         return;
       end if;
       if g_update_star_flag then
         if EDW_OWB_COLLECTION_UTIL.truncate_table(g_dim_name_hold) = false then
           return;
         end if;
       end if;
       if EDW_OWB_COLLECTION_UTIL.drop_table(g_dim_name_with_slow)=false then
         null;
       end if;
     end if; --if there are still records in the ilog to consider
  end loop;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
End;

PROCEDURE check_dim_star_empty IS
l_stmt varchar2(1000);
v_res number:=null;
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
if g_debug then
  write_to_log_file_n('In check_dim_star_empty'||get_time);
end if;
v_res:=0;
l_stmt:='select 1 from '||g_dim_name||' where rownum=1';
open cv for l_stmt;
fetch cv into v_res;
if v_res =1 then
  g_dim_empty_flag:=false;
  if g_debug then
    write_to_log_file_n('Star not empty');
  end if;
else
  if g_debug then
    write_to_log_file_n('Star empty');
  end if;
  g_dim_empty_flag:=true;
end if;
close cv;

Exception when others then
 begin
   close cv;
 exception when others then
   null;
 end;
 g_status_message:=sqlerrm;
 write_to_log_file_n(g_status_message);
 write_to_log_file('Problem statement :'||l_stmt);
 g_status:=false;
End;--PROCEDURE check_dim_star_empty IS

--the procedure insert_into_star is for first time insert only.
--this is for performance

function initial_insert_into_star(p_multi_thread boolean) return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In initial_insert_into_star');
  end if;
  g_dim_direct_load:=false;
  if g_number_levels=1 or g_collection_size=0 then
    g_level_change:=false;
    g_ltc_merge_use_nl:=false;
  end if;
  if g_level_change=false and g_collection_size=0 then
    g_dim_direct_load:=true;
  end if;
  if g_dim_direct_load=false then
    insert_into_load_progress_d(g_load_pk,g_dim_name,'Load ILOG'||g_jobid_stmt,sysdate,null,'DIMENSION',
    'INSERT','IL2010'||g_job_id,'I');
    insert_into_ilog(p_multi_thread);
    insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'IL2010'||g_job_id,'U');
    if g_status=false then
      return false;
    end if;
  else
    if create_dummy_ilog=false then
      return false;
    end if;
    truncate_ltc_snapshot_logs;
  end if;
  if g_dim_direct_load=false and g_level_change then
    insert_into_load_progress_d(g_load_pk,g_dim_name,'Create Level Key Tables'||g_jobid_stmt,sysdate,null,'DIMENSION',
    'CREATE-TABLE','IS2020'||g_job_id,'I');
    if drop_L_tables=false then
      insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'IS2020'||g_job_id,'U');
      g_status:=false;
      return false;
    end if;
    if create_ltc_ilog_table('SNP')=false then
      insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'IS2020'||g_job_id,'U');
      g_status:=false;
      return false;
    end if;
    if recreate_from_stmt=false then
      insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'IS2020'||g_job_id,'U');
      g_status:=false;
      return false;
    end if;
    insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'IS2020'||g_job_id,'U');
  end if;
  return true;
Exception when others then
 g_status_message:=sqlerrm;
 write_to_log_file_n('Error in initial_insert_into_star '||g_status_message);
 g_status:=false;
End;

PROCEDURE insert_into_star IS
l_stmt varchar2(32000);
l_stmt_row varchar2(32000);
l_count number:=0; --counts the records as they make in
l_status number;
l_table varchar2(200);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_stmt1 varchar2(4000);
l_rowid rowid;
l_ins_count number;
l_insert_type varchar2(200);
Begin
  if g_debug then
    write_to_log_file_n('In insert_into_star'||get_time);
  end if;
  l_insert_type:='MASS';
  --assume that there are proper levels here
  if g_parallel is null then
    l_stmt:='insert into '||g_dim_name||' ( ';
  else
    l_stmt:='insert /*+ PARALLEL ('||g_dim_name||','||g_parallel||') */ into '||g_dim_name||' ( ';
  end if;
  l_stmt_row:='insert into '||g_dim_name||' ( ';
  for i in 1..g_number_mapping loop
    if g_skip_item(i)=false then
      l_stmt:=l_stmt||' '||g_dim_col(i)||',';
      l_stmt_row:=l_stmt_row||' '||g_dim_col(i)||',';
    end if;
  end loop;
  l_stmt:=l_stmt||' CREATION_DATE, LAST_UPDATE_DATE ) ';
  l_stmt_row:=l_stmt_row||' CREATION_DATE, LAST_UPDATE_DATE ) ';
  if g_dim_direct_load then
    if g_where_stmt is not null then
      l_stmt:=l_stmt||g_select_stmt||',SYSDATE,SYSDATE '||g_from_stmt||' '||g_where_stmt;
      l_stmt_row:=l_stmt_row||g_select_stmt||',SYSDATE,SYSDATE '||g_from_stmt||' '||g_where_stmt||' and '||
      g_lowest_level_alias||'.rowid=:a';
    else
      l_stmt:=l_stmt||g_select_stmt||',SYSDATE,SYSDATE '||g_from_stmt;
      l_stmt_row:=l_stmt_row||g_select_stmt||',SYSDATE,SYSDATE '||g_from_stmt||' where '||
      g_lowest_level_alias||'.rowid=:a';
    end if;
  else
    if g_level_change=false then
      if g_where_stmt is not null then
        l_stmt:=l_stmt||g_select_stmt||',SYSDATE,SYSDATE '||g_from_stmt||','||g_ilog_small||' '||g_where_stmt||
        ' And '||g_ilog_small||'.row_id='||g_lowest_level_alias||'.rowid';
        l_stmt_row:=l_stmt_row||g_select_stmt||',SYSDATE,SYSDATE '||g_from_stmt||' '||g_where_stmt||' and '||
        g_lowest_level_alias||'.rowid=:a';
      else
        l_stmt:=l_stmt||g_select_stmt||',SYSDATE,SYSDATE '||g_from_stmt||','||g_ilog_small||' where '||
        g_ilog_small||'.row_id='||g_lowest_level_alias||'.rowid';
        l_stmt_row:=l_stmt_row||g_select_stmt||',SYSDATE,SYSDATE '||g_from_stmt||' where '||
        g_lowest_level_alias||'.rowid=:a';
      end if;
    else
      if g_where_stmt is not null then
        --remember, ltc copies are only holding commit size data!
        if g_ltc_merge_use_nl then
          l_stmt:=l_stmt||g_select_stmt||',SYSDATE,SYSDATE '||g_from_stmt||' '||g_where_stmt||
          ' and '||g_lowest_level_alias||'.rowid=:a';
          l_stmt_row:=l_stmt_row||g_select_stmt||',SYSDATE,SYSDATE '||g_from_stmt||' '||g_where_stmt||
          ' and '||g_lowest_level_alias||'.rowid=:a';
        else
          l_stmt:=l_stmt||g_select_stmt||',SYSDATE,SYSDATE '||g_from_stmt||' '||g_where_stmt;
          l_stmt_row:=l_stmt_row||g_select_stmt||',SYSDATE,SYSDATE '||g_from_stmt||' '||g_where_stmt||
          ' and '||g_lowest_level_alias||'.rowid=:a';
        end if;
      else
        if g_ltc_merge_use_nl then
          l_stmt:=l_stmt||g_select_stmt||',SYSDATE,SYSDATE '||g_from_stmt||' where '||
          g_lowest_level_alias||'.rowid=:a';
          l_stmt_row:=l_stmt_row||g_select_stmt||',SYSDATE,SYSDATE '||g_from_stmt||' where '||
          g_lowest_level_alias||'.rowid=:a';
        else
          l_stmt:=l_stmt||g_select_stmt||',SYSDATE,SYSDATE '||g_from_stmt;
          l_stmt_row:=l_stmt_row||g_select_stmt||',SYSDATE,SYSDATE '||g_from_stmt||' and '||
          g_lowest_level_alias||'.rowid=:a';
        end if;
      end if;
    end if;
  end if;
  if g_debug then
    write_to_log_file_n('The denormalization stmt is '||l_stmt);
    write_to_log_file_n('The denormalization stmt ROW-BY-ROW is '||l_stmt_row);
  end if;
  loop
    --if reset_profiles=false then
      --g_status:=false;
      --return;
    --end if;
    if g_skip_ilog_update=false then
      l_status:=set_gilog_status;
    else
      g_skip_ilog_update:=false;
      l_status:=2;
    end if;
    if l_status=0 then --error
      g_status:=false;
      return;
    elsif l_status=1 then
      --no more records to move to star
      write_to_log_file_n('Moved a total of '||g_number_rows_processed||' records into the star table');
      exit;
    else
      --process still going on
      --g_collection_size
      insert_into_load_progress_d(g_load_pk,g_dim_name,'Insert into Star'||g_jobid_stmt,sysdate,null,'DIMENSION',
      'INSERT','LIS2020'||l_count||' '||g_job_id,'I');
      if g_level_change then
        if create_L_from_ilog=false then
          g_status:=false;
          insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'LIS2020'||l_count||' '||g_job_id,'U');
          return;
        end if;
        if drill_up_net_change('SNP')=false then--create L tables
          g_status:=false;
          insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'LIS2020'||l_count||' '||g_job_id,'U');
          return;
        end if;
        if drop_ltc_copies=false then
          g_status:=false;
          insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'LIS2020'||l_count||' '||g_job_id,'U');
          return;
        end if;
        if create_ltc_copies('SNP')=false then
          g_status:=false;
          insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'LIS2020'||l_count||' '||g_job_id,'U');
          return;
        end if;
        if drop_L_tables=false then
          g_status:=false;
          insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'LIS2020'||l_count||' '||g_job_id,'U');
          return;
        end if;
      else
        if g_collection_size>0 then
          if create_gilog_small=false then
            return;
          end if;
        end if;
      end if;
      begin
        if g_debug then
          write_to_log_file_n('Going to execute insert into star');
        end if;
        <<start_direct_insert>>
        if g_ltc_merge_use_nl or l_insert_type='ROW-BY-ROW' then
          if g_debug then
            write_to_log_file_n('nested loop option');
          end if;
          g_number_rows_inserted:=0;
          l_ins_count:=0;
          l_table:=g_dim_name_hold||'R';
          l_stmt1:='create table '||l_table||' tablespace '||g_op_table_space;
          if g_parallel is not null then
            l_stmt1:=l_stmt1||' parallel (degree '||g_parallel||') ';
          end if;
          l_stmt1:=l_stmt1||'  as select rowid row_id from '||g_lowest_level;
          if g_debug then
            write_to_log_file_n('Going to execute '||l_stmt1||get_time);
          end if;
          if EDW_OWB_COLLECTION_UTIL.drop_table(l_table)=false then
            null;
          end if;
          execute immediate l_stmt1;
          if g_debug then
            write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
          end if;
          EDW_OWB_COLLECTION_UTIL.alter_session('NO-PARALLEL');
          l_stmt1:='select row_id from '||l_table;
          open cv for l_stmt1;
          loop
            fetch cv into l_rowid;
            exit when cv%notfound;
            execute immediate l_stmt_row using l_rowid;
            l_ins_count:=l_ins_count+1;
            g_number_rows_inserted:=g_number_rows_inserted+1;
            if l_ins_count=5000 then
              commit;
              l_ins_count:=0;
            end if;
          end loop;
          commit;
          close cv;
          if EDW_OWB_COLLECTION_UTIL.drop_table(l_table)=false then
            null;
          end if;
          if g_parallel is not null then
            EDW_OWB_COLLECTION_UTIL.alter_session('PARALLEL');
          end if;
        else
          begin
            EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
            execute immediate l_stmt;
          exception when others then
            if sqlcode=-4030 then
              if g_debug then
                write_to_log_file_n('Out of memory error in mass insert. (Try row-by-row) '||sqlerrm);
              end if;
              l_insert_type:='ROW-BY-ROW';
              goto start_direct_insert;
            elsif sqlcode=-00060 then
              if g_debug then
                write_to_log_file_n('Deadlock detected. Try again after sleep');
              end if;
              DBMS_LOCK.SLEEP(g_sleep_time);
              goto start_direct_insert;
            end if;
            g_status_message:=sqlerrm;
            write_to_log_file_n(g_status_message);
            g_status:=false;
            return;
          end;
          g_number_rows_inserted:=sql%rowcount;
        end if;
        g_number_rows_processed:=g_number_rows_processed+g_number_rows_inserted;
        if g_debug then
          write_to_log_file_n('Moved '||g_number_rows_inserted||' into the star table '||get_time);
          write_to_log_file('Total moved so far '||g_number_rows_processed);
        end if;
      exception when others then
        g_status_message:=sqlerrm;
        g_status:=false;
        write_to_log_file_n(g_status_message);
        write_to_log_file('Problem stmt '||l_stmt);
        insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'LIS2020'||l_count||' '||g_job_id,'U');
        return;
      end;
      if g_type_ilog_generation='UPDATE' then
        if delete_gilog_status=false then  --delete where status=1
          insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'LIS2020'||l_count||' '||g_job_id,'U');
          return;
        end if;
      end if;
      --update the row in progress log table. EDWACOLB does the insert
      if EDW_OWB_COLLECTION_UTIL.record_coll_progress(g_dim_name, g_object_type,
         g_number_rows_processed,'PROCESSING','UPDATE')= false then
         g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
         g_status:=false;
         write_to_log_file_n(g_status_message);
      end if;
      commit;
      insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'LIS2020'||l_count||' '||g_job_id,'U');
      l_count:=l_count+1;
    end if;
  end loop;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
End;--PROCEDURE insert_into_star IS


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
      l_stmt:='update '||g_ilog||' set status=1 ';
    else
      l_stmt:='update '||g_ilog||' set status=1 where rownum <='||g_collection_size;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt);
    end if;
    EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
    execute immediate l_stmt;
    l_count:=sql%rowcount;
    commit;
    if g_debug then
      write_to_log_file_n('commit');
    end if;
    if g_debug then
      write_to_log_file_n('Updated '||l_count||' rows in '||g_ilog||get_time);
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
    if g_collection_size > 0 then
      if g_ll_snplog_has_pk then
        l_stmt:=l_stmt||'  as select row_id,'||g_ltc_pk||',decode(status,1,2,2,2,decode(sign(rownum-'||
        g_collection_size||'),1,0,1)) status from (select row_id,'||g_ltc_pk||',status from '||g_ilog_prev||
        ' order by status) abc ';
      else
        l_stmt:=l_stmt||'  as select row_id,decode(status,1,2,2,2,decode(sign(rownum-'||
        g_collection_size||'),1,0,1)) status from (select row_id,status from '||g_ilog_prev||
        ' order by status) abc ';
      end if;
    else
      if g_ll_snplog_has_pk then
        l_stmt:=l_stmt||'  as select row_id,'||g_ltc_pk||',decode(status,1,2,0,1,2) status from '||
        g_ilog_prev;
      else
        l_stmt:=l_stmt||'  as select row_id,decode(status,1,2,0,1,2) status from '||
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
  g_status:=false;
  return 0;
End;

function delete_gilog_status return boolean is
l_stmt varchar2(4000);
Begin
  if g_debug then
    write_to_log_file_n('In delete_gilog_status');
  end if;
  l_stmt:='delete '||g_ilog||' where status=1';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
  execute immediate l_stmt;
  --commit;
  if g_debug then
    write_to_log_file_n('Deleted '||sql%rowcount||' rows from '||g_ilog||get_time);
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  write_to_log_file('Problem stmt '||l_stmt);
  return false;
End;

/*
for slowly changing dims, create the key lookup table that contains user pk and rowid (max)
*/
function create_kl_table return boolean is
l_stmt varchar2(10000);
l_dim_name_temp_int varchar2(400);
Begin
  --g_dim_kl_table
  if g_debug then
    write_to_log_file_n('In create_kl_table');
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dim_kl_table_temp) = false then
    null;
  end if;
  l_dim_name_temp_int:=g_dim_name_temp_int||'T';--just a temp table
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_dim_name_temp_int) = false then
    null;
  end if;
  l_stmt:='create table '||l_dim_name_temp_int||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select '||g_dim_user_pk||' from '||g_dim_name_temp_int;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created '||l_dim_name_temp_int||' with '||sql%rowcount||' records '||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_dim_name_temp_int,instr(l_dim_name_temp_int,'.')+1,
  length(l_dim_name_temp_int)),substr(l_dim_name_temp_int,1,instr(l_dim_name_temp_int,'.')-1));
  l_stmt:='create table '||g_dim_kl_table_temp||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select /*+ORDERED USE_NL('||g_dim_name||')*/ ';
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+PARALLEL ('||g_dim_name||','||g_parallel||')*/ ';
  end if;
  l_stmt:=l_stmt||g_dim_name||'.'||g_dim_user_pk||' '||g_dim_user_pk||', max('||g_dim_name||'.'||g_dim_pk||') '||
  g_dim_pk||' from '||l_dim_name_temp_int||','||g_dim_name||' where '||g_dim_name||'.'||g_dim_user_pk||'='||
  l_dim_name_temp_int||'.'||g_dim_user_pk||' group by '||g_dim_name||'.'||g_dim_user_pk;
  begin
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created '||g_dim_kl_table_temp||' with '||sql%rowcount||' records '||get_time);
    end if;
  exception when others then
    g_status_message:=sqlerrm;
    g_status:=false;
    write_to_log_file_n(g_status_message);
    write_to_log_file('Problem stmt '||l_stmt);
    return false;
  end;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_dim_kl_table_temp,instr(g_dim_kl_table_temp,'.')+1,
  length(g_dim_kl_table_temp)),substr(g_dim_kl_table_temp,1,instr(g_dim_kl_table_temp,'.')-1));
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dim_kl_table) = false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_dim_name_temp_int) = false then
    null;
  end if;
  l_stmt:='create table '||g_dim_kl_table||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select /*+ORDERED*/ ';
  l_stmt:=l_stmt||g_dim_kl_table_temp||'.'||g_dim_user_pk||' '||g_dim_user_pk||','||
  g_dim_kl_table_temp||'.'||g_dim_pk||' '||g_dim_pk;
  if g_number_slow_cols > 0 then
    for i in 1..g_number_slow_cols loop
      l_stmt:=l_stmt||','||g_dim_name_temp_int||'.'||g_slow_cols(i)||' '||g_slow_cols(i);
    end loop;
  end if;
  l_stmt:=l_stmt||' from '||g_dim_name_temp_int||','||g_dim_kl_table_temp||' where '||
  g_dim_name_temp_int||'.'||g_dim_user_pk||'='||g_dim_kl_table_temp||'.'||g_dim_user_pk;
  begin
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created '||g_dim_kl_table||' with '||sql%rowcount||' records '||get_time);
    end if;
  exception when others then
    g_status_message:=sqlerrm;
    g_status:=false;
    write_to_log_file_n(g_status_message);
    write_to_log_file('Problem stmt '||l_stmt);
    return false;
  end;
  --analyze the table
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_dim_kl_table,instr(g_dim_kl_table,'.')+1,
  length(g_dim_kl_table)),substr(g_dim_kl_table,1,instr(g_dim_kl_table,'.')-1));
  if g_debug then
    write_to_log_file_n('Table '||g_dim_kl_table||' analyzed ');
  end if;
  commit;
  if g_debug then
    write_to_log_file_n('commit');
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  return false;
End;


function create_temp_table return boolean is
l_stmt varchar2(30000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_table_found boolean :=false;
l_divide number:=2;
l_next_extent number;
Begin
  if g_debug then
    write_to_log_file_n('In create_temp_table');
  end if;
  --is the table there? then drop it.
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dim_name_temp) = false then
    write_to_log_file_n('Table '||g_dim_name_temp||' not found for dropping');
  end if;
  if g_parallel is null then
    l_divide:=2;
  else
    l_divide:=g_parallel;
  end if;
  l_next_extent:=g_dim_next_extent/l_divide;
  if l_next_extent>16777216 then --16M
    l_next_extent:=16777216;
  end if;
  if l_next_extent is null or l_next_extent=0 then
    l_next_extent:=8388608;
  end if;
  l_stmt:='create table '||g_dim_name_temp||' tablespace '||g_op_table_space||
  ' storage (initial '||l_next_extent||' next '||l_next_extent||' pctincrease 0 MAXEXTENTS 2147483645) ';
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select '||g_dim_user_pk||','||g_dim_pk;
  if g_update_type='DELETE-INSERT' then
    l_stmt:=l_stmt||',CREATION_DATE ';
  end if;
  --we need the user pk because the surr key in dim and ltc are different because of slowly changing dim
  -- we need pk because we need to update it for slow change
  l_stmt:=l_stmt||' from '||g_dim_name||' where 1=2 ';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created table '||g_dim_name_temp);
  end if;
  --add the 4 extra columns
  l_stmt:=' alter table '||g_dim_name_temp||' add (operation_code1 number, '||
          ' row_id1 rowid, row_id2 rowid, row_id3 rowid, slow_flag number) ';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  execute immediate l_stmt;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  write_to_log_file('Problem stmt '||l_stmt);
  return false;
End;

function create_index_temp return boolean is
l_stmt varchar2(4000);
Begin
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  return false;
End;

function drop_index_temp return boolean is
l_stmt varchar2(2000);
Begin
  if g_debug then
    write_to_log_file_n('In drop_index_temp');
  end if;
  l_stmt:='drop index '||g_dim_name_temp||'n1';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  execute immediate l_stmt;
  l_stmt:='drop index '||g_dim_name_temp||'u1';
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


function create_temp_table_int return boolean is
l_stmt varchar2(30000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_table_found boolean :=false;
Begin
  if g_debug then
    write_to_log_file_n('In create_temp_table_int');
  end if;
  --is the table there? then drop it.
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dim_name_temp_int) = false then
    write_to_log_file_n('Table '||g_dim_name_temp_int||' not found for dropping');
  end if;
  l_stmt:='create table '||g_dim_name_temp_int||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select '||g_dim_user_pk||','||g_dim_pk;
  if g_number_slow_cols > 0 then
    for i in 1..g_number_slow_cols loop
      l_stmt:=l_stmt||','||g_slow_cols(i);
    end loop;
  end if;
  l_stmt:=l_stmt||' from '||g_dim_name||' where 1=2 ';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created table '||g_dim_name_temp_int);
  end if;
  --add the 4 extra columns
  l_stmt:=' alter table '||g_dim_name_temp_int||' add (operation_code1 number, '||
  ' row_id1 rowid, row_id2 rowid, row_id3 rowid) ';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  execute immediate l_stmt;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  write_to_log_file('Problem stmt '||l_stmt);
  return false;
End;

function drop_index_temp_int return boolean is
l_stmt varchar2(2000);
Begin
  l_stmt:='drop index '||g_dim_name_temp_int||'u1';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  execute immediate l_stmt;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  write_to_log_file('Problem stmt '||l_stmt);
  return false;
End;

function create_index_temp_int return boolean is
l_stmt varchar2(2000);
Begin
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  write_to_log_file('Problem stmt '||l_stmt);
  return false;
End;

procedure make_temp_int_to_tm_stmt is
Begin
  if g_debug then
    write_to_log_file_n('In make_temp_int_to_tm_stmt');
  end if;
  g_temp_int_tm_stmt:='insert into '||g_dim_name_temp||'( ';
  if g_update_type='DELETE-INSERT' then
    g_temp_int_tm_stmt:=g_temp_int_tm_stmt||g_dim_user_pk||','||g_dim_pk||
    ', row_id1, row_id3, operation_code1,CREATION_DATE,slow_flag) ';
  else
    g_temp_int_tm_stmt:=g_temp_int_tm_stmt||g_dim_user_pk||','||g_dim_pk||
    ', row_id1, row_id3, operation_code1,slow_flag) ';
  end if;
  g_temp_int_tm_stmt:=g_temp_int_tm_stmt||' select /*+ORDERED*/ ';
  if g_slow_implemented then
    g_temp_int_tm_stmt:=g_temp_int_tm_stmt||g_dim_name_temp_int||'.'||g_dim_user_pk||','||
    ' decode ('||g_dim_kl_table||'.rowid,null,'||g_dim_name_temp_int||'.'||g_dim_pk||','||
    ' decode ('||g_dim_name_with_slow||'.row_id,null,'||g_seq_name||'.nextval,'||
    g_dim_kl_table||'.'||g_dim_pk||')), '||g_dim_name_with_slow||'.row_id, '||
    g_dim_name_temp_int||'.row_id3, decode('||g_dim_kl_table||'.rowid,null,0,decode('||
    g_dim_name_with_slow||'.row_id,null,0,1)) ';
    if g_update_type='DELETE-INSERT' then
      g_temp_int_tm_stmt:=g_temp_int_tm_stmt||','||g_dim_name_with_slow||'.CREATION_DATE ';
    end if;
    g_temp_int_tm_stmt:=g_temp_int_tm_stmt||',decode('||g_dim_kl_table||'.rowid,null,0,decode('||
    g_dim_name_with_slow||'.row_id,null,1,0)) ';
    g_temp_int_tm_stmt:=g_temp_int_tm_stmt||' from '||g_dim_name_temp_int||','||g_dim_kl_table||','||
    g_dim_name_with_slow||' where '||g_dim_kl_table||'.'||g_dim_user_pk||'(+)='||
    g_dim_name_temp_int||'.'||g_dim_user_pk||
    ' and '||g_dim_name_with_slow||'.'||g_dim_pk||'(+)='||g_dim_kl_table||'.'||g_dim_pk;
    for i in 1..g_number_slow_cols loop
      g_temp_int_tm_stmt:=g_temp_int_tm_stmt||' and nvl('||g_dim_name_with_slow||'.'||g_slow_cols(i)
      ||'(+),''^^'')= nvl('||g_dim_kl_table||'.'||g_slow_cols(i)||',''^^'')';
    end loop;
  else
    g_temp_int_tm_stmt:=g_temp_int_tm_stmt||g_dim_name_temp_int||'.'||g_dim_user_pk||','||
    g_dim_name_temp_int||'.'||g_dim_pk||','||g_dim_name_with_slow||'.row_id,'||g_dim_name_temp_int||'.row_id3,'||
    'decode('||g_dim_name_with_slow||'.row_id,null,0,1)  ';
    if g_update_type='DELETE-INSERT' then
      g_temp_int_tm_stmt:=g_temp_int_tm_stmt||','||g_dim_name_with_slow||'.CREATION_DATE ';
    end if;
    g_temp_int_tm_stmt:=g_temp_int_tm_stmt||',0 ';
    g_temp_int_tm_stmt:=g_temp_int_tm_stmt||' from '||g_dim_name_temp_int||','||g_dim_name_with_slow||
    ' where '||g_dim_name_with_slow||'.'||g_dim_pk||'(+)='||g_dim_name_temp_int||'.'||g_dim_pk;
  end if;
  if g_debug then
    write_to_log_file_n('g_temp_int_tm_stmt is '||g_temp_int_tm_stmt);
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
End;

procedure make_hold_insert_stmt is
l_divide number:=2;
l_extent number;
Begin
  if g_debug then
    write_to_log_file_n('In make_hold_insert_stmt');
  end if;
  if g_parallel is null then
    l_divide:=2;
  else
    l_divide:=g_parallel;
  end if;
  l_extent:=g_dim_next_extent/l_divide;
  if l_extent>16777216 then --16M
    l_extent:=16777216;
  end if;
  if l_extent is null or l_extent=0 then
    l_extent:=8388608;
  end if;
  g_hold_insert_stmt:='create table '||g_dim_name_hold||' tablespace '||g_op_table_space;
  if g_dim_next_extent is not null then
    g_hold_insert_stmt:=g_hold_insert_stmt||' storage (initial '||l_extent||' next '||
    l_extent||' pctincrease 0 MAXEXTENTS 2147483645) ';
  end if;
  if g_parallel is not null then
    g_hold_insert_stmt:=g_hold_insert_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  g_hold_insert_stmt:=g_hold_insert_stmt||'  as ';
  g_hold_insert_stmt:=g_hold_insert_stmt||g_select_stmt_nopk;
  g_hold_insert_stmt:=g_hold_insert_stmt||',TM.'||g_dim_pk||',TM.'||g_dim_user_pk||',TM.ROW_ID1 row_id';
  if g_update_type='DELETE-INSERT' then
    g_hold_insert_stmt:=g_hold_insert_stmt||',TM.CREATION_DATE ';
  end if;
  g_hold_insert_stmt:=g_hold_insert_stmt||' '||g_from_stmt;
  g_hold_insert_stmt:=g_hold_insert_stmt||','||g_dim_name_temp||' TM ';
  if g_where_stmt is not null then
    g_hold_insert_stmt:=g_hold_insert_stmt||g_where_stmt||' And ';
  else
    g_hold_insert_stmt:=g_hold_insert_stmt||' where ';
  end if;
  g_hold_insert_stmt:=g_hold_insert_stmt||' TM.row_id3='||g_lowest_level_alias||'.ROWID';
  g_hold_insert_stmt:=g_hold_insert_stmt||' And TM.operation_code1=1 ';
  g_hold_insert_stmt_row:='insert into '||g_dim_name_hold||'(';
  g_hold_insert_stmt_row:=g_hold_insert_stmt_row||g_insert_stmt_nopk;
  g_hold_insert_stmt_row:=g_hold_insert_stmt_row||','||g_dim_pk||','||g_dim_user_pk||',row_id) ';
  g_hold_insert_stmt_row:=g_hold_insert_stmt_row||g_select_stmt_nopk;
  g_hold_insert_stmt_row:=g_hold_insert_stmt_row||','||g_dim_pk||','||g_dim_user_pk||',ROW_ID1';
  g_hold_insert_stmt_row:=g_hold_insert_stmt_row||' '||g_from_stmt_hd_row;
  if g_where_stmt is not null then
    g_hold_insert_stmt_row:=g_hold_insert_stmt_row||g_where_stmt||' and ';
  else
    g_hold_insert_stmt_row:=g_hold_insert_stmt_row||' where ';
  end if;
  g_hold_insert_stmt_row:=g_hold_insert_stmt_row||g_lowest_level_alias||'.rowid=:a';
  if g_debug then
    write_to_log_file_n('g_hold_insert_stmt_row is '||g_hold_insert_stmt_row);
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
End;

/*
to speed up creation of the TM table...
*/
function create_g_dim_name_with_slow return boolean is
l_stmt varchar2(20000);
l_kl_table varchar2(80);
l_kl_table_count number;
l_use_nl boolean;
Begin
  if g_debug then
    write_to_log_file_n('In create_g_dim_name_with_slow');
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dim_name_with_slow)=false then
    null;
  end if;
  if g_dim_count is null then
    g_dim_count:=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_dim_name,g_table_owner);
  end if;
  if g_slow_implemented then
    l_kl_table:=g_dim_kl_table;
  else
    l_kl_table:=g_dim_name_temp_int;
  end if;
  l_kl_table_count:=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(l_kl_table,g_bis_owner);
  if g_debug then
    write_to_log_file_n('Dim count = '||g_dim_count||', kl table count='||l_kl_table_count);
  end if;
  l_use_nl:=true;
  if g_dim_count>0 then
    l_use_nl:=EDW_OWB_COLLECTION_UTIL.get_join_nl(l_kl_table_count,g_dim_count,g_join_nl_percentage);
  end if;
  l_stmt:='create table '||g_dim_name_with_slow||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  as select ';
  l_stmt:=l_stmt||'/*+ordered ';
  if l_use_nl then
    l_stmt:=l_stmt||'use_nl('||g_dim_name||')';
  end if;
  l_stmt:=l_stmt||'*/ ';
  if g_parallel is not null then
    l_stmt:=l_stmt||'/*+PARALLEL('||g_dim_name||','||g_parallel||')*/ ';
  end if;
  l_stmt:=l_stmt||g_dim_name||'.'||g_dim_pk||','||g_dim_name||'.rowid row_id ';
  if g_slow_implemented then
    for i in 1..g_number_slow_cols loop
      l_stmt:=l_stmt||','||g_dim_name||'.'||g_slow_cols(i);
    end loop;
  end if;
  if g_update_type='DELETE-INSERT' then
    l_stmt:=l_stmt||','||g_dim_name||'.CREATION_DATE';
  end if;
  l_stmt:=l_stmt||' from '||l_kl_table||','||g_dim_name||' where '||
  l_kl_table||'.'||g_dim_pk||'='||g_dim_name||'.'||g_dim_pk;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created '||g_dim_name_with_slow||' with '||sql%rowcount||' rows '||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_dim_name_with_slow,instr(g_dim_name_with_slow,'.')+1,
  length(g_dim_name_with_slow)),substr(g_dim_name_with_slow,1,instr(g_dim_name_with_slow,'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

--move the data from int temp to temp
procedure execute_temp_int_to_tm_stmt is
Begin
  if g_debug then
    write_to_log_file_n('In execute_temp_int_to_tm_stmt');
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute g_temp_int_tm_stmt '||get_time);
  end if;
  execute immediate g_temp_int_tm_stmt;
  if g_debug then
    write_to_log_file_n('Inserted '||sql%rowcount||' rows into '||g_dim_name_temp||get_time);
  end if;
  commit;
  if g_debug then
    write_to_log_file_n('commit');
  end if;
  --analyze the table
  if sql%rowcount > 0 then
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_dim_name_temp,instr(g_dim_name_temp,'.')+1,
    length(g_dim_name_temp)),substr(g_dim_name_temp,1,instr(g_dim_name_temp,'.')-1));
  end if;
  commit;
  if g_debug then
    write_to_log_file_n('commit');
  end if;
  --if there is slow change and there are pk key for slow change, log it into g_insert_prot_table
  --if g_slow_implemented then
    --if log_pk_into_insert_prot=false then
      --g_status:=false;
      --return;
    --end if;
  --end if;
  /*
  we can boost performance by testing to see if there is updates or not
  if there is no update then dont even bother to execute it
  */
  if check_temp_table_for_status('UPDATE')=true then
    g_update_star_flag:=true;
    if g_debug then
      write_to_log_file_n('Star Update Needed');
    end if;
  else
    g_update_star_flag:=false;
    if g_debug then
      write_to_log_file_n('Star Update NOT Needed');
    end if;
  end if;
  if check_temp_table_for_status('INSERT')=true then
    g_insert_star_flag:=true;
    if g_debug then
      write_to_log_file_n('Star Insert Needed');
    end if;
  else
    g_insert_star_flag:=false;
    if g_debug then
      write_to_log_file_n('Star Insert NOT Needed');
    end if;
  end if;
  if g_debug then
    count_temp_table_records; --this prints out NOCOPY how many insert update etc
  end if;

Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  write_to_log_file('Problem stmt '||g_temp_int_tm_stmt);
End ;

/*
see if in the temp table there are any records with opeartion_code1 of update or insert
*/
function check_temp_table_for_status(p_status varchar2) return boolean is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_res number:=null;
l_status number;
Begin
  if g_debug then
    write_to_log_file_n('In check_temp_table_for_status for status '||p_status);
  end if;
  if p_status='INSERT' then
    l_status:=0;
  elsif p_status='UPDATE' then
    l_status:=1;
  else
    l_status:=2;
  end if;
  l_stmt:='select 1 from '||g_dim_name_temp||' where operation_code1=:a and rownum=1';
  open cv for l_stmt using l_status;
  fetch cv into l_res;
  close cv;
  if l_res is null then
    return false;
  else
    return true;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  return false;
End ;

procedure count_temp_table_records is
l_stmt varchar2(2000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_operation_code1 EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_operation_code2 EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_count EDW_OWB_COLLECTION_UTIL.numberTableType;
l_rowid EDW_OWB_COLLECTION_UTIL.rowidTableType;
l_number number;
begin
  if g_debug then
    write_to_log_file_n('In count_temp_table_records');
  end if;
  l_stmt:='select count(*),  operation_code1 from '||g_dim_name_temp||' '||
    ' group by operation_code1 ';
  l_number:=1;
  open cv for l_stmt;
  loop
    fetch cv into l_count(l_number),
        l_operation_code1(l_number);
    exit when cv%notfound;
    l_number:=l_number+1;
  end loop;
  l_number:=l_number-1;
  close cv;
  write_to_log_file_n('The count(*),operation_code1  of the temp table '||
    g_dim_name_temp);
  for i in 1..l_number loop
    write_to_log_file('  '||l_count(i)||'    '||l_operation_code1(i));
  end loop;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n('Error in count_temp_table_records, not critical '||sqlerrm||get_time);
End ;


PROCEDURE identify_slow_cols IS
l_table EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_table_count number:=1;
cursor c4(p_dim_id number) is
select relation.sequence_name
from edw_pvt_sequences_md_v relation,
   edw_pvt_map_properties_md_v map,
   edw_pvt_map_properties_md_v map2,
   edw_pvt_map_sources_md_v ru
where
     map.primary_target=p_dim_id
and  map2.primary_target=map.primary_source
and  ru.mapping_id=map2.mapping_id
and  ru.source_id=relation.sequence_id;
Begin
if g_debug then
  write_to_log_file_n('In identify_slow_cols '||get_time);
end if;
if EDW_OWB_COLLECTION_UTIL.is_slow_change_implemented(g_dim_name,g_slow_is_name)= true then
  g_slow_implemented:=true;
  if g_debug then
    write_to_log_file_n('Slowly changing implemented');
  end if;
else
  g_slow_implemented:=false;
  if g_debug then
    write_to_log_file_n('Slowly changing NOT implemented');
  end if;
  return;
end if;
l_table_count:=0;
if g_slow_implemented then
  --g_dim_map_id_slow look here...get the cols (dim cols)
  if g_read_cfig_options then
    if g_debug then
      write_to_log_file_n('Reading from Config Options');
    end if;
    if edw_option.get_option_columns(null,g_dim_id,'SLOWDIM',l_table,l_table_count)=false then
      g_status_message:=edw_option.g_status_message;
      g_status:=false;
      return;
    end if;
  else
    if EDW_OWB_COLLECTION_UTIL.get_item_set_cols(l_table,l_table_count,g_dim_name,g_slow_is_name)=false then
      g_status:=false;
      return;
    end if;
  end if;
end if;
if g_debug then
  write_to_log_file_n('The dimension columns being tracked');
  for i in 1..l_table_count loop
    write_to_log_file(l_table(i));
  end loop;
end if;
g_number_slow_cols:=0;
--for the level names, get the star table col names
for i in 1..l_table_count loop
  for j in 1..g_number_mapping loop
    if g_skip_item(j)=false and g_consider_col(j) then
      if l_table(i)=g_dim_col(j) then
        g_number_slow_cols:=g_number_slow_cols+1;
        g_slow_cols(g_number_slow_cols):=g_dim_col(j);
        g_slow_level(g_number_slow_cols):=g_level_name(j);
        g_slow_level_alias(g_number_slow_cols):=get_level_alias(g_level_name(j));
        g_slow_level_col(g_number_slow_cols):=g_level_col(j);
        exit;
      end if;
    end if;
  end loop;
end loop;
if g_debug then
  write_to_log_file_n('Dim slow col        Level Table   Alias    Level Table col');
  for i in 1..g_number_slow_cols loop
    write_to_log_file(g_slow_cols(i)||'  '||g_slow_level(i)||'  '||g_slow_level_alias(i)||
        '   '||g_slow_level_col(i));
  end loop;
end if;
if g_number_slow_cols=0 then
  g_slow_implemented:=false;
  if g_debug then
    write_to_log_file_n('No columns found for tracking. Turning off slowly changing');
  end if;
  return;
end if;
--also get the seq name
open c4(g_dim_id);
fetch c4 into g_seq_name;
close c4;
if g_debug then
  write_to_log_file_n('The sequence name for slow change dims is '||g_seq_name);
end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return;
End;

PROCEDURE make_insert_update_stmt_star IS
l_iv varchar2(400);
Begin
if g_debug then
  write_to_log_file_n('In make_insert_update_stmt_star '||get_time);
end if;
l_iv:=g_dim_name||'_IV';

if g_parallel is null then
  g_insert_stmt_star:='insert into '||g_dim_name||'( ';
else
  g_insert_stmt_star:='insert /*+ PARALLEL ('||g_dim_name||','||g_parallel||') */ into '||g_dim_name||'( ';
end if;
g_insert_stmt_star_row:='insert into '||g_dim_name||'( ';
/*for i in 1..g_number_mapping loop
  if i = 1 then
    g_insert_stmt_star:=g_insert_stmt_star||' '||g_dim_col(i);
  else
    g_insert_stmt_star:=g_insert_stmt_star||','||g_dim_col(i);
  end if;
end loop;*/
g_insert_stmt_star:=g_insert_stmt_star||g_insert_stmt_nopk_ins;
g_insert_stmt_star:=g_insert_stmt_star||','||g_dim_pk||','||g_dim_user_pk;
g_insert_stmt_star:=g_insert_stmt_star||',CREATION_DATE,LAST_UPDATE_DATE) ';
g_insert_stmt_star:=g_insert_stmt_star||g_select_stmt_nopk_ins;
g_insert_stmt_star:=g_insert_stmt_star||',TM.'||g_dim_pk||',TM.'||g_dim_user_pk;
g_insert_stmt_star:=g_insert_stmt_star||',SYSDATE,SYSDATE ';
g_insert_stmt_star:=g_insert_stmt_star||' '||g_from_stmt_ins;
g_insert_stmt_star:=g_insert_stmt_star||','||g_dim_name_temp||' TM ';
if g_where_stmt_ins is not null then
  g_insert_stmt_star:=g_insert_stmt_star||g_where_stmt_ins||' And ';
else
  g_insert_stmt_star:=g_insert_stmt_star||' where ';
end if;
g_insert_stmt_star:=g_insert_stmt_star||' TM.row_id3='||g_lowest_level_alias||'.ROWID';
g_insert_stmt_star:=g_insert_stmt_star||' And TM.operation_code1=0 ';
--row by row stmt
g_insert_stmt_star_row:=g_insert_stmt_star_row||g_insert_stmt_nopk_ins;
g_insert_stmt_star_row:=g_insert_stmt_star_row||','||g_dim_pk||','||g_dim_user_pk;
g_insert_stmt_star_row:=g_insert_stmt_star_row||',CREATION_DATE,LAST_UPDATE_DATE) ';
g_insert_stmt_star_row:=g_insert_stmt_star_row||g_select_stmt_nopk_ins;
g_insert_stmt_star_row:=g_insert_stmt_star_row||','||g_dim_pk||','||g_dim_user_pk;
g_insert_stmt_star_row:=g_insert_stmt_star_row||',SYSDATE,SYSDATE ';
g_insert_stmt_star_row:=g_insert_stmt_star_row||' '||g_from_stmt_ins_row;
if g_where_stmt_ins is not null then
  g_insert_stmt_star_row:=g_insert_stmt_star_row||g_where_stmt_ins||' And ';
else
  g_insert_stmt_star_row:=g_insert_stmt_star_row||' where ';
end if;
g_insert_stmt_star_row:=g_insert_stmt_star_row||g_lowest_level_alias||'.rowid=:a';
--make the update stmt
if g_update_type='DELETE-INSERT' then
  g_update_stmt_star:='insert into '||g_dim_name||' ( ';
  g_update_stmt_star:=g_update_stmt_star||g_insert_stmt_nopk_ins;
  g_update_stmt_star:=g_update_stmt_star||','||g_dim_pk||','||g_dim_user_pk;
  g_update_stmt_star:=g_update_stmt_star||',CREATION_DATE,LAST_UPDATE_DATE';
  g_update_stmt_star:=g_update_stmt_star||') select ';
  g_update_stmt_star:=g_update_stmt_star||g_insert_stmt_nopk_ins;
  g_update_stmt_star:=g_update_stmt_star||','||g_dim_pk||','||g_dim_user_pk;
  g_update_stmt_star:=g_update_stmt_star||',CREATION_DATE,SYSDATE';
  g_update_stmt_star:=g_update_stmt_star||' from '||g_dim_name_hold;
else
  if g_update_type='ROW-BY-ROW' then
    g_update_stmt_star:='update '||g_dim_name||' set ( ';
  elsif g_update_type='MASS' then
    if g_parallel is null then
      g_update_stmt_star:='update /*+ ORDERED USE_NL('||g_dim_name||')*/ '||g_dim_name||' set ( ';
    else
      g_update_stmt_star:='update /*+ ORDERED USE_NL('||g_dim_name||')*/ /*+PARALLEL ('||g_dim_name||','||
      g_parallel||')*/ '||g_dim_name||' set ( ';
    end if;
  end if;
  g_update_stmt_star:=g_update_stmt_star||g_insert_stmt_nopk;
  g_update_stmt_star:=g_update_stmt_star||','||g_dim_pk||','||g_dim_user_pk;
  g_update_stmt_star:=g_update_stmt_star||',LAST_UPDATE_DATE) = ( select ';
  g_update_stmt_star:=g_update_stmt_star||g_insert_stmt_nopk;
  g_update_stmt_star:=g_update_stmt_star||','||g_dim_pk||','||g_dim_user_pk;
  g_update_stmt_star:=g_update_stmt_star||',SYSDATE ';
  g_update_stmt_star:=g_update_stmt_star||' from '||g_dim_name_hold||' where ';
  if g_update_type='ROW-BY-ROW' then
    g_update_stmt_star:=g_update_stmt_star||g_dim_name_hold||'.row_id=:a) where '||g_dim_name||'.rowid=:b ';
  elsif g_update_type='MASS' then
     g_update_stmt_star:=g_update_stmt_star||g_dim_name_hold||'.row_id='||g_dim_name||'.rowid) where '||
     g_dim_name||'.rowid in (select row_id from '||g_dim_name_hold||')';
  end if;
end if;
g_update_stmt_star_row:='update '||g_dim_name||' set ( '||
g_insert_stmt_nopk||','||g_dim_pk||','||g_dim_user_pk||',LAST_UPDATE_DATE) = ( select '||
g_insert_stmt_nopk||','||g_dim_pk||','||g_dim_user_pk||',SYSDATE '||' from '||g_dim_name_hold||' where '||
g_dim_name_hold||'.row_id=:a) where '||g_dim_name||'.rowid=:b ';
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
End;

function create_hold_index return boolean is
l_stmt varchar2(4000);
l_next_extent number;
Begin
  if g_debug then
    write_to_log_file_n('In create_hold_index');
  end if;
  l_next_extent:=g_dim_next_extent/4;
  if l_next_extent>8388608 then --8M
    l_next_extent:=8388608;
  end if;
  if l_next_extent is null or l_next_extent=0 then
    l_next_extent:=4194304;
  end if;
  l_stmt:='create unique index '||g_dim_name_hold||'u on '||
  g_dim_name_hold||'(row_id) tablespace '||g_op_table_space;
  --' storage (initial '||l_next_extent||' next '||l_next_extent||' pctincrease 0 MAXEXTENTS 2147483645)';
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel '||g_parallel;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  execute immediate l_stmt;
  return true;
Exception when others then
  write_to_log_file_n('Error in create_hold_index '||sqlerrm);
  return false;
End;


procedure execute_hold_insert_stmt is
l_stmt varchar2(5000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_rowid rowid;
l_count number;
l_total_count number;
l_table varchar2(200);
l_create_type varchar2(200);
Begin
  if g_debug then
    write_to_log_file_n('In execute_hold_insert_stmt'||get_time);
  end if;
  l_create_type:='MASS';
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dim_name_hold)=false then
    null;
  end if;
  <<start_hd_create>>
  if g_ltc_merge_use_nl=true or l_create_type='ROW-BY-ROW' then
    if g_debug then
      write_to_log_file_n('Nested loop option');
    end if;
    if create_hold_table=false then
      return;
    end if;
    if create_ltc_copy_low_hd_ins('UPDATE')=false then
      return;
    end if;
    l_table:=g_dim_name_hold||'R';
    l_stmt:='create table '||l_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    if g_ltc_merge_use_nl then
      l_stmt:=l_stmt||'  as select rowid row_id from '||g_levels_copy_low_hd_ins;
    else
      l_stmt:=l_stmt||'  as select row_id3 row_id from '||g_dim_name_temp||
      ' where operation_code1=1';
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_table)=false then
      null;
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
    end if;
    l_count:=0;
    l_total_count:=0;
    --disable parallel dml
    EDW_OWB_COLLECTION_UTIL.alter_session('NO-PARALLEL');
    l_stmt:='select row_id from '||l_table;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    open cv for l_stmt;
    loop
      fetch cv into l_rowid;
      exit when cv%notfound;
      execute immediate g_hold_insert_stmt_row using l_rowid;
      l_count:=l_count+1;
      l_total_count:=l_total_count+1;
      if l_count=5000 then
        commit;
        l_count:=0;
      end if;
    end loop;
    close cv;
    commit;
    if g_debug then
      write_to_log_file_n('Inserted '||l_total_count||' rows into '||g_dim_name_hold||get_time);
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_table)=false then
      null;
    end if;
    if g_parallel is not null then
      EDW_OWB_COLLECTION_UTIL.alter_session('PARALLEL');
    end if;
  else
    begin
      execute immediate g_hold_insert_stmt;
    exception when others then
      if sqlcode=-4030 then
        if g_debug then
          write_to_log_file_n('Out of memory error '||sqlerrm||' Try row-by-row');
        end if;
        l_create_type:='ROW-BY-ROW';
        goto start_hd_create;
      end if;
      g_status_message:=sqlerrm;
      write_to_log_file_n(g_status_message);
      g_status:=false;
      return;
    end;
    g_count_dim_name_hold:=sql%rowcount;
    if g_debug then
      write_to_log_file_n('Inserted '||g_count_dim_name_hold||' rows into '||g_dim_name_hold||get_time);
    end if;
  end if;
  if create_hold_index=false then
    null;
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_dim_name_hold,instr(g_dim_name_hold,'.')+1,
  length(g_dim_name_hold)),substr(g_dim_name_hold,1,instr(g_dim_name_hold,'.')-1));
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
End;

function create_dim_name_rowid_hold return boolean is
l_stmt varchar2(2000);
Begin
  if g_debug then
    write_to_log_file_n('In create_dim_name_rowid_hold');
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dim_name_rowid_hold)=false then
    null;
  end if;
  l_stmt:='create table '||g_dim_name_rowid_hold||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'as select row_id from '||g_dim_name_hold;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created '||g_dim_name_rowid_hold||' with '||sql%rowcount||' rows '||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_dim_name_rowid_hold,instr(g_dim_name_rowid_hold,'.')+1,
  length(g_dim_name_rowid_hold)),substr(g_dim_name_rowid_hold,1,instr(g_dim_name_rowid_hold,'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;


function execute_update_stmt return number is
l_stmt varchar2(5000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_rowid EDW_OWB_COLLECTION_UTIL.rowidTableType;
l_count number;
l_total_count number:=0;
l_update_type varchar2(400);
Begin
  if g_debug then
    write_to_log_file_n('In execute_update_stmt');
  end if;
  l_update_type:=g_update_type;

  <<start_update>>

  if l_update_type='MASS' or l_update_type='DELETE-INSERT' then
    --if create_dim_name_rowid_hold=false then
      --return false;
    --end if;
    /*
    having the rowid table seemed to slow down the update!
    */
    null;
  end if;
  if l_update_type='ROW-BY-ROW' then
    l_stmt:='select row_id from '||g_dim_name_hold;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt);
    end if;
    l_count:=1;
    open cv for l_stmt;
    loop
      fetch cv into l_rowid(l_count);
      exit when cv%notfound;
      if l_count>=g_forall_size then
        for i in 1..l_count loop
          execute immediate g_update_stmt_star_row using l_rowid(i),l_rowid(i);
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
        execute immediate g_update_stmt_star_row using l_rowid(i),l_rowid(i);
      end loop;
      l_total_count:=l_total_count+l_count;
    end if;
  elsif l_update_type='MASS' then
    begin
      if g_debug then
        write_to_log_file_n('Going to execute g_update_stmt_star '||get_time);
      end if;
      EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
      execute immediate g_update_stmt_star;
      l_total_count:=sql%rowcount;
    exception when others then
      if sqlcode=-4030 then
        commit;
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
      write_to_log_file('Problem stmt '||g_update_stmt_star);
      return null;
    end ;
  elsif l_update_type='DELETE-INSERT' then
    --first delete
    l_stmt:='delete '||g_dim_name||' where exists (select 1 from '||g_dim_name_hold||' where '||
      g_dim_name_hold||'.row_id='||g_dim_name||'.rowid)';
    --l_stmt:='delete '||g_dim_name||' where exists (select 1 from '||g_dim_name_hold||' where '||
      --g_dim_name_rowid_hold||'.row_id='||g_dim_name||'.rowid)';
    begin
      if g_debug then
        write_to_log_file_n('Going to execute '||l_stmt||get_time);
      end if;
      EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file('Deleted '||sql%rowcount||' rows');
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
        write_to_log_file_n('Going to execute g_update_stmt_star');
      end if;
      EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
      execute immediate g_update_stmt_star;
      if g_debug then
        write_to_log_file('Inserted '||sql%rowcount||' rows');
      end if;
      l_total_count:=sql%rowcount;
    exception when others then
      g_status:=false;
      g_status_message:=sqlerrm;
      write_to_log_file_n(g_status_message);
      write_to_log_file('Problem stmt '||g_update_stmt_star);
      return null;
    end ;
  end if;
  if g_debug then
    write_to_log_file_n('Updated '||l_total_count||' records In Star Table '||get_time);
  end if;
  --if EDW_OWB_COLLECTION_UTIL.drop_table(g_dim_name_rowid_hold)=false then
    --null;
  --end if;
  return l_total_count;
EXCEPTION when others then
  g_status:=false;
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return null;
End;

PROCEDURE execute_insert_update_star(p_count number) IS
l_update_count number:=0;
Begin
  if g_debug then
    write_to_log_file_n('In execute_insert_update_star '||get_time);
  end if;
  if g_insert_star_flag then
    Begin
      insert_into_load_progress_d(g_load_pk,g_dim_name,'Insert Into Star Table'||g_jobid_stmt,sysdate,null,
      'DIMENSION','INSERT','CDVT2030'||p_count||' '||g_job_id,'I');
      if execute_insert_stmt=false then
        insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'CDVT2030'||p_count||' '||g_job_id,'U');
        return;
      end if;
      insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'CDVT2030'||p_count||' '||g_job_id,'U');
    Exception when others then
     g_status_message:=sqlerrm;
     write_to_log_file_n(g_status_message);
     g_status:=false;
     insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'CDVT2030'||p_count||' '||g_job_id,'U');
     return;
    End;
  end if;--if g_insert_star_flag then
  --execute update
  if g_update_star_flag then
    --if the dim is a part of any derv/summary fact, log all needed cols before update
    if g_derv_snp_change_flag then
      insert_into_load_progress_d(g_load_pk,g_dim_name,'Log Before Update Data'||g_jobid_stmt,sysdate,null,
      'DIMENSION','INSERT','LBUCDVT2040'||p_count||' '||g_job_id,'I');
      if log_before_update_data=false then
        insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'LBUCDVT2040'||p_count||' '||g_job_id,'U');
        return;
      end if;
      insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'LBUCDVT2040'||p_count||' '||g_job_id,'U');
    end if;
    insert_into_load_progress_d(g_load_pk,g_dim_name,'Update Star Table'||g_jobid_stmt,sysdate,null,
    'DIMENSION','INSERT','CDVT2040'||p_count||' '||g_job_id,'I');
    l_update_count:=execute_update_stmt;--creates update prot table inside
    insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'CDVT2040'||p_count||' '||g_job_id,'U');
    if l_update_count is null then
      g_status:=false;
      return;
    end if;
  end if;
  g_number_rows_inserted:=g_number_rows_inserted+l_update_count;
  if g_debug then
    write_to_log_file_n('Finished execute_insert_update_star '||get_time);
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
End;

function execute_insert_stmt return boolean is
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_rowid rowid;
l_table varchar2(200);
l_insert_type varchar2(200);
l_unique_violation boolean;
Begin
  if g_debug then
    write_to_log_file_n('In execute_insert_stmt '||get_time);
  end if;
  l_insert_type:='MASS';
  <<start_insert>>
  if g_ltc_merge_use_nl or l_insert_type='ROW-BY-ROW' then
    l_unique_violation:=false;
    if g_debug then
      write_to_log_file_n('ROW-BY-ROW INSERTS');
    end if;
    g_number_rows_inserted:=0;
    if create_ltc_copy_low_hd_ins('INSERT')=false then
      g_status:=false;
      return false;
    end if;
    l_table:=g_dim_name_hold||'R';
    l_stmt:='create table '||l_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    if g_ltc_merge_use_nl then
      l_stmt:=l_stmt||'  as select rowid row_id from '||g_levels_copy_low_hd_ins;
    else
      l_stmt:=l_stmt||'  as select row_id3 row_id from '||g_dim_name_temp||
      ' where operation_code1=0';
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_table)=false then
      null;
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.alter_session('NO-PARALLEL');
    l_stmt:='select row_id from '||l_table;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    open cv for l_stmt;
    loop
      fetch cv into l_rowid;
      exit when cv%notfound;
      begin
        execute immediate g_insert_stmt_star_row using l_rowid;
        commit;
        g_number_rows_inserted:=g_number_rows_inserted+1;
      exception when others then
        rollback;
        if sqlcode=-00001 then
          l_unique_violation:=true;
        else
          g_status_message:=sqlerrm;
          write_to_log_file_n(g_status_message);
          g_status:=false;
          return false;
        end if;
      end;
    end loop;
    close cv;
    commit;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_table)=false then
      null;
    end if;
    if g_parallel is not null then
      EDW_OWB_COLLECTION_UTIL.alter_session('PARALLEL');
    end if;
    if l_unique_violation then
      if reset_temp_opcode=false then
        return false;
      end if;
    end if;
  else
    if g_debug then
      write_to_log_file_n('going to execute g_insert_stmt_star ');
    end if;
    begin
      EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
      execute immediate g_insert_stmt_star;
      g_number_rows_inserted:=sql%rowcount;
    exception when others then
      rollback;
      if sqlcode=-4030 then
        if g_debug then
          write_to_log_file_n('Out of memory error in mass insert. (Try row-by-row) '||sqlerrm||get_time);
        end if;
        l_insert_type:='ROW-BY-ROW';
        goto start_insert;
      elsif sqlcode=-00001 then
        if g_debug then
          write_to_log_file_n('Unique constraint violated '||sqlerrm||get_time);
        end if;
        if reset_temp_opcode=false then
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
        g_status_message:=sqlerrm;
        write_to_log_file_n(g_status_message);
        g_status:=false;
        return false;
      end if;
    end;
  end if;
  if g_debug then
    write_to_log_file_n('Inserted '||g_number_rows_inserted||' rows'||get_time);
  end if;
  commit;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function check_error return boolean is
 begin
  if g_status=false then
    --log the error message
    return false;
  end if;
  return true;
End ;--function check_error return boolean

Function get_status_message return varchar2 is
begin
  return g_status_message;
End;--Function get_status_message return varchar2 is

procedure get_dim_map_ids IS
cursor c3(p_dim_name varchar2) is
  select upper(item.column_name),
  replace(upper(item.column_name),'_KEY'), --for now assume this...
  dim.dim_id
  from edw_unique_keys_md_v pk,
  edw_pvt_key_columns_md_v isu,
  edw_pvt_columns_md_v item,
  edw_dimensions_md_v dim
  where pk.entity_id=dim.dim_id
  and isu.key_id=pk.key_id
  and isu.column_id=item.column_id
  and pk.primarykey=1
  and dim.dim_name=p_dim_name;
begin
--get the PK of the dim table
  g_dim_pk:=null;
  open c3(g_dim_name);
  fetch c3 into g_dim_pk,g_dim_user_pk,g_dim_id;
  close c3;
  if g_dim_pk is null then
    --user did not define a PK constraint on dim start table
    g_status_message:=EDW_OWB_COLLECTION_UTIL.get_message('EDW_NO_PRIMARY_KEY_FOUND');
    write_to_log_file_n(g_status_message);
    g_status:=false;
    return;
  end if;
  --get the corresponding ltc values
  --assume star structure
  for i in 1..g_number_mapping loop
    if g_dim_col(i)=g_dim_pk then
      g_ltc_pk:=g_level_col(i);
      exit;
    end if;
  end loop;
  for i in 1..g_number_mapping loop
    if g_dim_col(i)=g_dim_user_pk then
      g_ltc_user_pk:=g_level_col(i);
      exit;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('The star PK, Ltc Pk, Star User PK and Ltc User Pk');
    write_to_log_file(g_dim_pk||'  '||g_ltc_pk||'  '||g_dim_user_pk||'   '||g_ltc_user_pk);
  end if;
  if g_ltc_pk is null or g_ltc_user_pk is null then
    write_to_log_file_n('No Ltc Pk or User Pk found for the star pks');
    g_status:=false;
    return;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return;
End;--procedure get_dim_map_ids

procedure make_level_alias is
Begin
 if g_debug then
   write_to_log_file_n('In make_level_alias');
 end if;
 for i in 1..g_number_levels loop
   g_levels_alias(i):='A_'||i;
 end loop;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return;
End;

function get_level_alias(p_level varchar2) return varchar2 is
Begin
  if g_debug then
    write_to_log_file_n('In get_level_alias, level is '||p_level);
  end if;
  for i in 1..g_number_levels loop
    if g_levels(i)=p_level then
      return g_levels_alias(i);
    end if;
  end loop;
  return null;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return null;
End;


/*
get_lvl_relations gets the mapping details for the star mapping
*/
Procedure get_lvl_relations IS
Begin
if g_debug then
  write_to_log_file_n('In get_lvl_relations'||get_time);
end if;
EDW_OWB_COLLECTION_UTIL.Get_lvl_dim_mapping(
    g_dim_col,
    g_level_name,
    g_level_col,
    g_number_mapping,
    1); --dont find the rowid
if g_number_mapping=0 then
  g_status_message:=EDW_OWB_COLLECTION_UTIL.get_message('EDW_NO_LVL_DIM_MAPPING_FOUND');
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return;
end if;
--get the lowest level and its relation id
EDW_OWB_COLLECTION_UTIL.get_lowest_level(g_lowest_level, g_lowest_level_id);
if g_lowest_level is null then
  g_status_message:=EDW_OWB_COLLECTION_UTIL.get_message('EDW_NO_LOWEST_LEVEL_FOUND');
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return;
end if;
g_lowest_level_global:=g_lowest_level;
--determine the lowest level alias
for i in 1..g_number_levels loop
  if g_levels(i)=g_lowest_level then
    g_lowest_level_alias:='A_'||i;
    g_lowest_level_index:=i;
  end if;
end loop;
if g_lowest_level_alias is null then
  g_status_message:=EDW_OWB_COLLECTION_UTIL.get_message('EDW_NO_LOWEST_LEVEL_FOUND');
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return;
end if;
if g_debug then
  write_to_log_file_n('The lowest level and its relation id and the alias');
  write_to_log_file(g_lowest_level||'    '||g_lowest_level_id||'   '||g_lowest_level_alias);
  write_to_log_file_n('The mapping between level tables and star table');
  for i in 1..g_number_mapping loop
    write_to_log_file(g_dim_col(i)||'  '||g_level_name(i)||'  '||g_level_col(i));
  end loop;
end if;
--mark the columns to be skipped
for i in 1..g_number_mapping loop
  g_skip_item(i):=false;
end loop;
if g_number_skip_cols >0 then
  for i in 1..g_number_mapping loop
    for j in 1..g_number_skip_cols loop
      if g_dim_col(i)=g_skip_cols(j) then
        g_skip_item(i):=true;
        exit;
      end if;
    end loop;
  end loop;
end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
End;--Procedure get_lvl_relations IS

procedure make_select_from_where_stmt is
l_run integer:=0;
l_all_count integer:=0;
first_time boolean;
l_alias EDW_OWB_COLLECTION_UTIL.varcharTableType;
child_alias varchar2(100);
l_look_at EDW_OWB_COLLECTION_UTIL.booleanTableType;
l_looked_at EDW_OWB_COLLECTION_UTIL.booleanTableType;
l_start number;
l_done_flag boolean;
l_consider_level EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_consider_level number:=0;
l_level_index number;
l_child_index number;
l_affected_levels EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_affected_levels number;
Begin
  --make the alias
  if g_debug then
    write_to_log_file_n('In make_select_from_where_stmt');
  end if;
  if g_dim_empty_flag=false and g_error_rec_flag=false and g_check_fk_change then
    for i in 1..g_number_levels loop
      l_looked_at(i):=false;
      g_consider_level(i):=false;
      if g_consider_snapshot(i) then
        l_look_at(i):=true;
      else
        l_look_at(i):=false;
      end if;
    end loop;
    l_start:=1;
    l_done_flag:=false;
    l_run:=0;
    loop
      if l_look_at(l_start) and l_looked_at(l_start)=false then
        l_number_consider_level:=l_number_consider_level+1;
        l_consider_level(l_number_consider_level):=g_levels(l_start);
        g_consider_level(l_start):=true;
        l_level_index:=0;
        for j in 1..g_child_level_number(l_start) loop
          l_run:=l_run+1;
          l_level_index:=EDW_OWB_COLLECTION_UTIL.index_in_table(g_levels,g_number_levels,g_child_levels(l_run));
          if EDW_OWB_COLLECTION_UTIL.value_in_table(l_consider_level,l_number_consider_level,
            g_child_levels(l_run)) then
            l_looked_at(l_start):=true;
            exit;
          elsif l_look_at(l_level_index) then
            l_looked_at(l_start):=true;
            l_start:=0;
            l_run:=0;
            exit;
          elsif g_child_levels(l_run)=g_lowest_level_global then
            l_looked_at(l_start):=true;
            l_look_at(l_level_index):=true;
            l_start:=0;
            l_run:=0;
            exit;
          end if;
        end loop;
        if l_level_index=0 and l_start<>0 then
          --lowest level
          l_looked_at(l_start):=true;
        elsif l_start<>0 then
          if l_looked_at(l_start)=false then
            --add the child to the list
            l_look_at(l_level_index):=true;
            l_start:=0;
            l_run:=0;
            l_looked_at(l_start):=true;
          end if;
        end if;
      else
        for j in 1..g_child_level_number(l_start) loop
          l_run:=l_run+1;
        end loop;
      end if;
      l_start:=l_start+1;
      if l_start>g_number_levels then
        l_done_flag:=true;
        exit;
      end if;
    end loop;
    --if a child fk has changed, the parent and its parents need to be considered
    if find_all_affected_levels(g_job_id,l_affected_levels,l_number_affected_levels)=false then
      for i in 1..g_number_levels loop
        g_consider_level(i):=true;
      end loop;
    else
      for i in 1..l_number_affected_levels loop
        g_consider_level(EDW_OWB_COLLECTION_UTIL.index_in_table(g_levels,g_number_levels,
        l_affected_levels(i))):=true;
      end loop;
    end if;
  else
    --consider all levels
    for i in 1..g_number_levels loop
      g_consider_level(i):=true;
    end loop;
  end if;
  l_level_index:=EDW_OWB_COLLECTION_UTIL.index_in_table(g_levels,g_number_levels,g_lowest_level_global);
  if g_consider_level(l_level_index)=false then
    if g_debug then
      write_to_log_file_n('Lowest level not in. something fishy');
    end if;
    g_consider_level(l_level_index):=true;
  end if;
  if g_debug then
    write_to_log_file_n('The considered levels');
    for i in 1..g_number_levels loop
      if g_consider_level(i) then
        write_to_log_file(g_levels(i));
      end if;
    end loop;
  end if;
  for i in 1..g_number_mapping loop
    g_consider_col(i):=false;
  end loop;
  for i in 1..g_number_levels loop
    if g_consider_level(i) then
      for j in 1..g_number_mapping loop
        if g_level_name(j)=g_levels(i) then
          g_consider_col(j):=true;
        end if;
      end loop;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('The mappings to be considered');
    for i in 1..g_number_mapping loop
      if g_consider_col(i) then
        write_to_log_file(g_level_name(i)||'('||g_level_col(i)||') to '||g_dim_col(i));
      end if;
    end loop;
  end if;
  --make the insert stmt without the pk and user pk
  g_insert_stmt_nopk:=null;
  for i in 1..g_number_mapping loop
    if g_skip_item(i)=false then
      if g_dim_col(i) <> g_dim_pk and g_dim_col(i) <> g_dim_user_pk then
        if g_consider_col(i) then
          g_insert_stmt_nopk:=g_insert_stmt_nopk||g_dim_col(i)||',';
        end if;
      end if;
    end if;
  end loop;
  if g_insert_stmt_nopk is not null then
    g_insert_stmt_nopk:=substr(g_insert_stmt_nopk,1,length(g_insert_stmt_nopk)-1);
  end if;
  if g_debug then
    write_to_log_file_n('Insert stmt NOPK is '||g_insert_stmt_nopk);
  end if;
  for i in 1..g_number_mapping loop
    l_alias(i):=null;
    for j in 1..g_number_levels loop
      if g_level_name(i)=g_levels(j) then
        l_alias(i):='A_'||j;
        exit;
      end if;
    end loop;
  end loop;
  --identify the top level
  for i in 1..g_number_levels loop
   if g_levels(i)=g_all_level then
     g_all_level_index:=i;
     exit;
   end if;
  end loop;
  g_select_stmt:=' select ';
  g_select_stmt_nopk:=' select ';
  --make the select stmt
  for i in 1..g_number_mapping loop
    if g_skip_item(i)=false then
      if g_consider_col(i) then
        g_select_stmt:=g_select_stmt||l_alias(i)||'.'||g_level_col(i)||' '||g_dim_col(i)||',';
        if g_dim_col(i) <> g_dim_pk and g_dim_col(i) <> g_dim_user_pk then
          g_select_stmt_nopk:=g_select_stmt_nopk||l_alias(i)||'.'||g_level_col(i)||' '||g_dim_col(i)||',';
        end if;
      end if;
    end if;
  end loop;
  g_select_stmt:=substr(g_select_stmt,1,length(g_select_stmt)-1);
  g_select_stmt_nopk:=substr(g_select_stmt_nopk,1,length(g_select_stmt_nopk)-1);
  if g_debug then
    write_to_log_file_n('select stmt is '||g_select_stmt);
    write_to_log_file_n('select stmt NOPK is '||g_select_stmt_nopk);
  end if;
  --make the from
  g_from_stmt:=' from ';
  for i in 1..g_number_levels loop
    if g_consider_level(i) then
      g_from_stmt:=g_from_stmt||g_levels(i)||' A_'||i||',';
    end if;
  end loop;
  g_from_stmt:=substr(g_from_stmt,1,length(g_from_stmt)-1);
  if g_debug then
    write_to_log_file_n('from stmt is '||g_from_stmt);
  end if;
  --make the where clause
  g_fk_pk_number:=0;
  l_run:=0;
  l_all_count:=0;--in the star schema, there is need only to join to the all level for one hierarchy
  g_where_stmt:=' where ';
  for i in 1..g_number_levels loop
    for j in 1..g_child_level_number(i) loop
      l_run:=l_run+1;
      child_alias:=null;
      for k in 1..g_number_levels loop
        if g_child_levels(l_run)=g_levels(k) then
          child_alias:='A_'||k;
          l_child_index:=k;
          exit;
        end if;
      end loop;
      if l_child_index=0 then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.get_message('EDW_NO_LEVEL_FOUND');
        write_to_log_file_n(g_status_message);
        g_status:=false;
        return;
      end if;
      ------------------------------------------------------------
      -- the child and parent info are stored for drill down, drill up etc. improve inc perf
      g_fk_pk_number:=g_fk_pk_number+1;
      g_fk_pk_parent_level(g_fk_pk_number):=g_levels(i);
      g_fk_pk_parent_alias(g_fk_pk_number):=' A_'||i;
      g_fk_pk_parent_pk(g_fk_pk_number):=g_parent_pk(l_run);
      g_fk_pk_child_level(g_fk_pk_number):=g_child_levels(l_run);
      g_fk_pk_child_alias(g_fk_pk_number):=child_alias;
      g_fk_pk_child_fk(g_fk_pk_number):=g_child_fk(l_run);
      ------------------------------------------------------------
      if g_consider_level(i) and g_consider_level(l_child_index) then
        if g_all_level_index=i then
          if l_all_count=0 then
            g_where_stmt:=g_where_stmt||child_alias||'.'||g_child_fk(l_run)||'='||
            ' A_'||i||'.'||g_parent_pk(l_run)||' and ';
            l_all_count:=l_all_count+1;
          end if;
        else
          g_where_stmt:=g_where_stmt||child_alias||'.'||g_child_fk(l_run)||'='||
          ' A_'||i||'.'||g_parent_pk(l_run)||' and ';
        end if;
      end if;
    end loop;
  end loop;
  if g_where_stmt=' where ' then
    g_where_stmt:=null;
  else
    g_where_stmt:=substr(g_where_stmt,1,length(g_where_stmt)-4);
  end if;
  if g_debug then
    write_to_log_file_n('where stmt is '||g_where_stmt);
  end if;
  if g_debug then
    write_to_log_file_n('The fk-pk arrays');
    write_to_log_file('Child level, alias, fk, parent level, alias, pk');
    for i in 1..g_fk_pk_number loop
      write_to_log_file(g_fk_pk_child_level(i)||' '||g_fk_pk_child_alias(i)||' '||g_fk_pk_child_fk(i)||' '||
        g_fk_pk_parent_level(i)||' '||g_fk_pk_parent_alias(i)||' '||g_fk_pk_parent_pk(i));
    end loop;
  end if;
  first_time:=true;
  g_where_snplog_stmt:=null;
  /*
  g_where_snplog_stmt will not contain the join to the snapshot log for the lowest level
  */
  for i in 1..g_number_levels loop
    if g_consider_snapshot.exists(i) then
      if g_consider_snapshot(i) = true and g_levels(i) <> g_lowest_level then
        if first_time then
          g_where_snplog_stmt:=g_where_snplog_stmt||' And ( ';
          g_where_snplog_stmt:=g_where_snplog_stmt||'  '||'A_'||i||'.ROWID IN (select M_ROW$$ from '
          ||g_level_snapshot_logs(i)||') ';
          first_time:=false;
        else
          g_where_snplog_stmt:=g_where_snplog_stmt||' Or '||'A_'||i||'.ROWID IN (select M_ROW$$ from '
          ||g_level_snapshot_logs(i)||') ';
        end if;
      end if;
    end if;
  end loop;
  if first_time = false then
    g_where_snplog_stmt:=g_where_snplog_stmt||' ) ';
  end if;
  if g_debug then
    write_to_log_file_n('Snapshot where stmt is '||g_where_snplog_stmt);
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
End;

procedure make_select_from_where_ins is
l_run integer:=0;
l_all_count integer:=0;
first_time boolean;
l_alias EDW_OWB_COLLECTION_UTIL.varcharTableType;
child_alias varchar2(100);
l_child_index number;
Begin
  --make the alias
  if g_debug then
    write_to_log_file_n('In make_select_from_where_ins');
  end if;
  --make the insert stmt without the pk and user pk
  g_insert_stmt_nopk_ins:=null;
  for i in 1..g_number_mapping loop
    if g_skip_item(i)=false then
      if g_dim_col(i) <> g_dim_pk and g_dim_col(i) <> g_dim_user_pk then
        g_insert_stmt_nopk_ins:=g_insert_stmt_nopk_ins||g_dim_col(i)||',';
      end if;
    end if;
  end loop;
  if g_insert_stmt_nopk_ins is not null then
    g_insert_stmt_nopk_ins:=substr(g_insert_stmt_nopk_ins,1,length(g_insert_stmt_nopk_ins)-1);
  end if;
  if g_debug then
    write_to_log_file_n('Insert stmt NOPK is '||g_insert_stmt_nopk_ins);
  end if;
  for i in 1..g_number_mapping loop
    l_alias(i):=null;
    for j in 1..g_number_levels loop
      if g_level_name(i)=g_levels(j) then
        l_alias(i):='A_'||j;
        exit;
      end if;
    end loop;
  end loop;
  --identify the top level
  for i in 1..g_number_levels loop
   if g_levels(i)=g_all_level then
     g_all_level_index:=i;
     exit;
   end if;
  end loop;
  g_select_stmt_ins:=' select ';
  g_select_stmt_nopk_ins:=' select ';
  --make the select stmt
  for i in 1..g_number_mapping loop
    if g_skip_item(i)=false then
        g_select_stmt_ins:=g_select_stmt_ins||l_alias(i)||'.'||g_level_col(i)||' '||g_dim_col(i)||',';
        if g_dim_col(i) <> g_dim_pk and g_dim_col(i) <> g_dim_user_pk then
          g_select_stmt_nopk_ins:=g_select_stmt_nopk_ins||l_alias(i)||'.'||g_level_col(i)||' '||g_dim_col(i)||',';
        end if;
    end if;
  end loop;
  g_select_stmt_ins:=substr(g_select_stmt_ins,1,length(g_select_stmt_ins)-1);
  g_select_stmt_nopk_ins:=substr(g_select_stmt_nopk_ins,1,length(g_select_stmt_nopk_ins)-1);
  if g_debug then
    write_to_log_file_n('select stmt is '||g_select_stmt_ins);
    write_to_log_file_n('select stmt NOPK is '||g_select_stmt_nopk_ins);
  end if;
  --make the from
  g_from_stmt_ins:=' from  ';
  for i in 1..g_number_levels loop
    g_from_stmt_ins:=g_from_stmt_ins||g_levels(i)||' A_'||i||',';
  end loop;
  g_from_stmt_ins:=substr(g_from_stmt_ins,1,length(g_from_stmt_ins)-1);
  if g_debug then
    write_to_log_file_n('from stmt is '||g_from_stmt_ins);
  end if;
  --make the where clause
  l_run:=0;
  l_all_count:=0;--in the star schema, there is need only to join to the all level for one hierarchy
  g_where_stmt_ins:=' where ';
  for i in 1..g_number_levels loop
    for j in 1..g_child_level_number(i) loop
      l_run:=l_run+1;
      child_alias:=null;
      l_child_index:=0;
      for k in 1..g_number_levels loop
        if g_child_levels(l_run)=g_levels(k) then
          child_alias:='A_'||k;
          l_child_index:=k;
          exit;
        end if;
      end loop;
      if l_child_index=0 then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.get_message('EDW_NO_LEVEL_FOUND');
        write_to_log_file_n(g_status_message);
        g_status:=false;
        return;
      end if;
      if g_all_level_index=i then
        if l_all_count=0 then
          g_where_stmt_ins:=g_where_stmt_ins||child_alias||'.'||g_child_fk(l_run)||'='||
          ' A_'||i||'.'||g_parent_pk(l_run)||' and ';
          l_all_count:=l_all_count+1;
        end if;
      else
        g_where_stmt_ins:=g_where_stmt_ins||child_alias||'.'||g_child_fk(l_run)||'='||
        ' A_'||i||'.'||g_parent_pk(l_run)||' and ';
      end if;
    end loop;
  end loop;
  if g_where_stmt_ins=' where ' then
    g_where_stmt_ins:=null;
  else
    g_where_stmt_ins:=substr(g_where_stmt_ins,1,length(g_where_stmt_ins)-4);
  end if;
  if g_debug then
    write_to_log_file_n('where stmt is '||g_where_stmt_ins);
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
End;

function create_ilog_table return boolean is
l_stmt varchar2(10000);
Begin
  if g_debug then
    write_to_log_file_n('In create_ilog_table');
  end if;
  l_stmt:='create table '||g_ilog||' tablespace '||g_op_table_space||
  ' storage(initial 4M next 4M pctincrease 0 MAXEXTENTS 2147483645)';
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select rowid row_id,';
  if g_ll_snplog_has_pk then
    l_stmt:=l_stmt||g_ltc_pk||',';
  end if;
  l_stmt:=l_stmt||' 0 status from '||g_lowest_level_global||' where 1=2';
  --l_stmt:='create table '||g_ilog||' (row_id rowid, status number) '||' tablespace '||g_op_table_space||
  --' storage(initial 8M next 8M pctincrease 0 MAXEXTENTS 2147483645)';
  --if g_parallel is not null then
    --l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  --end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  execute immediate l_stmt;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

/*
a temp function here only because m_row$$ is varchar2 while row_id is rowid, see MINUS
*/
function create_gilog_T(p_snp_log varchar2,p_ilog_temp varchar2) return boolean is
l_stmt varchar2(4000);
Begin
  if g_debug then
    write_to_log_file_n('In create_gilog_T');
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_ilog_temp)=false then
    null;
  end if;
  l_stmt:='create table '||p_ilog_temp||'(row_id rowid) '||' tablespace '||g_op_table_space;
  if g_parallel is not null then
   l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  begin
    execute immediate l_stmt;
  exception when others then
    g_status:=false;
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message);
    return false;
  end;
  l_stmt:='insert into '||p_ilog_temp||' (row_id) select ';
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+PARALLEL ('||p_snp_log||','||g_parallel||')*/ ';
  end if;
  l_stmt:=l_stmt||' M_ROW$$ from '||p_snp_log;
  if g_debug then
     write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  begin
    EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Moved '||sql%rowcount||' rows into '||p_ilog_temp);
    end if;
    commit;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(p_ilog_temp,instr(p_ilog_temp,'.')+1,
    length(p_ilog_temp)),substr(p_ilog_temp,1,instr(p_ilog_temp,'.')-1));
  exception when others then
    g_status:=false;
    g_status_message:=sqlerrm;
    write_to_log_file_n(g_status_message);
    return false;
  end;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

/*
create the level Ilog  table for all levels
*/
function create_ltc_ilog_table(p_mode varchar2) return boolean is
l_stmt varchar2(10000);
l_pk varchar2(400);
l_fk  EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_fk number;
l_found boolean:=false;
l_consider boolean;
l_create_ilog_index boolean;
l_total_count number;
l_ltc_count number;
l_storage number;
Begin
  if g_debug then
    write_to_log_file_n('In create_ltc_ilog_table mode='||p_mode);
  end if;
  if p_mode='SNP' then
    for i in 1..g_number_levels loop
      if g_consider_level(i) and g_levels(i)<>g_lowest_level_global then
        l_found:=true;
      end if;
    end loop;
    if l_found=false then
      if g_debug then
        write_to_log_file_n('Only lowest level changed. No need to create ltc ilog');
      end if;
      return true;
    end if;
  end if;
  for i in 1..g_number_levels loop
    l_consider:=false;
    if g_use_ltc_ilog(i) then
      if p_mode='SNP' then
        if g_consider_level(i) then
          l_consider:=true;
        end if;
      elsif p_mode='NON-SNP' then
        if EDW_OWB_COLLECTION_UTIL.check_table(g_levels_I(i))=false then
          l_consider:=true;
        end if;
      end if;
      if g_debug then
        if l_consider then
          write_to_log_file_n('Creating ltc ilog for '||g_levels(i));
        else
          write_to_log_file_n('NOT Creating ltc ilog for '||g_levels(i));
        end if;
      end if;
      if l_consider then
        --get the pk
        l_pk:=null;
        l_number_fk:=0;
        for j in 1..g_fk_pk_number loop
          if g_fk_pk_parent_level(j)=g_levels(i) then
            l_pk:=g_fk_pk_parent_pk(j);
            exit;
          end if;
        end loop;
        if g_levels(i)=g_lowest_level_global then
          l_pk:=g_ltc_pk;
        end if;
        if g_debug then
          write_to_log_file_n('Considering level '||g_levels(i)||' and pk='||l_pk);
        end if;
        --get the fks
        for j in 1..g_fk_pk_number loop
          if g_fk_pk_child_level(j)=g_levels(i) then
            l_number_fk:=l_number_fk+1;
            l_fk(l_number_fk):=g_fk_pk_child_fk(j);
          end if;
        end loop;
        if g_debug then
          write_to_log_file('FKs are ');
          for j in 1..l_number_fk loop
            write_to_log_file(l_fk(j));
          end loop;
        end if;
        if EDW_OWB_COLLECTION_UTIL.drop_table(g_levels_I(i))=false then
          null;
        end if;
        l_ltc_count:=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_levels(i),g_table_owner);
        if g_debug then
          write_to_log_file_n('LTC count='||l_ltc_count);
        end if;
        l_storage:=4;
        if l_ltc_count is not null and l_ltc_count>g_big_table then
          l_storage:=8;
        end if;
        l_stmt:='create table '||g_levels_I(i)||' tablespace '||g_op_table_space;
        l_stmt:=l_stmt||' storage (initial '||l_storage||'M next '||l_storage||'M pctincrease 0) ';
        if g_parallel is not null then
          l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
        end if;
        l_stmt:=l_stmt||' as select ';
        if g_parallel is not null then
          if l_ltc_count is not null and l_ltc_count>g_big_table then
            l_stmt:=l_stmt||'/*+PARALLEL('||g_levels(i)||','||g_parallel||')*/ ';
          else
            l_stmt:=l_stmt||'/*+PARALLEL('||g_levels(i)||','||g_parallel||')*/ ';
          end if;
        end if;
        if l_pk is not null then
          l_stmt:=l_stmt||l_pk||' '||l_pk||',';
        end if;
        for j in 1..l_number_fk loop
          l_stmt:=l_stmt||l_fk(j)||' '||l_fk(j)||',';
        end loop;
        l_stmt:=l_stmt||'rowid row_id from '||g_levels(i);
        if g_debug then
          write_to_log_file_n('Going to execute '||l_stmt||get_time);
        end if;
        l_create_ilog_index:=true;
        EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
        begin
          execute immediate l_stmt;
          l_total_count:=sql%rowcount;
          if g_debug then
            write_to_log_file_n('Created '||g_levels_I(i)||' with '||l_total_count||' rows '||get_time);
          end if;
        exception when others then
          if sqlcode=-00955 then
            --only here in case of multi threading
            if g_debug then
              write_to_log_file_n('Error creating '||g_levels_I(i)||' '||sqlerrm||get_time);
              write_to_log_file('This table '||g_levels_I(i)||' already exists! Some other thread created it!');
            end if;
            l_create_ilog_index:=false;
          else
            g_status_message:=sqlerrm;
            write_to_log_file_n(g_status_message);
            g_status:=false;
            return false;
          end if;
        end;
        if l_create_ilog_index then
          l_create_ilog_index:=EDW_OWB_COLLECTION_UTIL.get_join_nl(g_collection_size,l_total_count,
          g_join_nl_percentage);
          if l_create_ilog_index then
            if l_pk is not null then
              l_stmt:='create unique index '||g_levels_I(i)||'u1 on '||g_levels_I(i)||'('||l_pk||')';
              l_stmt:=l_stmt||' tablespace '||g_op_table_space;
              if g_parallel is not null then
                l_stmt:=l_stmt||' parallel '||g_parallel;
              end if;
              if g_debug then
                write_to_log_file_n('Going to execute '||l_stmt||get_time);
              end if;
              execute immediate l_stmt;
            end if;
            l_stmt:='create unique index '||g_levels_I(i)||'u2 on '||g_levels_I(i)||'(row_id)';
            l_stmt:=l_stmt||' tablespace '||g_op_table_space;
            if g_parallel is not null then
              l_stmt:=l_stmt||' parallel '||g_parallel;
            end if;
            if g_debug then
              write_to_log_file_n('Going to execute '||l_stmt||get_time);
            end if;
            execute immediate l_stmt;
          end if;
          EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_levels_I(i),instr(g_levels_I(i),'.')+1,
          length(g_levels_I(i))),substr(g_levels_I(i),1,instr(g_levels_I(i),'.')-1));
        end if;
      end if;--if l_consider then
    else
      g_levels_I(i):=g_levels(i);
    end if;--if g_use_ltc_ilog(i) then
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

--copy of the snapshot logs
function create_snp_L_tables return boolean is
l_stmt varchar2(10000);
l_table varchar2(200);
l_count number;
l_ltc_i_found boolean;
l_use_nl boolean;
l_use_ordered_hint boolean;
Begin
  if g_debug then
    write_to_log_file_n('In create_snp_L_tables');
  end if;
  l_use_ordered_hint:=true;
  for i in 1..g_number_levels loop
    l_table:=g_snplogs_L(i)||'TMP';
    l_stmt:='create table '||l_table||' tablespace '||g_op_table_space;
    l_stmt:=l_stmt||' storage (initial 4M next 4M pctincrease 0) ';
    if g_parallel is not null then
     l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  as select ';
    if g_parallel is not null then
      l_stmt:=l_stmt||'/*+PARALLEL('||g_level_snapshot_logs(i)||','||g_parallel||')*/ ';
    end if;
    if g_levels(i)=g_lowest_level_global and g_ll_snplog_has_pk then
      l_stmt:=l_stmt||' distinct '||g_ltc_pk||' from '||g_level_snapshot_logs(i);
    else
      l_stmt:=l_stmt||' distinct m_row$$ row_id from '||g_level_snapshot_logs(i);
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_table)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    l_count:=sql%rowcount;
    if g_debug then
      write_to_log_file_n('Created with '||l_count||' rows '||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_table,instr(l_table,'.')+1,
    length(l_table)),substr(l_table,1,instr(l_table,'.')-1));
    if l_count>0 then
      l_ltc_i_found:=false;
      if not(g_levels(i)=g_lowest_level_global and g_ll_snplog_has_pk) then
        --if g_levels_I(i)<>g_levels(i) then
        if g_use_ltc_ilog(i) then
          if EDW_OWB_COLLECTION_UTIL.check_table(g_levels_I(i)) then
            l_ltc_i_found:=true;
          end if;
        end if;
      end if;
    end if;
    <<start_data_into_L>>
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_snplogs_L(i))=false then
      null;
    end if;
    /*l_stmt:='create table '||g_snplogs_L(i)||' tablespace '||g_op_table_space;
    l_stmt:=l_stmt||' storage (initial 4M next 4M pctincrease 0) ';
    if g_parallel is not null then
     l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||'  as select rowid row_id ';
    if g_levels(i)=g_lowest_level_global and g_ll_snplog_has_pk then
      l_stmt:=l_stmt||','||g_ltc_pk;
    end if;
    l_stmt:=l_stmt||' from '||g_levels(i)||' where 1=2';
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created '||g_snplogs_L(i)||get_time);
    end if;    */
    if l_count>0 then
      /*if g_levels(i)=g_lowest_level_global and g_ll_snplog_has_pk then
        l_stmt:='insert into '||g_snplogs_L(i)||'(row_id,'||g_ltc_pk||')';
      else
        l_stmt:='insert into '||g_snplogs_L(i)||'(row_id)';
      end if;
      */
      l_stmt:='create table '||g_snplogs_L(i)||' tablespace '||g_op_table_space;
      l_stmt:=l_stmt||' storage (initial 4M next 4M pctincrease 0) ';
      if g_parallel is not null then
       l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      if g_level_count(i) is null then
        g_level_count(i):=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_levels(i),g_table_owner);
      end if;
      l_use_nl:=EDW_OWB_COLLECTION_UTIL.get_join_nl(l_count,g_level_count(i),g_join_nl_percentage);
      if g_levels(i)=g_lowest_level_global and g_ll_snplog_has_pk then
        l_stmt:=l_stmt||' as select ';
        if l_use_ordered_hint then
          l_stmt:=l_stmt||'/*+ordered ';
          if l_use_nl then
            l_stmt:=l_stmt||'use_nl(A)';
          end if;
          l_stmt:=l_stmt||'*/ ';
        end if;
        if g_parallel is not null then
          l_stmt:=l_stmt||' /*+PARALLEL(A,'||g_parallel||')*/ ';
        end if;
        l_stmt:=l_stmt||'A.rowid row_id,A.'||g_ltc_pk||' from '||l_table||' B,'||g_levels(i)||' A '||
        ' where B.'||g_ltc_pk||'=A.'||g_ltc_pk;
      else
        l_stmt:=l_stmt||' as select ';
        if l_ltc_i_found=false then
          if l_use_ordered_hint then
            l_stmt:=l_stmt||'/*+ordered ';
            if l_use_nl then
              l_stmt:=l_stmt||'use_nl(A)';
            end if;
            l_stmt:=l_stmt||'*/ ';
          end if;
          if g_parallel is not null then
            l_stmt:=l_stmt||'/*+PARALLEL(A,'||g_parallel||')*/ ';
          end if;
          l_stmt:=l_stmt||'A.rowid row_id from '||l_table||' B,'||g_levels(i)||' A '||
          ' where B.row_id=A.rowid';
        else
          if l_use_ordered_hint then
            l_stmt:=l_stmt||'/*+ordered*/ ';
          end if;
          l_stmt:=l_stmt||'A.row_id from '||l_table||' B,'||g_levels_I(i)||' A '||
          ' where B.row_id=A.row_id';
        end if;
      end if;
      if g_debug then
        write_to_log_file_n('Going to execute '||l_stmt||get_time);
      end if;
      begin
        EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
        execute immediate l_stmt;
        if g_debug then
          write_to_log_file_n('Inserted into '||g_snplogs_L(i)||' '||sql%rowcount||' rows '||get_time);
        end if;
        commit;
      exception when others then
        write_to_log_file_n('Error '||sqlerrm||get_time);
        if sqlcode=-01410 then --invalid rowid error
          if l_use_ordered_hint then
            l_use_ordered_hint:=false;
            goto start_data_into_L;
          else
            write_to_log_file_n('Unrecoverable invalid rowid error');
            raise;
          end if;
        end if;
      end;
    else
      --create the empty g_snplogs_L(i) table
      l_stmt:='create table '||g_snplogs_L(i)||' tablespace '||g_op_table_space;
      l_stmt:=l_stmt||' storage (initial 4M next 4M pctincrease 0) ';
      if g_parallel is not null then
       l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  as select rowid row_id ';
      if g_levels(i)=g_lowest_level_global and g_ll_snplog_has_pk then
        l_stmt:=l_stmt||','||g_ltc_pk;
      end if;
      l_stmt:=l_stmt||' from '||g_levels(i)||' where 1=2';
      if g_debug then
        write_to_log_file_n('Going to execute '||l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Created '||g_snplogs_L(i)||get_time);
      end if;
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_snplogs_L(i),instr(g_snplogs_L(i),'.')+1,
    length(g_snplogs_L(i))),substr(g_snplogs_L(i),1,instr(g_snplogs_L(i),'.')-1));
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_table)=false then
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
insert the rowids of the child level into the LT table for the child for all the changed records of the parent
p_mode=DOWN means we are drilling down. for changes to parent, we are finding change to child
p_mode=UP means we are drilling up. for changes to child, we are finding changes to parent
*/
function insert_into_LT(p_child_level varchar2, p_parent_level varchar2,p_mode varchar2) return boolean is
l_stmt varchar2(10000);
l_child_index number:=null;
l_index number;
l_parent_index number:=null;
l_fk_pk_index number:=null;
l_a1_key varchar2(400);
l_a2_key varchar2(400);
l_fk_table varchar2(400);
l_fk_table_count number:=null;--number of rows in fk table
l_L_table_found boolean:=true;
l_snplogs_L varchar2(400);
l_rowid_child varchar2(20);
l_rowid_parent varchar2(20);
l_use_nl_child boolean;
l_use_nl_parent boolean;
l_L_count number;
Begin
  if g_debug then
    write_to_log_file_n('In insert_into_LT');
    write_to_log_file('p_parent_level='||p_parent_level);
    write_to_log_file('p_child_level='||p_child_level);
    write_to_log_file('p_mode='||p_mode);
  end if;
  for i in 1..g_number_levels loop
    if g_levels(i)=p_child_level then
      l_child_index:=i;
      exit;
    end if;
  end loop;
  for i in 1..g_number_levels loop
    if g_levels(i)=p_parent_level then
      l_parent_index:=i;
      exit;
    end if;
  end loop;
  l_use_nl_child:=false;
  l_use_nl_parent:=false;
  if g_levels_I(l_parent_index)=g_levels(l_parent_index) then
    l_rowid_parent:='rowid';
  else
    l_rowid_parent:='row_id';
  end if;
  if g_levels_I(l_child_index)=g_levels(l_child_index) then
    l_rowid_child:='rowid';
  else
    l_rowid_child:='row_id';
  end if;
  if g_debug then
    write_to_log_file_n('parent level and rowid='||g_levels_I(l_parent_index)||'('||l_rowid_parent||')');
    write_to_log_file('child level and rowid='||g_levels_I(l_child_index)||'('||l_rowid_child||')');
  end if;
  for i in 1..g_fk_pk_number loop
    if g_fk_pk_child_level(i)=p_child_level and g_fk_pk_parent_level(i)=p_parent_level then
      l_fk_pk_index:=i;
      exit;
    end if;
  end loop;
  if p_mode='DOWN' then
    l_L_table_found:=EDW_OWB_COLLECTION_UTIL.check_table(g_snplogs_L(l_child_index));
    if g_debug then
      if l_L_table_found then
        write_to_log_file_n('The L table '||g_snplogs_L(l_child_index)||' found');
      else
        write_to_log_file_n('The L table '||g_snplogs_L(l_child_index)||' NOT found');
      end if;
    end if;
    l_a1_key:=g_fk_pk_child_fk(l_fk_pk_index);
    l_a2_key:=g_fk_pk_parent_pk(l_fk_pk_index);
    l_L_count:=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_snplogs_L(l_parent_index),g_bis_owner);
    if g_levels_I(l_child_index)=g_levels(l_child_index) then
      if g_level_count(l_child_index) is null then
        g_level_count(l_child_index):=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_levels(l_child_index),
        g_table_owner);
      end if;
      --check index on l_a1_key
      if EDW_OWB_COLLECTION_UTIL.check_index_on_column(g_levels(l_child_index),g_table_owner,l_a1_key) then
        l_use_nl_child:=EDW_OWB_COLLECTION_UTIL.get_join_nl(l_L_count,g_level_count(l_child_index),
        g_join_nl_percentage);
      end if;
    end if;
    if g_levels_I(l_parent_index)=g_levels(l_parent_index) then
      if g_level_count(l_parent_index) is null then
        g_level_count(l_parent_index):=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_levels(l_parent_index),
        g_table_owner);
      end if;
      l_use_nl_parent:=EDW_OWB_COLLECTION_UTIL.get_join_nl(l_L_count,g_level_count(l_parent_index),
      g_join_nl_percentage);
    end if;
    if l_L_table_found then
      l_stmt:='create table '||g_snplogs_LT(l_child_index)||' tablespace '||g_op_table_space;
    else
      l_stmt:='create table '||g_snplogs_L(l_child_index)||' tablespace '||g_op_table_space;
    end if;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||' as select /*+ORDERED ';
    if l_use_nl_parent then
      l_stmt:=l_stmt||' use_nl(A2)';
    end if;
    if l_use_nl_child then
      l_stmt:=l_stmt||' use_nl(A1)';
    end if;
    l_stmt:=l_stmt||'*/ ';
    if g_parallel is not null then
      l_stmt:=l_stmt||'/*+parallel(A1,'||g_parallel||') parallel(A2,'||g_parallel||')*/ ';
    end if;
    l_stmt:=l_stmt||' A1.'||l_rowid_child||' row_id ';
    if g_levels(l_child_index)=g_lowest_level_global and g_ll_snplog_has_pk then
      l_stmt:=l_stmt||',A1.'||g_ltc_pk;
    end if;
    l_stmt:=l_stmt||' from '||g_snplogs_L(l_parent_index)||' Y,'||g_levels_I(l_parent_index)||' A2,'||
    g_levels_I(l_child_index)||' A1 where A2.'||l_rowid_parent||'=Y.row_id and A1.'||l_a1_key||'=A2.'||l_a2_key;
  else
    l_L_table_found:=EDW_OWB_COLLECTION_UTIL.check_table(g_snplogs_L(l_parent_index));
    if g_debug then
      if l_L_table_found then
        write_to_log_file_n('The L table '||g_snplogs_L(l_parent_index)||' found');
      else
        write_to_log_file_n('The L table '||g_snplogs_L(l_parent_index)||' NOT found');
      end if;
    end if;
    l_a1_key:=g_fk_pk_child_fk(l_fk_pk_index);
    l_a2_key:=g_fk_pk_parent_pk(l_fk_pk_index);
    l_L_count:=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_snplogs_L(l_child_index),g_bis_owner);
    if g_levels_I(l_child_index)=g_levels(l_child_index) then
      if g_level_count(l_child_index) is null then
        g_level_count(l_child_index):=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_levels(l_child_index),
        g_table_owner);
      end if;
      l_use_nl_child:=EDW_OWB_COLLECTION_UTIL.get_join_nl(l_L_count,g_level_count(l_child_index),
      g_join_nl_percentage);
    end if;
    --first create a fk table
    l_fk_table:=g_snplogs_L(l_parent_index)||'F';
    l_stmt:='create table '||l_fk_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||' as select /*+ORDERED ';
    if l_use_nl_child then
      l_stmt:=l_stmt||' use_nl(A1)';
    end if;
    l_stmt:=l_stmt||'*/ ';
    if g_parallel is not null then
      l_stmt:=l_stmt||'/*+parallel(A1,'||g_parallel||')*/ ';
    end if;
    l_stmt:=l_stmt||' distinct A1.'||l_a1_key||' from '||g_snplogs_L(l_child_index)||' Y,'||
    g_levels_I(l_child_index)||' A1 where A1.'||l_rowid_child||'=Y.row_id';
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_fk_table)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    l_fk_table_count:=sql%rowcount;
    if g_debug then
      write_to_log_file_n('Created '||l_fk_table||' with '||sql%rowcount||' rows '||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_fk_table,instr(l_fk_table,'.')+1,
    length(l_fk_table)),substr(l_fk_table,1,instr(l_fk_table,'.')-1));
    if g_levels_I(l_parent_index)=g_levels(l_parent_index) then
      if g_level_count(l_parent_index) is null then
        g_level_count(l_parent_index):=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_levels(l_parent_index),
        g_table_owner);
      end if;
      if EDW_OWB_COLLECTION_UTIL.check_index_on_column(g_levels(l_parent_index),g_table_owner,l_a2_key) then
        l_use_nl_parent:=EDW_OWB_COLLECTION_UTIL.get_join_nl(l_fk_table_count,g_level_count(l_parent_index),
        g_join_nl_percentage);
      end if;
    end if;
    if l_L_table_found then
      l_stmt:='create table '||g_snplogs_LT(l_parent_index)||' tablespace '||g_op_table_space;
    else
      l_stmt:='create table '||g_snplogs_L(l_parent_index)||' tablespace '||g_op_table_space;
    end if;
    if g_parallel is not null then
      /*
        encounetered a wierd bug in the database. this sql
        create table BIS.EDW_TRD_PARTNER_A_LTCLF parallel (degree 3)  as select distinct
        A1.PARENT_TPARTNER_FK_KEY from BIS.EDW_TPRT_P4_TPARTNER_LTCI A1,
        BIS.EDW_TPRT_P4_TPARTNER_LTCL Y where A1.row_id=Y.row_id oo01/29/2001 16:47:30
        was stuck forever. all the tables have only 1 row! if we remove the parallel (degree 3)
        statement, its very fast!! is this a database bug?
      */
      if l_fk_table_count >= 100 then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
    end if;
    l_stmt:=l_stmt||' as select /*+ORDERED ';
    if l_use_nl_parent then
      l_stmt:=l_stmt||' use_nl(A1)';
    end if;
    l_stmt:=l_stmt||'*/ ';
    if g_parallel is not null then
      l_stmt:=l_stmt||'/*+parallel(A1,'||g_parallel||')*/ ';
    end if;
    l_stmt:=l_stmt||' A1.'||l_rowid_parent||' row_id from '||l_fk_table||' Y,'||
    g_levels_I(l_parent_index)||' A1 where A1.'||l_a2_key||'=Y.'||l_a1_key;
    l_index:=l_parent_index;
    l_parent_index:=l_child_index;
    l_child_index:=l_index;
  end if;
  if g_debug then
    write_to_log_file_n('l_parent_index='||l_parent_index);
    write_to_log_file('parent level '||g_levels(l_parent_index));
    write_to_log_file('l_child_index='||l_child_index);
    write_to_log_file('child level '||g_levels(l_child_index));
    write_to_log_file('l_a1_key='||l_a1_key);
    write_to_log_file('l_a2_key='||l_a2_key);
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_snplogs_LT(l_child_index))=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
  execute immediate l_stmt;
  if g_debug then
    if l_L_table_found then
      write_to_log_file_n('Created '||g_snplogs_LT(l_child_index)||' with '||sql%rowcount||' rows '||get_time);
    else
      write_to_log_file_n('Created '||g_snplogs_L(l_child_index)||' with '||sql%rowcount||' rows '||get_time);
    end if;
  end if;
  commit;
  if l_L_table_found then
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_snplogs_LT(l_child_index),
      instr(g_snplogs_LT(l_child_index),'.')+1,length(g_snplogs_LT(l_child_index))),
      substr(g_snplogs_LT(l_child_index),1,instr(g_snplogs_LT(l_child_index),'.')-1));
  end if;
  --now insert into the L table
  if l_L_table_found then
    l_snplogs_L:=g_snplogs_L(l_child_index)||'Z';
    l_stmt:='create table '||l_snplogs_L||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||' as select row_id from '||g_snplogs_LT(l_child_index)||
    ' MINUS select row_id from '||g_snplogs_L(l_child_index);
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_snplogs_L)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Created '||l_snplogs_L||' with '||sql%rowcount||' rows '||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_snplogs_L,instr(l_snplogs_L,'.')+1,
    length(l_snplogs_L)),substr(l_snplogs_L,1,instr(l_snplogs_L,'.')-1));
    if g_levels(l_child_index)=g_lowest_level_global and g_ll_snplog_has_pk then
      l_stmt:='insert into '||g_snplogs_L(l_child_index)||'(row_id,'||g_ltc_pk||') select A.row_id,A.'||g_ltc_pk||
      ' from '||l_snplogs_L||' B,'||g_snplogs_LT(l_child_index)||' A where A.row_id=B.row_id';
    else
      l_stmt:='insert into '||g_snplogs_L(l_child_index)||'(row_id) select row_id from '||l_snplogs_L;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Inserted '||sql%rowcount||' rows into '||g_snplogs_L(l_child_index)||get_time);
    end if;
    commit;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_snplogs_L)=false then
      null;
    end if;
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_snplogs_L(l_child_index),
    instr(g_snplogs_L(l_child_index),'.')+1,length(g_snplogs_L(l_child_index))),
    substr(g_snplogs_L(l_child_index),1,instr(g_snplogs_L(l_child_index),'.')-1));
  if l_fk_table is not null then
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_fk_table)=false then
      null;
    end if;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_snplogs_LT(l_child_index))=false then
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
given a level, see what are the rowids that have changed because of change to the parent
*/
function find_rowid_parent_change(p_level varchar2) return boolean is
l_parent_index number;
l_parent varchar2(400);
l_index number;
Begin
  if g_debug then
    write_to_log_file_n('In find_rowid_parent_change');
    write_to_log_file('p_level='||p_level);
  end if;
  for i in 1..g_fk_pk_number loop
    if g_fk_pk_child_level(i)=p_level then
      l_parent:=g_fk_pk_parent_level(i);
      l_parent_index:=EDW_OWB_COLLECTION_UTIL.index_in_table(g_levels,g_number_levels,l_parent);
      l_index:=EDW_OWB_COLLECTION_UTIL.index_in_table(g_levels,g_number_levels,p_level);
      if g_consider_level(l_index) and g_consider_level(l_parent_index) then
        --if the parent  L table has data then
        --if the parent level has been already considered, do not consider it again
        if EDW_OWB_COLLECTION_UTIL.value_in_table(g_considered_parent,g_number_considered_parent,
          g_levels(l_parent_index))=false then
          if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_snplogs_L(l_parent_index))= 2 then
            if insert_into_LT(p_level,g_levels(l_parent_index),'DOWN')=false then
              return false;
            end if;
            g_number_considered_parent:=g_number_considered_parent+1;
            g_considered_parent(g_number_considered_parent):=g_levels(l_parent_index);
          end if;
          else
          if g_debug then
            write_to_log_file_n('Level '||g_levels(l_parent_index)||' already considered');
          end if;
        end if;
      else
        if g_debug then
          write_to_log_file_n('Both levels '||p_level||' and '||l_parent||' together have no change');
        end if;
      end if;
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
given a level, see what are the parent rowids that have changed because of the child
*/
function find_rowid_child_change(p_level varchar2,p_mode varchar2) return boolean is
l_parent_index number;
l_child_index number;
l_parent varchar2(400);
Begin
  if g_debug then
    write_to_log_file_n('In find_rowid_child_change mode='||p_mode||',level='||p_level);
  end if;
  for i in 1..g_fk_pk_number loop
    if g_fk_pk_child_level(i)=p_level then
      l_parent:=g_fk_pk_parent_level(i);
      l_parent_index:=EDW_OWB_COLLECTION_UTIL.index_in_table(g_levels,g_number_levels,l_parent);
      l_child_index:=EDW_OWB_COLLECTION_UTIL.index_in_table(g_levels,g_number_levels,p_level);
      if (p_mode='SNP' and g_consider_level(l_child_index) and g_consider_level(l_parent_index))
      OR p_mode='NON-SNP' then
        if g_debug then
          write_to_log_file_n('Drill '||g_levels(l_child_index)||' to '||g_levels(l_parent_index));
        end if;
        --if the parent level has been already considered, do not consider it again
        if EDW_OWB_COLLECTION_UTIL.value_in_table(g_considered_parent,g_number_considered_parent,
          g_levels(l_parent_index))=false then
          if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_snplogs_L(l_child_index))= 2 then
            if insert_into_LT(p_level,g_levels(l_parent_index),'UP')=false then
              return false;
            end if;
            g_number_considered_parent:=g_number_considered_parent+1;
            g_considered_parent(g_number_considered_parent):=g_levels(l_parent_index);
          end if;
        else
          if g_debug then
            write_to_log_file_n('Level '||g_levels(l_parent_index)||' already considered');
          end if;
        end if;
      else
        if g_debug then
          write_to_log_file_n('Both levels '||p_level||' and '||l_parent||' together have no change');
        end if;
      end if;
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
after inserting into the L table, insert these rows into the ILOG table
we cannot drop and recreate ilog so we can support error recovery
*/
function insert_into_ilog_from_L(p_multi_thread boolean) return boolean is
l_stmt varchar2(10000);
l_index number;
l_ilog varchar2(400);
l_ilog_el varchar2(400);
Begin
  if g_debug then
    write_to_log_file_n('In insert_into_ilog_from_L');
  end if;
  l_index:=EDW_OWB_COLLECTION_UTIL.index_in_table(g_levels,g_number_levels,g_lowest_level_global);
  if EDW_OWB_COLLECTION_UTIL.check_table(g_ilog)=false then
    --if create_ilog_table= false then
      --return false;
    --end if;
    l_stmt:='create table '||g_ilog||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    l_stmt:=l_stmt||' as select ';
    if p_multi_thread=false or g_collection_size=0 then
      g_skip_ilog_update:=true;
    else
      g_skip_ilog_update:=false;
    end if;
    if g_collection_size>0 then
      if g_ll_snplog_has_pk then
        if p_multi_thread then
          l_stmt:=l_stmt||' row_id,'||g_ltc_pk||',0 status,rownum row_num from '||g_snplogs_L(l_index);
        else
          l_stmt:=l_stmt||' row_id,'||g_ltc_pk||
          ',decode(sign(rownum-'||g_collection_size||'),1,0,1) status from '||g_snplogs_L(l_index);
        end if;
      else
        if p_multi_thread then
          l_stmt:=l_stmt||' row_id,0 status,rownum row_num from '||g_snplogs_L(l_index);
        else
          l_stmt:=l_stmt||' row_id,decode(sign(rownum-'||g_collection_size||'),1,0,1) status from '||
          g_snplogs_L(l_index);
        end if;
      end if;
    else
      if g_ll_snplog_has_pk then
        l_stmt:=l_stmt||' row_id,'||g_ltc_pk||',1 status,rownum row_num from '||g_snplogs_L(l_index);
      else
        l_stmt:=l_stmt||' row_id,1 status,rownum row_num from '||g_snplogs_L(l_index);
      end if;
    end if;
    if g_debug then
      write_to_log_file_n(l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('created with '||sql%rowcount||' rows '||get_time);
    end if;
    if p_multi_thread then
      edw_owb_collection_util.create_rownum_index_ilog(g_ilog,g_op_table_space,g_parallel);
    end if;
  else
    --must have pk_key in ilog for error recovery. there can be row migration with partitions
    --only effective if the lowest level snp log has pk_key
    if substr(g_ilog,length(g_ilog),1)='A' then
      l_ilog_el:=substr(g_ilog,1,length(g_ilog)-1);
    else
      l_ilog_el:=g_ilog||'A';
    end if;
    if g_ll_snplog_has_pk then
      l_stmt:='create table '||l_ilog_el||' tablespace '||g_op_table_space;
      l_stmt:=l_stmt||' storage (initial 4M next 4M pctincrease 0) ';
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  as select /*+ORDERED*/ A.'||g_ltc_pk||',A.rowid row_id,B.status from '||
      g_ilog||' B,'||g_lowest_level_global||' A where A.'||g_ltc_pk||'=B.'||g_ltc_pk;
    else
      l_stmt:='create table '||l_ilog_el||' tablespace '||g_op_table_space;
      l_stmt:=l_stmt||' storage (initial 4M next 4M pctincrease 0) ';
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      l_stmt:=l_stmt||'  as select /*+ORDERED*/ B.row_id,B.status from '||
      g_ilog||' B,'||g_lowest_level_global||' A where A.rowid=B.row_id';
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_ilog_el)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('created '||l_ilog_el||' with '||sql%rowcount||' rows '||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_ilog_el,instr(l_ilog_el,'.')+1,length(l_ilog_el)),
    substr(l_ilog_el,1,instr(l_ilog_el,'.')-1));
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_ilog)=false then
      null;
    end if;
    g_ilog:=l_ilog_el;
    l_ilog:=g_ilog||'T';
    l_stmt:='create table '||l_ilog||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    if g_ll_snplog_has_pk then
      l_stmt:=l_stmt||'  as select row_id,'||g_ltc_pk||',0 status from '||g_snplogs_L(l_index)||
      ' MINUS select row_id,'||g_ltc_pk||',0 status from '||g_ilog;
    else
      l_stmt:=l_stmt||'  as select row_id,0 status from '||g_snplogs_L(l_index)||
      ' MINUS select row_id,0 status from '||g_ilog;
    end if;
    if EDW_OWB_COLLECTION_UTIL.drop_table(l_ilog)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('created '||l_ilog||' with '||sql%rowcount||' rows '||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_ilog,instr(l_ilog,'.')+1,length(l_ilog)),
    substr(l_ilog,1,instr(l_ilog,'.')-1));
    if g_ll_snplog_has_pk then
     l_stmt:='insert into '||g_ilog||'(row_id,'||g_ltc_pk||',status) select row_id,'||g_ltc_pk||
     ',status from '||l_ilog;
    else
      l_stmt:='insert into '||g_ilog||'(row_id, status) select row_id,status from '||l_ilog;
    end if;
    if g_debug then
      write_to_log_file_n('Going to execute '||l_stmt||get_time);
    end if;
    EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
    execute immediate l_stmt;
    if g_debug then
      write_to_log_file_n('Inserted '||sql%rowcount||' rows into '||g_ilog||get_time);
    end if;
    commit;
    if l_ilog is not null then
      if EDW_OWB_COLLECTION_UTIL.drop_table(l_ilog)=false then
        null;
      end if;
    end if;
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_ilog,instr(g_ilog,'.')+1,length(g_ilog)),
  substr(g_ilog,1,instr(g_ilog,'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

/*
create L table for the lowest level with row_id from gilog
*/
function create_L_from_ilog return boolean is
l_stmt varchar2(10000);
l_index number;
Begin
  if g_debug then
    write_to_log_file_n('In create_L_from_ilog');
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_snplogs_L(g_lowest_level_index))=false then
    null;
  end if;
  l_stmt:='create table '||g_snplogs_L(g_lowest_level_index)||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select row_id from '||g_ilog||' where status=1';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created '||g_snplogs_L(g_lowest_level_index)||'with  '||sql%rowcount||
    ' rows '||get_time);
  end if;
  commit;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_snplogs_L(g_lowest_level_index),
  instr(g_snplogs_L(g_lowest_level_index),'.')+1,length(g_snplogs_L(g_lowest_level_index))),
         substr(g_snplogs_L(g_lowest_level_index),1,instr(g_snplogs_L(g_lowest_level_index),'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

/*
give all these temp tables names
*/
function name_op_tables(p_job_id number) return boolean is
l_prefix varchar2(40);
l_name varchar2(40);
l_name_org varchar2(40);
Begin
  if g_debug then
    write_to_log_file_n('In name_op_tables');
  end if;
  for i in 1..g_number_levels loop
    l_prefix:=EDW_OWB_COLLECTION_UTIL.get_level_prefix(substr(g_levels(i),1,instr(g_levels(i),'_LTC')-1));
    l_name_org:='TAB_'||g_dim_id||'_'||l_prefix||'_';
    if p_job_id is null then
      l_name:='TAB_'||g_dim_id||'_'||l_prefix||'_';
    else
      l_name:='TAB_'||g_dim_id||'_'||l_prefix||'_'||p_job_id||'_';
    end if;
    g_snplogs_L(i):=g_bis_owner||'.'||l_name||'L';
    if p_job_id is null then
      g_levels_I(i):=g_bis_owner||'.'||l_name_org||'I';--this name is shared across threads
      --when p_job_id is not null, g_levels_I is read from the input table
    end if;
    g_levels_copy(i):=g_bis_owner||'.'||l_name||'C';
    g_snplogs_LT(i):=g_bis_owner||'.'||l_name||'LT';
  end loop;
  g_levels_copy_low_hd_ins:=g_bis_owner||'.'||l_name||'LL_CL';
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function create_ltc_copies(p_mode varchar2) return boolean is
l_stmt varchar2(10000);
l_pk varchar2(400);
l_consider boolean;
l_cols EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_cols number;
l_L_count number;
l_nl_flag boolean;
Begin
  if g_debug then
    write_to_log_file_n('In create_ltc_copies mode='||p_mode);
  end if;
  for i in 1..g_number_levels loop
    l_consider:=false;
    if p_mode='SNP' then
      if EDW_OWB_COLLECTION_UTIL.drop_table(g_levels_copy(i))=false then
        null;
      end if;
      if g_consider_level(i) then
        l_consider:=true;
      end if;
    elsif p_mode='NON-SNP' and g_consider_level(i)=false then
      if EDW_OWB_COLLECTION_UTIL.drop_table(g_levels_copy(i))=false then
        null;
      end if;
      l_consider:=true;
    end if;
    if l_consider then
      if EDW_OWB_COLLECTION_UTIL.check_table(g_snplogs_L(i))=false then
        l_stmt:='create table '||g_snplogs_L(i)||' tablespace '||g_op_table_space;
        l_stmt:=l_stmt||' as select rowid row_id from '||g_levels(i)||' where 1=2';
        if g_debug then
          write_to_log_file_n('Going to execute '||l_stmt||get_time);
        end if;
        execute immediate l_stmt;
        if g_debug then
          write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
        end if;
      end if;
      if g_level_count(i) is null then
        g_level_count(i):=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_levels(i),g_table_owner);
      end if;
      l_L_count:=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(g_snplogs_L(i),g_bis_owner);
      l_nl_flag:=EDW_OWB_COLLECTION_UTIL.get_join_nl(l_L_count,g_level_count(i),g_join_nl_percentage);
      l_stmt:='create table '||g_levels_copy(i)||' tablespace '||g_op_table_space;
      if g_parallel is not null then
        l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
      end if;
      if l_nl_flag then
        l_stmt:=l_stmt||' as select /*+ORDERED USE_NL('||g_levels(i)||')*/ ';
      else
        l_stmt:=l_stmt||' as select /*+ORDERED*/ ';
      end if;
      if g_parallel is not null then
        l_stmt:=l_stmt||'/*+PARALLEL('||g_levels(i)||','||g_parallel||')*/ ';
      end if;
      --find the columns to include
      l_number_cols:=0;
      for j in 1..g_number_mapping loop
        if g_level_name(j)=g_levels(i) then
          if g_skip_item(j)=false then
            l_number_cols:=l_number_cols+1;
            l_cols(l_number_cols):=g_level_col(j);
          end if;
        end if;
      end loop;
      if g_number_src_fk_table>0 then
        for j in 1..g_number_src_fk_table loop
          if g_src_fk_table(j)=g_levels(i) then
            if EDW_OWB_COLLECTION_UTIL.value_in_table(l_cols,l_number_cols,g_src_fk(j))=false then
              l_number_cols:=l_number_cols+1;
              l_cols(l_number_cols):=g_src_fk(j);
            end if;
          end if;
        end loop;
      end if;
      --bug
      --we need to include the PK_KEY columns even if they are not mapped, especially for
      --higher levels
      if g_levels(i)<>g_lowest_level_global then
        for j in 1..g_fk_pk_number loop
          if g_fk_pk_parent_level(j)=g_levels(i) then
            if EDW_OWB_COLLECTION_UTIL.value_in_table(l_cols,l_number_cols,g_fk_pk_parent_pk(j))=false then
              l_number_cols:=l_number_cols+1;
              l_cols(l_number_cols):=g_fk_pk_parent_pk(j);
            end if;
          end if;
        end loop;
      end if;
      --for the lowest level, we need row_id because we need g_ilog to join to it
      if g_levels(i)=g_lowest_level_global then
        for j in 1..l_number_cols loop
          l_stmt:=l_stmt||g_levels(i)||'.'||l_cols(j)||',';
        end loop;
        l_stmt:=l_stmt||g_levels(i)||'.rowid row_id from '||g_snplogs_L(i)||','||
        g_levels(i)||' where '||g_levels(i)||'.rowid='||g_snplogs_L(i)||'.row_id';
      else
        for j in 1..l_number_cols loop
          l_stmt:=l_stmt||g_levels(i)||'.'||l_cols(j)||',';
        end loop;
        l_stmt:=substr(l_stmt,1,length(l_stmt)-1);
        l_stmt:=l_stmt||' from '||g_snplogs_L(i)||','||g_levels(i)||' where '||
        g_levels(i)||'.rowid='||g_snplogs_L(i)||'.row_id';
      end if;
      if g_debug then
        write_to_log_file_n('Going to execute '||l_stmt||get_time);
      end if;
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Created '||g_levels_copy(i)||' with '||sql%rowcount||' rows '||get_time);
      end if;
      commit;
      if g_levels(i)=g_lowest_level_global then
        null;
      else
        --create a unique index on the pk
        --we will need to create a unique index on all pks of the ltc table
        l_pk:=null;
        for j in 1..g_fk_pk_number loop
          if g_fk_pk_parent_level(j)=g_levels(i) then
            --we must not create a diff index on the same pk
            if l_pk is null or l_pk<>g_fk_pk_parent_pk(j) then
              l_stmt:='create unique index '||g_levels_copy(i)||'u'||j||' on '||
              g_levels_copy(i)||'('||g_fk_pk_parent_pk(j)||') tablespace '||g_op_table_space;
              if g_parallel is not null then
                l_stmt:=l_stmt||' parallel '||g_parallel;
              end if;
              if g_debug then
                write_to_log_file_n('Going to execute '||l_stmt||get_time);
              end if;
              execute immediate l_stmt;
              commit;
              l_pk:=g_fk_pk_parent_pk(j);
              if g_debug then
                write_to_log_file_n('Created unique index '||g_levels_copy(i)||'u'||j||' '||get_time);
              end if;
            end if;
          end if;
        end loop;
      end if;
      EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_levels_copy(i),instr(g_levels_copy(i),'.')+1,
      length(g_levels_copy(i))),substr(g_levels_copy(i),1,instr(g_levels_copy(i),'.')-1));
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

--drop all the L tables
function drop_L_tables return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In drop_L_tables');
  end if;
  for i in 1..g_number_levels loop
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_snplogs_L(i))=false then
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

function drop_I_tables return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In drop_I_tables');
  end if;
  for i in 1..g_number_levels loop
    if g_levels_I(i)<>g_levels(i) then
      if EDW_OWB_COLLECTION_UTIL.drop_table(g_levels_I(i))=false then
        null;
      end if;
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

--called from clean_up
function drop_ltc_copies return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In drop_ltc_copies');
  end if;
  for i in 1..g_number_levels loop
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_levels_copy(i))=false then
      null;
    end if;
  end loop;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_levels_copy_low_hd_ins)=false then
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
starting from the top, identify all the changes to the lowest level
*/
function drill_down_net_change(p_multi_thread boolean) return boolean is
l_index number;
Begin
  if g_debug then
    write_to_log_file_n('In drill_down_net_change');
  end if;
  --case 1: there is only one level
  --case 2: there is change to only the lowest level
  --case 3: there is change to any levels
  g_number_considered_parent:=0;
  if g_where_snplog_stmt is not null and g_number_levels>1 then
    for i in 1..g_number_levels loop
      l_index:=EDW_OWB_COLLECTION_UTIL.index_in_table(g_levels,g_number_levels,g_level_order(i));
      if g_consider_level(l_index) then
        if g_debug then
          write_to_log_file_n('Level '||g_level_order(i)||' has changed. Drill down net change');
        end if;
        if find_rowid_parent_change(g_level_order(i))=false then
          return false;
        end if;
      else
        if g_debug then
          write_to_log_file_n('Level '||g_level_order(i)||' has not changed. no need to drill down');
        end if;
      end if;
    end loop;
  end if;
  if insert_into_ilog_from_L(p_multi_thread)=false then
    return false;
  end if;
  if drop_L_tables=false then
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

/*
starting from the bottom, identify all the changes to the upper levels
*/
function drill_up_net_change(p_mode varchar2) return boolean is
l_index number;
Begin
  if g_debug then
    write_to_log_file_n('In drill_up_net_change mode='||p_mode);
  end if;
  if p_mode='SNP' then
    g_number_considered_parent:=0;
  else
    if g_debug then
      write_to_log_file_n('Considered parents');
      for i in 1..g_number_considered_parent loop
        write_to_log_file(g_considered_parent(i));
      end loop;
    end if;
  end if;
  if g_number_levels>1 then
    for i in 1..g_number_levels loop
      l_index:=EDW_OWB_COLLECTION_UTIL.index_in_table(g_levels,g_number_levels,
      g_level_order(g_number_levels+1-i));
      if p_mode='SNP' and g_consider_level(l_index) then
        if find_rowid_child_change(g_level_order(g_number_levels+1-i),p_mode)=false then
          return false;
        end if;
      elsif p_mode='NON-SNP' then
        if find_rowid_child_change(g_level_order(g_number_levels+1-i),p_mode)=false then
          return false;
        end if;
      else
        if g_debug then
          write_to_log_file_n('Level '||g_level_order(g_number_levels+1-i)||
          ' has no inc data to drill up');
        end if;
      end if;
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

/*recreate the from stmt and change the g_lowest_level and insert the new row_id into g_ilog*/
function recreate_from_stmt return boolean is
l_index number;
l_lowest_level varchar2(400);
Begin
  if g_debug then
    write_to_log_file_n('In recreate_from_stmt');
  end if;
  g_from_stmt_global:=g_from_stmt;
  g_from_stmt:=' from ';
  g_from_stmt_ins:=' from ';
  g_from_stmt_hd_row:=' from ';
  g_from_stmt_ins_row:=' from ';
  for i in 1..g_number_levels loop
    if g_consider_level(i) then
      g_from_stmt:=g_from_stmt||g_levels_copy(i)||' A_'||i||',';
    end if;
  end loop;
  g_from_stmt:=substr(g_from_stmt,1,length(g_from_stmt)-1);
  for i in 1..g_number_levels loop
    g_from_stmt_ins:=g_from_stmt_ins||g_levels_copy(i)||' A_'||i||',';
  end loop;
  g_from_stmt_ins:=substr(g_from_stmt_ins,1,length(g_from_stmt_ins)-1);--for insert stmt
  for i in 1..g_number_levels loop
    if g_levels(i)<>g_lowest_level then
      g_from_stmt_ins_row:=g_from_stmt_ins_row||g_levels_copy(i)||' A_'||i||',';
    else
      g_from_stmt_ins_row:=g_from_stmt_ins_row||g_levels_copy_low_hd_ins||' A_'||i||',';
    end if;
  end loop;
  g_from_stmt_ins_row:=substr(g_from_stmt_ins_row,1,length(g_from_stmt_ins_row)-1);--for insert stmt row by row
  for i in 1..g_number_levels loop
    if g_consider_level(i) then
      if g_levels(i)<>g_lowest_level then
        g_from_stmt_hd_row:=g_from_stmt_hd_row||g_levels_copy(i)||' A_'||i||',';
      else
        g_from_stmt_hd_row:=g_from_stmt_hd_row||g_levels_copy_low_hd_ins||' A_'||i||',';
      end if;
    end if;
  end loop;
  g_from_stmt_hd_row:=substr(g_from_stmt_hd_row,1,length(g_from_stmt_hd_row)-1);--for hold nested loop
  /*
  never must g_levels be changed!!
  */
  l_index:=EDW_OWB_COLLECTION_UTIL.index_in_table(g_levels,g_number_levels,g_lowest_level);
  if l_index>0 then
    g_lowest_level:=g_levels_copy(l_index);
  end if;
  if g_debug then
    write_to_log_file_n('The new g_from_stmt is ');
    write_to_log_file(g_from_stmt);
    write_to_log_file_n('The new g_from_stmt_ins is ');
    write_to_log_file(g_from_stmt_ins);
    write_to_log_file_n('The new g_from_stmt_hd_row is ');
    write_to_log_file(g_from_stmt_hd_row);
    write_to_log_file_n('The new g_lowest_level is '||g_lowest_level);
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in recreate_from_stmt '||g_status_message);
  g_status:=false;
  return false;
End;

procedure insert_into_ilog(p_multi_thread boolean) is
l_stmt varchar2(30000);
errbuf varchar2(2000);
retcode varchar2(400);
l_ilog_found boolean;
l_ilog_has_data boolean;
l_ilog_temp varchar2(400);
--
l_drill_down boolean;
--
Begin
  if g_debug then
    write_to_log_file_n('In insert_into_ilog');
  end if;
  if g_dim_empty_flag then
    --create the ilog
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_ilog) = false then
      write_to_log_file_n(g_ilog||' table not found for dropping');
    end if;
    --if create_ilog_table= false then
      --write_to_log_file_n('create_ilog_table returned with false');
      --return;
    --end if;
    begin
      /*
        if multi threading is true, we cannot make g_skip_ilog_update=true unless g_collection_size=0
      */
      if p_multi_thread=false or g_collection_size=0 then
        g_skip_ilog_update:=true;
      else
        g_skip_ilog_update:=false;
      end if;
      if g_parallel is not null then
        l_stmt:='create table '||g_ilog||' tablespace '||g_op_table_space||' parallel (degree '||g_parallel||') '||
        'as select /*+PARALLEL('||g_lowest_level||','||g_parallel||')*/ ';
        if g_collection_size>0 then
          if g_ll_snplog_has_pk then
            if p_multi_thread then
              l_stmt:=l_stmt||' rowid row_id,'||g_ltc_pk||',0 status, rownum row_num from '||
              g_lowest_level;
            else
              l_stmt:=l_stmt||' rowid row_id,'||g_ltc_pk||',decode(sign(rownum-'||g_collection_size||'),1,0,1) status from '||
              g_lowest_level;
            end if;
          else
            if p_multi_thread then
              l_stmt:=l_stmt||' rowid row_id,0 status, rownum row_num from '||g_lowest_level;
            else
              l_stmt:=l_stmt||' rowid row_id,decode(sign(rownum-'||g_collection_size||'),1,0,1) status from '||
              g_lowest_level;
            end if;
          end if;
        else
          if g_ll_snplog_has_pk then
            l_stmt:=l_stmt||' rowid row_id,'||g_ltc_pk||',1 status, rownum row_num from '||g_lowest_level;
          else
            l_stmt:=l_stmt||' rowid row_id,1 status,rownum row_num from '||g_lowest_level;
          end if;
        end if;
      else
        --l_stmt:='insert into '||g_ilog||'(row_id,status) select rowid,0 from '||g_lowest_level;
        l_stmt:='create table '||g_ilog||' tablespace '||g_op_table_space||' '||
        'as select ';
        if g_collection_size>0 then
          if g_ll_snplog_has_pk then
            if p_multi_thread then
              l_stmt:=l_stmt||' rowid row_id,'||g_ltc_pk||',0 status,rownum row_num from '||g_lowest_level;
            else
              l_stmt:=l_stmt||' rowid row_id,'||g_ltc_pk||
              ',decode(sign(rownum-'||g_collection_size||'),1,0,1) status from '||g_lowest_level;
            end if;
          else
            if p_multi_thread then
              l_stmt:=l_stmt||' rowid row_id,0 status, rownum row_num from '||g_lowest_level;
            else
              l_stmt:=l_stmt||' rowid row_id,decode(sign(rownum-'||
              g_collection_size||'),1,0,1) status from '||g_lowest_level;
            end if;
          end if;
        else
          if g_ll_snplog_has_pk then
            l_stmt:=l_stmt||' rowid row_id,'||g_ltc_pk||
            ',1 status, rownum row_num from '||g_lowest_level;
          else
            l_stmt:=l_stmt||' rowid row_id,1 status, rownum row_num from '||g_lowest_level;
          end if;
        end if;
      end if;
      if g_debug then
        write_to_log_file_n('Going to execute '||l_stmt);
      end if;
      --EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
      execute immediate l_stmt;
      if g_debug then
        write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
      end if;
      commit;
      if p_multi_thread then
        edw_owb_collection_util.create_rownum_index_ilog(g_ilog,g_op_table_space,g_parallel);
      end if;
      EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_ilog,instr(g_ilog,'.')+1,length(g_ilog)),
      substr(g_ilog,1,instr(g_ilog,'.')-1));
    exception when others then
      g_status_message:=sqlerrm;
      write_to_log_file_n(g_status_message);
      write_to_log_file('problem stmt '||l_stmt);
      g_status:=false;
      return;
    end;
    --at the end of this, we need to truncate the snapshot logs
    truncate_ltc_snapshot_logs;
    if set_level_I_flag=false then
      return;
    end if;
    return;
  end if;
  --here is when dim is not empty, ie incremental
  /*populate the ilog table and L tables. drill down net change will drop L tables*/
  if set_level_I_flag=false then
    return;
  end if;
  if create_ltc_ilog_table('SNP')=false then
    g_status:=false;
    return;
  end if;
  l_drill_down:=true;
  if g_parallel_drill_down then
    l_drill_down:=false;
    if g_debug then
      write_to_log_file_n('Parallel drill down TRUE');
    end if;
    if insert_L_ilog_parallel_dd(p_multi_thread)=false then
      l_drill_down:=true;
    end if;
  end if;
  if l_drill_down then
    if g_debug then
      write_to_log_file_n('Drilling down net change');
    end if;
    if drop_L_tables=false then
      g_status:=false;
      return;
    end if;
    if create_snp_L_tables=false then
      g_status:=false;
      return ;
    end if;
    if drill_down_net_change(p_multi_thread)=false then--populate  gilog and drop L tables
      g_status:=false;
      return;
    end if;
  end if;
  if g_level_change then
    if recreate_from_stmt=false then
      g_status:=false;
      return;
    end if;
  end if;
  --at the end of this, we need to truncate the snapshot logs
  truncate_ltc_snapshot_logs;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
End;

Procedure make_temp_insert_sql IS
Begin
if g_debug then
  write_to_log_file_n('In make_temp_insert_sql'||get_time);
end if;
--assume that there are proper levels here
g_temp_insert_stmt:='insert into '||g_dim_name_temp_int||' ( ';
g_temp_insert_stmt:=g_temp_insert_stmt||g_dim_pk||','||g_dim_user_pk||', row_id3 ';
if g_number_slow_cols > 0 then
  for i in 1..g_number_slow_cols loop
    g_temp_insert_stmt:=g_temp_insert_stmt||','||g_slow_cols(i);
  end loop;
end if;
if g_level_change then--we dont need reference to g_ilog
  g_temp_insert_stmt:=g_temp_insert_stmt||') select '||g_lowest_level_alias||'.'||g_ltc_pk||','
  ||g_lowest_level_alias||'.'||g_ltc_user_pk||','||g_lowest_level_alias||'.ROWID ';
  if g_number_slow_cols > 0 then
    for i in 1..g_number_slow_cols loop
      g_temp_insert_stmt:=g_temp_insert_stmt||','||g_slow_level_alias(i)||'.'||g_slow_level_col(i);
    end loop;
  end if;
  if g_number_slow_cols > 0 then
    if g_where_stmt is not null then
      g_temp_insert_stmt:=g_temp_insert_stmt||g_from_stmt||' '||g_where_stmt;
    else
      g_temp_insert_stmt:=g_temp_insert_stmt||g_from_stmt;
    end if;
  else
    --make it even faster
    g_temp_insert_stmt:=g_temp_insert_stmt||' from '||g_lowest_level||' '||g_lowest_level_alias;
  end if;
else
  g_temp_insert_stmt:=g_temp_insert_stmt||') select '||g_lowest_level_alias||'.'||g_ltc_pk||','
    ||g_lowest_level_alias||'.'||g_ltc_user_pk||','||g_lowest_level_alias||'.ROWID ';
  if g_number_slow_cols > 0 then
    for i in 1..g_number_slow_cols loop
      g_temp_insert_stmt:=g_temp_insert_stmt||','||g_slow_level_alias(i)||'.'||g_slow_level_col(i);
    end loop;
  end if;
  if g_number_slow_cols > 0 then
    if g_where_stmt is not null then
      g_temp_insert_stmt:=g_temp_insert_stmt||g_from_stmt||','||g_ilog||' '||g_where_stmt||' And ';
    else
      g_temp_insert_stmt:=g_temp_insert_stmt||g_from_stmt||','||g_ilog||' where ';
    end if;
    g_temp_insert_stmt:=g_temp_insert_stmt||g_ilog||'.row_id='||
    g_lowest_level_alias||'.rowid and '||g_ilog||'.status=1';
  else
    --make it even faster
    g_temp_insert_stmt:=g_temp_insert_stmt||' from '||g_lowest_level||' '||g_lowest_level_alias||','||g_ilog;
    g_temp_insert_stmt:=g_temp_insert_stmt||' where '||g_lowest_level_alias||'.rowid='||
    g_ilog||'.row_id and '||g_ilog||'.status=1';
  end if;
end if;

Exception when others then
 g_status:=false;
 g_status_message:=sqlerrm;
 write_to_log_file_n(g_status_message);
End;--Procedure make_temp_insert_sql

procedure analyze_snplogs is
Begin
  for i in 1..g_number_levels loop
    if g_consider_snapshot(i) then
      EDW_OWB_COLLECTION_UTIL.analyze_table_stats(g_level_snapshot_logs(i),g_table_owner);
    end if;
  end loop;
Exception when others then
 g_status:=false;
 g_status_message:=sqlerrm;
 write_to_log_file_n(g_status_message);
End;

function get_snapshot_log return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In get_snapshot_log');
  end if;
  for i in 1..g_number_levels loop
    --g_level_snapshot_logs(i):=EDW_OWB_COLLECTION_UTIL.get_table_snapshot_log(g_levels(i));
    g_consider_snapshot(i):=false;
  end loop;
  return true;
Exception when others then
 g_status:=false;
 g_status_message:=sqlerrm;
 write_to_log_file_n(g_status_message);
 return false;
End;

function check_snapshot_logs return boolean is
v_res number:=null;
l_consider boolean; --are all snapshot logs being considered?
begin
  if g_debug then
    write_to_log_file_n('In check_snapshot_logs'||get_time);
  end if;
  if EDW_OWB_COLLECTION_UTIL.check_table(g_ilog) then
    g_error_rec_flag:=true;
  elsif EDW_OWB_COLLECTION_UTIL.check_table(g_ilog||'A')=true then
    g_ilog:=g_ilog||'A';
    g_error_rec_flag:=true;
  end if;
  if g_fresh_restart then
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_ilog)=false then
      null;
    end if;
    g_error_rec_flag:=false;
  end if;
  l_consider:=false;
  for i in 1..g_number_levels loop
    v_res:=EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_level_snapshot_logs(i));
    if v_res=0 then
      if g_debug then
        write_to_log_file('Snapshot NOT FOUND!');
      end if;
      g_consider_snapshot(i):=false;
    elsif v_res=1 then
      if g_debug then
        write_to_log_file('Snapshot NOT considered');
      end if;
      g_consider_snapshot(i):=false;
    else
      if g_debug then
       write_to_log_file('Snapshot considered');
      end if;
      l_consider:=true;
      g_consider_snapshot(i):=true;
    end if;
  end loop;
  if l_consider=false then
    --check ilog also
    v_res:=EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_ilog);
    if v_res=2 then
      l_consider:=true;
    end if;
  end if;
  return l_consider;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;--Procedure check_snapshot_logs is

--insert into the int temp table g_dim_name_temp_int
Procedure execute_temp_insert_sql IS
l_count number;
Begin
if g_debug then
  write_to_log_file_n('In execute_temp_insert_sql');
end if;
if g_exec_flag = true  then
  if g_debug then
    write_to_log_file_n('Going to execute g_temp_insert_sql, inserting into table '||g_dim_name_temp_int);
  end if;
  EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
  execute immediate g_temp_insert_stmt;
  l_count:=sql%rowcount;
  commit;
  if g_debug then
    write_to_log_file_n('Inserted '||l_count||' records into '||g_dim_name_temp_int||get_time);
  end if;
  commit;
  if g_debug then
    write_to_log_file_n('commit');
  end if;
  --analyze the table
  if sql%rowcount > 0 then
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_dim_name_temp_int,instr(g_dim_name_temp_int,'.')+1,
    length(g_dim_name_temp_int)),substr(g_dim_name_temp_int,1,instr(g_dim_name_temp_int,'.')-1));
  end if;
  commit;
  if g_debug then
    write_to_log_file_n('commit');
  end if;
else
  write_to_log_file_n('In execute_temp_insert_sql exec flag found false');
end if;
Exception when others then
 g_status_message:=sqlerrm;
 write_to_log_file_n(g_status_message);
 write_to_log_file_n('Problem statement '||g_temp_insert_stmt);
 g_status:=false;
End;--Procedure execute_temp_insert_sql

PROCEDURE truncate_ltc_snapshot_logs IS
l_owner varchar2(400);
l_stmt varchar2(20000);
Begin
if g_debug then
  write_to_log_file_n('In truncate_ltc_snapshot_logs'||get_time);
end if;

for i in 1..g_number_levels loop
  if EDW_OWB_COLLECTION_UTIL.truncate_table(g_level_snapshot_logs(i),g_table_owner)=false then
    if g_debug then
      write_to_log_file_n(g_table_owner||' is not the owner for '||g_level_snapshot_logs(i));
    end if;
    l_owner:=null;
    l_owner:=EDW_OWB_COLLECTION_UTIL.get_table_owner(g_level_snapshot_logs(i));
    if g_debug then
      write_to_log_file_n('Owner is '||l_owner);
    end if;
    if l_owner is not null then
      if EDW_OWB_COLLECTION_UTIL.truncate_table(g_level_snapshot_logs(i),l_owner)=false then
        g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
        write_to_log_file_n(g_status_message);
        g_status:=false;
        return;
      end if;
    else
     g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
     write_to_log_file_n(g_status_message);
     g_status:=false;
     return;
    end if;
  end if;
end loop;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return;
End;--PROCEDURE truncate_ltc_snapshot_logs IS

procedure clean_up is
Begin
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dim_name_temp)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dim_name_temp_int)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_ilog)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_ilog_small)=false then
    null;
  end if;
  if g_ilog_prev is not null then
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_ilog_prev)=false then
      null;
    end if;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dim_name_hold)=false then
    null;
  end if;
 if EDW_OWB_COLLECTION_UTIL.drop_table(g_dim_kl_table)=false then
   null;
 end if;
 if EDW_OWB_COLLECTION_UTIL.drop_table(g_dim_name_with_slow)=false then
   null;
 end if;
 if EDW_OWB_COLLECTION_UTIL.drop_table(g_dim_kl_table_temp)=false then
   null;
 end if;
 if drop_ltc_copies=false then
   null;
 end if;
 if drop_I_tables=false then
   null;
 end if;
 for i in 1..g_number_objects_to_drop loop
   if EDW_OWB_COLLECTION_UTIL.drop_table(g_objects_to_drop(i))=false then
     null;
   end if;
 end loop;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
End;

/*
called by the jobs. global tables are not dropped
*/
procedure clean_up_job is
Begin
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dim_name_temp)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dim_name_temp_int)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_ilog)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_ilog_small)=false then
    null;
  end if;
  if g_ilog_prev is not null then
    if EDW_OWB_COLLECTION_UTIL.drop_table(g_ilog_prev)=false then
      null;
    end if;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_dim_name_hold)=false then
    null;
  end if;
 if EDW_OWB_COLLECTION_UTIL.drop_table(g_dim_kl_table)=false then
   null;
 end if;
 if EDW_OWB_COLLECTION_UTIL.drop_table(g_dim_kl_table_temp)=false then
   null;
 end if;
 if drop_ltc_copies=false then
   null;
 end if;
 for i in 1..g_number_objects_to_drop loop
   if EDW_OWB_COLLECTION_UTIL.drop_table(g_objects_to_drop(i))=false then
     null;
   end if;
 end loop;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
End;

function recover_from_previous_error return boolean is
l_stmt varchar2(4000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_res number:=null;
Begin
  if g_debug then
    write_to_log_file_n('In recover_from_previous_error');
  end if;
  l_stmt:='select nvl(sum(number_processed),0) from edw_coll_progress_log where object_name=:a and object_type=:b '||
    ' and status=:c';
  open cv for l_stmt using g_dim_name,g_object_type,'PROCESSING';
  fetch cv into l_res;
  close cv;
  if g_debug then
    write_to_log_file_n('The number of records collected from last run is '||l_res);
  end if;
  if l_res is not null then
    g_number_rows_processed:=g_number_rows_processed+l_res;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  return false;
End;

procedure init_all(p_job_id number) IS
l_dim_name varchar2(80);
l_dim_name_org varchar2(80);
begin
if p_job_id is null then
  l_dim_name:='TAB_'||g_dim_id||'_';
else
  l_dim_name:='TAB_'||g_dim_id||'_'||p_job_id||'_';
end if;
l_dim_name_org:='TAB_'||g_dim_id||'_';
g_slow_implemented:=false;--slowly changing dim not implemented by default
g_dim_empty_flag:=false;--assume that the star table is not empty
g_dim_name_temp:=g_bis_owner||'.'||l_dim_name||'TM';
g_dim_name_temp_int:=g_bis_owner||'.'||l_dim_name||'TI';--intermediate temp
g_dim_name_hold :=g_bis_owner||'.'||l_dim_name||'HD';
g_dim_name_rowid_hold:=g_bis_owner||'.'||l_dim_name||'HR';
g_all_level:=substr(g_dim_name,1,instr(g_dim_name,'_M',-1)-1)||'_A_LTC';
g_ilog:=g_bis_owner||'.'||l_dim_name||'IL';
g_ilog_small:=g_ilog||'S';
g_dim_kl_table:=g_bis_owner||'.'||l_dim_name||'KL';
g_dim_kl_table_temp:=g_bis_owner||'.'||l_dim_name||'KT';
g_insert_prot_table:=g_bis_owner||'.'||l_dim_name_org||'IP';--global only with slow change
g_insert_prot_table_active:=g_bis_owner||'.'||l_dim_name_org||'IPA';--used in this session
g_before_update_table_name:=g_bis_owner||'.'||l_dim_name_org||'BU';
g_number_before_update_table:=1;
g_bu_insert_prot_table:=g_bis_owner||'.'||l_dim_name_org||'BP';--global. used for derv fact sync
g_bu_insert_prot_table_active:=g_bis_owner||'.'||l_dim_name_org||'BPA';--global. used for derv fact sync
g_all_level_index:=-1;
g_status_message:=' ';
g_status:=true;
g_slow_is_name:='DIMENSION_HISTORY';
g_dim_name_with_slow:=g_bis_owner||'.'||l_dim_name||'SN';
g_insert_stmt_star:=null;
g_update_stmt_star:=null;
g_number_slow_cols:=0;
g_number_rows_inserted :=0;
g_number_rows_updated :=0;
g_number_rows_processed :=0;
g_level_change:=true;--if ltc copies are created, this is set to true (for inc collection)
g_dim_count:=0;
g_number_dim_derv_map_id:=0;
g_error_rec_flag:=false;
g_before_update_load_pk:=0;
g_type_ilog_generation:='CTAS';
g_skip_ilog_update:=false;
g_number_derv_fact_full_id:=0;
g_ll_snplog_has_pk:=false;
g_called_ltc_ilog_create:=false;
g_derv_snp_change_flag:=false;
if p_job_id is null then
  for i in 1..g_number_levels loop
    g_use_ltc_ilog(i):=true;
  end loop;
end if;
for i in 1..g_number_levels loop
  g_level_count(i):=null;
end loop;
g_big_table:=400000;--row count > g_big_table is a big table
g_number_objects_to_drop:=0;
g_dim_direct_load:=false;
End;--procedure init_all

function get_number_rows_inserted return number is
begin
  return g_number_rows_inserted;
End;--function get_number_rows_inserted return number is

function get_number_rows_updated return number is
begin
  return g_number_rows_updated;
End;--function get_number_rows_updated return number is


function get_time return varchar2 is
begin
 return '  '||to_char(sysdate,'MM/DD/YYYY HH24:MI:SS');
Exception when others then
  write_to_log_file_n('Exception in  get_time '||sqlerrm);
  return null;
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


function get_number_rows_processed return number is
begin
--g_number_rows_processed:=g_number_rows_inserted;
 return g_number_rows_processed;
Exception when others then
  write_to_log_file_n('Exception in  get_number_rows_processed '||sqlerrm||' '||get_time);
  return null;
End;

function reset_profiles return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In reset_profiles');
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
  EDW_OWB_COLLECTION_UTIL.insert_into_load_progress(p_load_fk,p_object_name,g_dim_id,p_load_progress,p_start_date,
  p_end_date,p_category,p_operation,p_seq_id,p_flag,1000);
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
    EDW_OWB_COLLECTION_UTIL.insert_into_load_progress(p_load_fk,p_object_name,g_dim_id,p_load_progress,p_start_date,
    p_end_date,p_category,p_operation,p_seq_id,p_flag,1000);
    commit;
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
End;

procedure analyze_star_table is
l_date date;
l_analyze boolean:=false;
l_diff number;
Begin
  if g_before_update_table_final is not null then
    if EDW_OWB_COLLECTION_UTIL.check_table(g_before_update_table_final) then
      EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_before_update_table_final,
      instr(g_before_update_table_final,'.')+1,length(g_before_update_table_final)),
      substr(g_before_update_table_final,1,instr(g_before_update_table_final,'.')-1),1);
    end if;
  end if;
  l_date:=EDW_OWB_COLLECTION_UTIL.last_analyzed_date(g_dim_name,g_table_owner);
  if g_debug then
    write_to_log_file_n('Last analyzed date for '||g_dim_name||' '||
    to_char(l_date,'MM-DD-YYYY HH24:MI:SS'));
  end if;
  if l_date is null or (sysdate-l_date)>=g_analyze_freq then
    insert_into_load_progress_d(g_load_pk,g_dim_name,'Analyze Star Table'||g_jobid_stmt,sysdate,null,'DIMENSION',
    'ANALYZE','AN2200'||g_job_id,'I');
    EDW_OWB_COLLECTION_UTIL.analyze_table_stats(g_dim_name,g_table_owner,1);
    if g_debug then
      write_to_log_file_n('Table '||g_dim_name||' analyzed');
    end if;
    commit;
    insert_into_load_progress_d(g_load_pk,null,null,null,sysdate,null,null,'AN2200'||g_job_id,'U');
  end if;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
End;

function get_dim_storage return boolean is
Begin
  if EDW_OWB_COLLECTION_UTIL.get_table_next_extent(g_dim_name,g_table_owner,g_dim_next_extent)=false then
    return false;
  end if;
  if g_dim_next_extent is null or g_dim_next_extent=0 then
    g_dim_next_extent:=16777216;
  end if;
  return true;
Exception when others then
  write_to_log_file_n('Error in get_dim_storage '||sqlerrm||get_time);
  return false;
End;

function is_dim_in_derv_map return boolean is
l_dim_fk EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_dim_fk number;
Begin
  g_derv_snp_change_flag:=false;
  if EDW_OWB_COLLECTION_UTIL.get_mapid_dim_in_derv_map(g_dim_name,g_dim_derv_map_id,
    g_derv_fact_id,g_src_fact_id,g_number_dim_derv_map_id,'INC')=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    return false;
  end if;
  for i in 1..g_number_dim_derv_map_id loop
    g_dim_derv_map_refresh(i):=true;--by default assume that all maps need to be refreshed
    g_dim_derv_map_full_refresh(i):=true;--by default, full refresh of the derv fact from this src fact
  end loop;
  if g_debug then
    write_to_log_file_n('Derv/Summary map ids where '||g_dim_name||' is a sec source');
    for i in 1..g_number_dim_derv_map_id loop
      write_to_log_file(g_dim_derv_map_id(i));
    end loop;
  end if;
  if g_number_dim_derv_map_id=0 then
    return true;
  end if;
  g_number_dim_derv_col:=0;
  g_number_dim_derv_pk_key:=0;
  g_num_dim_derv_col_map_all:=0;
  for i in 1..g_number_dim_derv_map_id loop
    l_number_dim_fk:=0;
    if EDW_OWB_COLLECTION_UTIL.get_dim_fk_summary_fact(g_derv_fact_id(i),g_dim_id,l_dim_fk,l_number_dim_fk)=false then
      g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
      return false;
    end if;
    for j in 1..l_number_dim_fk loop
      if EDW_OWB_COLLECTION_UTIL.value_in_table(g_dim_derv_pk_key,g_number_dim_derv_pk_key,l_dim_fk(j))=false then
        g_number_dim_derv_pk_key:=g_number_dim_derv_pk_key+1;
        g_dim_derv_pk_key(g_number_dim_derv_pk_key):=l_dim_fk(j);
      end if;
    end loop;
  end loop;
  if g_debug then
    write_to_log_file_n('The higher level PK_KEY of the dimension involved in derv maps');
    for i in 1..g_number_dim_derv_pk_key loop
      write_to_log_file(g_dim_derv_pk_key(i));
    end loop;
  end if;
  for i in 1..g_number_dim_derv_map_id loop
    if get_derv_fact_map_details(g_dim_derv_map_id(i)) = false then
      return false;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('The columns of the dimension involved in derv maps and ltc tables');
    for i in 1..g_number_dim_derv_col loop
      write_to_log_file(g_dim_derv_col(i)||'  '||g_dim_derv_col_ltc(i));
    end loop;
  end if;
  for i in 1..g_number_dim_derv_col loop
    if g_dim_derv_col_ltc(i) is null then
      g_derv_snp_change_flag:=true;
      exit;
    end if;
    for j in 1..g_number_levels loop
      if g_dim_derv_col_ltc(i)=g_levels(j) then
        if g_consider_snapshot(j) then
          g_derv_snp_change_flag:=true;
          exit;
        end if;
      end if;
    end loop;
    if g_derv_snp_change_flag then
      exit;
    end if;
  end loop;
  if g_debug then
    if g_derv_snp_change_flag then
      write_to_log_file_n('There is snapshot change to consider for derived fact');
    else
      write_to_log_file_n('There is NO snapshot change to consider for derived fact');
    end if;
  end if;
  if g_derv_snp_change_flag then
    for i in 1..g_number_dim_derv_map_id loop
      if EDW_OWB_COLLECTION_UTIL.value_in_table(g_dim_derv_col_map_all,g_num_dim_derv_col_map_all,
      g_dim_derv_map_id(i))=false then
        g_dim_derv_map_refresh(i):=false;
      end if;
    end loop;
  end if;
  --for each of the maps, check the src fact fk density
  for i in 1..g_number_dim_derv_map_id loop
    if g_dim_derv_map_refresh(i) then
      if get_max_fk_density(g_dim_id,g_src_fact_id(i),g_dim_derv_map_id(i))<=g_max_fk_density then
        g_dim_derv_map_full_refresh(i):=false;
      end if;
    end if;
  end loop;
  write_to_log_file_n('The Derv/Summary maps that need to be refreshed');
  if g_debug then
    for i in 1..g_number_dim_derv_map_id loop
      if g_dim_derv_map_refresh(i) then
        if g_dim_derv_map_full_refresh(i) then
          write_to_log_file(g_dim_derv_map_id(i)||'(Full Refresh with the src fact)');
        else
          write_to_log_file(g_dim_derv_map_id(i)||'(INC Refresh with the src fact)');
        end if;
      else
        write_to_log_file(g_dim_derv_map_id(i)||' NO Refresh Needed');
      end if;
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function get_derv_fact_map_details(p_mapping_id number) return boolean is
l_hold_func EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_hold_func_category EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_hold_item EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_hold_item_id EDW_OWB_COLLECTION_UTIL.numberTableType;
l_hold_item_usage EDW_OWB_COLLECTION_UTIL.numberTableType;
l_hold_aggregatefunction EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_hold_is_distinct EDW_OWB_COLLECTION_UTIL.numberTableType;
l_hold_relation EDW_OWB_COLLECTION_UTIL.numberTableType;
l_hold_relation_name EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_hold_relation_usage EDW_OWB_COLLECTION_UTIL.numberTableType;
l_hold_relation_type EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_hold_func_usage  EDW_OWB_COLLECTION_UTIL.numberTableType;
l_hold_func_position  EDW_OWB_COLLECTION_UTIL.numberTableType;
l_hold_func_dvalue  EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_hold_number  number;
l_stmt varchar2(2000);
l_filter_stmt varchar2(20000);
l_sec_source  EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_sec_source_id  EDW_OWB_COLLECTION_UTIL.numberTableType;
l_sec_source_child  EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_sec_source_child_id  EDW_OWB_COLLECTION_UTIL.numberTableType;
l_pk   EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_fk   EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_sec_source_usage  EDW_OWB_COLLECTION_UTIL.numberTableType;
l_sec_source_usage_name  EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_sec_source_child_usage  EDW_OWB_COLLECTION_UTIL.numberTableType;
l_sec_source_number  number;
l_sec_sources_child_alias  EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_sec_source_name_index  EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_sec_source_index  EDW_OWB_COLLECTION_UTIL.numberTableType;
l_sec_source_index_number number;
l_start number;
l_end number;
l_len number;
l_col varchar2(400);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_metadata_version varchar2(80);
Begin
  l_metadata_version:=EDW_OWB_COLLECTION_UTIL.get_metadata_version;
  if EDW_OWB_COLLECTION_UTIL.get_mapping_details(
     p_mapping_id
    ,l_hold_func
    ,l_hold_func_category
    ,l_hold_item
    ,l_hold_item_id
    ,l_hold_item_usage
    ,l_hold_aggregatefunction
    ,l_hold_is_distinct
    ,l_hold_relation
    ,l_hold_relation_name
    ,l_hold_relation_usage
    ,l_hold_relation_type
    ,l_hold_func_usage
    ,l_hold_func_position
    ,l_hold_func_dvalue
    ,l_hold_number
    ,l_metadata_version)=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    return false;
  end if;
  for i in 1..l_hold_number loop
    if l_hold_relation_name(i)=g_dim_name then
      g_num_dim_derv_col_map_all:=g_num_dim_derv_col_map_all+1;
      g_dim_derv_col_map_all(g_num_dim_derv_col_map_all):=p_mapping_id;
      if EDW_OWB_COLLECTION_UTIL.value_in_table(g_dim_derv_col,g_number_dim_derv_col,l_hold_item(i))=false then
        g_number_dim_derv_col:=g_number_dim_derv_col+1;
        g_dim_derv_col(g_number_dim_derv_col):=l_hold_item(i);
        g_dim_derv_col_map(g_number_dim_derv_col):=p_mapping_id;
      end if;
    end if;
  end loop;
  if EDW_OWB_COLLECTION_UTIL.get_sec_source_info(
    p_mapping_id,
    l_sec_source,
    l_sec_source_id ,
    l_sec_source_child ,
    l_sec_source_child_id,
    l_pk,
    l_fk,
    l_sec_source_usage,
    l_sec_source_usage_name,
    l_sec_source_child_usage,
    l_sec_source_number) = false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    return false;
  end if;
  --also look at the filter clause
  --not checked
  l_stmt:='select text from edw_pvt_map_properties_md_v where mapping_id=:a and text_type=''Filter''';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||' using '||p_mapping_id);
  end if;
  open cv for l_stmt using p_mapping_id;
  fetch cv into l_filter_stmt;
  close cv;
  if g_debug then
    write_to_log_file_n('l_filter_stmt='||l_filter_stmt);
  end if;
  if l_filter_stmt is not null then
    l_len:=length(l_filter_stmt);
    for i in 1..l_sec_source_number loop
      if l_sec_source(i)=g_dim_name then
        l_start:=1;
        l_end:=1;
        loop
          l_end:=instr(l_filter_stmt,l_sec_source_usage_name(i)||'.',l_start);
          if l_end=0 then
            exit;
          end if;
          l_start:=l_end+length(l_sec_source_usage_name(i)||'.');
          l_end:=instr(l_filter_stmt,' ',l_start);
          if l_end=0 then
            exit;
          end if;
          l_col:=substr(l_filter_stmt,l_start,(l_end-l_start));
          if g_debug then
            write_to_log_file_n('Coulmn from filter for '||l_sec_source_usage_name(i)||' '||l_col);
          end if;
          g_num_dim_derv_col_map_all:=g_num_dim_derv_col_map_all+1;
          g_dim_derv_col_map_all(g_num_dim_derv_col_map_all):=p_mapping_id;
          if EDW_OWB_COLLECTION_UTIL.value_in_table(g_dim_derv_col,g_number_dim_derv_col,l_col)=false then
            g_number_dim_derv_col:=g_number_dim_derv_col+1;
            g_dim_derv_col(g_number_dim_derv_col):=l_col;
            g_dim_derv_col_map(g_number_dim_derv_col):=p_mapping_id;
          end if;
          l_start:=l_end;
        end loop;
      end if;
    end loop;
  end if;

  --get the level also with the columns and see if any snapshot log has changed
  for i in 1..g_number_dim_derv_col loop
    g_dim_derv_col_ltc(i):=get_ltc_for_dim_col(g_dim_derv_col(i));
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function get_before_update_table_name return boolean is
Begin
  g_number_before_update_table:=1;
  loop
    g_before_update_table(g_number_before_update_table):=g_before_update_table_name||g_number_before_update_table;
    if EDW_OWB_COLLECTION_UTIL.check_table(g_before_update_table(g_number_before_update_table))=false then
      g_before_update_table_final:=g_before_update_table(g_number_before_update_table);
      exit;
    else
      g_number_before_update_table:=g_number_before_update_table+1;
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in get_before_update_table_name '||g_status_message);
  g_status:=false;
  return false;
End;

/*
log_before_update_data is called in each loop. we will analyze the table in the very end
*/
function log_before_update_data return boolean is
l_stmt varchar2(32000);
--l_pk_table varchar2(200);
--l_rowid_table varchar2(200);
--l_count number;
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
Begin
  if g_debug then
    write_to_log_file_n('In log_before_update_data'||get_time);
  end if;
  /*
  for every run of the load, the update data goes into a new table
  */
  if EDW_OWB_COLLECTION_UTIL.check_table(g_before_update_table_final)=false then
    if create_before_update_table=false then
      return false;
    end if;
  end if;
  l_stmt:='insert into '||g_before_update_table_final||'('||g_dim_pk||','||g_dim_user_pk;
  for i in 1..g_number_dim_derv_col loop
    l_stmt:=l_stmt||','||g_dim_derv_col(i);
  end loop;
  for i in 1..g_number_dim_derv_pk_key loop
    if EDW_OWB_COLLECTION_UTIL.value_in_table(g_dim_derv_col,g_number_dim_derv_col,g_dim_derv_pk_key(i))=false then
      l_stmt:=l_stmt||','||g_dim_derv_pk_key(i);
    end if;
  end loop;
  l_stmt:=l_stmt||',LAST_UPDATE_DATE) select /*+ORDERED USE_NL('||g_dim_name||')*/ '; --use nl?
  if g_parallel is not null then
    l_stmt:=l_stmt||'/*+PARALLEL('||g_dim_name||','||g_parallel||')*/ ';
  end if;
  l_stmt:=l_stmt||g_dim_name||'.'||g_dim_pk||','||g_dim_name||'.'||g_dim_user_pk;
  for i in 1..g_number_dim_derv_col loop
    l_stmt:=l_stmt||','||g_dim_name||'.'||g_dim_derv_col(i);
  end loop;
  for i in 1..g_number_dim_derv_pk_key loop
    if EDW_OWB_COLLECTION_UTIL.value_in_table(g_dim_derv_col,g_number_dim_derv_col,g_dim_derv_pk_key(i))=false then
      l_stmt:=l_stmt||','||g_dim_name||'.'||g_dim_derv_pk_key(i);
    end if;
  end loop;
  l_stmt:=l_stmt||',SYSDATE from '||g_dim_name_hold||','||g_dim_name||
  ' where '||g_dim_name_hold||'.row_id='||g_dim_name||'.rowid'||
  ' and '||g_dim_name_hold||'.'||g_dim_pk||' not in (select '||g_dim_pk||' from '||g_bu_insert_prot_table_active||')';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Inserted '||sql%rowcount||' rows into '||
    g_before_update_table_final||get_time);
  end if;
  if log_pk_into_bu_insert_prot=false then
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function create_before_update_table return boolean is
l_stmt varchar2(10000);
l_next_extent number;
Begin
  l_next_extent:=g_dim_next_extent/2;
  if l_next_extent>16777216 then --16M
    l_next_extent:=16777216;
  end if;
  if l_next_extent is null or l_next_extent=0 then
    l_next_extent:=8388608;
  end if;
  l_stmt:='create table '||g_before_update_table_final||' tablespace '||g_op_table_space||
  ' storage (initial '||l_next_extent||' next '||l_next_extent||' pctincrease 0 MAXEXTENTS 2147483645) ';
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||' as select '||g_dim_pk||','||g_dim_user_pk;
  for i in 1..g_number_dim_derv_col loop
    l_stmt:=l_stmt||','||g_dim_derv_col(i);
  end loop;
  for i in 1..g_number_dim_derv_pk_key loop
    if EDW_OWB_COLLECTION_UTIL.value_in_table(g_dim_derv_col,g_number_dim_derv_col,g_dim_derv_pk_key(i))=false then
      l_stmt:=l_stmt||','||g_dim_derv_pk_key(i);
    end if;
  end loop;
  l_stmt:=l_stmt||',LAST_UPDATE_DATE from '||g_dim_name||' where 1=2';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  begin
    execute immediate l_stmt;
  exception when others then
    if sqlcode=-00955 then
      --only here in case of multi threading
      if g_debug then
        write_to_log_file_n('Error creating '||g_before_update_table_final||' '||sqlerrm||get_time);
        write_to_log_file('This table '||g_before_update_table_final||' already exists! '||
        'Some other thread created it!');
      end if;
    else
      g_status_message:=sqlerrm;
      write_to_log_file_n(g_status_message);
      g_status:=false;
      return false;
    end if;
  end;
  l_stmt:='create unique index '||g_before_update_table_final||'u on '||
  g_before_update_table_final||'('||g_dim_pk||') tablespace '||g_op_table_space;
  --||' storage (initial '||l_next_extent/2||' next '||l_next_extent/2||' pctincrease 0 MAXEXTENTS 2147483645)';
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel '||g_parallel;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt);
  end if;
  execute immediate l_stmt;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function get_ltc_for_dim_col(p_col varchar2) return varchar2 is
l_stmt varchar2(1000);
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_prefix varchar2(200);
l_ltc varchar2(400);
Begin
  l_prefix:=substr(p_col,1,instr(p_col,'_')-1);
  l_stmt:='select level_name||''_LTC'' from edw_levels_md_v where level_prefix=:a and dim_id=:b';
  open cv for l_stmt using l_prefix,g_dim_id;
  fetch cv into l_ltc;
  close cv;
  return l_ltc;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return null;
End;

function get_max_fk_density(p_dim_id number,p_src_fact_id number,p_dim_derv_map_id number) return number is
l_fk EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_pk EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_fk number;
l_distcnt number;
l_density number;
l_nullcnt  number;
l_srec  DBMS_STATS.StatRec;
l_avgclen  number;
l_tot_density number;
l_fact_name varchar2(400);
l_owner varchar2(400);
Begin
  if EDW_OWB_COLLECTION_UTIL.get_fk_pk(p_src_fact_id,p_dim_id,p_dim_derv_map_id,l_fk,l_pk,l_number_fk)=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    g_status:=false;
    return null;
  end if;
  if g_debug then
    write_to_log_file_n('The fk and pk found for src fact '||p_src_fact_id||' with dim '||p_dim_id);
    for i in 1..l_number_fk loop
      write_to_log_file(l_fk(i)||'('||l_pk(i)||')');
    end loop;
  end if;
  --get the stats
  l_tot_density:=0;
  if g_debug then
    write_to_log_file_n('The fk and density');
  end if;
  for i in 1..l_number_fk loop
    l_fact_name:=EDW_OWB_COLLECTION_UTIL.get_object_name(p_src_fact_id);
    l_owner:=EDW_OWB_COLLECTION_UTIL.get_table_owner(l_fact_name);
    if EDW_OWB_COLLECTION_UTIL.get_column_stats(
      l_owner,
      l_fact_name,
      l_fk(i),
      l_distcnt,
      l_density,
      l_nullcnt,
      l_srec,
      l_avgclen)=false then
      null;
    end if;
    if g_debug then
      write_to_log_file(l_fk(i)||'('||l_density*100||')');
    end if;
    if l_tot_density<l_density then
      l_tot_density:=l_density;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('Max density='||l_tot_density*100);
  end if;
  return l_tot_density*100;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return null;
End;

function create_prot_table(p_table varchar2,p_table_active varchar2) return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In create_prot_table '||get_time);
  end if;
  if EDW_OWB_COLLECTION_UTIL.check_table(p_table)=false then
    g_stmt:='create table '||p_table||' tablespace '||g_op_table_space;
    if g_parallel is not null then
      g_stmt:=g_stmt||' parallel (degree '||g_parallel||') ';
    end if;
    g_stmt:=g_stmt||' as select '||g_dim_pk||' from '||g_dim_name||' where 1=2';
    if g_debug then
      write_to_log_file_n('Going to execute '||g_stmt);
    end if;
    execute immediate g_stmt;
  end if;
  g_stmt:='create table '||p_table_active||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    g_stmt:=g_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  g_stmt:=g_stmt||' as select * from '||p_table;
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_table_active)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n('Going to execute '||g_stmt);
  end if;
  execute immediate g_stmt;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function drop_prot_table(p_table varchar2,p_table_active varchar2) return boolean is
l_stmt varchar2(1000);
Begin
  if g_debug then
    write_to_log_file_n('In drop_prot_table ');
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_table)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_table_active)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function drop_restart_tables return boolean is
l_count number:=1;
Begin
  if g_debug then
    write_to_log_file_n('In drop_restart_tables');
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_ilog)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_ilog_tables(g_ilog,'IL',g_bis_owner)=false then
    null;
  end if;
  loop
    if EDW_OWB_COLLECTION_UTIL.check_table(g_before_update_table_name||l_count) then
      if EDW_OWB_COLLECTION_UTIL.drop_table(g_before_update_table_name||l_count)=false then
        null;
      end if;
      l_count:=l_count+1;
    else
      exit;
    end if;
  end loop;
  if drop_prot_table(g_insert_prot_table,g_insert_prot_table_active)=false then
    null;
  end if;
  if drop_prot_table(g_bu_insert_prot_table,g_bu_insert_prot_table_active)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function create_gilog_small return boolean is
l_stmt varchar2(4000);
Begin
  l_stmt:='create table '||g_ilog_small||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  as select row_id from '||g_ilog||' where status=1';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_ilog_small)=false then
    null;
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_ilog_small,instr(g_ilog_small,'.')+1,
  length(g_ilog_small)),substr(g_ilog_small,1,instr(g_ilog_small,'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  g_status:=false;
  return false;
End;

function create_dummy_ilog return boolean is
l_stmt varchar2(5000);
Begin
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_ilog)=false then
    null;
  end if;
  l_stmt:='create table '||g_ilog||' tablespace '||g_op_table_space||
  ' as select rowid row_id, 1 status from dual ';
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  g_skip_ilog_update:=true;
  g_type_ilog_generation:='UPDATE';
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function check_ll_snplog_col return number is
Begin
  if g_debug then
    write_to_log_file_n('In check_ll_snplog_col');
  end if;
  for i in 1..g_number_levels loop
    if g_levels(i)=g_lowest_level_global then
      if EDW_OWB_COLLECTION_UTIL.is_column_in_table(g_level_snapshot_logs(i),g_ltc_pk,g_table_owner) then
        g_ll_snplog_has_pk:=true;
        if g_debug then
          write_to_log_file_n('g_ll_snplog_has_pk set to TRUE');
        end if;
        return 1;
      end if;
    end if;
  end loop;
  if g_debug then
    write_to_log_file_n('g_ll_snplog_has_pk set to FALSE');
  end if;
  return 0;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return -1;
End;

function set_level_I_flag return boolean is
l_count number;
l_flag boolean;
l_avg_row_len number;
l_number_fk number;
l_byte_size number;
l_size number;
Begin
  if g_debug then
    write_to_log_file_n('In set_level_I_flag');
  end if;
  l_byte_size:=8;
  for i in 1..g_number_levels loop
    if EDW_OWB_COLLECTION_UTIL.get_table_avg_row_len(g_levels(i),g_table_owner,l_avg_row_len) then
      if g_debug then
        write_to_log_file_n('Level '||g_levels(i)||' avg_row_len='||l_avg_row_len);
      end if;
      if l_avg_row_len is not null and l_avg_row_len>0 then
        l_number_fk:=0;
        for j in 1..g_fk_pk_number loop
          if g_fk_pk_child_level(j)=g_levels(i) then
            l_number_fk:=l_number_fk+1;
          end if;
        end loop;
        l_size:=l_byte_size*(l_number_fk+2);
        l_flag:=EDW_OWB_COLLECTION_UTIL.get_join_nl(l_size,l_avg_row_len,g_ok_switch_update);
        if l_flag then
          g_use_ltc_ilog(i):=true;
        else
          g_use_ltc_ilog(i):=false;
        end if;
      else
        g_use_ltc_ilog(i):=false;
      end if;
    else
      g_use_ltc_ilog(i):=false;
    end if;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n(g_status_message);
  return false;
End;

function create_ltc_copy_low_hd_ins(p_mode varchar2) return boolean is
l_stmt varchar2(5000);
l_mode number;
Begin
  if g_debug then
    write_to_log_file_n('In create_ltc_copy_low_hd_ins mode '||p_mode);
  end if;
  if p_mode='INSERT' then
    l_mode:=0;
  elsif p_mode='UPDATE' then
    l_mode:=1;
  else
    l_mode:=2;
  end if;
  l_stmt:='create table '||g_levels_copy_low_hd_ins||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  as select A.*,B.'||g_dim_pk||',B.'||g_dim_user_pk||',B.ROW_ID1 row_id1 from '||
  g_lowest_level||' A,'||g_dim_name_temp||' B where A.rowid=B.row_id3 and B.operation_code1='||l_mode;
  if g_debug then
    write_to_log_file_n('Going to execute '||l_stmt||get_time);
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(g_levels_copy_low_hd_ins)=false then
    null;
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(g_levels_copy_low_hd_ins,instr(g_levels_copy_low_hd_ins,'.')+1,
  length(g_levels_copy_low_hd_ins)),substr(g_levels_copy_low_hd_ins,1,instr(g_levels_copy_low_hd_ins,'.')-1));
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  return false;
End;

function create_hold_table return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In create_hold_table');
  end if;
  if g_debug then
    write_to_log_file_n('Goin to execute '||g_hold_insert_stmt||' and 1=2');
  end if;
  execute immediate g_hold_insert_stmt||' and 1=2';
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n(g_status_message);
  return false;
End;

--if insert into dim tables fails due to unique cons violation, we try and reset the op codes of the temp table
--g_dim_name_temp.
function reset_temp_opcode return boolean is
l_stmt varchar2(20000);
l_table1 varchar2(200);
l_table2 varchar2(200);
Begin
  if g_debug then
    write_to_log_file_n('In reset_temp_opcode');
  end if;
  l_table1:=g_dim_name_temp||'1';
  l_table2:=g_dim_name_temp||'2';
  l_stmt:='create table '||l_table1||' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  as select '||g_dim_pk||' from '||g_dim_name_temp||
  ' where operation_code1=0';
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
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_table1,instr(l_table1,'.')+1,
  length(l_table1)),substr(l_table1,1,instr(l_table1,'.')-1));
  --4161164 : remove IOT , replace with ordinary table and index
  --l_stmt:='create table '||l_table2||'('||g_dim_pk||' primary key,row_id) organization index '||
  l_stmt:='create table '||l_table2||
  ' tablespace '||g_op_table_space;
  if g_parallel is not null then
    l_stmt:=l_stmt||' parallel (degree '||g_parallel||') ';
  end if;
  l_stmt:=l_stmt||'  as select ';
  if g_parallel is not null then
    l_stmt:=l_stmt||' /*+parallel(B,'||g_parallel||')*/ ';
  end if;
  l_stmt:=l_stmt||'A.'||g_dim_pk||',B.rowid row_id from '||l_table1||' A,'||
  g_dim_name||' B where A.'||g_dim_pk||'=B.'||g_dim_pk;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table2)=false then
    null;
  end if;
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Created with '||sql%rowcount||' rows '||get_time);
--4161164 : remove IOT , replace with ordinary table and index
  EDW_OWB_COLLECTION_UTIL.create_iot_index(l_table2,g_dim_pk,g_op_table_space,g_parallel);  end if;
  EDW_OWB_COLLECTION_UTIL.analyze_table_stats(substr(l_table2,instr(l_table2,'.')+1,
  length(l_table2)),substr(l_table2,1,instr(l_table2,'.')-1));
  l_stmt:='update /*+ordered use_nl(AA)*/ '||g_dim_name_temp||' AA set(row_id1,operation_code1)=(select row_id,'||
  '1 from '||l_table2||' where '||l_table2||'.'||g_dim_pk||'=AA.'||g_dim_pk||') where AA.'||g_dim_pk||
  ' in (select '||g_dim_pk||' from '||l_table2||') ';
  if g_debug then
    write_to_log_file_n(l_stmt||get_time);
  end if;
  EDW_OWB_COLLECTION_UTIL.set_rollback(g_rollback);
  execute immediate l_stmt;
  if g_debug then
    write_to_log_file_n('Updated '||sql%rowcount||' rows '||get_time);
  end if;
  commit;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table1)=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(l_table2)=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  g_status:=false;
  write_to_log_file_n('error in reset_temp_opcode '||g_status_message);
  return false;
End;

function find_all_affected_levels(
p_job_id number,
p_affected_levels out NOCOPY EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_number_affected_levels out NOCOPY number) return boolean is
l_hier EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_parent_ltc EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_parent_ltc_id  EDW_OWB_COLLECTION_UTIL.numberTableType;
l_child_ltc EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_child_ltc_id  EDW_OWB_COLLECTION_UTIL.numberTableType;
l_number_hier number;
l_parent_flat EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_child_flat EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_flat number;
l_children EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_children number;
l_table varchar2(200);
Begin
  if g_debug then
    write_to_log_file_n('In find_all_affected_levels '||get_time);
  end if;
  p_number_affected_levels:=0;
  if EDW_OWB_COLLECTION_UTIL.get_dim_hier_levels(g_dim_name,l_hier,l_parent_ltc,l_parent_ltc_id,
    l_child_ltc,l_child_ltc_id,l_number_hier)=false then
    g_status_message:=EDW_OWB_COLLECTION_UTIL.g_status_message;
    return false;
  end if;
  if g_debug then
    write_to_log_file_n('The hier and levels');
    for i in 1..l_number_hier loop
      write_to_log_file(l_hier(i)||' '||l_parent_ltc(i)||'('||l_parent_ltc_id(i)||') '||l_child_ltc(i)||'('||
      l_child_ltc_id(i)||')');
    end loop;
  end if;
  --find all the tables that fk change and get all the parent for it
  l_number_flat:=0;
  for i in 1..g_number_levels loop
    if get_parent(g_levels(i),l_parent_ltc,l_child_ltc,l_number_hier,l_children,l_number_children)=false then
      return false;
    end if;
    for j in 1..l_number_children loop
      if EDW_OWB_COLLECTION_UTIL.value_in_table(l_parent_flat,l_child_flat,l_number_flat,l_children(j),
        g_levels(i))=false then
        l_number_flat:=l_number_flat+1;
        l_parent_flat(l_number_flat):=l_children(j);
        l_child_flat(l_number_flat):=g_levels(i);
      end if;
    end loop;
  end loop;
  if g_debug then
    write_to_log_file_n('The flat hierarchy');
    for i in 1..l_number_flat loop
      write_to_log_file(l_child_flat(i)||'  '||l_parent_flat(i));
    end loop;
  end if;
  --check for tables
  for i in 1..g_number_levels loop
    for j in 1..l_number_hier loop
      if l_child_ltc(j)=g_levels(i) then
        if p_job_id is null then
          l_table:=g_bis_owner||'.LTFC_'||l_child_ltc_id(j)||'_'||l_parent_ltc_id(j);
        else
          l_table:=g_bis_owner||'.LTFC_'||l_child_ltc_id(j)||'_'||l_parent_ltc_id(j)||'_'||p_job_id;
        end if;
        if EDW_OWB_COLLECTION_UTIL.check_table(l_table) then
          g_number_objects_to_drop:=g_number_objects_to_drop+1;
          g_objects_to_drop(g_number_objects_to_drop):=l_table;
          if EDW_OWB_COLLECTION_UTIL.value_in_table(p_affected_levels,p_number_affected_levels,
            l_parent_ltc(j))=false then
            p_number_affected_levels:=p_number_affected_levels+1;
            p_affected_levels(p_number_affected_levels):=l_parent_ltc(j);
          end if;
          for k in 1..l_number_flat loop
            if l_child_flat(k)=l_parent_ltc(j) then
              if EDW_OWB_COLLECTION_UTIL.value_in_table(p_affected_levels,p_number_affected_levels,
                l_parent_flat(k))=false then
                p_number_affected_levels:=p_number_affected_levels+1;
                p_affected_levels(p_number_affected_levels):=l_parent_flat(k);
              end if;
            end if;
          end loop;
        end if;
      end if;
    end loop;
  end loop;
  if g_debug then
    write_to_log_file_n('Additional levels to be considered');
    for i in 1..p_number_affected_levels loop
      write_to_log_file(p_affected_levels(i));
    end loop;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('error in find_all_affected_levels '||g_status_message);
  return false;
End;

function get_parent(p_child_level varchar2,p_parent_ltc EDW_OWB_COLLECTION_UTIL.varcharTableType,
p_child_ltc EDW_OWB_COLLECTION_UTIL.varcharTableType, p_number_hier number,
p_parent out NOCOPY EDW_OWB_COLLECTION_UTIL.varcharTableType, p_number_parent out NOCOPY number) return boolean is
loop_end number;
l_parent EDW_OWB_COLLECTION_UTIL.varcharTableType;
l_number_parent number;
Begin
  p_number_parent:=0;
  for i in 1..p_number_hier loop
    if p_child_level=p_child_ltc(i) then
      if EDW_OWB_COLLECTION_UTIL.value_in_table(p_parent,p_number_parent,p_parent_ltc(i))=false then
        p_number_parent:=p_number_parent+1;
        p_parent(p_number_parent):=p_parent_ltc(i);
      end if;
    end if;
  end loop;
  loop_end:=p_number_parent;
  for i in 1..loop_end loop
    if get_parent(p_parent(i),p_parent_ltc,p_child_ltc,p_number_hier,l_parent,l_number_parent)=false then
      return false;
    end if;
    for j in 1..l_number_parent loop
      p_number_parent:=p_number_parent+1;
      p_parent(p_number_parent):=l_parent(j);
    end loop;
  end loop;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('error in get_parent '||g_status_message);
  return false;
End;

function set_g_type_ilog_generation return boolean is
l_percentage number;
l_total_records number;
l_table varchar2(200);
l_owner varchar2(200);
--cut off kept at 5%
Begin
  l_table:=substr(g_ilog,instr(g_ilog,'.')+1,length(g_ilog));
  l_owner:=substr(g_ilog,1,instr(g_ilog,'.')-1);
  l_total_records:=EDW_OWB_COLLECTION_UTIL.get_table_count_stats(l_table,l_owner);
  if g_collection_size>0 then
    if l_total_records>0 then
      l_percentage:=100*(g_collection_size/l_total_records);
      if l_percentage<g_ok_switch_update then
        g_type_ilog_generation:='UPDATE';
        if g_debug then
          write_to_log_file_n('g_type_ok_generation made UPDATE');
        end if;
      end if;
    end if;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('error in set_g_type_ilog_generation '||g_status_message);
  return false;
End;

function log_pk_into_insert_prot return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In log_pk_into_insert_prot');
  end if;
  g_stmt:='insert into '||g_insert_prot_table||'('||g_dim_pk||') select '||g_dim_pk||
  ' from '||g_dim_name_temp||' where slow_flag=1';
  if g_debug then
    write_to_log_file_n(g_stmt||get_time);
  end if;
  execute immediate g_stmt;
  if g_debug then
    write_to_log_file_n('Inserted '||sql%rowcount||' rows '||get_time);
  end if;
  commit;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in log_pk_into_insert_prot '||g_status_message);
  return false;
End;

function log_pk_into_bu_insert_prot return boolean is
Begin
  if g_debug then
    write_to_log_file_n('In log_pk_into_bu_insert_prot');
  end if;
  g_stmt:='insert into '||g_bu_insert_prot_table||'('||g_dim_pk||') select '||g_dim_pk||
  ' from '||g_dim_name_hold;
  if g_debug then
    write_to_log_file_n(g_stmt||get_time);
  end if;
  execute immediate g_stmt;
  if g_debug then
    write_to_log_file_n('Inserted '||sql%rowcount||' rows '||get_time);
  end if;
  commit;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in log_pk_into_bu_insert_prot '||g_status_message);
  return false;
End;

function read_options_table(p_table_name varchar2) return boolean is
TYPE CurTyp IS REF CURSOR;
cv   CurTyp;
l_debug varchar2(2);
l_exec_flag varchar2(2);
l_fresh_restart varchar2(2);
l_ltc_merge_use_nl varchar2(2);
l_dim_inc_refresh_derv varchar2(2);
l_check_fk_change varchar2(2);
l_trace varchar2(2);
l_read_cfig_options varchar2(2);
l_skip_ilog_update varchar2(2);
l_level_change varchar2(2);
l_dim_empty_flag varchar2(2);
l_error_rec_flag varchar2(2);
l_use_ltc_ilog varchar2(2);
l_level_table varchar2(80);
l_level_child_table varchar2(80);
l_skip_table varchar2(80);
l_run number;
l_consider_snapshot EDW_OWB_COLLECTION_UTIL.varcharTableType;
Begin
  if g_debug then
    write_to_log_file_n('In read_options_table '||p_table_name);
  end if;
  l_level_table:=p_table_name||'_LT';
  l_level_child_table:=p_table_name||'_CT';
  l_skip_table:=p_table_name||'_SK';
  g_stmt:='select '||
  'conc_id,'||
  'conc_name,'||
  'debug,'||
  'exec_flag,'||
  'bis_owner,'||
  'parallel,'||
  'collection_size,'||
  'table_owner,'||
  'forall_size,'||
  'update_type,'||
  'load_pk,'||
  'fresh_restart,'||
  'op_table_space,'||
  'rollback,'||
  'ltc_merge_use_nl,'||
  'dim_inc_refresh_derv,'||
  'check_fk_change,'||
  'ok_switch_update,'||
  'join_nl_percentage,'||
  'max_threads,'||
  'min_job_load_size,'||
  'sleep_time,'||
  'job_status_table,'||
  'hash_area_size,'||
  'sort_area_size,'||
  'trace,'||
  'read_cfig_options,'||
  'ilog_table ,'||
  'skip_ilog_update,'||
  'level_change,'||
  'dim_empty_flag,'||
  'before_update_table_final,'||
  'error_rec_flag,'||
  'max_fk_density'||
  ' from '||p_table_name;
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  open cv for g_stmt;
  fetch cv into
  g_conc_id,
  g_conc_name,
  l_debug,
  l_exec_flag,
  g_bis_owner,
  g_parallel,
  g_collection_size,
  g_table_owner,
  g_forall_size,
  g_update_type,
  g_load_pk,
  l_fresh_restart,
  g_op_table_space,
  g_rollback,
  l_ltc_merge_use_nl,
  l_dim_inc_refresh_derv,
  l_check_fk_change,
  g_ok_switch_update,
  g_join_nl_percentage,
  g_max_threads,
  g_min_job_load_size,
  g_sleep_time,
  g_job_status_table,
  g_hash_area_size,
  g_sort_area_size,
  l_trace,
  l_read_cfig_options,
  g_ilog_main_name,
  l_skip_ilog_update,
  l_level_change,
  l_dim_empty_flag,
  g_before_update_table_final,
  l_error_rec_flag,
  g_max_fk_density;
  close cv;
  if g_debug then
    write_to_log_file('g_conc_id='||g_conc_id);
    write_to_log_file('g_conc_name='||g_conc_name);
    write_to_log_file('l_debug='||l_debug);
    write_to_log_file('l_exec_flag='||l_exec_flag);
    write_to_log_file('g_bis_owner='||g_bis_owner);
    write_to_log_file('g_parallel='||g_parallel);
    write_to_log_file('g_collection_size='||g_collection_size);
    write_to_log_file('g_table_owner='||g_table_owner);
    write_to_log_file('g_forall_size='||g_forall_size);
    write_to_log_file('g_update_type='||g_update_type);
    write_to_log_file('g_load_pk='||g_load_pk);
    write_to_log_file('l_fresh_restart='||l_fresh_restart);
    write_to_log_file('g_op_table_space='||g_op_table_space);
    write_to_log_file('g_rollback='||g_rollback);
    write_to_log_file('l_ltc_merge_use_nl='||l_ltc_merge_use_nl);
    write_to_log_file('l_dim_inc_refresh_derv='||l_dim_inc_refresh_derv);
    write_to_log_file('l_check_fk_change='||l_check_fk_change);
    write_to_log_file('g_ok_switch_update='||g_ok_switch_update);
    write_to_log_file('g_join_nl_percentage='||g_join_nl_percentage);
    write_to_log_file('g_max_threads='||g_max_threads);
    write_to_log_file('g_min_job_load_size='||g_min_job_load_size);
    write_to_log_file('g_sleep_time='||g_sleep_time);
    write_to_log_file('g_job_status_table='||g_job_status_table);
    write_to_log_file('g_hash_area_size='||g_hash_area_size);
    write_to_log_file('g_sort_area_size='||g_sort_area_size);
    write_to_log_file('l_trace='||l_trace);
    write_to_log_file('l_read_cfig_options='||l_read_cfig_options);
    write_to_log_file('g_ilog_main_name='||g_ilog_main_name);
    write_to_log_file('l_skip_ilog_update='||l_skip_ilog_update);
    write_to_log_file('l_level_change='||l_level_change);
    write_to_log_file('l_dim_empty_flag='||l_dim_empty_flag);
    write_to_log_file('g_before_update_table_final='||g_before_update_table_final);
    write_to_log_file('l_error_rec_flag='||l_error_rec_flag);
    write_to_log_file('g_max_fk_density='||g_max_fk_density);
  end if;
  g_debug:=false;
  g_exec_flag:=false;
  g_fresh_restart:=false;
  g_ltc_merge_use_nl:=false;
  g_dim_inc_refresh_derv:=false;
  g_check_fk_change:=false;
  g_trace:=false;
  g_read_cfig_options:=false;
  g_skip_ilog_update:=false;
  g_level_change:=false;
  g_dim_empty_flag:=false;
  g_error_rec_flag:=false;
  if l_debug='Y' then
    g_debug:=true;
  end if;
  if l_exec_flag='Y' then
    g_exec_flag:=true;
  end if;
  if l_fresh_restart='Y' then
    g_fresh_restart:=true;
  end if;
  if l_ltc_merge_use_nl='Y' then
    g_ltc_merge_use_nl:=true;
  end if;
  if l_dim_inc_refresh_derv='Y' then
    g_dim_inc_refresh_derv:=true;
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
  if l_skip_ilog_update='Y' then
    g_skip_ilog_update:=true;
  end if;
  if l_level_change='Y' then
    g_level_change:=true;
  end if;
  if l_dim_empty_flag='Y' then
    g_dim_empty_flag:=true;
  end if;
  if l_error_rec_flag='Y' then
    g_error_rec_flag:=true;
  end if;
  g_stmt:='select '||
  'levels,'||
  'child_level_number,'||
  'level_snapshot_logs,'||
  'level_order,'||
  'consider_snapshot,'||
  'levels_I, '||
  'use_ltc_ilog '||
  ' from '||l_level_table||' order by level_number';
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  open cv for g_stmt;
  g_number_levels:=1;
  loop
    fetch cv into g_levels(g_number_levels),g_child_level_number(g_number_levels),
    g_level_snapshot_logs(g_number_levels),g_level_order(g_number_levels),
    l_consider_snapshot(g_number_levels),g_levels_I(g_number_levels),
    l_use_ltc_ilog;
    exit when cv%notfound;
    if l_use_ltc_ilog='Y' then
      g_use_ltc_ilog(g_number_levels):=true;
    else
      g_use_ltc_ilog(g_number_levels):=false;
    end if;
    g_number_levels:=g_number_levels+1;
  end loop;
  close cv;
  g_number_levels:=g_number_levels-1;
  if g_debug then
    write_to_log_file_n('The levels and snp logs');
    for i in 1..g_number_levels loop
      write_to_log_file(g_levels(i)||' '||g_child_level_number(i)||' '||
      g_level_snapshot_logs(i)||' '||g_level_order(i)||' '||l_consider_snapshot(i)||' '||
      g_levels_I(i));
      if g_use_ltc_ilog(i) then
        write_to_log_file('g_use_ltc_ilog TRUE');
      else
        write_to_log_file('g_use_ltc_ilog FALSE');
      end if;
    end loop;
  end if;
  for i in 1..g_number_levels loop
    if l_consider_snapshot(i)='Y' then
      g_consider_snapshot(i):=true;
    else
      g_consider_snapshot(i):=false;
    end if;
  end loop;
  g_stmt:='select '||
  'child_levels,'||
  'child_fk,'||
  'parent_pk'||
  ' from '||l_level_child_table||' order by run_number';
  if g_debug then
    write_to_log_file_n(g_stmt);
  end if;
  open cv for g_stmt;
  l_run:=1;
  loop
    fetch cv into g_child_levels(l_run),g_child_fk(l_run),g_parent_pk(l_run);
    exit when cv%notfound;
    l_run:=l_run+1;
  end loop;
  close cv;
  l_run:=l_run-1;
  if g_debug then
    write_to_log_file_n('The levels fk pk');
    for i in 1..l_run loop
      write_to_log_file(g_child_levels(i)||' '||g_child_fk(i)||' '||g_parent_pk(i));
    end loop;
  end if;
  g_stmt:='select '||
  'skip_cols'||
  ' from '||l_skip_table;
  if g_debug then
    write_to_log_file_n(g_stmt);
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
    write_to_log_file_n('The skip columns');
    for i in 1..g_number_skip_cols loop
      write_to_log_file(g_skip_cols(i));
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
p_low_end number,
p_high_end number
) return boolean is
l_ilog_number number;
Begin
  if g_debug then
    write_to_log_file_n('In make_ok_from_main_ok '||p_main_ok_table_name||' '||p_low_end||' '||p_high_end);
  end if;
  if EDW_OWB_COLLECTION_UTIL.make_ilog_from_main_ilog(
    g_ilog,
    p_main_ok_table_name,
    p_low_end,
    p_high_end,
    g_op_table_space,
    g_bis_owner,
    g_parallel,
    l_ilog_number)=false then
    return false;
  end if;
  if EDW_OWB_COLLECTION_UTIL.does_table_have_data(g_ilog,' status=1 ')=2 then
    g_skip_ilog_update:=true;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in make_ok_from_main_ok '||g_status_message);
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
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_table_name||'_CT')=false then
    null;
  end if;
  if EDW_OWB_COLLECTION_UTIL.drop_table(p_table_name||'_SK')=false then
    null;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in drop_input_tables '||g_status_message);
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

/*
this function is executed if there is multi threading.
we need rownum in the ok table so that each child process can then take its part of the
ok table
*/
function put_rownum_in_ok_table return boolean is
l_ilog_table varchar2(80);
Begin
  if g_debug then
    write_to_log_file_n('In put_rownum_in_ok_table');
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
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in put_rownum_in_ok_table '||g_status_message);
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
  l_exe_file_name:='EDW_SUMMARY_COLLECT.COLLECT_DIMENSION';
  l_parameter(1):='p_dim_name';
  l_parameter_value_set(1):='FND_CHAR240';
  l_parameter(2):='p_table_name';
  l_parameter_value_set(2):='FND_CHAR240';
  l_parameter(3):='p_job_id';
  l_parameter_value_set(3):='FND_NUMBER';
  l_parameter(4):='p_ok_low_end';
  l_parameter_value_set(4):='FND_NUMBER';
  l_parameter(5):='p_ok_high_end';
  l_parameter_value_set(5):='FND_NUMBER';
  l_number_parameters:=5;
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

function insert_L_ilog_parallel_dd(p_multi_thread boolean) return boolean is
--
l_status edw_owb_collection_util.varcharTableType;
l_num_status number;
l_job_id number;
l_job_running boolean;
l_ul_table varchar2(200);
l_ur_pattern varchar2(200);
--
--
Begin
  if g_debug then
    write_to_log_file_n('In insert_L_ilog_parallel_dd'||get_time);
  end if;
  --see if the process for the lowest level has finished
  if edw_owb_collection_util.query_table_cols(g_dd_status_table,'status',' where parent_ltc_id='||g_lowest_level_id,
    l_status,l_num_status)=false then
    return false;
  end if;
  if substr(l_status(1),1,3)='ERR' then
    g_status_message:=substr(l_status(1),instr(l_status(1),'+')+1);
    return false;
  end if;
  if l_status(1)<>'DONE' then
    --job is still running
    l_num_status:=0;
    if edw_owb_collection_util.query_table_cols(g_dd_status_table,'job_id',' where parent_ltc_id='||g_lowest_level_id,
      l_status,l_num_status)=false then
      g_status_message:=edw_owb_collection_util.g_status_message;
      return false;
    end if;
    l_job_id:=to_number(l_status(1));
    l_job_running:=false;
    if edw_owb_collection_util.check_job_status(l_job_id)='Y' then
      if edw_owb_collection_util.check_table(g_bis_owner||'.TAB_MARKER_DD_'||g_lowest_level_id) then
        l_job_running:=true;
      end if;
    end if;
    if l_job_running then
      if edw_owb_collection_util.wait_on_jobs(l_job_id,g_sleep_time,'JOB')=false then
        return false;
      end if;
      if edw_owb_collection_util.query_table_cols(g_dd_status_table,'status',' where parent_ltc_id='||g_lowest_level_id,
        l_status,l_num_status)=false then
        return false;
      end if;
      if substr(l_status(1),1,3)='ERR' then
        g_status_message:=substr(l_status(1),instr(l_status(1),'+')+1);
        return false;
      end if;
    else
      --process has crashed
      if edw_owb_collection_util.terminate_job(l_job_id)=false then
        null;
      end if;
      if g_debug then
        write_to_log_file_n(l_job_id||' could have crashed or not started. Try serial');
      end if;
      --manual op
      l_ul_table:=g_bis_owner||'.TAB_'||g_lowest_level_id||'_UL';
      l_ur_pattern:='TAB_'||g_lowest_level_id||'_HDUR_%';
      edw_mapping_collect.drill_parent_to_children(g_lowest_level,g_lowest_level_id,
      g_dd_status_table,l_ul_table,l_ur_pattern,g_ltc_pk,
      null,null,null,null,null,null,null,null,null,null,0);
      --if the manual op also fails, then try the old method of looking at the snp logs
    end if;
  end if;
  if insert_into_ilog_from_L(p_multi_thread)=false then
    return false;
  end if;
  if drop_L_tables=false then
    return false;
  end if;
  return true;
Exception when others then
  g_status_message:=sqlerrm;
  write_to_log_file_n('Error in insert_L_ilog_parallel_dd '||g_status_message);
  return false;
End;

END EDW_SUMMARY_COLLECT;

/
