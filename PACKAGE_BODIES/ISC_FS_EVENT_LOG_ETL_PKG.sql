--------------------------------------------------------
--  DDL for Package Body ISC_FS_EVENT_LOG_ETL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ISC_FS_EVENT_LOG_ETL_PKG" 
/* $Header: iscfsevntlogetlb.pls 120.1 2005/11/24 18:31:14 kreardon noship $ */
as

function check_dep_arr_task
( p_task_id in number
, p_task_audit_id in number
)
return varchar2
is
  cursor c_task is
    select
      'Y'
    from jtf_tasks_b t
    where
        t.task_id = p_task_id
    -- R12 dep/arr
    and t.task_type_id = 20;

  cursor c_task_audit is
    select
      'Y'
    from jtf_task_audits_b t
    where
        t.task_audit_id = p_task_audit_id
    -- R12 dep/arr
    and ( ( t.old_source_object_type_code = 'TASK' and t.old_task_type_id = 20 ) or
          ( t.new_source_object_type_code = 'TASK' and t.new_task_type_id = 20 )
        );

  l_interested varchar2(1);

begin

  l_interested := 'N';

  if p_task_audit_id is null then
    open c_task;
    fetch c_task into l_interested;
    close c_task;
  else
    open c_task_audit;
    fetch c_task_audit into l_interested;
    close c_task_audit;
  end if;

  return l_interested;

end check_dep_arr_task;

-- -------------------------------------------------------------------
-- PUBLIC PROCEDURES
-- -------------------------------------------------------------------

function check_events_enabled
return varchar2
is

  cursor c_check is
    select enabled
    from isc_fs_enable_events;

  l_enabled varchar2(1);

begin
  open c_check;
  fetch c_check into l_enabled;
  close c_check;
  return nvl(l_enabled,'N');
end check_events_enabled;

