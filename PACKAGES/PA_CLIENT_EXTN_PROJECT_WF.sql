--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_PROJECT_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_PROJECT_WF" AUTHID CURRENT_USER as
/* $Header: PAWFPCES.pls 120.2 2006/06/19 05:56:53 sunkalya noship $ */
/*#
 * This extension is used as the basis of your project workflow extension.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Project Workflow.
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*#
 * This API is used to return the project approver ID to the calling workflow process.
 * @param  p_project_id  Identifier of the project.
 * @rep:paraminfo {@rep:required}
 * @param p_workflow_started_by_id Identifier of the person who submitted the project status change.
 * @rep:paraminfo {@rep:required}
 * @param p_project_approver_id Identifier of the project approver.
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Select project approver.
 * @rep:compatibility S
*/

PROCEDURE select_project_approver (p_project_id	            IN NUMBER
				  ,p_workflow_started_by_id IN NUMBER
				  ,p_project_approver_id   OUT NOCOPY NUMBER ); --File.Sql.39 bug 4440895



/*#
 * This API is used to starts the workflow process for project status changes.
 * @param p_project_id  Identifier of the project.
 * @rep:paraminfo {@rep:required}
 * @param p_item_type The workflow item type.
 * @rep:paraminfo {@rep:required}
 * @param p_process Name of the workflow process.
 * @rep:paraminfo {@rep:required}
 * @param p_out_item_key The workflow item key.
 * @rep:paraminfo {@rep:required}
 * @param p_err_stack Error handling stack.
 * @rep:paraminfo {@rep:required}
 * @param p_err_stage Error handling stage.
 * @rep:paraminfo {@rep:required}
 * @param p_err_code Error handling code.
 * @rep:paraminfo {@rep:required}
 * @param p_status_type Project status type.
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Start project workflow.
 * @rep:compatibility S
*/

PROCEDURE Start_Project_Wf (p_project_id    IN NUMBER
                          , p_item_type     IN VARCHAR2
                          , p_process       IN VARCHAR2
                          , p_out_item_key OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                          , p_err_stack    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                          , p_err_stage    OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                          , p_err_code     OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
                          , p_status_type  IN  VARCHAR2 DEFAULT 'PROJECT');


end pa_client_extn_project_wf;

 

/
