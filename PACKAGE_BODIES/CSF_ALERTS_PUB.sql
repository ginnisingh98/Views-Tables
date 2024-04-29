--------------------------------------------------------
--  DDL for Package Body CSF_ALERTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_ALERTS_PUB" AS
/*$Header: csfAlertb.pls 120.5.12010000.2 2009/01/13 07:25:12 htank ship $*/

-- This function will do basic filteration as per the bussiness conditions
-- also based on the event type it will call another function
-- Main entry point for the CSF wireless alerts
-- What to check?
-- 1. Assignment should have task attached to it with Schedule Start/End date
-- 2. Schedule start date should be greater than sysdate
-- 3. Task should be a type of 'Dispatch' and schedulable flag = 'Y' (only for FS tasks)
-- 4. Check for Task priority (check against profile value)
-- 5. Task assignment status should be of 'CSF: Default Assigned task status' profile value
--    at the application level

function checkForAlerts (p_subscription_guid in raw,
                         p_event in out nocopy WF_EVENT_T) return varchar2 is

  l_event_name varchar2(100);
  l_event_key varchar2(100);
  l_task_asgn_id number;
  l_task_id number;
  l_scheduled_start_date date;
  l_scheduled_end_date date;
  l_resource_id number;
  l_resource_type_code varchar2(20);
  -- l_shifts CSF_RESOURCE_PUB.shift_tbl_type;
  X_RETURN_STATUS VARCHAR2(200);
  X_MSG_COUNT NUMBER;
  X_MSG_DATA VARCHAR2(200);
  l_shift_start_date date;
  l_minutes_before number;
  l_send_date date;
  l_wf_parameter_list_t wf_parameter_list_t;
  l_wf_parameter_list_t_cp wf_parameter_list_t;
  l_wf_parameter_t wf_parameter_t;
  l_old_resource number;
  l_new_resource number;
  l_old_resource_type varchar2(100);
  l_new_resource_type varchar2(100);
  l_new_asgnmnt_status_id number;
  l_old_asgnmnt_status_id number;
  l_assigned_status_flag varchar2(10);
  l_task_audit_id number;
  l_task_sch_update_check varchar2(10);
  l_task_priority_update_check varchar2(10);
  l_priority_test varchar2(10);
  l_org_assignment_status_id number;

  cursor c_task_assgn_detail (v_task_assgn_id number) is
    SELECT distinct jtb.task_id,
        jtb.scheduled_start_date,
        jtb.scheduled_end_date,
        jta.resource_id,
        jta.resource_type_code,
        jta.assignment_status_id
    FROM jtf_tasks_b jtb,
      jtf_task_assignments jta,
      jtf_task_priorities_vl jp_vl,
      jtf_task_types_vl jtt_vl
    WHERE jta.task_assignment_id = v_task_assgn_id
      and jta.task_id = jtb.task_id
	  and jtb.source_object_type_code = 'SR'
      and nvl(jtb.scheduled_start_date, sysdate - 1) > sysdate
      and nvl(jtb.scheduled_end_date, sysdate - 1) > sysdate
      and jta.assignment_status_id in (
                                      select
                                        task_status_id
                                      from
                                        jtf_task_statuses_b
                                      where
                                        usage = 'TASK'
                                        and nvl(assigned_flag, 'N') = 'Y'
                                        and nvl(assignment_status_flag, 'N') = 'Y'
                                        and sysdate between nvl(start_date_active, sysdate)
                                        and nvl(end_date_active, sysdate + 1)
                                      )
      and jtb.task_type_id = jtt_vl.task_type_id
      and jtt_vl.task_type_id in (
                                  select
                                    task_type_id
                                  from
                                    JTF_TASK_TYPES_B
                                  where
                                    rule = 'DISPATCH'
                                  )  -- only dispatch tasks
      and nvl(jtt_vl.schedule_flag, 'N') = 'Y' -- schedulable tasks
      and sysdate between nvl(jtt_vl.start_date_active, sysdate)
      and nvl(jtt_vl.end_date_active, sysdate + 1)
      and jtb.task_priority_id = jp_vl.task_priority_id
      and sysdate between nvl(jp_vl.start_date_active, sysdate)
      and nvl(jp_vl.end_date_active, sysdate + 1)
      and jp_vl.importance_level <= fnd_profile.VALUE_SPECIFIC('CSF_ALERT_PRIORITY',
                                                              getUserId(jta.resource_id, jta.resource_type_code),
                                                              21685,
                                                              513,
                                                              null,
                                                              null);

  cursor c_task_assgn_detail_status (v_task_assgn_id number) is
    SELECT distinct jtb.task_id,
        jtb.scheduled_start_date,
        jtb.scheduled_end_date,
        jta.resource_id,
        jta.resource_type_code
    FROM jtf_tasks_b jtb,
      jtf_task_assignments jta,
      jtf_task_priorities_vl jp_vl,
      jtf_task_types_vl jtt_vl
    WHERE jta.task_assignment_id = v_task_assgn_id
      and jta.task_id = jtb.task_id
	  and jtb.source_object_type_code = 'SR'
      and nvl(jtb.scheduled_start_date, sysdate - 1) > sysdate
      and nvl(jtb.scheduled_end_date, sysdate - 1) > sysdate
      and jtb.task_type_id = jtt_vl.task_type_id
      and jtt_vl.task_type_id in (
                                  select
                                    task_type_id
                                  from
                                    JTF_TASK_TYPES_B
                                  where
                                    rule = 'DISPATCH'
                                  )  -- only dispatch tasks
      and jtt_vl.schedule_flag = 'Y' -- schedulable tasks
      and sysdate between nvl(jtt_vl.start_date_active, sysdate)
      and nvl(jtt_vl.end_date_active, sysdate + 1)
      and jtb.task_priority_id = jp_vl.task_priority_id
      and sysdate between nvl(jp_vl.start_date_active, sysdate)
      and nvl(jp_vl.end_date_active, sysdate + 1)
      and jp_vl.importance_level <= fnd_profile.VALUE_SPECIFIC('CSF_ALERT_PRIORITY',
                                                              getUserId(jta.resource_id, jta.resource_type_code),
                                                              21685,
                                                              513,
                                                              null,
                                                              null);

  cursor c_check_task_status_id (v_new_status_id number, v_old_status_id number) is
    select 'TRUE' from dual where v_old_status_id in (select
      task_status_id
    from
      jtf_task_statuses_b
    where
      usage = 'TASK'
      and nvl(assigned_flag, 'N') <> 'Y'
      and nvl(assignment_status_flag, 'N') = 'Y'
      and sysdate between nvl(start_date_active, sysdate)
      and nvl(end_date_active, sysdate + 1))
      and v_new_status_id in (select
      task_status_id
    from
      jtf_task_statuses_b
    where
      usage = 'TASK'
      and nvl(assigned_flag, 'N') = 'Y'
      and nvl(assignment_status_flag, 'N') = 'Y'
      and sysdate between nvl(start_date_active, sysdate)
      and nvl(end_date_active, sysdate + 1));

  cursor c_task_detail (v_task_id number, v_resource_id number, v_resource_type_code varchar2) is
    SELECT jtb.scheduled_start_date,
        jtb.scheduled_end_date
    FROM jtf_tasks_b jtb,
      jtf_task_priorities_vl jp_vl,
      jtf_task_types_vl jtt_vl
    WHERE jtb.task_id = v_task_id
      and nvl(jtb.scheduled_start_date, sysdate - 1) > sysdate
	  and jtb.source_object_type_code = 'SR'
      and jtb.task_type_id = jtt_vl.task_type_id
      and jtt_vl.task_type_id in (
                                  select
                                    task_type_id
                                  from
                                    JTF_TASK_TYPES_B
                                  where
                                    rule = 'DISPATCH'
                                  )  -- only dispatch tasks
      and jtt_vl.schedule_flag = 'Y' -- schedulable tasks
      and sysdate between nvl(jtt_vl.start_date_active, sysdate)
      and nvl(jtt_vl.end_date_active, sysdate + 1)
      and jtb.task_priority_id = jp_vl.task_priority_id
      and sysdate between nvl(jp_vl.start_date_active, sysdate)
      and nvl(jp_vl.end_date_active, sysdate + 1)
      and jp_vl.importance_level <= fnd_profile.VALUE_SPECIFIC('CSF_ALERT_PRIORITY',
                                                            getUserId(v_resource_id, v_resource_type_code),
                                                            21685,
                                                            513,
                                                            null,
                                                            null);
      -- should take from profile here it is Medium

      cursor c_task_update_check (v_task_id number, v_task_audit_id number) is
        select
        (select
          'TRUE'
        from
          jtf_task_audits_b jtab,
		  jtf_tasks_b jtb
        where
          jtb.task_id =  v_task_id
		  and jtb.source_object_type_code = 'SR'
		  and jtb.task_id = jtab.task_id
          and jtab.task_audit_id = v_task_audit_id
          and (jtab.new_scheduled_start_date <> jtab.old_scheduled_start_date
          or jtab.new_scheduled_end_date <> jtab.old_scheduled_end_date)) as is_schedule_dates,
          (select
          'TRUE'
        from
          jtf_task_audits_b jtab,
		  jtf_tasks_b jtb
        where
          jtb.task_id =  v_task_id
		  and jtb.source_object_type_code = 'SR'
		  and jtb.task_id = jtab.task_id
          and jtab.task_audit_id = v_task_audit_id
          and jtab.new_task_priority_id <> jtab.old_task_priority_id) as is_priority
          from dual;

      cursor c_get_all_assignments (v_task_id number) is
        select
          task_assignment_Id
        from
          jtf_task_assignments
        where task_id = v_task_id;

      cursor c_priority_test (v_task_id number,
                              v_task_audit_id number,
                              v_resource_id number,
                              v_resource_type varchar2) is
        select
          'TRUE'
        from
          jtf_task_priorities_vl jp_vl1,
          jtf_task_priorities_vl jp_vl2,
          jtf_task_audits_b jtab
        where
          jtab.task_id = v_task_id
          and jtab.task_audit_id = v_task_audit_id
          and jp_vl1.task_priority_id = jtab.new_task_priority_id
          and jp_vl1.importance_level <= fnd_profile.VALUE_SPECIFIC('CSF_ALERT_PRIORITY',
                                                                    getUserId(v_resource_id, v_resource_type),
                                                                    21685,
                                                                    513,
                                                                    null,
                                                                    null)
          and jp_vl2.task_priority_id = jtab.old_task_priority_id
          and jp_vl2.importance_level > fnd_profile.VALUE_SPECIFIC('CSF_ALERT_PRIORITY',
                                                                    getUserId(v_resource_id, v_resource_type),
                                                                    21685,
                                                                    513,
                                                                    null,
                                                                    null);
