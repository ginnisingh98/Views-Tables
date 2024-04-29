--------------------------------------------------------
--  DDL for Package Body BIV_DBI_COLLECTION_INIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIV_DBI_COLLECTION_INIT" as
/* $Header: bivsrvcintb.pls 120.6 2005/11/10 06:25:04 kamsharm noship $ */

  g_bis_setup_exception exception;
  g_user_id number := fnd_global.user_id;
  g_login_id number := fnd_global.login_id;
  g_process_type varchar2(30) := 'INITIAL_LOAD';

function internal_wrapup
( p_rowid             in rowid
, x_error_message out nocopy varchar2 )
return number as

  cursor c_wrapup is
    select
      success_flag
    , activity_flag
    , closed_flag
    , backlog_flag
    , resolution_flag
    from
      biv_dbi_collection_log
    where
        rowid = p_rowid
    for update of success_flag;

  l_success_flag varchar2(1);
  l_activity_flag varchar2(1);
  l_closed_flag varchar2(1);
  l_backlog_flag varchar2(1);
  l_resolution_flag varchar2(1);

begin

  open c_wrapup;
  fetch c_wrapup into l_success_flag
                    , l_activity_flag
                    , l_closed_flag
                    , l_backlog_flag
                    , l_resolution_flag;

  if l_success_flag = 'Y' then
    x_error_message := 'Internal wrapup called for completed initial load';
    return -1;
  end if;

  if l_activity_flag = 'Y' and
     l_closed_flag = 'Y' and
     l_backlog_flag = 'Y' and
     l_resolution_flag = 'Y' then

    update biv_dbi_collection_log
    set success_flag = 'Y'
      , last_update_date = sysdate
      , last_updated_by = g_user_id
      , last_update_login = g_login_id
    where current of c_wrapup;

    bis_collection_utilities.put_line('Initial Load complete');

  end if;

  close c_wrapup;

  return 0;

exception
  when others then
    x_error_message  := sqlerrm;
    return -1;

end internal_wrapup;

procedure setup
( errbuf in out nocopy varchar2
, retcode in out nocopy varchar2
, p_load_to in varchar2 default fnd_date.date_to_canonical(sysdate)
, p_force in varchar2 default 'N'
) as

  l_exception exception;
  l_error_message varchar2(4000);

  l_log_rowid rowid;
  l_process_type varchar2(30);
  l_collect_from_date date;
  l_collect_to_date date;
  l_success_flag varchar2(1);
  l_staging_flag varchar2(1);
  l_activity_flag varchar2(1);
  l_closed_flag varchar2(1);
  l_backlog_flag varchar2(1);
  l_resolution_flag varchar2(1);

  l_biv_schema varchar2(100);
  l_rowcount number;


begin
  if not bis_collection_utilities.setup( 'BIV_DBI_COLLECT_INIT_SETUP' ) then
    raise g_bis_setup_exception;
  end if;

  /* this is a temporary workaround to bad audit data cause by:
     - bug 3050727 - fixed
  */

  if biv_dbi_collection_util.correct_bad_audit(l_error_message) <> 0 then
    raise l_exception;
  end if;

  biv_dbi_collection_util.get_last_log( l_log_rowid
                                      , l_process_type
                                      , l_collect_from_date
                                      , l_collect_to_date
                                      , l_success_flag
                                      , l_staging_flag
                                      , l_activity_flag
                                      , l_closed_flag
                                      , l_backlog_flag
                                      , l_resolution_flag
                                      );

  if nvl(l_success_flag,'Y') = 'N' then

    if p_force = 'Y' then
      l_success_flag := 'Y';
      bis_collection_utilities.log('Last collection did not complete successfully, forcing new initial load');
    end if;

  end if;

  if nvl(l_success_flag,'Y') = 'N' and
     nvl(l_process_type,g_process_type) <> g_process_type then
     l_error_message := 'Initial Load cannot run as there is an incomplete incremental load in progress';
    raise l_exception;
  end if;

  if nvl(l_success_flag,'Y') = 'Y' then

    if l_log_rowid is not null then
      update biv_dbi_collection_log
      set last_collection_flag = 'N'
        , last_update_date = sysdate
        , last_updated_by = g_user_id
        , last_update_login = g_login_id
      where rowid = l_log_rowid;
    end if;

    l_collect_from_date := to_date(fnd_profile.value('BIS_GLOBAL_START_DATE'),'mm/dd/yyyy');
    if l_collect_from_date is null then
      l_error_message := 'BIS_GLOBAL_START_DATE is not set';
      raise l_exception;
    end if;

    if p_load_to is null then
      l_error_message := 'p_load_to is a required parameter';
      raise l_exception;
    end if;
    l_collect_to_date := fnd_date.canonical_to_date(p_load_to);
    if l_collect_to_date > sysdate then
      l_error_message := 'p_load_to must less than or equal to ' ||
             fnd_date.date_to_displaydt(sysdate);
      raise l_exception;
    end if;

    -- @@@@@@@@ -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
    -- the next line overrides the global start date retrieved from the
    -- BIS_GLOBAL_START_DATE so that we can test different scenareos
    -- l_collect_from_date := sysdate;
    --
    -- the next line override sysdate so we can test initial + incremental
    -- load
    -- l_collect_to_date := to_date('31-12-2002 23:59:59','dd-mm-yyyy hh24:mi:ss');
    -- @@@@@@@@ -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

    if biv_dbi_collection_util.get_schema_name
       (l_biv_schema, l_error_message) <> 0 then
      raise l_exception;
    end if;


    -- Populating escalation staging table for initial loads
    -- This staging table will be used in initial load programs of BIV summary tables
    -- For marking escalated_flag and escalation date
    IF( g_process_type = 'INITIAL_LOAD')
    THEN

       bis_collection_utilities.log('Starting Escalations Staging table population ');

       bis_collection_utilities.log('Truncating table '||l_biv_schema||'.'||'BIV_DBI_ESCALATIONS_STG');

       if biv_dbi_collection_util.truncate_table
          (l_biv_schema, 'BIV_DBI_ESCALATIONS_STG', l_error_message) <> 0 then
         raise l_exception;
       end if;

       bis_collection_utilities.log('Inserting rows into BIV_DBI_ESCALATIONS_STG');

       insert into biv_dbi_escalations_stg
       (
          incident_id,
          escalated_date_from,
          escalated_date_to,
          escalated_date,
          de_escalated_same_day
       )
            select /*+ use_hash(tsk,trf) parallel(tsk) parallel(trf) */
              trf.object_id incident_id
            , trunc(tsk.actual_start_date) escalated_date_from
            , trunc(nvl(tsk.actual_end_date,to_date('01-12-4712','DD-MM-YYYY'))) escalated_date_to
            , tsk.actual_start_date escalated_date
            , CASE WHEN trunc(tsk.actual_start_date) = trunc(nvl(tsk.actual_end_date,to_date('01-12-4712','DD-MM-YYYY')))
                   THEN
                      'Y'
                   ELSE
                      'N'
                   END  de_escalated_same_day
            from
              jtf_tasks_b tsk
            , jtf_task_references_b trf
            where
                trf.object_type_code = 'SR'
            and trf.reference_code = 'ESC'
            and tsk.task_type_id = 22
            and tsk.task_id = trf.task_id
	    and tsk.task_id in (select task_id from (select min(task_id)task_id, object_id
                                from jtf_task_references_b
                                where reference_code = 'ESC'
                                and object_type_code = 'SR'
                                 group by object_id));

       l_rowcount := sql%rowcount;

       bis_collection_utilities.log('Inserted ' || l_rowcount || ' rows');
       commit;

	BEGIN

	fnd_stats.gather_table_stats(ownname => 'BIV'
					,tabname => 'BIV_DBI_ESCALATIONS_STG', percent => 10);
	END;


    END IF;

    insert into biv_dbi_collection_log
    ( last_collection_flag
    , process_type
    , collect_from_date
    , collect_to_date
    , success_flag
    , staging_table_flag
    , activity_flag
    , closed_flag
    , backlog_flag
    , resolution_flag
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login
    )
    values
    ( 'Y'
    , g_process_type
    , l_collect_from_date
    , l_collect_to_date
    , 'N'
    , 'Y'
    , 'N'
    , 'N'
    , 'N'
    , 'N'
    , sysdate
    , g_user_id
    , sysdate
    , g_user_id
    , g_login_id
    );

    bis_collection_utilities.log('Starting new Initial Load');
    bis_collection_utilities.log('From ' || fnd_date.date_to_displaydt(l_collect_from_date),1);
    bis_collection_utilities.log('To ' || fnd_date.date_to_displaydt(l_collect_to_date),1);

  else

    bis_collection_utilities.log('Resuming previous incomplete Initial Load');
    bis_collection_utilities.log('From ' || fnd_date.date_to_displaydt(l_collect_from_date),1);
    bis_collection_utilities.log('To ' || fnd_date.date_to_displaydt(l_collect_to_date),1);

  end if;

  commit;

  bis_collection_utilities.wrapup( p_status => true
                                 , p_period_from => l_collect_from_date
                                 , p_period_to => l_collect_to_date
                                 );

