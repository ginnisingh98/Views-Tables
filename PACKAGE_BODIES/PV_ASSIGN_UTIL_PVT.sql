--------------------------------------------------------
--  DDL for Package Body PV_ASSIGN_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ASSIGN_UTIL_PVT" as
/* $Header: pvvautlb.pls 120.9 2006/02/23 14:22:38 amaram ship $ */
-- Start of Comments

-- Package name     : PV_ASSIGN_UTIL_PVT
-- Purpose          :
-- History          :
-- Modified: amaram 01-sep-2001  Removing the reference to ASF_DEFAULT_GROUP_ROLE. Defaulting to one of the groups
--                               returned by Get_Salesgroup_ID Function.
--
-- NOTE             :
-- End of Comments
--


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_ASSIGN_UTIL_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvvautlb.pls';

-- private API called by get_partner_info only

g_tap_role_channel_manager  CONSTANT VARCHAR2(30) := 'CHANNEL_MANAGER';
g_tap_role_partner_contact  CONSTANT VARCHAR2(30) := 'PARTNER_CONTACT_MEMBER';

-- -----------------------------------------------------------------------------------
-- Private PRocedure Declaration
-- -----------------------------------------------------------------------------------
PROCEDURE Debug(
   p_msg_string    IN VARCHAR2
);


PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2 := NULL,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL
);

FUNCTION Get_Salesgroup_ID (
   p_resource_id   NUMBER
)
RETURN NUMBER;

-- -----------------------------------------------------------------------------------
-- Code starts...
-- -----------------------------------------------------------------------------------

