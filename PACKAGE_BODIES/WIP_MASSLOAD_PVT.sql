--------------------------------------------------------
--  DDL for Package Body WIP_MASSLOAD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_MASSLOAD_PVT" as
 /* $Header: wipmlpvb.pls 120.16.12010000.2 2009/02/26 19:47:15 ntangjee ship $ */

  g_pkgName constant varchar2(30) := 'wip_massload_pvt';


  procedure createWIPEntity(p_rowid in rowid);
  procedure updateWIPEntity(p_rowid in rowid);

  procedure processWJSI(p_rowid        in rowid,
                        x_returnStatus out nocopy varchar2,
                        x_errorMsg     out nocopy varchar2) is
    l_params wip_logger.param_tbl_t;
    l_procName varchar2(30) := 'processWJSI';
    l_logLevel number := to_number(fnd_log.g_current_runtime_level);
    l_retStatus varchar2(1);
    l_msg varchar2(240);

    wjsi_row wip_job_schedule_interface%ROWTYPE;
    l_serStartOp number := null;
    l_defaultSer number;
    l_startDate date;
    l_endDate date;
    l_jobType number;
    l_statusType number;
    l_bomRefID number;
    l_rtgRefID number;
    l_bomRevDate date;
    l_rtgRevDate date;
    l_allowExplosion boolean;
    l_qty number;
    l_success number;
    l_projectID number;
    l_taskID number;

  begin
    x_returnStatus := fnd_api.g_ret_sts_success;
    savepoint begin_process_wjsi;

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_rowid';
      l_params(1).paramValue := p_rowid;
      wip_logger.entryPoint(p_procName     => g_pkgName || '.' || l_procName,
                            p_params       => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    select *
      into wjsi_row
      from wip_job_schedule_interface
     where rowid = p_rowid;

    if ( l_logLevel <= wip_constants.trace_logging ) then
      wip_logger.log('Interface id: ' || wjsi_row.interface_id || ' load type is: ' || wjsi_row.load_type,
                     l_retStatus);
    end if;


    if ( wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_ns_job) ) then
      -- create job header record
      createWIPEntity(p_rowid);

      if ( wjsi_row.load_type = wip_constants.create_job ) then
        l_jobType := wip_constants.standard;
      else
        l_jobType := wip_constants.nonstandard;
      end if;

      if ( nvl(wjsi_row.allow_explosion, 'Y') not in ('n', 'N') ) then
        wip_bomRouting_pvt.createJob(p_orgID => wjsi_row.organization_id,
                                   p_wipEntityID => wjsi_row.wip_entity_id,
                                   p_jobType => l_jobType,
                                   p_itemID => wjsi_row.primary_item_id,
                                   p_schedulingMethod =>wjsi_row.scheduling_method,
                                   p_altRouting => wjsi_row.alternate_routing_designator,
                                   p_routingRevDate => wjsi_row.routing_revision_date,
                                   p_altBOM => wjsi_row.alternate_bom_designator,
                                   p_bomRevDate => wjsi_row.bom_revision_date,
                                   p_qty => wjsi_row.start_quantity,
                                   p_startDate => wjsi_row.first_unit_start_date,
                                   p_endDate => wjsi_row.last_unit_completion_date,
                                   p_projectID => wjsi_row.project_id,
                                   p_taskID => wjsi_row.task_id,
                                   p_rtgRefID => wjsi_row.routing_reference_id,
                                   p_bomRefID => wjsi_row.bom_reference_id,
				   p_unitNumber => wjsi_row.end_item_unit_number, /* added for bug 5332615 */
                                   x_serStartOp => l_serStartOp,
                                   x_returnStatus => x_returnStatus,
                                   x_errorMsg => x_errorMsg);
        if ( x_returnStatus <> fnd_api.g_ret_sts_success ) then
          raise fnd_api.g_exc_unexpected_error;
        end if;
      end if;

      -- default the serialization start op
      if ( wjsi_row.serialization_start_op is null and
           wjsi_row.primary_item_id is not null) then
        select default_serialization_start_op
          into l_defaultSer
          from wip_parameters
         where organization_id = wjsi_row.organization_id;

        if ( l_serStartOp is not null ) then
          update wip_discrete_jobs
             set serialization_start_op = l_serStartOp
           where wip_entity_id = wjsi_row.wip_entity_id
            and exists (select 1
                         from mtl_system_items
                        where inventory_item_id = wjsi_row.primary_item_id
                          and organization_id = wjsi_row.organization_id
                          and serial_number_control_code = wip_constants.full_sn);
        elsif ( l_defaultSer = wip_constants.yes ) then
          update wip_discrete_jobs
             set serialization_start_op = (select nvl(min(operation_seq_num), 1)
                                             from wip_operations
                                            where wip_entity_id = wjsi_row.wip_entity_id)
           where wip_entity_id = wjsi_row.wip_entity_id
             and exists (select 1
                           from mtl_system_items
                          where inventory_item_id = wjsi_row.primary_item_id
                            and organization_id = wjsi_row.organization_id
                            and serial_number_control_code = wip_constants.full_sn);
        end if;
      end if;

      /*  Fix bug 8272654
      Move this code to massLoadJobs in wip_massload_pub (wipmlppb.pls) to release job
      after load all the details to populate quantity in queue of the first operation
      added in WJDI
      -- release job if necessary
      if ( wjsi_row.status_type in (wip_constants.released, wip_constants.hold) ) then
        wip_mass_load_processor.ml_release(wjsi_row.wip_entity_id,
                                           wjsi_row.organization_id,
                                           wjsi_row.class_code,
                                           wjsi_row.status_type,
                                           l_success,
                                           x_errorMsg,
                                           nvl(wjsi_row.date_released, sysdate));
        if ( l_success = 0 ) then
          raise fnd_api.g_exc_unexpected_error;
        end if;
      end if;
      */

    elsif ( wjsi_row.load_type = wip_constants.resched_job ) then
      select bom_reference_id,
             routing_reference_id,
             bom_revision_date,
             routing_revision_date,
             start_quantity,
             status_type,
             scheduled_start_date,
             scheduled_completion_date,
	     project_id,
	     task_id
        into l_bomRefID,
             l_rtgRefID,
             l_bomRevDate,
             l_rtgRevDate,
             l_qty,
             l_statusType,
             l_startDate,
             l_endDate,
	     l_projectID,
	     l_taskID
        from wip_discrete_jobs
       where wip_entity_id = wjsi_row.wip_entity_id
         and organization_id = wjsi_row.organization_id;

      if ( wjsi_row.scheduling_method = wip_constants.routing ) then
        if ( wjsi_row.last_unit_completion_date is not null ) then
          l_startDate := null;
          l_endDate := wjsi_row.last_unit_completion_date;
        elsif ( wjsi_row.first_unit_start_date is not null ) then
          l_startDate := wjsi_row.first_unit_start_date;
          l_endDate := null;
        else
          -- if not date is provided, then we forward schedule
          l_endDate := null;
        end if;
      else
        l_startDate := wjsi_row.first_unit_start_date;
        l_endDate := wjsi_row.last_unit_completion_date;
      end if;

      if ( nvl(wjsi_row.allow_explosion, 'Y') in ('n', 'N') ) then
        l_allowExplosion := false;
      else
        l_allowExplosion := true;
      end if;

      wip_bomRouting_pvt.reexplodeJob(
            p_orgID => wjsi_row.organization_id,
            p_wipEntityID => wjsi_row.wip_entity_id,
            p_schedulingMethod => wjsi_row.scheduling_method,
            p_altRouting => wjsi_row.alternate_routing_designator,
            --Bug 5230849:If routing revision date is null in wjsi,
            --use the date present in wdj.
            p_routingRevDate => nvl(wjsi_row.routing_revision_date,l_rtgRevDate),
            p_altBOM => wjsi_row.alternate_bom_designator,
            --Bug 5230849:If bom revision date is null in wjsi,
            --use the date present in wdj.
            p_bomRevDate => nvl(wjsi_row.bom_revision_date,l_bomRevDate),
            p_qty => nvl(wjsi_row.start_quantity, l_qty),
            p_startDate => l_startDate,
            p_endDate => l_endDate,
	    p_projectID => nvl(wjsi_row.project_id, l_projectID),
	    p_taskID => nvl(wjsi_row.task_id, l_taskID),
            p_allowExplosion => l_allowExplosion,
            p_rtgRefID => nvl(wjsi_row.routing_reference_id, l_rtgRefID),
            p_bomRefID => nvl(wjsi_row.bom_reference_id, l_bomRefID),
	    p_unitNumber => wjsi_row.end_item_unit_number, /* added for bug 5332615 */
            x_returnStatus => x_returnStatus,
            x_errorMsg => x_errorMsg);
      if ( x_returnStatus <> fnd_api.g_ret_sts_success ) then
        raise fnd_api.g_exc_unexpected_error;
      end if;

      -- handle status change
      if ( l_statusType <> wjsi_row.status_type and
           l_statusType in (wip_constants.released, wip_constants.unreleased) ) then
        wip_mass_load_processor.ml_status_change(
                                  wjsi_row.wip_entity_id,
                                  wjsi_row.organization_id,
                                  wjsi_row.class_code,
                                  wjsi_row.status_type,
                                  l_statusType,
                                  l_success,
                                  x_errorMsg,
                                  nvl(wjsi_row.date_released, sysdate));
        if ( l_success = 0 ) then
          raise fnd_api.g_exc_unexpected_error;
        end if;
      end if;

      -- handles pick release related issues
      if ( wip_picking_pub.is_job_pick_released(wjsi_row.wip_entity_id,
                                                wjsi_row.repetitive_schedule_id,
                                                wjsi_row.organization_id) and
           l_qty <> wjsi_row.start_quantity ) then
        wip_picking_pub.update_job_backordqty(
                          p_wip_entity_id => wjsi_row.wip_entity_id,
                          p_repetitive_schedule_id => wjsi_row.repetitive_schedule_id,
                          p_new_job_qty => wjsi_row.start_quantity,
                          x_return_status => l_retStatus,
                          x_msg_data => x_errorMsg);
        if ( l_retStatus <> fnd_api.g_ret_sts_success ) then
          raise fnd_api.g_exc_unexpected_error;
        end if;
      end if;

      if ( wjsi_row.status_type in (wip_constants.comp_nochrg,
                                    wip_constants.hold,
                                    wip_constants.cancelled) ) then
        wip_picking_pvt.cancel_allocations(p_wip_entity_id => wjsi_row.wip_entity_id,
                                           p_wip_entity_type => wip_constants.discrete,
                                           x_return_status => l_retStatus,
                                           x_msg_data => x_errorMsg);
        if ( l_retStatus <> fnd_api.g_ret_sts_success ) then
          raise fnd_api.g_exc_unexpected_error;
        end if;
      end if;

      -- Call the stored procedure to create a po req only if both old and new statuses
      -- are released and the new quantity is > old quantity.  When the status is
      -- changed to released, already existing stored procedures will create a po req.
      if ( wjsi_row.start_quantity > l_qty and
           wjsi_row.status_type = wip_constants.released and
           l_statusType = wip_constants.unreleased ) then
        wip_osp.create_additional_req(wjsi_row.wip_entity_id,
                                      wjsi_row.organization_id,
                                      null,
                                      wjsi_row.start_quantity - l_qty);
      end if;

      -- update job header info
      updateWipEntity(p_rowid);

    end if;
    -- Added for bug 5439929
    -- We should update the wip_supply type in wip_requirement_operations table
    -- wip_supply_type is specified by user in interface table. If user specified the value
    -- as 'Based on bill'(value 7), then we don't need to update as that is the default behavior
    If nvl(wjsi_row.wip_supply_type,7) <> 7 then
       update wip_requirement_operations
       set    wip_supply_type = wjsi_row.wip_supply_type
       where  wip_entity_id   = wjsi_row.wip_entity_id;
    End if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
    end if;

  exception
  when fnd_api.g_exc_unexpected_error then
    rollback to savepoint begin_process_wjsi;
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => x_errorMsg,
                             x_returnStatus     => l_retStatus);
    end if;
  when others then
    rollback to savepoint begin_process_wjsi;
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
  end processWJSI;


  procedure createWIPEntity(p_rowid in rowid) is
  begin
    insert into wip_discrete_jobs(
      wip_entity_id,
      organization_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      source_line_id,
      source_code,
      description,
      status_type,
      date_released,
      primary_item_id,
      bom_reference_id,
      routing_reference_id,
      firm_planned_flag,
      job_type,
      wip_supply_type,
      class_code,
      material_account,
      material_overhead_account,
      resource_account,
      outside_processing_account,
      material_variance_account,
      resource_variance_account,
      outside_proc_variance_account,
      std_cost_adjustment_account,
      overhead_account,
      overhead_variance_account,
      scheduled_start_date,
      scheduled_completion_date,
      start_quantity,
      quantity_completed,
      quantity_scrapped,
      net_quantity,
      common_bom_sequence_id,
      common_routing_sequence_id,
      bom_revision,
      routing_revision,
      bom_revision_date,
      routing_revision_date,
      lot_number,
      alternate_bom_designator,
      alternate_routing_designator,
      completion_subinventory,
      completion_locator_id,
      demand_class,
      project_id,
      task_id,
      schedule_group_id,
      build_sequence,
      line_id,
      kanban_card_id,
      overcompletion_tolerance_type,
      overcompletion_tolerance_value,
      end_item_unit_number,
      po_creation_time,
      priority,
      due_date,
      requested_start_date,
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
      serialization_start_op)
    select
      wjsi.wip_entity_id,
      wjsi.organization_id,
      sysdate,
      wjsi.last_updated_by,
      sysdate,
      wjsi.created_by,
      wjsi.last_update_login,
      wjsi.request_id,
      wjsi.program_application_id,
      wjsi.program_id,
      sysdate,
      wjsi.source_line_id,
      wjsi.source_code,
      wjsi.description,
      wjsi.status_type,
      decode(wjsi.status_type,
             wip_constants.released,
             decode(wjsi.date_released, null, sysdate,
                    decode(sign(wjsi.date_released-sysdate), 1, sysdate, wjsi.date_released)),
             wip_constants.hold,
             decode(wjsi.date_released, null, sysdate,
                    decode(sign(wjsi.date_released-sysdate), 1, sysdate, wjsi.date_released)),
             null),
      wjsi.primary_item_id,
      decode(wjsi.load_type, wip_constants.create_job, null, wjsi.bom_reference_id),
      decode(wjsi.load_type, wip_constants.create_job, null, wjsi.routing_reference_id),
      wjsi.firm_planned_flag,
      decode(wjsi.load_type, wip_constants.create_job, wip_constants.standard, wip_constants.nonstandard),
      wjsi.wip_supply_type,
      wjsi.class_code,
      wac.material_account,
      wac.material_overhead_account,
      wac.resource_account,
      wac.outside_processing_account,
      wac.material_variance_account,
      wac.resource_variance_account,
      wac.outside_proc_variance_account,
      wac.std_cost_adjustment_account,
      wac.overhead_account,
      wac.overhead_variance_account,
      nvl(wjsi.first_unit_start_date, wjsi.last_unit_completion_date),
      nvl(wjsi.last_unit_completion_date, wjsi.first_unit_start_date),
      round(wjsi.start_quantity, wip_constants.max_displayed_precision),
      0, -- quantity_completed
      0, -- quantity_scrapped
      round(wjsi.net_quantity, wip_constants.max_displayed_precision),
      bom.common_bill_sequence_id,
      rtg.common_routing_sequence_id,
      wjsi.bom_revision,
      wjsi.routing_revision,
      wjsi.bom_revision_date,
      wjsi.routing_revision_date,
      wjsi.lot_number,
      wjsi.alternate_bom_designator,
      wjsi.alternate_routing_designator,
      wjsi.completion_subinventory,
      wjsi.completion_locator_id,
      wjsi.demand_class,
      wjsi.project_id,
      wjsi.task_id,
      wjsi.schedule_group_id,
      wjsi.build_sequence,
      wjsi.line_id,
      wjsi.kanban_card_id,
      wjsi.overcompletion_tolerance_type,
      wjsi.overcompletion_tolerance_value,
      wjsi.end_item_unit_number,
      wp.po_creation_time,
      nvl(wjsi.priority, wip_constants.default_priority),
      wjsi.due_date,
      /* Bug 5745772: Requested start date and due date can only co exist if routing does not exist.*/
      decode(wjsi.due_date, NULL,TO_DATE(
					   TO_CHAR(
						   wjsi.requested_start_date,WIP_CONSTANTS.DT_NOSEC_FMT
						   ),WIP_CONSTANTS.DT_NOSEC_FMT
				           ),
				     DECODE(
					    wjsi.routing_revision,NULL, TO_DATE(
									      TO_CHAR(
											wjsi.requested_start_date,WIP_CONSTANTS.DT_NOSEC_FMT
										     ),WIP_CONSTANTS.DT_NOSEC_FMT
									      ),NULL
					    )
		),
      --wjsi.requested_start_date,
      wjsi.attribute_category,
      wjsi.attribute1,
      wjsi.attribute2,
      wjsi.attribute3,
      wjsi.attribute4,
      wjsi.attribute5,
      wjsi.attribute6,
      wjsi.attribute7,
      wjsi.attribute8,
      wjsi.attribute9,
      wjsi.attribute10,
      wjsi.attribute11,
      wjsi.attribute12,
      wjsi.attribute13,
      wjsi.attribute14,
      wjsi.attribute15,
      wjsi.serialization_start_op
     from wip_accounting_classes wac,
          bom_operational_routings rtg,
          bom_bill_of_materials bom,
          wip_parameters wp,
          wip_job_schedule_interface wjsi
    where wjsi.rowid = p_rowid
      and nvl(rtg.cfm_routing_flag,2) = 2
      and wac.class_code(+) = wjsi.class_code
      and wac.organization_id(+) = wjsi.organization_id
      and rtg.organization_id(+) = wjsi.organization_id
      and nvl(rtg.alternate_routing_designator(+), 'NONEXISTENT') =
          nvl(wjsi.alternate_routing_designator, 'NONEXISTENT')
      and rtg.assembly_item_id(+) = decode(wjsi.load_type,
                                           wip_constants.create_job, wjsi.primary_item_id,
                                           wjsi.routing_reference_id)
      and bom.assembly_item_id(+) = decode(wjsi.load_type,
                                           wip_constants.create_job, wjsi.primary_item_id,
                                           wjsi.bom_reference_id)
      and bom.organization_id(+) = wjsi.organization_id
      and nvl(bom.alternate_bom_designator(+), 'NON_EXISTENT') =
          nvl(wjsi.alternate_bom_designator, 'NON_EXISTENT')
      and wp.organization_id = wjsi.organization_id;

    insert into wip_entities(
      wip_entity_id,
      organization_id,
      last_update_date,
      last_updated_by,
      creation_date,
      created_by,
      last_update_login,
      request_id,
      program_application_id,
      program_id,
      program_update_date,
      wip_entity_name,
      entity_type,
      description,
      primary_item_id,
      gen_object_id)
   select
      wjsi.wip_entity_id,
      wjsi.organization_id,
      sysdate,
      wjsi.last_updated_by,
      sysdate,
      wjsi.created_by,
      wjsi.last_update_login,
      wjsi.request_id,
      wjsi.program_application_id,
      wjsi.program_id,
      sysdate,
      wjsi.job_name,
      1,
      wjsi.description,
      wjsi.primary_item_id,
      mtl_gen_object_id_s.nextval
     from wip_job_schedule_interface wjsi
    where wjsi.rowid = p_rowid;
  end createWIPEntity;


  procedure updateWIPEntity(p_rowid in rowid) is
    l_wipEntityID number;
  begin
    select wip_entity_id
      into l_wipEntityID
      from wip_job_schedule_interface
     where rowid = p_rowid;

    update wip_discrete_jobs wdj
      set (last_updated_by,
           last_update_login,
           request_id,
           program_application_id,
           program_id,
           program_update_date,
           last_update_date,
           firm_planned_flag,
           lot_number,
           start_quantity,
           net_quantity,
           status_type,
           DATE_RELEASED,
           DATE_COMPLETED,  /* fix bug 4760788 */
           SCHEDULED_START_DATE,
           SCHEDULED_COMPLETION_DATE,
           SCHEDULE_GROUP_ID,
           BUILD_SEQUENCE,
           LINE_ID,
           PROJECT_ID,
           TASK_ID,
           completion_subinventory,
           COMPLETION_LOCATOR_ID,
           DESCRIPTION,
           SOURCE_CODE,
           SOURCE_LINE_ID,
           OVERCOMPLETION_TOLERANCE_TYPE,
           OVERCOMPLETION_TOLERANCE_VALUE,
           END_ITEM_UNIT_NUMBER,
           PRIORITY,
           DUE_DATE,
           ATTRIBUTE_CATEGORY,
           ATTRIBUTE1,
           ATTRIBUTE2,
           ATTRIBUTE3,
           ATTRIBUTE4,
           ATTRIBUTE5,
           ATTRIBUTE6,
           ATTRIBUTE7,
           ATTRIBUTE8,
           ATTRIBUTE9,
           ATTRIBUTE10,
           ATTRIBUTE11,
           ATTRIBUTE12,
           ATTRIBUTE13,
           ATTRIBUTE14,
           ATTRIBUTE15,
	   ROUTING_REVISION_DATE,
	   ROUTING_REVISION,
           BOM_REVISION_DATE,
           BOM_REVISION,
           SERIALIZATION_START_OP,
           BOM_REFERENCE_ID,
           ROUTING_REFERENCE_ID,
	   ALTERNATE_BOM_DESIGNATOR,
	   ALTERNATE_ROUTING_DESIGNATOR,
	   WIP_SUPPLY_TYPE,-- Fix for bug 5440109
	   DEMAND_CLASS) =
                (SELECT LAST_UPDATED_BY,
                        LAST_UPDATE_LOGIN,
                        request_id,
                        program_application_id,
                        program_id,
                        SYSDATE,
                        SYSDATE,
                        NVL(WJ.FIRM_PLANNED_FLAG,WDJ.FIRM_PLANNED_FLAG),
                        NVL(WJ.LOT_NUMBER,WDJ.LOT_NUMBER),
                        NVL(ROUND(WJ.START_QUANTITY, WIP_CONSTANTS.MAX_DISPLAYED_PRECISION),
                            WDJ.START_QUANTITY),
                        NVL(ROUND(WJ.NET_QUANTITY, WIP_CONSTANTS.MAX_DISPLAYED_PRECISION),
                            WDJ.NET_QUANTITY),
                        NVL(WJ.STATUS_TYPE,WDJ.STATUS_TYPE),
                        DECODE(WJ.STATUS_TYPE,
                                WIP_CONSTANTS.RELEASED,NVL(WDJ.DATE_RELEASED, NVL(WJ.DATE_RELEASED,SYSDATE)),
                                WIP_CONSTANTS.HOLD,NVL(WDJ.DATE_RELEASED,NVL(WJ.DATE_RELEASED,SYSDATE)),
                                WIP_CONSTANTS.UNRELEASED, NULL, /*bug 3061143*/
                                WDJ.DATE_RELEASED),
                        DECODE(WJ.STATUS_TYPE,
                                   WIP_CONSTANTS.COMP_CHRG , NVL(WDJ.DATE_COMPLETED, SYSDATE),
                                   WIP_CONSTANTS.RELEASED,NULL,
                                   WIP_CONSTANTS.HOLD, NULL,
                                   WIP_CONSTANTS.UNRELEASED, NULL,
                                   WIP_CONSTANTS.CANCELLED, NULL,
                                   WDJ.DATE_COMPLETED),  /*Bug Number 4760788: Update date_completed*/
                        /* Fix bug 5238435. WJSI dates are replacing the scheduler calculated dates of WDJ */
                        DECODE(WJ.SCHEDULING_METHOD,
			       WIP_CONSTANTS.ROUTING, WDJ.SCHEDULED_START_DATE,
			       NVL(WJ.FIRST_UNIT_START_DATE,WDJ.SCHEDULED_START_DATE)),
			DECODE(WJ.SCHEDULING_METHOD,
			       WIP_CONSTANTS.ROUTING, WDJ.SCHEDULED_COMPLETION_DATE,
                        NVL(WJ.LAST_UNIT_COMPLETION_DATE, WDJ.SCHEDULED_COMPLETION_DATE)),
                        NVL(WJ.SCHEDULE_GROUP_ID,WDJ.SCHEDULE_GROUP_ID),
                        NVL(WJ.BUILD_SEQUENCE,WDJ.BUILD_SEQUENCE),
                        NVL(WJ.LINE_ID,WDJ.LINE_ID),
                        -- If PROJECT_ID is null in the interface table,
                        -- leave PROJECT_ID, TASK_ID, and
                        -- COMPLETION_LOCATOR_ID set to their old values.
                        -- Otherwise, update them to have the interface
                        -- table values, even if some of those values are null.
                        decode (
                          WJ.PROJECT_ID,
                          null, WDJ.PROJECT_ID,
                                WJ.PROJECT_ID
                        ),
                        decode (
                          WJ.PROJECT_ID,
                          null, WDJ.TASK_ID,
                                WJ.TASK_ID
                        ),
                        /*nvl(wj.completion_subinventory, wdj.completion_subinventory),
                        decode (
                          wj.completion_subinventory,
                          null, wdj.completion_locator_id,
                                wj.completion_locator_id),*/
                   /* Bug 5446216 (FP Bug 5504790) : Completion subinventory and/or locator will be nulled out
                      when fnd_api.g_miss_char and fnd_api.g_miss_num is passed for respective fields */
                        decode(wj.completion_subinventory,
                                        NULL, wdj.completion_subinventory,
                                        fnd_api.g_miss_char, NULL,
                                        wj.completion_subinventory),
                        decode(wj.completion_subinventory,
                                        NULL, decode(wj.completion_locator_id,
                                                     NULL, wdj.completion_locator_id,
                                                     wj.completion_locator_id),
                                        fnd_api.g_miss_char, NULL,
                                        decode(wj.completion_locator_id,
                                               fnd_api.g_miss_num, NULL,
                                               wj.completion_locator_id)),
                        NVL(WJ.DESCRIPTION,WDJ.DESCRIPTION),
                        NVL(WJ.SOURCE_CODE,WDJ.SOURCE_CODE),
                        NVL(WJ.SOURCE_LINE_ID,WDJ.SOURCE_LINE_ID),
                        NVL(WJ.OVERCOMPLETION_TOLERANCE_TYPE,
                            WDJ.OVERCOMPLETION_TOLERANCE_TYPE),
                        NVL(WJ.OVERCOMPLETION_TOLERANCE_VALUE,
                            WDJ.OVERCOMPLETION_TOLERANCE_VALUE),
                        NVL(WJ.END_ITEM_UNIT_NUMBER,
                            WDJ.END_ITEM_UNIT_NUMBER),
                        NVL(WJ.PRIORITY,WDJ.PRIORITY),
                        NVL(WJ.DUE_DATE,WDJ.DUE_DATE),
                        NVL(WJ.ATTRIBUTE_CATEGORY,WDJ.ATTRIBUTE_CATEGORY),
                        NVL(WJ.ATTRIBUTE1,WDJ.ATTRIBUTE1),
                        NVL(WJ.ATTRIBUTE2,WDJ.ATTRIBUTE2),
                        NVL(WJ.ATTRIBUTE3,WDJ.ATTRIBUTE3),
                        NVL(WJ.ATTRIBUTE4,WDJ.ATTRIBUTE4),
                        NVL(WJ.ATTRIBUTE5,WDJ.ATTRIBUTE5),
                        NVL(WJ.ATTRIBUTE6,WDJ.ATTRIBUTE6),
                        NVL(WJ.ATTRIBUTE7,WDJ.ATTRIBUTE7),
                        NVL(WJ.ATTRIBUTE8,WDJ.ATTRIBUTE8),
                        NVL(WJ.ATTRIBUTE9,WDJ.ATTRIBUTE9),
                        NVL(WJ.ATTRIBUTE10,WDJ.ATTRIBUTE10),
                        NVL(WJ.ATTRIBUTE11,WDJ.ATTRIBUTE11),
                        NVL(WJ.ATTRIBUTE12,WDJ.ATTRIBUTE12),
                        NVL(WJ.ATTRIBUTE13,WDJ.ATTRIBUTE13),
                        NVL(WJ.ATTRIBUTE14,WDJ.ATTRIBUTE14),
                        NVL(WJ.ATTRIBUTE15,WDJ.ATTRIBUTE15),
                        --Bug 5230849:Start of changes
                        --Routing and bom details should be updated only when the job is in unreleased status
                        --TO achieve this,decode on status type is added.
                       DECODE(NVL(WJ.STATUS_TYPE,WDJ.STATUS_TYPE),WIP_CONSTANTS.UNRELEASED,
			      NVL(TO_DATE(TO_CHAR(wj.routing_revision_date, WIP_CONSTANTS.DT_NOSEC_FMT),
                                          WIP_CONSTANTS.DT_NOSEC_FMT), WDJ.ROUTING_REVISION_DATE),
                              WDJ.ROUTING_REVISION_DATE),
                       DECODE(NVL(WJ.STATUS_TYPE,WDJ.STATUS_TYPE),WIP_CONSTANTS.UNRELEASED,
                              NVL(WJ.ROUTING_REVISION,WDJ.ROUTING_REVISION),WDJ.ROUTING_REVISION),
                       DECODE(NVL(WJ.STATUS_TYPE,WDJ.STATUS_TYPE),WIP_CONSTANTS.UNRELEASED,
                              NVL(TO_DATE(TO_CHAR(wj.bom_revision_date, WIP_CONSTANTS.DT_NOSEC_FMT),
                                          WIP_CONSTANTS.DT_NOSEC_FMT),WDJ.BOM_REVISION_DATE),
                              WDJ.BOM_REVISION_DATE),
                       DECODE(NVL(WJ.STATUS_TYPE,WDJ.STATUS_TYPE),WIP_CONSTANTS.UNRELEASED,
                              NVL(WJ.BOM_REVISION,WDJ.BOM_REVISION),WDJ.BOM_REVISION),
                       NVL(WJ.SERIALIZATION_START_OP, WDJ.SERIALIZATION_START_OP),
                        --DECODE(WDJ.JOB_TYPE, wip_constants.nonstandard, nvl(WJ.BOM_REFERENCE_ID, WDJ.BOM_REFERENCE_ID), null),
                        --DECODE(WDJ.JOB_TYPE, wip_constants.nonstandard, nvl(WJ.ROUTING_REFERENCE_ID, WDJ.ROUTING_REFERENCE_ID),  null),
						/* Modified for bug 5479283. Now bom/routing reference fields will be maintained with old value when null is passed. */
                        DECODE(WDJ.JOB_TYPE, wip_constants.nonstandard,
                               DECODE(nvl(WJ.STATUS_TYPE,WDJ.STATUS_TYPE),WIP_CONSTANTS.UNRELEASED,
                                      WJ.BOM_REFERENCE_ID,WDJ.BOM_REFERENCE_ID),
                               null),
                        DECODE(WDJ.JOB_TYPE, wip_constants.nonstandard,
                               DECODE(nvl(WJ.STATUS_TYPE,WDJ.STATUS_TYPE),WIP_CONSTANTS.UNRELEASED,
                                      WJ.ROUTING_REFERENCE_ID,WDJ.ROUTING_REFERENCE_ID),
                               null),
                        --Bug 5230849:End of changes for checking job status.
                        --Bug 5230849:Start of changes:
                          --Bom/Routing designator should be updatable for non-standard jobs also.
                          --If bom/rou designator is g_miss_char,existing value should be retained.
                          --No check on status type is needed becaue this is already considered during validation phase.
			--DECODE(WDJ.JOB_TYPE, wip_constants.standard, nvl(WJ.ALTERNATE_BOM_DESIGNATOR, WDJ.ALTERNATE_BOM_DESIGNATOR), null),
                        --DECODE(WDJ.JOB_TYPE, wip_constants.standard, nvl(WJ.ALTERNATE_ROUTING_DESIGNATOR, WDJ.ALTERNATE_ROUTING_DESIGNATOR),  null)
			/*DECODE(WDJ.JOB_TYPE, wip_constants.standard,
                              DECODE(WJ.ALTERNATE_BOM_DESIGNATOR,fnd_api.g_miss_char,WDJ.ALTERNATE_BOM_DESIGNATOR,WJ.ALTERNATE_BOM_DESIGNATOR),
                              DECODE(
                                     DECODE(NVL(WJ.STATUS_TYPE,WDJ.STATUS_TYPE),WIP_CONSTANTS.UNRELEASED,WJ.BOM_REFERENCE_ID,WDJ.BOM_REFERENCE_ID),
                                     NULL,NULL,
                                     DECODE(WJ.ALTERNATE_BOM_DESIGNATOR,fnd_api.g_miss_char,WDJ.ALTERNATE_BOM_DESIGNATOR,WJ.ALTERNATE_BOM_DESIGNATOR))),
			DECODE(WDJ.JOB_TYPE, wip_constants.standard,
                              DECODE(WJ.ALTERNATE_ROUTING_DESIGNATOR,fnd_api.g_miss_char,WDJ.ALTERNATE_ROUTING_DESIGNATOR,WJ.ALTERNATE_ROUTING_DESIGNATOR),
                              DECODE(
                                     DECODE(NVL(WJ.STATUS_TYPE,WDJ.STATUS_TYPE),WIP_CONSTANTS.UNRELEASED,WJ.ROUTING_REFERENCE_ID,WDJ.ROUTING_REFERENCE_ID),
                                     NULL,NULL,
                                     DECODE(WJ.ALTERNATE_ROUTING_DESIGNATOR,fnd_api.g_miss_char,WDJ.ALTERNATE_ROUTING_DESIGNATOR,WJ.ALTERNATE_ROUTING_DESIGNATOR))),
			Modified update on ALTERNATE_BOM_DESIGNATOR,ALTERNATE_ROUTING_DESIGNATOR for bug 5479283.
			 This maintains old value when null is passed */
            DECODE(WDJ.JOB_TYPE, wip_constants.standard,WJ.ALTERNATE_BOM_DESIGNATOR,
                                 DECODE(DECODE(NVL(WJ.STATUS_TYPE,WDJ.STATUS_TYPE),WIP_CONSTANTS.UNRELEASED,WJ.BOM_REFERENCE_ID,WDJ.BOM_REFERENCE_ID),
                                        NULL,NULL,WJ.ALTERNATE_BOM_DESIGNATOR)),
			DECODE(WDJ.JOB_TYPE, wip_constants.standard,WJ.ALTERNATE_ROUTING_DESIGNATOR,
                                 DECODE(DECODE(NVL(WJ.STATUS_TYPE,WDJ.STATUS_TYPE),WIP_CONSTANTS.UNRELEASED,WJ.ROUTING_REFERENCE_ID,WDJ.ROUTING_REFERENCE_ID),
                                        NULL,NULL,WJ.ALTERNATE_ROUTING_DESIGNATOR)),
		       nvl(wj.wip_supply_type,wdj.wip_supply_type), -- Fix for bug 5440109
		       nvl(wj.demand_class,wdj.demand_class) -- Fix for bug 5440109
                        --Bug 5230849:End of changes for bom/alternate designator updation.
                FROM WIP_JOB_SCHEDULE_INTERFACE WJ
                WHERE WJ.ROWID = p_rowid)
        WHERE WDJ.WIP_ENTITY_ID = l_wipEntityID;

     UPDATE WIP_ENTITIES WE
        SET (DESCRIPTION,
             LAST_UPDATED_BY,
             last_update_login,
             request_id,
             program_application_id,
             program_id,
             program_update_date,
             last_update_date)
                         = (SELECT NVL(WJ.DESCRIPTION, WE.DESCRIPTION),
                                        LAST_UPDATED_BY,
                                        LAST_UPDATE_LOGIN,
                                        REQUEST_ID,
                                        PROGRAM_APPLICATION_ID,
                                        PROGRAM_ID,
                                        SYSDATE,
                                        SYSDATE
                           FROM   WIP_JOB_SCHEDULE_INTERFACE WJ
                           WHERE WJ.ROWID = p_rowid)
        WHERE WE.WIP_ENTITY_ID = l_wipEntityID;
  end updateWIPEntity;

end wip_massload_pvt;

/
