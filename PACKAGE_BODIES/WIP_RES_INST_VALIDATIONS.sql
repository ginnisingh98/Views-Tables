--------------------------------------------------------
--  DDL for Package Body WIP_RES_INST_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_RES_INST_VALIDATIONS" AS
/* $Header: wiprivdb.pls 120.4.12000000.2 2007/03/08 21:36:30 ntangjee ship $ */

function IS_Error(p_group_id            number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number,
                        p_operation_seq_num     number,
                        p_resource_seq_num      number) return number IS

x_count number := 0;

BEGIN

        SELECT count(*)
          INTO x_count
          FROM WIP_JOB_DTLS_INTERFACE
         WHERE group_id         = p_group_id
           AND process_status   = WIP_CONSTANTS.ERROR
           AND wip_entity_id    = p_wip_entity_id
           AND organization_id  = p_organization_id
           AND load_type        = WIP_JOB_DETAILS.WIP_RES_INSTANCE
           AND substitution_type= p_substitution_type
           AND operation_seq_num= p_operation_seq_num
           AND resource_seq_num = p_resource_seq_num;


        IF x_count <> 0 THEN
           return 1;
        ELSE return 0;
        END IF;

END IS_Error;

Procedure Valid_Dates(p_group_id         number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number,
                        p_operation_seq_num     number,
                        p_resource_seq_num      number,
                        p_instance_id           number,
                        p_resource_type         number) IS

  cursor c_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type = wip_job_details.wip_res_instance
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num /* fix for bug4238691 */
       and wjdi.substitution_type in
                   (wip_job_details.wip_add, wip_job_details.wip_change)
       and (wjdi.start_date > wjdi.completion_date
            or exists
                (select 1
                 from wip_operation_resources wor
                 where wor.wip_entity_id = p_wip_entity_id
                   and wor.organization_id = p_organization_id
                   and wor.operation_seq_num = p_operation_seq_num
                   and wor.resource_seq_num = p_resource_seq_num
                   and (wor.start_date > wjdi.start_date
                        or wor.completion_date < wjdi.completion_date))
           or (p_resource_type = 2 and
               exists (select 1
                      from bom_resource_employees brem
                      where brem.organization_id = p_organization_id
                        and brem.instance_id = p_instance_id
                        and (brem.effective_start_date > wjdi.start_date
                            or brem.effective_end_date < wjdi.completion_date))));

  l_error_exists boolean := false;
