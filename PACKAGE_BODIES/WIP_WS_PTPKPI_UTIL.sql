--------------------------------------------------------
--  DDL for Package Body WIP_WS_PTPKPI_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WS_PTPKPI_UTIL" as
/* $Header: WIPWSPUB.pls 120.16 2008/04/28 22:05:48 awongwai noship $ */

  /*
    Description:
      Get the calendar code from inventory parameters based on the
    Parameters:
      p_organization_id - the organization id
    Return:
      the calendar code of the given organization.
  */
  function get_calendar_code(p_organization_id number)
    return varchar2 is
    l_calendar_code varchar2(100) := null;
  begin
    -- get the calendar_code based on organization_id
    select mp.calendar_code into l_calendar_code
    from mtl_parameters mp
    where mp.organization_id = p_organization_id;
    return l_calendar_code;
    exception when others then
      return null;
  end get_calendar_code;


  /*
    Description:
      Get the primary uom code for the given org and wip entity.
    Parameters:
      p_org_id - organization id
      p_wip_entity_id - the wip entity id (job, schedule, etc.)
    Return:
      the primary uom of the assembly
  */
  function get_primary_uom_code(
    p_org_id in number,
    p_wip_entity_id in number
  ) return varchar2
  is
    l_primary_uom_code varchar2(10) := null;
    cursor retrieve_primary_uom_code_c is
      select primary_uom_code
      from mtl_system_items msi, wip_entities we
      where msi.organization_id = we.organization_id
        and we.primary_item_id = msi.inventory_item_id
        and we.organization_id = p_org_id
        and we.wip_entity_id = p_wip_entity_id
    ;
  begin
    open retrieve_primary_uom_code_c;
    fetch retrieve_primary_uom_code_c into l_primary_uom_code;
    close retrieve_primary_uom_code_c;

    return l_primary_uom_code;
  end get_primary_uom_code;


  /*
    Description:
      Get the project id for the given discrete job.
    Parameters:
      p_org_id - the organization id
      p_wip_entity_id - the discrete job wip entity id
    Return:
  */
  function get_project_id(
    p_org_id in number,
    p_wip_entity_id in number
  ) return number
  is
    l_project_id number := null;
    cursor retrieve_project_id_c is
      select project_id
      from wip_discrete_jobs
      where organization_id = p_org_id
        and wip_entity_id = p_wip_entity_id
    ;
  begin
    open retrieve_project_id_c;
    fetch retrieve_project_id_c into l_project_id;
    close retrieve_project_id_c;

    return l_project_id;
  end get_project_id;


    /*
    Description:
      Get the task id for the given discrete job.
    Parameters:
      p_org_id - the organization id
      p_wip_entity_id - the discrete job wip entity id
    Return:
  */
  function get_task_id(
    p_org_id in number,
    p_wip_entity_id in number
  ) return number
  is
    l_task_id number := null;
    cursor retrieve_task_id_c is
      select task_id
      from wip_discrete_jobs
      where organization_id = p_org_id
        and wip_entity_id = p_wip_entity_id
    ;
  begin
    open retrieve_task_id_c;
    fetch retrieve_task_id_c into l_task_id;
    close retrieve_task_id_c;

    return l_task_id;
  end get_task_id;


  /*
    Get the operation lead time (in minutes) for the given job operation.

    The operation lead time is found as:
      operation lead time = (item lead time) * (operation lead time %)

    The item lead time is the one stored at the item level, which is
    calculated by a concurrent program. The operation lead time % is
    defined at the BOM level, which is also calculated by a concurrent
    program.

    For MES Production To Plan KPI, we assume that the item's lead time
    and operation lead time % always exist.
  */
  function get_operation_lead_time(
    p_org_id in number,
    p_wip_entity_id in number,
    p_op_seq_num in number

  ) return number
  is
    l_hrUOM varchar2(3);
    l_lead_time  number;
  begin

  l_hrUOM := fnd_profile.value('BOM:HOUR_UOM_CODE');
  select  sum(lead_time)
  into    l_lead_time
  from
     (select  max((case when (inv_convert.inv_um_convert(0,wor.uom_code,l_hrUOM) = -99999)
                        then 0
                        else inv_convert.inv_um_convert(0,wor.uom_code,l_hrUOM)*wor.usage_rate_or_amount
                   end)*decode(wor.basis_type,WIP_CONSTANTS.PER_LOT,1,wo.scheduled_quantity)
                       /least(wor.assigned_units,bdr.capacity_units)/(nvl( bdr.utilization,1))/(nvl(bdr.efficiency,1))) lead_time
      from wip_operation_resources wor,
           wip_operations wo,
           bom_department_resources bdr,
           bom_resources br
      where wo.wip_entity_id = p_wip_entity_id
      and   wo.wip_entity_id = wor.wip_entity_id
      and   wo.operation_seq_num = p_op_seq_num
      and   wo.operation_seq_num = wor.operation_seq_num
      and   wo.department_id = bdr.department_id
      and   wor.resource_id   = bdr.resource_id
      and   wor.resource_id   = br.resource_id
      and   br.resource_type in (WIP_CONSTANTS.RES_MACHINE, WIP_CONSTANTS.RES_PERSON)
      and   wor.scheduled_flag <> WIP_CONSTANTS.SCHED_NO
      group by to_char(nvl(to_char(wor.schedule_seq_num),rowidtochar(wor.rowid)))
     );

    return l_lead_time;
  end get_operation_lead_time;


  /*
    Description:
      Given the organization, department, resource, and a timestamp,
      find out which shift the timestamp belongs to. It uses the existing
      shift definition as defined in the wip_ws_util package.
    Parameters:
      p_org_id - the organization id
      p_dept_id - the department id
      p_resource_id - the resource id
      p_date - the timestamp
  */
  function get_shift_id_for_date
  (
    p_org_id in number,
    p_dept_id in number,
    p_resource_id in number,
    p_date in date
  ) return varchar2
  is
    l_cal_code varchar2(30);

    l_c_start_date date;
    l_c_end_date date;
    l_c_from_time varchar2(60);
    l_c_to_time varchar2(60);
    l_24hr_resource number;
    x_shift_seq number;
    x_shift_num number;
    x_shift_start_date date;
    x_shift_end_date date;
    x_shift_string varchar2(100);
  begin
    wip_ws_util.retrieve_first_shift(
      p_org_id,
      p_dept_id,
      p_resource_id,
      p_date,
      x_shift_seq,
      x_shift_num,
      x_shift_start_date,
      x_shift_end_date,
      x_shift_string
    );
    return (x_shift_seq || '.' || x_shift_num);
  end get_shift_id_for_date;


  /*
    Description:
      Get the shift start or end datetime for the specified org and shift id.
    Parameters:
      p_org_id - organization id
      p_shift_id - in the format of <shift_seq_num>.<shift_num>
      p_start_or_end - 1 to retrieve shift start; 2 to retrieve shift end.
    Return:
      the shift start or end time (depending on p_start_or_end)
  */
  function get_datetime_for_shift(
    p_org_id in number,
    p_shift_id in varchar2,
    p_start_or_end in number
  ) return date
  is
    x_shift_day date;
    x_shift_start date;
    x_shift_end date;
    x_shift_string varchar2(100);
  begin
    if (instr(nvl(p_shift_id,'@'),'.') <= 0) then
      return null;
    end if;

    load_shift_information(
      p_org_id,
      p_shift_id,
      x_shift_day,
      x_shift_start,
      x_shift_end,
      x_shift_string
    );

    if (p_start_or_end = 1) then
      return x_shift_start;
    elsif (p_start_or_end = 2) then
      return x_shift_end;
    else
      return null;
    end if;

    exception
      when others then
        return null;
  end get_datetime_for_shift;


  /*
    Description:
      Get the shift display string for the chart.
    Parameters:
      p_org_id - organization id
      p_shift_id - in the format of <shift_seq_num>.<shift_num>
    Return:
      the shift display string on the chart's x-axis
  */
  function get_chart_str_for_shift(
    p_org_id in number,
    p_shift_id in varchar2
  ) return varchar2
  is
    x_shift_day date;
    x_shift_start date;
    x_shift_end date;
    x_shift_string varchar2(100);
  begin
    if (instr(nvl(p_shift_id,'@'),'.') <= 0) then
      return null;
    end if;

    load_shift_information(
      p_org_id,
      p_shift_id,
      x_shift_day,
      x_shift_start,
      x_shift_end,
      x_shift_string
    );

    return x_shift_string;
    exception
      when others then
        return null;
  end get_chart_str_for_shift;


    /*
    Description:
      Get the day display string for the chart.
    Parameters:
      p_org_id - organization id
      p_shift_id - in the format of <shift_seq_num>.<shift_num>
    Return:
      the day display string on the chart's x-axis
  */
  function get_chart_str_for_day(
    p_org_id in number,
    p_shift_id in varchar2
  ) return varchar2
  is
    x_shift_day date;
    x_shift_start date;
    x_shift_end date;
    x_shift_string varchar2(100);
  begin
    if (instr(nvl(p_shift_id,'@'),'.') <= 0) then
      return null;
    end if;

    load_shift_information(
      p_org_id,
      p_shift_id,
      x_shift_day,
      x_shift_start,
      x_shift_end,
      x_shift_string
    );

    return x_shift_day;
    exception
      when others then
        return null;
  end get_chart_str_for_day;



  /*
    Description:
      Get the shift-related information for the given org and shift id.
    Parameters:
      p_org_id - organization id
      p_shift_id - in the format of <shift_seq_num>.<shift_num>
      x_shift_day - the shift day (always trucated timestamp)
      x_shift_start - the shift start timestamp (inclusive)
      x_shift_end - the shift end timestamp (exclusive)
      x_shift_chart_str - the shift display on the chart
    Return:
  */
  procedure load_shift_information(
    p_org_id in number,
    p_shift_id in varchar2,
    x_shift_day out nocopy date,
    x_shift_start out nocopy date,
    x_shift_end out nocopy date,
    x_shift_chart_str out nocopy varchar2
  )
  is
    l_shift_seq_num number;
    l_shift_num number;
    l_calendar_code varchar2(50);
    l_shift_description varchar2(100);
  begin
    -- cannot proceed if shift_id is null
    if (instr(nvl(p_shift_id,'@'),'.') <= 0) then
      return;
    end if;

    l_shift_seq_num := substr(p_shift_id, 1, instr(p_shift_id, '.')-1);
    l_shift_num := substr(p_shift_id, instr(p_shift_id, '.')+1, length(p_shift_id));

    -- cannot proceed if shift_id is malformed
    if (l_shift_seq_num is null or l_shift_num is null) then
      return;
    end if;

    l_calendar_code := get_calendar_code(p_org_id);

    select
      bsd.shift_date + st.from_time/(60*60*24),
      bsd.shift_date + st.to_time/(60*60*24),
      trunc(bsd.shift_date),
      bcs.description
    into
      x_shift_start,
      x_shift_end,
      x_shift_day,
      l_shift_description
    from
      bom_shift_dates bsd,
      (select
         bst.shift_num,
         min(bst.from_time) from_time,
         max (bst.to_time + decode(sign(bst.to_time - bst.from_time), -1, (24*60*60), 0) ) to_time
       from bom_shift_times bst
       where bst.calendar_code = l_calendar_code
         and bst.shift_num = l_shift_num
       group by bst.shift_num
      ) st,
      bom_calendar_shifts bcs
    where bsd.calendar_code = l_calendar_code
      and bsd.exception_set_id = -1
      and bsd.seq_num = l_shift_seq_num
      and bsd.shift_num = st.shift_num
      and bsd.calendar_code = bcs.calendar_code
      and bsd.shift_num = bcs.shift_num
    ;

    -- construct the "display string" here...
    --x_shift_chart_str := x_shift_day || ':' || l_shift_num || ':' || l_shift_description;
    x_shift_chart_str := get_shift_display_str(x_shift_day, l_shift_num, l_shift_description);

    exception
      when others then
        return;
  end load_shift_information;


  function get_n_previous_working_day(
    p_org_id number,
    n number,
    p_date date
  ) return date
  is
    day date := null;
  begin
    if (n < 1) then
      return null;
    end if;
    day := mrp_calendar.PREV_WORK_DAY(p_org_id,1,trunc(p_date));
    for i in 1..(n-1) loop
      day := mrp_calendar.PREV_WORK_DAY(207,1,day-1);
    end loop;
    return day;
  end get_n_previous_working_day;

  --------------------------------------------------
  --------------------------------------------------
  /* start: for ui -- work in progress */
  procedure get_shifts(
    p_organization_id in number,
    p_department_id in number,
    p_resource_id in number,
    p_start_shift_date in date,
    p_end_shift_date in date
  ) is
  begin
    if (p_department_id is null) then
      get_org_shifts(p_organization_id, p_start_shift_date, p_end_shift_date);
    else
      get_dept_resource_shifts(
        p_organization_id,
        p_department_id,
        p_resource_id,
        p_start_shift_date,
        p_end_shift_date
      );
    end if;
  end get_shifts;


  procedure get_org_shifts(
    p_organization_id in number,
    p_start_shift_date in date,
    p_end_shift_date in date
  ) is
    l_calendar_code varchar2(50) := null;
    l_shift_info shift_info_t := null;
    l_start_shift_day date := null;
    l_end_shift_day date := null;

    -- cursor to get all shifts for day and calendar
    cursor c_shifts(
      p_organization_id number,
      start_shift_day date,
      end_shift_day date,
      p_calendar_code varchar2
    ) is
    select
      bsd.seq_num || '.' || bsd.shift_num as shift_id,
      to_char(
        wip_ws_util.get_appended_date(bsd.shift_date, t.from_time),
        'DD-MON-YYYY HH24:MI:SS'
      ) as from_date_char,
      to_char(
        wip_ws_util.get_appended_date( bsd.shift_date, t.to_time),
        'DD-MON-YYYY HH24:MI:SS'
      ) as to_date_char,
      wip_ws_util.get_appended_date( bsd.shift_date, t.from_time) as from_date,
      wip_ws_util.get_appended_date( bsd.shift_date, t.to_time) as to_date,
      t.shift_num as shift_num,
      bsd.seq_num as seq_num,
      wip_ws_util.get_shift_info_for_display(
        p_organization_id, bsd.seq_num, t.shift_num
      ) as display
    from
      bom_shift_dates bsd,
      (
        select
          bst.calendar_code,
          bst.shift_num,
          min(bst.from_time) from_time,
          max(decode(sign(bst.to_time - bst.from_time), -1, 24*60*60, 0) + bst.to_time) to_time
        from bom_shift_times bst
        where bst.calendar_code = p_calendar_code
        group by bst.calendar_code, bst.shift_num
      ) t
    where bsd.calendar_code = p_calendar_code
      and bsd.calendar_code = t.calendar_code
      and bsd.shift_num = t.shift_num
      and bsd.exception_set_id = -1
      and bsd.shift_date between start_shift_day and end_shift_day
      and bsd.seq_num is not null
    order by from_date;
    -- end cursor c_shifts

    l_return_status varchar2(1000);
  begin
    l_calendar_code := get_calendar_code(p_organization_id);
    l_start_shift_day := trunc(p_start_shift_date);
    l_end_shift_day := trunc(p_end_shift_date);

    open c_shifts(
      p_organization_id, l_start_shift_day, l_end_shift_day, l_calendar_code
    );
    loop
      fetch c_shifts into l_shift_info;
      wip_logger.log(
        'shift_id=' || l_shift_info.shift_id ||
        ', from_date_char=' || l_shift_info.from_date_char ||
        ', to_date_char=' || l_shift_info.to_date_char,l_return_status
      );
      exit when c_shifts%NOTFOUND;
    end loop;
    close c_shifts;
  end get_org_shifts;


  procedure get_dept_resource_shifts(
    p_organization_id in number,
    p_department_id in number,
    p_resource_id in number,
    p_start_shift_date in date,
    p_end_shift_date in date
  ) is
  begin
    null;
  end get_dept_resource_shifts;



  procedure get_candidate_shifts_for_day(
    p_organization_id in number,
    p_department_id in number,
    p_day date
  ) is
  begin
    null;
  end get_candidate_shifts_for_day;
  /* end: for ui -- work in progress */

  /*
   Used by UI to construct shift name for a given shift number
  */
  function get_shift_name_for_display(
    p_shift_num in number) return varchar2 is
    l_shift_string varchar2(240);
  begin
    fnd_message.SET_NAME('WIP', 'WIP_WS_PTP_SHIFT_SINGLE');
    fnd_message.SET_TOKEN('SHIFT_NUM', p_shift_num);
    l_shift_string := fnd_message.GET;
    return l_shift_string;

  exception when others then
    return to_char(p_shift_num);

  end get_shift_name_for_display;

  function get_date_as_string(
    p_date in date) return varchar2 is
  begin

    return trunc(p_date)||'';
  end get_date_as_string;


  function get_shift_display_str(
    p_shift_date in date,
    p_shift_num in number,
    p_shift_desc in varchar2) return varchar2 is
  l_shift_str varchar2(240);
  begin
    l_shift_str := trunc(p_shift_date) || ':' || get_shift_name_for_display(p_shift_num);
    return l_shift_str;

  end get_shift_display_str;



begin
  -- Initialization
  null;

end WIP_WS_PTPKPI_UTIL;

/
