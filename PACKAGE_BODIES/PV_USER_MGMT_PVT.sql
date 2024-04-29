--------------------------------------------------------
--  DDL for Package Body PV_USER_MGMT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_USER_MGMT_PVT" as
/* $Header: pvxvummb.pls 120.18 2006/05/24 22:07:06 dgottlie ship $ */

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'PV_USER_MGMT_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvummb.pls';

PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);


PROCEDURE create_user_resource
 (
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_partner_user_rec           IN   partner_user_rec_type
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
 )
 IS
    l_api_version_number        CONSTANT  NUMBER       := 1.0;
   l_api_name                  CONSTANT  VARCHAR2(30) := 'create_user_resource';
   l_full_name                 CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_person_rel_party_id  NUMBER;
   l_resource_id      NUMBER;
   l_resource_number  VARCHAR2(30);
   l_partner_id       NUMBER;
   l_partner_group_id NUMBER;
   l_person_first_name VARCHAR2(150);
   l_person_last_name  VARCHAR2(150);
   l_org_party_name  VARCHAR2(360);
   l_org_contact_id  NUMBER;
   l_role_relate_id  NUMBER;
   l_group_member_id NUMBER;
   l_profile_saved boolean;
   l_user_id NUMBER;
   l_object_version_number NUMBER;

   l_resource_exists boolean := false;
   l_role_exists boolean := false;
   l_group_assigned boolean := false;
   l_group_role_assigned boolean := false;

   resourceRec PVX_Misc_PVT.admin_rec_type;


   cursor c_get_user_details(cv_person_rel_party_id NUMBER) IS
   select pvpp.partner_id, pvpp.PARTNER_GROUP_ID , person_hzp.PERSON_FIRST_NAME, person_hzp.person_last_name, hzoc.org_contact_id, org_hzp.party_name
   from HZ_PARTIES PERSON_HZP, HZ_RELATIONSHIPS HZR, PV_PARTNER_PROFILES pvpp, hz_org_contacts hzoc, HZ_PARTIES ORG_HZP
   where HZR.party_id = cv_person_rel_party_id
   and HZR.directional_flag = 'F'
   and hzr.relationship_code = 'EMPLOYEE_OF'
   and HZR.subject_table_name ='HZ_PARTIES'
   and HZR.object_table_name ='HZ_PARTIES'
   and hzr.start_date <= SYSDATE
   and (hzr.end_date is null or hzr.end_date > SYSDATE)
   and hzr.status = 'A'
   and hzr.subject_id = person_hzp.party_id
   and person_hzp.status = 'A'
   and hzr.object_id = pvpp.partner_party_id
   and pvpp.status = 'A'
   and pvpp.partner_group_id is not null
   and hzoc.PARTY_RELATIONSHIP_ID = hzr.relationship_id
   and hzr.object_id = org_hzp.party_id;



   cursor c_get_resource_id (cv_person_rel_party_id NUMBER)is
   select resource_id, resource_number, user_id, object_version_number
   from jtf_rs_resource_extns
   where source_id = cv_person_rel_party_id
   and category='PARTY'
   and start_date_active <= sysdate
   and (end_date_active is null or end_date_active >= sysdate);


   cursor c_get_role_relate_id(cv_resource_id NUMBER) is
   select role_relate_id
   from jtf_rs_role_relations rr, jtf_rs_roles_b rrb
   where role_resource_id = cv_resource_id
   and role_resource_type = 'RS_INDIVIDUAL'
   and rr.start_date_active <= sysdate
   and (rr.end_date_active is null or rr.end_date_active >=sysdate)
   and rrb.role_id = rr.role_id
   and rrb.role_code= 'PARTNER_CONTACT_MEMBER'
   and (rr.delete_flag is null or rr.delete_flag='N')
   and (rr.active_flag is null or rr.active_flag = 'Y')
   and  (rrb.active_flag = 'Y');

   cursor c_get_group_member_id (cv_resource_id NUMBER, cv_partner_group_id NUMBER) is
   select group_member_id
   from jtf_rs_group_members
   where group_id = cv_partner_group_id
   and resource_id = cv_resource_id
   and (delete_flag is null or delete_flag = 'N');

   cursor c_get_group_role_assigned  (cv_group_member_id NUMBER) is
   select role_relate_id
   from jtf_rs_role_relations rr, jtf_rs_roles_b rrb
   where role_resource_id = cv_group_member_id
   and role_resource_type = 'RS_GROUP_MEMBER'
   and rr.start_date_active <= sysdate
   and (rr.end_date_active is null or rr.end_date_active >=sysdate)
   and rrb.role_id = rr.role_id
   and rrb.role_code= 'PARTNER_CONTACT_MEMBER'
   and (rr.delete_flag is null or rr.delete_flag='N')
   and (rr.active_flag is null or rr.active_flag = 'Y')
   and  (rrb.active_flag = 'Y');

   BEGIN

     ---------------Initialize --------------------
      -- Standard Start of API savepoint
      SAVEPOINT create_user_resource;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
            l_api_version_number
           ,p_api_version_number
           ,l_api_name
           ,G_PKG_NAME
           )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
       PVX_UTILITY_PVT.debug_message('API: ' || l_api_name || ' - start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
  -------------End Of Initialize -------------------------------


     IF (p_partner_user_rec.person_rel_party_id IS NULL or p_partner_user_rec.person_rel_party_id = FND_API.G_MISS_NUM) THEN
      fnd_message.SET_NAME  ('PV', 'PV_MISSING_PERSON_REL_ID');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
     END IF;

     open c_get_user_details(p_partner_user_rec.person_rel_party_id);
     fetch c_get_user_details into l_partner_id, l_partner_group_id, l_person_first_name, l_person_last_name,l_org_contact_id, l_org_party_name;
     if (c_get_user_details%NOTFOUND) THEN
      fnd_message.SET_NAME  ('PV', 'PV_INVALID_PARTNER');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
     END IF;
     close c_get_user_details;

     l_person_rel_party_id := p_partner_user_rec.person_rel_party_id;
     IF (PV_DEBUG_HIGH_ON) THEN
	PVX_UTILITY_PVT.debug_message('API: ' || l_api_name || ' - l_person_rel_party_id =' || to_char(l_person_rel_party_id));
     END IF;


     --get resource id into l_resource_id  number
     open c_get_resource_id( l_person_rel_party_id);
	fetch c_get_resource_id into  l_resource_id, l_resource_number, l_user_id, l_object_version_number;
	if (c_get_resource_id%FOUND) then
		l_resource_exists := true;
		IF (PV_DEBUG_HIGH_ON) THEN
			PVX_UTILITY_PVT.debug_message('API: ' || l_api_name || ' - l_resource_exists := true');
		END IF;

	end if;
     close c_get_resource_id;


     if (l_resource_exists = true) then
        jtf_rs_resource_pub.update_resource (
	P_API_VERSION             => p_api_version_number,
	P_INIT_MSG_LIST           => fnd_api.g_false,
	P_COMMIT                  => fnd_api.g_false,
	P_RESOURCE_ID             => l_resource_id,
	P_RESOURCE_NUMBER         => l_resource_number,
	P_USER_ID                 => p_partner_user_rec.user_ID,
	P_SOURCE_NAME             => FND_API.G_MISS_CHAR,
	P_OBJECT_VERSION_NUM      => l_object_version_number,
	P_USER_NAME		  => p_partner_user_rec.user_name,
	X_RETURN_STATUS           => x_return_status,
	X_MSG_COUNT               => x_msg_count,
	X_MSG_DATA                => x_msg_data
	);
     end if;



     if (l_resource_exists = false) then
     IF (PV_DEBUG_HIGH_ON) THEN
	PVX_UTILITY_PVT.debug_message('API: ' || l_api_name || ' - l_resource_exists := false');
     END IF;
     resourceRec.source_last_name        := l_person_last_name;
     resourceRec.source_first_name       := l_person_first_name;
     resourceRec.user_name               := upper(p_partner_user_rec.user_Name);
     resourceRec.user_id                 := p_partner_user_rec.user_ID;
     resourceRec.resource_type           := 'PARTY';
     resourceRec.partner_id              := p_partner_user_rec.person_rel_party_id;
     resourceRec.contact_id              := l_org_contact_id;
     resourceRec.source_name             := l_person_first_name || ' ' || l_person_last_name;
     resourceRec.resource_name           := resourceRec.source_name;
     resourceRec.source_org_id           := l_partner_id;
     resourceRec.source_org_name         := l_org_party_name;
     --PVX_UTILITY_PVT.debug_message('admin resource');
     PVX_Misc_PVT.Admin_Resource
     (
       p_api_version       =>  p_api_version_number
      ,p_init_msg_list     =>  FND_API.g_false
      ,p_commit            =>  FND_API.g_false
      ,x_return_status     =>  x_return_status
      ,x_msg_count         =>  x_msg_count
      ,x_msg_data          =>  x_msg_data
      ,p_admin_rec         =>  resourceRec
      ,p_mode              =>  'CREATE'
      ,x_resource_id       =>  l_resource_id
      ,x_resource_number   =>  l_resource_number
     );

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    end if;

    if (l_resource_exists = true) then
    -- fetch role into l_role_relate_id
    open c_get_role_relate_id(l_resource_id);
	fetch c_get_role_relate_id into l_role_relate_id;
	if (c_get_role_relate_id%FOUND) then
		l_role_exists := true;
		IF (PV_DEBUG_HIGH_ON) THEN
			PVX_UTILITY_PVT.debug_message('API: ' || l_api_name || ' - l_role_exists := true');
		END IF;
	end if;
    close c_get_role_relate_id;
    end if;



    if (l_role_exists = false) then
    IF (PV_DEBUG_HIGH_ON) THEN
	PVX_UTILITY_PVT.debug_message('API: ' || l_api_name || ' - l_role_exists := false');
    END IF;
    resourceRec.role_resource_id   := l_resource_id;
    resourceRec.role_resource_type := 'RS_INDIVIDUAL';
    resourceRec.role_code          := 'PARTNER_CONTACT_MEMBER';
    --PVX_UTILITY_PVT.debug_message('admin role for individual');
    PVX_Misc_PVT.Admin_Role
    (
     p_api_version       =>  p_api_version_number
    ,p_init_msg_list     =>  FND_API.g_false
    ,p_commit            =>  FND_API.g_false
    ,x_return_status     =>  x_return_status
    ,x_msg_count         =>  x_msg_count
    ,x_msg_data          =>  x_msg_data
    ,p_admin_rec         =>  resourceRec
    ,p_mode              =>  'CREATE'
    ,x_role_relate_id    =>  l_role_relate_id
    );

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    end if;


    if (l_resource_exists = true) then
    -- fetch check group into l_group_member_id
    open c_get_group_member_id(l_resource_id, l_partner_group_id);
	fetch c_get_group_member_id into l_group_member_id;
	if (c_get_group_member_id%FOUND) then
		l_group_assigned := true;
		IF (PV_DEBUG_HIGH_ON) THEN
			PVX_UTILITY_PVT.debug_message('API: ' || l_api_name || ' - l_group_assigned := true');
		END IF;
	end if;
    close c_get_group_member_id;
    end if;



    if (l_group_assigned = false) then
     IF (PV_DEBUG_HIGH_ON) THEN
	PVX_UTILITY_PVT.debug_message('API: ' || l_api_name || ' - l_group_assigned := false');
     END IF;
    resourceRec.role_resource_id  :=  l_resource_id;
    resourceRec.resource_number   :=  l_resource_number;
    resourceRec.group_id          :=  l_partner_group_id;

    --PVX_UTILITY_PVT.debug_message('admin group member');
    PVX_Misc_PVT.Admin_Group_Member
    (
     p_api_version       =>  p_api_version_number
    ,p_init_msg_list     =>  FND_API.g_false
    ,p_commit            =>  FND_API.g_false
    ,x_return_status     =>  x_return_status
    ,x_msg_count         =>  x_msg_count
    ,x_msg_data          =>  x_msg_data
    ,p_admin_rec         =>  resourceRec
    ,p_mode              =>  'CREATE'
    ,x_group_member_id   =>  l_group_member_id
    );

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    end if;

    --PVX_UTILITY_PVT.debug_message('l_group_member_id =' || to_char(l_group_member_id));


    if (l_resource_exists = true and l_group_assigned = true) then
    open c_get_group_role_assigned (l_group_member_id) ;
	fetch c_get_group_role_assigned into l_role_relate_id;
	if (c_get_group_role_assigned%FOUND) then
		l_group_role_assigned := true;
		IF (PV_DEBUG_HIGH_ON) THEN
			PVX_UTILITY_PVT.debug_message('API: ' || l_api_name || ' - l_group_role_assigned := true');
		END IF;
	end if;
    close c_get_group_role_assigned;
    end if;



    if (l_group_role_assigned = false) then
    IF (PV_DEBUG_HIGH_ON) THEN
	PVX_UTILITY_PVT.debug_message('API: ' || l_api_name || ' - l_group_role_assigned := false');
    END IF;
    resourceRec.role_resource_id   := l_group_member_id;
    resourceRec.role_resource_type := 'RS_GROUP_MEMBER';
    resourceRec.role_code          := 'PARTNER_CONTACT_MEMBER';

    --PVX_UTILITY_PVT.debug_message('admin role for group');
    PVX_Misc_PVT.Admin_Role
    (
     p_api_version       =>  p_api_version_number
    ,p_init_msg_list     =>  FND_API.g_false
    ,p_commit            =>  FND_API.g_false
    ,x_return_status     =>  x_return_status
    ,x_msg_count         =>  x_msg_count
    ,x_msg_data          =>  x_msg_data
    ,p_admin_rec         =>  resourceRec
    ,p_mode              =>  'CREATE'
    ,x_role_relate_id    =>  l_role_relate_id
    );

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;
    end if;
     l_profile_saved  := fnd_profile.save
                       (X_NAME        => 'ASF_DEFAULT_GROUP_ROLE',
		        X_VALUE       =>  l_partner_group_id||'(Member)',
		        X_LEVEL_NAME  => 'USER',
		        X_LEVEL_VALUE =>  p_partner_user_rec.user_ID);

    If (not l_profile_saved) THEN
      fnd_message.SET_NAME  ('PV', 'PV_PROFILE_NOT_EXISTS');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
    END IF;



    FND_MSG_PUB.Count_And_Get
    ( p_encoded => FND_API.G_FALSE,
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
    );

    IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

   EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO create_user_resource;
          x_return_status := FND_API.G_RET_STS_ERROR;
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );


       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO create_user_resource;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         -- Standard call to get message count and if count=1, get the message
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

       WHEN OTHERS THEN
         ROLLBACK TO create_user_resource;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
	 FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
          );

 END create_user_resource;

