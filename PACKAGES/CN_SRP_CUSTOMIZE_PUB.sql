--------------------------------------------------------
--  DDL for Package CN_SRP_CUSTOMIZE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_CUSTOMIZE_PUB" AUTHID CURRENT_USER as
-- $Header: cnpsrpcs.pls 120.0 2005/06/06 17:51:45 appldev noship $ -+
/*#
 * This procedure allows user to customize the target, goal, payment amount
 *  and uplift factors of a salesperson.
 * @rep:scope public
 * @rep:product CN
 * @rep:displayname Salesperson Customization
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CN_COMP_PLANS
 */


 /*#
 * This procedure updates the target, fixed amount and performance goal
 *  for which the plan element has been defined for a given salesperson.
 * @param p_api_version API Version
 * @param p_init_msg_list Initialize Message List
 * @param p_commit Commit after update
 * @param p_validation_level Validation Level
 * @param x_return_status Status of the update operation
 * @param x_msg_count Number of error messages returned
 * @param x_msg_data Error messages
 * @param p_srp_quota_assign_id Unique identifier for salesperson plan element assignment
 * @param p_customized_flag Customized Flag
 * @param p_quota Target of the plan element assigned to a given salesperson
 * @param p_fixed_amount Payment amount of the plan element assigned to a given salesperson
 * @param p_goal Performance Goal of the plan element assigned to a given salesperson
 * @param x_loading_status Status
 * @param x_status Status
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update SRP Quota Assigns
 */
PROCEDURE Update_srp_quota_assign(
        p_api_version           	IN	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2,
	p_commit	    		IN  	VARCHAR2,
	p_validation_level		IN  	NUMBER,
        p_srp_quota_assign_id           IN      NUMBER,
        p_customized_flag               IN      VARCHAR2,
        p_quota                         IN      NUMBER,
        p_fixed_amount                  IN      NUMBER,
        p_goal                          IN      NUMBER,
	x_return_status		        OUT NOCOPY VARCHAR2,
	x_msg_count		 OUT NOCOPY NUMBER,
	x_msg_data		 OUT NOCOPY VARCHAR2,
        x_loading_status	 OUT NOCOPY     VARCHAR2,
	x_status                        OUT NOCOPY     VARCHAR2);

 /*#
 * This procedure updates the customize flag for which the plan element has
 *   been defined for a given salesperson.
 * @param p_api_version API Version
 * @param p_init_msg_list Initialize Message List
 * @param p_commit Commit after create
 * @param p_validation_level Validation Level
 * @param x_return_status Status of the create operation
 * @param x_msg_count Number of error messages returned
 * @param x_msg_data Error messages
 * @param p_srp_quota_assign_id Unique identifier for salesperson plan element assignment
 * @param p_customized_flag Customized Flag
 * @param x_loading_status Status
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Change SRP Quota Custom Flag
 */
PROCEDURE Change_srp_quota_custom_flag(
        p_api_version           	IN	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2,
	p_commit	    		IN  	VARCHAR2,
	p_validation_level		IN  	NUMBER,
        p_srp_quota_assign_id           IN      NUMBER,
        p_customized_flag               IN      VARCHAR2,
	x_return_status		        OUT NOCOPY VARCHAR2,
	x_msg_count		 OUT NOCOPY NUMBER,
	x_msg_data		 OUT NOCOPY VARCHAR2,
        x_loading_status	 OUT NOCOPY     VARCHAR2
        ) ;

 /*#
 * This procedure updates the target, payment amount and performance goal
 *  for which the revenue class has been defined for a given salesperson.
 * @param p_api_version API Version
 * @param p_init_msg_list Initialize Message List
 * @param p_commit Commit after update
 * @param p_validation_level Validation Level
 * @param x_return_status Status of the update operation
 * @param x_msg_count Number of error messages returned
 * @param x_msg_data Error messages
 * @param p_quota_rule_id Unique identifier of the revenue class assigned to a plan element
 * @param p_srp_quota_rule_id Unique identifier of the revenue class assigned to a given salesperson
 * @param p_target Target of the revenue class assigned to a given salesperson
 * @param p_payment_amount Payment amount of the revenue class assigned to a given salesperson
 * @param p_performance_goal Performance goal of the revenue class assigned to a given salesperson
 * @param x_loading_status Status
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update SRP Quota Rules
 */

PROCEDURE Update_Srp_Quota_Rules(
        p_api_version           	IN	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2,
	p_commit	    		IN  	VARCHAR2,
	p_validation_level		IN  	NUMBER,
        p_quota_rule_id                 IN      NUMBER,
        p_srp_quota_rule_id             IN      NUMBER,
        p_target                        IN      NUMBER,
        p_payment_amount                IN      NUMBER,
        p_performance_goal              IN      NUMBER,
	x_return_status		        OUT NOCOPY VARCHAR2,
	x_msg_count		 OUT NOCOPY NUMBER,
	x_msg_data		 OUT NOCOPY VARCHAR2,
        x_loading_status	 OUT NOCOPY     VARCHAR2
        );

/*#
 * This procedure updates the payment and quota factor for which the plan
 *  element has been defined for a given salesperson.
 * @param p_api_version API Version
 * @param p_init_msg_list Initialize Message List
 * @param p_commit Commit after update
 * @param p_validation_level Validation Level
 * @param x_return_status Status of the update operation
 * @param x_msg_count Number of error messages returned
 * @param x_msg_data Error messages
 * @param p_srp_rule_uplift_id Unique identifier of the factor assigned to a revenue class
 * @param p_payment_factor Payment Factor
 * @param p_quota_factor Quota Factor
 * @param x_loading_status Status
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update SRP Rule Uplifts
 */
PROCEDURE Update_Srp_Rule_Uplifts(
        p_api_version           	IN	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2,
	p_commit	    		IN  	VARCHAR2,
	p_validation_level		IN  	NUMBER,

    p_srp_rule_uplift_id             IN      NUMBER,
    p_payment_factor                 IN      NUMBER,
    p_quota_factor                   IN      NUMBER,

	x_return_status		        OUT NOCOPY VARCHAR2,
	x_msg_count		 OUT NOCOPY NUMBER,
	x_msg_data		 OUT NOCOPY VARCHAR2,
        x_loading_status	 OUT NOCOPY     VARCHAR2
        );


END CN_Srp_Customize_PUB ;

 

/
