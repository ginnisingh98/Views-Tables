--------------------------------------------------------
--  DDL for Package CN_TRX_FACTORS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_TRX_FACTORS_PVT" AUTHID CURRENT_USER AS
/* $Header: cnxvtrxs.pls 120.1 2005/09/09 00:07:18 rarajara noship $ */
-- API name 	: Update trx factors
-- Type		: Private.
-- Pre-reqs	: None.
-- Usage	: Used to Call from Form to Update TRX Factors
-- Desc 	: Procedure to TRX Factors
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
--    		   p_validation_level  IN NUMBER      Optional
--    		       	Default = FND_API.G_VALID_LEVEL_FULL
--                 p_quota_name        IN VARCHAR2    Required
--                 p_rev_class_name IN VARCHAR2       Required
--                 p_trx_factor_rec_tbl IN
--                CN_PLAN_ELEMENT_PUB.trx_factor_rec_tbl_type
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- OUT		:  x_loading_status    OUT
--                 Detailed Error Message

-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- End of comments
   PROCEDURE  update_trx_factors
  (
   p_api_version        IN 	NUMBER,
   p_init_msg_list      IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit	        IN  	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level   IN  	NUMBER	 := FND_API.G_VALID_LEVEL_FULL,
   x_return_status      OUT NOCOPY 	VARCHAR2,
   x_msg_count	        OUT NOCOPY 	NUMBER,
   x_msg_data	        OUT NOCOPY 	VARCHAR2,
   p_quota_name	        IN      VARCHAR2,
   p_rev_class_name     IN      VARCHAR2,
   p_trx_factor_rec_tbl IN      CN_PLAN_ELEMENT_PUB.trx_factor_rec_tbl_type
                                  := CN_PLAN_ELEMENT_PUB.G_MISS_TRX_FACTOR_REC_TBL,
   x_loading_status     OUT NOCOPY 	VARCHAR2,
   p_org_id							IN NUMBER
   ) ;

END CN_TRX_FACTORS_PVT;
 

/
