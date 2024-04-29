--------------------------------------------------------
--  DDL for Package Body WIP_MASSLOAD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_MASSLOAD_PUB" as
 /* $Header: wipmlppb.pls 120.7.12010000.6 2009/09/29 00:06:10 ntangjee ship $ */

  g_pkgName constant varchar2(30) := 'wip_massload_pub';
  g_wipMLError constant number := 1;
  g_wipMLWarning constant number := 2;

  procedure processSerStartOp(p_rowid in rowid,
                              p_interfaceID in number,
                              x_returnStatus out nocopy varchar2,
                              x_errorMsg     out nocopy varchar2);

  --
  -- Currently, this API does not support the creation of repetitive schedule.
  --
  procedure massLoadJobs(p_groupID         in number,
                         p_validationLevel in number,
			 p_commitFlag     in number,
                         x_returnStatus out nocopy varchar2,
                         x_errorMsg     out nocopy varchar2) is
    l_params wip_logger.param_tbl_t;
    l_procName varchar2(30) := 'massLoadJobs';
    l_logLevel number := to_number(fnd_log.g_current_runtime_level);
    l_retStatus varchar2(1);
    l_totalNum number;
    l_errorCode varchar2(240);
    l_errRecCount number := 0;
    l_requestCount number;
    l_wdj_old_status_type NUMBER;/*Added for bug 6641029*/
    l_wjsi_new_status_type NUMBER;/*Added for bug 6641029*/
    l_wdj_wip_entity_id NUMBER;/*Added for bug 6641029*/
    l_wdj_organization_id NUMBER;/*Added for bug 6641029*/
    l_success number;  --8296679

    cursor c_allrows is
      select 1
        from wip_job_schedule_interface
       where group_id = p_groupID
         and process_status = wip_constants.pending
         and process_phase = wip_constants.ml_validation
         and load_type <> wip_constants.create_sched
      for update nowait;

    cursor c_wjsi is
      select rowid,
             header_id,
             interface_id,
             job_name,          --8494582
 	     wip_entity_id,     --8494582
 	     organization_id,   --8494582
 	     organization_code, --8494582
 	     load_type,         --8494582
 	     status_type,       --8296679
 	     class_code,        --8296679
 	     date_released      --8296679
        from wip_job_schedule_interface
       where group_id = p_groupID
         and process_phase = wip_constants.ml_validation
         and process_status in (wip_constants.running, wip_constants.warning)
         and load_type <> wip_constants.create_sched;
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

    -- print the no.of discrete requests to log

    select count(*) into l_requestCount
        from wip_job_schedule_interface
       where group_id = p_groupID
         and process_status = wip_constants.pending
         and process_phase = wip_constants.ml_validation
         and load_type <> wip_constants.create_sched;

    if (l_logLevel <= wip_constants.trace_logging) then
          wip_logger.log(l_requestCount || ' pending request(s) found for group_id' || p_groupID || ' for discrete processing', l_retStatus);
    end if;

    -- lock all the records
    open c_allrows;
    if ( c_allrows%isopen ) then
      close c_allrows;
    end if;

    -- assign interface_id and set process_status to running
    update wip_job_schedule_interface
       set interface_id = wip_interface_s.nextval,
           process_status = wip_constants.running
     where group_id = p_groupID
       and process_status = wip_constants.pending
       and process_phase = wip_constants.ml_validation
       and load_type <> wip_constants.create_sched;

    if (p_commitFlag <> 0) then
	commit;
    end if;
    --
    -- ?? here, we should assign a different group_id for those records with load type being
    --    create repetitive schedule
    --

    -- do the validation for those records
    wip_validateMLHeader_pvt.validateMLHeader(p_groupID => p_groupID,
                                              p_validationLevel => p_validationLevel,
                                              x_returnStatus => x_returnStatus,
                                              x_errorMsg => x_errorMsg);
    if ( x_returnStatus <> fnd_api.g_ret_sts_success ) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    -- process every row which pass validation
    for wjsi_rec in c_wjsi loop
      begin
        savepoint wip_massload_start;

        /*Bug 8494582: Adding the following IF and SQL to fetch old job status in case of updating a job*/
        if(wjsi_rec.load_type in (WIP_CONSTANTS.RESCHED_JOB,
                                  WIP_CONSTANTS.RESCHED_EAM_JOB)) then
                  select wdj.status_type
                    into l_wdj_old_status_type
                    from wip_discrete_jobs wdj
                   where wdj.organization_id=wjsi_rec.organization_id
                     and wdj.wip_entity_id=wjsi_rec.wip_entity_id;
        end if;
	/*8494582 End*/

        wip_massload_pvt.processWJSI(wjsi_rec.rowid, l_retStatus, x_errorMsg);
        if ( l_retStatus <> fnd_api.g_ret_sts_success ) then
          raise fnd_api.g_exc_unexpected_error;
        end if;

        select count(*)
          into l_totalNum
          from wip_job_schedule_interface wjsi,
               wip_job_dtls_interface wjdi
         where wjdi.parent_header_id = wjsi.header_id
           and wjdi.group_id = wjsi.group_id
           and wjdi.process_phase = wip_constants.ml_validation
           and wjdi.process_status = wip_constants.pending
           and wjsi.rowid = wjsi_rec.rowid
           and wjsi.load_type in (wip_constants.create_job,
                                  wip_constants.create_ns_job,
                                  wip_constants.resched_job);

        if (l_logLevel <= wip_constants.trace_logging) then
          wip_logger.log('There are ' || l_totalNum || ' detail records....', l_retStatus);
        end if;

        if ( l_totalNum > 0 ) then
          wip_job_details.load_all_details(p_group_id => p_groupID,
                                           p_parent_header_id => wjsi_rec.header_id,
                                           p_std_alone => 0,
                                           x_err_code => l_errorCode,
                                           x_err_msg => x_errorMsg,
                                           x_return_status => l_retStatus);
          if ( l_retStatus <> fnd_api.g_ret_sts_success ) then
            raise fnd_api.g_exc_unexpected_error;
          end if;
        end if;

        -- only here an we do validation for serialization_start_op because it depends on the routing
        -- explosion and detail loading
        processSerStartOp(wjsi_rec.rowid,
                          wjsi_rec.interface_id,
                          l_retStatus,
                          x_errorMsg);
        if ( l_retStatus <> fnd_api.g_ret_sts_success ) then
          raise fnd_api.g_exc_unexpected_error;
        end if;

	/* Fix 8296679: Moved this code from wip_massload_pvt.processWJSI to release the job
 	   after loading operation from WJDI to populate quantity in queue of the first operation
 	   added in WJDI
 	*/
 	-- release job if necessary
 	if (wjsi_rec.load_type in (wip_constants.create_job, wip_constants.create_ns_job)  and
 	    wjsi_rec.status_type in (wip_constants.released, wip_constants.hold) ) then
 	  wip_mass_load_processor.ml_release(wjsi_rec.wip_entity_id,
                                             wjsi_rec.organization_id,
                                             wjsi_rec.class_code,
                                             wjsi_rec.status_type,
                                             l_success,
                                             x_errorMsg,
                                             nvl(wjsi_rec.date_released, sysdate));

          if ( l_success = 0 ) then
            raise fnd_api.g_exc_unexpected_error;
          end if;
        end if;
 	/* End Fix 8296679 */

