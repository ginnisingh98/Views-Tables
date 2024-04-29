--------------------------------------------------------
--  DDL for Package Body WIP_WS_LABOR_METRIC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WS_LABOR_METRIC_PUB" AS
/* $Header: wipwslmb.pls 120.9 2008/06/12 11:24:27 sisankar noship $ */

    /* To Get Calendar Code for an organization */
    function get_calendar_code(p_organization_id number)
    return varchar2 is
        l_calendar_code varchar2(100) := null;
    begin
        select mp.calendar_code
        into l_calendar_code
        from mtl_parameters mp
        where mp.organization_id = p_organization_id;
        return l_calendar_code;
    exception
        when others then return null;
    end get_calendar_code;

    /* To validate whether the UOM is time based */
    function is_time_uom(p_uom_code in varchar2)
    return number is
        l_uom_class varchar2(10);
        l_time_based_uom_flag number;

        cursor time_based_uom_cursor is
        select distinct muc1.uom_class
        from mtl_uom_conversions  muc1,
        mtl_uom_conversions  muc2
        where (muc1.uom_class = muc2.uom_class
        and nvl(muc1.disable_date, sysdate + 1) > sysdate)
        and nvl(muc2.disable_date, sysdate + 1) > sysdate
        and muc1.uom_code = fnd_profile.value('BOM:HOUR_UOM_CODE')
        and muc2.uom_code = p_uom_code;
    begin
        open time_based_uom_cursor;
        fetch time_based_uom_cursor into l_uom_class;
        if time_based_uom_cursor%notfound then
            l_time_based_uom_flag := 2;
        else
            l_time_based_uom_flag := 1;
        end if;
        close time_based_uom_cursor;
        return l_time_based_uom_flag;
    end is_time_uom;

    /* To obtain end of the time window for metrics calculation */
    function get_period_end(p_calendar_code in varchar2,
                            p_date in date)
    return date is
        l_end_time Date  := null;
        l_temp_time Date;
    begin

        l_temp_time := p_date;
        select
        max(bsd.shift_date + st.to_time/(60*60*24))
        into l_end_time
        from
        bom_shift_dates bsd,
        (select bst.shift_num,
        min(bst.from_time) from_time,
        max(decode(sign(bst.to_time - bst.from_time), -1, 24*60*60, 0) + bst.to_time) to_time
        from bom_shift_times bst
        where bst.calendar_code = p_calendar_code
        group by bst.shift_num) st
        where bsd.calendar_code = p_calendar_code
        and bsd.shift_num = st.shift_num
        and bsd.exception_set_id = -1
        and bsd.seq_num is not null
        and bsd.shift_date = trunc(p_date)
        and bsd.shift_date + st.to_time/(60*60*24) <= l_temp_time
        and bsd.shift_date + st.from_time/(60*60*24) < l_temp_time;

        while l_end_time is null loop

            l_temp_time := l_temp_time-1;

            select
            max(bsd.shift_date + st.to_time/(60*60*24))
            into l_end_time
            from
            bom_shift_dates bsd,
            (select bst.shift_num,
            max(decode(sign(bst.to_time - bst.from_time), -1, 24*60*60, 0) + bst.to_time) to_time
            from bom_shift_times bst
            where bst.calendar_code = p_calendar_code
            group by bst.shift_num) st
            where bsd.calendar_code = p_calendar_code
            and bsd.shift_num = st.shift_num
            and bsd.exception_set_id = -1
            and bsd.seq_num is not null
            and bsd.shift_date = trunc(l_temp_time);

        end loop;

        return l_end_time;

    end get_period_end;

    /* To obtain start of the time window for metrics calculation */
    function get_period_start(p_org_id in number,
                              p_date in date)
    return date
    is
        l_start_time Date;
    begin
        l_start_time := trunc(p_date)-6;
        /* Commented this code since calculation is for last 7 calendar days and not last 7 working days.
        for i in 1..6 loop
        l_start_time := mrp_calendar.PREV_WORK_DAY(p_org_id,1,l_start_time-1);
        end loop;*/
        return l_start_time;
    end get_period_start;

    /* To obtain date for a given seq_num and shift_num (Used in Charts only) */
    function get_date_for_seq(p_org_id in number,
                              p_seq_num in number,
                              p_shift_num in number)
    return date
    is
        l_eff_date Date;
        l_converted_date date;
        l_calendar_code varchar2(50);
        l_timezone_enabled boolean := ( fnd_profile.value('ENABLE_TIMEZONE_CONVERSIONS') = 'Y' AND
                                        fnd_profile.value('CLIENT_TIMEZONE_ID') IS NOT NULL AND
                                        fnd_profile.value('SERVER_TIMEZONE_ID') IS NOT NULL AND
                                        fnd_profile.value('CLIENT_TIMEZONE_ID') <>
                                        fnd_profile.value('SERVER_TIMEZONE_ID'));
        l_client_id number := fnd_profile.value('CLIENT_TIMEZONE_ID');
        l_server_id number := fnd_profile.value('SERVER_TIMEZONE_ID');
    begin
        l_calendar_code := get_calendar_code(p_org_id);
        begin
            select shift_date
            into l_eff_date
            from bom_shift_dates
            where calendar_code = l_calendar_code
            and exception_set_id = -1
            and seq_num = p_seq_num
            and shift_num =p_shift_num;
        exception
            when no_data_found
               then l_eff_date := null;
        end;

        if l_timezone_enabled and l_eff_date is not null then
            l_converted_date := hz_timezone_pub.convert_datetime(l_server_id,
                                                                 l_client_id,
                                                                 l_eff_date);
        else
            l_converted_date := l_eff_date;
        end if;

        return l_converted_date;
    end get_date_for_seq;

    /* To obtain date for a given seq_num and shift_num */
    function get_date(p_org_id in number,
                      p_seq_num in number,
                      p_shift_num in number)
    return date
    is
        l_eff_date Date;
        l_calendar_code varchar2(50);
    begin
        l_calendar_code := get_calendar_code(p_org_id);
        begin
            select shift_date
            into l_eff_date
            from bom_shift_dates
            where calendar_code = l_calendar_code
            and exception_set_id = -1
            and seq_num = p_seq_num
            and shift_num =p_shift_num;
            return l_eff_date;
        exception
            when no_data_found then return null;
        end;
    end get_date;

    function get_index_for_date(p_date in date,
                                p_organization_id in number,
                                p_dept_id in number,
                                p_resource_id in number)
    return varchar2
    is
        l_date_seq number;
        l_shift_num number;
        l_shift_start_date date;
        l_shift_end_date date;
        l_calendar_code varchar2(100);
    begin

        l_calendar_code := get_calendar_code(p_organization_id);
        wip_ws_dl_util.get_first_dept_resource_shift
                                (p_cal_code         =>l_calendar_code,
                                 p_dept_id          =>p_dept_id,
                                 p_resource_id      =>p_resource_id,
                                 p_date             =>p_date,
                                 x_shift_seq        =>l_date_seq,
                                 x_shift_num        =>l_shift_num,
                                 x_shift_start_date =>l_shift_start_date,
                                 x_shift_end_date   =>l_shift_end_date);

        return to_char(l_date_seq||':'||l_shift_num);
    end get_index_for_date;

    procedure handle_error(p_error_msg in varchar2,
                           p_stmt_num in number,
                           p_proc_name in varchar2)
    is
    begin
        fnd_file.put_line(fnd_file.log,'Error in '||p_proc_name||'( stmt_num: '||p_stmt_num||') '||p_error_msg);
        fnd_file.new_line(fnd_file.log, 3);
    end handle_error;

    /* To calculate metrics for the required period */
    procedure calculate_metrics(retcode out nocopy number,
                                errbuf  out nocopy varchar2,
                                p_organization_id in number)
    is

    /* Record type for storing metrics data for a particular employee */
    type rec_emp_perf_temp IS record(
     actual_date_seq  number,
     shift_num        number,
     shift_start      date,
     shift_end        date,
     shift_duration   number,
     act_att_hrs      number,
     dir_lab_hrs      number,
     sch_avl_hrs      number,
     earned_hrs       number);

    /* PL/SQL table for storing metrics data for a particular employee */
    type t_emp_perf_temp is table of rec_emp_perf_temp index by varchar2(25);
    v_emp_perf_temp             t_emp_perf_temp;

    type t_wip_lab_perf_rate is table of wip_labor_performance_rates%rowtype index by binary_integer;
    v_wip_lab_perf_rate             t_wip_lab_perf_rate;

    type t_date_sequence is table of wip_labor_performance_rates.date_sequence%type      index by binary_integer;
    type t_shift_num     is table of wip_labor_performance_rates.shift_num%type          index by binary_integer;
    type t_m1_att1       is table of wip_labor_performance_rates.metric1_attribute1%type index by binary_integer;
    type t_m1_att2       is table of wip_labor_performance_rates.metric1_attribute2%type index by binary_integer;
    type t_m2_att1       is table of wip_labor_performance_rates.metric2_attribute1%type index by binary_integer;
    type t_m2_att2       is table of wip_labor_performance_rates.metric2_attribute2%type index by binary_integer;
    type t_m3_att1       is table of wip_labor_performance_rates.metric3_attribute1%type index by binary_integer;
    type t_m3_att2       is table of wip_labor_performance_rates.metric3_attribute2%type index by binary_integer;

    v_date_sequence   t_date_sequence;
    v_shift_num       t_shift_num;
    v_m1_att1         t_m1_att1;
    v_m1_att2         t_m1_att2;
    v_m2_att1         t_m2_att1;
    v_m2_att2         t_m2_att2;
    v_m3_att1         t_m3_att1;
    v_m3_att2         t_m3_att2;

    /* cursor to get all employees for a particular organization */
    cursor employees(org_id number) is
    select bre.organization_id,
    bdri.department_id,
    bdri.resource_id,
    bdri.instance_id,
    bre.person_id
    from per_all_people_f papf,
    bom_resource_employees bre,
    bom_dept_res_instances bdri,
    bom_department_resources bdr,
    bom_resources br
    where papf.person_id = bre.person_id
    and bre.instance_id = bdri.instance_id
    and sysdate between papf.effective_start_date and nvl(papf.effective_end_date,sysdate+1)
    and bre.resource_id = bdri.resource_id
    and bdri.department_id = bdr.department_id
    and bdri.resource_id = bdr.resource_id
    and bdr.resource_id = br.resource_id
    and bdr.available_24_hours_flag  = 2
    and wip_ws_labor_metric_pub.is_time_uom(br.unit_of_measure) = 1
    and bre.organization_id = org_id
    order by bdri.department_id,
    bdri.resource_id;

    /* cursor to get all preferences value for a particular organization */
    cursor get_preferences(org_id number) is
    select attribute_name,
    substr(attribute_name,2,1) as identifier,
    attribute_value_code
    from wip_preference_values
    where preference_id = 35
    and level_id = 1
    and sequence_number = (select sequence_number
                           from wip_preference_values
                           where preference_id = 35
                           and level_id = 1
                           and attribute_name = 'Org'
                           and attribute_value_code = to_char(org_id))
    order by 1 desc;

    /* This Cursor will get the information of all shifts for a department resource in the required period. */
    -- Modified Date conversion logic for Bug 6972082.
    cursor emp_shifts(p_calendar_code varchar2,
                      start_period date,
                      end_period date,
                      dept_id number,
                      res_id number) is
    select trunc(bsd.seq_num) shift_date_seq,
    bsd.shift_num shift_num,
    bsd.shift_date + st.from_time/(60*60*24) shift_start_time,
    bsd.shift_date + st.to_time/(60*60*24) shift_end_time,
    (bsd.shift_date + st.to_time/(60*60))-(bsd.shift_date + st.from_time/(60*60)) shift_duration
    from bom_shift_dates bsd,
    (select bst.shift_num,
     min(bst.from_time) from_time,
     max(bst.to_time + decode(sign(bst.to_time - bst.from_time), -1, (24*60*60), 0)) to_time
     from bom_shift_times bst
     where bst.calendar_code = p_calendar_code
     group by bst.shift_num) st,
    bom_calendar_shifts bcs,
    bom_resource_shifts brs
    where bsd.calendar_code = p_calendar_code
    and bsd.exception_set_id = -1
    and bsd.shift_date between trunc(start_period) and trunc(end_period)
    and bsd.shift_num = st.shift_num
    and bsd.seq_num is not null
    and bsd.calendar_code = bcs.calendar_code
    and bsd.shift_num = bcs.shift_num
    and fnd_date.canonical_to_date(to_char((bsd.shift_date + st.to_time/(60*60*24)),WIP_CONSTANTS.DATETIME_FMT)) < end_period
    and brs.shift_num= bcs.shift_num
    and brs.department_id = dept_id
    and brs.resource_id = res_id;

    /* cursor to get records from wip_resource_actual_times for calculating AAH */
    cursor aah_records(org_id number,
                       emp_id number,
                       start_time date,
                       end_time date) is
    select start_date as actual_date,
    decode(action_flag,2,-duration,duration) as duration,
    uom_code
    from wip_resource_actual_times
    where organization_id = org_id
    and employee_id = emp_id
    and wip_entity_id is null
    and time_entry_mode in (6,8)
    and start_date between start_time and end_time
    and duration is not null;

    /* cursor to get records from wip_resource_actual_times for calculating SAH */
    cursor sah_records(org_id number,
                       emp_id number,
                       start_time date,
                       end_time date) is
    select start_date as actual_date,
    decode(action_flag,2,-duration,duration) as duration,
    uom_code
    from wip_resource_actual_times
    where organization_id = org_id
    and employee_id = emp_id
    and wip_entity_id is null
    and time_entry_mode =7
    and start_date between start_time and end_time
    and duration is not null;

    /* cursor to get all records from wip_resource_actual_times for calculating DLH */
    -- Lot based jobs also uses wip_resource_actual_times. So added condition on entity_type.
    cursor dlh_records(org_id number,
                       dept_id number,
                       res_id number,
                       emp_id number,
                       start_time date,
                       end_time date) is
    select wrat.start_date as actual_date,
    decode(wrat.action_flag,2,-wrat.duration,wrat.duration) as duration,
    wrat.uom_code
    from wip_resource_actual_times wrat,
    wip_operations wo,
    wip_entities we
    where wrat.organization_id = org_id
    and wrat.organization_id= wo.organization_id
    and wrat.wip_entity_id = wo.wip_entity_id
    and we.organization_id = wo.organization_id
    and we.wip_entity_id = wo.wip_entity_id
    and we.entity_type=1
    and wrat.operation_seq_num = wo.operation_seq_num
    and wo.department_id = dept_id
    and wrat.resource_id = res_id
    and wrat.employee_id = emp_id
    and wrat.wip_entity_id is not null
    and wrat.duration is not null
    and wrat.start_date between start_time and end_time;

    /* Bug 7010115: cursor to get all Job-Ops from Clock-In records for calculating earned hours */
    cursor clock_in_records(org_id number,
                            dept_id number,
                            res_id number,
                            emp_id number,
                            start_time date,
                            end_time date) is
    select distinct wrat.wip_entity_id as wip_entity_id,
    wrat.operation_seq_num as operation_seq_num,
    get_index_for_date(wrat.start_date,wrat.organization_id,wo.department_id,res_id) as emp_index
    from wip_resource_actual_times wrat,
    wip_operations wo,
    wip_entities we
    where wrat.organization_id = org_id
    and wrat.organization_id= wo.organization_id
    and wrat.wip_entity_id = wo.wip_entity_id
    and we.organization_id = wo.organization_id
    and we.wip_entity_id = wo.wip_entity_id
    and we.entity_type=1
    and wrat.operation_seq_num = wo.operation_seq_num
    and wo.department_id = dept_id
    and wrat.resource_id = res_id
    and wrat.employee_id = emp_id
    and wrat.wip_entity_id is not null
    and wrat.duration is not null
    and wrat.start_date between start_time and end_time;

    /* cursor to get all records from wip_move_transactions, wip_operations for obtaining completed quantity */
    /* Modified for Bug 7010115. */
    -- Lot based jobs should not be considered for earned hours. So added condition on entity_type.
    cursor eh_records(org_id number,
                      start_time date,
                      end_time date,
                      wip_id number,
                      op_seq number,
                      res_id number,
                      indx varchar2)
    is
    select sum(nvl(t.move_qty,0)) as moved_qty
    from
    (select
      wo.wip_entity_id as job,
      wo.operation_seq_num as op,
      fm_operation_seq_num as fm_op,
      fm_intraoperation_step_type as fm_step,
      to_operation_seq_num as to_op,
      to_intraoperation_step_type as to_step,
      decode(wmt.to_intraoperation_step_type,
        1, (case when ((wmt.to_operation_seq_num > wo.operation_seq_num)) then wmt.primary_quantity
                 when ((wmt.to_operation_seq_num < wo.operation_seq_num)) then -1 * wmt.primary_quantity
                 when (wmt.to_operation_seq_num <= wmt.fm_operation_seq_num
                       and wmt.to_operation_seq_num = wo.operation_seq_num
                       and wmt.fm_intraoperation_step_type not in (4,5))  then -1 * wmt.primary_quantity
            else 0 end),
        2, (case when ((wmt.to_operation_seq_num > wo.operation_seq_num))  then wmt.primary_quantity
                 when ((wmt.to_operation_seq_num < wo.operation_seq_num))  then -1 * wmt.primary_quantity
                 when (wmt.to_operation_seq_num <= wmt.fm_operation_seq_num
                       and wmt.to_operation_seq_num = wo.operation_seq_num
                       and wmt.fm_intraoperation_step_type not in (4,5))   then -1 * wmt.primary_quantity
            else 0 end),
        3, (case when (wmt.to_operation_seq_num >= wo.operation_seq_num) then wmt.primary_quantity
                 when (wmt.to_operation_seq_num < wo.operation_seq_num
                       and (wmt.fm_intraoperation_step_type not in (4,5)
                            or wmt.fm_operation_seq_num <> wo.operation_seq_num)) then -1 * wmt.primary_quantity
            else 0 end),
        5, (case when wmt.to_operation_seq_num > wo.operation_seq_num then wmt.primary_quantity
                 when wmt.to_operation_seq_num < wo.operation_seq_num then -1 * wmt.primary_quantity
                 when wmt.to_operation_seq_num = wo.operation_seq_num then 0
            else 0 end),
        4, (case when wmt.to_operation_seq_num > wo.operation_seq_num then wmt.primary_quantity
                 when wmt.to_operation_seq_num < wo.operation_seq_num then -1 * wmt.primary_quantity
                 when wmt.to_operation_seq_num = wo.operation_seq_num then 0
            else 0 end),
        0) as move_qty,
      get_index_for_date(wmt.transaction_date,wmt.organization_id,wo.department_id,res_id) as emp_index
     from
      wip_move_transactions wmt,
      wip_operations wo,
      wip_entities we
     where
      wo.organization_id = org_id
      and wo.organization_id = wmt.organization_id
      and wo.organization_id = we.organization_id
      and wo.wip_entity_id = we.wip_entity_id
      and we.entity_type=1
      and wo.wip_entity_id = wmt.wip_entity_id
      and wo.operation_seq_num = op_seq
      and wo.wip_entity_id = wip_id
      and wo.repetitive_schedule_id is null
      and wmt.transaction_date between start_time and end_time
      and ((wo.operation_seq_num >= wmt.fm_operation_seq_num + decode(sign(wmt.fm_intraoperation_step_type - 2),1,1,0)
            and wo.operation_seq_num < wmt.to_operation_seq_num + decode(sign(wmt.to_intraoperation_step_type - 2),1,1,0)
            and (wmt.to_operation_seq_num > wmt.fm_operation_seq_num
                 or (wmt.to_operation_seq_num = wmt.fm_operation_seq_num
                     and wmt.fm_intraoperation_step_type <= 2
                     and wmt.to_intraoperation_step_type > 2)))
      or (wo.operation_seq_num < wmt.fm_operation_seq_num + decode(sign(wmt.fm_intraoperation_step_type-2),1,1,0)
          and wo.operation_seq_num >= wmt.to_operation_seq_num + decode(sign(wmt.to_intraoperation_step_type-2),1,1,0)
          and (wmt.fm_operation_seq_num > wmt.to_operation_seq_num
               or (wmt.fm_operation_seq_num = wmt.to_operation_seq_num
                   and wmt.to_intraoperation_step_type <= 2
                   and wmt.fm_intraoperation_step_type > 2)))
      or (wmt.fm_intraoperation_step_type in (4,5)
          and wo.operation_seq_num = wmt.fm_operation_seq_num))) t
    where
    t.emp_index = indx;

    cursor ear_hours_calc(org_id number,
                          we_ent_id number,
                          op_seq_num number,
                          res_id number,
                          move_qty number)
    is
    select usage_rate_or_amount *decode(sign(move_qty),-1,0,move_qty) usage_rate,uom_code,basis_type
    from wip_operation_resources
    where organization_id= org_id
    and wip_entity_id= we_ent_id
    and operation_seq_num= op_seq_num
    and resource_id = res_id;

    /* local variables */
    l_prev_department_id number   :=null;
    l_prev_resource_id   number   :=null;
    l_calendar_code varchar2(100) := null;
    l_bom_uom_code  varchar2(3)   :=null;
    l_time_uom_flag number        :=null;
    l_uom_code varchar2(3);
    l_current_date date           := null;
    window_end_time date          :=null;
    window_start_time date        :=null;

    l_act_avl_hrs_required     boolean := false;
    l_dir_lab_hrs_required     boolean := false;
    l_sch_avl_hrs_required     boolean := false;
    l_earned_hrs_required      boolean := false;

    /* variables for preferences */
    l_metric1_required boolean := false;
    l_metric2_required boolean := false;
    l_metric3_required boolean := false;
    l_metric1_attribute1 number :=0;
    l_metric1_attribute2 number :=0;
    l_metric2_attribute1 number :=0;
    l_metric2_attribute2 number :=0;
    l_metric3_attribute1 number :=0;
    l_metric3_attribute2 number :=0;

    log_metric1            varchar2(30):= 'Disabled';
    log_metric2            varchar2(30):= 'Disabled';
    log_metric3            varchar2(30):= 'Disabled';
    log_act_avl_hrs        varchar2(30):= 'Not Required';
    log_dir_lab_hrs        varchar2(30):= 'Not Required';
    log_sch_avl_hrs        varchar2(30):= 'Not Required';
    log_earned_hrs         varchar2(30):= 'Not Required';

    l_act_att_hrs        number :=0;
    l_dir_lab_hrs        number :=0;
    l_sch_avl_hrs        number :=0;
    l_earned_hrs         number :=0;

    g_user_id         number;
    g_user_login_id   number;
    g_program_appl_id number;
    g_request_id      number;
    g_program_id      number;
    g_logLevel        number;

    l_date_seq         number       := null;
    l_shift_num        number       := null;
    l_shift_start_date date         := null;
    l_shift_end_date   date         := null;

    l_stmt_num number := null;
    l_proc_name varchar2(50) := 'WIP_WS_LABOR_METRIC_PUB.CALCULATE_METRICS';

    l_org_code varchar2(3);
    l_pgm_count number :=0;

    emp_index varchar2(25) := null;
    idx varchar2(25) := null;
    new_index number;

    x_error_msg varchar2(2000);
    l_error_count number:=0;
    l_conc_status boolean;

    e_null_org_id  exception;

    is_aah_record_valid boolean;
    is_sah_record_valid boolean;
    is_dlh_record_valid boolean;
    is_eh_record_valid boolean;

    begin

    l_stmt_num :=10;
    g_user_id         := fnd_global.user_id;
    g_user_login_id   := fnd_global.login_id;
    g_program_appl_id := fnd_global.prog_appl_id;
    g_request_id      := fnd_global.conc_request_id;
    g_program_id      := fnd_global.conc_program_id;

    g_logLevel        := FND_LOG.g_current_runtime_level;

    if p_organization_id is null then
        raise e_null_org_id;
    end if;

    select organization_code
    into l_org_code
    from mtl_parameters
    where organization_id = p_organization_id;

    wip_ws_util.trace_log('Launching Labor Metrics Calculation for Organization: '||l_org_code);

    l_stmt_num :=20;

    /* If the calculation program is running for this org already, then error out.
        Bug 6891668. Modified Logic for Checking Concurrency */

    select  count(1)
    into l_pgm_count
    from fnd_concurrent_requests
    where program_application_id = g_program_appl_id
    and concurrent_program_id = g_program_id
    and upper(phase_code) = 'R'
    and argument1 = to_char(p_organization_id);

    if (l_pgm_count > 1) then
        fnd_message.set_name('WIP','WIP_RUNNING_LABOR_PRG');
        fnd_message.set_token('ORG', to_char(l_org_code));
        x_error_msg := fnd_message.get;
        wip_ws_util.trace_log('Error in '||l_proc_name||'( stmt_num: '||l_stmt_num||') '||x_error_msg);
        wip_ws_util.trace_log('Unable to run calculation program for this organization. Please try after some time.');
        retcode := 2;
        l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',
        'Errors encountered in calculation program, please check the log file.');
        return;
    end if;

    /* Get window_end_time and window_start_time to determine the
       Time window for metrics calculation. */

    select sysdate
    into l_current_date
    from dual;

    l_stmt_num :=30;

    l_bom_uom_code := fnd_profile.value('BOM:HOUR_UOM_CODE');
    l_calendar_code := get_calendar_code(p_organization_id);
    window_end_time := get_period_end(l_calendar_code,l_current_date);
    window_start_time := get_period_start(p_organization_id,window_end_time);

    if (g_logLevel <= wip_constants.trace_logging) then
        wip_ws_util.trace_log('Calendar: '||l_calendar_code);
        wip_ws_util.trace_log('Start Time: '||to_char(window_start_time,WIP_CONSTANTS.DATETIME_FMT));
        wip_ws_util.trace_log('End Time: '||to_char(window_end_time,WIP_CONSTANTS.DATETIME_FMT));
        wip_ws_util.trace_log('Base Time UOM: '||l_bom_uom_code);
    end if;

    l_stmt_num :=40;
    /* Check for the metrics preferences and its requirement: Start */

    for preferences in get_preferences(p_organization_id) loop
       if preferences.identifier = '1' then
          if l_metric1_required then
             if preferences.attribute_value_code ='1' then  /* 1-AAH,2-SAH,3-DLH,4-EH  */
                l_act_avl_hrs_required := true;
                log_act_avl_hrs := 'Required';
                if preferences.attribute_name = 'M1Attribute1' then
                   l_metric1_attribute1 :=1;
                else
                   l_metric1_attribute2 :=1;
                end if;
             elsif preferences.attribute_value_code ='2' then
                l_sch_avl_hrs_required := true;
                log_sch_avl_hrs :='Required';
                if preferences.attribute_name = 'M1Attribute1' then
                   l_metric1_attribute1 :=2;
                else
                   l_metric1_attribute2 :=2;
                end if;
             elsif preferences.attribute_value_code ='3' then
                l_dir_lab_hrs_required := true;
                log_dir_lab_hrs := 'Required';
                if preferences.attribute_name = 'M1Attribute1' then
                   l_metric1_attribute1 :=3;
                else
                   l_metric1_attribute2 :=3;
                end if;
             else
                l_earned_hrs_required := true;
                log_earned_hrs := 'Required';
                if preferences.attribute_name = 'M1Attribute1' then
                   l_metric1_attribute1 :=4;
                else
                   l_metric1_attribute2 :=4;
                end if;
             end if;
          end if;
          if preferences.attribute_name = 'M1Enabled' and preferences.attribute_value_code ='1' then
             l_metric1_required := true;
             log_metric1 := 'Enabled';
          end if;
       elsif preferences.identifier = '2' then
          if l_metric2_required then
             if preferences.attribute_value_code ='1' then  /* 1-AAH,2-SAH,3-DLH,4-EH  */
                l_act_avl_hrs_required := true;
                log_act_avl_hrs := 'Required';
                if preferences.attribute_name = 'M2Attribute1' then
                   l_metric2_attribute1 :=1;
                else
                   l_metric2_attribute2 :=1;
                end if;
             elsif preferences.attribute_value_code ='2' then
                l_sch_avl_hrs_required := true;
                log_sch_avl_hrs :='Required';
                if preferences.attribute_name = 'M2Attribute1' then
                   l_metric2_attribute1 :=2;
                else
                   l_metric2_attribute2 :=2;
                end if;
             elsif preferences.attribute_value_code ='3' then
                l_dir_lab_hrs_required := true;
                log_dir_lab_hrs := 'Required';
                if preferences.attribute_name = 'M2Attribute1' then
                   l_metric2_attribute1 :=3;
                else
                   l_metric2_attribute2 :=3;
                end if;
             else
                l_earned_hrs_required := true;
                log_earned_hrs := 'Required';
                if preferences.attribute_name = 'M2Attribute1' then
                   l_metric2_attribute1 :=4;
                else
                   l_metric2_attribute2 :=4;
                end if;
             end if;
          end if;
          if preferences.attribute_name = 'M2Enabled' and preferences.attribute_value_code ='1' then
             l_metric2_required := true;
             log_metric2 := 'Enabled';
          end if;
       elsif preferences.identifier = '3' then
          if l_metric3_required then
             if preferences.attribute_value_code ='1' then  /* 1-AAH,2-SAH,3-DLH,4-EH  */
                l_act_avl_hrs_required := true;
                log_act_avl_hrs := 'Required';
                if preferences.attribute_name = 'M3Attribute1' then
                   l_metric3_attribute1 :=1;
                else
                   l_metric3_attribute2 :=1;
                end if;
             elsif preferences.attribute_value_code ='2' then
                l_sch_avl_hrs_required := true;
                log_sch_avl_hrs :='Required';
                if preferences.attribute_name = 'M3Attribute1' then
                   l_metric3_attribute1 :=2;
                else
                   l_metric3_attribute2 :=2;
                end if;
             elsif preferences.attribute_value_code ='3' then
                l_dir_lab_hrs_required := true;
                log_dir_lab_hrs := 'Required';
                if preferences.attribute_name = 'M3Attribute1' then
                   l_metric3_attribute1 :=3;
                else
                   l_metric3_attribute2 :=3;
                end if;
             else
                l_earned_hrs_required := true;
                log_earned_hrs := 'Required';
                if preferences.attribute_name = 'M3Attribute1' then
                   l_metric3_attribute1 :=4;
                else
                   l_metric3_attribute2 :=4;
                end if;
             end if;
          end if;
          if preferences.attribute_name = 'M3Enabled' and preferences.attribute_value_code ='1' then
             l_metric3_required := true;
             log_metric3 := 'Enabled';
          end if;
       end if;
    end loop;

    l_stmt_num :=50;

    if (g_logLevel <= wip_constants.trace_logging) then

        wip_ws_util.trace_log('Metric 1: '||log_metric1);
        wip_ws_util.trace_log('Metric 2: '||log_metric2);
        wip_ws_util.trace_log('Metric 3: '||log_metric3);

        wip_ws_util.trace_log('Actual Attendance Hours: '||log_act_avl_hrs);
        wip_ws_util.trace_log('Scheduled Available Hours: '||log_sch_avl_hrs);
        wip_ws_util.trace_log('Direct Labor Hours: '||log_dir_lab_hrs);
        wip_ws_util.trace_log('Earned Hours: '||log_earned_hrs);

    end if;

    /* Check for the metrics preferences and its requirement: End */

    if l_metric1_required or l_metric2_required or l_metric3_required then
        /* Delete existing records in wip_labor_performance_rates table for the org.*/

            delete from wip_labor_performance_rates
            where organization_id= p_organization_id;

        l_stmt_num :=60;

        if (g_logLevel <= wip_constants.trace_logging) then
            wip_ws_util.trace_log('Deleted Existing records for this Organization.');
        end if;
        /* calculate the metrics for every employee associated to any of
           the department for this organization.  */
        new_index :=0;
        for employee in employees(p_organization_id) Loop

           if (g_logLevel <= wip_constants.trace_logging) then
               wip_ws_util.trace_log('Calculation for Emp with Dep_Id: '||to_char(employee.department_id)
                                   ||' Res_Id: '||to_char(employee.resource_id)
                                   ||' Pers_Id: '||to_char(employee.person_id));
           end if;

           if ( l_prev_department_id is null                   or
                l_prev_resource_id is null                     or
                employee.department_id <> l_prev_department_id or
                employee.resource_id <> l_prev_resource_id)
           then
                   l_stmt_num :=70;
                   v_emp_perf_temp.delete;
                   for emp_shift in emp_shifts(l_calendar_code,
                                               window_start_time,
                                               window_end_time,
                                               employee.department_id,
                                               employee.resource_id)
                   loop
                        l_stmt_num :=80;
                        emp_index := to_char(emp_shift.shift_date_seq||':'||emp_shift.shift_num);
                        v_emp_perf_temp(emp_index).actual_date_seq :=emp_shift.shift_date_seq;
                        v_emp_perf_temp(emp_index).shift_num       :=emp_shift.shift_num;
                        v_emp_perf_temp(emp_index).shift_start     :=emp_shift.shift_start_time;
                        v_emp_perf_temp(emp_index).shift_end       :=emp_shift.shift_end_time;
                        v_emp_perf_temp(emp_index).shift_duration  :=emp_shift.shift_duration;
                        v_emp_perf_temp(emp_index).act_att_hrs     :=0;
                        v_emp_perf_temp(emp_index).dir_lab_hrs     :=0;
                        v_emp_perf_temp(emp_index).sch_avl_hrs     :=0;
                        v_emp_perf_temp(emp_index).earned_hrs      :=0;
                        if (g_logLevel <= wip_constants.trace_logging) then
                            wip_ws_util.trace_log('Employee Shift Info: '||emp_index);
                        end if;
                   end loop;
                   if (g_logLevel <= wip_constants.trace_logging) then
                       wip_ws_util.trace_log('Re-Creating Shift Information for Employee');
                   end if;
           else
                   l_stmt_num :=90;
                   emp_index := v_emp_perf_temp.first;
                   while emp_index <= v_emp_perf_temp.last loop
                        v_emp_perf_temp(emp_index).act_att_hrs :=0;
                        v_emp_perf_temp(emp_index).dir_lab_hrs :=0;
                        v_emp_perf_temp(emp_index).sch_avl_hrs :=0;
                        v_emp_perf_temp(emp_index).earned_hrs  :=0;
                        emp_index := v_emp_perf_temp.next(emp_index);
                   end loop;

                   if (g_logLevel <= wip_constants.trace_logging) then
                       wip_ws_util.trace_log('Re-Using Shift Information for Employee');
                   end if;
           end if;

           if l_act_avl_hrs_required then /* Calculate actual available hours here. */
              l_stmt_num :=100;
              for emp_act_avl_hrs in aah_records(p_organization_id,
                                                 employee.person_id,
                                                 window_start_time,
                                                 window_end_time)
              loop
                  l_stmt_num :=110;
                  is_aah_record_valid := true;
                  wip_ws_dl_util.get_first_dept_resource_shift
                                (p_cal_code         =>l_calendar_code,
                                 p_dept_id          =>employee.department_id,
                                 p_resource_id      =>employee.resource_id,
                                 p_date             =>emp_act_avl_hrs.actual_date,
                                 x_shift_seq        =>l_date_seq,
                                 x_shift_num        =>l_shift_num,
                                 x_shift_start_date =>l_shift_start_date,
                                 x_shift_end_date   =>l_shift_end_date);

                  /* UOM validations and conversions */
                  l_time_uom_flag := is_time_uom(emp_act_avl_hrs.uom_code);
                  l_stmt_num :=120;
                  -- Modified for bug 6972129.
                  if l_time_uom_flag = 2 then
                      if (g_logLevel <= wip_constants.trace_logging) then
                          fnd_message.set_name('WIP','WIP_LM_TIME_UOM');
                          fnd_message.set_token('EMP', to_char(employee.person_id));
                          x_error_msg := fnd_message.get;
                          wip_ws_util.trace_log(l_proc_name||'( stmt_num: '||l_stmt_num||') '||x_error_msg);
                          --l_error_count := l_error_count + 1;
                      end if;
                      is_aah_record_valid := false;
                  end if;
                  if is_aah_record_valid then
                      if emp_act_avl_hrs.duration is not null and emp_act_avl_hrs.uom_code <> l_bom_uom_code then
                          l_stmt_num :=130;
                          l_act_att_hrs := inv_convert.inv_um_convert(item_id       => -1,
                                                                      precision     => 38,
                                                                      from_quantity => emp_act_avl_hrs.duration,
                                                                      from_unit     => emp_act_avl_hrs.uom_code,
                                                                      to_unit       => l_bom_uom_code,
                                                                      from_name     => null,
                                                                      to_name       => null);
                      else
                          l_act_att_hrs := emp_act_avl_hrs.duration;
                      end if;
                      l_stmt_num :=140;
                      -- Modified for Bug 7150089. Added this condition to avoid calculation if a shift
                      -- exists across multiple days and record is present for first day in that shift.
                      if v_emp_perf_temp.exists(to_char(l_date_seq||':'||l_shift_num)) then
                          v_emp_perf_temp(to_char(l_date_seq||':'||l_shift_num)).act_att_hrs :=
                          v_emp_perf_temp(to_char(l_date_seq||':'||l_shift_num)).act_att_hrs+l_act_att_hrs;

                          if (g_logLevel <= wip_constants.trace_logging) then
                              wip_ws_util.trace_log('Dep: '||to_char(employee.department_id)||
                                                    ' Res: '||to_char(employee.resource_id)||
                                                    ' Pers: '||to_char(employee.person_id)||
                                                    ' Date: '||to_char(emp_act_avl_hrs.actual_date,WIP_CONSTANTS.DATETIME_FMT)||
                                                    ' Shift Seq: '||to_char(l_date_seq)||
                                                    ' Shift Num: '||to_char(l_shift_num)||
                                                    ' AAH Value: '||to_char(l_act_att_hrs));
                          end if;
                      end if;
                  end if;
             end loop;
           end if; /* if l_act_avl_hrs_required then */

           if l_sch_avl_hrs_required then /* Calculate scheduled available hours here. */
                l_stmt_num :=150;
                /* Add Code for capacity changes and exceptions and factor it on the shift duration. */
               emp_index := v_emp_perf_temp.first;
               while emp_index <= v_emp_perf_temp.last loop
                        v_emp_perf_temp(emp_index).sch_avl_hrs := v_emp_perf_temp(emp_index).shift_duration;
                        emp_index := v_emp_perf_temp.next(emp_index);
               end loop;
               l_stmt_num :=160;
               for emp_sch_avl_hrs in sah_records(p_organization_id,
                                                  employee.person_id,
                                                  window_start_time,
                                                  window_end_time)
              loop
                  l_stmt_num :=170;
                  is_sah_record_valid :=true;
                  wip_ws_dl_util.get_first_dept_resource_shift
                                (p_cal_code         =>l_calendar_code,
                                 p_dept_id          =>employee.department_id,
                                 p_resource_id      =>employee.resource_id,
                                 p_date             =>emp_sch_avl_hrs.actual_date,
                                 x_shift_seq        =>l_date_seq,
                                 x_shift_num        =>l_shift_num,
                                 x_shift_start_date =>l_shift_start_date,
                                 x_shift_end_date   =>l_shift_end_date);

                  /* UOM validations and conversions */
                  l_time_uom_flag := is_time_uom(emp_sch_avl_hrs.uom_code);
                  l_stmt_num :=180;
                  -- Modified for bug 6972129.
                  if l_time_uom_flag = 2 then
                      if (g_logLevel <= wip_constants.trace_logging) then
                          fnd_message.set_name('WIP','WIP_LM_TIME_UOM');
                          fnd_message.set_token('EMP', to_char(employee.person_id));
                          x_error_msg := fnd_message.get;
                          wip_ws_util.trace_log(l_proc_name||'( stmt_num: '||l_stmt_num||') '||x_error_msg);
                          --l_error_count := l_error_count + 1;
                      end if;
                      is_sah_record_valid :=false;
                  end if;
                  if is_sah_record_valid then
                      if emp_sch_avl_hrs.duration is not null and emp_sch_avl_hrs.uom_code <> l_bom_uom_code then
                          l_stmt_num :=190;
                          l_sch_avl_hrs := inv_convert.inv_um_convert(item_id       => -1,
                                                                      precision     => 38,
                                                                      from_quantity => emp_sch_avl_hrs.duration,
                                                                      from_unit     => emp_sch_avl_hrs.uom_code,
                                                                      to_unit       => l_bom_uom_code,
                                                                      from_name     => null,
                                                                      to_name       => null);
                      else
                          l_sch_avl_hrs := emp_sch_avl_hrs.duration;
                      end if;
                      l_stmt_num :=200;
                      -- Modified for Bug 7150089. Added this condition to avoid calculation if a shift
                      -- exists across multiple days and record is present for first day in that shift.
                      if v_emp_perf_temp.exists(to_char(l_date_seq||':'||l_shift_num)) then
                          v_emp_perf_temp(to_char(l_date_seq||':'||l_shift_num)).sch_avl_hrs :=
                          v_emp_perf_temp(to_char(l_date_seq||':'||l_shift_num)).sch_avl_hrs+l_sch_avl_hrs;

                          if (g_logLevel <= wip_constants.trace_logging) then
                              wip_ws_util.trace_log('Dep: '||to_char(employee.department_id)||
                                                    ' Res: '||to_char(employee.resource_id)||
                                                    ' Pers: '||to_char(employee.person_id)||
                                                    ' Date: '||to_char(emp_sch_avl_hrs.actual_date,WIP_CONSTANTS.DATETIME_FMT)||
                                                    ' Shift Seq: '||to_char(l_date_seq)||
                                                    ' Shift Num: '||to_char(l_shift_num)||
                                                    ' SAH Value: '||to_char(l_sch_avl_hrs));
                          end if;
                      end if;
                  end if;
             end loop;
           end if; /* if l_sch_avl_hrs_required then */

           if l_dir_lab_hrs_required then /* Calculate direct labor hours here. */
              l_stmt_num :=210;
              for emp_dir_lab_hrs in dlh_records(p_organization_id,
                                                 employee.department_id,
                                                 employee.resource_id,
                                                 employee.person_id,
                                                 window_start_time,
                                                 window_end_time)
              loop
                  l_stmt_num :=220;
                  is_dlh_record_valid :=true;
                  wip_ws_dl_util.get_first_dept_resource_shift
                                (p_cal_code         =>l_calendar_code,
                                 p_dept_id          =>employee.department_id,
                                 p_resource_id      =>employee.resource_id,
                                 p_date             =>emp_dir_lab_hrs.actual_date,
                                 x_shift_seq        =>l_date_seq,
                                 x_shift_num        =>l_shift_num,
                                 x_shift_start_date =>l_shift_start_date,
                                 x_shift_end_date   =>l_shift_end_date);

                  /* UOM validations and conversions */
                  l_time_uom_flag := is_time_uom(emp_dir_lab_hrs.uom_code);
                  l_stmt_num :=230;
                  -- Modified for bug 6972129.
                  if l_time_uom_flag = 2 then
                      if (g_logLevel <= wip_constants.trace_logging) then
                          fnd_message.set_name('WIP','WIP_LM_TIME_UOM');
                          fnd_message.set_token('EMP', to_char(employee.person_id));
                          x_error_msg := fnd_message.get;
                          wip_ws_util.trace_log(l_proc_name||'( stmt_num: '||l_stmt_num||') '||x_error_msg);
                          --l_error_count := l_error_count + 1;
                      end if;
                      is_dlh_record_valid :=false;
                  end if;
                  if is_dlh_record_valid then
                      if emp_dir_lab_hrs.duration is not null and emp_dir_lab_hrs.uom_code <> l_bom_uom_code then
                          l_stmt_num :=240;
                          l_dir_lab_hrs := inv_convert.inv_um_convert(item_id       => -1,
                                                                      precision     => 38,
                                                                      from_quantity => emp_dir_lab_hrs.duration,
                                                                      from_unit     => emp_dir_lab_hrs.uom_code,
                                                                      to_unit       => l_bom_uom_code,
                                                                      from_name     => null,
                                                                      to_name       => null);
                      else
                          l_dir_lab_hrs := emp_dir_lab_hrs.duration;
                      end if;
                      l_stmt_num :=250;
                      idx := to_char(l_date_seq||':'||l_shift_num);
                      l_stmt_num :=260;
                      -- Modified for Bug 7150089. Added this condition to avoid calculation if a shift
                      -- exists across multiple days and record is present for first day in that shift.
                      if v_emp_perf_temp.exists(to_char(l_date_seq||':'||l_shift_num)) then
                          v_emp_perf_temp(to_char(l_date_seq||':'||l_shift_num)).dir_lab_hrs :=
                          v_emp_perf_temp(to_char(l_date_seq||':'||l_shift_num)).dir_lab_hrs+l_dir_lab_hrs;

                          if (g_logLevel <= wip_constants.trace_logging) then
                              wip_ws_util.trace_log('Dep: '||to_char(employee.department_id)||
                                                    ' Res: '||to_char(employee.resource_id)||
                                                    ' Pers: '||to_char(employee.person_id)||
                                                    ' Date: '||to_char(emp_dir_lab_hrs.actual_date,WIP_CONSTANTS.DATETIME_FMT)||
                                                    ' Shift Seq: '||to_char(l_date_seq)||
                                                    ' Shift Num: '||to_char(l_shift_num)||
                                                    ' DLH Value: '||to_char(l_dir_lab_hrs));
                          end if;
                      end if;
                  end if;
                  l_stmt_num :=270;
             end loop;
           end if; /* l_dir_lab_hrs_required */
           l_stmt_num :=280;
           if l_earned_hrs_required then /* Calculate earned hours here. */
               l_stmt_num :=290;
               /* Modified for Bug 7010115. */
               for emp_clock_rec in clock_in_records(p_organization_id,
                                                     employee.department_id,
                                                     employee.resource_id,
                                                     employee.person_id,
                                                     window_start_time,
                                                     window_end_time)
               loop
                   for emp_earned_hrs in eh_records(p_organization_id,
                                                    window_start_time,
                                                    window_end_time,
                                                    emp_clock_rec.wip_entity_id,
                                                    emp_clock_rec.operation_seq_num,
                                                    employee.resource_id,
                                                    emp_clock_rec.emp_index)
                   loop
                       for earned_hrs_rates in ear_hours_calc(p_organization_id,
                                                              emp_clock_rec.wip_entity_id,
                                                              emp_clock_rec.operation_seq_num,
                                                              employee.resource_id,
                                                              emp_earned_hrs.moved_qty)
                       loop
                           is_eh_record_valid := true;
                           l_earned_hrs := earned_hrs_rates.usage_rate;
                           l_uom_code   := earned_hrs_rates.uom_code ;
                           l_time_uom_flag := is_time_uom(l_uom_code);
                           l_stmt_num :=310;
                           -- Modified for bug 6972129.
                           if l_time_uom_flag = 2 then
                               if (g_logLevel <= wip_constants.trace_logging) then
                                   fnd_message.set_name('WIP','WIP_LM_TIME_UOM');
                                   fnd_message.set_token('EMP', to_char(employee.person_id));
                                   x_error_msg := fnd_message.get;
                                   wip_ws_util.trace_log(l_proc_name||'( stmt_num: '||l_stmt_num||') '||x_error_msg);
                                   --l_error_count := l_error_count + 1;
                               end if;
                               is_eh_record_valid := false;
                           end if;
                           if earned_hrs_rates.basis_type = 2 then
                               if (g_logLevel <= wip_constants.trace_logging) then
                                   fnd_message.set_name('WIP','WIP_LM_LOT_BASED_RES');
                                   fnd_message.set_token('EMP', to_char(employee.person_id));
                                   x_error_msg := fnd_message.get;
                                   wip_ws_util.trace_log(l_proc_name||'( stmt_num: '||l_stmt_num||') '||x_error_msg);
                                   --l_error_count := l_error_count + 1;
                               end if;
                               is_eh_record_valid := false;
                           end if;
                           if is_eh_record_valid then
                               if l_earned_hrs is not null and l_uom_code <> l_bom_uom_code then
                                   l_stmt_num :=320;
                                   l_earned_hrs := inv_convert.inv_um_convert(item_id       => -1,
                                                                              precision     => 38,
                                                                              from_quantity => l_earned_hrs,
                                                                              from_unit     => l_uom_code,
                                                                              to_unit       => l_bom_uom_code,
                                                                              from_name     => null,
                                                                              to_name       => null);
                               end if;
                               l_stmt_num :=330;
                               -- Modified for Bug 7150089. Added this condition to avoid calculation if a shift
                               -- exists across multiple days and record is present for first day in that shift.
                               if v_emp_perf_temp.exists(emp_clock_rec.emp_index) then
                                   v_emp_perf_temp(emp_clock_rec.emp_index).earned_hrs :=
                                   v_emp_perf_temp(emp_clock_rec.emp_index).earned_hrs+l_earned_hrs;

                                   if (g_logLevel <= wip_constants.trace_logging) then
                                       wip_ws_util.trace_log('Dep: '||to_char(employee.department_id)||
                                                             ' Res: '||to_char(employee.resource_id)||
                                                             ' Pers: '||to_char(employee.person_id)||
                                                             ' Index: '||to_char(emp_clock_rec.emp_index)||
                                                             ' Move Qty: '||to_char(emp_earned_hrs.moved_qty)||
                                                             ' EH Value: '||to_char(l_earned_hrs));
                                   end if;
                               end if;
                           end if;
                           l_stmt_num :=340;
                       end loop;
                   end loop;
               end loop;
           end if;  /* if l_earned_hrs_required then */
           l_stmt_num :=350;

           /* transfer data from collection indexed by varchar2 to a collection
              indexed by binary_integer so that we can bulk insert in the table.
              Also initialize the new collection always. */
           emp_index := v_emp_perf_temp.first;
           while emp_index <= v_emp_perf_temp.last loop
               if emp_index <> ':' or emp_index is not null then
                   new_index := new_index+1;
                   v_wip_lab_perf_rate(new_index).Organization_id        := p_organization_id;
                   v_wip_lab_perf_rate(new_index).Department_id          := employee.department_id;
                   v_wip_lab_perf_rate(new_index).Resource_id            := employee.resource_id;
                   v_wip_lab_perf_rate(new_index).Employee_id            := employee.person_id;
                   v_wip_lab_perf_rate(new_index).date_sequence          := v_emp_perf_temp(emp_index).actual_date_seq;
                   v_wip_lab_perf_rate(new_index).Shift_num              := v_emp_perf_temp(emp_index).shift_num;
                   case l_metric1_attribute1 when 1 then v_wip_lab_perf_rate(new_index).Metric1_attribute1 := v_emp_perf_temp(emp_index).act_att_hrs;
                                             when 2 then v_wip_lab_perf_rate(new_index).Metric1_attribute1 := v_emp_perf_temp(emp_index).sch_avl_hrs;
                                             when 3 then v_wip_lab_perf_rate(new_index).Metric1_attribute1 := v_emp_perf_temp(emp_index).dir_lab_hrs;
                                             when 4 then v_wip_lab_perf_rate(new_index).Metric1_attribute1 := v_emp_perf_temp(emp_index).earned_hrs;
                                             else v_wip_lab_perf_rate(new_index).Metric1_attribute1 :=0;
                   end case;
                   case l_metric1_attribute2 when 1 then v_wip_lab_perf_rate(new_index).Metric1_attribute2 := v_emp_perf_temp(emp_index).act_att_hrs;
                                             when 2 then v_wip_lab_perf_rate(new_index).Metric1_attribute2 := v_emp_perf_temp(emp_index).sch_avl_hrs;
                                             when 3 then v_wip_lab_perf_rate(new_index).Metric1_attribute2 := v_emp_perf_temp(emp_index).dir_lab_hrs;
                                             when 4 then v_wip_lab_perf_rate(new_index).Metric1_attribute2 := v_emp_perf_temp(emp_index).earned_hrs;
                                             else v_wip_lab_perf_rate(new_index).Metric1_attribute2 :=0;
                   end case;
                   case l_metric2_attribute1 when 1 then v_wip_lab_perf_rate(new_index).Metric2_attribute1 := v_emp_perf_temp(emp_index).act_att_hrs;
                                             when 2 then v_wip_lab_perf_rate(new_index).Metric2_attribute1 := v_emp_perf_temp(emp_index).sch_avl_hrs;
                                             when 3 then v_wip_lab_perf_rate(new_index).Metric2_attribute1 := v_emp_perf_temp(emp_index).dir_lab_hrs;
                                             when 4 then v_wip_lab_perf_rate(new_index).Metric2_attribute1 := v_emp_perf_temp(emp_index).earned_hrs;
                                             else v_wip_lab_perf_rate(new_index).Metric2_attribute1 :=0;
                   end case;
                   case l_metric2_attribute2 when 1 then v_wip_lab_perf_rate(new_index).Metric2_attribute2 := v_emp_perf_temp(emp_index).act_att_hrs;
                                             when 2 then v_wip_lab_perf_rate(new_index).Metric2_attribute2 := v_emp_perf_temp(emp_index).sch_avl_hrs;
                                             when 3 then v_wip_lab_perf_rate(new_index).Metric2_attribute2 := v_emp_perf_temp(emp_index).dir_lab_hrs;
                                             when 4 then v_wip_lab_perf_rate(new_index).Metric2_attribute2 := v_emp_perf_temp(emp_index).earned_hrs;
                                             else v_wip_lab_perf_rate(new_index).Metric2_attribute2 :=0;
                   end case;
                   case l_metric3_attribute1 when 1 then v_wip_lab_perf_rate(new_index).Metric3_attribute1 := v_emp_perf_temp(emp_index).act_att_hrs;
                                             when 2 then v_wip_lab_perf_rate(new_index).Metric3_attribute1 := v_emp_perf_temp(emp_index).sch_avl_hrs;
                                             when 3 then v_wip_lab_perf_rate(new_index).Metric3_attribute1 := v_emp_perf_temp(emp_index).dir_lab_hrs;
                                             when 4 then v_wip_lab_perf_rate(new_index).Metric3_attribute1 := v_emp_perf_temp(emp_index).earned_hrs;
                                             else v_wip_lab_perf_rate(new_index).Metric3_attribute1 :=0;
                   end case;
                   case l_metric3_attribute2 when 1 then v_wip_lab_perf_rate(new_index).Metric3_attribute2 := v_emp_perf_temp(emp_index).act_att_hrs;
                                             when 2 then v_wip_lab_perf_rate(new_index).Metric3_attribute2 := v_emp_perf_temp(emp_index).sch_avl_hrs;
                                             when 3 then v_wip_lab_perf_rate(new_index).Metric3_attribute2 := v_emp_perf_temp(emp_index).dir_lab_hrs;
                                             when 4 then v_wip_lab_perf_rate(new_index).Metric3_attribute2 := v_emp_perf_temp(emp_index).earned_hrs;
                                             else v_wip_lab_perf_rate(new_index).Metric3_attribute2 :=0;
                   end case;
                   v_wip_lab_perf_rate(new_index).Created_by             := g_user_id;
                   v_wip_lab_perf_rate(new_index).Creation_date          := sysdate;
                   v_wip_lab_perf_rate(new_index).Last_updated_by        := g_user_id;
                   v_wip_lab_perf_rate(new_index).Last_update_date       := sysdate;
                   v_wip_lab_perf_rate(new_index).Last_update_login      := g_user_login_id;
                   v_wip_lab_perf_rate(new_index).Object_version_number  := 1;
                   v_wip_lab_perf_rate(new_index).Request_id             := g_request_id;
                   v_wip_lab_perf_rate(new_index).Program_id             := g_program_id;
                   v_wip_lab_perf_rate(new_index).Program_application_id := g_program_appl_id;
                   v_wip_lab_perf_rate(new_index).Program_update_date    := sysdate;
               end if;
               emp_index := v_emp_perf_temp.next(emp_index);
           end loop;
           l_stmt_num :=360;

           if (g_logLevel <= wip_constants.trace_logging) then
               wip_ws_util.trace_log(' Calculation Completed for employee Dep: '||to_char(employee.department_id)||
                                            ' Res: '||to_char(employee.resource_id)||
                                            ' Pers: '||to_char(employee.person_id));
           end if;
           l_stmt_num :=370;

           l_prev_department_id := employee.department_id ;
           l_prev_resource_id   := employee.resource_id ;

        end loop;  /* for employee in employees(p_organization_id) */

        l_stmt_num :=380;

        /* Bulk Insert Records into Metrics Table */
        forall cntr in v_wip_lab_perf_rate.first..v_wip_lab_perf_rate.last
           INSERT into WIP_LABOR_PERFORMANCE_RATES values v_wip_lab_perf_rate(cntr);

        l_stmt_num :=390;
        if (g_logLevel <= wip_constants.trace_logging) then
               wip_ws_util.trace_log('Insertion of all calculated records is successful.');
        end if;

        /* Since attendance hours is entered for an employee at org level and distributed across all departments
           if the employee is associated to multiple departments. So org level attendance hours will be over shooted
           when summing the value in the dashboard. So we compute the org level summary and insert into metrics table.*/
        select t.date_sequence,
               t.shift_num,
               sum(t.m1_att1),
               sum(t.m1_att2),
               sum(t.m2_att1),
               sum(t.m2_att2),
               sum(t.m3_att1),
               sum(t.m3_att2)
        bulk collect into
               v_date_sequence,
               v_shift_num,
               v_m1_att1,
               v_m1_att2,
               v_m2_att1,
               v_m2_att2,
               v_m3_att1,
               v_m3_att2
        from (
              select date_sequence,
                     shift_num,
                     decode(l_metric1_attribute1,1,max(metric1_attribute1),sum(metric1_attribute1)) m1_att1,
                     decode(l_metric1_attribute2,1,max(metric1_attribute2),sum(metric1_attribute2)) m1_att2,
                     decode(l_metric2_attribute1,1,max(metric2_attribute1),sum(metric2_attribute1)) m2_att1,
                     decode(l_metric2_attribute2,1,max(metric2_attribute2),sum(metric2_attribute2)) m2_att2,
                     decode(l_metric3_attribute1,1,max(metric3_attribute1),sum(metric3_attribute1)) m3_att1,
                     decode(l_metric3_attribute2,1,max(metric3_attribute2),sum(metric3_attribute2)) m3_att2
              from wip_labor_performance_rates
              where organization_id = p_organization_id
              group by
              date_sequence,
              shift_num,
              employee_id
             )t
        group by
        t.date_sequence,
        t.shift_num;

        l_stmt_num :=400;
        if (g_logLevel <= wip_constants.trace_logging) then
               wip_ws_util.trace_log('Computed Org Level Summary Data.');
        end if;

        /* Insert into Metrics Table the org level summary data. Use -1 for dept,res and employee */
        forall org_index in v_shift_num.first..v_shift_num.last
        insert into wip_labor_performance_rates
        (
         ORGANIZATION_ID,
         DEPARTMENT_ID,
         RESOURCE_ID,
         EMPLOYEE_ID,
         DATE_SEQUENCE,
         SHIFT_NUM,
         METRIC1_ATTRIBUTE1,
         METRIC1_ATTRIBUTE2,
         METRIC2_ATTRIBUTE1,
         METRIC2_ATTRIBUTE2,
         METRIC3_ATTRIBUTE1,
         METRIC3_ATTRIBUTE2,
         CREATED_BY,
         CREATION_DATE,
         LAST_UPDATED_BY,
         LAST_UPDATE_DATE,
         LAST_UPDATE_LOGIN,
         PROGRAM_APPLICATION_ID,
         PROGRAM_UPDATE_DATE,
         PROGRAM_ID,
         REQUEST_ID,
         OBJECT_VERSION_NUMBER
        )
        values
        (
         p_organization_id,
         -1,
         -1,
         -1,
         v_date_sequence(org_index),
         v_shift_num(org_index),
         v_m1_att1(org_index),
         v_m1_att2(org_index),
         v_m2_att1(org_index),
         v_m2_att2(org_index),
         v_m3_att1(org_index),
         v_m3_att2(org_index),
         g_user_id,
         sysdate,
         g_user_id,
         sysdate,
         g_user_login_id,
         g_program_appl_id,
         sysdate,
         g_program_id,
         g_request_id,
         1);

        l_stmt_num :=400;
        if (g_logLevel <= wip_constants.trace_logging) then
               wip_ws_util.trace_log('Insertion of Org Level Summary Data is successful.');
        end if;

        end if; /* l_metric1_required or l_metric2_required or l_metric3_required */

        l_stmt_num :=410;
        wip_ws_util.trace_log('Labor Metrics Calculation completed.');

        commit;

        if l_error_count=0  then
            l_conc_status := true;
            retcode:=0;
        else
            retcode := 1;
            errbuf := 'Calculation program encountered invalid records. Invalid records will be ignored during calculation.';
            fnd_file.put_line(fnd_file.log,errbuf);
            l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('WARNING',errbuf);
        end if;

    exception
        when e_null_org_id then
            retcode := 2;
            errbuf := 'Organization parameter cannot be null';
            fnd_file.put_line(fnd_file.log,errbuf);
            l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',errbuf);
        when others then
            fnd_message.set_name('WIP','WIP_LAB_UNEXPECTED_ERROR');
            x_error_msg := fnd_message.get;
            wip_ws_util.trace_log('Error in '||l_proc_name||'( stmt_num: '||l_stmt_num||') '||x_error_msg);
            x_error_msg := sqlerrm(sqlcode);
            wip_ws_util.trace_log('Error in '||l_proc_name||'( stmt_num: '||l_stmt_num||') '||x_error_msg);
            rollback;
            retcode := 2;
            errbuf := 'Errors encountered in calculation program, please check the log file.';
            l_conc_status := FND_CONCURRENT.SET_COMPLETION_STATUS('ERROR',errbuf);

    end calculate_metrics;

    /* To obtain Client Date for a given Server Date (Used in Charts only) */
    function get_client_date(p_date in Date)
    return date
    is
        l_converted_date date;
        l_timezone_enabled boolean := ( fnd_profile.value('ENABLE_TIMEZONE_CONVERSIONS') = 'Y' AND
                                        fnd_profile.value('CLIENT_TIMEZONE_ID') IS NOT NULL AND
                                        fnd_profile.value('SERVER_TIMEZONE_ID') IS NOT NULL AND
                                        fnd_profile.value('CLIENT_TIMEZONE_ID') <>
                                        fnd_profile.value('SERVER_TIMEZONE_ID'));
        l_client_id number := fnd_profile.value('CLIENT_TIMEZONE_ID');
        l_server_id number := fnd_profile.value('SERVER_TIMEZONE_ID');
    begin

        if l_timezone_enabled and p_date is not null then
            l_converted_date := hz_timezone_pub.convert_datetime(l_server_id,
                                                                 l_client_id,
                                                                 p_date);
        else
            l_converted_date := p_date;
        end if;

        return l_converted_date;
    end get_client_date;

END WIP_WS_LABOR_METRIC_PUB;

/
