--------------------------------------------------------
--  DDL for Package Body WIP_JSI_PROCESSOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_JSI_PROCESSOR" as
/* $Header: wipjsipb.pls 120.1.12010000.2 2010/02/05 01:49:53 pding ship $ */



PROCEDURE update_parent_tables is

  x_load_type number ;
  x_status_type number ;
  x_entity_id number ;
  x_org_id number ;
  x_item_id number;
  x_cmn_bom_seq_id number;
  x_cmn_routing_seq_id number;
  x_rep_sched_id number ;
  x_mo_req_number VARCHAR2(20);
  x_conc_req_id number;
  x_old_start_quantity number;
  x_new_start_quantity number;
  l_previous_job_status number;
  l_create_requisition  boolean := TRUE;
  l_pm_sched_id NUMBER;
  l_plan_maint varchar2(1);
  l_status VARCHAR2(1);
  l_msg_data VARCHAR2(2000);
  l_move_order_required VARCHAR2(1);
  l_allocTbl wip_picking_pub.allocate_tbl_t;
  l_task_id NUMBER;
  l_project_id NUMBER;

BEGIN
  select
    load_type,
    status_type,
    wip_entity_id,
    organization_id,
    repetitive_schedule_id,
    start_quantity,
    pm_schedule_id,
    project_id,
    task_id,
    material_issue_by_mo
  into
    x_load_type,
    x_status_type,
    x_entity_id,
    x_org_id,
    x_rep_sched_id,
    x_new_start_quantity,
    l_pm_sched_id,
    l_project_id,
    l_task_id,
    l_move_order_required
  from wip_job_schedule_interface
  where rowid = WIP_JSI_Utils.current_rowid ;

  if (x_load_type in (WIP_CONSTANTS.RESCHED_JOB, WIP_CONSTANTS.RESCHED_LOT_JOB)) then
    begin
      select wdj.start_quantity
       into x_old_start_quantity
      FROM wip_discrete_jobs wdj,
       wip_job_schedule_interface wi
      WHERE
       wi.rowid = WIP_JSI_Utils.current_rowid and
       wi.wip_entity_id = wdj.wip_entity_id;
    exception
      when no_data_found then
         x_old_start_quantity := null;
    end;
  end if;

  if (UPPER(l_move_order_required) = 'Y' and x_status_type = WIP_CONSTANTS.RELEASED) then
      l_allocTbl(1).wip_entity_id := x_entity_id;
      l_allocTbl(1).repetitive_schedule_id := x_rep_sched_id;
      l_allocTbl(1).project_id := l_project_id;
      l_allocTbl(1).task_id := l_task_id;
      l_allocTbl(1).use_pickset_flag := 'N';

      wip_picking_pvt.allocate(p_alloc_tbl => l_allocTbl,
               p_cutoff_date => null,      -- no cutoff day
               p_wip_entity_type => wip_constants.eam,
               p_organization_id => x_org_id,
               x_mo_req_number => x_mo_req_number,
               x_conc_req_id => x_conc_req_id,
               x_return_status => l_status,
               x_msg_data => l_msg_data
        );

      if(l_status in ('S', 'P')) then
        wip_jsi_utils.record_error_text( l_status || ':' || x_mo_req_number || ': ' || l_msg_data, true) ;
      elsif(l_status in ('N', 'E')) then
        wip_jsi_utils.record_error_text( l_status || ': ' || l_msg_data, true) ;
      else
        wip_jsi_utils.record_error_text( l_status || ': ' || l_msg_data, true);
      end if;
  end if;

  if(l_pm_sched_id is not null) then
    l_plan_maint := 'Y';
  end if;

  if (x_load_type IN (WIP_CONSTANTS.CREATE_JOB,
                      WIP_CONSTANTS.CREATE_NS_JOB,
                      WIP_CONSTANTS.CREATE_EAM_JOB))
  then

        INSERT INTO WIP_DISCRETE_JOBS
        (wip_entity_id,
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
         parent_wip_entity_id,
         asset_group_id,
         asset_number,
         owning_department,
         rebuild_item_id,
         rebuild_serial_number,
         manual_rebuild_flag,
         activity_type,
         activity_cause,
         activity_source,
         work_order_type,
         notification_required,
         shutdown_type,
         pm_schedule_id,
         plan_maintenance,
         tagout_required,
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
         maintenance_object_id,
         maintenance_object_type,
         maintenance_object_source,
         material_issue_by_mo,
         serialization_start_op)
        SELECT
         wi.wip_entity_id,
         wi.organization_id,
         SYSDATE,
         wi.last_updated_by,
         SYSDATE,
         wi.created_by,
         wi.last_update_login,
         wi.request_id,
         wi.program_application_id,
         wi.program_id,
         SYSDATE,
         wi.source_line_id,
         wi.source_code,
         wi.description,
         wi.status_type,
         decode(wi.status_type,
                WIP_CONSTANTS.RELEASED,
                decode(wi.date_released,NULL,SYSDATE,decode( sign(wi.date_released - sysdate),1,sysdate,wi.date_released)),
                WIP_CONSTANTS.HOLD,
                decode(wi.date_released,NULL,SYSDATE,decode( sign(wi.date_released - sysdate),1,sysdate,wi.date_released)),
                WIP_CONSTANTS.UNRELEASED,
                NULL,
                NULL
               ),
         wi.primary_item_id,
         decode(wi.load_type, WIP_CONSTANTS.CREATE_JOB, NULL,
                                wi.bom_reference_id),
         decode(wi.load_type, WIP_CONSTANTS.CREATE_JOB, NULL,
                                wi.routing_reference_id),
         wi.firm_planned_flag,
         decode(wi.load_type, WIP_CONSTANTS.CREATE_JOB, WIP_CONSTANTS.STANDARD,
                                WIP_CONSTANTS.NONSTANDARD),
         wi.wip_supply_type,
         wi.class_code,
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
         TO_DATE(TO_CHAR(wi.first_unit_start_date,
                         WIP_CONSTANTS.DT_NOSEC_FMT),
                 WIP_CONSTANTS.DT_NOSEC_FMT),
         TO_DATE(TO_CHAR(wi.last_unit_completion_date,
                         WIP_CONSTANTS.DT_NOSEC_FMT),
                 WIP_CONSTANTS.DT_NOSEC_FMT),
         ROUND(wi.start_quantity, WIP_CONSTANTS.MAX_DISPLAYED_PRECISION),
         0,
         0,
         ROUND(wi.net_quantity, WIP_CONSTANTS.MAX_DISPLAYED_PRECISION),
         bom.common_bill_sequence_id,
         rtg.common_routing_sequence_id,
         wi.bom_revision,
         wi.routing_revision,
         TO_DATE(TO_CHAR(wi.bom_revision_date,
                         WIP_CONSTANTS.DT_NOSEC_FMT),
                 WIP_CONSTANTS.DT_NOSEC_FMT),
         TO_DATE(TO_CHAR(wi.routing_revision_date,
                         WIP_CONSTANTS.DT_NOSEC_FMT),
                 WIP_CONSTANTS.DT_NOSEC_FMT),
         wi.lot_number,
         wi.alternate_bom_designator,
         wi.alternate_routing_designator,
         wi.completion_subinventory,
         wi.completion_locator_id,
         wi.demand_class,
         wi.project_id,
         wi.task_id,
         decode(wi.load_type, WIP_CONSTANTS.CREATE_EAM_JOB, NULL, wi.schedule_group_id),
         decode(wi.load_type, WIP_CONSTANTS.CREATE_EAM_JOB, NULL, wi.build_sequence),
         wi.line_id,
         wi.kanban_card_id,
         wi.overcompletion_tolerance_type,
         wi.overcompletion_tolerance_value,
         wi.end_item_unit_number,
         params.po_creation_time,
         nvl(wi.priority,WIP_CONSTANTS.DEFAULT_PRIORITY),
         TO_DATE(TO_CHAR(wi.due_date,
                         WIP_CONSTANTS.DT_NOSEC_FMT),
                 WIP_CONSTANTS.DT_NOSEC_FMT),
         TO_DATE(TO_CHAR(wi.requested_start_date,
                         WIP_CONSTANTS.DT_NOSEC_FMT),
                 WIP_CONSTANTS.DT_NOSEC_FMT),
         decode(wi.load_type, WIP_CONSTANTS.CREATE_EAM_JOB, wi.parent_wip_entity_id, NULL),
         decode(wi.load_type, WIP_CONSTANTS.CREATE_EAM_JOB, wi.asset_group_id, NULL),
         decode(wi.load_type, WIP_CONSTANTS.CREATE_EAM_JOB, wi.asset_number, NULL),
         decode(wi.load_type, WIP_CONSTANTS.CREATE_EAM_JOB, wi.owning_department, NULL),
         decode(wi.load_type, WIP_CONSTANTS.CREATE_EAM_JOB, wi.rebuild_item_id, NULL),
         decode(wi.load_type, WIP_CONSTANTS.CREATE_EAM_JOB, wi.rebuild_serial_number, NULL),
         decode(wi.load_type, WIP_CONSTANTS.CREATE_EAM_JOB, wi.manual_rebuild_flag, NULL),
         decode(wi.load_type, WIP_CONSTANTS.CREATE_EAM_JOB, wi.activity_type, NULL),
         decode(wi.load_type, WIP_CONSTANTS.CREATE_EAM_JOB, wi.activity_cause, NULL),
         decode(wi.load_type, WIP_CONSTANTS.CREATE_EAM_JOB, wi.activity_source, NULL),
         decode(wi.load_type, WIP_CONSTANTS.CREATE_EAM_JOB, wi.work_order_type, NULL),
         decode(wi.load_type, WIP_CONSTANTS.CREATE_EAM_JOB, wi.notification_required, NULL),
         decode(wi.load_type, WIP_CONSTANTS.CREATE_EAM_JOB, wi.shutdown_type, NULL),
         decode(wi.load_type, WIP_CONSTANTS.CREATE_EAM_JOB, wi.pm_schedule_id, NULL),
         decode(wi.load_type, WIP_CONSTANTS.CREATE_EAM_JOB, l_plan_maint, NULL),
         decode(wi.load_type, WIP_CONSTANTS.CREATE_EAM_JOB, wi.tagout_required, NULL),
         wi.attribute_category,
         wi.attribute1,
         wi.attribute2,
         wi.attribute3,
         wi.attribute4,
         wi.attribute5,
         wi.attribute6,
         wi.attribute7,
         wi.attribute8,
         wi.attribute9,
         wi.attribute10,
         wi.attribute11,
         wi.attribute12,
         wi.attribute13,
         wi.attribute14,
         wi.attribute15,
         wi.maintenance_object_id,
         wi.maintenance_object_type,
         wi.maintenance_object_source,
         wi.material_issue_by_mo,
         decode(wi.load_type, WIP_CONSTANTS.CREATE_JOB, wi.serialization_start_op,
                              WIP_CONSTANTS.CREATE_NS_JOB, wi.serialization_start_op, NULL)
        FROM wip_accounting_classes wac,
             bom_operational_routings rtg,
             bom_bill_of_materials bom,
             wip_parameters params,
             wip_job_schedule_interface wi
        WHERE
            wi.rowid = WIP_JSI_Utils.current_rowid
        AND nvl(rtg.cfm_routing_flag,2) = 2
        AND wac.class_code(+)=wi.class_code
        AND wac.organization_id(+)=wi.organization_id
        AND rtg.organization_id(+)=wi.organization_id
        AND NVL(rtg.alternate_routing_designator(+),'NONEXISTENT') =
        NVL(wi.alternate_routing_designator,'NONEXISTENT')
        AND rtg.assembly_item_id(+) =
            decode(wi.load_type,1,wi.primary_item_id, wi.routing_reference_id)
        AND bom.assembly_item_id (+) =
            decode(wi.load_type,1,wi.primary_item_id, wi.bom_reference_id)
        AND bom.organization_id (+) = wi.organization_id
        AND NVL(bom.alternate_bom_designator (+),'NON_EXISTENT') =
            NVL(wi.alternate_bom_designator,'NON_EXISTENT')
        AND params.organization_id = wi.organization_id ;

        INSERT INTO WIP_ENTITIES
        (wip_entity_id,
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
        SELECT
        wi.wip_entity_id,
        wi.organization_id,
        SYSDATE,
        wi.last_updated_by,
        SYSDATE,
        wi.created_by,
        wi.last_update_login,
        wi.request_id,
        wi.program_application_id,
        wi.program_id,
        SYSDATE,
        wi.job_name,
        decode(wi.load_type, WIP_CONSTANTS.CREATE_EAM_JOB, 6, 1),
        wi.description,
        wi.primary_item_id,
  MTL_GEN_OBJECT_ID_S.nextval
        FROM WIP_JOB_SCHEDULE_INTERFACE wi
        WHERE wi.rowid = WIP_JSI_Utils.current_rowid ;

        /* Fix for Bug#3201290 */
        if ((x_load_type = WIP_CONSTANTS.CREATE_EAM_JOB)
            and (x_status_type = WIP_CONSTANTS.RELEASED)) then
           WIP_EAM_UTILS.create_default_operation ( x_org_id,
                                                    x_entity_id
                                                  ) ;
        end if ;

        -- bug#2798688, per eam team, copy attachments is only needed when
        -- creating jobs through massload(or PM scheduler which uses ML)
        select wdj.organization_id, wdj.wip_entity_id, wdj.primary_item_id,
               wdj.common_bom_sequence_id, wdj.common_routing_sequence_id
        into
               x_org_id, x_entity_id, x_item_id, x_cmn_bom_seq_id, x_cmn_routing_seq_id
        FROM wip_discrete_jobs wdj,
             wip_job_schedule_interface wi
        WHERE
            wi.rowid = WIP_JSI_Utils.current_rowid and
            wi.wip_entity_id = wdj.wip_entity_id;

         WIP_EAM_UTILS.copy_attachments(
           'Y',                 /* copy_asset_attachments         IN VARCHAR2, */
           'Y',                 /* copy_activity_attachments      IN VARCHAR2, */
           'Y',                 /* copy_activity_bom_attachments  IN VARCHAR2, */
           'Y',                 /* copy_activity_rtng_attachments IN VARCHAR2, */
           x_org_id,            /* p_organization_id              IN NUMBER, */
           x_entity_id,         /* p_wip_entity_id                IN NUMBER, */
           x_item_id,           /* p_primary_item_id              IN NUMBER, */
           x_cmn_bom_seq_id,    /* p_common_bom_sequence_id       IN NUMBER, */
           x_cmn_routing_seq_id /* p_common_routing_sequence_id   IN NUMBER */
           );


  elsif (x_load_type IN (WIP_CONSTANTS.RESCHED_JOB, WIP_CONSTANTS.RESCHED_EAM_JOB)) then

        UPDATE WIP_DISCRETE_JOBS WDJ
        SET (   LAST_UPDATED_BY,
                last_update_login,
                request_id,
                program_application_id,
                program_id,
                program_update_date,
                LAST_UPDATE_DATE,
                FIRM_PLANNED_FLAG,
                LOT_NUMBER,
                START_QUANTITY,
                NET_QUANTITY,
                STATUS_TYPE,
                DATE_RELEASED,
                DATE_COMPLETED,     /*Bug Number 4760788*/
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
                WORK_ORDER_TYPE,
                OWNING_DEPARTMENT,
                ACTIVITY_TYPE,
                ACTIVITY_CAUSE,
                ACTIVITY_SOURCE,
                NOTIFICATION_REQUIRED,
                SHUTDOWN_TYPE,
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
                MAINTENANCE_OBJECT_ID,
                MAINTENANCE_OBJECT_TYPE,
                MAINTENANCE_OBJECT_SOURCE,
                material_issue_by_mo,
                BOM_REVISION_DATE,
                BOM_REVISION,
                SERIALIZATION_START_OP) =
                (SELECT LAST_UPDATED_BY,
                        LAST_UPDATE_LOGIN,
                        request_id,
                        program_application_id,
                        program_id,
                        SYSDATE,
                        SYSDATE,
                        NVL(WJ.FIRM_PLANNED_FLAG,WDJ.FIRM_PLANNED_FLAG),
                        NVL(WJ.LOT_NUMBER,WDJ.LOT_NUMBER),
                        decode(wj.load_type, 7, 1, 8, WDJ.START_QUANTITY,
                            NVL(ROUND(WJ.START_QUANTITY,
                                WIP_CONSTANTS.MAX_DISPLAYED_PRECISION),
                                WDJ.START_QUANTITY)),
                        decode(wj.load_type, 7, 1, 8, WDJ.START_QUANTITY,
                            NVL(ROUND(WJ.NET_QUANTITY,
                                WIP_CONSTANTS.MAX_DISPLAYED_PRECISION),
                                WDJ.NET_QUANTITY)),
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
                               NVL(TO_DATE(TO_CHAR(WJ.FIRST_UNIT_START_DATE,WIP_CONSTANTS.DT_NOSEC_FMT), WIP_CONSTANTS.DT_NOSEC_FMT),
                               WDJ.SCHEDULED_START_DATE),/*Fix for Bug 8784056 (FP of 8704687), format date before upate WDJ*/
                               NVL(TO_DATE(TO_CHAR(WJ.LAST_UNIT_COMPLETION_DATE,WIP_CONSTANTS.DT_NOSEC_FMT), WIP_CONSTANTS.DT_NOSEC_FMT),
 	                             WDJ.SCHEDULED_COMPLETION_DATE),/*Fix for Bug 8784056 (FP of 8704687), format date before upate WDJ*/
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
                        ) ,
                        decode (
                          WJ.PROJECT_ID,
                          null, WDJ.TASK_ID,
                                WJ.TASK_ID
                        ) ,
    -- bug#4099186
    -- if rescheduling, sub/loc are now modifiable
    -- will update from both  wjsi.completion_subinventory and
    -- and wjsi.locator only if wjsi.completion_subinventory is not null
                        nvl(wj.completion_subinventory, wdj.completion_subinventory),
                        decode (
                          wj.completion_subinventory,
                          null, wdj.completion_locator_id,
                                wj.completion_locator_id),
                        /*decode (
                          WJ.PROJECT_ID,
                          null, WDJ.COMPLETION_LOCATOR_ID,
                          WJ.COMPLETION_LOCATOR_ID
                        ) ,*/

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
                        decode(wj.load_type, WIP_CONSTANTS.RESCHED_EAM_JOB, NVL(wj.work_order_type, WDJ.WORK_ORDER_TYPE),
                                                                            WDJ.WORK_ORDER_TYPE),
                        decode(wj.load_type, WIP_CONSTANTS.RESCHED_EAM_JOB, NVL(WJ.OWNING_DEPARTMENT, WDJ.OWNING_DEPARTMENT),
                                                                            WDJ.OWNING_DEPARTMENT),
                        decode(wj.load_type, WIP_CONSTANTS.RESCHED_EAM_JOB, NVL(wj.activity_type, WDJ.ACTIVITY_TYPE),
                                                                            WDJ.ACTIVITY_TYPE),
                        decode(wj.load_type, WIP_CONSTANTS.RESCHED_EAM_JOB, NVL(wj.activity_cause, WDJ.ACTIVITY_CAUSE),
                                                                            WDJ.ACTIVITY_CAUSE),
                        decode(wj.load_type, WIP_CONSTANTS.RESCHED_EAM_JOB, NVL(wj.activity_source, WDJ.ACTIVITY_SOURCE),
                                                                            WDJ.ACTIVITY_SOURCE),
                        decode(wj.load_type, WIP_CONSTANTS.RESCHED_EAM_JOB, NVL(WJ.NOTIFICATION_REQUIRED, WDJ.NOTIFICATION_REQUIRED),
                                                                            WDJ.NOTIFICATION_REQUIRED),
                        decode(wj.load_type, WIP_CONSTANTS.RESCHED_EAM_JOB, NVL(wj.shutdown_type, WDJ.SHUTDOWN_TYPE),
                                                                            WDJ.SHUTDOWN_TYPE),
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
                        NVL(WJ.MAINTENANCE_OBJECT_ID,WDJ.MAINTENANCE_OBJECT_ID),
                        NVL(WJ.MAINTENANCE_OBJECT_TYPE,WDJ.MAINTENANCE_OBJECT_TYPE),
                        NVL(WJ.MAINTENANCE_OBJECT_SOURCE,WDJ.MAINTENANCE_OBJECT_SOURCE),
                        NVL(WJ.material_issue_by_mo,WDJ.material_issue_by_mo),
                        NVL(TO_DATE(TO_CHAR(wj.bom_revision_date,
                                            WIP_CONSTANTS.DT_NOSEC_FMT),
                                    WIP_CONSTANTS.DT_NOSEC_FMT),
                            WDJ.BOM_REVISION_DATE),
                        NVL(WJ.BOM_REVISION,WDJ.BOM_REVISION),
                        DECODE(WJ.LOAD_TYPE, WIP_CONSTANTS.RESCHED_JOB,
                                             NVL(WJ.SERIALIZATION_START_OP, WDJ.SERIALIZATION_START_OP), WDJ.SERIALIZATION_START_OP)
                FROM WIP_JOB_SCHEDULE_INTERFACE WJ
                WHERE WJ.ROWID = WIP_JSI_Utils.current_rowid)
        WHERE WDJ.WIP_ENTITY_ID = x_entity_id ;

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
                           WHERE WJ.ROWID = WIP_JSI_Utils.current_rowid)
        WHERE WE.WIP_ENTITY_ID = x_entity_id ;

        /* Fix for Bug#3201290 */
        if ((x_load_type = WIP_CONSTANTS.RESCHED_EAM_JOB)
            and (x_status_type = WIP_CONSTANTS.RELEASED)) then
           WIP_EAM_UTILS.create_default_operation ( x_org_id,
                                                    x_entity_id
                                                  ) ;
        end if ;

        if (x_load_type in (WIP_CONSTANTS.RESCHED_JOB, WIP_CONSTANTS.RESCHED_LOT_JOB) and
            wip_picking_pub.is_job_pick_released(x_entity_id, x_rep_sched_id, x_org_id) and
            x_old_start_quantity <> x_new_start_quantity) then
           FND_MESSAGE.set_name('WIP','WIP_QTY_REQ_CHANGE_WARNING');
           wip_jsi_utils.record_current_error(TRUE);

           wip_picking_pub.Update_Job_BackOrdQty (p_wip_entity_id => x_entity_id,
                 p_repetitive_schedule_id => x_rep_sched_id,
                 p_new_job_qty => x_new_start_quantity,
                 x_return_status => l_status,
                 x_msg_data => l_msg_data);

           if(l_status <> FND_API.G_RET_STS_SUCCESS) then
              fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
              fnd_message.set_token('ERROR_TEXT', 'WIP_JSI_Processor.update_parent_table calling => ' ||
                    'wip_picking_pub.Update_Job_BackOrdQty: ' || SQLERRM);
               wip_jsi_utils.record_current_error;
           end if;
        end if;


        if(x_load_type = WIP_CONSTANTS.RESCHED_JOB AND x_status_type in
               (WIP_CONSTANTS.COMP_NOCHRG, WIP_CONSTANTS.HOLD, wip_constants.cancelled)) then
           wip_picking_pvt.cancel_allocations(p_wip_entity_id => x_entity_id,
                                             p_wip_entity_type => wip_constants.discrete,
                                             x_return_status => l_status,
                                             x_msg_data => l_msg_data);
           if(l_status <> FND_API.G_RET_STS_SUCCESS) then
              fnd_message.set_name('WIP', 'WIP_UNEXPECTED_ERROR');
              fnd_message.set_token('ERROR_TEXT', 'WIP_JSI_Processor.update_parent_table calling => ' ||
                    'wip_picking_pub.Update_Job_BackOrdQty: ' || SQLERRM);
               wip_jsi_utils.record_current_error;
           end if;
        end if;

  elsif (x_load_type = WIP_CONSTANTS.CREATE_SCHED) then

        INSERT INTO WIP_REPETITIVE_SCHEDULES(
                repetitive_schedule_id,
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
                wip_entity_id,
                line_id,
                daily_production_rate,
                processing_work_days,
                status_type,
                firm_planned_flag,
                alternate_bom_designator,
                common_bom_sequence_id,
                bom_revision,
                bom_revision_date,
                alternate_routing_designator,
                common_routing_sequence_id,
                routing_revision,
                routing_revision_date,
                first_unit_start_date,
                first_unit_completion_date,
                last_unit_start_date,
                last_unit_completion_date,
                quantity_completed,
                description,
                demand_class,
                material_account,
                material_overhead_account,
                material_variance_account,
                outside_processing_account,
                outside_proc_variance_account,
                overhead_account,
                overhead_variance_account,
                resource_account,
                resource_variance_account,
                po_creation_time,
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
        SELECT
                wi.repetitive_schedule_id,
                wi.organization_id,
                SYSDATE,
                wi.last_updated_by,
                SYSDATE,
                wi.created_by,
                wi.last_update_login,
                wi.request_id,
                wi.program_application_id,
                wi.program_id,
                SYSDATE,
                ri.wip_entity_id,
                wi.line_id,
                wi.daily_production_rate,
                wi.processing_work_days,
                WIP_CONSTANTS.PEND_REPML,
                wi.firm_planned_flag,
                ri.alternate_bom_designator,
                bom.common_bill_sequence_id,
                wi.bom_revision,
                TO_DATE(TO_CHAR(wi.bom_revision_date,
                                WIP_CONSTANTS.DT_NOSEC_FMT),
                        WIP_CONSTANTS.DT_NOSEC_FMT),
                ri.alternate_routing_designator,
                bor.common_routing_sequence_id,
                wi.routing_revision,
                TO_DATE(TO_CHAR(wi.routing_revision_date,
                                WIP_CONSTANTS.DT_NOSEC_FMT),
                        WIP_CONSTANTS.DT_NOSEC_FMT),
                TO_DATE(TO_CHAR(wi.first_unit_start_date,
                                WIP_CONSTANTS.DT_NOSEC_FMT),
                        WIP_CONSTANTS.DT_NOSEC_FMT),
                TO_DATE(TO_CHAR(wi.first_unit_completion_date,
                                WIP_CONSTANTS.DT_NOSEC_FMT),
                        WIP_CONSTANTS.DT_NOSEC_FMT),
                TO_DATE(TO_CHAR(wi.last_unit_start_date,
                                WIP_CONSTANTS.DT_NOSEC_FMT),
                        WIP_CONSTANTS.DT_NOSEC_FMT),
                TO_DATE(TO_CHAR(wi.last_unit_completion_date,
                                WIP_CONSTANTS.DT_NOSEC_FMT),
                        WIP_CONSTANTS.DT_NOSEC_FMT),
                0,      /* quantity completed */
                wi.description,
                wi.demand_class,
                ac.material_account,
                ac.material_overhead_account,
                ac.material_variance_account,
                ac.outside_processing_account,
                ac.outside_proc_variance_account,
                ac.overhead_account,
                ac.overhead_variance_account,
                ac.resource_account,
                ac.resource_variance_account,
                params.po_creation_time,
                wi.attribute_category,
                wi.attribute1,
                wi.attribute2,
                wi.attribute3,
                wi.attribute4,
                wi.attribute5,
                wi.attribute6,
                wi.attribute7,
                wi.attribute8,
                wi.attribute9,
                wi.attribute10,
                wi.attribute11,
                wi.attribute12,
                wi.attribute13,
                wi.attribute14,
                wi.attribute15
        FROM
                bom_operational_routings bor,
                bom_bill_of_materials bom,
                wip_repetitive_items ri,
                wip_accounting_classes ac,
                wip_parameters params,
                wip_job_schedule_interface wi
        WHERE   wi.rowid = WIP_JSI_Utils.current_rowid
            AND nvl(bor.cfm_routing_flag,2) = 2
            AND ri.organization_id = wi.organization_id
            AND ri.primary_item_id = wi.primary_item_id
            AND ri.line_id = wi.line_id
            AND bor.assembly_item_id (+) = ri.primary_item_id
            AND bor.organization_id (+) = ri.organization_id
            AND NVL(bor.alternate_routing_designator (+),'NON_EXISTENT') =
                NVL(ri.alternate_routing_designator,'NON_EXISTENT')
            AND bom.assembly_item_id (+) = ri.primary_item_id
            AND bom.organization_id (+) = ri.organization_id
            AND NVL(bom.alternate_bom_designator (+),'NON_EXISTENT') =
                NVL(ri.alternate_bom_designator,'NON_EXISTENT')
            AND ac.class_code = ri.class_code
            AND ac.organization_id = wi.organization_id
            AND params.organization_id = wi.organization_id ;

  end if ;
/*
   Fix for Bug#2034660

  if (x_load_type in (WIP_CONSTANTS.CREATE_JOB,
                      WIP_CONSTANTS.CREATE_SCHED
                      ) and
      x_status_type = WIP_CONSTANTS.released)
  then
    WIP_OSP.release_validation(x_entity_id, x_org_id, x_rep_sched_id) ;
  end if;

*/
END update_parent_tables ;



PROCEDURE Run_Report(P_Group_Id IN NUMBER) IS
req_id NUMBER;
wait BOOLEAN;
phase VARCHAR2(2000);
status VARCHAR2(2000);
devphase VARCHAR2(2000);
devstatus VARCHAR2(2000);
message VARCHAR2(2000);
BEGIN

req_id := FND_REQUEST.SUBMIT_REQUEST
                ('WIP','WIPMLINT',NULL,NULL,FALSE,
                  to_char(P_Group_Id), NULL, to_char(WIP_CONSTANTS.NO),
                  chr(0), NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
                  NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);

commit;

if req_id = 0 then
        NULL;
else

        -- We wait 100 minutes for the report.

        wait := FND_CONCURRENT.WAIT_FOR_REQUEST
                        (req_id, 10, 36000, phase, status, devphase,
                         devstatus, message);

end if;

END Run_Report;

PROCEDURE Delete_Completed_Records(P_Group_Id IN NUMBER) IS
BEGIN

        DELETE  FROM WIP_INTERFACE_ERRORS
        WHERE   INTERFACE_ID IN
                (SELECT INTERFACE_ID
                 FROM   WIP_JOB_SCHEDULE_INTERFACE
                 WHERE  PROCESS_PHASE = WIP_CONSTANTS.ML_COMPLETE
                 AND    GROUP_ID = P_Group_Id
                 AND    PROCESS_STATUS = WIP_CONSTANTS.ML_COMPLETE);

        DELETE  FROM WIP_JOB_SCHEDULE_INTERFACE
        WHERE   GROUP_ID = P_Group_Id
        AND     PROCESS_PHASE = WIP_CONSTANTS.ML_COMPLETE
        AND     PROCESS_STATUS = WIP_CONSTANTS.ML_COMPLETE;

END Delete_Completed_Records;

PROCEDURE ML_Release(P_Wip_Entity_Id IN NUMBER,
                    P_Organization_Id IN NUMBER,
                    P_Class_Code IN VARCHAR2,
                    P_New_Status_Type IN NUMBER,
                    P_Success_Flag OUT NOCOPY NUMBER,
                    P_Error_Msg OUT NOCOPY VARCHAR2) IS
x_dummy NUMBER;
BEGIN
        WIP_CHANGE_STATUS.Release
        (P_Wip_Entity_Id,
         P_Organization_Id,
         NULL, NULL,
         P_Class_Code,
         WIP_CONSTANTS.UNRELEASED,
         P_New_Status_Type,
         x_dummy);

        P_Success_Flag := 1;
EXCEPTION
        WHEN OTHERS THEN
                P_Success_Flag := 0;
                P_Error_Msg := SUBSTR(FND_MESSAGE.get,1,500);
END ML_Release;

PROCEDURE ML_Status_Change(P_Wip_Entity_Id IN NUMBER,
                    P_Organization_Id IN NUMBER,
                    P_Class_Code IN VARCHAR2,
                    P_New_Status_Type IN NUMBER,
                    P_Old_Status_Type IN NUMBER,
                    P_Success_Flag OUT NOCOPY NUMBER,
                    P_Error_Msg OUT NOCOPY VARCHAR2) IS
BEGIN
        IF P_Old_Status_Type = 1 THEN
                ML_Release(P_Wip_Entity_Id,
                           P_Organization_Id,
                           P_Class_Code,
                           P_New_Status_Type,
                           P_Success_Flag,
                           P_Error_Msg);
        ELSE
                WIP_UNRELEASE.Unrelease(P_Organization_Id,
                                        P_Wip_Entity_Id,
                                        NULL,
                                        NULL,
                                        1);

        END IF;

        P_Success_Flag := 1;

EXCEPTION
        WHEN OTHERS THEN
                P_Success_Flag := 0;
                P_Error_Msg := SUBSTR(FND_MESSAGE.get,1,500);
END;


END WIP_JSI_Processor ;

/
