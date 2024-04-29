--------------------------------------------------------
--  DDL for Package PA_FIN_PLAN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FIN_PLAN_PVT" AUTHID CURRENT_USER AS
/* $Header: PAFPPVTS.pls 120.3 2006/06/01 19:55:49 dkuo noship $
   Start of Comments
   Package name     : PA_FIN_PLAN_UTILS
   Purpose          : utility API's for Org Forecast pages
   History          :
   NOTE             :
   End of Comments
*/

  TYPE ci_rec IS RECORD (
       ci_id                    pa_control_items.ci_id%TYPE,
       ci_plan_version_id       pa_budget_versions.budget_version_id%TYPE,
       ci_impact_id             pa_ci_impacts.ci_impact_id%TYPE,
       record_version_number    pa_ci_impacts.record_version_number%TYPE,
       version_type             pa_fp_merged_ctrl_items.version_type%TYPE,
       impl_pfc_raw_cost        pa_fp_merged_ctrl_items.impl_proj_func_raw_cost%TYPE,
       impl_pfc_burd_cost       pa_fp_merged_ctrl_items.impl_proj_func_burdened_cost%TYPE,
       impl_pfc_revenue         pa_fp_merged_ctrl_items.impl_proj_func_revenue%TYPE,
       impl_pc_raw_cost         pa_fp_merged_ctrl_items.impl_proj_raw_cost%TYPE,
       impl_pc_burd_cost        pa_fp_merged_ctrl_items.impl_proj_burdened_cost%TYPE,
       impl_pc_revenue          pa_fp_merged_ctrl_items.impl_proj_revenue%TYPE,
       impl_cost_ppl_qty        pa_fp_merged_ctrl_items.impl_quantity%TYPE,
       impl_cost_equip_qty      pa_fp_merged_ctrl_items.impl_equipment_quantity%TYPE,
       impl_rev_ppl_qty         pa_fp_merged_ctrl_items.impl_quantity%TYPE,
       impl_rev_equip_qty       pa_fp_merged_ctrl_items.impl_equipment_quantity%TYPE,
       impl_agr_revenue         pa_fp_merged_ctrl_items.impl_agr_revenue%TYPE,
       rev_partially_impl_flag  pa_budget_versions.rev_partially_impl_flag%TYPE);


  /* Table definition for constituents of the budget_lines_tab starts */

        TYPE task_id_tab                        is TABLE of     pa_tasks.task_id%TYPE INDEX BY BINARY_INTEGER;
        TYPE resource_list_member_id_tab        is TABLE of     pa_resource_assignments.resource_list_member_id%TYPE INDEX BY BINARY_INTEGER;
        TYPE description_tab                    is TABLE of     pa_budget_lines.description%TYPE INDEX BY BINARY_INTEGER;
        TYPE start_date_tab                     is TABLE of     pa_budget_lines.start_date%TYPE INDEX BY BINARY_INTEGER;
        TYPE end_date_tab                       is TABLE of     pa_budget_lines.end_date%TYPE INDEX BY BINARY_INTEGER;
        TYPE period_name_tab                    is TABLE of     pa_budget_lines.period_name%TYPE INDEX BY BINARY_INTEGER;
        TYPE quantity_tab                       is TABLE of     pa_budget_lines.quantity%TYPE INDEX BY BINARY_INTEGER;
        TYPE unit_of_measure_tab                is TABLE of     pa_resource_assignments.unit_of_measure%TYPE INDEX BY BINARY_INTEGER;
        TYPE track_as_labor_flag_tab            is TABLE of     pa_resource_assignments.track_as_labor_flag%TYPE INDEX BY BINARY_INTEGER;
        TYPE txn_currency_code_tab              is TABLE of     pa_budget_lines.txn_currency_code%TYPE INDEX BY BINARY_INTEGER;
        TYPE raw_cost_tab                       is TABLE of     pa_budget_lines.raw_cost%TYPE INDEX BY BINARY_INTEGER;
        TYPE burdened_cost_tab                  is TABLE of     pa_budget_lines.burdened_cost%TYPE INDEX BY BINARY_INTEGER;
        TYPE revenue_tab                        is TABLE of     pa_budget_lines.revenue%TYPE INDEX BY BINARY_INTEGER;
        TYPE txn_raw_cost_tab                   is TABLE of     pa_budget_lines.txn_raw_cost%TYPE INDEX BY BINARY_INTEGER;
        TYPE txn_burdened_cost_tab              is TABLE of     pa_budget_lines.txn_burdened_cost%TYPE INDEX BY BINARY_INTEGER;
        TYPE txn_revenue_tab                    is TABLE of     pa_budget_lines.txn_revenue%TYPE INDEX BY BINARY_INTEGER;
        TYPE project_raw_cost_tab               is TABLE of     pa_budget_lines.project_raw_cost%TYPE INDEX BY BINARY_INTEGER;
        TYPE project_burdened_cost_tab          is TABLE of     pa_budget_lines.project_burdened_cost%TYPE INDEX BY BINARY_INTEGER;
        TYPE project_revenue_tab                is TABLE of     pa_budget_lines.project_revenue%TYPE INDEX BY BINARY_INTEGER;
        TYPE change_reason_code_tab             is TABLE of     pa_budget_lines.change_reason_code%TYPE INDEX BY BINARY_INTEGER;
        TYPE attribute_category_tab             is TABLE of     pa_budget_lines.attribute_category%TYPE INDEX BY BINARY_INTEGER;
        TYPE attribute1_tab                     is TABLE of     pa_budget_lines.attribute1%TYPE INDEX BY BINARY_INTEGER;
        TYPE attribute2_tab                     is TABLE of     pa_budget_lines.attribute1%TYPE INDEX BY BINARY_INTEGER;
        TYPE attribute3_tab                     is TABLE of     pa_budget_lines.attribute1%TYPE INDEX BY BINARY_INTEGER;
        TYPE attribute4_tab                     is TABLE of     pa_budget_lines.attribute1%TYPE INDEX BY BINARY_INTEGER;
        TYPE attribute5_tab                     is TABLE of     pa_budget_lines.attribute1%TYPE INDEX BY BINARY_INTEGER;
        TYPE attribute6_tab                     is TABLE of     pa_budget_lines.attribute1%TYPE INDEX BY BINARY_INTEGER;
        TYPE attribute7_tab                     is TABLE of     pa_budget_lines.attribute1%TYPE INDEX BY BINARY_INTEGER;
        TYPE attribute8_tab                     is TABLE of     pa_budget_lines.attribute1%TYPE INDEX BY BINARY_INTEGER;
        TYPE attribute9_tab                     is TABLE of     pa_budget_lines.attribute1%TYPE INDEX BY BINARY_INTEGER;
        TYPE attribute10_tab                    is TABLE of     pa_budget_lines.attribute1%TYPE INDEX BY BINARY_INTEGER;
        TYPE attribute11_tab                    is TABLE of     pa_budget_lines.attribute1%TYPE INDEX BY BINARY_INTEGER;
        TYPE attribute12_tab                    is TABLE of     pa_budget_lines.attribute1%TYPE INDEX BY BINARY_INTEGER;
        TYPE attribute13_tab                    is TABLE of     pa_budget_lines.attribute1%TYPE INDEX BY BINARY_INTEGER;
        TYPE attribute14_tab                    is TABLE of     pa_budget_lines.attribute1%TYPE INDEX BY BINARY_INTEGER;
        TYPE attribute15_tab                    is TABLE of     pa_budget_lines.attribute1%TYPE INDEX BY BINARY_INTEGER;
        TYPE PF_COST_RATE_TYPE_tab              is TABLE of     pa_budget_lines.PROJFUNC_COST_RATE_TYPE%TYPE INDEX BY BINARY_INTEGER;
        TYPE PF_COST_RATE_DATE_TYPE_tab         is TABLE of     pa_budget_lines.PROJFUNC_COST_RATE_DATE_TYPE%TYPE INDEX BY BINARY_INTEGER;
        TYPE PF_COST_RATE_DATE_tab              is TABLE of     pa_budget_lines.PROJFUNC_COST_RATE_DATE%TYPE INDEX BY BINARY_INTEGER;
        TYPE PF_COST_RATE_tab                   is TABLE of     pa_budget_lines.PROJFUNC_COST_EXCHANGE_RATE%TYPE INDEX BY BINARY_INTEGER;
        TYPE PF_REV_RATE_TYPE_tab               is TABLE of     pa_budget_lines.PROJFUNC_REV_RATE_TYPE%TYPE INDEX BY BINARY_INTEGER;
        TYPE PF_REV_RATE_DATE_TYPE_tab          is TABLE of     pa_budget_lines.PROJFUNC_REV_RATE_DATE_TYPE%TYPE INDEX BY BINARY_INTEGER;
        TYPE PF_REV_RATE_DATE_tab               is TABLE of     pa_budget_lines.PROJFUNC_REV_RATE_DATE%TYPE INDEX BY BINARY_INTEGER;
        TYPE PF_REV_RATE_tab                    is TABLE of     pa_budget_lines.PROJFUNC_REV_EXCHANGE_RATE%TYPE INDEX BY BINARY_INTEGER;
        TYPE PJ_COST_RATE_TYPE_tab              is TABLE of     pa_budget_lines.PROJECT_COST_RATE_TYPE%TYPE INDEX BY BINARY_INTEGER;
        TYPE PJ_COST_RATE_DATE_TYPE_tab         is TABLE of     pa_budget_lines.PROJECT_COST_RATE_DATE_TYPE%TYPE INDEX BY BINARY_INTEGER;
        TYPE PJ_COST_RATE_DATE_tab              is TABLE of     pa_budget_lines.PROJECT_COST_RATE_DATE%TYPE INDEX BY BINARY_INTEGER;
        TYPE PJ_COST_RATE_tab                   is TABLE of     pa_budget_lines.PROJECT_COST_EXCHANGE_RATE%TYPE INDEX BY BINARY_INTEGER;
        TYPE PJ_REV_RATE_TYPE_tab               is TABLE of     pa_budget_lines.PROJECT_REV_RATE_TYPE%TYPE INDEX BY BINARY_INTEGER;
        TYPE PJ_REV_RATE_DATE_TYPE_tab          is TABLE of     pa_budget_lines.PROJECT_REV_RATE_DATE_TYPE%TYPE INDEX BY BINARY_INTEGER;
        TYPE PJ_REV_RATE_DATE_tab               is TABLE of     pa_budget_lines.PROJECT_REV_RATE_DATE%TYPE INDEX BY BINARY_INTEGER;
        TYPE PJ_REV_RATE_tab                    is TABLE of     pa_budget_lines.PROJECT_REV_EXCHANGE_RATE%TYPE INDEX BY BINARY_INTEGER;
        TYPE pm_product_code_tab                is TABLE of     pa_budget_lines.pm_product_code%TYPE INDEX BY BINARY_INTEGER;
        TYPE pm_budget_line_reference_tab       is TABLE of     pa_budget_lines.pm_budget_line_reference%TYPE INDEX BY BINARY_INTEGER;
        TYPE quantity_source_tab                is TABLE of     pa_budget_lines.quantity_source%TYPE INDEX BY BINARY_INTEGER;
        TYPE raw_cost_source_tab                is TABLE of     pa_budget_lines.raw_cost_source%TYPE INDEX BY BINARY_INTEGER;
        TYPE burdened_cost_source_tab           is TABLE of     pa_budget_lines.burdened_cost_source%TYPE INDEX BY BINARY_INTEGER;
        TYPE revenue_source_tab                 is TABLE of     pa_budget_lines.revenue_source%TYPE INDEX BY BINARY_INTEGER;
        TYPE resource_assignment_id_tab         is TABLE of     pa_budget_lines.resource_assignment_id%TYPE INDEX BY BINARY_INTEGER;

  /* Table definition for constituents of the budget_lines_tab ends */

  TYPE budget_lines_tab is TABLE of pa_fp_rollup_tmp%ROWTYPE INDEX BY BINARY_INTEGER;

  TYPE ci_rec_tab is TABLE of ci_rec INDEX BY BINARY_INTEGER;

  TYPE number_type_tab IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

  TYPE date_type_tab IS TABLE OF DATE INDEX BY BINARY_INTEGER;

  TYPE char240_type_tab IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;

