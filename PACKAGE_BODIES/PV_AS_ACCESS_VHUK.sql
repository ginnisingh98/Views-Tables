--------------------------------------------------------
--  DDL for Package Body PV_AS_ACCESS_VHUK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_AS_ACCESS_VHUK" as
/* $Header: pvxvacsb.pls 120.0 2005/05/27 15:39:07 appldev noship $ */


G_PKG_NAME    CONSTANT VARCHAR2(30):='PV_AS_ACCESS_VHUK';
G_FILE_NAME   CONSTANT VARCHAR2(12):='pvxvacsb.pls';


procedure Validate_Salesteam (
                p_api_version_number  IN  NUMBER,
                p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
                p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
                p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                p_access_id           IN  NUMBER,
                p_lead_id             IN  NUMBER,
                p_salesforce_id       IN  NUMBER,
                p_mode	 	      IN  VARCHAR2,     -- The mode can be CREATE, UPDATE, DELETE
                x_return_status       OUT NOCOPY  VARCHAR2,
                x_msg_count           OUT NOCOPY  NUMBER,
                x_msg_data            OUT NOCOPY  VARCHAR2) is


    l_api_name            CONSTANT  VARCHAR2(30) := 'Validate_Salesteam';
    l_api_version_number  CONSTANT  NUMBER       := 2.0;

    l_lead_id                       NUMBER := p_lead_id; --p_sales_team_rec.salesforce_id;
    l_salesforce_id                 NUMBER := p_salesforce_id; --p_sales_team_rec.salesforce_id;


    l_party_id                      NUMBER;
    l_relationship_type             VARCHAR2(300);
    l_prm_keep_flag                 VARCHAR2(10);

    -- Required by getWorkflowID
    l_entity		VARCHAR2(200)  := 'OPPORTUNITY';
    l_itemType      VARCHAR2(300);
    l_itemKey       VARCHAR2(300);
    l_routing_status      varchar2(300);
    l_wf_status		VARCHAR2(200);



-- new query to support directional flag
CURSOR lc_get_rel_type(pc_salesforce_id number) is
SELECT
  PTORG.relationship_code
FROM
  hz_relationships CONTACT,
  hz_relationships PTORG,
  pv_partner_profiles PVPP,
  jtf_rs_resource_extns EXTN
WHERE EXTN.resource_id =  pc_salesforce_id
AND   EXTN.source_id = CONTACT.party_id
AND   EXTN.category  = 'PARTY'
AND   CONTACT.subject_table_name = 'HZ_PARTIES'
AND   CONTACT.object_table_name  = 'HZ_PARTIES'
AND   CONTACT.RELATIONSHIP_TYPE  = 'EMPLOYMENT'
AND   CONTACT.RELATIONSHIP_CODE  = 'EMPLOYEE_OF'
AND   CONTACT.directional_flag   = 'F'
AND   CONTACT.STATUS       =  'A'
AND   CONTACT.start_date <= SYSDATE
AND   nvl(CONTACT.end_date, SYSDATE) >= SYSDATE
AND   PTORG.subject_id   =  CONTACT.object_id
AND   PTORG.subject_table_name = 'HZ_PARTIES'
AND   PTORG.object_table_name = 'HZ_PARTIES'
AND   PTORG.RELATIONSHIP_TYPE = 'PARTNER'
AND   PTORG.STATUS       =  'A'
AND   PTORG.start_date <= SYSDATE
AND   nvl(PTORG.end_date, SYSDATE) >= SYSDATE
AND   PVPP.partner_party_id = PTORG.object_id
AND   PVPP.partner_id = PTORG.party_id
AND   PVPP.SALES_PARTNER_FLAG   = 'Y'
AND   PVPP.status = 'A'
ORDER BY PTORG.relationship_code desc;


CURSOR lc_get_prm_flag(pc_access_id number) is
    SELECT  prm_keep_flag
    FROM    as_accesses_all
    WHERE   access_id = pc_access_id;

l_get_upd_del_check_perm                 VARCHAR2(1) := 'N';

CURSOR lc_get_upd_del_check_perm(pc_lead_id number, pc_access_id number) is

