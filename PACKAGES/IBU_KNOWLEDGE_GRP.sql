--------------------------------------------------------
--  DDL for Package IBU_KNOWLEDGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBU_KNOWLEDGE_GRP" AUTHID CURRENT_USER AS
/* $Header: ibugkbs.pls 120.0 2005/09/12 10:17:12 ktma noship $ */



--
-- CONSTANTS
--

  G_PKG_NAME  	     CONSTANT VARCHAR2(50) := 'IBU_Knowledge_GRP';

-- This api is called by java.
-- It takes object params, convert to amv record types and call
-- the record type api.
--
PROCEDURE Specific_Search(
  p_api_version        IN   NUMBER,
  p_init_msg_list      IN   VARCHAR2 := fnd_api.g_false,
  p_validation_level   IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status      OUT  NOCOPY VARCHAR2,
  x_msg_count          OUT  NOCOPY NUMBER,
  x_msg_data           OUT  NOCOPY VARCHAR2,
  p_repository_tbl     IN   cs_kb_varchar100_tbl_type,
  p_search_string      IN   VARCHAR2 := NULL,
  p_updated_in_days    IN   NUMBER := NULL,
   p_check_login_user   IN   VARCHAR2 := FND_API.G_TRUE,
   p_application_id     IN   NUMBER,
   p_area_array         IN   JTF_VARCHAR2_TABLE_4000   := null,
   p_content_array      IN   JTF_VARCHAR2_TABLE_4000   := null,
   p_param_operator_array     IN   JTF_VARCHAR2_TABLE_100   := null,
   p_param_searchstring_array IN   JTF_VARCHAR2_TABLE_400   := null,
   p_user_id            IN   NUMBER := NULL,
   p_category_id        IN   JTF_NUMBER_TABLE,
   p_include_subcats    IN   VARCHAR2 := FND_API.G_FALSE,
   p_external_contents  IN   VARCHAR2 := FND_API.G_FALSE,
  p_rows_requested_tbl IN   cs_kb_number_tbl_type,
  p_start_row_pos_tbl  IN   cs_kb_number_tbl_type,
  p_get_total_cnt_flag IN   VARCHAR2 := fnd_api.g_true,
  x_rows_returned_tbl  OUT  NOCOPY cs_kb_number_tbl_type,
  x_next_row_pos_tbl   OUT  NOCOPY cs_kb_number_tbl_type,
  x_total_row_cnt_tbl  OUT  NOCOPY cs_kb_number_tbl_type,
  x_result_array       OUT  NOCOPY cs_kb_result_varray_type
);

--
-- Main Specific search
-- Same as above. With x_amv_result_array out parameter returned from Amv.
--
PROCEDURE Specific_Search(
  p_api_version        IN   NUMBER,
  p_init_msg_list      IN   VARCHAR2 := fnd_api.g_false,
  p_validation_level   IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status      OUT  NOCOPY VARCHAR2,
  x_msg_count          OUT  NOCOPY NUMBER,
  x_msg_data           OUT  NOCOPY VARCHAR2,
  p_repository_tbl     IN   cs_kb_varchar100_tbl_type,
  p_search_string      IN   VARCHAR2 := NULL,
  p_updated_in_days    IN   NUMBER := NULL,
  p_check_login_user   IN   VARCHAR2 := FND_API.G_TRUE,
  p_application_id     IN   NUMBER,
    p_area_array       IN   AMV_SEARCH_PVT.amv_char_varray_type
                            := AMV_SEARCH_PVT.amv_char_varray_type(),
    p_content_array    IN   AMV_SEARCH_PVT.amv_char_varray_type
                            := AMV_SEARCH_PVT.amv_char_varray_type(),
    p_param_array      IN   AMV_SEARCH_PVT.amv_searchpar_varray_type
                            := AMV_SEARCH_PVT.amv_searchpar_varray_type(),
  p_user_id            IN   NUMBER := NULL,
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
  x_result_array       OUT  NOCOPY cs_kb_result_varray_type,
  x_amv_result_array   OUT  NOCOPY AMV_SEARCH_PVT.amv_searchres_varray_type
);


end IBU_Knowledge_Grp;

 

/
