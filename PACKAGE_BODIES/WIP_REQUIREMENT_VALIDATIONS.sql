--------------------------------------------------------
--  DDL for Package Body WIP_REQUIREMENT_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_REQUIREMENT_VALIDATIONS" AS
/* $Header: wiprqvdb.pls 120.8.12010000.4 2010/01/27 15:22:02 sisankar ship $ */

/* inventory_item_id_Old must not be null */
procedure del_req_info_exist(p_group_id                 in number,
                             p_wip_entity_id            in number,
                             p_organization_id          in number,
                             p_substitution_type        in number,
                             p_operation_seq_num        in number) IS

  cursor c_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type = wip_job_details.wip_mtl_requirement
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.inventory_item_id_old is null;

  l_error_exists boolean := false;
begin

  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_JDI_DEL_REQ_INFO_MISSING');
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
       and wjdi.load_type = wip_job_details.wip_mtl_requirement
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.inventory_item_id_old is null;
  end if;
end del_req_info_exist;



/* operations, requirements, etc all match and exist */
procedure req_job_match (p_group_id              in number,
                         p_wip_entity_id         in number,
                         p_organization_id       in number,
                         p_substitution_type     in number,
                         p_operation_seq_num     in number,
                         p_inventory_item_id_old in number) IS

  cursor c_invalid_rows is
  select wjdi.interface_id,
         we.wip_entity_name,
         wjdi.wip_entity_id,
         wjdi.operation_seq_num,
         msik.concatenated_segments item_name,
         wjdi.inventory_item_id_old
    from wip_job_dtls_interface wjdi,
         wip_entities we,
         mtl_system_items_kfv msik
       where wjdi.group_id = p_group_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (wip_constants.running,
                                     wip_constants.warning)
         and wjdi.wip_entity_id = p_wip_entity_id
         and wjdi.organization_id = p_organization_id
         and wjdi.load_type = wip_job_details.wip_mtl_requirement
         and wjdi.substitution_type = p_substitution_type
         and wjdi.operation_seq_num = p_operation_seq_num
         and wjdi.inventory_item_id_old = p_inventory_item_id_old
         and wjdi.wip_entity_id = we.wip_entity_id
         and wjdi.inventory_item_id_old = msik.inventory_item_id
         and wjdi.organization_id = msik.organization_id
         and not exists (select 1
                           from wip_requirement_operations wro
                          where wro.wip_entity_id = wjdi.wip_entity_id
                            and wro.organization_id = wjdi.organization_id
                            and wro.operation_seq_num = wjdi.operation_seq_num
                            and wro.inventory_item_id = wjdi.inventory_item_id_old);


  l_error_exists boolean := false;
begin

  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_JDI_REQ_NOT_IN_JOB');
    fnd_message.set_token('INTERFACE', to_char(l_inv_row.interface_id));
    fnd_message.set_token('JOB', l_inv_row.wip_entity_name);
    fnd_message.set_token('WEI', to_char(l_inv_row.wip_entity_id));
    fnd_message.set_token('OPERATION', to_char(l_inv_row.operation_seq_num));
    fnd_message.set_token('ITEM', l_inv_row.item_name);
    fnd_message.set_token('ITEMID', to_char(l_inv_row.inventory_item_id_old));
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
       and wjdi.load_type = wip_job_details.wip_mtl_requirement
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.inventory_item_id_old = p_inventory_item_id_old
       and not exists (select 1
                         from wip_requirement_operations wro
                        where wro.wip_entity_id = wjdi.wip_entity_id
                          and wro.organization_id = wjdi.organization_id
                          and wro.operation_seq_num = wjdi.operation_seq_num
                          and wro.inventory_item_id = wjdi.inventory_item_id_old);
  end if;
end req_job_match;


procedure safe_delete(p_group_id              in number,
                      p_wip_entity_id         in number,
                      p_organization_id       in number,
                      p_substitution_type     in number,
                      p_operation_seq_num     in number,
                      p_inventory_item_id_old in number) IS

x_quantity_issued       number;
x_exist         number := 0;

  cursor c_invalid_wro_rows is
  select interface_id
    from wip_job_dtls_interface wjdi
       where wjdi.group_id = p_group_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (wip_constants.running,
                                     wip_constants.warning)
         and wjdi.wip_entity_id = p_wip_entity_id
         and wjdi.organization_id = p_organization_id
         and wjdi.load_type = wip_job_details.wip_mtl_requirement
         and wjdi.substitution_type = p_substitution_type
         and wjdi.operation_seq_num = p_operation_seq_num
         and wjdi.inventory_item_id_old = p_inventory_item_id_old
         and exists (select 1
                       from wip_requirement_operations wro
                      where wro.wip_entity_id = p_wip_entity_id
                        and wro.organization_id = p_organization_id
                        and wro.operation_seq_num = p_operation_seq_num
                        and wro.inventory_item_id = p_inventory_item_id_old
                        and wro.quantity_issued <> 0);

  cursor c_invalid_mmtt_rows is
  select interface_id
    from wip_job_dtls_interface wjdi
       where wjdi.group_id = p_group_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (wip_constants.running,
                                     wip_constants.warning)
         and wjdi.wip_entity_id = p_wip_entity_id
         and wjdi.organization_id = p_organization_id
         and wjdi.load_type = wip_job_details.wip_mtl_requirement
         and wjdi.substitution_type = p_substitution_type
         and wjdi.operation_seq_num = p_operation_seq_num
         and wjdi.inventory_item_id_old = p_inventory_item_id_old
         and exists (select 1
                       from mtl_material_transactions_temp mmtt
                      where mmtt.transaction_source_id = p_wip_entity_id
                        and mmtt.organization_id = p_organization_id
                        and mmtt.operation_seq_num = p_operation_seq_num
                        and mmtt.inventory_item_id = p_inventory_item_id_old);

  cursor c_invalid_mmt_rows is
  select interface_id
    from wip_job_dtls_interface wjdi
       where wjdi.group_id = p_group_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (wip_constants.running,
                                     wip_constants.warning)
         and wjdi.wip_entity_id = p_wip_entity_id
         and wjdi.organization_id = p_organization_id
         and wjdi.load_type = wip_job_details.wip_mtl_requirement
         and wjdi.substitution_type = p_substitution_type
         and wjdi.operation_seq_num = p_operation_seq_num
         and wjdi.inventory_item_id_old = p_inventory_item_id_old
         and exists (select 1
                       from mtl_material_transactions mmt
                      where mmt.transaction_source_id = p_wip_entity_id
                        and mmt.organization_id = p_organization_id
                        and mmt.operation_seq_num = p_operation_seq_num
                        and mmt.inventory_item_id = p_inventory_item_id_old);

  l_error_exists boolean := false;
