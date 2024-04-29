--------------------------------------------------------
--  DDL for Package CS_KNOWLEDGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KNOWLEDGE_GRP" AUTHID CURRENT_USER AS
/* $Header: csgkbs.pls 120.0 2005/06/01 13:09:56 appldev noship $ */
--
-- CONSTANTS
--
  G_PKG_NAME  	     CONSTANT VARCHAR2(50) := 'CS_Knowledge_GRP';
--
-- Public
--
-- Start of comments
--  API Name    : Construct_Text_Query
--  Type        : Public
--
--  Parameters  :
--  IN          :
--	p_api_version			IN	NUMBER		Required
--	p_init_msg_list			IN	VARCHAR2(1)	Optional
--		Default = FND_API.G_FALSE
--	p_commit			IN	VARCHAR2(1)	Optional
--		Default = FND_API.G_FALSE
--	p_validation_level    		IN  	NUMBER		Optional
--		Default = FND_API.G_VALID_LEVEL_FULL
--	p_qry_string  			IN
--		String of keywords
--  	p_search_option  			IN
--		Search option such as and, or, not, theme
--
--  OUT         :
--	x_return_status			OUT	VARCHAR2(1)
--	x_msg_count			OUT	NUMBER
--	x_msg_data			OUT	VARCHAR2(2000)
--  	x_qry_string           		OUT	VARCHAR2(30000)
--
--
--  Version     : Initial Version     1.0
--
--  Notes       : (Post 8/10/01) x_qry_string return result of the construct
--
--
-- End of comments

PROCEDURE Construct_Text_Query(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit              in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_qry_string          in  varchar2,
  p_search_option       in number,
  x_qry_string          OUT NOCOPY varchar2
);

-- Start of comments
--  API Name    : Delete_Set_Link
--  Type        : Group
--  Function    : Delete set_link from set_id, object_code, other_id
--  Pre-reqs    : Must have valid set_id/object_code/other_id
--
--  Parameters  :
--  IN          :
--	p_api_version			IN	NUMBER		Required
--	p_init_msg_list			IN	VARCHAR2(1)	Optional
--		Default = FND_API.G_FALSE
--	p_commit			IN	VARCHAR2(1)	Optional
--		Default = FND_API.G_FALSE
--	p_validation_level    		IN  	NUMBER		Optional
--		Default = FND_API.G_VALID_LEVEL_FULL
--	p_set_id			IN	NUMBER		Required
--	p_object_code			IN	VARCHAR2	Required
--	p_other_id			IN	NUMBER		Required
--  OUT         :
--	x_return_status			OUT	VARCHAR2(1)
--	x_msg_count			OUT	NUMBER
--	x_msg_data			OUT	VARCHAR2(2000)

--
--  Version     : Initial Version     1.0
--
--  Notes       :
--
-- End of comments

PROCEDURE Delete_Set_Link(
  p_api_version	        in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit	        in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count	        OUT NOCOPY number,
  x_msg_data	        OUT NOCOPY varchar2,
  p_set_id              in  number,
  p_object_code         in  varchar2,
  p_other_id            in  number
);

-- Start of comments
--  API Name    : Delete_Element_Link
--  Type        : Group
--  Function    : Delete element_link from set_id, object_code, other_id
--  Pre-reqs    : Must have valid element_id/object_code/other_id
--
--  Parameters  :
--  IN          :
--	p_api_version			IN	NUMBER		Required
--	p_init_msg_list			IN	VARCHAR2(1)	Optional
--		Default = FND_API.G_FALSE
--	p_commit			IN	VARCHAR2(1)	Optional
--		Default = FND_API.G_FALSE
--	p_validation_level    		IN  	NUMBER		Optional
--		Default = FND_API.G_VALID_LEVEL_FULL
--	p_element_id			IN	NUMBER		Required
--	p_object_code			IN	VARCHAR2	Required
--	p_other_id			IN	NUMBER		Required
--  OUT         :
--	x_return_status			OUT	VARCHAR2(1)
--	x_msg_count			OUT	NUMBER
--	x_msg_data			OUT	VARCHAR2(2000)