PROCEDURE removePreferedPartner (
      p_api_version_number  IN  NUMBER
   ,  p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,  p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,  p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,  p_lead_id             IN  NUMBER
   ,  p_item_type           IN  VARCHAR2
   ,  p_item_key            IN  VARCHAR2
   ,  p_partner_id          IN  NUMBER
   ,  x_return_status       OUT NOCOPY  VARCHAR2
   ,  x_msg_count           OUT NOCOPY  NUMBER
   ,  x_msg_data            OUT NOCOPY  VARCHAR2)
 IS

   l_api_name            CONSTANT VARCHAR2(30) := 'removePreferedPartner';
   l_api_version_number  CONSTANT NUMBER       := 1.0;

   l_flag                VARCHAR2(10);

   CURSOR lc_chk_pf_pt ( pc_lead_id NUMBER
                        ,pc_partner_id NUMBER)
   IS
   SELECT 'X'
   FROM   as_leads_all
   WHERE  lead_id                    = pc_lead_id
   AND    incumbent_partner_party_id = pc_partner_id;


   CURSOR lc_chk_pf_ass_pt ( pc_lead_id   NUMBER
                       , pc_item_key  VARCHAR2
                       , pc_item_type VARCHAR2)
   IS
   SELECT 'X'
   FROM   as_leads_all al
        , pv_lead_assignments ass
   WHERE  al.lead_id                    = ass.lead_id
   AND    al.incumbent_partner_party_id = ass.partner_id
   AND    ass.wf_item_type              = pc_item_type
   AND    ass.wf_item_key               = pc_item_key
   AND    al.lead_id                    = pc_lead_id ;

 BEGIN

    IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.SET_NAME('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_token('TEXT', 'In ' || l_api_name);
      fnd_msg_pub.Add;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   IF  p_lead_id IS NOT NULL
   AND p_partner_id  IS NOT NULL
   THEN
      OPEN lc_chk_pf_pt ( p_lead_id,  p_partner_id);
      FETCH lc_chk_pf_pt INTO l_flag;
      CLOSE  lc_chk_pf_pt;
   ELSIF p_lead_id IS NOT NULL
   AND   p_item_key IS NOT NULL
   AND   p_item_type IS NOT NULL
   THEN

      OPEN lc_chk_pf_ass_pt ( p_lead_id
                            , p_item_key
                            , p_item_type);
      FETCH lc_chk_pf_ass_pt INTO l_flag;
      CLOSE  lc_chk_pf_ass_pt;

   END IF;

   IF l_flag IS NOT NULL
   AND p_lead_id IS NOT NULL
   THEN

      UPDATE as_leads_all
      SET    incumbent_partner_party_id = NULL  ,
             incumbent_partner_resource_id = NULL
      WHERE  lead_id = p_lead_id;

   END IF;
   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
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

END;


procedure Log_assignment_status (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_assignment_rec      IN  ASSIGNMENT_REC_TYPE
   ,x_return_status       OUT NOCOPY  VARCHAR2
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2) is

   l_api_name            CONSTANT VARCHAR2(30) := 'log_assignment_status';
   l_api_version_number  CONSTANT NUMBER       := 1.0;

   l_access_level    varchar2(1) := 'V';
   l_message_name    varchar2(30);
   l_log_params_tbl  pvx_utility_pvt.log_params_tbl_type;

   cursor lc_get_opp_number (pc_lead_id number) is
      select lead_number from as_leads_all where lead_id = pc_lead_id;

   l_lead_number varchar2(50);

begin
   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.SET_NAME('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_token('TEXT', 'In ' || l_api_name);
      fnd_msg_pub.Add;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   if p_assignment_rec.status in ( 'CM_ADDED','CM_ADD_APP_FOR_PT','UNASSIGNED') then
      -- not used statuses. Added just in case
      null;
   else
      -- all routing status messages are listed here
      -- PV_LG_RTNG_ASSIGNED
      -- PV_LG_RTNG_CM_APPROVED
      -- PV_LG_RTNG_CM_APP_FOR_PT
      -- PV_LG_RTNG_CM_BYPASSED
      -- PV_LG_RTNG_CM_REJECTED
      -- PV_LG_RTNG_CM_TIMEOUT
      -- PV_LG_RTNG_LOST_CHANCE
      -- PV_LG_RTNG_MATCH_WITHDRAWN
      -- PV_LG_RTNG_OFFER_WITHDRAWN
      -- PV_LG_RTNG_PT_ABANDONED
      -- PV_LG_RTNG_PT_APPROVED
      -- PV_LG_RTNG_PT_CREATED
      -- PV_LG_RTNG_PT_REJECTED
      -- PV_LG_RTNG_PT_TIMEOUT

      open lc_get_opp_number(pc_lead_id => p_assignment_rec.lead_id);
      fetch lc_get_opp_number into l_lead_number;
      close lc_get_opp_number;

      l_log_params_tbl(1).param_name := 'OPP_NUMBER';
      l_log_params_tbl(1).param_value := l_lead_number;

      l_message_name := 'PV_LG_RTNG_' || p_assignment_rec.status;
   end if;

   if l_message_name is not null then
      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
	 fnd_message.SET_NAME('PV', 'PV_DEBUG_MESSAGE');
	 fnd_message.Set_token('TEXT', 'Logging routing message: ' || l_message_name ||
		   ' for lead_id:' || p_assignment_rec.lead_id || ' for partner_id:' || p_assignment_rec.partner_id);
	 fnd_msg_pub.Add;
      END IF;

      PVX_Utility_PVT.create_history_log(
	 p_arc_history_for_entity_code => 'OPPORTUNITY',
	 p_history_for_entity_id       => p_assignment_rec.lead_id,
	 p_history_category_code       => 'GENERAL',
	 p_message_code                => l_message_name,
	 p_partner_id                  => p_assignment_rec.partner_id,
	 p_access_level_flag           => l_access_level,
	 p_interaction_level           => pvx_utility_pvt.G_INTERACTION_LEVEL_50,
	 p_comments                    => NULL,
	 p_log_params_tbl              => l_log_params_tbl,
	 x_return_status               => x_return_status,
	 x_msg_count                   => x_msg_count,
	 x_msg_data                    => x_msg_data);

      if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
	 raise FND_API.G_EXC_ERROR;
      end if;
   end if;

   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
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
end;


PROCEDURE Create_party_notification(
    P_Api_Version_Number     IN   NUMBER,
    P_Init_Msg_List          IN   VARCHAR2     := FND_API.G_FALSE,
    P_Commit                 IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level       IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    P_party_notify_Rec       IN   PV_ASSIGN_UTIL_PVT.PARTY_NOTIFY_REC_TYPE,
    X_PARTY_NOTIFICATION_ID  OUT  NOCOPY   NUMBER,
    X_Return_Status          OUT  NOCOPY   VARCHAR2,
    X_Msg_Count              OUT  NOCOPY   NUMBER,
    X_Msg_Data               OUT  NOCOPY   VARCHAR2
    )

IS
   l_api_name            CONSTANT VARCHAR2(30) := 'Create_party_notification';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   CURSOR C2 IS SELECT PV_PARTY_NOTIFICATIONS_S.nextval FROM sys.dual;
   l_party_notification_id number;

BEGIN

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
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name);
      fnd_msg_pub.Add;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   --
   -- API body
   --

   OPEN C2;
   FETCH C2 INTO l_party_notification_id;
   CLOSE C2;


   INSERT into pv_party_notifications (
      PARTY_NOTIFICATION_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      OBJECT_VERSION_NUMBER,
      REQUEST_ID,
      PROGRAM_APPLICATION_ID,
      PROGRAM_ID,
      PROGRAM_UPDATE_DATE,
      NOTIFICATION_ID,
      NOTIFICATION_TYPE,
      LEAD_ASSIGNMENT_ID,
      WF_ITEM_TYPE,
      WF_ITEM_KEY,
      USER_ID,
      --USER_NAME,
      RESOURCE_ID,
      DECISION_MAKER_FLAG,
      RESOURCE_RESPONSE,
      RESPONSE_DATE,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15
   ) values (
      l_party_notification_id,
      sysdate,
      fnd_global.user_id,
      sysdate,
      fnd_global.user_id,
      fnd_global.conc_login_id,
      1,
      p_party_notify_rec.REQUEST_ID,
      p_party_notify_rec.PROGRAM_APPLICATION_ID,
      p_party_notify_rec.PROGRAM_ID,
      p_party_notify_rec.PROGRAM_UPDATE_DATE,
      p_party_notify_rec.NOTIFICATION_ID,
      p_party_notify_rec.NOTIFICATION_TYPE,
      p_party_notify_rec.LEAD_ASSIGNMENT_ID,
      p_party_notify_rec.WF_ITEM_TYPE,
      p_party_notify_rec.WF_ITEM_KEY,
      p_party_notify_rec.USER_ID,
      --p_party_notify_rec.USER_NAME,
      p_party_notify_rec.RESOURCE_ID,
      p_party_notify_rec.DECISION_MAKER_FLAG,
      p_party_notify_rec.RESOURCE_RESPONSE,
      p_party_notify_rec.RESPONSE_DATE,
      p_party_notify_rec.ATTRIBUTE_CATEGORY,
      p_party_notify_rec.ATTRIBUTE1,
      p_party_notify_rec.ATTRIBUTE2,
      p_party_notify_rec.ATTRIBUTE3,
      p_party_notify_rec.ATTRIBUTE4,
      p_party_notify_rec.ATTRIBUTE5,
      p_party_notify_rec.ATTRIBUTE6,
      p_party_notify_rec.ATTRIBUTE7,
      p_party_notify_rec.ATTRIBUTE8,
      p_party_notify_rec.ATTRIBUTE9,
      p_party_notify_rec.ATTRIBUTE10,
      p_party_notify_rec.ATTRIBUTE11,
      p_party_notify_rec.ATTRIBUTE12,
      p_party_notify_rec.ATTRIBUTE13,
      p_party_notify_rec.ATTRIBUTE14,
      p_party_notify_rec.ATTRIBUTE15
   );

   x_party_notification_id := l_party_notification_id;

   --
   -- End of API body
   --

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )
   THEN
       COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (  p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

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
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

End Create_party_notification;


procedure create_lead_assignment_row (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_assignment_rec      IN  ASSIGNMENT_REC_TYPE
   ,x_lead_assignment_id  OUT NOCOPY  NUMBER
   ,x_return_status       OUT NOCOPY  VARCHAR2
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2) is

   l_api_name            CONSTANT VARCHAR2(30) := 'create_lead_assignment_row';
   l_api_version_number  CONSTANT NUMBER       := 1.0;

   l_lead_assignment_id  number;

begin
   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.SET_NAME('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_token('TEXT', 'In ' || l_api_name);
      fnd_msg_pub.Add;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   if p_assignment_rec.SOURCE_TYPE not in ('CAMPAIGN', 'MATCHING', 'TAP', 'SALESTEAM') then
      fnd_message.SET_NAME('PV', 'PV_INVALID_SOURCE_TYPE');
      fnd_msg_pub.ADD;

      raise FND_API.G_EXC_ERROR;
   end if;

   select pv_lead_assignments_s.nextval into l_Lead_assignment_ID from sys.dual;

-- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.SET_NAME('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_token('TEXT', 'p_assignment_rec.wf_item_type ' || p_assignment_rec.wf_item_type||
                'p_assignment_rec.wf_item_key ' || p_assignment_rec.wf_item_key||
                'p_assignment_rec.lead_id ' || p_assignment_rec.lead_id||
                'p_assignment_rec.partner_id ' || p_assignment_rec.partner_id);
      fnd_msg_pub.Add;
   END IF;

   insert into pv_lead_assignments(
      LEAD_ASSIGNMENT_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      OBJECT_VERSION_NUMBER,
      LEAD_ID,
      PARTNER_ID,
      PARTNER_ACCESS_CODE,
      RELATED_PARTY_ID,
      RELATED_PARTY_ACCESS_CODE,
      ASSIGN_SEQUENCE,
      STATUS_DATE,
      STATUS,
      REASON_CODE,
      SOURCE_TYPE,
      WF_ITEM_TYPE,
      WF_ITEM_KEY,
      ERROR_TXT
   ) values (
      l_Lead_assignment_ID,
      sysdate,
      fnd_global.user_id,
      sysdate,
      fnd_global.user_id,
      fnd_global.conc_login_id,
      0,
      p_assignment_rec.LEAD_ID,
      p_assignment_rec.PARTNER_ID,
      p_assignment_rec.PARTNER_ACCESS_CODE,
      p_assignment_rec.RELATED_PARTY_ID,
      p_assignment_rec.RELATED_PARTY_ACCESS_CODE,
      p_assignment_rec.ASSIGN_SEQUENCE,
      p_assignment_rec.STATUS_DATE,
      p_assignment_rec.STATUS,
      p_assignment_rec.REASON_CODE,
      p_assignment_rec.SOURCE_TYPE,
      p_assignment_rec.WF_ITEM_TYPE,
      nvl(p_assignment_rec.WF_ITEM_KEY, l_lead_assignment_id),
      p_assignment_rec.ERROR_TXT
      );

      -- nvl(p_assignment_rec.WF_ITEM_KEY, l_lead_assignment_id),
      -- needed for UI saving assignments.  Prevents unique
      -- violation errors.  UI does not set itemtype or itemkey
      -- there is unique index on lead_id,partner_id,wf_item_key

   if p_assignment_rec.wf_item_key is not null then

      Log_assignment_status (
	 p_api_version_number  => 1.0,
	 p_init_msg_list       => FND_API.G_FALSE,
	 p_commit              => FND_API.G_FALSE,
	 p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
	 p_assignment_rec      => p_assignment_rec,
	 x_return_status       => x_return_status,
	 x_msg_count           => x_msg_count,
	 x_msg_data            => x_msg_data);

      if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
	 raise FND_API.G_EXC_ERROR;
      end if;

   end if;

   x_lead_assignment_id := l_lead_assignment_id;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.SET_NAME('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_token('TEXT', 'x_lead_assignment_id ' || x_lead_assignment_id);
      fnd_msg_pub.Add;
   END IF;

   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
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

end create_lead_assignment_row;


procedure create_lead_workflow_row (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_workflow_rec        IN  LEAD_WORKFLOW_REC_TYPE
   ,x_itemkey             OUT NOCOPY  VARCHAR2
   ,x_return_status       OUT NOCOPY  VARCHAR2
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2) is

   l_api_name            CONSTANT VARCHAR2(30) := 'create_lead_workflow_row';
   l_api_version_number  CONSTANT NUMBER       := 1.0;

   l_lead_workflow_id    number;

  CURSOR lc_get_user_type (pc_user_id NUMBER) IS
   SELECT extn.category
   FROM   fnd_user fuser,
          jtf_rs_resource_extns extn
   WHERE  fuser.user_id = pc_user_id
   AND    fuser.user_id   = extn.user_id;

   l_oppty_routing_log_rec  PV_ASSIGNMENT_PVT.oppty_routing_log_rec_type;
   l_user_category          VARCHAR2(40);
   l_user_id                NUMBER;
BEGIN
   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.SET_NAME('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_token('TEXT', 'In ' || l_api_name);
      fnd_msg_pub.Add;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   select pv_lead_workflows_s.nextval into l_Lead_Workflow_ID from sys.dual;

   insert into pv_lead_workflows(
      LEAD_WORKFLOW_ID,
      LAST_UPDATE_DATE,
      LAST_UPDATED_BY,
      CREATION_DATE,
      CREATED_BY,
      LAST_UPDATE_LOGIN,
      OBJECT_VERSION_NUMBER,
      LEAD_ID,
      ENTITY,
      WF_ITEM_TYPE,
      WF_ITEM_KEY,
      ROUTING_TYPE,
      ROUTING_STATUS,
      WF_STATUS,
      MATCHED_DUE_DATE,
      OFFERED_DUE_DATE,
      BYPASS_CM_OK_FLAG,
      LATEST_ROUTING_FLAG,
      FAILURE_CODE,
      FAILURE_MESSAGE
   ) values (
      l_Lead_Workflow_ID,
      sysdate,
      nvl(p_workflow_rec.last_updated_by, fnd_global.user_id),
      sysdate,
      nvl(p_workflow_rec.created_by, fnd_global.user_id),
      fnd_global.conc_login_id,
      0,
      p_workflow_rec.Lead_ID,
      p_workflow_rec.Entity,
      p_workflow_rec.wf_Item_Type,
      to_char(l_lead_workflow_id),
      p_workflow_rec.routing_type,
      p_workflow_rec.routing_status,
      p_workflow_rec.wf_status,
      null,
      null,
      p_workflow_rec.bypass_cm_ok_flag,
      p_workflow_rec.latest_routing_flag,
      p_workflow_rec.failure_code,
      p_workflow_rec.failure_message
      );

   x_itemkey := to_char(l_lead_workflow_id);

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.SET_NAME('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_token('TEXT', 'Row created in pv_lead_workflows ');
      fnd_msg_pub.Add;
   END IF;

   IF p_workflow_rec.routing_status = PV_ASSIGNMENT_PUB.g_r_status_failed_auto  THEN

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.SET_NAME('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_token('TEXT', 'Logging in routing history'||p_workflow_rec.routing_type);
      fnd_msg_pub.Add;
   END IF;
        l_user_id :=  nvl(p_workflow_rec.last_updated_by, fnd_global.user_id);

        OPEN  lc_get_user_type (l_user_id);
        FETCH lc_get_user_type INTO l_user_category;
        CLOSE lc_get_user_type;

        IF  l_user_category = PV_ASSIGNMENT_PUB.g_resource_employee  THEN
            l_oppty_routing_log_rec.vendor_user_id          := l_user_id;
            l_oppty_routing_log_rec.pt_contact_user_id      := TO_NUMBER(NULL);
        ELSIF l_user_category = PV_ASSIGNMENT_PUB.g_resource_party THEN
            l_oppty_routing_log_rec.vendor_user_id          := NULL;
            l_oppty_routing_log_rec.pt_contact_user_id      := l_user_id;
        END IF;
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.SET_NAME('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_token('TEXT', 'Logging in routing history 2');
      fnd_msg_pub.Add;
   END IF;

      l_oppty_routing_log_rec.event                   := 'ASSIGN_FAIL';
      l_oppty_routing_log_rec.lead_id                 := p_workflow_rec.Lead_ID;
      l_oppty_routing_log_rec.lead_workflow_id        := l_lead_workflow_id;
      l_oppty_routing_log_rec.routing_type            := p_workflow_rec.routing_type;
      l_oppty_routing_log_rec.latest_routing_flag     := p_workflow_rec.latest_routing_flag;
      l_oppty_routing_log_rec.bypass_cm_flag          := p_workflow_rec.bypass_cm_ok_flag;
      l_oppty_routing_log_rec.lead_assignment_id      := TO_NUMBER(NULL);
      l_oppty_routing_log_rec.event_date              := SYSDATE;
      l_oppty_routing_log_rec.user_response           := NULL;
      l_oppty_routing_log_rec.reason_code             := p_workflow_rec.failure_code;
      l_oppty_routing_log_rec.user_type               := 'LAM';

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.SET_NAME('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_token('TEXT', 'Logging in routing history 3');
      fnd_msg_pub.Add;
   END IF;
      pv_assignment_pvt.Create_Oppty_Routing_Log_Row (
         p_api_version_number    => 1.0,
         p_init_msg_list         => FND_API.G_FALSE,
         p_commit                => FND_API.G_FALSE,
         p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
         P_oppty_routing_log_rec => l_oppty_routing_log_rec,
         x_return_status         => x_return_status,
         x_msg_count             => x_msg_count,
         x_msg_data              => x_msg_data);
   END IF;
   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
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

end create_lead_workflow_row;


procedure delete_lead_assignment_row (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_lead_assignment_id  IN  NUMBER
   ,x_return_status       OUT NOCOPY  VARCHAR2
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2) is

   l_api_name            CONSTANT VARCHAR2(30) := 'delete_lead_assignment_row';
   l_api_version_number  CONSTANT NUMBER       := 1.0;

begin
   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )
   THEN
      fnd_msg_pub.initialize;
   END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.SET_NAME('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_token('TEXT', 'In ' || l_api_name);
      fnd_msg_pub.Add;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   delete from pv_lead_assignments
   where lead_assignment_id = p_lead_assignment_id;

   if sql%rowcount <> 1 then

      -- happening because submit routing for the same oppty was selected twice before the first
      -- routing completed and this API
      -- was called to delete the saved partner list before invoking the createAssignment API
      -- Do not raise an exception in this case.  Bug 3088598

      fnd_message.SET_NAME('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.SET_token('TEXT', 'Deleted ' || sql%rowcount || ' rows. Should have deleted 1 row');
      fnd_msg_pub.ADD;

      -- RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   end if;

   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
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

end delete_lead_assignment_row;


procedure get_partner_info (
   p_api_version_number  IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_mode                IN  VARCHAR2,                                  -- VENDOR or EXTERNAL
   p_partner_id          IN  NUMBER,
   p_entity              IN  VARCHAR2,                                  -- LEAD,OPPORTUNITY or PARTNER
   p_entity_id           IN  NUMBER,
   p_retrieve_mode       IN  VARCHAR2,
   x_rs_details_tbl      IN  OUT NOCOPY RESOURCE_DETAILS_TBL_TYPE,
   x_vad_id              IN OUT NOCOPY  NUMBER,
   x_return_status       OUT NOCOPY  VARCHAR2,
   x_msg_count           OUT NOCOPY  NUMBER,
   x_msg_data            OUT NOCOPY  VARCHAR2) is

   l_api_name            CONSTANT VARCHAR2(30) := 'get_partner_info';
   l_api_version_number  CONSTANT NUMBER       := 1.0;

   l_rs_details_tbl_cnt  pls_integer := 0;

   l_pt_user_rs_id_tbl      JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_pt_default_rs_id_tbl   pv_assignment_pub.g_number_table_type := pv_assignment_pub.g_number_table_type();

   l_pt_user_rs_id       number;
   l_partner_id          number;
   l_pt_to_vad_id        number;

   l_all_cm_rs_id        varchar2(1500) := ' ';
   l_cm_origin           varchar2(20);
   l_usertype       varchar2(20);
   l_person_type         varchar2(20);
   l_cm_rs_id_tbl        JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_cm_origin_tbl       pv_assignment_pub.g_varchar_table_type := pv_assignment_pub.g_varchar_table_type();

   l_rs_id               number;
   l_person_id           number;
   l_fnd_user_id         number;
   l_fnd_username        varchar2(1000);

   l_indirectly_managed  varchar2(1);
   l_decision_maker_flag varchar2(1);
   l_person_name         varchar2(1000);
   l_id_name             varchar2(100);
   l_id_type             varchar2(100);
   l_id_type_meaning     varchar2(100);
   l_object_id           number;
   l_pt_ok_flag          boolean := TRUE;

   cursor lc_get_person_details (pc_rs_id number) is
   SELECT
      cj.resource_id             person_resource_id,
      cj.category                user_type,
      cj.source_id               party_id,
      cj.source_name             name,      -- cm name (use in error message)
      cu.user_id                 userid,
      cu.user_name               logon_user -- cm fnd_user exists
   FROM
      jtf_rs_resource_extns     cj,
      fnd_user                  cu
   WHERE
          cj.resource_id = pc_rs_id
      AND cj.user_id     = cu.user_id (+)
      AND (cu.end_date > sysdate OR cu.end_date IS NULL);


   cursor lc_get_int_cms (pc_partner_id number) is
   SELECT distinct -- user could have both CM roles
      pt_acc.resource_id     rs_id,
      'INTERNAL'             origin
   FROM
      pv_partner_accesses PT_ACC,
      pv_partner_profiles PT_PROF,
      jtf_rs_resource_extns  extn,
      per_all_people_f       per,
      jtf_rs_role_relations  rel,
      jtf_rs_roles_b         role,
      fnd_user               usr
   WHERE
      pt_acc.partner_id       = pc_partner_id   and
      pt_acc.partner_id       = pt_prof.partner_id and
      pt_prof.status          = 'A' and
      pt_acc.resource_id      = extn.resource_id and
      extn.category           = pv_assignment_pub.g_resource_employee and
      extn.source_id          = per.person_id and
      (trunc(sysdate) between per.effective_start_date and per.effective_end_date) and
      extn.resource_id        = rel.role_resource_id and
      rel.role_resource_type  = 'RS_INDIVIDUAL' and
      (rel.end_date_active is null or rel.end_date_active > sysdate) and
      rel.delete_flag         = 'N' and
      rel.role_id             = role.role_id and
      role.role_type_code     = 'PRM' and
      role.role_code          in ('CHANNEL_MANAGER', 'CHANNEL_REP') and
      extn.user_id           =  usr.user_id and
      (usr.end_date > sysdate OR usr.end_date IS NULL);

   cursor lc_get_default_cm is
   SELECT res.resource_id
   FROM jtf_rs_resource_extns res
   where resource_id = to_number(fnd_profile.value('PV_DEFAULT_CM'));

   cursor lc_preferred_pt_contact (pc_partner_id number, pc_opportunity_id number) is
   select distinct
      c.resource_id
   from
      pv_partner_profiles   a,
      hz_relationships      b,
      jtf_rs_resource_extns c,
      as_accesses_all       d,
      fnd_user usr
   where
      a.partner_id          = pc_partner_id and
      a.partner_party_id    = b.object_id  and
      b.subject_table_name  = 'HZ_PARTIES' and
      b.object_table_name   = 'HZ_PARTIES' and
      b.directional_flag    = 'F' and
      b.relationship_code   = 'EMPLOYEE_OF' and
      b.relationship_type   = 'EMPLOYMENT' and
      (b.end_date is null  or b.end_date > sysdate) and
      b.status             = 'A' and
      b.party_id            = c.source_id and
      c.category            = pv_assignment_pub.g_resource_party and
      sysdate between c.start_date_active and nvl(c.end_date_active,sysdate) and
      c.resource_id         = d.salesforce_id and
      d.lead_id             = pc_opportunity_id and
      c.user_id             = usr.user_id and
      (usr.end_date > sysdate OR usr.end_date IS NULL);


   cursor lc_get_default_pt_contact (pc_partner_id number) is
   SELECT
      pj.resource_id
   FROM
      pv_partner_profiles   prof,
      hz_relationships      pr2,
      jtf_rs_resource_extns pj,
      fnd_user              usr
   WHERE
             prof.partner_id        = pc_partner_id
      and    prof.partner_party_id  = pr2.object_id
      and    pr2.subject_table_name = 'HZ_PARTIES'
      and    pr2.object_table_name  = 'HZ_PARTIES'
      and    pr2.directional_flag   = 'F'
      and    pr2.relationship_code  = 'EMPLOYEE_OF'
      and    pr2.relationship_type  = 'EMPLOYMENT'
      and    (pr2.end_date is null or pr2.end_date > sysdate)
      and    pr2.status             = 'A'
      and    pr2.party_id           = pj.source_id
      and    pj.category            = pv_assignment_pub.g_resource_party
      and    sysdate between pj.start_date_active and nvl(pj.end_date_active,sysdate)
      and    pj.user_id             = usr.user_id
      and   (usr.end_date > sysdate OR usr.end_date IS NULL)
      and exists(select 1 from jtf_auth_principal_maps jtfpm,
                 jtf_auth_principals_b jtfp1, jtf_auth_domains_b jtfd,
                 jtf_auth_principals_b jtfp2, jtf_auth_role_perms jtfrp,
                 jtf_auth_permissions_b jtfperm
                 where usr.user_name = jtfp1.principal_name
                 and jtfp1.is_user_flag=1
                 and jtfp1.jtf_auth_principal_id=jtfpm.jtf_auth_principal_id
                 and jtfpm.jtf_auth_parent_principal_id = jtfp2.jtf_auth_principal_id
                 and jtfp2.is_user_flag=0
                 and jtfp2.jtf_auth_principal_id = jtfrp.jtf_auth_principal_id
                 and jtfrp.positive_flag = 1
                 and jtfrp.jtf_auth_permission_id = jtfperm.jtf_auth_permission_id
                 and jtfperm.permission_name = 'PV_OPPTY_CONTACT'
                 and jtfd.jtf_auth_domain_id=jtfpm.jtf_auth_domain_id
                 and jtfd.domain_name='CRM_DOMAIN' );

   cursor lc_id_type (pc_party_rel_id number) is
   select pt.party_name,
          ar.meaning,
          pr.relationship_code,
          pr.object_id,
          imp.indirectly_managed_flag
   from   pv_partner_profiles pf,
          hz_relationships    pr,
          hz_organization_profiles op,
          ar_lookups          ar,
          hz_parties          pt,
          (select distinct a.partner_id, 'Y' indirectly_managed_flag from pv_partner_accesses a, pv_partner_profiles b
           where a.partner_id = pc_party_rel_id
           and a.vad_partner_id = b.partner_id and b.status = 'A') imp
   where pf.partner_id          = pc_party_rel_id
   and   pf.partner_id          = imp.partner_id (+)
   and   pr.party_id            = pf.partner_id
   and   pr.subject_table_name  = 'HZ_PARTIES'
   and   pr.object_table_name   = 'HZ_PARTIES'
   and   (pr.end_date is null  or pr.end_date > sysdate)
   and   pr.status             in ('A', 'I')
   and   pr.object_id           = op.party_id
   and   op.internal_flag       = 'Y'
   and   op.effective_end_date is null
   and   ar.lookup_type         = 'PARTY_RELATIONS_TYPE'
   AND   AR.lookup_code         = pr.relationship_code
   and   pr.subject_id          = pt.party_id
   and   pt.status             in ('A', 'I');


   cursor lc_get_ext_cms (pc_partner_id number, pc_vad_id number) is
   SELECT distinct -- user could have both CM roles
      pt_acc.resource_id     rs_id,
      'EXTERNAL'             origin
   FROM
      pv_partner_accesses PT_ACC,
      pv_partner_profiles PT_PROF,
      jtf_rs_resource_extns  extn,
      hz_relationships       emp,
      jtf_rs_role_relations  rel,
      jtf_rs_roles_b         role
   where
      PT_ACC.partner_id       = pc_partner_id and
      PT_ACC.vad_partner_id   = pc_vad_id and
      PT_ACC.vad_partner_id   = PT_PROF.partner_id and
      PT_PROF.status          = 'A' and
      PT_ACC.resource_id      = extn.resource_id and
      extn.category           = pv_assignment_pub.g_resource_party and
      extn.source_id          = emp.party_id and
      emp.subject_table_name  = 'HZ_PARTIES' and
      emp.object_table_name   = 'HZ_PARTIES' and
      emp.directional_flag    = 'F' and
      emp.relationship_code   = 'EMPLOYEE_OF' and
      emp.relationship_type   = 'EMPLOYMENT' and
      (emp.end_date is null or emp.end_date > sysdate) and
      emp.status             in ('A', 'I') and
      emp.object_id           = PT_PROF.partner_party_id and
      extn.resource_id        = rel.role_resource_id and
      rel.role_resource_type  = 'RS_INDIVIDUAL' and
      (rel.end_date_active is null or rel.end_date_active > sysdate) and
      rel.delete_flag         = 'N' and
      rel.role_id             = role.role_id and
      role.role_type_code     = 'PRM' and
      role.role_code          in ('CHANNEL_MANAGER', 'CHANNEL_REP');


begin
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                         p_api_version_number,
                                         l_api_name,
                                         G_PKG_NAME) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
        fnd_msg_pub.initialize;
    END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || '. Partner id: ' || p_partner_id || '. Mode: ' || p_mode);
      fnd_msg_pub.Add;
   END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- check to see if partner relationship exists.  Also
   -- get partner organization/contact name to be used in error messaging if needed

   open lc_id_type(pc_party_rel_id => p_partner_id);
   fetch lc_id_type into l_id_name, l_id_type_meaning, l_id_type, l_object_id, l_indirectly_managed;
   close lc_id_type;

   if l_id_name is null then

      fnd_message.SET_NAME('PV', 'PV_BAD_ID');
      fnd_message.SET_TOKEN('ID' ,p_partner_id);

      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;

   end if;

   if l_id_type <> 'PARTNER_OF' then

      -- this means that you cannot match a partner who is not PARTNER_OF
      -- every indirectly managed partner will have a PARTNER_OF directly with the vendor
      -- the user is only allowed to pick the PARTNER_OF instead of the CUSTOMER_INDIRECTLY_MANAGED_BY relationship

      fnd_message.SET_NAME('PV', 'PV_INVALID_PARTY_TYPE');
      fnd_message.SET_TOKEN('PARTY_NAME', l_id_name);
      fnd_message.SET_TOKEN('RELATION_TYPE', l_id_type_meaning);

      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;

   end if;

   if p_retrieve_mode in ('BOTH', 'CM') then

      if l_indirectly_managed = 'Y' and x_vad_id is not null then

         -- get VAD CMs for partner first only if VAD is routing to IMP (that is x_vad_id is not null)

         for l_rs_rec  in  lc_get_ext_cms(pc_partner_id => p_partner_id, pc_vad_id => x_vad_id)
         loop

            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
               fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
               fnd_message.Set_Token('TEXT', 'CM rs id: ' || l_rs_rec.rs_id || ' from ' || l_rs_rec .origin);
               fnd_msg_pub.Add;
            END IF;

            if instr(l_all_cm_rs_id, ' ' || l_rs_rec.rs_id || ' ') = 0 then

               l_all_cm_rs_id := l_all_cm_rs_id || ' ' || l_rs_rec.rs_id || ' ';

               l_cm_rs_id_tbl.extend;
               l_cm_rs_id_tbl(l_cm_rs_id_tbl.last) := l_rs_rec.rs_id;
               l_cm_origin_tbl.extend;
               l_cm_origin_tbl(l_cm_origin_tbl.last) := l_rs_rec.origin;

            else
               IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                  fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                  fnd_message.Set_Token('TEXT', 'cm resource id: ' || l_rs_rec.rs_id || ' already selected' );
                  fnd_msg_pub.Add;
               END IF;
            end if;

         end loop;

      end if;

      for l_rs_rec in lc_get_int_cms(pc_partner_id => p_partner_id)
      loop

         IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.Set_Token('TEXT', 'CM rs id: ' || l_rs_rec.rs_id || ' from ' || l_rs_rec .origin);
            fnd_msg_pub.Add;
         END IF;

         if instr(l_all_cm_rs_id, ' ' || l_rs_rec.rs_id || ' ') = 0 then

            l_all_cm_rs_id := l_all_cm_rs_id || ' ' || l_rs_rec.rs_id || ' ';

            l_cm_rs_id_tbl.extend;
            l_cm_rs_id_tbl(l_cm_rs_id_tbl.last) := l_rs_rec.rs_id;
            l_cm_origin_tbl.extend;
            l_cm_origin_tbl(l_cm_origin_tbl.last) := l_rs_rec.origin;

         else
            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
               fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
               fnd_message.Set_Token('TEXT', 'cm resource id: ' || l_rs_rec.rs_id || ' already selected' );
               fnd_msg_pub.Add;
            END IF;
         end if;

      end loop;


      if l_cm_rs_id_tbl.count = 0 then

         IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.Set_Token('TEXT', 'No CM found in PARTNER TEAM, Trying PV_DEFAULT_CM');
            fnd_msg_pub.Add;
         END IF;

         -- no cm found.  Look for default cm from profile

         l_rs_id := null;

         open lc_get_default_cm;
         fetch lc_get_default_cm into l_rs_id;
         close lc_get_default_cm;

         if l_rs_id is null then

            fnd_message.SET_NAME('PV', 'PV_NO_CM_FOR_PT');
            fnd_message.SET_TOKEN('P_PARTNER' ,l_id_name);

            fnd_msg_pub.ADD;
            raise FND_API.G_EXC_ERROR;

         end if;

         l_cm_rs_id_tbl.extend;
         l_cm_rs_id_tbl(l_cm_rs_id_tbl.last) := l_rs_id;
         l_cm_origin_tbl.extend;
         l_cm_origin_tbl(l_cm_origin_tbl.last) := 'DEFAULT';

      end if;

   end if;

   for i in 1 .. l_cm_rs_id_tbl.count loop

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.Set_Token('TEXT', 'Validating cm rs id: ' || l_cm_rs_id_tbl(i));
         fnd_msg_pub.Add;
      END IF;

      l_rs_id := null;

      open  lc_get_person_details ( pc_rs_id => l_cm_rs_id_tbl(i) );
      fetch lc_get_person_details into l_rs_id, l_usertype, l_person_id, l_person_name, l_fnd_user_id, l_fnd_username;
      close lc_get_person_details;

      if l_rs_id is null then

         fnd_message.SET_NAME('PV', 'PV_CM_INVALID_RESOURCE_ID');
         fnd_message.SET_TOKEN('P_RESOURCE_ID' ,l_cm_rs_id_tbl(i));
         fnd_msg_pub.ADD;
         l_pt_ok_flag := false;

      elsif l_fnd_username is null then

         fnd_message.SET_NAME('PV', 'PV_NO_LOGON_ACCT');
         fnd_message.SET_TOKEN('P_USER' ,l_person_name);
         fnd_msg_pub.ADD;
         l_pt_ok_flag := false;

      end if;

      if l_pt_ok_flag then

         if l_cm_origin_tbl(i) = 'DEFAULT' then

            l_decision_maker_flag := 'Y';

         elsif l_usertype = pv_assignment_pub.g_resource_employee then

            -- ER 3028478
            -- this is to handle the case where an indirectly managed partner is managed by multiple
            -- VADs (possible in 11.5.10).  In this case if an oppty is routed to a IMP, we will not
            -- know which VAD should approve the routing.  So we are changing the behavior so that
            -- the vendor CM of the IMP is always the one to approve, not the VAD CM of the IMP

            l_decision_maker_flag := 'Y';

         else
            l_decision_maker_flag := 'N';
         end if;

         x_rs_details_tbl.extend;
         l_rs_details_tbl_cnt := l_rs_details_tbl_cnt + 1;

         x_rs_details_tbl(l_rs_details_tbl_cnt).notification_type := pv_assignment_pub.g_notify_type_matched_to;
         x_rs_details_tbl(l_rs_details_tbl_cnt).user_id             := l_fnd_user_id;
         x_rs_details_tbl(l_rs_details_tbl_cnt).person_id           := l_person_id;
         x_rs_details_tbl(l_rs_details_tbl_cnt).person_type         := l_usertype;
         x_rs_details_tbl(l_rs_details_tbl_cnt).decision_maker_flag := l_decision_maker_flag;
         x_rs_details_tbl(l_rs_details_tbl_cnt).user_name           := l_fnd_username;
         x_rs_details_tbl(l_rs_details_tbl_cnt).resource_id         := l_rs_id;

      end if;

   end loop;

   if p_retrieve_mode in ('BOTH','CM') and fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'CMs found: ' || l_cm_rs_id_tbl.count);
      fnd_msg_pub.Add;
   END IF;

   if p_entity in ('LEAD','OPPORTUNITY') then

      if p_retrieve_mode in ('BOTH','PT') then

         l_all_cm_rs_id := ' ';

         -- see if there are any preferred partner contact

         open  lc_preferred_pt_contact(pc_partner_id => p_partner_id, pc_opportunity_id => p_entity_id);
         loop
            fetch lc_preferred_pt_contact into l_pt_user_rs_id;
            exit when lc_preferred_pt_contact%notfound;
            l_pt_user_rs_id_tbl.extend;
            l_pt_user_rs_id_tbl(l_pt_user_rs_id_tbl.last) := l_pt_user_rs_id;
         end loop;
         close lc_preferred_pt_contact;

         IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.Set_Token('TEXT', 'No. of pt contacts found in oppty salesteam: ' || l_pt_user_rs_id_tbl.count);
            fnd_msg_pub.Add;
         END IF;

         for i in 1 .. l_pt_user_rs_id_tbl.count loop
            l_all_cm_rs_id := l_all_cm_rs_id || ' ' || l_pt_user_rs_id_tbl(i) || ' ';
         end loop;

         -- add default contact for partner also

         open  lc_get_default_pt_contact (pc_partner_id => p_partner_id);
         loop
            fetch lc_get_default_pt_contact into l_pt_user_rs_id;
            exit when lc_get_default_pt_contact%notfound;
            l_pt_default_rs_id_tbl.extend;
            l_pt_default_rs_id_tbl(l_pt_default_rs_id_tbl.last) := l_pt_user_rs_id;
         end loop;
         close lc_get_default_pt_contact;

         IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.Set_Token('TEXT', 'No. of pt contacts with PV_OPPTY_CONTACT permission that has resource and' ||
                                           ' Valid login : ' || l_pt_default_rs_id_tbl.count);
            fnd_msg_pub.Add;
         END IF;

         if l_pt_user_rs_id_tbl.count = 0 and l_pt_default_rs_id_tbl.count = 0 then

            -- no partner contacts found

            fnd_message.SET_NAME('PV', 'PV_NO_CNTCT_FOR_PT');
            fnd_message.SET_TOKEN('P_PARTNER' , l_id_name);
            fnd_msg_pub.ADD;
            l_pt_ok_flag := false;

         end if;

         for i in 1 .. l_pt_default_rs_id_tbl.count loop

            if instr(l_all_cm_rs_id, ' ' || l_pt_default_rs_id_tbl(i) || ' ') = 0 then

               l_all_cm_rs_id := l_all_cm_rs_id || ' ' || l_pt_default_rs_id_tbl(i) || ' ';

               l_pt_user_rs_id_tbl.extend;
               l_pt_user_rs_id_tbl(l_pt_user_rs_id_tbl.last) := l_pt_default_rs_id_tbl(i);

            else

               IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                  fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                  fnd_message.Set_Token('TEXT', 'Default contact: resource id already there: '||l_pt_default_rs_id_tbl(i));
                  fnd_msg_pub.Add;
               END IF;

            end if;

         end loop;

         for i in 1 .. l_pt_user_rs_id_tbl.count loop

            l_rs_id := null;

            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
               fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
               fnd_message.Set_Token('TEXT', 'before retrieving the person details '|| l_pt_user_rs_id_tbl(i));
               fnd_msg_pub.Add;
            END IF;

            open  lc_get_person_details (pc_rs_id => l_pt_user_rs_id_tbl(i) );
            fetch lc_get_person_details into l_rs_id, l_usertype, l_person_id, l_person_name, l_fnd_user_id, l_fnd_username;
            close lc_get_person_details;

            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
               fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
               fnd_message.Set_Token('TEXT', 'Resource ID '||l_rs_id ||' '||l_person_name||' '|| l_fnd_username );
               fnd_msg_pub.Add;
            END IF;
            if l_fnd_username is null then

               fnd_message.SET_NAME('PV', 'PV_PT_CONTACT_NO_LOGON');
               fnd_message.SET_TOKEN('P_PT_RESOURCE_ID' ,l_pt_user_rs_id_tbl(i));
               fnd_msg_pub.ADD;
               -- l_pt_ok_flag := false;

               IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                  fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                  fnd_message.Set_Token('TEXT', 'Resource ID '||l_pt_user_rs_id_tbl(i) ||
                                        ' set to zero since the partner contact does not have login' );
                  fnd_msg_pub.Add;
               END IF;

               l_pt_user_rs_id_tbl(i) := 0;

            end if;

            if l_pt_ok_flag then

               if l_pt_user_rs_id_tbl(i) <> 0 then

                  x_rs_details_tbl.extend;
                  l_rs_details_tbl_cnt := l_rs_details_tbl_cnt + 1;

                  x_rs_details_tbl(l_rs_details_tbl_cnt).notification_type   := pv_assignment_pub.g_notify_type_offered_to;
                  x_rs_details_tbl(l_rs_details_tbl_cnt).user_id             := l_fnd_user_id;
                  x_rs_details_tbl(l_rs_details_tbl_cnt).person_id           := l_person_id;
                  x_rs_details_tbl(l_rs_details_tbl_cnt).person_type         := l_usertype;
                  x_rs_details_tbl(l_rs_details_tbl_cnt).decision_maker_flag := 'Y';
                  x_rs_details_tbl(l_rs_details_tbl_cnt).user_name           := l_fnd_username;
                  x_rs_details_tbl(l_rs_details_tbl_cnt).resource_id         := l_pt_user_rs_id_tbl(i);

               end if;
            end if;

         end loop;

         IF l_pt_user_rs_id_tbl.count > 0 THEN
            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
               fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
               fnd_message.Set_Token('TEXT', 'There are '||l_pt_user_rs_id_tbl.count || ' contacts found for partner '||
                                             l_id_name);
               fnd_msg_pub.Add;
            END IF;
         ELSE
            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
               fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
               fnd_message.Set_Token('TEXT', 'No contacts found for partner '||l_id_name);
               fnd_msg_pub.Add;
            END IF;
         END IF;

      end if; --  p_entity in 'LEAD','OPPORTUNITY'

   end if;  -- p_retrieve_mode

   if not l_pt_ok_flag then
      raise FND_API.G_EXC_ERROR;
   end if;

  --
  -- End of API body.
  --

   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
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
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

end get_partner_info;



--=============================================================================+
--|  Procedure                                                                 |
--|                                                                            |
--|    UpdateAccess                                                            |
--|                                                                            |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
procedure UpdateAccess
    ( p_api_version_number  IN   NUMBER,
      p_init_msg_list       IN   VARCHAR2     := FND_API.G_FALSE,
      p_commit              IN   VARCHAR2     := FND_API.G_FALSE,
      p_validation_level    IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
      p_itemtype            IN   VARCHAR2,
      p_itemkey             IN   VARCHAR2,
      p_current_username    IN   VARCHAR2,
      p_lead_id             IN   NUMBER,
      p_customer_id         IN   NUMBER,
      p_address_id          IN   NUMBER,
      p_resource_id         IN   NUMBER,
      p_access_type         IN   NUMBER,
      p_access_action       IN   NUMBER,
      x_access_id           OUT  NOCOPY   NUMBER,
      x_return_status       OUT  NOCOPY   VARCHAR2,
      x_msg_count           OUT  NOCOPY   NUMBER,
      x_msg_data            OUT  NOCOPY   VARCHAR2)
as

   l_temp           varchar2(100);

   -- if the person belongs to more than 1 group, we will use the group_id in ASF_DEFAULT_GROUP_ROLE.
   -- else we will use the group_id from jtf_rs_group_members

   l_get_person_info_sql varchar2(500) :=
      'select a.category, b.user_name, a.source_id ' ||
      'from jtf_rs_resource_extns a, fnd_user b ' ||
      'where a.resource_id = :p_resource_id and a.user_id = b.user_id ' ;

   l_get_pt_org_info_sql varchar2(800) :=
   'select re.source_id from jtf_rs_resource_extns re where re.resource_id = :p_resource_id ';

   l_api_name            CONSTANT VARCHAR2(30) := 'UpdateAccess';
   l_api_version_number  CONSTANT NUMBER       := 1.0;

   l_access_id_tbl       pv_assignment_pub.g_number_table_type  := pv_assignment_pub.g_number_table_type();
   l_prm_keep_flag_tbl   pv_assignment_pub.g_varchar_table_type := pv_assignment_pub.g_varchar_table_type();
   l_salesforce_id_tbl   pv_assignment_pub.g_number_table_type  := pv_assignment_pub.g_number_table_type();

   l_person_category     varchar2(30);
   l_access_Id           number;
   l_prm_keep_flag       varchar2(1);
   l_salesforce_id       number;
   l_sales_credit_count  number;
   l_profile_value       varchar2(50);
   l_non_quota_sc_id     number;
   l_sales_grp_id_str    varchar2(50);
   l_am_rs_id            NUMBER;
   l_ld_owner_rs_id      NUMBER;
   l_person_id           NUMBER;
   l_emp_person_id       NUMBER;
   l_pt_party_id         NUMBER;
   l_sales_group_id      NUMBER;
   l_pt_org_party_id     NUMBER;
   l_access_exists_flag  BOOLEAN;
   l_username            VARCHAR2(100);
   l_debug_string        VARCHAR2(100);
   l_pt_full_access_opp  VARCHAR2(1);
   l_pt_resource_id      NUMBER;
   l_open_flag       VARCHAR2(10);

   l_sales_team_rec      AS_ACCESS_PUB.Sales_Team_Rec_Type;
   lc_cursor             pv_assignment_pub.g_ref_cursor_type;

   cursor lc_get_access_details (pc_salesforce_id number, pc_lead_id number) is
      select access_id , prm_keep_flag, salesforce_id
      from as_accesses_all
      where salesforce_id = pc_salesforce_id
      and   lead_id       = pc_lead_id;

   cursor lc_get_am_and_owner (pc_lead_id number) is
      select am.resource_id, owner.resource_id
      from   pv_lead_workflows wf, jtf_rs_resource_extns am, as_leads_all ld, jtf_rs_resource_extns owner
      where  wf.lead_id             = pc_lead_id
      and    wf.entity              = 'OPPORTUNITY'
      and    wf.latest_routing_flag = 'Y'
      and    wf.created_by          = am.user_id
      and    ld.lead_id             = pc_lead_id
      and    ld.created_by          = owner.user_id;

   -- ----------------------------------------------------------------------------
   -- Quota Sales Credits
   -- ----------------------------------------------------------------------------
   CURSOR lc_get_sales_credit_count(pc_salesforce_id NUMBER, pc_lead_id NUMBER) IS
      SELECT COUNT(*) sales_credit_count
      FROM   as_sales_credits
      WHERE  lead_id        = pc_lead_id AND
             salesforce_id  = pc_salesforce_id AND
             credit_type_id = 1 AND
             NVL(credit_amount, 0) > 0;

   -- ----------------------------------------------------------------------------
   -- Non-Quota Sales Credits
   -- ----------------------------------------------------------------------------
   CURSOR lc_get_nonq_sales_credit(pc_salesforce_id NUMBER, pc_lead_id NUMBER) IS
      SELECT sales_credit_id
      FROM   as_sales_credits
      WHERE  lead_id        = pc_lead_id AND
             salesforce_id  = pc_salesforce_id AND
             credit_type_id = 2 AND
             NVL(credit_amount, 0) > 0;


  cursor lc_get_pt_access(pc_lead_id number)
  is
   SELECT   pn.resource_id
   FROM       pv_lead_workflows pw, pv_lead_assignments pa,
            pv_party_notifications pn
   WHERE    pw.wf_item_key = pa.wf_item_key
   AND      pa.lead_assignment_id = pn.lead_assignment_id
   AND       pw.latest_routing_flag = 'Y'
   AND      pw.lead_id = pc_lead_id
   AND       pn.notification_type = 'OFFERED_TO';

  cursor get_opp_open_flag_csr(pc_lead_id number) is
     select decode(st.opp_open_status_flag,'N',NULL,st.opp_open_status_flag)
     from as_leads_all ld, as_statuses_b st
     where ld.lead_id = pc_lead_id
     and ld.status = st.status_code;

   l_current_user_rs_id                     NUMBER; -- resource_id of currently logged in user
   l_curr_user_access_profile_rec           as_access_pub.access_profile_rec_type;


/*
FOr enhacement# 4092815
Cursor to get sql_text of attrribute# 7,
*/

cursor lc_get_sql_text_attr_7  is
SELECT sql_text
FROM pv_entity_Attrs
WHERE entity = 'PARTNER' and
attribute_id = 7
;

/*
For enhacement# 4092815
Cursor to get partner_id of the partner organisation with given resource_id
*/

cursor lc_get_partner_id_org (
				pc_salesforce_id number
) is
select source_id from jtf_rs_resource_extns
where resource_id = pc_salesforce_id
;

cursor lc_get_partner_id_org_contact (
				pc_salesforce_id number
) is

SELECT pvpp.partner_id
FROM hz_parties PARTNER, hz_relationships HZR_PART_CONT, hz_org_contacts ORG_CONTACT,
hz_contact_points hcp, pv_partner_profiles pvpp, jtf_rs_resource_extns res
WHERE
PARTNER.PARTY_ID = pvpp.partner_party_id and
PARTNER.party_type = 'ORGANIZATION' AND
HZR_PART_CONT.object_id = PARTNER.PARTY_ID AND
HZR_PART_CONT.relationship_type = 'EMPLOYMENT' AND
HZR_PART_CONT.subject_table_name = 'HZ_PARTIES' AND
HZR_PART_CONT.object_table_name = 'HZ_PARTIES' AND
HZR_PART_CONT.PARTY_ID = res.source_id and
res.resource_id = pc_salesforce_id and
HZR_PART_CONT.relationship_id = ORG_CONTACT.party_relationship_id AND
hcp.owner_table_id(+) = HZR_PART_CONT.PARTY_ID AND
hcp.CONTACT_POINT_TYPE(+) = 'PHONE' AND
hcp.owner_table_name(+) = 'HZ_PARTIES' and
hcp.primary_flag(+) ='Y'
;

cursor lc_get_nature_of_resource (pc_access_id number) is
      select 'CM_OR_REP'
      from as_accesses_all
      where access_id = pc_access_id
      and partner_customer_id is null
      and partner_cont_party_id is null;

/*
For enhacement# 4092815
*/
   l_current_partnerid_of_rel                     NUMBER;
   l_sql_text_attr_7                              VARCHAR2(2000);
   l_enable_full_access_value                     VARCHAR2(30);
   l_resoucre_nature				  VARCHAR2(30) := 'PART_OR_CONT';

begin

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
       fnd_msg_pub.initialize;
   END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN

      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || ' for Lead id = ' || p_lead_id || '. Resource ID: ' || p_resource_id);
      fnd_msg_pub.Add;

      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'p_access_type is: ' || p_access_type || ': p_access_action is :' || p_access_action || ' :');
      fnd_msg_pub.Add;


      select 'Access Type: '||decode(p_access_type, 1, 'CM', 2, 'PT', 3, 'PT ORG') ||
             ' Access Action: '||decode(p_access_action, 1, 'ADD', 2, 'REMOVE') into l_debug_string from dual;

      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', l_debug_string);
      fnd_msg_pub.Add;

   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;



   -- salesforce may appear multiple times in access for the same opportunity
   -- how this happens is one may have salesgroup but the other may not.

   open lc_get_access_details (pc_salesforce_id => p_resource_id, pc_lead_id => p_lead_id);
   loop

      fetch lc_get_access_details into l_access_id, l_prm_keep_flag, l_salesforce_id;
      exit when lc_get_access_details%notfound;

      l_access_id_tbl.extend;
      l_prm_keep_flag_tbl.extend;
      l_salesforce_id_tbl.extend;

      l_access_id_tbl(l_access_id_tbl.last) := l_access_id;
      l_prm_keep_flag_tbl(l_prm_keep_flag_tbl.last) := l_prm_keep_flag;
      l_salesforce_id_tbl(l_salesforce_id_tbl.last) := l_salesforce_id;
   end loop;
   close lc_get_access_details;

   if l_access_id_tbl.count > 0 then
      l_access_exists_flag := TRUE;
   else
      l_access_exists_flag := FALSE;
   end if;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');

      if l_access_exists_flag then
         fnd_message.Set_Token('TEXT', 'Access exist for ' || p_resource_id);
      else
         fnd_message.Set_Token('TEXT', 'Access does not exist for ' || p_resource_id);
      end if;

      fnd_msg_pub.Add;

   end if;

   if p_access_action = pv_assignment_pub.G_ADD_ACCESS and not l_access_exists_flag then

      if p_access_type in (pv_assignment_pub.G_CM_ACCESS, pv_assignment_pub.G_PT_ACCESS) then

         open lc_cursor for l_get_person_info_sql using p_resource_id;
         fetch lc_cursor into l_person_category, l_username, l_person_id ;

         if l_person_category = pv_assignment_pub.g_resource_employee then
            l_emp_person_id := l_person_id;

         elsif l_person_category = pv_assignment_pub.g_resource_party then
            l_pt_party_id := l_person_id;

         else
            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.SET_TOKEN('TEXT', 'Does not recognize person type: ' || l_person_category);
            fnd_msg_pub.ADD;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         end if;

         IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.Set_token('TEXT', 'Person is a ' || l_person_category);
            fnd_msg_pub.Add;
         end if;

      elsif p_access_type = pv_assignment_pub.G_PT_ORG_ACCESS then

         open lc_cursor for l_get_pt_org_info_sql using p_resource_id;
         fetch lc_cursor into l_pt_org_party_id;

      end if;

      if lc_cursor%NOTFOUND then

         fnd_message.SET_NAME  ('PV', 'PV_RESOURCE_NOT_FOUND');
         fnd_message.SET_TOKEN ('P_RESOURCE_ID' , p_resource_id);
         fnd_msg_pub.ADD;

         RAISE fnd_api.g_exc_error;

      end if;

      close lc_cursor;

      begin
	 l_sales_group_id  := Get_Salesgroup_ID(p_resource_id);

         --if instr(l_sales_grp_id_str, '(') > 0 then
         --   l_sales_group_id := to_number(substr(l_sales_grp_id_str, 1, instr(l_sales_grp_id_str, '(') - 1));
         --else
         --   l_sales_group_id := to_number(l_sales_grp_id_str);
         --end if;

      exception
      when others then
         l_sales_group_id := null;
      end;

      if l_sales_group_id is NULL and p_access_type <> pv_assignment_pub.G_PT_ORG_ACCESS then

         IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
		 fnd_message.SET_NAME  ('PV', 'PV_NO_DEFAULT_SALESGROUP');
		 fnd_message.SET_TOKEN ('P_USER' , l_username);
		 fnd_msg_pub.ADD;
         end if;
        -- RAISE fnd_api.g_exc_error;

      end if;

   end if;

   select decode(p_access_type,  pv_assignment_pub.G_CM_ACCESS,     'CM',
                                 pv_assignment_pub.G_PT_ACCESS,     'PT',
                                 pv_assignment_pub.G_PT_ORG_ACCESS, 'PT_ORG',
                                 'UNKNOWN') into l_temp from dual;

   l_pt_full_access_opp :=  fnd_profile.value('PV_ALLOW_PT_FULL_OPP_ACCESS');


   -- ------------------------------------------------------------------------------------------------
   -- Remove resource from sales team
   -- ------------------------------------------------------------------------------------------------
   if p_access_action = pv_assignment_pub.G_REMOVE_ACCESS and l_access_exists_flag then
      Debug('Remove resource from sales team...');

      open lc_get_am_and_owner (pc_lead_id => p_lead_id);
      fetch lc_get_am_and_owner into l_am_rs_id, l_ld_owner_rs_id;
      close lc_get_am_and_owner;

      if l_am_rs_id is null then
            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.SET_TOKEN('TEXT', 'Cannot identify Assignment manager or Opportunity creator');
            fnd_msg_pub.ADD;
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;


      for i in 1 .. l_access_id_tbl.count loop
         Debug('l_access_id = ' || l_access_id_tbl(i));

         open lc_get_nature_of_resource (pc_access_id => l_access_id_tbl(i));
	 fetch lc_get_nature_of_resource into l_resoucre_nature;
         close lc_get_nature_of_resource;

	 Debug('l_resoucre_nature : ' || l_resoucre_nature);
	 Debug('l_prm_keep_flag_tbl(i) : ' || l_prm_keep_flag_tbl(i));

         if (l_prm_keep_flag_tbl(i) = 'Y' and l_resoucre_nature = 'CM_OR_REP')
	    or
	    (l_resoucre_nature= 'PART_OR_CONT')
	 then  -- means added by WF

            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
               fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
               fnd_message.Set_token('TEXT', 'Removing Access for: ' || l_temp);
               fnd_msg_pub.Add;
            end if;

            -- -------------------------------------------------------------------------------
            -- Check if this resource has quota sales credit associated with it.
            -- -------------------------------------------------------------------------------
            FOR x IN lc_get_sales_credit_count(p_resource_id, p_lead_id) LOOP
               l_sales_credit_count := x.sales_credit_count;
            END LOOP;
	    Debug('l_sales_credit_count :' || l_sales_credit_count);

            -- -------------------------------------------------------------------------------
            -- Remove the resource from the sales team of the opportunity if the resource
            -- * is not the owner of the opportunity
            -- * is not the assignment manager
            -- * was put on the sales team by the routing process (prm_keep_flag = 'Y')
            -- * does not have any sales credit associated with it
            --
            -- A resource can also have non-quota sales credits associated with it. Whether
            -- these sales credits get deleted or not is depending on the profile
            -- PV_REMOVE_NON_QUOTA_SALES_CREDIT:
            -- 1). REMOVE_RS_ONLY - only resource will be removed from the sales team but
            --                      non-quota sales credits will be kept.
            -- 2). REMOVE_RS_SALES_CREDIT - the resource will be removed from the sales team
            --                      and non-quota sales credits will also be deleted.
            --
            -- If none of the above profile options is selected, the resource won't be
            -- removed from the sales team and the sales credits won't be deleted.
            -- -------------------------------------------------------------------------------
            IF (l_sales_credit_count = 0) THEN
               -- ----------------------------------------------------------------------------
               -- Retrieve profile value that deals with non-quota sales credit.
               -- ----------------------------------------------------------------------------
               l_profile_value := FND_PROFILE.VALUE('PV_REMOVE_NON_QUOTA_SALES_CREDIT');
               Debug(' Profile Option value of PV_REMOVE_NON_QUOTA_SALES_CREDIT = ' || l_profile_value);

               FOR x IN lc_get_nonq_sales_credit(p_resource_id, p_lead_id) LOOP
                  l_non_quota_sc_id := x.sales_credit_id;
                  EXIT;
               END LOOP;

	       Debug('l_non_quota_sc_id :'|| l_non_quota_sc_id);

               IF (l_non_quota_sc_id IS NOT NULL) THEN
                  IF (l_profile_value IS NULL) THEN
                        Debug('Do not remove for: ' || l_temp ||
                              '. It still has some non-quota sales credits associated with it.');

                  ELSIF (l_profile_value = 'REMOVE_RS_SALES_CREDIT') THEN
                     Debug('l_profile_value is REMOVE_RS_SALES_CREDIT. SO deleting access_id:' || l_access_id_tbl(i));
		     DELETE FROM as_accesses_all acc
                     WHERE  access_id = l_access_id_tbl(i) AND
                            salesforce_id NOT IN (l_am_rs_id, l_ld_owner_rs_id);

                     -- ----------------------------------------------------------------
                     -- Remove non-quota sales crdits
                     -- ----------------------------------------------------------------
                     Debug('Deleting Sales Credits from as_sales_credits');
		     DELETE FROM as_sales_credits
                     WHERE  lead_id         = p_lead_id AND
                            salesforce_id   = p_resource_id AND
                            credit_type_id  = 2;

                  ELSIF (l_profile_value = 'REMOVE_RS_ONLY') THEN
                     Debug('l_profile_value is REMOVE_RS_ONLY. SO deleting sales credits');
		     DELETE FROM as_accesses_all acc
                     WHERE  access_id = l_access_id_tbl(i) AND
                            salesforce_id NOT IN (l_am_rs_id, l_ld_owner_rs_id);
                  END IF;

               -- -----------------------------------------------------------------------
               -- If there are no non-quota sales credits
               -- -----------------------------------------------------------------------
               ELSE
                     Debug('l_non_quota_sc_id IS NULL.. SO deleting access_id:' || l_access_id_tbl(i) );

		     DELETE FROM as_accesses_all acc
                     WHERE  access_id = l_access_id_tbl(i) AND
                            salesforce_id NOT IN (l_am_rs_id, l_ld_owner_rs_id);
               END IF;

            ELSE
               Debug('l_sales_credit_count is not 0');

	       IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                  fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                  fnd_message.Set_token('TEXT', 'Do not remove for: ' || l_temp ||
                                        '. It still has some sales credits associated with it.');
                  fnd_msg_pub.Add;
               END IF;
            END IF;

         else
            Debug('l_prm_keep_flag_tbl(i) is not Y') ;
	    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
               fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
               fnd_message.Set_token('TEXT', 'Do not remove for: ' || l_temp || '. Prm_keep_flag is not Y');
               fnd_msg_pub.Add;
            end if;

         end if;
      end loop;
      -- ------------------------------------------------------------------------------------------------ --
      -- -------------------------End Removing Resources from Sales Team--------------------------------- --
      -- ------------------------------------------------------------------------------------------------ --



   elsif p_access_action = pv_assignment_pub.G_ADD_ACCESS and l_access_exists_flag then

            open get_opp_open_flag_csr(p_lead_id);
      fetch get_opp_open_flag_csr into l_open_flag;
      close get_opp_open_flag_csr;

      open lc_get_sql_text_attr_7;
      fetch lc_get_sql_text_attr_7 into l_sql_text_attr_7;
      close lc_get_sql_text_attr_7;

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_token('TEXT', ' SQL Text for attribute 7'|| l_sql_text_attr_7);
              fnd_msg_pub.Add;
      end if;


   for i in 1 .. l_access_id_tbl.count loop

     IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_token('TEXT', ' l_pt_ess_opp'|| l_pt_full_access_opp);
              fnd_msg_pub.Add;
     end if;


     IF  p_access_type in  (pv_assignment_pub.G_CM_ACCESS) THEN

        IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_token('TEXT', 'action type is G_CM_ACCESS and setting the Team_leader_flag, prm_keep_flag to Y for resource id: ' || p_resource_id );
              fnd_msg_pub.Add;
        end if;

        update as_accesses_all set prm_keep_flag = 'Y', freeze_flag = 'Y', team_leader_flag = 'Y', open_flag = l_open_flag
        where access_id = l_access_id_tbl(i);


     ELSIF  p_access_type in  (pv_assignment_pub.G_PT_ACCESS,pv_assignment_pub.G_PT_ORG_ACCESS)  THEN

        IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_token('TEXT', 'action type is G_PT_ACCESS or  G_PT_ORG_ACCESS for resource id: ' || p_resource_id );
              fnd_msg_pub.Add;
        end if;

        IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
		      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
		      fnd_message.Set_token('TEXT', 'Find the partner id of the resource with resource_id ' || p_resource_id );
		      fnd_msg_pub.Add;
	end if;


         IF p_access_type  = pv_assignment_pub.G_PT_ORG_ACCESS  THEN

	      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
		      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
		      fnd_message.Set_token('TEXT', 'p_access_type is G_PT_ORG_ACCESS and executing lc_get_partner_id_org cursor');
		      fnd_msg_pub.Add;
              end if;

	      open lc_get_partner_id_org(p_resource_id);
	      fetch lc_get_partner_id_org into l_current_partnerid_of_rel;
	      close lc_get_partner_id_org;



	 ELSIF p_access_type = pv_assignment_pub.G_PT_ACCESS THEN

		IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
		      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
		      fnd_message.Set_token('TEXT', 'p_access_type is G_PT_ACCESS and executing lc_get_partner_id_org_contact cursor');
		      fnd_msg_pub.Add;
                end if;

		open lc_get_partner_id_org_contact(p_resource_id);
		fetch lc_get_partner_id_org_contact into l_current_partnerid_of_rel;
		close lc_get_partner_id_org_contact;


	 END IF;

          IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
		      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
		      fnd_message.Set_token('TEXT', ' the partner id of the resource with resource_id ' || p_resource_id || ' is ' || l_current_partnerid_of_rel);
		      fnd_msg_pub.Add;
	  end if;



      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_token('TEXT', ' Executing the sql_text to get Allow Access Profile value for partner ' || l_current_partnerid_of_rel);
              fnd_msg_pub.Add;
      end if;

      BEGIN
            EXECUTE IMMEDIATE l_sql_text_attr_7 INTO l_enable_full_access_value
            USING 7, 'PARTNER', l_current_partnerid_of_rel;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
		    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
		    fnd_message.SET_TOKEN('TEXT', 'No Data found executing the sql_text for attribute id 7 ' || l_sql_text_attr_7);
		    fnd_msg_pub.ADD;
	    end if;
        END;

        IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_token('TEXT', ' Value of  Allow Access Profile value for partner ' || l_current_partnerid_of_rel || ' is ' || l_enable_full_access_value);
              fnd_msg_pub.Add;
        end if;


        IF(l_enable_full_access_value = 'Y') then

            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_token('TEXT', ' l_enable_full_access_value is Y');
              fnd_msg_pub.Add;
            end if;


            IF  p_access_type in  (pv_assignment_pub.G_PT_ORG_ACCESS)  THEN

                IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                    fnd_message.Set_token('TEXT', 'p_access_type is G_PT_ORG_ACCESS and updating team_leader_flag to Y');
                    fnd_msg_pub.Add;
                end if;

               update as_accesses_all set prm_keep_flag = 'Y', freeze_flag = 'Y', team_leader_flag = 'Y', open_flag = l_open_flag
               where access_id = l_access_id_tbl(i);

            ELSIF p_access_type in  (pv_assignment_pub.G_PT_ACCESS)  THEN
                IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                    fnd_message.Set_token('TEXT', 'p_access_type is G_PT_ACCESS and updating team_leader_flag to Y for all partner contact levels');
                    fnd_msg_pub.Add;
                end if;

                open lc_get_pt_access (p_lead_id);
                loop
                    fetch lc_get_pt_access into l_pt_resource_id;
                    exit when lc_get_pt_access%notfound;

                    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                        fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                        fnd_message.Set_token('TEXT', ' resource ID ' || l_pt_resource_id);
                        fnd_msg_pub.Add;
                    END IF;


                    --For exisitng contatcs, we do nto need to update the team leader flag.
		    -- We need to leave it the way it was.
		    -- THats why we are not updating team_leader_flag

                    update as_accesses_all set prm_keep_flag = 'Y', freeze_flag = 'Y'
		    --, team_leader_flag = 'Y'
                    where access_id = l_access_id_tbl(i) and salesforce_id = l_pt_resource_id;


                end loop;
                close lc_get_pt_access;

            END IF;

        ELSIF(l_enable_full_access_value = 'N') then

            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_token('TEXT', ' l_enable_full_access_value is N');
              fnd_msg_pub.Add;
            end if;

            IF  p_access_type in  (pv_assignment_pub.G_PT_ORG_ACCESS)  THEN

                IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                    fnd_message.Set_token('TEXT', 'p_access_type is G_PT_ORG_ACCESS and updating team_leader_flag to N');
                    fnd_msg_pub.Add;
                end if;

               update as_accesses_all set prm_keep_flag = 'Y', freeze_flag = 'Y', team_leader_flag = 'N', open_flag = l_open_flag
               where access_id = l_access_id_tbl(i);

            ELSIF p_access_type in  (pv_assignment_pub.G_PT_ACCESS)  THEN

		IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                    fnd_message.Set_token('TEXT', 'p_access_type is G_PT_ACCESS and updating team_leader_flag to N for all partner contact levels');
                    fnd_msg_pub.Add;
                end if;

                open lc_get_pt_access (p_lead_id);
                loop
                    fetch lc_get_pt_access into l_pt_resource_id;
                    exit when lc_get_pt_access%notfound;

                    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                        fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                        fnd_message.Set_token('TEXT', ' resource ID ' || l_pt_resource_id);
                        fnd_msg_pub.Add;
                    END IF;


                    --For exisitng contatcs, we do nto need to update the team leader flag.
		    -- We need to leave it the way it was.
		    -- THats why we are not updating team_leader_flag

                    update as_accesses_all set prm_keep_flag = 'Y', freeze_flag = 'Y'
		    --, team_leader_flag = 'N'
                    where access_id = l_access_id_tbl(i) and salesforce_id = l_pt_resource_id;

                end loop;
                close lc_get_pt_access;

            END IF;


        ELSE  -- FOr null value and othewr values
            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_token('TEXT', ' l_enable_full_access_value is null or other values');
              fnd_msg_pub.Add;
            end if;

            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_token('TEXT', ' Now the next level of security which is the profile options value would come into picture.');
              fnd_msg_pub.Add;
            end if;

            IF l_pt_full_access_opp = 'Y' THEN

                IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                    fnd_message.Set_token('TEXT', 'l_pt_full_access_opp is Y and Setting prm_keep_flag to Y for resource id: ' || p_resource_id || ' if not lead owner');
                    fnd_msg_pub.Add;
                end if;

		IF  p_access_type in  (pv_assignment_pub.G_PT_ORG_ACCESS)  THEN

			IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                        fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                        fnd_message.Set_token('TEXT', 'l_pt_full_access_opp is N and making team_leader_flag to Y of  PT ORG: ' || p_resource_id || ' if not lead owner');
                        fnd_msg_pub.Add;
                    end if;

			update as_accesses_all set prm_keep_flag = 'Y', freeze_flag = 'Y', open_flag = l_open_flag, team_leader_flag = 'Y'
			where access_id = l_access_id_tbl(i);

		ELSIF p_access_type = pv_assignment_pub.G_PT_ACCESS THEN

			IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                            fnd_message.Set_token('TEXT', 'action type is G_PT_ACCESS , l_pt_full_access_opp is Y and not touching the team leader flag of  Partner resource ID ' || l_pt_resource_id);
                            fnd_msg_pub.Add;
                        END IF;

			--For exisitng contatcs, we do nto need to update the team leader flag.
		        -- We need to leave it the way it was.
		        -- THats why we are not updating team_leader_flag

			update as_accesses_all set prm_keep_flag = 'Y', freeze_flag = 'Y', open_flag = l_open_flag
			--,team_leader_flag = 'Y'
			where access_id = l_access_id_tbl(i);

		END IF;



            ELSE
                IF  p_access_type in  (pv_assignment_pub.G_PT_ORG_ACCESS)  THEN


                    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                        fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                        fnd_message.Set_token('TEXT', 'l_pt_full_access_opp is N and making team_leader_flag to N  PT ORG: ' || p_resource_id || ' if not lead owner');
                        fnd_msg_pub.Add;
                    end if;

                    update as_accesses_all set prm_keep_flag = 'Y', freeze_flag = 'Y', team_leader_flag = 'N', open_flag = l_open_flag
                    where access_id = l_access_id_tbl(i);


                ELSIF p_access_type = pv_assignment_pub.G_PT_ACCESS THEN

                    open lc_get_pt_access (p_lead_id);
                    loop
                        fetch lc_get_pt_access into l_pt_resource_id;
                        exit when lc_get_pt_access%notfound;

                        IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                            fnd_message.Set_token('TEXT', 'action type is G_PT_ACCESS , l_pt_full_access_opp is N and not touching the team leader flag of  Partner resource ID ' || l_pt_resource_id);
                            fnd_msg_pub.Add;
                        END IF;


                         --For exisitng contatcs, we do nto need to update the team leader flag.
		        -- We need to leave it the way it was.
		        -- THats why we are not updating team_leader_flag


                        update as_accesses_all set prm_keep_flag = 'Y', freeze_flag = 'Y'
			--, team_leader_flag = 'N'
                        where access_id = l_access_id_tbl(i) and salesforce_id = l_pt_resource_id;


                    end loop;
                    close lc_get_pt_access;
                END IF; -- end of IF  p_access_type in  (pv_assignment_pub.G_PT_ORG_ACCESS)  THEN

            END IF; -- end of IF l_pt_full_access_opp = 'Y' THEN

        END IF; -- end of IF(l_enable_full_access_value = 'Y') then else loop

     END IF;  -- end of ELSIF  p_access_type in  (pv_assignment_pub.G_PT_ACCESS,pv_assignment_pub.G_PT_ORG_ACCESS)  THEN


      end loop;


   elsif p_access_action = pv_assignment_pub.G_ADD_ACCESS and not l_access_exists_flag then

      select as_accesses_s.nextval into l_sales_team_rec.Access_Id from dual;

      open get_opp_open_flag_csr(p_lead_id);
      fetch get_opp_open_flag_csr into l_open_flag;
      close get_opp_open_flag_csr;

      --<<<
      open lc_get_sql_text_attr_7;
      fetch lc_get_sql_text_attr_7 into l_sql_text_attr_7;
      close lc_get_sql_text_attr_7;

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_token('TEXT', ' SQL Text for attribute 7'|| l_sql_text_attr_7);
              fnd_msg_pub.Add;
      end if;



      IF  p_access_type in  (pv_assignment_pub.G_CM_ACCESS) THEN

        IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_token('TEXT', 'action type is G_CM_ACCESS and setting the Team_leader_flag  to Y for resource id: ' || p_resource_id );
              fnd_msg_pub.Add;
        end if;

        l_sales_team_rec.Team_Leader_Flag          := 'Y';

     ELSIF  p_access_type in  (pv_assignment_pub.G_PT_ACCESS,pv_assignment_pub.G_PT_ORG_ACCESS)  THEN

        IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_token('TEXT', 'action type is ' || p_access_type || '  for resource id: ' || p_resource_id );
              fnd_msg_pub.Add;
        end if;

        IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_token('TEXT', 'Find the partner id of the resource with resource_id ' || p_resource_id );
              fnd_msg_pub.Add;
        end if;

       IF p_access_type in  (pv_assignment_pub.G_PT_ORG_ACCESS)  THEN

            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_token('TEXT', 'p_access_type is G_PT_ORG_ACCESS and executing lc_get_partner_id_org cursor');
              fnd_msg_pub.Add;
            end if;

            open lc_get_partner_id_org(p_resource_id);
            fetch lc_get_partner_id_org into l_current_partnerid_of_rel;
            close lc_get_partner_id_org;

       ELSIF  p_access_type in  (pv_assignment_pub.G_PT_ACCESS)  THEN
            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_token('TEXT', 'p_access_type is G_PT_ACCESS and executing lc_get_partner_id_org_contact cursor');
              fnd_msg_pub.Add;
            end if;

            open lc_get_partner_id_org_contact(p_resource_id);
            fetch lc_get_partner_id_org_contact into l_current_partnerid_of_rel;
            close lc_get_partner_id_org_contact;
       END IF;

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_token('TEXT', ' the partner id of the resource with resource_id ' || p_resource_id || ' is ' || l_current_partnerid_of_rel);
              fnd_msg_pub.Add;
      end if;

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_token('TEXT', ' Executing the sql_text to get Allow Access Profile value for partner ' || l_current_partnerid_of_rel);
              fnd_msg_pub.Add;
      end if;

      BEGIN
            EXECUTE IMMEDIATE l_sql_text_attr_7 INTO l_enable_full_access_value
            USING 7, 'PARTNER', l_current_partnerid_of_rel;
        EXCEPTION
        WHEN NO_DATA_FOUND THEN
            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
		    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
		    fnd_message.SET_TOKEN('TEXT', 'No Data found executing sql_text for attribute id 7 ' || l_sql_text_attr_7);
		    fnd_msg_pub.ADD;
            end if;
        END;

        IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_token('TEXT', ' Value of  Allow Access Profile value for partner ' || l_current_partnerid_of_rel || ' is ' || l_enable_full_access_value);
              fnd_msg_pub.Add;
        end if;


        IF(l_enable_full_access_value = 'Y') then

            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_token('TEXT', ' l_enable_full_access_value is Y and updatign team_leader_flag to Y');
              fnd_msg_pub.Add;
            end if;

            l_sales_team_rec.Team_Leader_Flag          := 'Y';

        ELSIF(l_enable_full_access_value = 'N') then

            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_token('TEXT', ' l_enable_full_access_value is N and updating team leader flkag to N');
              fnd_msg_pub.Add;
            end if;

            l_sales_team_rec.Team_Leader_Flag          := 'N';

        ELSE  -- FOr null value and othewr values
            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_token('TEXT', ' l_enable_full_access_value is null or other values');
              fnd_msg_pub.Add;
            end if;

            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
              fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
              fnd_message.Set_token('TEXT', ' Now the next level of security which is the profile options value would come into picture.');
              fnd_msg_pub.Add;
            end if;

            IF l_pt_full_access_opp = 'Y' THEN

                IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                    fnd_message.Set_token('TEXT', 'l_pt_full_access_opp is Y and Setting team_leader_flag to Y');
                    fnd_msg_pub.Add;
                end if;

               l_sales_team_rec.Team_Leader_Flag          := 'Y';

            ELSE

                IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                    fnd_message.Set_token('TEXT', 'l_pt_full_access_opp is Y and Setting team_leader_flag to N');
                    fnd_msg_pub.Add;
                end if;

               l_sales_team_rec.Team_Leader_Flag          := 'N';

            END IF; -- end of IF l_pt_full_access_opp = 'Y' THEN

        END IF; -- end of IF(l_enable_full_access_value = 'Y') then else loop

     END IF;  -- end of ELSIF  p_access_type in  (pv_assignment_pub.G_PT_ACCESS,pv_assignment_pub.G_PT_ORG_ACCESS)  THEN




-->>>

      -- l_sales_team_rec.Access_type            := 'X';  -- obsolete column, always 'X'
      l_sales_team_rec.Last_Update_Date          := SYSDATE;
      l_sales_team_rec.Last_Updated_By           := FND_GLOBAL.User_Id;
      l_sales_team_rec.Creation_Date             := SYSDATE;
      l_sales_team_rec.Created_By                := FND_GLOBAL.User_Id;
      l_sales_team_rec.Last_Update_Login         := FND_GLOBAL.Conc_Login_Id;
      l_sales_team_rec.Freeze_Flag               := 'Y';  -- if Y, not removed by TAP
      l_sales_team_rec.Reassign_Flag             := 'N';
      l_sales_team_rec.Customer_Id               := p_customer_id;
      l_sales_team_rec.Address_Id                := p_address_id;
      l_sales_team_rec.Salesforce_id             := p_resource_id;
      l_sales_team_rec.Person_Id                 := l_emp_person_id;
      l_sales_team_rec.Partner_Customer_id       := l_pt_org_party_id; -- party_id of partner relationship
      l_sales_team_rec.Partner_Address_id        := NULL;
      l_sales_team_rec.created_Person_Id         := NULL; -- not used
      l_sales_team_rec.lead_id                   := p_lead_id;
      l_sales_team_rec.Freeze_Date               := NULL;
      l_sales_team_rec.Reassign_Reason           := NULL;
      -- l_sales_team_rec.org_id                    := NULL; -- not used
      l_sales_team_rec.downloadable_flag         := NULL;
      l_sales_team_rec.Salesforce_Role_Code      := NULL;   -- if set to account manager, person can view
                                                            -- all leads/oppor for the customer_id
      l_sales_team_rec.Salesforce_Relationship_Code := NULL;
      l_sales_team_rec.Sales_group_id            := l_sales_group_id;
      -- l_sales_team_rec.Internal_Update_access    := 1;   -- if team_leader_flag is Y, then 1, else 0
      l_sales_team_rec.Sales_lead_id             := NULL;
      l_sales_team_rec.Partner_Cont_Party_Id     := l_pt_party_id; -- party_id of partner contact relation
      l_sales_team_rec.owner_flag                := 'N';  -- alway N for oppr.  Used for sales leads only
      l_sales_team_rec.created_by_tap_flag       := 'N';  -- set by realtime TAP
      -- l_sales_team_rec.prm_keep_flag             := 'Y';  -- used exclusively by PRM

      insert into as_accesses_all (
         ACCESS_ID,
         LAST_UPDATE_DATE,
         LAST_UPDATED_BY,
         CREATION_DATE,
         CREATED_BY,
         LAST_UPDATE_LOGIN,
         ACCESS_TYPE,
         FREEZE_FLAG,
         REASSIGN_FLAG,
         TEAM_LEADER_FLAG,
         CUSTOMER_ID,
         ADDRESS_ID,
         SALESFORCE_ID,
         PERSON_ID,
         PARTNER_CUSTOMER_ID,
         PARTNER_ADDRESS_ID,
         LEAD_ID,
         FREEZE_DATE,
         SALESFORCE_ROLE_CODE,
         SALESFORCE_RELATIONSHIP_CODE,
         SALES_GROUP_ID,
         INTERNAL_UPDATE_ACCESS,
         SALES_LEAD_ID,
         PARTNER_CONT_PARTY_ID,
         OWNER_FLAG,
         CREATED_BY_TAP_FLAG,
         PRM_KEEP_FLAG,
    OPEN_FLAG)
      values (
         l_sales_team_rec.Access_id,
         l_sales_team_rec.Last_Update_Date,
         l_sales_team_rec.Last_Updated_By,
         l_sales_team_rec.Creation_Date,
         l_sales_team_rec.Created_By,
         l_sales_team_rec.Last_Update_Login,
         'X',
         l_sales_team_rec.Freeze_Flag,
         l_sales_team_rec.Reassign_Flag,
         l_sales_team_rec.Team_Leader_Flag,
         l_sales_team_rec.Customer_Id,
         l_sales_team_rec.Address_Id,
         l_sales_team_rec.Salesforce_id,
         l_sales_team_rec.Person_Id,
         l_sales_team_rec.Partner_Customer_id,
         l_sales_team_rec.Partner_Address_id,
         l_sales_team_rec.lead_id,
         l_sales_team_rec.Freeze_Date,
         l_sales_team_rec.Salesforce_Role_Code,
         l_sales_team_rec.Salesforce_Relationship_code,
         l_sales_team_rec.Sales_group_id,
         1,
         l_sales_team_rec.Sales_lead_id,
         l_sales_team_rec.Partner_Cont_Party_Id,
         l_sales_team_rec.owner_flag,
         l_sales_team_rec.created_by_tap_flag,
         'Y',
    l_open_flag
      );

   end if;

   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
   END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW)    THEN
      fnd_message.Set_Name('PV', 'API:' || l_api_name || ': End');
      fnd_msg_pub.Add;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);

EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;

      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      fnd_msg_pub.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

end UpdateAccess;


procedure GetWorkflowID   (p_api_version_number  IN  NUMBER,
                           p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
                           p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
                           p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
                           p_lead_id             IN  NUMBER,
                           p_entity              IN  VARCHAR2,
                           x_itemType            OUT NOCOPY  VARCHAR2,
                           x_itemKey             OUT NOCOPY  VARCHAR2,
                           x_routing_status      OUT NOCOPY  VARCHAR2,
                           x_wf_status           OUT NOCOPY  VARCHAR2,
                           x_return_status       OUT NOCOPY  VARCHAR2,
                           x_msg_count           OUT NOCOPY  NUMBER,
                           x_msg_data            OUT NOCOPY  VARCHAR2) is

   l_api_name            CONSTANT VARCHAR2(30) := 'GetWorkflowID';
   l_api_version_number  CONSTANT NUMBER       := 1.0;

begin
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
        fnd_msg_pub.initialize;
    END IF;

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || '. Lead id: ' || p_Lead_id);
      fnd_msg_pub.Add;
   END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

   begin

      select wl.wf_item_type, wl.wf_item_key, wl.routing_status, wl.wf_status
      into   x_itemType, x_itemKey, x_routing_status, x_wf_status
      from   pv_lead_workflows  wl
      where  wl.lead_id   = p_lead_id
      and    wl.entity    = p_entity
      and    wl.latest_routing_flag = 'Y';

   exception
   when TOO_MANY_ROWS then

      fnd_message.Set_Name('PV', 'PV_INVALID_ROUTING_ROW');
      fnd_message.Set_Token('P_LEAD_ID', p_lead_id);
      fnd_msg_pub.Add;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   when NO_DATA_FOUND then
      null;
   end;

   if x_itemkey is NULL then
      x_wf_status   := 'NEW';

   elsif x_routing_status not in (pv_assignment_pub.g_r_status_active,
                              pv_assignment_pub.g_r_status_matched,
                              pv_assignment_pub.g_r_status_offered,
                              pv_assignment_pub.g_r_status_recycled,
                              pv_assignment_pub.g_r_status_unassigned,
                              pv_assignment_pub.g_r_status_abandoned,
                              pv_assignment_pub.g_r_status_failed_auto,
                              pv_assignment_pub.g_r_status_withdrawn) then

      fnd_message.Set_Name('PV', 'PV_UNKNOWN_ROUTING_STAGE');
      fnd_message.SET_TOKEN('P_ROUTING', x_routing_status);
      fnd_msg_pub.ADD;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   elsif x_wf_status not in (pv_assignment_pub.g_wf_status_open, pv_assignment_pub.g_wf_status_closed) then

      fnd_message.Set_Name('PV', 'PV_INVALID_WF_STATUS');
      fnd_message.SET_TOKEN('P_WF_STATUS', x_wf_status);
      fnd_message.Set_Token('P_LEAD_ID', p_lead_id);
      fnd_msg_pub.ADD;

      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   end if;

  --
  -- End of API body.
  --

   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
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
end GetWorkflowID;

