--------------------------------------------------------
--  DDL for Package Body PVX_MISC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PVX_MISC_PVT" AS
/* $Header: pvxvmisb.pls 120.4 2008/01/17 00:52:46 hekkiral ship $ */



g_pkg_name           CONSTANT VARCHAR2(30):='PVX_Misc_PVT';



---------------------------------------------------------------------
-- PROCEDURE
--    Admin_Access
--
-- HISTORY
--    08/24/2000  Shitij Vatsa  Create.
--    03/12/2001  Shitij Vatsa  Update.
--                              In Admin_Access API changed the
--                              logic for the default sales group.
--                              It is now passed to the API from
--                              the UI.
--                              Search String : "BUG:1668567"
--    03/27/2001  Shitij Vatsa  Update
--                              In Admin_Access API further changed
--                              the logic for CM and phone support rep
--                              Sales_Group_ID. It is not defaulted
--                              from the UI now.
--                              Created a new cursor c_sales_group
--                              Search String : "BUG:1706709"
---------------------------------------------------------------------
PROCEDURE Admin_Access(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false
  ,p_validation_level  IN  NUMBER   := FND_API.g_valid_level_full

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_admin_rec         IN  admin_rec_type
  ,p_mode              IN  VARCHAR2
  ,x_access_id         OUT NOCOPY NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Admin_Access';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
   l_source_name VARCHAR2(25);

   l_return_status         VARCHAR2(1);
   -- Create record variables
   l_admin_rec       admin_rec_type := p_admin_rec;
   l_sales_team_rec  AS_ACCESS_PUB.sales_team_rec_type;

   l_object_version_number NUMBER := 1;

  -- For reference
  -- FND_API. return value constants
  -- G_RET_STS_SUCCESS     CONSTANT    VARCHAR2(1)	:=  'S';
  -- G_RET_STS_ERROR	   CONSTANT    VARCHAR2(1)	:=  'E';
  -- G_RET_STS_UNEXP_ERROR CONSTANT    VARCHAR2(1)	:=  'U';

  -- Cursor : c_resource_detail
  CURSOR c_resource_detail (cv_resource_id IN NUMBER) IS
  SELECT source_id,user_id, substr(source_name,1,20)
  FROM JTF_RS_RESOURCE_EXTNS
  WHERE resource_id = cv_resource_id;
    -- Cursor related variables
    l_source_id NUMBER;
    l_user_id   NUMBER;

/*
  -- Cursor : c_partner_detail
  CURSOR c_partner_detail (cv_partner_profile_id IN NUMBER) IS
  SELECT partner_party_id
  FROM PV_PARTNERS_V
  WHERE partner_profile_id = cv_partner_profile_id;
*/
  -- Cursor : c_partner_detail
  CURSOR c_partner_detail (cv_partner_profile_id IN NUMBER) IS
  SELECT partner_party_id
  FROM PV_PARTNER_PROFILES
  WHERE partner_profile_id = cv_partner_profile_id;


    -- Cursor records
    l_partner_party_id NUMBER;

  -- Cursor : c_party_site
  CURSOR c_party_site (cv_party_id IN NUMBER) IS
  SELECT party_site_id
  FROM HZ_PARTY_SITES
  WHERE party_id = cv_party_id
  AND identifying_address_flag = 'Y'
  AND NVL(start_date_active,SYSDATE) <= SYSDATE
  AND NVL(end_date_active,SYSDATE)   >= SYSDATE;
    -- Cursor records
    l_party_site_id NUMBER;

  -- "BUG:1706709"
  -- Cursor : c_sales_group
  CURSOR c_sales_group (cv_salesforce_id IN NUMBER) IS
  SELECT GRPREL.group_id
  FROM JTF_RS_RESOURCE_EXTNS RES ,JTF_RS_ROLE_RELATIONS RREL ,JTF_RS_ROLES_VL ROLE
      ,JTF_RS_GROUPS_TL GROUPS ,JTF_RS_GROUP_USAGES U ,JTF_RS_GROUP_MEMBERS GRPREL
  WHERE RES.category = 'EMPLOYEE' AND ROLE.role_type_code in ('SALES','TELESALES','FIELDSALES','PRM')
  AND RREL.role_id = ROLE.role_id AND GROUPS.language = userenv('LANG') AND GRPREL.group_id = GROUPS.group_id
  AND NVL(RREL.delete_flag,'N') = 'N' AND RREL.start_date_active <= sysdate
  AND NVL(RREL.end_date_active,sysdate) >= sysdate AND U.group_id = GRPREL.group_id
  AND U.usage = 'SALES' AND (ROLE.member_flag = 'Y' or ROLE.manager_flag='Y')
  AND RREL.role_resource_type = 'RS_GROUP_MEMBER' AND GRPREL.group_member_id = RREL.role_resource_id
  AND NVL(GRPREL.delete_flag,'N') = 'N' AND RES.resource_id = GRPREL.resource_id
  AND RES.resource_id = cv_salesforce_id;
    -- Cursor records
    l_group_id NUMBER;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT Admin_Access;

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;


  -------------------------- create --------------------------
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
     PVX_Utility_PVT.debug_message(l_full_name ||': create');
  END IF;



  -- If partner_profile_id IS NULL, raise an error
   IF l_admin_rec.partner_profile_id IS NULL THEN
     FND_MESSAGE.set_name('PV', 'PV_MISC_NO_PROFILE_ID');
     --FND_MESSAGE.set_token('ID',to_char(p_prtnr_prfls_rec.partner_id) );
     FND_MSG_PUB.add;
     x_return_status := FND_API.g_ret_sts_error;
     RAISE FND_API.g_exc_error;
   END IF;


  -- Get the Partner Details
  IF l_admin_rec.cm_id IS NOT NULL OR
    l_admin_rec.ph_support_rep IS NOT NULL OR
    l_admin_rec.cmm_id IS NOT NULL OR
    l_admin_rec.logged_resource_id IS NOT NULL THEN
    -- Get the partner details
    OPEN c_partner_detail(l_admin_rec.partner_profile_id);
    FETCH c_partner_detail INTO l_partner_party_id;
    CLOSE c_partner_detail;
  END IF;

  -- Get the party_site_id of the partner party
  OPEN c_party_site(l_partner_party_id);
  FETCH c_party_site INTO l_party_site_id;
  CLOSE c_party_site;


  -- Add Logged Resource to the Sales Team Access List
  IF l_admin_rec.logged_resource_id IS NOT NULL THEN

    -- Get the resource details
    OPEN c_resource_detail(l_admin_rec.logged_resource_id);
    FETCH c_resource_detail INTO l_source_id, l_user_id, l_source_name;
    CLOSE c_resource_detail;


    -- Populate the record
    l_sales_team_rec.salesforce_id := l_admin_rec.logged_resource_id;
    l_sales_team_rec.person_id := l_source_id;
    l_sales_team_rec.customer_id := l_partner_party_id;
    l_sales_team_rec.address_id := l_party_site_id;
    -- get the default group for the user
    --l_sales_team_rec.sales_group_id  := fnd_profile.value_specific('PV_DEFAULT_GROUP', l_user_id);
    -- "BUG:1668567"
    -- Update by svatsa on 03/09/2001
    -- This is holds good only for the logged resource and NOT for
    -- Channel manager or the Phone Support Rep
    l_sales_team_rec.sales_group_id  := l_admin_rec.group_id;

    --DBMS_OUTPUT.PUT_LINE('***** Logged Resource *****');
    --DBMS_OUTPUT.PUT_LINE('salesforce_id = '||to_char(l_sales_team_rec.salesforce_id));
    --DBMS_OUTPUT.PUT_LINE('person_id = '||to_char(l_sales_team_rec.person_id));
    --DBMS_OUTPUT.PUT_LINE('customer_id = '||to_char(l_sales_team_rec.customer_id));
    --DBMS_OUTPUT.PUT_LINE('address_id = '||to_char(l_sales_team_rec.address_id));
    --DBMS_OUTPUT.PUT_LINE('sales_group_id = '||to_char(l_sales_team_rec.sales_group_id));


    AS_ACCESS_PUB.Create_SalesTeam (
       p_api_version_number     => 2.0
      ,p_init_msg_list          => FND_API.g_true
--      ,p_commit                 => FND_API.g_true
      ,p_validation_level       => FND_API.g_valid_level_full

      ,p_access_profile_rec     => NULL
      ,p_check_access_flag      => 'N'
      ,p_admin_flag             => 'N'
      ,p_admin_group_id         => NULL
      ,p_identity_salesforce_id => NULL
      ,p_sales_team_rec         => l_sales_team_rec

      ,x_return_status          => x_return_status
      ,x_msg_count              => x_msg_count
      ,x_msg_data               => x_msg_data
      ,x_access_id              => x_access_id
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.set_name('PV', 'PV_MISC_ERROR_LOGD_RES_ID');
        FND_MESSAGE.set_token('ID',to_char(l_admin_rec.logged_resource_id) );
        FND_MSG_PUB.add;
      END IF;


      IF x_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

  END IF; -- IF logged_resource_id IS NOT NULL



  -- Add Channel Manager to the Sales Team Access List
  IF l_admin_rec.cm_id IS NOT NULL THEN

    -- Get the resource details
    OPEN c_resource_detail(l_admin_rec.cm_id);
    FETCH c_resource_detail INTO l_source_id, l_user_id, l_source_name;
    CLOSE c_resource_detail;

-- bug no 1651872 Chandra Sekhar.C

-- If user_id IS NULL, raise an error
 IF l_user_id IS NULL THEN
	FND_MESSAGE.set_name('PV', 'PV_NOT_VALID_USER');
	FND_MESSAGE.set_token('ENTITY',l_source_name );
	FND_MSG_PUB.add;
        x_return_status := FND_API.g_ret_sts_error;
        RAISE FND_API.g_exc_error;
 END IF;


-- end bug.



    -- Populate the record
    l_sales_team_rec.salesforce_id := l_admin_rec.cm_id;
    l_sales_team_rec.person_id := l_source_id;
    l_sales_team_rec.customer_id := l_partner_party_id;
    l_sales_team_rec.address_id := l_party_site_id;
    -- get the default group for the user
    --l_sales_team_rec.sales_group_id  := fnd_profile.value_specific('PV_DEFAULT_GROUP', l_user_id);
    -- Update by svatsa on 03/09/2001
    -- l_sales_team_rec.sales_group_id  := l_admin_rec.group_id;
    -- "BUG:1706709"; Since the above statement is not true for CM as it is selected from the LOV which
    -- already has a salesgroup_id, open the cursor to pass the sales_group_id
    -- corresponding to the resource_id of the CM.
    -- Updated on 03/27/2001

    -- Get the sales_group_id for the Channel Manager
    OPEN c_sales_group(l_admin_rec.cm_id);
    FETCH c_sales_group INTO l_group_id;
    CLOSE c_sales_group;

    l_sales_team_rec.sales_group_id  := l_group_id;

    --DBMS_OUTPUT.PUT_LINE('***** Channel Maneger *****');
    --DBMS_OUTPUT.PUT_LINE('salesforce_id = '||to_char(l_sales_team_rec.salesforce_id));
    --DBMS_OUTPUT.PUT_LINE('person_id = '||to_char(l_sales_team_rec.person_id));
    --DBMS_OUTPUT.PUT_LINE('customer_id = '||to_char(l_sales_team_rec.customer_id));
    --DBMS_OUTPUT.PUT_LINE('address_id = '||to_char(l_sales_team_rec.address_id));
    --DBMS_OUTPUT.PUT_LINE('sales_group_id = '||to_char(l_sales_team_rec.sales_group_id));


    AS_ACCESS_PUB.Create_SalesTeam (
       p_api_version_number     => 2.0
      ,p_init_msg_list          => FND_API.g_true
--      ,p_commit                 => FND_API.g_true
      ,p_validation_level       => FND_API.g_valid_level_full

      ,p_access_profile_rec     => NULL
      ,p_check_access_flag      => 'N'
      ,p_admin_flag             => 'N'
      ,p_admin_group_id         => NULL
      ,p_identity_salesforce_id => NULL
      ,p_sales_team_rec         => l_sales_team_rec

      ,x_return_status          => x_return_status
      ,x_msg_count              => x_msg_count
      ,x_msg_data               => x_msg_data
      ,x_access_id              => x_access_id
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.set_name('PV', 'PV_MISC_ERROR_CM_ID');
        FND_MESSAGE.set_token('ID',to_char(l_admin_rec.cm_id) );
        FND_MSG_PUB.add;
      END IF;


      IF x_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

  END IF; -- IF cm_id IS NOT NULL

  -- Add Phone Support Representative to the Sales Team Access List
  IF l_admin_rec.ph_support_rep IS NOT NULL THEN

    -- Get the resource details
    OPEN c_resource_detail(l_admin_rec.ph_support_rep);
    FETCH c_resource_detail INTO l_source_id, l_user_id, l_source_name;
    CLOSE c_resource_detail;

-- bug no. 1651872 Chandra Sekhar.C

-- If user_id IS NULL, raise an error
 IF l_user_id IS NULL THEN
	FND_MESSAGE.set_name('PV', 'PV_NOT_VALID_USER');
	FND_MESSAGE.set_token('ENTITY',l_source_name );
	FND_MSG_PUB.add;
    x_return_status := FND_API.g_ret_sts_error;
     RAISE FND_API.g_exc_error;
  END IF;


-- end bug.

    -- Populate the record
    l_sales_team_rec.salesforce_id := l_admin_rec.ph_support_rep;
    l_sales_team_rec.person_id := l_source_id;
    l_sales_team_rec.customer_id := l_partner_party_id;
    l_sales_team_rec.address_id := l_party_site_id;
    -- get the default group for the user
    --l_sales_team_rec.sales_group_id  := fnd_profile.value_specific('PV_DEFAULT_GROUP', l_user_id);
    -- Update by svatsa on 03/09/2001
    -- l_sales_team_rec.sales_group_id  := l_admin_rec.group_id;
    -- "BUG:1706709"; Since the above statement is not true for Phone Support rep as it is selected from the LOV which
    -- already has a salesgroup_id, open the cursor to pass the sales_group_id
    -- corresponding to the resource_id of the Phone Support Rep.
    -- Updated on 03/27/2001

    -- Get the sales_group_id for the Phone Support Rep
    OPEN c_sales_group(l_admin_rec.ph_support_rep);
    FETCH c_sales_group INTO l_group_id;
    CLOSE c_sales_group;

    l_sales_team_rec.sales_group_id  := l_group_id;

    --DBMS_OUTPUT.PUT_LINE('***** Sales Rep *****');
    --DBMS_OUTPUT.PUT_LINE('salesforce_id = '||to_char(l_sales_team_rec.salesforce_id));
    --DBMS_OUTPUT.PUT_LINE('person_id = '||to_char(l_sales_team_rec.person_id));
    --DBMS_OUTPUT.PUT_LINE('customer_id = '||to_char(l_sales_team_rec.customer_id));
    --DBMS_OUTPUT.PUT_LINE('address_id = '||to_char(l_sales_team_rec.address_id));
    --DBMS_OUTPUT.PUT_LINE('sales_group_id = '||to_char(l_sales_team_rec.sales_group_id));


    AS_ACCESS_PUB.Create_SalesTeam (
       p_api_version_number     => 2.0
      ,p_init_msg_list          => FND_API.g_true
--      ,p_commit                 => FND_API.g_true
      ,p_validation_level       => FND_API.g_valid_level_full

      ,p_access_profile_rec     => NULL
      ,p_check_access_flag      => 'N'
      ,p_admin_flag             => 'N'
      ,p_admin_group_id         => NULL
      ,p_identity_salesforce_id => NULL
      ,p_sales_team_rec         => l_sales_team_rec

      ,x_return_status          => x_return_status
      ,x_msg_count              => x_msg_count
      ,x_msg_data               => x_msg_data
      ,x_access_id              => x_access_id
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.set_name('PV', 'PV_MISC_ERROR_REP_ID');
        FND_MESSAGE.set_token('ID',to_char(l_admin_rec.ph_support_rep) );
        FND_MSG_PUB.add;
      END IF;

      IF x_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

  END IF; -- IF l_admin_rec.ph_support_rep IS NOT NULL

-- Begin Enh# 2188684 : by Achal.Anjaria
-- Add Channel Marketing Manager to the Sales Team Access List

  IF l_admin_rec.cmm_id IS NOT NULL THEN

    -- Get the resource details
    OPEN c_resource_detail(l_admin_rec.cmm_id);
    FETCH c_resource_detail INTO l_source_id, l_user_id, l_source_name;
    CLOSE c_resource_detail;

-- If user_id IS NULL, raise an error
 IF l_user_id IS NULL THEN
	FND_MESSAGE.set_name('PV', 'PV_NOT_VALID_USER');
	FND_MESSAGE.set_token('ENTITY',l_source_name );
	FND_MSG_PUB.add;
        x_return_status := FND_API.g_ret_sts_error;
        RAISE FND_API.g_exc_error;
 END IF;

    -- Populate the record
    l_sales_team_rec.salesforce_id := l_admin_rec.cmm_id;
    l_sales_team_rec.person_id := l_source_id;
    l_sales_team_rec.customer_id := l_partner_party_id;
    l_sales_team_rec.address_id := l_party_site_id;
    -- get the default group for the user
    -- Get the sales_group_id for the Channel Marketing Manager

    OPEN c_sales_group(l_admin_rec.cmm_id);
    FETCH c_sales_group INTO l_group_id;
    CLOSE c_sales_group;

    l_sales_team_rec.sales_group_id  := l_group_id;

    AS_ACCESS_PUB.Create_SalesTeam (
       p_api_version_number     => 2.0
      ,p_init_msg_list          => FND_API.g_true
--      ,p_commit                 => FND_API.g_true
      ,p_validation_level       => FND_API.g_valid_level_full

      ,p_access_profile_rec     => NULL
      ,p_check_access_flag      => 'N'
      ,p_admin_flag             => 'N'
      ,p_admin_group_id         => NULL
      ,p_identity_salesforce_id => NULL
      ,p_sales_team_rec         => l_sales_team_rec

      ,x_return_status          => x_return_status
      ,x_msg_count              => x_msg_count
      ,x_msg_data               => x_msg_data
      ,x_access_id              => x_access_id
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.set_name('PV', 'PV_MISC_ERROR_CMM_ID');
        FND_MESSAGE.set_token('ID',to_char(l_admin_rec.cmm_id) );
        FND_MSG_PUB.add;
      END IF;


      IF x_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

  END IF; -- IF cmm_id IS NOT NULL

  -- End Enh# 2188684
  ------------------------- finish -------------------------------


  -- Check for commit
    IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
    END IF;

  FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
  );

  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
     PVX_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;


EXCEPTION

    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Admin_Access;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Admin_Access;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );


    WHEN OTHERS THEN
      ROLLBACK TO Admin_Access;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

END Admin_Access;


---------------------------------------------------------------------
-- PROCEDURE
--    Complete_Admin_Rec
--
-- HISTORY
--    24/12/2002  svnathan  Create.
---------------------------------------------------------------------


PROCEDURE Complete_Admin_Rec (
    p_admin_rec IN  admin_rec_type
   ,x_complete_rec  OUT NOCOPY admin_rec_type
   )
IS
   l_return_status  VARCHAR2(1);

CURSOR c_complete IS
      SELECT jrre.resource_number,jrret.resource_name,jrre.source_name,jrre.source_org_id,
      jrre.source_first_name,jrre.source_last_name,jrre.source_middle_name
      FROM jtf_rs_resource_extns jrre ,jtf_rs_resource_extns_tl jrret
      WHERE jrre.resource_id = p_admin_rec.role_resource_id
      AND jrre.resource_id = jrret.resource_id ;

      l_admin_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_admin_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_admin_rec;
   CLOSE c_complete;

   -- resource number
   IF p_admin_rec.resource_number = FND_API.g_miss_num THEN
      x_complete_rec.resource_number := l_admin_rec.resource_number;
   END IF;

   -- resource name
   IF p_admin_rec.resource_name = FND_API.g_miss_char THEN
      x_complete_rec.resource_name := l_admin_rec.source_name;
   END IF;

   -- source name
   IF p_admin_rec.source_name = FND_API.g_miss_char THEN
      x_complete_rec.source_name := l_admin_rec.source_name;
   END IF;

   -- source org id
   IF p_admin_rec.source_org_id = FND_API.g_miss_num THEN
      x_complete_rec.source_org_id := l_admin_rec.source_org_id;
   END IF;

   -- first name
   IF p_admin_rec.source_first_name = FND_API.g_miss_char THEN
      x_complete_rec.source_first_name := l_admin_rec.source_first_name;
   END IF;

   -- last name
   IF p_admin_rec.source_last_name = FND_API.g_miss_char THEN
      x_complete_rec.source_last_name := l_admin_rec.source_last_name;
   END IF;


   -- middle name
   IF p_admin_rec.source_middle_name = FND_API.g_miss_char THEN
      x_complete_rec.source_middle_name := l_admin_rec.source_middle_name;
   END IF;

   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Admin_Rec;











---------------------------------------------------------------------
-- PROCEDURE
--    Admin_Resource
--
-- HISTORY
--    09/07/2000  Shitij Vatsa  Create.
--    10/05/2001  shitij.vatsa  Updated:
--                              1. Removed CREATE_RESOURCE_GROUP_MEMBER
--                                 because Admin_Group_Member does
--                                 the same function.
--                              2. Modified the record type admin_rec_type
--                                 with two new values source_name and resource_name
--                                 Which are now required for resource creation in
--                                 Admin_Resource.
--    04-SEP-2001 shitij.vatsa  Updated:
--                              1. Modified the record type admin_rec_type
--                                 with : user_name, source_first_name,
--                                 source_middle_name and source_last_name.
--                              2. Get the address of the source_id and populate the
--                                 address fields.
---------------------------------------------------------------------
PROCEDURE Admin_Resource(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_admin_rec         IN  admin_rec_type
  ,p_mode              IN  VARCHAR2
  ,x_resource_id       OUT NOCOPY NUMBER
  ,x_resource_number   OUT NOCOPY VARCHAR2
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Admin_Resource';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status         VARCHAR2(1);
   -- Create record variables
   l_admin_rec       admin_rec_type := p_admin_rec;
   l_admin_complete_rec   admin_rec_type ;
   l_resource_id     NUMBER;
   l_resource_number VARCHAR2(30);
   l_version_no NUMBER;

  -- Cursor : cur_resource_address
  CURSOR cur_resource_address (curvar_party_site_id IN NUMBER) IS
    SELECT
       HZL.address1
      ,HZL.address2
      ,HZL.address3
      ,HZL.address4
      ,HZL.city
      ,HZL.postal_code
      ,HZL.state
      ,HZL.province
      ,HZL.county
      ,HZL.country
    FROM hz_party_sites HZPS
        ,hz_locations HZL
    WHERE
          HZPS.location_id = HZL.location_id(+)
      AND HZPS.identifying_address_flag(+) = 'Y'
      AND HZPS.party_site_id = curvar_party_site_id;

    -- Cursor Record Type
      currec_resource_address cur_resource_address%ROWTYPE;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT Admin_Resource;

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;


  -------------------------- create --------------------------
    /*
    -- If the source_name is null then error out
    IF l_admin_rec.source_name IS NULL THEN
      FND_MESSAGE.set_name('PV', 'PV_MISC_NO_SOURCE_NAME');
      FND_MESSAGE.set_token('ID',to_char(l_admin_rec.partner_id) );
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    END IF;
    */

    -- Get the address for the resource
    OPEN cur_resource_address(l_admin_rec.party_site_id);
    FETCH cur_resource_address INTO currec_resource_address;

    --DBMS_OUTPUT.PUT_LINE('currec_resource_address.address1 = '||currec_resource_address.address1);
    --DBMS_OUTPUT.PUT_LINE('currec_resource_address.city = '||currec_resource_address.city);
    --DBMS_OUTPUT.PUT_LINE('currec_resource_address.postal_code = '||currec_resource_address.postal_code);
    --DBMS_OUTPUT.PUT_LINE('currec_resource_address.state = '||currec_resource_address.state);
    --DBMS_OUTPUT.PUT_LINE('currec_resource_address.country = '||currec_resource_address.country);



    -- Call the resource API to create the resource
    if (p_mode <> 'UPDATE') then

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        PVX_Utility_PVT.debug_message(l_full_name ||': create');
      END IF;

    JTF_RS_RESOURCE_PUB.Create_Resource(
       p_api_version        => 1.0
      ,p_init_msg_list      => FND_API.g_false
  --    ,p_commit             => FND_API.g_true
      ,x_return_status      => x_return_status
      ,x_msg_count          => x_msg_count
      ,x_msg_data           => x_msg_data

      ,p_category           => l_admin_rec.resource_type
      ,p_source_id          => l_admin_rec.partner_id           -- source_id
      ,p_user_id            => l_admin_rec.user_id              -- user_id
      ,p_source_name        => l_admin_rec.source_name          -- source_name
      ,p_resource_name      => l_admin_rec.resource_name        -- resource_name
      ,p_source_org_name    => l_admin_rec.source_org_name      -- source_org_name
      ,p_source_org_id	    => l_admin_rec.source_org_id        -- source_org_id
      ,p_contact_id         => l_admin_rec.contact_id
      ,p_start_date_active  => SYSDATE
  --    ,p_address_id         => l_admin_rec.party_site_id
      ,p_source_address1    => currec_resource_address.address1
      ,p_source_address2    => currec_resource_address.address2
      ,p_source_address3    => currec_resource_address.address3
      ,p_source_address4    => currec_resource_address.address4
      ,p_source_city        => currec_resource_address.city
      ,p_source_postal_code => currec_resource_address.postal_code
      ,p_source_state       => currec_resource_address.state
      ,p_source_province    => currec_resource_address.province
      ,p_source_county      => currec_resource_address.county
      ,p_source_country     => currec_resource_address.country

      ,p_user_name          => l_admin_rec.user_name
      ,p_source_first_name  => l_admin_rec.source_first_name
      ,p_source_middle_name => l_admin_rec.source_middle_name
      ,p_source_last_name   => l_admin_rec.source_last_name


      ,x_resource_id        => x_resource_id
      ,x_resource_number    => x_resource_number
      );

      elsif (p_mode = 'UPDATE') then

      Complete_Admin_Rec (
       p_admin_rec  =>l_admin_rec
      ,x_complete_rec =>l_admin_complete_rec
      );

    JTF_RS_RESOURCE_PUB.Update_Resource(
       p_api_version        => 1.0
      ,p_init_msg_list      => FND_API.g_false
      ,p_resource_id        => l_admin_complete_rec.role_resource_id
      ,p_resource_number    => l_admin_complete_rec.resource_number
--    ,p_start_date_active  => SYSDATE
--    ,p_end_date_active    => FND_API.g_miss_date
      ,p_resource_name      => l_admin_complete_rec.resource_name        -- resource_name
      ,p_source_name        => l_admin_complete_rec.source_name          -- source_name

      ,p_source_org_id	    => l_admin_complete_rec.source_org_id        -- source_org_id
    /*,p_source_org_name    => l_admin_complete_rec.source_org_name      -- source_org_name
      ,p_source_address1    => currec_resource_address.address1
      ,p_source_address2    => currec_resource_address.address2
      ,p_source_address3    => currec_resource_address.address3
      ,p_source_address4    => currec_resource_address.address4
      ,p_source_city        => currec_resource_address.city
      ,p_source_postal_code => currec_resource_address.postal_code
      ,p_source_state       => currec_resource_address.state
      ,p_source_province    => currec_resource_address.province
      ,p_source_county      => currec_resource_address.county
      ,p_source_country     => currec_resource_address.country
      */
      ,p_source_first_name  => l_admin_complete_rec.source_first_name
      ,p_source_last_name   => l_admin_complete_rec.source_last_name
      ,p_source_middle_name => l_admin_complete_rec.source_middle_name
    --,p_source_category    => l_admin_complete_rec.resource_type
    --,p_source_id          => l_admin_complete_rec.partner_id           -- source_id
    --,p_user_id            => l_admin_complete_rec.user_id              -- user_id
    --,p_contact_id         => l_admin_complete_rec.contact_id
    --,p_address_id         => l_admin_complete_rec.party_site_id
      ,p_object_version_num  => l_admin_complete_rec.object_version_number
    --,p_user_name          => l_admin_complete_rec.user_name
      ,x_return_status      => x_return_status
      ,x_msg_count          => x_msg_count
      ,x_msg_data           => x_msg_data

      );

    end if;



    CLOSE cur_resource_address;

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
    PVX_Utility_PVT.debug_message(l_full_name ||': x_return_status : ' || x_return_status);
    PVX_Utility_PVT.debug_message(l_full_name ||': x_msg_count : ' || x_msg_count);
    PVX_Utility_PVT.debug_message(l_full_name ||': x_msg_data : ' || x_msg_data);
  END IF;


      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.set_name('PV', 'PV_MISC_ERROR_RES_CREATION');
        FND_MESSAGE.set_token('ID',to_char(l_admin_rec.partner_id) );
        FND_MSG_PUB.add;
      END IF;

      IF x_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

  ------------------------- finish -------------------------------


  -- Check for commit
    IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
    END IF;

  FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
  );

  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
    PVX_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;

EXCEPTION

    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Admin_Resource;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Admin_Resource;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );


    WHEN OTHERS THEN
      ROLLBACK TO Admin_Resource;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

END Admin_Resource;

---------------------------------------------------------------------
-- PROCEDURE
--    Admin_Role
--
-- HISTORY
--    09/07/2000  Shitij Vatsa  Create.
---------------------------------------------------------------------
PROCEDURE Admin_Role(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_admin_rec         IN  admin_rec_type
  ,p_mode              IN  VARCHAR2
  ,x_role_relate_id    OUT NOCOPY NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Admin_Role';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status         VARCHAR2(1);
   -- Create record variables
   l_admin_rec       admin_rec_type := p_admin_rec;

  -- Cursor : c_role_detail
  CURSOR c_role_detail (cv_role_code IN VARCHAR2) IS
  SELECT role_id
  FROM JTF_RS_ROLES_VL
  WHERE role_code = cv_role_code;
    -- Cursor related variables
    l_role_id NUMBER;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT Admin_Role;

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;


  -------------------------- create resource role relate --------------------------
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
    PVX_Utility_PVT.debug_message(l_full_name ||': Create_Resource_Role_Relate');
  END IF;

    -- Get the role detail
    OPEN c_role_detail(l_admin_rec.role_code);
    FETCH c_role_detail INTO l_role_id;
    CLOSE c_role_detail;


    -- Call the resource API to create the resource
    JTF_RS_ROLE_RELATE_PUB.Create_Resource_Role_Relate(
       p_api_version        => 1.0
      ,p_init_msg_list      => FND_API.g_false
--      ,p_commit             => FND_API.g_true
      ,x_return_status      => x_return_status
      ,x_msg_count          => x_msg_count
      ,x_msg_data           => x_msg_data

      ,p_role_resource_type => l_admin_rec.role_resource_type
      ,p_role_resource_id   => l_admin_rec.role_resource_id
      ,p_role_id            => l_role_id
      ,p_role_code          => l_admin_rec.role_code
      ,p_start_date_active  => SYSDATE

      ,x_role_relate_id     => x_role_relate_id

      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.set_name('PV', 'PV_MISC_ERROR_ROLE_RELATE');
        FND_MESSAGE.set_token('ID',to_char(l_admin_rec.role_resource_id));
        FND_MSG_PUB.add;
      END IF;

      IF x_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

  ------------------------- finish -------------------------------


  -- Check for commit
    IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
    END IF;

  FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
  );

  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
    PVX_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;

EXCEPTION

    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Admin_Role;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Admin_Role;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );


    WHEN OTHERS THEN
      ROLLBACK TO Admin_Role;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

END Admin_Role;

---------------------------------------------------------------------
-- PROCEDURE
--    Admin_Group
--
-- HISTORY
--    10/10/2000  Shitij Vatsa  Create.
---------------------------------------------------------------------
PROCEDURE Admin_Group(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_admin_rec         IN  admin_rec_type
  ,p_mode              IN  VARCHAR2
  ,x_group_id          OUT NOCOPY NUMBER
  ,x_group_number      OUT NOCOPY VARCHAR2
  ,x_group_usage_id    OUT NOCOPY NUMBER
  ,x_group_member_id   OUT NOCOPY NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Admin_Group';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status         VARCHAR2(1);

   -- Create record variables
   l_admin_rec       admin_rec_type := p_admin_rec;

   -- Initialize the group name : 'PRM_GRP' plus the passed partner_id
   --l_group_name  VARCHAR2(30) := 'PRM_GRP'||TO_CHAR(l_admin_rec.partner_id);

  -- Cursor : c_party_detail
  CURSOR c_party_detail (cv_partner_id IN NUMBER) IS
  SELECT SUBSTR(party_name,1,80)
  FROM hz_parties
  WHERE party_id = cv_partner_id;
    -- Cursor related variables
    l_group_desc VARCHAR2(240);


  -- Cursor : c_party_name
  CURSOR c_party_name (cv_partner_id IN NUMBER) IS
  SELECT SUBSTRB(PARTNER.party_name,1,44)||'('||PARTNER.party_id||')'
  FROM hz_relationships HZR, hz_parties PARTNER, hz_organization_profiles HZOP
  WHERE HZR.party_id = cv_partner_id
  AND   HZR.subject_id = PARTNER.party_id
  AND   PARTNER.party_id = HZOP.party_id
  AND   NVL(HZOP.internal_flag,'N') = 'N'
  AND   HZOP.effective_end_date IS NULL;
    -- Cursor related variables
    l_group_name VARCHAR2(60);

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT Admin_Group;

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;


  -------------------------- create resource group --------------------------
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
    PVX_Utility_PVT.debug_message(l_full_name ||': Create_Resource_Group');
  END IF;

    -- Get the party detail
    OPEN c_party_detail(l_admin_rec.partner_id);
    FETCH c_party_detail INTO l_group_desc;
    CLOSE c_party_detail;

    -- Get the party name
    OPEN c_party_name(l_admin_rec.partner_id);
    FETCH c_party_name INTO l_group_name;
--    CLOSE c_party_name;

   -- Fix for the bug # 2535467 begin

    IF c_party_name%NOTFOUND THEN
      CLOSE c_party_name;
      FND_MESSAGE.set_name('PV', 'PV_DENY_INTERNAL_ORG_PROFILE');
      FND_MSG_PUB.add;
      RAISE FND_API.g_exc_error;
    ELSE
      CLOSE c_party_name;
    END IF;

    -- Fix for the bug # 2535467 end

    -- Call the Create_Resource_Group API to create the Group

    JTF_RS_GROUPS_PUB.Create_Resource_Group(
       p_api_version        => 1.0
      ,p_init_msg_list      => FND_API.g_false
--      ,p_commit             => FND_API.g_true
      ,x_return_status      => x_return_status
      ,x_msg_count          => x_msg_count
      ,x_msg_data           => x_msg_data

      ,p_group_name         => l_group_name
      ,p_group_desc         => l_group_desc
      ,p_start_date_active  => SYSDATE
      ,x_group_id           => x_group_id
      ,x_group_number       => x_group_number
      );
--DBMS_OUTPUT.PUT_LINE('x_group_id : '||TO_CHAR(x_group_id));

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.set_name('PV', 'PV_MISC_ERROR_GROUP_CREATE');
        FND_MESSAGE.set_token('ID',to_char(l_admin_rec.partner_id));
        FND_MSG_PUB.add;
      END IF;

      IF x_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

  -------------------------- create group usage --------------------------
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
    PVX_Utility_PVT.debug_message(l_full_name ||': Create_Group_Usage');
  END IF;

    -- Call the Create_Group_Usage API to create the Group Usage
    JTF_RS_GROUP_USAGES_PUB.Create_Group_Usage(
       p_api_version        => 1.0
      ,p_init_msg_list      => FND_API.g_false
--      ,p_commit             => FND_API.g_true
      ,x_return_status      => x_return_status
      ,x_msg_count          => x_msg_count
      ,x_msg_data           => x_msg_data

      ,p_group_id           => x_group_id
      ,p_group_number       => x_group_number
      ,p_usage              => 'PRM'
      ,x_group_usage_id     => x_group_usage_id
      );

--DBMS_OUTPUT.PUT_LINE('x_group_usage_id : '||TO_CHAR(x_group_usage_id));

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.set_name('PV', 'PV_MISC_ERROR_GROUP_USAGE');
        FND_MESSAGE.set_token('ID',to_char(x_group_id));
        FND_MSG_PUB.add;
      END IF;

      IF x_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

  -------------------------- create resource group member --------------------------
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
    PVX_Utility_PVT.debug_message(l_full_name ||': Create_Resource_Group_Members');
  END IF;

    -- Call the Create_Group_Usage API to create the Group Usage
    JTF_RS_GROUP_MEMBERS_PUB.Create_Resource_Group_Members(
       p_api_version        => 1.0
      ,p_init_msg_list      => FND_API.g_false
--      ,p_commit             => FND_API.g_true
      ,x_return_status      => x_return_status
      ,x_msg_count          => x_msg_count
      ,x_msg_data           => x_msg_data

      ,p_group_id           => x_group_id
      ,p_group_number       => x_group_number
      ,p_resource_id        => l_admin_rec.role_resource_id
      ,p_resource_number    => l_admin_rec.resource_number
      ,x_group_member_id    => x_group_member_id
      );

--DBMS_OUTPUT.PUT_LINE('x_group_member_id : '||TO_CHAR(x_group_member_id));

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.set_name('PV', 'PV_MISC_ERROR_GROUP_MEMBER');
        FND_MESSAGE.set_token('ID1',to_char(l_admin_rec.role_resource_id));
        FND_MESSAGE.set_token('ID2',to_char(x_group_id));
        FND_MSG_PUB.add;
      END IF;

      IF x_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;



  ------------------------- finish -------------------------------


  -- Check for commit
    IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
    END IF;

  FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
  );

  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
    PVX_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;

EXCEPTION

    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Admin_Group;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Admin_Group;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );


    WHEN OTHERS THEN
      ROLLBACK TO Admin_Group;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );
