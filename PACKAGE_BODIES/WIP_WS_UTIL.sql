--------------------------------------------------------
--  DDL for Package Body WIP_WS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WS_UTIL" as
/* $Header: wipwsutb.pls 120.25.12010000.5 2010/01/05 01:36:15 hliew ship $ */

  --Bug 6889755 Component Shortage Constants
  ORG_CALCULATION_LEVEL   CONSTANT NUMBER := 1;
  SUBINV_CALCULATION_LEVEL  CONSTANT NUMBER := 2;
  --End Bug 6889755

  function get_instance_name(p_instance_name varchar2, p_serial_number varchar2)
  return VARCHAR2
  IS
  begin

    if( p_serial_number is not null) then
      fnd_message.SET_NAME('WIP', 'WIP_WS_INSTANCE_NAME');
      fnd_message.SET_TOKEN('INSTANCE', p_instance_name);
      fnd_message.SET_TOKEN('SERIAL', p_serial_number);
      return fnd_message.GET;
    else
      return p_instance_name;
    end if;
  end;

  function get_preference_value_code(
    p_pref_id number,
    p_resp_key varchar2,
    p_org_id number,
    p_dept_id number
  ) return varchar2
  Is
  Begin
    return
      get_preference_value_code
      (
        p_pref_id,
        get_preference_level_id(p_pref_id, p_resp_key, p_org_id, p_dept_id)
      );
  End get_preference_value_code;

  function get_preference_level_id(
    p_pref_id number,
    p_resp_key varchar2,
    p_org_id number,
    p_dept_id number
  ) return number
  IS
    l_level_code number;
    l_module_id number;
    l_level_id number;
  BEGIN
    /* get the module id from preference */
    select wp.module_id
    into l_module_id
    from wip_preference_definitions wp
    where wp.preference_id = p_pref_id;

    /* get the level code */
    /* 0 - site, 1 - role, 2 - org, 3 - dept */
    l_level_code := 0;
    /* Check the case where org_id is not null but role_id is null
       that means role_id is not used in that app */
    if( p_resp_key is not null or p_org_id is not null) then
      l_level_code := 1;
      if( p_org_id is not null) then
        l_level_code := 2;
        if( p_dept_id is not null) then
          l_level_code := 3;
        end if;
      end if;
    end if;

    /* find out the level_id */
    select level_id
    into l_level_id
    from
    (
      select level_id
      from wip_preference_levels v
      where
        v.module_id = l_module_id and
        v.level_code <= l_level_code and
        ( v.resp_key is null or v.resp_key = p_resp_key) and
        ( v.organization_id is null or v.organization_id = p_org_id) and
        ( v.department_id is null or v.department_id = p_dept_id) and
        exists
        (
          select 1
             from wip_preference_values v1
             where v1.preference_id = p_pref_id and
               v1.level_id = v.level_id
        )
        order by v.level_code desc
       )
    where rownum = 1;

    return l_level_id;

  exception when others then
    return null;
  END;


  function get_preference_value_code(p_pref_id number, p_level_id number) return varchar2
  is
    l_result VARCHAR2(30) := null;
  begin

    BEGIN
      select wpv.attribute_value_code
      into l_result
      from wip_preference_values wpv
      where wpv.preference_id = p_pref_id and
        wpv.level_id = p_level_id and
        rownum = 1;
    Exception
      When others then
      null;
    END;

    return(l_result);
  end get_preference_value_code;


  function get_jobop_name(p_job_name varchar2, p_op_seq number) return varchar2
  is
  begin
    fnd_message.SET_NAME('WIP', 'WIP_WS_JOBOP_FORMAT');
    fnd_message.SET_TOKEN('JOB', p_job_name);
    fnd_message.SET_TOKEN('OP', p_op_seq);
    return fnd_message.GET;

  end get_jobop_name;


procedure retrieve_first_shift
(
  p_org_id number,
  p_dept_id number,
  p_resource_id number,
  p_date date,
  x_shift_seq out nocopy number,
  x_shift_num out nocopy number,
  x_shift_start_date out nocopy date,
  x_shift_end_date out nocopy date,
  x_shift_string out nocopy varchar2
)
Is
  l_cal_code varchar2(10);

  l_c_start_date date;
  l_c_end_date date;
  l_c_from_time varchar2(60);
  l_c_to_time varchar2(60);
  l_24hr_resource number;

  l_in_date date;
Begin

  /* if the date is null, use sysdate */
  if( p_date is null ) then
    l_in_date := sysdate;
  else
    l_in_date := p_date;
  end if;

  l_cal_code := get_calendar_code(p_org_id);


  if( p_resource_id is not null ) then /* test if it has shifts or not */
    select bdr.available_24_hours_flag
    into l_24hr_resource
    from bom_department_resources bdr
    where bdr.resource_id = p_resource_id and
          bdr.department_id = p_dept_id;
  else
    l_24hr_resource := 2;
  end if;

  if( l_24hr_resource = 2 ) then
    wip_ws_dl_util.get_first_shift(l_cal_code, p_dept_id, p_resource_id, l_in_date,
      x_shift_seq, x_shift_num, x_shift_start_date, x_shift_end_date);
  else
    wip_ws_dl_util.get_first_calendar_date(l_cal_code, l_in_date,
      x_shift_seq, x_shift_start_date, x_shift_end_date);
    x_shift_num := null;
  end if;

  /* seem we have re-read the timezone profile to be synch with oa */
  init_timezone;

  if ( g_timezone_enabled ) then
    l_c_start_date := hz_timezone_pub.convert_datetime(
                    g_server_id,
                    g_client_id,
                    x_shift_start_date
                  );
    l_c_end_date := hz_timezone_pub.convert_datetime(
                    g_server_id,
                    g_client_id,
                    x_shift_end_date
                  );
  else
    l_c_start_date := x_shift_start_date;
    l_c_end_date := x_shift_end_date;
  end if;

  select to_char(l_c_start_date, 'HH24:MI:SS')
  into l_c_from_time
  from dual;

  select to_char(l_c_end_date, 'HH24:MI:SS')
  into l_c_to_time
  from dual;

  fnd_message.SET_NAME('WIP', 'WIP_WS_SHIFT_INFO');
  fnd_message.SET_TOKEN('SHIFT_NUM', x_shift_num);
  fnd_message.SET_TOKEN('FROM_TIME', l_c_from_time);
  fnd_message.SET_TOKEN('TO_TIME', l_c_to_time);

  x_shift_string := fnd_message.GET;

