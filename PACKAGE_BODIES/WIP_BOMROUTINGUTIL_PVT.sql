--------------------------------------------------------
--  DDL for Package Body WIP_BOMROUTINGUTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_BOMROUTINGUTIL_PVT" as
 /* $Header: wipbmrub.pls 120.14.12010000.9 2010/04/05 08:17:41 pfauzdar ship $ */

  g_pkgName constant varchar2(30) := 'wip_bomRoutingUtil_pvt';

  procedure explodeRouting(p_orgID       in number,
                           p_wipEntityID in number,
                           p_repSchedID  in number,
                           p_itemID      in number,
                           p_altRouting  in varchar2,
                           p_routingRevDate in date,
                           p_qty         in number,
                           p_startDate   in date,
                           p_endDate     in date,
                           x_serStartOp   out nocopy number,
                           x_returnStatus out nocopy varchar2,
                           x_errorMsg     out nocopy varchar2) is
    l_params wip_logger.param_tbl_t;
    l_procName varchar2(30) := 'explodeRouting';
    l_logLevel number := to_number(fnd_log.g_current_runtime_level);
    l_retStatus varchar2(1);
    l_msg varchar2(240);

    l_routingSeqID number;
    l_excludeECO number;
    l_maxSeq number;

    cursor op_attachments(p_org_id number, p_wip_entity_id number) is
      select wo.operation_seq_num,
             wo.operation_sequence_id
        from wip_operations wo
       where wo.organization_id = p_org_id
         and wo.wip_entity_id = p_wip_entity_id
         and exists (select fad.pk1_value
                       from fnd_attached_documents fad
                      where fad.pk1_value = to_char(wo.operation_sequence_id)
                        and fad.entity_name = 'BOM_OPERATION_SEQUENCES');
  begin
    x_returnStatus := fnd_api.g_ret_sts_success;
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_orgID';
      l_params(1).paramValue := p_orgID;
      l_params(2).paramName := 'p_wipEntityID';
      l_params(2).paramValue := p_wipEntityID;
      l_params(3).paramName := 'p_repSchedID';
      l_params(3).paramValue := p_repSchedID;
      l_params(4).paramName := 'p_itemID';
      l_params(4).paramValue := p_itemID;
      l_params(5).paramName := 'p_altRouting';
      l_params(5).paramValue := p_altRouting;
      l_params(6).paramName := 'p_routingRevDate';
      l_params(6).paramValue := p_routingRevDate;
      l_params(7).paramName := 'p_qty';
      l_params(7).paramValue := p_qty;
      l_params(8).paramName := 'p_startDate';
      l_params(8).paramValue := p_startDate;
      l_params(9).paramName := 'p_endDate';
      l_params(9).paramValue := p_endDate;
      wip_logger.entryPoint(p_procName     => g_pkgName || '.' || l_procName,
                            p_params       => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    begin
      select common_routing_sequence_id,
             serialization_start_op
        into l_routingSeqID,
             x_serStartOp
        from bom_operational_routings
       where organization_id = p_orgID
         and assembly_item_id = p_itemID
         and nvl(alternate_routing_designator, '@@@^@@@') = nvl(p_altRouting, '@@@^@@@')
         and nvl(cfm_routing_flag, 2) = 2;
    exception
      when NO_DATA_FOUND then
        if(l_logLevel <= wip_constants.trace_logging) then
           wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                                p_procReturnStatus => 'true',
                                p_msg              => 'this item does not have a routing',
                                x_returnStatus     => l_retStatus);
          wip_logger.cleanup(l_retStatus);
        end if;
        return;
    end;

    l_excludeECO := fnd_profile.value('WIP_RELEASED_REVS');

    if ( l_logLevel <= wip_constants.full_logging ) then
      wip_logger.log('exclude ECO is: ' || l_excludeECO, l_retStatus);
      wip_logger.log('RoutingSeqID is: ' || l_routingSeqID, l_retStatus);
    end if;

    insert into wip_operations
      (wip_entity_id,
       operation_seq_num,
       organization_id,
       repetitive_schedule_id,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       operation_sequence_id,
       department_id,
       scheduled_quantity,
       quantity_in_queue,
       quantity_running,
       quantity_waiting_to_move,
       quantity_rejected,
       quantity_scrapped,
       quantity_completed,
       cumulative_scrap_quantity,
       count_point_type,
       backflush_flag,
       minimum_transfer_quantity,
       first_unit_start_date,
       first_unit_completion_date,
       last_unit_start_date,
       last_unit_completion_date,
       standard_operation_id,
       description,
       long_description,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15,
							check_skill)
    select p_wipEntityID,
           bos.operation_seq_num,
           p_orgID,
           p_repSchedID,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           fnd_global.login_id,
           fnd_global.conc_request_id,
           fnd_global.prog_appl_id,
           fnd_global.conc_program_id,
           sysdate,
           min(bos.operation_sequence_id),
           bos.department_id,
           round(p_qty, 6),
           0, 0, 0, 0, 0, 0, 0,
           bos.count_point_type,
           bos.backflush_flag,
           nvl(bos.minimum_transfer_quantity, 0),
           p_startDate, p_endDate,
           p_startDate, p_endDate,
           bos.standard_operation_id,
           bos.operation_description,
           bos.long_description,
           bos.attribute_category,
           bos.attribute1,
           bos.attribute2,
           bos.attribute3,
           bos.attribute4,
           bos.attribute5,
           bos.attribute6,
           bos.attribute7,
           bos.attribute8,
           bos.attribute9,
           bos.attribute10,
           bos.attribute11,
           bos.attribute12,
           bos.attribute13,
           bos.attribute14,
           bos.attribute15,
											nvl(bos.check_skill,2)
      from bom_operation_sequences bos
     where bos.routing_sequence_id = l_routingSeqID
       and nvl(bos.operation_type, 1) = 1
       and bos.effectivity_date <= p_routingRevDate
       and nvl(bos.disable_date, p_routingRevDate+1) >= p_routingRevDate
       and (   bos.implementation_date is not null
            or exists (select 1
                         from eng_revised_items eng
                        where eng.change_notice = bos.change_notice
                          and eng.organization_id = p_orgID
                          and eng.routing_sequence_id = l_routingSeqID
                          and ((eng.status_type in (4, 7) and l_excludeECO = 1) or
                               (eng.status_type in (1, 4, 7) and l_excludeECO = 2))))
      and not exists (select 1
                        from bom_operation_sequences bos2
                       where bos2.routing_sequence_id = bos.routing_sequence_id
                         and bos2.effectivity_date <= p_routingRevDate
                         and bos2.operation_seq_num = bos.operation_seq_num
                         and exists
                              (select 1
                                from eng_revised_items eng
                               where eng.change_notice = bos2.change_notice
                                 and eng.organization_id = p_orgID
                                 and eng.routing_sequence_id = l_routingSeqID
                                 and ((eng.status_type in (4, 7) and l_excludeECO = 1) or
                                      (eng.status_type in (1, 4, 7) and l_excludeECO = 2)))
                         and bos2.acd_type = 3)
    group by bos.operation_seq_num,
             bos.department_id, bos.count_point_type, bos.backflush_flag, bos.minimum_transfer_quantity,
             p_orgID, p_wipEntityID, p_repSchedID, p_qty, p_startDate, p_endDate, sysdate, fnd_global.user_id,
             fnd_global.login_id, fnd_global.conc_request_id, fnd_global.prog_appl_id,
             fnd_global.conc_program_id, bos.standard_operation_id, bos.operation_description,
             bos.long_description, bos.attribute_category, bos.attribute1, bos.attribute2,
             bos.attribute3, bos.attribute4, bos.attribute5, bos.attribute6, bos.attribute7, bos.attribute8,
             bos.attribute9, bos.attribute10, bos.attribute11, bos.attribute12, bos.attribute13,
             bos.attribute14, bos.attribute15, bos.check_skill;


    update wip_operations wo
       set previous_operation_seq_num = (select max(operation_seq_num)
                                           from wip_operations
                                          where wip_entity_id = p_wipEntityID
                                            and organization_id = p_orgID
                                            and operation_seq_num < wo.operation_seq_num),
           next_operation_seq_num = (select min(operation_seq_num)
                                       from wip_operations
                                      where wip_entity_id = p_wipEntityID
                                        and organization_id = p_orgID
                                        and operation_seq_num > wo.operation_seq_num)
     where wo.wip_entity_id = p_wipEntityID
       and wo.organization_id = p_orgID;

    if ( l_logLevel <= wip_constants.full_logging ) then
      wip_logger.log('begin to load resources', l_retStatus);
    end if;


    insert into wip_operation_resources
      (wip_entity_id,
       operation_seq_num,
       resource_seq_num,
       organization_id,
       repetitive_schedule_id,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       resource_id,
       uom_code,
       basis_type,
       usage_rate_or_amount,
       activity_id,
       scheduled_flag,
       assigned_units,
       autocharge_type,
       standard_rate_flag,
       applied_resource_units,
       applied_resource_value,
       start_date,
       completion_date,
       schedule_seq_num,
       substitute_group_num,
       replacement_group_num,
       principle_flag,
       setup_id,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15)
    select p_wipEntityID,
           bos.operation_seq_num,
           bor.resource_seq_num,
           p_orgID,
           p_repSchedID,
           sysdate,
           fnd_global.user_id,
           sysdate,
           fnd_global.user_id,
           fnd_global.login_id,
           fnd_global.conc_request_id,
           fnd_global.prog_appl_id,
           fnd_global.conc_program_id,
           sysdate,
           bor.resource_id,
           br.unit_of_measure,
           bor.basis_type,
           bor.usage_rate_or_amount,
           bor.activity_id,
           bor.schedule_flag,
           bor.assigned_units,
           bor.autocharge_type,
           bor.standard_rate_flag,
           0, 0,
           p_startDate,
           p_endDate,
           bor.schedule_seq_num,
           bor.substitute_group_num,
           0,
           bor.principle_flag,
           bor.setup_id,
           bor.attribute_category,
           bor.attribute1,
           bor.attribute2,
           bor.attribute3,
           bor.attribute4,
           bor.attribute5,
           bor.attribute6,
           bor.attribute7,
           bor.attribute8,
           bor.attribute9,
           bor.attribute10,
           bor.attribute11,
           bor.attribute12,
           bor.attribute13,
           bor.attribute14,
           bor.attribute15
      from bom_operation_sequences bos,
           bom_operation_resources bor,
           bom_resources br
     where bos.routing_sequence_id = l_routingSeqID
       and bos.effectivity_date <= p_routingRevDate
       and nvl(bos.disable_date, p_routingRevDate+1) >= p_routingRevDate
       and bos.operation_sequence_id = bor.operation_sequence_id
       and bor.resource_id = br.resource_id
       and nvl(bor.acd_type, 0) <> 3
       and bos.effectivity_date =
                    (select max(effectivity_date)
                       from bom_operation_sequences bos2,
                            bom_operation_resources bor2
                      where bos2.routing_sequence_id = l_routingSeqID
                        and bos2.operation_sequence_id = bor2.operation_sequence_id
                        and bos2.operation_seq_num = bos.operation_seq_num
                        and bor2.resource_seq_num = bor.resource_seq_num
                        and nvl(bos2.operation_type, 1) = 1
                        and bos2.effectivity_date <= p_routingRevDate
                        and (   bos2.implementation_date is not null
                             or exists (select 1
                                          from eng_revised_items eng
                                         where eng.change_notice = bos2.change_notice
                                           and eng.organization_id = p_orgID
                                           and eng.routing_sequence_id = l_routingSeqID
                                           and ((eng.status_type in (4, 7) and l_excludeECO = 1) or
                                                (eng.status_type in (1, 4, 7) and l_excludeECO = 2)))));

    if ( l_logLevel <= wip_constants.full_logging ) then
      wip_logger.log('begin to load substitute resources', l_retStatus);
    end if;

    select max(resource_seq_num)
      into l_maxSeq
      from wip_operation_resources
     where organization_id = p_orgID
       and wip_entity_id = p_wipEntityID;


    insert into wip_sub_operation_resources
      (wip_entity_id,
       operation_seq_num,
       resource_seq_num,
       organization_id,
       repetitive_schedule_id,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       request_id,
       program_application_id,
       program_id,
       program_update_date,
       resource_id,
       uom_code,
       basis_type,
       usage_rate_or_amount,
       activity_id,
       scheduled_flag,
       assigned_units,
       autocharge_type,
       standard_rate_flag,
       applied_resource_units,
       applied_resource_value,
       start_date,
       completion_date,
       schedule_seq_num,
       substitute_group_num,
       replacement_group_num,
       principle_flag,
       setup_id,
       attribute_category,
       attribute1,
       attribute2,
       attribute3,
       attribute4,
       attribute5,
       attribute6,
       attribute7,
       attribute8,
       attribute9,
       attribute10,
       attribute11,
       attribute12,
       attribute13,
       attribute14,
       attribute15)
    select wo.wip_entity_id,
           wo.operation_seq_num,
           l_maxSeq + ROWNUM,
           wo.organization_id,
           wo.repetitive_schedule_id,
           wo.last_update_date,
           wo.last_updated_by,
           wo.creation_date,
           wo.created_by,
           wo.last_update_login,
           wo.request_id,
           wo.program_application_id,
           wo.program_id,
           wo.program_update_date,
           bsor.resource_id,
           br.unit_of_measure,
           bsor.basis_type,
           bsor.usage_rate_or_amount,
           bsor.activity_id,
           bsor.schedule_flag,
           bsor.assigned_units,
           bsor.autocharge_type,
           bsor.standard_rate_flag,
           0, 0,
           wo.first_unit_start_date,
           wo.last_unit_completion_date,
           bsor.schedule_seq_num,
           bsor.substitute_group_num,
           bsor.replacement_group_num,
           bsor.principle_flag,
           bsor.setup_id,
           bsor.attribute_category,
           bsor.attribute1,
           bsor.attribute2,
           bsor.attribute3,
           bsor.attribute4,
           bsor.attribute5,
           bsor.attribute6,
           bsor.attribute7,
           bsor.attribute8,
           bsor.attribute9,
           bsor.attribute10,
           bsor.attribute11,
           bsor.attribute12,
           bsor.attribute13,
           bsor.attribute14,
           bsor.attribute15
      from bom_resources br,
           bom_sub_operation_resources bsor,
           wip_operations wo
     where wo.organization_id = p_orgID
       and wo.wip_entity_id = p_wipEntityID
       and wo.operation_sequence_id = bsor.operation_sequence_id
       and bsor.resource_id = br.resource_id
       and nvl(bsor.acd_type, 0) <> 3;

    if ( l_logLevel <= wip_constants.full_logging ) then
      wip_logger.log('begin to load attachment', l_retStatus);
    end if;


    FOR op_attach IN op_attachments(p_orgID, p_wipEntityID) LOOP
      fnd_attached_documents2_pkg.copy_attachments(
        x_from_entity_name => 'BOM_OPERATION_SEQUENCES',
        x_from_pk1_value => to_char(op_attach.operation_sequence_id),
        x_to_entity_name => 'WIP_DISCRETE_OPERATIONS',
        x_to_pk1_value => to_char(p_wipEntityID),
        x_to_pk2_value => to_char(op_attach.operation_seq_num),
        x_to_pk3_value => to_char(p_orgID),
        x_created_by => fnd_global.user_id,
        x_last_update_login => fnd_global.login_id,
        x_program_application_id => fnd_global.prog_appl_id,
        x_program_id => fnd_global.conc_program_id,
        x_request_id => fnd_global.conc_request_id);
    END LOOP;

    /* Added for 12.1.1 Skills Validation project.*/
    if ( l_logLevel <= wip_constants.full_logging ) then
      wip_logger.log('begin to load competence', l_retStatus);
    end if;

    DELETE FROM WIP_OPERATION_COMPETENCIES
    WHERE WIP_ENTITY_ID = p_wipEntityID
    AND ORGANIZATION_ID = p_orgID;


    INSERT INTO WIP_OPERATION_COMPETENCIES
        (LEVEL_ID,          ORGANIZATION_ID,
         WIP_ENTITY_ID,           OPERATION_SEQ_NUM, OPERATION_SEQUENCE_ID,
         STANDARD_OPERATION_ID,   COMPETENCE_ID,     RATING_LEVEL_ID,
         QUALIFICATION_TYPE_ID,   LAST_UPDATE_DATE,  LAST_UPDATED_BY,
         LAST_UPDATE_LOGIN,       CREATED_BY,        CREATION_DATE)
    SELECT
         3,                    WO.ORGANIZATION_ID,
         WO.WIP_ENTITY_ID,               WO.OPERATION_SEQ_NUM, BOS.OPERATION_SEQUENCE_ID,
         BOS.STANDARD_OPERATION_ID,      BOS.COMPETENCE_ID,    BOS.RATING_LEVEL_ID,
         BOS.QUALIFICATION_TYPE_ID,      WO.LAST_UPDATE_DATE,  WO.LAST_UPDATED_BY,
         WO.LAST_UPDATE_LOGIN,           WO.CREATED_BY,        WO.CREATION_DATE
    FROM BOM_OPERATION_SKILLS BOS,
         WIP_OPERATIONS WO,
         WIP_ENTITIES WE
    WHERE
         WE.WIP_ENTITY_ID = WO.WIP_ENTITY_ID
         AND WO.ORGANIZATION_ID = WO.ORGANIZATION_ID
         AND WE.ENTITY_TYPE = 1
         AND WO.ORGANIZATION_ID = p_orgID
         AND WO.WIP_ENTITY_ID = p_wipEntityID
         AND WO.ORGANIZATION_ID = BOS.ORGANIZATION_ID
         AND BOS.OPERATION_SEQUENCE_ID = WO.OPERATION_SEQUENCE_ID
         AND BOS.LEVEL_ID = 2;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
    end if;
  exception
  when others then
    if(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'unexp error:' || SQLERRM,
                           x_returnStatus     => l_retStatus);
    end if;
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.add_exc_msg(p_pkg_name => g_pkgName,
                            p_procedure_name => l_procName,
                            p_error_text => SQLERRM);
    wip_utilities.get_message_stack(p_msg => l_msg);
    x_errorMsg := substrb(l_msg, 1, 240);
  end explodeRouting;


  procedure explodeBOM(p_orgID       in number,
                       p_wipEntityID in number,
                       p_jobType     in number,
                       p_repSchedID  in number,
                       p_itemID      in number,
                       p_altBOM      in varchar2,
                       p_bomRevDate  in date,
                       p_altRouting  in varchar2,
                       p_routingRevDate in date,
                       p_qty         in number,
                       p_jobStartDate in date,
                       p_projectID   in number,
                       p_taskID      in number,
		       p_unitNumber  in varchar2 DEFAULT '', /* added for bug 5332615 */
                       x_returnStatus out nocopy varchar2,
                       x_errorMsg     out nocopy varchar2) is
    l_procName varchar2(30) := 'explodeBOM';
    l_params wip_logger.param_tbl_t;
    l_logLevel number := to_number(fnd_log.g_current_runtime_level);
    l_retStatus varchar2(1);
    l_msg varchar2(240);

    l_compTbl system.wip_component_tbl_t;
    l_mrpFlag number;
    l_count number;

    l_entityType number;
    l_usePhantomRouting number;
    l_minOp number;
    l_exists number;
    l_opSeq number;
    l_multipleFactor number;

    l_diff_basis number;
    l_basis number;
    l_wro_op number;

    cursor c_phantoms is
      select inventory_item_id,
             -1*operation_seq_num operation_seq_num
        from wip_requirement_operations
       where organization_id = p_orgID
         and wip_entity_id = p_wipEntityID
         and nvl(repetitive_schedule_id, -1) = nvl(p_repSchedID, -1)
         and operation_seq_num < 0
         and wip_supply_type = wip_constants.phantom;

  begin
    x_returnStatus := fnd_api.g_ret_sts_success;
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_orgID';
      l_params(1).paramValue := p_orgID;
      l_params(2).paramName := 'p_wipEntityID';
      l_params(2).paramValue := p_wipEntityID;
      l_params(3).paramName := 'p_jobType';
      l_params(3).paramValue := p_jobType;
      l_params(4).paramName := 'p_repSchedID';
      l_params(4).paramValue := p_repSchedID;
      l_params(5).paramName := 'p_itemID';
      l_params(5).paramValue := p_itemID;
      l_params(6).paramName := 'p_altBOM';
      l_params(6).paramValue := p_altBOM;
      l_params(7).paramName := 'p_bomRevDate';
      l_params(7).paramValue := p_bomRevDate;
      l_params(8).paramName := 'p_altRouting';
      l_params(8).paramValue := p_altRouting;
      l_params(9).paramName := 'p_routingRevDate';
      l_params(9).paramValue := p_routingRevDate;
      l_params(10).paramName := 'p_qty';
      l_params(10).paramValue := p_qty;
      l_params(11).paramName := 'p_jobStartDate';
      l_params(11).paramValue := p_jobStartDate;
      l_params(12).paramName := 'p_projectID';
      l_params(12).paramValue := p_projectID;
      l_params(13).paramName := 'p_taskID';
      l_params(13).paramValue := p_taskID;
      wip_logger.entryPoint(p_procName     => g_pkgName || '.' || l_procName,
                            p_params       => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    l_entityType := wip_constants.discrete;
    if ( p_repSchedID is not null ) then
      l_entityType := wip_constants.repetitive;
    end if;

    l_mrpFlag := wip_constants.yes;
    /*If non-standard job, set mrpFlag based on WIP: Enable MRP Net for Non-standard Job Requirements profile value for bug 7719689 (FP of bug 7506349) */
    if ( p_jobType = wip_constants.nonstandard ) then
       l_mrpFlag := TO_NUMBER(FND_PROFILE.value('WIP_NON_STD_MRP_NET')); /*code changed for bug 7719689 (FP of bug 7506349) */
    end if;

  /*
    wip_bflProc_priv.explodeRequirements(
                       p_itemID => p_itemID,
                       p_orgID => p_orgID,
                       p_qty => 1,
                       p_altBomDesig => p_altBOM,
                       p_altOption => 2,
                       p_bomRevDate => p_bomRevDate,
                       p_txnDate => null,
                       p_projectID => p_projectID,
                       p_taskID => p_taskID,
                       p_initMsgList => fnd_api.g_false,
                       p_endDebug => fnd_api.g_false,
                       x_compTbl => l_compTbl,
                       x_returnStatus => x_returnStatus);
   */

    wip_flowUtil_priv.explodeRequirementsAndDefault(
                       p_assyID => p_itemID,
                       p_orgID => p_orgID,
                       p_qty => 1,
                       p_altBomDesig => p_altBOM,
                       p_altOption => 2,
                       p_bomRevDate => p_bomRevDate,
                       p_txnDate => p_jobStartDate,
		       p_implFlag => 2,    /* for bug 5383135 */
                       p_projectID => p_projectID,
                       p_taskID => p_taskID,
                       p_toOpSeqNum => null,
                       p_altRoutDesig => p_altRouting,
                       p_txnFlag => false, /* for bug4538135 */ /* ER 4369064 */
		       p_unitNumber => p_unitNumber, /* added for bug 5332615 */
                       x_compTbl => l_compTbl,
                       x_returnStatus => x_returnStatus);
    if ( x_returnStatus <> fnd_api.g_ret_sts_success ) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    begin
      select nvl(min(operation_seq_num), 1)
        into l_minOp
        from wip_operations
       where wip_entity_id = p_wipEntityID;
    exception
    when others then
      l_minOp := 1;
    end;

    l_count := l_compTbl.first;
    while ( l_count is not null ) loop
      -- here, we need to make sure that the op exists. This might happen if the user use an alternate
      -- routing to create the job so the op exploded might not exists. In that case, we will assign this component
      -- to the first operation
      begin
        select 1 into l_exists
          from wip_operations
         where wip_entity_id = p_wipEntityID
           and operation_seq_num = l_compTbl(l_count).operation_seq_num;
        l_opSeq := l_compTbl(l_count).operation_seq_num;
      exception
      when others then
        l_opSeq := l_minOp;

	/* Fix for bug 8588333: If routing or the specific operation doesn't exists then only
           Op pull components should become Assy Pull. */
        if (l_opSeq = 1 AND l_compTbl(l_count).wip_supply_type = WIP_CONSTANTS.OP_PULL) then
            l_compTbl(l_count).wip_supply_type := WIP_CONSTANTS.ASSY_PULL;
        end if;

      end;

      if( l_compTbl(l_count).basis_type = WIP_CONSTANTS.LOT_BASED_MTL) then
          l_multipleFactor := 1 ;
      else
          l_multipleFactor := p_qty ;
      end if;

      /* Moved This fix inside exception block of SQL on wip_operations.
      /* Fix for bug 4703486. If no rtg exists, Op pull components should become Assy Pull
      if (l_opSeq = 1 AND l_compTbl(l_count).wip_supply_type = WIP_CONSTANTS.OP_PULL) then
         l_compTbl(l_count).wip_supply_type := WIP_CONSTANTS.ASSY_PULL;
      end if;
      */


      /* bug 4688276 - if the same component in op 1 and op 10, for example, we'll try
         to merge the qties into op 10, as long as their baisis type is the same */
      if( l_compTbl(l_count).wip_supply_type = wip_constants.phantom) then
        l_wro_op := -1*l_opSeq;
      else
        l_wro_op := l_opSeq;
      end if;

      select count(distinct nvl(basis_type, 1)), min(distinct nvl(basis_type, 1) )
      into l_diff_basis, l_basis
      from wip_requirement_operations wro
      where wro.inventory_item_id = l_compTbl(l_count).inventory_item_id
        and wro.organization_id = p_orgID
        and wro.wip_entity_id = p_wipEntityID
        and wro.operation_seq_num = l_wro_op;

      if( l_diff_basis > 1 ) then
        raise fnd_api.g_exc_unexpected_error;
      elsif( l_diff_basis = 1 ) then
        if(  (l_compTbl(l_count).basis_type is null and l_basis = 1 )
             or l_compTbl(l_count).basis_type = l_basis ) then
          update wip_requirement_operations wro
          set wro.quantity_per_assembly = round( l_compTbl(l_count).primary_quantity + wro.quantity_per_assembly,
                                                wip_constants.max_displayed_precision),
            wro.required_quantity = round( round(l_compTbl(l_count).primary_quantity,
                                                  wip_constants.max_displayed_precision)
                                           *l_multipleFactor/l_compTbl(l_count).component_yield_factor,
                                    wip_constants.max_displayed_precision) + wro.required_quantity
          where wro.inventory_item_id = l_compTbl(l_count).inventory_item_id
            and wro.organization_id = p_orgID
            and wro.wip_entity_id = p_wipEntityID
            and wro.operation_seq_num = l_wro_op;

          update wip_requirement_operations wro
	  /*Fix for bug 7486594*/
          set wro.component_yield_factor = decode(wro.quantity_per_assembly,0,1,round( wro.quantity_per_assembly * l_multipleFactor / wro.required_quantity,
                                                  wip_constants.max_displayed_precision))
          where wro.inventory_item_id = l_compTbl(l_count).inventory_item_id
            and wro.organization_id = p_orgID
            and wro.wip_entity_id = p_wipEntityID
            and wro.operation_seq_num = l_wro_op;
        else
          x_returnStatus := fnd_api.g_ret_sts_error;
          fnd_message.set_name('WIP', 'WIP_COMP_DUP_OP_ONE');
          fnd_msg_pub.add;
          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log(p_msg => 'Item ' || l_compTbl(l_count).inventory_item_id ||
                                    ' has duplicates in op 1, failed explosion!',
                           x_returnStatus => x_returnStatus);


          end if;
          return;
        end if;
      else  /* --> end of bug fix 4688276 */


      insert into wip_requirement_operations
        (inventory_item_id,
         organization_id,
         wip_entity_id,
         operation_seq_num,
         repetitive_schedule_id,
         last_update_date,
         last_updated_by,
         creation_date,
         created_by,
         last_update_login,
         request_id,
         program_application_id,
         program_id,
         program_update_date,
         component_sequence_id,
         wip_supply_type,
         date_required,
         required_quantity,
         quantity_issued,
         quantity_per_assembly,
         component_yield_factor, /*For Component Yield Enhancement(Bug 4369064) */
	 basis_type,
         supply_subinventory,
         supply_locator_id,
         mrp_net_flag)
      values(
         l_compTbl(l_count).inventory_item_id,
         p_orgID,
         p_wipEntityID,
         decode(l_compTbl(l_count).wip_supply_type,
                wip_constants.phantom, -1*l_opSeq, l_opSeq),
         null,
         sysdate,
         fnd_global.user_id,
         sysdate,
         fnd_global.user_id,
         fnd_global.login_id,
         fnd_global.conc_request_id,
         fnd_global.prog_appl_id,
         fnd_global.conc_program_id,
         sysdate,
         l_compTbl(l_count).component_sequence_id,
         l_compTbl(l_count).wip_supply_type,
         p_jobStartDate,
         round(round(l_compTbl(l_count).primary_quantity, wip_constants.max_displayed_precision)*l_multipleFactor/
                     l_compTbl(l_count).component_yield_factor, wip_constants.max_displayed_precision),
                     /*For Component Yield Enhancement(Bug 4369064)->Always need to consider yield factor*/
         0,
         round(l_compTbl(l_count).primary_quantity, wip_constants.max_displayed_precision),
         l_compTbl(l_count).component_yield_factor, /*For Component Yield Enhancement(Bug 4369064) */
	 decode(l_compTbl(l_count).basis_type,WIP_CONSTANTS.LOT_BASED_MTL,2,NULL),
         l_compTbl(l_count).supply_subinventory,
         l_compTbl(l_count).supply_locator_id,
         decode(l_compTbl(l_count).wip_supply_type, 5, 2,
                decode(sign(l_compTbl(l_count).primary_quantity), -1, 2, l_mrpFlag)));

      end if; /* end insert */

      l_count := l_compTbl.next(l_count);
    end loop;

    l_usePhantomRouting := wip_globals.use_phantom_routings(p_orgID);
    if ( l_usePhantomRouting = wip_constants.yes ) then
      for phan in c_phantoms loop
        wip_explode_phantom_rtgs.explode_resources(
            p_wip_entity_id => p_wipEntityID,
            p_sched_id => p_repSchedID,
            p_org_id => p_orgID,
            p_entity_type => l_entityType,
            p_phantom_item_id => phan.inventory_item_id,
            p_op_seq_num => phan.operation_seq_num,
            p_rtg_rev_date => p_routingRevDate);
      end loop;
    end if;

    -- bug 5527438 added call to the following API to enable defaulting of supply subinventory
    -- and locator from the resource definition.

    wip_picking_pvt.Post_Explosion_CleanUp(	p_wip_entity_id => p_wipEntityID,
             					p_repetitive_schedule_id => null,
             					p_org_id =>   p_orgID,
             					x_return_status => x_returnStatus,
             					x_msg_data => x_errorMsg );

    if (x_returnStatus <> fnd_api.g_ret_sts_success) then
             if (l_logLevel <= wip_constants.full_logging) then
                     wip_logger.log(p_msg => 'Post_Explosion_Cleanup failed for  wip_entity_id '||p_wipEntityID,
                                    x_returnStatus => x_returnStatus);
             end if;
             return;
    end if;

    -- bug 5527438 end of changes for this fix

    update wip_requirement_operations wro
       set (date_required,
            department_id,
            wip_supply_type) =
           (select nvl(max(wo.first_unit_start_date), wro.date_required),
                   max(department_id),
                   decode(wro.wip_supply_type, wip_constants.assy_pull,
                          decode(nvl(max(wo.count_point_type), 0),
                                 wip_constants.no_manual, wip_constants.op_pull,
                                 wro.wip_supply_type),
                          wro.wip_supply_type)
              from wip_operations wo
             where wo.organization_id = wro.organization_id
               and wo.wip_entity_id  = wro.wip_entity_id
               and nvl(wo.repetitive_schedule_id, -1) = nvl(wro.repetitive_schedule_id, -1)
               and wo.operation_seq_num = abs(wro.operation_seq_num)),
           (comments,
            attribute_category,
            attribute1,
            attribute2,
            attribute3,
            attribute4,
            attribute5,
            attribute6,
            attribute7,
            attribute8,
            attribute9,
            attribute10,
            attribute11,
            attribute12,
            attribute13,
            attribute14,
            attribute15) =
           (select bic.component_remarks,
                   bic.attribute_category,
                   bic.attribute1,
                   bic.attribute2,
                   bic.attribute3,
                   bic.attribute4,
                   bic.attribute5,
                   bic.attribute6,
                   bic.attribute7,
                   bic.attribute8,
                   bic.attribute9,
                   bic.attribute10,
                   bic.attribute11,
                   bic.attribute12,
                   bic.attribute13,
                   bic.attribute14,
                   bic.attribute15
              from bom_inventory_components bic
             where bic.component_sequence_id = wro.component_sequence_id),
           (segment1,
            segment2,
            segment3,
            segment4,
            segment5,
            segment6,
            segment7,
            segment8,
            segment9,
            segment10,
            segment11,
            segment12,
            segment13,
            segment14,
            segment15,
            segment16,
            segment17,
            segment18,
            segment19,
            segment20) =
           (select msi.segment1,
                   msi.segment2,
                   msi.segment3,
                   msi.segment4,
                   msi.segment5,
                   msi.segment6,
                   msi.segment7,
                   msi.segment8,
                   msi.segment9,
                   msi.segment10,
                   msi.segment11,
                   msi.segment12,
                   msi.segment13,
                   msi.segment14,
                   msi.segment15,
                   msi.segment16,
                   msi.segment17,
                   msi.segment18,
                   msi.segment19,
                   msi.segment20
              from mtl_system_items msi
             where msi.inventory_item_id = wro.inventory_item_id
               and msi.organization_id = wro.organization_id)
     where wro.wip_entity_id = p_wipEntityID
       and nvl(wro.repetitive_schedule_id, -1) = nvl(p_repSchedID, -1)
       and wro.organization_id = p_orgID;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
    end if;
  exception
  when fnd_api.g_exc_unexpected_error then
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => g_pkgName || '.' || l_procName,
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'failed at exploding requirements',
                           x_returnStatus => l_retStatus); --discard logging return status
    end if;
  when others then
    if(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'unexp error:' || SQLERRM,
                           x_returnStatus     => l_retStatus);
    end if;
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.add_exc_msg(p_pkg_name => g_pkgName,
                            p_procedure_name => l_procName,
                            p_error_text => SQLERRM);
    wip_utilities.get_message_stack(p_msg => l_msg);
    x_errorMsg := substrb(l_msg, 1, 240);
  end explodeBOM;


  procedure adjustQtyChange(p_orgID       in number,
                            p_wipEntityID in number,
                            p_qty         in number,
                            x_returnStatus out nocopy varchar2,
                            x_errorMsg     out nocopy varchar2) is
    l_params wip_logger.param_tbl_t;
    l_procName varchar2(30) := 'adjustQtyChange';
    l_logLevel number := to_number(fnd_log.g_current_runtime_level);
    l_msg varchar2(240);
    l_retStatus varchar2(1);

    l_jobQty number;
    l_jobStatus number;
    l_minOp number;
    l_updateFlag number :=0;/* add for Bug 8413228 (FP of 8392916).*/
  begin

    x_returnStatus := fnd_api.g_ret_sts_success;
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_orgID';
      l_params(1).paramValue := p_orgID;
      l_params(2).paramName := 'p_wipEntityID';
      l_params(2).paramValue := p_wipEntityID;
      l_params(3).paramName := 'p_qty';
      l_params(3).paramValue := p_qty;
      wip_logger.entryPoint(p_procName     => g_pkgName || '.' || l_procName,
                            p_params       => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;


    select start_quantity,
           status_type
      into l_jobQty,
           l_jobStatus
      from wip_discrete_jobs
     where organization_id = p_orgID
       and wip_entity_id = p_wipEntityID;

    if ( p_qty is null or
         l_jobStatus not in (wip_constants.unreleased,
                             wip_constants.released,
                             wip_constants.comp_chrg,
                             wip_constants.hold) ) then
      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'no qty change or job status is not right',
                             x_returnStatus     => l_retStatus);
      end if;
      return;
    end if;


    if ( l_jobStatus <> wip_constants.unreleased ) then
      select nvl(min(operation_seq_num), fnd_api.g_miss_num)
        into l_minOp
        from wip_operations
       where organization_id = p_orgID
         and wip_entity_id = p_wipEntityID;

      if ( l_minOp = fnd_api.g_miss_num ) then
         /*  Fix bug 9540544 */
         update wip_requirement_operations
         set required_quantity = decode(basis_type,
                                        2,  /* basis is lot */
 	     round(quantity_per_assembly/nvl(component_yield_factor,1), 6),/*For Component Yield Enhancement(Bug 4369064) */
 	                                round(quantity_per_assembly/nvl(component_yield_factor,1) * p_qty, 6))
         where organization_id = p_orgID
         and wip_entity_id = p_wipEntityID;
        /*  End of Fix bug 9540544 */
        if(l_logLevel <= wip_constants.trace_logging) then
          wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                               p_procReturnStatus => x_returnStatus,
                               p_msg              => 'no operation exist',
                               x_returnStatus     => l_retStatus);
        end if;
        return;
      end if;

       update wip_operations
         set quantity_in_queue = quantity_in_queue - (scheduled_quantity - p_qty)
       where organization_id = p_orgID
         and wip_entity_id = p_wipEntityID
         and operation_seq_num = l_minOp
	       and quantity_in_queue <> 0 /* Fix for Bug 6639146 */
         and (scheduled_quantity - p_qty) <= quantity_in_queue; /* add for Bug  8413228 (FP of 8392916).quantity_in_queue can be lower to 0 */

 	          /* add for Bug 8413228 (FP of 8392916).*/
 	         if SQL%FOUND then
 	          l_updateFlag :=1;
 	         end if;

       /* Fix for bug 6954115 */
       update wip_operations
         set quantity_in_queue = p_qty -(quantity_completed+quantity_running+quantity_in_queue)
       where organization_id = p_orgID
         and wip_entity_id = p_wipEntityID
         and operation_seq_num = l_minOp
         and quantity_in_queue = 0
         and (quantity_completed+quantity_running+quantity_in_queue) <= p_qty; /*Fix for Bug 8413228 (FP of 8392916). quantity_in_queue can be lower to 0 */

 	           /* add for Bug 8413228 (FP of 8392916). If both update statements have no rows to update, that means
 	           that the quantity was lowered below what was already past queue of the first op.
 	            This is an error. */
 	          if (SQL%NOTFOUND and l_updateFlag = 0) then
 	           fnd_message.set_name('WIP', 'WIP_LOWER_JOB_QTY');
 	           x_returnStatus := fnd_api.g_ret_sts_unexp_error;
 	           x_errorMsg := fnd_message.get;
 	           return;
 	         end if;

    end if;

      update wip_operations
       set scheduled_quantity = p_qty
     where organization_id = p_orgID
       and wip_entity_id = p_wipEntityID;

    update wip_requirement_operations
       set required_quantity = decode(basis_type,
				      2,  /* basis is lot */
                                      round(quantity_per_assembly/nvl(component_yield_factor,1), 6),/*For Component Yield Enhancement(Bug 4369064) */
				      round(quantity_per_assembly/nvl(component_yield_factor,1) * p_qty, 6))
     where organization_id = p_orgID
       and wip_entity_id = p_wipEntityID;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
    end if;

  exception
  when others then
    if(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'unexp error:' || SQLERRM,
                           x_returnStatus     => l_retStatus);
    end if;
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.add_exc_msg(p_pkg_name => g_pkgName,
                            p_procedure_name => l_procName,
                            p_error_text => SQLERRM);
    wip_utilities.get_message_stack(p_msg => l_msg);
    x_errorMsg := substrb(l_msg, 1, 240);
  end adjustQtyChange;

end wip_bomRoutingUtil_pvt;

/
