--------------------------------------------------------
--  DDL for Package Body WIP_RES_USAGE_VALIDATE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_RES_USAGE_VALIDATE" as
/* $Header: wipruvdb.pls 120.2 2006/09/01 06:00:23 panagara noship $ */
--is the resource sequence valid (not null)?
procedure validate_seq_num(p_group_id in number, p_wip_entity_id in number, p_organization_id in number);
--does the sequence number already exist in WOR?
procedure validate_res_seq_num(p_group_id in number, p_wip_entity_id in number, p_organization_id in number);
--are the dates populated?
procedure validate_dates(p_group_id in number, p_wip_entity_id in number, p_organization_id in number);
--assigned units > 0?
procedure validate_assigned_units(p_group_id in number, p_wip_entity_id in number, p_organization_id in number);
--times don't overlap?
procedure val_time_overlap_res_usage(p_group_id in number, p_wip_entity_id in number, p_organization_id in number);
procedure val_time_overlap_ri_usage(p_group_id in number, p_wip_entity_id in number, p_organization_id in number);
--times match slot?
procedure validate_time_slot(p_group_id in number, p_wip_entity_id in number, p_organization_id in number);

procedure derive_usages(p_group_id in number, p_wip_entity_id in number, p_organization_id in number) is
    cursor c_usage_rows is
      select resource_seq_num, parent_seq_num, operation_seq_num, resource_id_new, rowid
        from wip_job_dtls_interface wjdi
       where group_id = p_group_id
         and process_phase = wip_constants.ml_validation
         and process_status in (wip_constants.running,
                                wip_constants.warning)
         and wip_entity_id = p_wip_entity_id
         and organization_id = p_organization_id
         and load_type in (wip_job_details.wip_res_usage,
                           wip_job_details.wip_res_instance_usage)
         and substitution_type = wip_job_details.wip_add;

	 l_res_seq number;
  begin
    for cur_row in c_usage_rows loop
      if (cur_row.resource_seq_num is null and cur_row.parent_seq_num is not null) then
           /* Fixed bug 5500805. We should not copy parent_seq_num to resource_seq_num but
	      we need to derive it from the parent resource of this setup resource.
	      This query works for both res_usage and res_instance_usage */
            select resource_seq_num into l_res_seq
	      from wip_operation_resources
	     where organization_id = p_organization_id
	       and wip_entity_id = p_wip_entity_id
	       and operation_seq_num = cur_row.operation_seq_num
	       and resource_id = cur_row.resource_id_new
	       and parent_resource_seq = cur_row.parent_seq_num;

        update wip_job_dtls_interface wjdi
           set resource_seq_num = l_res_seq
         where rowid = cur_row.rowid;

      end if;
    end loop;

end derive_usages;

Procedure Validate_Usage ( p_group_id           in number,
                           p_wip_entity_id      in number,
                           p_organization_id    in number,
                           x_err_code           out NOCOPY varchar2,
                           x_err_msg            out NOCOPY varchar2,
                           x_return_status      out NOCOPY varchar2 ) IS

 BEGIN
   IF p_group_id IS NULL OR
      p_wip_entity_id IS NULL OR p_organization_id IS NULL THEN
      x_err_code := SQLCODE;
      x_err_msg := 'Error in wipruvdb.pls : Primary key cannot be null!';
      x_return_status := FND_API.G_RET_STS_ERROR;
      RETURN;
   END IF;

   derive_usages(p_group_id => p_group_id,
                    p_wip_entity_id => p_wip_entity_id,
                    p_organization_id => p_organization_id);

/**************CHECK THAT RESOURCE SEQ NUM IS NOT NULL ***************/
   validate_seq_num(p_group_id => p_group_id,
                    p_wip_entity_id => p_wip_entity_id,
                    p_organization_id => p_organization_id);

/***********CHECK THAT IF SUCH A RESOURCE EXIST IN RESOURCE TABLE *********/
  validate_res_seq_num(p_group_id => p_group_id,
                       p_wip_entity_id => p_wip_entity_id,
                       p_organization_id => p_organization_id);

/*************CHECK THAT START AND END DATE CANNOT BE NULL IF ADD**********/
  validate_dates(p_group_id => p_group_id,
                 p_wip_entity_id => p_wip_entity_id,
                 p_organization_id => p_organization_id);

