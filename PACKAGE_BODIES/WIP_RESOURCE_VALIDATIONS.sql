--------------------------------------------------------
--  DDL for Package Body WIP_RESOURCE_VALIDATIONS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_RESOURCE_VALIDATIONS" AS
/* $Header: wiprsvdb.pls 120.7.12000000.4 2007/03/10 02:13:19 ntangjee ship $ */

/* forward declarations */
Procedure check_res_sched_subgroup (p_group_id  in number,
                        p_wip_entity_id         in number,
                        p_organization_id      in number,
                        p_substitution_type  in number,
                        p_operation_seq_num     in  number,
                        p_resource_seq_num      in number,
                        p_schedule_seq_num     in number,
                        p_substitute_group_num in number,
                        p_replacement_group_num in number);

Procedure check_sub_sched_subgroup (p_group_id  number,
                        p_wip_entity_id         number,
                        p_organization_id      number,
                        p_substitution_type  number,
                        p_operation_seq_num     number,
                        p_resource_seq_num      number,
                        p_schedule_seq_num     number,
                        p_substitute_group_num number,
                        p_replacement_group_num number);

/* resource_seq_num, resource_id NOT NULL when delete/change resource */
procedure del_res_info_exist(p_group_id                 in number,
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
       and wjdi.load_type in (wip_job_details.wip_resource, wip_job_details.wip_sub_res)
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and (   wjdi.resource_seq_num is null
            or wjdi.resource_id_old is null);

  l_error_exists boolean := false;
begin

  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_JDI_DEL_RES_INFO_MISSING');
    fnd_message.set_token('INTERFACE', to_char(l_inv_row.interface_id));
    if (wip_job_details.std_alone = 1) then
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
       and wjdi.load_type in (wip_job_details.wip_resource, wip_job_details.wip_sub_res)
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and (   wjdi.resource_seq_num is null
            or wjdi.resource_id_old is null);
  end if;
end del_res_info_exist;


/* operations, resources, etc all match and exist */
procedure res_job_match (p_group_id             number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number,
                        p_operation_seq_num     number,
                        p_resource_seq_num      number,
                        p_resource_id_old       number) IS

  -- Job/op_seq_num/resource_seq_num/resource_id_old all match
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
       and wjdi.load_type in (wip_job_details.wip_resource, wip_job_details.wip_sub_res)
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and wjdi.resource_id_old = p_resource_id_old
       and not (  (exists (select 1
                         from wip_operation_resources wor
                        where wor.wip_entity_id = wjdi.wip_entity_id
                          and wor.organization_id = wjdi.organization_id
                          and wor.operation_seq_num = wjdi.operation_seq_num
                          and wor.resource_seq_num = wjdi.resource_seq_num
                          and wor.resource_id = wjdi.resource_id_old))
                          or
                         (exists (select 1
                         from wip_sub_operation_resources wsor
                        where wsor.wip_entity_id = wjdi.wip_entity_id
                          and wsor.organization_id = wjdi.organization_id
                          and wsor.operation_seq_num = wjdi.operation_seq_num
                          and wsor.resource_seq_num = wjdi.resource_seq_num
                          and wsor.resource_id = wjdi.resource_id_old))
                      );

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
       and wjdi.load_type in (wip_job_details.wip_resource, wip_job_details.wip_sub_res)
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and wjdi.resource_id_old = p_resource_id_old
       and not (  (exists (select 1
                         from wip_operation_resources wor
                        where wor.wip_entity_id = wjdi.wip_entity_id
                          and wor.organization_id = wjdi.organization_id
                          and wor.operation_seq_num = wjdi.operation_seq_num
                          and wor.resource_seq_num = wjdi.resource_seq_num
                          and wor.resource_id = wjdi.resource_id_old))
                          or
                         (exists (select 1
                         from wip_sub_operation_resources wsor
                        where wsor.wip_entity_id = wjdi.wip_entity_id
                          and wsor.organization_id = wjdi.organization_id
                          and wsor.operation_seq_num = wjdi.operation_seq_num
                          and wsor.resource_seq_num = wjdi.resource_seq_num
                          and wsor.resource_id = wjdi.resource_id_old))
                      );
  end if;
end res_job_match;


Procedure Safe_Delete (p_group_id               number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number,
                        p_operation_seq_num     number,
                        p_resource_seq_num      number,
                        p_resource_id_old       number) IS

  cursor c_invalid_wor_rows is
    select interface_id
      from wip_job_dtls_interface wjdi, wip_operation_resources wor
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type = wip_job_details.wip_resource
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wor.wip_entity_id = p_wip_entity_id
       and wor.organization_id = p_organization_id
       and wor.operation_seq_num = p_operation_seq_num
       and wor.resource_seq_num = p_resource_seq_num
       and wor.resource_id = p_resource_id_old
       and wor.applied_resource_units <> 0;

  cursor c_invalid_txn_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type = wip_job_details.wip_resource
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and (   exists (select 1
                        from wip_transactions wt
                       where wt.wip_entity_id = p_wip_entity_id
                         and wt.organization_id = p_organization_id
                         and wt.operation_seq_num = p_operation_seq_num
                         and wt.resource_seq_num = p_resource_seq_num
                         and wt.resource_id = p_resource_id_old)
            or exists (select 1
                         from wip_cost_txn_interface wcti, bom_resources br
                        where wcti.wip_entity_id = p_wip_entity_id
                          and wcti.organization_id = p_organization_id
                          and wcti.operation_seq_num = p_operation_seq_num
                          and wcti.resource_seq_num = p_resource_seq_num
                          and wcti.resource_code = br.resource_code (+)
                          and wcti.organization_id = br.organization_id (+)
                          and (   wcti.resource_id = p_resource_id_old
                               or br.resource_id = p_resource_id_old))
           );
  l_error_exists boolean := false;
begin

  -- applied_resource_units in WIP_OPERATION_RESOURCES must be 0
  for l_inv_row in c_invalid_wor_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_JDI_RES_APPLIED');
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
       set wjdi.process_status = wip_constants.error
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type = wip_job_details.wip_resource
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and exists (select 1
                     from wip_operation_resources wor
                    where wor.wip_entity_id = p_wip_entity_id
                      and wor.organization_id = p_organization_id
                      and wor.operation_seq_num = p_operation_seq_num
                      and wor.resource_seq_num = p_resource_seq_num
                      and wor.resource_id = p_resource_id_old
                      and wor.applied_resource_units <> 0);
    return;
  end if;

  --now check for [pending] transactions
  for l_inv_row in c_invalid_txn_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_JDI_DELETE_RESOURCE');
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
       and wjdi.load_type = wip_job_details.wip_resource
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and (   exists (select 1
                        from wip_transactions wt
                       where wt.wip_entity_id = p_wip_entity_id
                         and wt.organization_id = p_organization_id
                         and wt.operation_seq_num = p_operation_seq_num
                         and wt.resource_seq_num = p_resource_seq_num
                         and wt.resource_id = p_resource_id_old)
            or exists (select 1
                         from wip_cost_txn_interface wcti, bom_resources br
                        where wcti.wip_entity_id = p_wip_entity_id
                          and wcti.organization_id = p_organization_id
                          and wcti.operation_seq_num = p_operation_seq_num
                          and wcti.resource_seq_num = p_resource_seq_num
                          and wcti.resource_code = br.resource_code (+)
                          and wcti.organization_id = br.organization_id (+)
                          and (   wcti.resource_id = p_resource_id_old
                               or br.resource_id = p_resource_id_old))
           );
  end if;

end safe_delete;

/* outside processing */
Procedure Safe_PO (p_group_id  number,
                   p_wip_entity_id         number,
                   p_organization_id       number,
                   p_substitution_type     number,
                   p_operation_seq_num     number,
                   p_resource_seq_num      number,
                   p_resource_id_old       number) IS

  /* Bug 5004087 (FP of 4747215): Added WIP_RESOURCE_SEQ_NUM condition when checking
     for existing PO/REQ. */
  cursor c_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type = wip_job_details.wip_resource
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and wjdi.resource_id_old = p_resource_id_old
       -- Bug 4321480 - Modified the exists clause to exclude Cancelled PO/POR.
       and (exists
             ( SELECT 'PO/REQ Linked'
                 FROM PO_RELEASES_ALL PR,
                      PO_HEADERS_ALL PH,
                      PO_DISTRIBUTIONS_ALL PD,
                      PO_LINE_LOCATIONS_ALL PLL
                WHERE pd.po_line_id IS NOT NULL
                  AND pd.line_location_id IS NOT NULL
                  AND PD.WIP_ENTITY_ID = p_wip_entity_id
                  AND PD.DESTINATION_ORGANIZATION_ID = p_organization_id
                  AND (p_operation_seq_num is NULL OR
                       PD.WIP_OPERATION_SEQ_NUM = p_operation_seq_num)
                  AND PD.WIP_RESOURCE_SEQ_NUM = p_resource_seq_num /* Bug 5004087 (FP of 4747215)*/
                  AND PH.PO_HEADER_ID = PD.PO_HEADER_ID
                  AND PLL.LINE_LOCATION_ID = PD.LINE_LOCATION_ID
                  AND PR.PO_RELEASE_ID (+) = PD.PO_RELEASE_ID
              -- check cancel flag at shipment level instead of at header level
              -- because PO will cancel upto shipment level
                  AND (pll.cancel_flag IS NULL OR
                       pll.cancel_flag = 'N')
                  AND (PLL.QUANTITY_RECEIVED <
                      (PLL.QUANTITY-PLL.QUANTITY_CANCELLED))
                  AND nvl(pll.closed_code,'OPEN') <> 'FINALLY CLOSED'
                UNION ALL
               SELECT 'PO/REQ Linked'
                 FROM PO_REQUISITION_LINES_ALL PRL
                WHERE PRL.WIP_ENTITY_ID = p_wip_entity_id
                  AND PRL.DESTINATION_ORGANIZATION_ID = p_organization_id
                  AND (p_operation_seq_num is NULL OR
                       PRL.WIP_OPERATION_SEQ_NUM = p_operation_seq_num)
                  AND PRL.WIP_RESOURCE_SEQ_NUM = p_resource_seq_num /* Bug 5004087 (FP of 4747215) */
                  AND nvl(PRL.cancel_flag, 'N') = 'N'
                  AND PRL.LINE_LOCATION_ID is NULL
                UNION ALL
               SELECT 'PO/REQ Linked'
                 FROM PO_REQUISITIONS_INTERFACE_ALL PRI
                WHERE PRI.WIP_ENTITY_ID = p_wip_entity_id
                  AND PRI.DESTINATION_ORGANIZATION_ID = p_organization_id
                  AND (p_operation_seq_num is NULL OR
                       PRI.WIP_OPERATION_SEQ_NUM = p_operation_seq_num)
                  AND PRI.WIP_RESOURCE_SEQ_NUM = p_resource_seq_num /* Bug 5004087 (FP of 4747215) */));

--  l_error_exists boolean := false;
l_warning_exists boolean := false;
l_propagate_job_change_to_po NUMBER;
l_return_status VARCHAR2(1);
l_error_text VARCHAR2(2000);
begin
  SELECT propagate_job_change_to_po
    INTO l_propagate_job_change_to_po
    FROM wip_parameters
   WHERE organization_id = p_organization_id;

  -- There can't be any outside processing going on with the job
  for l_inv_row in c_invalid_rows loop
    IF(po_code_release_grp.Current_Release >=
       po_code_release_grp.PRC_11i_Family_Pack_J  AND
       l_propagate_job_change_to_po = WIP_CONSTANTS.YES) THEN
      -- cancel all PO/requisitions associate to this job/operation
      wip_osp.cancelPOReq(p_job_id        => p_wip_entity_id,
                          p_org_id        => p_organization_id,
                          p_op_seq_num    => p_operation_seq_num,
                          x_return_status => l_return_status);

      IF(l_return_status <> fnd_api. g_ret_sts_success) THEN
        l_warning_exists := true;
        -- If we are unable to cancel all PO/requisition associated to this
        -- job, we will try to cancel as much as we can, then user need to
        -- manually cancel the rest.
        wip_utilities.get_message_stack(p_msg =>l_error_text);
        IF(wip_job_details.std_alone = 1) THEN
          wip_interface_err_Utils.add_error(
            p_interface_id => l_inv_row.interface_id,
            p_text         => substrb(l_error_text,1,500),
            p_error_type   => wip_jdi_utils.msg_warning);
        ELSE
          wip_interface_err_Utils.add_error(
            p_interface_id => wip_jsi_utils.current_interface_id,
            p_text         => substrb(l_error_text,1,500),
            p_error_type   => wip_jdi_utils.msg_warning);
        END IF;
      END IF; -- check return status
    ELSE
      -- propagate_job_change_to_po is manual or customer does not have PO FPJ
      l_warning_exists := true;
      fnd_message.set_name('WIP', 'WIP_DELETE_OSP_RESOURCE');
      l_error_text := fnd_message.get;
      IF(wip_job_details.std_alone = 1) THEN
        wip_interface_err_Utils.add_error(
          p_interface_id => l_inv_row.interface_id,
          p_text         => l_error_text,
          p_error_type   => wip_jdi_utils.msg_warning);
      ELSE
        wip_interface_err_Utils.add_error(
          p_interface_id => wip_jsi_utils.current_interface_id,
          p_text         => l_error_text,
          p_error_type   => wip_jdi_utils.msg_warning);
      END IF;
    END IF; -- propagate_job_change_to_po check
  end loop;

  if(l_warning_exists) then
    update wip_job_dtls_interface wjdi
       set process_status = wip_constants.warning
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type = wip_job_details.wip_resource
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and wjdi.resource_id_old = p_resource_id_old
       -- Bug 4321480 - Modified the exists clause to exclude Cancelled PO/POR.
       and (exists
             ( SELECT 'PO/REQ Linked'
                 FROM PO_RELEASES_ALL PR,
                      PO_HEADERS_ALL PH,
                      PO_DISTRIBUTIONS_ALL PD,
                      PO_LINE_LOCATIONS_ALL PLL
                WHERE pd.po_line_id IS NOT NULL
                  AND pd.line_location_id IS NOT NULL
                  AND PD.WIP_ENTITY_ID = p_wip_entity_id
                  AND PD.DESTINATION_ORGANIZATION_ID = p_organization_id
                  AND (p_operation_seq_num is NULL OR
                       PD.WIP_OPERATION_SEQ_NUM = p_operation_seq_num)
                  AND PD.WIP_RESOURCE_SEQ_NUM = p_resource_seq_num /* Bug 5004087 (FP of 4747215) */
                  AND PH.PO_HEADER_ID = PD.PO_HEADER_ID
                  AND PLL.LINE_LOCATION_ID = PD.LINE_LOCATION_ID
                  AND PR.PO_RELEASE_ID (+) = PD.PO_RELEASE_ID
              -- check cancel flag at shipment level instead of at header level
              -- because PO will cancel upto shipment level
                  AND (pll.cancel_flag IS NULL OR
                       pll.cancel_flag = 'N')
                  AND (PLL.QUANTITY_RECEIVED <
                      (PLL.QUANTITY-PLL.QUANTITY_CANCELLED))
                  AND nvl(pll.closed_code,'OPEN') <> 'FINALLY CLOSED'
                UNION ALL
               SELECT 'PO/REQ Linked'
                 FROM PO_REQUISITION_LINES_ALL PRL
                WHERE PRL.WIP_ENTITY_ID = p_wip_entity_id
                  AND PRL.DESTINATION_ORGANIZATION_ID = p_organization_id
                  AND (p_operation_seq_num is NULL OR
                       PRL.WIP_OPERATION_SEQ_NUM = p_operation_seq_num)
                  AND PRL.WIP_RESOURCE_SEQ_NUM = p_resource_seq_num /* Bug 5004087 (FP of 4747215) */
                  AND nvl(PRL.cancel_flag, 'N') = 'N'
                  AND PRL.LINE_LOCATION_ID is NULL
                UNION ALL
               SELECT 'PO/REQ Linked'
                 FROM PO_REQUISITIONS_INTERFACE_ALL PRI
                WHERE PRI.WIP_ENTITY_ID = p_wip_entity_id
                  AND PRI.DESTINATION_ORGANIZATION_ID = p_organization_id
                  AND (p_operation_seq_num is NULL OR
                       PRI.WIP_OPERATION_SEQ_NUM = p_operation_seq_num)
                  AND PRI.WIP_RESOURCE_SEQ_NUM = p_resource_seq_num /* Bug 5004087 (FP of 4747215) */));

  end if;
end safe_po;


/* main procedure, call the above four */
Procedure Delete_Resource (p_group_id           number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number) IS

   CURSOR res_info (p_group_id          number,
                   p_wip_entity_id      number,
                   p_organization_id    number,
                   p_substitution_type  number) IS
   SELECT distinct operation_seq_num,
          resource_seq_num, resource_id_old, resource_id_new,
          usage_rate_or_amount,
          last_update_date, last_updated_by, creation_date, created_by,
          last_update_login, request_id, program_application_id,
          program_id, program_update_date,
          scheduled_flag, assigned_units, applied_resource_units,
          applied_resource_value, uom_code, basis_type,
          activity_id, autocharge_type, standard_rate_flag,
          start_date, completion_date,attribute_category, attribute1,
          attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,
          attribute8,attribute9,attribute10,attribute11,attribute12,
          attribute13,attribute14,attribute15
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_RESOURCE
      AND substitution_type = p_substitution_type;

BEGIN
    FOR cur_row IN res_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id,
                           p_substitution_type) LOOP

        Del_Res_Info_Exist(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num);

        IF Info_Missing(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num) = 0 THEN

           RES_JOB_Match (p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num,
                   cur_row.resource_id_old);

           IF IS_Error(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num) = 0 THEN

              Safe_Delete (p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num,
                   cur_row.resource_id_old);

              IF IS_Error(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num) = 0 THEN

                 Safe_PO (p_group_id,
                     p_wip_entity_id,
                     p_organization_id,
                     p_substitution_type,
                     cur_row.operation_seq_num,
                     cur_row.resource_seq_num,
                     cur_row.resource_id_old);
              END IF;
           END IF;
        END IF;
    END LOOP;
