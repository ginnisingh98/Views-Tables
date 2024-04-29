--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_BUDGET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_BUDGET" AUTHID CURRENT_USER AS
/* $Header: PAXBCECS.pls 120.6 2006/07/20 09:22:53 psingara ship $ */
/*#
 * This extension enables you to define rules for validating a budget before it's status is changed.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Budget Calculation Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_BUDGET
 * @rep:category BUSINESS_ENTITY PA_FORECAST
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*#
 * This procedure is used to calculate the raw cost for a budget.
 * @param x_budget_version_id The identifier of the budget version
 * @rep:paraminfo {@rep:required}
 * @param x_project_id The identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param x_task_id The identifier of the task. This value is set to zero if budgeting is done at the project level.
 * @rep:paraminfo {@rep:required}
 * @param x_resource_list_member_id The identifier of the resource list member
 * @rep:paraminfo {@rep:required}
 * @param x_resource_list_id The identifier of the resource list
 * @rep:paraminfo {@rep:required}
 * @param x_resource_id The identifier of the resource
 * @rep:paraminfo {@rep:required}
 * @param x_start_date The start date of the budget line
 * @rep:paraminfo {@rep:required}
 * @param x_end_date The end date of the budget line
 * @rep:paraminfo {@rep:required}
 * @param x_period_name The effective period of the budget line (if any)
 * @rep:paraminfo {@rep:required}
 * @param x_quantity The quantity of the budget line
 * @rep:paraminfo {@rep:required}
 * @param x_raw_cost The raw cost of the budget line
 * @rep:paraminfo {@rep:required}
 * @param x_pm_product_code The product code of the product where the budget line originated
 * @rep:paraminfo {@rep:required}
 * @param x_txn_currency_code The transaction currency code
 * @param x_error_code Error handling code
 * @rep:paraminfo {@rep:required}
 * @param x_error_message User-defined error message
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Calculate Raw Cost
 * @rep:compatibility S
*/
  procedure Calc_Raw_Cost( x_budget_version_id     in number,
			   x_project_id             in number,
			   x_task_id                in number,
			   x_resource_list_member_id  in number,
			   x_resource_list_id       in number,
			   x_resource_id            in number,
                           x_start_date             in date,
                           x_end_date               in date,
                           x_period_name            in varchar2,
			   x_quantity               in number,
			   x_raw_cost		    in out NOCOPY number, --File.Sql.39 bug 4440895
			   x_pm_product_code        in varchar2,
                           x_txn_currency_code      IN VARCHAR2 DEFAULT NULL,
                           x_error_code             out NOCOPY number,     --File.Sql.39 bug 4440895
			   x_error_message          out NOCOPY varchar2); --File.Sql.39 bug 4440895

/*#
 * This procedure is used to calculate the burdened cost for a budget.
 * @param x_budget_version_id The identifier of the budget version
 * @rep:paraminfo {@rep:required}
 * @param x_project_id The identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param x_task_id The identifier of the task. This value is set to zero if budgeting is done at the project level.
 * @rep:paraminfo {@rep:required}
 * @param x_resource_list_member_id The identifier of the resource list member
 * @rep:paraminfo {@rep:required}
 * @param x_resource_list_id The identifier of the resource list
 * @rep:paraminfo {@rep:required}
 * @param x_resource_id The identifier of the resource
 * @rep:paraminfo {@rep:required}
 * @param x_start_date The start date of the budget line
 * @rep:paraminfo {@rep:required}
 * @param x_end_date The end date of the budget line
 * @rep:paraminfo {@rep:required}
 * @param x_period_name The effective period of the budget line (if any)
 * @rep:paraminfo {@rep:required}
 * @param x_quantity The quantity of the budget line
 * @rep:paraminfo {@rep:required}
 * @param x_raw_cost The raw cost of the budget line
 * @rep:paraminfo {@rep:required}
 * @param x_burdened_cost The burden cost of the budget line
 * @rep:paraminfo {@rep:required}
 * @param x_pm_product_code The product code of the product where the budget line originated
 * @rep:paraminfo {@rep:required}
 * @param x_txn_currency_code The transaction currency code
 * @param x_error_code Error handling code
 * @rep:paraminfo {@rep:required}
 * @param x_error_message User-defined error message
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Calculate Burdened Cost
 * @rep:compatibility S
*/
  procedure Calc_Burdened_Cost( x_budget_version_id     in number,
                           x_project_id             in number,
                           x_task_id                in number,
                           x_resource_list_member_id  in number,
			   x_resource_list_id       in number,
                           x_resource_id            in number,
                           x_start_date             in date,
                           x_end_date               in date,
                           x_period_name            in varchar2,
			   x_quantity               in number,
			   x_raw_cost               in number,
			   x_burdened_cost	    in out NOCOPY number, --File.Sql.39 bug 4440895
			   x_pm_product_code        in varchar2,
                           x_txn_currency_code      IN VARCHAR2 DEFAULT NULL,
                           x_error_code             out NOCOPY number,     --File.Sql.39 bug 4440895
			   x_error_message          out NOCOPY varchar2); --File.Sql.39 bug 4440895

