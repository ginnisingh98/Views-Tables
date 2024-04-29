--------------------------------------------------------
--  DDL for Package PA_FP_UPGRADE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_UPGRADE_PKG" AUTHID CURRENT_USER AS
/* $Header: PAFPUPGS.pls 120.3 2007/02/06 10:12:49 dthakker ship $ */

TYPE upgrade_elements_rec_type IS RECORD (
 basis_cost_version_id          pa_budget_versions.budget_version_id%TYPE
,basis_rev_version_id           pa_budget_versions.budget_version_id%TYPE
,basis_cost_bem                 pa_budget_versions.budget_entry_method_code%TYPE
,basis_rev_bem                  pa_budget_versions.budget_entry_method_code%TYPE
,basis_cost_res_list_id         pa_budget_versions.resource_list_id%TYPE
,basis_rev_res_list_id          pa_budget_versions.resource_list_id%TYPE
,basis_cost_planning_level      pa_budget_entry_methods.entry_level_code%TYPE
,basis_rev_planning_level       pa_budget_entry_methods.entry_level_code%TYPE
,basis_cost_time_phased_code    pa_budget_entry_methods.time_phased_type_code%TYPE
,basis_rev_time_phased_code     pa_budget_entry_methods.time_phased_type_code%TYPE
,basis_cost_amount_set_id       pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE
,basis_rev_amount_Set_id        pa_fin_plan_amount_sets.fin_plan_amount_set_id%TYPE
,curr_option_preference_code    pa_proj_fp_options.fin_plan_preference_code%TYPE
,curr_option_project_id         pa_proj_fp_options.project_id%TYPE
,curr_option_plan_type_id       pa_proj_fp_options.fin_plan_type_id%TYPE
,curr_option_plan_version_id    pa_proj_fp_options.fin_plan_version_id%TYPE
,curr_option_level_code         pa_proj_fp_options.fin_plan_option_level_code%TYPE
,curr_option_budget_type_code   pa_budget_versions.budget_type_code%TYPE
);

