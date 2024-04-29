--------------------------------------------------------
--  DDL for Package Body WIP_INFRESSCHED_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WIP_INFRESSCHED_GRP" as
/* $Header: wipinrsb.pls 120.2.12010000.6 2010/02/18 21:23:10 pding ship $ */

  --package constants
  g_dateCursorLen CONSTANT NUMBER := 10;--must be greater than or equal to 1
  g_precision CONSTANT NUMBER := 6;

  g_forward CONSTANT NUMBER := 0;
  g_backward CONSTANT NUMBER := 1;

  g_logDateFmt CONSTANT VARCHAR2(30) := 'HH24:MI:SS MM/DD/YYYY';
  --private types
  type op_rec_t is record(startDate date,
                          endDate date,
                          priorsExist boolean,
                          nextsExist boolean,
                          resStartIdx number,
                          resEndIdx number);

  type op_tbl_t is table of op_rec_t index by binary_integer;

  /* fix bug 7027946 */
  type shift_recTbl_t is record(shiftNum num_tbl_t,
                                startDate date_tbl_t,
                                endDate date_tbl_t);
  /* end of fix bug 7027946 */

  procedure buildOpStructure(p_resTbls in op_res_rectbl_t,
                             p_anchorDate in DATE,
                             x_opTbl out nocopy op_tbl_t);

  procedure findMdPntRes(p_resTbls IN OP_RES_RECTBL_T,
                         p_opSeqNum NUMBER,
                         p_resSeqNum NUMBER,
                         p_isMdPntFwd boolean,
                         x_midPntFwdIdx OUT NOCOPY NUMBER,
                         x_midPntBkwdIdx OUT NOCOPY NUMBER);

  --schedules prior resources when forward scheduling, or resource is
  --on or after the midpoint op when midpoint scheduling
  procedure schedulePriorResources(p_orgID IN NUMBER,
                                   p_repLineID NUMBER,
                                   p_opTbl in op_tbl_t,
                                   x_resTbls IN OUT NOCOPY OP_RES_RECTBL_T,
                                   x_returnStatus OUT NOCOPY VARCHAR2);

  --schedules next resources when backward scheduling, or resource is
  --on or before the midpoint op when midpoint scheduling
  procedure scheduleNextResources(p_orgID IN NUMBER,
                                  p_repLineID NUMBER,
                                  p_opTbl in op_tbl_t,
                                  x_resTbls IN OUT NOCOPY OP_RES_RECTBL_T,
                                  x_returnStatus OUT NOCOPY VARCHAR2);



  --schedules 'no' resources
  procedure scheduleNoResources(p_anchorDate IN DATE,
                                x_resTbls IN OUT NOCOPY OP_RES_RECTBL_T,
                                x_returnStatus OUT NOCOPY VARCHAR2);

  --when forward scheduling, this function will reschedule the entire job
  --if one or more prior resources are initially scheduled to start before
  --the start date passed in.
  procedure resolvePriorExceptions(p_orgID IN NUMBER,
                                   p_repLineID  IN NUMBER,
                                   p_startDate IN DATE,
                                   x_resTbls IN OUT NOCOPY OP_RES_RECTBL_T,
                                   x_returnStatus OUT NOCOPY VARCHAR2);

  /* fix bug 7027946 */
  procedure capacityExceptions(p_resID     IN NUMBER,
                               p_deptID    IN NUMBER,
                               p_orgID     IN NUMBER,
                               x_shifts IN OUT NOCOPY shift_recTbl_t,
			       x_returnStatus OUT NOCOPY VARCHAR2);
  /* end of fix bug 7027946 */

  --when backward scheduling, this function will reschedule the entire job
  --if one or more next resources are initially scheduled to end after the
  --end date passed in.
  procedure resolveNextExceptions(p_orgID IN NUMBER,
                                  p_repLineID  IN NUMBER,
                                  p_endDate IN DATE,
                                  x_resTbls IN OUT NOCOPY OP_RES_RECTBL_T,
                                  x_returnStatus OUT NOCOPY VARCHAR2);

  procedure forwardSchedule(p_orgID        in number,
                            p_repLineID    in NUMBER := null,
                            p_startDate    in DATE,
                            p_range        in num_tbl_t,
                            p_schedFlag    in number,
                            x_resTbls      in out NOCOPY OP_RES_RECTBL_T,
                            x_returnStatus OUT NOCOPY VARCHAR2);

  procedure backwardSchedule(p_orgID        in number,
                             p_repLineID    in NUMBER := null,
                             p_endDate      in DATE,
                             p_range        in num_tbl_t,
                             p_schedFlag    in number,
                             x_resTbls      in out NOCOPY OP_RES_RECTBL_T,
                             x_returnStatus OUT NOCOPY VARCHAR2);


  --removes priors from simultaneous batch
  --returns last index of batch
  function cleanBatch(p_startIdx NUMBER,
                      x_resTbls IN OUT NOCOPY op_res_rectbl_t) return number is
  begin
    for i in p_startIdx..x_resTbls.resID.count loop
      if(x_resTbls.opSeqNum(i) = x_resTbls.opSeqNum(p_startIdx) and
         x_resTbls.schedSeqNum(i) = x_resTbls.schedSeqNum(p_startIdx)) then
        if(x_resTbls.schedFlag(i) = wip_constants.sched_prior) then
          x_resTbls.schedFlag(i) := wip_constants.sched_yes;
        end if;
      else
        return i;
      end if;
    end loop;
    return x_resTbls.resID.count;
  end cleanBatch;

  --checks if priors co-exist with other schedule methods in simultaneous batch
  --if so, it changes the priors to scheduled yes.
  procedure removePriorsFromBatch(x_resTbls IN OUT NOCOPY op_res_rectbl_t) is
    i number := 2;
    l_curOp NUMBER := x_resTbls.opSeqNum(1);
    l_curSch NUMBER := x_resTbls.schedSeqNum(1);
    l_priorExists boolean := x_resTbls.schedFlag(1) = wip_constants.sched_prior;
    l_otherExists boolean := x_resTbls.schedFlag(1) in (wip_constants.sched_yes, wip_constants.sched_next);
    l_startIdx NUMBER := 1;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_retStatus VARCHAR2(1);
    l_params wip_logger.param_tbl_t;
  begin
    if(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.entryPoint(p_procName => 'wip_infResSched_grp.removePriorsFromBatch',
                            p_params => l_params,
                            x_returnStatus => l_retStatus);
    end if;
    while(i <= x_resTbls.resID.count) loop
      --in same batch as the previous res
      if(x_resTbls.schedSeqNum(i) = l_curSch and
         x_resTbls.opSeqNum(i) = l_curOp) then
        l_priorExists := l_priorExists or x_resTbls.schedFlag(i) = wip_constants.sched_prior;
        l_otherExists := l_otherExists or x_resTbls.schedFlag(i) in (wip_constants.sched_yes, wip_constants.sched_next);
        if(l_priorExists and l_otherExists) then
          i := cleanBatch(p_startIdx => l_startIdx, x_resTbls => x_resTbls);
        end if;

      --new batch
      else
        l_curOp := x_resTbls.opSeqNum(i);
        l_curSch := x_resTbls.schedSeqNum(i);
        l_startIdx := i;
        l_priorExists := x_resTbls.schedFlag(i) = wip_constants.sched_prior;
        l_otherExists := x_resTbls.schedFlag(i) in (wip_constants.sched_yes, wip_constants.sched_next);
      end if;
      i := i + 1;
    end loop;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.removePriorsFromBatch',
                           p_procReturnStatus => null,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
    end if;
  end removePriorsFromBatch;

  procedure removePriors(x_resTbls IN OUT NOCOPY OP_RES_RECTBL_T) is
    l_curOp NUMBER:= x_resTbls.opSeqNum(1);
    l_nonPriorExists boolean := false;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_retStatus VARCHAR2(1);
    l_params wip_logger.param_tbl_t;
  begin
    if(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.entryPoint(p_procName => 'wip_infResSched_grp.removePriors',
                            p_params => l_params,
                            x_returnStatus => l_retStatus);
    end if;
    for i in 1..x_resTbls.resID.count loop
      if(l_curOp = x_resTbls.opSeqNum(i)) then
        if(l_nonPriorExists and x_resTbls.schedFlag(i) = wip_constants.sched_prior) then
          x_resTbls.schedFlag(i) := wip_constants.sched_yes;
        end if;
        l_nonPriorExists := l_nonPriorExists or (x_resTbls.schedFlag(i) not in (wip_constants.sched_prior, wip_constants.sched_no));
      else
        l_curOp := x_resTbls.opSeqNum(i);
        l_nonPriorExists := x_resTbls.schedFlag(i) not in (wip_constants.sched_prior, wip_constants.sched_no);
      end if;
    end loop;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.removePriors',
                           p_procReturnStatus => null,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
    end if;
  end removePriors;

  procedure removeNexts(x_resTbls IN OUT NOCOPY OP_RES_RECTBL_T) is
    l_curOp NUMBER:= x_resTbls.opSeqNum(x_resTbls.resID.count);
    l_nonNextExists boolean := false;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_retStatus VARCHAR2(1);
    l_params wip_logger.param_tbl_t;
  begin
    if(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.entryPoint(p_procName => 'wip_infResSched_grp.removeNexts',
                            p_params => l_params,
                            x_returnStatus => l_retStatus);
    end if;
    for i in reverse 1..x_resTbls.resID.count loop
      if(l_curOp = x_resTbls.opSeqNum(i)) then
        if(l_nonNextExists and x_resTbls.schedFlag(i) = wip_constants.sched_next) then
          x_resTbls.schedFlag(i) := wip_constants.sched_yes;
        end if;
        l_nonNextExists := l_nonNextExists or
                           (x_resTbls.schedFlag(i) not in (wip_constants.sched_next, wip_constants.sched_no));
      else
        l_curOp := x_resTbls.opSeqNum(i);
        l_nonNextExists := x_resTbls.schedFlag(i) not in (wip_constants.sched_no, wip_constants.sched_next);
      end if;
    end loop;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.removeNexts',
                           p_procReturnStatus => null,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
    end if;
  end removeNexts;

  procedure verifyResources(x_resTbls IN OUT NOCOPY OP_RES_RECTBL_T) is

    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_retStatus VARCHAR2(1);
    l_params wip_logger.param_tbl_t;
  begin
    if(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.entryPoint(p_procName => 'wip_infResSched_grp.verifyResources',
                            p_params => l_params,
                            x_returnStatus => l_retStatus);
    end if;

    --changes schedule method of prior resources to yes if
    -- + they are in the first op <= can't do this b/c of midpoint scheduling
    -- + other resources with a different schedule type precede them in the operation
    removePriors(x_resTbls => x_resTbls);

    --changes schedule method of next resources to yes if
    -- + other resources with a different schedule type are after them in the operation
    removeNexts(x_resTbls => x_resTbls);

    --if a prior resource is in a simultaneous batch that contains other resources
    --with different scheduling methods simply treat them as
    --scheduled ("yes") resources as the next/prior goals cannot be met, i.e. no
    --overlap with the next/previous operation can be achieved.
    --this shouldn't be done for next resources as they can still complete after
    --the next operation starts (batched resources must start at the same time but
    --can complete at different times).

    --changes schedule method of prior resources to yes if
    -- + they are in a simultaneous batch with yes or next resources.
    removePriorsFromBatch(x_resTbls => x_resTbls);
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.verifyResources',
                           p_procReturnStatus => null,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
    end if;
  end verifyResources;

  procedure dumpOps(p_opTbl in op_tbl_t) is
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_retStatus VARCHAR2(1);
    l_params wip_logger.param_tbl_t;
  begin
    if(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.entryPoint(p_procName => 'wip_infResSched_grp.dumpOps',
                            p_params => l_params,
                            x_returnStatus => l_retStatus);
    end if;
    if(l_logLevel <= wip_constants.full_logging) then
      for i in 1..p_opTbl.count loop
        wip_logger.log('op:' || i, l_retStatus);
        wip_logger.log('startDate:' || to_char(p_opTbl(i).startDate, g_logDateFmt), l_retStatus);
        wip_logger.log('endDate:' || to_char(p_opTbl(i).endDate, g_logDateFmt), l_retStatus);
        if(p_opTbl(i).priorsExist) then
          wip_logger.log('priorsExist:true', l_retStatus);
        else
          wip_logger.log('priorsExist:false', l_retStatus);
        end if;
        if(p_opTbl(i).nextsExist) then
          wip_logger.log('nextsExist:true', l_retStatus);
        else
          wip_logger.log('nextsExist:false', l_retStatus);
        end if;
        wip_logger.log('resRange:' || p_opTbl(i).resStartIdx || '-' || p_opTbl(i).resEndIdx, l_retStatus);
      end loop;
    end if;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.dumpOps',
                           p_procReturnStatus => null,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
    end if;
  end dumpOps;

  procedure buildOpStructure(p_resTbls in op_res_rectbl_t,
                             p_anchorDate in Date,
                             x_opTbl out nocopy op_tbl_t) is
    l_opSeqNum NUMBER := p_resTbls.opSeqNum(1);
    l_startRange NUMBER := 1;
    l_endRange NUMBER := 1;
    j number := 1;
    l_firstYesOpIdx NUMBER;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_retStatus VARCHAR2(1);
    l_params wip_logger.param_tbl_t;
  begin
    if(l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_anchorDate';
      l_params(1).paramValue := to_char(p_anchorDate, g_logDateFmt);
      wip_logger.entryPoint(p_procName => 'wip_infResSched_grp.buildOpStructure',
                            p_params => l_params,
                            x_returnStatus => l_retStatus);
    end if;

    --initialize op structure
    x_opTbl(1).resStartIdx := 1;
    x_opTbl(1).resEndIdx := null;

    for i in 1..p_resTbls.resID.count loop
      if(l_opSeqNum <> p_resTbls.opSeqNum(i)) then

        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('new op at resource ' || i, l_retStatus);
        end if;

        x_opTbl(j).resEndIdx := i - 1;
        j := j + 1;
--        if(j > 1) then
--          x_opTbl(j).startDate := x_opTbl(j-1).startDate;
--          x_opTbl(j).endDate := x_opTbl(j-1).endDate;
--        end if;
        x_opTbl(j).resStartIdx := i;
        x_opTbl(j).resEndIdx := null;

        l_opSeqNum := p_resTbls.opSeqNum(i);
      end if;
      x_opTbl(j).priorsExist := x_opTbl(j).priorsExist or p_resTbls.schedFlag(i) = wip_constants.sched_prior;
      x_opTbl(j).nextsExist := x_opTbl(j).nextsExist or p_resTbls.schedFlag(i) = wip_constants.sched_next;
      if(p_resTbls.schedFlag(i) = wip_constants.sched_yes) then
        if(l_firstYesOpIdx is null) then
          l_firstYesOpIdx := j;
        end if;
        x_opTbl(j).startDate := least(p_resTbls.startDate(i), nvl(x_opTbl(j).startDate, p_resTbls.startDate(i)));
        x_opTbl(j).endDate := greatest(p_resTbls.endDate(i), nvl(x_opTbl(j).endDate, p_resTbls.endDate(i)));
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('op ' || j || '''s start date:' || to_char(x_opTbl(j).startDate, g_logDateFmt), l_retStatus);
          wip_logger.log('op ' || j || '''s end date:' || to_char(x_opTbl(j).endDate, g_logDateFmt), l_retStatus);
        end if;

      end if;
    end loop;
    --for the last op, set the end resource to the last one in the structure
    x_opTbl(x_opTbl.count).resEndIdx := p_resTbls.resID.count;

    for i in 1..x_opTbl.count loop
      if(x_opTbl(i).startDate is null) then
        if(i = 1) then
          if(l_firstYesOpIdx is null) then
            x_opTbl(i).startDate := p_anchorDate;
            x_opTbl(i).endDate := p_anchorDate;
          else
            x_opTbl(i).startDate := x_opTbl(l_firstYesOpIdx).startDate;
            x_opTbl(i).endDate := x_opTbl(l_firstYesOpIdx).startDate;
          end if;
        else
          x_opTbl(i).startDate := x_opTbl(i-1).endDate;
          x_opTbl(i).endDate := x_opTbl(i-1).endDate;
        end if;
      end if;
    end loop;

    if (l_logLevel <= wip_constants.full_logging) then
      dumpOps(x_opTbl);
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.buildOpStructure',
                           p_procReturnStatus => null,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
    end if;
  end buildOpStructure;

  procedure findMdPntRes(p_resTbls IN OP_RES_RECTBL_T,
                         p_opSeqNum NUMBER,
                         p_resSeqNum NUMBER,
                         p_isMdPntFwd boolean,
                         x_midPntFwdIdx OUT NOCOPY NUMBER,
                         x_midPntBkwdIdx OUT NOCOPY NUMBER) is
    l_retStatus VARCHAR2(1);
    l_params wip_logger.param_tbl_t;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_foundMidPntOp boolean := false;
  begin
    if(l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_opSeqNum';
      l_params(1).paramValue := p_opSeqNum;
      l_params(2).paramName := 'p_resSeqNum';
      l_params(2).paramValue := p_resSeqNum;
      l_params(3).paramName := 'p_isMdPntFwd';
      if(p_isMdPntFwd) then l_params(3).paramValue := 'true';
      else l_params(3).paramValue := 'false'; end if;

      wip_logger.entryPoint(p_procName => 'wip_infResSched_grp.findMdPntRes',
                            p_params => l_params,
                            x_returnStatus => l_retStatus);
    end if;

    --find the midpoint resource
    for i in 1..p_resTbls.resID.count loop
      if(p_opSeqNum = p_resTbls.opSeqNum(i)) then --op matches
        l_foundMidPntOp := true;
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('op seq matches res ' || i, l_retStatus);
        end if;

        if(p_resSeqNum is not null) then
          if(p_resSeqNum = p_resTbls.resSeqNum(i)) then --res seq matches

            if(l_logLevel <= wip_constants.full_logging) then
              wip_logger.log('res seq matches res ' || i, l_retStatus);
            end if;

            if(p_isMdPntFwd) then
              -- bug 3423612: If there are simultaneous resources, we have to
              -- set the index to the first res in the group (last res for
              -- backwards scheduling).
              for j in reverse 1..i loop
                if (p_resTbls.opSeqNum(j) = p_resTbls.opSeqNum(i) and
                    nvl(p_resTbls.schedSeqNum(j), p_resTbls.resSeqNum(j)) = nvl(p_resTbls.schedSeqNum(i), p_resTbls.resSeqNum(i))) then
                  x_midPntFwdIdx := j;
                  if(j <> 1) then
                    x_midPntBkwdIdx := j - 1;
                  else
                    x_midPntBkwdIdx := null;
                  end if;
                else
                  exit;
                end if;
              end loop;
            else
              for j in i..p_resTbls.resID.count loop
                if (p_resTbls.opSeqNum(j) = p_resTbls.opSeqNum(i) and
                    nvl(p_resTbls.schedSeqNum(j), p_resTbls.resSeqNum(j)) = nvl(p_resTbls.schedSeqNum(i), p_resTbls.resSeqNum(i))) then
                  x_midPntBkwdIdx := j;
                  if(j <> p_resTbls.resID.count) then
                    x_midPntFwdIdx := j + 1;
                  else
                    x_midPntFwdIdx := null;
                  end if;
                else
                  exit;
                end if;
              end loop;
            end if; --start date...
            exit; --res seq matched, exit loop
          end if;
        else --resource seq was not populated. use op start or end res

          if(l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('res seq is null', l_retStatus);
          end if;

          if(p_isMdPntFwd) then --forward scheduling midpoint op
            x_midPntFwdIdx := i;
            if(i <> 1) then
              x_midPntBkwdIdx := i - 1;
            end if;
            exit;
          end if;
        end if;
      end if;

      --if backward scheduling the midpoint op and the first op of the next op was found...
      if(l_foundMidPntOp and
         not(p_isMdPntFwd) and
         p_resTbls.opSeqNum(i) <> p_opSeqNum) then
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('first res past midpoint at idx:' || i, l_retStatus);
        end if;
        x_midPntBkwdIdx := i - 1;
        x_midPntFwdIdx := i;
        exit;
      end if;

      if(p_resTbls.resID.count = i) then
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('backward scheduling everything', l_retStatus);
        end if;

        x_midPntBkwdIdx := i;
        exit;
      end if;
    end loop;
    if(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.findMdPntRes',
                           p_procReturnStatus => null,
                           p_msg              => 'fwdIdx:' || x_midPntFwdIdx || '; bkwdIdx:' || x_midPntBkwdIdx,
                           x_returnStatus     => l_retStatus);
    end if;
  end findMdPntRes;

  procedure schedule(p_orgID IN NUMBER,
                     p_repLineID NUMBER := null,
                     p_startDate DATE := null,
                     p_endDate DATE := null,
                     p_opSeqNum NUMBER := null,
                     p_resSeqNum NUMBER := null,
                     p_endDebug IN VARCHAR2 := null,
                     x_resTbls IN OUT NOCOPY OP_RES_RECTBL_T,
                     x_returnStatus OUT NOCOPY VARCHAR2) is
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_params wip_logger.param_tbl_t;
    l_retStatus VARCHAR2(1);

    l_fwdStIdx NUMBER;--resource to start forward scheduling from
    l_bkwdEndIdx NUMBER;--resource to backward schedule to
    l_startDate DATE;
    l_endDate DATE;
    l_range num_tbl_t := num_tbl_t(null,null);
    l_opTbl op_tbl_t;
    l_errMsg VARCHAR2(2000);
  begin
    if(l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_orgID';
      l_params(1).paramValue := p_orgID;
      l_params(2).paramName := 'p_repLineID';
      l_params(2).paramValue := p_repLineID;
      l_params(3).paramName := 'p_startDate';
      l_params(3).paramValue := to_char(p_startDate, g_logDateFmt);
      l_params(4).paramName := 'p_endDate';
      l_params(4).paramValue := to_char(p_endDate, g_logDateFmt);
      l_params(5).paramName := 'p_opSeqNum';
      l_params(5).paramValue := p_opSeqNum;
      wip_logger.entryPoint(p_procName => 'wip_infResSched_grp.schedule',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;
    x_returnStatus := fnd_api.g_ret_sts_success;

    if(x_resTbls.resID is null or x_resTbls.resID.count < 1) then
      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.schedule',
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'no resources to schedule!',
                             x_returnStatus     => l_retStatus);
      end if;
      return;
    end if;

    --initialize the date tables
    x_resTbls.startDate := date_tbl_t();
    x_resTbls.endDate := date_tbl_t();

    x_resTbls.usgStartIdx := num_tbl_t();
    x_resTbls.usgEndIdx := num_tbl_t();

    x_resTbls.usgStartDate := date_tbl_t();
    x_resTbls.usgEndDate := date_tbl_t();

    x_resTbls.usgCumMinProcTime := num_tbl_t();

    x_resTbls.usgStartIdx.extend(x_resTbls.resID.count);
    x_resTbls.usgEndIdx.extend(x_resTbls.resID.count);

    x_resTbls.startDate.extend(x_resTbls.resID.count);
    x_resTbls.endDate.extend(x_resTbls.resID.count);
    if(l_logLevel <= wip_constants.trace_logging) then
      dumpResources(x_resTbls);
    end if;

    verifyResources(x_resTbls => x_resTbls);

    if(l_logLevel <= wip_constants.trace_logging) then
      dumpResources(x_resTbls);
    end if;

    --caller wants to either forward or backward schedule.
    if(p_opSeqNum is null) then
      --forward
      if(p_startDate is not null) then
        l_fwdStIdx := 1;
        l_bkwdEndIdx := null;--this line isn''t necessary, but is included for clarity
        l_startDate := p_startDate;
        l_endDate := null;--this line isn''t necessary, but is included for clarity

        if (l_logLevel <= wip_constants.trace_logging) then
          wip_logger.log(p_msg          => 'forward scheduling',
                         x_returnStatus => x_returnStatus);
        end if;

      --backward
      else
        l_fwdStIdx := null;--this line isn''t necessary, but is included for clarity
        l_bkwdEndIdx := x_resTbls.resID.count;
        l_startDate := null;--this line isn''t necessary, but is included for clarity
        l_endDate := p_endDate;

        if (l_logLevel <= wip_constants.trace_logging) then
          wip_logger.log(p_msg          => 'backward scheduling',
                         x_returnStatus => x_returnStatus);
        end if;
      end if;
    else --midpoint scheduling
      findMdPntRes(p_resTbls => x_resTbls,
                   p_opSeqNum => p_opSeqNum,
                   p_resSeqNum => p_resSeqNum,
                   p_isMdPntFwd => p_startDate is not null,
                   x_midPntFwdIdx => l_fwdStIdx,
                   x_midPntBkwdIdx => l_bkwdEndIdx);

      if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.log(p_msg          => 'midpoint scheduling',
                       x_returnStatus => x_returnStatus);
      end if;

      if(p_startDate is not null) then
        --forward schedule operation provided and those greater.
        --backward schedule previous operations
        l_startDate := p_startDate;
        l_endDate := p_startDate;
      else
        --forward schedule operations greater than the one provided
        --backward schedule op provided and the previous ones
        l_startDate := p_endDate;
        l_endDate := p_endDate;
      end if;
    end if;

    if(l_fwdStIdx is not null) then
      l_range(1) := l_fwdStIdx;
      l_range(2) := x_resTbls.resID.count;

      --forward schedule resources in range.
      forwardSchedule(p_orgID        => p_orgID,
                      p_repLineID    => p_repLineID,
                      p_startDate    => l_startDate,
                      p_range        => l_range,
                      p_schedFlag    => wip_constants.sched_yes,
                      x_resTbls      => x_resTbls,
                      x_returnStatus => x_returnStatus);

      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        wip_logger.log('fwdSch failed', l_retStatus);
        raise fnd_api.g_exc_unexpected_error;
      end if;

      if(l_logLevel <= wip_constants.full_logging) then
        dumpResources(x_resTbls);
      end if;
    end if;

    if(l_bkwdEndIdx is not null) then
      l_range(1) := 1;
      l_range(2) := l_bkwdEndIdx;

      --backward schedule resources in range.
      backwardSchedule(p_orgID        => p_orgID,
                       p_repLineID    => p_repLineID,
                       p_endDate      => l_endDate,
                       p_range        => l_range,
                       p_schedFlag    => wip_constants.sched_yes,
                       x_resTbls      => x_resTbls,
                       x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        wip_logger.log('bkwdSch failed', l_retStatus);
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    --build the operation structure
    buildOpStructure(p_resTbls    => x_resTbls,
                     p_anchorDate => nvl(p_startDate, p_endDate),
                     x_opTbl      => l_opTbl);

    --now schedule prior and next resources
    schedulePriorResources(p_orgID => p_orgID,
                           p_repLineID => p_repLineID,
                           p_opTbl => l_opTbl,
                           x_resTbls => x_resTbls,
                           x_returnStatus => x_returnStatus);

    if(x_returnStatus <> fnd_api.g_ret_sts_success) then
      wip_logger.log('schPriorRes failed', l_retStatus);
      raise fnd_api.g_exc_unexpected_error;
    end if;


    scheduleNextResources(p_orgID => p_orgID,
                          p_repLineID => p_repLineID,
                          p_opTbl => l_opTbl,
                          x_resTbls => x_resTbls,
                          x_returnStatus => x_returnStatus);

    if(x_returnStatus <> fnd_api.g_ret_sts_success) then
      wip_logger.log('schNextRes failed', l_retStatus);
      raise fnd_api.g_exc_unexpected_error;
    end if;

    if(l_logLevel <= wip_constants.full_logging) then
      dumpResources(x_resTbls);
    end if;

    --if forward scheduling...
    if(p_opSeqNum is null and p_startDate is not null) then
      resolvePriorExceptions(p_orgID        => p_orgID,
                             p_repLineID    => p_repLineID,
                             p_startDate    => p_startDate,
                             x_resTbls      => x_resTbls,
                             x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        wip_logger.log('resolvePriorRes failed', l_retStatus);
        raise fnd_api.g_exc_unexpected_error;
      end if;
    --if backward scheduling
    elsif(p_opSeqNum is null and p_endDate is not null) then
      resolveNextExceptions(p_orgID        => p_orgID,
                            p_repLineID    => p_repLineID,
                            p_endDate      => p_endDate,
                            x_resTbls      => x_resTbls,
                            x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        wip_logger.log('resolveNextRes failed', l_retStatus);
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;


    --assign dates to scheduled no resources
    scheduleNoResources(p_anchorDate => nvl(p_startDate, p_endDate),
                        x_resTbls => x_resTbls,
                        x_returnStatus => x_returnStatus);



    if(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.schedule',
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
      if(fnd_api.to_boolean(nvl(p_endDebug, fnd_api.g_true))) then
        wip_logger.cleanup(l_retStatus);
      end if;
    end if;
  exception
     when fnd_api.g_exc_unexpected_error then
       x_returnStatus := fnd_api.g_ret_sts_unexp_error;
       if(l_logLevel <= wip_constants.trace_logging) then
         wip_utilities.get_message_stack(p_msg => l_errMsg,
                                         p_delete_stack => fnd_api.g_false);

         wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.schedule',
                              p_procReturnStatus => x_returnStatus,
                              p_msg              => 'failure: ' || l_errMsg,
                              x_returnStatus     => l_retStatus);
         if(fnd_api.to_boolean(nvl(p_endDebug, fnd_api.g_true))) then
           wip_logger.cleanup(l_retStatus);
         end if;
       end if;
     when others then
       x_returnStatus := fnd_api.g_ret_sts_unexp_error;
       fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_infResSched_grp',
                               p_procedure_name => 'schedule',
                               p_error_text => SQLERRM);
       if(l_logLevel <= wip_constants.trace_logging) then
         wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.schedule',
                              p_procReturnStatus => x_returnStatus,
                              p_msg              => 'unexpected error: ' || SQLERRM,
                              x_returnStatus     => l_retStatus);
         if(fnd_api.to_boolean(nvl(p_endDebug, fnd_api.g_true))) then
           wip_logger.cleanup(l_retStatus);
         end if;
       end if;
  end schedule;

  function getNextResIdx(p_range        in num_tbl_t,
                         p_schedFlag    in number,
                         p_schedMethod  in number,
                         p_resTbls      in OP_RES_RECTBL_T,
                         x_idx in out nocopy number) return boolean is
    l_retStatus VARCHAR2(1);
  begin
    if(p_schedMethod = g_forward) then
      for j in nvl(x_idx+1, p_range(1))..p_range(2) loop
        if(p_resTbls.schedFlag(j) = p_schedFlag) then
          x_idx := j;
          return true;
        end if;
      end loop;
    end if;

    if(p_schedMethod = g_backward) then
      for j in reverse p_range(1)..nvl(x_idx-1,p_range(2)) loop
        if(p_resTbls.schedFlag(j) = p_schedFlag) then
          x_idx := j;
          return true;
        end if;
      end loop;
    end if;

    return false;
  end getNextResIdx;

  --p_prevStartDate: The date from which the previous resource was scheduled from (not necessarily
  -- the start date of the previous resource...no shift could have been defined on the exact time
  -- the resource could have been scheduled from)
  function getStartDate(p_range in num_tbl_t,
                        p_schedFlag in number,
                        p_resTbls in op_res_rectbl_t,
                        p_curIdx in number,
                        p_doneSchedBatch in boolean,
                        p_prevIdx in number) return date is
    l_retStatus VARCHAR2(1);
    l_params wip_logger.param_tbl_t;
    i number;
    l_maxEndDate date;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_bool boolean;
  begin
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_range(1)';
      l_params(1).paramValue := p_range(1);
      l_params(2).paramName := 'p_range(2)';
      l_params(2).paramValue := p_range(2);
      l_params(3).paramName := 'p_schedFlag';
      l_params(3).paramValue := p_schedFlag;
      l_params(4).paramName := 'p_curIdx';
      l_params(4).paramValue := p_curIdx;
      l_params(5).paramName := 'p_doneSchedBatch';
      if(p_doneSchedBatch) then l_params(5).paramValue := 'true';
      else l_params(5).paramValue := 'false';
      end if;
      l_params(6).paramName := 'p_prevIdx';
      l_params(6).paramValue := p_prevIdx;

      wip_logger.entryPoint(p_procName     => 'wip_infResSched_grp.getStartDate',
                            p_params       => l_params,
                            x_returnStatus => l_retStatus);
    end if;

    --in case we just got done scheduling a batch of simultaneous resources, get the
    --latest end date to use as the next resource's start date
    i := p_curIdx;

    if(p_doneSchedBatch) then
      if(l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('done scheduling batch', l_retStatus);
      end if;
      while(getNextResIdx(p_range, p_schedFlag, g_backward, p_resTbls, i)) loop
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('in loop', l_retStatus);
          wip_logger.log('resID' || p_resTbls.resID(i), l_retStatus);
          wip_logger.log('opSeq' || p_resTbls.opSeqNum(i), l_retStatus);
          wip_logger.log('schSeq' || p_resTbls.schedSeqNum(i), l_retStatus);
          wip_logger.log('idx' || i, l_retStatus);
        end if;
        if(p_resTbls.schedSeqNum(i) = p_resTbls.schedSeqNum(p_prevIdx) and
           p_resTbls.opSeqNum(i) = p_resTbls.opSeqNum(p_prevIdx)) then
          l_maxEndDate := greatest(nvl(l_maxEndDate, p_resTbls.endDate(i)), p_resTbls.endDate(i));
          if(l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('resource in batch. endDate:' || to_char(p_resTbls.endDate(i), g_logDateFmt), l_retStatus);
          end if;
        else
          if(l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('resource not in batch.', l_retStatus);
          end if;
          exit;
        end if;
      end loop;
    else
      l_bool := (getNextResIdx(p_range, p_schedFlag, g_backward, p_resTbls, i));
      l_maxEndDate := p_resTbls.endDate(i);
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.getStartDate',
                           p_procReturnStatus => to_char(l_maxEndDate),
                           p_msg              => 'finished scheduling',
                           x_returnStatus     => l_retStatus);
    end if;
    return l_maxEndDate;
  end getStartDate;

  procedure forwardSchResource(p_orgID in number,
                               p_startDate in date,
                               p_maxDate in date,
                               p_idx in number,
                               p_repLineID in number := null,
                               x_resTbls in out nocopy op_res_rectbl_t,
                               x_returnStatus out nocopy varchar2) is

    cursor c_shiftTimes(v_resID NUMBER,
                        v_deptID NUMBER,
                        v_orgID NUMBER,
                        v_startDate DATE,
                        v_endDate DATE) is
      select brs.shift_num,
             bsd.shift_date + bst.from_time/86400,
             bsd.shift_date + bst.to_time/86400
        from bom_resource_shifts brs,
             mtl_parameters mp,
             bom_shift_dates bsd,
             bom_shift_times bst,
             bom_department_resources bdr
       where bdr.department_id = v_deptID
         and bdr.resource_id = v_resID
         and brs.resource_id = bdr.resource_id
         and brs.department_id = nvl(bdr.share_from_dept_id,bdr.department_id)
         and mp.organization_id = v_orgID
         and mp.calendar_code = bsd.calendar_code
         and mp.calendar_exception_set_id = bsd.exception_set_id
         and brs.shift_num = bsd.shift_num
         and bsd.shift_date between v_startDate and v_endDate --don't incorporate time into this check as it slows the query
         and bsd.seq_num is not null
         and bst.shift_num = bsd.shift_num
         and bst.calendar_code = bsd.calendar_code
       order by bsd.shift_date, bst.from_time;

      --for repetitive, ignore shifts and use the line's start and stop times. However, do
      --respect the working days definition
      cursor c_repTimes(v_repLineID NUMBER,
                        v_orgID NUMBER,
                        v_startDate DATE,
                        v_endDate DATE) is
      select -1 shiftNum,
             bcd.calendar_date + wl.start_time/86400,
             bcd.calendar_date + wl.stop_time/86400
        from mtl_parameters mp,
             bom_calendar_dates bcd,
             wip_lines wl
       where mp.organization_id = v_orgID
         and mp.calendar_code = bcd.calendar_code
         and mp.calendar_exception_set_id = bcd.exception_set_id
         and wl.line_id = v_repLineID
         and bcd.seq_num is not null --working day
         and bcd.calendar_date between v_startDate and v_endDate
       order by bcd.calendar_date;

    cursor c_24HrTimes(v_orgID NUMBER,
                       v_startDate DATE,
                       v_endDate DATE) is
      select -1,
             bcd.calendar_date,
             bcd.calendar_date + 1
        from mtl_parameters mp,
             bom_calendar_dates bcd
       where mp.organization_id = v_orgID
         and mp.calendar_code = bcd.calendar_code
         and mp.calendar_exception_set_id = bcd.exception_set_id
         and bcd.calendar_date between v_startDate and v_endDate
         and bcd.seq_num is not null
       order by bcd.calendar_date;

     --used to collect cursor records...
    /* fix bug 7027946 */
    /* type shift_recTbl_t is record(shiftNum num_tbl_t,
                                     startDate date_tbl_t,
                                     endDate date_tbl_t);
    /* end of fix bug 7027946 */

    l_shifts shift_recTbl_t;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_params wip_logger.param_tbl_t;
    l_retStatus VARCHAR2(1);
    l_resourceScheduled boolean := false;
    l_cursorStartDate date := trunc(p_startDate) - 1;--subtract 1 to make sure to get wraparound shifts (start on prev day)
    l_fromDate date;
    l_shiftLen NUMBER;
    l_remUsage NUMBER := x_resTbls.totalDaysUsg(p_idx);
    l_usgIdx NUMBER;
    l_startDate DATE;
    l_prevProcTime NUMBER;
    l_isFirstUsg boolean := true;
    l_dummy NUMBER; /* Bug 5660475 */
  begin
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_orgID';
      l_params(1).paramValue := p_orgID;
      l_params(2).paramName := 'p_startDate';
      l_params(2).paramValue := to_char(p_startDate, g_logDateFmt);
      l_params(3).paramName := 'p_maxDate';
      l_params(3).paramValue := to_char(p_maxDate, g_logDateFmt);
      l_params(4).paramName := 'p_idx';
      l_params(4).paramValue := p_idx;
      l_params(5).paramName := 'p_repLineID';
      l_params(5).paramValue := p_repLineID;
      wip_logger.entryPoint(p_procName     => 'wip_infResSched_grp.forwardSchResource',
                            p_params       => l_params,
                            x_returnStatus => l_retStatus);
    end if;
    x_returnStatus := fnd_api.g_ret_sts_success;

    /* Fix for bug 5660475: If dealing with shift resource, first check if shifts are setup fine. */
    if( p_repLineID is null
        and x_resTbls.avail24Flag(p_idx) = wip_constants.no
  	and x_resTbls.schedFlag(p_idx) <> wip_constants.sched_no) then
 	wip_logger.log('This is a shift resource. Need to validate shift setup', l_retStatus);
 	begin
 	  select 1
 	  into l_dummy
 	  from dual
 	  where exists (select 1
 	                  from bom_resource_shifts brs,
 	                       mtl_parameters mp,
 	                       bom_shift_dates bsd,
 	                       bom_shift_times bst,
 	                       bom_department_resources bdr
 	                 where bdr.department_id = x_resTbls.deptID(p_idx)
 	                   and bdr.resource_id = x_resTbls.resID(p_idx)
 	                   and brs.resource_id = bdr.resource_id
 	                   and brs.department_id = nvl(bdr.share_from_dept_id,bdr.department_id)
 	                   and mp.organization_id = p_orgID
 	                   and mp.calendar_code = bsd.calendar_code
 	                   and mp.calendar_exception_set_id = bsd.exception_set_id
 	                   and brs.shift_num = bsd.shift_num
 	                   and bsd.seq_num is not null
 	                   and bst.shift_num = bsd.shift_num
 	                   and bst.calendar_code = bsd.calendar_code);
 	exception
 	   when NO_DATA_FOUND then
 	      wip_logger.log('Error: Missing shifts or shift times!', l_retStatus);
 	      fnd_message.set_name('WIP', 'WIP_SHIFT_RESOURCE');
 	      fnd_message.set_token('ENTITY1', x_resTbls.resSeqNum(p_idx));
 	      fnd_message.set_token('ENTITY2', x_resTbls.opSeqNum(p_idx));
 	      fnd_msg_pub.add;
 	      raise fnd_api.g_exc_unexpected_error;
 	end;
    end if;

    x_resTbls.usgStartIdx(p_idx) := null;
    x_resTbls.usgEndIdx(p_idx) := null;
    loop
      exit when l_resourceScheduled;
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('cursor start date is' || to_char(l_cursorStartDate, g_logDateFmt), l_retStatus);
        wip_logger.log('cursor end date is' || to_char((l_cursorStartDate  + g_dateCursorLen - 1/86400), g_logDateFmt), l_retStatus);
      end if;

      --for v_endDate, subtract a second to avoid overlap between cursors.
      if(p_repLineID is not null) then
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('scheduling repetitive', l_retStatus);
        end if;
        open c_repTimes(v_repLineID => p_repLineID,
                        v_orgID     => p_orgID,
                        v_startDate => l_cursorStartDate,
                        v_endDate   => l_cursorStartDate + g_dateCursorLen - 1/86400);
        fetch c_repTimes
          bulk collect into l_shifts.shiftNum,
                            l_shifts.startDate,
                            l_shifts.endDate;
        close c_repTimes;
      elsif(x_resTbls.avail24Flag(p_idx) = wip_constants.yes) then
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('scheduling 24HR resource', l_retStatus);
        end if;
        open c_24HrTimes(v_orgID     => p_orgID,
                         v_startDate => l_cursorStartDate,
                         v_endDate   => l_cursorStartDate + g_dateCursorLen - 1/86400);
        fetch c_24HrTimes
          bulk collect into l_shifts.shiftNum,
                            l_shifts.startDate,
                            l_shifts.endDate;
        close c_24HrTimes;
      else
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('scheduling shift resource', l_retStatus);
        end if;
        open c_shiftTimes(v_resID     => x_resTbls.resID(p_idx),
                          v_deptID    => x_resTbls.deptID(p_idx),
                          v_orgID     => p_orgID,
                          v_startDate => l_cursorStartDate,
                          v_endDate   => l_cursorStartDate + g_dateCursorLen - 1/86400);
        fetch c_shiftTimes
          bulk collect into l_shifts.shiftNum,
                            l_shifts.startDate,
                            l_shifts.endDate;

        if (l_shifts.shiftNum.count = 0 ) then
        /* Fix for bug 5660475: If shifts are not available in the date range,
	we should continue to search in the next date range, instead of erroring out. */
	  wip_logger.log('No shifts found in this period.', l_retStatus);
          l_resourceScheduled := false;
        end if;

        close c_shiftTimes;

       /* fix bug 7027946 */
       capacityExceptions(p_resID        => x_resTbls.resID(p_idx),     -- adjust the capacity exception.
                          p_deptID       => x_resTbls.deptID(p_idx),
                          p_orgID        => p_orgID,
                          x_shifts       => l_shifts,
                          x_returnStatus => x_returnStatus);
       /* end of fix bug 7027946 */

      end if;


      for i in 1..l_shifts.shiftNum.count loop
        if(l_shifts.endDate(i) < l_shifts.startDate(i)) then --overnight shift
           l_shifts.endDate(i) := l_shifts.endDate(i) + 1;
        end if;

        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('**********shiftNum:' || l_shifts.shiftNum(i), l_retStatus);
          wip_logger.log('**shift start date:' || to_char(l_shifts.startDate(i), g_logDateFmt), l_retStatus);
          wip_logger.log('****shift end date:' || to_char(l_shifts.endDate(i), g_logDateFmt), l_retStatus);
        end if;

        --if shift ends before the requested start date, skip it since none of the shift
        --can be used. don't do this in the sql query as it degrades performance
        if(l_shifts.endDate(i) < p_startDate) then
          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('skipping shift (ends before start date)', l_retStatus);
          end if;
          goto NO_FULFILL_USAGE;--end of loop
        end if;

        --if the shift starts before the start time, adjust the shift length
        l_fromDate := greatest(l_shifts.startDate(i), p_startDate);
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('calculated start date: ' || to_char(l_fromDate, g_logDateFmt), l_retStatus);
        end if;

        l_shiftLen := l_shifts.endDate(i) - l_fromDate;
           /*Bug 7015594: If shift start time is same as end time then consider it as 24 hours resource.
           This should be only done when 24 hours check is unchecked and resource is not used on repetitive line*/
           /*Bug 9355406: fixed regression caused by 7015594, if resource start day is the end of the shift, it wont be treated as 24 hrs resource*/
           if(x_resTbls.avail24Flag(p_idx) <> wip_constants.yes AND p_repLineID is null AND l_shifts.startDate(i)=l_shifts.endDate(i)) then
                   l_shiftLen := 86400;
           end if;

        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('shiftLen(HRS) is ' || round(l_shiftLen*24, g_precision), l_retStatus);
        end if;

        if(round(l_shiftLen, g_precision) = 0) then
          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('skipping shift (no usage)', l_retStatus);
          end if;
          goto NO_FULFILL_USAGE;--end of loop
        end if;


        if(l_startDate is null) then
          l_startDate := l_fromDate;
          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('calculated resource start date:' || to_char(l_startDate, g_logDateFmt), l_retStatus);
          end if;
        end if;
         /*Bug 9355406: fixed regression caused by 7136375. if remaining usage is one day:
          for regular resource, consider shift fullfilled resource usage and exit the loop
          for 24 hours resource, condiser shift cannot fullfilled resource usage and loop to next working day
          */
          if(round(l_remUsage, g_precision) < round(l_shiftLen, g_precision) or /* Fix for bug 7136375.If time remaining is one day then we need to loop to next working day*/
           (round(l_remUsage, g_precision) = round(l_shiftLen, g_precision) and x_resTbls.avail24Flag(p_idx) <> wip_constants.yes)) then
          --shift fullfilled resource usage (round to approximately seconds)

          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('calculated resource start date:' || to_char(l_startDate, g_logDateFmt), l_retStatus);
          end if;
          x_resTbls.startDate(p_idx) := l_startDate;
          x_resTbls.endDate(p_idx) := l_fromDate + l_remUsage;
          --record shift usage
          x_resTbls.usgStartDate.extend(1);
          x_resTbls.usgEndDate.extend(1);
          x_resTbls.usgCumMinProcTime.extend(1);

          l_usgIdx := x_resTbls.usgStartDate.count;
          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('idx is ' || l_usgIdx, l_retStatus);
            wip_logger.log('count is ' || x_resTbls.usgStartIdx.count, l_retStatus);
            wip_logger.log('val is ' || x_resTbls.usgStartIdx(p_idx), l_retStatus);
          end if;

          x_resTbls.usgStartIdx(p_idx) := nvl(x_resTbls.usgStartIdx(p_idx), l_usgIdx);
          x_resTbls.usgEndIdx(p_idx) := l_usgIdx;

          x_resTbls.usgStartDate(l_usgIdx) := l_fromDate;

          --shift fulfilled resource => usage end time is resource end time
          x_resTbls.usgEndDate(l_usgIdx) := x_resTbls.endDate(p_idx);
          if(l_isFirstUsg) then
            if (l_logLevel <= wip_constants.full_logging) then
              wip_logger.log('first usage', l_retStatus);
            end if;
            l_isFirstUsg := false;
            l_prevProcTime := 0;
          else
            if (l_logLevel <= wip_constants.full_logging) then
              wip_logger.log('not first usage', l_retStatus);
            end if;
            l_prevProcTime := x_resTbls.usgCumMinProcTime(l_usgIdx - 1);
          end if;

          x_resTbls.usgCumMinProcTime(l_usgIdx) := l_prevProcTime +
                                                   (24*60)*(x_resTbls.usgEndDate(l_usgIdx) -
                                                            x_resTbls.usgStartDate(l_usgIdx));

          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('start date is ' || to_char(x_resTbls.startDate(p_idx), g_logDateFmt), l_retStatus);
            wip_logger.log('end date is ' || to_char(x_resTbls.endDate(p_idx), g_logDateFmt), l_retStatus);
            wip_logger.log('usage:' || to_char(x_resTbls.usgStartDate(l_usgIdx), g_logDateFmt) || ' - ' ||
                           to_char(x_resTbls.usgEndDate(l_usgIdx), g_logDateFmt), l_retStatus);
            wip_logger.log('cum usage time:' || x_resTbls.usgCumMinProcTime(l_usgIdx), l_retStatus);
          end if;

          l_resourceScheduled := true; --exit outer loop
          exit; --exit inner loop

        else --shift did not fulfill resource usage
          l_remUsage := l_remUsage - l_shiftLen; --decrement remaining time

          --record shift usage
          x_resTbls.usgStartDate.extend(1);
          x_resTbls.usgEndDate.extend(1);
          x_resTbls.usgCumMinProcTime.extend(1);

          l_usgIdx := x_resTbls.usgStartDate.count;
          x_resTbls.usgStartIdx(p_idx) := nvl(x_resTbls.usgStartIdx(p_idx), l_usgIdx);
          x_resTbls.usgEndIdx(p_idx) := l_usgIdx;

          x_resTbls.usgStartDate(l_usgIdx) := l_fromDate;
          --resource consumed until end of the shift
          x_resTbls.usgEndDate(l_usgIdx) := l_shifts.endDate(i);

          if(l_isFirstUsg) then
            l_prevProcTime := 0;
            l_isFirstUsg := false;
          else
            l_prevProcTime := x_resTbls.usgCumMinProcTime(l_usgIdx - 1);
          end if;
          x_resTbls.usgCumMinProcTime(l_usgIdx) := l_prevProcTime +
                                                   (24*60)*(x_resTbls.usgEndDate(l_usgIdx) -
                                                            x_resTbls.usgStartDate(l_usgIdx));
          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('exhausted shift. remaining usage(HRS) is ' || round(l_remUsage*24, g_precision), l_retStatus);
            wip_logger.log('usage:' || to_char(x_resTbls.usgStartDate(l_usgIdx), g_logDateFmt) || ' - ' ||
                           to_char(x_resTbls.usgEndDate(l_usgIdx), g_logDateFmt), l_retStatus);
            wip_logger.log('cum usage time:' || x_resTbls.usgCumMinProcTime(l_usgIdx), l_retStatus);
          end if;
        end if;
        <<NO_FULFILL_USAGE>>
        null;
      end loop;

      --if the resource wasn't scheduled, increment the date and keep going.
      if(not l_resourceScheduled) then
        l_cursorStartDate := l_cursorStartDate + g_dateCursorLen;

        --if the next start date is after the end of the calendar, then we can't schedule anything
        if(l_cursorStartDate > p_maxDate) then
          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('exhausted calendar. remaining usage(HRS) is ' || round(l_remUsage*24, g_precision), l_retStatus);
          end if;
          fnd_message.set_name('WIP', 'WIP_NO_CALENDAR');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_unexpected_error;
        end if;
      end if;
    end loop;
    if(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.forwardSchResource',
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
    end if;
  exception
    when fnd_api.g_exc_unexpected_error then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.forwardSchResource',
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'error',
                             x_returnStatus     => l_retStatus);
      end if;
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_infResSched_grp',
                              p_procedure_name => 'forwardSchResource',
                              p_error_text => SQLERRM);
      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.forwardSchResource',
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'unexp error: ' || SQLERRM,
                             x_returnStatus     => l_retStatus);
      end if;

  end forwardSchResource;

   /* fix bug 7027946: Added procedure wip_infResSched_grp.capacityExceptions to handle resource capacity exceptions.
                       It will change the resource shifts (add day, delete day, modify shift times) as per capacity
		       exceptions.
   */
   procedure capacityExceptions(p_resID     IN NUMBER,
                                p_deptID    IN NUMBER,
                                p_orgID     IN NUMBER,
                                x_shifts    IN OUT NOCOPY shift_recTbl_t,
			        x_returnStatus OUT NOCOPY VARCHAR2) is

     cursor c_capacityDtls(v_resID  NUMBER,
                           v_deptID NUMBER,
			   v_orgID  NUMBER) is
      select  shift_num,
              from_date,
	      to_date,
	      from_time,
	      to_time,
	      capacity_change,
	      action_type
         from bom_resource_changes brc,
	      crp_simulation_sets crp
        where department_id = v_deptID
	  and resource_id = v_resID
	  and organization_id = v_orgID
	  and crp.simulation_set  =  brc.simulation_set
	  and crp.use_in_wip_flag = 1;

      --used to collect cursor records...
      type  capacity_rec_t  is  record(shiftNum       number,
                                       fromDate       date,
                                       toDate         date ,
				       fromTime       number,
				       toTime         number,
				       capacityChange number,
				       actionType     number);

     type capacity_recTbl_t is table of capacity_rec_t index by binary_integer;

     l_capacity  capacity_recTbl_t ;
     l_logLevel NUMBER := fnd_log.g_current_runtime_level;
     l_params wip_logger.param_tbl_t;
     l_retStatus VARCHAR2(1);

     l_firstRow NUMBER;
     l_currRow NUMBER;
     l_lastRow NUMBER;
     l_prevRow NUMBER;
     j NUMBER;
     k NUMBER;
     flag BOOLEAN;

   BEGIN

     if (l_logLevel <= wip_constants.trace_logging) then
         l_params(1).paramName := 'p_resID';
         l_params(1).paramValue := p_resID;
         l_params(2).paramName := 'p_deptID';
         l_params(2).paramValue := p_deptID;
         l_params(3).paramName := 'p_orgID';
         l_params(3).paramValue := p_orgID;

        wip_logger.entryPoint(p_procName     => 'wip_infResSched_grp.capacityExceptions',
                              p_params       => l_params,
                              x_returnStatus => x_returnStatus);
     end if;

      open c_capacityDtls(v_resID  => p_resID,
                          v_deptID => p_deptID,
	        	  v_orgID  => p_orgID);
      fetch c_capacityDtls
        bulk collect into l_capacity ;
      close c_capacityDtls;

      for i in 1..l_capacity.count loop   -- outer most loop to loop through all the capacity exception records

          l_firstRow := x_shifts.shiftNum.FIRST;
          l_lastRow :=  x_shifts.shiftNum.LAST;
          j := l_firstRow;
          flag := FALSE;

          if (l_capacity(i).actionType = wip_constants.DELETE_WKDY) THEN     -- delete a working day

            WHILE (j <= l_lastRow) LOOP

	          IF ( Trunc(l_capacity(i).fromDate) = Trunc(x_shifts.startDate(j)) )  then
		    l_currRow := j;                               -- row that needs to be deleted
		    k := x_shifts.shiftNum.NEXT(l_currRow);
                    WHILE (k <= l_lastRow) LOOP                      -- shift all the rows one-up
		         x_shifts.shiftNum(l_currRow)  :=  x_shifts.shiftNum(k);
		         x_shifts.startDate(l_currRow) :=  x_shifts.startDate(k);
		         x_shifts.endDate(l_currRow)   :=  x_shifts.endDate(k);
                         l_currRow := k;
                         k := x_shifts.shiftNum.NEXT(k);
		    END LOOP;

		    x_shifts.shiftNum.trim();                   -- trim the last row
		    x_shifts.startDate.trim();
		    x_shifts.endDate.trim();
                    l_lastRow :=  x_shifts.shiftNum.LAST;        -- updated last row
	          END IF;
                  j :=  x_shifts.shiftNum.NEXT(j);
	    END LOOP;

          ELSIF (l_capacity(i).actionType = wip_constants.ADD_WKDY) THEN         -- add a non-working day

            WHILE (j <= l_lastRow) LOOP
              IF ( Trunc(l_capacity(i).fromDate) < Trunc(x_shifts.startDate(j)) ) THEN     -- add the day just before the shift date
                  flag := TRUE;                                                            -- that is greater than the capacity date
                  x_shifts.shiftNum.extend;   -- extend the xshifts table by one row and insert the day and then shift remaning days
                  x_shifts.startDate.extend;
                  x_shifts.endDate.extend;
                  l_lastRow :=  x_shifts.shiftNum.LAST;

                  k := l_lastRow;
                  l_prevRow := x_shifts.shiftNum.PRIOR(k);         -- now shift all the rows one-down
                  WHILE (k <> j) LOOP
                      x_shifts.shiftNum(k) := x_shifts.shiftNum(l_prevRow);
                      x_shifts.startDate(k) := x_shifts.startDate(l_prevRow);
                      x_shifts.endDate(k) := x_shifts.endDate(l_prevRow);
                      k := l_prevRow;
                      l_prevRow := x_shifts.shiftNum.PRIOR(k);
                  END LOOP;

                  x_shifts.shiftNum(j) := l_capacity(i).shiftNum;
                  x_shifts.startDate(j) := l_capacity(i).fromDate + l_capacity(i).fromTime/86400;
                  x_shifts.endDate(j) := l_capacity(i).fromDate + l_capacity(i).toTime/86400;

                  EXIT WHEN flag = TRUE;
              END IF;
              j :=  x_shifts.shiftNum.NEXT(j);
            END LOOP;

        ELSIF l_capacity(i).actionType = wip_constants.MODIFY_WKDY THEN                    -- modify capacity - modify or reduce capacity

            WHILE (j <= l_lastRow) LOOP
              IF ( Trunc(x_shifts.startDate(j)) >= Trunc(l_capacity(i).fromDate)
	           AND  Trunc(x_shifts.startDate(j)) <= Trunc(l_capacity(i).toDate) ) THEN

                  IF ( l_capacity(i).capacityChange >0 ) THEN      -- add capacity
                      x_shifts.endDate(j) := x_shifts.endDate(j) + (l_capacity(i).toTime - l_capacity(i).fromTime)/86400 ;
                  ELSE                                             -- reduce capacity
                      x_shifts.endDate(j) := x_shifts.endDate(j) - (l_capacity(i).toTime - l_capacity(i).fromTime)/86400 ;
                  END IF;

              END IF;
              j :=  x_shifts.shiftNum.NEXT(j);
            END LOOP;

        END IF;
      END LOOP;     -- end outer loop

     IF(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.capacityExceptions',
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
     END IF;
   EXCEPTION
      WHEN fnd_api.g_exc_unexpected_error THEN
         x_returnStatus := fnd_api.g_ret_sts_unexp_error;
         if(l_logLevel <= wip_constants.trace_logging) then
         wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.capacityExceptions',
                              p_procReturnStatus => x_returnStatus,
                              p_msg              => 'error',
                              x_returnStatus     => l_retStatus);
      end if;
      WHEN others  THEN
         x_returnStatus := fnd_api.g_ret_sts_unexp_error;
	 fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_infResSched_grp',
	      		         p_procedure_name => 'capacityExceptions',
			         p_error_text => SQLERRM);
         if(l_logLevel <= wip_constants.trace_logging) then
	   wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.capacityExceptions',
	  	                p_procReturnStatus => x_returnStatus,
			        p_msg              => 'unexp error: ' || SQLERRM,
			        x_returnStatus     => l_retStatus);
	 end if;
   END capacityExceptions;
   /* end of fix bug 7027946 */

  procedure forwardSchedule(p_orgID        IN number,
                            p_repLineID    in NUMBER := null,
                            p_startDate    in DATE,
                            p_range        in num_tbl_t,
                            p_schedFlag    in number,
                            x_resTbls      in out NOCOPY OP_RES_RECTBL_T,
                            x_returnStatus OUT NOCOPY VARCHAR2) is
    l_resStartDate DATE;  -- := p_startDate;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_params wip_logger.param_tbl_t;
    l_retStatus VARCHAR2(1);
    l_fromTime NUMBER;
    l_maxDate DATE;
    l_shiftStartDate DATE;
    l_currSchedSeqNum NUMBER;
    l_prevResIdx NUMBER;
    i number;
    l_schedulingBatch boolean := false;
    l_doneSchedBatch boolean;
  begin
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_repLineID';
      l_params(1).paramValue := p_repLineID;
      l_params(2).paramName := 'p_startDate';
      l_params(2).paramValue := to_char(p_startDate, g_logDateFmt);
      l_params(3).paramName := 'p_range(1)';
      l_params(3).paramValue := p_range(1);
      l_params(4).paramName := 'p_range(2)';
      l_params(4).paramValue := p_range(2);
      l_params(5).paramName := 'p_schedFlag';
      l_params(5).paramValue := p_schedFlag;

      wip_logger.entryPoint(p_procName     => 'wip_infResSched_grp.forwardSchedule',
                            p_params       => l_params,
                            x_returnStatus => x_returnStatus);
    end if;
    --get the maximum date
    select bc.calendar_end_date
      into l_maxDate
      from bom_calendars bc, mtl_parameters mp
     where mp.organization_id = p_orgID
       and mp.calendar_code = bc.calendar_code;

    while(getNextResIdx(p_range, p_schedFlag, g_forward, x_resTbls, i)) loop
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('begin scheduling resource:' || x_resTbls.resID(i), l_retStatus);
        wip_logger.log('                operation:' || x_resTbls.opSeqNum(i), l_retStatus);
        wip_logger.log('              res seq num:' || x_resTbls.resSeqNum(i), l_retStatus);
        wip_logger.log('         schedule seq num:' || x_resTbls.schedSeqNum(i), l_retStatus);
        wip_logger.log('               sched flag:' || x_resTbls.schedFlag(i), l_retStatus);
        wip_logger.log('        total usage (HRS):' || round(x_resTbls.totalDaysUsg(i)*24, g_precision), l_retStatus);

        if(l_prevResIdx is not null) then
          wip_logger.log('prev sched seq num is:' || x_resTbls.schedSeqNum(l_prevResIdx), l_retStatus);
          wip_logger.log('prev op seq num is:' || x_resTbls.opSeqNum(l_prevResIdx), l_retStatus);
        end if;
      end if;

      l_doneSchedBatch := false;
      --scheduling simultaneous
      if(l_prevResIdx is not null and
         x_resTbls.schedSeqNum(i) = x_resTbls.schedSeqNum(l_prevResIdx) and
         x_resTbls.opSeqNum(i) = x_resTbls.opSeqNum(l_prevResIdx)) then
        l_schedulingBatch := true;
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('setting sched batch to true', l_retStatus);
        end if;
      --just finished scheduling batch
      elsif(l_schedulingBatch) then
        l_schedulingBatch := false;
        l_doneSchedBatch := true;
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('setting done sched batch to true', l_retStatus);
        end if;
      end if;


      if(l_prevResIdx is null) then
        l_resStartDate := p_startDate;

      --if scheduling simultaneous, no need to get new start date, just use the previous start date
      elsif(not l_schedulingBatch) then
        l_resStartDate := getStartDate(p_range, p_schedFlag, x_resTbls, i, l_doneSchedBatch, l_prevResIdx);
      end if;

      forwardSchResource(p_orgID, l_resStartDate, l_maxDate, i, p_repLineID, x_resTbls, x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
      end if;

      l_prevResIdx := i;
    end loop;

    if(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.forwardSchedule',
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
    end if;
  exception
    when fnd_api.g_exc_unexpected_error then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.forwardSchedule',
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'error',
                             x_returnStatus     => l_retStatus);
      end if;
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_infResSched_grp',
                              p_procedure_name => 'forwardSchedule',
                              p_error_text => SQLERRM);
      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.forwardSchedule',
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'unexp error: ' || SQLERRM,
                             x_returnStatus     => l_retStatus);
      end if;
  end forwardSchedule;

  -- the resource could have been scheduled from
  function getEndDate(p_range in num_tbl_t,
                      p_schedFlag in number,
                      p_resTbls in op_res_rectbl_t,
                      p_curIdx in number,
                      p_doneSchedBatch in boolean,
                      p_prevIdx in number) return date is
    l_retStatus VARCHAR2(1);
    l_params wip_logger.param_tbl_t;
    i number;
    l_minStartDate date;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_bool boolean;
  begin
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_range(1)';
      l_params(1).paramValue := p_range(1);
      l_params(2).paramName := 'p_range(2)';
      l_params(2).paramValue := p_range(2);
      l_params(3).paramName := 'p_schedFlag';
      l_params(3).paramValue := p_schedFlag;
      l_params(4).paramName := 'p_curIdx';
      l_params(4).paramValue := p_curIdx;
      l_params(5).paramName := 'p_doneSchedBatch';
      if(p_doneSchedBatch) then l_params(5).paramValue := 'true';
      else l_params(5).paramValue := 'false';
      end if;
      l_params(6).paramName := 'p_prevIdx';
      l_params(6).paramValue := p_prevIdx;

      wip_logger.entryPoint(p_procName     => 'wip_infResSched_grp.getEndDate',
                            p_params       => l_params,
                            x_returnStatus => l_retStatus);
    end if;

    --in case we just got done scheduling a batch of simultaneous resources, get the
    --latest end date to use as the next resource's start date
    i := p_curIdx;

    if(p_doneSchedBatch) then
      if(l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('done scheduling batch', l_retStatus);
      end if;
      while(getNextResIdx(p_range, p_schedFlag, g_forward, p_resTbls, i)) loop
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('in loop', l_retStatus);
          wip_logger.log('resID' || p_resTbls.resID(i), l_retStatus);
          wip_logger.log('opSeq' || p_resTbls.opSeqNum(i), l_retStatus);
          wip_logger.log('schSeq' || p_resTbls.schedSeqNum(i), l_retStatus);
          wip_logger.log('idx' || i, l_retStatus);
        end if;
        if(p_resTbls.schedSeqNum(i) = p_resTbls.schedSeqNum(p_prevIdx) and
           p_resTbls.opSeqNum(i) = p_resTbls.opSeqNum(p_prevIdx)) then
          l_minStartDate := least(nvl(l_minStartDate, p_resTbls.startDate(i)), p_resTbls.startDate(i));
          if(l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('resource in batch. startDate:' || to_char(p_resTbls.startDate(i), g_logDateFmt), l_retStatus);
          end if;
        else
          if(l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('resource not in batch.', l_retStatus);
          end if;
          exit;
        end if;
      end loop;
    else
      l_bool := (getNextResIdx(p_range, p_schedFlag, g_forward, p_resTbls, i));
      l_minStartDate := p_resTbls.startDate(i);
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.getEndDate',
                           p_procReturnStatus => to_char(l_minStartDate),
                           p_msg              => 'finished scheduling',
                           x_returnStatus     => l_retStatus);
    end if;
    return l_minStartDate;
  end getEndDate;

  procedure backwardSchResource(p_orgID in number,
                                p_endDate in date,
                                p_minDate in date,
                                p_idx in number,
                                p_repLineID in number := null,
                                x_resTbls in out nocopy op_res_rectbl_t,
                                x_returnStatus out nocopy varchar2) is

    cursor c_shiftTimes(v_resID NUMBER,
                        v_deptID NUMBER,
                        v_orgID NUMBER,
                        v_startDate DATE,
                        v_endDate DATE) is
      select brs.shift_num shiftNum,
             bsd.shift_date + bst.from_time/86400,
             bsd.shift_date + bst.to_time/86400
        from bom_resource_shifts brs,
             mtl_parameters mp,
             bom_shift_dates bsd,
             bom_shift_times bst,
             bom_department_resources bdr
       where bdr.department_id = v_deptID
         and bdr.resource_id = v_resID
         and brs.resource_id = bdr.resource_id
         and brs.department_id = nvl(bdr.share_from_dept_id,bdr.department_id)
         and mp.organization_id = v_orgID
         and mp.calendar_code = bsd.calendar_code
         and mp.calendar_exception_set_id = bsd.exception_set_id
         and brs.shift_num = bsd.shift_num
         and bsd.shift_date between v_startDate and v_endDate --don't incorporate time into this check as it slows the query
         and bsd.seq_num is not null
         and bst.shift_num = bsd.shift_num
         and bst.calendar_code = bsd.calendar_code
       order by bsd.shift_date desc, bst.from_time desc;

    cursor c_24HrTimes(v_orgID NUMBER,
                       v_startDate DATE,
                       v_endDate DATE) is
      select -1,
             bcd.calendar_date,
             bcd.calendar_date + 1
        from mtl_parameters mp,
             bom_calendar_dates bcd
       where mp.organization_id = v_orgID
         and mp.calendar_code = bcd.calendar_code
         and mp.calendar_exception_set_id = bcd.exception_set_id
         and bcd.calendar_date between v_startDate and v_endDate
         and bcd.seq_num is not null
       order by bcd.calendar_date desc;


      --for repetitive, ignore shifts and use the line's start and stop times. However, do
      --respect the working days definition
      cursor c_repTimes(v_repLineID NUMBER,
                        v_orgID NUMBER,
                        v_startDate DATE,
                        v_endDate DATE) is
      select -1 shiftNum,
             bcd.calendar_date + wl.start_time/86400,
             bcd.calendar_date + wl.stop_time/86400
        from mtl_parameters mp,
             bom_calendar_dates bcd,
             wip_lines wl
       where mp.organization_id = v_orgID
         and mp.calendar_code = bcd.calendar_code
         and mp.calendar_exception_set_id = bcd.exception_set_id
         and wl.line_id = v_repLineID
         and bcd.seq_num is not null --working day
         and bcd.calendar_date between v_startDate and v_endDate --use stop_time to comsume tail end of a shift
       order by bcd.calendar_date desc;

     --used to collect cursor records...
     type shift_recTbl_t is record(shiftNum num_tbl_t,
                                   startDate date_tbl_t,
                                   endDate date_tbl_t);

    l_shifts shift_recTbl_t;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_params wip_logger.param_tbl_t;
    l_retStatus VARCHAR2(1);
    l_resourceScheduled boolean := false;
    l_cursorEndDate date := p_endDate;
    l_shiftEndDate date;
    l_toDate DATE;
    l_shiftLen NUMBER;
    l_remUsage NUMBER := x_resTbls.totalDaysUsg(p_idx);
    l_usgIdx NUMBER;
    i number;
    j number;
    l_tmpUsgStartDate date;
    l_tmpUsgEndDate date;
    l_endDate date;
    l_prevProcTime NUMBER := 0;
    l_dummy NUMBER; /* Bug 5660475 */
  begin

    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_orgID';
      l_params(1).paramValue := p_orgID;
      l_params(2).paramName := 'p_endDate';
      l_params(2).paramValue := to_char(p_endDate, g_logDateFmt);
      l_params(3).paramName := 'p_minDate';
      l_params(3).paramValue := to_char(p_minDate, g_logDateFmt);
      l_params(4).paramName := 'p_idx';
      l_params(4).paramValue := p_idx;
      l_params(5).paramName := 'p_repLineID';
      l_params(5).paramValue := p_repLineID;
      wip_logger.entryPoint(p_procName     => 'wip_infResSched_grp.backwardSchResource',
                            p_params       => l_params,
                            x_returnStatus => l_retStatus);
    end if;
     /* Fix for bug 5660475: If dealing with shift resource, first check if shifts are setup fine. */
    if( p_repLineID is null
        and x_resTbls.avail24Flag(p_idx) = wip_constants.no
  	and x_resTbls.schedFlag(p_idx) <> wip_constants.sched_no) then
 	wip_logger.log('This is a shift resource. Need to validate shift setup', l_retStatus);
 	begin
 	  select 1
 	  into l_dummy
 	  from dual
 	  where exists (select 1
 	                  from bom_resource_shifts brs,
 	                       mtl_parameters mp,
 	                       bom_shift_dates bsd,
 	                       bom_shift_times bst,
 	                       bom_department_resources bdr
 	                 where bdr.department_id = x_resTbls.deptID(p_idx)
 	                   and bdr.resource_id = x_resTbls.resID(p_idx)
 	                   and brs.resource_id = bdr.resource_id
 	                   and brs.department_id = nvl(bdr.share_from_dept_id,bdr.department_id)
 	                   and mp.organization_id = p_orgID
 	                   and mp.calendar_code = bsd.calendar_code
 	                   and mp.calendar_exception_set_id = bsd.exception_set_id
 	                   and brs.shift_num = bsd.shift_num
 	                   and bsd.seq_num is not null
 	                   and bst.shift_num = bsd.shift_num
 	                   and bst.calendar_code = bsd.calendar_code);
 	exception
 	   when NO_DATA_FOUND then
 	      wip_logger.log('Error: Missing shifts or shift times!', l_retStatus);
 	      fnd_message.set_name('WIP', 'WIP_SHIFT_RESOURCE');
 	      fnd_message.set_token('ENTITY1', x_resTbls.resSeqNum(p_idx));
 	      fnd_message.set_token('ENTITY2', x_resTbls.opSeqNum(p_idx));
 	      fnd_msg_pub.add;
 	      raise fnd_api.g_exc_unexpected_error;
 	end;
    end if;

    x_resTbls.usgStartIdx(p_idx) := null;
    x_resTbls.usgEndIdx(p_idx) := null;

    loop
      exit when l_resourceScheduled;
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('cursor start date: ' || to_char((l_cursorEndDate - (g_dateCursorLen - 1/86400)), g_logDateFmt), l_retStatus);
        wip_logger.log('cursor end date: ' || to_char(l_cursorEndDate, g_logDateFmt), l_retStatus);
      end if;

      --for v_endDate, subtract a second to avoid overlap between cursors.
      if(p_repLineID is not null) then
        open c_repTimes(v_repLineID => p_repLineID,
                        v_orgID     => p_orgID,
                        v_startDate => l_cursorEndDate - (g_dateCursorLen - 1/86400),
                        v_endDate   => l_cursorEndDate);
        fetch c_repTimes
          bulk collect into l_shifts.shiftNum,
                            l_shifts.startDate,
                            l_shifts.endDate;
        close c_repTimes;
      elsif(x_resTbls.avail24Flag(p_idx) = wip_constants.yes) then
        open c_24HrTimes(v_orgID     => p_orgID,
                         v_startDate => l_cursorEndDate - (g_dateCursorLen - 1/86400),
                         v_endDate   => l_cursorEndDate);
        fetch c_24HrTimes
          bulk collect into l_shifts.shiftNum,
                            l_shifts.startDate,
                            l_shifts.endDate;
        close c_24HrTimes;
      else
        open c_shiftTimes(v_resID     => x_resTbls.resID(p_idx),
                          v_deptID    => x_resTbls.deptID(p_idx),
                          v_orgID     => p_orgID,
                          v_startDate => l_cursorEndDate - (g_dateCursorLen - 1/86400),
                          v_endDate   => l_cursorEndDate);
        fetch c_shiftTimes
          bulk collect into l_shifts.shiftNum,
                            l_shifts.startDate,
                            l_shifts.endDate;

        if (l_shifts.shiftNum.count = 0 ) then
          /* Fix for bug 5660475: If shifts are not available in the date range,
	   we should continue to search in the next date range, instead of erroring out. */
	  wip_logger.log('No shifts found in this period.', l_retStatus);
          l_resourceScheduled := false;
        end if;

        close c_shiftTimes;
      end if;



      for i in 1..l_shifts.shiftNum.count loop
        if(l_shifts.endDate(i) < l_shifts.startDate(i)) then --overnight shift
          l_shifts.endDate(i) := l_shifts.endDate(i) + 1;
        end if;
        if (l_logLevel <= wip_constants.full_logging) then

          wip_logger.log('**********shiftNum:' || l_shifts.shiftNum(i), l_retStatus);
          wip_logger.log('**shift start date:' || to_char(l_shifts.startDate(i), g_logDateFmt), l_retStatus);
          wip_logger.log('****shift end date:' || to_char(l_shifts.endDate(i), g_logDateFmt), l_retStatus);
        end if;

        --if shift starts after the requested end date, skip it since none of the shift
        --can be used. don't do this in the sql query as it degrades performance
        if(l_shifts.startDate(i) > p_endDate) then
          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('skipping shift (starts after end date)', l_retStatus);
          end if;
          goto NO_FULFILL_USAGE;--end of loop
        end if;

        --if the shift ends before the end time, adjust the shift length
        l_toDate := least(l_shifts.endDate(i), p_endDate);
        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('calculated end date: ' || to_char(l_toDate, g_logDateFmt), l_retStatus);
        end if;

        l_shiftLen := l_toDate - l_shifts.startDate(i);
	  /*Bug 7015594: If shift start time is same as end time then consider it as 24 hours resource.
           This should be only done when 24 hours check is unchecked and resource is not used on repetitive line*/
          /*Bug 9355406: fixed regression caused by 7015594, if resource completion date  is the beginning of the shift, it wont be treated as 24 hrs resource*/
          if(x_resTbls.avail24Flag(p_idx) <> wip_constants.yes AND p_repLineID is null AND l_shifts.startDate(i)=l_shifts.endDate(i)) then
                   l_shiftLen := 86400;
           end if;


        if (l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('shiftLen(HRS) is ' || round(l_shiftLen*24, g_precision), l_retStatus);
        end if;

        if(round(l_shiftLen, g_precision) = 0) then
          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('skipping shift (no usage)', l_retStatus);
          end if;
          goto NO_FULFILL_USAGE;--end of loop
        end if;


        if(l_endDate is null) then
          l_endDate := l_toDate;
          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('calculated resource end date:' || to_char(l_endDate, g_logDateFmt), l_retStatus);
          end if;
        end if;

        if(round(l_remUsage, g_precision) <= round(l_shiftLen, g_precision)) then
          --shift fullfilled resource usage (round to approximately seconds)

          x_resTbls.startDate(p_idx) := l_toDate - l_remUsage;
          x_resTbls.endDate(p_idx) := l_endDate;

          --record shift usage
          x_resTbls.usgStartDate.extend(1);
          x_resTbls.usgEndDate.extend(1);
          x_resTbls.usgCumMinProcTime.extend(1);

          l_usgIdx := x_resTbls.usgStartDate.count;
          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('start idx is ' || x_resTbls.usgStartIdx(p_idx), l_retStatus);
            wip_logger.log('end idx is ' || x_resTbls.usgEndIdx(p_idx), l_retStatus);
            wip_logger.log('usg idx is ' || l_usgIdx, l_retStatus);
          end if;
          x_resTbls.usgStartIdx(p_idx) := nvl(x_resTbls.usgStartIdx(p_idx), l_usgIdx);
          x_resTbls.usgEndIdx(p_idx) := l_usgIdx;


          --shift fulfilled resource => usage start time is resource end time
          x_resTbls.usgStartDate(l_usgIdx) := x_resTbls.startDate(p_idx);
          x_resTbls.usgEndDate(l_usgIdx) := l_toDate;--l_shifts.endDate(i);

          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('start date is ' || to_char(x_resTbls.startDate(p_idx), g_logDateFmt), l_retStatus);
            wip_logger.log('end date is ' || to_char(x_resTbls.endDate(p_idx), g_logDateFmt), l_retStatus);
            wip_logger.log('usgIdx:' || l_usgIdx, l_retStatus);
            wip_logger.log('usage:' || to_char(x_resTbls.usgStartDate(l_usgIdx), g_logDateFmt) || ' - ' ||
                           to_char(x_resTbls.usgEndDate(l_usgIdx), g_logDateFmt), l_retStatus);
          end if;

          l_resourceScheduled := true; --exit outer loop
          exit; --exit inner loop

        else --shift did not fulfill resource usage
          l_remUsage := l_remUsage - l_shiftLen; --decrement remaining time

          --record shift usage
          x_resTbls.usgStartDate.extend(1);
          x_resTbls.usgEndDate.extend(1);
          x_resTbls.usgCumMinProcTime.extend(1);
          l_usgIdx := x_resTbls.usgStartDate.count;

          x_resTbls.usgStartIdx(p_idx) := nvl(x_resTbls.usgStartIdx(p_idx), l_usgIdx);
          x_resTbls.usgEndIdx(p_idx) := l_usgIdx;

          x_resTbls.usgStartDate(l_usgIdx) := l_shifts.startDate(i);
          --resource consumed until end of the shift
          x_resTbls.usgEndDate(l_usgIdx) := l_toDate;

          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('exhausted shift. remaining usage(HRS) is ' || round(l_remUsage*24, g_precision), l_retStatus);
            wip_logger.log('usage:' || to_char(x_resTbls.usgStartDate(l_usgIdx), g_logDateFmt) || ' - ' ||
                           to_char(x_resTbls.usgEndDate(l_usgIdx), g_logDateFmt), l_retStatus);
            wip_logger.log('usgIdx:' || l_usgIdx, l_retStatus);
          end if;
        end if;
        <<NO_FULFILL_USAGE>>
        null;
      end loop;

      --if the resource wasn't scheduled, increment the date and keep going.
      if(not l_resourceScheduled) then
        l_cursorEndDate := l_cursorEndDate - g_dateCursorLen;

        --if the next start date is after the end of the calendar, then we can't schedule anything
        if(l_cursorEndDate < p_minDate) then
          if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('exhausted calendar. remaining usage(HRS) is ' || round(l_remUsage*24, g_precision), l_retStatus);
          end if;
          fnd_message.set_name('WIP', 'WIP_NO_CALENDAR');
          fnd_msg_pub.add;
          raise fnd_api.g_exc_unexpected_error;
        end if;
      end if;
    end loop;

    --resource usages are in reverse chronological order. Flip them so they go start to end.
    i := x_resTbls.usgStartIdx(p_idx);
    j := x_resTbls.usgEndIdx(p_idx);
    if (l_logLevel <= wip_constants.full_logging) then
      wip_logger.log('i: ' || i || '; j: ' || j, l_retStatus);
    end if;

    while(j > i) loop
      l_tmpUsgStartDate := x_resTbls.usgStartDate(j);
      l_tmpUsgEndDate := x_resTbls.usgEndDate(j);
      x_resTbls.usgStartDate(j) := x_resTbls.usgStartDate(i);
      x_resTbls.usgEndDate(j) := x_resTbls.usgEndDate(i);
      x_resTbls.usgStartDate(i) := l_tmpUsgStartDate;
      x_resTbls.usgEndDate(i) := l_tmpUsgEndDate;
      j := j-1;
      i := i+1;
    end loop;
    for i in x_resTbls.usgStartIdx(p_idx)..x_resTbls.usgEndIdx(p_idx) loop
      x_resTbls.usgCumMinProcTime(i) := l_prevProcTime + (24*60)*(x_resTbls.usgEndDate(i)-x_resTbls.usgStartDate(i));
      l_prevProcTime := x_resTbls.usgCumMinProcTime(i);
    end loop;

    if(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.backwardSchResource',
                           p_procReturnStatus => null,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
    end if;
  exception
    when fnd_api.g_exc_unexpected_error then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.backwardSchResource',
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'error',
                             x_returnStatus     => l_retStatus);
      end if;
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_infResSched_grp',
                              p_procedure_name => 'backwardSchResource',
                              p_error_text => SQLERRM);

      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.backwardSchResource',
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'unexp error:' || SQLERRM,
                             x_returnStatus     => l_retStatus);
      end if;
  end backwardSchResource;

  procedure forwardScheduleBatch(p_orgID in number,
                                 p_repLineID in number,
                                 p_range in num_tbl_t,
                                 p_schedFlag in number,
                                 p_startIdx in number,
                                 x_resTbls in out nocopy op_res_rectbl_t,
                                 x_returnStatus out nocopy varchar2) is
    j number;
    l_minStartDate DATE;
    l_logLevel number := fnd_log.g_current_runtime_level;
    l_params wip_logger.param_tbl_t;
    l_retStatus VARCHAR2(1);
  begin
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_orgID';
      l_params(1).paramValue := p_orgID;
      l_params(2).paramName := 'p_repLineID';
      l_params(2).paramValue := p_repLineID;
      l_params(3).paramName := 'p_range(1)';
      l_params(3).paramValue := p_range(1);
      l_params(4).paramName := 'p_range(2)';
      l_params(4).paramValue := p_range(2);
      l_params(5).paramName := 'p_schedFlag';
      l_params(5).paramValue := p_schedFlag;
      l_params(6).paramName := 'p_startIdx';
      l_params(6).paramValue := p_startIdx;

      wip_logger.entryPoint(p_procName     => 'wip_infResSched_grp.forwardScheduleBatch',
                            p_params       => l_params,
                            x_returnStatus => x_returnStatus);
    end if;

    j := p_startIdx;
    l_minStartDate := x_resTbls.startDate(p_startIdx);
    --now find the min start date in the simultaneous batch and forward schedule
    --all resources in the batch from that point.
    while(getNextResIdx(p_range, p_schedFlag, g_forward, x_resTbls, j)) loop
      if(x_resTbls.schedSeqNum(j) = x_resTbls.schedSeqNum(p_startIdx) and
         x_resTbls.opSeqNum(j) = x_resTbls.opSeqNum(p_startIdx)) then
        --calculate min start date
        l_minStartDate := least(l_minStartDate, x_resTbls.startDate(j));
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('resID:' || x_resTbls.resID(j), l_retStatus);
          wip_logger.log('res start date:' || to_char(x_resTbls.startDate(j), g_logDateFmt), l_retStatus);
          wip_logger.log('min start date:' || to_char(l_minStartDate, g_logDateFmt), l_retStatus);
        end if;
        --clear backward scheduled times
        x_resTbls.usgStartIdx(j) := null;
        x_resTbls.usgEndIdx(j) := null;
      else
        j := j - 1;--decrement j to previous resource for forwardSchedule stmt below...
        exit;
      end if;
    end loop;
    forwardSchedule(p_orgID        => p_orgID,
                    p_repLineID    => p_repLineID,
                    p_startDate    => l_minStartDate,
                    p_range        => num_tbl_t(p_startIdx, j),
                    p_schedFlag    => p_schedFlag,
                    x_resTbls      => x_resTbls,
                    x_returnStatus => x_returnStatus);

    if(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.forwardScheduleBatch',
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success?',
                           x_returnStatus     => l_retStatus);
    end if;
  end forwardScheduleBatch;


  procedure backwardSchedule(p_orgID        IN NUMBER,
                             p_repLineID    in NUMBER := null,
                             p_endDate      in DATE,
                             p_range        in num_tbl_t,
                             p_schedFlag    in number,
                             x_resTbls      in out NOCOPY OP_RES_RECTBL_T,
                             x_returnStatus OUT NOCOPY VARCHAR2) is
    l_resEndDate DATE;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_params wip_logger.param_tbl_t;
    l_retStatus VARCHAR2(1);
    l_fromTime NUMBER;
    l_minDate DATE;
    l_shiftStartDate DATE;
    l_currSchedSeqNum NUMBER;
    l_prevResIdx NUMBER;
    i number;
    j number;
    l_schedulingBatch boolean := false;
    l_doneSchedBatch boolean := false;
    l_forSchedRange num_tbl_t := num_tbl_t(null, null);
  begin
    if (l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_orgID';
      l_params(1).paramValue := p_orgID;
      l_params(2).paramName := 'p_repLineID';
      l_params(2).paramValue := p_repLineID;
      l_params(3).paramName := 'p_endDate';
      l_params(3).paramValue := to_char(p_endDate, g_logDateFmt);
      l_params(4).paramName := 'p_range(1)';
      l_params(4).paramValue := p_range(1);
      l_params(5).paramName := 'p_range(2)';
      l_params(5).paramValue := p_range(2);
      l_params(6).paramName := 'p_schedFlag';
      l_params(6).paramValue := p_schedFlag;

      wip_logger.entryPoint(p_procName     => 'wip_infResSched_grp.backwardSchedule',
                            p_params       => l_params,
                            x_returnStatus => x_returnStatus);
    end if;
        --get the maximum date

    select bc.calendar_start_date
      into l_minDate
      from bom_calendars bc, mtl_parameters mp
     where mp.organization_id = p_orgID
       and mp.calendar_code = bc.calendar_code;

    while(getNextResIdx(p_range, p_schedFlag, g_backward, x_resTbls, i)) loop
      if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('begin scheduling resource:' || x_resTbls.resID(i), l_retStatus);
        wip_logger.log('                operation:' || x_resTbls.opSeqNum(i), l_retStatus);
        wip_logger.log('         schedule seq num:' || x_resTbls.schedSeqNum(i), l_retStatus);
        wip_logger.log('               sched flag:' || x_resTbls.schedFlag(i), l_retStatus);
        wip_logger.log('        total usage (HRS):' || round(x_resTbls.totalDaysUsg(i)*24, g_precision), l_retStatus);

        if(l_prevResIdx is not null) then
          wip_logger.log('prev sched seq num is:' || x_resTbls.schedSeqNum(l_prevResIdx), l_retStatus);
          wip_logger.log('prev op seq num is:' || x_resTbls.opSeqNum(l_prevResIdx), l_retStatus);
        end if;
      end if;

      l_doneSchedBatch := false;
      --scheduling simultaneous
      if(l_prevResIdx is not null and
         x_resTbls.schedSeqNum(i) = x_resTbls.schedSeqNum(l_prevResIdx) and
         x_resTbls.opSeqNum(i) = x_resTbls.opSeqNum(l_prevResIdx)) then
        l_schedulingBatch := true;
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('starting batch', l_retStatus);
        end if;

      --just finished scheduling batch
      elsif(l_schedulingBatch) then
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('done bkwd scheduling batch, now fwd sched', l_retStatus);
        end if;

        l_schedulingBatch := false;
        l_doneSchedBatch := true;

        forwardScheduleBatch(p_orgID        => p_orgID,
                             p_repLineID    => p_repLineID,
                             p_range        => p_range,
                             p_schedFlag    => p_schedFlag,
                             p_startIdx     => l_prevResIdx,
                             x_resTbls      => x_resTbls,
                             x_returnStatus => x_returnStatus);
        if(x_returnStatus <> fnd_api.g_ret_sts_success) then
          if(l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('simult batch scheduling failed', l_retStatus);
          end if;
          raise fnd_api.g_exc_unexpected_error;
        end if;
      end if;

      if(l_prevResIdx is null) then
        l_resEndDate := p_EndDate;

      --if scheduling simultaneous, no need to get new end date, just use the previous end date
      elsif(not l_schedulingBatch) then
        l_resEndDate := getEndDate(p_range, p_schedFlag, x_resTbls, i, l_doneSchedBatch, l_prevResIdx);
      end if;

      backwardSchResource(p_orgID, l_resEndDate, l_minDate, i, p_repLineID, x_resTbls, x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('backward schedule failed', l_retStatus);
        end if;
        raise fnd_api.g_exc_unexpected_error;
      end if;

      l_prevResIdx := i;
    end loop;

    if(l_schedulingBatch) then
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('done bkwd scheduling last batch, now fwd sched', l_retStatus);
        end if;
      forwardScheduleBatch(p_orgID        => p_orgID,
                           p_repLineID    => p_repLineID,
                           p_range        => p_range,
                           p_schedFlag    => p_schedFlag,
                           p_startIdx     => l_prevResIdx,
                           x_resTbls      => x_resTbls,
                           x_returnStatus => x_returnStatus);
      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('final simult batch scheduling failed', l_retStatus);
        end if;
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    if(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.backwardSchedule',
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
    end if;

  exception
    when fnd_api.g_exc_unexpected_error then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.backwardSchedule',
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'error',
                             x_returnStatus     => l_retStatus);
      end if;
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_infResSched_grp',
                              p_procedure_name => 'backwardSchedule',
                              p_error_text => SQLERRM);

      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.backwardSchedule',
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'unexp error:' || SQLERRM,
                             x_returnStatus     => l_retStatus);
      end if;
  end backwardSchedule;


  procedure schedulePriorResources(p_orgID IN NUMBER,
                                   p_repLineID NUMBER,
                                   p_opTbl in op_tbl_t,
                                   x_resTbls IN OUT NOCOPY OP_RES_RECTBL_T,
                                   x_returnStatus OUT NOCOPY VARCHAR2) is
    l_retStatus VARCHAR2(1);
    l_params wip_logger.param_tbl_t;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
  begin
    if(l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_orgID';
      l_params(1).paramValue := p_orgID;
      l_params(2).paramName := 'p_repLineID';
      l_params(2).paramValue := p_repLineID;

      wip_logger.entryPoint(p_procName => 'wip_infResSched_grp.schedulePriorResources',
                            p_params => l_params,
                            x_returnStatus => l_retStatus);
    end if;

    x_returnStatus := fnd_api.g_ret_sts_success;

    for i in 1..p_opTbl.count loop
      if(p_opTbl(i).priorsExist) then
        backwardSchedule(p_orgID => p_orgID,
                         p_repLineID    => p_repLineID,
                         p_EndDate      => p_opTbl(i).startDate,
                         p_range        => num_tbl_t(p_opTbl(i).resStartIdx, p_opTbl(i).resEndIdx),
                         p_schedFlag    => wip_constants.sched_prior,
                         x_resTbls      => x_resTbls,
                         x_returnStatus => x_returnStatus);
        if(x_returnStatus <> fnd_api.g_ret_sts_success) then
          raise fnd_api.g_exc_unexpected_error;
        end if;
      end if;
    end loop;

    if(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.schedulePriorResources',
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
    end if;
  exception
    when fnd_api.g_exc_unexpected_error then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.schedulePriorResources',
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'backward scheduling failed',
                             x_returnStatus     => l_retStatus);
      end if;
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.schedulePriorResources',
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'unexp error:' || SQLERRM,
                             x_returnStatus     => l_retStatus);
      end if;
  end schedulePriorResources;

  procedure scheduleNextResources(p_orgID IN NUMBER,
                                  p_repLineID NUMBER,
                                  p_opTbl IN OP_TBL_T,
                                  x_resTbls IN OUT NOCOPY OP_RES_RECTBL_T,
                                  x_returnStatus OUT NOCOPY VARCHAR2) is

    l_retStatus VARCHAR2(1);
    l_params wip_logger.param_tbl_t;
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
  begin
    if(l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_orgID';
      l_params(1).paramValue := p_orgID;
      l_params(2).paramName := 'p_repLineID';
      l_params(2).paramValue := p_repLineID;

      wip_logger.entryPoint(p_procName => 'wip_infResSched_grp.scheduleNextResources',
                            p_params => l_params,
                            x_returnStatus => l_retStatus);
    end if;

    x_returnStatus := fnd_api.g_ret_sts_success;

    for i in 1..p_opTbl.count loop
      if(p_opTbl(i).nextsExist) then
        forwardSchedule(p_orgID => p_orgID,
                        p_repLineID => p_repLineID,
                        p_startDate => p_opTbl(i).endDate,
                        p_range => num_tbl_t(p_opTbl(i).resStartIdx, p_opTbl(i).resEndIdx),
                        p_schedFlag => wip_constants.sched_next,
                        x_resTbls => x_resTbls,
                        x_returnStatus => x_returnStatus);
        if(x_returnStatus <> fnd_api.g_ret_sts_success) then
          raise fnd_api.g_exc_unexpected_error;
        end if;
      end if;
    end loop;

    if(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.scheduleNextResources',
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
    end if;
  exception
    when fnd_api.g_exc_unexpected_error then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.scheduleNextResources',
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'backward scheduling failed',
                             x_returnStatus     => l_retStatus);
      end if;
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_infResSched_grp',
                              p_procedure_name => 'scheduleNextResources',
                              p_error_text => SQLERRM);

      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.scheduleNextResources',
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'unexp error:' || SQLERRM,
                             x_returnStatus     => l_retStatus);
      end if;
  end scheduleNextResources;


  procedure resolvePriorExceptions(p_orgID IN NUMBER,
                                   p_repLineID  IN NUMBER,
                                   p_startDate IN DATE,
                                   x_resTbls IN OUT NOCOPY OP_RES_RECTBL_T,
                                   x_returnStatus OUT NOCOPY VARCHAR2) is
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_params wip_logger.param_tbl_t;
    l_retStatus VARCHAR2(1);
    l_opSeqNum NUMBER := null;
    l_opStartDate DATE;
    l_count NUMBER;
    l_range num_tbl_t := num_tbl_t(1, x_resTbls.resID.count);
    l_opRange num_tbl_t := num_tbl_t(null,null);
    i number;
    l_exceptionExists boolean := false;
    l_errMsg VARCHAR2(200);
  begin
    x_returnStatus := fnd_api.g_ret_sts_success;
    if(l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_orgID';
      l_params(1).paramValue := p_orgID;
      l_params(2).paramName := 'p_repLineID';
      l_params(2).paramValue := p_repLineID;
      l_params(3).paramName := 'p_startDate';
      l_params(3).paramValue := to_char(p_startDate, g_logDateFmt);
      wip_logger.entryPoint(p_procName => 'wip_infResSched_grp.resolvePriorExceptions',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
    end if;
    --this loop finds an exception
    while(getNextResIdx(l_range, wip_constants.sched_prior, g_forward, x_resTbls, i)) loop
      --if we have already found an exception and moved on to the next op, stop
      --and reschedule based on the current info
      if(l_exceptionExists) then
        if(l_opSeqNum <> x_resTbls.opSeqNum(i)) then
          exit;
        else
          l_opRange(2) := i; --prior resource is in same op, extend the schedule range
        end if;
      else --no exception found yet

        --assume current op will contain an exception.
        if(l_opSeqNum is null or l_opSeqNum <> x_resTbls.opSeqNum(i)) then
          l_opRange(1) := i;
          l_opSeqNum := x_resTbls.opSeqNum(i);
        end if;

        l_opRange(2) := i;
        l_exceptionExists := x_resTbls.startDate(i) < p_startDate;
      end if;
    end loop;

    --found a prior resource whose start date is earlier than job start...
    if(l_exceptionExists) then

      i := null;
      --going to reschedule entire job
      --delete usages
      x_resTbls.usgStartDate.delete;
      x_resTbls.usgEndDate.delete;
      x_resTbls.usgCumMinProcTime.delete;
      x_resTbls.usgStartIdx.delete;
      x_resTbls.usgEndIdx.delete;

      --delete resource times and reinitialize tables
      x_resTbls.startDate.delete;
      x_resTbls.endDate.delete;
      x_resTbls.startDate := date_tbl_t();
      x_resTbls.endDate := date_tbl_t();
      x_resTbls.startDate.extend(x_resTbls.resID.count);
      x_resTbls.endDate.extend(x_resTbls.resID.count);
      --reinitialize usage tables
      x_resTbls.usgStartIdx := num_tbl_t();
      x_resTbls.usgEndIdx := num_tbl_t();
      x_resTbls.usgStartIdx.extend(x_resTbls.resID.count);
      x_resTbls.usgEndIdx.extend(x_resTbls.resID.count);
      x_resTbls.usgStartDate := date_tbl_t();
      x_resTbls.usgEndDate := date_tbl_t();
      x_resTbls.usgCumMinProcTime := num_tbl_t();

      --forward schedule the prior resources in the 'bad' op from job start
      forwardSchedule(p_orgID        => p_orgID,
                      p_repLineID    => p_repLineID,
                      p_startDate    => p_startDate,
                      p_range        => l_opRange,
                      p_schedFlag    => wip_constants.sched_prior,
                      x_resTbls      => x_resTbls,
                      x_returnStatus => x_returnStatus);

      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        l_errMsg := 'forward schedule failed';
        raise fnd_api.g_exc_unexpected_error;
      end if;

      --find latest completion date of the prior resources
      i := null;
      while(getNextResIdx(l_opRange, wip_constants.sched_prior, g_forward, x_resTbls, i)) loop
        l_opStartDate := greatest(nvl(l_opStartDate, x_resTbls.endDate(i)), x_resTbls.endDate(i));
      end loop;

      --now midpoint schedule from the new op start date...This invocation of schedule() will not invoke
      --resolvePriorExceptions() because it is operating in midpoint mode
      schedule(p_orgID => p_orgID,
               p_repLineID => p_repLineID,
               p_startDate => l_opStartDate,
               p_opSeqNum => x_resTbls.opSeqNum(l_opRange(1)),
               p_endDebug => fnd_api.g_false,
               x_resTbls => x_resTbls,
               x_returnStatus => x_returnStatus);

      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        l_errMsg := 'schedule() failed';
        raise fnd_api.g_exc_unexpected_error;
      end if;

      --There still might be other exceptions. Call resolvePriorExceptions recursively. Note that this
      --terminates (eventually) because if schedule is called again, the resources we just re-scheduled
      --will be moved to an even later date guaranteeing the current exception will not cause any more problems...
      resolvePriorExceptions(p_orgID        => p_orgID,
                             p_repLineID    => p_repLineID,
                             p_startDate    => p_startDate,
                             x_resTbls      => x_resTbls,
                             x_returnStatus => x_returnStatus);

      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        l_errMsg := 'resolvePriorExceptions Failed';
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    if(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.resolvePriorExceptions',
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success.',
                           x_returnStatus     => l_retStatus);
    end if;
  exception
    when fnd_api.g_exc_unexpected_error then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.resolvePriorExceptions',
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'errmsg: ' || l_errMsg,
                             x_returnStatus     => l_retStatus);
      end if;
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_infResSched_grp',
                              p_procedure_name => 'resolvePriorExceptions',
                              p_error_text => SQLERRM);

      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.resolvePriorExceptions',
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'unexp error:' || SQLERRM,
                             x_returnStatus     => l_retStatus);
      end if;
  end resolvePriorExceptions;

  procedure resolveNextExceptions(p_orgID IN NUMBER,
                                  p_repLineID  IN NUMBER,
                                  p_endDate IN DATE,
                                  x_resTbls IN OUT NOCOPY OP_RES_RECTBL_T,
                                  x_returnStatus OUT NOCOPY VARCHAR2) is
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_params wip_logger.param_tbl_t;
    l_retStatus VARCHAR2(1);
    l_opSeqNum NUMBER := null;
    l_opEndDate DATE;
    l_count NUMBER;
    l_range num_tbl_t := num_tbl_t(1,x_resTbls.resID.count);
    l_opRange num_tbl_t := num_tbl_t(null,null);
    i number;
    l_exceptionExists boolean := false;
    l_errMsg VARCHAR2(200);
  begin
    x_returnStatus := fnd_api.g_ret_sts_success;
    if(l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_orgID';
      l_params(1).paramValue := p_orgID;
      l_params(2).paramName := 'p_repLineID';
      l_params(2).paramValue := p_repLineID;
      l_params(3).paramName := 'p_endDate';
      l_params(3).paramValue := to_char(p_endDate, g_logDateFmt);
      wip_logger.entryPoint(p_procName => 'wip_infResSched_grp.resolveNextExceptions',
                            p_params => l_params,
                            x_returnStatus => x_returnStatus);
    end if;
    --this loop finds an exception
    while(getNextResIdx(l_range, wip_constants.sched_next, g_backward, x_resTbls, i)) loop
      --if we have already found an exception and moved on to the next op, stop
      --and reschedule based on the current info
      if(l_exceptionExists) then
        if(l_opSeqNum <> x_resTbls.opSeqNum(i)) then
          exit;
        else
          l_opRange(1) := i; --next resource is in same op, extend the schedule range
        end if;
      else --no exception found yet
        --assume current op will contain an exception.
        if(l_opSeqNum is null or l_opSeqNum <> x_resTbls.opSeqNum(i)) then
          l_opRange(2) := i;
          l_opSeqNum := x_resTbls.opSeqNum(i);
        end if;
        l_opRange(1) := i;
        l_exceptionExists := x_resTbls.endDate(i) > p_endDate;
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('res end date: ' || to_char(x_resTbls.endDate(i), g_logDateFmt), l_retStatus);
          wip_logger.log('job end date: ' || to_char(p_endDate, g_logDateFmt), l_retStatus);
        end if;
      end if;
    end loop;

    --found a prior resource whose start date is earlier than job start...
    if(l_exceptionExists) then
      if(l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('found exception', l_retStatus);
      end if;
      i := null;
      --going to reschedule entire job
      --delete usages
      x_resTbls.usgStartDate.delete;
      x_resTbls.usgEndDate.delete;
      x_resTbls.usgCumMinProcTime.delete;
      x_resTbls.usgStartIdx.delete;
      x_resTbls.usgEndIdx.delete;

      --delete resource times and reinitialize tables
      x_resTbls.startDate.delete;
      x_resTbls.endDate.delete;
      x_resTbls.startDate := date_tbl_t();
      x_resTbls.endDate := date_tbl_t();
      x_resTbls.startDate.extend(x_resTbls.resID.count);
      x_resTbls.endDate.extend(x_resTbls.resID.count);

      --reinitialize usage tables
      x_resTbls.usgStartIdx := num_tbl_t();
      x_resTbls.usgEndIdx := num_tbl_t();
      x_resTbls.usgStartIdx.extend(x_resTbls.resID.count);
      x_resTbls.usgEndIdx.extend(x_resTbls.resID.count);
      x_resTbls.usgStartDate := date_tbl_t();
      x_resTbls.usgEndDate := date_tbl_t();
      x_resTbls.usgCumMinProcTime := num_tbl_t();

      --backward schedule the next resources in the 'bad' op from job start
      backwardSchedule(p_orgID        => p_orgID,
                       p_repLineID    => p_repLineID,
                       p_endDate      => p_endDate,
                       p_range        => l_opRange,
                       p_schedFlag    => wip_constants.sched_next,
                       x_resTbls      => x_resTbls,
                       x_returnStatus => x_returnStatus);

      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        l_errMsg := 'backward schedule failed';
        raise fnd_api.g_exc_unexpected_error;
      end if;

      --find earliest start date of the next resources
      i := null;
      while(getNextResIdx(l_opRange, wip_constants.sched_next, g_forward, x_resTbls, i)) loop
        l_opEndDate := least(nvl(l_opEndDate, x_resTbls.startDate(i)), x_resTbls.startDate(i));
      end loop;

      --now midpoint schedule from the new op start date...This invocation of schedule() will not invoke
      --resolveNextExceptions() because it is operating in midpoint mode
      schedule(p_orgID => p_orgID,
               p_repLineID => p_repLineID,
               p_endDate => l_opEndDate,
               p_opSeqNum => x_resTbls.opSeqNum(l_opRange(1)),
               p_endDebug => fnd_api.g_false,
               x_resTbls => x_resTbls,
               x_returnStatus => x_returnStatus);

      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        l_errMsg := 'schedule() failed';
        raise fnd_api.g_exc_unexpected_error;
      end if;

      --There still might be other exceptions. Call resolveNextExceptions recursively. Note that this
      --terminates (eventually) because if schedule is called again, the resources we just re-scheduled
      --will be moved to an even earlier date guaranteeing the current exception will not cause any more problems...
      resolveNextExceptions(p_orgID        => p_orgID,
                            p_repLineID    => p_repLineID,
                            p_endDate    => p_endDate,
                            x_resTbls      => x_resTbls,
                            x_returnStatus => x_returnStatus);

      if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        l_errMsg := 'resolveNextExceptions Failed';
        raise fnd_api.g_exc_unexpected_error;
      end if;
    end if;

    if(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.resolveNextExceptions',
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success.',
                           x_returnStatus     => l_retStatus);
    end if;
  exception
    when fnd_api.g_exc_unexpected_error then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.resolveNextExceptions',
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => l_errMsg,
                             x_returnStatus     => l_retStatus);
      end if;
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_infResSched_grp',
                              p_procedure_name => 'resolveNextExceptions',
                              p_error_text => SQLERRM);

      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.resolveNextExceptions',
                             p_procReturnStatus => x_returnStatus,
                             p_msg              => 'unexp error:' || SQLERRM,
                             x_returnStatus     => l_retStatus);
      end if;
  end resolveNextExceptions;




  procedure dumpResources(p_resTbls IN OP_RES_RECTBL_T) IS
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_params wip_logger.param_tbl_t;
    l_retStatus VARCHAR2(1);
    l_resCode VARCHAR2(10);
  begin

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.entryPoint(p_procName     => 'wip_infResSched_grp.dumpResources',
                            p_params       => l_params,
                            x_returnStatus => l_retStatus);
    end if;

    if(p_resTbls.resID is null or p_resTbls.resID.count < 1 and
       l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.dumpResources',
                           p_procReturnStatus => null,
                           p_msg              => 'no resources in table!',
                           x_returnStatus     => l_retStatus);
      return;
    end if;

    if (l_logLevel <= wip_constants.full_logging) then
      for i in 1..p_resTbls.resID.count loop
        select resource_code
          into l_resCode
          from bom_resources
         where resource_id = p_resTbls.resID(i);
        wip_logger.log('res:' || l_resCode || '(' || p_resTbls.resID(i) || ')', l_retStatus);
        wip_logger.log('+ usage (HRS):' || round(p_resTbls.totalDaysUsg(i)*24, 6),l_retStatus);
        wip_logger.log('+   operation:' || p_resTbls.opSeqNum(i), l_retStatus);
        wip_logger.log('+  department:' || p_resTbls.deptID(i), l_retStatus);
        wip_logger.log('+   sched seq:' || p_resTbls.schedSeqNum(i), l_retStatus);
        wip_logger.log('+     res seq:' || p_resTbls.resSeqNum(i), l_retStatus);
        wip_logger.log('+  sched flag:' || p_resTbls.schedFlag(i), l_retStatus);
        wip_logger.log('+  24hrs flag:' || p_resTbls.avail24Flag(i), l_retStatus);
        wip_logger.log('+  start date:' || to_char(p_resTbls.startDate(i), g_logDateFmt), l_retStatus);
        wip_logger.log('+    end date:' || to_char(p_resTbls.endDate(i), g_logDateFmt), l_retStatus);
        wip_logger.log('+  usg st idx:' || p_resTbls.usgStartIdx(i), l_retStatus);
        wip_logger.log('+ usg end idx:' || p_resTbls.usgEndIdx(i), l_retStatus);
        if(p_resTbls.usgStartIdx(i) is not null) then
          for j in p_resTbls.usgStartIdx(i)..p_resTbls.usgEndIdx(i) loop
            wip_logger.log('  + usage start date:' || to_char(p_resTbls.usgStartDate(j), g_logDateFmt),l_retStatus);
            wip_logger.log('  +   usage end date:' || to_char(p_resTbls.usgEndDate(j), g_logDateFmt),l_retStatus);
            wip_logger.log('  + cumulative usage:' || p_resTbls.usgCumMinProcTime(j),l_retStatus);
          end loop;
        end if;
      end loop;
    end if;
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.dumpResources',
                           p_procReturnStatus => null,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
    end if;

  exception
    when others then
    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wip_infResSched_grp.dumpResources',
                           p_procReturnStatus => null,
                           p_msg              => 'exception:' || SQLERRM,
                           x_returnStatus     => l_retStatus);
    end if;
  end dumpResources;

  procedure scheduleNoResources(p_anchorDate IN DATE,
                                x_resTbls IN OUT NOCOPY OP_RES_RECTBL_T,
                                x_returnStatus OUT NOCOPY VARCHAR2) is
    l_range num_tbl_t := num_tbl_t(1, x_resTbls.resID.count);
    l_prevRange num_tbl_t := num_tbl_t(1, null);
    l_nextRange num_tbl_t := num_tbl_t(null, x_resTbls.resID.count);
    i NUMBER;
    j NUMBER;
    k NUMBER; -- bug 8669295 (FP 8651554)
    l_logLevel NUMBER := fnd_log.g_current_runtime_level;
    l_retStatus VARCHAR2(1);
    l_params wip_logger.param_tbl_t;

    l_endDate DATE; --bug 8614399 (FP 8586766)
  begin
    if(l_logLevel <= wip_constants.trace_logging) then
      l_params(1).paramName := 'p_anchorDate';
      l_params(1).paramValue := to_char(p_anchorDate, g_logDateFmt);
      wip_logger.entryPoint(p_procName => 'wip_infResSched_grp.scheduleNoResources',
                            p_params => l_params,
                            x_returnStatus => l_retStatus);
    end if;
    x_returnStatus := fnd_api.g_ret_sts_success;

    while(getNextResIdx(l_range, wip_constants.sched_no, g_forward, x_resTbls, i)) loop

      if(l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('found scheduled no resource at ' || i, l_retStatus);
      end if;

      l_prevRange(2) := i;
      l_nextRange(1) := i;
      j := null;
      k := null; --bug 8669295 (FP 8651554)
      --find previous scheduled yes resource
      if(getNextResIdx(l_prevRange, wip_constants.sched_yes, g_backward, x_resTbls, j)) then

        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('found previous scheduled yes resource at ' || j, l_retStatus);
        end if;

      l_endDate := x_resTbls.endDate(j);
      --bug 8614399 (FP 8586766): identify the highest endDate in case of simultaneous resources
      if(x_resTbls.schedSeqNum(j) is not null) then
        for k in reverse 1..(j-1) loop --bug 8669295 (FP 8651554: range in for loop to be low..high
          if((x_resTbls.schedFlag(k) = wip_constants.sched_yes)
 	     and (x_resTbls.schedSeqNum(k) = x_resTbls.schedSeqNum(j))
 	     and (x_resTbls.endDate(k) > l_endDate)) then
 	       l_endDate := x_resTbls.endDate(k);
               if(l_logLevel <= wip_constants.full_logging) then
                 wip_logger.log('higher endDate found at: '|| k || ' date: ' || l_endDate,l_retStatus);
               end if;
           end if;
           if((k > 1) and (x_resTbls.schedSeqNum(k) <> x_resTbls.schedSeqNum(k-1))) then
             exit;
           end if;
         end loop;
       end if;
       x_resTbls.startDate(i) := l_endDate;

      --couldn't find a scheduled yes resource
      	/* Bug 6954186: Find the next scheduled resource in forward direction*/
      elsif(getNextResIdx(l_nextRange, wip_constants.sched_yes, g_forward, x_resTbls, j)) then
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('found later scheduled yes resource at ' || j, l_retStatus);
        end if;

        x_resTbls.startDate(i) := x_resTbls.startDate(j);

      else --no scheduled yes resources
        x_resTbls.startDate(i) := p_anchorDate;
        if(l_logLevel <= wip_constants.full_logging) then
          wip_logger.log('no scheduled yes resources found', l_retStatus);
        end if;
      end if;

      x_resTbls.endDate(i) := x_resTbls.startDate(i);
    end loop;
    if(l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName => 'wip_infResSched_grp.scheduleNoResources',
                           p_procReturnStatus => x_returnStatus,
                           p_msg => 'success',
                           x_returnStatus => l_retStatus);
    end if;
  exception
    when others then
      x_returnStatus := fnd_api.g_ret_sts_unexp_error;
      if(l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(p_procName => 'wip_infResSched_grp.scheduleNoResources',
                             p_procReturnStatus => x_returnStatus,
                             p_msg => 'error: ' || SQLERRM,
                             x_returnStatus => l_retStatus);
      end if;
      fnd_msg_pub.add_exc_msg(p_pkg_name => 'wip_infResSched_grp',
                              p_procedure_name => 'scheduleNoResources',
                              p_error_text => SQLERRM);
  end scheduleNoResources;
end wip_infResSched_grp;

/