begin

  l_event_name := p_event.getEventName();
  l_task_asgn_id := p_event.GetValueForParameter('TASK_ASSIGNMENT_ID');
  l_wf_parameter_list_t := p_event.getParameterList();

  -- create task assignment event
  if (l_event_name = 'oracle.apps.jtf.cac.task.createTaskAssignment') then  -- event type create

    open c_task_assgn_detail(l_task_asgn_id);
    fetch c_task_assgn_detail into l_task_id,
                                    l_scheduled_start_date,
                                    l_scheduled_end_date,
                                    l_resource_id,
                                    l_resource_type_code,
                                    l_org_assignment_status_id;
    close c_task_assgn_detail;

    if l_task_id is null then
      return 'SUCCESS'; -- nothing to do now :)
    end if;

    -- calculate SendDate
    l_send_date := getSendDate(l_resource_id,
                                  l_resource_type_code,
                                  l_scheduled_start_date,
                                  l_scheduled_end_date);

    if checkAlertsEnabled(l_resource_id, l_resource_type_code) then

      l_wf_parameter_t := wf_parameter_t('CSF_EVENT_TYPE', 'CREATE');
      l_wf_parameter_list_t.EXTEND;
      l_wf_parameter_list_t(l_wf_parameter_list_t.count()) := l_wf_parameter_t;

      l_wf_parameter_t := wf_parameter_t('ORG_TASK_ASSGN_STS_ID', to_char(l_org_assignment_status_id));
      l_wf_parameter_list_t.EXTEND;
      l_wf_parameter_list_t(l_wf_parameter_list_t.count()) := l_wf_parameter_t;

      l_event_key := getItemKey('oracle.apps.csf.createTaskAssignment',
                                l_resource_id,
                                l_resource_type_code,
                                l_task_asgn_id,
                                p_event.getEventKey());

      wf_event.raise(p_event_name => 'oracle.apps.csf.alerts.sendNotification',
                p_event_key => l_event_key,
                p_parameters  => l_wf_parameter_list_t,
                p_send_date => l_send_date);

    end if;

  -- delete assignment event
  elsif (l_event_name = 'oracle.apps.jtf.cac.task.deleteTaskAssignment') then  -- event type delete

    l_task_id := p_event.GetValueForParameter('TASK_ID');
    l_resource_id := p_event.GetValueForParameter('RESOURCE_ID');
    l_resource_type_code := p_event.GetValueForParameter('RESOURCE_TYPE_CODE');

    open c_task_detail(l_task_id, l_resource_id, l_resource_type_code);
    fetch c_task_detail into l_scheduled_start_date, l_scheduled_end_date;
    close c_task_detail;

    if l_task_id is null then
      return 'SUCCESS'; -- nothing to do now :)
    end if;

    -- calculate SendDate
    l_send_date := getSendDate(l_resource_id,
                                l_resource_type_code,
                                l_scheduled_start_date,
                                l_scheduled_end_date);

    if checkAlertsEnabled(l_resource_id, l_resource_type_code) then

      l_wf_parameter_t := wf_parameter_t('CSF_EVENT_TYPE', 'DELETE');
      l_wf_parameter_list_t.EXTEND;
      l_wf_parameter_list_t(l_wf_parameter_list_t.count()) := l_wf_parameter_t;

      l_event_key := getItemKey('oracle.apps.csf.deleteTaskAssignment',
                            l_resource_id,
                            l_resource_type_code,
                            l_task_asgn_id,
                            p_event.getEventKey());

      wf_event.raise(p_event_name => 'oracle.apps.csf.alerts.sendNotification',
                p_event_key => l_event_key,
                p_parameters  => l_wf_parameter_list_t,
                p_send_date => l_send_date);

    end if;

  -- update assignee event
  elsif (l_event_name = 'oracle.apps.jtf.cac.task.updateTaskAssignment') then -- event type update assignment

    l_old_resource := p_event.GetValueForParameter('OLD_RESOURCE_ID');
    l_new_resource := p_event.GetValueForParameter('NEW_RESOURCE_ID');
    l_old_resource_type := p_event.GetValueForParameter('OLD_RESOURCE_TYPE_CODE');
    l_new_resource_type := p_event.GetValueForParameter('NEW_RESOURCE_TYPE_CODE');

    l_new_asgnmnt_status_id := p_event.GetValueForParameter('NEW_ASSIGNMENT_STATUS_ID');
    l_old_asgnmnt_status_id := p_event.GetValueForParameter('OLD_ASSIGNMENT_STATUS_ID');

    -- Assignee change case
    if l_old_resource is not null and l_new_resource is not null then -- resource change

      open c_task_assgn_detail(l_task_asgn_id);
      fetch c_task_assgn_detail into l_task_id,
                                  l_scheduled_start_date,
                                  l_scheduled_end_date,
                                  l_resource_id,
                                  l_resource_type_code,
                                  l_org_assignment_status_id;
      close c_task_assgn_detail;

      if l_task_id is null then
      return 'SUCCESS'; -- nothing to do now :)
      end if;

      -- calculate SendDate
      l_send_date := getSendDate(l_resource_id,
                                l_resource_type_code,
                                l_scheduled_start_date,
                                l_scheduled_end_date);

      -- create notification to new resource
      if checkAlertsEnabled(l_new_resource, l_new_resource_type) then -- alerts enables?

        l_wf_parameter_list_t_cp := l_wf_parameter_list_t;
        l_wf_parameter_t := wf_parameter_t('CSF_EVENT_TYPE', 'CREATE');
        l_wf_parameter_list_t.EXTEND;
        l_wf_parameter_list_t(l_wf_parameter_list_t.count()) := l_wf_parameter_t;

        l_wf_parameter_t := wf_parameter_t('ORG_TASK_ASSGN_STS_ID', to_char(l_org_assignment_status_id));
        l_wf_parameter_list_t.EXTEND;
        l_wf_parameter_list_t(l_wf_parameter_list_t.count()) := l_wf_parameter_t;


        l_event_key :=  getItemKey('oracle.apps.csf.createTaskAssignment',
                                l_new_resource,
                                l_new_resource_type,
                                l_task_asgn_id,
                                p_event.getEventKey());

        wf_event.raise(p_event_name => 'oracle.apps.csf.alerts.sendNotification',
                      p_event_key => l_event_key,
                      p_parameters  => l_wf_parameter_list_t,
                      p_send_date => l_send_date
                      );

      end if; -- alerts enabled?

      -- delete alert to old resource
      if checkAlertsEnabled(l_old_resource, l_old_resource_type) then   -- alerts enabled?

        l_wf_parameter_t := wf_parameter_t('CSF_EVENT_TYPE', 'DELETE_FOR_UPDATE');
        l_wf_parameter_list_t := l_wf_parameter_list_t_cp;
        l_wf_parameter_list_t.EXTEND;
        l_wf_parameter_list_t(l_wf_parameter_list_t.count()) := l_wf_parameter_t;

        l_event_key :=  getItemKey('oracle.apps.csf.deleteTaskAssignment',
                            l_old_resource,
                            l_old_resource_type,
                            l_task_asgn_id,
                            p_event.getEventKey());

        wf_event.raise(p_event_name => 'oracle.apps.csf.alerts.sendNotification',
                  p_event_key => l_event_key,
                  p_parameters  => l_wf_parameter_list_t,
                  p_send_date => l_send_date);

      end if; -- alerts enabled?

    -- Status change case
    elsif l_new_asgnmnt_status_id is not null and l_old_asgnmnt_status_id is not null then  -- assignment status change

      -- check for other conditions without status change
      open c_task_assgn_detail_status(l_task_asgn_id);
      fetch c_task_assgn_detail_status into l_task_id,
                                 l_scheduled_start_date,
                                 l_scheduled_end_date,
                                 l_resource_id,
                                 l_resource_type_code;
      close c_task_assgn_detail_status;

      if l_task_id is null then
         return 'SUCCESS'; -- nothing to do now :)
      end if;

      if l_new_asgnmnt_status_id = fnd_profile.VALUE_SPECIFIC('CSF_DEFAULT_TASK_CANCELLED_STATUS',
                                                              getUserId(l_resource_id, l_resource_type_code),
                                                              21685,
                                                              513,
                                                              null,
                                                              null)
      and checkAlertsEnabled(l_resource_id, l_resource_type_code)
      then  -- is it cancel status

        -- calculate SendDate
        l_send_date := getSendDate(l_resource_id,
                                  l_resource_type_code,
                                  l_scheduled_start_date,
                                  l_scheduled_end_date);

        -- delete case
        l_wf_parameter_t := wf_parameter_t('CSF_EVENT_TYPE', 'DELETE');
        l_wf_parameter_list_t.EXTEND;
        l_wf_parameter_list_t(l_wf_parameter_list_t.count()) := l_wf_parameter_t;

        l_event_key := getItemKey('oracle.apps.csf.deleteTaskAssignment',
                      l_resource_id,
                      l_resource_type_code,
                      l_task_asgn_id,
                      p_event.getEventKey());

        wf_event.raise(p_event_name => 'oracle.apps.csf.alerts.sendNotification',
                      p_event_key => l_event_key,
                      p_parameters  => l_wf_parameter_list_t,
                      p_send_date => l_send_date);

      else  -- not a cancel status

        -- calculate SendDate
        l_send_date := getSendDate(l_resource_id,
                                  l_resource_type_code,
                                  l_scheduled_start_date,
                                  l_scheduled_end_date);

        if checkAlertsEnabled(l_resource_id, l_resource_type_code) then -- alerts enabled
          -- check for status non-assigned to assigned
          l_assigned_status_flag := 'FALSE';

          open c_check_task_status_id(l_new_asgnmnt_status_id, l_old_asgnmnt_status_id);
          fetch c_check_task_status_id into l_assigned_status_flag;
          close c_check_task_status_id;

          if l_assigned_status_flag = 'TRUE' then -- new assignment
            -- status from non-assigned to assigned

            l_wf_parameter_t := wf_parameter_t('CSF_EVENT_TYPE', 'CREATE');
            l_wf_parameter_list_t.EXTEND;
            l_wf_parameter_list_t(l_wf_parameter_list_t.count()) := l_wf_parameter_t;

            l_wf_parameter_t := wf_parameter_t('ORG_TASK_ASSGN_STS_ID', to_char(l_new_asgnmnt_status_id));
            l_wf_parameter_list_t.EXTEND;
            l_wf_parameter_list_t(l_wf_parameter_list_t.count()) := l_wf_parameter_t;

            l_event_key := getItemKey('oracle.apps.csf.createTaskAssignment',
                            l_resource_id,
                            l_resource_type_code,
                            l_task_asgn_id,
                            p_event.getEventKey());

            wf_event.raise(p_event_name => 'oracle.apps.csf.alerts.sendNotification',
                            p_event_key => l_event_key,
                            p_parameters  => l_wf_parameter_list_t,
                            p_send_date => l_send_date
                            );

          end if; -- new assignemnt over

        end if; -- alerts enabled? over

      end if; -- not a cancel status over

    end if; -- status change over

  elsif (l_event_name = 'oracle.apps.jtf.cac.task.updateTask') then

    l_task_id := p_event.GetValueForParameter('TASK_ID');
    l_task_audit_id := p_event.GetValueForParameter('TASK_AUDIT_ID');

    open c_task_update_check (l_task_id, l_task_audit_id);
    fetch c_task_update_check into l_task_sch_update_check, l_task_priority_update_check;
    close c_task_update_check;

    if l_task_sch_update_check = 'TRUE' or l_task_priority_update_check = 'TRUE' then

      -- fetch all the task assignemnts and resources
      -- loop for each assignment and check other conditions
      open c_get_all_assignments(l_task_id);
      loop
        fetch c_get_all_assignments into l_task_asgn_id;
        exit when c_get_all_assignments%notfound;

        open c_task_assgn_detail(l_task_asgn_id);
        fetch c_task_assgn_detail into l_task_id,
                            l_scheduled_start_date,
                            l_scheduled_end_date,
                            l_resource_id,
                            l_resource_type_code,
                            l_org_assignment_status_id;
        close c_task_assgn_detail;

        if l_task_id is null then
        return 'SUCCESS'; -- nothing to do now :)
        end if;

        -- calculate SendDate
        l_send_date := getSendDate(l_resource_id,
                          l_resource_type_code,
                          l_scheduled_start_date,
                          l_scheduled_end_date);

        -- priority change
        if l_task_priority_update_check = 'TRUE' then

          -- check if new priority is higher than the profile and
          -- old priority should be less than

          open c_priority_test(l_task_id, l_task_audit_id, l_resource_id, l_resource_type_code);
          fetch c_priority_test into l_priority_test;
          close c_priority_test;

          if l_priority_test = 'TRUE'
            and checkAlertsEnabled(l_resource_id, l_resource_type_code) then  -- create assignment notification

            l_wf_parameter_t := wf_parameter_t('CSF_EVENT_TYPE', 'CREATE');
            l_wf_parameter_list_t.EXTEND;
            l_wf_parameter_list_t(l_wf_parameter_list_t.count()) := l_wf_parameter_t;

            l_wf_parameter_t := wf_parameter_t('TASK_ASSIGNMENT_ID', to_char(l_task_asgn_id));
            l_wf_parameter_list_t.EXTEND;
            l_wf_parameter_list_t(l_wf_parameter_list_t.count()) := l_wf_parameter_t;

            l_wf_parameter_t := wf_parameter_t('ORG_TASK_ASSGN_STS_ID', to_char(l_org_assignment_status_id));
            l_wf_parameter_list_t.EXTEND;
            l_wf_parameter_list_t(l_wf_parameter_list_t.count()) := l_wf_parameter_t;

            l_event_key := getItemKey('oracle.apps.csf.createTaskAssignment',
                                      l_resource_id,
                                      l_resource_type_code,
                                      l_task_asgn_id,
                                      p_event.getEventKey());

            wf_event.raise(p_event_name => 'oracle.apps.csf.alerts.sendNotification',
                            p_event_key => l_event_key,
                            p_parameters  => l_wf_parameter_list_t,
                            p_send_date => l_send_date
                            );

          end if; -- end of create assignment notification

        elsif l_task_sch_update_check = 'TRUE' then

          -- raise and sch_dates update alert
          if checkAlertsEnabled(l_resource_id, l_resource_type_code) then

            l_wf_parameter_t := wf_parameter_t('CSF_EVENT_TYPE', 'SCH_UPDATE');
            l_wf_parameter_list_t.EXTEND;
            l_wf_parameter_list_t(l_wf_parameter_list_t.count()) := l_wf_parameter_t;

            l_wf_parameter_t := wf_parameter_t('TASK_ASSIGNMENT_ID', to_char(l_task_asgn_id));
            l_wf_parameter_list_t.EXTEND;
            l_wf_parameter_list_t(l_wf_parameter_list_t.count()) := l_wf_parameter_t;

            l_event_key := getItemKey('oracle.apps.csf.updateScheduleDates',
                                      l_resource_id,
                                      l_resource_type_code,
                                      l_task_asgn_id,
                                      p_event.getEventKey());

            wf_event.raise(p_event_name => 'oracle.apps.csf.alerts.sendNotification',
                            p_event_key => l_event_key,
                            p_parameters  => l_wf_parameter_list_t,
                            p_send_date => l_send_date
                            );

          end if;

        end if; -- end of priority change

      end loop;
      close c_get_all_assignments;

    end if;

  end if; -- event type update assignment over

  return 'SUCCESS';

end;

function sendNotification (p_subscription_guid in raw,
                  p_event in out nocopy WF_EVENT_T) return varchar2 is

    l_msg_subject varchar(1000);
    l_msg_subject2 varchar(1000);

    l_task_asgn_record task_asgn_record;
    itemkey varchar2(150);
    l_task_asgn_id number;
    l_task_id number;
    l_task_audit_id number;
    l_cust_name varchar2(200);
    l_schedule_start_date varchar2(100);
    l_csfw_event_type varchar2(25);
    l_resource_id     number;
    l_resource_type   varchar2(150);
    l_resource        varchar2(150);
    l_time_out1 number;
    l_time_out2 number;
    itemtype varchar2(10);
    l_auto_reject varchar2(10);
    l_document_id varchar2(100);
    l_org_assignment_status_id number;
    l_curr_assignment_status_id number;

    cursor c_resource_from_task_asgn_id (v_task_asgn_id number) is
    select
      jr.resource_id,
      jt.resource_id,
      jt.resource_type_code,
      jt.assignment_status_id
    from
      jtf_task_assignments jt,
      jtf_rs_resource_extns jr
    where
      jt.task_assignment_id = v_task_asgn_id
      and jt.resource_id = jr.resource_id
      and category_type(jt.resource_type_code) = jr.category;
