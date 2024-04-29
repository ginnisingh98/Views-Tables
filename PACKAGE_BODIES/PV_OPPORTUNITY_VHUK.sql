--------------------------------------------------------
--  DDL for Package Body PV_OPPORTUNITY_VHUK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_OPPORTUNITY_VHUK" as
/* $Header: pvxvoptb.pls 120.4 2006/03/28 12:19:45 amaram ship $ */

-- Start of Comments

-- Package name     : PV_OPPORTUNITY_VHUK
-- Purpose          : 1. Send out email notification to CM when an opportunity is created by Partner / VAD
--                    2. When an Opportunity is created or updated retrieve the partner related information
--                       associated with the campaign from AMS table and copy into
--                       AS_LEAD_ASSIGNMENTS table to keep track of the associated partner with the Campaign.
-- History          :
--
-- NOTE             :
-- End of Comments
--


G_PKG_NAME    CONSTANT VARCHAR2(30):='PV_OPPORTUNITY_VHUK';
G_FILE_NAME   CONSTANT VARCHAR2(12):='pvxvoptb.pls';


-- --------------------------------------------------------------
-- Used   for inserting output messages to the message table.
-- --------------------------------------------------------------
PROCEDURE Debug(
   p_msg_string      IN VARCHAR2
);

-- private to this package
procedure CreateRole (
   p_api_version_number   IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,p_itemType            IN  VARCHAR2
   ,p_itemKey             IN  VARCHAR2
   ,p_partner_id          IN  NUMBER
   ,p_notify_type         IN  VARCHAR2
   ,p_assignment_status   IN  VARCHAR2
   ,x_roleName            OUT NOCOPY  VARCHAR2
   ,x_msg_count           OUT NOCOPY  NUMBER
   ,x_msg_data            OUT NOCOPY  VARCHAR2
   ,x_return_status       OUT NOCOPY  VARCHAR2) is

   l_api_name            CONSTANT VARCHAR2(30) := 'CreateRole';
   l_api_version_number  CONSTANT NUMBER       := 1.0;

   cursor lc_get_party_for_status (pc_itemType       varchar2,
                                   pc_itemKey        varchar2,
                                   pc_notify_type    varchar2,
                                   pc_assign_status  varchar2)  is
      select   distinct usr.user_name
      from     pv_lead_assignments aa, pv_party_notifications bb, fnd_user usr
      where    bb.wf_item_key        = pc_itemKey
      and      bb.wf_item_type       = pc_itemType
      and      bb.notification_type  = pc_notify_type
      and      bb.lead_assignment_id = aa.lead_assignment_id
      and      aa.status             = pc_assign_status
      and      bb.user_id            = usr.user_id;

   cursor lc_role_exist_chk (pc_rolename varchar2) is
      select name from wf_local_roles
      where  name = pc_rolename;

   l_role_list        wf_directory.usertable;
   l_username_tbl     pv_assignment_pub.g_varchar_table_type := pv_assignment_pub.g_varchar_table_type();
   l_username         varchar2(50);
   l_adhoc_role       varchar2(80);
   l_exist_rolename   varchar2(80);

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
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || '. Roletype: ' || p_notify_type ||
                         '. Itemtype: ' || p_itemtype || '. p_assignemnt_status: ' || p_assignment_status);
      fnd_msg_pub.Add;
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS ;

   l_adhoc_role := 'PV2' || p_notify_type || p_itemkey || '+' || nvl(p_partner_id, '0');

   open lc_get_party_for_status (pc_itemType      => p_itemtype,
                                 pc_itemKey       => p_itemKey,
                                 pc_notify_type   => p_notify_type,
                                 pc_assign_status => p_assignment_status);

   loop
      fetch lc_get_party_for_status into l_username;
      exit when lc_get_party_for_status%notfound;
      l_username_tbl.extend;
      l_username_tbl(l_username_tbl.last) := l_username;
   end loop;
   close lc_get_party_for_status;

   for i in 1 .. l_username_tbl.count  loop
     l_role_list(i) := l_username_tbl(i);
   end loop;

   if l_role_list.count > 0 then


      -- Debug Message
      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
         if l_exist_rolename is null then
            fnd_message.Set_token('TEXT', 'Creating role: '||l_adhoc_role||' with members :--');
         else
            fnd_message.Set_token('TEXT', 'Adding to role: '||l_adhoc_role||' with members :--');
         end if;
         fnd_msg_pub.Add;
      END IF;

      FOR i in 1 .. l_role_list.count
       LOOP



           IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
		fnd_message.Set_token('TEXT', l_role_list(i) );
		fnd_msg_pub.Add;
           END IF;

        END LOOP;


      if l_exist_rolename is null then
         wf_directory.CreateAdHocRole2(role_name         => l_adhoc_role,
                                      role_display_name => l_adhoc_role,
                                      role_users        => l_role_list,
                  expiration_date   => sysdate + 5);
      else
         wf_directory.AddUsersToAdHocRole2(role_name   => l_adhoc_role,
                                          role_users  => l_role_list);
      end if;

      x_roleName := l_adhoc_role;

   else

      fnd_message.SET_NAME('PV', 'PV_EMPTY_ROLE');
      fnd_msg_pub.ADD;

      raise FND_API.G_EXC_ERROR;

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
end CreateRole;





/********************************************************/
/*  Takes the username table, item type and send        */
/*  email notification.                                 */
/********************************************************/

procedure Send_Email_By_Workflow (
    p_api_version_number  IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_user_name_tbl       IN  JTF_VARCHAR2_TABLE_100,
    p_user_type_tbl       IN  JTF_VARCHAR2_TABLE_100,
    p_username            IN  VARCHAR2,
    p_opp_amt             IN  VARCHAR2,
    p_opp_name            IN  VARCHAR2,
    p_customer_name       IN  VARCHAR2,
    p_lead_number         IN  NUMBER,
    p_from_status         IN  VARCHAR2,
    p_to_status           IN  VARCHAR2,
    p_vendor_org_name     IN  VARCHAR2,
    p_partner_names       IN  VARCHAR2,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2) is

   l_api_name            CONSTANT VARCHAR2(30) := 'Send_Email_By_Workflow';
   l_api_version_number  CONSTANT NUMBER       := 1.0;

   l_cm_role_list        wf_directory.usertable;
   l_am_role_list        wf_directory.usertable;
   l_ot_role_list        wf_directory.usertable;
   l_pt_role_list        wf_directory.usertable;

   l_am_adhoc_role       VARCHAR2(80);
   l_cm_adhoc_role       VARCHAR2(80);
   l_pt_adhoc_role       VARCHAR2(80);
   l_ot_adhoc_role       VARCHAR2(80);

   l_itemType       CONSTANT VARCHAR2(30)  := g_wf_itemtype_notify;
   l_itemKey       VARCHAR2(30);

   l_send_respond_url    VARCHAR2(500);
   l_vendor_org_name     VARCHAR2(50);
   l_email_enabled       VARCHAR2(5);

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
       fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
       fnd_message.Set_Token('TEXT', 'In ' || l_api_name || p_from_status || p_to_status);
       fnd_msg_pub.Add;
    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS ;

    -- check the profile value and return if the value is not Y
    l_email_enabled := nvl(fnd_profile.value('PV_EMAIL_NOTIFICATION_FLAG'), 'Y');

    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
    fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.Set_Token('TEXT', 'Email Notication is Enabled '||l_email_enabled);
         fnd_msg_pub.Add;
    END IF;

    if (l_email_enabled <> 'Y') then
        return;
    else
       IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
          fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
          fnd_message.Set_Token('TEXT', 'Email Notication is Enabled ');
          fnd_msg_pub.Add;
       END IF;
    end if;

    SELECT  PV_LEAD_WORKFLOWS_S.nextval INTO l_itemKey
    FROM    dual;

    FOR i in 1 .. p_user_name_tbl.count
    LOOP

        IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
           fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
           fnd_message.Set_Token('TEXT', 'In Loop of p_user_name_tbl '||p_user_name_tbl(i));
           fnd_msg_pub.Add;
        END IF;

        IF p_user_type_tbl(i) = 'AM'  THEN
           l_am_role_list(i) := p_user_name_tbl(i);
        ELSIF p_user_type_tbl(i) = 'CM'  THEN
           l_cm_role_list(i) :=  p_user_name_tbl(i);
        ELSIF p_user_type_tbl(i) = 'OTHER'  THEN
           l_ot_role_list(i) :=  p_user_name_tbl(i);
        ELSIF p_user_type_tbl(i) = 'PT'  THEN
           l_pt_role_list(i) := p_user_name_tbl(i);
        END IF;

    END LOOP;

    IF l_am_role_list.count > 0  then
       l_am_adhoc_role := 'PV_' || l_itemKey || 'AM' || '_' || '0';

        -- Debug Message

       IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
          Debug('Creating role AM : '|| l_am_adhoc_role || ' with members :--');
       END IF;

       FOR i in 1 .. l_am_role_list.count
       LOOP



           IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
           dEBUG( l_am_role_list(i) );
           END IF;

        END LOOP;

       wf_directory.CreateAdHocRole2(role_name         => l_am_adhoc_role,
                                    role_display_name => l_am_adhoc_role,
                                    role_users        => l_am_role_list);
    END IF;

    IF l_cm_role_list.count > 0 then
       l_cm_adhoc_role := 'PV_' || l_itemKey || 'CM' || '_' || '0';

        -- Debug Message
       IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
          debug('Creating role CM : '|| l_cm_adhoc_role || ' with members :-' );
       END IF;

       FOR i in 1 .. l_cm_role_list.count
       LOOP
           IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
           dEBUG( l_cm_role_list(i) );
           END IF;
        END LOOP;
       wf_directory.CreateAdHocRole2(role_name         => l_cm_adhoc_role,
                                    role_display_name => l_cm_adhoc_role,
                                    role_users        => l_cm_role_list);
    END IF;

    IF l_pt_role_list.count > 0  then
       l_pt_adhoc_role := 'PV_' || l_itemKey || 'PT' || '_' || '0';

        -- Debug Message
       IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
          debug( 'Creating role PT: '|| l_pt_adhoc_role || ' with members :-' );
       END IF;
       FOR i in 1 .. l_pt_role_list.count
       LOOP
           IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
           dEBUG( l_pt_role_list(i) );
           END IF;
        END LOOP;

       wf_directory.CreateAdHocRole2(role_name         => l_pt_adhoc_role,
                                    role_display_name => l_pt_adhoc_role,
                                    role_users        => l_pt_role_list);
    END IF;

    IF l_ot_role_list.count > 0 then
       l_ot_adhoc_role := 'PV_' || l_itemKey || 'OTHER' || '_' || '0';

        -- Debug Message
      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         debug('Creating role OT : '|| l_ot_adhoc_role || ' with members:- ' );
      END IF;
       FOR i in 1 .. l_ot_role_list.count
       LOOP
           IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
           dEBUG( l_ot_role_list(i) );
           END IF;
        END LOOP;

      wf_directory.CreateAdHocRole2(role_name         => l_ot_adhoc_role,
                                   role_display_name => l_ot_adhoc_role,
                                   role_users        => l_ot_role_list);

    END IF;

    IF  l_cm_role_list.count < 1  AND l_am_role_list.count < 1
    AND l_pt_role_list.count < 1 AND l_ot_role_list.count < 1
    THEN
       return;
    ELSE

       -- Once the parameters for workflow is validated, start the workflow
       wf_engine.CreateProcess (ItemType => l_itemType,
                                ItemKey  => l_itemKey,
                                process  => g_wf_pcs_notify_party);

       wf_engine.SetItemUserKey (ItemType => l_itemType,
                                 ItemKey  => l_itemKey,
                                 userKey  => l_itemkey);

       /* Coomented out for the wf limitation of owner, that cannot be more than 30 chars

       wf_engine.SetItemOwner (ItemType => l_itemType,
                ItemKey  => l_itemKey,
                Owner    => p_username);
       */

       wf_engine.SetItemAttrText (ItemType => l_itemType,
                                  ItemKey  => l_itemKey,
                                  aname    => g_wf_attr_am_notify_role,
                                  avalue   => l_am_adhoc_role);

       wf_engine.SetItemAttrText (ItemType => l_itemType,
                                  ItemKey  => l_itemKey,
                                  aname    => g_wf_attr_cm_notify_role,
                                  avalue   => l_cm_adhoc_role);

       wf_engine.SetItemAttrText (ItemType => l_itemType,
                                  ItemKey  => l_itemKey,
                                  aname    => g_wf_attr_pt_notify_role,
                                  avalue   => l_pt_adhoc_role);

       wf_engine.SetItemAttrText (ItemType => l_itemType,
                                  ItemKey  => l_itemKey,
                                  aname    => g_wf_attr_ot_notify_role,
                                  avalue   => l_ot_adhoc_role);

       wf_engine.SetItemAttrText (ItemType => l_itemType,
                                  ItemKey  => l_itemKey,
                                  aname    => g_wf_attr_opp_number,
                                  avalue   => p_lead_number);

       wf_engine.SetItemAttrText ( ItemType => l_itemType,
                                   ItemKey  => l_itemKey,
                                   aname    => g_wf_attr_customer_name,
                                   avalue   => p_customer_name);

       wf_engine.SetItemAttrText ( ItemType => l_itemType,
                                   ItemKey  => l_itemKey,
                                   aname    => g_wf_attr_opp_amt,
                                   avalue   => p_opp_amt);

       wf_engine.SetItemAttrText ( ItemType => l_itemType,
                                   ItemKey  => l_itemKey,
                                   aname    => g_wf_attr_opp_name,
                                   avalue   => p_opp_name);

       wf_engine.SetItemAttrText ( ItemType => l_itemType,
                                   ItemKey  => l_itemKey,
                                   aname    => g_wf_attr_vendor_org_name,
                                   avalue   => p_vendor_org_name);

       l_send_respond_url :=  fnd_profile.value('PV_WORKFLOW_RESPOND_SELF_SERVICE_URL');

       wf_engine.SetItemAttrText ( ItemType => l_itemType,
                                   ItemKey  => l_itemKey,
                                   aname    => g_wf_attr_send_url,
                                   avalue   => l_send_respond_url);

       wf_engine.SetItemAttrText (ItemType => l_itemType,
                                  ItemKey  => l_itemKey,
                                  aname    => g_wf_attr_from_status,
                                  avalue   => p_from_status);

       wf_engine.SetItemAttrText (ItemType => l_itemType,
                                  ItemKey  => l_itemKey,
                                  aname    => g_wf_attr_to_status,
                                  avalue   => p_to_status);

       wf_engine.SetItemAttrText (ItemType => l_itemType,
                                  ItemKey  => l_itemKey,
                                  aname    => g_wf_attr_partner_name,
                                  avalue   => p_partner_names);

       wf_engine.StartProcess (ItemType => l_itemType,
                               ItemKey  => l_itemKey);

       -- Call the following procedure to see whether workflow was able to send notification successfully.
       PV_ASSIGN_UTIL_PVT.checkforErrors
           (p_api_version_number  => 1.0
           ,p_init_msg_list       => FND_API.G_FALSE
           ,p_commit              => FND_API.G_FALSE
           ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
           ,p_itemtype            => l_itemType
           ,p_itemkey             => l_itemKey
           ,x_msg_count           => x_msg_count
           ,x_msg_data            => x_msg_data
           ,x_return_status       => x_return_status);

      -- Check the x_return_status. If its not successful throw an exception.
      if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
     raise FND_API.G_EXC_ERROR;
      end if;

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
     fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
     fnd_message.Set_token('TEXT', 'After Checkforerror');
     fnd_msg_pub.Add;
      END IF;
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
end Send_Email_By_Workflow;


