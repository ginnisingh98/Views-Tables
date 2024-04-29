--------------------------------------------------------
--  DDL for Package CN_PMTSUB_PUB_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PMTSUB_PUB_CUHK" AUTHID CURRENT_USER as
-- $Header: cncpsubs.pls 120.1 2005/10/14 11:30:50 rnagired noship $ --+

-------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: Pay_pre
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization before paying a payrun
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
-- IN		:  p_payrun_name       IN             cn_payruns.name%TYPE
--
-- OUT		:  x_loading_status    OUT            VARCHAR2(50)
--                 Detailed error code returned from procedure.
--
-- OUT		:  x_status           OUT	      VARCHAR2(50)
--		      Return Sql Statement Status ( VALID/INVALID)
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	:
--
-- End of comments
--------------------------------------------------------------------------------------+
PROCEDURE Pay_pre
( 	p_api_version           	IN	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		        OUT	NOCOPY VARCHAR2,
	x_msg_count			OUT	NOCOPY NUMBER,
	x_msg_data			OUT	NOCOPY  VARCHAR2,
      p_payrun_name                   IN OUT NOCOPY  cn_payruns.name%TYPE,
    	p_payrun_id         IN   cn_payruns.payrun_id%TYPE,
      x_loading_status		OUT   NOCOPY   VARCHAR2,
	x_status                        OUT   NOCOPY   VARCHAR2
);

-------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: Pay_post
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization after paying a payrun
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
-- IN		:  p_payrun_name       IN             cn_payruns.name%TYPE
--
-- OUT		:  x_loading_status    OUT            VARCHAR2(50)
--                 Detailed error code returned from procedure.
--
-- OUT		:  x_status           OUT	      VARCHAR2(50)
--		      Return Sql Statement Status ( VALID/INVALID)
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	:
--
-- End of comments
--------------------------------------------------------------------------------------+
PROCEDURE Pay_post
( 	p_api_version           	IN	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		        OUT	NOCOPY VARCHAR2,
	x_msg_count			OUT	NOCOPY NUMBER,
	x_msg_data			OUT	NOCOPY VARCHAR2,
      p_payrun_name                   IN      cn_payruns.name%TYPE,
    	p_payrun_id         IN   cn_payruns.payrun_id%TYPE,
      x_loading_status		OUT     NOCOPY VARCHAR2,
	x_status                        OUT     NOCOPY VARCHAR2
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
    (p_payrun_name           IN      cn_payruns.name%TYPE)
RETURN BOOLEAN;


END CN_PMTSUB_PUB_CUHK;
 

/
