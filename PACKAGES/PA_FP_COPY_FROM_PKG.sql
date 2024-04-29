--------------------------------------------------------
--  DDL for Package PA_FP_COPY_FROM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_COPY_FROM_PKG" AUTHID CURRENT_USER AS
/* $Header: PAFPCPFS.pls 120.4 2005/09/08 00:55:42 prachand noship $ */

Invalid_Arg_Exc  EXCEPTION ;

/* PL/SQL table type declaration */

TYPE l_res_assignment_tbl_typ IS TABLE OF
        pa_resource_assignments.RESOURCE_ASSIGNMENT_ID%TYPE INDEX BY BINARY_INTEGER;

TYPE l_tot_labor_hrs_tbl_typ IS TABLE OF
        pa_txn_accum.TOT_LABOR_HOURS%TYPE INDEX BY BINARY_INTEGER;

TYPE l_tot_raw_cost_tbl_typ IS TABLE OF
        pa_txn_accum.TOT_RAW_COST%TYPE INDEX BY BINARY_INTEGER;

TYPE l_tot_burdened_cost_tbl_typ IS TABLE OF
        pa_txn_accum.TOT_BURDENED_COST%TYPE INDEX BY BINARY_INTEGER;

TYPE l_tot_revenue_tbl_typ IS TABLE OF
        pa_txn_accum.TOT_REVENUE%TYPE INDEX BY BINARY_INTEGER;

TYPE l_period_name_tbl_typ  IS TABLE OF
        pa_periods.PERIOD_NAME%TYPE INDEX BY BINARY_INTEGER;

TYPE l_start_date_tbl_typ  IS TABLE OF DATE INDEX BY BINARY_INTEGER;

TYPE l_end_date_tbl_typ IS TABLE OF DATE INDEX BY BINARY_INTEGER;

TYPE proj_fp_options_id_tbl_typ IS TABLE OF
     pa_proj_fp_options.proj_fp_options_id%TYPE INDEX BY BINARY_INTEGER;

     /* PL/SQL table type declaration */

 TYPE FP_OPTIONS_COLS IS RECORD (
         proj_fp_options_id                PA_PROJ_FP_OPTIONS.proj_fp_options_id%type
        ,project_id                        PA_PROJ_FP_OPTIONS.project_id%type
        ,fin_plan_type_id                  PA_PROJ_FP_OPTIONS.fin_plan_type_id%type
        ,version_type                      VARCHAR2(30)
        ,planning_level                    PA_PROJ_FP_OPTIONS.cost_fin_plan_level_code%type
        ,resource_list_id                  PA_PROJ_FP_OPTIONS.cost_resource_list_id%type
        ,time_phased_code                  PA_PROJ_FP_OPTIONS.cost_time_phased_code%type
        ,amount_set_id                     PA_PROJ_FP_OPTIONS.cost_amount_set_id%type
        ,projfunc_cost_rate_type           PA_PROJ_FP_OPTIONS.projfunc_cost_rate_type%type
        ,projfunc_cost_rate_date_type      PA_PROJ_FP_OPTIONS.projfunc_cost_rate_date_type%type
        ,projfunc_cost_rate_date           PA_PROJ_FP_OPTIONS.projfunc_cost_rate_date%type
        ,projfunc_rev_rate_type            PA_PROJ_FP_OPTIONS.projfunc_rev_rate_type%type
        ,projfunc_rev_rate_date_type       PA_PROJ_FP_OPTIONS.projfunc_rev_rate_date_type%type
        ,projfunc_rev_rate_date            PA_PROJ_FP_OPTIONS.projfunc_rev_rate_date%type
        ,project_cost_rate_type            PA_PROJ_FP_OPTIONS.project_cost_rate_type%type
        ,project_cost_rate_date_type       PA_PROJ_FP_OPTIONS.project_cost_rate_date_type%type
        ,project_cost_rate_date            PA_PROJ_FP_OPTIONS.project_cost_rate_date%type
        ,project_rev_rate_type             PA_PROJ_FP_OPTIONS.project_rev_rate_type%type
        ,project_rev_rate_date_type        PA_PROJ_FP_OPTIONS.project_rev_rate_date_type%type
        ,project_rev_rate_date             PA_PROJ_FP_OPTIONS.project_rev_rate_date%type
        ,raw_cost_flag                     PA_FIN_PLAN_AMOUNT_SETS.raw_cost_flag%type
        ,burdened_cost_flag                PA_FIN_PLAN_AMOUNT_SETS.burdened_cost_flag%type
        ,revenue_flag                      PA_FIN_PLAN_AMOUNT_SETS.revenue_flag%type
        ,quantity_flag                     PA_FIN_PLAN_AMOUNT_SETS.revenue_qty_flag%type
        ,projfunc_currency_code            PA_PROJECTS_ALL.projfunc_currency_code%type
        ,project_currency_code             PA_PROJECTS_ALL.project_currency_code%type
                                );

