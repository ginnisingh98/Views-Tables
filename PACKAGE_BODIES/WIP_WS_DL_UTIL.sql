--------------------------------------------------------
--  DDL for Package Body WIP_WS_DL_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WS_DL_UTIL" as
/* $Header: wipwsdlb.pls 120.21.12010000.5 2010/02/19 08:52:20 hliew ship $ */

  procedure get_first_calendar_date
  (
    l_cal_code varchar2,
    p_date date,
    x_seq out nocopy number,
    x_start_date out nocopy date,
    x_end_date out nocopy date
  )
  Is
    l_next_seq number;
  Begin
    select bcd.next_seq_num, bcd.seq_num, bcd.calendar_date, bcd.calendar_date + 1
    into l_next_seq, x_seq, x_start_date, x_end_date
    from bom_calendar_dates bcd
    where bcd.calendar_code = l_cal_code and
          bcd.exception_set_id = -1 and
          bcd.calendar_date = trunc(p_date);

    if( x_seq is null) then
      select bcd.seq_num, bcd.calendar_date, bcd.calendar_date + 1
      into x_seq, x_start_date, x_end_date
      from bom_calendar_dates bcd
      where bcd.calendar_code = l_cal_code and
            bcd.exception_set_id = -1 and
            bcd.seq_num = l_next_seq;
    end if;
  End get_first_calendar_date;

  procedure get_first_calendar_shift
  (
    p_cal_code varchar2,
    p_date date,
    x_shift_seq out nocopy number,
    x_shift_num out nocopy number,
    x_shift_start_date out nocopy date,
    x_shift_end_date out nocopy date
  )
  Is
    l_cur_date date;
    l_prior_date date;
    l_next_date date;
  Begin

  /* initialize the out variables */
  x_shift_seq := null;
  x_shift_num := null;
  x_shift_start_date := null;
  x_shift_end_date := null;

  /* find out the day that is on */
  select min(bsd.shift_date)
  into l_cur_date
  from bom_shift_dates bsd
  where bsd.calendar_code = p_cal_code and
    bsd.shift_date >= trunc( p_date )and
    bsd.seq_num is not null;

  /* find out prior and next day in calendar */
  select max(bsd.shift_date)
  into l_prior_date
  from bom_shift_dates bsd
  where bsd.calendar_code = p_cal_code and
        bsd.shift_date < l_cur_date and
        bsd.seq_num is not null;

  select min(bsd.shift_date)
  into l_next_date
  from bom_shift_dates bsd
  where bsd.calendar_code = p_cal_code and
        bsd.shift_date > l_cur_date and
        bsd.seq_num is not null;

  /* find out the closest shift that is running or going to run */
  select
    seq_num,
    shift_num,
    shift_date + from_time/(60*60*24),
    shift_date + to_time/(60*60*24)
  into
    x_shift_seq,
    x_shift_num,
    x_shift_start_date,
    x_shift_end_date
  from
  (
    select bsd.shift_date,
           bsd.shift_num,
           bsd.seq_num,
           st.from_time,
           st.to_time
    from bom_shift_dates bsd,
         ( select bst.shift_num,
                  min(bst.from_time) from_time,
                  max (bst.to_time + decode(sign(bst.to_time - bst.from_time), -1, (24*60*60), 0) ) to_time
           from bom_shift_times bst
           where bst.calendar_code = p_cal_code
           group by bst.shift_num
         ) st
     where bsd.calendar_code = p_cal_code and
           bsd.shift_num = st.shift_num and
           (bsd.shift_date + st.to_time / (60 * 60 * 24)) > p_date and
           bsd.shift_date in (l_cur_date, l_prior_date, l_next_date)
     order by bsd.shift_date + st.from_time / (60 * 60 * 24)
   ) t
   where rownum = 1;


  Exception when others then
    null;
  End get_first_calendar_shift;

  procedure get_first_dept_resource_shift
  (
    p_cal_code varchar2,
    p_dept_id number,
    p_resource_id number,
    p_date date,
    x_shift_seq out nocopy number,
    x_shift_num out nocopy number,
    x_shift_start_date out nocopy date,
    x_shift_end_date out nocopy date
  )
  Is
    l_cur_date date;
    l_prior_date date;
    l_next_date date;
  Begin

  /* initialize the out variables */
  x_shift_seq := null;
  x_shift_num := null;
  x_shift_start_date := null;
  x_shift_end_date := null;

  /* find out the day that is on */
  select min(bsd.shift_date)
  into l_cur_date
  from bom_shift_dates bsd, bom_resource_shifts brs
  where bsd.calendar_code = p_cal_code and
    bsd.shift_date >= trunc( p_date )and
    brs.department_id = p_dept_id and
    brs.resource_id = nvl( p_resource_id, brs.resource_id) and
    brs.shift_num = bsd.shift_num and
    bsd.exception_set_id = -1 and
    bsd.seq_num is not null;

  /* find out prior and next day in calendar */
  select max(bsd.shift_date)
  into l_prior_date
  from bom_shift_dates bsd, bom_resource_shifts brs
  where bsd.calendar_code = p_cal_code and
        bsd.shift_date < l_cur_date and
        brs.department_id = p_dept_id and
        brs.resource_id = nvl( p_resource_id, brs.resource_id) and
        brs.shift_num = bsd.shift_num and
        bsd.exception_set_id = -1 and
        bsd.seq_num is not null;

  select min(bsd.shift_date)
  into l_next_date
  from bom_shift_dates bsd, bom_resource_shifts brs
  where bsd.calendar_code = p_cal_code and
        bsd.shift_date > l_cur_date and
        brs.department_id = p_dept_id and
        brs.resource_id = nvl( p_resource_id, brs.resource_id) and
        brs.shift_num = bsd.shift_num and
        bsd.exception_set_id = -1 and
        bsd.seq_num is not null;

  /* find out the closest shift that is running or going to run */
  select
    seq_num,
    shift_num,
    shift_date + from_time/(60*60*24),
    shift_date + to_time/(60*60*24)
  into
    x_shift_seq,
    x_shift_num,
    x_shift_start_date,
    x_shift_end_date
  from
  (
    select bsd.shift_date,
           bsd.shift_num,
           bsd.seq_num,
           st.from_time,
           st.to_time
    from bom_shift_dates bsd,
         ( select bst.shift_num,
                  min(bst.from_time) from_time,
                  max (bst.to_time + decode(sign(bst.to_time - bst.from_time), -1, (24*60*60), 0) ) to_time
           from bom_shift_times bst
           where bst.calendar_code = p_cal_code
           group by bst.shift_num
         ) st ,
         bom_resource_shifts brs
     where bsd.calendar_code = p_cal_code and
           bsd.shift_num = st.shift_num and
           brs.department_id = p_dept_id and
           brs.resource_id = nvl( p_resource_id, brs.resource_id) and
           brs.shift_num = bsd.shift_num and
           (bsd.shift_date + st.to_time / (60 * 60 * 24)) > p_date and
           bsd.shift_date in (l_cur_date, l_prior_date, l_next_date)
     order by bsd.shift_date + st.from_time / (60 * 60 * 24)
   ) t
   where rownum = 1;


  Exception when others then
    null;
  End get_first_dept_resource_shift;

  procedure get_first_shift
  (
    p_cal_code varchar2,
    p_dept_id number,
    p_resource_id number,
    p_date date,
    x_shift_seq out nocopy number,
    x_shift_num out nocopy number,
    x_shift_start_date out nocopy date,
    x_shift_end_date out nocopy date
  )
  Is
  Begin
     if( p_dept_id is null) then
       get_first_calendar_shift(p_cal_code, p_date, x_shift_seq, x_shift_num, x_shift_start_date, x_shift_end_date);
     else
       get_first_dept_resource_shift(p_cal_code, p_dept_id, p_resource_id, p_date,
             x_shift_seq, x_shift_num, x_shift_start_date, x_shift_end_date);
     end if;
  End get_first_shift;

  function get_col_job_on_name
  (
    p_employee_id number
  ) return varchar2
  is
  begin
      return wip_ws_util.get_employee_name(p_employee_id, null);
  end get_col_job_on_name;


  /* return the sum of qty in both place - direct previous op, the closest check point op
     , if they are the same, only count it once */
  function get_col_total_prior_qty
  (
    p_wip_entity_id number,
    p_op_seq number
  ) return number
  is
    l_qty number;
  begin

    select sum( wo1.quantity_in_queue + wo1.quantity_running + wo1.quantity_waiting_to_move + wo1.quantity_rejected)
    into l_qty
    from wip_operations wo1
    where wo1.wip_entity_id = p_wip_entity_id and
          ( wo1.operation_seq_num =
            ( select wo2.previous_operation_seq_num
              from wip_operations wo2
              where wo2.wip_entity_id = p_wip_entity_id and
                    wo2.operation_seq_num = p_op_seq
            )
            or
            wo1.operation_seq_num =
            ( select max( wo3.operation_seq_num )
              from wip_operations wo3
              where wo3.wip_entity_id = p_wip_entity_id and
                     wo3.operation_seq_num < p_op_seq and
                     wo3.count_point_type = 1
            )
          );

    return l_qty;
  exception when others then
    return null;
  end;

  function get_col_customer
  (
    p_org_id number,
    p_wip_entity_id number
  ) return varchar2
  is
    cursor c_num_customers(p_org_id number, p_wip_entity_id number)
    Is
     select count(distinct ool.sold_to_org_id)
       from HZ_CUST_ACCOUNTS cust_accnt, mtl_reservations mr,
            mtl_sales_orders mso, oe_order_lines_all ool
            , wip_discrete_jobs wdj
       where mso.sales_order_id = mr.demand_source_header_id
         and mr.demand_source_line_id = ool.line_id
         and mr.demand_source_type_id = 2
         and mr.supply_source_type_id = 5
         and ool.sold_to_org_id = cust_accnt.cust_account_id
         and mr.supply_source_header_id = wdj.wip_entity_id
         and mr.organization_id = wdj.organization_id
         and wdj.organization_id = p_org_id
         and wdj.wip_entity_id = p_wip_entity_id;
    cursor c_ustomers(p_org_id number, p_wip_entity_id number)
    Is
     select cust_party.party_name
       from HZ_CUST_ACCOUNTS cust_accnt, HZ_PARTIES cust_party,
            mtl_reservations mr, mtl_sales_orders mso, oe_order_lines_all ool,
            wip_discrete_jobs wdj
       where mso.sales_order_id = mr.demand_source_header_id
         and mr.demand_source_line_id = ool.line_id
         and mr.demand_source_type_id = 2
         and mr.supply_source_type_id = 5
         and ool.sold_to_org_id = cust_accnt.cust_account_id
         and cust_party.party_id = cust_accnt.party_id
         and mr.supply_source_header_id = wdj.wip_entity_id
         and mr.organization_id = wdj.organization_id
         and wdj.organization_id = p_org_id
         and wdj.wip_entity_id = p_wip_entity_id;

    l_count number;
    l_name varchar2(256);
  begin
    l_name := '';
    open c_num_customers(p_org_id, p_wip_entity_id);
    fetch c_num_customers into l_count;
    close c_num_customers;
    if (l_count > 1 ) then
      fnd_message.SET_NAME('WIP', 'WIP_WS_DL_MULTIPLE');
      return fnd_message.GET;
    elsif ( l_count = 1 ) then
      open c_ustomers(p_org_id, p_wip_entity_id);
      fetch c_ustomers into l_name;
      close c_ustomers;
    end if;

    return(l_name);
  end;

  function get_col_sales_order
  (
    p_org_id number,
    p_wip_entity_id number
  ) return varchar2
  is
    cursor c_num_sales_orders(p_org_id number, p_wip_entity_id number)
    Is
     select count(distinct mso.segment1)
     from mtl_reservations mr, mtl_sales_orders mso,
       oe_order_lines_all ool, wip_discrete_jobs wdj
     where mso.sales_order_id = mr.demand_source_header_id
       and mr.demand_source_line_id = ool.line_id
       and mr.demand_source_type_id = 2
       and mr.supply_source_type_id = 5
       and mr.supply_source_header_id = wdj.wip_entity_id
       and mr.organization_id = wdj.organization_id
       and wdj.organization_id = p_org_id
       and wdj.wip_entity_id = p_wip_entity_id;

    cursor c_sales_orders(p_org_id number, p_wip_entity_id number)
    Is
     select mso.concatenated_segments
     from mtl_reservations mr, mtl_sales_orders_kfv mso,
       oe_order_lines_all ool, wip_discrete_jobs wdj
     where mso.sales_order_id = mr.demand_source_header_id
       and mr.demand_source_line_id = ool.line_id
       and mr.demand_source_type_id = 2
       and mr.supply_source_type_id = 5
       and mr.supply_source_header_id = wdj.wip_entity_id
       and mr.organization_id = wdj.organization_id
       and wdj.organization_id = p_org_id
       and wdj.wip_entity_id = p_wip_entity_id;

    l_count number;
    l_name varchar2(256);
  begin
    l_name := '';
    open c_num_sales_orders(p_org_id, p_wip_entity_id);
    fetch c_num_sales_orders into l_count;
    close c_num_sales_orders;
    if (l_count > 1 ) then
      fnd_message.SET_NAME('WIP', 'WIP_WS_DL_MULTIPLE');
      return fnd_message.GET;
    elsif ( l_count = 1 ) then
      open c_sales_orders(p_org_id, p_wip_entity_id);
      fetch c_sales_orders into l_name;
      close c_sales_orders;
    end if;

    return(l_name);
  end;

  /* need to concatenate the shift seq and shift num to uniquely identify a shift */
  function get_col_shift_id
  (
    p_org_id number,
    p_dept_id number,
    p_resource_id number,
    p_op_date date,
    p_expedited varchar2,
    p_first_shift_id varchar2,
    p_first_shift_end_date date
  )
  return varchar2
  Is
    l_cal_code varchar2(30);

    l_shift_seq number;
    l_shift_num number;
    l_shift_start_date date;
    l_shift_end_date date;
    l_24hr_resource number;
    l_ret varchar2(30);
  Begin

    if( p_expedited = 'Y' ) then
      return p_first_shift_id;
    end if;

    if( p_op_date <= p_first_shift_end_date ) then
      return p_first_shift_id;
    end if;

    select mp.calendar_code
    into l_cal_code
    from mtl_parameters mp
    where mp.organization_id = p_org_id;

    if( p_resource_id is not null ) then
      select bdr.available_24_hours_flag
      into l_24hr_resource
      from bom_department_resources bdr
      where bdr.department_id = p_dept_id and
            bdr.resource_id = p_resource_id;
    else
      l_24hr_resource := null;
    end if;

    if( l_24hr_resource = 2 ) then
      get_first_shift(l_cal_code, p_dept_id, p_resource_id, p_op_date,
        l_shift_seq, l_shift_num, l_shift_start_date, l_shift_end_date);

      l_ret := l_shift_seq || '.' || l_shift_num;
    else
      /*
      get_first_calendar_date(l_cal_code, p_op_date, l_shift_seq, l_shift_start_date, l_shift_end_date);

      l_ret := l_shift_seq; */
      /* if it's 24 hour resource, we treat all jobops as if they are in one shift
         and the capacity would be 0, since using an arbitary day boundary would be
         misleading too - per barry's decision */
      l_ret := 1;
    end if;

    return l_ret;

  end get_col_shift_id;

  function get_col_exception
  (
    p_wip_entity_id number,
    p_op_seq number
  ) return varchar
  is
    cursor c_num_exceptions(p_wip_entity_id number, p_op_seq number)
    Is
      select count(we.exception_id)
      from wip_exceptions we
      where we.wip_entity_id = p_wip_entity_id and
            we.operation_seq_num = p_op_seq and
            we.status_type = 1;

    cursor c_exceptions(p_wip_entity_id number, p_op_seq number)
    Is
      select ml.MEANING
      from wip_exceptions we, mfg_lookups ml
      where we.wip_entity_id = p_wip_entity_id and
            we.operation_seq_num = p_op_seq and
            we.status_type = 1 and
            ml.LOOKUP_CODE = we.exception_type and
            ml.LOOKUP_TYPE = 'WIP_EXCEPTION_TYPE';

    l_count number;
    l_name varchar2(80);
  begin
    l_name := '';
    open c_num_exceptions(p_wip_entity_id, p_op_seq);
    fetch c_num_exceptions into l_count;
    close c_num_exceptions;
    if (l_count > 1 ) then
      fnd_message.SET_NAME('WIP', 'WIP_WS_DL_MULTIPLE');
      return fnd_message.GET;
    elsif ( l_count = 1 ) then
      open c_exceptions(p_wip_entity_id, p_op_seq);
      fetch c_exceptions into l_name;
      close c_exceptions;
    end if;

    return(l_name);
  end;

  function get_col_project
  (
    p_wip_entity_id number
  ) return varchar
  is
    l_name varchar2(100);
  begin
    select decode(wdj.project_id, null, null,
      pjm_project.all_proj_idtonum(wdj.project_id))
    into l_name
    from  wip_discrete_jobs wdj
    where wdj.wip_entity_id = p_wip_entity_id;

    return l_name;
  Exception
    when others then
    return null;
  end;

  function get_col_task
  (
    p_wip_entity_id number
  ) return varchar
  is
    l_name varchar2(100);
  begin
    select decode(wdj.task_id, null, null,
        pjm_project.all_task_idtonum(wdj.task_id))
    into l_name
    from wip_discrete_jobs wdj
    where wdj.wip_entity_id = p_wip_entity_id;

    return l_name;
  Exception
    when others then
    return null;
  end;

  /* need to pass in resource id? */
  function get_col_resource_setup
  (
    p_wip_entity_id number,
    p_op_seq number
  ) return varchar
  is
    cursor c_num_setups(p_wip_entity_id number, p_op_seq number)
    Is
      select count(distinct wor.setup_id)
      from wip_operation_resources wor
      where wor.wip_entity_id = p_wip_entity_id and
            wor.operation_seq_num = p_op_seq;

    cursor c_setups(p_wip_entity_id number, p_op_seq number)
    Is
      select bst.setup_code
      from wip_operation_resources wor, bom_setup_types bst
      where wor.wip_entity_id = p_wip_entity_id and
            wor.operation_seq_num = p_op_seq and
            wor.setup_id = bst.setup_id;

    l_count number;
    l_name varchar2(10);
  begin
    l_name := '';
    open c_num_setups(p_wip_entity_id, p_op_seq);
    fetch c_num_setups into l_count;
    close c_num_setups;
    if (l_count > 1 ) then
      fnd_message.SET_NAME('WIP', 'WIP_WS_DL_MULTIPLE');
      return fnd_message.GET;
    elsif ( l_count = 1 ) then
      open c_setups(p_wip_entity_id, p_op_seq);
      fetch c_setups into l_name;
      close c_setups;
    end if;

    return(l_name);
  end;

  function get_col_component_uom(p_org_id number, p_comp_id number) return varchar2
  Is
    l_uom varchar2(3);
  Begin
    if( p_comp_id is null) then
      return null;
    end if;

    select msi.primary_uom_code
    into l_uom
    from mtl_system_items_b msi
    where msi.organization_id = p_org_id and
          msi.inventory_item_id = p_comp_id;

    return l_uom;
  End get_col_component_uom;

  function get_col_component_usage
  (
    p_org_id number,
    p_wip_entity_id number,
    p_op_seq number,
    p_comp_id number
  ) return number
  is
    l_qty_open_requirements number;
    l_qty_required number;
    l_qty_issued number;
    l_qty_allocated number;
    l_qty_per number;
    l_op_qty number;
    l_qty_completed number;
    l_cumulative_scrap_qty number;
    l_basis_type number;
    l_yield number;

    l_qty_tmp number;
    cursor c_requirements(p_org_id number, p_wip_entity_id number, p_op_seq number, p_com_id number)
    Is
      select nvl(wro.basis_type, 1),
        wro.required_quantity, wro.quantity_issued, wro.quantity_per_assembly,
        decode(mp.include_component_yield, 1, nvl(wro.component_yield_factor, 1), 1)
      from wip_requirement_operations wro, wip_parameters mp
      where wro.organization_id = p_org_id and
          wro.wip_entity_id = p_wip_entity_id and
          mp.organization_id = wro.organization_id and
          wro.operation_seq_num = p_op_seq and
          wro.inventory_item_id = p_comp_id;

  begin

    select  wo.scheduled_quantity, wo.quantity_completed, nvl(wo.cumulative_scrap_quantity, 0)
    into l_op_qty, l_qty_completed, l_cumulative_scrap_qty
    from wip_operations wo
    where wo.organization_id = p_org_id and
          wo.wip_entity_id = p_wip_entity_id and
          wo.operation_seq_num = p_op_seq;

    l_qty_open_requirements := 0;
    open c_requirements(p_org_id, p_wip_entity_id, p_op_seq, p_comp_id);
    loop
      fetch c_requirements into l_basis_type, l_qty_required, l_qty_issued, l_qty_per, l_yield;
      exit when c_requirements%NOTFOUND;

      if( l_basis_Type = 1 ) then /* item */
        l_qty_tmp :=  l_qty_required/l_yield - l_qty_issued - l_qty_per * l_cumulative_scrap_qty/l_yield;
        if( l_qty_tmp > 0 ) then
          l_qty_open_requirements := l_qty_open_requirements + l_qty_tmp;
        end if;
      else
        l_qty_tmp := l_qty_required/l_yield - l_qty_issued;
        if( l_qty_tmp > 0 ) then
          l_qty_open_requirements := l_qty_open_requirements + l_qty_tmp;
        end if;
      end if;
    end loop;
    close c_requirements;

    begin
      l_qty_allocated := wip_picking_pub.quantity_allocated(p_wip_entity_id => p_wip_entity_id,
                                                p_operation_seq_num => p_op_seq,
                                                p_organization_id => p_org_id,
                                                p_inventory_item_id => p_comp_id,
                                                p_repetitive_schedule_id => null,
                                                p_quantity_issued => null);
    exception when others then
      l_qty_allocated := 0;
    end;

    return (l_qty_open_requirements - nvl(l_qty_allocated, 0));
  Exception
    when others then
    return null;
  end;

  /* suppose in an operation, no two resource with the same id */
  function get_actual_work_time
  (
    p_wip_entity_id number,
    p_op_seq_num number,
    p_resource_seq_num number,
    p_include_all varchar2/* only include the active time, or even the past time records */
  ) return number
  Is
    l_used_usage number;
  Begin

    /* use duration, so it works for machine also */
    /* also it will reflect the charged resource usage */
    select sum(wrat.duration)
    into l_used_usage
    from wip_resource_actual_times wrat
    where wrat.wip_entity_id = p_wip_entity_id
      and wrat.operation_seq_num = p_op_seq_num
      and wrat.resource_seq_num = p_resource_seq_num
      and wrat.duration is not null
      and wrat.process_status <> 4
      and (p_include_all = 'Y' or status_type = 1);

    return nvl(l_used_usage, 0);
  End get_actual_work_time;


  function get_col_res_usage_req
  (
    p_wip_entity_id number,
    p_op_seq number,
    p_dept_id number,
    p_resource_id number,
    p_resource_seq_num number
  ) return number
  is
    cursor c_dept_resource_usage(p_wip_entity_id number, p_op_seq number, p_dept_id number, p_resource_id number, p_resource_seq_num number)
    Is
    select
        wor.resource_seq_num,
        wor.basis_type,
        wdj.start_quantity,
        wo.cumulative_scrap_quantity,
        wo.quantity_completed,
        decode( wip_ws_time_entry.is_time_uom(wor.uom_code), 'Y',
               inv_convert.inv_um_convert(-1,
                                  38,
                                  wor.usage_rate_or_amount,
                                  wor.uom_code,
                                  fnd_profile.value('BOM:HOUR_UOM_CODE'),
                                  NULL,
                                  NULL),
               null) usage,
       decode(mp.include_resource_efficiency, 1, nvl(bdr.efficiency, 1), 1) efficiency,
       wor.actual_start_date,
       wor.assigned_units
  from wip_discrete_jobs       wdj,
       wip_operations          wo,
       wip_operation_resources wor,
       bom_resources           br,
       bom_department_resources bdr,
       wip_parameters mp
 where wdj.wip_entity_id = wo.wip_entity_id and
       wdj.organization_id = wo.organization_id and
       mp.organization_id = wdj.organization_id and
       wo.wip_entity_id = wor.wip_entity_id and
       wo.organization_id = wor.organization_id and
       wo.operation_seq_num = wor.operation_seq_num and
       br.organization_id = wor.organization_id and
       br.resource_id = wor.resource_id and
       bdr.resource_id = wor.resource_id and
       bdr.department_id = nvl(wor.department_id, wo.department_id) and
       wor.scheduled_flag in (1,3,4) and
       wdj.status_type in (1,3,6) and
       wor.wip_entity_id = p_wip_entity_id and
       wor.operation_seq_num = p_op_seq and
       nvl(bdr.share_from_dept_id, bdr.department_id ) = p_dept_id and
       wor.resource_id = p_resource_id and
       wor.resource_seq_num = nvl(p_resource_seq_num, wor.resource_seq_num);

    l_job_qty number;
    l_qty_cumulative_scrap number;
    l_qty_completed number;

    l_resource_seq_num number;
    l_basis_type number;
    l_usage number;
    l_efficiency number;
    l_actual_start date;
    l_assigned_units number;

    l_usage_p number;
    l_ret number;
  begin

    open c_dept_resource_usage(p_wip_entity_id, p_op_seq, p_dept_id, p_resource_id, p_resource_seq_num);

    l_ret := null;
    loop
      fetch c_dept_resource_usage
      into l_resource_seq_num, l_basis_type, l_job_qty, l_qty_cumulative_scrap, l_qty_completed,
           l_usage , l_efficiency, l_actual_start, l_assigned_units;
      exit when c_dept_resource_usage%NOTFOUND;

      l_usage_p := 0;

      if( l_actual_start is null) then
        if( l_job_qty <= l_qty_completed + l_qty_cumulative_scrap) then
            l_usage_p := 0;
        elsif( l_basis_type = 1 )  then /* item */
            l_usage_p := (l_job_qty - l_qty_completed - l_qty_cumulative_scrap) * l_usage;
        else /* lot */
          if( l_qty_completed + l_qty_cumulative_scrap > 0 ) then
            l_usage_p := 0;
          else
            l_usage_p := l_usage;
          end if;
        end if;
      else
        if( l_job_qty <= l_qty_completed + l_qty_cumulative_scrap) then
            l_usage_p := 0;
        elsif( l_basis_type = 1 )  then /* item */
            l_usage_p := (l_job_qty - l_qty_cumulative_scrap) * l_usage;
              /* don't adjust it - (sysdate - l_actual_start) * 24 * l_assigned_units; */
        else /* lot */
          if( l_qty_completed > 0 ) then
            l_usage_p := 0;
          else
            l_usage_p := l_usage; /* - (sysdate - l_actual_start) * 24 * l_assigned_units; */
          end if;
        end if;

        if( l_usage_p > 0 ) then
          if( l_qty_completed = 0 ) then
            /* no qty has been completed, use actual time entries to adjust the usage */
            l_usage_p := l_usage_p - get_actual_work_time(p_wip_entity_id, p_op_seq, l_resource_seq_num, 'Y');
          else
            /* use the time entry to adjust unless use qty is more accurate */
            l_usage_p := l_usage_p - greatest( l_qty_completed * l_usage ,
              get_actual_work_time(p_wip_entity_id, p_op_seq, l_resource_seq_num, 'Y'));
          end if;
        end if;

      end if;  /* end else actual_start_date */

      if( l_usage_p < 0 ) then
        l_usage_p := 0;
      end if;

      l_ret := nvl(l_ret, 0) + l_usage_p / l_efficiency;
    end loop;

    return l_ret;

  end get_col_res_usage_req;

  function get_jobop_queue_run_qty
  (
    p_wip_entity_id number,
    p_op_seq_num number
  ) return number
  Is
    l_qty number;
  Begin
    select wo.quantity_in_queue + wo.quantity_running
    into l_qty
    from wip_operations wo
    where wo.wip_entity_id = p_wip_entity_id and wo.operation_seq_num = p_op_seq_num;

    return l_qty;
  End get_jobop_queue_run_qty;

  function get_job_released_status
  (
    p_wip_entity_id number
  ) return varchar2
  Is
    l_status_type number;
  Begin
    select wdj.status_type
    into l_status_type
    from wip_discrete_jobs wdj
    where wdj.wip_entity_id = p_wip_entity_id;

    if( l_status_type <> 3 ) then /* not released */
      return 'N';
    end if;
    return 'Y';
  End get_job_released_status;

  function get_jobop_num_exceptions
  (
    p_wip_entity_id number,
    p_op_seq_num number
  ) return number
  Is
    l_num_exceptions number;
  Begin
    select count(*)
    into l_num_exceptions
    from wip_exceptions we
    where we.wip_entity_id = p_wip_entity_id and
          we.operation_seq_num = p_op_seq_num and
          we.status_type = 1;
    return l_num_exceptions;
  End get_jobop_num_exceptions;

  function get_jobop_shopfloor_status
  (
    p_wip_entity_id number,
    p_op_seq_num number
  ) return varchar2
  Is
    l_num_shop_status number;
    l_nomove_step_min number;
    l_nomove_step_max number;

  Begin
    select count(*), min(s.intraoperation_step_type), max(s.intraoperation_step_type)
    into l_num_shop_status, l_nomove_step_min, l_nomove_step_max
    from wip_shop_floor_statuses s, wip_shop_floor_status_codes c
    where s.wip_entity_id = p_wip_entity_id and
          s.operation_seq_num = p_op_seq_num and
          s.shop_floor_status_code = c.shop_floor_status_code and
          s.organization_id = c.organization_id and
          c.status_move_flag = 2 /* no move */ and
          nvl(c.disable_date, sysdate+1) > sysdate;

    if( l_num_shop_status > 0 ) then
      return 'N'; /* TODO, simplify for now */
    end if;

    return 'Y';
  End get_jobop_shopfloor_status;


  function get_col_ready_status(
    p_resp_key varchar2,
    p_org_id number,
    p_dept_id number,
    p_wip_entity_id number,
    p_op_seq_num number
  ) return varchar2
  Is
      cursor c_pref_values(p_pref_id number, p_level_id number) IS
        select wpv.attribute_name, wpv.attribute_value_code
        from wip_preference_values wpv
        where wpv.preference_id = p_pref_id and
          wpv.level_id = p_level_id
        order by wpv.sequence_number;

      l_c_resp_key varchar2(30) := null;
      l_c_org_id number := null;
      l_c_dept_id number := null;

      l_level_id number;
      l_value varchar2(10);
      l_attribute_name varchar2(30);

      l_c_job_released boolean := true;
      l_c_no_exceptions boolean := false;
      l_c_shop_status boolean := false;
      l_c_qty_queue_run boolean := false;

      --hooks for flexibility
      l_custom_ready_status varchar2(1) := 'Y';

    Begin

      -- custom ready status integration
      l_custom_ready_status :=
        wip_ws_custom.get_custom_ready_status(
          wip_entity_id => p_wip_entity_id,
          operation_seq_num => p_op_seq_num,
          serial_number => null,
          attribute1 => null,
          attribute2 => null,
          attribute3 => null
        );
      IF (l_custom_ready_status not in ('Y' , 'y')) THEN
        RETURN 'N';
      END IF;


      if( p_resp_key <> l_c_resp_key or nvl(p_org_id, -1) <> nvl(l_c_org_id, -1) or
          nvl(p_dept_id, -1) <> nvl(l_c_dept_id, -1) ) then
      /* re calculate the preference */
        l_level_id := wip_ws_util.get_preference_level_id(WP_READY_STATUS_CRITERIA, p_resp_key, p_org_id, p_dept_id);
        open c_pref_values(WP_READY_STATUS_CRITERIA, l_level_id);
        loop
          fetch c_pref_values into l_attribute_name, l_value;
          exit when c_pref_values%NOTFOUND;

          if( l_value = WP_VALUE_YES) then
            if( l_attribute_name = 'jobStatus') then
              l_c_job_released := true;

            elsif( l_attribute_name = 'exception' ) then
              l_c_no_exceptions := true;

            elsif( l_attribute_name = 'compAvail' ) then
              null;

            elsif( l_attribute_name = 'sfStatus' ) then
              l_c_shop_status := true;

            elsif( l_attribute_name = 'qtyQueRun' ) then
              l_c_qty_queue_run := true;

            else
              null;