/*6641029 Start- Added code to create requisition*/
 select wjsi.status_type,
        wdj.wip_entity_id,
        wdj.organization_id
        into l_wjsi_new_status_type,  /*Removed old status type for bug 8494582*/
             l_wdj_wip_entity_id,
             l_wdj_organization_id
         from wip_discrete_jobs wdj,
             wip_job_schedule_interface wjsi
       where wjsi.rowid = wjsi_rec.rowid
         and wdj.wip_entity_id = wjsi.wip_entity_id
         and wdj.organization_id = wjsi.organization_id
         and wjsi.load_type in (WIP_CONSTANTS.CREATE_JOB,
                                WIP_CONSTANTS.CREATE_NS_JOB,
                                WIP_CONSTANTS.CREATE_EAM_JOB,
                                WIP_CONSTANTS.RESCHED_EAM_JOB,
                                WIP_CONSTANTS.RESCHED_JOB) ;
         if (l_wjsi_new_status_type IN (WIP_CONSTANTS.RELEASED,WIP_CONSTANTS.HOLD))  then
             if((wip_osp.po_req_created( l_wdj_wip_entity_id,
                                    null,
                                    l_wdj_organization_id,
                                    null,
                                    WIP_CONSTANTS.DISCRETE
                                 ) = FALSE) or l_wdj_old_status_type in (WIP_CONSTANTS.UNRELEASED))  then
                wip_osp.release_validation(l_wdj_wip_entity_id,
                                           l_wdj_organization_id,
                                           NULL) ;
             end if ;
        end if ;
