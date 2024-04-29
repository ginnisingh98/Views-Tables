--------------------------------------------------------
--  DDL for Package Body PA_TASKS_MAINT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TASKS_MAINT_PUB" as
/*$Header: PATSKSPB.pls 120.5.12010000.3 2009/02/26 13:47:52 bifernan ship $*/

  g_pkg_name                             CONSTANT VARCHAR2(30):= 'PA_TASKS_MAINT_PUB';
 --begin add by rtarwat for FP.M developement
  Invalid_Arg_Exc_WP Exception;
  --begin add by rtarwat for FP.M developement
  -- API Name:        CREATE_TASK
  -- Type:            PUBLIC
  -- Parameters:

-- API name                      : CREATE_TASK
-- Type                          : Public Procedure
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
--   p_project_id                        IN  NUMBER
--   p_reference_task_id                 IN  NUMBER
--   p_reference_task_name               IN  VARCHAR2
--   p_peer_or_sub                       IN  VARCHAR2
--   p_task_number                       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_task_name                         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_long_task_name                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_task_description                  IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_task_manager_name                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_task_manager_person_id            IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_carrying_out_org_name             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
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
--   p_wbs_record_version_number         IN  NUMBER
--   p_task_id                                 OUT NUMBER
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

    ,p_project_id                        IN  NUMBER
    ,p_reference_task_id                 IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_reference_task_name               IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_peer_or_sub                       IN  VARCHAR2
    ,p_task_number                       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_task_name                         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_long_task_name                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_task_description                  IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_task_manager_name                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_task_manager_person_id            IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_carrying_out_org_name             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
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
    ,p_wbs_record_version_number         IN  NUMBER
    ,p_labor_disc_reason_code            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_non_labor_disc_reason_code        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--PA L Capital Project Changes 2872708
    ,p_retirement_cost_flag              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_cint_eligible_flag                IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_cint_stop_date                    IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--End PA L Capital Project Changes 2872708

    ,p_task_id                                 IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895

    ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count                         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data                          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_api_name                           CONSTANT VARCHAR2(30)  := 'CREATE_TASK';
    l_api_version                        CONSTANT NUMBER        := 1.0;
    l_msg_count                          NUMBER;
    l_msg_data                           VARCHAR2(250);
    l_data                               VARCHAR2(250);
    l_msg_index_out                      NUMBER;

    l_ref_task_id                        NUMBER;
    l_carrying_out_org_id                NUMBER;
    l_task_manager_id                    NUMBER;

    l_return_status                      VARCHAR2(1);
    l_error_msg_code                     VARCHAR2(250);
    l_display_seq                        NUMBER;

    l_dummy                              VARCHAR2(1);
    l_max_seq                            NUMBER;
    l_carrying_out_org_name              VARCHAR2(250);

  BEGIN

    pa_tasks_maint_utils.set_org_id(p_project_id);

    pa_debug.init_err_stack('PA_TASKS_MAINT_PUB.CREATE_TASK');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASKS_MAINT_PUB.CREATE_TASK begin');
    END IF;

    IF p_commit = FND_API.G_TRUE THEN
      savepoint CREATE_TASK;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_FALSE)) THEN
      pa_debug.debug('Performing ID validations and conversions');
      FND_MSG_PUB.initialize;
    END IF;

    --BEGIN VALIDATIONS

    IF (p_calling_module = 'SELF_SERVICE') OR (p_calling_module = 'EXCHANGE') THEN
    --Check Reference Task Name and Id

      IF ((p_reference_task_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
          (p_reference_task_name IS NOT NULL)) OR
         ((p_reference_task_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
          (p_reference_task_id IS NOT NULL)) THEN

         --Call Check API.
      /*   pa_tasks_maint_utils.CHECK_TASK_NAME_OR_ID(
             p_project_id     => p_project_id,
               p_task_name      => p_reference_task_name,
             p_task_id        => p_reference_task_id,
               p_check_id_flag => PA_STARTUP.G_Check_ID_Flag,
             x_task_id        => l_ref_task_id,
             x_return_status  => l_return_status,
             x_error_msg_code => l_error_msg_code);*/

        l_ref_task_id := p_reference_task_id;
        l_return_status := FND_API.G_RET_STS_SUCCESS;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => l_error_msg_code);
        END IF;
      END IF; --End Name-Id Conversion

        --Check Task Manager and Task Manager Id
      IF ((p_task_manager_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
          (p_task_manager_name IS NOT NULL)) OR
         ((p_task_manager_person_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
          (p_task_manager_person_id IS NOT NULL)) THEN
        --Call Check API.

/*          pa_tasks_maint_utils.check_task_mgr_name_or_id(
            p_task_mgr_name => p_task_manager_name,
            p_task_mgr_id => p_task_manager_person_id,
            p_check_id_flag => PA_STARTUP.G_Check_ID_Flag,
            x_task_mgr_id => l_task_manager_id,
            x_return_status => l_return_status,
            x_error_msg_code => l_error_msg_code);*/

        l_task_manager_id := p_task_manager_person_id;
        l_return_status := FND_API.G_RET_STS_SUCCESS;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => l_error_msg_code);
-- dbms_output.put_line( 'Error occured in task manager name to id conv. ' );
        END IF;

      END IF; --End Name-Id Conversion

--dbms_output.put_line( 'Check Carrying out organization name and Carrying out organization Id ' || p_carrying_out_organization_id);

    --Check Carrying out organization name and Carrying out organization Id
      IF p_carrying_out_org_name = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
      THEN
         l_carrying_out_org_name := FND_API.G_MISS_CHAR;
      ELSE
         l_carrying_out_org_name := p_carrying_out_org_name;
      END IF;

      IF p_carrying_out_organization_id = PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
      THEN
         l_carrying_out_org_id := FND_API.G_MISS_NUM;
      ELSE
         l_carrying_out_org_id := p_carrying_out_organization_id;
      END IF;

      IF ((l_carrying_out_org_name <> FND_API.G_MISS_CHAR) AND
          (l_carrying_out_org_name IS NOT NULL)) OR
         ((l_carrying_out_org_id <> FND_API.G_MISS_NUM) AND
          (l_carrying_out_org_id IS NOT NULL)) THEN

/*        pa_hr_org_utils.Check_OrgName_Or_Id
            (p_organization_id      => l_carrying_out_org_id
             ,p_organization_name   => l_carrying_out_org_name
             ,p_check_id_flag       => 'Y'
             ,x_organization_id     => l_carrying_out_org_id
             ,x_return_status       => l_return_status
             ,x_error_msg_code      => l_error_msg_code);*/

        l_return_status := FND_API.G_RET_STS_SUCCESS;

        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => l_error_msg_code);
--dbms_output.put_line( 'Error occured in org name to id conv. ' );

        END IF;
      END IF; --End Name-Id Conversion
    ELSE
        l_ref_task_id := p_reference_task_id;
        l_carrying_out_org_id := p_carrying_out_organization_id;
        l_task_manager_id := p_task_manager_person_id;
    END IF;

    --Check if there is any error
    l_msg_count := FND_MSG_PUB.count_msg;
    if l_msg_count > 0 then
      x_msg_count := l_msg_count;
      if x_msg_count = 1 then
        pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      end if;
      raise FND_API.G_EXC_ERROR;
    end if;

--dbms_output.put_line( 'Call Lock project ' );

    --Call Lock project
/*    PA_TASKS_MAINT_UTILS.LOCK_PROJECT(
          p_validate_only             => p_validate_only,
          p_calling_module            => p_calling_module,
          p_project_id                => p_project_id,
          p_wbs_record_version_number => p_wbs_record_version_number,
          x_return_status           => x_return_status,
          x_msg_data                  => x_msg_data );   */

--dbms_output.put_line( 'Call Private API ' );


    --Call Private API
    PA_TASKS_MAINT_PVT.CREATE_TASK
    (
    p_commit => p_commit
    ,p_calling_module => p_calling_module
    ,p_validate_only => p_validate_only
    ,p_debug_mode => p_debug_mode

    ,p_project_id => p_project_id
    ,p_reference_task_id => l_ref_task_id
    ,p_peer_or_sub => p_peer_or_sub
    ,p_task_number => p_task_number
    ,p_task_name => p_task_name
    ,p_long_task_name => p_long_task_name
    ,p_task_description => p_task_description
    ,p_task_manager_person_id => l_task_manager_id
    ,p_carrying_out_organization_id => l_carrying_out_org_id
    ,p_task_type_code => p_task_type_code
    ,p_priority_code => p_priority_code
    ,p_work_type_id => p_work_type_id
    ,p_service_type_code => p_service_type_code
    ,p_milestone_flag => p_milestone_flag
    ,p_critical_flag => p_critical_flag
    ,p_chargeable_flag => p_chargeable_flag
    ,p_billable_flag => p_billable_flag
    ,p_receive_project_invoice_flag => p_receive_project_invoice_flag
    ,p_inc_proj_progress_flag => p_inc_proj_progress_flag
    ,p_scheduled_start_date => p_scheduled_start_date
    ,p_scheduled_finish_date => p_scheduled_finish_date
    ,p_estimated_start_date => p_estimated_start_date
    ,p_estimated_end_date => p_estimated_end_date
    ,p_actual_start_date => p_actual_start_date
    ,p_actual_finish_date => p_actual_finish_date
    ,p_task_start_date => p_task_start_date
    ,p_task_completion_date => p_task_completion_date
    ,p_baseline_start_date => p_baseline_start_date
    ,p_baseline_end_date => p_baseline_end_date

    ,p_obligation_start_date => p_obligation_start_date
    ,p_obligation_end_date => p_obligation_end_date
    ,p_estimate_to_complete_work => p_estimate_to_complete_work
    ,p_baseline_work => p_baseline_work
    ,p_scheduled_work => p_scheduled_work
    ,p_actual_work_to_date => p_actual_work_to_date
    ,p_work_unit => p_work_unit
    ,p_progress_status_code => p_progress_status_code

    ,p_job_bill_rate_schedule_id =>p_job_bill_rate_schedule_id
    ,p_emp_bill_rate_schedule_id =>p_emp_bill_rate_schedule_id
    ,p_pm_product_code =>p_pm_product_code
    ,p_pm_project_reference =>p_pm_project_reference
    ,p_pm_task_reference =>p_pm_task_reference
    ,p_pm_parent_task_reference =>p_pm_parent_task_reference
    ,p_pa_parent_task_id =>p_pa_parent_task_id
    ,p_address_id =>p_address_id
    ,p_ready_to_bill_flag =>p_ready_to_bill_flag
    ,p_ready_to_distribute_flag =>p_ready_to_distribute_flag
    ,p_limit_to_txn_controls_flag =>p_limit_to_txn_controls_flag
    ,p_labor_bill_rate_org_id =>p_labor_bill_rate_org_id
    ,p_labor_std_bill_rate_schdl =>p_labor_std_bill_rate_schdl
    ,p_labor_schedule_fixed_date =>p_labor_schedule_fixed_date
    ,p_labor_schedule_discount =>p_labor_schedule_discount
    ,p_nl_bill_rate_org_id =>p_nl_bill_rate_org_id
    ,p_nl_std_bill_rate_schdl =>p_nl_std_bill_rate_schdl
    ,p_nl_schedule_fixed_date =>p_nl_schedule_fixed_date
    ,p_nl_schedule_discount =>p_nl_schedule_discount
    ,p_labor_cost_multiplier_name =>p_labor_cost_multiplier_name
    ,p_cost_ind_rate_sch_id =>p_cost_ind_rate_sch_id
    ,p_rev_ind_rate_sch_id =>p_rev_ind_rate_sch_id
    ,p_inv_ind_rate_sch_id =>p_inv_ind_rate_sch_id
    ,p_cost_ind_sch_fixed_date =>p_cost_ind_sch_fixed_date
    ,p_rev_ind_sch_fixed_date =>p_rev_ind_sch_fixed_date
    ,p_inv_ind_sch_fixed_date =>p_inv_ind_sch_fixed_date
    ,p_labor_sch_type =>p_labor_sch_type
    ,p_nl_sch_type =>p_nl_sch_type
    ,p_early_start_date =>p_early_start_date
    ,p_early_finish_date =>p_early_finish_date
    ,p_late_start_date =>p_late_start_date
    ,p_late_finish_date =>p_late_finish_date
    ,p_attribute_category =>p_attribute_category
    ,p_attribute1 =>p_attribute1
    ,p_attribute2 =>p_attribute2
    ,p_attribute3 =>p_attribute3
    ,p_attribute4 =>p_attribute4
    ,p_attribute5 =>p_attribute5
    ,p_attribute6 =>p_attribute6
    ,p_attribute7 =>p_attribute7
    ,p_attribute8 =>p_attribute8
    ,p_attribute9 =>p_attribute9
    ,p_attribute10 =>p_attribute10
    ,p_allow_cross_charge_flag =>p_allow_cross_charge_flag
    ,p_project_rate_date =>p_project_rate_date
    ,p_project_rate_type =>p_project_rate_type
    ,p_cc_process_labor_flag =>p_cc_process_labor_flag
    ,p_labor_tp_schedule_id =>p_labor_tp_schedule_id
    ,p_labor_tp_fixed_date =>p_labor_tp_fixed_date
    ,p_cc_process_nl_flag =>p_cc_process_nl_flag
    ,p_nl_tp_schedule_id =>p_nl_tp_schedule_id
    ,p_nl_tp_fixed_date =>p_nl_tp_fixed_date

    ,p_taskfunc_cost_rate_type           => p_taskfunc_cost_rate_type
    ,p_taskfunc_cost_rate_date           => p_taskfunc_cost_rate_date
    ,p_non_lab_std_bill_rt_sch_id        => p_non_lab_std_bill_rt_sch_id
-- FP.K changes msundare
    ,p_labor_disc_reason_code            => p_labor_disc_reason_code
    ,p_non_labor_disc_reason_code        => p_non_labor_disc_reason_code
--PA L Capital Project Changes 2872708
    ,p_retirement_cost_flag               => p_retirement_cost_flag
    ,p_cint_eligible_flag                 => p_cint_eligible_flag
    ,p_cint_stop_date                     => p_cint_stop_date
--End PA L Capital Project Changes 2872708

    ,p_task_id =>p_task_id
    ,x_display_seq => l_display_seq
    ,x_return_status =>l_return_status
    ,x_msg_count =>x_msg_count
    ,x_msg_data =>x_msg_data
    );

--dbms_output.put_line( 'After exis creat task pvt api call in pub api' );

    --Check return status
    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      x_msg_count := FND_MSG_PUB.count_msg;
      if x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      end if;
      raise FND_API.G_EXC_ERROR;
    end if;

    --Call Update statement to update display order
    BEGIN
--dbms_output.put_line( 'before select max( seq no' );
/* HY
      -- Need to get max number
      select max(display_sequence)
      into l_max_seq
      from PA_TASKS
      where project_id = p_project_id;

--dbms_output.put_line( 'After select max( seq no' );


      update PA_TASKS
      set
      display_sequence =
        PA_TASKS_MAINT_UTILS.REARRANGE_DISPLAY_SEQ(display_sequence, l_max_seq, 1, 'INSERT', 'DOWN'),
      record_version_number = record_version_number + 1
      where project_id = p_project_id
      and (display_sequence > -(l_display_seq+1) or display_sequence < 0);
HY */ NULL;
    EXCEPTION
      WHEN OTHERS THEN
        PA_UTILS.ADD_MESSAGE('PA', 'PA_TASK_SEQ_NUM_ERR');
        raise FND_API.G_EXC_ERROR;
    END;

--dbms_output.put_line( 'Before INCREMENT_WBS_REC_VER_NUM' );

/*    PA_TASKS_MAINT_UTILS.INCREMENT_WBS_REC_VER_NUM(
                         p_project_id                 => p_project_id,
                         p_wbs_record_version_number  => p_wbs_record_version_number,
                         x_return_status              => x_return_status );*/

--    p_task_id := l_ref_task_id;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

--dbms_output.put_line( 'After INCREMENT_WBS_REC_VER_NUM' );

    --commit
    IF (p_commit = FND_API.G_TRUE) THEN
      commit;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASKS_MAINT_PUB.CREATE_TASK END');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to CREATE_TASK;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to CREATE_TASK;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG(p_pkg_name => 'PA_TASKS_MAINT_PUB',
                              p_procedure_name => 'CREATE_TASK',
                              p_error_text => substrb(SQLERRM,1,240));
      RAISE;
  END CREATE_TASK;


