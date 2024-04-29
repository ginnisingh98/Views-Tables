--------------------------------------------------------
--  DDL for Package Body AS_OPPORTUNITY_VUHK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_OPPORTUNITY_VUHK" as
/* $Header: pvxvhopb.pls 115.21 2002/12/26 15:59:57 vansub ship $ */

G_PKG_NAME    CONSTANT VARCHAR2(30):='AS_OPPORTUNITY_VUHK';
G_FILE_NAME   CONSTANT VARCHAR2(12):='pvxvhopb.pls';

PROCEDURE Create_opp_header_Post(
    P_Api_Version_Number         IN   NUMBER,
    P_Init_Msg_List              IN   VARCHAR2    := FND_API.G_FALSE,
    P_Commit                     IN   VARCHAR2    := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    P_Check_Access_Flag          IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Flag                 IN   VARCHAR2    := FND_API.G_FALSE,
    P_Admin_Group_Id             IN   NUMBER,
    P_Identity_Salesforce_Id     IN   NUMBER      := NULL,
    P_salesgroup_id              IN   NUMBER      := NULL,
    P_profile_tbl                IN   AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    P_Partner_Cont_Party_id      IN   NUMBER      := FND_API.G_MISS_NUM,
    P_Header_Rec                 IN   AS_OPPORTUNITY_PUB.Header_Rec_Type
                                      := AS_OPPORTUNITY_PUB.G_MISS_Header_REC,
    X_LEAD_ID                    OUT NOCOPY   NUMBER,
    X_Return_Status              OUT NOCOPY   VARCHAR2,
    X_Msg_Count                  OUT NOCOPY   NUMBER,
    X_Msg_Data                   OUT NOCOPY   VARCHAR2
    ) IS

   l_api_name                CONSTANT VARCHAR2(30) := 'create_opp_header_post';
   l_api_version_number      CONSTANT NUMBER   := 2.0;

BEGIN

    -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
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

    x_return_status := FND_API.G_RET_STS_SUCCESS ;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', ' ********* Before calling PV_OPPORTUNITY_VHUK.Create_Opportunity_Post');
      fnd_msg_pub.Add;
   END IF;

    PV_OPPORTUNITY_VHUK.Create_Opportunity_Post (
            p_api_version_number      => 1.0,
            p_init_msg_list           => p_init_msg_list,
            p_commit                  => p_commit,
            p_validation_level        => p_validation_level,
            p_oppty_header_rec        => P_Header_Rec ,
            p_salesforce_id           => P_Identity_Salesforce_Id,
            x_return_status           => x_return_status,
            x_msg_count               => x_msg_count,
            x_msg_data                => x_msg_data);

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', '********* After calling PV_OPPORTUNITY_VHUK.Create_Opportunity_Post');
      fnd_msg_pub.Add;
   END IF;

    IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

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

END Create_opp_header_Post;


PROCEDURE Update_Opp_Header_Pre
(   p_api_version_number       IN     NUMBER,
    p_init_msg_list            IN     VARCHAR2    := FND_API.G_FALSE,
    p_commit                   IN     VARCHAR2    := FND_API.G_FALSE,
    p_validation_level         IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_check_access_flag        IN     VARCHAR2,
    p_admin_flag               IN     VARCHAR2,
    p_admin_group_id           IN     NUMBER,
    p_identity_salesforce_id   IN     NUMBER,
    p_profile_tbl              IN     AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    p_partner_cont_party_id    IN     NUMBER,
    p_header_rec               IN     AS_OPPORTUNITY_PUB.Header_Rec_Type,
    x_return_status            OUT NOCOPY     VARCHAR2,
    x_msg_count                OUT NOCOPY     NUMBER,
    x_msg_data                 OUT NOCOPY     VARCHAR2
)
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'update_opp_header_pre';
   l_api_version_number      CONSTANT NUMBER   := 2.0;

    cursor lc_get_channel_type (pc_lead_id    number) is
       select fnd_profile.value('PV_USER_TYPE'),
              a.channel_code,
              decode(nvl(c.channel_lookup_code,'0'), '0', 'N', c.indirect_channel_flag ),
              a.prm_assignment_type
       from   as_leads_all a, pv_channel_types c
       where  a.lead_id                 = pc_lead_id
       and    a.channel_code            = c.channel_lookup_code(+)
       and    c.channel_lookup_type (+) = 'SALES_CHANNEL';


   cursor lc_chk_channel_code (pc_code    varchar2) is
      select
             a.meaning,
             nvl(b.indirect_channel_flag, 'N')
      from   oe_lookups a, pv_channel_types b
      where  a.lookup_type  = 'SALES_CHANNEL'
      and    a.lookup_code  = pc_code
      and    a.lookup_type  = b.channel_lookup_type (+)
      and    a.lookup_code  = b.channel_lookup_code (+);

   l_temp                 varchar2(30);
   l_user_type            varchar2(30);
   l_curr_channel_code    varchar2(30);
   l_curr_indirect_flag   varchar2(1);
   l_to_indirect_flag     varchar2(1);
   l_to_channel_meaning   varchar2(80);
   l_prm_assignment_type  varchar2(80);