exception
  when g_bis_setup_exception then
    rollback;
    errbuf := 'Error in BIS_COLLECTION_UTILITIES.Setup';
    retcode := '2';

  when others then
    rollback;
    if l_error_message is null then
      l_error_message := substr(sqlerrm,1,4000);
    end if;
    bis_collection_utilities.log('Error:');
    bis_collection_utilities.log(l_error_message,1);
    bis_collection_utilities.wrapup( p_status => false
                                   , p_message => l_error_message
                                   , p_period_from => l_collect_from_date
                                   , p_period_to => l_collect_to_date
                                   );
    errbuf := l_error_message;
    retcode := '2';

end setup;

/* The procedure load_activity inserts data into the activity fact.*/

procedure load_activity
( errbuf in out nocopy varchar2
, retcode in out nocopy varchar2) as

  l_exception exception;
  l_error_message varchar2(4000);

  l_log_rowid rowid;
  l_process_type varchar2(30);
  l_collect_from_date date;
  l_collect_to_date date;
  l_success_flag varchar2(1);
  l_staging_flag varchar2(1);
  l_activity_flag varchar2(1);
  l_closed_flag varchar2(1);
  l_backlog_flag varchar2(1);
  l_resolution_flag varchar2(1);

  l_biv_schema varchar2(100);

  l_timer number;
  l_rowcount number;

  l_missing_owner_group_id    number := biv_dbi_collection_util.get_missing_owner_group_id;
  l_missing_inventory_item_id number := biv_dbi_collection_util.get_missing_inventory_item_id;
  l_missing_organization_id   number := biv_dbi_collection_util.get_missing_organization_id;

begin

  if not bis_collection_utilities.setup( 'BIV_DBI_COLLECT_INIT_ACTIVITY' ) then
    raise g_bis_setup_exception;
  end if;

  biv_dbi_collection_util.get_last_log( l_log_rowid
                                      , l_process_type
                                      , l_collect_from_date
                                      , l_collect_to_date
                                      , l_success_flag
                                      , l_staging_flag
                                      , l_activity_flag
                                      , l_closed_flag
                                      , l_backlog_flag
                                      , l_resolution_flag
                                      );

  if l_process_type <> g_process_type then
    l_error_message := 'Activity process called for wrong process type';
    raise l_exception;
  end if;

  if nvl(l_success_flag,'X') <> 'N' then
    l_error_message := 'Activity process called for completed initial load';
    raise l_exception;
  end if;

  if l_activity_flag = 'N' then

    l_timer := dbms_utility.get_time;

    if biv_dbi_collection_util.get_schema_name
       (l_biv_schema, l_error_message) <> 0 then
      raise l_exception;
    end if;

    bis_collection_utilities.log('Starting Activity Initial Load');
    bis_collection_utilities.log('From ' || fnd_date.date_to_displaydt(l_collect_from_date),1);
    bis_collection_utilities.log('To ' || fnd_date.date_to_displaydt(l_collect_to_date),1);

    bis_collection_utilities.log('Truncating table '||l_biv_schema||'.'||'BIV_DBI_ACTIVITY_SUM_F');

    if biv_dbi_collection_util.truncate_table
       (l_biv_schema, 'BIV_DBI_ACTIVITY_SUM_F', l_error_message) <> 0 then
      raise l_exception;
    end if;

    bis_collection_utilities.log('Inserting rows into BIV_DBI_ACTIVITY_SUM_F');

    insert /*+ APPEND parallel(biv_dbi_activity_sum_f) */
    into biv_dbi_activity_sum_f
    ( activity_date
    , incident_type_id
    , inventory_item_id
    , inv_organization_id
    , incident_severity_id
    , customer_id
    , owner_group_id
    , sr_creation_channel
    , primary_flag
    , first_opened_count
    , reopened_count
    , closed_count
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login
    , incident_urgency_id
    , incident_owner_id
    , escalated_flag
    )
    select /*+ ordered full(a) use_hash(i) parallel(a) parallel(i) */
      trunc(a.creation_date) report_date
    , nvl(a.incident_type_id,-1) incident_type_id /* workaround bad data */
    , nvl2( a.inventory_item_id+a.inv_organization_id
          , a.inventory_item_id
          , l_missing_inventory_item_id ) inventory_item_id
    , nvl2( a.inventory_item_id+a.inv_organization_id
          , a.inv_organization_id
          , l_missing_organization_id ) inv_organization_id
    , nvl(a.incident_severity_id,-1) incident_severity_id /* workaround bad data */
    , nvl(i.customer_id,-1) customer_id /* workaround bad data */
    , decode(a.group_type, 'RS_GROUP', nvl(a.group_id,l_missing_owner_group_id)
                         , l_missing_owner_group_id) owner_group_id
    , nvl(i.sr_creation_channel,'-1') sr_creation_channel /* workaround bad data */
    , 'Y'
    , sum(case when a.change_incident_type_flag = 'Y'
                and a.old_incident_type_id is null then 1 else 0 end) first_opened_count
    , sum(case when a.change_status_flag = 'Y'
                and a.status_flag = 'O'
                and a.old_status_flag = 'C' then 1 else 0 end) reopened_count
    , sum(case when a.change_status_flag = 'Y'
                and a.status_flag = 'C' then 1 else 0 end) closed_count
    , sysdate
    , g_user_id
    , sysdate
    , g_user_id
    , g_login_id
    , nvl(a.incident_urgency_id, -1) incident_urgency_id
    , decode(a.resource_type, 'RS_EMPLOYEE', nvl(a.incident_owner_id, -2)
                         , -2) incident_owner_id
    , case when e.escalated_date <= a.creation_date then 'Y' else 'N' end  escalated_flag
    from
      cs_incidents_audit_b a
    , cs_incidents_all_b i
    , biv_dbi_escalations_stg e
    where
        a.incident_id = i.incident_id
    and a.creation_date >= l_collect_from_date
    and a.creation_date+0 <= l_collect_to_date /* change here as workaround to db bug killing parallelism */
    and 'Y' in ( a.change_status_flag
               )
    and nvl(a.updated_entity_code, 'SR_HEADER') IN ('SR_HEADER','SR_ESCALATION')
    and e.incident_id(+) = i.incident_id
    group by
      trunc(a.creation_date)
    , nvl(a.incident_type_id,-1) /* workaround bad data */
    , nvl2( a.inventory_item_id+a.inv_organization_id
          , a.inventory_item_id
          , l_missing_inventory_item_id )
    , nvl2( a.inventory_item_id+a.inv_organization_id
          , a.inv_organization_id
          , l_missing_organization_id )
    , nvl(a.incident_severity_id,-1) /* workaround bad data */
    , nvl(i.customer_id,-1) /* workaround bad data */
    , decode(a.group_type, 'RS_GROUP', nvl(a.group_id,l_missing_owner_group_id)
                         , l_missing_owner_group_id)
    , nvl(i.sr_creation_channel,'-1') /* workaround bad data */
    , nvl(a.incident_urgency_id, -1)
    , decode(a.resource_type, 'RS_EMPLOYEE', nvl(a.incident_owner_id, -2)
                         , -2)
    , case when e.escalated_date <= a.creation_date then 'Y' else 'N' end;

    l_rowcount := sql%rowcount;

    bis_collection_utilities.log('Inserted ' || l_rowcount || ' rows');

    update biv_dbi_collection_log
    set activity_flag = 'Y'
      , activity_count = l_rowcount
      , activity_time = dbms_utility.get_time - l_timer
      , activity_error_message = null
      , last_update_date = sysdate
      , last_updated_by = g_user_id
      , last_update_login = g_login_id
    where rowid = l_log_rowid;

    bis_collection_utilities.log('Activity initial load complete');

  else

    bis_collection_utilities.log('Activity initial load already complete, skipping');

  end if;

  if internal_wrapup(l_log_rowid, l_error_message) <> 0 then
    raise l_exception;
  end if;

  commit;

  bis_collection_utilities.wrapup( p_status => true
                                 , p_period_from => l_collect_from_date
                                 , p_period_to => l_collect_to_date
                                 , p_count => l_rowcount
                                 );