-- API name                      : UPDATE_TASK
-- Type                          : Public Procedure
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
--   p_project_id                        IN  NUMBER
--   p_task_id                           IN  NUMBER
--   p_task_number                       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_task_name                         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_long_task_name                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_task_description                  IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_task_manager_name                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--   p_task_manager_person_id            IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
--   p_carrying_out_org_name             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
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
--   p_wbs_record_version_number         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
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

    ,p_project_id                        IN  NUMBER
    ,p_task_id                           IN  NUMBER
    ,p_task_number                       IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_task_name                         IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_long_task_name                    IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_task_description                  IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_task_manager_name                 IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_task_manager_person_id            IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_carrying_out_org_name             IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
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
    ,p_wbs_record_version_number         IN  NUMBER      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
    ,p_comments                          IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
-- FP.K changes msundare
    ,p_labor_disc_reason_code            IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_non_labor_disc_reason_code        IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
--PA L Capital Project Changes 2872708
    ,p_retirement_cost_flag              IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_cint_eligible_flag                IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_cint_stop_date                    IN  DATE        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
--End PA L Capital Project Changes 2872708
    ,p_gen_etc_src_code                  IN  VARCHAR2    := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
    ,p_update_subtasks_end_dt            IN  VARCHAR2    := 'Y'  --bug 4241863
    ,p_dates_check                       IN  VARCHAR2    := 'Y'  --bug 5665772
    ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count                         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data                          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_api_name                           CONSTANT VARCHAR2(30)  := 'UPDATE_TASK';
    l_api_version                        CONSTANT NUMBER        := 1.0;
    l_msg_count                          NUMBER;
    l_msg_data                           VARCHAR2(250);
    l_data                               VARCHAR2(250);
    l_msg_index_out                      NUMBER;

    l_carrying_out_org_id                NUMBER;
    l_task_manager_id                    NUMBER;

    l_return_status                      VARCHAR2(1);
    l_error_msg_code                     VARCHAR2(250);
    l_dummy                              VARCHAR2(1);

    CURSOR c1 IS
      select 'x'
      from PA_TASKS
      where project_id = p_project_id
      for update of record_version_number NOWAIT;

    CURSOR c2 IS
      select 'x'
      from PA_TASKS
      where project_id = p_project_id;
     -- Bug 7386335
     --BUG 4081329, rtarway
     cursor cur_get_child_task_dates (l_project_id NUMBER, l_task_id NUMBER)
     IS   select task_id, start_date, completion_date, parent_task_id from pa_tasks
          where project_id = l_project_id
          and   completion_date is null
               start with parent_task_id = l_task_id
               connect by parent_task_id = prior task_id
               and  project_id = l_project_id;

     -- Bug 7386335
     CURSOR cur_get_parent_tasks (l_project_id NUMBER, l_task_id NUMBER)
     IS
     SELECT task_id
     FROM pa_tasks
     WHERE project_id = l_project_id
     START WITH task_id = l_task_id
     CONNECT BY PRIOR parent_task_id = task_id
     AND project_id = l_project_id;

     type l_task_id_tbl_type is table of pa_tasks.task_id%type index by binary_integer;
     type l_start_date_tbl_type is table of pa_tasks.start_date%type index by binary_integer;
     type l_completion_date_tbl_type is table of pa_tasks.completion_date%type index by binary_integer;

     l_task_id_tbl             l_task_id_tbl_type;
     l_start_date_tbl          l_start_date_tbl_type;
     l_completion_date_tbl     l_completion_date_tbl_type;

     --BUG 4081329, rtarway

     -- Bug 7386335
     type l_parent_task_id_tbl_type is table of pa_tasks.parent_task_id%type index by binary_integer;
     l_parent_task_id_tbl      l_parent_task_id_tbl_type;
     l_parent_task_date        DATE;

  BEGIN
    pa_tasks_maint_utils.set_org_id(p_project_id);

    pa_debug.init_err_stack('PA_TASKS_MAINT_PUB.UPDATE_TASK');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASKS_MAINT_PUB.UPDATE_TASK begin');
    END IF;

    IF p_commit = FND_API.G_TRUE THEN
      savepoint UPDATE_TASK;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_FALSE)) THEN
      pa_debug.debug('Performing ID validations and conversions');
      FND_MSG_PUB.initialize;
    END IF;

-- Bug 8273954 : Commenting off the below code as it does not do any validations
-- and also results in task_manager_person_id to be updated to null when called
-- from PA_PROJECT_DATES_PUB.COPY_PROJECT_DATES
--    --BEGIN VALIDATIONS
--    IF (p_calling_module = 'SELF_SERVICE') OR (p_calling_module = 'EXCHANGE') THEN
--    --Check Task Manager and Task Manager Id
--      IF ((p_task_manager_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) AND
--          (p_task_manager_name IS NOT NULL)) OR
--         ((p_task_manager_person_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) AND
--          (p_task_manager_person_id IS NOT NULL)) THEN
--        --Call Check API.
--
--         /* pa_tasks_maint_utils.check_task_mgr_name_or_id(
--            p_task_mgr_name => p_task_manager_name,
--            p_task_mgr_id => p_task_manager_person_id,
--            x_task_mgr_id => l_task_manager_id,
--            x_return_status => l_return_status,
--            x_error_msg_code => l_error_msg_code);*/
--
--        l_task_manager_id := p_task_manager_person_id;
--        l_return_status := FND_API.G_RET_STS_SUCCESS;
--
--        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
--          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
--                               p_msg_name => l_error_msg_code);
--        END IF;
--
--      END IF; --End Name-Id Conversion
----    END IF;
--
----    IF (p_calling_module = 'SELF_SERVICE') OR (p_calling_module = 'EXCHANGE') THEN
--    --Check Carrying out organization name and Carrying out organization Id
--      IF ((p_carrying_out_org_name <> FND_API.G_MISS_CHAR) AND
--          (p_carrying_out_org_name IS NOT NULL)) OR
--         ((p_carrying_out_organization_id <> FND_API.G_MISS_NUM) AND
--          (p_carrying_out_organization_id IS NOT NULL)) THEN
--
--       /* pa_hr_org_utils.Check_OrgName_Or_Id
--            (p_organization_id      => p_carrying_out_organization_id
--             ,p_organization_name   => p_carrying_out_org_name
--             ,p_check_id_flag       => 'A'
--             ,x_organization_id     => l_carrying_out_org_id
--             ,x_return_status       => l_return_status
--             ,x_error_msg_code      => l_error_msg_code);*/
--
--        l_carrying_out_org_id := p_carrying_out_organization_id;
--        l_return_status := FND_API.G_RET_STS_SUCCESS;
--
--        IF l_return_status = FND_API.G_RET_STS_ERROR THEN
--              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
--                                   p_msg_name       => l_error_msg_code);
--        END IF;
--      END IF; --End Name-Id Conversion
--    ELSE
--        l_carrying_out_org_id := p_carrying_out_organization_id;
--        l_task_manager_id := p_task_manager_person_id;
--    END IF;

    -- Bug 8273954
    l_carrying_out_org_id := p_carrying_out_organization_id;
    l_task_manager_id     := p_task_manager_person_id;


    --Check if there is any error
    l_msg_count := FND_MSG_PUB.count_msg;
    if l_msg_count > 0 then
      x_msg_count := l_msg_count;
      if x_msg_count = 1 then
        pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      end if;
      raise FND_API.G_EXC_ERROR;
    end if;

/*  temporarily commenting for project structures
    --Call Lock project
    IF p_wbs_record_version_number <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
       p_wbs_record_version_number IS NOT NULL
    THEN
        PA_TASKS_MAINT_UTILS.LOCK_PROJECT(
          p_validate_only             => p_validate_only,
          p_calling_module            => p_calling_module,
          p_project_id                => p_project_id,
          p_wbs_record_version_number => p_wbs_record_version_number,
          x_return_status           => x_return_status,
          x_msg_data                  => x_msg_data );
    END IF;*/


    --Call Private API
    PA_TASKS_MAINT_PVT.UPDATE_TASK
    (
    p_commit => p_commit
    ,p_calling_module => p_calling_module
    ,p_validate_only => p_validate_only
    ,p_debug_mode => p_debug_mode

    ,p_project_id => p_project_id
    ,p_task_id => p_task_id
    ,p_task_number => p_task_number
    ,p_task_name => p_task_name
    ,p_long_task_name => p_long_task_name
    ,p_task_description => p_task_description
    ,p_task_manager_person_id => l_task_manager_id
    ,p_carrying_out_organization_id => l_carrying_out_org_id
    ,p_task_type_code => p_task_type_code
    ,p_priority_code => p_priority_code
    ,p_work_type_id => p_work_type_id
    ,p_service_type_code => p_service_type_code
    ,p_milestone_flag => p_milestone_flag
    ,p_critical_flag => p_critical_flag
    ,p_chargeable_flag => p_chargeable_flag
    ,p_billable_flag => p_billable_flag
    ,p_receive_project_invoice_flag => p_receive_project_invoice_flag
    ,p_scheduled_start_date => p_scheduled_start_date
    ,p_scheduled_finish_date => p_scheduled_finish_date
    ,p_estimated_start_date => p_estimated_start_date
    ,p_estimated_end_date => p_estimated_end_date
    ,p_actual_start_date => p_actual_start_date
    ,p_actual_finish_date => p_actual_finish_date
    ,p_task_start_date => p_task_start_date
    ,p_task_completion_date => p_task_completion_date
    ,p_baseline_start_date => p_baseline_start_date
    ,p_baseline_end_date => p_baseline_end_date

    ,p_obligation_start_date => p_obligation_start_date
    ,p_obligation_end_date => p_obligation_end_date
    ,p_estimate_to_complete_work => p_estimate_to_complete_work
    ,p_baseline_work => p_baseline_work
    ,p_scheduled_work => p_scheduled_work
    ,p_actual_work_to_date => p_actual_work_to_date
    ,p_work_unit => p_work_unit
    ,p_progress_status_code => p_progress_status_code

    ,p_job_bill_rate_schedule_id =>p_job_bill_rate_schedule_id
    ,p_emp_bill_rate_schedule_id =>p_emp_bill_rate_schedule_id
    ,p_pm_product_code =>p_pm_product_code
    ,p_pm_project_reference =>p_pm_project_reference
    ,p_pm_task_reference =>p_pm_task_reference
    ,p_pm_parent_task_reference =>p_pm_parent_task_reference
    ,p_parent_task_id =>p_parent_task_id
    ,p_address_id =>p_address_id
    ,p_ready_to_bill_flag =>p_ready_to_bill_flag
    ,p_ready_to_distribute_flag =>p_ready_to_distribute_flag
    ,p_limit_to_txn_controls_flag =>p_limit_to_txn_controls_flag
    ,p_labor_bill_rate_org_id =>p_labor_bill_rate_org_id
    ,p_labor_std_bill_rate_schdl =>p_labor_std_bill_rate_schdl
    ,p_labor_schedule_fixed_date =>p_labor_schedule_fixed_date
    ,p_labor_schedule_discount =>p_labor_schedule_discount
    ,p_nl_bill_rate_org_id =>p_nl_bill_rate_org_id
    ,p_nl_std_bill_rate_schdl =>p_nl_std_bill_rate_schdl
    ,p_nl_schedule_fixed_date =>p_nl_schedule_fixed_date
    ,p_nl_schedule_discount =>p_nl_schedule_discount
    ,p_labor_cost_multiplier_name =>p_labor_cost_multiplier_name
    ,p_cost_ind_rate_sch_id =>p_cost_ind_rate_sch_id
    ,p_rev_ind_rate_sch_id =>p_rev_ind_rate_sch_id
    ,p_inv_ind_rate_sch_id =>p_inv_ind_rate_sch_id
    ,p_cost_ind_sch_fixed_date =>p_cost_ind_sch_fixed_date
    ,p_rev_ind_sch_fixed_date =>p_rev_ind_sch_fixed_date
    ,p_inv_ind_sch_fixed_date =>p_inv_ind_sch_fixed_date
    ,p_labor_sch_type =>p_labor_sch_type
    ,p_nl_sch_type =>p_nl_sch_type
    ,p_early_start_date =>p_early_start_date
    ,p_early_finish_date =>p_early_finish_date
    ,p_late_start_date =>p_late_start_date
    ,p_late_finish_date =>p_late_finish_date
    ,p_attribute_category =>p_attribute_category
    ,p_attribute1 =>p_attribute1
    ,p_attribute2 =>p_attribute2
    ,p_attribute3 =>p_attribute3
    ,p_attribute4 =>p_attribute4
    ,p_attribute5 =>p_attribute5
    ,p_attribute6 =>p_attribute6
    ,p_attribute7 =>p_attribute7
    ,p_attribute8 =>p_attribute8
    ,p_attribute9 =>p_attribute9
    ,p_attribute10 =>p_attribute10
    ,p_allow_cross_charge_flag =>p_allow_cross_charge_flag
    ,p_project_rate_date =>p_project_rate_date
    ,p_project_rate_type =>p_project_rate_type
    ,p_cc_process_labor_flag =>p_cc_process_labor_flag
    ,p_labor_tp_schedule_id =>p_labor_tp_schedule_id
    ,p_labor_tp_fixed_date =>p_labor_tp_fixed_date
    ,p_cc_process_nl_flag =>p_cc_process_nl_flag
    ,p_nl_tp_schedule_id =>p_nl_tp_schedule_id
    ,p_nl_tp_fixed_date =>p_nl_tp_fixed_date
    ,p_inc_proj_progress_flag => p_inc_proj_progress_flag
    ,p_taskfunc_cost_rate_type           => p_taskfunc_cost_rate_type
    ,p_taskfunc_cost_rate_date           => p_taskfunc_cost_rate_date
    ,p_non_lab_std_bill_rt_sch_id        => p_non_lab_std_bill_rt_sch_id

    ,p_record_version_number => p_record_version_number
    ,p_comments              => p_comments
    ,p_labor_disc_reason_code => p_labor_disc_reason_code
    ,p_non_labor_disc_reason_code => p_non_labor_disc_reason_code
--PA L Capital Project Changes 2872708
    ,p_retirement_cost_flag               => p_retirement_cost_flag
    ,p_cint_eligible_flag                 => p_cint_eligible_flag
    ,p_cint_stop_date                     => p_cint_stop_date
--End PA L Capital Project Changes 2872708
    ,p_gen_etc_src_code                   => p_gen_etc_src_code
    ,p_dates_check                        => p_dates_check  --bug 5665772
    ,x_return_status =>l_return_status
    ,x_msg_count =>x_msg_count
    ,x_msg_data =>x_msg_data
    );

    --Check return status
    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      x_msg_count := FND_MSG_PUB.count_msg;
      if x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      end if;
      raise FND_API.G_EXC_ERROR;
    end if;

    IF p_wbs_record_version_number <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
       p_wbs_record_version_number IS NOT NULL
    THEN
        PA_TASKS_MAINT_UTILS.INCREMENT_WBS_REC_VER_NUM(
                         p_project_id                 => p_project_id,
                         p_wbs_record_version_number  => p_wbs_record_version_number,
                         x_return_status              => x_return_status );
    END IF;

  IF p_update_subtasks_end_dt = 'Y'     --bug 4241863
  THEN
    --BUG 4081329, rtarway
    --Update Child tasks with the end date passed
    if ( p_task_completion_date is not null and  p_task_completion_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE ) then
       open  cur_get_child_task_dates (p_project_id,p_task_id);
       fetch cur_get_child_task_dates bulk collect into      l_task_id_tbl,
                                                             l_start_date_tbl,
                                                             l_completion_date_tbl,
							     l_parent_task_id_tbl; -- Bug 7386335
       close cur_get_child_task_dates;
       if l_task_id_tbl is not null and l_task_id_tbl.count > 0 then
          -- Bug 7386335
	  FOR i in l_task_id_tbl.first..l_task_id_tbl.last LOOP
            IF l_parent_task_id_tbl(i) IS NOT NULL AND l_start_date_tbl(i) is NULL THEN
	      SELECT start_date
 	      INTO l_parent_task_date
 	      FROM pa_tasks
 	      WHERE task_id = l_parent_task_id_tbl(i);

 	      UPDATE pa_tasks
 	      SET completion_date = p_task_completion_date,
 	          start_date = l_parent_task_date
 	      WHERE task_id = l_task_id_tbl(i);

 	    ELSE
 	      UPDATE pa_tasks
 	      SET completion_date = p_task_completion_date
 	      WHERE task_id = l_task_id_tbl(i);
 	    END IF;
 	  END LOOP;
 	  --FORALL i in l_task_id_tbl.first..l_task_id_tbl.last
 	  --update pa_tasks set completion_date = p_task_completion_date where task_id = l_task_id_tbl(i)
 	  --and project_id = p_project_id;
       end if;
    -- Bug 7386335
    ELSIF p_task_completion_date is NULL THEN
       OPEN  cur_get_parent_tasks (p_project_id, p_task_id);
       FETCH cur_get_parent_tasks BULK COLLECT INTO l_task_id_tbl;
       CLOSE cur_get_parent_tasks;

       FORALL i in l_task_id_tbl.first..l_task_id_tbl.last
       UPDATE pa_tasks
       SET completion_date = p_task_completion_date
       WHERE task_id = l_task_id_tbl(i) and project_id = p_project_id;
    end if;
    --End Add by rtarway for bug 4081329
   END IF;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --commit
    IF (p_commit = FND_API.G_TRUE) THEN
      commit;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASKS_MAINT_PUB.UPDATE_TASK END');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to UPDATE_TASK;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to UPDATE_TASK;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --put message
      FND_MSG_PUB.ADD_EXC_MSG(p_pkg_name => 'PA_TASKS_MAINT_PUB',
                              p_procedure_name => 'UPDATE_TASK',
                              p_error_text => substrb(SQLERRM,1,240));
