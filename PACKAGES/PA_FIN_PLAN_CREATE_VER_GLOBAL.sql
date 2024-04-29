--------------------------------------------------------
--  DDL for Package PA_FIN_PLAN_CREATE_VER_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FIN_PLAN_CREATE_VER_GLOBAL" AUTHID CURRENT_USER as
/* $Header: PAFPCVGS.pls 120.1 2005/08/19 16:26:09 mwasowic noship $
   Start of Comments
   Package name     : PA_FIN_PLAN_CREATE_VER_GLOBAL
   Purpose          : API's for Org Forecast: Create Versions Page
   History          :
   NOTE             :
   End of Comments
*/

G_PROJECT_ID		NUMBER;
G_FIN_PLAN_TYPE_ID	NUMBER;
G_BUDGET_VERSION_ID	NUMBER;

function get_project_id return NUMBER;
function get_fin_plan_type_id return NUMBER;
function get_budget_version_id return NUMBER;


function get_lookup_planning_level
  (p_planning_level_code  IN  pa_proj_fp_options.all_fin_plan_level_code%TYPE)
return VARCHAR2;

function get_lookup_time_phase
  (p_time_phased_code  IN  pa_proj_fp_options.cost_time_phased_code%TYPE)
return VARCHAR2;

function get_resource_list_name
  (p_resource_list_id  IN  pa_resource_lists.resource_list_id%TYPE)
return VARCHAR2;

/* ==============================================================
   9/11/02 ADDED FUNCTIONS TO RETRIEVE GL/PA START/END PERIOD
   NAMES FOR CREATE VERSION PAGE
   ============================================================== */
FUNCTION get_gl_current_start_period
  (p_project_id		IN	pa_proj_period_profiles.project_id%TYPE)
return VARCHAR2;

FUNCTION get_gl_current_end_period
  (p_project_id		IN	pa_proj_period_profiles.project_id%TYPE)
return VARCHAR2;

FUNCTION get_pa_current_start_period
  (p_project_id		IN	pa_proj_period_profiles.project_id%TYPE)
return VARCHAR2;

FUNCTION get_pa_current_end_period
  (p_project_id		IN	pa_proj_period_profiles.project_id%TYPE)
return VARCHAR2;


procedure set_project_id
  (p_project_id		IN	pa_budget_versions.project_id%TYPE,
   x_return_status	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data		OUT	NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

procedure set_fin_plan_type_id
  (p_fin_plan_type_id	IN	pa_budget_versions.fin_plan_type_id%TYPE,
   x_return_status	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data		OUT	NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

procedure set_budget_version_id
  (p_budget_version_id	IN	pa_budget_versions.budget_version_id%TYPE,
   x_return_status	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data		OUT	NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

procedure set_global_values
  (p_project_id		IN	pa_budget_versions.project_id%TYPE,
   p_fin_plan_type_id	IN	pa_budget_versions.fin_plan_type_id%TYPE,
   p_budget_version_id	IN	pa_budget_versions.budget_version_id%TYPE,
   p_user_id              IN  NUMBER,
   x_locked_by_user_flag  OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_return_status	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data		OUT	NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

procedure get_start_end_period
  (x_period_start_date	OUT	NOCOPY pa_proj_fp_options.fin_plan_start_date%TYPE, --File.Sql.39 bug 4440895
   x_period_end_date	OUT	NOCOPY pa_proj_fp_options.fin_plan_end_date%TYPE, --File.Sql.39 bug 4440895
   x_return_status	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data		OUT	NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/* ========================================================
   HISTORY:
   8/21/02 -- added nvl to org_project_flag query: null --> 'N'
   8/22/02 -- added x_fin_plan_pref_code
   ======================================================== */
procedure Create_Versions_Init
	(p_project_id		IN	pa_projects_all.project_id%TYPE,
	 p_fin_plan_type_id	IN	pa_fin_plan_types_b.fin_plan_type_id%TYPE,
	 x_org_project_flag	OUT	NOCOPY pa_project_types_all.org_project_flag%TYPE, --File.Sql.39 bug 4440895
	 x_proj_fp_options_id	OUT	NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE, --File.Sql.39 bug 4440895
	 x_fin_plan_type_code	OUT	NOCOPY pa_fin_plan_types_b.fin_plan_type_code%TYPE, --File.Sql.39 bug 4440895
	 x_plan_class_code	OUT	NOCOPY pa_fin_plan_types_b.plan_class_code%TYPE, --File.Sql.39 bug 4440895
	 x_approved_budget_flag	OUT	NOCOPY pa_proj_fp_options.approved_cost_plan_type_flag%TYPE, --File.Sql.39 bug 4440895
	 x_fin_plan_pref_code	OUT	NOCOPY pa_proj_fp_options.fin_plan_preference_code%TYPE, --File.Sql.39 bug 4440895
	 x_return_status	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	 x_msg_count		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
	 x_msg_data		OUT	NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END pa_fin_plan_create_ver_global;

 

/
