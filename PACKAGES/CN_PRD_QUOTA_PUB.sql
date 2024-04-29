--------------------------------------------------------
--  DDL for Package CN_PRD_QUOTA_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PRD_QUOTA_PUB" AUTHID CURRENT_USER AS
/*$Header: cnvpedbs.pls 120.1 2005/09/19 22:51:28 rarajara noship $*/
/*#
 * The procedure in this package can be used to distribute the target of the specified plan element
 * across the various periods. When the plan element is created, the target is not distributed by default.
 * While the UI can be used to distribute the target by navigating to the individual plan elements,
 * this package provides a convenient method to do the same by using SQL*PLUS.
 * @rep:scope public
 * @rep:product CN
 * @rep:displayname Period Quotas distribution
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CN_COMP_PLANS
 */

-- period quota
TYPE prd_quota_rec_type IS RECORD
  (
     PERIOD_NAME      CN_PERIOD_STATUSES.PERIOD_NAME%TYPE := FND_API.G_MISS_CHAR,
     PERIOD_TARGET    NUMBER := FND_API.G_MISS_NUM,
     PERIOD_PAYMENT    NUMBER := FND_API.G_MISS_NUM,
     PERFORMANCE_GOAL  NUMBER := FND_API.G_MISS_NUM
  );


TYPE prd_quota_tbl_type IS
   TABLE OF prd_quota_rec_type INDEX BY BINARY_INTEGER ;



-- Global variable that represent missing values.

G_MISS_PRD_QUOTA_REC  prd_quota_rec_type;
G_MISS_PRD_QUOTA_REC_TB  prd_quota_tbl_type;


/*#
 * This procedure distributes the target for a plan element across the periods for which the plan element has been defined.
 * @param p_api_version API version
 * @param p_init_msg_list Initialize message list (default F)
 * @param p_commit Commit flag (default F).
 * @param p_validation_level Validation level (default 100).
 * @param x_return_status Return Status
 * @param x_msg_count Number of messages returned
 * @param x_msg_data Contents of message if x_msg_count = 1
 * @param p_pe_name The plan element for which the target has to be distributed.
 * @param p_target_amount The target amount that has to be distributed across the periods.
 * @param p_fixed_amount The fixed amount that has to be distributed for the periods.
 * @param p_performance_goal The performance goal that has to be distributed for the periods.
 * @param p_even_distribute The configuration parameter used to choose between even distribution and user configurable distribution. Y = even, N = user configurable.
 * @param p_prd_quota_tbl The user configured distribution if p_even_distribute is set to N.
 * @rep:lifecycle active
 * @rep:displayname Delete Role Plan Assignment
 */


PROCEDURE Distribute_Prd_Quota
(       p_api_version              IN   NUMBER   := CN_API.G_MISS_NUM,
        p_init_msg_list            IN   VARCHAR2 := CN_API.G_FALSE,
        p_commit                   IN   VARCHAR2 := CN_API.G_FALSE,
        p_validation_level         IN   NUMBER   := CN_API.G_VALID_LEVEL_FULL,
        p_pe_name                  IN   CN_QUOTAS.NAME%TYPE,
        p_target_amount            IN   CN_QUOTAS.target%TYPE,
        p_fixed_amount             IN   CN_QUOTAS.payment_amount%TYPE,
        p_performance_goal         IN   CN_QUOTAS.performance_goal%TYPE,
        p_even_distribute          IN   VARCHAR2,
        p_prd_quota_tbl            IN   prd_quota_tbl_type,
				p_org_id									 IN  NUMBER,
        x_return_status            OUT NOCOPY VARCHAR2,
        x_msg_count                OUT NOCOPY NUMBER,
        x_msg_data                 OUT NOCOPY VARCHAR2

  );







END CN_PRD_QUOTA_PUB;

 

/