PROCEDURE copy_plan(
           p_source_plan_version_id    IN     NUMBER
          ,p_target_plan_version_id    IN     NUMBER
          ,p_adj_percentage            IN     NUMBER
          ,x_return_status             OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                 OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                  OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
--Bug 4290043.Included parameter to indicate whether to copy actual info or not.
PROCEDURE Copy_Budget_Version(
       p_source_project_id          IN     NUMBER
       ,p_target_project_id         IN     NUMBER
       ,p_source_version_id         IN     NUMBER
       ,p_copy_mode                 IN     VARCHAR2
       ,p_adj_percentage            IN     NUMBER
       ,p_calling_module            IN     VARCHAR2
       ,p_shift_days                IN     NUMBER DEFAULT NULL
       ,p_copy_actuals_flag         IN     VARCHAR2 DEFAULT 'N'
       ,px_target_version_id        IN OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       ,p_struct_elem_version_id    IN     pa_budget_versions.budget_version_id%TYPE DEFAULT NULL--Bug 3354518
       ,x_return_status                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       ,x_msg_count                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
       ,x_msg_data                     OUT NOCOPY VARCHAR2 );           --File.Sql.39 bug 4440895


--Added parameter p_rbs_map_diff_flag for Bug 3974569. This parameter can be passed as Y if the RBS mapping of
--the target resource assignments is different from that of the source resource assignments.If this is passed as Y then
---->1.copy resource assignments will look at pa_rbs_plans_out_tmp table for rbs_element_id and txn_accum_header_id
---->of target resource assignments and it assumes that source_id in pa_rbs_plans_out_tmp corresponds to the
----> resource_assignment_id in the source budget version.
PROCEDURE copy_resource_assignments(
          p_source_plan_version_id    IN     NUMBER
          ,p_target_plan_version_id   IN     NUMBER
          ,p_adj_percentage           IN     NUMBER
          ,p_rbs_map_diff_flag        IN     VARCHAR2 DEFAULT 'N'
          ,p_calling_context          IN     VARCHAR2 DEFAULT NULL --Bug 4065314
          ,x_return_status            OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                 OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*===================================================================
  This api is used to copy budget lines from one plan version to
  another under the same project
===================================================================*/
--Bug 4290043. Introduced the paramters p_copy_actuals_flag and p_derv_rates_missing_amts_flag.
--These will be passed from copy_version API. p_copy_actuals_flag indicates whether to copy the
--actuals from the source version or not. p_derv_rates_missing_amts_flag indicates whether the
--target version contains missing amounts rates which should be derived after copy

PROCEDURE Copy_Budget_Lines(
           p_source_plan_version_id         IN   NUMBER
           ,p_target_plan_version_id        IN   NUMBER
           ,p_adj_percentage                IN   NUMBER
           ,p_copy_actuals_flag             IN   VARCHAR2   DEFAULT 'N'
           ,p_derv_rates_missing_amts_flag  IN   VARCHAR2   DEFAULT 'N'
           ,x_return_status                 OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count                     OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_msg_data                      OUT  NOCOPY VARCHAR2);  --File.Sql.39 bug 4440895

PROCEDURE Copy_Periods_Denorm(
           p_source_plan_version_id   IN    NUMBER
           ,p_target_plan_version_id  IN    NUMBER
           ,p_calling_module          IN    VARCHAR2
           ,x_return_status           OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count               OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_msg_data                OUT   NOCOPY VARCHAR2);  --File.Sql.39 bug 4440895


PROCEDURE Copy_Finplans_From_Project(
          p_source_project_id           IN   NUMBER
          ,p_target_project_id          IN   NUMBER
          ,p_shift_days                 IN   NUMBER
          ,p_copy_version_and_elements  IN   VARCHAR2 DEFAULT 'Y' /* Bug# 2981655 */
          ,p_agreement_amount           IN   NUMBER   -- Added for bug 2986930
          ,x_return_status              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                  OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                   OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Get_Fp_Options_To_Be_Copied(
           p_source_project_id    IN    NUMBER
           ,p_copy_versions       IN    VARCHAR2 DEFAULT 'Y' /* Bug 2981655 */
           ,x_fp_options_ids_tbl  OUT   NOCOPY PROJ_FP_OPTIONS_ID_TBL_TYP
           ,x_return_status       OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count           OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_msg_data            OUT   NOCOPY VARCHAR2) ;  --File.Sql.39 bug 4440895

PROCEDURE Copy_Budgets_From_Project(
          p_from_project_id         IN      NUMBER
          ,p_to_project_id          IN      NUMBER
          ,p_delta                  IN      NUMBER
          ,p_orig_template_flag     IN      VARCHAR2
          ,p_agreement_amount       IN      NUMBER   -- Added for bug 2986930
          ,p_baseline_funding_flag  IN      VARCHAR2  -- Added for bug 2986930
          ,x_err_code               OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_err_stage              OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_err_stack              OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*===================================================================
   Copy_Budget_lines has been overloaded to copy budget lines from one
   budget/finplan to another version during copy project
 ===================================================================*/

PROCEDURE Copy_Budget_Lines(
          p_source_project_id         IN  NUMBER
          ,p_target_project_id        IN  NUMBER
          ,p_source_plan_version_id   IN  NUMBER
          ,p_target_plan_version_id   IN  NUMBER
          ,p_shift_days               IN  NUMBER
          ,x_return_status            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                 OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*=======================================================================
 The api copies current period profiles from the source project to target
 project.
========================================================================*/

PROCEDURE Copy_Current_Period_Profiles
   (  p_target_project_id     IN   pa_projects.project_id%TYPE
     ,p_source_project_id     IN   pa_projects.project_id%TYPE
     ,p_shift_days            IN   NUMBER
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*===================================================================
  The api shifts the period profile during copy_project.
 ===================================================================*/

PROCEDURE Get_Create_Shifted_PD_Profile
   (  p_target_project_id               IN      pa_projects.project_id%TYPE
     ,p_source_period_profile_id        IN      pa_proj_period_profiles.period_profile_id%TYPE
     ,p_shift_days                      IN      NUMBER
     ,x_target_period_profile_id        OUT     NOCOPY pa_proj_period_profiles.period_profile_id%TYPE --File.Sql.39 bug 4440895
     ,x_return_status                   OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                       OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                        OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*============================================================================================================
  This procedure should be called to copy a workplan version. Copies budget versions, resource assignments
  and budget lines as required for the workplan version. This is added for FP M

  bug 3847386  Raja   24-Sep-2004  Added a new parameter p_copy_act_from_str_ids_tbl
                                   The table would contain from which version actuals
                                   should be copied for the target versions if they need
                                   to be copied
============================================================================================================*/

PROCEDURE copy_wp_budget_versions
(
       p_source_project_id            IN       pa_proj_element_versions.project_id%TYPE
      ,p_target_project_id            IN       pa_proj_element_versions.element_version_id%TYPE
      ,p_src_sv_ids_tbl               IN       SYSTEM.pa_num_tbl_type
      ,p_target_sv_ids_tbl            IN       SYSTEM.pa_num_tbl_type
      ,p_copy_act_from_str_ids_tbl    IN       SYSTEM.pa_num_tbl_type DEFAULT null -- bug 3847386
      ,p_copy_people_flag             IN       VARCHAR2                        DEFAULT 'Y'
      ,p_copy_equip_flag              IN       VARCHAR2                        DEFAULT 'Y'
      ,p_copy_mat_item_flag           IN       VARCHAR2                        DEFAULT 'Y'
      ,p_copy_fin_elem_flag           IN       VARCHAR2                        DEFAULT 'Y'
      ,p_copy_mode                    IN       VARCHAR2                        DEFAULT 'P' -- bug 4277801
      ,x_return_status                OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_msg_count                    OUT      NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,x_msg_data                     OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

/*====================================================================================
   Bug 3354518 - FP M changes - This is an overloaded API. This API will be called
   from pa_fp_planning_transaction_pub.copy_planning_transactions.This API will be used
   to populate the global temporary table PA_FP_RA_MAP_TEMP which will be used for
   the creation of target resource assignment records.
   New columns in pa_fp_ra_map_tmp that will be used for FP M are given below
   planning_start_Date->planning_start_Date for target resource assignment id
   planning_end_Date->planning_end_Date for target resource assignment id
   schedule_start_Date -> schedule_start_date for target resource assignment id .. For TA specifically..
   schedule_end_Date   -> schedule_end_date for target resource assignment id .. For TA specifically..
   system_reference1->source element version id
   system_reference2->target element version id
   system_reference3->project assignment id for the target resoruce assignment id

   p_src_ra_id_tbl -> The tbl containing the source ra ids which should be copied into the target
   p_src_elem_ver_id_tbl->source element version ids which should be copied into the target
   p_targ_elem_ver_id_tbl->target element version ids corresponding to the source element version ids
   p_targ_proj_assmt_id_tbl->target project assignment ids corresponding to the source resource assignment ids

   Bug 3615617 - FP M IB2 changes - Raja
      For workplan context target rlm id would be passed for each source resource assignment
      p_targ_rlm_id_tbl -> target resource list member ids corresponding to the source resource assignment ids
=====================================================================================*/
PROCEDURE create_res_task_maps(
          p_context                  IN      VARCHAR2  --Can be WORKPLAN, BUDGET
         ,p_src_ra_id_tbl            IN      SYSTEM.PA_NUM_TBL_TYPE
         ,p_src_elem_ver_id_tbl      IN      SYSTEM.PA_NUM_TBL_TYPE
         ,p_targ_elem_ver_id_tbl     IN      SYSTEM.PA_NUM_TBL_TYPE
         ,p_targ_proj_assmt_id_tbl   IN      SYSTEM.PA_NUM_TBL_TYPE
         ,p_targ_rlm_id_tbl          IN      SYSTEM.PA_NUM_TBL_TYPE -- Bug 3615617
         ,p_planning_start_date_tbl  IN      SYSTEM.PA_DATE_TBL_TYPE
         ,p_planning_end_date_tbl    IN      SYSTEM.PA_DATE_TBL_TYPE
         ,p_schedule_start_date_tbl  IN      SYSTEM.PA_DATE_TBL_TYPE
         ,p_schedule_end_date_tbl    IN      SYSTEM.PA_DATE_TBL_TYPE
         ,x_return_status            OUT     NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
         ,x_msg_count                OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data                 OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Acquire_Locks_For_Copy_Actual(
          p_plan_version_id  IN     pa_proj_fp_options.fin_plan_version_id%TYPE
          ,x_return_status   OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count       OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data        OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*===================================================================
3156057: This api is used to copy budget lines from mc enabled plan version to
               approved revenue budget versions
===================================================================*/

--Bug 4290043. Added p_derv_rates_missing_amts_flag to indicate whether the missing amounts in the target version
--should be derived or not after copy

PROCEDURE Copy_Budget_Lines_Appr_Rev(
           p_source_plan_version_id         IN   NUMBER
           ,p_target_plan_version_id        IN   NUMBER
           ,p_adj_percentage                IN   NUMBER
           ,p_derv_rates_missing_amts_flag  IN   VARCHAR2
           ,x_return_status                 OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count                     OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_msg_data                      OUT  NOCOPY VARCHAR2);  --File.Sql.39 bug 4440895

/*=============================================================================
 Bug 3619687: PJ.M:B5:BF:DEV:TRACKING BUG FOR PLAN SETTINGS CHANGE REQUEST
 When a new workplan structure version is created from a published version, this
 api is called to synchronise all the additional workplan settings related data.
 This api is called from copy_wp_budget_versions api at the end of copying all
 the budgets related data from source published version.
 Synchronisation involves:
  1) pa_fp_txn_currencies
  2) rate schedules, generation options and plan settings data
     (pa_proj_fp_options)

 Stating some of the business rules for clarity:
      i) If there is a published version, time phasing can not be changed
     ii) Planning resource list can change only if existing resource list is
         'None'. To handle this case, we would re-map the resource assignments
         data. Please note that in this case, only 'PEOPLE' resource class assignments
         would be present.
    iii) RBS can not be different as RBS change is pushed to
==============================================================================*/

PROCEDURE Update_Plan_Setup_For_WP_Copy(
           p_project_id           IN   pa_projects_all.project_id%TYPE
          ,p_wp_version_id        IN   pa_budget_versions.fin_plan_type_id%TYPE
          ,x_return_status        OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count            OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data             OUT  NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

END pa_fp_copy_from_pkg;

 

/