function enable_events
( x_error_message out nocopy varchar2 )
return number
is
begin

  update isc_fs_enable_events
  set enabled = 'Y'
  , last_updated_by = fnd_global.user_id
  , last_update_date = sysdate
  , last_update_login = fnd_global.login_id
  , program_id = fnd_global.conc_program_id
  , program_login_id = fnd_global.conc_login_id
  , program_application_id = fnd_global.prog_appl_id
  , request_id = fnd_global.conc_request_id;

  if sql%rowcount = 0 then

    insert into
    isc_fs_enable_events
    ( enabled
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
    ( 'Y'
    , fnd_global.user_id
    , sysdate
    , fnd_global.user_id
    , sysdate
    , fnd_global.login_id
    , fnd_global.conc_program_id
    , fnd_global.conc_login_id
    , fnd_global.prog_appl_id
    , fnd_global.conc_request_id
    );

  end if;

  -- note: the procedure does not perform the commit

  return 0;

exception
  when others then
    x_error_message := 'Error in function enable_events : ' || sqlerrm;
    return -1;
end enable_events;

function log_task
( p_subscription_guid          in     raw
, p_event                      in out nocopy wf_event_t
)
return varchar2
is
  l_send_date               constant date := p_event.send_date;
  l_event_name              constant varchar2(240) := p_event.event_name;
  l_task_id                 constant number := p_event.GetValueForParameter('TASK_ID');
  l_task_audit_id           constant number := p_event.GetValueForParameter('TASK_AUDIT_ID');

  l_source_object_type_code varchar2(60);
  l_source_object_id        number;
  l_interested              varchar2(1);

begin

  savepoint log_task;

  if check_events_enabled <> 'Y' then

    wf_event.addparametertolist
    ( p_name            => 'X_RETURN_STATUS'
    , p_value           => 'SUCCESS'
    , p_parameterlist   => p_event.parameter_list
    );

    return 'SUCCESS';

  end if;

  l_source_object_type_code := p_event.GetValueForParameter('SOURCE_OBJECT_TYPE_CODE');
  l_source_object_id := p_event.GetValueForParameter('SOURCE_OBJECT_ID');

  if l_source_object_type_code = 'SR' or
     l_source_object_type_code = 'TASK' then

    if l_source_object_type_code = 'SR' then
      l_interested := 'Y';
    else
      l_interested := check_dep_arr_task
                      ( l_task_id
                      , l_task_audit_id
                      );
    end if;

    if l_interested = 'Y' then
      insert into isc_fs_events
      ( send_date
      , event_name
      , source_object_type_code
      , source_object_id
      , task_id
      , task_audit_id
      , created_by
      , creation_date
      , last_updated_by
      , last_update_date
      , last_update_login
      )
      values
      ( l_send_date
      , l_event_name
      , l_source_object_type_code
      , l_source_object_id
      , l_task_id
      , l_task_audit_id
      , fnd_global.user_id
      , sysdate
      , fnd_global.user_id
      , sysdate
      , fnd_global.login_id
      );
    end if;

  end if;

  wf_event.addparametertolist
  ( p_name            => 'X_RETURN_STATUS'
  , p_value           => 'SUCCESS'
  , p_parameterlist   => p_event.parameter_list
  );

  return 'SUCCESS';

exception
  when others then
    rollback to savepoint log_task;
    fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
    fnd_message.set_token ('P_TEXT','isc_fs_event_log_pkg.log_task: '||SQLERRM );
    fnd_msg_pub.ADD;
    wf_event.addparametertolist
    ( p_name            => 'X_RETURN_STATUS'
    , p_value           => 'ERROR'
    , p_parameterlist   => p_event.parameter_list
    );
    return 'ERROR';

end log_task;

function log_task_assignment
( p_subscription_guid          in     raw
, p_event                      in out nocopy wf_event_t
)
return varchar2
is
  cursor c_task( b_task_id number ) is
    select
      source_object_type_code
    , source_object_id
    from
      jtf_tasks_b
    where task_id = b_task_id
    and ( source_object_type_code = 'SR' or
          ( source_object_type_code = 'TASK' and
            -- R12 dep/arr
            task_type_id = 20
          )
        );

  l_send_date               constant date := p_event.send_date;
  l_event_name              constant varchar2(240) := p_event.event_name;
  l_task_id                 constant number := p_event.GetValueForParameter('TASK_ID');
  l_task_assignment_id      constant number := p_event.GetValueForParameter('TASK_ASSIGNMENT_ID');
  l_assignee_role           constant varchar2(30) := p_event.GetValueForParameter('ASSIGNEE_ROLE');

  l_source_object_type_code varchar2(60);
  l_source_object_id        number;

begin

  savepoint log_task_assignment;

  if check_events_enabled <> 'Y' then

    wf_event.addparametertolist
    ( p_name            => 'X_RETURN_STATUS'
    , p_value           => 'SUCCESS'
    , p_parameterlist   => p_event.parameter_list
    );

    return 'SUCCESS';

  end if;

  if l_assignee_role = 'ASSIGNEE' then

    open c_task( l_task_id );
    fetch c_task into l_source_object_type_code, l_source_object_id;
    if c_task%found then

      insert into isc_fs_events
      ( send_date
      , event_name
      , source_object_type_code
      , source_object_id
      , task_id
      , task_assignment_id
      , created_by
      , creation_date
      , last_updated_by
      , last_update_date
      , last_update_login
      )
      values
      ( l_send_date
      , l_event_name
      , l_source_object_type_code
      , l_source_object_id
      , l_task_id
      , l_task_assignment_id
      , fnd_global.user_id
      , sysdate
      , fnd_global.user_id
      , sysdate
      , fnd_global.login_id
      );

    end if;
    close c_task;

  end if;

  wf_event.addparametertolist
  ( p_name            => 'X_RETURN_STATUS'
  , p_value           => 'SUCCESS'
  , p_parameterlist   => p_event.parameter_list
  );

  return 'SUCCESS';

exception
  when others then
    rollback to savepoint log_task_assignment;
    if c_task%isopen then
      close c_task;
    end if;
    fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
    fnd_message.set_token ('P_TEXT','isc_fs_event_log_pkg.log_task_assignment: '||SQLERRM );
    fnd_msg_pub.ADD;
    wf_event.addparametertolist
    ( p_name            => 'X_RETURN_STATUS'
    , p_value           => 'ERROR'
    , p_parameterlist   => p_event.parameter_list
    );
    return 'ERROR';

end log_task_assignment;

function log_sr
( p_subscription_guid          in     raw
, p_event                      in out nocopy wf_event_t
)
return varchar2
is

  cursor c_task( b_incident_number varchar2 ) is
    select
      i.incident_id
    from
      jtf_tasks_b t
    , cs_incidents_all_b i
    where
        t.source_object_type_code = 'SR'
    and t.source_object_id = i.incident_id
    and i.incident_number = b_incident_number;

  l_send_date               constant date := p_event.send_date;
  l_event_name              constant varchar2(240) := p_event.event_name;
  l_incident_number         constant varchar2(80) := p_event.GetValueForParameter('REQUEST_NUMBER');
  l_incident_id             number;

begin

  savepoint log_sr;

  if check_events_enabled <> 'Y' then

    wf_event.addparametertolist
    ( p_name            => 'X_RETURN_STATUS'
    , p_value           => 'SUCCESS'
    , p_parameterlist   => p_event.parameter_list
    );

    return 'SUCCESS';

  end if;

  open c_task( l_incident_number );
  fetch c_task into l_incident_id;
  if c_task%found is not null then

    insert into isc_fs_events
    ( send_date
    , event_name
    , source_object_type_code
    , source_object_id
    , task_id
    , created_by
    , creation_date
    , last_updated_by
    , last_update_date
    , last_update_login
    )
    select
      l_send_date
    , l_event_name
    , t.source_object_type_code
    , t.source_object_id
    , t.task_id
    , fnd_global.user_id
    , sysdate
    , fnd_global.user_id
    , sysdate
    , fnd_global.login_id
    from
      cs_incidents_audit_b a
    , jtf_tasks_b t
    where
        a.incident_id = l_incident_id
    and a.creation_date >= l_send_date - (5/1440) -- include audits from 5 minutes before event sent date
    and 'Y' in ( a.change_inventory_item_flag
               , a.change_inv_organization_flag
               )
    and a.entity_activity_code = 'U'
    and a.updated_entity_code = 'SR_HEADER'
    and t.source_object_type_code = 'SR'
    and t.source_object_id = a.incident_id;

  end if;
  close c_task;

  wf_event.addparametertolist
  ( p_name            => 'X_RETURN_STATUS'
  , p_value           => 'SUCCESS'
  , p_parameterlist   => p_event.parameter_list
  );

  return 'SUCCESS';

exception
  when others then
    rollback to savepoint log_sr;
    if c_task%isopen then
      close c_task;
    end if;
    fnd_message.set_name ('CS', 'CS_API_SR_UNKNOWN_ERROR');
    fnd_message.set_token ('P_TEXT','isc_fs_event_log_pkg.log_sr: '||SQLERRM );
    fnd_msg_pub.ADD;
    wf_event.addparametertolist
    ( p_name            => 'X_RETURN_STATUS'
    , p_value           => 'ERROR'
    , p_parameterlist   => p_event.parameter_list
    );
    return 'ERROR';

end log_sr;

end isc_fs_event_log_etl_pkg;

/
