--------------------------------------------------------
--  DDL for Package Body ISC_FS_TASK_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_FS_TASK_ETL_PKG" 
/* $Header: iscfstasketlb.pls 120.6 2005/12/01 19:02:44 kreardon noship $ */
as

  g_pkg_name constant varchar2(30) := 'isc_fs_task_etl_pkg';
  g_user_id  number;
  g_login_id number;
  g_program_id number;
  g_program_login_id number;
  g_program_application_id number;
  g_request_id number;
  g_success constant varchar2(10) := '0';
  g_error   constant varchar2(10) := '-1';
  g_warning constant varchar2(10) := '1';
  g_bis_setup_exception exception;
  g_global_start_date date;
  g_ttr_ftf_rule varchar2(30);
  g_time_uom_class constant varchar2(10) := fnd_profile.value('JTF_TIME_UOM_CLASS');
  g_uom_hours constant varchar2(10) := fnd_profile.value('CSF_UOM_HOURS');
  g_time_base_to_hours number;


procedure bis_collection_utilities_log
( m varchar2, indent number default null )
as
begin
  --if indent is not null then
  --  for i in 1..indent loop
  --    dbms_output.put('__');
  --  end loop;
  --end if;
  --dbms_output.put_line(substr(m,1,254));

  bis_collection_utilities.log( substr(m,1,2000-(nvl(indent,0)*3)), nvl(indent,0) );

end bis_collection_utilities_log;

procedure local_init
as

  cursor c_time_base is
    select 1 / decode( conversion_rate
                     , 0 , 1 -- prevent "divide by zero" error
                     , conversion_rate )
    from mtl_uom_conversions
    where uom_class = g_time_uom_class
    and uom_code = g_uom_hours
    and inventory_item_id = 0;

begin

  g_user_id  := fnd_global.user_id;
  g_login_id := fnd_global.login_id;
  g_global_start_date := bis_common_parameters.get_global_start_date;
  g_program_id := fnd_global.conc_program_id;
  g_program_login_id := fnd_global.conc_login_id;
  g_program_application_id := fnd_global.prog_appl_id;
  g_request_id := fnd_global.conc_request_id;

  g_ttr_ftf_rule := nvl(fnd_profile.value('ISC_FS_TTR_FTF_DISTRICT_RULE'),'0');

  -- the base UOM_CODE for the UOM_CLASS may not be the same as the
  -- UOM_CODE for "hours".  We need to convert everything to "hours"
  -- so we
  open c_time_base;
  fetch c_time_base into g_time_base_to_hours;
  close c_time_base;

end local_init;

procedure logger
( p_proc_name varchar2
, p_stmt_id number
, p_message varchar2
)
as
begin
  bis_collection_utilities_log( g_pkg_name || '.' || p_proc_name ||
                                ' #' || p_stmt_id || ' ' ||
                                p_message
                              , 3 );
end logger;

function get_schema_name
( x_schema_name   out nocopy varchar2
, x_error_message out nocopy varchar2 )
return number as

  l_isc_schema   varchar2(30);
  l_status       varchar2(30);
  l_industry     varchar2(30);

begin

  if fnd_installation.get_app_info('ISC', l_status, l_industry, l_isc_schema) then
    x_schema_name := l_isc_schema;
  else
    x_error_message := 'FND_INSTALLATION.GET_APP_INFO returned false';
    return -1;
  end if;

  return 0;

exception
  when others then
    x_error_message := 'Error in function get_schema_name : ' || sqlerrm;
    return -1;

end get_schema_name;

function truncate_table
( p_isc_schema    in varchar2
, p_table_name    in varchar2
, x_error_message out nocopy varchar2
)
return number as

begin

  execute immediate 'truncate table ' || p_isc_schema || '.' || p_table_name;

  return 0;

exception
  when others then
    x_error_message  := 'Error in function truncate_table : ' || sqlerrm;
    return -1;

end truncate_table;

function gather_statistics
( p_isc_schema    in varchar2
, p_table_name    in varchar2
, x_error_message out nocopy varchar2 )
return number as

begin

  fnd_stats.gather_table_stats( ownname => p_isc_schema
                              , tabname => p_table_name
                              );

  return 0;

exception
  when others then
    x_error_message  := 'Error in function gather_statistics : ' || sqlerrm;
    return -1;

end gather_statistics;

function get_last_refresh_date
( x_refresh_date out nocopy date
, x_error_message out nocopy varchar2 )
return number as

  l_refresh_date date;

begin

  l_refresh_date := fnd_date.displaydt_to_date(bis_collection_utilities.get_last_refresh_period(g_object_name));
  if l_refresh_date = g_global_start_date then
    x_error_message := 'Incremental Load can only be run after a completed initial or incremental load';
    return -1;
  end if;

  x_refresh_date := l_refresh_date;
  return 0;

exception
  when others then
    x_error_message := 'Error in function get_last_refresh_date : ' || sqlerrm;
    return -1;

end get_last_refresh_date;

function get_tr_ftf_rule_meaning
( p_lookup_code in varchar2
)
return varchar2
as

  cursor c_meaning is
    select meaning
    from fnd_lookup_values_vl
    where lookup_type = 'ISC_FS_TTR_FTF_DISTRICT_RULE'
    and lookup_code = p_lookup_code;

  l_meaning varchar2(80);

begin

  open c_meaning;
  fetch c_meaning into l_meaning;
  close c_meaning;

  return nvl(l_meaning,'NULL');

end get_tr_ftf_rule_meaning;

function check_district_rule
( p_mode  in varchar2
, x_error_message out nocopy varchar2
)
return number
as

  l_attributes DBMS_SQL.VARCHAR2_TABLE;
  l_count number;
  l_last_load varchar2(150);

begin

  bis_collection_utilities.get_last_user_attributes
  ( g_object_name
  , l_attributes
  , l_count
  );

  if l_count > 0 then
    l_last_load := l_attributes(1);
  else
    l_last_load := 'X';
  end if;

  if p_mode = 'initial_load' then
    bis_collection_utilities_log('MTTR/FTFR Rule: ' || get_tr_ftf_rule_meaning(g_ttr_ftf_rule), 1);
  else
    if g_ttr_ftf_rule = l_last_load then
      bis_collection_utilities_log('MTTR/FTFR Rule: ' || get_tr_ftf_rule_meaning(g_ttr_ftf_rule), 1);
    else
      bis_collection_utilities_log('Previous MTTR/FTFR Rule: ' || get_tr_ftf_rule_meaning(l_last_load), 1);
      bis_collection_utilities_log('Current MTTR/FTFR Rule: ' || get_tr_ftf_rule_meaning(g_ttr_ftf_rule), 1);
      x_error_message := 'MTTR/FTFR Rule mismatch';
      return -1;
    end if;
  end if;

  return 0;

end check_district_rule;

-- -------------------------------------------------------------------
-- PUBLIC PROCEDURES
-- -------------------------------------------------------------------
procedure initial_load
( errbuf out nocopy varchar2
, retcode out nocopy number
)
as

  l_proc_name constant varchar2(30) := 'initial_load';
  l_stmt_id number;
  l_exception exception;
  l_error_message varchar2(4000);
  l_isc_schema varchar2(100);

  l_rowcount number;

  l_collect_from_date date;
  l_collect_to_date date;

