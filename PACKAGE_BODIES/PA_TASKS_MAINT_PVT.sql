--------------------------------------------------------
--  DDL for Package Body PA_TASKS_MAINT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_TASKS_MAINT_PVT" as
/*$Header: PATSKSVB.pls 120.14.12010000.5 2009/07/21 14:32:21 anuragar ship $*/

  g_pkg_name                             CONSTANT VARCHAR2(30):= 'PA_TASKS_MAINT_PVT';
--begin add by rtarway for FP.M developement
  Invalid_Arg_Exc_WP Exception;
--End  add by rtarway for FP.M developement
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
  )
  IS
    l_api_name                           CONSTANT VARCHAR2(30)  := 'CREATE_TASK';
    l_api_version                        CONSTANT NUMBER        := 1.0;
    l_msg_count                          NUMBER;
    l_err_code                           NUMBER                 := 0;
    l_err_stack                          VARCHAR2(630);
    l_err_stage                          VARCHAR2(80); -- VARCHAR2(80)
    l_data                               VARCHAR2(250);
    l_msg_data                           VARCHAR2(250);
    l_msg_index_out                      NUMBER;

    l_delete_project_allowed             VARCHAR2(1);
    l_update_proj_num_allowed            VARCHAR2(1);
    l_update_proj_name_allowed           VARCHAR2(1);
    l_update_proj_desc_allowed           VARCHAR2(1);
    l_update_proj_dates_allowed          VARCHAR2(1);
    l_update_proj_status_allowed         VARCHAR2(1);
    l_update_proj_manager_allowed        VARCHAR2(1);
    l_update_proj_org_allowed            VARCHAR2(1);
    l_add_task_allowed                   VARCHAR2(1);
    l_delete_task_allowed                VARCHAR2(1);
    l_update_task_num_allowed            VARCHAR2(1);
    l_update_task_name_allowed           VARCHAR2(1);
    l_update_task_dates_allowed          VARCHAR2(1);
    l_update_task_desc_allowed           VARCHAR2(1);
    l_update_parent_task_allowed         VARCHAR2(1);
    l_update_task_org_allowed            VARCHAR2(1);
    l_f1                                 VARCHAR2(1);
    l_f2                                 VARCHAR2(1);
    l_ret                                VARCHAR2(1);
    l_msg_cnt                            NUMBER;

    l_rowid                              VARCHAR2(50);
    l_new_task_id                        NUMBER;
    l_parent_task_id                     NUMBER;
    l_top_task_id                        NUMBER;

    l_sequence_number                    NUMBER;

    -- For Task Attributes, for defaulting
    TDESCRIPTION                         VARCHAR2(250);
    TTASK_ID                             NUMBER;
    TTOP_TASK_ID                         NUMBER;
    TPARENT_TASK_ID                      NUMBER;
    TADDRESS_ID                          NUMBER;
    TREADY_TO_BILL_FLAG                  VARCHAR2(1);
    TREADY_TO_DISTRIBUTE_FLAG            VARCHAR2(1);
    TCARRYING_OUT_ORG_ID                 NUMBER;
    TSERVICE_TYPE_CODE                   VARCHAR2(30);
    TTASK_MANAGER_PERSON_ID              NUMBER;
    TCHARGEABLE                          VARCHAR2(1);
    TBILLABLE                            VARCHAR2(1);
    TLIMIT_TO_TXN_CONTROLS_FLAG          VARCHAR2(1);
    TSTART_DATE                          DATE;
    TCOMPLETION_DATE                     DATE;
    TLABOR_BILL_RATE_ORG_ID              NUMBER;
    TLABOR_STD_BILL_RATE_SCHDL           VARCHAR2(30);
    TLABOR_SCHEDULE_FIXED_DATE           DATE;
    TLABOR_SCHEDULE_DISCOUNT             NUMBER;
    TNLR_BILL_RATE_ORG_ID                NUMBER;
    TNLR_STD_BILL_RATE_SCHDL             VARCHAR2(30);
    TNLR_SCHEDULE_FIXED_DATE             DATE;
    TNLR_SCHEDULE_DISCOUNT               NUMBER;
    TCOST_IND_RATE_SCH_ID                NUMBER;
    TREV_IND_RATE_SCH_ID                 NUMBER;
    TINV_IND_RATE_SCH_ID                 NUMBER;
    TCOST_IND_SCH_FIXED_DATE             DATE;
    TREV_IND_SCH_FIXED_DATE              DATE;
    TINV_IND_SCH_FIXED_DATE              DATE;
    TLABOR_SCH_TYPE                      VARCHAR2(1);
    TNLR_SCH_TYPE                        VARCHAR2(1);
    TALLOW_CROSS_CHARGE_FLAG             VARCHAR2(1);
    TPROJECT_RATE_TYPE                   VARCHAR2(30);
    TPROJECT_RATE_DATE                   DATE;
    TCC_PROCESS_LABOR_FLAG               VARCHAR2(1);
    TLABOR_TP_SCHEDULE_ID                NUMBER;
    TLABOR_TP_FIXED_DATE                 DATE;
    TCC_PROCESS_NL_FLAG                  VARCHAR2(1);
    TNL_TP_SCHEDULE_ID                   NUMBER;
    TNL_TP_FIXED_DATE                    DATE;
    TRECEIVE_PROJECT_INVOICE_FLAG        VARCHAR2(1);
    TWORK_TYPE_ID                        NUMBER;
    TJOB_BILL_RATE_SCHEDULE_ID           NUMBER;
    TEMP_BILL_RATE_SCHEDULE_ID           NUMBER;
    --NEW ATTRIBUTES
    TTASK_TYPE_CODE                      VARCHAR2(30);
    TPRIORITY_CODE                       VARCHAR2(30);
    TCRITICAL_FLAG                       VARCHAR2(1);
    TMILESTONE_FLAG                      VARCHAR2(1);
    TESTIMATED_START_DATE                DATE;
    TESTIMATED_END_DATE                  DATE;
    TBASELINE_START_DATE                 DATE;
    TBASELINE_END_DATE                   DATE;
    TOBLIGATION_START_DATE               DATE;
    TOBLIGATION_END_DATE                 DATE;
    TSCHEDULED_START_DATE                DATE;
    TSCHEDULED_FINISH_DATE               DATE;
    TESTIMATE_TO_COMPLETE_WORK           NUMBER;
    TBASELINE_WORK                       NUMBER;
    TSCHEDULED_WORK                      NUMBER;
    TACTUAL_WORK_TO_DATE                 NUMBER;
    TWORK_UNIT_CODE                      VARCHAR2(30);
    TPROGRESS_STATUS_CODE                VARCHAR2(30);
    TWBS_LEVEL                           NUMBER;

    TACTUAL_START_DATE                   DATE;
    TACTUAL_FINISH_DATE                  DATE;
    TPA_PARENT_TASK_ID                   NUMBER;
    TLABOR_COST_MULTIPLIER_NAME          VARCHAR2(20);
    TEARLY_START_DATE                    DATE;
    TEARLY_FINISH_DATE                   DATE;
    TLATE_START_DATE                     DATE;
    TLATE_FINISH_DATE                    DATE;
    TATTRIBUTE_CATEGORY                  VARCHAR2(30);
    TATTRIBUTE1                          VARCHAR2(150);
    TATTRIBUTE2                          VARCHAR2(150);
    TATTRIBUTE3                          VARCHAR2(150);
    TATTRIBUTE4                          VARCHAR2(150);
    TATTRIBUTE5                          VARCHAR2(150);
    TATTRIBUTE6                          VARCHAR2(150);
    TATTRIBUTE7                          VARCHAR2(150);
    TATTRIBUTE8                          VARCHAR2(150);
    TATTRIBUTE9                          VARCHAR2(150);
    TATTRIBUTE10                         VARCHAR2(150);

    TPROJECT_TYPE                        VARCHAR2(20);
    CARRYING_OUT_ORG_ID_TMP              NUMBER;
    Tinc_proj_progress_flag              VARCHAR2(1);
    ttaskfunc_cost_rate_type             VARCHAR2(30);
    ttaskfunc_cost_rate_date             DATE;
    tnon_lab_std_bill_rt_Sch_id          NUMBER;
    Tlabor_disc_reason_code              VARCHAR2(30);
    Tnon_labor_disc_reason_code          VARCHAR2(30);

--PA L Capital Project Changes 2872708
      tretirement_cost_flag              VARCHAR2(1);
      tcint_eligible_flag                VARCHAR2(1);
      tcint_stop_date                    DATE;
--End PA L Capital Project Changes 2872708

    TGEN_ETC_SOURCE_CODE                 VARCHAR2(30);
/*FPM development for Project Setup */
    l_customer_id                        Number;
    l_revenue_accrual_method             varchar2(30);
    l_invoice_method                     varchar2(30);
    l_project_type_class_code            varchar2(80);

    --cursor for getting reference task info; from FORMS task2.create_task
    --new columns added starting from task_type_code
    CURSOR ref_task IS
      SELECT TASK_ID,
        TOP_TASK_ID,
        PARENT_TASK_ID,
        ADDRESS_ID,
        'N', -- READY_TO_BILL_FLAG
        'N', -- READY_TO_DISTRIBUTE_FLAG
        CARRYING_OUT_ORGANIZATION_ID,
        SERVICE_TYPE_CODE,
        TASK_MANAGER_PERSON_ID,
        'Y', -- CHARGEABLE_FLAG
        BILLABLE_FLAG,
        'N', -- LIMIT_TO_TXN_CONTROLS_FLAG
        START_DATE,
        COMPLETION_DATE,
        LABOR_BILL_RATE_ORG_ID,
        LABOR_STD_BILL_RATE_SCHDL,
        LABOR_SCHEDULE_FIXED_DATE,
        LABOR_SCHEDULE_DISCOUNT,
        NON_LABOR_BILL_RATE_ORG_ID,
        NON_LABOR_STD_BILL_RATE_SCHDL,
        NON_LABOR_SCHEDULE_FIXED_DATE,
        NON_LABOR_SCHEDULE_DISCOUNT,
        COST_IND_RATE_SCH_ID,
        REV_IND_RATE_SCH_ID,
        INV_IND_RATE_SCH_ID,
        COST_IND_SCH_FIXED_DATE,
        REV_IND_SCH_FIXED_DATE,
        INV_IND_SCH_FIXED_DATE,
        LABOR_SCH_TYPE,
        NON_LABOR_SCH_TYPE,
        ALLOW_CROSS_CHARGE_FLAG,
        PROJECT_RATE_TYPE,
        PROJECT_RATE_DATE,
        CC_PROCESS_LABOR_FLAG,
        LABOR_TP_SCHEDULE_ID,
        LABOR_TP_FIXED_DATE,
        CC_PROCESS_NL_FLAG,
        NL_TP_SCHEDULE_ID,
        NL_TP_FIXED_DATE,
        'N', -- RECEIVE_PROJECT_INVOICE_FLAG
        WORK_TYPE_ID,
        JOB_BILL_RATE_SCHEDULE_ID,
        EMP_BILL_RATE_SCHEDULE_ID,
-- HY        TASK_TYPE_CODE,
-- HY        PRIORITY_CODE,
-- HY        CRITICAL_FLAG,
-- HY        MILESTONE_FLAG,
-- HY        ESTIMATED_START_DATE,
-- HY        ESTIMATED_END_DATE,
        SCHEDULED_START_DATE,
        SCHEDULED_FINISH_DATE,
-- HY        ESTIMATE_TO_COMPLETE_WORK,
-- HY        SCHEDULED_WORK,
-- HY        WORK_UNIT_CODE,
-- HY        PROGRESS_STATUS_CODE,
        WBS_LEVEL,
-- HY        inc_proj_progress_flag,
        taskfunc_cost_rate_type,
        taskfunc_cost_rate_date,
        non_lab_std_bill_rt_sch_id,
        labor_disc_reason_code,
        non_labor_disc_reason_code,
--PA L Capital Project changes 2872708
      retirement_cost_flag,
      cint_eligible_flag,
      cint_stop_date,
--End PA L Capital Project changes 2872708
      /*FPM development for Project Setup */
      customer_id,
      revenue_accrual_method,
      invoice_method,
      GEN_ETC_SOURCE_CODE
      FROM PA_TASKS
      WHERE TASK_ID = p_reference_task_id;

    -- cursor for defaulting peer task that is not a top task.
    CURSOR ref_parent_task IS
      SELECT T.TASK_ID,
        T.TOP_TASK_ID,
        T.PARENT_TASK_ID,
        T.ADDRESS_ID,
        'N',
        'N',
        T.CARRYING_OUT_ORGANIZATION_ID,
        T.SERVICE_TYPE_CODE,
        T.TASK_MANAGER_PERSON_ID,
        'Y', -- CHARGEABLE_FLAG
        T.BILLABLE_FLAG,
        'N', -- LIMIT_TO_TXN_CONTROLS_FLAG
        T.START_DATE,
        T.COMPLETION_DATE,
        T.LABOR_BILL_RATE_ORG_ID,
        T.LABOR_STD_BILL_RATE_SCHDL,
        T.LABOR_SCHEDULE_FIXED_DATE,
        T.LABOR_SCHEDULE_DISCOUNT,
        T.NON_LABOR_BILL_RATE_ORG_ID,
        T.NON_LABOR_STD_BILL_RATE_SCHDL,
        T.NON_LABOR_SCHEDULE_FIXED_DATE,
        T.NON_LABOR_SCHEDULE_DISCOUNT,
        T.COST_IND_RATE_SCH_ID,
        T.REV_IND_RATE_SCH_ID,
        T.INV_IND_RATE_SCH_ID,
        T.COST_IND_SCH_FIXED_DATE,
        T.REV_IND_SCH_FIXED_DATE,
        T.INV_IND_SCH_FIXED_DATE,
        T.LABOR_SCH_TYPE,
        T.NON_LABOR_SCH_TYPE,
        T.ALLOW_CROSS_CHARGE_FLAG,
        T.PROJECT_RATE_TYPE,
        T.PROJECT_RATE_DATE,
        T.CC_PROCESS_LABOR_FLAG,
        T.LABOR_TP_SCHEDULE_ID,
        T.LABOR_TP_FIXED_DATE,
        T.CC_PROCESS_NL_FLAG,
        T.NL_TP_SCHEDULE_ID,
        T.NL_TP_FIXED_DATE,
        'N', -- RECEIVE_PROJECT_INVOICE_FLAG
        T.WORK_TYPE_ID,
        T.JOB_BILL_RATE_SCHEDULE_ID,
        T.EMP_BILL_RATE_SCHEDULE_ID,
-- HY        T.TASK_TYPE_CODE,
-- HY        T.PRIORITY_CODE,
-- HY        T.CRITICAL_FLAG,
-- HY        T.MILESTONE_FLAG,
-- HY        T.ESTIMATED_START_DATE,
-- HY        T.ESTIMATED_END_DATE,
        T.SCHEDULED_START_DATE,
        T.SCHEDULED_FINISH_DATE,
-- HY        T.ESTIMATE_TO_COMPLETE_WORK,
-- HY        T.SCHEDULED_WORK,
-- HY        T.WORK_UNIT_CODE,
-- HY        T.PROGRESS_STATUS_CODE,
        T.WBS_LEVEL,
-- HY        T.inc_proj_progress_flag,
        T.taskfunc_cost_rate_type,
        T.taskfunc_cost_rate_date,
        T.non_lab_std_bill_rt_sch_id,
        T.labor_disc_reason_code,
        T.non_labor_disc_reason_code,
--bug 3032842
--PA L Capital Project changes 2872708
      retirement_cost_flag,
      cint_eligible_flag,
      cint_stop_date,
--End PA L Capital Project changes 2872708
--end bug 3032842
      /*FPM development for Project Setup */
      T.customer_id,
      T.revenue_accrual_method,
      T.invoice_method,
      T.GEN_ETC_SOURCE_CODE
      FROM PA_TASKS T
      WHERE T.TASK_ID =
      (SELECT T2.PARENT_TASK_ID
       FROM PA_TASKS T2
       WHERE T2.TASK_ID = p_reference_task_id);

    --Cursor for defaulting top task
    CURSOR top_task IS
      select
        NULL,
        NULL,
        NULL,
        NULL,
        'Y',
        'Y',
        pa.carrying_out_organization_id,
        pt.SERVICE_TYPE_CODE,--service_type_code,
        pt.project_type_class_code, -- Project Type class code
        NULL,
        'Y',
        'N',
        'N',
        pa.start_date,
        pa.completion_date,
        pa.labor_bill_rate_org_id,
        pa.labor_std_bill_rate_schdl,
        pa.labor_schedule_fixed_date,
        pa.labor_schedule_discount,
        pa.non_labor_bill_rate_org_id,
        pa.non_labor_std_bill_rate_schdl,
        pa.non_labor_schedule_fixed_date,
        pa.non_labor_schedule_discount,
        pa.cost_ind_rate_sch_id,
        pa.rev_ind_rate_sch_id,
        pa.inv_ind_rate_sch_id,
        pa.cost_ind_sch_fixed_date,
        pa.rev_ind_sch_fixed_date,
        pa.inv_ind_sch_fixed_date,
        pa.labor_sch_type,
        pa.non_labor_sch_type,
        pa.allow_cross_charge_flag,
        pa.project_rate_type,
        pa.project_rate_date,
        pa.cc_process_labor_flag,
        pa.labor_tp_schedule_id,
        pa.labor_tp_fixed_date,
        pa.cc_process_nl_flag,
        pa.nl_tp_schedule_id,
        nl_tp_fixed_date,
        'N',
        pa.work_type_id,
        pa.job_bill_rate_schedule_id,
        pa.emp_bill_rate_schedule_id,
        NULL,
        NULL,
        'N',
        'N',
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        NULL,
        1, --WBS_LEVEL
--bug 3032842
--PA L Capital Project changes 2872708
      'N',  --retirment_flag
      decode( template_flag, 'N', 'N', 'Y' ), --cint_eligible_flag
      /*FPM development for Project Setup */
      pa.revenue_accrual_method,
      pa.Invoice_method,
--End PA L Capital Project changes 2872708
      NULL,
--end bug 3032842
      pa.Non_lab_std_bill_rt_sch_id  -- Added for bug 4963525.
      FROM PA_PROJECTS_ALL pa,
      PA_PROJECT_TYPES_ALL pt
      WHERE pa.PROJECT_ID = p_project_id and
      pa.PROJECT_TYPE = pt.PROJECT_TYPE and
      pa.ORG_ID = pt.ORG_ID;--MOAC Changes: Bug 4363092 : removed nvl usage with org_id

    CURSOR work_type_from_proj IS
      SELECT WORK_TYPE_ID, PROJECT_TYPE, CARRYING_OUT_ORGANIZATION_ID
      FROM PA_PROJECTS_ALL
      WHERE PROJECT_ID = p_project_id;

/* Commented for bug#3512486
    CURSOR work_type_from_proj_type(v_project_type VARCHAR2) IS
      SELECT WORK_TYPE_ID
      FROM PA_PROJECT_TYPES
      WHERE PROJECT_TYPE = v_project_type; */

    /* Modified the cursor work_type_from_proj_type for bug#3512486 */
    --MOAC Changes: Bug 4363092 : removed nvl usage with org_id
    CURSOR work_type_from_proj_type(v_project_type VARCHAR2) IS
      SELECT PT.WORK_TYPE_ID
      FROM PA_PROJECT_TYPES_ALL PT, PA_PROJECTS_ALL PA
      WHERE PT.PROJECT_TYPE = v_project_type
      and PA.PROJECT_ID = p_project_id
      and PA.ORG_ID = PT.ORG_ID;


    CURSOR billable_flag_c(v_work_type_id NUMBER) IS
      SELECT BILLABLE_CAPITALIZABLE_FLAG
      FROM PA_WORK_TYPES_VL
      WHERE WORK_TYPE_ID = v_work_type_id;

/*  FPM Changes for Project Setup */
    CURSOR top_task_customer is
    SELECT customer_id from pa_project_customers
    where project_id=p_project_id
    and default_top_task_cust_flag ='Y';
    --rtarway, BUG 3924597
    l_wp_separate_from_fin VARCHAR2(1);

  BEGIN
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASKS_MAINT_PVT.CREATE_TASK BEGIN');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint CREATE_TASK_PRIVATE;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Performing validations');
    END IF;

    IF (p_calling_module IN ('EXCHANGE')) THEN
      --check if task reference is null
      IF p_reference_task_id IS NULL THEN
        PA_UTILS.ADD_MESSAGE('PA', 'PA_TASK_REF_EMPTY');
      END IF;
    END IF;

    IF (p_calling_module IN ('FORMS', 'EXCHANGE', 'SELF_SERVICE')) THEN
      --check if task_name is null
      IF p_task_name IS NULL THEN
        PA_UTILS.ADD_MESSAGE('PA', 'PA_TASK_NAME_EMPTY');
      END IF;
    END IF;

    -- Set controls
    IF (p_calling_module IN ('SELF_SERVICE')) THEN
      If (p_pm_product_code IS NOT NULL) OR
         (p_pm_product_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
        PA_PM_CONTROLS.GET_PROJECT_ACTIONS_ALLOWED(
          p_pm_product_code => p_pm_product_code,
          p_delete_project_allowed => l_delete_project_allowed,
          p_update_proj_num_allowed => l_update_proj_num_allowed,
          p_update_proj_name_allowed => l_update_proj_name_allowed,
          p_update_proj_desc_allowed => l_update_proj_desc_allowed,
          p_update_proj_dates_allowed  => l_update_proj_dates_allowed,
          p_update_proj_status_allowed => l_update_proj_status_allowed,
          p_update_proj_manager_allowed => l_update_proj_manager_allowed,
          p_update_proj_org_allowed => l_update_proj_org_allowed,
          p_add_task_allowed => l_add_task_allowed,
          p_delete_task_allowed => l_delete_task_allowed,
          p_update_task_num_allowed => l_update_task_num_allowed,
          p_update_task_name_allowed => l_update_task_name_allowed,
          p_update_task_dates_allowed => l_update_task_dates_allowed,
          p_update_task_desc_allowed => l_update_task_desc_allowed,
          p_update_parent_task_allowed => l_update_parent_task_allowed,
          p_update_task_org_allowed => l_update_task_org_allowed,
          p_error_code => l_err_code,
          p_error_stack => l_err_stack,
          p_error_stage => l_err_stage
        );
      END IF; --product code is not null
    END IF;

    -- Check if pm_product code is not null and add_task_allowed = 'N'
    -- From Task Summary, when-button-pressed
    -- For Self-service, Exchange, Form
    IF ((p_pm_product_code IS NOT NULL) OR
       (p_pm_product_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR)) and
       (l_add_task_allowed = 'N') THEN
      --throw error PA_PR_PM_CANNOT_ADDTASK
      PA_UTILS.ADD_MESSAGE('PA', 'PA_PR_PM_CANNOT_ADDTASK');
      l_msg_count := FND_MSG_PUB.count_msg;
      IF (l_msg_count > 0) THEN
        x_msg_count := l_msg_count;
        IF (x_msg_count = 1) THEN
          pa_interface_utils_pub.get_messages(
            p_encoded => FND_API.G_TRUE,
            p_msg_index => 1,
            p_data => l_data,
            p_msg_index_out => l_msg_index_out);
          x_msg_data := l_data;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
    END IF;


    -- Check if task number is Unique
    IF (p_calling_module IN ('FORMS', 'SELF_SERVICE')) THEN
      If Pa_Task_Utils.Check_Unique_Task_number (p_project_id,
           p_task_number, NULL ) <> 1 Then
        PA_UTILS.ADD_MESSAGE('PA', 'PA_ALL_DUPLICATE_NUM');
      END IF;
    END IF;

    -- Check Start Date; will replace by Date roll-up in future
    -- Check Completion Date; will replace by Date roll-up in future
    IF (p_calling_module IN ('FORMS', 'EXCHANGE', 'SELF_SERVICE')) THEN
      --Check Start Date End Date
      IF (p_task_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR
          p_task_start_date IS NULL) AND
         (p_task_completion_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR
          p_task_completion_date IS NULL) THEN
        PA_TASKS_MAINT_UTILS.check_start_end_date(
          p_old_start_date => null,
          p_old_end_date => null,
          p_new_start_date => p_task_start_date,
          p_new_end_date => p_task_completion_date,
          p_update_start_date_flag => l_f1,
          p_update_end_date_flag => l_f2,
          p_return_status => l_ret);
        IF (l_ret <> 'S') THEN
          PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                               p_msg_name => 'PA_SU_INVALID_DATES');
        END IF;
      END IF;
    END IF;

    IF (p_calling_module IN ('SELF_SERVICE')) THEN
      -- Check if PRM is installed
      IF (PA_INSTALL.IS_PRM_LICENSED() = 'Y') THEN
        -- Work Type is required
        IF (p_work_type_id IS NULL) THEN
          PA_UTILS.ADD_MESSAGE('PA','PA_WORK_TYPE_REQ');
        END IF;
      END IF;
      null;
    END IF;

    -- Check if there is any error. Get new Task Id if no error
    l_msg_count := FND_MSG_PUB.count_msg;
    IF (l_msg_count > 0) THEN
      x_msg_count := l_msg_count;
      IF (x_msg_count = 1) THEN
        pa_interface_utils_pub.get_messages(
          p_encoded => FND_API.G_TRUE,
          p_msg_index => 1,
          p_data => l_data,
          p_msg_index_out => l_msg_index_out);
        x_msg_data := l_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Get Task Id
   --Commented the following line and replaced with new one.
   -- IF (p_calling_module IN ('FORMS', 'EXCHANGE', 'SELF_SERVICE')) THEN
    IF p_task_id IS NULL THEN  --Added by Ansari
      select PA_TASKS_S.NEXTVAL INTO l_new_task_id from sys.dual;
    ELSE  --Added by Ansari
      l_new_task_id := p_task_id;
    END IF;

    -- Check if this is a Subtask or a Peer task