--      RAISE;
  END UPDATE_TASK;


-- API name                      : DELETE_TASK
-- Type                          : Public Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--    p_api_version                       IN  NUMBER      := 1.0
--    p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
--    p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
--    p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
--    p_validation_level                  IN  VARCHAR2    := 100
--    p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
--    p_debug_mode                        IN  VARCHAR2    := 'N'
--    p_project_id                        IN  NUMBER
--    p_task_id                                IN  NUMBER
--    p_record_version_number             IN  NUMBER
--    x_return_status                     OUT VARCHAR2
--    x_msg_count                         OUT NUMBER
--    x_msg_data                          OUT VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--
  procedure DELETE_TASK
  (
     p_api_version                       IN  NUMBER      := 1.0
    ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
    ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
    ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
    ,p_validation_level                  IN  VARCHAR2    := 100
    ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
    ,p_debug_mode                        IN  VARCHAR2    := 'N'
    ,p_project_id                        IN  NUMBER
    ,p_task_id                                 IN  NUMBER
    ,p_record_version_number             IN  NUMBER
    ,p_wbs_record_version_number         IN  NUMBER
    ,p_called_from_api      IN    VARCHAR2    := 'ABCD'
    ,p_bulk_flag                         IN VARCHAR2     := 'N'  -- 4201927
    ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count                         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data                          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_api_name                           CONSTANT VARCHAR2(30)  := 'DELETE_TASK';
    l_api_version                        CONSTANT NUMBER        := 1.0;

    l_dummy                              VARCHAR2(1);
    l_return_status                      VARCHAR2(1);

    l_msg_count                          NUMBER;
    l_msg_data                           VARCHAR2(250);
    l_data                               VARCHAR2(250);
    l_msg_index_out                      NUMBER;

    l_task_cnt                           NUMBER;
    l_max_seq                            NUMBER;

    --selected_seq_num                     PA_TASKS.DISPLAY_SEQUENCE%TYPE;

    CURSOR c1 IS
      select 'x'
      from PA_TASKS
      where project_id = p_project_id
      for update of record_version_number NOWAIT;

    CURSOR c2 IS
      select 'x'
      from PA_TASKS
      where project_id = p_project_id;

   /* CURSOR cur_selected_task
    IS
      SELECT display_sequence
        FROM pa_tasks
       WHERE project_id = p_project_id
         AND task_id    = p_task_id;*/

  BEGIN
    pa_tasks_maint_utils.set_org_id(p_project_id);


    pa_debug.init_err_stack('PA_TASKS_MAINT_PUB.DELETE_TASK');

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASKS_MAINT_PUB.DELETE_TASK begin');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint DELETE_TASK;
    END IF;


    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version, p_api_version, l_api_name, g_pkg_name) THEN
      raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list, FND_API.G_FALSE)) THEN
      pa_debug.debug('Performing ID validations and conversions');
      FND_MSG_PUB.initialize;
    END IF;

    --Check if there is any error
    l_msg_count := FND_MSG_PUB.count_msg;
    if l_msg_count > 0 then
      x_msg_count := l_msg_count;
      if x_msg_count = 1 then
        pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      end if;
      raise FND_API.G_EXC_ERROR;
    end if;

    /*--Call Lock project

    PA_TASKS_MAINT_UTILS.LOCK_PROJECT(
          p_validate_only             => p_validate_only,
          p_calling_module            => p_calling_module,
          p_project_id                => p_project_id,
          p_wbs_record_version_number => p_wbs_record_version_number,
          x_return_status           => x_return_status,
          x_msg_data                  => x_msg_data );   */

    --Call Private API
    --count tasks to be deleted

    select count('x')
      INTO l_task_cnt
      FROM PA_TASKS
     WHERE project_id = p_project_id
    START WITH task_id = p_task_id
    CONNECT BY parent_task_id = prior task_id;


/*    --Get the sequence number of the selected task;
    OPEN cur_selected_task;
    FETCH cur_selected_task INTO selected_seq_num;
    CLOSE cur_selected_task;*/


    PA_TASKS_MAINT_PVT.DELETE_TASK
    (
    p_commit => p_commit
    ,p_calling_module => p_calling_module
    ,p_validate_only => p_validate_only
    ,p_debug_mode => p_debug_mode
    ,p_task_id => p_task_id
    ,p_record_version_number => p_record_version_number
    ,p_called_from_api      => p_called_from_api
    ,p_bulk_flag        =>  p_bulk_flag   -- 4201927 Passing the value to pvt api
    ,x_return_status => l_return_status
    ,x_msg_count => x_msg_count
    ,x_msg_data => x_msg_data
    );

    --Check return status
    if l_return_status <> FND_API.G_RET_STS_SUCCESS then
      x_msg_count := FND_MSG_PUB.count_msg;
      if x_msg_count = 1 then
         pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      end if;
      raise FND_API.G_EXC_ERROR;
    end if;

/*    --This fcuntion is moved in PA_TASK_PVT1.DELETE_TASK_VERSION api.
      BEGIN
      select max(display_sequence)
      into l_max_seq
      from PA_TASKS
      where project_id = p_project_id;

      update PA_TASKS
      set
      display_sequence =
        PA_TASKS_MAINT_UTILS.REARRANGE_DISPLAY_SEQ(display_sequence, l_max_seq, l_task_cnt, 'DELETE', 'DOWN'),
      record_version_number = record_version_number + 1
      where project_id = p_project_id
      and (display_sequence > selected_seq_num);
    EXCEPTION
      WHEN OTHERS THEN
        PA_UTILS.ADD_MESSAGE('PA', 'PA_TASK_SEQ_NUM_ERR');
        raise FND_API.G_EXC_ERROR;
    END;*/


    /*PA_TASKS_MAINT_UTILS.INCREMENT_WBS_REC_VER_NUM(
                         p_project_id                 => p_project_id,
                         p_wbs_record_version_number  => p_wbs_record_version_number,
                         x_return_status              => x_return_status );*/

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    --commit
    IF (p_commit = FND_API.G_TRUE) THEN
      commit;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASKS_MAINT_PUB.DELETE_TASK END');
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to DELETE_TASK;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to DELETE_TASK;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.ADD_EXC_MSG(p_pkg_name => 'PA_TASKS_MAINT_PUB',
                              p_procedure_name => 'DELETE_TASK',
                              p_error_text => substrb(SQLERRM,1,240));
  END DELETE_TASK;


-- API name                      : Edit_Task_Structure
-- Type                          : Utility Procedure
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
-- p_project_id                        IN  NUMBER      := FND_API.G_MISS_NUM
-- p_project_name                      IN  VARCHAR2    := FND_API.G_MISS_CHAR
-- p_task_id                           IN  NUMBER      := FND_API.G_MISS_NUM
-- p_task_name                         IN  VARCHAR2    := FND_API.G_MISS_CHAR
-- p_edit_mode                  IN  VARCHAR2  REQUIRED
-- p_record_version_number             IN  NUMBER
-- p_wbs_record_version_number             IN  NUMBER
-- x_return_status                     OUT VARCHAR2
-- x_msg_count                         OUT NUMBER
-- x_msg_data                          OUT VARCHAR2
--
--  History
--
--  25-JUN-01   Majid Ansari             -Created
--
--

  PROCEDURE Edit_Task_Structure(
    p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_project_id                        IN  NUMBER      := FND_API.G_MISS_NUM
   ,p_project_name                      IN  VARCHAR2    := FND_API.G_MISS_CHAR
   ,p_task_id                           IN  NUMBER      := FND_API.G_MISS_NUM
   ,p_task_name                         IN  VARCHAR2    := FND_API.G_MISS_CHAR
   ,p_edit_mode                         IN  VARCHAR2
   ,p_record_version_number             IN  NUMBER
   ,p_wbs_record_version_number             IN  NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT NOCOPY VARCHAR2 ) AS --File.Sql.39 bug 4440895


      l_api_name                CONSTANT VARCHAR(30) := 'Edit_Task_Structure';
      l_api_version             CONSTANT NUMBER      := 1.0;

      l_return_status                    VARCHAR2(1);
      l_msg_data                         VARCHAR2(250);
      l_msg_count                        NUMBER;

      l_dummy_char                       VARCHAR2(1);
      l_error_msg_code                   VARCHAR2(250);
      l_data                             VARCHAR2(250);
      l_msg_index_out                    NUMBER;
      l_task_id                      NUMBER;
      l_project_id                   NUMBER;
  BEGIN

    pa_tasks_maint_utils.set_org_id(p_project_id);

    -- Standard call to check for call compatibility
    IF (p_debug_mode = 'Y')
    THEN
        pa_debug.debug('Edit Task Structure PUB : Checking the api version number.');
    END IF;

    IF p_commit = FND_API.G_TRUE
    THEN
       SAVEPOINT Edit_Structure;
    END IF;

    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name)
    THEN

       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    if (p_debug_mode = 'Y') then
        pa_debug.debug('Edit Task Structure PUB : Initializing message stack.');
    end if;

    pa_debug.init_err_stack('PA_TASK_MAINT_PUB.Edit_Task_Structure');

    if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
       fnd_msg_pub.initialize;
    end if;

    /*IF (p_calling_module = 'SELF_SERVICE') OR (p_calling_module = 'EXCHANGE') THEN

    --Check Project Name and Id
      IF ((p_project_name <> FND_API.G_MISS_CHAR) AND
          (p_project_name IS NOT NULL)) OR
         ((p_project_id <> FND_API.G_MISS_NUM) AND
          (p_project_id IS NOT NULL)) THEN
         --Call Check API.
         pa_tasks_maint_utils.CHECK_PROJECT_NAME_OR_ID(
             p_project_id     => p_project_id,
               p_project_name   => p_project_name,
             x_project_id     => l_project_id,
             x_return_status  => l_return_status,
             x_error_msg_code => l_error_msg_code);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => l_error_msg_code);
        END IF;
      END IF; --End Project Name-Id Conversion

    --Check Task Name and Id
      IF ((p_task_name <> FND_API.G_MISS_CHAR) AND
          (p_task_name IS NOT NULL)) OR
         ((p_task_id <> FND_API.G_MISS_NUM) AND
          (p_task_id IS NOT NULL)) THEN
         --Call Check API.
         pa_tasks_maint_utils.CHECK_TASK_NAME_OR_ID(
             p_project_id     => l_project_id,
             p_task_id        => p_task_id,
               p_task_name      => p_task_name,
             x_task_id        => l_task_id,
             x_return_status  => l_return_status,
             x_error_msg_code => l_error_msg_code);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => l_error_msg_code);
        END IF;
      END IF; --End Task Name-Id Conversion
    ELSE*/
      l_project_id := p_project_id;
      l_task_id := p_task_id;
    --END IF;

      --project and task id Required check.
      PA_TASKS_MAINT_UTILS.SRC_PRJ_TASK_ID_REQ_CHECK(
                             p_project_id      => l_project_id,
                             p_task_id         => l_task_id,
                             x_return_status   => l_return_status,
                             x_error_msg_code  => l_error_msg_code );

      IF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => l_error_msg_code);
         x_msg_data := l_error_msg_code;
         x_return_status := 'E';
         RAISE  FND_API.G_EXC_ERROR;
      END IF;

      x_return_status := 'S';

    --Call Lock project