BEGIN

   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call (l_api_version_number,
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

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   open lc_get_channel_type (pc_lead_id => p_header_rec.lead_id);
   fetch lc_get_channel_type into l_user_type,
                                  l_curr_channel_code,
                                  l_curr_indirect_flag,
                                  l_prm_assignment_type;

   if lc_get_channel_type%NOTFOUND then

      close lc_get_channel_type;

      FND_MESSAGE.Set_Name('PV', 'PV_LEAD_NOT_FOUND');
      FND_MESSAGE.Set_Token('LEAD_ID', p_header_rec.lead_id);
      FND_MSG_PUB.Add;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   end if;

   close lc_get_channel_type;

   if l_curr_indirect_flag = 'Y' then

      -- channel_code in the record type may be null if user has decided not to display
      -- the column in the opportunity summary page.  In that case it will be G_MISS_CHAR

      if p_header_rec.channel_code <> FND_API.G_MISS_CHAR and p_header_rec.channel_code <> l_curr_channel_code then

         open lc_chk_channel_code(pc_code   => p_header_rec.channel_code);

         fetch lc_chk_channel_code into l_to_channel_meaning,
                                        l_to_indirect_flag;

         if lc_chk_channel_code%NOTFOUND then

            close lc_chk_channel_code;

            FND_MESSAGE.Set_Name('PV', 'PV_INVALID_CHANNEL_CODE');
            FND_MESSAGE.Set_Token('P_CHANNEL', p_header_rec.channel_code);
            FND_MSG_PUB.Add;

            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

         end if;

         close lc_chk_channel_code;

         if   l_to_indirect_flag <> 'Y'
	 and  (l_prm_assignment_type <> 'UNASSIGNED')
	 then

            FND_MESSAGE.Set_Name('PV', 'PV_OPP_ALREADY_ASSIGNED');
            FND_MESSAGE.Set_Token('P_CHANNEL', l_to_channel_meaning);
            FND_MSG_PUB.Add;

            RAISE FND_API.G_EXC_ERROR;

         end if;

      end if;
   end if;

   -- Added by Ajoy for user hook.
   PV_OPPORTUNITY_VHUK.Update_Opportunity_Pre (
      p_api_version_number      => 1.0,
      p_init_msg_list           => p_init_msg_list,
      p_commit                  => p_commit,
      p_validation_level        => p_validation_level,
      p_oppty_header_rec        => P_Header_Rec ,
      p_salesforce_id           => P_Identity_Salesforce_Id,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data);


   -- Standard call to get message count and if count is 1, get message info.
   fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_FALSE,
                              p_count     =>  x_msg_count,
                              p_data      =>  x_msg_data);

  IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
  END IF;

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
END update_opp_header_pre;

-- Added by Ajoy
-- Post hook is not used
PROCEDURE Update_Opp_Header_Post
(   p_api_version_number       IN     NUMBER,
    p_init_msg_list            IN     VARCHAR2    := FND_API.G_FALSE,
    p_commit                   IN     VARCHAR2    := FND_API.G_FALSE,
    p_validation_level         IN     NUMBER      := FND_API.G_VALID_LEVEL_FULL,
    p_check_access_flag        IN     VARCHAR2,
    p_admin_flag               IN     VARCHAR2,
    p_admin_group_id           IN     NUMBER,
    p_identity_salesforce_id   IN     NUMBER,
    p_profile_tbl              IN     AS_UTILITY_PUB.PROFILE_TBL_TYPE,
    p_partner_cont_party_id    IN     NUMBER,
    p_header_rec               IN     AS_OPPORTUNITY_PUB.Header_Rec_Type,
    x_return_status            OUT NOCOPY     VARCHAR2,
    x_msg_count                OUT NOCOPY     NUMBER,
    x_msg_data                 OUT NOCOPY     VARCHAR2
)
IS
   l_api_name                CONSTANT VARCHAR2(30) := 'update_opp_header_pre';
   l_api_version_number      CONSTANT NUMBER   := 2.0;

BEGIN

/*
   PV_OPPORTUNITY_VHUK.Update_Opportunity_Post (
      p_api_version_number      => 1.0,
      p_init_msg_list           => p_init_msg_list,
      p_commit                  => p_commit,
      p_validation_level        => p_validation_level,
      p_oppty_header_rec        => P_Header_Rec ,
      p_salesforce_id           => P_Identity_Salesforce_Id,
      x_return_status           => x_return_status,
      x_msg_count               => x_msg_count,
      x_msg_data                => x_msg_data);


   IF FND_API.To_Boolean ( p_commit )   THEN
      COMMIT WORK;
   END IF;
*/

-- Added this code for bugfix : 1975105
   x_return_status := FND_API.G_RET_STS_SUCCESS ;

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
END update_opp_header_post;

end AS_OPPORTUNITY_VUHK;


/
