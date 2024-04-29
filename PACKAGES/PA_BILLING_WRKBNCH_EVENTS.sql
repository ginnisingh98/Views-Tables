--------------------------------------------------------
--  DDL for Package PA_BILLING_WRKBNCH_EVENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BILLING_WRKBNCH_EVENTS" AUTHID CURRENT_USER as
/* $Header: PABWBCHS.pls 120.1 2005/08/19 16:17:32 mwasowic noship $ */

/*----------------- Private Procedure/Function Declarations -----------------*/

/*----------------------------------------------------------------------------+
 | This Private Procedure Get_Next_Event_Num gets the maximum event num + 1   |
 | for the project and task.                                                  |
 +----------------------------------------------------------------------------*/
  Procedure Get_Next_Event_Num ( P_Project_ID         IN  NUMBER,
                                 P_Task_ID            IN  NUMBER,
                                 X_Event_Num          OUT NOCOPY NUMBER ); --File.Sql.39 bug 4440895



  Procedure       Check_Event_Action  ( P_Project_Id     IN  NUMBER,
                                        P_Task_ID        IN  NUMBER,
                                        P_Event_Num      IN  NUMBER,
                                        P_Event_Id       IN  NUMBER,
                                        P_Event_Action   IN  VARCHAR2,
                                        P_Action_Name    IN  VARCHAR2,
                                        P_Init_Msg_List  IN  VARCHAR2,
                                        P_Event_Num_Chg  IN  VARCHAR2,
                                        P_Rec_Ver_Num    IN  NUMBER,
                                        P_Mcb_Enabled_Flag    IN  VARCHAR2,
                                        P_Pfc_Rate_Date_Code    IN  VARCHAR2,
                                        P_Pc_Rate_Date_Code    IN  VARCHAR2,
                                        P_Fc_Rate_Date_Code    IN  VARCHAR2,
                                        P_Projfunc_Curr_Code    IN  VARCHAR2,
                                        P_Project_Curr_Code    IN  VARCHAR2,
                                        P_Bill_Trans_Curr_Code    IN  VARCHAR2,
                                        P_Pfc_Rate_Type    IN  VARCHAR2,
                                        P_Pc_Rate_Type    IN  VARCHAR2,
                                        P_Fc_Rate_Type    IN  VARCHAR2,
                                        P_Pfc_Rate_Date    IN  DATE,
                                        P_Pc_Rate_Date    IN  DATE,
                                        P_Fc_Rate_Date    IN  DATE,
                                        P_Pfc_Excg_Rate    IN  NUMBER,
                                        P_Pc_Excg_Rate    IN  NUMBER,
                                        P_Fc_Excg_Rate    IN  NUMBER,
                                        P_Event_Type      IN  VARCHAR2,
                                        P_Bill_Txn_Cur    IN  VARCHAR2,
                                        P_Invoice_Amt     IN  NUMBER,
                                        P_Revenue_Amt     IN  NUMBER,
                                        P_Event_Org       IN  NUMBER,
                                        X_Msg_Data        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                        X_Msg_Count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                        X_Return_Status  OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

  Function  Check_Delv_Event_Processed  ( P_Project_Id     IN  NUMBER,
                                          P_Deliverable_Id IN  NUMBER,
                                          P_Action_Id      IN  NUMBER)
                                        RETURN VARCHAR2;

 Procedure Delete_Delv_Event ( P_Project_Id     IN  NUMBER,
                               P_Deliverable_Id IN  NUMBER,
                               P_Action_Id      IN  NUMBER,
                               P_Action_Name    IN  VARCHAR2,
                               X_Return_Status  OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

  Procedure Get_Proj_Carry_Out_Org ( P_Project_ID         IN  NUMBER,
                                     X_Org_ID             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                     X_Org_Name           OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

  Function CHECK_BILLING_EVENT_EXISTS
  (
	  p_project_id       IN  pa_projects_all.project_id%TYPE,
	  p_dlv_element_id   IN  pa_proj_elements.proj_element_id%TYPE
  ) RETURN VARCHAR2 ;

/* Added for bug 3941159 */
  Procedure Upd_Event_Comp_Date
  (
    P_Deliverable_Id  IN     NUMBER,
    P_Action_Id       IN     NUMBER,
    P_Event_Date      IN     DATE
  );
/*------------- End of Public Procedure/Function Declarations ----------------*/

end PA_Billing_Wrkbnch_Events;

 

/