--
--  Version     : Initial Version     1.0
--
--  Notes       :
--
-- End of comments

PROCEDURE Delete_Element_Link(
  p_api_version	        in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit	        in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count	        OUT NOCOPY number,
  x_msg_data	        OUT NOCOPY varchar2,
  p_element_id          in  number,
  p_object_code         in  varchar2,
  p_other_id            in  number
);

-- Start of comments
--  API Name    : Create_Set_And_Elements
--  Type        : Group
--  Function    : Create a set using given elements
--  Pre-reqs    : Must have valid set/element types
--
--  Parameters  :
--  IN          :
--	p_api_version			IN	NUMBER		Required
--	p_init_msg_list			IN	VARCHAR2(1)	Optional
--		Default = FND_API.G_FALSE
--	p_commit			IN	VARCHAR2(1)	Optional
--		Default = FND_API.G_FALSE
--	p_validation_level    		IN  	NUMBER		Optional
--		Default = FND_API.G_VALID_LEVEL_FULL
--	p_set_def_rec  			IN
--		CS_Knowledge_PUB.set_def_rec_type		Required
--		Definition of the set. Must have set type, status, name.
--  	p_ele_def_tbl  			IN
--  		CS_Knowledge_PUB.ele_def_tbl_type		Required
--		Each record defines an element. If element id is given,
--		it is used, otherwise the api uses other fields to
--		create the element.
--
--  OUT         :
--	x_return_status			OUT	VARCHAR2(1)
--	x_msg_count			OUT	NUMBER
--	x_msg_data			OUT	VARCHAR2(2000)
--  	x_set_id              		OUT	NUMBER
--		The created set id.
--
--
--  Version     : Initial Version     1.0
--
--  Notes       :
--
--
-- End of comments

PROCEDURE Create_Set_And_Elements(
  p_api_version	        in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit	        in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count	        OUT NOCOPY number,
  x_msg_data	        OUT NOCOPY varchar2,
  p_set_def_rec  	in  CS_Knowledge_PUB.set_def_rec_type,
  p_ele_def_tbl  	in  CS_Knowledge_PUB.ele_def_tbl_type,
  x_set_id              OUT NOCOPY number
);


-- Start of comments
--  API Name    : Create_Set_And_Elements
--  Type        : Group
--  Function    : Create a set using given elements
--  Pre-reqs    : Must have valid set/element types
--
--  Parameters  :
--  IN          :
--	p_api_version			IN	NUMBER		Required
--	p_init_msg_list			IN	VARCHAR2(1)	Optional
--		Default = FND_API.G_FALSE
--	p_commit			IN	VARCHAR2(1)	Optional
--		Default = FND_API.G_FALSE
--	p_validation_level    		IN  	NUMBER		Optional
--		Default = FND_API.G_VALID_LEVEL_FULL
--	p_set_def_rec  			IN
--		CS_Knowledge_PUB.set_def_rec_type		Required
--		Definition of the set. Must have set type, status, name.
--  	p_ele_def_tbl  			IN
--  		CS_Knowledge_PUB.ele_def_tbl_type		Required
--		Each record defines an element. If element id is given,
--		it is used, otherwise the api uses other fields to
--		create the element.
--
--  OUT         :
--	x_return_status			OUT	VARCHAR2(1)
--	x_msg_count			OUT	NUMBER
--	x_msg_data			OUT	VARCHAR2(2000)
--  	x_set_id              		OUT	NUMBER
--		The created set id.
--	x_element_id_tbl		OUT	CS_Knowledge_PUB.number15_tbl_type
--		Table of element ids associated with the statements contributed
--
--
--  Version     : Initial Version     1.0
--
--  Notes       : (Post 8/03/00) Contributed element ids passed back
--
--
-- End of comments