PROCEDURE register_partner_and_user
(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_partner_rec                IN   Partner_Rec_type
    ,P_partner_type               IN   VARCHAR2
    ,p_partner_user_rec           IN  partner_user_rec_type
    ,x_return_status              OUT NOCOPY  VARCHAR2
    ,x_msg_count                  OUT NOCOPY  NUMBER
    ,x_msg_data                   OUT NOCOPY  VARCHAR2
 )
 IS

   l_api_version_number        CONSTANT  NUMBER       := 1.0;
   l_api_name                  CONSTANT  VARCHAR2(30) := 'Register_Partner_And_User';
   l_full_name                 CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   l_partner_id NUMBER;
   l_default_resp_id NUMBER;
   l_resp_map_rule_id NUMBER;
   l_partner_group_id NUMBER;
   l_global_partner_id NUMBER := null;

   l_partner_types_tbl PV_ENTY_ATTR_VALUE_PUB.attr_value_tbl_type;

    cursor get_user_role(l_user_type_id NUMBER) IS
    select  jtfperm.permission_name
    from jtf_auth_principals_b jtfp1, jtf_auth_role_perms jtfrp, jtf_auth_permissions_b jtfperm
    where jtfp1.is_user_flag = 0
    and  jtfp1.jtf_auth_principal_id = jtfrp.jtf_auth_principal_id
    and  jtfrp.positive_flag = 1
    and jtfrp.jtf_auth_permission_id = jtfperm.jtf_auth_permission_id
    and jtfperm.permission_name  in (G_PARTNER_PERMISSION, G_PRIMARY_PERMISSION)
    and jtfp1.principal_name IN
       (select principal_name
        from  jtf_um_usertype_role jtur
        where  jtur.usertype_id = l_user_type_id
        and  (jtur.effective_end_date is null or jtur.effective_end_date > sysdate)
        union all
        select jtsr.principal_name
        from jtf_um_usertype_subscrip jtus, jtf_um_subscription_role jtsr
        where  jtus.usertype_id = l_user_type_id
        and (jtus.effective_end_date is null or jtus.effective_end_date > sysdate)
	and jtus.subscription_flag = 'IMPLICIT'
        and jtus.subscription_id = jtsr.subscription_id
        and (jtsr.effective_end_date is null or jtsr.effective_end_date > sysdate)
       )
    group by jtfperm.permission_name;

    is_partner_user boolean := false;
    is_primary_user boolean := false;
    l_role varchar2(10);

   BEGIN

     ---------------Initialize --------------------
      -- Standard Start of API savepoint
      SAVEPOINT Register_Partner_And_User;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
            l_api_version_number
           ,p_api_version_number
           ,l_api_name
           ,G_PKG_NAME
           )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
       PVX_UTILITY_PVT.debug_message('API: ' || l_api_name || ' - start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
  -------------End Of Initialize -------------------------------

     IF FND_GLOBAL.User_Id IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_USER_PROFILE_MISSING');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;


     IF P_partner_type IS NULL THEN
      fnd_message.SET_NAME  ('PV', 'PV_MISSING_PRTNR_TYPE');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
     END IF;

     IF (p_partner_rec.partner_party_id IS NULL or p_partner_rec.partner_party_id = FND_API.G_MISS_NUM) THEN
      fnd_message.SET_NAME  ('PV', 'PV_MISSING_ORGZN_ID');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
     END IF;

     IF (p_partner_rec.member_type IS NULL or p_partner_rec.member_type = FND_API.G_MISS_CHAR) THEN
      fnd_message.SET_NAME  ('PV', 'PV_MISSING_MEMBER_TYPE');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
     END IF;

     IF (p_partner_user_rec.user_id IS NULL or p_partner_user_rec.user_id  = FND_API.G_MISS_NUM) THEN
      fnd_message.SET_NAME  ('PV', 'PV_MISSING_USER_ID');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
     END IF;


     if(p_partner_rec.member_type = 'SUBSIDIARY') THEN
      IF(p_partner_rec.global_prtnr_org_number IS NULL OR p_partner_rec.global_prtnr_org_number = FND_API.G_MISS_CHAR) THEN
        fnd_message.SET_NAME  ('PV', 'PV_MISSING_GLOBAL_ID');
        fnd_msg_pub.ADD;
        raise FND_API.G_EXC_ERROR;
       ELSE
         l_global_partner_id := Pv_ptr_member_type_pvt.get_global_partner_id(p_global_prtnr_org_number => p_partner_rec.global_prtnr_org_number);
       END IF;
     END IF;

     IF (p_partner_user_rec.user_type_id IS NULL or p_partner_user_rec.user_type_id  = FND_API.G_MISS_NUM) THEN
      fnd_message.SET_NAME  ('PV', 'PV_MISSING_USERTYPE_ID');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
     END IF;


     FOR X in get_user_role(p_partner_user_rec.user_type_id) LOOP
      IF (X.permission_Name = G_PARTNER_PERMISSION) THEN
       is_partner_user := true;
      ELSIF (X.permission_name = G_PRIMARY_PERMISSION) THEN
       is_primary_user := true;
      END IF;
     END LOOP;

     IF((not is_partner_user) or (not is_primary_user)) THEN
      fnd_message.SET_NAME  ('PV', 'PV_NOT_PRTNR_PRIMARY_USER');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
     END IF;

     l_partner_types_tbl(1).attr_value := P_partner_type;
     l_partner_types_tbl(1).attr_value_extn := 'Y' ;

     pv_partner_util_pvt.Create_Relationship
     (
       p_api_version_number => p_api_version_number
      ,p_init_msg_list      => FND_API.g_false
      ,p_commit             =>  FND_API.G_FALSE
      ,p_validation_level   =>  FND_API.G_VALID_LEVEL_FULL
      ,x_return_status      => x_return_status
      ,x_msg_data           => x_msg_data
      ,x_msg_count          => x_msg_count
      ,p_party_id           => p_partner_rec.partner_party_id
      ,p_partner_types_tbl  => l_partner_types_tbl
      ,p_vad_partner_id     => NULL
      ,p_member_type        => p_partner_rec.member_type
      ,p_global_partner_id  => l_global_partner_id
      ,x_partner_id         => l_partner_id
      ,x_default_resp_id    => l_default_resp_id
      ,x_resp_map_rule_id   => l_resp_map_rule_id
      ,x_group_id           => l_partner_group_id
    );

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;



    FND_MSG_PUB.Count_And_Get
    ( p_encoded => FND_API.G_FALSE,
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
    );

    IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

   EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO Register_Partner_And_User;
          x_return_status := FND_API.G_RET_STS_ERROR;
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );


       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO Register_Partner_And_User;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         -- Standard call to get message count and if count=1, get the message
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

       WHEN OTHERS THEN
         ROLLBACK TO Register_Partner_And_User;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
	 FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
          );

 END register_partner_and_user;


 PROCEDURE register_partner_user
