--------------------------------------------------------
--  DDL for Package CN_RULESET_PUB_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_RULESET_PUB_VUHK" AUTHID CURRENT_USER as
-- $Header: cnirsets.pls 120.1 2005/06/20 19:48:08 appldev ship $

-------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: create_ruleset_pre
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization before creating a ruleset
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
-- IN		:  p_ruleset_id        IN             CN_Ruleset_PUB.ruleset_rec_type;
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
PROCEDURE create_ruleset_pre
  ( p_api_version           	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status		OUT NOCOPY	VARCHAR2,
    x_msg_count			OUT NOCOPY	NUMBER,
    x_msg_data			OUT NOCOPY	VARCHAR2,
    x_loading_status            OUT NOCOPY      VARCHAR2,
    p_ruleset_rec		IN      CN_Ruleset_PUB.ruleset_rec_type
  );

-------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: create_ruleset_post
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization after creating a ruleset
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
-- IN		:  p_ruleset_id        IN             CN_Ruleset_PUB.ruleset_rec_type;
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
PROCEDURE create_ruleset_post
  ( p_api_version           	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status		OUT NOCOPY	VARCHAR2,
    x_msg_count			OUT NOCOPY	NUMBER,
    x_msg_data			OUT NOCOPY	VARCHAR2,
    x_loading_status            OUT NOCOPY      VARCHAR2,
    p_ruleset_rec		IN      CN_Ruleset_PUB.ruleset_rec_type
  );


-------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: update_ruleset_pre
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization before updating a ruleset
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
-- IN OUT	:  p_old_ruleset_id    IN             CN_Ruleset_PUB.ruleset_rec_type
-- IN OUT	:  p_ruleset_id        IN             CN_Ruleset_PUB.ruleset_rec_type
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
PROCEDURE update_ruleset_pre
  ( p_api_version           	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status		OUT NOCOPY	VARCHAR2,
    x_msg_count			OUT NOCOPY	NUMBER,
    x_msg_data			OUT NOCOPY	VARCHAR2,
    x_loading_status            OUT NOCOPY     VARCHAR2,
    p_old_ruleset_rec		IN OUT NOCOPY  CN_Ruleset_PUB.ruleset_rec_type,
    p_ruleset_rec		IN OUT NOCOPY  CN_Ruleset_PUB.ruleset_rec_type
  );


-------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: update_ruleset_post
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization before updating a ruleset
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
-- IN OUT	:  p_old_ruleset_id    IN             CN_Ruleset_PUB.ruleset_rec_type
-- IN OUT	:  p_ruleset_id        IN             CN_Ruleset_PUB.ruleset_rec_type
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
PROCEDURE update_ruleset_post
  ( p_api_version           	IN	NUMBER,
    p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
    p_validation_level		IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
    x_return_status		OUT NOCOPY	VARCHAR2,
    x_msg_count			OUT NOCOPY	NUMBER,
    x_msg_data			OUT NOCOPY	VARCHAR2,
    x_loading_status            OUT NOCOPY     VARCHAR2,
    p_old_ruleset_rec		IN OUT NOCOPY  CN_Ruleset_PUB.ruleset_rec_type,
    p_ruleset_rec		IN OUT NOCOPY  CN_Ruleset_PUB.ruleset_rec_type
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
    (p_ruleset_rec		IN      CN_Ruleset_PUB.ruleset_rec_type)
RETURN BOOLEAN;


END CN_RULESET_PUB_VUHK;
 

/