--exception when others then
--  null;
End retrieve_first_shift;

function get_component_avail(p_org_id number, p_component_id number)
return number
Is
  l_is_revision_control boolean;
  l_is_lot_control boolean;
  l_is_serial_control boolean;
  l_lot_control_code number;
  l_revision_control_code number;
  l_serial_control_code number;

  x_qoh number;
  x_rqoh number;
  x_qr number;
  x_qs number;
  x_att number;
  x_atr number;

  x_return_status varchar2(2);
  x_msg_count number;
  x_msg_data varchar2(256);
begin
  select msi.revision_qty_control_code,
         msi.lot_control_code,
         msi.serial_number_control_code
  into l_revision_control_code, l_lot_control_code, l_serial_control_code
  from mtl_system_items_b msi
  where msi.organization_id = p_org_id
    and msi.inventory_item_id = p_component_id;

  if ( l_lot_control_code =  WIP_CONSTANTS.LOT ) then
    l_is_lot_control := true;
  else
    l_is_lot_control := false;
  end if;

  if( l_revision_control_code =  WIP_CONSTANTS.REV ) then
    l_is_revision_control := true;
  else
   l_is_revision_control := false;
  end if;

  if( l_serial_control_code in (WIP_CONSTANTS.FULL_SN, WIP_CONSTANTS.DYN_RCV_SN) ) then
    l_is_serial_control := true;
  else
    l_is_serial_control := false;
  end if;

  fnd_msg_pub.Delete_Msg;

  -- Call the procedure
  inv_quantity_tree_pub.query_quantities(p_api_version_number => 1.0,
                                         p_init_msg_lst => 'T',
                                         x_return_status => x_return_status,
                                         x_msg_count => x_msg_count,
                                         x_msg_data => x_msg_data,
                                         p_organization_id => p_org_id,
                                         p_inventory_item_id => p_component_id,
                                         p_tree_mode => 2,
                                         p_is_revision_control => l_is_revision_control,
                                         p_is_lot_control => l_is_lot_control,
                                         p_is_serial_control => l_is_serial_control,
                                         p_lot_expiration_date => sysdate,
                                         p_revision => null,
                                         p_lot_number => null,
                                         p_subinventory_code => null,
                                         p_locator_id => null,
                                         p_onhand_source => 3,
                                         x_qoh => x_qoh,
                                         x_rqoh => x_rqoh,
                                         x_qr => x_qr,
                                         x_qs => x_qs,
                                         x_att => x_att,
                                         x_atr => x_atr
                                         );

  /* call to clear the in memory cache */
  inv_quantity_tree_pub.clear_quantity_cache;

  return x_att;
end get_component_avail;

function get_employee_name(p_employee_id number, p_date date)
return varchar2
Is
  l_name varchar2(256);
  l_date date;
Begin
  l_date := nvl(p_date, sysdate);

  Begin
    select papf.full_name
    into l_name
    from per_all_people_f papf
    where papf.person_id = p_employee_id and
          papf.effective_start_date <= l_date and
          papf.effective_end_date > l_date;
  Exception when others then
    l_name := '';
  End;

  if( l_name is null ) then
  Begin
    select papf.full_name
    into l_name
    from per_all_people_f papf
    where papf.person_id = p_employee_id
    and rownum = 1;
  Exception when others then
    l_name := null;
  End;
  End if;

  return l_name;
end   get_employee_name;


function get_employee_id(p_employee_number varchar2, p_org_id number)
return number
Is
  l_emp_id number;
  l_count number;
Begin

  SELECT count(distinct p.person_id), min(p.PERSON_ID)
  into l_count, l_emp_id
  FROM PER_PEOPLE_F          P,
       PER_ASSIGNMENTS_F     A,
       PER_PERSON_TYPES      T,
       HR_ORGANIZATION_UNITS ORG
 WHERE A.PERSON_ID = P.PERSON_ID AND
       ORG.BUSINESS_GROUP_ID = P.BUSINESS_GROUP_ID AND
       A.PRIMARY_FLAG = 'Y' AND
       A.ASSIGNMENT_TYPE = 'E' AND
       P.PERSON_TYPE_ID = T.PERSON_TYPE_ID AND
       P.BUSINESS_GROUP_ID = T.BUSINESS_GROUP_ID AND
       TRUNC(sysdate) BETWEEN P.EFFECTIVE_START_DATE AND
       NVL(P.EFFECTIVE_END_DATE, SYSDATE + 1) AND
       TRUNC(sysdate) BETWEEN A.EFFECTIVE_START_DATE AND
       NVL(A.EFFECTIVE_END_DATE, SYSDATE + 1) AND
       P.EMPLOYEE_NUMBER IS NOT NULL AND
       P.EMPLOYEE_NUMBER = p_employee_number AND
       ORG.ORGANIZATION_ID = p_org_id;

   if( l_count > 1 ) then
     l_emp_id := -1;
   end if;

  return l_emp_id;

Exception when others then
  return null;
End get_employee_id;

function get_first_workday(p_org_id number, p_dept_id number, p_date date)
return date
Is
  l_in_date date;

  x_shift_seq number;
  x_shift_num number;
  x_shift_start_date date;
  x_shift_end_date date;

