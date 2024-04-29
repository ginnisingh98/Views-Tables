--------------------------------------------------------
--  DDL for Package Body BIV_DBI_COLLECTION_INC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BIV_DBI_COLLECTION_INC" as
/* $Header: bivsrvcincb.pls 120.5 2006/01/17 03:09:06 ngmishra noship $ */

  g_bis_setup_exception exception;
  g_user_id number := fnd_global.user_id;
  g_login_id number := fnd_global.login_id;
  g_process_type varchar2(30) := 'INCREMENTAL_LOAD';

function apply_escalations
( p_collect_from_date in date
, p_collect_to_date   in date
, x_rowcount out nocopy number
, x_error_message out nocopy varchar2
) return number is

  /* this cursor finds all of the escalation that relate to
     incident present in the staging table.
  */
  cursor c_esc is
    select
      trf.object_id incident_id
    , tsk.actual_start_date escalated_date_from
    , nvl(tsk.actual_end_date,p_collect_to_date+1) escalated_date_to
    from
      jtf_tasks_b tsk
    , jtf_task_references_b trf
    where
       trf.object_type_code = 'SR'
    and trf.reference_code = 'ESC'
    and tsk.task_type_id = 22
    and tsk.task_id = trf.task_id
    and trf.object_id in ( select /*+ cardinality(stg,10) NO_UNNEST */ incident_id from biv_dbi_collection_stg stg)
    and NOT EXISTS
    (SELECT null
     FROM jtf_task_references_b trf2
     where trf2.reference_code = 'ESC'
     and  trf2.object_type_code = 'SR'
     and trf2.object_id = trf.object_id
     and trf2.task_id < trf.task_id)
order by 1, 2, 3;

  /* this cursor attempts to find the last row in the staging
     table prior or equal to the escalation (from or to) date
  */
  cursor c_stg( b_incident_id number, b_esc_date date ) is
    select
      audit_date
    , incident_type_id
    , inventory_item_id
    , inv_organization_id
    , incident_severity_id
    , incident_status_id
    , owner_group_id
    , status_flag
    , sr_creation_channel
    , customer_id
    , incident_date
    , unowned_date
    , resolved_flag
    , incident_resolved_date
    , resolved_event_flag
    , unresolved_event_flag
    , backlog_rowid
    , resolution_code
    , incident_urgency_id
    , incident_owner_id
    from
      biv_dbi_collection_stg
    where
        incident_id = b_incident_id
    and audit_date <= b_esc_date
    order by
      audit_date desc
    , incident_audit_id desc;

  l_stg_rec c_stg%rowtype;
  l_rowcount number := 0;

begin

  for e in c_esc loop
    /* if the escalation started on or after the current collect from
       date we need to check that we have a row in the staging
       table for the day that it starts
    */
    if e.escalated_date_from >= p_collect_from_date then
      open c_stg( e.incident_id, e.escalated_date_from );
      fetch c_stg into l_stg_rec;
      if c_stg%found and
         (trunc(l_stg_rec.audit_date) < trunc(e.escalated_date_from) or
          l_stg_rec.backlog_rowid is not null) then
        insert into biv_dbi_collection_stg
        ( incident_id
        , audit_date
        , incident_audit_id
        , incident_type_id
        , inventory_item_id
        , inv_organization_id
        , incident_severity_id
        , incident_status_id
        , owner_group_id
        , status_flag
        , sr_creation_channel
        , customer_id
        , incident_date
        , unowned_date
        , resolved_flag
        , incident_resolved_date
        , resolved_event_flag
        , unresolved_event_flag
        , resolution_code
        , last_for_day_flag
        , creation_date
        , created_by
        , last_update_date
        , last_updated_by
        , last_update_login
        , incident_urgency_id
        , incident_owner_id
        , ever_escalated
        )
        values
        ( e.incident_id
        , trunc(e.escalated_date_from)
        , 2
        , l_stg_rec.incident_type_id
        , l_stg_rec.inventory_item_id
        , l_stg_rec.inv_organization_id
        , l_stg_rec.incident_severity_id
        , l_stg_rec.incident_status_id
        , l_stg_rec.owner_group_id
        , l_stg_rec.status_flag
        , l_stg_rec.sr_creation_channel
        , l_stg_rec.customer_id
        , l_stg_rec.incident_date
        , l_stg_rec.unowned_date
        , l_stg_rec.resolved_flag
        , l_stg_rec.incident_resolved_date
        , l_stg_rec.resolved_event_flag
        , l_stg_rec.unresolved_event_flag
        , l_stg_rec.resolution_code
        , 'Y'
        , sysdate
        , g_user_id
        , sysdate
        , g_user_id
        , g_login_id
        , l_stg_rec.incident_urgency_id
        , l_stg_rec.incident_owner_id
        , 'N'
        );
        l_rowcount := l_rowcount +1;
      end if;
      close c_stg;
    end if;

    /* if the escalation ended between the current collect from
       date and the collect to date we need to check that we have a row
       in the staging table for the day that it ends
    */
    if e.escalated_date_to between p_collect_from_date
                               and p_collect_to_date then
      open c_stg( e.incident_id, e.escalated_date_to );
      fetch c_stg into l_stg_rec;
      if c_stg%found and
         (trunc(l_stg_rec.audit_date) < trunc(e.escalated_date_to) or
          l_stg_rec.backlog_rowid is not null) then
        insert into biv_dbi_collection_stg
        ( incident_id
        , audit_date
        , incident_audit_id
        , incident_type_id
        , inventory_item_id
        , inv_organization_id
        , incident_severity_id
        , incident_status_id
        , owner_group_id
        , status_flag
        , sr_creation_channel
        , customer_id
        , incident_date
        , unowned_date
        , resolved_flag
        , incident_resolved_date
        , resolved_event_flag
        , unresolved_event_flag
        , resolution_code
        , last_for_day_flag
        , creation_date
        , created_by
        , last_update_date
        , last_updated_by
        , last_update_login
        , incident_urgency_id
        , incident_owner_id
        , ever_escalated
        )
        values
        ( e.incident_id
        , trunc(e.escalated_date_to)
        , 2
        , l_stg_rec.incident_type_id
        , l_stg_rec.inventory_item_id
        , l_stg_rec.inv_organization_id
        , l_stg_rec.incident_severity_id
        , l_stg_rec.incident_status_id
        , l_stg_rec.owner_group_id
        , l_stg_rec.status_flag
        , l_stg_rec.sr_creation_channel
        , l_stg_rec.customer_id
        , l_stg_rec.incident_date
        , l_stg_rec.unowned_date
        , null   -- RAVI to Verify
        , null   -- RAVI tp Verify
        , 'N'
        , 'N'
        , l_stg_rec.resolution_code
        , 'Y'
        , sysdate
        , g_user_id
        , sysdate
        , g_user_id
        , g_login_id
        , l_stg_rec.incident_urgency_id
        , l_stg_rec.incident_owner_id
        , 'N'
        );
      end if;
      l_rowcount := l_rowcount +1;
      close c_stg;
    end if;

    /* update all of the rows in the staging table where
       there audit date is within the escalated date range
       but don't update the row for the existing backlog
       as we have created a new row for this.
    */
    update biv_dbi_collection_stg
    set  escalated_date = case when ( trunc(audit_date) < trunc(e.escalated_date_to) ) then e.escalated_date_from
                               else escalated_date
                               end
    , ever_escalated = 'Y'
    , last_update_date = sysdate
    , last_updated_by = g_user_id
    , last_update_login = g_login_id
    where
        incident_id = e.incident_id
    and trunc(audit_date) >= trunc(e.escalated_date_from)
    and backlog_rowid is null;
  end loop;

