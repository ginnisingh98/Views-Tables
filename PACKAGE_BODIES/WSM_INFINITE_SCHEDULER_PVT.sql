--------------------------------------------------------
--  DDL for Package Body WSM_INFINITE_SCHEDULER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSM_INFINITE_SCHEDULER_PVT" as
/* $Header: WSMVIFSB.pls 120.3.12010000.4 2008/09/19 09:31:37 tbhande ship $ */

--private types
type num_tbl_t  is table of number;
type date_tbl_t is table of date;
type t_number   is table of number  index by binary_integer;

g_opQty                     t_number;
g_discrete_charges_exist    boolean;
mrp_debug                   varchar2(1):= fnd_profile.value('mrp_debug');

g_update_current_op         boolean;   -- Bug 6345672

--private procedures

--reads in job ops and resources (and locks the records)
procedure wsmJobReader (
        p_wipEntityID       in number,
        p_orgID             in number,
        p_scheduleMode      in number := null,
        p_opSeqNum          in out nocopy number,
        p_resSeqNum         in out nocopy number,
        p_scheQuantity      in number := null,
        p_curJobOpSeqNum    in number,
        p_curJobOpSeqId     in number,
        p_strRtgOpSeqNum    in number := null,
        p_endRtgOpSeqNum    in number := null,
        p_strRecoSeqNum     in number,
        p_endRecoSeqNum     in number,
        x_resTbls           out nocopy wip_infResSched_grp.op_res_rectbl_t,
        x_assignedUnits     out nocopy num_tbl_t,
        x_opTbl             out nocopy num_tbl_t,
        x_returnStatus      out nocopy varchar2,
        x_returnCode        out nocopy number,   -- ADD: BUG3195950
	p_new_job	    in  number
);

--writes out job op dates and resource dates
procedure wsmJobWriter (
        p_wipEntityID       in number,
        p_orgID             in number,
        p_scheduleMode      in number := null,
        p_opSeqNum          in number := null,
        p_resSeqNum         in number := null,
        p_curJobOpSeqNum    in number,
        p_strRtgOpSeqNum    in number,
        p_endRtgOpSeqNum    in number,
        p_anchorDate        in date,
        p_opTbl             in num_tbl_t,
        p_assignedUnits     in num_tbl_t,
        x_resTbls           in out nocopy wip_infressched_grp.op_res_rectbl_t,
        x_returnStatus      out nocopy varchar2,
        x_returnCode        out nocopy number -- ADD: BUG 3439417
);

-------------------------------------------------------------------------
-- This private procedure will schedule a lot based job  based on
-- resources usages, assuming infinite resource availibility. It will
-- read job/schedule information out of the relevant database tables,
-- schedule them based on input parameters, and then update the schedule
-- dates in WO, WOR, WCO, WCOR
-- OSFM scheduler will only schedule current and future operations
-- All the completed operations will not be re-scheduled
--
-- Parameters:
--  + p_initMsgList: Clear the message stack before processing?
--                   True (fnd_api.g_true) should be passed
--                   unless relevant messages are being saved
--                   on the stack. This value defaults to true.
--
--  + p_endDebug:    Pass true (fnd_api.g_true) unless the
--                   debug session will be ended at a later
--                   point by the caller. This value defaults
--                   to true
--
--  + p_orgID:       The organization of the entity.
--
--  + p_wipEntityID: The entity to reschedule.
--
--  + p_scheduleMode: will have the following values
--
--                   FORWARDS           CONSTANT NUMBER := 1;
--                   BACKWARDS          CONSTANT NUMBER := 4;
--                   MIDPOINT           CONSTANT NUMBER := 6;
--                   MIDPOINT_FORWARDS  CONSTANT NUMBER := 7;
--                   MIDPOINT_BACKWARDS CONSTANT NUMBER := 8;
--                   CURRENT_OP         CONSTANT NUMBER := 9;
--                   CURRENT_SUB_GRP    CONSTANT NUMBER := 11;
--
--                   - If p_scheduleMode = WIP_CONSTANTS.CURRENT_OP,
--                     p_opSeqNum must be given, only operation
--                     p_opSeqNum will be scheduled
--                   - If p_scheduleMode = WIP_CONSTANTS.MIDPOINT,
--                     p_opSeqNum must be given, all the current and
--                     future operations will be scheduled
--                   - If p_scheduleMode = WIP_CONSTANTS.MIDPOINT_FORWARDS,
--                     p_opSeqNum must be given, all operations after and
--                     include p_opSeqNum will be scheduled
--                   - If p_scheduleMode = WIP_CONSTANTS.MIDPOINT_BACKWARDS,
--                     p_opSeqNum must be given, all operations before and
--                     include p_opSeqNum will be scheduled
--                   - If p_scheduleMode = WIP_CONSTANTS.CURRENT_SUB_GRP,
--                     p_opSeqNum and p_resSeqNum must be given, only
--                     resources with the same (substitute_group_number,
--                     replacement_group_number) as this resource will be
--                     scheduled
--                   - If p_scheduleMode = WIP_CONSTANTS.FORWARDS, all the
--                     current and future operations will be forward
--                     scheduled,
--                     p_startDate must be given
--                   - If p_scheduleMode = WIP_CONSTANTS.BACKWARDS, all the
--                     current and future operations will be backward
--                     scheduled,
--                     p_endDate must be given
--
--  + p_startDate:   The start anchor date of either the operation
--                   or resource.
--
--  + p_endDate:     The end anchor date of either the operation
--                   or resource.
--
--  + p_opSeqNum:    Populate to midpoint schedule.
--                   Should be negative if passing current job op_seq_num,
--                   should be possitive if passing routing op_seq_num
--
--  + p_resSeqNum:   Populate to midpoint schedule down to the resource
--                   level, only used if p_opSeqNum is populated.
--                   pass -JOB_OP_SEQ_NUM if it is the current op
--
--  + p_subGrpNum:   This parameter is currently ignored
--
--  + x_returnStatus:fnd_api.g_ret_sts_success if the entity
--                   was scheduled successfully.
--
--  + x_errorMsg:    The error message. The error message will also
--                   be left on the stack.
-------------------------------------------------------------------------

procedure schedule(
        p_initMsgList   in varchar2 := null,
        p_endDebug      in varchar2 := null,
        p_orgID         in number,
        p_wipEntityID   in number,
        p_scheduleMode  in number   := null,
        p_startDate     in date     := null,
        p_endDate       in date     := null,
        p_opSeqNum      in number   := null,
        p_resSeqNum     in number   := null,
        p_scheQuantity  in number   := null,
        x_returnStatus  out nocopy varchar2,
        x_errorMsg      out nocopy varchar2,
	--OPTII-PER:Added the following arguments
	p_charges_exist	in number default NULL,
	p_new_job	in number default NULL)  is

l_logLevel          NUMBER := fnd_log.g_current_runtime_level;
l_params            wip_logger.param_tbl_t;
l_retStatus         VARCHAR2(1);
l_resTbls           wip_infResSched_grp.op_res_rectbl_t;
l_repLineID         NUMBER;
l_opTbl             num_tbl_t := num_tbl_t();
l_assignedUnits     num_tbl_t := num_tbl_t();


l_curJobOpSeqid     NUMBER := null;     -- current job op_seq_id
l_curJobOpSeqNum    NUMBER := null;     -- current job op_seq_num
l_strRtgOpSeqNum    NUMBER := null;     -- rtg_op_seq_num for routing start
l_strRtgOpSeqId     NUMBER := null;     -- rtg_op_seq_num for routing start
l_strRecoSeqNum     NUMBER := null;     -- reco_path_seq_num for routing start
l_endRtgOpSeqNum    NUMBER := null;     -- rtg_op_seq_num for routing end
l_endRtgOpSeqId     NUMBER := null;     -- rtg_op_seq_num for routing end
l_endRecoSeqNum     NUMBER := null;     -- reco_path_seq_num for routing end
l_opSeqNum          NUMBER;
l_resSeqNum         NUMBER;
l_retCode           NUMBER := 0; -- ADD BUG3195950

l_stmt_num          NUMBER;
e_wsm_error         exception;
e_skip_sche         exception;   -- ADD BUG3195950

l_job_status        NUMBER;
l_count             NUMBER := 0;
l_op_seq_incr       NUMBER;
l_copy_type         NUMBER := 0;

begin

