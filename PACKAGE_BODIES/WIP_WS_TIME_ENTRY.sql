--------------------------------------------------------
--  DDL for Package Body WIP_WS_TIME_ENTRY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_WS_TIME_ENTRY" AS
/* $Header: wipwsteb.pls 120.35.12010000.4 2010/02/22 23:56:54 ntangjee ship $ */

G_WIP_WS_PREF_CHARGE_RESOURCE CONSTANT NUMBER := 5;
G_WIP_WS_PREF_TIME_ENTRY_MODE CONSTANT NUMBER := 26;
G_BOM_AUTOCHARGE_TYPE_MANUAL CONSTANT NUMBER := 2;

G_RES_CHG_FAILED Number :=wip_constants.no;

-- Insert a record into the wip_resource_actual_times table.
PROCEDURE record_insert(
 p_time_entry_id	                   in number,
 p_organization_id  	               in number,
 p_wip_entity_id     	               in number,
 p_operation_seq_num                 in number,
 p_resource_id                       in number,
 p_resource_seq_num    	             in number,
 p_instance_id  	                   in number,
 p_serial_number          	         in varchar2,
 p_last_update_date     	           in date,
 p_last_updated_by                   in number,
 p_creation_date                     in date,
 p_created_by                        in number,
 p_last_update_login                 in number,
 p_object_version_num                in number,
 p_time_entry_mode                   in number,
 p_cost_flag                         in varchar2,
 p_add_to_rtg                        in varchar2,
 p_status_type                       in number,
 p_start_date                        in date,
 p_end_date                          in date,
 p_projected_completion_date         in date,
 p_duration                          in number,
 p_uom_code                          in varchar2,
 p_employee_id                       in number,
 x_time_entry_id                     out NOCOPY number,
 x_return_status                     out NOCOPY varchar2)
IS
 l_time_entry_id number;
 l_object_version_num number;
 l_status_type number;
 l_process_status number;
 l_time_entry_mode number;
 l_uom_code varchar2(3);
 l_time_uom_flag varchar2(1);
 l_duration number;
 l_projected_completion_date date;
 l_organization_code varchar2(3);
 l_resource_code varchar2(10);
 l_wip_entity_name varchar2(240);
 l_return_status varchar2(10);

l_resource_type number;
l_employee_id number;
l_employee_num varchar2(30);

BEGIN
   l_status_type := 1;     --pending
   l_process_status := 2;  --inserted
   l_object_version_num := 1;  --new record
   l_uom_code := fnd_profile.value('BOM:HOUR_UOM_CODE');
   l_return_status := 'U';

   if p_time_entry_id is null then
      select WIP_RESOURCE_ACTUAL_TIMES_S.nextval into l_time_entry_id from dual;
   else
      l_time_entry_id := p_time_entry_id;
   end if;

   if p_time_entry_mode is null then
      l_time_entry_mode := get_time_entry_mode(p_wip_entity_id     => p_wip_entity_id,
                                               p_operation_seq_num => p_operation_seq_num);
   else
      l_time_entry_mode := p_time_entry_mode;
   end if;

   l_time_uom_flag := is_time_uom(p_uom_code);

   if( p_start_date is null and p_duration is null) then
     /* skip, consider as empty record */
     null;
   elsif (l_time_uom_flag = 'Y' and p_start_date is not null) then

       if (p_start_date is not null and p_end_date is not null and p_duration is null) then
         l_duration := (p_end_date - p_start_date)*24;
       else
         l_duration := p_duration;
       end if;

       if l_duration is not null and l_uom_code <> p_uom_code then
         l_duration := inv_convert.inv_um_convert(item_id       => -1,
                                                  precision     => 38,
                                                  from_quantity => l_duration,
                                                  from_unit     => p_uom_code,
                                                  to_unit       => l_uom_code,
                                                  from_name     => null,
                                                  to_name       => null);
       end if;

       if p_projected_completion_date is null then
         l_projected_completion_date := wip_ws_util.get_projected_completion_date(p_organization_id => p_organization_id,
                                                                                  p_wip_entity_id => p_wip_entity_id,
                                                                                  p_op_seq_num => p_operation_seq_num,
                                                                                  p_resource_seq_num => p_resource_seq_num,
                                                                                  p_resource_id => p_resource_id,
                                                                                  p_instance_id => p_instance_id,
                                                                                  p_start_date => p_start_date);
       else
          l_projected_completion_date  := p_projected_completion_date;
       end if;

     insert into wip_resource_actual_times
     (time_entry_id,
      organization_id,
      wip_entity_id,
      operation_seq_num,
      resource_id,
      resource_seq_num,
      instance_id,
      serial_number,
      created_by,
      creation_date,
      last_updated_by,
      last_update_date,
      last_update_login,
      object_version_number,
      time_entry_mode,
      cost_flag,
      add_to_rtg,
      status_type,
      start_date,
      end_date,
      projected_completion_date,
      duration,
      uom_code,
      employee_id,
      process_status)
     values
     (l_time_entry_id,
      p_organization_id,
      p_wip_entity_id,
      p_operation_seq_num,
      p_resource_id,
      p_resource_seq_num,
      p_instance_id,
      p_serial_number,
      fnd_global.user_id,
      sysdate,
      fnd_global.user_id,
      sysdate,
      fnd_global.login_id,
      l_object_version_num,
      l_time_entry_mode,
      p_cost_flag,
      p_add_to_rtg,
      l_status_type,
      p_start_date,
      p_end_date,
      l_projected_completion_date,
      l_duration,
      l_uom_code,
      p_employee_id,
      l_process_status);

     update_actual_start_dates(p_wip_entity_id      => p_wip_entity_id,
                               p_operation_seq_num  => p_operation_seq_num,
                               p_resource_seq_num   => p_resource_seq_num);

     if p_start_date is not null then
        update_proj_completion_dates(p_organization_id => p_organization_id,
                                     p_wip_entity_id => p_wip_entity_id,
                                     p_operation_seq_num => p_operation_seq_num,
                                     p_resource_seq_num => p_resource_seq_num,
                                     p_resource_id => p_resource_id,
                                     p_start_date => p_start_date);
     end if;

     l_return_status := 'S';

   else

     select organization_code
      into l_organization_code
       from mtl_parameters
      where organization_id = p_organization_id;

     select wip_entity_name
      into l_wip_entity_name
       from wip_entities
      where wip_entity_id = p_wip_entity_id;

     select resource_code, resource_type
     into l_resource_code, l_resource_type
     from bom_resources
     where resource_id = p_resource_id;

     if( l_resource_type = 2 ) then /* for labor, try get the employee id and num */
       select mec.employee_num
         into l_employee_num
         from mtl_employees_current_view mec
        where mec.employee_id = p_employee_id
          and mec.organization_id = p_organization_id;
        l_employee_id := p_employee_id;
     else
       l_employee_id := null;
       l_employee_num := null;
     end if;

     insert into wip_cost_txn_interface
     (created_by,
      created_by_name,
      creation_date,
      last_updated_by,
      last_updated_by_name,
      last_update_date,
      last_update_login,
      operation_seq_num,
      organization_code,
      organization_id,
      process_phase,
      process_status,
      resource_id,
      resource_code,
      resource_seq_num,
      source_code,
      transaction_date,
      transaction_quantity,
      transaction_type,
      transaction_uom,
      entity_type,
      wip_entity_id,
      wip_entity_name,
      employee_id,
      employee_num)
     values
     (fnd_global.user_id,
      fnd_global.user_name,
      sysdate,
      fnd_global.user_id,
      fnd_global.user_name,
      sysdate,
      fnd_global.login_id,
      p_operation_seq_num,
      l_organization_code,
      p_organization_id,
      WIP_CONSTANTS.RES_VAL,
      WIP_CONSTANTS.PENDING,
      p_resource_id,
      l_resource_code,
      p_resource_seq_num,
      WIP_CONSTANTS.SOURCE_CODE,
      sysdate,
      -- bug 8851845 round transaction_quantity to MAX_DISPLAYED_PRECISION
      round(p_duration, WIP_CONSTANTS.MAX_DISPLAYED_PRECISION), --non time based resource implies no start/end time which means duration is mandatory
      WIP_CONSTANTS.RES_TXN,
      p_uom_code,
      WIP_CONSTANTS.DISCRETE,
      p_wip_entity_id,
      l_wip_entity_name,
      l_employee_id,
      l_employee_num);
     l_return_status := 'S';
   end if;

   x_time_entry_id := l_time_entry_id;
   x_return_status := l_return_status;
END record_insert;

-- Update a record in the wip_resource_actual_times table.
PROCEDURE record_update(
 p_time_entry_id	                   in number,
 p_organization_id  	               in number,
 p_wip_entity_id     	               in number,
 p_operation_seq_num    	           in number,
 p_resource_id                       in number,
 p_resource_seq_num    	             in number,
 p_instance_id  	                   in number,
 p_serial_number          	         in varchar2,
 p_last_update_date     	           in date,
 p_last_updated_by                   in number,
 p_creation_date                     in date,
 p_created_by                        in number,
 p_last_update_login                 in number,
 p_object_version_num                in number,
 p_time_entry_mode                   in number,
 p_cost_flag                         in varchar2,
 p_add_to_rtg                        in varchar2,
 p_status_type                       in number,
 p_start_date                        in date,
 p_end_date                          in date,
 p_projected_completion_date         in date,
 p_duration                          in number,
 p_uom_code                          in varchar2,
 p_employee_id                       in number,
 x_return_status                     out NOCOPY varchar2)
IS
 l_process_status number;
 l_uom_code varchar2(3);
 l_duration number;
 l_object_version_num  number;
 l_start_date date;
 l_time_uom_flag varchar2(1);
 l_projected_completion_date date;
 l_return_status varchar2(10);
BEGIN
   l_object_version_num := p_object_version_num;
   l_start_date := p_start_date;
   l_process_status := 3;  --updated
   l_uom_code := fnd_profile.value('BOM:HOUR_UOM_CODE');
   l_return_status := 'U';

   l_time_uom_flag := is_time_uom(p_uom_code);

   if l_time_uom_flag = 'Y' then
     if (p_duration is null and p_start_date is not null and p_end_date is not null) then
       l_duration := (p_end_date - p_start_date)*24;
     else
       l_duration := p_duration;
     end if;

     if l_duration is not null and l_uom_code <> p_uom_code then
       l_duration := inv_convert.inv_um_convert(item_id       => -1,
                                              precision     => 38,
                                              from_quantity => l_duration,
                                              from_unit     => p_uom_code,
                                              to_unit       => l_uom_code,
                                              from_name     => null,
                                              to_name       => null);
     end if;

     select object_version_number, start_date into l_object_version_num, l_start_date
     from wip_resource_actual_times where time_entry_id = p_time_entry_id;

     if l_start_date <> p_start_date then
       l_projected_completion_date := wip_ws_util.get_projected_completion_date(p_organization_id => p_organization_id,
                                                                                p_wip_entity_id => p_wip_entity_id,
                                                                                p_op_seq_num => p_operation_seq_num,
                                                                                p_resource_seq_num => p_resource_seq_num,
                                                                                p_resource_id => p_resource_id,
                                                                                p_instance_id => p_instance_id,
                                                                                p_start_date => p_start_date);
     else
        l_projected_completion_date  := p_projected_completion_date;
     end if;

     if l_object_version_num = p_object_version_num then
       update wip_resource_actual_times set
       organization_id = p_organization_id,
       wip_entity_id = p_wip_entity_id,
       operation_seq_num = p_operation_seq_num,
       resource_id = p_resource_id,
       resource_seq_num = p_resource_seq_num,
       instance_id = p_instance_id,
       serial_number = p_serial_number,
       creation_date = p_creation_date,
       created_by = p_created_by,
       time_entry_mode = p_time_entry_mode,
       cost_flag = p_cost_flag,
       add_to_rtg = p_add_to_rtg,
       status_type = p_status_type,
       start_date = p_start_date,
       end_date = p_end_date,
       projected_completion_date = l_projected_completion_date,
       duration = l_duration,
       uom_code = l_uom_code,
       employee_id = p_employee_id,
       process_status = l_process_status,
       object_version_number = p_object_version_num + 1,
       last_update_date = sysdate,
       last_updated_by = fnd_global.user_id,
       last_update_login = fnd_global.login_id
       where time_entry_id = p_time_entry_id;

       if p_start_date is not null and l_start_date <> p_start_date then
         update_actual_start_dates(p_wip_entity_id      => p_wip_entity_id,
                                   p_operation_seq_num  => p_operation_seq_num,
                                   p_resource_seq_num   => p_resource_seq_num);

         update_proj_completion_dates(p_organization_id => p_organization_id,
                                      p_wip_entity_id => p_wip_entity_id,
                                      p_operation_seq_num => p_operation_seq_num,
                                      p_resource_seq_num => p_resource_seq_num,
                                      p_resource_id => p_resource_id,
                                      p_start_date => p_start_date);
       end if;

       l_return_status := 'S';
     else
       l_return_status := 'U';  --error condition: stale data
     end if;
   else
     l_return_status := 'U';  --error condition: non time based resources are never updated
   end if;

   x_return_status := l_return_status;
