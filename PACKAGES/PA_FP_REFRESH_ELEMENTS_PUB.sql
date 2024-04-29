--------------------------------------------------------
--  DDL for Package PA_FP_REFRESH_ELEMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_REFRESH_ELEMENTS_PUB" AUTHID CURRENT_USER AS
/* $Header: PAFPPERS.pls 120.1 2005/08/19 16:28:03 mwasowic noship $ */
PROCEDURE get_refresh_plan_ele_dtls(
                    p_budget_version_id   IN pa_budget_versions.budget_version_id%TYPE
                    DEFAULT NULL,
                    p_proj_fp_options_id   IN pa_proj_fp_options.proj_fp_options_id%TYPE
                    DEFAULT NULL,
                    x_request_id OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                    x_process_code    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                    x_refresh_required_flag OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                    x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                    x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                    x_msg_data           OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


PROCEDURE set_process_flag_opt(
                    p_project_id   IN pa_projects_all.project_id%TYPE,
                    p_request_id   IN pa_budget_versions.request_id%TYPE,
                    p_process_code    IN pa_budget_versions.plan_processing_code%TYPE,
                    p_refresh_required_flag IN VARCHAR2,
                    p_proj_fp_options_id   IN pa_proj_fp_options.proj_fp_options_id%TYPE
                    DEFAULT NULL,
                    p_budget_version_id   IN pa_budget_versions.budget_version_id%TYPE
                    DEFAULT NULL,
                    x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                    x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                    x_msg_data           OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE set_process_flag_proj(
                    p_project_id   IN pa_projects_all.project_id%TYPE,
                    p_request_id   IN pa_budget_versions.request_id%TYPE,
                    p_process_code    IN pa_budget_versions.plan_processing_code%TYPE,
                    p_refresh_required_flag IN VARCHAR2,
                    x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                    x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                    x_msg_data           OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE refresh_planning_elements(
                    p_project_id   IN pa_projects_all.project_id%TYPE,
                    p_request_id   IN pa_budget_versions.request_id%TYPE,
                    x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                    x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                    x_msg_data           OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE update_process_status_auto( p_fp_opt_tab        IN PA_PLSQL_DATATYPES.IdTabTyp,
                                 p_return_status     IN VARCHAR2,
                                 p_project_id        IN NUMBER,
                                 p_request_id        IN NUMBER,
                                 x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 x_msg_data           OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE update_process_status( p_fp_opt_tab        IN PA_PLSQL_DATATYPES.IdTabTyp,
                                 p_return_status     IN VARCHAR2,
                                 p_project_id        IN NUMBER,
                                 p_request_id        IN NUMBER,
                                 x_return_status      OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                 x_msg_count          OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                                 x_msg_data           OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE fp_write_log_ss_or_conc(
                   p_calling_context IN VARCHAR2,
                   p_msg IN VARCHAR2,
                   p_log_level IN NUMBER,
                   p_module IN VARCHAR2 );

END pa_fp_refresh_elements_pub;

 

/
