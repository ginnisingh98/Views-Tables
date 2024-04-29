--------------------------------------------------------
--  DDL for Package PA_FP_VIEW_PLANS_TXN_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_VIEW_PLANS_TXN_PUB" AUTHID CURRENT_USER as
/* $Header: PAFPVPNS.pls 120.1 2005/08/19 16:31:34 mwasowic noship $
   Start of Comments
   Package name     : pa_fp_view_plans_txn_pub
   Purpose          : API's for Financial Planning: View Plans Non-Hgrid Page
   History          :
   NOTE             :
   End of Comments
*/

type vptxn_project_id_tab is
    TABLE of pa_resource_assignments.project_id%TYPE index by BINARY_INTEGER;
type vptxn_task_id_tab is
    TABLE of pa_resource_assignments.task_id%TYPE index by BINARY_INTEGER;
type vptxn_res_list_member_id_tab is
    TABLE of pa_resource_assignments.resource_list_member_id%TYPE index by BINARY_INTEGER;
type vptxn_res_assignment_id_tab is
    TABLE of pa_resource_assignments.resource_assignment_id%TYPE index by BINARY_INTEGER;
type vptxn_grouping_type_tab is
    TABLE OF VARCHAR2(30) index by BINARY_INTEGER;
type vptxn_unit_of_measure_tab is
    TABLE of pa_resource_assignments.unit_of_measure%TYPE index by BINARY_INTEGER;
type vptxn_quantity_tab is
    TABLE of pa_budget_lines.quantity%TYPE index by BINARY_INTEGER;
type vptxn_txn_currency_code_tab is
    TABLE of pa_budget_lines.txn_currency_code%TYPE index by BINARY_INTEGER;
type vptxn_txn_revenue_tab is
    TABLE of pa_budget_lines.txn_revenue%TYPE index by BINARY_INTEGER;
type vptxn_txn_burdened_cost_tab is
    TABLE of pa_budget_lines.txn_burdened_cost%TYPE index by BINARY_INTEGER;
type vptxn_txn_raw_cost_tab is
    TABLE of pa_budget_lines.txn_raw_cost%TYPE index by BINARY_INTEGER;


G_MULTI_CURR_FLAG		VARCHAR2(30); --Y/N
G_PLAN_TYPE_ID			NUMBER(15);
G_COST_VERSION_ID		NUMBER(15);
G_REV_VERSION_ID		NUMBER(15);
G_SINGLE_VERSION_ID		NUMBER(15); -- used only for gathering summary #'s
G_COST_RESOURCE_LIST_ID		NUMBER(15); -- for Resource Group, Resource LOV filter
G_REVENUE_RESOURCE_LIST_ID	NUMBER(15); -- for Resource Group, Resource LOV filter
G_REPORT_LABOR_HRS_FROM_CODE    pa_proj_fp_options.report_labor_hrs_from_code%TYPE;
G_DERIVE_MARGIN_FROM_CODE	VARCHAR2(30); -- R=rawcost, B=burdenedcost
G_DISPLAY_FROM			VARCHAR2(30); -- 'COST' = COST_ONLY version
					      -- 'REVENUE' = REVENUE_ONLY version
					      -- 'BOTH' = COST_AND_REV_SEP
					      -- 'ANY' = 'COST_AND_REV_SAME'
G_COST_VERSION_GROUPING		VARCHAR2(30); -- used in VO Decode for resource/resource group
G_REV_VERSION_GROUPING		VARCHAR2(30); -- used in VO Decode for resource/resource group
G_COST_RECORD_VERSION_NUM	pa_budget_versions.record_version_number%TYPE;
G_REV_RECORD_VERSION_NUM	pa_budget_versions.record_version_number%TYPE;
G_DISPLAY_CURRENCY_TYPE		VARCHAR2(30); -- 'PROJECT' or 'PROJFUNC' currency