END record_update;

-- Delete a record from the wip_resource_actual_times table.
PROCEDURE record_delete(
 p_time_entry_id	                   in number,
 p_object_version_num                      in number,
 x_return_status                     out NOCOPY varchar2)
IS
 l_process_status number;
 l_object_version_num number;
 l_organization_id number;
 l_wip_entity_id number;
 l_operation_seq_num number;
 l_resource_id number;
 l_resource_seq_num number;
 l_start_date date;
 l_return_status varchar2(10);

 cursor delete_cursor is select object_version_number,
                                organization_id,
                                wip_entity_id,
                                operation_seq_num,
                                resource_id,
                                resource_seq_num,
                                start_date
 from wip_resource_actual_times
 where time_entry_id = p_time_entry_id;
BEGIN
   l_process_status := 4;  --deleted
   l_return_status := 'U';

   open delete_cursor;
   fetch delete_cursor into l_object_version_num,
                            l_organization_id,
                            l_wip_entity_id,
                            l_operation_seq_num,
                            l_resource_id,
                            l_resource_seq_num,
                            l_start_date;
   if delete_cursor%NOTFOUND then
     l_return_status := 'U';
   else
     if l_object_version_num = p_object_version_num then
        update wip_resource_actual_times set
        process_status = l_process_status,
        object_version_number = p_object_version_num + 1,
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.login_id
        where time_entry_id = p_time_entry_id
           and process_status <> 4;

        update_actual_start_dates(p_wip_entity_id      => l_wip_entity_id,
                                  p_operation_seq_num  => l_operation_seq_num,
                                  p_resource_seq_num   => l_resource_seq_num);

        if l_start_date is not null then
          update_proj_completion_dates(p_organization_id => l_organization_id,
                                       p_wip_entity_id => l_wip_entity_id,
                                       p_operation_seq_num => l_operation_seq_num,
                                       p_resource_seq_num => l_resource_seq_num,
                                       p_resource_id => l_resource_id,
                                       p_start_date => l_start_date);
        end if;

        l_return_status := 'S';
     end if;
   end if;
   close delete_cursor;
   x_return_status := l_return_status;
END record_delete;

-- Delete a record from the wip_resource_actual_times table.
PROCEDURE record_delete(
 p_wip_entity_id	                   in number,
 p_operation_seq_num                 in number,
 p_employee_id                       in number,
 x_return_status                     out NOCOPY varchar2)
IS
 l_process_status number;
 l_object_version_num number;
 l_organization_id number;
 l_resource_id number;
 l_resource_seq_num number;
 l_start_date date;
 l_return_status varchar2(10);

 cursor delete_cursor is select object_version_number,
                                organization_id,
                                resource_id,
                                resource_seq_num,
                                start_date
 from wip_resource_actual_times
 where wip_entity_id = p_wip_entity_id
       and operation_seq_num = p_operation_seq_num
       and employee_id = p_employee_id
       and process_status <> 4;
BEGIN
   l_process_status := 4;  --deleted
   l_return_status := 'U';

   open delete_cursor;
   fetch delete_cursor into l_object_version_num,
                            l_organization_id,
                            l_resource_id,
                            l_resource_seq_num,
                            l_start_date;
   if delete_cursor%NOTFOUND then
     l_return_status := 'U';
   else
     update wip_resource_actual_times set
     process_status = l_process_status,
     object_version_number = l_object_version_num + 1,
     last_update_date = sysdate,
     last_updated_by = fnd_global.user_id,
     last_update_login = fnd_global.login_id
     where wip_entity_id = p_wip_entity_id
           and operation_seq_num = p_operation_seq_num
           and employee_id = p_employee_id
           and process_status <> 4;

     update_actual_start_dates(p_wip_entity_id      => p_wip_entity_id,
                               p_operation_seq_num  => p_operation_seq_num,
                               p_resource_seq_num   => l_resource_seq_num);

     if l_start_date is not null then
       update_proj_completion_dates(p_organization_id => l_organization_id,
                                    p_wip_entity_id => p_wip_entity_id,
                                    p_operation_seq_num => p_operation_seq_num,
                                    p_resource_seq_num => l_resource_seq_num,
                                    p_resource_id => l_resource_id,
                                    p_start_date => l_start_date);
     end if;

     l_return_status := 'S';
   end if;
   close delete_cursor;
   x_return_status := l_return_status;
END record_delete;

/*************************************************/
/* Local Procedures                              */
/*   job_off_internal                            */
/*   clock_out_labors                            */
/*   clock_out_machines                          */
/*************************************************/
PROCEDURE job_off_internal(p_wip_entity_id IN NUMBER, p_operation_seq_num NUMBER)
IS
BEGIN

  update wip_operations
  set employee_id = null
  where wip_entity_id = p_wip_entity_id
    and operation_seq_num = p_operation_seq_num
    and employee_id is not null;

END job_off_internal;

procedure clock_out_labors(p_wip_entity_id number, p_operation_seq_num number, exclude_scheduled_flag number)
is
  l_uom_code varchar2(3);
  l_date date;
Begin
   l_uom_code := fnd_profile.value('BOM:HOUR_UOM_CODE');
   l_date := sysdate;

   update wip_resource_actual_times t
   set
      end_date = l_date,
      duration = (l_date - start_date)*24,
      uom_code = l_uom_code,
      process_status = '3',
      object_version_number = object_version_number + 1,
      last_update_date = l_date,
      last_updated_by = fnd_global.user_id,
      last_update_login = fnd_global.login_id
    where wip_entity_id = p_wip_entity_id
      and operation_seq_num = p_operation_seq_num
      and process_status <> 4
      and status_type = 1
      and start_date is not null
      and end_date is null
      and resource_id in (select resource_id from bom_resources where resource_type = 2)
      and (exclude_scheduled_flag is null or
           exclude_scheduled_flag <>
           nvl((select scheduled_flag from wip_operation_resources wor
            where wor.wip_entity_id = t.wip_entity_id
              and wor.operation_seq_num = t.operation_seq_num
              and wor.resource_seq_num = t.resource_seq_num), 2) /* ad-hoc has no scheduled flag*/
          );

End clock_out_labors;

procedure clock_out_machines(p_wip_entity_id number, p_operation_seq_num number)
is

 cursor all_labor_clocked_out(p_scheduled_flag number) is
 select
 decode(
 ( select count(*)
     from wip_resource_actual_times wrat,
          bom_resources br,
          wip_operation_resources wor
    where wrat.wip_entity_id = p_wip_entity_id
      and wrat.operation_seq_num = p_operation_seq_num
      and wrat.resource_id = br.resource_id
      and wrat.wip_entity_id = wor.wip_entity_id (+) /* ad hoc resource not in wor */
      and wrat.operation_seq_num = wor.operation_seq_num (+)
      and wrat.resource_id = wor.resource_id (+)
      and wrat.process_status <> 4
      and wrat.status_type = 1
      and br.resource_type = 2  /* labor */
      and decode(wor.scheduled_flag, null, 1, 2, 1, wor.scheduled_flag) = p_scheduled_flag
      and wrat.start_date is not null
     and wrat.end_date is null
  ), 0, 1, 0)
  from dual;

 /* max end date for yes/no labor resources */
 cursor max_labor_end_date(p_scheduled_flag number) is
 select max(wrat.end_date)
 from wip_resource_actual_times wrat,
      bom_resources br,
      wip_operation_resources wor
 where wrat.wip_entity_id = p_wip_entity_id
   and wrat.operation_seq_num = p_operation_seq_num
   and wrat.resource_id = br.resource_id
   and wrat.wip_entity_id = wor.wip_entity_id (+) /* ad hoc resource not in wor */
   and wrat.operation_seq_num = wor.operation_seq_num (+)
   and wrat.resource_id = wor.resource_id (+)
   and wrat.process_status <> 4
   and br.resource_type = 2  /* labor */
   and decode(wor.scheduled_flag, null, 1, 2, 1, wor.scheduled_flag) = p_scheduled_flag
   and wrat.end_date is not null;

 l_all_clocked_out number;
 l_scheduled_flag number;
 l_date date;
 l_uom_code varchar2(10);
