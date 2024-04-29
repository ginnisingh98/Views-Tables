--------------------------------------------------------
--  DDL for Package PA_FP_ELEMENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_FP_ELEMENTS_PUB" AUTHID CURRENT_USER as
/* $Header: PAFPELPS.pls 120.1 2005/08/19 16:26:29 mwasowic noship $ */

Invalid_Arg_Exc EXCEPTION;

/* PLSQL record types */

TYPE l_impacted_task_in_rec_typ IS RECORD
 (impacted_task_id   pa_tasks.task_id%TYPE
 ,old_parent_task_id pa_tasks.task_id%TYPE
 ,new_parent_task_id pa_tasks.task_id%TYPE
 ,top_task_id        pa_tasks.task_id%TYPE
 ,action             VARCHAR2(30));

--For Bug 2976168.
TYPE l_wbs_refresh_tasks_rec_typ IS RECORD
( task_id 		   pa_tasks.task_id%TYPE
 ,parent_task_id     pa_tasks.parent_task_id%TYPE
 ,top_task_id        pa_tasks.top_task_id%TYPE
 ,task_level         VARCHAR2(1) 			-- T - Top Task, M - Middle Task, L - Lowest Task
);

/* PLSQL table types */

TYPE l_wbs_refresh_tasks_tbl_typ is TABLE OF
     l_wbs_refresh_tasks_rec_typ INDEX BY BINARY_INTEGER;--For Bug 2976168.

TYPE l_task_id_tbl_typ IS TABLE OF
        pa_fp_elements.TASK_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE l_top_task_id_tbl_typ IS TABLE OF
        pa_fp_elements.TOP_TASK_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE l_res_list_mem_id_tbl_typ IS TABLE OF
        pa_fp_elements.RESOURCE_LIST_MEMBER_ID%TYPE INDEX BY BINARY_INTEGER;
TYPE l_task_planning_level_tbl_typ IS TABLE OF
        pa_fp_elements.TOP_TASK_PLANNING_LEVEL%TYPE INDEX BY BINARY_INTEGER;
TYPE l_track_as_labor_flag_tbl_typ IS TABLE OF
        pa_resource_assignments.TRACK_AS_LABOR_FLAG%TYPE INDEX BY BINARY_INTEGER;
TYPE l_unit_of_measure_tbl_typ  IS TABLE OF
        pa_resource_assignments.UNIT_OF_MEASURE%TYPE INDEX BY BINARY_INTEGER;
TYPE l_res_planning_level_tbl_typ IS TABLE OF
        pa_fp_elements.RESOURCE_PLANNING_LEVEL%TYPE INDEX BY BINARY_INTEGER;
TYPE l_plannable_flag_tbl_typ IS TABLE OF
        pa_fp_elements.PLANNABLE_FLAG%TYPE INDEX BY BINARY_INTEGER;
TYPE l_res_planned_for_task_tbl_typ IS TABLE OF
        pa_fp_elements.RESOURCES_PLANNED_FOR_TASK%TYPE INDEX BY BINARY_INTEGER;
TYPE l_planamount_exists_tbl_typ  IS TABLE OF
        pa_fp_elements.PLAN_AMOUNT_EXISTS_FLAG%TYPE INDEX BY BINARY_INTEGER;
TYPE l_impacted_task_in_tbl_typ IS TABLE OF
        l_impacted_task_in_rec_typ INDEX BY BINARY_INTEGER;

/* PLSQL table types */



