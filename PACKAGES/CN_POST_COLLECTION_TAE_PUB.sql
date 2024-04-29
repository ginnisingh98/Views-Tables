--------------------------------------------------------
--  DDL for Package CN_POST_COLLECTION_TAE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_POST_COLLECTION_TAE_PUB" AUTHID CURRENT_USER AS
--$Header: cnppcols.pls 120.1 2005/11/25 03:09:39 rramakri noship $
/*#
 * This public package integrates the Oracle Incentive Compensation collection
 * process with the Territory Assignment Engine.
 * @rep:scope public
 * @rep:product CN
 * @rep:displayname OIC Integration With TA Engine Public Application Program Interface
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CN_COMP_PLANS
 */

-- Start of Comments
-- API name 	: get_assignments
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Used to add your code to populate the attribute data into the
-- 		  TAE input interface table, make the TAE calls to process the
--		  territory assignment and update the original OIC transactions
--		  with the new territory resource information.
-- Parameters	:
-- IN		:  p_api_version        IN NUMBER      Require
-- 		   p_init_msg_list      IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	        IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level   IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
--                 x_start_period_id    IN cn_periods.period_id%TYPE
--     		   x_end_period_id      IN cn_periods.period_id%TYPE,
--     		   x_conc_program_id	IN NUMBER
-- OUT		:  x_return_status      OUT	      VARCHAR2(1)
-- 		   x_msg_count	        OUT	      NUMBER
-- 		   x_msg_data	        OUT	      VARCHAR2(2000)
-- Version	: Current version	1.0
--		  Initial version 	1.0

/*#
 * This procedure allows you to add your code to populate the attribute data into the
 * TAE input interface table, make the TAE calls to process the territory assignment
 * and update the original OIC transactions with the new territory resource
 * information.
 * @param p_api_version API Version
 * @param p_init_msg_list Initialize Message List
 * @param p_commit Commit after create
 * @param p_validation_level Validation Level
 * @param x_start_period_id period_id from cn_periods
 * @param x_end_period_id period_id from cn_periods
 * @param x_conc_program_id Concurrent Program Number
 * @param x_return_status Status of the create operation
 * @param x_msg_count Number of error messages returned
 * @param x_msg_data Error messages
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Assignements Information For OIC TAE Integration
 */

PROCEDURE get_assignments
  ( p_api_version        IN NUMBER,
    p_init_msg_list      IN VARCHAR2 := FND_API.G_FALSE,
    p_commit             IN VARCHAR2 := FND_API.G_FALSE,
    p_validation_level   IN NUMBER := FND_API.G_VALID_LEVEL_FULL,
    x_start_period_id    IN cn_periods.period_id%TYPE,
    x_end_period_id      IN cn_periods.period_id%TYPE,
    x_conc_program_id    IN NUMBER,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2,
    x_org_id             IN NUMBER
    );

END cn_post_collection_tae_pub;
 

/
