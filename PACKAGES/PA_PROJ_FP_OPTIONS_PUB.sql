--------------------------------------------------------
--  DDL for Package PA_PROJ_FP_OPTIONS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJ_FP_OPTIONS_PUB" AUTHID CURRENT_USER as
/* $Header: PAFPOPPS.pls 120.3.12010000.2 2009/05/25 14:56:58 gboomina ship $ */

/* Record for Project FP Options

 This record will be used to populate the following columns of Project Fin Planning Options
 as these columns are most frequently used as input or output parameters to many of the APIs. */

Invalid_Arg_Exc EXCEPTION;

    -- Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------

TYPE FP_COLS IS RECORD (
               Fin_Plan_Start_Date                   PA_PROJ_FP_OPTIONS.FIN_PLAN_START_DATE%TYPE
              ,Fin_Plan_End_Date                     PA_PROJ_FP_OPTIONS.FIN_PLAN_END_DATE%TYPE
              ,Cost_Amount_Set_ID                    NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.COST_AMOUNT_SET_ID%TYPE
              ,Revenue_Amount_Set_ID                 NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.REVENUE_AMOUNT_SET_ID%TYPE
              ,All_Amount_Set_ID                     NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.ALL_AMOUNT_SET_ID%TYPE
              ,Cost_Fin_Plan_Level_Code              PA_PROJ_FP_OPTIONS.COST_FIN_PLAN_LEVEL_CODE%TYPE
              ,Cost_Time_Phased_Code                 PA_PROJ_FP_OPTIONS.COST_TIME_PHASED_CODE%TYPE
              ,Cost_Resource_List_ID                 NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.COST_RESOURCE_LIST_ID%TYPE
              ,Revenue_Fin_Plan_Level_Code           PA_PROJ_FP_OPTIONS.REVENUE_FIN_PLAN_LEVEL_CODE%TYPE
              ,Revenue_Time_Phased_Code              PA_PROJ_FP_OPTIONS.REVENUE_TIME_PHASED_CODE%TYPE
              ,Revenue_Resource_List_ID              NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.REVENUE_RESOURCE_LIST_ID%TYPE
              ,All_Fin_Plan_Level_Code               PA_PROJ_FP_OPTIONS.ALL_FIN_PLAN_LEVEL_CODE%TYPE
              ,All_Time_Phased_Code                  PA_PROJ_FP_OPTIONS.ALL_TIME_PHASED_CODE%TYPE
              ,All_Resource_List_ID                  NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.ALL_RESOURCE_LIST_ID%TYPE
              ,Report_Labor_Hrs_From_Code            PA_PROJ_FP_OPTIONS.REPORT_LABOR_HRS_FROM_CODE%TYPE
              ,Plan_In_Multi_Curr_Flag               PA_PROJ_FP_OPTIONS.PLAN_IN_MULTI_CURR_FLAG%TYPE
              ,Factor_By_Code                        PA_PROJ_FP_OPTIONS.FACTOR_BY_CODE%TYPE
              ,Default_Amount_Type_Code              PA_PROJ_FP_OPTIONS.DEFAULT_AMOUNT_TYPE_CODE%TYPE
              ,default_amount_subtype_code           PA_PROJ_FP_OPTIONS.default_amount_subtype_code%TYPE
              ,margin_derived_from_code              PA_PROJ_FP_OPTIONS.margin_derived_from_code%TYPE
              /* Bug 2920954 start of columns included for post FP-K oneoff patch*/
              ,select_cost_res_auto_flag             PA_PROJ_FP_OPTIONS.select_cost_res_auto_flag%TYPE
              ,cost_res_planning_level               PA_PROJ_FP_OPTIONS.cost_res_planning_level%TYPE
              ,select_rev_res_auto_flag              PA_PROJ_FP_OPTIONS.select_rev_res_auto_flag%TYPE
              ,revenue_res_planning_level            PA_PROJ_FP_OPTIONS.revenue_res_planning_level%TYPE
              ,select_all_res_auto_flag              PA_PROJ_FP_OPTIONS.select_all_res_auto_flag%TYPE
              ,all_res_planning_level                PA_PROJ_FP_OPTIONS.all_res_planning_level%TYPE
              /* Bug 2920954 end of columns included for post FP-K oneoff patch*/
              , use_planning_rates_flag              PA_PROJ_FP_OPTIONS.use_planning_rates_flag%TYPE
              , rbs_version_id                       NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.rbs_version_id%TYPE
              , res_class_raw_cost_sch_id            NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.res_class_raw_cost_sch_id%TYPE
              , res_class_bill_rate_sch_id           NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.res_class_bill_rate_sch_id%TYPE
              , cost_emp_rate_sch_id                 NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.cost_emp_rate_sch_id%TYPE
              , cost_job_rate_sch_id                 NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.cost_job_rate_sch_id%TYPE
              , cost_non_labor_res_rate_sch_id       NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.cost_non_labor_res_rate_sch_id%TYPE
              , cost_res_class_rate_sch_id           NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.cost_res_class_rate_sch_id%TYPE
              , cost_burden_rate_sch_id              NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.cost_burden_rate_sch_id%TYPE
              , cost_current_planning_period         PA_PROJ_FP_OPTIONS.cost_current_planning_period%TYPE
              , cost_period_mask_id                  PA_PROJ_FP_OPTIONS.cost_period_mask_id%TYPE
              , rev_emp_rate_sch_id                  NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.rev_emp_rate_sch_id%TYPE
              , rev_job_rate_sch_id                  NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.rev_job_rate_sch_id%TYPE
              , rev_non_labor_res_rate_sch_id        NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.rev_non_labor_res_rate_sch_id%TYPE
              , rev_res_class_rate_sch_id            NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.rev_res_class_rate_sch_id%TYPE
              , rev_current_planning_period          PA_PROJ_FP_OPTIONS.rev_current_planning_period%TYPE
              , rev_period_mask_id                   NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.rev_period_mask_id%TYPE
              , all_current_planning_period          PA_PROJ_FP_OPTIONS.all_current_planning_period%TYPE
              , all_period_mask_id                   NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.all_period_mask_id%TYPE
              , gen_cost_src_code                    PA_PROJ_FP_OPTIONS.gen_cost_src_code%TYPE
              , gen_cost_etc_src_code                PA_PROJ_FP_OPTIONS.gen_cost_etc_src_code%TYPE
              , gen_cost_incl_change_doc_flag        PA_PROJ_FP_OPTIONS.gen_cost_incl_change_doc_flag%TYPE
              , gen_cost_incl_open_comm_flag         PA_PROJ_FP_OPTIONS.gen_cost_incl_open_comm_flag%TYPE
              , gen_cost_ret_manual_line_flag        PA_PROJ_FP_OPTIONS.gen_cost_ret_manual_line_flag%TYPE
              , gen_cost_incl_unspent_amt_flag       PA_PROJ_FP_OPTIONS.gen_cost_incl_unspent_amt_flag%TYPE
              , gen_rev_src_code                     PA_PROJ_FP_OPTIONS.gen_rev_src_code%TYPE
              , gen_rev_etc_src_code                 PA_PROJ_FP_OPTIONS.gen_rev_etc_src_code%TYPE
              , gen_rev_incl_change_doc_flag         PA_PROJ_FP_OPTIONS.gen_rev_incl_change_doc_flag%TYPE
              , gen_rev_incl_bill_event_flag         PA_PROJ_FP_OPTIONS.gen_rev_incl_bill_event_flag%TYPE
              , gen_rev_ret_manual_line_flag         PA_PROJ_FP_OPTIONS.gen_rev_ret_manual_line_flag%TYPE
              , gen_src_cost_plan_type_id            NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.gen_src_cost_plan_type_id%TYPE
              , gen_src_cost_plan_version_id         NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.gen_src_cost_plan_version_id%TYPE
              , gen_src_cost_plan_ver_code           PA_PROJ_FP_OPTIONS.gen_src_cost_plan_ver_code%TYPE
              , gen_src_rev_plan_type_id             NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.gen_src_rev_plan_type_id%TYPE
              , gen_src_rev_plan_version_id          NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.gen_src_rev_plan_version_id%TYPE
              , gen_src_rev_plan_ver_code            PA_PROJ_FP_OPTIONS.gen_src_rev_plan_ver_code%TYPE
              , gen_src_all_plan_type_id             NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.gen_src_all_plan_type_id%TYPE
              , gen_src_all_plan_version_id          NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.gen_src_all_plan_version_id%TYPE
              , gen_src_all_plan_ver_code            PA_PROJ_FP_OPTIONS.gen_src_all_plan_ver_code%TYPE
              , gen_all_src_code                     PA_PROJ_FP_OPTIONS.gen_all_src_code%TYPE
              , gen_all_etc_src_code                 PA_PROJ_FP_OPTIONS.gen_all_etc_src_code%TYPE
              , gen_all_incl_change_doc_flag         PA_PROJ_FP_OPTIONS.gen_all_incl_change_doc_flag%TYPE
              , gen_all_incl_open_comm_flag          PA_PROJ_FP_OPTIONS.gen_all_incl_open_comm_flag%TYPE
              , gen_all_ret_manual_line_flag         PA_PROJ_FP_OPTIONS.gen_all_ret_manual_line_flag%TYPE
              , gen_all_incl_bill_event_flag         PA_PROJ_FP_OPTIONS.gen_all_incl_bill_event_flag%TYPE
              , gen_all_incl_unspent_amt_flag        PA_PROJ_FP_OPTIONS.gen_all_incl_unspent_amt_flag%TYPE
              , gen_cost_actual_amts_thru_code       PA_PROJ_FP_OPTIONS.gen_cost_actual_amts_thru_code%TYPE
              , gen_rev_actual_amts_thru_code        PA_PROJ_FP_OPTIONS.gen_rev_actual_amts_thru_code%TYPE
              , gen_all_actual_amts_thru_code        PA_PROJ_FP_OPTIONS.gen_all_actual_amts_thru_code%TYPE
              , track_workplan_costs_flag            PA_PROJ_FP_OPTIONS.track_workplan_costs_flag%TYPE
              -- bug 3519062 addition of new columns used for workplan generation source setup
              , gen_src_cost_wp_version_id           NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.gen_src_cost_wp_version_id%TYPE
              , gen_src_cost_wp_ver_code             PA_PROJ_FP_OPTIONS.gen_src_cost_wp_ver_code%TYPE
              , gen_src_rev_wp_version_id            NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.gen_src_rev_wp_version_id%TYPE
              , gen_src_rev_wp_ver_code              PA_PROJ_FP_OPTIONS.gen_src_rev_wp_ver_code%TYPE
              , gen_src_all_wp_version_id            NUMBER -- Bug 3591144 PA_PROJ_FP_OPTIONS.gen_src_all_wp_version_id%TYPE
              , gen_src_all_wp_ver_code              PA_PROJ_FP_OPTIONS.gen_src_all_wp_ver_code%TYPE
              , cost_layout_code                     PA_PROJ_FP_OPTIONS.cost_layout_code%TYPE
              , revenue_layout_code                  PA_PROJ_FP_OPTIONS.revenue_layout_code%TYPE
              , all_layout_code                      PA_PROJ_FP_OPTIONS.all_layout_code%TYPE
              , revenue_derivation_method            PA_PROJ_FP_OPTIONS.revenue_derivation_method%TYPE --Bug 5462471
	             , copy_etc_from_plan_flag              PA_PROJ_FP_OPTIONS.copy_etc_from_plan_flag%TYPE --bug 8318932
              );

    -- End: Bug 3362316, 08-JAN-2003: Added New FP.M Columns  --------------------------