(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_partner_user_rec           IN   partner_User_rec_type
    ,x_return_status              OUT  NOCOPY  VARCHAR2
    ,x_msg_count                  OUT  NOCOPY  NUMBER
    ,x_msg_data                   OUT  NOCOPY  VARCHAR2
 )
 IS

   l_api_version_number        CONSTANT  NUMBER       := 1.0;
   l_api_name                  CONSTANT  VARCHAR2(30) := 'register_partner_user';
   l_full_name                 CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   cursor get_user_role(l_user_type_id NUMBER) IS
       select  jtfperm.permission_name
    from jtf_auth_principals_b jtfp1, jtf_auth_role_perms jtfrp, jtf_auth_permissions_b jtfperm
    where jtfp1.is_user_flag = 0
    and  jtfp1.jtf_auth_principal_id = jtfrp.jtf_auth_principal_id
    and  jtfrp.positive_flag = 1
    and jtfrp.jtf_auth_permission_id = jtfperm.jtf_auth_permission_id
    and jtfperm.permission_name  in (G_PARTNER_PERMISSION, G_PRIMARY_PERMISSION)
    and jtfp1.principal_name IN
       (select principal_name
        from  jtf_um_usertype_role jtur
        where  jtur.usertype_id = l_user_type_id
        and  (jtur.effective_end_date is null or jtur.effective_end_date > sysdate)
        union all
        select jtsr.principal_name
        from jtf_um_usertype_subscrip jtus, jtf_um_subscription_role jtsr
        where  jtus.usertype_id = l_user_type_id
        and (jtus.effective_end_date is null or jtus.effective_end_date > sysdate)
	and jtus.subscription_flag = 'IMPLICIT'
        and jtus.subscription_id = jtsr.subscription_id
        and (jtsr.effective_end_date is null or jtsr.effective_end_date > sysdate)
       )
    group by jtfperm.permission_name;

    is_partner_user boolean := false;
    is_primary_user boolean := false;
    l_role varchar2(10);


   BEGIN

     ---------------Initialize --------------------
      -- Standard Start of API savepoint
      SAVEPOINT register_partner_user;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
            l_api_version_number
           ,p_api_version_number
           ,l_api_name
           ,G_PKG_NAME
           )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('API: ' || l_api_name || ' - start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
  -------------End Of Initialize -------------------------------


     IF FND_GLOBAL.User_Id IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_USER_PROFILE_MISSING');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF (p_partner_user_rec.user_id IS NULL or p_partner_user_rec.user_id  = FND_API.G_MISS_NUM) THEN
      fnd_message.SET_NAME  ('PV', 'PV_MISSING_USER_ID');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
     END IF;

     IF (p_partner_user_rec.user_type_id IS NULL or p_partner_user_rec.user_type_id  = FND_API.G_MISS_NUM) THEN
      fnd_message.SET_NAME  ('PV', 'PV_MISSING_USERTYPE_ID');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
     END IF;


     FOR X in get_user_role(p_partner_user_rec.user_type_id) LOOP
      IF (X.permission_Name = G_PARTNER_PERMISSION) THEN
       is_partner_user := true;
      ELSIF (X.permission_name = G_PRIMARY_PERMISSION) THEN
       is_primary_user := true;
      END IF;
     END LOOP;

     IF(not is_partner_user) THEN
      fnd_message.SET_NAME  ('PV', 'PV_NOT_PRTNR_USER');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
     END IF;

    create_user_resource(
        p_api_version_number       => p_api_version_number
       ,p_init_msg_list            => FND_API.g_false
       ,p_commit                   => FND_API.G_FALSE
       ,p_partner_user_rec         => p_partner_user_rec
       ,x_return_status            => x_return_status
       ,x_msg_count                => x_msg_count
       ,x_msg_data                 => x_msg_data
       );


    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

     IF (is_primary_user)  THEN
      l_role := pv_user_Resp_pvt.G_PRIMARY;
     ELSE
      l_role := pv_user_Resp_pvt.G_BUSINESS;
     END IF;

     pv_user_Resp_pvt.assign_user_resps(
      p_api_version_number         => p_api_version_number
     ,p_init_msg_list              => FND_API.g_false
     ,p_commit                     => FND_API.G_FALSE
     ,x_return_status              => x_return_status
     ,x_msg_count                  => x_msg_count
     ,x_msg_data                   => x_msg_data
     ,p_user_id                    => p_partner_user_rec.user_id
     ,p_user_role_code             => l_role
     );

     IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;


    FND_MSG_PUB.Count_And_Get
    ( p_encoded => FND_API.G_FALSE,
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
    );

    IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

   EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO register_partner_user;
          x_return_status := FND_API.G_RET_STS_ERROR;
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );


       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO register_partner_user;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         -- Standard call to get message count and if count=1, get the message
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

       WHEN OTHERS THEN
         ROLLBACK TO register_partner_user;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
	 FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
          );

 END register_partner_user;


 PROCEDURE revoke_role
 (
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_role_name                  IN   JTF_VARCHAR2_TABLE_1000
    ,p_user_name                  IN   VARCHAR2
    ,x_return_status              OUT  NOCOPY  VARCHAR2
    ,x_msg_count                  OUT  NOCOPY  NUMBER
    ,x_msg_data                   OUT  NOCOPY  VARCHAR2
 )
 IS

   l_api_version_number        CONSTANT  NUMBER       := 1.0;
   l_api_name                  CONSTANT  VARCHAR2(30) := 'revoke_role';
   l_full_name                 CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   cursor check_curr_role_perms(l_role_name JTF_VARCHAR2_TABLE_1000) IS
      select  jtfperm.permission_name  , jtfp1.jtf_auth_principal_id
      from jtf_auth_principals_b jtfp1, jtf_auth_role_perms jtfrp, jtf_auth_permissions_b jtfperm
      where jtfp1.is_user_flag = 0
      and  jtfp1.jtf_auth_principal_id = jtfrp.jtf_auth_principal_id
      and  jtfrp.positive_flag = 1
      and jtfrp.jtf_auth_permission_id = jtfperm.jtf_auth_permission_id
      and jtfperm.permission_name  in (G_PRIMARY_PERMISSION, G_PARTNER_PERMISSION)
      and jtfp1.principal_name IN (Select  * from table (CAST(l_role_name AS JTF_VARCHAR2_TABLE_1000)));


   cursor check_curr_user_perms(l_role_id JTF_NUMBER_TABLE, l_user_name varchar2) IS
   Select jtfperm.permission_name
   FROM   jtf_auth_principal_maps jtfpm, jtf_auth_principals_b jtfp1, jtf_auth_domains_b jtfd,  jtf_auth_role_perms jtfrp,
          jtf_auth_permissions_b jtfperm
	    where jtfp1.principal_name = l_user_name
	    and jtfp1.is_user_flag=1
	    and jtfp1.jtf_auth_principal_id=jtfpm.jtf_auth_principal_id
	    and jtfrp.jtf_auth_principal_id =  jtfpm.jtf_auth_parent_principal_id
	    and jtfrp.positive_flag = 1
	    and jtfrp.jtf_auth_permission_id = jtfperm.jtf_auth_permission_id
	    and jtfperm.permission_name  in ( G_PRIMARY_PERMISSION, G_PARTNER_PERMISSION)
	    and jtfd.jtf_auth_domain_id=jtfpm.jtf_auth_domain_id
	    and jtfd.domain_name='CRM_DOMAIN'
	    and jtfpm.jtf_auth_parent_principal_id NOT IN (Select  * from table (CAST(l_role_id AS JTF_NUMBER_TABLE)))
     group by jtfperm.permission_name;

   cursor get_user_id(l_user_name varchar2) IS
   Select fndu.user_id
   from fnd_user fndu
   where fndu.user_name = l_user_name;



   is_prtnr_perm_revoked boolean  := false;
   is_primary_perm_revoked boolean := false;
   l_role_ids JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   is_primary_user   boolean := false;
   is_partner_user   boolean := false;
   l_user_id  NUMBER;
   l_role varchar2(10);


   BEGIN

     ---------------Initialize --------------------
      -- Standard Start of API savepoint
      SAVEPOINT revoke_role;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
            l_api_version_number
           ,p_api_version_number
           ,l_api_name
           ,G_PKG_NAME
           )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('API: ' || l_api_name || ' - start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
  -------------End Of Initialize -------------------------------


     IF FND_GLOBAL.User_Id IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_USER_PROFILE_MISSING');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF (p_role_name.count < 1) THEN
      fnd_message.SET_NAME  ('PV', 'PV_MISSING_ROLE_NAME');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
     END IF;

     IF (p_user_name IS NULL or p_user_name = FND_API.G_MISS_CHAR) THEN
      fnd_message.SET_NAME  ('PV', 'PV_MISSING_USER_NAME');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
     END IF;

    /** Check if partner or primary permissions are part of the current role. IF NOT, we do not need to do any thing **/
    FOR X in check_curr_role_perms(p_role_name) LOOP
     l_role_ids.extend;
     l_role_ids(l_role_ids.count) := x.jtf_auth_principal_id;
     IF (x.permission_name = G_PARTNER_PERMISSION) THEN
       is_primary_perm_revoked  := true;
     elsif (x.permission_name = G_PRIMARY_PERMISSION) THEN
       is_prtnr_perm_revoked   := true;
     END IF;
    END LOOP;

    /** If partner or primary permissions are part of the current role **/
    if(is_primary_perm_revoked or is_prtnr_perm_revoked) THEN

     /** check if current user has either partner or primary persmissions assigned with out considering the role
     that is being revoked **/
     FOR X in check_curr_user_perms(l_role_ids, p_user_name) LOOP
      IF(X.permission_name = G_PARTNER_PERMISSION) THEN
        is_partner_user := true;
      elsif (X.permission_name = G_PRIMARY_PERMISSION) THEN
        is_primary_user := true;
      end if;
     END LOOP;


     open get_user_id(p_user_name);
     fetch get_user_id into l_user_id;
     close get_user_id;


     /** If G_PARTNER_PERMISSION permission is revoked and user will become non partner user after the role is revoked **/
     If(NOT is_partner_user and is_prtnr_perm_revoked) THEN

       if(is_primary_user or is_primary_perm_revoked) THEN
        l_role :=  PV_USER_RESP_PVT.G_PRIMARY;
       else
         l_role := PV_USER_RESP_PVT.G_BUSINESS;
       END IF;

       PV_USER_RESP_PVT.revoke_user_resps(
         p_api_version_number    => p_api_version_number
        ,p_init_msg_list         => FND_API.g_false
        ,p_commit                => FND_API.G_FALSE
        ,x_return_status         => x_return_status
        ,x_msg_count             => x_msg_count
        ,x_msg_data              => x_msg_data
        ,p_user_id               => l_user_id
	,p_user_role_code        => l_role
	);

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

     /** If partner user and primary user permission is revoked and user will become business user after this **/
     elsif (is_partner_user and (NOT is_primary_user) and is_primary_perm_revoked) THEN
      PV_USER_RESP_PVT.switch_user_resp(
        p_api_version_number     => p_api_version_number
       ,p_init_msg_list          => FND_API.g_false
       ,p_commit                 => FND_API.G_FALSE
       ,x_return_status          => x_return_status
       ,x_msg_count              => x_msg_count
       ,x_msg_data               => x_msg_data
       ,p_user_id                => l_user_id
       ,p_from_user_role_code    => PV_USER_RESP_PVT.G_PRIMARY
       ,p_to_user_role_code      => PV_USER_RESP_PVT.G_BUSINESS
       );

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF;
   end if;

   FND_MSG_PUB.Count_And_Get
    ( p_encoded => FND_API.G_FALSE,
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
    );

    IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

   EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO revoke_role;
          x_return_status := FND_API.G_RET_STS_ERROR;
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );


       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO revoke_role;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         -- Standard call to get message count and if count=1, get the message
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

       WHEN OTHERS THEN
         ROLLBACK TO revoke_role;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
	 FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
          );

 END revoke_role;


  PROCEDURE delete_role
 (
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_role_name                  IN   JTF_VARCHAR2_TABLE_1000
    ,x_return_status              OUT  NOCOPY  VARCHAR2
    ,x_msg_count                  OUT  NOCOPY  NUMBER
    ,x_msg_data                   OUT  NOCOPY  VARCHAR2
 )
 IS

   l_api_version_number        CONSTANT  NUMBER       := 1.0;
   l_api_name                  CONSTANT  VARCHAR2(30) := 'delete_role';
   l_full_name                 CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   cursor check_curr_role_perms(cv_role_name JTF_VARCHAR2_TABLE_1000) IS
      select  jtfperm.permission_name  , jtfp1.jtf_auth_principal_id
      from jtf_auth_principals_b jtfp1, jtf_auth_role_perms jtfrp, jtf_auth_permissions_b jtfperm
      where jtfp1.is_user_flag = 0
      and  jtfp1.jtf_auth_principal_id = jtfrp.jtf_auth_principal_id
      and  jtfrp.positive_flag = 1
      and jtfrp.jtf_auth_permission_id = jtfperm.jtf_auth_permission_id
      and jtfperm.permission_name  in (G_PRIMARY_PERMISSION, G_PARTNER_PERMISSION)
      and jtfp1.principal_name IN (Select  * from table (CAST(cv_role_name AS JTF_VARCHAR2_TABLE_1000)));



   cursor get_users_w_curr_role(cv_role_id JTF_NUMBER_TABLE) IS
      select /*+ cardinality( t 10 ) */ jtfp2.principal_name, fndu.user_id
      from jtf_auth_principal_maps jtfpm, jtf_auth_principals_b jtfp2,jtf_auth_principals_b jtfp1,
           fnd_user fndu, jtf_rs_resource_extns jtfre,  (Select  column_value from table
(CAST(cv_role_id AS JTF_NUMBER_TABLE))) t
      where jtfp1.jtf_auth_principal_id = t.column_value
      and   jtfp1.is_user_flag = 0
      and   jtfp1.jtf_auth_principal_id = jtfpm.jtf_auth_parent_principal_id
      and jtfpm.jtf_auth_principal_id = jtfp2.jtf_auth_principal_id
      and jtfp2.is_user_flag=1
      and jtfp2.principal_name =  fndu.user_name
      and fndu.user_id = jtfre.user_id
      and jtfre.category  = 'PARTY';


   /** ??? Does this query need to handle inactive resources or partner contacts **/
   cursor get_usrs_perm_wo_curr_role(cv_role_id JTF_NUMBER_TABLE, cv_user_name JTF_VARCHAR2_TABLE_1000) IS
   select /*+ cardinality( t 10 ) */  jtfperm.permission_name, jtfp3.principal_name
   from  jtf_auth_principals_b jtfp3,  jtf_auth_role_perms jtfrp, jtf_auth_permissions_b jtfperm, jtf_auth_principal_maps jtfpm2, (Select  column_value from table (CAST(cv_user_name AS JTF_VARCHAR2_TABLE_1000))) t
   where jtfp3.principal_name = t.column_value
    and jtfp3.is_user_flag = 1 and jtfp3.jtf_auth_principal_id=jtfpm2.jtf_auth_principal_id
    and jtfpm2.jtf_auth_parent_principal_id = jtfrp.JTF_AUTH_PRINCIPAL_ID
    and jtfpm2.jtf_auth_parent_principal_id NOT IN (Select  * from table (CAST(cv_role_id AS JTF_NUMBER_TABLE)))
    and jtfrp.JTF_AUTH_PERMISSION_ID = jtfperm.jtf_auth_permission_id
    and jtfperm.permission_name IN  (G_PRIMARY_PERMISSION, G_PARTNER_PERMISSION)
    and jtfrp.positive_flag = 1
    group by jtfperm.permission_name, jtfp3.principal_name
    order by jtfp3.principal_name;


   is_prtnr_perm_revoked boolean  := false;
   is_primary_perm_revoked boolean := false;
   is_primary_user   boolean := false;
   is_partner_user   boolean := false;

   l_role_ids JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_user_ids JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_user_names JTF_VARCHAR2_TABLE_1000 := JTF_VARCHAR2_TABLE_1000();
   l_user_perm_changed JTF_VARCHAR2_TABLE_1000 := JTF_VARCHAR2_TABLE_1000();

   l_prev_user_name VARCHAR2(255) := null;
   l_role varchar2(10);


   BEGIN

     ---------------Initialize --------------------
      -- Standard Start of API savepoint
      SAVEPOINT delete_role;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
            l_api_version_number
           ,p_api_version_number
           ,l_api_name
           ,G_PKG_NAME
           )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('API: ' || l_api_name || ' - start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
  -------------End Of Initialize -------------------------------


     IF FND_GLOBAL.User_Id IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_USER_PROFILE_MISSING');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF (p_role_name.count < 1) THEN
      fnd_message.SET_NAME  ('PV', 'PV_MISSING_ROLE_NAME');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
     END IF;

    /** Check if partner or primary permissions are part of the current role. IF NOT, we do not need to do any thing **/
    FOR X in check_curr_role_perms(p_role_name) LOOP
     l_role_ids.extend;
     l_role_ids(l_role_ids.count) := x.jtf_auth_principal_id;
     IF (x.permission_name = G_PARTNER_PERMISSION) THEN
       is_primary_perm_revoked  := true;
     elsif (x.permission_name = G_PRIMARY_PERMISSION) THEN
       is_prtnr_perm_revoked   := true;
     END IF;
    END LOOP;


     /** If partner or primary permissions are part of the current role **/
    IF (is_primary_perm_revoked or is_prtnr_perm_revoked) THEN
      FOR X in get_users_w_curr_role(l_role_ids) LOOP
         l_user_names.extend;
	 l_user_names(l_user_names.count) := X.principal_name;
	 l_user_ids.extend;
	 l_user_ids(l_user_ids.count) := X.user_id;
	 l_user_perm_changed.extend;
      END LOOP;

      IF (l_user_names.count > 0) THEN
       FOR X in get_usrs_perm_wo_curr_role(l_role_ids, l_user_names) LOOP
	 IF(l_prev_user_name is not null and l_prev_user_name <> X.principal_name) THEN
	    FOR Y in 1..l_user_names.count LOOP
              IF (l_user_names(Y) = l_prev_user_name) THEN
                if(is_partner_user and is_primary_user) THEN
		  l_user_perm_changed(Y) := 'PP';
		elsif(is_partner_user and not is_primary_user) THEN
		  l_user_perm_changed(Y) := 'PT';
		elsif(not is_partner_user and is_primary_user) THEN
		  l_user_perm_changed(Y) := 'PR';
		end if;
                is_partner_user := false;
		is_primary_user := false;
		l_prev_user_name := X.principal_name;
    	      END IF;
	    END LOOP;
	  ELSIF (l_prev_user_name is null) THEN
	     l_prev_user_name := X.principal_name;
	  END IF;
	  IF (x.permission_name = G_PARTNER_PERMISSION) THEN
	   is_partner_user := true;
	  elsif (X.permission_name = G_PRIMARY_PERMISSION) THEN
           is_primary_user := true;
          end if;
	END LOOP;

        FOR Y in 1..l_user_names.count LOOP
          IF (l_user_names(Y) = l_prev_user_name) THEN
             if(is_partner_user and is_primary_user) THEN
	      l_user_perm_changed(Y) := 'PP';
	   elsif(is_partner_user and not is_primary_user) THEN
	      l_user_perm_changed(Y) := 'PT';
	   elsif(not is_partner_user and is_primary_user) THEN
	       l_user_perm_changed(Y) := 'PR';
	   end if;
          END IF;
        END LOOP;



	FOR X in 1..l_user_names.count loop
         IF (is_primary_perm_revoked and (l_user_perm_changed(X) is null or l_user_perm_changed(X) = 'PR')) THEN
      	    IF (l_user_perm_changed(X) = 'PR' or is_primary_perm_revoked) THEN
             l_role :=  PV_USER_RESP_PVT.G_PRIMARY;
            else
             l_role := PV_USER_RESP_PVT.G_BUSINESS;
            END IF;

	    PV_USER_RESP_PVT.revoke_user_resps(
             p_api_version_number    => p_api_version_number
            ,p_init_msg_list         => FND_API.g_false
            ,p_commit                => FND_API.G_FALSE
            ,x_return_status         => x_return_status
            ,x_msg_count             => x_msg_count
            ,x_msg_data              => x_msg_data
            ,p_user_id               => l_user_ids(X)
	    ,p_user_role_code        => l_role
	   );

          IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;
        ELSIF (is_primary_perm_revoked and l_user_perm_changed(X) = 'PT') THEN
	  PV_USER_RESP_PVT.switch_user_resp(
           p_api_version_number     => p_api_version_number
          ,p_init_msg_list          => FND_API.g_false
          ,p_commit                 => FND_API.G_FALSE
          ,x_return_status          => x_return_status
          ,x_msg_count              => x_msg_count
          ,x_msg_data               => x_msg_data
          ,p_user_id                => l_user_ids(X)
          ,p_from_user_role_code    => PV_USER_RESP_PVT.G_PRIMARY
          ,p_to_user_role_code      => PV_USER_RESP_PVT.G_BUSINESS
         );

        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;

       END IF;
      END LOOP;

      END IF;
   END IF;

   FND_MSG_PUB.Count_And_Get
    ( p_encoded => FND_API.G_FALSE,
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
    );

    IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

   EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO delete_role;
          x_return_status := FND_API.G_RET_STS_ERROR;
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );


       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO delete_role;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         -- Standard call to get message count and if count=1, get the message
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

       WHEN OTHERS THEN
         ROLLBACK TO delete_role;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
	 FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
          );

 END delete_role;