END Delete_Resource;


/* resource_seq_num, resource_id, usage_rate_or_amount must not be null
   when add resource */
Procedure Add_Res_Info_Exist(p_group_id         number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number,
                        p_operation_seq_num     number) IS

  cursor c_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type = wip_job_details.wip_resource
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and (wjdi.usage_rate_or_amount is null
            or wjdi.resource_id_new is null);

  l_error_exists boolean := false;
begin

  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_JDI_ADD_RES_INFO_MISSING');
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
       and wjdi.load_type = wip_job_details.wip_resource
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and (wjdi.usage_rate_or_amount is null
            or wjdi.resource_id_new is null);
  end if;
end add_res_info_exist;

Procedure val_add_res_dates(p_group_id             number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number,
                        p_operation_seq_num     number,
                        p_resource_seq_num      number,
                        p_resource_id_new       number ) IS


  cursor c_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type in (wip_job_details.wip_resource, wjdi.load_type)
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and wjdi.resource_id_new = p_resource_id_new
       and nvl(wjdi.start_date, sysdate) > nvl(wjdi.completion_date, sysdate);

  l_error_exists boolean := false;
begin

  -- Validate when adding/updating resources
  -- resource dates must be valid
  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_INVALID_RESOURCE_DATES');
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
       and wjdi.load_type in (wip_job_details.wip_resource, wjdi.load_type)
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and wjdi.resource_id_new = p_resource_id_new
       and nvl(wjdi.start_date, sysdate) > nvl(wjdi.completion_date, sysdate);
  end if;

end val_add_res_dates;

Procedure val_change_res_dates(p_group_id             number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number,
                        p_operation_seq_num     number,
                        p_resource_seq_num      number,
                        p_resource_id_old       number ) IS


  cursor c_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type in (wip_job_details.wip_resource, wjdi.load_type)
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and wjdi.resource_id_old = p_resource_id_old
       and (wjdi.start_date is not null
         or wjdi.completion_date is not null)
       and exists
           (select 1
            from wip_operation_resources wor
            where wor.wip_entity_id = wjdi.wip_entity_id
              and wor.organization_id = wjdi.organization_id
              and wor.operation_seq_num = wjdi.operation_seq_num
              and wor.resource_seq_num = wjdi.resource_seq_num
              and wor.resource_id = wjdi.resource_id_old
              and nvl(wjdi.start_date, wor.start_date) > nvl(wjdi.completion_date, wor.completion_date));

  l_error_exists boolean := false;
