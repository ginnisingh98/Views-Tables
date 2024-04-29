--------------------------------------------------------
--  DDL for Package CS_KNOWLEDGE_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KNOWLEDGE_CUHK" AUTHID CURRENT_USER AS
/* $Header: cschkbs.pls 115.11 2002/12/02 19:42:43 mkettle noship $ */

PROCEDURE Create_Set_And_Elements_Pre(
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

PROCEDURE Create_Set_And_Elements_Post(
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

PROCEDURE Text_Query_Rewrite_Post
(
  p_api_version          in  number,
  p_init_msg_list        in  varchar2 := FND_API.G_FALSE,
  p_commit               in  varchar2 := FND_API.G_FALSE,
  p_validation_level     in  number := FND_API.G_VALID_LEVEL_FULL,
  x_return_status        OUT NOCOPY varchar2,
  x_msg_count            OUT NOCOPY number,
  x_msg_data             OUT NOCOPY varchar2,
  p_raw_query_text       in varchar2,
  p_processed_text_query in varchar2,
  p_search_option        in number,
  x_custom_text_query    OUT NOCOPY varchar2
);


FUNCTION OK_To_Launch_workflow
(
  p_set_def_rec         in  CS_Knowledge_PUB.set_def_rec_type,
  p_ele_def_tbl         in  CS_Knowledge_PUB.ele_def_tbl_type
) return Boolean;



FUNCTION OK_To_Generate_Msg
(
  p_set_def_rec         in  CS_Knowledge_PUB.set_def_rec_type,
  p_ele_def_tbl         in  CS_Knowledge_PUB.ele_def_tbl_type
) return Boolean;



END CS_Knowledge_CUHK;

 

/