/**********************************************************************/
/*  General API to start the workflow based on the username list      */
/*  This private methos is used for Opportunity notication module.    */
/*  email notification.                                               */
/**********************************************************************/
procedure StartWorkflow (
   p_api_version_number  IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_itemKey             IN  VARCHAR2,
   p_itemType            IN  VARCHAR2,
   p_partner_id          IN  NUMBER,
   p_partner_name        IN  VARCHAR2,
   p_lead_id             IN  NUMBER,
   p_opp_name            IN  VARCHAR2,
   p_lead_number         IN  NUMBER,
   p_customer_id         IN  NUMBER,
   p_address_id          IN  NUMBER,
   p_customer_name       IN  VARCHAR2,
   p_creating_username   IN  VARCHAR2,
   p_bypass_cm_ok_flag   IN  VARCHAR2,
   x_return_status       OUT NOCOPY  VARCHAR2,
   x_msg_count           OUT NOCOPY  NUMBER,
   x_msg_data            OUT NOCOPY  VARCHAR2) is

    l_api_name            CONSTANT VARCHAR2(30) := 'StartWorkflow';
    l_api_version_number  CONSTANT NUMBER       := 1.0;
    l_role_name           varchar2(80);
    l_email_enabled       varchar2(30);
    l_respondURL          varchar2(100);
    l_r_notify_type       varchar2(20) := 'MATCHED_TO';
    l_vendor_org_name     VARCHAR2(200);
    l_send_respond_url    VARCHAR2(200);

 cursor lc_get_vendor_org(pc_partner_id NUMBER)
 is
   select  hp.party_name
   from   hz_relationships porg,
          hz_parties       hp,
          hz_organization_profiles hzop,
          pv_partner_profiles pvpp
   where  porg.party_id           = pc_partner_id
   and    porg.subject_table_name = 'HZ_PARTIES'
   and    porg.object_table_name  = 'HZ_PARTIES'
   and    porg.relationship_code  = 'PARTNER_OF'
   and    porg.relationship_type  = 'PARTNER'
   and    porg.status             = 'A'
   and    PORG.start_date <= SYSDATE
   and    nvl(PORG.end_date, SYSDATE) >= SYSDATE
   and    porg.object_id          = hp.party_id
   and    hp.status               = 'A'
   and    hp.party_type           = 'ORGANIZATION'
   AND    HZOP.party_id = hp.party_id
   AND    HZOP.effective_end_date is null
   AND    HZOP.internal_flag = 'Y'
   AND    PVPP.partner_id = PORG.party_id
   AND    PVPP.SALES_PARTNER_FLAG   = 'Y';

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
      debug( 'In ' || l_api_name);
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- check the profile value and return if the value is not Y
   l_email_enabled := nvl(fnd_profile.value('PV_EMAIL_NOTIFICATION_FLAG'), 'Y');

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      debug('Email Enabled Flag '||l_email_enabled);
   END IF;

   if (l_email_enabled <> 'Y') then
      return;
   end if;

   open  lc_get_vendor_org(p_partner_id);
   fetch lc_get_vendor_org INTO l_vendor_org_name;
   close lc_get_vendor_org;

    -- Create the role before sending the notification
    CreateRole (
        p_api_version_number   => 1.0
       ,p_init_msg_list        => FND_API.G_FALSE
       ,p_commit               => FND_API.G_FALSE
       ,p_validation_level     => p_validation_level
       ,p_itemType            => p_itemtype
       ,p_itemKey             => p_itemKey
       ,p_partner_id          => p_partner_id
       ,p_notify_type         => l_r_notify_type
       ,p_assignment_status   => 'PT_CREATED'
       ,x_roleName            => l_role_name
       ,x_msg_count           => x_msg_count
       ,x_msg_data            => x_msg_data
       ,x_return_status       => x_return_status);

    if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
        raise FND_API.G_EXC_ERROR;
    end if;

    -- Debug Message
    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
       debug( 'After Createrole, withing Startworkflow');
    END IF;

    wf_engine.CreateProcess (   ItemType => p_itemtype,
                                ItemKey  => p_itemkey,
                                process  => g_wf_pcs_notify_cm);

    wf_engine.SetItemUserKey (  itemType => p_itemtype,
                                itemKey  => p_itemkey,
                                userKey  => p_itemkey);

