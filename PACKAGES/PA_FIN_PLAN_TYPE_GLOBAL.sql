--------------------------------------------------------
--  DDL for Package PA_FIN_PLAN_TYPE_GLOBAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FIN_PLAN_TYPE_GLOBAL" AUTHID CURRENT_USER as
/* $Header: PAFPPTGS.pls 120.1 2005/08/19 16:28:34 mwasowic noship $
   Start of Comments
   Package name     : PA_FIN_PLAN_TYPE_GLOBAL
   Purpose          : API's for Org Forecast: PLANS Page
   History          :
   NOTE             :
   End of Comments
*/

G_PROJECT_ID		NUMBER;
--G_PLAN_CLASS_CODE	VARCHAR2(30);

function Get_Project_Id return NUMBER;
--function Get_Plan_Class_Code return VARCHAR2;

PROCEDURE set_global_variables
	(p_project_id	   IN	pa_budget_versions.project_id%TYPE,
	 -- p_plan_class_code IN	pa_fin_plan_types_b.plan_class_code%TYPE,
	 x_factor_by_code  OUT 	NOCOPY pa_proj_fp_options.factor_by_code%TYPE, --File.Sql.39 bug 4440895
	 x_return_status   OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
	 x_msg_count	   OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
	 x_msg_data	   OUT	NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE pa_fp_get_orgfcst_version_id(p_project_id          IN   NUMBER,
	                               p_plan_type_id        IN   NUMBER,
        	                       p_plan_status_code    IN   VARCHAR2,
                	               x_orgfcst_version_id  OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                        	       x_return_status       OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                              	       x_msg_count           OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
                  	               x_msg_data            OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                                   );


-- this procedure is similar to the above, but used for non-orgfcst plan types
-- given a plan type, we retrieve the budget version(s) that are in the
-- current working/current baselined status
PROCEDURE pa_fp_get_finplan_version_id
    (p_project_id          IN   NUMBER,
     p_plan_type_id        IN   NUMBER,
     p_plan_status_code    IN   VARCHAR2,
     x_cost_version_id     OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_rev_version_id      OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_return_status       OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data            OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE delete_plan_type_from_project
    (p_project_id        IN  pa_budget_versions.project_id%TYPE,
     p_fin_plan_type_id  IN  pa_budget_versions.fin_plan_type_id%TYPE,
     x_return_status     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data          OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION plantype_to_planclass
    (p_project_id		IN  pa_proj_fp_options.project_id%TYPE,
     p_fin_plan_type_id    	IN  pa_proj_fp_options.fin_plan_type_id%TYPE)
return VARCHAR2;

FUNCTION planversion_to_planclass
    (p_fin_plan_version_id	IN  pa_budget_versions.budget_version_id%TYPE)
return VARCHAR2;

END pa_fin_plan_type_global;
 

/
