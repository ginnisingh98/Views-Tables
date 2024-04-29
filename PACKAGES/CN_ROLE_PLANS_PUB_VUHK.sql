--------------------------------------------------------
--  DDL for Package CN_ROLE_PLANS_PUB_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_ROLE_PLANS_PUB_VUHK" AUTHID CURRENT_USER AS
/* $Header: cnirlpls.pls 120.1 2005/06/10 13:55:17 appldev  $ */

-- Start of Comments
-- API name 	: Create_Role_Plan_Pre
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization before create a sales role and comp plan
--                assignment.
-- Parameters	:
-- IN		:  p_api_version            IN NUMBER      Require
-- 		:  p_init_msg_list          IN VARCHAR2    Optional
-- 		   	                    Default = FND_API.G_FALSE
-- 		:  p_commit	            IN VARCHAR2    Optional
-- 		       	                    Default = FND_API.G_FALSE
-- 		:  p_validation_level       IN NUMBER      Optional
-- 		       	                    Default = FND_API.G_VALID_LEVEL_FULL
-- 		:  p_role_plan_rec          IN OUT NOCOPY
--                                          CN_ROLE_PLANS_PUB.ROLE_PLAN_REC_TYPE
-- OUT		:  x_return_status          OUT NOCOPY 	           VARCHAR2(1)
-- 		:  x_msg_count	            OUT NOCOPY 	           NUMBER
-- 		:  x_msg_data	            OUT NOCOPY 	           VARCHAR2(2000)
--		:  x_loading_status	    OUT NOCOPY             VARCHAR2
--
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes
-- End of comments


PROCEDURE Create_Role_Plan_Pre
  (  	p_api_version              IN	NUMBER				      ,
   	p_init_msg_list		   IN	VARCHAR2 := CN_API.G_FALSE   	      ,
	p_commit	    	   IN  	VARCHAR2 := CN_API.G_FALSE   	      ,
	p_validation_level	   IN  	NUMBER	 := CN_API.g_valid_level_full,
	x_return_status		   OUT	NOCOPY VARCHAR2		      	      ,
	x_loading_status           OUT  NOCOPY VARCHAR2                              ,
	x_msg_count		   OUT	NOCOPY NUMBER			      	      ,
	x_msg_data		   OUT	NOCOPY VARCHAR2                      	      ,
	p_role_plan_rec            IN  OUT NOCOPY   cn_role_plans_pub.role_plan_rec_type
	);



-- Start of Comments
-- API name 	: Create_Role_Plan_Post
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization after create a sales role and comp plan
--                assignment.
-- Parameters	:
-- IN		:  p_api_version            IN NUMBER      Require
-- 		:  p_init_msg_list          IN VARCHAR2    Optional
-- 		   	                    Default = FND_API.G_FALSE
-- 		:  p_commit	            IN VARCHAR2    Optional
-- 		       	                    Default = FND_API.G_FALSE
-- 		:  p_validation_level       IN NUMBER      Optional
-- 		       	                    Default = FND_API.G_VALID_LEVEL_FULL
-- 		:  p_role_plan_rec          IN OUT NOCOPY
--                                          CN_ROLE_PLANS_PUB.ROLE_PLAN_REC_TYPE
-- OUT		:  x_return_status          OUT NOCOPY 	           VARCHAR2(1)
-- 		:  x_msg_count	            OUT NOCOPY 	           NUMBER
-- 		:  x_msg_data	            OUT NOCOPY 	           VARCHAR2(2000)
--		:  x_loading_status	    OUT NOCOPY             VARCHAR2
--
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes
-- End of comments


PROCEDURE Create_Role_Plan_Post
  (  	p_api_version              IN	NUMBER				      ,
   	p_init_msg_list		   IN	VARCHAR2 := CN_API.G_FALSE   	      ,
	p_commit	    	   IN  	VARCHAR2 := CN_API.G_FALSE   	      ,
	p_validation_level	   IN  	NUMBER	 := CN_API.g_valid_level_full,
	x_return_status		   OUT	NOCOPY VARCHAR2		      	      ,
	x_loading_status           OUT  NOCOPY VARCHAR2                              ,
	x_msg_count		   OUT	NOCOPY NUMBER			      	      ,
	x_msg_data		   OUT	NOCOPY VARCHAR2                      	      ,
	p_role_plan_rec            IN  OUT NOCOPY   cn_role_plans_pub.role_plan_rec_type
	);



