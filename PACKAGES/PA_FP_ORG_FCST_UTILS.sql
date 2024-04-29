--------------------------------------------------------
--  DDL for Package PA_FP_ORG_FCST_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_ORG_FCST_UTILS" AUTHID CURRENT_USER as
/* $Header: PAFPORUS.pls 120.2 2005/08/19 16:27:54 mwasowic noship $ */
-- Start of Comments
-- Package name     : PA_FP_ORG_FCST_UTILS
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

/*    20-Mar-2002 SManivannan   Added Procedure Get_Tp_Amount_Type   */

PROCEDURE get_forecast_option_details
  ( x_fcst_period_type           OUT NOCOPY pa_forecasting_options_all.org_fcst_period_type%TYPE --File.Sql.39 bug 4440895
   ,x_period_set_name            OUT NOCOPY pa_implementations_all.period_set_name%TYPE --File.Sql.39 bug 4440895
   ,x_act_period_type            OUT NOCOPY gl_periods.period_type%TYPE                 --File.Sql.39 bug 4440895
   ,x_org_projfunc_currency_code OUT NOCOPY gl_sets_of_books.currency_code%TYPE --File.Sql.39 bug 4440895
   ,x_number_of_periods          OUT NOCOPY pa_forecasting_options_all.number_of_periods%TYPE --File.Sql.39 bug 4440895
   ,x_weighted_or_full_code      OUT NOCOPY pa_forecasting_options_all.weighted_or_full_code%TYPE --File.Sql.39 bug 4440895
   ,x_org_proj_template_id       OUT NOCOPY pa_forecasting_options_all.org_fcst_project_template_id%TYPE --File.Sql.39 bug 4440895
   ,x_org_structure_version_id   OUT NOCOPY pa_implementations_all.org_structure_version_id%TYPE --File.Sql.39 bug 4440895
   ,x_fcst_start_date            OUT NOCOPY DATE --File.Sql.39 bug 4440895
   ,x_fcst_end_date              OUT NOCOPY DATE --File.Sql.39 bug 4440895
   ,x_org_id                     OUT NOCOPY pa_implementations_all.org_id%TYPE --File.Sql.39 bug 4440895
   ,x_return_status              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_err_code                   OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE get_org_project_info
  ( p_organization_id      IN hr_organization_units.organization_id%TYPE
                              := NULL
   ,x_org_project_id      OUT NOCOPY pa_projects_all.project_id%TYPE --File.Sql.39 bug 4440895
   ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_err_code            OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE get_org_task_info
  ( p_project_id           IN pa_projects_all.project_id%TYPE
                              := NULL
   ,x_org_task_id         OUT NOCOPY pa_tasks.task_id%TYPE --File.Sql.39 bug 4440895
   ,x_organization_id     OUT NOCOPY hr_organization_units.organization_id%TYPE --File.Sql.39 bug 4440895
   ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_err_code            OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE get_utilization_details
  ( p_org_id               IN pa_implementations_all.org_id%TYPE
                              := NULL
   ,p_organization_id      IN hr_organization_units.organization_id%TYPE
                              := NULL
   ,p_period_type          IN pa_forecasting_options_all.org_fcst_period_type%TYPE
                              := NULL
   ,p_period_set_name      IN gl_periods.period_set_name%TYPE
                              := NULL
   ,p_period_name          IN gl_periods.period_name%TYPE
                              := NULL
   ,x_utl_hours           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_utl_capacity        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_utl_percent         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_err_code            OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE get_headcount
  ( p_organization_id      IN hr_organization_units.organization_id%TYPE
                              := NULL
   ,p_effective_date       IN DATE
                              := NULL
   ,x_headcount           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_err_code            OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE get_probability_percent
  ( p_project_id           IN pa_projects_all.project_id%TYPE
                              := NULL
   ,x_prob_percent OUT NOCOPY pa_probability_members.probability_percentage%TYPE --File.Sql.39 bug 4440895
   ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_err_code            OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
PROCEDURE get_period_profile
  ( p_project_id          IN pa_projects_all.project_id%TYPE
                             := NULL
   ,p_period_profile_type IN pa_proj_period_profiles.period_profile_type%TYPE
                             := NULL
   ,p_plan_period_type    IN pa_forecasting_options.org_fcst_period_type%TYPE
                             := NULL
   ,p_period_set_name     IN gl_periods.period_set_name%TYPE
                             := NULL
   ,p_act_period_type     IN gl_periods.period_type%TYPE
                             := NULL
   ,p_start_date          IN gl_periods.start_date%TYPE
                             := NULL
   ,p_number_of_periods   IN pa_forecasting_options.number_of_periods%TYPE
   ,x_period_profile_id  OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_err_code           OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION check_org_proj_template
  ( p_project_id          IN pa_projects_all.project_id%TYPE
                             := NULL
   ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_err_code           OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
   RETURN VARCHAR2;

PROCEDURE Get_Tp_Amount_Type(p_project_id        IN  NUMBER,
                             p_work_type_id      IN  NUMBER,
                             x_tp_amount_type    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_return_status     OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             x_msg_count         OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                             x_msg_data          OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

FUNCTION check_org_project
  ( p_project_id          IN pa_projects_all.project_id%TYPE
                             := NULL
   ,x_return_status      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_err_code           OUT NOCOPY VARCHAR2) --File.Sql.39 bug 4440895
   RETURN VARCHAR2;

FUNCTION calculate_gl_amount
  ( p_amount_code         IN pa_amount_types_b.amount_type_code%TYPE
                             := NULL)
   RETURN NUMBER;

FUNCTION calculate_pa_amount
  ( p_amount_code         IN pa_amount_types_b.amount_type_code%TYPE
                             := NULL)
   RETURN NUMBER;

/* Dlai 04/21/02 -- added procedure detect_org_project */
PROCEDURE detect_org_project
  ( p_project_id	IN  pa_projects_all.project_id%TYPE,
    x_return_status	OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_err_code		OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/* Dlai 04/25/02 -- added function same_org_id and procedure check_same_org_id */
/*      07/13/05 -- commented out same_org_id and check_same_org_id, because   */
/*                  in R12, CLIENT_INFO should no longer be used               */
/*
FUNCTION same_org_id
    (p_project_id     	IN    pa_projects_all.project_id%TYPE)
  RETURN VARCHAR2;

PROCEDURE check_same_org_id
    (p_project_id           IN      pa_projects_all.project_id%TYPE,
     x_return_status        OUT     VARCHAR2,
     x_msg_count            OUT     NUMBER,
     x_msg_data             OUT     VARCHAR2);
*/

/* for Sheenie: function which takes in only 1 argument:
 * returns 'Y' if project is an org project
 * returns 'N' if project is not an org project
 * returns 'E' if there is an exception error
 */
FUNCTION is_org_project
  ( p_project_id          IN pa_projects_all.project_id%TYPE
                             := NULL)
   RETURN VARCHAR2;

END pa_fp_org_fcst_utils;
 

/