PROCEDURE assign_role
(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_role_name                  IN   JTF_VARCHAR2_TABLE_1000
    ,p_user_name                  IN   VARCHAR2
    ,x_return_status              OUT  NOCOPY  VARCHAR2
    ,x_msg_count                  OUT  NOCOPY  NUMBER
    ,x_msg_data                   OUT  NOCOPY  VARCHAR2
)
IS
   l_api_version_number        CONSTANT  NUMBER       := 1.0;
   l_api_name                  CONSTANT  VARCHAR2(30) := 'assign_role';
   l_full_name                 CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   cursor check_curr_role_perms(l_role_name JTF_VARCHAR2_TABLE_1000) IS
      select jtfperm.permission_name
      from jtf_auth_principals_b jtfp1, jtf_auth_role_perms jtfrp, jtf_auth_permissions_b jtfperm
      where jtfp1.is_user_flag = 0 and jtfp1.jtf_auth_principal_id = jtfrp.jtf_auth_principal_id
      and  jtfrp.positive_flag = 1 and jtfrp.jtf_auth_permission_id = jtfperm.jtf_auth_permission_id
      and jtfperm.permission_name IN ( G_PRIMARY_PERMISSION, G_PARTNER_PERMISSION)
      and jtfp1.principal_name in (Select  * from table (CAST(l_role_name AS JTF_VARCHAR2_TABLE_1000)))
      group by jtfperm.permission_name;

   cursor get_user_id(l_user_name VARCHAR2) IS
      select  fndu.user_id
      from    fnd_user fndu
      where   fndu.user_name = l_user_name;

   cursor get_user_permissions(l_user_name VARCHAR2) IS
      select  jtfperm.permission_name
      from jtf_auth_principals_b jtfp1, jtf_auth_principal_maps jtfpm,
      jtf_auth_role_perms jtfrp, jtf_auth_permissions_b jtfperm
      where jtfp1.principal_name = l_user_name
      and jtfp1.is_user_flag = 1
      and jtfp1.jtf_auth_principal_id = jtfpm.jtf_auth_principal_id
      and jtfpm.JTF_AUTH_PARENT_PRINCIPAL_ID =  jtfrp.jtf_auth_principal_id
      and  jtfrp.positive_flag = 1
      and jtfrp.jtf_auth_permission_id = jtfperm.jtf_auth_permission_id
      and jtfperm.permission_name  in (G_PRIMARY_PERMISSION, G_PARTNER_PERMISSION)
      group by jtfperm.permission_name;


   cursor validate_partner_user(l_user_id NUMBER) IS
      select 'X' from dual
      where exists
      (select 'X' from jtf_rs_resource_extns
      where user_id = l_user_id and category='PARTY');

   is_prtnr_perm_assigned boolean  := false;
   is_primary_perm_assigned boolean := false;
   l_role_ids JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   is_primary_user   boolean := false;
   is_partner_user   boolean := false;
   l_user_id  NUMBER;
   is_user_changed boolean := true;
   l_role varchar2(10);
   isValidPrtnrUser boolean := false;


   BEGIN

     ---------------Initialize --------------------
      -- Standard Start of API savepoint
      SAVEPOINT assign_role;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
            l_api_version_number
           ,p_api_version_number
           ,l_api_name
           ,G_PKG_NAME
           )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('API: ' || l_api_name || ' - start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
  -------------End Of Initialize -------------------------------


     IF FND_GLOBAL.User_Id IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_USER_PROFILE_MISSING');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF (p_role_name.count < 1) THEN
      fnd_message.SET_NAME  ('PV', 'PV_MISSING_ROLE_NAME');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
     END IF;

     IF (p_user_name IS NULL or p_user_name = FND_API.G_MISS_CHAR) THEN
      fnd_message.SET_NAME  ('PV', 'PV_MISSING_USER_NAME');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
     END IF;

     /** check if current roles that are being assigned has G_PARTNER_PERMISSION OR G_PRIMARY_PERMISSION permissions **/
     FOR X in check_curr_role_perms(p_role_name) LOOP
      IF (x.permission_name = G_PARTNER_PERMISSION) THEN
        is_prtnr_perm_assigned     := true;
      elsif (x.permission_name = G_PRIMARY_PERMISSION) THEN
        is_primary_perm_assigned  := true;
      END IF;
    END LOOP;

    IF(is_primary_perm_assigned or is_prtnr_perm_assigned) THEN

     FOR X in get_user_id(p_user_name) LOOP
        l_user_id := X.USER_ID;
     END LOOP;

     /** Check if user is partner user or partner primary user **/
     FOR X in get_user_permissions(p_user_name) LOOP
        IF (x.permission_name = G_PARTNER_PERMISSION) THEN
          is_partner_user     := true;
        elsif (x.permission_name = G_PRIMARY_PERMISSION) THEN
          is_primary_user  := true;
        END IF;
      END LOOP;

    /** If partner or primary permissions are part of the current role **/
    If (NOT is_partner_user and is_prtnr_perm_assigned) THEN
      FOR X in validate_partner_user(l_user_id) LOOP
       isValidPrtnrUser := true;
      END LOOP;

     IF (NOT isValidPrtnrUser) THEN
      fnd_message.SET_NAME  ('PV', 'PV_INVALID_PTNR_USER');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
     END IF;

     IF(is_primary_perm_assigned OR is_primary_user) THEN
      l_role := PV_USER_RESP_PVT.G_PRIMARY;
     else
      l_role := PV_USER_RESP_PVT.G_BUSINESS;
     end if;

      PV_USER_RESP_PVT.assign_user_resps(
          p_api_version_number    => p_api_version_number
         ,p_init_msg_list         => FND_API.g_false
         ,p_commit                => FND_API.G_FALSE
         ,x_return_status         => x_return_status
         ,x_msg_count             => x_msg_count
         ,x_msg_data              => x_msg_data
         ,p_user_id               => l_user_id
         ,p_user_role_code        => l_role
      );

       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

    ELSIF (is_partner_user and (NOT is_primary_user) and is_primary_perm_assigned) THEN

       PV_USER_RESP_PVT.switch_user_resp(
           p_api_version_number     => p_api_version_number
          ,p_init_msg_list          => FND_API.g_false
          ,p_commit                 => FND_API.G_FALSE
          ,x_return_status          => x_return_status
          ,x_msg_count              => x_msg_count
          ,x_msg_data               => x_msg_data
          ,p_user_id                => l_user_id
          ,p_from_user_role_code    => PV_USER_RESP_PVT.G_BUSINESS
          ,p_to_user_role_code      => PV_USER_RESP_PVT.G_PRIMARY
         );

       IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
       END IF;

    END IF;
   END IF;

   FND_MSG_PUB.Count_And_Get
    ( p_encoded => FND_API.G_FALSE,
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
    );

    IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

   EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO assign_role;
          x_return_status := FND_API.G_RET_STS_ERROR;
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );


       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO assign_role;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         -- Standard call to get message count and if count=1, get the message
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

       WHEN OTHERS THEN
         ROLLBACK TO assign_role;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
	 FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
          );

 END assign_role;