Begin

  l_uom_code := fnd_profile.value('BOM:HOUR_UOM_CODE');

  /* scheduled yes/no resource */
  l_scheduled_flag := 1;

  open all_labor_clocked_out(l_scheduled_flag);
  fetch all_labor_clocked_out into l_all_clocked_out;
  close all_labor_clocked_out;

  if( l_all_clocked_out = 1) then
    open max_labor_end_date(l_scheduled_flag);
    fetch max_labor_end_date into l_date;
    close max_labor_end_date;

    if( l_date is null ) then l_date := sysdate; end if;

    update wip_resource_actual_times t
    set
      end_date = l_date,
      duration = (l_date - start_date)*24,
      uom_code = l_uom_code,
      process_status = '3',
      object_version_number = object_version_number + 1,
      last_update_date = sysdate,
      last_updated_by = fnd_global.user_id,
      last_update_login = fnd_global.login_id
    where wip_entity_id = p_wip_entity_id
      and operation_seq_num = p_operation_seq_num
      and status_type = 1
      and start_date is not null
      and end_date is null
      and resource_id in (select resource_id from bom_resources where resource_type = 1)
      and ( select decode(scheduled_flag, 2, 1, scheduled_flag)
            from wip_operation_resources wor
           where wor.wip_entity_id = t.wip_entity_id
             and wor.operation_seq_num = t.operation_seq_num
             and wor.resource_seq_num = t.resource_seq_num) = l_scheduled_flag;
  end if;


  /* prior resources */
  l_scheduled_flag := 3;

  open all_labor_clocked_out(l_scheduled_flag);
  fetch all_labor_clocked_out into l_all_clocked_out;
  close all_labor_clocked_out;

  if( l_all_clocked_out = 1) then
    open max_labor_end_date(l_scheduled_flag);
    fetch max_labor_end_date into l_date;
    close max_labor_end_date;

    if( l_date is null ) then l_date := sysdate; end if;

    update wip_resource_actual_times t
    set
      end_date = l_date,
      duration = (l_date - start_date)*24,
      process_status = '3',
      object_version_number = object_version_number + 1,
      last_update_date = sysdate,
      last_updated_by = fnd_global.user_id,
      last_update_login = fnd_global.login_id
    where wip_entity_id = p_wip_entity_id
      and operation_seq_num = p_operation_seq_num
      and status_type = 1
      and start_date is not null
      and end_date is null
      and resource_id in (select resource_id from bom_resources where resource_type = 1)
      and ( select decode(scheduled_flag, 2, 1, scheduled_flag)
            from wip_operation_resources wor
           where wor.wip_entity_id = t.wip_entity_id
             and wor.operation_seq_num = t.operation_seq_num
             and wor.resource_seq_num = t.resource_seq_num) = l_scheduled_flag;
  end if;

  /* next resources */
  l_scheduled_flag := 4;

  open all_labor_clocked_out(l_scheduled_flag);
  fetch all_labor_clocked_out into l_all_clocked_out;
  close all_labor_clocked_out;

  if( l_all_clocked_out = 1) then
    open max_labor_end_date(l_scheduled_flag);
    fetch max_labor_end_date into l_date;
    close max_labor_end_date;

    if( l_date is null ) then l_date := sysdate; end if;

    update wip_resource_actual_times t
    set
      end_date = l_date,
      duration = (l_date - start_date)*24,
      process_status = '3',
      object_version_number = object_version_number + 1,
      last_update_date = sysdate,
      last_updated_by = fnd_global.user_id,
      last_update_login = fnd_global.login_id
    where wip_entity_id = p_wip_entity_id
      and operation_seq_num = p_operation_seq_num
      and status_type = 1
      and start_date is not null
      and end_date is null
      and resource_id in (select resource_id from bom_resources where resource_type = 1)
      and ( select decode(scheduled_flag, 2, 1, scheduled_flag)
            from wip_operation_resources wor
           where wor.wip_entity_id = t.wip_entity_id
             and wor.operation_seq_num = t.operation_seq_num
             and wor.resource_seq_num = t.resource_seq_num) = l_scheduled_flag;
  end if;

End clock_out_machines;

function get_adhoc_resource_seq(p_wip_entity_id number, p_operation_seq_num number, p_resource_id number)
return number
Is
  -- check if the resuorce is aleady used in wrat
  cursor resource_seq_in_wrat is
    select resource_seq_num
      from wip_resource_actual_times
     where wip_entity_id = p_wip_entity_id
       and operation_seq_num = p_operation_seq_num
       and resource_id = p_resource_id
       and resource_seq_num is not null
       and rownum=1;

  l_resource_seq_num number;
  l_next_resource_seq_num number;
  l_wor_max number;
  l_wrat_max number;
Begin

  l_resource_seq_num := null;

  open resource_seq_in_wrat;
  fetch resource_seq_in_wrat into l_resource_seq_num;

  if( resource_seq_in_wrat%NOTFOUND ) then

    select max(wor.resource_seq_num) seq
      into l_wor_max
      from wip_operation_resources wor
     where wor.wip_entity_id = p_wip_entity_id
       and wor.operation_seq_num = p_operation_seq_num;

    select max(wrat.resource_seq_num) seq
      into l_wrat_max
      from wip_resource_actual_times wrat
     where wrat.wip_entity_id = p_wip_entity_id
       and wrat.operation_seq_num = p_operation_seq_num
       and wrat.resource_seq_num is not null;

    select greatest(nvl(l_wor_max,0), nvl(l_wrat_max,0)) + 10
      into l_resource_seq_num
      from dual;

  end if;
  close resource_seq_in_wrat;

  return l_resource_seq_num;
End get_adhoc_resource_seq;

/* update the operation/resources's actual completion date based on wrat */
procedure update_actual_comp_dates(p_wip_entity_id IN NUMBER,
                                   p_operation_seq_num IN NUMBER)
IS
Begin

  /* update wor's actual completion date */
  update wip_operation_resources wor
  set
    wor.actual_completion_date =
    nvl( ( select max(wrat.end_date)
       from wip_resource_actual_times wrat
       where wrat.wip_entity_id = wor.wip_entity_id
         and wrat.operation_seq_num = wor.operation_seq_num
         and wrat.resource_seq_num = wor.resource_seq_num
         and wrat.process_status <> 4
         and wrat.end_date is not null), sysdate)
  where wip_entity_id = p_wip_entity_id
    and operation_seq_num = p_operation_seq_num
    and not exists (select wrat.end_date
                      from wip_resource_actual_times wrat
                     where wrat.wip_entity_id = wor.wip_entity_id
                       and wrat.operation_seq_num = wor.operation_seq_num
                       and wrat.resource_seq_num = wor.resource_seq_num
                       and wrat.start_date is not null
                       and wrat.end_date is null
                       and wrat.process_status <> 4);

  update wip_operations wo
  set
    wo.actual_completion_date =
    nvl(greatest( ( select max(wor.actual_completion_date)
                      from wip_operation_resources wor
                     where wor.wip_entity_id = wo.wip_entity_id
                       and wor.operation_seq_num = wo.operation_seq_num
                       and wor.actual_completion_date is not null)
                , ( select max(wrat.end_date)
                      from wip_resource_actual_times wrat
                     where wrat.wip_entity_id = wo.wip_entity_id
                       and wrat.operation_seq_num = wo.operation_seq_num
                       and wrat.end_date is not null)
                ), sysdate)
  where wip_entity_id = p_wip_entity_id
    and operation_seq_num = p_operation_seq_num
    and not exists (select 1
                      from wip_resource_actual_times wrat
                     where wrat.wip_entity_id = wo.wip_entity_id
                       and wrat.operation_seq_num = wo.operation_seq_num
                       and wrat.start_date is not null
                       and wrat.end_date is null
                       and wrat.process_status <> 4);

End update_actual_comp_dates;

-- Process records on report resource usages page.
PROCEDURE process_time_records_resource(p_organization_id in number)
IS
 l_wip_entity_id number;
 l_op_seq_num number;

 cursor time_records_all_cursor is
 select distinct wrat.wip_entity_id,
                 wrat.operation_seq_num
 from wip_resource_actual_times wrat
 where wrat.organization_id = p_organization_id
 and wrat.status_type = 1
 and wrat.process_status = 2 /* only new records */
 and wrat.duration is not null;

BEGIN
  for time_record IN time_records_all_cursor
  loop
    l_wip_entity_id := time_record.wip_entity_id;
    l_op_seq_num := time_record.operation_seq_num;
    process_time_records(p_wip_entity_id     => l_wip_entity_id,
                         p_completed_op      => l_op_seq_num,
                         p_instance_id       => null,
                         p_time_entry_source => 'resource');
  end loop;
END process_time_records_resource;

-- Process records on report my time page.
PROCEDURE process_time_records_my_time(p_organization_id in number,
                                       p_instance_id in number)
IS
 l_wip_entity_id number;
 l_op_seq_num number;

 cursor time_records_mytime_cursor is
 select distinct wrat.wip_entity_id,
                 wrat.operation_seq_num
 from wip_resource_actual_times wrat
 where wrat.organization_id = p_organization_id
 and wrat.instance_id = p_instance_id
 and wrat.status_type = 1
 and wrat.process_status in (2, 3, 4)
 and (wrat.time_entry_mode in (3,4) or wrat.process_status = 2)
 and wrat.duration is not null;

BEGIN
  for time_record IN time_records_mytime_cursor
  loop
    l_wip_entity_id := time_record.wip_entity_id;
    l_op_seq_num := time_record.operation_seq_num;
    process_time_records(p_wip_entity_id     => l_wip_entity_id,
                         p_completed_op      => l_op_seq_num,
                         p_instance_id       => p_instance_id,
                         p_time_entry_source => 'mytime');
  end loop;
END process_time_records_my_time;

-- Process records on move page.
PROCEDURE process_time_records_move(p_wip_entity_id IN NUMBER,
                                    p_from_op IN NUMBER,
                                    p_to_op IN NUMBER)
IS
 l_curr_op number;

 cursor op_seq_num_cursor is
 select operation_seq_num
 from wip_operations
 where wip_entity_id = p_wip_entity_id
       and operation_seq_num >= p_from_op
       and operation_seq_num <= p_to_op;
BEGIN
  for op_seq_num_record IN op_seq_num_cursor
  loop
    l_curr_op := op_seq_num_record.operation_seq_num;
    process_time_records(p_wip_entity_id     => p_wip_entity_id,
                         p_completed_op      => l_curr_op,
                         p_instance_id       => null,
                         p_time_entry_source => 'move');
  end loop;
END process_time_records_move;

-- Process records on report job operation page.
PROCEDURE process_time_records_job_op(p_wip_entity_id IN NUMBER,
                                      p_operation_seq_num IN NUMBER,
                                      p_instance_id in number)
IS
BEGIN
  process_time_records(p_wip_entity_id     => p_wip_entity_id,
                       p_completed_op      => p_operation_seq_num,
                       p_instance_id       => p_instance_id,
                       p_time_entry_source => 'jobop');
END process_time_records_job_op;

-- Process records.
PROCEDURE process_time_records(p_wip_entity_id IN NUMBER,
                               p_completed_op IN NUMBER,
                               p_instance_id IN NUMBER,
                               p_time_entry_source IN VARCHAR2)
IS
 l_object_version_num number;
 l_add_to_rtg varchar2(1);
 l_cost_flag varchar2(1);
 l_status_type number;
 l_process_status number;
 l_resource_seq_num number;
 l_org_id number;
 l_resource_id number;
 l_duration number;
 l_uom_code varchar2(3);
 l_employee_id number;
 l_instance_id number;
 l_resource_type number;
 l_scheduled_flag number;
 l_next_resource_seq_num number;
 l_end_date date;
 l_time_entry_mode number;
 l_last_op_qty_num number;
 l_last_job_qty_num number;
 l_last_op_qty varchar2(1);
 l_last_job_qty varchar2(1);
 l_completed_status_type number;
 l_completed_process_status number;
 l_organization_code varchar2(3);
 l_resource_code varchar2(10);
 l_wip_entity_name varchar2(240);
 l_change_flag varchar2(1);
 lx_organization_id number;
 lx_department_id number;
 lx_status varchar2(1);
 lx_msg_count number;
 lx_msg varchar2(255);

 l_employee_num varchar2(30);

 --time records (for all resource types) cursor- used for setting cost_flag, add_to_rtg,
 -- resource_seq_num (for ad-hoc resources), inserting into wcti and updating wrat status_type to completed
 cursor time_records_cursor (c_time_entry_mode1 number,
                             c_time_entry_mode2 number,
                             c_time_entry_mode3 number) is
 select wrat.time_entry_id,
        wrat.object_version_number,
        wrat.add_to_rtg,
        wrat.cost_flag,
        wrat.status_type,
        wrat.process_status,
        wrat.resource_seq_num,
        wrat.organization_id,
        wrat.resource_id,
        wrat.duration,
        wrat.uom_code,
        wrat.end_date,
        wrat.time_entry_mode
 from wip_resource_actual_times wrat,
      bom_resources br,
      wip_operation_resources wor
 where wrat.wip_entity_id = p_wip_entity_id
 and wrat.operation_seq_num = p_completed_op
 and wrat.resource_id = br.resource_id
 and wrat.wip_entity_id = wor.wip_entity_id (+)
 and wrat.operation_seq_num = wor.operation_seq_num (+)
 and wrat.resource_id = wor.resource_id (+)
 and wrat.status_type = 1
 and wrat.process_status <> 4
 and ( wrat.process_status in (2, 3) or
       ( wrat.time_entry_mode in (c_time_entry_mode1,
                                   c_time_entry_mode2, c_time_entry_mode3)
         and (p_instance_id is null or wrat.instance_id = p_instance_id)
     ) )
 ; -- and wrat.duration is not null;


 --find out if there are any active next resources
 cursor active_clock_cursor is
 select count(*)
   from wip_resource_actual_times wrat,
        wip_operation_resources wor
  where wrat.wip_entity_id = p_wip_entity_id
    and wrat.operation_seq_num = p_completed_op
    and wrat.status_type = 1
    and wrat.process_status <> 4
    and wrat.start_date is not null
    and wrat.end_date is null
    and wrat.wip_entity_id = wor.wip_entity_id
    and wrat.operation_seq_num = wor.operation_seq_num
    and wrat.resource_id = wor.resource_id;

 l_active_clocks number;
 l_entry_id number;
