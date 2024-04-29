--------------------------------------------------------
--  DDL for Package PA_PROJECT_STRUCTURE_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_STRUCTURE_UTILS" AUTHID CURRENT_USER as
/*$Header: PAXSTCUS.pls 120.8.12010000.4 2010/02/09 07:00:58 vgovvala ship $*/

-- API name                      : Check_Delete_Structure_Ver_Ok
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--   p_project_id                   IN      NUMBER
--   p_structure_version_id         IN      NUMBER
--   x_return_status                OUT     VARCHAR2
--   x_error_message_code           OUT     VARCHAR2
--
--  History
    --
--  25-JUN-01   HSIU             -Created
--
--


  procedure Check_Delete_Structure_Ver_Ok
  (
    p_project_id                        IN  NUMBER
   ,p_structure_version_id              IN  NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_error_message_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

-- API name                      : Check_Structure_Name_Unique
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Y if not exists; N if exists.
-- Parameters
--   p_structure_name               IN      VARCHAR2
--   p_structure_id                 IN      NUMBER
--   p_project_id                   IN      NUMBER
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  function Check_Structure_Name_Unique
  (
    p_structure_name                    IN  VARCHAR2
   ,p_structure_id                      IN  NUMBER
   ,p_project_id                        IN  NUMBER
  ) return varchar2;


-- API name                      : Check_Struc_Ver_Name_Unique
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Y if not exists; N if exists.
-- Parameters
--    p_structure_version_name            IN  VARCHAR2
--    p_pev_structure_id                  IN  NUMBER
--    p_structure_id                      IN  NUMBER
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  function Check_Struc_Ver_Name_Unique
  (
    p_structure_version_name            IN  VARCHAR2
   ,p_pev_structure_id                  IN  NUMBER
   ,p_project_id                        IN  NUMBER
   ,p_structure_id                      IN  NUMBER
  ) return VARCHAR2;



-- API name                      : Check_Structure_Type_Exists
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Check_Structure_Type_Exists
  (
    p_project_id                        IN  NUMBER
   ,p_structure_type                    IN  VARCHAR2
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_error_message_code                OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


-- API name                      : Get_Struc_Type_For_Structure
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : N if not exists; Y if exists.
-- Parameters
--    p_structure_id                      IN  NUMBER
--    p_structure_type                    IN  VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  function Get_Struc_Type_For_Structure
  (
    p_structure_id                      IN  NUMBER
   ,p_structure_type                    IN  VARCHAR2
  ) return VARCHAR2;


-- API name                      : Get_Struc_Type_For_Version
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Y if not exists; N if exists.
-- Parameters
--    p_structure_version_id              IN  NUMBER
--    p_structure_type                    IN  VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  function Get_Struc_Type_For_Version
  (
    p_structure_version_id              IN  NUMBER
   ,p_structure_type                    IN  VARCHAR2
  ) return VARCHAR2;



-- API name                      : Check_Publish_Struc_Ver_Ok
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Y if ok; N if can't publish.
-- Parameters
--    p_structure_version_id              IN  NUMBER
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  function Check_Publish_Struc_Ver_Ok
  (
    p_structure_version_id              IN  NUMBER
  ) return VARCHAR2;


-- API name                      : Check_Struc_Ver_Published
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : N if not published; Y if published.
-- Parameters
--    p_structure_version_id              IN  NUMBER
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  function Check_Struc_Ver_Published
  (
    p_project_id                        IN  NUMBER
   ,p_structure_version_id              IN  NUMBER
  ) return VARCHAR2;



-- API name                      : Get_New_Struc_Ver_Name
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--    p_structure_version_id              IN  NUMBER
--    x_structure_version_name            OUT VARCHAR2
--    x_return_status                     OUT VARCHAR2
--    x_error_message_code                OUT VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Get_New_Struc_Ver_Name
  (
    p_structure_version_id              IN  NUMBER
   ,x_structure_version_name            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_return_status                     OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_error_message_code                OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );




-- API name                      : Structure_Version_Name_Or_Id
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--    p_structure_id                      IN  NUMBER
--    p_structure_version_name            IN  VARCHAR2
--    p_structure_version_id              IN  NUMBER
--    p_check_id_flag                     IN  VARCHAR2 := PA_STARTUP.G_Check_ID_Flag
--    x_structure_version_id              OUT  NUMBER
--    x_return_status                     OUT  VARCHAR2
--    x_error_message_code                OUT  VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Structure_Version_Name_Or_Id
  (
    p_structure_id                      IN  NUMBER
   ,p_structure_version_name            IN  VARCHAR2
   ,p_structure_version_id              IN  NUMBER
   ,p_check_id_flag                     IN  VARCHAR2 := PA_STARTUP.G_Check_ID_Flag
   ,x_structure_version_id              OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_error_message_code                OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


-- API name                      : Structure_Name_Or_Id
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : N/A
-- Parameters
--    p_project_id                        IN  NUMBER
--    p_structure_name                    IN  VARCHAR2
--    p_structure_id                      IN  NUMBER
--    p_check_id_flag                     IN  VARCHAR2 := PA_STARTUP.G_Check_ID_Flag
--    x_structure_id                      OUT  NUMBER
--    x_return_status                     OUT  VARCHAR2
--    x_error_message_code                OUT  VARCHAR2
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  procedure Structure_Name_Or_Id
  (
    p_project_id                        IN  NUMBER
   ,p_structure_name                    IN  VARCHAR2
   ,p_structure_id                      IN  NUMBER
   ,p_check_id_flag                     IN  VARCHAR2 := PA_STARTUP.G_Check_ID_Flag
   ,x_structure_id                      OUT  NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_return_status                     OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_error_message_code                OUT  NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


-- API name                      : IS_STRUC_VER_LOCKED_BY_USER
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Y is locked by user - and returns Y also when locked by other users
--                                   and the current user has privelege to Unlock the structure version,
--                                 N is not locked,
--                                 O is locked by other user.
-- Parameters
--   p_user_id                 NUMBER
--   p_structure_version_id    NUMBER
--
--  History
--
--  01-NOV-01   HSIU             -Created
--

  function IS_STRUC_VER_LOCKED_BY_USER(p_user_id NUMBER,
                                     p_structure_version_id NUMBER)
  return VARCHAR2;

-- This function is same as above except for it returns 'O' when locked by other users
-- and current user has privelege to Unlock the structure version
-- API name                      : IS_STRUC_VER_LOCKED_BY_USER1
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Y is locked by user,
--                                 N is not locked,
--                                 O is locked by other user.
-- Parameters
--   p_user_id                 fnd_user.user_id%TYPE
--   p_structure_version_id    pa_proj_element_versions.element_version_id%TYPE
--
--
--  History
--
--  20-may-03   mrajput             -Created
--  Added For bug 2964237

  function IS_STRUC_VER_LOCKED_BY_USER1(p_user_id fnd_user.user_id%TYPE,
                                     p_structure_version_id pa_proj_element_versions.element_version_id%TYPE)
  return VARCHAR2;



-- API name                      : GET_APPROVAL_OPTION
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : N is no approval,
--                                 M is approval with manual publish,
--                                 A is approval with auto publish.
-- Parameters
--   p_project_id    NUMBER
--
--  History
--
--  06-NOV-01   HSIU             -Created
--

  function GET_APPROVAL_OPTION(p_project_id NUMBER)
  return VARCHAR2;


-- API name                      : IS_STRUC_TYPE_LICENSED
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Y for licensed,
--                                 N for not licensed.
--
-- Parameters
--   p_structure_type            VARCHAR2
--
--  History
--
--  06-NOV-01   HSIU             -Created
--

  function IS_STRUC_TYPE_LICENSED(p_structure_type VARCHAR2)
  return VARCHAR2;

-- API name                      : CHECK_PUBLISHED_VER_EXISTS
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Y for published version exists,
--                                 N for not exist.
--
-- Parameters
--   p_project_id               NUMBER
--   p_structure_id             NUMBER
--
--  History
--
--  16-JAN-02   HSIU             -Created
--
  function CHECK_PUBLISHED_VER_EXISTS(p_project_id NUMBER,
                                      p_structure_id NUMBER)
  return VARCHAR2;

-- API name                      : Product_Licensed
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : BOTH -- for workplan and (costing or billing)
--                                 WORKPLAN -- for workplan only
--                                 COSTING -- for costing or billing only
--
--
-- Parameters
--   None
--
--  History
--
--  14-MAR-02   HSIU             -Created
--
  function Product_Licensed
  return varchar2;


-- API name                      : Product_Licensed
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : BOTH -- for having both workplan and (costing or billing)
--                                         in one structure
--                                 WORKPLAN -- for workplan structure only
--                                 COSTING -- for costing or billing structure only
--                                 SPLIT -- for having two structures, one for workplan
--                                          and one for costing.
--
-- Parameters
--   p_project_id                NUMBER
--
--  History
--
--  14-MAR-02   HSIU             -Created
--
  function Associated_Structure(p_project_id NUMBER)
  return varchar2;


-- API name                      : Get_Rollup_Dates
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : None
--
-- Parameters
--   p_element_version_id             IN   NUMBER
--   p_min_sch_start_date             OUT  DATE
--   p_max_sch_finish_date            OUT  DATE
--   p_rollup_last_update_date        OUT  DATE
--
--  History
--
--  25-MAR-02   HSIU             -Created
--
  procedure Get_Rollup_Dates
  (
     p_element_version_id           IN  NUMBER
    ,p_min_sch_start_date           OUT NOCOPY DATE --File.Sql.39 bug 4440895
    ,p_max_sch_finish_date          OUT NOCOPY DATE --File.Sql.39 bug 4440895
    ,p_rollup_last_update_date      OUT NOCOPY DATE --File.Sql.39 bug 4440895
  );

-- API name                      : Get_Workplan_Version
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : None
--
-- Parameters
--   p_project_id                   IN   NUMBER
--   p_structure_version_id         OUT  NUMBER
--
--  History
--
--  10-MAY-02   HSIU             -Created
--
  procedure Get_Workplan_Version
  (
    p_project_id               IN NUMBER
   ,p_structure_version_id    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  );

-- API name                      : Get_Financial_Version
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : None
--
-- Parameters
--   p_project_id                   IN   NUMBER
--   p_structure_version_id         OUT  NUMBER
--
--  History
--
--  26-JAN-04   sdnambia             -Created
--
  procedure Get_Financial_Version
  (
    p_project_id               IN NUMBER
   ,p_structure_version_id    OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  );


-- API name                      : check_miss_transaction_tasks
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  :
--
-- Parameters
--    p_structure_version_id              IN  NUMBER
--
--  History
--
--  24-MAY-01   HSIU             -Created
--
--
  PROCEDURE check_miss_transaction_tasks
  (
     p_structure_version_id              IN  NUMBER
    ,x_return_status                     OUT NOCOPY VARCHAR2
    ,x_msg_count                         OUT NOCOPY NUMBER
    ,x_msg_data                          OUT NOCOPY VARCHAR2
  );

-- API name                      : Get_Struc_Ver_Display_Text
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : display text for structure version dropdown
--                                 list
--
-- Parameters
--
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
--
  FUNCTION Get_Struc_Ver_Display_Text
  ( p_structure_version_name            IN VARCHAR2
   ,p_structure_version_number          IN VARCHAR2
   ,p_status                            IN VARCHAR2
   ,p_baseline_flag                     IN VARCHAR2
  ) return varchar2;


-- API name                      : CHECK_WORKPLAN_ENABLED
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if workplan is enabled
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION check_workplan_enabled
  (  p_project_id IN NUMBER
  ) return VARCHAR2;


-- API name                      : CHECK_FINANCIAL_ENABLED
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if financial is enabled
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION check_financial_enabled
  (  p_project_id IN NUMBER
  ) return VARCHAR2;


-- API name                      : CHECK_SHARING_ENABLED
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if workplan and financial
--                                 are sharing 1 structure
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION check_sharing_enabled
  (  p_project_id IN NUMBER
  ) return VARCHAR2;


-- API name                      : CHECK_ENABLE_WP_OK
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if ok to enable workplan
--                                 Return Y or N
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  procedure check_enable_wp_ok
  (  p_project_id IN NUMBER
    ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_err_msg_code  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


-- API name                      : CHECK_DISABLE_WP_OK
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if ok to disable workplan
--                                 Return Y or N
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  procedure check_disable_wp_ok
  (  p_project_id IN NUMBER
    ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_err_msg_code  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


-- API name                      : CHECK_SHARING_ON_OK
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if ok to share workplan
--                                 Return Y or N
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  procedure check_sharing_on_ok
  (  p_project_id IN NUMBER
    ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_err_msg_code  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

-- API name                      : CHECK_SHARING_OFF_OK
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if ok to split workplan
--                                 Return Y or N
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  procedure check_sharing_off_ok
  (  p_project_id IN NUMBER
    ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_err_msg_code  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


-- API name                      : CHECK_PROJ_PROGRESS_EXIST
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if progress exists for project
--                                 Return Y or N
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION check_proj_progress_exist
  (  p_project_id IN NUMBER
    ,p_structure_id IN NUMBER
    ,p_structure_type IN VARCHAR2 := null    -- Added a new parameter p_structure_type for the BUG 6914708
  ) return VARCHAR2;


-- API name                      : CHECK_TASK_PROGRESS_EXIST
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if progress exists for task
--                                 Return Y or N
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION check_task_progress_exist
  (  p_task_id IN NUMBER
  ) return VARCHAR2;


-- API name                      : GET_LAST_UPDATED_WORKING_VER
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Return last update working structure
--                                 version id
--
-- Parameters
--  p_proj_element_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION GET_LAST_UPDATED_WORKING_VER
  (  p_structure_id IN NUMBER
  ) return NUMBER;


-- API name                      : CHECK_VERSIONING_ON_OK
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if ok to version workplan
--                                 Return Y or N
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  procedure check_versioning_on_ok
  (  p_proj_element_id IN NUMBER
    ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_err_msg_code  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );

-- API name                      : CHECK_VERSIONING_OFF_OK
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if ok to turn off workplan
--                                 versioning
--                                 Return Y or N
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  procedure check_versioning_off_ok
  (  p_proj_element_id IN NUMBER
    ,x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_err_msg_code  OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


-- API name                      : CHECK_FIN_TASK_PROG_EXIST
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if progress exists for financial task
--                                 Return Y or N
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION check_fin_task_prog_exist
  (  p_project_id IN NUMBER
  ) return VARCHAR2;


-- API name                      : CHECK_WORKING_VERSION_EXIST
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if working version exists for
--                                 workplan structure
--                                 Return Y or N
--
-- Parameters
--  p_proj_element_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION check_working_version_exist
  (  p_proj_element_id IN NUMBER
  ) return VARCHAR2;

-- API name                      : CHECK_EDIT_WP_OK
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if the workplan structure version
--                                 can be edited
--                                 Return Y or N
--
-- Parameters
--  p_project_id                IN NUMBER
--  p_structure_version_id      IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION check_edit_wp_ok
  (  p_project_id IN NUMBER
    ,p_structure_version_id IN NUMBER
  ) return VARCHAR2;


-- API name                      : CHECK_EDIT_FIN_OK
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if the financial structure version
--                                 can be edited
--                                 Return Y or N
--
-- Parameters
--  p_project_id                IN NUMBER
--  p_structure_version_id      IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION check_edit_fin_ok
  (  p_project_id IN NUMBER
    ,p_structure_version_id IN NUMBER
  ) return VARCHAR2;

-- API name                      : GET_FIN_STRUCTURE_ID
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Get the financial structure id
--                                 Return structure id for the financial
--                                 structure
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION GET_FIN_STRUCTURE_ID
  ( p_project_id IN NUMBER
  ) return NUMBER;

-- API name                      : GET_LATEST_FIN_STRUC_VER_ID
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Get the latest financial structure version
--                                 id.  Return structure version id for the
--                                 latest financial structure version. Return
--                                 NULL if no published version exists.
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION GET_LATEST_FIN_STRUC_VER_ID
  ( p_project_id IN NUMBER
  ) return NUMBER;

-- API name                      : GET_LATEST_FIN_STRUC_VER_ID
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : 'FINANCIAL' for a financial only task or
--                                 structure, 'WORKPLAN' for a workplan only
--                                 or shared structure.
--
-- Parameters
--  p_project_id                IN NUMBER
--  p_proj_element_id           IN NUMBER
--  p_object_type               IN VARCHAR2
--
--  History
--
--  23-OCT-02   HSIU             -Created
  FUNCTION get_element_struc_type
  ( p_project_id       IN NUMBER
   ,p_proj_element_id  IN NUMBER
   ,p_object_type      IN VARCHAR2
  ) return VARCHAR2;


  FUNCTION get_latest_wp_version
  ( p_project_id       IN NUMBER
  ) return NUMBER;


-- API name                      : Check_del_work_struc_ver_ok
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if ok to delete working structure
--                                 version
--                                 Return Y or N
--
-- Parameters
--  p_structure_version_id      IN NUMBER
--
--  History
--
--  26-JUL-02   HSIU             -Created
--
  FUNCTION check_del_work_struc_ver_ok
  ( p_structure_version_id IN NUMBER
  ) return VARCHAR2;


-- API name                      : Check_txn_on_summary_tasks
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Y if transactions exist on summary task
--                                 N if not
-- Parameters
--    p_structure_version_id              IN  NUMBER
--    x_return_status                     OUT VARCHAR2
--    x_error_message_code                OUT VARCHAR2
--
--  History
--
--  24-MAY-01   HSIU             -Created
--
--
  PROCEDURE Check_txn_on_summary_tasks
  (
    p_structure_version_id              IN  NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2
   ,x_msg_count                         OUT NOCOPY NUMBER
   ,x_msg_data                          OUT NOCOPY VARCHAR2
  );


-- API name                      : check_tasks_statuses_valid
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Y if all statuses are valid in the structure version
--                                 N if not
-- Parameters
--    p_structure_version_id              IN  NUMBER
--    x_return_status                     OUT VARCHAR2
--    x_error_message_code                OUT VARCHAR2
--
--  History
--
--  24-MAY-01   HSIU             -Created
--
--
  PROCEDURE check_tasks_statuses_valid
  (
    p_structure_version_id              IN  NUMBER
   ,x_return_status                     OUT NOCOPY VARCHAR2
   ,x_msg_count                         OUT NOCOPY NUMBER
   ,x_msg_data                          OUT NOCOPY VARCHAR2
  );



-- API name                      : get_unpub_version_count
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : number of unpublished structure versions
-- Parameters
--   p_project_id                   IN      NUMBER
--   p_structure_id                 IN      NUMBER
--
--  History
--
--  25-JUN-01   HSIU             -Created
--
--


  function get_unpub_version_count
  (
    p_project_id                        IN  NUMBER
   ,p_structure_ver_id                  IN  NUMBER
  ) return NUMBER;

-- API name                      : get_structrue_version_status
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Get the status of a structure version
-- Parameters
--   p_project_id                   IN      NUMBER
--   p_structure_version_id         IN      NUMBER
--
--  History
--
--  08-JAN-03   maansari             -Created
--
--


  function get_structrue_version_status
  (
    p_project_id                        IN  NUMBER
   ,p_structure_version_id              IN  NUMBER
  ) return VARCHAR2;


  function is_structure_version_updatable
  (
    p_structure_version_id              IN  NUMBER
  ) return VARCHAR2;

--Bug 3010538
FUNCTION GET_UPDATE_WBS_FLAG(
     p_project_id            IN  pa_projects_all.project_id%TYPE
    ,p_structure_version_id  IN  pa_proj_element_versions.element_version_id%TYPE
)
return VARCHAR2;

--Bug 3010538
FUNCTION GET_PROCESS_STATUS_CODE(
     p_project_id            IN  pa_projects_all.project_id%TYPE
    ,p_structure_version_id  IN  pa_proj_element_versions.element_version_id%TYPE
)
return VARCHAR2;

--Bug 3010538
FUNCTION GET_PROCESS_WBS_UPDATES_OPTION(
     p_task_count            IN  NUMBER
    ,p_project_id            IN  NUMBER  default null     --bug 4370533
)
return VARCHAR2;

--Bug 3010538
FUNCTION GET_PROCESS_STATUS_CODE(
     p_project_id            IN  pa_projects_all.project_id%TYPE
    ,p_structure_type        IN  pa_structure_types.structure_type%TYPE
)
return VARCHAR2;

function GET_FIN_STRUC_VER_ID(p_project_id IN NUMBER) return NUMBER;

--Bug 3010538
PROCEDURE GET_CONC_REQUEST_DETAILS(
     p_project_id            IN  pa_projects_all.project_id%TYPE
    ,p_structure_type        IN  pa_structure_types.structure_type%TYPE
    ,x_request_id            OUT NOCOPY pa_proj_elem_ver_structure.conc_request_id%TYPE --File.Sql.39 bug 4440895
    ,x_process_code          OUT NOCOPY pa_proj_elem_ver_structure.process_code%TYPE --File.Sql.39 bug 4440895
    ,x_structure_version_id  OUT NOCOPY pa_proj_elem_ver_structure.element_version_id%TYPE --File.Sql.39 bug 4440895
    ,x_return_status         OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
    ,x_msg_count             OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
    ,x_msg_data              OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

--Bug 3010538

--Below function is added for bug#3049157
FUNCTION GET_CONC_REQUEST_ID(
     p_project_id            IN  pa_projects_all.project_id%TYPE
    ,p_structure_type        IN  pa_structure_types.structure_type%TYPE
)
return NUMBER;

FUNCTION GET_STRUCT_CONC_ID(
     p_structure_version_id  IN  pa_proj_element_versions.parent_structure_version_id%TYPE
     ,p_project_id            IN  pa_projects_all.project_id%TYPE -- Included for Perf. Bug fix 3968091
)
return NUMBER ;

-- API name                      : CHECK_DELIVERABLE_ENABLED
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if deliverable is enabled
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  17-Dec-03   Bhumesh K.       -Created
--  This is added for FP_M changes

  FUNCTION check_Deliverable_enabled (
     p_project_id IN NUMBER
  ) Return VARCHAR2;

-- API name                      : get_current_working_ver_id
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  :get the WP current working version
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  17-Dec-03   maansari      -Created
--  This is added for FP_M changes
--FPM changes bug 3301192

FUNCTION get_current_working_ver_id( p_project_id  NUMBER
)
RETURN NUMBER;

--------------------------------------------------------------------------
-- API name                      : Check_Struct_Has_Dep
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check the dependency of a structure version ID
--
-- Parameters
--  P_Version_ID                IN NUMBER
--
--  History
--
-- 6-Jan-04   Bhumesh K.       -Created
-- This is added for FP_M changes. Refer to tracking bug 3305199 for more details

FUNCTION Check_Struct_Has_Dep (
    P_Version_ID    IN  NUMBER
)
RETURN VARCHAR2;

FUNCTION get_Structure_sharing_code(
        p_project_id    IN      NUMBER
)
RETURN VARCHAR2;

FUNCTION check_third_party_sch_flag(
        p_project_id    IN      NUMBER
)
RETURN VARCHAR2;

FUNCTION check_dep_on_summary_tk_ok(
        p_project_id    IN      NUMBER
)
RETURN VARCHAR2;

FUNCTION GET_LAST_UPD_WORK_VER_OLD(
  p_structure_id IN NUMBER
) return NUMBER;

FUNCTION GET_STRUCT_VER_UPDATE_FLAG(
  p_structure_version_id NUMBER
) return VARCHAR2;

-- API name                      : Get_Baseline_Struct_Ver
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Get the baseline structure version
--                                 id.  Return structure version id. Return
--                                 NULL if no baseline version exists.
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  16-Mar-04   SMUKKA             -Created
--
 FUNCTION Get_Baseline_Struct_Ver
 ( p_project_id IN NUMBER
 ) return NUMBER;
--
--
-- API name                      : Get_Sch_Dirty_fl
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Get the Schedule_diryt_flag for the given sturcture version
--                                 id and project_id.  Return schedule_dirty_flag.Return
--                                 NULL if no sturcture_version exists
--
-- Parameters
--  p_project_id                IN NUMBER
--  p_structure_version_id      IN NUMBER
--
--  History
--
--  16-Mar-04   SMUKKA             -Created
--
 FUNCTION Get_Sch_Dirty_fl
 (
     p_project_id           IN NUMBER
    ,p_structure_version_id IN NUMBER
 ) RETURN VARCHAR2;
--
--
-- API name                      : Check_Subproject_Exists
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : This API check if there is subproject association for the given
--                                 sturcture version id and project_id.  Return Y if there is subproject
--                                 association or N if there is subproject association
--
-- Parameters
--  p_project_id                IN NUMBER
--  p_structure_ver_id          IN NUMBER
--
--  History
--
--  29-Mar-04   SMUKKA             -Created
--
FUNCTION Check_Subproject_Exists
(
     p_project_id NUMBER,
     p_structure_ver_id NUMBER
    ,p_link_type        VARCHAR2     default 'SHARED'    --bug 4541039
)RETURN VARCHAR2;
--
--
-- API name                      : Check_Structure_Ver_Exists
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : This API check if there is structure version is valid exists for the
--                                 given sturcture version id and project_id.  Return Y if there is structure version
--                                 or N if there is no structure version.
--
-- Parameters
--  p_project_id                IN NUMBER
--  p_structure_ver_id          IN NUMBER
--
--  History
--
--  16-JUL-04   SMUKKA             -Created
--
FUNCTION Check_Structure_Ver_Exists
(
     p_project_id NUMBER,
     p_structure_ver_id NUMBER
)RETURN VARCHAR2;
--
--
Function Check_Project_exists(p_project_id IN NUMBER)
RETURN VARCHAR2;
--
--
-- Begin fix for Bug # 4373055.

PROCEDURE GET_PROCESS_STATUS_MSG(
p_project_id              IN  pa_projects_all.project_id%TYPE
, p_structure_type        IN  pa_structure_types.structure_type%TYPE := NULL
, p_structure_version_id  IN  pa_proj_element_versions.element_version_id%TYPE := NULL
, p_context       IN  VARCHAR2 := NULL
, x_message_name      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, x_message_type      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, x_structure_version_id  OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
, x_conc_request_id   OUT NOCOPY NUMBER); --File.Sql.39 bug 4440895

PROCEDURE SET_PROCESS_CODE_IN_PROC(
p_project_id              IN    NUMBER
, p_structure_version_id  IN    NUMBER
, p_calling_context       IN    VARCHAR2
, p_conc_request_id       IN    NUMBER
, x_return_status         OUT   NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

PROCEDURE SET_PROCESS_CODE_ERR(
p_project_id              IN    NUMBER
, p_structure_version_id  IN    NUMBER
, p_calling_context       IN    VARCHAR2
, p_conc_request_id       IN    NUMBER
, x_return_status         OUT   NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

-- End fix for Bug # 4373055.

-- Begin fix for Bug#5659575

PROCEDURE SET_PROCESS_CODE(
p_project_id              IN    NUMBER
, p_structure_version_id  IN    NUMBER
, p_process_code          IN    VARCHAR2
, p_conc_request_id       IN    NUMBER
, x_return_status         OUT   NOCOPY VARCHAR2);

-- End fix for Bug#5659575

-- Begin fix for Bug # 4502325.

procedure get_structure_msg(p_project_id              IN        NUMBER
                            , p_structure_type        IN        VARCHAR2
                            , p_structure_version_id  IN        NUMBER
                            , p_context               IN        VARCHAR2 := NULL
                            , x_message_name          OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                            , x_message_type          OUT       NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                            , x_structure_version_id  OUT       NOCOPY NUMBER --File.Sql.39 bug 4440895
                            , x_conc_request_id       OUT       NOCOPY NUMBER); --File.Sql.39 bug 4440895

-- End fix for Bug # 4502325.

-- Begin Bug # 4582750.

procedure lock_unlock_wp_str_autonomous
(p_project_id                       IN  NUMBER
 ,p_structure_version_id            IN  NUMBER
 ,p_lock_status_code                IN  VARCHAR2 := 'LOCKED'
 ,p_calling_module                  IN  VARCHAR2   := 'SELF_SERVICE'
 ,x_return_status                   OUT NOCOPY VARCHAR2
 ,x_msg_count                       OUT NOCOPY NUMBER
 ,x_msg_data                        OUT NOCOPY VARCHAR2);

procedure lock_unlock_wp_str
(p_project_id                       IN  NUMBER
 ,p_structure_version_id            IN  NUMBER
 ,p_lock_status_code                IN  VARCHAR2 := 'LOCKED'
 ,p_calling_module                  IN  VARCHAR2   := 'SELF_SERVICE'
 ,x_return_status                   OUT NOCOPY VARCHAR2
 ,x_msg_count                       OUT NOCOPY NUMBER
 ,x_msg_data                        OUT NOCOPY VARCHAR2);

-- End Bug # 4582750.

-- bug 4597323
-- API name                      : check_program_flag_enable
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : This API returns sys_program_flag from pa_projects_all table for a given project.
--                                 It's created to use from Projects Form.
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  08-SEP-05   maansari             -Created
--
FUNCTION check_program_flag_enable(
     p_project_id        IN  NUMBER
) RETURN VARCHAR2;

-- API name                      : check_del_pub_struc_ver_ok
-- Tracking Bug                  : 4925192
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Check if ok to delete Published structure
--                                 version
--                                 Return Y or N
--
-- Parameters
--  p_structure_version_id      IN NUMBER
--
--  History
--
--  20-OCT-06   Ram Namburi             -Created
--
--  Purpose:
--  This API will determine whether a published structure version can be deleted or not.
--
--  Business Rules:
--
--  The published version cannot be deleted if
--
--  1.	It is the current baseline version - because the metrics are calculated using
--      the baselined values from the current baselined workplan structure version
--  2.	It is the latest published version - because the PJI module uses the
--      financial plan to rollup data on the latest published workplan structure version
--  3.	It is a part of a program - because it is technically challenging to handle
--      the deletion of published workplan structure versions that belong to the
--      program itself or an intermediate sub-project in a program hierarchy



  FUNCTION check_del_pub_struc_ver_ok
  ( p_structure_version_id IN NUMBER
   ,p_project_id IN NUMBER
  ) return VARCHAR2;


-- bug 5183704
-- API name                      : check_pending_link_changes
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : This API returns "Y" if pending link changes exist for a given project as per
--				   log type PRG_CHANGE in the pa_pji_proj_events_log, pji_pa_proj_events_log tables
--                                 It's created to use from Projects Self Services (sql from vijay r).
--
-- Parameters
--  p_project_id                IN NUMBER
--
--  History
--
--  09-MAY-06   sliburd             -Created
--
FUNCTION CHECK_PENDING_LINK_CHANGES(
     p_project_id        IN  NUMBER
    ,p_version_id        IN  NUMBER  --Added for bug 8889029
) RETURN VARCHAR2;

-- bug 8889029
FUNCTION CHECK_UPPD_RUNNING(
     p_project_id        IN  NUMBER
    ,p_version_id        IN  NUMBER
) RETURN VARCHAR2;

-- bug 8889029
FUNCTION GET_ROLLUP_PROFILE_VAL(
     lookup_code         IN VARCHAR2
) RETURN VARCHAR2;


-- API name                      : check_exp_item_dates
-- Type                          : Utils API
-- Pre-reqs                      : None
-- Return Value                  : Validate all the lowest level task dates against
--                                 the expenditure item dates
--
-- Parameters
--  p_project_id                IN NUMBER
--  p_structure_version_id      IN NUMBER
--
procedure check_exp_item_dates (
    p_project_id               IN NUMBER
   ,p_structure_version_id     IN NUMBER
   ,x_return_status            OUT NOCOPY VARCHAR2
   ,x_msg_count                OUT NOCOPY NUMBER
   ,x_msg_data                 OUT NOCOPY VARCHAR2
);

end PA_PROJECT_STRUCTURE_UTILS;

/
