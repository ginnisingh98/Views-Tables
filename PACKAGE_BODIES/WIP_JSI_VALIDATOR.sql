--------------------------------------------------------
--  DDL for Package Body WIP_JSI_VALIDATOR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_JSI_VALIDATOR" as
/* $Header: wipjsivb.pls 120.3.12010000.2 2009/06/12 15:55:17 shjindal ship $ */

  procedure setup;
  procedure load_type;
  procedure organization_id;
  procedure job_name;
  procedure job_id;
  procedure entity_type;
  procedure kanban_card_id;
  procedure created_by;
  procedure last_updated_by;
  procedure start_quantity;
  procedure net_quantity;
  procedure firm_planned_flag;
  procedure demand_class;
  procedure line_id;
  procedure schedule_group_id;
  procedure build_sequence;
  procedure status_type;
  procedure processing_work_days;
  procedure daily_production_rate;
  procedure repetitive_schedule_id;
  procedure primary_item_id;
  procedure wip_supply_type;
  procedure routing_reference_id;
  procedure bom_reference_id;
  procedure alternate_routing_designator;
  procedure alternate_bom_designator;
  procedure project_id;
  procedure task_id;
  procedure project_task_id;
  procedure schedule_dates;
  procedure scheduling_method;
  procedure completion_subinventory;
  procedure completion_locator_id;
  procedure due_date;
  procedure date_released;
  procedure requested_start_date;
  procedure end_item_unit_number;
  procedure overcompletion;
  procedure class_code;
  procedure estimate_lead_time;
  procedure bom_revision;
  procedure routing_revision;
  procedure validate_date_released; /* 2424987 */

--added for eAM
  procedure asset_group_id;
  procedure asset_number;
  procedure rebuild_item_id;
  procedure rebuild_serial_number;
  procedure parent_wip_entity_id;
  procedure manual_rebuild_flag;
  procedure owning_department;
  procedure notification_required;
  procedure shutdown_type;
  procedure tagout_required;
  procedure plan_maintenance;
  procedure work_order_type;
  procedure activity_type;
  procedure activity_cause;
  procedure maintenance_object_type;
  procedure maintenance_object_source;
  procedure maintenance_object_id;
  procedure pm_schedule_id;
  procedure activity_source;
--end eAM

 type wdj_rec_t is RECORD (status_type NUMBER,
                           entity_type NUMBER,
                           job_type NUMBER,
                           start_quantity NUMBER,
                           quantity_completed NUMBER,
                           firm_planned_flag NUMBER,
                           primary_item_id NUMBER,
                           bom_reference_id NUMBER,
                           routing_reference_id NUMBER,
                           line_id NUMBER,
                           schedule_group_id NUMBER,
                           scheduled_completion_date DATE,
                           project_id NUMBER,
                           task_id NUMBER,
                           completion_subinventory VARCHAR2(30),
                           completion_locator_id NUMBER,
                           rebuild_item_id NUMBER);

  type item_rec_t is RECORD(inventory_item_id NUMBER,
                            eam_item_type NUMBER,
                            pick_components_flag VARCHAR2(1),
                            build_in_wip_flag  VARCHAR2(1),
                            eng_item_flag VARCHAR2(1),
                            inventory_asset_flag VARCHAR2(1),
                            restrict_subinventories_code NUMBER,
                            restrict_locators_code NUMBER,
                            location_control_code NUMBER,
                            fixed_lead_time NUMBER,
                            variable_lead_time NUMBER);


  wjsi_row wip_job_schedule_interface%ROWTYPE;
  wdj_row wdj_rec_t;
  primary_item_row item_rec_t;
  routing_ref_row item_rec_t;
  g_dummy NUMBER;
  orig_org_context number ;

  procedure validate is

  /* Added following variables for Bug# 4184566 and also in update statement */

  x_request_id number     ;
  x_program_id number     ;
  x_application_id number ;

  begin

      x_request_id     := fnd_global.conc_request_id ;
      x_program_id     := fnd_global.conc_program_id ;
      x_application_id := fnd_global.prog_appl_id    ;

    select *
      into wjsi_row
      from wip_job_schedule_interface
     where rowid = wip_jsi_utils.current_rowid;

    -- Save Original org context
    orig_org_context := nvl(fnd_profile.value('ORG_ID'), -1) ;

    --defaults all values in record
    --issues any ignored value warnings
    --sets the org context (needed for pjm validations)
    wip_jsi_defaulter.default_values(p_wjsi_row => wjsi_row);

    -- Fixed bug 7638816
    wjsi_row.schedule_group_id := WIP_JSI_Hooks.get_default_schedule_group_id (
                                  wjsi_row.interface_id,
                                  wjsi_row.schedule_group_id);

    /* Fixed bug 3977669 */
    if ( wjsi_row.load_type <> wip_constants.create_sched and
         wjsi_row.build_sequence is NULL) then

      if (wjsi_row.load_type = wip_constants.resched_job) then
        select WDJ.build_sequence
          into wjsi_row.build_sequence
          from wip_discrete_jobs WDJ
         where WDJ.wip_entity_id = wjsi_row.wip_entity_id ;
      else
        wjsi_row.build_sequence := null;
      end if;

      wjsi_row.build_sequence := WIP_JSI_Hooks.get_default_build_sequence (
                                  wjsi_row.interface_id,
                                  wjsi_row.build_sequence);
    end if;
    --select records from other tables that need to be accessed multiple times throughout the validation
    --procedures, e.g. mtl_system_items row for the primary item
    setup;

    --only perform a subset of the validations, mostly those odd cases in which the validation procedures
    --modify or insert date
    if(wip_jsi_utils.validation_level in (wip_constants.mrp, wip_constants.ato)) then
      job_name;
      job_id;
      entity_type;
      schedule_group_id;
      demand_class;
      primary_item_id;
      scheduling_method;
      project_task_id;
      project_id;
      task_id;
      completion_subinventory;
      completion_locator_id;
      class_code;
      estimate_lead_time;
      due_date;
      --date_released; /*check made in validate_date_released*/
      requested_start_date;
      overcompletion;
      bom_revision;      --added for bug 2375060
      routing_revision;  --added for bug 2375060
      validate_date_released; /* 2424987 */
    else --do full validations
      load_type;
      organization_id;
      job_name;
      job_id;
      entity_type;
      kanban_card_id;
      created_by;
      last_updated_by;
      start_quantity;
      net_quantity;
      firm_planned_flag;
      repetitive_schedule_id;
      demand_class;
      line_id;
      schedule_group_id;
      build_sequence;
      status_type;
      processing_work_days;
      daily_production_rate;
--added for EAM
      asset_group_id;
      asset_number;
      rebuild_item_id;
      maintenance_object_type;
      maintenance_object_source;
      rebuild_serial_number;
      maintenance_object_id;
--
      primary_item_id;
      wip_supply_type;
      routing_reference_id;
      bom_reference_id;
      alternate_routing_designator;
      alternate_bom_designator;
      project_task_id;
      project_id;
      task_id;
      schedule_dates;
      scheduling_method;
      completion_subinventory;
      completion_locator_id;
      due_date;
      requested_start_date;
      end_item_unit_number;
      overcompletion;
--added for EAM
      pm_schedule_id;
      parent_wip_entity_id;
--
      class_code;
      estimate_lead_time;
      bom_revision;
      routing_revision;
      validate_date_released; /* 2424987 */
--added for EAM
      owning_department;
      activity_cause;
      activity_source;
      plan_maintenance;
      notification_required;
      work_order_type;
      manual_rebuild_flag;
      tagout_required;
      shutdown_type;
      activity_type;
--
    end if;
    update wip_job_schedule_interface
       set created_by = wjsi_row.created_by,
           last_updated_by = wjsi_row.last_updated_by,
           organization_id = wjsi_row.organization_id,
           wip_entity_id = wjsi_row.wip_entity_id,
           job_name      = wjsi_row.job_name,
           repetitive_schedule_id = wjsi_row.repetitive_schedule_id,
           schedule_group_id = wjsi_row.schedule_group_id,
           line_id = wjsi_row.line_id,
           project_id = wjsi_row.project_id,
           task_id  = wjsi_row.task_id,
           firm_planned_flag = wjsi_row.firm_planned_flag,
           description = wjsi_row.description,
           status_type = wjsi_row.status_type,
           wip_supply_type = wjsi_row.wip_supply_type,
           class_code = wjsi_row.class_code,
           primary_item_id = wjsi_row.primary_item_id,
           start_quantity = wjsi_row.start_quantity,
           net_quantity = wjsi_row.net_quantity,
           overcompletion_tolerance_type = wjsi_row.overcompletion_tolerance_type,
           overcompletion_tolerance_value = wjsi_row.overcompletion_tolerance_value,
           asset_number = wjsi_row.asset_number,--20
           asset_group_id = wjsi_row.asset_group_id,
           parent_job_name = wjsi_row.parent_job_name,
           parent_wip_entity_id = wjsi_row.parent_wip_entity_id,
           rebuild_item_id = wjsi_row.rebuild_item_id,
           rebuild_serial_number = wjsi_row.rebuild_serial_number,
           manual_rebuild_flag = wjsi_row.manual_rebuild_flag,
           first_unit_start_date = wjsi_row.first_unit_start_date,
           last_unit_start_date = wjsi_row.last_unit_start_date,
           first_unit_completion_date = wjsi_row.first_unit_completion_date,
           last_unit_completion_date = wjsi_row.last_unit_completion_date,
           due_date = wjsi_row.due_date,
           requested_start_date = wjsi_row.requested_start_date,
           processing_work_days = wjsi_row.processing_work_days,--30
           daily_production_rate = wjsi_row.daily_production_rate,
           header_id = wjsi_row.header_id,
           demand_class = wjsi_row.demand_class,
           build_sequence = wjsi_row.build_sequence,
           routing_reference_id = wjsi_row.routing_reference_id,
           bom_reference_id = wjsi_row.bom_reference_id,
           alternate_routing_designator = wjsi_row.alternate_routing_designator,
           alternate_bom_designator = wjsi_row.alternate_bom_designator,
           bom_revision = wjsi_row.bom_revision,
           routing_revision = wjsi_row.routing_revision,--40
           bom_revision_date = wjsi_row.bom_revision_date,
           routing_revision_date = wjsi_row.routing_revision_date,
           lot_number = wjsi_row.lot_number,
           source_code = wjsi_row.source_code,
           source_line_id = wjsi_row.source_line_id,
           scheduling_method = wjsi_row.scheduling_method,
           completion_subinventory = wjsi_row.completion_subinventory,
           completion_locator_id = wjsi_row.completion_locator_id,
           priority = wjsi_row.priority,
           allow_explosion = wjsi_row.allow_explosion,
           end_item_unit_number = wjsi_row.end_item_unit_number, --must be after primary_item_id
           owning_department = wjsi_row.owning_department,
           notification_required = wjsi_row.notification_required,--50
           shutdown_type = wjsi_row.shutdown_type,
           work_order_type = wjsi_row.work_order_type,
           tagout_required = wjsi_row.tagout_required,
           plan_maintenance = wjsi_row.plan_maintenance,
           activity_type = wjsi_row.activity_type,
           activity_cause = wjsi_row.activity_cause,
           material_issue_by_mo = wjsi_row.material_issue_by_mo,
           maintenance_object_id = wjsi_row.maintenance_object_id,
           maintenance_object_type = wjsi_row.maintenance_object_type,
           maintenance_object_source = wjsi_row.maintenance_object_source,
           REQUEST_ID = decode(x_request_id,-1,REQUEST_ID,x_request_id),
           PROGRAM_ID = decode(x_program_id,-1,PROGRAM_ID,x_program_id),
           PROGRAM_UPDATE_DATE = SYSDATE,
           PROGRAM_APPLICATION_ID = decode(x_application_id,-1,PROGRAM_APPLICATION_ID, x_application_id)
     where rowid = wip_jsi_utils.current_rowid;

  -- Set Original org context since org context might have
  -- different for pjm validation
  if (orig_org_context <> -1) then
      fnd_client_info.set_org_context(to_char(orig_org_context)) ;
  end if ;

/* Fixed for Bug#3060266
   Abort if any errors were detected. */
  if (WIP_JSI_Utils.any_nonwarning_errors) then
    WIP_JSI_Utils.abort_request ;
  end if ;

  end validate;