begin

  -- Validate when adding/updating resources
  -- resource dates must be valid
  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_INVALID_RESOURCE_DATES');
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
       and wjdi.load_type in (wip_job_details.wip_resource, wjdi.load_type)
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and wjdi.resource_id_old = p_resource_id_old
       and (wjdi.start_date is not null
         or wjdi.completion_date is not null)
       and exists
           (select 1
            from wip_operation_resources wor
            where wor.wip_entity_id = wjdi.wip_entity_id
              and wor.organization_id = wjdi.organization_id
              and wor.operation_seq_num = wjdi.operation_seq_num
              and wor.resource_seq_num = wjdi.resource_seq_num
              and wor.resource_id = wjdi.resource_id_old
              and nvl(wjdi.start_date, wor.start_date) > nvl(wjdi.completion_date, wor.completion_date));

  end if;

end val_change_res_dates;

Procedure Valid_Resource(p_group_id             number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number,
                        p_operation_seq_num     number,
                        p_resource_seq_num      number,
                        p_resource_id_new       number ) IS


  cursor c_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi, wip_operations wo
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type in (wip_job_details.wip_resource, wjdi.load_type)
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and wjdi.resource_id_new = p_resource_id_new
       and wo.wip_entity_id = p_wip_entity_id
       and wo.operation_seq_num = p_operation_seq_num
       and wo.organization_id = p_organization_id
       and wo.repetitive_schedule_id is null
       and not (    wjdi.load_type = wip_job_details.wip_resource
                and wjdi.substitution_type = wip_job_details.wip_change
                and wjdi.substitute_group_num is not null
                and wjdi.replacement_group_num is not null
               )
       and (   not exists(select 1
                            from bom_resources br
                           where br.resource_id = p_resource_id_new
                             and (   br.disable_date > sysdate
                                  or br.disable_date is null)
                             and br.organization_id = p_organization_id)
            or not exists(select 1
                            from bom_department_resources bdr
                           where bdr.resource_id = p_resource_id_new
                             and bdr.department_id = wo.department_id)
           );

  l_error_exists boolean := false;
begin

  -- Validate when adding resources
  -- resources to be added must exist in BOM_RESOURCES, not disabled
  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_INVALID_RESOURCE');
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
       and wjdi.load_type in (wip_job_details.wip_resource, wjdi.load_type)
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and wjdi.resource_id_new = p_resource_id_new
        and not (    wjdi.load_type = wip_job_details.wip_resource
                and wjdi.substitution_type = wip_job_details.wip_change
                and wjdi.substitute_group_num is not null
                and wjdi.replacement_group_num is not null
               )
       and (   not exists(select 1
                            from bom_resources br
                           where br.resource_id = p_resource_id_new
                             and (   br.disable_date > sysdate
                                  or br.disable_date is null)
                             and br.organization_id = p_organization_id)
            or not exists(select 1
                            from bom_department_resources bdr, wip_operations wo
                           where bdr.resource_id = p_resource_id_new
                             and wo.wip_entity_id = p_wip_entity_id
                             and wo.operation_seq_num = p_operation_seq_num
                             and wo.organization_id = p_organization_id
                             and wo.repetitive_schedule_id is null
                             and bdr.department_id = wo.department_id)
           );
  end if;
end valid_resource;



Procedure Resource_Seq_Num(p_group_id number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number,
                        p_operation_seq_num     number,
                        p_resource_seq_num      number ) IS

  cursor c_invalid_rows is
    select wjdi.interface_id
      from wip_job_dtls_interface wjdi, wip_job_schedule_interface wjsi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type in (wip_job_details.wip_resource, wip_job_details.wip_sub_res)
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and (   resource_seq_num <= 0
            or exists (select 1
                         from wip_operation_resources wor
                        where wor.wip_entity_id = wjdi.wip_entity_id
                          and wor.organization_id = wjdi.organization_id
                          and wor.operation_seq_num = wjdi.operation_seq_num
                          and wor.resource_seq_num = wjdi.resource_seq_num)
            or exists (select 1
                         from wip_sub_operation_resources wsor
                        where wsor.wip_entity_id = wjdi.wip_entity_id
                          and wsor.organization_id = wjdi.organization_id
                          and wsor.operation_seq_num = wjdi.operation_seq_num
                          and wsor.resource_seq_num = wjdi.resource_seq_num)
           )
       -- Bug#5752548 skip the Resource_Seq_Num validation for setup resources
       -- inserted by ASCP because all existing setup resources would be deleted
       -- before adding new setup resource.
       and wjsi.organization_id = wjdi.organization_id
       and wjsi.group_id = wjdi.group_id
       and wjsi.header_id = wjdi.parent_header_id
       and (wjsi.source_code <> 'MSC' or wjdi.parent_seq_num is null);

  l_error_exists boolean := false;
begin

  -- Validate when adding resources
  -- resource_seq_num must not exist
  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_JDI_RES_SEQ_NUM_EXIST');
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
       and wjdi.load_type in (wip_job_details.wip_resource, wip_job_details.wip_sub_res)
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and (   resource_seq_num <= 0
            or exists (select 1
                         from wip_operation_resources wor
                        where wor.wip_entity_id = wjdi.wip_entity_id
                          and wor.organization_id = wjdi.organization_id
                          and wor.operation_seq_num = wjdi.operation_seq_num
                          and wor.resource_seq_num = wjdi.resource_seq_num)
           );
  end if;
end resource_seq_num;



Procedure Usage_Rate_Or_Amount(p_group_id  number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number,
                        p_operation_seq_num     number,
                        p_resource_seq_num      number,
                        p_resource_id_new       number,
                        p_usage_rate_or_amount  number) IS

  --the logic for invalid rows is actually in pl/sql for this procedure. This cursor
  --just selects all the rows that meet the parameter criteria.
  cursor c_invalid_rows is
    select interface_id, wjdi.usage_rate_or_amount
      from wip_job_dtls_interface wjdi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type in (wip_job_details.wip_resource, wip_job_details.wip_sub_res)
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and wjdi.resource_id_new = p_resource_id_new
       -- jy: no need to do this validation if doing res substitution
       and not (    wjdi.load_type = wip_job_details.wip_resource
                and wjdi.substitution_type = wip_job_details.wip_change
                and wjdi.substitute_group_num is not null
                and wjdi.replacement_group_num is not null
               );

  l_error_exists boolean := false;
  l_hour_uom              varchar2(50);
  l_hour_uom_class        varchar2(200);
  l_uom_time_class_flag   boolean;
  l_uom_class             varchar2(10);
  l_Autocharge_Type       number(38);
begin
  l_hour_uom := FND_PROFILE.value('BOM:HOUR_UOM_CODE');
  l_hour_uom_class := wip_op_resources_utilities.get_uom_class(l_hour_uom);

  select uom.uom_class
    into l_uom_class
    from bom_resources br, mtl_units_of_measure_vl uom
    where br.resource_id =  p_resource_id_new
    and br.unit_of_measure = uom.uom_code;

  if l_hour_uom_class = l_uom_class then
    l_uom_time_class_flag := true;
  else
    l_uom_time_class_flag := false;
  end if;

  select autocharge_type
    into l_autocharge_type
    from bom_resources
    where resource_id = p_resource_id_new;

  if(l_autocharge_type is null) then

    for l_inv_row in c_invalid_rows loop
      l_error_exists := true;
      fnd_message.set_name('WIP', 'WIP_JDI_NULL_CHARGE_TYPE');
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
       and wjdi.load_type in (wip_job_details.wip_resource, wip_job_details.wip_sub_res)
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and wjdi.resource_id_new = p_resource_id_new
       and not (    wjdi.load_type = wip_job_details.wip_resource
                and wjdi.substitution_type = wip_job_details.wip_change
                and wjdi.substitute_group_num is not null
                and wjdi.replacement_group_num is not null
               );

      return;
    end if;
  elsif (p_usage_rate_or_amount < 0 and
         (l_autocharge_type in (3,4) or l_uom_time_class_flag)) then
    for l_inv_row in c_invalid_rows loop
      if(l_inv_row.usage_rate_or_amount = p_usage_rate_or_amount) then
        l_error_exists := true;
        fnd_message.set_name('WIP', 'WIP_JDI_INVALID_RATE');
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
       and wjdi.load_type in (wip_job_details.wip_resource, wip_job_details.wip_sub_res)
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and wjdi.resource_id_new = p_resource_id_new
       and wjdi.usage_rate_or_amount = p_usage_rate_or_amount
       and not (    wjdi.load_type = wip_job_details.wip_resource
                and wjdi.substitution_type = wip_job_details.wip_change
                and wjdi.substitute_group_num is not null
                and wjdi.replacement_group_num is not null
               );
    end if;
  end if;
end usage_rate_or_amount;

Procedure Assigned_Units(p_group_id             number,
                         p_wip_entity_id   number,
                         p_organization_id  number,
                         p_load_type  number,
                         p_substitution_type number,
                         p_operation_seq_num number,
                         p_resource_seq_num number) is

    l_error_exists boolean := false;
    l_maximum_assigned_units number;

    cursor c_invalid_rows is
      select interface_id
        from wip_job_dtls_interface wjdi
       where wjdi.group_id = p_group_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (
                                wip_constants.running,
                                wip_constants.warning)
         and wjdi.wip_entity_id = p_wip_entity_id
         and wjdi.organization_id = p_organization_id
         and wjdi.load_type in (wip_job_details.wip_resource, wip_job_details.wip_sub_res)
         and wjdi.substitution_type = p_substitution_type
         and wjdi.operation_seq_num = p_operation_seq_num
         and wjdi.resource_seq_num = p_resource_seq_num
         and (wjdi.assigned_units <= 0
              or (wjdi.assigned_units is null
                  and wjdi.substitution_type = wip_job_details.wip_add)
              or (wjdi.assigned_units is not null and wjdi.assigned_units <> 1
                and (wjdi.setup_id is not null or exists
                    (select 1
                    from bom_resources br
                    where br.resource_id = nvl(wjdi.resource_id_new, wjdi.resource_id_old)
                      and br.batchable = 1
                    ))
                 )
              -- Bug 5172555
              -- The maximum_assigned_units should not be validated
              -- So commented out the clause
              -- ntungare Thu May 11 05:59:01 PDT 2006
              --
              -- or (wjdi.assigned_units >
              --          nvl(wjdi.maximum_assigned_units, l_maximum_assigned_units))
             );

