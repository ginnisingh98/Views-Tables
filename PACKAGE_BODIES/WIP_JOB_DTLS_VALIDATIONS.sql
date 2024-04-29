--------------------------------------------------------
--  DDL for Package Body WIP_JOB_DTLS_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_JOB_DTLS_VALIDATIONS" AS
/* $Header: wipjdvdb.pls 120.1 2005/12/22 02:39:11 panagara noship $ */
  procedure jobs (p_group_id IN number,
                  p_parent_header_id IN number) is
    cursor c_ml_invalid_rows is
      select interface_id
        from wip_job_dtls_interface wjdi
       where wjdi.group_id = p_group_id
         and wjdi.parent_header_id = p_parent_header_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (wip_constants.running, wip_constants.warning)
         and not exists (select 1
                           from wip_job_schedule_interface wjsi
                          where wjdi.group_id = wjsi.group_id
                            and wjdi.parent_header_id = wjsi.header_id);

    cursor c_wdj_invalid_rows is
      select interface_id
        from wip_job_dtls_interface wjdi
       where wjdi.group_id = p_group_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (wip_constants.running,
                                     wip_constants.warning)
         and not exists (select 1
                           from wip_discrete_jobs wdj
                          where wjdi.wip_entity_id = wdj.wip_entity_id
                            and wjdi.organization_id = wdj.organization_id);

    l_interface_id NUMBER;
    l_error_exists boolean := false;
  begin
    if(wip_job_details.std_alone = 0) then
      open c_ml_invalid_rows;
    else
      open c_wdj_invalid_rows;
    end if;

    loop
      if(wip_job_details.std_alone = 0) then
        fetch c_ml_invalid_rows into l_interface_id;
        exit when c_ml_invalid_rows%NOTFOUND;
      else
        fetch c_wdj_invalid_rows into l_interface_id;
        exit when c_wdj_invalid_rows%NOTFOUND;
      end if;
      l_error_exists := true; --loop executes only for invalid rows!
      fnd_message.set_name('WIP', 'WIP_JOB_DOES_NOT_EXIST');
      fnd_message.set_token('INTERFACE', to_char(l_interface_id));
      if(wip_job_details.std_alone = 1) then
        wip_interface_err_Utils.add_error(p_interface_id => l_interface_id,
                                          p_text         => substr(fnd_message.get,1,500),
                                          p_error_type   => wip_jdi_utils.msg_error);
      else
        wip_interface_err_Utils.add_error(p_interface_id => wip_jsi_utils.current_interface_id,
                                          p_text         => substr(fnd_message.get,1,500),
                                          p_error_type   => wip_jdi_utils.msg_error);
      end if;


    end loop;
    if(c_ml_invalid_rows%ISOPEN) then
      close c_ml_invalid_rows;
    elsif(c_wdj_invalid_rows%ISOPEN) then
      close c_wdj_invalid_rows;
    end if;

    if(l_error_exists) then
      if(wip_job_details.std_alone = 1) then
        update wip_job_dtls_interface wjdi
           set process_status = wip_constants.error
         where wjdi.group_id = p_group_id
           and process_phase = wip_constants.ml_validation
           and process_status in (wip_constants.running,
                                  wip_constants.warning)
           and not exists (select 1
                             from wip_discrete_jobs wdj
                            where wjdi.wip_entity_id = wdj.wip_entity_id
                              and wjdi.organization_id = wdj.organization_id);
      else
        update wip_job_dtls_interface wjdi
           set process_status = wip_constants.error
         where group_id = p_group_id
           and parent_header_id = p_parent_header_id
           and process_phase = wip_constants.ml_validation
           and process_status in (wip_constants.running,
                                  wip_constants.warning)
           and not exists (select 1
                           from wip_job_schedule_interface wjsi
                          where wjsi.group_id = p_group_id
                            and wjdi.parent_header_id = wjsi.header_id);
      end if;
    end if;
  end jobs;

  procedure job_status (p_group_id in number,
                        p_parent_header_id in number) is
    cursor c_ml_invalid_rows is
      select interface_id
        from wip_job_dtls_interface wjdi
       where wjdi.group_id = p_group_id
         and wjdi.parent_header_id = p_parent_header_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (wip_constants.running,
                                     wip_constants.warning)
         and not exists (select 1
                           from wip_discrete_jobs wdj
                          where wjdi.wip_entity_id = wdj.wip_entity_id
                            and wjdi.organization_id = wdj.organization_id
                            and wdj.status_type in (wip_constants.unreleased,
                                                    wip_constants.released,
                                                    wip_constants.comp_chrg,
                                                    wip_constants.hold));
    l_error_exists boolean := false;
  begin

        -- 1: unreleased, no charges allowed
        -- 3: released, charges allowed
        -- 4: complete, charges allowed
        -- 6: hold, no charges allowed
    if(wip_job_details.std_alone = 1) then
      for l_inv_row in c_ml_invalid_rows loop
        l_error_exists := true; --loop executes only for invalid rows!
        fnd_message.set_name('WIP', 'WIP_JOB_INVALID_STATUS');
        fnd_message.set_token('INTERFACE', to_char(l_inv_row.interface_id));
        wip_interface_err_Utils.add_error(p_interface_id => l_inv_row.interface_id,
                                          p_text         => substr(fnd_message.get,1,500),
                                          p_error_type   => wip_jdi_utils.msg_error);
        end loop;
    end if;

    if(l_error_exists) then
      update wip_job_dtls_interface wjdi
        set process_status = wip_constants.error
        where group_id = p_group_id
          and parent_header_id = p_parent_header_id
          and process_phase = wip_constants.ml_validation
          and process_status in (wip_constants.running,
                                 wip_constants.warning)
          and not exists (select 1
                            from wip_discrete_jobs wdj
                           where wjdi.wip_entity_id = wdj.wip_entity_id
                             and wjdi.organization_id = wdj.organization_id
                             and wdj.status_type in (wip_constants.unreleased,
                                                     wip_constants.released,
                                                     wip_constants.comp_chrg,
                                                     wip_constants.hold));
    end if;
  end job_status;

  procedure is_firm (p_group_id number,
                     p_parent_header_id number) is
    cursor c_invalid_rows is
      select interface_id
        from wip_job_dtls_interface wjdi
       where wjdi.group_id = p_group_id
         and wjdi.parent_header_id = p_parent_header_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (wip_constants.running,
                                     wip_constants.warning)
         and exists (select 1
                       from wip_discrete_jobs wdj
                      where wjdi.wip_entity_id = wdj.wip_entity_id
                        and wjdi.organization_id = wdj.organization_id
                        and wdj.status_type in (wip_constants.unreleased,
                                                wip_constants.released,
                                                wip_constants.comp_chrg,
                                                wip_constants.hold)
                        and wdj.firm_planned_flag = wip_constants.yes);

    l_error_exists boolean := false;
  begin
    -- If firmed, we can't do any further change
    if(wip_job_details.std_alone = 1) then
      for l_inv_row in c_invalid_rows loop
        l_error_exists := true;
        fnd_message.set_name('WIP', 'WIP_JOB_FIRMED');
        fnd_message.set_token('INTERFACE', to_char(l_inv_row.interface_id));
        wip_interface_err_Utils.add_error(p_interface_id => l_inv_row.interface_id,
                                          p_text         => substr(fnd_message.get,1,500),
                                          p_error_type   => wip_jdi_utils.msg_error);
      end loop;
    end if;

    if(l_error_exists) then
      update wip_job_dtls_interface wjdi
         set process_status = wip_constants.error
       where group_id = p_group_id
         and parent_header_id = p_parent_header_id
         and process_phase = wip_constants.ml_validation
         and process_status in (wip_constants.running,
                                wip_constants.warning)
         and exists (select 1
                       from wip_discrete_jobs wdj
                      where wjdi.wip_entity_id = wdj.wip_entity_id
                        and wjdi.organization_id = wdj.organization_id
                        and wdj.status_type in (wip_constants.unreleased,
                                                wip_constants.released,
                                                wip_constants.comp_chrg,
                                                wip_constants.hold)
                        and wdj.firm_planned_flag = wip_constants.yes);
    end if;
  end is_firm;

  procedure op_seq_num(p_group_id         IN number,
                       p_parent_header_id IN number,
                       p_wip_entity_id    IN number,
                       p_organization_id  IN number) is

    cursor c_first_operation is
      select min(operation_seq_num)
        from wip_operations
       where organization_id = p_organization_id
         and wip_entity_id = p_wip_entity_id;

    cursor c_ml_invalid_rows  is
      select interface_id
        from wip_job_dtls_interface wjdi
       where wjdi.group_id = p_group_id
         and wjdi.parent_header_id = p_parent_header_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (wip_constants.running,
                                     wip_constants.warning)
         and (   wjdi.load_type in (wip_job_details.wip_resource,
                                    wip_job_details.wip_sub_res,
                                    wip_job_details.wip_res_usage)

              or (    wjdi.load_type = wip_job_details.wip_mtl_requirement
                  and wjdi.operation_seq_num <> 1
                 )
             )
         and not exists (select 1
                           from wip_operations wo
                          where wjdi.wip_entity_id = wo.wip_entity_id
                            and wjdi.organization_id = wo.organization_id
                            and wjdi.operation_seq_num = wo.operation_seq_num);

    cursor c_wdj_invalid_rows is
      select interface_id
        from wip_job_dtls_interface wjdi
       where wjdi.group_id = p_group_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (wip_constants.running,
                                     wip_constants.warning)
         and wjdi.wip_entity_id = p_wip_entity_id
         and wjdi.organization_id = p_organization_id
         and (   wjdi.load_type in (wip_job_details.wip_resource,
                                    wip_job_details.wip_sub_res,
                                    wip_job_details.wip_res_usage)

              or (    wjdi.load_type = wip_job_details.wip_mtl_requirement
                  and wjdi.operation_seq_num <> 1
                 )
             )
         and not exists (select 1
                           from wip_operations wo
                          where wjdi.wip_entity_id = wo.wip_entity_id
                            and wjdi.organization_id = wo.organization_id
                            and wjdi.operation_seq_num = wo.operation_seq_num);

    l_num_first_op_rows   number := 0;
    l_first_op_seq_num number := 1;

    l_interface_id NUMBER;
    l_error_exists boolean := false;
  begin

    -- For add requirement only: If the operation sequence number given by the
    -- user is one, then we should treat it as the first operation.
    select count(*)
      into l_num_first_op_rows
      from wip_job_dtls_interface
     where group_id = p_group_id
       and parent_header_id = p_parent_header_id
       and process_phase = wip_constants.ml_validation
       and process_status in (wip_constants.running,wip_constants.warning)
       and wip_entity_id = p_wip_entity_id
       and organization_id = p_organization_id
       and load_type = wip_job_details.wip_mtl_requirement
       and substitution_type = wip_job_details.wip_add
       and operation_seq_num = 1;

    if(l_num_first_op_rows > 0) then
      --get the first op seq number
      open c_first_operation;
      fetch c_first_operation into l_first_op_seq_num;

      --update the details rows to the first op seq.
      if(c_first_operation%FOUND) then
       if l_first_op_seq_num is NOT NULL then /* Fix for Bug#3247891*/
        update wip_job_dtls_interface
           set operation_seq_num = l_first_op_seq_num
         where group_id = p_group_id
           and parent_header_id = p_parent_header_id
           and process_phase = wip_constants.ml_validation
           and process_status in (wip_constants.running, wip_constants.warning)
           and wip_entity_id = p_wip_entity_id
           and organization_id = p_organization_id
           and load_type = wip_job_details.wip_mtl_requirement
           and substitution_type = wip_job_details.wip_add
           and operation_seq_num = 1;
       end if ;
      end if;
      close c_first_operation;
    end if;
    -- operation_seq_num must be in job
    if(wip_job_details.std_alone = 1) then
      open c_wdj_invalid_rows;
    else
      open c_ml_invalid_rows;
    end if;

    loop
      if(wip_job_details.std_alone = 0) then
        fetch c_ml_invalid_rows into l_interface_id;
        exit when c_ml_invalid_rows%NOTFOUND;
      else
        fetch c_wdj_invalid_rows into l_interface_id;
        exit when c_wdj_invalid_rows%NOTFOUND;
      end if;
      l_error_exists := true; --loop executes only for invalid rows!
      fnd_message.set_name('WIP', 'WIP_OP_NOT_FOUND');
      fnd_message.set_token('INTERFACE', to_char(l_interface_id));
      if(wip_job_details.std_alone = 1) then
        wip_interface_err_Utils.add_error(p_interface_id => l_interface_id,
                                          p_text         => substr(fnd_message.get,1,500),
                                          p_error_type   => wip_jdi_utils.msg_error);
      else
        wip_interface_err_Utils.add_error(p_interface_id => wip_jsi_utils.current_interface_id,
                                          p_text         => substr(fnd_message.get,1,500),
                                          p_error_type   => wip_jdi_utils.msg_error);
      end if;


    end loop;
    if(c_ml_invalid_rows%ISOPEN) then
      close c_ml_invalid_rows;
    elsif(c_wdj_invalid_rows%ISOPEN) then
      close c_wdj_invalid_rows;
    end if;

    if(l_error_exists) then
      if(wip_job_details.std_alone = 1) then
        update wip_job_dtls_interface wjdi
           set process_status = wip_constants.error
         where group_id = p_group_id
           and process_phase = wip_constants.ml_validation
           and process_status in (wip_constants.running,
                                  wip_constants.warning)
           and wip_entity_id = p_wip_entity_id
           and organization_id = p_organization_id
           and (   load_type in (wip_job_details.wip_resource,
                                 wip_job_details.wip_sub_res,
                                 wip_job_details.wip_res_usage)

                or (    load_type = wip_job_details.wip_mtl_requirement
                    and operation_seq_num <> 1
                   )
               )
           and not exists (select 1
                             from wip_operations wo
                            where wjdi.wip_entity_id = wo.wip_entity_id
                              and wjdi.organization_id = wo.organization_id
                              and wjdi.operation_seq_num = wo.operation_seq_num);
      else
        update wip_job_dtls_interface wjdi
           set process_status = wip_constants.error
         where group_id = p_group_id
           and parent_header_id = p_parent_header_id
           and process_phase = wip_constants.ml_validation
           and process_status in (wip_constants.running,
                                  wip_constants.warning)
           and (   load_type in (wip_job_details.wip_resource,
                                 wip_job_details.wip_sub_res,
                                 wip_job_details.wip_res_usage)

                or (    load_type = wip_job_details.wip_mtl_requirement
                    and operation_seq_num <> 1
                   )
               )
           and not exists (select 1
                             from wip_operations wo
                            where wjdi.wip_entity_id = wo.wip_entity_id
                              and wjdi.organization_id = wo.organization_id
                              and wjdi.operation_seq_num = wo.operation_seq_num);
      end if;
    end if;
  end op_seq_num;


  procedure load_sub_types(p_group_id        IN number,
                           p_parent_header_id IN number,
                           p_wip_entity_id   IN number,
                           p_organization_id IN number) IS
    cursor c_invalid_rows is
      select interface_id
        from wip_job_dtls_interface wjdi
       where wjdi.group_id = p_group_id
         and wjdi.parent_header_id = p_parent_header_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (wip_constants.running,
                                     wip_constants.warning)
         and wjdi.wip_entity_id = p_wip_entity_id
         and wjdi.organization_id = p_organization_id
         and (   wjdi.load_type not in (1, 2, 3, 4, 5, 6, 7, WIP_JOB_DETAILS.WIP_RES_INSTANCE, WIP_JOB_DETAILS.WIP_RES_INSTANCE_USAGE)     -- load_type must be resource or material


              or wjdi.substitution_type not in (1, 2, 3)); -- substitution_type must be delete or add or change


    l_error_exists boolean := false;
  begin
    for l_inv_row in c_invalid_rows loop
      l_error_exists := true;
      fnd_message.set_name('WIP', 'WIP_INVALID_LOAD_SUB_TYPE');
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
      update wip_job_dtls_interface
         set process_status = wip_constants.error
       where group_id = p_group_id
         and parent_header_id = p_parent_header_id
         and process_phase = wip_constants.ml_validation
         and process_status in (wip_constants.running,
                                wip_constants.warning)
         and wip_entity_id = p_wip_entity_id
         and organization_id = p_organization_id
         and (   load_type not in (1, 2, 3, 4, 5)
              or substitution_type not in (1, 2, 3));
    end if;
  end load_sub_types;


  procedure last_updated_by(p_group_id        IN  number,
                            p_parent_header_id IN number,
                            p_wip_entity_id   IN  number,
                            p_organization_id IN  number) IS

    cursor c_invalid_rows is
      select interface_id
        from wip_job_dtls_interface wjdi
       where wjdi.group_id = p_group_id
         and wjdi.parent_header_id = p_parent_header_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (wip_constants.running,
                                     wip_constants.warning)
         and wjdi.wip_entity_id = p_wip_entity_id
         and wjdi.organization_id = p_organization_id
         and not exists (select 1
                           from fnd_user_view fu
                          where fu.user_id = wjdi.last_updated_by
                            and sysdate between fu.start_date and nvl(fu.end_date,sysdate+1));

      l_error_exists boolean := false;
  begin

    -- Give an error if NULL or if not a valid user
    for l_inv_row in c_invalid_rows loop
      l_error_exists := true;
      fnd_message.set_name('WIP', 'WIP_ML_LAST_UPDATED_BY');
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
         and parent_header_id = p_parent_header_id
         and process_phase = wip_constants.ml_validation
         and process_status in (wip_constants.running,
                                wip_constants.warning)
         and wip_entity_id = p_wip_entity_id
         and organization_id = p_organization_id
         and not exists (select 1
                           from fnd_user_view fu
                          where fu.user_id = wjdi.last_updated_by
                            and sysdate between fu.start_date and nvl(fu.end_date,sysdate+1));
    end if;
  end last_updated_by;

  procedure created_by(p_group_id        IN NUMBER,
                       p_parent_header_id IN NUMBER,
                       p_wip_entity_id   IN NUMBER,
                       p_organization_id IN NUMBER) IS
    cursor c_invalid_rows is
      select interface_id
        from wip_job_dtls_interface wjdi
       where wjdi.group_id = p_group_id
         and wjdi.parent_header_id = p_parent_header_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (wip_constants.running,
                                     wip_constants.warning)
         and wjdi.wip_entity_id = p_wip_entity_id
         and wjdi.organization_id = p_organization_id
         and not exists (select 1
                           from fnd_user_view fu
                          where fu.user_id = wjdi.created_by
                            and sysdate between fu.start_date and nvl(fu.end_date,sysdate+1));

      l_error_exists boolean := false;
  begin

    -- Give an error if NULL or if not a valid user
    for l_inv_row in c_invalid_rows loop
      l_error_exists := true;
      fnd_message.set_name('WIP', 'WIP_ML_CREATED_BY');
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
         and parent_header_id = p_parent_header_id
         and process_phase = wip_constants.ml_validation
         and process_status in (wip_constants.running,
                                      wip_constants.warning)
          and wip_entity_id = p_wip_entity_id
          and organization_id = p_organization_id
          and not exists (select 1
                            from fnd_user_view fu
                           where fu.user_id = wjdi.created_by
                             and sysdate between fu.start_date and nvl(fu.end_date,sysdate+1));
    end if;
  end created_by;


