--------------------------------------------------------
--  DDL for Package Body ISC_MAINT_REQ_WO_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_MAINT_REQ_WO_ETL_PKG" 
/* $Header: iscmaintreqwoetb.pls 120.1 2005/09/13 21:23:11 nbhamidi noship $ */
as

  g_pkg_name constant varchar2(30) := 'isc_maint_req_wo_etl_pkg';
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
  g_object_name constant varchar2(30) := 'ISC_MAINT_REQ_WO_FACT';

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
  bis_collection_utilities.log( g_pkg_name || '.' || p_proc_name ||
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
  l_missing_completion_date constant date := to_date('31/12/4712','dd/mm/yyyy');

begin

  local_init;

  bis_collection_utilities.log( 'Begin Initial Load' );

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

  bis_collection_utilities.log( 'From ' || fnd_date.date_to_displaydt(l_collect_from_date), 1 );
  bis_collection_utilities.log( 'To ' || fnd_date.date_to_displaydt(l_collect_to_date), 1 );

  -- get the isc schema name
  l_stmt_id := 20;
  if get_schema_name
     ( l_isc_schema
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  -- truncate the fact table
  l_stmt_id := 30;
  if truncate_table
     ( l_isc_schema
     , 'ISC_MAINT_REQ_WO_F'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Base summary table truncated', 1 );

  -- insert into base fact from staging table
  l_stmt_id := 40;
  insert /*+ append parallel(f) */
  into isc_maint_req_wo_f f
  ( request_type
  , maint_request_id
  , association_id
  , request_number
  , organization_id
  , department_id
  , asset_group_id
  , instance_id		/* replaced asset_number with instance_id */
  , request_start_date
  , request_severity_id
  , work_order_id
  , completion_date
  , response_days
  , completion_days
  , work_order_count
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_id
  , program_login_id
  , program_application_id
  , request_id
  )
  --
  -- select SR/WO associations
  --
  select /*+ parallel(x) */
    '2' request_type
  , maint_request_id
  , association_id
  , request_number
  , nvl(organization_id,-1)
  , nvl(department_id,-1)
  , nvl(asset_group_id,-1)
  , nvl(instance_id,-1)
  , request_start_date
  , request_severity_id
  , work_order_id
  , completion_date
  , response_days
  , completion_days
  , work_order_count
  , sysdate
  , g_user_id
  , sysdate
  , g_user_id
  , g_login_id
  , g_program_id
  , g_program_login_id
  , g_program_application_id
  , g_request_id
  from
    ( select /*+ parallel(x) */
        maint_request_id
      , association_id
      , request_number
      , organization_id
      , department_id
      , asset_group_id
      , instance_id
      , request_start_date
      , request_severity_id
      , work_order_id
      -- if this is the last completion date for all WOs for the SR and
      -- the completion date is not null we attribute the completion date
      -- to this SR/WO association
      , case
          when completion_rank = 1 and
               completion_datetime <> l_missing_completion_date then
            trunc(completion_datetime)
          else
            null
        end completion_date
      -- if this is the last completion date for all WOs for the SR and
      -- the completion date is not null we attribute the min response days
      -- to this SR/WO association
      , case
          when completion_rank = 1 and
               completion_datetime <> l_missing_completion_date then
            min_response_days
          else
            null
        end response_days
      -- if this is the last completion date for all WOs for the SR and
      -- the completion date is not null we attribute the completion days
      -- to this SR/WO association
      , case
          when completion_rank = 1 and
               completion_datetime <> l_missing_completion_date then
            completion_days
          else
            null
        end completion_days
      -- if this is the last completion date for all WOs for the SR and
      -- the completion date is not null we attribute the number of work orders
      -- to this SR/WO association
      , case
          when completion_rank = 1 and
               completion_datetime <> l_missing_completion_date then
            work_order_count
          else
            null
        end work_order_count
      from
        ( select /*+ parallel(i) parallel(a) parallel(w) */
            i.incident_id maint_request_id
          , a.wo_service_entity_assoc_id association_id
          , i.incident_number request_number
          , a.maintenance_organization_id organization_id
          , i.owning_department_id department_id
          , i.inventory_item_id asset_group_id
          , i.customer_product_id instance_id
          , i.incident_date request_start_date
          , i.incident_severity_id request_severity_id
          , w.work_order_id
          , w.completion_datetime
          -- calculate the response days for each SR/WO association
          -- this should never be less than 0 days
          , greatest(w.wo_creation_datetime - i.incident_date, 0) response_days
          -- calculate the completion days for each SR/WO association
          -- this should never be less than 0 days
          , greatest(w.completion_datetime - i.incident_date, 0) completion_days
          -- rank the SR/WO associations for the same SR based on WO completion date,
          -- the WO with the latest completion date is ranked first.  A null
          -- completion date will always outrank a not null completion date
          , row_number()
              over(partition by i.incident_id
                   order by nvl(w.completion_datetime,l_missing_completion_date) desc
                          , a.wo_service_entity_assoc_id) completion_rank
          -- determine the min response days for all SR/WO associations for
          -- the same SR
          , min(greatest(w.wo_creation_datetime - i.incident_date, 0))
              over(partition by i.incident_id) min_response_days
          , count(*) over(partition by i.incident_id) work_order_count
          from
            cs_incidents_all_b i
          , eam_wo_service_association a
          , isc_maint_work_orders_f w
          where
              i.incident_id = a.service_request_id
          and a.wip_entity_id = w.work_order_id
          and a.maintenance_organization_id = w.organization_id
          and nvl(a.enable_flag,'Y') = 'Y'
          -- exclude all cancelled work orders
          and w.status_type <> 7
        ) x
    ) x
  where nvl(completion_date,g_global_start_date) >= g_global_start_date
  union all
  --
  -- select WR/WO associations
  --
  select /*+ parallel(r) parallel(w) */
    '1' request_type
  , r.work_request_id maint_request_id
  , r.work_request_id association_id
  , r.work_request_number request_number
  , nvl(r.organization_id,-1) organization_id
  , nvl(r.work_request_owning_dept,-1) department_id
  , nvl(r.asset_group,-1) asset_group_id
  , nvl(r.maintenance_object_id,-1) instance_id
  , r.creation_date request_start_date
  , nvl(r.work_request_priority_id,-1) request_severity_id
  , w.work_order_id
  , trunc(w.completion_datetime) completion_date
  , case
      when w.completion_datetime is not null then
        greatest(w.wo_creation_datetime - r.creation_date, 0)
      else
        null
    end response_days
  , case
      when w.completion_datetime is not null then
        greatest(w.completion_datetime - r.creation_date, 0)
      else
        null
    end completion_days
  , case
      when w.completion_datetime is not null then
        1
      else
        null
    end work_order_count
  , sysdate
  , g_user_id
  , sysdate
  , g_user_id
  , g_login_id
  , g_program_id
  , g_program_login_id
  , g_program_application_id
  , g_request_id
  from
    wip_eam_work_requests r
  , isc_maint_work_orders_f w
  where
      r.wip_entity_id = w.work_order_id
  and r.organization_id = w.organization_id
  -- only include WR with WO completion_date >= global start date
  and nvl(w.completion_date,g_global_start_date) >= g_global_start_date
  -- exclude all cancelled work orders
  and w.status_type <> 7;

  l_rowcount := sql%rowcount;

  commit;

  bis_collection_utilities.log( l_rowcount || ' rows inserted into base summary', 1 );

  l_stmt_id := 50;
  bis_collection_utilities.wrapup( p_status => true
                                 , p_period_from => l_collect_from_date
                                 , p_period_to => l_collect_to_date
                                 , p_count => l_rowcount
                                 );

  bis_collection_utilities.log('End Initial Load');

  errbuf := null;
  retcode := g_success;

exception
  when g_bis_setup_exception then
    rollback;
    errbuf := l_error_message;
    retcode := g_error;

  when others then
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

  l_timer number;
  l_rowcount number;
  l_temp_rowcount number;

  l_collect_from_date date;
  l_collect_to_date date;

  l_missing_completion_date constant date := to_date('31/12/4712','dd/mm/yyyy');
  l_disabled_completion_date constant date := to_date('01/01/1111','dd/mm/yyyy');

begin

  local_init;

  bis_collection_utilities.log( 'Begin Incremental Load' );

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

  bis_collection_utilities.log( 'From: ' || fnd_date.date_to_displaydt(l_collect_from_date), 1 );
  bis_collection_utilities.log( 'To: ' || fnd_date.date_to_displaydt(l_collect_to_date), 1 );

  -- get the isc schema name
  l_stmt_id := 20;
  if get_schema_name
     ( l_isc_schema
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  -- truncate the staging table
  l_stmt_id := 30;
  if truncate_table
     ( l_isc_schema
     , 'ISC_MAINT_REQ_WO_STG'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Staging table truncated', 1 );

  -- this detects all SR with changed associations
  l_stmt_id := 40;
  insert into
  isc_maint_req_wo_stg
  ( maint_request_id
  , phase_id
  , creation_date
  , created_by
  , last_update_date
  , last_updated_by
  , last_update_login
  , program_id
  , program_login_id
  , program_application_id
  , request_id
  )
  select distinct
    service_request_id
  , 1
  , sysdate
  , g_user_id
  , sysdate
  , g_user_id
  , g_login_id
  , g_program_id
  , g_program_login_id
  , g_program_application_id
  , g_request_id
  from eam_wo_service_association a
  where a.last_update_date >= l_collect_from_date;

  l_rowcount := sql%rowcount;

  bis_collection_utilities.log( l_rowcount || ' rows inserted staging table from association', 1 );

  -- this detects all SR where associated WO is updated
  l_stmt_id := 50;
  merge into
  isc_maint_req_wo_stg s
  using
    ( select distinct
        service_request_id maint_request_id
      , 2 phase_id
      from eam_wo_service_association a
      , isc_maint_work_orders_f w
      where
          a.wip_entity_id = w.work_order_id
      and a.maintenance_organization_id = w.organization_id
      and w.last_update_date >= l_collect_from_date
    ) n
  on ( s.maint_request_id = n.maint_request_id )
  when matched then
    update
    set phase_id = s.phase_id + n.phase_id
      , last_update_date = sysdate
      , last_updated_by = g_user_id
      , last_update_login = g_login_id
      , program_id = g_program_id
      , program_login_id = g_program_login_id
      , program_application_id = g_program_application_id
      , request_id = g_request_id
  when not matched then
    insert
    ( maint_request_id
    , phase_id
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login
    , program_id
    , program_login_id
    , program_application_id
    , request_id
    )
    values
    ( n.maint_request_id
    , n.phase_id
    , sysdate
    , g_user_id
    , sysdate
    , g_user_id
    , g_login_id
    , g_program_id
    , g_program_login_id
    , g_program_application_id
    , g_request_id
    );

  l_rowcount := sql%rowcount;

  bis_collection_utilities.log( l_rowcount || ' rows merged into staging table from work orders', 1 );

  -- this detects new or updated SR of type maintenance
/*
  -- this is no longer performed, we will only track changes to dimension values
  -- in the service request at completion of the work order or if there has been
  -- a change at the association level.

  l_stmt_id := 60;
  merge into
  isc_maint_req_wo_stg s
  using
    ( select distinct
        incident_id maint_request_id
      , 3 phase_id
      from cs_incidents_audit_b a
      , cs_incident_types_b t
      where
          a.creation_date >= l_collect_from_date
      and a.incident_type_id = t.incident_type_id
      and t.maintenance_flag = 'Y'
      and ( ( a.change_incident_type_flag = 'Y' and a.old_incident_type_id is null ) or
            a.change_inventory_item_flag = 'Y' or
            a.change_inv_organization_flag = 'Y' or
            ( ( a.item_serial_number is null and a.old_item_serial_number is not null) or
              ( a.old_item_serial_number is null and a.item_serial_number is not null ) or
              ( a.old_item_serial_number <> a.item_serial_number ) ) or
            ( ( a.owning_department_id is null and a.old_owning_department_id is not null) or
              ( a.old_owning_department_id is null and a.owning_department_id is not null ) or
              ( a.old_owning_department_id <> a.owning_department_id ) )
          )
    ) n
  on ( s.maint_request_id = n.maint_request_id )
  when matched then
    update
    set phase_id = s.phase_id + n.phase_id
      , last_update_date = sysdate
      , last_updated_by = g_user_id
      , last_update_login = g_login_id
      , program_id = g_program_id
      , program_login_id = g_program_login_id
      , program_application_id = g_program_application_id
      , request_id = g_request_id
  when not matched then
    insert
    ( maint_request_id
    , phase_id
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login
    , program_id
    , program_login_id
    , program_application_id
    , request_id
    )
    values
    ( n.maint_request_id
    , n.phase_id
    , sysdate
    , g_user_id
    , sysdate
    , g_user_id
    , g_login_id
    , g_program_id
    , g_program_login_id
    , g_program_application_id
    , g_request_id
    );

  l_rowcount := sql%rowcount;

  bis_collection_utilities.log( l_rowcount || ' rows merged into staging table from incident audits', 1 );
*/

  -- gather statistics on staging table
  l_stmt_id := 70;
  if gather_statistics
     ( l_isc_schema
     , 'ISC_MAINT_REQ_WO_STG'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Staging table analyzed', 1 );

  -- merge staging table into base fact
  l_stmt_id := 80;
  merge
  into isc_maint_req_wo_f f
  using
    (
      --
      -- select SR/WO associations
      --
      select
        '2' request_type
      , maint_request_id
      , association_id
      , request_number
      , nvl(organization_id,-1) organization_id
      , nvl(department_id,-1) department_id
      , nvl(asset_group_id,-1) asset_group_id
      , nvl(instance_id,-1) instance_id		/* replaced asset_number with instance_id */
      , request_start_date
      , request_severity_id
      , work_order_id
      -- if this is the last completion date for all WOs for the SR and
      -- the completion date is not null we attribute the completion date
      -- to this SR/WO association
     , case
          when completion_rank = 1 and
               completion_datetime <> l_missing_completion_date and
               completion_datetime <> l_disabled_completion_date then
            trunc(completion_datetime)
          else
            null
        end completion_date
      -- if this is the last completion date for all WOs for the SR and
      -- the completion date is not null we attribute the min response days
      -- to this SR/WO association
      , case
          when completion_rank = 1 and
               completion_datetime <> l_missing_completion_date and
               completion_datetime <> l_disabled_completion_date then
            min_response_days
          else
            null
        end response_days
      -- if this is the last completion date for all WOs for the SR and
      -- the completion date is not null we attribute the completion days
      -- to this SR/WO association
      , case
          when completion_rank = 1 and
               completion_datetime <> l_missing_completion_date and
               completion_datetime <> l_disabled_completion_date then
            completion_days
          else
            null
        end completion_days
      -- if this is the last completion date for all WOs for the SR and
      -- the completion date is not null we attribute the number of work orders
      -- to this SR/WO association
      , case
          when completion_rank = 1 and
               completion_datetime <> l_missing_completion_date and
               completion_datetime <> l_disabled_completion_date then
            work_order_count
          else
            null
        end work_order_count
      from
        ( select
            i.incident_id maint_request_id
          , a.wo_service_entity_assoc_id association_id
          , i.incident_number request_number
          , a.maintenance_organization_id organization_id
          , i.owning_department_id department_id
          , i.inventory_item_id asset_group_id
          , i.customer_product_id instance_id
          , i.incident_date request_start_date
          , i.incident_severity_id request_severity_id
          , case
              when nvl(a.enable_flag,'Y') = 'Y' then
                w.work_order_id
              else
                null
            end work_order_id
          , case
              when nvl(a.enable_flag,'Y') = 'Y' and
                   w.status_type <> 7 then
                w.completion_datetime
              else
                null
            end completion_datetime
          -- calculate the response days for each SR/WO association
     -- this should never be less than 0 days
          , case
              when nvl(a.enable_flag,'Y') = 'Y' and
                   w.status_type <> 7 then
                greatest(w.wo_creation_datetime - i.incident_date, 0)
              else
                null
            end response_days
          -- calculate the completion days for each SR/WO association
          -- this should never be less than 0 days
          , case
              when nvl(a.enable_flag,'Y') = 'Y' and
                   w.status_type <> 7 then
                greatest(w.completion_datetime - i.incident_date, 0)
              else
                null
              end completion_days
          -- rank the SR/WO associations for the same SR based on WO completion date,
     -- the WO with the latest completion date is ranked first.  A null
          -- completion date will always outrank a not null completion date
          , row_number()
              over(partition by i.incident_id
                   order by case
                              when nvl(a.enable_flag,'Y') = 'Y' and
                                   w.status_type <> 7 then
                                nvl(w.completion_datetime,l_missing_completion_date)
                              else
                                l_disabled_completion_date
                            end desc
                          , a.wo_service_entity_assoc_id) completion_rank

          , min(greatest(case
                           when nvl(a.enable_flag,'Y') = 'Y' and
                                w.status_type <> 7 then
                             w.wo_creation_datetime - i.incident_date
                           else
                             999999999999999
                         end, 0))
              over(partition by i.incident_id) min_response_days
          , sum( case
                   when nvl(a.enable_flag,'Y') = 'Y' and
                        w.status_type <> 7 then
                     1
                   else
                     0
                 end ) over(partition by i.incident_id) work_order_count
          from
            cs_incidents_all_b i
          , eam_wo_service_association a
          , isc_maint_work_orders_f w
          , isc_maint_req_wo_stg c
          where
              i.incident_id = a.service_request_id
          and a.wip_entity_id = w.work_order_id
          and a.maintenance_organization_id = w.organization_id
          and a.service_request_id = c.maint_request_id
        )
      union all
      --
      -- select WR/WO associations
      --
      select
        '1' request_type
      , r.work_request_id maint_request_id
      , r.work_request_id association_id
      , r.work_request_number request_number
      , nvl(r.organization_id,-1) organization_id
      , nvl(r.work_request_owning_dept,-1) department_id
      , nvl(r.asset_group,-1) asset_group_id
      , nvl(r.maintenance_object_id,-1) instance_id
      , r.creation_date request_start_date
      , nvl(r.work_request_priority_id,-1) request_severity_id
      , w.work_order_id
      , case
          when w.completion_datetime is not null and
               w.status_type <> 7 then
            trunc(w.completion_datetime)
          else
            null
        end completion_date
      , case
          when w.completion_datetime is not null and
               w.status_type <> 7 then
            greatest(w.wo_creation_datetime - r.creation_date, 0)
          else
            null
        end response_days
      , case
          when w.completion_datetime is not null and
               w.status_type <> 7 then
            greatest(w.completion_datetime - r.creation_date, 0)
          else
            null
        end completion_days
      , case
          when w.completion_datetime is not null and
               w.status_type <> 7 then
            1
          else
            null
        end work_order_count
      from
        wip_eam_work_requests r
      , isc_maint_work_orders_f w
      where
          r.wip_entity_id = w.work_order_id(+)
      and r.organization_id = w.organization_id(+)
      and ( r.last_update_date >= l_collect_from_date or
            w.last_update_date >= l_collect_from_date )
    ) s
  on
    ( f.request_type = s.request_type and
      f.maint_request_id = s.maint_request_id and
      f.association_id = s.association_id )
  when matched then
    update
    set f.organization_id = s.organization_id
      , f.department_id = s.department_id
      , f.asset_group_id = s.asset_group_id
      , f.instance_id = s.instance_id
      , f.request_severity_id = s.request_severity_id
      , f.work_order_id = s.work_order_id
      , f.completion_date = s.completion_date
      , f.response_days = s.response_days
      , f.completion_days = s.completion_days
      , f.work_order_count = s.work_order_count
      , f.last_update_date = sysdate
      , f.last_updated_by = g_user_id
      , f.last_update_login = g_login_id
      , f.program_id = g_program_id
      , f.program_login_id = g_program_login_id
      , f.program_application_id = g_program_application_id
      , f.request_id = g_request_id
  when not matched then
    insert
    ( request_type
    , maint_request_id
    , association_id
    , request_number
    , organization_id
    , department_id
    , asset_group_id
    , instance_id
    , request_start_date
    , request_severity_id
    , work_order_id
    , completion_date
    , response_days
    , completion_days
    , work_order_count
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login
    , program_id
    , program_login_id
    , program_application_id
    , request_id
    )
    values
    ( s.request_type
    , s.maint_request_id
    , s.association_id
    , s.request_number
    , s.organization_id
    , s.department_id
    , s.asset_group_id
    , s.instance_id
    , s.request_start_date
    , s.request_severity_id
    , s.work_order_id
    , s.completion_date
    , s.response_days
    , s.completion_days
    , s.work_order_count
    , sysdate
    , g_user_id
    , sysdate
    , g_user_id
    , g_login_id
    , g_program_id
    , g_program_login_id
    , g_program_application_id
    , g_request_id
    );

  l_rowcount := sql%rowcount;

  commit;

  bis_collection_utilities.log( l_rowcount || ' rows merged into base summary', 1 );

  -- housekeeping/cleanup truncate the staging table
  l_stmt_id := 90;
  if truncate_table
     ( l_isc_schema
     , 'ISC_MAINT_REQ_WO_STG'
     , l_error_message ) <> 0 then
    logger( l_proc_name, l_stmt_id, l_error_message );
    raise l_exception;
  end if;

  bis_collection_utilities.log( 'Staging table truncated', 1 );
  l_stmt_id := 100;
  bis_collection_utilities.wrapup( p_status => true
                                 , p_period_from => l_collect_from_date
                                 , p_period_to => l_collect_to_date
                                 , p_count => l_rowcount
                                 );

  bis_collection_utilities.log('End Incremental Load');

  errbuf := null;
  retcode := g_success;

exception
  when g_bis_setup_exception then
    rollback;
    errbuf := l_error_message;
    retcode := g_error;

  when others then
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

end incremental_load;

end isc_maint_req_wo_etl_pkg;

/
