--------------------------------------------------------
--  DDL for Package Body PA_FP_BUDGET_VERSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_FP_BUDGET_VERSIONS_PKG" as
/* $Header: PAFPBVTB.pls 120.1 2005/08/19 16:24:16 mwasowic noship $ */
-- Start of Comments
-- Package name     : PA_FP_BUDGET_VERSIONS_PKG
-- Purpose          :
-- History          :
-- 31-OCT-2002    rravipat   Modified the Insert_Row and Update_Row apis
--                           to include the newly added columns
--                           for Bug:- 2634900
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PA_FP_BUDGET_VERSIONS_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pafpbvtb.pls';

PROCEDURE Insert_Row
(px_budget_version_id        IN OUT NOCOPY pa_budget_versions.budget_version_id%TYPE  --File.Sql.39 bug 4440895
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
 ,x_return_status               OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895

 IS
   CURSOR C2 IS select pa_budget_versions_s.nextval FROM sys.dual;

BEGIN

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF (px_budget_version_id IS NULL) OR (px_budget_version_id =
                                        FND_API.G_MISS_NUM) THEN
       OPEN C2;
       FETCH C2 INTO px_budget_version_id;
       CLOSE C2;
   END IF;

   INSERT INTO pa_budget_versions(
           budget_version_id
          ,record_version_number
          ,project_id
          ,budget_type_code
          ,version_number
          ,budget_status_code
          ,last_update_date
          ,last_updated_by
          ,creation_date
          ,created_by
          ,last_update_login
          ,current_flag
          ,original_flag
          ,current_original_flag
          ,resource_accumulated_flag
          ,resource_list_id
          ,version_name
          ,budget_entry_method_code
          ,baselined_by_person_id
          ,baselined_datE
          ,change_reason_code
          ,labor_quantity
          ,labor_unit_of_measure
          ,raw_cosT
          ,burdened_cost
          ,revenue
          ,description
          ,attribute_category
          ,attribute1
          ,attribute2
          ,attribute3
          ,attribute4
          ,attribute5
          ,attribute6
          ,attribute7
          ,attribute8
          ,attribute9
          ,attribute10
          ,attribute11
          ,attribute12
          ,attribute13
          ,attribute14
          ,attribute15
          ,first_budget_period
          ,pm_product_code
          ,pm_budget_reference
          ,wf_status_code
          ,adw_notify_flag
          ,prc_generated_flag
          ,plan_run_date
          ,plan_processing_code
          ,period_profile_id
          ,fin_plan_type_id
          ,parent_plan_version_id
          ,project_structure_version_id
          ,current_working_flag
          ,total_borrowed_revenue
          ,total_tp_revenue_in
          ,total_tp_revenue_out
          ,total_revenue_adj
          ,total_lent_resource_cost
          ,total_tp_cost_in
          ,total_tp_cost_out
          ,total_cost_adj
          ,total_unassigned_time_cost
          ,total_utilization_percent
          ,total_utilization_hours
          ,total_utilization_adj
          ,total_capacity
          ,total_head_count
          ,total_head_count_adj
          ,version_type
          ,request_id
	  ,total_project_raw_cost
  	  ,total_project_burdened_cost
	  ,total_project_revenue
	  ,locked_by_person_id
	  ,approved_cost_plan_type_flag
	  ,approved_rev_plan_type_flag
-- start of changes of Bug:- 2634900
          ,est_project_raw_cost
          ,est_project_burdened_cost
          ,est_project_revenue
          ,est_quantity
          ,est_projfunc_raw_cost
          ,est_projfunc_burdened_cost
          ,est_projfunc_revenue
          ,ci_id
          ,agreement_id
          ,process_update_wbs_flag
-- end of changes of Bug:- 2634900
-- Bug 3354518: start of new columns for FP-M
         ,object_type_code
         ,object_id
         ,primary_cost_forecast_flag
         ,primary_rev_forecast_flag
         ,rev_partially_impl_flag
         ,equipment_quantity
         ,pji_summarized_flag
         ,wp_version_flag
         ,current_planning_period
         ,period_mask_id
         ,last_amt_gen_date
         ,actual_amts_thru_period
      -- Bug 3354518: end of new columns for FP-M
         ,est_equipment_quantity --FP.M
         ) VALUES (
           px_budget_version_id
          ,1
          ,DECODE( p_project_id, FND_API.G_MISS_NUM, NULL, p_project_id)
          ,DECODE( p_budget_type_code, FND_API.G_MISS_CHAR, NULL,
                   p_budget_type_code)
          ,DECODE( p_version_number, FND_API.G_MISS_NUM, NULL, p_version_number)
          ,DECODE( p_budget_status_code, FND_API.G_MISS_CHAR, NULL,
                   p_budget_status_code)
          ,sysdate
		,fnd_global.user_id
		,sysdate
		,fnd_global.user_id
          ,fnd_global.login_id
          ,DECODE( p_current_flag, FND_API.G_MISS_CHAR, NULL, p_current_flag)
          ,DECODE( p_original_flag, FND_API.G_MISS_CHAR, NULL, p_original_flag)
          ,DECODE( p_current_original_flag, FND_API.G_MISS_CHAR, NULL,
                   p_current_original_flag)
          ,DECODE( p_resource_accumulated_flag, FND_API.G_MISS_CHAR, NULL,
                   p_resource_accumulated_flag)
          ,DECODE( p_resource_list_id, FND_API.G_MISS_NUM, NULL,
                   p_resource_list_id)
          ,DECODE( p_version_name, FND_API.G_MISS_CHAR, NULL, p_version_name)
          ,DECODE( p_budget_entry_method_code, FND_API.G_MISS_CHAR, NULL,
                   p_budget_entry_method_code)
          ,DECODE( p_baselined_by_person_id, FND_API.G_MISS_NUM, NULL,
                   p_baselined_by_person_id)
          ,DECODE( p_baselined_date, FND_API.G_MISS_DATE, TO_DATE(null),
                   p_baselined_date)
          ,DECODE( p_change_reason_code, FND_API.G_MISS_CHAR, NULL,
                   p_change_reason_code)
          ,DECODE( p_labor_quantity, FND_API.G_MISS_NUM, NULL, p_labor_quantity)
          ,DECODE( p_labor_unit_of_measure, FND_API.G_MISS_CHAR, NULL,
                   p_labor_unit_of_measure)
          ,DECODE( p_raw_cost, FND_API.G_MISS_NUM, NULL, p_raw_cost)
          ,DECODE( p_burdened_cost, FND_API.G_MISS_NUM, NULL, p_burdened_cost)
          ,DECODE( p_revenue, FND_API.G_MISS_NUM, NULL, p_revenue)
          ,DECODE( p_description, FND_API.G_MISS_CHAR, NULL, p_description)
          ,DECODE( p_attribute_category, FND_API.G_MISS_CHAR, NULL,
                   p_attribute_category)
          ,DECODE( p_attribute1, FND_API.G_MISS_CHAR, NULL, p_attribute1)
          ,DECODE( p_attribute2, FND_API.G_MISS_CHAR, NULL, p_attribute2)
          ,DECODE( p_attribute3, FND_API.G_MISS_CHAR, NULL, p_attribute3)
          ,DECODE( p_attribute4, FND_API.G_MISS_CHAR, NULL, p_attribute4)
          ,DECODE( p_attribute5, FND_API.G_MISS_CHAR, NULL, p_attribute5)
          ,DECODE( p_attribute6, FND_API.G_MISS_CHAR, NULL, p_attribute6)
          ,DECODE( p_attribute7, FND_API.G_MISS_CHAR, NULL, p_attribute7)
          ,DECODE( p_attribute8, FND_API.G_MISS_CHAR, NULL, p_attribute8)
          ,DECODE( p_attribute9, FND_API.G_MISS_CHAR, NULL, p_attribute9)
          ,DECODE( p_attribute10, FND_API.G_MISS_CHAR, NULL, p_attribute10)
          ,DECODE( p_attribute11, FND_API.G_MISS_CHAR, NULL, p_attribute11)
          ,DECODE( p_attribute12, FND_API.G_MISS_CHAR, NULL, p_attribute12)
          ,DECODE( p_attribute13, FND_API.G_MISS_CHAR, NULL, p_attribute13)
          ,DECODE( p_attribute14, FND_API.G_MISS_CHAR, NULL, p_attribute14)
          ,DECODE( p_attribute15, FND_API.G_MISS_CHAR, NULL, p_attribute15)
          ,DECODE( p_first_budget_period, FND_API.G_MISS_CHAR, NULL,
                   p_first_budget_period)
          ,DECODE( p_pm_product_code, FND_API.G_MISS_CHAR, NULL,
                   p_pm_product_code)
          ,DECODE( p_pm_budget_reference, FND_API.G_MISS_CHAR, NULL,
                   p_pm_budget_reference)
          ,DECODE( p_wf_status_code, FND_API.G_MISS_CHAR, NULL,
                   p_wf_status_code)
          ,DECODE( p_adw_notify_flag, FND_API.G_MISS_CHAR, NULL,
                   p_adw_notify_flag)
          ,DECODE( p_prc_generated_flag, FND_API.G_MISS_CHAR, NULL,
                   p_prc_generated_flag)
          ,DECODE( p_plan_run_DATE, FND_API.G_MISS_DATE, TO_DATE(null),
                   p_plan_run_DATE)
          ,DECODE( p_plan_processing_code, FND_API.G_MISS_CHAR, NULL,
                   p_plan_processing_code)
          ,DECODE( p_period_profile_id, FND_API.G_MISS_NUM, NULL,
                   p_period_profile_id)
          ,DECODE( p_fin_plan_type_id, FND_API.G_MISS_NUM, NULL,
                   p_fin_plan_type_id)
          ,DECODE( p_parent_plan_version_id, FND_API.G_MISS_NUM, NULL,
                   p_parent_plan_version_id)
          ,DECODE( p_project_structure_version_id, FND_API.G_MISS_NUM, NULL,
                   p_project_structure_version_id)
          ,DECODE( p_current_working_flag, FND_API.G_MISS_CHAR, NULL,
                   p_current_working_flag)
          ,DECODE( p_total_borrowed_revenue, FND_API.G_MISS_NUM, NULL,
                   p_total_borrowed_revenue)
          ,DECODE( p_total_tp_revenue_in, FND_API.G_MISS_NUM, NULL,
                   p_total_tp_revenue_in)
          ,DECODE( p_total_tp_revenue_out, FND_API.G_MISS_NUM, NULL,
                   p_total_tp_revenue_out)
          ,DECODE( p_total_revenue_adj, FND_API.G_MISS_NUM, NULL,
                   p_total_revenue_adj)
          ,DECODE( p_total_lent_resource_cost, FND_API.G_MISS_NUM, NULL,
                   p_total_lent_resource_cost)
          ,DECODE( p_total_tp_cost_in, FND_API.G_MISS_NUM, NULL,
                   p_total_tp_cost_in)
          ,DECODE( p_total_tp_cost_out, FND_API.G_MISS_NUM, NULL,
                   p_total_tp_cost_out)
          ,DECODE( p_total_cost_adj, FND_API.G_MISS_NUM, NULL, p_total_cost_adj)
          ,DECODE( p_total_unassigned_time_cost, FND_API.G_MISS_NUM, NULL,
                   p_total_unassigned_time_cost)
          ,DECODE( p_total_utilization_percent, FND_API.G_MISS_NUM, NULL,
                   p_total_utilization_percent)
          ,DECODE( p_total_utilization_hours, FND_API.G_MISS_NUM, NULL,
                   p_total_utilization_hours)
          ,DECODE( p_total_utilization_adj, FND_API.G_MISS_NUM, NULL,
                   p_total_utilization_adj)
          ,DECODE( p_total_capacity, FND_API.G_MISS_NUM, NULL, p_total_capacity)
          ,DECODE( p_total_head_count, FND_API.G_MISS_NUM, NULL,
                   p_total_head_count)
          ,DECODE( p_total_head_count_adj, FND_API.G_MISS_NUM, NULL,
                   p_total_head_count_adj)
          ,DECODE( p_version_type, FND_API.G_MISS_CHAR, NULL, p_version_type)
          ,DECODE( p_request_id, FND_API.G_MISS_NUM, NULL, p_request_id)
	  ,DECODE( p_total_project_raw_cost, FND_API.G_MISS_NUM, NULL, p_total_project_raw_cost)
	  ,DECODE( p_total_project_burdened_cost, FND_API.G_MISS_NUM, NULL, p_total_project_burdened_cost)
	  ,DECODE( p_total_project_revenue, FND_API.G_MISS_NUM, NULL, p_total_project_revenue)
	  ,DECODE( p_locked_by_person_id, FND_API.G_MISS_NUM, NULL, p_locked_by_person_id)
	  ,DECODE( p_approved_cost_plan_type_flag, FND_API.G_MISS_CHAR, NULL, p_approved_cost_plan_type_flag)
	  ,DECODE( p_approved_rev_plan_type_flag, FND_API.G_MISS_CHAR, NULL, p_approved_rev_plan_type_flag)
-- start of changes of Bug:- 2634900
	  ,DECODE( p_est_project_raw_cost, FND_API.G_MISS_NUM, NULL, p_est_project_raw_cost)
	  ,DECODE( p_est_project_burdened_cost, FND_API.G_MISS_NUM, NULL, p_est_project_burdened_cost)
	  ,DECODE( p_est_project_revenue, FND_API.G_MISS_NUM, NULL, p_est_project_revenue)
	  ,DECODE( p_est_quantity, FND_API.G_MISS_NUM, NULL, p_est_quantity)
      ,DECODE( p_est_projfunc_raw_cost, FND_API.G_MISS_NUM, NULL, p_est_projfunc_raw_cost)
	  ,DECODE( p_est_projfunc_burdened_cost, FND_API.G_MISS_NUM, NULL, p_est_projfunc_burdened_cost)
	  ,DECODE( p_est_projfunc_revenue, FND_API.G_MISS_NUM, NULL, p_est_projfunc_revenue)
	  ,DECODE( p_ci_id, FND_API.G_MISS_NUM, NULL, p_ci_id)
	  ,DECODE( p_agreement_id, FND_API.G_MISS_NUM, NULL, p_agreement_id)
      ,DECODE(p_refresh_required_flag, FND_API.G_MISS_CHAR, NULL, p_refresh_required_flag)
-- end of changes of Bug:- 2634900
-- Bug 3354518: start of new columns for FP-M
      ,DECODE(p_object_type_code            ,   FND_API.G_MISS_CHAR, null, p_object_type_code           )
      ,DECODE(p_object_id                   ,   FND_API.G_MISS_NUM , null, p_object_id                  )
      ,DECODE(p_primary_cost_forecast_flag  ,   FND_API.G_MISS_CHAR, null, p_primary_cost_forecast_flag )
      ,DECODE(p_primary_rev_forecast_flag   ,   FND_API.G_MISS_CHAR, null, p_primary_rev_forecast_flag  )
      ,DECODE(p_rev_partially_impl_flag     ,   FND_API.G_MISS_CHAR, null, p_rev_partially_impl_flag    )
      ,DECODE(p_equipment_quantity          ,   FND_API.G_MISS_NUM , null, p_equipment_quantity         )
      ,DECODE(p_pji_summarized_flag         ,   FND_API.G_MISS_CHAR, null, p_pji_summarized_flag        )
      ,DECODE(p_wp_version_flag             ,   FND_API.G_MISS_CHAR, null, p_wp_version_flag            )
      ,DECODE(p_current_planning_period     ,   FND_API.G_MISS_CHAR, null, p_current_planning_period    )
      ,DECODE(p_period_mask_id              ,   FND_API.G_MISS_NUM , null, p_period_mask_id             )
      ,DECODE(p_last_amt_gen_date           ,   FND_API.G_MISS_DATE, null, p_last_amt_gen_date          )
      ,DECODE(p_actual_amts_thru_period     ,   FND_API.G_MISS_CHAR, null, p_actual_amts_thru_period    )
-- Bug 3354518: end of new columns for FP-M
      ,DECODE( p_est_equip_qty, FND_API.G_MISS_NUM, NULL, p_est_equip_qty) --FP.M
          );
EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_FP_BUDGET_VERSIONS_PKG.Insert_Row'
                               ,p_procedure_name
                                => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Insert_Row;

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
 ,x_return_status               OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN

 x_return_status := FND_API.G_RET_STS_SUCCESS;

 UPDATE pa_budget_versions
 SET
  record_version_number = nvl(record_version_number,0) +1
 ,project_id = DECODE( p_project_id, FND_API.G_MISS_NUM, project_id,
                       p_project_id)
 ,budget_type_code = DECODE( p_budget_type_code, FND_API.G_MISS_CHAR,
                             budget_type_code, p_budget_type_code)
 ,version_number = DECODE( p_version_number, FND_API.G_MISS_NUM,
                           version_number, p_version_number)
 ,budget_status_code = DECODE( p_budget_status_code, FND_API.G_MISS_CHAR,
                               budget_status_code, p_budget_status_code)
 ,last_update_date = sysdate
 ,last_updated_by = fnd_global.user_id
 ,last_update_login = fnd_global.login_id
 ,current_flag = DECODE( p_current_flag, FND_API.G_MISS_CHAR, current_flag,
                         p_current_flag)
 ,original_flag = DECODE( p_original_flag, FND_API.G_MISS_CHAR, original_flag,
                          p_original_flag)
 ,current_original_flag = DECODE( p_current_original_flag, FND_API.G_MISS_CHAR,
                                  current_original_flag,
                                  p_current_original_flag)
 ,resource_accumulated_flag = DECODE( p_resource_accumulated_flag,
                                      FND_API.G_MISS_CHAR,
                                      resource_accumulated_flag,
                                      p_resource_accumulated_flag)
 ,resource_list_id = DECODE( p_resource_list_id, FND_API.G_MISS_NUM,
                             resource_list_id, p_resource_list_id)
 ,version_name = DECODE( p_version_name, FND_API.G_MISS_CHAR, version_name,
                         p_version_name)
 ,budget_entry_method_code = DECODE( p_budget_entry_method_code,
                                     FND_API.G_MISS_CHAR,
                                     budget_entry_method_code,
                                     p_budget_entry_method_code)
 ,baselined_by_person_id = DECODE( p_baselined_by_person_id, FND_API.G_MISS_NUM,
                                   baselined_by_person_id,
                                   p_baselined_by_person_id)
 ,baselined_date = DECODE( p_baselined_DATE, FND_API.G_MISS_DATE,
                           baselined_DATE, p_baselined_date)
 ,change_reason_code = DECODE( p_change_reason_code, FND_API.G_MISS_CHAR,
                               change_reason_code, p_change_reason_code)
 ,labor_quantity = DECODE( p_labor_quantity, FND_API.G_MISS_NUM, labor_quantity,
                           p_labor_quantity)
 ,labor_unit_of_measure = DECODE( p_labor_unit_of_measure, FND_API.G_MISS_CHAR,
                                  labor_unit_of_measure,
                                  p_labor_unit_of_measure)
 ,raw_cost = DECODE( p_raw_cost, FND_API.G_MISS_NUM, raw_cost, p_raw_cost)
 ,burdened_cost = DECODE( p_burdened_cost, FND_API.G_MISS_NUM, burdened_cost,
                          p_burdened_cost)
 ,revenue = DECODE( p_revenue, FND_API.G_MISS_NUM, revenue, p_revenue)
 ,description = DECODE( p_description, FND_API.G_MISS_CHAR, description,
                        p_description)
 ,attribute_category = DECODE( p_attribute_category, FND_API.G_MISS_CHAR,
                               attribute_category, p_attribute_category)
 ,attribute1 = DECODE( p_attribute1, FND_API.G_MISS_CHAR, attribute1,
                       p_attribute1)
 ,attribute2 = DECODE( p_attribute2, FND_API.G_MISS_CHAR, attribute2,
                       p_attribute2)
 ,attribute3 = DECODE( p_attribute3, FND_API.G_MISS_CHAR, attribute3,
                       p_attribute3)
 ,attribute4 = DECODE( p_attribute4, FND_API.G_MISS_CHAR, attribute4,
                       p_attribute4)
 ,attribute5 = DECODE( p_attribute5, FND_API.G_MISS_CHAR, attribute5,
                       p_attribute5)
 ,attribute6 = DECODE( p_attribute6, FND_API.G_MISS_CHAR, attribute6,
                       p_attribute6)
 ,attribute7 = DECODE( p_attribute7, FND_API.G_MISS_CHAR, attribute7,
                       p_attribute7)
 ,attribute8 = DECODE( p_attribute8, FND_API.G_MISS_CHAR, attribute8,
                       p_attribute8)
 ,attribute9 = DECODE( p_attribute9, FND_API.G_MISS_CHAR, attribute9,
                       p_attribute9)
 ,attribute10 = DECODE( p_attribute10, FND_API.G_MISS_CHAR, attribute10,
                        p_attribute10)
 ,attribute11 = DECODE( p_attribute11, FND_API.G_MISS_CHAR, attribute11,
                        p_attribute11)
 ,attribute12 = DECODE( p_attribute12, FND_API.G_MISS_CHAR, attribute12,
                        p_attribute12)
 ,attribute13 = DECODE( p_attribute13, FND_API.G_MISS_CHAR, attribute13,
                        p_attribute13)
 ,attribute14 = DECODE( p_attribute14, FND_API.G_MISS_CHAR, attribute14,
                        p_attribute14)
 ,attribute15 = DECODE( p_attribute15, FND_API.G_MISS_CHAR, attribute15,
                        p_attribute15)
 ,first_budget_period = DECODE( p_first_budget_period, FND_API.G_MISS_CHAR,
                                first_budget_period, p_first_budget_period)
 ,pm_product_code = DECODE( p_pm_product_code, FND_API.G_MISS_CHAR,
                            pm_product_code, p_pm_product_code)
 ,pm_budget_reference = DECODE( p_pm_budget_reference, FND_API.G_MISS_CHAR,
                                pm_budget_reference, p_pm_budget_reference)
 ,wf_status_code = DECODE( p_wf_status_code, FND_API.G_MISS_CHAR,
                           wf_status_code, p_wf_status_code)
 ,adw_notify_flag = DECODE( p_adw_notify_flag, FND_API.G_MISS_CHAR,
                            adw_notify_flag, p_adw_notify_flag)
 ,prc_generated_flag = DECODE( p_prc_generated_flag, FND_API.G_MISS_CHAR,
                               prc_generated_flag, p_prc_generated_flag)
 ,plan_run_date = DECODE( p_plan_run_DATE, FND_API.G_MISS_DATE, plan_run_DATE,
                          p_plan_run_date)
 ,plan_processing_code = DECODE( p_plan_processing_code, FND_API.G_MISS_CHAR,
                                 plan_processing_code, p_plan_processing_code)
 ,period_profile_id = DECODE( p_period_profile_id, FND_API.G_MISS_NUM,
                              period_profile_id, p_period_profile_id)
 ,fin_plan_type_id = DECODE( p_fin_plan_type_id, FND_API.G_MISS_NUM,
                             fin_plan_type_id, p_fin_plan_type_id)
 ,parent_plan_version_id = DECODE( p_parent_plan_version_id, FND_API.G_MISS_NUM,
                                   parent_plan_version_id,
                                   p_parent_plan_version_id)
 ,project_structure_version_id = DECODE( p_project_structure_version_id,
                                         FND_API.G_MISS_NUM,
                                         project_structure_version_id,
                                         p_project_structure_version_id)
 ,current_working_flag = DECODE( p_current_working_flag, FND_API.G_MISS_CHAR,
                                 current_working_flag, p_current_working_flag)
 ,total_borrowed_revenue = DECODE( p_total_borrowed_revenue, FND_API.G_MISS_NUM,
                                   total_borrowed_revenue,
                                   p_total_borrowed_revenue)
 ,total_tp_revenue_in = DECODE( p_total_tp_revenue_in, FND_API.G_MISS_NUM,
                                total_tp_revenue_in, p_total_tp_revenue_in)
 ,total_tp_revenue_out = DECODE( p_total_tp_revenue_out, FND_API.G_MISS_NUM,
                                 total_tp_revenue_out, p_total_tp_revenue_out)
 ,total_revenue_adj = DECODE( p_total_revenue_adj, FND_API.G_MISS_NUM,
                              total_revenue_adj, p_total_revenue_adj)
 ,total_lent_resource_cost = DECODE( p_total_lent_resource_cost,
                                     FND_API.G_MISS_NUM,
                                     total_lent_resource_cost,
                                     p_total_lent_resource_cost)
 ,total_tp_cost_in = DECODE( p_total_tp_cost_in, FND_API.G_MISS_NUM,
                             total_tp_cost_in, p_total_tp_cost_in)
 ,total_tp_cost_out = DECODE( p_total_tp_cost_out, FND_API.G_MISS_NUM,
                              total_tp_cost_out, p_total_tp_cost_out)
 ,total_cost_adj = DECODE( p_total_cost_adj, FND_API.G_MISS_NUM, total_cost_adj,
                           p_total_cost_adj)
 ,total_unassigned_time_cost = DECODE( p_total_unassigned_time_cost,
                                       FND_API.G_MISS_NUM,
                                       total_unassigned_time_cost,
                                       p_total_unassigned_time_cost)
 ,total_utilization_percent = DECODE( p_total_utilization_percent,
                                      FND_API.G_MISS_NUM,
                                      total_utilization_percent,
                                      p_total_utilization_percent)
 ,total_utilization_hours = DECODE( p_total_utilization_hours,
                                    FND_API.G_MISS_NUM, total_utilization_hours,
                                    p_total_utilization_hours)
 ,total_utilization_adj = DECODE( p_total_utilization_adj, FND_API.G_MISS_NUM,
                                  total_utilization_adj,
                                  p_total_utilization_adj)
 ,total_capacity = DECODE( p_total_capacity, FND_API.G_MISS_NUM, total_capacity,
                           p_total_capacity)
 ,total_head_count = DECODE( p_total_head_count, FND_API.G_MISS_NUM,
                             total_head_count, p_total_head_count)
 ,total_head_count_adj = DECODE( p_total_head_count_adj, FND_API.G_MISS_NUM,
                                 total_head_count_adj, p_total_head_count_adj)
 ,version_type = DECODE( p_version_type, FND_API.G_MISS_CHAR, version_type,
                         p_version_type)
 ,request_id = DECODE( p_request_id, FND_API.G_MISS_CHAR, request_id,p_request_id)
 ,total_project_raw_cost = DECODE( p_total_project_raw_cost, FND_API.G_MISS_NUM,
                                total_project_raw_cost,p_total_project_raw_cost)
 ,total_project_burdened_cost = DECODE( p_total_project_burdened_cost, FND_API.G_MISS_NUM,
                                total_project_burdened_cost,p_total_project_burdened_cost)
 ,total_project_revenue = DECODE( p_total_project_revenue, FND_API.G_MISS_NUM,
                                 total_project_revenue,p_total_project_revenue)
 ,locked_by_person_id = DECODE( p_locked_by_person_id, FND_API.G_MISS_NUM,
                                 locked_by_person_id,p_locked_by_person_id)
 ,approved_cost_plan_type_flag = DECODE( p_approved_cost_plan_type_flag, FND_API.G_MISS_CHAR,
                                 approved_cost_plan_type_flag,p_approved_cost_plan_type_flag)
 ,approved_rev_plan_type_flag = DECODE(p_approved_rev_plan_type_flag, FND_API.G_MISS_CHAR,
                                 approved_rev_plan_type_flag,p_approved_rev_plan_type_flag)
-- start of changes of Bug:- 2634900
 ,est_project_raw_cost = DECODE( p_est_project_raw_cost, FND_API.G_MISS_NUM,
                                est_project_raw_cost, p_est_project_raw_cost)
 ,est_project_burdened_cost = DECODE( p_est_project_burdened_cost,FND_API.G_MISS_NUM,
                               est_project_burdened_cost,p_est_project_burdened_cost)
 ,est_project_revenue = DECODE( p_est_project_revenue, FND_API.G_MISS_NUM,
                               est_project_revenue,p_est_project_revenue)
 ,est_quantity = DECODE( p_est_quantity, FND_API.G_MISS_NUM,est_quantity,p_est_quantity)
 ,est_projfunc_raw_cost = DECODE( p_est_projfunc_raw_cost, FND_API.G_MISS_NUM,
                                  est_projfunc_raw_cost,p_est_projfunc_raw_cost)
 ,est_projfunc_burdened_cost = DECODE( p_est_projfunc_burdened_cost, FND_API.G_MISS_NUM,
                                  est_projfunc_burdened_cost,p_est_projfunc_burdened_cost)
 ,est_projfunc_revenue = DECODE( p_est_projfunc_revenue, FND_API.G_MISS_NUM,
                                 est_projfunc_revenue,p_est_projfunc_revenue)
 ,ci_id = DECODE( p_ci_id, FND_API.G_MISS_NUM,ci_id,p_ci_id)
 ,agreement_id = DECODE(p_agreement_id, FND_API.G_MISS_NUM,agreement_id,p_agreement_id)
 -- Bug 3354518: start of new columns for FP-M
,object_type_code            =  DECODE(p_object_type_code ,   FND_API.G_MISS_CHAR, object_type_code
                                                          , p_object_type_code)
,object_id                   =  DECODE(p_object_id ,   FND_API.G_MISS_NUM , object_id, p_object_id)
,primary_cost_forecast_flag  =  DECODE(p_primary_cost_forecast_flag  ,   FND_API.G_MISS_CHAR,
                                           primary_cost_forecast_flag, p_primary_cost_forecast_flag )
,primary_rev_forecast_flag   =  DECODE(p_primary_rev_forecast_flag   ,   FND_API.G_MISS_CHAR,
                                           primary_rev_forecast_flag , p_primary_rev_forecast_flag  )
,rev_partially_impl_flag     =  DECODE(p_rev_partially_impl_flag     ,   FND_API.G_MISS_CHAR,
                                           rev_partially_impl_flag   , p_rev_partially_impl_flag    )
,equipment_quantity          =  DECODE(p_equipment_quantity          ,   FND_API.G_MISS_NUM ,
                                           equipment_quantity        , p_equipment_quantity         )
,pji_summarized_flag         =  DECODE(p_pji_summarized_flag         ,   FND_API.G_MISS_CHAR,
                                           pji_summarized_flag       , p_pji_summarized_flag        )
,wp_version_flag             =  DECODE(p_wp_version_flag             ,   FND_API.G_MISS_CHAR,
                                           wp_version_flag           , p_wp_version_flag            )
,current_planning_period     =  DECODE(p_current_planning_period     ,   FND_API.G_MISS_CHAR,
                                           current_planning_period   , p_current_planning_period    )
,period_mask_id              =  DECODE(p_period_mask_id              ,   FND_API.G_MISS_NUM ,
                                           period_mask_id            , p_period_mask_id             )
,last_amt_gen_date           =  DECODE(p_last_amt_gen_date           ,   FND_API.G_MISS_DATE,
                                           last_amt_gen_date         , p_last_amt_gen_date          )
,actual_amts_thru_period     =  DECODE(p_actual_amts_thru_period     ,   FND_API.G_MISS_CHAR,
                                           actual_amts_thru_period   , p_actual_amts_thru_period    )
-- Bug 3354518: end of new columns for FP-M
,est_equipment_quantity      =  DECODE( p_est_equip_qty, FND_API.G_MISS_NUM,est_equipment_quantity,p_est_equip_qty) --FP.M
-- end of changes of Bug:- 2634900

 WHERE budget_version_id = p_budget_version_id
   AND nvl(p_record_version_number, nvl(record_version_number,0)) =
                                    nvl(record_version_number,0);

    IF (SQL%NOTFOUND) THEN
       PA_UTILS.Add_message ( p_app_short_name => 'PA'
                             ,p_msg_name => 'PA_XC_RECORD_CHANGED');
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_FP_BUDGET_VERSIONS_PKG.Update_Row'
                               ,p_procedure_name
                                => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Update_Row;

PROCEDURE Lock_Row
( p_budget_version_id            IN pa_budget_versions.budget_version_id%TYPE
 ,p_record_version_number        IN NUMBER
                                    := NULL
 ,p_row_id                       IN ROWID
                                    := NULL
 ,x_return_status               OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
 IS
   l_row_id ROWID;
BEGIN
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       SELECT rowid into l_row_id
       FROM pa_budget_versions
       WHERE budget_version_id =  p_budget_version_id
          OR rowid = p_row_id
       FOR UPDATE NOWAIT;

    IF (SQL%NOTFOUND) THEN
       PA_UTILS.Add_message ( p_app_short_name => 'PA'
                             ,p_msg_name => 'PA_XC_RECORD_CHANGED');
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;
EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_FP_BUDGET_VERSIONS_PKG.Lock_Row'
                               ,p_procedure_name
                                => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Lock_Row;

PROCEDURE Delete_Row
( p_budget_version_id            IN pa_budget_versions.budget_version_id%TYPE
 ,p_record_version_number        IN NUMBER
                                    := NULL
 ,p_row_id                       IN ROWID
                                    := NULL
 ,x_return_status               OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
IS
BEGIN
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (p_budget_version_id IS NOT NULL AND
        p_budget_version_id <> FND_API.G_MISS_NUM) THEN

        DELETE FROM pa_budget_versions
         WHERE budget_version_id = p_budget_version_id
           AND nvl(p_record_version_number, nvl(record_version_number,0)) =
                                            nvl(record_version_number,0);
    ELSIF (p_row_id IS NOT NULL) THEN
        DELETE FROM pa_budget_versions
         WHERE rowid = p_row_id
           AND nvl(p_record_version_number, nvl(record_version_number,0)) =
                                            nvl(record_version_number,0);
    END IF;

    IF (SQL%NOTFOUND) then
       PA_UTILS.Add_message ( p_app_short_name => 'PA'
                             ,p_msg_name => 'PA_XC_RECORD_CHANGED');
       x_return_status := FND_API.G_RET_STS_ERROR;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
       FND_MSG_PUB.add_exc_msg( p_pkg_name
                                => 'PA_FP_BUDGET_VERSIONS_PKG.Delete_Row'
                               ,p_procedure_name
                                => PA_DEBUG.G_Err_Stack);
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       RAISE;
END Delete_Row;

END pa_fp_budget_versions_pkg;

/
