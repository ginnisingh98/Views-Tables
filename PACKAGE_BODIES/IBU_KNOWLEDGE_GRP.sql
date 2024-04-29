--------------------------------------------------------
--  DDL for Package Body IBU_KNOWLEDGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBU_KNOWLEDGE_GRP" AS
/* $Header: ibugkbb.pls 120.0 2005/09/12 10:17:38 ktma noship $ */

-- ========================================================================================
PROCEDURE Specific_Search_Mes(
  p_api_version        IN   NUMBER,
  p_init_msg_list      IN   VARCHAR2 := fnd_api.g_false,
  p_validation_level   IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status      OUT  NOCOPY VARCHAR2,
  x_msg_count          OUT  NOCOPY NUMBER,
  x_msg_data           OUT  NOCOPY VARCHAR2,
  p_search_string      IN   VARCHAR2 := NULL,
  p_updated_in_days    IN   NUMBER := NULL,
    p_check_login_user  IN   VARCHAR2 := FND_API.G_TRUE,
    p_application_id    IN   NUMBER,
    p_area_array        IN   AMV_SEARCH_PVT.amv_char_varray_type
                            := null, --amv_search_grp.Default_AreaArray,
    p_content_array     IN   AMV_SEARCH_PVT.amv_char_varray_type
                            := null, --amv_search_grp.Default_ContentArray,
    p_param_array       IN   AMV_SEARCH_PVT.amv_searchpar_varray_type,
    p_user_id           IN   NUMBER := NULL,
    p_category_id       IN   AMV_SEARCH_PVT.amv_number_varray_type,
    p_include_subcats   IN      VARCHAR2 := FND_API.G_FALSE,
    p_external_contents IN      VARCHAR2 := FND_API.G_FALSE,
  p_rows_requested IN NUMBER,
  p_start_row_pos  IN NUMBER := 1,
  p_get_total_cnt_flag IN VARCHAR2 := fnd_api.g_false,
  x_rows_returned OUT NOCOPY NUMBER,
  x_next_row_pos OUT NOCOPY NUMBER,
  x_total_row_cnt OUT NOCOPY NUMBER,
  x_result_array       IN OUT  NOCOPY cs_kb_result_varray_type,
  x_amv_result_array   OUT  NOCOPY AMV_SEARCH_PVT.amv_searchres_varray_type
) is
  l_amv_req_obj AMV_SEARCH_PVT.amv_request_obj_type;
  l_amv_ret_obj AMV_SEARCH_PVT.amv_return_obj_type;
  l_amv_res_array AMV_SEARCH_PVT.amv_searchres_varray_type;
  l_ret_cnt pls_integer :=0;
   l_search_string VARCHAR2(150) := p_search_string;
   l_updated_in_days NUMBER := p_updated_in_days;
   l_user_id NUMBER := p_user_id;
begin
  --  x_result_array := cs_kb_result_varray_type();
null;
   -- check for G_MISS* per standard
   if l_search_string is null or l_search_string = FND_API.G_MISS_CHAR then
    l_search_string := FND_API.G_MISS_CHAR;
   end if;
   if l_updated_in_days is null or l_updated_in_days = FND_API.G_MISS_NUM then
    l_updated_in_days := FND_API.G_MISS_NUM;
   end if;
   if l_user_id is null or l_user_id = FND_API.G_MISS_NUM then
    l_user_id := FND_API.G_MISS_NUM;
   end if;

   l_amv_req_obj.records_requested := p_rows_requested;
   l_amv_req_obj.start_record_position :=p_start_row_pos;
   l_amv_req_obj.return_total_count_flag :=p_get_total_cnt_flag;

   AMV_SEARCH_GRP.Content_Search(
      p_api_version => p_api_version,
      p_init_msg_list => p_init_msg_list,
      p_validation_level => p_validation_level,
      x_return_status => x_return_status,
      x_msg_count => x_msg_count,
      x_msg_data => x_msg_data,
      p_check_login_user => p_check_login_user,
      p_application_id => p_application_id,
      p_area_array => p_area_array,
      p_content_array => p_content_array,
      p_param_array  => p_param_array,
      p_imt_string   => l_search_string,
      p_days => l_updated_in_days,
      p_user_id => l_user_id,
      p_category_id	=> p_category_id,
      p_include_subcats => p_include_subcats,
      p_external_contents => p_external_contents,
      p_request_obj =>  l_amv_req_obj,
      x_return_obj  =>  l_amv_ret_obj,
      x_searchres_array  => l_amv_res_array);

    x_amv_result_array := l_amv_res_array;

    if(x_return_status = FND_API.G_RET_STS_SUCCESS) then

      x_rows_returned
          := l_amv_ret_obj.returned_record_count;
      x_next_row_pos
          := l_amv_ret_obj.next_record_position;
      x_total_row_cnt
          := l_amv_ret_obj.total_record_count;

      l_ret_cnt :=l_amv_ret_obj.returned_record_count;
      if(l_ret_cnt> 0) then

        x_result_array.EXTEND(l_ret_cnt);
        for i in 1..l_ret_cnt loop
          x_result_array(i) := cs_kb_result_obj_type(
              l_amv_res_array(i).score,
              l_amv_res_array(i).area_id,
              l_amv_res_array(i).title,
              l_amv_res_array(i).user1,
              l_amv_res_array(i).url_string,
              l_amv_res_array(i).description, 'MES', null);
        end loop;

      end if;
    end if;

