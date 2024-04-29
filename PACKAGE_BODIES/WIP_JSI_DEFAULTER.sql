--------------------------------------------------------
--  DDL for Package Body WIP_JSI_DEFAULTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_JSI_DEFAULTER" as
/* $Header: wipjsidb.pls 120.2.12000000.2 2007/05/03 22:40:34 vjambhek ship $ */

/* private variables */
  wjsi_row wip_job_schedule_interface%ROWTYPE;

/* forward declarations */

/* This package defaults all the column values in the wip mass load process. */
--  procedure row_by_row ;
  procedure created_by_name;
  procedure last_updated_by_name;
  procedure organization; --should be first after standard who columns
  procedure job_name;
  procedure wip_entity_id;
  procedure repetitive_schedule_id;
  procedure kanban_card_id; --may default job properties based on kanban id
  procedure schedule_group;
  procedure line_code;
  procedure project_number;
  procedure task_number;--10
  procedure firm_planned_flag;
  procedure description;
  procedure status_type;
  procedure wip_supply_type;
  procedure class_code;
  procedure primary_item;
  procedure start_quantity;
  procedure net_quantity;
  procedure overcompletion;
  procedure asset_number;--20
  procedure asset_group;
  procedure parent_job_name;
  procedure parent_wip_entity_id;
  procedure rebuild_item;
  procedure rebuild_serial_number;
  procedure manual_rebuild_flag;
  procedure first_unit_start_date;
	/* Uncommented to fix bug #5912951-FP of 5891243 */
--  procedure last_unit_start_date;
--  procedure first_unit_completion_date;
--  procedure last_unit_completion_date;
  procedure due_date;
  procedure date_released;
  procedure requested_start_date;
  procedure processing_work_days;--30
  procedure daily_production_rate;
  procedure header_id;
  procedure demand_class;
  procedure build_sequence;
  procedure routing_reference;
  procedure bom_reference;
  procedure alternate_routing_designator;
  procedure alternate_bom_designator;
  procedure bom_revision;
  procedure routing_revision;--40
  procedure bom_revision_date;
  procedure routing_revision_date;
  procedure lot_number;
  procedure source_code;
  procedure source_line_id;
  procedure scheduling_method;
  procedure completion_subinventory;
  procedure completion_locator;
  procedure priority;
  procedure allow_explosion;
  procedure end_item_unit_number; --must be after primary_item_id  procedure
  procedure owning_department;
  procedure notification_required;--50
  procedure shutdown_type;
  procedure work_order_type;
  procedure tagout_required;
  procedure plan_maintenance;
  procedure activity_type;
  procedure activity_cause;--56
  procedure material_issue_by_mo;
  procedure serialization_start_op;
  procedure maintenance_object_type;
  procedure maintenance_object_id;
  procedure maintenance_object_source;
  procedure activity_source;
  procedure pm_schedule_id;

/* public procedures */
  procedure default_values(p_wjsi_row in out nocopy wip_job_schedule_interface%ROWTYPE) IS
    BEGIN
      wjsi_row := p_wjsi_row;
      created_by_name;
      last_updated_by_name;
      organization;
      job_name;
      wip_entity_id;
      repetitive_schedule_id;
      kanban_card_id;
      schedule_group;
      line_code;
      project_number;
      task_number;--10
      firm_planned_flag;
      description;
      status_type;
      wip_supply_type;
--added for EAM
      asset_group;--20
      asset_number;
      rebuild_item;
      maintenance_object_type;
      maintenance_object_source;
      rebuild_serial_number;
      maintenance_object_id;
      pm_schedule_id;
      parent_job_name;
      parent_wip_entity_id;
--
      class_code;
      primary_item;
      start_quantity;
      net_quantity;
      overcompletion;
      first_unit_start_date;/* Uncommented to fix bug #5912951-FP of 5891243 */
--      last_unit_start_date;
--      first_unit_completion_date;
--      last_unit_completion_date;
      due_date;
      date_released;
      requested_start_date;
      processing_work_days;--30
      daily_production_rate;
      header_id;
      demand_class;
      build_sequence;
      routing_reference;
      bom_reference;
      alternate_routing_designator;
      alternate_bom_designator;
      bom_revision;
      routing_revision;--40
      bom_revision_date;
      routing_revision_date;
      lot_number;
      source_code;
      source_line_id;
      allow_explosion;
      scheduling_method;
      completion_subinventory;
      completion_locator;
      priority;
      end_item_unit_number; --must be after primary_item_id
--added for EAM
      owning_department;
      activity_cause;--56
      activity_source;
      plan_maintenance;
      notification_required;--50
      work_order_type;
      manual_rebuild_flag;
      tagout_required;
      shutdown_type;
      activity_type;
--
      material_issue_by_mo;
      serialization_start_op;
      p_wjsi_row := wjsi_row;
  end default_values;

  procedure default_serialization_op(p_rtgVal IN NUMBER) is
    l_minOp NUMBER;
    l_loadType NUMBER;
    l_default NUMBER;
    l_startOp NUMBER;
    l_wipID NUMBER;
    l_primaryItem NUMBER;
    l_orgID NUMBER;
  begin
    select wp.default_serialization_start_op,
           wjsi.load_type,
           wjsi.serialization_start_op,
           wjsi.wip_entity_id,
           wjsi.primary_item_id,
           wjsi.organization_id
      into l_default,
           l_loadType,
           l_startOp,
           l_wipID,
           l_primaryItem,
           l_orgID
      from wip_parameters wp, wip_job_schedule_interface wjsi
     where wjsi.rowid = wip_jsi_utils.current_rowid
       and wjsi.organization_id = wp.organization_id;

    if(l_startOp is not null OR
       l_primaryItem is null) then
      return;
    end if;
    --warnings are populated in default values as to provide messages to the
    --user asap
    if(l_loadType in (wip_constants.create_job, wip_constants.create_ns_job)) then
      if(p_rtgVal is not null) then
       update wip_discrete_jobs
          set serialization_start_op = p_rtgVal
        where wip_entity_id = l_wipID
          and exists (select 1
                         from mtl_system_items
                        where inventory_item_id = l_primaryItem
                          and organization_id = l_orgID
                          and serial_number_control_code = wip_constants.full_sn);

      elsif(l_default = wip_constants.yes) then
        update wip_discrete_jobs
          set serialization_start_op = (select nvl(min(operation_seq_num), 1)
                                        from wip_operations
                                        where wip_entity_id = l_wipID)
         where wip_entity_id = l_wipID
           and exists (select 1
                         from mtl_system_items
                        where inventory_item_id = l_primaryItem
                          and organization_id = l_orgID
                          and serial_number_control_code = wip_constants.full_sn);
      end if;
    end if;
  end default_serialization_op;