begin

  for l_inv_row in c_invalid_wro_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_JDI_QTY_ISSUED');
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
       and wjdi.load_type = wip_job_details.wip_mtl_requirement
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.inventory_item_id_old = p_inventory_item_id_old
       and exists (select 1
                     from wip_requirement_operations wro
                    where wro.wip_entity_id = wjdi.wip_entity_id
                      and wro.organization_id = wjdi.organization_id
                      and wro.operation_seq_num = wjdi.operation_seq_num
                      and wro.inventory_item_id = wjdi.inventory_item_id_old
                      and wro.quantity_issued > 0);
    return;
  end if;

  for l_inv_row in c_invalid_mmtt_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_JDI_REQ_JOB_PENDING');
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
       and wjdi.load_type = wip_job_details.wip_mtl_requirement
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.inventory_item_id_old = p_inventory_item_id_old
       and exists (select 1
                     from mtl_material_transactions_temp mmtt
                    where mmtt.transaction_source_id = wjdi.wip_entity_id
                      and mmtt.organization_id = wjdi.organization_id
                      and mmtt.operation_seq_num = wjdi.operation_seq_num
                      and mmtt.inventory_item_id = wjdi.inventory_item_id_old);
    return;
  end if;

  for l_inv_row in c_invalid_mmt_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_JDI_REQ_JOB_PENDING');
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
       and wjdi.load_type = wip_job_details.wip_mtl_requirement
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.inventory_item_id_old = p_inventory_item_id_old
       and exists (select 1
                     from mtl_material_transactions mmt
                    where mmt.transaction_source_id = wjdi.wip_entity_id
                      and mmt.organization_id = wjdi.organization_id
                      and mmt.operation_seq_num = wjdi.operation_seq_num
                      and mmt.inventory_item_id = wjdi.inventory_item_id_old);
  end if;
end safe_delete;


/* main delete, call the above. If any validation fail, it won''t go on
   with the next validations */
Procedure Delete_Req(p_group_id               in number,
                     p_wip_entity_id         in number,
                     p_organization_id       in number,
                     p_substitution_type     in number) IS

   CURSOR req_info(p_group_Id           number,
                   p_wip_entity_id      number,
                   p_organization_id    number,
                   p_substitution_type  number) IS
   SELECT distinct operation_seq_num,
          inventory_item_id_old, inventory_item_id_new,
          quantity_per_assembly,
          last_update_date, last_updated_by, creation_date, created_by,
          last_update_login, request_id, program_application_id,
          program_id, program_update_date,
          department_id, wip_supply_type, date_required,
          required_quantity, quantity_issued, supply_subinventory,
          supply_locator_id, mrp_net_flag, mps_required_quantity,
          mps_date_required, attribute_category, attribute1,
          attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,
          attribute8,attribute9,attribute10,attribute11,attribute12,
          attribute13,attribute14,attribute15
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_MTL_REQUIREMENT
      AND substitution_type = p_substitution_type;

BEGIN
     FOR cur_row IN req_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id,
                           p_substitution_type) LOOP
        Del_Req_Info_Exist(p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num);

        IF Info_Missing(p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num) = 0 THEN

           REQ_JOB_Match (p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.inventory_item_id_old);

           IF IS_Error(p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.inventory_item_id_old,
                        cur_row.inventory_item_id_new) = 0 THEN

              Safe_Delete (p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.inventory_item_id_old);

           END IF;
        END IF;
    END LOOP;
END Delete_Req;


procedure add_req_info_exist(p_group_id              in number,
                             p_wip_entity_id         in number,
                             p_organization_id       in number,
                             p_substitution_type     in number,
                             p_operation_seq_num     in number) IS
  cursor c_invalid_rows is
  select interface_id
    from wip_job_dtls_interface wjdi
       where wjdi.group_id = p_group_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (wip_constants.running,
                                     wip_constants.warning)
         and wjdi.wip_entity_id = p_wip_entity_id
         and wjdi.organization_id = p_organization_id
         and wjdi.load_type = wip_job_details.wip_mtl_requirement
         and wjdi.substitution_type = p_substitution_type
         and wjdi.operation_seq_num = p_operation_seq_num
         and (   wjdi.inventory_item_id_new is null
              or wjdi.quantity_per_assembly is null);

  l_error_exists boolean := false;
begin

  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_JDI_ADD_REQ_INFO_MISSING');
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
       and wjdi.load_type = wip_job_details.wip_mtl_requirement
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
         and (   wjdi.inventory_item_id_new is null
              or wjdi.quantity_per_assembly is null);
  end if;
end add_req_info_exist;



/* operations, requirements, should NOT exist; for add/change *
   check for duplicate requirement/operations */