/* Coomented out for the wf limitation of owner, that cannot be more than 30 chars
    wf_engine.SetItemOwner (    ItemType => p_itemtype,
                                ItemKey  => p_itemkey,
                                Owner    => p_creating_username);
*/

    wf_engine.SetItemAttrText ( itemtype => p_itemType,
                                itemkey  => p_itemKey,
                                aname    => g_wf_attr_vendor_org_name,
                                avalue   => l_vendor_org_name);

    wf_engine.SetItemAttrText ( itemtype => p_itemType,
                                itemkey  => p_itemKey,
                                aname    => g_wf_attr_lead_id,
                                avalue   => p_lead_id);

    wf_engine.SetItemAttrText ( itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => g_wf_attr_opp_number,
                                avalue   => p_lead_number);

    wf_engine.SetItemAttrText ( itemtype => p_itemType,
                                itemkey  => p_itemKey,
                                aname    => g_wf_attr_opp_name,
            avalue   => p_opp_name);

    wf_engine.SetItemAttrText ( itemtype => p_itemtype,
                                itemkey  => p_itemkey,
                                aname    => g_wf_attr_customer_name,
                                avalue   => p_customer_name);

    wf_engine.SetItemAttrText ( itemtype => p_itemType,
                                itemkey  => p_itemKey,
                                aname    => g_wf_attr_notify_role,
                                avalue   => l_role_Name);

    wf_engine.SetItemAttrText ( itemtype => p_itemType,
                                itemkey  => p_itemKey,
                                aname    => g_wf_attr_partner_id,
                                avalue   => p_partner_id);

    wf_engine.SetItemAttrText ( itemtype => p_itemType,
                                itemkey  => p_itemKey,
                                aname    => g_wf_attr_partner_name,
                                avalue   => p_partner_name);

    l_send_respond_url :=  fnd_profile.value('PV_WORKFLOW_RESPOND_SELF_SERVICE_URL');

     wf_engine.SetItemAttrText ( itemtype => p_itemType,
                                itemkey  => p_itemKey,
                                aname    => g_wf_attr_send_url,
                                avalue   => l_send_respond_url);

    wf_engine.StartProcess  (   itemtype => p_itemtype,
                                itemkey  => p_itemkey);

    IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN

       debug('wf item attr '|| wf_engine.GetItemAttrText ( itemtype => p_itemType, itemkey  => p_itemKey,
                                aname    => g_wf_attr_send_url));
       debug('End of Workflow process');

    END IF;

    -- Debug Message

    IF FND_API.To_Boolean ( p_commit )   THEN
        COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.Count_And_Get(  p_encoded   =>  FND_API.G_TRUE,
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
end StartWorkflow;




/********************************************************/
/*  Notify the Channel Managers when an Opportunity is  */
/*  created by Partner or VAD.                          */
/********************************************************/
procedure Notify_CM_On_Create_Oppty (
    p_api_version_number  IN  NUMBER,
    p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
    p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    p_oppty_header_rec    IN  AS_OPPORTUNITY_PUB.header_rec_type,
    p_salesforce_id       IN  NUMBER,
    p_relationship_type   IN  VARCHAR2,
    p_party_relation_id   IN  NUMBER,
    p_user_name           IN  VARCHAR2,
    p_party_name          IN  VARCHAR2,
    p_partner_type        IN  VARCHAR2,
    x_return_status       OUT NOCOPY  VARCHAR2,
    x_msg_count           OUT NOCOPY  NUMBER,
    x_msg_data            OUT NOCOPY  VARCHAR2)
 is

    l_api_name             CONSTANT  VARCHAR2(30) := 'Notify_CM_On_Create_Oppty';
    l_api_version_number   CONSTANT  NUMBER       := 1.0;

    l_access_code_update   CONSTANT VARCHAR2(10) := 'UPDATE';

    l_assign_seq           NUMBER := 0; -- Assignment sequence is set to 1 as there will always be 1 partner
    l_party_id             NUMBER;
    l_username             fnd_user.user_name%type;
    l_party_relation_id    NUMBER;
    l_partner_resource_id  NUMBER;
    l_lead_number          VARCHAR2(30)      := p_oppty_header_rec.lead_id;
    l_lead_id              NUMBER      := p_oppty_header_rec.lead_id;
    l_customer_id          NUMBER      := p_oppty_header_rec.customer_id;
    l_customer_name        VARCHAR2(500)  := p_oppty_header_rec.customer_name;
    l_opp_name             VARCHAR2(500)  := p_oppty_header_rec.description;
    l_opp_amt              NUMBER      := NVL(p_oppty_header_rec.total_amount,0);
    l_currency_code        VARCHAR2(20);
    l_opp_amt_curncy       VARCHAR2(50);
    l_address_id           NUMBER      := p_oppty_header_rec.address_id;
    l_lead_assignment_id   NUMBER;
    l_access_id            NUMBER;
    l_bypass_cm_ok_flag    VARCHAR2(1)     := 'N';
    l_entity               VARCHAR2(20)    := g_entity;
    l_itemType  CONSTANT   VARCHAR2(30)    := g_wf_itemtype_notify;
    l_itemKey              VARCHAR2(8);
    l_wf_status_closed     VARCHAR2(20)    := g_wf_status_closed;
    l_relationship_type    VARCHAR2(30);
    l_source_type          VARCHAR2(20)    := 'SALESTEAM'; --'OPPTYCR';
    l_vendor_org_name      VARCHAR2(50);
    l_partner_name         VARCHAR2(100);
    l_r_status_active      VARCHAR2(20)    := g_r_status_active;
    l_r_status_unassigned  VARCHAR2(20)    := g_r_status_unassigned;

    l_r_notify_type      VARCHAR2(20)    := 'MATCHED_TO';
    l_la_status_pt_created varchar2(20)    := g_la_status_pt_created;

    l_lead_workflow_rec    pv_assign_util_pvt.lead_workflow_rec_type;
    l_assignment_rec       pv_assign_util_pvt.ASSIGNMENT_REC_TYPE;
    l_rs_details_tbl       pv_assign_util_pvt.resource_details_tbl_type := pv_assign_util_pvt.resource_details_tbl_type();
    l_party_notify_rec_tbl pv_assignment_pvt.party_notify_rec_tbl_type;
    l_sales_team_rec       as_access_pub.sales_team_rec_type;
    l_access_profile_rec   as_access_pub.access_profile_rec_type;

    l_new_resource_count   NUMBER;
    l_person_id            NUMBER;
    l_related_party_id     NUMBER;
    l_sales_grp_id_str      VARCHAR2(200);
    l_sales_group_id       NUMBER;
    l_category         VARCHAR2(20);

    cursor lc_get_group_id(pc_resource_id number) is
    SELECT max(res.category), DECODE(COUNT(*),
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
             RES.resource_id         = pc_resource_id;

    lc_cursor             pv_assignment_pub.g_ref_cursor_type;

  CURSOR lc_opportunity (pc_lead_id number) is
    SELECT  ld.customer_id, ld.address_id
          , pt.party_name, ld.currency_code
    FROM    as_leads_all ld, hz_parties   pt
    WHERE   ld.customer_id = pt.party_id
    AND       ld.lead_id = pc_lead_id;

 CURSOR lc_get_opp_amt (pc_lead_id NUMBER) is
    SELECT SUM(NVL(total_amount,0))
    FROM   as_lead_lines
    WHERE  lead_id = pc_lead_id;

/*  CURSOR lc_address (pc_party_relation_id number) is
    SELECT  address_id, resource_id
    FROM    jtf_rs_resource_extns
    WHERE   category = 'PARTNER'
    and     sysdate between start_date_active and nvl(end_date_active,sysdate)
    AND     source_id = pc_party_relation_id; */

   -- --------------------------------------------------------------------------
   -- This cursor is a modification of the above cursor. The SQL now pulls
   -- address_id directly from TCA.
   -- --------------------------------------------------------------------------
   CURSOR lc_address (pc_party_relation_id number) is
     SELECT  b.address_id, a.resource_id
     FROM    jtf_rs_resource_extns a,
             as_party_addresses_v b,
             pv_partner_profiles c
     WHERE   a.category = 'PARTNER'
     AND     sysdate between a.start_date_active and nvl(a.end_date_active,sysdate)
     AND     a.source_id = pc_party_relation_id
     AND     a.source_id = c.partner_id
     AND     c.partner_party_id = b.party_id
     AND     b.primary_address_flag = 'Y';

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

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      Debug('In ' || l_api_name);
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      Debug('Relationship Type ' || p_relationship_type);
   END IF;

   IF p_relationship_type is not null THEN
      l_lead_workflow_rec.lead_id             := l_lead_id;
      l_lead_workflow_rec.entity              := l_entity;
      l_lead_workflow_rec.wf_item_type        := l_itemtype;
      l_lead_workflow_rec.wf_status           := l_wf_status_closed;
      l_lead_workflow_rec.bypass_cm_ok_flag   := l_bypass_cm_ok_flag;
      l_lead_workflow_rec.latest_routing_flag := 'Y';

      IF p_relationship_type = 'PARTNER_OF' THEN
         IF p_partner_type = 'PARTNER' THEN
            l_lead_workflow_rec.routing_status   := l_r_status_active;
            l_lead_workflow_rec.routing_type     := 'SINGLE';
        ELSIF p_partner_type = 'VAD' THEN
            l_lead_workflow_rec.routing_status   := l_r_status_unassigned;
        END IF;
      END IF;

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         Debug('Routing Status ' || l_lead_workflow_rec.routing_status);
      END IF;

      pv_assign_util_pvt.Create_lead_workflow_row
      (  p_api_version_number  => 1.0
         ,p_init_msg_list       => FND_API.G_FALSE
         ,p_commit              => FND_API.G_FALSE
         ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
         ,p_workflow_rec        => l_lead_workflow_rec
         ,x_ItemKey             => l_itemKey
         ,x_return_status       => x_return_status
         ,x_msg_count           => x_msg_count
         ,x_msg_data            => x_msg_data
      );

      IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Get the Channel Manager information
      pv_assign_util_pvt.get_partner_info
      (  p_api_version_number     => 1.0
         ,p_init_msg_list          => FND_API.G_FALSE
         ,p_commit                 => FND_API.G_FALSE
         ,p_validation_level       => FND_API.G_VALID_LEVEL_FULL
         ,p_mode                   => pv_assignment_pub.g_external_org
         ,p_partner_id             => p_party_relation_id
         ,p_entity                 => l_entity
         ,p_entity_id              => l_lead_id
         ,p_retrieve_mode          => 'BOTH'   -- change from CM to BOTH for 11.5.10
         ,x_rs_details_tbl         => l_rs_details_tbl
         ,x_vad_id                 => l_related_party_id
         ,x_return_status          => x_return_status
         ,x_msg_count              => x_msg_count
         ,x_msg_data               => x_msg_data
      );

      IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- If Channel manager found create assignment and notification record
      If l_rs_details_tbl.count <= 0 THEN
         FND_MESSAGE.set_name('PV', 'PV_EMPTY_ROLE');
         FND_MSG_PUB.add;
         RAISE FND_API.g_exc_unexpected_error;
      ELSE
         -- Insert into table PV_LEAD_ASSIGNMENTS with STATUS to PT_CREATED.
         -- Populate data with the following values.
         l_assignment_rec.lead_id                := l_lead_id;
         l_assignment_rec.partner_id             := p_party_relation_id;
         l_assignment_rec.source_type            := l_source_type;
         l_assignment_rec.assign_sequence        := l_assign_seq;
         l_assignment_rec.object_version_number  := 0;
         l_assignment_rec.status_date            := SYSDATE;
         l_assignment_rec.status                 := l_la_status_pt_created;
         l_assignment_rec.related_party_id       := l_related_party_id;
         l_assignment_rec.partner_access_code    := l_access_code_update;
         l_assignment_rec.wf_item_type           := l_itemType;
         l_assignment_rec.wf_item_key            := l_itemKey;

         pv_assign_util_pvt.Create_lead_assignment_row
         (   p_api_version_number  => 1.0
            ,p_init_msg_list       => FND_API.G_FALSE
            ,p_commit              => FND_API.G_FALSE
            ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
            ,p_assignment_rec      => l_assignment_rec
            ,x_lead_assignment_id  => l_lead_assignment_id
            ,x_return_status       => x_return_status
            ,x_msg_count           => x_msg_count
            ,x_msg_data            => x_msg_data
         );

         IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- Insert into table PV_PARTY_NOTIFICATIONS. Populate data with the
         -- following values. Extend the table for the number of channel managers

         l_new_resource_count := l_rs_details_tbl.count;

         l_party_notify_rec_tbl.WF_ITEM_TYPE.extend       (l_rs_details_tbl.last);
         l_party_notify_rec_tbl.WF_ITEM_KEY.extend        (l_rs_details_tbl.last);
         l_party_notify_rec_tbl.LEAD_ASSIGNMENT_ID.extend (l_rs_details_tbl.last);
         l_party_notify_rec_tbl.NOTIFICATION_TYPE.extend  (l_rs_details_tbl.last);
         l_party_notify_rec_tbl.RESOURCE_ID.extend        (l_rs_details_tbl.last);
         l_party_notify_rec_tbl.USER_ID.extend            (l_rs_details_tbl.last);
         l_party_notify_rec_tbl.USER_NAME.extend          (l_rs_details_tbl.last);
         l_party_notify_rec_tbl.RESOURCE_RESPONSE.extend  (l_new_resource_count);
         l_party_notify_rec_tbl.RESPONSE_DATE.extend      (l_new_resource_count);
         l_party_notify_rec_tbl.DECISION_MAKER_FLAG.extend(l_new_resource_count);

         -- Loop through and populate the table

         FOR i in 1 .. l_rs_details_tbl.count LOOP
            l_party_notify_rec_tbl.WF_ITEM_TYPE(i)       := l_itemtype;
            l_party_notify_rec_tbl.WF_ITEM_KEY(i)        := l_itemkey;
            l_party_notify_rec_tbl.LEAD_ASSIGNMENT_ID(i) := l_lead_assignment_id;
            l_party_notify_rec_tbl.NOTIFICATION_TYPE(i)  := l_rs_details_tbl(i).notification_type;
            l_party_notify_rec_tbl.RESOURCE_ID(i)        := l_rs_details_tbl(i).resource_id;
            l_party_notify_rec_tbl.USER_ID(i)            := l_rs_details_tbl(i).user_id;
            l_party_notify_rec_tbl.USER_NAME(i)          := l_rs_details_tbl(i).user_name;
            l_party_notify_rec_tbl.DECISION_MAKER_FLAG(i):= 'Y';

            IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN

               Debug( 'Assignment ID: ' || l_lead_assignment_id ||
               '. Notification type: ' || l_party_notify_rec_tbl.NOTIFICATION_TYPE(i) ||
               '. Username: ' || l_party_notify_rec_tbl.USER_NAME(i));

            END IF;
         END LOOP;

         -- Insert in bulk for all the channel manager by calling the procedure
         pv_assignment_pvt.bulk_cr_party_notification
         (   p_api_version_number    => 1.0
            ,p_init_msg_list         => FND_API.G_FALSE
            ,p_commit                => FND_API.G_FALSE
            ,p_validation_level      => FND_API.G_VALID_LEVEL_FULL
            ,p_party_notify_Rec_tbl  => l_party_notify_rec_tbl
            ,x_return_status         => x_return_status
            ,x_msg_count             => x_msg_count
            ,x_msg_data              => x_msg_data);

         IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- For each Channel Manager/partner contact in l_rs_details_tbl call the procedure to
         -- update the Sales team. This will insert rows in as_access_all.write
         -- access records for the channel managers/contact, partners are later

         FOR i in l_rs_details_tbl.first .. l_rs_details_tbl.last LOOP

            -- skip if resource already on salesteam
            for c_check in (select 1 from as_accesses_all where
                            salesforce_id <> l_rs_details_tbl(i).resource_id and lead_id = l_lead_id)
            loop
               -- The returned table has all CM from Vendor and VAD.
               -- Since VAD CM does not have person id, we need to populate partner_cont_party_id

               if l_rs_details_tbl(i).person_type = pv_assignment_pub.g_resource_employee then
                  l_sales_team_rec.partner_cont_party_id := null;
                  l_sales_team_rec.person_id := l_rs_details_tbl(i).person_id;
               else
                  l_sales_team_rec.person_id := null;
                  l_sales_team_rec.partner_cont_party_id := l_rs_details_tbl(i).person_id;
               end if;

               IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                  Debug( 'Partner Contact Party ID '||l_sales_team_rec.partner_cont_party_id);
               END IF;

               l_sales_team_rec.lead_id               := l_lead_id;
               l_sales_team_rec.customer_id           := l_customer_id;
               l_sales_team_rec.freeze_flag           := 'Y';
               l_sales_team_rec.partner_customer_id   := null;
               l_sales_team_rec.salesforce_id         := l_rs_details_tbl(i).resource_id;
               l_sales_team_rec.address_id            := l_address_id;
               l_sales_team_rec.team_leader_flag      := 'Y'; --Added per Suresh

               l_access_profile_rec := null;

               IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                  Debug( 'Lead ID '||l_lead_id ||' Customer ID '||l_customer_id||'salesforce_id'||
                         l_rs_details_tbl(i).resource_id);
               END IF;

               open  lc_get_group_id ( pc_resource_id => l_rs_details_tbl(i).resource_id);
               fetch lc_get_group_id into l_category, l_sales_grp_id_str;
               close lc_get_group_id;

               begin

                  if instr(l_sales_grp_id_str, '(') > 0 then
                     l_sales_group_id := to_number(substr(l_sales_grp_id_str, 1, instr(l_sales_grp_id_str, '(') - 1));
                  else
                     l_sales_group_id := to_number(l_sales_grp_id_str);
                  end if;

               exception
               when others then
                  if sqlcode = -6502 then  -- string is not a number
                     l_sales_group_id := null;
                  else
                     raise;
                  end if;
               end;

               if l_sales_group_id is NULL then

                  fnd_message.SET_NAME  ('PV', 'PV_DEBUG_MESSAGE');
                  fnd_message.SET_TOKEN ('TEXT' , 'No Default Sales Group for resource id '||
                                                   l_rs_details_tbl(i).resource_id);
                  fnd_msg_pub.ADD;

                  fnd_message.SET_NAME  ('PV', 'PV_DEBUG_MESSAGE');
                  fnd_message.SET_TOKEN ('TEXT' , 'Not adding to oppty salesteam: '||l_rs_details_tbl(i).user_name);
                  fnd_msg_pub.ADD;

               else

                  l_sales_team_rec.sales_group_id :=  l_sales_group_id;
                  as_access_pub.Create_SalesTeam
                     (p_api_version_number  =>  2 -- API Version has been changed
                     ,p_init_msg_list       =>  FND_API.G_FALSE
                     ,p_commit              =>  FND_API.G_FALSE
                     ,p_validation_level    =>  FND_API.G_VALID_LEVEL_FULL
                     ,p_access_profile_rec  =>  l_access_profile_rec
                     ,p_check_access_flag   =>  'N'
                     ,p_admin_flag          =>  'N'
                     ,p_admin_group_id      =>  null
                     ,p_identity_salesforce_id => p_salesforce_id
                     ,p_sales_team_rec      =>  l_sales_team_rec
                     ,x_return_status       =>  x_return_status
                     ,x_msg_count           =>  x_msg_count
                     ,x_msg_data            =>  x_msg_data
                     ,x_access_id           =>  l_access_id);

                  IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
                     RAISE FND_API.G_EXC_ERROR;
                  END IF;

                  IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
                     fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
                     fnd_message.Set_Token('TEXT', 'After 1st Create Sales team');
                     fnd_msg_pub.Add;
                  END IF;

               end if;

            END LOOP;
         END LOOP;

         -- Add the partner in the sales team. The first VAD_OF partner is
         -- picked up and added in the sales team to give access to all the
         -- contacts of the same partner in future.

         OPEN    lc_address (pc_party_relation_id => p_party_relation_id);
         FETCH   lc_address
         INTO    l_address_id, l_partner_resource_id;
         CLOSE   lc_address;

         IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.Set_Token('TEXT', 'Salesgroup ID'||l_sales_team_rec.sales_group_id);
            fnd_msg_pub.Add;
         END IF;

         l_sales_team_rec.sales_group_id     := null;
         l_sales_team_rec.person_id            := null;
         l_sales_team_rec.lead_id            := l_lead_id;
         l_sales_team_rec.customer_id         := l_customer_id;
         l_sales_team_rec.freeze_flag         := 'Y';
         l_sales_team_rec.partner_cont_party_id := null;
         l_sales_team_rec.partner_customer_id:= p_party_relation_id;
         l_sales_team_rec.salesforce_id      := l_partner_resource_id;
         l_sales_team_rec.partner_address_id   := l_address_id;
         l_sales_team_rec.team_leader_flag   := 'N'; --Added per Suresh

         as_access_pub.Create_SalesTeam
         (p_api_version_number  =>  2 -- API Version has been changed
         ,p_init_msg_list       =>  FND_API.G_FALSE
         ,p_commit              =>  FND_API.G_FALSE
         ,p_validation_level    =>  FND_API.G_VALID_LEVEL_FULL
         ,p_access_profile_rec  =>  l_access_profile_rec
         ,p_check_access_flag   =>  'N'
         ,p_admin_flag          =>  'N'
         ,p_admin_group_id      =>  null
         ,p_identity_salesforce_id => p_salesforce_id
         ,p_sales_team_rec      =>  l_sales_team_rec
         ,x_return_status       =>  x_return_status
         ,x_msg_count           =>  x_msg_count
         ,x_msg_data            =>  x_msg_data
         ,x_access_id           =>  l_access_id);

         -- Check the x_return_status. If its not successful throw an exception.
         IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         -- Add the VAD id when the opportunity is created by Indirectly Managed Partner
         -- Adding VAD organization will allow to add salesteam from that organization
         -- from UI later on.
         -- added validation to check if its created by IMP and use l_related_party_id
         -- for 11.5.10, we are not adding VAD when IMP creates oppty (l_related_party_id
         -- will always be null)

         IF l_related_party_id IS NOT NULL THEN

            OPEN    lc_address (pc_party_relation_id => l_related_party_id);
            FETCH   lc_address INTO l_address_id, l_partner_resource_id;
            CLOSE   lc_address;

            l_sales_team_rec.person_id      := null;
            l_sales_team_rec.lead_id      := l_lead_id;
            l_sales_team_rec.customer_id      := l_customer_id;
            l_sales_team_rec.freeze_flag      := 'Y';
            l_sales_team_rec.partner_customer_id   := p_party_relation_id;
            l_sales_team_rec.salesforce_id      := l_partner_resource_id;
            l_sales_team_rec.address_id      := l_address_id;
            l_sales_team_rec.team_leader_flag   := 'Y'; --Added per Suresh

            as_access_pub.Create_SalesTeam
            (p_api_version_number  =>  2 -- API Version has been changed
            ,p_init_msg_list       =>  FND_API.G_FALSE
            ,p_commit              =>  FND_API.G_FALSE
            ,p_validation_level    =>  FND_API.G_VALID_LEVEL_FULL
            ,p_access_profile_rec  =>  l_access_profile_rec
            ,p_check_access_flag   =>  'N'
            ,p_admin_flag          =>  'N'
            ,p_admin_group_id      =>  null
            ,p_identity_salesforce_id => p_salesforce_id
            ,p_sales_team_rec      =>  l_sales_team_rec
            ,x_return_status       =>  x_return_status
            ,x_msg_count           =>  x_msg_count
            ,x_msg_data            =>  x_msg_data
            ,x_access_id           =>  l_access_id);

            -- Check the x_return_status. If its not successful throw an exception.
            IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;

         END IF;

         IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.Set_Token('TEXT', 'After 2nd Create Sales team');
            fnd_msg_pub.Add;
         END IF;

         -- Update AS_LEADS_ALL set AUTO_ASSIGNMENT_TYPE in AS_LEADS_ALL to PRM for the lead_id.

         IF p_relationship_type = 'PARTNER_OF' THEN

            IF p_partner_type = 'PARTNER' THEN

               Update  AS_LEADS_ALL
               SET     PRM_ASSIGNMENT_TYPE  = 'SINGLE',
               AUTO_ASSIGNMENT_TYPE = 'PRM'
               WHERE   lead_id = l_lead_id;

            ELSIF p_partner_type = 'VAD' THEN  -- 'VAD_OF'

               Update  AS_LEADS_ALL
               SET     AUTO_ASSIGNMENT_TYPE = 'PRM'
               WHERE   lead_id = l_lead_id;

            END IF;

         END IF;

         OPEN lc_opportunity(l_lead_id);
         FETCH lc_opportunity INTO l_customer_id, l_address_id, l_customer_name, l_currency_code;
         CLOSE lc_opportunity;

         OPEN  lc_get_opp_amt(l_lead_id);
         FETCH lc_get_opp_amt INTO l_opp_amt;
         CLOSE lc_get_opp_amt;

         l_opp_amt_curncy := nvl(l_opp_amt,0) ||' '||l_currency_code;

         IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            debug('before starting workflow ...............');
         END IF;

         -- When all the table are updated start the workflow .
         StartWorkflow
         ( p_api_version_number  => 1.0,
         p_init_msg_list       => FND_API.G_FALSE,
         p_commit              => FND_API.G_FALSE,
         p_validation_level    => FND_API.G_VALID_LEVEL_FULL,
         p_itemKey             => l_itemKey,
         p_itemType            => l_itemType,
         p_partner_id          => p_party_relation_id,
         p_partner_name        => p_party_name,
         p_lead_id             => l_lead_id,
         p_opp_name            => l_opp_name,
         p_lead_number         => l_lead_number,
         p_customer_id         => l_customer_id,
         p_address_id          => l_address_id,
         p_customer_name       => l_customer_name,
         p_creating_username   => p_user_name,
         p_bypass_cm_ok_flag   => l_bypass_cm_ok_flag,
         x_return_status       => x_return_status,
         x_msg_count           => x_msg_count,
         x_msg_data            => x_msg_data);

         -- Check the x_return_status. If its not successful throw an exception.
         IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.Set_Token('TEXT', 'After Workflow is started');
            fnd_msg_pub.Add;
         END IF;

         -- Call the following procedure to see whether workflow was able to send notification successfully.
         PV_ASSIGN_UTIL_PVT.checkforErrors
         (p_api_version_number  => 1.0
         ,p_init_msg_list       => FND_API.G_FALSE
         ,p_commit              => FND_API.G_FALSE
         ,p_validation_level    => FND_API.G_VALID_LEVEL_FULL
         ,p_itemtype            => l_itemType
         ,p_itemkey             => l_itemKey
         ,x_msg_count           => x_msg_count
         ,x_msg_data            => x_msg_data
         ,x_return_status       => x_return_status);

         -- Check the x_return_status. If its not successful throw an exception.
         if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
            raise FND_API.G_EXC_ERROR;
         end if;
      END IF; -- No Channel Manager found
   END IF;

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
END Notify_CM_On_Create_Oppty;


Procedure Set_Oppty_Amt_Wf
  (  itemtype    in varchar2,
     itemkey     in varchar2,
     actid       in number,
     funcmode    in varchar2,
     resultout   in OUT NOCOPY varchar2)
is

   l_api_name            CONSTANT VARCHAR2(30) := 'SET_OPPTY_AMT_WF';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_resultout            varchar2(50);
   l_msg_count            number;
   l_msg_data             varchar2(2000);
   l_lead_id              number;
   l_opp_amt              number;
   l_currency_code        varchar2(100);
   l_amt_cny              varchar2(100);

   CURSOR lc_opp_amt(pc_lead_id NUMBER)
   IS
   SELECT nvl(total_amount,0), currency_code
   FROM   as_leads_all
   WHERE  lead_id = pc_lead_id;

BEGIN

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name || ' Funcmode: ' || funcmode);
      fnd_msg_pub.Add;
   END IF;

   IF (funcmode = 'RUN') then

      l_lead_id := wf_engine.GetItemAttrText ( itemtype => itemtype,
                                               itemkey  => itemkey,
                                               aname    => g_wf_attr_lead_id);
      OPEN  lc_opp_amt(l_lead_id);
      FETCH lc_opp_amt INTO l_opp_amt, l_currency_code;
      CLOSE lc_opp_amt;

      l_amt_cny := l_opp_amt||' '||l_currency_code;

      wf_engine.SetItemAttrText ( itemtype => itemtype,
                                  itemkey  => itemkey,
                                  aname    => g_wf_attr_opp_amt,
                                  avalue   => l_amt_cny);

      l_resultout := 'COMPLETE';

   ELSIF (funcmode = 'CANCEL') then
      l_resultout := 'COMPLETE';

  ELSIF (funcmode in ('RESPOND', 'FORWARD', 'TRANSFER')) then
      l_resultout := 'COMPLETE';

  ELSIF (funcmode = 'TIMEOUT') then
       l_resultout := 'COMPLETE';
  END IF;
  resultout := l_resultout;
EXCEPTION
     WHEN OTHERS THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;


END;
-- Vansub
-- Rivendell
-- Notify_on_Update_Oppty_from_JBES is called from Java Business Subscription when an opportunity is updated
-- in order to avoid generating rosetta wrapper and for the easy debug
-- Rivendell
procedure NOTIFY_ON_UPDATE_OPPTY_JBES (
          p_api_version_number  IN  NUMBER,
          p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
          p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
          p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          p_lead_id             IN  NUMBER,
          p_status              IN  VARCHAR2,
          p_lead_name           IN  VARCHAR2,
          p_customer_id         IN  NUMBER,
          p_total_amount        IN  NUMBER,
          p_salesforce_id       IN  NUMBER,
          x_return_status       OUT NOCOPY  VARCHAR2,
          x_msg_count           OUT NOCOPY  NUMBER,
          x_msg_data            OUT NOCOPY  VARCHAR2)
IS
    l_api_name              CONSTANT  VARCHAR2(100) := 'NOTIFY_ON_UPDATE_OPPTY_JBES';
    l_api_version_number    CONSTANT  NUMBER       := 1.0;

    l_opportunity_rec       AS_OPPORTUNITY_PUB.header_rec_type;


    CURSOR get_customer_name(pc_party_id NUMBER)
    IS
    SELECT party_name
    FROM   hz_parties
    WHERE  party_id = pc_party_id;

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

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name);
      fnd_msg_pub.Add;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

    OPEN   get_customer_name(p_customer_id);
    FETCH  get_customer_name INTO l_opportunity_rec.customer_name;
    CLOSE  get_customer_name;

    l_opportunity_rec.lead_id          := p_lead_id;
    l_opportunity_rec.status_code      := p_status;
    l_opportunity_rec.lead_number      := p_lead_id;
    l_opportunity_rec.description      := p_lead_name;
    l_opportunity_rec.total_amount     := p_total_amount;



   Notify_Party_On_Update_Oppty (
     p_api_version_number  => l_api_version_number,
     p_init_msg_list       => p_init_msg_list,
     p_commit              => p_commit,
     p_validation_level    => p_validation_level,
     p_oppty_header_rec    => l_opportunity_rec,
     p_salesforce_id       => p_salesforce_id,
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
      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
          fnd_message.Set_Token('TEXT', sqlcode||sqlerrm);
           fnd_msg_pub.Add;
       END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

END NOTIFY_ON_UPDATE_OPPTY_JBES;

-- Opportunity modify User Hook.
procedure Notify_Party_On_Update_Oppty (
          p_api_version_number  IN  NUMBER,
          p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
          p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
          p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          p_oppty_header_rec    IN  AS_OPPORTUNITY_PUB.header_rec_type,
          p_salesforce_id       IN  NUMBER,
          x_return_status       OUT NOCOPY  VARCHAR2,
          x_msg_count           OUT NOCOPY  NUMBER,
          x_msg_data            OUT NOCOPY  VARCHAR2) is

    l_api_name              CONSTANT  VARCHAR2(100) := 'Notify_Party_On_Update_Oppty';
    l_api_version_number    CONSTANT  NUMBER       := 1.0;

    l_lead_id                p_oppty_header_rec.lead_id%type := p_oppty_header_rec.lead_id;
    l_status                 p_oppty_header_rec.status_code%type := p_oppty_header_rec.status_code;
    l_lead_number            p_oppty_header_rec.lead_number%type := p_oppty_header_rec.lead_id;

    l_customer_name          p_oppty_header_rec.customer_name%type := p_oppty_header_rec.customer_name;
    l_opp_name               p_oppty_header_rec.description%type := p_oppty_header_rec.description;
    l_opp_amt                NUMBER := NVL(p_oppty_header_rec.total_amount,0);
    l_currency_code          VARCHAR2(30);
    l_opp_amt_curncy         VARCHAR2(30);
    l_salesforceid           NUMBER := p_salesforce_id;
    l_assignment_ids         NUMBER;
    l_workflow_id            NUMBER;
    l_user_id                NUMBER;
    l_user_name              fnd_user.user_name%type;
    l_creating_username      fnd_user.user_name%type;
    l_resource_id            jtf_rs_resource_extns.resource_id%type;
    l_category               jtf_rs_resource_extns.category%type;
    l_party_id               jtf_rs_resource_extns.source_id%type;
    l_party_name             jtf_rs_resource_extns.source_business_grp_name%type;
    l_vendor_org_name        jtf_rs_resource_extns.source_business_grp_name%type;
    l_customer_id            as_leads_all.customer_id%TYPE;
    l_address_id             as_leads_all.address_id%TYPE;
    l_wf_item_type           VARCHAR2(20);
    l_wf_item_key            VARCHAR2(20);
    l_partner_id             NUMBER;
    l_partner_name           VARCHAR2(360);
    l_partner_names          VARCHAR2(2000) := NULL;
    l_from_status            VARCHAR2(100);
    l_to_status              VARCHAR2(100);
    l_status_from            VARCHAR2(100);
    l_status_to              VARCHAR2(100);
    l_status_code            VARCHAR2(100);
    l_message_name           VARCHAR2(30);

    l_db_status             VARCHAR2(100);
    l_entity                VARCHAR2(20)  := 'OPPORTUNITY';

    -- Notification Flags
    l_notify_pt_flag            CHAR(1) := 'N';
    l_notify_am_flag            CHAR(1) := 'N';
    l_notify_cm_flag            CHAR(1) := 'N';
    l_notify_others_flag        CHAR(1) := 'N';

    l_user_id_tbl      JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
    l_user_name_tbl    JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
    l_resource_id_tbl  JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();
    l_user_type_tbl    JTF_VARCHAR2_TABLE_100 := JTF_VARCHAR2_TABLE_100();

    count_row       NUMBER := 1;

    l_user_type     VARCHAR2(20);

   CURSOR lc_users(pc_lead_id        NUMBER,
                   pc_notify_cm_flag VARCHAR2,
                   pc_notify_am_flag VARCHAR2,
                   pc_notify_pt_flag VARCHAR2,
                   pc_notify_ot_flag VARCHAR2)
   IS
   SELECT   pn.user_id, pn.resource_id, fu.user_name ,
            decode(pn.notification_type, 'MATCHED_TO', 'CM', 'PT') user_type,
            decode(pn.notification_type, 'MATCHED_TO', 0, pa.partner_id) partner_id
   FROM     pv_lead_workflows pw,
            pv_lead_assignments pa,
            pv_party_notifications pn,
            jtf_rs_resource_extns extn,
            as_accesses_all asac,
            fnd_user fu
   WHERE    pw.wf_item_type = pa.wf_item_type
   and      pw.wf_item_key = pa.wf_item_key
   AND      pa.lead_assignment_id = pn.lead_assignment_id
   AND      pw.routing_status = 'ACTIVE'
   AND      pw.latest_routing_flag = 'Y'
   AND      pw.lead_id = pc_lead_id
   AND      ((pn.notification_type = 'MATCHED_TO' and 'Y' = pc_notify_cm_flag)
             or (pn.notification_type = 'OFFERED_TO' and 'Y' = pc_notify_pt_flag))
   AND      pa.status IN ( 'PT_CREATED', 'PT_APPROVED' , 'CM_APP_FOR_PT' )
   AND      asac.salesforce_id = pn.resource_id
   AND      asac.lead_id =  pw.lead_id
   AND      asac.sales_lead_id IS NULL
   AND      asac.customer_id IS NOT NULL
   AND      asac.salesforce_id    = extn.resource_id
   AND      extn.user_id = fu.user_id
   AND      sysdate between extn.start_date_active and nvl(extn.end_date_active,sysdate)
   AND      sysdate between fu.start_date and nvl(fu.end_date,sysdate)
   UNION
   SELECT  js.user_id, js.resource_id, fu.user_name,
   decode(pw.created_by - js.user_id,0,'AM','OTHER') user_type, 0 partner_id
   FROM    as_accesses_all ac, jtf_rs_resource_extns js, fnd_user fu, pv_lead_workflows pw
   WHERE   (('Y' = pc_notify_ot_flag and pw.created_by <> js.user_id)
             or ('Y' = pc_notify_am_flag and pw.created_by = js.user_id))
   AND     ac.lead_id = pc_lead_id
   and     ac.lead_id = pw.lead_id
   and     pw.entity = 'OPPORTUNITY'
   AND     pw.latest_routing_flag = 'Y'
   AND     ac.salesforce_id = js.resource_id
   AND     js.user_id = fu.user_id
   AND     ac.sales_lead_id IS NULL
   AND     ac.customer_id IS NOT NULL
   and     sysdate between js.start_date_active and nvl(js.end_date_active,sysdate)
   AND     sysdate between fu.start_date and nvl(fu.end_date,sysdate)
   AND     NOT EXISTS
           (SELECT 1
            FROM pv_lead_assignments pl, pv_party_notifications pv
            WHERE  pl.lead_assignment_id = pv.lead_assignment_id
            AND    pv.resource_id = ac.salesforce_id
            and    pv.user_id <> pw.created_by
            AND    pl.wf_item_type = pw.wf_item_type
            AND    pl.wf_item_key = pw.wf_item_key)
   ORDER BY 4;

  CURSOR lc_assign_ids (pc_lead_id number) is
    SELECT  lead_workflow_id, wf_item_key, wf_item_type
    FROM    pv_lead_workflows pw
    WHERE   pw.routing_status = 'ACTIVE'
    AND     pw.latest_routing_flag = 'Y'
    AND     pw.lead_id = pc_lead_id;

    CURSOR  lc_status_notify (pc_status_code varchar2) is
    SELECT   nvl(notify_pt_flag,'N')
            ,nvl(notify_am_flag,'N')
            ,nvl(notify_cm_flag,'N')
            ,nvl(notify_others_flag,'N')
    FROM    pv_status_notifications
    WHERE    enabled_flag = 'Y'
    AND     status_type = 'OPPORTUNITY'
    AND       status_code = pc_status_code;

    CURSOR lc_opportunity (pc_lead_id number) is
    SELECT  ld.customer_id, ld.address_id, pt.party_name,
            nvl(ld.total_amount,0),ld.currency_code, ld.description
    FROM    as_leads_all ld, hz_parties   pt
    WHERE   ld.customer_id = pt.party_id
    AND       ld.lead_id = pc_lead_id;

    CURSOR lc_get_pt_emp_cat(pc_salesforce_id NUMBER) IS
    SELECT  js.source_id, js.category, js.source_business_grp_name, fu.user_name
    FROM    fnd_user fu, jtf_rs_resource_extns js
    WHERE   fu.user_id = js.user_id
    AND     js.resource_id = pc_salesforce_id;

    CURSOR lc_get_pt_ven_name(pc_party_id NUMBER) IS
    SELECT  VENDOR.party_name
    FROM    hz_parties VENDOR,
            hz_relationships PCONTACT,
            pv_partner_profiles PVPP
    WHERE   PCONTACT.party_id           = pc_party_id
    AND     PCONTACT.subject_table_name = 'HZ_PARTIES'
    AND     PCONTACT.object_table_name  = 'HZ_PARTIES'
    AND     PCONTACT.RELATIONSHIP_TYPE  = 'EMPLOYMENT'
    AND     PCONTACT.directional_flag   = 'F'
    AND     PCONTACT.STATUS             = 'A'
    AND     PCONTACT.start_date        <= SYSDATE
    AND     nvl(PCONTACT.end_date, SYSDATE) >= SYSDATE
    AND     PVPP.partner_party_id       = PCONTACT.object_id
    AND     VENDOR.party_id             = PVPP.partner_party_id
    AND     VENDOR.PARTY_TYPE           = 'ORGANIZATION'
    AND     VENDOR.status               = 'A'
    AND     PVPP.SALES_PARTNER_FLAG   = 'Y';

   l_partner_id_tbl   JTF_NUMBER_TABLE       := JTF_NUMBER_TABLE();

   cursor lc_get_pt_org_name(pc_item_type varchar2, pc_item_key varchar2) is
   select pt.party_name, pvas.partner_id
   from   hz_parties pt,
          pv_partner_profiles pvpp,
          pv_lead_assignments pvas
   where  pvas.wf_item_type =  pc_item_type
   and   pvas.wf_item_key  =  pc_item_key
   and    pvas.partner_id = pvpp.partner_id
   and    pvpp.partner_party_id = pt.party_id;

  cursor lc_get_meaning(pc_status_code VARCHAR2 ,pc_lead_id   NUMBER) IS
   select decode(a.status_code, t.status, a.meaning, a.status_code),
          decode(a.status_code, pc_status_code, a.meaning, a.status_code),
          a.status_code, a.win_loss_indicator
   from   as_statuses_vl a,
          (select status from as_leads_all
          where lead_id = pc_lead_id) t
   where  a.enabled_flag = 'Y'
   and    a.opp_flag = 'Y'
   and    a.status_code in (t.status, pc_status_code);

l_win_loss_indicator varchar2(1);
l_curr_win_loss_flag varchar2(1);
l_log_params_tbl  pvx_utility_pvt.log_params_tbl_type;


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

   -- Debug Message
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name);
      fnd_msg_pub.Add;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   OPEN    lc_assign_ids (pc_lead_id => l_lead_id);
   FETCH   lc_assign_ids INTO l_workflow_id,l_wf_item_key, l_wf_item_type;

   IF lc_assign_ids%FOUND THEN

      open  lc_get_pt_emp_cat(p_salesforce_id);
      fetch lc_get_pt_emp_cat into l_party_id, l_category,
      l_party_name, l_creating_username;
      close lc_get_pt_emp_cat;

      IF l_category = pv_assignment_pub.g_resource_employee THEN

         l_vendor_org_name := l_party_name;

      ELSIF l_category = pv_assignment_pub.g_resource_party THEN

         open lc_get_pt_ven_name(l_party_id);
         fetch lc_get_pt_ven_name into l_vendor_org_name;
         close lc_get_pt_ven_name;

      END IF;

      -- Debug Message
      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.Set_Token('TEXT', 'After Found : ' || l_creating_username || ' salesforce id : ' || p_salesforce_id);
         fnd_msg_pub.Add;
      END IF;

      -- Get the Opportunity Status from header and table
      -- IF Status is changed
      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.Set_Token('TEXT', 'Status '||l_status);
         fnd_msg_pub.Add;
      END IF;

      IF l_status is null THEN
         return;
      END IF;

      open lc_get_meaning(l_status,l_lead_id);
      loop
         fetch lc_get_meaning into l_status_from, l_status_to, l_db_status, l_curr_win_loss_flag;
         exit when lc_get_meaning%notfound;

         IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            Debug( 'l_status_to '||l_status_to ||' l_status_from '||l_status_from ||' DB Status '||l_db_status);
         END IF;

         IF l_db_status = l_status_from THEN
            l_to_status := l_status_to;
            l_win_loss_indicator := l_curr_win_loss_flag;
         ELSIF l_db_status = l_status_to THEN
            l_from_status := l_status_from;
         END IF;

      end loop;
      close lc_get_meaning;

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.Set_Token('TEXT', 'STATUS before  : ' || l_from_status || ', After : ' || l_to_status);
         fnd_msg_pub.Add;
      END IF;

      IF l_from_status IS NULL OR l_to_status IS NULL THEN
         return;
      END IF;

      OPEN lc_get_pt_org_name(l_wf_item_type, l_wf_item_key);
      LOOP
         FETCH lc_get_pt_org_name INTO l_partner_name, l_partner_id;
         EXIT WHEN lc_get_pt_org_name%NOTFOUND;

         l_partner_id_tbl.extend;
         l_partner_id_tbl(l_partner_id_tbl.count) := l_partner_id;

         IF l_partner_names is NULL THEN
            l_partner_names :=  l_partner_name ;
         ELSE
            l_partner_names := l_partner_names || ' ,' || l_partner_name ;
         END IF;

      END LOOP;
      CLOSE lc_get_pt_org_name;

      l_log_params_tbl(1).param_name := 'OPP_NUMBER';
      l_log_params_tbl(1).param_value := l_lead_number;

      l_log_params_tbl(2).param_name := 'STATUS';
      l_log_params_tbl(2).param_value := l_to_status;

      if l_win_loss_indicator = 'W' then
         l_message_name := 'PV_LG_OPPTY_WON';

      elsif l_win_loss_indicator = 'L' then
         l_message_name := 'PV_LG_OPPTY_LOST';
      else
         l_message_name := 'PV_LG_OPPTY_STATUS_CHG';
      end if;

      if l_message_name is not null then

         IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.SET_NAME('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.Set_token('TEXT', 'Logging status change message: ' || l_message_name ||
            ' for lead_id:' || l_lead_id || ' by resource:' || p_salesforce_id);
            fnd_msg_pub.Add;
         END IF;

         for l_pt_id in 1..l_partner_id_tbl.count loop
            PVX_Utility_PVT.create_history_log(
               p_arc_history_for_entity_code => 'OPPORTUNITY',
               p_history_for_entity_id       => l_lead_id,
               p_history_category_code       => 'GENERAL',
               p_message_code                => l_message_name,
               p_partner_id                  => l_partner_id_tbl(l_pt_id),
               p_access_level_flag           => 'V',
               p_interaction_level           => pvx_utility_pvt.G_INTERACTION_LEVEL_50,
               p_comments                    => NULL,
               p_log_params_tbl              => l_log_params_tbl,
               x_return_status               => x_return_status,
               x_msg_count                   => x_msg_count,
               x_msg_data                    => x_msg_data);

            if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
               raise FND_API.G_EXC_ERROR;
            end if;
         end loop;

      end if;

      OPEN    lc_status_notify (pc_status_code => l_status);
      FETCH   lc_status_notify
      INTO    l_notify_pt_flag, l_notify_am_flag, l_notify_cm_flag, l_notify_others_flag;
      CLOSE   lc_status_notify;

      -- Debug Message
      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
          fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
          fnd_message.Set_Token('TEXT', 'After PV Party Notification : ' || l_notify_pt_flag || l_notify_am_flag ||
                                         l_notify_cm_flag || l_notify_others_flag);
          fnd_msg_pub.Add;
      END IF;

      l_partner_id_tbl := JTF_NUMBER_TABLE();

      OPEN lc_users(l_lead_id, l_notify_cm_flag, l_notify_am_flag, l_notify_pt_flag, l_notify_others_flag);
      LOOP
         FETCH lc_users INTO l_user_id, l_resource_id, l_user_name, l_user_type, l_partner_id;
         EXIT WHEN lc_users%NOTFOUND;
         l_user_id_tbl.extend;
         l_user_name_tbl.extend;
         l_resource_id_tbl.extend;
         l_user_type_tbl.extend;

         l_user_id_tbl(count_row)        := l_user_id;
         l_user_name_tbl(count_row)      := l_user_name;
         l_resource_id_tbl(count_row)    := l_resource_id;
         l_user_type_tbl(count_row)      := l_user_type;

         IF l_partner_id <> 0 THEN
            l_partner_id_tbl.extend;
            l_partner_id_tbl(l_partner_id_tbl.count) := l_partner_id;
         END IF;

         count_row := count_row + 1;
      END LOOP;
      CLOSE lc_users;

      -- Debug Message
      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
         fnd_message.Set_Token('TEXT', 'Total number of parties to be notified : ' ||
                                   l_user_name_tbl.count || ' lead_id : ' || l_lead_id);
         fnd_msg_pub.Add;
      END IF;

      IF l_user_name_tbl.count > 0 THEN
         OPEN lc_opportunity(l_lead_id);
         FETCH lc_opportunity INTO l_customer_id, l_address_id, l_customer_name, l_opp_amt, l_currency_code, l_opp_name;
         CLOSE lc_opportunity;

         l_opp_amt_curncy := l_opp_amt ||' '||l_currency_code;

         IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
            fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
            fnd_message.Set_Token('TEXT', 'before calling the send_email ');
            fnd_msg_pub.Add;
         END IF;

         Send_Email_By_Workflow (
            p_api_version_number  =>  p_api_version_number,
            p_init_msg_list       =>  p_init_msg_list,
            p_commit              =>  p_commit,
            p_validation_level    =>  p_validation_level,
            p_user_name_tbl       =>  l_user_name_tbl,
            p_user_type_tbl       =>  l_user_type_tbl,
            p_username            =>  l_creating_username,
            p_opp_amt             =>  l_opp_amt_curncy,
            p_opp_name            =>  l_opp_name,
            p_customer_name       =>  l_customer_name,
            p_lead_number         =>  l_lead_number,
            p_from_status         =>  l_from_status,
            p_to_status           =>  l_to_status,
            p_vendor_org_name     =>  l_vendor_org_name,
            p_partner_names       =>  l_partner_names,
            x_return_status       =>  x_return_status,
            x_msg_count           =>  x_msg_count,
            x_msg_data            =>  x_msg_data);

      END IF;

      -- Check the x_return_status. If its not successful throw an exception.
      IF x_return_status <>  FND_API.G_RET_STS_SUCCESS then
         CLOSE   lc_assign_ids;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

   END IF; -- If Assignment has been started
   CLOSE   lc_assign_ids;

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
      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
          fnd_message.Set_Token('TEXT', sqlcode||sqlerrm);
           fnd_msg_pub.Add;
       END IF;

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