BEGIN
  l_completed_status_type := 2;     --completed
  l_completed_process_status := 1;  --completed

  l_last_op_qty_num := get_last_op_qty(p_wip_entity_id => p_wip_entity_id,
                                       p_operation_seq_num => p_completed_op);
  if l_last_op_qty_num = 0 then
    l_last_op_qty := 'Y';
  end if;

  l_last_job_qty_num := get_last_job_qty(p_wip_entity_id => p_wip_entity_id,
                                         p_operation_seq_num => p_completed_op);
  if l_last_job_qty_num = 0 then
    l_last_job_qty := 'Y';
  end if;

  if (l_last_op_qty = 'Y' and p_time_entry_source = 'move') then
    clock_out_labors(p_wip_entity_id, p_completed_op, 4); /* don't clock out next resources */
  end if;

  if (l_last_job_qty = 'Y') then
    clock_out_machines(p_wip_entity_id, p_completed_op);
  end if;

  /* if there is still active clock-ins */
  l_active_clocks := null;
  open active_clock_cursor;
  fetch active_clock_cursor into l_active_clocks;
  close active_clock_cursor;

  if (p_time_entry_source = 'move') then
    open time_records_cursor(4,-1,-1);
  elsif (p_time_entry_source = 'clock') then
    open time_records_cursor(2,-1,-1);
  elsif (p_time_entry_source = 'resource') then
    open time_records_cursor(-1,-1,-1); /* only new records */
  else
    open time_records_cursor(3,4,4);
  end if;

  loop
    fetch time_records_cursor into l_entry_id,
                                   l_object_version_num,
                                   l_add_to_rtg,
                                   l_cost_flag,
                                   l_status_type,
                                   l_process_status,
                                   l_resource_seq_num,
                                   l_org_id,
                                   l_resource_id,
                                   l_duration,
                                   l_uom_code,
                                   l_end_date,
                                   l_time_entry_mode;
    exit when time_records_cursor%NOTFOUND;

    /* add the cost_flag and add_to_rtg and resource seq for the inserted rows */
    if ( l_process_status = 2 ) then
      l_change_flag := 'N';

      if (l_cost_flag is null) then
        l_cost_flag := get_cost_flag(p_wip_entity_id     => p_wip_entity_id,
                                     p_operation_seq_num => p_completed_op,
                                     p_resource_seq_num  => l_resource_seq_num,
                                     p_time_entry_source => p_time_entry_source);
        l_change_flag := 'Y';
      end if;

      if (l_add_to_rtg is null) then
        l_add_to_rtg := get_add_to_rtg_flag(p_wip_entity_id     => p_wip_entity_id,
                                            p_operation_seq_num => p_completed_op,
                                            p_resource_seq_num  => l_resource_seq_num,
                                            p_cost_flag         => l_cost_flag,
                                          p_time_entry_source => p_time_entry_source);
        l_change_flag := 'Y';
      end if;

      if (l_add_to_rtg = 'Y' and l_resource_seq_num is null) then
        l_resource_seq_num := get_adhoc_resource_seq(
                                p_wip_entity_id, p_completed_op, l_resource_id);
        l_change_flag := 'Y';
      end if;

      if l_change_flag = 'Y' then
        update wip_resource_actual_times
        set
          cost_flag = l_cost_flag,
          add_to_rtg = l_add_to_rtg,
          resource_seq_num = l_resource_seq_num,
          object_version_number = l_object_version_num + 1,
          last_update_date = sysdate,
          last_updated_by = fnd_global.user_id,
          last_update_login = fnd_global.login_id
        where time_entry_id = l_entry_id;
      end if;
    end if;

    /* if it's called from clock, auto-clocked in machines needs to be review later*/
    if( l_duration is not null
        and not (p_time_entry_source = 'clock' and l_time_entry_mode <> 2)
        and not (p_time_entry_source = 'move'  and l_time_entry_mode = 3) /* clock out but not charge */
      ) then
      if (l_cost_flag = 'Y') then
        select organization_code
        into l_organization_code
        from mtl_parameters
        where organization_id = l_org_id;

        select wip_entity_name
        into l_wip_entity_name
        from wip_entities
        where wip_entity_id = p_wip_entity_id;

        select resource_code, resource_type
        into l_resource_code, l_resource_type
        from bom_resources
        where resource_id = l_resource_id;

        if( l_resource_type = 2 ) then /* for labor, try get the employee id and num */

          /* Bug 6891758. If the employee is not associated to the business unit for the organization
             we will still allow them to do clock-out as it's for reporting purpose.
             But resource charging will not be allowed.*/
          begin
													select wrat.employee_id, mec.employee_num
													into l_employee_id, l_employee_num
													from wip_resource_actual_times wrat, mtl_employees_current_view mec
													where wrat.time_entry_id = l_entry_id
													and wrat.employee_id = mec.employee_id
													and wrat.organization_id = mec.organization_id;
          exception
          when no_data_found then
             G_RES_CHG_FAILED := wip_constants.yes;
          end;
        else
          l_employee_id := null;
          l_employee_num := null;
        end if;

        if G_RES_CHG_FAILED <> wip_constants.yes then

        insert into wip_cost_txn_interface(
        created_by,
        created_by_name,
        creation_date,
        last_updated_by,
        last_updated_by_name,
        last_update_date,
        last_update_login,
        operation_seq_num,
        organization_code,
        organization_id,
        process_phase,
        process_status,
        resource_id,
        resource_code,
        resource_seq_num,
        source_code,
        transaction_date,
        transaction_quantity,
        transaction_type,
        transaction_uom,
        entity_type,
        wip_entity_id,
        wip_entity_name,
        employee_id,
        employee_num)
        values(
        fnd_global.user_id,
        fnd_global.user_name,
        sysdate,
        fnd_global.user_id,
        fnd_global.user_name,
        sysdate,
        fnd_global.login_id,
        p_completed_op,
        l_organization_code,
        l_org_id,
        WIP_CONSTANTS.RES_VAL,
        WIP_CONSTANTS.PENDING,
        l_resource_id,
        l_resource_code,
        l_resource_seq_num,
        WIP_CONSTANTS.SOURCE_CODE,
        sysdate,
        -- bug 8851845 round transaction_quantity to MAX_DISPLAYED_PRECISION
        round(l_duration, WIP_CONSTANTS.MAX_DISPLAYED_PRECISION), --non time based resource implies no start/end time which means duration is mandatory
        WIP_CONSTANTS.RES_TXN,
        l_uom_code,
        WIP_CONSTANTS.DISCRETE,
        p_wip_entity_id,
        l_wip_entity_name,
        l_employee_id,
        l_employee_num);

        end if;
      end if;

      --mark status type complete for wrat records
      update wip_resource_actual_times
      set
        status_type = l_completed_status_type,
        process_status = l_completed_process_status,
        object_version_number = l_object_version_num + 1,
        last_update_date = sysdate,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.login_id
      where time_entry_id = l_entry_id;

    end if;
  end loop;
  close time_records_cursor;

  /* job-off if no active clock-ins and is the last qty */
    if (l_last_job_qty = 'Y') then
      if( l_active_clocks = 0 ) then
        job_off_internal(p_wip_entity_id, p_completed_op);
      end if;
      update_actual_comp_dates(p_wip_entity_id, p_completed_op);
    end if;

  /* for wrat records with process status deleted - delete records */
  delete from wip_resource_actual_times
  where wip_entity_id = p_wip_entity_id
        and operation_seq_num = p_completed_op
        and status_type = 1
        and process_status = 4;

  /* reset process_status of records of inserted/updated - mark as completed */
  update wip_resource_actual_times set
  process_status = l_completed_process_status,
  last_update_date = sysdate,
  last_updated_by = fnd_global.user_id,
  last_update_login = fnd_global.login_id
  where wip_entity_id = p_wip_entity_id
        and operation_seq_num = p_completed_op
        and status_type = 1
        and process_status in (2,3);
END process_time_records;

/* to check if UOM time based */
FUNCTION is_time_uom(p_uom_code IN VARCHAR2) return VARCHAR2
IS
 l_uom_class varchar2(10);
 l_time_based_uom_flag varchar2(1);

 cursor time_based_uom_cursor is
 select distinct muc.uom_class
 from mtl_uom_conversions  muc,
      mtl_uom_conversions  muc2
 where (muc.uom_class = muc2.uom_class and
       nvl(muc.disable_date, sysdate + 1) > sysdate) and
       nvl(muc2.disable_date, sysdate + 1) > sysdate and
       muc.uom_code = fnd_profile.value('BOM:HOUR_UOM_CODE') and
       muc2.uom_code = p_uom_code;
BEGIN
  open time_based_uom_cursor;
  fetch time_based_uom_cursor into l_uom_class;
  if time_based_uom_cursor%NOTFOUND then
    l_time_based_uom_flag := 'N';
  else
    l_time_based_uom_flag := 'Y';
  end if;
  close time_based_uom_cursor;

  return l_time_based_uom_flag;
END is_time_uom;

-- Get the value for time entry mode.
FUNCTION get_time_entry_mode(p_wip_entity_id IN NUMBER,
                        p_operation_seq_num IN NUMBER) return NUMBER
IS
 l_time_entry_mode varchar2(2); -- Modified for Bug 6663985.
 lx_organization_id number;
 lx_department_id number;
BEGIN
  get_org_dept_ids(p_wip_entity_id     => p_wip_entity_id,
                   p_operation_seq_num => p_operation_seq_num,
                   x_organization_id   => lx_organization_id,
                   x_department_id     => lx_department_id);

  l_time_entry_mode := wip_ws_util.get_preference_value_code(p_pref_id => G_WIP_WS_PREF_TIME_ENTRY_MODE,
                                                             p_resp_key => wip_ws_util.get_current_resp_key,
                                                             p_org_id => lx_organization_id,
                                                             p_dept_id => lx_department_id);
  return mod(l_time_entry_mode,10);
END get_time_entry_mode;

-- Get the value for cost_flag.
FUNCTION get_cost_flag(p_wip_entity_id IN NUMBER,
                       p_operation_seq_num IN NUMBER,
                       p_resource_seq_num IN NUMBER,
                       p_time_entry_source IN VARCHAR2) return VARCHAR2
