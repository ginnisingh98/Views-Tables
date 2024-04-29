--------------------------------------------------------
--  DDL for Package CN_SRP_PMT_PLANS_PUB_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_PMT_PLANS_PUB_VUHK" AUTHID CURRENT_USER AS
/* $Header: cnisppas.pls 120.1 2005/06/10 13:57:07 appldev  $ */

-- Start of comments
-- API name 	: Create_Srp_Pmt_Plan_Pre
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization before create a new payment plan assignment to
--                an salesrep
-- Desc 	:
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- 		   p_srp_pmt_plans_rec   IN OUT NOCOPY
--                      cn_srp_pmt_plans_pub.srp_pmt_plans_rec_type
--                 Required input :
--                    PMT_PLAN_NAME           payment plan name
--                    SALESREP_TYPE,EMP_NUM   use to get salesrep info
--                    ROLE_NAME               which sales role to be assigned
-- OUT		:  x_return_status     OUT NOCOPY	      VARCHAR2(1)
-- 		   x_msg_count	       OUT NOCOPY	      NUMBER
-- 		   x_msg_data	       OUT NOCOPY	      VARCHAR2(2000)
--                 x_loading_status    OUT NOCOPY	      VARCHAR2(30)
-- Version	: Current version	1.0
--		  Initial version 	1.0
-- Notes        :
--
-- End of comments

PROCEDURE Create_Srp_Pmt_Plan_Pre
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   p_srp_pmt_plans_rec  IN OUT NOCOPY  cn_srp_pmt_plans_pub.srp_pmt_plans_rec_type,
   x_srp_pmt_plan_id    OUT NOCOPY   NUMBER,
   x_loading_status     OUT NOCOPY   VARCHAR2
);

-- Start of comments
-- API name 	: Create_Srp_Pmt_Plan_Post
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization after create a new payment plan assignment to
--                an salesrep
-- Desc 	:
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- 		   p_srp_pmt_plans_rec   IN
--                      cn_srp_pmt_plans_pub.srp_pmt_plans_rec_type
--                 Required input :
--                    PMT_PLAN_NAME           payment plan name
--                    SALESREP_TYPE,EMP_NUM   use to get salesrep info
--                    ROLE_NAME               which sales role to be assigned
-- OUT		:  x_return_status     OUT NOCOPY	      VARCHAR2(1)
-- 		   x_msg_count	       OUT NOCOPY	      NUMBER
-- 		   x_msg_data	       OUT NOCOPY	      VARCHAR2(2000)
--                 x_loading_status    OUT NOCOPY	      VARCHAR2(30)
-- Version	: Current version	1.0
--		  Initial version 	1.0
-- Notes        :
--
-- End of comments

PROCEDURE Create_Srp_Pmt_Plan_Post
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   p_srp_pmt_plans_rec  IN    cn_srp_pmt_plans_pub.srp_pmt_plans_rec_type,
   x_srp_pmt_plan_id    OUT NOCOPY   NUMBER,
   x_loading_status     OUT NOCOPY   VARCHAR2
);

-- Start of comments
-- API name 	: Update_Srp_Pmt_Plan_Pre
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customize before update pmt plan assignment of an salesrep
-- Desc 	: Procedure to update pmt plan assignment of an salesrep
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- 	           p_srp_pmt_plans_rec   IN OUT NOCOPY     srp_pmt_plans_rec_type
--                 Required input :
--                    PMT_PLAN_NAME           payment plan name
--                    SALESREP_TYPE,EMP_NUM   use to get salesrep info
--                    ROLE_NAME               which sales role to be assigned
-- OUT		:  x_return_status     OUT NOCOPY	      VARCHAR2(1)
-- 		   x_msg_count	       OUT NOCOPY	      NUMBER
-- 		   x_msg_data	       OUT NOCOPY	      VARCHAR2(2000)
--                 x_loading_status    OUT NOCOPY	      VARCHAR2(30)
-- Version	: Current version	1.0
--		  Initial version 	1.0
-- Notes        :
--
-- End of comments

