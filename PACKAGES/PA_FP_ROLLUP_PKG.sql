--------------------------------------------------------
--  DDL for Package PA_FP_ROLLUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_ROLLUP_PKG" AUTHID CURRENT_USER AS
/* $Header: PAFPRLPS.pls 120.1 2005/08/19 16:29:44 mwasowic noship $ */

/* PL/SQL Table Types. */

TYPE l_ra_id_tbl_typ IS TABLE OF
        pa_resource_assignments.RESOURCE_ASSIGNMENT_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE l_par_id_tbl_typ IS TABLE OF
        pa_resource_assignments.PARENT_ASSIGNMENT_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE l_task_id_tbl_typ IS TABLE OF
        pa_tasks.TASK_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE l_top_task_id_tbl_typ IS TABLE OF
        pa_tasks.TOP_TASK_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE l_res_list_mem_id_tbl_typ IS TABLE OF
        pa_resource_assignments.RESOURCE_LIST_MEMBER_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE l_track_as_labor_flag_tbl_typ IS TABLE OF
        pa_resource_assignments.TRACK_AS_LABOR_FLAG%TYPE INDEX BY BINARY_INTEGER;
TYPE l_plannable_flag_tbl_typ IS TABLE OF
        pa_proj_fp_options.ALL_FIN_PLAN_LEVEL_CODE%TYPE INDEX BY BINARY_INTEGER;
TYPE l_unit_of_measure_tbl_typ  IS TABLE OF
        pa_resource_assignments.UNIT_OF_MEASURE%TYPE INDEX BY BINARY_INTEGER;
TYPE l_proj_raw_cost_tbl_typ IS TABLE OF
        pa_resource_assignments.TOTAL_PROJECT_RAW_COST%TYPE INDEX BY BINARY_INTEGER;
TYPE l_proj_burd_cost_tbl_typ IS TABLE OF
        pa_resource_assignments.TOTAL_PROJECT_BURDENED_COST%TYPE INDEX BY BINARY_INTEGER;
TYPE l_proj_revenue_tbl_typ IS TABLE OF
        pa_resource_assignments.TOTAL_PROJECT_REVENUE%TYPE INDEX BY BINARY_INTEGER;
TYPE l_projfunc_raw_cost_tbl_typ IS TABLE OF
        pa_resource_assignments.TOTAL_PLAN_RAW_COST%TYPE INDEX BY BINARY_INTEGER;
TYPE l_projfunc_burd_cost_tbl_typ IS TABLE OF
        pa_resource_assignments.TOTAL_PLAN_BURDENED_COST%TYPE INDEX BY BINARY_INTEGER;
TYPE l_projfunc_revenue_tbl_typ IS TABLE OF
        pa_resource_assignments.TOTAL_PLAN_REVENUE%TYPE INDEX BY BINARY_INTEGER;
TYPE l_quantity_tbl_typ IS TABLE OF
        pa_resource_assignments.TOTAL_PLAN_QUANTITY%TYPE INDEX BY BINARY_INTEGER;

TYPE l_obj_typ_code_tbl_typ IS TABLE OF
        pa_proj_periods_denorm.object_type_code%TYPE INDEX BY BINARY_INTEGER;
TYPE l_object_id_tbl_typ               IS TABLE OF
        pa_proj_periods_denorm.object_id%TYPE;
TYPE l_period_profile_id_typ           IS TABLE OF
        pa_budget_versions.period_profile_id%TYPE;
TYPE l_amount_type_code_tbl_typ        IS TABLE OF
        pa_proj_periods_denorm.amount_type_code%TYPE;
TYPE l_amount_subtype_code_tbl_typ     IS TABLE OF
        pa_proj_periods_denorm.amount_subtype_code%TYPE;
TYPE l_amount_type_id_tbl_typ          IS TABLE OF
        pa_proj_periods_denorm.amount_type_id%TYPE;