PROCEDURE update_role
(
     p_api_version_number         IN   NUMBER
    ,p_init_msg_list              IN   VARCHAR2           := FND_API.G_FALSE
    ,p_commit                     IN   VARCHAR2           := FND_API.G_FALSE
    ,p_assigned_perms             IN   JTF_VARCHAR2_TABLE_1000
    ,p_unassigned_perms           IN   JTF_VARCHAR2_TABLE_1000
    ,p_role_name                  IN   VARCHAR2
    ,x_return_status              OUT  NOCOPY  VARCHAR2
    ,x_msg_count                  OUT  NOCOPY  NUMBER
    ,x_msg_data                   OUT  NOCOPY  VARCHAR2
)
IS
   l_api_version_number        CONSTANT  NUMBER       := 1.0;
   l_api_name                  CONSTANT  VARCHAR2(30) := 'update_role';
   l_full_name                 CONSTANT  VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;


   cursor get_user_permissions(cv_role_id NUMBER, cv_user_name JTF_VARCHAR2_TABLE_1000) IS
     select /*+ cardinality( t 10 ) */ jtfperm.permission_name, jtfp3.principal_name
     from  jtf_auth_principals_b jtfp3, jtf_auth_role_perms jtfrp, jtf_auth_permissions_b jtfperm, jtf_auth_principal_maps jtfpm2, (Select  column_value from table (CAST(cv_user_name AS JTF_VARCHAR2_TABLE_1000))) t
     where jtfp3.principal_name = t.column_value
	     and jtfp3.is_user_flag = 1
	     and jtfp3.jtf_auth_principal_id=jtfpm2.jtf_auth_principal_id
	     and jtfpm2.jtf_auth_parent_principal_id = jtfrp.JTF_AUTH_PRINCIPAL_ID
	     and jtfrp.JTF_AUTH_PERMISSION_ID = jtfperm.jtf_auth_permission_id
		 and jtfperm.permission_name IN  (G_PRIMARY_PERMISSION, G_PARTNER_PERMISSION)
	     and jtfrp.positive_flag = 1
	     and jtfpm2.jtf_auth_parent_principal_id <> cv_role_id
	     group by jtfperm.permission_name, jtfp3.principal_name
	     order by jtfp3.principal_name;


    cursor get_users_w_curr_role(cv_role_id NUMBER) IS
      select jtfp2.principal_name, fndu.user_id
      from jtf_auth_principal_maps jtfpm, jtf_auth_principals_b jtfp2,jtf_auth_principals_b jtfp1,
           fnd_user fndu, jtf_rs_resource_extns jtfre
      where jtfp1.jtf_auth_principal_id = cv_role_id
      and   jtfp1.is_user_flag = 0
      and   jtfp1.jtf_auth_principal_id = jtfpm.jtf_auth_parent_principal_id
      and jtfpm.jtf_auth_principal_id = jtfp2.jtf_auth_principal_id
      and jtfp2.is_user_flag=1
      and jtfp2.principal_name =  fndu.user_name
      and fndu.user_id = jtfre.user_id
      and jtfre.category  = 'PARTY';


    cursor check_curr_role_perms(l_role_name VARCHAR2) IS
      select jtfperm.permission_name, jtfp1.jtf_auth_principal_id
      from jtf_auth_principals_b jtfp1, jtf_auth_role_perms jtfrp, jtf_auth_permissions_b jtfperm
      where jtfp1.is_user_flag = 0 and jtfp1.jtf_auth_principal_id = jtfrp.jtf_auth_principal_id
      and  jtfrp.positive_flag = 1 and jtfrp.jtf_auth_permission_id = jtfperm.jtf_auth_permission_id
      and jtfperm.permission_name IN ( G_PRIMARY_PERMISSION, G_PARTNER_PERMISSION)
      and jtfp1.principal_name = l_role_name;


   is_prtnr_perm_assigned boolean  := false;
   is_primary_perm_assigned boolean := false;
   is_prtnr_perm_revoked boolean  := false;
   is_primary_perm_revoked boolean := false;

   is_primary_user   boolean := false;
   is_partner_user   boolean := false;

   l_user_ids JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_user_names JTF_VARCHAR2_TABLE_1000 := JTF_VARCHAR2_TABLE_1000();
   l_user_perm_changed JTF_VARCHAR2_TABLE_1000 := JTF_VARCHAR2_TABLE_1000();

   l_role varchar2(10);
   l_prev_user_name VARCHAR2(255);
   l_role_id NUMBER;
   l_prtnr_perm_exists boolean := false;
   l_primary_perm_exists boolean := false;



   BEGIN

     ---------------Initialize --------------------
      -- Standard Start of API savepoint
      SAVEPOINT update_role;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call (
            l_api_version_number
           ,p_api_version_number
           ,l_api_name
           ,G_PKG_NAME
           )
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('API: ' || l_api_name || ' - start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;
  -------------End Of Initialize -------------------------------


     IF FND_GLOBAL.User_Id IS NULL THEN
          FND_MESSAGE.set_name('PV', 'PV_API_USER_PROFILE_MISSING');
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     IF (p_role_name IS NULL or p_role_name = FND_API.G_MISS_CHAR) THEN
      fnd_message.SET_NAME  ('PV', 'PV_MISSING_ROLE_NAME');
      fnd_msg_pub.ADD;
      raise FND_API.G_EXC_ERROR;
     END IF;

     IF (p_assigned_perms IS NOT NULL and p_assigned_perms.count > 0) THEN
      FOR i in p_assigned_perms.FIRST .. p_assigned_perms.LAST LOOP
       IF (p_assigned_perms(i) = G_PARTNER_PERMISSION) THEN
          is_prtnr_perm_assigned := true;
       elsif (p_assigned_perms(i) = G_PRIMARY_PERMISSION) THEN
          is_primary_perm_assigned := true;
       END IF;
      END LOOP;
     END IF;


     IF (p_unassigned_perms IS NOT NULL and p_unassigned_perms.count > 0) THEN
      FOR i in p_unassigned_perms.FIRST .. p_unassigned_perms.LAST LOOP
       IF (p_unassigned_perms(i) = G_PARTNER_PERMISSION) THEN
          is_prtnr_perm_revoked := true;
       elsif (p_unassigned_perms(i) = G_PRIMARY_PERMISSION) THEN
          is_primary_perm_revoked := true;
       END IF;
      END LOOP;
     END IF;

     If(is_prtnr_perm_assigned or is_primary_perm_assigned or is_prtnr_perm_revoked or is_primary_perm_revoked) THEN

      FOR Y in check_curr_role_perms(p_role_name) LOOP
       l_role_id := Y.jtf_auth_principal_id;
       IF (Y.permission_name = G_PARTNER_PERMISSION) THEN
         l_prtnr_perm_exists := true;
       ELSIF (Y.permission_name = G_PRIMARY_PERMISSION) THEN
         l_primary_perm_exists := true;
       END IF;
      END LOOP;


      FOR X in get_users_w_curr_role(l_role_id) LOOP
         l_user_names.extend;
	 l_user_names(l_user_names.count) := X.principal_name;
	 l_user_ids.extend;
	 l_user_ids(l_user_ids.count) := X.user_id;
	 l_user_perm_changed.extend;
      END LOOP;

      IF (l_user_names.count > 0) THEN
          FOR X in get_user_permissions(l_role_id, l_user_names) LOOP
            IF(l_prev_user_name is not null and l_prev_user_name <> X.principal_name) THEN
	    FOR Y in 1..l_user_names.count LOOP
              IF (l_user_names(Y) = l_prev_user_name) THEN
                if(is_partner_user and is_primary_user) THEN
		  l_user_perm_changed(Y) := 'PP';
		elsif(is_partner_user and not is_primary_user) THEN
		  l_user_perm_changed(Y) := 'PT';
		elsif(not is_partner_user and is_primary_user) THEN
		  l_user_perm_changed(Y) := 'PR';
		end if;
                is_partner_user := false;
		is_primary_user := false;
		l_prev_user_name := X.principal_name;
    	      END IF;
	    END LOOP;
	  ELSIF (l_prev_user_name is null) THEN
	     l_prev_user_name := X.principal_name;
	  END IF;
	  IF (x.permission_name = G_PARTNER_PERMISSION) THEN
	   is_partner_user := true;
	  elsif (X.permission_name = G_PRIMARY_PERMISSION) THEN
           is_primary_user := true;
          end if;
         END LOOP;


	FOR Y in 1..l_user_names.count LOOP
	  IF (l_user_names(Y) = l_prev_user_name) THEN
           if(is_partner_user and is_primary_user) THEN
	      l_user_perm_changed(Y) := 'PP';
	   elsif(is_partner_user and not is_primary_user) THEN
	      l_user_perm_changed(Y) := 'PT';
	   elsif(not is_partner_user and is_primary_user) THEN
	       l_user_perm_changed(Y) := 'PR';
	   end if;
          END IF;
        END LOOP;


	FOR X in 1..l_user_names.count loop
          IF (is_prtnr_perm_assigned or is_primary_perm_assigned) THEN
           IF ((l_user_perm_changed(X) is null or l_user_perm_changed(X) = 'PR') and is_prtnr_perm_assigned) THEN
                 IF(is_primary_perm_assigned OR l_user_perm_changed(X) = 'PR' or (l_primary_perm_exists and NOT is_primary_perm_revoked)) THEN
                   l_role := PV_USER_RESP_PVT.G_PRIMARY;
                 else
                   l_role := PV_USER_RESP_PVT.G_BUSINESS;
                 end if;

		 PV_USER_RESP_PVT.assign_user_resps(
                   p_api_version_number    => p_api_version_number
                  ,p_init_msg_list         => FND_API.g_false
                  ,p_commit                => FND_API.G_FALSE
                  ,x_return_status         => x_return_status
                  ,x_msg_count             => x_msg_count
                  ,x_msg_data              => x_msg_data
                  ,p_user_id               => l_user_ids(X)
                  ,p_user_role_code        => l_role
                 );

                IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
                END IF;
            ELSIF ((l_user_perm_changed(X) = 'PT'
	            or (l_prtnr_perm_exists and NOT is_prtnr_perm_revoked))
	             and is_primary_perm_assigned) THEN

                PV_USER_RESP_PVT.switch_user_resp(
                  p_api_version_number     => p_api_version_number
                 ,p_init_msg_list          => FND_API.g_false
                 ,p_commit                 => FND_API.G_FALSE
                 ,x_return_status          => x_return_status
                 ,x_msg_count              => x_msg_count
                 ,x_msg_data               => x_msg_data
                 ,p_user_id                => l_user_ids(X)
                 ,p_from_user_role_code    => PV_USER_RESP_PVT.G_BUSINESS
                 ,p_to_user_role_code      => PV_USER_RESP_PVT.G_PRIMARY
                );

             IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
             ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
             END IF;
           END IF;
         END IF;

          IF (is_prtnr_perm_revoked or is_primary_perm_revoked) THEN
           /** If G_PARTNER_PERMISSION permission is revoked and user will become non partner user after the role is revoked **/
          If((l_user_perm_changed(X) = 'PR' or l_user_perm_changed(X) is null) and is_prtnr_perm_revoked) THEN
       	   IF(l_primary_perm_exists or l_user_perm_changed(X) = 'PR') THEN
              l_role := PV_USER_RESP_PVT.G_PRIMARY;
           else
              l_role := PV_USER_RESP_PVT.G_BUSINESS;
           end if;

           PV_USER_RESP_PVT.revoke_user_resps(
             p_api_version_number    => p_api_version_number
            ,p_init_msg_list         => FND_API.g_false
            ,p_commit                => FND_API.G_FALSE
            ,x_return_status         => x_return_status
            ,x_msg_count             => x_msg_count
            ,x_msg_data              => x_msg_data
            ,p_user_id               => l_user_ids(X)
	    ,p_user_role_code        => l_role
	   );

          IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
          END IF;

       /** If partner user and primary user permission is revoked and user will become business user after this **/
       elsif ((l_user_perm_changed(X) = 'PT' or (l_user_perm_changed(X) is null and l_prtnr_perm_exists)) and is_primary_perm_revoked) THEN


         PV_USER_RESP_PVT.switch_user_resp(
           p_api_version_number     => p_api_version_number
          ,p_init_msg_list          => FND_API.g_false
          ,p_commit                 => FND_API.G_FALSE
          ,x_return_status          => x_return_status
          ,x_msg_count              => x_msg_count
          ,x_msg_data               => x_msg_data
          ,p_user_id                => l_user_ids(X)
          ,p_from_user_role_code    => PV_USER_RESP_PVT.G_PRIMARY
          ,p_to_user_role_code      => PV_USER_RESP_PVT.G_BUSINESS
         );

        IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
          RAISE FND_API.G_EXC_ERROR;
        END IF;
       END IF;
      END IF;
      END LOOP;


     END IF;
    END IF;




   FND_MSG_PUB.Count_And_Get
    ( p_encoded => FND_API.G_FALSE,
      p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
    );

    IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT WORK;
    END IF;

   EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
          ROLLBACK TO update_role;
          x_return_status := FND_API.G_RET_STS_ERROR;
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );


       WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
          ROLLBACK TO update_role;
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         -- Standard call to get message count and if count=1, get the message
	   FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
           );

       WHEN OTHERS THEN
         ROLLBACK TO update_role;
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)THEN
            FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
         END IF;
	 FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE
           ,p_count   => x_msg_count
           ,p_data    => x_msg_data
          );

 END update_role;