BEGIN

fnd_stats.gather_table_stats(ownname => 'BIV',
			 tabname => 'BIV_DBI_ESCALATIONS_STG', PERCENT => 10);

END;

  x_rowcount := l_rowcount;
  return 0;

exception
  when others then
    x_error_message := sqlerrm;
    return -1;

end apply_escalations;

function process_incremental
( p_log_rowid         in rowid
, p_collect_from_date in date
, p_collect_to_date   in date
, p_staging_flag      in varchar2
, p_activity_flag     in varchar2
, p_closed_flag       in varchar2
, p_backlog_flag      in varchar2
, p_resolution_flag   in varchar2
, x_rowcount          out nocopy number
, x_error_message     out nocopy varchar2
)
return number as

  l_exception exception;
  l_error_message varchar2(4000);
  l_biv_schema varchar2(100);

  l_phase number;

  l_timer number;
  l_total_rowcount number := 0;
  l_rowcount number;
  l_temp_rowcount number;

  type t_rowid_tab is table of rowid;
  type t_date_tab is table of date;
  l_backlog_rowid_tab t_rowid_tab;
  l_backlog_date_to_tab t_date_tab;
  l_backlog_collected_to_tab t_date_tab;

  type t_number_tab is table of number;

  l_from_party_tab t_number_tab;
  l_to_party_tab   t_number_tab;

  l_missing_owner_group_id    number := biv_dbi_collection_util.get_missing_owner_group_id;
  l_missing_inventory_item_id number := biv_dbi_collection_util.get_missing_inventory_item_id;
  l_missing_organization_id   number := biv_dbi_collection_util.get_missing_organization_id;

  l_max_date date := to_date('4712/12/31','yyyy/mm/dd');

begin

  if p_staging_flag = 'N' then

    l_phase := 1;
    l_timer := dbms_utility.get_time;
    l_rowcount := 0;

    if biv_dbi_collection_util.get_schema_name(l_biv_schema, l_error_message) <> 0 then
      raise l_exception;
    end if;

    bis_collection_utilities.log('Truncating table staging table');

    if biv_dbi_collection_util.truncate_table
       (l_biv_schema, 'BIV_DBI_COLLECTION_STG', l_error_message) <> 0 then
      raise l_exception;
    end if;

    bis_collection_utilities.log('Populating staging table');

    /* this is a temporary workaround to bad audit data cause by:
       - bug 3050727 - fixed
    */

    if biv_dbi_collection_util.correct_bad_audit(l_error_message) <> 0 then
      raise l_exception;
    end if;

    bis_collection_utilities.log('insert rows for previous backlog into staging table',1);
    /*
      insert rows for previous backlog into staging table
      insert current audit activity rows into staging table
      apply values from the incidents table to staging table
    */

    bis_collection_utilities.log('insert current audit activity rows into staging table',1);

    bis_collection_utilities.log('apply values from the incidents table to staging table',1);


insert into biv_dbi_collection_stg
(incident_id
    , audit_date
    , incident_audit_id
    , incident_type_id
    , inventory_item_id
    , inv_organization_id
    , incident_severity_id
    , incident_status_id
    , owner_group_id
    , status_flag
    , old_status_flag
    , unowned_date
    , resolved_flag
    , incident_resolved_date
    , resolved_event_flag
    , unresolved_event_flag
    , escalated_date
    , backlog_rowid
    , first_opened_flag
    , reopened_flag
    , reopened_date
    , closed_flag
    , closed_date
    , last_for_day_flag
    , party_merge_flag
    , old_customer_id
    , creation_date
    , created_by
    , last_update_date
    , last_updated_by
    , last_update_login
    , incident_urgency_id
    , incident_owner_id
    , ever_escalated
    , incident_date
    , customer_id
    , sr_creation_channel
    , resolution_code
)
select
      f.incident_id
    , f.backlog_date_from
    , 1
    , f.incident_type_id
    , f.inventory_item_id
    , f.inv_organization_id
    , f.incident_severity_id
    , f.incident_status_id
    , f.owner_group_id
    , 'O'
    , 'O'
    , f.unowned_date
    , f.resolved_flag
    , f.incident_resolved_date
    , 'N'
    , 'N'
    , f.escalated_date
    , f.rowid
    , null
    , null
    , null
    , null
    , null
    , 'Y'
    , null
    , null
    , sysdate
    , g_user_id
    , sysdate
    , g_user_id
    , g_login_id
    , f.incident_urgency_id
    , f.incident_owner_id
    , f.escalated_flag
    ,i.incident_date
              , nvl(i.customer_id,-1) /* functionally should not be possible */
    , nvl(i.sr_creation_channel,'-1') /* functionally should not be possible */
              , nvl(i.resolution_code,'-1') /* valid, resolution code not specified*/
    from
      biv_dbi_backlog_sum_f f, cs_incidents_all_b i
    where
        backlog_date_to = l_max_date
        and i.incident_id = f.incident_id

union all

