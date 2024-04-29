--------------------------------------------------------
--  DDL for Package Body WIP_VALIDATEMLHEADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_VALIDATEMLHEADER_PVT" as
 /* $Header: wipmlhvb.pls 120.29.12010000.9 2010/02/18 11:39:16 sisankar ship $ */

  g_pkgName constant varchar2(30) := 'wip_validateMLHeader_pvt';

  type num_tbl_t is table of number;

  validationError constant number := 1;
  validationWarning constant number := 2;

  type wdj_rec_t is RECORD (wip_entity_name varchar2(240),
                            status_type NUMBER,
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
                            overcompletion_tolerance_type NUMBER,
                            overcompletion_tolerance_value NUMBER,
                            completion_subinventory VARCHAR2(30),
                            completion_locator_id NUMBER,
                            build_sequence NUMBER);

  type item_rec_t is RECORD(inventory_item_id NUMBER,
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

  procedure loadInterfaceError(p_interfaceTbl in out nocopy num_tbl_t,
                               p_text         in varchar2,
                               p_type         in number);

  procedure groupValidateMLHeader(p_groupID         in number,
                                  p_validationLevel in number,
                                  x_returnStatus out nocopy varchar2,
                                  x_errorMsg     out nocopy varchar2);

  procedure lineValidateMLHeader(p_groupID in number,
                                 p_validationLevel in number,
                                 x_returnStatus out nocopy varchar2,
                                 x_errorMsg     out nocopy varchar2);

  procedure setup(p_rowid in rowid);

  procedure estimateLeadTime(p_rowid    in rowid,
                             x_errorMsg out nocopy varchar2);

  procedure validateProjectTask(p_rowid    in rowid,
                                x_errorMsg out nocopy varchar2);

  procedure validateClassCode(p_rowid    in rowid,
                              x_errorMsg out nocopy varchar2);

  procedure validateBOMRevision(p_rowid    in rowid,
                                x_errorMsg out nocopy varchar2);

  procedure validateRoutingRevision(p_rowid    in rowid,
                                    x_errorMsg out nocopy varchar2);

  procedure validateStartQuantity(p_rowid    in rowid,
                                  x_errorMsg out nocopy varchar2);

  procedure validateOvercompletion(p_rowid    in rowid,
                                   x_errorMsg out nocopy varchar2);

  procedure validateSubinvLocator(p_rowid    in rowid,
                                  x_errorMsg out nocopy varchar2);

  procedure validateLotNumber(p_rowid    in rowid,
                              x_errorMsg out nocopy varchar2);

  /* Fix for #6117094. Added following procedure */
  procedure deriveScheduleDate(p_rowid    in rowid,
                              x_errorMsg out nocopy varchar2);

  procedure validateStatusType(p_rowid    in rowid,
                               x_errorMsg out nocopy varchar2);

  procedure validateBuildSequence(p_rowid    in rowid,
                                  x_errorMsg out nocopy varchar2);

  procedure validateEndItemUnitNumber(p_rowid    in rowid,
                                      x_errorMsg out nocopy varchar2);

  procedure validateDailyProductionRate(p_rowid    in rowid,
                                        x_errorMsg out nocopy varchar2);

  procedure validateRepScheduleDates(p_rowid    in rowid,
                                     x_errorMsg out nocopy varchar2);

  procedure validateKanban(p_rowid    in rowid,
                           p_validationLevel in number,
                           x_errorMsg out nocopy varchar2);

  --
  -- This procedure defaults and validates all the columns in wip_job_schedule_interface table.
  -- It does group validation where it can and does line validation otherwise. For a particular
  -- column, the default and validation logic might be splitted in two different places if it needs
  -- both line and group validation.
  -- The only exception is for column serialization_start_op. The default and validation has to be
  -- done after the routing explosion. We have two seperate APIs for this purpose.
  --
  procedure validateMLHeader(p_groupID         in number,
                             p_validationLevel in number,
                             x_returnStatus out nocopy varchar2,
                             x_errorMsg     out nocopy varchar2) is
    l_params wip_logger.param_tbl_t;
    l_procName varchar2(30) := 'validateMLHeader';
    l_logLevel number := to_number(fnd_log.g_current_runtime_level);
    l_retStatus varchar2(1);

  begin
    x_returnStatus := fnd_api.g_ret_sts_success;
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_groupID';
      l_params(1).paramValue := p_groupID;
      l_params(2).paramName := 'p_validationLevel';
      l_params(2).paramValue := p_validationLevel;
      wip_logger.entryPoint(p_procName     => g_pkgName || '.' || l_procName,
                            p_params       => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    -- do the group validation
    groupValidateMLHeader(p_groupID,
                          p_validationLevel,
                          x_returnStatus,
                          x_errorMsg);
    if ( x_returnStatus <> fnd_api.g_ret_sts_success ) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    -- do the line validation
    lineValidateMLHeader(p_groupID,
                         p_validationLevel,
                         x_returnStatus,
                         x_errorMsg);
    if ( x_returnStatus <> fnd_api.g_ret_sts_success ) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
    end if;

    exception
    when fnd_api.g_exc_unexpected_error then
      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'unexp error:' || x_errorMsg,
                             x_returnStatus     => l_retStatus);
      end if;
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
  end validateMLHeader;


  procedure groupValidateMLHeader(p_groupID         in number,
                                  p_validationLevel in number,
                                  x_returnStatus out nocopy varchar2,
                                  x_errorMsg     out nocopy varchar2) is
    l_params wip_logger.param_tbl_t;
    l_procName varchar2(30) := 'groupValidateMLHeader';
    l_logLevel number := to_number(fnd_log.g_current_runtime_level);
    l_retStatus varchar2(1);
    l_msg varchar2(2000);

    l_interfaceTbl num_tbl_t;
    l_schedGroupID number;
    l_description varchar2(240);
    l_see_eng_items_flag varchar2(1);

    --Fix for bug#4186944. Update REQUEST_ID
    x_request_id number     ;
    x_program_id number     ;
    x_application_id number ;

begin
    x_returnStatus := fnd_api.g_ret_sts_success;

    --Fix for bug#4186944. Update REQUEST_ID
    x_request_id     := fnd_global.conc_request_id ;
    x_program_id     := fnd_global.conc_program_id ;
    x_application_id := fnd_global.prog_appl_id    ;

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_groupID';
      l_params(1).paramValue := p_groupID;
      l_params(2).paramName := 'p_validationLevel';
      l_params(2).paramValue := p_validationLevel;
      wip_logger.entryPoint(p_procName     => g_pkgName || '.' || l_procName,
                            p_params       => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    if(p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)) then

    --
    -- validate load type
    --
    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type not in (WIP_CONSTANTS.CREATE_JOB,
                                  WIP_CONSTANTS.CREATE_SCHED,
                                  WIP_CONSTANTS.RESCHED_JOB,
                                  WIP_CONSTANTS.CREATE_NS_JOB)
     returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_LOAD_TYPE');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;

    --
    --Fix for bug#4186944. Update REQUEST_ID
    --
    update wip_job_schedule_interface wjsi
      set  wjsi.request_id = decode(x_request_id,-1,wjsi.request_id,x_request_id),
           wjsi.program_id = decode(x_program_id,-1,wjsi.program_id,x_program_id),
           wjsi.program_application_id = decode(x_application_id,-1,wjsi.program_application_id, x_application_id)
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING);


    --
    -- default and validate column created_by, created_by_name
    --
    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.created_by_name is not null
       and wjsi.created_by is null
       and not exists (select 1
                         from fnd_user usr
                        where usr.user_name = wjsi.created_by_name)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_INVALID');
      fnd_message.set_token('COLUMN', 'CREATED_BY_NAME', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;

    end if; /*p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)*/

    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.created_by_name is not null
       and wjsi.created_by is not null
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'CREATED_BY_NAME', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    update wip_job_schedule_interface wjsi
      set  wjsi.created_by = (select usr.user_id
                                from fnd_user usr
                               where usr.user_name = wjsi.created_by_name),
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.created_by_name is not null
       and wjsi.created_by is null;

  if(p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)) then
    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and not exists (select 1
                         from fnd_user usr
                        where usr.user_id = wjsi.created_by
                          and sysdate between usr.start_date and nvl(end_date, sysdate))
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_INVALID');
      fnd_message.set_token('COLUMN', 'CREATED_BY', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;


    --
    -- default and validate last_updated_by_name and last_updated_by
    --
    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.last_updated_by_name is not null
       and wjsi.last_updated_by is null
       and not exists (select 1
                         from fnd_user usr
                        where usr.user_name = wjsi.last_updated_by_name)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_INVALID');
      fnd_message.set_token('COLUMN', 'LAST_UPDATED_BY_NAME', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;
   end if; /*p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)*/

    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.last_updated_by_name is not null
       and wjsi.last_updated_by is not null
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'LAST_UPDATED_BY_NAME', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    update wip_job_schedule_interface wjsi
      set  wjsi.last_updated_by = (select usr.user_id
                                     from fnd_user usr
                                    where usr.user_name = wjsi.last_updated_by_name),
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.last_updated_by_name is not null
       and wjsi.last_updated_by is null;

  if(p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)) then

    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and not exists (select 1
                         from fnd_user usr
                        where usr.user_id = wjsi.last_updated_by
                          and sysdate between usr.start_date and nvl(end_date, sysdate))
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_INVALID');
      fnd_message.set_token('COLUMN', 'LAST_UPDATED_BY', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;


    --
    -- default and validate organization_code and organization_id
    --
    -- Bug 4890514. Performance Fix
    -- saugupta 25th-May-2006
    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.organization_code is not null
       and wjsi.organization_id is null
       and not exists (select 1
                         from mtl_parameters ood
                        where ood.organization_code = wjsi.organization_code)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_INVALID');
      fnd_message.set_token('COLUMN', 'ORGANIZATION_CODE', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;

  end if; /*p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)*/

    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.organization_code is not null
       and wjsi.organization_id is not null
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'ORGANIZATION_CODE', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    -- Bug 4890514. Performance Fix
    -- saugupta 25th-May-2006
    update wip_job_schedule_interface wjsi
      set  wjsi.organization_id = (select ood.organization_id
                                     from mtl_parameters ood
                                    where ood.organization_code = wjsi.organization_code),
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.organization_code is not null
       and wjsi.organization_id is null;


  if(p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)) then
    -- Bug 4890514. Performance Fix
    -- saugupta 25th-May-2006
    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and not exists (select 1
                         from wip_parameters wp,
                              mtl_parameters mp,
                              hr_organization_units ood
                        where wp.organization_id = mp.organization_id
                          and wp.organization_id = ood.organization_id
                          and wp.organization_id = wjsi.organization_id
                          and sysdate < nvl(ood.date_to, sysdate + 1))
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_ORGANIZATION_ID');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;

  end if; /*p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)*/


    --
    -- default and validate job_name and wip_entity_id column
    --
    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.job_name is not null
       and wjsi.wip_entity_id is null
       and wjsi.load_type = WIP_CONSTANTS.RESCHED_JOB
       and not exists (select 1
                         from wip_entities we
                        where we.wip_entity_name = wjsi.job_name
                          and we.organization_id = wjsi.organization_id)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_INVALID');
      fnd_message.set_token('COLUMN', 'JOB_NAME', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;

    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.job_name is not null
       and ( (wjsi.wip_entity_id is not null
              and wjsi.load_type = WIP_CONSTANTS.RESCHED_JOB) OR
             (wjsi.load_type = WIP_CONSTANTS.CREATE_SCHED) )
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'JOB_NAME', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    update wip_job_schedule_interface wjsi
       set wjsi.job_name = fnd_profile.value('WIP_JOB_PREFIX') || wip_job_number_s.nextval,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.job_name is null
       and wjsi.load_type in (WIP_CONSTANTS.CREATE_JOB, WIP_CONSTANTS.CREATE_NS_JOB);

    update wip_job_schedule_interface wjsi
      set  wjsi.wip_entity_id = (select we.wip_entity_id
                                   from wip_entities we
                                  where we.wip_entity_name = wjsi.job_name
                                    and we.organization_id = wjsi.organization_id),
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.job_name is not null
       and wjsi.wip_entity_id is null
       and wjsi.load_type = WIP_CONSTANTS.RESCHED_JOB;

    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type in (WIP_CONSTANTS.CREATE_JOB, WIP_CONSTANTS.CREATE_NS_JOB)
       and exists (select 1
                     from wip_entities we
                   where we.wip_entity_name = wjsi.job_name
                     and we.organization_id = wjsi.organization_id)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_JOB_NAME');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;

    --
    -- validate wip entity id
    --
    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.wip_entity_id is not null
       and wjsi.load_type in (WIP_CONSTANTS.CREATE_JOB,
                              WIP_CONSTANTS.CREATE_NS_JOB,
                              WIP_CONSTANTS.CREATE_SCHED)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'WIP_ENTITY_ID', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    update wip_job_schedule_interface wjsi
       set wip_entity_id = wip_entities_s.nextval,
           last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.wip_entity_id is null
       and wjsi.load_type in (WIP_CONSTANTS.CREATE_JOB,
                              WIP_CONSTANTS.CREATE_NS_JOB);

    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and ( ( wjsi.load_type = WIP_CONSTANTS.RESCHED_JOB
               and not exists (select 1
                               from wip_entities we
                              where we.organization_id = wjsi.organization_id
                                and we.wip_entity_id = wjsi.wip_entity_id))
          OR ( wjsi.load_type in (WIP_CONSTANTS.CREATE_JOB, WIP_CONSTANTS.CREATE_NS_JOB)
               and exists (select 1
                             from wip_entities we
                            where we.organization_id = wjsi.organization_id
                                and we.wip_entity_id = wjsi.wip_entity_id)))
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_WIP_ENTITY_ID');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;

    --
    -- validate for entity type
    --
    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = WIP_CONSTANTS.RESCHED_JOB
       and exists (select 1
                     from wip_entities we
                    where we.wip_entity_id = wjsi.wip_entity_id
                      and we.organization_id = wjsi.organization_id
                      and we.entity_type <> 1)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_ENTITY_TYPE');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;

    --
    -- default and validate repetitve_schedule_id
    --
    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = WIP_CONSTANTS.CREATE_SCHED
       and wjsi.repetitive_schedule_id is not null
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'REPETITIVE_SCHEDULE_ID', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    update wip_job_schedule_interface wjsi
      set  wjsi.repetitive_schedule_id = wip_repetitive_schedules_s.nextval,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = WIP_CONSTANTS.CREATE_SCHED;

    --
    -- default and validate schedule_group_id and schedule_group_name
    --
    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = WIP_CONSTANTS.CREATE_SCHED
       and wjsi.schedule_group_id is not null
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'SCHEDULE_GRPUP_ID', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and (wjsi.load_type = WIP_CONSTANTS.CREATE_SCHED or
            wjsi.schedule_group_id is not null)
       and wjsi.schedule_group_name is not null
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'SCHEDULE_GRPUP_NAME', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type in (WIP_CONSTANTS.CREATE_JOB,
                              WIP_CONSTANTS.RESCHED_JOB,
                              WIP_CONSTANTS.CREATE_NS_JOB)
       and wjsi.schedule_group_id is null
       and wjsi.schedule_group_name is not null
       and not exists (select 1
                         from wip_schedule_groups_val_v sg
                        where sg.schedule_group_name = wjsi.schedule_group_name
                          and sg.organization_id = wjsi.organization_id)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_INVALID');
      fnd_message.set_token('COLUMN', 'SCHEDULE_GROUP_NAME', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;

    update wip_job_schedule_interface wjsi
       set wjsi.schedule_group_id =
                    (select sg.schedule_group_id
                       from wip_schedule_groups_val_v sg
                      where sg.schedule_group_name = wjsi.schedule_group_name
                        and sg.organization_id = wjsi.organization_id),
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type in (WIP_CONSTANTS.CREATE_JOB,
                              WIP_CONSTANTS.RESCHED_JOB,
                              WIP_CONSTANTS.CREATE_NS_JOB)
       and wjsi.schedule_group_id is null
       and wjsi.schedule_group_name is not null;

     -- if still null, default from job if load type is reschedule job
     update wip_job_schedule_interface wjsi
        set wjsi.schedule_group_id =
                    (select wdj.schedule_group_id
                       from wip_discrete_jobs wdj
                      where wdj.wip_entity_id = wjsi.wip_entity_id
                        and wdj.organization_id = wjsi.organization_id),
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = WIP_CONSTANTS.RESCHED_JOB
       and wjsi.schedule_group_id is null;

     -- if still null, try to default from the delivery_id provided
     update wip_job_schedule_interface wjsi
        set wjsi.schedule_group_id =
                  (select wsg.schedule_group_id
                     from wip_schedule_groups wsg,
                          wsh_new_deliveries wds
                    where wds.delivery_id = wjsi.delivery_id
                      and wsg.schedule_group_name = wds.name
                      and wsg.organization_id = wjsi.organization_id),
            wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type in (WIP_CONSTANTS.CREATE_JOB,
                              WIP_CONSTANTS.RESCHED_JOB,
                              WIP_CONSTANTS.CREATE_NS_JOB)
       and wjsi.schedule_group_id is null
       and wjsi.source_code = 'WICDOL'
       and wjsi.delivery_id is not null
       and exists (select wsg.schedule_group_id
                     from wip_schedule_groups wsg,
                          wsh_new_deliveries wds
                    where wds.delivery_id = wjsi.delivery_id
                      and wsg.schedule_group_name = wds.name
                      and wsg.organization_id = wjsi.organization_id);

     -- if still null and loading from CTO, insert new groups
     select wjsi.interface_id
     bulk collect into l_interfaceTbl
      from wip_job_schedule_interface wjsi
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type in (WIP_CONSTANTS.CREATE_JOB,
                              WIP_CONSTANTS.RESCHED_JOB,
                              WIP_CONSTANTS.CREATE_NS_JOB)
       and wjsi.schedule_group_id is null
       and wjsi.source_code = 'WICDOL'
       and wjsi.delivery_id is not null;

    if ( l_interfaceTbl.count > 0 ) then
      for i in 1 .. l_interfaceTbl.count loop
        select wip_schedule_groups_s.nextval into l_schedGroupID from dual;
        insert into wip_schedule_groups(
          schedule_group_id,
          schedule_group_name,
          organization_id,
          description,
          created_by,
          last_updated_by,
          creation_date,
          last_update_date)
        select l_schedGroupID,
               wds.name,
               wjsi.organization_id,
               to_char(sysdate),
               fnd_global.user_id,
               fnd_global.user_id,
               sysdate,
               sysdate
          from wsh_new_deliveries wds,
               wip_job_schedule_interface wjsi
         where wds.delivery_id = wjsi.delivery_id
           and wjsi.interface_id = l_interfaceTbl(i);

        update wip_job_schedule_interface
           set schedule_group_id = l_schedGroupID,
               last_update_date = sysdate
         where interface_id = l_interfaceTbl(i);
      end loop;
      l_interfaceTbl.delete;
    end if;

    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type in (WIP_CONSTANTS.CREATE_JOB,
                              WIP_CONSTANTS.RESCHED_JOB,
                              WIP_CONSTANTS.CREATE_NS_JOB)
       and wjsi.schedule_group_id is not null
       and not exists (select 1
                         from wip_schedule_groups_val_v sg
                        where sg.schedule_group_id = wjsi.schedule_group_id
                          and sg.organization_id = wjsi.organization_id)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_SCHEDULE_GROUP');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;

    --
    -- default build_sequence
    --
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.build_sequence is not null
       and wjsi.load_type = wip_constants.create_sched
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'BUILD_SEQUENCE', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    --
    -- default and validate line_code and line_id
    --

  if(p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)) then

    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.line_code is not null
       and wjsi.line_id is null
       and not exists (select 1
                         from wip_lines_val_v wl
                        where wl.line_code = wjsi.line_code
                          and wl.organization_id = wjsi.organization_id)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_INVALID');
      fnd_message.set_token('COLUMN', 'LINE_CODE', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;
  end if; /*p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)*/

    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.line_code is not null
       and wjsi.line_id is not null
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'LINE_CODE', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    update wip_job_schedule_interface wjsi
       set line_id = (select wl.line_id
                        from wip_lines_val_v wl
                       where wl.line_code = wjsi.line_code
                         and wl.organization_id = wjsi.organization_id),
           last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and line_code is not null
       and line_id is null;

  if(p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)) then

    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.line_id is not null
       and not exists (select 1
                         from wip_lines_val_v wl
                        where wl.line_id = wjsi.line_id
                          and wl.organization_id = wjsi.organization_id)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_LINE_ID');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;

 end if; /*p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)*/

    -- ignore serialization_start_op for repetitive
    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = WIP_CONSTANTS.CREATE_SCHED
       and wjsi.serialization_start_op is not null
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'SERIALIZATION_START_OP', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    --
    -- default and validate project_number and project_id
    --
    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = WIP_CONSTANTS.CREATE_SCHED
       and wjsi.project_number is not null
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'PROJECT_NUMBER', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = WIP_CONSTANTS.CREATE_SCHED
       and wjsi.project_id is not null
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'PROJECT_ID', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    --
    -- default and validate task_number and task_id
    --
    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = WIP_CONSTANTS.CREATE_SCHED
       and wjsi.task_number is not null
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'TASK_NUMBER', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = WIP_CONSTANTS.CREATE_SCHED
       and wjsi.task_id is not null
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'TASK_ID', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    --
    -- default and validate firm_planned_flag
    --
    update wip_job_schedule_interface wjsi
       set wjsi.firm_planned_flag = WIP_CONSTANTS.NO,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.firm_planned_flag is null
       and wjsi.load_type in (WIP_CONSTANTS.CREATE_JOB,
                              WIP_CONSTANTS.CREATE_NS_JOB,
                              WIP_CONSTANTS.CREATE_SCHED);

  if(p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)) then

    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and (   (wjsi.load_type = WIP_CONSTANTS.CREATE_NS_JOB and
                wjsi.firm_planned_flag = WIP_CONSTANTS.YES)
            or (wjsi.firm_planned_flag = WIP_CONSTANTS.YES and
                wjsi.load_type = WIP_CONSTANTS.RESCHED_JOB and
                WIP_CONSTANTS.NONSTANDARD = (select wdj.job_type
                                               from wip_discrete_jobs wdj
                                              where wdj.wip_entity_id = wjsi.wip_entity_id
                                                and wdj.organization_id = wjsi.organization_id))
            or (wjsi.firm_planned_flag not in (WIP_CONSTANTS.YES, WIP_CONSTANTS.NO)))
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIRM_PLANNED_FLAG');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;
  end if; /*p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)*/

    --
    -- default description
    --
    fnd_message.set_name('WIP','WIP_MLD_DESC');
    fnd_message.set_token('LOAD_DATE', fnd_date.date_to_charDT(sysdate), false);
    l_description := fnd_message.get;
    update wip_job_schedule_interface wjsi
       set wjsi.description = l_description,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.description is null
       and wjsi.load_type in (WIP_CONSTANTS.CREATE_JOB,
                              WIP_CONSTANTS.CREATE_NS_JOB);

    fnd_message.set_name('WIP','WIP_MLR_DESC');
    fnd_message.set_token('LOAD_DATE', fnd_date.date_to_charDT(sysdate), false);
    l_description := fnd_message.get;
    update wip_job_schedule_interface wjsi
       set wjsi.description = l_description,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.description is null
       and wjsi.load_type = WIP_CONSTANTS.CREATE_SCHED;

    --
    -- default and validate primary_item_id and primary_item_segments
    --
    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and (wjsi.load_type = wip_constants.resched_job or
            wjsi.primary_item_id is not null)
       and wjsi.primary_item_segments is not null
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'PRIMARY_ITEM_SEGMENTS', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = wip_constants.resched_job
       and wjsi.primary_item_id is not null
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'PRIMARY_ITEM_ID', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    update wip_job_schedule_interface wjsi
       set primary_item_id = (select wdj.primary_item_id
                                from wip_discrete_jobs wdj
                               where wdj.organization_id = wjsi.organization_id
                                 and wdj.wip_entity_id = wjsi.wip_entity_id)
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = wip_constants.resched_job;

    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.primary_item_segments is not null
       and wjsi.primary_item_id is null
       and wjsi.load_type in (wip_constants.create_job,
                              wip_constants.create_ns_job,
                              wip_constants.create_sched)
       and not exists (select 1
                         from mtl_system_items_kfv msik
                        where msik.organization_id = wjsi.organization_id
                          and msik.concatenated_segments = wjsi.primary_item_segments)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_INVALID');
      fnd_message.set_token('COLUMN', 'PRIMARY_ITEM_SEGMENTS', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;

    update wip_job_schedule_interface wjsi
       set wjsi.primary_item_id = (select msik.inventory_item_id
                                     from mtl_system_items_kfv msik
                                    where msik.organization_id = wjsi.organization_id
                                      and msik.concatenated_segments = wjsi.primary_item_segments),
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type in (wip_constants.create_job,
                              wip_constants.create_ns_job,
                              wip_constants.create_sched)
       and wjsi.primary_item_segments is not null
       and wjsi.primary_item_id is null;

    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.primary_item_id is not null
       and (    wjsi.load_type in (wip_constants.create_job, wip_constants.create_sched)
            or (wjsi.load_type = wip_constants.create_ns_job and wjsi.primary_item_id is not null) )
       and not exists (select 1
                         from mtl_system_items msi
                        where msi.organization_id = wjsi.organization_id
                          and msi.inventory_item_id = wjsi.primary_item_id)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_PRIMARY_ITEM_ID');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;

    l_see_eng_items_flag := fnd_profile.value('WIP_SEE_ENG_ITEMS');
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and (  (wjsi.primary_item_id is null and
               wjsi.load_type in (wip_constants.create_job, wip_constants.create_sched))
           or (wjsi.primary_item_id is not null and
               wjsi.load_type in (wip_constants.create_job,
                                  wip_constants.create_ns_job,
                                  wip_constants.create_sched) and
               ( 'Y' <> (select msi.build_in_wip_flag
                          from mtl_system_items msi
                         where msi.organization_id = wjsi.organization_id
                           and msi.inventory_item_id = wjsi.primary_item_id) or
                 'N' <> (select msi.pick_components_flag
                          from mtl_system_items msi
                         where msi.organization_id = wjsi.organization_id
                           and msi.inventory_item_id = wjsi.primary_item_id) or
                (l_see_eng_items_flag = wip_constants.no and
                 'Y' = (select msi.eng_item_flag
                          from mtl_system_items msi
                         where msi.organization_id = wjsi.organization_id
                           and msi.inventory_item_id = wjsi.primary_item_id)))))
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_PRIMARY_ITEM_ID');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;

    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = wip_constants.create_sched
       and not exists (select 1
                         from wip_repetitive_items wri
                        where wri.line_id = wjsi.line_id
                          and wri.primary_item_id = wjsi.primary_item_id
                          and wri.organization_id = wjsi.organization_id)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_REPETITIVE_ITEM');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;

 /* FP bug 4378684. No need to validate whether ATO item has bill or not.
   This validation is removed per request by CTO team */

/*   update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type in (wip_constants.create_job,
                              wip_constants.create_sched,
                              wip_constants.create_ns_job)
       and wjsi.primary_item_id is not null
       and 'Y' = (select msi.replenish_to_order_flag
                    from mtl_system_items msi
                   where msi.organization_id = wjsi.organization_id
                     and msi.inventory_item_id = wjsi.primary_item_id)
       and 4 = (select msi.bom_item_type
                  from mtl_system_items msi
                 where msi.organization_id = wjsi.organization_id
                   and msi.inventory_item_id = wjsi.primary_item_id)
       and not exists (select 1
                         from bom_bill_of_materials bom
                        where bom.assembly_item_id = wjsi.primary_item_id
                          and bom.organization_id = wjsi.organization_id
                          and nvl(bom.alternate_bom_designator, '@@@') =
                              nvl(wjsi.alternate_bom_designator, '@@@')
                          and (bom.assembly_type = 1 or l_see_eng_items_flag = 1))
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_ATO_ITEM_NO_BOM');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;
  */

    --
    -- default and validate status_type
    -- more validation code in the validate line procedure
    --
    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = WIP_CONSTANTS.CREATE_SCHED
       and wjsi.status_type is not null
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'STATUS_TYPE', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    update wip_job_schedule_interface wjsi
      set  wjsi.status_type = WIP_CONSTANTS.UNRELEASED,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type in (WIP_CONSTANTS.CREATE_JOB, WIP_CONSTANTS.CREATE_NS_JOB)
       and wjsi.status_type is null;

    update wip_job_schedule_interface wjsi
      set  wjsi.status_type = (select wdj.status_type
                                 from wip_discrete_jobs wdj
                                where wdj.wip_entity_id = wjsi.wip_entity_id
                                  and wdj.organization_id = wjsi.organization_id),
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = WIP_CONSTANTS.RESCHED_JOB
       and wjsi.status_type is null;

  if(p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)) then

    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and (  (wjsi.load_type in (WIP_CONSTANTS.CREATE_NS_JOB,
                                  WIP_CONSTANTS.CREATE_JOB) and
               wjsi.status_type not in (WIP_CONSTANTS.UNRELEASED,
                                        WIP_CONSTANTS.RELEASED,
                                        WIP_CONSTANTS.HOLD))
           or (wjsi.load_type = wip_constants.resched_job and
               wjsi.status_type is not null and
               wjsi.status_type not in (wip_constants.unreleased,
                                        wip_constants.released,
                                        wip_constants.comp_chrg,
                                        wip_constants.hold,
                                        wip_constants.cancelled)) )
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_STATUS_TYPE');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;

  end if; /*p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)*/



    --
    -- default and validate routing_reference and routing_reference_id
    --
   /* Modified for bug 5479283. while re-scheduling non-std job we do consider reference fields. */
    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and (   wjsi.load_type in (wip_constants.create_job,
                                  wip_constants.create_sched,
                                  wip_constants.resched_job)
           or (wjsi.load_type = wip_constants.create_ns_job and
               wjsi.routing_reference_id is not null) )
       and wjsi.routing_reference_segments is not null
	   and WIP_CONSTANTS.NONSTANDARD <> (select wdj.job_type
                                            from wip_discrete_jobs wdj
                                            where wdj.wip_entity_id = wjsi.wip_entity_id
                                            and wdj.organization_id = wjsi.organization_id)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'ROUTING_REFERENCE_SEGMENTS', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;
      /* Modified for bug 5479283. while re-scheduling non-std job we do consider reference fields. */
    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type in (wip_constants.create_job,
                              wip_constants.create_sched,
                              wip_constants.resched_job)
       and wjsi.routing_reference_id is not null
	   and WIP_CONSTANTS.NONSTANDARD <> (select wdj.job_type
                                            from wip_discrete_jobs wdj
                                            where wdj.wip_entity_id = wjsi.wip_entity_id
                                            and wdj.organization_id = wjsi.organization_id)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'ROUTING_REFERENCE_ID', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

if(p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)) then
    /* Modified for bug 5479283. Validation should happen while re-scheduling non-std job */
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and (wjsi.load_type = WIP_CONSTANTS.CREATE_NS_JOB
	        OR (wjsi.load_type = WIP_CONSTANTS.RESCHED_JOB
			    and WIP_CONSTANTS.NONSTANDARD = (select wdj.job_type
                                                 from wip_discrete_jobs wdj
                                                 where wdj.wip_entity_id = wjsi.wip_entity_id
                                                 and wdj.organization_id = wjsi.organization_id)))
       and wjsi.routing_reference_segments is not null
       and wjsi.routing_reference_id is null
       and not exists (select 1
                         from mtl_system_items_kfv msik
                        where msik.organization_id = wjsi.organization_id
                          and msik.concatenated_segments = wjsi.routing_reference_segments)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_INVALID');
      fnd_message.set_token('COLUMN', 'ROUTING_REFERENCE_SEGMENTS', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;
end if; /*p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)*/
     /* Modified for bug 5479283. When Null is passed for routing reference, old value is maintained.  */
    update wip_job_schedule_interface wjsi
       set routing_reference_id = decode(wjsi.routing_reference_segments,null,(select wdj.routing_reference_id
                                                     from wip_discrete_jobs wdj
                                                     where wdj.wip_entity_id = wjsi.wip_entity_id
                                                     and wdj.organization_id = wjsi.organization_id),
										  (select inventory_item_id
                                           from mtl_system_items_kfv msik
                                           where msik.organization_id = wjsi.organization_id
                                           and msik.concatenated_segments = wjsi.routing_reference_segments)),
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and (wjsi.load_type = WIP_CONSTANTS.CREATE_NS_JOB
	        OR (wjsi.load_type = WIP_CONSTANTS.RESCHED_JOB and
	           WIP_CONSTANTS.NONSTANDARD = (select wdj.job_type
                                            from wip_discrete_jobs wdj
                                            where wdj.wip_entity_id = wjsi.wip_entity_id
                                            and wdj.organization_id = wjsi.organization_id)))
       --and wjsi.routing_reference_segments is not null
       and wjsi.routing_reference_id is null ;

  if(p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)) then
    /*Modified for bug 5479283. Validation should happen while re-scheduling non-std job */
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and (wjsi.load_type = WIP_CONSTANTS.CREATE_NS_JOB
	        OR (wjsi.load_type = WIP_CONSTANTS.RESCHED_JOB and
	           WIP_CONSTANTS.NONSTANDARD = (select wdj.job_type
                                            from wip_discrete_jobs wdj
                                            where wdj.wip_entity_id = wjsi.wip_entity_id
                                            and wdj.organization_id = wjsi.organization_id)))
       and wjsi.routing_reference_id is not null
       and not exists (select 1
                         from mtl_system_items_kfv msik
                        where msik.organization_id = wjsi.organization_id
                          and msik.inventory_item_id = wjsi.routing_reference_id)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_INVALID');
      fnd_message.set_token('COLUMN', 'ROUTING_REFERENCE_ID', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;
    /*Modified for bug 5479283. Validation should happen while re-scheduling non-std job */
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and (wjsi.load_type = WIP_CONSTANTS.CREATE_NS_JOB
	        OR (wjsi.load_type = WIP_CONSTANTS.RESCHED_JOB and
	           WIP_CONSTANTS.NONSTANDARD = (select wdj.job_type
                                            from wip_discrete_jobs wdj
                                            where wdj.wip_entity_id = wjsi.wip_entity_id
                                            and wdj.organization_id = wjsi.organization_id)))
       and wjsi.routing_reference_id is not null
       and ('Y' <> (select msi.build_in_wip_flag
                      from mtl_system_items msi
                     where msi.organization_id = wjsi.organization_id
                       and msi.inventory_item_id = wjsi.routing_reference_id) or
            'N' <> (select msi.pick_components_flag
                      from mtl_system_items msi
                     where msi.organization_id = wjsi.organization_id
                       and msi.inventory_item_id = wjsi.routing_reference_id) or
            (l_see_eng_items_flag = wip_constants.no and
             'Y' = (select msi.eng_item_flag
                      from mtl_system_items msi
                     where msi.organization_id = wjsi.organization_id
                       and msi.inventory_item_id = wjsi.routing_reference_id)))
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_ROUTING_REFERENCE_ID');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;
  end if; /*p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)*/


    --
    -- default and validate alternate_routing_designator
    --

  if(p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)) then

    /*Modified for bug 5479283. When Null is passed for alt routing designator, old value is maintained.
	                            When g_miss_char is passed for alt routing designator, updated to primary routing/bom.*/
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.alternate_routing_designator <> fnd_api.g_miss_char
       and (  (wjsi.alternate_routing_designator is not null
               and not exists (select 1
                         from bom_operational_routings bor
                        where bor.alternate_routing_designator = wjsi.alternate_routing_designator
                          and bor.organization_id = wjsi.organization_id
                          and bor.assembly_item_id = decode(wjsi.load_type,
                                wip_constants.create_ns_job, wjsi.routing_reference_id,
                                wip_constants.resched_job, decode((select wdj.job_type
                                                                    from wip_discrete_jobs wdj
                                                                   where wdj.organization_id = wjsi.organization_id
                                                                     and wdj.wip_entity_id = wjsi.wip_entity_id),
                                                                  1, wjsi.primary_item_id, wjsi.routing_reference_id),
                                wjsi.primary_item_id)
                          and nvl(bor.cfm_routing_flag, 2) = 2
                          and (bor.routing_type = 1 or (bor.routing_type = 2 and 1 = to_number(l_see_eng_items_flag))) ))
                          /* bug 4227345 */
            or (wjsi.alternate_routing_designator = fnd_api.g_miss_char
                and wjsi.load_type in (wip_constants.create_job,
                                       wip_constants.create_ns_job,
                                       wip_constants.create_sched)))
    returning wjsi.interface_id bulk collect into l_interfaceTbl;
    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_ALTERNATE_ROUTING');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;
  end if; /*p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)*/

/*Modified for bug 5479283. When Null is passed for alt routing designator, old value is maintained.
	                        When g_miss_char is passed for alt routing designator, updated to primary routing/bom.*/
    update wip_job_schedule_interface wjsi
       set wjsi.alternate_routing_designator = decode(wjsi.alternate_routing_designator,fnd_api.g_miss_char,null,null,(select wdj.alternate_routing_designator
                                                  from wip_discrete_jobs wdj
                                                 where wdj.organization_id = wjsi.organization_id
                                                   and wdj.wip_entity_id = wjsi.wip_entity_id),wjsi.alternate_routing_designator),
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = wip_constants.resched_job
       and (wjsi.alternate_routing_designator is null
	        or wjsi.alternate_routing_designator = fnd_api.g_miss_char);


  if(p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)) then

    -- you can not change the routing designator for jobs not in unreleased status
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = wip_constants.resched_job
       and nvl(wjsi.alternate_routing_designator, '@@-@@@') <>
           nvl( (select wdj.alternate_routing_designator
                  from wip_discrete_jobs wdj
                 where wdj.organization_id = wjsi.organization_id
                   and wdj.wip_entity_id = wjsi.wip_entity_id), '@@-@@@')
      and (select status_type
             from wip_discrete_jobs wdj
            where wdj.organization_id = wjsi.organization_id
              and wdj.wip_entity_id = wjsi.wip_entity_id) <> 1
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ALTERNATE_ROUTING_NOCHANGE');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;
 end if; /*p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)*/

    --
    -- default routing_revision and routing_revision_date
    --
    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = wip_constants.create_sched
       and wjsi.routing_revision_date is not null
       and wjsi.routing_revision is not null
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'ROUTING_REVISION', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

   /* Fix for bug 5020741. Do not default routing revision/revision date while updating jobs.
      update wip_job_schedule_interface wjsi
       set wjsi.routing_revision = (select wdj.routing_revision
                                  from wip_discrete_jobs wdj
                                 where wdj.organization_id = wjsi.organization_id
                                   and wdj.wip_entity_id = wjsi.wip_entity_id),
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = wip_constants.resched_job
       and (wjsi.bom_revision = fnd_api.g_miss_char
            or wjsi.bom_revision is null);

    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = wip_constants.resched_job
       and nvl(wjsi.routing_revision, '@@-@@@') <>
           nvl( (select wdj.routing_revision
                  from wip_discrete_jobs wdj
                 where wdj.organization_id = wjsi.organization_id
                   and wdj.wip_entity_id = wjsi.wip_entity_id), '@@-@@@')
      and (select status_type
             from wip_discrete_jobs wdj
            where wdj.organization_id = wjsi.organization_id
              and wdj.wip_entity_id = wjsi.wip_entity_id) <> 1
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ROUTING_REVISION_NOCHANGE');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;

    update wip_job_schedule_interface wjsi
       set wjsi.routing_revision_date = (select wdj.routing_revision_date
                                  from wip_discrete_jobs wdj
                                 where wdj.organization_id = wjsi.organization_id
                                   and wdj.wip_entity_id = wjsi.wip_entity_id),
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = wip_constants.resched_job
       and ( wjsi.routing_revision_date is null
             or wjsi.routing_revision_date = fnd_api.g_miss_date);

    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = wip_constants.resched_job
       and nvl(wjsi.routing_revision_date, fnd_api.g_miss_date) <>
           nvl((select wdj.routing_revision_date
                 from wip_discrete_jobs wdj
                where wdj.organization_id = wjsi.organization_id
                 and wdj.wip_entity_id = wjsi.wip_entity_id), fnd_api.g_miss_date)
       and (select wdj.status_type
             from wip_discrete_jobs wdj
            where wdj.organization_id = wjsi.organization_id
              and wdj.wip_entity_id = wjsi.wip_entity_id) <> 1
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ROUTING_REV_DATE_NOCHANGE');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;
*/
    --
    -- default and validate bom_reference and bom_reference_id
    --
	   /* Modified for bug 5479283. while re-scheduling non-std job we do consider reference fields. */
    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and (   wjsi.load_type in (wip_constants.create_job,
                                  wip_constants.create_sched,
                                  wip_constants.resched_job)
           or (wjsi.load_type = wip_constants.create_ns_job and
               wjsi.bom_reference_id is not null) )
       and wjsi.bom_reference_segments is not null
	   and WIP_CONSTANTS.NONSTANDARD <> (select wdj.job_type
                                            from wip_discrete_jobs wdj
                                            where wdj.wip_entity_id = wjsi.wip_entity_id
                                            and wdj.organization_id = wjsi.organization_id)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'BOM_REFERENCE_SEGMENTS', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;
   /* Modified for bug 5479283. while re-scheduling non-std job we do consider reference fields. */
    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type in (wip_constants.create_job,
                              wip_constants.create_sched,
                              wip_constants.resched_job)
       and wjsi.bom_reference_id is not null
	   and WIP_CONSTANTS.NONSTANDARD <> (select wdj.job_type
                                            from wip_discrete_jobs wdj
                                            where wdj.wip_entity_id = wjsi.wip_entity_id
                                            and wdj.organization_id = wjsi.organization_id)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'BOM_REFERENCE_ID', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;


  if(p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)) then
    /*Modified for bug 5479283.  Validation should happen while re-scheduling non-std job */
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and (wjsi.load_type = WIP_CONSTANTS.CREATE_NS_JOB
	        OR (wjsi.load_type = WIP_CONSTANTS.RESCHED_JOB and
	           WIP_CONSTANTS.NONSTANDARD = (select wdj.job_type
                                            from wip_discrete_jobs wdj
                                            where wdj.wip_entity_id = wjsi.wip_entity_id
                                            and wdj.organization_id = wjsi.organization_id)))
       and wjsi.bom_reference_segments is not null
	   and wjsi.bom_reference_id is null
       and not exists (select 1
                         from mtl_system_items_kfv msik
                        where msik.organization_id = wjsi.organization_id
                          and msik.concatenated_segments = wjsi.bom_reference_segments)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_INVALID');
      fnd_message.set_token('COLUMN', 'BOM_REFERENCE_SEGMENTS', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;
  end if; /*p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)*/
    /*Modified for bug 5479283. When Null is passed for bom reference, old value is maintained. */
    update wip_job_schedule_interface wjsi
       set bom_reference_id = decode(wjsi.bom_reference_segments,null,(select wdj.bom_reference_id
                                                                       from wip_discrete_jobs wdj
                                                                       where wdj.wip_entity_id = wjsi.wip_entity_id
                                                                       and wdj.organization_id = wjsi.organization_id),
											                     (select inventory_item_id
                                                                  from mtl_system_items_kfv msik
                                                                  where msik.organization_id = wjsi.organization_id
                                                                  and msik.concatenated_segments = wjsi.bom_reference_segments)),
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and (wjsi.load_type = WIP_CONSTANTS.CREATE_NS_JOB
	        OR (wjsi.load_type = WIP_CONSTANTS.RESCHED_JOB and
	           WIP_CONSTANTS.NONSTANDARD = (select wdj.job_type
                                            from wip_discrete_jobs wdj
                                            where wdj.wip_entity_id = wjsi.wip_entity_id
                                            and wdj.organization_id = wjsi.organization_id)))
       --and wjsi.bom_reference_segments is not null
       and (wjsi.bom_reference_id is null or wjsi.bom_reference_id=fnd_api.g_miss_num);

  if(p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)) then
  /*Modified for bug 5479283.  Validation should happen while re-scheduling non-std job */
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and (wjsi.load_type = WIP_CONSTANTS.CREATE_NS_JOB
	        OR (wjsi.load_type = WIP_CONSTANTS.RESCHED_JOB and
	           WIP_CONSTANTS.NONSTANDARD = (select wdj.job_type
                                            from wip_discrete_jobs wdj
                                            where wdj.wip_entity_id = wjsi.wip_entity_id
                                            and wdj.organization_id = wjsi.organization_id)))
       and wjsi.bom_reference_id is not null
       and not exists (select 1
                         from mtl_system_items_kfv msik
                        where msik.organization_id = wjsi.organization_id
                          and msik.inventory_item_id = wjsi.bom_reference_id)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_INVALID');
      fnd_message.set_token('COLUMN', 'BOM_REFERENCE_ID', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;
  /*Modified for bug 5479283. Validation should happen while re-scheduling non-std job */
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and (wjsi.load_type = WIP_CONSTANTS.CREATE_NS_JOB
	        OR (wjsi.load_type = WIP_CONSTANTS.RESCHED_JOB and
	           WIP_CONSTANTS.NONSTANDARD = (select wdj.job_type
                                            from wip_discrete_jobs wdj
                                            where wdj.wip_entity_id = wjsi.wip_entity_id
                                            and wdj.organization_id = wjsi.organization_id)))
       and wjsi.bom_reference_id is not null
       and ('Y' <> (select msi.build_in_wip_flag
                      from mtl_system_items msi
                     where msi.organization_id = wjsi.organization_id
                       and msi.inventory_item_id = wjsi.bom_reference_id) or
            'N' <> (select msi.pick_components_flag
                      from mtl_system_items msi
                     where msi.organization_id = wjsi.organization_id
                       and msi.inventory_item_id = wjsi.bom_reference_id) or
            (l_see_eng_items_flag = wip_constants.no and
             'Y' = (select msi.eng_item_flag
                      from mtl_system_items msi
                     where msi.organization_id = wjsi.organization_id
                       and msi.inventory_item_id = wjsi.bom_reference_id)))
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_BOM_REFERENCE_ID');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;
  end if; /*p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)*/


    --
    -- default and validate alternate_bom_designator
    --
  if(p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)) then
    /*Modified for bug 5479283. When Null is passed for alt bom designator, old value is maintained.
	                            When g_miss_char is passed for alt bom designator, updated to primary routing/bom.  */
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.alternate_bom_designator <> fnd_api.g_miss_char
       and ( (wjsi.alternate_bom_designator is not null
              and not exists (select 1
                         from bom_bill_alternates_v bba
                        where bba.alternate_bom_designator = wjsi.alternate_bom_designator
                          and bba.organization_id = wjsi.organization_id
                          and bba.assembly_item_id = decode(wjsi.load_type,
                                wip_constants.create_ns_job, wjsi.bom_reference_id,
                                wip_constants.resched_job, decode((select wdj.job_type
                                                                    from wip_discrete_jobs wdj
                                                                   where wdj.organization_id = wjsi.organization_id
                                                                     and wdj.wip_entity_id = wjsi.wip_entity_id),
                                                                  1, wjsi.primary_item_id, wjsi.bom_reference_id),
                                wjsi.primary_item_id)
                          and (bba.assembly_type = 1  or (bba.assembly_type = 2 and 1 = to_number(l_see_eng_items_flag))) ))
                          /* bug 4227345 */
           or (wjsi.alternate_bom_designator = fnd_api.g_miss_char
               and wjsi.load_type in (wip_constants.create_job,
                                      wip_constants.create_ns_job,
                                      wip_constants.create_sched)))
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_ALTERNATE_BOM');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;
  end if; /*p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)*/