exception
  when g_bis_setup_exception then
    rollback;
    errbuf := 'Error in BIS_COLLECTION_UTILITIES.Setup';
    retcode := '2';
    biv_dbi_collection_util.set_log_error
    ( p_rowid           => l_log_rowid
    , p_activity_error  => errbuf
    );
    commit;

  when others then
    rollback;
    if l_error_message is null then
      l_error_message := substr(sqlerrm,1,4000);
    end if;
    biv_dbi_collection_util.set_log_error
    ( p_rowid           => l_log_rowid
    , p_activity_error  => l_error_message
    );
    commit;
    bis_collection_utilities.wrapup( p_status => false
                                   , p_message => l_error_message
                                   , p_period_from => l_collect_from_date
                                   , p_period_to => l_collect_to_date
                                   );
    errbuf := l_error_message;
    retcode := '2';

end load_activity;

/* The procedure load_closed inserts data into the closure fact.*/

procedure load_closed
( errbuf in out nocopy varchar2
, retcode in out nocopy varchar2) as

  l_exception exception;
  l_error_message varchar2(4000);

  l_log_rowid rowid;
  l_process_type varchar2(30);
  l_collect_from_date date;
  l_collect_to_date date;
  l_success_flag varchar2(1);
  l_staging_flag varchar2(1);
  l_activity_flag varchar2(1);
  l_closed_flag varchar2(1);
  l_backlog_flag varchar2(1);
  l_resolution_flag varchar2(1);

  l_biv_schema varchar2(100);

  l_timer number;
  l_rowcount number;

  l_missing_owner_group_id    number := biv_dbi_collection_util.get_missing_owner_group_id;
  l_missing_inventory_item_id number := biv_dbi_collection_util.get_missing_inventory_item_id;
  l_missing_organization_id   number := biv_dbi_collection_util.get_missing_organization_id;

begin

  if not bis_collection_utilities.setup( 'BIV_DBI_COLLECT_INIT_CLOSED' ) then
    raise g_bis_setup_exception;
  end if;

  biv_dbi_collection_util.get_last_log( l_log_rowid
                                      , l_process_type
                                      , l_collect_from_date
                                      , l_collect_to_date
                                      , l_success_flag
                                      , l_staging_flag
                                      , l_activity_flag
                                      , l_closed_flag
                                      , l_backlog_flag
                                      , l_resolution_flag
                                      );

  if l_process_type <> g_process_type then
    l_error_message := 'Closed process called for wrong process type';
    raise l_exception;
  end if;

  if nvl(l_success_flag,'X') <> 'N' then
    l_error_message := 'Closed process called for completed initial load';
    raise l_exception;
  end if;

  if l_closed_flag = 'N' then

    l_timer := dbms_utility.get_time;

    if biv_dbi_collection_util.get_schema_name
       (l_biv_schema, l_error_message) <> 0 then
      raise l_exception;
    end if;

    bis_collection_utilities.log('Starting Closed Initial Load');
    bis_collection_utilities.log('From ' || fnd_date.date_to_displaydt(l_collect_from_date),1);
    bis_collection_utilities.log('To ' || fnd_date.date_to_displaydt(l_collect_to_date),1);

    bis_collection_utilities.log('Truncating table '||l_biv_schema||'.'||'BIV_DBI_CLOSED_SUM_F');

    if biv_dbi_collection_util.truncate_table
       (l_biv_schema, 'BIV_DBI_CLOSED_SUM_F', l_error_message) <> 0 then
      raise l_exception;
    end if;

    bis_collection_utilities.log('Inserting rows into BIV_DBI_CLOSED_SUM_F');

    insert /*+ APPEND parallel(csf)*/
    into biv_dbi_closed_sum_f csf
    (
     report_date
    , incident_id
    , incident_type_id
    , inventory_item_id
    , inv_organization_id
    , incident_severity_id
    , customer_id
    , owner_group_id
    , sr_creation_channel
    , resolution_code
    , reopened_date
    , time_to_close
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login
    , incident_urgency_id
    , incident_owner_id
    , escalated_flag
    )
   select /*+ parallel(r) parallel(e) use_hash(e) */
   trunc(report_date),
   r.incident_id,
   nvl(incident_type_id,-1) incident_type_id, /* workaround bad data */
   nvl2( inventory_item_id+inv_organization_id
          , inventory_item_id
          , l_missing_inventory_item_id ) inventory_item_id,
   nvl2( inventory_item_id+inv_organization_id
          , inv_organization_id
          , l_missing_organization_id )inv_organization_id,
   nvl(incident_severity_id,-1) incident_severity_id, /* workaround bad data */
   nvl(customer_id,-1) customer_id,
   owner_group_id,
   nvl(sr_creation_channel,'-1') sr_creation_channel, /* workaround bad data */
   nvl(resolution_code,'-1') resolution_code,
   null,
   time_to_close,
   sysdate,
   g_user_id,
   sysdate,
   g_user_id,
   g_login_id,
   nvl(incident_urgency_id, '-1') incident_urgency_id,
   nvl(incident_owner_id,'-2') incident_owner_id,
   case when e.escalated_date <=  case
                                       when close_date is null or close_date < incident_date then last_update_date
                                       else close_date
                                     end
           then 'Y'
           else 'N'
   end  escalated_flag
