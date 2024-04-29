--------------------------------------------------------
--  DDL for Package PA_FIN_PLAN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FIN_PLAN_PUB" AUTHID CURRENT_USER as
/* $Header: PAFPPUBS.pls 120.3.12010000.2 2009/07/24 13:07:19 rrambati ship $
   Start of Comments
   Package name     : PA_FIN_PLAN_PUB
   Purpose          : utility API's for Org Forecast pages
   History          :
   NOTE             :
   End of Comments
*/

rollback_on_error       EXCEPTION;

TYPE p_res_assignment_tbl_typ IS TABLE OF
        pa_budget_lines.resource_assignment_id%TYPE INDEX BY BINARY_INTEGER;

TYPE p_period_name_tbl_typ              IS TABLE OF
        pa_budget_lines.period_name%TYPE INDEX BY BINARY_INTEGER;
TYPE p_start_date_tbl_typ               IS TABLE OF
        pa_budget_lines.start_date%TYPE INDEX BY BINARY_INTEGER;
TYPE p_end_date_tbl_typ                 IS TABLE OF
        pa_budget_lines.end_date%TYPE INDEX BY BINARY_INTEGER;
TYPE p_currency_code_tbl_typ            IS TABLE OF
        pa_budget_lines.txn_currency_code%TYPE INDEX BY BINARY_INTEGER;
TYPE p_cost_tbl_typ                     IS TABLE OF
        pa_budget_lines.raw_cost%TYPE INDEX BY BINARY_INTEGER;
TYPE p_quantity_tbl_typ                 IS TABLE OF
        pa_budget_lines.quantity%TYPE INDEX BY BINARY_INTEGER;
TYPE p_buck_period_code_tbl_typ         IS TABLE OF
        pa_budget_lines.BUCKETING_PERIOD_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE p_delete_flag_tbl_typ              IS TABLE OF
        pa_fin_plan_lines_tmp.delete_flag%TYPE INDEX BY BINARY_INTEGER;