END Notify_Party_On_Update_Oppty;


PROCEDURE Party_Msg_Send_Wf
(  itemtype    in varchar2,
   itemkey     in varchar2,
   actid in number,
   funcmode    in varchar2,
   resultout   in OUT NOCOPY varchar2)
is

   l_api_name            CONSTANT VARCHAR2(30) := 'PARTY_MSG_SEND_WF';
   l_api_version_number  CONSTANT NUMBER   := 1.0;

   l_resultout            varchar2(50);
   l_msg_count            number;
   l_msg_data             varchar2(2000);

   l_am_adhoc_role       VARCHAR2(80) := NULL;
   l_cm_adhoc_role       VARCHAR2(80) := NULL;
   l_pt_adhoc_role       VARCHAR2(80) := NULL;
   l_ot_adhoc_role       VARCHAR2(80) := NULL;


   l_group_notify_id    NUMBER;
   l_pt_msg_name        VARCHAR2(80);
   l_am_msg_name        VARCHAR2(80);
   l_cm_msg_name        VARCHAR2(80);
   l_ot_msg_name        VARCHAR2(80);
   l_context            VARCHAR2(80);

Begin

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
     Debug( 'In ' || l_api_name || ' Funcmode: ' || funcmode);
   END IF;

   if (funcmode = 'RUN') then

      l_context := itemtype || ':' || itemkey || ':' || actid;

      l_pt_adhoc_role := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => g_wf_attr_pt_notify_role);

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
    Debug('Partner Role' || l_pt_adhoc_role);
      END IF;

      l_cm_adhoc_role := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => g_wf_attr_cm_notify_role);

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         Debug('CM Role' || l_cm_adhoc_role);
      END IF;

      l_ot_adhoc_role := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                     itemkey  => itemkey,
                                                     aname    => g_wf_attr_ot_notify_role);

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         Debug( 'Others Role' || l_ot_adhoc_role);
      END IF;

      l_am_adhoc_role := wf_engine.GetItemAttrText( itemtype => itemtype,
                                                    itemkey  => itemkey,
                                                    aname    => g_wf_attr_am_notify_role);

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
         Debug('AM Role' || l_am_adhoc_role);
      END IF;

      IF l_pt_adhoc_role IS NOT NULL THEN

          l_pt_msg_name   := 'PV_PARTY_OPTYUPD_PT_FYI_MSG';

          l_group_notify_id := wf_notification.sendGroup(
                          role         => l_pt_adhoc_role,
                          msg_type     => 'PVOPTYHK',
                          msg_name     => l_pt_msg_name,
                          due_date     => null,
                          callback     => 'wf_engine.cb',
                          context      => l_context,
                          send_comment => NULL,
                          priority     => NULL );
      END IF;

      IF l_cm_adhoc_role IS NOT NULL THEN

          l_cm_msg_name   := 'PV_PARTY_OPTYUPD_CM_FYI_MSG';

          l_group_notify_id := wf_notification.sendGroup(
                          role         => l_cm_adhoc_role,
                          msg_type     => 'PVOPTYHK',
                          msg_name     => l_cm_msg_name,
                          due_date     => null,
                          callback     => 'wf_engine.cb',
                          context      => l_context,
                          send_comment => NULL,
                          priority     => NULL );
     END IF;

     IF l_ot_adhoc_role IS NOT NULL THEN

         l_ot_msg_name   := 'PV_PARTY_OPTYUPD_OT_FYI_MSG';

         l_group_notify_id := wf_notification.sendGroup(
                          role         => l_ot_adhoc_role,
                          msg_type     => 'PVOPTYHK',
                          msg_name     => l_ot_msg_name,
                          due_date     => null,
                          callback     => 'wf_engine.cb',
                          context      => l_context,
                          send_comment => NULL,
                          priority     => NULL );
     END IF;

     IF l_am_adhoc_role IS NOT NULL THEN

        l_am_msg_name   := 'PV_PARTY_OPTYUPD_AM_FYI_MSG';

        l_group_notify_id := wf_notification.sendGroup(
                          role         => l_am_adhoc_role,
                          msg_type     => 'PVOPTYHK',
                          msg_name     => l_am_msg_name,
                          due_date     => null,
                          callback     => 'wf_engine.cb',
                          context      => l_context,
                          send_comment => NULL,
                          priority     => NULL );

    END IF;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN

     Debug('Group Notify ID' || l_group_notify_id);

   END IF;

      l_resultout := 'COMPLETE';

  ELSIF (funcmode = 'CANCEL') then
       l_resultout := 'COMPLETE';

  ELSIF (funcmode in ('RESPOND', 'FORWARD', 'TRANSFER')) then
       l_resultout := 'COMPLETE';

  ELSIF (funcmode = 'TIMEOUT') then
       l_resultout := 'COMPLETE';
  END IF;
  resultout := l_resultout;