/*#
 * This procedure is used to calculate the revenue.
 * @param x_budget_version_id The identifier of the budget version
 * @rep:paraminfo {@rep:required}
 * @param x_project_id The identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param x_task_id The identifier of the task. This value is set to zero if budgeting is done at the project level.
 * @rep:paraminfo {@rep:required}
 * @param x_resource_list_member_id The identifier of the resource list member
 * @rep:paraminfo {@rep:required}
 * @param x_resource_list_id The identifier of the resource list
 * @rep:paraminfo {@rep:required}
 * @param x_resource_id The identifier of the resource
 * @rep:paraminfo {@rep:required}
 * @param x_start_date The start date of the budget line
 * @rep:paraminfo {@rep:required}
 * @param x_end_date The end date of the budget line
 * @rep:paraminfo {@rep:required}
 * @param x_period_name The effective period of the budget line (if any)
 * @rep:paraminfo {@rep:required}
 * @param x_quantity The quantity of the budget line
 * @rep:paraminfo {@rep:required}
 * @param x_raw_cost The raw cost of the budget line
 * @rep:paraminfo {@rep:required}
 * @param x_burdened_cost The burden cost of the budget line
 * @rep:paraminfo {@rep:required}
 * @param x_revenue The revenue of the budget line
 * @rep:paraminfo {@rep:required}
 * @param x_pm_product_code The product code of the product where the budget line originated
 * @rep:paraminfo {@rep:required}
 * @param x_txn_currency_code The transaction currency code
 * @param x_error_code Error handling code
 * @rep:paraminfo {@rep:required}
 * @param x_error_message User-defined error message
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Calculate Revenue
 * @rep:compatibility S
*/
  procedure Calc_Revenue( x_budget_version_id     in number,
                           x_project_id             in number,
                           x_task_id                in number,
                           x_resource_list_member_id  in number,
			   x_resource_list_id       in number,
                           x_resource_id            in number,
                           x_start_date             in date,
                           x_end_date               in date,
                           x_period_name            in varchar2,
			   x_quantity               in number,
			   x_revenue		    in out NOCOPY number, --File.Sql.39 bug 4440895
			   x_pm_product_code        in varchar2,
                           x_txn_currency_code      IN VARCHAR2 DEFAULT NULL,
                           x_error_code             out NOCOPY number,    --File.Sql.39 bug 4440895
			   x_error_message          out NOCOPY varchar2, --File.Sql.39 bug 4440895
			  /*added thses new parameters for enhancement request */
			   x_raw_cost		    IN NUMBER DEFAULT NULL,
			   x_burdened_cost          IN NUMBER DEFAULT NULL);

