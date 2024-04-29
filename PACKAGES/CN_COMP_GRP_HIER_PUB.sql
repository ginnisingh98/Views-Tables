--------------------------------------------------------
--  DDL for Package CN_COMP_GRP_HIER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COMP_GRP_HIER_PUB" AUTHID CURRENT_USER AS
-- $Header: cnpcghrs.pls 115.3 2002/01/28 20:02:22 pkm ship      $
-- cg_salesrep_id will keep comp_group_id as well as salesrep_id
TYPE comp_group_rec IS RECORD(
	level				VARCHAR2(10),
	cg_salesrep_name		VARCHAR2(80),
     	cg_salesrep_id			NUMBER,
	parent_comp_group_id		NUMBER,
	grp_or_name_flag		VARCHAR2(10),
	role_name			VARCHAR2(80),
	role_id				NUMBER,
	start_date_active		DATE,
	end_date_active			DATE,
	start_cg_id			NUMBER,
	end_cg_id			NUMBER,
	image				VARCHAR2(10),
	expand				VARCHAR2(10));

TYPE comp_group_tbl IS TABLE OF comp_group_rec
INDEX BY BINARY_INTEGER;

PROCEDURE get_comp_group_hier(
     p_api_version              IN   NUMBER,
     p_init_msg_list            IN   VARCHAR2 := FND_API.G_FALSE,
     p_validation_level         IN   VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
     p_salesrep_id              IN   NUMBER ,
     p_comp_group_id            IN   NUMBER,
     p_focus_cg_id              IN   NUMBER,
     p_expand                   IN   CHAR,
     p_date                     IN   DATE,
     x_mgr_tbl                  OUT  comp_group_tbl,
     l_mgr_count                OUT  NUMBER,
     x_period_year              OUT  VARCHAR2,
     x_return_status            OUT  VARCHAR2,
     x_msg_count                OUT  NUMBER,
     x_msg_data                 OUT  VARCHAR2,
     x_loading_status           OUT  VARCHAR2);

END cn_comp_grp_hier_pub;

 

/