PROCEDURE Update_Srp_Pmt_Plan_Pre
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   p_old_srp_pmt_plans_rec  IN OUT NOCOPY cn_srp_pmt_plans_pub.srp_pmt_plans_rec_type,
   p_srp_pmt_plans_rec  IN OUT NOCOPY cn_srp_pmt_plans_pub.srp_pmt_plans_rec_type,
   x_loading_status     OUT NOCOPY   VARCHAR2
);

-- Start of comments
-- API name 	: Update_Srp_Pmt_Plan_Post
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customize after update pmt plan assignment of an salesrep
-- Desc 	: Procedure to update pmt plan assignment of an salesrep
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- 	           p_srp_pmt_plans_rec   IN OUT NOCOPY     srp_pmt_plans_rec_type
--                 Required input :
--                    PMT_PLAN_NAME           payment plan name
--                    SALESREP_TYPE,EMP_NUM   use to get salesrep info
--                    ROLE_NAME               which sales role to be assigned
-- OUT		:  x_return_status     OUT NOCOPY	      VARCHAR2(1)
-- 		   x_msg_count	       OUT NOCOPY	      NUMBER
-- 		   x_msg_data	       OUT NOCOPY	      VARCHAR2(2000)
--                 x_loading_status    OUT NOCOPY	      VARCHAR2(30)
-- Version	: Current version	1.0
--		  Initial version 	1.0
-- Notes        :
--
-- End of comments

PROCEDURE Update_Srp_Pmt_Plan_Post
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   p_old_srp_pmt_plans_rec  IN cn_srp_pmt_plans_pub.srp_pmt_plans_rec_type
                                := cn_srp_pmt_plans_pub.G_MISS_SRP_PMT_PLANS_REC,
   p_srp_pmt_plans_rec  IN cn_srp_pmt_plans_pub.srp_pmt_plans_rec_type
                              := cn_srp_pmt_plans_pub.G_MISS_SRP_PMT_PLANS_REC,
   x_loading_status     OUT NOCOPY   VARCHAR2
);

-- Start of comments
-- API name 	: Delete_Srp_Pmt_Plan_Pre
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customize before delete a payment plan assign to an salesrep
-- Desc 	: Procedure to delete a payment plan assignment to salesrep
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
--  	           p_srp_pmt_plans_rec   IN OUT NOCOPY     srp_pmt_plans_rec_type
--                 Required input :
--                    PMT_PLAN_NAME           payment plan name
--                    SALESREP_TYPE,EMP_NUM   use to get salesrep info
--                    ROLE_NAME               which sales role to be assigned
-- OUT		:  x_return_status     OUT NOCOPY	      VARCHAR2(1)
-- 		   x_msg_count	       OUT NOCOPY	      NUMBER
-- 		   x_msg_data	       OUT NOCOPY	      VARCHAR2(2000)
--                 x_loading_status    OUT NOCOPY	      VARCHAR2(30)
-- Version	: Current version	1.0
--		  Initial version 	1.0
-- Notes        :
-- End of comments

PROCEDURE Delete_Srp_Pmt_Plan_Pre
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   p_srp_pmt_plans_rec IN OUT NOCOPY  cn_srp_pmt_plans_pub.srp_pmt_plans_rec_type,
   x_loading_status     OUT NOCOPY   VARCHAR2
);

-- Start of comments
-- API name 	: Delete_Srp_Pmt_Plan_Post
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customize after delete a payment plan assign to an salesrep
-- Desc 	: Procedure to delete a payment plan assignment to salesrep
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
--  	           p_srp_pmt_plans_rec   IN OUT NOCOPY     srp_pmt_plans_rec_type
--                 Required input :
--                    PMT_PLAN_NAME           payment plan name
--                    SALESREP_TYPE,EMP_NUM   use to get salesrep info
--                    ROLE_NAME               which sales role to be assigned
-- OUT		:  x_return_status     OUT NOCOPY	      VARCHAR2(1)
-- 		   x_msg_count	       OUT NOCOPY	      NUMBER
-- 		   x_msg_data	       OUT NOCOPY	      VARCHAR2(2000)
--                 x_loading_status    OUT NOCOPY	      VARCHAR2(30)
-- Version	: Current version	1.0
--		  Initial version 	1.0
-- Notes        :
-- End of comments

