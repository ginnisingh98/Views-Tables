--------------------------------------------------------
--  DDL for Package PA_FP_WEBADI_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_WEBADI_UTILS" AUTHID CURRENT_USER as
/* $Header: PAFPWAUS.pls 120.5 2007/02/06 10:17:33 dthakker noship $ */

PROCEDURE GET_METADATA_INFO
                     ( p_budget_version_id    IN      NUMBER
                      ,x_content_code         OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                      ,x_mapping_code         OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                      ,x_layout_code          OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                      ,x_integrator_code      OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                      ,x_rej_lines_exist      OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                      ,x_submit_budget        OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                      ,x_submit_forecast      OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                      ,x_err_msg_code         OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                      ,x_return_status        OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                      ,x_msg_count            OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                      ,x_msg_data             OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                    );

PROCEDURE VALIDATE_BEFORE_LAUNCH
                    ( p_budget_version_id    IN   NUMBER
                     ,x_return_status        OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                     ,x_msg_count            OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
                     ,x_msg_data             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                    );

PROCEDURE CONVERT_TASK_NUM_TO_ID
                   ( p_project_id       IN     NUMBER
                    ,p_task_num         IN     VARCHAR2
                    ,x_task_id          OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
                    ,x_return_status    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                    ,x_msg_count        OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
                    ,x_msg_data         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                    );

PROCEDURE VALIDATE_CURRENCY_CODE
                   (p_budget_version_id  IN    NUMBER
                   ,p_currency_code      IN    VARCHAR2
                   ,x_return_status      OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                   ,x_msg_count          OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
                   ,x_msg_data           OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                   );

PROCEDURE VALIDATE_RESOURCE_INFO
                    (p_budget_version_id        IN     NUMBER
                    ,p_resource_group_name      IN     VARCHAR2
                    ,p_resource_alias           IN     VARCHAR2
                    ,x_resource_list_member_id  OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
                    ,x_resource_gp_flag         OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                    ,x_resource_alias_flag      OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                    ,x_return_status            OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                    );

PROCEDURE GET_RES_ASSIGNMENT_INFO
                  (p_resource_assignment_id IN  pa_resource_assignments.resource_assignment_id%TYPE
                  ,p_planning_level         IN  pa_proj_fp_options.cost_fin_plan_level_code%TYPE
                  ,x_task_number            OUT NOCOPY pa_tasks.task_number%TYPE --File.Sql.39 bug 4440895
                  ,x_task_id                OUT NOCOPY pa_tasks.task_id%TYPE --File.Sql.39 bug 4440895
                  ,x_resource_alias         OUT NOCOPY pa_resource_list_members.alias%TYPE --File.Sql.39 bug 4440895
                  ,x_resource_group_alias   OUT NOCOPY pa_resource_list_members.alias%TYPE --File.Sql.39 bug 4440895
                  ,x_parent_assignment_id   OUT NOCOPY pa_resource_assignments.parent_assignment_id%TYPE --File.Sql.39 bug 4440895
                  ,x_resource_list_member_id OUT NOCOPY pa_resource_list_members.resource_list_member_id%TYPE --File.Sql.39 bug 4440895
                  ,x_resource_id            OUT NOCOPY pa_resource_list_members.resource_id%TYPE --File.Sql.39 bug 4440895
                  ,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                  ,x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                  ,x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                  ) ;
/* Bug 5350437: Commented the below API
PROCEDURE VALIDATE_CHANGE_REASON_CODE
                 (p_change_reason_code  IN  pa_budget_lines.change_reason_code%TYPE
                 ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                 ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                 ,x_msg_data            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                 );
*/

PROCEDURE VALIDATE_TXN_CURRENCY_CODE
                 (p_budget_version_id    IN  pa_budget_versions.budget_version_id%TYPE
                 ,p_proj_fp_options_id   IN  pa_proj_fp_options.proj_fp_options_id%TYPE
                 ,p_txn_currency_code    IN  pa_budget_lines.txn_currency_code%TYPE
                 ,x_return_status        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                 ,x_msg_count            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
                 ,x_msg_data             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                 );
/* Bug 5350437: Commented the below API
PROCEDURE GET_VERSION_PERIODS_INFO
                 (p_budget_version_id IN   pa_budget_versions.budget_version_id%TYPE
                 ,x_period_name_tbl   OUT  NOCOPY pa_fp_webadi_pkg.l_period_name_tbl_typ --File.Sql.39 bug 4440895
                 ,x_start_date_tbl    OUT  NOCOPY pa_fp_webadi_pkg.l_start_date_tbl_typ --File.Sql.39 bug 4440895
                 ,x_end_date_tbl      OUT  NOCOPY pa_fp_webadi_pkg.l_end_date_tbl_typ --File.Sql.39 bug 4440895
                 ,x_number_of_pds     OUT  NOCOPY pa_proj_period_profiles.number_of_periods%TYPE --File.Sql.39 bug 4440895
                 ,x_period_profile_id OUT  NOCOPY pa_budget_versions.period_profile_id%TYPE --File.Sql.39 bug 4440895
                 ,x_return_status     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                 ,x_msg_count         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
                 ,x_msg_data          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                 ) ;
*/

