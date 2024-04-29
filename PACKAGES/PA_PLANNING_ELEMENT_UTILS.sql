--------------------------------------------------------
--  DDL for Package PA_PLANNING_ELEMENT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PLANNING_ELEMENT_UTILS" AUTHID CURRENT_USER AS
/* $Header: PAFPPEUS.pls 120.3.12010000.4 2009/10/09 06:34:19 rrambati ship $
   Start of Comments
   Package name     : PA_FIN_PLAN_UTILS
   Purpose          : utility API's for Org Forecast pages
   History          :
   NOTE             :
   End of Comments
*/

/* This procedure should be used for the Workplan Task Details page ONLY!
 */
PROCEDURE get_workplan_bvids
  (p_project_id           IN  pa_budget_versions.project_id%TYPE,
   p_element_version_id   IN  pa_proj_element_versions.element_version_id%TYPE,
   x_current_version_id   OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
   x_baselined_version_id OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
   x_published_version_id OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
   x_return_status        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data             OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE get_finplan_bvids
  (p_project_id          IN  pa_budget_versions.project_id%TYPE,
   p_budget_version_id   IN  pa_budget_versions.budget_version_id%TYPE,
   p_view_plan_flag      IN  VARCHAR2 default 'N',
   x_current_version_id  OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
   x_original_version_id OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
   x_prior_fcst_version_id OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
   x_return_status       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data            OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION get_task_name_and_number
  (p_project_or_task IN VARCHAR2,  -- 'PROJECT' or 'TASK'
   p_resource_assignment_id IN pa_resource_assignments.resource_assignment_id%TYPE) return VARCHAR2;

-- Bug 4057673. Added a parameter p_fin_plan_level_code. It will be either 'P','L' or 'M'
--depending on the planning level of the budget version
FUNCTION get_project_task_level
  (p_resource_assignment_id   IN pa_resource_assignments.resource_assignment_id%TYPE,
   p_fin_plan_level_code      IN pa_proj_fp_options.cost_fin_plan_level_code%TYPE) return VARCHAR2;

FUNCTION get_res_class_name
  (p_res_class_code IN pa_resource_classes_b.resource_class_code%TYPE) return VARCHAR2;

FUNCTION get_res_type_name
  (p_res_type_code IN pa_res_types_b.res_type_code%TYPE) return VARCHAR2;

FUNCTION get_project_role_name
  (p_project_role_id IN pa_project_role_types_b.project_role_id%TYPE) return VARCHAR2;

FUNCTION get_supplier_name
  (p_supplier_id IN po_vendors.vendor_id%TYPE) return VARCHAR2;

FUNCTION get_schedule_role_name
  (p_proj_assignment_id IN pa_project_assignments.assignment_id%TYPE) return VARCHAR2;

FUNCTION get_spread_curve_name
  (p_spread_curve_id IN pa_spread_curves_b.spread_curve_id%TYPE) return VARCHAR2;

FUNCTION get_mfc_cost_type_name
  (p_mfc_cost_type_id IN pa_resource_assignments.mfc_cost_type_id%TYPE) return VARCHAR2;

FUNCTION get_project_uncat_rlmid return NUMBER;

PROCEDURE get_common_budget_version_info
  (p_budget_version_id       IN  pa_budget_versions.budget_version_id%TYPE,
   p_resource_assignment_id  IN  pa_resource_assignments.resource_assignment_id%TYPE,
   p_project_currency_code   IN  pa_projects_all.project_currency_code%TYPE,
   p_projfunc_currency_code  IN  pa_projects_all.projfunc_currency_code%TYPE,
   p_txn_currency_code       IN  pa_budget_lines.txn_currency_code%TYPE,
   p_line_start_date         IN  pa_budget_lines.start_date%TYPE := to_date(NULL),
   p_line_end_date           IN  pa_budget_lines.end_date%TYPE := to_date(NULL),
   x_budget_version_id       OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
   x_planning_start_date     OUT NOCOPY pa_resource_assignments.planning_start_date%TYPE, --File.Sql.39 bug 4440895
   x_planning_end_date       OUT NOCOPY pa_resource_assignments.planning_end_date%TYPE, --File.Sql.39 bug 4440895
   x_schedule_start_date     OUT NOCOPY pa_resource_assignments.schedule_start_date%TYPE, --File.Sql.39 bug 4440895
   x_schedule_end_date	     OUT NOCOPY pa_resource_assignments.schedule_start_date%TYPE, --File.Sql.39 bug 4440895
   x_quantity                OUT NOCOPY pa_resource_assignments.total_plan_quantity%TYPE, --File.Sql.39 bug 4440895
   x_revenue_txn_cur         OUT NOCOPY pa_budget_lines.txn_revenue%TYPE, --File.Sql.39 bug 4440895
   x_revenue_proj_cur        OUT NOCOPY pa_resource_assignments.total_project_revenue%TYPE, --File.Sql.39 bug 4440895
   x_revenue_proj_func_cur   OUT NOCOPY pa_resource_assignments.total_plan_revenue%TYPE, --File.Sql.39 bug 4440895
   x_raw_cost_txn_cur        OUT NOCOPY pa_budget_lines.txn_raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_raw_cost_proj_cur       OUT NOCOPY pa_resource_assignments.total_project_raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_raw_cost_proj_func_cur  OUT NOCOPY pa_resource_assignments.total_plan_raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_burd_cost_txn_cur       OUT NOCOPY pa_budget_lines.txn_burdened_cost%TYPE, --File.Sql.39 bug 4440895
   x_burd_cost_proj_cur      OUT NOCOPY pa_resource_assignments.total_project_burdened_cost%TYPE, --File.Sql.39 bug 4440895
   x_burd_cost_proj_func_cur OUT NOCOPY pa_resource_assignments.total_plan_burdened_cost%TYPE, --File.Sql.39 bug 4440895
--   x_burd_multiplier         OUT pa_budget_lines.txn_burden_multiplier%TYPE, -- FPM2 data model upgrade
   x_init_rev_rate           OUT NOCOPY pa_budget_lines.txn_standard_bill_rate%TYPE, --File.Sql.39 bug 4440895
   x_avg_rev_rate            OUT NOCOPY pa_budget_lines.txn_standard_bill_rate%TYPE, --File.Sql.39 bug 4440895
   x_init_raw_cost_rate      OUT NOCOPY pa_budget_lines.txn_standard_cost_rate%TYPE, --File.Sql.39 bug 4440895
   x_avg_raw_cost_rate       OUT NOCOPY pa_budget_lines.txn_standard_cost_rate%TYPE, --File.Sql.39 bug 4440895
   x_init_burd_cost_rate     OUT NOCOPY pa_budget_lines.txn_standard_cost_rate%TYPE, --File.Sql.39 bug 4440895
   x_avg_burd_cost_rate      OUT NOCOPY pa_budget_lines.txn_standard_cost_rate%TYPE, --File.Sql.39 bug 4440895
   x_margin_txn_cur          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_margin_proj_cur         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_margin_proj_func_cur    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_margin_pct              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_etc_avg_rev_rate	     OUT NOCOPY pa_budget_lines.txn_standard_bill_rate%TYPE, --File.Sql.39 bug 4440895
   x_etc_avg_raw_cost_rate   OUT NOCOPY pa_budget_lines.txn_standard_bill_rate%TYPE, --File.Sql.39 bug 4440895
   x_etc_avg_burd_cost_rate  OUT NOCOPY pa_budget_lines.txn_standard_bill_rate%TYPE, --File.Sql.39 bug 4440895
   x_return_status           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count               OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE get_common_bv_info_fcst
  (p_budget_version_id       IN  pa_budget_versions.budget_version_id%TYPE,
   p_resource_assignment_id  IN  pa_resource_assignments.resource_assignment_id%TYPE,
   p_project_currency_code   IN  pa_projects_all.project_currency_code%TYPE,
   p_projfunc_currency_code  IN  pa_projects_all.projfunc_currency_code%TYPE,
   p_txn_currency_code       IN  pa_budget_lines.txn_currency_code%TYPE,
   p_line_start_date         IN  pa_budget_lines.start_date%TYPE := to_date(NULL),
   p_line_end_date           IN  pa_budget_lines.end_date%TYPE := to_date(NULL),
   x_budget_version_id       OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
   x_planning_start_date     OUT NOCOPY pa_resource_assignments.planning_start_date%TYPE, --File.Sql.39 bug 4440895
   x_planning_end_date       OUT NOCOPY pa_resource_assignments.planning_end_date%TYPE, --File.Sql.39 bug 4440895
   x_schedule_start_date     OUT NOCOPY pa_resource_assignments.schedule_start_date%TYPE, --File.Sql.39 bug 4440895
   x_schedule_end_date	     OUT NOCOPY pa_resource_assignments.schedule_start_date%TYPE, --File.Sql.39 bug 4440895
   x_act_quantity            OUT NOCOPY pa_resource_assignments.total_plan_quantity%TYPE, --File.Sql.39 bug 4440895
   x_etc_quantity            OUT NOCOPY pa_resource_assignments.total_plan_quantity%TYPE, --File.Sql.39 bug 4440895
   x_fcst_quantity           OUT NOCOPY pa_resource_assignments.total_plan_quantity%TYPE, --File.Sql.39 bug 4440895
   x_act_revenue_txn_cur         OUT NOCOPY pa_budget_lines.txn_revenue%TYPE, --File.Sql.39 bug 4440895
   x_act_revenue_proj_cur        OUT NOCOPY pa_resource_assignments.total_project_revenue%TYPE, --File.Sql.39 bug 4440895
   x_act_revenue_proj_func_cur   OUT NOCOPY pa_resource_assignments.total_plan_revenue%TYPE, --File.Sql.39 bug 4440895
   x_etc_revenue_txn_cur         OUT NOCOPY pa_budget_lines.txn_revenue%TYPE, --File.Sql.39 bug 4440895
   x_etc_revenue_proj_cur        OUT NOCOPY pa_resource_assignments.total_project_revenue%TYPE, --File.Sql.39 bug 4440895
   x_etc_revenue_proj_func_cur   OUT NOCOPY pa_resource_assignments.total_plan_revenue%TYPE, --File.Sql.39 bug 4440895
   x_fcst_revenue_txn_cur         OUT NOCOPY pa_budget_lines.txn_revenue%TYPE, --File.Sql.39 bug 4440895
   x_fcst_revenue_proj_cur        OUT NOCOPY pa_resource_assignments.total_project_revenue%TYPE, --File.Sql.39 bug 4440895
   x_fcst_revenue_proj_func_cur   OUT NOCOPY pa_resource_assignments.total_plan_revenue%TYPE, --File.Sql.39 bug 4440895
   x_act_raw_cost_txn_cur        OUT NOCOPY pa_budget_lines.txn_raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_act_raw_cost_proj_cur       OUT NOCOPY pa_resource_assignments.total_project_raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_act_raw_cost_proj_func_cur  OUT NOCOPY pa_resource_assignments.total_plan_raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_etc_raw_cost_txn_cur        OUT NOCOPY pa_budget_lines.txn_raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_etc_raw_cost_proj_cur       OUT NOCOPY pa_resource_assignments.total_project_raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_etc_raw_cost_proj_func_cur  OUT NOCOPY pa_resource_assignments.total_plan_raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_fcst_raw_cost_txn_cur        OUT NOCOPY pa_budget_lines.txn_raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_fcst_raw_cost_proj_cur       OUT NOCOPY pa_resource_assignments.total_project_raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_fcst_raw_cost_proj_func_cur  OUT NOCOPY pa_resource_assignments.total_plan_raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_act_burd_cost_txn_cur       OUT NOCOPY pa_budget_lines.txn_burdened_cost%TYPE, --File.Sql.39 bug 4440895
   x_act_burd_cost_proj_cur      OUT NOCOPY pa_resource_assignments.total_project_burdened_cost%TYPE, --File.Sql.39 bug 4440895
   x_act_burd_cost_proj_func_cur OUT NOCOPY pa_resource_assignments.total_plan_burdened_cost%TYPE, --File.Sql.39 bug 4440895
   x_etc_burd_cost_txn_cur       OUT NOCOPY pa_budget_lines.txn_burdened_cost%TYPE, --File.Sql.39 bug 4440895
   x_etc_burd_cost_proj_cur      OUT NOCOPY pa_resource_assignments.total_project_burdened_cost%TYPE, --File.Sql.39 bug 4440895
   x_etc_burd_cost_proj_func_cur OUT NOCOPY pa_resource_assignments.total_plan_burdened_cost%TYPE, --File.Sql.39 bug 4440895
   x_fcst_burd_cost_txn_cur       OUT NOCOPY pa_budget_lines.txn_burdened_cost%TYPE, --File.Sql.39 bug 4440895
   x_fcst_burd_cost_proj_cur      OUT NOCOPY pa_resource_assignments.total_project_burdened_cost%TYPE, --File.Sql.39 bug 4440895
   x_fcst_burd_cost_proj_func_cur OUT NOCOPY pa_resource_assignments.total_plan_burdened_cost%TYPE, --File.Sql.39 bug 4440895
   x_act_rev_rate           OUT NOCOPY pa_budget_lines.txn_standard_bill_rate%TYPE, --File.Sql.39 bug 4440895
   x_etc_init_rev_rate           OUT NOCOPY pa_budget_lines.txn_standard_bill_rate%TYPE, --File.Sql.39 bug 4440895
   x_etc_avg_rev_rate            OUT NOCOPY pa_budget_lines.txn_standard_bill_rate%TYPE, --File.Sql.39 bug 4440895
   x_act_raw_cost_rate      OUT NOCOPY pa_budget_lines.txn_standard_cost_rate%TYPE, --File.Sql.39 bug 4440895
   x_etc_init_raw_cost_rate      OUT NOCOPY pa_budget_lines.txn_standard_cost_rate%TYPE, --File.Sql.39 bug 4440895
   x_etc_avg_raw_cost_rate       OUT NOCOPY pa_budget_lines.txn_standard_cost_rate%TYPE, --File.Sql.39 bug 4440895
   x_act_burd_cost_rate     OUT NOCOPY pa_budget_lines.txn_standard_cost_rate%TYPE, --File.Sql.39 bug 4440895
   x_etc_init_burd_cost_rate     OUT NOCOPY pa_budget_lines.txn_standard_cost_rate%TYPE, --File.Sql.39 bug 4440895
   x_etc_avg_burd_cost_rate      OUT NOCOPY pa_budget_lines.txn_standard_cost_rate%TYPE, --File.Sql.39 bug 4440895
   x_act_margin_txn_cur          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_act_margin_proj_cur         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_act_margin_proj_func_cur    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_etc_margin_txn_cur          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_etc_margin_proj_cur         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_etc_margin_proj_func_cur    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_fcst_margin_txn_cur          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_fcst_margin_proj_cur         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_fcst_margin_proj_func_cur    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_act_margin_pct              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_etc_margin_pct              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_fcst_margin_pct              OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_return_status           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count               OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data                OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

procedure get_initial_budget_line_info
  (p_resource_assignment_id	IN  pa_resource_assignments.resource_assignment_id%TYPE,
   P_txn_currency_code		IN  pa_budget_lines.txn_currency_code%TYPE,
   p_line_start_date            IN  pa_budget_lines.start_date%TYPE := to_date(NULL),
   p_line_end_date              IN  pa_budget_lines.end_date%TYPE := to_date(NULL),
   x_start_date			OUT NOCOPY pa_budget_lines.start_date%TYPE, --File.Sql.39 bug 4440895
   x_end_date			OUT NOCOPY pa_budget_lines.end_date%TYPE, --File.Sql.39 bug 4440895
   x_period_name		OUT NOCOPY pa_budget_lines.period_name%TYPE, --File.Sql.39 bug 4440895
   x_quantity			OUT NOCOPY pa_budget_lines.quantity%TYPE, --File.Sql.39 bug 4440895
   x_txn_raw_cost		OUT NOCOPY pa_budget_lines.raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_txn_burdened_cost		OUT NOCOPY pa_budget_lines.burdened_cost%TYPE, --File.Sql.39 bug 4440895
   x_txn_revenue		OUT NOCOPY pa_budget_lines.revenue%TYPE, --File.Sql.39 bug 4440895
   x_init_quantity		OUT NOCOPY pa_budget_lines.init_quantity%TYPE, --File.Sql.39 bug 4440895
   x_txn_init_raw_cost		OUT NOCOPY pa_budget_lines.txn_init_raw_cost%TYPE, --File.Sql.39 bug 4440895
   x_txn_init_burdened_cost	OUT NOCOPY pa_budget_lines.txn_init_burdened_cost%TYPE, --File.Sql.39 bug 4440895
   x_txn_init_revenue		OUT NOCOPY pa_budget_lines.txn_init_revenue%TYPE, --File.Sql.39 bug 4440895
   x_init_raw_cost_rate		OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_init_burd_cost_rate	OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_init_revenue_rate		OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_etc_init_raw_cost_rate     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_etc_init_burd_cost_rate	OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_etc_init_revenue_rate	OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_return_status		OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count			OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data			OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


PROCEDURE add_new_resource_assignments
  (p_context			IN	VARCHAR2,
   p_project_id			IN	pa_budget_versions.project_id%TYPE,
   p_budget_version_id		IN	pa_budget_versions.budget_version_id%TYPE,
   p_task_elem_version_id_tbl	IN	SYSTEM.pa_num_tbl_type DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
   p_resource_list_member_id_tbl IN	SYSTEM.pa_num_tbl_type DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
   p_quantity_tbl		IN	SYSTEM.pa_num_tbl_type DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
   p_currency_code_tbl		IN	SYSTEM.PA_VARCHAR2_15_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_15_TBL_TYPE(),
   p_raw_cost_tbl		IN	SYSTEM.pa_num_tbl_type DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
   p_burdened_cost_tbl		IN	SYSTEM.pa_num_tbl_type DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
   p_revenue_tbl		IN	SYSTEM.pa_num_tbl_type DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
   p_cost_rate_tbl		IN	SYSTEM.pa_num_tbl_type DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
   p_bill_rate_tbl		IN	SYSTEM.pa_num_tbl_type DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
   p_burdened_rate_tbl		IN	SYSTEM.pa_num_tbl_type DEFAULT SYSTEM.PA_NUM_TBL_TYPE(),
   p_unplanned_flag_tbl		IN	SYSTEM.PA_VARCHAR2_1_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_1_TBL_TYPE(),
   p_expenditure_type_tbl    IN  SYSTEM.PA_VARCHAR2_30_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_30_TBL_TYPE(), --added for Enc
   x_return_status		OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count			OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data			OUT 	NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/* This procedure is used to retrieve:
   FND_API.G_MISS_NUM (x_num)
   FND_API.G_MISS_CHAR (x_char)
   FND_API.G_MISS_DATE (x_date)
   so it can be passed to the Java-side for further use
*/
PROCEDURE get_fnd_miss_constants
   (x_num  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_char OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_date OUT NOCOPY DATE); --File.Sql.39 bug 4440895

FUNCTION get_bv_name_from_id
   (p_budget_version_id  IN pa_budget_versions.budget_version_id%TYPE) return VARCHAR2;

--Created for bug 3546208. This function will return the financial structure version id for the project
--id passed.
FUNCTION get_fin_struct_id(p_project_id        pa_projects_all.project_id%TYPE,
                           p_budget_version_id pa_budget_versions.budget_Version_id%TYPE)
RETURN NUMBER;

-- This function returns the wbs element name, either from the wbs_element_version_id
-- or from the proj_element_id.  If using proj_element_id, then p_use_element_version_id_flag
-- must be set to 'N'
FUNCTION get_wbs_element_name_from_id
   (p_project_id	      IN  pa_projects_all.project_id%TYPE,
    p_wbs_element_version_id  IN  pa_resource_assignments.wbs_element_version_id%TYPE,
    p_wbs_project_element_id  IN  pa_proj_element_versions.proj_element_id%TYPE,
    p_use_element_version_flag IN VARCHAR2) return VARCHAR2;

FUNCTION get_proj_element_id
   (p_wbs_element_version_id  IN  pa_proj_element_versions.element_version_id%TYPE) return NUMBER;

FUNCTION get_rbs_element_name_from_id
    (p_rbs_element_version_id  IN  pa_rbs_elements.rbs_element_id%TYPE) return VARCHAR2;

FUNCTION get_task_percent_complete
    (p_project_id	     IN pa_projects_all.project_id%TYPE,
     p_budget_version_id     IN pa_budget_versions.budget_version_id%TYPE,
     p_proj_element_id       IN pa_proj_element_versions.proj_element_id%TYPE,
     p_calling_context       IN VARCHAR2) return NUMBER;

/* Bug 5524803: Added the below function to return the prior forecast version id
 * to be used by PJI.
 */
FUNCTION get_prior_forecast_version_id
  (p_plan_version_id   IN  pa_budget_versions.budget_version_id%TYPE,
   p_project_id          IN  pa_projects_all.project_id%TYPE
  ) RETURN NUMBER;

end pa_planning_element_utils;

/
