--------------------------------------------------------
--  DDL for Package CN_ROLE_PLANS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_ROLE_PLANS_PUB" AUTHID CURRENT_USER AS
/* $Header: cnprlpls.pls 120.1 2005/07/08 04:42:00 appldev ship $ */
/*#
 * There are three APIs for CN_ROLE_PLANS_PUB.
 * Create Role Plans: This procedure creates a Role-Plan Assignment. Records are inserted into cn_role_plans.
 * There is a call to procedure cn_srp_plan_assign_pvt.create_srp_plan_assigns. This inserts records into
 * cn_srp_plan_Assigns for all salesreps with the role. This results in records being created in
 * cn_srp_quota_assigns, cn_srp_period_quotas, cn_Srp_periods, cn_srp_rollover_quotas(if exists),
 * cn_srp_quota_rules, and cn_srp_rate_assigns.
 *
 * Update Role Plans: This procedure updates Role-Plan Assignment. Records are updated in cn_role_plans.
 * There is a call to procedure .cn_srp_plan_assign_pvt.update_srp_plan_assigns. This results in update to
 * cn_srp_quota_assigns, cn_srp_rate_tiers, cn_srp_periods, cn_srp_rollover, quotas.
 *
 * Delete Role Plans: This procedure deletes the Role-Plan assignment from cn_role_plans. This results in records being deleted from cn_srp_plan_assigns, cn_srp_quota_Assigns, and cn_srp_rate_tiers.
 * @rep:scope public
 * @rep:product CN
 * @rep:displayname Role to Compensation Plan Assignment
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CN_COMP_PLANS
 */

--
-- User defined Record Type
--
-- Note: form bug 725654 for G_MISS

TYPE role_plan_rec_type IS RECORD
  (
   role_name            cn_roles.name%TYPE             := cn_api.G_MISS_CHAR,
   role_id              cn_role_plans.role_id%TYPE     := NULL,
   comp_plan_name       cn_comp_plans.name%TYPE        := cn_api.G_MISS_CHAR,
   comp_plan_id         cn_role_plans.comp_plan_id%TYPE := NULL,
   start_date           cn_role_plans.start_date%TYPE  := cn_api.G_MISS_DATE,
   end_date             cn_role_plans.end_date%TYPE    := cn_api.G_MISS_DATE,
   attribute_category   cn_role_plans.attribute_category%TYPE := cn_api.G_MISS_CHAR,
   attribute1           cn_role_plans.attribute1%TYPE  := cn_api.G_MISS_CHAR,
   attribute2           cn_role_plans.attribute2%TYPE  := cn_api.G_MISS_CHAR,
   attribute3           cn_role_plans.attribute3%TYPE  := cn_api.G_MISS_CHAR,
   attribute4           cn_role_plans.attribute4%TYPE  := cn_api.G_MISS_CHAR,
   attribute5           cn_role_plans.attribute5%TYPE  := cn_api.G_MISS_CHAR,
   attribute6           cn_role_plans.attribute6%TYPE  := cn_api.G_MISS_CHAR,
   attribute7           cn_role_plans.attribute7%TYPE  := cn_api.G_MISS_CHAR,
   attribute8           cn_role_plans.attribute8%TYPE  := cn_api.G_MISS_CHAR,
   attribute9           cn_role_plans.attribute9%TYPE  := cn_api.G_MISS_CHAR,
   attribute10          cn_role_plans.attribute10%TYPE := cn_api.G_MISS_CHAR,
   attribute11          cn_role_plans.attribute11%TYPE := cn_api.G_MISS_CHAR,
   attribute12          cn_role_plans.attribute12%TYPE := cn_api.G_MISS_CHAR,
   attribute13          cn_role_plans.attribute13%TYPE := cn_api.G_MISS_CHAR,
   attribute14          cn_role_plans.attribute14%TYPE := cn_api.G_MISS_CHAR,
   attribute15          cn_role_plans.attribute15%TYPE := cn_api.G_MISS_CHAR,
   object_version_number cn_role_plans.object_version_number%TYPE := NULL,
   org_id                cn_role_plans.org_id%TYPE := NULL

  );

--
-- User defined Record Table Type
--
TYPE role_plan_rec_tbl_type IS TABLE OF role_plan_rec_type
  INDEX BY BINARY_INTEGER;

--
-- Global variable that represent missing values.
--
G_MISS_ROLE_PLAN_REC  role_plan_rec_type;
G_MISS_ROLE_PLAN_TBL  role_plan_rec_tbl_type;
G_ROLE_NAME CONSTANT VARCHAR2(80)
  := cn_api.get_lkup_meaning('ROLE_NAME','ROLE_OBJECT_TYPE');
G_CP_NAME  CONSTANT VARCHAR2(80)
  := cn_api.get_lkup_meaning('CP_NAME','CP_OBJECT_TYPE');
G_START_DATE  CONSTANT VARCHAR2(80)
  := cn_api.get_lkup_meaning('START_DATE','CN_OBJECT_TYPE');