EXCEPTION
     WHEN OTHERS THEN

      fnd_msg_pub.Count_And_Get(
         p_encoded  => FND_API.G_TRUE
         ,p_count   => l_msg_count
         ,p_data    => l_msg_data);

      wf_core.context(G_PKG_NAME, l_api_name,l_msg_data);
      raise;

END PARTY_MSG_SEND_WF;



/***************************************************/
/*  Call the Create Opportunity user hook. *********/
/***************************************************/
procedure Create_Opportunity_Post (
            p_api_version_number  IN  NUMBER,
            p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
            p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
            p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
            p_oppty_header_rec    IN  AS_OPPORTUNITY_PUB.header_rec_type,
            p_salesforce_id       IN  NUMBER,
            x_return_status       OUT NOCOPY  VARCHAR2,
            x_msg_count           OUT NOCOPY  NUMBER,
            x_msg_data            OUT NOCOPY  VARCHAR2) is

    l_api_name            CONSTANT  VARCHAR2(30) := 'Create_Opportunity_Post';
    l_api_version_number  CONSTANT  NUMBER       := 1.0;

    l_mode                VARCHAR2(10) := 'CREATE';
    l_relationship_type   VARCHAR2(20);
    l_party_id            NUMBER;
    l_party_relation_id   NUMBER;
    l_username            VARCHAR2(1000);
    l_party_name          VARCHAR2(1000);
    l_channel_code        VARCHAR2(50)    := p_oppty_header_rec.channel_code;
    l_partner_type     VARCHAR2(100);
    l_indirect_channel_flag VARCHAR2(10);