PROCEDURE CHECK_OVERLAPPING_DATES
                 (p_budget_version_id     IN   pa_budget_versions.budget_version_id%TYPE
                 ,x_rec_failed_validation OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                 ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                 ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
                 ,x_msg_data              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                 ) ;

PROCEDURE GET_MC_ERROR_LOOKUP_CODE
                 (p_mc_error_code         IN   pa_lookups.lookup_code%TYPE
                 ,p_attr_set_cost_rev     IN   VARCHAR2
                 ,p_attr_set_pc_pfc       IN   VARCHAR2
                 ,x_error_lookup_code     OUT  NOCOPY pa_lookups.lookup_code%TYPE --File.Sql.39 bug 4440895
                 ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                 ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
                 ,x_msg_data              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                 );

PROCEDURE CONV_MC_ATTR_MEANING_TO_CODE
                (p_pc_cost_rate_type_name         IN  pa_conversion_types_v.user_conversion_type%TYPE
                ,p_pc_cost_rate_date_type_name    IN  pa_lookups.meaning%TYPE
                ,p_pfc_cost_rate_type_name        IN  pa_conversion_types_v.user_conversion_type%TYPE
                ,p_pfc_cost_rate_date_type_name   IN  pa_lookups.meaning%TYPE
                ,p_pc_rev_rate_type_name          IN  pa_conversion_types_v.user_conversion_type%TYPE
                ,p_pc_rev_rate_date_type_name     IN  pa_lookups.meaning%TYPE
                ,p_pfc_rev_rate_type_name         IN  pa_conversion_types_v.user_conversion_type%TYPE
                ,p_pfc_rev_rate_date_type_name    IN  pa_lookups.meaning%TYPE
                ,x_pc_cost_rate_type              OUT  NOCOPY pa_conversion_types_v.conversion_type%TYPE --File.Sql.39 bug 4440895
                ,x_pc_cost_rate_date_type         OUT  NOCOPY pa_lookups.lookup_code%TYPE --File.Sql.39 bug 4440895
                ,x_pfc_cost_rate_type             OUT  NOCOPY pa_conversion_types_v.conversion_type%TYPE --File.Sql.39 bug 4440895
                ,x_pfc_cost_rate_date_type        OUT  NOCOPY pa_lookups.lookup_code%TYPE --File.Sql.39 bug 4440895
                ,x_pc_rev_rate_type               OUT  NOCOPY pa_conversion_types_v.conversion_type%TYPE --File.Sql.39 bug 4440895
                ,x_pc_rev_rate_date_type          OUT  NOCOPY pa_lookups.lookup_code%TYPE --File.Sql.39 bug 4440895
                ,x_pfc_rev_rate_type              OUT  NOCOPY pa_conversion_types_v.conversion_type%TYPE --File.Sql.39 bug 4440895
                ,x_pfc_rev_rate_date_type         OUT  NOCOPY pa_lookups.lookup_code%TYPE --File.Sql.39 bug 4440895
                ,x_return_status                  OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                ,x_msg_count                      OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
                ,x_msg_data                       OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                );

FUNCTION GET_AMOUNT_TYPE_NAME (
         p_amount_type_code  IN   PA_AMOUNT_TYPES_B.AMOUNT_TYPE_CODE%TYPE )
RETURN   PA_AMOUNT_TYPES_VL.AMOUNT_TYPE_NAME%TYPE ;

/*==================================================================================
This procedure is used to get the layout name and the layout type code when the
layout type is passed.
06-Apr-2005 prachand   Created as a part of WebAdi changes.
                        Initial Creation
===================================================================================*/



PROCEDURE GET_LAYOUT_DETAILS
                 (p_layout_code           IN    pa_proj_fp_options.cost_layout_code%TYPE
                 ,p_integrator_code       IN    bne_integrators_b.integrator_code%TYPE
                 ,x_layout_name           OUT   NOCOPY bne_layouts_tl.user_name%TYPE --File.Sql.39 bug 4440895
                 ,x_layout_type_code      OUT   NOCOPY pa_lookups.lookup_code%TYPE --File.Sql.39 bug 4440895
                 ,x_return_status         OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                 ,x_msg_count             OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
                 ,x_msg_data              OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                 );