--This procedure is slightly different from the other validation procedures.
--It cannot use the wjsi_row global b/c it is not called during the validation
--phase. It must be called after the explosion phase so WO will be populated
--with the job operations.
  procedure validate_serialization_op is

    l_startOp NUMBER;
    l_wipID NUMBER;
    l_primaryItemID NUMBER;
    l_serialOp NUMBER;
    l_loadType NUMBER;
    l_jobType NUMBER;
    cursor c_ops(v_wip_id number) is
      select operation_seq_num
        from wip_operations
       where wip_entity_id = v_wip_id;

      l_curOpSeq NUMBER;
      l_rtgExists boolean := false;
      l_opFound boolean := false;
  begin
    select wip_entity_id, serialization_start_op, load_type, primary_item_id
      into l_wipID, l_serialOp, l_loadType, l_primaryItemID
      from wip_job_schedule_interface wjsi
     where wjsi.rowid = wip_jsi_utils.current_rowid;


    if(l_serialOp is null) then
    --in this case, we may need to clear the serialization op if the routing was re-exploded
      if(l_loadType = wip_constants.resched_job) then
        update wip_discrete_jobs wdj
           set serialization_start_op = null
         where wip_entity_id = l_wipID
           and serialization_start_op <> 1
           and not exists(select 1
                            from wip_operations wo
                           where wo.wip_entity_id = wdj.wip_entity_id
                             and wo.operation_seq_num = wdj.serialization_start_op);
      end if;
      return;
    end if;

    --if serial op provided, the load type must be discrete or ns job
    if(l_loadType not in (wip_constants.create_job,
                          wip_constants.create_ns_job,
                          wip_constants.resched_job)) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    --job must have an assembly, and the assembly must be serial controlled (predefined).
    select 1
      into g_dummy
      from wip_discrete_jobs wdj, mtl_system_items msi
     where wdj.primary_item_id = msi.inventory_item_id
       and wdj.organization_id = msi.organization_id
       and wdj.wip_entity_id = l_wipID
       and msi.serial_number_control_code = wip_constants.full_sn;

    open c_ops(v_wip_id => l_wipID);

    loop
      fetch c_ops into l_curOpSeq;
      exit when c_ops%NOTFOUND;
      l_rtgExists := true;
      if(l_curOpSeq = l_serialOp) then
        l_opFound := true;
        exit;
      end if;
    end loop;

    close c_ops;

    --The routing exists, but an invalid op seq was provided
    if(l_rtgExists and not l_opFound) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    --If no routing exsts, the serialization op must be 1.
    if(not l_rtgExists and l_serialOp <> 1) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    --job must be unreleased to change the serialization op on a
    --reschedule request. This is to guarantee no txns
    --have taken place.
    if(l_loadType = wip_constants.resched_job) then
      select 1
        into g_dummy
        from wip_discrete_jobs
        where wip_entity_id = l_wipID
        and status_type = wip_constants.unreleased;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_SERIAL_START_OP');
      wip_jsi_utils.abort_request;
  end validate_serialization_op;


/* private procedures */
  procedure populate_item(p_item_id  in number,
                          p_org_id   in number,
                          x_item_row out nocopy item_rec_t) is begin
        select inventory_item_id,
               nvl(eam_item_type, -1),
               pick_components_flag,
               build_in_wip_flag,
               eng_item_flag,
               inventory_asset_flag,
               restrict_subinventories_code,
               restrict_locators_code,
               location_control_code,
               fixed_lead_time,
               variable_lead_time
          into x_item_row.inventory_item_id,
               x_item_row.eam_item_type,
               x_item_row.pick_components_flag,
               x_item_row.build_in_wip_flag,
               x_item_row.eng_item_flag,
               x_item_row.inventory_asset_flag,
               x_item_row.restrict_subinventories_code,
               x_item_row.restrict_locators_code,
               x_item_row.location_control_code,
               x_item_row.fixed_lead_time,
               x_item_row.variable_lead_time
          from mtl_system_items
         where inventory_item_id = p_item_id
           and organization_id = p_org_id;
  end populate_item;

  procedure setup is begin
    if(wjsi_row.load_type in (wip_constants.resched_job, wip_constants.resched_eam_job)) then
      select status_type,
             entity_type,
             job_type,
             start_quantity,
             quantity_completed,
             firm_planned_flag,
             wdj.primary_item_id,
             bom_reference_id,
             routing_reference_id,
             line_id,
             schedule_group_id,
             scheduled_completion_date,
             project_id,
             task_id,
             completion_subinventory,
             completion_locator_id,
             rebuild_item_id
        into wdj_row.status_type,
             wdj_row.entity_type,
             wdj_row.job_type,
             wdj_row.start_quantity,
             wdj_row.quantity_completed,
             wdj_row.firm_planned_flag,
             wdj_row.primary_item_id,
             wdj_row.bom_reference_id,
             wdj_row.routing_reference_id,
             wdj_row.line_id,
             wdj_row.schedule_group_id,
             wdj_row.scheduled_completion_date,
             wdj_row.project_id,
             wdj_row.task_id,
             wdj_row.completion_subinventory,
             wdj_row.completion_locator_id,
             wdj_row.rebuild_item_id
        from wip_discrete_jobs wdj, wip_entities we
       where wdj.wip_entity_id = wjsi_row.wip_entity_id
         and we.wip_entity_id = wjsi_row.wip_entity_id;
      if(wdj_row.primary_item_id is not null) then
        populate_item(p_item_id  => wdj_row.primary_item_id,
                      p_org_id   => wjsi_row.organization_id,
                      x_item_row => primary_item_row);
      end if;
      if(wdj_row.routing_reference_id is not null) then
        populate_item(p_item_id  => wdj_row.routing_reference_id,
                      p_org_id   => wjsi_row.organization_id,
                      x_item_row => routing_ref_row);
      end if;
    else --job/sched creation
      if(wjsi_row.primary_item_id is not null) then
        populate_item(p_item_id  => wjsi_row.primary_item_id,
                      p_org_id   => wjsi_row.organization_id,
                      x_item_row => primary_item_row);
      end if;
      if(wjsi_row.routing_reference_id is not null) then
        populate_item(p_item_id  => wjsi_row.routing_reference_id,
                      p_org_id   => wjsi_row.organization_id,
                      x_item_row => routing_ref_row);
      end if;
    end if;
  exception
    when others then
      null;
  end setup;

  procedure load_type is begin
    if(wjsi_row.load_type not in (wip_constants.create_job, wip_constants.create_sched, wip_constants.resched_job,
                                  wip_constants.create_ns_job, wip_constants.create_eam_job, wip_constants.resched_eam_job)) then
      raise fnd_api.g_exc_unexpected_error;
    end if;
    if((wjsi_row.load_type = wip_constants.resched_job and wdj_row.entity_type = wip_constants.eam) or
       (wjsi_row.load_type = wip_constants.resched_eam_job and wdj_row.entity_type <> wip_constants.eam)) then
      raise fnd_api.g_exc_unexpected_error;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_LOAD_TYPE');
      wip_jsi_utils.abort_request;
  end load_type;

  procedure organization_id is
    l_disable_date date;
  begin
    -- Bug 4890215. Performance Fix
    -- sugupta 26th-May-2006
    /*
    select ood.disable_date
      into l_disable_date
      from wip_parameters wp, mtl_parameters mp, org_organization_definitions ood
     where wp.organization_id = mp.organization_id
       and wp.organization_id = ood.organization_id
       and wp.organization_id = wjsi_row.organization_id;
    */
    SELECT ood.date_to disable_date
    INTO l_disable_date
    FROM wip_parameters wp,
        mtl_parameters mp ,
        hr_organization_units ood
    WHERE wp.organization_id   = mp.organization_id
        and wp.organization_id = ood.organization_id
        and wp.organization_id = wjsi_row.organization_id;

    if(l_disable_date < sysdate) then
      raise fnd_api.g_exc_unexpected_error;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_ORGANIZATION_ID');
      wip_jsi_utils.abort_request;
  end organization_id;

  procedure job_name is
    l_count NUMBER;
  begin
    if(wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_ns_job, wip_constants.create_eam_job) and
       wjsi_row.job_name is not null) then
      select count(*)
        into l_count
        from wip_entities
       where wip_entity_name = wjsi_row.job_name
         and organization_id = wjsi_row.organization_id;
      if(l_count > 0) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_JOB_NAME');
      wip_jsi_utils.abort_request;
  end job_name;

  procedure entity_type is
  begin
    if (wjsi_row.load_type in (wip_constants.create_eam_job,
                               wip_constants.resched_eam_job) or
         wdj_row.entity_type in (WIP_CONSTANTS.LOTBASED, WIP_CONSTANTS.EAM)) then
       raise fnd_api.g_exc_unexpected_error;
    end if;

  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_ENTITY_TYPE');
      wip_jsi_utils.abort_request;
  end entity_type;

  procedure job_id is
    l_count NUMBER;
  begin
    if(wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_ns_job, wip_constants.create_eam_job)) then
      select count(*)
        into l_count
        from wip_entities
       where wip_entity_id = wjsi_row.wip_entity_id;
      if(l_count > 0) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;
  exception
    when others then
      WIP_JSI_Utils.record_error('WIP_ML_WIP_ENTITY_ID') ;
      wip_jsi_utils.abort_request;
  end job_id;

  procedure kanban_card_id is
    l_doc_type NUMBER;
    l_doc_header_id NUMBER;
    l_status VARCHAR2(100);
    l_msg VARCHAR2(30) := 'WIP_ML_KB_SRC_NOT_INV';
  begin
    if(wjsi_row.kanban_card_id is null) then
      return;
    end if;

    if (wip_jsi_utils.validation_level <> wip_constants.inv) then
      raise fnd_api.g_exc_unexpected_error;
    end if ;

    l_msg := 'WIP_ML_KB_UPDATE_FAILED';
    l_doc_header_id := wjsi_row.wip_entity_id ;
    if(wjsi_row.load_type = wip_constants.create_job) then
      l_doc_type := INV_Kanban_PVT.G_doc_type_Discrete_Job ;
    elsif(wjsi_row.load_type = wip_constants.create_sched) then
      l_doc_type := INV_Kanban_PVT.G_doc_type_Rep_Schedule ;
    else
      raise fnd_api.g_exc_unexpected_error;
    end if;

      -- Tell Inventory to update the kanban card's supply status.
      -- Abort this request if unsuccessful.
    begin
      inv_kanban_pvt.update_card_supply_status (
        x_return_status      => l_status,
        p_kanban_card_id     => wjsi_row.kanban_card_id,
        p_supply_status      => INV_Kanban_PVT.G_Supply_Status_InProcess,
        p_document_type      => l_doc_type,
        p_document_header_id => l_doc_header_id);
    exception
      when others then
         l_status := null ;
    end ;

    if((l_status is null) or (l_status <> fnd_api.g_ret_sts_success)) then
      raise fnd_api.g_exc_unexpected_error;
    end if ;
  exception
    when others then
      WIP_JSI_Utils.record_error(l_msg) ;
      WIP_JSI_Utils.abort_request ;
  end kanban_card_id ;

  procedure created_by is begin
  select 1
    into g_dummy
    from fnd_user
   where user_id = wjsi_row.created_by
     and sysdate between start_date and nvl(end_date, sysdate);
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_CREATED_BY');
      WIP_JSI_Utils.abort_request ;
  end created_by;

  procedure last_updated_by is begin
  select 1
    into g_dummy
    from fnd_user
   where user_id = wjsi_row.last_updated_by
     and sysdate between start_date and nvl(end_date, sysdate);
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_LAST_UPDATED_BY');
      WIP_JSI_Utils.abort_request ;
  end last_updated_by;

  procedure start_quantity is
    l_reserved_qty NUMBER;
    l_reservation_count NUMBER;
    l_msg VARCHAR2(30) := 'WIP_ML_START_QUANTITY';
  begin
    if(wjsi_row.start_quantity < 0) then
      raise fnd_api.g_exc_unexpected_error;
    elsif(wjsi_row.load_type in (wip_constants.create_job,  wip_constants.create_ns_job) and
       wjsi_row.start_quantity is null) then
      raise fnd_api.g_exc_unexpected_error;
    elsif(wjsi_row.load_type = wip_constants.create_job and wjsi_row.start_quantity = 0) then
      raise fnd_api.g_exc_unexpected_error;
    elsif(wjsi_row.load_type = wip_constants.resched_job) then
      if(wjsi_row.start_quantity = 0 and wdj_row.job_type = wip_constants.standard) then
        raise fnd_api.g_exc_unexpected_error;
      elsif(wjsi_row.start_quantity < wdj_row.quantity_completed) then
        l_msg := 'WIP_ML_RESCHEDULE_QUANTITY';
        raise fnd_api.g_exc_unexpected_error;
      else
        select sum(primary_quantity), count(*)
          into l_reserved_qty, l_reservation_count
          from wip_reservations_v
         where wip_entity_id = wjsi_row.wip_entity_id
           and organization_id = wjsi_row.organization_id;
         if(l_reservation_count > 0 and
            wjsi_row.start_quantity < l_reserved_qty) then
           l_msg := 'WIP_ML_RESCHEDULE_QUANTITY';
           raise fnd_api.g_exc_unexpected_error;
         end if;
      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error(l_msg);
      wip_jsi_utils.abort_request;
  end start_quantity;

  procedure net_quantity is begin

    if(wjsi_row.load_type <> wip_constants.create_sched and wjsi_row.net_quantity is not null) then
      if(wjsi_row.net_quantity not between 0 and wjsi_row.start_quantity) then
        raise fnd_api.g_exc_unexpected_error;
      --can't have net qty when creating a ns job w/no item or rescheduling a ns job w/no item
      elsif(wjsi_row.net_quantity is not null and wjsi_row.net_quantity <> 0 and
            ((wjsi_row.load_type = wip_constants.create_ns_job and wjsi_row.primary_item_id is null) or
             (wjsi_row.load_type = wip_constants.resched_job and
              wdj_row.job_type = wip_constants.nonstandard and
              wdj_row.primary_item_id is null))) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_NET_QUANTITY');
      wip_jsi_utils.abort_request;

  end net_quantity;

  procedure firm_planned_flag is begin
    if((wjsi_row.firm_planned_flag = wip_constants.yes and wjsi_row.load_type = wip_constants.create_ns_job) or
       (wjsi_row.firm_planned_flag = wip_constants.yes and
        wdj_row.job_type = wip_constants.nonstandard and
        wjsi_row.load_type in (wip_constants.resched_job, wip_constants.resched_eam_job)) or
       (wjsi_row.firm_planned_flag not in (wip_constants.yes, wip_constants.no))) then
      raise fnd_api.g_exc_unexpected_error;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_FIRM_PLANNED_FLAG');
  end firm_planned_flag;

  procedure repetitive_schedule_id is
    l_rep_sched_count NUMBER;
  begin
    if(wjsi_row.load_type = wip_constants.create_sched) then
      if(wjsi_row.repetitive_schedule_id is null) then
        raise fnd_api.g_exc_unexpected_error;
      else
        select count(*)
          into l_rep_sched_count
          from wip_repetitive_schedules
         where repetitive_schedule_id = wjsi_row.repetitive_schedule_id;

        if(l_rep_sched_count > 0) then
          raise fnd_api.g_exc_unexpected_error;
        end if;
      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_REPETITIVE_SCHEDULE_ID');
      wip_jsi_utils.abort_request;
  end repetitive_schedule_id;

  procedure demand_class is begin
    if(wjsi_row.demand_class is not null and wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_sched,
                                                                    wip_constants.create_ns_job, wip_constants.create_eam_job)) then
      select 1
        into g_dummy
        from so_demand_classes_active_v
       where demand_class_code = wjsi_row.demand_class;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_DEMAND_CLASS');
  end demand_class;

  procedure line_id is begin
    if(wjsi_row.load_type = wip_constants.create_sched and wjsi_row.line_id is null) then
      raise fnd_api.g_exc_unexpected_error;
    elsif(wjsi_row.line_id is not null) then
      select 1
        into g_dummy
        from wip_lines_val_v
       where line_id = wjsi_row.line_id
         and organization_id = wjsi_row.organization_id;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_LINE_ID');
      wip_jsi_utils.abort_request;
  end line_id;

  procedure schedule_group_id is begin
    if(wjsi_row.schedule_group_id is not null and
       wjsi_row.load_type in (wip_constants.create_job, wip_constants.resched_job, wip_constants.create_ns_job)) then
      select 1
        into g_dummy
        from wip_schedule_groups_val_v
       where schedule_group_id = wjsi_row.schedule_group_id
         and organization_id = wjsi_row.organization_id;
    end if;  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_SCHEDULE_GROUP');
  end schedule_group_id;

  procedure build_sequence is
    l_retval boolean;
  begin
    if(wjsi_row.build_sequence is not null and
       wjsi_row.load_type in (wip_constants.create_job, wip_constants.resched_job, wip_constants.create_ns_job)) then
      l_retval := wip_validate.build_sequence(p_build_sequence => wjsi_row.build_sequence,
                                             p_wip_entity_id => wjsi_row.wip_entity_id,
                                             p_organization_id => wjsi_row.organization_id,
                                             p_line_id => nvl(wjsi_row.line_id, wdj_row.line_id),
                                             p_schedule_group_id => nvl(wjsi_row.schedule_group_id, wdj_row.schedule_group_id));
      if(not l_retval) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_BUILD_SEQUENCE');
  end build_sequence;

  procedure status_type is
    l_msg varchar2(30) := 'WIP_ML_STATUS_TYPE';