TYPE FP_MC_COLS IS RECORD (
               approved_cost_plan_type_flag  PA_PROJ_FP_OPTIONS.approved_cost_plan_type_flag%TYPE
              ,approved_rev_plan_type_flag   PA_PROJ_FP_OPTIONS.approved_rev_plan_type_flag%TYPE
               -- FPM Dev effort bug 3354518 included two new columns
              ,primary_cost_forecast_flag    PA_PROJ_FP_OPTIONS.primary_cost_forecast_flag%TYPE
              ,primary_rev_forecast_flag     PA_PROJ_FP_OPTIONS.primary_rev_forecast_flag%TYPE
               -- FPM Dev effort bug 3354518 included two new columns
              ,projfunc_cost_rate_type       PA_PROJ_FP_OPTIONS.projfunc_cost_rate_type%TYPE
              ,projfunc_cost_rate_date_type  PA_PROJ_FP_OPTIONS.projfunc_cost_rate_date_type%TYPE
              ,projfunc_cost_rate_date       PA_PROJ_FP_OPTIONS.projfunc_cost_rate_date%TYPE
              ,projfunc_rev_rate_type        PA_PROJ_FP_OPTIONS.projfunc_rev_rate_type%TYPE
              ,projfunc_rev_rate_date_type   PA_PROJ_FP_OPTIONS.projfunc_rev_rate_date_type%TYPE
              ,projfunc_rev_rate_date        PA_PROJ_FP_OPTIONS.projfunc_rev_rate_date%TYPE
              ,project_cost_rate_type        PA_PROJ_FP_OPTIONS.project_cost_rate_type%TYPE
              ,project_cost_rate_date_type   PA_PROJ_FP_OPTIONS.project_cost_rate_date_type%TYPE
              ,project_cost_rate_date        PA_PROJ_FP_OPTIONS.project_cost_rate_date%TYPE
              ,project_rev_rate_type         PA_PROJ_FP_OPTIONS.project_rev_rate_type%TYPE
              ,project_rev_rate_date_type    PA_PROJ_FP_OPTIONS.project_rev_rate_date_type%TYPE
              ,project_rev_rate_date         PA_PROJ_FP_OPTIONS.project_rev_rate_date%TYPE
                );