-- Bug 3986129: FP.M Web ADI Dev changes: Added the follwoing apis

-- This api would be called from a java method when the user wants to delete the data from the excel interface
-- that is downloaded for a session.

  PROCEDURE delete_interface_tbl_data
      (p_request_id           IN          pa_budget_versions.request_id%TYPE,
       x_return_status        OUT         NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_msg_count            OUT         NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_msg_data             OUT         NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

  -- This api would be called from a java method when the user wants to resubmit the request for the concurrent
  -- program, if the upload processing of the plan version fails for some reason.

  PROCEDURE resubmit_conc_request
      (p_old_request_id       IN          pa_budget_versions.request_id%TYPE,
       x_new_request_id       OUT         NOCOPY pa_budget_versions.request_id%TYPE, --File.Sql.39 bug 4440895
       x_return_status        OUT         NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_msg_count            OUT         NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_msg_data             OUT         NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

 -- Bug 3986129: FP.M Web ADI Dev changes: Ends

-- Bug 3986129: FP.M Web ADI Dev changes: Added the follwoing apis
/* =================================================================================
  This function is used is FPM's Budget and Forecasting webadi download query to get the period amounts
  of the current baselined plan version
=======================================================================================*/
FUNCTION get_current_amount(
  p_fin_plan_type_id         NUMBER,
  p_plan_class_code          VARCHAR2,
  p_project_id               NUMBER,
  p_fin_plan_preference_code pa_proj_fp_options.fin_plan_preference_code%TYPE,
  p_task_id                  NUMBER,
  p_resource_list_member_id  NUMBER,
  p_uom                      pa_resource_assignments.unit_of_measure%TYPE,
  p_txn_curr_code            pa_budget_lines.txn_currency_code%TYPE,
  p_amount                   VARCHAR2)
RETURN NUMBER;


/* =================================================================================
  This function is used is FPM's  Budget and Forecasting webadi download query to
  get the period amounts  of the original baselined plan version
=======================================================================================*/
FUNCTION get_original_amount(
  p_fin_plan_type_id         NUMBER,
  p_plan_class_code          VARCHAR2,
  p_project_id               NUMBER,
  p_fin_plan_preference_code pa_proj_fp_options.fin_plan_preference_code%TYPE,
  p_task_id                  NUMBER,
  p_resource_list_member_id  NUMBER,
  p_uom                      pa_resource_assignments.unit_of_measure%TYPE,
  p_txn_curr_code            pa_budget_lines.txn_currency_code%TYPE,
  p_amount                   VARCHAR2)
RETURN NUMBER;

/* =================================================================================
  This function is used is FPM's  Budget and Forecasting webadi download query to
  get the period amounts of the prior forecast plan version
=======================================================================================*/
FUNCTION get_prior_forecast_amount(
  p_fin_plan_type_id         NUMBER,
  p_plan_class_code          VARCHAR2,
  p_project_id               NUMBER,
  p_fin_plan_preference_code pa_proj_fp_options.fin_plan_preference_code%TYPE,
  p_task_id                  NUMBER,
  p_resource_list_member_id  NUMBER,
  p_uom                      pa_resource_assignments.unit_of_measure%TYPE,
  p_txn_curr_code            pa_budget_lines.txn_currency_code%TYPE,
  p_amount                   VARCHAR2)
RETURN NUMBER;


/* =================================================================================
  This function is used is FPM's Budget and Forecasting webadi download query to get the
  period amounts for the following amount types: RAW_COST_RATE,BURDENED_COST_RATE,BILL_RATE,
  'TOTAL_QTY''FCST_QTY',TOTAL_RAW_COST,FCST_RAW_COST,TOTAL_REV,FCST_REV,TOTAL_BURDENED_COST,
  FCST_BURDENED_COST,ACTUAL_QTY,ACTUAL_RAW_COST,ACTUAL_BURD_COST,ACTUAL_REVENUE,ETC_QTY,
  ETC_RAW_COST,ETC_BURDENED_COST,ETC_REVENUE
=======================================================================================*/
FUNCTION get_period_amounts(
                     p_budget_version_id           NUMBER,
                     p_amount_code                 VARCHAR2,
                     p_resource_assignment_id      pa_budget_lines.resource_assignment_id%TYPE,
             p_txn_currency_code           pa_budget_lines.txn_currency_code%TYPE,
             p_prd_start_date              DATE,
             p_prd_end_date        DATE,
             preceding_date                DATE,
             succedeing_date               DATE)
RETURN NUMBER;
-- Bug 3986129: FP.M Web ADI Dev changes: Ends



END PA_FP_WEBADI_UTILS;

/