/* bug 2308832 - Added check_so_link cursor for sales order checking
       of complete and cancelled statuses of jobs */
    l_qty_reserved number := 0;
    l_Primary_Item_Id number ;  /* for Bug 2792736 */
    l_propagate_job_change_to_po NUMBER;
    l_return_status VARCHAR2(1);

    CURSOR CHECK_SO_LINK IS
        SELECT NVL(SUM(PRIMARY_QUANTITY),0)
        FROM   WIP_RESERVATIONS_V
        WHERE  WIP_ENTITY_ID = wjsi_row.Wip_Entity_Id
        AND    INVENTORY_ITEM_ID = nvl(wjsi_row.primary_item_id,l_Primary_Item_Id )
        AND    ORGANIZATION_ID = wjsi_row.Organization_Id;

  begin
    --on job creation, status must be unreleased, released, on hold, or draft
    if(wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_ns_job, wip_constants.create_eam_job) and
       wjsi_row.status_type not in (wip_constants.unreleased, wip_constants.released, wip_constants.hold, wip_constants.draft)) then
      raise fnd_api.g_exc_unexpected_error;

    --on reschedule, status must be unreleased, released, complete charges allowed, on hold, cancelled, or pending scheduling
    elsif(wjsi_row.load_type in (wip_constants.resched_job, wip_constants.resched_eam_job)) then

      --if not changing the status type, skip status type validation processing
      if(wjsi_row.status_type is null) then
        return;
      end if;

      if(wjsi_row.status_type not in (wip_constants.unreleased, wip_constants.released, wip_constants.comp_chrg,
                      wip_constants.hold, wip_constants.cancelled, wip_constants.pend_sched) and
                      -- new comp_nochrg status is allowed in eam if old status is comp_chrg
                      (wjsi_row.status_type <> wip_constants.comp_nochrg or wdj_row.status_type <> wip_constants.comp_chrg
                       or wjsi_row.load_type <> wip_constants.resched_eam_job)) then
        raise fnd_api.g_exc_unexpected_error;

      --additionally, you can not reschedule jobs that are in certain statuses
      elsif(wdj_row.status_type not in (wip_constants.unreleased, wip_constants.released, wip_constants.comp_chrg,
                                        wip_constants.hold, wip_constants.cancelled)) then
        if(wjsi_row.load_type = wip_constants.resched_eam_job and
          --wdj_row.status_type in (wip_constants.pend_sched, wip_constants.draft)) then
           (wdj_row.status_type in (wip_constants.pend_sched) or
            -- draft cannot be changed to cancel for eam jobs
            (wdj_row.status_type in (wip_constants.draft) and
             wjsi_row.status_type not in (wip_constants.cancelled)))) then
          --these statuses ok for rescheduling eam jobs
          return;
        end if;
        l_msg := 'WIP_ML_WIP_DJ_RESCHEDULE';
        raise fnd_api.g_exc_unexpected_error;
      end if;