/*  temporarily commenting for project structures

    PA_TASKS_MAINT_UTILS.LOCK_PROJECT(
          p_validate_only             => p_validate_only,
          p_calling_module            => p_calling_module,
          p_project_id                => l_project_id,
          p_wbs_record_version_number => p_wbs_record_version_number,
          x_return_status           => x_return_status,
          x_msg_data                  => x_msg_data );   */

    l_msg_count := FND_MSG_PUB.count_msg;

    If l_msg_count > 0 THEN
       x_msg_count := l_msg_count;
       If l_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
               (p_encoded        => FND_API.G_TRUE ,
                p_msg_index      => 1,
                p_msg_count      => l_msg_count ,
                p_msg_data       => l_msg_data,
                p_data           => l_data,
                p_msg_index_out  => l_msg_index_out );

                x_msg_data := l_data;
       End if;
       RAISE  FND_API.G_EXC_ERROR;
    End if;

    IF p_edit_mode = 'INDENT'
    THEN

--  dbms_output.put_line( 'Edit Task structure. '||'Before Indent Task' );

       PA_TASKS_MAINT_PVT.Indent_Task(
                           p_commit                   => p_commit
                          ,p_validate_only      => p_validate_only
                          ,p_validation_level       => p_validation_level
                          ,p_calling_module     => p_calling_module
                          ,p_debug_mode             => p_debug_mode
                          ,p_project_id             => l_project_id
                          ,p_task_id                  => l_task_id
                          ,p_record_version_number  => p_record_version_number
                          ,x_return_status        => x_return_status
                          ,x_msg_count              => x_msg_count
                          ,x_msg_data               => x_msg_data );

    l_msg_count := FND_MSG_PUB.count_msg;

  --dbms_output.put_line( 'Edit Task structure. '||'After Indent Task '||'Count '|| l_msg_count );

    ELSIF p_edit_mode = 'OUTDENT'
    THEN

  --dbms_output.put_line( 'Edit Task structure. '||'Before Outdent Task' );

       PA_TASKS_MAINT_PVT.Outdent_Task(
                           p_commit                   => p_commit
                          ,p_validate_only      => p_validate_only
                          ,p_validation_level       => p_validation_level
                          ,p_calling_module     => p_calling_module
                          ,p_debug_mode             => p_debug_mode
                          ,p_project_id             => l_project_id
                          ,p_task_id                  => l_task_id
                          ,p_record_version_number  => p_record_version_number
                          ,x_return_status        => x_return_status
                          ,x_msg_count              => x_msg_count
                          ,x_msg_data               => x_msg_data );

    END IF;

  --dbms_output.put_line( 'After Edit Task structure. ' );


    if (p_debug_mode = 'Y') then
       pa_debug.debug('Edit Task Structure PUB : checking message count');
    end if;
    l_msg_count := FND_MSG_PUB.count_msg;

    If l_msg_count > 0 THEN
       x_msg_count := l_msg_count;
       If l_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
               (p_encoded        => FND_API.G_TRUE ,
                p_msg_index      => 1,
                p_msg_count      => l_msg_count ,
                p_msg_data       => l_msg_data,
                p_data           => l_data,
                p_msg_index_out  => l_msg_index_out );

                x_msg_data := l_data;
       End if;
       RAISE  FND_API.G_EXC_ERROR;
    End if;

    PA_TASKS_MAINT_UTILS.INCREMENT_WBS_REC_VER_NUM(
                         p_project_id                 => p_project_id,
                         p_wbs_record_version_number  => p_wbs_record_version_number,
                         x_return_status              => x_return_status );


    IF FND_API.TO_BOOLEAN(P_COMMIT)
    THEN
       COMMIT WORK;
    END IF;
  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Edit_Structure;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_PUB',
                               p_procedure_name => 'Edit_Task_Structure',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Edit_Structure;
       END IF;
       x_return_status := 'E';

     WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Edit_Structure;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_PUB',
                               p_procedure_name => 'Edit_Task_Structure',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;

  END Edit_Task_Structure;

-- API name                      : Move_Task
-- Type                          : Utility Procedure
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
-- p_reference_project_id              IN  NUMBER      := FND_API.G_MISS_NUM
-- p_reference_project_name            IN  VARCHAR2    := FND_API.G_MISS_CHAR
-- p_reference_task_id                 IN  NUMBER      := FND_API.G_MISS_NUM
-- p_reference_task_name               IN  VARCHAR2    := FND_API.G_MISS_CHAR
-- p_project_id                        IN  NUMBER      := FND_API.G_MISS_NUM
-- p_project_name                      IN  VARCHAR2    := FND_API.G_MISS_CHAR
-- p_task_id                           IN  NUMBER      := FND_API.G_MISS_NUM
-- p_task_name                         IN  VARCHAR2    := FND_API.G_MISS_CHAR
-- p_peer_or_sub                       IN  VARCHAR2
-- p_record_version_number             IN  NUMBER
-- p_wbs_record_version_number             IN  NUMBER
-- x_return_status                     OUT VARCHAR2
-- x_msg_count                         OUT NUMBER
-- x_msg_data                          OUT VARCHAR2
--
--  History
--
--  25-JUN-01   Majid Ansari             -Created
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
   ,p_reference_project_id              IN  NUMBER      := FND_API.G_MISS_NUM
   ,p_reference_project_name            IN  VARCHAR2    := FND_API.G_MISS_CHAR
   ,p_reference_task_id                 IN  NUMBER      := FND_API.G_MISS_NUM
   ,p_reference_task_name               IN  VARCHAR2    := FND_API.G_MISS_CHAR
   ,p_project_id                        IN  NUMBER      := FND_API.G_MISS_NUM
   ,p_project_name                      IN  VARCHAR2    := FND_API.G_MISS_CHAR
   ,p_task_id                           IN  NUMBER      := FND_API.G_MISS_NUM
   ,p_task_name                         IN  VARCHAR2    := FND_API.G_MISS_CHAR
   ,p_peer_or_sub                       IN  VARCHAR2
   ,p_record_version_number             IN  NUMBER
   ,p_wbs_record_version_number             IN  NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT NOCOPY VARCHAR2 ) AS --File.Sql.39 bug 4440895

      l_api_name                CONSTANT VARCHAR(30) := 'Move_Task';
      l_api_version             CONSTANT NUMBER      := 1.0;

      l_return_status                    VARCHAR2(1);
      l_msg_data                         VARCHAR2(250);
      l_msg_count                        NUMBER;

      l_dummy                            VARCHAR2(1);
      l_error_msg_code                   VARCHAR2(250);
      l_data                             VARCHAR2(250);
      l_msg_index_out                    NUMBER;
      l_project_id                       NUMBER;
      l_ref_project_id                   NUMBER;
      l_task_id                          NUMBER;
      l_ref_task_id                      NUMBER;

  BEGIN

    pa_tasks_maint_utils.set_org_id(p_project_id);

    -- Standard call to check for call compatibility
    IF (p_debug_mode = 'Y')
    THEN
        pa_debug.debug('Move Task PUB : Checking the api version number.');
    END IF;
    IF p_commit = FND_API.G_TRUE
    THEN
       SAVEPOINT Move;
    END IF;
    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name)
    THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    if (p_debug_mode = 'Y') then
        pa_debug.debug('Move Task PUB : Initializing message stack.');
    end if;
    pa_debug.init_err_stack('PA_TASK_MAINT_PUB.MOVE_TASK');
    if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
       fnd_msg_pub.initialize;
    end if;

--dbms_output.put_line( 'Before name to id conv. ' );
     --commenting after discussing with Hubert and Sakthi.
    /*IF (p_calling_module = 'SELF_SERVICE') OR (p_calling_module = 'EXCHANGE') THEN

    --Check Project Name and Id
      IF ((p_project_name <> FND_API.G_MISS_CHAR) AND
          (p_project_name IS NOT NULL)) OR
         ((p_project_id <> FND_API.G_MISS_NUM) AND
          (p_project_id IS NOT NULL)) THEN
         --Call Check API.
         pa_tasks_maint_utils.CHECK_PROJECT_NAME_OR_ID(
             p_project_id     => p_project_id,
               p_project_name   => p_project_name,
             x_project_id     => l_project_id,
             x_return_status  => l_return_status,
             x_error_msg_code => l_error_msg_code);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => l_error_msg_code);
        END IF;
      END IF; --End Project Name-Id Conversion

--dbms_output.put_line( 'Before name to id conv. 2' );

    --Check Task Name and Id
      IF ((p_task_name <> FND_API.G_MISS_CHAR) AND
          (p_task_name IS NOT NULL)) OR
         ((p_task_id <> FND_API.G_MISS_NUM) AND
          (p_task_id IS NOT NULL)) THEN
         --Call Check API.
         pa_tasks_maint_utils.CHECK_TASK_NAME_OR_ID(
             p_project_id     => l_project_id,
             p_task_id        => p_task_id,
               p_task_name      => p_task_name,
             x_task_id        => l_task_id,
             x_return_status  => l_return_status,
             x_error_msg_code => l_error_msg_code);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => l_error_msg_code);
        END IF;
      END IF; --End Task Name-Id Conversion

--dbms_output.put_line( 'Before name to id conv. 3' );

    --Check reference Project Name and Id
      IF ((p_reference_project_name <> FND_API.G_MISS_CHAR) AND
          (p_reference_project_name IS NOT NULL)) OR
         ((p_reference_project_id <> FND_API.G_MISS_NUM) AND
          (p_reference_project_id IS NOT NULL)) THEN
         --Call Check API.
         pa_tasks_maint_utils.CHECK_PROJECT_NAME_OR_ID(
             p_project_id     => p_reference_project_id,
               p_project_name   => p_reference_project_name,
             x_project_id     => l_ref_project_id,
             x_return_status  => l_return_status,
             x_error_msg_code => l_error_msg_code);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => l_error_msg_code);
        END IF;
      END IF; --End Ref Project Name-Id Conversion

--dbms_output.put_line( 'Before name to id conv. 4' );

    --Check reference Task Name and Id
      IF ((p_reference_task_name <> FND_API.G_MISS_CHAR) AND
          (p_reference_task_name IS NOT NULL)) OR
         ((p_reference_task_id <> FND_API.G_MISS_NUM) AND
          (p_reference_task_id IS NOT NULL)) THEN
         --Call Check API.
         pa_tasks_maint_utils.CHECK_TASK_NAME_OR_ID(
             p_project_id     => l_ref_project_id,
             p_task_id        => p_reference_task_id,
               p_task_name      => p_reference_task_name,
             x_task_id        => l_ref_task_id,
             x_return_status  => l_return_status,
             x_error_msg_code => l_error_msg_code);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => l_error_msg_code);
        END IF;
      END IF; --End Ref Task Name-Id Conversion


    ELSE*/
      l_project_id := p_project_id;
      l_task_id := p_task_id;
      l_ref_project_id := p_reference_project_id;
      l_ref_task_id := p_reference_task_id;
    --END IF;

    x_return_status := 'S';

--dbms_output.put_line( 'Before locking ' );

/*  temporarily commenting for project structures

    --Call Lock project
    PA_TASKS_MAINT_UTILS.LOCK_PROJECT(
          p_validate_only             => p_validate_only,
          p_calling_module            => p_calling_module,
          p_project_id                => l_ref_project_id,
          p_wbs_record_version_number => p_wbs_record_version_number,
          x_return_status           => x_return_status,
          x_msg_data                  => x_msg_data );         */

--dbms_output.put_line( 'After locking 1 ' );

    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
       x_msg_count := l_msg_count;
       x_msg_data  := x_msg_data;
       --dbms_output.put_line( 'x_msg_data '||x_msg_data );
       x_return_status := 'E';
       RAISE  FND_API.G_EXC_ERROR;
    END IF;

--dbms_output.put_line( 'After locking 2 ' );

    if (p_debug_mode = 'Y') then
       pa_debug.debug('Move Task PUB : checking message count');
    end if;

    l_msg_count := FND_MSG_PUB.count_msg;

--dbms_output.put_line( 'After locking 3 ' );

    If l_msg_count > 0 THEN
       x_msg_count := l_msg_count;
       If l_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
               (p_encoded        => FND_API.G_TRUE ,
                p_msg_index      => 1,
                p_msg_count      => l_msg_count ,
                p_msg_data       => l_error_msg_code,
                p_data           => l_data,
                p_msg_index_out  => l_msg_index_out );

                x_msg_data := l_data;

       End if;
       RAISE  FND_API.G_EXC_ERROR;
    End if;


    PA_TASKS_MAINT_PVT.Move_Task(
               p_commit                            => p_commit
              ,p_validate_only                     => p_validate_only
              ,p_validation_level                  => p_validation_level
              ,p_calling_module                    => p_calling_module
              ,p_debug_mode                        => p_debug_mode
              ,p_reference_project_id              => l_ref_project_id
              ,p_reference_task_id                 => l_ref_task_id
              ,p_project_id                        => l_project_id
              ,p_task_id                           => l_task_id
              ,p_peer_or_sub                       => p_peer_or_sub
              ,p_record_version_number             => p_record_version_number
              ,x_return_status                     => l_return_status
              ,x_msg_count                         => l_msg_count
              ,x_msg_data                          => l_msg_data );

    if (p_debug_mode = 'Y') then
       pa_debug.debug('Move Task PUB : checking message count');
    end if;
    l_msg_count := FND_MSG_PUB.count_msg;


    If l_msg_count > 0 THEN
       x_msg_count := l_msg_count;
       If l_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
               (p_encoded        => FND_API.G_TRUE ,
                p_msg_index      => 1,
                p_msg_count      => l_msg_count,
                p_msg_data       => l_msg_data,
                p_data           => l_data,
                p_msg_index_out  => l_msg_index_out );

                x_msg_data := l_data;


       End if;
       RAISE  FND_API.G_EXC_ERROR;
    End if;

    PA_TASKS_MAINT_UTILS.INCREMENT_WBS_REC_VER_NUM(
                         p_project_id                 => l_ref_project_id,
                         p_wbs_record_version_number  => p_wbs_record_version_number,
                         x_return_status              => x_return_status );


    IF FND_API.TO_BOOLEAN(P_COMMIT)
    THEN
       COMMIT WORK;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Move;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_PUB',
                               p_procedure_name => 'Move_Task',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Move;
       END IF;
       x_return_status := 'E';

     WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Move;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_PUB',
                               p_procedure_name => 'Move_Task',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;

  END Move_Task;


