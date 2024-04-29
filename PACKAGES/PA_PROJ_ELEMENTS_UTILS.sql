--------------------------------------------------------
--  DDL for Package PA_PROJ_ELEMENTS_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJ_ELEMENTS_UTILS" AUTHID CURRENT_USER AS
/* $Header: PATSK1US.pls 120.7 2007/02/06 10:08:17 dthakker ship $ */

--Global variable to store project id and structure version id
g_Struc_Ver_Id NUMBER := NULL;

--type sub_task is table of task_rec;

PROCEDURE SetGlobalStrucVerId (p_structure_version_id IN NUMBER);

FUNCTION GetGlobalStrucVerId RETURN NUMBER;

-- 5/13/05: DHI ER: Allowing multiple user to update task assignment
--          Added p_require_lock_flag parameter defauled to 'Y'.
-- 8/29/05: R12 Bug fix 4533152: Added p_add_error_flag paramter
--          defaulted to 'N'.
FUNCTION Check_Edit_Task_Ok(p_project_id IN NUMBER,
                            p_structure_version_id IN NUMBER,
                            p_curr_struct_version_id IN NUMBER,
                            p_element_id IN NUMBER := NULL,
                            p_require_lock_flag IN VARCHAR := 'Y',
                            p_add_error_flag IN VARCHAR := 'N')
RETURN VARCHAR2;

PROCEDURE Get_Structure_Attributes(
    p_element_version_id       NUMBER,
    p_structure_type_code       VARCHAR2 := 'WORKPLAN',
    x_task_name                 OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_task_number               OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_task_version_id           OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_structure_version_name    OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_structure_version_number  OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_structure_name            OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_structure_number          OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_structure_id              OUT NOCOPY NUMBER,    --File.Sql.39 bug 4440895
    x_structure_type_code_name  OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
    x_structure_version_id      OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
    x_project_id                OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
);

FUNCTION latest_published_ver_id(
    p_project_id             NUMBER,
    p_structure_type_code    VARCHAR2 := 'WORKPLAN'
) RETURN NUMBER;