function Get_Multicurrency_Flag return VARCHAR2;
function Get_Plan_Type_Id return NUMBER;
function Get_Cost_Version_Id return NUMBER;
function Get_Rev_Version_Id return NUMBER;
function Get_Single_Version_Id return NUMBER;  -- stores the passed-in budget version id
function Get_Cost_Resource_List_Id return NUMBER;
function Get_Revenue_Resource_List_Id return NUMBER;
function Get_Report_Labor_Hrs_From_Code return VARCHAR2;
function Get_Derive_Margin_From_Code return VARCHAR2;
function Get_Display_From return VARCHAR2;
function Get_Cost_Version_Grouping return VARCHAR2;
function Get_Rev_Version_Grouping return VARCHAR2;
function Get_Cost_RV_Num return NUMBER;
function Get_Rev_RV_Num return NUMBER;

-- BUG FIX 2615852: need to recognize if all txn currencies entered for a ra
function all_txn_currencies_entered
    (p_resource_assignment_id   IN  pa_resource_assignments.resource_assignment_id%TYPE)
  return VARCHAR2;

function get_task_name
     (p_task_id	 IN	pa_tasks.task_id%TYPE) return VARCHAR2;
function get_task_number
     (p_task_id	 IN	pa_tasks.task_id%TYPE) return VARCHAR2;
function get_resource_name
     (p_resource_id	IN	pa_resources.resource_id%TYPE) return VARCHAR2;

procedure nonhgrid_view_initialize
    (p_project_id           IN  pa_budget_versions.project_id%TYPE,
     p_cost_version_id      IN  pa_budget_versions.budget_version_id%TYPE,
     p_rev_version_id       IN  pa_budget_versions.budget_version_id%TYPE,
     p_user_id              IN  NUMBER,
--     x_budget_status_code   OUT pa_budget_versions.budget_status_code%TYPE,
     x_cost_budget_status_code   OUT NOCOPY pa_budget_versions.budget_status_code%TYPE, --File.Sql.39 bug 4440895
     x_rev_budget_status_code   OUT NOCOPY pa_budget_versions.budget_status_code%TYPE, --File.Sql.39 bug 4440895
     x_cost_version_id      OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
     x_rev_version_id       OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
     x_cost_rl_id           OUT NOCOPY pa_budget_versions.resource_list_id%TYPE, --File.Sql.39 bug 4440895
     x_rev_rl_id            OUT NOCOPY pa_budget_versions.resource_list_id%TYPE, --File.Sql.39 bug 4440895
--     x_cost_locked_id       OUT pa_budget_versions.locked_by_person_id%TYPE,
--     x_rev_locked_id        OUT pa_budget_versions.locked_by_person_id%TYPE,
     x_display_from         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_planned_resources_flag  OUT NOCOPY VARCHAR2,  -- valid values: 'Y', 'N' --File.Sql.39 bug 4440895
     x_grouping_type        OUT NOCOPY VARCHAR2,  -- valid values: 'GROUPED', 'NONGROUPED', 'MIXED' --File.Sql.39 bug 4440895
     x_planning_level       OUT NOCOPY VARCHAR2,  -- valid values: 'P', 'T', 'L', 'M' --File.Sql.39 bug 4440895
     x_multicurrency_flag   OUT NOCOPY VARCHAR2,  -- valid values: 'Y', 'N' --File.Sql.39 bug 4440895
     x_plan_type_name       OUT NOCOPY pa_fin_plan_types_tl.name%TYPE, --File.Sql.39 bug 4440895
     x_project_currency     OUT NOCOPY pa_projects_all.project_currency_code%TYPE, --File.Sql.39 bug 4440895
     x_labor_hrs_from_code  OUT NOCOPY pa_proj_fp_options.report_labor_hrs_from_code%TYPE, --File.Sql.39 bug 4440895
     x_cost_rv_number       OUT NOCOPY pa_budget_versions.record_version_number%TYPE, --File.Sql.39 bug 4440895
     x_rev_rv_number        OUT NOCOPY pa_budget_versions.record_version_number%TYPE, --File.Sql.39 bug 4440895
     x_cost_locked_name     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_rev_locked_name      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_ar_ac_flag           OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_plan_type_fp_options_id OUT NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE, --File.Sql.39 bug 4440895
     x_fin_plan_type_id     OUT NOCOPY pa_fin_plan_types_b.fin_plan_type_id%TYPE, --File.Sql.39 bug 4440895
     x_plan_class_code	    OUT NOCOPY VARCHAR2,  -- FP L: Plan Class Security --File.Sql.39 bug 4440895
     x_display_res_flag	    OUT NOCOPY VARCHAR2,  -- bug 3081511 --File.Sql.39 bug 4440895
     x_display_resgp_flag   OUT NOCOPY VARCHAR2,  -- bug 3081511 --File.Sql.39 bug 4440895
     x_auto_baselined_flag  OUT NOCOPY VARCHAR2,  -- bug 3146974 --File.Sql.39 bug 4440895
     x_return_status        OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count            OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    );