Begin

  /* if the date is null, use sysdate */
  l_in_date := nvl(p_date, sysdate);

  wip_ws_dl_util.get_first_shift(get_calendar_code(p_org_id), p_dept_id, null, l_in_date,
    x_shift_seq, x_shift_num, x_shift_start_date, x_shift_end_date);

  return trunc(x_shift_start_date);

End get_first_workday;

function get_appended_date(p_date date, p_time number)
return date
Is
Begin
  return (p_date + p_time/(24*60*60));
end get_appended_date;

function get_next_date(p_date date)
return date
Is
Begin
  return (p_date + 1);
end get_next_date;

function get_next_work_date_by_calcode(p_calendar_code varchar2, p_date date) return date
is
  l_next_working_date date;
begin
  if (p_date is null) then
    return null;
  end if;

  select min(bsd.shift_date)
    into l_next_working_date
    from bom_shift_dates bsd
    where bsd.calendar_code = p_calendar_code
      and bsd.shift_date > trunc(p_date,'ddd')
      and bsd.seq_num is not null;

return l_next_working_date;
end get_next_work_date_by_calcode;

function get_next_work_date_by_org_id(p_org_id number, p_date date) return date
is
begin
  return get_next_work_date_by_calcode(get_calendar_code(p_org_id),p_date);
end get_next_work_date_by_org_id;

function get_calendar_code(p_org_id number) return varchar2
is
  l_calendar_code varchar2(10);
begin
  select calendar_code
  into l_calendar_code
  from mtl_parameters
  where organization_id = p_org_id;

  return l_calendar_code;
end get_calendar_code;

function get_shift_info_for_display(p_org_id number, p_shift_seq number, p_shift_num number)
return varchar2
Is
  l_info varchar(256);
  l_start_date date;
  l_end_date date;

  l_from_date date;
  l_to_date date;
Begin

  if( p_shift_seq is null ) then
    l_info := null;
  elsif ( p_shift_num is not null ) then
    select bsd.shift_date + at.from_time /(24*60*60),
           bsd.shift_date + at.to_time/(24*60*60)
    into l_start_date, l_end_date
    from bom_shift_dates bsd,
      (select min(bst.from_time) from_time,
              max(bst.to_time + decode(sign(to_time - from_time), -1, 24*60*60, 0)) to_time,
              mp.calendar_code
       from bom_shift_times bst, mtl_parameters mp
       where bst.calendar_code = mp.calendar_code and
             mp.organization_id = p_org_id and
             bst.shift_num = p_shift_num
       group by mp.calendar_code
      ) at
    where bsd.calendar_code = at.calendar_code and
          bsd.exception_set_id = -1 and
          bsd.seq_num = p_shift_seq and
          bsd.shift_num = p_shift_num;

    if ( g_timezone_enabled ) then
      l_from_date := hz_timezone_pub.convert_datetime(
                    g_server_id,
                    g_client_id,
                    l_start_date
                  );
      l_to_date := hz_timezone_pub.convert_datetime(
                    g_server_id,
                    g_client_id,
                    l_end_date
                  );
    else
      l_from_date := l_start_date;
      l_to_date := l_end_date;
    end if;
    fnd_message.SET_NAME('WIP', 'WIP_WS_HOME_SHIFT_INFO_F');
    fnd_message.SET_TOKEN('NUM', p_shift_num);
    fnd_message.SET_TOKEN('FROM', fnd_date.date_to_displayDT(l_from_date) );
    fnd_message.SET_TOKEN('TO', fnd_date.date_to_displayDT(l_to_date) );
    l_info := fnd_message.GET;
  else
    l_info := null;
  end if;


  return l_info;
End get_shift_info_for_display;

function get_job_note_header(p_wip_entity_id number, p_op_seq number, p_employee_id number)
return varchar2
Is
 l_header varchar2(1024);
 l_emp_name varchar2(256);
 l_dept_code varchar2(30) := null;
 l_date date;
 l_date_str varchar2(256);
Begin

  l_emp_name := wip_ws_util.get_employee_name(p_employee_id, null);

  /* seem we have re-read the timezone profile to be synch with oa */
  init_timezone;

  if ( g_timezone_enabled ) then
    l_date := hz_timezone_pub.convert_datetime(
                    g_server_id,
                    g_client_id,
                    sysdate);
  else
    l_date := sysdate;
  end if;

  l_date_str := fnd_date.date_to_displayDT(l_date);

  if( p_op_seq is not null ) then
    select bd.department_code
    into l_dept_code
    from wip_operations wo, bom_departments bd
    where wo.department_id = bd.department_id
      and wo.wip_entity_id = p_wip_entity_id
      and wo.operation_seq_num = p_op_seq;

    fnd_message.set_name('WIP', 'WIP_WS_JOB_NOTE_HDR');
    fnd_message.SET_token('EMP', l_emp_name);
    fnd_message.SET_TOKEN('DATE', l_date_str);
    fnd_message.set_token('OP', p_op_seq);
    fnd_message.set_token('DEPT', l_dept_code);
    fnd_message.set_token('TZ', fnd_timezones.get_client_timezone_code);
    l_header := fnd_message.GET;
  else
    fnd_message.set_name('WIP', 'WIP_WS_JOB_NOTE_HDR_JOB');
    fnd_message.SET_token('EMP', l_emp_name);
    fnd_message.SET_TOKEN('DATE', l_date_str);
    fnd_message.set_token('TZ', fnd_timezones.get_client_timezone_code);
    l_header := fnd_message.GET;

  end if;

  return l_header;

Exception when others then
  return null;
