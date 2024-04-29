--------------------------------------------------------
--  DDL for Package PA_WORK_TYPE_UPGRADE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_WORK_TYPE_UPGRADE" AUTHID CURRENT_USER AS
/* $Header: PAWKUPGS.pls 120.1 2005/08/05 14:58:47 vgade noship $ */

/* Procedure: Upgrade_WT_Main

              Updates Work Type Id on
                 pa_projects_all,
                 pa_tasks,
                 pa_expenditure_items_all,
                 pa_cost_distribution_lines_all

              Simultaneously, it also updates Tp Amt Type Code on
                 pa_expenditure_items_all,
                 pa_cc_dist_lines_all
                 pa_draft_invoice_details_all

   Parameters: IN
                 P_Num_Of_Processes : User given number, that many processes will be spawned
                 P_Worker_Id        : Holds the worker id
                 P_Org_Id           : Holds the operating unit
                 P_Txn_Date_Arg     : Holds the transaction start date

                 --Added for R12 AP Lines uptake
                 P_Min_Project_Id   : Holds the minimum of the project id range, internally used
                 P_Max_Project_Id   : Holds the maximum of the project id range, internally used

               OUT
                 X_Return_Status : Currently not used
                 X_Error_Message_Code : Currently not used

*/

   Procedure Upgrade_WT_Main(
                              X_RETURN_STATUS      OUT NOCOPY VARCHAR2
                             ,X_ERROR_MESSAGE_CODE OUT NOCOPY VARCHAR2
			     ,P_TXN_TYPE           IN VARCHAR2
                             ,P_TXN_SRC            IN VARCHAR2
                             ,P_NUM_OF_PROCESSES   IN NUMBER
                             ,P_WORKER_ID          IN NUMBER
                             ,P_ORG_ID             IN NUMBER DEFAULT NULL
                             ,P_TXN_DATE           IN VARCHAR2
                             ,P_Min_Project_Id     IN NUMBER DEFAULT NULL
                             ,P_Max_Project_Id     IN NUMBER DEFAULT NULL
			     );

   TYPE ResStsRecord is RECORD (
        Request_Id             NUMBER,
        Status                 Varchar2(255));

   TYPE ResStsTabType is TABLE of ResStsRecord INDEX BY BINARY_INTEGER;

END PA_WORK_TYPE_UPGRADE;

 

/
