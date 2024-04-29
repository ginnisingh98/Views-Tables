--------------------------------------------------------
--  DDL for Package CN_SRP_PMT_PLANS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_PMT_PLANS_PUB" AUTHID CURRENT_USER AS
/* $Header: cnpsppas.pls 120.2 2005/10/27 16:03:20 mblum noship $ */
/*#
 * This procedure is used to create, update, and delete payment plan assignments for salesreps individually or in mass.
 * @rep:scope public
 * @rep:product CN
 * @rep:displayname Assign Payment Plans
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY CN_COMP_PLANS
 */
--
-- Record type for Srp Payment Plan
--
TYPE srp_pmt_plans_rec_type IS RECORD
  (PMT_PLAN_NAME	   cn_pmt_plans.name%TYPE := CN_API.G_MISS_CHAR,
   SALESREP_TYPE      	   VARCHAR2(100)  := CN_API.G_MISS_CHAR,
   EMP_NUM                 VARCHAR2(30)   := CN_API.G_MISS_CHAR,
   START_DATE              cn_srp_pmt_plans.start_date%TYPE
                                       := CN_API.G_MISS_DATE,
   END_DATE                cn_srp_pmt_plans.end_date%TYPE
                                       := CN_API.G_MISS_DATE,
   MINIMUM_AMOUNT 	   cn_srp_pmt_plans.minimum_amount%TYPE
                                       := CN_API.G_MISS_NUM,
   MAXIMUM_AMOUNT 	   cn_srp_pmt_plans.maximum_amount%TYPE
                                       := CN_API.G_MISS_NUM,
   ORG_ID                  cn_srp_pmt_plans.org_id%TYPE := NULL,
   OBJECT_VERSION_NUMBER   cn_srp_pmt_plans.object_version_number%TYPE,
   SRP_ROLE_ID             cn_srp_pmt_plans.srp_role_id%TYPE,
   ROLE_PMT_PLAN_ID        cn_srp_pmt_plans.role_pmt_plan_id%TYPE,
   LOCK_FLAG               cn_srp_pmt_plans.lock_flag%TYPE);

g_miss_srp_pmt_plans_rec srp_pmt_plans_rec_type;

TYPE srp_pmt_plans_tbl_type IS TABLE OF srp_pmt_plans_rec_type
  INDEX BY BINARY_INTEGER;

g_miss_srp_pmt_plans_tbl srp_pmt_plans_tbl_type;

-- Start of comments
-- API name 	: Create_Srp_Pmt_Plan
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Used to create a new payment plan assignment to an salesrep
-- Desc 	: Procedure to create a new payment plan assignment to salesrep
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = CN_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = CN_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = CN_API.G_VALID_LEVEL_FULL
-- 		   p_srp_pmt_plans_rec   IN         srp_pmt_plans_rec_type
--                 Required input :
--                    PMT_PLAN_NAME           payment plan name
--                    SALESREP_TYPE,EMP_NUM   use to get salesrep info
--                    ROLE_NAME               which sales role to be assigned
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
--                 x_loading_status    OUT	      VARCHAR2(30)
-- Version	: Current version	1.0
--		  Initial version 	1.0
-- Notes        :
-- Default Action for this procedure :
--  1. If user didn't  pass in info for the following field, this program will
--     inherit the data from the Payment Plan.
--        MINIMUM_AMOUNT,MAXIMUM_AMOUNT
--  2. If user didn't pass in info for START_DATE,END_DATE, this program will
--     get the overlapped date range between the Payment Plan active range
--     and Salesrep's active range and use that date range
--
-- End of comments
/*#
 * This procedure is used to create a new payment plan assignment to a salesrep.
 * @param p_api_version API Version
 * @param p_init_msg_list Initialize Message List
 * @param p_commit Commit after create
 * @param p_validation_level Validation Level
 * @param x_return_status Status of the create operation
 * @param x_msg_count Number of error messages returned
 * @param x_msg_data Error messages
 * @param x_srp_pmt_plan_id Return the unique identifier of this assignment
 * @param x_loading_status Status
 * @param p_srp_pmt_plans_rec Record of type srp_pmt_plans_rec_type that stores the data associated with payment plan assignments
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create payment plan assignments
 */
PROCEDURE Create_Srp_Pmt_Plan
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := CN_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := CN_API.G_FALSE,
   p_validation_level   IN    NUMBER   := CN_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count	        OUT NOCOPY  NUMBER,
   x_msg_data	        OUT NOCOPY  VARCHAR2,
   p_srp_pmt_plans_rec  IN   srp_pmt_plans_rec_type,
   x_srp_pmt_plan_id    OUT NOCOPY  NUMBER,
   x_loading_status     OUT NOCOPY  VARCHAR2
);

-- Start of comments
-- API name 	: Create_Mass_Asgn_Srp_Pmt_Plan
-- currently just a wrapper around the private method
PROCEDURE Create_Mass_Asgn_Srp_Pmt_Plan
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count	        OUT NOCOPY  NUMBER,
   x_msg_data	        OUT NOCOPY  VARCHAR2,
   p_srp_role_id        IN    NUMBER,
   p_role_pmt_plan_id   IN    NUMBER,
   x_srp_pmt_plan_id    OUT NOCOPY  NUMBER,
   x_loading_status     OUT NOCOPY  VARCHAR2
   );