select
      a.incident_id
    , a.creation_date audit_date
    , a.incident_audit_id
    , nvl(a.incident_type_id,-1) incident_type_id /* workaround bad data */
    , nvl2( a.inventory_item_id+a.inv_organization_id
          , a.inventory_item_id
          , l_missing_inventory_item_id ) inventory_item_id
    , nvl2( a.inventory_item_id+a.inv_organization_id
          , a.inv_organization_id
          , l_missing_organization_id )inv_organization_id
    , nvl(a.incident_severity_id,-1) incident_severity_id /* workaround bad data */
    , nvl(a.incident_status_id,-1) incident_status_id /* workaround bad data */
    , decode(a.group_type, 'RS_GROUP', nvl(a.group_id,l_missing_owner_group_id)
                       , l_missing_owner_group_id) owner_group_id
    , a.status_flag
    , a.old_status_flag
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
    , case when (a.incident_resolved_date is not null and
                 a.incident_resolved_date <= a.creation_date) then  'Y'
           -- when a.status_flag = 'C' then 'Y'
           else  'N'
      end resolved_flag
    , case when (a.incident_resolved_date is not null and
                 a.incident_resolved_date <= a.creation_date) then a.incident_resolved_date
           -- when a.status_flag = 'C' then  nvl(a.close_date,a.creation_date)
           else null
      end incident_resolved_date
    ,  case
        when nvl(a.old_incident_resolved_date,  a.incident_resolved_date+1) <> a.incident_resolved_date
                 and  a.incident_resolved_date is not null then
          'Y'
        else
         'N'
        end    resolved_event_flag
    ,  case
        when a.old_incident_resolved_date <> NVL(a.incident_resolved_date,a.old_incident_resolved_date+1)
              and  a.incident_resolved_date is null then
          'Y'
        else
         'N'
        end    unresolved_event_flag
    , null
    , null
    , case
        when a.change_incident_type_flag = 'Y' and a.old_incident_type_id is null then
          'Y'
        else
         'N'
       end first_opened_flag
    , case
        when a.change_status_flag = 'Y' and a.old_status_flag = 'C' and a.status_flag = 'O' then
          'Y'
        else
         'N'
        end reopened_flag
    , case
        when a.change_status_flag = 'Y' and a.old_status_flag = 'C' and a.status_flag = 'O' then
          a.creation_date
        else
          null
        end reopened_date
    , case
        when a.change_status_flag = 'Y' and a.status_flag = 'C' then
          'Y'
        else
          'N'
        end closed_flag
    , case
        when a.change_status_flag = 'Y' and a.status_flag = 'C' then
          nvl(a.close_date,a.creation_date)
        else
          null
        end closed_date
    , decode( a.incident_audit_id
            , last_value(a.incident_audit_id)
              over ( partition by a.incident_id, trunc(a.creation_date)
                     -- modified order by based on conclusions found in bug 3524935
                     order by decode(a.old_status_flag,null,1,2)
                            , a.creation_date
                            , a.incident_audit_id
                     rows between unbounded preceding and unbounded following )
            , 'Y'
            , 'N' ) last_for_day_flag
    , case
        when a.old_customer_id is not null and
             a.customer_id is not null and
             a.old_customer_id <> a.customer_id then
          'Y'
        else
          'N'
      end party_merge_flag
    , a.old_customer_id
    , sysdate
    , g_user_id
    , sysdate
    , g_user_id
    , g_login_id
    , nvl(a.incident_urgency_id,-1) incident_urgency_id /* workaround bad data */
    , decode(a.resource_type, 'RS_EMPLOYEE', nvl(a.incident_owner_id,-1) , -1) incident_owner_id
    , 'N'
    ,i.incident_date
              , nvl(i.customer_id,-1) /* functionally should not be possible */
    , nvl(i.sr_creation_channel,'-1') /* functionally should not be possible */
              , nvl(i.resolution_code,'-1') /* valid, resolution code not specified*/
    from
      cs_incidents_audit_b a , cs_incidents_all_b i
    where
        a.creation_date between p_collect_from_date and p_collect_to_date
        and i.incident_id = a.incident_id
    and nvl(a.updated_entity_code, 'SR_HEADER') IN ('SR_HEADER','SR_ESCALATION')
    and ('Y' in ( a.change_status_flag
               , a.change_incident_status_flag
               , a.change_incident_type_flag
               , a.change_incident_severity_flag
               , a.change_inventory_item_flag
               , a.change_inv_organization_flag
               , a.change_incident_owner_flag
               , a.change_incident_urgency_flag
               , a.change_group_flag
               , case
                   when a.old_customer_id is not null and
                        a.customer_id is not null and
                        a.old_customer_id <> a.customer_id then
                     'Y'
                   else
                     'N'
                   end
--Start bug#4932634
               ) or NVL(a.old_incident_resolved_date,trunc(sysdate)) <> a.incident_resolved_date );