-- Start of Comments
-- API name 	: Create_Role_Plan
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Procedure to create a sales role and comp plan assignment.
-- Parameters	:
-- IN		:  p_api_version            IN NUMBER      Require
-- 		:  p_init_msg_list          IN VARCHAR2    Optional
-- 		   	                    Default = FND_API.G_FALSE
-- 		:  p_commit	            IN VARCHAR2    Optional
-- 		       	                    Default = FND_API.G_FALSE
-- 		:  p_validation_level       IN NUMBER      Optional
-- 		       	                    Default = FND_API.G_VALID_LEVEL_FULL
-- 		:  p_role_plan_rec          IN             ROLE_PLAN_REC_TYPE
-- OUT		:  x_return_status          OUT	           VARCHAR2(1)
-- 		:  x_msg_count	            OUT	           NUMBER
-- 		:  x_msg_data	            OUT	           VARCHAR2(2000)
--		:  x_loading_status	    OUT            VARCHAR2
--
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Description	: This procedure is used to create a sales role and comp plan assignment.
-- Notes	: 1. Role name can not be missing or null.
--                2. Comp plan name can not be missing or null.
--                3. Start_date can not be missing or null.
--                4. Start_date <= end_date, if end_date is not null.
--                5. Role name must exist in cn_roles already.
--                6. Comp_plan_name must exist in cn_comp_plans already.
--                7. Date range (start_date, en_date) of the assignment must be
--                   within the date range (start_date, end_date) of the comp plan.
--                8. No comp plan overlap for the any same sales role.
--                   In other words, you can not have more than one comp plan for
--                   the same role at the same time.
--                9. Gap between two comp plans for the same role is allowed.
-- End of comments

/*#
 * This procedure creates Role-Plan assignment. For all salesreps,with this Role-Plan assignment records are created in Salesrep-Plan Assigns, Salesrep-Quota Assigns, Salesrep-Periods Quotas, Salesrep-Rate Tiers, Salesrep-Rule Uplifts.
 * @param p_api_version API version
 * @param p_init_msg_list Initialize message list (default F)
 * @param p_commit Commit flag (default F).
 * @param p_validation_level Validation level (default 100).
 * @param x_return_status Return Status
 * @param x_msg_count Number of messages returned
 * @param x_msg_data Contents of message if x_msg_count = 1
 * @param x_loading_status Standard OUT parameters
 * @param p_role_plan_rec  Record of type role_plan_rec_type
 * @rep:lifecycle active
 * @rep:displayname Create Role Plan Assignment
 */

PROCEDURE Create_Role_Plan
  ( p_api_version   	   IN	NUMBER				      ,
   	p_init_msg_list		   IN	VARCHAR2 := FND_API.G_FALSE   	      ,
	p_commit	    	   IN  	VARCHAR2 := FND_API.G_FALSE   	      ,
	p_validation_level	   IN  	NUMBER	 := FND_API.g_valid_level_full,
	x_return_status		   OUT NOCOPY VARCHAR2		      	      ,
	x_loading_status       OUT NOCOPY  VARCHAR2                              ,
	x_msg_count		       OUT NOCOPY NUMBER			      	      ,
	x_msg_data		       OUT NOCOPY VARCHAR2                      	      ,
	p_role_plan_rec        IN   role_plan_rec_type := G_MISS_ROLE_PLAN_REC,
    x_role_plan_id         OUT NOCOPY NUMBER,
    x_obj_ver_num          OUT NOCOPY NUMBER
	);

-- Start of Comments
-- API name 	: Update_Role_Plan
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Procedure to update a sales role and comp plan assignment.
-- Parameters	:
-- IN		:  p_api_version            IN NUMBER      Require
-- 		:  p_init_msg_list          IN VARCHAR2    Optional
-- 		   	                    Default = FND_API.G_FALSE
-- 		:  p_commit	            IN VARCHAR2    Optional
-- 		       	                    Default = FND_API.G_FALSE
-- 		:  p_validation_level       IN NUMBER      Optional
-- 		       	                    Default = FND_API.G_VALID_LEVEL_FULL
--              :  p_role_plan_rec_old      IN             ROLE_PLAN_REC_TYPE
-- 		:  p_role_plan_rec_new      IN             ROLE_PLAN_REC_TYPE
-- OUT		:  x_return_status          OUT	           VARCHAR2(1)
-- 		:  x_msg_count	            OUT	           NUMBER
-- 		:  x_msg_data	            OUT	           VARCHAR2(2000)
--		:  x_loading_status	    OUT            VARCHAR2
--
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Description	: This procedure is used to update a sales role and comp plan assignment.
-- Notes	:  1. Old role_plan_id must be found in cn_role_plans.
--                 2. New role name can not be null.
--                 3. New comp plan name can not be null.
--                 4. New start date can not be null.
--                 5. New start date <= new end date if new end date is not null.
--                 6. New role_name must exist in cn_roles already.
--                 8. New comp plan name must exist in cn_comp_plans already.
--                 9. The new date range (start_date, end_date) of the assignment must be
--                    within the date range (start_date, end_date) of the comp plan.
--                10. No comp plan overlap for the any same sales role.
--                    In other words, you can not have more than one comp plan for
--                    the same role at the same time.
--                11. Gap between two comp plans for the same role is allowed.
-- End of comments

