--------------------------------------------------------
--  DDL for Package CS_KNOWLEDGE_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KNOWLEDGE_VUHK" AUTHID CURRENT_USER AS
/* $Header: csvhkbs.pls 115.7 2002/12/02 23:13:11 mkettle noship $ */

PROCEDURE Create_Set_And_Elements_Pre
(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit              in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_set_def_rec         in  CS_Knowledge_PUB.set_def_rec_type,
  p_ele_def_tbl         in  CS_Knowledge_PUB.ele_def_tbl_type,
  x_set_id              OUT NOCOPY number,
  x_element_id_tbl OUT NOCOPY CS_Knowledge_PUB.number15_tbl_type
);

PROCEDURE Create_Set_And_Elements_Post
(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit              in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_set_def_rec         in  CS_Knowledge_PUB.set_def_rec_type,
  p_ele_def_tbl         in  CS_Knowledge_PUB.ele_def_tbl_type,
  x_set_id              OUT NOCOPY number,
  x_element_id_tbl OUT NOCOPY CS_Knowledge_PUB.number15_tbl_type
);


END CS_Knowledge_VUHK;

 

/