begin
    if (p_substitution_type = wip_job_details.wip_change) then
      if (p_load_type = WIP_JOB_DETAILS.WIP_RESOURCE) then
        select maximum_assigned_units
          into l_maximum_assigned_units
          from wip_operation_resources
         where wip_entity_id = p_wip_entity_id
           and organization_id = p_organization_id
           and operation_seq_num = p_operation_seq_num
           and resource_seq_num = p_resource_seq_num;
      elsif (p_load_type = WIP_JOB_DETAILS.WIP_SUB_RES) then
        select maximum_assigned_units
          into l_maximum_assigned_units
          from wip_sub_operation_resources
         where wip_entity_id = p_wip_entity_id
           and organization_id = p_organization_id
           and operation_seq_num = p_operation_seq_num
           and resource_seq_num = p_resource_seq_num;
      end if;
    end if;

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
         set wjdi.process_status = wip_constants.error
       where wjdi.group_id = p_group_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (wip_constants.running,
                                wip_constants.warning)
         and wjdi.wip_entity_id = p_wip_entity_id
         and wjdi.organization_id = p_organization_id
         and wjdi.load_type in (wip_job_details.wip_resource, wip_job_details.wip_sub_res)
         and wjdi.substitution_type = p_substitution_type
         and (wjdi.assigned_units <= 0
              or (wjdi.assigned_units is null
                  and wjdi.substitution_type = wip_job_details.wip_add)
              or (wjdi.assigned_units is not null and wjdi.assigned_units <> 1
                and (wjdi.setup_id is not null or exists
                    (select 1
                    from bom_resources br
                    where br.resource_id = nvl(wjdi.resource_id_new, wjdi.resource_id_old)
                    ))
                 )
              -- Bug 5172555
              -- The maximum_assigned_units should not be validated
              -- So commented out the clause
              -- ntungare Thu May 11 05:59:01 PDT 2006
              --
              -- or (wjdi.assigned_units >
              --          nvl(wjdi.maximum_assigned_units, l_maximum_assigned_units))
             );
    end if;

end Assigned_Units;

Procedure Derive_Resource( p_group_id number,
                        p_wip_entity_id number,
                        p_organization_id number,
                        p_substitution_type number,
                        p_operation_seq_num number,
                        p_resource_seq_num in out nocopy number,
                        p_schedule_seq_num in number,
                        p_parent_seq_num in number,
                        p_rowid rowid,
                        p_err_code out nocopy varchar2,
                        p_err_msg out nocopy varchar2) is
  x_setup_id number := null;
  x_res_seq_num_max number := null;
  x_res_seq_num number := null;
  x_schedule_seq_num number;
begin

  if (p_substitution_type = wip_job_details.WIP_ADD) then
    -- default res_seq_num to be max existing res_seq_num + 10
    if (p_resource_seq_num is null) then
      begin
	select nvl(max(resource_seq_num), 0)
          into x_res_seq_num_max
          from wip_operation_resources
         where wip_entity_id = p_wip_entity_id
           AND organization_id = p_organization_id
           AND operation_seq_num = p_operation_seq_num;
      exception
        when no_data_found then
          x_res_seq_num_max := 0;
      end;

      begin
        select nvl(max(resource_seq_num), 0)
          into x_res_seq_num
          from WIP_JOB_DTLS_INTERFACE
         where group_id = p_group_id
           and wip_entity_id = p_wip_entity_id
           and organization_id = p_organization_id
           and operation_seq_num = p_operation_seq_num
           and substitution_type = p_substitution_type;
      exception
        when no_data_found then
          x_res_seq_num := 0;
      end;

      if x_res_seq_num_max < x_res_seq_num then
         x_res_seq_num_max := x_res_seq_num;
      end if;

      x_res_seq_num_max := x_res_seq_num_max + 10;

      UPDATE WIP_JOB_DTLS_INTERFACE
      SET    resource_seq_num = x_res_seq_num_max
      WHERE  rowid = p_rowid;

      p_resource_seq_num := x_res_seq_num_max;

    end if;
    /* Bug 4747951. For setup resource, get the schedule_seq_num
       of parent resource from interface if it exists since this
       will be the latest */
    if (p_parent_seq_num is not null) then
      begin
        begin
          select schedule_seq_num
                  into x_schedule_seq_num
                  from wip_job_dtls_interface
                 where group_id = p_group_id
                   and wip_entity_id = p_wip_entity_id
                   and organization_id = p_organization_id
             and operation_seq_num = p_operation_seq_num
             and resource_seq_num = p_parent_seq_num
             and load_type = 1
             and substitution_type in (2,3);
        exception
          when others then x_schedule_seq_num := 0;
        end;
        if (x_schedule_seq_num = 0) then
          begin
            select schedule_seq_num
              into x_schedule_seq_num
                    from wip_operation_resources
                   where wip_entity_id = p_wip_entity_id
                     AND organization_id = p_organization_id
                     AND operation_seq_num = p_operation_seq_num
                     AND resource_seq_num = p_parent_seq_num;
                exception
                  when no_data_found then
                    raise FND_API.G_EXC_UNEXPECTED_ERROR;
          end;
        end if;
      end;
      UPDATE WIP_JOB_DTLS_INTERFACE
      SET    schedule_seq_num = x_schedule_seq_num
      WHERE  rowid = p_rowid;

    end if;
  elsif (p_substitution_type = wip_job_details.WIP_CHANGE) then
    begin
      select setup_id
        into x_setup_id
        from wip_operation_resources
       where wip_entity_id = p_wip_entity_id
         AND  organization_id = p_organization_id
         AND  operation_seq_num = p_operation_seq_num
         AND  resource_seq_num = p_resource_seq_num;
    exception
      when no_data_found then
        return;
    end;

    UPDATE WIP_JOB_DTLS_INTERFACE
    SET   setup_id = nvl(setup_id, x_setup_id)
    WHERE  rowid = p_rowid;

  end if;

exception
    when others then
      p_err_msg := 'WIPRSVDB.pls<Procedure derive_resource>:' || SQLERRM;
      p_err_code := SQLCODE;

end Derive_Resource;


/* main procedure to add resource, call the above */
Procedure Add_Resource(p_group_id               number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number) IS

x_err_code      varchar2(30) := null;
x_err_msg       varchar2(240) := NULL;

   CURSOR res_info (p_group_id          number,
                   p_wip_entity_id      number,
                   p_organization_id    number,
                   p_substitution_type  number) IS
   SELECT distinct operation_seq_num,
          resource_seq_num, resource_id_old, resource_id_new,
          usage_rate_or_amount,
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
          substitute_group_num, replacement_group_num, parent_seq_num, rowid
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_RESOURCE
      AND substitution_type = p_substitution_type;

BEGIN

    FOR cur_row IN res_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id,
                           p_substitution_type) LOOP

        derive_resource(p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.resource_seq_num,
                        cur_row.schedule_seq_num,
                        cur_row.parent_seq_num,
                        cur_row.rowid,
                        x_err_code,
                        x_err_msg);

        Add_Res_Info_Exist(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num);

        IF Info_Missing(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num) = 0 THEN

           Valid_Resource(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num,
                   cur_row.resource_id_new);

           IF IS_Error(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num)= 0 THEN

            val_add_res_dates(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num,
                   cur_row.resource_id_new);

            IF IS_Error(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num)= 0 THEN

              Resource_Seq_Num(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num);

              IF IS_Error(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num)= 0 THEN

                 Usage_Rate_Or_Amount(p_group_id,
                    p_wip_entity_id,
                    p_organization_id,
                    p_substitution_type,
                    cur_row.operation_seq_num,
                    cur_row.resource_seq_num,
                    cur_row.resource_id_new,
                    cur_row.usage_rate_or_amount);

                  IF IS_Error(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num)= 0 THEN

                   Assigned_Units(p_group_id,
                    p_wip_entity_id,
                    p_organization_id,
                    WIP_JOB_DETAILS.WIP_RESOURCE,
                    p_substitution_type,
                    cur_row.operation_seq_num,
                    cur_row.resource_seq_num);

                   IF IS_Error(p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.resource_seq_num) = 0 THEN

                       Check_res_sched_subgroup (p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.resource_seq_num,
                        cur_row.schedule_seq_num,
                        cur_row.substitute_group_num,
                        cur_row.replacement_group_num);

                   IF IS_Error(p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.resource_seq_num) = 0 THEN
                       WIP_RESOURCE_DEFAULT.Default_Resource(
                        p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.resource_seq_num,
                        cur_row.resource_id_new,
                        x_err_code,
                        x_err_msg);
                   END IF;
                 END IF;
                END IF;
              END IF;
            END IF;
           END IF;
        END IF;
    END LOOP;
END Add_Resource;

/* check for valid assigned units when changing resource assign units, it must be either
   equal to number of resource instances unless if no resource instance is defined
*/
Procedure Validate_Assigned_Units(p_group_id        number,
                   p_wip_entity_id              number,
                   p_organization_id            number,
                   p_substitution_type          number,
                   p_operation_seq_num          number,
                   p_resource_seq_num           number) IS

  l_error_exists boolean := false;
  l_count number;

  cursor c_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type = wip_job_details.wip_resource
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and (wjdi.assigned_units < 0 or
            (nvl(wjdi.assigned_units,-1) <> l_count and l_count > 0));

BEGIN
  l_count := 0;
  begin
     select count(*) into l_count
                from wip_op_resource_instances
                where wip_entity_id = p_wip_entity_id
                  and organization_id = p_organization_id
                  and operation_seq_num = p_operation_seq_num
                  and resource_seq_num = p_resource_seq_num;
  exception
    when no_data_found then
       null;
  end;

  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_ASSIGNED_UNITS_ERROR');
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
       and wjdi.load_type in (wip_job_details.wip_resource)
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and (wjdi.assigned_units < 0 or
            (wjdi.assigned_units <> l_count and l_count > 0));
    end if;
END Validate_Assigned_Units;

Procedure Chng_Res_Info_Exist(p_group_id          number,
                              p_wip_entity_id     number,
                              p_organization_id   number,
                              p_substitution_type number,
                              p_operation_seq_num number) IS
  cursor c_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type in (wip_job_details.wip_resource, wip_job_details.wip_sub_res)
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and (   wjdi.resource_seq_num is null
            or wjdi.resource_id_old is null
            or wjdi.resource_id_new is null
            or (    wjdi.resource_id_old <> nvl(wjdi.resource_id_new, wjdi.resource_id_old)
                and wjdi.usage_rate_or_amount is null
               )
           );

  l_error_exists boolean := false;
