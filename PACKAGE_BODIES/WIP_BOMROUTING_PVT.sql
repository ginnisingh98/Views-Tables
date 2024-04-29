--------------------------------------------------------
--  DDL for Package Body WIP_BOMROUTING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_BOMROUTING_PVT" as
 /* $Header: wipbmrtb.pls 120.15.12010000.5 2009/05/18 14:28:51 sisankar ship $ */

  g_pkgName constant varchar2(30) := 'wip_bomRouting_pvt';

  -- This procedure is used to explode the bom and routing and schedule the job if needed.
  -- p_schedulingMethod: if the value is routing based, then you must provide one of the p_startDate
  --                     and p_endDate, you can not provide both, however.
  --                     if it is not routing based, then you must provide both.
  -- p_startDate: forward schedule the job if it is not null
  -- p_endDate: backward schedule the job it it is not null
  -- p_rtgRefID: only useful when p_jobType is nonstandard
  -- p_bomRefID: only useful when p_jobType is nonstandard
  -- p_unitNumber: To explode components properly based on unit number for unit effective assemblies.
  procedure createJob(p_orgID       in number,
                      p_wipEntityID in number,
                      p_jobType     in number,
                      p_itemID      in number,
                      p_schedulingMethod in number,
                      p_altRouting  in varchar2,
                      p_routingRevDate in date,
                      p_altBOM      in varchar2,
                      p_bomRevDate  in date,
                      p_qty         in number,
                      p_startDate   in date,
                      p_endDate     in date,
                      p_projectID   in number,
                      p_taskID      in number,
                      p_rtgRefID    in number,
                      p_bomRefID    in number,
		      p_unitNumber  in varchar2 DEFAULT '', /* added for bug 5332615 */
                      x_serStartOp   out nocopy number,
                      x_returnStatus out nocopy varchar2,
                      x_errorMsg     out nocopy varchar2) is
    l_params wip_logger.param_tbl_t;
    l_procName varchar2(30) := 'createJob';
    l_logLevel number := to_number(fnd_log.g_current_runtime_level);
    l_retStatus varchar2(1);
    l_msg varchar2(240);

    l_startDate date;
    l_endDate date;
    l_rtgItemID number;
    l_bomItemID number;
  begin
    x_returnStatus := fnd_api.g_ret_sts_success;
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_orgID';
      l_params(1).paramValue := p_orgID;
      l_params(2).paramName := 'p_wipEntityID';
      l_params(2).paramValue := p_wipEntityID;
      l_params(3).paramName := 'p_jobType';
      l_params(3).paramValue := p_jobType;
      l_params(4).paramName := 'p_itemID';
      l_params(4).paramValue := p_itemID;
      l_params(5).paramName := 'p_schedulingMethod';
      l_params(5).paramValue := p_schedulingMethod;
      l_params(6).paramName := 'p_altRouting';
      l_params(6).paramValue := p_altRouting;
      l_params(7).paramName := 'p_routingRevDate';
      l_params(7).paramValue := p_routingRevDate;
      l_params(8).paramName := 'p_altBOM';
      l_params(8).paramValue := p_altBOM;
      l_params(9).paramName := 'p_bomRevDate';
      l_params(9).paramValue := p_bomRevDate;
      l_params(10).paramName := 'p_qty';
      l_params(10).paramValue := p_qty;
      l_params(11).paramName := 'p_startDate';
      l_params(11).paramValue := p_startDate;
      l_params(12).paramName := 'p_endDate';
      l_params(12).paramValue := p_endDate;
      l_params(13).paramName := 'p_projectID';
      l_params(13).paramValue := p_projectID;
      l_params(14).paramName := 'p_taskID';
      l_params(14).paramValue := p_taskID;
      l_params(15).paramName := 'p_rtgRefID';
      l_params(15).paramValue := p_rtgRefID;
      l_params(16).paramName := 'p_bomRefID';
      l_params(16).paramValue := p_bomRefID;
      wip_logger.entryPoint(p_procName     => g_pkgName || '.' || l_procName,
                            p_params       => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    if ( p_schedulingMethod = wip_constants.routing ) then
      if ( (p_startDate is null and p_endDate is null) or
           ((p_startDate is not null and p_endDate is not null) and
           /* Bug 4515999 Non standard jobs cannot have both dates not null */
	     p_jobType = wip_constants.standard) ) then
        x_errorMsg := 'Must only provide one of the p_startDate and p_endDate for routing based scheduling';
        raise fnd_api.g_exc_unexpected_error;
      else
        -- populate some value and then we will reschedule it later on.
        l_startDate := nvl(p_startDate, p_endDate);
        l_endDate := l_startDate;
      end if;
    else
      if ( p_startDate is null or p_endDate is null ) then
        x_errorMsg := 'Must provide both of the dates if it is not routing based scheduling';
        raise fnd_api.g_exc_unexpected_error;
      else
        l_startDate := p_startDate;
        l_endDate := p_endDate;
      end if;
    end if;

    if ( p_jobType = wip_constants.standard ) then
      l_rtgItemID := p_itemID;
      l_bomItemID := p_itemID;
    else
      l_rtgItemID := p_rtgRefID;
      l_bomItemID := p_bomRefID;
    end if;

    wip_bomRoutingUtil_pvt.explodeRouting(p_orgID => p_orgID,
                                      p_wipEntityID => p_wipEntityID,
                                      p_repSchedID => null,
                                      p_itemID => l_rtgItemID,
                                      p_altRouting => p_altRouting,
                                      p_routingRevDate => p_routingRevDate,
                                      p_qty => p_qty,
                                      p_startDate => l_startDate,
                                      p_endDate => l_endDate,
                                      x_serStartOp => x_serStartOp,
                                      x_returnStatus => x_returnStatus,
                                      x_errorMsg => x_errorMsg);
    if ( x_returnStatus <> fnd_api.g_ret_sts_success ) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    if ( p_schedulingMethod = wip_constants.routing ) then
      wip_infinite_scheduler_pvt.schedule(
          p_orgID => p_orgID,
          p_wipEntityID => p_wipEntityID,
          p_startDate => p_startDate,
          p_endDate => p_endDate,
          x_returnStatus => x_returnStatus,
          x_errorMsg => x_errorMsg);
      if ( x_returnStatus <> fnd_api.g_ret_sts_success ) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    -- explode the bom
    select wdj.scheduled_start_date,
           wdj.scheduled_completion_date
      into l_startDate, l_endDate
      from wip_discrete_jobs wdj
     where wdj.organization_id = p_orgID
       and wdj.wip_entity_id = p_wipEntityID;

    wip_bomRoutingUtil_pvt.explodeBOM(p_orgID => p_orgID,
                                  p_wipEntityID => p_wipEntityID,
                                  p_jobType => p_jobType,
                                  p_repSchedID => null,
                                  p_itemID => l_bomItemID,
                                  p_altBOM => p_altBOM,
                                  p_bomRevDate => p_bomRevDate,
                                  p_altRouting => p_altRouting,
                                  p_routingRevDate => p_routingRevDate,
                                  p_qty => p_qty,
                                  p_jobStartDate => l_startDate,
                                  p_projectID => p_projectID,
                                  p_taskID => p_taskID,
				  p_unitNumber => p_unitNumber, /* added for bug 5332615 */
                                  x_returnStatus => x_returnStatus,
                                  x_errorMsg => x_errorMsg);
    if ( x_returnStatus <> fnd_api.g_ret_sts_success ) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    -- for bug 3041013
    delete wip_operation_resource_usage
     where wip_entity_id = p_wipEntityID;

    -- for bug 3041018
    wip_op_resources_utilities.update_resource_instances(
        p_wip_entity_id => p_wipEntityID,
        p_org_id => p_orgID);

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
    end if;
  exception
  when others then
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    -- Fixed for bug 5255226
    -- Don't need to add the x_errormsg again to stack by calling fnd_msg_pub.add_exc_msg
    -- Removed this API call. Instead adding this error message to debug log using
    if (l_logLevel <= wip_constants.trace_logging) then
       wip_logger.log(x_errorMsg,l_retstatus);
    End if;
    -- End of Fix for bug 5255226

    if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => x_errorMsg,
                             x_returnStatus     => l_retStatus);
    end if;
  end;

  -- This procedure is used to reexplode the bom/routing if applicable and reschedule the job.
  -- p_schedulingMethod: if the value is routing based, then you must provide one of the p_startDate
  --                     and p_endDate, you can not provide both, however.
  --                     if it is not routing based, then you must provide both.
  -- p_startDate: forward schedule the job if it is not null
  -- p_endDate: backward schedule the job it it is not null
  -- p_rtgRefID: only useful when p_jobType is nonstandard
  -- p_bomRefID: only useful when p_jobType is nonstandard
  -- p_unitNumber: To explode components properly based on unit number for unit effective assemblies.
  -- for anything related to do not want to change, for instance, bom_reference_id, you must pass the original
  -- value queried up from the job. If you pass null, this API will consider that you want to change the
  -- value to null instead of not touching it at all.
  --
  procedure reexplodeJob(p_orgID       in number,
                         p_wipEntityID in number,
                         p_schedulingMethod in number,
                         p_altRouting  in varchar2,
                         p_routingRevDate in date,
                         p_altBOM      in varchar2,
                         p_bomRevDate  in date,
                         p_qty         in number,
                         p_startDate   in date,
                         p_endDate     in date,
			 p_projectID   in number,
			 p_taskID   in number,
                         p_rtgRefID    in number,
                         p_bomRefID    in number,
                         p_allowExplosion in boolean,
			 p_unitNumber  in varchar2 DEFAULT '', /* added for bug 5332615 */
                         x_returnStatus out nocopy varchar2,
                         x_errorMsg     out nocopy varchar2) is
    l_params wip_logger.param_tbl_t;
    l_procName varchar2(30) := 'reexplodeJob';
    l_logLevel number := to_number(fnd_log.g_current_runtime_level);
    l_retStatus varchar2(1);
    l_msg varchar2(240);
    l_serStartOp number;

    l_jobType number;
    l_jobStatus number;
    l_bomRefID number;
    l_rtgRefID number;
    l_bomRevDate date;
    l_rtgRevDate date;
    l_altBom varchar2(10);
    l_altRtg varchar2(10);

    l_expRtgRequired boolean := false;
    l_expBomRequired boolean := false;
    l_rtgItemID number;
    l_bomItemID number;
    l_assemblyID number;
    l_startDate date;
    l_endDate date;

    l_usePhantomRouting number;
    cursor c_phantoms is
      select inventory_item_id,
             -1*operation_seq_num operation_seq_num
        from wip_requirement_operations
       where organization_id = p_orgID
         and wip_entity_id = p_wipEntityID
         and operation_seq_num < 0
         and wip_supply_type = wip_constants.phantom;
  begin

    x_returnStatus := fnd_api.g_ret_sts_success;
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_orgID';
      l_params(1).paramValue := p_orgID;
      l_params(2).paramName := 'p_wipEntityID';
      l_params(2).paramValue := p_wipEntityID;
      wip_logger.entryPoint(p_procName     => g_pkgName || '.' || l_procName,
                            p_params       => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    select job_type,
           status_type,
           primary_item_id,
           bom_reference_id,
           routing_reference_id,
           bom_revision_date,
           routing_revision_date,
           alternate_bom_designator,
           alternate_routing_designator
      into l_jobType,
           l_jobStatus,
           l_assemblyID,
           l_bomRefID,
           l_rtgRefID,
           l_bomRevDate,
           l_rtgRevDate,
           l_altBom,
           l_altRtg
      from wip_discrete_jobs
     where organization_id = p_orgID
       and wip_entity_id = p_wipEntityID;

    if ( /*Fix for bug 5020741. Routing should be exploded if any relevant feild is not null.
         nvl(p_altRouting, fnd_api.g_miss_char) <> nvl(l_altRtg, fnd_api.g_miss_char) or
         nvl(p_routingRevDate, fnd_api.g_miss_date) <> nvl(l_rtgRevDate, fnd_api.g_miss_date)*/
         --Bug 5464449:Comparision of routing info is fixed
	 --p_altRouting IS NOT NULL or
	 --p_routingRevDate IS NOT NULL or
 nvl(p_altRouting, nvl(l_altRtg,fnd_api.g_miss_char)) <> nvl(l_altRtg, fnd_api.g_miss_char) or
 nvl(p_routingRevDate, nvl(l_rtgRevDate, fnd_api.g_miss_date)) <> nvl(l_rtgRevDate, fnd_api.g_miss_date) OR
 --Bug 5464449:End of changes
 (p_allowExplosion) or  -- fix bug 8299845
         (l_jobType = wip_constants.nonstandard and
          nvl(p_rtgRefID, -1) <> nvl(l_rtgRefID, -1)) ) then
      l_expRtgRequired := true;
      if (p_altRouting = '@@@') then
        l_altRtg := null;
      else
        l_altRtg := p_altRouting;
      end if;
    else
      l_expRtgRequired := false;
    end if;

    if ( /* Fix for bug 5020741. Bom should be exploded if any relevant feild is not null.
         nvl(p_altBom, fnd_api.g_miss_char) <> nvl(l_altBom, fnd_api.g_miss_char) or
         nvl(p_bomRevDate, fnd_api.g_miss_date) <> nvl(l_bomRevDate, fnd_api.g_miss_date)*/
--Bug 5464449:Comparision of bom info is fixed
	 --p_altBom IS NOT NULL or
	 --p_bomRevDate IS NOT NULL or
 nvl(p_altBom, nvl(l_altBom, fnd_api.g_miss_char)) <> nvl(l_altBom, fnd_api.g_miss_char) or
 nvl(p_bomRevDate, nvl(l_bomRevDate, fnd_api.g_miss_date)) <> nvl(l_bomRevDate, fnd_api.g_miss_date) or
 --Bug 5464449:End of changes
(p_allowExplosion) or -- fix bug 8299845
         (l_jobType = wip_constants.nonstandard and
          nvl(p_bomRefID, -1) <> nvl(l_bomRefID, -1)) ) then
      l_expBomRequired := true;
      if (p_altBom = '@@@') then
        l_altBom := null;
      else
        l_altBom := p_altBom;
      end if;
    else
      l_expBomRequired := false;
    end if;

    -- unless the job is unreleased, you can never explode again from bom
    if ( not p_allowExplosion or l_jobStatus <> wip_constants.unreleased ) then
      l_expRtgRequired := false;
      l_expBomRequired := false;
    end if;

    if ( p_schedulingMethod = wip_constants.routing ) then
      if ( (p_startDate is null and p_endDate is null) or
           (p_startDate is not null and p_endDate is not null) ) then
        x_errorMsg := 'Must only provide one of the p_startDate and p_endDate for routing based scheduling';
        raise fnd_api.g_exc_unexpected_error;
      else
        -- populate some value and then we will reschedule it later on.
        l_startDate := nvl(p_startDate, p_endDate);
        l_endDate := l_startDate;
      end if;
    else
      if (p_schedulingMethod = wip_constants.ml_manual and (p_startDate is null or p_endDate is null) ) then
        x_errorMsg := 'Must provide both of the dates if it is not routing based scheduling';
        raise fnd_api.g_exc_unexpected_error;
      end if;
      l_startDate := p_startDate;
      l_endDate := p_endDate;
    end if;

    if ( l_expRtgRequired ) then
      -- remove any setup resource for this job
      wip_update_setup_resources.delete_setup_resources_pub(
             p_wip_entity_id => p_wipEntityID,
             p_organization_id => p_orgID);

      delete from wip_operations
       where wip_entity_id = p_wipEntityID
         and organization_id = p_orgID;

      delete from wip_operation_resources
       where wip_entity_id = p_wipEntityID
         and organization_id = p_orgID;

      delete from wip_sub_operation_resources
       where wip_entity_id = p_wipEntityID
         and organization_id = p_orgID;

      fnd_attached_documents2_pkg.delete_attachments(
        x_entity_name => 'WIP_DISCRETE_OPERATIONS',
        x_pk1_value => to_char(p_wipEntityID),
        x_pk3_value => to_char(p_orgID),
        x_delete_document_flag => 'Y');

      if ( l_jobType = wip_constants.standard ) then
        l_rtgItemID := l_assemblyID;
      else
        l_rtgItemID := p_rtgRefID;
      end if;

      wip_bomRoutingUtil_pvt.explodeRouting(
                               p_orgID => p_orgID,
                               p_wipEntityID => p_wipEntityID,
                               p_repSchedID => null,
                               p_itemID => l_rtgItemID,
                               p_altRouting => l_altRtg,
                               p_routingRevDate => p_routingRevDate,
                               p_qty => p_qty,
                               p_startDate => l_startDate,
                               p_endDate => l_endDate,
                               x_serStartOp => l_serStartOp,
                               x_returnStatus => x_returnStatus,
                               x_errorMsg => x_errorMsg);
      if ( x_returnStatus <> fnd_api.g_ret_sts_success ) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;
    /* fix bug 5238435. Move the scheduler call outside the if condition since job can be
       rescheduled even without exploding the routing when user just changes the dates */

      if ( p_schedulingMethod = wip_constants.routing ) then
        wip_infinite_scheduler_pvt.schedule(
            p_orgID => p_orgID,
            p_wipEntityID => p_wipEntityID,
            p_startDate => p_startDate,
            p_endDate => p_endDate,
	    p_quantity => p_qty, --- Added for bug 5440007
            x_returnStatus => x_returnStatus,
            x_errorMsg => x_errorMsg);
        if ( x_returnStatus <> fnd_api.g_ret_sts_success ) then
          raise fnd_api.g_exc_unexpected_error;
        end if;

        select wdj.scheduled_start_date,
               wdj.scheduled_completion_date
          into l_startDate, l_endDate
          from wip_discrete_jobs wdj
         where wdj.organization_id = p_orgID
           and wdj.wip_entity_id = p_wipEntityID;
      end if;


    -- after reexplode the routing, some op reference in WRO might be invalid. We need to set those
    -- properly. We only need to do it if bom reexplosion is not required.
    -- we also need to add the phantom resource back since it was deleted before
    if ( l_expRtgRequired and not l_expBomRequired ) then
      if ( l_logLevel <= wip_constants.trace_logging ) then
        wip_logger.log('Resetting the op reference in WRO.....', l_retStatus);
      end if;
      wip_fix_req_ops_pkg.fix(x_wip_entity_id => p_wipEntityID,
                              x_organization_id => p_orgID,
                              x_repetitive_schedule_id => null,
                              x_entity_start_date => l_startDate);
      l_usePhantomRouting := wip_globals.use_phantom_routings(p_orgID);
      if ( l_usePhantomRouting = wip_constants.yes ) then
        for phan in c_phantoms loop
          wip_explode_phantom_rtgs.explode_resources(
              p_wip_entity_id => p_wipEntityID,
              p_sched_id => null,
              p_org_id => p_orgID,
              p_entity_type => wip_constants.discrete,
              p_phantom_item_id => phan.inventory_item_id,
              p_op_seq_num => phan.operation_seq_num,
              p_rtg_rev_date => p_routingRevDate);
        end loop;
      end if;
    end if;

    if ( l_expBomRequired ) then
      delete from wip_requirement_operations
       where wip_entity_id = p_wipEntityID
         and organization_id = p_orgID;

      if ( l_jobType = wip_constants.standard ) then
        l_bomItemID := l_assemblyID;
      else
        l_bomItemID := p_bomRefID;
      end if;

      -- Added for bug 8463132.
      if l_startDate is null then
        select wdj.scheduled_start_date
        into l_startDate
        from wip_discrete_jobs wdj
        where wdj.organization_id = p_orgID
        and wdj.wip_entity_id = p_wipEntityID;
      end if;

      wip_bomRoutingUtil_pvt.explodeBOM(
                                  p_orgID => p_orgID,
                                  p_wipEntityID => p_wipEntityID,
                                  p_jobType => l_jobType,
                                  p_repSchedID => null,
                                  p_itemID => l_bomItemID,
                                  p_altBOM => l_altBom,
                                  p_bomRevDate => p_bomRevDate,
                                  p_altRouting => p_altRouting,
                                  p_routingRevDate => p_routingRevDate,
                                  p_qty => p_qty,
                                  p_jobStartDate => l_startDate,
                                  p_projectID => p_projectID,
                                  p_taskID => p_taskID,
				  p_unitNumber => p_unitNumber, /* added for bug 5332615 */
                                  x_returnStatus => x_returnStatus,
                                  x_errorMsg => x_errorMsg);
      if ( x_returnStatus <> fnd_api.g_ret_sts_success ) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    -- for bug 3041013
    delete wip_operation_resource_usage
     where wip_entity_id = p_wipEntityID;

    -- for bug 3041018
    wip_op_resources_utilities.update_resource_instances(
        p_wip_entity_id => p_wipEntityID,
        p_org_id => p_orgID);

    -- if it is only date changes or qty changes, then the flow should be here
    if ( not l_expBomRequired and not l_expRtgRequired ) then
     --Bug 5464449: Quantity should be adjusted only when explode is yes at header level.
     if  p_allowExplosion  then
      wip_bomRoutingUtil_pvt.adjustQtyChange(
                                  p_orgID => p_orgID,
                                  p_wipEntityID => p_wipEntityID,
                                  p_qty => p_qty,
                                  x_returnStatus => x_returnStatus,
                                  x_errorMsg => x_errorMsg);
      if ( x_returnStatus <> fnd_api.g_ret_sts_success ) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
     end if; --End of check on p_allowExplosion.
      if ( p_schedulingMethod = wip_constants.routing ) then
        wip_infinite_scheduler_pvt.schedule(
            p_orgID => p_orgID,
            p_wipEntityID => p_wipEntityID,
            p_startDate => p_startDate,
            p_endDate => p_endDate,
	           p_quantity => p_qty,
            x_returnStatus => x_returnStatus,
            x_errorMsg => x_errorMsg);
        if ( x_returnStatus <> fnd_api.g_ret_sts_success ) then
          raise fnd_api.g_exc_unexpected_error;
        end if;
      else
        -- Added for Bug 8463132.
        if ( p_schedulingMethod = wip_constants.leadtime ) then
          select wdj.scheduled_start_date
          into l_startDate
          from wip_discrete_jobs wdj
          where wdj.organization_id = p_orgID
            and wdj.wip_entity_id = p_wipEntityID;
        end if;

        update wip_operations
           set first_unit_start_date = p_startDate,
               first_unit_completion_date = p_startDate,
               last_unit_start_date = p_startDate,
               last_unit_completion_date = p_startDate
         where organization_id = p_orgID
           and wip_entity_id = p_wipEntityID;

        update wip_operation_resources
           set start_date = p_startDate,
               completion_date = p_startDate
         where organization_id = p_orgID
           and wip_entity_id = p_wipEntityID;

        update wip_sub_operation_resources
           set start_date = p_startDate,
               completion_date = p_startDate
         where organization_id = p_orgID
           and wip_entity_id = p_wipEntityID;

        -- need to adjust the data required field
        update wip_requirement_operations wro
           set wro.date_required = (select nvl(max(wo.first_unit_start_date),l_startDate)
                                   from wip_operations wo
                                  where wo.organization_id = wro.organization_id
                                    and wo.wip_entity_id = wro.wip_entity_id
                                    and wo.operation_seq_num = abs(wro.operation_seq_num))
        where wro.wip_entity_id = p_wipEntityID
          and wro.organization_id = p_orgID;
      end if;

    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
    end if;
  exception
  when others then
    x_returnStatus := fnd_api.g_ret_sts_unexp_error;
    fnd_msg_pub.add_exc_msg(p_pkg_name => g_pkgName,
                            p_procedure_name => l_procName,
                            p_error_text => x_errorMsg);
    if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => g_pkgName || '.' || l_procName,
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => x_errorMsg,
                             x_returnStatus     => l_retStatus);
    end if;
  end reexplodeJob;

end wip_bomRouting_pvt;

/