-- Start of Comments
-- API name 	: Update_Role_Plan_Pre
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customize before update a sales role and comp plan assignment.
-- Parameters	:
-- IN		:  p_api_version            IN NUMBER      Require
-- 		:  p_init_msg_list          IN VARCHAR2    Optional
-- 		   	                    Default = FND_API.G_FALSE
-- 		:  p_commit	            IN VARCHAR2    Optional
-- 		       	                    Default = FND_API.G_FALSE
-- 		:  p_validation_level       IN NUMBER      Optional
-- 		       	                    Default = FND_API.G_VALID_LEVEL_FULL
--              :  p_role_plan_rec_old      IN OUT NOCOPY
--                                          CN_ROLE_PLANS_PUB.ROLE_PLAN_REC_TYPE
-- 		:  p_role_plan_rec_new      IN OUT NOCOPY
--                                          CN_ROLE_PLANS_PUB.ROLE_PLAN_REC_TYPE
-- OUT		:  x_return_status          OUT NOCOPY 	           VARCHAR2(1)
-- 		:  x_msg_count	            OUT NOCOPY 	           NUMBER
-- 		:  x_msg_data	            OUT NOCOPY 	           VARCHAR2(2000)
--		:  x_loading_status	    OUT NOCOPY             VARCHAR2
--
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes
-- End of comments


PROCEDURE Update_Role_Plan_Pre
(  	p_api_version              IN	NUMBER				      ,
   	p_init_msg_list		   IN	VARCHAR2 := CN_API.G_FALSE   	      ,
	p_commit	    	   IN  	VARCHAR2 := CN_API.G_FALSE   	      ,
	p_validation_level	   IN  	NUMBER	 := CN_API.G_VALID_LEVEL_FULL,
	x_return_status		   OUT	NOCOPY VARCHAR2		      	      ,
	x_loading_status           OUT  NOCOPY VARCHAR2 			      ,
	x_msg_count		   OUT	NOCOPY NUMBER			      	      ,
	x_msg_data		   OUT	NOCOPY VARCHAR2                      	      ,
	p_role_plan_rec_old        IN OUT NOCOPY  cn_role_plans_pub.role_plan_rec_type,
	p_role_plan_rec_new        IN OUT NOCOPY  cn_role_plans_pub.role_plan_rec_type
	);


-- Start of Comments
-- API name 	: Update_Role_Plan_Post
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customize after update a sales role and comp plan assignment.
-- Parameters	:
-- IN		:  p_api_version            IN NUMBER      Require
-- 		:  p_init_msg_list          IN VARCHAR2    Optional
-- 		   	                    Default = FND_API.G_FALSE
-- 		:  p_commit	            IN VARCHAR2    Optional
-- 		       	                    Default = FND_API.G_FALSE
-- 		:  p_validation_level       IN NUMBER      Optional
-- 		       	                    Default = FND_API.G_VALID_LEVEL_FULL
--              :  p_role_plan_rec_old      IN OUT NOCOPY
--                                          CN_ROLE_PLANS_PUB.ROLE_PLAN_REC_TYPE
-- 		:  p_role_plan_rec_new      IN OUT NOCOPY
--                                          CN_ROLE_PLANS_PUB.ROLE_PLAN_REC_TYPE
-- OUT		:  x_return_status          OUT NOCOPY 	           VARCHAR2(1)
-- 		:  x_msg_count	            OUT NOCOPY 	           NUMBER
-- 		:  x_msg_data	            OUT NOCOPY 	           VARCHAR2(2000)
--		:  x_loading_status	    OUT NOCOPY             VARCHAR2
--
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes
-- End of comments


PROCEDURE Update_Role_Plan_Post
(  	p_api_version              IN	NUMBER				      ,
   	p_init_msg_list		   IN	VARCHAR2 := CN_API.G_FALSE   	      ,
	p_commit	    	   IN  	VARCHAR2 := CN_API.G_FALSE   	      ,
	p_validation_level	   IN  	NUMBER	 := CN_API.G_VALID_LEVEL_FULL,
	x_return_status		   OUT	NOCOPY VARCHAR2		      	      ,
	x_loading_status           OUT  NOCOPY VARCHAR2 			      ,
	x_msg_count		   OUT	NOCOPY NUMBER			      	      ,
	x_msg_data		   OUT	NOCOPY VARCHAR2                      	      ,
	p_role_plan_rec_old        IN OUT NOCOPY  cn_role_plans_pub.role_plan_rec_type,
	p_role_plan_rec_new        IN OUT NOCOPY  cn_role_plans_pub.role_plan_rec_type
	);

