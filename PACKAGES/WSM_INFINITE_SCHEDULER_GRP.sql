--------------------------------------------------------
--  DDL for Package WSM_INFINITE_SCHEDULER_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSM_INFINITE_SCHEDULER_GRP" AUTHID CURRENT_USER as
/* $Header: WSMGIFSS.pls 115.2 2003/10/28 21:41:37 zchen noship $ */

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
        p_opSeqNum      in number   := null,      -- -1 if it is the current op
        p_resSeqNum     in number   := null,
        x_returnStatus  out nocopy varchar2,
        x_errorMsg      out nocopy varchar2);

end wsm_infinite_scheduler_grp;

 

/
