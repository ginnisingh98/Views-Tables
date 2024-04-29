--------------------------------------------------------
--  DDL for Package Body CS_KNOWLEDGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KNOWLEDGE_GRP" AS
/* $Header: csgkbb.pls 120.3 2006/01/20 16:53:53 mkettle ship $ */



--
-- PUBLIC
--
PROCEDURE Construct_Text_Query(
  p_api_version	        in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit	        in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count	        OUT NOCOPY number,
  x_msg_data	        OUT NOCOPY varchar2,
  p_qry_string          in varchar2,
  p_search_option       in number,
  x_qry_string          OUT NOCOPY varchar2
) is
  l_api_name	CONSTANT varchar2(30)	:= 'Construct_Text_Query';
  l_api_version CONSTANT number 	:= 1.0;
  l_ret number(5);
  l_qry_string  varchar2(30000) := p_qry_string;

begin
  savepoint Const_Text_Qry_PUB;
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
-- -- -- -- begin build_text_query -- -- -- -- --
  x_qry_string := CS_KNOWLEDGE_PVT.Build_Simple_Text_Query(
    p_qry_string => l_qry_string,
    p_search_option =>  p_search_option);

 EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Const_Text_Qry_PUB;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count  => x_msg_count,
      p_data   => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Const_Text_Qry_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO Const_Text_Qry_PUB;
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
end Construct_Text_Query;


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
) is
  l_api_name	CONSTANT varchar2(30)	:= 'Delete_Set_Link';
  l_api_version CONSTANT number 	:= 1.0;
  l_ret number(5);
begin
  savepoint Del_Set_Link_PUB;
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
-- -- -- -- begin delete set_link -- -- -- -- --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_ret := CS_KB_SET_LINKS_PKG.Delete_Set_Link_W_Obj_Code(
     p_set_id, p_object_code, p_other_id);
-- -- -- -- end delete set_link -- -- --

  FND_MSG_PUB.Count_And_Get(
    p_count =>  x_msg_count,
    p_data  =>  x_msg_data );

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Del_Set_Link_PUB;
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(
      p_count  => x_msg_count,
      p_data   => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Del_Set_Link_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO Del_Set_Link_PUB;
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
end Delete_Set_Link;

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
) is
  l_api_name	CONSTANT varchar2(30)	:= 'Delete_Element_Link';
  l_api_version CONSTANT number 	:= 1.0;
  l_ret number(5);
begin
  savepoint Del_Element_Link_PUB;

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

-- -- -- -- begin delete Element_link -- -- -- -- --
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  l_ret := CS_KB_ELEMENT_LINKS_PKG.Delete_Element_Link_W_Obj_Code(
    p_element_id, p_object_code, p_other_id);

-- -- -- -- end delete Element_link -- -- --
  -- Standard call to get message count. if count=1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count =>  x_msg_count,
    p_data  =>  x_msg_data );

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Del_Element_Link_PUB;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count  => x_msg_count,
      p_data   => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Del_Element_Link_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO Del_Element_Link_PUB;
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
end Delete_Element_Link;

--
-- Create_Set
-- returns set id or ERROR_STATUS
--

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
--  p_attrval_def_tbl     in  CS_Knowledge_PUB.attrval_def_tbl_type :=null,
  x_set_id              OUT NOCOPY number
)is
  l_api_name	CONSTANT varchar2(30)	:= 'Create_Set_And_Elements';
  l_api_version CONSTANT number 	:= 1.0;

begin

  savepoint Create_Set_And_Elements_PUB;

  if not FND_API.Compatible_API_Call(
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME) then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

-- -- -- -- begin my code -- -- -- -- --
  CS_Knowledge_PVT.Create_Set_And_Elements(
    p_api_version	=> p_api_version,
    p_init_msg_list  => p_init_msg_list,
    p_commit => p_commit,
    p_validation_level => p_validation_level,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data,
    p_set_def_rec => p_set_def_rec,
    p_ele_def_tbl => p_ele_def_tbl,
--    p_attrval_def_tbl => p_attrval_def_tbl,
    x_set_id => x_set_id);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_Set_And_Elements_PUB;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count  => x_msg_count,
      p_data   => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_Set_And_Elements_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO Create_Set_And_Elements_PUB;
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
end Create_Set_And_Elements;


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
)
IS
  l_api_name	CONSTANT varchar2(30)	:= 'Create_Set_And_Elements';
  l_api_version CONSTANT number 	:= 1.0;
