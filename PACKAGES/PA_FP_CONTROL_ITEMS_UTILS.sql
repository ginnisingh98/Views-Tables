--------------------------------------------------------
--  DDL for Package PA_FP_CONTROL_ITEMS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_CONTROL_ITEMS_UTILS" AUTHID CURRENT_USER AS
/* $Header: PAFPCIUS.pls 120.2.12010000.3 2009/08/13 11:32:51 kkorada ship $ */

--Merge exception
RAISE_MERGE_ERROR   EXCEPTION;
PRAGMA EXCEPTION_INIT(RAISE_MERGE_ERROR, -501);

PROCEDURE Get_Fin_Plan_Dtls(p_project_id                    IN          Pa_Projects_All.Project_Id%TYPE,
                            p_ci_id                         IN          NUMBER,
                            x_fin_plan_type_id_cost         OUT         NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            x_fin_plan_type_id_rev          OUT         NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            x_fin_plan_type_id_all          OUT         NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            x_fp_type_id_margin_code        OUT         NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            x_margin_derived_from_code      OUT         NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            x_report_labor_hours_code       OUT         NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            x_fp_pref_code                  OUT         NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            x_project_currency_code         OUT         NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            x_baseline_funding_flag         OUT         NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            x_msg_data                      OUT         NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            x_msg_count                     OUT         NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            x_return_status                 OUT         NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            x_ci_type_class_code            OUT         NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                            x_no_of_ci_plan_versions        OUT         NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            x_ci_est_qty                    OUT         NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            x_ci_planned_qty                OUT         NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            x_baselined_planned_qty         OUT         NOCOPY NUMBER, --File.Sql.39 bug 4440895
                            x_ci_ver_plan_prc_code          OUT         NOCOPY pa_budget_versions.plan_processing_code%TYPE, --File.Sql.39 bug 4440895
                            x_request_id                    OUT         NOCOPY pa_budget_versions.request_id%TYPE); --File.Sql.39 bug 4440895

FUNCTION Is_Financial_Planning_Allowed(p_project_id NUMBER) RETURN VARCHAR2;

PROCEDURE get_finplan_ci_type_name
(
        p_ci_id                         IN NUMBER,
        x_ci_type_name                  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_msg_data                      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_msg_count                     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
        x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

) ;

