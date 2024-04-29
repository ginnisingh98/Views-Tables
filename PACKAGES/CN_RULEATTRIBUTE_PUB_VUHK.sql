--------------------------------------------------------
--  DDL for Package CN_RULEATTRIBUTE_PUB_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_RULEATTRIBUTE_PUB_VUHK" AUTHID CURRENT_USER as
-- $Header: cniratrs.pls 120.1 2005/06/20 18:30:15 appldev ship $

-------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: create_ruleattribute_pre
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization before creating a rule attribute
--
-- Desc 	:
--
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Required
-- 		   p_init_msg_list     IN VARCHAR2    Optional
--					  	      Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	                              Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	                   Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- IN	        :  p_ruleattribute_rec IN             CN_RuleAttribute_PUB.RuleAttribute_rec_type
--
-- OUT		:  x_loading_status    OUT            VARCHAR2(50)
--                 Detailed error code returned from procedure.
--
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	:
--
-- End of comments
--------------------------------------------------------------------------------------+
PROCEDURE create_ruleattribute_pre
 ( p_api_version           	IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
   x_return_status		OUT NOCOPY	VARCHAR2,
   x_msg_count			OUT NOCOPY	NUMBER,
   x_msg_data			OUT NOCOPY	VARCHAR2,
   x_loading_status             OUT NOCOPY     VARCHAR2,
   p_RuleAttribute_rec       	IN      CN_RuleAttribute_PUB.RuleAttribute_rec_type
 );

-------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: create_ruleattribute_post
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization before creating a rule attribute
--
-- Desc 	:
--
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Required
-- 		   p_init_msg_list     IN VARCHAR2    Optional
--					  	      Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	                              Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	                   Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- IN	        :  p_ruleattribute_rec IN             CN_RuleAttribute_PUB.RuleAttribute_rec_type
--
-- OUT		:  x_loading_status    OUT            VARCHAR2(50)
--                 Detailed error code returned from procedure.
--
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	:
--
-- End of comments
--------------------------------------------------------------------------------------+
PROCEDURE create_ruleattribute_post
 ( p_api_version           	IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
   x_return_status		OUT NOCOPY	VARCHAR2,
   x_msg_count			OUT NOCOPY	NUMBER,
   x_msg_data			OUT NOCOPY	VARCHAR2,
   x_loading_status             OUT NOCOPY      VARCHAR2,
   p_RuleAttribute_rec       	IN      CN_RuleAttribute_PUB.RuleAttribute_rec_type
 );

-------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: update_ruleattribute_pre
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization before updating a rule attribute
--
-- Desc 	:
--
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Required
-- 		   p_init_msg_list     IN VARCHAR2    Optional
--					  	      Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	                              Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	                   Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- IN 		:  p_old_ruleattribute_rec IN         CN_RuleAttribute_PUB.RuleAttribute_rec_type
-- IN 		:  p_ruleattribute_rec	   IN         CN_RuleAttribute_PUB.RuleAttribute_rec_type
--
-- OUT		:  x_loading_status    OUT            VARCHAR2(50)
--                 Detailed error code returned from procedure.
--
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	:
--
-- End of comments
--------------------------------------------------------------------------------------+
PROCEDURE update_ruleattribute_pre
  ( p_api_version           	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status		OUT NOCOPY	VARCHAR2,
    x_msg_count			OUT NOCOPY	NUMBER,
    x_msg_data			OUT NOCOPY	VARCHAR2,
    x_loading_status            OUT NOCOPY      VARCHAR2,
    p_old_RuleAttribute_rec   	IN      CN_RuleAttribute_PUB.RuleAttribute_rec_type,
    p_RuleAttribute_rec   	IN      CN_RuleAttribute_PUB.RuleAttribute_rec_type
    );


-------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: update_ruleattribute_post
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization before updating a rule attribute
--
-- Desc 	:
--
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Required
-- 		   p_init_msg_list     IN VARCHAR2    Optional
--					  	      Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	                              Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	                   Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- IN 		:  p_old_ruleattribute_rec IN         CN_RuleAttribute_PUB.RuleAttribute_rec_type
-- IN 		:  p_ruleattribute_rec	   IN         CN_RuleAttribute_PUB.RuleAttribute_rec_type
--
-- OUT		:  x_loading_status    OUT            VARCHAR2(50)
--                 Detailed error code returned from procedure.
--
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	:
--
-- End of comments
--------------------------------------------------------------------------------------+

PROCEDURE update_ruleattribute_post
  ( p_api_version           	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status		OUT NOCOPY	VARCHAR2,
    x_msg_count			OUT NOCOPY	NUMBER,
    x_msg_data			OUT NOCOPY	VARCHAR2,
    x_loading_status            OUT NOCOPY      VARCHAR2,
    p_old_RuleAttribute_rec   	IN      CN_RuleAttribute_PUB.RuleAttribute_rec_type,
    p_RuleAttribute_rec   	IN      CN_RuleAttribute_PUB.RuleAttribute_rec_type
    );


-------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: delete_ruleattribute_pre
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization before deleting a rule attribute
--
-- Desc 	:
--
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Required
-- 		   p_init_msg_list     IN VARCHAR2    Optional
--					  	      Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	                              Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	                   Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- IN 		:  p_ruleattribute_rec IN         CN_RuleAttribute_PUB.RuleAttribute_rec_type
--
-- OUT		:  x_loading_status    OUT            VARCHAR2(50)
--                 Detailed error code returned from procedure.
--
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	:
--
-- End of comments
--------------------------------------------------------------------------------------+
PROCEDURE delete_ruleattribute_pre
  ( p_api_version           	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status		OUT NOCOPY	VARCHAR2,
    x_msg_count			OUT NOCOPY	NUMBER,
    x_msg_data			OUT NOCOPY	VARCHAR2,
    x_loading_status            OUT NOCOPY      VARCHAR2,
    p_ruleattribute_rec   	IN	CN_RuleAttribute_PUB.ruleattribute_rec_type
  );


-------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: delete_ruleattribute_post
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization before deleting a rule attribute
--
-- Desc 	:
--
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Required
-- 		   p_init_msg_list     IN VARCHAR2    Optional
--					  	      Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	                              Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	                   Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- IN 		:  p_ruleattribute_rec IN         CN_RuleAttribute_PUB.RuleAttribute_rec_type
--
-- OUT		:  x_loading_status    OUT            VARCHAR2(50)
--                 Detailed error code returned from procedure.
--
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	:
--
-- End of comments
--------------------------------------------------------------------------------------+
PROCEDURE delete_ruleattribute_post
  ( p_api_version           	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status		OUT NOCOPY	VARCHAR2,
    x_msg_count			OUT NOCOPY	NUMBER,
    x_msg_data			OUT NOCOPY	VARCHAR2,
    x_loading_status            OUT NOCOPY      VARCHAR2,
    p_ruleattribute_rec   	IN	CN_RuleAttribute_PUB.ruleattribute_rec_type
  );


--------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: ok_to_generate_msg
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Function to decide whether message needs to be generated
--
-- Desc 	:
--
-- Parameters	:
-- IN		:
-- OUT		:
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- End of comments
--------------------------------------------------------------------------------------+
  FUNCTION ok_to_generate_msg
    (p_ruleattribute_rec	IN      CN_RuleAttribute_PUB.ruleattribute_rec_type)
 --   (p_rule_name		IN      cn_rules.name%TYPE)
RETURN BOOLEAN;


END CN_RULEATTRIBUTE_PUB_VUHK;
 

/