begin

  savepoint Create_Set_And_Elements_PUB;

  if not FND_API.Compatible_API_Call(
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME) then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

-- -- -- -- begin my code -- -- -- -- --
  CS_Knowledge_PVT.Create_Set_And_Elements(
    p_api_version	=> p_api_version,
    p_init_msg_list  => p_init_msg_list,
    p_commit => p_commit,
    p_validation_level => p_validation_level,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data,
    p_set_def_rec => p_set_def_rec,
    p_ele_def_tbl => p_ele_def_tbl,
    x_set_id => x_set_id,
    x_element_id_tbl => x_element_id_tbl);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_Set_And_Elements_PUB;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count  => x_msg_count,
      p_data   => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_Set_And_Elements_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO Create_Set_And_Elements_PUB;
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

end Create_Set_And_Elements;


--
-- Create a set for the given element_ids.
--
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
--  p_attrval_def_tbl     in  CS_Knowledge_PUB.attrval_def_tbl_type := null,
  x_set_id              OUT NOCOPY number
) is
  l_api_name	CONSTANT varchar2(30)	:= 'Create_Set';
  l_api_version CONSTANT number 	:= 1.0;

begin

  savepoint Create_Set_PUB;

  if not FND_API.Compatible_API_Call(
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME) then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

-- -- -- -- begin my code -- -- -- -- --
  CS_Knowledge_PVT.Create_Set(
    p_api_version	=> p_api_version,
    p_init_msg_list  => p_init_msg_list,
    p_commit => p_commit,
    p_validation_level => p_validation_level,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data,
    p_set_def_rec => p_set_def_rec,
    p_ele_id_tbl => p_ele_id_tbl,
--    p_attrval_def_tbl => p_attrval_def_tbl,
    x_set_id => x_set_id);


EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_Set_PUB;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count  => x_msg_count,
      p_data   => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_Set_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO Create_Set_PUB;
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

end Create_Set;

--
-- Create ELement given ele_type_id and desc
-- Other params are not used for now.
--
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
) is
  l_api_name	CONSTANT varchar2(30)	:= 'Create_Element';
  l_api_version CONSTANT number 	:= 1.0;
begin

  savepoint Create_Element_PUB;

  if not FND_API.Compatible_API_Call(
           	l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

-- -- -- -- begin my code -- -- -- -- --
  CS_Knowledge_PVT.Create_Element(
    p_api_version	=> p_api_version,
    p_init_msg_list  => p_init_msg_list,
    p_commit => p_commit,
    p_validation_level => p_validation_level,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data,
    p_ele_def_rec => p_ele_def_rec,
    x_element_id => x_element_id);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_Element_PUB;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count  => x_msg_count,
      p_data   => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_Element_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO Create_Element_PUB;
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
end Create_Element;

PROCEDURE Find_Sets_Matching (
  p_api_version	        in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  --p_commit	        in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count	        OUT NOCOPY number,
  x_msg_data	        OUT NOCOPY varchar2,
  --p_sets_c            in OUT NOCOPY general_csr_type,
  p_pos_query_str       in  varchar2,
  p_neg_query_str       in  varchar2 := null,
  p_type_id_tbl         in  CS_Knowledge_PUB.number15_tbl_type,
  p_other_criteria      in  varchar2 := NULL,
  p_rows                in  number,
  p_start_score         in  number := null,
  p_start_id            in  number := null,
  x_set_tbl      	in OUT NOCOPY CS_Knowledge_PUB.set_res_tbl_type
)is
  l_api_name	CONSTANT varchar2(30)	:= 'Find_Sets_Matching';
  l_api_version CONSTANT number 	:= 1.0;
  l_total_rows number :=0;
begin
  savepoint Find_Sets_Matching_PUB;

  if not FND_API.Compatible_API_Call(
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME) then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

-- -- -- -- begin my code -- -- -- -- --
  CS_Knowledge_PVT.Find_Sets_Matching(
    p_api_version    => p_api_version,
    p_init_msg_list  => p_init_msg_list,
    p_validation_level => p_validation_level,
    x_return_status => x_return_status,
    x_msg_count => x_msg_count,
    x_msg_data => x_msg_data,
    p_pos_query_str =>p_pos_query_str,
    p_neg_query_str =>p_neg_query_str,
    p_type_id_tbl => p_type_id_tbl,
    p_other_criteria => p_other_criteria,
    p_rows => p_rows,
    p_start_score =>p_start_score,
    p_start_id => p_start_id,
    p_start_row => 1,
    p_get_total_flag => FND_API.G_FALSE,
    x_set_tbl => x_set_tbl,
    x_total_rows => l_total_rows);

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Find_Sets_Matching_PUB;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count  => x_msg_count,
      p_data   => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Find_Sets_Matching_PUB;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO Find_Sets_Matching_PUB;
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
end Find_Sets_Matching;

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
) is
  l_api_name	CONSTANT varchar2(30)	:= 'Create_Element_Link';
  l_api_version CONSTANT number 	:= 1.0;
  l_date  date;
  l_created_by number;
  l_login number;
  l_id number(15);