/*              dbms_output.put_line('Unknow ready status criteria ' || l_attribute_name); */

            end if;
          end if;

        end loop;
        close c_pref_values;
      end if;

     /* check qty in queue and run */
     if( l_c_qty_queue_run and get_jobop_queue_run_qty(p_wip_entity_id, p_op_seq_num) = 0 ) then
       return 'N';
     end if;

     /* check job status */
     if( l_c_job_released and get_job_released_status(p_wip_entity_id) = 'N' ) then
       return 'N';
     end if;

     /* check exceptions */
     if( l_c_no_exceptions and get_jobop_num_exceptions(p_wip_entity_id, p_op_seq_num) > 0 ) then
       return 'N';
     end if;

     /* check shop status */
     /* TODO, check if the no move is after the qty? */
     if( l_c_shop_status ) then
       if( get_jobop_shopfloor_status(p_wip_entity_id, p_op_seq_num) = 'N') then
         return 'N';
       end if;
     end if;

     return 'Y';

    End get_col_ready_status;

  /* interal apis */
  procedure add_string(x_all in out nocopy varchar2, p_str varchar2)
  is
  Begin
      x_all := x_all || p_str;
  End add_string;

  procedure add_string
  (
    x_all in out nocopy varchar2,
    p_delim varchar2,
    p_str varchar2
  )
  is
  Begin
    if( x_all is null) then
      x_all := p_str;
    else
      x_all := x_all || p_delim || p_str;
    end if;
  End add_string;

  procedure add_bind
  (
    x_binds in out nocopy varchar2,
    p_var varchar2,
    x_num in out nocopy number
  )
  is
  Begin
    x_num := x_num + 1;
    add_string(x_binds, ',', p_var);
  End add_bind;

  procedure add_where
  (
    x_where in out nocopy varchar2,
    p_line varchar2
  )
  is
  Begin
    if( x_where is not null) then
      x_where := x_where || ' and ';
    end if;

    x_where := x_where || p_line;
  End add_where;



  procedure build_dispatch_list_sql
  (
    p_resp_key varchar2,
    p_org_id number,
    p_dept_id number,
    p_resource_id number,
    p_instance_option number,
    p_instance_id number,
    p_serial_number varchar2,
    p_list_mode number,
    p_from_date date,
    p_to_date date,
    p_job_type number,
    p_component_id number,
    p_bind_number number,
    x_where_clause in out nocopy varchar2,
    x_bind_variables in out nocopy varchar2,
    x_order_by_columns in out nocopy varchar2,
    x_order_by_clause in out nocopy varchar2,
    x_required in varchar2 default null			--Bug -7364131
  )
  Is
  Begin

    build_dispatch_list_where
    (
      p_resp_key, p_org_id, p_dept_id, p_resource_id,
      p_instance_option, p_instance_id, p_serial_number,
      p_list_mode, p_from_date, p_to_date, p_job_type,
      p_component_id,
      p_bind_number,
      x_where_clause,
      x_bind_variables,
      x_required				--Bug -7364131
    );

    build_dispatch_list_order_by
    (
      p_resp_key,
      p_org_id,
      p_dept_id,
      x_order_by_columns,
      x_order_by_clause
    );
  End build_dispatch_list_sql;


  procedure build_dispatch_list_order_by
  (
    p_resp_key varchar2,
    p_org_id number,
    p_dept_id number,
    x_order_by_columns in out nocopy varchar2,
    x_order_by_clause in out nocopy varchar2
  )
  is

  cursor c_pref_order_by(p_pref_id number, p_level_id number) IS
  select
      v1.attribute_value_code,
      v2.attribute_value_code,
      v3.attribute_value_code,
      v4.attribute_value_code
    from wip_preference_values v1, wip_preference_values v2, wip_preference_values v3, wip_preference_values v4
    where
      v1.preference_id = p_pref_id and
      v2.preference_id = p_pref_id and
      v3.preference_id = p_pref_id and
      v4.preference_id = p_pref_id and
      v1.level_id = p_level_id and
      v2.level_id = p_level_id and
      v3.level_id = p_level_id and
      v4.level_id = p_level_id and
      v1.attribute_name = 'attribute' and
      v2.attribute_name = 'column' and
      v3.attribute_name = 'direction' and
      v4.attribute_name = 'ignoreTime' and
      v1.sequence_number = v2.sequence_number and
      v2.sequence_number = v3.sequence_number and
      v3.sequence_number = v4.sequence_number
    order by v1.sequence_number;

    l_columns varchar2(4096);
    l_orderby varchar2(4096);
    l_level_id number;
    l_attribute_code varchar2(256);
    l_column varchar2(256);
    l_direction varchar2(256);
    l_ignoreTime varchar2(1);

    l_tmp varchar2(100);
  Begin
    l_columns := 'expedited';
    l_orderby := 'expedited';

    l_level_id := wip_ws_util.get_preference_level_id(WP_DL_ORDERING_CRITERIA, p_resp_key, p_org_id, p_dept_id);

    open c_pref_order_by(WP_DL_ORDERING_CRITERIA, l_level_id);

    loop
      fetch c_pref_order_by
      into l_attribute_code, l_column, l_direction, l_ignoreTime;

      exit when c_pref_order_by%NOTFOUND;

      add_string(l_columns, ',', l_column);

      l_tmp := l_column;
      if( l_ignoreTime is not null and l_ignoreTime = WP_VALUE_YES ) then
        l_tmp := 'trunc(' || l_tmp || ')';
      end if;

      if( l_direction is not null and l_direction = WP_VALUE_DIRECTION_DOWN ) then
        add_string(l_tmp, ' desc');
      else
        add_string(l_tmp, ' asc');
      end if;

      add_string(l_orderby, ', ', l_tmp);
    end loop;

    close c_pref_order_by;

    x_order_by_columns := l_columns;
    x_order_by_clause := l_orderby;

  End build_dispatch_list_order_by;

  procedure build_dispatch_list_where
  (
    p_resp_key varchar2,
    p_org_id number,
    p_dept_id number,
    p_resource_id number,
    p_instance_assigned number,
    p_instance_id number,
    p_serial_number varchar2,
    p_list_mode number,
    p_from_date date,
    p_to_date date,
    p_job_type number,
    p_component_id number,
    p_bind_number number,
    x_where_clause in out nocopy varchar2,
    x_bind_variables in out nocopy varchar2,
    x_required in varchar2			--Bug -7364131
  )
  is

  cursor c_pref_values(p_pref_id number, p_level_id number, p_attribute varchar2) IS
    select wpv.attribute_value_code
    from wip_preference_values wpv
    where wpv.preference_id = p_pref_id and
      wpv.level_id = p_level_id and
      ( p_attribute is null
        or wpv.attribute_name = p_attribute);

  l_where varchar2(4096);
  l_binds varchar2(2048);
  l_num number;
  l_level_id number;

  l_status varchar2(20) := '';
  l_value varchar2(10) := '';
  l_include_to_move boolean;

  l_tmp varchar2(2048) := '';

  Begin

    l_num := p_bind_number;
    l_where := '';
    l_binds := '';

    -- read the job type
    if( p_job_type is not null) then
      add_where(l_where, '  job_type = ' || p_job_type);
    end if;

    -- read preference, add job status type
    l_level_id := wip_ws_util.get_preference_level_id(WP_JOB_STATUS, p_resp_key, p_org_id, p_dept_id);
    open c_pref_values(WP_JOB_STATUS, l_level_id, null);
    loop
      fetch c_pref_values into l_value;
      exit when c_pref_values%NOTFOUND;
      add_string(l_status, ', ', l_value);
    end loop;
    add_where(l_where, '  status_type in (' || l_status || ')' );

    -- if org has set
    if( p_org_id is not null ) then
      add_where(l_where, '  organization_id = :' || l_num);
      add_bind(l_binds, 'organization_id', l_num);
    end if;

    -- if instance has set
    if( (p_instance_assigned = 3 or p_instance_id = 4) and p_instance_id is not null ) then
      l_tmp :=
        '  exists   ' ||
        '  (   ' ||
        '    select 1  ' ||
        '    from wip_operation_resources   wor1,  ' ||
        '         wip_op_resource_instances wori1  ' ||
        '    where qrslt.wip_entity_id = wor1.wip_entity_id  ' ||
        '      and qrslt.organization_id = wor1.organization_id  ' ||
        '      and qrslt.operation_seq_num = wor1.operation_seq_num  ' ||
        '      and wor1.wip_entity_id = wori1.wip_entity_id  ' ||
        '      and wor1.operation_seq_num = wori1.operation_seq_num  ' ||
        '      and wor1.resource_seq_num = wori1.resource_seq_num  ' ||
        '      and wori1.instance_id = :' || l_num || '  ';

      add_bind(l_binds, 'instance_id', l_num);
      if( p_serial_number is not null ) then
        add_string(l_tmp, '      and wori1.serial_number = :' || l_num || '  ');
        add_bind(l_binds, 'serial_number', l_num);
      end if;

      add_string(l_tmp, '  )  ');
      add_where(l_where, l_tmp);

    -- if the resource is set
    elsif ( p_resource_id is not null ) then
      add_where(l_where,
        '  exists  ' ||
        '  (  ' ||
        '    select 1  ' ||
        '    from wip_operation_resources wor1, bom_department_resources bdr  ' ||
        '     where wor1.wip_entity_id = qrslt.wip_entity_id  ' ||
        '       and wor1.organization_id = qrslt.organization_id  ' ||
        '       and wor1.operation_seq_num = qrslt.operation_seq_num  ' ||
        '       and bdr.department_id = qrslt.department_id   ' ||
        '       and nvl(wor1.department_id, nvl(bdr.share_from_dept_id, bdr.department_id)) = :' || l_num || '  ' ||
        '       and wor1.resource_id = :' || (l_num + 1) || '  ' ||
        '  )  '
      );
      add_bind(l_binds, 'department_id', l_num);
      add_bind(l_binds, 'resource_id', l_num);

    -- if dept has set
    elsif ( p_dept_id is not null ) then
      add_where(l_where, '  department_id = :' || l_num);
      add_bind(l_binds, 'department_id', l_num);
    end if;

    if( p_instance_assigned = 2) then -- not assigned
      if (p_instance_assigned = 2 ) then
        l_tmp := '  not exists  ';
      else
        l_tmp := '  exists  ';
      end if;

      add_string
      (l_tmp,
        '  (   ' ||
        '    select 1  ' ||
        '    from wip_operation_resources wor1,   ' ||
        '         wip_op_resource_instances wori1  ' ||
        '    where qrslt.wip_entity_id = wor1.wip_entity_id  ' ||
        '      and qrslt.organization_id = wor1.organization_id  ' ||
        '      and qrslt.operation_seq_num = wor1.operation_seq_num  ' ||
        '      and wor1.wip_entity_id = wori1.wip_entity_id  ' ||
        '      and wor1.operation_seq_num = wori1.operation_seq_num  ' ||
        '      and wor1.resource_seq_num = wori1.resource_seq_num ' ||
        '  )  '
      );
      add_where(l_where, l_tmp);
    end if;

    -- read preference, include complete or not
    l_level_id := wip_ws_util.get_preference_level_id(WP_INCLUDE_COMPLETE_QTY, p_resp_key, p_org_id, p_dept_id);
    if( wip_ws_util.get_preference_value_code(WP_INCLUDE_COMPLETE_QTY, l_level_id) = WP_VALUE_YES ) then
      l_include_to_move := true;
    else
      l_include_to_move := false;
    end if;

    if (p_list_mode = LIST_MODE_SCHEDULED) then
      l_tmp := '';
      if( p_to_date is not null) then
        add_string(l_tmp, '      first_unit_start_date < :' || l_num);
        add_bind(l_binds, 'to_date', l_num);
      end if;

      if ( p_from_date is not null ) then
        add_string(l_tmp, ' and ', '      first_unit_start_date >= :' || l_num);
        add_bind(l_binds, 'from_date', l_num);
      end if;

      if( l_tmp is not null ) then
        add_where(l_where, '  ( expedited = ''Y'' or (' || l_tmp || ' ) )' );
      end if;

      if( l_include_to_move ) then
        add_where(l_where, '     ( quantity_waiting_to_move > 0 or start_quantity - quantity_completed - cumulative_scrap_quantity > 0 )');
      else
        add_where(l_where, '     (start_quantity - quantity_completed - cumulative_scrap_quantity > 0 )');
      end if;

    elsif ( p_list_mode = LIST_MODE_CURRENT) then
      l_tmp := '';


      if( p_to_date is not null ) then
        add_string(l_tmp, 'first_unit_start_date <:'|| l_num);
        add_bind(l_binds, 'to_date', l_num);
      end if;

      if( p_from_date is not null ) then
        add_string(l_tmp, ' and ', 'first_unit_start_date >= :' || l_num);
        add_bind(l_binds, 'from_date', l_num);
      end if;

      if( l_tmp is not null ) then
        l_tmp := '  (expedited = ''Y'' or ( ' || l_tmp || ' )) ';
      end if;

      if x_required is null then				--Bug -7364131
	      if( l_include_to_move ) then
		add_string(l_tmp, ' and ', '( quantity_in_queue > 0 or quantity_running > 0 or quantity_waiting_to_move > 0)');
	      else
		add_string(l_tmp, ' and ', '( quantity_in_queue > 0 or quantity_running > 0 )');
	      end if ;
      end if ;							--Bug -7364131

      add_where(l_where, '  (      ' || l_tmp || '   )  ');
    else -- upstream
      l_tmp := '';
      if( p_to_date is not null ) then
        add_string(l_tmp, 'first_unit_start_date <:'|| l_num);
        add_bind(l_binds, 'to_date', l_num);
      end if;

      if( p_from_date is not null ) then
        add_string(l_tmp, ' and ', 'first_unit_start_date >= :' || l_num);
        add_bind(l_binds, 'from_date', l_num);
      end if;

      if( l_tmp is not null ) then
        l_tmp := '  (expedited = ''Y'' or ( ' || l_tmp || ' )) ';
      end if;

      add_string(l_tmp, ' and ', '( ');
      add_string(l_tmp, '   0 < (select (wo1.quantity_in_queue + wo1.quantity_running + wo1.quantity_waiting_to_move + wo1.quantity_rejected) ');
      add_string(l_tmp, '      from wip_operations wo1 where wo1.operation_seq_num = ');
      add_string(l_tmp, '        ( select max(wo2.operation_seq_num) from wip_operations wo2 ');
      add_string(l_tmp, '          where wo2.count_point_type = 1 and ');
      add_string(l_tmp, '            wo2.operation_seq_num < qrslt.operation_seq_num and ');
      add_string(l_tmp, '            wo2.wip_entity_id = wo1.wip_entity_id and ');
      add_string(l_tmp, '             wo2.organization_id = wo1.organization_id ');
      add_string(l_tmp, '        ) and  wo1.wip_entity_id = qrslt.wip_entity_id )' );
      add_string(l_tmp, '   or ');
      add_string(l_tmp, '   0 < (select (wo1.quantity_in_queue + wo1.quantity_running + wo1.quantity_waiting_to_move + wo1.quantity_rejected) ');
      add_string(l_tmp, '      from wip_operations wo1, wip_operations wo2 ');
      add_string(l_tmp, '        where wo2.previous_operation_seq_num = wo1.operation_seq_num and ');
      add_string(l_tmp, '              wo2.operation_seq_num = qrslt.operation_seq_num and ');
      add_string(l_tmp, '              wo2.wip_entity_id = qrslt.wip_entity_id and ');
      add_string(l_tmp, '              wo2.wip_entity_id = wo1.wip_entity_id )' );
      add_string(l_tmp, '   ) ');
      add_where(l_where, l_tmp);
    end if;
   null;

   x_where_clause := l_where;
   x_bind_variables := l_binds;

  End build_dispatch_list_where;


  procedure expedite
  (
    p_wip_entity_id number,
    p_op_seq_num number,
    x_status in out nocopy varchar2,
    x_msg_count in out nocopy number,
    x_msg in out nocopy number
  )
  Is
   l_expedited varchar2(1);
  Begin
    fnd_msg_pub.Initialize;

    x_status := '';
    x_msg_count := 0;
    x_msg := '';

    select wdj.expedited
    into l_expedited
    from wip_discrete_jobs wdj
    where wdj.wip_entity_id = p_wip_entity_id;

    if( l_expedited is null or l_expedited = 'N') then
      update wip_discrete_jobs wdj
      set wdj.expedited = 'Y'
      where wdj.wip_entity_id = p_wip_entity_id;
      commit;
    else
      x_status := 'A';
      fnd_message.SET_NAME('WIP', 'WS_JOBOP_ALR_EXPEDITED');
      fnd_msg_pub.Add;
    end if;

  End;

  procedure unexpedite
  (
    p_wip_entity_id number,
    p_op_seq_num number,
    x_status in out nocopy varchar2,
    x_msg_count in out nocopy number,
    x_msg in out nocopy number
  )
  Is
   l_expedited varchar2(1);
  Begin
    fnd_msg_pub.Initialize;

    x_status := '';
    x_msg_count := 0;
    x_msg := '';

    select wdj.expedited
    into l_expedited
    from wip_discrete_jobs wdj
    where wdj.wip_entity_id = p_wip_entity_id;

    if( l_expedited = 'Y') then
      update wip_discrete_jobs wdj
      set wdj.expedited = null /* set to N dosn't help on order */
      where wdj.wip_entity_id = p_wip_entity_id;
      commit;
    else
      x_status := 'A';
      fnd_message.SET_NAME('WIP', 'WS_JOBOP_ALR_UNEXPEDITED');
      fnd_msg_pub.Add;
    end if;

  End;


  /* need to concatenate the shift seq and shift num to uniquely identify a shift */
  function get_first_shift_id(p_org_id number, p_dept_id number, p_resource_id number)
  return varchar2
  Is
    l_ret varchar2(60);

    l_date date;
    l_seq number;
    l_num number;
    l_shift_start_date date;
    l_shift_end_date date;
    l_str varchar2(60);
  Begin

    l_date := sysdate;

    wip_ws_util.retrieve_first_shift(p_org_id, p_dept_id, p_resource_id, l_date, l_seq, l_num, l_shift_start_date, l_shift_end_date, l_str);

    l_ret := l_seq || '.' || l_num;

    return l_ret;

  End get_first_shift_id;

  procedure batch_move_add(
    p_index number,
    p_wip_entity_id number,
    p_wip_entity_name varchar2,
    p_op_seq varchar2,
    p_move_qty number,
    p_scrap_qty number,
    p_assy_serial varchar2 default null,
    x_return_status out nocopy varchar2
  )
  Is
  Begin
    if( p_index = 1 ) then
      l_move_table.delete;
    end if;

    l_move_table(p_index).wip_entity_id := p_wip_entity_id;
    l_move_table(p_index).wip_entity_name := p_wip_entity_name;
    l_move_table(p_index).op_seq := p_op_seq;
    l_move_table(p_index).move_qty := p_move_qty;
    l_move_table(p_index).scrap_qty := p_scrap_qty;
    l_move_table(p_index).assy_serial := p_assy_serial;

    x_return_status := 'S';
  Exception when others then
    x_return_status := 'U';
  End batch_move_add;

  procedure batch_move_process
  (
    p_resp_key varchar2,
    p_org_id number,
    p_dept_id number,
    p_employee_id number,
    x_return_status out nocopy varchar2
  )
  Is
  Begin
    wip_batch_move.process(l_move_table, p_resp_key, p_org_id, p_dept_id, p_employee_id, x_return_status);
  End batch_move_process;

  function get_shift_capacity
  (
    p_org_id number,
    p_dept_id number,
    p_resource_id number,
    p_shift_seq number,
    p_shift_num number
  )  return number
  Is
    l_cal_code varchar2(30);
    l_cal_exception_id number;
    l_date date;
    l_shift_date date;
    l_total_time number;
    l_units number;
    l_utilizaiton number;
  Begin

    select mp.calendar_code, mp.calendar_exception_set_id
    into l_cal_code, l_cal_exception_id
    from mtl_parameters mp
    where mp.organization_id = p_org_id;

    if( p_shift_num is not null) then
      /* use bom_shift_dates*/
      l_date := sysdate;

      select shift_date
      into l_shift_date
      from bom_shift_dates bsd
      where bsd.calendar_code = l_cal_code and
            bsd.exception_set_id = l_cal_exception_id and
            bsd.seq_num = p_shift_seq and
            bsd.shift_num = p_shift_num;

      /* adjust the time with sysdate */
      select sum( 24* (to_date - from_date)) total_time
      into l_total_time
      from
             ( select GREATEST(l_date, l_shift_date + from_time/(24*60*60)) from_date,
                      l_shift_date + to_time/(24*60*60) + decode(sign(to_time - from_time), -1, 1, 0) to_date
                 from bom_shift_times bst
                 where bst.calendar_code = l_cal_code and
                       bst.shift_num = p_shift_num
             ) sd
      where sd.from_date <= sd.to_date;

      select brs.capacity_units
      into l_units
      from bom_resource_shifts brs
      where brs.department_id = p_dept_id and
          brs.resource_id = p_resource_id and
          brs.shift_num = p_shift_num;
    else
      /* 24 hour resource */
      /*
      select bcd.calendar_date
      into l_shift_date
      from bom_calendar_dates bcd
      where bcd.calendar_code = l_cal_code and
            bcd.seq_num = p_shift_seq;

      if( l_shift_date < trunc(sysdate) ) then
        l_total_time := 0;
      elsif (l_shift_date > trunc(sysdate) ) then
        l_total_time := 24;
      else
        l_total_time := 24 - (sysdate - l_shift_date)*24;
      end if;
      */
      /* per barry's decision, using 0 as the capacity for 24hr resource */
      l_total_time := 0;

      l_units := null;
    end if;

    select nvl(l_units, bdr.capacity_units),
           decode(wp.include_resource_utilization, wip_constants.yes, nvl(bdr.utilization, 1), 1)
    into l_units, l_utilizaiton
    from bom_department_resources bdr, wip_parameters wp
    where bdr.department_id = p_dept_id and
          bdr.resource_id = p_resource_id and
          wp.organization_id = p_org_id;

    if( l_units is null ) then
      l_units := 1;
    end if;

    return l_units * l_total_time * l_utilizaiton;
  Exception
    when others then
      return 0;
  End get_shift_capacity;

  /* for home page capacity table */
  function get_cap_num_ns_jobs
  (
    p_resp_key varchar2,
    p_org_id number,
    p_department_id number,
    p_resource_id number,
    p_shift_num number,
    p_from_date date,
    p_to_date date
  ) return number
  Is
    l_num number;

    l_bind_num number := 1;
    l_list_mode number;

    x_where_clause varchar2(4096);
    x_bind_variables varchar2(1024);
    x_order_by_columns varchar2(1024);
    x_order_by_clause varchar2(1024);

    l_index number;
    l_pos number;
    l_var varchar2(256);
    l_sql varchar(2048);
    l_cursor integer;
    l_dummy integer;
  Begin

    l_list_mode := wip_ws_util.get_preference_value_code(WIP_WS_DEFAULT_DL_TYPE, p_resp_key, p_org_id, p_department_id);

    l_bind_num := 3;

    wip_ws_dl_util.build_dispatch_list_sql(p_resp_key => p_resp_key,
                                         p_org_id => p_org_id,
                                         p_dept_id => p_department_id,
                                         p_resource_id => p_resource_id,
                                         p_instance_option => 1, /* all */
                                         p_instance_id => null,
                                         p_serial_number => null,
                                         p_list_mode => l_list_mode,
                                         p_from_date => p_from_date,
                                         p_to_date => p_to_date,
                                         p_job_type => 1,
                                          p_component_id => null,
                                         p_bind_number => l_bind_num,
                                         x_where_clause => x_where_clause,
                                         x_bind_variables => x_bind_variables,
                                         x_order_by_columns => x_order_by_columns,
                                         x_order_by_clause => x_order_by_clause);

    l_sql := 'select count(*) ';
    l_sql := l_sql || 'from ( ';
    l_sql := l_sql || 'select wo.organization_id, wo.wip_entity_id, wo.operation_seq_num, wo.department_id, ';
    l_sql := l_sql || '       wo.first_unit_start_date, wo.last_unit_completion_date, ';
    l_sql := l_sql || '       wo.quantity_in_queue, wo.quantity_running, wo.quantity_waiting_to_move, wo.cumulative_scrap_quantity, ';
    l_sql := l_sql || ' wdj.start_quantity, wdj.quantity_completed, wdj.expedited, wdj.job_type, wdj.status_type ';
    l_sql := l_sql || 'from wip_operations wo, wip_discrete_jobs wdj ';
    l_sql := l_sql || 'where wo.organization_id = wdj.organization_id and ';
    l_sql := l_sql || '      wo.wip_entity_id = wdj.wip_entity_id and ';
    l_sql := l_sql || '      wo.actual_start_date is null ';
    l_sql := l_sql || ' ) qrslt ';
    l_sql := l_sql || ' where ';
    l_sql := l_sql || x_where_clause;

    l_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);
    dbms_sql.define_column(l_cursor, 1, l_num);

    l_pos := 1;
    loop
      l_index := instr(x_bind_variables, ',', l_pos, 1);

      if ( l_index = 0 ) then
        l_var := substr(x_bind_variables, l_pos, length(x_bind_variables) - l_pos + 1);
      else
        l_var := substr(x_bind_variables, l_pos, l_index - l_pos);
      end if;

      if( l_var = 'from_date' ) then
        dbms_sql.bind_variable(l_cursor, '' || l_bind_num, p_from_date);
      elsif (l_var = 'to_date' ) then
        dbms_sql.bind_variable(l_cursor, '' || l_bind_num, p_to_date);
      elsif ( l_var = 'organization_id' ) then
        dbms_sql.bind_variable(l_cursor, '' || l_bind_num, p_org_id );
      elsif ( l_var = 'department_id' ) then
        dbms_sql.bind_variable(l_cursor, '' || l_bind_num, p_department_id);
      elsif ( l_var = 'resource_id') then
        dbms_sql.bind_variable(l_cursor, '' || l_bind_num, p_resource_id);
      end if;
      -- bind the var

      exit when l_index = 0;

      l_pos := l_index + 1;
      l_bind_num := l_bind_num + 1;
    end loop;

    l_dummy := dbms_sql.execute(l_cursor);

    if( dbms_sql.fetch_rows(l_cursor) > 0 ) then
      dbms_sql.column_value(l_cursor, 1, l_num);
    else
      l_num := 0;
    end if;

    dbms_sql.close_cursor(l_cursor);

    return l_num;
  End get_cap_num_ns_jobs;

  function get_cap_resource_avail
  (
    p_org_id number,
    p_department_id number,
    p_resource_id number,
    p_shift_num number,
    p_from_date date
  ) return number
  Is
    l_avail number;
    l_shift_seq number;
  Begin
    Begin
      select bsd.seq_num
      into l_shift_seq
      from bom_shift_dates bsd, mtl_parameters mp, bom_resource_shifts brs
      where mp.organization_id = p_org_id and
            mp.calendar_code = bsd.calendar_code and
            brs.department_id = p_department_id and
            brs.resource_id = p_resource_id and
            brs.shift_num = bsd.shift_num and
            bsd.shift_num = p_shift_num and
            bsd.shift_date = trunc(p_from_date); -- Fix bug 9392379
    Exception when others then
      l_shift_seq := null;
    end;

    if( l_shift_seq is null) then
      l_avail := 0;
    else
      l_avail := get_shift_capacity(p_org_id, p_department_id, p_resource_id, l_shift_seq, p_shift_num);
    end if;

    return l_avail;
  end get_cap_resource_avail;

 function get_cap_resource_required
  (
    p_resp_key varchar2,
    p_org_id number,
    p_department_id number,
    p_resource_id number,
    p_shift_num number,
    p_from_date date,
    p_to_date date
  )
  return number
  Is
    l_req number;

    l_bind_num number := 1;
    l_list_mode number;

    x_where_clause varchar2(4096);
    x_bind_variables varchar2(1024);
    x_order_by_columns varchar2(1024);
    x_order_by_clause varchar2(1024);
    x_required varchar2(10) := 'required';		--Bug -7364131
    l_index number;
    l_pos number;
    l_var varchar2(256);
    l_sql varchar(2048);
    l_cursor integer;
    l_dummy integer;
  Begin
    l_list_mode := wip_ws_util.get_preference_value_code(WIP_WS_DEFAULT_DL_TYPE, p_resp_key, p_org_id, p_department_id);

    l_bind_num := 3;

    wip_ws_dl_util.build_dispatch_list_sql(p_resp_key => p_resp_key,
                                         p_org_id => p_org_id,
                                         p_dept_id => p_department_id,
                                         p_resource_id => p_resource_id,
                                         p_instance_option => 1, /* all */
                                         p_instance_id => null,
                                         p_serial_number => null,
                                         p_list_mode => l_list_mode,
                                         p_from_date => p_from_date,
                                         p_to_date => p_to_date,
                                         p_job_type => 1,
                                          p_component_id => null,
                                         p_bind_number => l_bind_num,
                                         x_where_clause => x_where_clause,
                                         x_bind_variables => x_bind_variables,
                                         x_order_by_columns => x_order_by_columns,
                                         x_order_by_clause => x_order_by_clause,
					  x_required =>x_required		--Bug -7364131
					 );

    l_sql := 'select sum( nvl(wip_ws_dl_util.get_col_res_usage_req(wip_entity_id, operation_seq_num, :1, :2, null), 0) ) ';
    l_sql := l_sql || 'from ( ';
    l_sql := l_sql || 'select wo.organization_id, wo.wip_entity_id, wo.operation_seq_num, wo.department_id, ';
    l_sql := l_sql || '       wo.first_unit_start_date, wo.last_unit_completion_date, ';
    l_sql := l_sql || '       wo.quantity_in_queue, wo.quantity_running, wo.quantity_waiting_to_move, wo.cumulative_scrap_quantity, ';
    l_sql := l_sql || ' wdj.start_quantity, wdj.quantity_completed, wdj.expedited, wdj.job_type, wdj.status_type ';
    l_sql := l_sql || 'from wip_operations wo, wip_discrete_jobs wdj ';
    l_sql := l_sql || 'where wo.organization_id = wdj.organization_id and ';
    l_sql := l_sql || '      wo.wip_entity_id = wdj.wip_entity_id ';
    l_sql := l_sql || ' ) qrslt ';
    l_sql := l_sql || ' where ';
    l_sql := l_sql || x_where_clause;

    l_cursor := dbms_sql.open_cursor;
    dbms_sql.parse(l_cursor, l_sql, dbms_sql.native);
    dbms_sql.define_column(l_cursor, 1, l_req);

    dbms_sql.bind_variable(l_cursor, '1', p_department_id);
    dbms_sql.bind_variable(l_cursor, '2', p_resource_id);

    l_pos := 1;
    loop
      l_index := instr(x_bind_variables, ',', l_pos, 1);

      if ( l_index = 0 ) then
        l_var := substr(x_bind_variables, l_pos, length(x_bind_variables) - l_pos + 1);
      else
        l_var := substr(x_bind_variables, l_pos, l_index - l_pos);
      end if;

      if( l_var = 'from_date' ) then
        dbms_sql.bind_variable(l_cursor, '' || l_bind_num, p_from_date);
      elsif (l_var = 'to_date' ) then
        dbms_sql.bind_variable(l_cursor, '' || l_bind_num, p_to_date);
      elsif ( l_var = 'organization_id' ) then
        dbms_sql.bind_variable(l_cursor, '' || l_bind_num, p_org_id );
      elsif ( l_var = 'department_id' ) then
        dbms_sql.bind_variable(l_cursor, '' || l_bind_num, p_department_id);
      elsif ( l_var = 'resource_id') then
        dbms_sql.bind_variable(l_cursor, '' || l_bind_num, p_resource_id);
      end if;
      -- bind the var

      exit when l_index = 0;

      l_pos := l_index + 1;
      l_bind_num := l_bind_num + 1;
    end loop;

    l_dummy := dbms_sql.execute(l_cursor);

    if( dbms_sql.fetch_rows(l_cursor) > 0 ) then
      dbms_sql.column_value(l_cursor, 1, l_req);
    else
      l_req := 0;
    end if;

    if l_req is null then		--Bug -7364131
	l_req := 0;			--Bug -7364131
    end if;				--Bug -7364131
    dbms_sql.close_cursor(l_cursor);

    return l_req;
  End get_cap_resource_required;

  function is_jobop_completed
  (
    p_resp_key varchar2,
    p_wip_entity_id number,
    p_op_seq number
  ) return varchar2
  Is
    l_ret varchar2(1);

    l_dept_id number;
    l_org_id number;
    l_level_id number;
    l_qty_queue_run number;
    l_qty_to_move number;
    l_include_to_move boolean;
  Begin

    select wo.organization_id, wo.department_id,
      wo.quantity_in_queue + wo.quantity_running,
      wo.quantity_waiting_to_move
    into l_org_id, l_dept_id, l_qty_queue_run, l_qty_to_move
    from wip_operations wo
    where wo.wip_entity_id = p_wip_entity_id and
          wo.operation_seq_num = p_op_seq;

    l_level_id := wip_ws_util.get_preference_level_id(WP_INCLUDE_COMPLETE_QTY, p_resp_key, l_org_id, l_dept_id);
    if( wip_ws_util.get_preference_value_code(WP_INCLUDE_COMPLETE_QTY, l_level_id) = WP_VALUE_YES ) then
      l_include_to_move := true;
    else
      l_include_to_move := false;
    end if;

    if( (l_include_to_move and l_qty_queue_run + l_qty_to_move > 0)
          or (not l_include_to_move and l_qty_queue_run > 0) ) then
      l_ret := 'N';
    else
      l_ret := 'Y';
    end if;

    return l_ret;
  Exception when others then
    return null;
  End is_jobop_completed;

begin
  null;
end WIP_WS_DL_UTIL;


/