IS
 l_charge_time_resources_pref varchar2(1);
 l_autocharge_type number;
 l_cost_flag varchar2(1);
 lx_organization_id number;
 lx_department_id number;

 l_manual_exist number;
 cursor has_autocharge_manual_cursor is
 select 1
   from wip_operation_resources wor
  where wor.wip_entity_id = p_wip_entity_id
    and wor.operation_seq_num = p_operation_seq_num
    and wor.autocharge_type = G_BOM_AUTOCHARGE_TYPE_MANUAL
    and rownum = 1;

 cursor autocharge_type_res_cursor is select wor.autocharge_type
 from wip_operation_resources wor
 where wor.wip_entity_id = p_wip_entity_id
 and wor.operation_seq_num = p_operation_seq_num
 and wor.resource_seq_num = p_resource_seq_num;
BEGIN
  if (p_time_entry_source = 'move') then  --time entry source is 'move'
    l_cost_flag := 'Y';
  else
    get_org_dept_ids(p_wip_entity_id     => p_wip_entity_id,
                     p_operation_seq_num => p_operation_seq_num,
                     x_organization_id   => lx_organization_id,
                     x_department_id     => lx_department_id);
    l_charge_time_resources_pref := wip_ws_util.get_preference_value_code(p_pref_id => G_WIP_WS_PREF_CHARGE_RESOURCE,
                                                                          p_resp_key => wip_ws_util.get_current_resp_key,
                                                                          p_org_id => lx_organization_id,
                                                                          p_dept_id => lx_department_id);
    if (p_time_entry_source = 'clock') then  --time entry source is 'clock'
      if (l_charge_time_resources_pref = '2') then
        l_cost_flag := 'N';
      elsif (p_resource_seq_num is null) then  --resource is ad-hoc
        l_cost_flag := 'N';

        l_manual_exist := 0;
        open has_autocharge_manual_cursor;
        fetch has_autocharge_manual_cursor into l_manual_exist;
        close has_autocharge_manual_cursor;

        if (l_manual_exist = 1 ) then
            l_cost_flag := 'Y';
        end if;
      else
        open autocharge_type_res_cursor;
        fetch autocharge_type_res_cursor into l_autocharge_type;
        if autocharge_type_res_cursor%NOTFOUND then
          l_cost_flag := 'N';
        elsif (l_autocharge_type = G_BOM_AUTOCHARGE_TYPE_MANUAL) then  --resource is manual
          l_cost_flag := 'Y';
        else
          l_cost_flag := 'N';
        end if;
        close autocharge_type_res_cursor;
      end if;
    else  --time entry source is 'mytime', 'jobop' or 'resource'
      if (l_charge_time_resources_pref = '2') then
        l_cost_flag := 'N';
      else
        l_cost_flag := 'Y';
      end if;
    end if;
  end if;
  return l_cost_flag;
END get_cost_flag;

/* Get the value for add_to_rtg
  Since the insertion of a wor is done through cost txn, so this is simplified */
FUNCTION get_add_to_rtg_flag(p_wip_entity_id IN NUMBER,
                             p_operation_seq_num IN NUMBER,
                             p_resource_seq_num IN NUMBER,
                             p_cost_flag IN VARCHAR2,
                             p_time_entry_source IN VARCHAR2) return VARCHAR2
IS
 l_add_to_rtg_flag varchar2(1);
 l_cost_flag varchar(1);
BEGIN
  l_cost_flag := p_cost_flag;

  if( l_cost_flag is null ) then
    l_cost_flag := get_cost_flag(p_wip_entity_id => p_wip_entity_id,
                                 p_operation_seq_num => p_operation_seq_num,
                                 p_resource_seq_num => p_resource_seq_num,
                                 p_time_entry_source => p_time_entry_source);
  end if;

  if (l_cost_flag = 'Y' and p_resource_seq_num is null) then
    l_add_to_rtg_flag := 'Y';
  else
    l_add_to_rtg_flag := 'N';
  end if;

  return l_add_to_rtg_flag;
END get_add_to_rtg_flag;

-- Get Organization Id and Department Id.
PROCEDURE get_org_dept_ids(p_wip_entity_id IN NUMBER,
                 p_operation_seq_num IN NUMBER,
                 x_organization_id out NOCOPY NUMBER,
                 x_department_id out NOCOPY NUMBER)
IS
 l_organization_id number;
 l_department_id number;

 cursor org_dept_cursor is select wo.organization_id, wo.department_id
 from wip_operations wo
 where wo.wip_entity_id = p_wip_entity_id
 and wo.operation_seq_num = p_operation_seq_num;
BEGIN
  open org_dept_cursor;
  fetch org_dept_cursor into l_organization_id, l_department_id;
  if org_dept_cursor%NOTFOUND then
    l_organization_id := -1;
    l_department_id := -1;
  end if;
  x_organization_id := l_organization_id;
  x_department_id := l_department_id;
  close org_dept_cursor;
END get_org_dept_ids;

-- Update the value of actual start date in wdj, wo and wor tables
PROCEDURE update_actual_start_dates(p_wip_entity_id IN NUMBER,
                                    p_operation_seq_num IN NUMBER,
                                    p_resource_seq_num IN NUMBER)
IS
 l_min_start_date date;

 l_min_start_date_wrat date;

 cursor min_start_date_wrat_cursor is select min(wrat.start_date)
 from wip_resource_actual_times wrat
 where wrat.wip_entity_id = p_wip_entity_id
 and wrat.operation_seq_num = p_operation_seq_num
 and nvl(wrat.resource_seq_num, -1) = nvl(p_resource_seq_num, -1)
 and wrat.start_date is not null
 and wrat.process_status <> 4;

 cursor min_start_date_wor_cursor is select min(wor.actual_start_date)
 from wip_operation_resources wor
 where wor.wip_entity_id = p_wip_entity_id
 and wor.operation_seq_num = p_operation_seq_num
 and wor.actual_start_date is not null;

 cursor min_start_date_wo_cursor is select min(wo.actual_start_date)
 from wip_operations wo
 where wo.wip_entity_id = p_wip_entity_id
 and wo.actual_start_date is not null;
BEGIN

  l_min_start_date := null;
  open min_start_date_wrat_cursor;
  fetch min_start_date_wrat_cursor into l_min_start_date;
  if min_start_date_wrat_cursor%FOUND then
    if l_min_start_date is not null then
      update wip_operation_resources set
      actual_start_date = l_min_start_date
      where wip_entity_id = p_wip_entity_id
            and operation_seq_num = p_operation_seq_num
            and resource_seq_num = p_resource_seq_num;
    end if;
  end if;
  close min_start_date_wrat_cursor;

  /* save it */
  l_min_start_date_wrat := l_min_start_date;

  l_min_start_date := null;
  open min_start_date_wor_cursor;
  fetch min_start_date_wor_cursor into l_min_start_date;
  if( l_min_start_date_wrat is not null ) then
    select decode(l_min_start_date, null, l_min_start_date_wrat,
       least(l_min_start_date_wrat, l_min_start_date) )
    into l_min_start_date
    from dual;
  end if;

  if l_min_start_date is not null then
      update wip_operations set
      actual_start_date = l_min_start_date
      where wip_entity_id = p_wip_entity_id
            and operation_seq_num = p_operation_seq_num;
  end if;
  close min_start_date_wor_cursor;

  open min_start_date_wo_cursor;
  fetch min_start_date_wo_cursor into l_min_start_date;
  if min_start_date_wo_cursor%FOUND then
    if l_min_start_date is not null then
      update wip_discrete_jobs set
      actual_start_date = l_min_start_date
      where wip_entity_id = p_wip_entity_id;
    end if;
  end if;
  close min_start_date_wo_cursor;
END update_actual_start_dates;

-- Update the value of actual completion date in wo and wor tables
PROCEDURE update_actual_completion_dates(p_wip_entity_id IN NUMBER,
                                         p_operation_seq_num IN NUMBER,
                                         p_resource_seq_num IN NUMBER)
IS
 l_max_end_date date;
 l_active_next_resource_flag varchar2(1);

 cursor max_end_date_wrat_cursor is select max(wrat.end_date)
 from wip_resource_actual_times wrat
 where wrat.wip_entity_id = p_wip_entity_id
 and wrat.operation_seq_num = p_operation_seq_num
 and nvl(wrat.resource_seq_num, -1) = nvl(p_resource_seq_num, -1)
 and not exists (select wrat.end_date
                 from wip_resource_actual_times wrat
                 where wrat.wip_entity_id = p_wip_entity_id
                 and wrat.operation_seq_num = p_operation_seq_num
                 and nvl(wrat.resource_seq_num, -1) = nvl(p_resource_seq_num, -1)
                 and wrat.end_date is null
                 and wrat.process_status <> 4)
 and wrat.process_status <> 4;

 --find out if there are any active next resources
 cursor active_next_resource_cursor is select 'Y'
 from wip_resource_actual_times wrat,
      wip_operation_resources wor
 where wrat.wip_entity_id = p_wip_entity_id
 and wrat.operation_seq_num = p_operation_seq_num
 and wrat.status_type = 1
 and wrat.process_status <> 4
 and wrat.end_date is null
 and wor.scheduled_flag = 4
 and wrat.wip_entity_id = wor.wip_entity_id
 and wrat.operation_seq_num = wor.operation_seq_num
 and wrat.resource_id = wor.resource_id;

 cursor max_end_date_wor_cursor is select max(wor.actual_completion_date)
 from wip_operation_resources wor
 where wor.wip_entity_id = p_wip_entity_id
 and wor.operation_seq_num = p_operation_seq_num
 and not exists (select wor.actual_completion_date
                 from wip_operation_resources wor
                 where wor.wip_entity_id = p_wip_entity_id
                 and wor.operation_seq_num = p_operation_seq_num
                 and wor.actual_completion_date is null);
BEGIN
  open max_end_date_wrat_cursor;
  fetch max_end_date_wrat_cursor into l_max_end_date;
  if max_end_date_wrat_cursor%FOUND then
    if l_max_end_date is not null then
      update wip_operation_resources set
      actual_completion_date = l_max_end_date
      where wip_entity_id = p_wip_entity_id
            and operation_seq_num = p_operation_seq_num
            and resource_seq_num = p_resource_seq_num;
    end if;
  end if;
  close max_end_date_wrat_cursor;

  open active_next_resource_cursor;
  fetch active_next_resource_cursor into l_active_next_resource_flag;
  if active_next_resource_cursor%NOTFOUND then
    open max_end_date_wor_cursor;
    fetch max_end_date_wor_cursor into l_max_end_date;
    if max_end_date_wor_cursor%FOUND then
      if l_max_end_date is not null then
        update wip_operations set
        actual_completion_date = l_max_end_date
        where wip_entity_id = p_wip_entity_id
              and operation_seq_num = p_operation_seq_num;
      end if;
    end if;
    close max_end_date_wor_cursor;
  end if;
  close active_next_resource_cursor;
END update_actual_completion_dates;

-- Update the value of projected completion date in wo and wor tables.
PROCEDURE update_proj_completion_dates(p_organization_id IN NUMBER,
                                       p_wip_entity_id IN NUMBER,
                                       p_operation_seq_num IN NUMBER,
                                       p_resource_seq_num IN NUMBER,
                                       p_resource_id IN NUMBER,
                                       p_start_date IN DATE)
IS
 l_projected_completion_date date;
