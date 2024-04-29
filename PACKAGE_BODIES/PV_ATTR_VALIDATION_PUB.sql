--------------------------------------------------------
--  DDL for Package Body PV_ATTR_VALIDATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_ATTR_VALIDATION_PUB" as
/* $Header: pvvatvtb.pls 120.2 2006/03/28 11:52:41 amaram noship $*/

-- --------------------------------------------------------------
-- Used for inserting output messages to the message table.
-- --------------------------------------------------------------
PROCEDURE Debug(
   p_msg_string    IN VARCHAR2
);


PROCEDURE attribute_validate(
   p_api_version_number         IN  NUMBER,
   p_init_msg_list              IN  VARCHAR2  := FND_API.g_false,
   p_commit                     IN  VARCHAR2  := FND_API.g_false,
   p_validation_level           IN  NUMBER    := FND_API.g_valid_level_full,
   p_attribute_id               IN  NUMBER,
   p_entity			IN  VARCHAR2,
   p_entity_id			IN  VARCHAR2,
   p_user_id			IN  VARCHAR2,
   x_return_status              OUT NOCOPY VARCHAR2,
   x_msg_count                  OUT NOCOPY NUMBER,
   x_msg_data                   OUT NOCOPY VARCHAR2
)
IS
 l_api_name             CONSTANT VARCHAR2(30) := 'Attribute_Validate';
 l_api_version_number   CONSTANT NUMBER       := 1.0;

 l_category             VARCHAR2(100);

 l_rs_details_tbl	PV_ASSIGN_UTIL_PVT.resource_details_tbl_type := PV_ASSIGN_UTIL_PVT.resource_details_tbl_type();
 l_username_tbl		JTF_VARCHAR2_TABLE_1000 := JTF_VARCHAR2_TABLE_1000();

 l_partner_name		VARCHAR2(1000);
 l_partner_contact_name VARCHAR2(1000);
 l_pt_contact_id	VARCHAR2(1000);
 l_attribute_name	VARCHAR2(500);
 l_email_enabled        VARCHAR2(5);
 l_vad_id		NUMBER;



 cursor lc_get_pt_details (pc_partner_id number) is
   select pt.party_name party_name
   from   hz_relationships    pr,
          hz_organization_profiles op,
          hz_parties          pt
   where pr.party_id            = pc_partner_id
   and   pr.subject_table_name  = 'HZ_PARTIES'
   and   pr.object_table_name   = 'HZ_PARTIES'
   and   pr.status             in ('A', 'I')
   and   pr.object_id           = op.party_id
   and   op.internal_flag       = 'Y'
   and   op.effective_end_date is null
   and   pr.subject_id          = pt.party_id
   and   pt.status             in ('A', 'I');


 cursor lc_get_usr_dtails ( pc_user_id NUMBER )
 is
   select category, source_id
   from   jtf_rs_resource_extns extn, fnd_user usr
   where  extn.user_id     = usr.user_id
   and    usr.user_id	   = pc_user_id;


 cursor lc_get_pt_contact (pc_pt_contact_id NUMBER)
 is
   select d.party_name
   from hz_relationships b,
        hz_relationships c,
        hz_organization_profiles po,
	hz_parties d
   where b.party_id = pc_pt_contact_id
   and   b.subject_table_name   = 'HZ_PARTIES'
   and   b.object_table_name    = 'HZ_PARTIES'
   and   b.directional_flag     = 'F'
   and   b.relationship_code    = 'EMPLOYEE_OF'
   and   b.relationship_type    = 'EMPLOYMENT'
   and   (b.end_date is null   or b.end_date > sysdate)
   and   b.status               =  'A'
   and   b.object_id            = c.subject_id
   and   c.subject_table_name   = 'HZ_PARTIES'
   and   c.object_table_name    = 'HZ_PARTIES'
   and   (c.end_date is null or c.end_date > sysdate)
   and   c.status               = 'A'
   and   c.object_id            = po.party_id
   and   d.party_id             = b.subject_id
   and   po.internal_flag       = 'Y'
   and   po.effective_end_date  is null;




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
       dEBUG('In ' || l_api_name );

    END IF;


    IF p_entity = g_partner_entity THEN

       -- Getting partner contact details


       IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
          DEBUG('User id ' || p_user_id );
       END IF;


       FOR lc_user IN lc_get_usr_dtails(p_user_id )
       LOOP

	 l_category		:= lc_user.category;
	 l_pt_contact_id	:= lc_user.source_id;

	 IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
	    DEBUG('Category ' || lc_user.category );
  	    DEBUG('Source ' || lc_user.source_id );

	 END IF;


       END LOOP;


       IF l_category is null AND l_pt_contact_id is null  THEN

          fnd_message.SET_NAME('PV', 'PV_DEBUG_MESSAGE');
          fnd_message.SET_TOKEN('TEXT' , 'No User exists for this resource id ');
          fnd_msg_pub.ADD;

          raise FND_API.G_EXC_ERROR;


       -- If user is VENDOR then email notification will not sent out
       -- Email notification has to sent only when the partner makes the
       -- changes to the attribute

       ELSIF l_category = 'EMPLOYEE' THEN
          return;

       ELSIF l_category = 'PARTY' THEN


       -- Getting CM information

           pv_assign_util_pvt.get_partner_info
	   (
	     p_api_version_number  => p_api_version_number,
	     p_init_msg_list       => p_init_msg_list,
	     p_commit              => p_commit,
	     p_validation_level    => p_validation_level,
             p_mode                => 'EXTERNAL',
	     p_partner_id          => p_entity_id,
	     p_entity              => p_entity,
	     p_entity_id           => NULL,
	     p_retrieve_mode       => 'CM',
	     x_rs_details_tbl      => l_rs_details_tbl,
	     x_vad_id              => l_vad_id,
	     x_return_status       => x_return_status,
	     x_msg_count	   => x_msg_count,
	     x_msg_data		   => x_msg_data
	   );

	   if x_return_status <>  FND_API.G_RET_STS_SUCCESS then
             raise FND_API.G_EXC_ERROR;
           end if;

           IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
  	      Debug('Size of l_rs_details_tbl: ' || l_rs_details_tbl.count);
           END IF;

           FOR lc_cursor IN lc_get_pt_details(p_entity_id)
	   LOOP

	          l_partner_name := lc_cursor.party_name;

		   IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
		      Debug('Partner Name: ' || l_partner_name);
		   END IF;


           END LOOP;


	   if l_rs_details_tbl.count = 0 then

              fnd_message.SET_NAME('PV', 'PV_NO_CM_DECISION_MAKER');
              fnd_message.SET_TOKEN('P_PARTNER_NAME' , l_partner_name);
              fnd_msg_pub.ADD;

              raise FND_API.G_EXC_ERROR;

           else

	      l_username_tbl.extend(l_rs_details_tbl.count);

              for i in 1 .. l_rs_details_tbl.count
	      loop

	         l_username_tbl(i)  := l_rs_details_tbl(i).user_name;

		 IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
		      Debug('User Name: ' ||  l_username_tbl(i));
		 END IF;


	      end loop;

           end if;



           FOR  lc_pt_contact IN lc_get_pt_contact(l_pt_contact_id)
	   LOOP

	      l_partner_contact_name := lc_pt_contact.party_name;
  	      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
		 Debug('Partner Contact Name: ' ||  l_partner_contact_name);
	      END IF;


           END LOOP;

	   FOR lc_cur IN (select name from pv_attributes_vl where attribute_id = p_attribute_id)
	   LOOP

	      l_attribute_name := lc_cur.name;

  	      IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
		 Debug('Attribute Name: ' ||  l_attribute_name);
	      END IF;


           END LOOP;


	   StartWorkflow
	   (
	     p_api_version_number  => p_api_version_number,
	     p_init_msg_list       => p_init_msg_list,
	     p_commit              => p_commit,
	     p_validation_level    => p_validation_level,
	     p_user_name_tbl	   => l_username_tbl,
	     p_attribute_id	   => p_attribute_id,
	     p_attribute_name	   => l_attribute_name,
	     p_partner_name	   => l_partner_name,
	     p_pt_contact_name     => l_partner_contact_name,
	     x_return_status       => x_return_status,
	     x_msg_count           => x_msg_count,
	     x_msg_data            => x_msg_data
	 );


	  IF x_return_status <>  FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;

          IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
             Debug( 'Email is sent out successfully');
          END IF;

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
END;