procedure req_job_not_exist (p_group_id              in number,
                             p_wip_entity_id         in number,
                             p_organization_id       in number,
                             p_substitution_type     in number,
                             p_operation_seq_num     in number,
                             p_inventory_item_id_new in number) IS
  cursor c_invalid_rows is
  select interface_id
    from wip_job_dtls_interface wjdi
       where wjdi.group_id = p_group_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (wip_constants.running,
                                     wip_constants.warning)
         and wjdi.wip_entity_id = p_wip_entity_id
         and wjdi.organization_id = p_organization_id
         and wjdi.load_type = wip_job_details.wip_mtl_requirement
         and wjdi.substitution_type = p_substitution_type
         and wjdi.operation_seq_num = p_operation_seq_num
         and wjdi.inventory_item_id_new = p_inventory_item_id_new
         /* bug#2814045 */
         and nvl(wjdi.inventory_item_id_new, -1) <> nvl(wjdi.inventory_item_id_old, -1)
         and (   exists (select 1
                           from wip_requirement_operations wro
                          where wro.wip_entity_id = wjdi.wip_entity_id
                            and wro.organization_id = wjdi.organization_id
                            and wro.operation_seq_num = wjdi.operation_seq_num
                            and wro.inventory_item_id = wjdi.inventory_item_id_new)
              or exists (select 1
                           from wip_job_dtls_interface wjdi2
                          where wjdi.interface_id <> wjdi2.interface_id
                            and wjdi.group_id = wjdi2.group_id
                            and wjdi.wip_entity_id = wjdi2.wip_entity_id
                            and wjdi.organization_id = wjdi2.organization_id
                            and wjdi.operation_seq_num = wjdi2.operation_seq_num
                            and wjdi.inventory_item_id_new= wjdi2.inventory_item_id_new)
             );

  l_error_exists boolean := false;
begin

  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_JDI_REQ_EXIST');
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
       and wjdi.load_type = wip_job_details.wip_mtl_requirement
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.inventory_item_id_new = p_inventory_item_id_new
       /* Fix for Bug 5632150 */
	   /* and wjdi.inventory_item_id_new <> wjdi.inventory_item_id_old */
	   and nvl(wjdi.inventory_item_id_new,-1) <> nvl(wjdi.inventory_item_id_old,-1)
       and (   exists (select 1
                         from wip_requirement_operations wro
                        where wro.wip_entity_id = wjdi.wip_entity_id
                          and wro.organization_id = wjdi.organization_id
                          and wro.operation_seq_num = wjdi.operation_seq_num
                          and wro.inventory_item_id = wjdi.inventory_item_id_new)
            or exists (select 1
                         from wip_job_dtls_interface wjdi2
                        where wjdi.interface_id <> wjdi2.interface_id
                          and wjdi.group_id = wjdi2.group_id
                          and wjdi.wip_entity_id = wjdi2.wip_entity_id
                          and wjdi.organization_id = wjdi2.organization_id
                          and wjdi.operation_seq_num = wjdi2.operation_seq_num
                          and wjdi.inventory_item_id_new= wjdi2.inventory_item_id_new)
           );
  end if;
end req_job_not_exist;



/* for add/change only */
procedure valid_requirement(p_group_id              in number,
                            p_wip_entity_id         in number,
                            p_organization_id       in number,
                            p_substitution_type     in number,
                            p_operation_seq_num     in number,
                            p_inventory_item_id_new in number) IS
  cursor c_invalid_rows is
  select interface_id
    from wip_job_dtls_interface wjdi
       where wjdi.group_id = p_group_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (wip_constants.running,
                                     wip_constants.warning)
         and wjdi.wip_entity_id = p_wip_entity_id
         and wjdi.organization_id = p_organization_id
         and wjdi.load_type = wip_job_details.wip_mtl_requirement
         and wjdi.substitution_type = p_substitution_type
         and wjdi.operation_seq_num = p_operation_seq_num
         and wjdi.inventory_item_id_new = p_inventory_item_id_new
         and not exists (select 1
                           from mtl_system_items msi
                          where msi.inventory_item_id = wjdi.inventory_item_id_new
                            and msi.organization_id = wjdi.organization_id);

  /* bug#2811687 : begin */
  cursor c_supply_types_invalid_rows is
  select wjdi.interface_id
    from wip_job_dtls_interface wjdi, wip_job_schedule_interface wjsi
       where wjdi.group_id = p_group_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (wip_constants.running,
                                     wip_constants.warning)
         and wjdi.wip_entity_id = p_wip_entity_id
         and wjdi.organization_id = p_organization_id
         and wjdi.load_type = wip_job_details.wip_mtl_requirement
         and wjdi.substitution_type = p_substitution_type
         and wjdi.operation_seq_num = p_operation_seq_num
         and wjdi.inventory_item_id_new = p_inventory_item_id_new
         and wjdi.parent_header_id = wjsi.header_id
         and wjdi.group_id = wjsi.group_id
         and wjdi.organization_id = wjsi.organization_id
         and wjdi.wip_entity_id = wjsi.wip_entity_id
         and (wjdi.wip_supply_type = wip_constants.phantom
           or (wjsi.load_type in (wip_constants.create_eam_job, wip_constants.resched_eam_job)
                 and wjdi.wip_supply_type <> wip_constants.push));

  cursor c_mrp_net_flag_invalid_rows is
  select wjdi.interface_id
    from wip_job_dtls_interface wjdi, wip_job_schedule_interface wjsi
       where wjdi.group_id = p_group_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (wip_constants.running,
                                     wip_constants.warning)
         and wjdi.wip_entity_id = p_wip_entity_id
         and wjdi.organization_id = p_organization_id
         and wjdi.load_type = wip_job_details.wip_mtl_requirement
         and wjdi.substitution_type = p_substitution_type
         and wjdi.operation_seq_num = p_operation_seq_num
         and wjdi.inventory_item_id_new = p_inventory_item_id_new
         and wjdi.parent_header_id = wjsi.header_id
         and wjdi.group_id = wjsi.group_id
         and wjdi.organization_id = wjsi.organization_id
         and wjdi.wip_entity_id = wjsi.wip_entity_id
         and (wjdi.mrp_net_flag not in (wip_constants.yes, wip_constants.no));

  cursor c_auto_req_mat_invalid_rows is
  select wjdi.interface_id
    from wip_job_dtls_interface wjdi, wip_job_schedule_interface wjsi
       where wjdi.group_id = p_group_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (wip_constants.running,
                                     wip_constants.warning)
         and wjdi.wip_entity_id = p_wip_entity_id
         and wjdi.organization_id = p_organization_id
         and wjdi.load_type = wip_job_details.wip_mtl_requirement
         and wjdi.substitution_type = p_substitution_type
         and wjdi.operation_seq_num = p_operation_seq_num
         and wjdi.inventory_item_id_new = p_inventory_item_id_new
         and wjdi.parent_header_id = wjsi.header_id
         and wjdi.group_id = wjsi.group_id
         and wjdi.organization_id = wjsi.organization_id
         and wjdi.wip_entity_id = wjsi.wip_entity_id
         and (upper(wjdi.auto_request_material) not in ('Y', 'N'));
  /* bug#2814045 : end */