BEGIN
  l_projected_completion_date := wip_ws_util.get_projected_completion_date(p_organization_id => p_organization_id,
                                                                           p_wip_entity_id => p_wip_entity_id,
                                                                           p_op_seq_num => p_operation_seq_num,
                                                                           p_resource_seq_num => p_resource_seq_num,
                                                                           p_resource_id => p_resource_id,
                                                                           p_instance_id => null,
                                                                           p_start_date => p_start_date);
  update wip_operation_resources set
  projected_completion_date = l_projected_completion_date
  where wip_entity_id = p_wip_entity_id
        and operation_seq_num = p_operation_seq_num
        and resource_seq_num = p_resource_seq_num;

  l_projected_completion_date := wip_ws_util.get_projected_completion_date(p_organization_id => p_organization_id,
                                                                           p_wip_entity_id => p_wip_entity_id,
                                                                           p_op_seq_num => p_operation_seq_num,
                                                                           p_resource_seq_num => null,
                                                                           p_resource_id => null,
                                                                           p_instance_id => null,
                                                                           p_start_date => p_start_date);
  update wip_operations set
  projected_completion_date = l_projected_completion_date
  where wip_entity_id = p_wip_entity_id
        and operation_seq_num = p_operation_seq_num;
END update_proj_completion_dates;

-- Get the on/off status of the job.
FUNCTION get_job_on_off_status(p_wip_entity_id IN NUMBER,
                               p_operation_seq_num IN NUMBER) return VARCHAR2
IS
 l_job_status varchar2(1);
 l_employee_id number;

 cursor job_status_cursor is select employee_id
 from wip_operations wo
 where wo.wip_entity_id = p_wip_entity_id
 and wo.operation_seq_num = p_operation_seq_num;
BEGIN
  l_job_status := 'N';

  open job_status_cursor;
  fetch job_status_cursor into l_employee_id;
  if job_status_cursor%FOUND then
    if l_employee_id is not null then
      l_job_status := 'Y';
    end if;
  end if;
  close job_status_cursor;

  return l_job_status;
END get_job_on_off_status;

-- Set job on.
PROCEDURE job_on(p_wip_entity_id IN NUMBER,
                 p_operation_seq_num IN NUMBER,
                 p_employee_id IN NUMBER,
                 x_status out NOCOPY VARCHAR2,
                 x_msg_count out NOCOPY NUMBER,
                 x_msg out NOCOPY VARCHAR2)
IS
 l_job_status varchar2(1);
 l_status varchar2(1);
 l_msg_count number;
 l_msg varchar2(10);
 lx_return_status varchar2(10);
BEGIN
  l_status := 'U';
  l_job_status := get_job_on_off_status(p_wip_entity_id => p_wip_entity_id,
                                        p_operation_seq_num    => p_operation_seq_num);

  if (l_job_status = 'Y') then
    l_status := 'O';
  elsif (l_job_status = 'N') then
    update wip_operations set
    employee_id = p_employee_id
    where wip_entity_id = p_wip_entity_id
          and operation_seq_num = p_operation_seq_num;
    l_status := 'S';
  end if;

  x_status := l_status;
  x_msg_count := l_msg_count;
  x_msg := l_msg;
END job_on;


-- Set job off.
PROCEDURE job_off(p_wip_entity_id IN NUMBER,
                  p_operation_seq_num IN NUMBER,
                  x_status out NOCOPY VARCHAR2,
                  x_msg_count out NOCOPY NUMBER,
                  x_msg out NOCOPY VARCHAR2)
IS
 l_job_status varchar2(1);

 l_status varchar2(1);
 l_msg_count number;
 l_msg varchar2(255);
BEGIN
  l_status := 'U';
  l_job_status := get_job_on_off_status(p_wip_entity_id     => p_wip_entity_id,
                                        p_operation_seq_num => p_operation_seq_num);

  if (l_job_status = 'N') then
    l_status := 'O';
  elsif (l_job_status = 'Y') then

    /* clock out labors */
    clock_out_labors(p_wip_entity_id, p_operation_seq_num, null);

    /* clock out all machines as well */
    clock_out_machines(p_wip_entity_id, p_operation_seq_num);

    /* remove the employee stamp */
    job_off_internal(p_wip_entity_id, p_operation_seq_num);

    /* process the records */
    process_time_records(p_wip_entity_id     => p_wip_entity_id,
                         p_completed_op      => p_operation_seq_num,
                         p_instance_id       => null,
                         p_time_entry_source => 'clock');
    l_status := 'S';
  end if;

  x_status := l_status;
  x_msg_count := l_msg_count;
  x_msg := l_msg;
END job_off;
--emp_valid


PROCEDURE emp_valid(p_wip_employee_id IN NUMBER,
                    p_org_id IN NUMBER,
                    x_status OUT nocopy Boolean,
		    x_person_id OUT nocopy number
		    ) IS

  l_status boolean:=true;
  l_person_id NUMBER := null;
  l_dummy_var NUMBER;

CURSOR emp_valid_cursor IS
       select  bre.person_id
       from   per_all_people_f papf,
       bom_resource_employees bre
       where  papf.person_id = bre.person_id
       and sysdate between papf.effective_start_date and nvl(papf.effective_end_date,sysdate+1)
       and bre.organization_id = p_org_id
       and papf.employee_number = p_wip_employee_id
       and rownum=1;

BEGIN
--if multiple persons are there then it will give one person id

    OPEN emp_valid_cursor;
    FETCH emp_valid_cursor
    INTO l_person_id;

--IF emp_valid_cursor % FOUND THEN
IF (l_person_id is not null) THEN
l_status:=WIP_TIME_ENTRY_PUB.is_emp_invalid(p_org_id,null,null,l_person_id);
end if;

	x_status:=l_status;
	x_person_id:=l_person_id;

EXCEPTION
   WHEN OTHERS
   THEN
        l_person_id := null;

close emp_valid_cursor;
END emp_valid;

-- Set Shift in
PROCEDURE shift_in(p_wip_employee_id IN NUMBER,
                                     p_org_id IN NUMBER,
                                     x_status OUT nocopy VARCHAR2
				    ) IS
    l_shift_status VARCHAR2(1);
    l_dummy_var NUMBER;
    badge_validation Boolean:=FALSE;
    l_person_id  number;
    l_time_entry  number;
    l_ret_status  varchar2(200);

    CURSOR shift_in_cursor IS
    SELECT 1
    FROM wip_resource_actual_times wrat
    WHERE wrat.wip_entity_id IS NULL
     AND wrat.end_date IS NULL
     and wrat.employee_id = l_person_id
     and wrat.time_entry_mode = 8
     and organization_id = p_org_id;


BEGIN

    l_shift_status := 'U';



   emp_valid(p_wip_employee_id =>p_wip_employee_id,
                    p_org_id =>p_org_id,
                    x_status =>badge_validation,
		    x_person_id=>l_person_id
		    );

   OPEN shift_in_cursor;
    FETCH shift_in_cursor
    INTO l_dummy_var;

    IF (badge_validation = true) then
       l_shift_status :='N';
    ELSIF shift_in_cursor % FOUND THEN
      --Already Shifted in
      l_shift_status := 'C';
    ELSE
     --shift in employee for which badge number was entered
     -- removed hardcoding of resource_id for bug 6969269.
     insert into  wip_resource_actual_times
       (TIME_ENTRY_ID,ORGANIZATION_ID,WIP_ENTITY_ID,
        OPERATION_SEQ_NUM,RESOURCE_ID,RESOURCE_SEQ_NUM,
        INSTANCE_ID,SERIAL_NUMBER,TIME_ENTRY_MODE,
        COST_FLAG,ADD_TO_RTG,STATUS_TYPE,START_DATE,
        END_DATE,PROJECTED_COMPLETION_DATE,DURATION,
        UOM_CODE,EMPLOYEE_ID,PROCESS_STATUS,CREATED_BY,
        CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,OBJECT_VERSION_NUMBER,
        ACTION_FLAG,REQUEST_ID,PROGRAM_ID,
        PROGRAM_APPLICATION_ID,PROGRAM_UPDATE_DATE)
     values
       (WIP_RESOURCE_ACTUAL_TIMES_S.nextval,p_org_id,
        null,null,null,null,null,null,8,'N','N',null,
        sysdate,null,null,null,
        fnd_profile.value('BOM:HOUR_UOM_CODE'),
        l_person_id,1,fnd_global.user_id,
        sysdate,fnd_global.user_id,sysdate,
        fnd_global.login_id,1,null,null,null,
        null,null);


    l_shift_status := 'S';
    END IF;

    CLOSE shift_in_cursor;
    x_status := l_shift_status;
END shift_in;

-- Set Shift Out
PROCEDURE shift_out(p_wip_employee_id IN NUMBER,
                     p_org_id IN NUMBER,
                     x_status out NOCOPY VARCHAR2
                    ) is

	   l_shift_status varchar2(1);
	   l_start_date date;
	   l_date date;
           l_duration number;
	   badge_validation Boolean:= false;
	   l_person_id  number;

  cursor shift_out_test_cursor is
    select  start_date
    from wip_resource_actual_times wrat
    where wrat.wip_entity_id is null
    and wrat.EMPLOYEE_ID=l_person_id
    and wrat.ORGANIZATION_ID=p_org_id
    and wrat.end_date is null
    and wrat.time_entry_mode = 8;

  BEGIN
     l_shift_status := 'U';


    emp_valid(p_wip_employee_id =>p_wip_employee_id,
                    p_org_id =>p_org_id,
                    x_status=>badge_validation,
		    x_person_id=>l_person_id
		    );

     open shift_out_test_cursor;
     fetch shift_out_test_cursor into l_start_date;


    IF (badge_validation = true) then
       l_shift_status :='N';
     elsif shift_out_test_cursor%NOTFOUND then
       l_shift_status := 'O';
     else
       l_date := sysdate;
       l_duration := (l_date - l_start_date)*24;

       update wip_resource_actual_times set
          end_date = l_date,
          duration = l_duration
          where ORGANIZATION_ID=p_org_id
                and employee_id =l_person_id
                and end_date is null
	        and wip_entity_id is null;

	       l_shift_status := 'S';
     end if;
     close shift_out_test_cursor;

     x_status := l_shift_status;

    END shift_out;

-- Set Undo Shift In
PROCEDURE undo_shift_in(p_wip_employee_id IN NUMBER,
                     p_org_id IN NUMBER,
                     x_status out NOCOPY VARCHAR2
                    )
   IS
    l_shift_status varchar2(1);
    l_dummy_var number;
    badge_validation Boolean :=false;
    l_person_id  number;

      cursor undo_shift_in_test_cursor is
        select  1
        from wip_resource_actual_times wrat
        where wrat.wip_entity_id is null
	and wrat.EMPLOYEE_ID=l_person_id
	and wrat.ORGANIZATION_ID=p_org_id
	 and wrat.end_date is null;
   BEGIN
     l_shift_status := 'U';

             emp_valid(p_wip_employee_id =>p_wip_employee_id,
                    p_org_id =>p_org_id,
                    x_status=>badge_validation,
		    x_person_id=>l_person_id
		    );

       open undo_shift_in_test_cursor;
       fetch undo_shift_in_test_cursor into l_dummy_var;


      IF (badge_validation = true) then
       l_shift_status :='N';
       elsif undo_shift_in_test_cursor%NOTFOUND then
       l_shift_status := 'O';
       else
       delete from wip_resource_actual_times wrat
       where
       wrat.wip_entity_id is null
       and wrat.EMPLOYEE_ID=l_person_id
       and wrat.ORGANIZATION_ID=p_org_id
       and wrat.end_date is null;
       l_shift_status := 'S';
       end if;
    x_status := l_shift_status;

  END undo_shift_in;