from
(
 select /*+ use_hash(I) */
    case
              when i.close_date is null or i.close_date < i.incident_date then
                i.last_update_date
              else
                i.close_date
    end report_date,
    i.incident_id,
    a_incident_type_id  incident_type_id,
    a_inventory_item_id inventory_item_id,
    a_inv_organization_id inv_organization_id,
    a_incident_severity_id incident_severity_id,
    i.customer_id,
    decode(a_group_type, 'RS_GROUP', nvl(a_group_id,l_missing_owner_group_id), l_missing_owner_group_id) owner_group_id,
    i.sr_creation_channel,
    a_resolution_code resolution_code,
    CASE
        WHEN i.close_date is null or i.close_date < i.incident_date THEN i.last_update_date
        ELSE a_close_date
     END - i.incident_date time_to_close,
     a_incident_urgency_id incident_urgency_id,
     decode(a_resource_type, 'RS_EMPLOYEE', nvl(a_incident_owner_id,-2), -2) incident_owner_id,
    i.last_update_date,
    i.close_date,
    i.incident_date
   from
  (select /*+ parallel(ciab) */
      ciab.incident_id a_incident_id,
      max(ciab.close_date) keep (dense_rank last order by ciab.creation_date, ciab.incident_audit_id) a_close_date,
      max(ciab.incident_type_id) keep (dense_rank last order by ciab.creation_date, ciab.incident_audit_id) a_incident_type_id,
      max(ciab.inventory_item_id) keep (dense_rank last order by ciab.creation_date, ciab.incident_audit_id) a_inventory_item_id,
      max(ciab.inv_organization_id) keep (dense_rank last order by ciab.creation_date, ciab.incident_audit_id) a_inv_organization_id,
      max(ciab.incident_severity_id) keep (dense_rank last order by ciab.creation_date, ciab.incident_audit_id) a_incident_severity_id,
      max(ciab.group_type) keep (dense_rank last order by ciab.creation_date, ciab.incident_audit_id) a_group_type,
      max(ciab.resource_type) keep (dense_rank last order by ciab.creation_date, ciab.incident_audit_id) a_resource_type,
      max(ciab.resolution_code) keep (dense_rank last order by ciab.creation_date, ciab.incident_audit_id) a_resolution_code,
      max(ciab.group_id) keep (dense_rank last order by ciab.creation_date, ciab.incident_audit_id) a_group_id,
      max(ciab.incident_urgency_id) keep (dense_rank last order by ciab.creation_date, ciab.incident_audit_id) a_incident_urgency_id,
      max(ciab.incident_owner_id) keep (dense_rank last order by ciab.creation_date, ciab.incident_audit_id) a_incident_owner_id
   from cs_incidents_audit_b ciab
   where 1=1
   and ciab.status_flag = 'C' -- to pick up only those records that are closed.
   -- After the SR is closed changes made to the SR will not get picked up in the fact until its reopened and re-closed.
   and (ciab.old_status_flag ='O' or ciab.old_status_flag is null) /* using status_flag instead of old_closed_date as a workaround for bad data */
   group by ciab.incident_id
  ) a,
  cs_incidents_all_b i
  where i.incident_id = a.a_incident_id
  and  i.status_flag = 'C'
) r
, biv_dbi_escalations_stg e
where
  e.incident_id (+) = r.incident_id
and case
          when r.close_date is null or r.close_date < r.incident_date then
            r.last_update_date
          else
            r.close_date
        end >= l_collect_from_date
    and case
          when r.close_date is null or r.close_date < r.incident_date then
            r.last_update_date+0
          else
            r.close_date+0
        end <= l_collect_to_date;

    l_rowcount := sql%rowcount;

    bis_collection_utilities.log('Inserted ' || l_rowcount || ' rows');

    update biv_dbi_collection_log
    set closed_flag = 'Y'
      , closed_count = l_rowcount
      , closed_time = dbms_utility.get_time - l_timer
      , closed_error_message = null
      , last_update_date = sysdate
      , last_updated_by = g_user_id
      , last_update_login = g_login_id
    where rowid = l_log_rowid;

    bis_collection_utilities.log('Closed initial load complete');

  else

    bis_collection_utilities.log('Closed initial load already complete, skipping');

  end if;

  if internal_wrapup(l_log_rowid, l_error_message) <> 0 then
    raise l_exception;
  end if;

  commit;

  bis_collection_utilities.wrapup( p_status => true
                                 , p_period_from => l_collect_from_date
                                 , p_period_to => l_collect_to_date
                                 , p_count => l_rowcount
                                 );

exception
  when g_bis_setup_exception then
    rollback;
    errbuf := 'Error in BIS_COLLECTION_UTILITIES.Setup';
    retcode := '2';
    biv_dbi_collection_util.set_log_error
    ( p_rowid         => l_log_rowid
    , p_closed_error  => errbuf
    );
    commit;

  when others then
    rollback;
    if l_error_message is null then
      l_error_message := substr(sqlerrm,1,4000);
    end if;
    biv_dbi_collection_util.set_log_error
    ( p_rowid         => l_log_rowid
    , p_closed_error  => l_error_message
    );
    commit;
    bis_collection_utilities.wrapup( p_status => false
                                   , p_message => l_error_message
                                   , p_period_from => l_collect_from_date
                                   , p_period_to => l_collect_to_date
                                   );
    errbuf := l_error_message;
    retcode := '2';

end load_closed;

/* The procedure load_backlog inserts data into the backlog fact.*/

procedure load_backlog
( errbuf in out nocopy varchar2
, retcode in out nocopy varchar2) as

  l_exception exception;
  l_error_message varchar2(4000);

  l_log_rowid rowid;
  l_process_type varchar2(30);
  l_collect_from_date date;
  l_collect_to_date date;
  l_success_flag varchar2(1);
  l_staging_flag varchar2(1);
  l_activity_flag varchar2(1);
  l_closed_flag varchar2(1);
  l_backlog_flag varchar2(1);
  l_resolution_flag varchar2(1);

  l_biv_schema varchar2(100);

  l_timer number;
  l_rowcount number;

  l_missing_owner_group_id    number := biv_dbi_collection_util.get_missing_owner_group_id;
  l_missing_inventory_item_id number := biv_dbi_collection_util.get_missing_inventory_item_id;
  l_missing_organization_id   number := biv_dbi_collection_util.get_missing_organization_id;

  l_max_date date := to_date('4712/12/31','yyyy/mm/dd');

