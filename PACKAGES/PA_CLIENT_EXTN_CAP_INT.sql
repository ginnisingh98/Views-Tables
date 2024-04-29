--------------------------------------------------------
--  DDL for Package PA_CLIENT_EXTN_CAP_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PA_CLIENT_EXTN_CAP_INT" AUTHID CURRENT_USER AS
-- $Header: PACINTXS.pls 120.2 2006/07/25 20:42:31 skannoji noship $
/*#
 * This extension enables you to customize the capitalized interest calculation process.
 * @rep:scope public
 * @rep:product PA
 * @rep:lifecycle active
 * @rep:displayname Capitalized Interest Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY PA_PROJECT
 * @rep:category BUSINESS_ENTITY PA_CAPITAL_ASSET
 * @rep:doccd 120pjapi.pdf See the Oracle Projects API's, Client Extensions, and Open Interfaces Reference
*/

/*#
 * This procedure enables you to define duration and amount thresholds at levels lower than those defined for the operating unit.
 * @param p_project_id Identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param p_task_id Identifier of the task
 * @rep:paraminfo {@rep:required}
 * @param p_rate_name Rate name
 * @rep:paraminfo {@rep:required}
 * @param p_start_date Start date of the GL period
 * @rep:paraminfo {@rep:required}
 * @param p_end_date End date of the GL period
 * @rep:paraminfo {@rep:required}
 * @param p_threshold_amt_type Threshold amount type
 * @rep:paraminfo {@rep:required}
 * @param p_budget_type Budget type
 * @rep:paraminfo {@rep:required}
 * @param p_fin_plan_type_id Identifier of the financial plan type
 * @rep:paraminfo {@rep:required}
 * @param p_interest_calc_method Interest calculation method
 * @rep:paraminfo {@rep:required}
 * @param p_cip_cost_type CIP cost type
 * @rep:paraminfo {@rep:required}
 * @param x_duration_threshold Duration threshold
 * @rep:paraminfo {@rep:required}
 * @param x_amt_threshold Amount threshold
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (S = success, F = failure, U = unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_error_msg_count The error message count
 * @rep:paraminfo {@rep:required}
 * @param x_error_msg_code The error message code
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Check Thresholds
 * @rep:compatibility S
*/
	PROCEDURE check_thresholds
		(p_project_id IN NUMBER
		,p_task_id IN NUMBER
		,p_rate_name IN VARCHAR2
		,p_start_date IN DATE
		,p_end_date IN DATE
		,p_threshold_amt_type IN VARCHAR2
		,p_budget_type IN VARCHAR2
		,p_fin_plan_type_id IN NUMBER
		,p_interest_calc_method IN VARCHAR2
		,p_cip_cost_type IN VARCHAR2
		,x_duration_threshold IN OUT NOCOPY NUMBER
		,x_amt_threshold IN OUT NOCOPY NUMBER
		,x_return_status OUT NOCOPY VARCHAR2
		,x_error_msg_count OUT NOCOPY NUMBER
		,x_error_msg_code OUT NOCOPY VARCHAR2);

/*#
 * This function enables you to specify organizations other than source project owning organization or source task owning
 * organization as the expenditure organization for generated transactions.
 * @return Returns the expenditure organization
 * @param p_expenditure_item_id Identifier of the expenditure item
 * @rep:paraminfo {@rep:required}
 * @param p_line_num  CDL line number
 * @rep:paraminfo {@rep:required}
 * @param p_rate_name Rate name
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Expenditure Organization
 * @rep:compatibility S
*/
	FUNCTION expenditure_org
		(p_expenditure_item_id IN NUMBER
		,p_line_num IN NUMBER
		,p_rate_name IN VARCHAR2) RETURN NUMBER;

/*#
 * This function enables you to define multiple interest rate multipliers based on rate name and task owning organization.
 * @return Returns the interest rate multiplier
 * @param p_expenditure_item_id Identifier of the expenditure item
 * @rep:paraminfo {@rep:required}
 * @param p_line_num  CDL line number
 * @rep:paraminfo {@rep:required}
 * @param p_rate_name Rate name
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Rate Multiplier
 * @rep:compatibility S
*/
	FUNCTION rate_multiplier
		(p_expenditure_item_id IN NUMBER
		,p_line_num IN NUMBER
		,p_rate_name IN VARCHAR2) RETURN NUMBER;

