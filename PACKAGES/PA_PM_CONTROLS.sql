--------------------------------------------------------
--  DDL for Package PA_PM_CONTROLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PM_CONTROLS" AUTHID CURRENT_USER AS
/*$Header: PAPMCONS.pls 120.1.12010000.2 2008/08/22 16:11:33 mumohan ship $*/
    Procedure Action_Allowed (p_action            IN VARCHAR2,
                              p_pm_product_code   IN VARCHAR2,
                              p_field_value_code  IN VARCHAR2 DEFAULT NULL,
                              p_action_allowed    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_error_code        OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              p_error_stack       IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_error_stage       IN OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

   Procedure Get_Project_Actions_Allowed (
                              p_pm_product_code   IN VARCHAR2,
                              p_delete_project_allowed    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_proj_num_allowed   OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_proj_name_allowed OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_proj_desc_allowed    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_proj_dates_allowed    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_proj_status_allowed    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_proj_manager_allowed    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_proj_org_allowed    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_add_task_allowed    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_delete_task_allowed    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_task_num_allowed    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_task_name_allowed    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_task_dates_allowed    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_task_desc_allowed    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_parent_task_allowed    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_task_org_allowed    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_error_code        OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              p_error_stack       IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_error_stage       IN OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

   Procedure Get_Billing_Actions_Allowed (
                              p_pm_product_code             IN VARCHAR2,
                              p_update_agreement_allowed    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_delete_agreement_allowed    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_add_funding_allowed         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_update_funding_allowed      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_delete_funding_allowed      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_error_code                  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              p_error_stack                 IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              p_error_stage                 IN OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

/*Added for event amg api enhancement*/
  PROCEDURE GET_EVENT_ACTIONS_ALLOWED (
                              P_PM_PRODUCT_CODE   	IN 	VARCHAR2,
                              P_UPDATE_EVENT_ALLOWED    OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              P_DELETE_EVENT_ALLOWED   	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
			      P_UPDATE_EVENT_BILL_HOLD 	OUT	NOCOPY VARCHAR2, /* added for bug 6870421*/
                              P_ERROR_CODE	      	OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
                              P_ERROR_STACK           	IN OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              P_ERROR_STAGE	      	IN OUT	NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
/*End Of change for amg api enhancement*/

END PA_PM_CONTROLS;

/
