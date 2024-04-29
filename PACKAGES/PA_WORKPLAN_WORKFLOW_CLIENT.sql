--------------------------------------------------------
--  DDL for Package PA_WORKPLAN_WORKFLOW_CLIENT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_WORKPLAN_WORKFLOW_CLIENT" AUTHID CURRENT_USER as
/*$Header: PAXSTWCS.pls 120.6 2006/07/20 12:11:41 vkadimes noship $*/
/*#
 * This extension enables you to customize the workflow processes for submitting, approving, and publishing a workplan.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname  Workplan Workflow Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_TASK
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*#
 * This procedure starts the workflow process for a workplan.
 * @param p_item_type The workflow item type
 * @rep:paraminfo {@rep:required}
 * @param  p_item_key The workflow item key
 * @rep:paraminfo {@rep:required}
 * @param p_process_name Name of the workflow process
 * @rep:paraminfo {@rep:required}
 * @param p_structure_version_id Identifier of the structure version
 * @rep:paraminfo {@rep:required}
 * @param p_responsibility_id  Identifier of the user responsibility
 * @rep:paraminfo {@rep:required}
 * @param p_user_id Identifier for the user
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error messageThe
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Start Workflow.
 * @rep:compatibility S
*/
  procedure START_WORKFLOW
  (
    p_item_type              IN  VARCHAR2
   ,p_item_key               IN  VARCHAR2
   ,p_process_name           IN  VARCHAR2
   ,p_structure_version_id   IN  NUMBER
   ,p_responsibility_id      IN  NUMBER
   ,p_user_id                IN  NUMBER
   ,x_msg_count              OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
   ,x_msg_data               OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
   ,x_return_status          OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );
/*#
 * This procedure determines the approver for the workplan approval process.
 * @param p_item_type The workflow item type
 * @rep:paraminfo {@rep:required}
 * @param  p_item_key The workflow item key
 * @rep:paraminfo {@rep:required}
 * @param actid Identifier of the action
 * @rep:paraminfo {@rep:required}
 * @param funcmode Workflow function mode
 * @rep:paraminfo {@rep:required}
 * @param resultout Process result
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Select Approver
 * @rep:compatibility S
*/
  procedure SELECT_APPROVER
  (
    p_item_type          IN  VARCHAR2
   ,p_item_key           IN  VARCHAR2
   ,actid                IN  NUMBER
   ,funcmode             IN  VARCHAR2
   ,resultout            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );
/*#
 * This procedure determines which users receive workflow notifications when a workplan is submitted, approved, rejected, or published.
 * @param p_item_type The workflow item type
 * @rep:paraminfo {@rep:required}
 * @param p_item_key The workflow item key
 * @rep:paraminfo {@rep:required}
 * @param p_status_code The workplan status code
 * @rep:paraminfo {@rep:required}
 * @param actid Identifier of the action
 * @rep:paraminfo {@rep:required}
 * @param funcmode Workflow function mode
 * @rep:paraminfo {@rep:required}
 * @param resultout Process result
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Notification Party
 * @rep:compatibility S
*/
  procedure set_notification_party
  (
    p_item_type          IN  VARCHAR2
   ,p_item_key           IN  VARCHAR2
   ,p_status_code        IN  VARCHAR2
   ,actid                IN  NUMBER
   ,funcmode             IN  VARCHAR2
   ,resultout            OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  );


/*#
 * This API is a client extension. While publishing a workplan version, if user chooses the option of
 * Review and Publish Workplan, a preview document is sent as a notification to all the project stakeholders
 * which contains the details of the version to be published. This client extension API lets the user customize this
 * preview document.
 * @param document_id  Unique Identifier of the Preview Document.
 * @rep:paraminfo {@rep:required}
 * @param display_type Display type of the Preview Document
 * @rep:paraminfo {@rep:required}
 * @param document The actual document content.
 * @rep:paraminfo {@rep:required}
 * @param document_type Document Type
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Show Workplan Preview.
 * @rep:compatibility S
 */
  procedure show_workplan_preview
  (document_id IN VARCHAR2,
   display_type IN VARCHAR2,
   document IN OUT NOCOPY clob, --File.Sql.39 bug 4440895
   document_type IN OUT NOCOPY VARCHAR2); --File.Sql.39 bug 4440895

/*#
* This procedure enables you to specify the lead time between the start of the  task execution
* workflow process and start date of the associated task.
* execution lead time before which task execution   workflow process should be started . The project
* identifier,task identifier and the task execution   workflow item type will be passed to client extension
* so that task execution lead time can be set per task.
* @param p_item_type The workflow item type
* @rep:paraminfo {@rep:required}
* @param p_task_number Unique identifier of the task for which the lead time needs to be set
* @rep:paraminfo {@rep:required}
* @param p_project_number The unique Oracle Projects number for the project
* @rep:paraminfo {@rep:required}
* @param x_lead_days Lead days (number of days to start the workflow ahead of the task start date of the associated task)
* @rep:paraminfo {@rep:required}
* @rep:scope public
* @rep:lifecycle active
* @rep:displayname Set Lead Days
* @rep:compatibility S
*/
procedure SET_LEAD_DAYS
  (
    p_item_type      IN VARCHAR2 :='PATSKEX'
   ,p_task_number    IN VARCHAR2
   ,p_project_number IN VARCHAR2
   ,x_lead_days      OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  );


end PA_WORKPLAN_WORKFLOW_CLIENT;

 

/
