--------------------------------------------------------
--  DDL for Package Body PA_CE_AR_NOTIFY_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_CE_AR_NOTIFY_WF" AS
/* $Header: PAPWPCEB.pls 120.0.12010000.1 2008/10/30 08:07:37 atshukla noship $ */

-- ===================================================
--
--Name:               Select_Project_Manager
--Type:                 Procedure
--Description:      This client extension returns the project_manager ID
--              to the calling PA_PWP_NOTIFICATION Select_Project_Manager
--              procedure.
--
--
--Called subprograms: none.
--
--
--
--History:
--      26-Aug-2008      atShukla          - Created
--
-- IN
--   p_project_id                       - unique identifier for the project that needs approval
--
-- OUT
--   p_project_manager_id      - unique identifier of the employee
--                                (employee_id in per_people_f table)
--
PROCEDURE Select_Project_Manager (p_project_id          IN  NUMBER
                                , p_project_manager_id  OUT NOCOPY NUMBER
                                , p_return_status       IN OUT NOCOPY NUMBER)
IS
    /*
       You can use this procedure to add any additional rules to determine
       a person who should receive notifications for releasing hold on Invoices.
       This procedure is being used by the Workflow APIs and determine who
       should recieve notification when a receipt is applied to an AR Invoice.
       By default parent procedure fetches the Project Manager of the
       project which relates to the AR Invoice that receives cash when a
       receipt is applied.
    */
BEGIN
     /* Please update the Result status in accordance with the details below.
    Result Status : p_return_status
    =0  => NO Client Extention Implemented.
    >0  =>  Client Extention Implemented and successfully fetched the Project Manager ID.
    <0  =>  Client Extention Implemented and failed to fetch the Project Manager ID.
    */
     p_return_status := 0;
    --
    --The following algorithm can be used to handle known error conditions
    --When this code is used the arguments and there values will be displayed
    --in the error message that is send by workflow.
    --
    --IF <error condition>
    --THEN
    --      WF_CORE.TOKEN('ARG1', arg1);
    --      WF_CORE.TOKEN('ARGn', argn);
    --      WF_CORE.RAISE('ERROR_NAME');
    --END IF;

    -- Please uncomment and chenge this variable to any positive value (ex. =1) if you want to add any client extention.
    -- p_return_status := 1;
EXCEPTION
    WHEN OTHERS THEN
           p_return_status := -1;
           WF_CORE.CONTEXT('PA_CE_AR_NOTIFY_WF','SELECT_PROJECT_MANAGER');
           RAISE;

END Select_Project_Manager;

END pa_ce_ar_notify_wf;

/
