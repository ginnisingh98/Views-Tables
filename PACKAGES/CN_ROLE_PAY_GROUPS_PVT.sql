--------------------------------------------------------
--  DDL for Package CN_ROLE_PAY_GROUPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_ROLE_PAY_GROUPS_PVT" AUTHID CURRENT_USER AS
/* $Header: cnvrpgps.pls 120.3 2005/08/25 03:17:44 sjustina noship $ */

--
-- User defined Record Type
--
-- Note: form bug 725654 for G_MISS

TYPE role_pay_groups_rec_type IS RECORD
  (
   role_pay_group_id    cn_role_pay_groups.role_pay_group_id%TYPE  := cn_api.G_MISS_ID,
   role_name            cn_roles.name%TYPE           ,
   pay_groups_name      cn_pay_groups.name%TYPE      ,
   start_date           cn_role_pay_groups.start_date%TYPE  ,
   end_date             cn_role_pay_groups.end_date%TYPE    ,
   attribute_category   cn_role_pay_groups.attribute_category%TYPE := NULL,
   attribute1           cn_role_pay_groups.attribute1%TYPE  := NULL,
   attribute2           cn_role_pay_groups.attribute2%TYPE  := NULL,
   attribute3           cn_role_pay_groups.attribute3%TYPE  := NULL,
   attribute4           cn_role_pay_groups.attribute4%TYPE  := NULL,
   attribute5           cn_role_pay_groups.attribute5%TYPE  := NULL,
   attribute6           cn_role_pay_groups.attribute6%TYPE  := NULL,
   attribute7           cn_role_pay_groups.attribute7%TYPE  := NULL,
   attribute8           cn_role_pay_groups.attribute8%TYPE  := NULL,
   attribute9           cn_role_pay_groups.attribute9%TYPE  := NULL,
   attribute10          cn_role_pay_groups.attribute10%TYPE := NULL,
   attribute11          cn_role_pay_groups.attribute11%TYPE := NULL,
   attribute12          cn_role_pay_groups.attribute12%TYPE := NULL,
   attribute13          cn_role_pay_groups.attribute13%TYPE := NULL,
   attribute14          cn_role_pay_groups.attribute14%TYPE := NULL,
   attribute15          cn_role_pay_groups.attribute15%TYPE := NULL,
   org_id                  cn_role_pay_groups.org_Id%TYPE := NULL,
   object_version_number   cn_role_pay_groups.object_version_number%TYPE := NULL
  );

--
-- User defined Record Table Type
--
TYPE role_pay_groups_rec_tbl_type IS TABLE OF role_pay_groups_rec_type
  INDEX BY BINARY_INTEGER;

--
-- Global variable that represent missing values.
--
G_MISS_ROLE_PAY_GROUPS_REC  role_pay_groups_rec_type;
--G_MISS_ROLE_PAY_GROUPS_TBL  role_pay_group_recs_tbl_type;
G_ROLE_NAME CONSTANT VARCHAR2(80)
  := cn_api.get_lkup_meaning('ROLE_NAME','ROLE_OBJECT_TYPE');
G_PG_NAME  CONSTANT VARCHAR2(80) --LOOK AT THIS
  := cn_api.get_lkup_meaning('PG_NAME','PG_OBJECT_TYPE');
G_START_DATE  CONSTANT VARCHAR2(80)
  := cn_api.get_lkup_meaning('START_DATE','CN_OBJECT_TYPE');


-- Start of Comments
-- API name 	: Create_Role_Pay_Groups
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Procedure to create a sales role and pay group assignment.
-- Parameters	:
-- IN		:  p_api_version            IN NUMBER      Require
-- 		:  p_init_msg_list          IN VARCHAR2    Optional
-- 		   	                    Default = FND_API.G_FALSE
-- 		:  p_commit	            IN VARCHAR2    Optional
-- 		       	                    Default = FND_API.G_FALSE
-- 		:  p_validation_level       IN NUMBER      Optional
-- 		       	                    Default = FND_API.G_VALID_LEVEL_FULL
-- 		:  p_role_pay_groups         IN             ROLE_PLAN_REC_TYPE
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
--                2. Pay group name can not be missing or null.
--                3. Start_date can not be missing or null.
--                4. Start_date <= end_date, if end_date is not null.
--                5. Role name must exist in cn_roles already.
--                6. Pay_Group_name must exist in cn_pay_groups already.
--                7. Date range (start_date, en_date) of the assignment must be
--                   within the date range (start_date, end_date) of the comp plan.
--                8. No pay group overlap for the any same sales role.
--                   In other words, you can not have more than one pay group for
--                   the same role at the same time.
--                9. Gap between two comp plans for the same role is allowed.
-- End of comments


PROCEDURE Create_Role_Pay_Groups
  (  	p_api_version              IN	NUMBER				      ,
   	p_init_msg_list		   IN	VARCHAR2 := FND_API.G_FALSE   	      ,
	p_commit	    	   IN  	VARCHAR2 := FND_API.G_FALSE   	      ,
	p_validation_level	   IN  	NUMBER	 := FND_API.g_valid_level_full,
	x_return_status		   OUT NOCOPY VARCHAR2		      	      ,
	x_loading_status           OUT NOCOPY VARCHAR2                              ,
	x_msg_count		   OUT NOCOPY	NUMBER			      	      ,
	x_msg_data		   OUT NOCOPY	VARCHAR2                      	      ,
	p_role_pay_groups_rec   IN OUT NOCOPY  role_pay_groups_rec_type
	);



-- Start of Comments
-- API name 	: Delete_Role_Pay_Groups
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Procedure to delete a sales role and pay groups assignment.
-- Parameters	:
-- IN		:  p_api_version            IN NUMBER      Require
-- 		:  p_init_msg_list          IN VARCHAR2    Optional
-- 		   	                    Default = FND_API.G_FALSE
-- 		:  p_commit	            IN VARCHAR2    Optional
-- 		       	                    Default = FND_API.G_FALSE
-- 		:  p_validation_level       IN NUMBER      Optional
-- 		       	                    Default = FND_API.G_VALID_LEVEL_FULL
-- 		   p_role_pay_groups_rec    IN             ROLE_PAY_GROUPS_REC
-- OUT		:  x_return_status          OUT	           VARCHAR2(1)
-- 		:  x_msg_count	            OUT	           NUMBER
-- 		:  x_msg_data	            OUT	           VARCHAR2(2000)
--		:  x_loading_status	    OUT            VARCHAR2
--
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Description	: This procedure is used to delete a sales role and pay group assignment.
-- Notes	: 1. the old p_role_plan_id must be found based on the
--                   parameters passed in.
-- End of comments


PROCEDURE Delete_Role_Pay_Groups
(  	p_api_version              IN	NUMBER				      ,
   	p_init_msg_list		   IN	VARCHAR2 := FND_API.G_FALSE   	      ,
	p_commit	    	   IN  	VARCHAR2 := FND_API.G_FALSE   	      ,
	p_validation_level	   IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		   OUT NOCOPY	VARCHAR2		      	      ,
	x_loading_status           OUT NOCOPY  VARCHAR2            	              ,
	x_msg_count		   OUT NOCOPY	NUMBER			      	      ,
	x_msg_data		   OUT NOCOPY	VARCHAR2                      	      ,
	p_role_pay_groups_rec IN OUT NOCOPY role_pay_groups_rec_type
	);

END CN_ROLE_PAY_GROUPS_PVT;

 

/