begin

  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_JDI_RI_INVALID_DATES');
    fnd_message.set_token('INTERFACE', to_char(l_inv_row.interface_id));
    if(wip_job_details.std_alone = 1) then
      wip_interface_err_Utils.add_error(p_interface_id => l_inv_row.interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
    else
      wip_interface_err_Utils.add_error(p_interface_id => wip_jsi_utils.current_interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
    end if;
  end loop;

  if(l_error_exists) then
    update wip_job_dtls_interface wjdi
       set process_status = wip_constants.error
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type = wip_job_details.wip_res_instance
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.substitution_type in
                   (wip_job_details.wip_add, wip_job_details.wip_change)
       and (wjdi.start_date > wjdi.completion_date
            or exists
                (select 1
                 from wip_operation_resources wor
                 where wor.wip_entity_id = p_wip_entity_id
                   and wor.organization_id = p_organization_id
                   and wor.operation_seq_num = p_operation_seq_num
                   and wor.resource_seq_num = p_resource_seq_num
                   and (wor.start_date > wjdi.start_date
                        or wor.completion_date < wjdi.completion_date))
           or (p_resource_type = 2 and
               exists (select 1
                      from bom_resource_employees brem
                      where brem.organization_id = p_organization_id
                        and brem.instance_id = p_instance_id
                        and (brem.effective_start_date > wjdi.start_date
                            or brem.effective_end_date < wjdi.completion_date))));

  end if;
end Valid_Dates;


/* resource_seq_num, instance_id must not be null when add/change/delete
   resource instance */
Procedure ResInst_Info_Exist(p_group_id         number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number,
                        p_operation_seq_num     number,
			p_resource_seq_num      number,
		        p_resource_instance_id  number,
                        p_resource_type         number) IS

  cursor c_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type = wip_job_details.wip_res_instance
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and wjdi.resource_instance_id = p_resource_instance_id
       and (   wjdi.resource_seq_num is null
            or (wjdi.substitution_type <> wip_job_details.wip_delete
                and wjdi.resource_instance_id is null)
            or (wjdi.substitution_type = wip_job_details.wip_add
                and wjdi.resource_serial_number is null
                and p_resource_type = 1 ));

  l_error_exists boolean := false;
begin

  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_JDI_RES_INST_INFO_MISSING');
    fnd_message.set_token('INTERFACE', to_char(l_inv_row.interface_id));
    if(wip_job_details.std_alone = 1) then
      wip_interface_err_Utils.add_error(p_interface_id => l_inv_row.interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
    else
      wip_interface_err_Utils.add_error(p_interface_id => wip_jsi_utils.current_interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
    end if;
  end loop;

  if(l_error_exists) then
    update wip_job_dtls_interface wjdi
       set process_status = wip_constants.error
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type = wip_job_details.wip_res_instance
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and (   wjdi.resource_seq_num is null
            or (wjdi.substitution_type <> wip_job_details.wip_delete
                and wjdi.resource_instance_id is null)
            or (wjdi.substitution_type = wip_job_details.wip_add
                and wjdi.resource_serial_number is null
                and p_resource_type = 1 ));
  end if;
end resinst_info_exist;

Procedure Valid_Resource_Instance(p_group_id             number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number,
                        p_operation_seq_num     number,
                        p_resource_seq_num      number,
                        p_resource_instance_id       number ) IS


  cursor c_invalid_rows(p_dept_id number, p_resource_id number) is
    select interface_id
      from wip_job_dtls_interface wjdi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type = wip_job_details.wip_res_instance
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and wjdi.resource_instance_id = p_resource_instance_id
       and wjdi.resource_instance_id not in (
            select instance_id
            from bom_dept_res_instances
            where resource_id=p_resource_id and department_id=p_dept_id);

  l_error_exists boolean := false;
  l_dept_id number;
  l_resource_id number;
begin

  select wo.department_id, wor.resource_id
    into l_dept_id, l_resource_id
  from wip_operations wo, wip_operation_resources wor
  where wo.wip_entity_id = p_wip_entity_id
    and wo.operation_seq_num = p_operation_seq_num
    and wo.organization_id = p_organization_id
    and wo.repetitive_schedule_id is null
    and wor.wip_entity_id = p_wip_entity_id
    and wor.operation_seq_num = p_operation_seq_num
    and wor.resource_seq_num = p_resource_seq_num
    and wor.organization_id = p_organization_id
    and wor.repetitive_schedule_id is null;

  -- Validate when adding resource instances
  -- resources instances to be added must exist in department of the operation
  -- and in the resource being added to
  for l_inv_row in c_invalid_rows(l_dept_id, l_resource_id) loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_JDI_INVALID_RES_INST_ID');
    fnd_message.set_token('INTERFACE', to_char(l_inv_row.interface_id));
    if(wip_job_details.std_alone = 1) then
      wip_interface_err_Utils.add_error(p_interface_id => l_inv_row.interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
    else
      wip_interface_err_Utils.add_error(p_interface_id => wip_jsi_utils.current_interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
    end if;
  end loop;
  if(l_error_exists) then
    update wip_job_dtls_interface wjdi
       set process_status = wip_constants.error
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type in (wip_job_details.wip_res_instance, wjdi.load_type)
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and wjdi.resource_instance_id = p_resource_instance_id
       and wjdi.resource_instance_id not in (
            select instance_id
            from bom_dept_res_instances
            where resource_id=l_resource_id and department_id=l_dept_id);
  end if;

end valid_resource_instance;


Procedure Valid_Serial_Number(p_group_id             number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number,
                        p_operation_seq_num     number,
                        p_resource_seq_num      number,
                        p_resource_instance_id  number,
			p_resource_serial_number varchar2 ) IS


  cursor c_invalid_rows(p_dept_id number, p_resource_id number) is
    select interface_id
      from wip_job_dtls_interface wjdi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type = wip_job_details.wip_res_instance
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and wjdi.resource_instance_id = p_resource_instance_id
       and p_resource_id in (select resource_id
                               from bom_resources
			      where resource_type = 1) /* machine type resource */
       and p_resource_serial_number not in(
		select bdri.serial_number
		from bom_resource_equipments breq,
		bom_dept_res_instances_eqp_v bdri,
		mtl_system_items_kfv msik,
		bom_department_resources bdr
		where  bdr.resource_id = p_resource_id
		and    bdr.department_id = p_dept_id
		and    bdri.resource_id = bdr.resource_id
		and    bdri.department_id = nvl(bdr.share_from_dept_id, bdr.department_id)
		and    breq.organization_id = p_organization_id
		and    breq.instance_id = bdri.instance_id
		and    breq.resource_id = bdri.resource_id
		and    msik.inventory_item_id = breq.inventory_item_id
		and    msik.organization_id = breq.organization_id);

  l_error_exists boolean := false;
  l_dept_id number;
  l_resource_id number;
begin
  select wo.department_id, wor.resource_id
    into l_dept_id, l_resource_id
  from wip_operations wo, wip_operation_resources wor
  where wo.wip_entity_id = p_wip_entity_id
    and wo.operation_seq_num = p_operation_seq_num
    and wo.organization_id = p_organization_id
    and wo.repetitive_schedule_id is null
    and wor.wip_entity_id = p_wip_entity_id
    and wor.operation_seq_num = p_operation_seq_num
    and wor.resource_seq_num = p_resource_seq_num
    and wor.organization_id = p_organization_id
    and wor.repetitive_schedule_id is null;

  -- Validate when adding resource instances for machine type resources
  -- serial numbers to be added must exist in department of the operation
  -- and in the resource being added to
  for l_inv_row in c_invalid_rows(l_dept_id, l_resource_id) loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_JDI_INVALID_INST_SERIAL');
   fnd_message.set_token('INTERFACE', to_char(l_inv_row.interface_id));
    if(wip_job_details.std_alone = 1) then
      wip_interface_err_Utils.add_error(p_interface_id => l_inv_row.interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
    else
      wip_interface_err_Utils.add_error(p_interface_id => wip_jsi_utils.current_interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
    end if;
  end loop;
  if(l_error_exists) then

     update wip_job_dtls_interface wjdi
       set process_status = wip_constants.error
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type in (wip_job_details.wip_res_instance, wjdi.load_type)
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and wjdi.resource_instance_id = p_resource_instance_id
       and l_resource_id in (select resource_id
                               from bom_resources
			      where resource_type = 1) /* machine type resource */
       and p_resource_serial_number not in(
		select bdri.serial_number
		from bom_resource_equipments breq,
		bom_dept_res_instances_eqp_v bdri,
		mtl_system_items_kfv msik,
		bom_department_resources bdr
		where  bdr.resource_id = l_resource_id
		and    bdr.department_id = l_dept_id
		and    bdri.resource_id = bdr.resource_id
		and    bdri.department_id = nvl(bdr.share_from_dept_id, bdr.department_id)
		and    breq.organization_id = p_organization_id
		and    breq.instance_id = bdri.instance_id
		and    breq.resource_id = bdri.resource_id
		and    msik.inventory_item_id = breq.inventory_item_id
		and    msik.organization_id = breq.organization_id);

  end if;

end valid_serial_number;

/* check for instances added matches assigned units, it must be either
   equal to number of resource instances unless if no resource instance is defined
*/
Procedure Match_Assigned_Units(p_group_id        number,
                   p_wip_entity_id              number,
                   p_organization_id            number,
                   p_operation_seq_num          number,
                   p_resource_seq_num           number) IS

  l_error_exists boolean := false;
  l_count number;
  l_assigned_units number;

  cursor c_invalid_rows(p_count number, p_assigned_units number) is
    select interface_id
      from wip_job_dtls_interface wjdi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type = wip_job_details.wip_res_instance
       and wjdi.substitution_type = wip_job_details.wip_add
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and p_count <> p_assigned_units;

l_ret_status varchar2(10);
-- Added for bug fix 5132582
l_add_count  Number;
l_del_count  Number;
l_loglevel   Number := to_number(fnd_log.g_current_runtime_level);
l_retStatus  Varchar2(1);
l_source_code VARCHAR2(30); -- Added for Fix #5752548
BEGIN
  l_count := 0;

  begin
     select assigned_units into l_assigned_units
                from wip_operation_resources
                where wip_entity_id = p_wip_entity_id
                  and organization_id = p_organization_id
                  and operation_seq_num = p_operation_seq_num
                  and resource_seq_num = p_resource_seq_num;
  exception
    when no_data_found then
       l_assigned_units := -1;
  end;

 -- Fix bug 5472387.
 -- The logic to check for assigned units is as follows.
 -- Get the assigned units value from wip_operation_resources. This
 -- will be the benchmark against which we check for the total resource
 -- instance number.
 -- Get currently added resource instances from wip_op_resource_instances table.
 -- Get the number of resource instances being added in the current run and add it
 -- to the above number.
 -- Get the number of resource instances being deleted in the current run and subtract it
 -- from the above number.
 -- Now, this number should be equal to the assigned_units value we got from the first step.

 -- Fix bug #5752548:
 -- Since ASCP will always insert entire instance data, massload program deletes
 -- all existing resource instances in wip_op_resource_instances before adding
 -- new instances inserted by ASCP. Hence, the existing instances should not be
 -- counted when validating assigned units.

  l_source_code := '';

  begin
    select source_code into l_source_code
      from wip_job_schedule_interface
        where wip_entity_id = p_wip_entity_id
          and organization_id = p_organization_id
          and group_id = p_group_id;
  exception
    when no_data_found then
       l_source_code := '';
  end;

  if (l_source_code = 'MSC') then
    l_count := 0;
  else
    Begin
         select count(*) into l_count
                  from wip_op_resource_instances
                  where wip_entity_id = p_wip_entity_id
                    and organization_id = p_organization_id
                    and operation_seq_num = p_operation_seq_num
                    and resource_seq_num = p_resource_seq_num;
    Exception
        when no_data_found then
          l_count := 0;
    End;
  end if;

  -- end of bug fix #5752548

  Begin
     select count(*)
     into   l_add_count
     from   wip_job_dtls_interface
     where  group_id          = p_group_id
     and    wip_entity_id     = p_wip_entity_id
     and    organization_id   = p_organization_id
     and    load_type         = wip_job_details.wip_res_instance
     and    substitution_type = wip_job_details.wip_add
     and    operation_seq_num = p_operation_seq_num
     and    resource_seq_num  = p_resource_seq_num;
  Exception when no_data_found then
     l_add_count := 0;
  End;

  Begin
     select count(*)
     into   l_del_count
     from   wip_job_dtls_interface
     where  group_id          = p_group_id
     and    wip_entity_id     = p_wip_entity_id
     and    organization_id   = p_organization_id
     and    load_type         = wip_job_details.wip_res_instance
     and    substitution_type = wip_job_details.wip_delete
     and    operation_seq_num = p_operation_seq_num
     and    resource_seq_num  = p_resource_seq_num;
  Exception when no_data_found then
     l_del_count := 0;
  End;


  if ( l_logLevel <= wip_constants.full_logging ) then
      wip_logger.log('Number of current units       = ' ||to_char(l_count), l_retStatus);
      wip_logger.log('Number of units to be added   = ' ||to_char(l_add_count), l_retStatus);
      wip_logger.log('Number of units to be deleted = ' ||to_char(l_del_count), l_retStatus);
  end if;
 l_count := l_count + l_add_count - l_del_count;

 -- End of bug fix 5132582

  for l_inv_row in c_invalid_rows(l_count, l_assigned_units) loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_ASSIGNED_UNITS_ERROR');
    if(wip_job_details.std_alone = 1) then
      wip_interface_err_Utils.add_error(p_interface_id => l_inv_row.interface_id,
                                        p_text         => to_char(l_inv_row.interface_id)
                                              || ':' || substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
    else
      wip_interface_err_Utils.add_error(p_interface_id => wip_jsi_utils.current_interface_id,
                                        p_text         => to_char(l_inv_row.interface_id)
                                              || ':' || substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
    end if;
  end loop;
    if(l_error_exists) then
      update wip_job_dtls_interface wjdi
         set process_status = wip_constants.error
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type = wip_job_details.wip_res_instance
       and wjdi.substitution_type = wip_job_details.wip_add
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and l_count <> l_assigned_units;
    end if;
END Match_Assigned_Units;

Procedure Add_Resource_Instance(p_group_id               number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number,
                        p_err_code   out NOCOPY     varchar2,
                        p_err_msg    out NOCOPY     varchar2) IS

x_err_code      varchar2(30) := null;
x_err_msg       varchar2(240) := NULL;

   CURSOR res_info (p_group_id          number,
                   p_wip_entity_id      number,
                   p_organization_id    number,
                   p_substitution_type  number) IS
   SELECT distinct operation_seq_num,
          resource_seq_num, resource_id_old, resource_id_new,
          resource_instance_id, usage_rate_or_amount,
          last_update_date, last_updated_by, creation_date, created_by,
          last_update_login, request_id, program_application_id,
          program_id, program_update_date, resource_serial_number,
          scheduled_flag, assigned_units, applied_resource_units,
          applied_resource_value, uom_code, basis_type,
          activity_id, autocharge_type, standard_rate_flag,
          start_date, completion_date,attribute_category, attribute1,
          attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,
          attribute8,attribute9,attribute10,attribute11,attribute12,
          attribute13,attribute14,attribute15, schedule_seq_num,
          substitute_group_num, replacement_group_num, parent_seq_num, rowid
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_RES_INSTANCE
      AND substitution_type = p_substitution_type;

  l_resource_type number;
  l_return_status   varchar2(100);

BEGIN

    FOR cur_row IN res_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id,
                           p_substitution_type) LOOP

      WIP_RES_INST_DEFAULT.Default_Res_Instance(p_group_id,
                                                  p_wip_entity_id,
                                                  p_organization_id,
                                                  p_substitution_type,
                                                  cur_row.operation_seq_num,
                                                  cur_row.resource_seq_num,
						  cur_row.resource_id_new,
                                                  cur_row.resource_instance_id,
                                                  cur_row.parent_seq_num,
                                                  cur_row.rowid,
                                                  x_err_code,
                                                  x_err_msg);

      begin
        select br.resource_type
        into l_resource_type
        from bom_resources br, wip_operation_resources wor
        where wor.wip_entity_id = p_wip_entity_id
          and wor.organization_id = p_organization_id
          and wor.operation_seq_num = cur_row.operation_seq_num
          and wor.resource_seq_num = cur_row.resource_seq_num
          and br.resource_id = wor.resource_id;
      exception
        when others then
          l_resource_type := null;
      end;


      ResInst_Info_Exist(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
		   cur_row.resource_seq_num,
		   cur_row.resource_instance_id,
                   l_resource_type);


      IF IS_Error(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num)= 0 THEN

        Valid_Dates(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num,
                   cur_row.resource_instance_id,
                   l_resource_type);


        IF IS_Error(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num)= 0 THEN

          Valid_Resource_Instance(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num,
                   cur_row.resource_instance_id);

	IF (IS_Error(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num)= 0
	    AND l_resource_type = 1) THEN
	/* validate serial number for machine type resource instances */
          Valid_Serial_number(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num,
                   cur_row.resource_instance_id,
		   cur_row.resource_serial_number);

        End if;

	-- Fixed for bug 5132582
	-- The match_assigned_units call was inide the if condition of above Valid_Serial_number api
	-- but Valid_Serial_number is called only for meachine resource type
	-- We should call match assigned units call for both machine and employee resource
	-- Hence I have brought this API out of the above if condition

          IF IS_Error(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num)= 0 THEN

             Match_Assigned_Units(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num);

          End If;
      End If;
    End If;

    END LOOP;

exception
        when others then
             p_err_msg := 'wiprivdb, Add_Resource_Instance: ' || SQLERRM;
             p_err_code := SQLCODE;

END Add_Resource_Instance;

/* operations, resources, etc all match and exist */
procedure Res_Instance_Job_Match (p_group_id             number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number,
                        p_operation_seq_num     number,
                        p_resource_seq_num      number,
                        p_instance_id           number) IS

  -- Job/op_seq_num/resource_seq_num/resource_id all match
  -- Validate only when delete/change resources
  cursor c_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type = wip_job_details.wip_res_instance
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and wjdi.resource_instance_id= p_instance_id
       and not exists (select 1
                         from wip_op_resource_instances wori
                        where wori.wip_entity_id = wjdi.wip_entity_id
                          and wori.organization_id = wjdi.organization_id
                          and wori.operation_seq_num = wjdi.operation_seq_num
                          and wori.resource_seq_num = wjdi.resource_seq_num
                          and wori.instance_id = wjdi.resource_instance_id
                      );

  l_error_exists boolean := false;
begin

  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_JDI_RES_INST_NOT_IN_JOB');
    fnd_message.set_token('INTERFACE', to_char(l_inv_row.interface_id));
    if(wip_job_details.std_alone = 1) then
      wip_interface_err_Utils.add_error(p_interface_id => l_inv_row.interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
    else
      wip_interface_err_Utils.add_error(p_interface_id => wip_jsi_utils.current_interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
    end if;
  end loop;

  if(l_error_exists) then
    update wip_job_dtls_interface wjdi
       set process_status = wip_constants.error
     where group_id = p_group_id
       and process_phase = wip_constants.ml_validation
       and process_status in (wip_constants.running,
                              wip_constants.warning)
       and wip_entity_id = p_wip_entity_id
       and organization_id = p_organization_id
       and wjdi.load_type in (wip_job_details.wip_res_instance)
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and wjdi.resource_instance_id= p_instance_id
       and not exists (select 1
                         from wip_op_resource_instances wori
                        where wori.wip_entity_id = wjdi.wip_entity_id
                          and wori.organization_id = wjdi.organization_id
                          and wori.operation_seq_num = wjdi.operation_seq_num
                          and wori.resource_seq_num = wjdi.resource_seq_num
                          and wori.instance_id = wjdi.resource_instance_id
                      );

  end if;
end Res_Instance_Job_Match;

Procedure Change_Resource_Instance(p_group_id               number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number,
                        p_err_code   out NOCOPY     varchar2,
                        p_err_msg    out NOCOPY     varchar2) IS

x_err_code      varchar2(30) := null;
x_err_msg       varchar2(240) := NULL;

   CURSOR res_info (p_group_id          number,
                   p_wip_entity_id      number,
                   p_organization_id    number,
                   p_substitution_type  number) IS
   SELECT distinct operation_seq_num,
          resource_seq_num, resource_id_old, resource_id_new,
          resource_instance_id, usage_rate_or_amount,
          last_update_date, last_updated_by, creation_date, created_by,
          last_update_login, request_id, program_application_id,
          program_id, program_update_date,
          scheduled_flag, assigned_units, applied_resource_units,
          applied_resource_value, uom_code, basis_type,
          activity_id, autocharge_type, standard_rate_flag,
          start_date, completion_date,attribute_category, attribute1,
          attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,
          attribute8,attribute9,attribute10,attribute11,attribute12,
          attribute13,attribute14,attribute15, schedule_seq_num,
          substitute_group_num, replacement_group_num
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_RES_INSTANCE
      AND substitution_type = p_substitution_type;

  l_resource_type number;

BEGIN

    FOR cur_row IN res_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id,
                           p_substitution_type) LOOP

      begin
        select br.resource_type
        into l_resource_type
        from bom_resources br, wip_operation_resources wor
        where wor.wip_entity_id = p_wip_entity_id
          and wor.organization_id = p_organization_id
          and wor.operation_seq_num = cur_row.operation_seq_num
          and wor.resource_seq_num = cur_row.resource_seq_num
          and br.resource_id = wor.resource_id;
      exception
        when others then
          l_resource_type := null;
      end;

      ResInst_Info_Exist(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
		   cur_row.resource_seq_num,
		   cur_row.resource_instance_id,
                   l_resource_type);

      IF IS_Error(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num)= 0 THEN

         Valid_Dates(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num,
                   cur_row.resource_instance_id,
                   l_resource_type);

         IF IS_Error(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num)= 0 THEN

           -- Bug 5454843: when change resource instance,
           --              do not call Res_Instance_Job_Match()
           Valid_Resource_Instance(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num,
                   cur_row.resource_instance_id);

           IF IS_Error(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num)= 0 THEN

             update wip_op_resource_instances wori
             set wori.instance_id = cur_row.resource_instance_id
             where wori.wip_entity_id = p_wip_entity_id
               and wori.organization_id = p_organization_id
               and wori.operation_seq_num = cur_row.operation_seq_num
               and wori.resource_seq_num = cur_row.resource_seq_num;

           End If;

        End If;
      End If;

    END LOOP;

exception
        when others then
             p_err_msg := 'wiprivdb, Change_Resource_Instance: ' || SQLERRM;
             p_err_code := SQLCODE;

END Change_Resource_Instance;


Procedure Delete_Resource_Instance(p_group_id               number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number,
                        p_err_code   out NOCOPY     varchar2,
                        p_err_msg    out NOCOPY     varchar2) IS

x_err_code      varchar2(30) := null;
x_err_msg       varchar2(240) := NULL;

   CURSOR res_info (p_group_id          number,
                   p_wip_entity_id      number,
                   p_organization_id    number,
                   p_substitution_type  number) IS
   SELECT distinct operation_seq_num,
          resource_seq_num, resource_id_old, resource_id_new,
          resource_instance_id, usage_rate_or_amount,
          last_update_date, last_updated_by, creation_date, created_by,
          last_update_login, request_id, program_application_id,
          program_id, program_update_date,
          scheduled_flag, assigned_units, applied_resource_units,
          applied_resource_value, uom_code, basis_type,
          activity_id, autocharge_type, standard_rate_flag,
          start_date, completion_date,attribute_category, attribute1,
          attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,
          attribute8,attribute9,attribute10,attribute11,attribute12,
          attribute13,attribute14,attribute15, schedule_seq_num,
          substitute_group_num, replacement_group_num
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_RES_INSTANCE
      AND substitution_type = p_substitution_type;

BEGIN

    FOR cur_row IN res_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id,
                           p_substitution_type) LOOP

        ResInst_Info_Exist(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
		   cur_row.resource_seq_num,
		   cur_row.resource_instance_id,
                   null);

        IF IS_Error(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num)= 0 THEN

           Res_Instance_Job_Match(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num,
                   cur_row.resource_instance_id);

        End If;

    END LOOP;

exception
        when others then
             p_err_msg := 'wiprivdb, Delete_Resource_Instance: ' || SQLERRM;
             p_err_code := SQLCODE;

END Delete_Resource_Instance;

END WIP_RES_INST_VALIDATIONS;

/
