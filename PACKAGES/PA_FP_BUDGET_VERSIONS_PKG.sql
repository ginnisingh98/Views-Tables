--------------------------------------------------------
--  DDL for Package PA_FP_BUDGET_VERSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_BUDGET_VERSIONS_PKG" AUTHID CURRENT_USER as
/* $Header: PAFPBVTS.pls 120.1 2005/08/19 16:24:21 mwasowic noship $ */
-- Start of Comments
-- Package name     : PA_FP_BUDGET_VERSIONS_PKG
-- Purpose          :
-- History          :
-- 31-OCT-2002    rravipat   Modified the Insert_Row and Update_Row apis
--                           to include the newly added columns for
--                           Bug:- 2634900
--
--   26-JUN-2003 jwhite        - Plannable Task Dev Effort:
--                               For the Insert_Row procedure, add the
--                               following IN-parameters:
--                               1) p_refresh_required_flag
--   29-JAN-2003 rravipat      - Bug 2634900 (IDC)
--                               Included new columns for FP M Doosan.
--   02-APR-2004 dbora           FP.M Added p_est_equip_qty in parameter in
--                               Insert_Row and Update_Row
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row
( px_budget_version_id       IN OUT NOCOPY pa_budget_versions.budget_version_id%TYPE  --File.Sql.39 bug 4440895
 ,p_project_id                   IN pa_budget_versions.project_id%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_budget_type_code             IN pa_budget_versions.budget_type_code%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_version_number               IN pa_budget_versions.version_number%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_budget_status_code           IN pa_budget_versions.budget_status_code%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_current_flag                 IN pa_budget_versions.current_flag%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_original_flag                IN pa_budget_versions.original_flag%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_current_original_flag        IN pa_budget_versions.current_original_flag%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_resource_accumulated_flag    IN pa_budget_versions.resource_accumulated_flag%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_resource_list_id             IN pa_budget_versions.resource_list_id%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_version_name                 IN pa_budget_versions.version_name%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_budget_entry_method_code     IN pa_budget_versions.budget_entry_method_code%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_baselined_by_person_id       IN pa_budget_versions.baselined_by_person_id%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_baselined_date               IN pa_budget_versions.baselined_date%TYPE
                                    := FND_API.G_MISS_DATE
 ,p_change_reason_code           IN pa_budget_versions.change_reason_code%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_labor_quantity               IN pa_budget_versions.labor_quantity%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_labor_unit_of_measure        IN pa_budget_versions.labor_unit_of_measure%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_raw_cost                     IN pa_budget_versions.raw_cost%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_burdened_cost                IN pa_budget_versions.burdened_cost%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_revenue                      IN pa_budget_versions.revenue%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_description                  IN pa_budget_versions.description%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute_category           IN pa_budget_versions.attribute_category%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute1                   IN pa_budget_versions.attribute1%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute2                   IN pa_budget_versions.attribute2%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute3                   IN pa_budget_versions.attribute3%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute4                   IN pa_budget_versions.attribute4%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute5                   IN pa_budget_versions.attribute5%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute6                   IN pa_budget_versions.attribute6%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute7                   IN pa_budget_versions.attribute7%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute8                   IN pa_budget_versions.attribute8%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute9                   IN pa_budget_versions.attribute9%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute10                  IN pa_budget_versions.attribute10%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute11                  IN pa_budget_versions.attribute11%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute12                  IN pa_budget_versions.attribute12%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute13                  IN pa_budget_versions.attribute13%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute14                  IN pa_budget_versions.attribute14%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute15                  IN pa_budget_versions.attribute15%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_first_budget_period          IN pa_budget_versions.first_budget_period%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_pm_product_code              IN pa_budget_versions.pm_product_code%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_pm_budget_reference          IN pa_budget_versions.pm_budget_reference%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_wf_status_code               IN pa_budget_versions.wf_status_code%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_adw_notify_flag              IN pa_budget_versions.adw_notify_flag%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_prc_generated_flag           IN pa_budget_versions.prc_generated_flag%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_plan_run_date                IN pa_budget_versions.plan_run_date%TYPE
                                    := FND_API.G_MISS_DATE
 ,p_plan_processing_code         IN pa_budget_versions.plan_processing_code%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_period_profile_id            IN pa_budget_versions.period_profile_id%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_fin_plan_type_id             IN pa_budget_versions.fin_plan_type_id%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_parent_plan_version_id       IN pa_budget_versions.parent_plan_version_id%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_project_structure_version_id IN pa_budget_versions.project_structure_version_id%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_current_working_flag         IN pa_budget_versions.current_working_flag%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_total_borrowed_revenue       IN pa_budget_versions.total_borrowed_revenue%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_tp_revenue_in          IN pa_budget_versions.total_tp_revenue_in%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_tp_revenue_out         IN pa_budget_versions.total_tp_revenue_out%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_revenue_adj            IN pa_budget_versions.total_revenue_adj%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_lent_resource_cost     IN pa_budget_versions.total_lent_resource_cost%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_tp_cost_in             IN pa_budget_versions.total_tp_cost_in%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_tp_cost_out            IN pa_budget_versions.total_tp_cost_out%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_cost_adj               IN pa_budget_versions.total_cost_adj%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_unassigned_time_cost   IN pa_budget_versions.total_unassigned_time_cost%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_utilization_percent    IN pa_budget_versions.total_utilization_percent%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_utilization_hours      IN pa_budget_versions.total_utilization_hours%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_utilization_adj        IN pa_budget_versions.total_utilization_adj%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_capacity               IN pa_budget_versions.total_capacity%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_head_count             IN pa_budget_versions.total_head_count%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_head_count_adj         IN pa_budget_versions.total_head_count_adj%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_version_type                 IN pa_budget_versions.version_type%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_request_id                   IN pa_budget_versions.request_id%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_project_raw_cost       IN pa_budget_versions.total_project_raw_cost%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_project_burdened_cost	 IN pa_budget_versions.total_project_burdened_cost%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_project_revenue	 IN pa_budget_versions.total_project_revenue%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_locked_by_person_id 	 IN pa_budget_versions.locked_by_person_id%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_approved_cost_plan_type_flag IN pa_budget_versions.approved_cost_plan_type_flag%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_approved_rev_plan_type_flag	 IN pa_budget_versions.approved_rev_plan_type_flag%TYPE
                                    := FND_API.G_MISS_CHAR
-- start of changes of Bug:- 2634900
 ,p_est_project_raw_cost         IN pa_budget_versions.est_project_raw_cost%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_est_project_burdened_cost    IN pa_budget_versions.est_project_burdened_cost%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_est_project_revenue          IN pa_budget_versions.est_project_revenue%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_est_quantity                 IN pa_budget_versions.est_quantity%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_est_equip_qty                IN pa_budget_versions.est_equipment_quantity%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_est_projfunc_raw_cost        IN pa_budget_versions.est_projfunc_raw_cost%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_est_projfunc_burdened_cost   IN pa_budget_versions.est_projfunc_burdened_cost%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_est_projfunc_revenue         IN pa_budget_versions.est_projfunc_revenue%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_ci_id                        IN pa_budget_versions.ci_id%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_agreement_id                 IN pa_budget_versions.agreement_id%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_refresh_required_flag        IN pa_budget_versions.PROCESS_UPDATE_WBS_FLAG%TYPE
                                    := FND_API.G_MISS_CHAR
-- end of changes of Bug:- 2634900
-- Bug 3354518: start of new columns for FP-M
,p_object_type_code              IN   pa_budget_versions.object_type_code%TYPE
                                    := FND_API.G_MISS_CHAR
,p_object_id                     IN   pa_budget_versions.object_id%TYPE
                                    := FND_API.G_MISS_NUM
,p_primary_cost_forecast_flag    IN   pa_budget_versions.primary_cost_forecast_flag%TYPE
                                    := FND_API.G_MISS_CHAR
,p_primary_rev_forecast_flag     IN   pa_budget_versions.primary_rev_forecast_flag%TYPE
                                    := FND_API.G_MISS_CHAR
,p_rev_partially_impl_flag       IN   pa_budget_versions.rev_partially_impl_flag%TYPE
                                    := FND_API.G_MISS_CHAR
,p_equipment_quantity            IN   pa_budget_versions.equipment_quantity%TYPE
                                    := FND_API.G_MISS_NUM
,p_pji_summarized_flag           IN   pa_budget_versions.pji_summarized_flag%TYPE
                                    := FND_API.G_MISS_CHAR
,p_wp_version_flag               IN   pa_budget_versions.wp_version_flag%TYPE
                                    := FND_API.G_MISS_CHAR
,p_current_planning_period       IN   pa_budget_versions.current_planning_period%TYPE
                                    := FND_API.G_MISS_CHAR
,p_period_mask_id                IN   pa_budget_versions.period_mask_id%TYPE
                                    := FND_API.G_MISS_NUM
,p_last_amt_gen_date             IN   pa_budget_versions.last_amt_gen_date%TYPE
                                    := FND_API.G_MISS_DATE
,p_actual_amts_thru_period       IN   pa_budget_versions.actual_amts_thru_period%TYPE
                                    := FND_API.G_MISS_CHAR
-- Bug 3354518: end of new columns for FP-M

 ,x_row_id                      OUT NOCOPY ROWID --File.Sql.39 bug 4440895
 ,x_return_status               OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Update_Row
( p_budget_version_id            IN pa_budget_versions.budget_version_id%TYPE
 ,p_record_version_number        IN NUMBER
                                    := NULL
 ,p_project_id                   IN pa_budget_versions.project_id%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_budget_type_code             IN pa_budget_versions.budget_type_code%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_version_number               IN pa_budget_versions.version_number%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_budget_status_code           IN pa_budget_versions.budget_status_code%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_current_flag                 IN pa_budget_versions.current_flag%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_original_flag                IN pa_budget_versions.original_flag%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_current_original_flag        IN pa_budget_versions.current_original_flag%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_resource_accumulated_flag    IN pa_budget_versions.resource_accumulated_flag%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_resource_list_id             IN pa_budget_versions.resource_list_id%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_version_name                 IN pa_budget_versions.version_name%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_budget_entry_method_code     IN pa_budget_versions.budget_entry_method_code%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_baselined_by_person_id       IN pa_budget_versions.baselined_by_person_id%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_baselined_date               IN pa_budget_versions.baselined_date%TYPE
                                    := FND_API.G_MISS_DATE
 ,p_change_reason_code           IN pa_budget_versions.change_reason_code%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_labor_quantity               IN pa_budget_versions.labor_quantity%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_labor_unit_of_measure        IN pa_budget_versions.labor_unit_of_measure%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_raw_cost                     IN pa_budget_versions.raw_cost%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_burdened_cost                IN pa_budget_versions.burdened_cost%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_revenue                      IN pa_budget_versions.revenue%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_description                  IN pa_budget_versions.description%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute_category           IN pa_budget_versions.attribute_category%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute1                   IN pa_budget_versions.attribute1%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute2                   IN pa_budget_versions.attribute2%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute3                   IN pa_budget_versions.attribute3%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute4                   IN pa_budget_versions.attribute4%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute5                   IN pa_budget_versions.attribute5%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute6                   IN pa_budget_versions.attribute6%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute7                   IN pa_budget_versions.attribute7%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute8                   IN pa_budget_versions.attribute8%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute9                   IN pa_budget_versions.attribute9%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute10                  IN pa_budget_versions.attribute10%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute11                  IN pa_budget_versions.attribute11%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute12                  IN pa_budget_versions.attribute12%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute13                  IN pa_budget_versions.attribute13%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute14                  IN pa_budget_versions.attribute14%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_attribute15                  IN pa_budget_versions.attribute15%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_first_budget_period          IN pa_budget_versions.first_budget_period%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_pm_product_code              IN pa_budget_versions.pm_product_code%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_pm_budget_reference          IN pa_budget_versions.pm_budget_reference%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_wf_status_code               IN pa_budget_versions.wf_status_code%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_adw_notify_flag              IN pa_budget_versions.adw_notify_flag%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_prc_generated_flag           IN pa_budget_versions.prc_generated_flag%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_plan_run_date                IN pa_budget_versions.plan_run_date%TYPE
                                    := FND_API.G_MISS_DATE
 ,p_plan_processing_code         IN pa_budget_versions.plan_processing_code%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_period_profile_id            IN pa_budget_versions.period_profile_id%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_fin_plan_type_id             IN pa_budget_versions.fin_plan_type_id%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_parent_plan_version_id       IN pa_budget_versions.parent_plan_version_id%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_project_structure_version_id IN pa_budget_versions.project_structure_version_id%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_current_working_flag         IN pa_budget_versions.current_working_flag%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_total_borrowed_revenue       IN pa_budget_versions.total_borrowed_revenue%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_tp_revenue_in          IN pa_budget_versions.total_tp_revenue_in%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_tp_revenue_out         IN pa_budget_versions.total_tp_revenue_out%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_revenue_adj            IN pa_budget_versions.total_revenue_adj%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_lent_resource_cost     IN pa_budget_versions.total_lent_resource_cost%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_tp_cost_in             IN pa_budget_versions.total_tp_cost_in%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_tp_cost_out            IN pa_budget_versions.total_tp_cost_out%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_cost_adj               IN pa_budget_versions.total_cost_adj%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_unassigned_time_cost   IN pa_budget_versions.total_unassigned_time_cost%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_utilization_percent    IN pa_budget_versions.total_utilization_percent%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_utilization_hours      IN pa_budget_versions.total_utilization_hours%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_utilization_adj        IN pa_budget_versions.total_utilization_adj%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_capacity               IN pa_budget_versions.total_capacity%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_head_count             IN pa_budget_versions.total_head_count%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_head_count_adj         IN pa_budget_versions.total_head_count_adj%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_version_type                 IN pa_budget_versions.version_type%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_request_id                   IN pa_budget_versions.request_id%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_project_raw_cost       IN pa_budget_versions.total_project_raw_cost%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_project_burdened_cost	 IN pa_budget_versions.total_project_burdened_cost%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_total_project_revenue	 IN pa_budget_versions.total_project_revenue%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_locked_by_person_id 	 IN pa_budget_versions.locked_by_person_id%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_approved_cost_plan_type_flag IN pa_budget_versions.approved_cost_plan_type_flag%TYPE
                                    := FND_API.G_MISS_CHAR
 ,p_approved_rev_plan_type_flag	 IN pa_budget_versions.approved_rev_plan_type_flag%TYPE
                                    := FND_API.G_MISS_CHAR
-- start of changes of Bug:- 2634900
 ,p_est_project_raw_cost         IN pa_budget_versions.est_project_raw_cost%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_est_project_burdened_cost    IN pa_budget_versions.est_project_burdened_cost%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_est_project_revenue          IN pa_budget_versions.est_project_revenue%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_est_quantity                 IN pa_budget_versions.est_quantity%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_est_equip_qty                IN pa_budget_versions.est_equipment_quantity%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_est_projfunc_raw_cost        IN pa_budget_versions.est_projfunc_raw_cost%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_est_projfunc_burdened_cost   IN pa_budget_versions.est_projfunc_burdened_cost%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_est_projfunc_revenue         IN pa_budget_versions.est_projfunc_revenue%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_ci_id                        IN pa_budget_versions.ci_id%TYPE
                                    := FND_API.G_MISS_NUM
 ,p_agreement_id                 IN pa_budget_versions.agreement_id%TYPE
                                    := FND_API.G_MISS_NUM
-- end of changes of Bug:- 2634900
-- Bug 3354518: start of new columns for FP-M
,p_object_type_code              IN   pa_budget_versions.object_type_code%TYPE
                                    := FND_API.G_MISS_CHAR
,p_object_id                     IN   pa_budget_versions.object_id%TYPE
                                    := FND_API.G_MISS_NUM
,p_primary_cost_forecast_flag    IN   pa_budget_versions.primary_cost_forecast_flag%TYPE
                                    := FND_API.G_MISS_CHAR
,p_primary_rev_forecast_flag     IN   pa_budget_versions.primary_rev_forecast_flag%TYPE
                                    := FND_API.G_MISS_CHAR
,p_rev_partially_impl_flag       IN   pa_budget_versions.rev_partially_impl_flag%TYPE
                                    := FND_API.G_MISS_CHAR
,p_equipment_quantity            IN   pa_budget_versions.equipment_quantity%TYPE
                                    := FND_API.G_MISS_NUM
,p_pji_summarized_flag           IN   pa_budget_versions.pji_summarized_flag%TYPE
                                    := FND_API.G_MISS_CHAR
,p_wp_version_flag               IN   pa_budget_versions.wp_version_flag%TYPE
                                    := FND_API.G_MISS_CHAR
,p_current_planning_period       IN   pa_budget_versions.current_planning_period%TYPE
                                    := FND_API.G_MISS_CHAR
,p_period_mask_id                IN   pa_budget_versions.period_mask_id%TYPE
                                    := FND_API.G_MISS_NUM
,p_last_amt_gen_date             IN   pa_budget_versions.last_amt_gen_date%TYPE
                                    := FND_API.G_MISS_DATE
,p_actual_amts_thru_period       IN   pa_budget_versions.actual_amts_thru_period%TYPE
                                    := FND_API.G_MISS_CHAR
-- Bug 3354518: end of new columns for FP-M
 ,p_row_id                       IN ROWID
                                    := NULL
 ,x_return_status               OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Lock_Row
( p_budget_version_id            IN pa_budget_versions.budget_version_id%TYPE
 ,p_record_version_number        IN NUMBER
                                    := NULL
 ,p_row_id                       IN ROWID
                                    := NULL
 ,x_return_status               OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Delete_Row
( p_budget_version_id            IN pa_budget_versions.budget_version_id%TYPE
 ,p_record_version_number        IN NUMBER
                                    := NULL
 ,p_row_id                       IN ROWID
                                    := NULL
 ,x_return_status               OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END pa_fp_budget_versions_pkg;

 

/