/*
 * If any record for a job is invalid, we must error out *all*
 *  records for that job.
 */
  procedure error_all_if_any(p_group_id        IN NUMBER,
                             p_parent_header_id IN NUMBER,
                             p_wip_entity_id   IN NUMBER,
                             p_organization_id IN NUMBER) is
    cursor c_invalid_rows is
      select interface_id
        from wip_job_dtls_interface wjdi
       where wjdi.group_id = p_group_id
         and wjdi.parent_header_id = p_parent_header_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (wip_constants.running,
                                     wip_constants.warning)
         and wjdi.wip_entity_id = p_wip_entity_id
         and wjdi.organization_id = p_organization_id
         and exists (select 1
                       from wip_job_dtls_interface wjdi2
                      where wjdi2.group_id = wjdi.group_id
                        and wjdi2.parent_header_id = wjdi.parent_header_id
                        and wjdi2.process_status = wip_constants.error
                        and wjdi2.wip_entity_id = wjdi.wip_entity_id
                        and wjdi2.organization_id = wjdi.organization_id);
    l_error_exists boolean := false;
  begin
    for l_inv_row in c_invalid_rows loop
      l_error_exists := true;
      fnd_message.set_name('WIP', 'WIP_JDI_OTHERS_FAILED');
      fnd_message.set_token('INTERFACE', to_char(l_inv_row.interface_id));
      wip_interface_err_Utils.add_error(p_interface_id => l_inv_row.interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
    end loop;
    if(l_error_exists) then
      update wip_job_dtls_interface wjdi
         set process_status = wip_constants.error
       where group_id = p_group_id
         and parent_header_id = p_parent_header_id
         and process_phase = wip_constants.ml_validation
         and process_status in (wip_constants.running,
                                wip_constants.warning)
         and wip_entity_id = p_wip_entity_id
         and organization_id = p_organization_id
         and exists (select 1
                       from wip_job_dtls_interface wjdi2
                      where wjdi2.group_id = wjdi.group_id
                        and wjdi2.parent_header_id = wjdi.parent_header_id
                        and wjdi2.process_status = wip_constants.error
                        and wjdi2.wip_entity_id = wjdi.wip_entity_id
                        and wjdi2.organization_id = wjdi.organization_id);
    end if;
  end error_all_if_any;
end wip_job_dtls_validations;

/