/* bug 3112793 */
cursor c_direct_item_rows(p_profile_value IN number) is
 select interface_id
  from wip_job_dtls_interface wjdi
    where wjdi.group_id=p_group_id
      and wjdi.process_phase = wip_constants.ml_validation
      and wjdi.process_status in ( wip_constants.running,
                                   wip_constants.warning )
      and wjdi.wip_entity_id = p_wip_entity_id
      and wjdi.organization_id = p_organization_id
      and wjdi.load_type = wip_job_details.wip_mtl_requirement
      and wjdi.substitution_type = p_substitution_type
      and wjdi.operation_seq_num = p_operation_seq_num
      and wjdi.inventory_item_id_new = p_inventory_item_id_new
      and NOT exists ( select 1 from mtl_system_items msi
               where msi.inventory_item_id = wjdi.inventory_item_id_new
               and msi.organization_id = wjdi.organization_id
               and BOM_ENABLED_FLAG = 'Y'
               and BOM_ITEM_TYPE = 4
               and (( p_profile_value = WIP_CONSTANTS.YES)
               or (ENG_ITEM_FLAG = 'N' and p_profile_value = WIP_CONSTANTS.NO))
           );
/* end of 3112793 */

  l_profile_value number ;
  l_error_exists boolean := false;
begin

  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_JDI_INVALID_MTL_REQ');
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

  /* bug#2811687 : begin */
  for l_inv_row in c_supply_types_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_JDI_INVALID_SUPPLY_TYPE');
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

  for l_inv_row in c_mrp_net_flag_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_JDI_INVALID_MRP_NET_FLAG');
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

  for l_inv_row in c_auto_req_mat_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_JDI_INVALID_AUTO_REQ_MAT');
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
  /* bug#2811687 : end */

  l_profile_value := fnd_profile.value('WIP_SEE_ENG_ITEMS');
  for l_inv_row in c_direct_item_rows ( l_profile_value ) loop
  l_error_exists := true ;
  fnd_message.set_name('WIP','WIP_JDI_DIRECT_ITEM');
  fnd_message.set_token('INTERFACE',to_char(l_inv_row.interface_id));
  if(wip_job_details.std_alone =1 ) then
      wip_interface_err_utils.add_error (
                          p_interface_id => l_inv_row.interface_id,
                          p_text    => substr(fnd_message.get,1,500),
                          p_error_type => wip_jdi_utils.msg_error);
 else
       wip_interface_err_utils.add_error (
                          p_interface_id => wip_jsi_utils.current_interface_id,
                          p_text    => substr(fnd_message.get,1,500),
                          p_error_type => wip_jdi_utils.msg_error);
   end if ;
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
       and wjdi.load_type = wip_job_details.wip_mtl_requirement
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.inventory_item_id_new = p_inventory_item_id_new;
/* bug#2811687
       and not exists (select 1
                         from mtl_system_items msi
                        where msi.inventory_item_id = wjdi.inventory_item_id_new
                          and msi.organization_id = wjdi.organization_id);
*/
  end if;

end valid_requirement;


/*Bug 4202200 */
procedure valid_requirement_supply_type
                           (p_group_id              in number,
                           --need to fixed in forward port of 4142439 or 4159367, also see sql
                            --p_parent_header_id      in number,
                            p_wip_entity_id         in number,
                            p_organization_id       in number,
                            p_substitution_type     in number,
                            p_operation_seq_num     in number,
                            p_inventory_item_id_old in number,
                            p_inventory_item_id_new in number) IS

/* This query is modified for bug 5216025. The join with WJSI is not required as the validation happens
only if there is a parent record in wip_job_schedule_interface for the same job.
*/
  cursor c_supply_types_invalid_rows is
  select wjdi.interface_id
    from wip_job_dtls_interface wjdi /*, wip_job_schedule_interface wjsi */
       where wjdi.group_id = p_group_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (wip_constants.running,
                                     wip_constants.warning)
         and wjdi.wip_entity_id = p_wip_entity_id
         and wjdi.organization_id = p_organization_id
         and wjdi.load_type = wip_job_details.wip_mtl_requirement
         and wjdi.substitution_type = p_substitution_type
         and wjdi.operation_seq_num = p_operation_seq_num
         and (wjdi.inventory_item_id_new = p_inventory_item_id_new
              or p_inventory_item_id_new is null)
         and (wjdi.inventory_item_id_old = p_inventory_item_id_old
              or p_inventory_item_id_old is null)
         and (p_inventory_item_id_old is not null or
              p_inventory_item_id_new is not null)
         /*and (wjdi.parent_header_id = p_parent_header_id or
              WIP_JOB_DETAILS.STD_ALONE = 1)*/
         /*and wjdi.organization_id = wjsi.organization_id
         and wjdi.wip_entity_id = wjsi.wip_entity_id*/
         and wjdi.wip_supply_type = wip_constants.op_pull
         and not exists
         (select 1 from wip_operations
          where wip_entity_id = wjdi.wip_entity_id
          and organization_id = wjdi.organization_id);


  l_error_exists boolean := false;