end get_job_note_header;

  procedure clear_msg_stack
  Is
  Begin
    fnd_msg_pub.Initialize;

  End clear_msg_stack;

  function get_current_resp_key return varchar2
  Is
    l_resp_key varchar2(256);
  Begin
    select fr.responsibility_key
    into l_resp_key
    from fnd_responsibility fr
    where fr.responsibility_id = fnd_global.RESP_ID
      and fr.application_id = fnd_global.RESP_APPL_ID
      and rownum = 1;

    return l_resp_key;
  Exception when others then
    return null;
  end get_current_resp_key;

  procedure append_job_note(p_wip_entity_id number, p_msg varchar2,
                              p_init_msg_list IN VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2)
  Is
  Begin

    IF p_init_msg_list IS NOT NULL AND FND_API.TO_BOOLEAN(p_init_msg_list)
    THEN
      FND_MSG_PUB.initialize;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    update wip_discrete_jobs wdj
    set wdj.job_note = wdj.job_note || p_msg
    where wdj.wip_entity_id = p_wip_entity_id;

  exception when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg ('wip_ws_util' ,'append_job_note');
      END IF;

      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count ,p_data => x_msg_data);
  end append_job_note;

  procedure append_job_note(p_wip_entity_id number, p_clob_msg clob,
                              p_init_msg_list IN VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2)
  Is
    job_note clob;
  Begin

    IF p_init_msg_list IS NOT NULL AND FND_API.TO_BOOLEAN(p_init_msg_list)
    THEN
      FND_MSG_PUB.initialize;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select wdj.job_note
    into job_note
    from wip_discrete_jobs wdj
    where wdj.wip_entity_id = p_wip_entity_id
    for update;

    dbms_lob.append(job_note, p_clob_msg);

    commit;

  exception when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg ('wip_ws_util' ,'append_job_note');
      END IF;

      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count ,p_data => x_msg_data);
  end append_job_note;

  procedure append_exception_note(p_exception_id number, p_msg varchar2,
                              p_init_msg_list IN VARCHAR2,
                              x_return_status OUT NOCOPY VARCHAR2,
                              x_msg_count OUT NOCOPY NUMBER,
                              x_msg_data OUT NOCOPY VARCHAR2)
  Is
    l_note CLOB;

    Begin

    IF p_init_msg_list IS NOT NULL AND FND_API.TO_BOOLEAN(p_init_msg_list)
    THEN
      FND_MSG_PUB.initialize;
    END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    select note into l_note from wip_exceptions
    where exception_id = p_exception_id;

    if(l_note is null OR l_note ='') then
      l_note := p_msg;
    else
      l_note := l_note ||'<br><br>'||p_msg;
    end if;

    update wip_exceptions we
    set we.note = l_note
    where we.exception_id = p_exception_id;

  exception when others then
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg ('wip_ws_util' ,'append_exception_note');
      END IF;

      FND_MSG_PUB.Count_And_Get (p_count => x_msg_count ,p_data => x_msg_data);
  end append_exception_note;


  function get_resource_remaining_usage
  (
    p_organization_id number,
    p_wip_entity_id number,
    p_op_seq_num number,
    p_department_id number,
    p_resource_seq_num number,
    p_resource_id number
  ) return number
  Is
    l_remaining_usage number;
    l_req_usage number;

    l_used_usage number;
  Begin

    l_remaining_usage := null;

    if( p_resource_seq_num is not null ) then
      l_req_usage := wip_ws_dl_util.get_col_res_usage_req(
        p_wip_entity_id, p_op_seq_num, p_department_id, p_resource_id, p_resource_seq_num);

      l_remaining_usage := nvl(l_req_usage, 0) - 0;
    end if;

    return l_remaining_usage;
  End get_resource_remaining_usage;

  function project_resource_end_date
  (
    p_organization_id number,
    p_department_id number,
    p_resource_id number,
    p_start_date date,
    p_duration_hrs number
  ) return date
  Is
    cursor c_shift_periods(p_cal_code varchar2, p_date date, p_dept_id number, p_resource_id number)
    is
      select bsd.shift_date, bst.from_time, bst.to_time
      from bom_shift_dates bsd, bom_resource_shifts brs,
           bom_shift_times bst, mtl_parameters mp
      where mp.organization_id = p_organization_id and
            bsd.calendar_code = p_cal_code and
            bsd.exception_set_id = mp.calendar_exception_set_id and
            bsd.shift_date >= trunc(p_date) - 1 and
            bsd.shift_date + bst.to_time/(24*60*60) +
              decode(sign(bst.to_time - bst.from_time), -1, 1, 0) > p_date and
            brs.department_id = p_dept_id and
            brs.resource_id = p_resource_id and
            brs.shift_num = bsd.shift_num and
            bst.shift_num = brs.shift_num and
            bst.calendar_code = bsd.calendar_code and
            bsd.seq_num is not null
       order by bsd.shift_date + bst.from_time/(24*60*60);

    l_end_date date;

    l_remaining_duration number;
    l_new_start_date date;

    l_24hr_resource number;

    l_shift_date date;
    l_from_time number;
    l_to_time number;

    l_period_start_date date;
    l_period_end_date date;
  Begin

    if( p_duration_hrs <= 0 ) then
      l_end_date := p_start_date;
    else
      l_remaining_duration := p_duration_hrs / 24;
      l_new_start_date := p_start_date;

      select bdr.available_24_hours_flag
      into l_24hr_resource
      from bom_department_resources bdr
      where bdr.department_id = p_department_id
        and bdr.resource_id = p_resource_id;

      if( l_24hr_resource = 1 /*yes*/ ) then

        l_new_start_date := p_start_date + l_remaining_duration;

      else


        open c_shift_periods(get_calendar_code(p_organization_id), p_start_date, p_department_id, p_resource_id);


        loop
          fetch c_shift_periods
          into l_shift_date, l_from_time, l_to_time;

          exit when c_shift_periods%NOTFOUND;

