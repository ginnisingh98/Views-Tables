--------------------------------------------------------
--  DDL for Package PA_BUDGET_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_BUDGET_PVT" AUTHID DEFINER as
/*$Header: PAPMBUVS.pls 120.6 2007/11/30 16:00:09 rthumma ship $*/

--Declared the following variables as part of changes to AMG due to finplan model
g_task_number             pa_tasks.task_number%TYPE;
g_start_date              pa_budget_lines.start_date%TYPE;
g_resource_alias          pa_resource_list_members.alias%TYPE;

/*Bug 5509192 this record type, table type and table are
   defined only for the api pa_budget_pub.update_plannning_element_attr
   This global table will be populated only by pa_budget_pvt.
   validate_budget_lines. No other API should use this*/
   TYPE res_assign_rec_type IS RECORD
   (resource_assignment_id number);
   TYPE res_assign_tbl_type IS TABLE OF res_assign_rec_type
           INDEX BY BINARY_INTEGER;
   TYPE res_assign_tbl_type1 IS TABLE OF res_assign_rec_type
           INDEX BY varchar2(17);
   G_res_assign_tbl  res_assign_tbl_type;
   --end changes for bug 5509192



PROCEDURE insert_budget_line
( p_return_status             OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_pa_project_id             IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_budget_type_code          IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_task_id                IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_task_reference         IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_alias            IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_member_id                 IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_budget_start_date         IN    DATE              := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_budget_end_date           IN    DATE              := PA_INTERFACE_UTILS_PUB.G_PA_MISS_DATE
 ,p_period_name               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_description               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_raw_cost                  IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_burdened_cost             IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_revenue                   IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_quantity                  IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pm_product_code           IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_budget_line_reference  IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute_category        IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute1                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute2                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute3                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute4                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute5                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute6                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute7                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute8                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute9                IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute10               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute11               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute12               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute13               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute14               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_attribute15               IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_resource_list_id          IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_time_phased_type_code     IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_entry_level_code          IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_amount_code        IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_entry_method_code  IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_categorization_code       IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_budget_version_id         IN    NUMBER            := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_change_reason_code        IN    VARCHAR2          := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR );--Bug 4224464


/* Bug 4224464- This procedure has been modified extensively during FP.M changes for AMG.
 * If you do not want to update a parameter then either do not pass it or pass its value
 *  as NULL, and if you want to null out a parameter then pass it as FND_API.G_MISS_XXX*/
PROCEDURE update_budget_line_sql
( p_return_status             OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_budget_entry_method_code  IN    VARCHAR2          := NULL
 ,p_resource_assignment_id    IN    NUMBER            := NULL
 ,p_start_date                IN    DATE              := NULL
 ,p_time_phased_type_code     IN    VARCHAR2          := NULL
 ,p_description               IN    VARCHAR2          := NULL
 ,p_quantity                  IN    NUMBER            := NULL
 ,p_raw_cost                  IN    NUMBER            := NULL
 ,p_burdened_cost             IN    NUMBER            := NULL
 ,p_revenue                   IN    NUMBER            := NULL
 ,p_change_reason_code        IN    VARCHAR2          := NULL
 ,p_attribute_category        IN    VARCHAR2          := NULL
 ,p_attribute1                IN    VARCHAR2          := NULL
 ,p_attribute2                IN    VARCHAR2          := NULL
 ,p_attribute3                IN    VARCHAR2          := NULL
 ,p_attribute4                IN    VARCHAR2          := NULL
 ,p_attribute5                IN    VARCHAR2          := NULL
 ,p_attribute6                IN    VARCHAR2          := NULL
 ,p_attribute7                IN    VARCHAR2          := NULL
 ,p_attribute8                IN    VARCHAR2          := NULL
 ,p_attribute9                IN    VARCHAR2          := NULL
 ,p_attribute10               IN    VARCHAR2          := NULL
 ,p_attribute11               IN    VARCHAR2          := NULL
 ,p_attribute12               IN    VARCHAR2          := NULL
 ,p_attribute13               IN    VARCHAR2          := NULL
 ,p_attribute14               IN    VARCHAR2          := NULL
 ,p_attribute15               IN    VARCHAR2          := NULL
);

