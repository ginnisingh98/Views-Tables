--------------------------------------------------------
--  DDL for Package PA_PROJECT_CORE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_CORE" AUTHID CURRENT_USER as
-- $Header: PAXPCORS.pls 120.1.12010000.2 2008/09/30 09:38:03 sugupta ship $


--
--  PROCEDURE
--              delete_project
--  PURPOSE
--      This objective of this API is to delete projects from
--              the PA system.  All detail information will be deleted.
--              This API can be used by Enter Project form and other
--              external systems.
--
--              In order to delete a project, a project must NOT
--              have any of the following:
--
--                     * Event
--                     * Expenditure item
--                     * Puchase order line
--                     * Requisition line
--                     * Supplier invoice (ap invoice)
--                     * Funding
--                     * Baseline budget
--
--  HISTORY
--   24-OCT-95      R. Chiu       Created
--
procedure delete_project ( x_project_id     IN    number
                          , x_validation_mode     IN  VARCHAR2  DEFAULT 'U'   --bug 2947492
              , x_err_code          IN OUT    NOCOPY number --File.Sql.39 bug 4440895
              , x_err_stage         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
              , x_err_stack         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
			  , x_commit            IN VARCHAR2 := FND_API.G_FALSE );


--
--  PROCEDURE
--              import_task
--  PURPOSE
--      This objective of this API is to import tasks into
--              PA system.  This API can be called by task import system
--              and other external systems.  Other task related information
--              can be entered by using Enter Project form or calling table
--              handlers.
--
--
--  HISTORY
--   24-OCT-95      R. Chiu       Created
--
procedure import_task (   x_project_id          IN  number
            , x_task_name       IN  varchar2
            , x_task_number     IN  varchar2
            , x_service_type_code   IN  varchar2
            , x_organization_id     IN  number
            , x_description     IN  varchar2
            , x_task_start_date IN  date
            , x_task_end_date   IN  date
            , x_parent_task_id      IN  number
            , x_pm_project_id       IN  number
            , x_pm_task_id          IN  number
            , x_manager_id          IN  number
            , x_new_task_id         OUT     NOCOPY number --File.Sql.39 bug 4440895
            , x_err_code            IN OUT    NOCOPY number --File.Sql.39 bug 4440895
            , x_err_stage           IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
            , x_err_stack           IN OUT    NOCOPY varchar2); --File.Sql.39 bug 4440895


--
--  PROCEDURE
--              delete_task
--  PURPOSE
--      This objective of this API is to delete tasks from
--              the PA system.  All task detail information along
--              with the specified task will be deleted if there's
--              no transaction charged to the task.  This API can
--              be used by Enter Project form and other external systems.
--
--              To delete a top task and its subtasks, the following
--              requirements must be met:
--                   * No event at top level task
--                   * No funding at top level tasks
--                   * No baseline budget at top level task
--                   * Meet the following requirements for its children
--
--              To delete a mid level task, it involves checking its
--              children and meeting the following requirements for
--              its lowest level task.
--
--              To delete a lowest level task, the following requirements
--              must be met:
--                   * No expenditure item at lowest level task
--                   * No puchase order line at lowest level task
--                   * No requisition line at lowest level task
--                   * No supplier invoice (ap invoice) at lowest level task
--                   * No baseline budget at lowest level task
--
--  HISTORY
--   25-OCT-95      R. Chiu       Created
--   30-DEC-03      Rakesh Raghavan Modified
--
procedure delete_task (   x_task_id         IN    number
                        , x_validation_mode     IN        VARCHAR2  DEFAULT 'U'  --bug 2947492
                        , x_validate_flag       IN        varchar2  DEFAULT 'Y'  --Adding paramater x_validate_flag
                        , x_bulk_flag           IN        VARCHAR2  DEFAULT 'N'  -- 4201927
            , x_err_code            IN OUT    NOCOPY number --File.Sql.39 bug 4440895
            , x_err_stage           IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
            , x_err_stack           IN OUT    NOCOPY varchar2); --File.Sql.39 bug 4440895
--
--  PROCEDURE
--              delete_project_type
--
--  HISTORY
--   01-NOV-02      Mansari       Created
--

procedure delete_project_type (
                          x_project_type_id      IN     number
                        , x_msg_count            OUT    NOCOPY number --File.Sql.39 bug 4440895
                        , x_msg_data             OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                        , x_return_status        OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
);

--
--  PROCEDURE
--              delete_class_category
--
--  HISTORY
--   01-NOV-02      Mansari       Created
--

procedure delete_class_category (
                          x_class_category      IN     VARCHAR2
                        , x_msg_count            OUT    NOCOPY number --File.Sql.39 bug 4440895
                        , x_msg_data             OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                        , x_return_status        OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
);

--
--  PROCEDURE
--              delete_class_code
--
--  HISTORY
--   01-NOV-02      Mansari       Created
--
procedure delete_class_code (
                          x_class_category      IN     VARCHAR2
                        , x_class_code          IN     VARCHAR2
                        , x_msg_count            OUT    NOCOPY number --File.Sql.39 bug 4440895
                        , x_msg_data             OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
                        , x_return_status        OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
);

end PA_PROJECT_CORE ;

/