end Specific_Search_Mes;
-- ========================================================================================
--
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
)is
l_param_array   AMV_SEARCH_PVT.amv_searchpar_varray_type
                := AMV_SEARCH_PVT.amv_searchpar_varray_type();
l_area_array    AMV_SEARCH_PVT.amv_char_varray_type
                := AMV_SEARCH_PVT.amv_char_varray_type();
l_content_array AMV_SEARCH_PVT.amv_char_varray_type
                := AMV_SEARCH_PVT.amv_char_varray_type();
l_category_id AMV_SEARCH_PVT.amv_number_varray_type
              := AMV_SEARCH_PVT.amv_number_varray_type();
l_amv_result_array AMV_SEARCH_PVT.amv_searchres_varray_type;
i1 pls_integer;
   l_search_string VARCHAR2(150) := p_search_string;
   l_updated_in_days NUMBER := p_updated_in_days;
   l_user_id NUMBER := p_user_id;
begin
   -- check for G_MISS* per standard
   if l_search_string is null or l_search_string = FND_API.G_MISS_CHAR then
    l_search_string := FND_API.G_MISS_CHAR;
   end if;
   if l_updated_in_days is null or l_updated_in_days = FND_API.G_MISS_NUM then
    l_updated_in_days := FND_API.G_MISS_NUM;
   end if;
   if l_user_id is null or l_user_id = FND_API.G_MISS_NUM then
    l_user_id := FND_API.G_MISS_NUM;
   end if;

  -- convert to amv record types

  if(p_param_operator_array is not null and
     p_param_operator_array.COUNT>0) then
    i1 := p_param_operator_array.FIRST;
    while i1 is not null loop
      l_param_array.EXTEND;
      l_param_array(i1).operator := p_param_operator_array(i1);
      l_param_array(i1).search_string := p_param_searchstring_array(i1);
      i1 := p_param_operator_array.NEXT(i1);
    end loop;
  end if;

  if(p_area_array is not null and p_area_array.COUNT>0) then
    i1 := p_area_array.FIRST;
    while i1 is not null loop
      l_area_array.EXTEND;
      l_area_array(i1) := p_area_array(i1);
      i1 := p_area_array.NEXT(i1);
    end loop;
  end if;

  if(p_content_array is not null and p_content_array.COUNT>0) then
    i1 := p_content_array.FIRST;
    while i1 is not null loop
      l_content_array.EXTEND;
      l_content_array(i1) := p_content_array(i1);
      i1 := p_content_array.NEXT(i1);
    end loop;
  end if;

  if(p_category_id is not null and p_category_id.COUNT>0) then
    i1 := p_category_id.FIRST;
    while i1 is not null loop
      l_category_id.EXTEND;
      l_category_id(i1) := p_category_id(i1);
      i1 := p_category_id.NEXT(i1);
    end loop;
  end if;

  Specific_Search(
        p_api_version => p_api_version,
        p_init_msg_list => p_init_msg_list,
        p_validation_level => p_validation_level,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data,
        p_repository_tbl => p_repository_tbl,
        p_search_string => l_search_string,
        p_updated_in_days => l_updated_in_days,
        p_check_login_user => p_check_login_user,
        p_application_id => p_application_id,
        p_area_array => l_area_array,
        p_content_array => l_content_array,
        p_param_array  => l_param_array,
        p_user_id => l_user_id,
        p_category_id	=> l_category_id,
        p_include_subcats => p_include_subcats,
        p_external_contents => p_external_contents,
        p_rows_requested_tbl => p_rows_requested_tbl,
        p_start_row_pos_tbl  => p_start_row_pos_tbl,
        p_get_total_cnt_flag => p_get_total_cnt_flag,
        x_rows_returned_tbl => x_rows_returned_tbl,
        x_next_row_pos_tbl => x_next_row_pos_tbl,
        x_total_row_cnt_tbl => x_total_row_cnt_tbl,
        x_result_array => x_result_array,
        x_amv_result_array => l_amv_result_array);

end Specific_Search;