begin

  for l_inv_row in c_supply_types_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_JDI_INVALID_SUP_TYPE_NO_OP');
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

    update wip_job_dtls_interface wjdi
       set process_status = wip_constants.error
     where interface_id = l_inv_row.interface_id;
  end loop;

end valid_requirement_supply_type;
/*End of Bug Fix 4202200 */


/* main add, call the above */
Procedure add_Req(p_group_id               in number,
                  p_wip_entity_id         in number,
                  p_organization_id       in number,
                  p_substitution_type     in number) IS

   x_err_code      varchar2(30) := null;
   x_err_msg       varchar2(240) := NULL;

   CURSOR req_info(p_group_Id           number,
                   p_wip_entity_id      number,
                   p_organization_id    number,
                   p_substitution_type  number) IS
   SELECT distinct operation_seq_num,
          inventory_item_id_old, inventory_item_id_new,
          quantity_per_assembly,component_yield_factor, /*Component Yield Enhancement(Bug 4369064)*/
          last_update_date, last_updated_by, creation_date, created_by,
          last_update_login, request_id, program_application_id,
          program_id, program_update_date,
          department_id, wip_supply_type, date_required,
          required_quantity, quantity_issued,
          basis_type,                                       /* LBM Project */
          supply_subinventory,
          supply_locator_id, mrp_net_flag, mps_required_quantity,
          mps_date_required, attribute_category, attribute1,
          attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,
          attribute8,attribute9,attribute10,attribute11,attribute12,
          attribute13,attribute14,attribute15
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_MTL_REQUIREMENT
      AND substitution_type = p_substitution_type;

BEGIN
  FOR cur_row IN req_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id,
                           p_substitution_type) LOOP

        Add_Req_Info_Exist(p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num);

        IF Info_Missing(p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num) = 0 THEN

           REQ_JOB_NOT_EXIST (p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.inventory_item_id_new);

           IF IS_Error(p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.inventory_item_id_old,
                        cur_row.inventory_item_id_new) = 0 THEN

              Valid_Requirement (p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.inventory_item_id_new);

              IF IS_Error(p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.inventory_item_id_old,
                        cur_row.inventory_item_id_new) = 0 THEN

                 WIP_REQUIREMENT_DEFAULT.Default_Requirement(
                        p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.inventory_item_id_old,
                        cur_row.inventory_item_id_new,
                        round(cur_row.quantity_per_assembly, 6),
                        cur_row.basis_type,                         /* LBM Project */
                        cur_row.component_yield_factor,/*Component Yield Enhancement(Bug 4369064)*/
                        x_err_code,
                        x_err_msg);

                 IF x_err_code is null THEN
                    Post_Default (p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.inventory_item_id_new);
                 END IF;
              END IF;
           END IF;
        END IF;

      /*bug 4202200
        If the job has no operations , supply_type can not be
        operation pull
       */

        Valid_Requirement_Supply_Type (p_group_id,
                        --need to fixed in forward port of 4142439 or 4159367
                        --p_parent_header_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.inventory_item_id_old,
                        cur_row.inventory_item_id_new);

    END LOOP;
END Add_Req;



/* called after defaulting */
procedure post_default(p_group_id              number,
                       p_wip_entity_id         number,
                       p_organization_id       number,
                       p_substitution_type     number,
                       p_operation_seq_num     number,
                       p_inventory_item_id_new number) IS
  cursor c_invalid_rows is
  select interface_id
    from wip_job_dtls_interface wjdi
       where wjdi.group_id = p_group_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (wip_constants.running,
                                     wip_constants.warning)
         and wjdi.wip_entity_id = p_wip_entity_id
         and wjdi.organization_id = p_organization_id
         and wjdi.load_type = wip_job_details.wip_mtl_requirement
         and wjdi.substitution_type = p_substitution_type
         and wjdi.operation_seq_num = p_operation_seq_num
         and wjdi.inventory_item_id_new = p_inventory_item_id_new
         and wjdi.wip_supply_type is null;

  l_error_exists boolean := false;
begin

  -- Give Error if wip_supply_type is NULL
  -- Only do this validation when ADD/CHANGE Requirements

  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_JDI_NULL_SUPPLY_TYPE');
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
       and wjdi.load_type = wip_job_details.wip_mtl_requirement
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.inventory_item_id_new = p_inventory_item_id_new
       and wjdi.wip_supply_type is null;
  end if;
end post_default;



procedure chng_req_info_exist(p_group_id        number,
                              p_wip_entity_id              number,
                              p_organization_id            number,
                              p_substitution_type          number,
                              p_operation_seq_num          number) IS
  cursor c_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type = wip_job_details.wip_mtl_requirement
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and (   wjdi.inventory_item_id_old is null
            or (wjdi.inventory_item_id_old <> nvl(wjdi.inventory_item_id_new, wjdi.inventory_item_id_old)
                and wjdi.quantity_per_assembly is null
                and not exists
                      ( select 1
                        from   bom_substitute_components bsc
                        where  bsc.substitute_component_id = wjdi.inventory_item_id_new
                        and    bsc.component_sequence_id =
                            (select wro.component_sequence_id
                             from   wip_requirement_operations wro
                             where  wro.inventory_item_id        = wjdi.inventory_item_id_old
                             and    wro.wip_entity_id            = wjdi.wip_entity_id
                             and    wro.operation_seq_num        = wjdi.operation_seq_num
                             and    wro.organization_id          = wjdi.organization_id
                             )
                         and  bsc.acd_type is null
                        )
                  )
              ) ;

  l_error_exists boolean := false;
