--------------------------------------------------------
--  DDL for Package CN_PERIOD_QUOTAS_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_PERIOD_QUOTAS_GRP" AUTHID CURRENT_USER as
/* $Header: cnxgprds.pls 120.2 2005/10/19 06:06:14 chanthon ship $ */

-- API name 	: Create_Period_Quotas
-- Type		: Group.
-- Pre-reqs	: None.
-- Usage	: Used to create entry into cn_period_quotas
--
-- Desc 	: Create period Quotas, can be called independently from any oracle
--                applications. currently this program is called from public API
--                and from Forms directly.
--
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Required
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	 Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT VARCHAR2(1)
-- 		   x_msg_count	       OUT NUMBER
-- 		   x_msg_data	       OUT VARCHAR2(2000)
-- 		:  x_loading_status    OUT VARCHAR2(50)
--                 Detailed error code returned from procedure.
-- IN		:  p_quota_name        IN  VARCHAR2    Required
--                 p_period_quotas_rec_tbl
--                 CN_PLAN_ELEMENT_PUB.period_quotas_rec_tbl_type;
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	: Note text
--
-- End of comments

PROCEDURE Create_Period_Quotas
  (
   p_api_version             IN	 NUMBER,
   p_init_msg_list	     IN	 VARCHAR2 := FND_API.G_FALSE,
   p_commit	    	     IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level	     IN  NUMBER   :=    FND_API.G_VALID_LEVEL_FULL,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count		     OUT NOCOPY NUMBER,
   x_msg_data		     OUT NOCOPY VARCHAR2,
   p_quota_name		     IN  VARCHAR2,
   p_period_quotas_rec_tbl   IN  CN_PLAN_ELEMENT_PUB.PERIOD_QUOTAS_REC_TBL_TYPE
			       	 := CN_PLAN_ELEMENT_PUB.G_MISS_PERIOD_QUOTAS_REC_TBL,
   x_loading_status	     OUT NOCOPY VARCHAR2,
   p_is_duplicate             IN VARCHAR2 DEFAULT 'N'
   ) ;

PROCEDURE Update_Period_Quotas
  (
   p_api_version             IN	 NUMBER,
   p_init_msg_list	     IN	 VARCHAR2 := FND_API.G_FALSE,
   p_commit	    	     IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level	     IN  NUMBER   :=    FND_API.G_VALID_LEVEL_FULL,
   x_return_status           OUT NOCOPY VARCHAR2,
   x_msg_count		     OUT NOCOPY NUMBER,
   x_msg_data		     OUT NOCOPY VARCHAR2,
   p_quota_name		     IN  VARCHAR2,
   p_period_quotas_rec_tbl   IN  CN_PLAN_ELEMENT_PUB.PERIOD_QUOTAS_REC_TBL_TYPE
			       	 := CN_PLAN_ELEMENT_PUB.G_MISS_PERIOD_QUOTAS_REC_TBL,
   x_loading_status	     OUT NOCOPY VARCHAR2
   ) ;

END CN_PERIOD_QUOTAS_GRP;
 

/