begin

    /***************************************************************************/
    /** Notify Channel manager if the Opportunity is created by Partner        */
    /** conatct or VAD contact                                                 */
    /***************************************************************************/

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
   END IF;

   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
   END IF;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name||' Lead ID : '||p_oppty_header_rec.lead_id
            ||' Salesforce ID : '||p_salesforce_id);
      fnd_msg_pub.Add;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   get_user_info
   (  p_salesforce_id      => p_salesforce_id,
      p_channel_code       => l_channel_code,
      x_party_rel_id       => l_party_relation_id,
      x_relationship_type  => l_relationship_type,
      x_user_name          => l_username,
      x_party_name         => l_party_name,
      x_party_type         => l_partner_type,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data
   );

   if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
   end if;

   -- -----------------------------------------------------------------
   -- Find out the channel type of the opportunity: DIRECT or INDIRECT.
   -- -----------------------------------------------------------------
   FOR x IN (
        select nvl(b.indirect_channel_flag, 'N') indirect_channel_flag
        from   oe_lookups a, pv_channel_types b
        where  a.lookup_type  = 'SALES_CHANNEL'
        and    a.lookup_code  = l_channel_code
        and    a.lookup_type  = b.channel_lookup_type (+)
        and    a.lookup_code  = b.channel_lookup_code (+))
   LOOP
      l_indirect_channel_flag := x.indirect_channel_flag;
   END LOOP;


   -- -----------------------------------------------------------------
   -- If the channel type is INDIRECT, notify CM and copy partners
   -- from the campaign to the sales team of the opportunity.
   -- -----------------------------------------------------------------
   IF (l_indirect_channel_flag = 'Y') THEN

      -- If not l_relationship_type = 'PARTNER_OF' or l_relationship_type is null then
      -- VAD creating opportunity : partners who were not managed by VAD were also added
      -- That was creating problem in assignment routing.
      -- Fo rnow, partners are not added from campaign while VAD is creating oppty.

      If l_relationship_type is null then

         if p_oppty_header_rec.source_promotion_id is not null then

            PV_BG_PARTNER_MATCHING_PUB.Start_Campaign_Assignment(
            p_api_version_number      => l_api_version_number,
            p_init_msg_list           => p_init_msg_list,
            p_commit                  => p_commit,
            p_validation_level        => p_validation_level,
            p_identity_salesforce_id  => p_salesforce_id,
            P_Lead_id                 => p_oppty_header_rec.lead_id,
            x_return_status           => x_return_status,
            x_msg_count               => x_msg_count,
            x_msg_data                => x_msg_data);

          if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
             raise FND_API.G_EXC_ERROR;
          end if;

        end if;

      end if;
   END IF; -- l_indirect_channel_flag = 'Y'

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