TYPE l_amount_subtype_id_tbl_typ       IS TABLE OF
        pa_proj_periods_denorm.amount_subtype_id%TYPE;
TYPE l_currency_type_tbl_typ           IS TABLE OF
        pa_proj_periods_denorm.currency_type%TYPE;
TYPE l_currency_code_tbl_typ           IS TABLE OF
        pa_proj_periods_denorm.currency_code%TYPE;











/* Exception to be used for Invalid Parameters. */
Invalid_Arg_Exc EXCEPTION;

/* Global variables */
p_first_ra_id pa_resource_assignments.RESOURCE_ASSIGNMENT_ID%TYPE;


PROCEDURE POPULATE_LOCAL_VARS(
          p_budget_version_id     IN NUMBER
         ,x_project_id           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_resource_list_id     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_uncat_flag           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_uncat_rlm_id         OUT NOCOPY NUMBER  --File.Sql.39 bug 4440895
         ,x_rl_group_type_id     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_planning_level       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_return_status        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data             OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE ROLLUP_BUDGET_VERSION(
          p_budget_version_id     IN NUMBER
         ,p_entire_version        IN VARCHAR2
         ,p_context               IN VARCHAR2  DEFAULT NULL --Added for bug 4160258
         ,x_return_status        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data             OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE REFRESH_RESOURCE_ASSIGNMENTS(
          p_budget_version_id     IN NUMBER
         ,x_return_status        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data             OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE UPDATE_RES_PARENT_ASSIGN_ID(
          p_budget_version_id    IN NUMBER
         ,p_proj_ra_id           IN NUMBER
         ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data            OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE UPDATE_DENORM_PARENT_ASSIGN_ID(
          p_budget_version_id    IN NUMBER
         ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count           OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data            OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE INSERT_BULK_ROWS_RES (
          p_project_id               IN NUMBER
         ,p_plan_version_id          IN NUMBER
         ,p_task_id_tbl              IN l_task_id_tbl_typ
         ,p_res_list_mem_id_tbl      IN l_res_list_mem_id_tbl_typ
         ,p_proj_raw_cost_tbl        IN l_proj_raw_cost_tbl_typ
         ,p_proj_burdened_cost_tbl   IN l_proj_burd_cost_tbl_typ
         ,p_proj_revenue_tbl         IN l_proj_revenue_tbl_typ
         ,p_projfunc_raw_cost_tbl    IN l_projfunc_raw_cost_tbl_typ
         ,p_projfunc_burd_cost_tbl   IN l_projfunc_burd_cost_tbl_typ
         ,p_projfunc_revenue_tbl     IN l_projfunc_revenue_tbl_typ
         ,p_quantity_tbl             IN l_quantity_tbl_typ
         ,p_unit_of_measure_tbl      IN l_unit_of_measure_tbl_typ
         ,p_track_as_labor_flag_tbl  IN l_track_as_labor_flag_tbl_typ
         ,x_return_status           OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count               OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data                OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE REFRESH_PERIOD_DENORM(
          p_budget_version_id     IN NUMBER
         ,x_return_status        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data             OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE INSERT_MISSING_RES_PARENTS(
          p_budget_version_id     IN NUMBER
         ,x_return_status        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data             OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE ROLLUP_RES_ASSIGNMENT_AMOUNTS(
          p_budget_version_id     IN NUMBER
         ,x_return_status        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data             OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE INSERT_MISSING_PARENT_DENORM(
          p_budget_version_id     IN NUMBER
         ,x_return_status        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data             OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE ROLLUP_DENORM_AMOUNTS(
          p_budget_version_id     IN NUMBER
         ,x_return_status        OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count            OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data             OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE DELETE_ELEMENT(
          p_budget_version_id        IN NUMBER
         ,p_resource_assignment_id   IN NUMBER
         ,p_txn_currency_code        IN VARCHAR2
         ,x_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
         ,x_msg_count               OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
         ,x_msg_data                OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

END PA_FP_ROLLUP_PKG;


 

/
