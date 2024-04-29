--------------------------------------------------------
--  DDL for Package CN_RT_QUOTA_ASGNS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_RT_QUOTA_ASGNS_PVT" AUTHID CURRENT_USER AS
/* $Header: cnxvrqas.pls 120.1 2005/09/05 05:12:46 rarajara noship $ */

-- Record type

TYPE rate_date_seq_rec_type  IS RECORD
  (
   start_date         cn_rt_quota_asgns.start_date%TYPE := NULL,
   start_date_old     cn_rt_quota_asgns.start_date%TYPE := NULL,
   end_date           cn_rt_quota_asgns.end_date%TYPE   := NULL,
   end_date_old       cn_rt_quota_asgns.end_date%TYPE   := NULL,
   quota_id           cn_rt_quota_asgns.quota_id%TYPE   := NULL,
   rt_quota_asgn_id  cn_rt_quota_asgns.rt_quota_asgn_id%TYPE
                                                        := NULL,
   org_id            cn_rt_quota_asgns.org_id%type:=NULL
   );

--
-- User Defined Quota Rules Record Table Type
--
TYPE rate_date_seq_rec_tbl_type IS TABLE OF  rate_date_seq_rec_type
  INDEX BY BINARY_INTEGER;

G_MISS_RATE_DATE_SEQ_REC_TBL        rate_date_seq_rec_tbl_type ;

-- API name 	: Create RT Quota Asgns
-- Type		: Private.
-- Pre-reqs	: None.
-- Usage	: Used to Call from Form to Create RT Quota Asgns and
--                called from public API ( Plan Element Pub )
-- Desc 	: Procedure to RT Quota Asgns
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- IN         	p_rt_quota_asgns_tbl_rec   IN        rt_quota_asgns_rec_tbl_type,
-- IN           p_quota_name           IN            VARCHAR2
-- OUT		:  x_loading_status    OUT
--                 Detailed Error Message
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- End of comments

PROCEDURE Create_rt_quota_asgns
( 	p_api_version              IN	NUMBER,
  	p_init_msg_list		   IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    	   IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level	   IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL,
	x_return_status		        OUT NOCOPY VARCHAR2,
	x_msg_count		 OUT NOCOPY NUMBER,
	x_msg_data		 OUT NOCOPY VARCHAR2,
        p_quota_name                    IN      cn_quotas.name%TYPE,
        p_org_id												IN			NUMBER,
	p_rt_quota_asgns_rec_tbl        IN      cn_plan_element_pub.rt_quota_asgns_rec_tbl_type
	                                        := cn_plan_element_pub.g_miss_rt_quota_asgns_rec_tbl,
        x_loading_status	 OUT NOCOPY     VARCHAR2,
        x_object_version_number IN OUT NOCOPY NUMBER
);
-- API name 	: Update RT Quota Asgns
-- Type		: Private.
-- Pre-reqs	: None.
-- Usage	: Used to Call from Form to Update RT Quota Asgns
-- Desc 	: Procedure to RT Quota Asgns
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- 		   p_rt_quota_asgns_rec_tbl   rt_quota_asgns_rec_tbl_type
--		   p_quota_name     IN	      VARCHAR2
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- OUT		:  x_loading_status    OUT
--                 Detailed Error Message
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- End of comments
PROCEDURE  Update_rt_quota_asgns
(       p_api_version			IN 	NUMBER,
  	p_init_msg_list		        IN	VARCHAR2 := FND_API.G_FALSE,
	p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
	p_validation_level		IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL,
        x_return_status       	 OUT NOCOPY 	VARCHAR2,
    	x_msg_count	           OUT NOCOPY 	NUMBER,
    	x_msg_data		   OUT NOCOPY 	VARCHAR2,
        p_quota_name                    IN      cn_quotas.name%TYPE,
        p_org_id												IN NUMBER,
    	p_rt_quota_asgns_rec_tbl        IN      cn_plan_element_pub.rt_quota_asgns_rec_tbl_type
	                                        := cn_plan_element_pub.g_miss_rt_quota_asgns_rec_tbl,
    	x_loading_status    	 OUT NOCOPY 	VARCHAR2,
        x_object_version_number IN OUT NOCOPY NUMBER
    ) ;
-- API name 	: Delete RT Quota Asgns
-- Type		: Private.
-- Pre-reqs	: None.
-- Usage	: Used to Call from Form to Update RT Quota Asgns
-- Desc 	: Procedure to RT Quota Asgns
-- Parameters	:
-- IN		:  p_api_version       IN NUMBER      Require
-- 		   p_init_msg_list     IN VARCHAR2    Optional
-- 		   	Default = FND_API.G_FALSE
-- 		   p_commit	       IN VARCHAR2    Optional
-- 		       	Default = FND_API.G_FALSE
-- 		   p_validation_level  IN NUMBER      Optional
-- 		       	Default = FND_API.G_VALID_LEVEL_FULL
-- 		   p_rt_quota_asgns_rec_tbl  rt_quota_asgns_rec_tbl_type
--                 p_quota_name        IN             VARCHAR2
-- OUT		:  x_return_status     OUT	      VARCHAR2(1)
-- 		   x_msg_count	       OUT	      NUMBER
-- 		   x_msg_data	       OUT	      VARCHAR2(2000)
-- OUT		:  x_loading_status    OUT
--                 Detailed Error Message
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- End of comments

PROCEDURE  Delete_rt_quota_asgns
  (       p_api_version		        IN 	NUMBER,
	  p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	  p_commit	    		IN  	VARCHAR2 := FND_API.G_FALSE,
	  p_validation_level		IN  	NUMBER	:=
						FND_API.G_VALID_LEVEL_FULL,
	  x_return_status        OUT NOCOPY 	VARCHAR2,
	  x_msg_count	           OUT NOCOPY 	NUMBER,
	  x_msg_data		   OUT NOCOPY 	VARCHAR2,
          p_quota_name                  IN      cn_quotas.name%TYPE,
          p_org_id											IN      NUMBER,
	  p_rt_quota_asgns_rec_tbl      IN      cn_plan_element_pub.rt_quota_asgns_rec_tbl_type
	                                        := cn_plan_element_pub.g_miss_rt_quota_asgns_rec_tbl,
	  x_loading_status    	 OUT NOCOPY 	VARCHAR2
	  );
END CN_RT_QUOTA_ASGNS_PVT;
 

/