begin
  savepoint Create_Element_Link_Grp;

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

  l_id := CS_KB_ELEMENT_LINKS_PKG.Create_Element_Link(
        p_element_link_rec.link_type,
        p_element_link_rec.object_code,
        p_element_link_rec.element_id,
        p_element_link_rec.other_id,
	p_element_link_rec.attribute_category,
	p_element_link_rec.attribute1,
	p_element_link_rec.attribute2,
	p_element_link_rec.attribute3,
	p_element_link_rec.attribute4,
	p_element_link_rec.attribute5,
	p_element_link_rec.attribute6,
	p_element_link_rec.attribute7,
	p_element_link_rec.attribute8,
	p_element_link_rec.attribute9,
	p_element_link_rec.attribute10,
	p_element_link_rec.attribute11,
	p_element_link_rec.attribute12,
	p_element_link_rec.attribute13,
	p_element_link_rec.attribute14,
	p_element_link_rec.attribute15
  );
  if(l_id>0) then
    x_element_link_id  := l_id;
  else
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

-- -- -- -- end of code -- -- --

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count. if count=1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count =>  x_msg_count,
    p_data  =>  x_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_Element_Link_Grp;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count  => x_msg_count,
      p_data   => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Create_Element_Link_Grp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO Create_Element_Link_Grp;
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
end Create_Element_Link;

PROCEDURE Create_Set_Link(
  P_API_VERSION	        IN  NUMBER,
  P_INIT_MSG_LIST       IN  VARCHAR2 := FND_API.G_FALSE,
  P_COMMIT	            IN  VARCHAR2 := FND_API.G_FALSE,
  P_VALIDATION_LEVEL    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  X_RETURN_STATUS       OUT NOCOPY VARCHAR2,
  X_MSG_COUNT	        OUT NOCOPY NUMBER,
  X_MSG_DATA	        OUT NOCOPY VARCHAR2,
  P_SET_LINK_REC        IN  CS_KB_SET_LINKS%ROWTYPE,
  X_SET_LINK_ID         OUT NOCOPY NUMBER
) IS
  l_api_name	CONSTANT varchar2(30)	:= 'Create_Set_Link';
  l_api_version CONSTANT number 	:= 1.0;
  l_date  date;
  l_created_by number;
  l_login number;
  l_id number(15);

  l_return_status VARCHAR2(1);
  l_msg_data VARCHAR2(2000);
  l_msg_count NUMBER;

