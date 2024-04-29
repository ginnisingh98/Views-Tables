--------------------------------------------------------
--  DDL for Package CN_QUOTA_RULES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_QUOTA_RULES_GRP" AUTHID CURRENT_USER as
/* $Header: cnxgqrs.pls 120.3 2005/09/14 03:38:59 rarajara noship $ */

-- API name 	: Create_Quota_Rules
-- Type		: Group.
-- Pre-reqs	: None.
-- Usage	: Used to create entry into cn_quota_rules
--
-- Desc 	: Create quota rules, can be called independently from any oracle
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
-- IN		:  p_quota_name        IN  NUMBER     Required
--		   p_revenue_class_rec_tbl IN         Required
--                                 CN_PLAN_ELEMENT_PUB.revenue_class_rec_tbl_type
-- 		:  p_trx_factor_rec_tbl   IN	      Optional
--                                 CN_PLAN_ELEMENT_PUB.trx_factor_rec_tbl_typ
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	: Note text
--
-- End of comments

PROCEDURE Create_Quota_rules
  (
   p_api_version           	IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count		 OUT NOCOPY NUMBER,
   x_msg_data		 OUT NOCOPY VARCHAR2,
   p_quota_name		        IN      VARCHAR2,
   p_revenue_class_rec_tbl	IN      CN_PLAN_ELEMENT_PUB.REVENUE_CLASS_REC_TBL_TYPE
					     := CN_PLAN_ELEMENT_PUB.G_MISS_REVENUE_CLASS_REC_TBL,
   p_rev_uplift_rec_tbl       IN        cn_plan_element_pub.rev_uplift_rec_tbl_type
					:=  cn_plan_element_pub.G_MISS_REV_UPLIFT_REC_TBL,
   p_trx_factor_rec_tbl         IN      CN_PLAN_ELEMENT_PUB.trx_factor_rec_tbl_type
	                                     := CN_PLAN_ELEMENT_PUB.G_MISS_TRX_FACTOR_REC_TBL,
   x_loading_status	 OUT NOCOPY     VARCHAR2
);

-- API name 	: Update_Quota_Rules
-- Type		: Group.
-- Pre-reqs	: None.
-- Usage	: Used to Update the cn_quota_rules
--
-- Desc 	: Update quota rules, can be called independently from any oracle
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
-- IN		:  p_quota_name        IN  NUMBER     Required
--		   p_revenue_class_rec_tbl IN         Required
--                                 CN_PLAN_ELEMENT_PUB.revenue_class_rec_tbl_type
-- 		:  p_trx_factor_rec_tbl   IN	      Optional
--                                 CN_PLAN_ELEMENT_PUB.trx_factor_rec_tbl_typ
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	: Note text
--
-- End of comments


PROCEDURE Update_Quota_rules
  (
   p_api_version           	IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count		 OUT NOCOPY NUMBER,
   x_msg_data		 OUT NOCOPY VARCHAR2,
   p_quota_name		        IN      VARCHAR2,
   p_revenue_class_rec_tbl	IN      CN_PLAN_ELEMENT_PUB.REVENUE_CLASS_REC_TBL_TYPE
					     := CN_PLAN_ELEMENT_PUB.G_MISS_REVENUE_CLASS_REC_TBL,
   p_trx_factor_rec_tbl         IN      CN_PLAN_ELEMENT_PUB.trx_factor_rec_tbl_type
	                                     := CN_PLAN_ELEMENT_PUB.G_MISS_TRX_FACTOR_REC_TBL,
   x_loading_status	 OUT NOCOPY     VARCHAR2
   );

-- API name 	: Delete_Quota_Rules
-- Type		: Group.
-- Pre-reqs	: None.
-- Usage	: Used to Delete the cn_quota_rules
--
-- Desc 	: Delete quota rules, can be called independently from any oracle
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
-- IN		:  p_quota_name         IN  NUMBER     Required
--		   p_revenue_class_name IN             Required
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	: Note text
--
-- End of comments

PROCEDURE Delete_Quota_rules
 (
   p_api_version           	IN	NUMBER,
   p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
   p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
   p_validation_level		IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count		 OUT NOCOPY NUMBER,
   x_msg_data		 OUT NOCOPY VARCHAR2,
   p_quota_name		        IN      VARCHAR2,
   p_revenue_class_rec_tbl	IN      CN_PLAN_ELEMENT_PUB.REVENUE_CLASS_REC_TBL_TYPE
					     := CN_PLAN_ELEMENT_PUB.G_MISS_REVENUE_CLASS_REC_TBL,
   p_trx_factor_rec_tbl         IN      CN_PLAN_ELEMENT_PUB.trx_factor_rec_tbl_type
	                                     := CN_PLAN_ELEMENT_PUB.G_MISS_TRX_FACTOR_REC_TBL,
   x_loading_status	 OUT NOCOPY     VARCHAR2
   );
END CN_QUOTA_RULES_GRP;
 

/