PROCEDURE get_fp_ci_agreement_dtls
(
        p_project_id                    IN NUMBER,
        p_ci_id                         IN NUMBER,
        x_agreement_num                 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_agreement_amount              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
        x_agreement_currency_code       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_msg_data                      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
        x_msg_count                     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
        x_return_status                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

PROCEDURE FP_CI_GET_VERSION_DETAILS
(
     p_project_id        IN NUMBER,
     p_budget_version_id IN pa_budget_versions.budget_version_id%TYPE,
     x_fin_plan_pref_code     OUT NOCOPY pa_proj_fp_options.fin_plan_preference_code%TYPE, --File.Sql.39 bug 4440895
     x_multi_curr_flag   OUT NOCOPY pa_proj_fp_options.plan_in_multi_curr_flag%TYPE, --File.Sql.39 bug 4440895
     x_fin_plan_level_code    OUT NOCOPY pa_proj_fp_options.all_fin_plan_level_code%TYPE, --File.Sql.39 bug 4440895
     x_resource_list_id  OUT NOCOPY pa_proj_fp_options.all_resource_list_id%TYPE, --File.Sql.39 bug 4440895
     x_time_phased_code  OUT NOCOPY pa_proj_fp_options.all_time_phased_code%TYPE, --File.Sql.39 bug 4440895
     x_uncategorized_flag     OUT NOCOPY pa_resource_lists_all_bg.uncategorized_flag%TYPE, --File.Sql.39 bug 4440895
     x_group_res_type_id OUT NOCOPY pa_resource_lists_all_bg.group_resource_type_id%TYPE, --File.Sql.39 bug 4440895
     x_version_type      OUT NOCOPY pa_budget_versions.version_type%TYPE, --File.Sql.39 bug 4440895
     x_ci_id             OUT NOCOPY pa_budget_versions.ci_id%TYPE, --File.Sql.39 bug 4440895
     x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)   ;

PROCEDURE FP_CI_CHECK_MERGE_POSSIBLE
(
  p_project_id                IN  NUMBER,
  p_source_fp_version_id_tbl  IN  SYSTEM.pa_num_tbl_type,
  p_target_fp_version_id      IN  NUMBER,
  p_calling_mode              IN  VARCHAR2,
  x_merge_possible_code_tbl   OUT NOCOPY SYSTEM.pa_varchar2_1_tbl_type,
  x_return_status             OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                 OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );

PROCEDURE isFundingLevelChangeAllowed
(
  p_project_id                  IN  NUMBER,
  p_proposed_fund_level         IN  VARCHAR2 DEFAULT NULL,
  x_return_status               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE isAgreementDeletionAllowed
(
  p_agreement_id                IN  NUMBER,
  x_return_status               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE isAgrCurrencyChangeAllowed
(
  p_agreement_id                IN  NUMBER,
  x_return_status               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
  x_msg_count                   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
  x_msg_data                    OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Is_Create_CI_Version_Allowed
   (  p_project_id              IN      pa_budget_versions.project_id%TYPE
     ,p_fin_plan_type_id        IN      pa_proj_fp_options.fin_plan_type_id%TYPE
     ,p_version_type            IN      pa_budget_versions.version_type%TYPE
     ,p_impacted_task_id        IN      pa_tasks.task_id%TYPE
     ,x_version_allowed_flag    OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_return_status           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count               OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE  IsValidAgreement(
                          p_project_id IN NUMBER,
                          p_agreement_number IN VARCHAR2,
                          x_agreement_id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_msg_count OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                          x_msg_data OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                          x_return_status OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

FUNCTION IsFpAutoBaselineEnabled(p_project_id IN NUMBER)
RETURN VARCHAR2;

PROCEDURE GET_BUDGET_VERSION_INFO
(
     p_project_id        IN NUMBER,
     p_budget_version_id IN NUMBER,
     x_version_number    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_version_name      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_version_type      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_project_currency_code OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_approved_cost_flag     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_approved_rev_flag OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_fin_plan_type_id  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_plan_type_name    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_plan_class_code    OUT NOCOPY VARCHAR2,          -- added for FPM --File.Sql.39 bug 4440895
     x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
)   ;

FUNCTION GET_FUNINDG_AMOUNT(
           p_project_id IN pa_projects_all.project_id%TYPE,
           p_agreement_id IN pa_agreements_all.agreement_id%TYPE)
RETURN NUMBER;

PROCEDURE CHK_APRV_CUR_WORKING_BV_EXISTS
          ( p_project_id              IN  pa_projects_all.project_id%TYPE
           ,p_fin_plan_type_id        IN  pa_proj_fp_options.fin_plan_type_id%TYPE
           ,p_version_type            IN  pa_budget_versions.version_type%TYPE
           ,x_cur_work_bv_id          OUT NOCOPY pa_budget_versions.budget_version_id%TYPE --File.Sql.39 bug 4440895
           ,x_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count               OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_msg_data                OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE COMPARE_SOURCE_TARGET_VER_ATTR
          ( p_source_bv_id            IN  pa_budget_versions.budget_version_id%TYPE
           ,p_target_bv_id            IN  pa_budget_versions.budget_version_id%TYPE
           ,x_attributes_same_flag    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count               OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_msg_data                OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE CHECK_PLAN_VERSION_NAME_OR_ID
(
     p_project_id        IN NUMBER,
     p_budget_version_name    IN VARCHAR2,
     p_fin_plan_type_id  IN NUMBER,
     p_version_type      IN VARCHAR2,
     x_no_of_bv_versions OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_budget_version_id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

PROCEDURE FP_CI_CHECK_COPY_POSSIBLE
(
      p_source_plan_level_code     IN pa_proj_fp_options.all_fin_plan_level_code%TYPE
     ,p_source_time_phased_code    IN pa_proj_fp_options.all_time_phased_code%TYPE
     ,p_source_resource_list_id    IN pa_proj_fp_options.all_resource_list_id%TYPE
     ,p_source_version_type        IN pa_budget_versions.version_type%TYPE
     ,p_project_id            IN pa_budget_versions.project_id%TYPE
     ,p_s_ci_id               IN pa_budget_versions.ci_id%TYPE
     ,p_multiple_plan_types_flag   IN VARCHAR2 DEFAULT 'N'
     ,x_copy_possible_flag         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_return_status              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                  OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

PROCEDURE CHECK_FP_PLAN_VERSION_EXISTS
(
     p_project_id        IN NUMBER,
     p_ci_id             IN VARCHAR2,
     x_call_fp_api_flag  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

/* Added the following procedure for bug #2651851. This procedure is used for Review
   and Submit of Control Items. */

PROCEDURE FP_CI_IMPACT_SUBMIT_CHK
          ( p_project_id              IN  pa_budget_versions.project_id%TYPE
           ,p_ci_id                   IN  pa_budget_versions.ci_id%TYPE
           ,x_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
           ,x_msg_count               OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
           ,x_msg_data                OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*
   Bug # 2681589 - This API returns Y/N in x_update_impact_allowed depending on
   whether we can update the impact as IMPLEMENTED or not.
*/
--Bug 3550073. Included x_upd_cost_impact_allowed and x_upd_rev_impact_allowed
PROCEDURE FP_CI_VALIDATE_UPDATE_IMPACT
  (
       p_project_id                  IN  pa_budget_versions.project_id%TYPE,
       p_ci_id                       IN  pa_control_items.ci_id%TYPE,
       p_source_version_id           IN  pa_budget_versions.budget_version_id%TYPE,
       p_target_version_id           IN  pa_budget_versions.budget_version_id%TYPE,
       x_upd_cost_impact_allowed     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_upd_rev_impact_allowed      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_msg_data                    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
       x_msg_count                   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
       x_return_status               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  procedure chk_res_resgrp_mismatch(
            p_project_id in number,
            p_s_budget_version_id           IN pa_budget_versions.budget_version_id%TYPE,
            p_s_fin_plan_level_code         IN pa_proj_fp_options.all_fin_plan_level_code%TYPE,
            p_t_budget_version_id           IN pa_budget_versions.budget_version_id%TYPE,
            p_t_fin_plan_level_code         IN pa_proj_fp_options.all_fin_plan_level_code%TYPE,
            p_calling_mode                  in varchar2,
            x_res_resgr_mismatch_flag       OUT NOCOPY varchar2, --File.Sql.39 bug 4440895
          x_msg_data                    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_msg_count                   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
          x_return_status               OUT NOCOPY VARCHAR2  ); --File.Sql.39 bug 4440895

procedure chk_tsk_plan_level_mismatch(
            p_project_id in number,
            p_s_budget_version_id           IN pa_budget_versions.budget_version_id%TYPE,
            p_t_budget_version_id           IN pa_budget_versions.budget_version_id%TYPE,
            p_calling_mode                  in varchar2,
            x_tsk_plan_level_mismatch      OUT NOCOPY varchar2, --File.Sql.39 bug 4440895
            x_s_task_id_tbl             OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
            x_t_task_id_tbl             OUT NOCOPY PA_PLSQL_DATATYPES.IdTabTyp,
            x_s_fin_plan_level_tbl      OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
            x_t_fin_plan_level_tbl      OUT NOCOPY PA_PLSQL_DATATYPES.Char30TabTyp,
          x_msg_data                    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_msg_count                   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
          x_return_status               OUT NOCOPY VARCHAR2  ); --File.Sql.39 bug 4440895

/* dbora - FP M New functions to check for CI
smullapp-Changed NON_APP_STATUSES_EXIST to add p_fin_plan_type_id as input parameter(bug 3899756)
*/
FUNCTION NON_APP_STATUSES_EXIST (
      p_ci_type_id                  IN                   pa_pt_co_impl_statuses.ci_type_id%TYPE,
      p_version_type                IN                   pa_pt_co_impl_statuses.version_type%TYPE,
      p_fin_plan_type_id            IN                   pa_pt_co_impl_statuses.fin_plan_type_id%TYPE)
      RETURN  VARCHAR2;

FUNCTION GET_CI_ALLOWED_IMPACTS (
      p_ci_type_id                  IN                   pa_pt_co_impl_statuses.ci_type_id%TYPE)
      RETURN VARCHAR2;

-- This procedure will reutrn data for populating Plan Summary Region
PROCEDURE get_summary_data
(      p_project_id                  IN       NUMBER
      ,p_cost_version_id             IN       pa_budget_versions.budget_version_id%TYPE  DEFAULT NULL
      ,p_revenue_version_id          IN       pa_budget_versions.budget_version_id%TYPE  DEFAULT NULL
      ,p_page_context                IN       VARCHAR2
      ,p_calling_mode                IN       VARCHAR2 DEFAULT 'APPROVED' --Bug 5278200 kchaitan
      ,x_context                     OUT      NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
      ,x_summary_tbl                 OUT      NOCOPY SYSTEM.PA_VARCHAR2_150_TBL_TYPE --File.Sql.39 bug 4440895
      ,x_url_tbl                     OUT      NOCOPY SYSTEM.PA_VARCHAR2_240_TBL_TYPE --File.Sql.39 bug 4440895
      ,x_reference_tbl               OUT      NOCOPY SYSTEM.PA_VARCHAR2_30_TBL_TYPE --File.Sql.39 bug 4440895
      ,x_equipment_hours_tbl         OUT      NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
      ,x_labor_hours_tbl             OUT      NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
      ,x_cost_tbl                    OUT      NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
      ,x_revenue_tbl                 OUT      NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
      ,x_margin_tbl                  OUT      NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
      ,x_margin_percent_tbl          OUT      NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
      ,x_project_currency_code       OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_report_labor_hrs_code       OUT      NOCOPY VARCHAR2 /* Bug 4038253 */ --File.Sql.39 bug 4440895
      ,x_return_status               OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_msg_count                   OUT      NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,x_msg_data                    OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

-- This procedure will return the revenue amount,
FUNCTION get_labor_qty_partial(
         p_version_type        IN   pa_budget_versions.version_type%TYPE, -- This is the CI version type
         p_budget_version_id   IN   pa_budget_versions.budget_version_id%TYPE,
         p_ci_version_id       IN   pa_budget_versions.budget_version_id%TYPE,
         p_labor_qty           IN   pa_budget_versions.labor_quantity%TYPE DEFAULT NULL, -- CI qty
         p_pt_ct_version_type  IN   pa_pt_co_impl_statuses.version_type%TYPE DEFAULT NULL
         )
RETURN NUMBER;

FUNCTION get_equip_qty_partial(
         p_version_type        IN   pa_budget_versions.version_type%TYPE, -- This is the CI version type
         p_budget_version_id   IN   pa_budget_versions.budget_version_id%TYPE,
         p_ci_version_id       IN   pa_budget_versions.budget_version_id%TYPE,
         p_equip_qty           IN   pa_budget_versions.equipment_quantity%TYPE DEFAULT NULL, -- CI qty
         p_pt_ct_version_type  IN   pa_pt_co_impl_statuses.version_type%TYPE DEFAULT NULL
         )
RETURN NUMBER;

FUNCTION get_pc_revenue_partial (
          p_version_type       IN   pa_budget_versions.version_type%TYPE, -- This is the CI version type
          p_budget_version_id  IN   pa_budget_versions.budget_version_id%TYPE,
          p_ci_version_id      IN   pa_budget_versions.budget_version_id%TYPE,
          p_revenue            IN   pa_budget_versions.total_project_revenue%TYPE DEFAULT NULL,
          p_pt_ct_version_type IN   pa_pt_co_impl_statuses.version_type%TYPE  DEFAULT NULL
          )
RETURN  NUMBER;

FUNCTION get_pc_cost (
          p_version_type       IN   pa_budget_versions.version_type%TYPE, -- This is the CI version type
          p_budget_version_id  IN   pa_budget_versions.budget_version_id%TYPE,
          p_ci_version_id      IN   pa_budget_versions.budget_version_id%TYPE,
          p_raw_cost           IN   pa_budget_versions.total_project_raw_cost%TYPE DEFAULT NULL ,
          p_burdened_cost      IN   pa_budget_versions.total_project_burdened_cost%TYPE DEFAULT NULL,
          p_pt_ct_version_type IN   pa_pt_co_impl_statuses.version_type%TYPE DEFAULT NULL
          )
RETURN  NUMBER;

PROCEDURE get_not_included
(       p_project_id                  IN       NUMBER
       ,p_budget_version_id           IN       pa_budget_versions.budget_version_id%TYPE
       ,p_fin_plan_type_id            IN       pa_budget_versions.fin_plan_type_id%TYPE
       ,p_version_type                IN       pa_budget_versions.version_type%TYPE
       ,x_summary_tbl                 OUT      NOCOPY SYSTEM.PA_VARCHAR2_150_TBL_TYPE --File.Sql.39 bug 4440895
       ,x_equipment_hours_tbl         OUT      NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
       ,x_labor_hours_tbl             OUT      NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
       ,x_cost_tbl                    OUT      NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
       ,x_revenue_tbl                 OUT      NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
       ,x_margin_tbl                  OUT      NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
       ,x_margin_percent_tbl          OUT      NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
       ,x_return_status               OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       ,x_msg_count                   OUT      NOCOPY NUMBER --File.Sql.39 bug 4440895
       ,x_msg_data                    OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

/* FP.M -dbora */
FUNCTION is_impact_exists(p_ci_id     IN       pa_ci_impacts.ci_id%TYPE)
RETURN   VARCHAR2;

FUNCTION is_fin_impact_enabled(p_ci_id        IN       pa_control_items.ci_id%TYPE,
                               p_project_id   IN       pa_projects_all.project_id%TYPE)
RETURN   VARCHAR2;

/* Returns the plan types into which a change order can be implemented along with other information */
-- Added New Params for Quantity in GET_PLAN_TYPES_FOR_IMPL - Bug 3902176
PROCEDURE GET_PLAN_TYPES_FOR_IMPL
       (P_ci_id                 IN      Pa_fin_plan_types_b.fin_plan_type_id%TYPE,      --      Id of the Change Document
        P_project_id            IN      Pa_budget_versions.project_id%TYPE,             --      Id of the Project
        X_pt_id_tbl             OUT     NOCOPY SYSTEM.pa_num_tbl_type,                          --      Plsql table for fin plan type ids --File.Sql.39 bug 4440895
        X_pt_name_tbl           OUT     NOCOPY SYSTEM.pa_varchar2_150_tbl_type,                 --      Plsql table for fin plan type names --File.Sql.39 bug 4440895
        x_cost_impact_impl_tbl  OUT     NOCOPY SYSTEM.pa_varchar2_1_tbl_type, --File.Sql.39 bug 4440895
        x_rev_impact_impl_tbl   OUT     NOCOPY SYSTEM.pa_varchar2_1_tbl_type, --File.Sql.39 bug 4440895
        X_cost_impl_tbl         OUT     NOCOPY SYSTEM.pa_varchar2_1_tbl_type,                   --      Plsql table for Implement Cost Flag --File.Sql.39 bug 4440895
        x_rev_impl_tbl          OUT     NOCOPY SYSTEM.pa_varchar2_1_tbl_type,                   --      Plsql table for Implement Rev Flag --File.Sql.39 bug 4440895
        X_raw_cost_tbl          OUT     NOCOPY SYSTEM.pa_num_tbl_type,                          --      Plsql table for raw cost  --File.Sql.39 bug 4440895
        X_burd_cost_tbl         OUT     NOCOPY SYSTEM.pa_num_tbl_type,                          --      Plsql table for burdened cost  --File.Sql.39 bug 4440895
        X_revenue_tbl           OUT     NOCOPY SYSTEM.pa_num_tbl_type,                          --      Plsql table for revenue  --File.Sql.39 bug 4440895
        X_labor_hrs_c_tbl       OUT     NOCOPY SYSTEM.pa_num_tbl_type,                          --      Plsql table for labor hrs -Cost --File.Sql.39 bug 4440895
        X_equipment_hrs_c_tbl   OUT     NOCOPY SYSTEM.pa_num_tbl_type,                          --      Plsql tabe for equipment hrs -Cost --File.Sql.39 bug 4440895
        X_labor_hrs_r_tbl       OUT     NOCOPY SYSTEM.pa_num_tbl_type,                          --      Plsql table for labor hrs -Rev --File.Sql.39 bug 4440895
        X_equipment_hrs_r_tbl   OUT     NOCOPY SYSTEM.pa_num_tbl_type,                          --      Plsql tabe for equipment hrs -Rev --File.Sql.39 bug 4440895
        X_margin_tbl            OUT     NOCOPY SYSTEM.pa_num_tbl_type,                          --      Plsql table for margin --File.Sql.39 bug 4440895
        X_margin_percent_tbl    OUT     NOCOPY SYSTEM.pa_num_tbl_type,                          --      Plsql table for margin percent   --File.Sql.39 bug 4440895
        X_margin_derived_code_tbl OUT   NOCOPY SYSTEM.pa_varchar2_30_tbl_type,                  --      Plsql table for Margin Derived From Code - Bug 3734840 --File.Sql.39 bug 4440895
        x_approved_fin_pt_id    OUT     NOCOPY Pa_fin_plan_types_b.fin_plan_type_id%TYPE,       --      Contains the ID of the approved plan type --File.Sql.39 bug 4440895
        X_cost_bv_id_tbl        OUT     NOCOPY SYSTEM.pa_num_tbl_type,                          --      Plsql table for cost bv id --File.Sql.39 bug 4440895
        X_rev_bv_id_tbl         OUT     NOCOPY SYSTEM.pa_num_tbl_type,                          --      Plsql table for revenue bv id --File.Sql.39 bug 4440895
        X_all_bv_id_tbl         OUT     NOCOPY SYSTEM.pa_num_tbl_type,                          --      Plsql table for all bv id --File.Sql.39 bug 4440895
        X_select_flag_tbl       OUT     NOCOPY SYSTEM.pa_varchar2_1_tbl_type,                   --      The flag which indicates whether the select flag can be checked by default or not --File.Sql.39 bug 4440895
        X_agreement_num         OUT     NOCOPY Pa_agreements_all.agreement_num%TYPE,           --      Agreement number of the agreement --File.Sql.39 bug 4440895
        X_partially_impl_flag   OUT     NOCOPY VARCHAR2,                                       --      A flag that indicates whether a partially implemented CO exists for the plan type or not. Possible values are Y/N --File.Sql.39 bug 4440895
        X_cost_ci_version_id    OUT     NOCOPY Pa_budget_versions.budget_version_id%TYPE,      --      Ci cost Budget version  id --File.Sql.39 bug 4440895
        X_rev_ci_version_id     OUT     NOCOPY Pa_budget_versions.budget_version_id%TYPE,      --      Ci rev Budget version  id --File.Sql.39 bug 4440895
        X_all_ci_version_id     OUT     NOCOPY Pa_budget_versions.budget_version_id%TYPE,      --      Ci all Budget version  id --File.Sql.39 bug 4440895
        x_rem_proj_revenue      OUT     NOCOPY Pa_budget_versions.total_project_revenue%TYPE,  --      Remaining revenue amount to be implemented --File.Sql.39 bug 4440895
        x_rem_labor_qty         OUT     NOCOPY Pa_budget_versions.labor_quantity%TYPE, --File.Sql.39 bug 4440895
        x_rem_equip_qty         OUT     NOCOPY pa_budget_versions.equipment_quantity%TYPE, --File.Sql.39 bug 4440895
        X_autobaseline_project  OUT     NOCOPY VARCHAR2,                                       --      This flag will be set to Y if the project is enabled for autobaseline --File.Sql.39 bug 4440895
        X_disable_baseline_flag_tbl OUT     NOCOPY SYSTEM.pa_varchar2_1_tbl_type,                   --      Plsql table for Disable Baseline Checkbox Flag --File.Sql.39 bug 4440895
        x_return_status         OUT     NOCOPY VARCHAR2,                                       --      Indicates the exit status of the API --File.Sql.39 bug 4440895
        x_msg_data              OUT     NOCOPY VARCHAR2,                                       --      Indicates the error occurred --File.Sql.39 bug 4440895
        X_msg_count             OUT     NOCOPY NUMBER);                                        --      Indicates the number of error messages --File.Sql.39 bug 4440895


/* Returns the Ids of the versions created for this Change Document. The ID will be -1 if the version can never be there */

PROCEDURE GET_CI_VERSIONS(P_ci_id                   IN   Pa_budget_versions.ci_id%TYPE                  -- Controm item id of the change document
                         ,X_cost_budget_version_id  OUT  NOCOPY Pa_budget_versions.budget_version_id%TYPE      -- ID of the cost version associated with the CI --File.Sql.39 bug 4440895
                         ,X_rev_budget_version_id   OUT  NOCOPY Pa_budget_versions.budget_version_id%TYPE      -- ID of the revenue version associated with the CI --File.Sql.39 bug 4440895
                         ,X_all_budget_version_id   OUT  NOCOPY Pa_budget_versions.budget_version_id%TYPE      -- ID of the all version associated with the CI --File.Sql.39 bug 4440895
                         ,x_return_status           OUT  NOCOPY VARCHAR2                                       -- Indicates the exit status of the API --File.Sql.39 bug 4440895
                         ,x_msg_data                OUT  NOCOPY VARCHAR2                                       -- Indicates the error occurred --File.Sql.39 bug 4440895
                         ,X_msg_count               OUT  NOCOPY NUMBER);                                       -- Indicates the number of error messages --File.Sql.39 bug 4440895

PROCEDURE GET_IMPL_DETAILS(P_fin_plan_type_id        IN   Pa_fin_plan_types_b.fin_plan_type_id%TYPE                  --  Id of the plan type
                          ,P_project_id              IN   Pa_budget_versions.project_id%TYPE                         --  Id of the Project
                          ,P_app_rev_plan_type_flag  IN   pa_budget_versions.approved_rev_plan_type_flag%TYPE   DEFAULT  NULL   --  Indicates whether the plan type passed is approved rev_plan_type or not. If the value is NULL the value will be derived
                          ,P_ci_id                   IN   Pa_budget_versions.ci_id%TYPE                              --  Id of the Change Order
                          ,p_ci_type_id              IN   pa_control_items.ci_type_id%TYPE           DEFAULT  NULL
                          ,P_ci_status               IN   Pa_control_items.status_code%TYPE          DEFAULT  NULL   --  Status of the Change Order
                          ,P_ci_cost_version_id      IN   Pa_budget_versions.budget_version_id%TYPE  DEFAULT  NULL   --  Id of the Cost ci version
                          ,P_ci_rev_version_id       IN   Pa_budget_versions.budget_version_id%TYPE  DEFAULT  NULL   --  Id of the Revenue ci version
                          ,P_ci_all_version_id       IN   Pa_budget_versions.budget_version_id%TYPE  DEFAULT  NULL   --  Id of the All ci version
			           ,p_targ_bv_id              IN   Pa_budget_versions.budget_version_id%TYPE  DEFAULT  NULL   --  Id of the target budget version. Bug 3745163
                          ,x_cost_impl_flag          OUT  NOCOPY VARCHAR2      --             Contains 'Y' if  the cost impact can be implemented  --File.Sql.39 bug 4440895
                          ,x_rev_impl_flag           OUT  NOCOPY VARCHAR2      --             Contains 'Y' if  the rev impact can be implemented --File.Sql.39 bug 4440895
                          ,X_cost_impact_impl_flag   OUT  NOCOPY VARCHAR2      --             Contains 'Y' if the impact is completely implemented --File.Sql.39 bug 4440895
                          ,x_rev_impact_impl_flag    OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                          ,X_partially_impl_flag     OUT  NOCOPY VARCHAR2      --             Can be Y or N. Indicates whether a CI is partially implemented . --File.Sql.39 bug 4440895
                          ,x_agreement_num           OUT  NOCOPY pa_agreements_all.agreement_num%TYPE --File.Sql.39 bug 4440895
                          ,x_approved_fin_pt_id      OUT  NOCOPY Pa_fin_plan_types_b.fin_plan_type_id%TYPE --File.Sql.39 bug 4440895
                          ,x_return_status           OUT  NOCOPY VARCHAR2         --             Indicates the exit status of the API --File.Sql.39 bug 4440895
                          ,x_msg_data                OUT  NOCOPY VARCHAR2         --             Indicates the error occurred --File.Sql.39 bug 4440895
                          ,X_msg_count               OUT  NOCOPY NUMBER);          --             Indicates the number of error messages --File.Sql.39 bug 4440895

--This function returns either Y or N. If the user status code passed exists in pa_pt_co_impl_statuses, meaning
--that there exists a ci type whose change documents can be implemented/included into the working versions of a
--plan type, then Y is returned. N is returned otherwise
FUNCTION  is_user_status_implementable(p_status_code IN pa_control_items.status_code%TYPE)
RETURN VARCHAR2 ;

--This procedure will return the approved cost/rev current working version ids for a project.
--If there is only one version which is approved for both cost and revenue and the same version id will be
--populated in both x_app_cost_cw_ver_id and x_app_rev_cw_ver_id
--If the current working versions do not exist then null will be returned
PROCEDURE get_app_cw_ver_ids_for_proj
(p_project_id                   IN     pa_projects_all.project_id%TYPE,
x_app_cost_cw_ver_id           OUT    NOCOPY pa_budget_versions.budget_version_id%TYPE,  --File.Sql.39 bug 4440895
x_app_rev_cw_ver_id            OUT    NOCOPY pa_budget_versions.budget_version_id%TYPE,  --File.Sql.39 bug 4440895
x_msg_data                     OUT    NOCOPY VARCHAR2,   --File.Sql.39 bug 4440895
x_msg_count                    OUT    NOCOPY NUMBER,      --File.Sql.39 bug 4440895
x_return_status                OUT    NOCOPY VARCHAR2);  --File.Sql.39 bug 4440895

--This API will be called from the View Financial Impact page. This API will return the details required for
--that page
--p_budget_version_id is the target version id with which comparision happens in the view fin impact page. If this
--is available its not required to fetch the approved cost/rev current working ids.
PROCEDURE get_dtls_for_view_fin_imp_pg
(p_project_id                  IN     pa_projects_all.project_id%TYPE,
p_ci_id                        IN     pa_control_items.ci_id%TYPE,
p_ci_cost_version_id           IN     pa_budget_versions.budget_version_id%TYPE,
p_ci_rev_version_id            IN     pa_budget_versions.budget_version_id%TYPE,
p_ci_all_version_id            IN     pa_budget_versions.budget_version_id%TYPE,
p_budget_version_id            IN     pa_budget_versions.budget_version_id%TYPE,
x_app_cost_cw_ver_id           OUT    NOCOPY pa_budget_versions.budget_version_id%TYPE,   --File.Sql.39 bug 4440895
x_app_rev_cw_ver_id            OUT    NOCOPY pa_budget_versions.budget_version_id%TYPE,   --File.Sql.39 bug 4440895
x_ci_status_code               OUT    NOCOPY pa_control_items.status_code%TYPE,  --File.Sql.39 bug 4440895
x_project_currency_code        OUT    NOCOPY pa_projects_all.project_currency_code%TYPE,  --File.Sql.39 bug 4440895
x_impact_in_mc_flag            OUT    NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
x_targ_version_type            OUT    NOCOPY pa_budget_Versions.version_type%TYPE,  --File.Sql.39 bug 4440895
x_show_resources_flag          OUT    NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
x_plan_class_code              OUT    NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
x_report_cost_using            OUT    NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
x_cost_impl_into_app_cw_ver    OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
x_rev_impl_into_app_cw_ver     OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
x_ci_type                      OUT    NOCOPY pa_ci_types_vl.name%TYPE, --File.Sql.39 bug 4440895
x_ci_number                    OUT    NOCOPY pa_control_items.ci_number%TYPE, --File.Sql.39 bug 4440895
x_msg_data                     OUT    NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
x_msg_count                    OUT    NOCOPY NUMBER,  --File.Sql.39 bug 4440895
x_return_status                OUT    NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

/* Bug 3731948- New Function to return the CO amount already implemented
 * for REVENUE implementation in agreement currency
 */
FUNCTION get_impl_agr_revenue (p_project_id   IN     pa_projects_all.project_id%TYPE,
                               p_ci_id        IN     pa_fp_merged_ctrl_items.ci_id%TYPE)
RETURN NUMBER;

	 FUNCTION is_edit_plan_enabled(p_ci_id     IN       pa_ci_impacts.ci_id%TYPE)
 	 RETURN   VARCHAR2;

/* Function returns 'Y' if the change order has been implemented/included into ANY budget version. */
FUNCTION has_co_been_merged(p_ci_id     IN       pa_ci_impacts.ci_id%TYPE)
RETURN   VARCHAR2;

/* This API returns the txn_currency_code and the ci version id of the budget lines of a REVENUE or ALL ci version, if lines exist. Else it returns NULL
   All the lines of a revenue change order version will be in a single currency
*/
PROCEDURE get_txn_curr_code_of_ci_ver(
           p_project_id           IN   pa_projects_all.project_id%TYPE
           ,p_ci_id               IN   pa_budget_versions.ci_id%TYPE
           ,x_txn_currency_code   OUT  NOCOPY pa_budget_lines.txn_currency_code%TYPE --File.Sql.39 bug 4440895
           ,x_budget_version_id   OUT  NOCOPY pa_budget_versions.budget_version_id%TYPE --File.Sql.39 bug 4440895
           ,x_msg_data            OUT  NOCOPY VARCHAR2   --File.Sql.39 bug 4440895
           ,x_msg_count           OUT  NOCOPY NUMBER      --File.Sql.39 bug 4440895
           ,x_return_status       OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
) ;

/* Bug 3927208: DBORA- The following function is to be used by Control Item team, before
 * deleting any CI type from the system, to check if the ci type is being used
 * in any financial plan type context to define implementation/inclusion statuses
 * for financial impact implementation
 */
 FUNCTION validate_fp_ci_type_delete (p_ci_type_id    IN       pa_ci_types_b.ci_type_id%TYPE)
 RETURN VARCHAR2;

-- Bug 5845142
FUNCTION check_valid_combo
(p_project_id                 IN  NUMBER,
 p_targ_app_cost_flag         IN  VARCHAR2,
 p_targ_app_rev_flag          IN  VARCHAR2)
RETURN VARCHAR2;

end Pa_Fp_Control_Items_Utils;

/
