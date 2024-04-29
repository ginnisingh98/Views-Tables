--------------------------------------------------------
--  DDL for Package CN_TRANSACTION_LOAD_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_TRANSACTION_LOAD_PUB" AUTHID CURRENT_USER AS
-- $Header: cnploads.pls 120.3 2005/08/10 03:45:53 hithanki noship $

-- Start of Comments
-- API name 	: Load
-- Type		: Public.
-- Pre-reqs	: None.
-- Usage	: Used to load transactions from API table (CN_COMM_LINES_API)
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
--              :  x_loading_status    OUT            VARCHAR2
--              :  x_process_audit_id  OUT            NUMBER
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	:
--               This procedure loads trx from CN_COMM_LINES_API to
--               CN_COMMISSION_HEADERS, update cn_process_batches,
--               and perform transaction classification and rollup.
--
-- Special Notes :
--
-- End of comments


  PROCEDURE load
  (
   p_api_version        IN    NUMBER,
   p_init_msg_list      IN    VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN    VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_salesrep_id        IN    NUMBER,
   p_start_date         IN    DATE,
   p_end_date           IN    DATE,
   p_cls_rol_flag       IN    VARCHAR2,
   p_org_id		IN    NUMBER,
   x_return_status      OUT NOCOPY   VARCHAR2,
   x_msg_count	        OUT NOCOPY   NUMBER,
   x_msg_data	        OUT NOCOPY   VARCHAR2,
   x_loading_status     OUT NOCOPY   VARCHAR2,
   x_process_audit_id   OUT NOCOPY   NUMBER
   );

END cn_transaction_load_pub;

 

/
