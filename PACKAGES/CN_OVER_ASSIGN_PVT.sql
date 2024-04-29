--------------------------------------------------------
--  DDL for Package CN_OVER_ASSIGN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_OVER_ASSIGN_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvoasgs.pls 115.5 2002/11/21 21:14:33 hlchen ship $

TYPE quota_overassign_rec_type IS RECORD
  ( quota_category_id       cn_srp_quota_cates.quota_category_id%TYPE,
    direct_overassign_pct   NUMBER,
    street_overassign_pct   NUMBER,
    direct_pro_oasg_pct     NUMBER,
    street_pro_oasg_pct     NUMBER,
    direct_pln_oasg_pct     NUMBER,
    street_pln_oasg_pct     NUMBER)
  ;

TYPE quota_overassign_tbl_type IS TABLE OF quota_overassign_rec_type
  INDEX BY BINARY_INTEGER;

-- API name 	: Get_overassign
-- Type	: Public.
-- Pre-reqs	:
-- Usage	:
--
-- Desc 	:
--
--
--
-- Parameters	:
--  IN	:  p_api_version       NUMBER      Require
-- 		   p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
-- 		   p_commit	       VARCHAR2    Optional (FND_API.G_FALSE)
-- 		   p_validation_level  NUMBER      Optional
--                                              (FND_API.G_VALID_LEVEL_FULL)
--  OUT	:  x_return_status     VARCHAR2(1)
-- 		   x_msg_count	       NUMBER
-- 		   x_msg_data	       VARCHAR2(2000)
--  IN	:  p_srp_role_id       NUMBER,     Required
--		   p_org_code          VARCHAR2,   Required
--  OUT	:  x_quota_overassign_tbl quota_overassign_tbl_type
--
--
-- Version	: Current version	1.0
--		  Initial version 	1.0
--
-- Notes	:
--
-- End of comments

PROCEDURE get_overassign
    ( p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,
      p_qm_mgr_srp_group_id   IN  NUMBER ,
      p_org_code              IN  VARCHAR2,
      x_quota_overassign_tbl  OUT NOCOPY quota_overassign_tbl_type

    );


END cn_over_assign_pvt;


 

/
