--------------------------------------------------------
--  DDL for Package CN_CALC_SUBMISSION_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_CALC_SUBMISSION_CUHK" AUTHID CURRENT_USER AS
/* $Header: cnccsbs.pls 120.1 2005/06/10 13:57:28 appldev  $ */

-- Start of Comments
-- API name 	: Create_Calc_Submission_Pre
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
-- IN OUT	:  p_calc_submission_rec IN OUT       calc_submission_rec_type
-- Version	:  Current version     1.0
--		   Initial version     1.0
--
-- End of comments

PROCEDURE Create_Calc_Submission_Pre
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT   NOCOPY VARCHAR2,
   x_msg_count	        OUT   NOCOPY NUMBER,
   x_msg_data	        OUT   NOCOPY VARCHAR2,
   p_calc_submission_rec IN OUT      NOCOPY  cn_calc_submission_pub.calc_submission_rec_type,
   x_loading_status     OUT   NOCOPY VARCHAR2
);

-- Start of Comments
-- API name 	: Create_Calc_Submission_Post
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
-- IN   	:  p_calc_submission_rec IN       calc_submission_rec_type
-- Version	:  Current version     1.0
--		   Initial version     1.0
--
-- End of comments

PROCEDURE Create_Calc_Submission_Post
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT   NOCOPY VARCHAR2,
   x_msg_count	        OUT   NOCOPY NUMBER,
   x_msg_data	        OUT   NOCOPY VARCHAR2,
   p_calc_submission_rec IN   cn_calc_submission_pub.calc_submission_rec_type,
   x_loading_status     OUT   NOCOPY VARCHAR2
);


-- Start of Comments
-- API name 	:  Ok_To_Generate_Msg
-- Type		:  Public.
-- Pre-reqs	:  None.
-- Usage	:  Judge whether it is ok to generate message or not
-- Parameters	:

--
-- Version	:  Current version	1.0
--		   Initial version 	1.0
-- IN   p_calc_submission_rec IN   cn_calc_submission_pub.calc_submission_rec_type,
--
-- End of comments
--
FUNCTION Ok_To_Generate_Msg
  (
   p_calc_submission_rec IN   cn_calc_submission_pub.calc_submission_rec_type
   ) RETURN BOOLEAN;

END CN_CALC_SUBMISSION_CUHK ;
 

/
