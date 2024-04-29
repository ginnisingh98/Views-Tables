--------------------------------------------------------
--  DDL for Package CN_SRP_PLAN_ASSIGNS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_SRP_PLAN_ASSIGNS_PVT" AUTHID CURRENT_USER AS
/* $Header: cnvspas.pls 115.7 2002/11/21 21:18:38 hlchen ship $ */

-- Global variable for the translatable name for all Plan Assign objects.

-- Start of comments
-- API name 	: Create_Srp_Plan_Assigns
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Used to create a new comp plan assignment to an salesrep
-- Desc 	: Procedure to create a new comp plan assignment to an salesrep
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- IN		:  p_srp_role_id       IN    NUMBER,
--                 p_role_plan_id      IN    NUMBER,
--                 p_attribute_rec     IN    cn.attribute_rec_type
-- OUT		:  x_srp_plan_assign_id OUT	      NUMBER
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- End of comments

PROCEDURE Create_Srp_Plan_Assigns
  (p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   p_srp_role_id        IN    NUMBER,
   p_role_plan_id       IN    NUMBER,
   p_attribute_rec      IN    cn_global_var.attribute_rec_type := CN_GLOBAL_VAR.G_MISS_ATTRIBUTE_REC,
   x_srp_plan_assign_id OUT NOCOPY   NUMBER,
   x_loading_status     OUT NOCOPY   VARCHAR2
   );

-- Start of comments
-- API name 	: Update_Srp_Plan_Assigns
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Used to update comp plan assignment of an salesrep
-- Desc 	: Procedure to update comp plan assignment of an salesrep
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- IN		:  p_srp_role_id       IN    NUMBER,
--                 p_role_plan_id      IN    NUMBER,
--                 p_attribute_rec     IN    cn.attribute_rec_type
-- 		:  p_srp_plan_assign_id IN  NUMBER
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- End of comments

PROCEDURE Update_Srp_Plan_Assigns
  (p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   p_srp_role_id        IN    NUMBER,
   p_role_plan_id       IN    NUMBER,
   p_attribute_rec      IN    cn_global_var.attribute_rec_type := cn_global_var.g_miss_attribute_rec,
   x_loading_status     OUT NOCOPY   VARCHAR2
   );

-- Start of comments
-- API name 	: Delete_Srp_Plan_Assigns
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Used to delete comp plan assignment of an salesrep
-- Desc 	: Procedure to delete comp plan assignment of an salesrep
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- IN		:  p_srp_role_id       IN    NUMBER,
--                 p_role_plan_id      IN    NUMBER,
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- End of comments

PROCEDURE Delete_Srp_Plan_Assigns
  (p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   p_srp_role_id        IN    NUMBER,
   p_role_plan_id       IN    NUMBER,
   x_loading_status     OUT NOCOPY   VARCHAR2
   );

END CN_SRP_PLAN_ASSIGNS_PVT ;


 

/