/* Bug 2308832 - Added below if condition for sales order/PO checking */
    IF (wjsi_row.status_type IN (WIP_CONSTANTS.CANCELLED,
                                 WIP_CONSTANTS.COMP_CHRG,
                                 WIP_CONSTANTS.COMP_NOCHRG)) THEN

      /* Bug#2893368 - Added if condition to check whether primary item id
          in wip_job_schedule_interface is null */
      if ( wjsi_row.primary_item_id is null ) then
        select primary_item_id      /* for Bug2792736 */
          into l_Primary_Item_Id
          from wip_discrete_jobs
         where wip_entity_id = wjsi_row.wip_entity_id
           and organization_id = wjsi_row.organization_id;
      end if;

      OPEN CHECK_SO_LINK;
      FETCH CHECK_SO_LINK INTO l_qty_reserved;
      CLOSE CHECK_SO_LINK;

      /* Bug 3927677 -> Give warning when job linked to SO is being completed,
       * and give error when job linked to SO is being cancelled or
       * complete-no charge.
       */
      if ( l_qty_reserved > 0 and
           wjsi_row.status_type in (wip_constants.cancelled,
                                    wip_constants.comp_nochrg)) then
         l_msg := 'WIP_CANT_CANCEL_SO';
         raise fnd_api.g_exc_unexpected_error;
      end if;

      if ( l_qty_reserved > 0 and
           wjsi_row.status_type = wip_constants.comp_chrg) then
         fnd_message.set_name('WIP','WIP_SO_EXISTS');
         wip_jsi_utils.record_current_error(p_warning_only => true);
      end if;

      /* End fix of 3927677 */

      if (wip_osp.po_req_exists ( wjsi_row.wip_entity_id,
                                  null,
                                  wjsi_row.organization_id,
                                  null,
                                  wip_constants.discrete
                                 ) = TRUE )  then
        IF (po_code_release_grp.Current_Release >=
            po_code_release_grp.PRC_11i_Family_Pack_J) THEN

            SELECT propagate_job_change_to_po
              INTO l_propagate_job_change_to_po
              FROM wip_parameters wp
             WHERE organization_id = wjsi_row.organization_id;

            IF(l_propagate_job_change_to_po = WIP_CONSTANTS.YES AND
               wjsi_row.status_type IN (WIP_CONSTANTS.CANCELLED,
                                        WIP_CONSTANTS.COMP_NOCHRG)) THEN
              -- cancel PO/requisition associated to the job if cancel or
              -- complete-no-charge
              wip_osp.cancelPOReq(p_job_id        => wjsi_row.wip_entity_id,
                                  p_org_id        => wjsi_row.organization_id,
                                  x_return_status => l_return_status);

              IF(l_return_status <> fnd_api. g_ret_sts_success) THEN
                -- If we are unable to cancel all PO/requisition associated
                -- to this job, we will try to cancel as much as we can,
                -- then user need to manually cancel the rest.
                po_warning_flag := WIP_CONSTANTS.YES;
                wip_jsi_utils.record_current_error(p_warning_only => true);
              END IF; -- check return status
            ELSE
              -- propagate_job_change_to_po is manual or job status is
              -- 'Complete'
              po_warning_flag := WIP_CONSTANTS.YES;
              fnd_message.set_name('WIP', 'WIP_CANCEL_JOB/SCHED_OPEN_PO');
              wip_jsi_utils.record_current_error(p_warning_only => true);
            END IF;
          ELSE
            -- customer does not have PO patchset J onward, so behave the
            -- old way
            po_warning_flag := WIP_CONSTANTS.YES;
            fnd_message.set_name('WIP', 'WIP_CANCEL_JOB/SCHED_OPEN_PO');
            wip_jsi_utils.record_current_error(p_warning_only => true);
          END IF;
        END IF; -- PO/requisition exists
      END IF; -- status is either 'Cancel','Complete', or 'Complete-no-charge'

    /* Bug 3032515 - Added validation to prevent updation to completed/
       cancelled/completed-no charges/closed jobs through planner module
       for which source code is populated as MSC */
      if ( wjsi_row.source_code = 'MSC' and wdj_row.status_type in
           (wip_constants.comp_chrg, wip_constants.comp_nochrg,
            wip_constants.cancelled, wip_constants.closed) ) then
         wip_jsi_utils.record_error('WIP_CANT_UPDATE_JOB');
         wip_jsi_utils.abort_request;
      end if;

      -- bug# 3436646: job cannot be changed to unreleased if it's been pick released
      if ( wjsi_row.status_type = WIP_CONSTANTS.UNRELEASED and
             wdj_row.status_type <> WIP_CONSTANTS.UNRELEASED and
             WIP_PICKING_PUB.Is_Job_Pick_Released(
                     p_wip_entity_id =>  wjsi_row.wip_entity_id,
                     p_org_id => wjsi_row.organization_id)) then
         l_msg := 'WIP_UNRLS_JOB/SCHED';
         raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;  -- JOB RESCHED : END

  exception
    when others then
      wip_jsi_utils.record_error(l_msg);
      wip_jsi_utils.abort_request;
  end status_type;

  procedure processing_work_days is begin
    if(wjsi_row.load_type = wip_constants.create_sched and
       (wjsi_row.processing_work_days <= 0 or wjsi_row.processing_work_days is null)) then
      raise fnd_api.g_exc_unexpected_error;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_PROCESSING_WORK_DAYS');
  end processing_work_days;

  procedure daily_production_rate is
  l_max_line_rate NUMBER;
  begin
    if(wjsi_row.load_type = wip_constants.create_sched) then
      if(wjsi_row.daily_production_rate <= 0 or wjsi_row.daily_production_rate is null) then
        raise fnd_api.g_exc_unexpected_error;
      end if;

      select daily_maximum_rate
        into l_max_line_rate
        from wip_lines_val_v
       where line_id = wjsi_row.line_id;

      if(l_max_line_rate < wjsi_row.daily_production_rate) then
        fnd_message.set_name('WIP',  'WIP_PROD_RATE_WARNING');
        fnd_message.set_token('ENTITY1', l_max_line_rate);
        wip_jsi_utils.record_current_error(p_warning_only => true);
      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_DAILY_PRODUCTION_RATE');
  end daily_production_rate;

  procedure primary_item_id is
    l_see_eng_items_flag VARCHAR2(1);
    l_msg VARCHAR2(30);
    l_start_date DATE;
    l_end_date DATE;
    l_dummy NUMBER;
    X_Eng_Items_Flag NUMBER;
  begin
    l_see_eng_items_flag := fnd_profile.value('WIP_SEE_ENG_ITEMS');

    if(wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_sched,
                              wip_constants.create_ns_job)) then
      if(wjsi_row.primary_item_id is null and wjsi_row.load_type <>  wip_constants.create_ns_job) then
        l_msg := 'WIP_ML_PRIMARY_ITEM_ID';
        raise fnd_api.g_exc_unexpected_error;
      elsif(wjsi_row.primary_item_id is not null) then
        if(primary_item_row.build_in_wip_flag <> 'Y' or
           primary_item_row.pick_components_flag <> 'N' or
           (l_see_eng_items_flag = wip_constants.no and primary_item_row.eng_item_flag = 'Y')) then
          l_msg := 'WIP_ML_PRIMARY_ITEM_ID';
          raise fnd_api.g_exc_unexpected_error;
        end if;
        if(wjsi_row.load_type = wip_constants.create_sched) then
          l_msg := 'WIP_ML_REPETITIVE_ITEM';
          select 1
            into g_dummy
            from wip_repetitive_items
           where line_id = wjsi_row.line_id
             and primary_item_id = wjsi_row.primary_item_id
             and organization_id = wjsi_row.organization_id;
        end if;
      end if;

      if(wjsi_row.primary_item_id is not null) then
         X_Eng_Items_Flag := to_number(FND_PROFILE.value('WIP_SEE_ENG_ITEMS'));
         begin
           select 1
             into l_dummy
           from MTL_SYSTEM_ITEMS msi
           where msi.inventory_item_id = wjsi_row.primary_item_id
             and msi.organization_id= wjsi_row.organization_id
             and msi.replenish_to_order_flag = 'Y'
             and msi.bom_item_type = 4
             and not exists
                 (SELECT COMMON_BILL_SEQUENCE_ID
                  FROM BOM_BILL_OF_MATERIALS
                  WHERE ASSEMBLY_ITEM_ID = wjsi_row.primary_item_id
                  AND ORGANIZATION_ID = wjsi_row.organization_id
                  AND nvl(ALTERNATE_BOM_DESIGNATOR,'none') =
                        nvl(wjsi_row.alternate_bom_designator,'none')
                  AND (ASSEMBLY_TYPE = 1 OR X_Eng_Items_Flag = 1));
         exception
           when no_data_found then
              l_dummy := 0;
         end;

         if (l_dummy = 1) then
           wip_jsi_utils.record_error('WIP_ML_ATO_ITEM_NO_BOM');
           wip_jsi_utils.abort_request;
         end if;
      end if;
    elsif(wjsi_row.load_type = wip_constants.create_eam_job and
          wjsi_row.primary_item_id is not null) then
      l_msg := 'WIP_ML_EAM_ACTIVITY';

      if(primary_item_row.eam_item_type <> 2) then
        raise fnd_api.g_exc_unexpected_error;
      end if;

      if(wjsi_row.maintenance_object_type = 1) then
        if(wjsi_row.rebuild_item_id is null) then
          select start_date_active, end_date_active
            into l_start_date, l_end_date
            from mtl_eam_asset_activities
           where asset_activity_id = wjsi_row.primary_item_id
             and organization_id = wjsi_row.organization_id
             and inventory_item_id = wjsi_row.asset_group_id
             and serial_number = wjsi_row.asset_number;
        else
          select min(start_date_active), min(end_date_active)
            into l_start_date, l_end_date
            from mtl_eam_asset_activities
           where asset_activity_id = wjsi_row.primary_item_id
             and organization_id = wjsi_row.organization_id
             and inventory_item_id = wjsi_row.rebuild_item_id
             and serial_number = wjsi_row.rebuild_serial_number;
        end if;
      elsif(wjsi_row.maintenance_object_type = 2 and
            wjsi_row.rebuild_item_id is not null) then

          select min(start_date_active), min(end_date_active)
            into l_start_date, l_end_date
            from mtl_eam_asset_activities
           where asset_activity_id = wjsi_row.primary_item_id
             and organization_id = wjsi_row.organization_id
             and inventory_item_id = wjsi_row.rebuild_item_id;

      elsif(wjsi_row.maintenance_object_type = 3 and
            wjsi_row.rebuild_item_id is not null) then

          select min(start_date_active), min(end_date_active)
            into l_start_date, l_end_date
            from mtl_eam_asset_activities
           where asset_activity_id = wjsi_row.primary_item_id
             and organization_id = wjsi_row.organization_id
             and inventory_item_id = wjsi_row.rebuild_item_id;
      end if;

      if(l_start_date is not null and
         l_start_date > nvl(wjsi_row.first_unit_start_date, wjsi_row.last_unit_completion_date)) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
      if(l_end_date is not null and
         l_end_date < nvl(wjsi_row.last_unit_completion_date, wjsi_row.first_unit_start_date)) then
        raise fnd_api.g_exc_unexpected_error;
      end if;

    end if;
  exception
    when others then
      wip_jsi_utils.record_error(l_msg);
      wip_jsi_utils.abort_request;
  end primary_item_id;

  procedure wip_supply_type is
    l_routing_count NUMBER;
  begin
    if(wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_ns_job, wip_constants.create_eam_job)) then
      if(wjsi_row.wip_supply_type not in (wip_constants.push, wip_constants.assy_pull, wip_constants.op_pull,
                                          wip_constants.bulk, wip_constants.vendor, wip_constants.phantom,
                                          wip_constants.based_on_bom)) then
        --not a valid supply type
        raise fnd_api.g_exc_unexpected_error;
      elsif(wjsi_row.load_type = wip_constants.create_ns_job and
            wjsi_row.primary_item_id is null and
            wjsi_row.wip_supply_type in (wip_constants.assy_pull, wip_constants.op_pull)) then
        --can't have pull components for ns job w/no assy
        raise fnd_api.g_exc_unexpected_error;
      elsif(wjsi_row.wip_supply_type = wip_constants.op_pull) then
        select count(*)
          into l_routing_count
          from bom_operational_routings
         where organization_id = wjsi_row.organization_id
           and assembly_item_id = decode(wjsi_row.load_type, wip_constants.create_ns_job, wjsi_row.routing_reference_id, wjsi_row.primary_item_id)
           and nvl(alternate_routing_designator, '@@@') = nvl(wjsi_row.alternate_routing_designator, '@@@')
           and nvl(cfm_routing_flag, 2) = 2; --ignore flow routings
         if(l_routing_count = 0) then
           --can't have op pulls if no routing exists!
           raise fnd_api.g_exc_unexpected_error;
         end if;
      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_WIP_SUPPLY_TYPE');
  end wip_supply_type;

  procedure routing_reference_id is begin
    if(wjsi_row.load_type = wip_constants.create_ns_job and
       wjsi_row.routing_reference_id is not null and
       (routing_ref_row.build_in_wip_flag <> 'Y' or
        routing_ref_row.pick_components_flag <> 'N' or
        routing_ref_row.eng_item_flag <> 'N')) then
      raise fnd_api.g_exc_unexpected_error;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_ROUTING_REFERENCE_ID');
      wip_jsi_utils.abort_request;
  end routing_reference_id;

  procedure bom_reference_id is begin
    if(wjsi_row.load_type = wip_constants.create_ns_job and
       wjsi_row.bom_reference_id is not null) then
      select 1
        into g_dummy
        from mtl_system_items
       where inventory_item_id = wjsi_row.bom_reference_id
         and organization_id = wjsi_row.organization_id
         and build_in_wip_flag = 'Y'
         and pick_components_flag = 'N'
         and eng_item_flag = 'N';
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_BOM_REFERENCE_ID');
      wip_jsi_utils.abort_request;
  end bom_reference_id;

  procedure alternate_routing_designator is
    l_is_flow_rtg NUMBER;
    l_rtg_item_id NUMBER;
    l_msg VARCHAR2(30);
  begin
    if(wjsi_row.alternate_routing_designator is not null) then
      if(wjsi_row.load_type = wip_constants.create_ns_job) then
        l_rtg_item_id := wjsi_row.routing_reference_id;
      elsif(wjsi_row.load_type = wip_constants.resched_job) then
        if(wdj_row.job_type = wip_constants.standard) then
          l_rtg_item_id := wdj_row.primary_item_id;
        else
          l_rtg_item_id := wdj_row.routing_reference_id;
        end if;
      else
        l_rtg_item_id := wjsi_row.primary_item_id;
      end if;
      l_is_flow_rtg := wip_cfm_filter.org_item_alt_is_cfm(wjsi_row.organization_id,
                                                          l_rtg_item_id,
                                                          wjsi_row.alternate_routing_designator);
      if(l_is_flow_rtg = wip_constants.yes) then
        l_msg := 'WIP_ERROR_CHOSEN_RTG_IS_CFM';
        raise fnd_api.g_exc_unexpected_error;
      end if;
      l_msg := 'WIP_ML_ALTERNATE_ROUTING';
      select 1
        into g_dummy
        from bom_routing_alternates_v
       where assembly_item_id = l_rtg_item_id
         and alternate_routing_designator = wjsi_row.alternate_routing_designator
         and organization_id = wjsi_row.organization_id
         and nvl(cfm_routing_flag, 2) = 2 --ignore flow routings
         and routing_type = 1;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error(l_msg);
  end alternate_routing_designator;

  procedure alternate_bom_designator is
    l_bom_item_id NUMBER;
  begin
    if(wjsi_row.alternate_bom_designator is not null) then
      if(wjsi_row.load_type = wip_constants.create_ns_job) then
        l_bom_item_id := wjsi_row.bom_reference_id;
      elsif(wjsi_row.load_type = wip_constants.resched_job) then
        if(wdj_row.job_type = wip_constants.standard) then
          l_bom_item_id := wdj_row.primary_item_id;
        else
          l_bom_item_id := wdj_row.bom_reference_id;
        end if;
      else
        l_bom_item_id := wjsi_row.primary_item_id;
      end if;

      select 1
        into g_dummy
        from bom_bill_alternates_v
       where assembly_item_id = l_bom_item_id
         and alternate_bom_designator = wjsi_row.alternate_bom_designator
         and organization_id = wjsi_row.organization_id
         and assembly_type = 1;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_ALTERNATE_BOM');
  end alternate_bom_designator;

  procedure project_id is begin
    if(wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_eam_job) and
       wjsi_row.project_id is not null) then
       -- fix MOAC, set id so project view works
       fnd_profile.put('MFG_ORGANIZATION_ID',wjsi_row.organization_id);
       -- Bug 4890215. Performance Fix
       -- sugupta 26th-May-2006
       select mpv.project_id --this query will return multiple rows if the project has tasks
         into g_dummy
         from pjm_projects_v mpv, pjm_project_parameters ppp, mtl_parameters mp
        where mpv.project_id = ppp.project_id
          and mpv.project_id = wjsi_row.project_id
          and ppp.organization_id = wjsi_row.organization_id
          and ppp.organization_id = mp.organization_id
          and nvl(mp.project_reference_enabled, 2) = wip_constants.yes;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_PROJECT_ID');
  end project_id;

  procedure task_id is
    l_project_id NUMBER;
  begin
    if(wjsi_row.task_id is not null) then
      if(wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_ns_job, wip_constants.create_eam_job)) then
        l_project_id := wjsi_row.project_id;
      else
        l_project_id := nvl(wjsi_row.project_id, wdj_row.project_id);
      end if;

      if (PJM_PROJECT.val_task_idtonum(l_project_id, wjsi_row.task_id) is null)
      then
        raise fnd_api.g_exc_unexpected_error;
      end if;

    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_TASK_ID');
  end task_id;

  procedure project_task_id is
     l_result VARCHAR2(1);
     l_errcode VARCHAR2(80);
     l_message VARCHAR2(2000);
  begin
     if(wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_eam_job) and wjsi_row.project_id is not null) then
       l_result := PJM_PROJECT.VALIDATE_PROJ_REFERENCES
          (x_inventory_org_id  => wjsi_row.organization_id,
           x_project_id        => wjsi_row.project_id,
           x_task_id           => wjsi_row.task_id,
           x_date1             => wjsi_row.first_unit_start_date,
           x_date2             => wjsi_row.last_unit_completion_date,
           x_calling_function  => 'WILMLX',
           x_error_code        => l_errcode
          );

       if ( l_result <> PJM_PROJECT.G_VALIDATE_SUCCESS ) then
           raise fnd_api.g_exc_unexpected_error;
       end if;
     end if;
  exception
    when others then
      wip_utilities.get_message_stack(p_delete_stack => 'T',
                                      p_msg => l_message);
      if (l_result = PJM_PROJECT.G_VALIDATE_FAILURE) then
         wip_jsi_utils.record_error_text(l_message, false);
         wip_jsi_utils.abort_request;
      else
         wip_jsi_utils.record_error_text(l_message, true);
      end if;
  end project_task_id;

  procedure schedule_dates is
    l_line_count NUMBER;
    l_rtg_count NUMBER;
    l_date_count NUMBER := 0;
    l_msg VARCHAR2(30) := 'WIP_ML_SCHEDULE_DATES';
  begin
    if(wjsi_row.first_unit_start_date is not null) then
      l_date_count := l_date_count + 1;
    end if;

    if(wjsi_row.last_unit_completion_date is not null) then
      l_date_count := l_date_count + 1;
    end if;

    if(wjsi_row.load_type = wip_constants.create_ns_job and
       wjsi_row.routing_reference_id is null and
       l_date_count <> 2) then
      --must provide both dates when creating a ns job
      raise fnd_api.g_exc_unexpected_error;
    end if;

    if(wjsi_row.load_type = wip_constants.resched_job and
          wdj_row.job_type = wip_constants.nonstandard and
          wdj_row.routing_reference_id is null and
          (l_date_count = 1)) then
      --when rescheduling a ns job and providing one date, it must have a routing
      raise fnd_api.g_exc_unexpected_error;
    end if;
    if(wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_ns_job, wip_constants.create_eam_job) and
       l_date_count = 0) then
      --all job creations must have at least one date
      raise fnd_api.g_exc_unexpected_error;
    end if;
    if(wjsi_row.load_type = wip_constants.resched_job and
       l_date_count = 0 and
       wjsi_row.start_quantity is not null) then
      --when changing the quantity, you must also provide a date
      raise fnd_api.g_exc_unexpected_error;
    end if;
    if(wjsi_row.load_type in (wip_constants.resched_job, wip_constants.resched_eam_job) and
          (wjsi_row.allow_explosion = 'N' or wjsi_row.allow_explosion = 'n') and
          (l_date_count not in (0,2))) then
      --if not exploding, then the user must provide both dates or none at all
      raise fnd_api.g_exc_unexpected_error;
    end if;
    if(wjsi_row.first_unit_start_date is not null) then
      select 1
        into g_dummy
        from bom_calendar_dates bcd, mtl_parameters mp
       where mp.organization_id = wjsi_row.organization_id
         and mp.calendar_code = bcd.calendar_code
         and mp.calendar_exception_set_id = bcd.exception_set_id
         and bcd.calendar_date = trunc(wjsi_row.first_unit_start_date);
    end if;
    if(wjsi_row.last_unit_completion_date is not null) then
      select 1
        into g_dummy
        from bom_calendar_dates bcd, mtl_parameters mp
       where mp.organization_id = wjsi_row.organization_id
         and mp.calendar_code = bcd.calendar_code
         and mp.calendar_exception_set_id = bcd.exception_set_id
         and bcd.calendar_date = trunc(wjsi_row.last_unit_completion_date);
    end if;

    --begin repetitive validation
    l_msg := 'WIP_ML_REPETITIVE_DATES';
    --include repetitive dates in date provided count
    if(wjsi_row.last_unit_start_date is not null) then
      l_date_count := l_date_count + 1;
      if(wjsi_row.load_type <> wip_constants.create_sched) then
        wip_jsi_utils.record_ignored_column_warning('LAST_UNIT_START_DATE');
      end if;
    end if;

    if(wjsi_row.first_unit_completion_date is not null) then
      l_date_count := l_date_count + 1;
      if(wjsi_row.load_type <> wip_constants.create_sched) then
        wip_jsi_utils.record_ignored_column_warning('FIRST_UNIT_COMPLETION_DATE');
      end if;
    end if;

    if(wjsi_row.load_type = wip_constants.create_sched) then
      if(l_date_count = 0) then
        --must provide at least one date for rep sched
        raise fnd_api.g_exc_unexpected_error;
      end if;

      if(l_date_count <> 1) then
        --if you do not enter exactly one date then...
        select count(*)
          into l_line_count
          from wip_lines
         where organization_id = wjsi_row.organization_id
           and line_id = wjsi_row.line_id
           and line_schedule_type = 1; --fixed
        if(l_line_count > 0) then
          --the line can not have a fixed lead time
          raise fnd_api.g_exc_unexpected_error;
        end if;
        select count(*)
          into l_rtg_count
          from bom_operational_routings bor, wip_repetitive_items wri
         where wri.line_id = wjsi_row.line_id
           and nvl(bor.cfm_routing_flag, 2) = 2 --ignore flow rtgs
           and wri.primary_item_id = wjsi_row.primary_item_id
           and wri.organization_id = wjsi_row.organization_id
           and nvl(bor.alternate_routing_designator,'@@') = nvl(wri.alternate_routing_designator,'@@')
           and bor.organization_id = wri.organization_id
           and bor.assembly_item_id = wri.primary_item_id;
        if(l_rtg_count > 0) then
          --the line can not have a routing
          raise fnd_api.g_exc_unexpected_error;
        end if;
      end if;

      select count(*)
        into l_rtg_count
        from bom_operational_routings bor, wip_repetitive_items wri
       where wri.line_id = wjsi_row.line_id
         and nvl(bor.cfm_routing_flag,2) = 2 --ignore flow routings
         and wri.primary_item_id = wjsi_row.primary_item_id
         and wri.organization_id = wjsi_row.organization_id
         and nvl(bor.alternate_routing_designator,'@@') = nvl(wri.alternate_routing_designator,'@@')
         and bor.organization_id = wri.organization_id
         and bor.assembly_item_id = wri.primary_item_id;

      select count(*)
        into l_line_count
        from wip_lines_val_v
       where organization_id = wjsi_row.organization_id
         and line_id = wjsi_row.line_id
         and line_schedule_type = 2;


      --providing exactly the first dates or the last dates is an error condition
      if(not (l_date_count = 2 and
              ((wjsi_row.first_unit_start_date is not null and wjsi_row.first_unit_completion_date is not null) or
               (wjsi_row.last_unit_start_date is not null and wjsi_row.last_unit_completion_date is not null)))) then
        if(l_rtg_count = 0 and l_line_count > 0) then
          raise fnd_api.g_exc_unexpected_error;
        end if;
      end if;

      if(l_line_count > 0 and l_rtg_count = 0) then
      --estimate schedule dates
        if(wjsi_row.first_unit_start_date is null) then
          -- Bug 4890215. Performance Fix
          -- sugupta 26th-May-2006
          /*
          select calendar_date
            into wjsi_row.first_unit_start_date
            from bom_calendar_dates bcd, mtl_parameters mp
            where mp.organization_id = wjsi_row.organization_id
              and bcd.exception_set_id = mp.calendar_exception_set_id
              and bcd.calendar_code = mp.calendar_code
              and seq_num = (select prior_seq_num - ceil(wjsi_row.processing_work_days)+1
                               from bom_calendar_dates b2
                              where b2.calendar_date = trunc(wjsi_row.last_unit_start_date)
                                and b2.calendar_code = bcd.calendar_code
                                and b2.exception_set_id = bcd.exception_set_id);
          */
          SELECT bcd.calendar_date
            INTO wjsi_row.first_unit_start_date
            FROM bom_calendar_dates bcd,
            mtl_parameters mp,
            bom_calendar_dates b2
          WHERE mp.organization_id     = wjsi_row.organization_id
            and bcd.exception_set_id = mp.calendar_exception_set_id
            and bcd.calendar_code    = mp.calendar_code
            and bcd.seq_num          = b2.prior_seq_num - ceil(wjsi_row.processing_work_days)+1
            and b2.calendar_date     = trunc(wjsi_row.last_unit_start_date)
            and b2.calendar_code     = mp.calendar_code;
        end if;
        if(wjsi_row.last_unit_start_date is null) then
          -- Bug 4890215. Performance Fix
          -- sugupta 26th-May-2006
          /*
          select calendar_date
            into wjsi_row.last_unit_start_date
            from bom_calendar_dates bcd, mtl_parameters mp
           where mp.organization_id = wjsi_row.organization_id
             and bcd.exception_set_id = mp.calendar_exception_set_id
             and bcd.calendar_code = mp.calendar_code
             and seq_num = (select next_seq_num + ceil(wjsi_row.processing_work_days)-1
                              from bom_calendar_dates b2
                             where b2.calendar_date = trunc(wjsi_row.first_unit_start_date)
                               and b2.calendar_code = bcd.calendar_code
                               and b2.exception_set_id = bcd.exception_set_id);
          */
          SELECT bcd.calendar_date
          INTO wjsi_row.last_unit_start_date
          FROM bom_calendar_dates bcd,
              mtl_parameters mp,
              bom_calendar_dates b2
          WHERE mp.organization_id     = wjsi_row.organization_id
              and bcd.exception_set_id = mp.calendar_exception_set_id
              and bcd.calendar_code    = mp.calendar_code
              and bcd.seq_num          = b2.prior_seq_num + ceil(wjsi_row.processing_work_days)-1
              and b2.calendar_date     = trunc(wjsi_row.first_unit_start_date)
              and b2.calendar_code     = mp.calendar_code;
        end if;
        if(wjsi_row.first_unit_completion_date is null) then
          -- Bug 4890215. Performance Fix
          -- sugupta 26th-May-2006
          /*
          select calendar_date
            into wjsi_row.first_unit_completion_date
            from bom_calendar_dates bcd, mtl_parameters mp
           where mp.organization_id = wjsi_row.organization_id
             and bcd.exception_set_id = mp.calendar_exception_set_id
             and bcd.calendar_code = mp.calendar_code
             and seq_num = (select prior_seq_num - ceil(wjsi_row.processing_work_days)+1
                              from bom_calendar_dates b2
                             where b2.calendar_date = trunc(wjsi_row.last_unit_completion_date)
                               and b2.calendar_code = bcd.calendar_code
                               and b2.exception_set_id = bcd.exception_set_id);
          */
          SELECT bcd.calendar_date
          INTO wjsi_row.first_unit_completion_date
          FROM bom_calendar_dates bcd,
              mtl_parameters mp,
              bom_calendar_dates b2
          WHERE mp.organization_id     = wjsi_row.organization_id
              and bcd.exception_set_id = mp.calendar_exception_set_id
              and bcd.calendar_code    = mp.calendar_code
              and bcd.seq_num          = b2.prior_seq_num - ceil(wjsi_row.processing_work_days)+1
              and b2.calendar_date     = trunc(wjsi_row.last_unit_completion_date)
              and b2.calendar_code     = mp.calendar_code;
        end if;
        if(wjsi_row.last_unit_completion_date is null) then
          -- Bug 4890215. Performance Fix
          -- sugupta 26th-May-2006
          /*
          select calendar_date
            into wjsi_row.last_unit_completion_date
            from bom_calendar_dates bcd, mtl_parameters mp
           where mp.organization_id = wjsi_row.organization_id
             and bcd.exception_set_id = mp.calendar_exception_set_id
             and bcd.calendar_code = mp.calendar_code
             and seq_num = (select next_seq_num + ceil(wjsi_row.processing_work_days)-1
                              from bom_calendar_dates b2
                             where b2.calendar_date = trunc(wjsi_row.first_unit_completion_date)
                               and b2.calendar_code = bcd.calendar_code
                               and b2.exception_set_id = bcd.exception_set_id) ;
          */
          SELECT bcd.calendar_date
          INTO wjsi_row.last_unit_completion_date
          FROM bom_calendar_dates bcd,
              mtl_parameters mp,
              bom_calendar_dates b2
          WHERE mp.organization_id     = wjsi_row.organization_id
              and bcd.exception_set_id = mp.calendar_exception_set_id
              and bcd.calendar_code    = mp.calendar_code
              and bcd.seq_num          = b2.prior_seq_num + ceil(wjsi_row.processing_work_days)-1
              and b2.calendar_date     = trunc(wjsi_row.first_unit_completion_date)
              and b2.calendar_code     = mp.calendar_code;
        end if;
      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error(l_msg);
      wip_jsi_utils.abort_request;
  end schedule_dates;

  procedure scheduling_method is
    l_msg_code VARCHAR2(30) := 'WIP_ML_SCHEDULING_METHOD';
  begin
    if(wjsi_row.load_type <> wip_constants.create_sched) then
      if(wjsi_row.scheduling_method not in (wip_constants.routing, wip_constants.leadtime,
                                            wip_constants.ml_manual)) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
      if(wjsi_row.scheduling_method = wip_constants.leadtime and
         ((wjsi_row.load_type = wip_constants.create_ns_job and wjsi_row.routing_reference_id is null) or
         (wjsi_row.load_type = wip_constants.resched_job and
          wdj_row.job_type = wip_constants.nonstandard and
          wdj_row.routing_reference_id is null))) then
        --can not do lead time for ns jobs that have no routing reference
        raise fnd_api.g_exc_unexpected_error;
      elsif(wjsi_row.scheduling_method = wip_constants.ml_manual) then
        if((wjsi_row.first_unit_start_date is null or wjsi_row.last_unit_completion_date is null) or
          wjsi_row.first_unit_start_date > wjsi_row.last_unit_completion_date) then
          raise fnd_api.g_exc_unexpected_error;
        end if;
      else --routing
        if(wjsi_row.allow_explosion in ('n','N') and
           wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_eam_job) and
           (wjsi_row.first_unit_start_date is null or wjsi_row.last_unit_completion_date is null)) then
          --if not exploding, the user must provide both dates.
          l_msg_code := 'WIP_ML_SCHEDULING_METHOD2';
          raise fnd_api.g_exc_unexpected_error;
        end if;
      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error(l_msg_code);
      wip_jsi_utils.abort_request;
  end scheduling_method;

  procedure completion_subinventory is
    l_inv_item_id NUMBER;
    l_inv_asset_flag VARCHAR2(1);
    l_restrict_subinv_code NUMBER;

  begin
    if(wjsi_row.load_type = wip_constants.create_ns_job and
       wjsi_row.primary_item_id is null and
       wjsi_row.completion_subinventory is not null) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    if(wjsi_row.load_type = wip_constants.create_eam_job and
       wjsi_row.rebuild_item_id is not null) then
      l_inv_item_id := wjsi_row.rebuild_item_id;
      select inventory_asset_flag, restrict_subinventories_code
        into l_inv_asset_flag, l_restrict_subinv_code
        from mtl_system_items
       where inventory_item_id = l_inv_item_id
         and organization_id = wjsi_row.organization_id;
    else
      l_inv_item_id := wjsi_row.primary_item_id;
      l_inv_asset_flag := primary_item_row.inventory_asset_flag;
      l_restrict_subinv_code := primary_item_row.restrict_subinventories_code;
    end if;