/*6641029 End*/
      exception
      when fnd_api.g_exc_unexpected_error then
        rollback to wip_massload_start;
        wip_validateMLHeader_pvt.setInterfaceError(wjsi_rec.rowid,
                                                   wjsi_rec.interface_id,
                                                   x_errorMsg,
                                                   g_wipMLError);
        if (l_logLevel <= wip_constants.trace_logging) then
          wip_logger.log('interface ' || wjsi_rec.interface_id || ' failed: ' || x_errorMsg, l_retStatus);
        end if;
      end;
    end loop;

    update wip_job_schedule_interface
       set process_status = wip_constants.completed,
           process_phase = wip_constants.ml_complete
     where group_id = p_groupID
       and process_status in (wip_constants.running, wip_constants.warning)
       and process_phase = wip_constants.ml_validation
       and load_type <> wip_constants.create_sched;

    if (p_commitFlag <> 0) then
	commit;
    end if;

    select count(*) into l_errRecCount
      from wip_job_schedule_interface
     where group_id = p_groupID
       and process_status = wip_constants.error;

    if(l_errRecCount > 0) then
      x_returnStatus := fnd_api.g_ret_sts_error;
    else
      x_returnStatus := fnd_api.g_ret_sts_success;
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
    end if;
  exception
  when wip_constants.records_locked then
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => g_pkgName || '.' || l_procName,
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'records locked',
                           x_returnStatus => l_retStatus);
    end if;
    fnd_message.set_name('WIP', 'WIP_LOCKED_ROW_ALREADY_LOCKED');
    x_errorMsg := fnd_message.get;
  when fnd_api.g_exc_unexpected_error then
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => g_pkgName || '.' || l_procName,
                           p_procReturnStatus => x_returnStatus,
                           p_msg => x_errorMsg,
                           x_returnStatus => l_retStatus);
    end if;
  end massLoadJobs;


  -- this API is used to create one job for the given interface id. Please note that there should be no
  -- other records under the same group id as the given interface id. This API will fail that case.
  -- also, the load type for this record must be create standard or non-std job.
  procedure createOneJob(p_interfaceID in number,
                         p_validationLevel in number,
                         x_wipEntityID out nocopy number,
                         x_returnStatus out nocopy varchar2,
                         x_errorMsg     out nocopy varchar2) is
    l_params wip_logger.param_tbl_t;
    l_procName varchar2(30) := 'createOneJob';
    l_logLevel number := to_number(fnd_log.g_current_runtime_level);
    l_retStatus varchar2(1);
    l_totalNum number;
    l_groupID number;
    l_headerID number;
    l_rowid rowid;
    l_errorCode varchar2(240);
    l_load_type wip_job_schedule_interface.load_type%TYPE; --8936011
    l_status_type wip_job_schedule_interface.status_type%TYPE; --8936011
    l_wip_entity_id wip_job_schedule_interface.wip_entity_id%TYPE; --8936011
    l_organization_id wip_job_schedule_interface.organization_id%TYPE; --8936011
    l_class_code wip_job_schedule_interface.class_code%TYPE; --8936011
    l_date_released wip_job_schedule_interface.date_released%TYPE; --8936011
    l_success number;  --8936011

    cursor c_allrows is
      select 1
        from wip_job_schedule_interface
       where interface_id = p_interfaceID
      for update nowait;
  begin
    x_returnStatus := fnd_api.g_ret_sts_success;
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_interfaceID';
      l_params(1).paramValue := p_interfaceID;
      l_params(2).paramName := 'p_validationLevel';
      l_params(2).paramValue := p_validationLevel;
      wip_logger.entryPoint(p_procName     => g_pkgName || '.' || l_procName,
                            p_params       => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    select rowid, group_id, header_id
      into l_rowid, l_groupID, l_headerID
      from wip_job_schedule_interface
     where interface_id = p_interfaceID;

    select count(*)
      into l_totalNum
      from wip_job_schedule_interface
     where interface_id = p_interfaceID
       and process_status = wip_constants.pending
       and process_phase = wip_constants.ml_validation
       and load_type in (wip_constants.create_job, wip_constants.create_ns_job);

    if ( l_totalNum <> 1 ) then
      fnd_message.set_name('WIP', 'WIP_WJSI_ONE_ROW');
      x_errorMsg := fnd_message.get;
      raise fnd_api.g_exc_unexpected_error;
    end if;

    select count(*)
      into l_totalNum
      from wip_job_schedule_interface wjsi
     where wjsi.group_id = l_groupID;

    if ( l_totalNum <> 1 ) then
      fnd_message.set_name('WIP', 'WIP_WJSI_ONE_ROW');
      x_errorMsg := fnd_message.get;
      raise fnd_api.g_exc_unexpected_error;
    end if;

    -- lock all the records
    open c_allrows;
    if ( c_allrows%isopen ) then
      close c_allrows;
    end if;

    update wip_job_schedule_interface
       set process_status = wip_constants.running
     where interface_id = p_interfaceID;

    -- do the validation for those records
    wip_validateMLHeader_pvt.validateMLHeader(p_groupID => l_groupID,
                                              p_validationLevel => p_validationLevel,
                                              x_returnStatus => x_returnStatus,
                                              x_errorMsg => x_errorMsg);
    if ( x_returnStatus <> fnd_api.g_ret_sts_success ) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    select count(*)
      into l_totalNum
      from wip_job_schedule_interface
     where interface_id = p_interfaceID
       and process_status in (wip_constants.running, wip_constants.warning);

    if ( l_totalNum <> 1 ) then
      fnd_message.set_name('WIP', 'WIP_WJSI_VAL_FAILED');
      x_errorMsg := fnd_message.get;
      raise fnd_api.g_exc_unexpected_error;
    end if;

    wip_massload_pvt.processWJSI(l_rowid, x_returnStatus, x_errorMsg);
    if ( x_returnStatus <> fnd_api.g_ret_sts_success ) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    select count(*)
      into l_totalNum
      from wip_job_schedule_interface wjsi,
           wip_job_dtls_interface wjdi
     where wjdi.parent_header_id = wjsi.header_id
       and wjdi.group_id = wjsi.group_id
       and wjdi.process_phase = wip_constants.ml_validation
       and wjdi.process_status = wip_constants.pending
       and wjsi.rowid = l_rowid;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.log('There are ' || l_totalNum || ' detail records....', l_retStatus);
    end if;

    if ( l_totalNum > 0 ) then
      wip_job_details.load_all_details(p_group_id => l_groupID,
                                       p_parent_header_id => l_headerID,
                                       p_std_alone => 0,
                                       x_err_code => l_errorCode,
                                       x_err_msg => x_errorMsg,
                                       x_return_status => l_retStatus);
      if ( l_retStatus <> fnd_api.g_ret_sts_success ) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    -- only here an we do validation for serialization_start_op because it depends on the routing
    -- explosion and detail loading
    processSerStartOp(l_rowid,
                      p_interfaceID,
                      l_retStatus,
                      x_errorMsg);
    if ( l_retStatus <> fnd_api.g_ret_sts_success ) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    select wip_entity_id,
           load_type, status_type, organization_id, class_code, date_released --8936011
      into x_wipEntityID,
           l_load_type, l_status_type, l_organization_id, l_class_code, l_date_released --8936011
      from wip_job_schedule_interface
     where rowid = l_rowid;

    /* Fix 8936011: Moved this code from wip_massload_pvt.processWJSI
      to release the job after loading operation from WJDI to populate quantity
      in queue of the first operation added in WJDI
    */
    -- release job if necessary

    if (l_load_type in (wip_constants.create_job, wip_constants.create_ns_job)  and
        l_status_type in (wip_constants.released, wip_constants.hold) ) then
      wip_mass_load_processor.ml_release(x_wipEntityID,
                                               l_organization_id,
                                               l_class_code,
                                               l_status_type,
                                               l_success,
                                               x_errorMsg,
                                               nvl(l_date_released, sysdate));

      if ( l_success = 0 ) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    /* End Fix 8936011 */

    update wip_job_schedule_interface
       set process_status = wip_constants.completed
     where rowid = l_rowid;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
    end if;
  exception
  when wip_constants.records_locked then
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    fnd_message.set_name('WIP', 'WIP_LOCKED_ROW_ALREADY_LOCKED');
    x_errorMsg := fnd_message.get;
    wip_validateMLHeader_pvt.setInterfaceError(l_rowid,
                                               p_interfaceID,
                                               x_errorMsg,
                                               g_wipMLError);
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => g_pkgName || '.' || l_procName,
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'records locked',
                           x_returnStatus => l_retStatus);
    end if;
  when fnd_api.g_exc_unexpected_error then
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    wip_validateMLHeader_pvt.setInterfaceError(l_rowid,
                                               p_interfaceID,
                                               x_errorMsg,
                                               g_wipMLError);
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => g_pkgName || '.' || l_procName,
                           p_procReturnStatus => x_returnStatus,
                           p_msg => x_errorMsg,
                           x_returnStatus => l_retStatus);
    end if;
  end createOneJob;


  procedure processSerStartOp(p_rowid in rowid,
                              p_interfaceID in number,
                              x_returnStatus out nocopy varchar2,
                              x_errorMsg     out nocopy varchar2) is
    l_msg varchar2(80);
    l_dummy number;

    l_wjsiSerOp number;
    l_wdjSerOp number;
    l_wipEntityID number;
    l_loadType number;
    l_primaryItemID number;
    l_orgID number;

    l_curOpSeq number;
    l_rtgExists boolean := false;
    l_opFound boolean := false;

    cursor c_ops(v_wipEntityID number) is
      select operation_seq_num
        from wip_operations
       where wip_entity_id = v_wipEntityID;

  begin
    x_returnStatus := fnd_api.g_ret_sts_success;
    l_msg := 'WIP_ML_SERIAL_START_OP';

    select wip_entity_id,
           serialization_start_op,
           load_type,
           primary_item_id,
           organization_id
      into l_wipEntityID,
           l_wjsiSerOp,
           l_loadType,
           l_primaryItemID,
           l_orgID
      from wip_job_schedule_interface
     where rowid = p_rowid;

    if ( l_wjsiSerOp is null and l_loadType = wip_constants.resched_job ) then
    -- due to re-exploding, we may need to clear out the serialization start op
      update wip_discrete_jobs wdj
         set serialization_start_op = null
       where wip_entity_id = l_wipEntityID
         and serialization_start_op <> 1
         and not exists(select 1
                          from wip_operations wo
                         where wo.wip_entity_id = wdj.wip_entity_id
                           and wo.operation_seq_num = wdj.serialization_start_op);
      return;
    end if;

    -- when the flow comes here, regardless reschedule or job creation, we already updated wdj
    -- with the right value for serialization_start_op from the interface table or the defaulting
    -- logic. the column value might be different between wjsi and wdj because we do update for wdj if
    -- wjsi is null for job creation. Otherwise, the value should be the same.
    select serialization_start_op
      into l_wdjSerOp
      from wip_discrete_jobs
     where wip_entity_id = l_wipEntityID;

    if ( l_wdjSerOp is null ) then
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

    open c_ops(l_wipEntityID);
    loop
      fetch c_ops into l_curOpSeq;
      exit when c_ops%NOTFOUND;
      l_rtgExists := true;
      if(l_curOpSeq = l_wdjSerOp) then
        l_opFound := true;
        exit;
      end if;
    end loop;
    close c_ops;

    --The routing exists, but an invalid op seq was provided
    if ( l_rtgExists and not l_opFound ) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    --If no routing exsts, the serialization op must be 1.
    if ( not l_rtgExists and l_wdjSerOp <> 1 ) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    --job must be unreleased to change the serialization op on a reschedule request.
    if ( l_loadType = wip_constants.resched_job and l_wjsiSerOp is not null ) then
      select 1
        into l_dummy
        from wip_discrete_jobs
      where wip_entity_id = l_wipEntityID
        and status_type = wip_constants.unreleased;
    end if;

    l_msg := 'WIP_ML_SER_DEF_FAILURE';
    wip_job_dtls_substitutions.default_serial_associations(p_rowid => p_rowid,
                                                           p_wip_entity_id => l_wipEntityID,
                                                           p_organization_id => l_orgID,
                                                           x_err_msg => x_errorMsg,
                                                           x_return_status => x_returnStatus);
    if ( x_returnStatus <> fnd_api.g_ret_sts_success ) then
      raise fnd_api.g_exc_unexpected_error;
    end if;
  exception
  when others then
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    fnd_message.set_name('WIP', l_msg);
    if ( l_msg = 'WIP_ML_SER_DEF_FAILURE' ) then
      fnd_message.set_token('MESSAGE', x_errorMsg);
    end if;
    x_errorMsg := fnd_message.get;
  end processSerStartOp;

end wip_massload_pub;

/