PROCEDURE Delete_Srp_Pmt_Plan_Post
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   p_srp_pmt_plans_rec  IN    cn_srp_pmt_plans_pub.srp_pmt_plans_rec_type
                              := cn_srp_pmt_plans_pub.G_MISS_SRP_PMT_PLANS_REC,
   x_loading_status     OUT NOCOPY   VARCHAR2
);

-- API name 	: Get_Srp_Pmt_Plan_Pre
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customize before get payment plan assignment from db
-- Desc 	: Procedure to  payment plan assignment from db
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
--                 p_pmt_plan_name    IN    VARCHAR2   Optional
--                      Default = FND_API.G_MISS_CHAR
--                 p_salesrep_type    IN    VARCHAR2   Optional
--                      Default = FND_API.G_MISS_CHAR
--                 p_emp_num          IN    VARCHAR2   Optional
--                      Default = FND_API.G_MISS_CHAR
--                 p_role_name        IN    VARCHAR2   Optional
--                      Default = FND_API.G_MISS_CHAR
-- OUT		:  x_return_status     OUT NOCOPY	      VARCHAR2(1)
-- 		   x_msg_count	       OUT NOCOPY	      NUMBER
-- 		   x_msg_data	       OUT NOCOPY	      VARCHAR2(2000)
--                 x_srp_pmt_plans_rec_tbl   OUT NOCOPY      srp_pmt_plans_tbl_type
--                 x_loading_status    OUT NOCOPY	      VARCHAR2(30)
-- Version	: Current version	1.0
--		  Initial version 	1.0
-- Notes        :
-- End of comments

PROCEDURE Get_Srp_Pmt_Plan_Pre
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   p_pmt_plan_name 	IN OUT NOCOPY VARCHAR2,
   p_salesrep_type      IN OUT NOCOPY VARCHAR2,
   p_emp_num            IN OUT NOCOPY VARCHAR2 ,
   p_role_name  	IN OUT NOCOPY VARCHAR2 ,
   x_srp_pmt_plans_rec_tbl  OUT NOCOPY  cn_srp_pmt_plans_pub.srp_pmt_plans_tbl_type ,
   x_loading_status     OUT NOCOPY   VARCHAR2
);

-- API name 	: Get_Srp_Pmt_Plan_Post
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customize after get payment plan assignment from db
-- Desc 	: Procedure to  payment plan assignment from db
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
--                 p_pmt_plan_name    IN    VARCHAR2   Optional
--                      Default = FND_API.G_MISS_CHAR
--                 p_salesrep_type    IN    VARCHAR2   Optional
--                      Default = FND_API.G_MISS_CHAR
--                 p_emp_num          IN    VARCHAR2   Optional
--                      Default = FND_API.G_MISS_CHAR
--                 p_role_name        IN    VARCHAR2   Optional
--                      Default = FND_API.G_MISS_CHAR
-- OUT		:  x_return_status     OUT NOCOPY	      VARCHAR2(1)
-- 		   x_msg_count	       OUT NOCOPY	      NUMBER
-- 		   x_msg_data	       OUT NOCOPY	      VARCHAR2(2000)
--                 x_srp_pmt_plans_rec_tbl   OUT NOCOPY      srp_pmt_plans_tbl_type
--                 x_loading_status    OUT NOCOPY	      VARCHAR2(30)
-- Version	: Current version	1.0
--		  Initial version 	1.0
-- Notes        :
-- End of comments

PROCEDURE Get_Srp_Pmt_Plan_Post
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   p_pmt_plan_name 	IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_salesrep_type      IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_emp_num            IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   p_role_name  	IN  VARCHAR2 := FND_API.G_MISS_CHAR,
   x_srp_pmt_plans_rec_tbl  OUT NOCOPY  cn_srp_pmt_plans_pub.srp_pmt_plans_tbl_type ,
   x_loading_status     OUT NOCOPY   VARCHAR2
);

END CN_SRP_PMT_PLANS_PUB_VUHK ;

 

/
