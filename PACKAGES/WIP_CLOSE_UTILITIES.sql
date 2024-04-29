--------------------------------------------------------
--  DDL for Package WIP_CLOSE_UTILITIES
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_CLOSE_UTILITIES" AUTHID CURRENT_USER AS
 /* $Header: wipcluts.pls 115.6 2002/12/12 16:56:46 rmahidha ship $ */

/* UNCLOSE_JOB
 DESCRIPTION:
   This function updates all tables when a job is unclosed.
     - Changes WIP_ENTITIES.Entity_Type from 3 to 1
     - Inserts WIP_PERIOD_BALANCES records from Date_Released onward if
        the job was released
 RETURNS:
        1 upon success
        0 if the unclose fails due to the fact that the period in which
          the job was closed in is now closed.
   Note:  This DOES NOT clear Date_Closed or change the status of the job
*/

  FUNCTION UNCLOSE_JOB
    (P_wip_entity_id NUMBER,
     P_organization_id NUMBER,
     P_class_code VARCHAR2) RETURN NUMBER;

/* CHECK_PENDING_CLOSE takes the wip_entity_id, organization_id, and
   request_id of a discrete job that is status pending close.
   It looks at the request id, which should be a close process for the job.
   If the process has terminated abnormally, this function deletes the row
   for the job from wip_dj_close_temp and returns the status_type that was
   stored in WIP_DJ_CLOSE_TEMP.  The calling procedure should set the status
   type in WIP_DISCRETE_JOBS back to that status.

   If the request is running normally, CHECK_PENDING_CLOSE returns 0
*/

  FUNCTION Check_Pending_Close
    (P_wip_entity_id NUMBER,
     P_organization_id NUMBER,
     P_request_id NUMBER) RETURN NUMBER;

END WIP_CLOSE_UTILITIES;

 

/