BEGIN
  /* we don't check up to usage_rate_or_amount since we assume up to
     resource_id_old and resource_id_new, it should be unique */
  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_JDI_CHNG_RES_INFO_MISSING');
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
       and wjdi.load_type in (wip_job_details.wip_resource, wip_job_details.wip_sub_res)
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and (   wjdi.resource_seq_num is null
            or wjdi.resource_id_old is null
            or wjdi.resource_id_new is null
            or (    wjdi.resource_id_old <> nvl(wjdi.resource_id_new, wjdi.resource_id_old)
                and wjdi.usage_rate_or_amount is null
               )
           );
    end if;
END Chng_Res_Info_Exist;

/* jy - Checks the validity of rows that change resources.  There are two types of
   transactions.  The first is to just change an existing resource in
   wip_operation_resources.  The second is to substitute a
   resource in WOR with one in WSOR.  To indicate a substitution:
   1) The substitution_group_num column must be either null or have the valid
      value for that res_seq_num/id.
   2) The replacement_group_num must be a valid value in WSOR (if it is the
      same as the one in WOR then nothing happens).
   First, we try to determine if a record is a valid substitution.  If it contains
   wrong values for sub/repl group, it errors.  If it doesn't contain wrong
   information but is not a substitution, we clear the two columns and validate it for   a normal resource change.
   Note that with this validation, we don't allow users to change the sub/repl
   group of a resource through the dtls interface table.
*/

Procedure Change_Resource(p_group_id               number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number) IS

x_err_code      number := 0;
x_err_msg       varchar2(240) := NULL;
l_sub_group_num number;
l_repl_group_num number;

   CURSOR res_info (p_group_id          number,
                   p_wip_entity_id      number,
                   p_organization_id    number,
                   p_substitution_type  number) IS
   SELECT distinct operation_seq_num,
          resource_seq_num, resource_id_old, resource_id_new,
          usage_rate_or_amount,
          last_update_date, last_updated_by, creation_date, created_by,
          last_update_login, request_id, program_application_id,
          program_id, program_update_date,
          scheduled_flag, assigned_units, applied_resource_units,
          applied_resource_value, uom_code, basis_type,
          activity_id, autocharge_type, standard_rate_flag,
          start_date, completion_date,attribute_category, attribute1,
          attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,
          attribute8,attribute9,attribute10,attribute11,attribute12,
          attribute13,attribute14,attribute15,
          schedule_seq_num, substitute_group_num,
          replacement_group_num, parent_seq_num, rowid
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_RESOURCE
      AND substitution_type = p_substitution_type;

BEGIN
    FOR cur_row IN res_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id,
                           p_substitution_type) LOOP

       derive_resource(p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.resource_seq_num,
                        cur_row.schedule_seq_num,
                        cur_row.parent_seq_num,
                        cur_row.rowid,
                        x_err_code,
                        x_err_msg);

        Chng_Res_Info_Exist(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num);

        IF Info_Missing(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num) = 0 THEN
           RES_JOB_Match (p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num,
                   cur_row.resource_id_old);

           IF IS_Error(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num) = 0 THEN
              /* fix for bug# 2043593 */
              If (cur_row.resource_id_old <> cur_row.resource_id_new) then
                 Safe_Delete (p_group_id,
                      p_wip_entity_id,
                      p_organization_id,
                      p_substitution_type,
                      cur_row.operation_seq_num,
                      cur_row.resource_seq_num,
                      cur_row.resource_id_old);
              End if;

              IF IS_Error(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num) = 0 THEN
                 Safe_PO (p_group_id,
                    p_wip_entity_id,
                    p_organization_id,
                    p_substitution_type,
                    cur_row.operation_seq_num,
                    cur_row.resource_seq_num,
                    cur_row.resource_id_old);

                 IF IS_Error(p_group_id,
                      p_wip_entity_id,
                      p_organization_id,
                      p_substitution_type,
                      cur_row.operation_seq_num,
                      cur_row.resource_seq_num) = 0 THEN
                     Valid_Resource(p_group_id,
                      p_wip_entity_id,
                      p_organization_id,
                      p_substitution_type,
                      cur_row.operation_seq_num,
                      cur_row.resource_seq_num,
                      cur_row.resource_id_new);

                  IF IS_Error(p_group_id,
                          p_wip_entity_id,
                          p_organization_id,
                          p_substitution_type,
                          cur_row.operation_seq_num,
                          cur_row.resource_seq_num)= 0 THEN

                   val_change_res_dates(p_group_id,
                          p_wip_entity_id,
                          p_organization_id,
                          p_substitution_type,
                          cur_row.operation_seq_num,
                          cur_row.resource_seq_num,
                          cur_row.resource_id_old);

                    IF IS_Error(p_group_id,
                       p_wip_entity_id,
                       p_organization_id,
                       p_substitution_type,
                       cur_row.operation_seq_num,
                       cur_row.resource_seq_num) = 0 THEN

                       Usage_Rate_Or_Amount(p_group_id,
                          p_wip_entity_id,
                          p_organization_id,
                          p_substitution_type,
                          cur_row.operation_seq_num,
                          cur_row.resource_seq_num,
                          cur_row.resource_id_new,
                          cur_row.usage_rate_or_amount);

                      IF IS_Error(p_group_id,
                       p_wip_entity_id,
                       p_organization_id,
                       p_substitution_type,
                       cur_row.operation_seq_num,
                       cur_row.resource_seq_num)= 0 THEN

                       Assigned_Units(p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        WIP_JOB_DETAILS.WIP_RESOURCE,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.resource_seq_num);

                       IF IS_Error(p_group_id,
                                p_wip_entity_id,
                                p_organization_id,
                                p_substitution_type,
                                cur_row.operation_seq_num,
                                cur_row.resource_seq_num) = 0 THEN
                      Check_res_sched_subgroup (p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.resource_seq_num,
                        cur_row.schedule_seq_num,
                        cur_row.substitute_group_num,
                        cur_row.replacement_group_num);

                       IF IS_Error(p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.resource_seq_num)= 0 THEN
                         Validate_Assigned_Units(p_group_id,
                           p_wip_entity_id,
                           p_organization_id,
                           p_substitution_type,
                           cur_row.operation_seq_num,
                           cur_row.resource_seq_num);

                       IF IS_Error(p_group_id,
                            p_wip_entity_id,
                            p_organization_id,
                            p_substitution_type,
                            cur_row.operation_seq_num,
                            cur_row.resource_seq_num) = 0 THEN
                              WIP_RESOURCE_DEFAULT.Default_Resource(
                                   p_group_id,
                                   p_wip_entity_id,
                                   p_organization_id,
                                   p_substitution_type,
                                   cur_row.operation_seq_num,
                                   cur_row.resource_seq_num,
                                   cur_row.resource_id_new,
                                   x_err_code,
                                   x_err_msg);
                           END IF;
                         END IF;
                       END IF;
                      END IF;
                    END IF;
                  END IF;
                END IF;
              END IF;
           END IF;
        END IF;
    END LOOP;
END Change_Resource;

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
           AND load_type        = WIP_JOB_DETAILS.WIP_RESOURCE
           AND substitution_type= p_substitution_type
           AND operation_seq_num= p_operation_seq_num
           AND resource_seq_num = p_resource_seq_num;


        IF x_count <> 0 THEN
           return 1;
        ELSE return 0;
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
           AND load_type        = WIP_JOB_DETAILS.WIP_RESOURCE
           AND substitution_type= p_substitution_type
           AND operation_seq_num= p_operation_seq_num
           AND (resource_seq_num IS NULL
            OR  resource_id_old IS NULL);

    ELSIF p_substitution_type = WIP_JOB_DETAILS.WIP_ADD THEN
        SELECT count(*)
          INTO x_count
          FROM WIP_JOB_DTLS_INTERFACE
         WHERE group_id         = p_group_id
           AND process_status   = WIP_CONSTANTS.ERROR
           AND wip_entity_id    = p_wip_entity_id
           AND organization_id  = p_organization_id
           AND load_type        = WIP_JOB_DETAILS.WIP_RESOURCE
           AND substitution_type= p_substitution_type
           AND operation_seq_num= p_operation_seq_num
           AND (resource_id_new IS NULL
            OR  usage_rate_or_amount IS NULL);

    ELSIF p_substitution_type = WIP_JOB_DETAILS.WIP_CHANGE THEN
        SELECT count(*)
          INTO x_count
          FROM WIP_JOB_DTLS_INTERFACE
         WHERE group_id         = p_group_id
           AND process_status   = WIP_CONSTANTS.ERROR
           AND wip_entity_id    = p_wip_entity_id
           AND organization_id  = p_organization_id
           AND load_type        = WIP_JOB_DETAILS.WIP_RESOURCE
           AND substitution_type= p_substitution_type
           AND operation_seq_num= p_operation_seq_num
           AND (resource_seq_num IS NULL
            OR  resource_id_old IS NULL
            OR  resource_id_new IS NULL
            OR  usage_rate_or_amount IS NULL);

    END IF;

        IF x_count <> 0 THEN
           return 1;
        ELSE return 0;
        END IF;

END Info_Missing;



Procedure Delete_Sub_Resource (p_group_id           number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number) IS

   CURSOR res_info (p_group_id          number,
                   p_wip_entity_id      number,
                   p_organization_id    number,
                   p_substitution_type  number) IS
   SELECT distinct operation_seq_num,
          resource_seq_num, resource_id_old, resource_id_new,
          usage_rate_or_amount,
          last_update_date, last_updated_by, creation_date, created_by,
          last_update_login, request_id, program_application_id,
          program_id, program_update_date,
          scheduled_flag, assigned_units, applied_resource_units,
          applied_resource_value, uom_code, basis_type,
          activity_id, autocharge_type, standard_rate_flag,
          start_date, completion_date,attribute_category, attribute1,
          attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,
          attribute8,attribute9,attribute10,attribute11,attribute12,
          attribute13,attribute14,attribute15
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_SUB_RES
      AND substitution_type = p_substitution_type;