begin

  if not bis_collection_utilities.setup( 'BIV_DBI_COLLECT_INIT_BACKLOG' ) then
    raise g_bis_setup_exception;
  end if;

  biv_dbi_collection_util.get_last_log( l_log_rowid
                                      , l_process_type
                                      , l_collect_from_date
                                      , l_collect_to_date
                                      , l_success_flag
                                      , l_staging_flag
                                      , l_activity_flag
                                      , l_closed_flag
                                      , l_backlog_flag
                                      , l_resolution_flag
                                      );

  if l_process_type <> g_process_type then
    l_error_message := 'Backlog process called for wrong process type';
    raise l_exception;
  end if;

  if nvl(l_success_flag,'X') <> 'N' then
    l_error_message := 'Backlog process called for completed initial load';
    raise l_exception;
  end if;

  if l_backlog_flag = 'N' then

    l_timer := dbms_utility.get_time;

    if biv_dbi_collection_util.get_schema_name
       (l_biv_schema, l_error_message) <> 0 then
      raise l_exception;
    end if;

    bis_collection_utilities.log('Starting Backlog Initial Load');
    bis_collection_utilities.log('From ' || fnd_date.date_to_displaydt(l_collect_from_date),1);
    bis_collection_utilities.log('To ' || fnd_date.date_to_displaydt(l_collect_to_date),1);

    bis_collection_utilities.log('Truncating table '||l_biv_schema||'.'||'BIV_DBI_BACKLOG_SUM_F');

    if biv_dbi_collection_util.truncate_table
       (l_biv_schema, 'BIV_DBI_BACKLOG_SUM_F', l_error_message) <> 0 then
      raise l_exception;
    end if;

    bis_collection_utilities.log('Inserting rows into BIV_DBI_BACKLOG_SUM_F');

    insert /*+ APPEND parallel(biv_dbi_backlog_sum_f) */
    first
    when status_flag = 'O' then
      into biv_dbi_backlog_sum_f
      ( incident_id
      , backlog_date_from
      , backlog_date_to
      , incident_type_id
      , inventory_item_id
      , inv_organization_id
      , incident_severity_id
      , incident_status_id
      , customer_id
      , owner_group_id
      , sr_creation_channel
      , incident_date
      , escalated_date
      , unowned_date
      , creation_date
      , created_by
      , last_update_date
      , last_updated_by
      , last_update_login
      , resolved_flag
      , incident_resolved_date
      , escalated_flag
      , incident_urgency_id
      , incident_owner_id
      )
      values
      ( incident_id
      , date_from
      , date_to
      , incident_type_id
      , inventory_item_id
      , inv_organization_id
      , incident_severity_id
      , incident_status_id
      , customer_id
      , owner_group_id
      , sr_creation_channel
      , incident_date
      , escalated_date
      , unowned_date
      , sysdate
      , g_user_id
      , sysdate
      , g_user_id
      , g_login_id
      , resolved_flag
      , incident_resolved_date
      , escalated_flag
      , incident_urgency_id
      , incident_owner_id
      )
    select /*+ parallel(b) */
      status_flag
    , incident_id
    , greatest(audit_date,trunc(l_collect_from_date)) date_from
    , lead(audit_date-1,1,l_max_date) over (partition by incident_id order by audit_date) date_to
    , incident_type_id
    , inventory_item_id
    , inv_organization_id
    , incident_severity_id
    , incident_status_id
    , customer_id
    , owner_group_id
    , sr_creation_channel
    , incident_date
    , escalated_date
    , unowned_date
    , resolved_flag
    , incident_resolved_date
    , escalated_flag
    , incident_urgency_id
    , incident_owner_id
    from
      (
        select /*+ parallel(a) parallel(i) parallel(e) USE_HASH(A,I,E) */
          a.incident_id
        , a.audit_date
        , nvl(a.status_flag,'O') status_flag /* workaround bad data */
        , nvl(a.incident_type_id,-1) incident_type_id /* workaround bad data */
        , nvl2( a.inventory_item_id+a.inv_organization_id
              , a.inventory_item_id
              , l_missing_inventory_item_id ) inventory_item_id
        , nvl2( a.inventory_item_id+a.inv_organization_id
              , a.inv_organization_id
              , l_missing_organization_id )inv_organization_id
        , nvl(a.incident_status_id,-1) incident_status_id /* workaround bad data */
        , nvl(a.incident_severity_id,-1) incident_severity_id /* workaround bad data */
        , nvl(i.customer_id,-1) customer_id /* workaround bad data */
        , a.owner_group_id
        , nvl(i.sr_creation_channel,'-1') sr_creation_channel /* workaround bad data */
        , a.unowned_date
        , i.incident_date
        , case when a.audit_date >= e.escalated_date_from and
                    a.audit_date < e.escalated_date_to then
                 e.escalated_date
               else
                 null
          end escalated_date
        , case when
                  (a.incident_resolved_date is not null
                  and trunc(a.incident_resolved_date) <= a.audit_date)
               then
                  'Y'
               else
                  'N'
          end  resolved_flag
        , a.incident_resolved_date
        , case when e.escalated_date_from <= a.audit_date then 'Y' else 'N' end  escalated_flag
        , nvl(a.incident_urgency_id, -1) incident_urgency_id
        , nvl(a.incident_owner_id, -2) incident_owner_id
        from
          (
            /* this query extracts just the last row for each
               incident in any day
            */
            select /*+ parallel(a) */
              incident_id
            , audit_date_for_day audit_date
            , status_flag
            , incident_status_id
            , incident_type_id
            , incident_severity_id
            , owner_group_id
            , inventory_item_id
            , inv_organization_id
            , unowned_date
            , incident_resolved_date
            , incident_urgency_id
            , incident_owner_id
            from
              (
                /*
                   this query identifies all audit rows the audit table
                   that have changes that may be of interest, and identifies
                   the last row for each incident on any day
                */
                select /*+ parallel(a) full(a) */
                  a.incident_id
                , a.incident_date
                , a.status_flag
                , a.incident_status_id
                , a.incident_type_id
                , a.incident_severity_id
                , decode(a.group_type, 'RS_GROUP', nvl(a.group_id,l_missing_owner_group_id)
                                   , l_missing_owner_group_id) owner_group_id
                , a.inventory_item_id
                , a.inv_organization_id
                , decode( a.incident_owner_id
                        , null
                        , nvl(a.owner_assigned_time,nvl(a.incident_date,a.creation_date))
                          -- based on bug 2993526, if the incident is created
                          -- with no owner, the initial audit row will have
                          -- NULL in owner_assigned_time - intended behavior
                          -- so we need to take incident_date from audit row
                          -- if for any reason (bad data) this is null, then we take
                          -- creation_date from row.
                        , null ) unowned_date
                , incident_resolved_date incident_resolved_date
                , decode( a.incident_audit_id
                        , last_value(a.incident_audit_id)
                          over ( partition by a.incident_id, trunc(a.creation_date)
                                 -- modified order by based on conclusions found in bug 3524935
                                 order by decode(a.old_status_flag,null,1,2)
                                        , a.creation_date
                                        , a.incident_audit_id
                                 rows between unbounded preceding and unbounded following )
                        , 'Y'
                        , 'N' ) last_row_for_day
                , trunc(a.creation_date) audit_date_for_day
                , a.incident_urgency_id
                , decode(a.resource_type, 'RS_EMPLOYEE', nvl(a.incident_owner_id, -2)
                         , -2) incident_owner_id
                from
                  cs_incidents_audit_b a
                where
                    a.creation_date >= l_collect_from_date
	        and nvl(a.updated_entity_code, 'SR_HEADER') IN ('SR_HEADER','SR_ESCALATION')
                and ( 'Y' in ( a.change_incident_status_flag
                           , a.change_incident_type_flag
                           , a.change_incident_severity_flag
                           , a.change_inventory_item_flag
                           , a.change_inv_organization_flag
                           , a.change_status_flag
                           , a.change_incident_owner_flag
                           , a.change_group_flag
                           , a.change_incident_urgency_flag
                           ) OR a.old_incident_resolved_date <> a.incident_resolved_date )
              )
            where
                last_row_for_day = 'Y'
            ----------------------------
            union all
            ----------------------------
            /*
               this query extracts the state of incidents that
               form the opening backlog based on the their first
               change since the global start date or their current
               value if no changes since global start date
            */
            select
              incident_id
            , audit_date
            , status_flag
            , incident_status_id
            , incident_type_id
            , incident_severity_id
            , owner_group_id
            , inventory_item_id
            , inv_organization_id
            , unowned_date
            , incident_resolved_date
            , incident_urgency_id
            , incident_owner_id
            from
              (
                select
                  incident_id
                , decode( row_number()
                          over( partition by incident_id
                                -- modified order by based on conclusions found in bug 3524935
                                order by source
                                       , creation_date
                                       , incident_audit_id )
                        , 1, 'Y', 'N') first_for_incident
                , trunc(l_collect_from_date) -1 audit_date
                , status_flag
                , incident_status_id
                , incident_type_id
                , incident_severity_id
                , nvl(owner_group_id, l_missing_owner_group_id) owner_group_id
                , nvl2( inventory_item_id+inv_organization_id
                      , inventory_item_id
                      , l_missing_inventory_item_id ) inventory_item_id
                , nvl2( inventory_item_id+inv_organization_id
                      , inv_organization_id
                      , l_missing_organization_id )inv_organization_id
                , unowned_date
                , incident_resolved_date
                , incident_urgency_id
                , incident_owner_id
                from
                  (
                    select /*+ parallel(a) full(a) */
                      a.incident_id
                    , 1 source
                    , a.creation_date
                    , a.incident_audit_id
                    , decode( a.change_status_flag
                            , 'Y'
                            , a.old_status_flag
                            , a.status_flag ) status_flag
                    , decode( a.change_incident_status_flag
                            , 'Y'
                            , a.old_incident_status_id
                            , a.incident_status_id ) incident_status_id
                    , decode( a.change_incident_type_flag
                            , 'Y'
                            , a.old_incident_type_id
                            , a.incident_type_id ) incident_type_id
                    , decode( a.change_incident_severity_flag
                            , 'Y'
                            , a.old_incident_severity_id
                            , a.incident_severity_id ) incident_severity_id
                    , decode( a.change_group_flag
                            , 'Y'
                            , decode(a.old_group_type,'RS_GROUP',a.old_group_id,null)
                            , decode(a.group_type,'RS_GROUP',a.group_id,null) ) owner_group_id
                    , decode( a.change_inventory_item_flag
                            , 'Y'
                            , a.old_inventory_item_id
                            , a.inventory_item_id ) inventory_item_id
                    , decode( a.change_inv_organization_flag
                            , 'Y'
                            , a.old_inv_organization_id
                            , a.inv_organization_id ) inv_organization_id
                    , decode( a.change_incident_owner_flag
                            , 'Y'
                                      -- based on bug 2993526, if the incident is created
                                      -- with no owner, the initial audit row will have
                                      -- NULL in owner_assigned_time - intended behavior
                                      -- so we need to take incident_date from audit row
                                      -- if for any reason (bad data) this is null, then we take
                                      -- creation_date from row.
                            , decode( a.old_incident_owner_id
                                    , null
                                    , nvl(a.old_owner_assigned_time,nvl(a.incident_date,a.creation_date))
                                    , null )
                            , decode( a.incident_owner_id
                                    , null
                                    , nvl(a.owner_assigned_time,nvl(a.incident_date,a.creation_date))
                                    , null ) ) unowned_date
                    , case when a.old_incident_resolved_date <> a.incident_resolved_date
                           then a.old_incident_resolved_date
                           else a.incident_resolved_date end incident_resolved_date
                    , decode( a.change_incident_urgency_flag
                            , 'Y'
                            , a.old_incident_urgency_id
                            , a.incident_urgency_id ) incident_urgency_id
                    , decode( a.change_incident_owner_flag
                            , 'Y'
                            , decode(a.old_resource_type, 'RS_EMPLOYEE', nvl(a.old_incident_owner_id, -2) , -2)
                            , decode(a.resource_type, 'RS_EMPLOYEE', nvl(a.incident_owner_id, -2) , -2) ) incident_owner_id
                    from
                      cs_incidents_audit_b a
                    where
                        a.creation_date >= l_collect_from_date
		    and nvl(a.updated_entity_code, 'SR_HEADER') IN ('SR_HEADER','SR_ESCALATION')
                    and a.incident_date < l_collect_from_date
                    and ( 'Y' in ( a.change_incident_status_flag
                               , a.change_incident_type_flag
                               , a.change_incident_severity_flag
                               , a.change_inventory_item_flag
                               , a.change_inv_organization_flag
                               , a.change_status_flag
                               , a.change_incident_owner_flag
                               , a.change_incident_urgency_flag
                               , a.change_group_flag
                               ) or  a.old_incident_resolved_date <> a.incident_resolved_date )
                    union all
                    select /*+ parallel(i) full(i) */
                      i.incident_id
                    , 2 source
                    , l_collect_from_date -1
                    , 1
                    , i.status_flag
                    , i.incident_status_id
                    , i.incident_type_id
                    , i.incident_severity_id
                    , decode(i.group_type,'RS_GROUP',i.owner_group_id,null) owner_group_id
                    , i.inventory_item_id
                    , i.inv_organization_id
                    , decode( i.incident_owner_id
                            , null
                            , nvl(i.owner_assigned_time,i.incident_date)
                              -- based on bug 2993526, if the incident is created
                              -- with no owner, the initial audit row will have
                              -- NULL in owner_assigned_time - intended behavior
                              -- so we need to take incident_date.
                            , null ) unowned_date
                    , incident_resolved_date incident_resolved_date
                    , i.incident_urgency_id
                    , decode(i.resource_type, 'RS_EMPLOYEE', nvl(i.incident_owner_id, -2)
                         , -2) incident_owner_id
                    from
                      cs_incidents_all_b i
                    where
                        i.incident_date < l_collect_from_date
                    -- modified - this is not logical, unless it's 'O' it will be ingored anyway!
                    and i.status_flag = 'O'
                  )
                )
              where
                  first_for_incident = 'Y'
              and status_flag = 'O'
          ) a
        , cs_incidents_all_b i
        , ( select /*+ parallel(stg) */ * from biv_dbi_escalations_stg stg
            where de_escalated_same_day = 'N'
          ) e
        where
            a.incident_id = i.incident_id
        and e.incident_id(+) = a.incident_id
        and a.audit_date <= l_collect_to_date
      ) b;

    l_rowcount := sql%rowcount;

    bis_collection_utilities.log('Inserted ' || l_rowcount || ' rows');

    update biv_dbi_collection_log
    set backlog_flag = 'Y'
      , backlog_count = l_rowcount
      , backlog_time = dbms_utility.get_time - l_timer
      , backlog_error_message = null
      , last_update_date = sysdate
      , last_updated_by = g_user_id
      , last_update_login = g_login_id
    where rowid = l_log_rowid;

    bis_collection_utilities.log('Backlog initial load complete');

  else

    bis_collection_utilities.log('Backlog initial load already complete, skipping');

  end if;

  if internal_wrapup(l_log_rowid, l_error_message) <> 0 then
    raise l_exception;
  end if;

  commit;

  bis_collection_utilities.wrapup( p_status => true
                                 , p_period_from => l_collect_from_date
                                 , p_period_to => l_collect_to_date
                                 , p_count => l_rowcount
                                 );