-- ===========================================================================
--
-- Main Specific search
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
    p_check_login_user  IN   VARCHAR2 := FND_API.G_TRUE,
    p_application_id    IN   NUMBER,
   p_area_array         IN   AMV_SEARCH_PVT.amv_char_varray_type
                            := AMV_SEARCH_PVT.amv_char_varray_type(),
   p_content_array      IN   AMV_SEARCH_PVT.amv_char_varray_type
                            := AMV_SEARCH_PVT.amv_char_varray_type(),
   p_param_array        IN   AMV_SEARCH_PVT.amv_searchpar_varray_type
                            := AMV_SEARCH_PVT.amv_searchpar_varray_type(),
    p_user_id           IN   NUMBER := NULL,
    p_category_id       IN   AMV_SEARCH_PVT.amv_number_varray_type
                            :=AMV_SEARCH_PVT.amv_number_varray_type(),
    p_include_subcats   IN      VARCHAR2 := FND_API.G_FALSE,
    p_external_contents IN      VARCHAR2 := FND_API.G_FALSE,
  p_rows_requested_tbl IN cs_kb_number_tbl_type,
  p_start_row_pos_tbl  IN cs_kb_number_tbl_type,
  p_get_total_cnt_flag IN VARCHAR2 := fnd_api.g_true,
  x_rows_returned_tbl  OUT NOCOPY cs_kb_number_tbl_type,
  x_next_row_pos_tbl   OUT NOCOPY cs_kb_number_tbl_type,
  x_total_row_cnt_tbl  OUT NOCOPY cs_kb_number_tbl_type,
  x_result_array       OUT  NOCOPY cs_kb_result_varray_type,
  x_amv_result_array   OUT  NOCOPY AMV_SEARCH_PVT.amv_searchres_varray_type
)is
  l_api_name	CONSTANT varchar2(30)	:= 'Specific_Search';
  l_api_version CONSTANT number 	:= 1.0;
  ind           pls_integer;  --index number
   l_search_string VARCHAR2(150) := p_search_string;
   l_updated_in_days NUMBER := p_updated_in_days;
   l_user_id NUMBER := p_user_id;

begin
  savepoint Specific_Search_GRP;

   -- check for G_MISS* per standard
   if l_search_string is null or l_search_string = FND_API.G_MISS_CHAR then
    l_search_string := FND_API.G_MISS_CHAR;
   end if;
   if l_updated_in_days is null or l_updated_in_days = FND_API.G_MISS_NUM then
    l_updated_in_days := FND_API.G_MISS_NUM;
   end if;
   if l_user_id is null or l_user_id = FND_API.G_MISS_NUM then
    l_user_id := FND_API.G_MISS_NUM;
   end if;

  if not FND_API.Compatible_API_Call(
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME) then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

  if FND_API.to_Boolean(p_init_msg_list) then
    FND_MSG_PUB.initialize;
  end if;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
-- -- -- -- begin my code -- -- -- -- --
  --  x_row_return_obj := cs_kb_rowret_obj_type(0, 0, 0);

  -- this same array can be wrtten by both sms and mes search in out.
  x_result_array := cs_kb_result_varray_type();
  x_rows_returned_tbl := cs_kb_number_tbl_type();
  x_next_row_pos_tbl  :=cs_kb_number_tbl_type();
  x_total_row_cnt_tbl :=cs_kb_number_tbl_type();


  if(p_repository_tbl is null) then
    if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
      fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
      fnd_msg_pub.Add;
    end if;
    raise FND_API.G_EXC_ERROR;
  end if;

  ind :=  p_repository_tbl.FIRST;
  while ind is not null loop

    if(p_repository_tbl(ind) = 'MES') then

      x_rows_returned_tbl.EXTEND;
      x_next_row_pos_tbl.EXTEND;
      x_total_row_cnt_tbl.EXTEND;

      Specific_Search_Mes(
        p_api_version => p_api_version,
        p_init_msg_list => p_init_msg_list,
        p_validation_level => p_validation_level,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data,
        p_search_string => l_search_string,
        p_updated_in_days => l_updated_in_days,
        p_check_login_user => p_check_login_user,
        p_application_id => p_application_id,
        p_area_array => p_area_array,
        p_content_array => p_content_array,
        p_param_array  => p_param_array,
        p_user_id => l_user_id,
        p_category_id	=> p_category_id,
        p_include_subcats => p_include_subcats,
        p_external_contents => p_external_contents,
        p_rows_requested => p_rows_requested_tbl(ind),
        p_start_row_pos  => p_start_row_pos_tbl(ind),
        p_get_total_cnt_flag => p_get_total_cnt_flag,
        x_rows_returned => x_rows_returned_tbl(ind),
        x_next_row_pos => x_next_row_pos_tbl(ind),
        x_total_row_cnt => x_total_row_cnt_tbl(ind),
        x_result_array => x_result_array,
        x_amv_result_array => x_amv_result_array);
    end if;
    ind := p_repository_tbl.NEXT(ind);
  end loop;
-- -- -- -- end of code -- -- -- --

  -- Standard call to get message count. if count=1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count =>  x_msg_count,
    p_data  =>  x_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Specific_Search_GRP;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count  => x_msg_count,
      p_data   => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Specific_Search_GRP;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);

  WHEN OTHERS THEN
    ROLLBACK TO Specific_Search_GRP;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level
           (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg(
          G_PKG_NAME,
   	  l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get(
        p_count => x_msg_count,
        p_data => x_msg_data);


end Specific_Search;

-- ========================================================================================

end IBU_Knowledge_Grp;

/