--=============================================================================+
--|  Private Function                                                          |
--|                                                                            |
--|    Get_Salesgroup_ID                                                       |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
FUNCTION Get_Salesgroup_ID (
   p_resource_id   IN NUMBER
)
RETURN NUMBER
IS
   l_sales_group_id_str        VARCHAR2(100);
   l_sales_group_id            NUMBER;

   -- ------------------------------------------------------------------
   -- Retrieves the salesgroup_id of a resource.
   -- IF the resource belongs to more than one sales group, get the
   -- sales group from the profile: ASF_DEFAULT_GROUP_ROLE.
   -- ------------------------------------------------------------------
   CURSOR c_salesgroup_id IS
      SELECT DECODE(COUNT(*),
                    0,
                    null,
                    1,
                    TO_CHAR(MAX(grp.group_id)),
                    FND_PROFILE.VALUE_SPECIFIC('ASF_DEFAULT_GROUP_ROLE',
                       MAX(RES.user_id))) salesgroup_id
      FROM   JTF_RS_GROUP_MEMBERS mem,
             JTF_RS_ROLE_RELATIONS rrel,
             JTF_RS_ROLES_B role,
             JTF_RS_GROUP_USAGES u,
             JTF_RS_GROUPS_B grp,
             JTF_RS_RESOURCE_EXTNS RES
      WHERE  mem.group_member_id     = rrel.role_resource_id AND
             rrel.role_resource_type = 'RS_GROUP_MEMBER' AND
             rrel.role_id            = role.role_id AND
             role.role_type_code IN ('SALES','TELESALES','FIELDSALES','PRM') AND
             mem.delete_flag         <> 'Y' AND
             rrel.delete_flag        <> 'Y' AND
             sysdate BETWEEN rrel.start_date_active AND
                NVL(rrel.end_date_active, SYSDATE) AND
             mem.group_id            = u.group_id AND
             u.usage                 in ('SALES','PRM') AND
             mem.group_id            = grp.group_id AND
             sysdate BETWEEN grp.start_date_active AND
                NVL(grp.end_date_active,sysdate) AND
             mem.resource_id         = RES.resource_id AND
             RES.resource_id         = p_resource_id;

