--------------------------------------------------------
--  DDL for Package PA_BUDGET_ACCOUNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BUDGET_ACCOUNT_PKG" AUTHID CURRENT_USER AS
--   $Header: PABDACGS.pls 120.2 2005/08/12 10:33:39 bkattupa noship $

----------------------------------------------------------------------------------------+
--  Package             : PA_BUDGET_ACCOUNT_PKG
--
--  Purpose             : 1. Generate the Account Code CCID for every Budget Line
--                           depending upon the calling mode parameter.
--                        2. Update the Budget Line Data with generated CCID
--                        3. Update the Budget Account Summary Details
--                        4. Insert new Budget Lines which are having missed GL Periods
--                        5. Derive the Resource and Task related Parameters
--  Parameters          :
--     P_Calling_Mode--> SUBMIT / GENERATE_ACCOUNT
----------------------------------------------------------------------------------------+


----------------------------------------------------------------------------------------+
--  Procedure           : Gen_Account
--  Purpose             : Generate the Account Code CCID for every Budget Line
--                        depending upon the calling mode parameter and a given
--                        Budget Version ID
--  Parameters          : P_Calling_Mode--> SUBMIT / GENERATE_ACCOUNT
----------------------------------------------------------------------------------------+
PROCEDURE  Gen_Account (
  P_Budget_Version_ID     IN     PA_Budget_Versions.Budget_Version_ID%TYPE,
  P_Calling_Mode          IN     VARCHAR2,
  X_Return_Status         OUT    NOCOPY VARCHAR2,
  X_Msg_Count             OUT    NOCOPY NUMBER,
  X_Msg_Data              OUT    NOCOPY VARCHAR2
) ;

----------------------------------------------------------------------------------------+
--  Procedure           : Gen_Acct_All_Lines
--  Purpose             : Generate the Account Code CCID for all Budget Lines
--                        depending upon the calling mode parameter for a given
--                        Budget Version ID
--  Calling API         : Gen_Account
----------------------------------------------------------------------------------------+
PROCEDURE Gen_Acct_All_Lines (
  P_Budget_Version_ID       IN     PA_Budget_Versions.Budget_Version_ID%TYPE,
  P_Calling_Mode            IN     VARCHAR2,
  P_Budget_Type_Code        IN     PA_Budget_Types.Budget_Type_Code%TYPE,
  P_Budget_Entry_Level_Code IN     PA_Budget_Entry_Methods.Entry_Level_Code%TYPE,
  P_Project_ID              IN     PA_projects_All.project_id%TYPE,
  X_Return_Status           OUT    NOCOPY VARCHAR2,
  X_Msg_Count		    OUT    NOCOPY NUMBER,
  X_Msg_Data		    OUT	   NOCOPY VARCHAR2
) ;

----------------------------------------------------------------------------------------+
--  Procedure           : Gen_Acct_Line
--  Purpose             : Generate the Account Code CCID for a required Budget Line
--  Calling API         : Gen_Acct_All_Lines
----------------------------------------------------------------------------------------+
PROCEDURE Gen_Acct_Line (

  p_budget_entry_Level_Code     IN      pa_budget_entry_methods.Entry_Level_Code%TYPE,
  p_budget_type_code            IN      pa_budget_types.budget_type_code%TYPE,
  p_budget_version_id           IN      pa_budget_versions.budget_version_id%TYPE,

  p_project_id                  IN      pa_projects_all.project_id%TYPE,
  p_project_number              IN      pa_projects_all.segment1%TYPE,
  p_project_org_name            IN      hr_organization_units.name%TYPE,
  p_project_org_id              IN      hr_organization_units.organization_id %TYPE,
  p_project_type                IN      pa_project_types_all.project_type%TYPE,
  p_project_class_code		IN	pa_project_classes.class_code%TYPE,  /* Added for bug 2914197 */
  p_task_id                     IN      pa_tasks.task_id%TYPE,

  p_resource_list_flag          IN      VARCHAR2,
  p_resource_type_id            IN      pa_resource_types.resource_type_code%TYPE,
  p_resource_group_id           IN      pa_resource_types.resource_type_id%TYPE,
  p_resource_assign_id          IN      pa_budget_lines.resource_assignment_id%TYPE,
  p_start_date                  IN      pa_budget_lines.start_date%TYPE,

  p_person_ID                   IN      per_all_people_f.Person_ID%TYPE,
  p_expenditure_category        IN      pa_expenditure_categories.expenditure_category%TYPE,
  p_expenditure_type            IN      pa_expenditure_types.expenditure_type%TYPE,
  p_job_id                      IN      per_jobs.job_id%TYPE,
  p_organization_id             IN      hr_all_organization_units.organization_id%TYPE,
  p_supplier_id                 IN      po_vendors.vendor_id%TYPE,

  x_return_ccid                 OUT     NOCOPY gl_code_combinations.code_combination_id%TYPE,
  X_Return_Status               OUT     NOCOPY VARCHAR2,
  X_Msg_Count                   OUT     NOCOPY NUMBER,
  X_Msg_Data                    OUT     NOCOPY VARCHAR2,

  x_concat_segs                 OUT     NOCOPY VARCHAR2,
  x_concat_ids                  OUT     NOCOPY VARCHAR2,
  x_concat_descrs               OUT     NOCOPY VARCHAR2,
  x_error_message               OUT     NOCOPY VARCHAR2
) ;

