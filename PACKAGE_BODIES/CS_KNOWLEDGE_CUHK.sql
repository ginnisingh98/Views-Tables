--------------------------------------------------------
--  DDL for Package Body CS_KNOWLEDGE_CUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KNOWLEDGE_CUHK" AS
/* $Header: cschkbb.pls 115.10 2002/12/02 19:43:28 mkettle noship $ */

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
) IS

Begin

   Null;

End Create_Set_And_Elements_Pre;

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
) IS

Begin

   Null;

End Create_Set_And_Elements_Post;

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
) IS
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  x_msg_count := 0;
  x_msg_data := null;
  x_custom_text_query := p_processed_text_query;
END;

FUNCTION OK_To_Launch_workflow
(
  p_set_def_rec         in  CS_Knowledge_PUB.set_def_rec_type,
  p_ele_def_tbl         in  CS_Knowledge_PUB.ele_def_tbl_type
) return Boolean IS

Begin

   Null;

End OK_To_Launch_workflow;




FUNCTION OK_To_Generate_Msg
(
  p_set_def_rec         in  CS_Knowledge_PUB.set_def_rec_type,
  p_ele_def_tbl         in  CS_Knowledge_PUB.ele_def_tbl_type
) return Boolean IS

Begin

   Null;

End OK_To_Generate_Msg;

END CS_Knowledge_CUHK;

/