SELECT
1 from as_accesses_all acc ,  hz_relationships hzpp , hz_parties ptorg,
 fnd_user fndu, jtf_rs_resource_extns jtfre,
 hz_parties ptorg1 ,hz_relationships hzpp1
 WHERE
 acc.partner_cont_party_id = hzpp.party_id and
 hzpp.object_id = ptorg.party_id and
 ptorg.party_type = 'ORGANIZATION' and
 --acc.salesforce_id = pc_sales_force_id and
 acc.access_id = pc_access_id and
  fndu.user_id = fnd_global.user_id and
 jtfre.user_id = fndu.user_id  and
 jtfre.source_id = hzpp1.party_id and
 hzpp1.object_id = ptorg1.party_id and
 ptorg1.party_type = 'ORGANIZATION' and
 acc.lead_id = pc_lead_id and
 ptorg1.party_id=ptorg.party_id
 ;

 CURSOR lc_is_partner_user is

 SELECT    'PARTNER_OF'
   FROM
      hz_relationships CONTACT,
      pv_partner_profiles PVPP,
      jtf_rs_resource_extns EXTN,
      fnd_user fndu
   WHERE fndu.user_id = fnd_global.user_id
   AND EXTN.user_id = fndu.user_id
   AND CONTACT.party_id = EXTN.source_id
   AND   CONTACT.subject_table_name = 'HZ_PARTIES'
   AND   CONTACT.object_table_name  = 'HZ_PARTIES'
   AND   CONTACT.RELATIONSHIP_TYPE  = 'EMPLOYMENT'
   AND   CONTACT.RELATIONSHIP_CODE  = 'EMPLOYEE_OF'
   AND   CONTACT.directional_flag   = 'F'
   AND   CONTACT.STATUS       =  'A'
   AND   CONTACT.start_date <= SYSDATE
   AND   nvl(CONTACT.end_date, SYSDATE) >= SYSDATE
   AND   PVPP.partner_party_id   =  CONTACT.object_id
   ;

l_is_partner_user                 VARCHAR2(1) := 'N';