--End bug#4932634

    l_rowcount := sql%rowcount;

    bis_collection_utilities.log('Inserted ' || l_rowcount || ' rows',2);

    commit;


    /*
      apply_escalations
    */
    if apply_escalations( p_collect_from_date
                        , p_collect_to_date
                        , l_temp_rowcount
                        , l_error_message
                        ) <> 0 then
      raise l_exception;
    end if;

    bis_collection_utilities.log('Inserted ' || l_temp_rowcount || ' rows',2);

    l_rowcount := l_rowcount + l_temp_rowcount;

    commit;

    bis_collection_utilities.log('hide ''duplicate'' rows from backlog query',1);
    /*
      hide 'duplicate' rows from backlog query
    */
    update biv_dbi_collection_stg
    set status_flag = lower(status_flag)
    where rowid in ( select rowid
                     from
                       ( select
                           incident_id || '^' ||
                           incident_type_id || '^' ||
                           inventory_item_id || '^' ||
                           inv_organization_id || '^' ||
                           incident_severity_id || '^' ||
                           incident_status_id || '^' ||
                           owner_group_id || '^' ||
                           unowned_date || '^' ||
                           resolved_flag || '^' ||
                           incident_resolved_date || '^'||
                           resolved_event_flag || '^'||
                           unresolved_event_flag || '^'||
                           escalated_date || '^'||
                           incident_urgency_id || '^'||
                           incident_owner_id || '^'||
                           ever_escalated as conc_key
                         , lag(incident_id || '^' ||
                               incident_type_id || '^' ||
                               inventory_item_id || '^' ||
                               inv_organization_id || '^' ||
                               incident_severity_id || '^' ||
                               incident_status_id || '^' ||
                               owner_group_id || '^' ||
                               unowned_date || '^' ||
                               resolved_flag || '^' ||
                               incident_resolved_date || '^'||
                               resolved_event_flag || '^'||
                               unresolved_event_flag || '^'||
                               escalated_date || '^'||
                               incident_urgency_id|| '^'||
                               incident_owner_id || '^'||
                               ever_escalated
                              ,1,'^')
                               over (order by
                                       incident_id
                                     , audit_date
                                     , incident_audit_id) prev_conc_key
                         from
                           biv_dbi_collection_stg s
                         where
                             last_for_day_flag = 'Y'
                        )
                     where conc_key = prev_conc_key
                   );

    l_temp_rowcount := sql%rowcount;

    bis_collection_utilities.log('Updated ' || l_temp_rowcount || ' rows',2);

    commit;

    bis_collection_utilities.log('Gathering Statistics for staging table');

    if biv_dbi_collection_util.gather_statistics
       (l_biv_schema, 'BIV_DBI_COLLECTION_STG', l_error_message) <> 0 then
      raise l_exception;
    end if;

    update biv_dbi_collection_log
    set staging_table_flag = 'Y'
      , staging_table_count = l_rowcount
      , staging_table_time = dbms_utility.get_time - l_timer
      , staging_error_message = null
      , last_update_date = sysdate
      , last_updated_by = g_user_id
      , last_update_login = g_login_id
    where rowid = p_log_rowid;

    commit;

    l_total_rowcount := l_total_rowcount + l_rowcount;

    bis_collection_utilities.log('Staging table complete');

  else

    bis_collection_utilities.log('Staging table already complete, skipping');

  end if;

  bis_collection_utilities.log('Checking for party merge');

  select distinct
    old_customer_id from_party
  , customer_id to_party
  bulk collect into l_from_party_tab
                  , l_to_party_tab
  from
    biv_dbi_collection_stg stg
  where
      party_merge_flag = 'Y';

  bis_collection_utilities.log('found ' || l_from_party_tab.count || ' distinct party merges', 1);

  if p_activity_flag = 'N' then

    l_phase := 2;
    l_timer := dbms_utility.get_time;
    l_rowcount := 0;

    bis_collection_utilities.log('Starting Activity Incremental Load');

    if l_from_party_tab.count > 0 then

      forall i in 1..l_from_party_tab.count
        update biv_dbi_activity_sum_f
        set
          primary_flag = 'N'
        , customer_id = l_to_party_tab(i)
        , last_updated_by = g_user_id
        , last_update_date = sysdate
        where
            customer_id = l_from_party_tab(i);

      l_rowcount := sql%rowcount;

      bis_collection_utilities.log('Party Merge updated ' || l_rowcount || ' rows',1);

    end if;

    if p_collect_from_date <> trunc(p_collect_from_date) then

      bis_collection_utilities.log('Merge activity from ' ||
                                    fnd_date.date_to_displaydt(p_collect_from_date) ||
                                    ' to ' ||
                                    fnd_date.date_to_displaydt(least(p_collect_to_date
                                                                    ,trunc(p_collect_from_date)+(86399/86400)))
                                    ,1);

      merge
      into biv_dbi_activity_sum_f a
      using (
        select /*+ no_merge cardinality (stg,10) */
          trunc(audit_date) activity_date
        , incident_type_id
        , inventory_item_id
        , inv_organization_id
        , incident_severity_id
        , customer_id
        , owner_group_id
        , sr_creation_channel
        , sum(decode(first_opened_flag,'Y',1,0)) first_opened_count
        , sum(decode(reopened_flag,'Y',1,0)) reopened_count
        , sum(decode(closed_flag,'Y',1,0)) closed_count
        , sysdate update_date
        , g_user_id user_id
        , g_login_id login_id
        , incident_urgency_id
        , incident_owner_id
        , ever_escalated escalated_flag
        from
          biv_dbi_collection_stg stg
        where
            'Y' in ( first_opened_flag, reopened_flag, closed_flag )
        and audit_date <= trunc(p_collect_from_date)+(86399/86400)
        group by
          trunc(audit_date)
        , incident_type_id
        , inventory_item_id
        , inv_organization_id
        , incident_severity_id
        , customer_id
        , owner_group_id
        , sr_creation_channel
        , incident_urgency_id
        , incident_owner_id
        , ever_escalated
      ) m
      on ( a.activity_date = m.activity_date and
           a.incident_type_id = m.incident_type_id and
           a.inventory_item_id = m.inventory_item_id and
           a.inv_organization_id = m.inv_organization_id and
           a.incident_severity_id = m.incident_severity_id and
           a.customer_id = m.customer_id and
           a.owner_group_id = m.owner_group_id and
           a.sr_creation_channel = m.sr_creation_channel and
           a.primary_flag = 'Y'and
           a.incident_urgency_id = m.incident_urgency_id and
           a.incident_owner_id = m.incident_owner_id and
           a.escalated_flag    = m.escalated_flag
         )
      when matched then
        update
          set a.first_opened_count = a.first_opened_count + m.first_opened_count
            , a.reopened_count = a.reopened_count + m.reopened_count
            , a.closed_count = a.closed_count + m.closed_count
            , a.last_update_date = m.update_date
            , a.last_updated_by = m.user_id
            , a.last_update_login = m.login_id
      when not matched then
        insert
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
        values
        ( m.activity_date
        , m.incident_type_id
        , m.inventory_item_id
        , m.inv_organization_id
        , m.incident_severity_id
        , m.customer_id
        , m.owner_group_id
        , m.sr_creation_channel
        , 'Y'
        , m.first_opened_count
        , m.reopened_count
        , m.closed_count
        , m.update_date
        , m.user_id
        , m.update_date
        , m.user_id
        , m.login_id
        , m.incident_urgency_id
        , m.incident_owner_id
        , m.escalated_flag
        );

      l_temp_rowcount := sql%rowcount;

      l_rowcount := l_rowcount + l_temp_rowcount;

      bis_collection_utilities.log('Merged ' || l_temp_rowcount || ' rows',2);

    end if;

    if trunc(p_collect_to_date) >= trunc(p_collect_from_date) and
       trunc(p_collect_from_date-(1/86400))+1 <= p_collect_to_date then

      bis_collection_utilities.log('Insert activity from ' ||
                                    fnd_date.date_to_displaydt(trunc(p_collect_from_date-(1/86400))+1) ||
                                    ' to ' ||
                                    fnd_date.date_to_displaydt(p_collect_to_date)
                                    ,1);
      insert
      into biv_dbi_activity_sum_f a
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
      select
        trunc(audit_date) activity_date
      , incident_type_id
      , inventory_item_id
      , inv_organization_id
      , incident_severity_id
      , customer_id
      , owner_group_id
      , sr_creation_channel
      , 'Y'
      , sum(decode(first_opened_flag,'Y',1,0)) first_opened_count
      , sum(decode(reopened_flag,'Y',1,0)) reopened_count
      , sum(decode(closed_flag,'Y',1,0)) closed_count
      , sysdate
      , g_user_id
      , sysdate
      , g_user_id
      , g_login_id
      , incident_urgency_id
      , incident_owner_id
      , ever_escalated
      from
        biv_dbi_collection_stg stg
      where
          'Y' in ( first_opened_flag, reopened_flag, closed_flag )
      and audit_date >= trunc(p_collect_from_date-(1/86400))+1
      group by
        trunc(audit_date)
      , incident_type_id
      , inventory_item_id
      , inv_organization_id
      , incident_severity_id
      , customer_id
      , owner_group_id
      , sr_creation_channel
      , incident_urgency_id
      , incident_owner_id
      , ever_escalated;

      l_temp_rowcount := sql%rowcount;

      l_rowcount := l_rowcount + l_temp_rowcount;

      bis_collection_utilities.log('Inserted ' || l_temp_rowcount || ' rows',2);

    end if;

    update biv_dbi_collection_log
    set activity_flag = 'Y'
      , activity_count = l_rowcount
      , activity_time = dbms_utility.get_time - l_timer
      , activity_error_message = null
      , last_update_date = sysdate
      , last_updated_by = g_user_id
      , last_update_login = g_login_id
    where rowid = p_log_rowid;

    commit;

    l_total_rowcount := l_total_rowcount + l_rowcount;

    bis_collection_utilities.log('Activity incremental load complete');

  else

    bis_collection_utilities.log('Activity incremental load already complete, skipping');

  end if;

  if p_closed_flag = 'N' then

    l_phase := 3;
    l_timer := dbms_utility.get_time;
    l_rowcount := 0;

    bis_collection_utilities.log('Starting Closed Incremental Load');

    if l_from_party_tab.count > 0 then

      forall i in 1..l_from_party_tab.count
        update biv_dbi_closed_sum_f
        set
          customer_id = l_to_party_tab(i)
        , last_updated_by = g_user_id
        , last_update_date = sysdate
        where
            customer_id = l_from_party_tab(i);

      l_rowcount := sql%rowcount;

      bis_collection_utilities.log('Party Merge updated ' || l_rowcount || ' rows',1);

    end if;

    merge
    into biv_dbi_closed_sum_f c
    using (
      select /*+ cardinality (stg,10) */
        incident_id
      , max(closed_date)
            keep (dense_rank last order by audit_date, incident_audit_id) closed_date
      , max(reopened_date)
            keep (dense_rank last order by audit_date, incident_audit_id) reopened_date
      , max(incident_type_id)
            keep (dense_rank last order by audit_date, incident_audit_id) incident_type_id
      , max(inventory_item_id)
            keep (dense_rank last order by audit_date, incident_audit_id) inventory_item_id
      , max(inv_organization_id)
            keep (dense_rank last order by audit_date, incident_audit_id) inv_organization_id
      , max(incident_severity_id)
            keep (dense_rank last order by audit_date, incident_audit_id) incident_severity_id
      , max(customer_id)
            keep (dense_rank last order by audit_date, incident_audit_id) customer_id
      , max(owner_group_id)
            keep (dense_rank last order by audit_date, incident_audit_id) owner_group_id
      , max(sr_creation_channel)
            keep (dense_rank last order by audit_date, incident_audit_id) sr_creation_channel
      , max(resolution_code)
            keep (dense_rank last order by audit_date, incident_audit_id) resolution_code
      , max(closed_date - incident_date)
            keep (dense_rank last order by audit_date, incident_audit_id) time_to_close
      , sysdate update_date
      , g_user_id user_id
      , g_login_id login_id
      , max(incident_urgency_id)
            keep (dense_rank last order by audit_date, incident_audit_id) incident_urgency_id
      , max(incident_owner_id)
            keep (dense_rank last order by audit_date, incident_audit_id) incident_owner_id
      , max(ever_escalated)
            keep (dense_rank last order by audit_date, incident_audit_id) escalated_flag
      from
        biv_dbi_collection_stg stg
      where
	 ('Y' in (closed_flag) and (old_status_flag = 'O' or old_status_flag is null)
	 /* workaround for bad data where old_status_flag can be null.*/
	  or 'Y' in (reopened_flag))
	  /* to update those SR's that have been reopened so that they are not displayed in the report. */
      group by incident_id
    ) m
    on ( c.incident_id = m.incident_id )
    when matched then
      update
      set report_date = decode(m.reopened_date,null,trunc(m.closed_date),c.report_date)
        , reopened_date = m.reopened_date
        , incident_type_id = decode(m.reopened_date,null,m.incident_type_id,c.incident_type_id)
        , inventory_item_id = decode(m.reopened_date,null,m.inventory_item_id,c.inventory_item_id)
        , inv_organization_id = decode(m.reopened_date,null,m.inv_organization_id,c.inv_organization_id)
        , incident_severity_id = decode(m.reopened_date,null,m.incident_severity_id,c.incident_severity_id)
        , customer_id = decode(m.reopened_date,null,m.customer_id,c.customer_id)
        , owner_group_id = decode(m.reopened_date,null,m.owner_group_id,c.owner_group_id)
        , sr_creation_channel = decode(m.reopened_date,null,m.sr_creation_channel,c.sr_creation_channel)
        , resolution_code = decode(m.reopened_date,null,m.resolution_code,c.resolution_code)
        , time_to_close = decode(m.reopened_date,null,m.time_to_close,c.time_to_close)
        , last_update_date = m.update_date
        , last_updated_by = m.user_id
        , last_update_login = m.login_id
        , incident_urgency_id = decode(m.reopened_date,null,m.incident_urgency_id,c.incident_urgency_id)
        , incident_owner_id = decode(m.reopened_date,null,m.incident_owner_id,c.incident_owner_id)
        , escalated_flag = decode(m.reopened_date,null,m.escalated_flag,c.escalated_flag)
    when not matched then
      insert
      ( report_date
      , incident_id
      , incident_type_id
      , inventory_item_id
      , inv_organization_id
      , incident_severity_id
      , customer_id
      , owner_group_id
      , sr_creation_channel
      , resolution_code
      , time_to_close
      , reopened_date
      , creation_date
      , created_by
      , last_update_date
      , last_updated_by
      , last_update_login
      , incident_urgency_id
      , incident_owner_id
      , escalated_flag
      )
      values
      ( trunc(nvl(m.closed_date,m.reopened_date))
      , m.incident_id
      , m.incident_type_id
      , m.inventory_item_id
      , m.inv_organization_id
      , m.incident_severity_id
      , m.customer_id
      , m.owner_group_id
      , m.sr_creation_channel
      , m.resolution_code
      , m.time_to_close
      , m.reopened_date
      , m.update_date
      , m.user_id
      , m.update_date
      , m.user_id
      , m.login_id
      , m.incident_urgency_id
      , m.incident_owner_id
      , m.escalated_flag
      );

    l_temp_rowcount := sql%rowcount;

    l_rowcount := l_rowcount + l_temp_rowcount;

    bis_collection_utilities.log('Merged ' || l_temp_rowcount || ' rows',1);

    update biv_dbi_collection_log
    set closed_flag = 'Y'
      , closed_count = l_rowcount
      , closed_time = dbms_utility.get_time - l_timer
      , closed_error_message = null
      , last_update_date = sysdate
      , last_updated_by = g_user_id
      , last_update_login = g_login_id
    where rowid = p_log_rowid;

    commit;

    l_total_rowcount := l_total_rowcount + l_rowcount;

    bis_collection_utilities.log('Closed incremental load complete');

  else

    bis_collection_utilities.log('Closed incremental load already complete, skipping');

  end if;

  if p_backlog_flag = 'N' then

    l_phase := 4;
    l_timer := dbms_utility.get_time;
    l_rowcount := 0;

    bis_collection_utilities.log('Starting Backlog Incremental Load');

    if l_from_party_tab.count > 0 then

      forall i in 1..l_from_party_tab.count
        update biv_dbi_backlog_sum_f
        set
          customer_id = l_to_party_tab(i)
        , last_updated_by = g_user_id
        , last_update_date = sysdate
        where
            customer_id = l_from_party_tab(i);

      l_rowcount := sql%rowcount;

      bis_collection_utilities.log('Party merge updated ' || l_rowcount || ' rows',1);

    end if;

    bis_collection_utilities.log('Updating existing backlog rows',1);

    /* identify all existing backlog rows and determine there new end dates
    */
    select
      backlog_rowid
    , backlog_date_to
    bulk collect into l_backlog_rowid_tab
                    , l_backlog_date_to_tab
    from
      ( select
          backlog_rowid
        , audit_date
        , lead(trunc(audit_date)-1,1,l_max_date)
                       over(partition by incident_id
                            order by audit_date, incident_audit_id) backlog_date_to
        from
          biv_dbi_collection_stg stg
        where
            status_flag in ('O', 'C')
        and last_for_day_flag = 'Y'
      )
    where
        backlog_rowid is not null;

    /* update all existing backlog rows with there new end dates
    */
    forall i in 1..l_backlog_rowid_tab.count
      update /*+ rowid(f) */ biv_dbi_backlog_sum_f f
      set backlog_date_to = l_backlog_date_to_tab(i)
        , last_update_date = sysdate
        , last_updated_by = g_user_id
        , last_update_login = g_login_id
      where
          rowid = l_backlog_rowid_tab(i)
      and backlog_date_to <> l_backlog_date_to_tab(i);

    l_temp_rowcount := sql%rowcount;

    l_rowcount := l_rowcount + l_temp_rowcount;

    bis_collection_utilities.log('Updated ' || l_temp_rowcount || ' rows',2);

    bis_collection_utilities.log('Inserting new backlog rows',1);

    /* insert new backlog rows
    */
    insert
    first
    when status_flag = 'O' and
         backlog_rowid is null then
      into biv_dbi_backlog_sum_f
      ( backlog_date_from
      , backlog_date_to
      , incident_id
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
      , creation_date
      , created_by
      , last_update_date
      , last_updated_by
      , last_update_login
      , escalated_flag
      , incident_urgency_id
      , incident_owner_id
      )
      values
      ( backlog_date_from
      , backlog_date_to
      , incident_id
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
      , last_update_date
      , last_updated_by
      , last_update_date
      , last_updated_by
      , last_update_login
      , escalated_flag
      , incident_urgency_id
      , incident_owner_id
      )
    select
      status_flag
    , backlog_rowid
    , trunc(audit_date) backlog_date_from
    , lead(trunc(audit_date)-1,1,l_max_date)
                   over(partition by incident_id
                        order by audit_date, incident_audit_id) backlog_date_to
    , incident_id
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
    , sysdate last_update_date
    , g_user_id last_updated_by
    , g_login_id last_update_login