PROCEDURE Refresh_FP_Elements (
          p_proj_fp_options_id               IN   NUMBER
          ,p_cost_planning_level             IN   VARCHAR2
          ,p_revenue_planning_level          IN   VARCHAR2
          ,p_all_planning_level              IN   VARCHAR2
          ,p_cost_resource_list_id           IN   NUMBER
          ,p_revenue_resource_list_id        IN   NUMBER
          ,p_all_resource_list_id            IN   NUMBER
          /*  Bug :- 2920954 start of new parameters added for post fp-K one off patch */
          ,p_select_cost_res_auto_flag       IN   pa_proj_fp_options.select_cost_res_auto_flag%TYPE
          ,p_cost_res_planning_level         IN   pa_proj_fp_options.cost_res_planning_level%TYPE
          ,p_select_rev_res_auto_flag        IN   pa_proj_fp_options.select_rev_res_auto_flag%TYPE
          ,p_revenue_res_planning_level      IN   pa_proj_fp_options.revenue_res_planning_level%TYPE
          ,p_select_all_res_auto_flag        IN   pa_proj_fp_options.select_all_res_auto_flag%TYPE
          ,p_all_res_planning_level          IN   pa_proj_fp_options.all_res_planning_level%TYPE
          /*  Bug :- 2920954 end of new parameters added for post fp-K one off patch */
          ,x_return_status                   OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                       OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                        OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Copy_Elements (
          p_from_proj_fp_options_id   IN   NUMBER
          ,p_from_element_type        IN   VARCHAR2
          ,p_to_proj_fp_options_id    IN   NUMBER
          ,p_to_element_type          IN   VARCHAR2
          ,p_to_resource_list_id      IN   NUMBER
          ,p_copy_mode                IN   VARCHAR2 DEFAULT 'W' /* Bug 2920954 */
          ,x_return_status            OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                 OUT  NOCOPY VARCHAR2);  --File.Sql.39 bug 4440895

PROCEDURE Insert_Default (
          p_proj_fp_options_id     IN   NUMBER
          ,p_element_type          IN   VARCHAR2
          ,p_planning_level        IN   VARCHAR2
          ,p_resource_list_id      IN   NUMBER
          /* Bug :- 2920954 start of parameters added for post fp-K one off patch */
          ,p_select_res_auto_flag  IN   pa_proj_fp_options.select_cost_res_auto_flag%TYPE
          ,p_res_planning_level    IN   pa_proj_fp_options.cost_res_planning_level%TYPE
          /* Bug :- 2920954 end of parameters added for post fp-K one off patch */
          ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data              OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Delete_Elements (
          p_proj_fp_options_id     IN   NUMBER
          ,p_element_type          IN   VARCHAR2
          ,p_element_level         IN   VARCHAR2
          ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data              OUT  NOCOPY VARCHAR2);  --File.Sql.39 bug 4440895

PROCEDURE Delete_Element (
           p_task_id                 IN   NUMBER
          ,p_resource_list_member_id IN   NUMBER
          ,p_budget_version_id       IN   NUMBER
          ,x_return_status           OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count               OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                OUT  NOCOPY VARCHAR2);  --File.Sql.39 bug 4440895


PROCEDURE Insert_Bulk_Rows (
           p_proj_fp_options_id       IN NUMBER
          ,p_project_id               IN NUMBER
          ,p_fin_plan_type_id         IN NUMBER
          ,p_element_type             IN VARCHAR2
          ,p_plan_version_id          IN NUMBER
          ,p_task_id_tbl              IN l_task_id_tbl_typ
          ,p_top_task_id_tbl          IN l_top_task_id_tbl_typ
          ,p_res_list_mem_id_tbl      IN l_res_list_mem_id_tbl_typ
          ,p_task_planning_level_tbl  IN l_task_planning_level_tbl_typ
          ,p_res_planning_level_tbl   IN l_res_planning_level_tbl_typ
          ,p_plannable_flag_tbl       IN l_plannable_flag_tbl_typ
          ,p_res_planned_for_task_tbl IN l_res_planned_for_task_tbl_typ
          ,p_planamount_exists_tbl    IN l_planamount_exists_tbl_typ
          ,p_res_uncategorized_flag   IN VARCHAR2
          ,x_return_status            OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                 OUT  NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

PROCEDURE Insert_Bulk_Rows_Res (
           p_project_id               IN NUMBER
          ,p_plan_version_id          IN NUMBER
          ,p_task_id_tbl              IN l_task_id_tbl_typ
          ,p_res_list_mem_id_tbl      IN l_res_list_mem_id_tbl_typ
          ,p_unit_of_measure_tbl      IN l_unit_of_measure_tbl_typ
          ,p_track_as_labor_flag_tbl  IN l_track_as_labor_flag_tbl_typ
          ,x_return_status            OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                 OUT  NOCOPY VARCHAR2 );  --File.Sql.39 bug 4440895

PROCEDURE Create_Enterable_Resources (
          p_plan_version_id           IN   NUMBER
          ,p_task_id                  IN   pa_tasks.task_id%TYPE DEFAULT NULL
          ,p_res_del_req_flag         IN   VARCHAR2 DEFAULT 'Y'
          ,x_return_status            OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                 OUT  NOCOPY VARCHAR2);             --File.Sql.39 bug 4440895

FUNCTION get_element_id (
           p_proj_fp_options_id      IN   pa_proj_fp_options.proj_fp_options_id%TYPE
          ,p_element_type            IN   pa_fp_elements.element_type%TYPE
          ,p_task_id                 IN   pa_tasks.task_id%TYPE
          ,p_resource_list_member_id IN   pa_resource_list_members.resource_list_member_id%TYPE)
RETURN pa_fp_elements.proj_fp_elements_id%TYPE;

FUNCTION get_element_plannable_flag (
           p_proj_fp_options_id      IN   pa_proj_fp_options.proj_fp_options_id%TYPE
          ,p_element_type            IN   pa_fp_elements.element_type%TYPE
          ,p_task_id                 IN   pa_tasks.task_id%TYPE
          ,p_resource_list_member_id IN   pa_resource_list_members.resource_list_member_id%TYPE)
RETURN pa_fp_elements.plannable_flag%TYPE;

FUNCTION get_plan_amount_exists_flag (
           p_proj_fp_options_id      IN   pa_proj_fp_options.proj_fp_options_id%TYPE
          ,p_element_type            IN   pa_fp_elements.element_type%TYPE
          ,p_task_id                 IN   pa_tasks.task_id%TYPE
          ,p_resource_list_member_id IN   pa_resource_list_members.resource_list_member_id%TYPE)
RETURN pa_fp_elements.plan_amount_exists_flag%TYPE;

/*=================================================================================
 The follwing function has been created to get resource_planning_level value in
 Create_elements_from_version api.
=================================================================================*/
FUNCTION get_resource_planning_level(
          p_parent_member_id            IN      pa_resource_list_members.parent_member_id%TYPE
         ,p_uncategorized_flag          IN      pa_resource_lists.uncategorized_flag%TYPE
         ,p_grouped_flag                IN      VARCHAR2)
RETURN pa_fp_elements.resource_planning_level%TYPE;

PROCEDURE Create_elements_from_version(
          p_proj_fp_options_id                  IN      pa_proj_fp_options.proj_fp_options_id%TYPE
          ,p_element_type                       IN      pa_fp_elements.element_type%TYPE
          ,p_from_version_id                    IN      pa_budget_versions.budget_version_id%TYPE
          ,p_resource_list_id                   IN      pa_budget_versions.resource_list_id%TYPE
          ,x_mixed_resource_planned_flag        OUT     NOCOPY VARCHAR2  -- new parameter for Bug :- 2625872 --File.Sql.39 bug 4440895
          ,x_return_status                      OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                          OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                           OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


PROCEDURE refresh_res_list_changes (
           p_proj_fp_options_id              IN    PA_PROJ_FP_OPTIONS.PROJ_FP_OPTIONS_ID%TYPE
          ,p_element_type                    IN    PA_FP_ELEMENTS.ELEMENT_TYPE%TYPE  /* COST,REVENUE,ALL,BOTH */
          ,p_cost_resource_list_id           IN    PA_PROJ_FP_OPTIONS.COST_RESOURCE_LIST_ID%TYPE
          ,p_rev_resource_list_id            IN    PA_PROJ_FP_OPTIONS.REVENUE_RESOURCE_LIST_ID%TYPE
          ,p_all_resource_list_id            IN    PA_PROJ_FP_OPTIONS.ALL_RESOURCE_LIST_ID%TYPE
          /* Bug :- 2920954 start of new parameters added for post fp-K one off patch */
          ,p_select_cost_res_auto_flag       IN   pa_proj_fp_options.select_cost_res_auto_flag%TYPE
          ,p_cost_res_planning_level         IN   pa_proj_fp_options.cost_res_planning_level%TYPE
          ,p_select_rev_res_auto_flag        IN   pa_proj_fp_options.select_rev_res_auto_flag%TYPE
          ,p_revenue_res_planning_level      IN   pa_proj_fp_options.revenue_res_planning_level%TYPE
          ,p_select_all_res_auto_flag        IN   pa_proj_fp_options.select_all_res_auto_flag%TYPE
          ,p_all_res_planning_level          IN   pa_proj_fp_options.all_res_planning_level%TYPE
          /* Bug :- 2920954 end of new parameters added for post fp-K one off patch */
          ,x_return_status                   OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
          ,x_msg_count                       OUT   NOCOPY NUMBER --File.Sql.39 bug 4440895
          ,x_msg_data                        OUT   NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE create_assgmt_from_rolluptmp
    ( p_fin_plan_version_id	IN      pa_budget_versions.budget_version_id%TYPE
     ,x_return_status           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count               OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Create_CI_Resource_Assignments
   (  p_project_id              IN      pa_budget_versions.project_id%TYPE
     ,p_budget_version_id       IN      pa_budget_versions.budget_version_id%TYPE
     ,p_version_type            IN      pa_budget_versions.version_type%TYPE
     ,p_impacted_task_id        IN      pa_resource_assignments.task_id%TYPE
     ,x_return_status           OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count               OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                OUT     NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Add_resources_automatically
   (  p_proj_fp_options_id    IN   pa_proj_fp_options.proj_fp_options_id%TYPE
     ,p_element_type          IN   pa_fp_elements.element_type%TYPE
     ,p_fin_plan_level_code   IN   pa_proj_fp_options.cost_fin_plan_level_code%TYPE
     ,p_resource_list_id      IN   pa_resource_lists_all_bg.resource_list_id%TYPE
     ,p_res_planning_level    IN   pa_proj_fp_options.cost_res_planning_level%TYPE
     ,p_entire_option         IN   VARCHAR2
     ,p_element_task_id_tbl   IN   pa_fp_elements_pub.l_task_id_tbl_typ
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE Delete_task_elements
   (  p_task_id               IN   pa_tasks.task_id%TYPE
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE maintain_plannable_tasks
   (p_project_id             IN   pa_projects_all.project_id%TYPE
   ,p_impacted_tasks_tbl     IN   l_impacted_task_in_tbl_typ
   ,x_return_status          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_msg_count              OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data               OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE make_new_tasks_plannable
    ( p_project_id              IN   pa_projects_all.project_id%TYPE
     ,p_tasks_tbl               IN   pa_fp_elements_pub.l_wbs_refresh_tasks_tbl_typ
     ,p_refresh_fp_options_tbl  IN   PA_PLSQL_DATATYPES.IdTabTyp
     ,x_return_status           OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count               OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895



end PA_FP_ELEMENTS_PUB;


 

/
