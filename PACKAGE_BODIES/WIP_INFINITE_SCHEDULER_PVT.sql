--------------------------------------------------------
--  DDL for Package Body WIP_INFINITE_SCHEDULER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_INFINITE_SCHEDULER_PVT" as
/* $Header: wipiscdb.pls 120.6.12010000.2 2010/02/16 18:35:25 hliew ship $ */

  --private types
  type num_tbl_t is table of number;
  type date_tbl_t is table of date;


  --package constants
  g_logDateFmt CONSTANT VARCHAR2(30) := 'HH24:MI:SS MM/DD/YYYY';


  --private procedures

  --reads in job ops and resources (and locks the records)
  -- Fixed bug 5440007
  -- Added a new parameter p_quantity
  procedure readJobSchedule(p_wipEntityID NUMBER,
                            p_repSchedID NUMBER := null,
                            p_orgID NUMBER,
                            p_minOpSeqNum NUMBER,
                            p_minSchedSeqNum NUMBER,
                            p_maxOpSeqNum NUMBER,
                            p_maxSchedSeqNum NUMBER,
			    p_quantity  NUMBER := null,   --- Fixed bug 5440007
                            x_resTbls out nocopy wip_infResSched_grp.op_res_rectbl_t,
                            x_assignedUnits out nocopy num_tbl_t,
                            x_returnStatus out nocopy varchar2);

  --writes out job op dates and resource dates
  procedure writeJobSchedule(p_wipEntityID NUMBER,
                             p_repSchedID NUMBER := null,
                             p_orgID NUMBER,
                             p_schedMethod NUMBER,
                             p_minOpSeqNum NUMBER,
                             p_minSchedSeqNum NUMBER,
                             p_maxOpSeqNum NUMBER,
                             p_maxSchedSeqNum NUMBER,
                             p_anchorDate in date,
                             p_assignedUnits in num_tbl_t,
                             x_resTbls in out nocopy wip_infResSched_grp.op_res_rectbl_t,
                             x_returnStatus out nocopy varchar2);

  procedure getMidPointInfo(p_midPntOpSeqNum   IN NUMBER,
                            p_midPntResSeqNum  IN NUMBER,
                            p_subGrpNum        IN NUMBER,
                            p_schedMethod      IN NUMBER,
                            p_wipEntityID      IN NUMBER,
                            p_orgID            IN NUMBER,
                            x_minOpSeqNum     OUT NOCOPY NUMBER,
                            x_minSchedSeqNum  OUT NOCOPY NUMBER,
                            x_maxOpSeqNum     OUT NOCOPY NUMBER,
                            x_maxSchedSeqNum  OUT NOCOPY NUMBER);


  -- Fixed bug 5440007
  -- Added a new parameter p_quantity to the schedule api
  -- As of now, wip massload code path will pass this value
  procedure schedule(p_initMsgList IN VARCHAR2 := null,
                     p_endDebug IN VARCHAR2 := null,
                     p_orgID IN NUMBER,
                     p_wipEntityID IN NUMBER,
                     p_repSchedID IN NUMBER := null,
                     p_startDate IN DATE := null,
                     p_endDate IN DATE := null,
                     p_midPntMethod IN NUMBER := null,
                     p_opSeqNum IN NUMBER := null,
                     p_resSeqNum IN NUMBER := null,
                     p_subGrpNum IN NUMBER := null,
		     p_quantity  IN NUMBER := null,  -- Fix bug 5440007
                     x_returnStatus OUT NOCOPY VARCHAR2,
                     x_errorMsg OUT NOCOPY VARCHAR2) is
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_params wip_logger.param_tbl_t;
    l_retStatus VARCHAR2(1);
    l_resTbls wip_infResSched_grp.op_res_rectbl_t;
    l_repLineID NUMBER;
    l_assignedUnits num_tbl_t;
    l_minOpSeqNum NUMBER;
    l_minSchedSeqNum NUMBER;
    l_maxOpSeqNum NUMBER;
    l_maxSchedSeqNum NUMBER;
    l_schedMethod NUMBER;
  begin
    savepoint wipiscdb0;
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_orgID';
      l_params(1).paramValue := p_orgID;
      l_params(2).paramName := 'p_wipEntityID';
      l_params(2).paramValue := p_wipEntityID;
      l_params(3).paramName := 'p_repSchedID';
      l_params(3).paramValue := p_repSchedID;
      l_params(4).paramName := 'p_startDate';
      l_params(4).paramValue := to_char(p_startDate, g_logDateFmt);
      l_params(5).paramName := 'p_endDate';
      l_params(5).paramValue := to_char(p_endDate, g_logDateFmt);
      l_params(6).paramName := 'p_midPntMethod';
      l_params(6).paramValue := p_midPntMethod;
      l_params(7).paramName := 'p_opSeqNum';
      l_params(7).paramValue := p_opSeqNum;
      l_params(8).paramName := 'p_resSeqNum';
      l_params(8).paramValue := p_resSeqNum;
      l_params(9).paramName := 'p_subGrpNum';
      l_params(9).paramValue := p_subGrpNum;
      l_params(10).paramName := 'p_quantity';
      l_params(10).paramValue := p_quantity;

      wip_logger.entryPoint(p_procName     => 'wip_infinite_scheduler_pvt.schedule',
                            p_params       => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;
    x_returnStatus := fnd_api.g_ret_sts_success;

    if(fnd_api.to_boolean(nvl(p_initMsgList, fnd_api.g_true))) then
      fnd_msg_pub.initialize;
    end if;

    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('reading job/schedule...', l_retStatus);
    end if;
    if(p_midPntMethod is not null) then
      l_schedMethod := p_midPntMethod;
    elsif(p_opSeqNum is not null) then
      l_schedMethod := wip_constants.midpoint;
    elsif(p_startDate is not null) then
      l_schedMethod := wip_constants.forwards;
    else
      l_schedMethod := wip_constants.backwards;
    end if;

    getMidPointInfo(p_midPntOpSeqNum  => p_opSeqNum,
                    p_midPntResSeqNum => p_resSeqNum,
                    p_subGrpNum       => p_subGrpNum,
                    p_schedMethod     => l_schedMethod,
                    p_wipEntityID     => p_wipEntityID,
                    p_orgID           => p_orgID,
                    x_minOpSeqNum     => l_minOpSeqNum,
                    x_minSchedSeqNum  => l_minSchedSeqNum,
                    x_maxOpSeqNum     => l_maxOpSeqNum,
                    x_maxSchedSeqNum    => l_maxSchedSeqNum);

    -- Fixed bug 5440007
    -- Started passing new parameter p_quantity
    readJobSchedule(p_wipEntityID    => p_wipEntityID,
                    p_repSchedID     => p_repSchedID,
                    p_orgID          => p_orgID,
                    p_minOpSeqNum    => l_minOpSeqNum,
                    p_minSchedSeqNum => l_minSchedSeqNum,
                    p_maxOpSeqNum    => l_maxOpSeqNum,
                    p_maxSchedSeqNum => l_maxSchedSeqNum,
		    p_quantity       => p_quantity,   --- fixed bug 5440007
                    x_resTbls        => l_resTbls,
                    x_assignedUnits  => l_assignedUnits,
                    x_returnStatus   => x_returnStatus);

    if(x_returnStatus <> fnd_api.g_ret_sts_success) then
      raise fnd_api.g_exc_unexpected_error;
    end if;
/*
    if(p_repSchedID is not null) then
      select line_id
        into l_repLineID
        from wip_repetitive_schedules
       where repetitive_schedule_id = p_repSchedID;
    end if;
*/
    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('scheduling job/schedule...', l_retStatus);
    end if;

    wip_infResSched_grp.schedule(p_orgID        => p_orgID,
--                               p_repLineID    => l_repLineID,
                                 p_startDate    => p_startDate,
                                 p_endDate      => p_endDate,
                                 p_opSeqNum     => p_opSeqNum,
                                 p_resSeqNum    => p_resSeqNum,
                                 p_endDebug     => fnd_api.g_false,
                                 x_resTbls      => l_resTbls,
                                 x_returnStatus => x_returnStatus);
    if(x_returnStatus <> fnd_api.g_ret_sts_success) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('writing job/schedule...', l_retStatus);
    end if;

    writeJobSchedule(p_wipEntityID     => p_wipEntityID,
                     p_repSchedID      => p_repSchedID,
                     p_orgID           => p_orgID,
                     p_schedMethod     => l_schedMethod,
                     p_minOpSeqNum     => l_minOpSeqNum,
                     p_minSchedSeqNum  => l_minSchedSeqNum,
                     p_maxOpSeqNum     => l_maxOpSeqNum,
                     p_maxSchedSeqNum  => l_maxSchedSeqNum,
                     p_anchorDate      => nvl(p_startDate, p_endDate),
                     p_assignedUnits   => l_assignedUnits,
                     x_resTbls         => l_resTbls,
                     x_returnStatus    => x_returnStatus);

    if(x_returnStatus <> fnd_api.g_ret_sts_success) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infinite_scheduler_pvt.schedule',
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
      if(fnd_api.to_boolean(nvl(p_endDebug, fnd_api.g_true))) then
        wip_logger.cleanup(l_retStatus);
      end if;
    end if;
  exception
    when fnd_api.g_exc_unexpected_error then
      rollback to wipiscdb0;
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      wip_utilities.get_message_stack(p_msg => x_errorMsg,
                                      p_delete_stack => fnd_api.g_false);
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infinite_scheduler_pvt.schedule',
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'error: ' || x_errorMsg,
                           x_returnStatus     => l_retStatus);
      if(fnd_api.to_boolean(nvl(p_endDebug, fnd_api.g_true))) then
        wip_logger.cleanup(l_retStatus);
      end if;
    end if;

    when others then
      rollback to wipiscdb0;
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_infinite_scheduler_pvt',
                              p_procedure_name => 'schedule',
                              p_error_text => SQLERRM);
      wip_utilities.get_message_stack(p_msg => x_errorMsg,
                                      p_delete_stack => fnd_api.g_false);
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infinite_scheduler_pvt.schedule',
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'unexp error: ' || x_errorMsg,
                           x_returnStatus     => l_retStatus);
      if(fnd_api.to_boolean(nvl(p_endDebug, fnd_api.g_true))) then
        wip_logger.cleanup(l_retStatus);
      end if;
    end if;
  end schedule;

  procedure getMidPointInfo(p_midPntOpSeqNum   IN NUMBER,
                            p_midPntResSeqNum  IN NUMBER,
                            p_subGrpNum        IN NUMBER,
                            p_schedMethod      IN NUMBER,
                            p_wipEntityID      IN NUMBER,
                            p_orgID            IN NUMBER,
                            x_minOpSeqNum     OUT NOCOPY NUMBER,
                            x_minSchedSeqNum  OUT NOCOPY NUMBER,
                            x_maxOpSeqNum     OUT NOCOPY NUMBER,
                            x_maxSchedSeqNum  OUT NOCOPY NUMBER) is
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_params wip_logger.param_tbl_t;
    l_retStatus VARCHAR2(1);
  begin
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_midPntOpSeqNum';
      l_params(1).paramValue := p_midPntOpSeqNum;
      l_params(2).paramName := 'p_midPntResSeqNum';
      l_params(2).paramValue := p_midPntResSeqNum;
      l_params(3).paramName := 'p_subGrpNum';
      l_params(3).paramValue := p_subGrpNum;
      l_params(4).paramName := 'p_schedMethod';
      l_params(4).paramValue := p_schedMethod;
      l_params(5).paramName := 'p_wipEntityID';
      l_params(5).paramValue := p_wipEntityID;
      l_params(6).paramName := 'p_orgID';
      l_params(6).paramValue := p_orgID;
      wip_logger.entryPoint(p_procName     => 'wip_infinite_scheduler_pvt.getMidPointInfo',
                            p_params       => l_params,
                            x_returnStatus => l_retStatus);
    end if;

    if(p_schedMethod in (wip_constants.forwards,
                         wip_constants.backwards,
                         wip_constants.midpoint)) then

      if(l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('entire job reschedule', l_retStatus);
      end if;

      select min(operation_seq_num),
             max(operation_seq_num)
        into x_minOpSeqNum,
             x_maxOpSeqNum
        from wip_operations
       where wip_entity_id = p_wipEntityID
         and organization_id = p_orgID;

    elsif(p_schedMethod = wip_constants.midpoint_forwards) then

      if(l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('midpoint forward', l_retStatus);
      end if;

      x_minOpSeqNum := p_midPntOpSeqNum;

      if (p_midPntOpSeqNum is not null AND
          p_midPntResSeqNum is not null) then
        select nvl(schedule_seq_num, resource_seq_num)
          into x_minSchedSeqNum
          from wip_operation_resources
         where wip_entity_id = p_wipEntityID
          and organization_id = p_orgID
          and operation_seq_num = p_midPntOpSeqNum
          and resource_seq_num = p_midPntResSeqNum;
      else
        x_minSchedSeqNum := null;
      end if;

      select max(operation_seq_num)
        into x_maxOpSeqNum
        from wip_operations
       where wip_entity_id = p_wipEntityID
         and organization_id = p_orgID;

      select max(nvl(schedule_seq_num, resource_seq_num))
        into x_maxSchedSeqNum
        from wip_operation_resources
       where wip_entity_id = p_wipEntityID
         and organization_id = p_orgID
         and operation_seq_num = x_maxOpSeqNum;

    elsif(p_schedMethod = wip_constants.midpoint_backwards) then
      x_maxOpSeqNum := p_midPntOpSeqNum;

      if (p_midPntOpSeqNum is not null AND
          p_midPntResSeqNum is not null) then
        select nvl(schedule_seq_num, resource_seq_num)
          into x_maxSchedSeqNum
          from wip_operation_resources
          where wip_entity_id = p_wipEntityID
          and organization_id = p_orgID
          and operation_seq_num = p_midPntOpSeqNum
          and resource_seq_num = p_midPntResSeqNum;
      else
        x_maxSchedSeqNum := null;
      end if;

      if(l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('midpoint backward', l_retStatus);
      end if;

      select min(operation_seq_num)
        into x_minOpSeqNum
        from wip_operations
       where wip_entity_id = p_wipEntityID
         and organization_id = p_orgID;

      select min(nvl(schedule_seq_num, resource_seq_num))
        into x_minSchedSeqNum
        from wip_operation_resources
       where wip_entity_id = p_wipEntityID
         and organization_id = p_orgID
         and operation_seq_num = x_minOpSeqNum;
    elsif(p_schedMethod = wip_constants.current_op) then

      if(l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('current op', l_retStatus);
      end if;

      x_minOpSeqNum := p_midPntOpSeqNum;
      x_maxOpSeqNum := p_midPntOpSeqNum;
      select min(nvl(schedule_seq_num, resource_seq_num)), max(nvl(schedule_seq_num, resource_seq_num))
        into x_minSchedSeqNum, x_maxSchedSeqNum
        from wip_operation_resources
       where wip_entity_id = p_wipEntityID
         and organization_id = p_orgID
         and operation_seq_num = p_midPntOpSeqNum;
    elsif(p_schedMethod = wip_constants.current_sub_grp) then

      if(l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('current sub grp', l_retStatus);
      end if;

      x_minOpSeqNum := p_midPntOpSeqNum;
      x_maxOpSeqNum := p_midPntOpSeqNum;

      select min(nvl(schedule_seq_num, resource_seq_num)), max(nvl(schedule_seq_num, resource_seq_num))
        into x_minSchedSeqNum, x_maxSchedSeqNum
        from wip_operation_resources
       where wip_entity_id = p_wipEntityID
         and organization_id = p_orgID
         and operation_seq_num = p_midPntOpSeqNum
         and substitute_group_num = p_subGrpNum;
    else --current op resource

      if(l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('current op res', l_retStatus);
      end if;

      x_minOpSeqNum := p_midPntOpSeqNum;
      x_maxOpSeqNum := p_midPntOpSeqNum;

      if (p_midPntOpSeqNum is not null AND
          p_midPntResSeqNum is not null) then
        select nvl(schedule_seq_num, resource_seq_num)
          into x_minSchedSeqNum
          from wip_operation_resources
          where wip_entity_id = p_wipEntityID
          and organization_id = p_orgID
          and operation_seq_num = p_midPntOpSeqNum
          and resource_seq_num = p_midPntResSeqNum;
      else
        x_minSchedSeqNum := null;
      end if;

      x_maxSchedSeqNum := x_minSchedSeqNum;
    end if;

    if(l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('min op seq' || x_minOpSeqNum, l_retStatus);
      wip_logger.log('min sched seq' || x_minSchedSeqNum, l_retStatus);
      wip_logger.log('max op seq' || x_maxOpSeqNum, l_retStatus);
      wip_logger.log('max sched seq' || x_maxSchedSeqNum, l_retStatus);
    end if;

    if(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infinite_scheduler_pvt.schedule',
                           p_procReturnStatus => 'N/A',
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
    end if;
  end getMidPointInfo;


  -- Fixed bug 5440007
  -- Added a new parameter p_quantity

  procedure readJobSchedule(p_wipEntityID in number,
                            p_repSchedID in number := null,
                            p_orgID in number,
                            p_minOpSeqNum in number,
                            p_minSchedSeqNum in number,
                            p_maxOpSeqNum in number,
                            p_maxSchedSeqNum in number,
			    p_quantity       IN NUMBER := null, -- Fixed bug 5440007
                            x_resTbls out nocopy wip_infResSched_grp.op_res_rectbl_t,
                            x_assignedUnits out nocopy num_tbl_t,
                            x_returnStatus out nocopy varchar2) is
    l_loglevel NUMBER := fnd_log.g_current_runtime_level;
    l_params wip_logger.param_tbl_t;
    l_retStatus VARCHAR2(1);
    l_hrUOM VARCHAR2(3);
    l_hrVal NUMBER;
    l_uomClass VARCHAR2(10);
    l_dummy NUMBER;

    --the following cursors simply lock the records writeJobSchedule() will later modify
    cursor c_job is
      select 1
        from wip_discrete_jobs
       where wip_entity_id = p_wipEntityID
         and organization_id = p_orgID
         for update nowait;

    cursor c_ops is
      select 1
        from wip_operations
       where wip_entity_id = p_wipEntityID
         and organization_id = p_orgID
         and operation_seq_num between p_minOpSeqNum and p_maxOpSeqNum
         for update nowait;

    cursor c_mtlReqs is
      select 1
        from wip_requirement_operations
       where wip_entity_id = p_wipEntityID
         and organization_id = p_orgID
         and operation_seq_num between p_minOpSeqNum and p_maxOpSeqNum
         for update nowait;

    cursor c_resUsgs is
      select 1
        from wip_operation_resource_usage woru,
             wip_operation_resources wor
       where wor.wip_entity_id = p_wipEntityID
         and wor.organization_id = p_orgID
         and (    wor.operation_seq_num < p_maxOpSeqNum
              and wor.operation_seq_num > p_minOpSeqNum
              or (    p_minOpSeqNum <> p_maxOpSeqNum
                  and wor.operation_seq_num = p_minOpSeqNum
                  and nvl(wor.schedule_seq_num, wor.resource_seq_num) >= nvl(p_minSchedSeqNum, nvl(wor.schedule_seq_num, wor.resource_seq_num))
                 )
              or (    p_minOpSeqNum <> p_maxOpSeqNum
                  and wor.operation_seq_num = p_maxOpSeqNum
                  and nvl(wor.schedule_seq_num, wor.resource_seq_num) <= nvl(p_maxSchedSeqNum, nvl(wor.schedule_seq_num, wor.resource_seq_num))
                 )
              or (    p_minOpSeqNum = p_maxOpSeqNum
                  and wor.operation_seq_num = p_maxOpSeqNum
                  and nvl(wor.schedule_seq_num, wor.resource_seq_num) between nvl(p_minSchedSeqNum, nvl(wor.schedule_seq_num, wor.resource_seq_num)) and nvl(p_maxSchedSeqNum, nvl(wor.schedule_seq_num, wor.resource_seq_num))
                 )
             )
         and woru.organization_id = wor.organization_id
         and woru.wip_entity_id = wor.wip_entity_id
         and woru.operation_seq_num = wor.operation_seq_num
         and woru.resource_seq_num = wor.resource_seq_num
         for update nowait;

    cursor c_resInsts is
      select 1
        from wip_op_resource_instances wori,
             wip_operation_resources wor
       where wor.wip_entity_id = p_wipEntityID
         and wor.organization_id = p_orgID
         and (    wor.operation_seq_num < p_maxOpSeqNum
              and wor.operation_seq_num > p_minOpSeqNum
              or (    p_minOpSeqNum <> p_maxOpSeqNum
                  and wor.operation_seq_num = p_minOpSeqNum
                  and nvl(wor.schedule_seq_num, wor.resource_seq_num) >= nvl(p_minSchedSeqNum, nvl(wor.schedule_seq_num, wor.resource_seq_num))
                 )
              or (    p_minOpSeqNum <> p_maxOpSeqNum
                  and wor.operation_seq_num = p_maxOpSeqNum
                  and nvl(wor.schedule_seq_num, wor.resource_seq_num) <= nvl(p_maxSchedSeqNum, nvl(wor.schedule_seq_num, wor.resource_seq_num))
                 )
              or (    p_minOpSeqNum = p_maxOpSeqNum
                  and wor.operation_seq_num = p_maxOpSeqNum
                  and nvl(wor.schedule_seq_num, wor.resource_seq_num) between nvl(p_minSchedSeqNum, nvl(wor.schedule_seq_num, wor.resource_seq_num)) and nvl(p_maxSchedSeqNum, nvl(wor.schedule_seq_num, wor.resource_seq_num))
                 )
             )
         and wori.organization_id = wor.organization_id
         and wori.wip_entity_id = wor.wip_entity_id
         and wori.operation_seq_num = wor.operation_seq_num
         and wori.resource_seq_num = wor.resource_seq_num
         for update nowait;
  begin

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_wipEntityID';
      l_params(1).paramValue := p_wipEntityID;
      l_params(2).paramName := 'p_repSchedID';
      l_params(2).paramValue := p_repSchedID;
      l_params(3).paramName := 'p_orgID';
      l_params(3).paramValue := p_orgID;
      l_params(4).paramName := 'p_minOpSeqNum';
      l_params(4).paramValue := p_minOpSeqNum;
      l_params(5).paramName := 'p_minSchedSeqNum';
      l_params(5).paramValue := p_minSchedSeqNum;
      l_params(6).paramName := 'p_maxOpSeqNum';
      l_params(6).paramValue := p_maxOpSeqNum;
      l_params(7).paramName := 'p_maxSchedSeqNum';
      l_params(7).paramValue := p_maxSchedSeqNum;
      l_params(8).ParamName  := 'P_quantity';
      l_params(8).ParamValue := p_quantity;

      wip_logger.entryPoint(p_procName     => 'wip_infinite_scheduler_pvt.readJobSchedule',
                            p_params       => l_params,
                            x_returnStatus => l_retStatus);
    end if;
    x_returnStatus := fnd_api.g_ret_sts_success;

    l_hrUOM := fnd_profile.value('BOM:HOUR_UOM_CODE');
    select conversion_rate, uom_class
      into l_hrVal, l_uomClass
      from mtl_uom_conversions
     where uom_code = l_hrUOM
       and nvl(disable_date, sysdate + 1) > sysdate
       and inventory_item_id = 0;

    --Fix for bug#4888567
       --UOM conversion from Resource UOM to HOUR UOM was not properly done
       --  Using the standard function inv_convert.inv_um_convert to convert
       --  between resource UOM and standard HR uom code received from BOM profile value.


    -- Fixed bug 5440007
    -- Added decode clause to derive the quantity from wip_discrete_jobs only if the parameter
    -- p_quantity is null
    select wor.operation_seq_num,
           wor.resource_id,
           nvl(bdr.share_from_dept_id, bdr.department_id),
           wor.resource_seq_num,
           wor.schedule_seq_num,
           wor.scheduled_flag,
           bdr.available_24_hours_flag,
           --l_hrVal * nvl(muc.conversion_rate,0) *
           --Bug 4614036:Rounding of usage rate to next minute is handled.
/*
           round((decode(wor.basis_type, wip_constants.per_lot, 1, decode(p_quantity,null,wdj.start_quantity,p_quantity)) *
           inv_convert.inv_um_convert(0,
                             NULL,
                             wor.usage_rate_or_amount,
                             wor.UOM_CODE,
                             l_hrUOM,
                             NULL,
                             NULL )),0)
--                             NULL )*60)+0.5,0) --Fixed bug #5618787
                                      / (
--                                       60*24 * least(wor.assigned_units, bdr.capacity_units) * --Fixed bug #5618787
                                       24 * least(wor.assigned_units, bdr.capacity_units) *
                                       decode(wp.include_resource_utilization,
                                              wip_constants.yes, nvl(bdr.utilization, 1), 1) *
                                       decode(wp.include_resource_efficiency,
                                              wip_constants.yes, nvl(bdr.efficiency, 1), 1)
                                      ),
*/
           -- Start of fix for Bug #5657612: Use ceil function to round up the usage rate to next minute
           -- bug 6741020: pass a precision = 6 to inv_um_convert as resource usage form field
           -- supports 6 decimals. INV assumes a default of 5 decimals if null is passed. This causes
           -- errors in calculation.
           ceil((decode(wor.basis_type, wip_constants.per_lot, 1, decode(p_quantity,null,wdj.start_quantity,p_quantity)) *
           inv_convert.inv_um_convert(0,
                             6,
                             wor.usage_rate_or_amount,
                             wor.UOM_CODE,
                             l_hrUOM,
                             NULL,
                             NULL )*60) /
							 ( least(wor.assigned_units, bdr.capacity_units) *
                                       decode(wp.include_resource_utilization,
                                              wip_constants.yes, nvl(bdr.utilization, 1), 1) *
                                       decode(wp.include_resource_efficiency,
                                              wip_constants.yes, nvl(bdr.efficiency, 1), 1) )
							 ) / (60 * 24),
           -- End of fix for Bug #5657612
           wor.assigned_units
      bulk collect into x_resTbls.opSeqNum,
                        x_resTbls.resID,
                        x_resTbls.deptID,
                        x_resTbls.resSeqNum,
                        x_resTbls.schedSeqNum,
                        x_resTbls.schedFlag,
                        x_resTbls.avail24Flag,
                        x_resTbls.totalDaysUsg,
                        x_assignedUnits
      from wip_discrete_jobs wdj,
           wip_operations wo,
           wip_operation_resources wor,
           mtl_uom_conversions muc,
           bom_department_resources bdr,
           wip_parameters wp
     where wp.organization_id = wdj.organization_id
       and wdj.wip_entity_id = p_wipEntityID
       and wdj.organization_id = p_orgID
       and wdj.wip_entity_id = wo.wip_entity_id
       and wdj.organization_id = wo.organization_id
       and wo.wip_entity_id = wor.wip_entity_id
       and wo.organization_id = wor.organization_id
       and wo.operation_seq_num = wor.operation_seq_num
       and bdr.resource_id = wor.resource_id
       and bdr.department_id = nvl(wor.department_id, wo.department_id)
       and wor.uom_code = muc.uom_code (+)
       and muc.uom_class (+)= l_uomClass
       and muc.inventory_item_id (+)= 0
       and (
            (    wor.operation_seq_num < p_maxOpSeqNum
             and wor.operation_seq_num > p_minOpSeqNum
            )
              or (    p_minOpSeqNum <> p_maxOpSeqNum
                  and wor.operation_seq_num = p_minOpSeqNum
                  and nvl(wor.schedule_seq_num, wor.resource_seq_num) >= nvl(p_minSchedSeqNum, nvl(wor.schedule_seq_num, wor.resource_seq_num))
                 )
              or (    p_minOpSeqNum <> p_maxOpSeqNum
                  and wor.operation_seq_num = p_maxOpSeqNum
                  and nvl(wor.schedule_seq_num, wor.resource_seq_num) <= nvl(p_maxSchedSeqNum, nvl(wor.schedule_seq_num, wor.resource_seq_num))
                 )
              or (    p_minOpSeqNum = p_maxOpSeqNum
                  and wor.operation_seq_num = p_maxOpSeqNum
                  and nvl(wor.schedule_seq_num, wor.resource_seq_num) between nvl(p_minSchedSeqNum, nvl(wor.schedule_seq_num, wor.resource_seq_num)) and nvl(p_maxSchedSeqNum, nvl(wor.schedule_seq_num, wor.resource_seq_num))
                 )
           )
       order by wor.operation_seq_num, nvl(wor.schedule_seq_num, wor.resource_seq_num)
       for update of wor.start_date nowait;

    --lock the job
    open c_job;
    close c_job;

    --lock the routing
    open c_ops;
    close c_ops;
    --lock the BOM
    open c_mtlReqs;
    close c_mtlReqs;

    --lock the usages (will be deleted later)
    open c_resUsgs;
    close c_resUsgs;

    --lock the resource instances
    open c_resInsts;
    close c_resInsts;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infinite_scheduler_pvt.readJobSchedule',
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
    end if;
  exception
   /*Fix bug 8914181 (FP 8894732)*/
    when wip_constants.records_locked then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_infinite_scheduler_pvt.readJobSchedule',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'records were locked',
                             x_returnStatus => l_retStatus);
      end if;
      fnd_message.set_name('WIP', 'WIP_LOCKED_ROW_ALREADY_LOCKED');
      fnd_msg_pub.add;
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_infinite_scheduler_pvt',
                              p_procedure_name => 'readJobSchedule',
                              p_error_text => SQLERRM);
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => 'wip_infinite_scheduler_pvt.readJobSchedule',
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'unexp error: ' || SQLERRM,
                             x_returnStatus     => l_retStatus);
      end if;
  end readJobSchedule;

  procedure writeJobSchedule(p_wipEntityID     in number,
                             p_repSchedID      in number := null,
                             p_orgID           in number,
                             p_schedMethod     in number,
                             p_minOpSeqNum     in number,
                             p_minSchedSeqNum  in number,
                             p_maxOpSeqNum     in number,
                             p_maxSchedSeqNum  in number,
                             p_anchorDate      in date,
                             p_assignedUnits   in num_tbl_t,
                             x_resTbls         in out nocopy wip_infResSched_grp.op_res_rectbl_t,
                             x_returnStatus   out nocopy varchar2) is
    type op_rectbl_t is record (opSeqNum  num_tbl_t,
                                startDate date_tbl_t,
                                endDate   date_tbl_t);


    l_opTbls op_rectbl_t;
    l_opSchYesTbls op_rectbl_t;
    l_startOpIdx NUMBER;
    l_endOpIdx NUMBER;

    --standard who columns
    l_sysDate DATE := sysdate;
    l_userID NUMBER := fnd_global.user_id;
    l_loginID NUMBER := fnd_global.login_id;
    l_reqID NUMBER := fnd_global.conc_request_id;
    l_progApplID NUMBER := fnd_global.prog_appl_id;
    l_progID NUMBER := fnd_global.conc_program_id;
    l_minResStartDate DATE;
    l_maxResEndDate DATE;
    l_jobStartDate DATE;
    l_jobCplDate DATE;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_params wip_logger.param_tbl_t;
    l_retStatus VARCHAR2(1);
  begin
    savepoint wipiscdb100;
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_wipEntityID';
      l_params(1).paramValue := p_wipEntityID;
      l_params(2).paramName := 'p_repSchedID';
      l_params(2).paramValue := p_repSchedID;
      l_params(3).paramName := 'p_orgID';
      l_params(3).paramValue := p_orgID;
      l_params(4).paramName := 'p_schedMethod';
      l_params(4).paramValue := p_schedMethod;
      l_params(5).paramName := 'p_minOpSeqNum';
      l_params(5).paramValue := p_minOpSeqNum;
      l_params(6).paramName := 'p_minSchedSeqNum';
      l_params(6).paramValue := p_minSchedSeqNum;
      l_params(7).paramName := 'p_maxOpSeqNum';
      l_params(7).paramValue := p_maxOpSeqNum;
      l_params(8).paramName := 'p_maxSchedSeqNum';
      l_params(8).paramValue := p_maxSchedSeqNum;
      l_params(9).paramName := 'p_anchorDate';
      l_params(9).paramValue := to_char(p_anchorDate, g_logDateFmt);
      for i in 1..p_assignedUnits.count loop
        l_params(9+i).paramName := 'p_assignedUnits(' || i || ')';
        l_params(9+i).paramValue := p_assignedUnits(i);
      end loop;
      wip_logger.entryPoint(p_procName     => 'wip_infinite_scheduler_pvt.writeJobSchedule',
                            p_params       => l_params,
                            x_returnStatus => l_retStatus);
    end if;
    x_returnStatus := fnd_api.g_ret_sts_success;

    --update resources
    forall i in 1..x_resTbls.resID.count
      update wip_operation_resources
         set start_date = x_resTbls.startDate(i),
             completion_date = x_resTbls.endDate(i),
             last_update_date = l_sysdate,
             last_updated_by = l_userID,
             last_update_login = l_loginID,
             request_id = l_reqID,
             program_application_id = l_progApplID,
             program_id = l_progID,
             program_update_date = l_sysDate
       where wip_entity_id = p_wipEntityID
         and organization_id = p_orgID
         and operation_seq_num = x_resTbls.opSeqNum(i)
         and resource_seq_num = x_resTbls.resSeqNum(i);

    if(l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('wrote resources', l_retStatus);
    end if;


    forall i in 1..x_resTbls.resID.count
      update wip_op_resource_instances
         set start_date = x_resTbls.startDate(i),
             completion_date = x_resTbls.endDate(i),
             last_update_date = l_sysdate,
             last_updated_by = l_userID,
             last_update_login = l_loginID
       where wip_entity_id = p_wipEntityID
         and organization_id = p_orgID
         and operation_seq_num = x_resTbls.opSeqNum(i)
         and resource_seq_num = x_resTbls.resSeqNum(i);

    if(l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('wrote resource instances', l_retStatus);
    end if;

    delete wip_operation_resource_usage
     where (organization_id, wip_entity_id, operation_seq_num, resource_seq_num) in
        (select organization_id,
                wip_entity_id,
                operation_seq_num,
                resource_seq_num
           from wip_operation_resources wor
          where wor.wip_entity_id = p_wipEntityID
            and wor.organization_id = p_orgID
            and (    wor.operation_seq_num < p_maxOpSeqNum
              and wor.operation_seq_num > p_minOpSeqNum
              or (    p_minOpSeqNum <> p_maxOpSeqNum
                  and wor.operation_seq_num = p_minOpSeqNum
                  and nvl(wor.schedule_seq_num, wor.resource_seq_num) >= nvl(p_minSchedSeqNum, nvl(wor.schedule_seq_num, wor.resource_seq_num))
                 )
              or (    p_minOpSeqNum <> p_maxOpSeqNum
                  and wor.operation_seq_num = p_maxOpSeqNum
                  and nvl(wor.schedule_seq_num, wor.resource_seq_num) <= nvl(p_maxSchedSeqNum, nvl(wor.schedule_seq_num, wor.resource_seq_num))
                 )
              or (    p_minOpSeqNum = p_maxOpSeqNum
                  and wor.operation_seq_num = p_maxOpSeqNum
                  and nvl(wor.schedule_seq_num, wor.resource_seq_num) between nvl(p_minSchedSeqNum, nvl(wor.schedule_seq_num, wor.resource_seq_num)) and nvl(p_maxSchedSeqNum, nvl(wor.schedule_seq_num, wor.resource_seq_num))
                 )
             )
        );

    for i in 1..x_resTbls.resID.count loop
      if(x_resTbls.usgStartIdx(i) is not null) then
        forall j in x_resTbls.usgStartIdx(i)..x_resTbls.usgEndIdx(i)
            insert into wip_operation_resource_usage
              (wip_entity_id,
               operation_seq_num,
               resource_seq_num,
               organization_id,
               start_date,
               completion_date,
               assigned_units,
               cumulative_processing_time,
               last_update_date,
               last_updated_by,
               creation_date,
               created_by,
               last_update_login,
               request_id,
               program_application_id,
               program_id,
               program_update_date)
              values
              (p_wipEntityID,
               x_resTbls.opSeqNum(i),
               x_resTbls.resSeqNum(i),
               p_orgID,
               x_resTbls.usgStartDate(j),
               x_resTbls.usgEndDate(j),
               p_assignedUnits(i),
               x_resTbls.usgCumMinProcTime(j),
               l_sysdate,
               l_userID,
               l_sysdate,
               l_userID,
               l_loginID,
               l_reqID,
               l_progApplID,
               l_progID,
               l_sysdate);
      end if;
    end loop;
    if(l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('wrote resource usages', l_retStatus);
    end if;

    insert into wip_operation_resource_usage
      (wip_entity_id,
       operation_seq_num,
       resource_seq_num,
       organization_id,
       start_date,
       completion_date,
       assigned_units,
       instance_id,
       serial_number,
       cumulative_processing_time,
       last_update_date,
       last_updated_by,
       creation_date,
       created_by,
       last_update_login,
       request_id,
       program_application_id,
       program_id,
       program_update_date)
      select p_wipEntityID,
             woru.operation_seq_num,
             woru.resource_seq_num,
             p_orgID,
             woru.start_date,
             woru.completion_date,
             1,
             wori.instance_id,
             wori.serial_number,
             woru.cumulative_processing_time,
             l_sysdate,
             l_userID,
             l_sysdate,
             l_userID,
             l_loginID,
             l_reqID,
             l_progApplID,
             l_progID,
             l_sysdate
        from wip_operation_resource_usage woru,
             wip_op_resource_instances wori,
             wip_operation_resources wor
       where woru.wip_entity_id = wori.wip_entity_id
         and woru.operation_seq_num = wori.operation_seq_num
         and woru.resource_seq_num = wori.resource_seq_num
         and woru.organization_id = wori.organization_id
         and wor.wip_entity_id = p_wipEntityID
         and wor.organization_id = p_orgID
         and (    wor.operation_seq_num < p_maxOpSeqNum
              and wor.operation_seq_num > p_minOpSeqNum
              or (    p_minOpSeqNum <> p_maxOpSeqNum
                  and wor.operation_seq_num = p_minOpSeqNum
                  and nvl(wor.schedule_seq_num, wor.resource_seq_num) >= nvl(p_minSchedSeqNum, nvl(wor.schedule_seq_num, wor.resource_seq_num))
                 )
              or (    p_minOpSeqNum <> p_maxOpSeqNum
                  and wor.operation_seq_num = p_maxOpSeqNum
                  and nvl(wor.schedule_seq_num, wor.resource_seq_num) <= nvl(p_maxSchedSeqNum, nvl(wor.schedule_seq_num, wor.resource_seq_num))
                 )
              or (    p_minOpSeqNum = p_maxOpSeqNum
                  and wor.operation_seq_num = p_maxOpSeqNum
                  and nvl(wor.schedule_seq_num, wor.resource_seq_num) between nvl(p_minSchedSeqNum, nvl(wor.schedule_seq_num, wor.resource_seq_num)) and nvl(p_maxSchedSeqNum, nvl(wor.schedule_seq_num, wor.resource_seq_num))
                 )
             )
         and woru.organization_id = wor.organization_id
         and woru.wip_entity_id = wor.wip_entity_id
         and woru.operation_seq_num = wor.operation_seq_num
         and woru.resource_seq_num = wor.resource_seq_num;


    if(l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('wrote ' || SQL%ROWCOUNT || ' resource instance usages', l_retStatus);
    end if;

    if(l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('about to start op processing', l_retStatus);
    end if;
    --base operation dates off of op resource dates
    select wo.operation_seq_num,
           min(wor.start_date),
           max(wor.completion_date)
      bulk collect into
           l_opTbls.opSeqNum,
           l_opTbls.startDate,
           l_opTbls.endDate
      from wip_operations wo,
           wip_operation_resources wor
     where wo.wip_entity_id = p_wipEntityID
       and wo.organization_id = p_orgID
       and wo.wip_entity_id = wor.wip_entity_id (+)
       and wo.organization_id = wor.organization_id (+)
       and wo.operation_seq_num = wor.operation_seq_num (+)
     group by wo.operation_seq_num;

    select wo.operation_seq_num,
           min(wor.start_date),
           max(wor.completion_date)
      bulk collect into
           l_opSchYesTbls.opSeqNum,
           l_opSchYesTbls.startDate,
           l_opSchYesTbls.endDate
      from wip_operations wo,
           wip_operation_resources wor
     where wo.wip_entity_id = p_wipEntityID
       and wo.organization_id = p_orgID
       and wo.wip_entity_id = wor.wip_entity_id (+)
       and wo.organization_id = wor.organization_id (+)
       and wo.operation_seq_num = wor.operation_seq_num (+)
       and wip_constants.sched_yes = wor.scheduled_flag (+)
     group by wo.operation_seq_num;

    if(l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('about to start op processing', l_retStatus);
    end if;

    for i in 1..l_opTbls.opSeqNum.count loop
      if(l_opTbls.startDate(i) is null) then

        --look for previous operations with a yes resource
        if(i > 1) then
          for j in reverse 1..(i-1) loop
            if(l_opSchYesTbls.endDate(j) is not null) then
              l_opTbls.startDate(i) := l_opSchYesTbls.endDate(j);
              l_opTbls.endDate(i) := l_opTbls.startDate(i);
              exit;
            end if;
          end loop;
        end if;

        --if the date is still null, look for future ops with a yes resource
        if(l_opTbls.startDate(i) is null) then
          if(i < l_opTbls.opSeqNum.count) then
            for j in (i+1)..l_opTbls.opSeqNum.count loop
              if(l_opSchYesTbls.endDate(j) is not null) then
                l_opTbls.startDate(i) := l_opSchYesTbls.endDate(j);
                l_opTbls.endDate(i) := l_opSchYesTbls.endDate(j);
                exit;
              end if;
            end loop;
          end if;
        end if;

        --if the date is still null, this means that there are no scheduled yes
        --resources in the job.
        if(l_opTbls.startDate(i) is null) then
          l_opTbls.startDate(i) := p_anchorDate;
          l_opTbls.endDate(i) := p_anchorDate;
          for j in 1..x_resTbls.resID.count loop
            if(x_resTbls.opSeqNum(j) < l_opTbls.opSeqNum(i) and
               x_resTbls.schedFlag(j) = wip_constants.sched_prior) then
              l_opTbls.startDate(i) := x_resTbls.endDate(j);
              l_opTbls.endDate(i) := x_resTbls.endDate(j);
            else
              exit;
            end if;
          end loop;
        end if;

      end if;
    end loop;

    --determine which operations to update
    for i in 1..l_opTbls.opSeqNum.count loop
      if(l_opTbls.opSeqNum(i) = p_minOpSeqNum) then
        l_startOpIdx := i;
      end if;
      if(l_opTbls.opSeqNum(i) = p_maxOpSeqNum) then
        l_endOpIdx := i;
        exit;
      end if;
    end loop;

    if(l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('about to write ops', l_retStatus);
    end if;

    if(l_startOpIdx is not null) then
      forall i in l_startOpIdx..l_endOpIdx
        update wip_operations
           set first_unit_start_date = l_opTbls.startDate(i),
               last_unit_start_date = l_opTbls.startDate(i),
               first_unit_completion_date = l_opTbls.endDate(i),
               last_unit_completion_date = l_opTbls.endDate(i),
               last_update_date = l_sysdate,
               last_updated_by = l_userID,
               last_update_login = l_loginID,
               request_id = l_reqID,
               program_application_id = l_progApplID,
               program_id = l_progID,
               program_update_date = l_sysDate
         where wip_entity_id = p_wipEntityID
           and organization_id = p_orgID
           and operation_seq_num = l_opTbls.opSeqNum(i);
    if(l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('wrote ops', l_retStatus);
    end if;

      --update mtl requirement dates if job has routing
      forall i in l_startOpIdx..l_endOpIdx
        update wip_requirement_operations
           set date_required = l_opTbls.startDate(i),
               last_update_date = l_sysdate,
               last_updated_by = l_userID,
               last_update_login = l_loginID,
               request_id = l_reqID,
               program_application_id = l_progApplID,
               program_id = l_progID,
               program_update_date = l_sysDate
         where wip_entity_id = p_wipEntityID
           and organization_id = p_orgID
           and operation_seq_num = l_opTbls.opSeqNum(i);
    else
      --update mtl requirement dates if job doesn't have a routing
      update wip_requirement_operations
         set date_required = p_anchorDate,
             last_update_date = l_sysdate,
             last_updated_by = l_userID,
             last_update_login = l_loginID,
             request_id = l_reqID,
             program_application_id = l_progApplID,
             program_id = l_progID,
             program_update_date = l_sysDate
       where wip_entity_id = p_wipEntityID
         and organization_id = p_orgID
         and operation_seq_num = 1;
    end if;

    if(l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('wrote material requirements', l_retStatus);
    end if;

    --now update job dates
    --must select from table to get resource dates b/c of partial job scheduling
    select min(start_date), max(completion_date)
      into l_minResStartDate, l_maxResEndDate
      from wip_operation_resources
     where wip_entity_id = p_wipEntityID
       and organization_id = p_orgID;

    if(l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('min res date:' || to_char(l_minResStartDate, g_logDateFmt), l_retStatus);
      wip_logger.log('max res date:' || to_char(l_maxResEndDate, g_logDateFmt), l_retStatus);
    end if;
    --if there are no resources, set the local variables to p_anchorDate
    --so below update is correct.
    l_jobStartDate := nvl(l_minResStartDate, p_anchorDate);
    l_jobCplDate := nvl(l_maxResEndDate, p_anchorDate);

    update wip_discrete_jobs
      set scheduled_start_date = l_jobStartDate,
          scheduled_completion_date = l_jobCplDate,
          last_update_date = l_sysdate,
          last_updated_by = l_userID,
          last_update_login = l_loginID,
          request_id = l_reqID,
          program_application_id = l_progApplID,
          program_id = l_progID,
          program_update_date = l_sysDate
    where wip_entity_id = p_wipEntityID
      and organization_id = p_orgID;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infinite_scheduler_pvt.writeJobSchedule',
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
    end if;
  exception
    when others then
      rollback to wipiscdb100;
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_infinite_scheduler_pvt',
                              p_procedure_name => 'writeJobSchedule',
                              p_error_text => SQLERRM);
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => 'wip_infinite_scheduler_pvt.writeJobSchedule',
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'unexp error: ' || SQLERRM,
                             x_returnStatus     => l_retStatus);
      end if;
  end writeJobSchedule;


end wip_infinite_scheduler_pvt;

/