-- API name                      : Copy_Task
-- Type                          : Utility Procedure
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
-- p_reference_project_id              IN  NUMBER      := FND_API.G_MISS_NUM
-- p_reference_project_name            IN  VARCHAR2    := FND_API.G_MISS_CHAR
-- p_reference_task_id                 IN  NUMBER      := FND_API.G_MISS_NUM
-- p_reference_task_name               IN  VARCHAR2    := FND_API.G_MISS_CHAR
-- p_project_id                        IN  NUMBER      := FND_API.G_MISS_NUM
-- p_project_name                      IN  VARCHAR2    := FND_API.G_MISS_CHAR
-- p_task_id                           IN  NUMBER      := FND_API.G_MISS_NUM
-- p_task_name                         IN  VARCHAR2    := FND_API.G_MISS_CHAR
-- p_peer_or_sub                       IN  VARCHAR2  REQUIRED
-- p_copy_node_flag                    IN  VARCHAR2  REQUIRED
-- p_task_prefix                       IN  VARCHAR2  REQUIRED
-- p_wbs_record_version_number         IN  NUMBER
-- x_return_status                     OUT VARCHAR2
-- x_msg_count                         OUT NUMBER
-- x_msg_data                          OUT VARCHAR2
--
--  History
--
--  25-JUN-01   Majid Ansari             -Created
--
--

  PROCEDURE Copy_Task(
    p_api_version                       IN  NUMBER      := 1.0
   ,p_init_msg_list                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_commit                            IN  VARCHAR2    := FND_API.G_FALSE
   ,p_validate_only                     IN  VARCHAR2    := FND_API.G_TRUE
   ,p_validation_level                  IN  VARCHAR2    := 100
   ,p_calling_module                    IN  VARCHAR2    := 'SELF_SERVICE'
   ,p_debug_mode                        IN  VARCHAR2    := 'N'
   ,p_reference_project_id              IN  NUMBER      := FND_API.G_MISS_NUM
   ,p_reference_project_name            IN  VARCHAR2    := FND_API.G_MISS_CHAR
   ,p_reference_task_id                 IN  NUMBER      := FND_API.G_MISS_NUM
   ,p_reference_task_name               IN  VARCHAR2    := FND_API.G_MISS_CHAR
   ,p_project_id                        IN  NUMBER      := FND_API.G_MISS_NUM
   ,p_project_name                      IN  VARCHAR2    := FND_API.G_MISS_CHAR
   ,p_task_id                           IN  NUMBER      := FND_API.G_MISS_NUM
   ,p_task_name                         IN  VARCHAR2    := FND_API.G_MISS_CHAR
   ,p_peer_or_sub                       IN  VARCHAR2
   ,p_copy_node_flag                    IN  VARCHAR2
   ,p_task_prefix                       IN  VARCHAR2
   ,p_wbs_record_version_number         IN  NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                          OUT NOCOPY VARCHAR2 ) AS --File.Sql.39 bug 4440895

      l_api_name                CONSTANT VARCHAR(30) := 'Copy_Task';
      l_api_version             CONSTANT NUMBER      := 1.0;

      l_return_status                    VARCHAR2(1);
      l_msg_data                         VARCHAR2(250);
      l_msg_count                        NUMBER;

      l_dummy_char                       VARCHAR2(1);
      l_error_msg_code                   VARCHAR2(250);
      l_data                             VARCHAR2(250);
      l_msg_index_out                    NUMBER;
      l_dummy                            VARCHAR2(1);

      l_project_id                       NUMBER;
      l_ref_project_id                   NUMBER;
      l_task_id                          NUMBER;
      l_ref_task_id                      NUMBER;

  BEGIN

    pa_tasks_maint_utils.set_org_id(p_project_id);
    -- Standard call to check for call compatibility
    IF (p_debug_mode = 'Y')
    THEN
        pa_debug.debug('Copy Task PUB : Checking the api version number.');
    END IF;
    IF p_commit = FND_API.G_TRUE
    THEN
       SAVEPOINT Copy;
    END IF;
    IF NOT FND_API.COMPATIBLE_API_CALL(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       g_pkg_name)
    THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
    if (p_debug_mode = 'Y') then
        pa_debug.debug('Copy Task PUB : Initializing message stack.');
    end if;
    pa_debug.init_err_stack('PA_TASK_MAINT_PUB.COPY_TASK');
    if FND_API.to_boolean(nvl(p_init_msg_list, FND_API.G_FALSE)) then
       fnd_msg_pub.initialize;
    end if;

    IF (p_calling_module = 'SELF_SERVICE') OR (p_calling_module = 'EXCHANGE') THEN

    --Check Project Name and Id
      IF ((p_project_name <> FND_API.G_MISS_CHAR) AND
          (p_project_name IS NOT NULL)) OR
         ((p_project_id <> FND_API.G_MISS_NUM) AND
          (p_project_id IS NOT NULL)) THEN
         --Call Check API.
         pa_tasks_maint_utils.CHECK_PROJECT_NAME_OR_ID(
             p_project_id     => p_project_id,
                 p_project_name   => p_project_name,
             p_check_id_flag  => 'Y', -- Bug 2623999
             x_project_id     => l_project_id,
             x_return_status  => l_return_status,
             x_error_msg_code => l_error_msg_code);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => l_error_msg_code);
        END IF;
      END IF; --End Project Name-Id Conversion

    --Check Task Name and Id
      IF ((p_task_name <> FND_API.G_MISS_CHAR) AND
          (p_task_name IS NOT NULL)) OR
         ((p_task_id <> FND_API.G_MISS_NUM) AND
          (p_task_id IS NOT NULL)) THEN
         --Call Check API.
         pa_tasks_maint_utils.CHECK_TASK_NAME_OR_ID(
             p_project_id     => l_project_id,
             p_task_id        => p_task_id,
             p_check_id_flag  => 'Y', -- Bug 2623999
                 p_task_name      => p_task_name,
             x_task_id        => l_task_id,
             x_return_status  => l_return_status,
             x_error_msg_code => l_error_msg_code);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => l_error_msg_code);
        END IF;
      END IF; --End Task Name-Id Conversion

    /*--Do not validate reference parameters - as per discussion with Sakthi and Zahid
    --Check reference Project Name and Id
      IF ((p_reference_project_name <> FND_API.G_MISS_CHAR) AND
          (p_reference_project_name IS NOT NULL)) OR
         ((p_reference_project_id <> FND_API.G_MISS_NUM) AND
          (p_reference_project_id IS NOT NULL)) THEN
         --Call Check API.
         pa_tasks_maint_utils.CHECK_PROJECT_NAME_OR_ID(
             p_project_id     => p_reference_project_id,
               p_project_name   => p_reference_project_name,
             x_project_id     => l_ref_project_id,
             x_return_status  => l_return_status,
             x_error_msg_code => l_error_msg_code);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => l_error_msg_code);
        END IF;
      END IF; --End Ref Project Name-Id Conversion

    --Check reference Task Name and Id
      IF ((p_reference_task_name <> FND_API.G_MISS_CHAR) AND
          (p_reference_task_name IS NOT NULL)) OR
         ((p_reference_task_id <> FND_API.G_MISS_NUM) AND
          (p_reference_task_id IS NOT NULL)) THEN
         --Call Check API.
         pa_tasks_maint_utils.CHECK_TASK_NAME_OR_ID(
             p_project_id     => l_ref_project_id,
             p_task_id        => p_reference_task_id,
               p_task_name      => p_reference_task_name,
             x_task_id        => l_ref_task_id,
             x_return_status  => l_return_status,
             x_error_msg_code => l_error_msg_code);
        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => l_error_msg_code);
        END IF;
      END IF; --End Ref Task Name-Id Conversion*/
    ELSE
      l_project_id := p_project_id;
      l_task_id := p_task_id;
    END IF;

    l_ref_project_id := p_reference_project_id;
    l_ref_task_id := p_reference_task_id;

    --Ref project and task id Required check.
    PA_TASKS_MAINT_UTILS.REF_PRJ_TASK_ID_REQ_CHECK(
                             p_reference_project_id      => l_ref_project_id,
                             p_reference_task_id         => l_ref_task_id,
                             x_return_status             => l_return_status,
                             x_error_msg_code            => l_error_msg_code );

    IF l_return_status = FND_API.G_RET_STS_ERROR
    THEN
       PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                            p_msg_name       => l_error_msg_code);
       x_msg_data := l_error_msg_code;
       x_return_status := 'E';
    END IF;

    x_return_status := 'S';

/*  temporarily commenting for project structures

    --Call Lock project
    PA_TASKS_MAINT_UTILS.LOCK_PROJECT(
          p_validate_only             => p_validate_only,
          p_calling_module            => p_calling_module,
          p_project_id                => l_ref_project_id,
          p_wbs_record_version_number => p_wbs_record_version_number,
          x_return_status           => x_return_status,
          x_msg_data                  => x_msg_data );   */


    l_msg_count := FND_MSG_PUB.count_msg;
    IF l_msg_count > 0 THEN
       x_msg_count := l_msg_count;
       x_return_status := 'E';
       RAISE  FND_API.G_EXC_ERROR;
    END IF;

    IF p_copy_node_flag = 'P'           ----copy entire project
    THEN
        PA_TASKS_MAINT_PVT.Copy_Entire_Project(
                  p_commit              => p_commit
                 ,p_validate_only         => p_validate_only
                 ,p_validation_level      => p_validation_level
                 ,p_calling_module        => p_calling_module
                 ,p_debug_mode        => p_debug_mode
                 ,p_reference_project_id  => l_ref_project_id
                 ,p_reference_task_id     => l_ref_task_id
                 ,p_project_id            => l_project_id
                 ,p_peer_or_sub           => p_peer_or_sub
                 ,p_task_prefix           => p_task_prefix
                 ,x_return_status         => l_return_status
                 ,x_msg_count               => l_msg_count
                 ,x_msg_data                => l_msg_data );

    ELSIF p_copy_node_flag = 'T'        ----copy selected task and its sub tasks
    THEN
        PA_TASKS_MAINT_PVT.Copy_Entire_Task(
                  p_commit              => p_commit
                 ,p_validate_only         => p_validate_only
                 ,p_validation_level      => p_validation_level
                 ,p_calling_module        => p_calling_module
                 ,p_debug_mode        => p_debug_mode
                 ,p_reference_project_id  => l_ref_project_id
                 ,p_reference_task_id     => l_ref_task_id
                 ,p_project_id            => l_project_id
                 ,p_task_id               => l_task_id
                 ,p_peer_or_sub           => p_peer_or_sub
                 ,p_task_prefix           => p_task_prefix
                 ,x_return_status         => l_return_status
                 ,x_msg_count               => l_msg_count
                 ,x_msg_data                => l_msg_data );
    ELSIF p_copy_node_flag = 'S'        ----copy selected node
    THEN
        PA_TASKS_MAINT_PVT.Copy_Selected_Task(
                 p_commit                =>  p_commit
                ,p_validate_only         =>  p_validate_only
                ,p_validation_level      =>  p_validation_level
                ,p_calling_module        =>  p_calling_module
                ,p_debug_mode                =>  p_debug_mode
                ,p_reference_project_id    =>  l_ref_project_id
                ,p_reference_task_id       =>  l_ref_task_id
                ,p_task_id                 =>  l_task_id
                ,p_peer_or_sub             =>  p_peer_or_sub
                ,p_task_prefix             =>  p_task_prefix
                ,x_return_status           =>  l_return_status
                ,x_msg_count                 =>  l_msg_count
                ,x_msg_data              =>  l_msg_data );

    END IF;

    if (p_debug_mode = 'Y') then
       pa_debug.debug('Edit Task Structure PUB : checking message count');
    end if;
    l_msg_count := FND_MSG_PUB.count_msg;


    If l_msg_count > 0 THEN
       x_msg_count := l_msg_count;
       If l_msg_count = 1 THEN
          pa_interface_utils_pub.get_messages
               (p_encoded        => FND_API.G_TRUE ,
                p_msg_index      => 1,
                p_msg_count      => l_msg_count ,
                p_msg_data       => l_msg_data,
                p_data           => l_data,
                p_msg_index_out  => l_msg_index_out );

                x_msg_data := l_data;

       End if;
       RAISE  FND_API.G_EXC_ERROR;
    End if;

    PA_TASKS_MAINT_UTILS.INCREMENT_WBS_REC_VER_NUM(
                         p_project_id                 => l_ref_project_id,
                         p_wbs_record_version_number  => p_wbs_record_version_number,
                         x_return_status              => x_return_status );

    IF FND_API.TO_BOOLEAN(P_COMMIT)
    THEN
       COMMIT WORK;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Copy;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_PUB',
                               p_procedure_name => 'Copy_Task',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Copy;
       END IF;
       x_return_status := 'E';

     WHEN OTHERS THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Copy;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_PUB',
                               p_procedure_name => 'Copy_Task',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;

  END Copy_Task;

--3279982 Begin Add by rtarway for FP.M development

-- Procedure            : set_financial_flag_wrapper
-- Type                 : Public Procedure
-- Purpose              : This API will be called from set financial tasks page only in financial tab
--                      : Wrapper API to call set_unset_financial_task and sync_up_wp_tasks_with_fin.
-- Note                 : If a task is selected to be set as financial task, its all parents should be selected
--                      : to be set as financial task implicitly.
--                      : Similarly, if a task is unselected to be financial task, all child tasks should be unset.
--                      : However, set on lowest task has higher precedence than unset on higher level task.
--                      :
-- Assumptions          : This API assumes that it will be called in display sequence order of tasks.
--                      : So that lowest task action (checked/unchecked) precedes its parents.
--                      : We assume that OA will call VO row Impl's update row in the same order as it is shown in Hgrid.

-- Parameters                   Type     Required        Description and Purpose
-- ---------------------------  ------   --------        --------------------------------------------------------
--   p_task_version_id           IN      Yes             Element Version Id of the modified task.
--   p_checked_flag              IN      Yes             This is Y/N depending on the checkbox is checked in the page.
--   p_record_version_number     IN      Yes             Record version number from  pa_proj_element_versions table
--   p_project_id                IN      Yes           Project_id of the project being updated.
--   p_published_version_exists  IN      Yes             Flag(Y/N) to indicate that whether published version exists for the project or not.

PROCEDURE SET_FINANCIAL_FLAG_WRAPPER
    (
       p_api_version               IN   NUMBER   := 1.0
     , p_init_msg_list             IN   VARCHAR2 := FND_API.G_TRUE
     , p_commit                    IN   VARCHAR2 := FND_API.G_FALSE
     , p_validate_only             IN   VARCHAR2 := FND_API.G_FALSE
     , p_validation_level          IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
     , p_calling_module            IN   VARCHAR2 := 'SELF_SERVICE'
     , p_debug_mode                IN   VARCHAR2 := 'N'
     , p_task_version_id           IN   NUMBER
     , p_checked_flag              IN   VARCHAR2
     , p_record_version_number     IN   NUMBER
     , p_project_id                IN   NUMBER
     , p_published_version_exists  IN   VARCHAR2
     , x_return_status             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count                 OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data                  OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   )
IS
l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);
l_task_version_id_tbl           task_version_id_table_type;
lCounterTable                   NUMBER := 0;
l_patask_record_version_number  NUMBER;
l_db_financial_flag             VARCHAR2(1);
l_cur_task_version_id           NUMBER;
l_last_task_parent_id           NUMBER;

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;

--This cursor gets all the parents of the current task
--Commented by rtarway during performance BUG fix : 3693360
/*CURSOR c_get_parents( l_project_id NUMBER, l_task_version_id NUMBER )
IS
SELECT
     element_version_id
   , financial_task_flag
FROM
     pa_proj_element_versions
WHERE
     project_id = l_project_id
AND
     element_version_id
IN
(--Get the Parents of the passed task
     SELECT
          object_id_from1 object_id
     FROM
          pa_object_relationships
     WHERE
          relationship_type  = 'S'
     AND
          relationship_subtype = 'TASK_TO_TASK'
     START WITH object_id_to1 =  l_task_version_id
     CONNECT BY Object_id_to1 = PRIOR object_id_from1
)
order by display_sequence desc -- Bug 3735089
;*/
--Commented by rtarway during performance BUG fix : 3693360
CURSOR c_get_parents( l_project_id NUMBER, l_task_version_id NUMBER )
IS
SELECT
     element_version_id
   , financial_task_flag