-- Start of Comments
-- API name 	: Delete_Role_Plan_Pre
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customize before delete a sales role and comp plan assignment.
-- Parameters	:
-- IN		:  p_api_version            IN NUMBER      Require
-- 		:  p_init_msg_list          IN VARCHAR2    Optional
-- 		   	                    Default = FND_API.G_FALSE
-- 		:  p_commit	            IN VARCHAR2    Optional
-- 		       	                    Default = FND_API.G_FALSE
-- 		:  p_validation_level       IN NUMBER      Optional
-- 		       	                    Default = FND_API.G_VALID_LEVEL_FULL
-- 		   p_role_plan_rec          IN OUT NOCOPY
--                                          CN_ROLE_PLANS_PUB.ROLE_PLAN_REC_TYPE
-- OUT		:  x_return_status          OUT NOCOPY 	           VARCHAR2(1)
-- 		:  x_msg_count	            OUT NOCOPY 	           NUMBER
-- 		:  x_msg_data	            OUT NOCOPY 	           VARCHAR2(2000)
--		:  x_loading_status	    OUT NOCOPY             VARCHAR2
--
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes
-- End of comments


PROCEDURE Delete_Role_Plan_Pre
(  	p_api_version              IN	NUMBER				      ,
   	p_init_msg_list		   IN	VARCHAR2 := CN_API.G_FALSE   	      ,
	p_commit	    	   IN  	VARCHAR2 := CN_API.G_FALSE   	      ,
	p_validation_level	   IN  	NUMBER	 := CN_API.G_VALID_LEVEL_FULL,
	x_return_status		   OUT NOCOPY 	VARCHAR2		      	      ,
	x_loading_status           OUT NOCOPY   VARCHAR2            	              ,
	x_msg_count		   OUT NOCOPY 	NUMBER			      	      ,
	x_msg_data		   OUT NOCOPY 	VARCHAR2                      	      ,
	p_role_plan_rec            IN OUT NOCOPY  cn_role_plans_pub.role_plan_rec_type
	);


-- Start of Comments
-- API name 	: Delete_Role_Plan_Post
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customize after delete a sales role and comp plan assignment.
-- Parameters	:
-- IN		:  p_api_version            IN NUMBER      Require
-- 		:  p_init_msg_list          IN VARCHAR2    Optional
-- 		   	                    Default = FND_API.G_FALSE
-- 		:  p_commit	            IN VARCHAR2    Optional
-- 		       	                    Default = FND_API.G_FALSE
-- 		:  p_validation_level       IN NUMBER      Optional
-- 		       	                    Default = FND_API.G_VALID_LEVEL_FULL
-- 		   p_role_plan_rec          IN OUT NOCOPY
--                                          CN_ROLE_PLANS_PUB.ROLE_PLAN_REC_TYPE
-- OUT		:  x_return_status          OUT NOCOPY 	           VARCHAR2(1)
-- 		:  x_msg_count	            OUT NOCOPY 	           NUMBER
-- 		:  x_msg_data	            OUT NOCOPY 	           VARCHAR2(2000)
--		:  x_loading_status	    OUT NOCOPY             VARCHAR2
--
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes
-- End of comments


PROCEDURE Delete_Role_Plan_Post
(  	p_api_version              IN	NUMBER				      ,
   	p_init_msg_list		   IN	VARCHAR2 := CN_API.G_FALSE   	      ,
	p_commit	    	   IN  	VARCHAR2 := CN_API.G_FALSE   	      ,
	p_validation_level	   IN  	NUMBER	 := CN_API.G_VALID_LEVEL_FULL,
	x_return_status		   OUT NOCOPY 	VARCHAR2		      	      ,
	x_loading_status           OUT NOCOPY   VARCHAR2            	              ,
	x_msg_count		   OUT NOCOPY 	NUMBER			      	      ,
	x_msg_data		   OUT NOCOPY 	VARCHAR2                      	      ,
	p_role_plan_rec            IN OUT NOCOPY  cn_role_plans_pub.role_plan_rec_type
	);


END cn_role_plans_pub_vuhk;
 

/
