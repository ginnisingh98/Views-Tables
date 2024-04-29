--------------------------------------------------------
--  DDL for Package PA_PROJECT_UTILS2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_PROJECT_UTILS2" AUTHID CURRENT_USER as
-- $Header: PAXPUT2S.pls 120.1 2005/08/19 17:18:40 mwasowic noship $


-- ----------------------------------------------------------
-- Validate_Attribute_Change
--   X_err_code:
--       > 0   for application business errors
--       < 0   for SQL errors
--       = 0   for success
--  If X_err_code > 0, X_err_stage contains the message code
--     X_err_code < 0, X_err_stage contains SQLCODE
-- ----------------------------------------------------------

    PA_Arch_Pur_Subroutine_Error     EXCEPTION ;
    g_sqlerrm                        VARCHAR2(2000);


PROCEDURE validate_attribute_change(
       X_Context                IN VARCHAR2
    ,  X_insert_update_mode     IN VARCHAR2
    ,  X_calling_module         IN VARCHAR2
    ,  X_project_id             IN NUMBER
    ,  X_task_id                IN NUMBER
    ,  X_old_value              IN VARCHAR2
    ,  X_new_value              IN VARCHAR2
    ,  X_project_type           IN VARCHAR2
    ,  X_project_start_date     IN DATE
    ,  X_project_end_date       IN DATE
    ,  X_public_sector_flag     IN VARCHAR2
    ,  X_task_manager_person_id IN NUMBER
    ,  X_Service_type           IN VARCHAR2
    ,  X_task_start_date        IN DATE
    ,  X_task_end_date          IN DATE
    ,  X_entered_by_user_id     IN NUMBER
    ,  X_attribute_category     IN VARCHAR2
    ,  X_attribute1             IN VARCHAR2
    ,  X_attribute2             IN VARCHAR2
    ,  X_attribute3             IN VARCHAR2
    ,  X_attribute4             IN VARCHAR2
    ,  X_attribute5             IN VARCHAR2
    ,  X_attribute6             IN VARCHAR2
    ,  X_attribute7             IN VARCHAR2
    ,  X_attribute8             IN VARCHAR2
    ,  X_attribute9             IN VARCHAR2
    ,  X_attribute10            IN VARCHAR2
    ,  X_pm_product_code        IN VARCHAR2
    ,  X_pm_project_reference   IN VARCHAR2
    ,  X_pm_task_reference      IN VARCHAR2
    ,  X_functional_security_flag IN VARCHAR2
    ,  x_warnings_only_flag   OUT    NOCOPY varchar2 --bug3134205 --File.Sql.39 bug 4440895
    ,  X_err_code          IN OUT    NOCOPY number --File.Sql.39 bug 4440895
    ,  X_err_stage         IN OUT    NOCOPY varchar2 --File.Sql.39 bug 4440895
    ,  X_err_stack         IN OUT    NOCOPY varchar2); --File.Sql.39 bug 4440895
FUNCTION Get_project_business_group
     (p_project_id IN pa_projects_all.project_id%TYPE) RETURN NUMBER ;
PRAGMA RESTRICT_REFERENCES (Get_project_business_group , WNPS, WNDS );

PROCEDURE  Check_Project_Number_Or_Id
                  ( p_project_id          IN pa_projects_all.project_id%TYPE
                   ,p_project_number      IN pa_projects_all.segment1%TYPE
                   ,p_check_id_flag       IN VARCHAR2 := 'A'
                   ,x_project_id          OUT NOCOPY pa_projects_all.project_id%TYPE --File.Sql.39 bug 4440895
                   ,x_return_status       OUT NOCOPY VARCHAR2                                     --File.Sql.39 bug 4440895
                   ,x_error_message_code  OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895


PROCEDURE AbortWorkflow( p_project_id            IN NUMBER,
              			p_record_version_number IN NUMBER,
                         x_return_status OUT NOCOPY VARCHAR2,
                         x_msg_count     OUT NOCOPY NUMBER,
                         x_msg_data      OUT NOCOPY VARCHAR2 );

end PA_PROJECT_UTILS2 ;

 

/