begin
   itemkey := p_event.getEventKey();
   l_task_asgn_id := p_event.GetValueForParameter('TASK_ASSIGNMENT_ID');
   l_task_id := p_event.GetValueForParameter('TASK_ID');
   l_task_audit_id := p_event.GetValueForParameter('TASK_AUDIT_ID');
   l_csfw_event_type := p_event.GetValueForParameter('CSF_EVENT_TYPE');
   l_org_assignment_status_id := p_event.GetValueForParameter('ORG_TASK_ASSGN_STS_ID');

   if l_csfw_event_type = 'CREATE' then

      l_csfw_event_type := 'CREATE_EVENT';

      open c_resource_from_task_asgn_id(l_task_asgn_id);
      fetch c_resource_from_task_asgn_id into l_resource,
                                              l_resource_id,
                                              l_resource_type,
                                              l_curr_assignment_status_id;
      close c_resource_from_task_asgn_id;

      -- check if task assignment status has changed from the time event was
      -- generated
      if l_org_assignment_status_id is not null
        and l_org_assignment_status_id <> l_curr_assignment_status_id then
          return 'SUCCESS';
      end if;

      l_resource := getWFRole(l_resource_id);

      l_task_asgn_record := getTaskDetails(null, l_task_asgn_id, null);

      l_cust_name := l_task_asgn_record.cust_name;
      l_schedule_start_date := to_char(getClientTime(l_task_asgn_record.sch_st_date,
                                            getUserId(l_resource_id, l_resource_type)), 'DD-MON-YYYY HH24:MI');

      fnd_message.set_name('CSF', 'CSF_ALERTS_ASSIGNED_SUB');
      fnd_message.set_token('CUST_NAME', l_cust_name);
      fnd_message.set_token('SCH_START_DT', l_schedule_start_date);

      l_msg_subject := fnd_message.get;

      fnd_message.set_name('CSF', 'CSF_ALERTS_REMINDER_SUB');
      fnd_message.set_token('CUST_NAME', l_cust_name);
      fnd_message.set_token('SCH_START_DT', l_schedule_start_date);

      l_msg_subject2 := fnd_message.get;

      l_document_id := to_char(l_resource_id) || '-' || l_resource_type || '-' || to_char(l_task_asgn_id);

   elsif l_csfw_event_type = 'DELETE' or l_csfw_event_type = 'DELETE_FOR_UPDATE' then

      if l_csfw_event_type = 'DELETE' then

        l_resource_id := p_event.GetValueForParameter('RESOURCE_ID');
        l_resource_type := p_event.GetValueForParameter('RESOURCE_TYPE_CODE');

      else

        l_resource_id := p_event.GetValueForParameter('OLD_RESOURCE_ID');
        l_resource_type := p_event.GetValueForParameter('OLD_RESOURCE_TYPE_CODE');

      end if;

      l_csfw_event_type := 'DELETE_EVENT';
      l_resource := getWFRole(l_resource_id);
      l_task_asgn_record := getTaskDetails(l_task_id, null, null);

      l_cust_name := l_task_asgn_record.cust_name;
      l_schedule_start_date := to_char(getClientTime(l_task_asgn_record.sch_st_date,
                                        getUserId(l_resource_id, l_resource_type)), 'DD-MON-YYYY HH24:MI');

      fnd_message.set_name('CSF', 'CSF_ALERTS_CANCEL_SUB');
      fnd_message.set_token('CUST_NAME', l_cust_name);
      fnd_message.set_token('SCH_START_DT', l_schedule_start_date);

      l_msg_subject := fnd_message.get;

      l_document_id := to_char(l_resource_id) || '-' || l_resource_type || '-' || to_char(l_task_id);

   elsif l_csfw_event_type = 'SCH_UPDATE'  then

      l_csfw_event_type := 'SCH_UPDATE_EVENT';

      open c_resource_from_task_asgn_id(l_task_asgn_id);
      fetch c_resource_from_task_asgn_id into l_resource,
                                              l_resource_id,
                                              l_resource_type,
                                              l_curr_assignment_status_id;
      close c_resource_from_task_asgn_id;

      l_resource := getWFRole(l_resource_id);

      l_task_asgn_record := getTaskDetails(null, l_task_asgn_id, null);
      l_cust_name := l_task_asgn_record.cust_name;
      l_schedule_start_date := to_char(getClientTime(l_task_asgn_record.sch_st_date,
                                        getUserId(l_resource_id, l_resource_type)), 'DD-MON-YYYY HH24:MI');


      fnd_message.set_name('CSF', 'CSF_ALERTS_RESCHEDULE_SUB');
      fnd_message.set_token('CUST_NAME', l_cust_name);
      fnd_message.set_token('SCH_START_DT', l_schedule_start_date);

      l_msg_subject := fnd_message.get;

      l_document_id := to_char(l_resource_id) || '-' || l_resource_type || '-' || to_char(l_task_id) || '-' || to_char(l_task_audit_id);

   else
      return 'SUCCESS';
   end if;

   itemtype := 'CSFALERT';

   wf_engine.createprocess(itemtype => itemtype,
                              itemkey => itemkey,
                              process => 'MAIN_PROCESS');

   wf_engine.setItemAttrNumber(itemtype => itemtype,
                              itemkey => itemkey,
                              aname => 'TASK_ASSGN_ID',
                              avalue => l_task_asgn_id);

   wf_engine.setItemAttrNumber(itemtype => itemtype,
                              itemkey => itemkey,
                              aname => 'RES_ID',
                              avalue => l_resource_id);

   wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => itemkey,
                              aname => 'RES_TYPE',
                              avalue => l_resource_type);

   wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => itemkey,
                              aname => 'EVENT_TYPE',
                              avalue => l_csfw_event_type);

   wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => itemkey,
                              aname => 'RESOURCE',
                              avalue => l_resource);

   wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => itemkey,
                              aname => 'DOCUMENT_ID',
                              avalue => l_document_id);

   wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => itemkey,
                              aname => 'MSG_SUBJECT',
                              avalue => l_msg_subject);

   wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => itemkey,
                              aname => 'MSG_SUBJECT2',
                              avalue => l_msg_subject2);

   l_auto_reject := fnd_profile.VALUE_SPECIFIC('CSF_ALERTS_AUTO_REJECT',
                                          getUserId(l_resource_id, l_resource_type),
                                          21685,
                                          513,
                                          null,
                                          null);
   if l_auto_reject = 'Y' then
    l_auto_reject := 'TRUE';
   else
    l_auto_reject := 'FALSE';
   end if;

   wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => itemkey,
                              aname => 'AUTO_REJECT_VALUE',
                              avalue => l_auto_reject);

   l_time_out1 := fnd_profile.VALUE_SPECIFIC('CSF_ALERTS_RESPONSE_TIME_MIN',
                                          getUserId(l_resource_id, l_resource_type),
                                          21685,
                                          513,
                                          null,
                                          null);

   wf_engine.setItemAttrNumber(itemtype => itemtype,
                              itemkey => itemkey,
                              aname => 'TIMEOUT1',
                              avalue => l_time_out1);

   l_time_out2 := fnd_profile.VALUE_SPECIFIC('CSF_ALERTS_REMINDER_TIME_MIN',
                                            getUserId(l_resource_id, l_resource_type),
                                            21685,
                                            513,
                                            null,
                                            null);

   wf_engine.setItemAttrNumber(itemtype => itemtype,
                              itemkey => itemkey,
                              aname => 'TIMEOUT2',
                              avalue => l_time_out2);

  -- original task assignment status id
   wf_engine.setItemAttrNumber(itemtype => itemtype,
                              itemkey => itemkey,
                              aname => 'ORG_TSK_ASG_STS_ID',
                              avalue => l_org_assignment_status_id);

   wf_engine.startprocess(itemtype => itemtype,
                              itemkey => itemkey);

   return 'SUCCESS';

end;

procedure checkEvent (itemtype in varchar2,
                        itemkey in varchar2,
                        actid in number,
                        funcmode in varchar2,
                        resultout out nocopy varchar2) is

    l_event_type varchar2(20);
begin
    l_event_type := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                itemkey => itemkey,
                                                aname => 'EVENT_TYPE');
    resultout := 'COMPLETE:' || l_event_type;
end;

procedure check_again (itemtype in varchar2,
                        itemkey in varchar2,
                        actid in number,
                        funcmode in varchar2,
                        resultout out nocopy varchar2) is

  l_task_assgn_id number;
  l_task_id number;
  l_reminder_timeout number;
  l_resource_id number;
  l_resource_type varchar2(100);
  l_org_assignment_status_id number;
  l_curr_assignment_status_id number;

  cursor c_task_assgn_detail (v_task_assgn_id number) is
    SELECT distinct jtb.task_id,
        jta.resource_id,
        jta.resource_type_code,
        jta.assignment_status_id
    FROM jtf_tasks_b jtb,
      jtf_task_assignments jta,
      jtf_task_priorities_vl jp_vl,
      jtf_task_types_vl jtt_vl
    WHERE jta.task_assignment_id = v_task_assgn_id
      and jta.task_id = jtb.task_id
      and nvl(jtb.scheduled_start_date, sysdate - 1) > sysdate
      and nvl(jtb.scheduled_end_date, sysdate - 1) > sysdate
      and jta.assignment_status_id in (
                                      select
                                        task_status_id
                                      from
                                        jtf_task_statuses_b
                                      where
                                        usage = 'TASK'
                                        and nvl(assigned_flag, 'N') = 'Y'
                                        and nvl(assignment_status_flag, 'N') = 'Y'
                                        and sysdate between nvl(start_date_active, sysdate)
                                        and nvl(end_date_active, sysdate + 1)
                                      )
      and jtb.task_type_id = jtt_vl.task_type_id
      and jtt_vl.task_type_id in (
                                  select
                                    task_type_id
                                  from
                                    JTF_TASK_TYPES_B
                                  where
                                    rule = 'DISPATCH'
                                  )  -- only dispatch tasks
      and nvl(jtt_vl.schedule_flag, 'N') = 'Y' -- schedulable tasks
      and sysdate between nvl(jtt_vl.start_date_active, sysdate)
      and nvl(jtt_vl.end_date_active, sysdate + 1)
      and jtb.task_priority_id = jp_vl.task_priority_id
      and sysdate between nvl(jp_vl.start_date_active, sysdate)
      and nvl(jp_vl.end_date_active, sysdate + 1)
      and jp_vl.importance_level <= fnd_profile.VALUE_SPECIFIC('CSF_ALERT_PRIORITY',
                                                              getUserId(jta.resource_id, jta.resource_type_code),
                                                              21685,
                                                              513,
                                                              null,
                                                              null);
begin

  resultout := 'COMPLETE:F';

  l_task_assgn_id :=  wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                                itemkey => itemkey,
                                                aname => 'TASK_ASSGN_ID');

  l_org_assignment_status_id :=  wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                                itemkey => itemkey,
                                                aname => 'ORG_TSK_ASG_STS_ID');


  open c_task_assgn_detail(l_task_assgn_id);
  fetch c_task_assgn_detail into l_task_id, l_resource_id, l_resource_type, l_curr_assignment_status_id;
  close c_task_assgn_detail;

  if l_org_assignment_status_id is null then
      l_org_assignment_status_id := l_curr_assignment_status_id;
  end if;

  if l_task_id is not null
    and l_org_assignment_status_id = l_curr_assignment_status_id then
    -- check for timeout2 profile
    -- if it is null then do not send reminder

    l_reminder_timeout := fnd_profile.VALUE_SPECIFIC('CSF_ALERTS_REMINDER_TIME_MIN',
                                            getUserId(l_resource_id, l_resource_type),
                                            21685,
                                            513,
                                            null,
                                            null);

    if l_reminder_timeout is not null and l_reminder_timeout > 0 then
      resultout := 'COMPLETE:T';
    end if;

  end if;

end;

procedure check_auto_reject (itemtype in varchar2,
                        itemkey in varchar2,
                        actid in number,
                        funcmode in varchar2,
                        resultout out nocopy varchar2) is

  l_AUTO_REJECT_VALUE varchar2(25);

begin
  resultout := 'COMPLETE:F';
  l_AUTO_REJECT_VALUE := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                itemkey => itemkey,
                                                aname => 'AUTO_REJECT_VALUE');
  if l_AUTO_REJECT_VALUE = 'TRUE' then
    -- bug # 5845177
    wf_engine.setItemAttrText(itemtype => itemtype,
                            itemkey => itemkey,
                            aname => 'IS_AUTO_REJECT',
                            avalue => 'Y');
    resultout := 'COMPLETE:T';
  end if;
end;

procedure accept_assgn (itemtype in varchar2,
                        itemkey in varchar2,
                        actid in number,
                        funcmode in varchar2,
                        resultout out nocopy varchar2) is

      l_task_assgn_id   number;
      l_object_version_number number;

      l_tmp_user_id number;
      l_tmp_resp_id number;
      l_tmp_resp_apps_id number;

      l_resource_id number;
      l_resource_type varchar2(100);
      p_user_id number;

      l_return_status varchar2(10);
      l_msg_count number;
      l_msg_data varchar2(2000);
      l_task_object_version_number number;
      l_task_status_id number;
      --l_task_status_name varchar2(100);

      l_org_assignment_status_id number;
      l_curr_assignment_status_id number;

      cursor c_task_assgn_detail (v_task_assgn_id number) is
      SELECT jta.object_version_number, jta.assignment_status_id
      FROM
        jtf_task_assignments jta
      WHERE jta.task_assignment_id = v_task_assgn_id;