BEGIN
    FOR cur_row IN res_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id,
                           p_substitution_type) LOOP

        Del_Res_Info_Exist(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num);

        IF Info_Missing(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num) = 0 THEN

           RES_JOB_Match (p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num,
                   cur_row.resource_id_old);

        END IF;
    END LOOP;
END Delete_Sub_Resource;

/* jy - checks for a valid resource substitution row. */
Procedure Check_Res_Substitution(p_group_id        number,
                      p_wip_entity_id              number,
                      p_organization_id            number,
                      p_substitution_type          number,
                      p_operation_seq_num          number,
                      p_resource_seq_num           number,
                      p_resource_id_old            number) IS

    cursor c_invalid_rows is
      select interface_id
        from wip_job_dtls_interface wjdi
       where wjdi.group_id = p_group_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (wip_constants.running,
                                     wip_constants.warning)
         and wjdi.wip_entity_id = p_wip_entity_id
         and wjdi.organization_id = p_organization_id
         and wjdi.load_type = wip_job_details.wip_resource
         and wjdi.substitution_type = p_substitution_type
         and wjdi.operation_seq_num = p_operation_seq_num
         and wjdi.resource_seq_num = p_resource_seq_num
         and wjdi.resource_id_old = p_resource_id_old
         and (   (    wjdi.substitute_group_num is not null
                  and not exists (select 1
                           from wip_operation_resources wor
                          where wor.wip_entity_id = wjdi.wip_entity_id
                            and wor.organization_id = wjdi.organization_id
                            and wor.resource_id = wjdi.resource_id_old
                            and wor.operation_seq_num = wjdi.operation_seq_num
                            and wor.resource_seq_num = wjdi.resource_seq_num
                            and wor.substitute_group_num = wjdi.substitute_group_num
                        )
                 )
              or (   wjdi.replacement_group_num is not null
                  and not exists (select 1
                            from wip_sub_operation_resources wsor,
                                 wip_operation_resources wor
                           where wsor.wip_entity_id = wjdi.wip_entity_id
                             and wsor.organization_id = wjdi.organization_id
                             and wsor.operation_seq_num = wjdi.operation_seq_num
                             and wor.wip_entity_id = wjdi.wip_entity_id
                             and wor.organization_id = wjdi.organization_id
                             and wor.resource_id = wjdi.resource_id_old
                             and wor.operation_seq_num = wjdi.operation_seq_num
                             and wor.resource_seq_num = wjdi.resource_seq_num
                             and wsor.substitute_group_num = nvl(wjdi.substitute_group_num, wor.substitute_group_num)
                             and wsor.replacement_group_num = wjdi.replacement_group_num
                         )
                  and not exists (select 1
                           from wip_operation_resources wor
                          where wor.wip_entity_id = wjdi.wip_entity_id
                            and wor.organization_id = wjdi.organization_id
                            and wor.resource_id = wjdi.resource_id_old
                            and wor.operation_seq_num = wjdi.operation_seq_num
                            and wor.resource_seq_num = wjdi.resource_seq_num
                            and ( (wor.substitute_group_num =
                                     nvl(wjdi.substitute_group_num,wor.substitute_group_num)) OR
                                  (wor.substitute_group_num is null and
                                   wjdi.substitute_group_num is null)
                                )
                            and wor.replacement_group_num = wjdi.replacement_group_num
                          )
                 )
             );

    cursor c_not_sub_rows is
      select wjdi.substitute_group_num,
             wjdi.replacement_group_num
        from wip_job_dtls_interface wjdi
       where wjdi.group_id = p_group_id
         and wjdi.process_phase = wip_constants.ml_validation
         and wjdi.process_status in (wip_constants.running,
                                     wip_constants.warning)
         and wjdi.wip_entity_id = p_wip_entity_id
         and wjdi.organization_id = p_organization_id
         and wjdi.load_type = wip_job_details.wip_resource
         and wjdi.substitution_type = p_substitution_type
         and wjdi.operation_seq_num = p_operation_seq_num
         and wjdi.resource_seq_num = p_resource_seq_num
         and wjdi.resource_id_old = p_resource_id_old
         and (   wjdi.replacement_group_num is null
              or (    wjdi.replacement_group_num is not null
                  and exists (select 1
                           from wip_operation_resources wor
                          where wor.wip_entity_id = wjdi.wip_entity_id
                            and wor.organization_id = wjdi.organization_id
                            and wor.resource_id = wjdi.resource_id_old
                            and wor.operation_seq_num = wjdi.operation_seq_num
                            and wor.resource_seq_num = wjdi.resource_seq_num
                            and ( (wor.substitute_group_num =
                                     nvl(wjdi.substitute_group_num, wor.substitute_group_num)) OR
                                  (wor.substitute_group_num is null and
                                   wjdi.substitute_group_num is null)
                                )
                            and wor.replacement_group_num = wjdi.replacement_group_num
                          )
                  )
             )
         for update;

    cursor c_sub_rows is
      select wip_entity_id,
             organization_id,
             resource_id_old,
             operation_seq_num,
             resource_seq_num,
             substitute_group_num
        from wip_job_dtls_interface
       where group_id = p_group_id
         and process_phase = wip_constants.ml_validation
         and process_status in (wip_constants.running,
                                     wip_constants.warning)
         and wip_entity_id = p_wip_entity_id
         and organization_id = p_organization_id
         and load_type = wip_job_details.wip_resource
         and substitution_type = p_substitution_type
         and operation_seq_num = p_operation_seq_num
         and resource_seq_num = p_resource_seq_num
         and resource_id_old = p_resource_id_old
         and replacement_group_num is not null
        for update;

    l_error_exists boolean := false;
    l_sub_group_temp number;


BEGIN

  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP','WIP_JDI_RES_SUB_INFO_MISSING' );
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
         and wjdi.load_type = wip_job_details.wip_resource
         and wjdi.substitution_type = p_substitution_type
         and wjdi.operation_seq_num = p_operation_seq_num
         and wjdi.resource_seq_num = p_resource_seq_num
         and wjdi.resource_id_old = p_resource_id_old
         and (   (    wjdi.substitute_group_num is not null
                  and not exists (select 1
                           from wip_operation_resources wor
                          where wor.wip_entity_id = wjdi.wip_entity_id
                            and wor.organization_id = wjdi.organization_id
                            and wor.resource_id = wjdi.resource_id_old
                            and wor.operation_seq_num = wjdi.operation_seq_num
                            and wor.resource_seq_num = wjdi.resource_seq_num
                            and wor.substitute_group_num = wjdi.substitute_group_num
                        )
                 )
              or (   wjdi.replacement_group_num is not null
                  and not exists (select 1
                            from wip_sub_operation_resources wsor,
                                 wip_operation_resources wor
                           where wsor.wip_entity_id = wjdi.wip_entity_id
                             and wsor.organization_id = wjdi.organization_id
                             and wsor.operation_seq_num = wjdi.operation_seq_num
                             and wor.wip_entity_id = wjdi.wip_entity_id
                             and wor.organization_id = wjdi.organization_id
                             and wor.resource_id = wjdi.resource_id_old
                             and wor.operation_seq_num = wjdi.operation_seq_num
                             and wor.resource_seq_num = wjdi.resource_seq_num
                             and wsor.substitute_group_num = nvl(wjdi.substitute_group_num, wor.substitute_group_num)
                             and wsor.replacement_group_num = wjdi.replacement_group_num
                         )
                 )
             );
    RETURN;
  end if;

  for l_ns_row in c_not_sub_rows loop
    update wip_job_dtls_interface wjdi
      set substitute_group_num = null,
          replacement_group_num = null
      where current of c_not_sub_rows;
  end loop;

  for l_sub_row in c_sub_rows loop
    if l_sub_row.substitute_group_num is null then
      select wor.substitute_group_num
        into l_sub_group_temp
        from wip_operation_resources wor
       where wor.wip_entity_id = l_sub_row.wip_entity_id
         and wor.organization_id = l_sub_row.organization_id
         and wor.resource_id = l_sub_row.resource_id_old
         and wor.operation_seq_num = l_sub_row.operation_seq_num
         and wor.resource_seq_num = l_sub_row.resource_seq_num;
      update wip_job_dtls_interface
         set substitute_group_num = l_sub_group_temp
         where current of c_sub_rows;
    end if;
  end loop;

END Check_Res_Substitution;

Procedure Substitute_Info (p_group_id              number,
                     p_wip_entity_id               number,
                     p_organization_id             number,
                     p_substitution_type           number,
                     p_operation_seq_num           number,
                     p_resource_seq_num            number) IS
  cursor c_invalid_rows is
    select interface_id
      from wip_job_dtls_interface wjdi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type = wip_job_details.wip_sub_res
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and (   wjdi.schedule_seq_num < 0
            or wjdi.substitute_group_num is null
            or wjdi.substitute_group_num < 0
            or wjdi.replacement_group_num is null
            or wjdi.replacement_group_num < 0
            or not exists (select 1
                             from wip_operation_resources wor
                            where wor.wip_entity_id = wjdi.wip_entity_id
                              and wor.organization_id = wjdi.organization_id
                              and wor.operation_seq_num = wjdi.operation_seq_num
                              and wor.substitute_group_num = wjdi.substitute_group_num)
            or exists (select 1
                         from wip_operation_resources wor
                        where wor.wip_entity_id = wjdi.wip_entity_id
                          and wor.organization_id = wjdi.organization_id
                          and wor.operation_seq_num = wjdi.operation_seq_num
                          and wor.substitute_group_num = wjdi.substitute_group_num
                          and wor.replacement_group_num = wjdi.replacement_group_num)
           );

  l_error_exists boolean := false;
begin

  for l_inv_row in c_invalid_rows loop
    l_error_exists := true;
    fnd_message.set_name('WIP', 'WIP_JDI_RES_SUB_INFO_MISSING');
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
       and wjdi.load_type = wip_job_details.wip_sub_res
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and (   wjdi.schedule_seq_num is null
            or wjdi.schedule_seq_num < 0
            or wjdi.substitute_group_num is null
            or wjdi.substitute_group_num < 0
            or wjdi.replacement_group_num is null
            or wjdi.replacement_group_num < 0
            or not exists (select 1
                             from wip_operation_resources wor
                            where wor.wip_entity_id = wjdi.wip_entity_id
                              and wor.organization_id = wjdi.organization_id
                              and wor.operation_seq_num = wjdi.operation_seq_num
                              and wor.substitute_group_num = wjdi.substitute_group_num)
            or exists (select 1
                         from wip_operation_resources wor
                        where wor.wip_entity_id = wjdi.wip_entity_id
                          and wor.organization_id = wjdi.organization_id
                          and wor.operation_seq_num = wjdi.operation_seq_num
                          and wor.substitute_group_num = wjdi.substitute_group_num
                          and wor.replacement_group_num = wjdi.replacement_group_num)
           );
  end if;