-- POST K:Added for Shortcut to get the last updated Workplan version
-- API name                      : Get_Last_Upd_Working_Wp_Ver
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Parameters
--        p_project_id            IN    REQUIRED  NUMBER
--        x_element_version_id    OUT             NUMBER
--              x_element_version_name  OUT            VARCHAR2
--              x_record_version_number OUT            NUMBER
--              x_return_status         OUT            VARCHAR2
--              x_msg_count             OUT            NUMBER
--              x_msg_data              OUT            VARCHAR2
--  History
--
--  17-APRIL-03   MRAJPUT             -Created
Procedure Get_Last_Upd_Working_Wp_Ver(
      p_project_id            IN   pa_proj_elem_ver_structure.project_id%TYPE
     ,x_pev_structure_id      OUT  NOCOPY pa_proj_elem_ver_structure.pev_structure_id%TYPE --File.Sql.39 bug 4440895
     ,x_element_version_id    OUT  NOCOPY pa_proj_elem_ver_structure.element_version_id%TYPE --File.Sql.39 bug 4440895
     ,x_element_version_name  OUT  NOCOPY pa_proj_elem_ver_structure.name%TYPE --File.Sql.39 bug 4440895
     ,x_record_version_number OUT  NOCOPY pa_proj_elem_ver_structure.record_version_number%TYPE --File.Sql.39 bug 4440895
     ,x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data              OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


FUNCTION element_has_child(
    p_structure_version_id NUMBER
) RETURN VARCHAR2;

function IS_LOWEST_TASK(p_task_version_id NUMBER) RETURN VARCHAR2;

  function Check_element_number_Unique
  (
    p_element_number                    IN  VARCHAR2
   ,p_element_id                      IN  NUMBER
   ,p_project_id                      IN  NUMBER
   ,p_structure_id                    IN  NUMBER
   ,p_object_type                     IN  VARCHAR2 := 'PA_TASKS'
  ) return VARCHAR2;

  function Check_Struc_Published
  (
    p_project_id                        IN  NUMBER
   ,p_structure_id                      IN  NUMBER
  ) return VARCHAR2;

  procedure Check_Delete_task_Ver_Ok
  (
    p_project_id                        IN  NUMBER
   ,p_task_version_id                   IN  NUMBER
   ,p_parent_structure_ver_id           IN  NUMBER
   ,p_validation_mode                      IN  VARCHAR2     DEFAULT 'U' --bug 2947492
   ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_error_message_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  function structure_type(
    p_structure_version_id NUMBER,
    p_task_version_id      NUMBER,
    p_structure_type       VARCHAR2 ) RETURN VARCHAR2;

 FUNCTION is_summary_task_or_structure( p_element_version_id NUMBER ) RETURN VARCHAR2;

  procedure Check_Date_range
  (
    p_scheduled_start_date    IN   DATE      :=null
   ,p_scheduled_end_date IN   DATE      :=null
   ,p_obligation_start_date   IN   DATE       :=null
   ,p_obligation_end_date     IN   DATE       :=null
   ,p_actual_start_date        IN  DATE       :=null
   ,p_actual_finish_date IN   DATE       :=null
   ,p_estimate_start_date     IN   DATE       :=null
   ,p_estimate_finish_date    IN   DATE       :=null
   ,p_early_start_date         IN  DATE      :=null
   ,p_early_end_date           IN  DATE       :=null
   ,p_late_start_date          IN  DATE       :=null
   ,p_late_end_date            IN  DATE       :=null
   ,x_return_status           OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_error_message_code      OUT   NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

PROCEDURE Project_Name_Or_Id
  (
    p_project_name                      IN  VARCHAR2
   ,p_project_id                        IN  NUMBER
   ,p_check_id_flag                     IN  VARCHAR2 := 'Y'
   ,x_project_id                        OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_error_msg_code                OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

PROCEDURE task_Ver_Name_Or_Id
  (
    p_task_name                         IN  VARCHAR2
   ,p_task_version_id                        IN  NUMBER
   ,p_structure_version_id              IN NUMBER
   ,p_check_id_flag                     IN  VARCHAR2 := 'Y'
   ,x_task_version_id                       OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_error_msg_code                OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

PROCEDURE UPDATE_WBS_NUMBERS ( p_commit                  IN        VARCHAR2
                              ,p_debug_mode              IN        VARCHAR2
                              ,p_parent_structure_ver_id IN        NUMBER
                              ,p_task_id                 IN        NUMBER
                              ,p_display_seq             IN        NUMBER
                              ,p_action                  IN        VARCHAR2
                              ,p_parent_task_id          IN        NUMBER
                              ,x_return_status          OUT       NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

FUNCTION task_exists_in_struc_ver(
  p_structure_version_id NUMBER,
  p_task_version_id      NUMBER ) RETURN VARCHAR2;

FUNCTION GET_LINKED_TASK_VERSION_ID(
    p_cur_element_id                     NUMBER ,
    p_cur_element_version_id             NUMBER
) RETURN NUMBER;

FUNCTION LINK_FLAG( p_element_id NUMBER ) RETURN VARCHAR2;

-- API name                      : CHECK_TASK_IN_STRUCTURE
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Y if task is in structure; N for task in
--                                 different struture.
--
-- Parameters
--    p_structure_version_id    IN  NUMBER
--    p_task_version_id         IN  NUMBER
--
--  History
--
--  09-JAN-02   HSIU             -Created
--
FUNCTION CHECK_TASK_IN_STRUCTURE(p_structure_version_id NUMBER,
                                 p_task_version_id NUMBER)
RETURN VARCHAR2;


FUNCTION GET_DISPLAY_PARENT_VERSION_ID(p_element_version_id NUMBER,
                                       p_parent_element_version_id NUMBER,
                                       p_relationship_type VARCHAR2,
                                       p_link_task_flag VARCHAR2)
RETURN NUMBER;


FUNCTION IS_ACTIVE_TASK(p_element_version_id NUMBER,
                        p_object_type VARCHAR2)
RETURN VARCHAR2;

FUNCTION Get_DAYS_TO_START(p_element_version_id NUMBER,
                           p_object_type VARCHAR2)
RETURN NUMBER;

FUNCTION Get_DAYS_TO_FINISH(p_element_version_id NUMBER,
                            p_object_type VARCHAR2)
RETURN NUMBER;

FUNCTION GET_PREV_SCH_START_DATE(p_element_version_id NUMBER,
                                 p_parent_structure_version_id NUMBER)
RETURN DATE;

FUNCTION GET_PREV_SCH_FINISH_DATE(p_element_version_id NUMBER,
                                  p_parent_structure_version_id NUMBER)
RETURN DATE;

FUNCTION CHECK_IS_FINANCIAL_TASK(p_proj_element_id NUMBER)
RETURN VARCHAR2;

FUNCTION CONVERT_HR_TO_DAYS(p_hour NUMBER)
RETURN NUMBER;

FUNCTION GET_FND_LOOKUP_MEANING(p_lookup_type VARCHAR2,
                                p_lookup_code VARCHAR2)
RETURN VARCHAR2;

FUNCTION GET_PA_LOOKUP_MEANING(p_lookup_type VARCHAR2,
                               p_lookup_code VARCHAR2)
RETURN VARCHAR2;

-- API name                      : GET_DEFAULT_TASK_TYPE_ID
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Default task type_id
--
-- Parameters
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION GET_DEFAULT_TASK_TYPE_ID
    return NUMBER;


  FUNCTION IS_TASK_TYPE_USED(p_task_type_id IN NUMBER)
    return VARCHAR2;

-- API name                      : GET_LATEST_FIN_PUB_TASK_VER_ID
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Task version id of the latest financial
--                                 published task
--
-- Parameters
--   p_project_id                IN NUMBER
--   p_task_id                   IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION GET_LATEST_FIN_PUB_TASK_VER_ID(
    p_project_id    IN NUMBER
   ,p_task_id       IN NUMBER
  ) return NUMBER;

-- API name                      : CHECK_MODIFY_OK_FOR_STATUS
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if this task can be modified with its
--                                 current status. Y can be modified, N cannot.
--
-- Parameters
--   p_project_id                IN NUMBER
--   p_task_id                   IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION CHECK_MODIFY_OK_FOR_STATUS(
    p_project_id    IN NUMBER
   ,p_task_id       IN NUMBER
  ) return VARCHAR2;


-- API name                      : GET_DISPLAY_SEQUENCE
-- Type                          : FUNCTION
-- Pre-reqs                      : N/A
-- Return Value                  : The display sequence for a given task.
--
-- Parameters
--   p_task_id                   IN NUMBER
--
--  History
--
--  16-OCT-02   XXLU             -Created
--
FUNCTION GET_DISPLAY_SEQUENCE (
   p_task_id       IN  NUMBER
) RETURN NUMBER;


  procedure Check_Del_all_task_Ver_Ok
  (
    p_project_id                        IN  NUMBER
   ,p_task_version_id                   IN  NUMBER
   ,p_parent_structure_ver_id           IN  NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_error_message_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  procedure Check_create_subtask_ok
  ( p_parent_task_ver_id                IN  NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_error_message_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

  FUNCTION Check_task_stus_action_allowed
                          (p_task_status_code IN VARCHAR2,
                           p_action_code      IN VARCHAR2 ) return
  VARCHAR2;


-- hyau new apis for lifecycle changes

-- API name                      : CHECK_ELEMENT_HAS_PHASE
-- Type                          : FUNCTION
-- Pre-reqs                      : N/A
-- Return Value                  : 'Y' if the element has a phase associated with it, else returns 'N'.
--
-- Parameters
--   p_proj_element_id            IN NUMBER
--
--  History
--
--  30-OCT-02   hyau             -Created
--
FUNCTION CHECK_ELEMENT_HAS_PHASE (
   p_proj_element_id       IN  NUMBER
) RETURN VARCHAR2;

-- API name                      : IS_TOP_TASK_ACROSS_ALL_VER
-- Type                          : FUNCTION
-- Pre-reqs                      : N/A
-- Return Value                  : 'Y' if the task is a top task across all versions, else returns 'N'.
--
-- Parameters
--   p_proj_element_id            IN NUMBER
--
--  History
--
--  30-OCT-02   hyau             -Created
--
FUNCTION IS_TOP_TASK_ACROSS_ALL_VER(
   p_proj_element_id       IN  NUMBER
) RETURN VARCHAR2;

-- API name                      : CHECK_PHASE_IN_USE
-- Type                          : FUNCTION
-- Pre-reqs                      : N/A
-- Return Value                  : 'Y' if the phase is already used by another task in the structure, else returns 'N'.
--
-- Parameters
--   p_task_id           NUMBER
--   phase_version_id    NUMBER
--
--  History
--
--  30-OCT-02   hyau             -Created
--
FUNCTION CHECK_PHASE_IN_USE(
   p_task_id       IN  NUMBER
  ,p_phase_version_id  IN NUMBER
) RETURN VARCHAR2;

-- end hyau new apis for lifecycle changes

  PROCEDURE Check_Fin_Task_Published(p_project_id IN NUMBER,
                                     p_task_id IN NUMBER,
                                     x_return_status OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                                     x_error_message_code OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

  PROCEDURE check_move_task_ok
  (
    p_task_ver_id         IN  NUMBER
   ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_error_message_code  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


  PROCEDURE Check_chg_stat_cancel_ok
  (
    p_task_id             IN  NUMBER
   ,p_task_version_id     IN  NUMBER
   ,p_new_task_status     IN  VARCHAR2
   ,x_return_status       OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_error_message_code  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

FUNCTION get_element_name(p_proj_element_id IN NUMBER) RETURN VARCHAR2;
FUNCTION get_element_number(p_proj_element_id IN NUMBER) RETURN VARCHAR2;
FUNCTION get_element_name_number(p_proj_element_id IN NUMBER) RETURN VARCHAR2;

function check_child_element_exist(p_element_version_id NUMBER) RETURN VARCHAR2;

FUNCTION get_task_status_sys_code(p_task_status_code VARCHAR2) RETURN VARCHAR2;

FUNCTION get_next_prev_task_id(
    p_project_id              IN  NUMBER
   ,p_structure_version_id         IN  NUMBER
   ,p_display_seq_id          IN  NUMBER
   ,p_previous_or_next        IN VARCHAR2) RETURN NUMBER;

-- Included the API for Post FP K one off. Bug 2931183
PROCEDURE GET_STRUCTURE_INFO
   (  p_project_id                IN   pa_projects_all.project_id%TYPE
     ,p_structure_type            IN   pa_structure_types.structure_type_class_code%TYPE
     ,p_structure_id              IN   pa_proj_elements.proj_element_id%TYPE
     ,p_is_wp_separate_from_fn    IN   VARCHAR2
     ,p_is_wp_versioning_enabled  IN   VARCHAR2
     ,x_structure_version_id      OUT  NOCOPY pa_proj_element_versions.element_version_id%TYPE --File.Sql.39 bug 4440895
     -- The following parameter has been added after review obsoleting get_task_unpub_status_ver_code api.
     ,x_task_unpub_ver_status_code OUT  NOCOPY pa_proj_element_versions.task_unpub_ver_status_code%TYPE --File.Sql.39 bug 4440895
     ,x_return_status             OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     ,x_msg_count                 OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     ,x_msg_data                  OUT  NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-- Begin add rtarway FP.M development
-- API for checking if a financial task has transaction
-- For detailed comment check package body
PROCEDURE CHECK_TASK_HAS_TRANSACTION
   (
       p_api_version           IN   NUMBER    := 1.0
     , p_calling_module        IN   VARCHAR2  := 'SELF_SERVICE'
     , p_debug_mode            IN   VARCHAR2  := 'N'
     , p_task_id               IN   NUMBER
     , p_project_id            IN   NUMBER  -- Added for Performance fix 4903460
     , x_return_status         OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_msg_count             OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
     , x_msg_data              OUT  NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
     , x_error_msg_code        OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
     , x_error_code            OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895

   );
--End add rtarway FP.M development

function GET_TOP_TASK_ID(
    p_element_version_id  IN NUMBER) return NUMBER;

function GET_TOP_TASK_VER_ID(
    p_element_version_id  IN NUMBER) return NUMBER;

-- This API returns Task Level of WP Tasks
function GET_TASK_LEVEL(
    p_element_version_id  IN NUMBER) return VARCHAR2;

-- Added by avaithia : INCLUDED FOR BUG 4156732
-- This API returns task level of Financial Tasks
-- Please see package body for more details reg. this function
function GET_TASK_LEVEL(
    p_project_id          IN PA_PROJECTS_ALL.PROJECT_ID%TYPE,
    p_proj_element_id     IN PA_PROJ_ELEMENT_VERSIONS.PROJ_ELEMENT_ID%TYPE) return VARCHAR2;

--Added by sabansal
--Function to check whether the given task is a workplan task or not
function CHECK_IS_WORKPLAN_TASK(p_project_id NUMBER,
                                p_proj_element_id NUMBER) RETURN VARCHAR2;
--End added by sabansal

function GET_PARENT_TASK_ID(
    p_element_version_id  IN NUMBER) return NUMBER;

function GET_PARENT_TASK_VERSION_ID(
    p_element_version_id  IN NUMBER) return NUMBER;

function GET_TASK_VERSION_ID(
    p_structure_version_id  IN NUMBER
    ,p_task_id          IN NUMBER) return NUMBER;

function GET_RELATIONSHIP_ID(
    p_object_id_from1  IN NUMBER
    ,p_object_id_to1   IN NUMBER) return NUMBER;

FUNCTION check_task_parents_deliv(p_element_version_id IN number)
RETURN VARCHAR2;

FUNCTION check_deliv_in_hierarchy(p_element_version_id IN number,
                                  p_target_element_version_id IN number)
RETURN VARCHAR2;

FUNCTION check_sharedstruct_deliv(p_element_version_id IN number)
RETURN VARCHAR2;

FUNCTION IS_WF_PROCESS_RUNNING(p_proj_element_id IN number)
RETURN VARCHAR2;

FUNCTION GET_ELEMENT_WF_ITEMKEY(p_proj_element_id IN number,
 p_project_id IN number, p_wf_type_code IN VARCHAR2 := 'TASK_EXECUTION')
RETURN VARCHAR2;

FUNCTION GET_ELEMENT_WF_STATUS(p_proj_element_id IN number,
 p_project_id IN number, p_wf_type_code IN VARCHAR2 := 'TASK_EXECUTION')
RETURN VARCHAR2;

--
--  FUNCTION           check_fin_or_wp_structure
--  PURPOSE            Checks whether the passed proj_element_id is a WP or FIN structure record
--  RETURN VALUE       VARCHAR2 - 'Y' if the passed proj_element_id is of the type WORKPLAN OR FINANCIAL STRUCTURE
--                                'N' otherwise.
--
FUNCTION check_fin_or_wp_structure( p_proj_element_id IN NUMBER ) RETURN VARCHAR2;

FUNCTION CHECK_USER_VIEW_TASK_PRIVILEGE
(
    p_project_id IN NUMBER
)   RETURN VARCHAR2;
--
--
FUNCTION check_deliv_in_hie_upd(p_task_version_id IN number)
RETURN NUMBER;
--
FUNCTION GET_SUB_TASK_VERSION_ID(p_task_version_id IN number)
RETURN NUMBER;
--
--
--  FUNCTION           check_pa_lookup_exists
--  PURPOSE            Checks whether the passed lookup_code and value are valid
--  RETURN VALUE       VARCHAR2 - 'Y' if the valid
--                                'N' otherwise.
--
Function check_pa_lookup_exists(p_lookup_type VARCHAR2,
                                p_lookup_code VARCHAR2)
RETURN VARCHAR2;
--
--
--bug 4183307
function GET_TASK_ID(
    p_project_id  IN NUMBER
    ,p_structure_version_id  IN NUMBER
    ,p_task_version_id          IN NUMBER) return NUMBER;

-- Begin fix for Bug # 4237838.

function is_lowest_level_fin_task(p_project_id NUMBER
				  , p_task_version_id NUMBER
				  , p_include_sub_proj_flag VARCHAR2 := 'Y') -- Fix for Bug # 4290042.
return VARCHAR2;
-- End fix for Bug # 4237838.

-- Bug 4667361: Added this Function
FUNCTION WP_STR_EXISTS_FOR_UPG
 (
  p_project_id                       IN NUMBER
 ) RETURN VARCHAR2;

-- Bug 4667361: Added this Function
FUNCTION CHECK_SHARING_ENABLED_FOR_UPG
 (
  p_project_id IN NUMBER
 ) return VARCHAR2;


-- Procedure included for perf fix  4903460
---------------------------------------------
-- Does the following validations :
---------------------------------------------
-- Check if task has expenditure item
-- Check if task has purchase order distribution
-- Check if task has purchase order requisition
-- Check if task has supplier invoices
-- check if task has supplier invoice distribution
-- Check if task has commitment transaction
-- Check if task has compensation rule set
-- Check if task has draft invoices
-- Check if task has Project_customers

PROCEDURE perform_task_validations
(
 p_project_id     IN  NUMBER,
 p_task_id        IN  NUMBER,
 x_error_code     OUT NOCOPY NUMBER,
 x_error_msg_code OUT NOCOPY VARCHAR2
 );

-- This Function has been included for perf fix  4964992
----------------------------------------------------------------------------------------------------------
-- This function returns the entire hierarchy for the
-- passed task_id.
-- Example: if the task hierarchy is like
--	1
--	  1.1
--	      1.1.1

-- When we pass 1's task_id the entire strucutre above is retrieved.

FUNCTION get_task_hierarchy(
				p_project_id		IN		NUMBER,
				p_task_id		IN		NUMBER
			   )
RETURN sub_task;

--Function to check if the given task is the lowest task at the project level
--ie If there are linked tasks under the child task in a program then the subproject
-- will not be included in the check.
function IS_LOWEST_PROJ_TASK( p_task_version_id NUMBER,
                              p_project_id      Number) RETURN VARCHAR2;


END PA_PROJ_ELEMENTS_UTILS;


/