BEGIN
  SAVEPOINT Create_Set_Link_Grp;

  IF NOT FND_API.Compatible_API_Call(
		l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME) THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  IF FND_API.to_Boolean(p_init_msg_list) THEN
    FND_MSG_PUB.initialize;
  END IF;

  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

  CS_KB_SET_LINKS_PKG.Create_Set_Link(
       P_LINK_TYPE          => p_set_link_rec.link_type,
       P_OBJECT_CODE        => p_set_link_rec.object_code,
       P_SET_ID             => p_set_link_rec.set_id,
       P_OTHER_ID           => p_set_link_rec.other_id,
       P_ATTRIBUTE_CATEGORY => p_set_link_rec.attribute_category,
       P_ATTRIBUTE1         => p_set_link_rec.attribute1,
       P_ATTRIBUTE2         => p_set_link_rec.attribute2,
       P_ATTRIBUTE3         => p_set_link_rec.attribute3,
       P_ATTRIBUTE4         => p_set_link_rec.attribute4,
       P_ATTRIBUTE5         => p_set_link_rec.attribute5,
       P_ATTRIBUTE6         => p_set_link_rec.attribute6,
       P_ATTRIBUTE7         => p_set_link_rec.attribute7,
       P_ATTRIBUTE8         => p_set_link_rec.attribute8,
       P_ATTRIBUTE9         => p_set_link_rec.attribute9,
       P_ATTRIBUTE10        => p_set_link_rec.attribute10,
       P_ATTRIBUTE11        => p_set_link_rec.attribute11,
       P_ATTRIBUTE12        => p_set_link_rec.attribute12,
       P_ATTRIBUTE13        => p_set_link_rec.attribute13,
       P_ATTRIBUTE14        => p_set_link_rec.attribute14,
       P_ATTRIBUTE15        => p_set_link_rec.attribute15,
       X_LINK_ID            => l_id,
       X_RETURN_STATUS      => l_return_status,
       X_MSG_DATA           => l_msg_data,
       X_MSG_COUNT          => l_msg_count );

  X_RETURN_STATUS   := l_return_status;
  X_MSG_DATA        := l_msg_data;
  X_MSG_COUNT       := l_msg_count;

  IF FND_API.To_Boolean( p_commit ) AND
     l_return_status = FND_API.G_RET_STS_SUCCESS THEN
    COMMIT WORK;
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN

    ROLLBACK TO Create_Set_Link_Grp;

    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR ;

    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
      p_count  => x_msg_count,
      p_data   => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

    ROLLBACK TO Create_Set_Link_Grp;

    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR ;

    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);
  WHEN OTHERS THEN

    ROLLBACK TO Create_Set_Link_Grp;

    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR ;

    IF FND_MSG_PUB.Check_Msg_Level
       (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name);
    END IF;

    FND_MSG_PUB.Count_And_Get(
       p_encoded => FND_API.G_FALSE ,
       p_count => x_msg_count,
       p_data => x_msg_data);

END Create_Set_Link;

PROCEDURE Update_Set_Link(
  p_api_version         in  number,
  p_init_msg_list       in  varchar2 := FND_API.G_FALSE,
  p_commit              in  varchar2 := FND_API.G_FALSE,
  p_validation_level    in  number   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status       OUT NOCOPY varchar2,
  x_msg_count           OUT NOCOPY number,
  x_msg_data            OUT NOCOPY varchar2,
  p_set_link_rec   in  CS_KB_SET_LINKS%ROWTYPE
) is
  l_api_name    CONSTANT varchar2(30)   := 'Update_Set_Link';
  l_api_version CONSTANT number         := 1.0;
  l_date  date;
  l_created_by number;
  l_login number;
  l_sta number(15);
begin
  savepoint Update_Set_Link_Grp;

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

  l_sta := CS_KB_SET_LINKS_PKG.Update_Set_Link(
        p_set_link_rec.link_id,
        p_set_link_rec.link_type,
        p_set_link_rec.object_code,
        p_set_link_rec.set_id,
        p_set_link_rec.other_id,
        p_set_link_rec.attribute_category,
        p_set_link_rec.attribute1,
        p_set_link_rec.attribute2,
        p_set_link_rec.attribute3,
        p_set_link_rec.attribute4,
        p_set_link_rec.attribute5,
        p_set_link_rec.attribute6,
        p_set_link_rec.attribute7,
        p_set_link_rec.attribute8,
        p_set_link_rec.attribute9,
        p_set_link_rec.attribute10,
        p_set_link_rec.attribute11,
        p_set_link_rec.attribute12,
        p_set_link_rec.attribute13,
        p_set_link_rec.attribute14,
        p_set_link_rec.attribute15
  );
  if(l_sta<>CS_KB_SET_LINKS_PKG.OKAY_STATUS) then
    raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;

-- -- -- -- end of code -- -- --

  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  -- Standard call to get message count. if count=1, get message info.
  FND_MSG_PUB.Count_And_Get(
    p_count =>  x_msg_count,
    p_data  =>  x_msg_data );

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Update_Set_Link_Grp;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count  => x_msg_count,
      p_data   => x_msg_data );
  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    ROLLBACK TO Update_Set_Link_Grp;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_count => x_msg_count,
      p_data  => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO Update_Set_Link_Grp;
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
end Update_Set_Link;