PROCEDURE Create_Set_And_Elements(
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



-- Start of comments
--  API Name    : Create_Set
--  Type        : Group
--  Function    : Create a set using given elements
--  Pre-reqs    : Must have valid set/element types
--
--  Parameters  :
--  IN          :
--	p_api_version			IN	NUMBER		Required
--	p_init_msg_list			IN	VARCHAR2(1)	Optional
--		Default = FND_API.G_FALSE
--	p_commit			IN	VARCHAR2(1)	Optional
--		Default = FND_API.G_FALSE
--	p_validation_level    		IN  	NUMBER		Optional
--		Default = FND_API.G_VALID_LEVEL_FULL
--	p_set_def_rec  			IN
--		CS_Knowledge_PUB.set_def_rec_type		Required
--		Definition of the set. Must have set type, status, name.
--  	p_ele_id_tbl          		IN
--		CS_Knowledge_PUB.number15_tbl_type		Required
--		Element ids for creating the solution set.
--
--  OUT         :
--	x_return_status			OUT	VARCHAR2(1)
--	x_msg_count			OUT	NUMBER
--	x_msg_data			OUT	VARCHAR2(2000)
--  	x_set_id              		OUT	NUMBER
--		The created set id.
--
--
--  Version     : Initial Version     1.0
--
--  Notes       :
--
--
-- End of comments

PROCEDURE Create_Set(
  p_api_version	        in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit	        in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count	        OUT NOCOPY number,
  x_msg_data	        OUT NOCOPY varchar2,
  p_set_def_rec         in  CS_Knowledge_PUB.set_def_rec_type,
  p_ele_id_tbl          in  CS_Knowledge_PUB.number15_tbl_type,
  x_set_id              OUT NOCOPY number
);


-- Start of comments
--  API Name    : Create_Element
--  Type        : Group
--  Function    : Create element
--  Pre-reqs    :
--
--  Parameters  :
--  IN          :
--	p_api_version			IN	NUMBER		Required
--	p_init_msg_list			IN	VARCHAR2(1)	Optional
--		Default = FND_API.G_FALSE
--	p_commit			IN	VARCHAR2(1)	Optional
--		Default = FND_API.G_FALSE
--	p_validation_level    		IN  	NUMBER		Optional
--		Default = FND_API.G_VALID_LEVEL_FULL
--	p_ele_def_rec         		IN
--		CS_Knowledge_PUB.ele_def_rec_type		Required
-- 		Definition of element.
--
--  OUT         :
--	x_return_status			OUT	VARCHAR2(1)
--	x_msg_count			OUT	NUMBER
--	x_msg_data			OUT	VARCHAR2(2000)
--  	x_element_id              	OUT	NUMBER
--		The created element id.
--
--
--  Version     : Initial Version     1.0
--
--  Notes       :
--
--
-- End of comments

PROCEDURE Create_Element(
  p_api_version	        in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit	        in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count	        OUT NOCOPY number,
  x_msg_data	        OUT NOCOPY varchar2,
  p_ele_def_rec         in  CS_Knowledge_PUB.ele_def_rec_type,
  x_element_id          OUT NOCOPY number
);

-- Start of comments
--  API Name    : Find_Sets_Matching
--  Type        : Group
--  Function    : Search for sets with elements matching given search string
--  Pre-reqs    :
--
--  Parameters  :
--  IN          :
--	p_api_version		IN	NUMBER		Required
--	p_init_msg_list		IN	VARCHAR2(1)	Optional
--		Default = FND_API.G_FALSE
--	p_validation_level    	IN  	NUMBER		Optional
--		Default = FND_API.G_VALID_LEVEL_FULL
-- 	p_pos_query_str       	IN  	VARCHAR2	Required
--  	p_neg_query_str       	IN  	VARCHAR2	Optional
--		Default = null
--	p_type_id_tbl     	IN
--		CS_Knowledge_PUB.number15_tbl_type	Required
--		Ids of set types to look for.
--  	p_other_criteria  	IN  	VARCHAR2	Optional
--		Default = NULL
--	p_rows			IN	NUMBER		Required
--	p_start_score		IN	NUMBER		Optional
--		Default = NULL
--	p_start_id            	IN	NUMBER		Optional
--		Default = NULL
--
--  OUT         :
--	x_return_status		OUT	VARCHAR2(1)
--	x_msg_count		OUT	NUMBER
--	x_msg_data		OUT	VARCHAR2(2000)
--  	x_set_tbl      		IN OUT 	CS_Knowledge_PUB.set_res_tbl_type
--
--
--  Version     : Initial Version     1.0
--
--  Notes       : Search for sets containing elements matching given
--		  query string.
--                Query string is used to do about() search.
--                Results are returned in x_set_tbl
--		  ordered by descending score and id.
--		  User may specify starting score and id, along with
--		  number of rows, to fetch into result set.
--
--
-- End of comments

PROCEDURE Find_Sets_Matching (
  p_api_version	        in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  --p_commit	        in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count	        OUT NOCOPY number,
  x_msg_data	        OUT NOCOPY varchar2,
  p_pos_query_str       in  varchar2,
  p_neg_query_str       in  varchar2 := null,
  p_type_id_tbl         in  CS_Knowledge_PUB.number15_tbl_type,
  p_other_criteria      in  varchar2 := NULL,
  p_rows                in  number,
  p_start_score         in  number := null,
  p_start_id            in  number := null,
  x_set_tbl      	in OUT NOCOPY CS_Knowledge_PUB.set_res_tbl_type
);

-- Start of comments
--  API Name    : Create_Element_Link
--  Type        : Group
--  Function    : Create element link
--  Pre-reqs    :
--
--  Parameters  :
--  IN          :
--	p_api_version			IN	NUMBER		Required
--	p_init_msg_list			IN	VARCHAR2(1)	Optional
--		Default = FND_API.G_FALSE
--	p_commit			IN	VARCHAR2(1)	Optional
--		Default = FND_API.G_FALSE
--	p_validation_level    		IN  	NUMBER		Optional
--		Default = FND_API.G_VALID_LEVEL_FULL
--	p_element_link_rec   		IN
--		CS_KB_ELEMENT_LINKS%ROWTYPE			Required
--		Definition of element link
--
--  OUT         :
--	x_return_status			OUT	VARCHAR2(1)
--	x_msg_count			OUT	NUMBER
--	x_msg_data			OUT	VARCHAR2(2000)
--  	x_element_link_id              OUT	NUMBER
--		The created id.
--
--  Version     : Initial Version     1.0
--  Notes       :
--
-- End of comments

PROCEDURE Create_Element_Link(
  p_api_version	        in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit	        in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count	        OUT NOCOPY number,
  x_msg_data	        OUT NOCOPY varchar2,
  p_element_link_rec   in  CS_KB_ELEMENT_LINKS%ROWTYPE,
  x_element_link_id   OUT NOCOPY number
);

-- Start of comments
--  API Name    : Create_Set_Link
--  Type        : Group
--  Function    : Create set link
--  Pre-reqs    :
--
--  Parameters  :
--  IN          :
--	p_api_version			IN	NUMBER		Required
--	p_init_msg_list			IN	VARCHAR2(1)	Optional
--		Default = FND_API.G_FALSE
--	p_commit			IN	VARCHAR2(1)	Optional
--		Default = FND_API.G_FALSE
--	p_validation_level    		IN  	NUMBER		Optional
--		Default = FND_API.G_VALID_LEVEL_FULL
--	p_set_link_rec   		IN
--		CS_KB_SET_LINKS%ROWTYPE			Required
--		Definition of set link
--
--  OUT         :
--	x_return_status			OUT	VARCHAR2(1)
--	x_msg_count			OUT	NUMBER
--	x_msg_data			OUT	VARCHAR2(2000)
--  	x_set_link_id              OUT	NUMBER
--		The created id.
--
--  Version     : Initial Version     1.0
--  Notes       :
--
-- End of comments

PROCEDURE Create_Set_Link(
  p_api_version	        in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit	        in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count	        OUT NOCOPY number,
  x_msg_data	        OUT NOCOPY varchar2,
  p_set_link_rec   in  CS_KB_SET_LINKS%ROWTYPE,
  x_set_link_id   OUT NOCOPY number
);

PROCEDURE Update_Set_Link(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit              in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_set_link_rec   in  CS_KB_SET_LINKS%ROWTYPE
);

-- This api is called by java.
-- It takes object params, convert to amv record types and call
-- the record type api.
--
PROCEDURE Specific_Search(
  p_api_version        IN   NUMBER,
  p_init_msg_list      IN   VARCHAR2 := fnd_api.g_false,
  p_validation_level   IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status      OUT NOCOPY  VARCHAR2,
  x_msg_count          OUT NOCOPY  NUMBER,
  x_msg_data           OUT NOCOPY  VARCHAR2,
  p_repository_tbl     IN   cs_kb_varchar100_tbl_type,
  p_search_string      IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_updated_in_days    IN   NUMBER := FND_API.G_MISS_NUM,
   p_check_login_user   IN   VARCHAR2 := FND_API.G_TRUE,
   p_application_id     IN   NUMBER,
   p_area_array         IN   JTF_VARCHAR2_TABLE_4000   := null,
   p_content_array      IN   JTF_VARCHAR2_TABLE_4000   := null,
   p_param_operator_array     IN   JTF_VARCHAR2_TABLE_100   := null,
   p_param_searchstring_array IN   JTF_VARCHAR2_TABLE_400   := null,
   p_user_id            IN   NUMBER := FND_API.G_MISS_NUM,
   p_category_id        IN   JTF_NUMBER_TABLE,
   p_include_subcats    IN   VARCHAR2 := FND_API.G_FALSE,
   p_external_contents  IN   VARCHAR2 := FND_API.G_FALSE,
  p_rows_requested_tbl IN   cs_kb_number_tbl_type,
  p_start_row_pos_tbl  IN   cs_kb_number_tbl_type,
  p_get_total_cnt_flag IN   VARCHAR2 := fnd_api.g_true,
  x_rows_returned_tbl  OUT NOCOPY  cs_kb_number_tbl_type,
  x_next_row_pos_tbl   OUT NOCOPY  cs_kb_number_tbl_type,
  x_total_row_cnt_tbl  OUT NOCOPY  cs_kb_number_tbl_type,
  x_result_array       OUT NOCOPY  cs_kb_result_varray_type,
  p_search_option      IN  NUMBER := NULL

);

-- Start of comments
--  API Name    : Specific_Search
--  Type        : Group
--  Function    : Search MES and SMS
--  Pre-reqs    : Must have SMS and MES
--
--  Parameters  :
--  IN          : p_api_version	        IN	NUMBER		Required
--	   	  p_init_msg_list	IN	VARCHAR2(1)	Optional
--		  	Default = FND_API.G_FALSE
--		  p_validation_level	IN	NUMBER		Optional
--			Default = FND_API.G_VALID_LEVEL_FULL
-- 		  p_repository_tbl      IN
--			cs_kb_varchar100_tbl_type 		Required
--   			valid values are MES, SMS, ALL
--  		  p_search_string       IN   	VARCHAR2        Optional
--                 	:= FND_API.G_MISS_CHAR
--			used for interMedia search on SMS or MES contents.
--  		  p_updated_in_days     IN   	NUMBER 		Optional
--			:= FND_API.G_MISS_NUM
--			days since last updated. For MES.
--    		  p_check_login_user    IN   	VARCHAR2 	Optional
--			:= FND_API.G_TRUE
--			whether or not to check login user's access privilege. For MES.
--    		  p_application_id      IN  	NUMBER		Required
--    		  p_area_array          IN
--			AMV_SEARCH_PVT.amv_char_varray_type  	Optional
--			:= AMV_SEARCH_PVT.amv_char_varray_type()
--			valid values are ITEM, CATEGORY. For MES
--    		  p_content_array       IN
--			AMV_SEARCH_PVT.amv_char_varray_type  	Optional
--			:= AMV_SEARCH_PVT.amv_char_varray_type()
--			valid values are KEYWORD, AUTHOR, TITLE_DESC, CONTENT. for MES
--    		  p_param_array       	IN
--			AMV_SEARCH_PVT.amv_searchpar_varray_type Optional
--			:= AMV_SEARCH_PVT.amv_searchpar_varray_type()
--			For MES. Consists of operator and search string
--			valid values for operator are
--			CAN_CONTAIN, MUST_CONTAIN, MUST_NOT_CONTAIN
--			Do not use this for interMedia search on content.
--			This is only for searching keyword, author, title_desc.
--    		  p_user_id           IN   	NUMBER 		Optional
--			:= FND_API.G_MISS_NUM
--			For MES
--    		  p_category_id       IN
--			AMV_SEARCH_PVT.amv_number_varray_type	Optioanl
--			:= AMV_SEARCH_PVT.amv_number_varray_type()
--			MES category identifier. Empty obj to search all MES categories.
--    		  p_include_subcats   IN   VARCHAR2 		Optional
--			:= FND_API.G_FALSE
--			Include sub categories. MES
--    		  p_external_contents IN   VARCHAR2 		Optional
--			:= FND_API.G_FALSE
--			Include external contents. MES
--  		  p_rows_requested_tbl  IN   cs_kb_number_tbl_type Required
--			Number of rows requested
-- 		  p_start_row_pos_tbl   IN   cs_kb_number_tbl_type Required
--			Start row position
--  		  p_get_total_cnt_flag  IN   VARCHAR2 		Optional
--			:= fnd_api.g_true
--			Whether to get total count
--
--
--  OUT     :
--		  x_return_status	OUT	VARCHAR2(1)
--		  x_msg_count		OUT	NUMBER
--		  x_msg_data		OUT	VARCHAR2(2000)
--  		  x_rows_returned_tbl   OUT  cs_kb_number_tbl_type,
--			Number of rows returned
--  		  x_next_row_pos_tbl    OUT  cs_kb_number_tbl_type,
--			Next row position
--  		  x_total_row_cnt_tbl   OUT  cs_kb_number_tbl_type,
--			Total row count
--  		  x_result_array        OUT  cs_kb_result_varray_type
--
--  Version     : Initial Version     1.0
--
--  Notes       : For object types, use empty objects instead of nulls
--		  for the api(and MES apis) to work correctly.
--
--
-- End of comments
--
PROCEDURE Specific_Search(
  p_api_version        IN   NUMBER,
  p_init_msg_list      IN   VARCHAR2 := fnd_api.g_false,
  p_validation_level   IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status      OUT NOCOPY  VARCHAR2,
  x_msg_count          OUT NOCOPY  NUMBER,
  x_msg_data           OUT NOCOPY  VARCHAR2,
  p_repository_tbl      IN   cs_kb_varchar100_tbl_type,
  p_search_string       IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_updated_in_days     IN   NUMBER := FND_API.G_MISS_NUM,
    p_check_login_user  IN   VARCHAR2 := FND_API.G_TRUE,
    p_application_id    IN   NUMBER,
    p_area_array        IN   AMV_SEARCH_PVT.amv_char_varray_type
                            := AMV_SEARCH_PVT.amv_char_varray_type(),
    p_content_array     IN   AMV_SEARCH_PVT.amv_char_varray_type
                            := AMV_SEARCH_PVT.amv_char_varray_type(),
    p_param_array       IN   AMV_SEARCH_PVT.amv_searchpar_varray_type
                            := AMV_SEARCH_PVT.amv_searchpar_varray_type(),
    p_user_id           IN   NUMBER := FND_API.G_MISS_NUM,
    p_category_id       IN   AMV_SEARCH_PVT.amv_number_varray_type
                            := AMV_SEARCH_PVT.amv_number_varray_type(),
    p_include_subcats   IN   VARCHAR2 := FND_API.G_FALSE,
    p_external_contents IN   VARCHAR2 := FND_API.G_FALSE,
  p_rows_requested_tbl  IN   cs_kb_number_tbl_type,
  p_start_row_pos_tbl   IN   cs_kb_number_tbl_type,
  p_get_total_cnt_flag  IN   VARCHAR2 := fnd_api.g_true,
  x_rows_returned_tbl   OUT NOCOPY  cs_kb_number_tbl_type,
  x_next_row_pos_tbl    OUT NOCOPY  cs_kb_number_tbl_type,
  x_total_row_cnt_tbl   OUT NOCOPY  cs_kb_number_tbl_type,
  x_result_array        OUT NOCOPY  cs_kb_result_varray_type,
  p_search_option      IN  NUMBER := NULL

);


--
-- Main Specific search
-- Same as above. With x_amv_result_array out parameter returned from Amv.
--
PROCEDURE Specific_Search(
  p_api_version        IN   NUMBER,
  p_init_msg_list      IN   VARCHAR2 := fnd_api.g_false,
  p_validation_level   IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status      OUT NOCOPY  VARCHAR2,
  x_msg_count          OUT NOCOPY  NUMBER,
  x_msg_data           OUT NOCOPY  VARCHAR2,
  p_repository_tbl     IN   cs_kb_varchar100_tbl_type,
  p_search_string      IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_updated_in_days    IN   NUMBER := FND_API.G_MISS_NUM,
  p_check_login_user   IN   VARCHAR2 := FND_API.G_TRUE,
  p_application_id     IN   NUMBER,
    p_area_array       IN   AMV_SEARCH_PVT.amv_char_varray_type
                            := AMV_SEARCH_PVT.amv_char_varray_type(),
    p_content_array    IN   AMV_SEARCH_PVT.amv_char_varray_type
                            := AMV_SEARCH_PVT.amv_char_varray_type(),
    p_param_array      IN   AMV_SEARCH_PVT.amv_searchpar_varray_type
                            := AMV_SEARCH_PVT.amv_searchpar_varray_type(),
  p_user_id            IN   NUMBER := FND_API.G_MISS_NUM,
  p_category_id        IN   AMV_SEARCH_PVT.amv_number_varray_type
                            := AMV_SEARCH_PVT.amv_number_varray_type(),
  p_include_subcats    IN   VARCHAR2 := FND_API.G_FALSE,
  p_external_contents  IN   VARCHAR2 := FND_API.G_FALSE,
  p_rows_requested_tbl IN cs_kb_number_tbl_type,
  p_start_row_pos_tbl  IN cs_kb_number_tbl_type,
  p_get_total_cnt_flag IN VARCHAR2 := fnd_api.g_true,
  x_rows_returned_tbl  OUT NOCOPY cs_kb_number_tbl_type,
  x_next_row_pos_tbl   OUT NOCOPY cs_kb_number_tbl_type,
  x_total_row_cnt_tbl  OUT NOCOPY cs_kb_number_tbl_type,
  x_result_array       OUT NOCOPY  cs_kb_result_varray_type,
  x_amv_result_array   OUT NOCOPY  AMV_SEARCH_PVT.amv_searchres_varray_type,
  p_search_option      IN  NUMBER := NULL

);

-- Start of comments
--    API name   : Purge_Knowledge_Links
--    Type       : Group
--    Pre-reqs   : None
--    Function   : Performs a Purge of Knowledge Links for a given object
--    Parameters :
--    IN           p_api_version        Required
--                 p_init_msg_list      Optional - Default False
--                 P_COMMIT             Optional - Default False
--                 P_PROCESSING_SET_ID  Required - Processing Set - identifies rows to be purged
--                 P_OBJECT_TYPE        Required - The Object (FK Jtf_Objects_vl.object_code)
--    OUT        : x_return_status
--                 x_msg_count
--                 x_msg_data
--    Version    : Initial version     1.0
--    Notes      :
-- End of comments
PROCEDURE Purge_Knowledge_Links (
 P_API_VERSION        IN  NUMBER,
 P_INIT_MSG_LIST      IN  VARCHAR2,
 P_COMMIT             IN  VARCHAR2,
 P_PROCESSING_SET_ID  IN  NUMBER,
 P_OBJECT_TYPE        IN  VARCHAR2,
 X_RETURN_STATUS      OUT NOCOPY VARCHAR2,
 X_MSG_COUNT	      OUT NOCOPY NUMBER,
 X_MSG_DATA	          OUT NOCOPY VARCHAR2);


end CS_Knowledge_Grp;

 

/