begin

  local_init;

  bis_collection_utilities_log( 'Begin Initial Load' );

  l_stmt_id := 0;
  if not bis_collection_utilities.setup( g_object_name ) then
    l_error_message := 'Error in BIS_COLLECTION_UTILITIES.Setup';
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise g_bis_setup_exception;
  end if;

  -- determine the date we last collected to
  l_stmt_id := 10;
  if g_global_start_date is null then
    l_error_message := 'Unable to get DBI global start date.'; -- translatable message?
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  l_collect_from_date := g_global_start_date;
  l_collect_to_date := sysdate;

  bis_collection_utilities_log( 'From ' || fnd_date.date_to_displaydt(l_collect_from_date), 1 );
  bis_collection_utilities_log( 'To ' || fnd_date.date_to_displaydt(l_collect_to_date), 1 );

  -- check MTTR/FTFR district rule
  l_stmt_id := 20;
  if check_district_rule
     ( l_proc_name
     , l_error_message ) <> 0 then -- should never fail for intial load
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  -- get the isc schema name
  l_stmt_id := 30;
  if get_schema_name
     ( l_isc_schema
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  -- truncate the events table
  l_stmt_id := 40;
  if truncate_table
     ( l_isc_schema
     , 'ISC_FS_EVENTS'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities_log( 'Events table truncated', 1 );

  -- truncate the party merge events table
  l_stmt_id := 50;
  if truncate_table
     ( l_isc_schema
     , 'ISC_FS_PARTY_MERGE_EVENTS'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities_log( 'Party Merge Events table truncated', 1 );

  -- enable event logging
  l_stmt_id := 60;
  if isc_fs_event_log_etl_pkg.enable_events
     ( l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities_log( 'Event logging enabled', 1 );

  -- truncate the isc_fs_tasks_f fact table
  l_stmt_id := 70;
  if truncate_table
     ( l_isc_schema
     , 'ISC_FS_TASKS_F'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities_log( 'Task base summary table truncated', 1 );

  -- truncate the isc_fs_task_assignmnts_f fact table
  l_stmt_id := 80;
  if truncate_table
     ( l_isc_schema
     , 'ISC_FS_TASK_ASSIGNMNTS_F'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities_log( 'Task Assignments base summary table truncated', 1 );

  -- R12 dep/arr
  -- attempt to truncate obsolete isc_fs_dep_arr_tasks_f table,
  -- ignore any errors as table may not exist.
  l_stmt_id := 90;
  if truncate_table
     ( l_isc_schema
     , 'ISC_FS_DEP_ARR_TASKS_F'
     , l_error_message ) = 0 then
    bis_collection_utilities_log( 'Obsolete Departure/Arrival Task base summary table truncated', 1 );
  end if;

  -- truncate the isc_fs_capacity_f fact table
  l_stmt_id := 95;
  if truncate_table
     ( l_isc_schema
     , 'ISC_FS_CAPACITY_F'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities_log( 'Capacity base summary table truncated', 1 );
  -- R12 dep/arr

  -- insert into base fact tables
  l_stmt_id := 100;
  insert /*+ append
             parallel(isc_fs_tasks_f)
             parallel(isc_fs_task_assignmnts_f)
             parallel(isc_fs_capacity_f)
         */
  ALL
  when source_object_type_code = 'SR' and task_rn = 1 then into
    isc_fs_tasks_f
    ( task_id
    , task_number
    , task_type_id
    , task_type_rule
    , break_fix_flag
    , task_status_id
    , owner_id
    -- R12 resource type impact
    , owner_type
    , owner_district_id
    , customer_id
    , address_id
    -- R12 impact
    , location_id
    , planned_start_date
    , planned_end_date
    , scheduled_start_date
    , scheduled_end_date
    , actual_start_date
    , actual_end_date
    , source_object_type_code
    , source_object_id
    , source_object_name
    , planned_effort_hrs
    , actual_effort_hrs
    , cancelled_flag
    , completed_flag
    , closed_flag
    , deleted_flag
    , task_creation_date
    --
    , first_asgn_creation_date
    --
    , act_bac_assignee_id
    -- R12 resource type impact
    , act_bac_assignee_type
    , act_bac_district_id
    --
    , ftf_assignee_id
    -- R12 resource type impact
    , ftf_assignee_type
    , ftf_district_id
    --
    , ttr_assignee_id
    -- R12 resource type impact
    , ttr_assignee_type
    , ttr_district_id
    --
    , ftf_ttr_district_rule
    --
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , program_id
    , program_login_id
    , program_application_id
    , request_id
    --
    , include_task_in_ttr_flag
    , include_task_in_ftf_flag
    , ftf_flag
    --
    , incident_date
    , inventory_item_id
    , inv_organization_id
    --
    -- R12 impact
    , task_split_flag
    , parent_task_id
    --
    )
    values
    ( task_id
    , task_number
    , task_type_id
    , task_type_rule
    , break_fix_flag
    , task_status_id
    , task_owner_id
    -- R12 resource type impact
    , task_owner_type
    , task_district_id
    , customer_id
    , address_id
    -- R12 impact
    , location_id
    , task_planned_start_date
    , task_planned_end_date
    , task_scheduled_start_date
    , task_scheduled_end_date
    , task_actual_start_date
    , task_actual_end_date
    , source_object_type_code
    , source_object_id
    , source_object_name
    , task_planned_effort_hrs
    , task_actual_effort_hrs
    , task_cancelled_flag
    , task_completed_flag
    , task_closed_flag
    , task_deleted_flag
    , task_creation_date
    --
    -- R12 impact null value for first_asgn_creation_date for "child" task
    , decode(task_split_flag,'D',to_date(null),first_asgn_creation_date)
    --
    -- R12 impact null value for act_bac_assignee_id for "child" task
    , decode(task_split_flag,'D',to_number(null),nvl(act_bac_assignee_id,task_owner_id))
    -- R12 resource type impact
    , decode(task_split_flag,'D',null,nvl(act_bac_assignee_type,task_owner_type))
    --
    -- R12 impact null value for act_bac_district_id for "child" task
    , decode(task_split_flag,'D',to_number(null),nvl(act_bac_district_id,task_district_id))
    --
    -- R12 impact null value for ftf_assignee_id for "child" task
    , decode(task_split_flag,'D',to_number(null),nvl(ftf_assignee_id,task_owner_id))
    -- R12 resource type impact
    , decode(task_split_flag,'D',null,nvl(ftf_assignee_type,task_owner_type))
    -- R12 impact null value for ftf_district_id for "child" task
    , decode(task_split_flag,'D',to_number(null),nvl(ftf_district_id,task_district_id))
    --
    -- R12 impact null value for ttr_assignee_id for "child" task
    , decode(task_split_flag,'D',to_number(null),nvl(ttr_assignee_id,task_owner_id))
    -- R12 resource type impact
    , decode(task_split_flag,'D',null,nvl(ttr_assignee_type,task_owner_type))
    --
    -- R12 impact null value for ttr_district_id for "child" task
    , decode(task_split_flag,'D',to_number(null),nvl(ttr_district_id,task_district_id))
    --
    -- values for ftf owner/district are determined by rule in MV and detail report
    , g_ttr_ftf_rule
    --
    , g_user_id
    , l_collect_to_date -- don't use sysdate as need to synchronize dates
    , g_user_id
    , l_collect_to_date -- don't use sysdate as need to synchronize dates for activity and backlog
    , g_login_id
    , g_program_id
    , g_program_login_id
    , g_program_application_id
    , g_request_id
    --
    , include_task_in_ttr_flag
    , include_task_in_ftf_flag
    , ftf_flag
    --
    , incident_date
    , inventory_item_id
    , inv_organization_id
    --
    -- R12 impact
    , task_split_flag
    , parent_task_id
    --
    )
  when source_object_type_code = 'SR' and task_assignment_id is not null then into
    isc_fs_task_assignmnts_f
    ( task_id
    , task_assignment_id
    , deleted_flag
    , cancelled_flag
    , assignment_creation_date
    , resource_id
    -- R12 resource type impact
    , resource_type
    , district_id
    , actual_effort_hrs
    , sched_travel_distance_km
    , sched_travel_duration_min
    , actual_travel_distance_km
    , actual_travel_duration_min
    , actual_start_date
    , actual_end_date
    , report_date
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , program_id
    , program_login_id
    , program_application_id
    , request_id
    )
    values
    ( task_id
    , task_assignment_id
    , asgn_deleted_flag
    , asgn_cancelled_flag
    , asgn_creation_date
    , asgn_resource_id
    -- R12 resource type impact
    , asgn_resource_type
    , asgn_district_id
    , asgn_actual_effort_hrs
    , sched_travel_distance_km
    , sched_travel_duration_min
    , actual_travel_distance_km
    , actual_travel_duration_min
    , asgn_actual_start_date
    , asgn_actual_end_date
    , case
        when asgn_deleted_flag = 'N' and
             asgn_actual_end_date >= g_global_start_date then
          trunc(asgn_actual_end_date)
        else
          null
      end
    , g_user_id
    , l_collect_to_date -- don't use sysdate as need to synchronize dates
    , g_user_id
    , l_collect_to_date -- don't use sysdate as need to synchronize dates
    , g_login_id
    , g_program_id
    , g_program_login_id
    , g_program_application_id
    , g_request_id
    )
  when source_object_type_code = 'TASK' and task_rn = 1 then into
    -- R12 dep/arr
    isc_fs_capacity_f
    ( task_id
    , owner_id
    -- R12 resource type impact
    , owner_type
    , district_id
    , blocked_trip_flag
    , object_capacity_id
    , capacity_date
    , capacity_hours
    , deleted_flag
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , program_id
    , program_login_id
    , program_application_id
    , request_id
    )
    values
    ( task_id
    , task_owner_id
    -- R12 resource type impact
    , task_owner_type
    , task_district_id
    , blocked_trip_flag
    , object_capacity_id
    , capacity_date
    , capacity_hours
    , task_deleted_flag
    , g_user_id
    , sysdate
    , g_user_id
    , sysdate
    , g_login_id
    , g_program_id
    , g_program_login_id
    , g_program_application_id
    , g_request_id
    -- R12 dep/arr
    )
  --
  -- this query selects all tasks and task assignments for tasks of
  -- interest
  -- R12 dep/arr
  -- . Task Type departure (20) and source object "TASK" or
  --   Task source object "SR"
  -- . Task Created on/after GSD or
  --   Task has assignments created on/after GSD or
  --   Task status is not closed (source object "SR" only)
  --
  select  /*+ leading(x) parallel(x)
              use_nl(t_eff,t_peff,ta_eff,ta_std,ta_atd)
              parallel(t_eff)
              parallel(ta_eff)
              parallel(ta_std)
              parallel(ta_atd)
              parallel(bf)
              parallel(x)
          */
    x.task_id
  --
  -- simple columns for isc_fs_tasks_f
  --
  , x.task_rn
  , x.task_number
  , x.task_type_id
  , x.task_type_rule
  , x.break_fix_flag
  , x.task_status_id
  , x.task_owner_id
  -- R12 resource type impact
  , x.task_owner_type
  , x.task_district_id
  , x.customer_id
  , x.address_id
  -- R12 impact
  , x.location_id
  , x.task_planned_start_date
  , x.task_planned_end_date
  , x.task_scheduled_start_date
  , x.task_scheduled_end_date
  , x.task_actual_start_date
  , x.task_actual_end_date
  , x.source_object_type_code
  , x.source_object_id
  , x.source_object_name
  , (x.task_planned_effort * t_peff.conversion_rate * g_time_base_to_hours) task_planned_effort_hrs
  , (x.task_actual_effort * t_eff.conversion_rate * g_time_base_to_hours) task_actual_effort_hrs
  , x.task_creation_date
  , x.task_cancelled_flag
  , x.task_completed_flag
  , x.task_closed_flag
  , x.task_deleted_flag
  --
  -- complex columns for isc_fs_tasks_f
  --
  -- returns the date of the first created (not cancelled) assignment for the task
  -- R12 impact
  , min( x.asgn_creation_date_unc )
         keep( dense_rank first
               order by x.asgn_creation_date_unc nulls last
             )
         over( partition by nvl(x.parent_task_id,x.task_id) ) first_asgn_creation_date
  --
  -- assignee/district are determined uniquely for activity/backlog, ftf and ttr
  -- as they have different rules for establishing ownership and dealing with
  -- cancelled assignments.
  --
  -- activity/backlog
  -- based on last assignment creation date of non-cancelled assignments
  -- R12 impact in the case of split "parent" tasks, it is from the last "scheduled"
  -- "child" task assignments.
  --
  , max( x.act_bac_resource_id )
         keep( dense_rank last
               order by
                 x.task_scheduled_end_date
               , x.asgn_creation_date_unc nulls first
               , x.asgn_creation_date -- always use creation_date ahead of xxx_id for RAC
               , x.task_assignment_id
             )
         over( partition by nvl(x.parent_task_id,x.task_id) ) act_bac_assignee_id
  -- R12 resource type impact
  , max( x.act_bac_resource_type )
         keep( dense_rank last
               order by
                 x.task_scheduled_end_date
               , x.asgn_creation_date_unc nulls first
               , x.asgn_creation_date -- always use creation_date ahead of xxx_id for RAC
               , x.task_assignment_id
             )
         over( partition by nvl(x.parent_task_id,x.task_id) ) act_bac_assignee_type
  -- R12 impact
  , max( x.act_bac_district_id )
         keep( dense_rank last
               order by
                 x.task_scheduled_end_date
               , x.asgn_creation_date_unc nulls first
               , x.asgn_creation_date -- always use creation_date ahead of xxx_id for RAC
               , x.task_assignment_id
             )
         over( partition by nvl(x.parent_task_id,x.task_id) ) act_bac_district_id
  --
  -- ftf
  -- based on last assignment creation date, exclude cancelled assignments unless
  -- they have actual_end_date not null
  --
  -- R12 impact
  , max( x.ftf_ttr_resource_id )
         keep( dense_rank last
               order by
                 x.task_scheduled_end_date
               , x.asgn_creation_date_unc nulls first
               , x.asgn_creation_date -- always use creation_date ahead of xxx_id for RAC
               , x.task_assignment_id
              )
         over( partition by nvl(x.parent_task_id,x.task_id) ) ftf_assignee_id
  -- R12 resource type impact
  , max( x.ftf_ttr_resource_type )
         keep( dense_rank last
               order by
                 x.task_scheduled_end_date
               , x.asgn_creation_date_unc nulls first
               , x.asgn_creation_date -- always use creation_date ahead of xxx_id for RAC
               , x.task_assignment_id
             )
         over( partition by nvl(x.parent_task_id,x.task_id) ) ftf_assignee_type
  -- R12 impact
  , max( x.ftf_ttr_district_id )
         keep( dense_rank last
               order by
                 x.task_scheduled_end_date
               , x.asgn_creation_date_unc nulls first
               , x.asgn_creation_date -- always use creation_date ahead of xxx_id for RAC
               , x.task_assignment_id
             )
         over( partition by nvl(x.parent_task_id,x.task_id) ) ftf_district_id
  --
  -- ttr
  -- based on the last worked (assignment actual end date), exclude cancelled assignments unless
  -- they have actual_end_date not null
  --
  -- R12 impact
  , max( x.ftf_ttr_resource_id )
         keep( dense_rank last
               order by
                 x.asgn_actual_end_date nulls first
               , x.asgn_creation_date -- always use creation_date ahead of xxx_id for RAC
               , x.task_assignment_id
             )
         over( partition by nvl(x.parent_task_id,x.task_id) ) ttr_assignee_id
  -- R12 resource type impact
  , max( x.ftf_ttr_resource_type )
         keep( dense_rank last
               order by
                 x.asgn_actual_end_date nulls first
               , x.asgn_creation_date -- always use creation_date ahead of xxx_id for RAC
               , x.task_assignment_id
             )
         over( partition by nvl(x.parent_task_id,x.task_id) ) ttr_assignee_type
  -- R12 impact
  , max( x.ftf_ttr_district_id )
         keep( dense_rank last
               order by
                 x.asgn_actual_end_date nulls first
               , x.asgn_creation_date -- always use creation_date ahead of xxx_id for RAC
               , x.task_assignment_id
              )
         over( partition by nvl(x.parent_task_id,x.task_id) ) ttr_district_id
  --
  -- ttr
  -- only rows (one per SR) with 'Y' are included in ttr reports
  -- a) not deleted, type rule = DISPATCH, break/fix enabled
  -- b) latest actual end date, if no actual end dates, latest scheduled end date
  -- c) "normal" or "parent" tasks
  , case
      when x.task_ttr_ftf_flag <> 'Y' then 'N'
      when rank() over( partition by
                          x.source_object_type_code
                        , x.source_object_id
                        order by
                          x.task_ttr_ftf_flag desc
                        , x.task_ttr_ftf_actual_end_date desc nulls last
                        , x.task_ttr_ftf_sched_end_date desc nulls last
                        , x.task_creation_date desc -- always use creation_date ahead of xxx_id for RAC
                        , x.task_id desc
                      ) <> 1 then 'N'
      else 'Y'
    end include_task_in_ttr_flag
  --
  -- ftf
  -- multiple rows per SR with 'Y' are included in non ftf detail report
  -- not deleted, type rule = DISPATCH, break/fix enabled
  -- "normal" or "parent" tasks
  , x.task_ttr_ftf_flag include_task_in_ftf_flag
  --
  -- ftf
  -- only rows (one per SR) with 'Y' or 'N' are included in ftf reports
  -- a) not deleted, type rule = DISPATCH, break/fix enabled
  -- b) earliest actual start date, if no actual start dates, latest scheduled start date
  -- c) trunc( earliest actual end date ) = trunc ( latest actual end date ) = ftf else non ftf
  -- d) "normal" or "parent" tasks
  , case
      when x.task_ttr_ftf_flag <> 'Y' then '-'
      when rank() over( partition by
                          x.source_object_type_code
                        , x.source_object_id
                        order by
                          x.task_ttr_ftf_flag desc
                        , x.task_ttr_ftf_actual_start_date
                        , x.task_ttr_ftf_sched_start_date
                        , x.task_creation_date -- always use creation_date ahead of xxx_id for RAC
                        , x.task_id
                      ) <> 1 then '-'
      when trunc( first_value( x.task_ttr_ftf_actual_start_date ) -- use start_date
                  over( partition by
                          x.source_object_type_code
                        , x.source_object_id
                        order by
                          x.task_ttr_ftf_flag desc
                        , x.task_ttr_ftf_actual_start_date nulls last -- use start_date
                        , x.task_ttr_ftf_sched_start_date nulls last -- use start_date
                        , x.task_creation_date -- always use creation_date ahead of xxx_id for RAC
                        , x.task_id
                        rows between unbounded preceding and unbounded following
                      )
                ) <>
           trunc( last_value( x.task_ttr_ftf_actual_start_date ) -- use start_date
                  over( partition by
                          x.source_object_type_code
                        , x.source_object_id
                        order by
                          x.task_ttr_ftf_flag
                        , x.task_ttr_ftf_actual_start_date nulls first -- use start_date
                        , x.task_ttr_ftf_sched_start_date nulls first -- use start_date
                        , x.task_creation_date -- always use creation_date ahead of xxx_id for RAC
                        , x.task_id
                        rows between unbounded preceding and unbounded following
                      )
                ) then 'N'
      else 'Y'
    end ftf_flag
  --
  , x.incident_date
  , x.inventory_item_id
  , x.inv_organization_id
  --
  -- R12 impact
  , x.task_split_flag
  , x.parent_task_id
  --
  -- simple columns for isc_fs_task_assignmnts_f
  --
  , x.task_assignment_id
  , 'N' asgn_deleted_flag
  , x.asgn_cancelled_flag
  , x.asgn_creation_date
  , x.asgn_resource_id
  -- R12 resource type impact
  , x.asgn_resource_type
  , x.asgn_district_id
  , (x.asgn_actual_effort * ta_eff.conversion_rate * g_time_base_to_hours) asgn_actual_effort_hrs
  , x.sched_travel_distance sched_travel_distance_km
  , (x.sched_travel_duration * ta_std.conversion_rate * g_time_base_to_hours)* 60 sched_travel_duration_min
  , x.actual_travel_distance actual_travel_distance_km
  , (x.actual_travel_duration * ta_atd.conversion_rate * g_time_base_to_hours) * 60 actual_travel_duration_min
  , x.asgn_actual_start_date
  , x.asgn_actual_end_date
  --
  -- R12 dep/arr
  -- simple columns for isc_fs_capacity_f
  --
  , x.object_capacity_id
  , x.capacity_date
  , x.capacity_hours
  , x.blocked_trip_flag
  --
  -- R12 dep/arr
  --
  from
    ( --
      -- this query returns all of tasks of interest joined to
      -- their assignments if any and resolves field service
      -- district
      --
      select /*+ parallel(t)
                 use_nl(dgt,dga,tt,tas,oc,bf)
                 parallel(tt)
                 parallel(dga)
                 parallel(dgt)
                 parallel(tas)
                 parallel(oc)
                 parallel(bf)
             */
        t.task_id
      , t.task_number
      , t.task_type_id
      , tt.rule task_type_rule
      , nvl(bf.enabled,'N') break_fix_flag
      , case
          -- R12 impact
          when t.task_split_flag = 'D' then 'N'
          when nvl(tt.rule,'X') = 'DISPATCH' and
               nvl(bf.enabled,'N') = 'Y' and
               'Y' in (t.task_closed_flag,t.task_completed_flag) and
               t.incident_date >= g_global_start_date then 'Y'
          else 'N'
        end task_ttr_ftf_flag
      , case
          -- R12 impact
          when t.task_split_flag = 'D' then to_date(null)
          when nvl(tt.rule,'X') = 'DISPATCH' and
               nvl(bf.enabled,'N') = 'Y' and
               'Y' in (t.task_closed_flag,t.task_completed_flag) and
               t.incident_date >= g_global_start_date then t.task_actual_start_date
          else null
        end task_ttr_ftf_actual_start_date
      , case
          -- R12 impact
          when t.task_split_flag = 'D' then to_date(null)
          when nvl(tt.rule,'X') = 'DISPATCH' and
               nvl(bf.enabled,'N') = 'Y' and
               'Y' in (t.task_closed_flag,t.task_completed_flag) and
               t.incident_date >= g_global_start_date then t.task_actual_end_date
          else null
        end task_ttr_ftf_actual_end_date
      , case
          -- R12 impact
          when t.task_split_flag = 'D' then to_date(null)
          when nvl(tt.rule,'X') = 'DISPATCH' and
               nvl(bf.enabled,'N') = 'Y' and
               'Y' in (t.task_closed_flag,t.task_completed_flag) and
               t.incident_date >= g_global_start_date then t.task_scheduled_start_date
          else null
        end task_ttr_ftf_sched_start_date
      , case
          -- R12 impact
          when t.task_split_flag = 'D' then to_date(null)
          when nvl(tt.rule,'X') = 'DISPATCH' and
               nvl(bf.enabled,'N') = 'Y' and
               'Y' in (t.task_closed_flag,t.task_completed_flag) and
               t.incident_date >= g_global_start_date then t.task_scheduled_end_date
          else null
        end task_ttr_ftf_sched_end_date
      , t.task_status_id
      , t.task_owner_id
      -- R12 resource type impact
      , t.task_owner_type
      , decode( t.task_owner_type
              , 'GROUP', t.task_owner_id
              , nvl(dgt.group_id,-1)
              ) task_district_id
      , t.customer_id
      , t.address_id
      -- R12 impact
      , t.location_id
      , t.task_planned_start_date
      , t.task_planned_end_date
      , t.task_actual_start_date
      , t.task_actual_end_date
      , t.task_scheduled_start_date
      , t.task_scheduled_end_date
      , t.source_object_type_code
      , t.source_object_id
      , t.source_object_name
      , t.task_planned_effort
      , t.task_actual_effort
      , t.task_planned_effort_uom
      , t.task_actual_effort_uom
      , t.task_creation_date
      , t.task_cancelled_flag
      , t.task_completed_flag
      , t.task_closed_flag
      , row_number() over( partition by t.task_id
                           order by t.asgn_creation_date
                         ) task_rn
      , 'N' task_deleted_flag
      --
      , t.task_assignment_id
      , t.asgn_creation_date
      , t.asgn_resource_id
      -- R12 resource type impact
      , t.asgn_resource_type
      , decode( t.asgn_resource_type
              , 'GROUP', t.asgn_resource_id
              , nvl(dga.group_id,-1)
              ) asgn_district_id
      , t.asgn_actual_effort
      , t.asgn_actual_effort_uom
      , t.sched_travel_distance
      , t.sched_travel_duration
      , t.sched_travel_duration_uom
      , t.actual_travel_distance
      , t.actual_travel_duration
      , t.actual_travel_duration_uom
      , t.asgn_actual_start_date
      , t.asgn_actual_end_date
      , nvl(tas.cancelled_flag,'N') asgn_cancelled_flag
      --
      -- activity/backlog
      -- only return non-null resource type code for uncancelled
      -- only return non-null resource id for uncancelled
      , decode( nvl(tas.cancelled_flag,'N')
              , 'N', t.asgn_resource_id
              , null ) act_bac_resource_id
      -- R12 resource type impact
      , decode( nvl(tas.cancelled_flag,'N')
              , 'N', t.asgn_resource_type
              , null ) act_bac_resource_type
      -- only return non-null district id for uncancelled
      -- R12 resource type impact
      , decode( nvl(tas.cancelled_flag,'N')
              , 'N', decode( t.asgn_resource_type
                           , 'GROUP', t.asgn_resource_id
                           , 'TEAM', -1
                           , 'RESOURCE', nvl(dga.group_id,-1)
                           , dga.group_id
                           )
              , null ) act_bac_district_id
      --
      -- ftf/ttr
      -- return resource type code of assignments with actual end date, or un-cancelled
      -- return resource id of assignments with actual end date, or un-cancelled
      , decode( t.asgn_actual_end_date
              , null, decode( nvl(tas.cancelled_flag,'N')
                            , 'N', t.asgn_resource_id
                            , null )
              , t.asgn_resource_id ) ftf_ttr_resource_id
      -- R12 resource type impact
      , decode( t.asgn_actual_end_date
              , null, decode( nvl(tas.cancelled_flag,'N')
                            , 'N', t.asgn_resource_type
                            , null )
              , t.asgn_resource_type ) ftf_ttr_resource_type
      -- return district id of assignments with actual end date, or un-cancelled
      -- R12 resource type impact
      , decode( t.asgn_actual_end_date
              , null, decode( nvl(tas.cancelled_flag,'N')
                            , 'N', decode( t.asgn_resource_type
                                         , 'GROUP', t.asgn_resource_id
                                         , 'TEAM', -1
                                         , 'RESOURCE', nvl(dga.group_id,-1)
                                         , dga.group_id
                                         )
                            , null )
              , decode( t.asgn_resource_type
                      , 'GROUP', t.asgn_resource_id
                      , 'TEAM', -1
                      , 'RESOURCE', nvl(dga.group_id,-1)
                      , dga.group_id
                      )
              ) ftf_ttr_district_id
      -- return non-null creation date for un-cancelled
      , decode( nvl(tas.cancelled_flag,'N')
              , 'N', t.asgn_creation_date
              , null ) asgn_creation_date_unc
      --
      -- R12 dep/arr
      , oc.object_capacity_id
      , trunc(oc.end_date_time) capacity_date
      , ( oc.end_date_time - oc.start_date_time) * 24 capacity_hours
      , decode( oc.status
              , 1, 'N'
              , 0, 'Y'
              , null
              ) blocked_trip_flag
      -- R12 dep/arr
      --
      , t.incident_date
      , t.inventory_item_id
      , t.inv_organization_id
      --
      -- R12 impact
      , t.task_split_flag
      , t.parent_task_id
      --
      from
        ( -- need to nest this as an inline view to allow for
          -- chaining of outer joins
          select /*+ no_merge parallel(t)
                     parallel(ta)
                     parallel(ts)
                     parallel(i)
                     parallel(a)
                     use_hash(t,ta,i) pq_distribute(A,hash,hash) pq_distribute(I,hash,hash)
                 */
            t.source_object_type_code
          , t.source_object_id
          , t.source_object_name
          , t.task_id
          , t.task_number
          , t.task_status_id
          , t.task_type_id
          -- R12 resource type impact
          , t.owner_id task_owner_id
          , decode( t.owner_type_code
                  , 'RS_GROUP', 'GROUP'
                  , 'RS_TEAM', 'TEAM'
                  , null, null
                  , 'RESOURCE'
                  ) task_owner_type
          , t.customer_id
          , t.address_id
          -- R12 impact
          , t.location_id
          , t.planned_start_date task_planned_start_date
          , t.planned_end_date task_planned_end_date
          , t.actual_start_date task_actual_start_date
          , t.actual_end_date task_actual_end_date
          , t.scheduled_start_date task_scheduled_start_date
          , t.scheduled_end_date task_scheduled_end_date
          , t.planned_effort task_planned_effort
          , t.planned_effort_uom task_planned_effort_uom
          , t.actual_effort task_actual_effort
          , t.actual_effort_uom task_actual_effort_uom
          , t.creation_date task_creation_date
          , nvl(ts.cancelled_flag,'N') task_cancelled_flag
          , nvl(ts.completed_flag,'N') task_completed_flag
          , nvl(ts.closed_flag,'N') task_closed_flag
          --
          -- R12 resource type impact
          , ta.resource_id asgn_resource_id
          , decode( ta.resource_type_code
                  , 'RS_GROUP', 'GROUP'
                  , 'RS_TEAM', 'TEAM'
                  , null, null
                  , 'RESOURCE'
                  ) asgn_resource_type
          , ta.creation_date asgn_creation_date
          , ta.task_assignment_id
          , ta.assignment_status_id
          -- R12 dep/arr
          , ta.object_capacity_id
          , ta.actual_effort asgn_actual_effort
          , ta.actual_effort_uom asgn_actual_effort_uom
          , ta.sched_travel_distance
          , ta.sched_travel_duration
          , ta.sched_travel_duration_uom
          , ta.actual_travel_distance
          , ta.actual_travel_duration
          , ta.actual_travel_duration_uom
          , ta.actual_start_date asgn_actual_start_date
          , ta.actual_end_date asgn_actual_end_date
          --
          , i.incident_date
          , nvl2( i.inventory_item_id+i.inv_organization_id
                , i.inventory_item_id
                , -1 ) inventory_item_id
          , nvl2( i.inventory_item_id+i.inv_organization_id
                , i.inv_organization_id
                , -99 )inv_organization_id
          --
          -- R12 impact
          , t.task_split_flag
          , t.parent_task_id
          --
          from
            jtf_tasks_b t
          , jtf_task_assignments ta
          , jtf_task_statuses_b ts
          , cs_incidents_all_b i
          , ( select /*+ no_merge parallel(a) */
                distinct task_id
              from
                jtf_task_audits_b a
              where
                  new_source_object_type_code = 'SR'
              and creation_date >= l_collect_from_date
            ) a
          where
              t.task_id = ta.task_id(+)
          and t.task_status_id = ts.task_status_id
          and ( (
                  -- include all SR tasks with a creation_date on/after GSD
                  t.source_object_type_code = 'SR' and
                  -- don't restrict to just rule of 'DISPATCH' as
                  -- could subsequently change type and we would
                  -- miss out on the backlog/activity
                  -- and tt.rule = 'DISPATCH'
                  t.creation_date >= l_collect_from_date
                ) or
                  -- include all SR tasks current in backlog
                ( t.source_object_type_code = 'SR' and
                  nvl(ts.closed_flag,'N') = 'N'
                ) or
                  -- include all SR tasks in backlog at GSD
                  -- actually considering all SR tasks that have an audit
                  -- row on/after GSD as this suggests they were created
                  -- prior to GSD and were "probably" open at GSD (is does
                  -- matter if we pick up some closed ones as they will
                  -- never be measured)
                ( t.source_object_type_code = 'SR' and
                  a.task_id is not null
                ) or
                     -- R12 dep/arr
                     -- include all dep tasks
                     -- with a planned_start_date on/after GSD
                ( t.source_object_type_code = 'TASK' and
                  t.task_type_id = 20 and
                     -- R12 dep/arr
                  t.planned_start_date >= l_collect_from_date
                )
              )
          and nvl(t.deleted_flag,'N') <> 'Y'
          and decode( t.source_object_type_code
                    , 'SR', t.source_object_id
                    , -777 ) = i.incident_id(+)
          and decode( t.source_object_type_code
                    , 'SR', t.task_id
                    , -777 ) = a.task_id(+)
          and ( t.source_object_type_code = 'TASK' or
                ( t.source_object_type_code = 'SR' and t.customer_id is not null )
                -- ignore SR tasks with NULL customer_id
              )
        ) t
      , jtf_task_types_b tt
      , jtf_rs_default_groups dgt
      , jtf_rs_default_groups dga
      , jtf_task_statuses_b tas
      -- R12 dep/arr
      , cac_sr_object_capacity oc
      -- R12 dep/arr
      , isc_fs_break_fix_tasks bf
      where
          t.task_type_id = tt.task_type_id
      -- R12 resource type impact
      and decode( t.task_owner_type
                , 'RESOURCE', nvl(t.task_owner_id,-2)
                , -2
                ) = dgt.resource_id(+)
      and decode( t.source_object_type_code
                , 'SR', trunc(t.task_creation_date)
                , trunc(t.task_planned_start_date) ) >= dgt.start_date(+)
      and decode( t.source_object_type_code
                , 'SR', trunc(t.task_creation_date)
                , trunc(t.task_planned_start_date) ) <= dgt.end_date(+)
      and 'FLD_SRV_DISTRICT' = dgt.usage(+)
      -- R12 resource type impact
      and decode( t.asgn_resource_type
                , 'RESOURCE', nvl(t.asgn_resource_id,-2)
                , -2
                ) = dga.resource_id(+)
      and decode( t.source_object_type_code
                , 'SR', trunc(nvl(t.asgn_creation_date,sysdate))
                , trunc(t.task_planned_start_date) ) >= dga.start_date(+)
      and decode( t.source_object_type_code
                , 'SR', trunc(nvl(t.asgn_creation_date,sysdate))
                , trunc(t.task_planned_start_date) ) <= dga.end_date(+)
      and 'FLD_SRV_DISTRICT' = dga.usage(+)
      and nvl(t.assignment_status_id,-123) = tas.task_status_id(+)
      -- R12 dep/arr
      and nvl(t.object_capacity_id,-123) = oc.object_capacity_id(+)
      -- R12 dep/arr
      and t.task_type_id = bf.task_type_id(+)
    ) x
  , mtl_uom_conversions t_eff
  , mtl_uom_conversions t_peff
  , mtl_uom_conversions ta_eff
  , mtl_uom_conversions ta_std
  , mtl_uom_conversions ta_atd
  where
  --
      t_peff.inventory_item_id = 0
  and t_peff.uom_class = g_time_uom_class
  and t_peff.uom_code = nvl(x.task_planned_effort_uom,g_uom_hours)
  --
  and t_eff.inventory_item_id = 0
  and t_eff.uom_class = g_time_uom_class
  and t_eff.uom_code = nvl(x.task_actual_effort_uom,g_uom_hours)
  --
  and ta_eff.inventory_item_id = 0
  and ta_eff.uom_class = g_time_uom_class
  and ta_eff.uom_code = nvl(x.asgn_actual_effort_uom,g_uom_hours)
  --
  and ta_std.inventory_item_id = 0
  and ta_std.uom_class = g_time_uom_class
  and ta_std.uom_code = nvl(x.sched_travel_duration_uom,g_uom_hours)
  --
  and ta_atd.inventory_item_id = 0
  and ta_atd.uom_class = g_time_uom_class
  and ta_atd.uom_code = nvl(x.actual_travel_duration_uom,g_uom_hours)
  --
  ;

  l_rowcount := sql%rowcount;

  commit;

  bis_collection_utilities_log( l_rowcount || ' rows inserted into base summaries', 1 );

  l_stmt_id := 110;
  bis_collection_utilities.wrapup( p_status => true
                                 , p_period_from => l_collect_from_date
                                 , p_period_to => l_collect_to_date
                                 , p_count => l_rowcount
                                 , p_attribute1 => g_ttr_ftf_rule
                                 );

  bis_collection_utilities_log('End Initial Load');

  errbuf := null;
  retcode := g_success;