PROCEDURE Specific_Search_Mes(
  p_api_version        IN   NUMBER,
  p_init_msg_list      IN   VARCHAR2 := fnd_api.g_false,
  p_validation_level   IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status      OUT NOCOPY  VARCHAR2,
  x_msg_count          OUT NOCOPY  NUMBER,
  x_msg_data           OUT NOCOPY  VARCHAR2,
  p_search_string      IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_updated_in_days    IN   NUMBER := FND_API.G_MISS_NUM,
    p_check_login_user  IN   VARCHAR2 := FND_API.G_TRUE,
    p_application_id    IN   NUMBER,
    p_area_array        IN   AMV_SEARCH_PVT.amv_char_varray_type
                            := null, --amv_search_grp.Default_AreaArray,
    p_content_array     IN   AMV_SEARCH_PVT.amv_char_varray_type
                            := null, --amv_search_grp.Default_ContentArray,
    p_param_array       IN   AMV_SEARCH_PVT.amv_searchpar_varray_type,
    p_user_id           IN   NUMBER := FND_API.G_MISS_NUM,
    p_category_id       IN   AMV_SEARCH_PVT.amv_number_varray_type,
    p_include_subcats   IN      VARCHAR2 := FND_API.G_FALSE,
    p_external_contents IN      VARCHAR2 := FND_API.G_FALSE,
  p_rows_requested IN NUMBER,
  p_start_row_pos  IN NUMBER := 1,
  p_get_total_cnt_flag IN VARCHAR2 := fnd_api.g_false,
  x_rows_returned OUT NOCOPY NUMBER,
  x_next_row_pos OUT NOCOPY NUMBER,
  x_total_row_cnt OUT NOCOPY NUMBER,
  x_result_array       IN OUT NOCOPY  cs_kb_result_varray_type,
  x_amv_result_array   OUT NOCOPY  AMV_SEARCH_PVT.amv_searchres_varray_type
) is
  l_amv_req_obj AMV_SEARCH_PVT.amv_request_obj_type;
  l_amv_ret_obj AMV_SEARCH_PVT.amv_return_obj_type;
  l_amv_res_array AMV_SEARCH_PVT.amv_searchres_varray_type;
  l_ret_cnt pls_integer :=0;

begin
  --  x_result_array := cs_kb_result_varray_type();
null;

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
      p_imt_string   => p_search_string,
      p_days => p_updated_in_days,
      p_user_id => p_user_id,
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
              -- 3430496
              -- l_amv_res_array(i).user1,
              -- user1 has a 'DD-MON-YYYY' format. Fine to use 'DD-MM-RRRR'
              -- in to_date.
              to_date(l_amv_res_array(i).user1, 'DD-MM-RRRR'),
              l_amv_res_array(i).url_string,
              l_amv_res_array(i).description, 'MES', null);
        end loop;

      end if;
    end if;

end Specific_Search_Mes;

PROCEDURE Specific_Search_Sms(
  p_api_version        IN   NUMBER,
  p_init_msg_list      IN   VARCHAR2 := fnd_api.g_false,
  p_validation_level   IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  x_return_status      OUT NOCOPY  VARCHAR2,
  x_msg_count          OUT NOCOPY  NUMBER,
  x_msg_data           OUT NOCOPY  VARCHAR2,
  p_search_string      IN   VARCHAR2 := FND_API.G_MISS_CHAR,
  p_updated_in_days    IN   NUMBER := FND_API.G_MISS_NUM,
  p_rows_requested IN NUMBER,
  p_start_row_pos  IN NUMBER := 1,
  p_get_total_cnt_flag IN VARCHAR2 := fnd_api.g_false,
  x_rows_returned OUT NOCOPY NUMBER,
  x_next_row_pos OUT NOCOPY NUMBER,
  x_total_row_cnt OUT NOCOPY NUMBER,
  x_result_array       IN OUT NOCOPY  cs_kb_result_varray_type,
  p_search_option  IN NUMBER := null
)is
  err_num number;
  err_msg varchar2(100);
  l_days_cond  varchar2(100) := '';
  l_sms_res_tbl CS_Knowledge_PUB.set_res_tbl_type;
  l_total_cnt pls_integer :=0;
  l_next_pos pls_integer :=0;
  l_ret_cnt pls_integer :=0;