/*Modified for bug 5479283. When Null is passed for alt bom designator, old value is maintained.
	                            When g_miss_char is passed for alt bom designator, updated to primary routing/bom.  */

    update wip_job_schedule_interface wjsi
       set wjsi.alternate_bom_designator = decode(wjsi.alternate_bom_designator,fnd_api.g_miss_char,null,null,
	                                         (select wdj.alternate_bom_designator
                                              from wip_discrete_jobs wdj
                                             where wdj.organization_id = wjsi.organization_id
                                               and wdj.wip_entity_id = wjsi.wip_entity_id),wjsi.alternate_bom_designator),
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = wip_constants.resched_job
       and (wjsi.alternate_bom_designator is null
	        or wjsi.alternate_bom_designator =fnd_api.g_miss_char);

    -- you can not change the bom designator for jobs not in unreleased status
  if(p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)) then
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = wip_constants.resched_job
       and nvl(wjsi.alternate_bom_designator, '@@-@@@') <>
           nvl( (select wdj.alternate_bom_designator
                  from wip_discrete_jobs wdj
                 where wdj.organization_id = wjsi.organization_id
                   and wdj.wip_entity_id = wjsi.wip_entity_id), '@@-@@@')
      and (select status_type
             from wip_discrete_jobs wdj
            where wdj.organization_id = wjsi.organization_id
              and wdj.wip_entity_id = wjsi.wip_entity_id) <> 1
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ALTERNATE_BOM_NOCHANGE');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;
  end if; /*p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)*/

    --
    -- default bom_revision and bom_revision_date
    --
    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = wip_constants.create_sched
       and wjsi.bom_revision_date is not null
       and wjsi.bom_revision is not null
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'BOM_REVISION', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

   /* Fix for bug 5020741. Do not default bom revision/revision date while updating jobs.
    update wip_job_schedule_interface wjsi
       set wjsi.bom_revision = (select wdj.bom_revision
                                  from wip_discrete_jobs wdj
                                 where wdj.organization_id = wjsi.organization_id
                                   and wdj.wip_entity_id = wjsi.wip_entity_id),
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = wip_constants.resched_job
       and (wjsi.bom_revision = fnd_api.g_miss_char
            or wjsi.bom_revision is null);

    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = wip_constants.resched_job
       and nvl(wjsi.bom_revision, '@@-@@@') <>
           nvl( (select wdj.bom_revision
                  from wip_discrete_jobs wdj
                 where wdj.organization_id = wjsi.organization_id
                   and wdj.wip_entity_id = wjsi.wip_entity_id), '@@-@@@')
      and (select status_type
             from wip_discrete_jobs wdj
            where wdj.organization_id = wjsi.organization_id
              and wdj.wip_entity_id = wjsi.wip_entity_id) <> 1
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_BOM_REVISION_NOCHANGE');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;

    update wip_job_schedule_interface wjsi
       set wjsi.bom_revision_date = (select wdj.bom_revision_date
                                  from wip_discrete_jobs wdj
                                 where wdj.organization_id = wjsi.organization_id
                                   and wdj.wip_entity_id = wjsi.wip_entity_id),
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = wip_constants.resched_job
       and ( wjsi.bom_revision_date = fnd_api.g_miss_date
             or wjsi.bom_revision_date is null);

    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = wip_constants.resched_job
       and nvl(wjsi.bom_revision_date, fnd_api.g_miss_date) <>
           nvl( (select wdj.bom_revision_date
                  from wip_discrete_jobs wdj
                 where wdj.organization_id = wjsi.organization_id
                   and wdj.wip_entity_id = wjsi.wip_entity_id), fnd_api.g_miss_date)
      and (select status_type
             from wip_discrete_jobs wdj
            where wdj.organization_id = wjsi.organization_id
              and wdj.wip_entity_id = wjsi.wip_entity_id) <> 1
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_BOM_REV_DATE_NOCHANGE');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    */


    --
    -- default and validate wip_supply_type
    --
    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type in (wip_constants.create_sched, wip_constants.resched_job)
       and wjsi.wip_supply_type is not null
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'WIP_SUPPLY_TYPE', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    update wip_job_schedule_interface wjsi
      set  wjsi.wip_supply_type = wip_constants.based_on_bom,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type in (WIP_CONSTANTS.CREATE_JOB, WIP_CONSTANTS.CREATE_NS_JOB)
       and wjsi.wip_supply_type is null;

  if(p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)) then
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and (  (wjsi.load_type in (WIP_CONSTANTS.CREATE_NS_JOB,
                                  WIP_CONSTANTS.CREATE_JOB) and
               wjsi.wip_supply_type not in (wip_constants.push,
                                            wip_constants.assy_pull,
                                            wip_constants.op_pull,
                                            wip_constants.bulk,
                                            wip_constants.vendor,
                                            wip_constants.phantom,
                                            wip_constants.based_on_bom))
           or (wjsi.load_type = wip_constants.create_ns_job and
               wjsi.primary_item_id is null and
               wjsi.wip_supply_type in (wip_constants.assy_pull,
                                        wip_constants.op_pull))
           or (wjsi.wip_supply_type = wip_constants.op_pull and
               not exists
                 (select 1
                    from bom_operational_routings bor
                   where bor.organization_id = wjsi.organization_id
                     and bor.assembly_item_id = decode(wjsi.load_type,
                                                wip_constants.create_ns_job, wjsi.routing_reference_id,
                                                wjsi.primary_item_id)
                     and nvl(alternate_routing_designator, '@@@') =
                         nvl(wjsi.alternate_routing_designator, '@@@')
                     and nvl(cfm_routing_flag, 2) = 2)))
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_WIP_SUPPLY_TYPE');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;
  end if; /*p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)*/

    --
    -- default and validate start_quantity
    --
    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.start_quantity is not null
       and (   wjsi.load_type = wip_constants.create_sched
            or (wjsi.load_type = wip_constants.resched_job and
                (select wdj.status_type
                   from wip_discrete_jobs wdj
                  where wdj.organization_id = wjsi.organization_id
                    and wdj.wip_entity_id = wjsi.wip_entity_id) not in
                                       (wip_constants.unreleased,
                                        wip_constants.released,
                                        wip_constants.comp_chrg,
                                        wip_constants.hold)) )
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'START_QUANTITY', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

  if(p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)) then
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and (   wjsi.start_quantity < 0
           or (wjsi.load_type in (wip_constants.create_job,  wip_constants.create_ns_job) and
               wjsi.start_quantity is null)
           or (wjsi.load_type = wip_constants.create_job and
               wjsi.start_quantity = 0)
           or (wjsi.load_type = wip_constants.resched_job and
               wjsi.start_quantity = 0 and
               wip_constants.standard  = (select wdj.job_type
                                           from wip_discrete_jobs wdj
                                          where wdj.organization_id = wjsi.organization_id
                                            and wdj.wip_entity_id = wjsi.wip_entity_id)))
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_START_QUANTITY');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;

    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = wip_constants.resched_job
       and wjsi.start_quantity is not null
       and (   wjsi.start_quantity < (select wdj.quantity_completed
                                        from wip_discrete_jobs wdj
                                       where wdj.organization_id = wjsi.organization_id
                                            and wdj.wip_entity_id = wjsi.wip_entity_id)
           or (0 < (select count(*)
                      from wip_reservations_v wr
                     where wr.wip_entity_id = wjsi.wip_entity_id
                       and wr.organization_id = wjsi.organization_id) and
               wjsi.start_quantity < (select sum(wr.primary_quantity)
                                        from wip_reservations_v wr
                                       where wr.organization_id = wjsi.organization_id
                                         and wr.wip_entity_id = wjsi.wip_entity_id)))
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_RESCHEDULE_QUANTITY');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;
  end if; /*p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)*/

    --
    -- default and validate net_quantity
    --
    update wip_job_schedule_interface wjsi
      set  wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = wip_constants.create_sched
       and wjsi.net_quantity is not null
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'NET_QUANTITY', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    update wip_job_schedule_interface wjsi
       set wjsi.net_quantity = wjsi.start_quantity,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = wip_constants.create_job
       and wjsi.net_quantity is null;

    update wip_job_schedule_interface wjsi
       set wjsi.net_quantity = (select decode(wdj.net_quantity,
                                      wdj.start_quantity, wjsi.start_quantity,
                                      least(wdj.net_quantity, nvl(wjsi.start_quantity, wdj.net_quantity)))
                                 from wip_discrete_jobs wdj
                                where wdj.wip_entity_id = wjsi.wip_entity_id
                                  and wdj.organization_id = wjsi.organization_id),
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = wip_constants.resched_job
       and wjsi.net_quantity is null;

    update wip_job_schedule_interface wjsi
       set wjsi.net_quantity = 0,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = wip_constants.create_ns_job
       and wjsi.net_quantity is null;

  if(p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)) then
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.net_quantity is not null
       and wjsi.load_type in (wip_constants.create_job,
                              wip_constants.create_ns_job,
                              wip_constants.resched_job)
       and (   wjsi.net_quantity not between 0 and (select nvl(wjsi.start_quantity,wdj.start_quantity)
                                                    from wip_discrete_jobs wdj
                                                   where wdj.organization_id = wjsi.organization_id
                                                     and wdj.wip_entity_id = wjsi.wip_entity_id)   /*Fix for Bug 6522139*/
           or (     wjsi.net_quantity <> 0
               and ((wjsi.load_type = wip_constants.create_ns_job and wjsi.primary_item_id is null) or
                    (wjsi.load_type = wip_constants.resched_job and
                     wip_constants.nonstandard = (select wdj.job_type
                                                    from wip_discrete_jobs wdj
                                                   where wdj.organization_id = wjsi.organization_id
                                                     and wdj.wip_entity_id = wjsi.wip_entity_id) and
                     (select wdj.primary_item_id
                        from wip_discrete_jobs wdj
                       where wdj.organization_id = wjsi.organization_id
                         and wdj.wip_entity_id = wjsi.wip_entity_id) is null))))
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_NET_QUANTITY');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;
  end if; /*p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)*/

    --
    -- overcompletion_tolerance_type and overcompletion_tolerance_value
    --
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.overcompletion_tolerance_type is not null
       and (   wjsi.load_type = wip_constants.create_sched
           or (wjsi.load_type = wip_constants.create_ns_job and
               wjsi.primary_item_id is null))
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'OVERCOMPLETION_TOLERANCE_TYPE', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.overcompletion_tolerance_value is not null
       and (   wjsi.load_type = wip_constants.create_sched
           or (wjsi.load_type = wip_constants.create_ns_job and
               wjsi.primary_item_id is null))
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'OVERCOMPLETION_TOLERANCE_VALUE', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    --
    -- default due_date
    --
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.due_date is not null
       and wjsi.load_type = wip_constants.create_sched
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'DUE_DATE', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    update wip_job_schedule_interface wjsi
       set wjsi.due_date = wjsi.last_unit_completion_date,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.due_date is null
       and wjsi.requested_start_date is null
       and wjsi.load_type in (wip_constants.create_job, wip_constants.create_ns_job);

    --
    -- validate date_released
    --
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.date_released is not null
       and wjsi.status_type = wip_constants.unreleased
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'DATE_RELEASED', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and nvl(wjsi.date_released, sysdate) > sysdate
       and wjsi.status_type = wip_constants.released
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_INVALID_RELEASE_DATE');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
      -- set it to sysdate
      update wip_job_schedule_interface wjsi
       set wjsi.date_released = sysdate,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.date_released > sysdate
       and wjsi.status_type = wip_constants.released;
    end if;

    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.status_type = wip_constants.released
       and exists (select 1
                     from wip_discrete_jobs
                    where wip_entity_id = wjsi.wip_entity_id
                      and organization_Id = wjsi.organization_id
                      and (status_type IS NULL OR
                           status_type NOT IN (wip_constants.released,wip_constants.comp_chrg,
                                               wip_constants.cancelled, wip_constants.hold)))
       and not exists (select 1
                         from org_acct_periods oap
                        where oap.organization_id = wjsi.organization_id
                          and trunc(INV_LE_TIMEZONE_PUB.GET_LE_DAY_FOR_INV_ORG(nvl(wjsi.date_released,sysdate), wjsi.organization_id))
                              between oap.period_start_date and oap.schedule_close_date
                          and oap.period_close_date is null)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_NO_ACCT_PERIOD');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;


    --
    -- requested_start_date
    --
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.requested_start_date is not null
       and wjsi.load_type = wip_constants.create_sched
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'REQUESTED_START_DATE', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    update wip_job_schedule_interface wjsi
       set wjsi.requested_start_date = wjsi.first_unit_start_date,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.due_date is null
       and wjsi.requested_start_date is null
       and wjsi.load_type in (wip_constants.create_job, wip_constants.create_ns_job);

    --
    -- header_id
    --
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.header_id is not null
       and wjsi.load_type = wip_constants.create_sched
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'HEADER_ID', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    --
    -- default and validate processing_work_days
    --
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.processing_work_days is not null
       and wjsi.load_type <> wip_constants.create_sched
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'PROCESSING_WORK_DAYS', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

  if(p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)) then
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = wip_constants.create_sched
       and (wjsi.processing_work_days <= 0 or wjsi.processing_work_days is null)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_PROCESSING_WORK_DAYS');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;
  end if; /*p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)*/

    --
    -- default and validate daily_production_rate
    --
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.daily_production_rate is not null
       and wjsi.load_type <> wip_constants.create_sched
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'DAILY_PRODUCTION_RATE', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

  if(p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)) then
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = wip_constants.create_sched
       and (wjsi.daily_production_rate <= 0 or wjsi.daily_production_rate is null)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_PROCESSING_WORK_DAYS');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;
  end if; /*p_validationLevel NOT IN (wip_constants.mrp, wip_constants.ato)*/

    --
    -- default and validate demand_class
    --
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.demand_class is not null
       and wjsi.load_type = wip_constants.resched_job
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'DEMAND_CLASS', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type in (wip_constants.create_sched,
                              wip_constants.create_job,
                              wip_constants.create_ns_job)
       and wjsi.demand_class is not null
       and not exists (select 1
                         from so_demand_classes_active_v sdc
                        where sdc.demand_class_code = wjsi.demand_class)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_DEMAND_CLASS');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;

    --
    -- default and validate completion_subinventory
    --
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.completion_subinventory is not null
       and wjsi.load_type in (wip_constants.resched_job,
                              wip_constants.create_sched)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'COMPLETION_SUBINVENTORY', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    update wip_job_schedule_interface wjsi
       set wjsi.completion_subinventory =
               (select bor.completion_subinventory
                  from bom_operational_routings bor
                 where bor.organization_id = wjsi.organization_id
                   and nvl(bor.cfm_routing_flag,2) = 2
                   and bor.assembly_item_id = wjsi.primary_item_id
                   and nvl(bor.alternate_routing_designator,'@@@') =
                       nvl(wjsi.alternate_routing_designator, '@@@')),
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.completion_subinventory is null
       and wjsi.load_type = wip_constants.create_job;

    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type = wip_constants.create_ns_job
       and wjsi.primary_item_id is null
       and wjsi.completion_subinventory is not null
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_COMPLETION_SUBINVENTORY');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;

    --
    -- Default completion_locator_id
    --
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.completion_locator_id is not null
       and wjsi.load_type in (wip_constants.resched_job,
                              wip_constants.create_sched)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'COMPLETION_LOCATOR_ID', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.completion_locator_id is not null
       and wjsi.completion_locator_segments is not null
       and wjsi.load_type in (wip_constants.create_job,
                              wip_constants.create_ns_job)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'COMPLETION_LOCATOR_SEGMENTS', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    update wip_job_schedule_interface wjsi
       set wjsi.completion_locator_id =
                  (select bor.completion_locator_id
                     from bom_operational_routings bor
                    where bor.organization_id = wjsi.organization_id
                      and nvl(bor.cfm_routing_flag, 2) = 2
                      and bor.assembly_item_id = wjsi.primary_item_id
                      and nvl(bor.alternate_routing_designator,'@@@') =
                          nvl(wjsi.alternate_routing_designator, '@@@')
                      and bor.completion_subinventory = wjsi.completion_subinventory),
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.completion_locator_id is null
       and wjsi.completion_locator_segments is null
       and wjsi.load_type = wip_constants.create_job;

    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type in (wip_constants.create_ns_job, wip_constants.create_job)
       and wjsi.completion_subinventory is null
       and wjsi.completion_locator_id is not null
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_COMPLETION_LOCATOR');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;

    --
    -- default and validate lot_number
    --
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.lot_number is not null
       and wjsi.load_type = wip_constants.create_sched
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'LOT_NUMBER', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    --
    -- default and validate source_code and source_line_id
    --
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.source_code is not null
       and wjsi.load_type = wip_constants.create_sched
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'SOURCE_CODE', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.source_line_id is not null
       and wjsi.load_type = wip_constants.create_sched
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'SOURCE_LINE_ID', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    --
    -- default and validate scheduling_method
    --
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.scheduling_method is not null
       and wjsi.load_type = wip_constants.create_sched
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'SCHEDULING_METHOD', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