procedure nonhgrid_edit_initialize
    (p_project_id           IN  pa_budget_versions.project_id%TYPE,
     p_budget_version_id    IN  pa_budget_versions.budget_version_id%TYPE,
--     p_fin_plan_type_id     IN  pa_proj_fp_options.fin_plan_type_id%TYPE,
--     p_proj_fp_options_id   IN  pa_proj_fp_options.proj_fp_options_id%TYPE,
--     p_working_or_baselined IN  VARCHAR2,
--     p_cost_or_revenue      IN  VARCHAR2,
     x_budget_status_code   OUT NOCOPY pa_budget_versions.budget_status_code%TYPE, --File.Sql.39 bug 4440895
     x_current_working_flag OUT NOCOPY pa_budget_versions.current_working_flag%TYPE, --File.Sql.39 bug 4440895
     x_cost_version_id	    OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
     x_rev_version_id       OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
     x_cost_rl_id           OUT NOCOPY pa_budget_versions.resource_list_id%TYPE, --File.Sql.39 bug 4440895
     x_rev_rl_id            OUT	NOCOPY pa_budget_versions.resource_list_id%TYPE, --File.Sql.39 bug 4440895
     x_display_from         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_planned_resources_flag  OUT NOCOPY VARCHAR2,  -- valid values: 'Y', 'N' --File.Sql.39 bug 4440895
     x_grouping_type        OUT NOCOPY VARCHAR2,     -- valid values: 'GROUPED', 'NONGROUPED', 'MIXED' --File.Sql.39 bug 4440895
     x_planning_level       OUT NOCOPY VARCHAR2,     -- valid values: 'P', 'T', 'L', 'M' --File.Sql.39 bug 4440895
     x_multicurrency_flag   OUT NOCOPY VARCHAR2,     -- valid values: 'Y', 'N' --File.Sql.39 bug 4440895
     x_plan_type_name       OUT NOCOPY pa_fin_plan_types_tl.name%TYPE, --File.Sql.39 bug 4440895
     x_project_currency     OUT NOCOPY pa_projects_all.project_currency_code%TYPE, --File.Sql.39 bug 4440895
     x_record_version_number OUT NOCOPY pa_budget_versions.record_version_number%TYPE, --File.Sql.39 bug 4440895
     x_plan_type_fp_options_id OUT NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE, --File.Sql.39 bug 4440895
     x_plan_version_fp_options_id OUT NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE, --File.Sql.39 bug 4440895
     x_fin_plan_type_id	    OUT NOCOPY pa_fin_plan_types_b.fin_plan_type_id%TYPE, --File.Sql.39 bug 4440895
     x_ar_ac_flag	    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_auto_baselined_flag  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_plan_class_code	    OUT NOCOPY VARCHAR2,  -- FP L: Plan Class Security --File.Sql.39 bug 4440895
     x_display_res_flag	    OUT NOCOPY VARCHAR2,  -- bug 3081511 --File.Sql.39 bug 4440895
     x_display_resgp_flag   OUT NOCOPY VARCHAR2,  -- bug 3081511 --File.Sql.39 bug 4440895
     x_return_status	    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count	    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data		    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    );