----------------------------------------------------------------------------------------+
--  Procedure           : Insert_into_Budget_Lines
--  Purpose             : Insert into Budget Lines with amount=0 for a missed GL Period
--  Calling API         : Gen_Acct_All_Lines
----------------------------------------------------------------------------------------+
PROCEDURE Insert_into_Budget_Lines (
  P_Budget_Version_ID        IN     PA_Budget_Versions.Budget_Version_ID%TYPE,
  P_Project_ID               IN     PA_projects_All.project_id%TYPE,
  P_Project_Start_Date       IN     DATE,
  P_Project_End_Date         IN     DATE,
  X_Return_Status            OUT    NOCOPY VARCHAR2,
  X_Msg_Count                OUT    NOCOPY NUMBER,
  X_Msg_Data                 OUT    NOCOPY VARCHAR2
) ;

----------------------------------------------------------------------------------------+
--  Procedure           : Derive_Resource_Params
--  Purpose             : To Derive the Budget Line's Resource Parameters
--  Calling API         : Gen_Acct_Line
----------------------------------------------------------------------------------------+
PROCEDURE Derive_Resource_Params (
  p_person_id                 IN      per_all_people_f.person_id%TYPE,
  p_job_id                    IN      per_jobs.job_id%TYPE,
  p_organization_id           IN      hr_all_organization_units.organization_id%TYPE,
  p_supplier_id               IN      po_vendors.vendor_id%TYPE,
  x_employee_number           OUT     NOCOPY per_all_people_f.employee_number%TYPE,
  X_Person_Type		      OUT     NOCOPY PA_Employees.Person_Type%TYPE,  -- FP_M changes
  x_job_name                  OUT     NOCOPY per_jobs.name%TYPE,
  x_job_group_id              OUT     NOCOPY per_jobs.job_group_id%TYPE,
  x_job_group_name            OUT     NOCOPY per_job_groups.internal_name%TYPE,
  x_organization_type         OUT     NOCOPY hr_all_organization_units.type%TYPE,
  x_organization_name         OUT     NOCOPY hr_all_organization_units.name%TYPE,
  x_supplier_name             OUT     NOCOPY po_vendors.vendor_name%TYPE,
  X_Return_Status             OUT     NOCOPY VARCHAR2,
  X_Msg_Count                 OUT     NOCOPY NUMBER,
  X_Msg_Data                  OUT     NOCOPY VARCHAR2
) ;

----------------------------------------------------------------------------------------+
--  Procedure           : Derive_Task_Params
--  Purpose             : To Derive the Budget Line's Task Parameters
--  Calling API         : Gen_Acct_Line
----------------------------------------------------------------------------------------+
PROCEDURE Derive_Task_Params (
  p_project_id                IN      pa_projects_all.project_id%TYPE,
  p_top_task_id               IN      pa_tasks.task_id%TYPE,
  p_low_task_id               IN      pa_tasks.task_id%TYPE,
  x_top_task_number           OUT     NOCOPY pa_tasks.task_number%TYPE,
  x_task_organization_id      OUT     NOCOPY hr_organization_units.organization_id%TYPE,
  x_task_organization_name    OUT     NOCOPY hr_organization_units.name%TYPE,
  x_task_service_type         OUT     NOCOPY pa_tasks.service_type_code%TYPE,
  x_task_number               OUT     NOCOPY pa_tasks.task_number%TYPE,
  X_Return_Status             OUT     NOCOPY VARCHAR2,
  X_Msg_Count                 OUT     NOCOPY NUMBER,
  X_Msg_Data                  OUT     NOCOPY VARCHAR2
) ;

END PA_BUDGET_ACCOUNT_PKG ; /* End Package Specifications PA_BUDGET_ACCOUNT_PKG */

 

/