/*#
 * This procedure enables you to redirect capitalized interest transactions to specific tasks.
 * @param p_source_task_id Identifier of the task
 * @rep:paraminfo {@rep:required}
 * @param p_source_task_num  Task number
 * @rep:paraminfo {@rep:required}
 * @param p_rate_name Rate name
 * @rep:paraminfo {@rep:required}
 * @param x_target_task_id Identifier of the target task
 * @rep:paraminfo {@rep:required}
 * @param x_target_task_num Target task number
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (S = success, F = failure, U = unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_error_msg_count The error message count
 * @rep:paraminfo {@rep:required}
 * @param x_error_msg_code The error message code
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Target Task
 * @rep:compatibility S
*/
	PROCEDURE get_target_task
		(p_source_task_id IN NUMBER
		,p_source_task_num IN VARCHAR2
		,p_rate_name IN VARCHAR2
		,x_target_task_id OUT NOCOPY NUMBER
		,x_target_task_num OUT NOCOPY VARCHAR2
		,x_return_status OUT NOCOPY VARCHAR2
		,x_error_msg_count OUT NOCOPY NUMBER
		,x_error_msg_code OUT NOCOPY VARCHAR2);

/*#
 * This procedure enables you to control how the transaction attribute columns are populated.
 * @param p_project_id Identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param p_source_task_id Identifier of the task
 * @rep:paraminfo {@rep:required}
 * @param p_target_task_id Identifier of the target task
 * @rep:paraminfo {@rep:required}
 * @param p_rate_name Rate name
 * @rep:paraminfo {@rep:required}
 * @param p_grouping_method Grouping method
 * @rep:paraminfo {@rep:required}
 * @param x_attribute_category Descriptive flexfield category
 * @rep:paraminfo {@rep:required}
 * @param x_attribute1 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param x_attribute2 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param x_attribute3 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param x_attribute4 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param x_attribute5 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param x_attribute6 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param x_attribute7 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param x_attribute8 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param x_attribute9 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param x_attribute10 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param x_return_status API standard: return status of the API (S = success, F = failure, U = unexpected error)
 * @rep:paraminfo {@rep:required}
 * @param x_error_msg_count The error message count
 * @rep:paraminfo {@rep:required}
 * @param x_error_msg_code The error message code
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Transcation Attributes
 * @rep:compatibility S
*/
	PROCEDURE get_txn_attributes
		(p_project_id IN NUMBER
		,p_source_task_id IN NUMBER
		,p_target_task_id IN NUMBER
		,p_rate_name IN VARCHAR2
		,p_grouping_method IN VARCHAR2
		,x_attribute_category OUT NOCOPY VARCHAR2
		,x_attribute1 OUT NOCOPY VARCHAR2
		,x_attribute2 OUT NOCOPY VARCHAR2
		,x_attribute3 OUT NOCOPY VARCHAR2
		,x_attribute4 OUT NOCOPY VARCHAR2
		,x_attribute5 OUT NOCOPY VARCHAR2
		,x_attribute6 OUT NOCOPY VARCHAR2
		,x_attribute7 OUT NOCOPY VARCHAR2
		,x_attribute8 OUT NOCOPY VARCHAR2
		,x_attribute9 OUT NOCOPY VARCHAR2
		,x_attribute10 OUT NOCOPY VARCHAR2
		,x_return_status OUT NOCOPY VARCHAR2
		,x_error_msg_count OUT NOCOPY NUMBER
		,x_error_msg_code OUT NOCOPY VARCHAR2);