/*
    if(wjsi_row.completion_subinventory is not null and
       (wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_ns_job) or
       (wjsi_row.load_type = wip_constants.create_eam_job and
        wjsi_row.rebuild_item_id is not null))) then
      if(l_inv_item_id is not null) then
        if(l_restrict_subinv_code = wip_constants.yes) then
          if(l_inv_asset_flag = 'N') then
            -- If restricted sub, non-asset item, must be in MTL_ITEM_SUB_VAL_V
            select 1
              into g_dummy
              from mtl_item_sub_val_v
              where inventory_item_id = l_inv_item_id
              and organization_id = wjsi_row.organization_id
              and secondary_inventory_name = wjsi_row.completion_subinventory;
          else
            -- If restricted sub, asset item, must be in MTL_ITEM_AST_TRK_SUB_VAL_V
            select 1
              into g_dummy
              from mtl_item_sub_ast_trk_val_v
             where inventory_item_id = l_inv_item_id
               and organization_id = wjsi_row.organization_id
               and secondary_inventory_name = wjsi_row.completion_subinventory;
          end if;
        --now validate unrestricted items
        elsif(fnd_profile.value('INV:EXPENSE_TO_ASSET_TRANSFER') = 1) then
          select 1
            into g_dummy
            from mtl_subinventories_val_v
           where secondary_inventory_name = wjsi_row.completion_subinventory
             and organization_id = wjsi_row.organization_id
             and asset;
        else
          select 1
            into g_dummy
            from mtl_sub_ast_trk_val_v
           where secondary_inventory_name = wjsi_row.completion_subinventory
             and organization_id = wjsi_row.organization_id;
        end if;
      end if;
    end if;
*/
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_COMPLETION_SUBINVENTORY');
      wip_jsi_utils.abort_request;
  end completion_subinventory;

  procedure completion_locator_id is
    l_prj_loc_id NUMBER;
    l_msg VARCHAR2(30) := 'WIP_ML_LOCATOR_PROJ_TASK';
    l_org_loc_control NUMBER;
    l_sub_loc_control NUMBER;
    l_success boolean;
    l_item_id NUMBER;
    l_restrict_locs NUMBER;
    l_item_loc_control NUMBER;
  begin

    if((wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_ns_job) or
        (wjsi_row.load_type = wip_constants.create_eam_job and wjsi_row.rebuild_item_id is not null)) and
      wjsi_row.completion_subinventory is null) then
      if(wjsi_row.completion_locator_id is not null) then
        l_msg := 'WIP_ML_COMPLETION_LOCATOR';
        raise fnd_api.g_exc_unexpected_error;
      else
        return;
      end if;
    end if;

    if(wjsi_row.load_type in (wip_constants.create_eam_job, wip_constants.resched_eam_job)) then

      if(wjsi_row.load_type = wip_constants.create_eam_job) then
        l_item_id := wjsi_row.rebuild_item_id;
      else
        l_item_id := wdj_row.rebuild_item_id;
      end if;
      if(l_item_id is not null) then
        select restrict_locators_code, location_control_code
          into l_restrict_locs, l_item_loc_control
          from mtl_system_items
         where inventory_item_id = l_item_id
           and organization_id = wjsi_row.organization_id;
      else
        return; --no need for locator validation
      end if;
    else
      l_restrict_locs := primary_item_row.restrict_locators_code;
      l_item_loc_control := primary_item_row.location_control_code;
      l_item_id := primary_item_row.inventory_item_id;
    end if;

    --if rescheduling, sub/loc are not modifiable. Make sure new values don't get inserted
    --into the tables. For proj/task, default from the existing job if user is not changing them.
    if(wjsi_row.load_type in (wip_constants.resched_job, wip_constants.resched_eam_job)) then
      wjsi_row.completion_locator_id := wdj_row.completion_locator_id;
      wjsi_row.project_id := nvl(wjsi_row.project_id, wdj_row.project_id);
      wjsi_row.task_id := nvl(wjsi_row.task_id, wdj_row.task_id);
      wjsi_row.completion_subinventory := wdj_row.completion_subinventory;
    end if;
    -- if rescheduling, sub/loc are now modifiable.
    -- will update from both  wjsi.completion_subinventory and
    -- and wjsi.locator only if wjsi.completion_subinventory is not null
    if(wjsi_row.load_type in (wip_constants.resched_job, wip_constants.resched_eam_job)) then
      wjsi_row.project_id := nvl(wjsi_row.project_id, wdj_row.project_id);
      wjsi_row.task_id := nvl(wjsi_row.task_id, wdj_row.task_id);
      wjsi_row.completion_subinventory :=
            nvl(wjsi_row.completion_subinventory, wdj_row.completion_subinventory);
      if wjsi_row.completion_subinventory is not null then
          wjsi_row.completion_locator_id :=  nvl(wjsi_row.completion_locator_id,
                                                 wdj_row.completion_locator_id);
      end if;
    end if;

    -- Ask PJM to default the locator.
    -- If successful, PJM will set the output locator parameter.
    -- If unsuccessful, they will leave it at its current value or,
    -- if things really go wrong, throw a no_data_found.
    if(wjsi_row.project_id is not null) then
      if(pjm_project_locator.check_itemLocatorControl(wjsi_row.organization_id,
                                                      wjsi_row.completion_subinventory,
                                                      wjsi_row.completion_locator_id,
                                                      l_item_id,
                                                      2)) then
        pjm_project_locator.get_defaultProjectLocator(wjsi_row.organization_id,
                                                      wjsi_row.completion_locator_id,
                                                      wjsi_row.project_id,
                                                      wjsi_row.task_id,
                                                      l_prj_loc_id);
        if(l_prj_loc_id is not null) then
          wjsi_row.completion_locator_id := l_prj_loc_id; --for write to wjsi
          if(not pjm_project_locator.check_project_references(wjsi_row.organization_id,
                                                              l_prj_loc_id,
                                                              'SPECIFIC', -- validation mode
                                                              'Y', -- required?
                                                              wjsi_row.project_id,
                                                              wjsi_row.task_id)) then
            raise fnd_api.g_exc_unexpected_error;
          end if;
        end if;
      end if;
    end if;
    --done with project locator defaulting/validation.
    if(wjsi_row.load_type <> wip_constants.create_sched and
       wjsi_row.completion_subinventory is not null) then
      l_msg := 'WIP_ML_INVALID_LOCATOR';
      select sub.locator_type, mp.stock_locator_control_code
        into l_sub_loc_control, l_org_loc_control
        from mtl_secondary_inventories sub, mtl_parameters mp
       where sub.secondary_inventory_name = wjsi_row.completion_subinventory
         and sub.organization_id = wjsi_row.organization_id
         and mp.organization_id = wjsi_row.organization_id;

      wip_locator.validate(p_organization_id => wjsi_row.organization_id,
                   p_item_id                 => l_item_id,
                   p_subinventory_code       => wjsi_row.completion_subinventory,
                   p_org_loc_control         => l_org_loc_control,
                   p_sub_loc_control         => l_sub_loc_control,
                   p_item_loc_control        => l_item_loc_control,
                   p_restrict_flag           => l_restrict_locs,
                   p_neg_flag                => '',
                   p_action                  => '',
                   p_project_id              => wjsi_row.project_id,
                   p_task_id                 => wjsi_row.task_id,
                   p_locator_id              => wjsi_row.completion_locator_id,
                   p_locator_segments        => wjsi_row.completion_locator_segments,
                   p_success_flag            => l_success);
      if(not l_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;
  exception when others then
    wip_jsi_utils.record_error(l_msg);
    /* Fixed Bug#3060266 - should abort request if Invalid Locator */
    wip_jsi_utils.abort_request;
  end completion_locator_id;

  procedure due_date is begin
    if(wjsi_row.load_type = wip_constants.create_eam_job) then
      if(wjsi_row.due_date is not null and wjsi_row.pm_schedule_id is null) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    elsif(wjsi_row.due_date is not null and wjsi_row.load_type = wip_constants.resched_eam_job) then
      if(wdj_row.status_type <> wip_constants.draft) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_DUE_DATE');
      wip_jsi_utils.abort_request;
  end due_date;

  procedure date_released is begin
    if(wjsi_row.date_released > sysdate and
       wjsi_row.status_type = wip_constants.released) then
      raise fnd_api.g_exc_unexpected_error;
    end if;
  exception when others then
      wip_jsi_utils.record_error('WIP_ML_INVALID_RELEASE_DATE');
      wip_jsi_utils.abort_request;
  end date_released;

  procedure requested_start_date is begin
    if(wjsi_row.load_type = wip_constants.create_eam_job) then
      if(wjsi_row.requested_start_date is not null and wjsi_row.pm_schedule_id is null) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    elsif(wjsi_row.load_type = wip_constants.resched_eam_job) then
      if(wjsi_row.requested_start_date is not null and wdj_row.status_type <> wip_constants.draft) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_REQUESTED_START_DATE');
      wip_jsi_utils.abort_request;
  end requested_start_date;

  procedure end_item_unit_number is
    is_unit_effective_item boolean;
    l_bom_item_id NUMBER;
  begin

  if(wjsi_row.load_type = wip_constants.create_ns_job) then
      l_bom_item_id := wjsi_row.bom_reference_id;
  else
      l_bom_item_id := wjsi_row.primary_item_id;
  end if;
  is_unit_effective_item := l_bom_item_id is not null and
                              PJM_UNIT_EFF.ENABLED = 'Y' and
                              PJM_Unit_Eff.unit_effective_item(l_bom_item_id,
                                                               wjsi_row.organization_id) = 'Y';

  -- If the assembly item is unit effective, validate the actual
  -- unit number value. The unit number must exist in the same _master_
  -- organization as the item. (We already validate that the item
  -- is in the organization identified by the ORGANIZATION_ID column.)
  if(is_unit_effective_item and wjsi_row.end_item_unit_number is not null) then
      begin
        select 1
        into g_dummy
        from pjm_unit_numbers_lov_v pun,
             mtl_parameters mp
        where pun.unit_number = wjsi_row.end_item_unit_number
         and mp.organization_id = wjsi_row.organization_id
         and mp.master_organization_id = pun.master_organization_id;
      exception
         when too_many_rows then
           null; -- the query returning multiple rows is ok
         when others then
           fnd_message.set_name('PJM', 'UEFF-UNIT NUMBER INVALID') ;
         wip_jsi_utils.record_current_error ;
      end;
  end if;

  -- You cannot create a repetitive schedule for a unit effective assembly.
  if(wjsi_row.load_type = wip_constants.create_sched and
       is_unit_effective_item) then
      wip_jsi_utils.record_error('WIP_ML_NO_UNIT_EFF_SCHED');
      raise fnd_api.g_exc_unexpected_error;
  end if;

  -- If this is a discrete job load...
  if (wjsi_row.load_type in (WIP_CONSTANTS.CREATE_JOB, WIP_CONSTANTS.CREATE_NS_JOB))
  then
    -- It is an error to provide unit number for non-unit effective assemblies.
    if(not is_unit_effective_item and wjsi_row.end_item_unit_number is not null) then
      wip_jsi_utils.record_error('WIP_ML_UNIT_NUM_MEANINGLESS');
    end if;

    -- Unit number is required for unit effective assemblies.
    if(is_unit_effective_item and wjsi_row.end_item_unit_number is null) then
      fnd_message.set_name('PJM', 'UEFF-UNIT NUMBER REQUIRED');
      wip_jsi_utils.record_current_error;
      raise fnd_api.g_exc_unexpected_error;
    end if;
  end if;

  --if request is for reschedule, keep as is for all cases except when job_status is unreleased
  if (wjsi_row.load_type in (WIP_CONSTANTS.RESCHED_JOB,
                      WIP_CONSTANTS.RESCHED_LOT_JOB))
  then
    -- added for bug#2766839, added check when the assembly is not is_unit_effective_item
    if(not is_unit_effective_item) then
      -- It is an error to provide unit number for non-unit effective assemblies.
      if ( wjsi_row.end_item_unit_number is not null) then
        wip_jsi_utils.record_error('WIP_ML_UNIT_NUM_MEANINGLESS');
      end if;
      wjsi_row.end_item_unit_number := null;

    -- if status is unreleased, the end_item_unit_number can be modified
    elsif (wdj_row.status_type = WIP_CONSTANTS.UNRELEASED) then
        if (wjsi_row.end_item_unit_number is null) then
          begin
            select end_item_unit_number into wjsi_row.end_item_unit_number
                                  from wip_discrete_jobs
                                  where wip_entity_id =
                                    (select wip_entity_id
                                     from wip_job_schedule_interface
                                     where rowid = WIP_JSI_UTILS.CURRENT_ROWID
                                    );
          exception
            when others then
              FND_Message.set_name('PJM', 'UEFF-UNIT NUMBER INVALID') ;
              WIP_JSI_Utils.record_current_error ;
              raise fnd_api.g_exc_unexpected_error;
          end ;
        else
          begin
            -- bug#2719927, bom revision code/reexplosion is based on bom_reference_id
            select primary_item_id into wjsi_row.bom_reference_id
                                  from wip_discrete_jobs
                                  where wip_entity_id = wjsi_row.wip_entity_id;
          exception
            when others then
              FND_Message.set_name('WIP', 'WIP_ML_PRIMARY_ITEM_ID') ;
              WIP_JSI_Utils.record_current_error ;
              raise fnd_api.g_exc_unexpected_error;
          end ;
        end if;

    -- if status is not unreleased, end_item_unit_number is ignored.
    else
        if (wjsi_row.end_item_unit_number is not null) then
          wip_jsi_utils.record_ignored_column_warning('END_ITEM_UNIT_NUMBER');
        end if;

        begin
          select end_item_unit_number into wjsi_row.end_item_unit_number
                                  from wip_discrete_jobs
                                  where wip_entity_id =
                                    (select wip_entity_id
                                     from wip_job_schedule_interface
                                     where rowid = WIP_JSI_UTILS.CURRENT_ROWID
                                    );
        exception
          when others then
            FND_Message.set_name('PJM', 'UEFF-UNIT NUMBER INVALID') ;
            WIP_JSI_Utils.record_current_error ;
            raise fnd_api.g_exc_unexpected_error;
        end ;
    end if;
  end if ;

  exception
    when others then
      wip_jsi_utils.abort_request;

  end end_item_unit_number;

  procedure overcompletion is
    l_tol_type NUMBER := wjsi_row.overcompletion_tolerance_type;
    l_tol_value NUMBER := wjsi_row.overcompletion_tolerance_value;
    l_msg VARCHAR2(30);
  begin
    if(wjsi_row.load_type in (wip_constants.create_job, wip_constants.resched_job) or
       (wjsi_row.load_type = wip_constants.create_ns_job and wjsi_row.primary_item_id is not null)) then
      if(l_tol_value is not null and l_tol_type is not null) then
        if(l_tol_type not in (wip_constants.percent, wip_constants.amount)) then
          l_msg:= 'WIP_ML_COMP_TOLERANCE_TYPE';
          raise fnd_api.g_exc_unexpected_error;
        end if;
        if(l_tol_value < 0) then
          l_msg := 'WIP_ML_COMP_TOLERANCE_NEGATIVE';
          raise fnd_api.g_exc_unexpected_error;
        end if;
      elsif(l_tol_value is not null or l_tol_type is not null) then
        l_msg := 'WIP_ML_COMP_TOLERANCE_NULL';--only one overcompletion column was provided
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error(l_msg);
  end overcompletion;

  procedure class_code is begin
    if(wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_ns_job, wip_constants.create_eam_job) and
       wjsi_row.class_code is null) then
      raise fnd_api.g_exc_unexpected_error;
    end if;
    if(wjsi_row.load_type = wip_constants.create_job) then
      if(wjsi_row.project_id is null) then
        select 1
          into g_dummy
          from dual
         where exists(select 1
                        from cst_cg_wip_acct_classes_v
                       where class_code = wjsi_row.class_code
                         and organization_id = wjsi_row.organization_id
                         and class_type = wip_constants.discrete);
      else
        select 1
          into g_dummy
          from dual
         where exists(select 1
                        from cst_cg_wip_acct_classes_v ccwac, mtl_parameters mp
                       where ccwac.class_code = wjsi_row.class_code
                         and ccwac.organization_id = wjsi_row.organization_id
                         and ccwac.class_type = wip_constants.discrete
                         and mp.organization_id = wjsi_row.organization_id
                         and (   mp.primary_cost_method = wip_constants.cost_std
                              or ccwac.cost_group_id = (select costing_group_id
                                                          from mrp_project_parameters mpp
                                                         where organization_id = wjsi_row.organization_id
                                                           and mpp.project_id = wjsi_row.project_id)
                             )
                     );
      end if;
    elsif(wjsi_row.load_type = wip_constants.create_ns_job) then
      select 1
        into g_dummy
        from dual
       where exists(select 1
                      from wip_non_standard_classes_val_v
                     where class_code = wjsi_row.class_code
                       and organization_id = wjsi_row.organization_id);

    elsif(wjsi_row.load_type = wip_constants.create_eam_job) then
      if(wjsi_row.project_id is null) then
         select 1
           into g_dummy
           from dual
          where exists(select 1
                         from cst_cg_wip_acct_classes_v
                        where class_code = wjsi_row.class_code
                          and organization_id = wjsi_row.organization_id
                          and class_type = wip_constants.eam);
       else
         select 1
           into g_dummy
           from dual
          where exists(select 1
                         from cst_cg_wip_acct_classes_v ccwac, mtl_parameters mp
                        where ccwac.class_code = wjsi_row.class_code
                          and ccwac.organization_id = wjsi_row.organization_id
                          and ccwac.class_type = wip_constants.eam
                          and mp.organization_id = wjsi_row.organization_id
                          and (   mp.primary_cost_method = wip_constants.cost_std
                               or ccwac.cost_group_id = (select costing_group_id
                                                           from mrp_project_parameters mpp
                                                          where organization_id = wjsi_row.organization_id
                                                            and mpp.project_id = wjsi_row.project_id)
                              )
                      );
      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_CLASS_CODE');
  end class_code;

  procedure estimate_lead_time is
    l_entity_type NUMBER;
    l_sched_dir NUMBER;
    l_rtg_count NUMBER := 0; --if > 0 a routing exists
    l_qty NUMBER;
    l_msg VARCHAR2(30);
  begin
    if(wjsi_row.load_type = wip_constants.create_sched) then
      l_entity_type := wip_constants.repetitive;
      if(wjsi_row.first_unit_start_date is null) then
        if(wjsi_row.last_unit_start_date is not null) then
          l_sched_dir := wip_constants.lusd;
        elsif(wjsi_row.first_unit_completion_date is not null) then
          l_sched_dir := wip_constants.fucd;
        else
          l_sched_dir := wip_constants.lucd;
        end if;

        wip_calendar.estimate_leadtime(x_org_id      => wjsi_row.organization_id,
                                       x_fixed_lead  => primary_item_row.fixed_lead_time,
                                       x_var_lead    => primary_item_row.variable_lead_time,
                                       x_quantity    => wjsi_row.processing_work_days * wjsi_row.daily_production_rate,
                                       x_proc_days   => wjsi_row.processing_work_days,
                                       x_entity_type => wip_constants.repetitive,
                                       x_fusd        => wjsi_row.first_unit_start_date,
                                       x_fucd        => wjsi_row.first_unit_completion_date,
                                       x_lusd        => wjsi_row.last_unit_start_date,
                                       x_lucd        => wjsi_row.last_unit_completion_date,
                                       x_sched_dir   => l_sched_dir,
                                       x_est_date    => wjsi_row.first_unit_start_date);
        if(wjsi_row.first_unit_start_date is null) then
          l_msg := 'WIP_ML_EST_LEADTIME';
          raise fnd_api.g_exc_unexpected_error;
        end if;
      end if;
    else
      if(wjsi_row.load_type = wip_constants.create_ns_job and wjsi_row.routing_reference_id is not null) then
        select count(*)
          into l_rtg_count
          from bom_operational_routings
         where assembly_item_id = wjsi_row.routing_reference_id
           and organization_id = wjsi_row.organization_id
           and nvl(alternate_routing_designator, '@@') = nvl(wjsi_row.alternate_routing_designator, '@@')
           and nvl(cfm_routing_flag, 2) = 2;
        l_qty := wjsi_row.start_quantity;
      elsif(wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_eam_job)) then
        select count(*)
          into l_rtg_count
          from bom_operational_routings
         where assembly_item_id = wjsi_row.primary_item_id
           and organization_id = wjsi_row.organization_id
           and nvl(alternate_routing_designator, '@@') = nvl(wjsi_row.alternate_routing_designator, '@@')
           and nvl(cfm_routing_flag, 2) = 2;
        l_qty := wjsi_row.start_quantity;
      elsif(wjsi_row.load_type in (wip_constants.resched_job, wip_constants.resched_eam_job)) then
        select count(*)
          into l_rtg_count
          from wip_operations
         where wip_entity_id = wjsi_row.wip_entity_id;
        l_qty := nvl(wjsi_row.start_quantity, wdj_row.start_quantity);
      end if;
      --if no routing exists, update the scheduling method appropriately
      if(wjsi_row.scheduling_method = wip_constants.routing and l_rtg_count = 0) then
        if(wjsi_row.first_unit_start_date is not null and
           wjsi_row.last_unit_completion_date is not null) then
          wjsi_row.scheduling_method := wip_constants.ml_manual;
        else
          wjsi_row.scheduling_method := wip_constants.leadtime;
        end if;
      end if;

      if((wjsi_row.first_unit_start_date is null and
          wjsi_row.last_unit_completion_date is not null) or
         (wjsi_row.last_unit_completion_date is not null and
          wjsi_row.scheduling_method = wip_constants.leadtime)) then
        /* Estimate Start Date */
        wip_calendar.estimate_leadtime(x_org_id      => wjsi_row.organization_id,
                                       x_fixed_lead  => primary_item_row.fixed_lead_time,
                                       x_var_lead    => primary_item_row.variable_lead_time,
                                       x_quantity    => l_qty,
                                       x_proc_days   => 0,
                                       x_entity_type => l_entity_type,
                                       x_fusd        => '',
                                       x_fucd        => '',
                                       x_lusd        => '',
                                       x_lucd        => wjsi_row.last_unit_completion_date,
                                       x_sched_dir   => wip_constants.lucd,
                                       x_est_date    => wjsi_row.first_unit_start_date);
        if(wjsi_row.first_unit_start_date is null) then
          l_msg := 'WIP_ML_EST_LEADTIME';
          raise fnd_api.g_exc_unexpected_error;
        end if;
      elsif(wjsi_row.last_unit_completion_date is null and
            wjsi_row.first_unit_start_date is not null and
            wjsi_row.scheduling_method = wip_constants.leadtime) then
        /* Estimate Completion Date */
        wip_calendar.estimate_leadtime(x_org_id      => wjsi_row.organization_id,
                                       x_fixed_lead  => primary_item_row.fixed_lead_time,
                                       x_var_lead    => primary_item_row.variable_lead_time,
                                       x_quantity    => l_qty,
                                       x_proc_days   => 0,
                                       x_entity_type => l_entity_type,
                                       x_fusd        => wjsi_row.first_unit_start_date,
                                       x_fucd        => '',
                                       x_lusd        => '',
                                       x_lucd        => '',
                                       x_sched_dir   => wip_constants.fusd,
                                       x_est_date    => wjsi_row.last_unit_completion_date);
        if(wjsi_row.last_unit_completion_date is null) then
          l_msg := 'WIP_NO_CALENDAR';
          raise fnd_api.g_exc_unexpected_error;
        end if;
      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error(l_msg);
  end estimate_lead_time;

  procedure bom_revision is
    l_start_date DATE;
    l_bom_item_id NUMBER;
  begin
    if(wjsi_row.load_type = wip_constants.create_ns_job) then
      l_bom_item_id := wjsi_row.bom_reference_id;
    else
      l_bom_item_id := wjsi_row.primary_item_id;
    end if;
    l_start_date := greatest(wjsi_row.first_unit_start_date, sysdate);
    if(wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_sched,
                              wip_constants.create_ns_job, wip_constants.create_eam_job)) then
      wip_revisions.bom_revision(p_organization_id => wjsi_row.organization_id,
                                 p_item_id => l_bom_item_id,
                                 p_revision => wjsi_row.bom_revision,
                                 p_revision_date => wjsi_row.bom_revision_date,
                                 p_start_date => l_start_date);
    end if;
  exception
    when others then
      WIP_JSI_Utils.record_error('WIP_ML_BOM_REVISION') ;
 /* Fixed for bug#3063147
    When No valid bom revision exists for an item then mass load should be
    aborted.
 */
   wip_jsi_utils.abort_request;

  end bom_revision;

  procedure routing_revision is
    l_start_date DATE;
    l_rtg_item_id NUMBER;
    l_count NUMBER;
  begin
    if(wjsi_row.load_type = wip_constants.create_ns_job) then
      l_rtg_item_id := wjsi_row.routing_reference_id;
    else
      l_rtg_item_id := wjsi_row.primary_item_id;
    end if;
    l_start_date := greatest(wjsi_row.first_unit_start_date, sysdate);
    if(wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_sched,
                              wip_constants.create_ns_job, wip_constants.create_eam_job)) then
      select count(*)
        into l_count
        from bom_operational_routings
       where assembly_item_id = decode(wjsi_row.load_type, wip_constants.create_ns_job, wjsi_row.routing_reference_id,
                                                                                 wjsi_row.primary_item_id)
         and organization_id = wjsi_row.organization_id
         and nvl(alternate_routing_designator, '@@') = nvl(wjsi_row.alternate_routing_designator, '@@');
      if(l_count > 0) then
        wip_revisions.routing_revision(p_organization_id => wjsi_row.organization_id,
                                       p_item_id => l_rtg_item_id,
                                       p_revision => wjsi_row.routing_revision,
                                       p_revision_date => wjsi_row.routing_revision_date,
                                       p_start_date => l_start_date);
      end if;
    end if;
  exception
    when others then
      WIP_JSI_Utils.record_error('WIP_ML_ROUTING_REVISION');
  end routing_revision;

  procedure asset_group_id is begin
    if(wjsi_row.load_type = wip_constants.create_eam_job) then
      if(wjsi_row.asset_group_id is not null) then
        select 1
          into g_dummy
          from mtl_system_items
         where inventory_item_id = wjsi_row.asset_group_id
           and organization_id = wjsi_row.organization_id
           and eam_item_type = 1; -- asset group
      elsif(wjsi_row.rebuild_item_id is null) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_EAM_ASSET_GROUP');
      wip_jsi_utils.abort_request;
  end asset_group_id;

  procedure asset_number is
    l_msg VARCHAR2(30);
  begin
    l_msg := 'WIP_ML_EAM_ASSET_NUM';
    if(wjsi_row.load_type = wip_constants.create_eam_job) then

      -- Per EAM Enh. for H, this field is no longer mandatory

      if(wjsi_row.asset_group_id is null and
         wjsi_row.asset_number is not null) then
        raise fnd_api.g_exc_unexpected_error;
      end if;

      if(wjsi_row.asset_group_id is not null) then
        select 1
          into g_dummy
          from mtl_serial_numbers
         where inventory_item_id = wjsi_row.asset_group_id
           and current_organization_id = wjsi_row.organization_id
           and serial_number = wjsi_row.asset_number
           and maintainable_flag = 'Y';
      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error(l_msg);
  end asset_number;

  procedure rebuild_item_id is begin
    if(wjsi_row.load_type = wip_constants.create_eam_job and
       wjsi_row.rebuild_item_id is not null) then
      select 1
        into g_dummy
        from mtl_system_items
       where inventory_item_id = wjsi_row.rebuild_item_id
         and organization_id = wjsi_row.organization_id
         and eam_item_type = 3;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_EAM_REBUILD_ITEM');
      wip_jsi_utils.abort_request;
  end rebuild_item_id;

  procedure rebuild_serial_number is begin
    if(wjsi_row.load_type = wip_constants.create_eam_job) then

      if(wjsi_row.rebuild_item_id is null and
         wjsi_row.rebuild_serial_number is not null) then
        raise fnd_api.g_exc_unexpected_error;
      end if;

      if(wjsi_row.rebuild_item_id is not null) then
        if(wjsi_row.rebuild_serial_number is null) then
          if(wjsi_row.maintenance_object_source = 1 and
             wjsi_row.maintenance_object_type = 1) then
            if(wjsi_row.status_type not in (wip_constants.draft, wip_constants.unreleased)) then
              raise fnd_api.g_exc_unexpected_error;
            end if;
          elsif(wjsi_row.maintenance_object_type not in (2, 3)) then
            raise fnd_api.g_exc_unexpected_error;
          end if;
        else
          if(wjsi_row.maintenance_object_type = 1) then
            select 1
              into g_dummy
              from mtl_serial_numbers
             where serial_number = wjsi_row.rebuild_serial_number
               and inventory_item_id = wjsi_row.rebuild_item_id
               and current_organization_id = wjsi_row.organization_id
               and current_status in (1,3,4);--defined not used, resides in stores, issued out nocopy of stores (consistent w/EAM UI)
          elsif(wjsi_row.maintenance_object_type = 3) then
            select 1
              into g_dummy
              from mtl_serial_numbers
             where serial_number = wjsi_row.rebuild_serial_number
               and inventory_item_id = wjsi_row.rebuild_item_id
               and current_organization_id = wjsi_row.organization_id;
          end if;
        end if;
      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_EAM_REBUILD_SERIAL');
  end rebuild_serial_number;

  procedure parent_wip_entity_id is begin
    -- Per EAM Enh. for H, this field is no longer mandatory
    if(wjsi_row.load_type = wip_constants.create_eam_job
        and wjsi_row.parent_wip_entity_id is not null) then
      select 1
        into g_dummy
        from wip_entities
        where wip_entity_id = wjsi_row.parent_wip_entity_id
          and entity_type = wip_constants.eam;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_EAM_PARENT_ENTITY');
  end parent_wip_entity_id;

  procedure manual_rebuild_flag is begin
    if(wjsi_row.load_type = wip_constants.create_eam_job) then
      if(wjsi_row.manual_rebuild_flag is not null and
         (wjsi_row.rebuild_item_id is null or
         wjsi_row.manual_rebuild_flag not in ('Y', 'N'))) then
        raise fnd_api.g_exc_unexpected_error;
      end if;

      if(wjsi_row.manual_rebuild_flag is null and
         wjsi_row.rebuild_item_id is not null) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_EAM_REBUILD_FLAG');
  end manual_rebuild_flag;

  procedure owning_department is
    l_job_date DATE;
    l_disable_date DATE;
  begin
    if(wjsi_row.load_type in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
       wjsi_row.owning_department is not null) then
      l_job_date := nvl(wjsi_row.last_unit_completion_date, nvl(wjsi_row.first_unit_start_date, wdj_row.scheduled_completion_date));
      select disable_date
        into l_disable_date
        from bom_departments
       where department_id = wjsi_row.owning_department
         and organization_id = wjsi_row.organization_id;

      if(l_disable_date is not null and
         l_disable_date < l_job_date) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_EAM_OWNING_DEPT');
  end owning_department;

  procedure notification_required is begin
    if(wjsi_row.load_type in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
       wjsi_row.notification_required is not null and
       wjsi_row.notification_required not in ('Y', 'N')) then
      raise fnd_api.g_exc_unexpected_error;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_EAM_NOTIF_REQ');
  end notification_required;

  procedure shutdown_type is begin
    if(wjsi_row.load_type in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
       wjsi_row.shutdown_type is not null) then
      select 1
        into g_dummy
        from mfg_lookups
       where lookup_type = 'BOM_EAM_SHUTDOWN_TYPE'
         and lookup_code = wjsi_row.shutdown_type
         and enabled_flag = 'Y';
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_EAM_SHUTDOWN_TYPE');
  end shutdown_type;

  procedure tagout_required is begin
    if(wjsi_row.load_type in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
       wjsi_row.tagout_required is not null and
       wjsi_row.tagout_required not in ('Y', 'N')) then
      raise fnd_api.g_exc_unexpected_error;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_EAM_TAGOUT_REQUIRED');
  end tagout_required;

  procedure plan_maintenance is begin
    if(wjsi_row.load_type = wip_constants.create_eam_job and
       wjsi_row.plan_maintenance is not null and
       wjsi_row.plan_maintenance not in ('Y', 'N')) then
      raise fnd_api.g_exc_unexpected_error;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_EAM_PLAN_MAINTENANCE');
  end plan_maintenance;

  procedure work_order_type is begin
    if(wjsi_row.load_type in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
       wjsi_row.work_order_type is not null) then
      select 1
        into g_dummy
        from mfg_lookups
       where lookup_type = 'WIP_EAM_WORK_ORDER_TYPE'
         and lookup_code = wjsi_row.work_order_type
         and enabled_flag = 'Y';
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_EAM_WORK_ORDER_TYPE');
  end work_order_type;

  procedure activity_type is begin
    if(wjsi_row.load_type in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
       wjsi_row.activity_type is not null) then
      select 1
        into g_dummy
        from mfg_lookups
       where lookup_type = 'MTL_EAM_ACTIVITY_TYPE'
         and lookup_code = wjsi_row.activity_type
         and enabled_flag = 'Y';
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_EAM_ACTIVITY_TYPE');
  end activity_type;

  procedure activity_cause is begin
    if(wjsi_row.load_type in (wip_constants.create_eam_job, wip_constants.resched_eam_job,
       wip_constants.resched_job) and wjsi_row.activity_cause is not null) then
      select 1
        into g_dummy
        from mfg_lookups
       where lookup_type = 'MTL_EAM_ACTIVITY_CAUSE'
         and lookup_code = wjsi_row.activity_cause
         and enabled_flag = 'Y';
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_EAM_ACTIVITY_CAUSE');
  end activity_cause;

  procedure maintenance_object_type is
    l_serial_number_control_code NUMBER;
  begin
    if(wjsi_row.load_type in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
       wjsi_row.maintenance_object_type is not null) then
      if(wjsi_row.rebuild_item_id is null and wjsi_row.maintenance_object_type <> 1) then
        raise fnd_api.g_exc_unexpected_error;
      elsif(wjsi_row.rebuild_item_id is not null) then

        select serial_number_control_code
          into l_serial_number_control_code
          from mtl_system_items
         where organization_id = wjsi_row.organization_id
           and inventory_item_id = wjsi_row.rebuild_item_id;

        if(l_serial_number_control_code in (2, 5, 6) and
           wjsi_row.maintenance_object_type not in (1, 3)) then
          raise fnd_api.g_exc_unexpected_error;
        elsif(l_serial_number_control_code not in (2, 5, 6) and
           wjsi_row.maintenance_object_type not in(2, 3)) then
          raise fnd_api.g_exc_unexpected_error;
        end if;

      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_EAM_MAINT_OBJECT_TYPE');
  end maintenance_object_type;

   procedure maintenance_object_source is begin
    if(wjsi_row.load_type in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
       wjsi_row.maintenance_object_source is not null) then
      if(wjsi_row.rebuild_item_id is null and
         wjsi_row.maintenance_object_source <> 1) then
        raise fnd_api.g_exc_unexpected_error;
      else
        select 1
          into g_dummy
        from mfg_lookups
         where lookup_type = 'WIP_MAINTENANCE_OBJECT_SOURCE'
           and lookup_code = wjsi_row.maintenance_object_source
           and enabled_flag = 'Y';
      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_EAM_MAINT_OBJECT_SOURCE');
  end maintenance_object_source;

  procedure maintenance_object_id is begin
    if(wjsi_row.load_type = wip_constants.create_eam_job and
       wjsi_row.maintenance_object_id is not null) then

      if(wjsi_row.maintenance_object_type = 1) then
        if(wjsi_row.rebuild_item_id is null) then
          select 1
            into g_dummy
            from mtl_serial_numbers
           where current_organization_id = wjsi_row.organization_id
             and inventory_item_id = wjsi_row.asset_group_id
             and serial_number = wjsi_row.asset_number
             and gen_object_id = wjsi_row.maintenance_object_id;
        else
          select 1
            into g_dummy
            from mtl_serial_numbers
           where current_organization_id = wjsi_row.organization_id
             and inventory_item_id = wjsi_row.rebuild_item_id
             and serial_number = wjsi_row.rebuild_serial_number
             and gen_object_id = wjsi_row.maintenance_object_id;
        end if;
      elsif(wjsi_row.maintenance_object_type = 2 and
            wjsi_row.maintenance_object_id <> wjsi_row.rebuild_item_id) then
        raise fnd_api.g_exc_unexpected_error;
      end if;

    end if;

    if(wjsi_row.load_type = wip_constants.create_eam_job and
       wjsi_row.maintenance_object_id is null and
       wjsi_row.maintenance_object_type = 3) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_EAM_MAINT_OBJECT_ID');
  end maintenance_object_id;

  procedure pm_schedule_id is begin
    if(wjsi_row.load_type in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
       wjsi_row.pm_schedule_id is not null and
       wjsi_row.primary_item_id is null) then
      raise fnd_api.g_exc_unexpected_error;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_EAM_PM_SCHEDULE_ID');
  end pm_schedule_id;

  procedure activity_source is begin
    if(wjsi_row.load_type in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
       wjsi_row.activity_source is not null) then
      select 1
        into g_dummy
        from mfg_lookups
       where lookup_type = 'MTL_EAM_ACTIVITY_SOURCE'
         and lookup_code = wjsi_row.activity_source
         and enabled_flag = 'Y';
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_EAM_ACTIVITY_SOURCE');
  end activity_source;


