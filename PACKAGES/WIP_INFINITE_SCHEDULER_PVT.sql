--------------------------------------------------------
--  DDL for Package WIP_INFINITE_SCHEDULER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_INFINITE_SCHEDULER_PVT" AUTHID CURRENT_USER as
/* $Header: wipiscds.pls 120.1 2006/08/04 01:16:53 rekannan noship $ */

  ------------------------------------------------------------
  --This procedure will schedule a job or repetitive schedule
  --based on resources usages, assuming infinite resource
  --availibility. It will read job/schedule information out of
  --the relevant database tables, schedule them based on input
  --parameters, and then update the schedule dates in
  --WIP_OPERATIONS and WIP_OPERATION_RESOURCES.
  --
  --Parameters:
  --  + p_initMsgList: Clear the message stack before processing?
  --                   True (fnd_api.g_true) should be passed
  --                   unless relevant messages are being saved
  --                   on the stack. This value defaults to true.
  --  + p_endDebug: Pass true (fnd_api.g_true) unless the debug
  --                session will be ended at a later point by the
  --                caller. This value defaults to true.
  --  + p_orgID: The organization of the entity (job or rep schedule).
  --  + p_wipEntityID: The entity to reschedule.
  --  + p_repSchedID: *NOT CURRENTLY SUPPORTED* This value is currently
  --                  ignored. In the future, it may be used.
  --  + p_startDate: if p_opSeqNum is null -> populating this
  --                 value means the procedure will forward
  --                 schedule the entity.
  --                 if p_opSeq is not null -> populating this
  --                 value means the midpoint op seq will be
  --                 forward scheduled.
  --  + p_endDate: if p_opSeqNum is null -> populating this
  --                 value means the procedure will backward
  --                 schedule the entity.
  --                 if p_opSeq is not null -> populating this
  --                 value means the midpoint op seq will be
  --                 backward scheduled.
  -- + p_midPntMethod: constants defined in wip_constants:
  --                   forwards           --forward schedule job
  --                   backwards          --backward schedule job
  --                   midpoint           --midpoint schedule job
  --                   midpoint_forwards  --schedule midpoint and future operations/op resources
  --                   midpoint_backwards --schedule midpoint and past operations/op resources
  --                   current_op         --only schedule current operation
  --                   current_op_res     --only schedule current op resource
  --                   current_sub_grp    --only schedule current substitution group
  -- + p_opSeqNum: Populate to midpoint schedule.
  -- + p_resSeqNum: Populate to midpoint schedule down to the resource level.
  --                Only used if p_opSeqNum is populated.
  -- + p_subGrpNum : Populate to schedule the entire substitute group. When passing
  --                 this value, use current_sub_grp midpoint method.
  --   Fix bug 5440007
  --   p_quantity  : When scheduling is called from wip mass load the quantity
  --                 may be specified in the wip interface table . In that case we need to
  --                 take a look at the qty specified in the interface table.
  --                 Not to impact other callers, the default value for this parameter is null
  -- + x_returnStatus: fnd_api.g_ret_sts_success if the entity
  --                   was scheduled successfully.
  -- + x_errorMsg: The error message. The error message will also
  --               be left on the stack.
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
                     x_errorMsg OUT NOCOPY VARCHAR2);

end wip_infinite_scheduler_pvt;

 

/