--    , case when (escalated_date <= audit_date) then 'Y' else 'N' end escalated_flag
    , ever_escalated  escalated_flag
    , incident_urgency_id
    , incident_owner_id
    from
      biv_dbi_collection_stg stg
    where
        status_flag in ('O','C')
    and last_for_day_flag = 'Y';

    l_temp_rowcount := sql%rowcount;

    l_rowcount := l_rowcount + l_temp_rowcount;

    bis_collection_utilities.log('Inserted ' || l_temp_rowcount || ' rows',2);

    update biv_dbi_collection_log
    set backlog_flag = 'Y'
      , backlog_count = l_rowcount
      , backlog_time = dbms_utility.get_time - l_timer
      , backlog_error_message = null
      , last_update_date = sysdate
      , last_updated_by = g_user_id
      , last_update_login = g_login_id
    where rowid = p_log_rowid;

    commit;

    l_total_rowcount := l_total_rowcount + l_rowcount;

    bis_collection_utilities.log('Backlog incremental load complete');

  else

    bis_collection_utilities.log('Backlog incremental load already complete, skipping');
  end if;

  if p_resolution_flag = 'N' then

    l_phase := 5;
    l_timer := dbms_utility.get_time;
    l_rowcount := 0;

    bis_collection_utilities.log('Starting Resolution Incremental Load');

    if l_from_party_tab.count > 0 then

      forall i in 1..l_from_party_tab.count
        update biv_dbi_resolution_sum_f
        set
          customer_id = l_to_party_tab(i)
        , last_updated_by = g_user_id
        , last_update_date = sysdate
        where
            customer_id = l_from_party_tab(i);

      l_rowcount := sql%rowcount;

      bis_collection_utilities.log('Party Merge updated ' || l_rowcount || ' rows',1);

    end if;

    merge
   into biv_dbi_resolution_sum_f c
   using (
   select
   CASE WHEN incident_resolved_date is null or incident_resolved_date < incident_date
	THEN last_update_date
        ELSE incident_resolved_date
   END report_date,
   incident_id,
   incident_type_id,
   nvl2( inventory_item_id+inv_organization_id
          , inventory_item_id
          , l_missing_inventory_item_id ) inventory_item_id,
   nvl2( inventory_item_id+inv_organization_id
          , inv_organization_id
          , l_missing_organization_id )inv_organization_id,
   incident_severity_id,
   nvl(customer_id,-1) customer_id,
   decode(group_type, 'RS_GROUP', nvl(owner_group_id,l_missing_owner_group_id)
                         , l_missing_owner_group_id) owner_group_id,
   nvl(sr_creation_channel,'-1') sr_creation_channel,
   nvl(resolution_code,'-1') resolution_code,
   CASE WHEN (incident_resolved_date IS NOT NULL)
   THEN
      case when incident_resolved_date < incident_date then
                last_update_date
              else
                incident_resolved_date
      end
   ELSE
      NULL
   END  - incident_date time_to_resolution,
   sysdate last_update_date,
   g_user_id last_updated_by,
   g_login_id last_update_login,
   incident_urgency_id,
   decode(resource_type, 'RS_EMPLOYEE', nvl(incident_owner_id,-2)
                         , -2) incident_owner_id,
   escalated_flag,
   respond_on_date,
   respond_by_date,
   resolve_by_date,
   incident_date,
   contract_number
   FROM
    (
    select
    i.incident_id,
    CASE
      WHEN(i.incident_resolved_date = a.a_incident_resolved_date) THEN
         CASE WHEN(a.a_incident_resolved_date < i.incident_date) then i.incident_date
             --  WHEN(a.a_incident_resolved_date > i.close_date ) then i.close_date
               ELSE a.a_incident_resolved_date
         END
     /* From 8.0 SR's that are resolved only are taken into the resolution fact.
      WHEN (i.status_flag = 'C') THEN
            case
              when i.close_date is null or i.close_date < i.incident_date then
                i.last_update_date
              else
                i.close_date
            end */
      ELSE NULL
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
   /* From 8.0 SR's that are resolved only are taken into the resolution fact.
    CASE
      WHEN(i.incident_resolved_date = a.a_incident_resolved_date) THEN  a_group_type
      WHEN (i.status_flag = 'C') THEN   group_type
      ELSE NULL
    END*/ group_type,
    i.sr_creation_channel,
    CASE
      WHEN(i.incident_resolved_date = a.a_incident_resolved_date) THEN  a_resolution_code
      ELSE resolution_code
    END resolution_code,
    i.last_update_date,
    i.owner_group_id,
    i.incident_date,
    CASE
      WHEN(i.incident_resolved_date = a.a_incident_resolved_date) THEN  a_incident_urgency_id
     -- WHEN (i.status_flag = 'C') THEN   incident_urgency_id
      ELSE NULL
    END incident_urgency_id,
     i.resource_type,
    CASE
      WHEN(i.incident_resolved_date = a.a_incident_resolved_date) THEN  a_incident_owner_id
     -- WHEN (i.status_flag = 'C') THEN   incident_owner_id
      ELSE NULL
    END incident_owner_id,
    CASE
      WHEN(i.incident_resolved_date = a.a_incident_resolved_date) THEN  a_escalated_flag
      /* WHEN (i.status_flag = 'C') THEN
                CASE WHEN e.escalated_date_from <= i.close_date THEN 'Y' ELSE 'N' END */
      ELSE 'N'
    END escalated_flag,
    i.inc_responded_by_date respond_on_date,
    i.obligation_date respond_by_date,
    i.expected_resolution_date resolve_by_date,
    i.contract_number contract_number
    from
      (
      select /*+ cardinality(stg, 10) */
        incident_id a_incident_id
      , max(incident_resolved_date)
            keep (dense_rank last order by audit_date, incident_audit_id) a_incident_resolved_date
      , max(incident_type_id)
            keep (dense_rank last order by audit_date, incident_audit_id) a_incident_type_id
      , max(inventory_item_id)
            keep (dense_rank last order by audit_date, incident_audit_id) a_inventory_item_id
      , max(inv_organization_id)
            keep (dense_rank last order by audit_date, incident_audit_id) a_inv_organization_id
      , max(incident_severity_id)
            keep (dense_rank last order by audit_date, incident_audit_id) a_incident_severity_id
      , max(owner_group_id)
            keep (dense_rank last order by audit_date, incident_audit_id) a_owner_group_id
      , max(sr_creation_channel)
            keep (dense_rank last order by audit_date, incident_audit_id) a_sr_creation_channel
      , max(resolution_code)
            keep (dense_rank last order by audit_date, incident_audit_id) a_resolution_code
      , max(incident_urgency_id)
            keep (dense_rank last order by audit_date, incident_audit_id) a_incident_urgency_id
      , max(incident_owner_id)
            keep (dense_rank last order by audit_date, incident_audit_id) a_incident_owner_id
      , max(ever_escalated)
            keep (dense_rank last order by audit_date, incident_audit_id) a_escalated_flag
      from
        biv_dbi_collection_stg stg
        where ('Y' in (resolved_flag) and (old_status_flag = 'O' or old_status_flag is null)
	/* workaround for bad data where old_status_flag can be null.*/
	or 'Y' in (reopened_flag))
	/* to update those SR's that have been reopened so that they are not displayed in the report. */
      group by incident_id
     ) a, cs_incidents_all_b i,
         (
            select  trf.object_id, tsk.task_id, trunc(tsk.actual_start_date) escalated_date_from
            , trunc(nvl(tsk.actual_end_date,to_date('01-12-4712','DD-MM-YYYY'))) escalated_date_to
            , tsk.actual_start_date escalated_date
            , CASE WHEN trunc(tsk.actual_start_date) = trunc(nvl(tsk.actual_end_date,to_date('01-12-4712','DD-MM-YYYY')))
                   THEN
                      'Y'
                   ELSE
                      'N'
                   END  de_escalated_same_day
            from
              jtf_tasks_b tsk, jtf_task_references_b trf
              where trf.object_type_code = 'SR'
               and trf.reference_code = 'ESC'
               and tsk.task_type_id = 22
               and trf.task_id = tsk.task_id
              and NOT EXISTS
		(SELECT null
		 FROM jtf_task_references_b trf2
		 where trf2.reference_code = 'ESC'
		 and trf2.object_type_code = 'SR'
		 and trf2.object_id = trf.object_id
		 and trf2.task_id < trf.task_id)
          ) e
     where a.a_incident_id = i.incident_id
     and e.object_id(+) = i.incident_id
     )
    ) m
    on ( c.incident_id = m.incident_id )
    when matched then
      update
      set
          report_date = m.report_date
        , incident_type_id = m.incident_type_id
        , inventory_item_id = m.inventory_item_id
        , inv_organization_id = m.inv_organization_id
        , incident_severity_id = m.incident_severity_id
        , customer_id = m.customer_id
        , owner_group_id = m.owner_group_id
        , sr_creation_channel = sr_creation_channel
        , resolution_code = resolution_code
        , time_to_resolution = m.time_to_resolution
        , last_update_date = m.last_update_date
        , last_updated_by = m.last_updated_by
        , last_update_login = m.last_update_login
        , incident_urgency_id = m.incident_urgency_id
        , incident_owner_id = m.incident_owner_id
        , escalated_flag = m.escalated_flag
	, respond_on_date = m.respond_on_date
        , respond_by_date = m.respond_by_date
        , resolve_by_date= m.resolve_by_date
        , incident_date = m.incident_date
        , contract_number = m.contract_number
    when not matched then
      insert
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
       , creation_date
       , created_by
       , last_update_date
       , last_updated_by
       , last_update_login
       , incident_urgency_id
       , incident_owner_id
       , escalated_flag
       , respond_on_date
       , respond_by_date
       , resolve_by_date
       , incident_date
       , contract_number

      )
      values
      (
         m.report_date
       , m.incident_id
       , m.incident_type_id
       , m.inventory_item_id
       , m.inv_organization_id
       , m.incident_severity_id
       , m.customer_id
       , m.owner_group_id
       , m.sr_creation_channel
       , m.resolution_code
       , m.time_to_resolution
       , sysdate
       , m.last_updated_by
       , m.last_update_date
       , m.last_updated_by
       , m.last_update_login
       , m.incident_urgency_id
       , m.incident_owner_id
       , m.escalated_flag
       , m.respond_on_date
       , m.respond_by_date
       , m.resolve_by_date
       , m.incident_date
       , m.contract_number
      );

    l_temp_rowcount := sql%rowcount;

    l_rowcount := l_rowcount + l_temp_rowcount;

    bis_collection_utilities.log('Merged ' || l_temp_rowcount || ' rows',1);

    update biv_dbi_collection_log
    set resolution_flag = 'Y'
      , resolution_count = l_rowcount
      , resolution_time = dbms_utility.get_time - l_timer
      , resolution_error_message = null
      , last_update_date = sysdate
      , last_updated_by = g_user_id
      , last_update_login = g_login_id
    where rowid = p_log_rowid;

    commit;

    l_total_rowcount := l_total_rowcount + l_rowcount;

    bis_collection_utilities.log('Resolution incremental load complete');

  else

    bis_collection_utilities.log('Resolution incremental load already complete, skipping');

  end if;



  x_rowcount := l_total_rowcount;

  return 0;

