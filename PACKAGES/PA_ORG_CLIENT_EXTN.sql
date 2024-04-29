--------------------------------------------------------
--  DDL for Package PA_ORG_CLIENT_EXTN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_ORG_CLIENT_EXTN" AUTHID CURRENT_USER AS
  -- $Header: PAXORCES.pls 120.5 2006/07/05 10:45:13 sunkalya noship $
/*#
 * The Verify Organization Change Extension enables you to build business rules to determine whether an organization change is allowed
 * for a Project/Task Owning Organization, and to define the error messages that are used when the rules are violated.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Verify Organization Change.
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/



/*#
* Oracle Projects provides this client extension to extend business rules for organization changes.
* @param X_insert_update_mode Flag indicating whether the project or task record is inserted or updated.
* Value = INSERT if the project or task record has not been saved in the database. Value = UPDATE if the
* record exists in the database.
* @rep:paraminfo {@rep:required}
* @param X_calling_module The calling module. The value is PAXPREPR if this extension is called from the
* Projects window. The value is PAXBAUPD if this extension is called from the Process Mass.
* @rep:paraminfo {@rep:required}
* @param X_project_id Identifier of the project to be updated
* @rep:paraminfo {@rep:required}
* @param X_task_id   Identifier of the task to be updated. The value is NULL when the extension is called
* to verify a project organization change.
* @rep:paraminfo {@rep:required}
* @param X_old_organization_id  Identifier of the current organization of the project or task
* @rep:paraminfo {@rep:required}
* @param X_new_organization_id Identifier of the new organization to be assigned to the project or task
* @rep:paraminfo {@rep:required}
* @param X_project_type Identifier of the project type of the project
* @rep:paraminfo {@rep:required}
* @param X_project_start_date Start date of the project
* @rep:paraminfo {@rep:required}
* @param X_project_end_date End date of the project
* @rep:paraminfo {@rep:required}
* @param X_public_sector_flag Public sector flag on the project
* @rep:paraminfo {@rep:required}
* @param X_task_manager_person_id Identifier of the manager of the task
* @rep:paraminfo {@rep:required}
* @param X_Service_type Service type code of the task
* @rep:paraminfo {@rep:required}
* @param X_task_start_date Start date of the task.
* @rep:paraminfo {@rep:required}
* @param X_task_end_date  End date of the task
* @rep:paraminfo {@rep:required}
* @param X_entered_by_user_id Identifier of the user who entered the project or task
* @rep:paraminfo {@rep:required}
* @param X_attribute_category Descriptive flexfield category of the project or task
* @rep:paraminfo {@rep:required}
* @param X_attribute1 Descriptive flexfield segment
* @rep:paraminfo {@rep:required}
* @param X_attribute2 Descriptive flexfield segment
* @rep:paraminfo {@rep:required}
* @param X_attribute3 Descriptive flexfield segment
* @rep:paraminfo {@rep:required}
* @param X_attribute4 Descriptive flexfield segment
* @rep:paraminfo {@rep:required}
* @param X_attribute5 Descriptive flexfield segment
* @rep:paraminfo {@rep:required}
* @param X_attribute6 Descriptive flexfield segment
* @rep:paraminfo {@rep:required}
* @param X_attribute7 Descriptive flexfield segment
* @rep:paraminfo {@rep:required}
* @param X_attribute8 Descriptive flexfield segment
* @rep:paraminfo {@rep:required}
* @param X_attribute9 Descriptive flexfield segment
* @rep:paraminfo {@rep:required}
* @param X_attribute10 Descriptive flexfield segment
* @rep:paraminfo {@rep:required}
* @param X_pm_product_code Identifier of the external system from which the project was imported
* @rep:paraminfo {@rep:required}
* @param X_pm_project_reference The reference code that uniquely identifies the project in the external system
* @rep:paraminfo {@rep:required}
* @param X_pm_task_reference  The reference code that identifies the task in the external system
* @rep:paraminfo {@rep:required}
* @param X_functional_security_flag Flag indicating whether the user is permitted to change the organization.
* The value is Y if the user's responsibility has the function Project: Org Update: Override Standard Checks.
* Otherwise, the value is N.
* @rep:paraminfo {@rep:required}
* @param X_outcome The message error code if a verification rule is violated or if there is a database error.
* @rep:paraminfo {@rep:required}
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Verify Organization Change
* @rep:compatibility S
*/


  PROCEDURE  verify_org_change(X_insert_update_mode     IN VARCHAR2
            ,  X_calling_module         IN VARCHAR2
            ,  X_project_id             IN NUMBER
            ,  X_task_id                IN NUMBER
            ,  X_old_organization_id    IN NUMBER
            ,  X_new_organization_id    IN NUMBER
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
            ,  X_outcome                OUT NOCOPY VARCHAR2 ); --File.Sql.39 bug 4440895

 END PA_ORG_CLIENT_EXTN;


 

/