-- Start of comments
-- API name 	: Update_Srp_Pmt_Plan
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Used to update pmt plan assignment of an salesrep
-- Desc 	: Procedure to update pmt plan assignment of an salesrep
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = CN_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = CN_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = CN_API.G_VALID_LEVEL_FULL
-- 	           p_srp_pmt_plans_rec   IN         srp_pmt_plans_rec_type
--                 Required input :
--                    PMT_PLAN_NAME           payment plan name
--                    SALESREP_TYPE,EMP_NUM   use to get salesrep info
--                    ROLE_NAME               which sales role to be assigned
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
--                 x_loading_status    OUT	      VARCHAR2(30)
-- Version	: Current version	1.0
--		  Initial version 	1.0
-- Notes        :
-- Update Srp Payment Plan Assignment is not allowed for following cases :
-- 1. Change the START_DATE assignment :
--    If the payment plan already been used by a payment worksheet and the
--    payment has been paid during this assigment's date range, no update or
--    delete is allowed for this Srp Payment Plan assignment START_DATE.
--    Otherwise user can expand or shrink the START_DATE
-- 2. Shorten the END_DATE assignment
--    If the payment plan already been used by a payment worksheet and the
--    payment has been paid during this assigment's date range,the END_DATE of
--    this Srp Payment Plan assignment cannot be shorten but user can expand it
--
-- End of comments
/*#
 * This procedure is used to update the payment plan assignment of a salesrep.
 * @param p_api_version API Version
 * @param p_init_msg_list Initialize Message List
 * @param p_commit Commit after update
 * @param p_validation_level Validation Level
 * @param x_return_status Status of the update operation
 * @param x_msg_count Number of error messages returned
 * @param x_msg_data Error messages
 * @param x_loading_status Status
 * @param p_old_srp_pmt_plans_rec Record of type srp_pmt_plans_rec_type that stores the data associated with payment plan assignments
 * @param p_srp_pmt_plans_rec Record of type srp_pmt_plans_rec_type that stores the old data associated with payment plan assignments
 * @param p_check_lock locking customization flag
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Update payment plan assignments
 */

PROCEDURE Update_Srp_Pmt_Plan
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := CN_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := CN_API.G_FALSE,
   p_validation_level   IN    NUMBER   := CN_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count	        OUT NOCOPY  NUMBER,
   x_msg_data	        OUT NOCOPY  VARCHAR2,
   p_old_srp_pmt_plans_rec  IN  srp_pmt_plans_rec_type,
   p_srp_pmt_plans_rec      IN  srp_pmt_plans_rec_type,
   x_loading_status     OUT NOCOPY  VARCHAR2,
   p_check_lock         IN  VARCHAR2 := NULL
);

-- Start of comments
-- API name 	: Update_Mass_Asgn_Srp_Pmt_Plan
-- currently just a wrapper around the private method
PROCEDURE Update_Mass_Asgn_Srp_Pmt_plan
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count	        OUT NOCOPY  NUMBER,
   x_msg_data	        OUT NOCOPY  VARCHAR2,
   p_srp_role_id        IN    NUMBER,
   p_role_pmt_plan_id   IN    NUMBER,
   x_loading_status     OUT NOCOPY  VARCHAR2
   );


-- Start of comments
-- API name 	: Delete_Srp_Pmt_Plan
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Used to delete a payment plan assignment to an salesrep
-- Desc 	: Procedure to delete a payment plan assignment to salesrep
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = CN_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = CN_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = CN_API.G_VALID_LEVEL_FULL
--  	           p_srp_pmt_plans_rec   IN         srp_pmt_plans_rec_type
--                 Required input :
--                    PMT_PLAN_NAME           payment plan name
--                    SALESREP_TYPE,EMP_NUM   use to get salesrep info
--                    ROLE_NAME               which sales role to be assigned
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
--                 x_loading_status    OUT	      VARCHAR2(30)
-- Version	: Current version	1.0
--		  Initial version 	1.0
-- Notes        :
-- Delete Srp Payment Plan Assignment is not allowed for following cases :
--    If the payment plan already been used by a payment worksheet and the
--    payment has been paid during this assigment's date range, no update or
--    delete is allowed for this Srp Payment Plan assignment.
-- End of comments
/*#
 * This procedure is used to delete a payment plan assignment to a salesrep.
 * @param p_api_version API Version
 * @param p_init_msg_list Initialize Message List
 * @param p_commit Commit after delete
 * @param p_validation_level Validation Level
 * @param x_return_status Status of the delete operation
 * @param x_msg_count Number of error messages returned
 * @param x_msg_data Error messages
 * @param x_loading_status Status
 * @param p_srp_pmt_plans_rec Record of type srp_pmt_plans_rec_type that stores the data associated with payment plan assignments
 * @param p_check_lock locking customization flag
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Delete payment plan assignments
 */
PROCEDURE Delete_Srp_Pmt_Plan
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := CN_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := CN_API.G_FALSE,
   p_validation_level   IN    NUMBER   := CN_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count	        OUT NOCOPY  NUMBER,
   x_msg_data	        OUT NOCOPY  VARCHAR2,
   p_srp_pmt_plans_rec  IN   srp_pmt_plans_rec_type,
   x_loading_status     OUT NOCOPY  VARCHAR2,
   p_check_lock         IN  VARCHAR2 := NULL
);

-- Start of comments
-- API name 	: Delete_Mass_Asgn_Srp_Pmt_Plan
-- currently just a wrapper around the private method
PROCEDURE Delete_Mass_Asgn_Srp_Pmt_Plan
  (p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count	        OUT NOCOPY  NUMBER,
   x_msg_data	        OUT NOCOPY  VARCHAR2,
   p_srp_role_id        IN    NUMBER,
   p_role_pmt_plan_id   IN    NUMBER,
   x_loading_status     OUT NOCOPY  VARCHAR2
   );

END CN_SRP_PMT_PLANS_PUB ;


 

/
