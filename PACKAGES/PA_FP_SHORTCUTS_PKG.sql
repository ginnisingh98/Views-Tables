--------------------------------------------------------
--  DDL for Package PA_FP_SHORTCUTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_SHORTCUTS_PKG" AUTHID CURRENT_USER AS
/* $Header: PAFPSHPS.pls 120.3 2006/06/26 09:04:01 nkumbi noship $ */

PROCEDURE identify_plan_version_id(
          p_project_id            IN        pa_projects_all.project_id%TYPE,
          p_function_code         IN        VARCHAR2,
          p_context               IN        VARCHAR2 DEFAULT NULL,
          p_user_id               IN        NUMBER,
          p_same_org_id_flag      IN        VARCHAR2, -- DEFAULT 'N',  Bug 5276024
          px_fin_plan_type_id     IN  OUT   NOCOPY pa_fin_plan_types_b.fin_plan_type_id%TYPE, --File.Sql.39 bug 4440895
          x_budget_version_id     OUT       NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
          x_redirect_url          OUT       NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_request_id            OUT       NOCOPY pa_budget_versions.request_id%TYPE, --File.Sql.39 bug 4440895
          x_plan_processing_code  OUT       NOCOPY pa_budget_versions.plan_processing_code%TYPE, --File.Sql.39 bug 4440895
          x_proj_fp_option_id     OUT       NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE, --File.Sql.39 bug 4440895
          x_return_status         OUT       NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
          x_msg_count             OUT       NOCOPY NUMBER, --File.Sql.39 bug 4440895
          x_msg_data              OUT       NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE get_app_budget_pt_id(
                    p_project_id IN pa_projects_all.project_id%TYPE,
                    p_version_type IN pa_budget_versions.version_type%TYPE,
                    p_context IN VARCHAR2,
                    p_function_code IN VARCHAR2 DEFAULT NULL,
                    x_fin_plan_type_id OUT NOCOPY pa_fin_plan_types_b.fin_plan_type_id%TYPE, --File.Sql.39 bug 4440895
                    x_redirect_url OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                    x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                    x_msg_count     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                    x_msg_data      OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895


PROCEDURE get_fcst_plan_type_id(
                    p_project_id IN pa_projects_all.project_id%TYPE,
                    p_version_type IN pa_budget_versions.version_type%TYPE,
                    p_context IN VARCHAR2,
                    p_function_code IN VARCHAR2 DEFAULT NULL,
                    x_fin_plan_type_id OUT NOCOPY pa_fin_plan_types_b.fin_plan_type_id%TYPE, --File.Sql.39 bug 4440895
                    x_redirect_url OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                    x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                    x_msg_count     OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
                    x_msg_data      OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

procedure get_cw_version(
                    p_project_id            IN      pa_projects_all.project_id%TYPE,
                    p_plan_class_code       IN      pa_fin_plan_types_b.plan_class_Code%TYPE,
                    p_version_type          IN      pa_budget_versions.version_type%TYPE,
                    p_fin_plan_type_id      IN      pa_fin_plan_types_b.fin_plan_type_id%TYPE,
                    p_edit_in_excel_Flag    IN      VARCHAR2,
                    p_user_id               IN      NUMBER,
                    p_context               IN      VARCHAR2,
                    x_budget_version_id     OUT     NOCOPY pa_budget_versions.budget_version_id%TYPE, --File.Sql.39 bug 4440895
                    x_redirect_url          OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                    x_request_id            OUT     NOCOPY pa_budget_versions.request_id%TYPE, --File.Sql.39 bug 4440895
                    x_plan_processing_code  OUT     NOCOPY pa_budget_versions.plan_processing_code%TYPE, --File.Sql.39 bug 4440895
                    x_proj_fp_option_id     OUT     NOCOPY pa_proj_fp_options.proj_fp_options_id%TYPE, --File.Sql.39 bug 4440895
                    x_return_status         OUT     NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                    x_msg_count             OUT     NOCOPY NUMBER, --File.Sql.39 bug 4440895
                    x_msg_data              OUT     NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895
END pa_fp_shortcuts_pkg;

 

/
