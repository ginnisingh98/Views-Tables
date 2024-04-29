--------------------------------------------------------
--  DDL for Package Body ISC_FS_TASK_ACT_BAC_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_FS_TASK_ACT_BAC_ETL_PKG" 
/* $Header: iscfsactbacetlb.pls 120.4 2005/11/24 18:29:59 kreardon noship $ */
as

  g_pkg_name constant varchar2(30) := 'isc_fs_task_act_bac_etl_pkg';
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
  g_max_date constant date := to_date('4712/12/31','yyyy/mm/dd');

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
begin
  g_user_id  := fnd_global.user_id;
  g_login_id := fnd_global.login_id;
  g_global_start_date := bis_common_parameters.get_global_start_date;
  g_program_id := fnd_global.conc_program_id;
  g_program_login_id := fnd_global.conc_login_id;
  g_program_application_id := fnd_global.prog_appl_id;
  g_request_id := fnd_global.conc_request_id;
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
, x_error_message out nocopy varchar2 )
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
, x_error_message out nocopy varchar2
, p_object_name in varchar2 default null
)
return number as

  l_refresh_date date;

begin

  l_refresh_date := fnd_date.displaydt_to_date
                    ( bis_collection_utilities.get_last_refresh_period
                      ( nvl(p_object_name,g_object_name) )
                    );
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

  l_timer number;
  l_rowcount number;
  l_temp_rowcount number;

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

  -- check global start date
  l_stmt_id := 10;
  if g_global_start_date is null then
    l_error_message := 'Unable to get DBI global start date.'; -- translatable message?
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  l_collect_from_date := g_global_start_date;

  -- determine the date we last collected to
  l_stmt_id := 20;
  if get_last_refresh_date
     ( l_collect_to_date
     , l_error_message
     , isc_fs_task_etl_pkg.g_object_name ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities_log( 'From ' || fnd_date.date_to_displaydt(l_collect_from_date), 1 );
  bis_collection_utilities_log( 'To ' || fnd_date.date_to_displaydt(l_collect_to_date), 1 );

  -- get the isc schema name
  l_stmt_id := 30;
  if get_schema_name
     ( l_isc_schema
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  -- truncate the isc_fs_task_activity_f fact table
  l_stmt_id := 40;
  if truncate_table
     ( l_isc_schema
     , 'ISC_FS_TASK_ACTIVITY_F'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities_log( 'Task Activity base summary table truncated', 1 );

  -- truncate the isc_fs_task_backlog_f fact table
  l_stmt_id := 50;
  if truncate_table
     ( l_isc_schema
     , 'ISC_FS_TASK_BACKLOG_F'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities_log( 'Task Backlog base summary table truncated', 1 );

  -- insert into base fact tables
  l_stmt_id := 60;

  insert /*+ append
             parallel(isc_fs_task_activity_f)
             parallel(isc_fs_task_backlog_f)
         */
  ALL
  when 1 in (first_opened, reopened, closed) then
    into isc_fs_task_activity_f
    ( task_id
    , task_audit_id
    , activity_date
    , first_opened
    , reopened
    , closed
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , program_id
    , program_login_id
    , program_application_id
    , request_id
    -- denomalized columns
    , source_object_type_code
    , task_type_id
    , task_type_rule
    , deleted_flag
    , act_bac_assignee_id
    -- R12 resource type impact
    , act_bac_assignee_type
    , act_bac_district_id
    , inventory_item_id
    , inv_organization_id
    , customer_id
    -- denomalized columns
    )
    values
    ( task_id
    , task_audit_id
    , activity_date
    , first_opened
    , reopened
    , closed
    , g_user_id
    , sysdate
    , g_user_id
    , sysdate
    , g_login_id
    , g_program_id
    , g_program_login_id
    , g_program_application_id
    , g_request_id
    -- denomalized columns
    , source_object_type_code
    , task_type_id
    , task_type_rule
    , deleted_flag
    , act_bac_assignee_id
    -- R12 resource type impact
    , act_bac_assignee_type
    , act_bac_district_id
    , inventory_item_id
    , inv_organization_id
    , customer_id
    -- denomalized columns
    )
  when backlog_date_from is not null then
    into isc_fs_task_backlog_f
    ( task_id
    , task_audit_id
    , backlog_date_from
    , backlog_date_to
    , backlog_status_code
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , program_id
    , program_login_id
    , program_application_id
    , request_id
    -- denomalized columns
    , source_object_type_code
    , task_type_id
    , task_type_rule
    , deleted_flag
    , act_bac_assignee_id
    -- R12 resource type impact
    , act_bac_assignee_type
    , act_bac_district_id
    , inventory_item_id
    , inv_organization_id
    , customer_id
    , planned_start_date
    -- denomalized columns
    )
    values
    ( task_id
    , task_audit_id
    , backlog_date_from
    , backlog_date_to
    , backlog_status_code
    , g_user_id
    , sysdate
    , g_user_id
    , sysdate
    , g_login_id
    , g_program_id
    , g_program_login_id
    , g_program_application_id
    , g_request_id
    -- denomalized columns
    , source_object_type_code
    , task_type_id
    , task_type_rule
    , deleted_flag
    , act_bac_assignee_id
    -- R12 resource type impact
    , act_bac_assignee_type
    , act_bac_district_id
    , inventory_item_id
    , inv_organization_id
    , customer_id
    , planned_start_date
    -- denomalized columns
    )
  select /*+ parallel(a)
             parallel(s_new)
             parallel(s_old)
             parallel(e_act)
             use_nl(s_new,s_old)
         */
    a.task_id
  , a.task_audit_id
  , trunc(a.audit_date) activity_date
  , decode( a.task_audit_id
          , -1, 1
          , null ) first_opened
  , case
      when a.task_audit_id < 0 then
        null
      when nvl(s_new.closed_flag,'N') = 'N' and
           nvl(s_old.closed_flag,'N') = 'Y' then
        1
      else
        null
    end reopened
  , case
      when a.task_audit_id = -2 then
        null
      when a.task_audit_id = -1 and
           nvl(s_new.closed_flag,'N') = 'Y' then
        1
      when nvl(s_new.closed_flag,'N') = 'Y' and
           nvl(s_old.closed_flag,'N') = 'N' then
        1
      else
        null
    end closed
  , case
      when nvl(s_new.closed_flag,'N') = 'N' then
        case
          -- note: the sequence of the "when" is important, don't change it!
          when nvl(s_new.schedulable_flag,'N') = 'Y' or
               trunc(a.audit_date) < trunc(nvl(a.first_asgn_creation_date,g_max_date)) then
            1 --'IN PLANNING'
          when nvl(s_new.working_flag,'N') = 'Y' then
            3 --'WORKING'
          when nvl(s_new.assigned_flag,'N') = 'Y' then
            2 --'ASSIGNED'
          when nvl(s_new.completed_flag,'N') = 'Y' then
            4 -- 'COMPLETED'
          else
            5 -- 'OTHER'
        end
      else
        null
    end backlog_status_code
  , case
      when last_row_for_day_flag = 'Y' and
           nvl(s_new.closed_flag,'N') = 'N' then
        trunc(a.audit_date)
      else null
    end backlog_date_from
  , case
      when last_row_for_day_flag = 'Y' and
           nvl(s_new.closed_flag,'N') = 'N' then
        lead(trunc(a.audit_date)-1,1,g_max_date) over(partition by task_id order by a.audit_date, a.task_audit_id)
      else null
    end backlog_date_to
  -- denomalized columns
  , source_object_type_code
  , task_type_id
  , task_type_rule
  , deleted_flag
  , act_bac_assignee_id
  -- R12 resource type impact
  , act_bac_assignee_type
  , act_bac_district_id
  , inventory_item_id
  , inv_organization_id
  , customer_id
  , planned_start_date
  -- denomalized columns
  from
    ( --
      -- this selects audits (including initial creation) for all
      -- tasks of interest where the task was created on or after
      -- GSD and all audit rows since GSD for tasks of interest
      -- created before GSD
      select /*+ no_merge parallel(x)
             */
        task_id
      , task_audit_id
      , audit_date
      , case
          when task_audit_id < 0 then
            lead(old_task_status_id,1,task_status_id)
                 over(partition by task_id order by audit_date, task_audit_id)
           else
             task_status_id
         end task_status_id
      , case
          when task_audit_id = -1 then
            -1
          else
            old_task_status_id
        end old_task_status_id
      , first_asgn_creation_date
      , decode( row_number()
                over(partition by task_id, trunc(audit_date) order by audit_date desc, task_audit_id desc)
              , 1, 'Y'
              , 'N' ) last_row_for_day_flag
      -- denomalized columns
      , source_object_type_code
      , task_type_id
      , task_type_rule
      , deleted_flag
      , act_bac_assignee_id
      -- R12 resource type impact
      , act_bac_assignee_type
      , act_bac_district_id
      , inventory_item_id
      , inv_organization_id
      , customer_id
      , planned_start_date
      -- denomalized columns
      from
        ( --
          -- this query selects the current state of all tasks based on the
          -- data that was collected into isc_fs_tasks_f.
          -- the row from this query will be the marker
          -- 1. for the initial row for tasks created after GSD or
          -- 2. for the beginning row tasks created before GSD that are
          --    included in the beginning backlog
          --
          select /*+ parallel(t) no_merge
                 */
            t.task_id
          , case
              when t.task_creation_date < l_collect_from_date then
                -2
              else
                -1
            end task_audit_id
          , case
              when t.task_creation_date < l_collect_from_date then
                l_collect_from_date
              else
                t.task_creation_date
            end audit_date
          , t.task_status_id old_task_status_id
          , t.task_status_id
          , t.first_asgn_creation_date
          -- denomalized columns
          , t.source_object_type_code
          , t.task_type_id
          , t.task_type_rule
          , t.deleted_flag
          , t.act_bac_assignee_id
          -- R12 resource type impact
          , t.act_bac_assignee_type
          , t.act_bac_district_id
          , t.inventory_item_id
          , t.inv_organization_id
          , t.customer_id
          , t.planned_start_date
          -- denomalized columns
          from
            isc_fs_tasks_f t
          where
              t.source_object_type_code = 'SR'
          -- don't restrict to just rule of 'DISPATCH' as
          -- could subsequently change type and we would
          -- miss out on the initial backlog/activity
          -- and t.task_type_rule = 'DISPATCH'
          and t.task_creation_date <= l_collect_to_date
          and nvl(t.task_split_flag,'N') in ('N','M')
          --
          union all
          --
          -- this query selects all rows from the task audit table
          -- for tasks that were collected into isc_fs_tasks_f.
          --
          -- only include audits created between GSD and the end date
          -- of the load to isc_fs_tasks_f.
          --
          -- the first row for an audit may ne consumed twice, once
          -- for the initial values for the task and again for the
          -- new values (the change).
          --
          select /*+ ordered
                     parallel(t)
                     parallel(a)
                     use_hash(a)
                     pq_distribute(a,hash,hash)
                */
            a.task_id
          , a.task_audit_id
          , a.creation_date audit_date
          , a.old_task_status_id
          , a.new_task_status_id
          , t.first_asgn_creation_date
          -- denomalized columns
          , t.source_object_type_code
          , t.task_type_id
          , t.task_type_rule
          , t.deleted_flag
          , t.act_bac_assignee_id
          -- R12 resource type impact
          , t.act_bac_assignee_type
          , t.act_bac_district_id
          , t.inventory_item_id
          , t.inv_organization_id
          , t.customer_id
          , t.planned_start_date
          -- denomalized columns
          from
            isc_fs_tasks_f t
          , jtf_task_audits_b a
          where
              t.task_id = a.task_id
          and t.source_object_type_code = 'SR'
          -- don't restrict to just rule of 'DISPATCH' as
          -- could subsequently change type and we would
          -- miss out on the initial backlog/activity
          -- and t.task_type_rule = 'DISPATCH'
          and a.creation_date >= l_collect_from_date
          and a.creation_date+0 <= l_collect_to_date
          and nvl(t.task_split_flag,'N') in ('N','M')
        ) x
    ) a
  , jtf_task_statuses_b s_old
  , jtf_task_statuses_b s_new
  where
      a.task_status_id = s_new.task_status_id
  and a.old_task_status_id = s_old.task_status_id(+);

  l_rowcount := sql%rowcount;

  bis_collection_utilities_log( l_rowcount || ' rows inserted into base summaries', 1 );

  commit;

  l_stmt_id := 70;
  bis_collection_utilities.wrapup( p_status => true
                                 , p_period_from => l_collect_from_date
                                 , p_period_to => l_collect_to_date
                                 , p_count => l_rowcount
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

  type t_rowid_tbl       is table of rowid;
  type t_date_tbl        is table of date;

  l_proc_name constant varchar2(30) := 'incremental_load';
  l_stmt_id number;
  l_exception exception;
  l_error_message varchar2(4000);
  l_isc_schema varchar2(100);

  l_timer number;
  l_rowcount number;
  l_temp_rowcount number;

  l_collect_from_date date;
  l_collect_to_date date;

  l_rowid_tbl               t_rowid_tbl;
  l_backlog_date_to         t_date_tbl;

  cursor c_updated is
    select
      task_id
    , source_object_type_code
    , task_type_id
    , task_type_rule
    , deleted_flag
    , act_bac_assignee_id
    -- R12 resource type impact
    , act_bac_assignee_type
    , act_bac_district_id
    , inventory_item_id
    , inv_organization_id
    , customer_id
    , planned_start_date
    from isc_fs_tasks_f
    where last_update_date >= l_collect_from_date;

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
  if get_last_refresh_date
     ( l_collect_to_date
     , l_error_message
     ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;
  l_collect_from_date := l_collect_to_date + 1/86400;

  -- determine the date that we last collected tasks/assignments to
  l_stmt_id := 20;
  if get_last_refresh_date
     ( l_collect_to_date
     , l_error_message
     , isc_fs_task_etl_pkg.g_object_name
     ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities_log( 'From: ' || fnd_date.date_to_displaydt(l_collect_from_date), 1 );
  bis_collection_utilities_log( 'To: ' || fnd_date.date_to_displaydt(l_collect_to_date), 1 );

  if l_collect_from_date >= l_collect_to_date then

    bis_collection_utilities_log( 'Nothing to process', 2 );
    bis_collection_utilities.wrapup( p_status => true
                                   , p_period_from => l_collect_from_date
                                   , p_period_to => l_collect_to_date
                                   , p_count => 0
                                   );

    bis_collection_utilities_log('End Incremental Load');
    errbuf := null;
    retcode := g_success;
    return;
  end if;

  -- get the isc schema name
  l_stmt_id := 30;
  if get_schema_name
     ( l_isc_schema
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  -- truncate the staging table
  l_stmt_id := 40;
  if truncate_table
     ( l_isc_schema
     , 'ISC_FS_TASK_ACT_BAC_STG'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities_log( 'Staging table truncated', 1 );

  bis_collection_utilities_log( 'Inserting Task audit history into staging table', 1 );

  --
  -- insert rows based on tasks created or tasks updated
  --
  l_stmt_id := 50;
  insert into isc_fs_task_act_bac_stg
  ( task_id
  , task_audit_id
  , status_flag
  , audit_date
  , first_opened
  , reopened
  , closed
  , last_row_for_day_flag
  , backlog_status_code
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date
  , last_update_login
  , program_id
  , program_login_id
  , program_application_id
  , request_id
  -- denomalized columns
  , source_object_type_code
  , task_type_id
  , task_type_rule
  , deleted_flag
  , act_bac_assignee_id
  -- R12 resource type impact
  , act_bac_assignee_type
  , act_bac_district_id
  , inventory_item_id
  , inv_organization_id
  , customer_id
  , planned_start_date
  -- denomalized columns
  )
  /* These hints are given assuming the num of rows from ISC_FS_TASKS_F with
     the last_update_date filter would be in the range 3000 - 6000 */
  select /*+ ordered use_nl(s_new,s_old) */
    a.task_id
  , a.task_audit_id
  , decode( nvl(s_new.closed_flag,'N')
          , 'N', 'O'
          , 'C' ) status_flag
  , a.audit_date
  , decode( a.task_audit_id
          , -1, 1
          , null ) first_opened
  , case
      when a.task_audit_id < 0 then
        null
      when nvl(s_new.closed_flag,'N') = 'N' and
           nvl(s_old.closed_flag,'N') = 'Y' then
        1
      else
        null
    end reopened
  , case
      when a.task_audit_id = -2 then
        null
      when a.task_audit_id = -1 and
           nvl(s_new.closed_flag,'N') = 'Y' then
        1
      when nvl(s_new.closed_flag,'N') = 'Y' and
           nvl(s_old.closed_flag,'N') = 'N' then
        1
      else
        null
    end closed
  , last_row_for_day_flag
  , case
      when nvl(s_new.closed_flag,'N') = 'N' then
        case
          -- note: the sequence of the "when" is important, don't change it!
          when nvl(s_new.schedulable_flag,'N') = 'Y' or
               trunc(a.audit_date) < trunc(nvl(a.first_asgn_creation_date,g_max_date)) then
            1 --'IN PLANNING' -- in planning
          when nvl(s_new.working_flag,'N') = 'Y' then
            3 --'WORKING' -- working
          when nvl(s_new.assigned_flag,'N') = 'Y' then
            2 --'ASSIGNED' -- assigned
          when nvl(s_new.completed_flag,'N') = 'Y' then
            4 --'COMPLETED' -- completed
          else
            5 --'OTHER' -- others
        end
      else
        null
    end backlog_status_code
  , g_user_id
  , sysdate
  , g_user_id
  , sysdate
  , g_login_id
  , g_program_id
  , g_program_login_id
  , g_program_application_id
  , g_request_id
  -- denomalized columns
  , a.source_object_type_code
  , a.task_type_id
  , a.task_type_rule
  , a.deleted_flag
  , a.act_bac_assignee_id
  -- R12 resource type impact
  , a.act_bac_assignee_type
  , a.act_bac_district_id
  , a.inventory_item_id
  , a.inv_organization_id
  , a.customer_id
  , a.planned_start_date
  -- denomalized columns
  from
    ( --
      -- this selects audits (including initial creation) for all
      -- tasks updated since last collection based on isc_fs_tasks_f
      select
        task_id
      , task_audit_id
      , audit_date
      , case
          when task_audit_id < 0 then
            lead(old_task_status_id,1,task_status_id)
                 over(partition by task_id order by audit_date, task_audit_id)
           else
             task_status_id
         end task_status_id
      , case
          when task_audit_id = -1 then
            -1
          else
            old_task_status_id
        end old_task_status_id
      , first_asgn_creation_date
      , decode( row_number()
                over( partition by task_id, trunc(audit_date)
                      order by audit_date desc, task_audit_id desc)
              , 1, 'Y'
              , 'N' ) last_row_for_day_flag
      -- denomalized columns
      , source_object_type_code
      , task_type_id
      , task_type_rule
      , deleted_flag
      , act_bac_assignee_id
      -- R12 resource type impact
      , act_bac_assignee_type
      , act_bac_district_id
      , inventory_item_id
      , inv_organization_id
      , customer_id
      , planned_start_date
      -- denomalized columns
      from
        ( --
          -- this query selects the current state of all tasks based on the
          -- data that was collected into isc_fs_tasks_f.
          -- the row from this query will be the marker for the initial row
          -- for tasks created since last collection
          --
          select
            t.task_id
          , -1 task_audit_id
          , t.task_creation_date audit_date
          , t.task_status_id old_task_status_id
          , t.task_status_id
          , t.first_asgn_creation_date
          -- denomalized columns
          , t.source_object_type_code
          , t.task_type_id
          , t.task_type_rule
          , t.deleted_flag
          , t.act_bac_assignee_id
          -- R12 resource type impact
          , t.act_bac_assignee_type
          , t.act_bac_district_id
          , t.inventory_item_id
          , t.inv_organization_id
          , t.customer_id
          , t.planned_start_date
          -- denomalized columns
          from
            isc_fs_tasks_f t
          where
              t.last_update_date >= l_collect_from_date
          and t.task_creation_date >= l_collect_from_date
          and nvl(t.task_split_flag,'N') in ('N','M')
          --
          union all
          --
          -- this query selects rows from the task audit table created between
          -- last collection of activty/backlog and last collection of
          -- isc_fs_tasks_f for tasks that were updated in isc_fs_tasks_f
          -- since last collection of activty/backlog.
          --
          select /*+ ordered use_nl(A) */
            a.task_id
          , a.task_audit_id
          , a.creation_date audit_date
          , a.old_task_status_id
          , a.new_task_status_id
          , t.first_asgn_creation_date
          -- denomalized columns
          , t.source_object_type_code
          , t.task_type_id
          , t.task_type_rule
          , t.deleted_flag
          , t.act_bac_assignee_id
          -- R12 resource type impact
          , t.act_bac_assignee_type
          , t.act_bac_district_id
          , t.inventory_item_id
          , t.inv_organization_id
          , t.customer_id
          , t.planned_start_date
          -- denomalized columns
          from
            isc_fs_tasks_f t
          , jtf_task_audits_b a
          where
              t.task_id = a.task_id
          and t.last_update_date >= l_collect_from_date
          and nvl(t.task_split_flag,'N') in ('N','M')
          and a.creation_date >= l_collect_from_date
          and a.creation_date <= l_collect_to_date
        ) x
    ) a
  , jtf_task_statuses_b s_old
  , jtf_task_statuses_b s_new
  where
      a.task_status_id = s_new.task_status_id
  and a.old_task_status_id = s_old.task_status_id(+);

  --

  l_rowcount := sql%rowcount;

  bis_collection_utilities_log( l_rowcount || ' rows inserted', 2 );

  commit;

  bis_collection_utilities_log( 'Inserting beginning task backlog into staging table', 1 );

  -- insert a row for each task in the latest backlog
  -- this row will later be compared with the subsequent
  -- last row for day for the same task to determine if
  -- it needs to be closed off
  --
  l_stmt_id := 60;
  insert into isc_fs_task_act_bac_stg
  ( task_id
  , task_audit_id
  , backlog_status_code
  , status_flag
  , audit_date
  , backlog_rowid
  , last_row_for_day_flag
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date
  , last_update_login
  , program_id
  , program_login_id
  , program_application_id
  , request_id
  -- denomalized columns
  , source_object_type_code
  , task_type_id
  , task_type_rule
  , deleted_flag
  , act_bac_assignee_id
  -- R12 resource type impact
  , act_bac_assignee_type
  , act_bac_district_id
  , inventory_item_id
  , inv_organization_id
  , customer_id
  , planned_start_date
  -- denomalized columns
  )
  select
    b.task_id
  , b.task_audit_id
  , b.backlog_status_code
  , 'O'
  , b.backlog_date_from
  , b.rowid
  , 'Y'
  , g_user_id
  , sysdate
  , g_user_id
  , sysdate
  , g_login_id
  , g_program_id
  , g_program_login_id
  , g_program_application_id
  , g_request_id
  -- denomalized columns
  , t.source_object_type_code
  , t.task_type_id
  , t.task_type_rule
  , t.deleted_flag
  , t.act_bac_assignee_id
  -- R12 resource type impact
  , t.act_bac_assignee_type
  , t.act_bac_district_id
  , t.inventory_item_id
  , t.inv_organization_id
  , t.customer_id
  , t.planned_start_date
  -- denomalized columns
  from
    isc_fs_task_backlog_f b
  , isc_fs_tasks_f t
  where
      b.backlog_date_to = g_max_date
  and b.task_id = t.task_id;

  l_rowcount := sql%rowcount;

  bis_collection_utilities_log( l_rowcount || ' rows inserted', 2 );

  commit;

  -- gather stats on staging table
  l_stmt_id := 70;
  if gather_statistics
     ( l_isc_schema
     , 'ISC_FS_TASK_ACT_BAC_STG'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities_log( 'Gathered statistics on staging table', 1 );

  -- we need to deal with the case where the task has had a task assignement
  -- added or cancelled (even deleted) after the last audit row for that task.
  -- not sure how likely this is as testing has shown that task is updated when
  -- assignment is changed but making sure.
  --
  -- the issue is that backlog_status_code is based on both task_status_id (flags)
  -- and whether or not the task has assignments.  task_status_id is picked up
  -- by audit rows, task having/not having assignments is not.
  --
  -- for each task in the audit table we find the "last" row, if that task is open
  -- and the date of that row is not the same as the collection, we compare
  -- backlog_status_code of that row with backlog_status_code calculated based
  -- on isc_fs_tasks_f.  if they differ we insert a "dummy" audit row.
  --
  -- the most likely (but not highly likely as above) reason that they might differ
  -- is that at the time of the last audit row the backlog_status_code was IN PLANNING
  -- bacause there were no assignments, otherwise it would have been WORKING etc.
  -- by adding an assignment to the task we need to recompute backlog_status_code.
  -- the reverse hold true, if the task assignment is cancelled, we may need to
  -- move backlog_status_code from WORKING etc back to IN PLANNING.

  bis_collection_utilities_log( 'Inserting closing backlog status into staging table', 1 );

  l_stmt_id := 80;
  insert into isc_fs_task_act_bac_stg
  ( task_id
  , task_audit_id
  , backlog_status_code
  , status_flag
  , audit_date
  , last_row_for_day_flag
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date
  , last_update_login
  , program_id
  , program_login_id
  , program_application_id
  , request_id
  -- denomalized columns
  , source_object_type_code
  , task_type_id
  , task_type_rule
  , deleted_flag
  , act_bac_assignee_id
  -- R12 resource type impact
  , act_bac_assignee_type
  , act_bac_district_id
  , inventory_item_id
  , inv_organization_id
  , customer_id
  , planned_start_date
  -- denomalized columns
  )
  /* If the volume of the table ISC_FS_TASK_ACT_BAC_STG is going to be high, create
     an index on LAST_ROW_FOR_DAY_FLAG with a histogram */
  select /*+ ordered use_nl(T,S) */
    t.task_id
  , -0.1 task_audit_id
  , case
      -- note: the sequence of the "when" is important, don't change it!
      when nvl(s.schedulable_flag,'N') = 'Y' or
           trunc(l_collect_to_date) < trunc(nvl(t.first_asgn_creation_date,g_max_date)) then
        1 --'IN PLANNING'
      when nvl(s.working_flag,'N') = 'Y' then
        3 --'WORKING'
      when nvl(s.assigned_flag,'N') = 'Y' then
        2 --'ASSIGNED'
      when nvl(s.completed_flag,'N') = 'Y' then
        4 --'COMPLETED'
      else
        5 --'OTHER'
    end backlog_status_code
  , 'O' status_flag
  , l_collect_to_date audit_date
  , 'Y' last_row_for_day_flag
  , g_user_id
  , sysdate
  , g_user_id
  , sysdate
  , g_login_id
  , g_program_id
  , g_program_login_id
  , g_program_application_id
  , g_request_id
  -- denomalized columns
  , t.source_object_type_code
  , t.task_type_id
  , t.task_type_rule
  , t.deleted_flag
  , t.act_bac_assignee_id
  -- R12 resource type impact
  , t.act_bac_assignee_type
  , t.act_bac_district_id
  , t.inventory_item_id
  , t.inv_organization_id
  , t.customer_id
  , t.planned_start_date
  -- denomalized columns
  from
    ( select
        task_id
      , audit_date
      , backlog_status_code
      , status_flag
      , rank() over(partition by task_id order by audit_date desc, task_audit_id desc) rnk
      from
        isc_fs_task_act_bac_stg
      where last_row_for_day_flag = 'Y'
    ) b
  , isc_fs_tasks_f t
  , jtf_task_statuses_b s
  where
      b.rnk = 1
  and b.status_flag = 'O'
  and trunc(b.audit_date) < trunc(l_collect_to_date)
  and b.task_id = t.task_id
  and t.task_status_id = s.task_status_id
  and nvl(s.closed_flag,'N') = 'N'
  and b.backlog_status_code <> case
                                 -- note: the sequence of the "when" is important, don't change it!
                                 when nvl(s.schedulable_flag,'N') = 'Y' or
                                      trunc(l_collect_to_date) < trunc(nvl(t.first_asgn_creation_date,g_max_date)) then
                                   1 --'IN PLANNING'
                                 when nvl(s.working_flag,'N') = 'Y' then
                                   3 --'WORKING'
                                 when nvl(s.assigned_flag,'N') = 'Y' then
                                   2 --'ASSIGNED'
                                 when nvl(s.completed_flag,'N') = 'Y' then
                                   4 --'COMPLETED'
                                 else
                                   5 --'OTHER'
                             end;

  l_rowcount := sql%rowcount;

  bis_collection_utilities_log( l_rowcount || ' rows inserted', 2 );

  commit;

  bis_collection_utilities_log( 'Hiding ''duplicate'' rows from backlog query', 1 );

  -- hide 'duplicate' rows from backlog query
  l_stmt_id := 90;
  update isc_fs_task_act_bac_stg
  set status_flag = lower(status_flag)
    , last_updated_by = g_user_id
    , last_update_date = sysdate
    , last_update_login = g_login_id
    , program_id = g_program_id
    , program_login_id = g_program_login_id
    , program_application_id = g_program_application_id
    , request_id = g_request_id
  where rowid in ( select rowid
                   from
                     ( select
                         task_id || '^' ||
                         backlog_status_code conc_key
                       , lag(task_id || '^' ||
                             backlog_status_code
                            ,1,'^')
                             over (order by
                                     task_id
                                   , audit_date
                                   , task_audit_id) prev_conc_key
                       from
                         isc_fs_task_act_bac_stg
                       where
                           last_row_for_day_flag = 'Y'
                      )
                   where conc_key = prev_conc_key
                 );

  l_temp_rowcount := sql%rowcount;

  bis_collection_utilities_log(l_temp_rowcount || ' rows updated',2);

  commit;

  bis_collection_utilities_log('Staging table complete');

  -- ---------------------------------------------- --
  -- do not issue another commit until we are done!
  -- ---------------------------------------------- --

  bis_collection_utilities_log( 'Updating changes to denormalized data for existing rows', 1 );

  -- pick up changes in denormalized columns from isc_fs_tasks_f
  -- for existing activity and end dated backlog
  l_stmt_id := 92;
  l_rowcount := 0;
  l_temp_rowcount := 0;

  for i in c_updated loop

    l_stmt_id := 94;
    update isc_fs_task_activity_f
    set
      source_object_type_code = i.source_object_type_code
    , task_type_id = i.task_type_id
    , task_type_rule = i.task_type_rule
    , deleted_flag = i.deleted_flag
    , act_bac_assignee_id = i.act_bac_assignee_id
    -- R12 resource type impact
    , act_bac_assignee_type = i.act_bac_assignee_type
    , act_bac_district_id = i.act_bac_district_id
    , inventory_item_id = i.inventory_item_id
    , inv_organization_id = i.inv_organization_id
    , customer_id = i.customer_id
    , last_updated_by = g_user_id
    , last_update_date = sysdate
    , last_update_login = g_login_id
    , program_id = g_program_id
    , program_login_id = g_program_login_id
    , program_application_id = g_program_application_id
    , request_id = g_request_id
    where
        task_id = i.task_id
    and ( nvl(source_object_type_code,'X') <> nvl(i.source_object_type_code,'X') or -- should not be null
          nvl(task_type_id,-5) <> nvl(i.task_type_id,-5) or -- should not be null
          nvl(task_type_rule,'X') <> nvl(i.task_type_rule,'X') or -- may be null
          nvl(deleted_flag,'X') <> nvl(i.deleted_flag,'X') or -- should not be null
          nvl(act_bac_assignee_id,-5) <> nvl(i.act_bac_assignee_id,-5) or -- should not be null
          -- R12 resource type impact
          nvl(act_bac_assignee_type,'X') <> nvl(i.act_bac_assignee_type,'X') or -- should not be null
          nvl(act_bac_district_id,-5) <> nvl(i.act_bac_district_id,-5) or -- should not be null
          nvl(inventory_item_id,-5) <> nvl(i.inventory_item_id,-5) or -- should not be null
          nvl(inv_organization_id,-5) <> nvl(i.inv_organization_id,-5) or -- should not be null
          nvl(customer_id,-5) <> nvl(i.customer_id,-5) -- should not be null
        );
    l_rowcount := l_rowcount + sql%rowcount;

    l_stmt_id := 96;
    update isc_fs_task_backlog_f
    set
      source_object_type_code = i.source_object_type_code
    , task_type_id = i.task_type_id
    , task_type_rule = i.task_type_rule
    , deleted_flag = i.deleted_flag
    , act_bac_assignee_id = i.act_bac_assignee_id
    -- R12 resource type impact
    , act_bac_assignee_type = i.act_bac_assignee_type
    , act_bac_district_id = i.act_bac_district_id
    , inventory_item_id = i.inventory_item_id
    , inv_organization_id = i.inv_organization_id
    , customer_id = i.customer_id
    , planned_start_date = i.planned_start_date
    , last_updated_by = g_user_id
    , last_update_date = sysdate
    , last_update_login = g_login_id
    , program_id = g_program_id
    , program_login_id = g_program_login_id
    , program_application_id = g_program_application_id
    , request_id = g_request_id
    where
        task_id = i.task_id
    and ( nvl(source_object_type_code,'X') <> nvl(i.source_object_type_code,'X') or -- should not be null
          nvl(task_type_id,-5) <> nvl(i.task_type_id,-5) or -- should not be null
          nvl(task_type_rule,'X') <> nvl(i.task_type_rule,'X') or -- may be null
          nvl(deleted_flag,'X') <> nvl(i.deleted_flag,'X') or -- should not be null
          nvl(act_bac_assignee_id,-5) <> nvl(i.act_bac_assignee_id,-5) or -- should not be null
          -- R12 resource type impact
          nvl(act_bac_assignee_type,'X') <> nvl(i.act_bac_assignee_type,'X') or -- should not be null
          nvl(act_bac_district_id,-5) <> nvl(i.act_bac_district_id,-5) or -- should not be null
          nvl(inventory_item_id,-5) <> nvl(i.inventory_item_id,-5) or -- should not be null
          nvl(inv_organization_id,-5) <> nvl(i.inv_organization_id,-5) or -- should not be null
          nvl(customer_id,-5) <> nvl(i.customer_id,-5) or -- should not be null
          nvl(planned_start_date,g_max_date) <> nvl(i.planned_start_date,g_max_date) -- may be null
        );
    l_temp_rowcount := l_temp_rowcount + sql%rowcount;

  end loop;

  bis_collection_utilities_log(l_rowcount || ' rows updated in activity base summary',2);
  bis_collection_utilities_log(l_temp_rowcount || ' rows updated in backlog base summary',2);

  bis_collection_utilities_log( 'Calculating changes to previous current task backlog rows', 1 );

  --
  -- determine if the previous backlog row needs to be closed off
  -- as there is a subsequent row for the same task, either closed or
  -- open but with different properties
  --
  l_stmt_id := 100;
  select
    backlog_rowid
  , lead_audit_date -1
  bulk collect into
    l_rowid_tbl
  , l_backlog_date_to
  from
    ( select
        backlog_rowid
      , lead( backlog_status_code, 1, backlog_status_code )
              over( partition by task_id order by audit_date, task_audit_id ) lead_backlog_status_code
      , lead( status_flag, 1, status_flag )
              over( partition by task_id order by audit_date, task_audit_id ) lead_status_flag
      , lead( trunc(audit_date), 1, null )
              over( partition by task_id order by audit_date, task_audit_id ) lead_audit_date
      , backlog_status_code
      , status_flag
      from
        isc_fs_task_act_bac_stg
      where
        last_row_for_day_flag = 'Y'
      and status_flag in ('O','C')
    )
  where backlog_rowid is not null
  and lead_audit_date is not null
  and ( lead_backlog_status_code <> backlog_status_code or
        lead_status_flag <> status_flag );

  bis_collection_utilities_log( 'Updating changed previous current task backlog rows', 2 );
  --
  -- updated the previous backlog row that need to be closed off
  -- as there is a subsequent row for the same task, either closed or
  -- open with different properties
  --
  l_stmt_id := 110;
  forall i in 1..l_rowid_tbl.count
    update isc_fs_task_backlog_f
    set
      backlog_date_to = l_backlog_date_to(i)
    , last_updated_by = g_user_id
    , last_update_date = sysdate
    , last_update_login = g_login_id
    , program_id = g_program_id
    , program_login_id = g_program_login_id
    , program_application_id = g_program_application_id
    , request_id = g_request_id
    where rowid = l_rowid_tbl(i);

  l_rowcount := sql%rowcount;

  bis_collection_utilities_log( l_rowid_tbl.count || ' rows updated', 3 );

  bis_collection_utilities_log( 'Inserting activity', 1 );

  --
  -- insert the activity rows into isc_fs_task_activity_f
  --
  l_stmt_id := 120;
  insert into isc_fs_task_activity_f
  ( task_id
  , task_audit_id
  , activity_date
  , first_opened
  , reopened
  , closed
  , created_by
  , creation_date
  , last_updated_by
  , last_update_date
  , last_update_login
  , program_id
  , program_login_id
  , program_application_id
  , request_id
  -- denomalized columns
  , source_object_type_code
  , task_type_id
  , task_type_rule
  , deleted_flag
  , act_bac_assignee_id
  -- R12 resource type impact
  , act_bac_assignee_type
  , act_bac_district_id
  , inventory_item_id
  , inv_organization_id
  , customer_id
  -- denomalized columns
  )
  select
    task_id
  , task_audit_id
  , trunc(audit_date)
  , first_opened
  , reopened
  , closed
  , g_user_id
  , sysdate
  , g_user_id
  , sysdate
  , g_login_id
  , g_program_id
  , g_program_login_id
  , g_program_application_id
  , g_request_id
  -- denomalized columns
  , source_object_type_code
  , task_type_id
  , task_type_rule
  , deleted_flag
  , act_bac_assignee_id
  -- R12 resource type impact
  , act_bac_assignee_type
  , act_bac_district_id
  , inventory_item_id
  , inv_organization_id
  , customer_id
  -- denomalized columns
  from
    isc_fs_task_act_bac_stg
  where
      trunc(audit_date) >= g_global_start_date
  and 1 in ( first_opened
           , reopened
           , closed
           );

  l_rowcount := sql%rowcount;

  bis_collection_utilities_log( l_rowcount || ' rows inserted', 2 );

  bis_collection_utilities_log( 'Inserting backlog history', 1 );

  --
  -- insert the new backlog rows into isc_fs_task_backlog_f
  --
  l_stmt_id := 130;
  insert
  first
  when status_flag = 'O' and
       backlog_rowid is null then
    into isc_fs_task_backlog_f
    ( task_id
    , task_audit_id
    , backlog_date_from
    , backlog_date_to
    , backlog_status_code
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    , program_id
    , program_login_id
    , program_application_id
    , request_id
    -- denomalized columns
    , source_object_type_code
    , task_type_id
    , task_type_rule
    , deleted_flag
    , act_bac_assignee_id
    -- R12 resource type impact
    , act_bac_assignee_type
    , act_bac_district_id
    , inventory_item_id
    , inv_organization_id
    , customer_id
    , planned_start_date
    -- denomalized columns
    )
    values
    ( task_id
    , task_audit_id
    , greatest(backlog_date_from, g_global_start_date)
    , greatest(backlog_date_to, g_global_start_date)
    , backlog_status_code
    , g_user_id
    , sysdate
    , g_user_id
    , sysdate
    , g_login_id
    , g_program_id
    , g_program_login_id
    , g_program_application_id
    , g_request_id
    -- denomalized columns
    , source_object_type_code
    , task_type_id
    , task_type_rule
    , deleted_flag
    , act_bac_assignee_id
    -- R12 resource type impact
    , act_bac_assignee_type
    , act_bac_district_id
    , inventory_item_id
    , inv_organization_id
    , customer_id
    , planned_start_date
    -- denomalized columns
    )
  select
    task_id
  , task_audit_id
  , trunc(audit_date) backlog_date_from
  , lead(trunc(audit_date)-1,1,g_max_date)
         over(partition by task_id order by audit_date, task_audit_id) backlog_date_to
  , backlog_status_code
  , backlog_rowid
  , status_flag
  -- denomalized columns
  , source_object_type_code
  , task_type_id
  , task_type_rule
  , deleted_flag
  , act_bac_assignee_id
  -- R12 resource type impact
  , act_bac_assignee_type
  , act_bac_district_id
  , inventory_item_id
  , inv_organization_id
  , customer_id
  , planned_start_date
  -- denomalized columns
  from
    isc_fs_task_act_bac_stg
  where
      status_flag in ('O','C')
  and last_row_for_day_flag = 'Y';

  l_temp_rowcount := sql%rowcount;

  bis_collection_utilities_log( l_temp_rowcount || ' rows inserted', 2 );

  l_rowcount := l_rowcount + l_temp_rowcount;

  commit;

  -- house keeping -- cleanup staging table
  l_stmt_id := 140;
  if truncate_table
     ( l_isc_schema
     , 'ISC_FS_TASK_ACT_BAC_STG'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities_log( 'Staging table truncated', 1 );

  l_stmt_id := 150;
  bis_collection_utilities.wrapup( p_status => true
                                 , p_period_from => l_collect_from_date
                                 , p_period_to => l_collect_to_date
                                 , p_count => l_rowcount
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

end isc_fs_task_act_bac_etl_pkg;

/