END Admin_Group;

---------------------------------------------------------------------
-- PROCEDURE
--    Admin_Group_Member
--
-- HISTORY
--    10/11/2000  Shitij Vatsa  Create.
---------------------------------------------------------------------
PROCEDURE Admin_Group_Member(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
  ,p_commit            IN  VARCHAR2 := FND_API.g_false

  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2

  ,p_admin_rec         IN  admin_rec_type
  ,p_mode              IN  VARCHAR2
  ,x_group_member_id   OUT NOCOPY NUMBER
)
IS

   l_api_version CONSTANT NUMBER       := 1.0;
   l_api_name    CONSTANT VARCHAR2(30) := 'Admin_Group_Member';
   l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

   l_return_status         VARCHAR2(1);
   -- Create record variables
   l_admin_rec       admin_rec_type := p_admin_rec;

  -- Cursor : c_role_detail
  CURSOR c_role_detail (cv_role_code IN VARCHAR2) IS
  SELECT role_id
  FROM JTF_RS_ROLES_VL
  WHERE role_code = cv_role_code;
    -- Cursor related variables
    l_role_id NUMBER;

BEGIN

   --------------------- initialize -----------------------
   SAVEPOINT Admin_Group_Member;

   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name||': start');
   END IF;

   IF FND_API.to_boolean(p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;

   IF NOT FND_API.compatible_api_call(
         l_api_version,
         p_api_version,
         l_api_name,
         g_pkg_name
   ) THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   x_return_status := FND_API.g_ret_sts_success;


  -------------------------- create resource group member --------------------------
  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
    PVX_Utility_PVT.debug_message(l_full_name ||': Create_Resource_Group_Members');
  END IF;

    -- Call the Create_Group_Usage API to create the Group Usage
    JTF_RS_GROUP_MEMBERS_PUB.Create_Resource_Group_Members(
       p_api_version        => 1.0
      ,p_init_msg_list      => FND_API.g_false
--      ,p_commit             => FND_API.g_true
      ,x_return_status      => x_return_status
      ,x_msg_count          => x_msg_count
      ,x_msg_data           => x_msg_data

      ,p_group_id           => l_admin_rec.group_id
      ,p_group_number       => l_admin_rec.group_number
      ,p_resource_id        => l_admin_rec.role_resource_id
      ,p_resource_number    => l_admin_rec.resource_number
      ,x_group_member_id    => x_group_member_id
      );


      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        FND_MESSAGE.set_name('PV', 'PV_MISC_ERROR_GROUP_MEMBER');
        FND_MESSAGE.set_token('ID1',to_char(l_admin_rec.role_resource_id));
        FND_MESSAGE.set_token('ID2',to_char(l_admin_rec.group_id));
        FND_MSG_PUB.add;
      END IF;

      IF x_return_status = FND_API.g_ret_sts_error THEN
        RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
        RAISE FND_API.g_exc_unexpected_error;
      END IF;

  ------------------------- finish -------------------------------


  -- Check for commit
    IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
    END IF;

  FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false,
         p_count   => x_msg_count,
         p_data    => x_msg_data
  );

  IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
    PVX_Utility_PVT.debug_message(l_full_name ||': end');
  END IF;