--HSIU, modified for structures
    IF (p_peer_or_sub = 'SUB') AND
       (p_reference_task_id IS NOT NULL OR p_reference_task_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN

      -- Add as subtask

      -- Check create subtask ok
      IF (p_calling_module IN ('FORMS', 'SELF_SERVICE')) THEN
       --Call PA_TASK_UTILS.CHECK_CREATE_SUBTASK_OK
        PA_TASK_UTILS.CHECK_CREATE_SUBTASK_OK(x_task_id => p_reference_task_id,
          x_err_code => l_err_code,
          x_err_stack => l_err_stack,
          x_err_stage => l_err_stage
          );
        IF (l_err_code <> 0) THEN
          PA_UTILS.ADD_MESSAGE('PA', substr(l_err_stage,1,30));
        END IF;
      END IF;

      -- Copy parent task attributes to task.
      IF (p_calling_module IN ('FORMS', 'SELF_SERVICE')) THEN
        --Select attributes from parent task (cursor)
        OPEN ref_task;
        FETCH ref_task INTO
          TTASK_ID,
          TTOP_TASK_ID,
          TPARENT_TASK_ID,
          TADDRESS_ID,
          TREADY_TO_BILL_FLAG,
          TREADY_TO_DISTRIBUTE_FLAG,
          TCARRYING_OUT_ORG_ID,
          TSERVICE_TYPE_CODE,
          TTASK_MANAGER_PERSON_ID,
          TCHARGEABLE,
          TBILLABLE,
          TLIMIT_TO_TXN_CONTROLS_FLAG,
          TSTART_DATE,
          TCOMPLETION_DATE,
          TLABOR_BILL_RATE_ORG_ID,
          TLABOR_STD_BILL_RATE_SCHDL,
          TLABOR_SCHEDULE_FIXED_DATE,
          TLABOR_SCHEDULE_DISCOUNT,
          TNLR_BILL_RATE_ORG_ID,
          TNLR_STD_BILL_RATE_SCHDL,
          TNLR_SCHEDULE_FIXED_DATE,
          TNLR_SCHEDULE_DISCOUNT,
          TCOST_IND_RATE_SCH_ID,
          TREV_IND_RATE_SCH_ID,
          TINV_IND_RATE_SCH_ID,
          TCOST_IND_SCH_FIXED_DATE,
          TREV_IND_SCH_FIXED_DATE,
          TINV_IND_SCH_FIXED_DATE,
          TLABOR_SCH_TYPE,
          TNLR_SCH_TYPE,
          TALLOW_CROSS_CHARGE_FLAG,
          TPROJECT_RATE_TYPE,
          TPROJECT_RATE_DATE,
          TCC_PROCESS_LABOR_FLAG,
          TLABOR_TP_SCHEDULE_ID,
          TLABOR_TP_FIXED_DATE,
          TCC_PROCESS_NL_FLAG,
          TNL_TP_SCHEDULE_ID,
          TNL_TP_FIXED_DATE,
          TRECEIVE_PROJECT_INVOICE_FLAG,
          TWORK_TYPE_ID,
          TJOB_BILL_RATE_SCHEDULE_ID,
          TEMP_BILL_RATE_SCHEDULE_ID,
-- HY          TTASK_TYPE_CODE,
-- HY          TPRIORITY_CODE,
-- HY          TCRITICAL_FLAG,
-- HY          TMILESTONE_FLAG,
-- HY          TESTIMATED_START_DATE,
-- HY          TESTIMATED_END_DATE,
          TSCHEDULED_START_DATE,
          TSCHEDULED_FINISH_DATE,
-- HY          TESTIMATE_TO_COMPLETE_WORK,
-- HY          TSCHEDULED_WORK,
-- HY          TWORK_UNIT_CODE,
-- HY          TPROGRESS_STATUS_CODE,
          TWBS_LEVEL,
-- HY          Tinc_proj_progress_flag,
          Ttaskfunc_cost_rate_type,
          Ttaskfunc_cost_rate_date,
          Tnon_lab_std_bill_rt_Sch_id,
          Tlabor_disc_reason_code,
          Tnon_labor_disc_reason_code,
--PA L Capital Project changes 2872708
      tretirement_cost_flag,
      tcint_eligible_flag,
      tcint_stop_date,
--End PA L Capital Project changes 2872708
      /*FPM development for Project Setup */
      l_customer_id,
      l_revenue_accrual_method,
      l_invoice_method,
      TGEN_ETC_SOURCE_CODE;

        -- IF ref_task%NOTFOUND THEN
          --This should not occur
        -- END IF;
        CLOSE ref_task;

        -- Setting parent and top task id
        l_parent_task_id := TTASK_ID;
        l_top_task_id := TTOP_TASK_ID;
        TWBS_LEVEL := TWBS_LEVEL + 1;
      END IF;

--    ELSIF (p_peer_or_sub = 'PEER') THEN
-- HSIU, for creating the first task in a structure since
--  p_peer_or_sub is 'SUB' if reference is structure
    ELSE
      -- Add as peer task
      -- Insert Peer task
      OPEN ref_parent_task;
      FETCH ref_parent_task INTO
        TTASK_ID
       ,TTOP_TASK_ID
       ,TPARENT_TASK_ID
       ,TADDRESS_ID
       ,TREADY_TO_BILL_FLAG
       ,TREADY_TO_DISTRIBUTE_FLAG
       ,TCARRYING_OUT_ORG_ID
       ,TSERVICE_TYPE_CODE
       ,TTASK_MANAGER_PERSON_ID
       ,TCHARGEABLE
       ,TBILLABLE
       ,TLIMIT_TO_TXN_CONTROLS_FLAG
       ,TSTART_DATE
       ,TCOMPLETION_DATE
       ,TLABOR_BILL_RATE_ORG_ID
       ,TLABOR_STD_BILL_RATE_SCHDL
       ,TLABOR_SCHEDULE_FIXED_DATE
       ,TLABOR_SCHEDULE_DISCOUNT
       ,TNLR_BILL_RATE_ORG_ID
       ,TNLR_STD_BILL_RATE_SCHDL
       ,TNLR_SCHEDULE_FIXED_DATE
       ,TNLR_SCHEDULE_DISCOUNT
       ,TCOST_IND_RATE_SCH_ID
       ,TREV_IND_RATE_SCH_ID
       ,TINV_IND_RATE_SCH_ID
       ,TCOST_IND_SCH_FIXED_DATE
       ,TREV_IND_SCH_FIXED_DATE
       ,TINV_IND_SCH_FIXED_DATE
       ,TLABOR_SCH_TYPE
       ,TNLR_SCH_TYPE
       ,TALLOW_CROSS_CHARGE_FLAG
       ,TPROJECT_RATE_TYPE
       ,TPROJECT_RATE_DATE
       ,TCC_PROCESS_LABOR_FLAG
       ,TLABOR_TP_SCHEDULE_ID
       ,TLABOR_TP_FIXED_DATE
       ,TCC_PROCESS_NL_FLAG
       ,TNL_TP_SCHEDULE_ID
       ,TNL_TP_FIXED_DATE
       ,TRECEIVE_PROJECT_INVOICE_FLAG
       ,TWORK_TYPE_ID
       ,TJOB_BILL_RATE_SCHEDULE_ID
       ,TEMP_BILL_RATE_SCHEDULE_ID
-- HY       ,TTASK_TYPE_CODE
-- HY       ,TPRIORITY_CODE
-- HY       ,TCRITICAL_FLAG
-- HY       ,TMILESTONE_FLAG
-- HY       ,TESTIMATED_START_DATE
-- HY       ,TESTIMATED_END_DATE
       ,TSCHEDULED_START_DATE
       ,TSCHEDULED_FINISH_DATE
-- HY       ,TESTIMATE_TO_COMPLETE_WORK
-- HY       ,TSCHEDULED_WORK
-- HY       ,TWORK_UNIT_CODE
-- HY       ,TPROGRESS_STATUS_CODE
       ,TWBS_LEVEL
-- HY       ,Tinc_proj_progress_flag
       ,Ttaskfunc_cost_rate_type
       ,Ttaskfunc_cost_rate_date
       ,Tnon_lab_std_bill_rt_Sch_id
       ,Tlabor_disc_reason_code
       ,Tnon_labor_disc_reason_code
--bug 3032842
--PA L Capital Project changes 2872708
      ,tretirement_cost_flag
      ,tcint_eligible_flag
      ,tcint_stop_date
--End PA L Capital Project changes 2872708
--end bug 3032842
      /*FPM development for Project Setup */
      ,l_customer_id
      ,l_revenue_accrual_method
      ,l_invoice_method
       ,TGEN_ETC_SOURCE_CODE;
      IF (ref_parent_task%NOTFOUND) THEN
        --DEFAULT FROM PROJECT
        OPEN top_task;
        FETCH top_task INTO
          TTASK_ID
         ,TTOP_TASK_ID
         ,TPARENT_TASK_ID
         ,TADDRESS_ID
         ,TREADY_TO_BILL_FLAG
         ,TREADY_TO_DISTRIBUTE_FLAG
         ,TCARRYING_OUT_ORG_ID
         ,TSERVICE_TYPE_CODE
         ,l_project_type_class_code
         ,TTASK_MANAGER_PERSON_ID
         ,TCHARGEABLE
         ,TBILLABLE
         ,TLIMIT_TO_TXN_CONTROLS_FLAG
         ,TSTART_DATE
         ,TCOMPLETION_DATE
         ,TLABOR_BILL_RATE_ORG_ID
         ,TLABOR_STD_BILL_RATE_SCHDL
         ,TLABOR_SCHEDULE_FIXED_DATE
         ,TLABOR_SCHEDULE_DISCOUNT
         ,TNLR_BILL_RATE_ORG_ID
         ,TNLR_STD_BILL_RATE_SCHDL
         ,TNLR_SCHEDULE_FIXED_DATE
         ,TNLR_SCHEDULE_DISCOUNT
         ,TCOST_IND_RATE_SCH_ID
         ,TREV_IND_RATE_SCH_ID
         ,TINV_IND_RATE_SCH_ID
         ,TCOST_IND_SCH_FIXED_DATE
         ,TREV_IND_SCH_FIXED_DATE
         ,TINV_IND_SCH_FIXED_DATE
         ,TLABOR_SCH_TYPE
         ,TNLR_SCH_TYPE
         ,TALLOW_CROSS_CHARGE_FLAG
         ,TPROJECT_RATE_TYPE
         ,TPROJECT_RATE_DATE
         ,TCC_PROCESS_LABOR_FLAG
         ,TLABOR_TP_SCHEDULE_ID
         ,TLABOR_TP_FIXED_DATE
         ,TCC_PROCESS_NL_FLAG
         ,TNL_TP_SCHEDULE_ID
         ,TNL_TP_FIXED_DATE
         ,TRECEIVE_PROJECT_INVOICE_FLAG
         ,TWORK_TYPE_ID
         ,TJOB_BILL_RATE_SCHEDULE_ID
         ,TEMP_BILL_RATE_SCHEDULE_ID
         ,TTASK_TYPE_CODE
         ,TPRIORITY_CODE
         ,TCRITICAL_FLAG
         ,TMILESTONE_FLAG
         ,TESTIMATED_START_DATE
         ,TESTIMATED_END_DATE
         ,TSCHEDULED_START_DATE
         ,TSCHEDULED_FINISH_DATE
         ,TESTIMATE_TO_COMPLETE_WORK
         ,TSCHEDULED_WORK
         ,TWORK_UNIT_CODE
         ,TPROGRESS_STATUS_CODE
         ,TWBS_LEVEL
--bug 3032842
--PA L Capital Project changes 2872708
      ,tretirement_cost_flag
      ,tcint_eligible_flag
       /*FPM development for Project Setup */
      ,l_revenue_accrual_method
      ,l_invoice_method
--End PA L Capital Project changes 2872708
--end bug 3032842
         ,TGEN_ETC_SOURCE_CODE
	 ,Tnon_lab_std_bill_rt_Sch_id ;    -- Bug 4963525
        CLOSE top_task;

        TADDRESS_ID := PA_TASKS_MAINT_UTILS.DEFAULT_ADDRESS_ID(p_project_id);
        l_parent_task_id := NULL;
        l_top_task_id := l_new_task_id;
        /*FPM development for Project Setup */
        IF l_project_type_class_code ='CONTRACT' THEN
          open top_task_customer;
          Fetch top_task_customer into l_customer_id;
          close top_task_customer;

          TBILLABLE := 'Y'; --Bug 7524711

        END IF;

      ELSE
        -- Peer task found.
        l_parent_task_id := TTASK_ID;
        l_top_task_id := TTOP_TASK_ID;
        TWBS_LEVEL := TWBS_LEVEL + 1;
      END IF;
      CLOSE ref_parent_task;
    END IF;

l_msg_count := FND_MSG_PUB.count_msg;  --commented by ansari

    IF (p_calling_module IN ('FORMS', 'EXCHANGE', 'SELF_SERVICE')) THEN
      --Check Start Date
      IF (p_task_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
        PA_TASKS_MAINT_UTILS.Check_Start_Date(
          p_project_id => p_project_id,
          p_parent_task_id => l_parent_task_id,
          p_task_id => NULL,
          p_start_date => p_task_start_date,
          x_return_status => l_ret,
          x_msg_count => l_msg_cnt,
          x_msg_data => l_msg_data);
        IF (l_ret <> 'S') THEN
          PA_UTILS.ADD_MESSAGE('PA', l_msg_data);
        END IF;
      END IF;

l_msg_count := FND_MSG_PUB.count_msg;

      --Check Completion Date
      IF (p_task_completion_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
        PA_TASKS_MAINT_UTILS.Check_End_Date(
          p_project_id => p_project_id,
          p_parent_task_id => l_parent_task_id,
          p_task_id => NULL,
          p_end_date => p_task_completion_date,
          x_return_status => l_ret,
          x_msg_count => l_msg_cnt,
          x_msg_data => l_msg_data);
        IF (l_ret <> 'S') THEN
          PA_UTILS.ADD_MESSAGE('PA', l_msg_data);
        END IF;
      END IF;


l_msg_count := FND_MSG_PUB.count_msg;



      --Start Commenting  by rtarway for BUG 3927343
      -- These  checks are commented because schedule dates are not stored in pa_tasks.

      --Check Schedule Dates
      --IF (p_scheduled_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR
      --    p_scheduled_start_date IS NULL) AND
      --   (p_scheduled_finish_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR
      --    p_scheduled_finish_date IS NULL) THEN
      --  PA_TASKS_MAINT_UTILS.CHECK_SCHEDULE_DATES(
      --    p_project_id => p_project_id,
      --    p_sch_start_date => p_scheduled_start_date,
      --    p_sch_end_date => p_scheduled_finish_date,
      --    x_return_status => l_ret,
      --    x_msg_count => l_msg_cnt,
      --    x_msg_data => l_msg_data);
        --commented to suppress redundant messages appearing on
        --create task page
        /*IF (l_ret <> 'S') THEN
          PA_UTILS.ADD_MESSAGE('PA', l_msg_data);
        END IF;*/
     -- END IF;


--l_msg_count := FND_MSG_PUB.count_msg;

      --Check Estimate Dates
  --    IF (p_estimated_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR
    --      p_estimated_start_date IS NULL) AND
    --     (p_estimated_end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR
    --      p_estimated_end_date IS NULL) THEN
    --    PA_TASKS_MAINT_UTILS.CHECK_ESTIMATE_DATES(
    --      p_project_id => p_project_id,
    --      p_estimate_start_date => p_estimated_start_date,
    --      p_estimate_end_date => p_estimated_end_date,
    --     x_return_status => l_ret,
    --      x_msg_count => l_msg_cnt,
    --      x_msg_data => l_msg_data);
    --    IF (l_ret <> 'S') THEN
    --      PA_UTILS.ADD_MESSAGE('PA', l_msg_data);
    --    END IF;
    --  END IF;

--l_msg_count := FND_MSG_PUB.count_msg;

      --Check Actual Dates
  --    IF (p_actual_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR
      --    p_actual_start_date IS NULL) AND
    --     (p_actual_finish_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR
        --  p_actual_finish_date IS NULL) THEN
       -- PA_TASKS_MAINT_UTILS.CHECK_ACTUAL_DATES(
        --  p_project_id => p_project_id,
        --  p_actual_start_date => p_actual_start_date,
        --  p_actual_end_date => p_actual_finish_date,
        --  x_return_status => l_ret,
        --  x_msg_count => l_msg_cnt,
        --  x_msg_data => l_msg_data);
       -- IF (l_ret <> 'S') THEN
        --  PA_UTILS.ADD_MESSAGE('PA', l_msg_data);
       -- END IF;
      --END IF;
       --End Commenting  by rtarway for BUG 3927343

    END IF;

    l_msg_count := FND_MSG_PUB.count_msg;
    IF (l_msg_count > 0) THEN
      x_msg_count := l_msg_count;
      IF (x_msg_count = 1) THEN
        pa_interface_utils_pub.get_messages(
          p_encoded => FND_API.G_TRUE,
          p_msg_index => 1,
          p_data => l_data,
          p_msg_index_out => l_msg_index_out);
        x_msg_data := l_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;


    IF (p_calling_module IN ('FORMS', 'SELF_SERVICE')) THEN

      -- If Work Type Id is Null, then default from Project
      IF TWORK_TYPE_ID IS NULL THEN
        OPEN work_type_from_proj;
        FETCH work_type_from_proj INTO TWORK_TYPE_ID, TPROJECT_TYPE, CARRYING_OUT_ORG_ID_TMP;
        IF TWORK_TYPE_ID IS NULL THEN
          OPEN work_type_from_proj_type(TPROJECT_TYPE);
          FETCH work_type_from_proj_type INTO TWORK_TYPE_ID;
          CLOSE work_type_from_proj_type;
        END IF;
        CLOSE work_type_from_proj;
      END IF;

      -- Set Billable Flag base on work type
      IF TWORK_TYPE_ID IS NOT NULL THEN
        OPEN billable_flag_c(TWORK_TYPE_ID);
        FETCH billable_flag_c INTO TBILLABLE;
        CLOSE billable_flag_c;
      END IF;

    END IF;


    -- Replacing with user-entered values
    IF (p_task_manager_person_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      TTASK_MANAGER_PERSON_ID := p_task_manager_person_id;
    END IF;

    IF (p_carrying_out_organization_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      TCARRYING_OUT_ORG_ID := p_carrying_out_organization_id;
    END IF;
    -- If Organization Id is Null, then default from Project
    IF (TCARRYING_OUT_ORG_ID IS NULL) THEN
      TCARRYING_OUT_ORG_ID := CARRYING_OUT_ORG_ID_TMP; -- From Project
    END IF;

    IF (p_task_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TTASK_TYPE_CODE := p_task_type_code;
    END IF;

    IF (p_priority_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TPRIORITY_CODE := p_priority_code;
    END IF;

    IF (p_work_type_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      TWORK_TYPE_ID := p_work_type_id;
    END IF;

    IF (p_service_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TSERVICE_TYPE_CODE := p_service_type_code;
    END IF;

    IF (p_milestone_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TMILESTONE_FLAG := p_milestone_flag;
    END IF;

    IF (p_critical_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TCRITICAL_FLAG := p_critical_flag;
    END IF;

    IF (p_chargeable_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TCHARGEABLE := p_chargeable_flag;
    END IF;

    IF (p_billable_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TBILLABLE := p_billable_flag;
    END IF;

    -- Check Allow Charges
    --Chargeable flag, receive project invoice flag validation
    IF (p_receive_project_invoice_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      PA_TASKS_MAINT_UTILS.Check_Chargeable_Flag( p_chargeable_flag => TCHARGEABLE,
                       p_receive_project_invoice_flag => p_receive_project_invoice_flag,
                       p_project_type => TPROJECT_TYPE,
               p_project_id   => p_project_id, -- Added for bug#3512486
                       x_receive_project_invoice_flag => TRECEIVE_PROJECT_INVOICE_FLAG);
--      TRECEIVE_PROJECT_INVOICE_FLAG := p_receive_project_invoice_flag;
    END IF;

    IF (p_scheduled_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
      TSCHEDULED_START_DATE := p_scheduled_start_date;
    END IF;

    IF (p_scheduled_finish_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
      TSCHEDULED_FINISH_DATE := p_scheduled_finish_date;
    END IF;

    IF (p_estimated_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
      TESTIMATED_START_DATE := p_estimated_start_date;
    ELSE
      -- Default from schedule
      TESTIMATED_START_DATE := TSCHEDULED_START_DATE;
    END IF;

    IF (p_estimated_end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
      TESTIMATED_END_DATE := p_estimated_end_date;
    ELSE
      -- Default from schedule
      TESTIMATED_END_DATE := TSCHEDULED_FINISH_DATE;
    END IF;


    IF (p_actual_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
      TACTUAL_START_DATE := p_actual_start_date;
    END IF;

    IF (p_actual_finish_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
      TACTUAL_FINISH_DATE := p_actual_finish_date;
    END IF;


    IF (p_task_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
      TSTART_DATE := p_task_start_date;
--    ELSE
      -- Default from schedule
--      TSTART_DATE := TSCHEDULED_START_DATE;
    END IF;

    IF (p_task_completion_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
      TCOMPLETION_DATE := p_task_completion_date;
--    ELSE
      -- Default from schedule
--      TCOMPLETION_DATE := TSCHEDULED_FINISH_DATE;
    END IF;

    IF (p_baseline_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
      TBASELINE_START_DATE := p_baseline_start_date;
    END IF;

    IF (p_baseline_end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
      TBASELINE_END_DATE := p_baseline_end_date;
    END IF;


    IF (p_obligation_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
      TOBLIGATION_START_DATE := p_obligation_start_date;
    END IF;

    IF (p_obligation_end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
      TOBLIGATION_END_DATE := p_obligation_end_date;
    END IF;

    IF (p_estimate_to_complete_work <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      TESTIMATE_TO_COMPLETE_WORK := p_estimate_to_complete_work;
    END IF;

    IF (p_baseline_work <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      TBASELINE_WORK := p_baseline_work;
    END IF;

    IF (p_scheduled_work <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      TSCHEDULED_WORK := p_scheduled_work;
    END IF;

    IF (p_actual_work_to_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      TACTUAL_WORK_TO_DATE := p_actual_work_to_date;
    END IF;

    IF (p_work_unit <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TWORK_UNIT_CODE := p_work_unit;
    END IF;

    IF (p_progress_status_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TPROGRESS_STATUS_CODE := p_progress_status_code;
    END IF;

    IF (p_job_bill_rate_schedule_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      TJOB_BILL_RATE_SCHEDULE_ID := p_job_bill_rate_schedule_id;
    END IF;

    IF (p_emp_bill_rate_schedule_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      TEMP_BILL_RATE_SCHEDULE_ID := p_emp_bill_rate_schedule_id;
    END IF;

    IF (p_pa_parent_task_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      TPA_PARENT_TASK_ID := p_pa_parent_task_id;
    END IF;

    IF (p_address_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      TADDRESS_ID := p_address_id;
    END IF;

    IF (p_ready_to_bill_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TREADY_TO_BILL_FLAG := p_ready_to_bill_flag;
    END IF;

    IF (p_ready_to_distribute_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TREADY_TO_DISTRIBUTE_FLAG := p_ready_to_distribute_flag;
    END IF;

    IF (p_limit_to_txn_controls_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TLIMIT_TO_TXN_CONTROLS_FLAG := p_limit_to_txn_controls_flag;
    END IF;

    IF (p_labor_bill_rate_org_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      TLABOR_BILL_RATE_ORG_ID := p_labor_bill_rate_org_id;
    END IF;

    IF (p_labor_std_bill_rate_schdl <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TLABOR_STD_BILL_RATE_SCHDL := p_labor_std_bill_rate_schdl;
    END IF;

    IF (p_labor_schedule_fixed_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
      TLABOR_SCHEDULE_FIXED_DATE := p_labor_schedule_fixed_date;
    END IF;

    IF (p_labor_schedule_discount <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      TLABOR_SCHEDULE_DISCOUNT := p_labor_schedule_discount;
    END IF;

    IF (p_nl_bill_rate_org_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      TNLR_BILL_RATE_ORG_ID := p_nl_bill_rate_org_id;
    END IF;

    IF (p_nl_std_bill_rate_schdl <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TNLR_STD_BILL_RATE_SCHDL := p_nl_std_bill_rate_schdl;
    END IF;

    IF (p_nl_schedule_fixed_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
      TNLR_SCHEDULE_FIXED_DATE := p_nl_schedule_fixed_date;
    END IF;

    IF (p_nl_schedule_discount <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      TNLR_SCHEDULE_DISCOUNT := p_nl_schedule_discount;
    END IF;

    IF (p_labor_cost_multiplier_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TLABOR_COST_MULTIPLIER_NAME := p_labor_cost_multiplier_name;
    END IF;

    IF (p_cost_ind_rate_sch_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      TCOST_IND_RATE_SCH_ID := p_cost_ind_rate_sch_id;
    END IF;

    IF (p_rev_ind_rate_sch_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      TREV_IND_RATE_SCH_ID := p_rev_ind_rate_sch_id;
    END IF;

    IF (p_inv_ind_rate_sch_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      TINV_IND_RATE_SCH_ID := p_inv_ind_rate_sch_id;
    END IF;

    IF (p_cost_ind_sch_fixed_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
      TCOST_IND_SCH_FIXED_DATE := p_cost_ind_sch_fixed_date;
    END IF;

    IF (p_rev_ind_sch_fixed_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
      TREV_IND_SCH_FIXED_DATE := p_rev_ind_sch_fixed_date;
    END IF;

    IF (p_inv_ind_sch_fixed_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
      TINV_IND_SCH_FIXED_DATE := p_inv_ind_sch_fixed_date;
    END IF;

    IF (p_labor_sch_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TLABOR_SCH_TYPE := p_labor_sch_type;
    END IF;

    IF (p_nl_sch_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TNLR_SCH_TYPE := p_nl_sch_type;
    END IF;

    IF (p_early_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
      TEARLY_START_DATE := p_early_start_date;
    END IF;

    IF (p_early_finish_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
      TEARLY_FINISH_DATE := p_early_finish_date;
    END IF;

    IF (p_late_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
      TLATE_START_DATE := p_late_start_date;
    END IF;

    IF (p_late_finish_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
      TLATE_FINISH_DATE := p_late_finish_date;
    END IF;

    IF (p_attribute_category <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TATTRIBUTE_CATEGORY := p_attribute_category;
    END IF;

    IF (p_attribute1 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TATTRIBUTE1 := p_attribute1;
    END IF;

    IF (p_attribute2 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TATTRIBUTE2 := p_attribute2;
    END IF;

    IF (p_attribute3 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TATTRIBUTE3 := p_attribute3;
    END IF;

    IF (p_attribute4 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TATTRIBUTE4 := p_attribute4;
    END IF;

    IF (p_attribute5 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TATTRIBUTE5 := p_attribute5;
    END IF;

    IF (p_attribute6 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TATTRIBUTE6 := p_attribute6;
    END IF;

    IF (p_attribute7 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TATTRIBUTE7 := p_attribute7;
    END IF;

    IF (p_attribute8 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TATTRIBUTE8 := p_attribute8;
    END IF;

    IF (p_attribute9 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TATTRIBUTE9 := p_attribute9;
    END IF;

    IF (p_attribute10 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TATTRIBUTE10 := p_attribute10;
    END IF;

    IF (p_allow_cross_charge_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TALLOW_CROSS_CHARGE_FLAG := p_allow_cross_charge_flag;
    END IF;

    IF (p_project_rate_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
      TPROJECT_RATE_DATE := p_project_rate_date;
    END IF;

    IF (p_project_rate_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TPROJECT_RATE_TYPE := p_project_rate_type;
    END IF;

    IF (p_cc_process_labor_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TCC_PROCESS_LABOR_FLAG := p_cc_process_labor_flag;
    END IF;

    IF (p_labor_tp_schedule_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      TLABOR_TP_SCHEDULE_ID := p_labor_tp_schedule_id;
    END IF;

    IF (p_labor_tp_fixed_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
      TLABOR_TP_FIXED_DATE := p_labor_tp_fixed_date;
    END IF;

    IF (p_cc_process_nl_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TCC_PROCESS_NL_FLAG := p_cc_process_nl_flag;
    END IF;

    IF (p_nl_tp_schedule_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
      TNL_TP_SCHEDULE_ID := p_nl_tp_schedule_id;
    END IF;

    IF (p_nl_tp_fixed_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
      TNL_TP_FIXED_DATE := p_nl_tp_fixed_date;
    END IF;

    IF (p_task_description <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      TDESCRIPTION := substrb( p_task_description, 1, 250); --Bug 4297289
    END IF;

    IF (p_inc_proj_progress_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      Tinc_proj_progress_flag := p_inc_proj_progress_flag;
    END IF;

    IF (p_taskfunc_cost_rate_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_taskfunc_cost_rate_type IS NULL ) THEN
       ttaskfunc_cost_rate_type:= p_taskfunc_cost_rate_type;
    END IF;

    IF (p_taskfunc_cost_rate_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_taskfunc_cost_rate_date IS NULL ) THEN
       ttaskfunc_cost_rate_date:= p_taskfunc_cost_rate_date;
    END IF;

    IF (p_non_lab_std_bill_rt_sch_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_non_lab_std_bill_rt_sch_id IS NULL ) THEN
       tnon_lab_std_bill_rt_sch_id:= p_non_lab_std_bill_rt_sch_id;
    END IF;

--  FP.K changes by msundare
    IF (p_labor_disc_reason_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
p_labor_disc_reason_code IS NULL ) THEN
       Tlabor_disc_reason_code:= p_labor_disc_reason_code;
    END IF;

    IF (p_non_labor_disc_reason_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
p_non_labor_disc_reason_code IS NULL ) THEN
       Tnon_labor_disc_reason_code:= p_non_labor_disc_reason_code;
    END IF;

--PA L Capital Project Changes 2872708
    IF (p_retirement_cost_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
        p_retirement_cost_flag IS NULL ) THEN
       tretirement_cost_flag:= p_retirement_cost_flag;
    END IF;

    IF (p_cint_eligible_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
        p_cint_eligible_flag IS NULL ) THEN
        tcint_eligible_flag:= p_cint_eligible_flag;
    END IF;

    IF (p_cint_stop_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR
        p_cint_stop_date IS NULL ) THEN
        tcint_stop_date:= p_cint_stop_date;
    END IF;

--End PA L Capital Project Changes 2872708

--added by rtarway for BUG 3924597, etc sorce defaulting.
 --1. get the structure_share_code
   l_wp_separate_from_fin := PA_PROJ_TASK_STRUC_PUB.IS_WP_SEPARATE_FROM_FN( p_project_id );
--end by rtarway for BUG 3924597
    -- Get Display Sequence


  IF p_reference_task_id IS NOT NULL          --Modified by Ansari. Added logic to create top task.
  THEN
    l_sequence_number := PA_TASKS_MAINT_UTILS.Get_Sequence_Number(p_peer_or_sub,
                               p_project_id,
                               p_reference_task_id);

    --added by rtarway for BUG 3924597, etc sorce defaulting.
    --if TGEN_ETC_SOURCE_CODE is null, i.e. not defaulted from top tasks , then we should default this value
      if ( TGEN_ETC_SOURCE_CODE  is null or TGEN_ETC_SOURCE_CODE = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) then
          if (p_calling_module = 'FORMS') then
               TGEN_ETC_SOURCE_CODE := 'FINANCIAL_PLAN';
          else
               if (nvl(l_wp_separate_from_fin,'N') = 'N') then
                    TGEN_ETC_SOURCE_CODE := 'WORKPLAN_RESOURCES';
               else
                    TGEN_ETC_SOURCE_CODE := 'FINANCIAL_PLAN';
               end if;
          end if;
      end if;
  ELSE
    --No reference task is passed . Its assumed top task.
    l_sequence_number := 1;
    --Added by rtarway for BUG 3924597, Default the ETC_SOURCE_CODE for top tasks
    if (p_calling_module = 'FORMS') then
     TGEN_ETC_SOURCE_CODE := 'FINANCIAL_PLAN';
    else
        if (nvl(l_wp_separate_from_fin,'N') = 'N') then
          TGEN_ETC_SOURCE_CODE := 'WORKPLAN_RESOURCES';
        else
          TGEN_ETC_SOURCE_CODE := 'FINANCIAL_PLAN';
        end if;
    end if;
  END IF;

  --Changes for 8566495 anuragag
--PA_TASK_PVT1.G_CHG_DOC_CNTXT will be 1 for task created via change management, so this call will be skipped
			 if(PA_TASK_PVT1.G_CHG_DOC_CNTXT = 0)
			 then
    -- Call Table Handler
    --Insert using table handler
    PA_TASKS_PKG.insert_row(
      l_rowid,
      l_new_task_id,
      p_project_id,
      p_task_number,
      sysdate,
      FND_GLOBAL.USER_ID, -- created_by
      sysdate,
      FND_GLOBAL.USER_ID, --  Last_Updated_By
      FND_GLOBAL.USER_ID, --  Last_Update_Login
      p_task_name,
      p_long_task_name,
      l_top_task_id,
      TWBS_LEVEL,
      TREADY_TO_BILL_FLAG,
      TREADY_TO_DISTRIBUTE_FLAG,
      l_parent_task_Id,
      TDESCRIPTION,
      TCARRYING_OUT_ORG_ID,
      TSERVICE_TYPE_CODE,
      p_task_manager_person_id,
      TCHARGEABLE,
      TBILLABLE,
      TLIMIT_TO_TXN_CONTROLS_FLAG,
      TSTART_DATE,
      TCOMPLETION_DATE,
      TADDRESS_ID,
      TLABOR_BILL_RATE_ORG_ID,
      TLABOR_STD_BILL_RATE_SCHDL,
      TLABOR_SCHEDULE_FIXED_DATE,
      TLABOR_SCHEDULE_DISCOUNT,
      TNLR_BILL_RATE_ORG_ID,
      TNLR_STD_BILL_RATE_SCHDL,
      TNLR_SCHEDULE_FIXED_DATE,
      TNLR_SCHEDULE_DISCOUNT,
      TLABOR_COST_MULTIPLIER_NAME, -- Labor_Cost_Multiplier_Name
      TATTRIBUTE_CATEGORY, -- Attribute_Category
      TATTRIBUTE1, -- Attribute1
      TATTRIBUTE2, -- Attribute2
      TATTRIBUTE3, -- Attribute3
      TATTRIBUTE4, -- Attribute4
      TATTRIBUTE5, -- Attribute5
      TATTRIBUTE6, -- Attribute6
      TATTRIBUTE7, -- Attribute7
      TATTRIBUTE8, -- Attribute8
      TATTRIBUTE9, -- Attribute9
      TATTRIBUTE10, -- Attribute10
      TCOST_IND_RATE_SCH_ID,
      TREV_IND_RATE_SCH_ID,
      TINV_IND_RATE_SCH_ID,
      TCOST_IND_SCH_FIXED_DATE,
      TREV_IND_SCH_FIXED_DATE,
      TINV_IND_SCH_FIXED_DATE,
      TLABOR_SCH_TYPE,
      TNLR_SCH_TYPE,
      TALLOW_CROSS_CHARGE_FLAG,
      TPROJECT_RATE_DATE,
      TPROJECT_RATE_TYPE,
      TCC_PROCESS_LABOR_FLAG,
      TLABOR_TP_SCHEDULE_ID,
      TLABOR_TP_FIXED_DATE,
      TCC_PROCESS_NL_FLAG,
      TNL_TP_SCHEDULE_ID,
      TNL_TP_FIXED_DATE,
      TRECEIVE_PROJECT_INVOICE_FLAG,
      TWORK_TYPE_ID,
      TJOB_BILL_RATE_SCHEDULE_ID,
      TEMP_BILL_RATE_SCHEDULE_ID,

      /*TTASK_TYPE_CODE,
      l_sequence_number, --DISPLAY SEQUENCE
      TPRIORITY_CODE,
      TCRITICAL_FLAG,
      TMILESTONE_FLAG,
      TSCHEDULED_START_DATE,
      TSCHEDULED_FINISH_DATE,
      TACTUAL_START_DATE, -- Actual Start Date
      TACTUAL_FINISH_DATE, -- Actual Finish Date
      TESTIMATED_START_DATE,
      TESTIMATED_END_DATE,
      TBASELINE_START_DATE,
      TBASELINE_END_DATE,
      TOBLIGATION_START_DATE,
      TOBLIGATION_END_DATE,
      TESTIMATE_TO_COMPLETE_WORK,
      TBASELINE_WORK,
      TSCHEDULED_WORK,
      TACTUAL_WORK_TO_DATE,
      TWORK_UNIT_CODE,
      TPROGRESS_STATUS_CODE,
      Tinc_proj_progress_flag,

      1, --Record version Number */
      ttaskfunc_cost_rate_type,
      ttaskfunc_cost_rate_date,
      tnon_lab_std_bill_rt_sch_id,
      Tlabor_disc_reason_code,
      Tnon_labor_disc_reason_code,
--PA L Capital Project Changes 2872708
      NVL( tretirement_cost_flag, 'N'),
      NVL( tcint_eligible_flag, 'N'),
      tcint_stop_date,
--End PA L Capital Project Changes 2872708

      /*FPM development for Project Setup */
      l_customer_id,
      l_revenue_accrual_method,
      l_invoice_method,
      TGEN_ETC_SOURCE_CODE
      );

    -- Date Roll-up


    -- Update parent task chargeable and receive project invoice flags
    --   if creating subtask
    IF (p_peer_or_sub = 'SUB') THEN
      IF (p_calling_module IN ('FORMS', 'SELF_SERVICE')) THEN
        -- Set parent task chargeable flag to 'N' and set
        -- Parent Task Receive_Project_Invoice_Flag to 'N'
        -- This should be performed after the task is added.
        UPDATE PA_TASKS
        SET
        CHARGEABLE_FLAG = 'N',
        RECEIVE_PROJECT_INVOICE_FLAG = 'N',
        RECORD_VERSION_NUMBER = nvl(RECORD_VERSION_NUMBER,0)+1,
        last_updated_by = FND_GLOBAL.USER_ID,
        last_update_login = FND_GLOBAL.USER_ID,
        last_update_date = sysdate
        WHERE TASK_ID = l_parent_task_Id;
      END IF;
    END IF;



    x_return_status := FND_API.G_RET_STS_SUCCESS;
    p_task_id := l_new_task_id;
    x_display_seq := l_sequence_number;

	end if; -- end check for chg_doc_cntxt
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to CREATE_TASK_PRIVATE;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to CREATE_TASK_PRIVATE;
      END IF;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_count := FND_MSG_PUB.count_msg;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_PVT',
                              p_procedure_name => 'CREATE_TASK',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
  END CREATE_TASK;

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
  )
  IS
    l_rowid                              VARCHAR2(50);

    l_api_name                           CONSTANT VARCHAR2(30)  := 'UPDATE_TASK';
    l_api_version                        CONSTANT NUMBER        := 1.0;
    l_msg_count                          NUMBER;
    l_err_code                           NUMBER                 := 0;
    l_err_stack                          VARCHAR2(630);
    l_err_stage                          VARCHAR2(80);
    l_data                               VARCHAR2(250);
    l_msg_data                           VARCHAR2(250);
    l_msg_index_out                      NUMBER;
    l_msg_cnt                            NUMBER;

    l_delete_project_allowed             VARCHAR2(1);
    l_update_proj_num_allowed            VARCHAR2(1);
    l_update_proj_name_allowed           VARCHAR2(1);
    l_update_proj_desc_allowed           VARCHAR2(1);
    l_update_proj_dates_allowed          VARCHAR2(1);
    l_update_proj_status_allowed         VARCHAR2(1);
    l_update_proj_manager_allowed        VARCHAR2(1);
    l_update_proj_org_allowed            VARCHAR2(1);
    l_add_task_allowed                   VARCHAR2(1);
    l_delete_task_allowed                VARCHAR2(1);
    l_update_task_num_allowed            VARCHAR2(1);
    l_update_task_name_allowed           VARCHAR2(1);
    l_update_task_dates_allowed          VARCHAR2(1);
    l_update_task_desc_allowed           VARCHAR2(1);
    l_update_parent_task_allowed         VARCHAR2(1);
    l_update_task_org_allowed            VARCHAR2(1);
    l_f1                                 VARCHAR2(1);
    l_f2                                 VARCHAR2(1);
    l_ret                                VARCHAR2(1);
    l_change_parent_flag                 VARCHAR2(1);

    t_pm_product_code                    PA_TASKS.PM_PRODUCT_CODE%TYPE;

    -- For Task Attributes, defaulting from parent task
    TTASK_ID                             NUMBER;
    TTASK_NAME                            PA_TASKS.TASK_NAME%TYPE;
    TLONG_TASK_NAME                       PA_TASKS.LONG_TASK_NAME%TYPE;
    TTASK_NUMBER                          PA_TASKS.TASK_NUMBER%TYPE;
    TDESCRIPTION                          PA_TASKS.DESCRIPTION%TYPE;
    TTOP_TASK_ID                         NUMBER;
    TPARENT_TASK_ID                      NUMBER;
    TADDRESS_ID                          NUMBER;
    TREADY_TO_BILL_FLAG                  VARCHAR2(1);
    TREADY_TO_DISTRIBUTE_FLAG            VARCHAR2(1);
    TCARRYING_OUT_ORG_ID                 NUMBER;
    TSERVICE_TYPE_CODE                   VARCHAR2(30);
    TTASK_MANAGER_PERSON_ID              NUMBER;
    TCHARGEABLE                          VARCHAR2(1);
    TBILLABLE                            VARCHAR2(1);
    TLIMIT_TO_TXN_CONTROLS_FLAG          VARCHAR2(1);
    TSTART_DATE                          DATE;
    TCOMPLETION_DATE                     DATE;
    TLABOR_BILL_RATE_ORG_ID              NUMBER;
    TLABOR_STD_BILL_RATE_SCHDL           VARCHAR2(30);
    TLABOR_SCHEDULE_FIXED_DATE           DATE;
    TLABOR_SCHEDULE_DISCOUNT             NUMBER;
    TNLR_BILL_RATE_ORG_ID                NUMBER;
    TNLR_STD_BILL_RATE_SCHDL             VARCHAR2(30);
    TNLR_SCHEDULE_FIXED_DATE             DATE;
    TNLR_SCHEDULE_DISCOUNT               NUMBER;
    TCOST_IND_RATE_SCH_ID                NUMBER;
    TREV_IND_RATE_SCH_ID                 NUMBER;
    TINV_IND_RATE_SCH_ID                 NUMBER;
    TCOST_IND_SCH_FIXED_DATE             DATE;
    TREV_IND_SCH_FIXED_DATE              DATE;
    TINV_IND_SCH_FIXED_DATE              DATE;
    TLABOR_SCH_TYPE                      VARCHAR2(1);
    TNLR_SCH_TYPE                        VARCHAR2(1);
    TALLOW_CROSS_CHARGE_FLAG             VARCHAR2(1);
    TPROJECT_RATE_TYPE                   VARCHAR2(30);
    TPROJECT_RATE_DATE                   DATE;
    TCC_PROCESS_LABOR_FLAG               VARCHAR2(1);
    TLABOR_TP_SCHEDULE_ID                NUMBER;
    TLABOR_TP_FIXED_DATE                 DATE;
    TCC_PROCESS_NL_FLAG                  VARCHAR2(1);
    TNL_TP_SCHEDULE_ID                   NUMBER;
    TNL_TP_FIXED_DATE                    DATE;
    TRECEIVE_PROJECT_INVOICE_FLAG        VARCHAR2(1);
    TWORK_TYPE_ID                        NUMBER;
    TJOB_BILL_RATE_SCHEDULE_ID           NUMBER;
    TEMP_BILL_RATE_SCHEDULE_ID           NUMBER;
    --NEW ATTRIBUTES
    TTASK_TYPE_CODE                      VARCHAR2(30);
    TPRIORITY_CODE                       VARCHAR2(30);
    TCRITICAL_FLAG                       VARCHAR2(1);
    TMILESTONE_FLAG                      VARCHAR2(1);
    TESTIMATED_START_DATE                DATE;
    TESTIMATED_END_DATE                  DATE;
    TBASELINE_START_DATE                 DATE;
    TBASELINE_END_DATE                   DATE;
    TOBLIGATION_START_DATE               DATE;
    TOBLIGATION_END_DATE                 DATE;
    TSCHEDULED_START_DATE                DATE;
    TSCHEDULED_FINISH_DATE               DATE;
    TESTIMATE_TO_COMPLETE_WORK           NUMBER;
    TBASELINE_WORK                       NUMBER;
    TSCHEDULED_WORK                      NUMBER;
    TACTUAL_WORK_TO_DATE                 NUMBER;
    TWORK_UNIT_CODE                      VARCHAR2(30);
    TPROGRESS_STATUS_CODE                VARCHAR2(30);
    TWBS_LEVEL                           NUMBER;

    TACTUAL_START_DATE                   DATE;
    TACTUAL_FINISH_DATE                  DATE;
    TLABOR_COST_MULTIPLIER_NAME          VARCHAR2(20);
    TEARLY_START_DATE                    DATE;
    TEARLY_FINISH_DATE                   DATE;
    TLATE_START_DATE                     DATE;
    TLATE_FINISH_DATE                    DATE;
    TATTRIBUTE_CATEGORY                  VARCHAR2(30);
    TATTRIBUTE1                          VARCHAR2(150);
    TATTRIBUTE2                          VARCHAR2(150);
    TATTRIBUTE3                          VARCHAR2(150);
    TATTRIBUTE4                          VARCHAR2(150);
    TATTRIBUTE5                          VARCHAR2(150);
    TATTRIBUTE6                          VARCHAR2(150);
    TATTRIBUTE7                          VARCHAR2(150);
    TATTRIBUTE8                          VARCHAR2(150);
    TATTRIBUTE9                          VARCHAR2(150);
    TATTRIBUTE10                         VARCHAR2(150);

    Tinc_proj_progress_flag              VARCHAR2(1);
    Tcomments                    VARCHAR2(4000);
    TDISPLAY_SEQUENCE                    NUMBER;

    TPROJECT_TYPE                        VARCHAR2(20);
    CARRYING_OUT_ORG_ID_TMP              NUMBER;
    ttaskfunc_cost_rate_type             VARCHAR2(30);
    ttaskfunc_cost_rate_date             DATE;
    tnon_lab_std_bill_rt_Sch_id          NUMBER;
    Tlabor_disc_reason_code              VARCHAR2(30);
    Tnon_labor_disc_reason_code          VARCHAR2(30);

--PA L Capital Project Changes 2872708
      tretirement_cost_flag              VARCHAR2(1);
      tcint_eligible_flag                VARCHAR2(1);
      tcint_stop_date                    DATE;
--End PA L Capital Project Changes 2872708

    TGEN_ETC_SOURCE_CODE                 VARCHAR2(30);

    CURSOR ref_task IS
      SELECT rowid,
        TASK_ID,
        TASK_NAME, --new
        LONG_TASK_NAME, --new
        TASK_NUMBER, --new
        DESCRIPTION, --new
        TOP_TASK_ID,
        PARENT_TASK_ID,
        ADDRESS_ID,
        READY_TO_BILL_FLAG,
        READY_TO_DISTRIBUTE_FLAG,
        CARRYING_OUT_ORGANIZATION_ID,
        SERVICE_TYPE_CODE,
        TASK_MANAGER_PERSON_ID,
        CHARGEABLE_FLAG,
        BILLABLE_FLAG,
        LIMIT_TO_TXN_CONTROLS_FLAG,
        START_DATE,
        COMPLETION_DATE,
        LABOR_BILL_RATE_ORG_ID,
        LABOR_STD_BILL_RATE_SCHDL,
        LABOR_SCHEDULE_FIXED_DATE,
        LABOR_SCHEDULE_DISCOUNT,
        NON_LABOR_BILL_RATE_ORG_ID,
        NON_LABOR_STD_BILL_RATE_SCHDL,
        NON_LABOR_SCHEDULE_FIXED_DATE,
        NON_LABOR_SCHEDULE_DISCOUNT,
        COST_IND_RATE_SCH_ID,
        REV_IND_RATE_SCH_ID,
        INV_IND_RATE_SCH_ID,
        COST_IND_SCH_FIXED_DATE,
        REV_IND_SCH_FIXED_DATE,
        INV_IND_SCH_FIXED_DATE,
        LABOR_SCH_TYPE,
        NON_LABOR_SCH_TYPE,
        ALLOW_CROSS_CHARGE_FLAG,
        PROJECT_RATE_TYPE,
        PROJECT_RATE_DATE,
        CC_PROCESS_LABOR_FLAG,
        LABOR_TP_SCHEDULE_ID,
        LABOR_TP_FIXED_DATE,
        CC_PROCESS_NL_FLAG,
        NL_TP_SCHEDULE_ID,
        NL_TP_FIXED_DATE,
        RECEIVE_PROJECT_INVOICE_FLAG,
        WORK_TYPE_ID,
        JOB_BILL_RATE_SCHEDULE_ID,
        EMP_BILL_RATE_SCHEDULE_ID,
-- HY        TASK_TYPE_CODE,
-- HY        PRIORITY_CODE,
-- HY        CRITICAL_FLAG,
-- HY        MILESTONE_FLAG,
-- HY        ESTIMATED_START_DATE,
-- HY        ESTIMATED_END_DATE,
        SCHEDULED_START_DATE,
        SCHEDULED_FINISH_DATE,
-- HY        ESTIMATE_TO_COMPLETE_WORK,
-- HY        SCHEDULED_WORK,
-- HY        WORK_UNIT_CODE,
-- HY        PROGRESS_STATUS_CODE,
        WBS_LEVEL,
        LABOR_COST_MULTIPLIER_NAME,
        ATTRIBUTE_CATEGORY,
        ATTRIBUTE1,
        ATTRIBUTE2,
        ATTRIBUTE3,
        ATTRIBUTE4,
        ATTRIBUTE5,
        ATTRIBUTE6,
        ATTRIBUTE7,
        ATTRIBUTE8,
        ATTRIBUTE9,
        ATTRIBUTE10,
-- HY        inc_proj_progress_flag,
-- HY        comments,
-- HY        DISPLAY_SEQUENCE
        taskfunc_cost_rate_type,
        taskfunc_cost_rate_date,
        non_lab_std_bill_rt_sch_id,
        labor_disc_reason_code,
        non_labor_disc_reason_code,
--PA L Capital Project changes 2872708
      retirement_cost_flag,
      cint_eligible_flag,
      cint_stop_date,
--End PA L Capital Project changes 2872708
      GEN_ETC_SOURCE_CODE
      FROM PA_TASKS
      WHERE TASK_ID = p_task_id;

  BEGIN

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASKS_MAINT_PVT.UPDATE_TASK BEGIN');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint UPDATE_TASK_PRIVATE;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Performing validations');
    END IF;

    IF (p_calling_module IN ('FORMS', 'EXCHANGE', 'SELF_SERVICE')) THEN
      --check if task_name is null
      IF p_task_name IS NULL THEN
        PA_UTILS.ADD_MESSAGE('PA', 'PA_TASK_NAME_EMPTY');
      END IF;
    END IF;

    -- Get PM_PRODUCT_CODE
    IF (p_pm_product_code = PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) THEN
      BEGIN
        select PM_PRODUCT_CODE
          into t_pm_product_code
          from pa_tasks
         where task_id = p_task_id;
      EXCEPTION
        WHEN NO_DATA_FOUND THEN
          PA_UTILS.ADD_MESSAGE('PA','PA_EXP_NO_TASK'); -- specified task does not exist
          raise FND_API.G_EXC_ERROR;
      END;
    ELSE
      t_pm_product_code := p_pm_product_code;
    END IF;

    --l_msg_count := FND_MSG_PUB.count_msg;


    -- Set controls
    IF (p_calling_module in ('SELF_SERVICE')) THEN
      If (t_pm_product_code IS NOT NULL) THEN
        PA_PM_CONTROLS.GET_PROJECT_ACTIONS_ALLOWED(
          p_pm_product_code => t_pm_product_code,
          p_delete_project_allowed => l_delete_project_allowed,
          p_update_proj_num_allowed => l_update_proj_num_allowed,
          p_update_proj_name_allowed => l_update_proj_name_allowed,
          p_update_proj_desc_allowed => l_update_proj_desc_allowed,
          p_update_proj_dates_allowed  => l_update_proj_dates_allowed,
          p_update_proj_status_allowed => l_update_proj_status_allowed,
          p_update_proj_manager_allowed => l_update_proj_manager_allowed,
          p_update_proj_org_allowed => l_update_proj_org_allowed,
          p_add_task_allowed => l_add_task_allowed,
          p_delete_task_allowed => l_delete_task_allowed,
          p_update_task_num_allowed => l_update_task_num_allowed,
          p_update_task_name_allowed => l_update_task_name_allowed,
          p_update_task_dates_allowed => l_update_task_dates_allowed,
          p_update_task_desc_allowed => l_update_task_desc_allowed,
          p_update_parent_task_allowed => l_update_parent_task_allowed,
          p_update_task_org_allowed => l_update_task_org_allowed,
          p_error_code => l_err_code,
          p_error_stack => l_err_stack,
          p_error_stage => l_err_stage
        );
      END IF; --product code is not null
    END IF;

--dbms_output.put_line( 'In update task 3' );

    --getting all information
    OPEN ref_task;
    FETCH ref_task INTO
     l_rowid
    ,TTASK_ID
    ,TTASK_NAME
    ,TLONG_TASK_NAME
    ,TTASK_NUMBER
    ,TDESCRIPTION
    ,TTOP_TASK_ID
    ,TPARENT_TASK_ID
    ,TADDRESS_ID
    ,TREADY_TO_BILL_FLAG
    ,TREADY_TO_DISTRIBUTE_FLAG
    ,TCARRYING_OUT_ORG_ID
    ,TSERVICE_TYPE_CODE
    ,TTASK_MANAGER_PERSON_ID
    ,TCHARGEABLE
    ,TBILLABLE
    ,TLIMIT_TO_TXN_CONTROLS_FLAG
    ,TSTART_DATE
    ,TCOMPLETION_DATE
    ,TLABOR_BILL_RATE_ORG_ID
    ,TLABOR_STD_BILL_RATE_SCHDL
    ,TLABOR_SCHEDULE_FIXED_DATE
    ,TLABOR_SCHEDULE_DISCOUNT
    ,TNLR_BILL_RATE_ORG_ID
    ,TNLR_STD_BILL_RATE_SCHDL
    ,TNLR_SCHEDULE_FIXED_DATE
    ,TNLR_SCHEDULE_DISCOUNT
    ,TCOST_IND_RATE_SCH_ID
    ,TREV_IND_RATE_SCH_ID
    ,TINV_IND_RATE_SCH_ID
    ,TCOST_IND_SCH_FIXED_DATE
    ,TREV_IND_SCH_FIXED_DATE
    ,TINV_IND_SCH_FIXED_DATE
    ,TLABOR_SCH_TYPE
    ,TNLR_SCH_TYPE
    ,TALLOW_CROSS_CHARGE_FLAG
    ,TPROJECT_RATE_TYPE
    ,TPROJECT_RATE_DATE
    ,TCC_PROCESS_LABOR_FLAG
    ,TLABOR_TP_SCHEDULE_ID
    ,TLABOR_TP_FIXED_DATE
    ,TCC_PROCESS_NL_FLAG
    ,TNL_TP_SCHEDULE_ID
    ,TNL_TP_FIXED_DATE
    ,TRECEIVE_PROJECT_INVOICE_FLAG
    ,TWORK_TYPE_ID
    ,TJOB_BILL_RATE_SCHEDULE_ID
    ,TEMP_BILL_RATE_SCHEDULE_ID
-- HY    ,TTASK_TYPE_CODE
-- HY    ,TPRIORITY_CODE
-- HY    ,TCRITICAL_FLAG
-- HY    ,TMILESTONE_FLAG
-- HY    ,TESTIMATED_START_DATE
-- HY    ,TESTIMATED_END_DATE
    ,TSCHEDULED_START_DATE
    ,TSCHEDULED_FINISH_DATE
-- HY    ,TESTIMATE_TO_COMPLETE_WORK
-- HY    ,TSCHEDULED_WORK
-- HY    ,TWORK_UNIT_CODE
-- HY    ,TPROGRESS_STATUS_CODE
    ,TWBS_LEVEL
    ,TLABOR_COST_MULTIPLIER_NAME
    ,TATTRIBUTE_CATEGORY
    ,TATTRIBUTE1
    ,TATTRIBUTE2
    ,TATTRIBUTE3
    ,TATTRIBUTE4
    ,TATTRIBUTE5
    ,TATTRIBUTE6
    ,TATTRIBUTE7
    ,TATTRIBUTE8
    ,TATTRIBUTE9
    ,TATTRIBUTE10
    ,ttaskfunc_cost_rate_type
    ,ttaskfunc_cost_rate_date
    ,tnon_lab_std_bill_rt_sch_id
    ,Tlabor_disc_reason_code
    ,Tnon_labor_disc_reason_code
--PA L Capital Project changes 2872708
     ,tretirement_cost_flag
     ,tcint_eligible_flag
     ,tcint_stop_date
--End PA L Capital Project changes 2872708
     ,tGEN_ETC_SOURCE_CODE
;
-- HY    ,Tinc_proj_progress_flag
-- HY    ,Tcomments
-- HY    ,TDISPLAY_SEQUENCE;

    IF (ref_task%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE ref_task;

--dbms_output.put_line( 'In update task 4 ');

    IF (p_calling_module IN ('FORMS', 'EXCHANGE', 'SELF_SERVICE')) THEN
      --Check if it is ok to change task number
      --IF (p_task_number <> TTASK_NUMBER) THEN          -- Commented for Bug#5968516
      IF (substrb(p_task_number, 0, 25) <> TTASK_NUMBER) -- Added substrb for Bug#5968516
      AND (p_task_number IS NOT NULL)  -- Bug 5968516
      AND (p_task_number <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR) -- Bug 5968516
      THEN
        PA_TASKS_MAINT_UTILS.CHECK_TASK_NUMBER_DISP(
          p_project_id,
          p_task_id,
          p_task_number,
          l_rowid);
      END IF;
    END IF;

--dbms_output.put_line( 'In update task 5' );

--Bug 6316383 :Changed the below condition for SELF SERVICE, as it is now handled in a different manner.
    --IF (p_calling_module IN ('FORMS', 'SELF_SERVICE')) THEN
      --If Carrying Out Organization has changed
      IF (p_calling_module  = 'FORMS') THEN
      IF (TCARRYING_OUT_ORG_ID <> p_carrying_out_organization_id) AND
         (p_carrying_out_organization_id IS NOT NULL) AND
         (p_carrying_out_organization_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
        PA_TASK_UTILS.CHANGE_TASK_ORG_OK(p_task_id,
                           l_err_code,
                           l_err_stage,
                           l_err_stack);
        IF (l_err_code <> 0) Then
          PA_UTILS.ADD_MESSAGE('PA', substr(l_err_stage,1,30));
        End If;
      END IF;
    END IF;

--dbms_output.put_line( 'In update task 6' );

    -- Check Start Date; will replace by Date roll-up in future
    -- Check Completion Date; will replace by Date roll-up in future
    IF (p_calling_module IN ('FORMS', 'EXCHANGE', 'SELF_SERVICE')) THEN
      --Check Start Date End Date
      IF (p_task_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR
          p_task_start_date IS NULL) AND
         (p_task_completion_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR
          p_task_completion_date IS NULL) THEN
        PA_TASKS_MAINT_UTILS.check_start_end_date(
          p_old_start_date => null,
          p_old_end_date => null,
          p_new_start_date => p_task_start_date,
          p_new_end_date => p_task_completion_date,
          p_update_start_date_flag => l_f1,
          p_update_end_date_flag => l_f2,
          p_return_status => l_ret);
        IF (l_ret <> 'S') THEN
          -- Bug 7386335
	  -- The API check_start_end_date will log a single error message. Not required to log further.
	  l_msg_count := FND_MSG_PUB.count_msg;
 	  IF (l_msg_count > 0) THEN
 	    x_msg_count := l_msg_count;
 	    IF (x_msg_count = 1) THEN
 	      pa_interface_utils_pub.get_messages(
 			p_encoded => FND_API.G_TRUE,
 			p_msg_index => 1,
 			p_data => l_data,
 			p_msg_index_out => l_msg_index_out);
 			x_msg_data := l_data;
 	    END IF;
 	    RAISE FND_API.G_EXC_ERROR;
 	  END IF;
        END IF;
      END IF;

--dbms_output.put_line( 'In update task 7' );

      --Check Start Date
      -- Added for bug 5665772
     IF p_dates_check = 'Y' THEN
      IF (p_task_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND
          nvl(p_task_start_date,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) <>
          nvl(TSTART_DATE,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) ) -- Bug 6163119
        THEN
        PA_TASKS_MAINT_UTILS.Check_Start_Date(
          p_project_id => p_project_id,
          p_parent_task_id => TPARENT_TASK_ID,
          p_task_id => p_task_id, -- Bug 7386335
          p_start_date => p_task_start_date,
          x_return_status => l_ret,
          x_msg_count => l_msg_cnt,
          x_msg_data => l_msg_data);
        IF (l_ret <> 'S') THEN
          PA_UTILS.ADD_MESSAGE('PA', l_msg_data);
        END IF;
      END IF;
     END IF;

      --BUG 4081329, rtarway
      --Check Start Date EI
      IF (p_task_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND
          nvl(p_task_start_date,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) <>
          nvl(TSTART_DATE,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) ) -- Bug 6163119
      THEN
        PA_TASKS_MAINT_UTILS.Check_Start_Date_EI(
          p_project_id => p_project_id,
          p_task_id => p_task_id,
          p_start_date => p_task_start_date,
          x_return_status => l_ret,
          x_msg_count => l_msg_cnt,
          x_msg_data => l_msg_data);
          --Since This API would have Added message in Stack, dont add it again
      END IF;
      --End Add BUG 4081329, rtarway
--dbms_output.put_line( 'In update task 8' );

      -- Bug 7386335
      -- This serves only as a workaround fix. We cannot change the condition IF (x_msg_count = 1) to IF
      -- (x_msg_count > 1) since the change will have to be made in all the procedures involved in the flow.
      l_msg_count := FND_MSG_PUB.count_msg;
      IF (l_msg_count > 0) THEN
        x_msg_count := l_msg_count;
        IF (x_msg_count = 1) THEN
          pa_interface_utils_pub.get_messages(
			p_encoded => FND_API.G_TRUE,
			p_msg_index => 1,
			p_data => l_data,
			p_msg_index_out => l_msg_index_out);
			x_msg_data := l_data;
        END IF;
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      --Check Completion Date
    -- Added for bug 5665772
    IF p_dates_check = 'Y' THEN

      IF (p_task_completion_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND
          nvl(p_task_completion_date,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) <>
          nvl(TCOMPLETION_DATE,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) ) -- Bug 6163119
      THEN

        PA_TASKS_MAINT_UTILS.Check_End_Date(
          p_project_id => p_project_id,
          p_parent_task_id => TPARENT_TASK_ID,
          --p_task_id => NULL,
          p_task_id => p_task_id,--BUG 4081329, rtarway
          p_end_date => p_task_completion_date,
          x_return_status => l_ret,
          x_msg_count => l_msg_cnt,
          x_msg_data => l_msg_data);
        IF (l_ret <> 'S') THEN
          PA_UTILS.ADD_MESSAGE('PA', l_msg_data);
        END IF;
      END IF;
    END IF;

            --BUG 4081329, rtarway
       --Check Completion Date against EI date
      IF (p_task_completion_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE AND
          nvl(p_task_completion_date,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) <>
          nvl(TCOMPLETION_DATE,PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) ) -- Bug 6163119
      THEN

        PA_TASKS_MAINT_UTILS.Check_End_Date_EI(
          p_project_id => p_project_id,
          p_task_id => p_task_id,
          p_end_date => p_task_completion_date,
          x_return_status => l_ret,
          x_msg_count => l_msg_cnt,
          x_msg_data => l_msg_data);
          --Since This API would have Added message in Stack, dont add it again
      END IF;
      --End Add BUG 4081329, rtarway

--dbms_output.put_line( 'In update task 9' );

      --Check Schedule Dates
      IF (p_scheduled_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR
          p_scheduled_start_date IS NULL) AND
         (p_scheduled_finish_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR
          p_scheduled_finish_date IS NULL) THEN
        PA_TASKS_MAINT_UTILS.CHECK_SCHEDULE_DATES(
          p_project_id => p_project_id,
          p_sch_start_date => p_scheduled_start_date,
          p_sch_end_date => p_scheduled_finish_date,
          x_return_status => l_ret,
          x_msg_count => l_msg_cnt,
          x_msg_data => l_msg_data);
--        IF (l_ret <> 'S') THEN
--          PA_UTILS.ADD_MESSAGE('PA', l_msg_data);
--        END IF;
      END IF;
--dbms_output.put_line( 'In update task 10' );

      --Check Estimate Dates
      IF (p_estimated_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR
          p_estimated_start_date IS NULL) AND
         (p_estimated_end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR
          p_estimated_end_date IS NULL) THEN
        PA_TASKS_MAINT_UTILS.CHECK_ESTIMATE_DATES(
          p_project_id => p_project_id,
          p_estimate_start_date => p_estimated_start_date,
          p_estimate_end_date => p_estimated_end_date,
          x_return_status => l_ret,
          x_msg_count => l_msg_cnt,
          x_msg_data => l_msg_data);
--        IF (l_ret <> 'S') THEN
--          PA_UTILS.ADD_MESSAGE('PA', l_msg_data);
--        END IF;
      END IF;

--dbms_output.put_line( 'In update task 11' );

      --Check Actual Dates
      IF (p_actual_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR
          p_actual_start_date IS NULL) AND
         (p_actual_finish_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR
          p_actual_finish_date IS NULL) THEN
        PA_TASKS_MAINT_UTILS.CHECK_ACTUAL_DATES(
          p_project_id => p_project_id,
          p_actual_start_date => p_actual_start_date,
          p_actual_end_date => p_actual_finish_date,
          x_return_status => l_ret,
          x_msg_count => l_msg_cnt,
          x_msg_data => l_msg_data);
--        IF (l_ret <> 'S') THEN
--          PA_UTILS.ADD_MESSAGE('PA', l_msg_data);
--        END IF;
      END IF;

    END IF;

--dbms_output.put_line( 'In update task 12' );

    IF (p_calling_module IN ('SELF_SERVICE')) THEN
      -- Check if PRM is installed
      IF (PA_INSTALL.IS_PRM_LICENSED() = 'Y') THEN
        -- Work Type is required
        IF (p_work_type_id IS NULL) THEN
          PA_UTILS.ADD_MESSAGE('PA','PA_WORK_TYPE_REQ');
        END IF;
      END IF;
      null;
    END IF;

    --Check if it is okay to change parent task

--dbms_output.put_line( 'In update task 13' );

    IF (p_calling_module IN ('SELF_SERVICE', 'FORM')) THEN
      IF NVL( p_parent_task_id, -1 ) <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM AND
         NVL( p_parent_task_id, -1 ) <> TPARENT_TASK_ID  THEN --parent task has changed



        IF (p_parent_task_id IS NOT NULL AND NVL( p_parent_task_id, -1 ) <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN

    l_msg_count := FND_MSG_PUB.count_msg;

--dbms_output.put_line( 'In update task 14 '|| l_msg_count);


          PA_PROJECT_PUB.CHECK_CHANGE_PARENT_OK(
            p_api_version_number => 1.0,
            p_project_id => p_project_id,
            p_task_id => p_task_id,
            p_new_parent_task_id => p_parent_task_id,
            p_pm_project_reference => NULL,
            p_pm_task_reference => NULL,
            p_pm_new_parent_task_reference => NULL,
            p_change_parent_ok_flag => l_change_parent_flag,
            p_return_status => l_ret,
            p_msg_count => l_msg_cnt,
            p_msg_data => l_msg_data);

    l_msg_count := FND_MSG_PUB.count_msg;

--dbms_output.put_line( 'In update task 14 --erro msg '|| l_msg_count);

          IF (l_change_parent_flag <> 'Y') THEN
            PA_UTILS.ADD_MESSAGE('PA', 'PA_CANT_CHANGE_PARENT');
          END IF;
        ELSE
          --new parent task is null; cannot change
          /* Bug2740269  -- commented the following message populataion. The parent can be null in case of top task
          PA_UTILS.ADD_MESSAGE('PA', 'PA_CANT_CHANGE_PARENT');
       */
      null;
        END IF;
      END IF;
    END IF;

    -- Check if there is any error. Get new Task Id if no error

    l_msg_count := FND_MSG_PUB.count_msg;
    IF (l_msg_count > 0) THEN
      x_msg_count := l_msg_count;
      IF (x_msg_count = 1) THEN
        pa_interface_utils_pub.get_messages(
          p_encoded => FND_API.G_TRUE,
          p_msg_index => 1,
          p_data => l_data,
          p_msg_index_out => l_msg_index_out);
        x_msg_data := l_data;
      END IF;
      RAISE FND_API.G_EXC_ERROR;
    END IF;


--dbms_output.put_line( 'In update task 15' );

    --Update with incoming parameters
    -- Replacing non-entered values
    IF (p_task_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_task_name IS NULL ) THEN
      TTASK_NAME := substrb(p_task_name,1,20); -- 4151509
    END IF;

    IF (p_long_task_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_long_task_name IS NULL ) THEN
      TLONG_TASK_NAME := p_long_task_name;
    END IF;
--dbms_output.put_line( 'In update task 15 -- 1' );


    IF (p_task_number <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_task_number IS NULL ) THEN
      TTASK_NUMBER := substrb(p_task_number,1,25); -- 4151509
    END IF;

--dbms_output.put_line( 'In update task 15 -- 2' );


    IF (p_task_description <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_task_description IS NULL ) THEN
      TDESCRIPTION := substrb(p_task_description,1,250); -- 4151509
    END IF;

    IF (p_task_manager_person_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_task_manager_person_id IS NULL ) THEN
      TTASK_MANAGER_PERSON_ID := p_task_manager_person_id;
    END IF;

    IF (p_carrying_out_organization_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_carrying_out_organization_id IS NULL ) THEN
      IF (p_carrying_out_organization_id IS NOT NULL) THEN
        TCARRYING_OUT_ORG_ID := p_carrying_out_organization_id;
      END IF;
    END IF;

    IF (p_task_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_task_type_code IS NULL ) THEN
      TTASK_TYPE_CODE := p_task_type_code;
    END IF;

    IF (p_priority_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_priority_code IS NULL ) THEN
      TPRIORITY_CODE := p_priority_code;
    END IF;

    IF (p_work_type_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_work_type_id IS NULL ) THEN
      TWORK_TYPE_ID := p_work_type_id;
    END IF;

    IF (p_service_type_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_service_type_code IS NULL ) THEN
      TSERVICE_TYPE_CODE := p_service_type_code;
    END IF;

    IF (p_milestone_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_milestone_flag IS NULL ) THEN
      TMILESTONE_FLAG := p_milestone_flag;
    END IF;

    IF (p_critical_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_critical_flag IS NULL ) THEN
      TCRITICAL_FLAG := p_critical_flag;
    END IF;

    IF (p_chargeable_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_chargeable_flag IS NULL ) THEN
      TCHARGEABLE := p_chargeable_flag;
    END IF;

    --hy
    --Check if child exist for current parent task. If not,
    --update chargeable flag to Y
    IF (Pa_Task_Utils.check_child_Exists(NVL(p_task_id,0)) = 1 ) THEN
      TCHARGEABLE := 'N';
    END IF;


    IF (p_billable_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_billable_flag IS NULL ) THEN
      TBILLABLE := p_billable_flag;
    END IF;

    IF (p_receive_project_invoice_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_receive_project_invoice_flag IS NULL ) THEN
--dbms_output.put_line( 'In update task 16' );

        select project_type INTO TPROJECT_TYPE
          from pa_projects_all
         where project_id = p_project_id;
      PA_TASKS_MAINT_UTILS.Check_Chargeable_Flag( p_chargeable_flag => TCHARGEABLE,
                       p_receive_project_invoice_flag => p_receive_project_invoice_flag,
                       p_project_type => TPROJECT_TYPE,
               p_project_id   => p_project_id, -- Added for bug#3512486
                       x_receive_project_invoice_flag => TRECEIVE_PROJECT_INVOICE_FLAG);
--      TRECEIVE_PROJECT_INVOICE_FLAG := p_receive_project_invoice_flag;
    END IF;

    IF (p_scheduled_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_scheduled_start_date IS NULL ) THEN
      TSCHEDULED_START_DATE := p_scheduled_start_date;
    END IF;

    IF (p_scheduled_finish_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_scheduled_finish_date IS NULL ) THEN
      TSCHEDULED_FINISH_DATE := p_scheduled_finish_date;
    END IF;

    IF (p_estimated_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_estimated_start_date IS NOT NULL ) THEN
      TESTIMATED_START_DATE := p_estimated_start_date;

    ELSIF (TESTIMATED_START_DATE is NULL or TESTIMATED_START_DATE =PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
    TESTIMATED_START_DATE := TSCHEDULED_START_DATE;
    END IF;


    IF (p_estimated_end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_estimated_end_date IS NOT NULL ) THEN
      TESTIMATED_END_DATE := p_estimated_end_date;

    ELSIF (TESTIMATED_END_DATE is NULL or TESTIMATED_END_DATE =PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE) THEN
    TESTIMATED_END_DATE := TSCHEDULED_FINISH_DATE;
    END IF;

    IF (p_actual_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_actual_start_date IS NULL ) THEN
      TACTUAL_START_DATE := p_actual_start_date;
    END IF;

    IF (p_actual_finish_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_actual_finish_date IS NULL ) THEN
      TACTUAL_FINISH_DATE := p_actual_finish_date;
    END IF;

    IF (p_task_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_task_start_date IS NULL ) THEN
      TSTART_DATE := p_task_start_date;
    END IF;

    IF (p_task_completion_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_task_completion_date IS NULL ) THEN
      TCOMPLETION_DATE := p_task_completion_date;
    END IF;

    IF (p_baseline_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_baseline_start_date IS NULL ) THEN
      TBASELINE_START_DATE := p_baseline_start_date;
    END IF;

    IF (p_baseline_end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR  p_baseline_end_date IS NULL ) THEN
      TBASELINE_END_DATE := p_baseline_end_date;
    END IF;

    IF (p_obligation_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_obligation_start_date IS NULL ) THEN
      TOBLIGATION_START_DATE := p_obligation_start_date;
    END IF;

    IF (p_obligation_end_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_obligation_end_date IS NULL ) THEN
      TOBLIGATION_END_DATE := p_obligation_end_date;
    END IF;

    IF (p_estimate_to_complete_work <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_estimate_to_complete_work IS NULL ) THEN
      TESTIMATE_TO_COMPLETE_WORK := p_estimate_to_complete_work;
    END IF;

    IF (p_baseline_work <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_baseline_work IS NULL ) THEN
      TBASELINE_WORK := p_baseline_work;
    END IF;

    IF (p_scheduled_work <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_scheduled_work IS NULL ) THEN
      TSCHEDULED_WORK := p_scheduled_work;
    END IF;

    IF (p_actual_work_to_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_actual_work_to_date IS NULL ) THEN
      TACTUAL_WORK_TO_DATE := p_actual_work_to_date;
    END IF;

    IF (p_work_unit <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_work_unit IS NULL ) THEN
      TWORK_UNIT_CODE := p_work_unit;
    END IF;

    IF (p_progress_status_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_progress_status_code IS NULL ) THEN
      TPROGRESS_STATUS_CODE := p_progress_status_code;
    END IF;

    IF (p_job_bill_rate_schedule_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_job_bill_rate_schedule_id IS NULL ) THEN
      TJOB_BILL_RATE_SCHEDULE_ID := p_job_bill_rate_schedule_id;
    END IF;

    IF (p_emp_bill_rate_schedule_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_emp_bill_rate_schedule_id IS NULL ) THEN
      TEMP_BILL_RATE_SCHEDULE_ID := p_emp_bill_rate_schedule_id;
    END IF;

    IF (p_address_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_address_id IS NULL ) THEN
      TADDRESS_ID := p_address_id;
    END IF;

    IF (p_ready_to_bill_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_ready_to_bill_flag IS NULL ) THEN
      TREADY_TO_BILL_FLAG := p_ready_to_bill_flag;
    END IF;

    IF (p_ready_to_distribute_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_ready_to_distribute_flag IS NULL ) THEN
      TREADY_TO_DISTRIBUTE_FLAG := p_ready_to_distribute_flag;
    END IF;

    IF (p_limit_to_txn_controls_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_limit_to_txn_controls_flag IS NULL ) THEN
      TLIMIT_TO_TXN_CONTROLS_FLAG := p_limit_to_txn_controls_flag;
    END IF;

    IF (p_labor_bill_rate_org_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_labor_bill_rate_org_id IS NULL ) THEN
      TLABOR_BILL_RATE_ORG_ID := p_labor_bill_rate_org_id;
    END IF;

    IF (p_labor_std_bill_rate_schdl <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_labor_std_bill_rate_schdl IS NULL ) THEN
      TLABOR_STD_BILL_RATE_SCHDL := p_labor_std_bill_rate_schdl;
    END IF;

    IF (p_labor_schedule_fixed_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_labor_schedule_fixed_date IS NULL ) THEN
      TLABOR_SCHEDULE_FIXED_DATE := p_labor_schedule_fixed_date;
    END IF;

    IF (p_labor_schedule_discount <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_labor_schedule_discount IS NULL ) THEN
      TLABOR_SCHEDULE_DISCOUNT := p_labor_schedule_discount;
    END IF;

    IF (p_nl_bill_rate_org_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_nl_bill_rate_org_id IS NULL ) THEN
      TNLR_BILL_RATE_ORG_ID := p_nl_bill_rate_org_id;
    END IF;

    IF (p_nl_std_bill_rate_schdl <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_nl_std_bill_rate_schdl IS NULL ) THEN
      TNLR_STD_BILL_RATE_SCHDL := p_nl_std_bill_rate_schdl;
    END IF;

    IF (p_nl_schedule_fixed_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_nl_schedule_fixed_date IS NULL ) THEN
      TNLR_SCHEDULE_FIXED_DATE := p_nl_schedule_fixed_date;
    END IF;

    IF (p_nl_schedule_discount <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_nl_schedule_discount IS NULL ) THEN
      TNLR_SCHEDULE_DISCOUNT := p_nl_schedule_discount;
    END IF;

    IF (p_labor_cost_multiplier_name <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_labor_cost_multiplier_name IS NULL ) THEN
      TLABOR_COST_MULTIPLIER_NAME := p_labor_cost_multiplier_name;
    END IF;

    IF (p_cost_ind_rate_sch_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_cost_ind_rate_sch_id IS NULL ) THEN
      TCOST_IND_RATE_SCH_ID := p_cost_ind_rate_sch_id;
    END IF;

    IF (p_rev_ind_rate_sch_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_rev_ind_rate_sch_id IS NULL ) THEN
      TREV_IND_RATE_SCH_ID := p_rev_ind_rate_sch_id;
    END IF;

    IF (p_inv_ind_rate_sch_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_inv_ind_rate_sch_id IS NULL ) THEN
      TINV_IND_RATE_SCH_ID := p_inv_ind_rate_sch_id;
    END IF;

    IF (p_cost_ind_sch_fixed_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_cost_ind_sch_fixed_date IS NULL ) THEN
      TCOST_IND_SCH_FIXED_DATE := p_cost_ind_sch_fixed_date;
    END IF;

    IF (p_rev_ind_sch_fixed_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_rev_ind_sch_fixed_date IS NULL ) THEN
      TREV_IND_SCH_FIXED_DATE := p_rev_ind_sch_fixed_date;
    END IF;

    IF (p_inv_ind_sch_fixed_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_inv_ind_sch_fixed_date IS NULL ) THEN
      TINV_IND_SCH_FIXED_DATE := p_inv_ind_sch_fixed_date;
    END IF;

    IF (p_labor_sch_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_labor_sch_type IS NULL ) THEN
      TLABOR_SCH_TYPE := p_labor_sch_type;
    END IF;

    IF (p_nl_sch_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_nl_sch_type IS NULL ) THEN
      TNLR_SCH_TYPE := p_nl_sch_type;
    END IF;

    IF (p_early_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_early_start_date IS NULL ) THEN
      TEARLY_START_DATE := p_early_start_date;
    END IF;

    IF (p_early_finish_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_early_finish_date IS NULL ) THEN
      TEARLY_FINISH_DATE := p_early_finish_date;
    END IF;

    IF (p_late_start_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_late_start_date IS NULL ) THEN
      TLATE_START_DATE := p_late_start_date;
    END IF;

    IF (p_late_finish_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_late_finish_date IS NULL ) THEN
      TLATE_FINISH_DATE := p_late_finish_date;
    END IF;

    IF (p_attribute_category <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute_category IS NULL ) THEN
      TATTRIBUTE_CATEGORY := p_attribute_category;
    END IF;

   IF (p_attribute1 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute1 IS NULL) THEN	/* Modified for Bug#6041525 */
      TATTRIBUTE1 := p_attribute1;
    END IF;

    IF (p_attribute2 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute2 IS NULL) THEN	/* Modified for Bug#6041525 */
      TATTRIBUTE2 := p_attribute2;
    END IF;

    IF (p_attribute3 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute3 IS NULL) THEN	/* Modified for Bug#6041525 */
      TATTRIBUTE3 := p_attribute3;
    END IF;

    IF (p_attribute4 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute4 IS NULL) THEN	/* Modified for Bug#6041525 */
      TATTRIBUTE4 := p_attribute4;
    END IF;

    IF (p_attribute5 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute5 IS NULL) THEN	/* Modified for Bug#6041525 */
      TATTRIBUTE5 := p_attribute5;
    END IF;

    IF (p_attribute6 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute6 IS NULL) THEN	/* Modified for Bug#6041525 */
      TATTRIBUTE6 := p_attribute6;
    END IF;

    IF (p_attribute7 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute7 IS NULL) THEN	/* Modified for Bug#6041525 */
      TATTRIBUTE7 := p_attribute7;
    END IF;

    IF (p_attribute8 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute8 IS NULL) THEN	/* Modified for Bug#6041525 */
      TATTRIBUTE8 := p_attribute8;
    END IF;

    IF (p_attribute9 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute9 IS NULL) THEN	/* Modified for Bug#6041525 */
      TATTRIBUTE9 := p_attribute9;
    END IF;

    IF (p_attribute10 <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_attribute10 IS NULL) THEN	/* Modified for Bug#6041525 */
      TATTRIBUTE10 := p_attribute10;
    END IF;

    IF (p_allow_cross_charge_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_allow_cross_charge_flag IS NULL ) THEN
      TALLOW_CROSS_CHARGE_FLAG := p_allow_cross_charge_flag;
    END IF;

    IF (p_project_rate_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_project_rate_date IS NULL ) THEN
      TPROJECT_RATE_DATE := p_project_rate_date;
    END IF;

    IF (p_project_rate_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_project_rate_type IS NULL ) THEN
      TPROJECT_RATE_TYPE := p_project_rate_type;
    END IF;

    IF (p_cc_process_labor_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_cc_process_labor_flag IS NULL ) THEN
      TCC_PROCESS_LABOR_FLAG := p_cc_process_labor_flag;
    END IF;

    IF (p_labor_tp_schedule_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_labor_tp_schedule_id IS NULL ) THEN
      TLABOR_TP_SCHEDULE_ID := p_labor_tp_schedule_id;
    END IF;

    IF (p_labor_tp_fixed_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_labor_tp_fixed_date IS NULL ) THEN
      TLABOR_TP_FIXED_DATE := p_labor_tp_fixed_date;
    END IF;

    IF (p_cc_process_nl_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_cc_process_nl_flag IS NULL ) THEN
      TCC_PROCESS_NL_FLAG := p_cc_process_nl_flag;
    END IF;

    IF (p_nl_tp_schedule_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_nl_tp_schedule_id IS NULL ) THEN
      TNL_TP_SCHEDULE_ID := p_nl_tp_schedule_id;
    END IF;

    IF (p_nl_tp_fixed_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_nl_tp_fixed_date IS NULL ) THEN
      TNL_TP_FIXED_DATE := p_nl_tp_fixed_date;
    END IF;

    --Added by ansari
--dbms_output.put_line( 'In update task 15 -- 2' );

    IF (p_top_task_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_top_task_id IS NULL ) THEN
      TTOP_TASK_ID := p_top_task_id;
    END IF;

    IF (p_parent_task_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_parent_task_id IS NULL ) THEN
      TPARENT_TASK_ID := p_parent_task_id;
    END IF;

    IF (p_wbs_level <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_wbs_level IS NULL ) THEN
       TWBS_LEVEL:= p_wbs_level;
    END IF;

    IF (p_display_sequence <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM) THEN
       TDISPLAY_SEQUENCE:= p_display_sequence;
    END IF;

    IF (p_inc_proj_progress_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_inc_proj_progress_flag IS NULL ) THEN
       Tinc_proj_progress_flag:= p_inc_proj_progress_flag;
    END IF;

    IF (p_comments <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_comments IS NULL ) THEN
       Tcomments:= p_comments;
    END IF;

    IF (p_comments <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_comments IS NULL ) THEN
       Tcomments:= p_comments;
    END IF;


    IF (p_taskfunc_cost_rate_type <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_taskfunc_cost_rate_type IS NULL ) THEN
       ttaskfunc_cost_rate_type:= p_taskfunc_cost_rate_type;
    END IF;

    IF (p_taskfunc_cost_rate_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR p_taskfunc_cost_rate_date IS NULL ) THEN
       ttaskfunc_cost_rate_date:= p_taskfunc_cost_rate_date;
    END IF;

    IF (p_non_lab_std_bill_rt_sch_id <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM OR p_non_lab_std_bill_rt_sch_id IS NULL ) THEN
       tnon_lab_std_bill_rt_sch_id:= p_non_lab_std_bill_rt_sch_id;
    END IF;
--  FP.K changes msundare
    IF (p_labor_disc_reason_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_labor_disc_reason_code IS NULL ) THEN
       Tlabor_disc_reason_code:= p_labor_disc_reason_code;
    END IF;

    IF (p_non_labor_disc_reason_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR p_non_labor_disc_reason_code IS NULL ) THEN
       Tnon_labor_disc_reason_code:= p_non_labor_disc_reason_code;
    END IF;

--PA L Capital Project Changes 2872708
    IF (p_retirement_cost_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
        p_retirement_cost_flag IS NULL ) THEN
       tretirement_cost_flag:= p_retirement_cost_flag;
    END IF;

    IF (p_cint_eligible_flag <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR OR
        p_cint_eligible_flag IS NULL ) THEN
        tcint_eligible_flag:= p_cint_eligible_flag;
    END IF;

    IF (p_cint_stop_date <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE OR
        p_cint_stop_date IS NULL ) THEN
        tcint_stop_date:= p_cint_stop_date;
    END IF;

--End PA L Capital Project Changes 2872708

    IF (p_gen_etc_src_code <> PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR or
        p_gen_etc_src_code IS NULL) THEN
      TGEN_ETC_SOURCE_CODE := p_gen_etc_src_code;


    END IF;

--dbms_output.put_line( 'In update task 17' );

    -- update task
  PA_TASKS_PKG.update_row(
   l_rowid,
   p_task_id,
   p_project_id,
   TTASK_NUMBER,
   sysdate,
   FND_GLOBAL.USER_ID,
   FND_GLOBAL.USER_ID,
   TTASK_NAME,
   TLONG_TASK_NAME, --new
   TTOP_TASK_ID,
   TWBS_LEVEL,
   TREADY_TO_BILL_FLAG,
   TREADY_TO_DISTRIBUTE_FLAG,
   TPARENT_TASK_ID,
   TDESCRIPTION,
   TCARRYING_OUT_ORG_ID,
   TSERVICE_TYPE_CODE,
   TTASK_MANAGER_PERSON_ID,
   TCHARGEABLE,
   TBILLABLE,
   TLIMIT_TO_TXN_CONTROLS_FLAG,
   TSTART_DATE,
   TCOMPLETION_DATE,
   TADDRESS_ID,
   TLABOR_BILL_RATE_ORG_ID,
   TLABOR_STD_BILL_RATE_SCHDL,
   TLABOR_SCHEDULE_FIXED_DATE,
   TLABOR_SCHEDULE_DISCOUNT,
   TNLR_BILL_RATE_ORG_ID,
   TNLR_STD_BILL_RATE_SCHDL,
   TNLR_SCHEDULE_FIXED_DATE,
   TNLR_SCHEDULE_DISCOUNT,
   TLABOR_COST_MULTIPLIER_NAME,
   TATTRIBUTE_CATEGORY,
   TATTRIBUTE1,
   TATTRIBUTE2,
   TATTRIBUTE3,
   TATTRIBUTE4,
   TATTRIBUTE5,
   TATTRIBUTE6,
   TATTRIBUTE7,
   TATTRIBUTE8,
   TATTRIBUTE9,
   TATTRIBUTE10,
   TCOST_IND_RATE_SCH_ID,
   TREV_IND_RATE_SCH_ID,
   TINV_IND_RATE_SCH_ID,
   TCOST_IND_SCH_FIXED_DATE,
   TREV_IND_SCH_FIXED_DATE,
   TINV_IND_SCH_FIXED_DATE,
   TLABOR_SCH_TYPE,
   TNLR_SCH_TYPE,
   TALLOW_CROSS_CHARGE_FLAG,
   TPROJECT_RATE_DATE,
   TPROJECT_RATE_TYPE,
   TCC_PROCESS_LABOR_FLAG,
   TLABOR_TP_SCHEDULE_ID,
   TLABOR_TP_FIXED_DATE,
   TCC_PROCESS_NL_FLAG,
   TNL_TP_SCHEDULE_ID,
   TNL_TP_FIXED_DATE,
   TRECEIVE_PROJECT_INVOICE_FLAG,
   TWORK_TYPE_ID,
   TJOB_BILL_RATE_SCHEDULE_ID,
   TEMP_BILL_RATE_SCHEDULE_ID,

      /*TTASK_TYPE_CODE,
      TDISPLAY_SEQUENCE, --DISPLAY SEQUENCE
      TPRIORITY_CODE,
      TCRITICAL_FLAG,
      TMILESTONE_FLAG,
      TSCHEDULED_START_DATE,
      TSCHEDULED_FINISH_DATE,
      TACTUAL_START_DATE, -- Actual Start Date
      TACTUAL_FINISH_DATE, -- Actual Finish Date
      TESTIMATED_START_DATE,
      TESTIMATED_END_DATE,
      TBASELINE_START_DATE,
      TBASELINE_END_DATE,
      TOBLIGATION_START_DATE,
      TOBLIGATION_END_DATE,
      TESTIMATE_TO_COMPLETE_WORK,
      TBASELINE_WORK,
      TSCHEDULED_WORK,
      TACTUAL_WORK_TO_DATE,
      TWORK_UNIT_CODE,
      TPROGRESS_STATUS_CODE,
      Tinc_proj_progress_flag,
      Tcomments,
      p_record_version_number --Record version Number*/

      ttaskfunc_cost_rate_type,
      ttaskfunc_cost_rate_date,
      tnon_lab_std_bill_rt_sch_id,
      Tlabor_disc_reason_code,
      Tnon_labor_disc_reason_code,
--PA L Capital Project Changes 2872708
      tretirement_cost_flag ,
      tcint_eligible_flag   ,
      tcint_stop_date      ,
--End PA L Capital Project Changes 2872708
      tGEN_ETC_SOURCE_CODE
);

  x_return_status := FND_API.G_RET_STS_SUCCESS;


  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to UPDATE_TASK_PRIVATE;
      END IF;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN NO_DATA_FOUND THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to UPDATE_TASK_PRIVATE;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to UPDATE_TASK_PRIVATE;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_PVT',
                              p_procedure_name => 'UPDATE_TASK',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
  END UPDATE_TASK;


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
    ,p_bulk_flag                         IN  VARCHAR2    := 'N'        -- 4201927
    ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count                         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data                          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  )
  IS
    l_msg_count                          NUMBER := 0;

    l_err_code                           NUMBER                 := 0;
    l_err_stack                          VARCHAR2(630);
    l_err_stage                          VARCHAR2(80);
    l_data                               VARCHAR2(250);
    l_msg_data                           VARCHAR2(250);
    l_msg_index_out                      NUMBER;

    l_delete_project_allowed             VARCHAR2(1);
    l_update_proj_num_allowed            VARCHAR2(1);
    l_update_proj_name_allowed           VARCHAR2(1);
    l_update_proj_desc_allowed           VARCHAR2(1);
    l_update_proj_dates_allowed          VARCHAR2(1);
    l_update_proj_status_allowed         VARCHAR2(1);
    l_update_proj_manager_allowed        VARCHAR2(1);
    l_update_proj_org_allowed            VARCHAR2(1);
    l_add_task_allowed                   VARCHAR2(1);
    l_delete_task_allowed                VARCHAR2(1);
    l_update_task_num_allowed            VARCHAR2(1);
    l_update_task_name_allowed           VARCHAR2(1);
    l_update_task_dates_allowed          VARCHAR2(1);
    l_update_task_desc_allowed           VARCHAR2(1);
    l_update_parent_task_allowed         VARCHAR2(1);
    l_update_task_org_allowed            VARCHAR2(1);

    t_pm_product_code                    PA_TASKS.PM_PRODUCT_CODE%TYPE;
    t_parent_task_id                     PA_TASKS.PARENT_TASK_ID%TYPE;
  BEGIN
    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('PA_TASKS_MAINT_PVT.DELETE_TASK BEGIN');
    END IF;

    IF (p_commit = FND_API.G_TRUE) THEN
      savepoint DELETE_TASK_PRIVATE;
    END IF;

    IF (p_debug_mode = 'Y') THEN
      pa_debug.debug('Performing validations');
    END IF;

    -- Get PM_PRODUCT_CODE
    BEGIN
    select PM_PRODUCT_CODE, PARENT_TASK_ID
      into t_pm_product_code, t_parent_task_id
      from pa_tasks
     where task_id = p_task_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        PA_UTILS.ADD_MESSAGE('PA','PA_EXP_NO_TASK'); -- specified task does not exist
        raise FND_API.G_EXC_ERROR;
    END;

    -- Set controls
    IF (p_calling_module IN ('SELF_SERVICE')) THEN
      If (t_pm_product_code IS NOT NULL) THEN
        PA_PM_CONTROLS.GET_PROJECT_ACTIONS_ALLOWED(
          p_pm_product_code => t_pm_product_code,
          p_delete_project_allowed => l_delete_project_allowed,
          p_update_proj_num_allowed => l_update_proj_num_allowed,
          p_update_proj_name_allowed => l_update_proj_name_allowed,
          p_update_proj_desc_allowed => l_update_proj_desc_allowed,
          p_update_proj_dates_allowed  => l_update_proj_dates_allowed,
          p_update_proj_status_allowed => l_update_proj_status_allowed,
          p_update_proj_manager_allowed => l_update_proj_manager_allowed,
          p_update_proj_org_allowed => l_update_proj_org_allowed,
          p_add_task_allowed => l_add_task_allowed,
          p_delete_task_allowed => l_delete_task_allowed,
          p_update_task_num_allowed => l_update_task_num_allowed,
          p_update_task_name_allowed => l_update_task_name_allowed,
          p_update_task_dates_allowed => l_update_task_dates_allowed,
          p_update_task_desc_allowed => l_update_task_desc_allowed,
          p_update_parent_task_allowed => l_update_parent_task_allowed,
          p_update_task_org_allowed => l_update_task_org_allowed,
          p_error_code => l_err_code,
          p_error_stack => l_err_stack,
          p_error_stage => l_err_stage
        );
      END IF; --product code is not null
    END IF;

    If (p_calling_module IN ('SELF_SERVICE', 'FORM')) THEN
    --Check if task can be deleted;
      IF (t_pm_product_code IS NOT NULL) AND (l_delete_task_allowed = 'N') THEN
        PA_UTILS.ADD_MESSAGE('PA', 'PA_PR_PM_CANNOT_DELETE');
        raise FND_API.G_EXC_ERROR;
      END IF;

/* do not stop delting the last task. FPM changes
refer bug 3427157
      IF p_called_from_api <> 'IMPORT'   --do not perform the following validation if called from
                                         --PA_TASK_PUB1.DELETE_TASK_VERSION and PA_TASK_PUB1.DELETE_TASK_VERSION
                                         --is called from import logic.
      THEN
        --Check if this is last task;
        If (PA_TASK_UTILS.check_last_task(p_task_id) <> 0) THEN
            PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                 p_msg_name => 'PA_TK_CANT_DELETE_LAST_TASK');
            raise FND_API.G_EXC_ERROR;
         END IF;
      END IF;
 do not stop delting the last task. FPM changes*/

    --Bug 2947492: The following api call is modified to pass parameters by notation.
    --Check if it is okay to delete task
      -- 4201927 If this api is getting called from bulk task delete version, p_bulk_flag will
      -- be passed as 'Y' and below validation will not be done in that flow
      IF p_bulk_flag = 'N' THEN
          PA_TASK_UTILS.CHECK_DELETE_TASK_OK(x_task_id     => p_task_id,
                                             x_err_code    => l_err_code,
                                             x_err_stage   => l_err_stage,
                                             x_err_stack   => l_err_stack);
          IF (l_err_code <> 0) THEN
            PA_UTILS.ADD_MESSAGE('PA', substr(l_err_stage, 1, 30));
            raise FND_API.G_EXC_ERROR;
          END IF;
      END IF;
      -- 4201927 end

    END IF;

    --Bug 2947492: The following api call is modified to pass parameters by notation.
    PA_PROJECT_CORE.Delete_Task(
                      x_task_id     => p_task_id,
                      x_bulk_flag   => p_bulk_flag,
                      x_err_code    => l_err_code,
                      x_err_stage   => l_err_stage,
                      x_err_stack   => l_err_stack);

    If (l_err_code <> 0) THEN
      PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                           p_msg_name => substr(l_err_stage,1,30));
      raise FND_API.G_EXC_ERROR;
    END IF;

    IF (p_calling_module IN ('SELF_SERVICE', 'FORM')) THEN
      --Check if child exist for current parent task. If not,
      --update chargeable flag to Y
      IF (Pa_Task_Utils.check_child_Exists(NVL(t_parent_task_id,0)) = 0 ) THEN
        UPDATE Pa_tasks
        SET Chargeable_Flag = 'Y',
        RECORD_VERSION_NUMBER = nvl(RECORD_VERSION_NUMBER,0) + 1,
        last_updated_by = FND_GLOBAL.USER_ID,
        last_update_login = FND_GLOBAL.USER_ID,
        last_update_date = sysdate
        WHERE TASK_ID = t_parent_task_id;
      END IF;
    END IF;

    l_msg_count := FND_MSG_PUB.count_msg;
    IF (l_msg_count > 0) then
      x_msg_count := l_msg_count;
      IF (x_msg_count = 1) then
        pa_interface_utils_pub.get_messages
         (p_encoded        => FND_API.G_TRUE,
          p_msg_index      => 1,
          p_data           => l_data,
          p_msg_index_out  => l_msg_index_out);
         x_msg_data := l_data;
      end if;
      raise FND_API.G_EXC_ERROR;
    end if;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to DELETE_TASK_PRIVATE;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_ERROR;
    WHEN OTHERS THEN
      IF (p_commit = FND_API.G_TRUE) THEN
        ROLLBACK to DELETE_TASK_PRIVATE;
      END IF;
      x_msg_count := FND_MSG_PUB.count_msg;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      --put message
      fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_PVT',
                              p_procedure_name => 'DELETE_TASK',
                              p_error_text     => SUBSTRB(SQLERRM,1,240));
      RAISE;
  END DELETE_TASK;

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
  ,x_msg_data                OUT     NOCOPY VARCHAR2   ) AS --File.Sql.39 bug 4440895

    CURSOR c1 IS
      select 'x'
      from PA_TASKS
      where project_id = p_project_id
      for update of record_version_number NOWAIT;

    CURSOR c2 IS
      select 'x'
      from PA_TASKS
      where project_id = p_project_id;

    CURSOR cur_task_heirarchy
    IS
      SELECT task_id, wbs_level, record_version_number
        FROM pa_tasks
       START WITH task_id = p_task_id
       CONNECT BY PRIOR task_id = parent_task_id;


    --Get the parent of the indenting task if the above task is at higher level
    CURSOR cur_parent_of_above( p_wbs_level NUMBER,
                                p_top_task_id_above NUMBER,
                                p_display_sequence NUMBER )
    IS
/*      SELECT task_id, top_task_id
        FROM pa_tasks
       WHERE wbs_level = p_wbs_level
         AND top_task_id = p_top_task_id_above
         AND display_sequence = ( SELECT max( display_sequence )
                                    FROM pa_tasks
                                   WHERE top_task_id = p_top_task_id_above
                                     AND wbs_level = p_wbs_level
                                     AND display_sequence < p_display_sequence );*/
--Project Structure changes
    SELECT task_id, top_task_id
        FROM pa_tasks pt, pa_proj_element_versions ppev
       WHERE pt.wbs_level = p_wbs_level
         AND top_task_id = p_top_task_id_above
         AND pt.task_id = ppev.proj_element_id
         AND ppev.display_sequence = ( SELECT max( ppev.display_sequence )
                                         FROM pa_tasks pt, pa_proj_element_versions ppev
                                        WHERE top_task_id = p_top_task_id_above
                                          AND pt.wbs_level = p_wbs_level
                                          AND ppev.proj_element_id = pt.task_id
                                          AND ppev.display_sequence < p_display_sequence );

   l_return_status                    VARCHAR2(1);
   l_msg_data                         VARCHAR2(250);
   l_msg_count                        NUMBER;

   l_dummy                            VARCHAR2(1);
   l_error_msg_code                   VARCHAR2(250);
   l_data                             VARCHAR2(250);
   l_msg_index_out                    NUMBER;

   l_task_level                       PA_TASKS.WBS_LEVEL%TYPE :=0;
   l_parent_task_id                   NUMBER;
   l_top_task_id                      NUMBER;
   l_display_sequence                 NUMBER;

   l_task_level_above                 PA_TASKS.WBS_LEVEL%TYPE :=0;
   l_task_id_above                    NUMBER;
   l_parent_task_id_above             NUMBER;
   l_top_task_id_above                NUMBER;
   l_display_sequence_above           NUMBER;

   l_new_parent_id                    NUMBER;
   l_new_top_id                       NUMBER;

-- 23-JUL-2001 Added by HSIU
    l_err_code                           NUMBER                 := 0;
    l_err_stack                          VARCHAR2(630);
    l_err_stage                          VARCHAR2(80); -- VARCHAR2(80)

 BEGIN

    IF p_commit = FND_API.G_TRUE
    THEN
       SAVEPOINT Edit_Structure;
    END IF;
    x_return_status := 'S';

    PA_TASKS_MAINT_UTILS.GetWbsLevel(
                                 p_project_id           => p_project_id,
                                 p_task_id              => p_task_id,

                                 x_task_level           => l_task_level,
                                 x_parent_task_id       => l_parent_task_id,
                                 x_top_task_id          => l_top_task_id,
                                 x_display_sequence     => l_display_sequence,

                                 x_task_id_above       => l_task_id_above,
                                 x_task_level_above     => l_task_level_above,
                                 x_parent_task_id_above => l_parent_task_id_above,
                                 x_top_task_id_above    => l_top_task_id_above,
                                 x_display_sequence_above => l_display_sequence_above,

                                 x_return_status     => x_return_status,
                                 x_error_msg_code    => x_msg_data );

    -- if the above task is at the higher level ( with low wbs level value ) then the task
    --   cannot be indented.

--dbms_output.put_line( 'Indent Task PVT : Stage 1' );
/* Bug2740269 -- Commented the following If condition and added a new
    IF  l_task_level > l_task_level_above OR l_task_level = 1
*/
    IF  l_task_level > l_task_level_above OR l_display_sequence = 1
    THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_TASK_CANNOT_INDENT' );
        x_msg_data := 'PA_TASK_CANNOT_INDENT';
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE  FND_API.G_EXC_ERROR;

    ELSE

--dbms_output.put_line( 'Indent Task PVT : Stage 2' ||' l_task_level '||l_task_level||'  l_task_level_above '||l_task_level_above);

     -- If the above task has the same wbs level as that of the indenting task then the indenting
      -- task becomes the child of the above task

      IF l_task_level = l_task_level_above
      THEN
        -- 0) Check if this task can have a subtask; no need to check in other cases since
        --    the task is already at a higher level, which means it is already a subtask of
        --    another task
        -- 23-JUL-2001
        -- Added by HSIU--check if the reference task can have child tasks

    l_msg_count := FND_MSG_PUB.count_msg;

--dbms_output.put_line( 'Indent Task PVT : Stage 3 '||'Count '||l_msg_count );

        PA_TASK_UTILS.CHECK_CREATE_SUBTASK_OK(x_task_id => l_task_id_above,
           x_err_code => l_err_code,
           x_err_stack => l_err_stack,
           x_err_stage => l_err_stage
        );
        IF (l_err_code <> 0) THEN
           PA_UTILS.ADD_MESSAGE('PA', substr(l_err_stage,1,30));
        END IF;

    l_msg_count := FND_MSG_PUB.count_msg;

--dbms_output.put_line( 'Indent Task PVT : Stage 4'||' Count '||l_msg_count );

        -- HSIU changes ends here

        -- 1) update the parent task id of the indenting task with the above task id
        PA_TASKS_MAINT_PVT.UPDATE_TASK
           (
              p_commit                            => p_commit
             ,p_validate_only                     => p_validate_only
             ,p_validation_level                  => p_validation_level
             ,p_calling_module                    => p_calling_module
             ,p_debug_mode                        => p_debug_mode

             ,p_project_id                        => p_project_id
             ,p_task_id                           => p_task_id
             ,p_parent_task_id                    => l_task_id_above
             ,p_record_version_number             => p_record_version_number
             ,x_return_status                     => x_return_status
             ,x_msg_count                         => x_msg_count
             ,x_msg_data                          => x_msg_data );

    l_msg_count := FND_MSG_PUB.count_msg;

--dbms_output.put_line( 'Indent Task PVT : Stage 5'||' Count '||l_msg_count  );


            l_msg_count := FND_MSG_PUB.count_msg;

            IF l_msg_count > 0 THEN
               x_msg_count := l_msg_count;
               x_return_status := 'E';
               RAISE  FND_API.G_EXC_ERROR;
            END IF;

        -- Changes for bug 3125880
        -- As Parent Task Id of the Task being indented is updated and b'coz of this
        -- for this particular case the parent task was earlier a lowest level task
        -- but now it has become a summarized level task so need to update its chargeable flag to N

        UPDATE PA_TASKS SET CHARGEABLE_FLAG='N'
        WHERE TASK_ID = l_task_id_above;

        -- End of Changes for bug 3125880

        -- 2) update the wbs level of the indenting task and its children

--dbms_output.put_line( 'Indent Task PVT : Stage 6' );


        FOR cur_task_heirarchy_rec IN cur_task_heirarchy LOOP

            PA_TASKS_MAINT_PVT.UPDATE_TASK
              (
                 p_commit                            => p_commit
                ,p_validate_only                     => p_validate_only
                ,p_validation_level                  => p_validation_level
                ,p_calling_module                    => p_calling_module
                ,p_debug_mode                        => p_debug_mode

                ,p_project_id                        => p_project_id
                ,p_task_id                           => cur_task_heirarchy_rec.task_id
                ,p_wbs_level                         => cur_task_heirarchy_rec.wbs_level + 1

                --3) update the top task id of the indenting task including its children with the top task id of the task above.
                ,p_top_task_id                       => l_top_task_id_above
                ,p_record_version_number             => cur_task_heirarchy_rec.record_version_number
                ,x_return_status                     => x_return_status
                ,x_msg_count                         => x_msg_count
                ,x_msg_data                          => x_msg_data );

            l_msg_count := FND_MSG_PUB.count_msg;

            IF l_msg_count > 0 THEN
               x_msg_count := l_msg_count;
               x_return_status := 'E';
               RAISE  FND_API.G_EXC_ERROR;
            END IF;

        END LOOP;

--dbms_output.put_line( 'Indent Task PVT : Stage 7' );

      ELSIF l_task_level < l_task_level_above
      THEN


        -- 1) update the parent task id of the indenting task same as that above task in the above heirarchy which used to
        -- at the same level as that of indenting task before indenting.


        OPEN cur_parent_of_above( l_task_level , l_top_task_id_above, l_display_sequence );
        FETCH cur_parent_of_above INTO l_new_parent_id, l_new_top_id;
        CLOSE cur_parent_of_above;

        PA_TASKS_MAINT_PVT.UPDATE_TASK
            (
                p_commit                            => p_commit
               ,p_validate_only                     => p_validate_only
               ,p_validation_level                  => p_validation_level
               ,p_calling_module                    => p_calling_module
               ,p_debug_mode                        => p_debug_mode

              ,p_project_id                        => p_project_id
              ,p_task_id                           => p_task_id
              ,p_parent_task_id                    => l_new_parent_id
              ,p_record_version_number             => p_record_version_number
              ,x_return_status                     => x_return_status
              ,x_msg_count                         => x_msg_count
              ,x_msg_data                          => x_msg_data );


            l_msg_count := FND_MSG_PUB.count_msg;

            IF l_msg_count > 0 THEN
               x_msg_count := l_msg_count;
               x_return_status := 'E';
               RAISE  FND_API.G_EXC_ERROR;
            END IF;

        -- 2) update the top task id of the indenting task including its children with the top task id of the task above.
        -- 3) update the wbs level of the indenting task and its children


        FOR cur_task_heirarchy_rec IN cur_task_heirarchy LOOP

            PA_TASKS_MAINT_PVT.UPDATE_TASK
              (
              p_commit                            => p_commit
             ,p_validate_only                     => p_validate_only
             ,p_validation_level                  => p_validation_level
             ,p_calling_module                    => p_calling_module
             ,p_debug_mode                        => p_debug_mode

                ,p_project_id                        => p_project_id
                ,p_task_id                           => cur_task_heirarchy_rec.task_id
                ,p_wbs_level                         => cur_task_heirarchy_rec.wbs_level + 1
                ,p_top_task_id                       => l_top_task_id_above
                ,p_record_version_number             => cur_task_heirarchy_rec.record_version_number
                ,x_return_status                     => x_return_status
                ,x_msg_count                         => x_msg_count
                ,x_msg_data                          => x_msg_data );

            l_msg_count := FND_MSG_PUB.count_msg;

            IF l_msg_count > 0 THEN
               x_msg_count := l_msg_count;
               x_return_status := 'E';
               RAISE  FND_API.G_EXC_ERROR;
            END IF;

        END LOOP;
      END IF;
    END IF;

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Edit_Structure;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_PVT',
                               p_procedure_name => 'Indent_task',
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
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_PVT',
                               p_procedure_name => 'Indent_task',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;

 END Indent_Task;

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
  ,x_msg_data                OUT     NOCOPY VARCHAR2   ) AS --File.Sql.39 bug 4440895

   l_return_status                    VARCHAR2(1);
   l_msg_data                         VARCHAR2(250);
   l_msg_count                        NUMBER;

   l_dummy                       VARCHAR2(1);
   l_error_msg_code                   VARCHAR2(250);
   l_data                             VARCHAR2(250);
   l_msg_index_out                    NUMBER;

   l_task_level                       PA_TASKS.WBS_LEVEL%TYPE :=0;
   l_parent_task_id                   NUMBER;
   l_top_task_id                      NUMBER;
   l_display_sequence                 NUMBER;

   l_task_level_above                 PA_TASKS.WBS_LEVEL%TYPE :=0;
   l_task_id_above                    NUMBER;
   l_parent_task_id_above             NUMBER;
   l_top_task_id_above                NUMBER;
   l_display_sequence_above           NUMBER;
   l_new_parent_id                    NUMBER;
   l_new_top_id                       NUMBER;

    CURSOR c1 IS
      select 'x'
      from PA_TASKS
      where project_id = p_project_id
      for update of record_version_number NOWAIT;

    CURSOR c2 IS
      select 'x'
      from PA_TASKS
      where project_id = p_project_id;


    CURSOR cur_task_heirarchy( p_task_id NUMBER )
    IS
      SELECT task_id, wbs_level, record_version_number
        FROM pa_tasks
       START WITH task_id = p_task_id
       CONNECT BY PRIOR task_id = parent_task_id;


    --For updating top task id
    --select all tasks under outdenting task's parent task with display sequence greater than
    --the display sequence of the outdenting task
    CURSOR cur_all_tasks( p_top_task_id NUMBER, p_display_sequence NUMBER )
    IS
     /*SELECT task_id, record_version_number
         FROM pa_tasks
        WHERE top_task_id = p_top_task_id
          AND display_sequence > p_display_sequence;*/

--Project Structure changes
         SELECT pt.task_id, pt.record_version_number
           FROM pa_tasks pt, pa_proj_element_versions ppev
          WHERE top_task_id = p_top_task_id
            AND pt.task_id = ppev.proj_element_id
            AND ppev.display_sequence >= p_display_sequence;  --bug 2968468

    --For updating parent task id
    --All tasks ,that were peer task with outdenting task with larger display order than outdenting task,
    --now becomes children of outdenting task.
    CURSOR cur_new_child_task( p_wbs_level NUMBER, p_display_sequence NUMBER )
    IS
/*      SELECT task_id, record_version_number
        FROM pa_tasks
       WHERE wbs_level = p_wbs_level
         AND parent_task_id = l_parent_task_id
         AND project_id = p_project_id
         AND display_sequence > p_display_sequence;*/

      SELECT pt.task_id, pt.record_version_number
        FROM pa_tasks pt, pa_proj_element_versions ppev
       WHERE pt.wbs_level = p_wbs_level
         AND parent_task_id = l_parent_task_id
         AND pt.project_id = p_project_id
         AND pt.task_id = ppev.proj_element_id
         AND ppev.display_sequence > p_display_sequence;

    CURSOR cur_parent_of_above( p_wbs_level NUMBER, p_top_task_id_above NUMBER )
    IS
      SELECT parent_task_id, top_task_id
        FROM pa_tasks
       WHERE wbs_level = p_wbs_level
         AND project_id = p_project_id
         AND top_task_id = p_top_task_id_above;
 BEGIN

    IF p_commit = FND_API.G_TRUE
    THEN
       SAVEPOINT Edit_Structure;
    END IF;
    x_return_status := 'S';

    PA_TASKS_MAINT_UTILS.GetWbsLevel(
                                 p_project_id           => p_project_id,
                                 p_task_id              => p_task_id,

                                 x_task_level           => l_task_level,
                                 x_parent_task_id       => l_parent_task_id,
                                 x_top_task_id          => l_top_task_id,
                                 x_display_sequence     => l_display_sequence,

                                 x_task_id_above       => l_task_id_above,
                                 x_task_level_above     => l_task_level_above,
                                 x_parent_task_id_above => l_parent_task_id_above,
                                 x_top_task_id_above    => l_top_task_id_above,
                                 x_display_sequence_above => l_display_sequence_above,

                                 x_return_status     => x_return_status,
                                 x_error_msg_code    => x_msg_data );


    --If if the selected task is topmost task then it cannot be outdented.
    IF l_top_task_id = p_task_id OR l_task_level = 1
    THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_TASK_CANNOT_OUTDENT' );
        x_msg_data := 'PA_TASK_CANNOT_OUTDENT';
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE  FND_API.G_EXC_ERROR;
    END IF;

    --If the task above is at lower wbs level
    IF l_task_level_above < l_task_level
    THEN
       --2) update the parent task id of outdenting task with the parent task id of the task above

            PA_TASKS_MAINT_PVT.UPDATE_TASK
              (
              p_commit                            => p_commit
             ,p_validate_only                     => p_validate_only
             ,p_validation_level                  => p_validation_level
             ,p_calling_module                    => p_calling_module
             ,p_debug_mode                        => p_debug_mode

                ,p_project_id                        => p_project_id
                ,p_task_id                           => p_task_id
                ,p_parent_task_id                    => l_parent_task_id_above
                ,p_record_version_number             => p_record_version_number
                ,x_return_status                     => x_return_status
                ,x_msg_count                         => x_msg_count
                ,x_msg_data                          => x_msg_data );

            l_msg_count := FND_MSG_PUB.count_msg;

            IF l_msg_count > 0 THEN
               x_msg_count := l_msg_count;
               x_return_status := 'E';
               RAISE  FND_API.G_EXC_ERROR;
            END IF;

       --1) update wbs level of outdenting task includinf its children

        FOR cur_task_heirarchy_rec IN cur_task_heirarchy( p_task_id ) LOOP

            PA_TASKS_MAINT_PVT.UPDATE_TASK
              (
              p_commit                            => p_commit
             ,p_validate_only                     => p_validate_only
             ,p_validation_level                  => p_validation_level
             ,p_calling_module                    => p_calling_module
             ,p_debug_mode                        => p_debug_mode

                ,p_project_id                        => p_project_id
                ,p_task_id                           => cur_task_heirarchy_rec.task_id
                ,p_wbs_level                         => cur_task_heirarchy_rec.wbs_level - 1
                ,p_record_version_number             => cur_task_heirarchy_rec.record_version_number
                ,x_return_status                     => x_return_status
                ,x_msg_count                         => x_msg_count
                ,x_msg_data                          => x_msg_data );

            l_msg_count := FND_MSG_PUB.count_msg;

            IF l_msg_count > 0 THEN
               x_msg_count := l_msg_count;
               x_return_status := 'E';
               RAISE  FND_API.G_EXC_ERROR;
            END IF;

        END LOOP;


       --3) update top_task id  for all the task including outdenting task that belong to the
       --   to parent task of the outdenting task with display order larger than the outdenting
       --   task.

            --if the outdenting task is going to be the top most task then
            --update the top task ids of outdenting task's new children with outdenting task id.

            IF l_parent_task_id_above IS NULL
            THEN
               FOR cur_all_tasks_rec IN cur_all_tasks( l_top_task_id , l_display_sequence ) LOOP

                  PA_TASKS_MAINT_PVT.UPDATE_TASK
                   (
                      p_commit                            => p_commit
                     ,p_validate_only                     => p_validate_only
                     ,p_validation_level                  => p_validation_level
                     ,p_calling_module                    => p_calling_module
                     ,p_debug_mode                        => p_debug_mode

                     ,p_project_id                        => p_project_id
                     ,p_task_id                           => cur_all_tasks_rec.task_id
                     ,p_top_task_id                       => p_task_id
                     ,p_record_version_number             => cur_all_tasks_rec.record_version_number
                     ,x_return_status                     => x_return_status
                     ,x_msg_count                         => x_msg_count
                     ,x_msg_data                          => x_msg_data );

                  l_msg_count := FND_MSG_PUB.count_msg;

                  IF l_msg_count > 0 THEN
                     x_msg_count := l_msg_count;
                     x_return_status := 'E';
                     RAISE  FND_API.G_EXC_ERROR;
                  END IF;

               END LOOP;
            END IF;

       --4) update the parent task id of all tasks are new children underneath the outdenting task
            --( these new child tasks used to be at the same level before the outdenting task outedented )
            --l_task_level now contains old value of the wbs level.
            FOR cur_new_child_task_rec IN cur_new_child_task( l_task_level, l_display_sequence ) LOOP

                  PA_TASKS_MAINT_PVT.UPDATE_TASK
                   (
                      p_commit                            => p_commit
                     ,p_validate_only                     => p_validate_only
                     ,p_validation_level                  => p_validation_level
                     ,p_calling_module                    => p_calling_module
                     ,p_debug_mode                        => p_debug_mode

                     ,p_project_id                        => p_project_id
                     ,p_task_id                           => cur_new_child_task_rec.task_id
                     ,p_parent_task_id                    => p_task_id
                     ,p_record_version_number             => cur_new_child_task_rec.record_version_number
                     ,x_return_status                     => x_return_status
                     ,x_msg_count                         => x_msg_count
                     ,x_msg_data                          => x_msg_data );

                     l_msg_count := FND_MSG_PUB.count_msg;

                     IF l_msg_count > 0 THEN
                        x_msg_count := l_msg_count;
                        x_return_status := 'E';
                        RAISE  FND_API.G_EXC_ERROR;
                     END IF;

            END LOOP;

    --task above having wbs level greater than the wbs level of outdenting task.
    ELSIF l_task_level_above > l_task_level
    THEN

       --2) update the parent task id and top task id of the outdenting task.

         OPEN cur_parent_of_above( l_task_level - 1, l_top_task_id_above );
         FETCH cur_parent_of_above INTO l_new_parent_id, l_new_top_id;
         CLOSE cur_parent_of_above;

            --The outdenting task may become a child of another task or
            --it may become the top most task in its branch.


            IF l_new_parent_id IS NULL
            THEN
               l_new_top_id := p_task_id;
               l_new_parent_id := null;
            END IF;
            PA_TASKS_MAINT_PVT.UPDATE_TASK
                (
                 p_commit                            => p_commit
                ,p_validate_only                     => p_validate_only
                ,p_validation_level                  => p_validation_level
                ,p_calling_module                    => p_calling_module
                ,p_debug_mode                        => p_debug_mode
                ,p_project_id                        => p_project_id
                ,p_task_id                           => p_task_id
                ,p_parent_task_id                    => l_new_parent_id
                ,p_top_task_id                       => l_new_top_id
                ,p_record_version_number             => p_record_version_number
                ,x_return_status                     => x_return_status
                ,x_msg_count                         => x_msg_count
                ,x_msg_data                          => x_msg_data );

            l_msg_count := FND_MSG_PUB.count_msg;

            IF l_msg_count > 0 THEN
               x_msg_count := l_msg_count;
               x_return_status := 'E';
               RAISE  FND_API.G_EXC_ERROR;
            END IF;


         --1) update wbs level

         FOR cur_task_heirarchy_rec IN cur_task_heirarchy( p_task_id ) LOOP

             PA_TASKS_MAINT_PVT.UPDATE_TASK
              (
              p_commit                            => p_commit
             ,p_validate_only                     => p_validate_only
             ,p_validation_level                  => p_validation_level
             ,p_calling_module                    => p_calling_module
             ,p_debug_mode                        => p_debug_mode

                ,p_project_id                        => p_project_id
                ,p_task_id                           => cur_task_heirarchy_rec.task_id
                ,p_wbs_level                         => cur_task_heirarchy_rec.wbs_level - 1
                ,p_record_version_number             => cur_task_heirarchy_rec.record_version_number
                ,x_return_status                     => x_return_status
                ,x_msg_count                         => x_msg_count
                ,x_msg_data                          => x_msg_data );

            l_msg_count := FND_MSG_PUB.count_msg;

            IF l_msg_count > 0 THEN
               x_msg_count := l_msg_count;
               x_return_status := 'E';
               RAISE  FND_API.G_EXC_ERROR;
            END IF;

         END LOOP;


       --4) update the parent task id of all tasks are new children underneath the outdenting task
            --( these new child tasks used to be at the same level before the outdenting task outedented )
            --l_task_level now contains old value of the wbs level.
            --Also update the top task id for the new children
            FOR cur_new_child_task_rec IN cur_new_child_task( l_task_level, l_display_sequence ) LOOP

                  PA_TASKS_MAINT_PVT.UPDATE_TASK
                   (
                      p_commit                            => p_commit
                     ,p_validate_only                     => p_validate_only
                     ,p_validation_level                  => p_validation_level
                     ,p_calling_module                    => p_calling_module
                     ,p_debug_mode                        => p_debug_mode

                     ,p_project_id                        => p_project_id
                     ,p_task_id                           => cur_new_child_task_rec.task_id
                     ,p_parent_task_id                    => p_task_id
                     ,p_top_task_id                       => l_new_top_id
                     ,p_record_version_number             => cur_new_child_task_rec.record_version_number
                     ,x_return_status                     => x_return_status
                     ,x_msg_count                         => x_msg_count
                     ,x_msg_data                          => x_msg_data );

               l_msg_count := FND_MSG_PUB.count_msg;

               IF l_msg_count > 0 THEN
                  x_msg_count := l_msg_count;
                  x_return_status := 'E';
                  RAISE  FND_API.G_EXC_ERROR;
               END IF;

            END LOOP;

    ELSIF l_task_level_above = l_task_level
    THEN

        -- The outdenting task when outdented IS NOT a topmost task
        IF l_task_level > 2
        THEN

            --1) update the parent task id of the outdenting task.

            --Here the task above and the outdenting task used to be at the same level
            --therefore the parent of, parent of the task above, is the parent of the
            --outdenting task. So pass wbs level as after outdenting.

            OPEN cur_parent_of_above( l_task_level - 1, l_top_task_id_above );
            FETCH cur_parent_of_above INTO l_new_parent_id, l_new_top_id;
            CLOSE cur_parent_of_above;

            --The outdenting task may become a child of another task or
            --it may become the top most task in its branch.

            PA_TASKS_MAINT_PVT.UPDATE_TASK
                (
                 p_commit                            => p_commit
                ,p_validate_only                     => p_validate_only
                ,p_validation_level                  => p_validation_level
                ,p_calling_module                    => p_calling_module
                ,p_debug_mode                        => p_debug_mode
                ,p_project_id                        => p_project_id
                ,p_task_id                           => p_task_id
                ,p_parent_task_id                    => l_new_parent_id
                ,p_record_version_number             => p_record_version_number
                ,x_return_status                     => x_return_status
                ,x_msg_count                         => x_msg_count
                ,x_msg_data                          => x_msg_data );

            l_msg_count := FND_MSG_PUB.count_msg;

            IF l_msg_count > 0 THEN
               x_msg_count := l_msg_count;
               x_return_status := 'E';
               RAISE  FND_API.G_EXC_ERROR;
            END IF;

            --1) update wbs level of outdenting task and its all child tasks
            FOR cur_task_heirarchy_rec IN cur_task_heirarchy( p_task_id ) LOOP

                PA_TASKS_MAINT_PVT.UPDATE_TASK
                  (
                  p_commit                            => p_commit
                 ,p_validate_only                     => p_validate_only
                 ,p_validation_level                  => p_validation_level
                 ,p_calling_module                    => p_calling_module
                 ,p_debug_mode                        => p_debug_mode

                 ,p_project_id                        => p_project_id
                 ,p_task_id                           => cur_task_heirarchy_rec.task_id
                 ,p_wbs_level                         => cur_task_heirarchy_rec.wbs_level - 1
                 ,p_record_version_number             => cur_task_heirarchy_rec.record_version_number
                 ,x_return_status                     => x_return_status
                 ,x_msg_count                         => x_msg_count
                 ,x_msg_data                          => x_msg_data );

                l_msg_count := FND_MSG_PUB.count_msg;

                IF l_msg_count > 0 THEN
                   x_msg_count := l_msg_count;
                   x_return_status := 'E';
                   RAISE  FND_API.G_EXC_ERROR;
                END IF;
            END LOOP;

            --2) updating parent of the new children

            -- update the parent task id of all tasks taht are new children underneath the outdenting task
            --( these new child tasks used to be at the same level before the outdenting task outedented )
            --l_task_level now contains old value of the wbs level.
            FOR cur_new_child_task_rec IN cur_new_child_task( l_task_level, l_display_sequence ) LOOP

                  PA_TASKS_MAINT_PVT.UPDATE_TASK
                   (
                      p_commit                            => p_commit
                     ,p_validate_only                     => p_validate_only
                     ,p_validation_level                  => p_validation_level
                     ,p_calling_module                    => p_calling_module
                     ,p_debug_mode                        => p_debug_mode

                     ,p_project_id                        => p_project_id
                     ,p_task_id                           => cur_new_child_task_rec.task_id
                     ,p_parent_task_id                    => p_task_id
                     ,p_record_version_number             => cur_new_child_task_rec.record_version_number
                     ,x_return_status                     => x_return_status
                     ,x_msg_count                         => x_msg_count
                     ,x_msg_data                          => x_msg_data );

                 l_msg_count := FND_MSG_PUB.count_msg;

                 IF l_msg_count > 0 THEN
                    x_msg_count := l_msg_count;
                    x_return_status := 'E';
                    RAISE  FND_API.G_EXC_ERROR;
                 END IF;

            END LOOP;

        -- The outdenting task becomes the top most task
        ELSIF l_task_level = 2
        THEN
            --1) update parent of outdenting task as null
            PA_TASKS_MAINT_PVT.UPDATE_TASK
                (
                 p_commit                            => p_commit
                ,p_validate_only                     => p_validate_only
                ,p_validation_level                  => p_validation_level
                ,p_calling_module                    => p_calling_module
                ,p_debug_mode                        => p_debug_mode
                ,p_project_id                        => p_project_id
                ,p_task_id                           => p_task_id
                ,p_parent_task_id                    => null

                -- updating the outdenting top task with p_task id
                ,p_top_task_id                       => p_task_id
                ,p_record_version_number             => p_record_version_number
                ,x_return_status                     => x_return_status
                ,x_msg_count                         => x_msg_count
                ,x_msg_data                          => x_msg_data );

              l_msg_count := FND_MSG_PUB.count_msg;

              IF l_msg_count > 0 THEN
                 x_msg_count := l_msg_count;
                 x_return_status := 'E';
                 RAISE  FND_API.G_EXC_ERROR;
              END IF;

            --2) updating parent of the new children

            -- update the parent task id of all tasks taht are new children underneath the outdenting task
            --( these new child tasks used to be at the same level before the outdenting task outedented )
            --l_task_level now contains old value of the wbs level.
            FOR cur_new_child_task_rec IN cur_new_child_task( l_task_level, l_display_sequence ) LOOP

                  PA_TASKS_MAINT_PVT.UPDATE_TASK
                   (
                      p_commit                            => p_commit
                     ,p_validate_only                     => p_validate_only
                     ,p_validation_level                  => p_validation_level
                     ,p_calling_module                    => p_calling_module
                     ,p_debug_mode                        => p_debug_mode

                     ,p_project_id                        => p_project_id
                     ,p_task_id                           => cur_new_child_task_rec.task_id
                     ,p_parent_task_id                    => p_task_id

                      -- updating the new child top tas with p_task id
                     ,p_top_task_id                       => p_task_id
                     ,p_record_version_number             => cur_new_child_task_rec.record_version_number
                     ,x_return_status                     => x_return_status
                     ,x_msg_count                         => x_msg_count
                     ,x_msg_data                          => x_msg_data );

                    l_msg_count := FND_MSG_PUB.count_msg;

                    IF l_msg_count > 0 THEN
                       x_msg_count := l_msg_count;
                       x_return_status := 'E';
                       RAISE  FND_API.G_EXC_ERROR;
                    END IF;

                    --updating top_task_id of child tasks of outdenting task's new child tasks
                    FOR cur_task_heirarchy_rec IN cur_task_heirarchy( cur_new_child_task_rec.task_id ) LOOP
                         PA_TASKS_MAINT_PVT.UPDATE_TASK
                              (
                                  p_commit                            => p_commit
                                 ,p_validate_only                     => p_validate_only
                                 ,p_validation_level                  => p_validation_level
                                 ,p_calling_module                    => p_calling_module
                                 ,p_debug_mode                        => p_debug_mode

                                 ,p_project_id                        => p_project_id
                                 ,p_task_id                           => cur_task_heirarchy_rec.task_id
                                 ,p_top_task_id                       => p_task_id
                                 ,p_record_version_number             => cur_task_heirarchy_rec.record_version_number
                                 ,x_return_status                     => x_return_status
                                 ,x_msg_count                         => x_msg_count
                                 ,x_msg_data                          => x_msg_data );

                          l_msg_count := FND_MSG_PUB.count_msg;

                          IF l_msg_count > 0 THEN
                             x_msg_count := l_msg_count;
                             x_return_status := 'E';
                             RAISE  FND_API.G_EXC_ERROR;
                          END IF;
                    END LOOP;
            END LOOP;

            --1) update wbs level of outdenting task and its all child tasks
            FOR cur_task_heirarchy_rec IN cur_task_heirarchy( p_task_id ) LOOP

                PA_TASKS_MAINT_PVT.UPDATE_TASK
                  (
                  p_commit                            => p_commit
                 ,p_validate_only                     => p_validate_only
                 ,p_validation_level                  => p_validation_level
                 ,p_calling_module                    => p_calling_module
                 ,p_debug_mode                        => p_debug_mode

                 ,p_project_id                        => p_project_id
                 ,p_task_id                           => cur_task_heirarchy_rec.task_id
                 ,p_wbs_level                         => cur_task_heirarchy_rec.wbs_level - 1
                 ,p_record_version_number             => cur_task_heirarchy_rec.record_version_number
                 ,x_return_status                     => x_return_status
                 ,x_msg_count                         => x_msg_count
                 ,x_msg_data                          => x_msg_data );

                 l_msg_count := FND_MSG_PUB.count_msg;
                 IF l_msg_count > 0 THEN
                    x_msg_count := l_msg_count;
                    x_return_status := 'E';
                    RAISE  FND_API.G_EXC_ERROR;
                 END IF;
            END LOOP;


            --3) update the top task id of outdenting task, child tasks of outdenting task , new child tasks
            --   of outdenting task and child tasks of new child tasks with outdenting task id.

            --updating top_task_id of child tasks of outdenting task
            FOR cur_task_heirarchy_rec IN cur_task_heirarchy( p_task_id ) LOOP
                PA_TASKS_MAINT_PVT.UPDATE_TASK
                 (
                 p_commit                            => p_commit
                ,p_validate_only                     => p_validate_only
                ,p_validation_level                  => p_validation_level
                ,p_calling_module                    => p_calling_module
                ,p_debug_mode                        => p_debug_mode

                ,p_project_id                        => p_project_id
                ,p_task_id                           => cur_task_heirarchy_rec.task_id
                ,p_top_task_id                       => p_task_id
                ,p_record_version_number             => cur_task_heirarchy_rec.record_version_number
                ,x_return_status                     => x_return_status
                ,x_msg_count                         => x_msg_count
                ,x_msg_data                          => x_msg_data );

                l_msg_count := FND_MSG_PUB.count_msg;

                IF l_msg_count > 0 THEN
                   x_msg_count := l_msg_count;
                   x_return_status := 'E';
                   RAISE  FND_API.G_EXC_ERROR;
                END IF;
            END LOOP;
        END IF;
    END IF;

  EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Edit_Structure;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_PVT',
                               p_procedure_name => 'Outdent_task',
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
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_PVT',
                               p_procedure_name => 'Outdent_task',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;
 END Outdent_Task;

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
  ,x_msg_data                OUT     NOCOPY VARCHAR2   ) AS --File.Sql.39 bug 4440895

   CURSOR cur_entire_proj
   IS
/*     SELECT *
       FROM pa_tasks pt
      WHERE project_id = p_project_id
        ORDER BY display_sequence;*/

     SELECT pt.task_number, pt.task_name, pt.long_task_name, pt.description, pt.carrying_out_organization_id,
            pt.work_type_id, pt.service_type_code,
            pt.chargeable_flag, pt.billable_flag, pt.receive_project_invoice_flag,
            pt.scheduled_start_date, pt.scheduled_finish_date, pt.start_date,
            pt.wbs_level, pt.task_id, ppev.display_sequence
       FROM pa_tasks pt, pa_proj_element_versions ppev
      WHERE pt.project_id = p_project_id
        AND pt.task_id = ppev.proj_element_id
        ORDER BY ppev.display_sequence;

   CURSOR cur_ref_info
   IS
     SELECT *
       FROM pa_tasks
      WHERE project_id = p_reference_project_id
        AND task_id    = p_reference_task_id;

   CURSOR cur_data_length(c_pa_schema_name  VARCHAR2)
   IS
     SELECT column_name, data_length
       FROM all_tab_columns
      WHERE table_name = 'PA_TASKS'
    AND owner = c_pa_schema_name
        AND column_name IN ( 'TASK_NAME', 'LONG_TASK_NAME', 'TASK_NUMBER' );

   --schema swap changes
   l_table_owner           VARCHAR2(30);
   l_fnd_return_status     BOOLEAN;
   l_fnd_status            VARCHAR2(30);
   l_fnd_industry          VARCHAR2(30);
   --schema swap changes

   l_rec_cur_ref_info cur_ref_info%ROWTYPE;

   l_parent_task_id     NUMBER;
   l_top_task_id        NUMBER;
   l_wbs_level          NUMBER;
   l_option             VARCHAR2(4);
   l_reference_task_id  NUMBER;
   l_max_display        NUMBER;
   l_prev_wbs_level     NUMBER;
   l_task_id            NUMBER;
   l_display_seq        NUMBER;
   l_max_seq            NUMBER;
   l_first_seq          NUMBER;

   l_estimated_start_date    DATE;
   l_estimated_end_date      DATE;

   TYPE CurrTasks IS RECORD( task_id NUMBER(15), wbs_level NUMBER(15),
                             display_sequence NUMBER(15), new_task_id NUMBER(15) );
   TYPE TaskTab IS TABLE OF CurrTasks INDEX BY BINARY_INTEGER;

   l_TaskTab            TaskTab;
   i                    NUMBER := 0;
   k                    NUMBER := 0;
   l_msg_count                        NUMBER;

   l_task_number_len    NUMBER;
   l_task_name_len      NUMBER;
   l_long_task_name_len NUMBER;
   l_column_name        VARCHAR2(30);
   l_data_length        NUMBER;

 BEGIN

      IF p_commit = FND_API.G_TRUE
      THEN
         SAVEPOINT Copy;
      END IF;
      x_return_status := 'S';

      --get the max data length allowed for task_number and task_name from data dictionary
      --This is to make sure that the task_name and task_number does not exceed after
      --appended with prefix.

--schema swap changes
       l_fnd_return_status := FND_INSTALLATION.GET_APP_INFO(
                                   application_short_name => 'PA',
                                   status                 => l_fnd_status,
                                   industry               => l_fnd_industry,
                                   oracle_schema          => l_table_owner);
       IF NOT l_fnd_return_status
       THEN
           fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_PVT',
                                   p_procedure_name => 'Copy_Entire_Project',
                                   p_error_text     => SUBSTRB('FND_INSTALLATION.GET_APP_INFO api call failed:'||SQLERRM,1,240));
           RAISE FND_API.G_EXC_ERROR;
       END IF;
--schema swap changes

      OPEN cur_data_length(l_table_owner);
      LOOP
         FETCH cur_data_length INTO l_column_name, l_data_length;
         IF cur_data_length%FOUND
         THEN
            IF l_column_name = 'TASK_NUMBER'
            THEN
               l_task_number_len := l_data_length;
            ELSIF l_column_name = 'LONG_TASK_NAME'
            THEN
               l_long_task_name_len := l_data_length;
            ELSE
               l_task_name_len   := l_data_length;
            END IF;
         ELSE
            Exit;
         END IF;
      END LOOP;

      OPEN cur_ref_info;
      FETCH  cur_ref_info INTO l_rec_cur_ref_info;
      CLOSE cur_ref_info;

      l_option := p_peer_or_sub;
      l_reference_task_id := p_reference_task_id;

      FOR  cur_entire_proj_rec IN cur_entire_proj LOOP

         IF cur_entire_proj%ROWCOUNT > 1
         THEN
             --Find now the relationship between the next task in the cursor and the previously created task.
             IF cur_entire_proj_rec.wbs_level = l_prev_wbs_level
             THEN
                l_reference_task_id := l_task_id;
                l_option            := 'PEER';
             ELSIF cur_entire_proj_rec.wbs_level > l_prev_wbs_level
             THEN
                l_reference_task_id := l_task_id;
                l_option            := 'SUB';
             ELSE
                --Find the task above the heirarchy at the same level as that of the current task
                --from the matrix.
                --Assign a min value to max display sequence.
                l_max_display := 0;
                k := 1;
                LOOP
                    --Getting the exact display sequence number. It is possible that there could be
                    --more than one task at the same level above.
                    IF l_TaskTab( k ).display_sequence > l_max_display AND
                       l_TaskTab( k ).display_sequence < cur_entire_proj_rec.display_sequence AND
                       l_TaskTab( k ).wbs_level = cur_entire_proj_rec.wbs_level
                    THEN
                       l_max_display := l_TaskTab( k ).display_sequence;
                       l_reference_task_id := l_TaskTab( k ).new_task_id;
                    END IF;
                    IF k = i   -- If there does not exists any record in the matrix.
                    THEN
                       Exit;
                    ELSE
                       k := k + 1;
                    END IF;
                END LOOP;
                l_option            := 'PEER';
             END IF;
         END IF;

         IF l_option = 'PEER' AND
            l_rec_cur_ref_info.wbs_level > 1      ---Not a Top level
         THEN
--Project structure changes. estimated_start_date and estimated_end_date cols do not exist.
--            l_estimated_start_date := cur_entire_proj_rec.estimated_start_date;
--            l_estimated_end_date := cur_entire_proj_rec.estimated_end_date;
            l_estimated_start_date := cur_entire_proj_rec.scheduled_start_date;
            l_estimated_end_date := cur_entire_proj_rec.scheduled_finish_date;
         ELSE --TOP LEVEL PEER task or SUB task.
            l_estimated_start_date := cur_entire_proj_rec.scheduled_start_date;
            l_estimated_end_date := cur_entire_proj_rec.scheduled_finish_date;
         END IF;

         --Write the basic info in the PL/SQL table.
         i := i + 1;
         l_TaskTab( i ).task_id := cur_entire_proj_rec.task_id;
         l_TaskTab( i ).new_task_id := 0;
         l_TaskTab( i ).wbs_level := cur_entire_proj_rec.wbs_level;
         l_TaskTab( i ).display_sequence := cur_entire_proj_rec.display_sequence;

         IF   length( p_task_prefix||cur_entire_proj_rec.task_number ) > l_task_number_len OR
              length( p_task_prefix||cur_entire_proj_rec.task_name ) > l_task_name_len
       OR     length( p_task_prefix||cur_entire_proj_rec.long_task_name ) > l_long_task_name_len
         THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_TASK_PREFIX_TOO_LARGE' );
              x_msg_data := 'PA_TASK_PREFIX_TOO_LARGE';
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              RAISE  FND_API.G_EXC_ERROR;
         END IF;

         PA_TASKS_MAINT_PVT.CREATE_TASK
                      (
                        p_commit                            => p_commit
                       ,p_validate_only                     => p_validate_only
                       ,p_validation_level                  => p_validation_level
                       ,p_calling_module                    => p_calling_module
                       ,p_debug_mode                        => p_debug_mode

                       ,p_project_id                        => p_reference_project_id
                       ,p_reference_task_id                 => l_reference_task_id
                       ,p_peer_or_sub                       => l_option
                       ,p_task_number                       => p_task_prefix||cur_entire_proj_rec.task_number
                       ,p_task_name                         => p_task_prefix||cur_entire_proj_rec.task_name
                       ,p_long_task_name                    => p_task_prefix||cur_entire_proj_rec.long_task_name
                       ,p_task_description                  => cur_entire_proj_rec.description
                       ,p_task_manager_person_id            => null
                       ,p_carrying_out_organization_id      => cur_entire_proj_rec.carrying_out_organization_id
                       --,p_task_type_code                    => cur_entire_proj_rec.task_type_code
                       --,p_priority_code                     => cur_entire_proj_rec.priority_code
                       ,p_work_type_id                      => cur_entire_proj_rec.work_type_id
                       ,p_service_type_code                 => cur_entire_proj_rec.service_type_code
                       --,p_milestone_flag                    => cur_entire_proj_rec.milestone_flag
                       --,p_critical_flag                     => null
                       ,p_chargeable_flag                   => cur_entire_proj_rec.chargeable_flag
                       ,p_billable_flag                     => cur_entire_proj_rec.billable_flag
                       ,p_receive_project_invoice_flag      => cur_entire_proj_rec.receive_project_invoice_flag
                       ,p_scheduled_start_date              => cur_entire_proj_rec.scheduled_start_date
                       ,p_scheduled_finish_date             => cur_entire_proj_rec.scheduled_finish_date
                       ,p_estimated_start_date              => l_estimated_start_date
                       ,p_estimated_end_date                => l_estimated_end_date
                       ,p_actual_start_date                 => null
                       ,p_actual_finish_date                => null
                       ,p_task_start_date                   => cur_entire_proj_rec.start_date
                       --,p_task_completion_date              => cur_entire_proj_rec.end_date
                       ,p_baseline_start_date               => null
                       ,p_baseline_end_date                 => null

                       ,p_estimate_to_complete_work         => null
                       ,p_baseline_work                     => null
                       --,p_scheduled_work                    => cur_entire_proj_rec.scheduled_work
                       ,p_actual_work_to_date               => null
                       ,p_work_unit                         => 'Hours'

                       ,p_task_id                     => l_task_id
                       ,x_display_seq                       => l_display_seq

                       ,x_return_status                     => x_return_status
                       ,x_msg_count                         => x_msg_count
                       ,x_msg_data                          => x_msg_data  );

             l_prev_wbs_level := cur_entire_proj_rec.wbs_level;
             l_TaskTab( i ).new_task_id := l_task_id;

             IF cur_entire_proj%ROWCOUNT = 1
             THEN
                --capture the first sequence created.
                l_first_seq := l_display_seq;
             END IF;

            l_msg_count := FND_MSG_PUB.count_msg;

            IF l_msg_count > 0 THEN
               x_msg_count := l_msg_count;
               x_return_status := 'E';
               RAISE  FND_API.G_EXC_ERROR;
            END IF;


      END LOOP;

/*      --Call Update statement to update display order

      ************************************************************
       THIS FUNCTIONALITY IS MOVED TO PA_TASK_PUB1.COPY_TASK API.
      ************************************************************
      BEGIN
          -- Need to get max number
          SELECT max(display_sequence)
            INTO l_max_seq
            FROM PA_TASKS
           WHERE project_id = p_reference_project_id;

          UPDATE PA_TASKS
             SET display_sequence =
                 PA_TASKS_MAINT_UTILS.REARRANGE_DISPLAY_SEQ(display_sequence, l_max_seq, i, 'INSERT', null),
                 record_version_number = record_version_number + 1
           WHERE project_id = p_reference_project_id
             AND ( display_sequence > -( l_first_seq + 1 ) or display_sequence < 0 );
      EXCEPTION
         WHEN OTHERS THEN
              PA_UTILS.ADD_MESSAGE('PA', 'PA_TASK_SEQ_NUM_ERR');
              RAISE FND_API.G_EXC_ERROR;
      END; */

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Copy;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_PVT',
                               p_procedure_name => 'Copy_Entire_Task',
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
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_PVT',
                               p_procedure_name => 'Copy_Entire_Task',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;
 END Copy_Entire_Project;

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
  ,x_msg_data                OUT     NOCOPY VARCHAR2   ) AS --File.Sql.39 bug 4440895

  CURSOR cur_select_task
   IS
     SELECT *
       FROM pa_tasks
      WHERE task_id = p_task_id;

   CURSOR cur_ref_info
   IS
     SELECT *
       FROM pa_tasks
      WHERE project_id = p_reference_project_id
        AND task_id    = p_reference_task_id;

   CURSOR cur_data_length(c_pa_schema_name  VARCHAR2)
   IS
     SELECT column_name, data_length
       FROM all_tab_columns
      WHERE table_name = 'PA_TASKS'
        AND owner = c_pa_schema_name
        AND column_name IN ( 'TASK_NAME', 'LONG_TASK_NAME', 'TASK_NUMBER' );

   --schema swap changes
   l_table_owner           VARCHAR2(30);
   l_fnd_return_status     BOOLEAN;
   l_fnd_status            VARCHAR2(30);
   l_fnd_industry          VARCHAR2(30);
   --schema swap changes

   l_rec_cur_ref_info cur_ref_info%ROWTYPE;

   l_parent_task_id     NUMBER;
   l_top_task_id        NUMBER;
   l_wbs_level          NUMBER;
   l_task_id            NUMBER;
   l_display_seq        NUMBER;
   l_max_seq            NUMBER;

   l_estimated_start_date    DATE;
   l_estimated_end_date      DATE;
   l_msg_count                        NUMBER;

   l_task_number_len    NUMBER;
   l_task_name_len      NUMBER;
   l_long_task_name_len NUMBER;
   l_column_name        VARCHAR2(30);
   l_data_length        NUMBER;

 BEGIN
      IF p_commit = FND_API.G_TRUE
      THEN
         SAVEPOINT Copy;
      END IF;
      x_return_status := 'S';

      --get the max data length allowed for task_number and task_name from data dictionary
      --This is to make sure that the task_name and task_number does not exceed after
      --appended with prefix.

--schema swap changes
       l_fnd_return_status := FND_INSTALLATION.GET_APP_INFO(
                                   application_short_name => 'PA',
                                   status                 => l_fnd_status,
                                   industry               => l_fnd_industry,
                                   oracle_schema          => l_table_owner);
       IF NOT l_fnd_return_status
       THEN
           fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_PVT',
                                   p_procedure_name => 'Copy_Entire_Project',
                                   p_error_text     => SUBSTRB('FND_INSTALLATION.GET_APP_INFO api call failed:'||SQLERRM,1,240));
           RAISE FND_API.G_EXC_ERROR;
       END IF;
--schema swap changes

      OPEN cur_data_length(l_table_owner);
      LOOP
         FETCH cur_data_length INTO l_column_name, l_data_length;
         IF cur_data_length%FOUND
         THEN
            IF l_column_name = 'TASK_NUMBER'
            THEN
               l_task_number_len := l_data_length;
            ELSIF l_column_name = 'LONG_TASK_NAME'
            THEN
               l_long_task_name_len := l_data_length;
            ELSE
               l_task_name_len   := l_data_length;
            END IF;
         ELSE
            Exit;
         END IF;
      END LOOP;

      OPEN cur_ref_info;
      FETCH  cur_ref_info INTO l_rec_cur_ref_info;
      CLOSE cur_ref_info;

      -- Only a single task is going to be inserted in this for-loop cursor
      FOR  cur_select_task_rec IN cur_select_task LOOP

         IF p_peer_or_sub = 'PEER' AND
            l_rec_cur_ref_info.wbs_level > 1      ---Not a Top level
         THEN
            --l_estimated_start_date := cur_select_task_rec.estimated_start_date;
            --l_estimated_end_date := cur_select_task_rec.estimated_end_date;
            l_estimated_start_date := cur_select_task_rec.scheduled_start_date;
            l_estimated_end_date := cur_select_task_rec.scheduled_finish_date;
         ELSE --TOP LEVEL PEER task or SUB task.
            l_estimated_start_date := cur_select_task_rec.scheduled_start_date;
            l_estimated_end_date := cur_select_task_rec.scheduled_finish_date;
         END IF;

         IF   length( p_task_prefix||cur_select_task_rec.task_number ) > l_task_number_len OR
              length( p_task_prefix||cur_select_task_rec.task_name ) > l_task_name_len OR
              length( p_task_prefix||cur_select_task_rec.long_task_name ) > l_long_task_name_len
         THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_TASK_PREFIX_TOO_LARGE' );
              x_msg_data := 'PA_TASK_PREFIX_TOO_LARGE';
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              RAISE  FND_API.G_EXC_ERROR;
         END IF;

         PA_TASKS_MAINT_PVT.CREATE_TASK
                      (
                        p_commit                            => p_commit
                       ,p_validate_only                     => p_validate_only
                       ,p_validation_level                  => p_validation_level
                       ,p_calling_module                    => p_calling_module
                       ,p_debug_mode                        => p_debug_mode

                       ,p_project_id                        => p_reference_project_id
                       ,p_reference_task_id                 => p_reference_task_id
                       ,p_peer_or_sub                       => p_peer_or_sub
                       ,p_task_number                       => p_task_prefix||cur_select_task_rec.task_number
                       ,p_task_name                         => p_task_prefix||cur_select_task_rec.task_name
                       ,p_long_task_name                    => p_task_prefix||cur_select_task_rec.long_task_name
                       ,p_task_description                  => cur_select_task_rec.description
                       ,p_task_manager_person_id            => null
                       ,p_carrying_out_organization_id      => cur_select_task_rec.carrying_out_organization_id
                       --,p_task_type_code                    => cur_select_task_rec.task_type_code
                       --,p_priority_code                     => cur_select_task_rec.priority_code
                       ,p_work_type_id                      => cur_select_task_rec.work_type_id
                       ,p_service_type_code                 => cur_select_task_rec.service_type_code
                       --,p_milestone_flag                    => cur_select_task_rec.milestone_flag
                       --,p_critical_flag                     => null
                       ,p_chargeable_flag                   => cur_select_task_rec.chargeable_flag
                       ,p_billable_flag                     => cur_select_task_rec.billable_flag
                       ,p_receive_project_invoice_flag      => cur_select_task_rec.receive_project_invoice_flag
                       ,p_scheduled_start_date              => cur_select_task_rec.scheduled_start_date
                       ,p_scheduled_finish_date             => cur_select_task_rec.scheduled_finish_date
                       ,p_estimated_start_date              => l_estimated_start_date
                       ,p_estimated_end_date                => l_estimated_end_date
                       ,p_actual_start_date                 => null
                       ,p_actual_finish_date                => null
                       ,p_task_start_date                   => cur_select_task_rec.start_date
                       --,p_task_completion_date              => cur_select_task_rec.end_date
                       ,p_baseline_start_date               => null
                       ,p_baseline_end_date                 => null

                       ,p_estimate_to_complete_work         => null
                       ,p_baseline_work                     => null
--                       ,p_scheduled_work                    => cur_select_task_rec.scheduled_work
                       ,p_actual_work_to_date               => null
                       ,p_work_unit                         => 'Hours'

                       ,p_task_id                     => l_task_id
                       ,x_display_seq                       => l_display_seq

                       ,x_return_status                     => x_return_status
                       ,x_msg_count                         => x_msg_count
                       ,x_msg_data                          => x_msg_data  );

            l_msg_count := FND_MSG_PUB.count_msg;

            IF l_msg_count > 0 THEN
               x_msg_count := l_msg_count;
               x_return_status := 'E';
               RAISE  FND_API.G_EXC_ERROR;
            END IF;

      END LOOP;

/*
      --Call Update statement to update display order

      ************************************************************
       THIS FUNCTIONALITY IS MOVED IN PA_TASK_PUB1.COPY_TASK API.
      ************************************************************

      BEGIN
          -- Need to get max number
          SELECT max(display_sequence)
            INTO l_max_seq
            FROM PA_TASKS
           WHERE project_id = p_reference_project_id;

          UPDATE PA_TASKS
             SET display_sequence =
                 PA_TASKS_MAINT_UTILS.REARRANGE_DISPLAY_SEQ(display_sequence, l_max_seq, 1, 'INSERT', null),
                 record_version_number = record_version_number + 1
           WHERE project_id = p_reference_project_id
             AND ( display_sequence > -( l_display_seq + 1 ) or display_sequence < 0 );
      EXCEPTION
         WHEN OTHERS THEN
              PA_UTILS.ADD_MESSAGE('PA', 'PA_TASK_SEQ_NUM_ERR');
              RAISE FND_API.G_EXC_ERROR;
      END;*/

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Copy;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_PVT',
                               p_procedure_name => 'Copy_Selected_Task',
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
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_PVT',
                               p_procedure_name => 'Copy_Selected_Task',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;
 END Copy_Selected_Task;

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
  ,x_msg_data                OUT     NOCOPY VARCHAR2   ) AS --File.Sql.39 bug 4440895

   CURSOR cur_entire_task
   IS

     /*SELECT *
       FROM pa_tasks
      WHERE project_id = p_project_id
     START WITH task_id = p_task_id
     CONNECT BY PRIOR task_id = parent_task_id
     ORDER BY display_sequence; */

    SELECT pt.task_number, pt.task_name, pt.long_task_name, pt.description, pt.carrying_out_organization_id,
            pt.work_type_id, pt.service_type_code,
            pt.chargeable_flag, pt.billable_flag, pt.receive_project_invoice_flag,
            pt.scheduled_start_date, pt.scheduled_finish_date, pt.start_date,
            pt.wbs_level, pt.task_id, ppev.display_sequence
      FROM
     ( SELECT task_id, task_number, task_name, long_task_name, description,carrying_out_organization_id,
              work_type_id, service_type_code,
              chargeable_flag, billable_flag, receive_project_invoice_flag,
              scheduled_start_date, scheduled_finish_date, start_date,
              wbs_level
         FROM pa_tasks
        WHERE project_id = p_project_id
      START WITH task_id = p_task_id
      CONNECT BY PRIOR task_id = parent_task_id ) pt,
                         pa_proj_element_versions ppev
     WHERE pt.task_id = ppev.proj_element_id
     ORDER BY ppev.display_sequence;

   CURSOR cur_ref_info
   IS
     SELECT *
       FROM pa_tasks
      WHERE project_id = p_reference_project_id
        AND task_id    = p_reference_task_id;

   CURSOR cur_data_length(c_pa_schema_name  VARCHAR2)
   IS
     SELECT column_name, data_length
       FROM all_tab_columns
      WHERE table_name = 'PA_TASKS'
    AND owner = c_pa_schema_name
        AND column_name IN ( 'TASK_NAME', 'LONG_TASK_NAME', 'TASK_NUMBER' );

   --schema swap changes
   l_table_owner           VARCHAR2(30);
   l_fnd_return_status     BOOLEAN;
   l_fnd_status            VARCHAR2(30);
   l_fnd_industry          VARCHAR2(30);
   --schema swap changes

   l_rec_cur_ref_info cur_ref_info%ROWTYPE;

   l_parent_task_id     NUMBER;
   l_top_task_id        NUMBER;
   l_wbs_level          NUMBER;
   l_option             VARCHAR2(4);
   l_reference_task_id  NUMBER;
   l_max_display        NUMBER;
   l_prev_wbs_level     NUMBER;
   l_task_id            NUMBER;
   l_display_seq        NUMBER;
   l_max_seq            NUMBER;
   l_first_seq          NUMBER;

   l_estimated_start_date    DATE;
   l_estimated_end_date      DATE;

   TYPE CurrTasks IS RECORD( task_id NUMBER(15), wbs_level NUMBER(15),
                             display_sequence NUMBER(15), new_task_id NUMBER(15) );
   TYPE TaskTab IS TABLE OF CurrTasks INDEX BY BINARY_INTEGER;

   l_TaskTab            TaskTab;
   i                    NUMBER := 0;
   k                    NUMBER := 0;
   l_msg_count                        NUMBER;

   l_task_number_len    NUMBER;
   l_task_name_len      NUMBER;
   l_long_task_name_len NUMBER;
   l_column_name        VARCHAR2(30);
   l_data_length        NUMBER;

 BEGIN

      IF p_commit = FND_API.G_TRUE
      THEN
         SAVEPOINT Copy;
      END IF;
      x_return_status := 'S';

      --get the max data length allowed for task_number and task_name from data dictionary
      --This is to make sure that the task_name and task_number does not exceed after
      --appended with prefix.

--schema swap changes
       l_fnd_return_status := FND_INSTALLATION.GET_APP_INFO(
                                   application_short_name => 'PA',
                                   status                 => l_fnd_status,
                                   industry               => l_fnd_industry,
                                   oracle_schema          => l_table_owner);
       IF NOT l_fnd_return_status
       THEN
           fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_PVT',
                                   p_procedure_name => 'Copy_Entire_Project',
                                   p_error_text     => SUBSTRB('FND_INSTALLATION.GET_APP_INFO api call failed:'||SQLERRM,1,240));
           RAISE FND_API.G_EXC_ERROR;
       END IF;
--schema swap changes

      OPEN cur_data_length(l_table_owner);
      LOOP
         FETCH cur_data_length INTO l_column_name, l_data_length;
         IF cur_data_length%FOUND
         THEN
            IF l_column_name = 'TASK_NUMBER'
            THEN
               l_task_number_len := l_data_length;
            ELSIF l_column_name = 'LONG_TASK_NAME'
            THEN
               l_long_task_name_len := l_data_length;
            ELSE
               l_task_name_len   := l_data_length;
            END IF;
         ELSE
            Exit;
         END IF;
      END LOOP;

      OPEN cur_ref_info;
      FETCH  cur_ref_info INTO l_rec_cur_ref_info;
      CLOSE cur_ref_info;

      l_option := p_peer_or_sub;
      l_reference_task_id := p_reference_task_id;

      FOR  cur_entire_task_rec IN cur_entire_task LOOP

         IF cur_entire_task%ROWCOUNT > 1
         THEN
             --Find now the relationship between the next task in the cursor and the previously created task.
             IF cur_entire_task_rec.wbs_level = l_prev_wbs_level
             THEN
                l_reference_task_id := l_task_id;
                l_option            := 'PEER';
             ELSIF cur_entire_task_rec.wbs_level > l_prev_wbs_level
             THEN
                l_reference_task_id := l_task_id;
                l_option            := 'SUB';
             ELSE
                --Find the task above the heirarchy at the same level as that of the current task
                --from the matrix.
                --Assign a min value to max display sequence.
                l_max_display := 0;
                k := 1;
                LOOP
                    --Getting the exact display sequence number. It is possible that there could be
                    --more than one task at the same level above.
                    IF l_TaskTab( k ).display_sequence > l_max_display AND
                       l_TaskTab( k ).display_sequence < cur_entire_task_rec.display_sequence AND
                       l_TaskTab( k ).wbs_level = cur_entire_task_rec.wbs_level
                    THEN
                       l_max_display := l_TaskTab( k ).display_sequence;
                       l_reference_task_id := l_TaskTab( k ).new_task_id;
                    END IF;
                    IF k = i   -- If there does not exists any record in the matrix.
                    THEN
                       Exit;
                    ELSE
                       k := k + 1;
                    END IF;
                END LOOP;
                l_option            := 'PEER';
             END IF;
         END IF;


         IF l_option = 'PEER' AND
            l_rec_cur_ref_info.wbs_level > 1      ---Not a Top level
         THEN
            --l_estimated_start_date := cur_entire_task_rec.estimated_start_date;
            --l_estimated_end_date := cur_entire_task_rec.estimated_end_date;
            l_estimated_start_date := cur_entire_task_rec.scheduled_start_date;
            l_estimated_end_date := cur_entire_task_rec.scheduled_finish_date;
         ELSE --TOP LEVEL PEER task or SUB task.
            l_estimated_start_date := cur_entire_task_rec.scheduled_start_date;
            l_estimated_end_date := cur_entire_task_rec.scheduled_finish_date;
         END IF;

         --Write the basic info in the PL/SQL table.
         i := i + 1;
         l_TaskTab( i ).task_id := cur_entire_task_rec.task_id;
         l_TaskTab( i ).new_task_id := 0;
         l_TaskTab( i ).wbs_level := cur_entire_task_rec.wbs_level;
         l_TaskTab( i ).display_sequence := cur_entire_task_rec.display_sequence;

         IF   length( p_task_prefix||cur_entire_task_rec.task_number ) > l_task_number_len OR
              length( p_task_prefix||cur_entire_task_rec.task_name ) > l_task_name_len OR
              length( p_task_prefix||cur_entire_task_rec.long_task_name) > l_long_task_name_len
         THEN
              PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                                   p_msg_name       => 'PA_TASK_PREFIX_TOO_LARGE' );
              x_msg_data := 'PA_TASK_PREFIX_TOO_LARGE';
              x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
              RAISE  FND_API.G_EXC_ERROR;
         END IF;

         PA_TASKS_MAINT_PVT.CREATE_TASK
                      (
                        p_commit                            => p_commit
                       ,p_validate_only                     => p_validate_only
                       ,p_validation_level                  => p_validation_level
                       ,p_calling_module                    => p_calling_module
                       ,p_debug_mode                        => p_debug_mode

                       ,p_project_id                        => p_reference_project_id
                       ,p_reference_task_id                 => l_reference_task_id
                       ,p_peer_or_sub                       => l_option
                       ,p_task_number                       => p_task_prefix||cur_entire_task_rec.task_number
                       ,p_task_name                         => p_task_prefix||cur_entire_task_rec.task_name
                       ,p_long_task_name                    => p_task_prefix||cur_entire_task_rec.long_task_name
                       ,p_task_description                  => cur_entire_task_rec.description
                       ,p_task_manager_person_id            => null
                       ,p_carrying_out_organization_id      => cur_entire_task_rec.carrying_out_organization_id
                       --,p_task_type_code                    => cur_entire_task_rec.task_type_code
                       --,p_priority_code                     => cur_entire_task_rec.priority_code
                       ,p_work_type_id                      => cur_entire_task_rec.work_type_id
                       ,p_service_type_code                 => cur_entire_task_rec.service_type_code
                       --,p_milestone_flag                    => cur_entire_task_rec.milestone_flag
                       --,p_critical_flag                     => null
                       ,p_chargeable_flag                   => cur_entire_task_rec.chargeable_flag
                       ,p_billable_flag                     => cur_entire_task_rec.billable_flag
                       ,p_receive_project_invoice_flag      => cur_entire_task_rec.receive_project_invoice_flag
                       ,p_scheduled_start_date              => cur_entire_task_rec.scheduled_start_date
                       ,p_scheduled_finish_date             => cur_entire_task_rec.scheduled_finish_date
                       ,p_estimated_start_date              => l_estimated_start_date
                       ,p_estimated_end_date                => l_estimated_end_date
                       ,p_actual_start_date                 => null
                       ,p_actual_finish_date                => null
                       ,p_task_start_date                   => cur_entire_task_rec.start_date
                       --,p_task_completion_date              => cur_entire_task_rec.end_date
                       ,p_baseline_start_date               => null
                       ,p_baseline_end_date                 => null

                       ,p_estimate_to_complete_work         => null
                       ,p_baseline_work                     => null
--                       ,p_scheduled_work                    => cur_entire_task_rec.scheduled_work
                       ,p_actual_work_to_date               => null
                       ,p_work_unit                         => 'Hours'

                       ,p_task_id                     => l_task_id
                       ,x_display_seq                       => l_display_seq

                       ,x_return_status                     => x_return_status
                       ,x_msg_count                         => x_msg_count
                       ,x_msg_data                          => x_msg_data  );

             l_prev_wbs_level := cur_entire_task_rec.wbs_level;
             l_TaskTab( i ).new_task_id := l_task_id;

             IF cur_entire_task%ROWCOUNT = 1
             THEN
                --capture the first sequence created.
                l_first_seq := l_display_seq;
             END IF;


            l_msg_count := FND_MSG_PUB.count_msg;

            IF l_msg_count > 0 THEN
               x_msg_count := l_msg_count;
               x_return_status := 'E';
               RAISE  FND_API.G_EXC_ERROR;
            END IF;

      END LOOP;

/*
      --Call Update statement to update display order

      ************************************************************
       THIS FUNCTIONALITY IS MOVED IN PA_TASK_PUB1.COPY_TASK API.
      ************************************************************

      BEGIN
          -- Need to get max number
          SELECT max(display_sequence)
            INTO l_max_seq
            FROM PA_TASKS
           WHERE project_id = p_reference_project_id;

          UPDATE PA_TASKS
             SET display_sequence =
                 PA_TASKS_MAINT_UTILS.REARRANGE_DISPLAY_SEQ(display_sequence, l_max_seq, i, 'INSERT', null),
                 record_version_number = record_version_number + 1
           WHERE project_id = p_reference_project_id
             AND ( display_sequence > -( l_first_seq + 1 ) or display_sequence < 0 );
      EXCEPTION
         WHEN OTHERS THEN
              PA_UTILS.ADD_MESSAGE('PA', 'PA_TASK_SEQ_NUM_ERR');
              RAISE FND_API.G_EXC_ERROR;
      END; */

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Copy;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_PVT',
                               p_procedure_name => 'Copy_Entire_Task',
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
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_PVT',
                               p_procedure_name => 'Copy_Entire_Task',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;

 END Copy_Entire_Task;


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
   ,x_msg_data                          OUT NOCOPY VARCHAR2 ) AS --File.Sql.39 bug 4440895

   CURSOR cur_tasks
   IS
/*     SELECT task_id, display_sequence, top_task_id, parent_task_id, wbs_level, record_version_number
       FROM pa_tasks
      WHERE project_id = p_project_id
        START WITH task_id = p_task_id
        CONNECT BY PRIOR task_id = parent_task_id
     ORDER BY display_sequence;*/

     SELECT pt.task_id, ppev.display_sequence, pt.top_task_id, pt.parent_task_id, pt.wbs_level, pt.record_version_number
       FROM
     ( SELECT task_id, top_task_id, parent_task_id, wbs_level, record_version_number
         FROM pa_tasks
        WHERE project_id = p_project_id
          START WITH task_id = p_task_id
          CONNECT BY PRIOR task_id = parent_task_id ) pt, pa_proj_element_versions ppev
      WHERE pt.task_id = ppev.proj_element_id
      ORDER BY ppev.display_sequence;

   CURSOR cur_ref_info
   IS
/*     SELECT *
       FROM pa_tasks
      WHERE project_id = p_reference_project_id
        START WITH task_id    = p_reference_task_id
        CONNECT BY PRIOR task_id = parent_task_id
      ORDER BY display_sequence;*/

     SELECT pt.top_task_id, pt.parent_task_id, pt.wbs_level, ppev.display_sequence
       FROM
     ( SELECT  task_id, top_task_id, parent_task_id, wbs_level
         FROM pa_tasks
        WHERE project_id = p_reference_project_id
          START WITH task_id    = p_reference_task_id
          CONNECT BY PRIOR task_id = parent_task_id ) pt, pa_proj_element_versions ppev
       WHERE pt.task_id = ppev.proj_element_id
      ORDER BY ppev.display_sequence;


   l_rec_cur_ref_info cur_ref_info%ROWTYPE;

   l_top_level_task_flag      VARCHAR2(1) := 'N';

   l_max_seq                  NUMBER;
   i                          NUMBER;

   l_top_task_id              NUMBER;
   l_parent_task_id           NUMBER;
   l_wbs_level                NUMBER;
   l_display_sequence         NUMBER;

   l_ref_top_task_id          NUMBER;
   l_ref_parent_task_id       NUMBER;
   l_ref_wbs_level            NUMBER;
   l_ref_display_sequence     NUMBER;

   l_above_top_task_id        NUMBER;
   l_above_parent_task_id     NUMBER;
   l_above_wbs_level          NUMBER;
   l_above_display_sequence   NUMBER;

   l_ref_child_tasks_num      NUMBER := 0;

   l_lowest_moving_wbs_level  NUMBER;
   l_move_direction           VARCHAR2(4);
   l_min_display_sequence     NUMBER;
   l_max_display_sequence     NUMBER;
   l_above_child_tasks_num    NUMBER;
   l_reference_sequence       NUMBER;

   l_return_status                    VARCHAR2(1);
   l_error_msg_code                   VARCHAR2(250);
   l_msg_count                        NUMBER;

-- 23-JUL-2001 Added by HSIU
    l_err_code                           NUMBER                 := 0;
    l_err_stack                          VARCHAR2(630);
    l_err_stage                          VARCHAR2(80); -- VARCHAR2(80)

 BEGIN

      x_return_status:= FND_API.G_RET_STS_SUCCESS;

--dbms_output.put_line( 'In move task 0' );

      --Ref project and task id Required check.
      PA_TASKS_MAINT_UTILS.REF_PRJ_TASK_ID_REQ_CHECK(
                               p_reference_project_id      => p_reference_project_id,
                               p_reference_task_id         => p_reference_task_id,
                               x_return_status           => l_return_status,
                               x_error_msg_code            => l_error_msg_code );

      IF l_return_status = FND_API.G_RET_STS_ERROR
      THEN
         PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                              p_msg_name       => l_error_msg_code);
         x_msg_data := l_error_msg_code;
         x_return_status := 'E';
         RAISE  FND_API.G_EXC_ERROR;
      END IF;

--dbms_output.put_line( 'In move task 1' );

      --project and task id Required check.
      PA_TASKS_MAINT_UTILS.SRC_PRJ_TASK_ID_REQ_CHECK(
                             p_project_id      => p_project_id,
                             p_task_id         => p_task_id,
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
--dbms_output.put_line( 'In move task 2' );


      IF p_reference_project_id <> p_project_id
      THEN
        PA_UTILS.ADD_MESSAGE(p_app_short_name => 'PA',
                             p_msg_name       => 'PA_TASK_MOV_NOT_ALLOWED' );
        x_msg_data := 'PA_TASK_MOV_NOT_ALLOWED';
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        RAISE  FND_API.G_EXC_ERROR;
      END IF;

--dbms_output.put_line( 'In move task 3' );


      FOR l_rec_cur_ref_info IN cur_ref_info LOOP
         IF cur_ref_info%ROWCOUNT = 1
         THEN
             --store attributes of the first ref task itself
             l_ref_top_task_id         := l_rec_cur_ref_info.top_task_id;
             l_ref_parent_task_id      := l_rec_cur_ref_info.parent_task_id;
             l_ref_wbs_level           := l_rec_cur_ref_info.wbs_level;
             l_ref_display_sequence    := l_rec_cur_ref_info.display_sequence;

             --If only one record exists then both set of variables will hold the same value.
             l_above_top_task_id         := l_rec_cur_ref_info.top_task_id;
             l_above_parent_task_id      := l_rec_cur_ref_info.parent_task_id;
             l_above_wbs_level           := l_rec_cur_ref_info.wbs_level;
             l_above_display_sequence    := l_rec_cur_ref_info.display_sequence;
         ELSE
             --store attributes of the last child in the ref task heir.
             l_above_top_task_id         := l_rec_cur_ref_info.top_task_id;
             l_above_parent_task_id      := l_rec_cur_ref_info.parent_task_id;
             l_above_wbs_level           := l_rec_cur_ref_info.wbs_level;
             l_above_display_sequence    := l_rec_cur_ref_info.display_sequence;
         END IF;
         --no of children underneath the ref tasks
         l_above_child_tasks_num := l_above_child_tasks_num + 1;
      END LOOP;

--dbms_output.put_line( 'In move task 4' );


      IF l_ref_wbs_level = 1 AND
         p_peer_or_sub = 'PEER'
      THEN
         l_top_level_task_flag := 'Y';
      ELSE
         l_top_task_id := l_ref_top_task_id;
         IF p_peer_or_sub = 'PEER'
         THEN
            l_parent_task_id := l_ref_parent_task_id;
         ELSE
            -- 23-JUL-2001
            -- Added by HSIU--check if the reference task can have child tasks
          PA_TASK_UTILS.CHECK_CREATE_SUBTASK_OK(x_task_id => p_reference_task_id,
               x_err_code => l_err_code,
               x_err_stack => l_err_stack,
               x_err_stage => l_err_stage
            );
            IF (l_err_code <> 0) THEN
               PA_UTILS.ADD_MESSAGE('PA', substr(l_err_stage,1,30));
            END IF;
            -- HSIU changes ends here

            l_parent_task_id := p_reference_task_id;
         END IF;
      END IF;
      i := 0;

--dbms_output.put_line( 'In move task 5' );

      FOR cur_tasks_rec IN cur_tasks LOOP

          IF cur_tasks%ROWCOUNT = 1
          THEN
             l_lowest_moving_wbs_level := cur_tasks_rec.wbs_level;

             --make the top task for p_task and its children as p_task
             IF l_top_level_task_flag = 'Y'
             THEN
                l_top_task_id := cur_tasks_rec.task_id;
                l_parent_task_id := null;                  --This is only for the first task in the moving tasks set.
             END IF;

             --Set the move direction and boundaries for the sequence number update
             IF p_peer_or_sub = 'PEER'
             THEN
                l_reference_sequence := l_above_display_sequence;
             ELSE
                l_reference_sequence := l_ref_display_sequence;
             END IF;
             IF cur_tasks_rec.display_sequence < l_reference_sequence
             THEN
                l_move_direction := 'DOWN';
                l_min_display_sequence := cur_tasks_rec.display_sequence;
                IF p_peer_or_sub = 'PEER'
                THEN
                   l_max_display_sequence := l_above_display_sequence ;
                ELSE
                   l_max_display_sequence := l_ref_display_sequence ;
                END IF;
             ELSIF cur_tasks_rec.display_sequence > l_reference_sequence
             THEN
                l_move_direction := 'UP';
                IF p_peer_or_sub = 'PEER'
                THEN
                   l_min_display_sequence := l_above_display_sequence;
                ELSE
                   l_min_display_sequence := l_ref_display_sequence;
                END IF;
                l_max_display_sequence := cur_tasks_rec.display_sequence;  --add the total tasks added
             ELSE
             --otherwise no change in the display sequence.
               null;
             END IF;

          ELSE
             --Parent task id for all other except the first task remains same
             l_parent_task_id := cur_tasks_rec.parent_task_id;
          END IF;

          i := i + 1;       --counting no. of moving tasks

          --initialize the wbs level of the moving tasks starting from 1
          l_wbs_level := cur_tasks_rec.wbs_level - l_lowest_moving_wbs_level + 1;

          IF p_peer_or_sub = 'PEER'
          THEN
             --creating -ve sequence numbers.
             --moving after all child tasks of the ref task
             l_display_sequence :=   -( l_above_display_sequence + i ) ;

             l_wbs_level := l_wbs_level + ( l_ref_wbs_level - 1 );
          ELSE
             l_wbs_level := l_wbs_level + l_ref_wbs_level ;
             --creating -ve sequence numbers.
             --moving immediately after ref task
             l_display_sequence :=   -( l_ref_display_sequence + i ) ;
          END IF;

          --dbms_output.put_line( 'Before update task ' );
           PA_TASKS_MAINT_PVT.UPDATE_TASK
                   (
                      p_commit                            => p_commit
                     ,p_validate_only                     => p_validate_only
                     ,p_validation_level                  => p_validation_level
                     ,p_calling_module                    => p_calling_module
                     ,p_debug_mode                        => p_debug_mode

                     ,p_project_id                        => p_reference_project_id
                     ,p_task_id                           => cur_tasks_rec.task_id

                     ,p_parent_task_id                    => l_parent_task_id
                     ,p_top_task_id                       => l_top_task_id
                     ,p_wbs_level                         => l_wbs_level
                     ,p_display_sequence                  => l_display_sequence

                     ,p_record_version_number             => cur_tasks_rec.record_version_number
                     ,x_return_status                     => x_return_status
                     ,x_msg_count                         => x_msg_count
                     ,x_msg_data                          => x_msg_data );

            l_msg_count := FND_MSG_PUB.count_msg;

            IF l_msg_count > 0 THEN
               x_msg_count := l_msg_count;
               x_return_status := 'E';
               x_msg_data := x_msg_data;
          --dbms_output.put_line( 'x_msg_data in update task  '||x_msg_data );

               RAISE  FND_API.G_EXC_ERROR;
            END IF;

      END LOOP;

--dbms_output.put_line( 'In move task 6' );

      -- update chargeable flag for reference task to no.
      IF (Pa_Task_Utils.check_child_Exists(NVL(p_reference_task_id,0)) = 1 ) THEN
        UPDATE Pa_tasks
        SET Chargeable_Flag = 'N',
        RECORD_VERSION_NUMBER = nvl(RECORD_VERSION_NUMBER,0) + 1,
        last_updated_by = FND_GLOBAL.USER_ID,
        last_update_login = FND_GLOBAL.USER_ID,
        last_update_date = sysdate
        WHERE TASK_ID = p_reference_task_id;
      END IF;

--dbms_output.put_line( 'In move task 7' );


/*
      --Call Update statement to update display order

      ************************************************************
       THIS FUNCTIONALITY IS MOVED IN PA_TASK_PUB1.COPY_TASK API.
      ************************************************************

      BEGIN
          -- Need to get max number
          SELECT max(display_sequence)
            INTO l_max_seq
            FROM PA_TASKS
           WHERE project_id = p_reference_project_id;


          IF l_move_direction = 'UP'
          THEN
             l_max_display_sequence := l_max_display_sequence + i - 1;       --( )
             l_max_seq              := l_max_seq + i;
          END IF;

          UPDATE PA_TASKS
             SET display_sequence =
                 PA_TASKS_MAINT_UTILS.REARRANGE_DISPLAY_SEQ(display_sequence, l_max_seq, i, 'MOVE', l_move_direction ),
                 record_version_number = record_version_number + 1
           WHERE project_id = p_reference_project_id
             AND ( ( display_sequence > l_min_display_sequence and
                     display_sequence <= l_max_display_sequence ) or display_sequence < 0 );
      EXCEPTION
         WHEN OTHERS THEN
              PA_UTILS.ADD_MESSAGE('PA', 'PA_TASK_SEQ_NUM_ERR');
              RAISE FND_API.G_EXC_ERROR;
      END;    */

 EXCEPTION
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR  THEN
       IF p_commit = FND_API.G_TRUE
       THEN
          ROLLBACK TO Move;
       END IF;
       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_PVT',
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
       fnd_msg_pub.add_exc_msg(p_pkg_name       => 'PA_TASKS_MAINT_PVT',
                               p_procedure_name => 'Move_Task',
                               p_error_text     => SUBSTRB(SQLERRM,1,240));
       RAISE;

 END Move_Task;
--Begin add by rtarway for FP.M development
-- Procedure            : SET_UNSET_FINANCIAL_TASK
-- Type                 : Public Procedure
-- Purpose              : This API will be called from set financial tasks page in financial tab
--                      : This Api is to set unset the financial_task_flag in pa_proj_element_versions table.

-- Note                 :
--                      :
--                      :
-- Assumptions          :

-- Parameters                   Type     Required        Description and Purpose
-- ---------------------------  ------   --------        --------------------------------------------------------
-- p_task_version_id            NUMBER   YES             Element Version Id.
-- p_checked_flag               NUMBER   YES             Flag indicating Y/N.
-- p_project_id                 NUMBER   YES             Project ID
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
   )
IS

l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);
l_task_id                       NUMBER;
l_error_msg_code                VARCHAR2(200);

l_error_code                    NUMBER;

l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;

CURSOR c_get_task_id (l_task_version_id NUMBER, l_project_id NUMBER)
IS
SELECT
     proj_element_id
FROM
     pa_proj_element_versions
WHERE
     project_id = l_project_id
AND
     element_version_id = l_task_version_id;

-- Bug 3735089 Added cursor
CURSOR c_task_exists_in_pa_tasks(c_task_id NUMBER)
IS
SELECT 'Y'
from pa_tasks
WHERE task_id = c_task_id
and project_id = p_project_id;

--Bug 3735089
l_task_exists       VARCHAR2(1);
l_user_id               NUMBER;
l_login_id              NUMBER;


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
          PA_DEBUG.set_curr_function( p_function   => 'SET_UNSET_FINANCIAL_TASK',
                                      p_debug_mode => l_debug_mode );
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_TASKS_MAINT_PVT : SET_UNSET_FINANCIAL_TASK : Printing Input parameters';
          Pa_Debug.WRITE(g_pkg_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);

          Pa_Debug.WRITE(g_pkg_name,'p_task_version_id'||':'||p_task_version_id,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_pkg_name,'p_checked_flag'||':'||p_checked_flag,
                                     l_debug_level3);
          Pa_Debug.WRITE(g_pkg_name,'p_project_id'||':'||p_project_id,
                                     l_debug_level3);
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
      FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
       savepoint SET_UNSET_FINANCIAL_TASK_PVT;
       --savepoint SET_FIN_FLAG_WRAPPER_PUBLIC; Bug 3735089
     END IF;

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'PA_TASKS_MAINT_PVT : SET_UNSET_FINANCIAL_TASK : Validating Input parameters';
          Pa_Debug.WRITE(g_pkg_name,Pa_Debug.g_err_stage,
                                     l_debug_level3);
     END IF;

     IF (
          ( p_task_version_id IS NULL ) OR
          ( p_checked_flag IS NULL ) OR
          ( p_project_id IS NULL)
        )
     THEN
         IF l_debug_mode = 'Y' THEN
             Pa_Debug.g_err_stage:= 'PA_TASKS_MAINT_PVT : SET_UNSET_FINANCIAL_TASK : Both p_task_version_id and p_checked_flag are null';
             Pa_Debug.WRITE(g_pkg_name,Pa_Debug.g_err_stage,
                                    l_debug_level3);
         END IF;
         RAISE Invalid_Arg_Exc_WP;
     END IF;
    --Get the task id for task_version_id
    IF (p_checked_flag ='N')
    THEN
         OPEN  c_get_task_id ( p_task_version_id , p_project_id );
         FETCH c_get_task_id INTO l_task_id;
         CLOSE c_get_task_id ;

    -- Bug 3735089 Added cursor call , we can add this additionally, currently not needed
    -- OPEN c_task_exists_in_pa_tasks(l_task_id);
    -- FETCH c_task_exists_in_pa_tasks INTO l_task_exists;
        -- CLOSE c_task_exists_in_pa_tasks ;

    -- IF NVL(l_task_exists,'N') ='Y' THEN -- Bug 3735089
         --Check if the task has any transaction associated with it
         PA_PROJ_ELEMENTS_UTILS.CHECK_TASK_HAS_TRANSACTION
         (
                p_task_id               => l_task_id
              , p_project_id            => p_project_id -- Added for Performance fix 4903460
              , x_return_status         => x_return_status
              , x_msg_count             => x_msg_count
              , x_msg_data              => x_msg_data
              , x_error_msg_code        => l_error_msg_code
              , x_error_code            => l_error_code
         );

         --l_error_code is > 50 in case of associated transaction and < 0 in case of SQL error
         IF (l_error_code <> 0) THEN


              IF l_debug_mode = 'Y' THEN
                  Pa_Debug.g_err_stage:= 'PA_TASKS_MAINT_PVT : SET_UNSET_FINANCIAL_TASK :l_error_code :'||l_error_code||'l_error_msg_code :'||l_error_msg_code;
                  Pa_Debug.WRITE(g_pkg_name,Pa_Debug.g_err_stage,
                                         l_debug_level3);
              END IF;
              PA_UTILS.ADD_MESSAGE(
                                     p_app_short_name => 'PA'
                                   , p_msg_name       => substr(l_error_msg_code,1,30)--bug 3735089 used substr
                                  );
              RAISE FND_API.G_EXC_ERROR;
         END IF;
    -- END IF; --NVL(l_task_exists,'N') ='Y' THEN
     END IF;
    --Update the table with financial flag
    --Not using table handler as only one field needs to be updated.


    UPDATE
     PA_PROJ_ELEMENT_VERSIONS
    SET
     financial_task_flag = p_checked_flag
    WHERE
     element_version_id = p_task_version_id
    AND
     project_id = p_project_id;


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
       ROLLBACK TO  SET_UNSET_FINANCIAL_TASK_PVT;
       --ROLLBACK TO  SET_FIN_FLAG_WRAPPER_PUBLIC; Bug 3735089
     END IF;
     IF c_get_task_id%ISOPEN THEN
        CLOSE c_get_task_id;
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
     x_msg_data      := 'PA_TASKS_MAINT_PVT : SET_UNSET_FINANCIAL_TASK : NULL PARAMETERS ARE PASSED OR CURSOR DIDNT RETURN ANY ROWS';

     IF p_commit = FND_API.G_TRUE THEN
       ROLLBACK TO  SET_UNSET_FINANCIAL_TASK_PVT;
       --ROLLBACK TO  DELETE_MAPPING_PUBLIC; Bug 3735089
     END IF;
     IF c_get_task_id%ISOPEN THEN
        CLOSE c_get_task_id;
     END IF;
     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_TASKS_MAINT_PVT'
                    , p_procedure_name  => 'SET_UNSET_FINANCIAL_TASK'
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
       ROLLBACK TO  SET_UNSET_FINANCIAL_TASK_PVT;
       --ROLLBACK TO  DELETE_MAPPING_PUBLIC; Bug 3735089
     END IF;

     IF c_get_task_id%ISOPEN THEN
        CLOSE c_get_task_id;
     END IF;

     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name         => 'PA_TASKS_MAINT_PVT'
                    , p_procedure_name  => 'SET_UNSET_FINANCIAL_TASK'
                    , p_error_text      => x_msg_data);

     IF l_debug_mode = 'Y' THEN
          Pa_Debug.g_err_stage:= 'Unexpected Error'||x_msg_data;
          Pa_Debug.WRITE(g_pkg_name,Pa_Debug.g_err_stage,
                              l_debug_level5);
          Pa_Debug.reset_curr_function;
     END IF;
     RAISE;
END SET_UNSET_FINANCIAL_TASK ;

-- Procedure            : SYNC_UP_WP_TASKS_WITH_FIN
-- Type                 : Private Procedure
-- Purpose              : This API will be called from SYNC_UP_WP_TASKS_WITH_FIN public
--                      : This API is to Sync up the financial tasks with pa_tasks table
-- Note                 : This API can be called in two modes. One Singular and one All. In both the cases it will assume that
--                      : 1. In Singular case this API will expect the p_task_version_id and p_checked_flag to be passed.
--                      : 2. In All mode, it will expect the p_structre_version_id and p_syncup_all_tasks flag to be passed as
--                      :    'N'. In this mode this API will loop thru all the tasks in the passed structure, get each tasks
--                           financial_task_flag. If flag is Y in database, then check if the task is not present in
--                           pa_tasks. If not present in pa_tasks then create it there. Similarly remove from
--                           pa_tasks if flag is 'N'.
-- Assumptions          : The financial_task_flag is already set in the database.

-- Parameters                   Type     Required        Description and Purpose
-- ---------------------------  ------   --------        --------------------------------------------------------
-- p_parent_task_version_id    NUMBER     NO             Parent task id of the current task
-- p_patask_record_version_number NUMBER  NO
-- p_project_id                NUMBER     Yes            Project_id of the project being synced up.
-- p_syncup_all_tasks          VARCHAR2   NO             Flag indicating Y/N whether to sync up all the tasks for the given structure version id.
-- p_task_version_id           NUMBER     NO             The single task's version id. This is applicable for singular case.
-- p_structure_version_id      NUMBER     NO             The structre version_id of the structre being synced up. This is applicable when we want to sync up all the tasks.
-- p_checked_flag              VARCHAR2   NO             This flag(Y/N) will be applicable in singular case where task_version_id is being passed. This is passed so that this API again do not have to fetch financial_task_flag from the database.
-- p_mode                      VARCHAR2   NO             The mode mentioning that whether processing is to be done for All the tasks in the structure or juts for the single passed task. Possible values are SINGLE and ALL

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
   )
IS
l_msg_count                     NUMBER := 0;
l_data                          VARCHAR2(2000);
l_msg_data                      VARCHAR2(2000);
l_msg_index_out                 NUMBER;
l_debug_mode                    VARCHAR2(1);
l_task_id                       NUMBER ;
l_parent_task_id                NUMBER;
l_task_name                     VARCHAR2(240);
l_task_number                   VARCHAR2(100);
--l_display_seq                   NUMBER;
l_carrying_out_organization_id  NUMBER;
l_task_version_id               NUMBER;
l_patask_record_version_number  NUMBER;
l_debug_level2                   CONSTANT NUMBER := 2;
l_debug_level3                   CONSTANT NUMBER := 3;
l_debug_level4                   CONSTANT NUMBER := 4;
l_debug_level5                   CONSTANT NUMBER := 5;

--This cursor will give the element id corresponding to a element version id
CURSOR c_get_task_id (l_element_version_id NUMBER, l_project_id NUMBER)
IS
SELECT
proj_element_id
FROM
pa_proj_element_versions
WHERE
     element_version_id = l_element_version_id
AND
     project_id = l_project_id;
--This cursor will return name and number for a particular element
CURSOR c_get_task_name_and_number (l_element_id NUMBER, l_project_id NUMBER)
IS
SELECT
name, element_number
FROM
pa_proj_elements
WHERE
     proj_element_id = l_element_id
AND
     project_id = l_project_id;

--This cursor gets the immediate parent's task id for the passed task version id.
CURSOR c_get_immediate_parent_task_id (l_object_id_to1 NUMBER, l_project_id NUMBER)
IS
SELECT
     elever.proj_element_id
FROM
       pa_proj_element_versions elever
     , pa_object_relationships obRel
WHERE
     obRel.relationship_type ='S'
AND
     obRel.relationship_subtype ='TASK_TO_TASK'
AND
     obRel.OBJECT_ID_TO1 =  l_object_id_to1
AND
     elever.element_version_id=obRel.OBJECT_ID_FROM1
AND
     elever.project_id = l_project_id;

--This cursor returns name and number of a particular element, using element_version_id
CURSOR c_get_task_name_number_frm_ver (l_element_version_id NUMBER, l_project_id NUMBER)
IS
SELECT
       elements.name
     , elements.element_number

FROM
       pa_proj_elements elements
     , pa_proj_element_versions elever
WHERE
       elever.element_version_id = l_element_version_id
AND
       elever.project_id = l_project_id
AND
       elements.proj_element_id = elever.proj_element_id
AND
       elements.project_id = elever.project_id;

--This curosr returns the record version number from pa_tasks for row containig passed task id.
CURSOR c_get_pa_record_version_number (l_task_id NUMBER , l_project_id NUMBER)
IS
SELECT
     record_version_number
FROM
     PA_TASKS
WHERE
     task_id = l_task_id
AND
     project_id = l_project_id;

CURSOR c_get_all_tasks_in_structure(l_structure_version_id NUMBER, l_project_id NUMBER)
IS
SELECT
      element_version_id
     ,financial_task_flag
FROM
     pa_proj_element_versions
WHERE
     parent_structure_version_id = l_structure_version_id
AND
     object_type='PA_TASKS'
AND
     project_id = l_project_id;

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
          Pa_Debug.g_err_stage:= 'PA_TASKS_MAINT_PVT : SYNC_UP_WP_TASKS_WITH_FIN : Printing Input parameters';
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
     END IF;

     IF FND_API.TO_BOOLEAN(nvl(p_init_msg_list,FND_API.G_TRUE)) THEN
      FND_MSG_PUB.initialize;
     END IF;

     IF (p_commit = FND_API.G_TRUE) THEN
      --savepoint SET_FIN_FLAG_WRAPPER_PUBLIC; Bug 3735089
      savepoint SYNC_UP_WP_TASKS_WITH_FIN_PVT;
     END IF;
     --get carrying_out_organization_id
      l_carrying_out_organization_id := PA_DELIVERABLE_UTILS.GET_CARRYING_OUT_ORG
      (
          p_project_id   => p_project_id
          ,p_task_id      => l_task_id
      );
     --If p_mode is single, and p_checked_flag is 'N', delete the task
     -- if p_mode is 'Y', and task is not in PA_TASKS, create the new task
     IF ( p_mode = 'SINGLE' )
     THEN

          IF (p_checked_flag='N')
          THEN

               OPEN c_get_task_id ( p_task_version_id , p_project_id );
               FETCH c_get_task_id INTO l_task_id;
               CLOSE c_get_task_id;
               IF (PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(l_task_id)='Y')
               THEN


                   PA_TASKS_MAINT_PUB.DELETE_TASK
                   (
                          p_commit                => p_commit
                        , p_init_msg_list         => FND_API.G_FALSE
                        , p_calling_module        => p_calling_module
                        , p_debug_mode            => l_debug_mode
                        , p_project_id            => p_project_id
                        , p_task_id               => l_task_id
                        , p_record_version_number => p_patask_record_version_number
                        , p_wbs_record_version_number => 1 --parameter not used anywhere in PA_TASKS_MAINT_PUB.DELETE_TASK,pass any dummy value
                        , x_return_status         => x_return_status
                        , x_msg_count             => x_msg_count
                        , x_msg_data              => x_msg_data
                   );


                    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
                    THEN
                         RAISE FND_API.G_EXC_ERROR;
                    END IF;
               END IF;

          ELSIF (p_checked_flag='Y')
          THEN
               OPEN c_get_task_id ( p_task_version_id , p_project_id );
               FETCH c_get_task_id INTO l_task_id;
               CLOSE c_get_task_id;
               --get carrying_out_organization_id
               l_carrying_out_organization_id := PA_DELIVERABLE_UTILS.GET_CARRYING_OUT_ORG
               (
                     p_project_id   => p_project_id
                    ,p_task_id      => l_task_id
               );
               IF (PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(l_task_id)='N')
               THEN
                    --Get the task id for the parent_task_version_id
                    OPEN  c_get_task_id ( p_parent_task_version_id , p_project_id );
                    FETCH c_get_task_id INTO l_parent_task_id;
                    CLOSE c_get_task_id;
                    --Get the task name from pa_proj_elements
                    OPEN  c_get_task_name_and_number ( l_task_id , p_project_id );
                    FETCH c_get_task_name_and_number INTO l_task_name, l_task_number;
                    CLOSE c_get_task_name_and_number ;

                   PA_TASKS_MAINT_PUB.CREATE_TASK
                   (
                         p_commit                 => p_commit
                        ,p_calling_module         => p_calling_module
                        ,p_init_msg_list          => FND_API.G_FALSE
                        ,p_debug_mode             => l_debug_mode
                        ,p_project_id             => p_project_id
                        ,p_reference_task_id      => l_parent_task_id
                        ,p_peer_or_sub            => 'SUB'
                        ,p_task_number            => l_task_number
                        ,p_task_name              => l_task_name
                        ,p_task_id                => l_task_id
                        ,p_wbs_record_version_number => 1--parameter not used anywhere in PA_TASKS_MAINT_PUB.DELETE_TASK,pass any dummy value
                        ,p_carrying_out_organization_id => l_carrying_out_organization_id
                        --,x_display_seq            => l_display_seq
                        ,x_return_status          => x_return_status
                        ,x_msg_count              => x_msg_count
                        ,x_msg_data               => x_msg_data
                   );
                   IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
                   THEN
                        RAISE FND_API.G_EXC_ERROR;
                   END IF;

               END IF;
          END IF;
     --If p_mode is ALL, get all the tasks for the passed structure id
     -- For each task
     -- If p_mode is 'N' delete the task
     -- if p_mode is 'Y', and task is not in PA_TASKS, create the new task
     ELSIF ( p_mode = 'ALL' )
     THEN
          OPEN  c_get_pa_record_version_number ( l_task_id , p_project_id);
          FETCH c_get_pa_record_version_number INTO l_patask_record_version_number;
          CLOSE c_get_pa_record_version_number;

          FOR iCounter IN c_get_all_tasks_in_structure (p_structure_version_id , p_project_id) LOOP

              --initialize all values to null here
              l_task_id := null;
              l_task_version_id := null;
              l_parent_task_id := null;
              l_task_name := null;
              l_task_number := null;

              --FETCH c_get_all_tasks_in_structure INTO l_task_version_id;
              l_task_version_id := iCounter.element_version_id;
--commented by hsiu: incorrect cursor
--              l_task_version_id := cursor_rec.element_version_id;
              OPEN  c_get_task_id ( l_task_version_id , p_project_id );
              FETCH c_get_task_id INTO l_task_id;
              CLOSE c_get_task_id;
--Check_is_financial_task will return 'Y' when data is there is PA_TASKS
                    IF (PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(l_task_id)='Y' AND iCounter.financial_task_flag='N' )
                    THEN
                         PA_TASKS_MAINT_PUB.DELETE_TASK
                         (
                               p_commit                => p_commit
                             , p_calling_module        => p_calling_module
                             , p_init_msg_list         => FND_API.G_FALSE
                             , p_debug_mode            => l_debug_mode
                             , p_project_id            => p_project_id
                             , p_task_id               => l_task_id
                             , p_record_version_number => l_patask_record_version_number
                             --, p_called_from_api       => p_called_from_api
                             , p_wbs_record_version_number => 1 --parameter not used anywhere in PA_TASKS_MAINT_PUB.DELETE_TASK,pass any dummy value
                             , x_return_status         => x_return_status
                             , x_msg_count             => x_msg_count
                             , x_msg_data              => x_msg_data
                         );
                         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
                         THEN
                              RAISE FND_API.G_EXC_ERROR;
                         END IF;

                    ELSIF (PA_PROJ_ELEMENTS_UTILS.CHECK_IS_FINANCIAL_TASK(l_task_id)='N' AND iCounter.financial_task_flag='Y')
                    THEN
                         --Get the task id for the parent_task_version_id
                         OPEN  c_get_immediate_parent_task_id ( l_task_version_id , p_project_id );
                         FETCH c_get_immediate_parent_task_id INTO l_parent_task_id;
                         CLOSE c_get_immediate_parent_task_id;
                         --Get the task name from pa_proj_elements
                         OPEN  c_get_task_name_number_frm_ver ( l_task_version_id, p_project_id );
                         FETCH c_get_task_name_number_frm_ver INTO l_task_name, l_task_number;
                         CLOSE c_get_task_name_number_frm_ver ;


                         PA_TASKS_MAINT_PUB.CREATE_TASK
                         (
                              p_commit                 => p_commit
                             ,p_calling_module         => p_calling_module
                             ,p_init_msg_list          => FND_API.G_FALSE
                             ,p_validate_only          => p_validate_only
                             ,p_debug_mode             => l_debug_mode
                             ,p_project_id             => p_project_id
                             ,p_reference_task_id      => l_parent_task_id
                             ,p_peer_or_sub            => 'SUB'
                             ,p_task_number            => l_task_number
                             ,p_task_name              => l_task_name
                             ,p_task_id                => l_task_id
                             ,p_wbs_record_version_number => 1--parameter not used anywhere in PA_TASKS_MAINT_PUB.DELETE_TASK,pass any dummy value
                             ,p_carrying_out_organization_id => l_carrying_out_organization_id
                             --,x_display_seq            => l_display_seq
                             ,x_return_status          =>x_return_status
                             ,x_msg_count              =>x_msg_count
                             ,x_msg_data               =>x_msg_data
                         );
                         IF (x_return_status <> FND_API.G_RET_STS_SUCCESS)
                         THEN
                              RAISE FND_API.G_EXC_ERROR;
                         END IF;
                    END IF;
          END LOOP;
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
      --ROLLBACK TO  SET_FIN_FLAG_WRAPPER_PUBLIC; Bug 3735089
      ROLLBACK TO  SYNC_UP_WP_TASKS_WITH_FIN_PVT;
     END IF;

     IF c_get_task_id%ISOPEN THEN
        CLOSE c_get_task_id;
     END IF;
     IF c_get_task_name_and_number%ISOPEN THEN
        CLOSE c_get_task_name_and_number;
     END IF;
     IF c_get_immediate_parent_task_id%ISOPEN THEN
        CLOSE c_get_immediate_parent_task_id;
     END IF;
     IF c_get_task_name_number_frm_ver%ISOPEN THEN
        CLOSE c_get_task_name_number_frm_ver;
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
     x_msg_data      := 'PA_TASKS_MAINT_PVT : SYNC_UP_WP_TASKS_WITH_FIN : NULL PARAMETERS ARE PASSED OR CURSOR DIDNT RETURN ANY ROWS';

     IF p_commit = FND_API.G_TRUE THEN
        --ROLLBACK TO  DELETE_MAPPING_PUBLIC; Bug 3735089
        ROLLBACK TO  SYNC_UP_WP_TASKS_WITH_FIN_PVT;
     END IF;
     IF c_get_task_id%ISOPEN THEN
        CLOSE c_get_task_id;
     END IF;
     IF c_get_task_name_and_number%ISOPEN THEN
        CLOSE c_get_task_name_and_number;
     END IF;
     IF c_get_immediate_parent_task_id%ISOPEN THEN
        CLOSE c_get_immediate_parent_task_id;
     END IF;
     IF c_get_task_name_number_frm_ver%ISOPEN THEN
        CLOSE c_get_task_name_number_frm_ver;
     END IF;
     IF c_get_pa_record_version_number%ISOPEN THEN
        CLOSE c_get_pa_record_version_number;
     END IF;
     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name        => 'PA_TASKS_MAINT_PVT'
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
        --ROLLBACK TO  DELETE_MAPPING_PUBLIC; Bug 3735089
        ROLLBACK TO  SYNC_UP_WP_TASKS_WITH_FIN_PVT;
     END IF;

     IF c_get_task_id%ISOPEN THEN
        CLOSE c_get_task_id;
     END IF;
     IF c_get_task_name_and_number%ISOPEN THEN
        CLOSE c_get_task_name_and_number;
     END IF;
     IF c_get_immediate_parent_task_id%ISOPEN THEN
        CLOSE c_get_immediate_parent_task_id;
     END IF;
     IF c_get_task_name_number_frm_ver%ISOPEN THEN
        CLOSE c_get_task_name_number_frm_ver;
     END IF;
     IF c_get_pa_record_version_number%ISOPEN THEN
        CLOSE c_get_pa_record_version_number;
     END IF;
     Fnd_Msg_Pub.add_exc_msg
                   ( p_pkg_name         => 'PA_TASKS_MAINT_PVT'
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

--End add by rtarway for FP.M development

end PA_TASKS_MAINT_PVT;

/