FUNCTION is_partner_user (p_rel_party_id  IN  NUMBER) RETURN VARCHAR2 IS

   cursor cv_is_partner_user(l_rel_party_id NUMBER) IS
    select 1 from dual where exists
    (
      select /*+ use_nl (hzr res) */ pvpp.partner_id, hzr.party_id, hzr.subject_id ,pvpp.partner_party_id
      from jtf_rs_resource_extns RES, hz_relationships hzr, pv_partner_profiles pvpp
      where RES.category = 'PARTY' and RES.source_id = 6310
      and RES.start_date_active <= SYSDATE
      and (RES.end_date_active is null or RES.end_date_active > SYSDATE)
      and RES.source_id = hzr.party_id and hzr.directional_flag = 'F'
      and hzr.relationship_code = 'EMPLOYEE_OF' and HZR.subject_table_name ='HZ_PARTIES'
      and HZR.object_table_name ='HZ_PARTIES' and hzr.start_date <= SYSDATE
      and (hzr.end_date is null or hzr.end_date > sysdate)
      and hzr.object_id = pvpp.partner_party_id
      and pvpp.status = 'A' and exists
      (
        select 1 from jtf_auth_principal_maps jtfpm,jtf_auth_principals_b jtfp1, jtf_auth_domains_b jtfd,
	   jtf_auth_principals_b jtfp2,jtf_auth_role_perms jtfrp, jtf_auth_permissions_b jtfperm
        where jtfp1.principal_name = RES.user_name and jtfp1.is_user_flag=1
        and jtfp1.jtf_auth_principal_id=jtfpm.jtf_auth_principal_id and jtfpm.jtf_auth_parent_principal_id = jtfp2.jtf_auth_principal_id
        and jtfp2.is_user_flag=0 and jtfp2.jtf_auth_principal_id = jtfrp.jtf_auth_principal_id
        and jtfrp.positive_flag = 1 and jtfrp.jtf_auth_permission_id = jtfperm.jtf_auth_permission_id
        and jtfperm.permission_name = G_PARTNER_PERMISSION
        and jtfd.jtf_auth_domain_id=jtfpm.jtf_auth_domain_id
        and jtfd.domain_name='CRM_DOMAIN'
      )
    );

   is_partner_user varchar2(1) := 'N';