PROCEDURE validate_date_released is
x_status_type     number;
x_date_released   date;
x_organization_id number;
x_period_exists  varchar2(1);
BEGIN
  If (wjsi_row.status_type = WIP_CONSTANTS.UNRELEASED) then
    if (wjsi_row.date_released is not null) then
      WIP_JSI_Utils.record_ignored_column_warning ('DATE_RELEASED') ;
    end if ;
  Elsif (wjsi_row.status_type = WIP_CONSTANTS.RELEASED) then
    if (nvl(wjsi_row.date_released,sysdate) > sysdate) then
        WIP_JSI_Utils.record_error('WIP_INVALID_RELEASE_DATE',TRUE) ;

        update wip_job_schedule_interface
        set    date_released = sysdate
        where  rowid = WIP_JSI_Utils.current_rowid ;
    end if;

    --else
    /* fix for bug 2424987 */
        Begin
          select 'X'
          into   x_period_exists
          from org_acct_periods
          where organization_id = wjsi_row.organization_id
          and trunc(INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_INV_ORG(nvl(wjsi_row.date_released,sysdate),wjsi_row.organization_id)) between PERIOD_START_DATE and SCHEDULE_CLOSE_DATE
          and period_close_date is NULL;
        Exception
          When others then
            WIP_JSI_Utils.record_error('WIP_NO_ACCT_PERIOD',FALSE) ;
            WIP_JSI_Utils.abort_request;
        End;
    --end if;

  End if;

END validate_date_released;

end wip_jsi_validator;

/