BEGIN
   Debug('Calling Get_Salesgroup_ID function...........');
   Debug('resource_id = ' || p_resource_id);

   FOR x IN c_salesgroup_id LOOP
    BEGIN
      l_sales_group_id_str := x.salesgroup_id;

      Debug('l_sales_group_id_str = ' || l_sales_group_id_str);

      -- -------------------------------------------------------------
      -- Parse out the string into an ID.
      -- The string could look like this: "100000100(Member)"
      -- -------------------------------------------------------------
      IF (INSTR(l_sales_group_id_str, ')') > 0) THEN
         l_sales_group_id :=
            TO_NUMBER(SUBSTR(l_sales_group_id_str, 1,
                         INSTR(l_sales_group_id_str, '(') - 1));

      ELSE
         l_sales_group_id := TO_NUMBER(l_sales_group_id_str);
      END IF;

    EXCEPTION
       WHEN OTHERS THEN
          l_sales_group_id := null;
    END;
   END LOOP;

   RETURN l_sales_group_id;
END Get_Salesgroup_ID;

procedure checkforErrors (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_itemtype            IN  VARCHAR2
   ,p_itemkey             IN  VARCHAR2
   ,x_return_status       OUT NOCOPY  VARCHAR2
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2) is

   l_api_name            CONSTANT VARCHAR2(30) := 'checkforErrors';
   l_api_version_number  CONSTANT NUMBER       := 1.0;
   l_wf_error_msg        varchar2(2000);
   l_wf_error_stack        varchar2(2000);


   -- check root itemkey and all child itemkeys for any errors
   -- initially this cursor was using nid but found out that
   -- wf_item_activity_statuses.notification_id is sometimes null when there is an error

   -- ignore mailer errors (WFMLRSND_FAILED)

   cursor lc_wf_error_message(pc_itemtype varchar2, pc_itemkey varchar2) is
      select error_message , error_stack
      from   wf_item_activity_statuses
      where  item_type           = pc_itemtype
      and    item_key in
      (select item_key from wf_items
       start with item_type = pc_itemtype and item_key = pc_itemkey
       connect by parent_item_key = prior item_key and parent_item_type = pc_itemtype)
       and error_message is not null and error_name <> 'WFMLRSND_FAILED';