begin
      l_task_assgn_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                                itemkey => itemkey,
                                                aname => 'TASK_ASSGN_ID');

      l_org_assignment_status_id :=  wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                                itemkey => itemkey,
                                                aname => 'ORG_TSK_ASG_STS_ID');

      open c_task_assgn_detail(l_task_assgn_id);
      fetch c_task_assgn_detail into l_object_version_number, l_curr_assignment_status_id;
      close c_task_assgn_detail;

      -- check if task assignment status has been changed from the original value
      if l_org_assignment_status_id is null then
         l_org_assignment_status_id := l_curr_assignment_status_id;
      end if;

      resultout := 'COMPLETE';

      if l_org_assignment_status_id = l_curr_assignment_status_id then

      l_resource_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                                itemkey => itemkey,
                                                aname => 'RES_ID');

      l_resource_type := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                itemkey => itemkey,
                                                aname => 'RES_TYPE');

      p_user_id := getUserId(l_resource_id, l_resource_type);

      if p_user_id is null then
        p_user_id := 0;
      end if;

      -- call API
      l_tmp_user_id := fnd_global.USER_ID;
      l_tmp_resp_id := fnd_global.RESP_ID;
      l_tmp_resp_apps_id := fnd_global.RESP_APPL_ID;

      fnd_global.APPS_INITIALIZE(user_id => p_user_id, resp_id => 21685, resp_appl_id => 513);

      csf_task_assignments_pub.update_assignment_status(
                                    p_api_version => 1.0,
                                    p_task_assignment_id => l_task_assgn_id,
                                    p_assignment_status_id => fnd_profile.VALUE_SPECIFIC('CSF_DEFAULT_ACCEPTED_STATUS',
                                            getUserId(l_resource_id, l_resource_type),
                                            21685,
                                            513,
                                            null,
                                            null),    -- accepted
                                    p_object_version_number => l_object_version_number,
                                    x_return_status => l_return_status,
                                    x_msg_count => l_msg_count,
                                    x_msg_data  => l_msg_data,
                                    x_task_object_version_number  => l_task_object_version_number,
                                    x_task_status_id  => l_task_status_id
                           );

    fnd_global.APPS_INITIALIZE(user_id => l_tmp_user_id, resp_id => l_tmp_resp_id, resp_appl_id => l_tmp_resp_apps_id);

    if l_return_status = 'S' then
      resultout := 'COMPLETE';
    else
      resultout := 'ERROR' || ':' || l_msg_data;
    end if;

    end if; -- check for asgn status chng check
end;

procedure cancel_assgn (itemtype in varchar2,
                        itemkey in varchar2,
                        actid in number,
                        funcmode in varchar2,
                        resultout out nocopy varchar2) is

      l_task_assgn_id   number;
      l_object_version_number number;

      l_tmp_user_id number;
      l_tmp_resp_id number;
      l_tmp_resp_apps_id number;

      l_resource_id number;
      l_resource_type varchar2(100);
      p_user_id number;

      l_return_status varchar2(10);
      l_msg_count number;
      l_msg_data varchar2(2000);
      l_task_object_version_number number;
      l_task_status_id number;
      --l_task_status_name varchar2(100);

      l_org_assignment_status_id number;
      l_curr_assignment_status_id number;

      cursor c_task_assgn_detail (v_task_assgn_id number) is
      SELECT jta.object_version_number, jta.assignment_status_id
      FROM
        jtf_task_assignments jta
      WHERE jta.task_assignment_id = v_task_assgn_id;

      -- bug # 5220702
      l_auto_reject varchar2(1);
      l_task_id number;
      l_task_asgn_record task_asgn_record;
      l_cust_name varchar2(250);
      l_schedule_start_date varchar2(100);
      l_msg_subject varchar2(1000);
      l_document_id varchar2(250);

      cursor c_get_task_id (v_task_asgn_id number) is
      select task_id
      from jtf_task_assignments
      where task_assignment_id = v_task_asgn_id;
begin
      l_task_assgn_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                                itemkey => itemkey,
                                                aname => 'TASK_ASSGN_ID');

      l_org_assignment_status_id :=  wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                                itemkey => itemkey,
                                                aname => 'ORG_TSK_ASG_STS_ID');

      open c_task_assgn_detail(l_task_assgn_id);
      fetch c_task_assgn_detail into l_object_version_number, l_curr_assignment_status_id;
      close c_task_assgn_detail;

      -- check if task assignment status has been changed from the original value

      if l_org_assignment_status_id is null then
         l_org_assignment_status_id := l_curr_assignment_status_id;
      end if;

      resultout := 'COMPLETE:F';
      if l_org_assignment_status_id = l_curr_assignment_status_id then

      l_resource_id := wf_engine.GetItemAttrNumber(itemtype => itemtype,
                                                itemkey => itemkey,
                                                aname => 'RES_ID');

      l_resource_type := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                itemkey => itemkey,
                                                aname => 'RES_TYPE');

      p_user_id := getUserId(l_resource_id, l_resource_type);

      if p_user_id is null then
        p_user_id := 0;
      end if;

      -- call API
      l_tmp_user_id := fnd_global.USER_ID;
      l_tmp_resp_id := fnd_global.RESP_ID;
      l_tmp_resp_apps_id := fnd_global.RESP_APPL_ID;

      fnd_global.APPS_INITIALIZE(user_id => p_user_id, resp_id => 21685, resp_appl_id => 513);

      csf_task_assignments_pub.update_assignment_status(
                                    p_api_version => 1.0,
                                    p_task_assignment_id => l_task_assgn_id,
                                    p_assignment_status_id => fnd_profile.VALUE_SPECIFIC('CSF_DEFAULT_REJECTED_STATUS',
                                            getUserId(l_resource_id, l_resource_type),
                                            21685,
                                            513,
                                            null,
                                            null),    -- Rejected
                                    p_object_version_number => l_object_version_number,
                                    x_return_status => l_return_status,
                                    x_msg_count => l_msg_count,
                                    x_msg_data  => l_msg_data,
                                    x_task_object_version_number  => l_task_object_version_number,
                                    x_task_status_id  => l_task_status_id
                           );

    fnd_global.APPS_INITIALIZE(user_id => l_tmp_user_id, resp_id => l_tmp_resp_id, resp_appl_id => l_tmp_resp_apps_id);

    if l_return_status = 'S' then

      -- bug # 5220702
      l_auto_reject := wf_engine.GetItemAttrText(itemtype => itemtype,
                                                itemkey => itemkey,
                                                aname => 'IS_AUTO_REJECT');
      if l_auto_reject = 'Y' then
        -- modify subject and document_id
        open c_get_task_id(l_task_assgn_id);
        fetch c_get_task_id into l_task_id;
        close c_get_task_id;

        l_task_asgn_record := getTaskDetails(l_task_id, null, null);

        l_cust_name := l_task_asgn_record.cust_name;
        l_schedule_start_date := to_char(getClientTime(l_task_asgn_record.sch_st_date,
                                  getUserId(l_resource_id, l_resource_type)), 'DD-MON-YYYY HH24:MI');

        fnd_message.set_name('CSF', 'CSF_ALERTS_CANCEL_SUB');
        fnd_message.set_token('CUST_NAME', l_cust_name);
        fnd_message.set_token('SCH_START_DT', l_schedule_start_date);

        l_msg_subject := fnd_message.get;

        l_document_id := to_char(l_resource_id) || '-' || l_resource_type || '-' || to_char(l_task_id);

         wf_engine.setItemAttrText(itemtype => itemtype,
                            itemkey => itemkey,
                            aname => 'DOCUMENT_ID',
                            avalue => l_document_id);

         wf_engine.setItemAttrText(itemtype => itemtype,
                              itemkey => itemkey,
                              aname => 'MSG_SUBJECT',
                              avalue => l_msg_subject);

        resultout := 'COMPLETE:T';
      else
        resultout := 'COMPLETE:F';
      end if;
    else
      resultout := 'ERROR' || ':' || l_msg_data;
    end if;

    end if; -- check for asgn status chng check

end;

function getSendDate (p_resource_id number,
                      p_resource_type_code varchar2,
                      p_scheduled_start_date date,
                      p_scheduled_end_date date) return date is
  l_return_date date;
  l_profile_value varchar2(100);
  l_minutes_before number;
  l_shifts CSF_RESOURCE_PUB.shift_tbl_type;
  X_RETURN_STATUS VARCHAR2(200);
  X_MSG_COUNT NUMBER;
  X_MSG_DATA VARCHAR2(200);
begin
  l_return_date := null;
  l_profile_value := fnd_profile.value_specific('CSF_ALERT_SEND_PREF',
                                            getUserId(p_resource_id, p_resource_type_code),
                                            21685,
                                            513,
                                            null,
                                            null);

  if l_profile_value = 'SHIFT_DAY' then  -- During Shift

    -- fetch shift start date time for the given schedule dates
    CSF_RESOURCE_PUB.GET_RESOURCE_SHIFTS(
                    P_API_VERSION => 1.0,
                    P_RESOURCE_ID => p_resource_id,
                    P_RESOURCE_TYPE => p_resource_type_code,
                    P_START_DATE => p_scheduled_start_date,
                    P_END_DATE => p_scheduled_end_date,
                    X_RETURN_STATUS => X_RETURN_STATUS,
                    X_MSG_COUNT => X_MSG_COUNT,
                    X_MSG_DATA => X_MSG_DATA,
                    X_SHIFTS => l_shifts
                    );

    if (X_RETURN_STATUS = 'S') and (l_shifts is not null) and (l_shifts.count > 0) then
      l_return_date := l_shifts(1).start_datetime;

      -- if shift start is less than current date time then send immediately
      if l_return_date > sysdate then
        -- fetch next shift start from today
        CSF_RESOURCE_PUB.GET_RESOURCE_SHIFTS(
                P_API_VERSION => 1.0,
                P_RESOURCE_ID => p_resource_id,
                P_RESOURCE_TYPE => p_resource_type_code,
                P_START_DATE => trunc(sysdate) + 1,
                P_END_DATE => trunc(sysdate) + 2,
                X_RETURN_STATUS => X_RETURN_STATUS,
                X_MSG_COUNT => X_MSG_COUNT,
                X_MSG_DATA => X_MSG_DATA,
                X_SHIFTS => l_shifts
                );

        if (X_RETURN_STATUS = 'S') and (l_shifts is not null) and (l_shifts.count > 0) then
          l_return_date := l_shifts(1).start_datetime;

          -- fetch profile value for how many minutes before should we send the notification
          l_minutes_before := fnd_profile.VALUE_SPECIFIC('CSF_ALERTS_MIN_BEFORE_SHIFT',
                                                        getUserId(p_resource_id, p_resource_type_code),
                                                        21685,
                                                        513,
                                                        null,
                                                        null);

          l_return_date := (l_return_date - l_minutes_before / 1440);

          -- for testing purpose
          -- l_return_date := sysdate + 20/86400;

        end if;

      end if;

    end if;

  elsif l_profile_value = 'SCHEDULE_DAY' then -- Scheduled Day

    -- fetch shift start date time for the given schedule dates
    CSF_RESOURCE_PUB.GET_RESOURCE_SHIFTS(
                        P_API_VERSION => 1.0,
                        P_RESOURCE_ID => p_resource_id,
                        P_RESOURCE_TYPE => p_resource_type_code,
                        P_START_DATE => p_scheduled_start_date,
                        P_END_DATE => p_scheduled_end_date,
                        X_RETURN_STATUS => X_RETURN_STATUS,
                        X_MSG_COUNT => X_MSG_COUNT,
                        X_MSG_DATA => X_MSG_DATA,
                        X_SHIFTS => l_shifts
                        );

   if (X_RETURN_STATUS = 'S') and (l_shifts is not null) and (l_shifts.count > 0)  then
      l_return_date := l_shifts(1).start_datetime;

      -- fetch profile value for how many minutes before should we send the notification
      l_minutes_before := fnd_profile.VALUE_SPECIFIC('CSF_ALERTS_MIN_BEFORE_SHIFT',
                                              getUserId(p_resource_id, p_resource_type_code),
                                              21685,
                                              513,
                                              null,
                                              null);

      l_return_date := (l_return_date - l_minutes_before / 1440);

      -- for testing purpose
      -- l_return_date := sysdate + 20/86400;

      -- if shift start is less than current date time then send immediately
      if l_return_date <= sysdate then
        l_return_date := null;
      end if;
   end if;

  else  -- Immediate
    l_return_date := null;
  end if;

  return l_return_date;
end;

function getUserId (p_resource_id number,
                    p_resource_type varchar2) return number is
  l_user_id number;
  cursor c_user_id (v_resource_id number, v_category varchar2) is
    select user_id from jtf_rs_resource_extns where resource_id = v_resource_id and category = v_category;
begin
  l_user_id := 0;

  open c_user_id (p_resource_id, category_type(p_resource_type));
  fetch c_user_id into l_user_id;
  close c_user_id;

  return l_user_id;
end;

function getUserName (p_resource_id number,
                    p_resource_type varchar2) return varchar2 is
  l_user_name varchar2(100);
begin
  return l_user_name;
end;

FUNCTION category_type ( p_rs_category varchar2 ) return varchar2 is
begin
  if p_rs_category = 'RS_EMPLOYEE' then
    return 'EMPLOYEE';
  elsif p_rs_category = 'RS_PARTNER' then
    return 'PARTNER';
  elsif p_rs_category = 'RS_SUPPLIER_CONTACT' then
    return 'SUPPLIER_CONTACT';
  elsif p_rs_category = 'RS_PARTY' then
    return 'PARTY';
  elsif p_rs_category = 'RS_OTHER' then
    return 'OTHER';
  else
    return null;
  end if;
end;

function getItemKey (p_event_type varchar2,
                    p_resource_id number,
                    p_resource_type_code varchar2,
                    p_task_assignment_id varchar2,
                    p_old_event_id varchar2) return varchar2 is

  l_new_item_key varchar2(240);
  l_old_event_id varchar2(20);