--User mode Shift functionality
PROCEDURE shift_in_UM(p_wip_employee_id IN NUMBER,
                                     p_org_id IN NUMBER,
                                     x_status OUT nocopy VARCHAR2
				    ) IS
    l_shift_status VARCHAR2(1);
    l_dummy_var NUMBER;
    badge_validation Boolean:=FALSE;
    l_person_id  number;
    l_time_entry  number;
    l_ret_status  varchar2(200);

    CURSOR shift_in_cursor IS
    SELECT 1
    FROM wip_resource_actual_times wrat
    WHERE wrat.wip_entity_id IS NULL
     AND wrat.end_date IS NULL
     and wrat.employee_id = p_wip_employee_id
     and wrat.time_entry_mode = 8;


BEGIN

    l_shift_status := 'U';

    badge_validation:=WIP_TIME_ENTRY_PUB.is_emp_invalid(p_org_id,null,null,p_wip_employee_id);

   OPEN shift_in_cursor;
    FETCH shift_in_cursor
    INTO l_dummy_var;

    IF (badge_validation = true) then
       l_shift_status :='N';
    ELSIF shift_in_cursor % FOUND THEN
      --Already Shifted in
      l_shift_status := 'C';
    ELSE
     --shift in employee for which badge number was entered
     -- removed hardcoding of resource_id for bug 6969269.
     insert into  wip_resource_actual_times
       (TIME_ENTRY_ID,ORGANIZATION_ID,WIP_ENTITY_ID,
        OPERATION_SEQ_NUM,RESOURCE_ID,RESOURCE_SEQ_NUM,
        INSTANCE_ID,SERIAL_NUMBER,TIME_ENTRY_MODE,
        COST_FLAG,ADD_TO_RTG,STATUS_TYPE,START_DATE,
        END_DATE,PROJECTED_COMPLETION_DATE,DURATION,
        UOM_CODE,EMPLOYEE_ID,PROCESS_STATUS,CREATED_BY,
        CREATION_DATE,LAST_UPDATED_BY,LAST_UPDATE_DATE,
        LAST_UPDATE_LOGIN,OBJECT_VERSION_NUMBER,
        ACTION_FLAG,REQUEST_ID,PROGRAM_ID,
        PROGRAM_APPLICATION_ID,PROGRAM_UPDATE_DATE)
     values
       (WIP_RESOURCE_ACTUAL_TIMES_S.nextval,p_org_id,
        null,null,null,null,null,null,8,'N','N',null,
        sysdate,null,null,null,
        fnd_profile.value('BOM:HOUR_UOM_CODE'),
        p_wip_employee_id,1,fnd_global.user_id,
        sysdate,fnd_global.user_id,sysdate,
        fnd_global.login_id,1,null,null,null,
        null,null);


    l_shift_status := 'S';
    END IF;

    CLOSE shift_in_cursor;
    x_status := l_shift_status;
END shift_in_UM;

-- Set Shift Out
PROCEDURE shift_out_UM(p_wip_employee_id IN NUMBER,
                     p_org_id IN NUMBER,
                     x_status out NOCOPY VARCHAR2
                    ) is

	   l_shift_status varchar2(1);
	   l_start_date date;
	   l_date date;
           l_duration number;
	   badge_validation Boolean:= false;
	   l_person_id  number;

  cursor shift_out_test_cursor is
   select  start_date
    from wip_resource_actual_times wrat
    where wrat.wip_entity_id is null
	and wrat.EMPLOYEE_ID=p_wip_employee_id
	and wrat.ORGANIZATION_ID=p_org_id
	 and wrat.end_date is null;

  BEGIN
     l_shift_status := 'U';


      badge_validation:=WIP_TIME_ENTRY_PUB.is_emp_invalid(p_org_id,null,null,p_wip_employee_id);

     open shift_out_test_cursor;
     fetch shift_out_test_cursor into l_start_date;


    IF (badge_validation = true) then
       l_shift_status :='N';
     elsif shift_out_test_cursor%NOTFOUND then
       l_shift_status := 'O';
     else
       l_date := sysdate;
       l_duration := (l_date - l_start_date)*24;

       update wip_resource_actual_times set
          end_date = l_date,
          duration = l_duration
          where ORGANIZATION_ID=p_org_id
                and employee_id =p_wip_employee_id
                and end_date is null
	        and wip_entity_id is null;

	       l_shift_status := 'S';
     end if;
     close shift_out_test_cursor;

     x_status := l_shift_status;

    END shift_out_UM;

-- Set Undo Shift In
PROCEDURE undo_shift_in_UM(p_wip_employee_id IN NUMBER,
                     p_org_id IN NUMBER,
                     x_status out NOCOPY VARCHAR2
                    )
   IS
    l_shift_status varchar2(1);
    l_dummy_var number;
    badge_validation Boolean :=false;
    l_person_id  number;

      cursor undo_shift_in_test_cursor is
        select  1
        from wip_resource_actual_times wrat
        where wrat.wip_entity_id is null
	and wrat.EMPLOYEE_ID=p_wip_employee_id
	and wrat.ORGANIZATION_ID=p_org_id
	 and wrat.end_date is null;
   BEGIN
     l_shift_status := 'U';

   badge_validation:=WIP_TIME_ENTRY_PUB.is_emp_invalid(p_org_id,null,null,p_wip_employee_id);

       open undo_shift_in_test_cursor;
       fetch undo_shift_in_test_cursor into l_dummy_var;


      IF (badge_validation = true) then
       l_shift_status :='N';
       elsif undo_shift_in_test_cursor%NOTFOUND then
       l_shift_status := 'O';
       else
       delete from wip_resource_actual_times wrat
       where
       wrat.wip_entity_id is null
       and wrat.EMPLOYEE_ID=p_wip_employee_id
       and wrat.ORGANIZATION_ID=p_org_id
       and wrat.end_date is null;
       l_shift_status := 'S';
       end if;
    x_status := l_shift_status;

  END undo_shift_in_UM;


-- Set clock in.
PROCEDURE clock_in(p_wip_entity_id IN NUMBER,
                   p_operation_seq_num IN NUMBER,
                   p_responsibility_key IN VARCHAR2,
                   p_dept_id IN NUMBER,
                   p_employee_id IN NUMBER,
                   p_instance_id IN NUMBER,
                   p_resource_id IN NUMBER,
                   p_resource_seq_num IN NUMBER,
                   x_status out NOCOPY VARCHAR2,
                   x_msg_count out NOCOPY NUMBER,
                   x_msg out NOCOPY VARCHAR2)
IS
 lx_status varchar2(1);
 lx_msg_count number;
 lx_msg varchar2(255);
 l_clock_status varchar2(1);
 l_dummy_var number;
 l_resource_id number;
 l_resource_seq_num number;
 l_uom_code varchar2(3);
 l_scheduled_flag number;
 lx_organization_id number;
 lx_department_id number;
 lx_time_entry_id number;
 lx_return_status varchar2(10);
 l_num_job_op number;
	l_skill_check number;

 cursor clock_in_cursor is select 1
 from wip_resource_actual_times wrat
 where wrat.wip_entity_id = p_wip_entity_id
 and wrat.operation_seq_num = p_operation_seq_num
 and wrat.resource_id = p_resource_id
 and nvl(wrat.resource_seq_num, -1) = nvl(p_resource_seq_num, -1)
 and wrat.employee_id = p_employee_id
 and wrat.instance_id = p_instance_id
 and wrat.status_type = 1
 and wrat.end_date is null;

 cursor resource_uom_cursor is select unit_of_measure
 from bom_resources br
 where br.resource_id = p_resource_id;

 cursor scheduled_flag_cursor is
 select scheduled_flag
   from wip_operation_resources wor
  where wor.wip_entity_id = p_wip_entity_id
  and wor.operation_seq_num = p_operation_seq_num
  and wor.resource_seq_num = p_resource_seq_num;

 /* check if there is no clock-in in the scheduled flag group */
 cursor num_job_op_cursor(p_scheduled_flag varchar2) is
 select count(*)
  from wip_resource_actual_times wrat, wip_operation_resources wor
 where wrat.wip_entity_id = p_wip_entity_id
   and wrat.operation_seq_num = p_operation_seq_num
   and wrat.wip_entity_id = wor.wip_entity_id (+)
   and wrat.operation_seq_num = wor.operation_seq_num (+)
   and wrat.resource_seq_num = wor.resource_seq_num(+)
   and decode(wor.scheduled_flag, null, 1, 2, 1, wor.scheduled_flag) =
       decode(p_scheduled_flag, null, 1, 2, 1, p_scheduled_flag)
   and wrat.status_type = 1
   and wrat.start_date is not null
   and wrat.end_date is null;

 cursor time_records_machine_cursor(c_scheduled_flag number) is
 select wor.resource_id,
        wor.resource_seq_num,
        wor.uom_code
 from wip_operation_resources wor,
      bom_resources br
 where wor.wip_entity_id = p_wip_entity_id
 and wor.operation_seq_num = p_operation_seq_num
 and decode(wor.scheduled_flag, 2, 1, wor.scheduled_flag) =
     decode(c_scheduled_flag, 2, 1, c_scheduled_flag)
 and br.resource_type = 1 --machine resource
 and wor.resource_id = br.resource_id
 and not exists (select 1
                 from wip_resource_actual_times wrat
                 where wrat.wip_entity_id = p_wip_entity_id
                 and wrat.operation_seq_num = p_operation_seq_num
                 and wrat.resource_id = wor.resource_id
                 and wrat.resource_seq_num = wor.resource_seq_num
                 and wrat.status_type = 1
                 and wrat.end_date is null);