exception
  when g_bis_setup_exception then
    rollback;
    errbuf := 'Error in BIS_COLLECTION_UTILITIES.Setup';
    retcode := '2';
    biv_dbi_collection_util.set_log_error
    ( p_rowid          => l_log_rowid
    , p_backlog_error  => errbuf
    );
    commit;

  when others then
    rollback;
    if l_error_message is null then
      l_error_message := substr(sqlerrm,1,4000);
    end if;
    biv_dbi_collection_util.set_log_error
    ( p_rowid          => l_log_rowid
    , p_backlog_error  => l_error_message
    );
    commit;
    bis_collection_utilities.wrapup( p_status => false
                                   , p_message => l_error_message
                                   , p_period_from => l_collect_from_date
                                   , p_period_to => l_collect_to_date
                                   );
    errbuf := l_error_message;
    retcode := '2';

end load_backlog;

/* The procedure load_resolution inserts data into the resolution fact.*/

procedure load_resolved
( errbuf in out nocopy varchar2
, retcode in out nocopy varchar2) as

  l_exception exception;
  l_error_message varchar2(4000);

  l_log_rowid rowid;
  l_process_type varchar2(30);
  l_collect_from_date date;
  l_collect_to_date date;
  l_success_flag varchar2(1);
  l_staging_flag varchar2(1);
  l_activity_flag varchar2(1);
  l_closed_flag varchar2(1);
  l_backlog_flag varchar2(1);
  l_resolution_flag varchar2(1);

  l_biv_schema varchar2(100);

  l_timer number;
  l_rowcount number;

  l_missing_owner_group_id    number := biv_dbi_collection_util.get_missing_owner_group_id;
  l_missing_inventory_item_id number := biv_dbi_collection_util.get_missing_inventory_item_id;
  l_missing_organization_id   number := biv_dbi_collection_util.get_missing_organization_id;