/*#
 * This procedure enables you to define  calculations for capitalized interest.
 * @param p_gl_period GL period
 * @rep:paraminfo {@rep:required}
 * @param p_rate_name Rate name
 * @rep:paraminfo {@rep:required}
 * @param p_curr_period_mult Current period multiplier
 * @rep:paraminfo {@rep:required}
 * @param p_period_mult Period multiplier
 * @rep:paraminfo {@rep:required}
 * @param p_project_id Identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param p_source_task_id Identifier of the task
 * @rep:paraminfo {@rep:required}
 * @param p_target_task_id Identifier of the target task
 * @rep:paraminfo {@rep:required}
 * @param p_exp_org_id Identifier of the expenditure
 * @rep:paraminfo {@rep:required}
 * @param p_exp_item_date Expenditure item date
 * @rep:paraminfo {@rep:required}
 * @param p_prior_period_amt Prior basis amount for capitalized interest calculation
 * @rep:paraminfo {@rep:required}
 * @param p_curr_period_amt Current basis amount for capitalized interest calculation
 * @rep:paraminfo {@rep:required}
 * @param p_grouping_method Grouping method
 * @rep:paraminfo {@rep:required}
 * @param p_rate_mult Rate multiplier
 * @rep:paraminfo {@rep:required}
 * @param x_cap_int_amt Capitalized interest amount
 * @rep:paraminfo {@rep:required}
 * @param x_return_status Error status (0 = successful execution, <0 = Oracle error, >0 = application error)
 * @rep:paraminfo {@rep:required}
 * @param x_error_msg_count The error message count
 * @rep:paraminfo {@rep:required}
 * @param x_error_msg_code The error message code
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Calculate Capitalized Interest
 * @rep:compatibility S
*/
	PROCEDURE calculate_cap_interest
		(p_gl_period IN VARCHAR2
		,p_rate_name IN VARCHAR2
		,p_curr_period_mult IN NUMBER
		,p_period_mult IN NUMBER
		,p_project_id IN NUMBER
		,p_source_task_id IN NUMBER
		,p_target_task_id IN NUMBER
		,p_exp_org_id IN NUMBER
		,p_exp_item_date IN DATE
		,p_prior_period_amt IN NUMBER
		,p_curr_period_amt IN NUMBER
		,p_grouping_method IN VARCHAR2
		,p_rate_mult IN NUMBER
		,x_cap_int_amt IN OUT NOCOPY NUMBER
		,x_return_status OUT NOCOPY VARCHAR2
		,x_error_msg_count OUT NOCOPY NUMBER
		,x_error_msg_code OUT NOCOPY VARCHAR2);

/*#
 * This function enables you to control how the transaction attribute columns are populated.
 * @return Returns transaction attribute grouping method
 * @param p_gl_period GL period
 * @rep:paraminfo {@rep:required}
 * @param p_project_id Identifier of the project
 * @rep:paraminfo {@rep:required}
 * @param p_source_task_id Identifier of the task
 * @rep:paraminfo {@rep:required}
 * @param p_expenditure_item_id Identifier of the expenditure item
 * @rep:paraminfo {@rep:required}
 * @param p_line_num Line number
 * @rep:paraminfo {@rep:required}
 * @param p_expenditure_id Identifier of the expenditure
 * @rep:paraminfo {@rep:required}
 * @param p_expenditure_type Expenditure type
 * @rep:paraminfo {@rep:required}
 * @param p_expenditure_category Expenditure category
 * @rep:paraminfo {@rep:required}
 * @param p_attribute1 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute2 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute3 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute4 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute5 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute6 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute7 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute8 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute9 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute10 Descriptive flexfield segment
 * @rep:paraminfo {@rep:required}
 * @param p_attribute_category Descriptive flexfield category
 * @rep:paraminfo {@rep:required}
 * @param p_transaction_source Transcation source
 * @rep:paraminfo {@rep:required}
 * @param p_rate_name Rate name
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Grouping Method
 * @rep:compatibility S
*/
      FUNCTION grouping_method
                (p_gl_period IN VARCHAR2
                ,p_project_id IN NUMBER
                ,p_source_task_id IN NUMBER
                ,p_expenditure_item_id IN NUMBER
                ,p_line_num IN NUMBER
		,p_expenditure_id IN NUMBER
		,p_expenditure_type IN VARCHAR2
		,p_expenditure_category IN VARCHAR2
		,p_attribute1 IN VARCHAR2
		,p_attribute2 IN VARCHAR2
		,p_attribute3 IN VARCHAR2
		,p_attribute4 IN VARCHAR2
		,p_attribute5 IN VARCHAR2
		,p_attribute6 IN VARCHAR2
		,p_attribute7 IN VARCHAR2
		,p_attribute8 IN VARCHAR2
		,p_attribute9 IN VARCHAR2
		,p_attribute10 IN VARCHAR2
		,p_attribute_category IN VARCHAR2
		,p_transaction_source IN VARCHAR2
		,p_rate_name IN VARCHAR2) RETURN VARCHAR2;

END PA_CLIENT_EXTN_CAP_INT ;

 

/