begin
--null;

  --  x_result_array := cs_kb_result_varray_type();

    if( p_search_string = FND_API.G_MISS_CHAR ) then
      if fnd_msg_pub.Check_Msg_Level( fnd_msg_pub.G_MSG_LVL_ERROR) then
        fnd_message.set_name('CS', 'CS_KB_C_MISS_PARAM');
        fnd_msg_pub.Add;
      end if;
      raise FND_API.G_EXC_ERROR;
    end if;


    if( p_updated_in_days is not null and
        p_updated_in_days<FND_API.G_MISS_NUM and
        p_updated_in_days >= 0) then
      l_days_cond :=
        ' and cs_kb_sets_b.last_update_date >= (sysdate - :2 ) ';
--        ' and cs_kb_sets_vl.last_update_date >= (sysdate - ' ||
--        to_char(p_updated_in_days) || ') ';

      CS_Knowledge_PVT.Find_Sets_Matching2(
        p_api_version => p_api_version,
        p_init_msg_list => p_init_msg_list,
        p_validation_level => p_validation_level,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data,
        p_pos_query_str => p_search_string,
        --p_neg_query_str => null,
        p_type_id_tbl => null,
        p_other_criteria  => l_days_cond,
        p_other_value  => p_updated_in_days,
        p_rows => p_rows_requested +
                  p_start_row_pos -1,
        p_start_row => 1,
        p_get_total_flag => p_get_total_cnt_flag,
        x_set_tbl => l_sms_res_tbl,
        x_total_rows => l_total_cnt,
        p_search_option => p_search_option);

    else

      CS_Knowledge_PVT.Find_Sets_Matching(
        p_api_version => p_api_version,
        p_init_msg_list => p_init_msg_list,
        p_validation_level => p_validation_level,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data,
        p_pos_query_str => p_search_string,
        p_neg_query_str => null,
        p_type_id_tbl => null,
        p_other_criteria  => l_days_cond,
        p_rows => p_rows_requested +
                  p_start_row_pos -1,
        p_start_row => 1,
        p_get_total_flag => p_get_total_cnt_flag,
        x_set_tbl => l_sms_res_tbl,
        x_total_rows => l_total_cnt,
        p_search_option => p_search_option);

    end if;

    -- return x_row_return_obj and x_result_array
    if(x_return_status = FND_API.G_RET_STS_SUCCESS) then

      l_ret_cnt := l_sms_res_tbl.COUNT;
      x_total_row_cnt := l_total_cnt;
      x_rows_returned := l_ret_cnt;
      if(l_ret_cnt < l_total_cnt)  then
        l_next_pos := l_ret_cnt +1;
      else
        l_next_pos := 0;
      end if;
      x_next_row_pos := l_next_pos;


      if(l_ret_cnt > 0) then

        x_result_array.EXTEND(x_rows_returned);

        for i in 1..l_ret_cnt loop
          x_result_array(i) := cs_kb_result_obj_type(
            l_sms_res_tbl(i).score,
            l_sms_res_tbl(i).id,
            l_sms_res_tbl(i).name,
            l_sms_res_tbl(i).last_update_date,
            'cskmis03.jsp?setId='||to_char(l_sms_res_tbl(i).id),
            null, 'SMS', l_sms_res_tbl(i).solution_number);

--dbms_output.put_line(to_char(i)||':'||to_char(x_result_array(i).id));
--dbms_output.put_line(to_char(i)||':'||to_char(x_result_array(i).score));
        end loop;
      end if;

    end if;

end Specific_Search_Sms;


--
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
begin

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
        p_search_string => p_search_string,
        p_updated_in_days => p_updated_in_days,
        p_check_login_user => p_check_login_user,
        p_application_id => p_application_id,
        p_area_array => l_area_array,
        p_content_array => l_content_array,
        p_param_array  => l_param_array,
        p_user_id => p_user_id,
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
        x_amv_result_array => l_amv_result_array,
        p_search_option => p_search_option);

end Specific_Search;


