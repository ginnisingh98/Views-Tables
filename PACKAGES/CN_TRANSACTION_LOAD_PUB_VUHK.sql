--------------------------------------------------------
--  DDL for Package CN_TRANSACTION_LOAD_PUB_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_TRANSACTION_LOAD_PUB_VUHK" AUTHID CURRENT_USER AS
-- $Header: cniloads.pls 120.3 2005/08/10 03:44:18 hithanki ship $

-- Start of Comments
-- API name 	: Load_Pre
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization before load transactions from API table
--                (CN_COMM_LINES_API)
--                to HEADER table (CN_COMMISSION_HEADERS)
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		:  p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		:  p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		:  p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		:  x_msg_count	       OUT	      NUMBER
-- 		:  x_msg_data	       OUT	      VARCHAR2(2000)
--              :  x_loading_status         OUT            VARCHAR2
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes
--
--
-- Special Notes :
--
-- End of comments

  PROCEDURE Load_Pre
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   x_loading_status     OUT NOCOPY   VARCHAR2
   );



 -- Start of Comments
-- API name 	: Load_Post
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Customization after load transactions from API table
--                (CN_COMM_LINES_API)
--                to HEADER table (CN_COMMISSION_HEADERS)
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		:  p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		:  p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		:  p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		:  x_msg_count	       OUT	      NUMBER
-- 		:  x_msg_data	       OUT	      VARCHAR2(2000)
--              :  x_loading_status         OUT            VARCHAR2
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes
--
--
-- Special Notes :
--
-- End of comments

  PROCEDURE Load_Post
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   x_loading_status     OUT NOCOPY   VARCHAR2
   );


END cn_transaction_load_pub_vuhk;

 

/