/*#
 * This procedure updates Role-Plan assignment. For all salesreps, with this Role-Plan assignment records are updated in Salesrep-Plan Assigns, Salesrep-Quota Assigns, Salesrep-Periods Quotas, Salesrep-Rate Tiers, Salesrep-Rule Uplifts.
 * @param p_api_version API version
 * @param p_init_msg_list Initialize message list (default F)
 * @param p_commit Commit flag (default F).
 * @param p_validation_level Validation level (default 100).
 * @param x_return_status Return Status
 * @param x_msg_count Number of messages returned
 * @param x_msg_data Contents of message if x_msg_count = 1
 * @param x_loading_status Standard OUT parameters
 * @param p_role_plan_rec_old Record of type role_plan_rec_type
 * @param p_role_plan_rec_new Record of type role_plan_rec_type
 * @param p_ovn Object Version Number
 * @rep:lifecycle active
 * @rep:displayname Update Role Plan Assignment
 */


PROCEDURE Update_Role_Plan
(  	p_api_version          IN	NUMBER				      ,
   	p_init_msg_list		   IN	VARCHAR2 := FND_API.G_FALSE   	      ,
	p_commit	    	   IN  	VARCHAR2 := FND_API.G_FALSE   	      ,
	p_validation_level	   IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		   OUT NOCOPY VARCHAR2		      	      ,
	x_loading_status       OUT NOCOPY  VARCHAR2 			      ,
	x_msg_count		       OUT NOCOPY NUMBER			      	      ,
	x_msg_data		       OUT NOCOPY VARCHAR2                      	      ,
	p_role_plan_rec_old    IN   role_plan_rec_type := G_MISS_ROLE_PLAN_REC,
    p_ovn                  IN OUT NOCOPY  cn_role_plans.object_version_number%TYPE,
	p_role_plan_rec_new    IN   role_plan_rec_type := G_MISS_ROLE_PLAN_REC,
	p_role_plan_id		   IN   cn_role_plans.role_plan_id%TYPE
	);



-- Start of Comments
-- API name 	: Delete_Role_Plan
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Procedure to delete a sales role and comp plan assignment.
-- Parameters	:
-- IN		:  p_api_version            IN NUMBER      Require
-- 		:  p_init_msg_list          IN VARCHAR2    Optional
-- 		   	                    Default = FND_API.G_FALSE
-- 		:  p_commit	            IN VARCHAR2    Optional
-- 		       	                    Default = FND_API.G_FALSE
-- 		:  p_validation_level       IN NUMBER      Optional
-- 		       	                    Default = FND_API.G_VALID_LEVEL_FULL
-- 		   p_role_plan_rec          IN             ROLE_PLAN_REC_TYPE
-- OUT		:  x_return_status          OUT	           VARCHAR2(1)
-- 		:  x_msg_count	            OUT	           NUMBER
-- 		:  x_msg_data	            OUT	           VARCHAR2(2000)
--		:  x_loading_status	    OUT            VARCHAR2
--
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Description	: This procedure is used to delete a sales role and comp plan assignment.
-- Notes	: 1. the old p_role_plan_id must be found based on the
--                   parameters passed in.
-- End of comments

/*#
 * This procedure deletes Role-Plan assignment. For all salesreps, with this Role-Plan assignment records are deleted in Salesrep-Plan Assigns, Salesrep-Quota Assigns, Salesrep-Periods Quotas, Salesrep-Rate Tiers, Salesrep-Rule Uplifts.
 * @param p_api_version API version
 * @param p_init_msg_list Initialize message list (default F)
 * @param p_commit Commit flag (default F).
 * @param p_validation_level Validation level (default 100).
 * @param x_return_status Return Status
 * @param x_msg_count Number of messages returned
 * @param x_msg_data Contents of message if x_msg_count = 1
 * @param x_loading_status Standard OUT parameters
 * @param p_role_plan_rec Record of type role_plan_rec_type
 * @rep:lifecycle active
 * @rep:displayname Delete Role Plan Assignment
 */


PROCEDURE Delete_Role_Plan
(  	p_api_version              IN	NUMBER				      ,
   	p_init_msg_list		   IN	VARCHAR2 := FND_API.G_FALSE   	      ,
	p_commit	    	   IN  	VARCHAR2 := FND_API.G_FALSE   	      ,
	p_validation_level	   IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		   OUT NOCOPY VARCHAR2		      	      ,
	x_loading_status           OUT NOCOPY  VARCHAR2            	              ,
	x_msg_count		   OUT NOCOPY NUMBER			      	      ,
	x_msg_data		   OUT NOCOPY VARCHAR2                      	      ,
	p_role_plan_rec            IN   role_plan_rec_type := G_MISS_ROLE_PLAN_REC
	);

END CN_ROLE_PLANS_PUB;

 

/