procedure StartWorkflow
(
   p_api_version_number  IN  NUMBER,
   p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit              IN  VARCHAR2 := FND_API.G_FALSE,
   p_validation_level    IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   p_user_name_tbl	 IN  JTF_VARCHAR2_TABLE_1000,
   p_attribute_id	 IN  VARCHAR2,
   p_attribute_name	 IN  VARCHAR2,
   p_partner_name	 IN  VARCHAR2,
   p_pt_contact_name     IN  VARCHAR2,
   x_return_status       OUT NOCOPY  VARCHAR2,
   x_msg_count           OUT NOCOPY  NUMBER,
   x_msg_data            OUT NOCOPY  VARCHAR2
 )
 is
 l_api_name             CONSTANT VARCHAR2(30) := 'StartWorkflow';
 l_api_version_number   CONSTANT NUMBER       := 1.0;

 l_send_respond_url     VARCHAR2(500);
 l_email_enabled        VARCHAR2(5);
 l_itemKey	        VARCHAR2(100);
 l_itemType             VARCHAR2(10) := g_wf_itemtype_notify;
 l_role_list	        wf_directory.usertable;
 l_adhoc_role		VARCHAR2(1000);


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
       dEBUG('In ' || l_api_name );

    END IF;

    x_return_status := FND_API.G_RET_STS_SUCCESS ;

    -- check the profile value and return if the value is not Y

    l_email_enabled := nvl(fnd_profile.value('PV_EMAIL_NOTIFICATION_FLAG'), 'Y');

    if (l_email_enabled <> 'Y') then
        return;
    end if;

    debug('Email Enabled '|| l_email_enabled);

    SELECT  PV_LEAD_WORKFLOWS_S.nextval
    INTO    l_itemKey
    FROM    dual;

    FOR i in 1 .. p_user_name_tbl.count
    LOOP

        IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
           dEBUG( 'In Loop of p_user_name_tbl ');
        END IF;

           l_role_list(i) := p_user_name_tbl(i);

    END LOOP;

    IF l_role_list.count > 0  then
       l_adhoc_role := 'PV_' || l_itemKey || '_' || '0';

        -- Debug Message

       IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
 	  Debug('Creating role : '|| l_adhoc_role || ' with members:--'  );
       END IF;

       FOR i in 1 .. l_role_list.count
       LOOP



           IF fnd_msg_pub.Check_Msg_Level (fnd_msg_pub.G_MSG_LVL_DEBUG_LOW) THEN
           dEBUG( l_role_list(i) );
           END IF;

        END LOOP;


            wf_directory.CreateAdHocRole2(role_name         => l_adhoc_role,
                                         role_display_name => l_adhoc_role,
                                         role_users        => l_role_list);


    END IF;


    IF  l_role_list.count < 1
    THEN
       return;

    ELSE



    -- Once the parameters for workflow is validated, start the workflow
     wf_engine.CreateProcess (ItemType => l_itemType,
                              ItemKey  => l_itemKey,
                              process  => g_wf_pcs_notify_cm);

     wf_engine.SetItemUserKey (ItemType => l_itemType,
                               ItemKey  => l_itemKey,
                               userKey  => l_itemkey);

     wf_engine.SetItemAttrText (ItemType => l_itemType,
                                ItemKey  => l_itemKey,
                                aname    => g_wf_attr_cm_notify_role,
                                avalue   => l_adhoc_role);

     wf_engine.SetItemAttrText (ItemType => l_itemType,
                                ItemKey  => l_itemKey,
                                aname    => g_wf_attr_attribute_name,
                                avalue   => p_attribute_name);


     wf_engine.SetItemAttrText (ItemType => l_itemType,
                                ItemKey  => l_itemKey,
                                aname    => g_wf_attr_partner_name,
                                avalue   => p_partner_name);

     wf_engine.SetItemAttrText (ItemType => l_itemType,
                                ItemKey  => l_itemKey,
                                aname    => g_wf_attr_prtnr_cont_name,
                                avalue   => p_pt_contact_name);

     l_send_respond_url  := fnd_profile.value('PV_WORKFLOW_RESPOND_SELF_SERVICE_URL');

     wf_engine.SetItemAttrText ( ItemType => l_itemType,
                                 ItemKey  => l_itemKey,
                                 aname    => g_wf_attr_send_url,
                                 avalue   => l_send_respond_url);


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
end StartWorkflow;


PROCEDURE Debug(
   p_msg_string    IN VARCHAR2
)
IS

BEGIN
    FND_MESSAGE.Set_Name('PV', 'PV_DEBUG_MESSAGE');
    FND_MESSAGE.Set_Token('TEXT', p_msg_string);
    FND_MSG_PUB.Add;
END Debug;

END PV_ATTR_VALIDATION_PUB;

/