--Bug 3964755. Introduced the parameter p_calling_context. Valid values are NULL and 'COPY_PROJECT'
procedure Submit_Current_Working
    (p_calling_context                  IN     VARCHAR2                                         DEFAULT NULL,
     p_project_id                       IN     pa_budget_versions.project_id%TYPE,
     p_budget_version_id                IN     pa_budget_versions.budget_version_id%TYPE,
     p_record_version_number            IN     pa_budget_versions.record_version_number%TYPE,
     x_return_status                    OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                        OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                         OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

procedure Set_Current_Working
    (p_project_id                   IN     pa_budget_versions.project_id%TYPE,
     p_budget_version_id            IN     pa_budget_versions.budget_version_id%TYPE,
     p_record_version_number        IN     pa_budget_versions.record_version_number%TYPE,
     p_orig_budget_version_id       IN     pa_budget_versions.budget_version_id%TYPE,
     p_orig_record_version_number   IN     pa_budget_versions.record_version_number%TYPE,
     x_return_status                    OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                        OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                         OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

procedure Rework_Submitted
    (p_project_id                   IN     pa_budget_versions.project_id%TYPE,
     p_budget_version_id            IN     pa_budget_versions.budget_version_id%TYPE,
     p_record_version_number        IN     pa_budget_versions.record_version_number%TYPE,
     x_return_status                    OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                        OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                         OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

procedure Mark_As_Original
    (p_project_id                   IN     pa_budget_versions.project_id%TYPE,
     p_budget_version_id            IN     pa_budget_versions.budget_version_id%TYPE,
     p_record_version_number        IN     pa_budget_versions.record_version_number%TYPE,
     p_orig_budget_version_id       IN     pa_budget_versions.budget_version_id%TYPE,
     p_orig_record_version_number   IN     pa_budget_versions.record_version_number%TYPE,
     x_return_status                    OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                        OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                         OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

procedure Delete_Version
    (p_project_id                   IN     pa_budget_versions.project_id%TYPE,
     p_budget_version_id            IN     pa_budget_versions.budget_version_id%TYPE,
     p_record_version_number        IN     pa_budget_versions.record_version_number%TYPE,
     p_context                      IN     VARCHAR2    DEFAULT    PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET,
     x_return_status                    OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                        OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                         OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

--p_context can be PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET or PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN.
--p_budget_version_id is mandatory whenever p_context is PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET.
--When PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_WORKPLAN, data for the version will be deleted when p_budget_version_id
--is passed. Otherwise when p_project_id is passed data for the entire project will be deleted.
procedure Delete_Version_Helper
    (p_project_id                       IN     pa_projects_all.project_id%TYPE DEFAULT NULL,
     p_context                          IN     VARCHAR2 DEFAULT PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_BUDGET,
     p_budget_version_id                IN     pa_budget_versions.budget_version_id%TYPE,
     x_return_status                    OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                        OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                         OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/* added ... for financial planning copy from needs */
procedure Copy_Version
    (p_project_id               IN      pa_budget_versions.project_id%TYPE,
     p_source_version_id        IN      pa_budget_versions.budget_version_id%TYPE,
     p_copy_mode                IN      VARCHAR2,
     p_adj_percentage           IN      NUMBER   DEFAULT 0,
     p_calling_module           IN      VARCHAR2 DEFAULT PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_ORG_FORECAST,
     p_pji_rollup_required      IN      VARCHAR2 DEFAULT 'Y',  --Bug 4200168
     px_target_version_id       IN  OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
     x_return_status                OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                     OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


procedure Baseline
    (p_project_id                   IN  pa_budget_versions.project_id%TYPE,
     p_budget_version_id            IN  pa_budget_versions.budget_version_id%TYPE,
     p_record_version_number        IN  pa_budget_versions.record_version_number%TYPE,
     p_orig_budget_version_id       IN  pa_budget_versions.budget_version_id%TYPE,
     p_orig_record_version_number   IN  pa_budget_versions.record_version_number%TYPE,
     x_fc_version_created_flag      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_return_status                OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                     OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

procedure Create_Version_OrgFcst
    (p_project_id                   IN     pa_budget_versions.project_id%TYPE,
     p_fin_plan_type_id             IN     pa_budget_versions.fin_plan_type_id%TYPE,
     p_fin_plan_options_id          IN     pa_proj_fp_options.proj_fp_options_id%TYPE default NULL,
     p_version_name                 IN     pa_budget_versions.version_name%TYPE,
     p_description                  IN     pa_budget_versions.description%TYPE,
     p_resource_list_id             IN     pa_budget_versions.resource_list_id%TYPE,
     x_budget_version_id            OUT    NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
     x_return_status                OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                    OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                     OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

procedure Regenerate
    (p_project_id                   IN     pa_budget_versions.project_id%TYPE,
     p_budget_version_id            IN     pa_budget_versions.budget_version_id%TYPE,
     p_record_version_number        IN     pa_budget_versions.record_version_number%TYPE,
     x_return_status                    OUT    NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                        OUT    NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                         OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

procedure Update_Version
    (p_project_id             IN     pa_budget_versions.project_id%TYPE
     ,p_budget_version_id          IN     pa_budget_versions.budget_version_id%TYPE
     ,p_record_version_number      IN     pa_budget_versions.record_version_number%TYPE
     ,p_version_name               IN     pa_budget_versions.version_name%TYPE
     ,p_description           IN     pa_budget_versions.description%TYPE
     ,p_change_reason_code         IN     pa_budget_versions.change_reason_code%TYPE
    -- Start of additional columns for Bug :- 3088010
     ,p_attribute_category               IN     pa_budget_versions.attribute_category%TYPE default NULL
     ,p_attribute1                       IN     pa_budget_versions.attribute1%TYPE default NULL
     ,p_attribute2                       IN     pa_budget_versions.attribute2%TYPE default NULL
     ,p_attribute3                       IN     pa_budget_versions.attribute3%TYPE default NULL
     ,p_attribute4                       IN     pa_budget_versions.attribute4%TYPE default NULL
     ,p_attribute5                       IN     pa_budget_versions.attribute5%TYPE default NULL
     ,p_attribute6                       IN     pa_budget_versions.attribute6%TYPE default NULL
     ,p_attribute7                       IN     pa_budget_versions.attribute7%TYPE default NULL
     ,p_attribute8                       IN     pa_budget_versions.attribute8%TYPE default NULL
     ,p_attribute9                       IN     pa_budget_versions.attribute9%TYPE default NULL
     ,p_attribute10                      IN     pa_budget_versions.attribute10%TYPE default NULL
     ,p_attribute11                      IN     pa_budget_versions.attribute11%TYPE default NULL
     ,p_attribute12                      IN     pa_budget_versions.attribute12%TYPE default NULL
     ,p_attribute13                      IN     pa_budget_versions.attribute13%TYPE default NULL
     ,p_attribute14                      IN     pa_budget_versions.attribute14%TYPE default NULL
     ,p_attribute15                      IN     pa_budget_versions.attribute15%TYPE default NULL
    -- End of additional columns for Bug :- 3088010
     ,x_return_status                    OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                        OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                         OUT    NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/* added for financial planning needs*/

procedure Create_Org_Fcst_Elements (
    p_project_id               IN      pa_projects_all.project_id%TYPE,
    p_source_version_id        IN      pa_budget_versions.budget_version_id%TYPE,
    p_target_version_id        IN      pa_budget_versions.budget_version_id%TYPE,
    x_return_status               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_msg_count                   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_msg_data                    OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Create_Version (
    p_project_id                        IN     NUMBER
    ,p_fin_plan_type_id                 IN     NUMBER
    ,p_element_type                     IN     VARCHAR2
    ,p_version_name                     IN     VARCHAR2
    ,p_description                      IN     VARCHAR2
    -- Start of additional columns for Bug :- 2634900
    ,p_ci_id                            IN     pa_budget_versions.ci_id%TYPE                    := NULL
    ,p_est_proj_raw_cost                IN     pa_budget_versions.est_project_raw_cost%TYPE     := NULL
    ,p_est_proj_bd_cost                 IN     pa_budget_versions.est_project_burdened_cost%TYPE:= NULL
    ,p_est_proj_revenue                 IN     pa_budget_versions.est_project_revenue%TYPE      := NULL
    ,p_est_qty                          IN     pa_budget_versions.est_quantity%TYPE             := NULL
    ,p_est_equip_qty                    IN     pa_budget_versions.est_equipment_quantity%TYPE   := NULL
    ,p_impacted_task_id                 IN     pa_tasks.task_id%TYPE                            := NULL
    ,p_agreement_id                     IN     pa_budget_versions.agreement_id%TYPE             := NULL
    ,p_calling_context                  IN     VARCHAR2                                         := NULL
    -- End of additional columns for Bug :- 2634900
    -- Start of additional columns for Bug :- 2649474
    ,p_resource_list_id                 IN     pa_budget_versions.resource_list_id%TYPE         := NULL
    ,p_time_phased_code                 IN     pa_proj_fp_options.cost_time_phased_code%TYPE    := NULL
    ,p_fin_plan_level_code              IN     pa_proj_fp_options.cost_fin_plan_level_code%TYPE := NULL
    ,p_plan_in_multi_curr_flag          IN     pa_proj_fp_options.plan_in_multi_curr_flag%TYPE  := NULL
    ,p_amount_set_id                    IN     pa_proj_fp_options.cost_amount_set_id%TYPE       := NULL
    -- End of additional columns for Bug :- 2649474
    -- Start of additional columns for Bug :- 3088010
    ,p_attribute_category               IN     pa_budget_versions.attribute_category%TYPE default NULL
    ,p_attribute1                       IN     pa_budget_versions.attribute1%TYPE default NULL
    ,p_attribute2                       IN     pa_budget_versions.attribute2%TYPE default NULL
    ,p_attribute3                       IN     pa_budget_versions.attribute3%TYPE default NULL
    ,p_attribute4                       IN     pa_budget_versions.attribute4%TYPE default NULL
    ,p_attribute5                       IN     pa_budget_versions.attribute5%TYPE default NULL
    ,p_attribute6                       IN     pa_budget_versions.attribute6%TYPE default NULL
    ,p_attribute7                       IN     pa_budget_versions.attribute7%TYPE default NULL
    ,p_attribute8                       IN     pa_budget_versions.attribute8%TYPE default NULL
    ,p_attribute9                       IN     pa_budget_versions.attribute9%TYPE default NULL
    ,p_attribute10                      IN     pa_budget_versions.attribute10%TYPE default NULL
    ,p_attribute11                      IN     pa_budget_versions.attribute11%TYPE default NULL
    ,p_attribute12                      IN     pa_budget_versions.attribute12%TYPE default NULL
    ,p_attribute13                      IN     pa_budget_versions.attribute13%TYPE default NULL
    ,p_attribute14                      IN     pa_budget_versions.attribute14%TYPE default NULL
    ,p_attribute15                      IN     pa_budget_versions.attribute15%TYPE default NULL
    -- End of additional columns for Bug :- 3088010
    ,px_budget_version_id               IN OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,p_struct_elem_version_id           IN     pa_proj_element_versions.element_version_id%TYPE default NULL -- BUG 3354518
    ,p_pm_product_code                  IN pa_budget_versions.pm_product_code%TYPE DEFAULT NULL
    ,p_finplan_reference                IN pa_budget_versions.pm_budget_reference%TYPE DEFAULT NULL
    ,p_change_reason_code               IN pa_budget_versions.change_reason_code%TYPE DEFAULT NULL
    ,p_pji_rollup_required             IN VARCHAR2                                   DEFAULT 'Y'  --Bug 4200168
    ,x_proj_fp_option_id                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_return_status                       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count                           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data                            OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

/* added for financial planning needs*/

PROCEDURE Create_Fresh_Period_Profile(
    p_project_id           IN     NUMBER
    ,p_period_type         IN     VARCHAR2
    ,x_period_profile_id      OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data               OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE Call_Maintain_Plan_Matrix (
    p_budget_version_id    IN     pa_budget_versions.budget_version_id%TYPE
    ,p_data_source         IN     VARCHAR2
    ,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data               OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE INSERT_PLAN_LINES_TMP_BULK
   (p_res_assignment_tbl        IN    p_res_assignment_tbl_typ
   ,p_period_name_tbl           IN    p_period_name_tbl_typ
   ,p_start_date_tbl            IN    p_start_date_tbl_typ
   ,p_end_date_tbl              IN    p_end_date_tbl_typ
   ,p_currency_type             IN    pa_proj_periods_denorm.currency_type%TYPE
   ,p_currency_code_tbl         IN    p_currency_code_tbl_typ
   ,p_quantity_tbl              IN    p_quantity_tbl_typ
   ,p_raw_cost_tbl              IN    p_cost_tbl_typ
   ,p_burdened_cost_tbl         IN    p_cost_tbl_typ
   ,p_revenue_tbl               IN    p_cost_tbl_typ
   ,p_old_quantity_tbl          IN    p_quantity_tbl_typ
   ,p_old_raw_cost_tbl          IN    p_cost_tbl_typ
   ,p_old_burdened_cost_tbl     IN    p_cost_tbl_typ
   ,p_old_revenue_tbl           IN    p_cost_tbl_typ
   ,p_margin_tbl                IN    p_cost_tbl_typ
   ,p_margin_percent_tbl        IN    p_cost_tbl_typ
   ,p_old_margin_tbl            IN    p_cost_tbl_typ
   ,p_old_margin_percent_tbl    IN    p_cost_tbl_typ
   ,p_buck_period_code_tbl      IN    p_buck_period_code_tbl_typ
   ,p_parent_assignment_id_tbl  IN    p_res_assignment_tbl_typ
   ,p_delete_flag_tbl           IN    p_delete_flag_tbl_typ
   ,p_source_txn_curr_code_tbl  IN    p_currency_code_tbl_typ
   ,x_return_status             OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count                 OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data                  OUT   NOCOPY VARCHAR2  ); --File.Sql.39 bug 4440895

PROCEDURE Refresh_res_list_assignment (
    p_project_id              IN    pa_budget_versions.project_id%TYPE
    ,p_resource_list_id       IN    pa_budget_versions.resource_list_id%TYPE
    ,x_return_status          OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count              OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data               OUT   NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE create_default_plan_txn_rec
    (p_budget_version_id          IN         pa_budget_versions.budget_version_id%TYPE,
     p_calling_module             IN    VARCHAR2,
     p_ra_id_tbl                  IN    SYSTEM.PA_NUM_TBL_TYPE         DEFAULT SYSTEM.PA_NUM_TBL_TYPE(), /* 7161809 */
     p_curr_code_tbl              IN    SYSTEM.PA_VARCHAR2_15_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_15_TBL_TYPE(), /* 7161809 */
     p_expenditure_type_tbl       IN    SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE(), /* Enc */
     x_return_status              OUT NOCOPY   VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2);



END pa_fin_plan_pub;

/
