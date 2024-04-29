--------------------------------------------------------
--  DDL for Package WIP_JSI_HOOKS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_JSI_HOOKS" AUTHID CURRENT_USER as
/* $Header: wipjsihs.pls 120.0.12010000.2 2009/06/12 16:01:46 shjindal ship $ */


--
-- This function will be called for each request in WIP_JOB_SCHEDULE_INTERFACE
-- to create or update a discrete job. It is called with the following
-- parameters:
--
--   P_INTERFACE_ID -- value of the INTERFACE_ID column in the
--     WIP_JOB_SCHEDULE_INTERFACE record being validated
--
--   P_CURRENT_BUILD_SEQUENCE -- current value of the BUILD_SEQUENCE
--     column in the WIP_JOB_SCHEDULE_INTERFACE record being validated
--
-- This function should not commit, and should not rollback unless to
-- an internally-defined savepoint.
-- The function's return value will replace the value in the BUILD_SEQUENCE
-- column before request validation continues.
--

function
get_default_build_sequence (
  p_interface_id in number,
  p_current_build_sequence in number
  )
return number ;

--
-- This function will be called for each request in WIP_JOB_SCHEDULE_INTERFACE
-- to create or update a discrete job. It is called with the following
-- parameters:
--
--   P_INTERFACE_ID -- value of the INTERFACE_ID column in the
--     WIP_JOB_SCHEDULE_INTERFACE record being validated
--
--   P_CURRENT_SCHEDULE_GROUP_ID -- current value of the SCHEDULE_GROUP_ID
--     column in the WIP_JOB_SCHEDULE_INTERFACE record being validated
--
-- This function should not commit, and should not rollback unless to
-- an internally-defined savepoint.
-- The function's return value will replace the value in the SCHEDULE_GROUP_ID
-- column before request validation continues.
--
-- Fixed bug 7638816
function
get_default_schedule_group_id (
  p_interface_id in number,
  p_current_schedule_group_id in number
  )
return number ;

end WIP_JSI_Hooks ;

/
