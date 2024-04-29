--------------------------------------------------------
--  DDL for Package CN_ROLE_PMT_PLANS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_ROLE_PMT_PLANS_PVT" AUTHID CURRENT_USER AS
/* $Header: cnprptps.pls 120.7 2006/08/23 10:29:30 sjustina noship $ */

--
-- User defined Record Type
--

TYPE role_pmt_plan_rec_type IS RECORD
  (
   org_id             cn_role_pmt_plans.org_id%TYPE,
   role_pmt_plan_id     cn_role_pmt_plans.role_pmt_plan_id%TYPE,
   role_name            cn_roles.name%TYPE             := cn_api.G_MISS_CHAR,
   pmt_plan_name        cn_pmt_plans.name%TYPE         := cn_api.G_MISS_CHAR,
   pmt_plan_id          cn_pmt_plans.pmt_plan_id%TYPE,
   start_date           cn_role_pmt_plans.start_date%TYPE  := cn_api.G_MISS_DATE,
   end_date             cn_role_pmt_plans.end_date%TYPE    := cn_api.G_MISS_DATE,
   object_version_number NUMBER := null,
   attribute_category   cn_role_pmt_plans.attribute_category%TYPE := cn_api.G_MISS_CHAR,
   attribute1           cn_role_pmt_plans.attribute1%TYPE  := cn_api.G_MISS_CHAR,
   attribute2           cn_role_pmt_plans.attribute2%TYPE  := cn_api.G_MISS_CHAR,
   attribute3           cn_role_pmt_plans.attribute3%TYPE  := cn_api.G_MISS_CHAR,
   attribute4           cn_role_pmt_plans.attribute4%TYPE  := cn_api.G_MISS_CHAR,
   attribute5           cn_role_pmt_plans.attribute5%TYPE  := cn_api.G_MISS_CHAR,
   attribute6           cn_role_pmt_plans.attribute6%TYPE  := cn_api.G_MISS_CHAR,
   attribute7           cn_role_pmt_plans.attribute7%TYPE  := cn_api.G_MISS_CHAR,
   attribute8           cn_role_pmt_plans.attribute8%TYPE  := cn_api.G_MISS_CHAR,
   attribute9           cn_role_pmt_plans.attribute9%TYPE  := cn_api.G_MISS_CHAR,
   attribute10          cn_role_pmt_plans.attribute10%TYPE := cn_api.G_MISS_CHAR,
   attribute11          cn_role_pmt_plans.attribute11%TYPE := cn_api.G_MISS_CHAR,
   attribute12          cn_role_pmt_plans.attribute12%TYPE := cn_api.G_MISS_CHAR,
   attribute13          cn_role_pmt_plans.attribute13%TYPE := cn_api.G_MISS_CHAR,
   attribute14          cn_role_pmt_plans.attribute14%TYPE := cn_api.G_MISS_CHAR,
   attribute15          cn_role_pmt_plans.attribute15%TYPE := cn_api.G_MISS_CHAR
  );

--
-- User defined Record Table Type
--
TYPE role_pmt_plan_rec_tbl_type IS TABLE OF role_pmt_plan_rec_type
  INDEX BY BINARY_INTEGER;

--
-- Global variable that represent missing values.
--
G_MISS_ROLE_PMT_PLAN_REC  role_pmt_plan_rec_type;
G_MISS_ROLE_PMT_PLAN_TBL  role_pmt_plan_rec_tbl_type;
G_ROLE_NAME CONSTANT VARCHAR2(80)
  := cn_api.get_lkup_meaning('ROLE_NAME','ROLE_OBJECT_TYPE');

G_PP_NAME CONSTANT VARCHAR2(80)
  := cn_api.get_lkup_meaning('PP_NAME','PP_OBJECT_TYPE');

G_START_DATE  CONSTANT VARCHAR2(80)
  := cn_api.get_lkup_meaning('START_DATE','CN_OBJECT_TYPE');

