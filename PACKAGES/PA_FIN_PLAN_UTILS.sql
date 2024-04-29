--------------------------------------------------------
--  DDL for Package PA_FIN_PLAN_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FIN_PLAN_UTILS" AUTHID CURRENT_USER AS
/* $Header: PAFPUTLS.pls 120.5.12010000.4 2009/06/18 09:16:05 gboomina ship $
   Start of Comments
   Package name     : PA_FIN_PLAN_UTILS
   Purpose          : utility API's for Org Forecast pages
   History          :
   NOTE             :
   End of Comments
*/

Check_Locked_By_User_Exception  EXCEPTION;

/*
   Declaration of global variables to be used in webadi - Currently these
   globals are used in the procedure VALIDATE_CURRENCY_ATTRIBUTES. In the
   beginning of the procedure these globals are set to null and then populated
   down the line depending on the error.
*/
g_first_error_code              varchar2(30);
g_pc_pfc_context                PA_LOOKUPS.LOOKUP_CODE%TYPE;
g_cost_rev_context              varchar2(30);


function get_lookup_value
    (p_lookup_type      pa_lookups.lookup_type%TYPE,
     p_lookup_code      pa_lookups.lookup_code%TYPE) return VARCHAR2;

procedure Check_Record_Version_Number
    (p_unique_index             IN  NUMBER,
     p_record_version_number    IN  NUMBER,
     x_valid_flag               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_return_status            OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_error_msg_code           OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

function Retrieve_Record_Version_Number
    (p_budget_version_id       IN  pa_budget_versions.budget_version_id%TYPE)
    return number;

FUNCTION Plan_Amount_Exists
    (p_budget_version_id       IN pa_budget_versions.budget_version_id%TYPE)
    RETURN VARCHAR2;
--PRAGMA RESTRICT_REFERENCES ( Plan_Amount_Exists, WNDS, WNPS);

/*
  API Name : Plan_Amount_Exists_Task_Res
  API Description   : Return 'Y' if at least one record exists in Resource Assignments (pa_resource_assignments)
                           for the given Budget Version Id, Task Id, Resource List Member Id
  API Created By    : Vthakkar
  API Creation Date : 15-MAR-2004
*/

FUNCTION Plan_Amount_Exists_Task_Res
    (p_budget_version_id       IN pa_budget_versions.budget_version_id%TYPE ,
      p_task_id                       IN pa_tasks.task_id%TYPE Default Null,
      p_resource_list_member_id IN pa_resource_list_members.RESOURCE_LIST_MEMBER_ID%TYPE Default Null
     ) RETURN VARCHAR2;



FUNCTION Get_Resource_List_Id (
         p_fin_plan_version_id  IN   pa_proj_fp_options.fin_plan_version_id %TYPE )
RETURN   pa_proj_fp_options.all_resource_list_id%TYPE;
--PRAGMA RESTRICT_REFERENCES ( Get_Resource_List_Id, WNDS, WNPS);

FUNCTION Get_Time_Phased_code (
         p_fin_plan_version_id  IN   pa_proj_fp_options.fin_plan_version_id %TYPE )
RETURN   pa_proj_fp_options.all_time_phased_code%TYPE;
--PRAGMA RESTRICT_REFERENCES ( Get_Time_Phased_code , WNDS, WNPS);

FUNCTION Get_Multi_Curr_Flag(
         p_fin_plan_version_id  IN   pa_proj_fp_options.fin_plan_version_id %TYPE )
RETURN   pa_proj_fp_options.plan_in_multi_curr_flag%TYPE;

FUNCTION Get_Fin_Plan_Level_Code(
         p_fin_plan_version_id  IN   pa_proj_fp_options.fin_plan_version_id %TYPE )
RETURN   pa_proj_fp_options.all_fin_plan_level_code%TYPE;
--PRAGMA RESTRICT_REFERENCES ( Get_Fin_Plan_Level_Code, WNDS, WNPS);

FUNCTION Get_Amount_Set_Id(
         p_fin_plan_version_id  IN   pa_proj_fp_options.fin_plan_version_id %TYPE )
RETURN   pa_proj_fp_options.all_amount_set_id%TYPE;
--PRAGMA RESTRICT_REFERENCES ( Get_Amount_Set_Id, WNDS, WNPS);

FUNCTION Get_Period_Profile_Start_Date
        (p_period_profile_id    IN   pa_budget_versions.period_profile_id%TYPE)
return pa_proj_period_profiles.period_name1%TYPE;

FUNCTION Get_Period_Profile_End_Date
        (p_period_profile_id    IN   pa_budget_versions.period_profile_id%TYPE)
return pa_proj_period_profiles.profile_end_period_name%TYPE;

/* This fuction will return  workplan budget version res_list_id */
FUNCTION Get_wp_bv_res_list_id
   ( p_proj_structure_version_id NUMBER)
RETURN NUMBER ;

/*=============================================================================
   This function will return the time phase code
   of the budget_version_id for a given wp_structure_version_id.
   P->PA, G->Gl, N->None
==============================================================================*/
FUNCTION Get_wp_bv_time_phase
    (p_wp_structure_version_id IN PA_BUDGET_VERSIONS.PROJECT_STRUCTURE_VERSION_ID%TYPE)
RETURN VARCHAR2;

/*=============================================================================
   This function will return the approved cost budget current baselined version.
   If version is not available then it will return null value.
==============================================================================*/
FUNCTION Get_app_budget_cost_cb_ver
    (p_project_id     IN   pa_projects_all.project_id%TYPE)
RETURN NUMBER;


PROCEDURE Get_Appr_Cost_Plan_Type_Info(
          p_project_id     IN   pa_projects_all.project_id%TYPE
          ,x_plan_type_id  OUT  NOCOPY pa_proj_fp_options.fin_plan_type_id%TYPE --File.Sql.39 bug 4440895
          ,x_return_status OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count     OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data      OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Get_Appr_Rev_Plan_Type_Info(
          p_project_id     IN   pa_projects_all.project_id%TYPE
          ,x_plan_type_id  OUT  NOCOPY pa_proj_fp_options.fin_plan_type_id%TYPE --File.Sql.39 bug 4440895
          ,x_return_status OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count     OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data      OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Get_Baselined_Version_Info(
          p_project_id            IN   pa_projects_all.project_id%TYPE
          ,p_fin_plan_type_id     IN   pa_budget_versions.fin_plan_type_id%TYPE
          ,p_version_type         IN   pa_budget_versions.version_type%TYPE
          ,x_fp_options_id         OUT  NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE      --File.Sql.39 bug 4440895
          ,x_fin_plan_version_id  OUT  NOCOPY pa_proj_fp_options.fin_plan_version_id%TYPE --File.Sql.39 bug 4440895
          ,x_return_status        OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count            OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data             OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


     /*bug 3224177 start*/
--      Refer to Update "16-JAN-04 sagarwal" in the history above.
--      This has been added as part of code merge
 PROCEDURE Delete_Fp_Options
     (p_project_id           IN        PA_FP_TXN_CURRENCIES.PROJECT_ID%TYPE
     ,x_err_code             IN OUT    NOCOPY NUMBER); --File.Sql.39 bug 4440895


PROCEDURE Update_Txn_Currencies
    ( p_project_id        IN        PA_FP_TXN_CURRENCIES.PROJECT_ID%TYPE
     ,p_proj_curr_code    IN        PA_FP_TXN_CURRENCIES.TXN_CURRENCY_CODE%TYPE);
 /*bug 3224177 end*/



PROCEDURE Get_Curr_Working_Version_Info(
          p_project_id         IN   pa_projects_all.project_id%TYPE
          ,p_fin_plan_type_id  IN   pa_budget_versions.fin_plan_type_id%TYPE
          ,p_version_type      IN   pa_budget_versions.version_type%TYPE
          ,x_fp_options_id         OUT  NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE      --File.Sql.39 bug 4440895
          ,x_fin_plan_version_id  OUT  NOCOPY pa_proj_fp_options.fin_plan_version_id%TYPE --File.Sql.39 bug 4440895
          ,x_return_status     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data          OUT  NOCOPY VARCHAR2);          --File.Sql.39 bug 4440895

PROCEDURE GET_OR_CREATE_AMOUNT_SET_ID
       (
        p_raw_cost_flag          IN  pa_fin_plan_amount_sets.raw_cost_flag%TYPE,
        p_burdened_cost_flag     IN  pa_fin_plan_amount_sets.burdened_cost_flag%TYPE,
        p_revenue_flag           IN  pa_fin_plan_amount_sets.revenue_flag%TYPE,
        p_cost_qty_flag          IN  pa_fin_plan_amount_sets.cost_qty_flag%TYPE,
        p_revenue_qty_flag       IN  pa_fin_plan_amount_sets.revenue_qty_flag%TYPE,
        p_all_qty_flag           IN  pa_fin_plan_amount_sets.all_qty_flag%TYPE,
        p_plan_pref_code         IN  pa_proj_fp_options.fin_plan_preference_code%TYPE,
/* Changes for FP.M, Tracking Bug No - 3354518
Adding three new IN parameters p_bill_rate_flag,
p_cost_rate_flag, p_burden_rate below for
new columns in pa_fin_plan_amount_sets */
        p_bill_rate_flag         IN  pa_fin_plan_amount_sets.bill_rate_flag%TYPE,
          p_cost_rate_flag         IN  pa_fin_plan_amount_sets.cost_rate_flag%TYPE,
     p_burden_rate_flag       IN  pa_fin_plan_amount_sets.burden_rate_flag%TYPE,
     x_cost_amount_set_id     OUT NOCOPY pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE, --File.Sql.39 bug 4440895
        x_revenue_amount_set_id  OUT NOCOPY pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE, --File.Sql.39 bug 4440895
        x_all_amount_set_id      OUT NOCOPY pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE, --File.Sql.39 bug 4440895
        x_message_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
        x_return_status          OUT NOCOPY VARCHAR2,         --File.Sql.39 bug 4440895
        x_message_data           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      );

PROCEDURE GET_PLAN_AMOUNT_FLAGS(
      P_AMOUNT_SET_ID       IN  PA_FIN_PLAN_AMOUNT_SETS.fin_plan_amount_set_id%TYPE,
      X_RAW_COST_FLAG       OUT NOCOPY PA_FIN_PLAN_AMOUNT_SETS.raw_cost_flag%TYPE, --File.Sql.39 bug 4440895
      X_BURDENED_FLAG       OUT NOCOPY PA_FIN_PLAN_AMOUNT_SETS.burdened_cost_flag%TYPE, --File.Sql.39 bug 4440895
      X_REVENUE_FLAG        OUT NOCOPY PA_FIN_PLAN_AMOUNT_SETS.revenue_flag%TYPE, --File.Sql.39 bug 4440895
      X_COST_QUANTITY_FLAG  OUT NOCOPY PA_FIN_PLAN_AMOUNT_SETS.cost_qty_flag%TYPE, --File.Sql.39 bug 4440895
      X_REV_QUANTITY_FLAG   OUT NOCOPY PA_FIN_PLAN_AMOUNT_SETS.revenue_qty_flag%TYPE, --File.Sql.39 bug 4440895
      X_ALL_QUANTITY_FLAG   OUT NOCOPY PA_FIN_PLAN_AMOUNT_SETS.all_qty_flag%TYPE, --File.Sql.39 bug 4440895
/* Changes for FP.M, Tracking Bug No - 3354518
Adding three new OUT parameters x_bill_rate_flag,
x_cost_rate_flag, x_burden_rate below for
new columns in pa_fin_plan_amount_sets */
      X_BILL_RATE_FLAG      OUT  NOCOPY pa_fin_plan_amount_sets.bill_rate_flag%TYPE, --File.Sql.39 bug 4440895
      X_COST_RATE_FLAG      OUT  NOCOPY pa_fin_plan_amount_sets.cost_rate_flag%TYPE, --File.Sql.39 bug 4440895
      X_BURDEN_RATE_FLAG    OUT  NOCOPY pa_fin_plan_amount_sets.burden_rate_flag%TYPE, --File.Sql.39 bug 4440895
      x_message_count       OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
      x_return_status       OUT NOCOPY VARCHAR2,         --File.Sql.39 bug 4440895
      x_message_data        OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION is_orgforecast_plan
    (p_budget_version_id    IN  pa_budget_versions.budget_version_id%TYPE)
return VARCHAR2;


/* Changes for FP.M, Tracking Bug No - 3354518
Modifying the type of the IN parameter p_element_type
below as pa_fp_elements is being obsoleted. */
/*
FUNCTION GET_OPTION_PLANNING_LEVEL(
         P_PROJ_FP_OPTIONS_ID  IN  pa_proj_fp_options.proj_fp_options_id%TYPE,
         P_ELEMENT_TYPE        IN pa_fp_elements.element_type%TYPE)
RETURN   pa_proj_fp_options.all_fin_plan_level_code%TYPE;
*/
FUNCTION GET_OPTION_PLANNING_LEVEL(
         P_PROJ_FP_OPTIONS_ID  IN  pa_proj_fp_options.proj_fp_options_id%TYPE,
         P_ELEMENT_TYPE        IN pa_budget_versions.version_type%TYPE)
RETURN   pa_proj_fp_options.all_fin_plan_level_code%TYPE;


FUNCTION get_person_name
    (p_person_id   IN   NUMBER) return VARCHAR2;

/*This is due to bug 2607945*/
FUNCTION is_plan_type_addition_allowed
          (p_project_id                   IN   pa_projects_all.project_id%TYPE
          ,P_FIN_PLAN_TYPE_ID             IN   pa_fin_plan_types_b.fin_plan_type_id%TYPE
          ) RETURN VARCHAR2 ;


PROCEDURE Get_Peceding_Suceeding_Pd_Info
      (   p_resource_assignment_id     IN  pa_budget_lines.RESOURCE_ASSIGNMENT_ID%TYPE
         ,p_txn_currency_code          IN  pa_budget_lines.TXN_CURRENCY_CODE%TYPE
         ,x_preceding_prd_start_date  OUT  NOCOPY DATE --File.Sql.39 bug 4440895
         ,x_preceding_prd_end_date    OUT  NOCOPY DATE --File.Sql.39 bug 4440895
         ,x_succeeding_prd_start_date OUT  NOCOPY DATE --File.Sql.39 bug 4440895
         ,x_succeeding_prd_end_date   OUT  NOCOPY DATE --File.Sql.39 bug 4440895
         ,x_return_status             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count                 OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data                  OUT  NOCOPY VARCHAR2   --File.Sql.39 bug 4440895
      ) ;

PROCEDURE Get_Element_Proj_PF_Amounts
         (
           p_resource_assignment_id       IN   pa_budget_lines.RESOURCE_ASSIGNMENT_ID%TYPE
          ,p_txn_currency_code            IN   pa_budget_lines.TXN_CURRENCY_CODE%TYPE
          ,x_quantity                     OUT  NOCOPY pa_budget_lines.QUANTITY%TYPE --File.Sql.39 bug 4440895
          ,x_project_raw_cost             OUT  NOCOPY pa_budget_lines.TXN_RAW_COST%TYPE --File.Sql.39 bug 4440895
          ,x_project_burdened_cost        OUT  NOCOPY pa_budget_lines.TXN_BURDENED_COST%TYPE --File.Sql.39 bug 4440895
          ,x_project_revenue              OUT  NOCOPY pa_budget_lines.TXN_REVENUE%TYPE --File.Sql.39 bug 4440895
          ,x_projfunc_raw_cost            OUT  NOCOPY pa_budget_lines.TXN_RAW_COST%TYPE --File.Sql.39 bug 4440895
          ,x_projfunc_burdened_cost       OUT  NOCOPY pa_budget_lines.TXN_BURDENED_COST%TYPE --File.Sql.39 bug 4440895
          ,x_projfunc_revenue             OUT  NOCOPY pa_budget_lines.TXN_REVENUE%TYPE --File.Sql.39 bug 4440895
          ,x_return_status                OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                    OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                     OUT  NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
          );

PROCEDURE Check_Version_Name_Or_id
          (
           p_budget_version_id            IN   pa_budget_versions.BUDGET_VERSION_ID%TYPE
          ,p_project_id                   IN   pa_budget_versions.project_id%TYPE                -- Bug 2770562
          ,p_version_name                 IN   pa_budget_versions.VERSION_NAME%TYPE
          ,p_check_id_flag                IN   VARCHAR2
          ,x_budget_version_id            OUT  NOCOPY pa_budget_versions.BUDGET_VERSION_ID%TYPE --File.Sql.39 bug 4440895
          ,x_return_status                OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                    OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          );

PROCEDURE Check_Currency_Name_Or_Code
          (
           p_txn_currency_code            IN   pa_fp_txn_currencies.txn_currency_code%TYPE
          ,p_currency_code_name           IN   VARCHAR2
          ,p_check_id_flag                IN   VARCHAR2
          ,x_txn_currency_code            OUT  NOCOPY pa_fp_txn_currencies.txn_currency_code%TYPE --File.Sql.39 bug 4440895
          ,x_return_status                OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                    OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ) ;


/* Changes for FP.M, Tracking Bug No - 3354518
Replacing all references of PA_TASKS by PA_STRUCT_TASK_WBS_V*/
/* Commenting code below for FP.M changes, Tracking Bug No - 3354518 */
/*PROCEDURE check_task_name_or_id
    (p_project_id       IN  pa_tasks.project_id%TYPE,
     p_task_id          IN  pa_tasks.task_id%TYPE,
     p_task_name        IN  pa_tasks.task_name%TYPE,
     p_check_id_flag    IN  VARCHAR2,
     x_task_id          OUT pa_tasks.task_id%TYPE,
     x_return_status    OUT VARCHAR2,
     x_msg_count        OUT NUMBER,
     x_error_msg        OUT VARCHAR2);*/
/* Rewriting procedure declaration below to refer to pa_struct_task_wbs_v
instead of pa_tasks - as part of worplan structure model changes in FP.M */
PROCEDURE check_task_name_or_id
    (p_project_id       IN  PA_STRUCT_TASK_WBS_V.project_id%TYPE,
     p_task_id          IN  PA_STRUCT_TASK_WBS_V.task_id%TYPE,
     p_task_name        IN  PA_STRUCT_TASK_WBS_V.task_name%TYPE,
     p_check_id_flag    IN  VARCHAR2,
     x_task_id          OUT NOCOPY PA_STRUCT_TASK_WBS_V.task_id%TYPE, --File.Sql.39 bug 4440895
     x_return_status    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count        OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_error_msg        OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/* Changes for FP.M, Tracking Bug No - 3354518
   The procedure check_resource_gp_name_or_id is being obsoleted as the
   concept of Resource group is no longer there in case of the New dev
   model of FP.M. However we are adding code in the procedure to raise
   a exception unconditionally for tracking/debuging purposes at the moment.
   Basically to note any calls made to this procedure. Eventually we shall be
   commenting out this procedure because of its nonusage.  */
PROCEDURE check_resource_gp_name_or_id
    (p_resource_id      IN  pa_resources.resource_id%TYPE,
     p_resource_name    IN  pa_resources.name%TYPE,
     p_check_id_flag    IN  VARCHAR2,
     x_resource_id      OUT NOCOPY pa_resource_list_members.resource_list_member_id%TYPE, --File.Sql.39 bug 4440895
     x_return_status    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count        OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_error_msg        OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE check_resource_name_or_id
    (p_resource_id      IN  pa_resources.resource_id%TYPE,
     p_resource_name    IN  pa_resources.name%TYPE,
     p_check_id_flag    IN  VARCHAR2,
     x_resource_id      OUT NOCOPY pa_resources.resource_id%TYPE, --File.Sql.39 bug 4440895
     x_return_status    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count        OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_error_msg        OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION check_proj_fp_options_exists
    (p_project_id       IN pa_proj_fp_options.project_id%TYPE)
return NUMBER;

FUNCTION get_amttype_id
  ( p_amt_typ_code     IN pa_amount_types_b.amount_type_code%TYPE) RETURN NUMBER;

PROCEDURE Check_Locked_By_User
        (p_user_id              IN      NUMBER,
         p_budget_version_id    IN      pa_budget_versions.budget_version_id%TYPE,
         x_is_locked_by_userid  OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
         x_locked_by_person_id  OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
         x_return_status        OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
         x_msg_count            OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
         x_msg_data             OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Check_Both_Locked_By_User
        (p_user_id              IN      NUMBER,
         p_budget_version_id1   IN      pa_budget_versions.budget_version_id%TYPE,
         p_budget_version_id2   IN      pa_budget_versions.budget_version_id%TYPE,
         x_is_locked_by_userid  OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
         x_return_status        OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
         x_msg_count            OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
         x_msg_data             OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION check_budget_trans_exists
        (p_project_id           IN      pa_projects_all.project_id%TYPE)
        return VARCHAR2;

FUNCTION enable_auto_baseline
        (p_project_id           IN      pa_projects_all.project_id%TYPE)
        return VARCHAR2;

PROCEDURE Get_Resource_List_Info
         (p_resource_list_id           IN   pa_resource_lists.RESOURCE_LIST_ID%TYPE
         ,x_res_list_is_uncategorized  OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_is_resource_list_grouped   OUT  NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
         ,x_group_resource_type_id     OUT  NOCOPY pa_resource_lists.GROUP_RESOURCE_TYPE_ID%TYPE  --File.Sql.39 bug 4440895
         ,x_return_status              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count                  OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data                   OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


/* Changes for FPM, Tracking Bug - 3354518
   Adding Procedure Get_Resource_List_Info below.
   Please note that this proceedure is a overloaded procedure.
   The reason behind overloading this procedure below is the
   is the addiditon of three fields use_for_wp_flag,control_flag
   and migration_code to pa_resource_lists_all_bg */
PROCEDURE Get_Resource_List_Info
         (p_resource_list_id           IN   pa_resource_lists.RESOURCE_LIST_ID%TYPE
         ,x_res_list_is_uncategorized  OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_is_resource_list_grouped   OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_group_resource_type_id     OUT  NOCOPY pa_resource_lists.GROUP_RESOURCE_TYPE_ID%TYPE --File.Sql.39 bug 4440895
         ,x_use_for_wp_flag            OUT  NOCOPY pa_resource_lists_all_bg.use_for_wp_flag%TYPE /*New Column added for FPM */ --File.Sql.39 bug 4440895
         ,x_control_flag               OUT  NOCOPY pa_resource_lists_all_bg.control_flag%TYPE /*New Column added for FPM */ --File.Sql.39 bug 4440895
         ,x_migration_code             OUT  NOCOPY pa_resource_lists_all_bg.migration_code%TYPE /*New Column added for FPM */ --File.Sql.39 bug 4440895
         ,x_return_status              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count                  OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data                   OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


PROCEDURE Get_Uncat_Resource_List_Info
         (x_resource_list_id           OUT   NOCOPY pa_resource_lists.RESOURCE_LIST_ID%TYPE --File.Sql.39 bug 4440895
         ,x_resource_list_member_id    OUT   NOCOPY pa_resource_list_members.RESOURCE_LIST_MEMBER_ID%TYPE --File.Sql.39 bug 4440895
         ,x_track_as_labor_flag        OUT   NOCOPY pa_resource_list_members.TRACK_AS_LABOR_FLAG%TYPE --File.Sql.39 bug 4440895
         ,x_unit_of_measure            OUT   NOCOPY pa_resources.UNIT_OF_MEASURE%TYPE --File.Sql.39 bug 4440895
         ,x_return_status              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count                  OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data                   OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Is_AC_PT_Attached_After_UPG(
          p_project_id     IN   pa_projects_all.project_id%TYPE
          ,x_plan_type_id  OUT  NOCOPY pa_proj_fp_options.fin_plan_type_id%TYPE --File.Sql.39 bug 4440895
          ,x_return_status OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count     OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data      OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Is_AR_PT_Attached_After_UPG(
          p_project_id     IN   pa_projects_all.project_id%TYPE
          ,x_plan_type_id  OUT  NOCOPY pa_proj_fp_options.fin_plan_type_id%TYPE --File.Sql.39 bug 4440895
          ,x_return_status OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count     OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data      OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Get_Max_Budget_Version_Number
        (p_project_id         IN      pa_budget_versions.project_id%TYPE
        ,p_fin_plan_type_id   IN      pa_budget_versions.fin_plan_type_id%TYPE
        ,p_version_type       IN      pa_budget_versions.version_type%TYPE
        ,p_copy_mode          IN      VARCHAR2
        ,p_ci_id              IN      NUMBER
        ,p_lock_required_flag IN      VARCHAR2
        ,x_version_number     OUT     NOCOPY pa_budget_versions.version_number%TYPE --File.Sql.39 bug 4440895
        ,x_return_status      OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_msg_count          OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
        ,x_msg_data           OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION get_period_start_date (p_input_date IN pa_periods_all.start_date%TYPE,
                                p_time_phased_code IN pa_proj_fp_options.cost_time_phased_Code%TYPE) RETURN DATE;

FUNCTION get_period_end_date (p_input_date IN pa_periods_all.end_date%TYPE,
                              p_time_phased_code IN pa_proj_fp_options.cost_time_phased_Code%TYPE) RETURN DATE;
/*==============================================================================
   This api returns the current baselined version for a given project and
   budget_type_code or fin_plan_type combination.
   1)If the plan type is COST_AND_REV_SAME, then it returns 'ALL' version
   2)If it is REVENUE_ONLY or COST_AND_REV_SEP then it returns 'REVENUE'  version
 ===============================================================================*/

PROCEDURE GET_REV_BASE_VERSION_INFO
   (  p_project_id              IN      pa_budget_versions.project_id%TYPE
     ,p_fin_plan_Type_id        IN      pa_budget_versions.fin_plan_type_id%TYPE
     ,p_budget_type_code        IN      pa_budget_versions.budget_type_code%TYPE
     ,x_budget_version_id       OUT     NOCOPY pa_budget_versions.budget_version_id%TYPE --File.Sql.39 bug 4440895
     ,x_return_status           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count               OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*==============================================================================
   This api returns the Current Baselined Version for a given project and
   budget_type_code or fin_plan_type combination.

   1)If the plan type is COST_AND_REV_SAME, then it returns 'ALL' version
   2)If it is COST_ONLY or COST_AND_REV_SEP then it returns 'COST'  version
 ===============================================================================*/

PROCEDURE GET_COST_BASE_VERSION_INFO
   (  p_project_id              IN      pa_budget_versions.project_id%TYPE
     ,p_fin_plan_Type_id        IN      pa_budget_versions.fin_plan_type_id%TYPE
     ,p_budget_type_code        IN      pa_budget_versions.budget_type_code%TYPE
     ,x_budget_version_id       OUT     NOCOPY pa_budget_versions.budget_version_id%TYPE --File.Sql.39 bug 4440895
     ,x_return_status           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count               OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


FUNCTION ACQUIRE_USER_LOCK
   ( X_LOCK_NAME  IN  VARCHAR2 )
RETURN NUMBER ;

FUNCTION RELEASE_USER_LOCK
   ( X_LOCK_NAME  IN  VARCHAR2 )
RETURN NUMBER ;

PROCEDURE get_converted_amounts
   (  p_budget_version_id       IN   pa_budget_versions.budget_version_id%TYPE
     ,p_txn_raw_cost            IN   pa_budget_versions.est_project_raw_cost%TYPE
     ,p_txn_burdened_cost       IN   pa_budget_versions.est_project_burdened_cost%TYPE
     ,p_txn_revenue             IN   pa_budget_versions.est_project_revenue%TYPE
     ,p_txn_currency_Code       IN   pa_projects_all.project_currency_code%TYPE
     ,p_project_currency_code   IN   pa_projects_all.project_currency_code%TYPE
     ,p_projfunc_currency_code  IN   pa_projects_all.projfunc_currency_code%TYPE
     ,x_project_raw_cost        OUT  NOCOPY pa_budget_versions.est_projfunc_raw_cost%TYPE --File.Sql.39 bug 4440895
     ,x_project_burdened_cost   OUT  NOCOPY pa_budget_versions.est_projfunc_burdened_cost%TYPE --File.Sql.39 bug 4440895
     ,x_project_revenue         OUT  NOCOPY pa_budget_versions.est_projfunc_revenue%TYPE --File.Sql.39 bug 4440895
     ,x_projfunc_raw_cost       OUT  NOCOPY pa_budget_versions.est_projfunc_raw_cost%TYPE --File.Sql.39 bug 4440895
     ,x_projfunc_burdened_cost  OUT  NOCOPY pa_budget_versions.est_projfunc_burdened_cost%TYPE --File.Sql.39 bug 4440895
     ,x_projfunc_revenue        OUT  NOCOPY pa_budget_versions.est_projfunc_revenue%TYPE --File.Sql.39 bug 4440895
     ,x_return_status           OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count               OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION check_proj_fin_plan_exists (x_project_id             IN NUMBER,
                                     x_budget_version_id      IN NUMBER,
                                     x_budget_status_code     IN VARCHAR2,
                                     x_plan_type_code         IN VARCHAR2,
                                     x_fin_plan_type_id       IN NUMBER,
                                     x_version_type           IN VARCHAR2
                                    ) RETURN NUMBER;

FUNCTION check_task_fin_plan_exists (x_task_id                IN NUMBER,
                                     x_budget_version_id      IN NUMBER,
                                     x_budget_status_code     IN VARCHAR2,
                                     x_plan_type_code         IN VARCHAR2,
                                     x_fin_plan_type_id       IN NUMBER,
                                     x_version_type           IN VARCHAR2
                                    ) RETURN NUMBER;

/*  Changes for FPM. Tracking Bug - 3354518
    Modifying the datatype of parameter p_plan_period_type below to varchar2
    and x_shifted_period_start_date and x_shifted_period_end_date as date*/
PROCEDURE Get_Period_Details
   (  p_period_name           IN        pa_periods.period_name%TYPE
/*   ,p_plan_period_type              IN      pa_proj_period_profiles.plan_period_type%TYPE */
     ,p_plan_period_type              IN      VARCHAR2
     ,x_start_date            OUT       NOCOPY DATE --File.Sql.39 bug 4440895
     ,x_end_date              OUT       NOCOPY DATE --File.Sql.39 bug 4440895
     ,x_return_status         OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT       NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*  Changes for FPM. Tracking Bug - 3354518
    Modifying the datatype of parameter p_plan_period_type below to varchar2
    and x_shifted_period_start_date and x_shifted_period_end_date as date*/
PROCEDURE Get_Shifted_Period (
        p_period_name                   IN      pa_periods.period_name%TYPE
/*     ,p_plan_period_type              IN      pa_proj_period_profiles.plan_period_type%TYPE */
       ,p_plan_period_type              IN      VARCHAR2
       ,p_number_of_periods             IN      NUMBER
       ,x_shifted_period                OUT     NOCOPY pa_periods.period_name%TYPE --File.Sql.39 bug 4440895
/*     ,x_shifted_period_start_date     OUT     pa_proj_period_profiles.period1_start_date%TYPE
       ,x_shifted_period_end_date       OUT     pa_proj_period_profiles.period1_end_date%TYPE */
       ,x_shifted_period_start_date     OUT     NOCOPY DATE   --File.Sql.39 bug 4440895
       ,x_shifted_period_end_date       OUT     NOCOPY DATE --File.Sql.39 bug 4440895
       ,x_return_status                 OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       ,x_msg_count                     OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
       ,x_msg_data                      OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


FUNCTION Get_Approved_Budget_Ver_Qty (
        p_project_id                    IN NUMBER
       ,p_version_code                  IN VARCHAR2
       ,p_quantity_type                 IN VARCHAR2
       ,p_ci_id                         IN NUMBER DEFAULT NULL) RETURN pa_budget_lines.quantity%TYPE;

PROCEDURE VALIDATE_CURRENCY_ATTRIBUTES
          ( px_project_cost_rate_type        IN OUT  NOCOPY pa_proj_fp_options.project_cost_rate_type%TYPE --File.Sql.39 bug 4440895
           ,px_project_cost_rate_date_typ    IN OUT  NOCOPY pa_proj_fp_options.project_cost_rate_date_type%TYPE --File.Sql.39 bug 4440895
           ,px_project_cost_rate_date        IN OUT  NOCOPY pa_proj_fp_options.project_cost_rate_date%TYPE --File.Sql.39 bug 4440895
           ,px_project_cost_exchange_rate    IN OUT  NOCOPY pa_budget_lines.project_cost_exchange_rate%TYPE  --File.Sql.39 bug 4440895
           ,px_projfunc_cost_rate_type       IN OUT  NOCOPY pa_proj_fp_options.projfunc_cost_rate_type%TYPE   --File.Sql.39 bug 4440895
           ,px_projfunc_cost_rate_date_typ   IN OUT  NOCOPY pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE --File.Sql.39 bug 4440895
           ,px_projfunc_cost_rate_date       IN OUT  NOCOPY pa_proj_fp_options.projfunc_cost_rate_date%TYPE --File.Sql.39 bug 4440895
           ,px_projfunc_cost_exchange_rate   IN OUT  NOCOPY pa_budget_lines.projfunc_cost_exchange_rate%TYPE  --File.Sql.39 bug 4440895
           ,px_project_rev_rate_type         IN OUT  NOCOPY pa_proj_fp_options.project_rev_rate_type%TYPE --File.Sql.39 bug 4440895
           ,px_project_rev_rate_date_typ     IN OUT  NOCOPY pa_proj_fp_options.project_rev_rate_date_type%TYPE --File.Sql.39 bug 4440895
           ,px_project_rev_rate_date         IN OUT  NOCOPY pa_proj_fp_options.project_rev_rate_date%TYPE --File.Sql.39 bug 4440895
           ,px_project_rev_exchange_rate     IN OUT  NOCOPY pa_budget_lines.project_rev_exchange_rate%TYPE  --File.Sql.39 bug 4440895
           ,px_projfunc_rev_rate_type        IN OUT  NOCOPY pa_proj_fp_options.projfunc_rev_rate_type%TYPE   --File.Sql.39 bug 4440895
           ,px_projfunc_rev_rate_date_typ    IN OUT  NOCOPY pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE --File.Sql.39 bug 4440895
           ,px_projfunc_rev_rate_date        IN OUT  NOCOPY pa_proj_fp_options.projfunc_rev_rate_date%TYPE --File.Sql.39 bug 4440895
           ,px_projfunc_rev_exchange_rate    IN OUT  NOCOPY pa_budget_lines.projfunc_rev_exchange_rate%TYPE  --File.Sql.39 bug 4440895
           ,p_project_currency_code          IN      pa_projects_all.project_currency_code%TYPE
           ,p_projfunc_currency_code         IN      pa_projects_all.projfunc_currency_code%TYPE
           ,p_txn_currency_code              IN      pa_projects_all.projfunc_currency_code%TYPE DEFAULT NULL
           ,p_context                        IN      VARCHAR2
           ,p_attrs_to_be_validated          IN      VARCHAR2  -- valid values are COST, REVENUE , BOTH
           ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_msg_data                          OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE VALIDATE_CONV_ATTRIBUTES
          ( px_rate_type         IN OUT  NOCOPY pa_proj_fp_options.projfunc_cost_rate_type%TYPE --File.Sql.39 bug 4440895
           ,px_rate_date_type    IN OUT  NOCOPY pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE --File.Sql.39 bug 4440895
           ,px_rate_date         IN OUT  NOCOPY pa_proj_fp_options.projfunc_cost_rate_date%TYPE --File.Sql.39 bug 4440895
           ,px_rate              IN OUT  NOCOPY pa_budget_lines.project_cost_exchange_rate%TYPE --File.Sql.39 bug 4440895
           ,p_amount_type_code   IN      VARCHAR2
           ,p_currency_type_code IN      VARCHAR2
           ,p_calling_context    IN      VARCHAR2
           ,x_first_error_code      OUT  NOCOPY VARCHAR2   -- Removed validate code and introduce this parameter for WEBADI. --File.Sql.39 bug 4440895
           ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_msg_data              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ) ;

PROCEDURE GET_PLAN_TYPE_OPTS_FOR_VER
        (
            p_plan_version_id       IN   pa_proj_fp_options.fin_plan_version_id%TYPE
           ,x_fin_plan_type_id      OUT  NOCOPY pa_proj_fp_options.fin_plan_type_id%TYPE --File.Sql.39 bug 4440895
           ,x_plan_type_option_id   OUT  NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE --File.Sql.39 bug 4440895
           ,x_version_type          OUT  NOCOPY pa_budget_versions.version_type%TYPE --File.Sql.39 bug 4440895
           ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_msg_data              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        );

PROCEDURE Get_Project_Curr_Attributes
   (  p_project_id                      IN   pa_projects_all.project_id%TYPE
     ,x_multi_currency_billing_flag     OUT  NOCOPY pa_projects_all.multi_currency_billing_flag%TYPE --File.Sql.39 bug 4440895
     ,x_project_currency_code           OUT  NOCOPY pa_projects_all.project_currency_code%TYPE --File.Sql.39 bug 4440895
     ,x_projfunc_currency_code          OUT  NOCOPY pa_projects_all.projfunc_currency_code%TYPE --File.Sql.39 bug 4440895
     ,x_project_cost_rate_type          OUT  NOCOPY pa_projects_all.project_rate_type%TYPE --File.Sql.39 bug 4440895
     ,x_projfunc_cost_rate_type         OUT  NOCOPY pa_projects_all.projfunc_cost_rate_type%TYPE --File.Sql.39 bug 4440895
     ,x_project_bil_rate_type           OUT  NOCOPY pa_projects_all.project_bil_rate_type%TYPE --File.Sql.39 bug 4440895
     ,x_projfunc_bil_rate_type          OUT  NOCOPY pa_projects_all.projfunc_bil_rate_type%TYPE --File.Sql.39 bug 4440895
     ,x_return_status                   OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                       OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                        OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE IsRevVersionCreationAllowed
    ( p_project_id                      IN   pa_projects_all.project_id%TYPE
     ,p_fin_plan_type_id                IN   pa_fin_plan_types_b.fin_plan_type_id%TYPE
     ,x_creation_allowed                OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_return_status                   OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                       OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                        OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE GET_LOOKUP_CODE
          (
                 p_lookup_type                      IN   pa_lookups.lookup_type%TYPE
                ,p_lookup_meaning                   IN   pa_lookups.meaning%TYPE
                ,x_lookup_code                      OUT  NOCOPY pa_lookups.lookup_code%TYPE --File.Sql.39 bug 4440895
                ,x_return_status                    OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                ,x_msg_count                        OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
                ,x_msg_data                         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          );

FUNCTION HAS_PLANNABLE_ELEMENTS
         (p_budget_version_id IN   pa_budget_versions.budget_version_id%TYPE)
RETURN VARCHAR2;

-- This procedure is used to derive the version type given the project id and
-- fin plan type id
PROCEDURE get_version_type
( p_project_id               IN     pa_projects_all.project_id%TYPE
 ,p_fin_plan_type_id         IN     pa_proj_fp_options.fin_plan_type_id%TYPE
 ,px_version_type            IN OUT NOCOPY pa_budget_Versions.version_type%TYPE --File.Sql.39 bug 4440895
 ,x_return_status            OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                 OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );

PROCEDURE get_version_id
( p_project_id               IN   pa_projects_all.project_id%TYPE
 ,p_fin_plan_type_id         IN   pa_proj_fp_options.fin_plan_type_id%TYPE
 ,p_version_type             IN   pa_budget_Versions.version_type%TYPE
 ,p_version_number           IN   pa_budget_Versions.version_number%TYPE
 ,x_budget_version_id        OUT  NOCOPY pa_budget_Versions.budget_version_id%TYPE --File.Sql.39 bug 4440895
 ,x_ci_id                    OUT  NOCOPY pa_budget_Versions.ci_id%TYPE --File.Sql.39 bug 4440895
 ,x_return_status            OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                 OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );


PROCEDURE perform_autobasline_checks
( p_budget_version_id     IN  pa_budget_versions.budget_version_id%TYPE
 ,x_result                OUT NOCOPY VARCHAR2     --File.Sql.39 bug 4440895
 ,x_return_status         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count             OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data              OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE get_version_type_for_bdgt_type
   (  p_budget_type_code      IN   pa_budget_versions.budget_type_code%TYPE
     ,x_version_type          OUT  NOCOPY pa_budget_versions.version_type%TYPE --File.Sql.39 bug 4440895
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE validate_editable_bv
    (p_budget_version_id     IN  pa_budget_versions.budget_version_id%TYPE,
     p_user_id               IN  NUMBER,

     --Bug 3986129: FP.M Web ADI Dev changes, a new parameter added
     p_context               IN  VARCHAR2   DEFAULT 'ATTACHMENTS',
     p_excel_calling_mode    IN  VARCHAR2   DEFAULT NULL,
     x_locked_by_person_id   OUT NOCOPY pa_budget_versions.locked_by_person_id%TYPE, --File.Sql.39 bug 4440895
     x_err_code              OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_return_status         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count             OUT NOCOPY NUMBER,   --File.Sql.39 bug 4440895
     x_msg_data              OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE check_delete_task_ok
     (/* p_task_id               IN   pa_tasks.task_id%TYPE Commenting out NOCOPY for to replace  --File.Sql.39 bug 4440895
     pa_tasks by PA_STRUCT_TASK_WBS_V as part of FP.M, Tracking Bug No - 3354518 */
     p_task_id               IN   pa_struct_task_wbs_v.task_id%TYPE
     ,p_validation_mode       IN   VARCHAR2 DEFAULT 'U'
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE check_reparent_task_ok
     (p_task_id               IN   pa_tasks.task_id%TYPE
     ,p_old_parent_task_id    IN   pa_tasks.task_id%TYPE
     ,p_new_parent_task_id    IN   pa_tasks.task_id%TYPE
     ,p_validation_mode       IN   VARCHAR2 DEFAULT 'U'
     ,x_return_status        OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count            OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data             OUT   NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/* Part of changes for FP.M, Tracking Bug No - 3354518
This function is being called by PA_FP_ELEMENTS_PUB currently to verify,
if PA_FP_ELEMENTS contains a entry for this task. This procedure is now
obsoleted.However noticing that this procedure is re-usable, we change
all references to pa_tasks to pa_struct_task_wbs_v and all references of
pa_fp_elements to pa_resource_assignments */
/* FUNCTION check_task_in_fp_option
    (p_task_id                IN   pa_tasks.task_id%TYPE)
    RETURN VARCHAR2;  Re-writing function declaration below*/
    FUNCTION check_task_in_fp_option
    (p_task_id                IN   pa_struct_task_wbs_v.task_id%TYPE)
    RETURN VARCHAR2;


--Name:        Get_Budgeted_Amount
--Type:                  Function
--
--Description:          This function is used by Capital-Project calling
--                      objects to get the following:
--
--                      1) Project or lowest-level task for a given project
--                      2) Approved Cost budget or FP plan version
--                      3) raw cost or burden cost amount
--
--                      Amount is the project functional amount for the
--                      the current baseline budget/plan version.
--
--
--Called subprograms:    None.
--
--Notes:
--
--History:
--    27-MAY-03 jwhite  - Created
--
-- IN Parameters
--    p_project_id              - Always passed.
--
--    p_task_id                 - Passed as NULL if project-level amounts requested.
--
--    p_fin_plan_type_id        - If passed as NON-null, query FP model.
--
--    p_budget_type_code        - Query pre-FP model if p_fin_plan_type_id is NULL.
--
--    p_amount_type             - Passed as 'R' to return raw cost; 'B' to return burdened cost.


FUNCTION Get_Budgeted_Amount
   (
     p_project_id              IN   pa_projects_all.project_id%TYPE
     , p_task_id               IN   pa_tasks.task_id%TYPE
     , p_fin_plan_type_id      IN   pa_proj_fp_options.fin_plan_type_id%TYPE
     , p_budget_type_code      IN   pa_budget_versions.budget_type_code%TYPE
     , p_amount_type           IN   VARCHAR2
   )
RETURN NUMBER ;

PROCEDURE Check_if_plan_type_editable (
 P_project_id            In              Number
,P_fin_plan_type_id      IN              Number
,P_version_type          IN              VARCHAR2
,X_editable_flag         OUT             NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,X_return_status         OUT             NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,X_msg_count             OUT             NOCOPY NUMBER --File.Sql.39 bug 4440895
,X_msg_data              OUT             NOCOPY VARCHAR2 );                                                                   --File.Sql.39 bug 4440895

PROCEDURE End_date_active_val (
 p_start_date_active     IN              Date
,p_end_date_active       IN              Date
,x_return_status         OUT             NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
,x_msg_count             OUT             NOCOPY NUMBER --File.Sql.39 bug 4440895
,x_msg_data              OUT             NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*=============================================================================
 This api is used to return current original version info for given plan type,
 project id and version type
==============================================================================*/

PROCEDURE Get_Curr_Original_Version_Info(
          p_project_id              IN   pa_projects_all.project_id%TYPE
          ,p_fin_plan_type_id       IN   pa_budget_versions.fin_plan_type_id%TYPE
          ,p_version_type           IN   pa_budget_versions.version_type%TYPE
          ,x_fp_options_id          OUT  NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE      --File.Sql.39 bug 4440895
          ,x_fin_plan_version_id    OUT  NOCOPY pa_proj_fp_options.fin_plan_version_id%TYPE --File.Sql.39 bug 4440895
          ,x_return_status          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count              OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data               OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*=============================================================================
 This api is used to derive actual_amts_thru_period for a version. The api also
 returns first future PA/GL periods if they are available. This api is called
 from plan setting pages to maintain Include unspent amount through period lov.
==============================================================================*/

PROCEDURE GET_ACTUAL_AMTS_THRU_PERIOD(
           p_budget_version_id       IN    pa_budget_versions.budget_version_id%TYPE
          ,x_record_version_number   OUT   NOCOPY pa_budget_versions.record_version_number%TYPE --File.Sql.39 bug 4440895
          ,x_actual_amts_thru_period OUT   NOCOPY pa_budget_versions.actual_amts_thru_period%TYPE --File.Sql.39 bug 4440895
          ,x_first_future_pa_period  OUT   NOCOPY pa_periods_all.period_name%TYPE --File.Sql.39 bug 4440895
          ,x_first_future_gl_period  OUT   NOCOPY pa_periods_all.period_name%TYPE --File.Sql.39 bug 4440895
          ,x_return_status           OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count               OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                OUT   NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/* To determine if a task is a planning element or not */
-- Modified for Bug 3840993 --sagarwal
FUNCTION IS_TASK_A_PLANNING_ELEMENT(
           p_budget_version_id        IN  pa_budget_versions.budget_version_id%TYPE
          ,p_task_id                  IN  pa_tasks.task_id%TYPE)
RETURN VARCHAR2;

/* To determine if a task has resources attached to it as planning element */
FUNCTION IS_RESOURCE_ATTACHED_TO_TASK(
          p_budget_version_id        IN   pa_budget_versions.budget_version_id%TYPE
         ,p_task_id                  IN   pa_resource_assignments.task_id%TYPE)
         --,p_wbs_element_version_id   IN   pa_resource_assignments.wbs_element_version_id%TYPE)
RETURN VARCHAR2;

/*=============================================================================
 This api would be called to check if workplan res list can be updated.
 The api returns 'Y' or 'N' accordingly. If can not be updated without throwing
 any error appropriate erroer message code is returned.

 Bug 3651620 Added a new out parameter to indicate if task assignments
      exist for any of the workplan versions. If resource list can be
      updated, then only if task assignments data exists then a warning
      message would be shown to the user.
 =============================================================================*/
PROCEDURE IS_WP_RL_UPDATEABLE(
           p_project_id                     IN   pa_budget_versions.project_id%TYPE
          ,x_wp_rl_update_allowed_flag      OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_reason_msg_code                OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_return_status                  OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                      OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                       OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


/*=============================================================================
This api checks if any plan type marked for primary forecast cost usage has been
attached to the project and returns id of that plan type if found. Else null
would be returned
==============================================================================*/

PROCEDURE IS_PRI_FCST_COST_PT_ATTACHED(
          p_project_id     IN   pa_projects_all.project_id%TYPE
          ,x_plan_type_id  OUT  NOCOPY pa_proj_fp_options.fin_plan_type_id%TYPE --File.Sql.39 bug 4440895
          ,x_return_status OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count     OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data      OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*=============================================================================
This api checks if any plan type marked for primary forecast revenue usage has
been attached to the project and returns id of that plan type if found. Else null
would be returned
==============================================================================*/

PROCEDURE IS_PRI_FCST_REV_PT_ATTACHED(
          p_project_id     IN   pa_projects_all.project_id%TYPE
          ,x_plan_type_id  OUT  NOCOPY pa_proj_fp_options.fin_plan_type_id%TYPE --File.Sql.39 bug 4440895
          ,x_return_status OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count     OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data      OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


/* Used by Resource foundation team to know the resource lists used in WP */
FUNCTION is_wp_resource_list
         (p_project_id       IN   pa_projects_all.project_id%TYPE
         ,p_resource_list_id IN
pa_resource_lists_all_bg.resource_list_id%TYPE)
RETURN VARCHAR2;

/* Used by Resource foundation team to know the resource lists used in FP */
FUNCTION is_fp_resource_list
         (p_project_id       IN   pa_projects_all.project_id%TYPE
         ,p_resource_list_id IN
pa_resource_lists_all_bg.resource_list_id%TYPE)
RETURN VARCHAR2;

PROCEDURE GET_CURR_WORKING_VERSION_IDS(P_fin_plan_type_id         IN       Pa_fin_plan_types_b.fin_plan_type_id%TYPE       -- Id of the plan types
                                      ,P_project_id               IN       Pa_budget_versions.project_id%TYPE         -- Id of the Project
                                      ,X_cost_budget_version_id   OUT      NOCOPY Pa_budget_versions.budget_version_id%TYPE  -- ID of the cost version associated with the CI --File.Sql.39 bug 4440895
                                      ,X_rev_budget_version_id    OUT      NOCOPY Pa_budget_versions.budget_version_id%TYPE  -- ID of the revenue version associated with the CI --File.Sql.39 bug 4440895
                                      ,X_all_budget_version_id    OUT      NOCOPY Pa_budget_versions.budget_version_id%TYPE  -- ID of the all version associated with the CI --File.Sql.39 bug 4440895
                                      ,x_return_status            OUT      NOCOPY VARCHAR2                                   -- Indicates the exit status of the API --File.Sql.39 bug 4440895
                                      ,x_msg_data                 OUT      NOCOPY VARCHAR2                                   -- Indicates the error occurred --File.Sql.39 bug 4440895
                                      ,X_msg_count                OUT      NOCOPY NUMBER);                                   -- Indicates the number of error messages --File.Sql.39 bug 4440895

/*         GET_SUMMARY_AMOUNTS            */
-- Added New Params for Quantity in Get_Summary_Amounts - Bug 3902176

-- p_version parameter was earlier used to retieve the cost or revenue or all quantity figures.
-- Since cost and revenue quantity figures are now both alreayd being retrieved and are passed
-- in separate out params, p_version parameter is no longer required.
-- Commenting out references of p_version_type_below - Bug 3902176

PROCEDURE GET_SUMMARY_AMOUNTS(p_context                 IN              VARCHAR2
                             ,P_project_id              IN              Pa_projects_all.project_id%TYPE                           --  Id of the project .
                             ,P_ci_id                   IN              Pa_budget_versions.ci_id%TYPE  DEFAULT  NULL              --  Controm item id of the change document
                             ,P_fin_plan_type_id        IN              Pa_fin_plan_types_b.fin_plan_type_id%TYPE  DEFAULT  NULL  --  Name of default staffing owner.
--                             ,p_version_type            IN              pa_budget_versions.version_type%TYPE DEFAULT NULL --Bug 3902176
                             ,X_proj_raw_cost           OUT             NOCOPY Pa_budget_versions.total_project_raw_cost%TYPE            --  Raw Cost in PC --File.Sql.39 bug 4440895
                             ,X_proj_burdened_cost      OUT             NOCOPY Pa_budget_versions.total_project_burdened_cost%TYPE       --  Burdened Cost in PC --File.Sql.39 bug 4440895
                             ,X_proj_revenue            OUT             NOCOPY Pa_budget_versions.total_project_revenue%TYPE             --  Revenue in PC --File.Sql.39 bug 4440895
                             ,X_margin                  OUT             NOCOPY NUMBER                                                    --  MARGIN --File.Sql.39 bug 4440895
                             ,X_margin_percent          OUT             NOCOPY NUMBER                                                    --  MARGIN percent --File.Sql.39 bug 4440895
                             ,X_labor_hrs_cost          OUT             NOCOPY Pa_budget_versions.labor_quantity%TYPE                    --  Labor Hours Cost --File.Sql.39 bug 4440895
                             ,X_equipment_hrs_cost      OUT             NOCOPY Pa_budget_versions.equipment_quantity%TYPE                --  Equipment Hours Cost --File.Sql.39 bug 4440895
                             ,X_labor_hrs_rev           OUT             NOCOPY Pa_budget_versions.labor_quantity%TYPE                    --  Labor Hours Revenue --File.Sql.39 bug 4440895
                             ,X_equipment_hrs_rev       OUT             NOCOPY Pa_budget_versions.equipment_quantity%TYPE                --  Equipment Hours Revenue --File.Sql.39 bug 4440895
                             ,X_cost_budget_version_id  OUT             NOCOPY Pa_budget_versions.budget_version_id%TYPE                 --  Cost Budget Verison Id --File.Sql.39 bug 4440895
                             ,X_rev_budget_version_id   OUT             NOCOPY Pa_budget_versions.budget_version_id%TYPE                 --  Revenue Budget Verison Id --File.Sql.39 bug 4440895
                             ,X_all_budget_version_id   OUT             NOCOPY Pa_budget_versions.budget_version_id%TYPE                 --  All Budget Verison Id --File.Sql.39 bug 4440895
                             ,X_margin_derived_from_code OUT             NOCOPY pa_proj_fp_options.margin_derived_from_code%TYPE          --  margin_derived_from_code of cost version - Bug 3734840 --File.Sql.39 bug 4440895
                             ,x_return_status           OUT             NOCOPY VARCHAR2                                                  --  Indicates the exit status of the API --File.Sql.39 bug 4440895
                             ,x_msg_data                OUT             NOCOPY VARCHAR2                                                  --  Indicates the error occurred --File.Sql.39 bug 4440895
                             ,X_msg_count               OUT             NOCOPY NUMBER);                                                  --  Indicates the number of error messages --File.Sql.39 bug 4440895


/*         GET_PROJ_IMPACT_AMOUNTS            */
-- Added New Params for Quantity in Get_Summary_Amounts - Bug 3902176

-- p_version parameter was earlier used to retieve the cost or revenue or all quantity figures.
-- Since cost and revenue quantity figures are now both alreayd being retrieved and are passed
-- in separate out params, p_version parameter is no longer required.
-- Commenting out references of p_version_type_below - Bug 3902176

PROCEDURE GET_PROJ_IMPACT_AMOUNTS(p_cost_budget_version_id  IN   Pa_budget_versions.budget_version_id%TYPE              --  ID of the cost version associated with the CI
                                 ,p_rev_budget_version_id   IN   Pa_budget_versions.budget_version_id%TYPE              --  ID of the revenue version associated with the CI
                                 ,p_all_budget_version_id   IN   Pa_budget_versions.budget_version_id%TYPE              --  ID of the all version associated with the CI
--                                 ,p_version_type            IN   pa_budget_versions.version_type%TYPE DEFAULT NULL --Bug 3902176
                                 ,X_proj_raw_cost           OUT  NOCOPY Pa_budget_versions.total_project_raw_cost%TYPE         --  Raw Cost in PC --File.Sql.39 bug 4440895
                                 ,X_proj_burdened_cost      OUT  NOCOPY Pa_budget_versions.total_project_burdened_cost%TYPE    --  Burdened Cost in PC --File.Sql.39 bug 4440895
                                 ,X_proj_revenue            OUT  NOCOPY Pa_budget_versions.total_project_revenue%TYPE          --  Revenue in PC --File.Sql.39 bug 4440895
                                 ,X_labor_hrs_cost          OUT  NOCOPY Pa_budget_versions.labor_quantity%TYPE                 --  Labor Hours Cost --File.Sql.39 bug 4440895
                                 ,X_equipment_hrs_cost      OUT  NOCOPY Pa_budget_versions.equipment_quantity%TYPE             --  Equipment Hours Cost --File.Sql.39 bug 4440895
                                 ,X_labor_hrs_rev           OUT  NOCOPY Pa_budget_versions.labor_quantity%TYPE                 --  Labor Hours Revenue --File.Sql.39 bug 4440895
                                 ,X_equipment_hrs_rev       OUT  NOCOPY Pa_budget_versions.equipment_quantity%TYPE             --  Equipment Hours Revenue --File.Sql.39 bug 4440895
                                 ,X_margin                  OUT  NOCOPY Number                                                 --  Margin --File.Sql.39 bug 4440895
                                 ,X_margin_percent          OUT  NOCOPY Number                                                 --  Margin percent --File.Sql.39 bug 4440895
                                 ,X_margin_derived_from_code OUT NOCOPY pa_proj_fp_options.margin_derived_from_code%TYPE --  margin_derived_from_code - Bug 3734840 --File.Sql.39 bug 4440895
                                 ,x_return_status           OUT  NOCOPY VARCHAR2                                               --  Indicates the exit status of the API --File.Sql.39 bug 4440895
                                 ,x_msg_data                OUT  NOCOPY VARCHAR2                                               --  Indicates the error occurred --File.Sql.39 bug 4440895
                                 ,X_msg_count               OUT  NOCOPY NUMBER);                                               --  Indicates the number of error messages --File.Sql.39 bug 4440895


/* Function returns 'Y' if budget version has budget lines with rejection code. */
FUNCTION does_bv_have_rej_lines(p_budget_version_id IN pa_budget_versions.budget_version_id%TYPE)
RETURN VARCHAR2;

--------------------------------------------------------------------------------
-- This API is called during deleting a  Rate Sch to check if the Rate
-- Schedule is being reference by any Plan Type or not.
-- In case if it is referenced then the 'N' is returned , or else 'Y' is returned
--------------------------------------------------------------------------------
FUNCTION check_delete_sch_ok(
         p_bill_rate_sch_id      IN   pa_std_bill_rate_schedules_all.bill_rate_sch_id%TYPE)
RETURN VARCHAR2;

--------------------------------------------------------------------------------
-- This API is called during deleting a Burden Rate Sch to check if the Burden Rate
-- Schedule is being reference by any Plan Type or not.
-- In case if it is referenced then the 'N' is returned , or else 'Y' is returned
--------------------------------------------------------------------------------
FUNCTION check_delete_burd_sch_ok(
         p_ind_rate_sch_id      IN   pa_ind_rate_schedules_all_bg.ind_rate_sch_id%TYPE)
RETURN VARCHAR2;

/* -------------------------------------------------------------------------------------------
 * Function to check for the validity of the event of unchecking of 'Plan in Multi Currency'
 * check box in the 'Edit Planning Options' screen. This api is called just before committing
 * the changes done in the page and is called for both workplan and budgeting and forecasting
 * context and this is indicated by the value of input parameter p_context, for which the
 * valid values are 'WORKPLAN' and 'FINPLAN'. If the context is 'WORKPLAN' the input parameter
 * p_budget_version_id would be null. The api returns 'Y' if the event is valid and allowed
 * and returns 'N' otherwise.
 *--------------------------------------------------------------------------------------------*/
 FUNCTION Validate_Uncheck_MC_Flag (
              p_project_id             IN         pa_projects_all.project_id%TYPE,
              p_context                IN         VARCHAR2,
              p_budget_version_id      IN         pa_budget_versions.budget_version_id%TYPE)
 RETURN  VARCHAR2;

/*=============================================================================
 This api is called to check if a txn currency can be deleted for an fp option.
 For workplan case,
    A txn currency can not be deleted if
      1. the currency is project currency or
      2. the currency is project functional currency or
      3. amounts exist against the currency in any of the workplan versions

 For Budgets and Forecasting case,
    A txn currency can not be deleted if
      1. the currency is project currency or
      2. the currency is project functional currency or
      3. option is a version and amounts exist against the currency
==============================================================================*/

FUNCTION Check_delete_txn_cur_ok(
          p_project_id            IN   pa_projects_all.project_id%TYPE
          ,p_context              IN   VARCHAR2 -- FINPLAN or WORKPLAN
          ,p_fin_plan_version_id  IN   pa_budget_versions.budget_version_id%TYPE
          ,p_txn_currency_code    IN   fnd_currencies.currency_code%TYPE
) RETURN VARCHAR2;

/*=============================================================================
  This api is called to check if amounts exist for any of the workplan versions
  of the project in budgets data model.
==============================================================================*/

FUNCTION check_if_amounts_exist_for_wp(
           p_project_id           IN   pa_projects_all.project_id%TYPE
) RETURN VARCHAR2;

/*=============================================================================
  This api is called to check if task assignments exist for any of the workplan
  versions of the given project
==============================================================================*/

FUNCTION check_if_task_asgmts_exist(
           p_project_id           IN   pa_projects_all.project_id%TYPE
) RETURN VARCHAR2;

/*=============================================================================
  This api is called to check if amounts exist for any of the budget versions
  of the project - plan type combination. This is used as of now to restrict
  RBS change at plan type level.
==============================================================================*/

FUNCTION check_if_amounts_exist_for_fp(
           p_project_id           IN   pa_projects_all.project_id%TYPE
           ,p_fin_plan_type_id    IN   pa_fin_plan_types_b.fin_plan_type_id %TYPE
) RETURN VARCHAR2;

/*===================================================================================
 This api is used to validate the plan processing code if it passed, or to return
 the same for the budget version id that is passed in budget context or for the
 ci_id passed for the CI version context and throw an error in case they are not valid
=====================================================================================*/




PROCEDURE return_and_vldt_plan_prc_code
(
       p_add_msg_to_stack             IN       VARCHAR2                                         DEFAULT 'Y'
      ,p_calling_context              IN       VARCHAR2                                         DEFAULT 'BUDGET'
      ,p_budget_version_id            IN       pa_budget_versions.budget_version_id%TYPE        DEFAULT NULL
      ,p_source_ci_id_tbl             IN       SYSTEM.pa_num_tbl_type                           DEFAULT SYSTEM.pa_num_tbl_type()
      ,p_target_ci_id                 IN       pa_control_items.ci_id%TYPE                      DEFAULT NULL
      ,p_plan_processing_code         IN       pa_budget_versions.plan_processing_code%TYPE     DEFAULT NULL
      ,x_final_plan_prc_code          OUT      NOCOPY pa_budget_versions.plan_processing_code%TYPE --File.Sql.39 bug 4440895
      ,x_targ_request_id              OUT      NOCOPY pa_budget_versions.request_id%TYPE --File.Sql.39 bug 4440895
      ,x_return_status                OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_msg_count                    OUT      NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,x_msg_data                     OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

FUNCTION Is_source_for_gen_options
          (p_project_id                   IN   pa_projects_all.project_id%TYPE
          ,p_fin_plan_type_id             IN  pa_fin_plan_types_b.fin_plan_type_id%TYPE
          ,p_preference_code              IN pa_proj_fp_options.fin_plan_preference_code%TYPE
          ) RETURN VARCHAR2;


 /* bug 4494740: the following global variable added so that they
  * can be used in view pa_fp_webadi_periodic_v
  */

   g_fp_wa_struct_ver_id             pa_proj_element_versions.parent_structure_version_id%TYPE;
   g_fp_wa_struct_status_flag        VARCHAR2(1);
   g_fp_wa_time_phased_code          pa_proj_fp_options.cost_time_phased_code%TYPE;

  TYPE fp_wa_task_pc_compl_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  g_fp_wa_task_pc_compl_tbl      fp_wa_task_pc_compl_tab;

  /* bug 4494740: The following function is included here which would return
    the percent complete for the financial structure version when the financial
    structure_version_id and the status_flags are passed as input. This function
    is introduced as part of performance improvement for FP.M excel download
    in the view pa_fp_webadi_periodic_v.
  */

  FUNCTION get_physical_pc_complete
        ( p_project_id                  IN           pa_projects_all.project_id%TYPE,
          p_proj_element_id             IN           pa_proj_element_versions.proj_element_id%TYPE)

  RETURN NUMBER;

  FUNCTION set_webadi_download_var
         (p_structure_version_id        IN           pa_proj_element_versions.parent_structure_version_id%TYPE,
          p_structure_status_flag       IN           VARCHAR2)

  RETURN VARCHAR2;

  PRAGMA RESTRICT_REFERENCES (set_webadi_download_var, RNDS,WNDS, TRUST);

  FUNCTION get_fp_wa_struct_ver_id RETURN NUMBER;

  PRAGMA RESTRICT_REFERENCES (get_fp_wa_struct_ver_id, RNDS,WNDS, TRUST);


  /* This procedure is called from FPWebadiAMImpl.java to get the structure version id
   * and the structure version status flag to be used as URL parameter for BNE URL
   */
  PROCEDURE return_struct_ver_info
        (p_budget_version_id    IN             pa_budget_versions.budget_version_id%TYPE,
         x_struct_version_id    OUT   NOCOPY   pa_proj_element_versions.parent_structure_version_id%TYPE,
         x_struct_status_flag   OUT   NOCOPY   VARCHAR2,
         x_return_status        OUT   NOCOPY   VARCHAR2,
         x_msg_count            OUT   NOCOPY   NUMBER,
         x_msg_data             OUT   NOCOPY   VARCHAR2);

  FUNCTION get_cached_time_phased_code (bv_id     IN     pa_budget_versions.budget_version_id%TYPE)
  RETURN VARCHAR2;
  -- bug 4494740: ends

  /*=============================================================================
 This api is used as a wrapper API to pa_budget_pub.create_draft_budget
==============================================================================*/

PROCEDURE create_draft_budget_wrp(
  p_api_version_number            IN  NUMBER
 ,p_commit                        IN  VARCHAR2        := FND_API.G_FALSE
 ,p_init_msg_list                 IN  VARCHAR2        := FND_API.G_FALSE
 ,p_msg_count                     OUT NOCOPY NUMBER
 ,p_msg_data                      OUT NOCOPY VARCHAR2
 ,p_return_status                 OUT NOCOPY VARCHAR2
 ,p_pm_product_code               IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_budget_reference           IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
, p_budget_version_name           IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id                 IN  NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_project_reference          IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_type_code              IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_change_reason_code            IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_description                   IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_entry_method_code             IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_list_name            IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_list_id              IN  NUMBER          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_attribute_category            IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9                    IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10                   IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11                   IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12                   IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13                   IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14                   IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15                   IN  VARCHAR2        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_lines_in               IN  PA_BUDGET_PUB.budget_line_in_tbl_type
 ,p_budget_lines_out              OUT NOCOPY PA_BUDGET_PUB.budget_line_out_tbl_type

 /*Parameters due fin plan model */
 ,p_fin_plan_type_id              IN   pa_fin_plan_types_b.fin_plan_type_id%TYPE          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_fin_plan_type_name            IN   pa_fin_plan_types_vl.name%TYPE                     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_version_type                  IN   pa_budget_versions.version_type%TYPE               := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_fin_plan_level_code           IN   pa_proj_fp_options.cost_fin_plan_level_code%TYPE   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_time_phased_code              IN   pa_proj_fp_options.cost_time_phased_code%TYPE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_plan_in_multi_curr_flag       IN   pa_proj_fp_options.plan_in_multi_curr_flag%TYPE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_type       IN   pa_proj_fp_options.projfunc_cost_rate_type%TYPE    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_date_typ   IN   pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_cost_rate_date       IN   pa_proj_fp_options.projfunc_cost_rate_date%TYPE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_projfunc_rev_rate_type        IN   pa_proj_fp_options.projfunc_rev_rate_type%TYPE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_rev_rate_date_typ    IN   pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_projfunc_rev_rate_date        IN   pa_proj_fp_options.projfunc_rev_rate_date%TYPE       := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_cost_rate_type        IN   pa_proj_fp_options.project_cost_rate_type%TYPE      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_cost_rate_date_typ    IN   pa_proj_fp_options.project_cost_rate_date_type%TYPE   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_cost_rate_date        IN   pa_proj_fp_options.project_cost_rate_date%TYPE  := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_project_rev_rate_type         IN   pa_proj_fp_options.project_rev_rate_type%TYPE   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_rev_rate_date_typ     IN   pa_proj_fp_options.project_rev_rate_date_type%TYPE := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_project_rev_rate_date         IN   pa_proj_fp_options.project_rev_rate_date%TYPE   := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_raw_cost_flag                 IN   VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_burdened_cost_flag            IN   VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_revenue_flag                  IN   VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_cost_qty_flag                 IN   VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_revenue_qty_flag              IN   VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,P_all_qty_flag                  IN   VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_create_new_curr_working_flag  IN   VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_replace_current_working_flag  IN   VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_using_resource_lists_flag	  IN   VARCHAR2 := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 );

/*
  API Name          : Get_NP_RA_Description
  API Description   : Returns the description for the Non Periodic Resource Assignment
  API Created By    : kchaitan
  API Creation Date : 07-MAY-2007
*/

FUNCTION Get_NP_RA_Description
               (p_resource_assignment_id IN pa_resource_assignments.resource_assignment_id%TYPE Default Null,
                p_txn_currency_code      IN pa_budget_lines.txn_currency_code%TYPE Default Null
     ) RETURN VARCHAR2;

/*
  API Name          : Get_Change_Reason
  API Description   : Returns the Change Reason Meaning for the Non Periodic and Periodic Resource Assignment
  API Created By    : kchaitan
  API Creation Date : 07-MAY-2007
*/

FUNCTION Get_Change_Reason
               (p_resource_assignment_id IN pa_resource_assignments.resource_assignment_id%TYPE Default Null,
                p_txn_currency_code      IN pa_budget_lines.txn_currency_code%TYPE Default Null,
                p_time_phased_code       IN varchar2
     ) RETURN VARCHAR2;

   -- gboomina added for bug 8318932 - start
   /* B&F -This function is used to get the
   copy_etc_from_plan_flag in the generation options in case of cost forecast*/
   FUNCTION get_copy_etc_from_plan_flag
       (p_project_id           IN     pa_proj_fp_options.project_id%TYPE,
            p_fin_plan_type_id     IN     pa_proj_fp_options.fin_plan_type_id%TYPE,
            p_fin_plan_option_code IN     pa_proj_fp_options.fin_plan_option_level_code%TYPE,
            p_budget_version_id    IN     pa_budget_versions.budget_version_id%TYPE)
   RETURN pa_proj_fp_options.copy_etc_from_plan_flag%type;
   -- gboomina added for bug 8318932 - end

END pa_fin_plan_utils;


/