--          dbms_output.put_line('start=' || to_char(l_new_start_date, 'YYYY/MM/DD HH24:MI:SS') || ' usage=' || l_remaining_duration * 24);
--          dbms_output.put_line('shift=' || l_shift_date || ' from=' || l_from_time/(60*60) || ' to=' || l_to_time/(60*60));

          l_period_start_date := l_shift_date + l_from_time/(24*60*60);
          if( l_to_time < l_from_time) then
            l_period_end_date := l_shift_date + l_to_time/(24*60*60) + 1;
          else
            l_period_end_date := l_shift_date + l_to_time/(24*60*60);
          end if;

          if( l_period_end_date > l_new_start_date ) then

            if( l_new_start_date < l_period_start_date ) then
              l_new_start_date := l_period_start_date;
            end if;

            if( l_period_end_date - l_new_start_date >= l_remaining_duration ) then
              l_new_start_date := l_new_start_date + l_remaining_duration;
              l_remaining_duration := 0;
            else
              l_remaining_duration := l_remaining_duration - (l_period_end_date - l_new_start_date);
              l_new_start_date := l_period_end_date;
            end if;

          end if; /* l_period_end_date > l_new_start_date */

          if( l_remaining_duration <= 0 ) then
            exit;
          end if;

        end loop;
        l_end_date := l_new_start_date;

      end if; /* end if not 24 hr resource */
    end if; /* end if p_duration_hrs < 0 */

    return l_end_date;
  End project_resource_end_date;


  function project_op_res_end_date
  (
    p_organization_id number,
    p_wip_entity_id number,
    p_op_seq_num number,
    p_resource_seq_num number,
    p_resource_id number,
    p_start_date date
  ) return date
  Is
    l_utilization number;
    l_efficiency number;
    l_units number;
    l_actual_units number;
    l_department_id number;

    l_remaining_usage number;
    l_duration number;
    l_completion_date date;
  Begin

    /* if it's ad-hoc resource, no usage is defined so no completion date can be projected */
    if( p_resource_seq_num is null ) then
      l_completion_date := null;
    else
      select nvl(wor.department_id, wo.department_id)
      into l_department_id
      from wip_operations wo, wip_operation_resources wor
      where wo.wip_entity_id = p_wip_entity_id
        and wo.organization_id = p_organization_id
        and wo.operation_seq_num = p_op_seq_num
        and wor.wip_entity_id = wo.wip_entity_id
        and wor.organization_id = wo.organization_id
        and wor.operation_seq_num = wo.operation_seq_num
        and wor.resource_seq_num = p_resource_seq_num;

      l_remaining_usage := get_resource_remaining_usage(p_organization_id,
        p_wip_entity_id, p_op_seq_num, l_department_id, p_resource_seq_num, p_resource_id);

--      yl_debug.dump('req=' || l_remaining_usage);
      if( l_remaining_usage is not null ) then

        select least(wor.assigned_units, bdr.capacity_units),
               decode(wp.include_resource_utilization,
                      wip_constants.yes, nvl(bdr.utilization, 1), 1),
               decode(wp.include_resource_efficiency,
                      wip_constants.yes, nvl(bdr.efficiency, 1), 1)
        into l_units, l_utilization, l_efficiency
        from wip_operation_resources wor,
             bom_department_resources bdr,
             wip_parameters wp
        where wor.organization_id = p_organization_id
          and wor.wip_entity_id = p_wip_entity_id
          and wor.operation_seq_num = p_op_seq_num
          and wor.resource_seq_num = p_resource_seq_num
          and bdr.resource_id = wor.resource_id
          and bdr.department_id = l_department_id
          and wp.organization_id = p_organization_id;

--      dbms_output.put_line('units=' || l_units);

        select count(distinct wrat.instance_id)
        into l_actual_units
        from wip_resource_actual_times wrat
        where wrat.organization_id = p_organization_id
          and wrat.wip_entity_id = p_wip_entity_id
          and wrat.operation_seq_num = p_op_seq_num
          and wrat.resource_seq_num = p_resource_seq_num
          and wrat.status_type = 1
          and wrat.end_date is null;

        if( l_actual_units > l_units) then
          l_units := l_actual_units;
        end if;

