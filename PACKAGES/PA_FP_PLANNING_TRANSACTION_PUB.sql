--------------------------------------------------------
--  DDL for Package PA_FP_PLANNING_TRANSACTION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_PLANNING_TRANSACTION_PUB" AUTHID CURRENT_USER AS
/* $Header: PAFPPTPS.pls 120.5.12010000.4 2009/10/09 06:38:04 rrambati ship $ */

--Declare empty pl/sql tables so that they can be used for defaulting

/*=====================================================================
Procedure Name:      add_planning_transactions
Purpose:             This procedure should be called to create planning
                     transactions valid values for p_context are 'BUDGET'
                     ,'FORECAST', 'WORKPLAN' and 'TASK_ASSIGNMENT'.valid
                     values for p_default_resource_attribs are 'Y' or 'N'
                     When Y, the api will honor only resource list member
                     id, resource name and resource class flag in the
                     resource rec type and default all the other values
                     by calling the get resurce defaults api of resource
                     foundation.
                     If p_calling_module parameter is CREATE_VERSION,
                     donot call calculate api.

                     Creates resource assignments and budget lines for
                     workplan/budget/forecast. It is assumed that the
                     duplicate rlm ids are not passed . If this API finds
                     that there is no corresponding budget version then
                     this API goes and creates a budget version for the
                     work plan version.
=======================================================================*/
/*******************************************************************************************************
As part of Bug 3749516 All References to Equipment Effort or Equip Resource Class has been removed in
PROCEDURE add_planning_transactions.
p_planned_equip_effort_tbl IN parameter has also been removed as they were not being  used/referred.
********************************************************************************************************/
PROCEDURE add_planning_transactions
(
       p_context                     IN       VARCHAR2
      ,p_calling_context             IN       VARCHAR2 DEFAULT NULL      -- Added for Bug 6856934
      ,p_one_to_one_mapping_flag     IN       VARCHAR2 DEFAULT 'N'
      ,p_calling_module              IN       VARCHAR2 DEFAULT NULL
      ,p_project_id                  IN       Pa_projects_all.project_id%TYPE
      ,p_struct_elem_version_id      IN       Pa_proj_element_versions.element_version_id%TYPE   DEFAULT NULL
      ,p_budget_version_id           IN       Pa_budget_versions.budget_version_id%TYPE          DEFAULT NULL
      ,p_task_elem_version_id_tbl    IN       SYSTEM.pa_num_tbl_type                             DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_task_name_tbl               IN       SYSTEM.PA_VARCHAR2_240_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
      ,p_task_number_tbl             IN       SYSTEM.PA_VARCHAR2_100_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_100_TBL_TYPE()
      ,p_start_date_tbl              IN       SYSTEM.pa_date_tbl_type                            DEFAULT SYSTEM.PA_DATE_TBL_TYPE()
      ,p_end_date_tbl                IN       SYSTEM.pa_date_tbl_type                            DEFAULT SYSTEM.PA_DATE_TBL_TYPE()
       -- Bug 3793623 New params p_planning_start_date_tbl and p_planning_end_date_tbl added
      ,p_planning_start_date_tbl     IN       SYSTEM.pa_date_tbl_type                            DEFAULT SYSTEM.PA_DATE_TBL_TYPE()
      ,p_planning_end_date_tbl       IN       SYSTEM.pa_date_tbl_type                            DEFAULT SYSTEM.PA_DATE_TBL_TYPE()
      ,p_planned_people_effort_tbl   IN       SYSTEM.pa_num_tbl_type                             DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_latest_eff_pub_flag_tbl     IN       SYSTEM.PA_VARCHAR2_1_TBL_TYPE                      DEFAULT SYSTEM.PA_VARCHAR2_1_TBL_TYPE()
      --One record in the above pl/sql tables correspond to all the records in the below pl/sql tables
      ,p_resource_list_member_id_tbl IN       SYSTEM.pa_num_tbl_type                             DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_project_assignment_id_tbl   IN       SYSTEM.pa_num_tbl_type                             DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      /* The following columns are not (to be) passed by TA/WP. They are based by Edit Plan page BF case */
      ,p_quantity_tbl                IN       SYSTEM.pa_num_tbl_type                             DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_currency_code_tbl           IN       SYSTEM.PA_VARCHAR2_15_TBL_TYPE                     DEFAULT SYSTEM.PA_VARCHAR2_15_TBL_TYPE()
      ,p_raw_cost_tbl                IN       SYSTEM.pa_num_tbl_type                             DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_burdened_cost_tbl           IN       SYSTEM.pa_num_tbl_type                             DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_revenue_tbl                 IN       SYSTEM.pa_num_tbl_type                             DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_cost_rate_tbl               IN       SYSTEM.pa_num_tbl_type                             DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_bill_rate_tbl               IN       SYSTEM.pa_num_tbl_type                             DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_burdened_rate_tbl           IN       SYSTEM.pa_num_tbl_type                             DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_skip_duplicates_flag        IN       VARCHAR2                                           DEFAULT 'N'
      ,p_unplanned_flag_tbl          IN       SYSTEM.PA_VARCHAR2_1_TBL_TYPE                      DEFAULT SYSTEM.PA_VARCHAR2_1_TBL_TYPE()
      ,p_expenditure_type_tbl               IN  SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE() --added for Enc
      ,p_pm_product_code             IN       SYSTEM.PA_VARCHAR2_30_TBL_TYPE                     DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
      ,p_pm_res_asgmt_ref            IN       SYSTEM.PA_VARCHAR2_30_TBL_TYPE                     DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
      ,p_attribute_category_tbl      IN       SYSTEM.PA_VARCHAR2_30_TBL_TYPE                     DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
      ,p_attribute1                  IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute2                  IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute3                  IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute4                  IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute5                  IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute6                  IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute7                  IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute8                  IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute9                  IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute10                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute11                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute12                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute13                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute14                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute15                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute16                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute17                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute18                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute19                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute20                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute21                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute22                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute23                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute24                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute25                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute26                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute27                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute28                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute29                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute30                 IN       SYSTEM.PA_VARCHAR2_150_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_apply_progress_flag         IN       VARCHAR2                                           DEFAULT 'N' /* Bug# 3720357 */
      ,p_scheduled_delay             IN       SYSTEM.pa_num_tbl_type                             DEFAULT SYSTEM.PA_NUM_TBL_TYPE()--For bug 3948128
      ,p_pji_rollup_required        IN       VARCHAR2                                           DEFAULT 'Y' /* Bug# 4200168 */
      ,x_return_status               OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_msg_count                   OUT      NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,x_msg_data                    OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

/*This procedure should be called to update planning transactions
  valid values for p_context are 'BUDGET' , 'FORECAST', 'WORKPLAN' and 'TASK_ASSIGNMENT'
*/
/*******************************************************************************************************
As part of Bug 3749516 All References to Equipment Effort or Equip Resource Class has been removed in
PROCEDURE update_planning_transactions.
All _addl_ and p_equip_people_effort_tbl IN parameters have also been removed as they were not being
 used/referred.
********************************************************************************************************/
PROCEDURE update_planning_transactions
(
       p_context                      IN          VARCHAR2
      ,p_calling_context              IN          VARCHAR2 DEFAULT NULL    -- Added for Bug 6856934
      ,p_struct_elem_version_id       IN          Pa_proj_element_versions.element_version_id%TYPE  DEFAULT NULL
      ,p_budget_version_id            IN          Pa_budget_versions.budget_version_id%TYPE         DEFAULT NULL
      ,p_task_elem_version_id_tbl     IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_task_name_tbl                IN          SYSTEM.PA_VARCHAR2_240_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
      ,p_task_number_tbl              IN          SYSTEM.PA_VARCHAR2_100_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_100_TBL_TYPE()
      ,p_start_date_tbl               IN          SYSTEM.PA_DATE_TBL_TYPE                           DEFAULT SYSTEM.PA_DATE_TBL_TYPE()
      ,p_end_date_tbl                 IN          SYSTEM.PA_DATE_TBL_TYPE                           DEFAULT SYSTEM.PA_DATE_TBL_TYPE()
      ,p_planned_people_effort_tbl    IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
--    One pl/sql record in          The         Above tables
      ,p_resource_assignment_id_tbl   IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_resource_list_member_id_tbl  IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_assignment_description_tbl   IN          SYSTEM.PA_VARCHAR2_240_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
      ,p_project_assignment_id_tbl    IN          SYSTEM.pa_num_tbl_type                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_resource_alias_tbl           IN          SYSTEM.PA_VARCHAR2_80_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_80_TBL_TYPE()
      ,p_resource_class_flag_tbl      IN          SYSTEM.PA_VARCHAR2_1_TBL_TYPE                     DEFAULT SYSTEM.PA_VARCHAR2_1_TBL_TYPE()
      ,p_resource_class_code_tbl      IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
      ,p_resource_class_id_tbl        IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_res_type_code_tbl            IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
      ,p_resource_code_tbl            IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
      ,p_resource_name                IN          SYSTEM.PA_VARCHAR2_240_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
      ,p_person_id_tbl                IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_job_id_tbl                   IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_person_type_code             IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
      ,p_bom_resource_id_tbl          IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_non_labor_resource_tbl       IN          SYSTEM.PA_VARCHAR2_20_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_20_TBL_TYPE()
      ,p_inventory_item_id_tbl        IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_item_category_id_tbl         IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_project_role_id_tbl          IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_project_role_name_tbl        IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_organization_id_tbl          IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_organization_name_tbl        IN          SYSTEM.PA_VARCHAR2_240_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
      ,p_fc_res_type_code_tbl         IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
      ,p_financial_category_code_tbl  IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
      ,p_expenditure_type_tbl         IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
      ,p_expenditure_category_tbl     IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
      ,p_event_type_tbl               IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
      ,p_revenue_category_code_tbl    IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
      ,p_supplier_id_tbl              IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_unit_of_measure_tbl          IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
      ,p_spread_curve_id_tbl          IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_etc_method_code_tbl          IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
      ,p_mfc_cost_type_id_tbl         IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_procure_resource_flag_tbl    IN          SYSTEM.PA_VARCHAR2_1_TBL_TYPE                     DEFAULT SYSTEM.PA_VARCHAR2_1_TBL_TYPE()
      ,p_incurred_by_res_flag_tbl     IN          SYSTEM.PA_VARCHAR2_1_TBL_TYPE                     DEFAULT SYSTEM.PA_VARCHAR2_1_TBL_TYPE()
      ,p_incur_by_resource_code_tbl   IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
      ,p_incur_by_resource_name_tbl   IN          SYSTEM.PA_VARCHAR2_240_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
      ,p_incur_by_res_class_code_tbl  IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
      ,p_incur_by_role_id_tbl         IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_use_task_schedule_flag_tbl   IN          SYSTEM.PA_VARCHAR2_1_TBL_TYPE                     DEFAULT SYSTEM.PA_VARCHAR2_1_TBL_TYPE()
      ,p_planning_start_date_tbl      IN          SYSTEM.PA_DATE_TBL_TYPE                           DEFAULT SYSTEM.PA_DATE_TBL_TYPE()
      ,p_planning_end_date_tbl        IN          SYSTEM.PA_DATE_TBL_TYPE                           DEFAULT SYSTEM.PA_DATE_TBL_TYPE()
      ,p_schedule_start_date_tbl      IN          SYSTEM.PA_DATE_TBL_TYPE                           DEFAULT SYSTEM.PA_DATE_TBL_TYPE()
      ,p_schedule_end_date_tbl        IN          SYSTEM.PA_DATE_TBL_TYPE                           DEFAULT SYSTEM.PA_DATE_TBL_TYPE()
      ,p_quantity_tbl                 IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_currency_code_tbl            IN          SYSTEM.PA_VARCHAR2_15_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_15_TBL_TYPE()
      ,p_txn_currency_override_tbl    IN          SYSTEM.PA_VARCHAR2_15_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_15_TBL_TYPE()
      ,p_raw_cost_tbl                 IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_burdened_cost_tbl            IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_revenue_tbl                  IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_cost_rate_tbl                IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_cost_rate_override_tbl       IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_burdened_rate_tbl            IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_burdened_rate_override_tbl   IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_bill_rate_tbl                IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_bill_rate_override_tbl       IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_billable_percent_tbl         IN          SYSTEM.PA_NUM_TBL_TYPE                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_sp_fixed_date_tbl            IN          SYSTEM.PA_DATE_TBL_TYPE                           DEFAULT SYSTEM.PA_DATE_TBL_TYPE()
      ,p_named_role_tbl               IN          SYSTEM.PA_VARCHAR2_80_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_80_TBL_TYPE()
      ,p_financial_category_name_tbl  IN          SYSTEM.PA_VARCHAR2_80_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_80_TBL_TYPE()
      ,p_supplier_name_tbl            IN          SYSTEM.PA_VARCHAR2_240_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
      ,p_attribute_category_tbl       IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE                    DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
      ,p_attribute1_tbl               IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute2_tbl               IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute3_tbl               IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute4_tbl               IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute5_tbl               IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute6_tbl               IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute7_tbl               IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute8_tbl               IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute9_tbl               IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute10_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute11_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute12_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute13_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute14_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute15_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute16_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute17_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute18_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute19_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute20_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute21_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute22_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute23_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute24_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute25_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute26_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute27_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute28_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute29_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_attribute30_tbl              IN          SYSTEM.PA_VARCHAR2_150_TBL_TYPE                   DEFAULT SYSTEM.PA_VARCHAR2_150_TBL_TYPE()
      ,p_apply_progress_flag          IN          VARCHAR2                                          DEFAULT 'N' /* Passed from apply_progress api (sakthi's team) */
      ,p_scheduled_delay              IN          SYSTEM.pa_num_tbl_type                            DEFAULT SYSTEM.PA_NUM_TBL_TYPE()--For bug 3948128
      ,p_pji_rollup_required         IN       VARCHAR2                                             DEFAULT 'Y' /* Bug# 4200168 */
      ,p_upd_cost_amts_too_for_ta_flg IN VARCHAR2 DEFAULT 'N' --Added for bug #4538286
      ,p_distrib_amts                 IN          VARCHAR2  DEFAULT 'Y' -- Bug 5684639.
      ,p_direct_expenditure_type_tbl  IN          SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE() --added for Enc
      ,x_return_status                OUT         NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_msg_data                     OUT         NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_msg_count                    OUT         NOCOPY NUMBER --File.Sql.39 bug 4440895



);

/*This procedure should be called to copy planning transactions
  valid values for p_context are 'BUDGET' , 'FORECAST', 'WORKPLAN' and 'TASK_ASSIGNMENT'
  valid values for p_copy_amt_qty are 'Y' and 'N'

  The parameters
      p_copy_people_flag
      p_copy_equip_flag
      p_copy_mat_item_flag
      p_copy_fin_elem_flag
  will be used only when the p_context is TASK_ASSIGNMENT.
  Irrespective of the context in which the API is called,
  the p_src_targ_version_id_tbl should never be empty.
  The other parameters can be derived based on the values
  in p_src_targ_version_id_tbl table.
*/
PROCEDURE copy_planning_transactions
(
       p_context                   IN   VARCHAR2
      ,p_copy_external_flag        IN   VARCHAR2
      ,p_src_project_id            IN   pa_projects_all.project_id%TYPE
      ,p_target_project_id         IN   pa_projects_all.project_id%TYPE
      ,p_src_budget_version_id     IN   pa_budget_versions.budget_version_id%TYPE DEFAULT NULL
      ,p_targ_budget_version_id    IN   pa_budget_versions.budget_version_id%TYPE DEFAULT NULL
      ,p_src_version_id_tbl        IN   SYSTEM.PA_NUM_TBL_TYPE
      ,p_targ_version_id_tbl       IN   SYSTEM.PA_NUM_TBL_TYPE
      ,p_copy_people_flag          IN   VARCHAR2                        := NULL
      ,p_copy_equip_flag           IN   VARCHAR2                        := NULL
      ,p_copy_mat_item_flag        IN   VARCHAR2                        := NULL
      ,p_copy_fin_elem_flag        IN   VARCHAR2                        := NULL
--     Added this field p_pji_rollup_required for the 4200168
      ,p_pji_rollup_required      IN   VARCHAR2                     DEFAULT 'Y'
      ,x_return_status             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_msg_count                 OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,x_msg_data                  OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

);



/*This procedure should be called to delete planning transactions
  valid values for p_context are 'BUDGET' , 'FORECAST', 'WORKPLAN' and 'TASK_ASSIGNMENT'
  valid values for p_task_or_res are 'TASKS','ASSIGNMENT'
  In the context of 'TASK_ASSIGNMENT' the fields task_number and task_name are required in p_task_rec_tbl
  If p_task_or_res is TASKS, p_element_version_id_tbl, p_task_number_tbl, p_task_name_tbl are used.
  If p_task_or_res is ASSIGNMENT, p_resource_assignment_tbl is used.

  p_calling_module can be NULL or PROCESS_RES_CHG_DERV_CALC_PRMS. If passed as Y
  resource assignments will be  deleted otherwise they
  will not be deleted.(Please note that budget lines will be deleted
  always irrespective of the value for this parameter).
  Please note that this parameter cannot be PROCESS_RES_CHG_DERV_CALC_PRMS
  when p_task_or_res is passed as TASKS
  Whenever p_calling_module is passed as PROCESS_RES_CHG_DERV_CALC_PRMS,
  the parameters p_task_id_tbl,p_resource_class_code_tbl
  p_rbs_element_id_tbl and  p_rate_based_flag_tbl should ALSO be
  passed. These tbls must be equal in length to p_resource_assignment_tbl
  and should contain the task id, rbs element id and rate based flag
  for the resource assignment

  Bug - 3719918. New param p_currency_code_tbl is added below
  When p_context - Budget/Forecast and p_task_or_res is Assignment then only the bugdet lines
  Corresponding to currency code passed will be deleted. After deleting of the budget lines
  the corresponding RA will only we deleted if the budget line count is 0 from the RA.
  p_calling_module will be'EDIT_PLAN' when called from edit plan pages.

*/
PROCEDURE delete_planning_transactions
(
       p_context                      IN       VARCHAR2
      ,p_calling_context              IN       VARCHAR2 DEFAULT NULL      -- Added for Bug 6856934
      ,p_task_or_res                  IN       VARCHAR2 DEFAULT 'TASKS'
      ,p_element_version_id_tbl       IN       SYSTEM.PA_NUM_TBL_TYPE          DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_task_number_tbl              IN       SYSTEM.PA_VARCHAR2_240_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
      ,p_task_name_tbl                IN       SYSTEM.PA_VARCHAR2_240_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
      ,p_resource_assignment_tbl      IN       SYSTEM.PA_NUM_TBL_TYPE          DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      --Introduced for bug 3589130. If this parameter is passed as Y then an error will be thrown
      --When its required to delete a resource assignment containing budget lines. This parameter
      --will be considered only for BUDGET and FORECAST context
      ,p_validate_delete_flag         IN       VARCHAR2                        DEFAULT 'N'
      -- This param will be used for B/F Context. Bug - 3719918
      ,p_currency_code_tbl            IN       SYSTEM.PA_VARCHAR2_15_TBL_TYPE  DEFAULT SYSTEM.PA_VARCHAR2_15_TBL_TYPE()
      ,p_calling_module               IN       VARCHAR2                        DEFAULT NULL
      ,p_task_id_tbl                  IN       SYSTEM.PA_NUM_TBL_TYPE          DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_rbs_element_id_tbl           IN       SYSTEM.PA_NUM_TBL_TYPE          DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
      ,p_rate_based_flag_tbl          IN       SYSTEM.PA_VARCHAR2_1_TBL_TYPE   DEFAULT SYSTEM.PA_VARCHAR2_1_TBL_TYPE()
      ,p_resource_class_code_tbl      IN       SYSTEM.PA_VARCHAR2_30_TBL_TYPE  DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
      --For Bug 3937716. Calls to PJI and budget version rollup APIs will be skipped if p_rollup_required_flag is N.
      ,p_rollup_required_flag         IN       VARCHAR2                        DEFAULT 'Y'
      ,p_pji_rollup_required          IN       VARCHAR2                        DEFAULT 'Y' /* Bug 4200168 */
      ,x_return_status                OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_msg_count                    OUT      NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,x_msg_data                     OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);


/*=====================================================================
Procedure Name:      ADD_WP_PLAN_TYPE
Purpose:             This API checks if a Work Plan type is present in
                     the system.If is it not then it throws a error.
                     If WorkPlan Type is not attached to the project
                     then it attaches it.
                     This would be called when workplan is enabled for
                     a project or template.
Parameters:
IN                   1)p_project_id IN SYSTEM.PA_NUM_TBL_TYPE
=======================================================================*/
PROCEDURE add_wp_plan_type
 (
       p_src_project_id               IN       pa_projects_all.project_id%TYPE
      ,p_targ_project_id              IN       pa_projects_all.project_id%TYPE
      ,x_return_status                OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
      ,x_msg_count                    OUT      NOCOPY NUMBER --File.Sql.39 bug 4440895
      ,x_msg_data                     OUT      NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 );



/*=====================================================================
Procedure Name:      check_and_create_task_rec_info
Purpose:             This is a private api in the package. This API will
                      validate the task data passed to the
                      update_planning_transactions api This API checks
                      for the existence of the element version id passed
                      in pa_resource_assignments. If some of the element
                      version Ids are not there then it call
                      add_planning_transactions API to create records in
                      pa_resource_assignments. This API will be called
                      only when the context is WORKPLAN
=======================================================================*/
/*******************************************************************************************************
As part of Bug 3749516 All References to Equipment Effort or Equip Resource Class has been removed in
PROCEDURE check_and_create_task_rec_info.
p_planned_equip_effort_tbl IN parameter has also been removed as they were not being  used/referred.
********************************************************************************************************/
 PROCEDURE check_and_create_task_rec_info
 (
    p_project_id                 IN   Pa_projects_all.project_id%TYPE
   ,p_struct_elem_version_id     IN   Pa_proj_element_versions.element_version_id%TYPE
   ,p_element_version_id_tbl     IN   SYSTEM.PA_NUM_TBL_TYPE
   ,p_planning_start_date_tbl    IN   SYSTEM.PA_DATE_TBL_TYPE
   ,p_planning_end_date_tbl      IN   SYSTEM.PA_DATE_TBL_TYPE
   ,p_planned_people_effort_tbl  IN   SYSTEM.PA_NUM_TBL_TYPE
   ,p_raw_cost_tbl               IN   SYSTEM.PA_NUM_TBL_TYPE /* Bug# 3720357 */
   ,p_burdened_cost_tbl          IN   SYSTEM.PA_NUM_TBL_TYPE /* Bug# 3720357 */
   ,p_apply_progress_flag        IN   VARCHAR2               /* Bug 3720357 */
   ,x_element_version_id_tbl     OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
   ,x_planning_start_date_tbl    OUT  NOCOPY SYSTEM.PA_DATE_TBL_TYPE --File.Sql.39 bug 4440895
   ,x_planning_end_date_tbl      OUT  NOCOPY SYSTEM.PA_DATE_TBL_TYPE --File.Sql.39 bug 4440895
   ,x_planned_effort_tbl         OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
   ,x_resource_assignment_id_tbl OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
   ,x_raw_cost_tbl               OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE /* Bug# 3720357 */ --File.Sql.39 bug 4440895
   ,x_burdened_cost_tbl          OUT  NOCOPY SYSTEM.PA_NUM_TBL_TYPE /* Bug# 3720357 */ --File.Sql.39 bug 4440895
   ,x_return_status              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_data                   OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                  OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
);



/*=============================================================================
 This api would be called for a finplan version, whenever there is a change
 either in planning level or resource list or rbs version.
==============================================================================*/

PROCEDURE Refresh_Plan_Txns(
           p_budget_version_id         IN   pa_budget_versions.budget_version_id%TYPE
          ,p_plan_level_change         IN   VARCHAR2
          ,p_resource_list_change      IN   VARCHAR2
          ,p_rbs_version_change        IN   VARCHAR2
          ,p_time_phase_change_flag    IN   VARCHAR2
	  ,p_ci_ver_agr_change_flag    IN   VARCHAR2 DEFAULT 'N' --IPM enhancement
          ,p_rev_der_method_change     IN   VARCHAR2 DEFAULT 'N' --Bug 5462471
          ,x_return_status             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                 OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                  OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


/* This API creates default task planning transactions for a new plan
 * version . Modified for IPM Changes added two parameters to see
    if it is being called from select tasks page and if all the
   resources have to be added. */

PROCEDURE Create_Default_Task_Plan_Txns (
        P_budget_version_id              IN              Number
       ,P_version_plan_level_code        IN              VARCHAR2
       ,p_calling_context                IN              VARCHAR2 DEFAULT 'CREATE_VERSION'
       ,p_add_all_resources_flag         IN              VARCHAR2 DEFAULT 'N'
       ,X_return_status                  OUT             NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
       ,X_msg_count                      OUT             NOCOPY NUMBER --File.Sql.39 bug 4440895
       ,X_msg_data                       OUT             NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

/*=============================================================================
 This api is called upon save from Additional Workplan Options page. Whenever
 there is a change in the Additional Workplan setting page, all the chages should
 be propagated to all the underlying workplan versions immediately upon save.
===============================================================================*/

PROCEDURE REFRESH_WP_SETTINGS(
           p_project_id                 IN      pa_budget_versions.project_id%TYPE
          ,p_resource_list_change       IN      VARCHAR2    DEFAULT 'N'    -- Bug 3619687
          ,p_time_phase_change          IN      VARCHAR2    DEFAULT 'N'    -- Bug 3619687
          ,p_rbs_version_change         IN      VARCHAR2    DEFAULT 'N'    -- Bug 3619687
          ,p_track_costs_flag_change    IN      VARCHAR2    DEFAULT 'N'    -- Bug 3619687
          ,x_return_status              OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                  OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                   OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*=============================================================================
 This api is called when ever RBS should be changed for budget versions.

 Usage:
 p_calling_context    --> 'ALL_CHILD_VERSIONS'
 p_budget_version_id  -->  null
                        If there is a change in RBS for a financial plan type
                        to push the change to the underlying budget version.
                        p_budget_version_id  would be null

 p_calling_context    --> 'SINGLE_VERSION'
 p_budget_version_id  --> not null, version id should be passed
                      --> This mode is useful for creation of working versions
                          out of published versions, or copy amounts case from
                          a different version
==============================================================================*/

PROCEDURE Refresh_rbs_for_versions(
          p_project_id            IN   pa_projects_all.project_id%TYPE
          ,p_fin_plan_type_id     IN   pa_budget_versions.fin_plan_type_id%TYPE
          ,p_calling_context      IN   VARCHAR2 Default 'ALL_CHILD_VERSIONS'
          ,p_budget_version_id    IN   pa_budget_versions.budget_version_id%TYPE Default null
          ,x_return_status        OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count            OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data             OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--This function returns 'N' if a record already exists in pa_resource_assignments
--for a given budget version id, task id and resource list member id
--Returns 'Y' if the record is not already there
FUNCTION DUP_EXISTS
( p_budget_version_id       IN pa_budget_versions.budget_version_id%TYPE
 ,p_task_id                 IN pa_tasks.task_id%TYPE
 ,p_resource_list_member_id IN pa_resource_list_members.resource_list_member_id%TYPE
 ,p_project_id              IN pa_projects_all.project_id%TYPE)
 RETURN VARCHAR2;

END PA_FP_PLANNING_TRANSACTION_PUB;



/