begin
  l_old_event_id := substr(p_old_event_id, (INSTR(p_old_event_id, '-') + 1));
  l_new_item_key := '';
  l_new_item_key := l_new_item_key || p_event_type
                              || '-' || to_char(p_resource_id)
                              || '-' || p_resource_type_code
                              || '-' || to_char(p_task_assignment_id)
                              || '-' || l_old_event_id;
  return l_new_item_key;
end;

function checkAlertsEnabled(p_resource_id number,
                    p_resource_type_code varchar2) return boolean is
  l_return_value boolean;
begin
  l_return_value := false;

  if fnd_profile.VALUE_SPECIFIC('CSF_ALERTS_ENABLE',
                              getUserId(p_resource_id, p_resource_type_code),
                              21685,
                              513,
                              null,
                              null) = 'Y' then
    l_return_value := true;
  end if;
  return l_return_value;
end;

procedure getAssignedMessage(document_id varchar2,
                            display_type varchar2,
                            document in out nocopy varchar2,
                            document_type in out nocopy varchar2) is
  l_resource_id number;
  l_resource_type varchar2(100);
  l_task_asgn_id number;
  l_message varchar2(32000);
  l_task_detail task_asgn_record;
  l_message_header varchar2(1000);

  l_tmp_user_id number;
  l_tmp_resp_id number;
  l_tmp_resp_apps_id number;
  p_user_id number;

  -- notes
  l_is_notes varchar2(1);
  l_notes varchar2(30000);
  cursor c_notes (v_task_asgn_id number) is
  select
    n.notes
  from
    jtf_notes_vl n,
    jtf_task_assignments a
  where
    n.source_object_code = 'TASK'
    and n.source_object_id = a.task_id
    and a.task_assignment_id = v_task_asgn_id
  union select
    n.notes
  from
    jtf_notes_vl n,
    jtf_task_assignments a,
    jtf_tasks_b t
  where
    n.source_object_code = 'SR'
    and n.source_object_id = t.source_object_id
    and t.task_id = a.task_id
    and a.task_assignment_id = v_task_asgn_id;
begin

  l_resource_id := to_number(substr(document_id, 1, instr(document_id, '-', 1, 1) - 1));
  l_resource_type := substr(document_id, instr(document_id, '-', 1, 1) + 1, instr(document_id, '-', 1, 2) - instr(document_id, '-', 1, 1) - 1);
  l_task_asgn_id := to_number(substr(document_id, instr(document_id, '-', 1, 2) + 1));


  p_user_id := getUserId(l_resource_id, l_resource_type);


  if p_user_id is null then
    p_user_id := 0;
  end if;

  -- call API
  l_tmp_user_id := fnd_global.USER_ID;
  l_tmp_resp_id := fnd_global.RESP_ID;
  l_tmp_resp_apps_id := fnd_global.RESP_APPL_ID;

  fnd_global.APPS_INITIALIZE(user_id => p_user_id, resp_id => 21685, resp_appl_id => 513);

  l_task_detail := getTaskDetails(null, l_task_asgn_id, null);


  fnd_message.set_name('CSF', 'CSF_ALERTS_ASSIGNED_HDR');
  l_message_header := fnd_message.get;

  if display_type = 'text/html' then

    l_message := '<P>';
    l_message := l_message || l_message_header || '</P>';
    l_message := l_message || '<P><B>' || getPrompt('CSF_ALERTS_TASK_DETAILS') || ':</B></P>';
    l_message := l_message || '<P>';
    l_message := l_message || '<TABLE cellSpacing=0 cellPadding=0 border=1>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_TASK') || '</B></TD>';
    l_message := l_message || '<TD>' || l_task_detail.task_number || ' ' || l_task_detail.task_name || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_DESCRIPTION') || '</B></TD>';
    l_message := l_message || '<TD>' || l_task_detail.task_desc || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_SCHEDULE_START') || '</B></TD>';
    l_message := l_message || '<TD>' || to_char(getClientTime(l_task_detail.sch_st_date,
                                          getUserId(l_resource_id, l_resource_type)), 'DD-MON-YYYY HH24:MI')
                                          || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_SCHEDULE_END') || '</B></TD>';
    l_message := l_message || '<TD>' || to_char(getClientTime(l_task_detail.sch_end_date,
                                            getUserId(l_resource_id, l_resource_type)), 'DD-MON-YYYY HH24:MI')
                                            || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_PLANNED_EFFORT') || '</B></TD>';
    l_message := l_message || '<TD>' || l_task_detail.planned_effort || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_PRIORITY') || '</B></TD>';
    l_message := l_message || '<TD>' || l_task_detail.priority || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_STATUS') || '</B></TD>';
    l_message := l_message || '<TD>' || l_task_detail.asgm_sts_name || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '</TABLE>';
    l_message := l_message || '</P>';
    l_message := l_message || '<P><B>' || getPrompt('CSF_ALERTS_SERVICE_REQUEST') || ': </B>';
    l_message := l_message || l_task_detail.sr_number || ' ' || l_task_detail.sr_summary;
    l_message := l_message || '</P>';

    if l_task_detail.product_nr is not null then
      l_message := l_message || '<P><B>' || getPrompt('CSF_ALERTS_ITEM') || '</B>: ' || l_task_detail.product_nr || ', ' || l_task_detail.item_description;
      if l_task_detail.item_serial is not null then
        l_message := l_message || '(' || l_task_detail.item_serial || ')';
      end if;
      l_message := l_message || '</P>';
    end if;

    l_message := l_message || '<P><B>' || getPrompt('CSF_ALERTS_CUSTOMER') || '</B>:<BR/>';
    l_message := l_message || l_task_detail.cust_name || '<BR/>';
    l_message := l_message || l_task_detail.cust_address || '<BR/>';

    if l_task_detail.contact_name is not null then
      l_message := l_message || '<B>' || getPrompt('CSF_ALERTS_CONTACT') || '</B>: ' || l_task_detail.contact_name || '<BR/>';
      l_message := l_message || l_task_detail.contact_phone || ' ' || l_task_detail.contact_email;
    end if;

    l_message := l_message || '</P>';

    -- notes
    l_is_notes := 'N';

    open c_notes(l_task_asgn_id);
    loop
      fetch c_notes into l_notes;
      exit when c_notes%NOTFOUND;

      if l_is_notes = 'N' then
        l_message := l_message || '<P><B>' || getPrompt('CSF_ALERTS_NOTES') || ':</B></P>';
        l_is_notes := 'Y';
      end if;

      l_message := l_message || l_notes || '<BR/>';

    end loop;
    close c_notes;

  else

    l_message := '';
    l_message := l_message || '
    ' || l_message_header;
    l_message := l_message || '
    ' || '
    ' || getPrompt('CSF_ALERTS_TASK_DETAILS') || ':';
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_TASK') || ': ';
    l_message := l_message || l_task_detail.task_number || ' ' || l_task_detail.task_name;
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_DESCRIPTION') || ': ';
    l_message := l_message || l_task_detail.task_desc;
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_SCHEDULE_START') || ': ';
    l_message := l_message || to_char(getClientTime(l_task_detail.sch_st_date,
                                        getUserId(l_resource_id, l_resource_type)), 'DD-MON-YYYY HH24:MI');
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_SCHEDULE_END') || ': ';
    l_message := l_message || to_char(getClientTime(l_task_detail.sch_end_date,
                                        getUserId(l_resource_id, l_resource_type)), 'DD-MON-YYYY HH24:MI');
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_PLANNED_EFFORT') || ': ';
    l_message := l_message || l_task_detail.planned_effort;
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_PRIORITY') || ': ';
    l_message := l_message || l_task_detail.priority;
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_STATUS') || ': ';
    l_message := l_message || l_task_detail.asgm_sts_name;
    l_message := l_message || '
    ' || '
    ' || getPrompt('CSF_ALERTS_SERVICE_REQUEST') || ': ';
    l_message := l_message || l_task_detail.sr_number || ' ' || l_task_detail.sr_summary;

    if l_task_detail.product_nr is not null then
      l_message := l_message || '
      ' || '
      ' || getPrompt('CSF_ALERTS_ITEM') || ': ' || l_task_detail.product_nr || ', ' || l_task_detail.item_description;
      if l_task_detail.item_serial is not null then
        l_message := l_message || '(' || l_task_detail.item_serial || ')';
      end if;
    end if;

    l_message := l_message || '
    ' || '
    ' || getPrompt('CSF_ALERTS_CUSTOMER') || ': ';
    l_message := l_message || '
    ' || l_task_detail.cust_name;
    l_message := l_message || '
    ' || l_task_detail.cust_address;

    if l_task_detail.contact_name is not null then
      l_message := l_message || '
      ' || '
      ' || getPrompt('CSF_ALERTS_CONTACT') || ': ' || l_task_detail.contact_name;
      l_message := l_message || l_task_detail.contact_phone || ' ' || l_task_detail.contact_email;
    end if;

    -- notes
    l_is_notes := 'N';

    open c_notes(l_task_asgn_id);
    loop
      fetch c_notes into l_notes;
      exit when c_notes%NOTFOUND;

      if l_is_notes = 'N' then
        l_message := l_message || '
        ' || getPrompt('CSF_ALERTS_NOTES') || ':';
        l_is_notes := 'Y';
      end if;

      l_message := l_message || l_notes || '
      ';

    end loop;
    close c_notes;

  end if;

  fnd_global.APPS_INITIALIZE(user_id => l_tmp_user_id, resp_id => l_tmp_resp_id, resp_appl_id => l_tmp_resp_apps_id);

  document := l_message;

end;

procedure getReminderMessage(document_id varchar2,
                            display_type varchar2,
                            document in out nocopy varchar2,
                            document_type in out nocopy varchar2) is
  l_resource_id number;
  l_resource_type varchar2(100);
  l_task_asgn_id number;

  l_message varchar2(32000);
  l_task_detail task_asgn_record;
  l_message_header1 varchar2(1000);
  l_message_header2 varchar2(1000);

  l_tmp_user_id number;
  l_tmp_resp_id number;
  l_tmp_resp_apps_id number;
  p_user_id number;

  -- notes
  l_is_notes varchar2(1);
  l_notes varchar2(30000);
  cursor c_notes (v_task_asgn_id number) is
  select
    n.notes
  from
    jtf_notes_vl n,
    jtf_task_assignments a
  where
    n.source_object_code = 'TASK'
    and n.source_object_id = a.task_id
    and a.task_assignment_id = v_task_asgn_id
  union select
    n.notes
  from
    jtf_notes_vl n,
    jtf_task_assignments a,
    jtf_tasks_b t
  where
    n.source_object_code = 'SR'
    and n.source_object_id = t.source_object_id
    and t.task_id = a.task_id
    and a.task_assignment_id = v_task_asgn_id;
