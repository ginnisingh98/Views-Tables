--------------------------------------------------------
--  DDL for Package GMS_CLIENT_EXTN_BUDGET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMS_CLIENT_EXTN_BUDGET" AUTHID CURRENT_USER AS
/* $Header: gmsbcecs.pls 120.4 2006/08/16 11:09:28 lveerubh ship $ */
/*#
 * This client extension allows you to override certain budget validations.
 * @rep:scope public
 * @rep:product GMS
 * @rep:lifecycle active
 * @rep:displayname Budget Client Extension
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY GMS_AWARD
 * @rep:doccd 120gmsug.pdf See the Oracle Oracle Grants Accounting User's Guide
*/
  procedure Calc_Raw_Cost( x_budget_version_id      in number,
			   x_project_id             in number,
			   x_task_id                in number,
			   x_resource_list_member_id  in number,
			   x_resource_list_id       in number,
			   x_resource_id            in number,
                           x_start_date             in date,
                           x_end_date               in date,
                           x_period_name            in varchar2,
			   x_quantity               in number,
			   x_raw_cost		    in out NOCOPY number,
			   x_pm_product_code        in varchar2,
                           x_error_code             out NOCOPY number,
			   x_error_message          out NOCOPY varchar2);

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
			   x_burdened_cost	    in out NOCOPY number,
			   x_pm_product_code        in varchar2,
                           x_error_code             out NOCOPY number,
			   x_error_message          out NOCOPY varchar2);


PROCEDURE Verify_Budget_Rules
 (p_draft_version_id		IN 	NUMBER
  , p_mark_as_original  	IN	VARCHAR2
  , p_event			IN	VARCHAR2
  , p_project_id        	IN 	NUMBER
  , p_budget_type_code  	IN	VARCHAR2
  , p_resource_list_id		IN	NUMBER
  , p_project_type_class_code	IN 	VARCHAR2
  , p_created_by 		IN	NUMBER
  , p_calling_module		IN	VARCHAR2
  , p_warnings_only_flag	OUT NOCOPY	VARCHAR2
  , p_err_msg_count		OUT NOCOPY	NUMBER
  , p_error_code             	OUT NOCOPY	NUMBER
  , p_error_message          	OUT NOCOPY 	VARCHAR2
);

-- For Bug:2395386
/*#
 *This procedures allows you to override following budget validations :
 * a) Does not allow budgeting outside of installment dates.
 * b) Budget line amount against available funds in the order of budget period. This default
 * functionality can be overriden to check the funds availability in the ascending order of budget
 * line amounts so that negative amounts are compared first.
 * @param p_award_id    Identifier of the award_id whose budget-installment validation to override
 * @rep:paraminfo {@rep:required}
 * @param p_project_id  Identifier of the project_id whose budget-installment validation to override
 * @rep:paraminfo {@rep:required}
 * @param p_override_validation  RETURN Y to override validation or N not to override validation
 * @rep:paraminfo {@rep:required}
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Override Installment Date Validation
 * @rep:compatibility S
*/
PROCEDURE override_inst_date_validation
 ( p_award_id 			IN	NUMBER,
   p_project_id			IN	NUMBER,
   p_override_validation	OUT NOCOPY	VARCHAR2 );

pragma restrict_references(override_inst_date_validation, wnds, wnps);

END gms_client_extn_budget;

 

/