PROCEDURE get_valid_period_dates
( p_return_status             OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_project_id                IN    NUMBER
 ,p_task_id                   IN    NUMBER
 ,p_time_phased_type_code     IN    VARCHAR2
 ,p_entry_level_code          IN    VARCHAR2
 ,p_period_name_in            IN    VARCHAR2
 ,p_budget_start_date_in      IN    DATE
 ,p_budget_end_date_in        IN    DATE
 ,p_period_name_out           OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_budget_start_date_out     OUT   NOCOPY DATE --File.Sql.39 bug 4440895
 ,p_budget_end_date_out       OUT   NOCOPY DATE --File.Sql.39 bug 4440895

 -- Bug 3986129: FP.M Web ADI Dev changes
 ,p_context                IN   VARCHAR2  DEFAULT  NULL
 ,p_calling_model_context     IN   VARCHAR2
 ,x_error_code             OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE check_entry_method_flags
( p_return_status               OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_budget_amount_code          IN      VARCHAR2
 ,p_budget_entry_method_code    IN      VARCHAR2
 ,p_quantity                    IN      NUMBER
 ,p_raw_cost                    IN      NUMBER
 ,p_burdened_cost               IN      NUMBER
 ,p_revenue                     IN      NUMBER
 ,p_version_type                IN      VARCHAR2 := NULL
 ,p_allow_qty_flag              IN      VARCHAR2 := NULL
 ,p_allow_raw_cost_flag         IN      VARCHAR2 := NULL
 ,p_allow_burdened_cost_flag    IN      VARCHAR2 := NULL
 ,p_allow_revenue_flag          IN      VARCHAR2 := NULL

 -- Bug 3986129: FP.M Web ADI Dev changes
 ,p_context                   IN  VARCHAR2   DEFAULT NULL
 ,p_raw_cost_rate             IN  NUMBER     DEFAULT NULL
 ,p_burdened_cost_rate        IN  NUMBER     DEFAULT NULL
 ,p_bill_rate                 IN  NUMBER     DEFAULT NULL
 ,p_allow_raw_cost_rate_flag  IN  VARCHAR2   DEFAULT NULL
 ,p_allow_burd_cost_rate_flag IN  VARCHAR2   DEFAULT NULL
 ,p_allow_bill_rate_flag      IN  VARCHAR2   DEFAULT NULL
 ,x_webadi_error_code         OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

 PROCEDURE Validate_Header_Info
( p_api_version_number            IN        NUMBER
 ,p_budget_version_name           IN        VARCHAR2   /* Introduced for bug 3133930*/
 ,p_init_msg_list                 IN        VARCHAR2
 ,px_pa_project_id                IN  OUT   NOCOPY pa_projects_all.project_id%TYPE --File.Sql.39 bug 4440895
 ,p_pm_project_reference          IN        pa_projects_all.pm_project_reference%TYPE
 ,p_pm_product_code               IN        pa_projects_all.pm_product_code%TYPE
 ,p_budget_type_code              IN        pa_budget_types.budget_type_code%TYPE
 ,p_entry_method_code             IN        pa_budget_entry_methods.budget_entry_method_code%TYPE
 ,px_resource_list_name           IN  OUT   NOCOPY pa_resource_lists_tl.name%TYPE --File.Sql.39 bug 4440895
 ,px_resource_list_id             IN  OUT   NOCOPY pa_resource_lists_all_bg.resource_list_id%TYPE --File.Sql.39 bug 4440895
 ,px_fin_plan_type_id             IN  OUT   NOCOPY pa_fin_plan_types_b.fin_plan_type_id%TYPE --File.Sql.39 bug 4440895
 ,px_fin_plan_type_name           IN  OUT   NOCOPY pa_fin_plan_types_tl.name%TYPE --File.Sql.39 bug 4440895
 ,px_version_type                 IN  OUT   NOCOPY pa_budget_versions.version_type%TYPE --File.Sql.39 bug 4440895
 ,px_fin_plan_level_code          IN  OUT   NOCOPY pa_proj_fp_options.cost_fin_plan_level_code%TYPE --File.Sql.39 bug 4440895
 ,px_time_phased_code             IN  OUT   NOCOPY pa_proj_fp_options.cost_time_phased_code%TYPE --File.Sql.39 bug 4440895
 ,px_plan_in_multi_curr_flag      IN  OUT   NOCOPY pa_proj_fp_options.plan_in_multi_curr_flag%TYPE --File.Sql.39 bug 4440895
 ,px_projfunc_cost_rate_type      IN  OUT   NOCOPY pa_proj_fp_options.projfunc_cost_rate_type%TYPE --File.Sql.39 bug 4440895
 ,px_projfunc_cost_rate_date_typ  IN  OUT   NOCOPY pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE --File.Sql.39 bug 4440895
 ,px_projfunc_cost_rate_date      IN  OUT   NOCOPY pa_proj_fp_options.projfunc_cost_rate_date%TYPE --File.Sql.39 bug 4440895
 ,px_projfunc_rev_rate_type       IN  OUT   NOCOPY pa_proj_fp_options.projfunc_rev_rate_type%TYPE --File.Sql.39 bug 4440895
 ,px_projfunc_rev_rate_date_typ   IN  OUT   NOCOPY pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE --File.Sql.39 bug 4440895
 ,px_projfunc_rev_rate_date       IN  OUT   NOCOPY pa_proj_fp_options.projfunc_rev_rate_date%TYPE --File.Sql.39 bug 4440895
 ,px_project_cost_rate_type       IN  OUT   NOCOPY pa_proj_fp_options.project_cost_rate_type%TYPE --File.Sql.39 bug 4440895
 ,px_project_cost_rate_date_typ   IN  OUT   NOCOPY pa_proj_fp_options.project_cost_rate_date_type%TYPE --File.Sql.39 bug 4440895
 ,px_project_cost_rate_date       IN  OUT   NOCOPY pa_proj_fp_options.project_cost_rate_date%TYPE --File.Sql.39 bug 4440895
 ,px_project_rev_rate_type        IN  OUT   NOCOPY pa_proj_fp_options.project_rev_rate_type%TYPE --File.Sql.39 bug 4440895
 ,px_project_rev_rate_date_typ    IN  OUT   NOCOPY pa_proj_fp_options.project_rev_rate_date_type%TYPE --File.Sql.39 bug 4440895
 ,px_project_rev_rate_date        IN  OUT   NOCOPY pa_proj_fp_options.project_rev_rate_date%TYPE --File.Sql.39 bug 4440895
 ,px_raw_cost_flag                IN  OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,px_burdened_cost_flag           IN  OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,px_revenue_flag                 IN  OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,px_cost_qty_flag                IN  OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,px_revenue_qty_flag             IN  OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,px_all_qty_flag                 IN  OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,p_create_new_curr_working_flag  IN        VARCHAR2
 ,p_replace_current_working_flag  IN        VARCHAR2
 ,p_change_reason_code            IN        pa_budget_versions.change_reason_code%TYPE
 ,p_calling_module                IN        VARCHAR2
--New parameter for fin plan.
 ,p_using_resource_lists_flag     IN        VARCHAR2 default 'Y'
 ,x_budget_amount_code            OUT       NOCOPY pa_budget_types.budget_amount_code%TYPE   --Added for bug 4224464. --File.Sql.39 bug 4440895
 ,x_msg_count                     OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                      OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_return_status                 OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895

) ;


--This API is an overloaded version of an already existing procedure. It is
--created as part of FP.M Changes for FP AMG Apis. All header level validations
--required for PA_BUDGET_PUB.add_budget_line have been added to this API.
--This API handles validations for budget versions in new as well as old models.

PROCEDURE Validate_Header_Info
( p_api_version_number            IN            NUMBER DEFAULT 1.0
 ,p_api_name                      IN            VARCHAR2 DEFAULT NULL
 ,p_init_msg_list                 IN            VARCHAR2
 ,px_pa_project_id                IN OUT NOCOPY NUMBER
 ,p_pm_project_reference          IN            VARCHAR2
 ,p_pm_product_code               IN            VARCHAR2
 ,px_budget_type_code             IN OUT NOCOPY VARCHAR2
 ,px_fin_plan_type_id             IN OUT NOCOPY NUMBER
 ,px_fin_plan_type_name           IN OUT NOCOPY VARCHAR2
 ,px_version_type                 IN OUT NOCOPY VARCHAR2
 ,p_budget_version_number         IN            NUMBER
 ,p_change_reason_code            IN            VARCHAR2
 ,p_function_name                 IN            VARCHAR2
 ,x_budget_entry_method_code      OUT    NOCOPY VARCHAR2
 ,x_resource_list_id              OUT    NOCOPY NUMBER
 ,x_budget_version_id             OUT    NOCOPY NUMBER
 ,x_fin_plan_level_code           OUT    NOCOPY VARCHAR2
 ,x_time_phased_code              OUT    NOCOPY VARCHAR2
 ,x_plan_in_multi_curr_flag       OUT    NOCOPY VARCHAR2
 ,x_budget_amount_code            OUT    NOCOPY VARCHAR2
 ,x_categorization_code           OUT    NOCOPY VARCHAR2
 ,x_project_number                OUT    NOCOPY VARCHAR2
 /* Plan Amount Entry flags introduced by bug 6408139 */
 ,px_raw_cost_flag                IN OUT NOCOPY   VARCHAR2
 ,px_burdened_cost_flag           IN OUT NOCOPY   VARCHAR2
 ,px_revenue_flag                 IN OUT NOCOPY   VARCHAR2
 ,px_cost_qty_flag                IN OUT NOCOPY   VARCHAR2
 ,px_revenue_qty_flag             IN OUT NOCOPY   VARCHAR2
 ,px_all_qty_flag                 IN OUT NOCOPY   VARCHAR2
 ,px_bill_rate_flag               IN OUT NOCOPY   VARCHAR2
 ,px_cost_rate_flag               IN OUT NOCOPY   VARCHAR2
 ,px_burden_rate_flag             IN OUT NOCOPY   VARCHAR2
 /* Plan Amount Entry flags introduced by bug 6408139 */
 ,x_msg_count                     OUT    NOCOPY NUMBER
 ,x_msg_data                      OUT    NOCOPY VARCHAR2
 ,x_return_status                 OUT    NOCOPY VARCHAR2
 );


PROCEDURE Validate_Budget_Lines
( p_calling_context                 IN     VARCHAR2 DEFAULT 'BUDGET_LINE_LEVEL_VALIDATION'
 ,p_run_id                          IN     pa_fp_webadi_upload_inf.run_id%TYPE DEFAULT NULL
 ,p_pa_project_id                   IN     pa_projects_all.project_id%TYPE
 ,p_budget_type_code                IN     pa_budget_types.budget_type_code%TYPE
 ,p_fin_plan_type_id                IN     pa_fin_plan_types_b.fin_plan_type_id%TYPE
 ,p_version_type                    IN     pa_budget_versions.version_type%TYPE
 ,p_resource_list_id                IN     pa_resource_lists_all_bg.resource_list_id%TYPE
 ,p_time_phased_code                IN     pa_proj_fp_options.cost_time_phased_code%TYPE
 ,p_budget_entry_method_code        IN     pa_budget_entry_methods.budget_entry_method_code%TYPE
 ,p_entry_level_code                IN     pa_proj_fp_options.cost_fin_plan_level_code%TYPE
 ,p_allow_qty_flag                  IN     VARCHAR2
 ,p_allow_raw_cost_flag             IN     VARCHAR2
 ,p_allow_burdened_cost_flag        IN     VARCHAR2
 ,p_allow_revenue_flag              IN     VARCHAR2
 ,p_multi_currency_flag             IN     pa_proj_fp_options.plan_in_multi_curr_flag%TYPE
 ,p_project_cost_rate_type          IN     pa_proj_fp_options.project_cost_rate_type%TYPE
 ,p_project_cost_rate_date_typ      IN     pa_proj_fp_options.project_cost_rate_date_type%TYPE
 ,p_project_cost_rate_date          IN     pa_proj_fp_options.project_cost_rate_date%TYPE
 ,p_project_cost_exchange_rate      IN     pa_budget_lines.project_cost_exchange_rate%TYPE
 ,p_projfunc_cost_rate_type         IN     pa_proj_fp_options.projfunc_cost_rate_type%TYPE
 ,p_projfunc_cost_rate_date_typ     IN     pa_proj_fp_options.projfunc_cost_rate_date_type%TYPE
 ,p_projfunc_cost_rate_date         IN     pa_proj_fp_options.projfunc_cost_rate_date%TYPE
 ,p_projfunc_cost_exchange_rate     IN     pa_budget_lines.projfunc_cost_exchange_rate%TYPE
 ,p_project_rev_rate_type           IN     pa_proj_fp_options.project_rev_rate_type%TYPE
 ,p_project_rev_rate_date_typ       IN     pa_proj_fp_options.project_rev_rate_date_type%TYPE
 ,p_project_rev_rate_date           IN     pa_proj_fp_options.project_rev_rate_date%TYPE
 ,p_project_rev_exchange_rate       IN     pa_budget_lines.project_rev_exchange_rate%TYPE
 ,p_projfunc_rev_rate_type          IN     pa_proj_fp_options.projfunc_rev_rate_type%TYPE
 ,p_projfunc_rev_rate_date_typ      IN     pa_proj_fp_options.projfunc_rev_rate_date_type%TYPE
 ,p_projfunc_rev_rate_date          IN     pa_proj_fp_options.projfunc_rev_rate_date%TYPE
 ,p_projfunc_rev_exchange_rate      IN     pa_budget_lines.project_rev_exchange_rate%TYPE

 /* Bug 3986129: FP.M Web ADI Dev changes: New parameters added*/
 ,p_version_info_rec                IN     pa_fp_gen_amount_utils.fp_cols  DEFAULT NULL
 ,p_allow_raw_cost_rate_flag        IN     VARCHAR2  DEFAULT NULL
 ,p_allow_burd_cost_rate_flag       IN     VARCHAR2  DEFAULT NULL
 ,p_allow_bill_rate_flag            IN     VARCHAR2  DEFAULT NULL
 ,p_raw_cost_rate_tbl               IN     SYSTEM.pa_num_tbl_type          DEFAULT SYSTEM.pa_num_tbl_type()
 ,p_burd_cost_rate_tbl              IN     SYSTEM.pa_num_tbl_type          DEFAULT SYSTEM.pa_num_tbl_type()
 ,p_bill_rate_tbl                   IN     SYSTEM.pa_num_tbl_type          DEFAULT SYSTEM.pa_num_tbl_type()
 ,p_uom_tbl                         IN     SYSTEM.pa_varchar2_80_tbl_type  DEFAULT SYSTEM.pa_varchar2_80_tbl_type()
 ,p_planning_start_date_tbl         IN     SYSTEM.pa_date_tbl_type         DEFAULT SYSTEM.pa_date_tbl_type()
 ,p_planning_end_date_tbl           IN     SYSTEM.pa_date_tbl_type         DEFAULT SYSTEM.pa_date_tbl_type()
 ,p_delete_flag_tbl                 IN     SYSTEM.pa_varchar2_1_tbl_type   DEFAULT SYSTEM.pa_varchar2_1_tbl_type()
 ,p_mfc_cost_type_tbl               IN     SYSTEM.PA_VARCHAR2_15_TBL_TYPE  DEFAULT SYSTEM.PA_VARCHAR2_15_TBL_TYPE()
 ,p_spread_curve_name_tbl           IN     SYSTEM.PA_VARCHAR2_240_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_240_TBL_TYPE()
 ,p_sp_fixed_date_tbl               IN     SYSTEM.PA_DATE_TBL_TYPE         DEFAULT SYSTEM.PA_DATE_TBL_TYPE()
 ,p_etc_method_name_tbl             IN     SYSTEM.PA_VARCHAR2_80_TBL_TYPE  DEFAULT SYSTEM.PA_VARCHAR2_80_TBL_TYPE()
 ,p_spread_curve_id_tbl             IN     SYSTEM.PA_NUM_TBL_TYPE          DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
 ,p_amount_type_tbl                 IN     SYSTEM.PA_VARCHAR2_30_TBL_TYPE  DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE()
/* Bug 3986129: end */

 ,px_budget_lines_in                IN OUT NOCOPY PA_BUDGET_PUB.G_BUDGET_LINES_IN_TBL%TYPE --File.Sql.39 bug 4440895
 /* bug 3133930 included out pl/sql table */
 ,x_budget_lines_out                OUT    NOCOPY PA_BUDGET_PUB.G_BUDGET_LINES_OUT_TBL%TYPE --File.Sql.39 bug 4440895
 /* Bug 3986129: FP.M Web ADI Dev changes: New parameters added */
 ,x_mfc_cost_type_id_tbl            OUT    NOCOPY SYSTEM.pa_num_tbl_type --File.Sql.39 bug 4440895
 ,x_etc_method_code_tbl             OUT    NOCOPY SYSTEM.pa_varchar2_30_tbl_type --File.Sql.39 bug 4440895
 ,x_spread_curve_id_tbl             OUT    NOCOPY SYSTEM.pa_num_tbl_type --File.Sql.39 bug 4440895
 ,x_msg_count                       OUT    NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_data                        OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_return_status                   OUT    NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

/*=====================================================================
Procedure Name:      GET_FIN_PLAN_LINES_STATUS
This procedure is added as part of B and F AMG API changes. Tracking Bug - 3507156.
Patchset M: B and F impact changes : AMG
Purpose:              This API calls the following apis :
                      1) PA_FIN_PLAN_UTILS2.Get_AMG_BdgtLineRejctions

Parameters:
IN                   1)p_fin_plan_version_id IN pa_budget_versions.budget_version_id%TYPE
                     2)p_budget_lines_in IN PA_BUDGET_PUB.budget_line_in_tbl_type
=======================================================================*/

PROCEDURE GET_FIN_PLAN_LINES_STATUS
          (p_calling_context                 IN             VARCHAR2 DEFAULT NULL
          ,p_fin_plan_version_id             IN             pa_budget_versions.budget_version_id%TYPE
          ,p_budget_lines_in                 IN             PA_BUDGET_PUB.budget_line_in_tbl_type
          ,x_fp_lines_retn_status_tab        OUT NOCOPY     PA_BUDGET_PUB.budget_line_out_tbl_type
          ,x_return_status                   OUT NOCOPY     VARCHAR2
          ,x_msg_count                       OUT NOCOPY     NUMBER
          ,x_msg_data                        OUT NOCOPY     VARCHAR2);


-- Function             : Is_bc_enabled_for_budget
-- Purpose              : This functions returns true if a record exists in
--                        PA_BC_BALANCES table for the given budget version id
-- Parameters           : Budget Version Id.
--
FUNCTION Is_bc_enabled_for_budget
( p_budget_version_id   IN    NUMBER )
RETURN BOOLEAN;


/*================================================================================
Procedure Name : VALID_RATE_TYPE
Earlier this procedure was a local procedure to this package only. But now it has
has been made public as we need to use it directly from pa_budget_pub
=================================================================================*/
PROCEDURE VALID_RATE_TYPE
( p_pt_project_cost_rate_type   IN      pa_proj_fp_options.project_cost_rate_type%TYPE
 ,p_pt_project_rev_rate_type    IN      pa_proj_fp_options.project_rev_rate_type%TYPE
 ,p_pt_projfunc_cost_rate_type  IN      pa_proj_fp_options.projfunc_cost_rate_type%TYPE
 ,p_pt_projfunc_rev_rate_type   IN      pa_proj_fp_options.projfunc_rev_rate_type%TYPE
 ,p_pv_project_cost_rate_type   IN      pa_proj_fp_options.project_cost_rate_type%TYPE
 ,p_pv_project_rev_rate_type    IN      pa_proj_fp_options.project_rev_rate_type%TYPE
 ,p_pv_projfunc_cost_rate_type  IN      pa_proj_fp_options.projfunc_cost_rate_type%TYPE
 ,p_pv_projfunc_rev_rate_type   IN      pa_proj_fp_options.projfunc_rev_rate_type%TYPE
 ,x_is_rate_type_valid          OUT     NOCOPY BOOLEAN
 ,x_return_status               OUT     NOCOPY VARCHAR2
 ,x_msg_count                   OUT     NOCOPY NUMBER
 ,x_msg_data                    OUT     NOCOPY VARCHAR2
);


--Name:               Get_Latest_BC_Year
--Type:               Procedure
--Description:        For budgetary control projects, this procedure fetches the
--                    latest encumbrance year for the project's set-of-books.
--
--
--
--History:
--   27-SEP-2005    jwhite    Created per bug 4588279

PROCEDURE Get_Latest_BC_Year
( p_pa_project_id                IN      pa_projects_all.project_id%TYPE
  ,x_latest_encumbrance_year     OUT     NOCOPY gl_ledgers.Latest_Encumbrance_Year%TYPE
  ,x_return_status               OUT     NOCOPY VARCHAR2
  ,x_msg_count                   OUT     NOCOPY NUMBER
  ,x_msg_data                    OUT     NOCOPY VARCHAR2
);




end PA_BUDGET_PVT;

/
