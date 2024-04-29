--------------------------------------------------------
--  DDL for Package CN_PMTSUB_PUB_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PMTSUB_PUB_VUHK" AUTHID CURRENT_USER as
-- $Header: cnipsubs.pls 120.2 2005/10/14 11:04:32 rnagired noship $ --+

-------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: PAY_pre
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization before paying a payrun
--
-- Desc 	:
--
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
-- IN		:  p_payrun_name        IN             cn_payruns.name%TYPE
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
PROCEDURE pay_pre
( 	p_api_version           	IN	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level		IN  	NUMBER   := FND_API.G_VALID_LEVEL_FULL,
	x_return_status		        OUT	NOCOPY VARCHAR2,
	x_msg_count			OUT	NOCOPY NUMBER,
	x_msg_data			OUT	NOCOPY VARCHAR2,
      p_payrun_name                   IN OUT NOCOPY cn_payruns.name%TYPE,
    	p_payrun_id         IN   cn_payruns.payrun_id%TYPE,
      x_loading_status		OUT NOCOPY   VARCHAR2,
	x_status                        OUT NOCOPY      VARCHAR2
);

-------------------------------------------------------------------------------------+
-- Start of comments
-- API name 	: pay_post
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
      x_loading_status		OUT NOCOPY     VARCHAR2,
	x_status                        OUT NOCOPY     VARCHAR2
);

END CN_PMTSUB_PUB_VUHK;
 

/
