--------------------------------------------------------
--  DDL for Package Body WSM_INFINITE_SCHEDULER_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSM_INFINITE_SCHEDULER_GRP" as
/* $Header: WSMGIFSB.pls 115.3 2003/10/28 21:41:14 zchen noship $ */

--private types
type num_tbl_t  is table of number;
type date_tbl_t is table of date;
--private procedures


-------------------------------------------------------------------------
-- This API is a group API to schedule a lot based job based on
-- resources usages, assuming infinite resource availibility. It will
-- validate the parameter and call WSM private API to schedule the job.
-- and then update the schedule dates in WDJ, WO, WOR, WCO, WCOR.
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
-- + p_scheduleMode: will have the following values
--
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
        x_returnStatus  out nocopy varchar2,
        x_errorMsg      out nocopy varchar2) is

l_logLevel          NUMBER := fnd_log.g_current_runtime_level;
l_params            wip_logger.param_tbl_t;
l_retStatus         VARCHAR2(1);
l_resTbls           wip_infResSched_grp.op_res_rectbl_t;
l_repLineID         NUMBER;
l_opTbl             num_tbl_t;
l_assignedUnits     num_tbl_t;

l_curJobOpSeqNum    NUMBER := null;     -- current job op_seq_num
l_strRtgOpSeqNum    NUMBER := null;     -- routing start op_seq_num
l_endRtgOpSeqNum    NUMBER := null;     -- routing end op_seq_num

e_invalid_mode      exception;

begin

    if (l_logLevel <= wip_constants.trace_logging) then
        l_params(1).paramName := 'p_wipEntityID';
        l_params(1).paramValue := p_wipEntityID;

        wip_logger.entryPoint(
                p_procName     => 'wsm_infinite_scheduler_grp.schedule',
                p_params       => l_params,
                x_returnStatus => x_returnStatus);
        if(x_returnStatus <> fnd_api.g_ret_sts_success) then
            raise fnd_api.g_exc_unexpected_error;
        end if;
    end if;
    x_returnStatus := fnd_api.g_ret_sts_success;

    -- do validation here
    if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('validate parameters p_scheduleMode...', l_retStatus);
    end if;
    if p_scheduleMode NOT IN (
        WIP_CONSTANTS.MIDPOINT,
        WIP_CONSTANTS.MIDPOINT_FORWARDS,
        WIP_CONSTANTS.MIDPOINT_BACKWARDS,
        WIP_CONSTANTS.CURRENT_OP,
        --WIP_CONSTANTS.CURRENT_OP_RES
        WIP_CONSTANTS.CURRENT_SUB_GRP )
    then
        raise e_invalid_mode;
    end if;

    -- call private API
    if (l_logLevel <= wip_constants.full_logging) then
        wip_logger.log('scheduling lot based job...', l_retStatus);
    end if;
    wsm_infinite_scheduler_pvt.schedule(
            p_initMsgList   => p_initMsgList,
            p_endDebug      => p_endDebug,
            p_orgID         => p_orgID,
            p_wipEntityID   => p_wipEntityID,
            p_scheduleMode  => p_scheduleMode,
            p_startDate     => p_startDate,
            p_endDate       => p_endDate,
            p_opSeqNum      => p_opSeqNum,
            p_resSeqNum     => p_resSeqNum,
            x_returnStatus  => x_returnStatus,
            x_errorMsg      => x_errorMsg);
    if(x_returnStatus <> fnd_api.g_ret_sts_success) then
        raise fnd_api.g_exc_unexpected_error;
    end if;

exception

    when e_invalid_mode then
        x_returnStatus := fnd_api.g_ret_sts_unexp_error;
        x_errorMsg := 'p_scheduleMode = ' || p_scheduleMode || ' is not supported';
        if (l_logLevel <= wip_constants.trace_logging) then
            wip_logger.exitPoint(
                    p_procName         => 'wsm_infinite_scheduler_grp.schedule',
                    p_procReturnStatus => x_returnStatus,
                    p_msg              => 'error: ' || x_errorMsg,
                    x_returnStatus     => l_retStatus);
            if(fnd_api.to_boolean(nvl(p_endDebug, fnd_api.g_true))) then
                wip_logger.cleanup(l_retStatus);
            end if;
        end if;

    when fnd_api.g_exc_unexpected_error then
        x_returnStatus := fnd_api.g_ret_sts_unexp_error;
        wip_utilities.get_message_stack(
                p_msg          => x_errorMsg,
                p_delete_stack => fnd_api.g_false);
        if (l_logLevel <= wip_constants.trace_logging) then
            wip_logger.exitPoint(
                    p_procName         => 'wsm_infinite_scheduler_grp.schedule',
                    p_procReturnStatus => x_returnStatus,
                    p_msg              => 'error: ' || x_errorMsg,
                    x_returnStatus     => l_retStatus);
            if(fnd_api.to_boolean(nvl(p_endDebug, fnd_api.g_true))) then
                wip_logger.cleanup(l_retStatus);
            end if;
        end if;

    when others then
        x_returnStatus := fnd_api.g_ret_sts_unexp_error;
        fnd_msg_pub.add_exc_msg(
                p_pkg_name       => 'wsm_infinite_scheduler_grp',
                p_procedure_name => 'schedule',
                p_error_text     => SQLERRM);
        wip_utilities.get_message_stack(
                p_msg          => x_errorMsg,
                p_delete_stack => fnd_api.g_false);
        if (l_logLevel <= wip_constants.trace_logging) then
            wip_logger.exitPoint(
                p_procName         => 'wsm_infinite_scheduler_grp.schedule',
                p_procReturnStatus => x_returnStatus,
                p_msg              => 'unexp error: ' || x_errorMsg,
                x_returnStatus     => l_retStatus);
            if(fnd_api.to_boolean(nvl(p_endDebug, fnd_api.g_true))) then
                wip_logger.cleanup(l_retStatus);
            end if;
        end if;

end schedule;




end wsm_infinite_scheduler_grp;

/
