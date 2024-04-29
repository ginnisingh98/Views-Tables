--------------------------------------------------------
--  DDL for Package PA_FP_EDIT_LINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_EDIT_LINE_PKG" AUTHID CURRENT_USER AS
/* $Header: PAFPEDLS.pls 120.2 2005/09/26 11:26:04 rnamburi noship $ */

/* Variable used for setting function security of current user */
G_IS_FN_SECURITY_AVAILABLE varchar2(1);

PROCEDURE POPULATE_ROLLUP_TMP(
          p_resource_assignment_id  IN  pa_resource_assignments.RESOURCE_ASSIGNMENT_ID%TYPE
          ,p_txn_currency_code      IN  pa_budget_lines.TXN_CURRENCY_CODE%TYPE
          ,p_calling_context        IN  VARCHAR2
          ,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data               OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

PROCEDURE DERIVE_PD_SD_START_END_DATES
    (p_calling_context           IN  VARCHAR2
    ,p_pp_st_dt                  IN  pa_budget_lines.start_date%TYPE
    ,p_pp_end_dt                 IN  pa_budget_lines.start_date%TYPE
    ,p_plan_period_type          IN  pa_proj_period_profiles.plan_period_type%TYPE
    ,p_resource_assignment_id    IN  pa_resource_assignments.resource_assignment_id%TYPE
    ,p_transaction_currency_code IN  pa_budget_lines.txn_currency_code%TYPE
    ,x_pd_st_dt                  OUT NOCOPY pa_budget_lines.start_date%TYPE --File.Sql.39 bug 4440895
    ,x_pd_end_dt                 OUT NOCOPY pa_budget_lines.start_date%TYPE --File.Sql.39 bug 4440895
    ,x_pd_period_name            OUT NOCOPY pa_budget_lines.period_name%TYPE     --File.Sql.39 bug 4440895
    ,x_sd_st_dt                  OUT NOCOPY pa_budget_lines.start_date%TYPE --File.Sql.39 bug 4440895
    ,x_sd_end_dt                 OUT NOCOPY pa_budget_lines.start_date%TYPE --File.Sql.39 bug 4440895
    ,x_sd_period_name            OUT NOCOPY pa_budget_lines.period_name%TYPE     --File.Sql.39 bug 4440895
    ,x_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count                 OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data                  OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/* Bug# 2674353 - Included p_calling_context parameter */

PROCEDURE PROCESS_MODIFIED_LINES
         (  --Bug Fix: 4569365. Removed MRC code.
		    p_calling_context            IN  VARCHAR2 --pa_mrc_finplan.g_calling_module%TYPE DEFAULT NULL
           ,p_resource_assignment_id     IN  pa_resource_assignments.RESOURCE_ASSIGNMENT_ID%TYPE
           ,p_fin_plan_version_id        IN  pa_resource_assignments.budget_version_id%TYPE DEFAULT NULL
           ,x_return_status             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count                 OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_msg_data                  OUT  NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895


PROCEDURE GET_ELEMENT_AMOUNT_INFO
       ( p_resource_assignment_id      IN pa_resource_assignments.RESOURCE_ASSIGNMENT_ID%TYPE
        ,p_txn_currency_code           IN pa_budget_lines.TXN_CURRENCY_CODE%TYPE
        ,p_calling_context            IN  VARCHAR2
        ,x_quantity_flag              OUT NOCOPY pa_fin_plan_amount_sets.cost_qty_flag%TYPE  --File.Sql.39 bug 4440895
        ,x_raw_cost_flag              OUT NOCOPY pa_fin_plan_amount_sets.raw_cost_flag%TYPE  --File.Sql.39 bug 4440895
        ,x_burdened_cost_flag         OUT NOCOPY pa_fin_plan_amount_sets.burdened_cost_flag%TYPE  --File.Sql.39 bug 4440895
        ,x_revenue_flag               OUT NOCOPY pa_fin_plan_amount_sets.revenue_flag%TYPE  --File.Sql.39 bug 4440895
/* Changes for FP.M, Tracking Bug No - 3354518. Adding three new OUT parameters x_bill_rate_flag,
   x_cost_rate_flag, x_burden_multiplier_flag below for new columns in pa_fin_plan_amount_sets */
/* Changes for FP.M, Tracking Bug No - 3354518. Start here*/
        ,x_bill_rate_flag             OUT NOCOPY pa_fin_plan_amount_sets.bill_rate_flag%TYPE --File.Sql.39 bug 4440895
        ,x_cost_rate_flag             OUT NOCOPY pa_fin_plan_amount_sets.cost_rate_flag%TYPE --File.Sql.39 bug 4440895
        ,x_burden_multiplier_flag     OUT NOCOPY pa_fin_plan_amount_sets.burden_rate_flag%TYPE --File.Sql.39 bug 4440895
/* Changes for FP.M, Tracking Bug No - 3354518. End here*/
        ,x_period_profile_id          OUT NOCOPY pa_proj_periods_denorm.PERIOD_PROFILE_ID%TYPE --File.Sql.39 bug 4440895
        ,x_plan_period_type           OUT NOCOPY pa_proj_period_profiles.PLAN_PERIOD_TYPE%TYPE --File.Sql.39 bug 4440895
        ,x_quantity                   OUT NOCOPY pa_budget_lines.QUANTITY%TYPE --File.Sql.39 bug 4440895
        ,x_project_raw_cost           OUT NOCOPY pa_budget_lines.RAW_COST%TYPE --File.Sql.39 bug 4440895
        ,x_project_burdened_cost      OUT NOCOPY pa_budget_lines.BURDENED_COST%TYPE --File.Sql.39 bug 4440895
        ,x_project_revenue            OUT NOCOPY pa_budget_lines.REVENUE%TYPE --File.Sql.39 bug 4440895
        ,x_projfunc_raw_cost          OUT NOCOPY pa_budget_lines.RAW_COST%TYPE --File.Sql.39 bug 4440895
        ,x_projfunc_burdened_cost     OUT NOCOPY pa_budget_lines.BURDENED_COST%TYPE --File.Sql.39 bug 4440895
        ,x_projfunc_revenue           OUT NOCOPY pa_budget_lines.REVENUE%TYPE --File.Sql.39 bug 4440895
        ,x_projfunc_margin            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
        ,x_projfunc_margin_percent    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
        ,x_proj_margin                OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
        ,x_proj_margin_percent        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
        ,x_return_status              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
        ,x_msg_count                  OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
        ,x_msg_data                   OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

PROCEDURE CALL_CLIENT_EXTENSIONS
          (  p_project_id         IN pa_projects_all.PROJECT_ID%TYPE
            ,p_budget_version_id  IN pa_budget_versions.budget_version_id%TYPE
            ,p_task_id            IN pa_tasks.TASK_ID%TYPE
            ,p_resource_list_member_id IN pa_resource_list_members.RESOURCE_LIST_MEMBER_ID%TYPE
            ,p_resource_list_id   IN pa_resource_lists.RESOURCE_LIST_ID%TYPE
            ,p_resource_id        IN pa_resources.RESOURCE_ID%TYPE
            ,p_txn_currency_code  IN pa_budget_lines.txn_currency_code%TYPE
            ,p_product_code_tbl   IN SYSTEM.pa_varchar2_30_tbl_type
            ,p_start_date_tbl     IN SYSTEM.pa_date_tbl_type
            ,p_end_date_tbl       IN SYSTEM.pa_date_tbl_type
            ,p_period_name_tbl    IN SYSTEM.pa_varchar2_30_tbl_type
            ,p_quantity_tbl       IN SYSTEM.pa_num_tbl_type
            ,px_raw_cost_tbl      IN OUT NOCOPY SYSTEM.pa_num_tbl_type
            ,px_burdened_cost_tbl IN OUT NOCOPY SYSTEM.pa_num_tbl_type
            ,px_revenue_tbl       IN OUT NOCOPY SYSTEM.pa_num_tbl_type
            ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
            ,x_msg_count          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
            ,x_msg_data           OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

PROCEDURE POPULATE_ELIGIBLE_PERIODS
          (  p_fin_plan_version_id          IN pa_proj_fp_options.fin_plan_version_id%TYPE
            ,p_period_profile_start_date    IN pa_budget_lines.start_date%TYPE
            ,p_period_profile_end_date      IN pa_budget_lines.end_date%TYPE
            ,p_preceding_prd_start_date     IN pa_budget_lines.start_Date%TYPE
            ,p_succeeding_prd_start_date    IN pa_budget_lines.start_Date%TYPE
            ,x_return_status         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
            ,x_msg_count             OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
            ,x_msg_data              OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

PROCEDURE GET_PRECEDING_SUCCEEDING_AMT(
          p_budget_version_id          IN pa_proj_fp_options.fin_plan_version_id%TYPE  -- Added for #2839138
         ,p_resource_assignment_id     IN pa_resource_assignments.RESOURCE_ASSIGNMENT_ID%TYPE
         ,p_txn_currency_code          IN pa_budget_lines.TXN_CURRENCY_CODE%TYPE
         ,p_period_profile_id          IN pa_budget_versions.period_profile_id%TYPE
         ,x_preceding_raw_cost         OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_succeeding_raw_cost        OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_preceding_burdened_cost    OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_succeeding_burdened_cost   OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_preceding_revenue          OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_succeeding_revenue         OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE         --File.Sql.39 bug 4440895
         ,x_preceding_quantity         OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_succeeding_quantity        OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_return_status              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count                  OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data                   OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895

FUNCTION get_is_fn_security_available RETURN VARCHAR2;

PROCEDURE  CALL_CLIENT_EXTENSIONS
          (  p_project_id             IN pa_projects_all.PROJECT_ID%TYPE
            ,p_budget_version_id      IN pa_budget_versions.budget_version_id%TYPE
            ,p_task_id_tbl            IN SYSTEM.pa_num_tbl_type
            ,p_res_list_member_id_tbl IN SYSTEM.pa_num_tbl_type
            ,p_resource_list_id       IN pa_resource_lists.RESOURCE_LIST_ID%TYPE
            ,p_resource_id_tbl        IN SYSTEM.pa_num_tbl_type
            ,p_txn_currency_code_tbl  IN SYSTEM.pa_varchar2_30_tbl_type
            ,p_product_code_tbl       IN SYSTEM.pa_varchar2_30_tbl_type
            ,p_start_date_tbl         IN SYSTEM.pa_date_tbl_type
            ,p_end_date_tbl           IN SYSTEM.pa_date_tbl_type
            ,p_period_name_tbl        IN SYSTEM.pa_varchar2_30_tbl_type
            ,p_quantity_tbl           IN SYSTEM.pa_num_tbl_type
            ,px_raw_cost_tbl          IN OUT NOCOPY SYSTEM.pa_num_tbl_type
            ,px_burdened_cost_tbl     IN OUT NOCOPY SYSTEM.pa_num_tbl_type
            ,px_revenue_tbl           IN OUT NOCOPY SYSTEM.pa_num_tbl_type
            ,x_return_status          OUT NOCOPY VARCHAR2     --File.Sql.39 bug 4440895
            ,x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
            ,x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ) ;

PROCEDURE Find_dup_rows_in_rollup_tmp
( x_return_status  OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count      OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data       OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE GET_PD_SD_AMT_IN_PC_PFC(
          p_resource_assignment_id     IN  pa_resource_assignments.resource_assignment_id%TYPE
         ,p_txn_currency_code          IN  pa_budget_lines.txn_currency_code%TYPE
         ,p_period_profile_id          IN  pa_budget_versions.period_profile_id%TYPE
         ,x_pd_pc_raw_cost             OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_pd_pfc_raw_cost            OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_sd_pc_raw_cost             OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_sd_pfc_raw_cost            OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_pd_pc_burdened_cost        OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_pd_pfc_burdened_cost       OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_sd_pc_burdened_cost        OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_sd_pfc_burdened_cost       OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_pd_pc_revenue              OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_pd_pfc_revenue             OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_sd_pc_revenue              OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_sd_pfc_revenue             OUT NOCOPY pa_proj_periods_denorm.preceding_periods_amount%TYPE --File.Sql.39 bug 4440895
         ,x_return_status              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count                  OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data                   OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE PROCESS_BDGTLINES_FOR_VERSION
          (  p_budget_version_id      IN  pa_budget_versions.budget_version_id%TYPE
            ,p_calling_context        IN  VARCHAR2
            ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
            ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
            ,x_msg_data              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          );

END PA_FP_EDIT_LINE_PKG ;




 

/
