--------------------------------------------------------
--  DDL for Package CN_COMMISSION_CALC_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COMMISSION_CALC_PUB" AUTHID CURRENT_USER AS
--$Header: cnpprcms.pls 120.2 2006/03/31 10:34:21 sbadami noship $
/*#
 * The calculate_Commission procedure in cn_commission_calc_pub is used for
 * calculating projected compensation for a salesperson, including the projection
 * identifier, calculation date, and sales credit amount. These details are inserted into a
 * global temporary table called cn_proj_compensation_gtt by the calling program.
 * The projection identifier passed by the user is mapped to the plan element using
 * the plan element classification rules defined for the period defined in the
 * cn_proj_compensation_gtt. Then, the corresponding formula is used for finding the
 * projected compensation of the passed projection identifier.
 * @rep:scope public
 * @rep:product CN
 * @rep:displayname Calculate Projected Compensation Public Application Program Interface
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CN_COMP_PLANS
 */

/*#
 * This procedure creates a record in cn_role_plans. This also calls Cn_Commission_
 * Calc_Pvt. calculate_Commission to create records in cn_Srp_plan_assigns.
 * @param p_api_version API Version
 * @param p_init_msg_list Initialize Message List
 * @param x_inc_plnr_disclaimer The income planner disclaimer message is returned
 * if the profile 'CN_CUST_DISCLAIMER' is set.
 * @param x_return_status Status of the create operation
 * @param x_msg_count Number of error messages returned
 * @param x_msg_data Error messages
 * @rep:displayname Calculate Commission For Salesrep
 */

 Procedure calculate_Commission
(
	p_api_version		IN NUMBER,
	p_init_msg_list		IN VARCHAR2 := FND_API.G_FALSE,
	x_inc_plnr_disclaimer   OUT NOCOPY  cn_repositories.income_planner_disclaimer%TYPE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2
);

 Procedure calculate_Commission
(
	p_api_version		IN NUMBER,
	p_init_msg_list		IN VARCHAR2 := FND_API.G_FALSE,
	p_org_id            IN NUMBER,
	x_inc_plnr_disclaimer   OUT NOCOPY  cn_repositories.income_planner_disclaimer%TYPE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER,
	x_msg_data		OUT NOCOPY VARCHAR2

);

END CN_COMMISSION_CALC_PUB;

 

/