--      dbms_output.put_line('units=' || l_units);
--      dbms_output.put_line('dept=' || l_department_id);

        l_duration := l_remaining_usage / (l_units * l_utilization * l_efficiency);

        l_completion_date := project_resource_end_date(
          p_organization_id, l_department_id, p_resource_id,
          p_start_date, l_duration);

      end if;
    end if;

    return l_completion_date;
  end project_op_res_end_date;


  function get_emp_projected_end_date
  (
    p_organization_id number,
    p_wip_entity_id number,
    p_op_seq_num number,
    p_resource_seq_num number,
    p_resource_id number,
    p_instance_id number,
    p_start_date date
  ) return date
  Is

  Begin

    return project_op_res_end_date(
      p_organization_id, p_wip_entity_id, p_op_seq_num,
      p_resource_seq_num, p_resource_id, p_start_date);

  End get_emp_projected_end_date;

  function get_res_projected_end_date
  (
    p_organization_id number,
    p_wip_entity_id number,
    p_op_seq_num number,
    p_resource_seq_num number,
    p_resource_id number,
    p_start_date date
  ) return date
  Is
    l_resource_type number;
    l_is_time_uom varchar2(10);

    l_completion_date date;
  Begin

    select br.resource_type, wip_ws_time_entry.is_time_uom(br.unit_of_measure)
    into l_resource_type, l_is_time_uom
    from bom_resources br
    where br.organization_id = p_organization_id
      and br.resource_id = p_resource_id;

    if( l_is_time_uom = 'Y') then


      if( l_resource_type = 1 ) then /* machine */

        l_completion_date := project_op_res_end_date(
          p_organization_id, p_wip_entity_id,
          p_op_seq_num, p_resource_seq_num, p_resource_id, p_start_date);


      elsif (l_resource_type = 2 ) then /* labor */
        l_completion_date := project_op_res_end_date(
          p_organization_id, p_wip_entity_id,
          p_op_seq_num, p_resource_seq_num, p_resource_id, p_start_date);

      else
        l_completion_date := project_op_res_end_date(
          p_organization_id, p_wip_entity_id,
          p_op_seq_num, p_resource_seq_num, p_resource_id, p_start_date);

      end if;
    else
      l_completion_date := null;
    end if; /* end if is_time_uom */

    return l_completion_date;
  end get_res_projected_end_date;

  function get_op_projected_end_date
  (
    p_organization_id number,
    p_wip_entity_id number,
    p_op_seq_num number
  ) return date
  Is
    l_completion_date date;
    l_not_projected_count number;
  Begin

    l_completion_date := null;

    select count(wor.resource_seq_num)
    into l_not_projected_count
    from wip_operation_resources wor
    where wor.wip_entity_id = p_wip_entity_id
      and wor.operation_seq_num = p_op_seq_num
      and wor.organization_id = p_organization_id
      and wor.projected_completion_date is null
      and wor.scheduled_flag in (1, 3, 4);

    if( l_not_projected_count = 0 ) then

      select max(wor.projected_completion_date)
      into l_completion_date
      from wip_operation_resources wor
      where wor.wip_entity_id = p_wip_entity_id
        and wor.operation_seq_num = p_op_seq_num
        and wor.organization_id = p_organization_id
        and wor.projected_completion_date is not null
        and wor.scheduled_flag in (1, 3, 4);
    end if;

    return l_completion_date;

  end get_op_projected_end_date;

  function get_projected_completion_date
  (
    p_organization_id number,
    p_wip_entity_id number,
    p_op_seq_num number,
    p_resource_seq_num number,
    p_resource_id number,
    p_instance_id number,
    p_start_date date
  ) return date
  Is

    l_completion_date date;
  Begin

    if( p_start_date is null ) then
      l_completion_date := null;

    elsif( p_instance_id is not null) then
     l_completion_date := get_emp_projected_end_date(
       p_organization_id, p_wip_entity_id, p_op_seq_num, p_resource_seq_num, p_resource_id,
       p_instance_id, p_start_date);

    elsif ( p_resource_seq_num is not null or p_resource_id is not null) then
      l_completion_date := get_res_projected_end_date(
        p_organization_id, p_wip_entity_id, p_op_seq_num, p_resource_seq_num, p_resource_id,
        p_start_date);

    elsif ( p_op_seq_num is not null ) then
      l_completion_date := get_op_projected_end_date(
        p_organization_id, p_wip_entity_id, p_op_seq_num);

    else
      l_completion_date := null;

    end if;

    return l_completion_date;

  End get_projected_completion_date;

  procedure set_legal_entity_ctx(
    p_org_id number
  )
  Is
    l_le_id number;
  Begin
    select to_number(ORG_INFORMATION2) into l_le_id
    from hr_organization_information
    where organization_id = p_org_id
    and org_information_context = 'Accounting Information';

    GL_GLOBAL.set_aff_validation('LE', l_le_id);

  exception when others then
     null;
  End set_legal_entity_ctx;

  function get_instance_name(p_resource_id IN NUMBER,
                             p_instance_id IN NUMBER,
                             p_serial_number IN VARCHAR2) return VARCHAR2
  IS
   l_resource_type number;
   l_emp_id number;
   l_emp_name varchar2(255);
   l_equipment_prefix varchar2(255);
   l_equipment_name varchar2(255);
   l_instance_name varchar2(255);

   cursor resource_type_cursor is
   select resource_type
   from bom_resources br
   where resource_id = p_resource_id;

   cursor emp_id_cursor is
   select person_id
   from bom_resource_employees bremp
   where instance_id = p_instance_id;

   cursor equipment_cursor is
   select msik.concatenated_segments
   from bom_resource_equipments breq,
        mtl_system_items_kfv msik
   where breq.instance_id = p_instance_id
         and msik.inventory_item_id = breq.inventory_item_id
         and msik.organization_id = breq.organization_id;
  BEGIN
    open resource_type_cursor;
    fetch resource_type_cursor into l_resource_type;
    close resource_type_cursor;

    if l_resource_type = 2 then  --person resource
      open emp_id_cursor;
      fetch emp_id_cursor into l_emp_id;
      close emp_id_cursor;

      l_emp_name := get_employee_name(p_employee_id => l_emp_id,
                                      p_date        => null);
      return l_emp_name;
    elsif l_resource_type = 1 then  --machine resource
      open equipment_cursor;
      fetch equipment_cursor into l_equipment_prefix;
      close equipment_cursor;

      l_equipment_name := get_instance_name(p_instance_name =>  l_equipment_prefix,
                                            p_serial_number =>  p_serial_number);
      return l_equipment_name;
    else  --other resource
      return null;
    end if;
  END get_instance_name;

  procedure init_timezone
  IS
  Begin

    /* reset the timezone profiles */
    g_timezone_enabled := (fnd_profile.value('ENABLE_TIMEZONE_CONVERSIONS') = 'Y' AND
                        fnd_profile.value('CLIENT_TIMEZONE_ID') IS NOT NULL AND
                        fnd_profile.value('SERVER_TIMEZONE_ID') IS NOT NULL AND
                        fnd_profile.value('CLIENT_TIMEZONE_ID') <>
                        fnd_profile.value('SERVER_TIMEZONE_ID'));


    g_client_id  := fnd_profile.value('CLIENT_TIMEZONE_ID');
    g_server_id  := fnd_profile.value('SERVER_TIMEZONE_ID');

  Exception
    when others then
      null;
  End init_timezone;

  function get_page_title(p_oahp varchar2, p_oasf varchar2)
  return varchar2
  IS
    l_home_menu_id number;
    l_function_id number;
    l_f_menu_id number;
    l_name varchar2(255);
  Begin
    l_name := '';

    select user_function_name
    into l_name
    from fnd_form_functions_vl t
    where t.function_name = p_oasf;

    return l_name;
  Exception when others then
    return null;
  End get_page_title;


  function get_multival_pref_seq(p_pref_id IN NUMBER,
                                 p_level_id IN NUMBER,
                                 p_attribute_name IN VARCHAR2,
                                 p_attribute_val IN VARCHAR2) return NUMBER IS
    CURSOR pref_row_seq_csr IS
    select wpv.sequence_number
      from wip_preference_values wpv
     where wpv.preference_id = p_pref_id
       and wpv.level_id = p_level_id
       and wpv.attribute_name = p_attribute_name
       and wpv.attribute_value_code = p_attribute_val;
    l_seq_num NUMBER;
  BEGIN
    for c_pref_row_seq_csr in pref_row_seq_csr loop
      l_seq_num := c_pref_row_seq_csr.sequence_number;
    end loop;
    return l_seq_num;
  END get_multival_pref_seq;


  function get_multival_pref_val_code(p_pref_id IN NUMBER,
                                      p_level_id IN NUMBER,
                                      p_seq_num IN NUMBER,
                                      p_attribute_name IN VARCHAR2) return VARCHAR2 IS
    CURSOR att_val_csr IS
    select wpv.attribute_value_code
      from wip_preference_values wpv
     where wpv.preference_id = p_pref_id
       and wpv.level_id = p_level_id
       and wpv.sequence_number = p_seq_num
       and wpv.attribute_name = p_attribute_name;
    l_att_val VARCHAR2(80);
  BEGIN
    for c_att_val_csr in att_val_csr loop
      l_att_val := c_att_val_csr.attribute_value_code;
    end loop;
    return l_att_val;
  END get_multival_pref_val_code;


  procedure log_time(p_msg IN VARCHAR2, p_date IN DATE DEFAULT SYSDATE) IS
    l_returnStatus varchar2(1);
  BEGIN

    if (g_logLevel <= wip_constants.trace_logging) then
      wip_logger.log((to_char(p_date,'hh:mi:ss') || '-' || p_msg),l_returnStatus);
    end if;
  END log_time;