PROCEDURE Create_FP_Option (
          px_target_proj_fp_option_id             IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,p_source_proj_fp_option_id             IN NUMBER
          ,p_target_fp_option_level_code          IN VARCHAR2
          ,p_target_fp_preference_code            IN VARCHAR2
          ,p_target_fin_plan_version_id           IN NUMBER
          ,p_target_project_id                    IN NUMBER
          ,p_target_plan_type_id                  IN NUMBER
          ,x_return_status                       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                            OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE GET_FP_OPTIONS(
         p_proj_fp_options_id        IN NUMBER
         ,p_target_fp_options_id     IN NUMBER DEFAULT NULL
         ,p_fin_plan_preference_code IN VARCHAR2
         ,p_target_fp_option_level_code IN VARCHAR2 -- Added for ms-excel options for web adi
         ,x_fp_cols_rec             OUT NOCOPY FP_COLS
         ,x_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count               OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data                OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/* Bug # 2618119 */
procedure SYNCHRONIZE_BUDGET_VERSION
	(
	     p_budget_version_id                IN     pa_budget_versions.budget_version_id%TYPE,
	     x_return_status                    OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	     x_msg_count                        OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
	     x_msg_data                         OUT    NOCOPY VARCHAR2	 --File.Sql.39 bug 4440895
	);

FUNCTION GET_PARENT_FP_OPTION_ID(
         p_proj_fp_options_id  IN NUMBER ) RETURN PA_PROJ_FP_OPTIONS.PROJ_FP_OPTIONS_ID%TYPE;

FUNCTION GET_FP_OPTION_ID(
         p_project_id       IN NUMBER
         ,p_plan_type_id    IN NUMBER
         ,p_plan_version_id IN NUMBER   ) RETURN PA_PROJ_FP_OPTIONS.PROJ_FP_OPTIONS_ID%TYPE;

FUNCTION GET_DEFAULT_FP_OPTIONS(
         p_fin_plan_preference_code     IN VARCHAR2,
         p_target_project_id            IN pa_projects_all.project_id%TYPE,
         p_plan_type_id                 IN pa_proj_fp_options.fin_plan_type_id%TYPE ) RETURN FP_COLS;

FUNCTION GET_FP_PROJ_MC_OPTIONS (p_proj_fp_options_id IN  NUMBER) Return FP_MC_COLS;

FUNCTION GET_FP_PLAN_TYPE_MC_OPTIONS (p_fin_plan_type_id IN  NUMBER) Return FP_MC_COLS;

/*=====================================================================================
  This is a private api that would return gen src plan version id for a given option
  based on project id, target version type, gen src plan type id and gen src plan
  version code inputs

  23-JAN-2004 rravipat   FP M Dev effort Bug 3354518 (IDC)
                         Initial Creation
=====================================================================================*/
FUNCTION Gen_Src_Plan_Version_Id(
         p_target_project_id         IN   pa_projects_all.project_id%TYPE,
         p_target_version_type       IN   pa_budget_versions.version_type%TYPE,
         p_gen_src_plan_type_id      IN   pa_proj_fp_options.gen_src_cost_plan_type_id%TYPE,
         p_gen_src_plan_ver_code     IN   pa_proj_fp_options.gen_src_cost_plan_ver_code%TYPE)
RETURN pa_budget_versions.budget_version_id%TYPE;

/*=====================================================================================
  This is a private api that would return gen src wokplan budget version id for a given
  option based on project id and gen src workplan version code inputs

  20-MAR-2004 rravipat   FP M Dev effort Phase II changes
                         Initial Creation
=====================================================================================*/

FUNCTION Gen_Src_WP_Version_Id(
         p_target_project_id       IN   pa_projects_all.project_id%TYPE,
         p_gen_src_wp_ver_code     IN   pa_proj_fp_options.gen_src_cost_wp_ver_code%TYPE)
RETURN pa_budget_versions.budget_version_id%TYPE;

/*==================================================================================
This procedure is used to create the seeded view for the periodic budget or forcasts
 The  selected amount types for the layout will be stored using this method.This will
 also be used to store the seeded amount types for the layouts.

  06-Apr-2005 prachand   Created as a part of WebAdi changes.
                            Initial Creation
 ===================================================================================*/
PROCEDURE Create_amt_types (
           p_project_id             IN       pa_projects_all.project_id%TYPE
          ,p_fin_plan_type_id       IN       pa_fin_plan_types_b.fin_plan_type_id%TYPE
          ,p_plan_preference_code   IN       pa_proj_fp_options.fin_plan_preference_code%TYPE
          ,p_cost_layout_code       IN       pa_proj_fp_options.cost_layout_code%TYPE
          ,p_revenue_layout_code    IN       pa_proj_fp_options.revenue_layout_code%TYPE
          ,p_all_layout_code        IN       pa_proj_fp_options.all_layout_code%TYPE
          ,x_return_status          OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count              OUT      NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data               OUT      NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

/*==================================================================================
This procedure is used to copy the amount types for the periodic budget or forcasts
from an existing plan type The existing plan types amount types will be copied to the
new project or plan type when a copy is done.

  06-Apr-2005 prachand   Created as a part of WebAdi changes.
                            Initial Creation
 ===================================================================================*/

PROCEDURE  copy_amt_types (
           p_source_project_id             IN       pa_projects_all.project_id%TYPE
          ,p_source_fin_plan_type_id       IN       pa_fin_plan_types_b.fin_plan_type_id%TYPE
          ,p_target_project_id             IN       pa_projects_all.project_id%TYPE
          ,p_target_fin_plan_type_id       IN       pa_fin_plan_types_b.fin_plan_type_id%TYPE
          ,x_return_status                 OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                     OUT      NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                      OUT      NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

/*==================================================================================
This procedure is used to update the amount types for the periodic budget or forcasts
of an existing plan type The existing plan types amount types will be updated to the
new selected amount types.

  06-Apr-2005 prachand   Created as a part of WebAdi changes.
                            Initial Creation
 ===================================================================================*/


PROCEDURE  update_amt_types (
           p_project_id                IN       pa_projects_all.project_id%TYPE
          ,p_fin_plan_type_id          IN       pa_fin_plan_types_b.fin_plan_type_id%TYPE
          ,p_add_cost_amt_types_tbl    IN       SYSTEM.pa_varchar2_30_tbl_type
          ,p_del_cost_amt_types_tbl    IN       SYSTEM.pa_varchar2_30_tbl_type
          ,p_add_rev_amt_types_tbl     IN       SYSTEM.pa_varchar2_30_tbl_type
          ,p_del_rev_amt_types_tbl     IN       SYSTEM.pa_varchar2_30_tbl_type
          ,p_add_all_amt_types_tbl     IN       SYSTEM.pa_varchar2_30_tbl_type
          ,p_del_all_amt_types_tbl     IN       SYSTEM.pa_varchar2_30_tbl_type
          ,x_return_status             OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                 OUT      NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                  OUT      NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895


end PA_PROJ_FP_OPTIONS_PUB;


/