FROM
     pa_proj_element_versions elem,
     (--Get the Parents of the passed task
          SELECT
               object_id_from1 object_id
          FROM
               pa_object_relationships
          WHERE
               relationship_type  = 'S'
          AND
               relationship_subtype = 'TASK_TO_TASK'
          START WITH object_id_to1 =  l_task_version_id
          CONNECT BY Object_id_to1 = PRIOR object_id_from1
          AND RELATIONSHIP_TYPE = 'S'
     ) parents

WHERE
     elem.project_id = l_project_id
AND  elem.object_type = 'PA_TASKS'
AND  elem.element_version_id = parents.object_id
order by elem.display_sequence desc;

--Commented by rtarway for Perf FIX : BUG 3693360
/*
--This cursor gets all the children of the current task
CURSOR c_get_childs( l_project_id NUMBER, l_task_version_id NUMBER )
IS
SELECT
     element_version_id
   , financial_task_flag
FROM
     pa_proj_element_versions
WHERE
     project_id = l_project_id
AND
     element_version_id
IN
(-- Get the Childs of the mapped task
     SELECT
          object_id_to1 object_id
     FROM
          pa_object_relationships
     WHERE
          relationship_type ='S'
     AND
          relationship_subtype ='TASK_TO_TASK'
     START WITH object_id_from1 = l_task_version_id
     CONNECT BY object_id_from1 = PRIOR object_id_to1
)
order by display_sequence -- Bug 3735089
;*/

--Added by rtarway, modified Query for improving perf, BUG 3693360
CURSOR c_get_childs( l_project_id NUMBER, l_task_version_id NUMBER )
IS
SELECT
    element_version_id
  , financial_task_flag
FROM
    pa_proj_element_versions elem,
    (
         SELECT
               object_id_to1 object_id
         FROM
               pa_object_relationships
         WHERE
               relationship_type ='S'
         AND   relationship_subtype ='TASK_TO_TASK'
         START WITH object_id_from1 = l_task_version_id
         CONNECT BY object_id_from1 = PRIOR object_id_to1
            AND relationship_type ='S'
    ) childs
WHERE
    elem.project_id = l_project_id
and elem.object_type = 'PA_TASKS'
and elem.element_version_id = childs.object_id
order by elem.display_sequence;

--End Changes by rtarway for BUG 3693360


--This cursor gets the immediate parent of the passed task version id from the pa_object_relationships
CURSOR c_get_immediate_parent (l_object_id_to1 NUMBER)
IS
SELECT
     OBJECT_ID_FROM1
FROM
     pa_object_relationships
WHERE
     relationship_type ='S'
AND
     relationship_subtype ='TASK_TO_TASK'
AND
     OBJECT_ID_TO1 =  l_object_id_to1;

--This cursor gets the record version number from pa_tasks for the passed task version id
CURSOR c_get_pa_record_version_number (l_task_version_id NUMBER , l_project_id NUMBER)
IS
SELECT
       allTasks.record_version_number

FROM
     PA_TASKS allTasks,
     pa_proj_element_versions elever
WHERE
     elever.element_version_id = l_task_version_id
AND
     elever.project_id = l_project_id
AND  elever.proj_element_id  = allTasks.task_id
AND  allTasks.project_id = elever.project_id;