/*************CHECK THAT THE TIME SLOT CANNOT BE OVERLAPPED **********/
  val_time_overlap_res_usage(p_group_id => p_group_id,
                        p_wip_entity_id => p_wip_entity_id,
                        p_organization_id => p_organization_id);
  val_time_overlap_ri_usage(p_group_id => p_group_id,
                        p_wip_entity_id => p_wip_entity_id,
                        p_organization_id => p_organization_id);

  validate_time_slot(p_group_id => p_group_id,
                     p_wip_entity_id => p_wip_entity_id,
                     p_organization_id => p_organization_id);

/***************CHECK THAT ASSIGNED UNITS CANNOT BE NULL ****************/
  validate_assigned_units(p_group_id => p_group_id,
                     p_wip_entity_id => p_wip_entity_id,
                     p_organization_id => p_organization_id);

  exception
    When others then
       x_err_code := SQLCODE;
       x_err_msg := 'Error in wiprudfb: '|| SQLERRM;
       x_return_status := FND_API.G_RET_STS_ERROR;
  END VALIDATE_USAGE;

  procedure validate_seq_num(p_group_id in number, p_wip_entity_id in number, p_organization_id in number) is
    cursor c_invalid_rows is
      select interface_id
        from wip_job_dtls_interface wjdi
       where group_id = p_group_id
         and process_phase = wip_constants.ml_validation
         and process_status in (wip_constants.running,
                                wip_constants.warning)
         and wip_entity_id = p_wip_entity_id
         and organization_id = p_organization_id
         and load_type in (wip_job_details.wip_res_usage,
                           wip_job_details.wip_res_instance_usage)
         and substitution_type = wip_job_details.wip_add
         and (resource_seq_num is null
             or (load_type = wip_job_details.wip_res_instance_usage
                 and resource_instance_id is null));
    l_error_exists boolean := false;
  begin
    for l_inv_row in c_invalid_rows loop
      l_error_exists := true;
      fnd_message.set_name('WIP', 'WIP_NOT_NULL_VAL_LACK');
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
         and load_type in (wip_job_details.wip_res_usage,
                           wip_job_details.wip_res_instance_usage)
         and substitution_type = wip_job_details.wip_add
         and (resource_seq_num is null
             or (load_type = wip_job_details.wip_res_instance_usage
                 and resource_instance_id is null));
    end if;
  end validate_seq_num;


  procedure validate_res_seq_num(p_group_id in number, p_wip_entity_id in number, p_organization_id in number) is
    cursor c_invalid_rows is
      select interface_id
        from wip_job_dtls_interface wjdi
       where group_id = p_group_id
         and process_phase = wip_constants.ml_validation
         and process_status in (wip_constants.running,
                                wip_constants.warning)
         and wip_entity_id = p_wip_entity_id
         and organization_id = p_organization_id
         and substitution_type = wip_job_details.wip_add
         and ((load_type = wip_job_details.wip_res_instance_usage
               and  not exists (select 1
                           from wip_op_resource_instances
                          where wip_entity_id = wjdi.wip_entity_id
                            and organization_id = wjdi.organization_id
                            and operation_seq_num = wjdi.operation_seq_num
                            and resource_seq_num = wjdi.resource_seq_num
                            and instance_id = wjdi.resource_instance_id))
           or (load_type = wip_job_details.wip_res_usage
               and not exists (select 1
                           from wip_operation_resources
                          where wip_entity_id = wjdi.wip_entity_id
                            and organization_id = wjdi.organization_id
                            and operation_seq_num = wjdi.operation_seq_num
                            and resource_seq_num = wjdi.resource_seq_num)));
    l_error_exists boolean := false;
  begin
    for l_inv_row in c_invalid_rows loop
      l_error_exists := true;
      fnd_message.set_name('WIP', 'WIP_JDI_RES_NOT_IN_JOB');
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
         and substitution_type = wip_job_details.wip_add
         and ((load_type = wip_job_details.wip_res_instance_usage
               and  not exists (select 1
                           from wip_op_resource_instances
                          where wip_entity_id = wjdi.wip_entity_id
                            and organization_id = wjdi.organization_id
                            and operation_seq_num = wjdi.operation_seq_num
                            and resource_seq_num = wjdi.resource_seq_num
                            and instance_id = wjdi.resource_instance_id))
           or (load_type = wip_job_details.wip_res_usage
               and not exists (select 1
                           from wip_operation_resources
                          where wip_entity_id = wjdi.wip_entity_id
                            and organization_id = wjdi.organization_id
                            and operation_seq_num = wjdi.operation_seq_num
                            and resource_seq_num = wjdi.resource_seq_num)));

    end if;
  end validate_res_seq_num;

  procedure validate_dates(p_group_id in number, p_wip_entity_id in number, p_organization_id in number) is
    cursor c_invalid_rows is
      select interface_id
        from wip_job_dtls_interface wjdi
       where group_id = p_group_id
         and process_phase = wip_constants.ml_validation
         and process_status in (wip_constants.running,
                                wip_constants.warning)
         and wip_entity_id = p_wip_entity_id
         and organization_id = p_organization_id
         and load_type in (wip_job_details.wip_res_usage,
                             wip_job_details.wip_res_instance_usage)
         and substitution_type = wip_job_details.wip_add
         and (   start_date is null
              or completion_date is null
    --Bug 5139799:Following 2 validations are added:
    -- 1.Start date of usage is greater than or equal to start date of the corresponding resource or instance.
    -- 2.Start and end dates of usage is in between start and end dates of corresponding resource or instance.
              or start_date > completion_date
              or exists (select 1
                         from   wip_operation_resources wor,wip_op_resource_instances wori
                         where  wor.wip_entity_id = p_wip_entity_id
                         and    wor.operation_seq_num = wjdi.operation_seq_num
                         and    wor.resource_seq_num  = wjdi.resource_seq_num
                         and    wor.wip_entity_id = wori.wip_entity_id(+)
                         and    wor.operation_seq_num = wori.operation_seq_num(+)
                         and    wor.resource_seq_num  = wori.resource_seq_num(+)
                         and    wjdi.resource_instance_id = wori.instance_id(+)
                         and   (nvl(wori.start_date,wor.start_date) > wjdi.start_date
	                        or  nvl(wori.completion_date,wor.completion_date) <wjdi.completion_date)));

    l_error_exists boolean := false;
    begin

    for l_inv_row in c_invalid_rows loop
      l_error_exists := true;
      fnd_message.set_name('WIP', 'WIP_INV_START_OR_END');
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
         and load_type in (wip_job_details.wip_res_usage,
                             wip_job_details.wip_res_instance_usage)
         and substitution_type = wip_job_details.wip_add
         and (   start_date is null
              or completion_date is null
    --Bug 5139799:Following 2 validations are added:
    -- 1.Start date of usage is greater than or equal to start date of the corresponding resource or instance.
    -- 2.Start and end dates of usage is in between start and end dates of corresponding resource or instance.
              or start_date > completion_date
              or exists (select 1
                         from   wip_operation_resources wor,wip_op_resource_instances wori
                         where  wor.wip_entity_id = p_wip_entity_id
                         and    wor.operation_seq_num = wjdi.operation_seq_num
                         and    wor.resource_seq_num  = wjdi.resource_seq_num
                         and    wor.wip_entity_id = wori.wip_entity_id(+)
                         and    wor.operation_seq_num = wori.operation_seq_num(+)
                         and    wor.resource_seq_num  = wori.resource_seq_num(+)
                         and    wjdi.resource_instance_id = wori.instance_id(+)
                         and   (nvl(wori.start_date,wor.start_date) > wjdi.start_date
                                or  nvl(wori.completion_date,wor.completion_date) <wjdi.completion_date)));
    end if;
  end validate_dates;

  procedure validate_assigned_units(p_group_id in number, p_wip_entity_id in number, p_organization_id in number) is
    cursor c_invalid_rows is
      select interface_id
        from wip_job_dtls_interface wjdi
       where group_id = p_group_id
         and process_phase = wip_constants.ml_validation
         and process_status in (wip_constants.running,
                                wip_constants.warning)
         and wip_entity_id = p_wip_entity_id
         and organization_id = p_organization_id
         and load_type in (wip_job_details.wip_res_usage,
                             wip_job_details.wip_res_instance_usage)
         and substitution_type = wip_job_details.wip_add
         and (   assigned_units is null
              or assigned_units <= 0);

    l_error_exists boolean := false;
    begin

    for l_inv_row in c_invalid_rows loop
      l_error_exists := true;
      fnd_message.set_name('WIP', 'WIP_INV_ASSIGNED_UNITS');
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
         and load_type in (wip_job_details.wip_res_usage,
                             wip_job_details.wip_res_instance_usage)
         and substitution_type = wip_job_details.wip_add
         and (   assigned_units is null
              or assigned_units < 0);
    end if;
  end validate_assigned_units;

  procedure val_time_overlap_ri_usage(p_group_id in number, p_wip_entity_id in number, p_organization_id in number) is

    cursor c_invalid_res_inst_usage_rows is
      select interface_id
        from wip_job_dtls_interface wjdi
       where group_id = p_group_id
         and process_phase = wip_constants.ml_validation
         and process_status in (wip_constants.running,
                                wip_constants.warning)
         and wip_entity_id = p_wip_entity_id
         and organization_id = p_organization_id
         and load_type = wip_job_details.wip_res_instance_usage
         and substitution_type = wip_job_details.wip_add
         and exists (select 1
                       from wip_job_dtls_interface wjdi2
                      where wjdi2.group_id = wjdi.group_id
                        and wjdi2.wip_entity_id = p_wip_entity_id
                        and wjdi2.organization_id = p_organization_id
                        and wjdi2.operation_seq_num = wjdi.operation_seq_num
                        and wjdi2.resource_seq_num = wjdi.resource_seq_num
                        and wjdi2.load_type = wip_job_details.wip_res_instance_usage
                        and wjdi2.start_date < wjdi.start_date
                        and wjdi2.completion_date > wjdi.start_date);

    l_error_exists boolean := false;
    begin

    for l_inv_row in c_invalid_res_inst_usage_rows loop
      l_error_exists := true;
      fnd_message.set_name('WIP', 'WIP_TIME_OVERLAPPED');
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
         and load_type = wip_job_details.wip_res_instance_usage
         and substitution_type = wip_job_details.wip_add
         and exists (select 1
                       from wip_job_dtls_interface wjdi2
                      where wjdi2.group_id = wjdi.group_id
                        and wjdi2.wip_entity_id = p_wip_entity_id
                        and wjdi2.organization_id = p_organization_id
                        and wjdi2.operation_seq_num = wjdi.operation_seq_num
                        and wjdi2.resource_seq_num = wjdi.resource_seq_num
                        and load_type = wip_job_details.wip_res_instance_usage
                        and wjdi2.rowid <> wjdi.rowid
                        and (   wjdi2.start_date between wjdi.start_date and wjdi.completion_date
                             or wjdi2.completion_date between wjdi.start_date and wjdi.completion_date));

    end if;

  end val_time_overlap_ri_usage;

  procedure val_time_overlap_res_usage(p_group_id in number, p_wip_entity_id in number, p_organization_id in number) is
    cursor c_invalid_res_usage_rows is
      select interface_id
        from wip_job_dtls_interface wjdi
       where group_id = p_group_id
         and process_phase = wip_constants.ml_validation
         and process_status in (wip_constants.running,
                                wip_constants.warning)
         and wip_entity_id = p_wip_entity_id
         and organization_id = p_organization_id
         and load_type = wip_job_details.wip_res_usage
         and substitution_type = wip_job_details.wip_add
         and exists (select 1
                       from wip_job_dtls_interface wjdi2
                      where wjdi2.group_id = wjdi.group_id
                        and wjdi2.wip_entity_id = p_wip_entity_id
                        and wjdi2.organization_id = p_organization_id
                        and wjdi2.operation_seq_num = wjdi.operation_seq_num
                        and wjdi2.resource_seq_num = wjdi.resource_seq_num
                        and wjdi2.load_type = wip_job_details.wip_res_usage
                        and wjdi2.start_date < wjdi.start_date
                        and wjdi2.completion_date > wjdi.start_date);

    l_error_exists boolean := false;
    begin

    for l_inv_row in c_invalid_res_usage_rows loop
      l_error_exists := true;
      fnd_message.set_name('WIP', 'WIP_TIME_OVERLAPPED');
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
         and load_type = wip_job_details.wip_res_usage
         and substitution_type = wip_job_details.wip_add
         and exists (select 1
                       from wip_job_dtls_interface wjdi2
                      where wjdi2.group_id = wjdi.group_id
                        and wjdi2.wip_entity_id = p_wip_entity_id
                        and wjdi2.organization_id = p_organization_id
                        and wjdi2.operation_seq_num = wjdi.operation_seq_num
                        and wjdi2.resource_seq_num = wjdi.resource_seq_num
                        and load_type = wip_job_details.wip_res_usage
                        and wjdi2.rowid <> wjdi.rowid
                        and (   wjdi2.start_date between wjdi.start_date and wjdi.completion_date
                             or wjdi2.completion_date between wjdi.start_date and wjdi.completion_date));

    end if;

  end val_time_overlap_res_usage;

  procedure validate_time_slot(p_group_id in number, p_wip_entity_id in number, p_organization_id in number) is
    cursor c_invalid_rows is
      select interface_id
        from wip_job_dtls_interface wjdi
       where group_id = p_group_id
         and process_phase = wip_constants.ml_validation
         and process_status in (wip_constants.running,
                                wip_constants.warning)
         and wip_entity_id = p_wip_entity_id
         and organization_id = p_organization_id
         and load_type = wip_job_details.wip_res_usage
         and substitution_type = wip_job_details.wip_add
         and (   not exists (select 1
                               from wip_job_dtls_interface wjdi2, wip_operation_resources wor
                              where wjdi2.group_id = wjdi.group_id
                                and wjdi2.wip_entity_id = p_wip_entity_id
                                and wjdi2.organization_id = p_organization_id
                                and wjdi2.operation_seq_num =  wjdi.operation_seq_num
                                and wjdi2.resource_seq_num = wjdi.resource_seq_num
                                and wjdi2.load_type = wip_job_details.wip_res_usage
                                and wjdi2.substitution_type = wip_job_details.wip_add
                                and wor.wip_entity_id = p_wip_entity_id
                                and wor.organization_id = p_organization_id
                                and wor.operation_seq_num = wjdi2.operation_seq_num
                                and wor.resource_seq_num = wjdi2.resource_seq_num
                                and wor.start_date = wjdi2.start_date)
              or not exists (select 1
                               from wip_job_dtls_interface wjdi2, wip_operation_resources wor
                              where wjdi2.group_id = wjdi.group_id
                                and wjdi2.wip_entity_id = p_wip_entity_id
                                and wjdi2.organization_id = p_organization_id
                                and wjdi2.operation_seq_num =  wjdi.operation_seq_num
                                and wjdi2.resource_seq_num = wjdi.resource_seq_num
                                and wjdi2.load_type = wip_job_details.wip_res_usage
                                and wjdi2.substitution_type = wip_job_details.wip_add
                                and wor.wip_entity_id = p_wip_entity_id
                                and wor.organization_id = p_organization_id
                                and wor.operation_seq_num = wjdi2.operation_seq_num
                                and wor.resource_seq_num = wjdi2.resource_seq_num
                                and wor.completion_date = wjdi2.completion_date));
    l_error_exists boolean := false;
  begin
    for l_inv_row in c_invalid_rows loop
      l_error_exists := true;
      fnd_message.set_name('WIP', 'WIP_DATE_NOT_MATCH');
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
         and load_type = wip_job_details.wip_res_usage
         and substitution_type = wip_job_details.wip_add
         and (   not exists (select 1
                               from wip_job_dtls_interface wjdi2, wip_operation_resources wor
                              where wjdi2.group_id = wjdi.group_id
                                and wjdi2.wip_entity_id = p_wip_entity_id
                                and wjdi2.organization_id = p_organization_id
                                and wjdi2.operation_seq_num =  wjdi.operation_seq_num
                                and wjdi2.resource_seq_num = wjdi.resource_seq_num
                                and wjdi2.load_type = wip_job_details.wip_res_usage
                                and wjdi2.substitution_type = wip_job_details.wip_add
                                and wor.wip_entity_id = p_wip_entity_id
                                and wor.organization_id = p_organization_id
                                and wor.operation_seq_num = wjdi2.operation_seq_num
                                and wor.resource_seq_num = wjdi2.resource_seq_num
                                and wor.start_date = wjdi2.start_date)
              or not exists (select 1
                               from wip_job_dtls_interface wjdi2, wip_operation_resources wor
                              where wjdi2.group_id = wjdi.group_id
                                and wjdi2.wip_entity_id = p_wip_entity_id
                                and wjdi2.organization_id = p_organization_id
                                and wjdi2.operation_seq_num =  wjdi.operation_seq_num
                                and wjdi2.resource_seq_num = wjdi.resource_seq_num
                                and wjdi2.load_type = wip_job_details.wip_res_usage
                                and wjdi2.substitution_type = wip_job_details.wip_add
                                and wor.wip_entity_id = p_wip_entity_id
                                and wor.organization_id = p_organization_id
                                and wor.operation_seq_num = wjdi2.operation_seq_num
                                and wor.resource_seq_num = wjdi2.resource_seq_num
                                and wor.completion_date = wjdi2.completion_date));
    end if;
  end validate_time_slot;
end wip_res_usage_validate;

/
