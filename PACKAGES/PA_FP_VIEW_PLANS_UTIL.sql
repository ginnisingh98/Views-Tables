--------------------------------------------------------
--  DDL for Package PA_FP_VIEW_PLANS_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_VIEW_PLANS_UTIL" AUTHID CURRENT_USER as
/* $Header: PAFPVPUS.pls 120.1 2005/08/19 16:31:44 mwasowic noship $
   Start of Comments
   Package name     : pa_fin_plan_maint_ver_global
   Purpose          : API's for Financial Planning: View Plans Page
   History          :
   NOTE             :
   End of Comments
*/

function calculate_gl_total
       (p_amount_code               IN pa_amount_types_b.amount_type_code%TYPE,
        p_project_id                IN pa_resource_assignments.project_id%TYPE,
        p_task_id                   IN pa_resource_assignments.task_id%TYPE,
        p_resource_list_member_id   IN pa_resource_assignments.resource_list_member_id%TYPE)
  return NUMBER;

function calculate_pa_total
       (p_amount_code               IN pa_amount_types_b.amount_type_code%TYPE,
        p_project_id                IN pa_resource_assignments.project_id%TYPE,
        p_task_id                   IN pa_resource_assignments.task_id%TYPE,
        p_resource_list_member_id   IN pa_resource_assignments.resource_list_member_id%TYPE)
  return NUMBER;

function check_compatible_pd_profiles
    (p_period_profile_id1   IN  pa_proj_period_profiles.period_profile_id%TYPE,
     p_period_profile_id2   IN  pa_proj_period_profiles.period_profile_id%TYPE)
  return VARCHAR2;

function assign_row_level
    (p_project_id               IN  pa_resource_assignments.project_id%TYPE,
     p_task_id                  IN  pa_resource_assignments.task_id%TYPE,
     p_resource_list_member_id  IN  pa_resource_assignments.resource_list_member_id%TYPE)
  return NUMBER;

function assign_parent_element
    (p_project_id               IN  pa_resource_assignments.project_id%TYPE,
     p_task_id                  IN  pa_resource_assignments.task_id%TYPE,
     p_resource_list_member_id  IN  pa_resource_assignments.resource_list_member_id%TYPE)
  return VARCHAR2;

function assign_element_name
    (p_project_id               IN  pa_resource_assignments.project_id%TYPE,
     p_task_id                  IN  pa_resource_assignments.task_id%TYPE,
     p_resource_list_member_id  IN  pa_resource_assignments.resource_list_member_id%TYPE)
  return VARCHAR2;

function assign_element_level
    (p_project_id               IN  pa_resource_assignments.project_id%TYPE,
     p_budget_version_id	IN  pa_resource_assignments.budget_version_id%TYPE,
     p_task_id                  IN  pa_resource_assignments.task_id%TYPE,
     p_resource_list_member_id  IN  pa_resource_assignments.resource_list_member_id%TYPE)
  return VARCHAR2;

FUNCTION assign_flat_element_names
    (p_project_id               IN  pa_resource_assignments.project_id%TYPE,
     p_task_id                  IN  pa_resource_assignments.task_id%TYPE,
     p_resource_list_member_id  IN  pa_resource_assignments.resource_list_member_id%TYPE,
     p_element_type             IN  VARCHAR2)
  return VARCHAR2;

procedure assign_default_amount
    (p_budget_version_id           IN  pa_budget_versions.budget_version_id%TYPE,
     x_default_amount_type_code    OUT NOCOPY pa_proj_periods_denorm.amount_type_code%TYPE, --File.Sql.39 bug 4440895
     x_default_amount_subtype_code OUT NOCOPY pa_proj_periods_denorm.amount_subtype_code%TYPE, --File.Sql.39 bug 4440895
     x_return_status               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                   OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                    OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

function get_period_n_value
    (p_period_profile_id    IN  pa_proj_period_profiles.period_profile_id%TYPE,
     p_budget_version_id    IN  pa_budget_versions.budget_version_id%TYPE,
     p_resource_assignment_id IN pa_proj_periods_denorm.resource_assignment_id%TYPE,
     p_project_currency_type IN VARCHAR2,
     p_amount_type_id       IN  pa_proj_periods_denorm.amount_type_id%TYPE,
     p_period_number        IN  NUMBER) return NUMBER;

function calc_margin_percent
        (p_cost_value       IN NUMBER,
         p_rev_value        IN NUMBER) return NUMBER;


procedure refresh_period_profile
	(p_project_id		IN	pa_projects_all.project_id%TYPE,
	 p_budget_version_id1	IN	pa_budget_versions.budget_version_id%TYPE,
	 p_budget_version_id2	IN	pa_budget_versions.budget_version_id%TYPE,
	 x_return_status	OUT	NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	 x_msg_count		OUT	NOCOPY NUMBER, --File.Sql.39 bug 4440895
	 x_msg_data		OUT 	NOCOPY VARCHAR2);	 --File.Sql.39 bug 4440895

function has_period_profile_id
	(p_budget_version_id	IN	pa_budget_versions.budget_version_id%TYPE)
return VARCHAR2;

procedure roll_up_budget_lines
    (p_budget_version_id        in  pa_budget_versions.budget_version_id%TYPE,
     p_cost_or_rev              in  VARCHAR2);

-- FP L: used in View/Edit Plan page whenever navigation option to View/Edit
-- Plan Line page is chosen.  If the resource assignment has been deleted by
-- WBS, an error needs to be displayed
procedure check_res_assignment_exists
    (p_resource_assignment_id   IN   pa_resource_assignments.resource_assignment_id%TYPE,
     x_res_assignment_exists    OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_return_status            OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count                OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data                 OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-- FP L: used in View/Edit Plan page to determine if a plan version is planned
--       at a resource or resource group level (bug 2813661)
-- NOTE: THIS PROCEDURE IS USED ONLY FOR COLUMN DISPLAY PURPOSES: IT CONTAINS LOGIC
--       THAT IS USED TO HIDE/SHOW THE RESOURCE AND/OR RESOURCE GROUP COLUMNS.  IT
--       CONTAINS DISPLAY LOGIC THAT MAY NOT BE DIRECTLY RELEVANT TO THE ACTUAL
--       PLANNING LEVEL OF THE VERSION.
--       ** p_entered_amts_only_flag = 'Y' if this is used by the View Plan page
--          (query only rows with entered amts), and 'N' if used by Edit Plan page
procedure get_plan_version_res_level
  (p_budget_version_id	 IN  pa_budget_versions.budget_version_id%TYPE,
   p_entered_amts_only_flag IN VARCHAR2,
   x_resource_level	 OUT NOCOPY VARCHAR2,  -- 'R' = resource, 'G' = resource group,  --File.Sql.39 bug 4440895
					-- 'M' = mixed, 'N' = not applicable (ungrouped resource list)
   x_return_status	 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
   x_msg_count		 OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
   x_msg_data		 OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/* THE FOLLOWING ARE USED ONLY FOR TESTING PURPOSES */
TYPE number_data_type_table IS TABLE OF NUMBER
          INDEX BY BINARY_INTEGER;

TYPE char240_data_type_table IS TABLE OF VARCHAR2(240)
          INDEX BY BINARY_INTEGER;

FUNCTION get_amttype_id
  ( p_amt_typ_code     IN pa_amount_types_b.amount_type_code%TYPE) RETURN NUMBER;

end pa_fp_view_plans_util;

 

/