exception
  when g_bis_setup_exception then
    rollback;
    errbuf := l_error_message;
    retcode := g_error;
    bis_collection_utilities_log('End Initial Load with Error');

  when l_exception then
    rollback;
    if l_error_message is null then
      l_error_message := substr(sqlerrm,1,4000);
    end if;
    bis_collection_utilities.wrapup( p_status => false
                                   , p_message => l_error_message
                                   , p_period_from => l_collect_from_date
                                   , p_period_to => l_collect_to_date
                                   );
    errbuf := l_error_message;
    retcode := g_error;
    bis_collection_utilities_log('End Initial Load with Error');

  when others then
    rollback;
    if l_error_message is null then
      l_error_message := substr(sqlerrm,1,4000);
    end if;
    logger( l_proc_name, l_stmt_id, l_error_message );
    bis_collection_utilities.wrapup( p_status => false
                                   , p_message => l_error_message
                                   , p_period_from => l_collect_from_date
                                   , p_period_to => l_collect_to_date
                                   );
    errbuf := l_error_message;
    retcode := g_error;
    bis_collection_utilities_log('End Initial Load with Error');

end initial_load;

procedure incremental_load
( errbuf out nocopy varchar2
, retcode out nocopy number
)
as

  l_proc_name constant varchar2(30) := 'incremental_load';
  l_stmt_id number;
  l_exception exception;
  l_error_message varchar2(4000);
  l_isc_schema varchar2(100);

  l_rowcount number;
  l_temp_rowcount number;

  l_collect_from_date date;
  l_collect_to_date date;

  l_resource_busy exception;
  pragma exception_init(l_resource_busy, -54);

