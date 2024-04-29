--------------------------------------------------------
--  DDL for Package PA_PROJECT_DATES_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_DATES_UTILS" AUTHID CURRENT_USER AS
/* $Header: PARMPDUS.pls 120.7.12010000.3 2010/05/02 22:25:35 nisinha ship $ */

-- API name		: Get_Project_Start_Date
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER

FUNCTION GET_PROJECT_START_DATE
(  p_project_id                    IN NUMBER
) RETURN DATE;


-- API name		: Get_Project_Finish_Date
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER

FUNCTION GET_PROJECT_FINISH_DATE
(  p_project_id                    IN NUMBER
) RETURN DATE;


-- API name		: Check_Financial_Task_Exists
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_proj_element_id                    IN NUMBER

FUNCTION CHECK_FINANCIAL_TASK_EXISTS
(  p_proj_element_id                    IN NUMBER
) RETURN VARCHAR2;


-- API name		: Get_Task_Start_Date
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER
-- p_proj_element_id               IN NUMBER
-- p_parent_structure_version_id   IN NUMBER
-- x_task_start_date               OUT DATE
-- x_start_as_of_date              OUT DATE
PROCEDURE GET_TASK_START_DATE
(  p_project_id                    IN NUMBER
  ,p_proj_element_id               IN NUMBER
  ,p_parent_structure_version_id   IN NUMBER
  ,x_task_start_date               OUT NOCOPY DATE --File.Sql.39 bug 4440895
  ,x_start_as_of_date              OUT NOCOPY DATE --File.Sql.39 bug 4440895
);


-- API name		: Get_Task_Finish_Date
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER
-- p_proj_element_id               IN NUMBER
-- p_parent_structure_version_id   IN NUMBER
-- x_task_finish_date              OUT DATE
-- x_finish_as_of_date             OUT DATE
PROCEDURE GET_TASK_FINISH_DATE
(  p_project_id                    IN NUMBER
  ,p_proj_element_id               IN NUMBER
  ,p_parent_structure_version_id   IN NUMBER
  ,x_task_finish_date              OUT NOCOPY DATE --File.Sql.39 bug 4440895
  ,x_finish_as_of_date             OUT NOCOPY DATE --File.Sql.39 bug 4440895
);


-- API name		: Get_Task_Derived_Dates
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER
-- p_proj_element_id               IN NUMBER
-- p_parent_structure_version_id   IN NUMBER
-- x_task_start_date               OUT DATE
-- x_task_finish_date              OUT DATE
-- x_task_as_of_date               OUT DATE
PROCEDURE GET_TASK_DERIVED_DATES
(  p_project_id                    IN NUMBER
  ,p_proj_element_id               IN NUMBER
  ,p_parent_structure_version_id   IN NUMBER
  ,x_task_start_date               OUT NOCOPY DATE --File.Sql.39 bug 4440895
  ,x_task_finish_date              OUT NOCOPY DATE --File.Sql.39 bug 4440895
  ,x_task_as_of_date               OUT NOCOPY DATE --File.Sql.39 bug 4440895
);


-- API name		: Get_Task_Copy_Dates
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER
-- p_proj_element_id               IN NUMBER
-- p_parent_structure_version_id   IN NUMBER
-- x_task_start_date               OUT DATE
-- x_task_finish_date              OUT DATE
PROCEDURE GET_TASK_COPY_DATES
(  p_project_id                    IN NUMBER
  ,p_proj_element_id               IN NUMBER
  ,p_parent_structure_version_id   IN NUMBER
  ,x_task_start_date               OUT NOCOPY DATE --File.Sql.39 bug 4440895
  ,x_task_finish_date              OUT NOCOPY DATE --File.Sql.39 bug 4440895
  ,p_act_fin_date_flag             IN VARCHAR2   DEFAULT 'Y'  --bug 4229865
);


-- API name		: Get_Default_Proj_Start_Date
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id                    IN NUMBER

FUNCTION GET_DEFAULT_PROJ_START_DATE
(  p_project_id                    IN NUMBER
) RETURN DATE;

-- Bug 6335446: Start
-- API name             : Get_Default_Assign_Start_Date
-- Type                 : Utility
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id                    IN NUMBER

FUNCTION GET_DEFAULT_ASSIGN_START_DATE
(  p_project_id                    IN NUMBER
) RETURN DATE;
-- Bug 6335446: End

-- API name		: Get_Struct_Schedule_Dates
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_structure_version_id   IN NUMBER
-- x_schedule_start_date               OUT DATE
-- x_schedule_finish_date              OUT DATE
-- x_schedule_as_of_date               OUT DATE
-- x_schedule_duration                 OUT NUMBER
PROCEDURE GET_STRUCT_SCHEDULE_DATES
(  p_structure_version_id	    IN NUMBER
  ,x_schedule_start_date           OUT NOCOPY DATE --File.Sql.39 bug 4440895
  ,x_schedule_finish_date          OUT NOCOPY DATE --File.Sql.39 bug 4440895
  ,x_schedule_as_of_date           OUT NOCOPY DATE --File.Sql.39 bug 4440895
  ,x_schedule_duration             OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
);

-- API name		: Get_Project_Start_Date_Src
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id           IN NUMBER

FUNCTION GET_PROJECT_START_DATE_SRC
(  p_project_id                    IN NUMBER
) RETURN VARCHAR2;