begin

  if not bis_collection_utilities.setup( 'BIV_DBI_COLLECT_INIT_RESOLUTION' ) then
    raise g_bis_setup_exception;
  end if;

  biv_dbi_collection_util.get_last_log( l_log_rowid
                                      , l_process_type
                                      , l_collect_from_date
                                      , l_collect_to_date
                                      , l_success_flag
                                      , l_staging_flag
                                      , l_activity_flag
                                      , l_closed_flag
                                      , l_backlog_flag
                                      , l_resolution_flag
                                      );

  if l_process_type <> g_process_type then
    l_error_message := 'Resolution process called for wrong process type';
    raise l_exception;
  end if;

  if nvl(l_success_flag,'X') <> 'N' then
    l_error_message := 'Resolution process called for completed initial load';
    raise l_exception;
  end if;

  if l_resolution_flag = 'N' then

    l_timer := dbms_utility.get_time;

    if biv_dbi_collection_util.get_schema_name
       (l_biv_schema, l_error_message) <> 0 then
      raise l_exception;
    end if;

    bis_collection_utilities.log('Starting Resolution Initial Load');
    bis_collection_utilities.log('From ' || fnd_date.date_to_displaydt(l_collect_from_date),1);
    bis_collection_utilities.log('To ' || fnd_date.date_to_displaydt(l_collect_to_date),1);

    bis_collection_utilities.log('Truncating table '||l_biv_schema||'.'||'BIV_DBI_RESOLUTION_SUM_F');

    if biv_dbi_collection_util.truncate_table
       (l_biv_schema, 'BIV_DBI_RESOLUTION_SUM_F', l_error_message) <> 0 then
      raise l_exception;
    end if;

    bis_collection_utilities.log('Inserting rows into BIV_DBI_RESOLUTION_SUM_F');

insert /*+ APPEND parallel(rsf)*/
    into biv_dbi_resolution_sum_f rsf
    (
      report_date
    , incident_id
    , incident_type_id
    , inventory_item_id
    , inv_organization_id
    , incident_severity_id
    , customer_id
    , owner_group_id
    , sr_creation_channel
    , resolution_code
    , time_to_resolution
    , escalated_flag
    , incident_urgency_id
    , incident_owner_id
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login
    , respond_on_date
    , respond_by_date
    , resolve_by_date
    , incident_date
    , contract_number
    )
   select /*+ parallel(r) parallel(e) use_hash(e) */
   CASE WHEN incident_resolved_date < incident_date
	THEN last_update_date
        ELSE incident_resolved_date
   END report_date,
   r.incident_id,
   incident_type_id,
   nvl2( inventory_item_id+inv_organization_id
          , inventory_item_id
          , l_missing_inventory_item_id ) inventory_item_id,
   nvl2( inventory_item_id+inv_organization_id
          , inv_organization_id
          , l_missing_organization_id )inv_organization_id,
   incident_severity_id,
   nvl(customer_id,-1) customer_id,
   owner_group_id,
   nvl(sr_creation_channel,'-1') sr_creation_channel,
   nvl(resolution_code,'-1') resolution_code,
   CASE WHEN (incident_resolved_date IS NOT NULL)
   THEN
      case
              when incident_resolved_date < incident_date then
                last_update_date
              else
                incident_resolved_date
      end
   ELSE
      NULL
   END  - incident_date time_to_resolution,
   case when e.escalated_date <=  case
                                     when incident_resolved_date < r.incident_date then last_update_date
                                     else incident_resolved_date
                                   end
         then 'Y'
         else 'N'
   end  escalated_flag,
   nvl(incident_urgency_id, '-1') incident_urgency_id,
   nvl(incident_owner_id,'-2') incident_owner_id,
   sysdate,
   g_user_id,
   sysdate,
   g_user_id,
   g_login_id,
   respond_on_date,
   respond_by_date,
   resolve_by_date,
   incident_date,
   contract_number