begin

  local_init;

  bis_collection_utilities_log( 'Begin Incremental Load' );

  l_stmt_id := 0;
  if not bis_collection_utilities.setup( g_object_name ) then
    l_error_message := 'Error in BIS_COLLECTION_UTILITIES.Setup';
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise g_bis_setup_exception;
  end if;

  -- determine the date we last collected to
  l_stmt_id := 10;
  if get_last_refresh_date(l_collect_to_date, l_error_message) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;
  l_collect_from_date := l_collect_to_date + 1/86400;
  l_collect_to_date := sysdate;

  bis_collection_utilities_log( 'From: ' || fnd_date.date_to_displaydt(l_collect_from_date), 1 );
  bis_collection_utilities_log( 'To: ' || fnd_date.date_to_displaydt(l_collect_to_date), 1 );

  -- check MTTR/FTFR district rule
  l_stmt_id := 20;
  if check_district_rule
     ( l_proc_name
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  -- get the isc schema name
  l_stmt_id := 30;
  if get_schema_name
     ( l_isc_schema
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  -- truncate the staging table isc_fs_events_stg
  l_stmt_id := 40;
  if truncate_table
     ( l_isc_schema
     , 'ISC_FS_EVENTS_STG'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities_log( 'Staging table truncated', 1 );

  -- insert into staging table from events table
  l_stmt_id := 40;
  insert into isc_fs_events_stg
  ( source
  , event_rowid
  , task_id
  , source_object_type_code
  , source_object_id
  , task_assignment_id
  )
  select
    1
  , rowid
  , task_id
  , source_object_type_code
  , source_object_id
  , task_assignment_id
  from
    isc_fs_events;

  l_rowcount := sql%rowcount;
  commit;

  bis_collection_utilities_log( l_rowcount || ' rows inserted into staging table from events', 1 );

  -- insert into staging table from party merge events table
  l_stmt_id := 50;
  insert into isc_fs_events_stg
  ( source
  , event_rowid
  , task_id
  , source_object_type_code
  , source_object_id
  )
  select
    2
  , rowid
  , task_id
  , source_object_type_code
  , source_object_id
  from
    isc_fs_party_merge_events;

  l_rowcount := sql%rowcount;
  commit;

  bis_collection_utilities_log( l_rowcount || ' rows inserted into staging table from party mearge events', 1 );

  -- gather stats for staging table
  l_stmt_id := 60;
  if gather_statistics
     ( l_isc_schema
     , 'ISC_FS_EVENTS_STG'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities_log( 'Gathered stats for staging table', 1 );

  -- do the merge into isc_fs_task_assignmnts_f
  l_stmt_id := 70;
  merge into isc_fs_task_assignmnts_f o
  using (
    select /*+ ordered use_nl(TA,TS,T_SCH,T_ACT,E_ACT,DGA) */
      -- deleted task assignments are moved to negative task_id
      -- to break join with isc_fs_tasks_f later
      nvl(ta.task_id,0-e.task_id) task_id
    , e.task_assignment_id
    , decode(ta.task_id,null,'Y','N') deleted_flag
    , nvl(ts.cancelled_flag,'N') cancelled_flag
    , ta.creation_date assignment_creation_date
    -- R12 resource type impact
    , ta.resource_id resource_id
    , decode( ta.resource_type_code
            , 'RS_GROUP', 'GROUP'
            , 'RS_TEAM', 'TEAM'
            , null, null
            , 'RESOURCE'
            ) resource_type
    , decode( ta.resource_type_code
            , 'RS_GROUP', ta.resource_id
            , nvl(dga.group_id,-1)
            ) district_id
    , (ta.actual_effort * e_act.conversion_rate * g_time_base_to_hours) actual_effort_hrs
    , ta.sched_travel_distance sched_travel_distance_km
    , (ta.sched_travel_duration * t_sch.conversion_rate * g_time_base_to_hours) * 60 sched_travel_duration_min
    , ta.actual_travel_distance actual_travel_distance_km
    , (ta.actual_travel_duration * t_act.conversion_rate * g_time_base_to_hours) * 60 actual_travel_duration_min
    , ta.actual_start_date
    , ta.actual_end_date
    , case
        when decode(ta.task_id,null,'Y','N') = 'N' and
             ta.actual_end_date >= g_global_start_date then
          trunc(ta.actual_end_date)
        else
          null
      end report_date
    from
      jtf_task_assignments ta
    , ( select /*+ NO_MERGE */ distinct
          task_id
        , task_assignment_id
        from
          isc_fs_events_stg
        where task_assignment_id is not null
        and source_object_type_code = 'SR'
      ) e
    , jtf_rs_default_groups dga
    , jtf_task_statuses_b ts
    , mtl_uom_conversions t_sch
    , mtl_uom_conversions t_act
    , mtl_uom_conversions e_act
    where
        -- needs to be out to handle deleted assignments
        e.task_assignment_id = ta.task_assignment_id(+)
        -- needs nvl/outer to handle deleted assignments
    and nvl(ta.assignment_status_id,-1) = ts.task_status_id(+)
    and t_sch.inventory_item_id = 0
    and t_sch.uom_class = g_time_uom_class
    and t_sch.uom_code = nvl(ta.sched_travel_duration_uom,g_uom_hours)
    and t_act.inventory_item_id = 0
    and t_act.uom_class = g_time_uom_class
    and t_act.uom_code = nvl(ta.actual_travel_duration_uom,g_uom_hours)
    and e_act.inventory_item_id = 0
    and e_act.uom_class = g_time_uom_class
    and e_act.uom_code = nvl(ta.actual_effort_uom,g_uom_hours)
    --
    and decode( ta.resource_type_code
              , null, -2
              , 'RS_GROUP', -2
              , 'RS_TEAM', -2
              , ta.resource_id ) = dga.resource_id(+)
    and trunc(nvl(ta.creation_date,sysdate)) >= dga.start_date(+)
    and trunc(nvl(ta.creation_date,sysdate)) <= dga.end_date(+)
    and 'FLD_SRV_DISTRICT' = dga.usage(+)
  ) n
  on (
    o.task_assignment_id = n.task_assignment_id
  )
  when matched then
    update
    set
      o.task_id = n.task_id
    , o.deleted_flag = n.deleted_flag
    , o.cancelled_flag = n.cancelled_flag
    , o.resource_id = n.resource_id
    -- R12 resource type impact
    , o.resource_type = n.resource_type
    , o.district_id = n.district_id
    , o.actual_effort_hrs = n.actual_effort_hrs
    , o.sched_travel_distance_km = n.sched_travel_distance_km
    , o.sched_travel_duration_min = n.sched_travel_duration_min
    , o.actual_travel_distance_km = n.actual_travel_distance_km
    , o.actual_travel_duration_min = n.actual_travel_duration_min
    , o.actual_start_date = n.actual_start_date
    , o.actual_end_date = n.actual_end_date
    , o.report_date = n.report_date
    , o.last_updated_by = g_user_id
    , o.last_update_date = l_collect_to_date -- don't use sysdate as need to synchronize dates
    , o.last_update_login = g_login_id
    , o.program_id = g_program_id
    , o.program_login_id = g_program_login_id
    , o.program_application_id = g_program_application_id
    , o.request_id = g_request_id
  when not matched then
    insert
    ( task_id
    , task_assignment_id
    , deleted_flag
    , cancelled_flag
    , assignment_creation_date
    , resource_id
    -- R12 resource type impact
    , resource_type
    , district_id
    , actual_effort_hrs
    , sched_travel_distance_km
    , sched_travel_duration_min
    , actual_travel_distance_km
    , actual_travel_duration_min
    , actual_start_date
    , actual_end_date
    , report_date
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , program_id
    , program_login_id
    , program_application_id
    , request_id
    )
    values
    ( n.task_id
    , n.task_assignment_id
    , n.deleted_flag
    , n.cancelled_flag
    , n.assignment_creation_date
    , n.resource_id
    -- R12 resource type impact
    , n.resource_type
    , n.district_id
    , n.actual_effort_hrs
    , n.sched_travel_distance_km
    , n.sched_travel_duration_min
    , n.actual_travel_distance_km
    , n.actual_travel_duration_min
    , n.actual_start_date
    , n.actual_end_date
    , n.report_date
    , g_user_id
    , l_collect_to_date -- don't use sysdate as need to synchronize dates
    , g_user_id
    , l_collect_to_date -- don't use sysdate as need to synchronize dates
    , g_login_id
    , g_program_id
    , g_program_login_id
    , g_program_application_id
    , g_request_id
  );

  l_rowcount := sql%rowcount;

  bis_collection_utilities_log( l_rowcount || ' rows merged into task assignments base summary', 1 );

  -- do the merge into isc_fs_tasks_f
  l_stmt_id := 80;
  merge into isc_fs_tasks_f o
  using (
    select
      task_id
    , task_number
    , task_type_id
    , task_type_rule
    , break_fix_flag
    , task_status_id
    , owner_id
    -- R12 resource type impact
    , owner_type
    , owner_district_id
    , customer_id
    , address_id
    -- R12 impact
    , location_id
    , planned_start_date
    , planned_end_date
    , scheduled_start_date
    , scheduled_end_date
    , actual_start_date
    , actual_end_date
    , source_object_type_code
    , source_object_id
    , source_object_name
    , planned_effort_hrs
    , actual_effort_hrs
    , cancelled_flag
    , completed_flag
    , closed_flag
    , deleted_flag
    , task_creation_date
    -- R12 impact null value for first_asgn_creation_date for "child" task
    , decode(task_split_flag,'D',to_date(null),first_asgn_creation_date) first_asgn_creation_date
    --
    -- R12 impact null value for act_bac_assignee_id for "child" task
    , decode(task_split_flag,'D',to_number(null),nvl(act_bac_assignee_id,owner_id)) act_bac_assignee_id
    -- R12 resource type impact
    , decode(task_split_flag,'D',null,nvl(act_bac_assignee_type,owner_type)) act_bac_assignee_type
    -- R12 impact null value for act_bac_district_id for "child" task
    , decode(task_split_flag,'D',to_number(null),nvl(act_bac_district_id,owner_district_id)) act_bac_district_id
    , include_task_in_ttr_flag
    , include_task_in_ftf_flag
    , ftf_flag
    --
    -- R12 impact null value for ftf_assignee_id for "child" task
    , decode(task_split_flag,'D',to_number(null),nvl(ftf_assignee_id,owner_id)) ftf_assignee_id
    -- R12 resource type impact
    , decode(task_split_flag,'D',null,nvl(ftf_assignee_type,owner_type)) ftf_assignee_type
    -- R12 impact null value for ftf_district_id for "child" task
    , decode(task_split_flag,'D',to_number(null),nvl(ftf_district_id,owner_district_id)) ftf_district_id
    --
    -- R12 impact null value for ttr_assignee_id for "child" task
    , decode(task_split_flag,'D',to_number(null),nvl(ttr_assignee_id,owner_id)) ttr_assignee_id
    -- R12 resource type impact
    , decode(task_split_flag,'D',null,nvl(ttr_assignee_type,owner_type)) ttr_assignee_type
    -- R12 impact null value for ttr_district_id for "child" task
    , decode(task_split_flag,'D',to_number(null),nvl(ttr_district_id,owner_district_id)) ttr_district_id
    --
    , incident_date
    , inventory_item_id
    , inv_organization_id
    , task_split_flag
    , parent_task_id
    from
         -- note: the select statement for the incremental load logic has been
         -- been rewritten to match the initial load.  this was necessary to
         -- accommodate the multiple levels of across aggregation which could
         -- not be included in the previous logic.
      (
      /* needs to be reviewed by performance team for r12 as changed from 11i */
      select
      --
      -- simple columns
      --
        x.task_id
      , x.task_rn
      , x.task_number
      , x.task_type_id
      , x.task_type_rule
      , x.break_fix_flag
      , x.task_status_id
      , x.owner_id
      -- R12 resource type impact
      , x.owner_type
      , x.owner_district_id
      , x.customer_id
      , x.address_id
      -- R12 impact
      , x.location_id
      , x.planned_start_date
      , x.planned_end_date
      , x.scheduled_start_date
      , x.scheduled_end_date
      , x.actual_start_date
      , x.actual_end_date
      , x.source_object_type_code
      , x.source_object_id
      , x.source_object_name
      , x.planned_effort_hrs
      , x.actual_effort_hrs
      , x.task_creation_date
      , x.cancelled_flag
      , x.completed_flag
      , x.closed_flag
      , x.deleted_flag
      --
      , x.incident_date
      , x.inventory_item_id
      , x.inv_organization_id
      --
      , x.task_split_flag
      , x.parent_task_id
      --
      --
      -- complex columns
      --
      -- returns the date of the first created (not cancelled) assignment for the task
      , min( x.asgn_creation_date_unc )
             keep( dense_rank first
                   order by x.asgn_creation_date_unc nulls last
                 )
             over( partition by nvl(x.parent_task_id,x.task_id) ) first_asgn_creation_date
      --
      -- assignee/district are determined uniquely for activity/backlog, ftf and ttr
      -- as they have different rules for establishing ownership and dealing with
      -- cancelled assignments.
      --
      -- activity/backlog
      -- based on last assignment creation date of non-cancelled assignments, in the case of
      -- split "parent" tasks, it is from the last "scheduled" "child" task assignments.
      --
      , max( x.act_bac_resource_id )
             keep( dense_rank last
                   order by
                     x.scheduled_end_date
                   , x.asgn_creation_date_unc nulls first
                   , x.asgn_creation_date -- always use creation_date ahead of xxx_id for RAC
                   , x.task_assignment_id )
             over( partition by nvl(x.parent_task_id,x.task_id) ) act_bac_assignee_id
      -- R12 resource type impact
      , max( x.act_bac_resource_type )
             keep( dense_rank last
                   order by
                     x.scheduled_end_date
                   , x.asgn_creation_date_unc nulls first
                   , x.asgn_creation_date -- always use creation_date ahead of xxx_id for RAC
                   , x.task_assignment_id )
             over( partition by nvl(x.parent_task_id,x.task_id) ) act_bac_assignee_type
      --
      , max( x.act_bac_district_id )
             keep( dense_rank last
                   order by
                     x.scheduled_end_date
                   , x.asgn_creation_date_unc nulls first
                   , x.asgn_creation_date -- always use creation_date ahead of xxx_id for RAC
                   , x.task_assignment_id )
             over( partition by nvl(x.parent_task_id,x.task_id) ) act_bac_district_id
      --
      -- ftf
      -- based on last assignment creation date, exclude cancelled assignments unless
      -- they have actual_end_date not null
      --
      , max( x.ftf_ttr_resource_id )
             keep( dense_rank last
                   order by
                     x.scheduled_end_date
                   , x.asgn_creation_date_unc nulls first
                   , x.asgn_creation_date -- always use creation_date ahead of xxx_id for RAC
                   , x.task_assignment_id)
             over( partition by nvl(x.parent_task_id,x.task_id) ) ftf_assignee_id
      -- R12 resource type impact
      , max( x.ftf_ttr_resource_type )
             keep( dense_rank last
                   order by
                     x.scheduled_end_date
                   , x.asgn_creation_date_unc nulls first
                   , x.asgn_creation_date -- always use creation_date ahead of xxx_id for RAC
                   , x.task_assignment_id)
             over( partition by nvl(x.parent_task_id,x.task_id) ) ftf_assignee_type
      --
      , max( x.ftf_ttr_district_id )
             keep( dense_rank last
                   order by
                     x.scheduled_end_date
                   , x.asgn_creation_date_unc nulls first
                   , x.asgn_creation_date -- always use creation_date ahead of xxx_id for RAC
                   , x.task_assignment_id)
             over( partition by nvl(x.parent_task_id,x.task_id) ) ftf_district_id
      --
      -- ttr
      -- based on the last worked (assignment actual end date), exclude cancelled assignments unless
      -- they have actual_end_date not null
      --
      , max( x.ftf_ttr_resource_id )
             keep( dense_rank last
                   order by
                     x.asgn_actual_end_date nulls first
                   , x.asgn_creation_date -- always use creation_date ahead of xxx_id for RAC
                   , x.task_assignment_id )
             over( partition by nvl(x.parent_task_id,x.task_id) ) ttr_assignee_id
      -- R12 resource type impact
      , max( x.ftf_ttr_resource_type )
             keep( dense_rank last
                   order by
                     x.asgn_actual_end_date nulls first
                   , x.asgn_creation_date -- always use creation_date ahead of xxx_id for RAC
                   , x.task_assignment_id )
             over( partition by nvl(x.parent_task_id,x.task_id) ) ttr_assignee_type
      --
      , max( x.ftf_ttr_district_id )
             keep( dense_rank last
                   order by
                     x.asgn_actual_end_date nulls first
                   , x.asgn_creation_date -- always use creation_date ahead of xxx_id for RAC
                   , x.task_assignment_id )
             over( partition by nvl(x.parent_task_id,x.task_id) ) ttr_district_id
      --
      --
      -- ttr
      -- only rows (one per SR) with 'Y' are included in ttr reports
      -- a) not deleted, type rule = DISPATCH, break/fix enabled
      -- b) latest actual end date, if no actual end dates, latest scheduled end date
      -- c) "normal" or "parent" tasks
      , case
          when x.ttr_ftf_flag <> 'Y' then 'N'
          when rank() over( partition by
                              x.source_object_type_code
                            , x.source_object_id
                            order by
                              x.ttr_ftf_flag desc
                            , x.ttr_ftf_actual_end_date desc nulls last
                            , x.ttr_ftf_sched_end_date desc nulls last
                            , x.task_creation_date desc -- always use creation_date ahead of xxx_id for RAC
                            , x.task_id desc
                          ) <> 1 then 'N'
          else 'Y'
        end include_task_in_ttr_flag
      --
      -- ftf
      -- multiple rows per SR with 'Y' are included in non ftf detail report
      -- not deleted, type rule = DISPATCH, break/fix enabled
      -- "normal" or "parent" tasks
      , x.ttr_ftf_flag include_task_in_ftf_flag
      --
      -- ftf
      -- only rows (one per SR) with 'Y' or 'N' are included in ftf reports
      -- a) not deleted, type rule = DISPATCH, break/fix enabled
      -- b) earliest actual start date, if no actual start dates, latest scheduled start date
      -- c) trunc( earliest actual end date ) = trunc ( latest actual end date ) = ftf else non ftf
      -- d) "normal" or "parent" tasks
      , case
          when x.ttr_ftf_flag <> 'Y' then '-'
          when rank() over( partition by
                              x.source_object_type_code
                            , x.source_object_id
                            order by
                              x.ttr_ftf_flag desc
                            , x.ttr_ftf_actual_start_date
                            , x.ttr_ftf_sched_start_date
                            , x.task_creation_date -- always use creation_date ahead of xxx_id for RAC
                            , x.task_id
                          ) <> 1 then '-'
          when trunc( first_value( x.ttr_ftf_actual_start_date ) -- use start_date
                      over( partition by
                              x.source_object_type_code
                            , x.source_object_id
                            order by
                              x.ttr_ftf_flag desc
                            , x.ttr_ftf_actual_start_date nulls last -- use start_date
                            , x.ttr_ftf_sched_start_date nulls last -- use start_date
                            , x.task_creation_date -- always use creation_date ahead of xxx_id for RAC
                            , x.task_id
                            rows between unbounded preceding and unbounded following
                          )
                    ) <>
               trunc( last_value( x.ttr_ftf_actual_start_date ) -- use start_date
                      over( partition by
                              x.source_object_type_code
                            , x.source_object_id
                            order by
                              x.ttr_ftf_flag
                            , x.ttr_ftf_actual_start_date nulls first -- use start_date
                            , x.ttr_ftf_sched_start_date nulls first -- use start_date
                            , x.task_creation_date -- always use creation_date ahead of xxx_id for RAC
                            , x.task_id
                            rows between unbounded preceding and unbounded following
                          )
                    ) then 'N'
          else 'Y'
        end ftf_flag
      --
      from
        ( select
            t.task_id
          , t.task_number
          , t.task_type_id
          , t.task_type_rule
          , t.break_fix_flag
          , row_number() over( partition by t.task_id
                               order by t.asgn_creation_date
                             ) task_rn
          , case
              when t.task_split_flag = 'D' then 'N'
              when nvl(t.task_type_rule,'X') = 'DISPATCH' and
                   t.break_fix_flag = 'Y' and
                   'Y' in (t.closed_flag,t.completed_flag) and
                   t.incident_date >= g_global_start_date then 'Y'
              else 'N'
            end ttr_ftf_flag
          , case
              when t.task_split_flag = 'D' then to_date(null)
              when nvl(t.task_type_rule,'X') = 'DISPATCH' and
                   t.break_fix_flag = 'Y' and
                   'Y' in (t.closed_flag,t.completed_flag) and
                   t.incident_date >= g_global_start_date then t.actual_start_date
              else null
            end ttr_ftf_actual_start_date
          , case
              when t.task_split_flag = 'D' then to_date(null)
              when nvl(t.task_type_rule,'X') = 'DISPATCH' and
                   t.break_fix_flag = 'Y' and
                   'Y' in (t.closed_flag,t.completed_flag) and
                   t.incident_date >= g_global_start_date then t.actual_end_date
              else null
            end ttr_ftf_actual_end_date
          , case
              when t.task_split_flag = 'D' then to_date(null)
              when nvl(t.task_type_rule,'X') = 'DISPATCH' and
                   t.break_fix_flag = 'Y' and
                   'Y' in (t.closed_flag,t.completed_flag) and
                   t.incident_date >= g_global_start_date then t.scheduled_start_date
              else null
            end ttr_ftf_sched_start_date
          , case
              when t.task_split_flag = 'D' then to_date(null)
              when nvl(t.task_type_rule,'X') = 'DISPATCH' and
                   t.break_fix_flag = 'Y' and
                   'Y' in (t.closed_flag,t.completed_flag) and
                   t.incident_date >= g_global_start_date then t.scheduled_end_date
              else null
            end ttr_ftf_sched_end_date
          , t.task_status_id
          , t.owner_id
          -- R12 resource type impact
          , t.owner_type
          , t.owner_district_id
          , t.customer_id
          , t.address_id
          -- R12 impact
          , t.location_id
          , t.planned_start_date
          , t.planned_end_date
          , t.planned_effort_hrs
          , t.actual_start_date
          , t.actual_end_date
          , t.actual_effort_hrs
          , t.scheduled_start_date
          , t.scheduled_end_date
          , t.source_object_type_code
          , t.source_object_id
          , t.source_object_name
          , t.task_creation_date
          , t.cancelled_flag
          , t.completed_flag
          , t.closed_flag
          , t.deleted_flag
          --
          , t.task_assignment_id
          , t.asgn_creation_date
          , t.asgn_resource_id
          -- R12 resource type impact
          , t.asgn_resource_type
          , t.asgn_district_id
          , t.asgn_actual_end_date
          , t.asgn_cancelled_flag
          --
          -- activity/backlog
          -- only return non-null resource type code for uncancelled
          -- only return non-null resource id for uncancelled
          , decode( t.asgn_cancelled_flag
                  , 'N', t.asgn_resource_id
                  , null ) act_bac_resource_id
          -- R12 resource type impact
          , decode( t.asgn_cancelled_flag
                  , 'N', t.asgn_resource_type
                  , null ) act_bac_resource_type
          -- only return non-null district id for uncancelled
          , decode( t.asgn_cancelled_flag
                  , 'N', t.asgn_district_id
                  , null ) act_bac_district_id
          --
          -- ftf/ttr
          -- return resource type code of assignments with actual end date, or un-cancelled
          -- return resource id of assignments with actual end date, or un-cancelled
          , decode( t.asgn_actual_end_date
                  , null, decode( t.asgn_cancelled_flag
                                , 'N', t.asgn_resource_id
                                , null )
                  , t.asgn_resource_id ) ftf_ttr_resource_id
          -- R12 resource type impact
          , decode( t.asgn_actual_end_date
                  , null, decode( t.asgn_cancelled_flag
                                , 'N', t.asgn_resource_type
                                , null )
                  , t.asgn_resource_type ) ftf_ttr_resource_type
          -- return district id of assignments with actual end date, or un-cancelled
          , decode( t.asgn_actual_end_date
                  , null, decode( t.asgn_cancelled_flag
                                , 'N', t.asgn_district_id
                                , null )
                  , t.asgn_district_id ) ftf_ttr_district_id
          -- return non-null creation date for un-cancelled
          , decode( t.asgn_cancelled_flag
                  , 'N', t.asgn_creation_date
                  , null ) asgn_creation_date_unc
          --
          , t.incident_date
          , t.inventory_item_id
          , t.inv_organization_id
          --
          , t.task_split_flag
          , t.parent_task_id
          --
          from
            ( select
                t.source_object_type_code
              -- hide source_object_id for deleted tasks from partitioning above
              , case
                  when t.deleted_flag = 'Y' or
                       t.customer_id is null then
                       -- tasks with null customer_id are invalid
                    0-t.source_object_id
                  else
                    t.source_object_id
                end source_object_id
              , t.source_object_name
              , t.task_id
              , t.task_number
              , t.task_status_id
              , t.task_type_id
              , case
                  when t.customer_id is null or
                       -- tasks with null customer_id are invalid
                       t.deleted_flag = 'Y' then
                    null
                  else
                    tt.rule
                end task_type_rule
              , case
                  when t.customer_id is null or
                       -- tasks with null customer_id are invalid
                       t.deleted_flag = 'Y' then
                    'N'
                  else
                    nvl(bf.enabled,'N')
                end break_fix_flag
              -- R12 resource type impact
              , t.owner_id owner_id
              , decode( t.owner_type_code
                      , 'RS_GROUP', 'GROUP'
                      , 'RS_TEAM', 'TEAM'
                      , null, null
                      , 'RESOURCE'
                      ) owner_type
              , decode( t.owner_type_code
                      , 'RS_GROUP', t.owner_id
                      , nvl(dgt.group_id,-1)
                      ) owner_district_id
              , nvl(t.customer_id,-2) customer_id
              -- allow for null customer_id
              , t.address_id
              -- R12 impact
              , t.location_id
              , t.planned_start_date
              , t.planned_end_date
              , t.actual_start_date
              , t.actual_end_date
              , t.scheduled_start_date
              , t.scheduled_end_date
              , (t.planned_effort * t_peff.conversion_rate * g_time_base_to_hours) planned_effort_hrs
              , (t.actual_effort * t_eff.conversion_rate * g_time_base_to_hours) actual_effort_hrs
              , t.creation_date task_creation_date
              , nvl(ts.cancelled_flag,'N') cancelled_flag
              , nvl(ts.completed_flag,'N') completed_flag
              , nvl(ts.closed_flag,'N') closed_flag
              , decode(t.customer_id,null,'Y',nvl(t.deleted_flag,'N')) deleted_flag
              -- tasks with null customer_id are invalid
              --
              , ta.resource_id asgn_resource_id
              -- R12 resource type impact
              , ta.resource_type asgn_resource_type
              , ta.district_id asgn_district_id
              , ta.assignment_creation_date asgn_creation_date
              , ta.task_assignment_id
              , ta.cancelled_flag asgn_cancelled_flag
              , ta.actual_start_date asgn_actual_start_date
              , ta.actual_end_date asgn_actual_end_date
              --
              , i.incident_date
              , nvl2( i.inventory_item_id+i.inv_organization_id
                    , i.inventory_item_id
                    , -1
                    ) inventory_item_id
              , nvl2( i.inventory_item_id+i.inv_organization_id
                    , i.inv_organization_id
                    , -99
                    )inv_organization_id
              --
              , t.task_split_flag
              -- hide parent_task_id for deleted tasks from partitioning above
              , case
                  when t.deleted_flag = 'Y' or
                       t.customer_id is null then
                       -- tasks with null customer_id are invalid
                    0-t.parent_task_id
                  else
                    t.parent_task_id
                end parent_task_id
              from
                jtf_tasks_b t
              , isc_fs_task_assignmnts_f ta
              , jtf_task_statuses_b ts
              , jtf_task_types_b tt
              , mtl_uom_conversions t_eff
              , mtl_uom_conversions t_peff
              , ( select /*+ NO_MERGE  */ distinct
                    source_object_id
                  from
                    isc_fs_events_stg
                  where
                    source_object_type_code = 'SR'
                ) e
              , cs_incidents_all_b i
              , isc_fs_break_fix_tasks bf
              , jtf_rs_default_groups dgt
              where
                  t.source_object_id = e.source_object_id
              and t.source_object_type_code = 'SR'
              --
              and t.source_object_id = i.incident_id
              --
              and t.task_id = ta.task_id(+)
              --
              and t.task_status_id = ts.task_status_id
              --
              and t.task_type_id = tt.task_type_id
              --
              and t.task_type_id = bf.task_type_id(+)
              --
              -- R12 resource type impact
              and decode( t.owner_type_code
                        , null, -2
                        , 'RS_GROUP', -2
                        , 'RS_TEAM', -2
                        , t.owner_id
                        ) = dgt.resource_id(+)
              and trunc(t.creation_date) >= dgt.start_date(+)
              and trunc(t.creation_date) <= dgt.end_date(+)
              and 'FLD_SRV_DISTRICT' = dgt.usage(+)
              --
              and t_peff.inventory_item_id = 0
              and t_peff.uom_class = g_time_uom_class
              and t_peff.uom_code = nvl(t.planned_effort_uom,g_uom_hours)
              --
              and t_eff.inventory_item_id = 0
              and t_eff.uom_class = g_time_uom_class
              and t_eff.uom_code = nvl(t.actual_effort_uom,g_uom_hours)
            ) t
        ) x
    )
    where task_rn = 1
  ) n
  on ( o.task_id = n.task_id
  )
  when matched then
    update
    set
      o.task_type_id = n.task_type_id
    , o.task_type_rule = n.task_type_rule
    , o.break_fix_flag = n.break_fix_flag
    , o.task_status_id = n.task_status_id
    , o.owner_id = n.owner_id
    -- R12 resource type impact
    , o.owner_type = n.owner_type
    , o.owner_district_id = n.owner_district_id
    , o.customer_id = n.customer_id
    , o.address_id = n.address_id
    -- R12 impact
    , o.location_id = n.location_id
    , o.planned_start_date = n.planned_start_date
    , o.planned_end_date = n.planned_end_date
    , o.scheduled_start_date = n.scheduled_start_date
    , o.scheduled_end_date = n.scheduled_end_date
    , o.actual_start_date = n.actual_start_date
    , o.actual_end_date = n.actual_end_date
    --
    , o.source_object_type_code = n.source_object_type_code
    , o.source_object_id = n.source_object_id
    , o.source_object_name = n.source_object_name
    --
    , o.planned_effort_hrs = n.planned_effort_hrs
    , o.actual_effort_hrs = n.actual_effort_hrs
    , o.cancelled_flag = n.cancelled_flag
    , o.completed_flag = n.completed_flag
    , o.closed_flag = n.closed_flag
    , o.deleted_flag = n.deleted_flag
    , o.first_asgn_creation_date = n.first_asgn_creation_date
    , o.act_bac_assignee_id = n.act_bac_assignee_id
    -- R12 resource type impact
    , o.act_bac_assignee_type = n.act_bac_assignee_type
    , o.act_bac_district_id = n.act_bac_district_id
    , o.ftf_assignee_id = n.ftf_assignee_id
    -- R12 resource type impact
    , o.ftf_assignee_type = n.ftf_assignee_type
    , o.ftf_district_id = n.ftf_district_id
    , o.ttr_assignee_id = n.ttr_assignee_id
    -- R12 resource type impact
    , o.ttr_assignee_type = n.ttr_assignee_type
    , o.ttr_district_id = n.ttr_district_id
    --
    , o.ftf_ttr_district_rule = g_ttr_ftf_rule
    --
    , o.include_task_in_ttr_flag = n.include_task_in_ttr_flag
    , o.include_task_in_ftf_flag = n.include_task_in_ftf_flag
    , o.ftf_flag = n.ftf_flag
    --
    , o.incident_date = n.incident_date
    , o.inventory_item_id = n.inventory_item_id
    , o.inv_organization_id = n.inv_organization_id
    --
    -- R12 impact
    , o.task_split_flag = n.task_split_flag
    , o.parent_task_id = n.parent_task_id
    --
    , o.last_updated_by = g_user_id
    , o.last_update_date = l_collect_to_date -- don't use sysdate as need to synchronize dates
    , o.last_update_login = g_login_id
    , o.program_id = g_program_id
    , o.program_login_id = g_program_login_id
    , o.program_application_id = g_program_application_id
    , o.request_id = g_request_id
  when not matched then
    insert
    ( task_id
    , task_number
    , task_type_id
    , task_type_rule
    , break_fix_flag
    , task_status_id
    , owner_id
    -- R12 resource type impact
    , owner_type
    , owner_district_id
    , customer_id
    , address_id
    -- R12 impact
    , location_id
    , planned_start_date
    , planned_end_date
    , scheduled_start_date
    , scheduled_end_date
    , actual_start_date
    , actual_end_date
    , source_object_type_code
    , source_object_id
    , source_object_name
    , planned_effort_hrs
    , actual_effort_hrs
    , cancelled_flag
    , completed_flag
    , closed_flag
    , deleted_flag
    , task_creation_date
    , first_asgn_creation_date
    , act_bac_assignee_id
    -- R12 resource type impact
    , act_bac_assignee_type
    , act_bac_district_id
    , ftf_assignee_id
    -- R12 resource type impact
    , ftf_assignee_type
    , ftf_district_id
    , ttr_assignee_id
    -- R12 resource type impact
    , ttr_assignee_type
    , ttr_district_id
    , ftf_ttr_district_rule
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , program_id
    , program_login_id
    , program_application_id
    , request_id
    --
    , include_task_in_ttr_flag
    , include_task_in_ftf_flag
    , ftf_flag
    --
    , incident_date
    , inventory_item_id
    , inv_organization_id
    --
    -- R12 impact
    , task_split_flag
    , parent_task_id
    )
    values
    ( n.task_id
    , n.task_number
    , n.task_type_id
    , n.task_type_rule
    , n.break_fix_flag
    , n.task_status_id
    , n.owner_id
    -- R12 resource type impact
    , n.owner_type
    , n.owner_district_id
    , n.customer_id
    , n.address_id
    -- R12 impact
    , n.location_id
    , n.planned_start_date
    , n.planned_end_date
    , n.scheduled_start_date
    , n.scheduled_end_date
    , n.actual_start_date
    , n.actual_end_date
    , n.source_object_type_code
    , n.source_object_id
    , n.source_object_name
    , n.planned_effort_hrs
    , n.actual_effort_hrs
    , n.cancelled_flag
    , n.completed_flag
    , n.closed_flag
    , n.deleted_flag
    , n.task_creation_date
    , n.first_asgn_creation_date
    , n.act_bac_assignee_id
    -- R12 resource type impact
    , n.act_bac_assignee_type
    , n.act_bac_district_id
    , n.ftf_assignee_id
    -- R12 resource type impact
    , n.ftf_assignee_type
    , n.ftf_district_id
    , n.ttr_assignee_id
    -- R12 resource type impact
    , n.ttr_assignee_type
    , n.ttr_district_id
    --
    , g_ttr_ftf_rule
    , g_user_id
    , l_collect_to_date -- don't use sysdate as need to synchronize dates
    , g_user_id
    , l_collect_to_date -- don't use sysdate as need to synchronize dates
    , g_login_id
    , g_program_id
    , g_program_login_id
    , g_program_application_id
    , g_request_id
    --
    , n.include_task_in_ttr_flag
    , n.include_task_in_ftf_flag
    , n.ftf_flag
    --
    , n.incident_date
    , n.inventory_item_id
    , n.inv_organization_id
    --
    -- R12 impact
    , n.task_split_flag
    , n.parent_task_id
    );

  l_temp_rowcount := sql%rowcount;

  bis_collection_utilities_log( l_temp_rowcount || ' rows merged into tasks base summary', 1 );

  l_rowcount := l_rowcount + l_temp_rowcount;

  -- R12 dep/arr
  -- do the merge into isc_fs_capacity_f
  l_stmt_id := 90;
  merge into isc_fs_capacity_f o
  using (
    select /*+ ordered use_nl(T,TA,DG,OC) */
      t.task_id
    -- R12 resource type impact
    , t.owner_id owner_id
    , decode( t.owner_type_code
            , 'RS_GROUP', 'GROUP'
            , 'RS_TEAM', 'TEAM'
            , null, null
            , 'RESOURCE'
            ) owner_type
    , decode( t.owner_type_code
            , 'RS_GROUP', t.owner_id
            , nvl(dg.group_id,-1)
            ) district_id
    , ta.object_capacity_id
    , trunc(oc.end_date_time) capacity_date
    , (oc.end_date_time - oc.start_date_time ) * 24 capacity_hours
    , decode( oc.STATUS
            , 1, 'N'
            , 0, 'Y'
            , null
            ) blocked_trip_flag
    , decode( t.task_type_id
            , 20, nvl(t.deleted_flag,'N')
            , 'Y'
            ) deleted_flag
    from
      jtf_tasks_b t
    , jtf_task_assignments ta
    , ( select /*+ NO_MERGE */ distinct
          task_id
        from isc_fs_events_stg
        where source_object_type_code = 'TASK'
      ) e
    , jtf_rs_default_groups dg
    , cac_sr_object_capacity oc
    where
        e.task_id = t.task_id
        -- needs to be out to handle deleted assignments
    and t.task_id = ta.task_id(+)
    --
    and decode( t.owner_type_code
              , null, -2
              , 'RS_GROUP', -2
              , 'RS_TEAM', -2
              , t.owner_id ) = dg.resource_id(+)
    and trunc(t.planned_start_date) >= dg.start_date(+)
    and trunc(t.planned_start_date) <= dg.end_date(+)
    and 'FLD_SRV_DISTRICT' = dg.usage(+)
    --
    and nvl(ta.object_capacity_id,-123) = oc.object_capacity_id(+)
  ) n
  on (
    o.task_id = n.task_id
  )
  when matched then
    update
    set
      o.owner_id = n.owner_id
    -- R12 resource type impact
    , o.owner_type = n.owner_type
    , o.district_id = n.district_id
    , o.object_capacity_id = n.object_capacity_id
    , o.capacity_date = n.capacity_date
    , o.capacity_hours = n.capacity_hours
    , o.blocked_trip_flag = n.blocked_trip_flag
    , o.deleted_flag = n.deleted_flag
    , o.last_updated_by = g_user_id
    , o.last_update_date = sysdate
    , o.last_update_login = g_login_id
    , o.program_id = g_program_id
    , o.program_login_id = g_program_login_id
    , o.program_application_id = g_program_application_id
    , o.request_id = g_request_id
  when not matched then
    insert
    ( task_id
    , owner_id
    -- R12 resource type impact
    , owner_type
    , district_id
    , object_capacity_id
    , capacity_date
    , capacity_hours
    , blocked_trip_flag
    , deleted_flag
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    )
    values
    ( n.task_id
    , n.owner_id
    -- R12 resource type impact
    , n.owner_type
    , n.district_id
    , n.object_capacity_id
    , n.capacity_date
    , n.capacity_hours
    , n.blocked_trip_flag
    , n.deleted_flag
    , g_user_id
    , sysdate
    , g_user_id
    , sysdate
    , g_login_id
  );
  -- R12 dep/arr

  l_temp_rowcount := sql%rowcount;

  bis_collection_utilities_log( l_temp_rowcount || ' rows merged into capacity base summary', 1 );

  l_rowcount := l_rowcount + l_temp_rowcount;

  -- delete processed rows from events table
  l_stmt_id := 100;
  delete from isc_fs_events
  where rowid in ( select event_rowid from isc_fs_events_stg where source = 1 );

  l_temp_rowcount := sql%rowcount;

  bis_collection_utilities_log( l_temp_rowcount || ' rows deleted from events table', 1 );

  -- delete processed rows from party merge events table
  l_stmt_id := 110;
  delete from isc_fs_party_merge_events
  where rowid in ( select event_rowid from isc_fs_events_stg where source = 2 );

  l_temp_rowcount := sql%rowcount;

  bis_collection_utilities_log( l_temp_rowcount || ' rows deleted from party merge events table', 1 );

  commit;

  bis_collection_utilities_log( 'Cleaning up..', 1 );

  -- attempt (no fail) to truncate party merge events table is zero rows
  l_stmt_id := 120;
  begin

    lock table isc_fs_party_merge_events in exclusive mode nowait;

    select count(*)
    into l_temp_rowcount
    from isc_fs_party_merge_events;

    if l_temp_rowcount = 0 then
      if truncate_table
         ( l_isc_schema
         , 'ISC_FS_PARTY_MERGE_EVENTS'
         , l_error_message ) <> 0 then
        logger( l_proc_name, l_stmt_id, l_error_message );
        raise l_exception;
      end if;
      bis_collection_utilities_log( 'Party merge events table truncated', 2 );
    else
      bis_collection_utilities_log( l_temp_rowcount || ' new unprocessed rows party merge events table', 2 );
    end if;

  exception
    when l_exception then
      raise l_exception;
    when l_resource_busy then
      bis_collection_utilities_log( 'Unable to lock party merge events table at this time', 2 );
    when others then
      raise;
  end;

  commit;

  -- house keeping -- cleanup staging table
  l_stmt_id := 130;
  if truncate_table
     ( l_isc_schema
     , 'ISC_FS_EVENTS_STG'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities_log( 'Staging table truncated', 2 );

  l_stmt_id := 140;
  bis_collection_utilities.wrapup( p_status => true
                                 , p_period_from => l_collect_from_date
                                 , p_period_to => l_collect_to_date
                                 , p_count => l_rowcount
                                 , p_attribute1 => g_ttr_ftf_rule
                                 );

  bis_collection_utilities_log('End Incremental Load');

  errbuf := null;
  retcode := g_success;

exception
  when g_bis_setup_exception then
    rollback;
    errbuf := l_error_message;
    retcode := g_error;
    bis_collection_utilities_log('End Incremential Load with Error');

  when l_exception then
    rollback;
    if l_error_message is null then
      l_error_message := substr(sqlerrm,1,4000);
    end if;
    bis_collection_utilities.wrapup( p_status => false
                                   , p_message => l_error_message
                                   , p_period_from => l_collect_from_date
                                   , p_period_to => l_collect_to_date
                                   );
    errbuf := l_error_message;
    retcode := g_error;
    bis_collection_utilities_log('End Incremential Load with Error');

  when others then
    rollback;
    if l_error_message is null then
      l_error_message := substr(sqlerrm,1,4000);
    end if;
    logger( l_proc_name, l_stmt_id, l_error_message );
    bis_collection_utilities.wrapup( p_status => false
                                   , p_message => l_error_message
                                   , p_period_from => l_collect_from_date
                                   , p_period_to => l_collect_to_date
                                   );
    errbuf := l_error_message;
    retcode := g_error;
    bis_collection_utilities_log('End Incremential Load with Error');

end incremental_load;

end isc_fs_task_etl_pkg;

/
