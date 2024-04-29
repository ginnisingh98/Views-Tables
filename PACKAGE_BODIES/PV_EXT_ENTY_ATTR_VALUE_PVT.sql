--------------------------------------------------------
--  DDL for Package Body PV_EXT_ENTY_ATTR_VALUE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_EXT_ENTY_ATTR_VALUE_PVT" AS
 /* $Header: pvxveaxb.pls 115.3 2003/01/08 20:17:15 amaram ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Ext_Enty_Attr_Value_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


 G_PKG_NAME  CONSTANT VARCHAR2(30) := 'PV_Ext_Enty_Attr_Value_PVT';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxveaxb.pls';

 G_USER_ID         NUMBER := NVL(FND_GLOBAL.USER_ID,-1);
 G_LOGIN_ID        NUMBER := NVL(FND_GLOBAL.CONC_LOGIN_ID,-1);



-- Hint: Primary key needs to be returned.
PROCEDURE Update_Customer_Anual_Revenue(
     p_api_version_number     IN   NUMBER
    ,p_init_msg_list          IN   VARCHAR2     := FND_API.G_FALSE
    ,p_commit                 IN   VARCHAR2     := FND_API.G_FALSE
    ,p_validation_level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL

    ,x_return_status          OUT NOCOPY  VARCHAR2
    ,x_msg_count              OUT NOCOPY  NUMBER
    ,x_msg_data               OUT NOCOPY  VARCHAR2

	,p_entity                     IN   VARCHAR2
	,p_entity_id			      IN   NUMBER
	,p_attr_value				  IN   VARCHAR2
    )


 IS
   l_api_name                  CONSTANT VARCHAR2(30) := 'Update_Customer_Anual_Revenue';
   l_full_name                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_api_version_number        CONSTANT NUMBER       := 1.0;
   l_return_status_full                 VARCHAR2(1);
   l_object_version_number              NUMBER       := 1;
   l_partner_update_text				VARCHAR2(2000) :=
										' update  hz_organization_profiles org set org.curr_fy_potential_revenue=  :attr_value where ' ||
										' org.party_id = :party_id'
										;


   l_oppty_update_text					VARCHAR2(2000) := '';
   l_lead_update_text					VARCHAR2(2000) := '';
   l_value								NUMBER;
   l_party_id							NUMBER;

   x_profile_id							NUMBER;
   l_org_rec							HZ_PARTY_V2PUB.organization_rec_type;
 CURSOR c_get_party_ids (pc_entity_id IN NUMBER) IS
   select orgp.party_id from  hz_organization_profiles orgp, hz_relationships hz,
	hz_organization_profiles orgp2 where hz.party_id = pc_entity_id and
	hz.subject_id = orgp.party_id  and hz.object_id = orgp2.party_id and orgp2.internal_flag = 'Y'
	and orgp2.effective_end_date is null and nvl(orgp.effective_end_date, sysdate+1) > sysdate
	;

 CURSOR c_get_obj_ver_num (pc_party_id IN NUMBER) IS
	select object_version_number from hz_parties where party_id = pc_party_id
	;


BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Update_Customer_Anual_Revenue;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Debug Message
	  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
      PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;




   IF(p_entity = 'PARTNER') THEN

	for x in c_get_party_ids(pc_entity_id => p_entity_id )
	loop
		l_party_id := x.party_id;



		l_org_rec.curr_fy_potential_revenue := TO_NUMBER(PV_CHECK_MATCH_PUB.Retrieve_Token(':::',p_attr_value,'IN TOKEN',1));

		if (l_org_rec.curr_fy_potential_revenue is null) then
			l_org_rec.curr_fy_potential_revenue := fnd_api.g_miss_num;
		end if;

		--l_org_rec.curr_fy_potential_revenue := TO_NUMBER(p_attr_value);
	    l_org_rec.pref_functional_currency :=PV_CHECK_MATCH_PUB.Retrieve_Token(':::',p_attr_value,'IN TOKEN',2);
		l_org_rec.party_rec.party_id :=l_party_id;

		if (l_org_rec.pref_functional_currency is null) then
			l_org_rec.pref_functional_currency := fnd_api.g_miss_char;
		end if;


		for x in c_get_obj_ver_num (pc_party_id =>l_party_id)
		loop
			l_object_version_number := x.object_version_number;

		end loop;

		HZ_PARTY_V2PUB.update_organization (
			 p_init_msg_list					=> FND_API.G_FALSE
			,p_organization_rec                 => l_org_rec
			,p_party_object_version_number      => l_object_version_number
			,x_profile_id                       => x_profile_id
			,x_return_status					=> x_return_status
			,x_msg_count						=> x_msg_count
			,x_msg_data							=> x_msg_data
		);



      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
	end loop;
   END IF;	 -- en of IF(p_entity = 'PARTNER') THEN



--
-- End of API body
--

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
	  IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
       PVX_Utility_PVT.debug_message('Private API: '||l_full_name||' - end');
	   END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get (
          p_count          =>   x_msg_count
         ,p_data           =>   x_msg_data
         );

EXCEPTION
/*
    WHEN PVX_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
  PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');
*/
   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Update_Customer_Anual_Revenue;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Customer_Anual_Revenue;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count => x_msg_count
            ,p_data  => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO Update_Customer_Anual_Revenue;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE
            ,p_count => x_msg_count
            ,p_data  => x_msg_data
            );
End Update_Customer_Anual_Revenue;




END PV_Ext_Enty_Attr_Value_PVT;

/
