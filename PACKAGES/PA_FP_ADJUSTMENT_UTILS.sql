--------------------------------------------------------
--  DDL for Package PA_FP_ADJUSTMENT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_ADJUSTMENT_UTILS" AUTHID CURRENT_USER AS
-- $Header: PAFPADJS.pls 120.1 2005/08/19 16:23:44 mwasowic noship $


-- This procedure will Get Summary Information on a
-- given Budget Version Id/Name



PROCEDURE Get_Summary_Info
(  p_project_id                  IN  NUMBER
  ,p_cost_budget_version_id      IN  NUMBER
  ,p_rev_budget_version_id       IN  NUMBER
  ,p_WBS_Element_Id              IN  NUMBER    DEFAULT NULL
  ,p_RBS_Element_Id              IN  NUMBER    DEFAULT NULL
  ,p_WBS_Structure_Version_Id    IN  NUMBER    DEFAULT NULL
  ,p_RBS_Version_Id              IN  NUMBER    DEFAULT NULL
  ,p_WBS_Rollup_Flag             IN  VARCHAR2
  ,p_RBS_Rollup_Flag             IN  VARCHAR2
  ,p_resource_tbl_flag           IN  VARCHAR2  DEFAULT 'N'
  ,p_resource_assignment_id_tbl  IN  SYSTEM.PA_NUM_TBL_TYPE DEFAULT SYSTEM.PA_NUM_TBL_TYPE()
  ,p_txn_currency_code_tbl       IN  SYSTEM.PA_VARCHAR2_15_TBL_TYPE DEFAULT SYSTEM.PA_VARCHAR2_15_TBL_TYPE()
  ,x_version                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_version_name                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_project_id                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_structure_version_id        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_rev_version                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_rev_version_name            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_task_number                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_task_name                   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_resource_name               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_plan_setup                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_plan_type_name              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_fin_plan_type_id            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_version_type                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_rev_plan_type_name          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_rev_workplan_flag           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_rev_plan_setup              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_rev_plan_class_code         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_rev_fin_plan_type_id        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_rev_version_type            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_workplan_flag               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_plan_class_code             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_pc_raw_cost                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_pc_burdened_cost            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_pc_revenue                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_pc_currency                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_pfc_raw_cost                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_pfc_burdened_cost           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_pfc_revenue                 OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_pfc_currency                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_pc_margin                   OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_pfc_margin                  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_margin_percent              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_total_labor_hours           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_total_equip_hours           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_rev_total_labor_hours       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_rev_total_equip_hours       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_resource_assignment_id_tbl  OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
  ,x_txn_currency_code_tbl       OUT NOCOPY SYSTEM.PA_VARCHAR2_15_TBL_TYPE --File.Sql.39 bug 4440895
  ,x_workplan_costs_enabled_flag OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_return_status               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                   OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                    OUT NOCOPY VARCHAR2 ) ; --File.Sql.39 bug 4440895


-- Purpose: Private Specific to compute relevant planning transaction id's affected in computing summary amounts/adjusting plan via Adjust/Mass Adjust.
--          Called by Get_Summary_Info and AMG Adjust Interface API.
PROCEDURE COMPUTE_HIERARCHY(
     p_cost_budget_version_id    IN  NUMBER
    ,p_rev_budget_version_id     IN  NUMBER
    ,p_WBS_Element_Id	         IN  NUMBER DEFAULT NULL
    ,p_RBS_Element_Id	         IN  NUMBER DEFAULT NULL
    ,p_WBS_Structure_Version_Id  IN  NUMBER DEFAULT NULL
    ,p_RBS_Version_Id            IN  NUMBER DEFAULT NULL
    ,p_WBS_Rollup_Flag           IN  VARCHAR2
    ,p_RBS_Rollup_Flag           IN  VARCHAR2
    ,X_res_assignment_id_tbl     OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
    ,X_txn_currency_code_tbl     OUT NOCOPY SYSTEM.pa_varchar2_15_tbl_type --File.Sql.39 bug 4440895
    ,X_rev_res_assignment_id_tbl OUT NOCOPY SYSTEM.PA_NUM_TBL_TYPE --File.Sql.39 bug 4440895
    ,X_rev_txn_currency_code_tbl OUT NOCOPY SYSTEM.pa_varchar2_15_tbl_type --File.Sql.39 bug 4440895
    ,X_return_status             OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    )   ;


-- This procedure is an interface to Adjust the relevant Planning Versions /transactions
-- based on a percentage
-- for the relevant parameters

PROCEDURE Adjust_Planning_Transactions
(
     p_Project_Id                   IN  NUMBER
    ,p_Context                      IN  VARCHAR2
    ,p_user_id                      IN  NUMBER DEFAULT FND_GLOBAL.USER_ID
    ,p_cost_budget_version_id	    IN  NUMBER
    ,p_rev_budget_version_id        IN  NUMBER   DEFAULT NULL
    ,p_cost_fin_plan_type_id	    IN	NUMBER
    ,p_cost_version_type	    IN	VARCHAR2
    ,p_cost_plan_setup              IN  VARCHAR2
    ,p_rev_fin_plan_type_id	    IN	NUMBER	 DEFAULT NULL
    ,p_rev_version_type		    IN	VARCHAR2 DEFAULT NULL
    ,p_rev_plan_setup               IN  VARCHAR2 DEFAULT NULL
    ,p_new_version_flag	            IN  VARCHAR2 DEFAULT 'N'
    ,p_new_version_name	            IN  VARCHAR2 DEFAULT NULL
    ,p_new_version_desc	            IN  VARCHAR2 DEFAULT NULL
    ,p_adjustment_type	            IN  VARCHAR2 DEFAULT NULL
    ,p_adjustment_percentage	    IN  NUMBER
    ,p_WBS_Element_Id	            IN  NUMBER DEFAULT NULL
    ,p_RBS_Element_Id	            IN  NUMBER DEFAULT NULL
    ,p_WBS_Structure_Version_Id     IN  NUMBER DEFAULT NULL
    ,p_RBS_Version_Id               IN  NUMBER DEFAULT NULL
    ,p_WBS_Rollup_Flag              IN  VARCHAR2
    ,p_RBS_Rollup_Flag              IN  VARCHAR2
    ,p_resource_assignment_id_tbl   IN  SYSTEM.PA_NUM_TBL_TYPE
    ,p_txn_currency_code_tbl        IN  SYSTEM.pa_varchar2_15_tbl_type
    ,x_cost_budget_version_id	    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_rev_budget_version_id        OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_return_status                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count                    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data                     OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

FUNCTION CLASS_HOURS(p_current_budget_version_id IN NUMBER, p_input_budget_version_id IN NUMBER,
                     p_rev_budget_version_id IN NUMBER, p_report_using IN VARCHAR2,
					 p_mode IN VARCHAR2, p_resource_class_code IN VARCHAR2,
					 p_total_plan_quantity IN NUMBER, p_rate_based_flag IN VARCHAR2 ) RETURN NUMBER ;

FUNCTION REVENUE(p_current_budget_version_id IN NUMBER, p_input_budget_version_id IN NUMBER,
                 p_rev_budget_version_id IN NUMBER, p_REVENUE IN NUMBER) RETURN NUMBER ;


end  PA_FP_ADJUSTMENT_UTILS ;

 

/