--
-- This api has fewer params. It calls the main Specific Search.
-- This api uses amv's record types, which used to be object types.
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
   p_area_array         IN   AMV_SEARCH_PVT.amv_char_varray_type
                            := AMV_SEARCH_PVT.amv_char_varray_type(),
   p_content_array      IN   AMV_SEARCH_PVT.amv_char_varray_type
                            := AMV_SEARCH_PVT.amv_char_varray_type(),
   p_param_array        IN   AMV_SEARCH_PVT.amv_searchpar_varray_type
                            := AMV_SEARCH_PVT.amv_searchpar_varray_type(),
   p_user_id            IN   NUMBER := FND_API.G_MISS_NUM,
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
  x_result_array       OUT NOCOPY  cs_kb_result_varray_type,
  p_search_option      IN  NUMBER := NULL

)is
l_amv_result_array AMV_SEARCH_PVT.amv_searchres_varray_type;
begin
  Specific_Search(
        p_api_version => p_api_version,
        p_init_msg_list => p_init_msg_list,
        p_validation_level => p_validation_level,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data,
        p_repository_tbl => p_repository_tbl,
        p_search_string => p_search_string,
        p_updated_in_days => p_updated_in_days,
        p_check_login_user => p_check_login_user,
        p_application_id => p_application_id,
        p_area_array => p_area_array,
        p_content_array => p_content_array,
        p_param_array  => p_param_array,
        p_user_id => p_user_id,
        p_category_id	=> p_category_id,
        p_include_subcats => p_include_subcats,
        p_external_contents => p_external_contents,
        p_rows_requested_tbl => p_rows_requested_tbl,
        p_start_row_pos_tbl  => p_start_row_pos_tbl,
        p_get_total_cnt_flag => p_get_total_cnt_flag,
        x_rows_returned_tbl => x_rows_returned_tbl,
        x_next_row_pos_tbl => x_next_row_pos_tbl,
        x_total_row_cnt_tbl => x_total_row_cnt_tbl,
        x_result_array => x_result_array,
        x_amv_result_array => l_amv_result_array,
        p_search_option => p_search_option);

end Specific_Search;

--
-- Main Specific search
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
    p_check_login_user  IN   VARCHAR2 := FND_API.G_TRUE,
    p_application_id    IN   NUMBER,
   p_area_array         IN   AMV_SEARCH_PVT.amv_char_varray_type
                            := AMV_SEARCH_PVT.amv_char_varray_type(),
   p_content_array      IN   AMV_SEARCH_PVT.amv_char_varray_type
                            := AMV_SEARCH_PVT.amv_char_varray_type(),
   p_param_array        IN   AMV_SEARCH_PVT.amv_searchpar_varray_type
                            := AMV_SEARCH_PVT.amv_searchpar_varray_type(),
    p_user_id           IN   NUMBER := FND_API.G_MISS_NUM,
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
  x_result_array       OUT NOCOPY  cs_kb_result_varray_type,
  x_amv_result_array   OUT NOCOPY  AMV_SEARCH_PVT.amv_searchres_varray_type,
  p_search_option      IN  NUMBER := NULL

)is
  l_api_name	CONSTANT varchar2(30)	:= 'Specific_Search';
  l_api_version CONSTANT number 	:= 1.0;
  ind           pls_integer;  --index number

  -- klou add search option
  l_search_option NUMBER := p_search_option;
begin
  savepoint Specific_Search_GRP;

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
  -- 08/10/2004, klou, check search option
  if l_search_option is null then
    -- default to interMedia search, as this API is specifically for
    -- eMail center, and they always want interMedia search.
    l_search_option := CS_KNOWLEDGE_PUB.INTERMEDIA_SYNTAX;
  end if;

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
        p_search_string => p_search_string,
        p_updated_in_days => p_updated_in_days,
        p_check_login_user => p_check_login_user,
        p_application_id => p_application_id,
        p_area_array => p_area_array,
        p_content_array => p_content_array,
        p_param_array  => p_param_array,
        p_user_id => p_user_id,
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

    elsif(p_repository_tbl(ind) = 'SMS') then

      x_rows_returned_tbl.EXTEND;
      x_next_row_pos_tbl.EXTEND;
      x_total_row_cnt_tbl.EXTEND;

      Specific_Search_Sms(
        p_api_version => p_api_version,
        p_init_msg_list => p_init_msg_list,
        p_validation_level => p_validation_level,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data,
        p_search_string => p_search_string,
        p_updated_in_days => p_updated_in_days,
        p_rows_requested => p_rows_requested_tbl(ind),
        p_start_row_pos  => p_start_row_pos_tbl(ind),
        p_get_total_cnt_flag => p_get_total_cnt_flag,
        x_rows_returned => x_rows_returned_tbl(ind),
        x_next_row_pos => x_next_row_pos_tbl(ind),
        x_total_row_cnt => x_total_row_cnt_tbl(ind),
        x_result_array => x_result_array,
        p_search_option => l_search_option);