BEGIN

     FOR x in cv_is_partner_user(p_rel_party_id) loop
       is_partner_user := 'Y';
     end loop;

     return is_partner_user;
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
        return is_partner_user;
END;  --is_partner_user



/*+====================================================================
| FUNCTION NAME
|    post_approval
|
| DESCRIPTION
|    This function is seeded as a subscription to the approval event
|
| USAGE
|    -   creates resps and resources when an approval event happens
|
+======================================================================*/

FUNCTION post_approval(
		       p_subscription_guid      IN RAW,
		       p_event                  IN OUT NOCOPY wf_event_t)

RETURN VARCHAR2
IS

    l_api_version_number        CONSTANT  NUMBER       := 1.0;
    l_api_name                  CONSTANT  VARCHAR2(30) := 'post_approval';

    l_key		VARCHAR2(240) := p_event.GetEventKey();
    l_id		NUMBER;
    l_userreg_id       	NUMBER;
    l_usertype_key      VARCHAR2(240);
    l_usertype_appId    VARCHAR2(240);
    l_customer_id	NUMBER;
    l_user_id		NUMBER;
    l_user_type_id      NUMBER;
    l_user_name		VARCHAR2(100);
    x_return_status     VARCHAR2(1);
    x_msg_count         NUMBER;
    x_msg_data          VARCHAR2(240);
    is_partner		NUMBER;
    partner_User_rec	partner_User_rec_type;
    x_msg_index         NUMBER;

    -- get user id, user name, customer id and usertype id
    Cursor c_get_user_info(c_reg_id NUMBER, c_user_type VARCHAR2) IS
    	select usr.user_id, usr.user_name, usr.customer_id, jureg.usertype_id
	from fnd_user usr, jtf_um_usertype_reg jureg
    	where jureg.usertype_reg_id=c_reg_id
    	and usr.user_id = jureg.user_id;

    -- check if the person is a partner user
    Cursor c_is_partner_user(c_usertype_id NUMBER) is
	select 1 from dual
	where exists
	( select  jtfperm.permission_name
   	  from jtf_auth_principals_b jtfp1, jtf_auth_role_perms jtfrp, jtf_auth_permissions_b jtfperm
   	  where jtfp1.is_user_flag = 0
   	  and  jtfp1.jtf_auth_principal_id = jtfrp.jtf_auth_principal_id
   	  and  jtfrp.positive_flag = 1
   	  and jtfrp.jtf_auth_permission_id = jtfperm.jtf_auth_permission_id
   	  and jtfperm.permission_name  = 'PV_PARTNER_USER'
   	  and jtfp1.principal_name IN
      	  (select principal_name
       	  from  jtf_um_usertype_role jtur
       	  where  jtur.usertype_id = c_usertype_id
       	  and  (jtur.effective_end_date is null or jtur.effective_end_date > sysdate)
      	  union all
       	  select jtsr.principal_name
       	  from jtf_um_usertype_subscrip jtus, jtf_um_subscription_role jtsr
       	  where  jtus.usertype_id = c_usertype_id
       	  and (jtus.effective_end_date is null or jtus.effective_end_date > sysdate)
       	  and jtus.subscription_flag = 'IMPLICIT'
       	  and jtus.subscription_id = jtsr.subscription_id
       	  and (jtsr.effective_end_date is null or jtsr.effective_end_date > sysdate)
      	  )
	);

BEGIN

    FND_MSG_PUB.initialize;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                       ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                       ,'Entered Post Approval procedure');
    END IF;

    l_userreg_id   := p_event.getValueForParameter('USERTYPEREG_ID');
    l_usertype_key := p_event.getValueForParameter('USER_TYPE_KEY');
    l_usertype_appId := p_event.getValueForParameter('APPID');

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                       ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                       ,'l_userreg_id=' || l_userreg_id || ',l_usertype_key=' || l_usertype_key || ',l_usertype_appId=' || l_usertype_appId);
    END IF;

    OPEN c_get_user_info(l_userreg_id, l_usertype_key);
    FETCH c_get_user_info into l_user_id, l_user_name, l_customer_id, l_user_type_id;
    CLOSE c_get_user_info;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                       ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                       ,'After c_get_user_info: l_user_id' || l_user_id || ',l_user_name=' || l_user_name || ',l_customer_id=' || l_customer_id || ',l_user_type_id=' || l_user_type_id);
    END IF;

    OPEN c_is_partner_user(l_user_type_id);
    FETCH c_is_partner_user into is_partner;
       IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
	         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                       ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                       ,'is_partner='|| to_char(is_partner) || ';');
       END IF;
    if (c_is_partner_user%NOTFOUND or is_partner <> 1 ) then
	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                       ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                       ,'l_user_name:' || l_user_name || '-- This user is not a partner user; no action; returning SUCCESS');
	END IF;
	RETURN 'SUCCESS';
    end if;
    CLOSE c_is_partner_user;

	-- create the partner_user_rec
	partner_user_rec.user_name :=  l_user_name;
	partner_user_rec.person_rel_party_id := l_customer_id;
	partner_user_rec.user_id := l_user_id;
	partner_user_rec.user_type_id := l_user_type_id;

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                       ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                       ,'this is a partner user; created partner user rec and going to call pv_user_mgmt_pvt.register_partner_user');
	END IF;

	-- jkylee: call register partner user procedure
	pv_user_mgmt_pvt.register_partner_user
	(
	 p_api_version_number         =>  l_api_version_number
	,p_init_msg_list              =>  FND_API.g_false
	,p_commit                     =>  FND_API.G_FALSE
	,p_partner_user_rec           =>  partner_user_rec
	,x_return_status              =>  x_return_status
	,x_msg_count                  =>  x_msg_count
	,x_msg_data                   =>  x_msg_data
	);

	IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                       ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                       ,'after call pv_user_mgmt_pvt.register_partner_user: x_return_status='|| x_return_status || ',x_msg_count=' || to_char(x_msg_count));
	END IF;

	FND_MSG_PUB.Count_And_Get
	(	p_encoded	 => FND_API.G_FALSE,
		p_count          =>   x_msg_count,
		p_data           =>   x_msg_data
	);

	if (x_return_status = 'S') then
		IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                       ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                       ,'returning SUCCESS to the function');
		END IF;
		RETURN 'SUCCESS';
	else

		IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
		FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
                       ,'pv.plsql.' || g_pkg_name || '.' || l_api_name
                       ,'x_return_status is not returning S');
		END IF;
		FOR k IN 1 .. x_msg_count LOOP
			fnd_msg_pub.get (
			p_msg_index     => k
			,p_encoded       => FND_API.G_FALSE
			,p_data          => x_msg_data
			,p_msg_index_out => x_msg_index);


			IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
				FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT
				,'pv.plsql.' || g_pkg_name || '.' || l_api_name
				,'in the error msg loop: k=' || to_char(k)|| ',x_msg_data=' || x_msg_data);
			END IF;
		END LOOP;

		WF_CORE.CONTEXT('PV', 'post_approval',
     	            p_event.getEventName(), p_subscription_guid);
     	            WF_EVENT.setErrorInfo(p_event, 'ERROR DURING CALL TO pv_user_mgmt_pvt.register_partner_user');
		RETURN 'ERROR';

      end if;

      RETURN 'SUCCESS';