l_stmt_num := 5;
    savepoint SP_WSMIFS_0;
    if (l_logLevel <= wip_constants.trace_logging) then
        l_params(1).paramName := 'p_wipEntityID';
        l_params(1).paramValue := p_wipEntityID;
        l_params(2).paramName := 'p_orgID';
        l_params(2).paramValue := p_orgID;
        l_params(3).paramName := 'p_scheduleMode';
        l_params(3).paramValue := p_scheduleMode;
        l_params(4).paramName := 'p_startDate';
        l_params(4).paramValue := to_char(p_startDate, 'DD-MON-YYYY HH24:MI:SS');
        l_params(5).paramName := 'p_endDate';
        l_params(5).paramValue := to_char(p_endDate, 'DD-MON-YYYY HH24:MI:SS');
        l_params(6).paramName := 'p_opSeqNum';
        l_params(6).paramValue := p_opSeqNum;
        l_params(7).paramName := 'p_resSeqNum';
        l_params(7).paramValue := p_resSeqNum;

        wip_logger.entryPoint(
                p_procName     => 'wsm_infinite_scheduler_pvt.schedule',
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
        wip_logger.log('reading lot based job...', l_retStatus);
    end if;

    l_copy_type := WSMPUTIL.get_internal_copy_type(p_wipEntityID);
    if(l_copy_type = 3) then
            fnd_message.set_name('WSM', 'WSM_NO_VALID_COPY');
            x_errorMsg := fnd_message.get;
            raise e_wsm_error;
    end if;

    BEGIN
l_stmt_num := 20.1;
        -- get the rtg op_seq_num of the routing start
        -- we assume WSM copy tables exist
        select wco.operation_seq_num,
               wco.operation_sequence_id,
               wco.reco_path_seq_num
        into   l_strRtgOpSeqNum,
               l_strRtgOpSeqId,
               l_strRecoSeqNum
        from   wsm_copy_operations wco
        where  wco.wip_entity_id = p_wipEntityID
        and    wco.network_start_end = 'S';

l_stmt_num := 20.2;
        -- get the rtg op_seq_num of the routing end
        select wco.operation_seq_num,
               wco.operation_sequence_id,
               wco.reco_path_seq_num
        into   l_endRtgOpSeqNum,
               l_endRtgOpSeqId,
               l_endRecoSeqNum
        from   wsm_copy_operations wco
        where  wco.wip_entity_id = p_wipEntityID
        and    wco.network_start_end = 'E';

        -- BD: bug 3388636, should remove this check
        -- Create job copy API will not call infinite schedule if reco_seq_num cannot be set
        --if(l_strRecoSeqNum IS NULL or l_endRecoSeqNum IS NULL) then
        --    x_errorMsg := 'Error: could not schedule a job when wco.reco_path_seq_num is not set';
        --    raise e_wsm_error;
        --end if;
        -- ED: bug 3388636

    EXCEPTION
        when no_data_found then
            x_errorMsg := 'Error: could not find routing start/end in the job copy.';
            raise e_wsm_error;
    END;

l_stmt_num := 30;
    --get l_curJobOpSeqNum and l_curJobOpSeqid
    begin
        select  count(operation_seq_num)
        into    l_count
        from    wip_operations
        where   wip_entity_id = p_wipEntityID;

        if(l_count = 0) then
            l_curJobOpSeqNum := null;
            l_curJobOpSeqid  := null;
        else
l_stmt_num := 30.1;
            -- get the job status
            select  status_type
            into    l_job_status
            from    wip_discrete_jobs
            where   wip_entity_id = p_wipEntityID;

            if(l_job_status = WIP_CONSTANTS.UNRELEASED) then
l_stmt_num := 30.2;
                -- get OP_SEQ_NUM_INCREMENT
                select nvl(OP_SEQ_NUM_INCREMENT, 10)
                into   l_op_seq_incr
                from   wsm_parameters
                where  ORGANIZATION_ID = p_orgID;

                l_curJobOpSeqNum := l_op_seq_incr;
                l_curJobOpSeqid  := l_strRtgOpSeqId;

            else -- l_job_status <> WIP_CONSTANTS.UNRELEASED
                if( p_opSeqNum < 0 and p_scheduleMode = WIP_CONSTANTS.CURRENT_OP) then
                    -- will trust parameter given by caller
l_stmt_num := 30.3;
                    -- get current operation in WO
                    select  operation_seq_num,
                            operation_sequence_id
                    into    l_curJobOpSeqNum,
                            l_curJobOpSeqid
                    from    wip_operations
                    where   wip_entity_id = p_wipEntityID
                    and     operation_seq_num = -p_opSeqNum;
                else
l_stmt_num := 30.4;
                    -- get current operation in WO
                    select  operation_seq_num,
                            operation_sequence_id
                    into    l_curJobOpSeqNum,
                            l_curJobOpSeqid
                    from    wip_operations
                    where   wip_entity_id = p_wipEntityID
                    and     (quantity_in_queue <> 0 or
                             quantity_running <> 0 or
                             quantity_waiting_to_move <> 0);
                end if;
            end if; -- l_job_status <> WIP_CONSTANTS.UNRELEASED

	    --OPTII-PERF: Check if charges exists is already known
            -- call discrete_charges_exist
	    if p_charges_exist = 1 THEN
	            g_discrete_charges_exist := true;
	    elsif p_charges_exist = 2 THEN
	           g_discrete_charges_exist := false;
	    else
	    	--charges exist is NULL..
		    if(l_job_status = WIP_CONSTANTS.UNRELEASED) then
			g_discrete_charges_exist := false;
		    elsif(l_job_status IN (WIP_CONSTANTS.COMPLETED, WIP_CONSTANTS.CLOSED)) then
			g_discrete_charges_exist := true;
		    else
			g_discrete_charges_exist := WSM_LBJ_INTERFACE_PVT.discrete_charges_exist(
				p_wipEntityID,
				p_orgID, 0);
		    end if;
	   end if;--End of check on p_charges_exist

        end if; -- l_count = 0 no WO records exist
    exception
        when no_data_found then
            l_curJobOpSeqNum := null;
            l_curJobOpSeqid  := null;
    end;

    -- bug 6345672: Update copy tables for current operation if the job is on the
    -- first op queue and no charges exist.

    if (l_count = 1) and (g_discrete_charges_exist = false) then
        g_update_current_op := true;
        if l_curJobOpSeqNum is not null then
            declare
            l_dummy   varchar2(1);
            begin
                select '1'
                into   l_dummy
                from   wip_operations
                where  wip_entity_id = p_wipEntityID
                and    operation_seq_num = l_curJobOpSeqNum
                and    nvl(quantity_running, 0) = 0
                and    nvl(quantity_waiting_to_move, 0) = 0;

                g_update_current_op := true;
            exception
                when no_data_found then
                    g_update_current_op := false;
            end;
        end if;
    else
        g_update_current_op := false;
    end if;

    if (l_logLevel <= wip_constants.full_logging) then
        if g_update_current_op then
        wip_logger.log('schedule: g_update_current_op = true', l_retStatus);
        else
        wip_logger.log('schedule: g_update_current_op = false', l_retStatus);
        end if;
    end if;
    -- end bug 6345672

    l_opSeqNum  := p_opSeqNum;
    l_resSeqNum := p_resSeqNum;

    l_stmt_num := 40;
    wsmJobReader (
            p_wipEntityID    => p_wipEntityID,
            p_orgID          => p_orgID,
            p_scheduleMode   => p_scheduleMode,
            p_opSeqNum       => l_opSeqNum,
            p_resSeqNum      => l_resSeqNum,
            p_scheQuantity   => p_scheQuantity,
            p_curJobOpSeqNum => l_curJobOpSeqNum,
            p_curJobOpSeqId  => l_curJobOpSeqid,
            p_strRtgOpSeqNum => l_strRtgOpSeqNum,
            p_endRtgOpSeqNum => l_endRtgOpSeqNum,
            p_strRecoSeqNum  => l_strRecoSeqNum,
            p_endRecoSeqNum  => l_endRecoSeqNum,
            x_resTbls        => l_resTbls,
            x_assignedUnits  => l_assignedUnits,
            x_opTbl          => l_opTbl,
            x_returnStatus   => x_returnStatus,
            x_returnCode     => l_retCode,
	    p_new_job	     => p_new_job);
    if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
    end if;
    -- BA: BUG3195950
    if(l_retCode = 1) then
        x_errorMsg := 'Skip infinite scheduling for this job, no quantity.';
        wip_logger.log(x_errorMsg, l_retStatus);
        raise e_skip_sche;
    end if;
    -- EA: BUG3195950

    if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('scheduling lot based job...', l_retStatus);
    end if;

    if(l_resTbls.opSeqNum.count <> 0) then
        l_stmt_num := 50;
        wip_infResSched_grp.schedule(
                p_orgID        => p_orgID,
                p_repLineID    => l_repLineID,
                p_startDate    => p_startDate,
                p_endDate      => p_endDate,
                p_opSeqNum     => l_opSeqNum,
                p_resSeqNum    => l_resSeqNum,
                p_endDebug     => fnd_api.g_false,
                x_resTbls      => l_resTbls,
                x_returnStatus => x_returnStatus);
        if(x_returnStatus <> fnd_api.g_ret_sts_success) then
            raise fnd_api.g_exc_unexpected_error;
        end if;

        if (l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('writing lot based job...', l_retStatus);
        end if;
    end if;

    l_stmt_num := 60;
    l_retCode := 0;
    wsmJobWriter (
            p_wipEntityID    => p_wipEntityID,
            p_orgID          => p_orgID,
            p_scheduleMode   => p_scheduleMode,
            p_opSeqNum       => l_opSeqNum,
            p_resSeqNum      => l_resSeqNum,
            p_curJobOpSeqNum => l_curJobOpSeqNum,
            p_strRtgOpSeqNum => l_strRtgOpSeqNum,
            p_endRtgOpSeqNum => l_endRtgOpSeqNum,
            p_anchorDate     => nvl(p_startDate, p_endDate),
            p_opTbl          => l_opTbl,
            p_assignedUnits  => l_assignedUnits,
            x_resTbls        => l_resTbls,
            x_returnStatus   => x_returnStatus,
            x_returnCode     => l_retCode );
    if(x_returnStatus <> fnd_api.g_ret_sts_success) then
      raise fnd_api.g_exc_unexpected_error;
    end if;

    l_stmt_num := 70;
    if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(
                p_procName         => 'wsm_infinite_scheduler_pvt.schedule',
                p_procReturnStatus => x_returnStatus,
                p_msg              => 'success',
                x_returnStatus     => l_retStatus);
        if(fnd_api.to_boolean(nvl(p_endDebug, fnd_api.g_true))) then
            wip_logger.cleanup(l_retStatus);
        end if;
    end if;

exception

    when e_wsm_error then
        rollback to SP_WSMIFS_0;
        x_returnStatus := fnd_api.g_ret_sts_unexp_error;
        if(mrp_debug = 'Y') then
            x_errorMsg := x_errorMsg || ' (# ' || l_stmt_num || ')';
        end if;

    when e_skip_sche then
        rollback to SP_WSMIFS_0;
        -- since this is just a warning, do not change return status
        if(mrp_debug = 'Y') then
            x_errorMsg := x_errorMsg || ' (# ' || l_stmt_num || ')';
        end if;

    when fnd_api.g_exc_unexpected_error then
        rollback to SP_WSMIFS_0;
        x_returnStatus := fnd_api.g_ret_sts_unexp_error;
        wip_utilities.get_message_stack(
                p_msg          => x_errorMsg,
                p_delete_stack => fnd_api.g_false);
        if (l_logLevel <= wip_constants.trace_logging) then
            wip_logger.exitPoint(
                    p_procName         => 'wsm_infinite_scheduler_pvt.schedule',
                    p_procReturnStatus => x_returnStatus,
                    p_msg              => 'error: ' || x_errorMsg,
                    x_returnStatus     => l_retStatus);
            if(fnd_api.to_boolean(nvl(p_endDebug, fnd_api.g_true))) then
                wip_logger.cleanup(l_retStatus);
            end if;
        end if;
        if(mrp_debug = 'Y') then
            x_errorMsg := x_errorMsg || ' (# ' || l_stmt_num || ')';
        end if;

    when others then
        rollback to SP_WSMIFS_0;
        x_returnStatus := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.add_exc_msg(
                p_pkg_name       => 'wsm_infinite_scheduler_pvt',
                p_procedure_name => 'schedule',
                p_error_text => SQLERRM);
        wip_utilities.get_message_stack(
                p_msg => x_errorMsg,
                p_delete_stack => fnd_api.g_false);
        if (l_logLevel <= wip_constants.trace_logging) then
            wip_logger.exitPoint(
                p_procName         => 'wsm_infinite_scheduler_pvt.schedule',
                p_procReturnStatus => x_returnStatus,
                p_msg              => 'unexp error: ' || x_errorMsg,
                x_returnStatus     => l_retStatus);
            if(fnd_api.to_boolean(nvl(p_endDebug, fnd_api.g_true))) then
                wip_logger.cleanup(l_retStatus);
            end if;
        end if;
        if(mrp_debug = 'Y') then
            x_errorMsg := x_errorMsg || ' (# ' || l_stmt_num || ')';
        end if;

end schedule;


procedure wsmJobReader (
        p_wipEntityID       in number,
        p_orgID             in number,
        p_scheduleMode      in number := null,
        p_opSeqNum          in out nocopy number,
        p_resSeqNum         in out nocopy number,
        p_scheQuantity      in number := null,
        p_curJobOpSeqNum    in number,
        p_curJobOpSeqId     in number,
        p_strRtgOpSeqNum    in number := null,
        p_endRtgOpSeqNum    in number := null,
        p_strRecoSeqNum     in number,
        p_endRecoSeqNum     in number,
        x_resTbls           out nocopy wip_infResSched_grp.op_res_rectbl_t,
        x_assignedUnits     out nocopy num_tbl_t,
        x_opTbl             out nocopy num_tbl_t,
        x_returnStatus      out nocopy varchar2,
        x_returnCode        out nocopy number, -- ADD: BUG3195950
	p_new_job	    in  number
) is

l_loglevel          NUMBER := fnd_log.g_current_runtime_level;
l_params            wip_logger.param_tbl_t;
l_retStatus         VARCHAR2(1);
l_hrUOM             VARCHAR2(3);
l_hrVal             NUMBER;
l_uomClass          VARCHAR2(10);
l_dummy             NUMBER;
l_cnt_wor           number;
l_cnt_wo            number;
l_idx               number;

l_cur_job_op_seq    NUMBER;
l_the_rec_seq_num   NUMBER;
l_fst_rec_seq_num   NUMBER;
l_lst_rec_seq_num   NUMBER;
l_res_seq_num       NUMBER;
l_sub_grp_num       NUMBER;
l_rpl_grp_num       NUMBER;
l_levels            num_tbl_t := num_tbl_t();

l_job_start_qty     number;
l_job_scrap_qty     number;
l_job_quantity      number;
l_cur_op_yield      number  := 1;
l_qty_posi          number;     -- 1: queue/running 2: to move
l_rec_seq_num       number;
l_opSeqTbl          num_tbl_t := num_tbl_t();
l_opYieldTbl        num_tbl_t := num_tbl_t();
l_baseTypes         num_tbl_t := num_tbl_t();
l_scheFlagOrder     num_tbl_t := num_tbl_t();

l_stat_num          number;
e_skip_sche         exception;  -- BUG3195950

--the following cursors simply lock the records wsmJobWriter() will later modify
cursor c_WO is
  select 1
    from wip_operations
   where wip_entity_id = p_wipEntityID
     and organization_id = p_orgID
     for update nowait;

cursor c_WRO is
  select 1
    from wip_requirement_operations
   where wip_entity_id = p_wipEntityID
     and organization_id = p_orgID
     for update nowait;

cursor c_WOR is
  select 1
    from wip_operation_resources
   where wip_entity_id = p_wipEntityID
     and organization_id = p_orgID
     for update nowait;

cursor c_WORU is
  select 1
    from wip_operation_resource_usage
   where wip_entity_id = p_wipEntityID
     and organization_id = p_orgID
     for update nowait;

cursor c_WORI is
  select 1
    from wip_op_resource_instances
   where wip_entity_id = p_wipEntityID
     and organization_id = p_orgID
     for update nowait;

cursor c_WCO is
  select 1
    from wsm_copy_operations
   where wip_entity_id = p_wipEntityID
     and organization_id = p_orgID
     for update nowait;

cursor c_WCOR is
  select 1
    from wsm_copy_op_resources
   where wip_entity_id = p_wipEntityID
     and organization_id = p_orgID
     for update nowait;

cursor c_WCRO is
  select 1
    from wsm_copy_requirement_ops
   where wip_entity_id = p_wipEntityID
     and organization_id = p_orgID
     for update nowait;

cursor c_WCORU is
  select 1
    from wsm_copy_op_resource_usage
   where wip_entity_id = p_wipEntityID
     and organization_id = p_orgID
     for update nowait;

cursor c_WCORI is
  select 1
    from wsm_copy_op_resource_instances
   where wip_entity_id = p_wipEntityID
     and organization_id = p_orgID
     for update nowait;

-- cursor to fetch all the resources
cursor c_op_resources (c_cur_job_op_seq   number,
                       c_fst_rec_seq_seq  number,
                       c_lst_rec_seq_seq  number,
                       c_res_seq_num      number,
                       c_sub_grp_num      number,
                       c_rpl_grp_num      number) IS
    -- current job op --
    select 0 lvl,
           -c_cur_job_op_seq,
           wor.resource_id,
           NVL(wor.department_id, wo.department_id),
           wor.resource_seq_num        RES_SEQ_NUM,
           wor.schedule_seq_num        RES_SCH_NUM,
           wor.scheduled_flag,
           decode(wor.scheduled_flag, 3, 1, 1, 2, 4, 3, null)
                                       SCHE_FLAG_ORDER,
           bdr.available_24_hours_flag,
           --Bug 4554494
           --l_hrVal * nvl(muc.conversion_rate,0)
           nvl(muc.conversion_rate,0)
               * decode(wor.basis_type, wip_constants.per_lot, 1, wdj.start_quantity)
               * wor.usage_rate_or_amount
               / ( 24 * nvl(l_hrVal,1)*least(wor.assigned_units, bdr.capacity_units)
                      * nvl(bdr.utilization, 1) * nvl(bdr.efficiency, 1) ),
           wor.basis_type,
           wor.assigned_units
      from wip_discrete_jobs wdj,
           wip_operations wo,
           wip_operation_resources wor,
           mtl_uom_conversions muc,
           bom_department_resources bdr
     where wdj.wip_entity_id = p_wipEntityID
       and wdj.organization_id = p_orgID
       and wdj.wip_entity_id = wo.wip_entity_id
       and wdj.organization_id = wo.organization_id
       and wo.wip_entity_id = wor.wip_entity_id
       and wo.organization_id = wor.organization_id
       and wo.operation_seq_num = wor.operation_seq_num
       and wor.resource_seq_num
               = decode(c_res_seq_num,
                        null, wor.resource_seq_num,
                        decode(c_sub_grp_num,
                               null, c_res_seq_num,
                               wor.resource_seq_num))
       and nvl(wor.substitute_group_num, 0)
               = decode(c_res_seq_num,
                        null, nvl(wor.substitute_group_num, 0),
                        decode(c_sub_grp_num,
                               null, nvl(wor.substitute_group_num, 0),
                               c_sub_grp_num))
       and nvl(wor.replacement_group_num, 0)
               = decode(c_res_seq_num,
                        null, nvl(wor.replacement_group_num, 0),
                        decode(c_sub_grp_num,
                               null, nvl(wor.replacement_group_num, 0),
                               c_rpl_grp_num))
       and wo.operation_seq_num = c_cur_job_op_seq
       and bdr.resource_id = wor.resource_id
       and bdr.department_id = nvl(wor.department_id, wo.department_id)
       and wor.uom_code = muc.uom_code (+)
       and muc.uom_class (+)= l_uomClass
       and muc.inventory_item_id (+)= 0
       and c_cur_job_op_seq IS NOT NULL
    union
    -- future rtg ops --
    select wco.reco_path_seq_num  lvl,
           wcor.operation_seq_num,
           wcor.resource_id,
           NVL(wcor.department_id, wco.department_id),
           wcor.resource_seq_num   RES_SEQ_NUM,
           wcor.schedule_seq_num   RES_SCH_NUM,
           wcor.schedule_flag,
           decode(wcor.schedule_flag, 3, 1, 1, 2, 4, 3, null)
                                   SCHE_FLAG_ORDER,
           bdr.available_24_hours_flag,
           --Bug 4554494
           --l_hrVal * nvl(muc.conversion_rate,0)
           nvl(muc.conversion_rate,0)
               * decode(wcor.basis_type, wip_constants.per_lot, 1, wdj.start_quantity)
               * wcor.usage_rate_or_amount
               / ( 24 * nvl(l_hrVal,1)* least(wcor.assigned_units, bdr.capacity_units)
                      * nvl(bdr.utilization, 1) * nvl(bdr.efficiency, 1) ),
           wcor.basis_type,
           wcor.assigned_units
      from wip_discrete_jobs wdj,
           wsm_copy_operations wco,
           wsm_copy_op_resources wcor,
           mtl_uom_conversions muc,
           bom_department_resources bdr
     where wdj.wip_entity_id = p_wipEntityID
       and wdj.organization_id = p_orgID
       and wdj.wip_entity_id = wco.wip_entity_id
       and wdj.organization_id = wco.organization_id
       and wco.wip_entity_id = wcor.wip_entity_id
       and wco.organization_id = wcor.organization_id
       and wco.operation_seq_num = wcor.operation_seq_num
       and (wco.reco_path_seq_num between c_fst_rec_seq_seq and c_lst_rec_seq_seq)
       and wcor.recommended = 'Y'
       and wcor.resource_seq_num
               = decode(c_res_seq_num,
                        null, wcor.resource_seq_num,
                        decode(c_sub_grp_num,
                               null, c_res_seq_num,
                               wcor.resource_seq_num))
       and nvl(wcor.substitute_group_num, 0)
               = decode(c_res_seq_num,
                        null, nvl(wcor.substitute_group_num, 0),
                        decode(c_sub_grp_num,
                               null, nvl(wcor.substitute_group_num, 0),
                               c_sub_grp_num))
       and nvl(wcor.replacement_group_num, 0)
               = decode(c_res_seq_num,
                        null, nvl(wcor.replacement_group_num, 0),
                        decode(c_sub_grp_num,
                               null, nvl(wcor.replacement_group_num, 0),
                               c_rpl_grp_num))
       and bdr.resource_id = wcor.resource_id
       and bdr.department_id = nvl(wcor.department_id, wco.department_id)
       and wcor.uom_code = muc.uom_code (+)
       and muc.uom_class (+)= l_uomClass
       and muc.inventory_item_id (+)= 0
  order by lvl, SCHE_FLAG_ORDER, RES_SEQ_NUM, RES_SCH_NUM;

-- cursor to fetch the operations
cursor c_operations (c_cur_job_op_seq   number,
                     c_fst_rec_seq_seq  number,
                     c_lst_rec_seq_seq  number) is
    -- current job op --
    select 0 lvl,
           -c_cur_job_op_seq OP_SEQ_NUM
      from dual
     where c_cur_job_op_seq IS NOT NULL
    union
    -- other rtg ops --
    select wco.reco_path_seq_num  lvl,
           operation_seq_num   OP_SEQ_NUM
      from wsm_copy_operations wco
     where wco.wip_entity_id = p_wipEntityID
       and (wco.reco_path_seq_num between c_fst_rec_seq_seq and c_lst_rec_seq_seq)
     order by lvl;

-- cursor to fetch all future operations
cursor c_future_op_yield (
          c_fst_rec_seq_seq  number,
          c_lst_rec_seq_seq  number) is
    select operation_seq_num,
           NVL(yield, 1.0)
      from wsm_copy_operations wco
     where wco.wip_entity_id = p_wipEntityID
       and (wco.reco_path_seq_num between c_fst_rec_seq_seq and c_lst_rec_seq_seq)
     order by wco.reco_path_seq_num;

BEGIN

l_stat_num := 10;
    if (l_logLevel <= wip_constants.trace_logging) then
        l_params(1).paramName := 'p_wipEntityID';
        l_params(1).paramValue := p_wipEntityID;
        l_params(2).paramName := 'p_orgID';
        l_params(2).paramValue := p_orgID;
        l_params(3).paramName := 'p_scheduleMode';
        l_params(3).paramValue := p_scheduleMode;
        l_params(4).paramName := 'p_curJobOpSeqNum';
        l_params(4).paramValue := p_curJobOpSeqNum;
        l_params(5).paramName := 'p_curJobOpSeqId';
        l_params(5).paramValue := p_curJobOpSeqId;
        l_params(6).paramName := 'p_strRtgOpSeqNum';
        l_params(6).paramValue := p_strRtgOpSeqNum;
        l_params(7).paramName := 'p_endRtgOpSeqNum';
        l_params(7).paramValue := p_endRtgOpSeqNum;
        l_params(8).paramName := 'p_strRecoSeqNum';
        l_params(8).paramValue := p_strRecoSeqNum;
        l_params(9).paramName := 'p_endRecoSeqNum';
        l_params(9).paramValue := p_endRecoSeqNum;

        wip_logger.entryPoint(
            p_procName     => 'wsm_infinite_scheduler_pvt.wsmJobReader',
            p_params       => l_params,
            x_returnStatus => l_retStatus);
    end if;
    x_returnStatus := fnd_api.g_ret_sts_success;
    x_returnCode   := 0;  -- ADD: BUG3195950

l_stat_num := 20;
    l_hrUOM := fnd_profile.value('BOM:HOUR_UOM_CODE');
    select conversion_rate, uom_class
      into l_hrVal, l_uomClass
      from mtl_uom_conversions
     where uom_code = l_hrUOM
       and nvl(disable_date, sysdate + 1) > sysdate
       and inventory_item_id = 0;


    ----------------------------------------------------------
    -- set the default value for
    -- l_cur_job_op_seq, l_fst_rec_seq_num, l_lst_rec_seq_num,
    -- l_res_seq_num, l_sub_grp_num, l_rpl_grp_num
    ----------------------------------------------------------
    l_cur_job_op_seq   := p_curJobOpSeqNum;
    l_lst_rec_seq_num  := p_endRecoSeqNum;
    l_res_seq_num      := null;
    l_sub_grp_num      := null;
    l_rpl_grp_num      := null;

l_stat_num := 30;
    if(l_cur_job_op_seq IS NULL) then
        -- get the reco_path_seq_num for routing start, this should happen during
        -- job creation, usually l_fst_rec_seq_num should not be null
        l_fst_rec_seq_num := p_strRecoSeqNum;
    else
        if(p_curJobOpSeqId IS NULL) then
            -- currently in a operation outside routing
            l_fst_rec_seq_num := null;
        else
l_stat_num := 30.1;
            BEGIN
                select wco.reco_path_seq_num
                into   l_fst_rec_seq_num
                from   WSM_COPY_OPERATIONS  wco
                where  wco.wip_entity_id  = p_wipEntityID
                and    wco.operation_sequence_id = p_curJobOpSeqId;
            EXCEPTION
                when no_data_found then
                    l_fst_rec_seq_num := null;
            END;
        end if;

        if l_fst_rec_seq_num IS NOT NULL then
            -- pointing to the next op of the current operation
            l_fst_rec_seq_num := l_fst_rec_seq_num +1;
            if (l_fst_rec_seq_num > l_lst_rec_seq_num) then
                -- current op is the rtg end, no future operation exists !!
                l_fst_rec_seq_num := null;
                l_lst_rec_seq_num := null;
            end if;
        end if;
    end if;

    -- Note: l_fst_rec_seq_num IS NULL means future op unknown !!
    -- only current operation will be scheduled
    if(l_fst_rec_seq_num IS NULL) then
        l_lst_rec_seq_num := null;
    end if;

l_stat_num := 40;
    -- get reco_path_seq_num for p_opSeqNum
    if(p_opSeqNum IS NOT NULL and p_opSeqNum > 0) then
        BEGIN
            select wco.reco_path_seq_num
            into   l_the_rec_seq_num
            from   WSM_COPY_OPERATIONS  wco
            where  wco.wip_entity_id  = p_wipEntityID
            and    wco.operation_seq_num = p_opSeqNum;
        EXCEPTION
            when no_data_found then
                l_the_rec_seq_num := null;
        END;
    end if;

l_stat_num := 50;
    -- get job start quantity
    select  wdj.start_quantity,
            wdj.quantity_scrapped
    into    l_job_start_qty,
            l_job_scrap_qty
    from    wip_discrete_jobs wdj
    where   wdj.wip_entity_id = p_wipEntityID;
    -- BA: BUG3195950
    if(l_job_start_qty = 0 or
       l_job_start_qty - l_job_scrap_qty = 0) then
        raise e_skip_sche;
    end if;
    -- EA: BUG3195950

l_stat_num := 60;
    g_opQty.delete;
    -- get scheduled quantity for all the future operations
    if(l_cur_job_op_seq IS NOT NULL) then
        -- WO records exist
        -- get current job quantity
        select  wo.quantity_in_queue + wo.quantity_running
                    + wo.quantity_waiting_to_move,
                nvl(wo.operation_yield, 1),
                decode(wo.quantity_waiting_to_move,
                       0, 1, 2)
        into    l_job_quantity,
                l_cur_op_yield,
                l_qty_posi
        from    wip_operations wo
        where   wo.wip_entity_id = p_wipEntityID
        and     wo.operation_seq_num = l_cur_job_op_seq;

        if(l_job_quantity = 0) then
            -- This can happen for an unreleased job or during move to an un-scheduled op
            if(p_scheQuantity IS NULL) then
                l_job_quantity := l_job_start_qty - l_job_scrap_qty;
            else
                l_job_quantity := p_scheQuantity;
            end if;
            l_qty_posi     := 1;
        end if;

        g_opQty(-l_cur_job_op_seq) := l_job_quantity;

        -- get operation yield
        if(l_fst_rec_seq_num IS NOT NULL) then
l_stat_num := 60.1;
            open c_future_op_yield (
                    l_fst_rec_seq_num,
                    l_lst_rec_seq_num);
            fetch c_future_op_yield bulk collect into
                    l_opSeqTbl,
                    l_opYieldTbl;
            close c_future_op_yield;

            -- caculate operation quantity based on yield
            if(l_opSeqTbl.exists(1)) then
                if(l_qty_posi = 1) then
                    g_opQty(l_opSeqTbl(1)) := l_job_quantity * l_cur_op_yield;
                else
                    g_opQty(l_opSeqTbl(1)) := l_job_quantity;
                end if;

                for i in 2..l_opSeqTbl.last
                loop
                    g_opQty(l_opSeqTbl(i)) :=  g_opQty(l_opSeqTbl(i-1)) * l_opYieldTbl(i-1);
                end loop;
            end if;
        end if;
    else
l_stat_num := 60.2;
        -- get current job quantity
        l_job_quantity := l_job_start_qty;
        l_qty_posi     := 1;

        -- get operation yield
        open c_future_op_yield (
                p_strRecoSeqNum,
                p_endRecoSeqNum);
        fetch c_future_op_yield bulk collect into
                l_opSeqTbl,
                l_opYieldTbl;
        close c_future_op_yield;

        -- caculate operation quantity based on yield
        g_opQty(l_opSeqTbl(1)) := l_job_quantity;
        for i in 2..l_opSeqTbl.last
        loop
            g_opQty(l_opSeqTbl(i)) := g_opQty(l_opSeqTbl(i-1)) * l_opYieldTbl(i-1);
        end loop;
    end if;

l_stat_num := 70;
    -- set the parameters to open the cursor
    if(p_scheduleMode = WIP_CONSTANTS.FORWARDS) then
        --if(l_cur_job_op_seq IS NOT NULL) then
        --    p_opSeqNum := -l_cur_job_op_seq;
        --else
        --    p_opSeqNum := p_strRtgOpSeqNum;
        --end if;
        p_opSeqNum  := null;
        p_resSeqNum := null;
    elsif(p_scheduleMode = WIP_CONSTANTS.BACKWARDS) then
        --p_opSeqNum  := p_endRtgOpSeqNum;
        p_opSeqNum  := null;
        p_resSeqNum := null;
    elsif(p_scheduleMode = WIP_CONSTANTS.MIDPOINT_FORWARDS) then
        if( p_opSeqNum > 0) then
            -- should always ignore current op
            l_cur_job_op_seq  := null;
            l_fst_rec_seq_num := l_the_rec_seq_num;
        end if;
    elsif(p_scheduleMode = WIP_CONSTANTS.MIDPOINT_BACKWARDS) then
        if(p_opSeqNum > 0) then
            -- should fetch up to p_opSeqNum
            l_lst_rec_seq_num := l_the_rec_seq_num;
        else
            l_fst_rec_seq_num := null;
        end if;
    elsif(p_scheduleMode in (WIP_CONSTANTS.CURRENT_OP,
                             WIP_CONSTANTS.CURRENT_SUB_GRP)) then
        if(p_opSeqNum > 0) then
            -- should always ignore current op, fetch p_opSeqNum only
            l_cur_job_op_seq  := null;
            l_fst_rec_seq_num := l_the_rec_seq_num;
            l_lst_rec_seq_num := l_the_rec_seq_num;
        else
            l_fst_rec_seq_num := null;
        end if;

        if(p_scheduleMode = WIP_CONSTANTS.CURRENT_SUB_GRP) then
            l_res_seq_num    := p_resSeqNum;
            if(p_opSeqNum > 0) then
l_stat_num := 70.1;
                select substitute_group_num,
                       replacement_group_num
                into   l_sub_grp_num,
                       l_rpl_grp_num
                from   WSM_COPY_OP_RESOURCES
                where  wip_entity_id = p_wipEntityID
                and    operation_seq_num = p_opSeqNum
                and    resource_seq_num  = p_resSeqNum;
            else
l_stat_num := 70.2;
                select substitute_group_num,
                       replacement_group_num
                into   l_sub_grp_num,
                       l_rpl_grp_num
                from   WIP_OPERATION_RESOURCES
                where  wip_entity_id = p_wipEntityID
                and    operation_seq_num = -p_opSeqNum
                and    resource_seq_num  = p_resSeqNum;
            end if;
        end if;
    end if;

l_stat_num := 80;
    -- bulk fetch all the resources
    open c_op_resources (
            l_cur_job_op_seq,
            l_fst_rec_seq_num,
            l_lst_rec_seq_num,
            l_res_seq_num,
            l_sub_grp_num,
            l_rpl_grp_num);
    fetch c_op_resources bulk collect into
            l_levels,
            x_resTbls.opSeqNum,
            x_resTbls.resID,
            x_resTbls.deptID,
            x_resTbls.resSeqNum,
            x_resTbls.schedSeqNum,
            x_resTbls.schedFlag,
            l_scheFlagOrder,
            x_resTbls.avail24Flag,
            x_resTbls.totalDaysUsg,
            l_baseTypes,
            x_assignedUnits;
    close c_op_resources;

    if(x_resTbls.opSeqNum.count <> 0) then
        -- update totalDaysUsg based on scheduled quantity
        l_idx := x_resTbls.opSeqNum.first;
        while (l_idx IS NOT NULL)
        loop
            if(l_baseTypes(l_idx) <> wip_constants.per_lot) then
                x_resTbls.totalDaysUsg(l_idx) :=
                    x_resTbls.totalDaysUsg(l_idx)
                    * g_opQty(x_resTbls.opSeqNum(l_idx))/l_job_start_qty;
            end if;
            l_idx := x_resTbls.opSeqNum.next(l_idx);
        end loop;
    end if;

l_stat_num := 90;
    -- Note: not all operations have resources. Thus we have to select the ops from the db
    open c_operations (
            l_cur_job_op_seq,
            l_fst_rec_seq_num,
            l_lst_rec_seq_num);
    fetch c_operations bulk collect into
            l_levels,
            x_opTbl;
    close c_operations;

l_stat_num := 100;
    --lock the job
    IF p_new_job <> 1 THEN
    select 1
      into l_dummy
      from wip_discrete_jobs
     where wip_entity_id = p_wipEntityID
       and organization_id = p_orgID
       for update nowait;
    END IF;

l_stat_num := 110;
    --lock WO/WCO, WRO/WCRO
    l_cnt_wo := 0;
    l_idx := x_opTbl.first;
    while(l_idx IS NOT NULL and x_opTbl(l_idx) < 0)
    loop
        l_cnt_wo := l_cnt_wo +1;
        l_idx := x_opTbl.next(l_idx);
    end loop;

l_stat_num := 120;
    --if(l_cnt_wo>=1) then
    if(l_cnt_wo>=1) AND (p_new_job <> 1) then
        open  c_WO;
        close c_WO;
        open  c_WRO;
        close c_WRO;
    end if;
    --if(x_opTbl.count>l_cnt_wo) then
    if(x_opTbl.count>l_cnt_wo) AND (p_new_job <> 1) then
        open  c_WCO;
        close c_WCO;
        open  c_WCRO;
        close c_WCRO;
    end if;

l_stat_num := 130;
    if(x_resTbls.opSeqNum.count <> 0) then
        --lock WOR/WCOR, WORU/WCORU, WORI/WCORI
        l_cnt_wor := 0;
        l_idx := x_resTbls.opSeqNum.first;
        while(l_idx IS NOT NULL and x_resTbls.opSeqNum(l_idx) < 0)
        loop
            l_cnt_wor := l_cnt_wor +1;
            l_idx := x_resTbls.opSeqNum.next(l_idx);
        end loop;

        if(l_cnt_wor>=1) AND (p_new_job <> 1) then
            open  c_WOR;
            close c_WOR;
            open  c_WORU;
            close c_WORU;
            open  c_WORI;
            close c_WORI;
        end if;
        if(x_resTbls.opSeqNum.count>l_cnt_wor) AND (p_new_job <> 1) then
            open  c_WCOR;
            close c_WCOR;
            open  c_WCORU;
            close c_WCORU;
            open  c_WCORI;
            close c_WCORI;
        end if;
    end if;

    if (l_logLevel <= wip_constants.trace_logging) then
      wip_logger.exitPoint(p_procName         => 'wsm_infinite_scheduler_pvt.wsmJobReader',
                           p_procReturnStatus => x_returnStatus,
                           p_msg              => 'success',
                           x_returnStatus     => l_retStatus);
    end if;

EXCEPTION
    -- BA: BUG3195950
    when e_skip_sche then
        if (l_logLevel <= wip_constants.trace_logging) then
            wip_logger.exitPoint(p_procName         => 'wsm_infinite_scheduler_pvt.wsmJobReader',
                                 p_procReturnStatus => x_returnStatus,
                                 p_msg              => 'success',
                                 x_returnStatus     => l_retStatus);
        end if;
        x_returnCode := 1;
    -- EA: BUG3195950
    when others then
        x_returnStatus := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.add_exc_msg(
                p_pkg_name       => 'wsm_infinite_scheduler_pvt',
                p_procedure_name => 'wsmJobReader',
                p_error_text     => SQLERRM || ' (reader #' || l_stat_num || ')' );
        if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(
                p_procName         => 'wsm_infinite_scheduler_pvt.wsmJobReader',
                p_procReturnStatus => x_returnStatus,
                p_msg              => 'unexp error: ' || SQLERRM || ' (reader #' || l_stat_num || ')',
                x_returnStatus     => l_retStatus);
        end if;
END wsmJobReader;


procedure wsmJobWriter(
        p_wipEntityID       in NUMBER,
        p_orgID             in NUMBER,
        p_scheduleMode      in number := null,
        p_opSeqNum          in number := null,
        p_resSeqNum         in number := null,
        p_curJobOpSeqNum    in number,
        p_strRtgOpSeqNum    in number,
        p_endRtgOpSeqNum    in number,
        p_anchorDate        in date,
        p_opTbl             in num_tbl_t,
        p_assignedUnits     in num_tbl_t,
        x_resTbls           in out nocopy wip_infResSched_grp.op_res_rectbl_t,
        x_returnStatus      out nocopy varchar2,
        x_returnCode        out nocopy number -- ADD: BUG 3439417
) is

type t_date is table of date    index by binary_integer;

l_hashOpSDate       t_date;
l_hashOpEDate       t_date;
l_hashOpSDateYes    t_date;
l_hashOpEDateYes    t_date;

l_OpStartDate       date_tbl_t := date_tbl_t();
l_OpEndDate         date_tbl_t := date_tbl_t();
l_OpQty             num_tbl_t  := num_tbl_t();

l_jobStartDate      date := null;
l_jobComplDate      date := null;
l_newJobStartDate   date := null;   -- ADD: bug 3439417
l_newJobComplDate   date := null;   -- ADD: bug 3439417
l_minDate           date;
l_maxDate           date;
l_minDateYes        date;
l_currentDate       date;

l_op_seq_incr       number;
l_curOp             number;
l_retStatus         VARCHAR2(1);
l_logLevel          NUMBER := fnd_log.g_current_runtime_level;
l_params            wip_logger.param_tbl_t;

--standard who columns
l_sysDate           DATE := sysdate;
l_userID            NUMBER := fnd_global.user_id;
l_loginID           NUMBER := fnd_global.login_id;
l_reqID             NUMBER := fnd_global.conc_request_id;
l_progApplID        NUMBER := fnd_global.prog_appl_id;
l_progID            NUMBER := fnd_global.conc_program_id;

l_cnt_wor           number;
l_cnt_wo            number;
l_idx               number;
l_stat_num          number;

e_bad_date          exception;

begin

        x_returnCode := 0;

l_stat_num := 10;
    if (l_logLevel <= wip_constants.trace_logging) then
        l_params(1).paramName := 'p_wipEntityID';
        l_params(1).paramValue := p_wipEntityID;
        l_params(2).paramName := 'p_orgID';
        l_params(2).paramValue := p_orgID;
        l_params(3).paramName := 'p_scheduleMode';
        l_params(3).paramValue := p_scheduleMode;
        l_params(4).paramName := 'p_anchorDate';
        l_params(4).paramValue := to_char(p_anchorDate, 'DD-MON-YYYY HH24:MI:SS');
        l_params(5).paramName := 'p_curJobOpSeqNum';
        l_params(5).paramValue := p_curJobOpSeqNum;
        l_params(6).paramName := 'p_strRtgOpSeqNum';
        l_params(6).paramValue := p_strRtgOpSeqNum;
        l_params(7).paramName := 'p_endRtgOpSeqNum';
        l_params(7).paramValue := p_endRtgOpSeqNum;
        l_params(8).paramName := 'p_opSeqNum';
        l_params(8).paramValue := p_opSeqNum;
        l_params(9).paramName := 'p_resSeqNum';
        l_params(9).paramValue := p_resSeqNum;


        wip_logger.entryPoint(
                p_procName     => 'wsm_infinite_scheduler_pvt.wsmJobWriter',
                p_params       => l_params,
                x_returnStatus => l_retStatus);
    end if;
    x_returnStatus := fnd_api.g_ret_sts_success;

l_stat_num := 20;
    -- get the current job start/end date
    select  wdj.scheduled_start_date,
            wdj.scheduled_completion_date
    into    l_jobStartDate,
            l_jobComplDate
    from    wip_discrete_jobs wdj
    where   wdj.wip_entity_id = p_wipEntityID;


    if(x_resTbls.opSeqNum.count <> 0) then
l_stat_num := 30;

        if p_scheduleMode = WIP_CONSTANTS.CURRENT_SUB_GRP then

            l_OpStartDate.extend(1);
            l_OpEndDate.extend(1);
            l_OpQty.extend(1); -- bug 3585783 must initialize this

            l_curOp := x_resTbls.opSeqNum(1);

            if(l_curOp<0) then
                select first_unit_start_date,
                       last_unit_completion_date
                into   l_OpStartDate(1),
                       l_OpEndDate(1)
                from   wip_operations
                where  wip_entity_id = p_wipEntityID
                and    organization_id = p_orgID
                and    operation_seq_num = -l_curOp;
            else
                select reco_start_date,
                       reco_completion_date
                into   l_OpStartDate(1),
                       l_OpEndDate(1)
                from   wsm_copy_operations
                where  wip_entity_id = p_wipEntityID
                and    organization_id = p_orgID
                and    operation_seq_num = l_curOp;
            end if;

            for i in 1..x_resTbls.resID.count loop
                l_OpStartDate(1) := least(nvl(l_OpStartDate(1), x_resTbls.startDate(i)),
                                          x_resTbls.startDate(i));
                l_OpEndDate(1)   := greatest(nvl(l_OpEndDate(1), x_resTbls.endDate(i)),
                                             x_resTbls.endDate(i));
            end loop;
            l_OpQty(1):= g_opQty(l_curOp); -- bug 3585783
            l_minDate := l_OpStartDate(1);
            l_maxDate := l_OpEndDate(1);


        else    -- p_scheduleMode <> WIP_CONSTANTS.CURRENT_SUB_GRP

            l_minDate    := null;
            l_maxDate    := null;
            l_minDateYes := null;

            for i in 1..x_resTbls.resID.count loop
                l_curOp := x_resTbls.opSeqNum(i);
                if(NOT l_hashOpSDate.exists(l_curOp)) then
                    l_hashOpSDate(l_curOp)    := null;
                    l_hashOpEDate(l_curOp)    := null;
                    l_hashOpSDateYes(l_curOp) := null;
                    l_hashOpEDateYes(l_curOp) := null;
                end if;

                if(x_resTbls.startDate(i) IS NOT NULL) then
                    l_hashOpSDate(l_curOp)
                            := least(nvl(l_hashOpSDate(l_curOp), x_resTbls.startDate(i)),
                                     x_resTbls.startDate(i));
                    l_minDate
                            := least(nvl(l_minDate, x_resTbls.startDate(i)),
                                     x_resTbls.startDate(i));
                    if(x_resTbls.schedFlag(i) = 1) then
                        l_hashOpSDateYes(l_curOp)
                            := least(nvl(l_hashOpSDateYes(l_curOp), x_resTbls.startDate(i)),
                                     x_resTbls.startDate(i));
                        l_minDateYes
                            := least(nvl(l_minDateYes, x_resTbls.startDate(i)),
                                     x_resTbls.startDate(i));
                    end if;
                end if;
                if(x_resTbls.endDate(i) IS NOT NULL) then
                    l_hashOpEDate(l_curOp)
                            := greatest(nvl(l_hashOpEDate(l_curOp), x_resTbls.endDate(i)),
                                        x_resTbls.endDate(i));
                    l_maxDate
                            := greatest(nvl(l_maxDate, x_resTbls.endDate(i)),
                                        x_resTbls.endDate(i));
                    if(x_resTbls.schedFlag(i) = 1) then
                        l_hashOpEDateYes(l_curOp)
                            := greatest(nvl(l_hashOpEDateYes(l_curOp), x_resTbls.endDate(i)),
                                        x_resTbls.endDate(i));
                    end if;
                end if;
            end loop;

            -- set startDate/endDate for resources with schedFlag = No
            l_currentDate   := l_minDateYes;
            for i in 1..x_resTbls.resID.count loop
                l_curOp := x_resTbls.opSeqNum(i);
                l_currentDate := NVL(l_hashOpEDateYes(l_curOp), l_currentDate);

                if(x_resTbls.startDate(i) IS NULL) then
                    x_resTbls.startDate(i) := l_currentDate;
                    x_resTbls.endDate(i)   := l_currentDate;
                end if;
            end loop;


            l_currentDate   := NVL(l_minDateYes,l_minDate); -- bug fix 6806858
            for i in 1..p_opTbl.count loop
                l_curOp := p_opTbl(i);

                if(NOT l_hashOpSDate.exists(l_curOp)) then
                    l_hashOpSDate(l_curOp)    := l_currentDate;
                    l_hashOpEDate(l_curOp)    := l_currentDate;
                    l_hashOpSDateYes(l_curOp) := l_currentDate;
                    l_hashOpEDateYes(l_curOp) := l_currentDate;
                else
                    l_currentDate := NVL(l_hashOpEDateYes(l_curOp), l_currentDate);
                end if;
            end loop;

            l_OpStartDate.extend(p_opTbl.count);
            l_OpEndDate.extend(p_opTbl.count);
            l_OpQty.extend(p_opTbl.count);
            for i in 1..p_opTbl.count loop
                l_curOp          := p_opTbl(i);
                l_OpStartDate(i) := l_hashOpSDate(l_curOp);
                l_OpEndDate(i)   := l_hashOpEDate(l_curOp);
                l_OpQty(i)       := g_opQty(l_curOp);
            end loop;

        end if;  -- p_scheduleMode <> WIP_CONSTANTS.CURRENT_SUB_GRP

    else -- x_resTbls.opSeqNum.count = 0
l_stat_num := 40;
            l_OpStartDate.extend(p_opTbl.count);
            l_OpEndDate.extend(p_opTbl.count);
            l_OpQty.extend(p_opTbl.count);

            for i in 1..p_opTbl.count loop
                l_curOp          := p_opTbl(i);
                l_OpStartDate(i) := p_anchorDate;
                l_OpEndDate(i)   := p_anchorDate;
                l_OpQty(i)       := g_opQty(l_curOp);
            end loop;
            -- BA: bug 3350262
            l_minDate := p_anchorDate;
            l_maxDate := p_anchorDate;
            -- EA: bug 3350262
    end if;

l_stat_num := 45;

    ----------------------------------------------------------------
    l_cnt_wo := 0;
    l_idx := p_opTbl.first;
    while(l_idx IS NOT NULL and p_opTbl(l_idx) < 0)
    loop
        l_cnt_wo := l_cnt_wo +1;
        l_idx := p_opTbl.next(l_idx);
    end loop;


l_stat_num := 50;
    -- if current op is the first op update update l_jobStartDate
    -- if current op = null, first op is routing start, update l_jobStartDate
    -- last op is routing end, update l_jobCompDate
    select nvl(OP_SEQ_NUM_INCREMENT, 10)
    into   l_op_seq_incr
    from   wsm_parameters
    where  ORGANIZATION_ID = p_orgID;

    -- BC: bug 3439417 the following logic should be changed

    --if(l_minDate IS NOT NULL) then
    --    if(l_minDate < l_jobStartDate) then
    --        l_jobStartDate := l_minDate;
    --    else
    --        if(l_cnt_wo >= 1) then
    --            if(l_op_seq_incr = -p_opTbl(1)) then
    --                l_jobStartDate := l_minDate;
    --            end if;
    --        else
    --            if(p_opTbl(1) = p_strRtgOpSeqNum) then
    --                l_jobStartDate := l_minDate;
    --            end if;
    --        end if;
    --    end if;
    --end if;

    --if(l_maxDate IS NOT NULL) then
    --    if(l_maxDate > l_jobComplDate) then
    --        l_jobComplDate := l_maxDate;
    --    else
    --        if(p_opTbl(p_opTbl.count) = p_endRtgOpSeqNum) then
    --            l_jobComplDate := l_maxDate;
    --        end if;
    --    end if;
    --end if;

    if(l_cnt_wo >= 1) then
        if(l_op_seq_incr = -p_opTbl(1)) then
            l_newJobStartDate := NVL(l_minDate, l_jobStartDate);
        else
            l_newJobStartDate := l_jobStartDate;
        end if;
    else
        if(p_strRtgOpSeqNum = p_opTbl(1)) then
            l_newJobStartDate := NVL(l_minDate, l_jobStartDate);
        else
            l_newJobStartDate := l_jobStartDate;
        end if;
    end if;
    --Bug 5110917:If the last op is the current operation, the following
    --check fails.
    --if(p_opTbl(p_opTbl.count) = p_endRtgOpSeqNum) then
    if(p_opTbl(p_opTbl.count) = p_endRtgOpSeqNum)
      or p_opTbl(p_opTbl.count)<0 then --Current op is last op
        l_newJobComplDate := NVL(l_maxDate, l_jobComplDate);
    else
        l_newJobComplDate := l_jobComplDate;
    end if;

    if(g_discrete_charges_exist) then
        -- since the job has charge, should not allow changing job start date
        l_newJobStartDate := l_jobStartDate;
    end if;
    -- EC: bug 3439417


l_stat_num := 60;
    --update job
    --if(l_jobStartDate IS NOT NULL or l_jobComplDate IS NOT NULL) then
    if(l_jobStartDate <> l_newJobStartDate or l_jobComplDate <> l_newJobComplDate) then

        update wip_discrete_jobs
           set --scheduled_start_date      = NVL(l_jobStartDate, scheduled_start_date),
               --scheduled_completion_date = NVL(l_jobComplDate, scheduled_completion_date),
               scheduled_start_date      = l_newJobStartDate,
               scheduled_completion_date = l_newJobComplDate,
               ----standard who columns----
               last_update_date = l_sysdate,
               last_updated_by = l_userID,
               last_update_login = l_loginID,
               request_id = l_reqID,
               program_application_id = l_progApplID,
               program_id = l_progID,
               program_update_date = l_sysDate
         where wip_entity_id = p_wipEntityID
           and organization_id = p_orgID;

        if(l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('wrote job', l_retStatus);
        end if;
    end if;


l_stat_num := 70;
    --update operations WO
    forall i in 1..l_cnt_wo
      update wip_operations
         set first_unit_start_date = NVL(l_OpStartDate(i), first_unit_start_date),
             last_unit_start_date = NVL(l_OpStartDate(i), last_unit_start_date),
             first_unit_completion_date = NVL(l_OpEndDate(i), first_unit_completion_date),
             last_unit_completion_date = NVL(l_OpEndDate(i), last_unit_completion_date),
             scheduled_quantity = l_OpQty(i),
             ----standard who columns----
             last_update_date = l_sysdate,
             last_updated_by = l_userID,
             last_update_login = l_loginID,
             request_id = l_reqID,
             program_application_id = l_progApplID,
             program_id = l_progID,
             program_update_date = l_sysDate
       where wip_entity_id = p_wipEntityID
         and organization_id = p_orgID
         and operation_seq_num = -p_opTbl(i);
    if(l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('wrote WO', l_retStatus);
    end if;


l_stat_num := 80;
    --update operations WCO
    forall i in l_cnt_wo+1..p_opTbl.count
      update wsm_copy_operations
         set reco_start_date = l_OpStartDate(i),
             reco_completion_date = l_OpEndDate(i),
             reco_scheduled_quantity = l_OpQty(i),
             ----standard who columns----
             last_update_date = l_sysdate,
             last_updated_by = l_userID,
             last_update_login = l_loginID,
             request_id = l_reqID,
             program_application_id = l_progApplID,
             program_id = l_progID,
             program_update_date = l_sysDate
       where wip_entity_id = p_wipEntityID
         and organization_id = p_orgID
         and operation_seq_num = p_opTbl(i);
    if(l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('wrote WCO', l_retStatus);
    end if;

    --bug 6345672: begin
l_stat_num := 85;
    if g_update_current_op and l_cnt_wo is not NULL and l_cnt_wo > 0 THEN  --bug 6345672
      update wsm_copy_operations
         set reco_start_date = l_OpStartDate(l_cnt_wo),
             reco_completion_date = l_OpEndDate(l_cnt_wo),
             reco_scheduled_quantity = l_OpQty(l_cnt_wo),
             ----standard who columns----
             last_update_date = l_sysdate,
             last_updated_by = l_userID,
             last_update_login = l_loginID,
             request_id = l_reqID,
             program_application_id = l_progApplID,
             program_id = l_progID,
             program_update_date = l_sysDate
       where wip_entity_id = p_wipEntityID
         and organization_id = p_orgID
         and operation_seq_num = -p_opTbl(l_cnt_wo);

        if(l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('wrote WCO for current op', l_retStatus);
        end if;
    end if;
    --bug 6345672: end

    ----------------------------------------------------------------
l_stat_num := 90;
    --update mtl requirement dates WRO
    forall i in 1..l_cnt_wo
      update wip_requirement_operations
         set date_required = NVL(l_OpStartDate(i), date_required),
             ----standard who columns----
             last_update_date = l_sysdate,
             last_updated_by = l_userID,
             last_update_login = l_loginID,
             request_id = l_reqID,
             program_application_id = l_progApplID,
             program_id = l_progID,
             program_update_date = l_sysDate
       where wip_entity_id = p_wipEntityID
         and organization_id = p_orgID
         and operation_seq_num = -p_opTbl(i);
    if(l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('wrote WRO', l_retStatus);
    end if;

l_stat_num := 100;
    --update mtl requirement dates WCRO
    forall i in l_cnt_wo+1..p_opTbl.count
      update wsm_copy_requirement_ops
         set reco_date_required = l_OpStartDate(i),
             ----standard who columns----
             last_update_date = l_sysdate,
             last_updated_by = l_userID,
             last_update_login = l_loginID,
             request_id = l_reqID,
             program_application_id = l_progApplID,
             program_id = l_progID,
             program_update_date = l_sysDate
       where wip_entity_id = p_wipEntityID
         and organization_id = p_orgID
         and operation_seq_num = p_opTbl(i);
    if(l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('wrote WCRO', l_retStatus);
    end if;

    --bug 6345672: begin
l_stat_num := 105;
    if g_update_current_op and l_cnt_wo is not NULL and l_cnt_wo > 0 then --bug 6345672
      update wsm_copy_requirement_ops
         set reco_date_required = l_OpStartDate(l_cnt_wo),
             ----standard who columns----
             last_update_date = l_sysdate,
             last_updated_by = l_userID,
             last_update_login = l_loginID,
             request_id = l_reqID,
             program_application_id = l_progApplID,
             program_id = l_progID,
             program_update_date = l_sysDate
       where wip_entity_id = p_wipEntityID
         and organization_id = p_orgID
         and operation_seq_num = -p_opTbl(l_cnt_wo);

        if(l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('wrote WCRO for current op', l_retStatus);
        end if;
    end if;
    --bug 6345672: end

    ----------------------------------------------------------------
    if(x_resTbls.opSeqNum.count <> 0) then

        l_cnt_wor := 0;
        l_idx := x_resTbls.opSeqNum.first;
        while(l_idx IS NOT NULL and x_resTbls.opSeqNum(l_idx) < 0)
        loop
            l_cnt_wor := l_cnt_wor +1;
            l_idx := x_resTbls.opSeqNum.next(l_idx);
        end loop;

l_stat_num := 110;
        --update resources (WOR)
        forall i in 1..l_cnt_wor
            update wip_operation_resources
               set start_date = NVL(x_resTbls.startDate(i), start_date),
                   completion_date = NVL(x_resTbls.endDate(i), completion_date),
                   ----standard who columns----
                   last_update_date = l_sysdate,
                   last_updated_by = l_userID,
                   last_update_login = l_loginID,
                   request_id = l_reqID,
                   program_application_id = l_progApplID,
                   program_id = l_progID,
                   program_update_date = l_sysDate
             where wip_entity_id = p_wipEntityID
               and organization_id = p_orgID
               and operation_seq_num = -x_resTbls.opSeqNum(i)
               and resource_seq_num = x_resTbls.resSeqNum(i);
        if(l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('wrote WOR', l_retStatus);
        end if;

l_stat_num := 120;
        --update resources (WCOR)
        forall i in l_cnt_wor+1..x_resTbls.resID.count
            update wsm_copy_op_resources
               set reco_start_date = x_resTbls.startDate(i),
                   reco_completion_date = x_resTbls.endDate(i),
                   ----standard who columns----
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
            wip_logger.log('wrote WCOR', l_retStatus);
        end if;

        --bug 6345672: begin
l_stat_num := 125;
        if g_update_current_op AND l_cnt_wor > 0  and l_cnt_wor is not NULL then  --bug 6345672/   -- bug 7248484
            update wsm_copy_op_resources
            set reco_start_date = x_resTbls.startDate(l_cnt_wor),
                   reco_completion_date = x_resTbls.endDate(l_cnt_wor),
                   ----standard who columns----
                   last_update_date = l_sysdate,
                   last_updated_by = l_userID,
                   last_update_login = l_loginID,
                   request_id = l_reqID,
                   program_application_id = l_progApplID,
                   program_id = l_progID,
                   program_update_date = l_sysDate
            where wip_entity_id = p_wipEntityID
            and organization_id = p_orgID
            and operation_seq_num = -x_resTbls.opSeqNum(l_cnt_wor)
            and resource_seq_num = x_resTbls.resSeqNum(l_cnt_wor);

            if(l_logLevel <= wip_constants.full_logging) then
                wip_logger.log('wrote WCOR for current op', l_retStatus);
            end if;
        end if;
        --bug 6345672: end

        ----------------------------------------------------------------
l_stat_num := 130;
        --update resources instances (WORI)
        forall i in 1..l_cnt_wor
            update wip_op_resource_instances
               set start_date = NVL(x_resTbls.startDate(i), start_date),
                   completion_date = NVL(x_resTbls.endDate(i), completion_date),
                   ----standard who columns----
                   last_update_date = l_sysdate,
                   last_updated_by = l_userID,
                   last_update_login = l_loginID
             where wip_entity_id = p_wipEntityID
               and organization_id = p_orgID
               and operation_seq_num = -x_resTbls.opSeqNum(i)
               and resource_seq_num = x_resTbls.resSeqNum(i);
        if(l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('wrote WORI', l_retStatus);
        end if;

l_stat_num := 140;
        --update resources instances (WCORI)
        forall i in l_cnt_wor+1..x_resTbls.resID.count
            update wsm_copy_op_resource_instances
               set start_date = x_resTbls.startDate(i),
                   completion_date = x_resTbls.endDate(i),
                   ----standard who columns----
                   last_update_date = l_sysdate,
                   last_updated_by = l_userID,
                   last_update_login = l_loginID
             where wip_entity_id = p_wipEntityID
               and organization_id = p_orgID
               and operation_seq_num = x_resTbls.opSeqNum(i)
               and resource_seq_num = x_resTbls.resSeqNum(i);
        if(l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('wrote WCORI', l_retStatus);
        end if;

        --bug 6345672: begin
l_stat_num := 145;
        if g_update_current_op and  l_cnt_wor > 0  and l_cnt_wor is not NULL then --bug 6345672    -- bug 7248484
            update wsm_copy_op_resource_instances
               set start_date = x_resTbls.startDate(l_cnt_wor),
                   completion_date = x_resTbls.endDate(l_cnt_wor),
                   ----standard who columns----
                   last_update_date = l_sysdate,
                   last_updated_by = l_userID,
                   last_update_login = l_loginID
             where wip_entity_id = p_wipEntityID
               and organization_id = p_orgID
               and operation_seq_num = -x_resTbls.opSeqNum(l_cnt_wor)
               and resource_seq_num = x_resTbls.resSeqNum(l_cnt_wor);
        if(l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('wrote WCORI for current op', l_retStatus);
        end if;
        end if;
        --bug 6345672: end

        ----------------------------------------------------------------

l_stat_num := 150;
        --update resources usage (WORU)
        forall i in 1..l_cnt_wor
            delete wip_operation_resource_usage
             where wip_entity_id = p_wipEntityID
               and operation_seq_num = -x_resTbls.opSeqNum(i)
               and resource_seq_num = x_resTbls.resSeqNum(i);

l_stat_num := 160;
        for i in 1..l_cnt_wor loop
            if(x_resTbls.usgStartIdx(i) is not null) then
                forall j in x_resTbls.usgStartIdx(i)..x_resTbls.usgEndIdx(i)
                    insert into wip_operation_resource_usage (
                           wip_entity_id,
                           operation_seq_num,
                           resource_seq_num,
                           organization_id,
                           start_date,
                           completion_date,
                           assigned_units,
                           cumulative_processing_time,
                           ----standard who columns----
                           last_update_date,
                           last_updated_by,
                           creation_date,
                           created_by,
                           last_update_login,
                           request_id,
                           program_application_id,
                           program_id,
                           program_update_date
                      ) values (
                           p_wipEntityID,
                           -x_resTbls.opSeqNum(i),
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
            wip_logger.log('wrote WORU', l_retStatus);
        end if;

l_stat_num := 170;
        forall i in 1..l_cnt_wor
            insert into wip_operation_resource_usage(
                   wip_entity_id,
                   operation_seq_num,
                   resource_seq_num,
                   organization_id,
                   start_date,
                   completion_date,
                   assigned_units,
                   instance_id,
                   serial_number,
                   cumulative_processing_time,
                   ----standard who columns----
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
                   wip_op_resource_instances wori
             where woru.wip_entity_id = wori.wip_entity_id
               and woru.operation_seq_num = wori.operation_seq_num
               and woru.resource_seq_num = wori.resource_seq_num
               and woru.organization_id = wori.organization_id
               and woru.wip_entity_id = p_wipEntityID
               and woru.organization_id = p_orgID
               and wori.operation_seq_num = -x_resTbls.opSeqNum(i)
               and wori.resource_seq_num = x_resTbls.resSeqNum(i);
        if(l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('wrote ' || SQL%ROWCOUNT || ' WROU', l_retStatus);
        end if;


l_stat_num := 180;
        --update resources usage (WCORU)
        forall i in l_cnt_wor+1..x_resTbls.resID.count
            delete wsm_copy_op_resource_usage
             where wip_entity_id = p_wipEntityID
               and operation_seq_num = x_resTbls.opSeqNum(i)
               and resource_seq_num = x_resTbls.resSeqNum(i);

        --bug 6345672: begin
l_stat_num := 185;
        if g_update_current_op and l_cnt_wor > 0  and l_cnt_wor is not NULL then --bug 6345672   -- bug 7248484
            delete wsm_copy_op_resource_usage
             where wip_entity_id = p_wipEntityID
               and operation_seq_num = -x_resTbls.opSeqNum(l_cnt_wor)
               and resource_seq_num = x_resTbls.resSeqNum(l_cnt_wor);
        end if;
        --bug 6345672: end


l_stat_num := 190;
        for i in l_cnt_wor+1..x_resTbls.resID.count loop
            if(x_resTbls.usgStartIdx(i) is not null) then
                forall j in x_resTbls.usgStartIdx(i)..x_resTbls.usgEndIdx(i)
                    insert into wsm_copy_op_resource_usage(
                           wip_entity_id,
                           operation_seq_num,
                           resource_seq_num,
                           organization_id,
                           start_date,
                           completion_date,
                           assigned_units,
                           cumulative_processing_time,
                           ----standard who columns----
                           last_update_date,
                           last_updated_by,
                           creation_date,
                           created_by,
                           last_update_login,
                           request_id,
                           program_application_id,
                           program_id,
                           program_update_date
                      ) values (
                          p_wipEntityID,
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
            wip_logger.log('wrote WCORU', l_retStatus);
        end if;

        --bug 6345672: begin
l_stat_num := 195;
        if g_update_current_op and l_cnt_wor > 0  and l_cnt_wor is not NULL then --bug 6345672/ -- bug 7248484
            if(x_resTbls.usgStartIdx(l_cnt_wor) is not null) then
                forall j in x_resTbls.usgStartIdx(l_cnt_wor)..x_resTbls.usgEndIdx(l_cnt_wor)
                    insert into wsm_copy_op_resource_usage(
                           wip_entity_id,
                           operation_seq_num,
                           resource_seq_num,
                           organization_id,
                           start_date,
                           completion_date,
                           assigned_units,
                           cumulative_processing_time,
                           ----standard who columns----
                           last_update_date,
                           last_updated_by,
                           creation_date,
                           created_by,
                           last_update_login,
                           request_id,
                           program_application_id,
                           program_id,
                           program_update_date
                      ) values (
                          p_wipEntityID,
                          -x_resTbls.opSeqNum(l_cnt_wor),
                          x_resTbls.resSeqNum(l_cnt_wor),
                          p_orgID,
                          x_resTbls.usgStartDate(j),
                          x_resTbls.usgEndDate(j),
                          p_assignedUnits(l_cnt_wor),
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

            if(l_logLevel <= wip_constants.full_logging) then
                wip_logger.log('wrote WCORU for current op', l_retStatus);
            end if;
        end if;
        --bug 6345672: end

l_stat_num := 200;
        forall i in l_cnt_wor+1..x_resTbls.resID.count
            insert into wsm_copy_op_resource_usage(
                   wip_entity_id,
                   operation_seq_num,
                   resource_seq_num,
                   organization_id,
                   start_date,
                   completion_date,
                   assigned_units,
                   instance_id,
                   serial_number,
                   cumulative_processing_time,
                   ----standard who columns----
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
                   wcoru.operation_seq_num,
                   wcoru.resource_seq_num,
                   p_orgID,
                   wcoru.start_date,
                   wcoru.completion_date,
                   1,
                   wcori.instance_id,
                   wcori.serial_number,
                   wcoru.cumulative_processing_time,
                   l_sysdate,
                   l_userID,
                   l_sysdate,
                   l_userID,
                   l_loginID,
                   l_reqID,
                   l_progApplID,
                   l_progID,
                   l_sysdate
              from wsm_copy_op_resource_usage wcoru,
                   wsm_copy_op_resource_instances wcori
             where wcoru.wip_entity_id = wcori.wip_entity_id
               and wcoru.operation_seq_num = wcori.operation_seq_num
               and wcoru.resource_seq_num = wcori.resource_seq_num
               and wcoru.organization_id = wcori.organization_id
               and wcoru.wip_entity_id = p_wipEntityID
               and wcoru.organization_id = p_orgID
               and wcori.operation_seq_num = x_resTbls.opSeqNum(i)
               and wcori.resource_seq_num = x_resTbls.resSeqNum(i);
        if(l_logLevel <= wip_constants.full_logging) then
            wip_logger.log('wrote ' || SQL%ROWCOUNT || ' WCORU', l_retStatus);
        end if;

        --bug 6345672: begin
l_stat_num := 205;
        if g_update_current_op and l_cnt_wor > 0  and l_cnt_wor is not NULL then --bug 6345672 -- bug 7248484
            insert into wsm_copy_op_resource_usage(
                   wip_entity_id,
                   operation_seq_num,
                   resource_seq_num,
                   organization_id,
                   start_date,
                   completion_date,
                   assigned_units,
                   instance_id,
                   serial_number,
                   cumulative_processing_time,
                   ----standard who columns----
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
                   wcoru.operation_seq_num,
                   wcoru.resource_seq_num,
                   p_orgID,
                   wcoru.start_date,
                   wcoru.completion_date,
                   1,
                   wcori.instance_id,
                   wcori.serial_number,
                   wcoru.cumulative_processing_time,
                   l_sysdate,
                   l_userID,
                   l_sysdate,
                   l_userID,
                   l_loginID,
                   l_reqID,
                   l_progApplID,
                   l_progID,
                   l_sysdate
              from wsm_copy_op_resource_usage wcoru,
                   wsm_copy_op_resource_instances wcori
             where wcoru.wip_entity_id = wcori.wip_entity_id
               and wcoru.operation_seq_num = wcori.operation_seq_num
               and wcoru.resource_seq_num = wcori.resource_seq_num
               and wcoru.organization_id = wcori.organization_id
               and wcoru.wip_entity_id = p_wipEntityID
               and wcoru.organization_id = p_orgID
               and wcori.operation_seq_num = -x_resTbls.opSeqNum(l_cnt_wor)
               and wcori.resource_seq_num = x_resTbls.resSeqNum(l_cnt_wor);
            if(l_logLevel <= wip_constants.full_logging) then
                wip_logger.log('wrote ' || SQL%ROWCOUNT || ' WCORU for current op', l_retStatus);
            end if;

        end if;
        --bug 6345672: end

				end if;

    if (l_logLevel <= wip_constants.trace_logging) then
        wip_logger.exitPoint(
                p_procName         => 'wsm_infinite_scheduler_pvt.wsmJobWriter',
                p_procReturnStatus => x_returnStatus,
                p_msg              => 'success',
                x_returnStatus     => l_retStatus);
    end if;

exception

    when others then
        x_returnStatus := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.add_exc_msg(
                p_pkg_name       => 'wsm_infinite_scheduler_pvt',
                p_procedure_name => 'wsmJobWriter',
                p_error_text     => SQLERRM || ' (writer #' || l_stat_num || ')' );
        if (l_logLevel <= wip_constants.trace_logging) then
          wip_logger.exitPoint(
                p_procName         => 'wsm_infinite_scheduler_pvt.wsmJobWriter',
                p_procReturnStatus => x_returnStatus,
                p_msg              => 'unexp error: ' || SQLERRM || ' (writer #' || l_stat_num || ')',
                x_returnStatus     => l_retStatus);
        end if;
end wsmJobWriter;


end wsm_infinite_scheduler_pvt;

/