/*#
 * This procedure is used to build additional validations that Oracle Projects checks whenever a budget is submitted or baselined. The parameter
 * P_EVENT passes a value of either SUBMIT or BASELINE, to indicate the desired status of the budget being tested.
 * @param p_draft_version_id The identifier of the draft budget version
 * @rep:paraminfo {@rep:required}
 * @param p_mark_as_original Marks the original request
 * @rep:paraminfo {@rep:required}
 * @param p_event Indicates the requested status of the budget. Value is either SUBMIT or BASELINE.
 * @rep:paraminfo {@rep:required}
 * @param p_project_id The identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param p_budget_type_code The budge type code
 * @rep:paraminfo {@rep:required}
 * @param p_resource_list_id The identifier of the resource list for the budget
 * @rep:paraminfo {@rep:required}
 * @param p_project_type_class_code The project type class code of the budgets project
 * @rep:paraminfo {@rep:required}
 * @param p_created_by The identifier of the person who created the budget
 * @rep:paraminfo {@rep:required}
 * @param p_calling_module The module that called the extension
 * @rep:paraminfo {@rep:required}
 * @param p_fin_plan_type_id The identifier of the financial plan type
 * @param p_version_type The type of version
 * @param p_warnings_only_flag Flag indicating the level of errors the procedure generated. Y indicates that only warnings were generated. N indicates that errors were generated.
 * @rep:paraminfo {@rep:required}
 * @param p_err_msg_count The number of warnings and errors that the procedure generated
 * @rep:paraminfo {@rep:required}
 * @param p_error_code Error handling code
 * @rep:paraminfo {@rep:required}
 * @param p_error_message User-defined error message
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Verify Budget Rules
 * @rep:compatibility S
*/
  PROCEDURE Verify_Budget_Rules
                        (
                         p_draft_version_id		IN 	NUMBER
                         , p_mark_as_original  	        IN	VARCHAR2
                         , p_event			IN	VARCHAR2
                         , p_project_id        	        IN 	NUMBER
                         , p_budget_type_code  	        IN	VARCHAR2
                         , p_resource_list_id		IN	NUMBER
                         , p_project_type_class_code	IN 	VARCHAR2
                         , p_created_by 		IN	NUMBER
                         , p_calling_module		IN	VARCHAR2
                         , p_fin_plan_type_id           IN      NUMBER DEFAULT NULL
                         , p_version_type               IN      VARCHAR2 DEFAULT NULL
                         , p_warnings_only_flag	        OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                         , p_err_msg_count		OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
                         , p_error_code             	OUT	NOCOPY NUMBER --File.Sql.39 bug 4440895
                         , p_error_message          	OUT 	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                         );

  /* #2717299: Added the following procedure for the FinPlan WebADI Upload
     Functionality. */
/*#
 * You can use this procedure to modify the layout code for a budget version.
 * @param p_budget_version_id Budget version identifier for which the layout code needs to be determined
 * @rep:paraminfo {@rep:required}
 * @param p_layout_code_in Layout code that is determined by the calling procedure for the budget version
 * @rep:paraminfo {@rep:required}
 * @param x_layout_code_out The customized layout code that the user would like to view for the budget version
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Custom Layout Code
 * @rep:compatibility S
*/
  PROCEDURE Get_Custom_Layout_Code
                        (
                         p_budget_version_id		IN 	NUMBER
                         , p_layout_code_in  	        IN	VARCHAR2
                         , x_layout_code_out    	OUT	NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                         , x_return_status              OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                         , x_msg_count                  OUT     NOCOPY NUMBER --File.Sql.39 bug 4440895
                         , x_msg_data                   OUT     NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
                         );

/* Added for bug 3736220*/
/*#
 * This procedure is used to display error messages when you upload a project workplan from a spreadsheet. When you
 * perform this action, the system calls both the Budget Calculation Extension and the Budget Verification Extension.
 * You need to ensure that the lookup codes are defined for all the error messages that you would like to stamp on an uploaded budget.
 * @param p_resource_assignment_id Identifier of the resource assignment against which the error is displayed
 * @rep:paraminfo {@rep:required}
 * @param p_error_code The lookup code which corresponds to the error message
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (success/failure/unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_msg_count API standard: number of error messages
 * @rep:paraminfo {@rep:required}
 * @param x_msg_data API standard: error message
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Stamp Client Extension Errors
 * @rep:compatibility S
*/
PROCEDURE Stamp_Client_Extn_Errors
( p_resource_assignment_id IN NUMBER
  ,p_error_code     IN  VARCHAR2
  , x_return_status OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
  , x_msg_count     OUT NOCOPY NUMBER --File.Sql.39 bug 4440895
  , x_msg_data      OUT NOCOPY VARCHAR2 --File.Sql.39 bug 4440895
);

END pa_client_extn_budget;

 

/