EXCEPTION
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     	            WF_CORE.CONTEXT('PV', 'post_approval',
     	            p_event.getEventName(), p_subscription_guid);
     	            WF_EVENT.setErrorInfo(p_event, 'UNEXPECTED ERROR');
    		    RETURN 'ERROR';
     WHEN OTHERS THEN
	            WF_CORE.CONTEXT('PV', 'post_approval',
	            p_event.getEventName(), p_subscription_guid);
	            WF_EVENT.setErrorInfo(p_event, 'ERROR');
    		    RETURN 'ERROR';
END;


--=============================================================================+
--| Procedure                                                                  |
--|    update_elig_prgm_4_new_ptnr                                             |
--|                                                                            |
--| Parameters                                                                 |
--|    IN                                                                      |
--|    OUT                                                                     |
--|                                                                            |
--|                                                                            |
--| NOTES                                                                      |
--|                                                                            |
--| HISTORY                                                                    |
--|                                                                            |
--==============================================================================
PROCEDURE update_elig_prgm_4_new_ptnr(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level           IN   NUMBER		   := FND_API.g_valid_level_full
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_partner_id                 IN   NUMBER
   ,p_member_type                IN   VARCHAR2     := null
)
IS
   CURSOR c_get_program_info IS
      SELECT prg.program_id, prereq_process_rule_id
      FROM pv_partner_program_b prg
      WHERE prg.program_status_code = 'ACTIVE'
          AND prg.program_level_code = 'MEMBERSHIP'
          AND NVL(prg.allow_enrl_until_date, SYSDATE +1) >= SYSDATE
          AND prg.enabled_flag = 'Y';

   CURSOR c_get_prereq (c_program_id NUMBER) IS
      SELECT change_from_program_id
      FROM pv_pg_enrl_change_rules rule
      WHERE rule.change_to_program_id = c_program_id
            AND rule.change_direction_code = 'PREREQUISITE'
            AND rule.EFFECTIVE_FROM_DATE <= SYSDATE
            AND NVL(rule.EFFECTIVE_TO_DATE, SYSDATE+1) >= SYSDATE
            AND rule.ACTIVE_FLAG = 'Y';

   CURSOR c_is_no_prereq_membership(c_program_id NUMBER, c_partner_id NUMBER) IS
      SELECT 1
      FROM dual
      WHERE not exists(
         SELECT 1
         FROM pv_pg_memberships memb
         WHERE memb.program_id = c_program_id
            AND memb.partner_id = c_partner_id
            AND memb.MEMBERSHIP_STATUS_CODE = 'ACTIVE'
            AND memb.START_DATE <= SYSDATE
            AND NVL(memb.ACTUAL_END_DATE,NVL(memb.ORIGINAL_END_DATE,SYSDATE+1)) >= SYSDATE
      );

   CURSOR c_elig_program_id_seq IS
      SELECT PV_PG_ELIG_PROGRAMS_S.NEXTVAL
      FROM dual;

  l_api_name                      CONSTANT  VARCHAR2(30) := 'update_elig_prgm_4_new_ptnr';
  l_cnt                           NUMBER;
  l_partner_id                    NUMBER;
  l_member_type                   VARCHAR2(500);
  l_program_id_tbl                JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
  l_process_rule_id_tbl           JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
  l_rule_id_tbl                   JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
  l_attr_id_tbl                   JTF_NUMBER_TABLE;
  l_attr_evaluation_result_tbl    JTF_VARCHAR2_TABLE_100;
  l_partner_attr_value_tbl        JTF_VARCHAR2_TABLE_4000;
  l_evaluation_criteria_tbl       JTF_VARCHAR2_TABLE_4000;
  l_rule_pass_flag                VARCHAR2(4);
  l_delimiter                     VARCHAR2(10);
  l_user_id                       NUMBER := FND_GLOBAL.USER_ID();
  l_prereq_exist                  BOOLEAN;
  l_no_membership                 BOOLEAN;
  l_stmt_str			  VARCHAR2(4000);
  l_nextval                       NUMBER;

BEGIN
   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - start');
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   FOR x IN c_get_program_info LOOP
      l_prereq_exist := false;
      l_no_membership := false;
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('x.program_id = ' || x.program_id);
         PVX_UTILITY_PVT.debug_message('p_partner_id = ' || p_partner_id);
      END IF;
      FOR y IN c_get_prereq(x.program_id) LOOP
         l_prereq_exist := true;
         IF (PV_DEBUG_HIGH_ON) THEN
            PVX_UTILITY_PVT.debug_message('y.change_from_program_id = ' || y.change_from_program_id);
         END IF;
         FOR z IN c_is_no_prereq_membership(y.change_from_program_id, p_partner_id) LOOP
            l_no_membership := true;
            IF (PV_DEBUG_HIGH_ON) THEN
               PVX_UTILITY_PVT.debug_message('prereq exists but no active membership.');
            END IF;
         END LOOP;
         EXIT WHEN l_no_membership;
      END LOOP;
      IF ((l_prereq_exist and (not l_no_membership)) or (not l_prereq_exist)) THEN
         IF (x.prereq_process_rule_id IS NULL) THEN
               OPEN  c_elig_program_id_seq;
               FETCH c_elig_program_id_seq INTO l_nextval;
               CLOSE c_elig_program_id_seq;

               l_stmt_str := 'INSERT
                              INTO   pv_pg_elig_programs
                                     (
                                        ELIG_PROGRAM_ID,
                                        PROGRAM_ID,
                                        PARTNER_ID,
                                        ELIGIBILITY_CRIT_CODE,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        LAST_UPDATE_LOGIN ,
                                        OBJECT_Version_number
                                     )
                              VALUES
                                     (
                                        :1,
                                        :2,
                                        :3,
                                        :4,
                                        :5,
                                        :6,
                                        :7,
                                        :8,
                                        :9,
                                        :10
                                     )';

               EXECUTE IMMEDIATE l_stmt_str
               USING l_nextval,
                     x.program_id,
                     p_partner_id,
                     'PREREQ',
                     SYSDATE,
                     l_user_id,
                     SYSDATE,
                     l_user_id,
                     l_user_id,
                     1.0;

         ELSE
            l_rule_id_tbl.extend;
            l_rule_id_tbl(1) := x.prereq_process_rule_id;
            IF (PV_DEBUG_HIGH_ON) THEN
               PVX_UTILITY_PVT.debug_message('l_rule_id_tbl(1) = ' || l_rule_id_tbl(1));
            END IF;

            PV_RULE_EVALUATION_PUB.quick_partner_eval_outcome(
                p_api_version                    => p_api_version_number
               ,p_init_msg_list                  => FND_API.G_FALSE
               ,p_commit                         => FND_API.G_FALSE
               ,p_validation_level               => p_validation_level
               ,p_partner_id                     => p_partner_id
               ,p_rule_id_tbl                    => l_rule_id_tbl
               ,x_rule_pass_flag                 => l_rule_pass_flag
               ,x_return_status                  => x_return_status
               ,x_msg_count                      => x_msg_count
               ,x_msg_data                       => x_msg_data
            );

            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               IF (PV_DEBUG_HIGH_ON) THEN
                  PVX_UTILITY_PVT.debug_message('x_return_status = ' || x_return_status);
               END IF;
                  RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF (PV_DEBUG_HIGH_ON) THEN
               PVX_UTILITY_PVT.debug_message('l_rule_pass_flag = '||l_rule_pass_flag);
            END IF;

            IF (l_rule_pass_flag = 'PASS') THEN
               IF (PV_DEBUG_HIGH_ON) THEN
                  PVX_UTILITY_PVT.debug_message('PASS: x.program_id = '|| x.program_id);
                  PVX_UTILITY_PVT.debug_message('PASS: p_partner_id = '|| p_partner_id);
               END IF;
               OPEN c_elig_program_id_seq;
               FETCH c_elig_program_id_seq INTO l_nextval;
               CLOSE c_elig_program_id_seq;

               l_stmt_str := 'INSERT
                              INTO   pv_pg_elig_programs
                                     (
                                        ELIG_PROGRAM_ID,
                                        PROGRAM_ID,
                                        PARTNER_ID,
                                        ELIGIBILITY_CRIT_CODE,
                                        CREATION_DATE,
                                        CREATED_BY,
                                        LAST_UPDATE_DATE,
                                        LAST_UPDATED_BY,
                                        LAST_UPDATE_LOGIN ,
                                        OBJECT_Version_number
                                     )
                              VALUES
                                     (
                                        :1,
                                        :2,
                                        :3,
                                        :4,
                                        :5,
                                        :6,
                                        :7,
                                        :8,
                                        :9,
                                        :10
                                     )';

               EXECUTE IMMEDIATE l_stmt_str
               USING l_nextval,
                     x.program_id,
                     p_partner_id,
                     'PREREQ',
                     SYSDATE,
                     l_user_id,
                     SYSDATE,
                     l_user_id,
                     l_user_id,
                     1.0;
            END IF;
         END IF;
      END IF;
   END LOOP;

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' - end');
      END IF;
   END IF;

   FND_MSG_PUB.Count_And_Get (
         p_encoded => FND_API.G_FALSE,
         p_count   => x_msg_count,
         p_data    => x_msg_data
   );

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

EXCEPTION
   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
     THEN
        FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END update_elig_prgm_4_new_ptnr;

 END PV_USER_MGMT_PVT;

/