begin

  -- Give Error if wip_supply_type is NULL
  -- Only do this validation when ADD/CHANGE Requirements

  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_JDI_CHNG_REQ_INFO_MISSING');
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
       and wjdi.load_type = wip_job_details.wip_mtl_requirement
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and (   wjdi.inventory_item_id_old is null
            or (    wjdi.inventory_item_id_old <> nvl(wjdi.inventory_item_id_new, wjdi.inventory_item_id_old)
                and wjdi.quantity_per_assembly is null
               )
           );
  end if;
end chng_req_info_exist;

Procedure derive_quantity(
                p_group_id              in  number,
                p_wip_entity_id         in  number,
                p_organization_id       in  number,
                p_substitution_type     in  number,
                p_operation_seq_num     in  number,
                p_inventory_item_id_old in  number,
                p_inventory_item_id_new in  number,
                p_quantity_per_assembly in  number,
                p_required_quantity     in  number,
                p_basis_type            in  number,    /* LBM Project */
                p_component_yield_factor in number,   /*Component Yield Enhancement(Bug 4369064)*/
                p_err_code              out nocopy varchar2,
                p_err_msg               out nocopy varchar2) IS

        x_required_quantity       NUMBER;
        x_mps_required_quantity   NUMBER;
        X_start_quantity        number;
        X_quantity_per_assembly number ;
        X_component_yield_factor number;      /*Component Yield Enhancement(Bug 4369064)*/
        X_start_quantity_wro     number;      /*Component Yield Enhancement(Bug 4369064)*/
        X_quantity_per_assembly_wro number ;  /*Component Yield Enhancement(Bug 4369064)*/
        X_component_yield_factor_wro number;  /*Component Yield Enhancement(Bug 4369064)*/
        X_required_quantity_wro  number;      /*Component Yield Enhancement(Bug 4369064)*/
        x_qpa_val number;                     /*Component Yield Enhancement(Bug 4369064)*/
        x_rq_val number;                      /*Component Yield Enhancement(Bug 4369064)*/
        x_cyf_val number;                     /*Component Yield Enhancement(Bug 4369064)*/


BEGIN

     /* returns if mat is changed, defaulting for those are done in
        WIP_REQUIREMENT_DEFAULT.Default_Requirement */
     if (p_inventory_item_id_new is not null and p_inventory_item_id_new <> p_inventory_item_id_old ) then
        return;
     end if;

     begin
         SELECT start_quantity
          INTO X_start_quantity
          FROM WIP_DISCRETE_JOBS
         WHERE wip_entity_id = p_wip_entity_id
          AND organization_id = p_organization_id;

           /*Component Yield Enhancement(Bug 4369064)->Get the current values of qpa, req_qty and yield*/
           begin
             SELECT nvl(component_yield_factor,1),required_quantity,quantity_per_assembly
             INTO x_component_yield_factor_wro,x_required_quantity_wro,x_quantity_per_assembly_wro
             FROM wip_requirement_operations
             WHERE wip_entity_id = p_wip_entity_id
             AND organization_id = p_organization_id
             AND inventory_item_id = p_inventory_item_id_old;
           exception
             when no_data_found then
               return;  /*Let the validation error be caught in valid_requirement*/
           end;

        X_quantity_per_assembly := p_quantity_per_assembly;
        x_required_quantity := p_required_quantity;
        X_component_yield_factor := p_component_yield_factor; /*Component Yield Enhancement(Bug 4369064)*/

        /*Component Yield Enhancement(Bug 4369064)
          Use following values while re-calculation of yield or required quantity*/

         x_qpa_val := nvl(x_quantity_per_assembly,x_quantity_per_assembly_wro);
          x_rq_val := nvl(x_required_quantity,x_required_quantity_wro);
         x_cyf_val := nvl(x_component_yield_factor,x_component_yield_factor_wro);

        /*Component Yield Enhancement(Bug 4369064)
          User can provide any combination of qpa, req_qty and yield in WJDI. So there would be 8 combinations
          in all. We have divided them in following categories
          1. When all of them are null -> Don't do anything
          2. When only req qty is provied -> ie user wanted to re-calculate yield from req qty.
          3. When req qty and QPA are provided -> calculate yield.
	  4. When req qty and yield are provided -> calculate QPA.
          5. Rest of the cases -> re-calculate required quantity in all such cases
        */
        if x_quantity_per_assembly is null and x_component_yield_factor is null
                 and x_required_quantity is null then
           null;

        elsif x_quantity_per_assembly is null and x_component_yield_factor is null
                 and x_required_quantity is not null then /*User entered required qty, calculate yield */

	      /* LBM Project changes have been re-evaluated by Jenny */
              if p_basis_type = WIP_CONSTANTS.LOT_BASED_MTL then
                 x_component_yield_factor := round(x_qpa_val / x_required_quantity,6);
              else
                 x_component_yield_factor := round(x_qpa_val * X_start_quantity / x_required_quantity,6);
              end if;

	elsif x_required_quantity is not null and x_quantity_per_assembly  is not null
                 and x_component_yield_factor is null then /*User entered required qty and QPA, calculate yield */

                if p_basis_type = WIP_CONSTANTS.LOT_BASED_MTL then
                  x_component_yield_factor := round(x_qpa_val / x_required_quantity,6);
                else
                  x_component_yield_factor := round(x_qpa_val * X_start_quantity / x_required_quantity,6);
                end if;

	elsif x_required_quantity is not null and x_component_yield_factor is not null
                 and x_quantity_per_assembly is null then /*User entered required qty and yield, calculate QPA */

		  if p_basis_type = WIP_CONSTANTS.LOT_BASED_MTL then
                      X_quantity_per_assembly := round(x_cyf_val * x_required_quantity,6);
                else
                      X_quantity_per_assembly := round(x_cyf_val *  x_required_quantity / X_start_quantity ,6);
                end if;

        else /*User entered QPA, calculate required qty */
	     /*User entered yield, calculate required qty */
	     /*User entered QPA and yield, calculate required qty */
	     /*User entered QPA, required qty and yield, re-calculate required qty */
	           if p_basis_type = WIP_CONSTANTS.LOT_BASED_MTL then
                     x_required_quantity := round(x_qpa_val / x_cyf_val , 6);
                   else
                      x_required_quantity := round(x_start_quantity * x_qpa_val / x_cyf_val , 6);
                   end if;

            x_MPS_required_quantity := x_required_quantity;

        end if;

        if (x_required_quantity is not null) then
          UPDATE WIP_JOB_DTLS_INTERFACE
          SET    quantity_per_assembly   = nvl(X_quantity_per_assembly, quantity_per_assembly),
                 required_quantity       = x_required_quantity,
                 mps_required_quantity   = nvl(x_mps_required_quantity,mps_required_quantity),
                 component_yield_factor  = nvl(x_component_yield_factor,component_yield_factor)
                                                /*Component Yield Enhancement(Bug 4369064)*/
          WHERE   group_id = p_group_id
          AND     wip_entity_id = p_wip_entity_id
          AND     organization_id = p_organization_id
          AND     load_type = WIP_JOB_DETAILS.WIP_MTL_REQUIREMENT
          AND     substitution_type = p_substitution_type
          AND     operation_seq_num = p_operation_seq_num
          AND     inventory_item_id_old = p_inventory_item_id_old;
        end if;

     exception
           when others then
              p_err_msg := 'WIPRQVDB.pls<Procedure derive_quantity>:' || SQLERRM;
              p_err_code := SQLCODE;
     end;