Procedure Populate_Local_Variables(
           p_project_id                 IN           pa_proj_fp_options.project_id%TYPE
          ,p_budget_type_code           IN           pa_budget_versions.budget_type_code%TYPE
          ,p_fin_plan_version_id        IN           pa_proj_fp_options.fin_plan_version_id%TYPE
          ,p_fin_plan_option_level      IN           pa_proj_fp_options.fin_plan_option_level_code%TYPE
         ,x_upgrade_elements_rec         OUT  NOCOPY  pa_fp_upgrade_pkg.upgrade_elements_rec_type
          ,x_return_status              OUT          NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                  OUT          NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                   OUT          NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Upgrade_Budgets(
           p_from_project_number        IN           VARCHAR2
          ,p_to_project_number          IN           VARCHAR2
          ,p_budget_types               IN           VARCHAR2
          ,p_budget_statuses            IN           VARCHAR2
          ,p_project_type               IN           VARCHAR2
          ,p_project_statuses           IN           VARCHAR2
          ,x_return_status              OUT          NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                  OUT          NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                   OUT          NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Upgrade_Budget_Types(
           p_budget_types               IN           VARCHAR2
          ,x_return_status              OUT          NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                  OUT          NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                   OUT          NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

PROCEDURE Create_fp_options(
           p_project_id                 IN           pa_proj_fp_options.project_id%TYPE
          ,p_budget_type_code           IN           pa_budget_versions.budget_type_code%TYPE
          ,p_fin_plan_version_id        IN           pa_proj_fp_options.fin_plan_version_id%TYPE
          ,p_fin_plan_option_level      IN           pa_proj_fp_options.fin_plan_option_level_code%TYPE
          ,x_proj_fp_options_id         OUT          NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE --File.Sql.39 bug 4440895
         ,x_upgrade_elements_rec       OUT  NOCOPY  pa_fp_upgrade_pkg.upgrade_elements_rec_type
          ,x_return_status              OUT          NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                  OUT          NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                   OUT          NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

Procedure Add_Plan_Types(
           p_project_id                 IN           pa_projects.project_id%TYPE
          ,p_budget_types               IN           VARCHAR2
          ,x_return_status              OUT          NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                  OUT          NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                   OUT          NOCOPY VARCHAR2) ; --File.Sql.39 bug 4440895

PROCEDURE Upgrade_Budget_Versions (
           p_project_id                 IN           pa_projects.project_id%TYPE
          ,p_budget_types               IN           VARCHAR2
          ,p_budget_statuses            IN           VARCHAR2
          ,x_return_status              OUT          NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                  OUT          NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                   OUT          NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Insert_Audit_Record(
           p_project_id                      IN        PA_FP_UPGRADE_AUDIT.PROJECT_ID%TYPE
          ,p_budget_type_code                IN        PA_FP_UPGRADE_AUDIT.BUDGET_TYPE_CODE%TYPE
          ,p_proj_fp_options_id              IN        PA_FP_UPGRADE_AUDIT.PROJ_FP_OPTIONS_ID%TYPE
          ,p_fin_plan_option_level_code      IN        PA_FP_UPGRADE_AUDIT.FIN_PLAN_OPTION_LEVEL_CODE%TYPE
          ,p_basis_cost_version_id           IN        PA_FP_UPGRADE_AUDIT.BASIS_COST_VERSION_ID%TYPE
          ,p_basis_rev_version_id            IN        PA_FP_UPGRADE_AUDIT.BASIS_REV_VERSION_ID%TYPE
          ,p_basis_cost_bem                  IN        PA_FP_UPGRADE_AUDIT.BASIS_COST_BEM%TYPE
          ,p_basis_rev_bem                   IN        PA_FP_UPGRADE_AUDIT.BASIS_REV_BEM%TYPE
          ,p_upgraded_flag                   IN        PA_FP_UPGRADE_AUDIT.UPGRADED_FLAG%TYPE
          ,p_failure_reason_code             IN        PA_FP_UPGRADE_AUDIT.FAILURE_REASON_CODE%TYPE
          ,p_proj_fp_options_id_rup          IN        PA_FP_UPGRADE_AUDIT.PROJ_FP_OPTIONS_ID%TYPE  DEFAULT NULL); -- bug 5144013:IPM RUP3 Merge

PROCEDURE VALIDATE_BUDGETS (
           p_from_project_number             IN        VARCHAR2
          ,p_to_project_number               IN        VARCHAR2
          ,p_budget_types                    IN        VARCHAR2
          ,p_budget_statuses                 IN        VARCHAR2
          ,p_project_type                    IN        VARCHAR2
          ,p_project_statuses                IN        VARCHAR2
          ,x_return_status                   OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                       OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                        OUT       NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE validate_project (
           p_project_id                      IN        pa_budget_versions.project_id%TYPE
          ,x_validation_status               OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_return_status                   OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                       OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                        OUT       NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE validate_project_plan_type (
           p_project_id                      IN        pa_budget_versions.project_id%TYPE
          ,p_budget_type_code                IN        pa_budget_versions.budget_type_code%TYPE
          ,x_validation_status               OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_return_status                   OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                       OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                        OUT       NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE validate_budget_version (
           p_budget_version_id               IN        pa_budget_versions.budget_version_id%TYPE
          ,x_return_status                   OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                       OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                        OUT       NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--This procedure will upgrade the budget lines of a budget version so that all the amount/quantity columns
--are populated. Please refer to the bug to see more discussion on this matter

--ASSUMPTIONS
--1.Input is ordered by resource assignment id ,quantities with NULLS coming first
--2.0(Zero)s are passed as input for amounts instead of NULL.

-- bug 5144013: added a new Added a new IN parameter p_calling_module in the
-- with a default value of 'UI_FLOW'.

PROCEDURE Apply_Calculate_FPM_Rules
( p_preference_code              IN   pa_proj_fp_options.fin_plan_preference_code%TYPE
 ,p_resource_assignment_id_tbl   IN   SYSTEM.pa_num_tbl_type
 ,p_rate_based_flag_tbl          IN   SYSTEM.pa_varchar2_1_tbl_type
 ,p_quantity_tbl                 IN   SYSTEM.pa_num_tbl_type
 ,p_txn_raw_cost_tbl             IN   SYSTEM.pa_num_tbl_type
 ,p_txn_burdened_cost_tbl        IN   SYSTEM.pa_num_tbl_type
 ,p_txn_revenue_tbl              IN   SYSTEM.pa_num_tbl_type
 ,p_calling_module               IN   VARCHAR2   DEFAULT  'UI_FLOW'    -- bug 5144013
 ,x_quantity_tbl                 OUT  NOCOPY SYSTEM.pa_num_tbl_type --File.Sql.39 bug 4440895
 ,x_txn_raw_cost_tbl             OUT  NOCOPY SYSTEM.pa_num_tbl_type --File.Sql.39 bug 4440895
 ,x_txn_burdened_cost_tbl        OUT  NOCOPY SYSTEM.pa_num_tbl_type --File.Sql.39 bug 4440895
 ,x_txn_revenue_tbl              OUT  NOCOPY SYSTEM.pa_num_tbl_type --File.Sql.39 bug 4440895
 ,x_raw_cost_override_rate_tbl   OUT  NOCOPY SYSTEM.pa_num_tbl_type  --File.Sql.39 bug 4440895
 ,x_burd_cost_override_rate_tbl  OUT  NOCOPY SYSTEM.pa_num_tbl_type  --File.Sql.39 bug 4440895
 ,x_bill_override_rate_tbl       OUT  NOCOPY SYSTEM.pa_num_tbl_type  --File.Sql.39 bug 4440895
 ,x_non_rb_ra_id_tbl             OUT  NOCOPY SYSTEM.pa_num_tbl_type --File.Sql.39 bug 4440895
 ,x_return_status                OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_msg_count                    OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                     OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-- bug 5144013:IPM RUP3 Merge :Optional upgrade code. created new procedure rollup_rejected_bl_amounts

PROCEDURE rollup_rejected_bl_amounts(
           p_from_project_number        IN           VARCHAR2 DEFAULT NULL
          ,p_to_project_number          IN           VARCHAR2 DEFAULT NULL
          ,p_fin_plan_type_id           IN           NUMBER   DEFAULT NULL
          ,p_project_statuses           IN           VARCHAR2
          ,x_return_status              OUT NOCOPY   VARCHAR2
          ,x_msg_count                  OUT NOCOPY   NUMBER
          ,x_msg_data                   OUT NOCOPY   VARCHAR2);

END pa_fp_upgrade_pkg;

/