from
(
 select /*+ use_hash(I) */
    i.incident_id,
    CASE
      WHEN(i.incident_resolved_date = a.a_incident_resolved_date) THEN
          CASE WHEN(a.a_incident_resolved_date < i.incident_date) then i.incident_date
              -- WHEN(a.a_incident_resolved_date > i.close_date ) then i.close_date
               ELSE a.a_incident_resolved_date
          END
/*     From 8.0 SR's that are resolved only are taken into the resolution fact.
	i.e. all SR's that are closed are not pulled into the resolution fact until they have been resolved.
	WHEN (i.status_flag = 'C') THEN
           case
              when i.close_date is null or i.close_date < i.incident_date then
                i.last_update_date
              else
                i.close_date
            end
      ELSE NULL */
    END incident_resolved_date,
    CASE
      WHEN(i.incident_resolved_date = a.a_incident_resolved_date) THEN  a_incident_type_id
      ELSE incident_type_id
    END incident_type_id,
    CASE
      WHEN(i.incident_resolved_date = a.a_incident_resolved_date) THEN  a_inventory_item_id
      ELSE inventory_item_id
      END inventory_item_id,
    CASE
      WHEN(i.incident_resolved_date = a.a_incident_resolved_date) THEN  a_inv_organization_id
      ELSE inv_organization_id
    END inv_organization_id,
    CASE
      WHEN(i.incident_resolved_date = a.a_incident_resolved_date) THEN  a_incident_severity_id
      ELSE incident_severity_id
      END incident_severity_id,
    i.customer_id,
    CASE
      WHEN(i.incident_resolved_date = a.a_incident_resolved_date) THEN
            decode(a_group_type, 'RS_GROUP', nvl(a_group_id,l_missing_owner_group_id), l_missing_owner_group_id)
      ELSE  decode(group_type, 'RS_GROUP', nvl(owner_group_id,l_missing_owner_group_id), l_missing_owner_group_id)
    END owner_group_id,
    i.sr_creation_channel,
    CASE
      WHEN(i.incident_resolved_date = a.a_incident_resolved_date) THEN  a_resolution_code
      ELSE resolution_code
    END resolution_code,
    i.last_update_date,
    CASE
      WHEN(i.incident_resolved_date = a.a_incident_resolved_date) THEN  a_incident_urgency_id
      ELSE incident_urgency_id
    END incident_urgency_id,
    CASE
      WHEN(i.incident_resolved_date = a.a_incident_resolved_date)
      THEN  decode(a_resource_type, 'RS_EMPLOYEE', nvl(a_incident_owner_id,-2), -2)
      ELSE decode(resource_type, 'RS_EMPLOYEE', nvl(incident_owner_id,-2), -2)
    END incident_owner_id,
    i.inc_responded_by_date respond_on_date,
    i.obligation_date respond_by_date,
    i.expected_resolution_date resolve_by_date,
    i.incident_date,
    i.contract_number contract_number
  from
  (select /*+ parallel(CS_INCIDENTS_AUDIT_B) */
      ciab.incident_id a_incident_id,
      max(ciab.incident_resolved_date) keep (dense_rank last order by ciab.creation_date, ciab.incident_audit_id) a_incident_resolved_date,
      max(ciab.incident_type_id) keep (dense_rank last order by ciab.creation_date, ciab.incident_audit_id) a_incident_type_id,
      max(ciab.inventory_item_id) keep (dense_rank last order by ciab.creation_date, ciab.incident_audit_id) a_inventory_item_id,
      max(ciab.inv_organization_id) keep (dense_rank last order by ciab.creation_date, ciab.incident_audit_id) a_inv_organization_id,
      max(ciab.incident_severity_id) keep (dense_rank last order by ciab.creation_date, ciab.incident_audit_id) a_incident_severity_id,
      max(ciab.group_type) keep (dense_rank last order by ciab.creation_date, ciab.incident_audit_id) a_group_type,
      max(ciab.resource_type) keep (dense_rank last order by ciab.creation_date, ciab.incident_audit_id) a_resource_type,
      max(ciab.resolution_code) keep (dense_rank last order by ciab.creation_date, ciab.incident_audit_id) a_resolution_code,
      max(ciab.group_id) keep (dense_rank last order by ciab.creation_date, ciab.incident_audit_id) a_group_id,
      max(ciab.incident_urgency_id) keep (dense_rank last order by ciab.creation_date, ciab.incident_audit_id) a_incident_urgency_id,
      max(ciab.incident_owner_id) keep (dense_rank last order by ciab.creation_date, ciab.incident_audit_id) a_incident_owner_id
   from cs_incidents_audit_b ciab
   where 1=1
   and  ciab.INCIDENT_RESOLVED_DATE is not null
   and (ciab.old_status_flag = 'O' or ciab.old_status_flag is null)
   /*  and INCIDENT_RESOLVED_DATE <> nvl(OLD_INCIDENT_RESOLVED_DATE,INCIDENT_RESOLVED_DATE+1)
    removed the where clause in 8.0 so that the latest attibutes are picked into the Resolution fact until the SR is closed.
    After the SR is closed changes made to the SR will not get picked up in the fact until its reopened and re-resolved.*/
   group by ciab.incident_id
  ) a,
  cs_incidents_all_b i
  where i.incident_id = a.a_incident_id (+)
) r
, biv_dbi_escalations_stg e
where
  e.incident_id (+) = r.incident_id
and  ( incident_resolved_date IS NOT NULL
        AND
        (
          case
          when incident_resolved_date < incident_date then
            last_update_date
          else
            incident_resolved_date
          end >= l_collect_from_date
         and case
          when incident_resolved_date < incident_date then
            last_update_date+0
          else
            incident_resolved_date+0
          end <= l_collect_to_date
        )
      );
    l_rowcount := sql%rowcount;

    bis_collection_utilities.log('Inserted ' || l_rowcount || ' rows');

    update biv_dbi_collection_log
    set resolution_flag = 'Y'
      , resolution_count = l_rowcount
      , resolution_time = dbms_utility.get_time - l_timer
      , resolution_error_message = null
      , last_update_date = sysdate
      , last_updated_by = g_user_id
      , last_update_login = g_login_id
    where rowid = l_log_rowid;

    bis_collection_utilities.log('Resolution initial load complete');

  else

    bis_collection_utilities.log('Resolution initial load already complete, skipping');

  end if;

  if internal_wrapup(l_log_rowid, l_error_message) <> 0 then
    raise l_exception;
  end if;

  commit;

  bis_collection_utilities.wrapup( p_status => true
                                 , p_period_from => l_collect_from_date
                                 , p_period_to => l_collect_to_date
                                 , p_count => l_rowcount
                                 );

exception
  when g_bis_setup_exception then
    rollback;
    errbuf := 'Error in BIS_COLLECTION_UTILITIES.Setup';
    retcode := '2';
    biv_dbi_collection_util.set_log_error
    ( p_rowid         => l_log_rowid
    , p_resolution_error  => errbuf
    );
    commit;

  when others then
    rollback;
    if l_error_message is null then
      l_error_message := substr(sqlerrm,1,4000);
    end if;
    biv_dbi_collection_util.set_log_error
    ( p_rowid         => l_log_rowid
    , p_resolution_error  => l_error_message
    );
    commit;
    bis_collection_utilities.wrapup( p_status => false
                                   , p_message => l_error_message
                                   , p_period_from => l_collect_from_date
                                   , p_period_to => l_collect_to_date
                                   );
    errbuf := l_error_message;
    retcode := '2';

end load_resolved;

procedure wrapup
( errbuf in out nocopy varchar2
, retcode in out nocopy varchar2) as

begin

  -- this is now a noop
  return;

end wrapup;


end biv_dbi_collection_init;

/
