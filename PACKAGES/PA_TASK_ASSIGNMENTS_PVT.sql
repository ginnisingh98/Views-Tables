--------------------------------------------------------
--  DDL for Package PA_TASK_ASSIGNMENTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_TASK_ASSIGNMENTS_PVT" AUTHID CURRENT_USER AS
-- $Header: PATAPVTS.pls 120.1 2005/08/19 17:03:23 mwasowic noship $



--Internal Utiilities to convert PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM to fnd_api.g_miss_xxx
FUNCTION PFCHAR(P_CHAR IN VARCHAR2 DEFAULT TO_CHAR(NULL)) RETURN VARCHAR2 ;
FUNCTION PFNUM(P_NUM IN NUMBER DEFAULT TO_NUMBER(NULL)) RETURN NUMBER;
FUNCTION PFDATE(P_DATE IN DATE DEFAULT TO_DATE(NULL)) RETURN DATE ;

PROCEDURE Create_Task_Assignment_Periods
( p_api_version_number	        IN   NUMBER	     := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_commit			            IN   VARCHAR2	     := FND_API.G_FALSE
 ,p_init_msg_list	            IN   VARCHAR2	     := FND_API.G_FALSE
 ,p_pm_product_code	            IN   VARCHAR2      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pm_project_reference        IN   VARCHAR2      := PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR
 ,p_pa_project_id               IN   NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_pa_structure_version_id     IN   NUMBER        := PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM
 ,p_task_assignment_periods_in  IN   pa_task_assignments_pub.ASSIGNMENT_PERIODS_TBL_TYPE
 ,p_task_assignment_periods_out OUT  NOCOPY pa_task_assignments_pub.ASSIGNMENT_OUT_TBL_TYPE
 ,x_msg_count		            OUT  NOCOPY NUMBER
 ,x_msg_data		            OUT  NOCOPY VARCHAR2
 ,x_return_status		        OUT  NOCOPY VARCHAR2
) ;

PROCEDURE lock_version( p_project_id IN NUMBER, p_structure_version_id IN NUMBER);
/*
FUNCTION GET_PERIOD_START_DATE(P_PERIOD_NAME IN VARCHAR2, P_BUDGET_VERSION_ID IN NUMBER) RETURN DATE;
*/
PROCEDURE Derive_Task_Assignments
( p_project_id              IN PA_PROJECTS_ALL.project_id%TYPE
 ,p_task_version_id         IN PA_PROJ_ELEMENT_VERSIONS.element_version_id%TYPE
 ,p_scheduled_start         IN DATE
 ,p_scheduled_end           IN DATE
 ,p_resource_class_code     IN PA_RESOURCE_LIST_MEMBERS.resource_class_code%TYPE
 ,p_resource_list_member_id IN PA_RESOURCE_LIST_MEMBERS.resource_list_member_id%TYPE
 ,p_unplanned_flag          IN PA_RESOURCE_ASSIGNMENTS.unplanned_flag%TYPE
 ,x_resource_assignment_id  OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_task_version_id         OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_resource_list_member_id OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_currency_code           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_rate_based_flag         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
 ,x_rbs_element_id          OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 ,x_msg_count		    OUT NOCOPY NUMBER
 ,x_msg_data		    OUT NOCOPY VARCHAR2
 ,x_return_status           OUT NOCOPY VARCHAR2
);





PROCEDURE Copy_Missing_Unplanned_Asgmts
(
	p_project_id				IN	PA_PROJECTS_ALL.PROJECT_ID%TYPE,
	p_old_structure_version_id	IN	PA_PROJ_ELEM_VER_STRUCTURE.ELEMENT_VERSION_ID%TYPE,
	p_new_structure_version_id	IN	PA_PROJ_ELEM_VER_STRUCTURE.ELEMENT_VERSION_ID%TYPE,
	p_new_budget_version_id		IN	PA_BUDGET_VERSIONS.BUDGET_VERSION_ID%TYPE			DEFAULT NULL,
	x_msg_count					OUT	NOCOPY NUMBER,
	x_msg_data					OUT	NOCOPY VARCHAR2,
	x_return_status				OUT	NOCOPY VARCHAR2
);

PROCEDURE Check_Period_Details(
   P_BUDGET_VERSION_ID      IN pa_budget_versions.budget_version_id%TYPE,
   p_period_set_name        IN gl_periods.period_set_name%TYPE,
   p_time_phase_code        IN pa_proj_fp_options.cost_time_phased_code%TYPE,
   p_accounted_period_type  IN gl_periods.period_type%TYPE,
   p_pa_period_type         IN gl_periods.period_type%TYPE,
   p_task_name              IN pa_proj_elements.name%TYPE,
   p_rlm_alias              IN pa_resource_list_members.alias%TYPE,
   P_PERIOD_NAME            IN OUT NOCOPY VARCHAR2,  --File.Sql.39 bug 4440895
   P_PERIOD_START_DATE      IN OUT NOCOPY DATE,  --File.Sql.39 bug 4440895
   P_PERIOD_END_DATE        IN OUT NOCOPY DATE, --File.Sql.39 bug 4440895
   x_return_status          OUT NOCOPY VARCHAR2
  );

END PA_TASK_ASSIGNMENTS_PVT;

 

/