end substitute_info;



Procedure Add_Sub_Resource(p_group_id               number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number) IS

   x_err_code      varchar2(30) := null;
   x_err_msg       varchar2(240) := NULL;

   CURSOR res_info (p_group_id          number,
                   p_wip_entity_id      number,
                   p_organization_id    number,
                   p_substitution_type  number) IS
   SELECT distinct operation_seq_num,
          resource_seq_num, resource_id_old, resource_id_new,
          usage_rate_or_amount,
          last_update_date, last_updated_by, creation_date, created_by,
          last_update_login, request_id, program_application_id,
          program_id, program_update_date,
          scheduled_flag, assigned_units, applied_resource_units,
          applied_resource_value, uom_code, basis_type,
          activity_id, autocharge_type, standard_rate_flag,
          start_date, completion_date,attribute_category, attribute1,
          attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,
          attribute8,attribute9,attribute10,attribute11,attribute12,
          attribute13,attribute14,attribute15,schedule_seq_num,
          substitute_group_num, replacement_group_num, parent_seq_num, rowid
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_SUB_RES
      AND substitution_type = p_substitution_type;


BEGIN
    FOR cur_row IN res_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id,
                           p_substitution_type) LOOP

        derive_resource(p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.resource_seq_num,
                        cur_row.schedule_seq_num,
                        cur_row.parent_seq_num,
                        cur_row.rowid,
                        x_err_code,
                        x_err_msg);

        Add_Res_Info_Exist(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num);

        IF Info_Missing(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num) = 0 THEN

           Valid_Resource(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num,
                   cur_row.resource_id_new);

           IF IS_Error(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num)= 0 THEN

              Resource_Seq_Num(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num);

              IF IS_Error(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num)= 0 THEN

                 Usage_Rate_Or_Amount(p_group_id,
                    p_wip_entity_id,
                    p_organization_id,
                    p_substitution_type,
                    cur_row.operation_seq_num,
                    cur_row.resource_seq_num,
                    cur_row.resource_id_new,
                    cur_row.usage_rate_or_amount);

                  IF IS_Error(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num)= 0 THEN

                   Assigned_Units(p_group_id,
                    p_wip_entity_id,
                    p_organization_id,
                    WIP_JOB_DETAILS.WIP_SUB_RES,
                    p_substitution_type,
                    cur_row.operation_seq_num,
                    cur_row.resource_seq_num);

                 IF IS_Error(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num)= 0 THEN

                   Substitute_Info(p_group_id,
                     p_wip_entity_id,
                     p_organization_id,
                     p_substitution_type,
                     cur_row.operation_seq_num,
                     cur_row.resource_seq_num);

                   IF IS_Error(p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.resource_seq_num) = 0 THEN

                       Check_sub_sched_subgroup (p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.resource_seq_num,
                        cur_row.schedule_seq_num,
                        cur_row.substitute_group_num,
                        cur_row.replacement_group_num);

                   IF IS_Error(p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.resource_seq_num) = 0 THEN

                    WIP_RESOURCE_DEFAULT.Default_Resource(
                        p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.resource_seq_num,
                        cur_row.resource_id_new,
                        x_err_code,
                        x_err_msg);
                      END IF;
                   END IF;
                  END IF;
                 END IF;
              END IF;
           END IF;
        END IF;
    END LOOP;
END Add_Sub_Resource;


Procedure Change_Sub_Resource(p_group_id               number,
                        p_wip_entity_id         number,
                        p_organization_id       number,
                        p_substitution_type     number) IS

x_err_code      number := 0;
x_err_msg       varchar2(240) := NULL;
   CURSOR res_info (p_group_id          number,
                   p_wip_entity_id      number,
                   p_organization_id    number,
                   p_substitution_type  number) IS
   SELECT distinct operation_seq_num,
          resource_seq_num, resource_id_old, resource_id_new,
          usage_rate_or_amount,
          last_update_date, last_updated_by, creation_date, created_by,
          last_update_login, request_id, program_application_id,
          program_id, program_update_date,
          scheduled_flag, assigned_units, applied_resource_units,
          applied_resource_value, uom_code, basis_type,
          activity_id, autocharge_type, standard_rate_flag,
          start_date, completion_date,attribute_category, attribute1,
          attribute2,attribute3,attribute4,attribute5,attribute6,attribute7,
          attribute8,attribute9,attribute10,attribute11,attribute12,
          attribute13,attribute14,attribute15,schedule_seq_num,
          substitute_group_num, replacement_group_num
     FROM WIP_JOB_DTLS_INTERFACE
    WHERE group_id = p_group_id
      AND process_phase = WIP_CONSTANTS.ML_VALIDATION
      AND process_status in (WIP_CONSTANTS.RUNNING,WIP_CONSTANTS.WARNING)
      AND wip_entity_id = p_wip_entity_id
      AND organization_id = p_organization_id
      AND load_type = WIP_JOB_DETAILS.WIP_SUB_RES
      AND substitution_type = p_substitution_type;


BEGIN
    FOR cur_row IN res_info(p_group_id,
                           p_wip_entity_id,
                           p_organization_id,
                           p_substitution_type) LOOP

        Chng_Res_Info_Exist(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num);

        IF Info_Missing(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num) = 0 THEN
           RES_JOB_Match (p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num,
                   cur_row.resource_id_old);

           IF IS_Error(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num) = 0 THEN
              Safe_Delete (p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num,
                   cur_row.resource_id_old);

              IF IS_Error(p_group_id,
                   p_wip_entity_id,
                   p_organization_id,
                   p_substitution_type,
                   cur_row.operation_seq_num,
                   cur_row.resource_seq_num) = 0 THEN

                 Valid_Resource(p_group_id,
                      p_wip_entity_id,
                      p_organization_id,
                      p_substitution_type,
                      cur_row.operation_seq_num,
                      cur_row.resource_seq_num,
                      cur_row.resource_id_new);

                 IF IS_Error(p_group_id,
                    p_wip_entity_id,
                    p_organization_id,
                    p_substitution_type,
                    cur_row.operation_seq_num,
                    cur_row.resource_seq_num) = 0 THEN

                    Substitute_Info(p_group_id,
                       p_wip_entity_id,
                       p_organization_id,
                       p_substitution_type,
                       cur_row.operation_seq_num,
                       cur_row.resource_seq_num);

                    IF IS_Error(p_group_id,
                       p_wip_entity_id,
                       p_organization_id,
                       p_substitution_type,
                       cur_row.operation_seq_num,
                       cur_row.resource_seq_num) = 0 THEN

                       Usage_Rate_Or_Amount(p_group_id,
                          p_wip_entity_id,
                          p_organization_id,
                          p_substitution_type,
                          cur_row.operation_seq_num,
                          cur_row.resource_seq_num,
                          cur_row.resource_id_new,
                          cur_row.usage_rate_or_amount);

                    IF IS_Error(p_group_id,
                     p_wip_entity_id,
                     p_organization_id,
                     p_substitution_type,
                     cur_row.operation_seq_num,
                     cur_row.resource_seq_num)= 0 THEN

                     Assigned_Units(p_group_id,
                     p_wip_entity_id,
                     p_organization_id,
                     WIP_JOB_DETAILS.WIP_SUB_RES,
                     p_substitution_type,
                     cur_row.operation_seq_num,
                     cur_row.resource_seq_num);

                       IF IS_Error(p_group_id,
                                p_wip_entity_id,
                                p_organization_id,
                                p_substitution_type,
                                cur_row.operation_seq_num,
                                cur_row.resource_seq_num) = 0 THEN

                       Check_sub_sched_subgroup (p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.resource_seq_num,
                        cur_row.schedule_seq_num,
                        cur_row.substitute_group_num,
                        cur_row.replacement_group_num);

                   IF IS_Error(p_group_id,
                        p_wip_entity_id,
                        p_organization_id,
                        p_substitution_type,
                        cur_row.operation_seq_num,
                        cur_row.resource_seq_num) = 0 THEN

                          WIP_RESOURCE_DEFAULT.Default_Resource(
                                   p_group_id,
                                   p_wip_entity_id,
                                   p_organization_id,
                                   p_substitution_type,
                                   cur_row.operation_seq_num,
                                   cur_row.resource_seq_num,
                                   cur_row.resource_id_new,
                                   x_err_code,
                                   x_err_msg);
                           END IF;
                       END IF;
                      END IF;
                    END IF;
                 END IF;
              END IF;
           END IF;
        END IF;
    END LOOP;
END Change_Sub_Resource;


Procedure check_res_sched_subgroup (p_group_id  number,
                        p_wip_entity_id         number,
                        p_organization_id      number,
                        p_substitution_type  number,
                        p_operation_seq_num     number,
                        p_resource_seq_num      number,
                        p_schedule_seq_num     number,
                        p_substitute_group_num number,
                        p_replacement_group_num number) IS
  cursor sched_rows is
    select *
      from wip_job_dtls_interface wjdi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type = wip_job_details.wip_resource
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and ( (wjdi.schedule_seq_num = p_schedule_seq_num)
            or (wjdi.schedule_seq_num is null and p_schedule_seq_num is null))
       and ( (wjdi.substitute_group_num = p_substitute_group_num)
            or (wjdi.substitute_group_num is null and p_substitute_group_num is null))
       and ( (wjdi.replacement_group_num = p_replacement_group_num)
            or (wjdi.replacement_group_num is null and p_replacement_group_num is null))
       for update;

    status VARCHAR2(1);
    sim_exists BOOLEAN;
    sched_seq NUMBER;
    sub_group NUMBER;
    repl_group NUMBER;
    l_res_sub number := 0;