END derive_quantity;

Procedure Change_Req(p_group_id               in number,
                     p_wip_entity_id         in number,
                     p_organization_id       in number,
                     p_substitution_type     in number) IS

x_err_code      varchar2(30) := null;
x_err_msg       varchar2(240) := NULL;
   CURSOR req_info(p_group_Id           number,
                   p_wip_entity_id      number,
                   p_organization_id    number,
                   p_substitution_type  number) IS
   SELECT distinct operation_seq_num,
          inventory_item_id_old, inventory_item_id_new,
          quantity_per_assembly,component_yield_factor, /*Component Yield Enhancement(Bug 4369064)*/
          last_update_date, last_updated_by, creation_date, created_by,
          last_update_login, request_id, program_application_id,
          program_id, program_update_date,
          department_id, wip_supply_type, date_required,
          required_quantity, quantity_issued,
          basis_type,                                       /* LBM Project */
          supply_subinventory,
          supply_locator_id, mrp_net_flag, mps_required_quantity,
          mps_date_required, attribute_category, attribute1,
          attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,
          attribute8,attribute9,attribute10,attribute11,attribute12,
          attribute13,attribute14,attribute15
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_MTL_REQUIREMENT
      AND substitution_type = p_substitution_type;

BEGIN

     FOR cur_row IN req_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id,
                           p_substitution_type) LOOP

       derive_quantity(p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.inventory_item_id_old,
                        cur_row.inventory_item_id_new,
                        round(cur_row.quantity_per_assembly, 6),
                        round(cur_row.required_quantity, 6),
                        cur_row.basis_type,                          /* LBM Project */
                        cur_row.component_yield_factor,/*Component Yield Enhancement(Bug 4369064)*/
                        x_err_code,
                        x_err_msg);
       IF x_err_code is null then

        Chng_Req_Info_Exist(p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num);

        IF Info_Missing(p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num) = 0 THEN
           REQ_JOB_Match (p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.inventory_item_id_old);

           /* Bug 7758528. Material requirements form allows us to update transacted materials.
                    So call to validate for transactions/ pending transactions will be done only if user
                    is updating the component itself. */

           IF IS_Error(p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.inventory_item_id_old,
                        cur_row.inventory_item_id_new) = 0 AND
              nvl(cur_row.inventory_item_id_new, cur_row.inventory_item_id_old) <> cur_row.inventory_item_id_old THEN

              REQ_JOB_NOT_EXIST (p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.inventory_item_id_new);

         -- check that the new component not exist in same operation.

              IF IS_Error(p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.inventory_item_id_old,
                        cur_row.inventory_item_id_new) = 0 THEN

                Safe_Delete (p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.inventory_item_id_old);

                IF IS_Error(p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.inventory_item_id_old,
                        cur_row.inventory_item_id_new) = 0 AND
                    cur_row.inventory_item_id_new IS NOT NULL THEN

                 Valid_Requirement (p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.inventory_item_id_new);

                 IF IS_Error(p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.inventory_item_id_old,
                        cur_row.inventory_item_id_new) = 0 THEN

                    WIP_REQUIREMENT_DEFAULT.Default_Requirement(p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.inventory_item_id_old,
                        cur_row.inventory_item_id_new,
                        round(cur_row.quantity_per_assembly, 6),
                        cur_row.basis_type,                         /* LBM Project */
                        cur_row.component_yield_factor,/*Component Yield Enhancement(Bug 4369064)*/
                        x_err_code,
                        x_err_msg);

                    IF x_err_code is null  AND
                       cur_row.inventory_item_id_new IS NOT NULL  AND
		       cur_row.inventory_item_id_new <> cur_row.inventory_item_id_old THEN /*Component Yield Enhancement(Bug 4369064)*/

                       Post_Default (p_group_id,
                         p_wip_entity_id,
                         p_organization_id,
                         p_substitution_type,
                         cur_row.operation_seq_num,
                         cur_row.inventory_item_id_new);
                    END IF;
                 END IF;
              END IF;
           END IF;
         END IF;
        END IF;
      END IF;

      /*bug 4202200 -> If the job has no operations , supply_type can not be
        operation pull; I have put this condition here since we should also be
        catering to cases where inventory_item_id_new is null */

      Valid_Requirement_Supply_Type (p_group_id,
                      --need to fixed in forward port of 4142439 or 4159367
                      --p_parent_header_id,
                      p_wip_entity_id,
                      p_organization_id,
                      p_substitution_type,
                      cur_row.operation_seq_num,
                      cur_row.inventory_item_id_old,
                      cur_row.inventory_item_id_new);

    END LOOP;