return;
    end if;
    ind := p_repository_tbl.NEXT(ind);
  end loop;

  if(p_repository_tbl.COUNT=1 and
     p_repository_tbl(p_repository_tbl.FIRST)='ALL') then

    ind :=  p_repository_tbl.FIRST;
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
        p_search_string => p_search_string,
        p_updated_in_days => p_updated_in_days,
        p_check_login_user => p_check_login_user,
        p_application_id => p_application_id,
        p_area_array => p_area_array,
        p_content_array => p_content_array,
        p_param_array  => p_param_array,
        p_user_id => p_user_id,
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

    Specific_Search_Sms(
        p_api_version => p_api_version,
        p_init_msg_list => p_init_msg_list,
        p_validation_level => p_validation_level,
        x_return_status => x_return_status,
        x_msg_count => x_msg_count,
        x_msg_data => x_msg_data,
        p_search_string => p_search_string,
        p_updated_in_days => p_updated_in_days,
        p_rows_requested => p_rows_requested_tbl(ind),
        p_start_row_pos  => p_start_row_pos_tbl(ind),
        p_get_total_cnt_flag => p_get_total_cnt_flag,
        x_rows_returned => x_rows_returned_tbl(ind),
        x_next_row_pos => x_next_row_pos_tbl(ind),
        x_total_row_cnt => x_total_row_cnt_tbl(ind),
        x_result_array => x_result_array,
        p_search_option => l_search_option);

  end if;  --end if all

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
 X_MSG_DATA	          OUT NOCOPY VARCHAR2) IS

BEGIN
  SAVEPOINT Purge_Knowledge_Links_GRP;
  X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;

  IF FND_API.to_Boolean(P_INIT_MSG_LIST) THEN
    FND_MSG_PUB.initialize;
  END IF;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_KNOWLEDGE_GRP.Purge_Knowledge_Links.Start',
                   'Purge_Knowledge_Links for - '||P_PROCESSING_SET_ID||' '||P_OBJECT_TYPE );
  END IF;

  IF (P_PROCESSING_SET_ID IS NULL OR P_OBJECT_TYPE IS NULL) THEN
    FND_MESSAGE.set_name('CS', 'CS_KB_C_MISS_PARAM');
    FND_MSG_PUB.ADD;
    X_RETURN_STATUS := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE ,
                              p_count   => X_MSG_COUNT,
                              p_data    => X_MSG_DATA);
    IF FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

       FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION,

                      'cs.plsql.CS_KNOWLEDGE_GRP.Purge_Knowledge_Links.InvalidParams',

                      'Purge_Knowledge_Links for - '||P_PROCESSING_SET_ID||' '||P_OBJECT_TYPE
                     );

    END IF;
  ELSE

    DELETE /*+ index(l) */ FROM CS_KB_SET_LINKS l
    WHERE l.Object_Code = P_OBJECT_TYPE
    AND l.Other_id IN ( SELECT /*+ no_unnest no_semijoin cardinality(10) */ t.Object_id
                        FROM JTF_OBJECT_PURGE_PARAM_TMP t
                        WHERE nvl(t.purge_status, 'S') <> 'E'
                        AND t.Processing_Set_Id = P_PROCESSING_SET_ID
                        AND t.Object_Type = P_OBJECT_TYPE
                       );

    X_RETURN_STATUS := FND_API.G_RET_STS_SUCCESS;

    IF FND_API.to_Boolean(P_COMMIT) THEN
      COMMIT;
    END IF;

  END IF;

  IF FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE, 'cs.plsql.CS_KNOWLEDGE_GRP.Purge_Knowledge_Links.End',
                   'Purge_Knowledge_Links Status - '||X_RETURN_STATUS );
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK TO Purge_Knowledge_Links_GRP;
    IF FND_LOG.LEVEL_UNEXPECTED >= FND_LOG.G_CURRENT_RUNTIME_LEVEL THEN

       FND_LOG.STRING(FND_LOG.LEVEL_UNEXPECTED, 'cs.plsql.CS_KNOWLEDGE_GRP.Purge_Knowledge_Links.UNEXPECTED',

                     ' Error= '||sqlerrm);

    END IF;

    X_RETURN_STATUS := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.Check_Msg_Level (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,
                                 'Purge_Knowledge_Links');
    END IF;
    FND_MSG_PUB.Count_And_Get( p_encoded => FND_API.G_FALSE ,
                               p_count => x_msg_count,
                               p_data => x_msg_data);
END Purge_Knowledge_Links;


end CS_Knowledge_Grp;

/