begin
   -- Standard call to check for call compatibility.

   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
                                       p_api_version_number,
                                       l_api_name,
                                       G_PKG_NAME) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
   END IF;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name);
      fnd_msg_pub.Add;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   open lc_wf_error_message(pc_itemtype => p_itemtype, pc_itemkey => p_itemkey);
   fetch lc_wf_error_message into l_wf_error_msg, l_wf_error_stack;
   close lc_wf_error_message;

   if l_wf_error_msg is not null then

      fnd_message.SET_NAME('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.SET_TOKEN('TEXT' ,l_wf_error_msg);
      fnd_msg_pub.ADD;

      fnd_message.SET_NAME('PV', 'PV_MSG_FRM_CHK_FOR_ERR');
      fnd_message.SET_TOKEN('P_ITEM_TYPE' ,p_itemtype);
      fnd_message.SET_TOKEN('P_ITEM_KEY' ,p_itemkey);

      if fnd_profile.value('ASF_PROFILE_DEBUG_MSG_ON') = 'Y' then

          fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
          fnd_message.Set_Token('TEXT', l_wf_error_stack);
          fnd_msg_pub.Add;

      end if;

      raise FND_API.G_EXC_ERROR;

   end if;
   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);
EXCEPTION

   WHEN FND_API.G_EXC_ERROR THEN

      x_return_status := FND_API.G_RET_STS_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