FUNCTION get_lock_handle (
         p_org_id       IN NUMBER,
   p_lock_prefix  IN Varchar2) RETURN VARCHAR2 IS

   PRAGMA AUTONOMOUS_TRANSACTION;
   l_lock_handle VARCHAR2(128);
   l_lock_name   VARCHAR2(30);
BEGIN
   l_lock_name := p_lock_prefix || p_org_id;
   trace_log('get_lock_handle: lock_name='||l_lock_name);
   dbms_lock.allocate_unique(
         lockname       => l_lock_name
        ,lockhandle     => l_lock_handle);
   trace_log('get_lock_handle: lock_handle='||l_lock_handle);
   return l_lock_handle;
END get_lock_handle;


PROCEDURE get_lock(
          x_return_status OUT nocopy varchar2,
          x_msg_count     OUT nocopy number,
          x_msg_data      OUT nocopy varchar2,
          x_lock_status   OUT nocopy number,
          p_org_id        IN  NUMBER,
    p_lock_prefix   IN  Varchar2) IS
  l_lock_handle    varchar2(128);
  l_returnStatus  varchar2(1);
BEGIN
  trace_log('get_lock: Entering for org_id='||p_org_id);
  l_lock_handle := get_lock_handle (p_org_id       => p_org_id,
                                    p_lock_prefix  => p_lock_prefix);
  -- request lock with release_on_commit TRUE so that we dont have to manually
  -- release the lock later.
  x_lock_status := dbms_lock.request(
  lockhandle      => l_lock_handle,
  lockmode        => dbms_lock.x_mode,
  timeout         => dbms_lock.maxwait,
  release_on_commit => TRUE);
  trace_log('get_lock: got lock for lock handle with status ='||x_lock_status);
  trace_log('get_lock: Returning from lock_for_match');
EXCEPTION
 WHEN FND_API.G_EXC_UNEXPECTED_ERROR then
   trace_log('get_lock: Exception: Unexpected Error '||sqlerrm);
   x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

  WHEN OTHERS then
    trace_log('get_lock: Exception: Others Exception : ' || sqlerrm);
    x_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;

END get_lock;


PROCEDURE release_lock(
          x_return_status OUT NOCOPY VARCHAR2,
          x_msg_count     OUT NOCOPY NUMBER,
          x_msg_data      OUT NOCOPY VARCHAR2,
          p_org_id        IN  NUMBER,
    p_lock_prefix   IN  varchar2) IS
  l_return_status        VARCHAR2(1) := fnd_api.g_ret_sts_success;
  l_lock_handle          VARCHAR2(128);
  l_status               INTEGER;
  l_returnStatus  varchar2(1);
BEGIN
   trace_log('release_lock: Entering release_lock for org_id'||p_org_id);
   --get lock handle by calling helper function
   l_lock_handle := get_lock_handle(p_org_id       => p_org_id,
                                    p_lock_prefix  => p_lock_prefix);
   trace_log('release_lock: lock_handle='||l_lock_handle);

   l_status := dbms_lock.release(l_lock_handle);
   trace_log('release_lock: release returned with status:'||l_status);

   --if success (status = 0) or session does not own lock (status=4),
   --   do nothing
   --if parameter error or illegal lock handle (internal error)

   if l_status IN (3,5) THEN
     trace_log('release_lock: Error releasing lock');
     RAISE fnd_api.g_exc_error;
   end if;

   x_return_status := l_return_status;


EXCEPTION

   WHEN fnd_api.g_exc_error THEN
     trace_log('release_lock: Exception: expected error');
     x_return_status := fnd_api.g_ret_sts_error;

   WHEN fnd_api.g_exc_unexpected_error THEN
     trace_log('release_lock: Exception: Unexpected error');
     x_return_status := fnd_api.g_ret_sts_unexp_error ;

    WHEN OTHERS THEN
     trace_log('release_lock: Exception: Others Exception: '||sqlerrm);
      x_return_status := fnd_api.g_ret_sts_unexp_error ;

END release_lock;

