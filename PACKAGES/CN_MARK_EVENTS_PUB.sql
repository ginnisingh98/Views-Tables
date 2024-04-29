--------------------------------------------------------
--  DDL for Package CN_MARK_EVENTS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_MARK_EVENTS_PUB" AUTHID CURRENT_USER AS
/* $Header: cnpmkevs.pls 120.0 2006/08/25 00:19:00 ymao noship $ */
/*#
 * This package provides the APIs for creating notification log records for incremental calculation.
 * @rep:scope public
 * @rep:product CN
 * @rep:displayname Create Notification Log Records
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CN_COMP_PLANS
 */

-- Start of Comments
-- API name : Mark_Event_Calc
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Used to create notification log records to re-compute commissions incrementally for the specified
--            salesrep within the given parameters
-- Desc 	: Procedure to create notification log records for the specified salesrep in the given time period
--            and optionally for the given plan element
-- Parameters	:
-- IN	   p_api_version       IN  NUMBER      Required
-- 		   p_init_msg_list     IN  VARCHAR2    Optional 	Default = FND_API.G_FALSE
-- 		   p_commit	           IN  VARCHAR2    Optional 	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN  NUMBER      Optional 	Default = FND_API.G_VALID_LEVEL_FULL
-- OUT	   x_return_status     OUT VARCHAR2(1)
-- 		   x_msg_count	       OUT NUMBER
-- 		   x_msg_data	       OUT VARCHAR2(2000)
-- IN	   p_salesrep_id       IN  NUMBER
--         p_period_id         IN  NUMBER
--         p_start_date        IN  DATE        Optional     Default = NULL
--         p_end_date          IN  DATE        Optional     Default = NULL
--         p_quota_id          IN  NUMBER      Optional     Default = NULL
--         p_org_id            IN  NUMBER
-- Version	: Current version	1.0
--		      Initial version 	1.0
--
-- Notes	:
--   p_salesrep_id should be a valid salesrep identified in the operating unit specified by p_org_id.
--   p_period_id should specify the period for which calculation needs to be rerun
--   p_start_date should be within the period specified by p_period_id. It has a default value of null,
--     which is treated as the beginning of the specified period
--   p_end_date should be within the period specified by p_period_id. It has a default value of null,
--     which is treated as the end of the specified period
--   p_quota_id is the identifier of the plan element that needs to be recalculated. If it is null, all
--     plan elements of the specified salesrep will be calculated
--   p_org_id is the identifier of the operating unit
-- End of comments

/*#
 * This procedure creates a new notification log record with the given specifications.
 * @param p_api_version API version
 * @param p_init_msg_list Initialize message list (default F)
 * @param p_commit Commit flag (default F). If p_commit is not fnd_api.g_true, then the calculation will not be submitted even if all of the validations are successful.
 * @param p_validation_level Validation level (default Full)
 * @param x_return_status Return status
 * @param x_msg_count Number of messages returned
 * @param x_msg_data Contents of message if x_msg_count = 1
 * @param p_salesrep_id Identifier of the salesrep for which notification log records will be created
 * @param p_period_id Period for which calculation needs to be rerun.
 * @param p_start_date Start date of the period for which calculation needs to be rerun. It should be within the specified period (default start of the period)
 * @param p_end_date End date of the period for which calculation needs to be rerun. It should be within the specified period (default end of the period)
 * @param p_quota_id Identifier of the plan element that needs to be recalculated. If it is null, all plan elements will be recalculated for the given period (default null)
 * @param p_org_id Identifier of the operating unit
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Notification Log Records for Recalc
 */

PROCEDURE Mark_Event_Calc
  (p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	            IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT   NOCOPY VARCHAR2,
   x_msg_count	        OUT   NOCOPY NUMBER,
   x_msg_data	        OUT   NOCOPY VARCHAR2,
   p_salesrep_id 	    IN    NUMBER,
   p_period_id	        IN    NUMBER,
   p_start_date	        IN    DATE     := NULL,
   p_end_date	        IN    DATE     := NULL,
   p_quota_id	        IN    NUMBER   := NULL,
   p_org_id             IN    NUMBER);

END cn_mark_events_pub;

 

/