BEGIN
     for sched_row in sched_rows loop
         if ((sched_row.substitute_group_num <= 0) OR
              (sched_row.schedule_seq_num <= 0) OR
              (sched_row.replacement_group_num <= 0 AND
               p_substitution_type = WIP_JOB_DETAILS.WIP_ADD)) then
               /*Bug 5227753 - Added AND condition above for p_substitution_type in replacement group check*/
                 fnd_message.set_name('WIP', 'WIP_JDI_INVALID_SCHED_SUB');
                 fnd_message.set_token('INTERFACE', to_char(sched_row.interface_id));
                 if(wip_job_details.std_alone = 1) then
                     wip_interface_err_Utils.add_error(p_interface_id => sched_row.interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
                 else
                     wip_interface_err_Utils.add_error(p_interface_id => wip_jsi_utils.current_interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
                 end if;

                update wip_job_dtls_interface
                        set process_status = wip_constants.error
                 where current of sched_rows;

                return;
         end if;

         if (sched_row.substitution_type = wip_job_details.wip_add) then
              if (sched_row.substitute_group_num is not null) then
                     begin
                          select distinct replacement_group_num
                             into repl_group
                            from wip_operation_resources
                        where wip_entity_id = p_wip_entity_id
                             and repetitive_schedule_id is null
                             and operation_seq_num = p_operation_seq_num
                             and substitute_group_num = sched_row.substitute_group_num;
                     exception
                        when no_data_found then
                                 repl_group := 1;
                     end;

                     update wip_job_dtls_interface
                             set replacement_group_num = repl_group
                      where current of sched_rows;
              else
                     update wip_job_dtls_interface
                             set replacement_group_num = null
                      where current of sched_rows;
              end if;
         elsif (sched_row.substitution_type = wip_job_details.wip_change) then
               select schedule_seq_num,
                           substitute_group_num,
                           replacement_group_num
                  into sched_seq,
                           sub_group,
                           repl_group
                 from wip_operation_resources
               where wip_entity_id = p_wip_entity_id
                    and repetitive_schedule_id is null
                    and operation_seq_num = p_operation_seq_num
                    and resource_seq_num = p_resource_seq_num;

               if (sched_row.schedule_seq_num is null) then
                     update wip_job_dtls_interface
                            set  schedule_seq_num = sched_seq
                      where current of sched_rows;
               end if;

               if (sched_row.substitute_group_num = fnd_api.g_miss_num) then
                     update wip_job_dtls_interface
                             set replacement_group_num = fnd_api.g_miss_num
                      where current of sched_rows;
               elsif (sched_row.substitute_group_num is not null) then
                     l_res_sub := 0;

                     if (sched_row.substitute_group_num = sub_group) then
                         -- check if this is a resource substitution; if it is, leave it alone
                         begin
                           select 1
                             into l_res_sub
                             from dual
                            where exists (select 1
                                           from wip_sub_operation_resources
                                          where wip_entity_id = p_wip_entity_id
                                            and operation_seq_num = p_operation_seq_num
                                            and substitute_group_num = sub_group
                                            and replacement_group_num = sched_row.replacement_group_num);
                         exception
                            when others then
                               null;
                         end;
                     end if;

                     if (l_res_sub = 0) then
                         begin
                             select distinct replacement_group_num
                                into repl_group
                              from wip_operation_resources
                           where wip_entity_id = p_wip_entity_id
                               and repetitive_schedule_id is null
                               and operation_seq_num = p_operation_seq_num
                               and substitute_group_num = sched_row.substitute_group_num;
                         exception
                          when no_data_found then
                                   repl_group := 1;
                         end;

                         update wip_job_dtls_interface
                                set replacement_group_num = repl_group
                           where current of sched_rows;
                     end if;
              else
                     update wip_job_dtls_interface
                             set replacement_group_num = repl_group,
                                    substitute_group_num = sub_group
                      where current of sched_rows;
              end if;
         end if;
    end loop;
end check_res_sched_subgroup;

Procedure check_sub_sched_subgroup (p_group_id  number,
                        p_wip_entity_id         number,
                        p_organization_id      number,
                        p_substitution_type  number,
                        p_operation_seq_num     number,
                        p_resource_seq_num      number,
                        p_schedule_seq_num     number,
                        p_substitute_group_num number,
                        p_replacement_group_num number) IS
  cursor sched_rows is
    select *
      from wip_job_dtls_interface wjdi
     where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type = wip_job_details.wip_sub_res
       and wjdi.substitution_type = p_substitution_type
       and wjdi.operation_seq_num = p_operation_seq_num
       and wjdi.resource_seq_num = p_resource_seq_num
       and ( (wjdi.schedule_seq_num = p_schedule_seq_num)
            or (wjdi.schedule_seq_num is null and p_schedule_seq_num is null))
       and ( (wjdi.substitute_group_num = p_substitute_group_num)
            or (wjdi.substitute_group_num is null and p_substitute_group_num is null))
       and ( (wjdi.replacement_group_num = p_replacement_group_num)
            or (wjdi.replacement_group_num is null and p_replacement_group_num is null))
      for update;

    status VARCHAR2(1);
    sim_exists BOOLEAN;
    sched_seq NUMBER;
    sub_group NUMBER;
    repl_group NUMBER;
    p_count NUMBER;
begin
     for sched_row in sched_rows loop
         if ((sched_row.substitute_group_num <= 0) OR
              (sched_row.schedule_seq_num <= 0) OR
              (sched_row.replacement_group_num <= 0 AND
               p_substitution_type = WIP_JOB_DETAILS.WIP_ADD)) then
               /*Bug 5227753 - Added AND condition above for p_substitution_type in replacement group check*/
             fnd_message.set_name('WIP', 'WIP_JDI_INVALID_SCHED_SUB');
                 fnd_message.set_token('INTERFACE', to_char(sched_row.interface_id));
                 if(wip_job_details.std_alone = 1) then
                     wip_interface_err_Utils.add_error(p_interface_id => sched_row.interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
                 else
                     wip_interface_err_Utils.add_error(p_interface_id => wip_jsi_utils.current_interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
                 end if;

                update wip_job_dtls_interface
                        set process_status = wip_constants.error
                 where current of sched_rows;

                return;
         end if;

         if (sched_row.substitution_type = wip_job_details.wip_add) then
              if (sched_row.substitute_group_num is null) then
                 fnd_message.set_name('WIP', 'WIP_JDI_ALT_SUB_MISSING');
                 fnd_message.set_token('INTERFACE', to_char(sched_row.interface_id));
                 if(wip_job_details.std_alone = 1) then
                     wip_interface_err_Utils.add_error(p_interface_id => sched_row.interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
                 else
                     wip_interface_err_Utils.add_error(p_interface_id => wip_jsi_utils.current_interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
                 end if;

                update wip_job_dtls_interface
                        set process_status = wip_constants.error
                 where current of sched_rows;

                return;
              end if;
         elsif (sched_row.substitution_type = wip_job_details.wip_change) then
               select schedule_seq_num,
                           substitute_group_num,
                           replacement_group_num
                  into sched_seq,
                           sub_group,
                           repl_group
                 from wip_sub_operation_resources
               where wip_entity_id = p_wip_entity_id
                    and repetitive_schedule_id is null
                    and operation_seq_num = p_operation_seq_num
                    and resource_seq_num = p_resource_seq_num;

               if (sched_row.schedule_seq_num is null) then
                     update wip_job_dtls_interface
                            set  schedule_seq_num = sched_seq
                      where current of sched_rows;
               end if;

               if (sched_row.substitute_group_num = fnd_api.g_miss_num) then
                    -- not allowed to erase the sub/repl group of an existing alt res
                    update wip_job_dtls_interface
                       set substitute_group_num = sub_group,
                           replacement_group_num = repl_group
                      where current of sched_rows;
               elsif (sched_row.substitute_group_num is not null) then
                    if ((sched_row.substitute_group_num <> sub_group) AND
                          (sched_row.replacement_group_num is null)) then
                         fnd_message.set_name('WIP', 'WIP_JDI_ALT_SUB_MISSING');
                         fnd_message.set_token('INTERFACE', to_char(sched_row.interface_id));
                         if(wip_job_details.std_alone = 1) then
                              wip_interface_err_Utils.add_error(p_interface_id => sched_row.interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
                         else
                              wip_interface_err_Utils.add_error(p_interface_id => wip_jsi_utils.current_interface_id,
                                        p_text         => substr(fnd_message.get,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
                         end if;

                         update wip_job_dtls_interface
                                 set process_status = wip_constants.error
                           where current of sched_rows;

                         return;
                    end if;
               end if;
         end if;
    end loop;
end check_sub_sched_subgroup;

Procedure Check_Sub_Groups (p_group_id NUMBER,
                                                               p_organization_id NUMBER,
                                                               p_wip_entity_id NUMBER) IS
    cursor c_invalid_rows (p_operation_seq_num NUMBER) is
      select interface_id
      from wip_job_dtls_interface wjdi
      where wjdi.group_id = p_group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type in (wip_job_details.wip_resource, wip_job_details.wip_sub_res)
       and wjdi.operation_seq_num = p_operation_seq_num;

      l_op_seq NUMBER;
      l_status VARCHAR2(1);
      l_error_msg VARCHAR2(2000);
BEGIN
     wip_op_resources_utilities.validate_sub_groups(p_wip_entity_id, null, l_status, l_error_msg, l_op_seq);

     if (l_status = fnd_api.g_ret_sts_error) then
         for l_inv_row in c_invalid_rows(l_op_seq) loop
             if(wip_job_details.std_alone = 1) then
                 wip_interface_err_Utils.add_error(p_interface_id => l_inv_row.interface_id,
                                        p_text         => substr(l_error_msg,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
             else
                 wip_interface_err_Utils.add_error(p_interface_id => wip_jsi_utils.current_interface_id,
                                        p_text         => substr(l_error_msg,1,500),
                                        p_error_type   => wip_jdi_utils.msg_error);
             end if;
        end loop;

       update wip_job_dtls_interface wjdi
               set wjdi.process_status = wip_constants.error
          where wjdi.group_id = p_group_id
           and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status in (wip_constants.running,
                                   wip_constants.warning)
       and wjdi.wip_entity_id = p_wip_entity_id
       and wjdi.organization_id = p_organization_id
       and wjdi.load_type in (wip_job_details.wip_resource, wip_job_details.wip_sub_res)
       and wjdi.operation_seq_num = l_op_seq;

       return;
     end if;

     wip_op_resources_utilities.delete_orphaned_alternates(p_wip_entity_id, null, l_status);
END Check_Sub_Groups;

END WIP_RESOURCE_VALIDATIONS;

/
