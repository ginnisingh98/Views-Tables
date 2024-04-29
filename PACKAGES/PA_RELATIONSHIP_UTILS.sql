--------------------------------------------------------
--  DDL for Package PA_RELATIONSHIP_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_RELATIONSHIP_UTILS" AUTHID CURRENT_USER as
/*$Header: PAXRELUS.pls 120.8 2006/04/26 16:12:59 sliburd noship $*/

-- API name                      : Check_Create_Link_Ok
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--  p_element_version_id_from IN NUMBER
--  p_element_version_id_to   IN NUMBER
--  x_return_status           OUT VARCHAR2
--  x_error_message_code      OUT VARCHAR2
--
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Check_Create_Link_Ok
  (
    p_element_version_id_from IN NUMBER
   ,p_element_version_id_to   IN NUMBER
   ,x_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_error_message_code      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

-- API name                      : Check_Create_Dependency_Ok
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--  p_element_version_id_from IN NUMBER
--  p_element_version_id_to   IN NUMBER
--  x_return_status           OUT VARCHAR2
--  x_error_message_code      OUT VARCHAR2
--
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Check_Create_Dependency_Ok
  (
    p_element_version_id_from IN NUMBER
   ,p_element_version_id_to   IN NUMBER
   ,x_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_error_message_code      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


-- API name                      : Check_Create_Association_Ok
-- Type                          : Private Procedure
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--  p_element_version_id_from IN NUMBER
--  p_element_version_id_to   IN NUMBER
--  x_return_status           OUT VARCHAR2
--  x_error_message_code      OUT VARCHAR2
--
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Check_Create_Association_Ok
  (
    p_element_version_id_from IN NUMBER
   ,p_element_version_id_to   IN NUMBER
   ,x_return_status           OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_error_message_code      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

-- API name                      : parent_LP_link_exists
-- Type                          : Private Function
-- Pre-reqs                      : None
-- Return Value                  : Y or N
-- Parameters
--  p_parent_project_id IN NUMBER
--  p_sub_project_id   IN NUMBER
--
--
--  History
--
--  05-DEC-03   Maansari             -Created
--
--  Description
--
-- This fucntion returns 'Y' if there exists a Link from parent latest published version to the
-- subproject.  This is used in view PA_STRUCTURES_LINKS_V to select working version if there is no
-- link from the parent latest published version to the subproject.
--
--

  Function parent_LP_link_exists(
    p_parent_project_id IN NUMBER
   ,p_sub_project_id    IN NUMBER
  ) RETURN VARCHAR2;

-- API name                      : check_create_intra_dep_ok
-- Type                          : Private Check procedure
-- Pre-reqs                      : None
-- Return Value                  : Returns error status
-- Parameters
--  p_pre_project_id    IN NUMBER
--  p_pre_task_ver_id   IN NUMBER
--  p_project_id        IN NUMBER
--  p_task_ver_id       IN NUMBER
--
--
--  History
--
--  19-DEC-03   Maansari             -Created
--
--  Description
--
--
--

  procedure check_create_intra_dep_ok(
   p_pre_project_id    IN NUMBER
  ,p_pre_task_ver_id   IN NUMBER
  ,p_project_id        IN NUMBER
  ,p_task_ver_id       IN NUMBER
  ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


-- API name                      : check_create_inter_dep_ok
-- Type                          : Private Check procedure
-- Pre-reqs                      : None
-- Return Value                  : Returns error status
-- Parameters
--  p_pre_project_id    IN NUMBER
--  p_pre_task_ver_id   IN NUMBER
--  p_project_id        IN NUMBER
--  p_task_ver_id       IN NUMBER
--
--
--  History
--
--  19-DEC-03   Maansari             -Created
--
--  Description
--
--
--

  procedure check_create_inter_dep_ok(
   p_pre_project_id    IN NUMBER
  ,p_pre_task_ver_id   IN NUMBER
  ,p_project_id        IN NUMBER
  ,p_task_ver_id       IN NUMBER
  ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  ,x_msg_count                         OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
  ,x_msg_data                          OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );
--
--
--  History
--
--  28-JAN-04   Mukka             -Created
--
--  Description
--
--
--
FUNCTION DISPLAY_PREDECESSORS( p_element_version_id IN NUMBER)
  RETURN  VARCHAR2;

FUNCTION ChecK_dep_exists(p_element_version_id IN NUMBER)
  RETURN VARCHAR2;

FUNCTION Is_Proj_Top_Program(p_project_id IN NUMBER)
  RETURN VARCHAR2;

FUNCTION Is_Proj_Sub_Project(p_project_id IN NUMBER)
  RETURN VARCHAR2;

FUNCTION DISABLE_SYS_PROG_OK(p_project_id NUMBER)
  RETURN varchar2;

FUNCTION DISABLE_MULTI_PROG_OK(p_project_id NUMBER)
  RETURN varchar2;

FUNCTION CREATE_SUB_PROJ_ASSO_OK(p_task_version_id NUMBER, p_project_id NUMBER,
                                 p_structure_type VARCHAR2 := 'WORKPLAN')
  RETURN VARCHAR2;

FUNCTION IS_AUTO_ROLLUP(p_project_id NUMBER)
  RETURN VARCHAR2;

FUNCTION Get_Latest_Parent_Ver_obj_Id(p_structure_ver_id NUMBER, p_task_id NUMBER
                      , p_relationship_type VARCHAR2 := 'LW') -- Fix for Bug # 4471484.
  RETURN NUMBER;

FUNCTION Get_Latest_Parent_Task_Ver_Id(p_structure_ver_id NUMBER, p_task_id NUMBER
				      , p_relationship_type VARCHAR2 := 'LW') -- Fix for Bug # 5189862.
  RETURN NUMBER;

FUNCTION Get_Latest_Child_Ver_Id(p_task_ver_id NUMBER)
  RETURN NUMBER;

--Bug 3629024 : The following two functions are MUTUALLY RECURSIVE
FUNCTION get_predecessors( p_src_task_ver_id       IN NUMBER
                          ,p_orig_succ_task_ver_id IN NUMBER ) RETURN BOOLEAN;

FUNCTION get_parents_childs( p_src_task_ver_id       IN NUMBER
                            ,p_orig_succ_task_ver_id IN NUMBER ) RETURN BOOLEAN;
--End : Bug 3629024

FUNCTION Check_link_exists(p_project_id number
   ,p_link_type    VARCHAR2 DEFAULT 'SHARED'    --bug 4532826
) return VARCHAR2;

FUNCTION Check_proj_currency_identical(p_src_project_id NUMBER
                                     , p_dest_project_id NUMBER) return VARCHAR2;

FUNCTION check_dependencies_valid(p_new_parent_task_ver_id  IN NUMBER
                                 ,p_task_ver_id IN NUMBER) RETURN VARCHAR2;

-- Begin fix for Bug # 4266540.

FUNCTION check_task_has_sub_proj(p_project_id NUMBER
                     , p_task_id NUMBER
                 , p_task_version_id NUMBER := NULL)
return VARCHAR2;

-- END fix for Bug # 4266540.

-- Begin fix for Bug # 4411603.

function is_str_linked_to_working_ver
(p_project_id NUMBER
 , p_structure_version_id NUMBER
 , p_relationship_type VARCHAR2 := 'LW') return VARCHAR2;

-- End fix for Bug # 4411603.

--bug 4541039
FUNCTION Check_parent_project_Exists
(
     p_project_id NUMBER,
     p_structure_ver_id NUMBER
    ,p_link_type        VARCHAR2     default 'SHARED'    --bug 4541039
)RETURN VARCHAR2;

--bug 4619824
FUNCTION Check_subproject_link_exists
(
     p_project_id NUMBER
    ,p_link_type        VARCHAR2     default 'SHARED'    --bug 4541039
)RETURN VARCHAR2;

end PA_RELATIONSHIP_UTILS;

 

/