begin

  l_resource_id := to_number(substr(document_id, 1, instr(document_id, '-', 1, 1) - 1));
  l_resource_type := substr(document_id, instr(document_id, '-', 1, 1) + 1, instr(document_id, '-', 1, 2) - instr(document_id, '-', 1, 1) - 1);
  l_task_asgn_id := to_number(substr(document_id, instr(document_id, '-', 1, 2) + 1));

  p_user_id := getUserId(l_resource_id, l_resource_type);

  if p_user_id is null then
    p_user_id := 0;
  end if;

  -- call API
  l_tmp_user_id := fnd_global.USER_ID;
  l_tmp_resp_id := fnd_global.RESP_ID;
  l_tmp_resp_apps_id := fnd_global.RESP_APPL_ID;

  fnd_global.APPS_INITIALIZE(user_id => p_user_id, resp_id => 21685, resp_appl_id => 513);

  l_task_detail := getTaskDetails(null, l_task_asgn_id, null);

  fnd_message.set_name('CSF', 'CSF_ALERTS_REMINDER_HDR');
  l_message_header1 := fnd_message.get;
  fnd_message.set_name('CSF', 'CSF_ALERTS_ASSIGNED_HDR');
  l_message_header2 := fnd_message.get;

  if display_type = 'text/html' then

    l_message := '<P>';
    l_message := l_message || '<B>' || l_message_header1 || '</B>';
    l_message := l_message || '<P>';
    l_message := l_message || l_message_header2 || '</P>';
    l_message := l_message || '<P><B>' || getPrompt('CSF_ALERTS_TASK_DETAILS') || ':</B></P>';
    l_message := l_message || '<P>';
    l_message := l_message || '<TABLE cellSpacing=0 cellPadding=0 border=1>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_TASK') || '</B></TD>';
    l_message := l_message || '<TD>' || l_task_detail.task_number || ' ' || l_task_detail.task_name || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_DESCRIPTION') || '</B></TD>';
    l_message := l_message || '<TD>' || l_task_detail.task_desc || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_SCHEDULE_START') || '</B></TD>';
    l_message := l_message || '<TD>' || to_char(getClientTime(l_task_detail.sch_st_date,
                                                getUserId(l_resource_id, l_resource_type)), 'DD-MON-YYYY HH24:MI')
                                                || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_SCHEDULE_END') || '</B></TD>';
    l_message := l_message || '<TD>' || to_char(getClientTime(l_task_detail.sch_end_date,
                                                getUserId(l_resource_id, l_resource_type)), 'DD-MON-YYYY HH24:MI')
                                                || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_PLANNED_EFFORT') || '</B></TD>';
    l_message := l_message || '<TD>' || l_task_detail.planned_effort || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_PRIORITY') || '</B></TD>';
    l_message := l_message || '<TD>' || l_task_detail.priority || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_STATUS') || '</B></TD>';
    l_message := l_message || '<TD>' || l_task_detail.asgm_sts_name || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '</TABLE>';
    l_message := l_message || '</P>';
    l_message := l_message || '<P><B>' || getPrompt('CSF_ALERTS_SERVICE_REQUEST') || ':</B>';
    l_message := l_message || l_task_detail.sr_number || ' ' || l_task_detail.sr_summary;
    l_message := l_message || '</P>';

    if l_task_detail.product_nr is not null then
      l_message := l_message || '<P><B>' || getPrompt('CSF_ALERTS_ITEM') || '</B>: ' || l_task_detail.product_nr || ', ' || l_task_detail.item_description;
      if l_task_detail.item_serial is not null then
        l_message := l_message || '(' || l_task_detail.item_serial || ')';
      end if;
      l_message := l_message || '</P>';
    end if;

    l_message := l_message || '<P><B>' || getPrompt('CSF_ALERTS_CUSTOMER') || '</B>:<BR/>';
    l_message := l_message || l_task_detail.cust_name || '<BR/>';
    l_message := l_message || l_task_detail.cust_address || '<BR/>';

    if l_task_detail.contact_name is not null then
      l_message := l_message || '<B>' || getPrompt('CSF_ALERTS_CONTACT') || '</B>: ' || l_task_detail.contact_name || '<BR/>';
      l_message := l_message || l_task_detail.contact_phone || ' ' || l_task_detail.contact_email;
    end if;

    l_message := l_message || '</P>';

    -- notes
    l_is_notes := 'N';

    open c_notes(l_task_asgn_id);
    loop
      fetch c_notes into l_notes;
      exit when c_notes%NOTFOUND;

      if l_is_notes = 'N' then
        l_message := l_message || '<P><B>' || getPrompt('CSF_ALERTS_NOTES') || ':</B></P>';
        l_is_notes := 'Y';
      end if;

      l_message := l_message || l_notes || '<BR/>';

    end loop;
    close c_notes;

  else

    l_message := '
    ' || l_message_header1;
    l_message := l_message || '
    ' || '
    ' || l_message_header2;
    l_message := l_message || '
    ' || '
    ' || getPrompt('CSF_ALERTS_TASK_DETAILS') || ':';
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_TASK') || ': ';
    l_message := l_message || l_task_detail.task_number || ' ' || l_task_detail.task_name;
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_DESCRIPTION') || ': ';
    l_message := l_message || l_task_detail.task_desc;
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_SCHEDULE_START') || ': ';
    l_message := l_message || to_char(getClientTime(l_task_detail.sch_st_date,
                                                    getUserId(l_resource_id, l_resource_type)), 'DD-MON-YYYY HH24:MI');
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_SCHEDULE_END') || ': ';
    l_message := l_message || to_char(getClientTime(l_task_detail.sch_end_date,
                                                    getUserId(l_resource_id, l_resource_type)), 'DD-MON-YYYY HH24:MI');
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_PLANNED_EFFORT') || ': ';
    l_message := l_message || l_task_detail.planned_effort;
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_PRIORITY') || ': ';
    l_message := l_message || l_task_detail.priority;
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_STATUS') || ': ';
    l_message := l_message || l_task_detail.asgm_sts_name;
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_SERVICE_REQUEST') || ': ';
    l_message := l_message || l_task_detail.sr_number || ' ' || l_task_detail.sr_summary;

    if l_task_detail.product_nr is not null then
      l_message := l_message || '
      ' || '
      ' || getPrompt('CSF_ALERTS_ITEM') || ': ' || l_task_detail.product_nr || ', ' || l_task_detail.item_description;
      if l_task_detail.item_serial is not null then
        l_message := l_message || '(' || l_task_detail.item_serial || ')';
      end if;
    end if;

    l_message := l_message || '
    ' || '
    ' || getPrompt('CSF_ALERTS_CUSTOMER') || ': ';
    l_message := l_message || '
    ' || l_task_detail.cust_name;
    l_message := l_message || '
    ' || l_task_detail.cust_address;

    if l_task_detail.contact_name is not null then
      l_message := l_message || '
      ' || getPrompt('CSF_ALERTS_CONTACT') || ': ' || l_task_detail.contact_name;
      l_message := l_message || l_task_detail.contact_phone || ' ' || l_task_detail.contact_email;
    end if;

    -- notes
    l_is_notes := 'N';

    open c_notes(l_task_asgn_id);
    loop
      fetch c_notes into l_notes;
      exit when c_notes%NOTFOUND;

      if l_is_notes = 'N' then
        l_message := l_message || '
        ' || getPrompt('CSF_ALERTS_NOTES') || ':';
        l_is_notes := 'Y';
      end if;

      l_message := l_message || l_notes || '
      ';

    end loop;
    close c_notes;

  end if;

  fnd_global.APPS_INITIALIZE(user_id => l_tmp_user_id, resp_id => l_tmp_resp_id, resp_appl_id => l_tmp_resp_apps_id);

  document := l_message;

end;

procedure getDeleteMessage(document_id varchar2,
                            display_type varchar2,
                            document in out nocopy varchar2,
                            document_type in out nocopy varchar2) is
  l_resource_id number;
  l_resource_type varchar2(100);
  l_task_id number;

  l_message varchar2(32000);
  l_task_detail task_asgn_record;
  l_message_header varchar2(1000);

  l_tmp_user_id number;
  l_tmp_resp_id number;
  l_tmp_resp_apps_id number;
  p_user_id number;

  -- notes
  l_is_notes varchar2(1);
  l_notes varchar2(30000);
  cursor c_notes (v_task_id number) is
  select
    n.notes
  from
    jtf_notes_vl n
  where
    n.source_object_code = 'TASK'
    and n.source_object_id = v_task_id
  union select
    n.notes
  from
    jtf_notes_vl n,
    jtf_tasks_b t
  where
    n.source_object_code = 'SR'
    and n.source_object_id = t.source_object_id
    and t.task_id = v_task_id;
begin

  l_resource_id := to_number(substr(document_id, 1, instr(document_id, '-', 1, 1) - 1));
  l_resource_type := substr(document_id, instr(document_id, '-', 1, 1) + 1, instr(document_id, '-', 1, 2) - instr(document_id, '-', 1, 1) - 1);
  l_task_id := to_number(substr(document_id, instr(document_id, '-', 1, 2) + 1));

  p_user_id := getUserId(l_resource_id, l_resource_type);

  if p_user_id is null then
    p_user_id := 0;
  end if;

  -- call API
  l_tmp_user_id := fnd_global.USER_ID;
  l_tmp_resp_id := fnd_global.RESP_ID;
  l_tmp_resp_apps_id := fnd_global.RESP_APPL_ID;

  fnd_global.APPS_INITIALIZE(user_id => p_user_id, resp_id => 21685, resp_appl_id => 513);

  l_task_detail := getTaskDetails(l_task_id, null, null);

  fnd_message.set_name('CSF', 'CSF_ALERTS_DELETE_HDR');
  l_message_header := fnd_message.get;

  if display_type = 'text/html' then

    l_message := '<P>';
    l_message := l_message || l_message_header || '</P>';
    l_message := l_message || '<P><B>' || getPrompt('CSF_ALERTS_TASK_DETAILS') || ':</B></P>';
    l_message := l_message || '<P>';
    l_message := l_message || '<TABLE cellSpacing=0 cellPadding=0 border=1>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_TASK') || '</B></TD>';
    l_message := l_message || '<TD>' || l_task_detail.task_number || ' ' || l_task_detail.task_name || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_DESCRIPTION') || '</B></TD>';
    l_message := l_message || '<TD>' || l_task_detail.task_desc || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_SCHEDULE_START') || '</B></TD>';
    l_message := l_message || '<TD>' || to_char(getClientTime(l_task_detail.sch_st_date,
                                                getUserId(l_resource_id, l_resource_type)), 'DD-MON-YYYY HH24:MI')
                                                || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_SCHEDULE_END') || '</B></TD>';
    l_message := l_message || '<TD>' || to_char(getClientTime(l_task_detail.sch_end_date,
                                                getUserId(l_resource_id, l_resource_type)), 'DD-MON-YYYY HH24:MI')
                                                || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_PLANNED_EFFORT') || '</B></TD>';
    l_message := l_message || '<TD>' || l_task_detail.planned_effort || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_PRIORITY') || '</B></TD>';
    l_message := l_message || '<TD>' || l_task_detail.priority || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '</TABLE>';
    l_message := l_message || '</P>';
    l_message := l_message || '<P><B>' || getPrompt('CSF_ALERTS_SERVICE_REQUEST') || ':</B>';
    l_message := l_message || l_task_detail.sr_number || ' ' || l_task_detail.sr_summary;
    l_message := l_message || '</P>';

    if l_task_detail.product_nr is not null then
      l_message := l_message || '<P><B>' || getPrompt('CSF_ALERTS_ITEM') || '</B>: ' || l_task_detail.product_nr || ', ' || l_task_detail.item_description;
      if l_task_detail.item_serial is not null then
        l_message := l_message || '(' || l_task_detail.item_serial || ')';
      end if;
      l_message := l_message || '</P>';
    end if;

    l_message := l_message || '<P><B>' || getPrompt('CSF_ALERTS_CUSTOMER') || '</B>:<BR/>';
    l_message := l_message || l_task_detail.cust_name || '<BR/>';
    l_message := l_message || l_task_detail.cust_address || '<BR/>';

    if l_task_detail.contact_name is not null then
      l_message := l_message || '<B>' || getPrompt('CSF_ALERTS_CONTACT') || '</B>: ' || l_task_detail.contact_name || '<BR/>';
      l_message := l_message || l_task_detail.contact_phone || ' ' || l_task_detail.contact_email;
    end if;

    l_message := l_message || '</P>';

    -- notes
    l_is_notes := 'N';

    open c_notes(l_task_id);
    loop
      fetch c_notes into l_notes;
      exit when c_notes%NOTFOUND;

      if l_is_notes = 'N' then
        l_message := l_message || '<P><B>' || getPrompt('CSF_ALERTS_NOTES') || ':</B></P>';
        l_is_notes := 'Y';
      end if;

      l_message := l_message || l_notes || '<BR/>';

    end loop;
    close c_notes;

  else

    l_message := '';
    l_message := l_message || '
    ' || l_message_header;
    l_message := l_message || '
    ' || '
    ' || getPrompt('CSF_ALERTS_TASK_DETAILS') || ':';
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_TASK') || ': ';
    l_message := l_message || l_task_detail.task_number || ' ' || l_task_detail.task_name;
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_DESCRIPTION') || ': ';
    l_message := l_message || l_task_detail.task_desc;
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_SCHEDULE_START') || ': ';
    l_message := l_message || to_char(getClientTime(l_task_detail.sch_st_date,
                                          getUserId(l_resource_id, l_resource_type)), 'DD-MON-YYYY HH24:MI');
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_SCHEDULE_END') || ': ';
    l_message := l_message || to_char(getClientTime(l_task_detail.sch_end_date,
                                          getUserId(l_resource_id, l_resource_type)), 'DD-MON-YYYY HH24:MI');
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_PLANNED_EFFORT') || ': ';
    l_message := l_message || l_task_detail.planned_effort;
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_PRIORITY') || ': ';
    l_message := l_message || l_task_detail.priority;
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_SERVICE_REQUEST') || ': ';
    l_message := l_message || l_task_detail.sr_number || ' ' || l_task_detail.sr_summary;

    if l_task_detail.product_nr is not null then
      l_message := l_message || '
      ' || '
      ' || getPrompt('CSF_ALERTS_ITEM') || ': ' || l_task_detail.product_nr || ', ' || l_task_detail.item_description;
      if l_task_detail.item_serial is not null then
        l_message := l_message || '(' || l_task_detail.item_serial || ')';
      end if;
    end if;

    l_message := l_message || '
    ' || '
    ' || getPrompt('CSF_ALERTS_CUSTOMER') || ': ';
    l_message := l_message || '
    ' || l_task_detail.cust_name;
    l_message := l_message || '
    ' || l_task_detail.cust_address;

    if l_task_detail.contact_name is not null then
      l_message := l_message || '
      ' || getPrompt('CSF_ALERTS_CONTACT') || ': ' || l_task_detail.contact_name;
      l_message := l_message || l_task_detail.contact_phone || ' ' || l_task_detail.contact_email;
    end if;

    -- notes
    l_is_notes := 'N';

    open c_notes(l_task_id);
    loop
      fetch c_notes into l_notes;
      exit when c_notes%NOTFOUND;

      if l_is_notes = 'N' then
        l_message := l_message || '
        ' || getPrompt('CSF_ALERTS_NOTES') || ':';
        l_is_notes := 'Y';
      end if;

      l_message := l_message || l_notes || '
      ';

    end loop;
    close c_notes;

  end if;

  fnd_global.APPS_INITIALIZE(user_id => l_tmp_user_id, resp_id => l_tmp_resp_id, resp_appl_id => l_tmp_resp_apps_id);

  document := l_message;

end;

procedure getRescheduleMessage(document_id varchar2,
                            display_type varchar2,
                            document in out nocopy varchar2,
                            document_type in out nocopy varchar2) is
  l_resource_id number;
  l_resource_type varchar2(100);
  l_message varchar2(32000);
  l_task_detail task_asgn_record;
  p_task_id number;
  p_task_audit_id number;
  l_message_header varchar2(1000);

  l_tmp_user_id number;
  l_tmp_resp_id number;
  l_tmp_resp_apps_id number;
  p_user_id number;

  -- notes
  l_is_notes varchar2(1);
  l_notes varchar2(30000);
  cursor c_notes (v_task_id number) is
  select
    n.notes
  from
    jtf_notes_vl n
  where
    n.source_object_code = 'TASK'
    and n.source_object_id = v_task_id
  union select
    n.notes
  from
    jtf_notes_vl n,
    jtf_tasks_b t
  where
    n.source_object_code = 'SR'
    and n.source_object_id = t.source_object_id
    and t.task_id = v_task_id;
