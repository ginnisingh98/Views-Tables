--------------------------------------------------------
--  DDL for Package PA_TASKS_MAINT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TASKS_MAINT_PVT" AUTHID CURRENT_USER as
/*$Header: PATSKSVS.pls 120.2 2007/02/06 10:11:23 dthakker ship $*/

  --commented by rtarway in FP.M development, already defined in body
  --g_pkg_name                             CONSTANT VARCHAR2(30):= 'PA_TASKS_MAINT_PVT';

-- API name                      : CREATE_TASK
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_project_id                        IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_reference_task_id                 IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_peer_or_sub                       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_task_number                       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_task_name                         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_long_task_name                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_task_description                  IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_task_manager_person_id            IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_carrying_out_organization_id      IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_task_type_code                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_priority_code                     IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_work_type_id                      IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_service_type_code                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_milestone_flag                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_critical_flag                     IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_chargeable_flag                   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_billable_flag                     IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_receive_project_invoice_flag      IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_scheduled_start_date              IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_scheduled_finish_date             IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_estimated_start_date              IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_estimated_end_date                IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_actual_start_date                 IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_actual_finish_date                IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_task_start_date                   IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_task_completion_date              IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_baseline_start_date               IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_baseline_end_date                 IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_obligation_start_date             IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_obligation_end_date               IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_estimate_to_complete_work         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_baseline_work                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_scheduled_work                    IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_actual_work_to_date               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_work_unit                         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_progress_status_code              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_job_bill_rate_schedule_id         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_emp_bill_rate_schedule_id         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_pm_product_code                   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_pm_project_reference              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_pm_task_reference                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_pm_parent_task_reference          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_pa_parent_task_id                 IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_address_id                        IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_ready_to_bill_flag                IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_ready_to_distribute_flag          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_limit_to_txn_controls_flag        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_labor_bill_rate_org_id            IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_labor_std_bill_rate_schdl         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_labor_schedule_fixed_date         IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_labor_schedule_discount           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_nl_bill_rate_org_id               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_nl_std_bill_rate_schdl            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_nl_schedule_fixed_date            IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_nl_schedule_discount              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_labor_cost_multiplier_name        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_cost_ind_rate_sch_id              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_rev_ind_rate_sch_id               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_inv_ind_rate_sch_id               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_cost_ind_sch_fixed_date           IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_rev_ind_sch_fixed_date            IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_inv_ind_sch_fixed_date            IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_labor_sch_type                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_nl_sch_type                       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_early_start_date                  IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_early_finish_date                 IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_late_start_date                   IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_late_finish_date                  IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_attribute_category                IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute1                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute2                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute3                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute4                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute5                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute6                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute7                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute8                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute9                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute10                       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_allow_cross_charge_flag           IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_project_rate_date                 IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_project_rate_type                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_cc_process_labor_flag             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_labor_tp_schedule_id              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_labor_tp_fixed_date               IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_cc_process_nl_flag                IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_nl_tp_schedule_id                 IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_nl_tp_fixed_date                  IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_inc_proj_progress_flag            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_task_id                                 IN OUT NUMBER
--   x_display_seq                       OUT NUMBER
--   x_return_status                     OUT VARCHAR2
--   x_msg_count                         OUT NUMBER
--   x_msg_data                          OUT VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--
  procedure CREATE_TASK
  (
     p_api_version                       IN  NUMBER      := 1.0
    ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
    ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
    ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
    ,p_validation_level                  IN  VARCHAR2    := 100
    ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
    ,p_debug_mode                        IN  VARCHAR2    := 'N'

    ,p_project_id                        IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_reference_task_id                 IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_peer_or_sub                       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_task_number                       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_task_name                         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_long_task_name                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_task_description                  IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_task_manager_person_id            IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_carrying_out_organization_id      IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_task_type_code                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_priority_code                     IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_work_type_id                      IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_service_type_code                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_milestone_flag                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_critical_flag                     IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_chargeable_flag                   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_billable_flag                     IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_receive_project_invoice_flag      IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_scheduled_start_date              IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_scheduled_finish_date             IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_estimated_start_date              IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_estimated_end_date                IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_actual_start_date                 IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_actual_finish_date                IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_task_start_date                   IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_task_completion_date              IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_baseline_start_date               IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_baseline_end_date                 IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE

    ,p_obligation_start_date             IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_obligation_end_date               IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_estimate_to_complete_work         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_baseline_work                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_scheduled_work                    IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_actual_work_to_date               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_work_unit                         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_progress_status_code              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR

    ,p_job_bill_rate_schedule_id         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_emp_bill_rate_schedule_id         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_pm_product_code                   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_pm_project_reference              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_pm_task_reference                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_pm_parent_task_reference          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_pa_parent_task_id                 IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_address_id                        IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_ready_to_bill_flag                IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_ready_to_distribute_flag          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_limit_to_txn_controls_flag        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_labor_bill_rate_org_id            IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_labor_std_bill_rate_schdl         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_labor_schedule_fixed_date         IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_labor_schedule_discount           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_nl_bill_rate_org_id               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_nl_std_bill_rate_schdl            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_nl_schedule_fixed_date            IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_nl_schedule_discount              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_labor_cost_multiplier_name        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_cost_ind_rate_sch_id              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_rev_ind_rate_sch_id               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_inv_ind_rate_sch_id               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_cost_ind_sch_fixed_date           IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_rev_ind_sch_fixed_date            IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_inv_ind_sch_fixed_date            IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_labor_sch_type                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_nl_sch_type                       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_early_start_date                  IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_early_finish_date                 IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_late_start_date                   IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_late_finish_date                  IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_attribute_category                IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_attribute1                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_attribute2                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_attribute3                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_attribute4                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_attribute5                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_attribute6                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_attribute7                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_attribute8                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_attribute9                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_attribute10                       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_allow_cross_charge_flag           IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_project_rate_date                 IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_project_rate_type                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_cc_process_labor_flag             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_labor_tp_schedule_id              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_labor_tp_fixed_date               IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_cc_process_nl_flag                IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_nl_tp_schedule_id                 IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_nl_tp_fixed_date                  IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_inc_proj_progress_flag            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_taskfunc_cost_rate_type           IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_taskfunc_cost_rate_date           IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_non_lab_std_bill_rt_sch_id        IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_labor_disc_reason_code            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_non_labor_disc_reason_code        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--PA L Capital Project Changes 2872708
    ,p_retirement_cost_flag              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_cint_eligible_flag                IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_cint_stop_date                    IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--End PA L Capital Project Changes 2872708

    ,p_task_id                                IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_display_seq                       OUT NOCOPY NUMBER --File.Sql.39 bug 4440895

    ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count                         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data                          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

-- API name                      : UPDATE_TASK
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_api_version                       IN  NUMBER      := 1.0
--   p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--   p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--   p_validation_level                  IN  VARCHAR2    := 100
--   p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--   p_debug_mode                        IN  VARCHAR2    := 'N'
--   p_project_id                        IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_task_id                           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_task_number                       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_task_name                         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_long_task_name                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_task_description                  IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_task_manager_person_id            IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_carrying_out_organization_id      IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_task_type_code                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_priority_code                     IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_work_type_id                      IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_service_type_code                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_milestone_flag                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_critical_flag                     IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_chargeable_flag                   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_billable_flag                     IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_receive_project_invoice_flag      IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_scheduled_start_date              IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_scheduled_finish_date             IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_estimated_start_date              IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_estimated_end_date                IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_actual_start_date                 IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_actual_finish_date                IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_task_start_date                   IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_task_completion_date              IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_baseline_start_date               IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_baseline_end_date                 IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_obligation_start_date             IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_obligation_end_date               IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_estimate_to_complete_work         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_baseline_work                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_scheduled_work                    IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_actual_work_to_date               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_work_unit                         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_progress_status_code              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_job_bill_rate_schedule_id         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_emp_bill_rate_schedule_id         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_pm_product_code                   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_pm_project_reference              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_pm_task_reference                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_pm_parent_task_reference          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_top_task_id                       IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_wbs_level                         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_parent_task_id                    IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_display_sequence                  IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_address_id                        IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_ready_to_bill_flag                IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_ready_to_distribute_flag          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_limit_to_txn_controls_flag        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_labor_bill_rate_org_id            IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_labor_std_bill_rate_schdl         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_labor_schedule_fixed_date         IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_labor_schedule_discount           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_nl_bill_rate_org_id               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_nl_std_bill_rate_schdl            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_nl_schedule_fixed_date            IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_nl_schedule_discount              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_labor_cost_multiplier_name        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_cost_ind_rate_sch_id              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_rev_ind_rate_sch_id               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_inv_ind_rate_sch_id               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_cost_ind_sch_fixed_date           IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_rev_ind_sch_fixed_date            IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_inv_ind_sch_fixed_date            IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_labor_sch_type                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_nl_sch_type                       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_early_start_date                  IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_early_finish_date                 IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_late_start_date                   IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_late_finish_date                  IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_attribute_category                IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute1                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute2                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute3                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute4                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute5                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute6                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute7                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute8                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute9                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_attribute10                       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_allow_cross_charge_flag           IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_project_rate_date                 IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_project_rate_type                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_cc_process_labor_flag             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_labor_tp_schedule_id              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_labor_tp_fixed_date               IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_cc_process_nl_flag                IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_nl_tp_schedule_id                 IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_nl_tp_fixed_date                  IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--   p_inc_proj_progress_flag            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_record_version_number             IN  NUMBER
--   p_comments                          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   x_return_status                     OUT VARCHAR2
--   x_msg_count                         OUT NUMBER
--   x_msg_data                          OUT VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--

  procedure UPDATE_TASK
  (
     p_api_version                       IN  NUMBER      := 1.0
    ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
    ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
    ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
    ,p_validation_level                  IN  VARCHAR2    := 100
    ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
    ,p_debug_mode                        IN  VARCHAR2    := 'N'

    ,p_project_id                        IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_task_id                           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_task_number                       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_task_name                         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_long_task_name                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_task_description                  IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_task_manager_person_id            IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_carrying_out_organization_id      IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_task_type_code                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_priority_code                     IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_work_type_id                      IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_service_type_code                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_milestone_flag                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_critical_flag                     IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_chargeable_flag                   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_billable_flag                     IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_receive_project_invoice_flag      IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_scheduled_start_date              IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_scheduled_finish_date             IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_estimated_start_date              IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_estimated_end_date                IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_actual_start_date                 IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_actual_finish_date                IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_task_start_date                   IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_task_completion_date              IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_baseline_start_date               IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_baseline_end_date                 IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE

    ,p_obligation_start_date             IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_obligation_end_date               IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_estimate_to_complete_work         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_baseline_work                     IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_scheduled_work                    IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_actual_work_to_date               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_work_unit                         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_progress_status_code              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR

    ,p_job_bill_rate_schedule_id         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_emp_bill_rate_schedule_id         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_pm_product_code                   IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_pm_project_reference              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_pm_task_reference                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_pm_parent_task_reference          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_top_task_id                       IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_wbs_level                         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_parent_task_id                    IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_display_sequence                  IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_address_id                        IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_ready_to_bill_flag                IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_ready_to_distribute_flag          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_limit_to_txn_controls_flag        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_labor_bill_rate_org_id            IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_labor_std_bill_rate_schdl         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_labor_schedule_fixed_date         IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_labor_schedule_discount           IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_nl_bill_rate_org_id               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_nl_std_bill_rate_schdl            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_nl_schedule_fixed_date            IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_nl_schedule_discount              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_labor_cost_multiplier_name        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_cost_ind_rate_sch_id              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_rev_ind_rate_sch_id               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_inv_ind_rate_sch_id               IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_cost_ind_sch_fixed_date           IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_rev_ind_sch_fixed_date            IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_inv_ind_sch_fixed_date            IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_labor_sch_type                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_nl_sch_type                       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_early_start_date                  IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_early_finish_date                 IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_late_start_date                   IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_late_finish_date                  IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_attribute_category                IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_attribute1                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_attribute2                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_attribute3                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_attribute4                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_attribute5                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_attribute6                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_attribute7                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_attribute8                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_attribute9                        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_attribute10                       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_allow_cross_charge_flag           IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_project_rate_date                 IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_project_rate_type                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_cc_process_labor_flag             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_labor_tp_schedule_id              IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_labor_tp_fixed_date               IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_cc_process_nl_flag                IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_nl_tp_schedule_id                 IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_nl_tp_fixed_date                  IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_inc_proj_progress_flag            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_taskfunc_cost_rate_type           IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_taskfunc_cost_rate_date           IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
    ,p_non_lab_std_bill_rt_sch_id        IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_record_version_number             IN  NUMBER
    ,p_comments                          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_labor_disc_reason_code            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_non_labor_disc_reason_code        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--PA L Capital Project Changes 2872708
    ,p_retirement_cost_flag              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_cint_eligible_flag                IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_cint_stop_date                    IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--End PA L Capital Project Changes 2872708
    ,p_gen_etc_src_code                  IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_dates_check                       IN  VARCHAR2    := 'Y'  --bug 5665772
    ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count                         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data                          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


  procedure DELETE_TASK
  (
     p_api_version                       IN  NUMBER      := 1.0
    ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
    ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
    ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
    ,p_validation_level                  IN  VARCHAR2    := 100
    ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
    ,p_debug_mode                        IN  VARCHAR2    := 'N'
    ,p_task_id                                 IN  NUMBER
    ,p_record_version_number             IN  NUMBER
    ,p_called_from_api      IN    VARCHAR2    := 'ABCD'
    ,p_bulk_flag                         IN  VARCHAR2    := 'N' -- 4201927
    ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count                         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data                          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );
-- API name                      : Indent_Task
-- Type                          : Private procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_commit                    IN    VARCHAR2   REQUIRED   DEFAULT=FND_API.G_FALSE
-- p_validate_only       IN  VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_validation_level        IN  NUMBER     OPTIONAL   DEFAULT=FND_API.G_VALID_LEVEL_FULL
-- p_calling_module      IN      VARCHAR2   OPTIONAL   DEFAULT='SELF_SERVICE'
-- p_debug_mode              IN  VARCHAR2   OPTIONAL   DEFAULT='N'
-- p_max_msg_count       IN  NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_project_id              IN  NUMBER     REQUIRED
-- p_task_id                   IN    NUMBER     REQUIRED
-- p_record_version_number   IN  NUMBER     REQUIRED   DEFAULT=1
-- x_return_status         OUT   VARCHAR2   REQUIRED
-- x_msg_count               OUT     VARCHAR2   REQUIRED
-- x_msg_data                OUT     VARCHAR2   REQUIRED
--
--  History
--
--  25-JUN-01   Majid Ansari             -Created
--
--

 PROCEDURE Indent_Task(
   p_commit                    IN    VARCHAR2    DEFAULT FND_API.G_FALSE
  ,p_validate_only       IN  VARCHAR2    DEFAULT FND_API.G_TRUE
  ,p_validation_level        IN  NUMBER      DEFAULT FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module      IN      VARCHAR2    DEFAULT 'SELF_SERVICE'
  ,p_debug_mode              IN  VARCHAR2    DEFAULT 'N'
  ,p_max_msg_count       IN  NUMBER      DEFAULT FND_API.G_MISS_NUM
  ,p_project_id              IN  NUMBER
  ,p_task_id                   IN    NUMBER
  ,p_record_version_number   IN  NUMBER      DEFAULT 1
  ,x_return_status         OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_data                OUT     NOCOPY VARCHAR2   ); --File.Sql.39 bug 4440895

-- API name                      : Outdent_Task
-- Type                          : Private procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_commit                    IN    VARCHAR2   REQUIRED   DEFAULT=FND_API.G_FALSE
-- p_validate_only       IN  VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_validation_level        IN  NUMBER     OPTIONAL   DEFAULT=FND_API.G_VALID_LEVEL_FULL
-- p_calling_module      IN      VARCHAR2   OPTIONAL   DEFAULT='SELF_SERVICE'
-- p_debug_mode              IN  VARCHAR2   OPTIONAL   DEFAULT='N'
-- p_max_msg_count       IN  NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_project_id              IN  NUMBER     REQUIRED
-- p_task_id                   IN    NUMBER     REQUIRED
-- p_record_version_number   IN  NUMBER     REQUIRED   DEFAULT=1
-- x_return_status         OUT   VARCHAR2   REQUIRED
-- x_msg_count               OUT     VARCHAR2   REQUIRED
-- x_msg_data                OUT     VARCHAR2   REQUIRED
--
--  History
--
--  25-JUN-01   Majid Ansari             -Created
--
--

 PROCEDURE Outdent_Task(
   p_commit                    IN    VARCHAR2    DEFAULT FND_API.G_FALSE
  ,p_validate_only       IN  VARCHAR2    DEFAULT FND_API.G_TRUE
  ,p_validation_level        IN  NUMBER      DEFAULT FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module      IN      VARCHAR2    DEFAULT 'SELF_SERVICE'
  ,p_debug_mode              IN  VARCHAR2    DEFAULT 'N'
  ,p_max_msg_count       IN  NUMBER      DEFAULT FND_API.G_MISS_NUM
  ,p_project_id              IN  NUMBER
  ,p_task_id                   IN    NUMBER
  ,p_record_version_number   IN  NUMBER      DEFAULT 1
  ,x_return_status         OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_data                OUT     NOCOPY VARCHAR2   ); --File.Sql.39 bug 4440895



-- API name                      : Copy_Entire_Project
-- Type                          : Private procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_commit                    IN    VARCHAR2   REQUIRED   DEFAULT=FND_API.G_FALSE
-- p_validate_only       IN  VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_validation_level        IN  NUMBER     OPTIONAL   DEFAULT=FND_API.G_VALID_LEVEL_FULL
-- p_calling_module      IN      VARCHAR2   OPTIONAL   DEFAULT='SELF_SERVICE'
-- p_debug_mode              IN  VARCHAR2   OPTIONAL   DEFAULT='N'
-- p_max_msg_count       IN  NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_reference_project_id      IN    NUMBER
-- p_reference_task_id         IN    NUMBER
-- p_project_id                IN    NUMBER
-- p_peer_or_sub                    IN    VARCHAR2
-- p_task_prefix               IN    VARCHAR2   --
-- x_return_status         OUT   VARCHAR2   REQUIRED
-- x_msg_count               OUT     VARCHAR2   REQUIRED
-- x_msg_data                OUT     VARCHAR2   REQUIRED
--
--  History
--
--  25-JUN-01   Majid Ansari             -Created
--
--

 PROCEDURE Copy_Entire_Project(
   p_commit                    IN    VARCHAR2    DEFAULT FND_API.G_FALSE
  ,p_validate_only       IN  VARCHAR2    DEFAULT FND_API.G_TRUE
  ,p_validation_level        IN  NUMBER      DEFAULT FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module      IN      VARCHAR2    DEFAULT 'SELF_SERVICE'
  ,p_debug_mode              IN  VARCHAR2    DEFAULT 'N'
  ,p_max_msg_count       IN  NUMBER      DEFAULT FND_API.G_MISS_NUM
  ,p_reference_project_id      IN    NUMBER
  ,p_reference_task_id         IN    NUMBER
  ,p_project_id                IN    NUMBER
  ,p_peer_or_sub                    IN    VARCHAR2
  ,p_task_prefix               IN    VARCHAR2
  ,x_return_status         OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_data                OUT     NOCOPY VARCHAR2   ); --File.Sql.39 bug 4440895


-- API name                      : Copy_Selected_Task
-- Type                          : Private procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_commit                    IN    VARCHAR2   REQUIRED   DEFAULT=FND_API.G_FALSE
-- p_validate_only       IN  VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_validation_level        IN  NUMBER     OPTIONAL   DEFAULT=FND_API.G_VALID_LEVEL_FULL
-- p_calling_module      IN      VARCHAR2   OPTIONAL   DEFAULT='SELF_SERVICE'
-- p_debug_mode              IN  VARCHAR2   OPTIONAL   DEFAULT='N'
-- p_max_msg_count       IN  NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_reference_project_id      IN    NUMBER
-- p_reference_task_id         IN    NUMBER
-- p_task_id                   IN    NUMBER
-- p_peer_or_sub                    IN    VARCHAR2
-- p_task_prefix               IN    VARCHAR2   --
-- x_return_status         OUT   VARCHAR2   REQUIRED
-- x_msg_count               OUT     VARCHAR2   REQUIRED
-- x_msg_data                OUT     VARCHAR2   REQUIRED
--
--  History
--
--  25-JUN-01   Majid Ansari             -Created
--
--

 PROCEDURE Copy_Selected_Task(
   p_commit                    IN    VARCHAR2    DEFAULT FND_API.G_FALSE
  ,p_validate_only       IN  VARCHAR2    DEFAULT FND_API.G_TRUE
  ,p_validation_level        IN  NUMBER      DEFAULT FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module      IN      VARCHAR2    DEFAULT 'SELF_SERVICE'
  ,p_debug_mode              IN  VARCHAR2    DEFAULT 'N'
  ,p_max_msg_count       IN  NUMBER      DEFAULT FND_API.G_MISS_NUM
  ,p_reference_project_id      IN    NUMBER
  ,p_reference_task_id         IN    NUMBER
  ,p_task_id                   IN    NUMBER
  ,p_peer_or_sub                    IN    VARCHAR2
  ,p_task_prefix               IN    VARCHAR2
  ,x_return_status         OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_data                OUT     NOCOPY VARCHAR2   ); --File.Sql.39 bug 4440895


-- API name                      : Copy_Entire_Task
-- Type                          : Private procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_commit                    IN    VARCHAR2   REQUIRED   DEFAULT=FND_API.G_FALSE
-- p_validate_only       IN  VARCHAR2   REQUIRED   DEFAULT=FND_API.G_TRUE
-- p_validation_level        IN  NUMBER     OPTIONAL   DEFAULT=FND_API.G_VALID_LEVEL_FULL
-- p_calling_module      IN      VARCHAR2   OPTIONAL   DEFAULT='SELF_SERVICE'
-- p_debug_mode              IN  VARCHAR2   OPTIONAL   DEFAULT='N'
-- p_max_msg_count       IN  NUMBER     OPTIONAL   DEFAULT=FND_API.G_MISS_NUM
-- p_reference_project_id      IN    NUMBER
-- p_reference_task_id         IN    NUMBER
-- p_project_id                IN    NUMBER
-- p_task_id                   IN    NUMBER
-- p_peer_or_sub                    IN    VARCHAR2
-- p_task_prefix               IN    VARCHAR2   --
-- x_return_status         OUT   VARCHAR2   REQUIRED
-- x_msg_count               OUT     VARCHAR2   REQUIRED
-- x_msg_data                OUT     VARCHAR2   REQUIRED
--
--  History
--
--  25-JUN-01   Majid Ansari             -Created
--
--

 PROCEDURE Copy_Entire_Task(
   p_commit                    IN    VARCHAR2    DEFAULT FND_API.G_FALSE
  ,p_validate_only       IN  VARCHAR2    DEFAULT FND_API.G_TRUE
  ,p_validation_level        IN  NUMBER      DEFAULT FND_API.G_VALID_LEVEL_FULL
  ,p_calling_module      IN      VARCHAR2    DEFAULT 'SELF_SERVICE'
  ,p_debug_mode              IN  VARCHAR2    DEFAULT 'N'
  ,p_max_msg_count       IN  NUMBER      DEFAULT FND_API.G_MISS_NUM
  ,p_reference_project_id      IN    NUMBER
  ,p_reference_task_id         IN    NUMBER
  ,p_project_id                IN    NUMBER
  ,p_task_id                   IN    NUMBER
  ,p_peer_or_sub                    IN    VARCHAR2
  ,p_task_prefix               IN    VARCHAR2
  ,x_return_status         OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_data                OUT     NOCOPY VARCHAR2   ); --File.Sql.39 bug 4440895


-- API name                      : Move_Task
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Prameters
-- p_api_version                       IN  NUMBER      := 1.0
-- p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
-- p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
-- p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
-- p_validation_level                  IN  VARCHAR2    := 100
-- p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
-- p_debug_mode                        IN  VARCHAR2    := 'N'
-- p_reference_project_id              IN  NUMBER
-- p_reference_task_id                 IN  NUMBER
-- p_project_id                        IN  NUMBER
-- p_task_id                           IN  NUMBER
-- p_peer_or_sub                       IN  VARCHAR2
-- p_record_version_number             IN  NUMBER
-- x_return_status                     OUT VARCHAR2
-- x_msg_count                         OUT NUMBER
-- x_msg_data                          OUT VARCHAR2
--
--  History
--
--  02-JUL-01   Majid Ansari             -Created
--
--

 PROCEDURE Move_Task(
    p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_reference_project_id              IN  NUMBER
   ,p_reference_task_id                 IN  NUMBER
   ,p_project_id                        IN  NUMBER
   ,p_task_id                           IN  NUMBER
   ,p_peer_or_sub                       IN  VARCHAR2
   ,p_record_version_number             IN  NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

--Begin add by rtarway for FP.M development
  PROCEDURE SET_UNSET_FINANCIAL_TASK
    (
       p_api_version           IN   NUMBER   := 1.0
     , p_init_msg_list         IN   VARCHAR2 := FND_API.G_TRUE
     , p_commit                IN   VARCHAR2 := FND_API.G_FALSE
     , p_validate_only         IN   VARCHAR2 := FND_API.G_FALSE
     , p_validation_level      IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
     , p_calling_module        IN   VARCHAR2 := 'SELF_SERVICE'
     , p_task_version_id       IN   NUMBER
    , p_project_id            IN   NUMBER
     , p_checked_flag          IN   VARCHAR2
     , p_debug_mode            IN   VARCHAR2 := 'N'
     , x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   );
  PROCEDURE SYNC_UP_WP_TASKS_WITH_FIN
    (
       p_api_version                    IN   NUMBER   := 1.0
     , p_init_msg_list                  IN   VARCHAR2 := FND_API.G_TRUE
     , p_commit                         IN   VARCHAR2 := FND_API.G_FALSE
     , p_validate_only                  IN   VARCHAR2 := FND_API.G_FALSE
     , p_validation_level               IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
     , p_calling_module                 IN   VARCHAR2 := 'SELF_SERVICE'
     , p_debug_mode                     IN   VARCHAR2 := 'N'
     , p_parent_task_version_id         IN   NUMBER   := FND_API.G_MISS_NUM
     , p_patask_record_version_number   IN   NUMBER   := FND_API.G_MISS_NUM
     , p_project_id                     IN   NUMBER
     , p_syncup_all_tasks               IN   VARCHAR2 := 'N'
     , p_task_version_id                IN   NUMBER   := FND_API.G_MISS_NUM
     , p_structure_version_id           IN   NUMBER   := FND_API.G_MISS_NUM
     , p_checked_flag                   IN   VARCHAR2 := FND_API.G_MISS_CHAR
     , p_mode                           IN   VARCHAR2 := 'SINGLE'
     , x_return_status                  OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count                      OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data                       OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   );


--End add by rtarway for FP.M development
end PA_TASKS_MAINT_PVT;

/
