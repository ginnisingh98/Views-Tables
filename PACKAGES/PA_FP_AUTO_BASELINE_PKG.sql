--------------------------------------------------------
--  DDL for Package PA_FP_AUTO_BASELINE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_AUTO_BASELINE_PKG" AUTHID CURRENT_USER AS
/* $Header: PAFPABPS.pls 120.1 2005/08/19 16:23:35 mwasowic noship $ */


/* PLSQL Record Types */

TYPE funding_bl_rec IS RECORD (
     task_id            pa_tasks.task_id%TYPE,
     description        pa_budget_lines.description%TYPE,
     start_date         pa_budget_lines.start_date%TYPE,
     end_date           pa_budget_lines.end_date%TYPE,
     projfunc_revenue   pa_budget_lines.revenue%TYPE,
     project_revenue    pa_budget_lines.project_revenue%TYPE
  );

/* PLSQL Record Types */


/* PLSQL Table Types */

TYPE funding_bl_tab is TABLE of funding_bl_rec INDEX BY BINARY_INTEGER;

/* PLSQL Table Types */


PROCEDURE CREATE_BASELINED_VERSION
   (  p_project_id              IN      pa_budget_versions.project_id%TYPE
     ,p_fin_plan_type_id        IN      pa_budget_versions.fin_plan_type_id%TYPE
     ,p_funding_level_code      IN      pa_proj_fp_options.cost_fin_plan_level_code%TYPE
     ,p_version_name            IN      pa_budget_versions.version_name%TYPE
     ,p_description             IN      pa_budget_versions.description%TYPE
     ,p_funding_bl_tab          IN      pa_fp_auto_baseline_pkg.funding_bl_tab
    -- Start of additional columns for Bug :- 2634900
     ,p_ci_id                   IN      pa_budget_versions.ci_id%TYPE                    := NULL
     ,p_est_proj_raw_cost       IN      pa_budget_versions.est_project_raw_cost%TYPE     := NULL
     ,p_est_proj_bd_cost        IN      pa_budget_versions.est_project_burdened_cost%TYPE:= NULL
     ,p_est_proj_revenue        IN      pa_budget_versions.est_project_revenue%TYPE      := NULL
     ,p_est_qty                 IN      pa_budget_versions.est_quantity%TYPE             := NULL
     ,p_est_equip_qty           IN      pa_budget_versions.est_equipment_quantity%TYPE   := NULL -- FP.M
     ,p_impacted_task_id        IN      pa_tasks.task_id%TYPE                            := NULL
     ,p_agreement_id            IN      pa_budget_versions.agreement_id%TYPE             := NULL
    -- End of additional columns for Bug :- 2634900
     ,x_budget_version_id       OUT     NOCOPY pa_budget_versions.budget_version_id%TYPE      --File.Sql.39 bug 4440895
     ,x_return_status           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count               OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


END PA_FP_AUTO_BASELINE_PKG;

 

/
