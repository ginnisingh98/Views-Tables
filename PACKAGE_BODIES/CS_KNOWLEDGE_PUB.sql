--------------------------------------------------------
--  DDL for Package Body CS_KNOWLEDGE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CS_KNOWLEDGE_PUB" AS
/* $Header: cspkbb.pls 115.13 2003/12/04 00:57:55 mkettle ship $ */

empty varchar2(10) :='';

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
  CS_KNOWLEDGE_GRP.Construct_Text_Query
	  (     p_api_version	=>1.0,
		p_init_msg_list	=>FND_API.G_FALSE,
		p_commit	=>FND_API.G_FALSE,
		x_return_status =>x_return_status,
		x_msg_count	=>x_msg_count,
		x_msg_data	=>x_msg_data,
                p_qry_string    =>p_qry_string,
                p_search_option =>p_search_option,
                x_qry_string    =>x_qry_string);

--------- end ----------------------

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

  l_return_status VARCHAR2(1);
  l_set_def_rec CS_Knowledge_PUB.set_def_rec_type;
  l_ele_def_tbl CS_Knowledge_PUB.ele_def_tbl_type;


begin

  savepoint Create_Set_And_Elements_PUB;

  l_set_def_rec := p_set_def_rec;
  l_ele_def_tbl := p_ele_def_tbl;

  if not FND_API.Compatible_API_Call(
	 	l_api_version,
		p_api_version,
		l_api_name,
		G_PKG_NAME) then
     raise FND_API.G_EXC_UNEXPECTED_ERROR;
  end if;



--  Adding User Hooks at this point

	IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'B', 'C' ) THEN
		CS_KNOWLEDGE_CUHK.Create_Set_And_Elements_Pre
		(
			p_api_version		=>	1.0,
			p_init_msg_list	        =>	FND_API.G_FALSE,
			p_commit		=>	FND_API.G_FALSE,
			x_return_status	        =>	l_return_status,
			x_msg_count		=>	x_msg_count,
			x_msg_data		=>	x_msg_data,
                        p_set_def_rec           =>      l_set_def_rec,
                        p_ele_def_tbl           =>      l_ele_def_tbl,
                        x_set_id                =>      x_set_id,
                        x_element_id_tbl        =>      x_element_id_tbl);

                IF (l_return_status = FND_API.G_RET_STS_ERROR) then
		       RAISE FND_API.G_EXC_ERROR;
                ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
		       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

		END IF;
	END IF;

	IF JTF_USR_HKS.Ok_to_execute( G_PKG_NAME, l_api_name, 'B', 'V' )  THEN
		CS_KNOWLEDGE_VUHK.Create_Set_And_Elements_Pre
		(
			p_api_version		=>	1.0,
			p_init_msg_list	        =>	FND_API.G_FALSE,
			p_commit		=>	FND_API.G_FALSE,
			x_return_status	        =>	l_return_status,
			x_msg_count		=>	x_msg_count,
			x_msg_data		=>	x_msg_data,
                        p_set_def_rec           =>      l_set_def_rec,
                        p_ele_def_tbl           =>      l_ele_def_tbl,
                        x_set_id                =>      x_set_id,
                        x_element_id_tbl        =>      x_element_id_tbl);

                IF (l_return_status = FND_API.G_RET_STS_ERROR) then
		       RAISE FND_API.G_EXC_ERROR;
                ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
		       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

		END IF;
	END IF;


-- -- -- -- begin my code -- -- -- -- --
  CS_Knowledge_GRP.Create_Set_And_Elements(
    p_api_version	=> p_api_version,
    p_init_msg_list     => p_init_msg_list,
    p_commit            => p_commit,
    p_validation_level  => p_validation_level,
    x_return_status     => x_return_status,
    x_msg_count         => x_msg_count,
    x_msg_data          => x_msg_data,
    p_set_def_rec       => p_set_def_rec,
    p_ele_def_tbl       => p_ele_def_tbl,
    x_set_id            => x_set_id,
    x_element_id_tbl    => x_element_id_tbl);

    IF (x_return_status = FND_API.G_RET_STS_ERROR) then
       RAISE FND_API.G_EXC_ERROR;
    ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;



--------- end my code ----------------------

-- begin user hooks --

	IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'C' ) THEN
		CS_KNOWLEDGE_CUHK.Create_Set_And_Elements_Post
		(
			p_api_version	 =>	1.0,
			p_init_msg_list	 =>	FND_API.G_FALSE,
			p_commit	 =>	FND_API.G_FALSE,
			x_return_status	 =>	l_return_status,
			x_msg_count	 =>	x_msg_count,
			x_msg_data	 =>	x_msg_data,
                        p_set_def_rec    =>     l_set_def_rec,
                        p_ele_def_tbl    =>     l_ele_def_tbl,
                        x_set_id         =>     x_set_id,
                        x_element_id_tbl =>     x_element_id_tbl);

                IF (l_return_status = FND_API.G_RET_STS_ERROR) then
		       RAISE FND_API.G_EXC_ERROR;
                ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
		       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
		END IF;
	END IF;

	IF JTF_USR_HKS.Ok_to_execute(G_PKG_NAME, l_api_name, 'A', 'V' ) THEN
		CS_KNOWLEDGE_VUHK.Create_Set_And_Elements_Post
		(
			p_api_version	 =>	1.0,
			p_init_msg_list	 =>	FND_API.G_FALSE,
			p_commit	 =>	FND_API.G_FALSE,
			x_return_status	 =>	l_return_status,
			x_msg_count	 =>	x_msg_count,
			x_msg_data	 =>	x_msg_data,
                        p_set_def_rec    =>     l_set_def_rec,
                        p_ele_def_tbl    =>     l_ele_def_tbl,
                        x_set_id         =>     x_set_id,
                        x_element_id_tbl =>     x_element_id_tbl);

                IF (l_return_status = FND_API.G_RET_STS_ERROR) then
		       RAISE FND_API.G_EXC_ERROR;
                ELSIF (l_return_status = FND_API.G_RET_STS_UNEXP_ERROR) then
		       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

		END IF;




	END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    ROLLBACK TO Create_Set_And_Elements_PUB;
    x_return_status := FND_API.G_RET_STS_ERROR ;
    FND_MSG_PUB.Count_And_Get(
      p_encoded => FND_API.G_FALSE,
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




end CS_Knowledge_PUB;

/