BEGIN
  l_clock_status := 'U';

  if WIP_TIME_ENTRY_PUB.is_emp_shift_in(p_wip_entity_id => p_wip_entity_id,
                                        p_employee_id   => p_employee_id) then

				l_skill_check := WIP_WS_SKILL_CHECK_PVT.validate_skill_for_clock_in(
																																	p_wip_entity_id   => p_wip_entity_id,
																																	p_op_seq_num      => p_operation_seq_num,
																																	p_emp_id          => p_employee_id);

				if l_skill_check = WIP_WS_SKILL_CHECK_PVT.G_SKILL_VALIDATION_SUCCESS then

						open clock_in_cursor;
						fetch clock_in_cursor into l_dummy_var;
						if clock_in_cursor%FOUND then
								l_clock_status := 'C';
						else
								job_on(p_wip_entity_id     => p_wip_entity_id,
															p_operation_seq_num => p_operation_seq_num,
															p_employee_id       => p_employee_id,
															x_status            => lx_status,
															x_msg_count         => lx_msg_count,
															x_msg               => lx_msg);

								get_org_dept_ids(p_wip_entity_id     => p_wip_entity_id,
																									p_operation_seq_num => p_operation_seq_num,
																									x_organization_id   => lx_organization_id,
																									x_department_id     => lx_department_id);

								open resource_uom_cursor;
								fetch resource_uom_cursor into l_uom_code;
								close resource_uom_cursor;

								--clock in employee for which badge number was entered
								record_insert(p_time_entry_id               => null,
																						p_organization_id             => lx_organization_id,
																						p_wip_entity_id               => p_wip_entity_id,
																						p_operation_seq_num           => p_operation_seq_num,
																						p_resource_id                 => p_resource_id,
																						p_resource_seq_num           => p_resource_seq_num,
																						p_instance_id                 => p_instance_id,
																						p_serial_number               => null,
																						p_last_update_date            => null,
																						p_last_updated_by             => null,
																						p_creation_date               => null,
																						p_created_by                  => null,
																						p_last_update_login           => null,
																						p_object_version_num          => null,
																						p_time_entry_mode             => null,
																						p_cost_flag                   => null,
																						p_add_to_rtg                  => null,
																						p_status_type                 => null,
																						p_start_date                  => sysdate,
																						p_end_date                    => null,
																						p_projected_completion_date   => null,
																						p_duration                    => null,
																						p_uom_code                    => l_uom_code,
																						p_employee_id                 => p_employee_id,
																						x_time_entry_id               => lx_time_entry_id,
																						x_return_status               => lx_return_status);
								l_clock_status := 'S';
						end if;
						close clock_in_cursor;

						open scheduled_flag_cursor;
						fetch scheduled_flag_cursor into l_scheduled_flag;
						close scheduled_flag_cursor;

						/* ad-hoc resource don't have a scheduled_flag, treat it as no-scheduled*/
						if(l_scheduled_flag is null) then l_scheduled_flag := 2;  end if;

						open num_job_op_cursor(l_scheduled_flag);
						fetch num_job_op_cursor into l_num_job_op;
						close num_job_op_cursor;

						--this is the first clock in for this job operation
						if (l_num_job_op = 1) then

								open time_records_machine_cursor(l_scheduled_flag);
								loop
										fetch time_records_machine_cursor into l_resource_id,
																																																	l_resource_seq_num,
																																																	l_uom_code;
										exit when time_records_machine_cursor%NOTFOUND;

										--clock in machines that have not already been clocked in
										record_insert(p_time_entry_id              => null,
																								p_organization_id             => lx_organization_id,
																								p_wip_entity_id               => p_wip_entity_id,
																								p_operation_seq_num           => p_operation_seq_num,
																								p_resource_id                 => l_resource_id,
																								p_resource_seq_num           => l_resource_seq_num,
																								p_instance_id                 => null,
																								p_serial_number               => null,
																								p_last_update_date            => null,
																								p_last_updated_by             => null,
																								p_creation_date               => null,
																								p_created_by                  => null,
																								p_last_update_login           => null,
																								p_object_version_num          => null,
																								p_time_entry_mode             => null,
																								p_cost_flag                   => null,
																								p_add_to_rtg                  => null,
																								p_status_type                 => null,
																								p_start_date                  => sysdate,
																								p_end_date                    => null,
																								p_projected_completion_date   => null,
																								p_duration                    => null,
																								p_uom_code                    => l_uom_code,
																								p_employee_id                 => p_employee_id,
																								x_time_entry_id               => lx_time_entry_id,
																								x_return_status               => lx_return_status);
								end loop;
						close time_records_machine_cursor;
						end if;

						process_time_records(p_wip_entity_id     => p_wip_entity_id,
																											p_completed_op      => p_operation_seq_num,
																											p_instance_id       => null,
																											p_time_entry_source => 'clock');


						x_status := l_clock_status;

		  elsif l_skill_check = WIP_WS_SKILL_CHECK_PVT.G_COMPETENCE_CHECK_FAIL then
      	x_status := 'P';
				elsif l_skill_check = WIP_WS_SKILL_CHECK_PVT.G_CERTIFY_CHECK_FAIL then
      	x_status := 'Q';
				elsif l_skill_check = WIP_WS_SKILL_CHECK_PVT.G_QUALIFY_CHECK_FAIL then
      	x_status := 'R';
    elsif l_skill_check = WIP_WS_SKILL_CHECK_PVT.G_SKILL_VALIDATION_EXCEPTION then
				   x_status := 'U';
				end if;
		else
    x_status := 'H';
  end if;
END clock_in;

-- Set clock out.
PROCEDURE clock_out(p_wip_entity_id IN NUMBER,
                    p_operation_seq_num IN NUMBER,
                    p_responsibility_key IN VARCHAR2,
                    p_dept_id IN NUMBER,
                    p_employee_id IN NUMBER,
                    p_instance_id IN NUMBER,
                    p_resource_id IN NUMBER,
                    p_resource_seq_num IN NUMBER,
                    x_status out NOCOPY VARCHAR2,
                    x_msg_count out NOCOPY NUMBER,
                    x_msg out NOCOPY VARCHAR2)
IS
 l_clock_status varchar2(1);
 l_process_status number;
 l_object_version_num number;
 l_last_op_qty_num number;
 l_last_job_qty_num number;
 l_last_op_qty varchar2(1);
 l_last_job_qty varchar2(1);
 l_start_date date;
 l_date date;
 l_duration number;
 l_uom_code varchar2(3);

 cursor clock_out_test_cursor is
 select object_version_number,
        start_date
 from wip_resource_actual_times
 where wip_entity_id = p_wip_entity_id
     and operation_seq_num = p_operation_seq_num
     and resource_id = p_resource_id
   /*  and nvl(resource_seq_num, -1) = nvl(p_resource_seq_num, -1) BUG 7322174*/
     and employee_id = p_employee_id
     and instance_id = p_instance_id
     and status_type = 1
     and end_date is null;
BEGIN
   l_clock_status := 'U';
   l_process_status := 3;  --updated
   l_uom_code := fnd_profile.value('BOM:HOUR_UOM_CODE');

   open clock_out_test_cursor;
   fetch clock_out_test_cursor into l_object_version_num,
                                    l_start_date;
   if clock_out_test_cursor%NOTFOUND then
     l_clock_status := 'O';
   else
     l_date := sysdate;
     l_duration := (l_date - l_start_date)*24;
     update wip_resource_actual_times set
        end_date = l_date,
        duration = l_duration,
        uom_code = l_uom_code,
        process_status = l_process_status,
        object_version_number = l_object_version_num + 1,
        last_update_date = l_date,
        last_updated_by = fnd_global.user_id,
        last_update_login = fnd_global.login_id
        where wip_entity_id = p_wip_entity_id
        and operation_seq_num = p_operation_seq_num
        and resource_id = p_resource_id
        and nvl(resource_seq_num, -1) = nvl(p_resource_seq_num, -1)
        and employee_id = p_employee_id
        and instance_id = p_instance_id
        and status_type = 1
        and end_date is null;

     process_time_records(p_wip_entity_id     => p_wip_entity_id,
                          p_completed_op      => p_operation_seq_num,
                          p_instance_id       => null,
                          p_time_entry_source => 'clock');

     l_clock_status := 'S';
   end if;
   close clock_out_test_cursor;
   /* Added for bug 6891758.*/
   if G_RES_CHG_FAILED =wip_constants.yes then
     l_clock_status := 'T';
   end if;
   x_status := l_clock_status;
END clock_out;

-- Set undo clock in.
PROCEDURE undo_clock_in(p_wip_entity_id IN NUMBER,
                        p_operation_seq_num IN NUMBER,
                        p_responsibility_key IN VARCHAR2,
                        p_dept_id IN NUMBER,
                        p_employee_id IN NUMBER,
                        p_instance_id IN NUMBER,
                        p_resource_id IN NUMBER,
                        p_resource_seq_num IN NUMBER,
                        x_status out NOCOPY VARCHAR2,
                        x_msg_count out NOCOPY NUMBER,
                        x_msg out NOCOPY VARCHAR2)
IS
 l_clock_status varchar2(1);
 lx_return_status varchar2(10);
BEGIN
  l_clock_status := 'U';
  record_delete(p_wip_entity_id       => p_wip_entity_id,
                p_operation_seq_num   => p_operation_seq_num,
                p_employee_id         => p_employee_id,
                x_return_status       => lx_return_status);

  if (lx_return_status = 'S') then
    process_time_records(p_wip_entity_id     => p_wip_entity_id,
                         p_completed_op      => p_operation_seq_num,
                         p_instance_id       => null,
                         p_time_entry_source => 'clock');
    l_clock_status := 'S';
  elsif (lx_return_status = 'U') then
    l_clock_status := 'E';
  end if;
  x_status := l_clock_status;
END undo_clock_in;

-- Get last operation quantity.
FUNCTION get_last_op_qty(p_wip_entity_id IN NUMBER,
                         p_operation_seq_num IN NUMBER) return NUMBER
IS
 l_last_op_qty number;

 cursor last_op_qty_cursor is
 select (wo.quantity_in_queue + wo.quantity_running)
 from wip_operations wo
 where wo.wip_entity_id = p_wip_entity_id
       and wo.operation_seq_num = p_operation_seq_num;
BEGIN
  open last_op_qty_cursor;
  fetch last_op_qty_cursor into l_last_op_qty;
  close last_op_qty_cursor;
  return l_last_op_qty;
END get_last_op_qty;

-- Get last job quantity.
FUNCTION get_last_job_qty(p_wip_entity_id IN NUMBER,
                         p_operation_seq_num IN NUMBER) return NUMBER
IS
 l_last_job_qty number;

 cursor last_job_qty_cursor is
 select (wo.scheduled_quantity - wo.quantity_completed - nvl(wo.cumulative_scrap_quantity, 0))
 from wip_operations wo
 where wo.wip_entity_id = p_wip_entity_id
       and wo.operation_seq_num = p_operation_seq_num;
BEGIN
  open last_job_qty_cursor;
  fetch last_job_qty_cursor into l_last_job_qty;
  close last_job_qty_cursor;
  return l_last_job_qty;
END get_last_job_qty;

-- Get the instance id.
FUNCTION get_instance_id(p_org_id IN NUMBER,
                         p_employee_id IN NUMBER) return NUMBER
IS
 l_instance_id number;

 cursor instance_id_cursor is
 select instance_id
 from bom_resource_employees bre
 where organization_id = p_org_id
 and person_id = p_employee_id;
BEGIN
  open instance_id_cursor;
  fetch instance_id_cursor into l_instance_id;
  close instance_id_cursor;

  return l_instance_id;
END get_instance_id;

-- Check pending clockouts.
FUNCTION is_clock_pending(p_wip_entity_id IN NUMBER,
                          p_operation_seq_num IN NUMBER) return VARCHAR2
IS
 l_status varchar2(1);
 l_dummy_var varchar2(1);

 cursor pending_clockout_cursor is
 select count(*)
 from wip_resource_actual_times
 where wip_entity_id = p_wip_entity_id
     and operation_seq_num = nvl(p_operation_seq_num, operation_seq_num)
     and status_type = 1
     and start_date is not null
     and end_date is null;
BEGIN
  l_status := 'U';

  open pending_clockout_cursor;
  fetch pending_clockout_cursor into l_dummy_var;
  if l_dummy_var > 0 then
    l_status := 'Y';
  else
    l_status := 'N';
  end if;
  close pending_clockout_cursor;

  return l_status;
END is_clock_pending;

/* To Check if there are any pending clock-outs for an employee */
FUNCTION is_emp_clock_out_pending(p_employee_number IN NUMBER,
                                  p_organization_id IN NUMBER,
                                  p_user_mode IN VARCHAR2) return NUMBER
IS
  l_emp_clock_ins Number := 0;
  l_person_id Number;
  badge_validation boolean := true;

BEGIN

  /* Get person_id from badge entered for multi user mode.
     For single user mode, person_id itself is passed. */

  if p_user_mode = 'M' then
    emp_valid(p_wip_employee_id => p_employee_number,
              p_org_id          => p_organization_id,
              x_status          => badge_validation,
              x_person_id       => l_person_id);
  else
    l_person_id := p_employee_number;
    badge_validation := false;
  end if;

  /* For Invalid badge we can skip this validation since Shift-Out will fail.*/

  if not badge_validation then
    select count(1)
    into l_emp_clock_ins
    from dual
    where exists( select wip_entity_id
                  from wip_resource_actual_times
                  where organization_id = p_organization_id
                  and employee_id = l_person_id
                  and end_date is null
                  and wip_entity_id is not null );
  end if;

  return l_emp_clock_ins;

END is_emp_clock_out_pending;

END WIP_WS_TIME_ENTRY;

/