END Change_Req;

function IS_Error(p_group_id            number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number,
                        p_operation_seq_num     number,
                        p_inventory_item_id_old number,
                        p_inventory_item_id_new number) return number IS

x_count number := 0;

BEGIN

    IF p_substitution_type = WIP_JOB_DETAILS.WIP_DELETE THEN
        SELECT count(*)
          INTO x_count
          FROM WIP_JOB_DTLS_INTERFACE
         WHERE group_id         = p_group_id
           AND process_status   = WIP_CONSTANTS.ERROR
           AND wip_entity_id    = p_wip_entity_id
           AND organization_id  = p_organization_id
           AND load_type        = WIP_JOB_DETAILS.WIP_MTL_REQUIREMENT
           AND substitution_type= p_substitution_type
           AND operation_seq_num= p_operation_seq_num
           AND inventory_item_id_old = p_inventory_item_id_old;

    ELSIF p_substitution_type = WIP_JOB_DETAILS.WIP_ADD THEN
        SELECT count(*)
          INTO x_count
          FROM WIP_JOB_DTLS_INTERFACE
         WHERE group_id         = p_group_id
           AND process_status   = WIP_CONSTANTS.ERROR
           AND wip_entity_id    = p_wip_entity_id
           AND organization_id  = p_organization_id
           AND load_type        = WIP_JOB_DETAILS.WIP_MTL_REQUIREMENT
           AND substitution_type= p_substitution_type
           AND operation_seq_num= p_operation_seq_num
           AND inventory_item_id_new = p_inventory_item_id_new;

    ELSIF p_substitution_type = WIP_JOB_DETAILS.WIP_CHANGE THEN
         SELECT count(*)
          INTO x_count
          FROM WIP_JOB_DTLS_INTERFACE
         WHERE group_id         = p_group_id
           AND process_status   = WIP_CONSTANTS.ERROR
           AND wip_entity_id    = p_wip_entity_id
           AND organization_id  = p_organization_id
           AND load_type        = WIP_JOB_DETAILS.WIP_MTL_REQUIREMENT
           AND substitution_type= p_substitution_type
           AND operation_seq_num= p_operation_seq_num
           AND inventory_item_id_old = p_inventory_item_id_old
           AND inventory_item_id_new = p_inventory_item_id_new;

    END IF;

    IF x_count <> 0 THEN
        return 1;
    ELSE
        return 0;
    END IF;

END IS_Error;

function Info_Missing(p_group_id            number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number,
                        p_operation_seq_num     number) return number IS

x_count number := 0;

BEGIN

    IF p_substitution_type = WIP_JOB_DETAILS.WIP_DELETE THEN
        SELECT count(*)
          INTO x_count
          FROM WIP_JOB_DTLS_INTERFACE
         WHERE group_id         = p_group_id
           AND process_status   = WIP_CONSTANTS.ERROR
           AND wip_entity_id    = p_wip_entity_id
           AND organization_id  = p_organization_id
           AND load_type        = WIP_JOB_DETAILS.WIP_MTL_REQUIREMENT
           AND substitution_type= p_substitution_type
           AND operation_seq_num= p_operation_seq_num
           AND inventory_item_id_old IS NULL;

    ELSIF p_substitution_type = WIP_JOB_DETAILS.WIP_ADD THEN
        SELECT count(*)
          INTO x_count
          FROM WIP_JOB_DTLS_INTERFACE
         WHERE group_id         = p_group_id
           AND process_status   = WIP_CONSTANTS.ERROR
           AND wip_entity_id    = p_wip_entity_id
           AND organization_id  = p_organization_id
           AND load_type        = WIP_JOB_DETAILS.WIP_MTL_REQUIREMENT
           AND substitution_type= p_substitution_type
           AND operation_seq_num= p_operation_seq_num
           AND (inventory_item_id_new IS NULL
            OR  quantity_per_assembly IS NULL);

    ELSIF p_substitution_type = WIP_JOB_DETAILS.WIP_CHANGE THEN
        SELECT count(*)
          INTO x_count
          FROM WIP_JOB_DTLS_INTERFACE
         WHERE group_id         = p_group_id
           AND process_status   = WIP_CONSTANTS.ERROR
           AND wip_entity_id    = p_wip_entity_id
           AND organization_id  = p_organization_id
           AND load_type        = WIP_JOB_DETAILS.WIP_MTL_REQUIREMENT
           AND substitution_type= p_substitution_type
           AND operation_seq_num= p_operation_seq_num
           AND (inventory_item_id_old IS NULL
            OR  quantity_per_assembly IS NULL);

    END IF;

        IF x_count <> 0 THEN
           return 1;
        ELSE return 0;
        END IF;

END Info_Missing;

END WIP_REQUIREMENT_VALIDATIONS;

/