-- Start of Comments
-- API name 	: Create_Role_Pmt_Plan
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Procedure to create a sales role and pmt plan assignment.
-- Parameters	:
-- IN		:  p_api_version            IN NUMBER      Require
-- 		:  p_init_msg_list          IN VARCHAR2    Optional
-- 		   	                    Default = FND_API.G_FALSE
-- 		:  p_commit	            IN VARCHAR2    Optional
-- 		       	                    Default = FND_API.G_FALSE
-- 		:  p_validation_level       IN NUMBER      Optional
-- 		       	                    Default = FND_API.G_VALID_LEVEL_FULL
-- 		:  p_role_pmt_plan_rec      IN             ROLE_PMT_PLAN_REC_TYPE
-- OUT		:  x_return_status          OUT	           VARCHAR2(1)
-- 		:  x_msg_count	            OUT	           NUMBER
-- 		:  x_msg_data	            OUT	           VARCHAR2(2000)
--		:  x_loading_status	    OUT            VARCHAR2
--
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Description	: This procedure is used to create a sales role and pmt plan assignment.
-- Notes	: 1. Role name can not be missing or null.
--                2. Pmt plan name can not be missing or null.
--                3. Start_date can not be missing or null.
--                4. Start_date <= end_date, if end_date is not null.
--                5. Role name must exist in cn_roles already.
--                6. Pmt_plan_name must exist in cn_pmt_plans already.
--                7. Date range (start_date, en_date) of the assignment must be
--                   within the date range (start_date, end_date) of the pmt plan.
--                8. No pmt plan with the same payment_group_code overlap for any same sales role.
--                   In other words, you can not have more than one pmt plan for
--                   the same role with the same payment group code at the same time.
--                9. Gap between two payment plans for the same role is allowed.
-- End of comments


PROCEDURE Create_Role_Pmt_Plan
  (  	p_api_version              IN	NUMBER				      ,
   	p_init_msg_list		   IN	VARCHAR2 := FND_API.G_FALSE   	      ,
	p_commit	    	   IN  	VARCHAR2 := FND_API.G_FALSE   	      ,
	p_validation_level	   IN  	NUMBER	 := FND_API.g_valid_level_full,
	x_return_status		   OUT	NOCOPY VARCHAR2		      	      ,
	x_loading_status           OUT  NOCOPY VARCHAR2                              ,
	x_msg_count		   OUT	NOCOPY NUMBER			      	      ,
	x_msg_data		   OUT	NOCOPY VARCHAR2                      	      ,
	p_role_pmt_plan_rec        IN   role_pmt_plan_rec_type := G_MISS_ROLE_PMT_PLAN_REC
	);

-- Start of Comments
-- API name 	: Update_Role_Pmt_Plan
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Procedure to update a sales role and pmt plan assignment.
-- Parameters	:
-- IN		:  p_api_version            IN NUMBER      Require
-- 		:  p_init_msg_list          IN VARCHAR2    Optional
-- 		   	                    Default = FND_API.G_FALSE
-- 		:  p_commit	            IN VARCHAR2    Optional
-- 		       	                    Default = FND_API.G_FALSE
-- 		:  p_validation_level       IN NUMBER      Optional
-- 		       	                    Default = FND_API.G_VALID_LEVEL_FULL
--              :  p_role_pmt_plan_rec_old  IN             ROLE_PMT_PLAN_REC_TYPE
-- 		:  p_role_pmt_plan_rec_new  IN             ROLE_PMT_PLAN_REC_TYPE
-- OUT		:  x_return_status          OUT	           VARCHAR2(1)
-- 		:  x_msg_count	            OUT	           NUMBER
-- 		:  x_msg_data	            OUT	           VARCHAR2(2000)
--		:  x_loading_status	    OUT            VARCHAR2
--
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Description	: This procedure is used to update a sales role and pmt plan assignment.
-- Notes	:  1. Old role_pmt_plan_id must be found in cn_role_pmt_plans.
--                 2. New role name can not be null.
--                 3. New pmt plan name can not be null.
--                 4. New start date can not be null.
--                 5. New start date <= new end date if new end date is not null.
--                 6. New role_name must exist in cn_roles already.
--                 8. New pmt plan name must exist in cn_pmt_plans already.
--                 9. The new date range (start_date, end_date) of the assignment must be
--                    within the date range (start_date, end_date) of the pmt plan.
--                10. No pmt plan overlap with same payment group code for any same sales role.
--                    In other words, you can not have more than one pmt plan with the same payment group code for
--                    the same role at the same time.
--                11. Gap between two pmt plans for the same role is allowed.
-- End of comments