BEGIN
--FND_MSG_PUB.G_MSG_LEVEL_THRESHOLD := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call(l_api_version_number,
                                      p_api_version_number,
                                      l_api_name,
                                      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
   END IF;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || ' , access > ' || p_access_id || ',  lead_id > ' || p_lead_id || ',  salesforce > ' || l_salesforce_id || ', api version >  ' || p_api_version_number);
      fnd_msg_pub.Add;
   END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'before pv_assignment_pvt.GetWorkflowID');
      fnd_msg_pub.Add;
   END IF;

   -- if its a customer, lead_id will be null
   if p_lead_id is null then
    return;
   end if;

   -- call getWorkflowId to check the Workflow status
   pv_assign_util_pvt.GetWorkflowID (p_api_version_number  => 1.0,
                                    p_init_msg_list       => FND_API.G_FALSE,
                                    p_commit              => FND_API.G_FALSE,
                                    p_validation_level    => p_validation_level,
                                    p_lead_id             => l_lead_id,
                                    p_entity              => l_entity,
                                    x_itemType            => l_itemType,
                                    x_itemKey             => l_itemKey,
                                    x_routing_status      => l_routing_status,
                                    x_wf_status           => l_wf_status,
                                    x_return_status       => x_return_status,
                                    x_msg_count           => x_msg_count,
                                    x_msg_data            => x_msg_data);

    IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'After pv_assignment_pvt.GetWorkflowID : wf status  : ' || l_wf_status);
      fnd_msg_pub.Add;
   END IF;

   OPEN    lc_get_rel_type (pc_salesforce_id => l_salesforce_id);
            FETCH   lc_get_rel_type
            INTO    l_relationship_type;
            CLOSE   lc_get_rel_type;

    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
       fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
       fnd_message.Set_Token('TEXT', 'Relationship Type : ' || l_relationship_type);
       fnd_msg_pub.Add;
    END IF;

    -- wf_status could be OPEN and routing_status ACTIVE in case of Joint
    IF l_wf_status = g_wf_status_open and l_routing_status <> 'ACTIVE' THEN

        IF p_mode = 'CREATE' then

           /* OPEN    lc_get_rel_type (pc_salesforce_id => l_salesforce_id);
            FETCH   lc_get_rel_type
            INTO    l_relationship_type;
            CLOSE   lc_get_rel_type;

            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
               fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
               fnd_message.Set_Token('TEXT', 'Relationship Type : ' || l_relationship_type);
               fnd_msg_pub.Add;
            END IF;
	   */
            IF (l_relationship_type IS NULL) THEN
               IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                  fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                  fnd_message.Set_Token('TEXT', 'Resource id: ' || l_salesforce_id || ' is not a partner user. Returning');
                  fnd_msg_pub.Add;
               END IF;
               return;
            ELSIF l_relationship_type = 'PARTNER_OF'  THEN
                fnd_message.SET_NAME('PV', 'PV_ADDSLSTEAM_NOT_ALLOWED'); -- Change message 1 ********************
                fnd_msg_pub.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

        ELSIF p_mode = 'DELETE' or p_mode = 'UPDATE' then

            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
               fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
               fnd_message.Set_Token('TEXT', 'In Delete / Update block ');
               fnd_msg_pub.Add;
            END IF;

            OPEN    lc_get_prm_flag(pc_access_id => p_access_id);
            FETCH   lc_get_prm_flag
            INTO    l_prm_keep_flag;
            CLOSE   lc_get_prm_flag;

            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
               fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
               fnd_message.Set_Token('TEXT', 'After PRM KEEP FLAG check : ' || l_prm_keep_flag);
               fnd_msg_pub.Add;
            END IF;

            IF (l_prm_keep_flag  = 'Y') THEN
                fnd_message.SET_NAME('PV', 'PV_UPDSLSTEAM_NOT_ALLOWED'); -- Change message 1 ********************
                fnd_msg_pub.ADD;
                RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
               fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
               fnd_message.Set_Token('TEXT', 'Success ..... ');
               fnd_msg_pub.Add;
            END IF;

        END IF;

    ELSE
        -- Workflow is not running. return success mesage and continue with the calling API
        NULL;

    END IF; -- Workflow open or not



    --Checking if user can update or delete sales team.
    --Logged in user can update or delete sales team if \user belongs to the
    --organisation of the person he tries to update or delete.
    --for bug# 3439126
    -- this condition only applies for partner user

    IF p_mode = 'DELETE' or p_mode = 'UPDATE' then

	    for x in lc_get_upd_del_check_perm(pc_lead_id =>p_lead_id,pc_access_id => p_access_id)
	    loop
		l_get_upd_del_check_perm := 'Y' ;
	    end loop;

	    --to find if logged in user is partner user

	    for x in lc_is_partner_user
	    loop
		l_is_partner_user := 'Y' ;
	    end loop;



	    if(l_get_upd_del_check_perm = 'N' and
	       l_is_partner_user = 'Y' )

	    then

		IF (FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_ERROR)) THEN
			FND_MESSAGE.Set_Name('PV', 'PV_USER_NOT_UPD_DEL_EXT_SLSTM');
			--FND_MESSAGE.Set_Token('ATTRIBUTE_NAME',p_attribute_rec.name );
			--FND_MESSAGE.Set_Token('RESPONSIBILITY_LIST',substr(l_being_used_list,2) );
			FND_MSG_PUB.Add;
		END IF;
		RAISE FND_API.G_EXC_ERROR;
	    end if;
    end if;



     -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                               p_count     =>  x_msg_count,
                               p_data      =>  x_msg_data);

EXCEPTION

  WHEN NO_DATA_FOUND THEN
      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.Set_Token('TEXT', 'NO Data found ..');
         fnd_msg_pub.Add;
      END IF;

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

END Validate_Salesteam;


procedure Create_Salesteam_Pre (
                p_api_version_number  IN  NUMBER,
                p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
                p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
                p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                p_lead_id             IN  NUMBER,
                p_salesforce_id       IN  NUMBER,
                x_return_status       OUT NOCOPY  VARCHAR2,
                x_msg_count           OUT NOCOPY  NUMBER,
                x_msg_data            OUT NOCOPY  VARCHAR2) is

    l_api_name            CONSTANT  VARCHAR2(30) := 'Create_Salesteam_Pre';
    l_api_version_number  CONSTANT  NUMBER       := 2.0;

    l_mode      CONSTANT  VARCHAR2(20) := 'CREATE';

