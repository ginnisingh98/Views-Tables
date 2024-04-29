--------------------------------------------------------
--  DDL for Package CN_RULE_PUB_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_RULE_PUB_VUHK" AUTHID CURRENT_USER as
-- $Header: cnirules.pls 120.1 2005/06/20 20:03:11 appldev ship $

-------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: create_rule_pre
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization before creating a rule
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
-- IN OUT       :  p_rule_rec	       IN OUT         CN_Rule_PUB.rule_rec_type
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
PROCEDURE create_rule_pre
  ( p_api_version           	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status		OUT NOCOPY	VARCHAR2,
    x_msg_count			OUT NOCOPY	NUMBER,
    x_msg_data			OUT NOCOPY	VARCHAR2,
    x_loading_status            OUT NOCOPY      VARCHAR2,
    p_rule_rec			IN OUT NOCOPY	CN_Rule_PUB.rule_rec_type
  );

-------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: create_rule_post
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization before creating a rule
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
-- IN OUT       :  p_rule_rec	       IN OUT         CN_Rule_PUB.rule_rec_type
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
PROCEDURE create_rule_post
  ( p_api_version           	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status             OUT NOCOPY      VARCHAR2,
    x_msg_count                 OUT NOCOPY      NUMBER,
    x_msg_data                  OUT NOCOPY      VARCHAR2,
    x_loading_status            OUT NOCOPY      VARCHAR2,
    p_rule_rec			IN OUT NOCOPY	CN_Rule_PUB.rule_rec_type
  );

-------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: update_rule_pre
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization before updating a rule
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
-- IN OUT	:  p_old_rule_id	IN            CN_Rule_PUB.rule_rec_type
-- IN OUT	:  p_rule_id		IN            CN_Rule_PUB.rule_rec_type
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
PROCEDURE update_rule_pre
  ( p_api_version           	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status             OUT NOCOPY      VARCHAR2,
    x_msg_count                 OUT NOCOPY      NUMBER,
    x_msg_data                  OUT NOCOPY      VARCHAR2,
    x_loading_status            OUT NOCOPY      VARCHAR2,
    p_old_rule_rec		IN OUT NOCOPY  CN_Rule_PUB.rule_rec_type,
    p_rule_rec			IN OUT NOCOPY  CN_Rule_PUB.rule_rec_type
    );

-------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: update_rule_post
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization before updating a rule
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
-- IN OUT	:  p_old_ruleset_id	IN OUT	      CN_Rule_PUB.rule_rec_type
-- IN OUT	:  p_ruleset_id		IN OUT	      CN_Rule_PUB.rule_rec_type
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
PROCEDURE update_rule_post
  ( p_api_version           	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status             OUT NOCOPY      VARCHAR2,
    x_msg_count                 OUT NOCOPY      NUMBER,
    x_msg_data                  OUT NOCOPY      VARCHAR2,
    x_loading_status            OUT NOCOPY      VARCHAR2,
    p_old_rule_rec		IN OUT NOCOPY  CN_Rule_PUB.rule_rec_type,
    p_rule_rec			IN OUT NOCOPY  CN_Rule_PUB.rule_rec_type
    );

-------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: delete_rule_pre
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization before deleting a rule
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
-- 		:  p_rule_name		IN		cn_rules.name%TYPE,
--		:  p_ruleset_name	IN		cn_rulesets.name%TYPE,
--		:  p_ruleset_start_date	IN		cn_rulesets.start_date%TYPE,
--		:  p_ruleset_end_date	IN		cn_rulesets.end_date%TYPE
--
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
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
PROCEDURE delete_rule_pre
  ( p_api_version           	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status             OUT NOCOPY      VARCHAR2,
    x_msg_count                 OUT NOCOPY      NUMBER,
    x_msg_data                  OUT NOCOPY      VARCHAR2,
    x_loading_status            OUT NOCOPY      VARCHAR2,
    p_rule_name			IN	cn_rules.name%TYPE,
    p_ruleset_name              IN      cn_rulesets.name%TYPE,
    p_ruleset_start_date        IN      cn_rulesets.start_date%TYPE,
    p_ruleset_end_date          IN      cn_rulesets.end_date%TYPE
    );


-------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: delete_rule_post
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization before deleting a rule
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
-- 		:  p_rule_name		IN		cn_rules.name%TYPE,
--		:  p_ruleset_name	IN		cn_rulesets.name%TYPE,
--		:  p_ruleset_start_date	IN		cn_rulesets.start_date%TYPE,
--		:  p_ruleset_end_date	IN		cn_rulesets.end_date%TYPE
--
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
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
PROCEDURE delete_rule_post
  ( p_api_version           	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status             OUT NOCOPY      VARCHAR2,
    x_msg_count                 OUT NOCOPY      NUMBER,
    x_msg_data                  OUT NOCOPY      VARCHAR2,
    x_loading_status            OUT NOCOPY      VARCHAR2,
    p_rule_name			IN	cn_rules.name%TYPE,
    p_ruleset_name              IN      cn_rulesets.name%TYPE,
    p_ruleset_start_date        IN      cn_rulesets.start_date%TYPE,
    p_ruleset_end_date          IN      cn_rulesets.end_date%TYPE
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
    (p_rule_name		IN      VARCHAR2)
  RETURN BOOLEAN;


END CN_RULE_PUB_VUHK;
 

/