--Bug 3735089
l_syncup_task_version_id  NUMBER;
l_user_id                 NUMBER;
l_login_id                 NUMBER;
l_wp_version_enabled VARCHAR2(1);--Bug 4482903
BEGIN
     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;
     --Delete the elements from the table, if any
     l_task_version_id_tbl.DELETE;

     --Bug 3735089 - instead of fnd_profile.value use fnd_profile.value_specific
     --l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
     l_user_id := fnd_global.user_id;
     l_login_id := fnd_global.login_id;
     l_debug_mode  := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',l_user_id, l_login_id,275,null,null),'N');

     --l_debug_mode  := NVL(p_debug_mode,'N');
     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'SET_FINANCIAL_FLAG_WRAPPER',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN

          Pa_Debug.g_err_stage:= 'PA_TASKS_MAINT_PUB : SET_FINANCIAL_FLAG_WRAPPER : Printing Input parameters';

          Pa_Debug.WRITE(g_pkg_name,Pa_Debug.g_err_stage,
                         l_debug_level3);
          Pa_Debug.WRITE(g_pkg_name,'p_task_version_id'||':'||p_task_version_id,
                         l_debug_level3);
          Pa_Debug.WRITE(g_pkg_name,'p_checked_flag'||':'||p_checked_flag,
                         l_debug_level3);
          Pa_Debug.WRITE(g_pkg_name,'p_record_version_number'||':'||p_record_version_number,
                         l_debug_level3);
          Pa_Debug.WRITE(g_pkg_name,'p_project_id'||':'||p_project_id,
                         l_debug_level3);
          Pa_Debug.WRITE(g_pkg_name,'p_published_version_exists'||':'||p_published_version_exists,
                         l_debug_level3);
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
      FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
      savepoint SET_FIN_FLAG_WRAPPER_PUBLIC;
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_TASKS_MAINT_PUB : SET_FINANCIAL_FLAG_WRAPPER : Validating Input parameters';
          Pa_Debug.WRITE(g_pkg_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     IF (
           p_task_version_id IS NULL  OR
           p_checked_flag IS NULL  OR
           -- p_record_version_number IS NULL OR -- Bug # 4611527.
           p_project_id IS NULL OR
           p_published_version_exists IS NULL
        )
     THEN
           IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'PA_TASKS_MAINT_PUB : SET_FINANCIAL_FLAG_WRAPPER : At least one of the mandatory IN parameters are passed as NULL';
               Pa_Debug.WRITE(g_pkg_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
           END IF;
          RAISE Invalid_Arg_Exc_WP;
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_TASKS_MAINT_PUB : SET_FINANCIAL_FLAG_WRAPPER : Calling set_unset_financial_task';
          Pa_Debug.WRITE(g_pkg_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;
    --This part of code is common whether p_checked_flag is 'Y' or 'N'
    --Call API to set/unset financial_flag for p_task_version_id depending on p_checked_flag.

   PA_TASKS_MAINT_PVT.SET_UNSET_FINANCIAL_TASK
    (
            p_init_msg_list   => FND_API.G_FALSE
          , p_commit          => p_commit
          , p_debug_mode      => l_debug_mode
          , p_task_version_id => p_task_version_id
          , p_project_id      => p_project_id
          , p_checked_flag    => p_checked_flag
          , x_return_status   => x_return_status
          , x_msg_count       => x_msg_count
          , x_msg_data        => x_msg_data
    );

   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
   THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;
   l_wp_version_enabled := PA_PROJ_TASK_STRUC_PUB.IS_WP_VERSIONING_ENABLED(p_project_id); --Bug 4482903
   --If p_published_version_exists ='N'
   -- IF ( p_published_version_exists = 'N') --Bug 4482903
   -- Added an additional condition for handling the Version Disabled Case
   IF (p_published_version_exists ='N' OR l_wp_version_enabled= 'N') --Bug 4482903
   THEN
        --put the current task version id as the first element in table
        l_task_version_id_tbl(lCounterTable) := p_task_version_id;
        lCounterTable  := lCounterTable + 1;
   END IF;
   --Intialize the counter with current count of the table
   --lCounterTable := l_task_version_id_tbl.COUNT;
   --if p_checked_flag is Y
   IF (p_checked_flag = 'Y')
   THEN
        -- LOOP thru cursor c_get_parents(p_project_id, p_task_version_id)
        -- This loop will set the financial task flag
        -- for all the parent tasks of the current task

        FOR c_get_parents_rec IN c_get_parents(p_project_id, p_task_version_id) LOOP
          --FETCH c_get_parents INTO l_cur_task_version_id , l_db_financial_flag;
          l_cur_task_version_id := c_get_parents_rec.element_version_id;
          l_db_financial_flag := c_get_parents_rec.financial_task_flag;


          IF (l_db_financial_flag = 'Y')
          THEN
               --Exit from the loop as this condition implies that all the parent ladder tasks
               --are already set as financial task
               EXIT;
          ELSE

               --Set the financial task flag
               PA_TASKS_MAINT_PVT.SET_UNSET_FINANCIAL_TASK
               (
                      p_init_msg_list   => p_init_msg_list
                    , p_commit          => p_commit
                    , p_debug_mode      => l_debug_mode
                    , p_project_id      => p_project_id
                    , p_task_version_id => l_cur_task_version_id
                    , p_checked_flag    => p_checked_flag
                    , x_return_status   => x_return_status
                    , x_msg_count       => x_msg_count
                    , x_msg_data        => x_msg_data
               );

               IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
               THEN
                    RAISE FND_API.G_EXC_ERROR;
               END IF;

               IF ( p_published_version_exists = 'N')
               THEN
                    -- This will put all the task version id of the parent ladder
                    l_task_version_id_tbl(lCounterTable) := l_cur_task_version_id;
                    lCounterTable := lCounterTable + 1;
               END IF;
          END IF;--End if for l_db_financial task
        END LOOP;--End Loop for parent tasks of the current task
   ELSIF (p_checked_flag = 'N')
   THEN
        -- LOOP thru cursor c_get_childs(p_project_id, p_task_version_id)
        -- This loop will unset the financial task flag
        -- for all the child tasks of the current task

        FOR c_get_childs_rec IN c_get_childs(p_project_id, p_task_version_id) LOOP
          --FETCH c_get_childs INTO l_cur_task_version_id , l_db_financial_flag;
          l_cur_task_version_id := c_get_childs_rec.element_version_id;
          l_db_financial_flag := c_get_childs_rec.financial_task_flag;


          IF (l_db_financial_flag = 'N')
          THEN
               --Exit from the loop as this condition implies that all the child ladder tasks
               --are already unset as financial task
               --EXIT;
               --As the above assumption is wrong if there are peer tasks at a level which are not set as financial task
               NULL;
          ELSE

               --Unset the financial task flag
               PA_TASKS_MAINT_PVT.SET_UNSET_FINANCIAL_TASK
               (
                      p_init_msg_list   => p_init_msg_list
                    , p_commit          => p_commit
                    , p_debug_mode      => l_debug_mode
                    , p_project_id      => p_project_id
                    , p_task_version_id => l_cur_task_version_id
                    , p_checked_flag    => p_checked_flag
                    , x_return_status   => x_return_status
                    , x_msg_count       => x_msg_count
                    , x_msg_data        => x_msg_data
               );

               IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
               THEN
                    RAISE FND_API.G_EXC_ERROR;
               END IF;

               IF ( p_published_version_exists = 'N')
               THEN
                    l_task_version_id_tbl(lCounterTable) := l_cur_task_version_id;
                    lCounterTable := lCounterTable + 1;
               END IF;
          END IF;--End if for l_db_financial task
        END LOOP;--End Loop for child tasks of the current task
   END IF;--End if for the p_checked_flag='Y'
   --IF ( p_published_version_exists = 'N') --Bug 4482903
   -- Added an additional condition for handling the Version Disabled Case
   IF (p_published_version_exists ='N' OR l_wp_version_enabled= 'N') --Bug 4482903
   THEN


       -- Bug 3735089 Added below IF condition
       -- It is sufficient to delete top task in case checked flag as N
       -- no need to loop and delete all child tasks
       IF p_checked_flag = 'N' THEN
          l_syncup_task_version_id := p_task_version_id;
       ELSE
          l_syncup_task_version_id := l_task_version_id_tbl(l_task_version_id_tbl.LAST);
       END IF;

       --Get record version number from pa_tasks table
       -- OPEN  c_get_pa_record_version_number (l_task_version_id_tbl(l_task_version_id_tbl.LAST) , p_project_id); --Bug 3735089
       OPEN  c_get_pa_record_version_number (l_syncup_task_version_id , p_project_id);
       FETCH c_get_pa_record_version_number INTO l_patask_record_version_number;
       CLOSE c_get_pa_record_version_number;

       --get the parent of the last task.
       --OPEN  c_get_immediate_parent (l_task_version_id_tbl(l_task_version_id_tbl.LAST)); --Bug 3735089
       OPEN  c_get_immediate_parent (l_syncup_task_version_id);
       FETCH c_get_immediate_parent INTO l_last_task_parent_id;
       IF (c_get_immediate_parent%NOTFOUND)
       THEN
           --if the parent is structure then then pass p_parent_task_version_id as null
            PA_TASKS_MAINT_PUB.SYNC_UP_WP_TASKS_WITH_FIN
            (
                 p_api_version                    => 1.0
               , p_init_msg_list                  => FND_API.G_FALSE
               , p_commit                         => p_commit
               , p_validate_only                  => FND_API.G_FALSE
               , p_validation_level               => FND_API.G_VALID_LEVEL_FULL
               , p_calling_module                 => 'SELF_SERVICE'
               , p_debug_mode                     => l_debug_mode
               , p_patask_record_version_number   => l_patask_record_version_number
               , p_parent_task_version_id         => FND_API.G_MISS_NUM
               , p_project_id                     => p_project_id
               , p_syncup_all_tasks               => 'N'
              -- , p_task_version_id                => l_task_version_id_tbl(l_task_version_id_tbl.LAST)--Bug 3735089
               , p_task_version_id                => l_syncup_task_version_id
               , p_structure_version_id           => FND_API.G_MISS_NUM
               , p_check_for_transactions         => 'N'
               , p_checked_flag                   => p_checked_flag
               , p_mode                           => 'SINGLE'
               , x_return_status                  => x_return_status
               , x_msg_count                      => x_msg_count
               , x_msg_data                       => x_msg_data
             );
        -- Bug 3735089 : Added error handling code
                IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
                THEN
                     RAISE FND_API.G_EXC_ERROR;
                END IF;

            ELSE

               --else pass the derived parent task version id
               PA_TASKS_MAINT_PUB.SYNC_UP_WP_TASKS_WITH_FIN
               (
                  p_debug_mode                    => l_debug_mode
                , p_commit                        => p_commit
                , p_init_msg_list                 => FND_API.G_FALSE
                , p_patask_record_version_number  => l_patask_record_version_number
                , p_parent_task_version_id        => l_last_task_parent_id
                , p_project_id                    => p_project_id
                , p_syncup_all_tasks              =>'N'
                --, p_task_version_id               => l_task_version_id_tbl(l_task_version_id_tbl.LAST)-- Bug 3735089
                , p_task_version_id               => l_syncup_task_version_id
                , p_checked_flag                  => p_checked_flag
                , p_mode                          => 'SINGLE'
                , p_check_for_transactions        =>'N'
                , x_return_status                 => x_return_status
                , x_msg_count                     => x_msg_count
                , x_msg_data                      => x_msg_data
               );
        -- Bug 3735089 : Added error handling code
                IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
                THEN
                     RAISE FND_API.G_EXC_ERROR;
                END IF;

       END IF;
       CLOSE c_get_immediate_parent;

       --For All other tasks in the l_task_version_id_tbl,  loop in reverse order and call sync-up API
       -- Pass the 1 up task version id in table as the parent
       IF (l_task_version_id_tbl.COUNT > 1 AND p_checked_flag = 'Y') -- Bug 3735089 : Added  p_checked_flag = 'Y'
       THEN

            FOR iCounter IN REVERSE l_task_version_id_tbl.FIRST..l_task_version_id_tbl.LAST-1 LOOP

                PA_TASKS_MAINT_PUB.SYNC_UP_WP_TASKS_WITH_FIN
                (
                       p_debug_mode                    => l_debug_mode
                     , p_commit                        => p_commit
                     , p_init_msg_list                 => FND_API.G_FALSE
                     , p_patask_record_version_number  => l_patask_record_version_number
                     , p_parent_task_version_id        => l_task_version_id_tbl( iCounter + 1 )
                     , p_project_id                    => p_project_id
                     , p_syncup_all_tasks              =>'N'
                     , p_task_version_id               => l_task_version_id_tbl( iCounter )
                     , p_checked_flag                  => p_checked_flag
                     , p_mode                          => 'SINGLE'
                     , p_check_for_transactions        =>'N'
                     , x_return_status                 => x_return_status
                     , x_msg_count                     => x_msg_count
                     , x_msg_data                      => x_msg_data
                );
                IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
                THEN
                     RAISE FND_API.G_EXC_ERROR;
                END IF;
            END LOOP;
       END IF;
   END IF;

  IF (p_commit = FND_API.G_TRUE) THEN
     COMMIT;
  END IF;
  -- Bug 3735089 : using reset_curr_function too, just using set_curr_function may overflow it after several recursive calls
  -- and it gives ORA 06512 numeric or value error
  IF l_debug_mode = 'Y' THEN
      Pa_Debug.reset_curr_function;
  END IF;

 EXCEPTION

 WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     l_msg_count := Fnd_Msg_Pub.count_msg;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO SET_FIN_FLAG_WRAPPER_PUBLIC;
     END IF;

     IF c_get_parents%ISOPEN THEN
          CLOSE c_get_parents;
     END IF;

     IF c_get_childs%ISOPEN THEN
          CLOSE c_get_childs;
     END IF;
     IF c_get_immediate_parent%ISOPEN THEN
          CLOSE c_get_immediate_parent;
     END IF;
     IF c_get_pa_record_version_number%ISOPEN THEN
          CLOSE c_get_pa_record_version_number;
     END IF;


     IF l_msg_count = 1 AND x_msg_data IS NULL
      THEN
          Pa_Interface_Utils_Pub.get_messages
              ( p_encoded        => Fnd_Api.G_TRUE
              , p_msg_index      => 1
              , p_msg_count      => l_msg_count
              , p_msg_data       => l_msg_data
              , p_data           => l_data
              , p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.reset_curr_function;
     END IF;

 WHEN Invalid_Arg_Exc_WP THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'PA_TASKS_MAINT_PUB : SET_FINANCIAL_FLAG_WRAPPER : NULL PARAMETERS ARE PASSED OR CURSOR DIDNT RETURN ANY ROWS';

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO SET_FIN_FLAG_WRAPPER_PUBLIC;
     END IF;
     IF c_get_parents%ISOPEN THEN
          CLOSE c_get_parents;
     END IF;

     IF c_get_childs%ISOPEN THEN
          CLOSE c_get_childs;
     END IF;
     IF c_get_immediate_parent%ISOPEN THEN
          CLOSE c_get_immediate_parent;
     END IF;
     IF c_get_pa_record_version_number%ISOPEN THEN
          CLOSE c_get_pa_record_version_number;
     END IF;
     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_TASKS_MAINT_PUB'
                    , p_procedure_name  => 'SET_FINANCIAL_FLAG_WRAPPER'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_pkg_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

 WHEN OTHERS THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := substr(SQLERRM,1,120);-- Bug 3735089 Added substr

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO SET_FIN_FLAG_WRAPPER_PUBLIC;
     END IF;

     IF c_get_parents%ISOPEN THEN
          CLOSE c_get_parents;
     END IF;

     IF c_get_childs%ISOPEN THEN
          CLOSE c_get_childs;
     END IF;
     IF c_get_immediate_parent%ISOPEN THEN
          CLOSE c_get_immediate_parent;
     END IF;
     IF c_get_pa_record_version_number%ISOPEN THEN
          CLOSE c_get_pa_record_version_number;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name         => 'PA_TASKS_MAINT_PUB'
                    , p_procedure_name  => 'SET_FINANCIAL_FLAG_WRAPPER'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_pkg_name,Pa_Debug.g_err_stage,
                              l_debug_level5);

          Pa_Debug.reset_curr_function;

     END IF;
     RAISE;
END SET_FINANCIAL_FLAG_WRAPPER ;

-- Procedure            : POPULATE_TEMP_TABLE
-- Type                 : Public Procedure
-- Purpose              : This API will be called from set financial tasks page in financial tab
--                      : This Api is to populate the global temp
--                      : table PA_PREVIEW_FIN_TASKS_TEMP for Preview Financial tasks page.
--                      : The VO of Preview page is based on this temp table
--                      :
-- Note                 : This API first populates the temp table with structure information and then it selects all the parent
--                      : tasks for the passed task id and popultes the temp table with parent tasks information
--                      :
-- Assumptions          :

-- Parameters                   Type                   Required        Description and Purpose
-- ---------------------------  ------                 --------        --------------------------------------------------------
-- p_task_version_id_array      SYSTEM.PA_NUM_TBL_TYPE Yes             Array of checked Element Version Id from the Set Financial Tasks page.
-- p_structure_version_id       NUMBER                 Yes             Structure Version Id of the structure being previewed.
-- p_project_id                 NUMBER                 Yes             Project_id of the project being used.

PROCEDURE POPULATE_TEMP_TABLE
    (
       p_api_version           IN   NUMBER   := 1.0
     , p_init_msg_list         IN   VARCHAR2 := FND_API.G_TRUE
     , p_commit                IN   VARCHAR2 := FND_API.G_FALSE
     , p_validate_only         IN   VARCHAR2 := FND_API.G_FALSE
     , p_validation_level      IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
     , p_calling_module        IN   VARCHAR2 := 'SELF_SERVICE'
     , p_debug_mode            IN   VARCHAR2 := 'N'
     , p_task_version_id_array IN   SYSTEM.PA_NUM_TBL_TYPE := NULL
     , p_structure_version_id  IN   NUMBER
     , p_project_id            IN   NUMBER
     , x_return_status     OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count         OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data          OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   )
IS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);
l_rec_fin_tasks_temp            fin_tasks_temp_record_type;
--l_rec_fin_tasks_temp_tbl        fin_tasks_temp_table_type;


l_project_id_tbl                  project_id_table_type ;
l_element_version_id_tbl          ELEMENT_VERSION_ID_table_type;
l_prnt_struct_ver_id_tbl          PRNT_STRUCT_VER_ID_table_type;
l_prnt_elem_ver_id_tbl            PRNT_ELEM_VER_ID_table_type;
l_child_element_flag_tbl          CHILD_ELEMENT_FLAG_table_type ;
l_task_name_tbl                   TASK_NAME_table_type ;
l_task_number_tbl                 TASK_NUMBER_table_type;
l_object_type_tbl                 OBJECT_TYPE_table_type ;
l_display_sequence_tbl            DISPLAY_SEQUENCE_table_type;
l_wbs_number_tbl                  WBS_NUMBER_table_type ;
l_proj_element_id_tbl             PROJ_ELEMENT_ID_table_type;
l_fin_task_flag_tbl               FINANCIAL_TASK_FLAG_table_type;

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;

--This cursor will get all the structure Information for the passed project id and structure id
CURSOR c_get_structure_info(l_project_id NUMBER, l_element_version_id NUMBER)
IS
SELECT
  elemver.project_id AS PROJECT_ID
, elemver.element_version_id AS ELEMENT_VERSION_ID
, elemver.parent_structure_version_id AS PARENT_STRUCTRE_VERSION_ID
, null AS PARENT_ELEMENT_VERSION_ID
, PA_PROJ_ELEMENTS_UTILS.check_child_element_exist(elemver.element_version_id) AS CHILD_ELEMENT_FLAG
, elem.name AS TASK_NAME
--, elem.element_number AS TASK_NUMBER -- Commented for Bug 5438975
, verstruct.version_number as TASK_NUMBER -- Added for Bug 5438975
, elem.object_type  AS OBJECT_TYPE
, elemver.display_sequence AS DISPLAY_SEQUENCE
, elemver.wbs_number AS WBS_NUMBER
, elem.proj_element_id AS PROJ_ELEMENT_ID
, elemver.financial_task_flag AS FINANCIAL_TASK_FLAG
FROM
  pa_proj_elements elem
, pa_proj_element_versions elemver
, pa_proj_elem_ver_structure verstruct -- Added for Bug 5438975
WHERE elem.proj_element_id = elemver.proj_element_id
AND elem.project_id = elemver.project_id
AND elemver.element_version_id = l_element_version_id
AND elemver.project_id = l_project_id
-- Added for Bug 5438975
AND verstruct.project_id = elemver.project_id
AND verstruct.ELEMENT_VERSION_ID = elemver.element_version_id
AND verstruct.PROJ_ELEMENT_ID = elemver.proj_element_id;

-- This curosor gets the details of the parents of the passed task along with the passed task itself
CURSOR c_get_parents (l_project_id NUMBER, l_task_version_id NUMBER)
IS
SELECT
  elemver.project_id AS PROJECT_ID
, elemver.element_version_id AS ELEMENT_VERSION_ID
, elemver.parent_structure_version_id AS PARENT_STRUCTRE_VERSION_ID
, por.object_id_from1 AS PARENT_ELEMENT_VERSION_ID
, PA_PROJ_ELEMENTS_UTILS.check_child_element_exist(elemver.element_version_id) AS CHILD_ELEMENT_FLAG
, projelem.name AS TASK_NAME
, projelem.element_number AS TASK_NUMBER
, elemver.object_type AS OBJECT_TYPE
, elemver.display_sequence AS DISPLAY_SEQUENCE
, elemver.wbs_number AS WBS_NUMBER
, elemver.proj_element_id AS PROJ_ELEMENT_ID
, elemver.financial_task_flag AS FINANCIAL_TASK_FLAG
FROM
  pa_proj_element_versions elemver
, pa_proj_elements projelem
, pa_object_relationships por
WHERE
    projelem.project_id = elemver.project_id
AND projelem.proj_element_id = elemver.proj_element_id
AND elemver.object_type='PA_TASKS'
AND projelem.object_type='PA_TASKS'
AND por.object_type_from IN ('PA_STRUCTURES', 'PA_TASKS')
AND por.object_id_to1 = elemver.element_version_id
AND por.object_type_to IN ('PA_STRUCTURES', 'PA_TASKS')
AND por.relationship_type = 'S'
AND elemver.project_id = l_project_id
AND elemver.element_version_id IN
(--Get the Parents of the passed task
     SELECT object_id_from1 object_id
     FROM pa_object_relationships
     WHERE relationship_type  = 'S'
     AND relationship_subtype = 'TASK_TO_TASK'
     START WITH object_id_to1 =  l_task_version_id
     CONNECT BY Object_id_to1 = PRIOR object_id_from1
     UNION
     SELECT l_task_version_id--Get the Passed task itself
     FROM dual
)
AND NOT EXISTS -- This is to insure that the same record does not get inserted twice
(
     SELECT 'xyz'
     FROM pa_preview_fin_tasks_temp temp
     WHERE temp.element_version_id = elemver.element_version_id
);

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
     --l_debug_mode  := NVL(p_debug_mode,'N');
     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'POPULATE_TEMP_TABLE',
                                      p_debug_mode => l_debug_mode );
     END IF;



     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_TASKS_MAINT_PUB:POPULATE_TEMP_TABLE:Printing Input parameters';
          Pa_Debug.WRITE(g_pkg_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_pkg_name,'p_structure_version_id'||':'||p_structure_version_id,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_pkg_name,'p_project_id'||':'||p_project_id,
                                     l_debug_level3);
     END IF;

     --Delete all elements from temporary table first.
     BEGIN
          DELETE FROM pa_preview_fin_tasks_temp;

     EXCEPTION
          WHEN OTHERS THEN

          RAISE;
     END;

     --Delete all the elements from all PL/sql tables before using
     l_project_id_tbl.DELETE;
     l_element_version_id_tbl.DELETE;
     l_prnt_struct_ver_id_tbl.DELETE;
     l_prnt_elem_ver_id_tbl.DELETE;
     l_child_element_flag_tbl.DELETE;
     l_task_name_tbl.DELETE;
     l_task_number_tbl.DELETE;
     l_object_type_tbl.DELETE;
     l_display_sequence_tbl.DELETE;
     l_wbs_number_tbl.DELETE;
     l_proj_element_id_tbl.DELETE;
     l_fin_task_flag_tbl.DELETE;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
      FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
      savepoint POPULATE_TEMP_TBL_PUB;
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_TASKS_MAINT_PUB : POPULATE_TEMP_TABLE : Validating Input parameters';
          Pa_Debug.WRITE(g_pkg_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     IF (
          --( p_task_version_id_array IS NULL ) OR
          ( p_structure_version_id IS NULL  ) OR
          ( p_project_id IS NULL )
        )
     THEN
           IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'PA_TASKS_MAINT_PUB : POPULATE_TEMP_TABLE : At least one of the mandatory IN parameters are passed as NULL';
               Pa_Debug.WRITE(g_pkg_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
           END IF;
          RAISE Invalid_Arg_Exc_WP;
     END IF;

     --Open cursor c_get_structure_info and get the structure information
     OPEN c_get_structure_info(p_project_id , p_structure_version_id);
     FETCH c_get_structure_info INTO l_rec_fin_tasks_temp;
     INSERT INTO pa_preview_fin_tasks_temp
     (
            PROJECT_ID
          , ELEMENT_VERSION_ID
          , PARENT_STRUCTURE_VERSION_ID
          , PARENT_ELEMENT_VERSION_ID
          , CHILD_ELEMENT_FLAG
          , TASK_NAME
          , TASK_NUMBER
          , OBJECT_TYPE
          , DISPLAY_SEQUENCE
          , WBS_NUMBER
          , PROJ_ELEMENT_ID
          , FINANCIAL_TASK_FLAG
     )
     VALUES
     (
            l_rec_fin_tasks_temp.PROJECT_ID
          , l_rec_fin_tasks_temp.element_version_id
          , l_rec_fin_tasks_temp.parent_structure_version_id
          , l_rec_fin_tasks_temp.parent_element_version_id
          , l_rec_fin_tasks_temp.child_element_flag
          , l_rec_fin_tasks_temp.task_name
          , l_rec_fin_tasks_temp.task_number
          , l_rec_fin_tasks_temp.object_type
          , l_rec_fin_tasks_temp.display_sequence
          , l_rec_fin_tasks_temp.wbs_number
          , l_rec_fin_tasks_temp.proj_element_id
          , l_rec_fin_tasks_temp.financial_task_flag
     );
     CLOSE c_get_structure_info;

     IF (p_task_version_id_array IS NOT NULL AND p_task_version_id_array.COUNT >0) THEN
          FOR iCounter IN REVERSE p_task_version_id_array.FIRST..p_task_version_id_array.LAST LOOP
               --Get all the parentes of the task Ids passed

               OPEN c_get_parents ( p_project_id , p_task_version_id_array (iCounter) );
               --Bulk Collect the cursor in to table of pa_preview_fin_tasks_temp_tbl type records
               FETCH c_get_parents BULK COLLECT INTO
                 l_project_id_tbl
               , l_element_version_id_tbl
               , l_prnt_struct_ver_id_tbl
               , l_prnt_elem_ver_id_tbl
               , l_child_element_flag_tbl
               , l_task_name_tbl
               , l_task_number_tbl
               , l_object_type_tbl
               , l_display_sequence_tbl
               , l_wbs_number_tbl
               , l_proj_element_id_tbl
               , l_fin_task_flag_tbl;

               CLOSE c_get_parents;


               IF (l_element_version_id_tbl.COUNT > 0)THEN
                    --Loop thorugh the table and insert all the data in the temp table
                    FORALL iCounter1 IN l_element_version_id_tbl.FIRST..l_element_version_id_tbl.LAST
                         INSERT INTO pa_preview_fin_tasks_temp
                         (
                                PROJECT_ID
                              , ELEMENT_VERSION_ID
                              , PARENT_STRUCTURE_VERSION_ID
                              , PARENT_ELEMENT_VERSION_ID
                              , CHILD_ELEMENT_FLAG
                              , TASK_NAME
                              , TASK_NUMBER
                              , OBJECT_TYPE
                              , DISPLAY_SEQUENCE
                              , WBS_NUMBER
                              , PROJ_ELEMENT_ID
                              , FINANCIAL_TASK_FLAG
                         )
                         VALUES
                         (
                                l_project_id_tbl(iCounter1)
                              , l_element_version_id_tbl(iCounter1)
                              , l_prnt_struct_ver_id_tbl(iCounter1)
                              , l_prnt_elem_ver_id_tbl(iCounter1)
                              , l_child_element_flag_tbl(iCounter1)
                              , l_task_name_tbl(iCounter1)
                              , l_task_number_tbl(iCounter1)
                              , l_object_type_tbl(iCounter1)
                              , l_display_sequence_tbl(iCounter1)
                              , l_wbs_number_tbl(iCounter1)
                              , l_proj_element_id_tbl(iCounter1)
                              , l_fin_task_flag_tbl(iCounter1)
                         );
               END IF;
          END LOOP;
     END IF;
     IF (p_commit = FND_API.G_TRUE) THEN
          COMMIT;
     END IF;

     EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN

          x_return_status := Fnd_Api.G_RET_STS_ERROR;
          l_msg_count := Fnd_Msg_Pub.count_msg;

          IF p_commit = FND_API.G_TRUE THEN
             ROLLBACK TO POPULATE_TEMP_TABLE_PUB;
          END IF;

          IF c_get_structure_info%ISOPEN THEN
               CLOSE c_get_structure_info;
          END IF;

          IF c_get_parents%ISOPEN THEN
               CLOSE c_get_parents;
          END IF;


          IF l_msg_count = 1 AND x_msg_data IS NULL
           THEN
               Pa_Interface_Utils_Pub.get_messages
                   ( p_encoded        => Fnd_Api.G_TRUE
                   , p_msg_index      => 1
                   , p_msg_count      => l_msg_count
                   , p_msg_data       => l_msg_data
                   , p_data           => l_data
                   , p_msg_index_out  => l_msg_index_out);
               x_msg_data := l_data;
               x_msg_count := l_msg_count;
          ELSE
               x_msg_count := l_msg_count;
          END IF;
          IF l_debug_mode = 'Y' THEN
               Pa_Debug.reset_curr_function;
          END IF;

     WHEN Invalid_Arg_Exc_WP THEN

          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := 'PA_TASKS_MAINT_PUB : POPULATE_TEMP_TABLE : NULL PARAMETERS ARE PASSED OR CURSOR DIDNT RETURN ANY ROWS';

          IF p_commit = FND_API.G_TRUE THEN
             ROLLBACK TO POPULATE_TEMP_TABLE_PUB;
          END IF;
          IF c_get_structure_info%ISOPEN THEN
               CLOSE c_get_structure_info;
          END IF;

          IF c_get_parents%ISOPEN THEN
               CLOSE c_get_parents;
          END IF;
          Fnd_Msg_Pub.add_exc_msg
                        ( p_pkg_name        => 'PA_TASKS_MAINT_PUB'
                         , p_procedure_name  => 'POPULATE_TEMP_TABLE'
                         , p_error_text      => x_msg_data);

          IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
               Pa_Debug.WRITE(g_pkg_name,Pa_Debug.g_err_stage,
                                   l_debug_level5);
               Pa_Debug.reset_curr_function;
          END IF;
          RAISE;

     WHEN OTHERS THEN

          x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
          x_msg_count     := 1;
          x_msg_data      := substr(SQLERRM,1,120);-- Bug 3735089 Added substr

          IF p_commit = FND_API.G_TRUE THEN
             ROLLBACK TO POPULATE_TEMP_TABLE_PUB;
          END IF;
          IF c_get_structure_info%ISOPEN THEN
               CLOSE c_get_structure_info;
          END IF;

          IF c_get_parents%ISOPEN THEN
               CLOSE c_get_parents;
          END IF;

          Fnd_Msg_Pub.add_exc_msg
                        ( p_pkg_name         => 'PA_TASKS_MAINT_PUB'
                         , p_procedure_name  => 'POPULATE_TEMP_TABLE'
                         , p_error_text      => x_msg_data);

          IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
               Pa_Debug.WRITE(g_pkg_name,Pa_Debug.g_err_stage,
                                   l_debug_level5);
               Pa_Debug.reset_curr_function;
          END IF;
          RAISE;
END POPULATE_TEMP_TABLE ;


-- Procedure            : SYNC_UP_WP_TASKS_WITH_FIN
-- Type                 : Public Procedure
-- Purpose              : This API will be called from set financial tasks page in financial tab
--                      : This API is to Sync up the financial tasks with pa_tasks table
-- Note                 : This API does all the validations required on parameters and calls private API
--                      :
-- Assumptions          : The financial_task_flag is already set in the database.

-- Parameters                      Type     Required        Description and Purpose
-- ---------------------------     ------   --------        --------------------------------------------------------
-- p_project_id                    NUMBER     Yes            Project_id of the project being synced up.
-- p_syncup_all_tasks              VARCHAR2   NO             Flag indicating Y/N whether to sync up all the tasks for the given structure version id.
-- p_task_version_id               NUMBER     NO             The single task's version id. This is applicable for singular case.
-- p_structure_version_id          NUMBER     NO             The structre version_id of the structre being synced up. This is applicable when we want to sync up all the tasks.
-- p_checked_flag                  VARCHAR2   NO             This flag(Y/N) will be applicable in singular case where task_version_id is being passed. This is passed so that this API again do not have to fetch financial_task_flag from the database.
-- p_mode                          VARCHAR2   NO             The mode mentioning that whether processing is to be done for All the tasks in the structure or juts for the single passed task. Possible values are SINGLE and ALL
-- p_patask_record_version_number  NUMBER     NO             This is record version number of the record in pa_tasks
-- p_parent_task_version_id        NUMBER     NO             This is parent task version id of the current task, It is needed in create_task

PROCEDURE SYNC_UP_WP_TASKS_WITH_FIN
    (
       p_api_version                    IN   NUMBER   := 1.0
     , p_init_msg_list                  IN   VARCHAR2 := FND_API.G_TRUE
     , p_commit                         IN   VARCHAR2 := FND_API.G_FALSE
     , p_validate_only                  IN   VARCHAR2 := FND_API.G_FALSE
     , p_validation_level               IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL
     , p_calling_module                 IN   VARCHAR2 := 'SELF_SERVICE'
     , p_debug_mode                     IN   VARCHAR2 := 'N'
     , p_patask_record_version_number   IN   NUMBER   := FND_API.G_MISS_NUM
     , p_parent_task_version_id         IN   NUMBER   := FND_API.G_MISS_NUM
     , p_project_id                     IN   NUMBER
     , p_syncup_all_tasks               IN   VARCHAR2 := 'N'
     , p_task_version_id                IN   NUMBER   := FND_API.G_MISS_NUM
     , p_structure_version_id           IN   NUMBER   := FND_API.G_MISS_NUM
     , p_check_for_transactions         IN   VARCHAR2 := 'N'
     , p_checked_flag                   IN   VARCHAR2 := FND_API.G_MISS_CHAR
     , p_mode                           IN   VARCHAR2 := 'SINGLE'
     , x_return_status                  OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count                      OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data                       OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   )
IS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;

--Bug 3735089
l_user_id                 NUMBER;
l_login_id                 NUMBER;

BEGIN

     x_msg_count := 0;
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     --Bug 3735089 - instead of fnd_profile.value use fnd_profile.value_specific
     --l_debug_mode  := NVL(FND_PROFILE.value('PA_DEBUG_MODE'),'N');
     l_user_id := fnd_global.user_id;
     l_login_id := fnd_global.login_id;
     l_debug_mode  := NVL(FND_PROFILE.value_specific('PA_DEBUG_MODE',l_user_id, l_login_id,275,null,null),'N');

     --l_debug_mode  := NVL(p_debug_mode,'N');
     IF l_debug_mode = 'Y' THEN
          PA_DEBUG.set_curr_function( p_function   => 'SYNC_UP_WP_TASKS_WITH_FIN',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_TASKS_MAINT_PUB : SYNC_UP_WP_TASKS_WITH_FIN : Printing Input parameters';
          Pa_Debug.WRITE(g_pkg_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_pkg_name,'p_project_id  '||':'||p_project_id  ,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_pkg_name,'p_syncup_all_tasks'||':'||p_syncup_all_tasks,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_pkg_name,'p_task_version_id'||':'|| p_task_version_id   ,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_pkg_name,'p_structure_version_id'||':'|| p_structure_version_id,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_pkg_name,'p_checked_flag '||':'||p_checked_flag ,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_pkg_name,'p_mode'||':'||p_mode,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_pkg_name,'p_parent_task_version_id'||':'||p_parent_task_version_id,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_pkg_name,'p_patask_record_version_number'||':'||p_patask_record_version_number,
                                     l_debug_level3);
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
      FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
      savepoint SYNC_UP_WITH_FIN_PUBLIC;
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_TASKS_MAINT_PUB : SYNC_UP_WP_TASKS_WITH_FIN : Validating Input parameters';
          Pa_Debug.WRITE(g_pkg_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     IF ( p_project_id IS NULL)
     THEN
           IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'PA_TASKS_MAINT_PUB : SYNC_UP_WP_TASKS_WITH_FIN : Mandatory parameters are null';
               Pa_Debug.WRITE(g_pkg_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
           END IF;
           RAISE Invalid_Arg_Exc_WP;
     END IF;

     --Validating for p_mode, it shopuld be either SINGLE or ALL
     /*IF (p_mode <> 'SINGLE' OR  p_mode <> 'ALL')
     THEN
           IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'PA_TASKS_MAINT_PUB : SYNC_UP_WP_TASKS_WITH_FIN : p_mode is invalid';
               Pa_Debug.WRITE(g_pkg_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
           END IF;
           RAISE Invalid_Arg_Exc_WP;
     END IF;*/
    --If p_mode = SINGLE, then p_task_version_id and p_checked_flag should be passed not null
     IF ( ( p_mode='SINGLE') AND
          (
               ( p_task_version_id IS NULL OR p_task_version_id = FND_API.G_MISS_NUM  ) OR
               ( p_checked_flag IS NULL OR p_checked_flag = FND_API.G_MISS_CHAR )
          )
        )
     THEN
          IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'PA_TASKS_MAINT_PUB : SYNC_UP_WP_TASKS_WITH_FIN : Manadatory parameters with mode '||p_mode||'are not passed';
               Pa_Debug.WRITE(g_pkg_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
          END IF;
          RAISE Invalid_Arg_Exc_WP;
     ELSIF ( ( p_mode = 'ALL')
          AND
             ( p_structure_version_id IS NULL OR p_structure_version_id = FND_API.G_MISS_NUM )
           )
     THEN
          IF l_debug_mode = 'Y' THEN
               Pa_Debug.g_err_stage:= 'PA_TASKS_MAINT_PUB : SYNC_UP_WP_TASKS_WITH_FIN : Manadatory parameters with mode '||p_mode||'are not passed';
               Pa_Debug.WRITE(g_pkg_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
          END IF;
          RAISE Invalid_Arg_Exc_WP;
     END IF;

     -- Call Private APIs
     PA_TASKS_MAINT_PVT.SYNC_UP_WP_TASKS_WITH_FIN
     (
         p_init_msg_list                => FND_API.G_FALSE
       , p_commit                       => p_commit
       , p_debug_mode                   => l_debug_mode
       , p_project_id                   => p_project_id
       , p_syncup_all_tasks             => p_syncup_all_tasks
       , p_patask_record_version_number => p_patask_record_version_number
       , p_parent_task_version_id       => p_parent_task_version_id
       , p_task_version_id              => p_task_version_id
       , p_structure_version_id         => p_structure_version_id
       , p_checked_flag                 => p_checked_flag
       , p_mode                         => p_mode
       , x_return_status                => x_return_status
       , x_msg_count                    => x_msg_count
       , x_msg_data                     => x_msg_data
     );
     IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
     THEN
       RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
       COMMIT;
     END IF;

     -- Bug 3735089 : using reset_curr_function too, just using set_curr_function may overflow it after several recursive calls
     -- and it gives ORA 06512 numeric or value error
      IF l_debug_mode = 'Y' THEN
    Pa_Debug.reset_curr_function;
      END IF;

EXCEPTION

WHEN FND_API.G_EXC_ERROR THEN

     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     l_msg_count := Fnd_Msg_Pub.count_msg;

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO SYNC_UP_WITH_FIN_PUBLIC;
     END IF;


     IF l_msg_count = 1 AND x_msg_data IS NULL
      THEN
          Pa_Interface_Utils_Pub.get_messages
              ( p_encoded        => Fnd_Api.G_TRUE
              , p_msg_index      => 1
              , p_msg_count      => l_msg_count
              , p_msg_data       => l_msg_data
              , p_data           => l_data
              , p_msg_index_out  => l_msg_index_out);
          x_msg_data := l_data;
          x_msg_count := l_msg_count;
     ELSE
          x_msg_count := l_msg_count;
     END IF;
     IF l_debug_mode = 'Y' THEN
          Pa_Debug.reset_curr_function;
     END IF;

WHEN Invalid_Arg_Exc_WP THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := 'PA_TASKS_MAINT_PUB : SYNC_UP_WP_TASKS_WITH_FIN : NULL PARAMETERS ARE PASSED OR CURSOR DIDNT RETURN ANY ROWS';

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO SYNC_UP_WITH_FIN_PUBLIC;
     END IF;


     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_TASKS_MAINT_PUB'
                    , p_procedure_name  => 'SYNC_UP_WP_TASKS_WITH_FIN'
                    , p_error_text      => x_msg_data);
     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_pkg_name,Pa_Debug.g_err_stage,
                              l_debug_level5);

          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;

WHEN OTHERS THEN

     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     x_msg_count     := 1;
     x_msg_data      := substr(SQLERRM,1,120);-- Bug 3735089 Added substr

     IF p_commit = FND_API.G_TRUE THEN
        ROLLBACK TO SYNC_UP_WITH_FIN_PUBLIC;
     END IF;



     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name         => 'PA_TASKS_MAINT_PUB'
                    , p_procedure_name  => 'SYNC_UP_WP_TASKS_WITH_FIN'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_pkg_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
      Pa_Debug.reset_curr_function;
     END IF;
     RAISE;
END SYNC_UP_WP_TASKS_WITH_FIN ;

--3279982 End Add rtarway for FP.M develeopment
end PA_TASKS_MAINT_PUB;

/