/*bug 7568044: setting scheduling_method to be manual for a non-standard discrete job in case when no routing reference is provided*/
    update wip_job_schedule_interface wjsi
	set wjsi.scheduling_method = wip_constants.ml_manual,
		wjsi.last_update_date = sysdate
    where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.scheduling_method is null
	   and wjsi.load_type = WIP_CONSTANTS.CREATE_NS_JOB
	   and wjsi.routing_reference_id is null;

    update wip_job_schedule_interface wjsi
       set wjsi.scheduling_method = wip_constants.routing,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.scheduling_method is null
       and (  wjsi.allow_explosion is null
           or upper(wjsi.allow_explosion) <> 'N');

    update wip_job_schedule_interface wjsi
       set wjsi.scheduling_method = wip_constants.ml_manual,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.scheduling_method is null
       and upper(wjsi.allow_explosion) = 'N';

    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.load_type in (wip_constants.create_ns_job,
                              wip_constants.create_job,
                              wip_constants.resched_job)
       and wjsi.scheduling_method not in (wip_constants.routing,
                                          wip_constants.leadtime,
                                          wip_constants.ml_manual)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_SCHEDULING_METHOD');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;

    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and (   (wjsi.scheduling_method = wip_constants.leadtime
                and ((wjsi.load_type = wip_constants.create_ns_job and
                      wjsi.routing_reference_id is null) or
                     (wjsi.load_type = wip_constants.resched_job and
                      (select wdj.job_type
                         from wip_discrete_jobs wdj
                        where wdj.organization_id = wjsi.organization_id
                          and wdj.wip_entity_id = wjsi.wip_entity_id) = wip_constants.nonstandard and
                      (select wdj.routing_reference_id
                         from wip_discrete_jobs wdj
                        where wdj.organization_id = wjsi.organization_id
                          and wdj.wip_entity_id = wjsi.wip_entity_id) is null)))
            or (wjsi.scheduling_method = wip_constants.ml_manual
                and (wjsi.first_unit_start_date is null or
                     wjsi.last_unit_completion_date is null or
                     wjsi.first_unit_start_date > wjsi.last_unit_completion_date)))
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_SCHEDULING_METHOD');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;

    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.scheduling_method = wip_constants.routing
       and wjsi.allow_explosion in ('n', 'N')
       and wjsi.load_type = wip_constants.create_job
       and (wjsi.first_unit_start_date is null or
            wjsi.last_unit_completion_date is null)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_SCHEDULING_METHOD2');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;

    --
    -- default and validate allow_explosion
    --
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.allow_explosion is not null
       and wjsi.load_type = wip_constants.create_sched
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'ALLOW_EXPLOSION', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    --
    -- default and validate allow_explosion
    --
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.priority is not null
       and wjsi.load_type = wip_constants.create_sched
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'PRIORITY', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    --
    -- default and validate end_item_unit_number
    --
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.WARNING,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.end_item_unit_number is not null
       and wjsi.load_type in (wip_constants.create_sched,
                              wip_constants.resched_job)
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'END_ITEM_UNIT_NUMBER', false);
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
    end if;

    --
    -- validate schedule dates
    --
    if ( p_validationLevel not in (wip_constants.mrp, wip_constants.ato) ) then
	/* Modified For bug 5479283. To check against current value of routing reference id.*/
      update wip_job_schedule_interface wjsi
         set wjsi.process_status = WIP_CONSTANTS.ERROR,
             wjsi.last_update_date = sysdate
       where wjsi.group_id = p_groupID
         and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
         and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
         and (  (wjsi.load_type = wip_constants.create_ns_job and
                 --must provide both dates when creating a ns job
                 wjsi.routing_reference_id is null and
                 (wjsi.first_unit_start_date is null or wjsi.last_unit_completion_date is null))
             or (wjsi.load_type = wip_constants.resched_job and
                 --when rescheduling a ns job and providing one date, it must have a routing
                 wip_constants.nonstandard = (select wdj.job_type
                                                from wip_discrete_jobs wdj
                                               where wdj.organization_id = wjsi.organization_id
                                                 and wdj.wip_entity_id = wjsi.wip_entity_id) and
                 /* (select wdj.routing_reference_id
                    from wip_discrete_jobs wdj
                   where wdj.organization_id = wjsi.organization_id
                     and wdj.wip_entity_id = wjsi.wip_entity_id) */ wjsi.routing_reference_id is null and
		   (select count(*)
		      from wip_operations
		     where organization_id = wjsi.organization_id
		       and wip_entity_id = wjsi.wip_entity_id) = 0   and
                  ((wjsi.first_unit_start_date is not null or  wjsi.last_unit_completion_date is not null)
		   /* Bug fix : 8407567 If scheduling method is manual, then both the dates are needed */
		   and wjsi.scheduling_method <> wip_constants.ml_manual))
             or (wjsi.load_type in (wip_constants.create_job, wip_constants.create_ns_job) and
                 --all job creations must have at least one date
                 wjsi.first_unit_start_date is null  and
                 wjsi.last_unit_completion_date is null)
             or (wjsi.load_type = wip_constants.resched_job and
                 --when changing the quantity, you must also provide a date
                 wjsi.start_quantity is not null and
                 wjsi.first_unit_start_date is null  and
                 wjsi.last_unit_completion_date is null)
             or (wjsi.load_type = wip_constants.resched_job and
                 --if not exploding, then the user must provide both dates or none at all
                 wjsi.allow_explosion in ('N', 'n') and
                 ((wjsi.first_unit_start_date is not null and wjsi.last_unit_completion_date is null) or
                  (wjsi.first_unit_start_date is null and wjsi.last_unit_completion_date is not null)))
             or (wjsi.first_unit_start_date is not null and
                 not exists (select 1
                               from bom_calendar_dates bcd,
                                    mtl_parameters mp
                              where mp.organization_id = wjsi.organization_id
                                and mp.calendar_code = bcd.calendar_code
                                and mp.calendar_exception_set_id = bcd.exception_set_id
                                and bcd.calendar_date = trunc(wjsi.first_unit_start_date)))
             or (wjsi.last_unit_completion_date is not null and
                 not exists (select 1
                               from bom_calendar_dates bcd,
                                    mtl_parameters mp
                              where mp.organization_id = wjsi.organization_id
                                and mp.calendar_code = bcd.calendar_code
                                and mp.calendar_exception_set_id = bcd.exception_set_id
                                and bcd.calendar_date = trunc(wjsi.last_unit_completion_date))))
      returning wjsi.interface_id bulk collect into l_interfaceTbl;


      if ( sql%rowcount > 0 ) then
        fnd_message.set_name('WIP', 'WIP_ML_SCHEDULE_DATES');
        loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
      end if;

      update wip_job_schedule_interface wjsi
         set wjsi.process_status = WIP_CONSTANTS.WARNING,
             wjsi.last_update_date = sysdate
       where wjsi.group_id = p_groupID
         and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
         and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
         and wjsi.last_unit_start_date is not null
         and wjsi.load_type <> wip_constants.create_sched
      returning wjsi.interface_id bulk collect into l_interfaceTbl;

      if ( sql%rowcount > 0 ) then
        fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
        fnd_message.set_token('COLUMN', 'LAST_UNIT_START_DATE', false);
        loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
      end if;

      update wip_job_schedule_interface wjsi
         set wjsi.process_status = WIP_CONSTANTS.WARNING,
             wjsi.last_update_date = sysdate
       where wjsi.group_id = p_groupID
         and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
         and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
         and wjsi.first_unit_completion_date is not null
         and wjsi.load_type <> wip_constants.create_sched
      returning wjsi.interface_id bulk collect into l_interfaceTbl;

      if ( sql%rowcount > 0 ) then
        fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
        fnd_message.set_token('COLUMN', 'FIRST_UNIT_COMPLETION_DATE', false);
        loadInterfaceError(l_interfaceTbl, fnd_message.get, validationWarning);
      end if;
    end if;

    --
    -- validate serialization_start_op
    --
    update wip_job_schedule_interface wjsi
       set wjsi.process_status = WIP_CONSTANTS.ERROR,
           wjsi.last_update_date = sysdate
     where wjsi.group_id = p_groupID
       and wjsi.process_phase = WIP_CONSTANTS.ML_VALIDATION
       and wjsi.process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING)
       and wjsi.serialization_start_op is not null
       and wjsi.load_type = wip_constants.create_sched
    returning wjsi.interface_id bulk collect into l_interfaceTbl;

    if ( sql%rowcount > 0 ) then
      fnd_message.set_name('WIP', 'WIP_ML_SERIAL_START_OP');
      loadInterfaceError(l_interfaceTbl, fnd_message.get, validationError);
    end if;

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
  end groupValidateMLHeader;


  procedure lineValidateMLHeader(p_groupID in number,
                                 p_validationLevel in number,
                                 x_returnStatus out nocopy varchar2,
                                 x_errorMsg     out nocopy varchar2) is
    l_params wip_logger.param_tbl_t;
    l_procName varchar2(30) := 'lineValidateMLHeader';
    l_logLevel number := to_number(fnd_log.g_current_runtime_level);
    l_retStatus varchar2(1);
    l_msg varchar2(2000);
    l_orginalOrgContext number;
    l_operatingUnit number;

    cursor c_line is
      select rowid,
             interface_id
        from wip_job_schedule_interface
       where group_id = p_groupID
         and process_phase = WIP_CONSTANTS.ML_VALIDATION
         and process_status in (WIP_CONSTANTS.RUNNING, WIP_CONSTANTS.WARNING);
  begin
    x_returnStatus := fnd_api.g_ret_sts_success;
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(2).paramName := 'p_validationLevel';
      l_params(2).paramValue := p_validationLevel;
      wip_logger.entryPoint(p_procName     => g_pkgName || '.' || l_procName,
                            p_params       => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    for line in c_line loop
      begin
        setup(line.rowid);

        if (l_logLevel <= wip_constants.trace_logging) then
          wip_logger.log('begin to validate record with interface_id: ' || wjsi_row.interface_id,
                         l_retStatus);
        end if;

        validateKanban(line.rowid, p_validationLevel, l_msg);

        -- save the original org context
        l_orginalOrgContext := nvl(fnd_profile.value('ORG_ID'), -1);

        -- set the org context for future PJM validation
        -- Bug 4890514. Performance Fix
        -- saugupta 25th-May-2006
        /*
        select ood.operating_unit
          into l_operatingUnit
          from wip_parameters wp,
               mtl_parameters mp,
               org_organization_definitions ood
         where wp.organization_id = mp.organization_id
           and wp.organization_id = ood.organization_id
           and wp.organization_id = wjsi_row.organization_id
           and sysdate < nvl(ood.disable_date, sysdate+1);
        fnd_client_info.set_org_context(to_char(l_operatingUnit));
        */
        SELECT
            decode(hoi.org_information_context, 'Accounting Information',
                     to_number(hoi.org_information3), to_number(null)) operating_unit
        INTO l_operatingUnit
        FROM hr_organization_units hou,
            wip_parameters wp,
            mtl_parameters mp,
            hr_organization_information hoi
        WHERE hou.organization_id                   = hoi.organization_id
            and ( hoi.org_information_context || '') = 'Accounting Information'
            and wp.organization_id                    = mp.organization_id
            and wp.organization_id                    = hou.organization_id
            and wp.organization_id                    = wjsi_row.organization_id
            and sysdate                               < nvl(hou.date_to, sysdate+1);

        validateProjectTask(line.rowid, l_msg);
        validateSubinvLocator(line.rowid, l_msg);

        -- restore the original org context
        if ( l_orginalOrgContext <> -1 ) then
          fnd_client_info.set_org_context(to_char(l_orginalOrgContext));
        end if;

        estimateLeadTime(line.rowid, l_msg);
        deriveScheduleDate(line.rowid, l_msg) ; /* 6117094 */

        validateLotNumber(line.rowid, l_msg);
        validateClassCode(line.rowid, l_msg);
        validateBOMRevision(line.rowid, l_msg);
        validateRoutingRevision(line.rowid, l_msg);
        validateStartQuantity(line.rowid, l_msg);
        validateOvercompletion(line.rowid, l_msg);
        --Bug 5210075:Validate status type should be called always irrespective of
        --validation level
        validateStatusType(line.rowid, l_msg);
        if ( p_validationLevel not in (wip_constants.mrp, wip_constants.ato) ) then
          --Bug 5210075:Call to procedure validatestatustype is commented out.
          --validateStatusType(line.rowid, l_msg);
          validateBuildSequence(line.rowid, l_msg);
          validateEndItemUnitNumber(line.rowid, l_msg);
          validateDailyProductionRate(line.rowid, l_msg);
          validateRepScheduleDates(line.rowid, l_msg);
        end if;

      exception
      when line_validation_error then
        if (l_logLevel <= wip_constants.trace_logging) then
          wip_logger.log('Validation Error happened on interface_id ' || line.interface_id || ': ' || l_msg,
                         l_retStatus);
        end if;
      end;

     update wip_job_schedule_interface
         set project_id = wjsi_row.project_id,
             task_id  = wjsi_row.task_id,
             status_type = wjsi_row.status_type,
             class_code = wjsi_row.class_code,
             overcompletion_tolerance_type = wjsi_row.overcompletion_tolerance_type,
             overcompletion_tolerance_value = wjsi_row.overcompletion_tolerance_value,
             first_unit_start_date = to_date(to_char(wjsi_row.first_unit_start_date,
                                       wip_constants.dt_nosec_fmt), wip_constants.dt_nosec_fmt),
             last_unit_start_date = to_date(to_char(wjsi_row.last_unit_start_date,
                                      wip_constants.dt_nosec_fmt), wip_constants.dt_nosec_fmt),
             first_unit_completion_date = to_date(to_char(wjsi_row.first_unit_completion_date,
                                            wip_constants.dt_nosec_fmt), wip_constants.dt_nosec_fmt),
             last_unit_completion_date = to_date(to_char(wjsi_row.last_unit_completion_date,
                                           wip_constants.dt_nosec_fmt), wip_constants.dt_nosec_fmt),
             build_sequence = wjsi_row.build_sequence,
             bom_revision = wjsi_row.bom_revision,
             routing_revision = wjsi_row.routing_revision,
             bom_revision_date = to_date(to_char(wjsi_row.bom_revision_date,
                                   wip_constants.dt_nosec_fmt), wip_constants.dt_nosec_fmt),
             routing_revision_date = to_date(to_char(wjsi_row.routing_revision_date,
                                       wip_constants.dt_nosec_fmt), wip_constants.dt_nosec_fmt),
             due_date = to_date(to_char(wjsi_row.due_date,
                          wip_constants.dt_nosec_fmt), wip_constants.dt_nosec_fmt),
             requested_start_date = to_date(to_char(wjsi_row.requested_start_date,
                                      wip_constants.dt_nosec_fmt), wip_constants.dt_nosec_fmt),
             lot_number = wjsi_row.lot_number,
             completion_subinventory = wjsi_row.completion_subinventory,
             completion_locator_id = wjsi_row.completion_locator_id,
             scheduling_method = wjsi_row.scheduling_method,
             end_item_unit_number = wjsi_row.end_item_unit_number
       where rowid = line.rowid;
    end loop;


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
  end lineValidateMLHeader;


  procedure setup(p_rowid in rowid) is
    l_primaryItemID number;
  begin
    select *
      into wjsi_row
      from wip_job_schedule_interface
     where rowid = p_rowid;

    if ( wjsi_row.load_type = wip_constants.resched_job ) then
      select we.wip_entity_name,
             wdj.status_type,
             we.entity_type,
             wdj.job_type,
             wdj.start_quantity,
             wdj.quantity_completed,
             wdj.firm_planned_flag,
             wdj.primary_item_id,
             wdj.bom_reference_id,
             wdj.routing_reference_id,
             wdj.line_id,
             wdj.schedule_group_id,
             wdj.scheduled_completion_date,
             wdj.project_id,
             wdj.task_id,
             wdj.overcompletion_tolerance_type,
             wdj.overcompletion_tolerance_value,
             wdj.completion_subinventory,
             wdj.completion_locator_id,
             wdj.build_sequence
        into wdj_row.wip_entity_name,
             wdj_row.status_type,
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
             wdj_row.overcompletion_tolerance_type,
             wdj_row.overcompletion_tolerance_value,
             wdj_row.completion_subinventory,
             wdj_row.completion_locator_id,
             wdj_row.build_sequence
        from wip_discrete_jobs wdj,
             wip_entities we
       where wdj.wip_entity_id = wjsi_row.wip_entity_id
         and we.wip_entity_id = wdj.wip_entity_id;

      l_primaryItemID := wdj_row.primary_item_id;
    else
      l_primaryItemID := wjsi_row.primary_item_id;
    end if;

     if ( l_primaryItemID is not null ) then
       select inventory_item_id,
              pick_components_flag,
              build_in_wip_flag,
              eng_item_flag,
              inventory_asset_flag,
              restrict_subinventories_code,
              restrict_locators_code,
              location_control_code,
              fixed_lead_time,
              variable_lead_time
         into primary_item_row.inventory_item_id,
              primary_item_row.pick_components_flag,
              primary_item_row.build_in_wip_flag,
              primary_item_row.eng_item_flag,
              primary_item_row.inventory_asset_flag,
              primary_item_row.restrict_subinventories_code,
              primary_item_row.restrict_locators_code,
              primary_item_row.location_control_code,
              primary_item_row.fixed_lead_time,
              primary_item_row.variable_lead_time
         from mtl_system_items
        where inventory_item_id = l_primaryItemID
          and organization_id = wjsi_row.organization_id;
     end if;
  end setup;


  procedure estimateLeadTime(p_rowid    in rowid,
                             x_errorMsg out nocopy varchar2) is
    l_schedDir number;
    l_rtgCount number;
    l_qty number;
    l_msg varchar2(30);
  begin
    if ( wjsi_row.load_type = wip_constants.create_sched ) then
      if(wjsi_row.first_unit_start_date is null) then
        if(wjsi_row.last_unit_start_date is not null) then
          l_schedDir := wip_constants.lusd;
        elsif(wjsi_row.first_unit_completion_date is not null) then
          l_schedDir := wip_constants.fucd;
        else
          l_schedDir := wip_constants.lucd;
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
                                       x_sched_dir   => l_schedDir,
                                       x_est_date    => wjsi_row.first_unit_start_date);
        if(wjsi_row.first_unit_start_date is null) then
          l_msg := 'WIP_ML_EST_LEADTIME';
          raise fnd_api.g_exc_unexpected_error;
        end if;
      end if;
    else
      if(wjsi_row.load_type = wip_constants.create_ns_job and wjsi_row.routing_reference_id is not null) then
        select count(*)
          into l_rtgCount
          from bom_operational_routings
         where assembly_item_id = wjsi_row.routing_reference_id
           and organization_id = wjsi_row.organization_id
           and nvl(alternate_routing_designator, '@@@') =
               nvl(wjsi_row.alternate_routing_designator, '@@@')
           and nvl(cfm_routing_flag, 2) = 2;
        l_qty := wjsi_row.start_quantity;
      elsif(wjsi_row.load_type = wip_constants.create_job) then
        select count(*)
          into l_rtgCount
          from bom_operational_routings
         where assembly_item_id = wjsi_row.primary_item_id
           and organization_id = wjsi_row.organization_id
           and nvl(alternate_routing_designator, '@@@') =
               nvl(wjsi_row.alternate_routing_designator, '@@@')
           and nvl(cfm_routing_flag, 2) = 2;
        l_qty := wjsi_row.start_quantity;
      elsif(wjsi_row.load_type = wip_constants.resched_job) then

        /* Modified for Bug 9286094. Modified logic to default scheduling method. */
        if ( nvl(wjsi_row.allow_explosion, 'Y') in ('n', 'N') ) then
          select count(*)
          into l_rtgCount
          from wip_operations
          where wip_entity_id = wjsi_row.wip_entity_id;
        else
          select count(*)
          into l_rtgCount
          from bom_operational_routings
          where organization_id = wjsi_row.organization_id
          and assembly_item_id = nvl(wjsi_row.routing_reference_id,wjsi_row.primary_item_id)
          and nvl(alternate_routing_designator, '@@@^@@@') = nvl(wjsi_row.alternate_routing_designator, '@@@^@@@')
          and nvl(cfm_routing_flag, 2) = 2;
        end if;
        l_qty := nvl(wjsi_row.start_quantity, wdj_row.start_quantity);
      end if;
      --if no routing exists, update the scheduling method appropriately
      if(wjsi_row.scheduling_method = wip_constants.routing and l_rtgCount = 0) then
        if(wjsi_row.first_unit_start_date is not null and
           wjsi_row.last_unit_completion_date is not null) then
          wjsi_row.scheduling_method := wip_constants.ml_manual;
        else
          wjsi_row.scheduling_method := wip_constants.leadtime;
        end if;
      end if;
      if(wjsi_row.first_unit_start_date is null and
          wjsi_row.last_unit_completion_date is not null and
          wjsi_row.scheduling_method = wip_constants.leadtime) then
        /* Estimate Start Date */
        wip_calendar.estimate_leadtime(x_org_id      => wjsi_row.organization_id,
                                       x_fixed_lead  => primary_item_row.fixed_lead_time,
                                       x_var_lead    => primary_item_row.variable_lead_time,
                                       x_quantity    => l_qty,
                                       x_proc_days   => 0,
                                       x_entity_type => wip_constants.discrete,
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
                                       x_entity_type => wip_constants.discrete,
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
      -- Added for Bug 9385806.
      elsif (wjsi_row.last_unit_completion_date is null and
             wjsi_row.first_unit_start_date is null and
             wjsi_row.scheduling_method = wip_constants.leadtime) then
        if wjsi_row.load_type = wip_constants.resched_job then

            select wdj.scheduled_start_date into wjsi_row.first_unit_start_date
            from wip_discrete_jobs wdj
            where wdj.wip_entity_id = wjsi_row.wip_entity_id;

            /* Estimate Completion Date */
            wip_calendar.estimate_leadtime(x_org_id      => wjsi_row.organization_id,
                                           x_fixed_lead  => primary_item_row.fixed_lead_time,
                                           x_var_lead    => primary_item_row.variable_lead_time,
                                           x_quantity    => l_qty,
                                           x_proc_days   => 0,
                                           x_entity_type => wip_constants.discrete,
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
        else
              l_msg := 'WIP_ML_SCHEDULE_DATES';
              raise fnd_api.g_exc_unexpected_error;
        end if;
      end if;
    end if;
  exception
  when others then
    fnd_message.set_name('WIP', l_msg);
    x_errorMsg := fnd_message.get;
    setInterfaceError(p_rowid, wjsi_row.interface_id, x_errorMsg, validationError);
    raise line_validation_error;
  end estimateLeadTime;


  procedure validateProjectTask(p_rowid in rowid,
                                x_errorMsg out nocopy varchar2) is
    l_dummy number;
    l_projectID number;
    l_errCode varchar2(80);
    l_result varchar2(1);
  begin
    -- fix MOAC, set id so project view works
    fnd_profile.put('MFG_ORGANIZATION_ID',wjsi_row.organization_id);
    if ( wjsi_row.load_type <> wip_constants.create_sched ) then
      begin
      if ( wjsi_row.project_number is not null and wjsi_row.project_id is null) then
        -- Bug 4890514. Performance Fix
        -- saugupta 25th-May-2006
        select mpv.project_id --if the project has tasks, this query returns multiple rows
          into wjsi_row.project_id
          from pjm_projects_v mpv,
               pjm_project_parameters ppp
         where mpv.project_number = wjsi_row.project_number
           and mpv.project_id = ppp.project_id
           and ppp.organization_id = wjsi_row.organization_id;
      end if;
      exception
      when others then
        fnd_message.set_name('WIP', 'WIP_ML_FIELD_INVALID');
        fnd_message.set_token('COLUMN', 'PROJECT_NUMBER', false);
        x_errorMsg := fnd_message.get;
        setInterfaceError(p_rowid, wjsi_row.interface_id, x_errorMsg, validationError);
        raise line_validation_error;
      end;
    end if;

    if ( wjsi_row.load_type <> wip_constants.create_sched and
         wjsi_row.project_id is not null) then
      begin
        -- Bug 4890514. Performance Fix
        -- saugupta 25th-May-2006
      select mpv.project_id --this query will return multiple rows if the project has tasks
         into l_dummy
         from pjm_projects_v mpv,
              pjm_project_parameters ppp,
              mtl_parameters mp
        where mpv.project_id = ppp.project_id
          and mpv.project_id = wjsi_row.project_id
          and ppp.organization_id = wjsi_row.organization_id
          and ppp.organization_id = mp.organization_id
          and nvl(mp.project_reference_enabled, 2) = wip_constants.yes;
      exception
      when others then
        fnd_message.set_name('WIP', 'WIP_ML_PROJECT_ID');
        x_errorMsg := fnd_message.get;
        setInterfaceError(p_rowid, wjsi_row.interface_id, x_errorMsg, validationError);
        raise line_validation_error;
      end;
    end if;

    if ( wjsi_row.load_type <> wip_constants.create_sched and
         wjsi_row.task_number is not null and wjsi_row.task_id is null) then
      begin
        if ( wjsi_row.load_type = wip_constants.resched_job ) then
          select pa.task_id
            into wjsi_row.task_id
            from pa_tasks_expend_v pa,
                 wip_discrete_jobs wdj
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
      exception
      when others then
        fnd_message.set_name('WIP', 'WIP_ML_FIELD_INVALID');
        fnd_message.set_token('COLUMN', 'TASK_NUMBER', false);
        x_errorMsg := fnd_message.get;
        setInterfaceError(p_rowid, wjsi_row.interface_id, x_errorMsg, validationError);
        raise line_validation_error;
      end;
    end if;

    if ( wjsi_row.task_id is not null ) then
      if ( wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_ns_job) ) then
        l_projectID := wjsi_row.project_id;
      else
        l_projectID := nvl(wjsi_row.project_id, wdj_row.project_id);
      end if;
      begin

        if (PJM_PROJECT.val_task_idtonum(l_projectID, wjsi_row.task_id)
            is null) then
          raise fnd_api.g_exc_unexpected_error;
        end if;

      exception
      when others then
        fnd_message.set_name('WIP', 'WIP_ML_TASK_ID');
        x_errorMsg := fnd_message.get;
        setInterfaceError(p_rowid, wjsi_row.interface_id, x_errorMsg, validationError);
        raise line_validation_error;
      end;
    end if;

    if ( wjsi_row.load_type = wip_constants.create_job and
         wjsi_row.project_id is not null ) then
      l_result := PJM_PROJECT.VALIDATE_PROJ_REFERENCES
          (x_inventory_org_id  => wjsi_row.organization_id,
           x_project_id        => wjsi_row.project_id,
           x_task_id           => wjsi_row.task_id,
           x_date1             => wjsi_row.first_unit_start_date,
           x_date2             => wjsi_row.last_unit_completion_date,
           x_calling_function  => 'WILMLX',
           x_error_code        => l_errCode
          );
      if ( l_result <> PJM_PROJECT.G_VALIDATE_SUCCESS ) then
        wip_utilities.get_message_stack(p_delete_stack => 'T',
                                        p_msg => x_errorMsg);
        if ( l_result = PJM_PROJECT.G_VALIDATE_FAILURE ) then
          setInterfaceError(p_rowid, wjsi_row.interface_id, x_errorMsg, validationError);
          raise line_validation_error;
        else
          setInterfaceError(p_rowid, wjsi_row.interface_id, x_errorMsg, validationWarning);
        end if;
      end if;
    end if;
  end validateProjectTask;


  procedure validateClassCode(p_rowid    in rowid,
                              x_errorMsg out nocopy varchar2) is
    l_dummy NUMBER;
    l_errMsg1 VARCHAR2(30);
    l_errMsg2 VARCHAR2(30);
    l_errClass1 VARCHAR2(30);
    l_errClass2 VARCHAR2(30);
  begin
    if ( wjsi_row.class_code is not null and
         wjsi_row.load_type in (wip_constants.resched_job,
                                wip_constants.create_sched)) then
      fnd_message.set_name('WIP', 'WIP_ML_FIELD_IGNORED');
      fnd_message.set_token('COLUMN', 'CLASS_CODE', false);
      setInterfaceError(p_rowid, wjsi_row.interface_id, fnd_message.get, validationWarning);
    end if;

    -- default the class code
    if ( wjsi_row.class_code is null ) then
      if ( wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_ns_job) ) then
        wjsi_row.class_code := wip_common.default_acc_class(
                                x_org_id      => wjsi_row.organization_id,
                                x_item_id     => wjsi_row.primary_item_id,
                                x_entity_type => wip_constants.discrete,
                                x_project_id  => wjsi_row.project_id,
                                x_err_mesg_1  => l_errMsg1,
                                x_err_mesg_2  => l_errMsg2,
                                x_err_class_1 => l_errClass1,
                                x_err_class_2 => l_errClass2);
        if ( l_errMsg1 is not null) then
          fnd_message.set_name('WIP', l_errMsg1);
          fnd_message.set_token('class_code', l_errClass1, false);
          x_errorMsg := fnd_message.get;
          setInterfaceError(p_rowid, wjsi_row.interface_id, x_errorMsg, validationError);
          raise line_validation_error;
        end if ;
        if (l_errMsg2 is not null) then
          fnd_message.set_name('WIP', l_errMsg2);
          fnd_message.set_token('class_code', l_errClass2, false);
          x_errorMsg := fnd_message.get;
          setInterfaceError(p_rowid, wjsi_row.interface_id, x_errorMsg, validationError);
          raise line_validation_error;
        end if ;
      elsif ( wjsi_row.load_type = wip_constants.resched_job ) then
        select wdj.class_code
          into wjsi_row.class_code
          from wip_discrete_jobs wdj
         where wdj.wip_entity_id = wjsi_row.wip_entity_id
           and wdj.organization_id = wjsi_row.organization_id;
      end if;
    end if;

    begin
    if ( wjsi_row.load_type = wip_constants.create_job) then
      if(wjsi_row.project_id is null) then
        select 1 into l_dummy
        from dual
        where exists(select 1
                       from cst_cg_wip_acct_classes_v
                      where class_code = wjsi_row.class_code
                        and organization_id = wjsi_row.organization_id
                        and class_type = wip_constants.discrete);
      else
        select 1 into l_dummy
        from dual
        where exists(select 1
                       from cst_cg_wip_acct_classes_v ccwac,
                            mtl_parameters mp
                      where ccwac.class_code = wjsi_row.class_code
                        and ccwac.organization_id = wjsi_row.organization_id
                        and ccwac.class_type = wip_constants.discrete
                        and mp.organization_id = wjsi_row.organization_id
                        and (   mp.primary_cost_method = wip_constants.cost_std
                             or ccwac.cost_group_id = (select costing_group_id
                                                          from mrp_project_parameters mpp
                                                         where organization_id = wjsi_row.organization_id
                                                           and mpp.project_id = wjsi_row.project_id)));
      end if;
    elsif ( wjsi_row.load_type = wip_constants.create_ns_job ) then
      select 1 into l_dummy
      from dual
      where exists(select 1
                     from wip_non_standard_classes_val_v
                    where class_code = wjsi_row.class_code
                      and organization_id = wjsi_row.organization_id);
    end if;
    exception
    when others then
      fnd_message.set_name('WIP', 'WIP_ML_CLASS_CODE');
      x_errorMsg := fnd_message.get;
      setInterfaceError(p_rowid, wjsi_row.interface_id, x_errorMsg, validationError);
      raise line_validation_error;
    end;
  end validateClassCode;

  procedure validateBOMRevision(p_rowid    in rowid,
                                x_errorMsg out nocopy varchar2) is
    l_bomItemID number;
  begin
    if(wjsi_row.load_type = wip_constants.create_ns_job) then
      l_bomItemID := wjsi_row.bom_reference_id;
    else
      l_bomItemID := wjsi_row.primary_item_id;
    end if;

    if(wjsi_row.load_type in (wip_constants.create_job,
                              wip_constants.create_sched,
                              wip_constants.create_ns_job) ) then
     --Bug 5464449: Default revision date from wdj
 IF wjsi_row.load_type = wip_constants.RESCHED_JOB and
        wjsi_row.wip_entity_id is not null and
        wjsi_row.bom_revision_date IS NULL THEN
       BEGIN
       select bom_revision_date
              into wjsi_row.bom_revision_date
       from  wip_discrete_jobs
       where wip_entity_id = wjsi_row.wip_entity_id;
       EXCEPTION
           WHEN OTHERS THEN
              wjsi_row.bom_revision_date := NULL;
       END;
 END IF;
 --Bug 5464449: End of changes.
      wip_revisions.bom_revision(
                        p_organization_id => wjsi_row.organization_id,
                        p_item_id => l_bomItemID,
                        p_revision => wjsi_row.bom_revision,
                        p_revision_date => wjsi_row.bom_revision_date,
                        p_start_date => greatest(nvl(wjsi_row.first_unit_start_date, wjsi_row.last_unit_completion_date), sysdate));
    end if;
  exception
  when others then
    fnd_message.set_name('WIP', 'WIP_ML_BOM_REVISION');
    x_errorMsg := fnd_message.get;
    setInterfaceError(p_rowid, wjsi_row.interface_id, x_errorMsg, validationError);
    raise line_validation_error;
  end validateBOMRevision;


  procedure validateRoutingRevision(p_rowid    in rowid,
                                    x_errorMsg out nocopy varchar2) is
    l_rtgItemID number;
    l_count number;
    l_ret_status varchar2(20);

  begin
    if(wjsi_row.load_type = wip_constants.create_ns_job) then
      l_rtgItemID := wjsi_row.routing_reference_id;
    else
      l_rtgItemID := wjsi_row.primary_item_id;
    end if;

    if(wjsi_row.load_type in (wip_constants.create_job,
                              wip_constants.create_sched,
                              wip_constants.create_ns_job,
			      wip_constants.RESCHED_JOB --5194524
			      )
			       ) then

       wip_logger.log('ENTERED into Validate routing revision',l_ret_status);

      select count(*)
        into l_count
        from bom_operational_routings
       where assembly_item_id = decode(wjsi_row.load_type,
                                       wip_constants.create_ns_job, wjsi_row.routing_reference_id,
                                       wjsi_row.primary_item_id
				       )
         and organization_id = wjsi_row.organization_id
         and nvl(alternate_routing_designator, '@@@') =
             nvl(wjsi_row.alternate_routing_designator, '@@@');
      --Bug 	5464449: Default revision date from wdj
       IF wjsi_row.load_type = wip_constants.RESCHED_JOB and
        wjsi_row.wip_entity_id is not null and
        wjsi_row.routing_revision_date IS NULL THEN
       BEGIN
       select routing_revision_date
              into wjsi_row.routing_revision_date
       from  wip_discrete_jobs
       where wip_entity_id = wjsi_row.wip_entity_id;
       EXCEPTION
           WHEN OTHERS THEN
              wjsi_row.routing_revision_date := NULL;
       END;
       END IF;
      --Bug 5464449:End of changes.
      if(l_count > 0) then
        wip_logger.log('calling wip_revisions.routing_revision',l_ret_status);
	--l_start_date := greatest(nvl(wjsi_row.first_unit_start_date, wjsi_row.last_unit_completion_date), sysdate);

        wip_revisions.routing_revision(p_organization_id => wjsi_row.organization_id,
                                       p_item_id => l_rtgItemID,
                                       p_revision => wjsi_row.routing_revision,
                                       p_revision_date => wjsi_row.routing_revision_date,
				       --bugifx 5364387 added outer nvl
                                       p_start_date => nvl(greatest(nvl(wjsi_row.first_unit_start_date, wjsi_row.last_unit_completion_date), sysdate),sysdate)

				       );
      end if;
    end if;
  exception
  when others then
    fnd_message.set_name('WIP', 'WIP_ML_ROUTING_REVISION');
    x_errorMsg := fnd_message.get;
    setInterfaceError(p_rowid, wjsi_row.interface_id, x_errorMsg, validationError);
    raise line_validation_error;
  end validateRoutingRevision;


  procedure validateStartQuantity(p_rowid    in rowid,
                                  x_errorMsg out nocopy varchar2) is
    l_minOp number;
    l_queueQty number;
    l_scheduledQty number;
  begin

    if ( wjsi_row.load_type = wip_constants.resched_job and
         wjsi_row.start_quantity <> wdj_row.start_quantity ) then

      if ( wjsi_row.start_quantity < wdj_row.quantity_completed ) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    --  Fix for 5999220 Added if condition by mraman
     if ( wdj_row.status_type <> wip_constants.unreleased ) then
      select nvl(min(operation_seq_num), fnd_api.g_miss_num)
        into l_minOp
        from wip_operations
       where organization_id = wjsi_row.organization_id
         and wip_entity_id = wjsi_row.wip_entity_id
         and nvl(repetitive_schedule_id, -1) = nvl(wjsi_row.repetitive_schedule_id, -1);

       if ( l_minOp <> fnd_api.g_miss_num ) then
         select quantity_in_queue,
                scheduled_quantity
           into l_queueQty,
                l_scheduledQty
           from wip_operations
          where organization_id = wjsi_row.organization_id
            and wip_entity_id = wjsi_row.wip_entity_id
            and nvl(repetitive_schedule_id, -1) = nvl(wjsi_row.repetitive_schedule_id, -1)
            and operation_seq_num = l_minOp;

         if ( l_queueQty < l_scheduledQty - wjsi_row.start_quantity ) then
           raise fnd_api.g_exc_unexpected_error;
         end if; -- end if  (l_queueQty < l_scheduledQty - wjsi_row.start_quantity )
	end if ; -- end if (l_minOp <> fnd_api.g_miss_num )
       end if; -- end if ( wdj_row.status_type <> wip_constants.unreleased )

      /* bug 5350660. Show warning if job is already pick released */
      if ( wip_picking_pub.is_job_pick_released(wjsi_row.wip_entity_id,
                                                wjsi_row.repetitive_schedule_id,
                                                wjsi_row.organization_id)) then
	 fnd_message.set_name('WIP', 'WIP_QTY_REQ_CHANGE_WARNING');
         setInterfaceError(p_rowid, wjsi_row.interface_id, substr(fnd_message.get, 1, 500), validationWarning);
      end if;
    end if;
  exception
  when others then
    fnd_message.set_name('WIP', 'WIP_LOWER_JOB_QTY');
    x_errorMsg := fnd_message.get;
    setInterfaceError(p_rowid, wjsi_row.interface_id, x_errorMsg, validationError);
    raise line_validation_error;
  end validateStartQuantity;


  procedure validateStatusType(p_rowid    in rowid,
                               x_errorMsg out nocopy varchar2) is
    l_qtyReserved number;
    l_propagate_job_change_to_po number;
    l_msg varchar2(30);
    l_retStatus varchar2(1);
    l_old_status number := 0 ;  /* Fix for Bug#4406036 */

    cursor check_so_link is
      select nvl(sum(wr.primary_quantity), 0)
        from wip_reservations_v wr
       where wr.wip_entity_id = wjsi_row.wip_entity_id
         and wr.inventory_item_id = nvl(wjsi_row.primary_item_id, wdj_row.primary_item_id)
         and wr.organization_id = wjsi_row.organization_id;
  begin
    if ( wjsi_row.load_type <> wip_constants.resched_job ) then
      return;
    end if;

    /* Fix for Bug#4406036. Added following sql statement to get existing
       status of job. Warning is applicable only if current status of job
       is anything other than complete or cancelled
    */
         begin
            select status_type
            into   l_old_status
            from   wip_discrete_jobs
            where  wip_entity_id = wjsi_row.wip_entity_id ;
         end ;

    if ( wjsi_row.status_type in (wip_constants.cancelled,
                                  wip_constants.comp_chrg)
	and (l_old_status not in (wip_constants.cancelled, wip_constants.comp_chrg,
                                  wip_constants.comp_nochrg))) then
      open check_so_link;
      fetch check_so_link into l_qtyReserved;
      close check_so_link;

      if ( l_qtyReserved > 0 ) then
        l_msg := 'WIP_CANT_CANCEL_SO';
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;



    if ( wjsi_row.status_type in (wip_constants.cancelled,
                                  wip_constants.comp_chrg,
                                  wip_constants.comp_nochrg)
	and (l_old_status not in (wip_constants.cancelled, wip_constants.comp_chrg,
                                  wip_constants.comp_nochrg))) then
      if ( wip_osp.po_req_exists(wjsi_row.wip_entity_id,
                                 null,
                                 wjsi_row.organization_id,
                                 null,
                                 wip_constants.discrete) = true ) then
        if ( po_code_release_grp.Current_Release >=
             po_code_release_grp.PRC_11i_Family_Pack_J ) then
          select propagate_job_change_to_po
            into l_propagate_job_change_to_po
            from wip_parameters wp
           where organization_id = wjsi_row.organization_id;

          if ( l_propagate_job_change_to_po = wip_constants.yes and
               wjsi_row.status_type in (wip_constants.cancelled,
                                        wip_constants.comp_nochrg) ) then
            -- cancel PO/requisition associated to the job if cancel or
            -- complete-no-charge
            wip_osp.cancelPOReq(p_job_id        => wjsi_row.wip_entity_id,
                                p_org_id        => wjsi_row.organization_id,
                                x_return_status => l_retStatus);
            if ( l_retStatus <> fnd_api.g_ret_sts_success ) then
              po_warning_flag := WIP_CONSTANTS.YES;
              setInterfaceError(p_rowid, wjsi_row.interface_id, fnd_message.get, validationWarning);
            end if;
          else
            -- propagate_job_change_to_po is manual or job status is 'Complete'
            po_warning_flag := WIP_CONSTANTS.YES;
            fnd_message.set_name('WIP', 'WIP_CANCEL_JOB/SCHED_OPEN_PO');
            setInterfaceError(p_rowid, wjsi_row.interface_id, fnd_message.get, validationWarning);
          end if;
        else
          -- customer does not have PO patchset J onward, so behave the the old way
          po_warning_flag := WIP_CONSTANTS.YES;
          fnd_message.set_name('WIP', 'WIP_CANCEL_JOB/SCHED_OPEN_PO');
          setInterfaceError(p_rowid, wjsi_row.interface_id, fnd_message.get, validationWarning);
        end if;
      end if; -- po/requisiton exist
    end if;

    -- Bug 3032515 - Added validation to prevent updation to completed/
    -- cancelled/completed-no charges/closed jobs through planner module
    -- for which source code is populated as MSC
    if ( wjsi_row.source_code = 'MSC' and
         wdj_row.status_type in (wip_constants.comp_chrg, wip_constants.comp_nochrg,
                                 wip_constants.cancelled, wip_constants.closed) ) then
      l_msg := 'WIP_CANT_UPDATE_JOB';
      raise fnd_api.g_exc_unexpected_error;
    end if;

    -- bug# 3436646: job cannot be changed to unreleased if it's been pick released
    if ( wjsi_row.status_type = WIP_CONSTANTS.UNRELEASED and
         wdj_row.status_type <> WIP_CONSTANTS.UNRELEASED and
         WIP_PICKING_PUB.Is_Job_Pick_Released(
                     p_wip_entity_id =>  wjsi_row.wip_entity_id,
                     p_org_id => wjsi_row.organization_id) ) then
      l_msg := 'WIP_UNRLS_JOB/SCHED';
      raise fnd_api.g_exc_unexpected_error;
    end if;
  exception
  when others then
    fnd_message.set_name('WIP', l_msg);
    x_errorMsg := fnd_message.get;
    setInterfaceError(p_rowid, wjsi_row.interface_id, x_errorMsg, validationError);
    raise line_validation_error;
  end validateStatusType;


  procedure validateBuildSequence(p_rowid    in rowid,
                                  x_errorMsg out nocopy varchar2) is
    l_retval boolean;
    l_buildSeq number;
  begin
    if ( wjsi_row.load_type = wip_constants.create_sched ) then
      return;
    end if;

    if ( wjsi_row.build_sequence is null ) then
      if ( wjsi_row.load_type = wip_constants.resched_job ) then
        l_buildSeq := wdj_row.build_sequence;
      else
        l_buildSeq := null;
      end if;

      wjsi_row.build_sequence := wip_jsi_hooks.get_default_build_sequence(wjsi_row.interface_id,
                                                                          l_buildSeq);
    end if;

    if ( wjsi_row.build_sequence is not null ) then
      l_retval := wip_validate.build_sequence(
                      p_build_sequence => wjsi_row.build_sequence,
                      p_wip_entity_id => wjsi_row.wip_entity_id,
                      p_organization_id => wjsi_row.organization_id,
                      p_line_id => nvl(wjsi_row.line_id, wdj_row.line_id),
                      p_schedule_group_id => nvl(wjsi_row.schedule_group_id, wdj_row.schedule_group_id) );
      if( not l_retval ) then
        fnd_message.set_name('WIP', 'WIP_ML_BUILD_SEQUENCE');
        x_errorMsg := fnd_message.get;
        setInterfaceError(p_rowid, wjsi_row.interface_id, x_errorMsg, validationError);
        raise line_validation_error;
      end if;
    end if;
  end validateBuildSequence;


  procedure validateEndItemUnitNumber(p_rowid    in rowid,
                                      x_errorMsg out nocopy varchar2) is
    l_bomItemID number;
    l_isUnitEffective boolean;
    l_dummy number;
    l_msg varchar2(30);
  begin
    if ( wjsi_row.load_type = wip_constants.create_ns_job) then
      l_bomItemID := wjsi_row.bom_reference_id;
    else
      l_bomItemID := wjsi_row.primary_item_id;
    end if;
    l_isUnitEffective := l_bomItemID is not null and
                         pjm_unit_eff.enabled = 'Y' and
                         pjm_unit_eff.unit_effective_item(l_bomItemID,
                                                          wjsi_row.organization_id) = 'Y';

    if( l_isUnitEffective and wjsi_row.end_item_unit_number is not null) then
      begin
        select 1
        into l_dummy
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
        x_errorMsg := fnd_message.get;
        setInterfaceError(p_rowid, wjsi_row.interface_id, x_errorMsg, validationError);
        raise line_validation_error;
      end;
    end if;

    -- You cannot create a repetitive schedule for a unit effective assembly.
    if( l_isUnitEffective and wjsi_row.load_type = wip_constants.create_sched ) then
      l_msg := 'WIP_ML_NO_UNIT_EFF_SCHED';
      raise fnd_api.g_exc_unexpected_error;
    end if;

    -- It is an error to provide unit number for non-unit effective assemblies.
    if (not l_isUnitEffective and wjsi_row.end_item_unit_number is not null) then
      l_msg := 'WIP_ML_UNIT_NUM_MEANINGLESS';
      raise fnd_api.g_exc_unexpected_error;
    end if;

    if (wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_ns_job)) then
      -- Unit number is required for unit effective assemblies.
      if( l_isUnitEffective and wjsi_row.end_item_unit_number is null) then
        fnd_message.set_name('PJM', 'UEFF-UNIT NUMBER REQUIRED');
        x_errorMsg := fnd_message.get;
        setInterfaceError(p_rowid, wjsi_row.interface_id, x_errorMsg, validationError);
        raise line_validation_error;
      end if;
    end if;

    --if request is for reschedule, keep as is for all cases except when job_status is unreleased
    if ( wjsi_row.load_type = wip_constants.resched_job ) then
      if ( wjsi_row.end_item_unit_number is null) then
        begin
          select wdj.end_item_unit_number
            into wjsi_row.end_item_unit_number
            from wip_discrete_jobs wdj
           where wdj.wip_entity_id = wjsi_row.wip_entity_id;
        exception
        when others then
          fnd_message.set_name('PJM', 'UEFF-UNIT NUMBER INVALID');
          x_errorMsg := fnd_message.get;
          setInterfaceError(p_rowid, wjsi_row.interface_id, x_errorMsg, validationError);
          raise line_validation_error;
        end;
      end if;

      if ( wjsi_row.status_type = wip_constants.unreleased and
           wjsi_row.end_item_unit_number is not null ) then
        -- bug#2719927, bom revision code/reexplosion is based on bom_reference_id
        select primary_item_id
          into wjsi_row.bom_reference_id
          from wip_discrete_jobs
         where wip_entity_id = wjsi_row.wip_entity_id;
      end if;

      if ( wjsi_row.status_type <> wip_constants.unreleased and
           wjsi_row.end_item_unit_number is not null ) then
        fnd_message.set_name('WIP', 'END_ITEM_UNIT_NUMBER');
        setInterfaceError(p_rowid, wjsi_row.interface_id, x_errorMsg, validationWarning);
	-- Added by Renga Kannan
	-- Fixed for bug 5332672
	-- Added code to get the end unit item number from wip_discrete_jobs and populate
	-- to interface table

	begin
         select end_item_unit_number into wjsi_row.end_item_unit_number
                                 from wip_discrete_jobs
                                 where wip_entity_id =
                                   (select wip_entity_id
                                    from wip_job_schedule_interface
                                    where rowid = p_rowid
                                   );
       exception
          when others then
           FND_Message.set_name('PJM', 'UEFF-UNIT NUMBER INVALID') ;
           WIP_JSI_Utils.record_current_error ;
           raise fnd_api.g_exc_unexpected_error;
       end ;

       -- End of bug fix 5332672
      end if;
    end if;
  exception
  when fnd_api.g_exc_unexpected_error then
    fnd_message.set_name('WIP', l_msg);
    x_errorMsg := fnd_message.get;
    setInterfaceError(p_rowid, wjsi_row.interface_id, x_errorMsg, validationError);
    raise line_validation_error;
  end validateEndItemUnitNumber;


  procedure validateDailyProductionRate(p_rowid    in rowid,
                                        x_errorMsg out nocopy varchar2) is
    l_maxLineRate number;
  begin
    if( wjsi_row.load_type <> wip_constants.create_sched ) then
      return;
    end if;

    select daily_maximum_rate
      into l_maxLineRate
      from wip_lines_val_v
     where line_id = wjsi_row.line_id;

    if( l_maxLineRate < wjsi_row.daily_production_rate ) then
      fnd_message.set_name('WIP',  'WIP_PROD_RATE_WARNING');
      fnd_message.set_token('ENTITY1', l_maxLineRate);
      setInterfaceError(p_rowid, wjsi_row.interface_id, fnd_message.get, validationWarning);
    end if;
  end validateDailyProductionRate;


  procedure validateRepScheduleDates(p_rowid    in rowid,
                                     x_errorMsg out nocopy varchar2) is
    l_dateCount number := 0;
    l_lineCount number;
    l_rtgCount number;
  begin
    if ( wjsi_row.load_type <> wip_constants.create_sched ) then
      return;
    end if;

    if ( wjsi_row.first_unit_start_date is not null ) then
      l_dateCount := l_dateCount + 1;
    end if;

    if ( wjsi_row.last_unit_completion_date is not null ) then
      l_dateCount := l_dateCount + 1;
    end if;

    if ( wjsi_row.first_unit_completion_date is not null ) then
      l_dateCount := l_dateCount + 1;
    end if;

    if ( wjsi_row.last_unit_start_date is not null ) then
      l_dateCount := l_dateCount + 1;
    end if;

    if ( l_dateCount = 0 ) then
      --must provide at least one date for rep sched
      raise fnd_api.g_exc_unexpected_error;
    end if;

    if ( l_dateCount <> 1 ) then
      select count(*)
        into l_lineCount
        from wip_lines
       where organization_id = wjsi_row.organization_id
         and line_id = wjsi_row.line_id
         and line_schedule_type = 1; --fixed
      if( l_lineCount > 0 ) then
        --the line can not have a fixed lead time
        raise fnd_api.g_exc_unexpected_error;
      end if;

      select count(*)
        into l_rtgCount
        from bom_operational_routings bor,
             wip_repetitive_items wri
       where wri.line_id = wjsi_row.line_id
         and nvl(bor.cfm_routing_flag, 2) = 2 --ignore flow rtgs
         and wri.primary_item_id = wjsi_row.primary_item_id
         and wri.organization_id = wjsi_row.organization_id
         and nvl(bor.alternate_routing_designator,'@@@') =  nvl(wri.alternate_routing_designator, '@@@')
         and bor.organization_id = wri.organization_id
         and bor.assembly_item_id = wri.primary_item_id;
      if ( l_rtgCount > 0 ) then
        --the line can not have a routing
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    select count(*)
      into l_rtgCount
      from bom_operational_routings bor,
           wip_repetitive_items wri
     where wri.line_id = wjsi_row.line_id
       and nvl(bor.cfm_routing_flag,2) = 2 --ignore flow routings
       and wri.primary_item_id = wjsi_row.primary_item_id
       and wri.organization_id = wjsi_row.organization_id
       and nvl(bor.alternate_routing_designator,'@@@') = nvl(wri.alternate_routing_designator,'@@@')
       and bor.organization_id = wri.organization_id
       and bor.assembly_item_id = wri.primary_item_id;

    select count(*)
      into l_lineCount
      from wip_lines_val_v
     where organization_id = wjsi_row.organization_id
       and line_id = wjsi_row.line_id
       and line_schedule_type = 2;

    --providing exactly the first dates or the last dates is an error condition
    if( not (l_dateCount = 2 and
            ((wjsi_row.first_unit_start_date is not null and wjsi_row.first_unit_completion_date is not null) or
             (wjsi_row.last_unit_start_date is not null and wjsi_row.last_unit_completion_date is not null))) ) then
      if ( l_rtgCount = 0 and l_lineCount > 0 ) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    if ( l_lineCount > 0 and l_rtgCount = 0 ) then
    -- estimate schedule dates
      if ( wjsi_row.first_unit_start_date is null ) then
        -- Bug 4890514. Performance Fix
        -- saugupta 25th-May-2006
        /*
        select calendar_date
          into wjsi_row.first_unit_start_date
          from bom_calendar_dates bcd,
               mtl_parameters mp
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
        -- Bug 4890514. Performance Fix
        -- saugupta 25th-May-2006
        /*
        select calendar_date
          into wjsi_row.last_unit_start_date
          from bom_calendar_dates bcd,
               mtl_parameters mp
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
        INTO  wjsi_row.last_unit_start_date
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
        -- Bug 4890514. Performance Fix
        -- saugupta 25th-May-2006
        /*
        select calendar_date
          into wjsi_row.first_unit_completion_date
          from bom_calendar_dates bcd,
               mtl_parameters mp
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
        INTO  wjsi_row.first_unit_completion_date
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
        -- Bug 4890514. Performance Fix
        -- saugupta 25th-May-2006
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
                             and b2.exception_set_id = bcd.exception_set_id);
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
            and b2.calendar_date     = trunc(wjsi_row.first_unit_completion_date )
            and b2.calendar_code     = mp.calendar_code;
      end if;
    end if;
  exception
  when others then
    fnd_message.set_name('WIP', 'WIP_ML_REPETITIVE_DATES');
    x_errorMsg := fnd_message.get;
    setInterfaceError(p_rowid, wjsi_row.interface_id, x_errorMsg, validationError);
    raise line_validation_error;
  end validateRepScheduleDates;

  --
  -- This procedure is not called during validatoin phase. It must be called after the explosion
  -- so work order will be populated with job operations.
  --
  procedure defaultSerializationStartOp(p_rowid  in rowid,
                                        p_rtgVal in number) is
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
     where wjsi.rowid = p_rowid
       and wjsi.organization_id = wp.organization_id;

    if( l_startOp is not null or l_primaryItem is null ) then
      return;
    end if;

    if ( l_loadType in (wip_constants.create_job, wip_constants.create_ns_job) ) then
      if ( p_rtgVal is not null ) then
        update wip_discrete_jobs
           set serialization_start_op = p_rtgVal
         where wip_entity_id = l_wipID
           and exists (select 1
                         from mtl_system_items
                        where inventory_item_id = l_primaryItem
                          and organization_id = l_orgID
                          and serial_number_control_code = wip_constants.full_sn);

      elsif ( l_default = wip_constants.yes ) then
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
  end defaultSerializationStartOp;

  --
  -- Unlike other procedure, this one has to be called after the explosion. We can only validate op related
  -- after the explosion and the possible details loading.
  --
  procedure validateSerializationStartOp(p_rowid    in rowid,
                                         x_returnStatus out nocopy varchar2,
                                         x_errorMsg     out nocopy varchar2) is
    l_wipEntityID number;
    l_serialOp number;
    l_loadType number;
    l_interfaceID number;

    l_curOpSeq number;
    l_rtgExists boolean;
    l_opFound boolean;
    l_dummy number;

    cursor c_ops(p_wipEntityId number) is
      select operation_seq_num
        from wip_operations
       where wip_entity_id = p_wipEntityId;
  begin
    x_returnStatus := fnd_api.g_ret_sts_success;

    select wip_entity_id,
           serialization_start_op,
           load_type,
           interface_id
      into l_wipEntityID, l_serialOp, l_loadType, l_interfaceID
      from wip_job_schedule_interface wjsi
     where wjsi.rowid = p_rowid;

    if ( l_serialOp is null ) then
      if ( wjsi_row.load_type = wip_constants.resched_job ) then
        --in this case, we may need to clear the serialization op if the routing was re-exploded
        update wip_discrete_jobs wdj
           set serialization_start_op = null
         where wip_entity_id = l_wipEntityID
           and serialization_start_op <> 1
           and not exists(select 1
                            from wip_operations wo
                           where wo.wip_entity_id = wdj.wip_entity_id
                             and wo.operation_seq_num = wdj.serialization_start_op);
      end if;

      return;
    end if;

    --job must have an assembly, and the assembly must be serial controlled (predefined).
    select 1
      into l_dummy
      from wip_discrete_jobs wdj,
           mtl_system_items msi
     where wdj.primary_item_id = msi.inventory_item_id
       and wdj.organization_id = msi.organization_id
       and wdj.wip_entity_id = l_wipEntityID
       and msi.serial_number_control_code = wip_constants.full_sn;

    open c_ops(l_wipEntityId);
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
    if( l_rtgExists and not l_opFound ) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    --If no routing exsts, the serialization op must be 1.
    if( not l_rtgExists and l_serialOp <> 1 ) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    -- job must be unreleased to change the serialization op on a
    -- reschedule request. This is to guarantee no txns have taken place.
    if ( l_loadType = wip_constants.resched_job ) then
      select 1
        into l_dummy
        from wip_discrete_jobs
        where wip_entity_id = l_wipEntityID
        and status_type = wip_constants.unreleased;
    end if;
  exception
  when others then
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    fnd_message.set_name('WIP', 'WIP_ML_SERIAL_START_OP');
    x_errorMsg := fnd_message.get;
    setInterfaceError(p_rowid, l_interfaceID, x_errorMsg, validationError);
  end validateSerializationStartOp;


 procedure validateSubinvLocator(p_rowid    in rowid,
                                  x_errorMsg out nocopy varchar2) is
    l_projectLocID number;
    l_subLocCtl number;
    l_orgLocCtl number;
    l_success boolean;
    l_msg varchar2(30);
  begin
    /*Bug 5446216 (FP Bug 5504790): Subinventory can be passed as null during job rescheduling. */
    if ( /* wjsi_row.completion_subinventory is null or */
         wjsi_row.load_type in (wip_constants.create_sched)) then
         --Bug 5191031:It is allowed to modify locator during job rescheduling.
         --Hence validation below should be executed when load_type is resched_job
         --wjsi_row.load_type in (wip_constants.create_sched,
          --                      wip_constants.resched_job) ) then
      return;
    end if;

    if ( wjsi_row.load_type = wip_constants.resched_job ) then
      wjsi_row.project_id := nvl(wjsi_row.project_id, wdj_row.project_id);
      wjsi_row.task_id := nvl(wjsi_row.task_id, wdj_row.task_id);
     /*Bug 5446216 (FP Bug 5504790): Need not copy old value if value is fnd_api.g_miss_char*/
      if wjsi_row.completion_subinventory is null then
        if ( wjsi_row.completion_locator_id is null) then
                        wjsi_row.completion_locator_id :=  wdj_row.completion_locator_id;
        end if;
      elsif (wjsi_row.completion_subinventory = fnd_api.g_miss_char) then
                wjsi_row.completion_locator_id :=  null;
      end if;
      wjsi_row.completion_subinventory :=
            nvl(wjsi_row.completion_subinventory, wdj_row.completion_subinventory);

      --Bug 5191031:Following defaulting prevents the following update:
      --Update the completion sub inv and locator of a job from SX and LX to SY and NULL.
      --where SY is not locator controlled.
      --if (wjsi_row.completion_subinventory is not null) then
       --   wjsi_row.completion_locator_id :=  nvl(wjsi_row.completion_locator_id,
        --                                         wdj_row.completion_locator_id);
      --end if;
    end if;

    if ( wjsi_row.project_id is not null) then
      if(pjm_project_locator.check_itemLocatorControl(wjsi_row.organization_id,
                                                      wjsi_row.completion_subinventory,
                                                      wjsi_row.completion_locator_id,
                                                      primary_item_row.inventory_item_id,
                                                      2)) then
        pjm_project_locator.get_defaultProjectLocator(wjsi_row.organization_id,
                                                      wjsi_row.completion_locator_id,
                                                      wjsi_row.project_id,
                                                      wjsi_row.task_id,
                                                      l_projectLocID);
        if ( l_projectLocID is not null ) then
          wjsi_row.completion_locator_id := l_projectLocID;
          if(not pjm_project_locator.check_project_references(wjsi_row.organization_id,
                                                              l_projectLocID,
                                                              'SPECIFIC', -- validation mode
                                                              'Y', -- required?
                                                              wjsi_row.project_id,
                                                              wjsi_row.task_id)) then
            l_msg := 'WIP_ML_LOCATOR_PROJ_TASK';
            raise fnd_api.g_exc_unexpected_error;
          end if;
        end if;
      end if;
    end if;

    /* Bug 5446216 (FP Bug 5504790):Need not validate locator when subinventory is null */
     if(wjsi_row.load_type <> wip_constants.create_sched and
       ((wjsi_row.completion_subinventory IS NOT NULL  AND  wjsi_row.completion_subinventory <> fnd_api.g_miss_char)
        OR (wjsi_row.completion_locator_id IS NOT NULL AND  wjsi_row.completion_locator_id <> fnd_api.g_miss_num))) then

    l_msg := 'WIP_ML_INVALID_LOCATOR';

	select sub.locator_type, mp.stock_locator_control_code
      into l_subLocCtl, l_orgLocCtl
      from mtl_secondary_inventories sub,
           mtl_parameters mp
     where sub.secondary_inventory_name = wjsi_row.completion_subinventory
       and sub.organization_id = wjsi_row.organization_id
       and mp.organization_id = wjsi_row.organization_id;

     wip_locator.validate(
                   p_organization_id => wjsi_row.organization_id,
                   p_item_id                 => primary_item_row.inventory_item_id,
                   p_subinventory_code       => wjsi_row.completion_subinventory,
                   p_org_loc_control         => l_orgLocCtl,
                   p_sub_loc_control         => l_subLocCtl,
                   p_item_loc_control        => primary_item_row.location_control_code,
                   p_restrict_flag           => primary_item_row.restrict_locators_code,
                   p_neg_flag                => '',
                   p_action                  => '',
                   p_project_id              => wjsi_row.project_id,
                   p_task_id                 => wjsi_row.task_id,
                   p_locator_id              => wjsi_row.completion_locator_id,
                   p_locator_segments        => wjsi_row.completion_locator_segments,
                   p_success_flag            => l_success);

    if ( not l_success ) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    end if;

  exception
  when others then
    fnd_message.set_name('WIP', l_msg);
    x_errorMsg := fnd_message.get;
    setInterfaceError(p_rowid, wjsi_row.interface_id, x_errorMsg, validationError);
    raise line_validation_error;
  end validateSubinvLocator;

  /* Fix for #6117094. Added following procedure not to change job date when
     source is MSC and completed operation (not passed by ASCP) exists on a
     job
  */
  procedure deriveScheduleDate(p_rowid in rowid,
                               x_errorMsg out nocopy varchar2) is
  l_params wip_logger.param_tbl_t;
  l_ret_status varchar2(20);
  l_logLevel number := to_number(fnd_log.g_current_runtime_level);
  l_procName varchar2(30) := 'deriveScheduleDate';
  begin
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_rowid';
      l_params(1).paramValue := p_rowid;
      wip_logger.entryPoint(p_procName     => g_pkgName || '.' || l_procName,
                            p_params       => l_params,
                            x_returnStatus => l_ret_status);
      if(l_ret_status <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;


    /* Populate original job start date as fusd. This will ensure that completed operation
       dates are updated as original job start date in update_routing procedure in wipschdb.pls .
    */

    if (wjsi_row.source_code = 'MSC' and
       wjsi_row.load_type = wip_constants.resched_job and
       wjsi_row.scheduling_method = wip_constants.ml_manual) then

       begin
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
         wip_logger.log(' Repopulated Scheduled Start Date as' || wjsi_row.first_unit_start_date,
                          l_ret_status );
       exception
         when NO_DATA_FOUND then
           null;
       end;
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                           p_procReturnStatus => null,
                           p_msg              => 'success',
                           x_returnStatus     => l_ret_status);
    end if;

  end deriveScheduleDate;

  procedure validateLotNumber(p_rowid    in rowid,
                              x_errorMsg out nocopy varchar2) is
  begin
    if ( wjsi_row.load_type = wip_constants.resched_job ) then
      wjsi_row.lot_number := wip_lot_number_default.lot_number(
                               p_item_id => wdj_row.primary_item_id,
                               p_organization_id => wjsi_row.organization_id,
                               p_lot_number => wjsi_row.lot_number,
                               p_job_name => wdj_row.wip_entity_name,
                               p_default_flag => 0);
    elsif ( wjsi_row.load_type in (wip_constants.create_job,
                                   wip_constants.create_ns_job) ) then
      wjsi_row.lot_number := wip_lot_number_default.lot_number(
                               p_item_id => wjsi_row.primary_item_id,
                               p_organization_id => wjsi_row.organization_id,
                               p_lot_number => wjsi_row.lot_number,
                               p_job_name => wjsi_row.job_name,
                               p_default_flag => 1);
    end if;
  end validateLotNumber;


  procedure validateKanban(p_rowid    in rowid,
                           p_validationLevel in number,
                           x_errorMsg out nocopy varchar2) is
    l_raw_job WIP_Work_Order_Pub.DiscreteJob_Rec_Type ;
    l_defaulted_job WIP_Work_Order_Pub.DiscreteJob_Rec_Type ;
    l_raw_sched WIP_Work_Order_Pub.RepSchedule_Rec_Type ;
    l_defaulted_sched WIP_Work_Order_Pub.RepSchedule_Rec_Type ;

    l_doc_type NUMBER;
    l_doc_header_id NUMBER;
    l_status VARCHAR2(100);
    l_msg varchar2(30);
  begin
    if ( wjsi_row.kanban_card_id is null ) then
      return;
    end if;

    if ( p_validationLevel <>  wip_constants.inv ) then
      l_msg := 'WIP_ML_KB_SRC_NOT_INV';
      raise fnd_api.g_exc_unexpected_error;
    else
      if ( wjsi_row.load_type = wip_constants.create_job ) then
        l_raw_job := WIP_Work_Order_Pub.G_MISS_DISCRETEJOB_REC;

        l_raw_job.organization_id := wjsi_row.organization_id;
        l_raw_job.kanban_card_id := wjsi_row.kanban_card_id;
        l_raw_job.primary_item_id := nvl(wjsi_row.primary_item_id, l_raw_job.primary_item_id);
        l_raw_job.completion_subinventory := nvl(wjsi_row.completion_subinventory, l_raw_job.completion_subinventory);
        l_raw_job.completion_locator_id := nvl(wjsi_row.completion_locator_id, l_raw_job.completion_locator_id);
        l_raw_job.start_quantity := nvl(wjsi_row.start_quantity, l_raw_job.start_quantity);
        l_raw_job.action := WIP_Globals.G_OPR_DEFAULT_USING_KANBAN;

        WIP_Default_DiscreteJob.attributes(p_discreteJob_rec => l_raw_job,
                                           x_discreteJob_rec => l_defaulted_job,
                                           p_redefault       => false);

        l_defaulted_job := WIP_DiscreteJob_Util.convert_miss_to_null(l_defaulted_job);
        wjsi_row.primary_item_id := l_defaulted_job.primary_item_id;
        wjsi_row.completion_subinventory := l_defaulted_job.completion_subinventory;
        wjsi_row.completion_locator_id := l_defaulted_job.completion_locator_id;
        wjsi_row.start_quantity := l_defaulted_job.start_quantity;
      elsif ( wjsi_row.load_type = wip_constants.create_sched) then
        l_raw_sched := WIP_Work_Order_Pub.G_MISS_REPSCHEDULE_REC;

        l_raw_sched.organization_id := wjsi_row.organization_id;
        l_raw_sched.kanban_card_id := wjsi_row.kanban_card_id ;
        l_raw_sched.line_id := nvl(wjsi_row.line_id, l_raw_sched.line_id);
        l_raw_sched.processing_work_days := nvl(wjsi_row.processing_work_days, l_raw_sched.processing_work_days);
        l_raw_sched.first_unit_cpl_date := nvl(wjsi_row.first_unit_completion_date, l_raw_sched.first_unit_cpl_date);
        l_raw_sched.daily_production_rate := nvl(wjsi_row.daily_production_rate, l_raw_sched.daily_production_rate);
        l_raw_sched.action := WIP_Globals.G_OPR_DEFAULT_USING_KANBAN;

        WIP_Default_RepSchedule.attributes(p_RepSchedule_rec => l_raw_sched,
                                           x_RepSchedule_rec => l_defaulted_sched,
                                           p_redefault => false);

        l_defaulted_sched := WIP_RepSchedule_Util.convert_miss_to_null(l_defaulted_sched);
        wjsi_row.line_id := l_defaulted_sched.line_id;
        wjsi_row.processing_work_days := l_defaulted_sched.processing_work_days;
        wjsi_row.first_unit_completion_date := l_defaulted_sched.first_unit_cpl_date;
        wjsi_row.daily_production_rate := l_defaulted_sched.daily_production_rate;
      else
        l_msg := 'WIP_ML_BAD_KB_LOAD';
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

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
    fnd_message.set_name('WIP', l_msg);
    x_errorMsg := fnd_message.get;
    setInterfaceError(p_rowid, wjsi_row.interface_id, x_errorMsg, validationError);
    raise line_validation_error;
  end validateKanban;


  procedure validateOvercompletion(p_rowid    in rowid,
                                   x_errorMsg out nocopy varchar2) is
    l_msg varchar2(30);
  begin
    if ( wjsi_row.load_type = wip_constants.resched_job ) then
      if ( wjsi_row.overcompletion_tolerance_type is null ) then
        wjsi_row.overcompletion_tolerance_type := wdj_row.overcompletion_tolerance_type;
      end if;
      if ( wjsi_row.overcompletion_tolerance_value is null ) then
        wjsi_row.overcompletion_tolerance_value := wdj_row.overcompletion_tolerance_value;
      end if;
    end if;

    if ( wjsi_row.load_type in (wip_constants.create_job, wip_constants.create_ns_job) and
         wjsi_row.primary_item_id is not null and
         wjsi_row.overcompletion_tolerance_type is null and
         wjsi_row.overcompletion_tolerance_value is null ) then
      wip_overcompletion.get_tolerance_default(
              p_primary_item_id  => wjsi_row.primary_item_id,
              p_org_id           => wjsi_row.organization_id,
              p_tolerance_type   => wjsi_row.overcompletion_tolerance_type,
              p_tolerance_value  => wjsi_row.overcompletion_tolerance_value);

    end if;

    if ( wjsi_row.load_type in (wip_constants.create_job, wip_constants.resched_job) or
         (wjsi_row.load_type = wip_constants.create_ns_job and wjsi_row.primary_item_id is not null) ) then
      if ( wjsi_row.overcompletion_tolerance_type is not null and
           wjsi_row.overcompletion_tolerance_value is not null ) then
        if ( wjsi_row.overcompletion_tolerance_type not in (wip_constants.percent, wip_constants.amount) ) then
          l_msg:= 'WIP_ML_COMP_TOLERANCE_TYPE';
          raise fnd_api.g_exc_unexpected_error;
        end if;
        if( wjsi_row.overcompletion_tolerance_value < 0 ) then
          l_msg := 'WIP_ML_COMP_TOLERANCE_NEGATIVE';
          raise fnd_api.g_exc_unexpected_error;
        end if;
      elsif ( wjsi_row.overcompletion_tolerance_type is not null or
              wjsi_row.overcompletion_tolerance_value is not null ) then
        -- only one overcompletion column was provided
        l_msg := 'WIP_ML_COMP_TOLERANCE_NULL';
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;
  exception
  when others then
    fnd_message.set_name('WIP', l_msg);
    x_errorMsg := fnd_message.get;
    setInterfaceError(p_rowid, wjsi_row.interface_id, x_errorMsg, validationError);
    raise line_validation_error;
  end validateOvercompletion;

  procedure loadInterfaceError(p_interfaceTbl in out nocopy num_tbl_t,
                               p_text         in varchar2,
                               p_type         in number) is
  begin
    for i in 1 .. p_interfaceTbl.count loop
      insert into wip_interface_errors(
        interface_id,
        error_type,
        error,
        last_update_date,
        creation_date,
        created_by,
        last_update_login,
        last_updated_by
      )values(
        p_interfaceTbl(i),
        p_type,
        p_text,
        sysdate,
        sysdate,
        fnd_global.user_id,
        fnd_global.login_id,
        fnd_global.user_id);
    end loop;
    -- clear the interface id table
    p_interfaceTbl.delete;
  end loadInterfaceError;


  procedure setInterfaceError(p_rowid       in rowid,
                              p_interfaceID in number,
                              p_text        in varchar2,
                              p_type        in number) is
    l_processStatus number;
  begin
    l_processStatus := wip_constants.error;
    if ( p_type = validationWarning ) then
      l_processStatus := wip_constants.warning;
    end if;

    update wip_job_schedule_interface
       set process_status = l_processStatus,
           last_update_date = sysdate
     where rowid = p_rowid;

    insert into wip_interface_errors(
      interface_id,
      error_type,
      error,
      last_update_date,
      creation_date,
      created_by,
      last_update_login,
      last_updated_by
    )values(
      p_interfaceID,
      p_type,
      p_text,
      sysdate,
      sysdate,
      fnd_global.user_id,
      fnd_global.login_id,
      fnd_global.user_id
    );
  end setInterfaceError;

end wip_validateMLHeader_pvt;

/