begin

  l_resource_id := to_number(substr(document_id, 1, instr(document_id, '-', 1, 1) - 1));
  l_resource_type := substr(document_id, instr(document_id, '-', 1, 1) + 1, instr(document_id, '-', 1, 2) - instr(document_id, '-', 1, 1) - 1);

  p_task_id := to_number(substr(document_id, instr(document_id, '-', 1, 2) + 1, instr(document_id, '-', 1, 3) - instr(document_id, '-', 1, 2) - 1));
  p_task_audit_id := to_number(substr(document_id, instr(document_id, '-', 1, 3) + 1));

  p_user_id := getUserId(l_resource_id, l_resource_type);

  if p_user_id is null then
    p_user_id := 0;
  end if;

  -- call API
  l_tmp_user_id := fnd_global.USER_ID;
  l_tmp_resp_id := fnd_global.RESP_ID;
  l_tmp_resp_apps_id := fnd_global.RESP_APPL_ID;

  fnd_global.APPS_INITIALIZE(user_id => p_user_id, resp_id => 21685, resp_appl_id => 513);

  l_task_detail := getTaskDetails(p_task_id, null, p_task_audit_id);

  fnd_message.set_name('CSF', 'CSF_ALERTS_RESCHEDULE_HDR');
  l_message_header := fnd_message.get;

  if display_type = 'text/html' then

    l_message := '<P>';
    l_message := l_message || l_message_header || '</P>';
    l_message := l_message || '<P><B>' || getPrompt('CSF_ALERTS_TASK_DETAILS') || ':</B></P>';
    l_message := l_message || '<P>';
    l_message := l_message || '<TABLE cellSpacing=0 cellPadding=0 border=1>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_TASK') || '</B></TD>';
    l_message := l_message || '<TD>' || l_task_detail.task_number || ' ' || l_task_detail.task_name || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_DESCRIPTION') || '</B></TD>';
    l_message := l_message || '<TD>' || l_task_detail.task_desc || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_N_SCH_START') || '</B></TD>';
    l_message := l_message || '<TD>' || to_char(getClientTime(l_task_detail.sch_st_date,
                                                getUserId(l_resource_id, l_resource_type)), 'DD-MON-YYYY HH24:MI')
                                                || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_O_SCH_START') || '</B></TD>';
    l_message := l_message || '<TD>' || to_char(getClientTime(l_task_detail.old_sch_st_date,
                                                getUserId(l_resource_id, l_resource_type)), 'DD-MON-YYYY HH24:MI')
                                                || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_N_SCH_END') || '</B></TD>';
    l_message := l_message || '<TD>' || to_char(getClientTime(l_task_detail.sch_end_date,
                                                getUserId(l_resource_id, l_resource_type)), 'DD-MON-YYYY HH24:MI')
                                                || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_O_SCH_END') || '</B></TD>';
    l_message := l_message || '<TD>' || to_char(getClientTime(l_task_detail.old_sch_end_date,
                                                getUserId(l_resource_id, l_resource_type)), 'DD-MON-YYYY HH24:MI')
                                                || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_PLANNED_EFFORT') || '</B></TD>';
    l_message := l_message || '<TD>' || l_task_detail.planned_effort || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '<TR>';
    l_message := l_message || '<TD><B>' || getPrompt('CSF_ALERTS_PRIORITY') || '</B></TD>';
    l_message := l_message || '<TD>' || l_task_detail.priority || '</TD>';
    l_message := l_message || '</TR>';
    l_message := l_message || '</TABLE>';
    l_message := l_message || '</P>';
    l_message := l_message || '<P><B>' || getPrompt('CSF_ALERTS_SERVICE_REQUEST') || ':</B>';
    l_message := l_message || l_task_detail.sr_number || ' ' || l_task_detail.sr_summary;
    l_message := l_message || '</P>';

    if l_task_detail.product_nr is not null then
      l_message := l_message || '<P><B>' || getPrompt('CSF_ALERTS_ITEM') || '</B>: ' || l_task_detail.product_nr || ', ' || l_task_detail.item_description;
      if l_task_detail.item_serial is not null then
        l_message := l_message || '(' || l_task_detail.item_serial || ')';
      end if;
      l_message := l_message || '</P>';
    end if;

    l_message := l_message || '<P><B>' || getPrompt('CSF_ALERTS_CUSTOMER') || '</B>:<BR/>';
    l_message := l_message || l_task_detail.cust_name || '<BR/>';
    l_message := l_message || l_task_detail.cust_address || '<BR/>';

    if l_task_detail.contact_name is not null then
      l_message := l_message || '<B>' || getPrompt('CSF_ALERTS_CONTACT') || '</B>: ' || l_task_detail.contact_name || '<BR/>';
      l_message := l_message || l_task_detail.contact_phone || ' ' || l_task_detail.contact_email;
    end if;

    l_message := l_message || '</P>';

    -- notes
    l_is_notes := 'N';

    open c_notes(p_task_id);
    loop
      fetch c_notes into l_notes;
      exit when c_notes%NOTFOUND;

      if l_is_notes = 'N' then
        l_message := l_message || '<P><B>' || getPrompt('CSF_ALERTS_NOTES') || ':</B></P>';
        l_is_notes := 'Y';
      end if;

      l_message := l_message || l_notes || '<BR/>';

    end loop;
    close c_notes;

  else

    l_message := '';
    l_message := l_message || '
    ' || l_message_header;
    l_message := l_message || '
    ' || '
    ' || getPrompt('CSF_ALERTS_TASK_DETAILS') || ':';
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_TASK') || ': ';
    l_message := l_message || l_task_detail.task_number || ' ' || l_task_detail.task_name;
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_DESCRIPTION') || ': ';
    l_message := l_message || l_task_detail.task_desc;
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_N_SCH_START') || ': ';
    l_message := l_message || to_char(getClientTime(l_task_detail.sch_st_date,
                                        getUserId(l_resource_id, l_resource_type)), 'DD-MON-YYYY HH24:MI');
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_O_SCH_START') || ': ';
    l_message := l_message || to_char(getClientTime(l_task_detail.old_sch_st_date,
                                        getUserId(l_resource_id, l_resource_type)), 'DD-MON-YYYY HH24:MI');
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_N_SCH_END') || ': ';
    l_message := l_message || to_char(getClientTime(l_task_detail.sch_end_date,
                                        getUserId(l_resource_id, l_resource_type)), 'DD-MON-YYYY HH24:MI');
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_O_SCH_END') || ': ';
    l_message := l_message || to_char(getClientTime(l_task_detail.old_sch_end_date,
                                        getUserId(l_resource_id, l_resource_type)), 'DD-MON-YYYY HH24:MI');
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_PLANNED_EFFORT') || ': ';
    l_message := l_message || l_task_detail.planned_effort;
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_PRIORITY') || ': ';
    l_message := l_message || l_task_detail.priority;
    l_message := l_message || '
    ' || getPrompt('CSF_ALERTS_SERVICE_REQUEST') || ': ';
    l_message := l_message || l_task_detail.sr_number || ' ' || l_task_detail.sr_summary;

    if l_task_detail.product_nr is not null then
      l_message := l_message || '
      ' || '
      ' || getPrompt('CSF_ALERTS_ITEM') || ': ' || l_task_detail.product_nr || ', ' || l_task_detail.item_description;
      if l_task_detail.item_serial is not null then
        l_message := l_message || '(' || l_task_detail.item_serial || ')';
      end if;
    end if;

    l_message := l_message || '
    ' || '
    ' || getPrompt('CSF_ALERTS_CUSTOMER') || ': ';
    l_message := l_message || '
    ' || l_task_detail.cust_name;
    l_message := l_message || '
    ' || l_task_detail.cust_address;

    if l_task_detail.contact_name is not null then
      l_message := l_message || '
      ' || getPrompt('CSF_ALERTS_CONTACT') || ': ' || l_task_detail.contact_name;
      l_message := l_message || l_task_detail.contact_phone || ' ' || l_task_detail.contact_email;
    end if;

    -- notes
    l_is_notes := 'N';

    open c_notes(p_task_id);
    loop
      fetch c_notes into l_notes;
      exit when c_notes%NOTFOUND;

      if l_is_notes = 'N' then
        l_message := l_message || '
        ' || getPrompt('CSF_ALERTS_NOTES') || ':';
        l_is_notes := 'Y';
      end if;

      l_message := l_message || l_notes || '
      ';

    end loop;
    close c_notes;

  end if;

  fnd_global.APPS_INITIALIZE(user_id => l_tmp_user_id, resp_id => l_tmp_resp_id, resp_appl_id => l_tmp_resp_apps_id);

  document := l_message;

end;

function getPrompt (p_name varchar2) return varchar2 is
  l_return varchar2(100);
begin
  l_return := '';
  fnd_message.set_name('CSF', p_name);
  l_return := fnd_message.get;
  return l_return;
end;

function getContactDetail(p_incident_id number,
                      p_contact_type varchar2,
                      p_party_id number) return contact_record is

    l_contact contact_record;

    l_contact_name varchar2(100);
    l_contact_email varchar2(250);
    l_contact_phone varchar2(100);

    cursor c_EMP_contact(v_id number) is
    SELECT
      per.full_name contactname,
      per.email_address email,
      ph.phone_number phone_number
    FROM
      per_all_people_f per,
      per_phones ph
    WHERE
      per.person_id = v_id
      and per.person_id = ph.parent_id
      and ph.phone_type = 'W1'
      AND ph.parent_table = 'PER_ALL_PEOPLE_F'
      AND sysdate between nvl(per.effective_start_date, sysdate)
      and nvl(per.effective_end_date, sysdate);

    -- bug # 6630754
    -- relaced hz_party_relationships with hz_relationships
    cursor c_REL_contact(v_id number) is
    SELECT
      hp.person_first_name ||' '|| hp.person_last_name contactname,
      hp.email_address email
    FROM
      hz_relationships rel,
      hz_parties hp
    WHERE
      rel.party_id = v_id
      AND rel.subject_id = hp.party_id
      AND rel.subject_table_name = 'HZ_PARTIES'
      AND rel.subject_type = 'PERSON';

    cursor c_PERSON_contact(v_id number) is
      Select PARTY_NAME, EMAIL_ADDRESS from hz_parties where party_id = v_id;

    cursor c_rel_person_phone(v_incident_id number) is
    SELECT
      hcp.phone_country_code || ' ' || hcp.phone_area_code || ' ' || hcp.phone_number PHONE_NUMBER
    FROM
      cs_incidents_all_b      ci_all_b,
      cs_hz_sr_contact_points_v chscp,
      hz_contact_points       hcp
    WHERE
      ci_all_b.incident_id = chscp.incident_id
      AND chscp.contact_point_id = hcp.contact_point_id
      AND chscp.primary_flag = 'Y'
      AND hcp.contact_point_type = 'PHONE'
      AND ci_all_b.incident_id = v_incident_id;
begin

  if p_contact_type = 'EMPLOYEE' then

    open c_EMP_contact(p_party_id);
    fetch c_EMP_contact into l_contact_name, l_contact_email, l_contact_phone;
    close c_EMP_contact;

  elsif p_contact_type = 'PARTY_RELATIONSHIP' then

    open c_REL_contact(p_party_id);
    fetch c_REL_contact into l_contact_name, l_contact_email;
    close c_REL_contact;

    open c_rel_person_phone(p_incident_id);
    fetch c_rel_person_phone into l_contact_phone;
    close c_rel_person_phone;

  elsif p_contact_type = 'PERSON' then

    open c_PERSON_contact(p_party_id);
    fetch c_PERSON_contact into l_contact_name, l_contact_email;
    close c_PERSON_contact;

    open c_rel_person_phone(p_incident_id);
    fetch c_rel_person_phone into l_contact_phone;
    close c_rel_person_phone;

  end if;

  l_contact.contact_name := l_contact_name;
  l_contact.contact_email := l_contact_email;
  l_contact.contact_phone := l_contact_phone;

  return l_contact;

end;

