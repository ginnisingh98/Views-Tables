--------------------------------------------------------
--  DDL for Package PA_FIN_PLAN_MAINT_VER_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FIN_PLAN_MAINT_VER_GLOBAL" AUTHID CURRENT_USER as
/* $Header: PAFPMVGS.pls 120.3.12010000.3 2009/06/25 11:02:31 rthumma ship $
   Start of Comments
   Package name     : PA_FIN_PLAN_MAINT_VER_GLOBAL
   Purpose          : API's for Org Forecast: Maintain Versions Page
   History          :
   NOTE             :
   End of Comments
*/

G_PROJECT_ID		NUMBER;
G_FIN_PLAN_TYPE_ID	NUMBER;
G_LOGIN_PERSON_ID	NUMBER;

G_SECURITY_S              VARCHAR2(1); /* Added for bug 5737980 */
G_SECURITY_R              VARCHAR2(1); /* Added for bug 5737980 */
G_SECURITY_B              VARCHAR2(1); /* Added for bug 5737980 */


function get_project_id return NUMBER;
function get_fin_plan_type_id return NUMBER;
function get_login_person_id return NUMBER;
function get_fin_plan_security(SecurityType IN VARCHAR2) return VARCHAR2; /* Added for bug 5737980 */

procedure set_global_finplan_security  /* Added for bug 5737980 */
         ( paFinplanSecType  IN  VARCHAR2,
           paFinplanSec      IN  VARCHAR2 := NULL,
           x_return_status   OUT NOCOPY VARCHAR2,
           x_msg_count       OUT NOCOPY  NUMBER,
           x_msg_data        OUT NOCOPY VARCHAR2 );

procedure set_global_values
	(p_project_id		IN	pa_projects_all.project_id%TYPE,
	 p_fin_plan_type_id	IN	pa_fin_plan_types_b.fin_plan_type_id%TYPE,
	 p_user_id		IN	VARCHAR2,
	 x_return_status	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	 x_msg_count		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
	 x_msg_data		OUT	NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

procedure Maintain_Versions_Init
	(p_project_id		IN	pa_projects_all.project_id%TYPE,
	 p_fin_plan_options_id	IN	pa_proj_fp_options.proj_fp_options_id%TYPE,
	 p_fin_plan_type_id	IN	pa_fin_plan_types_b.fin_plan_type_id%TYPE,
	 x_fin_plan_type_name	OUT	NOCOPY pa_fin_plan_types_tl.name%TYPE, --File.Sql.39 bug 4440895
	 x_fin_plan_pref_code	OUT	NOCOPY pa_proj_fp_options.fin_plan_preference_code%TYPE, --File.Sql.39 bug 4440895
	 x_org_project_flag	OUT	NOCOPY pa_project_types_all.org_project_flag%TYPE, --File.Sql.39 bug 4440895
	 x_currency_code	OUT	NOCOPY pa_projects_all.projfunc_currency_code%TYPE,	 --File.Sql.39 bug 4440895
	 x_proj_currency_code	OUT	NOCOPY pa_projects_all.project_currency_code%TYPE, --File.Sql.39 bug 4440895
	 x_fin_plan_type_code	OUT	NOCOPY pa_fin_plan_types_b.fin_plan_type_code%TYPE, --File.Sql.39 bug 4440895
	 x_fin_plan_class_code	OUT	NOCOPY pa_fin_plan_types_b.plan_class_code%TYPE, --File.Sql.39 bug 4440895
	 x_derive_margin_from_code OUT  NOCOPY pa_proj_fp_options.margin_derived_from_code%TYPE, --File.Sql.39 bug 4440895
	 x_report_labor_hrs_code OUT  NOCOPY pa_proj_fp_options.report_labor_hrs_from_code%TYPE, --File.Sql.39 bug 4440895
	 x_auto_baseline_flag	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	 x_ar_flag		OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
         x_plan_type_processing_code OUT NOCOPY pa_proj_fp_options.plan_processing_code%TYPE, --File.Sql.39 bug 4440895
         x_navg_inc_co_code OUT    NOCOPY VARCHAR2,--Bug 5845142
	 x_return_status	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	 x_msg_count		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
	 x_msg_data		OUT	NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

procedure Create_Working_Copy
    (p_project_id               IN      pa_budget_versions.project_id%TYPE,
     p_source_version_id        IN      pa_budget_versions.budget_version_id%TYPE,
     p_copy_mode                IN      VARCHAR2,
     p_adj_percentage           IN      NUMBER DEFAULT 0,
     p_calling_module           IN      VARCHAR2 DEFAULT PA_FP_CONSTANTS_PKG.G_CALLING_MODULE_ORG_FORECAST,
     px_target_version_id       IN  OUT NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
     x_return_status                OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                     OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Resubmit_Concurrent_Process
    (p_project_id		IN	pa_projects_all.project_id%TYPE,
     x_return_status                OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                    OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                     OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END pa_fin_plan_maint_ver_global;

/
