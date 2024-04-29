--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_BUDGET_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_BUDGET_WF" AUTHID CURRENT_USER AS
/* $Header: PAWFBCES.pls 120.3 2006/07/05 06:13:15 psingara noship $ */
/*#
 * This extension enables you to customize the workflow processes for changing the status of a budget.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname  Budget Workflow
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_BUDGET
 * @rep:category BUSINESS_ENTITY PA_FORECAST
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/
/*#
 * When Oracle Projects determines whether to call Oracle Workflow for a budget status change, it bases the decision on the settings in the budget
 * type and the project type.
 * @param p_draft_version_id The identifier of the draft version
 * @rep:paraminfo {@rep:required}
 * @param p_project_id The identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param p_budget_type_code The budge type code
 * @rep:paraminfo {@rep:required}
 * @param p_pm_product_code The project management product code
 * @rep:paraminfo {@rep:required}
 * @param p_fin_plan_type_id Identifier for the financial plan type
 * @param p_version_type The type of version
 * @param p_result Result of the procedure. Value is either Y or N.
 * @rep:paraminfo {@rep:required}
 * @param p_err_code Error handling code
 * @rep:paraminfo {@rep:required}
 * @param p_err_stage Error handling stage
 * @rep:paraminfo {@rep:required}
 * @param p_err_stack Error handling stack
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Budget Workflow Creation
 * @rep:compatibility S
*/
PROCEDURE Budget_WF_Is_Used
(p_draft_version_id		IN 	NUMBER
, p_project_id 			IN 	NUMBER
, p_budget_type_code		IN 	VARCHAR2
, p_pm_product_code		IN 	VARCHAR2
, p_fin_plan_type_id            IN      NUMBER     default NULL
, p_version_type                IN      VARCHAR2   default NULL
, p_result			IN OUT  NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
, p_err_code                    IN OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
, p_err_stage			IN OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_err_stack			IN OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);
/*#
 * This procedure starts the workflow process for the budget status changes.
 * @param p_draft_version_id The identifier of the draft version
 * @rep:paraminfo {@rep:required}
 * @param p_project_id The identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param p_budget_type_code The budge type code
 * @rep:paraminfo {@rep:required}
 * @param p_mark_as_original Marks as original request
 * @rep:paraminfo {@rep:required}
 * @param p_fck_req_flag Flag indicating if fund checking is required
 * @param p_bgt_intg_flag Flag indicating if budgetary control is enabled
 * @param p_fin_plan_type_id The identifier for financial plan type
 * @param p_version_type The type of version
 * @param p_item_type The type of item
 * @rep:paraminfo {@rep:required}
 * @param p_item_key The item key
 * @rep:paraminfo {@rep:required}
 * @param p_err_code Error handling code
 * @rep:paraminfo {@rep:required}
 * @param p_err_stage Error handling stage
 * @rep:paraminfo {@rep:required}
 * @param p_err_stack Error handling stack
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Start Budget Workflow
 * @rep:compatibility S
*/
PROCEDURE Start_Budget_WF
(p_draft_version_id	IN	NUMBER
, p_project_id 		IN 	NUMBER
, p_budget_type_code	IN 	VARCHAR2
, p_mark_as_original	IN 	VARCHAR2
, p_fck_req_flag        IN      VARCHAR2  DEFAULT NULL
, p_bgt_intg_flag       IN      VARCHAR2  DEFAULT NULL
, p_fin_plan_type_id    IN      NUMBER    default NULL
, p_version_type        IN      VARCHAR2  default NULL
, p_item_type           OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_item_key           	OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_err_code            IN OUT NOCOPY NUMBER  --File.Sql.39 bug 4440895
, p_err_stage         	IN OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
, p_err_stack         	IN OUT NOCOPY VARCHAR2  --File.Sql.39 bug 4440895
);

/*#
 * This procedure is called by the Oracle Workflow to determine the budget approver.
 * @param p_item_type The workflow item type
 * @rep:paraminfo {@rep:required}
 * @param p_item_key The workflow item key
 * @rep:paraminfo {@rep:required}
 * @param p_project_id Identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param p_budget_type_code The budge type code
 * @rep:paraminfo {@rep:required}
 * @param p_workflow_started_by_id Identifier of the person who requested the budget status change
 * @rep:paraminfo {@rep:required}
 * @param p_fin_plan_type_id The identifier of the financial plan type
 * @param p_version_type The type of version
 * @param p_draft_version_id The identifier of the draft version
 * @param p_budget_baseliner_id Identifier of the person selected to approve the budget status change
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Select Budget Approver
 * @rep:compatibility S
*/
PROCEDURE Select_Budget_Approver
(p_item_type			IN   	VARCHAR2
, p_item_key  			IN   	VARCHAR2
, p_project_id			IN      NUMBER
, p_budget_type_code		IN      VARCHAR2
, p_workflow_started_by_id  	IN      NUMBER
, p_fin_plan_type_id            IN      NUMBER     default NULL
, p_version_type                IN      VARCHAR2   default NULL
, p_draft_version_id     IN      NUMBER     default NULL
, p_budget_baseliner_id		OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
 );

/*#
 * This procedure enables you to create validations that Oracle Projects performs whenever a budget or forecast is submitted or baselined.
 * @param p_item_type The workflow item type
 * @rep:paraminfo {@rep:required}
 * @param p_item_key The workflow item key
 * @rep:paraminfo {@rep:required}
 * @param p_project_id Identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param p_budget_type_code The budge type code
 * @rep:paraminfo {@rep:required}
 * @param p_workflow_started_by_id Identifier of the person who requested the budget status change
 * @rep:paraminfo {@rep:required}
 * @param p_event Identifies the requested status of the budget. Value is either SUBMIT or BASELINE.
 * @rep:paraminfo {@rep:required}
 * @param p_fin_plan_type_id The identifier of the financial plan type
 * @param p_version_type The type of version
 * @param p_warnings_only_flag Flag indicating the level of errors the procedure generated. Y indicates that only warnings were generated. N indicates that errors were generated.
 * @rep:paraminfo {@rep:required}
 * @param p_err_msg_count The number of warnings and errors the procedure generated
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Verify Budget Rules
 * @rep:compatibility S
*/
PROCEDURE Verify_Budget_Rules
(p_item_type			IN   	VARCHAR2
, p_item_key  			IN   	VARCHAR2
, p_project_id			IN 	NUMBER
, p_budget_type_code		IN 	VARCHAR2
, p_workflow_started_by_id  	IN 	NUMBER
, p_event			IN	VARCHAR2
, p_fin_plan_type_id            IN      NUMBER     default NULL
, p_version_type                IN      VARCHAR2   default NULL
, p_warnings_only_flag		OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
, p_err_msg_count		OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
);


END pa_client_extn_budget_wf;

 

/