exception
  when others then
    rollback;
    if l_error_message is null then
      l_error_message := substr(sqlerrm,1,4000);
    end if;
    x_error_message := l_error_message;
    if l_phase = 1 then
      biv_dbi_collection_util.set_log_error( p_rowid => p_log_rowid
                                           , p_staging_error => l_error_message
                                           );
    elsif l_phase = 2 then
      biv_dbi_collection_util.set_log_error( p_rowid => p_log_rowid
                                           , p_activity_error => l_error_message
                                           );
    elsif l_phase = 3 then
      biv_dbi_collection_util.set_log_error( p_rowid => p_log_rowid
                                           , p_closed_error => l_error_message
                                           );
    elsif l_phase = 4 then
      biv_dbi_collection_util.set_log_error( p_rowid => p_log_rowid
                                           , p_backlog_error => l_error_message
                                           );
    end if;

    commit;

    return -1;

end process_incremental;

procedure incremental_load
( errbuf in out nocopy varchar2
, retcode in out nocopy varchar2) as

  l_exception exception;
  l_error_message varchar2(4000);
  l_biv_schema varchar2(100);

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

  l_target_date date := sysdate;
  l_process_success number;
  l_rowcount number;

begin

  if not bis_collection_utilities.setup( 'BIV_DBI_COLLECTION' ) then
    raise g_bis_setup_exception;
  end if;

  biv_dbi_collection_util.get_last_log
  ( l_log_rowid
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

  if l_success_flag is null then
     l_error_message := 'Incremental Load can only be run after a completed initial or incremental load';
    raise l_exception;
  end if;

  if l_success_flag = 'N' and
     l_process_type <> g_process_type then
     l_error_message := 'Incremental Load cannot run as there is an incomplete initial load in progress';
    raise l_exception;
  end if;

  if l_success_flag = 'N' then

    bis_collection_utilities.log('Resuming previous incomplete Incremental Load');
    bis_collection_utilities.log('From ' || fnd_date.date_to_displaydt(l_collect_from_date),1);
    bis_collection_utilities.log('To ' || fnd_date.date_to_displaydt(l_collect_to_date),1);

    l_process_success := process_incremental( l_log_rowid
                                            , l_collect_from_date
                                            , l_collect_to_date
                                            , l_staging_flag
                                            , l_activity_flag
                                            , l_closed_flag
                                            , l_backlog_flag
                                            , l_resolution_flag
                                            , l_rowcount
                                            , l_error_message
                                            );
    if l_process_success <> 0 then
      raise l_exception;
    end if;

    update biv_dbi_collection_log
    set success_flag = 'Y'
      , last_update_date = sysdate
      , last_updated_by = g_user_id
      , last_update_login = g_login_id
    where rowid = l_log_rowid;

    commit;

    bis_collection_utilities.wrapup( p_status => true
                                   , p_period_from => l_collect_from_date
                                   , p_period_to => l_collect_to_date
                                   , p_count => l_rowcount
                                   );

    if not bis_collection_utilities.setup( 'BIV_DBI_COLLECTION' ) then
      raise g_bis_setup_exception;
    end if;

  end if;

  update biv_dbi_collection_log
  set last_collection_flag = 'N'
    , last_update_date = sysdate
    , last_updated_by = g_user_id
    , last_update_login = g_login_id
  where rowid = l_log_rowid;

  l_collect_from_date := l_collect_to_date + (1/86400);
  l_collect_to_date := l_target_date;

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
  , 'N'
  , 'N'
  , 'N'
  , 'N'
  , 'N'
  , sysdate
  , g_user_id
  , sysdate
  , g_user_id
  , g_login_id
  )
  returning rowid into l_log_rowid;

  bis_collection_utilities.log('Starting new Initial Load');
  bis_collection_utilities.log('From ' || fnd_date.date_to_displaydt(l_collect_from_date),1);
  bis_collection_utilities.log('To ' || fnd_date.date_to_displaydt(l_collect_to_date),1);

  commit;

  l_process_success := process_incremental( l_log_rowid
                                          , l_collect_from_date
                                          , l_collect_to_date
                                          , 'N'
                                          , 'N'
                                          , 'N'
                                          , 'N'
                                          , 'N'
                                          , l_rowcount
                                          , l_error_message
                                          );
  if l_process_success <> 0 then
    raise l_exception;
  end if;

  update biv_dbi_collection_log
  set success_flag = 'Y'
    , last_update_date = sysdate
    , last_updated_by = g_user_id
    , last_update_login = g_login_id
  where rowid = l_log_rowid;

  commit;

  bis_collection_utilities.wrapup( p_status => true
                                 , p_period_from => l_collect_from_date
                                 , p_period_to => l_collect_to_date
                                 , p_count => l_rowcount
                                 );

  bis_collection_utilities.log('Incremental Load complete');

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
    bis_collection_utilities.wrapup( p_status => false
                                   , p_message => l_error_message
                                   , p_period_from => l_collect_from_date
                                   , p_period_to => l_collect_to_date
                                   );
    errbuf := l_error_message;
    retcode := '2';

end incremental_load;

procedure incremental_log
( errbuf in out nocopy varchar2
, retcode in out nocopy varchar2 ) as

begin

  -- this is a noop procedure.
  -- we need to register a concurrent program to run for incremental
  -- refresh for biv_dbi_collection_log.  this is because the
  -- "Data Last Updated" calculation for reports checks the
  -- completion date for the object.  without this, the completion
  -- date is always the initial load date.

  null;

end incremental_log;

end biv_dbi_collection_inc;

/
