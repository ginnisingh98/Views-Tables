--------------------------------------------------------
--  DDL for Package MSC_WS_PROCESS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."MSC_WS_PROCESS" AUTHID CURRENT_USER AS
/* $Header: MSCWPROS.pls 120.0 2007/10/10 00:24:27 ryliu noship $ */

-- =============================================================
-- Desc: This FUNCTION is invoked from web service to check
--       the status for the given conc process. The possible return
--       statuses are:
--
--     concurrent prog phase_status          function return value
--
--     Running_<any status code>              RUNNING
--     Pending_<any status code>              PENDING
--     Inactive_<any other status codes>      INACTIVE
--     Completed_Normal                       COMPLETED_NORMAL
--     Completed_Error                        COMPLETED_ERROR
--     Completed_Warning                      COMPLETED_WARNING
--     Completed_Terminated                   COMPLETED_TERMINATED
--     Completed_<any other status codes>     COMPLETED
-- =============================================================

 FUNCTION  CHECK_PROC_STATUS(processId  IN  NUMBER) RETURN  VARCHAR2;


END MSC_WS_PROCESS;

/