PROCEDURE trace_log(p_msg IN VARCHAR2) IS
l_returnStatus varchar2(1);
BEGIN
  fnd_file.put_line(fnd_file.log,p_msg);
  if (g_logLevel <= wip_constants.trace_logging) then
    wip_logger.log(p_msg,l_returnStatus);
  end if;
END trace_log;


  --check shortages in work orders tab supervisor dashboard
   -- 1 is shortage
   -- 2 is no shortage
   -- 3 is not applicable
FUNCTION check_comp_shortage(p_wip_entity_id IN NUMBER,
           p_org_id        IN NUMBER) RETURN NUMBER IS
  l_comp_shortage NUMBER := 3;
  l_row_seq_num NUMBER;
  l_shortage_calc_level NUMBER;
BEGIN
  --Bug 6889755 - Return component shortage depending on the calculation level setup
  l_row_seq_num := wip_ws_util.get_multival_pref_seq(
    WIP_WS_SHORTAGE.g_pref_id_comp_short, WIP_WS_SHORTAGE.g_pref_level_id_site, WIP_WS_SHORTAGE.g_pref_val_mast_org_att, to_char(p_org_id));

  l_shortage_calc_level := wip_ws_util.get_multival_pref_val_code(
    WIP_WS_SHORTAGE.g_pref_id_comp_short, WIP_WS_SHORTAGE.g_pref_level_id_site, l_row_seq_num, WIP_WS_SHORTAGE.g_pref_val_calclevel_att);
  --End Bug 6889755

  --Bug 6889755 - added IF condition and the ELSE block for subinv level check
  /* Bug 9221212 , remove rownum =1 as we should consider the shortage_qty
  for all components not only the first component*/
  IF (l_shortage_calc_level = ORG_CALCULATION_LEVEL) THEN
    select decode(nvl(sum(shortage_qty),-1),-1,3,0,2,1)
    into l_comp_shortage
    from wip_ws_comp_shortage
    where wip_entity_id = p_wip_entity_id
    and   organization_id =  p_org_id
    and SUPPLY_SUBINVENOTRY is null;

  ELSIF (l_shortage_calc_level = SUBINV_CALCULATION_LEVEL) THEN
    /* Bug 9221212 , remove rownum =1 as we should consider the shortage_qty
    for all components not only the first component*/
    select decode(nvl(sum(shortage_qty),-1),-1,3,0,2,1)
    into l_comp_shortage
    from wip_ws_comp_shortage
    where wip_entity_id = p_wip_entity_id
    and organization_id =  p_org_id
    and SUPPLY_SUBINVENOTRY is not null;

  END IF;

  --l_comp_shortage :=1;
  return l_comp_shortage;


Exception
   when no_data_found then
      --for organization not setup for comp shortage calculation
      l_comp_shortage := 3;
       return l_comp_shortage;
   When others then
      l_comp_shortage := 3;
      -- l_comp_shortage :=1;
      return l_comp_shortage;
END check_comp_shortage;

FUNCTION check_res_shortage(p_wip_entity_id IN NUMBER,
           p_org_id        IN NUMBER) RETURN NUMBER IS
  l_res_shortage NUMBER  := 3;
BEGIN

   /* Bug 9221212 , remove rownum =1 as we should consider the resource_shortage
    for all resources not only the first resource*/
  select decode(nvl(sum(RESOURCE_SHORTAGE),-1),-1,3,0,2,1)
  into l_res_shortage
  from wip_ws_res_shortage
  where wip_entity_id = p_wip_entity_id
  and   organization_id =  p_org_id;

   --l_res_shortage :=1;
   return l_res_shortage;
Exception
    when no_data_found then
      --for organization not setup for res shortage calculation
      l_res_shortage := 3;
      return l_res_shortage;

   When others then
      l_res_shortage := 3;
     -- l_res_shortage :=1;
      return l_res_shortage;
END check_res_shortage;

--new function for bugfix 6755623
function get_csh_calc_level(p_org_id Number) return NUMBER IS
    l_calc_level NUMBER;
    l_row_seq_num NUMBER;
  BEGIN
    --get the sequence number
     l_row_seq_num := wip_ws_util.get_multival_pref_seq(
    g_pref_id_comp_short, g_pref_level_id_site, g_pref_val_mast_org_att, to_char(p_org_id));

    if(l_row_seq_num is null) then
     return 1; --return org level by default inorder to avoid error
    end if;

    l_calc_level := wip_ws_util.get_multival_pref_val_code(
    g_pref_id_comp_short, g_pref_level_id_site, l_row_seq_num, g_pref_val_calclevel_att);

    return l_calc_level;

  END get_csh_calc_level;

FUNCTION get_no_of_running_concurrent(
    p_program_application_id in number,
    p_concurrent_program_id  in number,
    p_org_id                 in number) RETURN number
IS
    l_pgm_count       number;
BEGIN
    wip_ws_util.trace_log('Program application id '|| p_program_application_id);
    wip_ws_util.trace_log('Concurrent program id '|| p_concurrent_program_id);
    wip_ws_util.trace_log('Oraganization id '|| p_org_id);
    SELECT  count(1)
        INTO l_pgm_count
    FROM fnd_concurrent_requests
    WHERE program_application_id = p_program_application_id
        AND concurrent_program_id = p_concurrent_program_id
        AND upper(phase_code) = 'R'
        AND argument1 = to_char(p_org_id);
    wip_ws_util.trace_log('Running concurrent program '|| l_pgm_count);
    return l_pgm_count;
END  get_no_of_running_concurrent;


PROCEDURE log_for_duplicate_concurrent(
    p_org_id       in number,
    p_program_name in varchar2)
IS
    l_org_code        varchar2(3);
BEGIN

    wip_ws_util.trace_log('Unable to run '|| p_program_name ||' calculation program for  organization ' || get_calendar_code(p_org_id));
    wip_ws_util.trace_log('Another instance may be running. Please try again after some time.');

END log_for_duplicate_concurrent;


end wip_ws_util;


/