-- Bug 6335446: Start
-- API name             : IS_VALID_ASSIGN_START_DATE
-- Type                 : Utility
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id           IN NUMBER
-- p_assign_start_date    IN DATE

FUNCTION IS_VALID_ASSIGN_START_DATE
(  p_project_id                    IN NUMBER,
   p_assign_start_date             IN DATE
) RETURN VARCHAR2;
-- Bug 6335446: End

-- API name		: Get_Project_Finish_Date_Src
-- Type			: Utility
-- Pre-reqs		: None.
-- Parameters           :
-- p_project_id           IN NUMBER

FUNCTION GET_PROJECT_FINISH_DATE_SRC
(  p_project_id                    IN NUMBER
) RETURN VARCHAR2;

-- API name             : chek_all_tsk_have_act_fin_dt
-- Type                 : Utility
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id           IN NUMBER

FUNCTION chek_all_tsk_have_act_fin_dt
(  p_project_id                           IN NUMBER,
   p_parent_structure_version_id          IN NUMBER
) RETURN VARCHAR2;

-- API name             : chek_one_task_has_act_st_date
-- Type                 : Utility
-- Pre-reqs             : None.
-- Parameters           :
-- p_project_id           IN NUMBER

FUNCTION chek_one_task_has_act_st_date
(  p_project_id                           IN NUMBER,
   p_parent_structure_version_id          IN NUMBER
) RETURN VARCHAR2;


/*============Bug 6511907:PJR DATE VALIDATION ENHANCEMENT=======START=======*/
PROCEDURE Validate_Project_Dates
   (p_project_id IN NUMBER,
    p_start_date IN DATE,
	p_end_date IN DATE,
	x_validate OUT NOCOPY VARCHAR2,
	x_start_date_status OUT NOCOPY VARCHAR2,
	x_end_date_status   OUT NOCOPY VARCHAR2);

PROCEDURE Validate_Resource_Dates
   (p_project_id IN NUMBER,
    p_start_date IN OUT NOCOPY DATE,
	p_end_date IN OUT NOCOPY DATE,
	x_validate OUT NOCOPY VARCHAR2,
	x_start_date_status OUT NOCOPY VARCHAR2,
	x_end_date_status   OUT NOCOPY VARCHAR2);



/* NISINHA Updatable Scheduled people ER */
PROCEDURE VALIDATE_ASSIGNMENT_DATES_BULK
    (p_project_id_tbl        IN                   SYSTEM.PA_NUM_TBL_TYPE,
     p_start_date_tbl        IN OUT NOCOPY        SYSTEM.PA_DATE_TBL_TYPE,
	 p_end_date_tbl          IN OUT NOCOPY        SYSTEM.PA_DATE_TBL_TYPE,
	 x_validate_tbl          IN OUT NOCOPY           SYSTEM.PA_VARCHAR2_2000_TBL_TYPE,
	 x_start_date_status_tbl OUT NOCOPY           SYSTEM.PA_VARCHAR2_2000_TBL_TYPE,
	 x_end_date_status_tbl   OUT NOCOPY           SYSTEM.PA_VARCHAR2_2000_TBL_TYPE,
	 x_msg_data_tbl          OUT NOCOPY           SYSTEM.PA_VARCHAR2_2000_TBL_TYPE);

/* NISINHA Updatable Scheduled people ER */


/* PRABSING Bug 7693634 Start */

PROCEDURE Validate_Resource_Dates_Bulk
    (p_project_id_tbl        IN                   SYSTEM.PA_NUM_TBL_TYPE,
     p_start_date_tbl        IN OUT NOCOPY        SYSTEM.PA_DATE_TBL_TYPE,
	 p_end_date_tbl          IN OUT NOCOPY        SYSTEM.PA_DATE_TBL_TYPE,
	 x_validate_tbl          IN OUT NOCOPY           SYSTEM.PA_VARCHAR2_2000_TBL_TYPE,
	 x_start_date_status_tbl OUT NOCOPY           SYSTEM.PA_VARCHAR2_2000_TBL_TYPE,
	 x_end_date_status_tbl   OUT NOCOPY           SYSTEM.PA_VARCHAR2_2000_TBL_TYPE,
	 x_msg_data_tbl          OUT NOCOPY           SYSTEM.PA_VARCHAR2_2000_TBL_TYPE);

/* PRABSING Bug 7693634 Start */

PROCEDURE Validate_Template_Team_Dates
     (p_project_id IN NUMBER,
      p_template_id IN NUMBER,
	  x_validate OUT NOCOPY VARCHAR2,
	  x_start_date_status OUT NOCOPY VARCHAR2,
	  x_end_date_status   OUT NOCOPY VARCHAR2);
/*============Bug 6511907:PJR DATE VALIDATION ENHANCEMENT=======END=======*/

/*===============Bug 6860603======================*/
PROCEDURE WPP_Validate_Project_Dates
   (p_project_id IN NUMBER,
    p_start_date IN DATE,
	p_end_date IN DATE,
	p_alwd_start_date OUT NOCOPY DATE,
	p_alwd_end_date OUT NOCOPY DATE,
	p_res_min_date OUT NOCOPY DATE,
	p_res_max_date OUT NOCOPY DATE,
	x_validate OUT NOCOPY VARCHAR2,
	x_start_date_status OUT NOCOPY VARCHAR2,
	x_end_date_status   OUT NOCOPY VARCHAR2);
/*===============Bug 6860603======================*/


END PA_PROJECT_DATES_UTILS;

/