EXCEPTION

    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO Admin_Group_Member;
      x_return_status := FND_API.g_ret_sts_error;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );

    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO Admin_Group_Member;
      x_return_status := FND_API.g_ret_sts_unexp_error ;
      FND_MSG_PUB.count_and_get (
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );


    WHEN OTHERS THEN
      ROLLBACK TO Admin_Group_Member;
      x_return_status := FND_API.g_ret_sts_unexp_error ;

      IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
		THEN
         FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
      END IF;

      FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_msg_count
          ,p_data    => x_msg_data
          );
END Admin_Group_Member;


---------------------------------------------------------------------
-- PROCEDURE
--    Update_User
--
-- HISTORY
---------------------------------------------------------------------
  PROCEDURE Update_User(
     p_api_version       IN  NUMBER
    ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
    ,p_commit            IN  VARCHAR2 := FND_API.g_false
    ,x_return_status     OUT NOCOPY VARCHAR2
    ,x_msg_count         OUT NOCOPY NUMBER
    ,x_msg_data          OUT NOCOPY VARCHAR2
    ,p_fnd_rec           IN  fnd_rec_type

  )
  IS

     l_api_version CONSTANT NUMBER       := 1.0;
     l_api_name    CONSTANT VARCHAR2(30) := 'Update_User';
     l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

     l_return_status         VARCHAR2(1);
     -- Create record variables
     l_fnd_rec       fnd_rec_type := p_fnd_rec;

     l_object_version_number NUMBER := 1;
     l_owner    VARCHAR2(10) := 'PRM';

    -- For reference
    -- FND_API. return value constants
    -- G_RET_STS_SUCCESS     CONSTANT    VARCHAR2(1)	:=  'S';
    -- G_RET_STS_ERROR	   CONSTANT    VARCHAR2(1)	:=  'E';
    -- G_RET_STS_UNEXP_ERROR CONSTANT    VARCHAR2(1)	:=  'U';



  BEGIN

     --------------------- initialize -----------------------
     SAVEPOINT Update_User;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        PVX_Utility_PVT.debug_message(l_full_name||': start');
     END IF;

     IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
     END IF;

     IF NOT FND_API.compatible_api_call(
           l_api_version,
           p_api_version,
           l_api_name,
           g_pkg_name
     ) THEN
        RAISE FND_API.g_exc_unexpected_error;
     END IF;

     x_return_status := FND_API.g_ret_sts_success;


    -------------------------- create --------------------------
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name ||': create');
    END IF;


    -- If user_name IS NULL, raise an error
     IF l_fnd_rec.user_name IS NULL THEN
       FND_MESSAGE.set_name('PV', 'PV_FND_NO_USER_NAME');
       FND_MSG_PUB.add;
       x_return_status := FND_API.g_ret_sts_error;
       RAISE FND_API.g_exc_error;
     END IF;



      FND_USER_PKG.UpdateUser
      (
           X_USER_NAME           => l_fnd_rec.user_name
          ,X_OWNER               => l_owner
          ,X_END_DATE            => l_fnd_rec.end_date
          ,X_EMAIL_ADDRESS       => l_fnd_rec.email_address
      );

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          FND_MESSAGE.set_name('PV', 'PV_ERROR_UPDATE_USER');
          FND_MSG_PUB.add;
        END IF;


        IF x_return_status = FND_API.g_ret_sts_error THEN
          RAISE FND_API.g_exc_error;
        ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
          RAISE FND_API.g_exc_unexpected_error;
        END IF;

     -- Check for commit
      IF FND_API.to_boolean(p_commit) THEN
        COMMIT;
      END IF;

    FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false,
           p_count   => x_msg_count,
           p_data    => x_msg_data
    );

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name ||': end');
    END IF;

  EXCEPTION

      WHEN FND_API.g_exc_error THEN
        ROLLBACK TO Update_User;
        x_return_status := FND_API.g_ret_sts_error;
        FND_MSG_PUB.count_and_get (
             p_encoded => FND_API.g_false
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

      WHEN FND_API.g_exc_unexpected_error THEN
        ROLLBACK TO Update_User;
        x_return_status := FND_API.g_ret_sts_unexp_error ;
        FND_MSG_PUB.count_and_get (
             p_encoded => FND_API.g_false
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );


      WHEN OTHERS THEN
        ROLLBACK TO Update_User;
        x_return_status := FND_API.g_ret_sts_unexp_error ;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
  		THEN
           FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        END IF;

        FND_MSG_PUB.count_and_get(
             p_encoded => FND_API.g_false
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

    END Update_User;

  ---------------------------------------------------------------------
  -- PROCEDURE
  --    Disable_Responsibility
  --
  -- HISTORY
  --    18/05/2001  Shitij Vatsa  Create.
  ---------------------------------------------------------------------
  PROCEDURE Disable_Responsibility(
     p_api_version       IN  NUMBER
    ,p_init_msg_list     IN  VARCHAR2 := FND_API.g_false
    ,p_commit            IN  VARCHAR2 := FND_API.g_false

    ,x_return_status     OUT NOCOPY VARCHAR2
    ,x_msg_count         OUT NOCOPY NUMBER
    ,x_msg_data          OUT NOCOPY VARCHAR2

    ,p_fnd_rec           IN  fnd_rec_type
    ,p_mode              IN  VARCHAR2
  )
  IS

    l_api_version CONSTANT NUMBER       := 1.0;
    l_api_name    CONSTANT VARCHAR2(30) := 'Disable_Responsibility';
    l_full_name   CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;

    l_return_status         VARCHAR2(1);
    -- Create record variables
    l_fnd_rec       fnd_rec_type := p_fnd_rec;


    -- Define API cursors

    -- Cursor : cur_user_resp_detail
    CURSOR cur_user_resp_detail (cv_user_id     IN NUMBER
                                ,cv_resp_id     IN NUMBER
                                ,cv_resp_app_id IN NUMBER) IS
    SELECT FNDU.user_name
          ,FNDR.responsibility_key
  	    ,FNDSG.security_group_key
    FROM   fnd_user FNDU, fnd_responsibility FNDR, fnd_user_resp_groups FNDURG, fnd_security_groups FNDSG
    WHERE  FNDU.user_id             = cv_user_id
    AND    FNDR.responsibility_id   = cv_resp_id
    AND    FNDR.application_id      = cv_resp_app_id
    AND    FNDU.user_id             = FNDURG.user_id
    AND    FNDR.responsibility_id   = FNDURG.responsibility_id
    AND    FNDR.application_id      = FNDURG.responsibility_application_id
    AND    FNDURG.security_group_id = FNDSG.security_group_id
    ;
      -- Cursor Record
      l_crec_user_resp_detail cur_user_resp_detail%ROWTYPE;

  BEGIN

     --------------------- initialize -----------------------
     SAVEPOINT Disable_Responsibility;

     IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
        PVX_Utility_PVT.debug_message(l_full_name||': start');
     END IF;

     IF FND_API.to_boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
     END IF;

     IF NOT FND_API.compatible_api_call(
           l_api_version,
           p_api_version,
           l_api_name,
           g_pkg_name
     ) THEN
        RAISE FND_API.g_exc_unexpected_error;
     END IF;

     x_return_status := FND_API.g_ret_sts_success;


    -------------------------- create --------------------------
    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name ||': create');
    END IF;


    -- Get the user and responsibility details
    OPEN cur_user_resp_detail(l_fnd_rec.user_id
                             ,l_fnd_rec.resp_id
                             ,l_fnd_rec.resp_app_id);
    FETCH cur_user_resp_detail INTO l_crec_user_resp_detail;
    CLOSE cur_user_resp_detail;

    -- Call the FND API to disable the user responsibility mapping.
    -- You need to pass the following mandatory parameters
    --  username:       User Name
    --  resp_app:       Application Short Name
    --  resp_key:       Responsibility Key
    --  security_group: Security Group Key

    FND_USER_PKG.DelResp(
        username       => l_crec_user_resp_detail.user_name
       ,resp_app       => l_fnd_rec.resp_app_short_name -- Application_Short_name from POL (Partners On-Line)
       ,resp_key       => l_crec_user_resp_detail.responsibility_key
       ,security_group => l_crec_user_resp_detail.security_group_key
       );



    ------------------------- finish -------------------------------


    -- Check for commit
      IF FND_API.to_boolean(p_commit) THEN
        COMMIT;
      END IF;

    FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false,
           p_count   => x_msg_count,
           p_data    => x_msg_data
    );

    IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
      PVX_Utility_PVT.debug_message(l_full_name ||': end');
    END IF;

  EXCEPTION

      WHEN FND_API.g_exc_error THEN
        ROLLBACK TO Disable_Responsibility;
        x_return_status := FND_API.g_ret_sts_error;
        FND_MSG_PUB.count_and_get (
             p_encoded => FND_API.g_false
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

      WHEN FND_API.g_exc_unexpected_error THEN
        ROLLBACK TO Disable_Responsibility;
        x_return_status := FND_API.g_ret_sts_unexp_error ;
        FND_MSG_PUB.count_and_get (
             p_encoded => FND_API.g_false
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );


      WHEN OTHERS THEN
        ROLLBACK TO Disable_Responsibility;
        x_return_status := FND_API.g_ret_sts_unexp_error ;

        IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_unexp_error)
  		THEN
           FND_MSG_PUB.add_exc_msg(g_pkg_name, l_api_name);
        END IF;

        FND_MSG_PUB.count_and_get(
             p_encoded => FND_API.g_false
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

  END Disable_Responsibility;

  ---------------------------------------------------------------------
  -- PROCEDURE
  --    Update_Partner_Status
  --
  -- HISTORY
  --    04-JUL-2003  Narasimha Ramu  Create.
  ---------------------------------------------------------------------
  PROCEDURE update_partner_status (
    ERRBUF      OUT NOCOPY   VARCHAR2,
    RETCODE     OUT NOCOPY   VARCHAR2 ) IS

    CURSOR c_partners IS
      SELECT *
        FROM pv_partner_profiles
        Where status <> 'M'; -- hekkiral for bug fix 6694939. Merged records
 	                     --  should not be touched.

    CURSOR c_relationship_status (p_party_id IN NUMBER, p_partner_party_id IN NUMBER) IS
      SELECT subject_id vendor_party_id,
             start_date,
             end_date,
             status
        FROM hz_relationships
        WHERE party_id = p_party_id
          AND object_id = p_partner_party_id;

    CURSOR c_party_status (p_party_id IN NUMBER) IS
      SELECT NVL(status, 'A') party_status
        FROM hz_parties
        WHERE party_id = p_party_id;

    CURSOR c_resource_status (p_resource_id IN NUMBER) IS
      SELECT start_date_active,
             end_date_active
        FROM jtf_rs_resource_extns
        WHERE resource_id = p_resource_id;

    CURSOR c_party_name (p_party_id IN NUMBER) IS
      SELECT SUBSTRB(party_name, 1, 100) partner_name,
             party_number partner_number
        FROM hz_parties
        WHERE party_id = p_party_id;

    l_vendor_party_id   NUMBER;
    l_start_date        DATE;
    l_end_date          DATE;
    l_status            VARCHAR2(1);
    l_new_partner_status VARCHAR2(1);
    l_api_version CONSTANT NUMBER := 1.0;
    l_return_status      VARCHAR2(1);
    l_msg_count          NUMBER;
    l_prtnr_prfls_rec    PVX_PRTNR_PRFLS_PVT.prtnr_prfls_rec_type;
    l_message            VARCHAR2(32000);
    l_msg_data		 VARCHAR2(32000);
    l_total_partners     NUMBER := 0;
    l_error_partners     NUMBER := 0;
    l_partner_name       VARCHAR2(360);
    l_partner_number     VARCHAR2(30);

  BEGIN

    FND_MESSAGE.SET_NAME( application => 'PV'
                          ,name        => 'PV_PARTNER_STATUS_BATCH_START');

    FND_MESSAGE.SET_TOKEN( token   => 'P_DATE_TIME'
                           ,value   =>  TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') );

    FND_FILE.PUT_LINE( FND_FILE.LOG,  fnd_message.get );
    FND_FILE.NEW_LINE( FND_FILE.LOG,  1 );


    l_return_status := FND_API.G_RET_STS_SUCCESS ;

    FOR l_partners_rec in c_partners LOOP

      l_total_partners := l_total_partners + 1;

      l_new_partner_status := 'A';

      OPEN c_relationship_status ( l_partners_rec.partner_id, l_partners_rec.partner_party_id );
      FETCH c_relationship_status INTO l_vendor_party_id, l_start_date, l_end_date, l_status;
      IF c_relationship_status%FOUND THEN
        IF l_status = 'I' THEN
          l_new_partner_status := 'I';
        ELSE
          IF l_start_date > SYSDATE OR NVL(l_end_date, SYSDATE) < SYSDATE THEN
            l_new_partner_status := 'I';
          END IF;
        END IF;
      END IF;
      CLOSE c_relationship_status;

      IF l_new_partner_status <> 'I' THEN
        OPEN c_party_status (l_partners_rec.partner_party_id);
        FETCH c_party_status INTO l_status;
        IF c_party_status%FOUND THEN
          IF l_status = 'I' THEN
            l_new_partner_status := 'I';
          END IF;
        END IF;
        CLOSE c_party_status;
      END IF;

      IF l_new_partner_status <> 'I' THEN
        OPEN c_party_status (l_vendor_party_id);
        FETCH c_party_status INTO l_status;
        IF c_party_status%FOUND THEN
          IF l_status = 'I' THEN
            l_new_partner_status := 'I';
          END IF;
        END IF;
        CLOSE c_party_status;
      END IF;

      IF l_new_partner_status <> 'I' THEN
        OPEN c_resource_status (l_partners_rec.partner_resource_id);
        FETCH c_resource_status INTO l_start_date, l_end_date;
        IF c_resource_status%FOUND THEN
          IF l_start_date > SYSDATE OR NVL(l_end_date, SYSDATE) < SYSDATE THEN
            l_new_partner_status := 'I';
          END IF;
        END IF;
        CLOSE c_resource_status;
      END IF;

      IF l_partners_rec.status IS NULL OR l_partners_rec.status <> l_new_partner_status THEN

         l_prtnr_prfls_rec.partner_profile_id        := l_partners_rec.partner_profile_id;
         l_prtnr_prfls_rec.object_version_number     := l_partners_rec.object_version_number;
         l_prtnr_prfls_rec.partner_id                := l_partners_rec.partner_id;
         l_prtnr_prfls_rec.target_revenue_amt        := l_partners_rec.target_revenue_amt;
         l_prtnr_prfls_rec.actual_revenue_amt        := l_partners_rec.actual_revenue_amt;
         l_prtnr_prfls_rec.target_revenue_pct        := l_partners_rec.target_revenue_pct;
         l_prtnr_prfls_rec.actual_revenue_pct        := l_partners_rec.actual_revenue_pct;
         l_prtnr_prfls_rec.orig_system_reference     := l_partners_rec.orig_system_reference;
         l_prtnr_prfls_rec.orig_system_type          := l_partners_rec.orig_system_type;
         l_prtnr_prfls_rec.capacity_size             := l_partners_rec.capacity_size;
         l_prtnr_prfls_rec.capacity_amount           := l_partners_rec.capacity_amount;
         l_prtnr_prfls_rec.auto_match_allowed_flag   := l_partners_rec.auto_match_allowed_flag;
         l_prtnr_prfls_rec.purchase_method           := l_partners_rec.purchase_method;
         l_prtnr_prfls_rec.cm_id                     := l_partners_rec.cm_id;
         l_prtnr_prfls_rec.ph_support_rep            := l_partners_rec.ph_support_rep;
         l_prtnr_prfls_rec.lead_sharing_status       := l_partners_rec.lead_sharing_status;
         l_prtnr_prfls_rec.lead_share_appr_flag      := l_partners_rec.lead_share_appr_flag;
         l_prtnr_prfls_rec.partner_relationship_id   := l_partners_rec.partner_relationship_id;
         l_prtnr_prfls_rec.partner_level             := l_partners_rec.partner_level;
         l_prtnr_prfls_rec.preferred_vad_id          := l_partners_rec.preferred_vad_id;
         l_prtnr_prfls_rec.partner_group_id          := l_partners_rec.partner_group_id;
         l_prtnr_prfls_rec.partner_resource_id       := l_partners_rec.partner_resource_id;
         l_prtnr_prfls_rec.partner_group_number      := l_partners_rec.partner_group_number;
         l_prtnr_prfls_rec.partner_resource_number   := l_partners_rec.partner_resource_number;
         l_prtnr_prfls_rec.sales_partner_flag        := l_partners_rec.sales_partner_flag;
         l_prtnr_prfls_rec.indirectly_managed_flag   := l_partners_rec.indirectly_managed_flag;
         l_prtnr_prfls_rec.channel_marketing_manager := l_partners_rec.channel_marketing_manager;
         l_prtnr_prfls_rec.related_partner_id        := l_partners_rec.related_partner_id;
         l_prtnr_prfls_rec.max_users                 := l_partners_rec.max_users;
         l_prtnr_prfls_rec.partner_party_id          := l_partners_rec.partner_party_id;
         l_prtnr_prfls_rec.status                    := l_new_partner_status;

         SAVEPOINT update_partner_status;

         PVX_PRTNR_PRFLS_PVT.Update_Prtnr_Prfls(
            p_api_version        => l_api_version
            ,p_init_msg_list     => FND_API.g_true
            ,p_commit            => FND_API.g_false
            ,p_validation_level  => FND_API.g_valid_level_full
            ,x_return_status     => l_return_status
            ,x_msg_count         => l_msg_count
            ,x_msg_data          => l_msg_data
            ,p_prtnr_prfls_rec   => l_prtnr_prfls_rec
         );

         IF (l_return_status <> fnd_api.G_RET_STS_SUCCESS)  THEN

            ROLLBACK TO update_partner_status;

            l_error_partners := l_error_partners + 1;

            OPEN c_party_name (l_partners_rec.partner_party_id);
            FETCH c_party_name INTO l_partner_name, l_partner_number;
            CLOSE c_party_name;

            FND_MESSAGE.SET_NAME( application => 'PV'
                                ,name        => 'PV_PARTNER_STATUS_ERR_PARTNER');
            FND_MESSAGE.SET_TOKEN( token   => 'PARTNER'
                                  ,value    => l_partner_name || ' (' || l_partner_number || ')');
            l_message := FND_MESSAGE.get;

            FND_FILE.PUT_LINE( FND_FILE.LOG,  l_message );
            FND_FILE.NEW_LINE( FND_FILE.LOG,  1 );

            IF l_msg_count > 0 THEN
               l_message := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first, p_encoded => FND_API.g_false);
               while (l_message is not null)
               LOOP
                 fnd_file.put_line(FND_FILE.LOG,substr(l_message,1,200));
                 l_message := fnd_msg_pub.get(p_encoded => FND_API.g_false);
               END LOOP;
            END IF;

         END IF;

      END IF;

    END LOOP;

    COMMIT;

    IF l_total_partners = l_error_partners THEN

      FND_MESSAGE.SET_NAME( application => 'PV'
                            ,name       => 'PV_PARTNER_STATUS_COMPLET_FAIL');
      FND_MSG_PUB.ADD;
      l_message := FND_MESSAGE.get;

      FND_FILE.PUT_LINE( FND_FILE.LOG,  l_message );
      FND_FILE.NEW_LINE( FND_FILE.LOG,  1 );

      RETCODE := 2;
      ERRBUF  := l_message;

    ELSIF l_total_partners <> l_error_partners AND l_error_partners <> 0 THEN

      FND_MESSAGE.SET_NAME( application => 'PV'
                          ,name        => 'PV_PARTNER_STATUS_PARTIAL_FAIL');
      FND_MESSAGE.SET_TOKEN( token   => 'TOTAL_PARTNERS'
                           ,value    =>  l_total_partners);
      FND_MESSAGE.SET_TOKEN( token   => 'ERROR_PARTNERS'
                           ,value    =>  l_error_partners);
      l_message := FND_MESSAGE.get;

      FND_FILE.PUT_LINE( FND_FILE.LOG,  l_message );
      FND_FILE.NEW_LINE( FND_FILE.LOG,  1 );

      RETCODE := 1;
      ERRBUF := l_message;

    ELSIF l_error_partners = 0 THEN
      FND_MESSAGE.SET_NAME( application => 'PV'
                           ,name       => 'PV_PARTNER_STATUS_SUCCESS');
      l_message := FND_MESSAGE.get;

      FND_FILE.PUT_LINE( FND_FILE.LOG,  l_message );
      FND_FILE.NEW_LINE( FND_FILE.LOG,  1 );

      RETCODE := 0;
      ERRBUF := l_message;
    END IF;

    FND_MESSAGE.SET_NAME( application => 'PV'
                         ,name        => 'PV_PARTNER_STATUS_BATCH_END');

    FND_MESSAGE.SET_TOKEN( token   => 'P_DATE_TIME'
                          ,value   =>  TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') );

    FND_FILE.PUT_LINE( FND_FILE.LOG,  fnd_message.get );
    FND_FILE.NEW_LINE( FND_FILE.LOG,  1 );

  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      FND_MESSAGE.SET_NAME( application => 'PV'
                           ,name       => 'PV_UNKNOWN_ERROR');
      FND_MESSAGE.SET_TOKEN( token   => 'TEXT'
                            ,value   => 'Database Error:'||sqlcode||' '||sqlerrm);
      FND_MSG_PUB.ADD;
      l_message := FND_MESSAGE.get;

      FND_FILE.PUT_LINE( FND_FILE.LOG,  l_message );
      FND_FILE.NEW_LINE( FND_FILE.LOG,  1 );

      FND_MESSAGE.SET_NAME( application => 'PV'
                           ,name        => 'PV_UNKNOWN_ERROR');
      RETCODE := 1;
      ERRBUF  := fnd_message.get;

  END Update_Partner_Status;

-------------------------------------------------------------------
-- PROCEDURE
--    Cr_As_Accts_With_Partner_User
--
-- PURPOSE
--    Procedure to Create and Associate the customer Accounts with
--    Partner Users.
--
-- PARAMETERS
--    None
--
-- NOTES
--
--
--------------------------------------------------------------------
  PROCEDURE Cr_As_Accts_With_Partner_User (
     ERRBUF      OUT NOCOPY   VARCHAR2,
     RETCODE     OUT NOCOPY   VARCHAR2 ) IS

  CURSOR c_get_partner_wo_accounts IS
        select distinct pvpp.partner_party_id, hzp.party_name
        from   pv_partner_profiles pvpp, hz_parties hzp
        where  pvpp.status = 'A'
        and    hzp.party_id = pvpp.partner_party_id
        and    hzp.status = 'A'
        and    not exists
        (select 1
        from hz_cust_accounts hzca
        where hzca.status = 'A'
        and hzca.party_id = pvpp.partner_party_id);

  CURSOR c_get_prtnrcntct_wo_role IS
        select hzr.party_id, max(hzca.cust_account_id) cust_account_id
        from  jtf_rs_resource_extns jtfre, hz_relationships hzr, hz_cust_accounts hzca
        where jtfre.category= 'PARTY'
        and   jtfre.user_id is not null
        and   jtfre.source_id = hzr.party_id
        and   hzr.object_id in (select pvpp.partner_party_id
                                from pv_partner_profiles pvpp
                                where status = 'A')
        and   hzca.party_id = hzr.object_id
        and   hzca.status = 'A'
        and   hzr.relationship_code = 'EMPLOYEE_OF'
        and   hzr.directional_flag = 'F'
        and   hzr.status = 'A'
        and   hzr.start_date <= sysdate
        and   nvl(hzr.end_date,sysdate) >= sysdate
        and   not exists
        ( select 1
           from  hz_cust_account_roles hzcar
           where hzcar.cust_account_id  IN (select cust_account_id from hz_cust_accounts where party_id = hzr.object_id)
           and   nvl(hzcar.status,'A')='A'
           and   nvl(hzcar.begin_date,sysdate) <= sysdate
           and   nvl(hzcar.end_date,sysdate) >= sysdate
           and   hzr.party_id = hzcar.party_id
         )
       group by hzr.party_id;


   account_rec          HZ_CUST_ACCOUNT_V2PUB.cust_account_rec_type;
   organization_rec     HZ_PARTY_V2PUB.organization_rec_type;
   cust_profile_rec     HZ_CUSTOMER_PROFILE_V2PUB.customer_profile_rec_type;
   cust_acct_roles_rec  HZ_CUST_ACCOUNT_ROLE_V2PUB.cust_account_role_rec_type;

   l_cust_account_id    NUMBER;
   l_account_number     VARCHAR2(30);
   l_party_id           NUMBER;
   l_party_number       VARCHAR2(30);
   l_profile_id         NUMBER;
   l_cust_account_role_id  NUMBER;
   l_message            VARCHAR2(4000);
   l_partner_info       VARCHAR2(2000);
   i                    NUMBER;
   l_gen_cust_num       VARCHAR2(3);

   type numArray is table of number;
   type VCHAR2ARRAY is table of VARCHAR2(360);


   l_ptnr_party_id_array numArray;
   l_ptnr_party_name_array VCHAR2ARRAY;
   l_ptnr_cntct_id_array numArray;
   l_account_id_array   numArray;

   l_msg_count        NUMBER;
   l_msg_data         VARCHAR2(200);
   l_return_status    VARCHAR2(1);
   l_error_partners   NUMBER;

 BEGIN

        FND_MESSAGE.SET_NAME(
                application => 'PV'
                ,name        => 'PV_CR_CUST_ACCT_BATCH_START');

        FND_MESSAGE.SET_TOKEN(
                token   => 'P_DATE_TIME'
                ,value   =>  TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') );

        FND_FILE.PUT_LINE( FND_FILE.LOG,  fnd_message.get );
        FND_FILE.NEW_LINE( FND_FILE.LOG,  1 );

        /** Create a TCA account for partners if it does not exist **/
        account_rec.Created_by_Module := 'TCA_V2_API';
        organization_rec.Created_by_Module := 'TCA_V2_API';
        cust_profile_rec.Created_by_Module := 'TCA_V2_API';

        SELECT generate_customer_number INTO l_gen_cust_num FROM ar_system_parameters;

        open c_get_partner_wo_accounts;
        LOOP
           FETCH c_get_partner_wo_accounts bulk collect
                INTO l_ptnr_party_id_array,
                l_ptnr_party_name_array LIMIT 100;
           FOR k in 1 .. l_ptnr_party_id_array.count
           LOOP

             BEGIN

                -- Set the l_return_status to SUCCESS before starting the processing of each Parnter.
                l_return_status := FND_API.g_ret_sts_success;
                SAVEPOINT create_cust_account;
                l_partner_info := l_ptnr_party_name_array(k) || ' (' || l_ptnr_party_id_array(k) || ')';

                IF (l_gen_cust_num is null or l_gen_cust_num  = 'N') THEN
                   select TO_CHAR( HZ_ACCOUNT_NUM_S.NEXTVAL) into account_rec.account_number from dual ;
                END IF;

                organization_rec.party_rec.party_id := l_ptnr_party_id_array(k);
                account_rec.account_name := 'System Generated Account';

                HZ_CUST_ACCOUNT_V2PUB.create_cust_account
                (
                   p_init_msg_list            => FND_API.G_FALSE,
                   p_cust_account_rec         => account_rec,
                   p_organization_rec         => organization_rec,
                   p_customer_profile_rec     => cust_profile_rec,
                   x_cust_account_id          => l_cust_account_id,
                   x_account_number           => l_account_number,
                   x_party_id                 => l_party_id,
                   x_party_number             => l_party_number,
                   x_profile_id               => l_profile_id,
                   x_return_status            => l_return_status,
                   x_msg_count                => l_msg_count,
                   x_msg_data                 => l_msg_data
                );

                IF (l_return_status <> fnd_api.G_RET_STS_SUCCESS)  THEN
                    RAISE FND_API.G_EXC_ERROR;
                END IF;

            EXCEPTION

              WHEN Fnd_Api.G_EXC_ERROR THEN

                ROLLBACK TO create_cust_account;
                l_message := null;
                l_error_partners := l_error_partners + 1;
                l_partner_info := l_ptnr_party_name_array(k) || ' (' || l_ptnr_party_id_array(k) || ')';

                IF l_msg_count > 0 THEN
                   l_message := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first, p_encoded => FND_API.g_false);
                   while (l_message is not null)
                   LOOP
                      l_message := l_message||fnd_msg_pub.get(p_encoded => FND_API.g_false);
                   END LOOP;
                END IF;

                FND_FILE.PUT_LINE( FND_FILE.LOG,  substr(l_partner_info,1,50)||substr(l_message,1,500) );
                FND_FILE.NEW_LINE( FND_FILE.LOG,  1 );
                RETCODE := '2';

              WHEN OTHERS THEN
                ROLLBACK TO create_cust_account;
                l_message := null;
                l_error_partners := l_error_partners + 1;


                IF l_msg_count > 0 THEN
                   l_message := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first, p_encoded => FND_API.g_false);
                   while (l_message is not null)
                   LOOP
                      l_message := l_message||fnd_msg_pub.get(p_encoded => FND_API.g_false);
                   END LOOP;
                END IF;

                FND_FILE.PUT_LINE( FND_FILE.LOG,  substr(l_partner_info,1,50)||substr(l_message,1,500) );
                FND_FILE.NEW_LINE( FND_FILE.LOG,  1 );
                RETCODE := '2';
             END ; /* END of the Internal BEGIN */

           END LOOP;  /* k in 1 .. l_ptnr_party_id_array.count */
           exit when c_get_partner_wo_accounts%notfound;
        END LOOP;     /* FETCH c_get_partner_wo_accounts bulk collect */
       CLOSE c_get_partner_wo_accounts;

        FND_MESSAGE.SET_NAME(
                application => 'PV'
                ,name        => 'PV_CR_CUST_ACCT_BATCH_END');

        FND_MESSAGE.SET_TOKEN(
                token   => 'P_DATE_TIME'
                ,value   =>  TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') );
--------------------------------------------------------------------------

        FND_MESSAGE.SET_NAME(
                application => 'PV'
                ,name        => 'PV_AS_ACCT_TO_CNTCT_BTCH_START');

        FND_MESSAGE.SET_TOKEN(
                token   => 'P_DATE_TIME'
                ,value   =>  TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') );

        FND_FILE.PUT_LINE( FND_FILE.LOG,  fnd_message.get );
        FND_FILE.NEW_LINE( FND_FILE.LOG,  1 );

     /** Assign an account to contact **/
       open c_get_prtnrcntct_wo_role;
       LOOP
         fetch c_get_prtnrcntct_wo_role bulk collect into l_ptnr_cntct_id_array, l_account_id_array LIMIT 100;
         for k in 1 .. l_ptnr_cntct_id_array.count
         LOOP

           BEGIN
             l_return_status := FND_API.g_ret_sts_success;
             SAVEPOINT create_cust_account_role;
             l_partner_info := substr(l_ptnr_cntct_id_array(k),1,30) ||'     '|| substr(l_account_id_array(k),1,30);

             cust_acct_roles_rec.party_id        := l_ptnr_cntct_id_array(k);
             cust_acct_roles_rec.cust_account_id := l_account_id_array(k);
             cust_acct_roles_rec.role_type       := 'CONTACT';
             cust_acct_roles_rec.Created_by_Module := 'TCA_V2_API';

             HZ_CUST_ACCOUNT_ROLE_V2PUB.create_cust_account_role(
                p_init_msg_list                         => FND_API.G_FALSE,
                p_cust_account_role_rec                 => cust_acct_roles_rec,
                x_return_status                         => l_return_status,
                x_msg_count                             => l_msg_count,
                x_msg_data                              => l_msg_data ,
                 x_cust_account_role_id                  => l_cust_account_role_id
             );

             IF (l_return_status <> fnd_api.G_RET_STS_SUCCESS)  THEN
                 RAISE FND_API.G_EXC_ERROR;
             END IF;

             FND_FILE.PUT_LINE( FND_FILE.LOG,  substr(l_partner_info,1,60)||fnd_api.G_RET_STS_SUCCESS );
             COMMIT;
          EXCEPTION

              WHEN Fnd_Api.G_EXC_ERROR THEN

                ROLLBACK TO create_cust_account_role;
                l_message := null;

                IF l_msg_count > 0 THEN
                   l_message := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first, p_encoded => FND_API.g_false);
                   while (l_message is not null)
                   LOOP
                      l_message := l_message||fnd_msg_pub.get(p_encoded => FND_API.g_false);
                   END LOOP;
                END IF;

                FND_FILE.PUT_LINE( FND_FILE.LOG,  substr(l_partner_info,1,60)||substr(l_message,1,500) );
                FND_FILE.NEW_LINE( FND_FILE.LOG,  1 );

              WHEN OTHERS THEN
                ROLLBACK TO create_cust_account_role;
                l_message := null;
                l_error_partners := l_error_partners + 1;
                l_partner_info := substr(l_ptnr_cntct_id_array(k),1,30) ||'     '|| substr(l_account_id_array(k),1,30);

                IF l_msg_count > 0 THEN
                   l_message := fnd_msg_pub.get(p_msg_index => fnd_msg_pub.g_first, p_encoded => FND_API.g_false);
                   while (l_message is not null)
                   LOOP
                      l_message := l_message||fnd_msg_pub.get(p_encoded => FND_API.g_false);
                   END LOOP;
                END IF;

                FND_FILE.PUT_LINE( FND_FILE.LOG,  substr(l_partner_info,1,60)||substr(l_message,1,500) );
                FND_FILE.NEW_LINE( FND_FILE.LOG,  1 );

             END ; /* END of the Internal BEGIN */
         end loop;
         exit when c_get_prtnrcntct_wo_role%notfound;
        end loop;
       Close c_get_prtnrcntct_wo_role;

       FND_MESSAGE.SET_NAME(
                application => 'PV'
                ,name        => 'PV_AS_ACCT_TO_CNTCT_BTCH_END');

       FND_MESSAGE.SET_TOKEN(
                token   => 'P_DATE_TIME'
                ,value   =>  TO_CHAR(SYSDATE, 'DD-MON-YYYY HH24:MI:SS') );

  END Cr_As_Accts_With_Partner_User;

END PVX_Misc_PVT;

/