/* private procedures */
  procedure organization is
    l_dummy NUMBER;
    l_def_error boolean := true;
    l_operating_unit NUMBER;
  begin
    --org_id defaulting
    if(wjsi_row.organization_code is not null) then
      if(wjsi_row.organization_id is null) then
        select organization_id
          into wjsi_row.organization_id
          from mtl_parameters
          where organization_code = wjsi_row.organization_code;
      else
        WIP_JSI_Utils.record_ignored_column_warning('ORGANIZATION_CODE');
      end if;
    end if;
    l_def_error := false; --after this point exceptions are from validations

    select to_number(org_information3) into l_operating_unit
      from hr_organization_information
     where organization_id = wjsi_row.organization_id
       and org_information_context = 'Accounting Information' ;

    --set the org context so future pjm validations succeed (their views are striped).
    fnd_client_info.set_org_context(to_char(l_operating_unit));
  exception
    when others then
      if(l_def_error) then
        wip_jsi_utils.record_invalid_column_error('ORGANIZATION_CODE');
      else
        wip_jsi_utils.record_error('WIP_ML_ORGANIZATION_ID');
      end if;
      wip_jsi_utils.abort_request;
  end organization;

  procedure job_name is begin
    --wip_entity_name defaulting

    --if rescheduling job default name, warn if both name and id provided
    if(wjsi_row.load_type in (wip_constants.resched_job, wip_constants.resched_eam_job)) then
      if(wjsi_row.wip_entity_id is null) then
        select wip_entity_id
          into wjsi_row.wip_entity_id
          from wip_entities
         where wip_entity_name = wjsi_row.job_name
           and organization_id = wjsi_row.organization_id;
      elsif(wjsi_row.job_name is not null) then
        WIP_JSI_Utils.record_ignored_column_warning('JOB_NAME');
      end if;
    --if rep sched, name is ignored
    elsif(wjsi_row.load_type = wip_constants.create_sched) then
      if(wjsi_row.job_name is not null) then
        WIP_JSI_Utils.record_ignored_column_warning('JOB_NAME');
      end if;
    --when creating a job, if name isn't provided, create one
    elsif(wjsi_row.job_name is null) then
      /* Fix for Bug#2994658 */
      if (wjsi_row.load_type = wip_constants.create_eam_job) then
         select WORK_ORDER_PREFIX || wip_job_number_s.nextval
         into   wjsi_row.job_name
         from   wip_eam_parameters
         where  organization_id = wjsi_row.organization_id ;
      else
        select fnd_profile.value('WIP_JOB_PREFIX') || wip_job_number_s.nextval
        into wjsi_row.job_name
        from dual;
      end if ;
    end if;
  exception
    when others then
      wip_jsi_utils.record_invalid_column_error('JOB_NAME');
      wip_jsi_utils.abort_request;
  end job_name;

  procedure wip_entity_id is
    l_dummy NUMBER;
  begin
    if(wjsi_row.load_type = wip_constants.create_sched) then
      if(wjsi_row.wip_entity_id is not null) then
        wip_jsi_utils.record_ignored_column_warning('WIP_ENTITY_ID');
      end if;
    --if create job request, then ignore interface wip_entity and default from sequence
    elsif(wjsi_row.load_type in (wip_constants.create_job,
                                 wip_constants.create_ns_job,
                                 wip_constants.create_eam_job)) then
      if(wjsi_row.wip_entity_id is not null) then
        wip_jsi_utils.record_ignored_column_warning('WIP_ENTITY_ID');
      end if;
      select wip_entities_s.nextval
        into wjsi_row.wip_entity_id
        from dual;
    else --do minimal validation of wip_entity_id so future defaulting doesn't error
      select 1
        into l_dummy
        from wip_entities
       where wip_entity_id = wjsi_row.wip_entity_id
         and organization_id = wjsi_row.organization_id;
    end if;
  exception
    when others then
      wip_jsi_utils.record_invalid_column_error('WIP_ENTITY_ID');
      wip_jsi_utils.abort_request;
  end wip_entity_id;

  procedure schedule_group is begin
    --schedule group defaulting
    if(wjsi_row.load_type in (wip_constants.create_sched, wip_constants.create_eam_job, wip_constants.resched_eam_job)) then
      if(wjsi_row.schedule_group_id is not null) then
        wip_jsi_utils.record_ignored_column_warning('SCHEDULE_GROUP_ID');
      end if;
      if(wjsi_row.schedule_group_name is not null) then
        wip_jsi_utils.record_ignored_column_warning('SCHEDULE_GROUP_NAME');
      end if;
      return;
    end if;

    if(wjsi_row.schedule_group_id is null) then
      if(wjsi_row.schedule_group_name is not null) then
        select schedule_group_id
          into wjsi_row.schedule_group_id
          from wip_schedule_groups_val_v
         where schedule_group_name = wjsi_row.schedule_group_name
           and organization_id = wjsi_row.organization_id;
      end if;
    else
      wip_jsi_utils.record_ignored_column_warning('SCHEDULE_GROUP_NAME');
    end if;
      --if still null, default from job
    if(wjsi_row.load_type = wip_constants.resched_job and
       wjsi_row.schedule_group_id is null) then
      begin
        select schedule_group_id
          into wjsi_row.schedule_group_id
          from wip_discrete_jobs
          where wip_entity_id = wjsi_row.wip_entity_id
          and organization_id = wjsi_row.organization_id;
      exception
        when others then null;
      end;
    end if;
    -- if still null and loading from CTO, insert new group
    if(wjsi_row.schedule_group_id is null and
       wjsi_row.source_code = 'WICDOL' and
       wjsi_row.delivery_id is not null) then
        begin
          select schedule_group_id
            into wjsi_row.schedule_group_id
            from wip_schedule_groups wsg,
                 wsh_new_deliveries wds
           where wds.delivery_id = wjsi_row.delivery_id
             and wsg.schedule_group_name = wds.name
             and wsg.organization_id = wjsi_row.organization_id;
        exception
          when no_data_found then
          --having problems using dml returning...
            select wip_schedule_groups_s.nextval
              into wjsi_row.schedule_group_id
              from dual;

            insert into wip_schedule_groups (
            schedule_group_id,
            schedule_group_name,
            organization_id,
            description,
            created_by,
            last_updated_by,
            creation_date,
            last_update_date)
            select wjsi_row.schedule_group_id,
                   wds.name,
                   wjsi_row.organization_id,
                   to_char(sysdate),
                   fnd_global.user_id,
                   fnd_global.user_id,
                   sysdate,
                   sysdate
              from wsh_new_deliveries wds
             where wds.delivery_id = wjsi_row.delivery_id;
        end;
    end if;
  exception
    when others then
      wip_jsi_utils.record_invalid_column_error('SCHEDULE_GROUP_NAME');
      wip_jsi_utils.abort_request;
  end schedule_group;

  --line code defaulting
  procedure line_code is begin
    if(wjsi_row.line_id is null and wjsi_row.line_code is not null) then
       select line_id
         into wjsi_row.line_id
         from wip_lines_val_v
        where line_code = wjsi_row.line_code
          and organization_id = wjsi_row.organization_id;
    elsif(wjsi_row.line_id is not null and wjsi_row.line_code is not null) then
      WIP_JSI_Utils.record_ignored_column_warning('LINE_CODE');
    end if;
  exception
    when others then
      wip_jsi_utils.record_invalid_column_error('LINE_CODE');
      wip_jsi_utils.abort_request;
  end line_code;

  procedure project_number is begin
    if(wjsi_row.load_type = wip_constants.create_sched) then
      if(wjsi_row.project_number is not null) then
        WIP_JSI_Utils.record_ignored_column_warning('PROJECT_NUMBER');
      end if;
      if(wjsi_row.project_id is not null) then
        WIP_JSI_Utils.record_ignored_column_warning('PROJECT_ID');
      end if;
    elsif(wjsi_row.project_number is not null and wjsi_row.project_id is null) then
      -- fix MOAC, set id so project view works
      fnd_profile.put('MFG_ORGANIZATION_ID',wjsi_row.organization_id);
      select pjm_project.val_proj_numtoid(wjsi_row.project_number, wjsi_row.organization_id)
        into wjsi_row.project_id
        from dual;
    elsif(wjsi_row.load_type not in (wip_constants.resched_job, wip_constants.resched_eam_job) and
          wjsi_row.task_number is not null
          and wjsi_row.task_id is not null) then
      raise fnd_api.g_exc_unexpected_error;
    end if;
  exception
    when others then
      wip_jsi_utils.record_invalid_column_error('PROJECT_NUMBER');
      wip_jsi_utils.abort_request;
  end project_number;

  procedure task_number is begin
    if(wjsi_row.load_type = wip_constants.create_sched) then
      if(wjsi_row.task_number is not null) then
        WIP_JSI_Utils.record_ignored_column_warning('TASK_NUMBER');
      end if;
      if(wjsi_row.task_id is not null) then
        WIP_JSI_Utils.record_ignored_column_warning('TASK_ID');
      end if;
    elsif(wjsi_row.task_number is not null and wjsi_row.task_id is null) then
      if(wjsi_row.load_type = wip_constants.resched_job) then
        select pa.task_id
          into wjsi_row.task_id
          from pa_tasks_expend_v pa, wip_discrete_jobs wdj
         where wdj.wip_entity_id = wjsi_row.wip_entity_id
           and pa.project_id = nvl(wjsi_row.project_id, wdj.project_id)
           and pa.task_number = wjsi_row.task_number;
      else
        select task_id
          into wjsi_row.task_id
          from pa_tasks_expend_v
         where project_id = wjsi_row.project_id
           and task_number = wjsi_row.task_number;
      end if;
    elsif(wjsi_row.task_number is not null and wjsi_row.task_id is not null) then
      wip_jsi_utils.record_ignored_column_warning('TASK_NUMBER');
    end if;
  exception
    when others then
      wip_jsi_utils.record_invalid_column_error('TASK_NUMBER');
      wip_jsi_utils.abort_request;
  end task_number;

  procedure firm_planned_flag is begin
    if(wjsi_row.firm_planned_flag is null and
       wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_sched,
                              wip_constants.create_ns_job, wip_constants.create_eam_job)) then
      wjsi_row.firm_planned_flag := wip_constants.no;
    end if;
  end firm_planned_flag;

  procedure demand_class is begin
    if(wjsi_row.load_type in (wip_constants.resched_job, wip_constants.resched_eam_job) and
       wjsi_row.demand_class is not null) then
      wip_jsi_utils.record_ignored_column_warning('DEMAND_CLASS');
    end if;
  end demand_class;

  procedure description is begin
    if(wjsi_row.description is null) then
      if(wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_ns_job)) then
        fnd_message.set_name('WIP','WIP_MLD_DESC');
        fnd_message.set_token('LOAD_DATE', fnd_date.date_to_charDT(sysdate), false);
        wjsi_row.description := fnd_message.get;
      elsif(wjsi_row.load_type = wip_constants.create_sched) then
        fnd_message.set_name('WIP','WIP_MLR_DESC');
        fnd_message.set_token('LOAD_DATE', fnd_date.date_to_charDT(sysdate), false);
        wjsi_row.description := fnd_message.get;
      end if;
    end if;
  end description;

  procedure build_sequence is begin
    if(wjsi_row.load_type = wip_constants.create_sched and
       wjsi_row.build_sequence is not null) then
      wip_jsi_utils.record_ignored_column_warning('BUILD_SEQUENCE');
    end if;
  end build_sequence;

  procedure status_type is begin
    if(wjsi_row.load_type = wip_constants.create_sched and wjsi_row.status_type is not null) then
      wip_jsi_utils.record_ignored_column_warning('STATUS_TYPE');
    elsif(wjsi_row.status_type is null and wjsi_row.load_type in (wip_constants.create_job,
                                  wip_constants.create_ns_job, wip_constants.create_eam_job)) then
      wjsi_row.status_type := wip_constants.unreleased;
    elsif (wjsi_row.load_type in (wip_constants.resched_job, wip_constants.resched_eam_job) and
           wjsi_row.status_type is null) then
        select wdj.status_type
          into wjsi_row.status_type
        from wip_discrete_jobs wdj
        where wdj.wip_entity_id = wjsi_row.wip_entity_id
           and wdj.organization_id = wjsi_row.organization_id;
    end if;
  end status_type;

  procedure processing_work_days is begin
    if(wjsi_row.load_type <> wip_constants.create_sched and
       wjsi_row.processing_work_days is not null) then
      wip_jsi_utils.record_ignored_column_warning('PROCESSING_WORK_DAYS');
    end if;
  end processing_work_days;

  procedure daily_production_rate is begin
    if(wjsi_row.load_type <> wip_constants.create_sched and
       wjsi_row.daily_production_rate is not null) then
      wip_jsi_utils.record_ignored_column_warning('DAILY_PRODUCTION_RATE');
    end if;
  end daily_production_rate;

  procedure repetitive_schedule_id is begin
    if(wjsi_row.load_type = wip_constants.create_sched) then
      if(wjsi_row.repetitive_schedule_id is null) then
        select wip_repetitive_schedules_s.nextval
          into wjsi_row.repetitive_schedule_id
          from dual;
      end if;
    elsif(wjsi_row.repetitive_schedule_id is not null) then
      wip_jsi_utils.record_ignored_column_warning('REPETITIVE_SCHEDULE_ID');
    end if;
  end repetitive_schedule_id;

  procedure kanban_card_id is
    l_raw_job WIP_Work_Order_Pub.DiscreteJob_Rec_Type ;
    l_defaulted_job WIP_Work_Order_Pub.DiscreteJob_Rec_Type ;
    l_raw_sched WIP_Work_Order_Pub.RepSchedule_Rec_Type ;
    l_defaulted_sched WIP_Work_Order_Pub.RepSchedule_Rec_Type ;
  begin
    if(wjsi_row.kanban_card_id is null or wip_jsi_utils.validation_level <> wip_constants.inv) then
      return;
    end if;


    if(wjsi_row.load_type = wip_constants.create_job) then
      l_raw_job := WIP_Work_Order_Pub.G_MISS_DISCRETEJOB_REC ;

      l_raw_job.organization_id := wjsi_row.organization_id ;
      l_raw_job.kanban_card_id := wjsi_row.kanban_card_id ;
      l_raw_job.primary_item_id := nvl(wjsi_row.primary_item_id, l_raw_job.primary_item_id) ;
      l_raw_job.completion_subinventory := nvl(wjsi_row.completion_subinventory, l_raw_job.completion_subinventory) ;
      l_raw_job.completion_locator_id := nvl(wjsi_row.completion_locator_id, l_raw_job.completion_locator_id) ;
      l_raw_job.start_quantity := nvl(wjsi_row.start_quantity, l_raw_job.start_quantity) ;

      l_raw_job.action := WIP_Globals.G_OPR_DEFAULT_USING_KANBAN ;

      WIP_Default_DiscreteJob.attributes(p_discreteJob_rec => l_raw_job,
                                         x_discreteJob_rec => l_defaulted_job,
                                         p_redefault       => false);

      l_defaulted_job := WIP_DiscreteJob_Util.convert_miss_to_null(l_defaulted_job) ;
      wjsi_row.primary_item_id := l_defaulted_job.primary_item_id;
      wjsi_row.completion_subinventory := l_defaulted_job.completion_subinventory;
      wjsi_row.completion_locator_id := l_defaulted_job.completion_locator_id;
      wjsi_row.start_quantity := l_defaulted_job.start_quantity;
    elsif(wjsi_row.load_type = wip_constants.create_sched) then
      l_raw_sched := WIP_Work_Order_Pub.G_MISS_REPSCHEDULE_REC ;

      l_raw_sched.organization_id := wjsi_row.organization_id ;
      l_raw_sched.kanban_card_id := wjsi_row.kanban_card_id ;
      l_raw_sched.line_id := nvl(wjsi_row.line_id, l_raw_sched.line_id) ;
      l_raw_sched.processing_work_days := nvl(wjsi_row.processing_work_days, l_raw_sched.processing_work_days) ;
      l_raw_sched.first_unit_cpl_date := nvl(wjsi_row.first_unit_completion_date, l_raw_sched.first_unit_cpl_date) ;
      l_raw_sched.daily_production_rate := nvl(wjsi_row.daily_production_rate, l_raw_sched.daily_production_rate) ;
      l_raw_sched.action := WIP_Globals.G_OPR_DEFAULT_USING_KANBAN;

      WIP_Default_RepSchedule.attributes(p_RepSchedule_rec => l_raw_sched,
                                         x_RepSchedule_rec => l_defaulted_sched,
                                         p_redefault => false);

      l_defaulted_sched := WIP_RepSchedule_Util.convert_miss_to_null(l_defaulted_sched) ;
      wjsi_row.line_id := l_defaulted_sched.line_id;
      wjsi_row.processing_work_days := l_defaulted_sched.processing_work_days;
      wjsi_row.first_unit_completion_date := l_defaulted_sched.first_unit_cpl_date;
      wjsi_row.daily_production_rate := l_defaulted_sched.daily_production_rate;
    else
      -- A kanban reference makes sense only on a standard job or schedule
      -- creation request.
      raise fnd_api.g_exc_unexpected_error;
    end if ;
    exception when others then
      wip_jsi_utils.record_error('WIP_ML_BAD_KB_LOAD') ;
      wip_jsi_utils.abort_request ;
  end kanban_card_id ;

  procedure primary_item is begin
    if(wjsi_row.load_type in (wip_constants.resched_job, wip_constants.resched_eam_job)) then
      if(wjsi_row.primary_item_segments is not null) then
        wip_jsi_utils.record_ignored_column_warning('PRIMARY_ITEM_SEGMENTS');
      end if;
      if(wjsi_row.primary_item_id is not null) then
        wip_jsi_utils.record_ignored_column_warning('PRIMARY_ITEM_ID');
      end if;
    elsif(wjsi_row.primary_item_segments is not null) then
      if(wjsi_row.primary_item_id is null) then
        select inventory_item_id
          into wjsi_row.primary_item_id
          from mtl_system_items_kfv
         where concatenated_segments = wjsi_row.primary_item_segments
           and organization_id = wjsi_row.organization_id;
      else
        wip_jsi_utils.record_ignored_column_warning('PRIMARY_ITEM_SEGMENTS');
      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_invalid_column_error('PRIMARY_ITEM_SEGMENTS');
      wip_jsi_utils.abort_request;
  end primary_item;

  procedure start_quantity is begin
    if(wjsi_row.load_type in (wip_constants.create_eam_job, wip_constants.resched_eam_job)) then
      if(wjsi_row.start_quantity is not null) then
        wip_jsi_utils.record_ignored_column_warning('START_QUANTITY');
      end if;
      wjsi_row.start_quantity := 1;
    elsif(wjsi_row.load_type = wip_constants.create_sched and
          wjsi_row.start_quantity is not null) then
      wip_jsi_utils.record_ignored_column_warning('START_QUANTITY');
    end if;
  end start_quantity;

  procedure net_quantity is begin
    if(wjsi_row.net_quantity is null) then
      if(wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_eam_job)) then
        wjsi_row.net_quantity := wjsi_row.start_quantity;
      elsif(wjsi_row.load_type in (wip_constants.resched_job, wip_constants.resched_eam_job)) then
        select decode(wdj.net_quantity,
                      wdj.start_quantity, wjsi_row.start_quantity,
                      least(wdj.net_quantity, nvl(wjsi_row.start_quantity, wdj.net_quantity)))
          into wjsi_row.net_quantity
          from wip_discrete_jobs wdj
         where wdj.wip_entity_id = wjsi_row.wip_entity_id
           and wdj.organization_id = wjsi_row.organization_id;
      elsif(wjsi_row.load_type = wip_constants.create_ns_job) then
        wjsi_row.net_quantity := 0;
      end if;
    else
      if(wjsi_row.load_type = wip_constants.create_sched) then
        wip_jsi_utils.record_ignored_column_warning('NET_QUANTITY');
      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_invalid_column_error('NET_QUANTITY');
      wip_jsi_utils.abort_request;
  end net_quantity;

  procedure overcompletion is
    l_tolType NUMBER;
    l_tolValue NUMBER;
    l_primaryItemId NUMBER;
    begin
    if(wjsi_row.load_type in (wip_constants.create_eam_job, wip_constants.resched_eam_job, wip_constants.create_sched)) then
      if(wjsi_row.overcompletion_tolerance_type is not null) then
        wip_jsi_utils.record_ignored_column_warning ('OVERCOMPLETION_TOLERANCE_TYPE');
      end if;
      if(wjsi_row.overcompletion_tolerance_value is not null) then
        wip_jsi_utils.record_ignored_column_warning ('OVERCOMPLETION_TOLERANCE_VALUE');
      end if;
    elsif(wjsi_row.load_type = wip_constants.create_ns_job and
          wjsi_row.primary_item_id is null) then
      if(wjsi_row.overcompletion_tolerance_type is not null) then
        wip_jsi_utils.record_ignored_column_warning ('OVERCOMPLETION_TOLERANCE_TYPE');
      end if;
      if(wjsi_row.overcompletion_tolerance_value is not null) then
        wip_jsi_utils.record_ignored_column_warning ('OVERCOMPLETION_TOLERANCE_VALUE');
      end if;
    else
      if(wjsi_row.load_type = wip_constants.resched_job) then
        select overcompletion_tolerance_type, overcompletion_tolerance_value, primary_item_id
          into l_tolType, l_tolValue, l_primaryItemId
          from wip_discrete_jobs
         where wip_entity_id = wjsi_row.wip_entity_id;
        if(wjsi_row.overcompletion_tolerance_type is not null) then
          wjsi_row.overcompletion_tolerance_type := l_tolType;
        end if;
        if(wjsi_row.overcompletion_tolerance_value is not null) then
          wjsi_row.overcompletion_tolerance_value := l_tolValue;
        end if;
      else --job creation
        l_primaryItemId := wjsi_row.primary_item_id;
      end if;
      if(wjsi_row.overcompletion_tolerance_type is null and
         wjsi_row.overcompletion_tolerance_value is null and
         l_primaryItemId is not null) then
        --the only way this procedure error is if it can't find the item...thus
        --the invalid assembly error below
        WIP_Overcompletion.get_tolerance_default (p_primary_item_id  => l_primaryItemId,
                                                  p_org_id           => wjsi_row.organization_id,
                                                  p_tolerance_type   => wjsi_row.overcompletion_tolerance_type,
                                                  p_tolerance_value  => wjsi_row.overcompletion_tolerance_value);
      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_error('WIP_ML_PRIMARY_ITEM_ID');
      wip_jsi_utils.abort_request;
  end overcompletion;

  procedure wip_supply_type is begin
    if(wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_ns_job, wip_constants.create_eam_job)) then
      if(wjsi_row.wip_supply_type is null) then
        wjsi_row.wip_supply_type := wip_constants.based_on_bom;
      end if;
    elsif(wjsi_row.wip_supply_type is not null) then
      wip_jsi_utils.record_ignored_column_warning ('WIP_SUPPLY_TYPE');
    end if;
  end wip_supply_type;

  procedure class_code is
    l_entityType NUMBER;
    l_errMsg1 VARCHAR2(30);
    l_errMsg2 VARCHAR2(30);
    l_errClass1 VARCHAR2(30);
    l_errClass2 VARCHAR2(30);
    l_returnMsg VARCHAR2(200);
    l_asset_number VARCHAR2(30);
    l_asset_group_id NUMBER;
    l_job_type NUMBER;
  begin
    l_errMsg1 := null;
    l_errMsg2 := null;

    if(wjsi_row.class_code is not null) then
      return;
    end if;

    if(wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_eam_job)) then
      if(wjsi_row.load_type = wip_constants.create_job) then
        l_entityType := wip_constants.discrete;
        wjsi_row.class_code := wip_common.default_acc_class(x_org_id      => wjsi_row.organization_id,
                                                          x_item_id     => wjsi_row.primary_item_id,
                                                          x_entity_type => l_entityType,
                                                          x_project_id  => wjsi_row.project_id,
                                                          x_err_mesg_1  => l_errMsg1,
                                                          x_err_mesg_2  => l_errMsg2,
                                                          x_err_class_1 => l_errClass1,
                                                          x_err_class_2 => l_errClass2);
      else
        l_entityType := wip_constants.eam;

        if (wjsi_row.rebuild_item_id is null) then
             l_job_type := 1; -- maintenance WO
             l_asset_number := wjsi_row.asset_number;
             l_asset_group_id := wjsi_row.asset_group_id;
        else
             l_job_type := 2; -- rebuild WO
             l_asset_number := wjsi_row.rebuild_serial_number;
             l_asset_group_id := wjsi_row.rebuild_item_id;
        end if;

        wip_eam_utils.default_acc_class( p_org_id          => wjsi_row.organization_id,
                                         p_job_type        => l_job_type,
                                         p_serial_number   => l_asset_number,
                                         p_asset_group_id  => l_asset_group_id,
                                         p_parent_wo_id    => wjsi_row.parent_wip_entity_id,
                                         p_asset_activity_id  => wjsi_row.primary_item_id, -- Asset Activity
                                         p_project_id      => wjsi_row.project_id,
                                         p_task_id         => wjsi_row.task_id,
                                         x_class_code      => wjsi_row.class_code, -- WAC (return value)
                                         x_return_status   => l_returnMsg, -- Return Status
                                         x_msg_data        => l_errMsg1);  -- Error messages
      end if;
      if (l_errMsg1 is not null) then
        fnd_message.set_name('WIP', l_errMsg1);
        fnd_message.set_token('class_code', l_errClass1, false);
        wip_jsi_utils.record_current_error ;
      end if ;
      if (l_errMsg2 is not null) then
        fnd_message.set_name('WIP', l_errMsg2);
        fnd_message.set_token('class_code', l_errClass2, false);
        wip_jsi_utils.record_current_error ;
      end if ;
    elsif(wjsi_row.load_type in (wip_constants.resched_job,
                                 wip_constants.resched_eam_job,
                                 wip_constants.create_sched)) then
          if (wjsi_row.class_code is not null) then
             wip_jsi_utils.record_ignored_column_warning ('CLASS_CODE');
             return;
          end if;

      if (wjsi_row.load_type in (wip_constants.resched_job, wip_constants.resched_eam_job) and
          wjsi_row.class_code is NULL) then
         select class_code
         into   wjsi_row.class_code
         from wip_discrete_jobs
         where wip_entity_id = wjsi_row.wip_entity_id
         and organization_id = wjsi_row.organization_id;
      end if;
    end if;
  end class_code;

  procedure routing_reference is begin
    if(wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_sched, wip_constants.resched_job,
                              wip_constants.create_eam_job, wip_constants.resched_eam_job)) then
      if(wjsi_row.routing_reference_segments is not null) then
        wip_jsi_utils.record_ignored_column_warning ('ROUTING_REFERENCE_SEGMENTS');
      end if;
      if(wjsi_row.routing_reference_id is not null) then
        wip_jsi_utils.record_ignored_column_warning ('ROUTING_REFERENCE_ID');
      end if;
    elsif(wjsi_row.routing_reference_segments is not null) then
      if(wjsi_row.routing_reference_id is null) then
        select inventory_item_id
          into wjsi_row.routing_reference_id
          from mtl_system_items_kfv
         where concatenated_segments = wjsi_row.routing_reference_segments
           and organization_id = wjsi_row.organization_id;
      else
        wip_jsi_utils.record_ignored_column_warning('ROUTING_REFERENCE_SEGMENTS');
      end if;
    end if;
    exception
    when others then
      wip_jsi_utils.record_invalid_column_error('ROUTING_REFERENCE_SEGMENTS');
      wip_jsi_utils.abort_request;
  end routing_reference;

  procedure bom_reference is begin
    if(wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_sched, wip_constants.resched_job,
                              wip_constants.create_eam_job, wip_constants.resched_eam_job)) then
      if(wjsi_row.bom_reference_segments is not null) then
        wip_jsi_utils.record_ignored_column_warning ('BOM_REFERENCE_SEGMENTS');
      end if;
      if(wjsi_row.bom_reference_id is not null) then
        wip_jsi_utils.record_ignored_column_warning ('BOM_REFERENCE_ID');
      end if;
    elsif(wjsi_row.bom_reference_segments is not null) then
      if(wjsi_row.bom_reference_id is null) then
        select inventory_item_id
          into wjsi_row.bom_reference_id
          from mtl_system_items_kfv
         where concatenated_segments = wjsi_row.bom_reference_segments
           and organization_id = wjsi_row.organization_id;
      else
        wip_jsi_utils.record_ignored_column_warning('BOM_REFERENCE_SEGMENTS');
      end if;
    end if;
    exception
    when others then
      wip_jsi_utils.record_invalid_column_error('BOM_REFERENCE_SEGMENTS');
      wip_jsi_utils.abort_request;
  end bom_reference;

  procedure alternate_routing_designator is begin
    if(wjsi_row.load_type in (wip_constants.create_sched, wip_constants.resched_job, wip_constants.resched_eam_job) and
       wjsi_row.alternate_routing_designator is not null) then
        wip_jsi_utils.record_ignored_column_warning ('ALTERNATE_ROUTING_DESIGNATOR');
    end if;
  end alternate_routing_designator;

  procedure alternate_bom_designator is begin
    if(wjsi_row.load_type in (wip_constants.create_sched, wip_constants.resched_job, wip_constants.resched_eam_job) and
       wjsi_row.alternate_bom_designator is not null) then
        wip_jsi_utils.record_ignored_column_warning ('ALTERNATE_BOM_DESIGNATOR');
    end if;
  end alternate_bom_designator;

  procedure bom_revision is begin
    if(wjsi_row.load_type in (wip_constants.resched_job, wip_constants.resched_eam_job) and
       wjsi_row.bom_revision is not null) then
      wip_jsi_utils.record_ignored_column_warning('BOM_REVISION');
    elsif(wjsi_row.load_type not in (wip_constants.create_job, wip_constants.create_ns_job, wip_constants.create_eam_job)) then
      if(wjsi_row.bom_revision_date is not null and wjsi_row.bom_revision is not null) then
        wip_jsi_utils.record_ignored_column_warning('BOM_REVISION');
      end if;
    end if;
  end bom_revision;

  procedure bom_revision_date is begin
    if(wjsi_row.load_type in (wip_constants.resched_job, wip_constants.resched_eam_job) and
       wjsi_row.bom_revision_date is not null) then
      wip_jsi_utils.record_ignored_column_warning('BOM_REVISION_DATE');
    end if;
  end bom_revision_date;

  procedure routing_revision is begin
    if(wjsi_row.load_type in (wip_constants.resched_job, wip_constants.resched_eam_job) and
       wjsi_row.routing_revision is not null) then
      wip_jsi_utils.record_ignored_column_warning('ROUTING_REVISION');
    elsif(wjsi_row.load_type not in (wip_constants.create_job, wip_constants.create_ns_job, wip_constants.create_eam_job)) then
      if(wjsi_row.routing_revision_date is not null and wjsi_row.routing_revision is not null) then
        wip_jsi_utils.record_ignored_column_warning('ROUTING_REVISION');
      end if;
    end if;
  end routing_revision;

  procedure routing_revision_date is begin
    if(wjsi_row.load_type in (wip_constants.resched_job, wip_constants.resched_eam_job) and
       wjsi_row.routing_revision_date is not null) then
      wip_jsi_utils.record_ignored_column_warning('ROUTING_REVISION_DATE');
    end if;
  end routing_revision_date;

  procedure lot_number is
    l_primary_item_id NUMBER;
    l_wip_name VARCHAR2(240);
  begin
    if(wjsi_row.load_type = wip_constants.create_sched and
       wjsi_row.lot_number is not null) then
      wip_jsi_utils.record_ignored_column_warning('LOT_NUMBER');
    elsif(wjsi_row.load_type in (wip_constants.resched_job, wip_constants.resched_eam_job)) then
      select primary_item_id, wip_entity_name
        into l_primary_item_id, l_wip_name
        from wip_entities
       where wip_entity_id = wjsi_row.wip_entity_id;

      wjsi_row.lot_number := wip_lot_number_default.lot_number(p_item_id => l_primary_item_id,
                                                               p_organization_id => wjsi_row.organization_id,
                                                               p_lot_number => wjsi_row.lot_number,
                                                               p_job_name => l_wip_name,
                                                               p_default_flag => 0);
    else --job creation
      wjsi_row.lot_number := wip_lot_number_default.lot_number(p_item_id => wjsi_row.primary_item_id,
                                                               p_organization_id => wjsi_row.organization_id,
                                                               p_lot_number => wjsi_row.lot_number,
                                                               p_job_name => wjsi_row.job_name,
                                                               p_default_flag => 1);

    end if;
  exception
    when others then
      wip_jsi_utils.record_invalid_column_error('LOT_NUMBER');
      wip_jsi_utils.abort_request;
  end lot_number;

  procedure source_code is begin
    if(wjsi_row.load_type = wip_constants.create_sched and
       wjsi_row.source_code is not null) then
      WIP_JSI_Utils.Record_Ignored_Column_Warning ('SOURCE_CODE');
    end if;
  end source_code;

  procedure source_line_id is begin
    if(wjsi_row.load_type = wip_constants.create_sched and
       wjsi_row.source_line_id is not null) then
      WIP_JSI_Utils.Record_Ignored_Column_Warning ('SOURCE_LINE_ID');
    end if;
  end source_line_id;

  procedure first_unit_start_date is begin

  /* Fix for Bug#5912951-FP of 5891243. Following if condition needs to be
     commented out as this will happen in scheduling_dates in wipjsivb.pls

    if(wjsi_row.first_unit_start_date is null and
       wjsi_row.load_type = wip_constants.create_sched) then
      --if no routing used work days and last unit comp date to determine fusd
      select calendar_date
         into wjsi_row.first_unit_start_date
         from bom_calendar_dates bcd, mtl_parameters mp
         where mp.organization_id = wjsi_row.organization_id
           and bcd.exception_set_id = mp.calendar_exception_set_id
           and bcd.calendar_code = mp.calendar_code
           and seq_num = (select prior_seq_num - ceil(wjsi_row.processing_work_days)+1
                            from bom_calendar_dates b2
                           where b2.calendar_date = trunc(wjsi_row.last_unit_start_date)
                             and b2.calendar_code = mp.calendar_code
                             and b2.exception_set_id = bcd.exception_set_id)
           and (exists (select 1
                          from wip_lines wl
                         where wl.line_id = wjsi_row.line_id
                           and wl.line_schedule_type = 2))
           and (not exists (select 1
                              from bom_operational_routings bor,
                                   wip_repetitive_items wri
                             where wri.line_id = wjsi_row.line_id
                               and nvl(bor.cfm_routing_flag,2) = 2
                               and wri.primary_item_id = wjsi_row.primary_item_id
                               and wri.organization_id = wjsi_row.organization_id
                               and nvl(bor.alternate_routing_designator,'@@') =
                                      nvl(wri.alternate_routing_designator,'@@')
                               and bor.organization_id = wri.organization_id
                               and bor.assembly_item_id = wri.primary_item_id));
    end if;
    */

    /* Bug 5912951-FP of 5891243:
       Populate original job start date as fusd. This will ensure that completed operation
       dates are updated as original job start date in update_routing procedure in wipschdb.pls .
    */
    if (wjsi_row.source_code = 'MSC' and
       wjsi_row.load_type = wip_constants.resched_job and
       wjsi_row.scheduling_method = wip_constants.ml_manual) then
        select wdj.scheduled_start_date
         into wjsi_row.first_unit_start_date
         from wip_discrete_jobs wdj
         where wdj.wip_entity_id = wjsi_row.wip_entity_id
           and wdj.organization_id = wjsi_row.organization_id
           and exists ( select operation_seq_num
                        from wip_operations wo
                        where wo.wip_entity_id = wdj.wip_entity_id and
                        wo.organization_id = wdj.organization_id
                        minus
                        select  operation_seq_num
                        from    wip_job_dtls_interface
                        where   group_id = wjsi_row.group_id
                        and     parent_header_id = wjsi_row.header_id
                        and     load_type = WIP_JOB_DETAILS.WIP_OPERATION
                      ) ;

    end if;

  exception
    when no_data_found then
      null;
    when others then
      wip_jsi_utils.record_invalid_column_error('FIRST_UNIT_START_DATE');
      wip_jsi_utils.abort_request;
  end first_unit_start_date;

  procedure last_unit_start_date is begin
    if(wjsi_row.last_unit_start_date is null and
       wjsi_row.load_type = wip_constants.create_sched) then
      --if no routing used work days and first unit comp date to determine fusd
      select calendar_date
         into wjsi_row.last_unit_start_date
         from bom_calendar_dates bcd, mtl_parameters mp
         where mp.organization_id = wjsi_row.organization_id
           and bcd.exception_set_id = mp.calendar_exception_set_id
           and bcd.calendar_code = mp.calendar_code
           and seq_num = (select next_seq_num + ceil(wjsi_row.processing_work_days)-1
                            from bom_calendar_dates b2
                           where b2.calendar_date = trunc(wjsi_row.first_unit_start_date)
                             and b2.calendar_code = mp.calendar_code
                             and b2.exception_set_id = bcd.exception_set_id)
           and (exists (select 1
                          from wip_lines wl
                         where wl.line_id = wjsi_row.line_id
                           and wl.line_schedule_type = 2))
           and (not exists (select 1
                              from bom_operational_routings bor,
                                   wip_repetitive_items wri
                             where wri.line_id = wjsi_row.line_id
                               and nvl(bor.cfm_routing_flag,2) = 2
                               and wri.primary_item_id = wjsi_row.primary_item_id
                               and wri.organization_id = wjsi_row.organization_id
                               and nvl(bor.alternate_routing_designator,'@@') =
                                      nvl(wri.alternate_routing_designator,'@@')
                               and bor.organization_id = wri.organization_id
                               and bor.assembly_item_id = wri.primary_item_id));
    end if;
  exception
    when no_data_found then
         wip_jsi_utils.record_ignored_column_warning('LAST_UNIT_START_DATE');
      null;
    when others then
      wip_jsi_utils.record_invalid_column_error('LAST_UNIT_START_DATE');
      wip_jsi_utils.abort_request;
  end last_unit_start_date;

  procedure first_unit_completion_date is begin
    if(wjsi_row.first_unit_completion_date is null and
       wjsi_row.load_type = wip_constants.create_sched) then
      select calendar_date
         into wjsi_row.first_unit_completion_date
         from bom_calendar_dates bcd, mtl_parameters mp
         where mp.organization_id = wjsi_row.organization_id
           and bcd.exception_set_id = mp.calendar_exception_set_id
           and bcd.calendar_code = mp.calendar_code
           and seq_num = (select prior_seq_num - ceil(wjsi_row.processing_work_days)+1
                            from bom_calendar_dates b2
                           where b2.calendar_date = trunc(wjsi_row.last_unit_completion_date)
                             and b2.calendar_code = mp.calendar_code
                             and b2.exception_set_id = bcd.exception_set_id)
           and (exists (select 1
                          from wip_lines wl
                         where wl.line_id = wjsi_row.line_id
                           and wl.line_schedule_type = 2))
           and (not exists (select 1
                              from bom_operational_routings bor,
                                   wip_repetitive_items wri
                             where wri.line_id = wjsi_row.line_id
                               and nvl(bor.cfm_routing_flag,2) = 2
                               and wri.primary_item_id = wjsi_row.primary_item_id
                               and wri.organization_id = wjsi_row.organization_id
                               and nvl(bor.alternate_routing_designator,'@@') =
                                      nvl(wri.alternate_routing_designator,'@@')
                               and bor.organization_id = wri.organization_id
                               and bor.assembly_item_id = wri.primary_item_id));
    end if;
  exception
    when no_data_found then
      null;
    when others then
      wip_jsi_utils.record_invalid_column_error('FIRST_UNIT_COMPLETION_DATE');
      wip_jsi_utils.abort_request;
  end first_unit_completion_date;

  procedure last_unit_completion_date is begin
    if(wjsi_row.last_unit_completion_date is null and
       wjsi_row.load_type = wip_constants.create_sched) then
      select calendar_date
         into wjsi_row.last_unit_completion_date
         from bom_calendar_dates bcd, mtl_parameters mp
         where mp.organization_id = wjsi_row.organization_id
           and bcd.exception_set_id = mp.calendar_exception_set_id
           and bcd.calendar_code = mp.calendar_code
           and seq_num = (select next_seq_num + ceil(wjsi_row.processing_work_days)-1
                            from bom_calendar_dates b2
                           where b2.calendar_date = trunc(wjsi_row.first_unit_completion_date)
                             and b2.calendar_code = mp.calendar_code
                             and b2.exception_set_id = bcd.exception_set_id)
           and (exists (select 1
                          from wip_lines wl
                         where wl.line_id = wjsi_row.line_id
                           and wl.line_schedule_type = 2))
           and (not exists (select 1
                              from bom_operational_routings bor,
                                   wip_repetitive_items wri
                             where wri.line_id = wjsi_row.line_id
                               and nvl(bor.cfm_routing_flag,2) = 2
                               and wri.primary_item_id = wjsi_row.primary_item_id
                               and wri.organization_id = wjsi_row.organization_id
                               and nvl(bor.alternate_routing_designator,'@@') =
                                      nvl(wri.alternate_routing_designator,'@@')
                               and bor.organization_id = wri.organization_id
                               and bor.assembly_item_id = wri.primary_item_id));
    end if;
  exception
    when no_data_found then
      null;
    when others then
      wip_jsi_utils.record_invalid_column_error('LAST_UNIT_COMPLETION_DATE');
      wip_jsi_utils.abort_request;
  end last_unit_completion_date;

  --if routing based line and item w/no routing is used, default the other values. conditions are necessary
  --b/c it is an error to provide the combination of dates listed in the if stmt.
  procedure schedule_dates is begin
    first_unit_start_date;
    first_unit_completion_date;
    last_unit_start_date;
    last_unit_completion_date;
  end schedule_dates;

  procedure allow_explosion is begin
    if(wjsi_row.load_type = wip_constants.create_sched and
       wjsi_row.allow_explosion is not null) then
      wip_jsi_utils.record_ignored_column_warning('ALLOW_EXPLOSION');
    end if;
  end allow_explosion;

  procedure scheduling_method is begin
    if(wjsi_row.load_type = wip_constants.create_sched and
       wjsi_row.scheduling_method is not null) then
      wip_jsi_utils.record_ignored_column_warning('SCHEDULING_METHOD');
    elsif(wjsi_row.scheduling_method is null) then
      if(wjsi_row.allow_explosion is null or
         upper(wjsi_row.allow_explosion) <> 'N') then
        wjsi_row.scheduling_method := wip_constants.routing;
      else
        wjsi_row.scheduling_method := wip_constants.ml_manual;
      end if;
    end if;
  end scheduling_method;

  procedure completion_subinventory is begin
    if(wjsi_row.completion_subinventory is null) then
      if((wjsi_row.load_type = wip_constants.create_job) or
         (wjsi_row.load_type = wip_constants.create_eam_job and --for eam, comp sub in valid for rebuild jobs only
          (wjsi_row.rebuild_item_id is not null or wjsi_row.rebuild_item_segments is not null))) then
        select bor.completion_subinventory
          into wjsi_row.completion_subinventory
          from bom_operational_routings bor
         where bor.organization_id = wjsi_row.organization_id
           and nvl(bor.cfm_routing_flag,2) = 2
           and bor.assembly_item_id = wjsi_row.primary_item_id
           and nvl(bor.alternate_routing_designator,'@@@') =
                     nvl(wjsi_row.alternate_routing_designator,'@@@');
      end if;
    elsif(wjsi_row.load_type in (wip_constants.create_sched,
                                 wip_constants.resched_job,
                                 wip_constants.resched_eam_job)) then
      wip_jsi_utils.record_ignored_column_warning('COMPLETION_SUBINVENTORY');
    end if;
  exception
    when no_data_found then
      null; -- no routing
    when others then
      wip_jsi_utils.record_invalid_column_error('COMPLETION_SUBINVENTORY');
      wip_jsi_utils.abort_request;
  end completion_subinventory;

  procedure completion_locator is begin
    --note deriving locator id from segments is
    -- done in validation package as a part of the wip_locator pkg
    if(wjsi_row.completion_locator_id is null and
       wjsi_row.completion_locator_segments is null) then
      if((wjsi_row.load_type = wip_constants.create_job) or
         (wjsi_row.load_type = wip_constants.create_eam_job and --for eam, comp sub in valid for rebuild jobs only
          (wjsi_row.rebuild_item_id is not null or wjsi_row.rebuild_item_segments is not null))) then
        select bor.completion_locator_id
          into wjsi_row.completion_locator_id
          from bom_operational_routings bor
         where bor.organization_id = wjsi_row.organization_id
           and nvl(bor.cfm_routing_flag,2) = 2
           and bor.assembly_item_id = wjsi_row.primary_item_id
           and nvl(bor.alternate_routing_designator,'@@@') =
               nvl(wjsi_row.alternate_routing_designator,'@@@')
 /* Fixed for bug#3060266
  While defaulting the value for completion locator,completion sub inventory mus
t be checked.Completion locator would be defaulted from
table BOM_OPERATIONAL_ROUTINGS only if the completion sub inventory in
BOM_OPERATIONAL_ROUTINGS is same as completion sub inventory given in
table WIP_JOB_SCHEDULE_INTERFACE otherwise leave it null.
 */
      and bor.COMPLETION_SUBINVENTORY=wjsi_row.COMPLETION_SUBINVENTORY;
      end if;
    else
      if(wjsi_row.load_type in (wip_constants.create_job,
                                wip_constants.create_ns_job,
                                wip_constants.create_eam_job)) then
        if(wjsi_row.completion_locator_id is not null and
           wjsi_row.completion_locator_segments is not null) then
          wip_jsi_utils.record_ignored_column_warning('COMPLETION_LOCATOR_SEGMENTS');
        end if;
      else
        wip_jsi_utils.record_ignored_column_warning('COMPLETION_LOCATOR_ID');
      end if;
    end if;
  exception
    when no_data_found then
      null;
    when others then
      wip_jsi_utils.record_invalid_column_error('COMPLETION_LOCATOR');
      wip_jsi_utils.abort_request;
  end completion_locator;

  procedure last_updated_by_name is begin
    if(wjsi_row.last_updated_by is null) then
      select user_id
        into wjsi_row.last_updated_by
        from fnd_user
       where user_name = wjsi_row.last_updated_by_name;
    elsif(wjsi_row.last_updated_by_name is not null) then --both name + id columns are populated
      WIP_JSI_Utils.record_ignored_column_warning('LAST_UPDATED_BY_NAME');
    end if;
  exception
    when others then
      wip_jsi_utils.record_invalid_column_error('LAST_UPDATED_BY_NAME');
      wip_jsi_utils.abort_request;
  end last_updated_by_name;

  procedure created_by_name is begin
    if(wjsi_row.created_by is null) then
      select user_id
        into wjsi_row.created_by
        from fnd_user
       where user_name = wjsi_row.created_by_name;
    elsif(wjsi_row.created_by_name is not null) then --both name + id columns are populated
      WIP_JSI_Utils.record_ignored_column_warning('CREATED_BY_NAME');
    end if;
  exception
    when others then
      wip_jsi_utils.record_invalid_column_error('CREATED_BY_NAME');
      wip_jsi_utils.abort_request;
  end created_by_name;

  procedure priority is begin
    if(wjsi_row.load_type = wip_constants.create_sched and
       wjsi_row.priority is not null) then
      wip_jsi_utils.record_ignored_column_warning('PRIORITY');
    end if;
  end priority;

  --due_date/requested_start_date logic is:
  --if both are null and doing a job creation then first try to default due_date.
  --if both are still null then try to default requested_start_date
  procedure due_date is begin
    if(wjsi_row.due_date is null) then
      if(wjsi_row.requested_start_date is null and
         (wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_ns_job) OR
          (wjsi_row.load_type = wip_constants.create_eam_job and wjsi_row.pm_schedule_id is not null))) then
        wjsi_row.due_date := wjsi_row.last_unit_completion_date;
      end if;
    elsif(wjsi_row.load_type = wip_constants.create_sched) then
      wip_jsi_utils.record_ignored_column_warning('DUE_DATE');
    end if;
  end due_date;

  procedure date_released is begin
    if(wjsi_row.status_type = wip_constants.unreleased and
       wjsi_row.date_released is not null) then
      wip_jsi_utils.record_ignored_column_warning('DATE_RELEASED');
    end if;
  end date_released;

  procedure requested_start_date is begin
    if(wjsi_row.requested_start_date is null) then
      if(wjsi_row.due_date is null and
         (wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_ns_job) OR
          (wjsi_row.load_type = wip_constants.create_eam_job and wjsi_row.pm_schedule_id is not null))) then
        wjsi_row.requested_start_date := wjsi_row.first_unit_start_date;
      end if;
    elsif(wjsi_row.load_type = wip_constants.create_sched) then
      wip_jsi_utils.record_ignored_column_warning('REQUESTED_START_DATE');
    end if;
  end requested_start_date;

  procedure header_id is begin
    if(wjsi_row.load_type = wip_constants.create_sched and
       wjsi_row.header_id is not null) then
      wip_jsi_utils.record_ignored_column_warning('HEADER_ID');
    end if;
  end header_id;

  procedure end_item_unit_number is begin
    if ((wjsi_row.load_type in (wip_constants.create_sched, wip_constants.resched_job,
                                wip_constants.resched_eam_job)) and
        (wjsi_row.end_item_unit_number is not null)) then
      wip_jsi_utils.record_ignored_column_warning('END_ITEM_UNIT_NUMBER');
    end if;
  end end_item_unit_number;

  procedure asset_number is begin
    if(wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_sched,
                              wip_constants.resched_job, wip_constants.resched_eam_job,
                              wip_constants.create_ns_job) and
       wjsi_row.asset_number is not null) then
       wip_jsi_utils.record_ignored_column_warning('ASSET_NUMBER');
    end if;
  end asset_number;

  procedure asset_group is begin
    if(wjsi_row.asset_group_id is not null and
       wjsi_row.load_type <> wip_constants.create_eam_job) then
      wip_jsi_utils.record_ignored_column_warning('ASSET_GROUP_ID');
    end if;

    if(wjsi_row.asset_group_segments is not null and
       wjsi_row.load_type <> wip_constants.create_eam_job) then
      wip_jsi_utils.record_ignored_column_warning('ASSET_GROUP_SEGMENTS');
    elsif(wjsi_row.asset_group_segments is not null) then
      if(wjsi_row.asset_group_id is null) then
        select inventory_item_id
          into wjsi_row.asset_group_id
          from mtl_system_items_kfv
         where concatenated_segments = wjsi_row.asset_group_segments
           and organization_id = wjsi_row.organization_id;
      else
        wip_jsi_utils.record_ignored_column_warning('ASSET_GROUP_SEGMENTS');
      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_invalid_column_error('ASSET_GROUP_SEGMENTS');
      wip_jsi_utils.abort_request;
  end asset_group;

  procedure parent_job_name is begin
    if(wjsi_row.load_type <>  wip_constants.create_eam_job and
       wjsi_row.parent_job_name is not null) then
      wip_jsi_utils.record_ignored_column_warning('PARENT_JOB_NAME');
    elsif(wjsi_row.parent_job_name is not null) then
      if(wjsi_row.parent_wip_entity_id is null) then
        select wip_entity_id
          into wjsi_row.parent_wip_entity_id
          from wip_entities
         where wip_entity_name = wjsi_row.parent_job_name
           and organization_id = wjsi_row.organization_id;
      else
        wip_jsi_utils.record_ignored_column_warning('PARENT_JOB_NAME');
      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_invalid_column_error('PARENT_JOB_NAME');
      wip_jsi_utils.abort_request;
  end parent_job_name;

  procedure parent_wip_entity_id is begin
    if(wjsi_row.load_type <> wip_constants.create_eam_job and
       wjsi_row.parent_wip_entity_id is not null) then
      wip_jsi_utils.record_ignored_column_warning('PARENT_WIP_ENTITY_ID');
    end if;
  end parent_wip_entity_id;

  procedure rebuild_item is begin
  if(wjsi_row.load_type <> wip_constants.create_eam_job) then
    if(wjsi_row.rebuild_item_segments is not null) then
      wip_jsi_utils.record_ignored_column_warning('REBUILD_ITEM_SEGMENTS');
    end if;
    if(wjsi_row.rebuild_item_id is not null) then
      wip_jsi_utils.record_ignored_column_warning('REBUILD_ITEM_ID');
    end if;

  elsif(wjsi_row.rebuild_item_segments is not null) then
    if(wjsi_row.rebuild_item_id is null) then
      select inventory_item_id
        into wjsi_row.rebuild_item_id
        from mtl_system_items_kfv
        where concatenated_segments = wjsi_row.rebuild_item_segments
         and organization_id = wjsi_row.organization_id;
    else
      wip_jsi_utils.record_ignored_column_warning('REBUILD_ITEM_SEGMENTS');
    end if;
  end if;
  exception
    when others then
      wip_jsi_utils.record_invalid_column_error('REBUILD_ITEM_SEGMENTS');
      wip_jsi_utils.abort_request;
  end rebuild_item;

  procedure rebuild_serial_number is begin
    if(wjsi_row.load_type <> wip_constants.create_eam_job and
       wjsi_row.rebuild_serial_number is not null) then
      wip_jsi_utils.record_ignored_column_warning('REBUILD_SERIAL_NUMBER');
    end if;
  end rebuild_serial_number;

  procedure manual_rebuild_flag is begin
    if(wjsi_row.load_type <> wip_constants.create_eam_job and
       wjsi_row.manual_rebuild_flag is not null) then
      wip_jsi_utils.record_ignored_column_warning('MANUAL_REBUILD_FLAG');
    end if;
  end manual_rebuild_flag;

  procedure owning_department is
    l_returnMsg VARCHAR2(200);
    l_msgCount NUMBER;
    l_errMsg VARCHAR2(30);
  begin
    if(wjsi_row.load_type not in (wip_constants.create_eam_job, wip_constants.resched_eam_job)) then
      if(wjsi_row.owning_department_code is not null) then
        wip_jsi_utils.record_ignored_column_warning('OWNING_DEPARTMENT_CODE');
      end if;
      if(wjsi_row.owning_department is not null) then
        wip_jsi_utils.record_ignored_column_warning('OWNING_DEPARTMENT');
      end if;
    else
      if(wjsi_row.owning_department is null and wjsi_row.owning_department_code is not null) then
        select department_id
          into wjsi_row.owning_department
          from bom_departments
         where department_code = wjsi_row.owning_department_code
           and organization_id = wjsi_row.organization_id;
      elsif(wjsi_row.owning_department is null and wjsi_row.owning_department_code is null) then
        wip_eamworkorder_pvt.get_eam_owning_dept_default(p_api_version             => 1.0,
                                                         p_init_msg_list           => null,
                                                         p_commit                  => null,
                                                         p_validation_level        => null,
                                                         p_primary_item_id         => wjsi_row.primary_item_id,
                                                         p_organization_id         => wjsi_row.organization_id,
                                                         p_maintenance_object_type => wjsi_row.maintenance_object_type,
                                                         p_maintenance_object_id   => wjsi_row.maintenance_object_id,
                                                         p_rebuild_item_id         => wjsi_row.rebuild_item_id,
                                                         x_owning_department_id    => wjsi_row.owning_department,
                                                         x_return_status           => l_returnMsg,
                                                         x_msg_count               => l_msgCount,
                                                         x_msg_data                => l_errMsg);
        if (l_errMsg is not null) then
          fnd_message.set_name('WIP', 'OWNING_DEPARTMENT');
          fnd_message.set_token('owning_department', wjsi_row.owning_department, false);
          wip_jsi_utils.record_current_error;
        end if ;
      elsif(wjsi_row.owning_department_code is not null) then
        WIP_JSI_Utils.record_ignored_column_warning('OWNING_DEPARTMENT_CODE');
      end if;
    end if;
  exception
    when others then
      wip_jsi_utils.record_invalid_column_error('OWNING_DEPARTMENT_CODE');
      wip_jsi_utils.abort_request;
  end owning_department;

  procedure notification_required is
    l_returnMsg VARCHAR2(200);
    l_msgCount NUMBER;
    l_errMsg VARCHAR2(30);
  begin
    if(wjsi_row.load_type not in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
       wjsi_row.notification_required is not null) then
      wip_jsi_utils.record_ignored_column_warning('NOTIFICATION_REQUIRED');
    elsif(wjsi_row.load_type in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
          wjsi_row.notification_required is null) then
      wip_eamworkorder_pvt.get_eam_notification_default(p_api_version             => 1.0,
                                                        p_init_msg_list           => null,
                                                        p_commit                  => null,
                                                        p_validation_level        => null,
                                                        p_primary_item_id         => wjsi_row.primary_item_id,
                                                        p_organization_id         => wjsi_row.organization_id,
                                                        p_maintenance_object_type => wjsi_row.maintenance_object_type,
                                                        p_maintenance_object_id   => wjsi_row.maintenance_object_id,
                                                        p_rebuild_item_id         => wjsi_row.rebuild_item_id,
                                                        x_notification_flag       => wjsi_row.notification_required,
                                                        x_return_status           => l_returnMsg,
                                                        x_msg_count               => l_msgCount,
                                                        x_msg_data                => l_errMsg);
      if (l_errMsg is not null) then
        fnd_message.set_name('WIP', 'NOTIFICATION_REQUIRED');
        fnd_message.set_token('notification_required', wjsi_row.notification_required, false);
        wip_jsi_utils.record_current_error;
      end if ;
    end if;

  exception
    when others then
      wip_jsi_utils.record_invalid_column_error('NOTIFICATION_REQUIRED');
      wip_jsi_utils.abort_request;
  end notification_required;

  procedure shutdown_type is
    l_returnMsg VARCHAR2(200);
    l_msgCount NUMBER;
    l_errMsg VARCHAR2(30);
  begin
    if(wjsi_row.load_type not in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
       wjsi_row.shutdown_type is not null) then
      wip_jsi_utils.record_ignored_column_warning('SHUTDOWN_TYPE');
    elsif(wjsi_row.load_type in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
          wjsi_row.shutdown_type is null) then
      wip_eamworkorder_pvt.get_eam_shutdown_default(p_api_version             => 1.0,
                                                    p_init_msg_list           => null,
                                                    p_commit                  => null,
                                                    p_validation_level        => null,
                                                    p_primary_item_id         => wjsi_row.primary_item_id,
                                                    p_organization_id         => wjsi_row.organization_id,
                                                    p_maintenance_object_type => wjsi_row.maintenance_object_type,
                                                    p_maintenance_object_id   => wjsi_row.maintenance_object_id,
                                                    p_rebuild_item_id         => wjsi_row.rebuild_item_id,
                                                    x_shutdown_type_code      => wjsi_row.shutdown_type,
                                                    x_return_status           => l_returnMsg,
                                                    x_msg_count               => l_msgCount,
                                                    x_msg_data                => l_errMsg);
      if (l_errMsg is not null) then
        fnd_message.set_name('WIP', 'SHUTDOWN_TYPE');
        fnd_message.set_token('shutdown_type', wjsi_row.shutdown_type, false);
        wip_jsi_utils.record_current_error;
      end if ;
    end if;

  exception
    when others then
      wip_jsi_utils.record_invalid_column_error('SHUTDOWN_TYPE');
      wip_jsi_utils.abort_request;
  end shutdown_type;

  procedure work_order_type is begin
    if(wjsi_row.load_type not in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
       wjsi_row.work_order_type is not null) then
      wip_jsi_utils.record_ignored_column_warning('WORK_ORDER_TYPE');
    end if;
  end work_order_type;

  procedure tagout_required is
    l_returnMsg VARCHAR2(200);
    l_msgCount NUMBER;
    l_errMsg VARCHAR2(30);
  begin
    if(wjsi_row.load_type not in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
       wjsi_row.tagout_required is not null) then
      wip_jsi_utils.record_ignored_column_warning('TAGOUT_REQUIRED');
    elsif(wjsi_row.load_type in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
          wjsi_row.tagout_required is null) then
      wip_eamworkorder_pvt.get_eam_tagout_default(p_api_version             => 1.0,
                                                  p_init_msg_list           => null,
                                                  p_commit                  => null,
                                                  p_validation_level        => null,
                                                  p_primary_item_id         => wjsi_row.primary_item_id,
                                                  p_organization_id         => wjsi_row.organization_id,
                                                  p_maintenance_object_type => wjsi_row.maintenance_object_type,
                                                  p_maintenance_object_id   => wjsi_row.maintenance_object_id,
                                                  p_rebuild_item_id         => wjsi_row.rebuild_item_id,
                                                  x_tagout_required         => wjsi_row.tagout_required,
                                                  x_return_status           => l_returnMsg,
                                                  x_msg_count               => l_msgCount,
                                                  x_msg_data                => l_errMsg);
      if (l_errMsg is not null) then
        fnd_message.set_name('WIP', 'TAGOUT_REQUIRED');
        fnd_message.set_token('tagout_required', wjsi_row.tagout_required, false);
        wip_jsi_utils.record_current_error;
      end if ;
    end if;

  exception
    when others then
      wip_jsi_utils.record_invalid_column_error('TAGOUT_REQUIRED');
      wip_jsi_utils.abort_request;
  end tagout_required;

  procedure plan_maintenance is begin
    if(wjsi_row.load_type not in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
       wjsi_row.plan_maintenance is not null) then
      wip_jsi_utils.record_ignored_column_warning('PLAN_MAINTENANCE');
    elsif(wjsi_row.pm_schedule_id is not null) then
      wjsi_row.plan_maintenance := 'Y';
    end if;
  end plan_maintenance;

  procedure activity_type is
    l_returnMsg VARCHAR2(200);
    l_msgCount NUMBER;
    l_errMsg VARCHAR2(30);
  begin
    if(wjsi_row.load_type not in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
       wjsi_row.activity_type is not null) then
      wip_jsi_utils.record_ignored_column_warning('ACTIVITY_TYPE');
    elsif(wjsi_row.load_type in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
          wjsi_row.activity_type is null) then
      wip_eamworkorder_pvt.get_eam_act_type_default(p_api_version             => 1.0,
                                                    p_init_msg_list           => null,
                                                    p_commit                  => null,
                                                    p_validation_level        => null,
                                                    p_primary_item_id         => wjsi_row.primary_item_id,
                                                    p_organization_id         => wjsi_row.organization_id,
                                                    p_maintenance_object_type => wjsi_row.maintenance_object_type,
                                                    p_maintenance_object_id   => wjsi_row.maintenance_object_id,
                                                    p_rebuild_item_id         => wjsi_row.rebuild_item_id,
                                                    x_activity_type_code      => wjsi_row.activity_type,
                                                    x_return_status           => l_returnMsg,
                                                    x_msg_count               => l_msgCount,
                                                    x_msg_data                => l_errMsg);
      if (l_errMsg is not null) then
        fnd_message.set_name('WIP', 'ACTIVITY_TYPE');
        fnd_message.set_token('activity_type', wjsi_row.activity_type, false);
        wip_jsi_utils.record_current_error;
      end if;
    end if;

  exception
    when others then
      wip_jsi_utils.record_invalid_column_error('ACTIVITY_TYPE');
      wip_jsi_utils.abort_request;
  end activity_type;

  procedure activity_cause is
    l_returnMsg VARCHAR2(200);
    l_msgCount NUMBER;
    l_errMsg VARCHAR2(30);
  begin
    if(wjsi_row.load_type not in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
       wjsi_row.activity_cause is not null) then
      wip_jsi_utils.record_ignored_column_warning('ACTIVITY_CAUSE');
    elsif(wjsi_row.load_type in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
          wjsi_row.activity_cause is null) then
      wip_eamworkorder_pvt.get_eam_act_cause_default(p_api_version             => 1.0,
                                                     p_init_msg_list           => null,
                                                     p_commit                  => null,
                                                     p_validation_level        => null,
                                                     p_primary_item_id         => wjsi_row.primary_item_id,
                                                     p_organization_id         => wjsi_row.organization_id,
                                                     p_maintenance_object_type => wjsi_row.maintenance_object_type,
                                                     p_maintenance_object_id   => wjsi_row.maintenance_object_id,
                                                     p_rebuild_item_id         => wjsi_row.rebuild_item_id,
                                                     x_activity_cause_code     => wjsi_row.activity_cause,
                                                     x_return_status           => l_returnMsg,
                                                     x_msg_count               => l_msgCount,
                                                     x_msg_data                => l_errMsg);
      if (l_errMsg is not null) then
        fnd_message.set_name('WIP', 'ACTIVITY_CAUSE');
        fnd_message.set_token('activity_cause', wjsi_row.activity_cause, false);
        wip_jsi_utils.record_current_error;
      end if;
    end if;

  exception
    when others then
      wip_jsi_utils.record_invalid_column_error('ACTIVITY_CAUSE');
      wip_jsi_utils.abort_request;
  end activity_cause;

  procedure serialization_start_op is
  begin
    if(wjsi_row.load_type not in (wip_constants.create_job, wip_constants.create_ns_job, wip_constants.resched_job) and
       wjsi_row.serialization_start_op is not null) then
      wip_jsi_utils.record_ignored_column_warning('SERIALIZATION_START_OP');
    end if;
  end serialization_start_op;

  procedure material_issue_by_mo is
  l_wms_enabled_flag VARCHAR(1);
  begin
    if (wjsi_row.load_type <> wip_constants.create_eam_job and
      (wjsi_row.load_type <> wip_constants.resched_eam_job or wjsi_row.status_type <> wip_constants.draft)
      and wjsi_row.material_issue_by_mo is not null) then

         wip_jsi_utils.record_ignored_column_warning('MATERIAL_ISSUE_BY_MO');

         select material_issue_by_mo
           into   wjsi_row.material_issue_by_mo
         from wip_discrete_jobs
         where wip_entity_id = wjsi_row.wip_entity_id
           and organization_id = wjsi_row.organization_id;

    elsif (wjsi_row.load_type in (wip_constants.create_eam_job, wip_constants.resched_eam_job)) then
          select wms_enabled_flag
                into l_wms_enabled_flag
          from mtl_parameters
          where organization_id = wjsi_row.organization_id;

          if (upper(l_wms_enabled_flag) = 'Y') then
              wjsi_row.material_issue_by_mo := 'N';
          elsif (wjsi_row.material_issue_by_mo is null) then
            select material_issue_by_mo
              into wjsi_row.material_issue_by_mo
            from WIP_EAM_PARAMETERS
            where organization_id = wjsi_row.organization_id;
          end if;

    end if;
  end material_issue_by_mo;

  procedure maintenance_object_type is
  l_serial_number_control_code NUMBER;
  begin
    if(wjsi_row.load_type not in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
       wjsi_row.maintenance_object_type is not null) then
      wip_jsi_utils.record_ignored_column_warning('MAINTENANCE_OBJECT_TYPE');
    elsif(wjsi_row.load_type in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
          wjsi_row.maintenance_object_type is null) then
      if(wjsi_row.rebuild_item_id is null) then
        wjsi_row.maintenance_object_type := 1; --MSN
      else
        select serial_number_control_code
          into l_serial_number_control_code
          from mtl_system_items
         where organization_id = wjsi_row.organization_id
           and inventory_item_id = wjsi_row.rebuild_item_id;

        if(l_serial_number_control_code in (2, 5, 6)) then
          wjsi_row.maintenance_object_type := 1; --MSN
        else
          wjsi_row.maintenance_object_type := 2; --MSI
        end if;

      end if;
    end if;

  exception
    when no_data_found then
      wip_jsi_utils.record_invalid_column_error('MAINTENANCE_OBJECT_TYPE');
      wip_jsi_utils.abort_request;
    when others then
      wip_jsi_utils.record_invalid_column_error('MAINTENANCE_OBJECT_TYPE');
      wip_jsi_utils.abort_request;
  end maintenance_object_type;

  procedure maintenance_object_id is
  begin
    if(wjsi_row.load_type not in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
       wjsi_row.maintenance_object_id is not null) then
      wip_jsi_utils.record_ignored_column_warning('MAINTENANCE_OBJECT_ID');
    elsif(wjsi_row.load_type in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
          wjsi_row.maintenance_object_id is null) then
      if(wjsi_row.maintenance_object_type = 1) then
        if(wjsi_row.rebuild_item_id is null) then
          select gen_object_id
            into wjsi_row.maintenance_object_id
            from mtl_serial_numbers
           where current_organization_id = wjsi_row.organization_id
             and inventory_item_id = wjsi_row.asset_group_id
             and serial_number = wjsi_row.asset_number;
        elsif(wjsi_row.rebuild_serial_number is not null) then
          select gen_object_id
            into wjsi_row.maintenance_object_id
            from mtl_serial_numbers
           where current_organization_id = wjsi_row.organization_id
             and inventory_item_id = wjsi_row.rebuild_item_id
             and serial_number = wjsi_row.rebuild_serial_number;
        end if;
      elsif(wjsi_row.maintenance_object_type = 2) then
        wjsi_row.maintenance_object_id := wjsi_row.rebuild_item_id;
      end if;
    end if;

  exception
    when no_data_found then
      wip_jsi_utils.record_invalid_column_error('MAINTENANCE_OBJECT_ID');
      wip_jsi_utils.abort_request;
    when others then
      wip_jsi_utils.record_invalid_column_error('MAINTENANCE_OBJECT_ID');
      wip_jsi_utils.abort_request;
  end maintenance_object_id;

  procedure maintenance_object_source is begin
    if(wjsi_row.load_type not in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
       wjsi_row.maintenance_object_source is not null) then
      wip_jsi_utils.record_ignored_column_warning('MAITENANCE_OBJECT_SOURCE');
    elsif(wjsi_row.load_type in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
          wjsi_row.maintenance_object_source is null) then
      wjsi_row.maintenance_object_source := 1; --EAM
    end if;

  exception
    when others then
      wip_jsi_utils.record_invalid_column_error('MAITENANCE_OBJECT_SOURCE');
      wip_jsi_utils.abort_request;
  end maintenance_object_source;

  procedure activity_source is
    l_returnMsg VARCHAR2(200);
    l_msgCount NUMBER;
    l_errMsg VARCHAR2(30);
  begin
    if(wjsi_row.load_type not in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
       wjsi_row.activity_source is not null) then
      wip_jsi_utils.record_ignored_column_warning('ACTIVITY_SOURCE');
    elsif(wjsi_row.load_type in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
          wjsi_row.activity_source is null) then
      wip_eamworkorder_pvt.get_eam_act_source_default(p_api_version             => 1.0,
                                                      p_init_msg_list           => null,
                                                      p_commit                  => null,
                                                      p_validation_level        => null,
                                                      p_primary_item_id         => wjsi_row.primary_item_id,
                                                      p_organization_id         => wjsi_row.organization_id,
                                                      p_maintenance_object_type => wjsi_row.maintenance_object_type,
                                                      p_maintenance_object_id   => wjsi_row.maintenance_object_id,
                                                      p_rebuild_item_id         => wjsi_row.rebuild_item_id,
                                                      x_activity_source_code    => wjsi_row.activity_source,
                                                      x_return_status           => l_returnMsg,
                                                      x_msg_count               => l_msgCount,
                                                      x_msg_data                => l_errMsg);
      if (l_errMsg is not null) then
        fnd_message.set_name('WIP', 'ACTIVITY_SOURCE');
        fnd_message.set_token('activity_source', wjsi_row.activity_source, false);
        wip_jsi_utils.record_current_error;
      end if;
    end if;

  exception
    when others then
      wip_jsi_utils.record_invalid_column_error('ACTIVITY_SOURCE');
      wip_jsi_utils.abort_request;
  end activity_source;

  procedure pm_schedule_id is begin
    if(wjsi_row.load_type not in (wip_constants.create_eam_job, wip_constants.resched_eam_job) and
       wjsi_row.pm_schedule_id is not null) then
      wip_jsi_utils.record_ignored_column_warning('PM_SCHEDULE_ID');
    end if;
  end pm_schedule_id;

end wip_jsi_defaulter;

/
