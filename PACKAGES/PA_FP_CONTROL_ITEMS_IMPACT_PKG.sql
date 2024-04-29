--------------------------------------------------------
--  DDL for Package PA_FP_CONTROL_ITEMS_IMPACT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_CONTROL_ITEMS_IMPACT_PKG" AUTHID CURRENT_USER AS
/* $Header: PAFPCIIS.pls 120.1 2005/08/19 16:24:44 mwasowic noship $ */
PROCEDURE Maintain_Ctrl_Item_Version
(
      p_project_id IN Pa_Projects_All.Project_Id%TYPE,
      p_ci_id                    IN   NUMBER,
      p_fp_pref_code             IN   VARCHAR2,
      p_fin_plan_type_id_cost    IN   NUMBER,
      p_fin_plan_type_id_rev     IN   NUMBER,
      p_fin_plan_type_id_all     IN   NUMBER,
      p_est_proj_raw_cost        IN   NUMBER,
      p_est_proj_bd_cost         IN   NUMBER,
      p_est_proj_revenue         IN   NUMBER,
      p_est_qty                  IN   NUMBER,
      p_est_equip_qty            IN   NUMBER,  -- FP.M
      p_button_pressed_from_page IN   VARCHAR2 DEFAULT 'NONE',
      p_impacted_task_id         IN   NUMBER,
      p_agreement_id             IN   NUMBER   DEFAULT NULL,
      p_agreement_number         IN   VARCHAR2 DEFAULT NULL,
      x_return_status            OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_msg_count                OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
      x_msg_data                 OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_plan_version_id          OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895
PROCEDURE Maintain_Plan_Version
(
      p_project_id             IN   Pa_Projects_All.Project_Id%TYPE,
      p_ci_id                  IN   NUMBER,
      p_fp_pref_code           IN   VARCHAR2,
      p_fin_plan_type_id       IN   NUMBER,
      p_est_proj_raw_cost      IN   NUMBER,
      p_est_proj_bd_cost       IN   NUMBER,
      p_est_proj_revenue       IN   NUMBER,
      p_est_qty                IN   NUMBER,
      p_est_equip_qty          IN   NUMBER,  -- FP.M
      p_project_currency_Code  IN   VARCHAR2,
      p_projfunc_currency_code IN   VARCHAR2,
      p_element_type           IN   VARCHAR2,
      p_impacted_task_id       IN   NUMBER,
      p_agreement_id           IN   NUMBER   DEFAULT NULL,
      p_agreement_number       IN   VARCHAR2 DEFAULT NULL,
      p_baseline_funding_flag  IN   VARCHAR2 DEFAULT NULL,
      x_return_status          OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_msg_count              OUT  NOCOPY NUMBER, --File.Sql.39 bug 4440895
      x_msg_data               OUT  NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
      x_plan_version_id        OUT  NOCOPY NUMBER); --File.Sql.39 bug 4440895


PROCEDURE delete_ci_plan_versions
(
     p_project_id     IN  NUMBER,
     p_ci_id          IN  NUMBER,
     p_init_msg_list  IN  VARCHAR2 DEFAULT 'N' ,
     p_commit_flag    IN  VARCHAR2 DEFAULT 'N',
     x_return_status  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
     x_msg_count      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
     x_msg_data       OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END Pa_Fp_Control_Items_Impact_Pkg;

 

/