BEGIN
--FND_MSG_PUB.G_MSG_LEVEL_THRESHOLD := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call(l_api_version_number,
                                      p_api_version_number,
                                      l_api_name,
                                      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
   END IF;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || ' ' || p_lead_id || ' ' || p_salesforce_id || ' ' || p_api_version_number);
      fnd_msg_pub.Add;
   END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- if its a customer, lead_id will be null
   if p_lead_id is null then
    return;
   end if;

    Validate_Salesteam (
                p_api_version_number  => l_api_version_number,
                p_init_msg_list       => p_init_msg_list,
                p_commit              => p_commit,
                p_validation_level    => p_validation_level,
                p_access_id           => null,
                p_lead_id             => p_lead_id,
                p_salesforce_id       => p_salesforce_id,
                p_mode	    	     => l_mode,
                x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data);

    IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                               p_count     =>  x_msg_count,
                               p_data      =>  x_msg_data);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

END Create_Salesteam_Pre;

procedure Update_Salesteam_Pre (
                p_api_version_number  IN  NUMBER,
                p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
                p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
                p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                p_access_id           IN  NUMBER,
                p_lead_id             IN  NUMBER,
                x_return_status       OUT NOCOPY  VARCHAR2,
                x_msg_count           OUT NOCOPY  NUMBER,
                x_msg_data            OUT NOCOPY  VARCHAR2) is

    l_api_name            CONSTANT  VARCHAR2(30) := 'Update_Salesteam_Pre';
    l_api_version_number  CONSTANT  NUMBER       := 2.0;

    l_mode      CONSTANT  VARCHAR2(20) := 'UPDATE';
BEGIN
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call(l_api_version_number,
                                      p_api_version_number,
                                      l_api_name,
                                      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
   END IF;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || ' , access id :  ' || p_access_id );
      fnd_msg_pub.Add;
   END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

     Validate_Salesteam (
                p_api_version_number  => l_api_version_number,
                p_init_msg_list       => p_init_msg_list,
                p_commit              => p_commit,
                p_validation_level    => p_validation_level,
                p_access_id           => p_access_id,
                p_lead_id             => p_lead_id,
                p_salesforce_id       => null,
                p_mode	 	      => l_mode,
                x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data);


    IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                               p_count     =>  x_msg_count,
                               p_data      =>  x_msg_data);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

END Update_Salesteam_Pre;

procedure Delete_Salesteam_Pre (
                p_api_version_number  IN  NUMBER,
                p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
                p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
                p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                p_access_id           IN  NUMBER,
                p_lead_id             IN  NUMBER,
                x_return_status       OUT NOCOPY  VARCHAR2,
                x_msg_count           OUT NOCOPY  NUMBER,
                x_msg_data            OUT NOCOPY  VARCHAR2) is

    l_api_name            CONSTANT  VARCHAR2(30) := 'Delete_Salesteam_Pre';
    l_api_version_number  CONSTANT  NUMBER       := 2.0;
    l_mode      CONSTANT  VARCHAR2(20) := 'DELETE';

BEGIN

 --FND_MSG_PUB.g_msg_level_threshold := FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW;

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call(l_api_version_number,
                                      p_api_version_number,
                                      l_api_name,
                                      G_PKG_NAME)
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
   END IF;


   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || ' , access id  : ' || p_access_id );
      fnd_msg_pub.Add;
   END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    Validate_Salesteam (
                p_api_version_number  => l_api_version_number,
                p_init_msg_list       => p_init_msg_list,
                p_commit              => p_commit,
                p_validation_level    => p_validation_level,
                p_access_id           => p_access_id,
                p_lead_id             => p_lead_id,
                p_salesforce_id       => null,
                p_mode	 	      => l_mode,
                x_return_status       => x_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data);

    IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                               p_count     =>  x_msg_count,
                               p_data      =>  x_msg_data);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

END Delete_Salesteam_Pre;

END PV_AS_ACCESS_VHUK;

/
