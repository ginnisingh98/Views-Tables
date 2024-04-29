--------------------------------------------------------
--  DDL for Package CN_ROLLUP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_ROLLUP_PVT" AUTHID CURRENT_USER as
/* $Header: cnvrolls.pls 120.2 2005/08/02 17:59:45 ymao ship $ */

  TYPE srp_rec_type IS RECORD
    (  salesrep_id         NUMBER(15),
       start_date          DATE,
       end_date            DATE);

  TYPE srp_group_rec_type IS RECORD
    (  salesrep_id         NUMBER(15),
       group_id            NUMBER(15),
       level               NUMBER(15),
       start_date          DATE,
       end_date            DATE);

  TYPE group_rec_type IS RECORD
    (  group_id            NUMBER(15),
       level               NUMBER(15),
       start_date          DATE,
       end_date            DATE);

  TYPE role_rec_type IS RECORD
    (  role_id             NUMBER(15),
       manager_flag        VARCHAR(1),
       start_date          DATE,
       end_date            DATE);

  TYPE group_mem_rec_type IS RECORD
    (  salesrep_id         NUMBER(15),
       role_id             NUMBER(15),
       manager_flag        VARCHAR(1),
       start_date          DATE,
       end_date            DATE
    );

  TYPE active_group_rec_type IS RECORD
    (  group_id         NUMBER(15),
       role_id             NUMBER(15),
       manager_flag        VARCHAR(1),
       start_date          DATE,
       end_date            DATE);

  TYPE srp_tbl_type IS
     TABLE OF srp_rec_type
       INDEX BY BINARY_INTEGER;

  TYPE srp_group_tbl_type IS
     TABLE OF srp_group_rec_type
       INDEX BY BINARY_INTEGER;

  TYPE group_tbl_type IS
     TABLE OF group_rec_type
       INDEX BY BINARY_INTEGER;

  TYPE role_tbl_type IS
     TABLE OF role_rec_type
       INDEX BY BINARY_INTEGER;

  TYPE group_mem_tbl_type IS
     TABLE OF group_mem_rec_type
       INDEX BY BINARY_INTEGER;

  TYPE active_group_tbl_type IS
     TABLE OF active_group_rec_type
       INDEX BY BINARY_INTEGER;


  -- Start of comments
  -- API name 	:
  -- Type	: Private.
  -- Pre-reqs	: None
  -- Usage	:
  --
  -- Desc 	:
  --
  --
  --
  -- Parameters	:
  --  IN	:  p_api_version       NUMBER      Required
  -- 		   p_init_msg_list     VARCHAR2    Optional (FND_API.G_FALSE)
  -- 		   p_commit	       VARCHAR2    Optional (FND_API.G_FALSE)
  -- 		   p_validation_level  NUMBER      Optional (FND_API.G_VALID_LEVEL_FULL)
  --  OUT	:  x_return_status     VARCHAR2(1)
  -- 		   x_msg_count	       NUMBER
  -- 		   x_msg_data	       VARCHAR2(2000)
  --  IN	:
  --
  --
  --  OUT	:
  --
  --
  -- Version	: Current version	1.0
  --		  Initial version 	1.0
  --
  -- Notes	:
  --
  -- End of comments

  PROCEDURE get_active_role
    ( p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,
      p_org_id                IN  NUMBER,
      p_srp                   IN  srp_group_rec_type,
      x_role                  OUT NOCOPY role_tbl_type);

  PROCEDURE get_active_group_member
    ( p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,
      p_org_id                IN  NUMBER,
      p_group                 IN  group_rec_type,
      x_group_mem             OUT NOCOPY group_mem_tbl_type);

  PROCEDURE get_active_group_member
    ( p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,
      p_org_id                IN  NUMBER,
      p_group                 IN  group_tbl_type,
      x_group_mem             OUT NOCOPY srp_group_tbl_type);

  PROCEDURE get_active_group
    ( p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,
      p_org_id                IN  NUMBER,
      p_srp                   IN  srp_rec_type,
      x_active_group          OUT NOCOPY active_group_tbl_type);

  PROCEDURE get_ancestor_group
    ( p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,
      p_group                 IN  group_rec_type,
      x_group                 OUT NOCOPY group_tbl_type);

  PROCEDURE get_descendant_group
    ( p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,
      p_group                 IN  group_rec_type,
      x_group                 OUT NOCOPY group_tbl_type);

  PROCEDURE get_ancestor_salesrep
    ( p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,
      p_org_id                IN  NUMBER,
      p_srp                   IN  srp_group_rec_type,
      x_srp                   OUT NOCOPY srp_group_tbl_type);

  PROCEDURE get_descendant_salesrep
    ( p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,
      p_org_id                IN  NUMBER,
      p_srp                   IN  srp_group_rec_type,
      x_srp                   OUT NOCOPY srp_group_tbl_type);

  PROCEDURE get_descendant_salesrep
    ( p_api_version           IN  NUMBER,
      p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit                IN  VARCHAR2 := FND_API.G_FALSE,
      p_validation_level      IN  VARCHAR2 := FND_API.G_VALID_LEVEL_FULL,
      x_return_status         OUT NOCOPY VARCHAR2,
      x_msg_count             OUT NOCOPY NUMBER,
      x_msg_data              OUT NOCOPY VARCHAR2,
      p_org_id                IN  NUMBER,
      p_srp                   IN  srp_rec_type,
      x_srp                   OUT NOCOPY srp_tbl_type);

END cn_rollup_pvt;

 

/
