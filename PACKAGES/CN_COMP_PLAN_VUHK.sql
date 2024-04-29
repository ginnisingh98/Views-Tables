--------------------------------------------------------
--  DDL for Package CN_COMP_PLAN_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COMP_PLAN_VUHK" AUTHID CURRENT_USER AS
/* $Header: cnicps.pls 120.1 2005/06/10 14:16:06 appldev  $ */

-- Start of Comments
-- API name 	: Create_Comp_Plan_Pre
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: User hook before create a new compensation plan
--                or add the passed in plan element into an existing
--                compensation plan
-- Desc 	: Procedure to create a new compensation plan or add a plan
--                element to an existing compensation plan
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
-- IN OUT	:  p_comp_plan_rec     IN OUT         comp_plan_rec_type
-- Version	:  Current version     1.0
--		   Initial version     1.0
--
-- End of comments

PROCEDURE Create_Comp_Plan_Pre
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count	        OUT NOCOPY  NUMBER,
   x_msg_data	        OUT NOCOPY  VARCHAR2,
   p_comp_plan_rec      IN OUT NOCOPY    cn_comp_plan_pub.comp_plan_rec_type,
   x_loading_status     OUT NOCOPY VARCHAR2
);


-- Start of Comments
-- API name 	: Create_Comp_Plan_Post
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: User hook before create a new compensation plan
--                or add the passed in plan element into an existing
--                compensation plan
-- Desc 	: Procedure to create a new compensation plan or add a plan
--                element to an existing compensation plan
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
-- IN   	:  p_comp_plan_rec     IN             comp_plan_rec_type
-- Version	:  Current version     1.0
--		   Initial version     1.0
--
-- End of comments

PROCEDURE Create_Comp_Plan_Post
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count	        OUT NOCOPY  NUMBER,
   x_msg_data	        OUT NOCOPY  VARCHAR2,
   p_comp_plan_rec      IN    cn_comp_plan_pub.comp_plan_rec_type,
   x_loading_status     OUT NOCOPY VARCHAR2
);

END CN_COMP_PLAN_VUHK ;

 

/