end checkforErrors;


-- ***************************************************************************

--=============================================================================+
--|  Private Procedure                                                          |
--|                                                                            |
--|    Set_Message                                                             |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Debug(
   p_msg_string       IN VARCHAR2
)
IS

BEGIN
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      FND_MESSAGE.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      FND_MESSAGE.Set_Token('TEXT', p_msg_string);
      FND_MSG_PUB.Add;
   END IF;
END Debug;
-- =================================End of Debug================================



--=============================================================================+
--|  Private Procedure                                                          |
--|                                                                            |
--|    Set_Message                                                             |
--|                                                                            |
--|  Parameters                                                                |
--|  IN                                                                        |
--|  OUT                                                                       |
--|                                                                            |
--|                                                                            |
--| NOTES:                                                                     |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2 := NULL ,
    p_token2_value  IN      VARCHAR2 := NULL,
    p_token3        IN      VARCHAR2 := NULL,
    p_token3_value  IN      VARCHAR2 := NULL
)
IS
BEGIN
    IF FND_MSG_PUB.Check_Msg_Level(p_msg_level) THEN
        FND_MESSAGE.Set_Name('PV', p_msg_name);
        FND_MESSAGE.Set_Token(p_token1, p_token1_value);

        IF (p_token2 IS NOT NULL) THEN
           FND_MESSAGE.Set_Token(p_token2, p_token2_value);
        END IF;

        IF (p_token3 IS NOT NULL) THEN
           FND_MESSAGE.Set_Token(p_token3, p_token3_value);
        END IF;

        FND_MSG_PUB.Add;
    END IF;
END Set_Message;
-- ==============================End of Set_Message==============================


End PV_ASSIGN_UTIL_PVT;

/