check_wf_error          EXCEPTION;
start_wf_error          EXCEPTION;
baseline_finplan_error  EXCEPTION;
--g_ci_rec_tab          pa_fin_plan_pvt.ci_rec_tab;  Commented for bug 2672654


PROCEDURE lock_unlock_version
    (p_budget_version_id      IN  pa_budget_versions.budget_version_id%TYPE,
     p_record_version_number  IN  pa_budget_versions.record_version_number%TYPE,
     p_action                 IN  VARCHAR2, -- 'L' for lock, 'U' for unlock
     p_user_id                IN  NUMBER,
     p_person_id              IN  NUMBER,  -- can be null
     x_return_status          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     p_unlock_locked_ver_flag IN  VARCHAR2 DEFAULT NULL);


PROCEDURE Baseline_FinPlan
    (p_project_id                 IN    pa_budget_versions.project_id%TYPE,
     p_budget_version_id          IN    pa_budget_versions.budget_version_id%TYPE,
     p_record_version_number      IN    pa_budget_versions.record_version_number%TYPE,
     p_orig_budget_version_id     IN    pa_budget_versions.budget_version_id%TYPE default null,
     p_orig_record_version_number IN    pa_budget_versions.record_version_number%TYPE default null,
     p_verify_budget_rules        IN    VARCHAR2 DEFAULT 'Y',
     x_fc_version_created_flag    OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_return_status              OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                  OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                   OUT   NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Submit_Current_Working_FinPlan
    (p_project_id               IN      pa_budget_versions.project_id%TYPE,
     p_budget_version_id        IN      pa_budget_versions.budget_version_id%TYPE,
     p_record_version_number    IN      pa_budget_versions.record_version_number%TYPE,
     x_return_status            OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                 OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Get_Included_Ci
    ( p_from_bv_id     IN pa_budget_versions.budget_version_id%TYPE
     ,p_to_bv_id       IN pa_budget_versions.budget_version_id%TYPE DEFAULT NULL
     ,p_impact_status  IN pa_ci_impacts.status_code%TYPE DEFAULT NULL
     ,x_ci_rec_tab    OUT NOCOPY pa_fin_plan_pvt.ci_rec_tab
     ,x_return_status OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count     OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data      OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE handle_ci_links
    ( p_source_bv_id   IN pa_budget_versions.budget_version_id%TYPE
     ,p_target_bv_id   IN pa_budget_versions.budget_version_id%TYPE
     ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data      OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE CREATE_DRAFT
   (  p_project_id                      IN      pa_budget_versions.project_id%TYPE
     ,p_fin_plan_type_id                IN      pa_budget_versions.fin_plan_type_id%TYPE
     ,p_version_type                    IN      pa_budget_versions.version_type%TYPE
     -- Bug Fix: 4569365. Removed MRC code.
     --,p_calling_context                 IN      pa_mrc_finplan.g_calling_module%TYPE
     ,p_calling_context                 IN      VARCHAR2
     ,p_time_phased_code                IN      pa_proj_fp_options.cost_time_phased_code%TYPE
     ,p_resource_list_id                IN      pa_budget_versions.resource_list_id%TYPE
     ,p_fin_plan_level_code             IN      pa_proj_fp_options.cost_fin_plan_level_code%TYPE
     ,p_plan_in_mc_flag                 IN      pa_proj_fp_options.plan_in_multi_curr_flag%TYPE
     ,p_version_name                    IN      pa_budget_versions.version_name%TYPE
     ,p_description                     IN      pa_budget_versions.description%TYPE
     ,p_change_reason_code              IN      pa_budget_versions.change_reason_code%TYPE
     ,p_raw_cost_flag                   IN      pa_fin_plan_amount_sets.raw_cost_flag%TYPE
     ,p_burdened_cost_flag              IN      pa_fin_plan_amount_sets.burdened_cost_flag%TYPE
     ,p_revenue_flag                    IN      pa_fin_plan_amount_sets.revenue_flag%TYPE
     ,p_cost_qty_flag                   IN      pa_fin_plan_amount_sets.cost_qty_flag%TYPE
     ,p_revenue_qty_flag                IN      pa_fin_plan_amount_sets.revenue_qty_flag%TYPE
     ,p_all_qty_flag                    IN      pa_fin_plan_amount_sets.all_qty_flag%TYPE
     ,p_attribute_category              IN      pa_budget_versions.attribute_category%TYPE
     ,p_attribute1                      IN      pa_budget_versions.attribute1%TYPE
     ,p_attribute2                      IN      pa_budget_versions.attribute2%TYPE
     ,p_attribute3                      IN      pa_budget_versions.attribute3%TYPE
     ,p_attribute4                      IN      pa_budget_versions.attribute4%TYPE
     ,p_attribute5                      IN      pa_budget_versions.attribute5%TYPE
     ,p_attribute6                      IN      pa_budget_versions.attribute6%TYPE
     ,p_attribute7                      IN      pa_budget_versions.attribute7%TYPE
     ,p_attribute8                      IN      pa_budget_versions.attribute8%TYPE
     ,p_attribute9                      IN      pa_budget_versions.attribute9%TYPE
     ,p_attribute10                     IN      pa_budget_versions.attribute10%TYPE
     ,p_attribute11                     IN      pa_budget_versions.attribute11%TYPE
     ,p_attribute12                     IN      pa_budget_versions.attribute12%TYPE
     ,p_attribute13                     IN      pa_budget_versions.attribute13%TYPE
     ,p_attribute14                     IN      pa_budget_versions.attribute14%TYPE
     ,p_attribute15                     IN      pa_budget_versions.attribute15%TYPE
     ,p_projfunc_cost_rate_type         IN      pa_proj_fp_options.projfunc_cost_rate_type%TYPE
     ,p_projfunc_cost_rate_date_type    IN      pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE
     ,p_projfunc_cost_rate_date         IN      pa_proj_fp_options.projfunc_cost_rate_date%TYPE
     ,p_projfunc_rev_rate_type          IN      pa_proj_fp_options.projfunc_rev_rate_type%TYPE
     ,p_projfunc_rev_rate_date_type     IN      pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE
     ,p_projfunc_rev_rate_date          IN      pa_proj_fp_options.projfunc_rev_rate_date%TYPE
     ,p_project_cost_rate_type          IN      pa_proj_fp_options.project_cost_rate_type%TYPE
     ,p_project_cost_rate_date_type     IN      pa_proj_fp_options.project_cost_rate_date_type%TYPE
     ,p_project_cost_rate_date          IN      pa_proj_fp_options.project_cost_rate_date%TYPE
     ,p_project_rev_rate_type           IN      pa_proj_fp_options.project_rev_rate_type%TYPE
     ,p_project_rev_rate_date_type      IN      pa_proj_fp_options.project_rev_rate_date_type%TYPE
     ,p_project_rev_rate_date           IN      pa_proj_fp_options.project_rev_rate_date%TYPE
     ,p_pm_product_code                 IN      pa_budget_versions.pm_product_code%TYPE
     ,p_pm_budget_reference             IN      pa_budget_versions.pm_budget_reference%TYPE
     ,p_budget_lines_tab                IN      pa_fin_plan_pvt.budget_lines_tab
    -- Start of additional columns for Bug :- 2634900
     ,p_ci_id                           IN     pa_budget_versions.ci_id%TYPE                    := NULL
     ,p_est_proj_raw_cost               IN     pa_budget_versions.est_project_raw_cost%TYPE     := NULL
     ,p_est_proj_bd_cost                IN     pa_budget_versions.est_project_burdened_cost%TYPE:= NULL
     ,p_est_proj_revenue                IN     pa_budget_versions.est_project_revenue%TYPE      := NULL
     ,p_est_qty                         IN     pa_budget_versions.est_quantity%TYPE             := NULL
     ,p_est_equip_qty                   IN     pa_budget_versions.est_equipment_quantity%TYPE   := NULL
     ,p_impacted_task_id                IN     pa_tasks.task_id%TYPE                            := NULL
     ,p_agreement_id                    IN     pa_budget_versions.agreement_id%TYPE             := NULL
    -- End of additional columns for Bug :- 2634900
    --Added the two flags below as part of changes to AMG for finplan model
     ,p_create_new_curr_working_flag    IN     VARCHAR2
     ,p_replace_current_working_flag    IN     VARCHAR2
     ,x_budget_version_id               OUT    NOCOPY pa_budget_versions.budget_version_id%TYPE --File.Sql.39 bug 4440895
     ,x_return_status                   OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                       OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                        OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     );

    /* Bug# 2674353 - Added p_calling_context */

    PROCEDURE CREATE_FINPLAN_LINES
    ( -- Bug Fix: 4569365. Removed MRC code.
      -- p_calling_context         IN      pa_mrc_finplan.g_calling_module%TYPE
      p_calling_context         IN      VARCHAR2
     ,p_fin_plan_version_id     IN      pa_budget_versions.budget_version_id%TYPE
     ,p_budget_lines_tab        IN      pa_fin_plan_pvt.budget_lines_tab
     ,x_return_status           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count               OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

   FUNCTION Fetch_Plan_Type_Id
    (p_fin_plan_type_name pa_fin_plan_types_tl.name%TYPE) RETURN NUMBER ;

   PROCEDURE convert_plan_type_name_to_id
    ( p_fin_plan_type_id    IN  pa_fin_plan_types_b.fin_plan_type_id%TYPE
     ,p_fin_plan_type_name  IN  pa_fin_plan_types_tl.name%TYPE
     ,x_fin_plan_type_id    OUT NOCOPY pa_fin_plan_types_b.fin_plan_type_id%TYPE  --File.Sql.39 bug 4440895
     ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data            OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
     );

/*=====================================================================
Procedure Name:      DELETE_WP_OPTION
This procedure is added as part of FPM Development. Trackinb Bug - 3354518.
Purpose:             This api Deletes the proj fp options data pertaining
                      to the workplan type attached to the project for
                      the passed project id.
                      Deletes data from the following tables -
                        1)   pa_proj_fp_options
                        2)   pa_fp_txn_currencies
                        3)   pa_proj_period_profiles
                        4)   pa_fp_upgrade_audit

Please note that all validations before calling this API shall be done
in the calling entity.

Parameters:
IN                   1) p_project_id - project id.
=======================================================================*/
   PROCEDURE Delete_wp_option
     (p_project_id           IN    PA_PROJECTS_ALL.PROJECT_ID%TYPE
     ,x_return_status        OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count            OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data             OUT   NOCOPY VARCHAR2); --File.Sql.39 bug 4440895



/*=====================================================================
Procedure Name:      DELETE_WP_BUDGET_VERSIONS
This procedure is added as part of FPM Development. Trackinb Bug - 3354518.
Purpose:              This API deletes the budget_versions for all the
                      workplan structure version ids passed.

Parameters:
IN                   1)p_struct_elem_version_id_tbl IN SYSTEM.pa_num_tbl_typ
=======================================================================*/
  PROCEDURE Delete_wp_budget_versions
     (p_struct_elem_version_id_tbl IN    SYSTEM.pa_num_tbl_type
     ,x_return_status              OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                  OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                   OUT   NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*=====================================================================
Procedure Name:      ADD_FIN_PLAN_LINES
This procedure is added as part of B and F AMG API changes. Tracking Bug - 3507156.
Purpose:              This API calls the following apis :
                      1) PA_FIN_PLAN_PVT.CREATE_FINPLAN_LINES
                      2) PA_FP_CALC_PLAN_PKG.CALCULATE
                      3) PJI_FM_XBS_ACCUM_MAINT.PLAN_CREATE
Parameters:
IN                   1)p_calling_context IN pa_mrc_finplan.g_calling_module%TYPE
                     2)p_fin_plan_version_id IN pa_budget_versions.budget_version_id%TYPE
                     3)p_finplan_lines_tab IN pa_fin_plan_pvt.budget_lines_tab
=======================================================================*/
  PROCEDURE ADD_FIN_PLAN_LINES
    ( -- Bug Fix: 4569365. Removed MRC code.
	  -- p_calling_context         IN      pa_mrc_finplan.g_calling_module%TYPE
	  p_calling_context         IN      VARCHAR2
     ,p_fin_plan_version_id     IN      pa_budget_versions.budget_version_id%TYPE
     ,p_finplan_lines_tab       IN      pa_fin_plan_pvt.budget_lines_tab
     ,x_return_status           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count               OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                OUT     NOCOPY VARCHAR2);  --File.Sql.39 bug 4440895

END pa_fin_plan_pvt;

 

/