end Create_Opportunity_Post;


/***************************************************/
/*  Call the Update Opportunity user hook. *********/
/***************************************************/
procedure Update_Opportunity_Pre (
            p_api_version_number  IN  NUMBER,
            p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
            p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
            p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
            p_oppty_header_rec    IN  AS_OPPORTUNITY_PUB.header_rec_type,
            p_salesforce_id       IN  NUMBER,
            x_return_status       OUT NOCOPY  VARCHAR2,
            x_msg_count           OUT NOCOPY  NUMBER,
            x_msg_data            OUT NOCOPY  VARCHAR2) is

    l_api_name            CONSTANT  VARCHAR2(30) := 'Update_Opportunity_Pre';
    l_api_version_number  CONSTANT  NUMBER       := 1.0;

    l_mode                VARCHAR2(10) := 'UPDATE';

    l_channel_code        p_oppty_header_rec.channel_code%type  := p_oppty_header_rec.channel_code;
    l_relationship_type   VARCHAR2(20);
    l_party_relation_id   NUMBER;
    l_user_name        VARCHAR2(100);
    l_party_name     VARCHAR2(1000);
    l_partner_type     VARCHAR2(100);

begin

    /***************************************************************************/
    /** Notify Channel manager if the Opportunity is updated by Partner        */
    /** contact or VAD contact                                                 */
    /***************************************************************************/

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list ) THEN
      fnd_msg_pub.initialize;
   END IF;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
      fnd_message.Set_Token('TEXT', 'In ' || l_api_name);
      fnd_msg_pub.Add;
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   get_user_info
   (  p_salesforce_id      => p_salesforce_id,
      p_channel_code       => l_channel_code,
      x_party_rel_id       => l_party_relation_id,
      x_relationship_type  => l_relationship_type,
      x_user_name      => l_user_name,
      x_party_name      => l_party_name,
      x_party_type      => l_partner_type,
      x_return_status      => x_return_status,
      x_msg_count          => x_msg_count,
      x_msg_data           => x_msg_data
   );

   if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
      raise FND_API.G_EXC_ERROR;
   end if;

   if p_oppty_header_rec.source_promotion_id is not null then

      PV_BG_PARTNER_MATCHING_PUB.Start_Campaign_Assignment(
    P_Api_Version_Number      => l_api_version_number,
    P_Init_Msg_List           => p_init_msg_list,
    P_Commit                  => p_commit,
    P_Validation_Level        => p_validation_level,
    P_Identity_Salesforce_Id  => p_salesforce_id,
    P_Lead_id                 => p_oppty_header_rec.lead_id,
    x_return_status           => x_return_status,
    x_msg_count               => x_msg_count,
    x_msg_data                => x_msg_data);

      if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
      end if;

   end if;

    Notify_Party_On_Update_Oppty (
        p_api_version_number  => l_api_version_number,
        p_init_msg_list       => p_init_msg_list,
        p_commit              => p_commit,
        p_validation_level    => p_validation_level,
        p_oppty_header_rec    => p_oppty_header_rec,
        p_salesforce_id       => p_salesforce_id,
        x_return_status       => x_return_status,
        x_msg_count           => x_msg_count,
        x_msg_data            => x_msg_data);

     if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
    raise FND_API.G_EXC_ERROR;
     end if;