function getTaskDetails(p_task_id number,
                        p_task_asgn_id number,
                         p_task_audit_id number) return task_asgn_record is

  l_task_asgn_record task_asgn_record;
  l_contact_record  contact_record;

  l_task_number     jtf_tasks_b.task_number%type;
  l_task_name       jtf_tasks_vl.task_name%type;
  l_task_desc       jtf_tasks_vl.description%type;
  l_sch_st_date     jtf_tasks_b.scheduled_start_date%type;
  l_old_sch_st_date jtf_tasks_b.scheduled_start_date%type;
  l_sch_end_date    jtf_tasks_b.scheduled_end_date%type;
  l_old_sch_end_date jtf_tasks_b.scheduled_end_date%type;
  l_planned_effort  varchar2(100);
  l_priority        jtf_task_priorities_vl.name%type;
  l_asgm_sts_name   jtf_task_statuses_vl.name%type;
  l_sr_number       cs_incidents_all_b.incident_number%type;
  l_sr_summary      cs_incidents_all_b.summary%type;
  l_product_nr      mtl_system_items_vl.concatenated_segments%type;
  l_item_serial     cs_customer_products_all.current_serial_number%type;
  l_item_description  mtl_system_items_vl.description%type;
  l_cust_name       hz_parties.party_name%type;
  l_cust_address    varchar2(1000);
  l_contact_name    varchar2(100);
  l_contact_phone   varchar2(100);
  l_contact_email   varchar2(250);
  l_contact_type    varchar2(200);
  l_contact_party_id  number;
  l_incident_id number;

  cursor c_task_assgn_detail (v_task_assgn_id number) is
    SELECT
      c_b.incident_id incident_id,
      c_b.incident_number sr_number,
      c_b.summary sr_summary,
      hp.party_name cust_name,
      hp.address1 || ', ' ||  hp.postal_code || ', ' || hp.city address,
      jtb.task_number task_number,
      j_vl.task_name task_name,
      js_vl.name assignment_name,
      jp_vl.name priority,
      j_vl.PLANNED_EFFORT || ' ' || j_vl.PLANNED_EFFORT_UOM planned_effort,
      jtb.scheduled_start_date sch_st_date,
      jtb.scheduled_end_date sch_end_date,
      j_vl.description task_desc,
      msi_b.concatenated_segments product_nr,
      ccp_all.current_serial_number item_serial,
      msi_b.description item_description,
      chscp.contact_type  contact_type,
      chscp.party_id contact_party_id
    FROM
      jtf_tasks_b jtb,
      jtf_task_assignments jta,
      jtf_tasks_vl j_vl,
      jtf_task_priorities_vl jp_vl,
      jtf_task_statuses_vl js_vl,
      cs_incidents_all c_b,
      hz_party_sites hps,
      hz_parties hp,
      mtl_system_items_vl msi_b,
      cs_customer_products_all ccp_all,
      cs_hz_sr_contact_points_v chscp
    WHERE
      jta.task_assignment_id =  v_task_assgn_id
      and jta.task_id = jtb.task_id
      and j_vl.task_id = jta.task_id
      and jp_vl.task_priority_id (+) = j_vl.task_priority_id
      and js_vl.task_status_id = jta.assignment_status_id
      and jtb.source_object_type_code = 'SR'
      and jtb.source_object_id = c_b.incident_id
      and jtb.address_id = hps.party_site_id
      and hps.party_id = hp.party_id
      and c_b.inventory_item_id = msi_b.inventory_item_id (+)
      and c_b.customer_product_id = ccp_all.customer_product_id(+)
      and msi_b.organization_id (+) = c_b.org_id
      and chscp.primary_flag (+) = 'Y'
      and chscp.incident_id (+)  = c_b.incident_id;

  cursor c_task_detail (v_task_id number) is
    SELECT
      c_b.incident_id incident_id,
      c_b.incident_number sr_number,
      c_b.summary sr_summary,
      hp.party_name cust_name,
      hp.address1 || ', ' ||  hp.postal_code || ', ' || hp.city address,
      jtb.task_number task_number,
      j_vl.task_name task_name,
      jp_vl.name priority,
      j_vl.PLANNED_EFFORT || ' ' || j_vl.PLANNED_EFFORT_UOM planned_effort,
      jtb.scheduled_start_date sch_st_date,
      jtb.scheduled_end_date sch_end_date,
      j_vl.description task_desc,
      msi_b.concatenated_segments product_nr,
      ccp_all.current_serial_number item_serial,
      msi_b.description item_description,
      chscp.contact_type  contact_type,
      chscp.party_id contact_party_id
    FROM
      jtf_tasks_b jtb,
      jtf_tasks_vl j_vl,
      jtf_task_priorities_vl jp_vl,
      cs_incidents_all c_b,
      hz_party_sites hps,
      hz_parties hp,
      mtl_system_items_vl msi_b,
      cs_customer_products_all ccp_all,
      cs_hz_sr_contact_points_v chscp
    WHERE
      jtb.task_id = v_task_id
      and j_vl.task_id = jtb.task_id
      and jp_vl.task_priority_id (+) = j_vl.task_priority_id
      and jtb.source_object_type_code = 'SR'
      and jtb.source_object_id = c_b.incident_id
      and jtb.address_id = hps.party_site_id
      and hps.party_id = hp.party_id
      and c_b.inventory_item_id = msi_b.inventory_item_id (+)
      and c_b.customer_product_id = ccp_all.customer_product_id(+)
      and msi_b.organization_id (+) = c_b.org_id
      and chscp.primary_flag (+) = 'Y'
      and chscp.incident_id (+) = c_b.incident_id;

  cursor c_task_audit_detail (v_task_id number, v_task_audit_id number) is
    SELECT
      c_b.incident_id incident_id,
      c_b.incident_number sr_number,
      c_b.summary sr_summary,
      hp.party_name cust_name,
      hp.address1 || ', ' ||  hp.postal_code || ', ' || hp.city address,
      jtb.task_number task_number,
      j_vl.task_name task_name,
      jp_vl.name priority,
      j_vl.PLANNED_EFFORT || ' ' || j_vl.PLANNED_EFFORT_UOM planned_effort,
      jtb.scheduled_start_date sch_st_date,
      jtb.scheduled_end_date sch_end_date,
      j_vl.description task_desc,
      msi_b.concatenated_segments product_nr,
      ccp_all.current_serial_number item_serial,
      msi_b.description item_description,
      chscp.contact_type  contact_type,
      chscp.party_id contact_party_id,
      jtab.old_scheduled_start_date old_sch_st_date,
      jtab.old_scheduled_end_date old_sch_end_date
    FROM
      jtf_tasks_b jtb,
      jtf_task_audits_b jtab,
      jtf_tasks_vl j_vl,
      jtf_task_priorities_vl jp_vl,
      cs_incidents_all c_b,
      hz_party_sites hps,
      hz_parties hp,
      mtl_system_items_vl msi_b,
      cs_customer_products_all ccp_all,
      cs_hz_sr_contact_points_v chscp
    WHERE
      jtb.task_id = v_task_id
      and jtab.task_audit_id = v_task_audit_id
      and jtab.task_id = jtb.task_id
      and j_vl.task_id = jtb.task_id
      and jp_vl.task_priority_id (+) = j_vl.task_priority_id
      and jtb.source_object_type_code = 'SR'
      and jtb.source_object_id = c_b.incident_id
      and jtb.address_id = hps.party_site_id
      and hps.party_id = hp.party_id
      and c_b.inventory_item_id = msi_b.inventory_item_id (+)
      and c_b.customer_product_id = ccp_all.customer_product_id(+)
      and msi_b.organization_id (+) = c_b.org_id
      and chscp.primary_flag (+) = 'Y'
      and chscp.incident_id (+) = c_b.incident_id;
begin


  if p_task_asgn_id is not null then

    open c_task_assgn_detail(p_task_asgn_id);
    fetch c_task_assgn_detail into
                      l_incident_id,
                      l_sr_number,
                      l_sr_summary,
                      l_cust_name,
                      l_cust_address,
                      l_task_number,
                      l_task_name,
                      l_asgm_sts_name,
                      l_priority,
                      l_planned_effort,
                      l_sch_st_date,
                      l_sch_end_date,
                      l_task_desc,
                      l_product_nr,
                      l_item_serial,
                      l_item_description,
                      l_contact_type,
                      l_contact_party_id;
    close c_task_assgn_detail;

    l_contact_record := getContactDetail(l_incident_id,
                                          l_contact_type,
                                          l_contact_party_id);

    l_task_asgn_record.task_number := l_task_number;
    l_task_asgn_record.task_name := l_task_name;
    l_task_asgn_record.task_desc := l_task_desc;
    l_task_asgn_record.sch_st_date := l_sch_st_date;
    l_task_asgn_record.sch_end_date := l_sch_end_date;
    l_task_asgn_record.planned_effort := l_planned_effort;
    l_task_asgn_record.priority := l_priority;
    l_task_asgn_record.asgm_sts_name := l_asgm_sts_name;
    l_task_asgn_record.sr_number := l_sr_number;
    l_task_asgn_record.sr_summary := l_sr_summary;
    l_task_asgn_record.product_nr := l_product_nr;
    l_task_asgn_record.item_serial := l_item_serial;
    l_task_asgn_record.item_description := l_item_description;
    l_task_asgn_record.cust_name := l_cust_name;
    l_task_asgn_record.cust_address := l_cust_address;
    l_task_asgn_record.contact_name := l_contact_record.contact_name;
    l_task_asgn_record.contact_phone := l_contact_record.contact_phone;
    l_task_asgn_record.contact_email := l_contact_record.contact_email;

  elsif p_task_id is not null and p_task_audit_id is null then

    open c_task_detail(p_task_id);
    fetch c_task_detail into
                      l_incident_id,
                      l_sr_number,
                      l_sr_summary,
                      l_cust_name,
                      l_cust_address,
                      l_task_number,
                      l_task_name,
                      l_priority,
                      l_planned_effort,
                      l_sch_st_date,
                      l_sch_end_date,
                      l_task_desc,
                      l_product_nr,
                      l_item_serial,
                      l_item_description,
                      l_contact_type,
                      l_contact_party_id;
    close c_task_detail;

    l_contact_record := getContactDetail(l_incident_id,
                                          l_contact_type,
                                          l_contact_party_id);

    l_task_asgn_record.task_number := l_task_number;
    l_task_asgn_record.task_name := l_task_name;
    l_task_asgn_record.task_desc := l_task_desc;
    l_task_asgn_record.sch_st_date := l_sch_st_date;
    l_task_asgn_record.sch_end_date := l_sch_end_date;
    l_task_asgn_record.planned_effort := l_planned_effort;
    l_task_asgn_record.priority := l_priority;
    l_task_asgn_record.sr_number := l_sr_number;
    l_task_asgn_record.sr_summary := l_sr_summary;
    l_task_asgn_record.product_nr := l_product_nr;
    l_task_asgn_record.item_serial := l_item_serial;
    l_task_asgn_record.item_description := l_item_description;
    l_task_asgn_record.cust_name := l_cust_name;
    l_task_asgn_record.cust_address := l_cust_address;
    l_task_asgn_record.contact_name := l_contact_record.contact_name;
    l_task_asgn_record.contact_phone := l_contact_record.contact_phone;
    l_task_asgn_record.contact_email := l_contact_record.contact_email;

  elsif p_task_id is not null and p_task_audit_id is not null then

    open c_task_audit_detail(p_task_id, p_task_audit_id);
    fetch c_task_audit_detail into
                      l_incident_id,
                      l_sr_number,
                      l_sr_summary,
                      l_cust_name,
                      l_cust_address,
                      l_task_number,
                      l_task_name,
                      l_priority,
                      l_planned_effort,
                      l_sch_st_date,
                      l_sch_end_date,
                      l_task_desc,
                      l_product_nr,
                      l_item_serial,
                      l_item_description,
                      l_contact_type,
                      l_contact_party_id,
                      l_old_sch_st_date,
                      l_old_sch_end_date;
    close c_task_audit_detail;

    l_contact_record := getContactDetail(l_incident_id,
                                          l_contact_type,
                                          l_contact_party_id);

    l_task_asgn_record.task_number := l_task_number;
    l_task_asgn_record.task_name := l_task_name;
    l_task_asgn_record.task_desc := l_task_desc;
    l_task_asgn_record.sch_st_date := l_sch_st_date;
    l_task_asgn_record.sch_end_date := l_sch_end_date;
    l_task_asgn_record.planned_effort := l_planned_effort;
    l_task_asgn_record.priority := l_priority;
    l_task_asgn_record.sr_number := l_sr_number;
    l_task_asgn_record.sr_summary := l_sr_summary;
    l_task_asgn_record.product_nr := l_product_nr;
    l_task_asgn_record.item_serial := l_item_serial;
    l_task_asgn_record.item_description := l_item_description;
    l_task_asgn_record.cust_name := l_cust_name;
    l_task_asgn_record.cust_address := l_cust_address;
    l_task_asgn_record.contact_name := l_contact_record.contact_name;
    l_task_asgn_record.contact_phone := l_contact_record.contact_phone;
    l_task_asgn_record.contact_email := l_contact_record.contact_email;
    l_task_asgn_record.old_sch_st_date := l_old_sch_st_date;
    l_task_asgn_record.old_sch_end_date := l_old_sch_end_date;

  end if;

  return l_task_asgn_record;
end;

function getClientTime (p_server_time date,
                          p_user_id number) return date is
  l_client_tz_id  number;
  l_server_tz_id  number;
  l_msg_count     number;
  l_status        varchar2(1);
  x_client_time   date;
  l_msg_data      varchar2(2000);

begin

  IF (fnd_timezones.timezones_enabled <> 'Y') THEN
          return p_server_time;
  END IF;

  l_client_tz_id := to_number(fnd_profile.VALUE_SPECIFIC('CLIENT_TIMEZONE_ID',
                                                                    p_user_id,
                                                                    21685,
                                                                    513,
                                                                    null,
                                                                    null));

  l_server_tz_id := to_number(fnd_profile.VALUE_SPECIFIC('SERVER_TIMEZONE_ID',
                                                                    p_user_id,
                                                                    21685,
                                                                    513,
                                                                    null,
                                                                    null));

  HZ_TIMEZONE_PUB.GET_TIME(1.0,
                            'F',
                            l_server_tz_id,
                            l_client_tz_id,
                            p_server_time,
                            x_client_time,
                            l_status,
                            l_msg_count,
                            l_msg_data);

  return x_client_time;

end;

-- Returns WF ROLE NAME
-- Bug # 5245611
function getWFRole (p_resource_id number) return varchar2 is

  l_wf_role_name  varchar2(150) := NULL;
  cursor c_check_user_name (v_resource_id number) is
  select
    j.user_name
  from
    jtf_rs_resource_extns j,
    wf_roles w
  where
    j.resource_id =  v_resource_id
    and j.user_name = w.name;

begin

  open c_check_user_name(p_resource_id);
  fetch c_check_user_name into l_wf_role_name;
  close c_check_user_name;

  if l_wf_role_name is NULL
  then
    l_wf_role_name := JTF_RS_WF_INTEGRATION_PUB.get_wf_role(p_resource_id);
  end if;

  return l_wf_role_name;

end;

END csf_alerts_pub;

/