procedure view_plans_txn_populate_tmp
    (p_page_mode             IN   VARCHAR2, /* V - View mode ; E - Edit Mode */
     p_project_id            IN   pa_budget_versions.project_id%TYPE,
     p_cost_version_id       IN   pa_budget_versions.budget_version_id%TYPE,
     p_revenue_version_id    IN   pa_budget_versions.budget_version_id%TYPE,
     p_both_version_id       IN   pa_budget_versions.budget_version_id%TYPE,
     p_project_currency      IN   pa_projects_all.project_currency_code%TYPE,
     p_get_display_from      IN   VARCHAR2,  -- 'COST', 'REVENUE', 'BOTH', 'ANY'
     p_filter_task_id        IN   pa_resource_assignments.task_id%TYPE,
     p_filter_resource_id    IN   pa_resource_list_members.resource_id%TYPE,
     p_filter_rlm_id         IN   pa_resource_assignments.resource_list_member_id%TYPE,
     p_filter_txncurrency    IN   pa_budget_lines.txn_currency_code%TYPE,
     x_return_status         OUT   NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count             OUT   NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data              OUT   NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-----------  BEGIN OF CHANGE ORDER / CONTROL ITEM -------------

procedure nonhgrid_view_initialize_ci
    (p_project_id           IN  pa_budget_versions.project_id%TYPE,
     p_ci_id    	    IN  pa_budget_versions.ci_id%TYPE,
     p_user_id		    IN  NUMBER,
     x_budget_status_code   OUT NOCOPY pa_budget_versions.budget_status_code%TYPE, --File.Sql.39 bug 4440895
     x_cost_version_id	    OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
     x_rev_version_id       OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
     x_cost_rl_id           OUT NOCOPY pa_budget_versions.resource_list_id%TYPE, --File.Sql.39 bug 4440895
     x_rev_rl_id            OUT	NOCOPY pa_budget_versions.resource_list_id%TYPE, --File.Sql.39 bug 4440895
     x_display_from         OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_planned_resources_flag  OUT NOCOPY VARCHAR2,  -- valid values: 'Y', 'N' --File.Sql.39 bug 4440895
     x_grouping_type        OUT NOCOPY VARCHAR2,     -- valid values: 'GROUPED', 'NONGROUPED', 'MIXED' --File.Sql.39 bug 4440895
     x_planning_level       OUT NOCOPY VARCHAR2,     -- valid values: 'P', 'T', 'L', 'M' --File.Sql.39 bug 4440895
     x_multicurrency_flag   OUT NOCOPY VARCHAR2,     -- valid values: 'Y', 'N' --File.Sql.39 bug 4440895
     x_plan_type_name       OUT NOCOPY pa_fin_plan_types_tl.name%TYPE, --File.Sql.39 bug 4440895
     x_project_currency     OUT NOCOPY pa_projects_all.project_currency_code%TYPE, --File.Sql.39 bug 4440895
     x_labor_hrs_from_code  OUT NOCOPY pa_proj_fp_options.report_labor_hrs_from_code%TYPE, --File.Sql.39 bug 4440895
     x_cost_rv_number       OUT NOCOPY pa_budget_versions.record_version_number%TYPE, --File.Sql.39 bug 4440895
     x_rev_rv_number        OUT NOCOPY pa_budget_versions.record_version_number%TYPE, --File.Sql.39 bug 4440895
     x_cost_locked_name	    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_rev_locked_name	    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_ar_ac_flag	    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_plan_type_fp_options_id OUT NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE, --File.Sql.39 bug 4440895
     x_fin_plan_type_id	    OUT NOCOPY pa_fin_plan_types_b.fin_plan_type_id%TYPE, --File.Sql.39 bug 4440895
     x_auto_baselined_flag  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_display_res_flag	    OUT NOCOPY VARCHAR2,  -- bug 3081511 --File.Sql.39 bug 4440895
     x_display_resgp_flag   OUT NOCOPY VARCHAR2,  -- bug 3081511 --File.Sql.39 bug 4440895
     x_return_status	    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count	    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data		    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    );

procedure calculate_amounts_for_version
    ( p_budget_version_id      IN  pa_budget_versions.budget_version_id%TYPE
     ,p_calling_context        IN  VARCHAR2
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    );

end pa_fp_view_plans_txn_pub;

 

/