exception
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

   WHEN no_data_found THEN
        fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
        fnd_message.Set_Token('TEXT',  'Current resource does not have a login user assigned. '||
                                     'Please use resource manager to assign a login user to this resource ');
        fnd_msg_pub.Add;

        x_return_status := FND_API.G_RET_STS_ERROR ;
        fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);

end Update_Opportunity_Pre;


procedure get_user_info
(  p_salesforce_id      IN  VARCHAR2,
   p_channel_code       IN  VARCHAR2,
   x_party_rel_id       OUT NOCOPY  NUMBER,
   x_relationship_type  OUT NOCOPY  VARCHAR2,
   x_user_name          OUT NOCOPY  VARCHAR2,
   x_party_name         OUT NOCOPY  VARCHAR2,
   x_party_type         OUT NOCOPY  VARCHAR2,
   x_return_status      OUT NOCOPY  VARCHAR2,
   x_msg_count          OUT NOCOPY  NUMBER,
   x_msg_data           OUT NOCOPY  VARCHAR2
)
IS
    l_api_name            CONSTANT  VARCHAR2(30) := 'get_user_info';
    l_api_version_number  CONSTANT  NUMBER       := 1.0;

    l_relationship_type   VARCHAR2(20);
    l_party_id            NUMBER;
    l_party_relation_id   NUMBER;
    l_username            fnd_user.user_name%type;
    l_party_name     VARCHAR2(1000);
    l_resource_category   VARCHAR2(30);

    l_channel_flag        VARCHAR2(1);

    l_partner_type     VARCHAR2(100);
    l_attr_value     VARCHAR2(100);


   cursor lc_chk_channel_code (pc_code    varchar2) is
        --select a.meaning, nvl(b.indirect_channel_flag, 'N')
        select nvl(b.indirect_channel_flag, 'N')
        from   oe_lookups a, pv_channel_types b
        where  a.lookup_type  = 'SALES_CHANNEL'
        and    a.lookup_code  = pc_code
        and    a.lookup_type  = b.channel_lookup_type (+)
        and    a.lookup_code  = b.channel_lookup_code (+);

   CURSOR lc_get_rel_type(pc_party_id number) is
   SELECT    'PARTNER_OF', PVPP.partner_id, PARTNER.party_name, peav.attr_value
   FROM
      hz_parties PARTNER,
      hz_relationships CONTACT,
      pv_partner_profiles PVPP,
      pv_enty_attr_values peav
   WHERE CONTACT.party_id = pc_party_id
   AND   CONTACT.subject_table_name = 'HZ_PARTIES'
   AND   CONTACT.object_table_name  = 'HZ_PARTIES'
   AND   CONTACT.RELATIONSHIP_TYPE  = 'EMPLOYMENT'
   AND   CONTACT.RELATIONSHIP_CODE  = 'EMPLOYEE_OF'
   AND   CONTACT.directional_flag   = 'F'
   AND   CONTACT.STATUS       =  'A'
   AND   CONTACT.start_date <= SYSDATE
   AND   nvl(CONTACT.end_date, SYSDATE) >= SYSDATE
   AND   PVPP.partner_party_id   =  CONTACT.object_id
   AND   PARTNER.party_id = PVPP.partner_party_id
   AND   PARTNER.PARTY_TYPE   = 'ORGANIZATION'
   AND   PARTNER.status = 'A'
   AND   peav.entity_id(+) = PVPP.partner_id
   AND   peav.entity(+) = 'PARTNER'
   AND   peav.attribute_id(+) = 3;

begin

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      debug('In '||l_api_name);
   END IF;

   --  Initialize API return status to success
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Get the Party id of the relation from based on the resource id
   SELECT  js.source_id, fu.user_name, js.category
   INTO    l_party_id, x_user_name, l_resource_category
   FROM    fnd_user fu, jtf_rs_resource_extns js
   WHERE   fu.user_id = js.user_id
   AND     js.resource_id = p_salesforce_id;

   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      debug('Person Party ID '|| l_party_id);
      debug('Person User name'|| x_user_name);
   END IF;

   IF l_resource_category = 'PARTY' then

      OPEN    lc_get_rel_type (pc_party_id => l_party_id);
      LOOP
         FETCH   lc_get_rel_type
         INTO    l_relationship_type, l_party_relation_id, l_party_name, l_attr_value;
         EXIT WHEN lc_get_rel_type%notfound;
         IF l_attr_value = 'VAD' THEN
       exit;
         END IF;

      END LOOP;

   end if;

   IF  l_relationship_type is not null THEN

      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
    Debug('Relationship Type '|| l_relationship_type);
      END IF;

      x_relationship_type := l_relationship_type;
      x_party_rel_id      := l_party_relation_id;
      x_party_name        := l_party_name;

      IF l_relationship_type = 'PARTNER_OF' THEN

    IF l_attr_value = 'VAD' THEN
       x_party_type := 'VAD' ;
    ELSE
       x_party_type := 'PARTNER';
    END IF;

      END IF;

   END IF;
   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
      Debug('Partner Type '|| x_party_type);
   END IF;

   if (x_party_type = 'PARTNER' or x_party_type = 'VAD')    THEN
      --  Validate if the Channel code is INDIRECT. If so, throw an exception.

      open     lc_chk_channel_code(pc_code => p_channel_code);
      fetch    lc_chk_channel_code into l_channel_flag;
      close    lc_chk_channel_code;

      if (l_channel_flag = null or l_channel_flag = 'N') then
    fnd_message.SET_NAME('PV', 'PV_INVALID_CHANNEL_CODE');
    fnd_msg_pub.ADD;
    raise FND_API.G_EXC_ERROR;
      end if;

   end if;

exception
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

   WHEN no_data_found THEN
        fnd_message.Set_Name('PV', 'PV_DEBUG_MESSAGE');
        fnd_message.Set_Token('TEXT',  'Current resource does not have a login user assigned. '||
                                     'Please use resource manager to assign a login user to this resource ');
        fnd_msg_pub.Add;

        x_return_status := FND_API.G_RET_STS_ERROR ;
        fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);



   WHEN OTHERS THEN

      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME, l_api_name);
      fnd_msg_pub.Count_And_Get( p_encoded   =>  FND_API.G_TRUE,
                                 p_count     =>  x_msg_count,
                                 p_data      =>  x_msg_data);
end get_user_info;

PROCEDURE Debug(
   p_msg_string         IN VARCHAR2
)
IS

BEGIN
   FND_MESSAGE.Set_Name('PV', 'PV_DEBUG_MESSAGE');
   FND_MESSAGE.Set_Token('TEXT', p_msg_string);
   FND_MSG_PUB.Add;

END Debug;


END PV_OPPORTUNITY_VHUK;

/