PROCEDURE Update_Role_Pmt_Plan
(  	p_api_version              IN	NUMBER				      ,
   	p_init_msg_list		   IN	VARCHAR2 := FND_API.G_FALSE   	      ,
	p_commit	    	   IN  	VARCHAR2 := FND_API.G_FALSE   	      ,
	p_validation_level	   IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		   OUT	NOCOPY VARCHAR2		      	      ,
	x_loading_status           OUT  NOCOPY VARCHAR2 			      ,
	x_msg_count		   OUT	NOCOPY NUMBER			      	      ,
	x_msg_data		   OUT	NOCOPY VARCHAR2                      	      ,
	p_role_pmt_plan_rec_old    IN   role_pmt_plan_rec_type := G_MISS_ROLE_PMT_PLAN_REC,
        p_ovn                      IN   cn_role_pmt_plans.object_version_number%TYPE,
	p_role_pmt_plan_rec_new    IN   role_pmt_plan_rec_type := G_MISS_ROLE_PMT_PLAN_REC
	);



-- Start of Comments
-- API name 	: Delete_Role_Pmt_Plan
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Procedure to delete a sales role and pmt plan assignment.
-- Parameters	:
-- IN		:  p_api_version            IN NUMBER      Require
-- 		:  p_init_msg_list          IN VARCHAR2    Optional
-- 		   	                    Default = FND_API.G_FALSE
-- 		:  p_commit	            IN VARCHAR2    Optional
-- 		       	                    Default = FND_API.G_FALSE
-- 		:  p_validation_level       IN NUMBER      Optional
-- 		       	                    Default = FND_API.G_VALID_LEVEL_FULL
-- 		   p_role_pmt_plan_rec      IN             ROLE_PMT_PLAN_REC_TYPE
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


PROCEDURE Delete_Role_Pmt_Plan
(  	p_api_version              IN	NUMBER				      ,
   	p_init_msg_list		   IN	VARCHAR2 := FND_API.G_FALSE   	      ,
	p_commit	    	   IN  	VARCHAR2 := FND_API.G_FALSE   	      ,
	p_validation_level	   IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		   OUT	NOCOPY VARCHAR2		      	      ,
	x_loading_status           OUT  NOCOPY VARCHAR2            	              ,
	x_msg_count		   OUT	NOCOPY NUMBER			      	      ,
	x_msg_data		   OUT	NOCOPY VARCHAR2                      	      ,
	p_role_pmt_plan_rec        IN   role_pmt_plan_rec_type := G_MISS_ROLE_PMT_PLAN_REC
	);

FUNCTION date_range_overlap
  (
   a_start_date   DATE,
   a_end_date     DATE,
   b_start_date   DATE,
   b_end_date     DATE
   ) RETURN NUMBER;

FUNCTION date_range_diff_present
  (
   a_start_date   DATE,
   a_end_date     DATE,
   b_start_date   DATE,
   b_end_date     DATE
   ) RETURN NUMBER;

FUNCTION date_range_intersect
  (
   a_start_date   DATE,
   a_end_date     DATE,
   b_start_date   DATE,
   b_end_date     DATE
   ) RETURN NUMBER;

END CN_ROLE_PMT_PLANS_PVT;

 

/
