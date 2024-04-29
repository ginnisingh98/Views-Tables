--------------------------------------------------------
--  DDL for Package Body PV_USER_RESP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_USER_RESP_PVT" AS
 /* $Header: pvxvpurb.pls 120.9 2006/05/05 13:32:50 dgottlie ship $ */

-- ===============================================================
-- Start of Comments
-- Package name
--          PV_USER_RESP_PUB
-- Purpose
--
-- History
--         24-OCT-2002    Jessica.Lee         Created
--         02-OCT-2003    Karen.Tsao          Modified for 11.5.10
--         28-OCT-2003    Karen.Tsao          Made changes in assign_resp, get_default_resp, and get_default_org_resp
--         04-NOV-2003    Karen.Tsao          Change i := 0 to i := 1 in get_store_prgm_resp.
--         11-NOV-2003    Karen.Tsao          Change the cursors c_get_user_resp_groups (in assign cases) to query
--                                            fnd_responsibility_vl to get the application_id.
--         12-NOV-2003    Karen.Tsao          Added procedure manage_resp_on_address_change() and
--                                            function manage_resp_on_address_change() for business event subscription.
--         14-NOV-2003    Karen.Tsao          1. Changed cursor name from c_get_user_resp_groups to c_get_application_id (in assign cases).
--                                            2. Modified the way to handle store responsibility.
--                                            3. Changed the method name from get_default_and_assign to get_default_assign_addrow.
--         19-NOV-2003    Karen.Tsao          Took out l_cnt delaration and := 1 for the FOR-LOOP.
--         10-DEC-2003    Karen.Tsao          Modified.
--         11-FEB-2004    Karen.Tsao          Fixed for bug 3428985. Added get_partner_users_2(). Modified manage_ter_exp_memb_resp()
--                                            and revoke_default_resp(), make a call to get_partner_users_2() instead of get_partner_users().
--         19-FEB-2004    Karen.Tsao          Fixed for bug 3436285. Added adjust_user_resps() API.
--         12-MAR-2003    pukken              TO fix bug 3492311. modified manage_resp_on_address_change subscription
--         05-APR-2004    Karen.Tsao          Fixed for bug 3533631.
--         30-APR-2004    Karen.Tsao          Fixed for bug 3586212. Added pvpp.partner_id = p_partner_id in API assign_default_resp().
--         24-MAY-2004    Karen.Tsao          Fixed for sql repository. Took out the c_get_application_id and hard code the iStore application to 671.
--         22-JUL-2004    Karen.Tsao          Fixed for sql repository. Bug #3766776.
--         10-AUG-2004    Karen.Tsao          Fixed for bug 3824526. Updated create_resp_mapping() API.
--         13-AUG-2004    Karen.Tsao          Fixed for bug 3830319. Created manage_merged_party_memb_resp() API for party merge routine.
--         18-AUG-2004    Karen.Tsao          Updated the logic in manage_merged_party_memb_resp() API based on contact merge happening after resp merge.
--         14-APR-2004    Karen.Tsao          Make update_resp_mapping into concurrent program call exec_cre_upd_del_resp_mapping (same as
--                                            create and delete). Therefore, change API name exec_cre_or_del_resp_mapping to exec_cre_upd_del_resp_mapping.
--         07-OCT-2005    Karen.Tsao          Fixed for bug 4644887 - took out the reference to fnd_user_resp_groups in get_partner_users_2().
--
--
-- NOTE
--
-- End of Comments
-- ===============================================================

G_PKG_NAME   CONSTANT VARCHAR2(30) := 'PV_USER_RESP_PVT';
G_FILE_NAME  CONSTANT VARCHAR2(12) := 'pvxvpurb.pls';

G_APP_ID CONSTANT NUMBER := 691;

PV_DEBUG_HIGH_ON CONSTANT BOOLEAN := Fnd_Msg_Pub.CHECK_MSG_LEVEL(Fnd_Msg_Pub.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT BOOLEAN := Fnd_Msg_Pub.CHECK_MSG_LEVEL(Fnd_Msg_Pub.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT BOOLEAN := Fnd_Msg_Pub.CHECK_MSG_LEVEL(Fnd_Msg_Pub.G_MSG_LVL_DEBUG_MEDIUM);
g_log_level     CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;
g_log_to_file            VARCHAR2(5)  := 'N';

bad_action                     EXCEPTION;
NO_SOURCE_RESP_MAP_RULE_ID     EXCEPTION;
EXC_ERROR                      EXCEPTION;
no_user_name                   EXCEPTION;

/*
* private Debug_Log
* input: p_msg_string, p_msg_type
* Write the message into log
*
*/
PROCEDURE Debug_Log(
   p_msg_string    IN VARCHAR2,
   p_msg_type      IN VARCHAR2 := 'PV_DEBUG_MESSAGE'
)
IS
BEGIN
   IF (PV_DEBUG_HIGH_ON) THEN
     Pvx_Utility_Pvt.debug_message('g_log_to_file = ' || g_log_to_file);
   END IF;
   IF (g_log_to_file = 'N') THEN
        Pvx_Utility_Pvt.debug_message(p_msg_string);
   ELSIF (g_log_to_file = 'Y') THEN
      FND_MESSAGE.Set_Name('PV', p_msg_type);
      FND_MESSAGE.Set_Token('TEXT', p_msg_string);
      FND_FILE.PUT_LINE( FND_FILE.LOG,  fnd_message.get );
   END IF;
END Debug_Log;

/*****************************
 * debug_message
 *****************************/
PROCEDURE debug_message
(
    p_log_level IN NUMBER
   ,p_module_name    IN VARCHAR2
   ,p_text   IN VARCHAR2
)
IS
BEGIN

  IF  (p_log_level>= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(p_log_level, p_module_name, p_text);
  END IF;


END debug_message;

/*****************************
 * WRITE_LOG
 *****************************/
PROCEDURE WRITE_LOG
(
   p_api_name      IN VARCHAR2
   , p_log_message   IN VARCHAR2
)
IS

BEGIN
  debug_message (
      p_log_level     => g_log_level
     ,p_module_name   => 'plsql.pv'||'.'|| g_pkg_name||'.'||p_api_name||'.'||p_log_message
     ,p_text          => p_log_message
  );
END WRITE_LOG;

/*
* get_partner_users
* get the list of partner users based on the partner id and partner type
*
*/
FUNCTION get_partner_users (
     p_partner_id		       IN NUMBER,
     p_user_role_code       IN VARCHAR2
)
RETURN JTF_NUMBER_TABLE
IS
   l_user_ids_tbl JTF_NUMBER_TABLE  := JTF_NUMBER_TABLE();
   l_user_id      NUMBER;
   i              NUMBER := 1;

   CURSOR c_primary_user_ids IS
      SELECT user_id
      FROM pv_partner_primary_users_v
      WHERE partner_id = p_partner_id;

   CURSOR c_business_user_ids IS
      SELECT user_id
      FROM pv_partner_business_users_v
      WHERE partner_id = p_partner_id;

BEGIN
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('get_partner_users: - START');
      Debug_Log('get_partner_users: p_user_role_code = ' || p_user_role_code);
   END IF;
   IF (p_user_role_code = G_ALL)  THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('get_partner_users: p_user_role_code = G_ALL');
      END IF;
      -- Primary users
      FOR x IN c_primary_user_ids LOOP
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('get_partner_users: i = ' || i);
            Debug_Log('get_partner_users: x.user_id = ' || x.user_id);
         END IF;
         l_user_ids_tbl.extend;
     		l_user_ids_tbl(i) := x.user_id;
     		i := i+1;
  		END LOOP;
      -- Business users
      FOR x IN c_business_user_ids LOOP
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('get_partner_users: i = ' || i);
            Debug_Log('get_partner_users: x.user_id = ' || x.user_id);
         END IF;
         l_user_ids_tbl.extend;
     		l_user_ids_tbl(i) := x.user_id;
     		i := i+1;
  		END LOOP;
   ELSIF (p_user_role_code = G_PRIMARY)  THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('get_partner_users: p_user_role_code = G_PRIMARY');
      END IF;
      FOR x IN c_primary_user_ids LOOP
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('get_partner_users: i = ' || i);
            Debug_Log('get_partner_users: x.user_id = ' || x.user_id);
         END IF;
         l_user_ids_tbl.extend;
     		l_user_ids_tbl(i) := x.user_id;
     		i := i+1;
  		END LOOP;
   ELSIF (p_user_role_code = G_BUSINESS)  THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('get_partner_users: p_user_role_code = G_BUSINESS');
      END IF;
      FOR x IN c_business_user_ids LOOP
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('get_partner_users: i = ' || i);
            Debug_Log('get_partner_users: x.user_id = ' || x.user_id);
         END IF;
         l_user_ids_tbl.extend;
     		l_user_ids_tbl(i) := x.user_id;
     		i := i+1;
  		END LOOP;
  END IF;
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('get_partner_users: - END');
   END IF;

  RETURN l_user_ids_tbl;
  EXCEPTION WHEN OTHERS THEN
 	RETURN NULL;
END; -- Endo of get_partner_users_

/*
* get_partner_users_2
* get the list of partner users based on the partner id and partner type
* differencies between get_partner_users and get_partner_users_2 is:
* instead of using views pv_partner_primary_users_v and pv_partner_business_users_v
* hardcoded the query of the views but took out the where status = 'A'
*/
FUNCTION get_partner_users_2 (
     p_partner_id		       IN NUMBER,
     p_user_role_code       IN VARCHAR2
)
RETURN JTF_NUMBER_TABLE
IS
   l_user_ids_tbl JTF_NUMBER_TABLE  := JTF_NUMBER_TABLE();
   l_user_id      NUMBER;
   i              NUMBER := 1;

   CURSOR c_primary_user_ids IS
      SELECT user_id
      FROM   (
             SELECT jtfre.user_id user_id, pvpp.partner_id partner_id
             FROM   pv_partner_profiles pvpp, hz_relationships hzr, jtf_rs_resource_extns jtfre, fnd_user fndu
             WHERE  pvpp.partner_party_id = hzr.object_id
                    AND hzr.relationship_code = 'EMPLOYEE_OF'
                    AND HZR.subject_table_name ='HZ_PARTIES'
                    AND HZR.object_table_name ='HZ_PARTIES'
                    AND HZR.directional_flag = 'F'
                    AND hzr.start_date <= SYSDATE
		    AND (hzr.end_date is null or  hzr.end_date > sysdate)
		    AND HZR.status = 'A'
                    AND hzr.party_id = jtfre.source_id
                    AND jtfre.category = 'PARTY'
                    AND fndu.user_id = jtfre.user_id
                    AND fndu.start_date <= sysdate
                    AND (fndu.end_date is null or fndu.end_date > sysdate)
                    AND exists (
                                           SELECT jtfp1.principal_name username
                                           FROM jtf_auth_principal_maps jtfpm, jtf_auth_principals_b jtfp1, jtf_auth_domains_b jtfd, jtf_auth_principals_b jtfp2, jtf_auth_role_perms jtfrp, jtf_auth_permissions_b jtfperm
                                           WHERE jtfp1.is_user_flag=1
                                           AND jtfp1.jtf_auth_principal_id=jtfpm.jtf_auth_principal_id
                                           AND jtfp2.jtf_auth_principal_id=jtfpm.jtf_auth_parent_principal_id
                                           AND jtfp2.is_user_flag=0
                                           AND jtfp2.jtf_auth_principal_id=jtfrp.jtf_auth_principal_id
                                           AND jtfrp.positive_flag = 1
                                           AND jtfrp.jtf_auth_permission_id = jtfperm.jtf_auth_permission_id
                                           AND jtfperm.permission_name in ('PV_PARTNER_USER', 'IBE_INT_PRIMARY_USER')
                                           AND jtfd.jtf_auth_domain_id = jtfpm.jtf_auth_domain_id
                                           AND jtfd.domain_name = 'CRM_DOMAIN'
					   and jtfp1.principal_name = jtfre.user_name
                                           GROUP BY jtfp1.principal_name
                                           HAVING count (distinct decode(jtfperm.permission_name, 'IBE_INT_PRIMARY_USER', null, jtfperm.permission_name) ) = 1
                                           AND count(distinct decode(jtfperm.permission_name, 'IBE_INT_PRIMARY_USER', jtfperm.permission_name, null )) =1
                                           )
             )
      WHERE  partner_id = p_partner_id;

   CURSOR c_business_user_ids IS
      SELECT user_id
      FROM   (
             SELECT jtfre.user_id user_id, pvpp.partner_id partner_id
             FROM pv_partner_profiles pvpp, hz_relationships hzr, jtf_rs_resource_extns jtfre, fnd_user fndu
             WHERE pvpp.partner_party_id = hzr.object_id
             AND hzr.relationship_code = 'EMPLOYEE_OF'
             AND HZR.subject_table_name ='HZ_PARTIES'
             AND HZR.object_table_name ='HZ_PARTIES'
             AND HZR.directional_flag = 'F'
             AND hzr.start_date <= SYSDATE
	     AND (hzr.end_date is null or  hzr.end_date > sysdate)
	     AND HZR.status = 'A'
             AND hzr.party_id = jtfre.source_id
             AND jtfre.category = 'PARTY'
             AND fndu.user_id = jtfre.user_id
             AND fndu.start_date <= sysdate
             AND (fndu.end_date is null or fndu.end_date > sysdate)
             AND exists (
                                               SELECT jtfp1.principal_name username
                                               FROM jtf_auth_principal_maps jtfpm, jtf_auth_principals_b jtfp1, jtf_auth_domains_b jtfd, jtf_auth_principals_b jtfp2, jtf_auth_role_perms jtfrp, jtf_auth_permissions_b jtfperm
                                               WHERE jtfp1.is_user_flag = 1
                                               AND jtfp1.jtf_auth_principal_id = jtfpm.jtf_auth_principal_id
                                               AND jtfpm.jtf_auth_parent_principal_id = jtfp2.jtf_auth_principal_id
                                               AND jtfp2.is_user_flag = 0
                                               AND jtfp2.jtf_auth_principal_id = jtfrp.jtf_auth_principal_id
                                               AND jtfrp.positive_flag = 1
                                               AND jtfrp.jtf_auth_permission_id = jtfperm.jtf_auth_permission_id
                                               AND jtfperm.permission_name in ('PV_PARTNER_USER', 'IBE_INT_PRIMARY_USER')
                                               AND jtfd.jtf_auth_domain_id = jtfpm.jtf_auth_domain_id
                                               AND jtfd.domain_name = 'CRM_DOMAIN'
					       and jtfp1.principal_name = jtfre.user_name
                                               GROUP BY jtfp1.principal_name
                                               HAVING count( distinct decode(jtfperm.permission_name, 'IBE_INT_PRIMARY_USER', null, jtfperm.permission_name ) ) = 1
                                               AND count (distinct decode(jtfperm.permission_name, 'IBE_INT_PRIMARY_USER' , jtfperm.permission_name, null ) ) = 0 )
             )
      WHERE  partner_id = p_partner_id;

BEGIN
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('get_partner_users_2: - START');
      Debug_Log('get_partner_users_2: p_user_role_code = ' || p_user_role_code);
   END IF;
   IF (p_user_role_code = G_ALL)  THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('get_partner_users_2: p_user_role_code = G_ALL');
      END IF;
      -- Primary users
      FOR x IN c_primary_user_ids LOOP
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('get_partner_users_2: i = ' || i);
            Debug_Log('get_partner_users_2: x.user_id = ' || x.user_id);
         END IF;
         l_user_ids_tbl.extend;
     		l_user_ids_tbl(i) := x.user_id;
     		i := i+1;
  		END LOOP;
      -- Business users
      FOR x IN c_business_user_ids LOOP
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('get_partner_users_2: i = ' || i);
            Debug_Log('get_partner_users_2: x.user_id = ' || x.user_id);
         END IF;
         l_user_ids_tbl.extend;
     		l_user_ids_tbl(i) := x.user_id;
     		i := i+1;
  		END LOOP;
   ELSIF (p_user_role_code = G_PRIMARY)  THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('get_partner_users_2: p_user_role_code = G_PRIMARY');
      END IF;
      FOR x IN c_primary_user_ids LOOP
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('get_partner_users_2: i = ' || i);
            Debug_Log('get_partner_users_2: x.user_id = ' || x.user_id);
         END IF;
         l_user_ids_tbl.extend;
     		l_user_ids_tbl(i) := x.user_id;
     		i := i+1;
  		END LOOP;
   ELSIF (p_user_role_code = G_BUSINESS)  THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('get_partner_users_2: p_user_role_code = G_BUSINESS');
      END IF;
      FOR x IN c_business_user_ids LOOP
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('get_partner_users_2: i = ' || i);
            Debug_Log('get_partner_users_2: x.user_id = ' || x.user_id);
         END IF;
         l_user_ids_tbl.extend;
     		l_user_ids_tbl(i) := x.user_id;
     		i := i+1;
  		END LOOP;
  END IF;
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('get_partner_users_2: - END');
   END IF;

  RETURN l_user_ids_tbl;
  EXCEPTION WHEN OTHERS THEN
 	RETURN NULL;
END; -- Endo of get_partner_users_2

/*
* get_partners
* get the list of partner ids based on the user id
*
*/
FUNCTION get_partners (
    p_user_id		     IN  NUMBER
)
RETURN JTF_NUMBER_TABLE
IS
   l_partner_ids_tbl   JTF_NUMBER_TABLE  := JTF_NUMBER_TABLE();
   l_user_id           NUMBER;
   l_index             NUMBER := 1;

   CURSOR c_get_partner_id IS
      select pvpp.partner_id partner_id
      from   jtf_rs_resource_extns RES, hz_relationships hzr, pv_partner_profiles pvpp
      where  RES.user_id = p_user_id
      and    RES.category = 'PARTY'
      and    RES.start_date_active <= SYSDATE and nvl(RES.end_date_active , sysdate) >= SYSDATE
      and    RES.source_id = hzr.party_id and hzr.directional_flag = 'F'
      and    hzr.relationship_code = 'EMPLOYEE_OF' and HZR.subject_table_name ='HZ_PARTIES'
      and    HZR.object_table_name ='HZ_PARTIES' and hzr.start_date <= SYSDATE
      and    (hzr.end_date is null or hzr.end_date > SYSDATE)
      and    hzr.object_id = pvpp.partner_party_id
      and    pvpp.status = 'A';
BEGIN
   FOR x in c_get_partner_id
   LOOP
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('x.partner_id: ' || x.partner_id);
      END IF;

      l_partner_ids_tbl.extend;
      l_partner_ids_tbl(l_index) := x.partner_id;
      l_index := l_index + 1;
   END LOOP;
  RETURN l_partner_ids_tbl;
EXCEPTION
   WHEN OTHERS THEN
 	   RETURN NULL;
END;

/*
* assign_resp
* input: p_user_id, p_resp_id, p_app_id
* assigning the user p_user_id with resp p_resp_id for application p_app_id
*
*/

PROCEDURE assign_resp
(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2  := Fnd_Api.g_false,
    p_commit                     IN   VARCHAR2  := Fnd_Api.g_false,
    p_user_id			 		 IN   NUMBER,
    p_resp_id		 			 IN   NUMBER,
    p_app_id				 	 IN   NUMBER,
    X_Return_Status		 		 OUT NOCOPY  VARCHAR2,
    X_Msg_Count			 		 OUT NOCOPY  NUMBER,
    X_Msg_Data			 		 OUT NOCOPY  VARCHAR2
)
IS
l_api_name                  CONSTANT  VARCHAR2(30) := 'assign_resp';
l_api_version_number        CONSTANT  NUMBER       := 1.0;
l_object_version_number     NUMBER;
BEGIN
     ---- Initialize----------------

      -- Standard Start of API savepoint
      SAVEPOINT assign_resp;

      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                         ,p_api_version_number
                                         ,l_api_name
                                         ,G_PKG_NAME
                                         )
      THEN
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
         Fnd_Msg_Pub.initialize;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('PRIVATE API: ' || l_api_name || ' - START');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

      IF (p_user_id is null) THEN
         FND_MESSAGE.SET_NAME  ('PV', 'PV_USER_ID_NULL');
         FND_MSG_PUB.ADD;
         raise FND_API.G_EXC_ERROR;
      END IF;

      IF (p_resp_id is null) THEN
         FND_MESSAGE.SET_NAME  ('PV', 'PV_RESP_ID_NULL');
         FND_MSG_PUB.ADD;
         raise FND_API.G_EXC_ERROR;
      END IF;

      IF (p_app_id is null) THEN
         FND_MESSAGE.SET_NAME  ('PV', 'PV_APPL_ID_NULL');
         FND_MSG_PUB.ADD;
         raise FND_API.G_EXC_ERROR;
      END IF;

      Fnd_User_Resp_Groups_Api.UPLOAD_ASSIGNMENT(
	  		user_id => p_user_id,
	  		responsibility_id => p_resp_id,
	  		responsibility_application_id => p_app_id,
	  		start_date => SYSDATE,
	  		end_date => NULL,
	  		description => NULL );

     -- Check for commit : no commit at private procedure
     --IF Fnd_Api.to_boolean(p_commit) THEN
     --   COMMIT;
     --END IF;

    Fnd_Msg_Pub.count_and_get(
       p_encoded => Fnd_Api.g_false
      ,p_count   => x_msg_count
      ,p_data    => x_msg_data
      );

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Debug_Log('PRIVATE API: ' || l_api_name || ' - END');
      END IF;

EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
     ROLLBACK TO assign_resp;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO assign_resp;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO assign_resp;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

END assign_resp;

/*
* revoke resp
* input: p_user_id, p_resp_id, p_app_id
* revoking user resp when the status code is upgraded, terminated or expired
* based on a p_user_id, we will revoke p_resp_id for the application p_app_id
*/
PROCEDURE revoke_resp(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list          	   IN   VARCHAR2  := Fnd_Api.g_false,
    p_commit                 	   IN   VARCHAR2  := Fnd_Api.g_false,
    p_user_id			 			   IN   NUMBER,
    p_resp_id		 				   IN   NUMBER,
    p_app_id				 		   IN   NUMBER,
    p_security_group_id			   IN   NUMBER,
    p_start_date			 		   IN   DATE,
    p_description 				   IN   VARCHAR2,
    x_return_status		 	      OUT NOCOPY  VARCHAR2,
    x_msg_count			 		   OUT NOCOPY  NUMBER,
    x_msg_data			 			   OUT NOCOPY  VARCHAR2
)

IS
   l_api_name                  CONSTANT  VARCHAR2(30) := 'revoke_resp';
   l_api_version_number        CONSTANT  NUMBER       := 1.0;
   l_object_version_number     NUMBER;

BEGIN
     ---- Initialize----------------

      -- Standard Start of API savepoint
      SAVEPOINT revoke_resp;

      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                         ,p_api_version_number
                                         ,l_api_name
                                         ,G_PKG_NAME
                                         )
      THEN
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
         Fnd_Msg_Pub.initialize;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('PRIVATE API: ' || l_api_name || ' - START');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

      Fnd_User_Resp_Groups_Api.UPLOAD_ASSIGNMENT(
         user_id                        => p_user_id,
         responsibility_id              => p_resp_id,
         responsibility_application_id  => p_app_id,
         security_group_id              => p_security_group_id,
         start_date                     => p_start_date,
         end_date                       => SYSDATE,
         description                    => p_description
      );

      Fnd_Msg_Pub.count_and_get(
          p_encoded => Fnd_Api.g_false
         ,p_count   => x_msg_count
         ,p_data    => x_msg_data
      );

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Debug_Log('PRIVATE API: ' || l_api_name || ' - END');
      END IF;

EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
     ROLLBACK TO revoke_resp;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO revoke_resp;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO revoke_resp;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );


END revoke_resp;


/*
* revoke resp
* input: p_user_id, p_resp_id, p_app_id
* revoking user resp when the status code is upgraded, terminated or expired
* based on a p_user_id, we will revoke p_resp_id for the application p_app_id
*/
PROCEDURE revoke_resp(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list          	   IN   VARCHAR2  := Fnd_Api.g_false,
    p_commit                 	   IN   VARCHAR2  := Fnd_Api.g_false,
    p_user_id			 			   IN   JTF_NUMBER_TABLE,
    p_resp_id		 				   IN   NUMBER,
    x_return_status		 	      OUT NOCOPY  VARCHAR2,
    x_msg_count			 		   OUT NOCOPY  NUMBER,
    x_msg_data			 			   OUT NOCOPY  VARCHAR2
)

IS
   CURSOR c_get_user_resp_groups IS
      SELECT  user_id, responsibility_id, responsibility_application_id, security_group_id, start_date, description
      FROM    fnd_user_resp_groups
      WHERE   user_id in (
               SELECT * FROM TABLE (CAST(p_user_id AS JTF_NUMBER_TABLE))
              )
      AND     responsibility_id = p_resp_id;

   l_api_name                  CONSTANT  VARCHAR2(30) := 'revoke_resp';
   l_api_version_number        CONSTANT  NUMBER       := 1.0;
   l_object_version_number     NUMBER;

BEGIN
     ---- Initialize----------------

      -- Standard Start of API savepoint
      SAVEPOINT revoke_resp;


      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                         ,p_api_version_number
                                         ,l_api_name
                                         ,G_PKG_NAME
                                         )
      THEN
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
         Fnd_Msg_Pub.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('PRIVATE API: ' || l_api_name || ' - START');
      END IF;

       -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         IF (p_user_id IS NULL) THEN
            Debug_Log('PRIVATE API: p_user_id is null');
         ELSE
            FOR l_cnt IN 1..p_user_id.count LOOP
               Debug_Log('PRIVATE API: p_user_id(' || l_cnt || ') = ' || p_user_id(l_cnt));
            END LOOP;
         END IF;
         Debug_Log('PRIVATE API: p_resp_id = ' || p_resp_id);
      END IF;

      FOR x IN c_get_user_resp_groups LOOP
         -- Debug Message
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('revoke_resp: x.responsibility_id = ' || x.responsibility_id);
            Debug_Log('revoke_resp: x.user_id = ' || x.user_id);
            Debug_Log('revoke_resp: x.responsibility_application_id = ' || x.responsibility_application_id);
            Debug_Log('revoke_resp: x.security_group_id = ' || x.security_group_id);
            Debug_Log('revoke_resp: x.start_date = ' || x.start_date);
            Debug_Log('revoke_resp: x.description = ' || x.description);
         END IF;

         revoke_resp(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,p_user_id                    => x.user_id
            ,p_resp_id                    => x.responsibility_id
            ,p_app_id                     => x.responsibility_application_id
            ,p_security_group_id          => x.security_group_id
            ,p_start_date                 => x.start_date
            ,p_description                => x.description
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END LOOP;

      Fnd_Msg_Pub.count_and_get(
          p_encoded => Fnd_Api.g_false
         ,p_count   => x_msg_count
         ,p_data    => x_msg_data
      );

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Debug_Log('PRIVATE API: ' || l_api_name || ' - END');
      END IF;

EXCEPTION
   WHEN Fnd_Api.G_EXC_ERROR THEN
     ROLLBACK TO revoke_resp;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO revoke_resp;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );

   WHEN OTHERS THEN
     ROLLBACK TO revoke_resp;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
             p_encoded => Fnd_Api.G_FALSE
            ,p_count   => x_msg_count
            ,p_data    => x_msg_data
            );


END revoke_resp;

/*
* get_user_role_code
* This is to get the default responsibility using partner_id and user_rold
*/
PROCEDURE get_user_role_code(
    p_user_id            IN  NUMBER
   ,x_user_role_code     OUT NOCOPY VARCHAR2
)
IS
    CURSOR get_user_role IS
      SELECT   jtfperm.permission_name
      FROM     jtf_auth_principal_maps jtfpm,
               jtf_auth_principals_b jtfp1, jtf_auth_domains_b jtfd,
               jtf_auth_principals_b jtfp2,
               jtf_auth_role_perms jtfrp,
               jtf_auth_permissions_b jtfperm,
               fnd_user fndu
      WHERE    fndu.user_id = p_user_id
      AND      jtfp1.principal_name = fndu.user_name
      AND      jtfp1.is_user_flag=1
      AND      jtfp1.jtf_auth_principal_id=jtfpm.jtf_auth_principal_id
      AND      jtfpm.jtf_auth_parent_principal_id = jtfp2.jtf_auth_principal_id
      AND      jtfp2.is_user_flag=0
      AND      jtfp2.jtf_auth_principal_id = jtfrp.jtf_auth_principal_id
      AND      jtfrp.positive_flag = 1
      AND      jtfrp.jtf_auth_permission_id = jtfperm.jtf_auth_permission_id
      AND      jtfperm.permission_name in ('IBE_INT_PRIMARY_USER', 'PV_PARTNER_USER')
      AND      jtfd.jtf_auth_domain_id=jtfpm.jtf_auth_domain_id
      AND      jtfd.domain_name='CRM_DOMAIN'
      GROUP BY jtfperm.permission_name;

    is_partner_user boolean := false;
    is_primary_user boolean := false;

BEGIN
   FOR x IN get_user_role LOOP
      IF (x.permission_name = 'IBE_INT_PRIMARY_USER') THEN
        is_primary_user     := true;
      ELSIF (x.permission_name = 'PV_PARTNER_USER') THEN
        is_partner_user  := true;
      END IF;
   END LOOP;

   IF((not is_partner_user) and (not is_primary_user)) THEN
      FND_MESSAGE.SET_NAME  ('PV', 'PV_NOT_VALID_PARTNER_USER');
      FND_MSG_PUB.ADD;
      raise FND_API.G_EXC_ERROR;
   ELSIF (is_primary_user) THEN
      x_user_role_code := G_PRIMARY;
   ELSE
      x_user_role_code := G_BUSINESS;
   END IF;
END get_user_role_code;

/*
* get_default_resp
* This is to get the default responsibility using partner_id and user_rold
*/
PROCEDURE get_default_resp(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_partner_id                 IN   NUMBER
   ,p_user_role_code             IN   VARCHAR2
   ,x_responsibility_id          OUT  NOCOPY NUMBER
   ,x_resp_map_rule_id           OUT  NOCOPY NUMBER
)
IS
   CURSOR c_get_resp_map_rule_info (cv_user_role_code VARCHAR2) IS
      SELECT resp_map_rule_id, geo_hierarchy_id, responsibility_id
      FROM   pv_ge_resp_map_rules
      WHERE  user_role_code = p_user_role_code
      AND    program_id is null
      AND    delete_flag = 'N';

   CURSOR c_get_area1_resp (cv_user_role_code VARCHAR2) IS
      SELECT rmr.resp_map_rule_id, rmr.responsibility_id
      FROM   pv_ge_resp_map_rules rmr, jtf_loc_hierarchies_vl lh
      WHERE  rmr.user_role_code = p_user_role_code
      AND    rmr.program_id is null
      AND    rmr.geo_hierarchy_id = lh.location_hierarchy_id
      AND    lh.location_type_code = 'AREA1'
      AND    rmr.delete_flag = 'N';

   l_api_name                  CONSTANT  VARCHAR2(30) := 'get_default_resp';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_geo_hierarchy_id_tbl      JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_responsibility_id_tbl     JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_resp_map_rule_id_tbl      JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_index                     NUMBER;
   l_matched_geo_hierarchy_id  NUMBER;
   l_responsibility_id         NUMBER;


BEGIN
  ---- Initialize----------------

   -- Standard Start of API savepoint
   SAVEPOINT get_default_resp;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                      ,p_api_version_number
                                      ,l_api_name
                                      ,G_PKG_NAME
                                      )
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_Boolean( p_init_msg_list )
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('PRIVATE API: ' || l_api_name || ' - START');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   l_index := 1;
   FOR x IN c_get_resp_map_rule_info(p_user_role_code)
   LOOP
      l_geo_hierarchy_id_tbl.extend;
      l_geo_hierarchy_id_tbl(l_index) := x.geo_hierarchy_id;
      l_responsibility_id_tbl.extend;
      l_responsibility_id_tbl(l_index) := x.responsibility_id;
      l_resp_map_rule_id_tbl.extend;
      l_resp_map_rule_id_tbl(l_index) := x.resp_map_rule_id;
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('get_default_resp: l_index = ' || l_index);
         Debug_Log('get_default_resp: l_geo_hierarchy_id_tbl(l_index) = ' || l_geo_hierarchy_id_tbl(l_index));
         Debug_Log('get_default_resp: l_responsibility_id_tbl(l_index) = ' || l_responsibility_id_tbl(l_index));
         Debug_Log('get_default_resp: l_resp_map_rule_id_tbl(l_index) = ' || l_resp_map_rule_id_tbl(l_index));
      END IF;
      l_index := l_index + 1;
   END LOOP;

   PV_PARTNER_GEO_MATCH_PVT.Get_Ptnr_Matched_Geo_Id (
      p_api_version_number         => p_api_version_number
     ,p_init_msg_list              => FND_API.G_FALSE
     ,x_return_status              => x_return_status
     ,x_msg_count                  => x_msg_count
     ,x_msg_data                   => x_msg_data
     ,p_partner_id                 => p_partner_id
     ,p_geo_hierarchy_id           => l_geo_hierarchy_id_tbl
     ,x_geo_hierarchy_id           => l_matched_geo_hierarchy_id
   );

   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

   -- if l_matched_geo_hierarchy_id is null
   -- most likely the partner doesn't have address in database
   IF l_matched_geo_hierarchy_id is null THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('get_default_resp: l_matched_geo_hierarchy_id is null');
      END IF;
      FOR x IN c_get_area1_resp(p_user_role_code)
      LOOP
         x_responsibility_id := x.responsibility_id;
         x_resp_map_rule_id := x.resp_map_rule_id;
      END LOOP;
      IF ((x_responsibility_id is null) or (x_resp_map_rule_id is null)) THEN
        FND_MESSAGE.set_name('PV', 'PV_NO_DEFLT_RESP');
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
   ELSE
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('get_default_resp: l_matched_geo_hierarchy_id =' || l_matched_geo_hierarchy_id);
      END IF;
      FOR i IN 1..l_geo_hierarchy_id_tbl.COUNT
      LOOP
          IF l_geo_hierarchy_id_tbl(i) = l_matched_geo_hierarchy_id THEN
            x_responsibility_id := l_responsibility_id_tbl(i);
            x_resp_map_rule_id := l_resp_map_rule_id_tbl(i);
            EXIT;
          END IF;
      END LOOP;
   END IF;

   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('get_default_resp: x_responsibility_id =' || x_responsibility_id);
      Debug_Log('get_default_resp: x_resp_map_rule_id =' || x_resp_map_rule_id);
   END IF;

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO get_default_resp;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO get_default_resp;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO get_default_resp;
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

END get_default_resp;

/*
* get_default_org_resp
* This is to get the default responsibility using partner_org_id and user_rold
* This will be used only during partner self_service flow as partner_id does
* not exist before calling this API.
*/
PROCEDURE get_default_org_resp(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_partner_org_id             IN   NUMBER
   ,p_user_role_code             IN   VARCHAR2
   ,x_responsibility_id          OUT  NOCOPY NUMBER
   ,x_resp_map_rule_id           OUT  NOCOPY NUMBER
)
IS
   CURSOR c_get_resp_map_rule_info (cv_user_role_code VARCHAR2) IS
      SELECT resp_map_rule_id, geo_hierarchy_id, responsibility_id
      FROM   pv_ge_resp_map_rules
      WHERE  user_role_code = cv_user_role_code
      AND    program_id is null
      AND    delete_flag = 'N';

   CURSOR c_get_area1_resp (cv_user_role_code VARCHAR2) IS
      SELECT rmr.resp_map_rule_id, rmr.responsibility_id
      FROM   pv_ge_resp_map_rules rmr, jtf_loc_hierarchies_vl lh
      WHERE  rmr.user_role_code = p_user_role_code
      AND    rmr.program_id is null
      AND    rmr.geo_hierarchy_id = lh.location_hierarchy_id
      AND    lh.location_type_code = 'AREA1'
      AND    rmr.delete_flag = 'N';

   l_api_name                  CONSTANT  VARCHAR2(30) := 'get_default_org_resp';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_geo_hierarchy_id_tbl      JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_responsibility_id_tbl     JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_resp_map_rule_id_tbl      JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_index                     NUMBER;
   l_matched_geo_hierarchy_id  NUMBER;
   l_responsibility_id                   NUMBER;


BEGIN
  ---- Initialize----------------

   -- Standard Start of API savepoint
   SAVEPOINT get_default_org_resp;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                      ,p_api_version_number
                                      ,l_api_name
                                      ,G_PKG_NAME
                                      )
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_Boolean( p_init_msg_list )
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('PRIVATE API: ' || l_api_name || ' - START');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   l_index := 1;
   FOR x IN c_get_resp_map_rule_info(p_user_role_code)
   LOOP
      l_geo_hierarchy_id_tbl.extend;
      l_geo_hierarchy_id_tbl(l_index) := x.geo_hierarchy_id;
      l_responsibility_id_tbl.extend;
      l_responsibility_id_tbl(l_index) := x.responsibility_id;
      l_resp_map_rule_id_tbl.extend;
      l_resp_map_rule_id_tbl(l_index) := x.resp_map_rule_id;
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('get_default_org_resp: l_index = ' || l_index);
         Debug_Log('get_default_org_resp: l_geo_hierarchy_id_tbl(l_index) = ' || l_geo_hierarchy_id_tbl(l_index));
         Debug_Log('get_default_org_resp: l_responsibility_id_tbl(l_index) = ' || l_responsibility_id_tbl(l_index));
         Debug_Log('get_default_org_resp: l_resp_map_rule_id_tbl(l_index) = ' || l_resp_map_rule_id_tbl(l_index));
      END IF;
      l_index := l_index + 1;
   END LOOP;

   PV_PARTNER_GEO_MATCH_PVT.Get_Ptnr_Org_Matched_Geo_Id (
      p_api_version_number         => p_api_version_number
     ,p_init_msg_list              => FND_API.G_FALSE
     ,x_return_status              => x_return_status
     ,x_msg_count                  => x_msg_count
     ,x_msg_data                   => x_msg_data
     ,p_party_id                   => p_partner_org_id
     ,p_geo_hierarchy_id           => l_geo_hierarchy_id_tbl
     ,x_geo_hierarchy_id           => l_matched_geo_hierarchy_id
   );

   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

   -- if l_matched_geo_hierarchy_id is null
   -- most likely the partner doesn't have address in database
   IF l_matched_geo_hierarchy_id is null THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('get_default_org_resp: l_matched_geo_hierarchy_id is null');
      END IF;
      FOR x IN c_get_area1_resp(p_user_role_code)
      LOOP
         x_responsibility_id := x.responsibility_id;
         x_resp_map_rule_id := x.resp_map_rule_id;
      END LOOP;
      IF ((x_responsibility_id is null) or (x_resp_map_rule_id is null)) THEN
        FND_MESSAGE.set_name('PV', 'PV_NO_DEFLT_RESP');
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
   ELSE
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('get_default_org_resp: l_matched_geo_hierarchy_id =' || l_matched_geo_hierarchy_id);
      END IF;
      FOR i IN 1..l_geo_hierarchy_id_tbl.COUNT
      LOOP
          IF l_geo_hierarchy_id_tbl(i) = l_matched_geo_hierarchy_id THEN
            x_responsibility_id := l_responsibility_id_tbl(i);
            x_resp_map_rule_id := l_resp_map_rule_id_tbl(i);
            EXIT;
          END IF;
      END LOOP;
   END IF;

   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('get_default_org_resp: x_responsibility_id =' || x_responsibility_id);
      Debug_Log('get_default_org_resp: x_resp_map_rule_id =' || x_resp_map_rule_id);
   END IF;

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO get_default_org_resp;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO get_default_org_resp;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO get_default_org_resp;
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

END get_default_org_resp;

/*
* get_program_resp
* This is to get the program responsibility using partner_id, user_rold, and program_id
*/
PROCEDURE get_program_resp(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_partner_id                 IN   NUMBER
   ,p_user_role_code             IN   VARCHAR2
   ,p_program_id                 IN   NUMBER
   ,x_responsibility_id          OUT  NOCOPY NUMBER
   ,x_resp_map_rule_id           OUT  NOCOPY NUMBER
)
IS
   CURSOR c_get_resp_map_rule_info (cv_user_role_code VARCHAR2, cv_program_id NUMBER) IS
      SELECT resp_map_rule_id, geo_hierarchy_id, responsibility_id
      FROM   pv_ge_resp_map_rules
      WHERE  user_role_code = cv_user_role_code
      AND    program_id = cv_program_id
      AND    delete_flag = 'N';

   CURSOR c_get_area1_resp (cv_user_role_code VARCHAR2, cv_program_id NUMBER) IS
      SELECT rmr.resp_map_rule_id, rmr.responsibility_id
      FROM   pv_ge_resp_map_rules rmr, jtf_loc_hierarchies_vl lh
      WHERE  rmr.user_role_code = p_user_role_code
      AND    rmr.program_id = cv_program_id
      AND    rmr.geo_hierarchy_id = lh.location_hierarchy_id
      AND    lh.location_type_code = 'AREA1'
      AND    rmr.delete_flag = 'N';

   l_api_name                  CONSTANT  VARCHAR2(30) := 'get_program_resp';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_geo_hierarchy_id_tbl      JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_responsibility_id_tbl     JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_resp_map_rule_id_tbl      JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_index                     NUMBER;
   l_matched_geo_hierarchy_id  NUMBER;
   l_responsibility_id                   NUMBER;

BEGIN
  ---- Initialize----------------

   -- Standard Start of API savepoint
   SAVEPOINT get_program_resp;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                      ,p_api_version_number
                                      ,l_api_name
                                      ,G_PKG_NAME
                                      )
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_Boolean( p_init_msg_list )
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('PRIVATE API: ' || l_api_name || ' - START');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   l_index := 1;
   FOR x IN c_get_resp_map_rule_info(p_user_role_code, p_program_id)
   LOOP
      l_geo_hierarchy_id_tbl.extend;
      l_geo_hierarchy_id_tbl(l_index) := x.geo_hierarchy_id;
      l_responsibility_id_tbl.extend;
      l_responsibility_id_tbl(l_index) := x.responsibility_id;
      l_resp_map_rule_id_tbl.extend;
      l_resp_map_rule_id_tbl(l_index) := x.resp_map_rule_id;

      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('get_program_resp: l_geo_hierarchy_id_tbl('||l_index||')='||l_geo_hierarchy_id_tbl(l_index));
         Debug_Log('get_program_resp: l_responsibility_id_tbl('||l_index||')='||l_responsibility_id_tbl(l_index));
         Debug_Log('get_program_resp: l_resp_map_rule_id_tbl('||l_index||')='||l_resp_map_rule_id_tbl(l_index));
      END IF;
      l_index := l_index + 1;
   END LOOP;

   PV_PARTNER_GEO_MATCH_PVT.Get_Ptnr_Matched_Geo_Id (
      p_api_version_number         => p_api_version_number
     ,p_init_msg_list              => FND_API.G_FALSE
     ,x_return_status              => x_return_status
     ,x_msg_count                  => x_msg_count
     ,x_msg_data                   => x_msg_data
     ,p_partner_id                 => p_partner_id
     ,p_geo_hierarchy_id           => l_geo_hierarchy_id_tbl
     ,x_geo_hierarchy_id           => l_matched_geo_hierarchy_id
   );

   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

   -- if l_matched_geo_hierarchy_id is null
   -- most likely the partner doesn't have address in database
   IF l_matched_geo_hierarchy_id is null THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('get_program_resp: l_matched_geo_hierarchy_id is null - get resp of AREA1');
      END IF;
      FOR x IN c_get_area1_resp(p_user_role_code, p_program_id)
      LOOP
         x_responsibility_id := x.responsibility_id;
         x_resp_map_rule_id := x.resp_map_rule_id;
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('get_program_resp: x_responsibility_id = ' || x_responsibility_id);
            Debug_Log('get_program_resp: x_resp_map_rule_id = ' || x_resp_map_rule_id);
         END IF;
      END LOOP;
   ELSE
      FOR i IN 1..l_geo_hierarchy_id_tbl.COUNT
      LOOP
          IF l_geo_hierarchy_id_tbl(i) = l_matched_geo_hierarchy_id THEN
            x_responsibility_id := l_responsibility_id_tbl(i);
            x_resp_map_rule_id := l_resp_map_rule_id_tbl(i);
            IF (PV_DEBUG_HIGH_ON) THEN
               Debug_Log('get_program_resp: x_responsibility_id = ' || x_responsibility_id);
               Debug_Log('get_program_resp: x_resp_map_rule_id = ' || x_resp_map_rule_id);
            END IF;
            EXIT;
          END IF;
      END LOOP;
   END IF;
   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO get_program_resp;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO get_program_resp;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO get_program_resp;
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

END get_program_resp;

/*
* get_store_prgm_resps
* This is to get the all store responsibilities of a given partner
*/

PROCEDURE get_store_prgm_resps(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_partner_id                 IN   JTF_NUMBER_TABLE
   ,x_responsibility_id          OUT  NOCOPY JTF_NUMBER_TABLE
   ,x_resp_map_rule_id           OUT  NOCOPY JTF_NUMBER_TABLE
)
IS
   CURSOR get_resp_id IS
	SELECT ben.benefit_id, ben.program_benefits_id
	FROM  pv_program_benefits ben
	WHERE
	ben.benefit_type_code = 'STORES'
	AND ben.delete_flag = 'N'
	AND ben.program_id in
	(
	SELECT program_id
	FROM pv_partner_program_b
            START WITH program_id in
            (
             SELECT /*+ leading(T) USE_NL(T MEM)*/ mem.program_id
             FROM  pv_pg_memberships mem, (SELECT column_value FROM TABLE (CAST(p_partner_id AS JTF_NUMBER_TABLE))) t
             WHERE mem.partner_id = t.column_value
                   AND    mem.membership_status_code = 'ACTIVE'
            )
            CONNECT BY PRIOR program_parent_id = program_id
	);

   l_api_name                  CONSTANT  VARCHAR2(30) := 'get_store_prgm_resps';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_responsibility_id         JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_resp_map_rule_id          JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   i                           NUMBER;

BEGIN
  ---- Initialize----------------

   -- Standard Start of API savepoint
   SAVEPOINT get_store_prgm_resps;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                      ,p_api_version_number
                                      ,l_api_name
                                      ,G_PKG_NAME
                                      )
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_Boolean( p_init_msg_list )
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('PRIVATE API: ' || l_api_name || ' - START');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   i := 1;
   FOR x in get_resp_id LOOP
      IF (PV_DEBUG_HIGH_ON) THEN
        Debug_Log('get_store_prgm_resps: x.benefit_id = ' || x.benefit_id);
        Debug_Log('get_program_resp: x_resp_map_rule_id = ' || x.program_benefits_id);
      END IF;
      l_responsibility_id.extend;
      l_resp_map_rule_id.extend;
      l_responsibility_id(i) := x.benefit_id;
      l_resp_map_rule_id(i) := x.program_benefits_id;
      i := i + 1;
   END LOOP;

   x_responsibility_id := l_responsibility_id;
   x_resp_map_rule_id := l_resp_map_rule_id;

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO get_store_prgm_resps;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO get_store_prgm_resps;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO get_store_prgm_resps;
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

END get_store_prgm_resps;


/*
* get_store_prgm_resps
* This is to get the all store responsibilities of a given program_id
*/

PROCEDURE get_store_prgm_resps(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_program_id                 IN   NUMBER
   ,x_responsibility_id          OUT  NOCOPY JTF_NUMBER_TABLE
   ,x_resp_map_rule_id           OUT  NOCOPY JTF_NUMBER_TABLE
)
IS
   CURSOR get_resp_id IS
      SELECT ben.benefit_id, ben.program_benefits_id
      FROM   pv_program_benefits ben
      WHERE  ben.program_id IN (
                SELECT program_id
                FROM pv_partner_program_b
                START WITH program_id = p_program_id
                CONNECT BY PRIOR program_parent_id = program_id
             )
      AND    ben.benefit_type_code = 'STORES'
      AND    ben.delete_flag = 'N';

   l_api_name                  CONSTANT  VARCHAR2(30) := 'get_store_prgm_resps';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_responsibility_id         JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_resp_map_rule_id          JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   i                           NUMBER;

BEGIN
  ---- Initialize----------------

   -- Standard Start of API savepoint
   SAVEPOINT get_store_prgm_resps;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                      ,p_api_version_number
                                      ,l_api_name
                                      ,G_PKG_NAME
                                      )
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_Boolean( p_init_msg_list )
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('PRIVATE API: ' || l_api_name || ' - START');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   i := 1;
   FOR x in get_resp_id LOOP
      IF (PV_DEBUG_HIGH_ON) THEN
        Debug_Log('get_store_prgm_resps: x.benefit_id = ' || x.benefit_id);
        Debug_Log('get_program_resp: x_resp_map_rule_id = ' || x.program_benefits_id);
      END IF;
      l_responsibility_id.extend;
      l_resp_map_rule_id.extend;
      l_responsibility_id(i) := x.benefit_id;
      l_resp_map_rule_id(i) := x.program_benefits_id;
      i := i + 1;
   END LOOP;

   x_responsibility_id := l_responsibility_id;
   x_resp_map_rule_id := l_resp_map_rule_id;

   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('PRIVATE API: ' || l_api_name || ' - END');
   END IF;

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO get_store_prgm_resps;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO get_store_prgm_resps;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO get_store_prgm_resps;
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

END get_store_prgm_resps;

/************
 * This API will do the following three things:
 * 1. Get the default responsibility.
 * 2. Assign that to all the users passed in.
 * 3. Add a new row to the pv_ge_ptnr_resps table.
 ************/
PROCEDURE get_default_assign_addrow(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_user_role_code             IN   VARCHAR2
   ,p_user_ids_tbl               IN   JTF_NUMBER_TABLE
   ,p_partner_id                 IN   NUMBER
)
IS
   l_api_name              CONSTANT  VARCHAR2(30) := 'get_default_assign_addrow';
   l_exist                 NUMBER;
   l_responsibility_id     NUMBER;
   l_resp_map_rule_id      NUMBER;
   l_ge_ptnr_resps_rec     PV_Ge_Ptnr_Resps_PVT.ge_ptnr_resps_rec_type;
   l_ptnr_resp_id          NUMBER;
   l_user_ids_tbl          JTF_NUMBER_TABLE;

BEGIN
  ---- Initialize----------------

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_Boolean( p_init_msg_list )
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('PRIVATE API: ' || l_api_name || ' - START');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   get_default_resp(
       p_api_version_number         => p_api_version_number
      ,p_init_msg_list              => FND_API.G_FALSE
      ,p_commit                     => FND_API.G_FALSE
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,p_partner_id                 => p_partner_id
      ,p_user_role_code             => p_user_role_code
      ,x_responsibility_id          => l_responsibility_id
      ,x_resp_map_rule_id           => l_resp_map_rule_id
   );
   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('get_default_assign_addrow: l_responsibility_id = ' || l_responsibility_id);
      Debug_Log('get_default_assign_addrow: l_resp_map_rule_id = ' || l_resp_map_rule_id);
   END IF;

   -- Fixed for bug 3533631.
   IF (p_user_ids_tbl is null) THEN
      Debug_Log('get_default_assign_addrow: p_user_ids_tbl is null');
      l_user_ids_tbl := get_partner_users(p_partner_id, p_user_role_code);
   ELSE
      l_user_ids_tbl := p_user_ids_tbl;
   END IF;

   IF (l_responsibility_id is not null) and (l_resp_map_rule_id is not null) THEN
      FOR l_cnt IN 1..l_user_ids_tbl.count LOOP
         assign_resp(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,p_user_id                    => l_user_ids_tbl(l_cnt)
            ,p_resp_id                    => l_responsibility_id
            ,p_app_id                     => 691
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END LOOP;

      /****
       * API to add a row to pv_ge_ptnr_resps
       ****/
      l_ge_ptnr_resps_rec.partner_id := p_partner_id;
      l_ge_ptnr_resps_rec.user_role_code := p_user_role_code;
      l_ge_ptnr_resps_rec.responsibility_id := l_responsibility_id;
      l_ge_ptnr_resps_rec.source_resp_map_rule_id := l_resp_map_rule_id;
      l_ge_ptnr_resps_rec.resp_type_code := G_PROGRAM;

      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('get_default_assign_addrow: l_ge_ptnr_resps_rec.partner_id = ' || l_ge_ptnr_resps_rec.partner_id);
         Debug_Log('get_default_assign_addrow: l_ge_ptnr_resps_rec.user_role_code = ' || l_ge_ptnr_resps_rec.user_role_code);
         Debug_Log('get_default_assign_addrow: l_ge_ptnr_resps_rec.responsibility_id = ' || l_ge_ptnr_resps_rec.responsibility_id);
         Debug_Log('get_default_assign_addrow: l_ge_ptnr_resps_rec.source_resp_map_rule_id = ' || l_ge_ptnr_resps_rec.source_resp_map_rule_id);
         Debug_Log('get_default_assign_addrow: l_ge_ptnr_resps_rec.resp_type_code = ' || l_ge_ptnr_resps_rec.resp_type_code);
      END IF;

      PV_Ge_Ptnr_Resps_PVT.Create_Ge_Ptnr_Resps(
          p_api_version_number         => p_api_version_number
         ,p_init_msg_list              => FND_API.G_FALSE
         ,p_commit                     => FND_API.G_FALSE
         ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL

         ,x_return_status              => x_return_status
         ,x_msg_count                  => x_msg_count
         ,x_msg_data                   => x_msg_data
         ,p_ge_ptnr_resps_rec          => l_ge_ptnr_resps_rec
         ,x_ptnr_resp_id               => l_ptnr_resp_id
      );

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   ELSE
      FND_MESSAGE.set_name('PV', 'PV_NO_DEFAULT_RESP');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

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

END get_default_assign_addrow;

/*
* assign_first_user_resp
* This public API will be called during partner self service registration.
*/
PROCEDURE assign_first_user_resp(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_resp_map_rule_id           IN   NUMBER
   ,p_responsibility_id          IN   NUMBER
   ,p_partner_id                 IN   NUMBER
   ,p_user_id                    IN   NUMBER
)
IS
   l_api_name                  CONSTANT  VARCHAR2(30) := 'assign_first_user_resp';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_ptnr_resp_id              NUMBER;
   l_ge_ptnr_resps_rec         PV_Ge_Ptnr_Resps_PVT.ge_ptnr_resps_rec_type;

BEGIN
  ---- Initialize----------------

   -- Standard Start of API savepoint
   SAVEPOINT assign_first_user_resp;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                      ,p_api_version_number
                                      ,l_api_name
                                      ,G_PKG_NAME
                                      )
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_Boolean( p_init_msg_list )
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('PRIVATE API: ' || l_api_name || ' - START');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

   assign_resp (
       p_api_version_number         => p_api_version_number
      ,p_init_msg_list              => FND_API.G_FALSE
      ,p_commit                     => FND_API.G_FALSE
      ,p_user_id                    => p_user_id
      ,p_resp_id                    => p_responsibility_id
      ,p_app_id                     => 691
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
   );

   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
    END IF;

   /****
    * API to add a row to pv_ge_ptnr_resps
    ****/
   l_ge_ptnr_resps_rec.partner_id := p_partner_id;
   l_ge_ptnr_resps_rec.user_role_code := G_PRIMARY;
   l_ge_ptnr_resps_rec.responsibility_id := p_responsibility_id;
   l_ge_ptnr_resps_rec.source_resp_map_rule_id := p_resp_map_rule_id;
   l_ge_ptnr_resps_rec.resp_type_code := G_PROGRAM;

   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('assign_first_user_resp: l_ge_ptnr_resps_rec.partner_id = ' || l_ge_ptnr_resps_rec.partner_id);
      Debug_Log('assign_first_user_resp: l_ge_ptnr_resps_rec.user_role_code = ' || l_ge_ptnr_resps_rec.user_role_code);
      Debug_Log('assign_first_user_resp: l_ge_ptnr_resps_rec.responsibility_id = ' || l_ge_ptnr_resps_rec.responsibility_id);
      Debug_Log('assign_first_user_resp: l_ge_ptnr_resps_rec.source_resp_map_rule_id = ' || l_ge_ptnr_resps_rec.source_resp_map_rule_id);
      Debug_Log('assign_first_user_resp: l_ge_ptnr_resps_rec.resp_type_code = ' || l_ge_ptnr_resps_rec.resp_type_code);
   END IF;

   PV_Ge_Ptnr_Resps_PVT.Create_Ge_Ptnr_Resps(
       p_api_version_number         => p_api_version_number
      ,p_init_msg_list              => FND_API.G_FALSE
      ,p_commit                     => FND_API.G_FALSE
      ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL

      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,p_ge_ptnr_resps_rec          => l_ge_ptnr_resps_rec
      ,x_ptnr_resp_id               => l_ptnr_resp_id
   );

   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO assign_first_user_resp;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO assign_first_user_resp;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO assign_first_user_resp;
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

END assign_first_user_resp;

/*
* assign_user_resps
* This public API will be called during additional user registration of
* an existing partner, when an existing user becomes a partner user,
* and when partner contact resource is actived.
*/
PROCEDURE assign_user_resps(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_user_id                    IN   NUMBER
   ,p_user_role_code             IN   VARCHAR2
)
IS
   CURSOR c_get_resp_id (cv_partner_id JTF_NUMBER_TABLE, cv_user_role_code VARCHAR2, cv_resp_type_code VARCHAR2) IS
      SELECT /*+ CARDINALITY(t 10) */ responsibility_id
      FROM   pv_ge_ptnr_resps,
	     (SELECT * FROM TABLE (CAST(cv_partner_id AS JTF_NUMBER_TABLE))) t
      WHERE  partner_id = t.column_value
      AND    user_role_code = cv_user_role_code
      AND    resp_type_code = cv_resp_type_code;

   CURSOR c_get_program_id (cv_partner_id JTF_NUMBER_TABLE) IS
      SELECT /*+ CARDINALITY(t 10) */ program_id, partner_id
      FROM   pv_pg_memberships,
	     (SELECT * FROM TABLE (CAST(cv_partner_id AS JTF_NUMBER_TABLE))) t
      WHERE  partner_id = t.column_value
      AND    membership_status_code = 'ACTIVE';

   l_api_name                  CONSTANT  VARCHAR2(30) := 'assign_user_resps';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_responsibility_id_tbl         JTF_NUMBER_TABLE;
   l_responsibility_id         NUMBER;
   l_resp_map_rule_id          NUMBER;
   l_partner_ids_tbl           JTF_NUMBER_TABLE;
   l_resp_exist                VARCHAR(1) := 'N';
   l_ge_ptnr_resps_rec         PV_Ge_Ptnr_Resps_PVT.ge_ptnr_resps_rec_type;
   l_ptnr_resp_id              NUMBER;
   l_user_ids_tbl              JTF_NUMBER_TABLE;
BEGIN
  ---- Initialize----------------

   -- Standard Start of API savepoint
   SAVEPOINT assign_user_resps;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                      ,p_api_version_number
                                      ,l_api_name
                                      ,G_PKG_NAME
                                      )
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_Boolean( p_init_msg_list )
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('PRIVATE API: ' || l_api_name || ' - START');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   l_partner_ids_tbl := get_partners(p_user_id);

   IF (l_partner_ids_tbl.count = 0) THEN
       FND_MESSAGE.set_name('PV', 'PV_INVALID_PTNR_USER');
       FND_MSG_PUB.add;
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('assign_user_resps: l_partner_ids_tbl.count: ' || l_partner_ids_tbl.count);
   END IF;

   FOR x IN c_get_resp_id (l_partner_ids_tbl, p_user_role_code, G_PROGRAM) LOOP
      l_resp_exist := 'Y';
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('assign_user_resps: x.responsibility_id: ' || x.responsibility_id);
      END IF;
      assign_resp (
          p_api_version_number         => p_api_version_number
         ,p_init_msg_list              => FND_API.G_FALSE
         ,p_commit                     => FND_API.G_FALSE
         ,p_user_id                    => p_user_id
         ,p_resp_id                    => x.responsibility_id
         ,p_app_id                     => 691
         ,x_return_status              => x_return_status
         ,x_msg_count                  => x_msg_count
         ,x_msg_data                   => x_msg_data
      );
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END LOOP;

   IF (l_resp_exist = 'N') THEN
      FOR x IN c_get_program_id (l_partner_ids_tbl) LOOP
         l_responsibility_id := null;
         l_resp_map_rule_id := null;
         get_program_resp(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
            ,p_partner_id                 => x.partner_id
            ,p_user_role_code             => p_user_role_code
            ,p_program_id                 => x.program_id
            ,x_responsibility_id          => l_responsibility_id
            ,x_resp_map_rule_id           => l_resp_map_rule_id
         );

         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('assign_user_resps: l_responsibility_id = ' || l_responsibility_id);
            Debug_Log('assign_user_resps: l_resp_map_rule_id = ' || l_resp_map_rule_id);
         END IF;

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
         IF (l_responsibility_id is not null) and (l_resp_map_rule_id is not null) THEN
            l_resp_exist := 'Y';
            assign_resp (
                p_api_version_number         => p_api_version_number
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,p_user_id                    => p_user_id
               ,p_resp_id                    => l_responsibility_id
               ,p_app_id                     => 691
               ,x_return_status              => x_return_status
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
            );
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;

            /****
             * API to add a row to pv_ge_ptnr_resps
             ****/
            l_ge_ptnr_resps_rec.partner_id := x.partner_id;
            l_ge_ptnr_resps_rec.user_role_code := p_user_role_code;
            l_ge_ptnr_resps_rec.program_id := x.program_id;
            l_ge_ptnr_resps_rec.responsibility_id := l_responsibility_id;
            l_ge_ptnr_resps_rec.source_resp_map_rule_id := l_resp_map_rule_id;
            l_ge_ptnr_resps_rec.resp_type_code := G_PROGRAM;

            IF (PV_DEBUG_HIGH_ON) THEN
               Debug_Log('assign_user_resps: l_ge_ptnr_resps_rec.partner_id = ' || l_ge_ptnr_resps_rec.partner_id);
               Debug_Log('assign_user_resps: l_ge_ptnr_resps_rec.user_role_code = ' || l_ge_ptnr_resps_rec.user_role_code);
               Debug_Log('assign_user_resps: l_ge_ptnr_resps_rec.program_id = ' || l_ge_ptnr_resps_rec.program_id);
               Debug_Log('assign_user_resps: l_ge_ptnr_resps_rec.responsibility_id = ' || l_ge_ptnr_resps_rec.responsibility_id);
               Debug_Log('assign_user_resps: l_ge_ptnr_resps_rec.source_resp_map_rule_id = ' || l_ge_ptnr_resps_rec.source_resp_map_rule_id);
               Debug_Log('assign_user_resps: l_ge_ptnr_resps_rec.resp_type_code = ' || l_ge_ptnr_resps_rec.resp_type_code);
            END IF;

            PV_Ge_Ptnr_Resps_PVT.Create_Ge_Ptnr_Resps(
                p_api_version_number         => p_api_version_number
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL

               ,x_return_status              => x_return_status
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
               ,p_ge_ptnr_resps_rec          => l_ge_ptnr_resps_rec
               ,x_ptnr_resp_id               => l_ptnr_resp_id
            );
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;
      END LOOP;
   END IF;
   -- If there is no program responsibility (l_resp_exist still equals to 'N'),
   -- get the default responsibility and assign it to the user
   IF (l_resp_exist = 'N') THEN
      l_user_ids_tbl := JTF_NUMBER_TABLE();
      l_user_ids_tbl.extend;
      l_user_ids_tbl(1) := p_user_id;
      FOR l_cnt IN 1..l_partner_ids_tbl.count LOOP
         get_default_assign_addrow(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
            ,p_user_role_code             => p_user_role_code
            ,p_user_ids_tbl               => l_user_ids_tbl
            ,p_partner_id                 => l_partner_ids_tbl(l_cnt)
         );

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END LOOP;
   END IF;

   -- Store responsibility
   FOR x IN c_get_resp_id (l_partner_ids_tbl, G_ALL, G_STORE) LOOP
      l_resp_exist := 'Y';
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('assign_user_resps: Store x.responsibility_id: ' || x.responsibility_id);
      END IF;
      assign_resp (
         p_api_version_number         => p_api_version_number
        ,p_init_msg_list              => FND_API.G_FALSE
        ,p_commit                     => FND_API.G_FALSE
        ,p_user_id                    => p_user_id
        ,p_resp_id                    => x.responsibility_id
        ,p_app_id                     => 671
        ,x_return_status              => x_return_status
        ,x_msg_count                  => x_msg_count
        ,x_msg_data                   => x_msg_data
      );
      IF (PV_DEBUG_HIGH_ON) THEN
        Debug_Log('assign_user_resps: after assign_resp');
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
   END LOOP; -- End of FOR x IN c_get_resp_id (l_partner_ids_tbl, p_user_role_code, G_STORE)

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO assign_user_resps;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO assign_user_resps;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO assign_user_resps;
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

END assign_user_resps;

/*
* assign_user_resps
* This public API will be called during additional user registration of
* an existing partner, when an existing user becomes a partner user,
* and when partner contact resource is actived.
*/
PROCEDURE assign_user_resps(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_user_name                  IN   VARCHAR2
)
IS
   CURSOR c_get_user_id IS
      select usr.user_id
      from   jtf_rs_resource_extns extn, fnd_user usr
      where  extn.user_id     = usr.user_id
      and    usr.user_name	   = p_user_name;

   l_api_name                  CONSTANT  VARCHAR2(30) := 'assign_user_resps';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_user_role_code            VARCHAR2(30);

BEGIN
  ---- Initialize----------------

   -- Standard Start of API savepoint
   SAVEPOINT assign_user_resps_2;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                      ,p_api_version_number
                                      ,l_api_name
                                      ,G_PKG_NAME
                                      )
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_Boolean( p_init_msg_list )
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('PRIVATE API: ' || l_api_name || ' - START');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   FOR x IN c_get_user_id LOOP
      get_user_role_code (
          p_user_id        => x.user_id
         ,x_user_role_code => l_user_role_code
      );

      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('assign_user_resps_2: l_user_role_code = ' || l_user_role_code);
      END IF;
      assign_user_resps(
          p_api_version_number         => p_api_version_number
         ,p_init_msg_list              => FND_API.G_FALSE
         ,p_commit                     => FND_API.G_FALSE
         ,x_return_status              => x_return_status
         ,x_msg_count                  => x_msg_count
         ,x_msg_data                   => x_msg_data
         ,p_user_id                    => x.user_id
         ,p_user_role_code             => l_user_role_code
      );
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END LOOP;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('PRIVATE API: ' || l_api_name || ' - END');
   END IF;

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO assign_user_resps_2;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO assign_user_resps_2;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO assign_user_resps_2;
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
END assign_user_resps;


/*
 * switch_user_resp
 * This public API will be called when user role is switched from primary to
 * non-primary or viceversa.
 */
PROCEDURE switch_user_resp(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_user_id                    IN   NUMBER
   ,p_from_user_role_code        IN   VARCHAR2
   ,p_to_user_role_code          IN   VARCHAR2
)
IS
   CURSOR c_get_respid_and_action (cv_partner_id JTF_NUMBER_TABLE, cv_user_id NUMBER, cv_from_user_role_code VARCHAR2, cv_to_user_role_code VARCHAR2) IS
      (SELECT /*+LEADING(T) USE_NL(t p f)*/ p.responsibility_id, 'REVOKE' action, f.responsibility_application_id, f.security_group_id, f.start_date, f.description
       FROM   pv_ge_ptnr_resps p, fnd_user_resp_groups f
       WHERE  partner_id in (
                 SELECT  * FROM TABLE (CAST(cv_partner_id AS JTF_NUMBER_TABLE))
              )
       AND    p.user_role_code = cv_from_user_role_code
       AND    p.responsibility_id = f.responsibility_id
       AND    f.user_id = cv_user_id
       AND    p.resp_type_code = G_PROGRAM
       MINUS
       SELECT /*+LEADING(T) USE_NL(t p f)*/ p.responsibility_id, 'REVOKE' action, f.responsibility_application_id, f.security_group_id, f.start_date, f.description
       FROM   pv_ge_ptnr_resps p, fnd_user_resp_groups f
       WHERE  partner_id in (
                 SELECT  * FROM TABLE (CAST(cv_partner_id AS JTF_NUMBER_TABLE))
              )
       AND    p.user_role_code = cv_to_user_role_code
       AND    p.responsibility_id = f.responsibility_id
       AND    f.user_id = cv_user_id
       AND    p.resp_type_code = G_PROGRAM
      )
      UNION
      (SELECT /*+LEADING(T) USE_NL(t p f)*/ p.responsibility_id, 'ASSIGN' action, f.responsibility_application_id, f.security_group_id, f.start_date, f.description
       FROM   pv_ge_ptnr_resps p, fnd_user_resp_groups f
       WHERE  partner_id in (
                 SELECT  * FROM TABLE (CAST(cv_partner_id AS JTF_NUMBER_TABLE))
              )
       AND    p.user_role_code = cv_to_user_role_code
       AND    p.responsibility_id = f.responsibility_id
       AND    f.user_id = cv_user_id
       AND    p.resp_type_code = G_PROGRAM
       MINUS
       SELECT /*+LEADING(T) USE_NL(t p f)*/ p.responsibility_id, 'ASSIGN' action, f.responsibility_application_id, f.security_group_id, f.start_date, f.description
       FROM   pv_ge_ptnr_resps p, fnd_user_resp_groups f
       WHERE  partner_id in (
                 SELECT  * FROM TABLE (CAST(cv_partner_id AS JTF_NUMBER_TABLE))
              )
       AND    p.user_role_code = cv_from_user_role_code
       AND    p.responsibility_id = f.responsibility_id
       AND    f.user_id = cv_user_id
       AND    p.resp_type_code = G_PROGRAM
      );

   l_api_name                  CONSTANT  VARCHAR2(30) := 'switch_user_resp';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_partner_ids_tbl           JTF_NUMBER_TABLE;
    l_is_resp_assigned   boolean := false;

BEGIN
  ---- Initialize----------------

   -- Standard Start of API savepoint
   SAVEPOINT switch_user_resp;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                      ,p_api_version_number
                                      ,l_api_name
                                      ,G_PKG_NAME
                                      )
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_Boolean( p_init_msg_list )
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('PRIVATE API: ' || l_api_name || ' - START');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   l_partner_ids_tbl := get_partners(p_user_id);

   IF (l_partner_ids_tbl.count = 0) THEN
       FND_MESSAGE.set_name('PV', 'PV_INVALID_PTNR_USER');
       FND_MSG_PUB.add;
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   FOR x in c_get_respid_and_action (l_partner_ids_tbl, p_user_id, p_from_user_role_code, p_to_user_role_code)
   LOOP
      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('switch_user_resp: In c_get_respid_and_action');
      END IF;
      IF x.action = 'ASSIGN' THEN
         -- Debug Message
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('switch_user_resp: ASSIGN');
         END IF;
         assign_resp (
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,p_user_id                    => p_user_id
            ,p_resp_id                    => x.responsibility_id
            ,p_app_id                     => 691
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
         );

	 l_is_resp_assigned := true;
      ELSIF x.action = 'REVOKE' THEN
         -- Debug Message
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('switch_user_resp: REVOKE');
            Debug_Log('switch_user_resp: x.responsibility_id = ' || x.responsibility_id);
            Debug_Log('switch_user_resp: x.responsibility_application_id = ' || x.responsibility_application_id);
            Debug_Log('switch_user_resp: x.security_group_id = ' || x.security_group_id);
            Debug_Log('switch_user_resp: x.start_date = ' || x.start_date);
            Debug_Log('switch_user_resp: x.description = ' || x.description);
         END IF;
         revoke_resp(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,p_user_id                    => p_user_id
            ,p_resp_id                    => x.responsibility_id
            ,p_app_id                     => x.responsibility_application_id
            ,p_security_group_id          => x.security_group_id
            ,p_start_date                 => x.start_date
            ,p_description                => x.description
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
         );
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END LOOP;


     IF (not l_is_resp_assigned) THEN
      pv_user_Resp_pvt.assign_user_resps(
      p_api_version_number         => p_api_version_number
     ,p_init_msg_list              => FND_API.g_false
     ,p_commit                     => FND_API.G_FALSE
     ,x_return_status              => x_return_status
     ,x_msg_count                  => x_msg_count
     ,x_msg_data                   => x_msg_data
     ,p_user_id                    => p_user_id
     ,p_user_role_code             => p_to_user_role_code
     );

       IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

   END IF;

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO switch_user_resp;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO switch_user_resp;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO switch_user_resp;
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

END switch_user_resp;

/************
 * This API will do the following three things:
 * 1. Revoke the old responsibility_id that passed in.
 * 2. Update the corresponding row (using p_ptnr_resp_id) in pv_ge_ptnr_resps.
 * 3. Assign the new responsibility_id that passed in.
************/
PROCEDURE revoke_update_assign(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_user_ids_tbl               IN   JTF_NUMBER_TABLE
   ,p_ptnr_resp_id               IN   NUMBER
   ,p_old_responsibility_id      IN   NUMBER
   ,p_new_responsibility_id      IN   NUMBER
   ,p_program_id                 IN   NUMBER       := null
   ,p_resp_map_rule_id           IN   NUMBER       := null
   ,p_object_version_number      IN   NUMBER
   ,p_is_revoke                  IN   VARCHAR2
)
IS
   l_api_name              CONSTANT  VARCHAR2(30) := 'revoke_update_assign';
   l_exist                 NUMBER;
   l_responsibility_id     NUMBER;
   l_resp_map_rule_id      NUMBER;
   l_ge_ptnr_resps_rec     PV_Ge_Ptnr_Resps_PVT.ge_ptnr_resps_rec_type;
   l_ptnr_resp_id          NUMBER;

BEGIN
  ---- Initialize----------------

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_Boolean( p_init_msg_list )
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('PRIVATE API: ' || l_api_name || ' - START');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   IF p_is_revoke = 'Y' THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('revoke_update_assign: p_old_responsibility_id' || p_old_responsibility_id);
      END IF;
      revoke_resp(
          p_api_version_number         => p_api_version_number
         ,p_init_msg_list              => FND_API.G_FALSE
         ,p_commit                     => FND_API.G_FALSE
         ,p_user_id                    => p_user_ids_tbl
         ,p_resp_id                    => p_old_responsibility_id
         ,x_return_status              => x_return_status
         ,x_msg_count                  => x_msg_count
         ,x_msg_data                   => x_msg_data
      );
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;

   /****
    * API to update the resp in pv_partner_memberships
    ****/
   l_ge_ptnr_resps_rec.ptnr_resp_id := p_ptnr_resp_id;
   l_ge_ptnr_resps_rec.responsibility_id := p_new_responsibility_id;
   IF p_resp_map_rule_id IS NOT NULL THEN
      l_ge_ptnr_resps_rec.source_resp_map_rule_id := p_resp_map_rule_id;
      Debug_Log('revoke_update_assign: l_ge_ptnr_resps_rec.source_resp_map_rule_id = ' || l_ge_ptnr_resps_rec.source_resp_map_rule_id);
   END IF;
   IF p_program_id IS NOT NULL THEN
      l_ge_ptnr_resps_rec.program_id := p_program_id;
      Debug_Log('revoke_update_assign: l_ge_ptnr_resps_rec.program_id = ' || l_ge_ptnr_resps_rec.program_id);
   END IF;
   l_ge_ptnr_resps_rec.object_version_number := p_object_version_number;

   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('revoke_update_assign: l_ge_ptnr_resps_rec.ptnr_resp_id = ' || l_ge_ptnr_resps_rec.ptnr_resp_id);
      Debug_Log('revoke_update_assign: l_ge_ptnr_resps_rec.responsibility_id = ' || l_ge_ptnr_resps_rec.responsibility_id);
      Debug_Log('revoke_update_assign: l_ge_ptnr_resps_rec.object_version_number = ' || l_ge_ptnr_resps_rec.object_version_number);
  END IF;

  PV_Ge_Ptnr_Resps_PVT.Update_Ge_Ptnr_Resps(
       p_api_version_number         => p_api_version_number
      ,p_init_msg_list              => FND_API.G_FALSE
      ,p_commit                     => FND_API.G_FALSE
      ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL

      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,p_ge_ptnr_resps_rec          => l_ge_ptnr_resps_rec
   );
   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
      x_return_status := FND_API.G_RET_STS_ERROR;
   END IF;

   FOR l_cnt IN 1..p_user_ids_tbl.count LOOP
      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('revoke_update_assign: p_new_responsibility_id' || p_new_responsibility_id);
      END IF;

      assign_resp(
          p_api_version_number         => p_api_version_number
         ,p_init_msg_list              => FND_API.G_FALSE
         ,p_commit                     => FND_API.G_FALSE
         ,p_user_id                    => p_user_ids_tbl(l_cnt)
         ,p_resp_id                    => p_new_responsibility_id
         ,p_app_id                     => 691
         ,x_return_status              => x_return_status
         ,x_msg_count                  => x_msg_count
         ,x_msg_data                   => x_msg_data
      );
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END LOOP;

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     RAISE FND_API.G_EXC_ERROR;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
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
END revoke_update_assign;

/*
 * manage_ter_exp_memb_resp
 * This private API gets called when membership is terminated or expired
 */
PROCEDURE manage_ter_exp_memb_resp(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_partner_id                 IN   NUMBER
   ,p_program_id                 IN   NUMBER
)
IS

   CURSOR c_get_partner_resp_info(cv_resp_type_code VARCHAR2) IS
      SELECT ptnr_resp_id, user_role_code, responsibility_id, object_version_number
      FROM   pv_ge_ptnr_resps
      WHERE  partner_id = p_partner_id
      AND    program_id = p_program_id
      AND    resp_type_code = cv_resp_type_code;

   -- Get the resp id of all other partners which have the same
   -- partner_party_id of the pass in partner
   CURSOR c_get_other_resp_id(cv_user_role_code VARCHAR2, cv_resp_type_code VARCHAR2) IS
      SELECT responsibility_id
      FROM   pv_ge_ptnr_resps
      WHERE  partner_id in (
                SELECT partner_id
                FROM   pv_partner_profiles
                WHERE  partner_party_id in (
                          SELECT partner_party_id
                          FROM pv_partner_profiles
                          WHERE partner_id = p_partner_id
                       )
                AND    partner_id <> p_partner_id
             )
       AND   user_role_code = cv_user_role_code
       AND   resp_type_code = cv_resp_type_code;

   CURSOR c_get_count (cv_partner_id NUMBER, cv_user_role_code VARCHAR2, cv_responsibility_id NUMBER, cv_resp_type_code VARCHAR2) IS
      SELECT count(*)
      FROM   pv_ge_ptnr_resps
      WHERE  partner_id = cv_partner_id
         AND user_role_code = cv_user_role_code
         AND responsibility_id = cv_responsibility_id
         AND resp_type_code = cv_resp_type_code;

   CURSOR c_check_prgm_resp_exist (cv_partner_id NUMBER, cv_user_role_code VARCHAR2) IS
      SELECT 1
      FROM   pv_ge_ptnr_resps
      WHERE  partner_id = cv_partner_id
      AND    user_role_code = cv_user_role_code
      AND    resp_type_code = G_PROGRAM;

   l_api_name                 CONSTANT  VARCHAR2(30) := 'manage_ter_exp_memb_resp';
   l_api_version_number       CONSTANT NUMBER   := 1.0;
   l_user_ids_tbl             JTF_NUMBER_TABLE;
   l_related_partner_id_tbl   JTF_NUMBER_TABLE;
   l_exist                    NUMBER;
   l_count                    NUMBER;
   l_responsibility_id        JTF_NUMBER_TABLE;
   l_no_revoke                BOOLEAN;
BEGIN
  ---- Initialize----------------

   -- Standard Start of API savepoint
   SAVEPOINT manage_ter_exp_memb_resp;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                      ,p_api_version_number
                                      ,l_api_name
                                      ,G_PKG_NAME
                                      )
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_Boolean( p_init_msg_list )
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('PRIVATE API: ' || l_api_name || ' - START');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Get the ptnr_resp_id, responsibility_id, and user_role_code for
   -- the passed in partner_id, program_id, and resp_type_code is G_PROGRAM
   FOR x IN c_get_partner_resp_info(G_PROGRAM) LOOP
      OPEN c_get_count(p_partner_id, x.user_role_code, x.responsibility_id, G_PROGRAM);
      FETCH c_get_count into l_count;
      CLOSE c_get_count;
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('manage_ter_exp_memb_resp: l_count = ' || l_count);
      END IF;
      -- If there is only this (partner_id, user_role_code, responsibility_id, resp_type_code) combo,
      -- do the following steps.
      IF (l_count = 1) THEN
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('manage_ter_exp_memb_resp: l_count is 1');
         END IF;

         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('manage_ter_exp_memb_resp: x.responsibility_id = ' || x.responsibility_id);
         END IF;

         l_no_revoke := false;
         FOR y IN c_get_other_resp_id(x.user_role_code, G_PROGRAM) LOOP
            -- To check if there is same resp_id assigned to the users
            -- The users in two partner_id which have the same partner_party_id
            -- We set l_no_revoke to true, that means, we will not revoke this resp
            IF (x.responsibility_id = y.responsibility_id) THEN
               l_no_revoke := true;
               exit;
            END IF;
         END LOOP;
         IF (not l_no_revoke) THEN
            revoke_resp(
                p_api_version_number         => p_api_version_number
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => p_commit
               ,p_user_id                    => get_partner_users_2(p_partner_id, x.user_role_code)
               ,p_resp_id                    => x.responsibility_id
               ,x_return_status              => x_return_status
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
            );
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;

         /****
          * API to delete the row with ptnr_resp_id = x.ptnr_resp_id from pv_partner_memberships
          ****/
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('manage_ter_exp_memb_resp: before calling PV_Ge_Ptnr_Resps_PVT.Delete_Ge_Ptnr_Resps');
            Debug_Log('manage_ter_exp_memb_resp: x.ptnr_resp_id = ' || x.ptnr_resp_id);
         END IF;

         PV_Ge_Ptnr_Resps_PVT.Delete_Ge_Ptnr_Resps(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL

            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
            ,p_ptnr_resp_id               => x.ptnr_resp_id
            ,p_object_version_number      => x.object_version_number
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         OPEN c_check_prgm_resp_exist(p_partner_id, x.user_role_code);
         FETCH c_check_prgm_resp_exist INTO l_exist  ;

         IF (c_check_prgm_resp_exist%NOTFOUND) THEN
            -- Get the new default resp, assign it to the users, and add a new
            -- row into pv_ge_ptnr_resps
            IF (PV_DEBUG_HIGH_ON) THEN
               Debug_Log('manage_ter_exp_memb_resp: c_check_prgm_resp_exist%NOTFOUND');
            END IF;
            get_default_assign_addrow(
                p_api_version_number         => p_api_version_number
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,x_return_status              => x_return_status
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
               ,p_user_role_code             => x.user_role_code
               ,p_user_ids_tbl               => get_partner_users(p_partner_id, x.user_role_code)
               ,p_partner_id                 => p_partner_id
            );
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               CLOSE c_check_prgm_resp_exist;
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;
         CLOSE c_check_prgm_resp_exist;
      ELSIF l_count > 1 THEN
         /****
          * API to delete the row with ptnr_resp_id = x.ptnr_resp_id from pv_partner_memberships
          ****/
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('manage_ter_exp_memb_resp: before calling PV_Ge_Ptnr_Resps_PVT.Delete_Ge_Ptnr_Resps');
            Debug_Log('manage_ter_exp_memb_resp: x.ptnr_resp_id = ' || x.ptnr_resp_id);
         END IF;

         PV_Ge_Ptnr_Resps_PVT.Delete_Ge_Ptnr_Resps(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => p_commit
            ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL

            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
            ,p_ptnr_resp_id               => x.ptnr_resp_id
            ,p_object_version_number      => x.object_version_number
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF; -- End of IF l_count = 1
    END LOOP; -- End of FOR x IN c_get_partner_resp_info

   -- Get the store program responsibility_id
   -- Get the ptnr_resp_id, responsibility_id, and user_role_code for
   -- the passed in partner_id, program_id, and resp_type_code is G_PROGRAM
   FOR x IN c_get_partner_resp_info(G_STORE) LOOP
      OPEN c_get_count(p_partner_id, x.user_role_code, x.responsibility_id, G_STORE);
      FETCH c_get_count into l_count;
      CLOSE c_get_count;
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('manage_ter_exp_memb_resp: l_count = ' || l_count);
      END IF;
      -- If there is only this (partner_id, user_role_code, responsibility_id, resp_type_code) combo,
      -- do the following steps.
      IF (l_count = 1) THEN
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('manage_ter_exp_memb_resp: l_count is 1');
         END IF;

         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('manage_ter_exp_memb_resp: x.responsibility_id = ' || x.responsibility_id);
         END IF;

         l_no_revoke := false;
         FOR y IN c_get_other_resp_id(x.user_role_code, G_STORE) LOOP
            -- To check if there is same resp_id assigned to the users
            -- The users in two partner_id which have the same partner_party_id
            -- We set l_no_revoke to true, that means, we will not revoke this resp
            IF (x.responsibility_id = y.responsibility_id) THEN
               l_no_revoke := true;
               exit;
            END IF;
         END LOOP;
         IF (not l_no_revoke) THEN
            -- Revoke for all users
            revoke_resp(
                p_api_version_number         => p_api_version_number
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => p_commit
               ,p_user_id                    => get_partner_users_2(p_partner_id, G_ALL)
               ,p_resp_id                    => x.responsibility_id
               ,x_return_status              => x_return_status
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
            );
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF; -- End of IF (not l_no_revoke)
      END IF; -- End of IF (l_count = 1)
      /****
       * API to delete the row with ptnr_resp_id = x.ptnr_resp_id from pv_partner_memberships
       ****/
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('manage_ter_exp_memb_resp: before calling PV_Ge_Ptnr_Resps_PVT.Delete_Ge_Ptnr_Resps');
         Debug_Log('manage_ter_exp_memb_resp: x.ptnr_resp_id = ' || x.ptnr_resp_id);
      END IF;

      PV_Ge_Ptnr_Resps_PVT.Delete_Ge_Ptnr_Resps(
          p_api_version_number         => p_api_version_number
         ,p_init_msg_list              => FND_API.G_FALSE
         ,p_commit                     => FND_API.G_FALSE
         ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL

         ,x_return_status              => x_return_status
         ,x_msg_count                  => x_msg_count
         ,x_msg_data                   => x_msg_data
         ,p_ptnr_resp_id               => x.ptnr_resp_id
         ,p_object_version_number      => x.object_version_number
      );
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END LOOP; -- End of FOR x IN c_get_partner_resp_info(G_STORE) LOOP

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO manage_ter_exp_memb_resp;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO manage_ter_exp_memb_resp;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO manage_ter_exp_memb_resp;
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

END manage_ter_exp_memb_resp;


/*
 * manage_active_memb_resp
 * This private API gets called when new 'ACTIVE' membership row is created in
 * pv_pg_memberships table.
 */
PROCEDURE manage_active_memb_resp(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_partner_id                 IN   NUMBER
   ,p_program_id                 IN   NUMBER
   ,p_membership_id              IN   NUMBER
)
IS
   CURSOR c_get_default_resp_id (cv_partner_id NUMBER, cv_user_role_code VARCHAR2) IS
      SELECT ptnr_resp_id, responsibility_id, object_version_number
      FROM   pv_ge_ptnr_resps
      WHERE  partner_id = cv_partner_id
      AND    program_id is null
      AND    user_role_code = cv_user_role_code
      AND    resp_type_code = G_PROGRAM;

   CURSOR c_get_prev_memberships (cv_membership_id NUMBER) IS
      SELECT prev.program_id
      FROM   pv_pg_mmbr_transitions tran, pv_pg_memberships prev
      WHERE  tran.to_membership_id = cv_membership_id
      AND    prev.membership_id = tran.from_membership_id;

   l_api_name                 CONSTANT  VARCHAR2(30) := 'manage_active_memb_resp';
   l_api_version_number       CONSTANT NUMBER   := 1.0;
   l_responsibility_id        NUMBER;
   l_store_responsibility_id  JTF_NUMBER_TABLE;
   l_store_resp_map_rule_id   JTF_NUMBER_TABLE;
   l_resp_map_rule_id         NUMBER;
   l_ptnr_resp_id             NUMBER;
   l_ge_ptnr_resps_rec        PV_Ge_Ptnr_Resps_PVT.ge_ptnr_resps_rec_type;
   l_user_ids_tbl             JTF_NUMBER_TABLE;

BEGIN
  ---- Initialize----------------

   -- Standard Start of API savepoint
   SAVEPOINT manage_active_memb_resp;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                      ,p_api_version_number
                                      ,l_api_name
                                      ,G_PKG_NAME
                                      )
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_Boolean( p_init_msg_list )
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('PRIVATE API: ' || l_api_name || ' - START...');
      Debug_Log('manage_active_memb_resp: p_partner_id = ' || p_partner_id);
      Debug_Log('manage_active_memb_resp: p_program_id = ' || p_program_id);
      Debug_Log('manage_active_memb_resp: p_membership_id = ' || p_membership_id);
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Get all users of the partner_id and the user_role_code.
   --primary_user_ids_tbl := get_partner_users(p_partner_id, G_PRIMARY);
   --business_user_ids_tbl := get_partner_users(p_partner_id, G_BUSINESS);

   -- Get the program responsibility for primary users
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('manage_active_memb_resp: primary users');
   END IF;
   get_program_resp(
       p_api_version_number         => p_api_version_number
      ,p_init_msg_list              => FND_API.G_FALSE
      ,p_commit                     => FND_API.G_FALSE
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,p_partner_id                 => p_partner_id
      ,p_user_role_code             => G_PRIMARY
      ,p_program_id                 => p_program_id
      ,x_responsibility_id          => l_responsibility_id
      ,x_resp_map_rule_id           => l_resp_map_rule_id
   );
   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('manage_active_memb_resp: l_responsibility_id = ' || l_responsibility_id);
      Debug_Log('manage_active_memb_resp: l_resp_map_rule_id = ' || l_resp_map_rule_id);
   END IF;

   -- If there is any program responsibility, get the partner primary users and assign
   -- that responsibility to all of them
   IF (l_responsibility_id is not null) and (l_resp_map_rule_id is not null) THEN
      l_user_ids_tbl := get_partner_users(p_partner_id, G_PRIMARY);
      -- Check if default responsibility is still assigned to partner
      -- If yes, revoke for all partner primary users
      FOR x in c_get_default_resp_id(p_partner_id, G_PRIMARY)
      LOOP
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('manage_active_memb_resp: x.responsibility_id = ' || x.responsibility_id);
         END IF;
         revoke_resp(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,p_user_id                    => l_user_ids_tbl
            ,p_resp_id                    => x.responsibility_id
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         /****
          * API to delete the row with ptnr_resp_id = x.ptnr_resp_id from pv_partner_memberships
          ****/
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('manage_active_memb_resp: before calling PV_Ge_Ptnr_Resps_PVT.Delete_Ge_Ptnr_Resps');
            Debug_Log('manage_active_memb_resp: x.ptnr_resp_id = ' || x.ptnr_resp_id);
         END IF;

         PV_Ge_Ptnr_Resps_PVT.Delete_Ge_Ptnr_Resps(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
            ,p_ptnr_resp_id               => x.ptnr_resp_id
            ,p_object_version_number      => x.object_version_number
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END LOOP; -- End of loop c_get_default_resp_id()

      FOR l_cnt IN 1..l_user_ids_tbl.count LOOP
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('manage_active_memb_resp: assign: l_user_ids_tbl('||l_cnt||')='||l_user_ids_tbl(l_cnt));
         END IF;

         assign_resp(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,p_user_id                    => l_user_ids_tbl(l_cnt)
            ,p_resp_id                    => l_responsibility_id
            ,p_app_id                     => 691
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END LOOP;

      /****
       * API to add a row to pv_ge_ptnr_resps
       ****/
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('manage_active_memb_resp: before calling PV_Ge_Ptnr_Resps_PVT.Create_Ge_Ptnr_Resps');
      END IF;

      l_ge_ptnr_resps_rec.partner_id := p_partner_id;
      l_ge_ptnr_resps_rec.user_role_code := G_PRIMARY;
      l_ge_ptnr_resps_rec.responsibility_id := l_responsibility_id;
      l_ge_ptnr_resps_rec.program_id := p_program_id;
      l_ge_ptnr_resps_rec.source_resp_map_rule_id := l_resp_map_rule_id;
      l_ge_ptnr_resps_rec.resp_type_code := G_PROGRAM;

      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('manage_active_memb_resp: l_ge_ptnr_resps_rec.partner_id = ' || l_ge_ptnr_resps_rec.partner_id);
         Debug_Log('manage_active_memb_resp: l_ge_ptnr_resps_rec.user_role_code = ' || l_ge_ptnr_resps_rec.user_role_code);
         Debug_Log('manage_active_memb_resp: l_ge_ptnr_resps_rec.responsibility_id = ' || l_ge_ptnr_resps_rec.responsibility_id);
         Debug_Log('manage_active_memb_resp: l_ge_ptnr_resps_rec.program_id = ' || l_ge_ptnr_resps_rec.program_id);
         Debug_Log('manage_active_memb_resp: l_ge_ptnr_resps_rec.source_resp_map_rule_id = ' || l_ge_ptnr_resps_rec.source_resp_map_rule_id);
         Debug_Log('manage_active_memb_resp: l_ge_ptnr_resps_rec.resp_type_code = ' || l_ge_ptnr_resps_rec.resp_type_code);
      END IF;

      PV_Ge_Ptnr_Resps_PVT.Create_Ge_Ptnr_Resps(
          p_api_version_number         => p_api_version_number
         ,p_init_msg_list              => FND_API.G_FALSE
         ,p_commit                     => FND_API.G_FALSE
         ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL

         ,x_return_status              => x_return_status
         ,x_msg_count                  => x_msg_count
         ,x_msg_data                   => x_msg_data
         ,p_ge_ptnr_resps_rec          => l_ge_ptnr_resps_rec
         ,x_ptnr_resp_id               => l_ptnr_resp_id
      );
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF; -- End of IF (l_responsibility_id is not null) and (l_resp_map_rule_id is not null)

   -- Get the program responsibility for business users
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('manage_active_memb_resp: business users');
   END IF;
   get_program_resp(
       p_api_version_number         => p_api_version_number
      ,p_init_msg_list              => FND_API.G_FALSE
      ,p_commit                     => FND_API.G_FALSE
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,p_partner_id                 => p_partner_id
      ,p_user_role_code             => G_BUSINESS
      ,p_program_id                 => p_program_id
      ,x_responsibility_id          => l_responsibility_id
      ,x_resp_map_rule_id           => l_resp_map_rule_id
   );
   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('manage_active_memb_resp: l_responsibility_id = ' || l_responsibility_id);
      Debug_Log('manage_active_memb_resp: l_resp_map_rule_id = ' || l_resp_map_rule_id);
   END IF;
   -- If there is any program responsibility, get the partner business users and assign
   -- that responsibility to all of them
   IF (l_responsibility_id is not null) and (l_resp_map_rule_id is not null) THEN
      l_user_ids_tbl := get_partner_users(p_partner_id, G_BUSINESS);
      -- Check if default responsibility is still assigned to partner
      -- If yes, revoke for all partner primary users
      FOR x in c_get_default_resp_id(p_partner_id, G_BUSINESS)
      LOOP
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('manage_active_memb_resp: x.responsibility_id = ' || x.responsibility_id);
         END IF;

         revoke_resp(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,p_user_id                    => l_user_ids_tbl
            ,p_resp_id                    => x.responsibility_id
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
         /****
          * API to delete the row with ptnr_resp_id = x.ptnr_resp_id from pv_partner_memberships
          ****/
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('manage_active_memb_resp: before calling PV_Ge_Ptnr_Resps_PVT.Delete_Ge_Ptnr_Resps');
            Debug_Log('manage_active_memb_resp: x.ptnr_resp_id = ' || x.ptnr_resp_id);
         END IF;

         PV_Ge_Ptnr_Resps_PVT.Delete_Ge_Ptnr_Resps(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => p_commit
            ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
            ,p_ptnr_resp_id               => x.ptnr_resp_id
            ,p_object_version_number      => x.object_version_number
         );

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END LOOP;

      FOR l_cnt IN 1..l_user_ids_tbl.count LOOP
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('manage_active_memb_resp: assign: l_user_ids_tbl('||l_cnt||')='||l_user_ids_tbl(l_cnt));
         END IF;

         assign_resp(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,p_user_id                    => l_user_ids_tbl(l_cnt)
            ,p_resp_id                    => l_responsibility_id
            ,p_app_id                     => 691
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END LOOP;

      /****
       * API to add a row to pv_ptnr_resps
       ****/
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('manage_active_memb_resp: before calling PV_Ge_Ptnr_Resps_PVT.Create_Ge_Ptnr_Resps');
      END IF;

      l_ge_ptnr_resps_rec.partner_id := p_partner_id;
      l_ge_ptnr_resps_rec.user_role_code := G_BUSINESS;
      l_ge_ptnr_resps_rec.responsibility_id := l_responsibility_id;
      l_ge_ptnr_resps_rec.program_id := p_program_id;
      l_ge_ptnr_resps_rec.source_resp_map_rule_id := l_resp_map_rule_id;
      l_ge_ptnr_resps_rec.resp_type_code := G_PROGRAM;

      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('manage_active_memb_resp: l_ge_ptnr_resps_rec.partner_id = ' || l_ge_ptnr_resps_rec.partner_id);
         Debug_Log('manage_active_memb_resp: l_ge_ptnr_resps_rec.user_role_code = ' || l_ge_ptnr_resps_rec.user_role_code);
         Debug_Log('manage_active_memb_resp: l_ge_ptnr_resps_rec.responsibility_id = ' || l_ge_ptnr_resps_rec.responsibility_id);
         Debug_Log('manage_active_memb_resp: l_ge_ptnr_resps_rec.program_id = ' || l_ge_ptnr_resps_rec.program_id);
         Debug_Log('manage_active_memb_resp: l_ge_ptnr_resps_rec.source_resp_map_rule_id = ' || l_ge_ptnr_resps_rec.source_resp_map_rule_id);
         Debug_Log('manage_active_memb_resp: l_ge_ptnr_resps_rec.resp_type_code = ' || l_ge_ptnr_resps_rec.resp_type_code);
      END IF;

      PV_Ge_Ptnr_Resps_PVT.Create_Ge_Ptnr_Resps(
          p_api_version_number         => p_api_version_number
         ,p_init_msg_list              => FND_API.G_FALSE
         ,p_commit                     => FND_API.G_FALSE
         ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL
         ,x_return_status              => x_return_status
         ,x_msg_count                  => x_msg_count
         ,x_msg_data                   => x_msg_data
         ,p_ge_ptnr_resps_rec          => l_ge_ptnr_resps_rec
         ,x_ptnr_resp_id               => l_ptnr_resp_id
      );
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF; -- End of IF (l_responsibility_id is not null) and (l_resp_map_rule_id is not null)

   -- Get the store program responsibility_id
   get_store_prgm_resps(
       p_api_version_number         => p_api_version_number
      ,p_init_msg_list              => FND_API.G_FALSE
      ,p_commit                     => FND_API.G_FALSE
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,p_program_id                 => p_program_id
      ,x_responsibility_id          => l_store_responsibility_id
      ,x_resp_map_rule_id           => l_store_resp_map_rule_id
   );

   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF l_store_responsibility_id IS NULL THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('manage_active_memb_resp: l_store_responsibility_id is null');
      END IF;
   END IF;

   IF l_store_responsibility_id IS NOT NULL THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('manage_active_memb_resp: l_store_responsibility_id is not null');
      END IF;
      l_user_ids_tbl := get_partner_users(p_partner_id, G_ALL);
      -- assign the above responsibility_id to all primary users
      FOR l_r_cnt IN 1..l_store_responsibility_id.count LOOP
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('manage_active_memb_resp: primary: l_store_responsibility_id('||l_r_cnt||')='||l_store_responsibility_id(l_r_cnt));
         END IF;
         FOR l_u_cnt IN 1..l_user_ids_tbl.count LOOP
            assign_resp (
                p_api_version_number         => p_api_version_number
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,p_user_id                    => l_user_ids_tbl(l_u_cnt)
               ,p_resp_id                    => l_store_responsibility_id(l_r_cnt)
               ,p_app_id                     => 671
               ,x_return_status              => x_return_status
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
            );
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END LOOP; -- End of l_user_ids_tbl

         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('manage_active_memb_resp: before calling PV_Ge_Ptnr_Resps_PVT.Create_Ge_Ptnr_Resps');
         END IF;

         /****
          * API to add a row to pv_ptnr_resps
          ****/
         l_ge_ptnr_resps_rec.partner_id := p_partner_id;
         l_ge_ptnr_resps_rec.user_role_code := G_ALL;
         l_ge_ptnr_resps_rec.responsibility_id := l_store_responsibility_id(l_r_cnt);
         l_ge_ptnr_resps_rec.program_id := p_program_id;
         l_ge_ptnr_resps_rec.source_resp_map_rule_id := l_store_resp_map_rule_id(l_r_cnt);
         l_ge_ptnr_resps_rec.resp_type_code := G_STORE;

         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('manage_active_memb_resp: l_ge_ptnr_resps_rec.partner_id = ' || l_ge_ptnr_resps_rec.partner_id);
            Debug_Log('manage_active_memb_resp: l_ge_ptnr_resps_rec.user_role_code = ' || l_ge_ptnr_resps_rec.user_role_code);
            Debug_Log('manage_active_memb_resp: l_ge_ptnr_resps_rec.responsibility_id = ' || l_ge_ptnr_resps_rec.responsibility_id);
            Debug_Log('manage_active_memb_resp: l_ge_ptnr_resps_rec.program_id = ' || l_ge_ptnr_resps_rec.program_id);
            Debug_Log('manage_active_memb_resp: l_ge_ptnr_resps_rec.source_resp_map_rule_id = ' || l_ge_ptnr_resps_rec.source_resp_map_rule_id);
            Debug_Log('manage_active_memb_resp: l_ge_ptnr_resps_rec.resp_type_code = ' || l_ge_ptnr_resps_rec.resp_type_code);
         END IF;

         PV_Ge_Ptnr_Resps_PVT.Create_Ge_Ptnr_Resps(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
            ,p_ge_ptnr_resps_rec          => l_ge_ptnr_resps_rec
            ,x_ptnr_resp_id               => l_ptnr_resp_id
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END LOOP; -- End of FOR l_r_cnt IN 1..l_store_responsibility_id.count
   END IF; -- End of IF (l_responsibility_id is not null) and (l_resp_map_rule_id is not null)

   -- Get if there are any previous memberships that are associated with the current membership.
   FOR x IN c_get_prev_memberships(p_membership_id)
   LOOP
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('manage_active_memb_resp: before calling manage_ter_exp_memb_resp');
      END IF;
      -- Call c_get_prev_memberships for all the programs retrieved in the above step
      manage_ter_exp_memb_resp(
          p_api_version_number         => p_api_version_number
         ,p_init_msg_list              => FND_API.G_FALSE
         ,p_commit                     => FND_API.G_FALSE
         ,x_return_status              => x_return_status
         ,x_msg_count                  => x_msg_count
         ,x_msg_data                   => x_msg_data
         ,p_partner_id                 => p_partner_id
         ,p_program_id                 => x.program_id
      );
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END LOOP;

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO manage_active_memb_resp;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO manage_active_memb_resp;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO manage_active_memb_resp;
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

END manage_active_memb_resp;

/*
 * manage_memb_resp
 * This public API will take care of managing user responsibilities when
 * membership is terminated, exprired, created, upgraded, and downgraded.
 * This should be called when a new row is created in pv_pg_memberships
 * table with the membership_id of the row that just got created, membership_id
 * of program that is being terminated or expireing.
 */
PROCEDURE manage_memb_resp(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_membership_id              IN   NUMBER
)
IS
   CURSOR c_get_membership_status (cv_membership_id NUMBER) IS
      SELECT membership_status_code, partner_id, program_id
      FROM   pv_pg_memberships
      WHERE  membership_id = cv_membership_id;

   l_api_name              CONSTANT  VARCHAR2(30) := 'manage_memb_resp';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_user_ids_tbl            JTF_NUMBER_TABLE;
   l_responsibility_id               NUMBER;
   l_resp_map_rule_id      NUMBER;

BEGIN
  ---- Initialize----------------

   -- Standard Start of API savepoint
   SAVEPOINT manage_memb_resp;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                      ,p_api_version_number
                                      ,l_api_name
                                      ,G_PKG_NAME
                                      )
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_Boolean( p_init_msg_list )
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('PRIVATE API: ' || l_api_name || ' - START');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Get the membership status
   FOR x IN c_get_membership_status (p_membership_id)
   LOOP
      IF x.membership_status_code = 'TERMINATED' THEN
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('manage_memb_resp: TERMINATED');
         END IF;
         manage_ter_exp_memb_resp(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
            ,p_partner_id                 => x.partner_id
            ,p_program_id                 => x.program_id
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      ELSIF x.membership_status_code = 'ACTIVE' THEN
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('manage_memb_resp: ACTIVE');
         END IF;
         manage_active_memb_resp(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
            ,p_partner_id                 => x.partner_id
            ,p_program_id                 => x.program_id
            ,p_membership_id              => p_membership_id
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
   END LOOP;

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO manage_memb_resp;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO manage_memb_resp;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO manage_memb_resp;
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

END manage_memb_resp;

/*
 * delete_resp_mapping
 * This public API will take care of managing partner user responsibilities when
 * responsibility mapping is soft deleted.
 */
PROCEDURE delete_resp_mapping(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_source_resp_map_rule_id    IN   NUMBER
)
IS
   CURSOR c_get_ptnr_resps (cv_source_resp_map_rule_id NUMBER) IS
      SELECT ptnr_resp_id, responsibility_id, partner_id, user_role_code, program_id, object_version_number
      FROM   pv_ge_ptnr_resps
      WHERE  source_resp_map_rule_id = cv_source_resp_map_rule_id
      AND    resp_type_code = G_PROGRAM
      ORDER BY partner_id, user_role_code;

   CURSOR c_get_count (cv_partner_id NUMBER, cv_user_role_code VARCHAR2, cv_responsibility_id NUMBER) IS
      SELECT count(*)
      FROM   pv_ge_ptnr_resps
      WHERE  partner_id = cv_partner_id
      AND    user_role_code = cv_user_role_code
      AND    responsibility_id = cv_responsibility_id
      AND    resp_type_code = G_PROGRAM;

   CURSOR c_check_if_resp_exist (cv_partner_id NUMBER, cv_user_role_code VARCHAR2) IS
      SELECT 1
      FROM   pv_ge_ptnr_resps
      WHERE  partner_id = cv_partner_id
      AND    user_role_code = cv_user_role_code
      AND    resp_type_code = G_PROGRAM;

   l_api_name              CONSTANT  VARCHAR2(30) := 'delete_resp_mapping';
   l_api_version_number    CONSTANT NUMBER   := 1.0;
   l_user_ids_tbl          JTF_NUMBER_TABLE;
   l_exist                 NUMBER;
   l_count                 NUMBER;
   l_responsibility_id     NUMBER;
   l_resp_map_rule_id      NUMBER;
   l_ptnr_resp_id          NUMBER;
   l_ge_ptnr_resps_rec     PV_Ge_Ptnr_Resps_PVT.ge_ptnr_resps_rec_type;

BEGIN
  ---- Initialize----------------

   -- Standard Start of API savepoint
   SAVEPOINT delete_resp_mapping;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                      ,p_api_version_number
                                      ,l_api_name
                                      ,G_PKG_NAME
                                      )
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_Boolean( p_init_msg_list )
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('PRIVATE API: ' || l_api_name || ' - START...');
   END IF;
   -- Initialize API return status to SUCCESS
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;
   -- Get the membership status
   FOR x IN c_get_ptnr_resps (p_source_resp_map_rule_id)
   LOOP
      l_user_ids_tbl := get_partner_users(x.partner_id, x.user_role_code);

      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('delete_resp_mapping: x.program_id = ' || x.program_id);
      END IF;

      IF x.program_id IS NOT NULL THEN
         OPEN c_get_count(x.partner_id, x.user_role_code, x.responsibility_id);
         FETCH c_get_count into l_count;
         CLOSE c_get_count;
         -- If there is only this (partner_id, user_role_code, responsibility_id) combo,
         -- do the following steps. Otherwise, continue.
         IF l_count = 1 THEN
            -- Get all users of the partner_id and the user_role_code.
            -- Rovoke the responsibility for all of them.
            IF (PV_DEBUG_HIGH_ON) THEN
               Debug_Log('delete_resp_mapping: x.responsibility_id = ' || x.responsibility_id);
            END IF;
            revoke_resp(
                p_api_version_number         => p_api_version_number
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,p_user_id                    => l_user_ids_tbl
               ,p_resp_id                    => x.responsibility_id
               ,x_return_status              => x_return_status
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
            );
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;

         /****
          * API to delete the row with ptnr_resp_id = x.ptnr_resp_id from pv_partner_memberships
          ****/
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('delete_resp_mapping: before calling PV_Ge_Ptnr_Resps_PVT.Delete_Ge_Ptnr_Resps');
            Debug_Log('delete_resp_mapping: x.ptnr_resp_id = ' || x.ptnr_resp_id);
         END IF;

         PV_Ge_Ptnr_Resps_PVT.Delete_Ge_Ptnr_Resps(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL

            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
            ,p_ptnr_resp_id               => x.ptnr_resp_id
            ,p_object_version_number      => x.object_version_number
         );

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('delete_resp_mapping: before calling get_program_resp');
         END IF;
         -- Get the program responsibility for primary users
         get_program_resp(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
            ,p_partner_id                 => x.partner_id
            ,p_user_role_code             => x.user_role_code
            ,p_program_id                 => x.program_id
            ,x_responsibility_id          => l_responsibility_id
            ,x_resp_map_rule_id           => l_resp_map_rule_id
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         --
         -- If no program resp is returned and there is no other same resps,
         -- check if partner has at least one resp
         IF ((l_responsibility_id is null) or (l_resp_map_rule_id is null)) THEN
            IF (PV_DEBUG_HIGH_ON) THEN
               Debug_Log('delete_resp_mapping: (l_responsibility_id is null or l_resp_map_rule_id is null) 1');
            END IF;
            OPEN c_check_if_resp_exist(x.partner_id, x.user_role_code);
            FETCH c_check_if_resp_exist into l_exist;
            --CLOSE c_check_if_resp_exist;
            -- If there is none, do the following steps. Otherwise, do nothing.
            IF (c_check_if_resp_exist%NOTFOUND) THEN
               get_default_assign_addrow(
                   p_api_version_number         => p_api_version_number
                  ,p_init_msg_list              => FND_API.G_FALSE
                  ,p_commit                     => FND_API.G_FALSE
                  ,x_return_status              => x_return_status
                  ,x_msg_count                  => x_msg_count
                  ,x_msg_data                   => x_msg_data
                  ,p_user_role_code             => x.user_role_code
                  ,p_user_ids_tbl               => l_user_ids_tbl
                  ,p_partner_id                 => x.partner_id
               );
               IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                  CLOSE c_check_if_resp_exist;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;
            END IF; -- End of IF (c_check_if_resp_exist%NOTFOUND)
            CLOSE c_check_if_resp_exist;

         -- If some program resp is returned, assign it to the users
         ELSE
            IF (PV_DEBUG_HIGH_ON) THEN
               Debug_Log('delete_resp_mapping: !!!(l_responsibility_id is null or l_resp_map_rule_id is null) and l_count = 1');
            END IF;

            FOR l_cnt IN 1..l_user_ids_tbl.count
            LOOP
               assign_resp(
                   p_api_version_number         => p_api_version_number
                  ,p_init_msg_list              => FND_API.G_FALSE
                  ,p_commit                     => FND_API.G_FALSE
                  ,p_user_id                    => l_user_ids_tbl(l_cnt)
                  ,p_resp_id                    => l_responsibility_id
                  ,p_app_id                     => 691
                  ,x_return_status              => x_return_status
                  ,x_msg_count                  => x_msg_count
                  ,x_msg_data                   => x_msg_data
               );
            END LOOP;

            /****
             * API to add a row to Create_Ge_Ptnr_Resps
             ****/
            IF (PV_DEBUG_HIGH_ON) THEN
               Debug_Log('delete_resp_mapping: before calling PV_Ge_Ptnr_Resps_PVT.Create_Ge_Ptnr_Resps');
            END IF;
            l_ge_ptnr_resps_rec.partner_id := x.partner_id;
            l_ge_ptnr_resps_rec.user_role_code := x.user_role_code;
            l_ge_ptnr_resps_rec.responsibility_id := l_responsibility_id;
            l_ge_ptnr_resps_rec.program_id := x.program_id;
            l_ge_ptnr_resps_rec.source_resp_map_rule_id := l_resp_map_rule_id;
            l_ge_ptnr_resps_rec.resp_type_code := G_PROGRAM;

            IF (PV_DEBUG_HIGH_ON) THEN
               Debug_Log('delete_resp_mapping: l_ge_ptnr_resps_rec.partner_id = ' || l_ge_ptnr_resps_rec.partner_id);
               Debug_Log('delete_resp_mapping: l_ge_ptnr_resps_rec.user_role_code = ' || l_ge_ptnr_resps_rec.user_role_code);
               Debug_Log('delete_resp_mapping: l_ge_ptnr_resps_rec.responsibility_id = ' || l_ge_ptnr_resps_rec.responsibility_id);
               Debug_Log('delete_resp_mapping: l_ge_ptnr_resps_rec.program_id = ' || l_ge_ptnr_resps_rec.program_id);
               Debug_Log('delete_resp_mapping: l_ge_ptnr_resps_rec.source_resp_map_rule_id = ' || l_ge_ptnr_resps_rec.source_resp_map_rule_id);
               Debug_Log('delete_resp_mapping: l_ge_ptnr_resps_rec.resp_type_code = ' || l_ge_ptnr_resps_rec.resp_type_code);
            END IF;

            PV_Ge_Ptnr_Resps_PVT.Create_Ge_Ptnr_Resps(
                p_api_version_number         => p_api_version_number
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL

               ,x_return_status              => x_return_status
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
               ,p_ge_ptnr_resps_rec          => l_ge_ptnr_resps_rec
               ,x_ptnr_resp_id               => l_ptnr_resp_id
            );

            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF; -- End of IF (l_responsibility_id is null) or (l_resp_map_rule_id is null)

      ELSIF x.program_id IS NULL THEN
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('delete_resp_mapping: x.program_id is null');
            Debug_Log('delete_resp_mapping: x.responsibility_id = ' || x.responsibility_id);
         END IF;
         revoke_resp(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,p_user_id                    => l_user_ids_tbl
            ,p_resp_id                    => x.responsibility_id
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
         /****
          * API to delete the row with ptnr_resp_id = x.ptnr_resp_id from pv_partner_memberships
          ****/
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('delete_resp_mapping: before calling PV_Ge_Ptnr_Resps_PVT.Delete_Ge_Ptnr_Resps');
            Debug_Log('delete_resp_mapping: x.ptnr_resp_id = ' || x.ptnr_resp_id);
         END IF;

         PV_Ge_Ptnr_Resps_PVT.Delete_Ge_Ptnr_Resps(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => p_commit
            ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL

            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
            ,p_ptnr_resp_id               => x.ptnr_resp_id
            ,p_object_version_number      => x.object_version_number
         );

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('delete_resp_mapping: before calling get_default_assign_addrow');
         END IF;
         -- Get the new default resp, assign it to the users, and add a new
         -- row into pv_ge_ptnr_resps
         get_default_assign_addrow(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
            ,p_user_role_code             => x.user_role_code
            ,p_user_ids_tbl               => l_user_ids_tbl
            ,p_partner_id                 => x.partner_id
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF; -- End of IF program_id IS NOT NULL
   END LOOP;
   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO delete_resp_mapping;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO delete_resp_mapping;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO delete_resp_mapping;
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

END delete_resp_mapping;

/*
 * update_resp_mapping
 * This public API will take care of managing partner user responsibilities when
 * responsibility mapping is updated with a new responsibility.
 */
PROCEDURE update_resp_mapping(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_source_resp_map_rule_id    IN   NUMBER
)
IS
   CURSOR c_get_ptnr_resps (cv_source_resp_map_rule_id NUMBER) IS
      SELECT ptnr_resp_id, responsibility_id, partner_id, user_role_code, program_id, object_version_number
      FROM   pv_ge_ptnr_resps
      WHERE  source_resp_map_rule_id = cv_source_resp_map_rule_id
      AND    resp_type_code = G_PROGRAM
      ORDER BY partner_id, user_role_code;

   CURSOR c_get_new_resp (cv_source_resp_map_rule_id NUMBER) IS
      SELECT responsibility_id
      FROM   pv_ge_resp_map_rules
      WHERE  resp_map_rule_id = cv_source_resp_map_rule_id;

   CURSOR c_get_count (cv_partner_id NUMBER, cv_user_role_code VARCHAR2, cv_responsibility_id NUMBER) IS
      SELECT count(*)
      FROM   pv_ge_ptnr_resps
      WHERE  partner_id = cv_partner_id
      AND    user_role_code = cv_user_role_code
      AND    responsibility_id = cv_responsibility_id
      AND    resp_type_code = G_PROGRAM;

   l_api_name              CONSTANT  VARCHAR2(30) := 'update_resp_mapping';
   l_api_version_number    CONSTANT NUMBER   := 1.0;
   l_user_ids_tbl          JTF_NUMBER_TABLE;
   l_first_time_flag       VARCHAR2(1);
   l_count                 NUMBER;
   l_new_responsibility_id NUMBER;
   l_resp_map_rule_id      NUMBER;

BEGIN
  ---- Initialize----------------

   -- Standard Start of API savepoint
   SAVEPOINT update_resp_mapping;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                      ,p_api_version_number
                                      ,l_api_name
                                      ,G_PKG_NAME
                                      )
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_Boolean( p_init_msg_list )
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('PRIVATE API: ' || l_api_name || ' - START');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   FOR x IN c_get_new_resp(p_source_resp_map_rule_id) LOOP
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('update_resp_mapping: new x.responsibility_id = ' || x.responsibility_id);
      END IF;
      l_new_responsibility_id := x.responsibility_id;
   END LOOP;

   FOR x IN c_get_ptnr_resps (p_source_resp_map_rule_id) LOOP
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('update_resp_mapping: x.responsibility_id = ' || x.responsibility_id);
         Debug_Log('update_resp_mapping: x.program_id = ' || x.program_id);
      END IF;

      l_user_ids_tbl := get_partner_users(x.partner_id, x.user_role_code);

      IF x.program_id IS NOT NULL THEN
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('update_resp_mapping: x.program_id is not null');
         END IF;
         OPEN c_get_count(x.partner_id, x.user_role_code, x.responsibility_id);
         FETCH c_get_count into l_count;
         CLOSE c_get_count;
         -- If there is only this (partner_id, user_role_code, responsibility_id) combo,
         -- call revoke_update_assign with p_is_revoke = 'Y'
         -- Otherwise, call revoke_update_assign with p_is_revoke = 'N'
         IF l_count = 1 THEN
            -- Rovoke the responsibility for all partner users.
            -- Update the corresponding row in pv_ge_ptnr_resps.
            -- Assign the new responsibility for all partner users.
            IF (PV_DEBUG_HIGH_ON) THEN
               Debug_Log('update_resp_mapping: before calling revoke_update_assign');
            END IF;
            revoke_update_assign(
                p_api_version_number         => p_api_version_number
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,x_return_status              => x_return_status
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
               ,p_user_ids_tbl               => l_user_ids_tbl
               ,p_ptnr_resp_id               => x.ptnr_resp_id
               ,p_old_responsibility_id      => x.responsibility_id
               ,p_new_responsibility_id      => l_new_responsibility_id
               ,p_object_version_number      => x.object_version_number
               ,p_is_revoke                  => 'Y'
            );
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
            IF (PV_DEBUG_HIGH_ON) THEN
               Debug_Log('update_resp_mapping: after calling revoke_update_assign');
            END IF;

         ELSE
            -- Update the corresponding row in pv_ge_ptnr_resps.
            -- Assign the new responsibility for all partner users.
            IF (PV_DEBUG_HIGH_ON) THEN
               Debug_Log('update_resp_mapping: before calling revoke_update_assign');
            END IF;
           revoke_update_assign(
                p_api_version_number         => p_api_version_number
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,x_return_status              => x_return_status
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
               ,p_user_ids_tbl               => l_user_ids_tbl
               ,p_ptnr_resp_id               => x.ptnr_resp_id
               ,p_old_responsibility_id      => x.responsibility_id
               ,p_new_responsibility_id      => l_new_responsibility_id
               ,p_object_version_number      => x.object_version_number
               ,p_is_revoke                  => 'N'
            );
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF (PV_DEBUG_HIGH_ON) THEN
               Debug_Log('update_resp_mapping: after calling revoke_update_assign');
            END IF;
         END IF;
      ELSE  -- IF program_id IS NULL
         -- Rovoke the responsibility for all partner users.
         -- Update the corresponding row in pv_ge_ptnr_resps.
         -- Assign the new responsibility for all partner users.
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('update_resp_mapping: before calling revoke_update_assign');
         END IF;
         revoke_update_assign(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
            ,p_user_ids_tbl               => l_user_ids_tbl
            ,p_ptnr_resp_id               => x.ptnr_resp_id
            ,p_old_responsibility_id      => x.responsibility_id
            ,p_new_responsibility_id      => l_new_responsibility_id
            ,p_object_version_number      => x.object_version_number
            ,p_is_revoke                  => 'Y'
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('update_resp_mapping: before calling revoke_update_assign');
         END IF;
      END IF; -- End of IF program_id IS NOT NULL
   END LOOP;

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO update_resp_mapping;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO update_resp_mapping;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO update_resp_mapping;
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

END update_resp_mapping;

/*
 * create_resp_mapping
 * This public API will take care of managing partner user responsibilities when
 * responsibility mapping is created.
 */
PROCEDURE create_resp_mapping(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_source_resp_map_rule_id    IN   NUMBER
)
IS
   CURSOR c_get_resp_info_1 (cv_source_resp_map_rule_id NUMBER) IS
      SELECT m.partner_id, mr.user_role_code, mr.program_id
      FROM   pv_pg_memberships m, pv_ge_resp_map_rules mr
      WHERE  mr.program_id = m.program_id
      AND    m.membership_status_code = 'ACTIVE'
      AND    mr.resp_map_rule_id = cv_source_resp_map_rule_id;

   CURSOR c_get_resp_info_2 (cv_source_resp_map_rule_id NUMBER) IS
      SELECT user_role_code
      FROM   pv_ge_resp_map_rules mr
      WHERE  program_id is null
      AND    resp_map_rule_id = cv_source_resp_map_rule_id;

   CURSOR c_get_ptnr_resps_1 (cv_partner_id NUMBER, cv_user_role_code VARCHAR2, cv_program_id NUMBER) IS
      SELECT ptnr_resp_id, program_id, responsibility_id, source_resp_map_rule_id, object_version_number
      FROM   pv_ge_ptnr_resps
      WHERE  partner_id = cv_partner_id
      AND    user_role_code = cv_user_role_code
      AND    program_id = cv_program_id
      AND    resp_type_code = G_PROGRAM;

   CURSOR c_get_defalut_resp (cv_partner_id NUMBER, cv_user_role_code VARCHAR2, cv_program_id NUMBER) IS
      SELECT ptnr_resp_id, responsibility_id, object_version_number
      FROM   pv_ge_ptnr_resps
      WHERE  partner_id = cv_partner_id
      AND    user_role_code = cv_user_role_code
      AND    program_id is null
      AND    resp_type_code = G_PROGRAM;

   CURSOR c_get_ptnr_resps_2 (cv_user_role_code VARCHAR2) IS
      SELECT ptnr_resp_id, responsibility_id, source_resp_map_rule_id, object_version_number, partner_id
      FROM   pv_ge_ptnr_resps
      WHERE  user_role_code = cv_user_role_code
      AND    program_id is null
      AND    resp_type_code = G_PROGRAM;

   CURSOR c_get_count (cv_partner_id NUMBER, cv_user_role_code VARCHAR2, cv_responsibility_id NUMBER) IS
      SELECT count(*)
      FROM   pv_ge_ptnr_resps
      WHERE  partner_id = cv_partner_id
      AND    user_role_code = cv_user_role_code
      AND    responsibility_id = cv_responsibility_id
      AND    resp_type_code = G_PROGRAM;

   l_api_name              CONSTANT  VARCHAR2(30) := 'create_resp_mapping';
   l_api_version_number    CONSTANT NUMBER   := 1.0;
   l_user_ids_tbl          JTF_NUMBER_TABLE;
   l_first_time_flag       VARCHAR2(1);
   l_count                 NUMBER;
   l_new_responsibility_id NUMBER;
   l_resp_map_rule_id      NUMBER;
   l_same_comb             boolean;
   l_exist                 NUMBER;
   l_ge_ptnr_resps_rec     PV_Ge_Ptnr_Resps_PVT.ge_ptnr_resps_rec_type;
   l_ptnr_resp_id          NUMBER;
BEGIN
  ---- Initialize----------------

   -- Standard Start of API savepoint
   SAVEPOINT create_resp_mapping;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                      ,p_api_version_number
                                      ,l_api_name
                                      ,G_PKG_NAME
                                      )
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_Boolean( p_init_msg_list )
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('PRIVATE API: ' || l_api_name || ' - START...');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   FOR x IN c_get_resp_info_1 (p_source_resp_map_rule_id) LOOP
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('create_resp_mapping: x.partner_id = ' || x.partner_id);
         Debug_Log('create_resp_mapping: x.user_role_code = ' ||x.user_role_code);
      END IF;

      l_user_ids_tbl := get_partner_users(x.partner_id, x.user_role_code);

      --IF x.program_id IS NOT NULL THEN
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('create_resp_mapping: x.program_id is not null');
         Debug_Log('create_resp_mapping: before calling get_program_resp');
      END IF;
      get_program_resp(
          p_api_version_number         => p_api_version_number
         ,p_init_msg_list              => FND_API.G_FALSE
         ,p_commit                     => FND_API.G_FALSE
         ,x_return_status              => x_return_status
         ,x_msg_count                  => x_msg_count
         ,x_msg_data                   => x_msg_data
         ,p_partner_id                 => x.partner_id
         ,p_user_role_code             => x.user_role_code
         ,p_program_id                 => x.program_id
         ,x_responsibility_id          => l_new_responsibility_id
         ,x_resp_map_rule_id           => l_resp_map_rule_id
      );
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('create_resp_mapping: after calling get_program_resp');
         Debug_Log('create_resp_mapping: l_new_responsibility_id = ' || l_new_responsibility_id);
         Debug_Log('create_resp_mapping: l_resp_map_rule_id = ' || l_resp_map_rule_id);
      END IF;
      l_same_comb := false;
      FOR y in c_get_ptnr_resps_1(x.partner_id, x.user_role_code, x.program_id) LOOP
         l_same_comb :=  true;
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('create_resp_mapping: y.ptnr_resp_id = ' || y.ptnr_resp_id);
            Debug_Log('create_resp_mapping: y.responsibility_id = ' || y.responsibility_id);
         END IF;
         IF (y.responsibility_id <> l_new_responsibility_id) THEN
            OPEN c_get_count(x.partner_id, x.user_role_code, y.responsibility_id);
            FETCH c_get_count into l_count;
            CLOSE c_get_count;
            -- If there is only this (partner_id, user_role_code, responsibility_id) combo,
            -- call revoke_update_assign with p_is_revoke = 'Y'
            -- Otherwise, call revoke_update_assign with p_is_revoke = 'N'
            IF l_count = 1 THEN
               IF (PV_DEBUG_HIGH_ON) THEN
                  Debug_Log('create_resp_mapping: l_count = 1');
                  Debug_Log('create_resp_mapping: before calling revoke_update_assign');
               END IF;
               -- Rovoke the responsibility for all partner users.
               -- Update the corresponding row in pv_ge_ptnr_resps.
               -- Assign the new responsibility for all partner users.
               revoke_update_assign(
                   p_api_version_number         => p_api_version_number
                  ,p_init_msg_list              => FND_API.G_FALSE
                  ,p_commit                     => FND_API.G_FALSE
                  ,x_return_status              => x_return_status
                  ,x_msg_count                  => x_msg_count
                  ,x_msg_data                   => x_msg_data
                  ,p_user_ids_tbl               => l_user_ids_tbl
                  ,p_ptnr_resp_id               => y.ptnr_resp_id
                  ,p_old_responsibility_id      => y.responsibility_id
                  ,p_new_responsibility_id      => l_new_responsibility_id
                  ,p_resp_map_rule_id           => l_resp_map_rule_id
                  ,p_object_version_number      => y.object_version_number
                  ,p_is_revoke                  => 'Y'
               );
               IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
               END IF;
            ELSE
               IF (PV_DEBUG_HIGH_ON) THEN
                  Debug_Log('create_resp_mapping: else');
                  Debug_Log('create_resp_mapping: before calling revoke_update_assign');
               END IF;

               -- Update the corresponding row in pv_ge_ptnr_resps.
               -- Assign the new responsibility for all partner users.
               revoke_update_assign(
                   p_api_version_number         => p_api_version_number
                  ,p_init_msg_list              => FND_API.G_FALSE
                  ,p_commit                     => FND_API.G_FALSE
                  ,x_return_status              => x_return_status
                  ,x_msg_count                  => x_msg_count
                  ,x_msg_data                   => x_msg_data
                  ,p_user_ids_tbl               => l_user_ids_tbl
                  ,p_ptnr_resp_id               => y.ptnr_resp_id
                  ,p_old_responsibility_id      => y.responsibility_id
                  ,p_new_responsibility_id      => l_new_responsibility_id
                  ,p_object_version_number      => y.object_version_number
                  ,p_is_revoke                  => 'N'
               );
               IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
               END IF;
            END IF; -- End of IF l_count = 1
         END IF; -- End of IF (y.responsibility <> l_new_responsibility_id)
      END LOOP; -- End of FOR y in c_get_ptnr_resps_1(x.partner_id, x.user_role_code, x.program_id)

      IF (not l_same_comb) THEN
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('create_resp_mapping: not l_same_comb');
         END IF;
         FOR y IN c_get_defalut_resp (x.partner_id, x.user_role_code, x.program_id) LOOP
            revoke_resp(
                p_api_version_number         => p_api_version_number
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,p_user_id                    => l_user_ids_tbl
               ,p_resp_id                    => y.responsibility_id
               ,x_return_status              => x_return_status
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
            );
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
           /****
             * API to delete the row with ptnr_resp_id = x.ptnr_resp_id from pv_partner_memberships
             ****/
            IF (PV_DEBUG_HIGH_ON) THEN
               Debug_Log('create_resp_mapping: before calling PV_Ge_Ptnr_Resps_PVT.Delete_Ge_Ptnr_Resps');
               Debug_Log('create_resp_mapping: y.ptnr_resp_id = ' || y.ptnr_resp_id);
               Debug_Log('create_resp_mapping: y.object_version_number = ' || y.object_version_number);
           END IF;

           PV_Ge_Ptnr_Resps_PVT.Delete_Ge_Ptnr_Resps(
                p_api_version_number         => p_api_version_number
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL

               ,x_return_status              => x_return_status
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
               ,p_ptnr_resp_id               => y.ptnr_resp_id
               ,p_object_version_number      => y.object_version_number
            );
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END LOOP; -- End of FOR y IN c_get_defalut_resp (x.partner_id, x.user_role_code, x.program_id)

         FOR l_u_cnt IN 1..l_user_ids_tbl.count LOOP
            assign_resp (
                p_api_version_number         => p_api_version_number
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,p_user_id                    => l_user_ids_tbl(l_u_cnt)
               ,p_resp_id                    => l_new_responsibility_id
               ,p_app_id                     => 691
               ,x_return_status              => x_return_status
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
            );
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END LOOP; -- End of l_l_user_ids_tbl

         /****
          * API to add a row to pv_ge_ptnr_resps
          ****/
         l_ge_ptnr_resps_rec.partner_id := x.partner_id;
         l_ge_ptnr_resps_rec.user_role_code := x.user_role_code;
         l_ge_ptnr_resps_rec.program_id := x.program_id;
         l_ge_ptnr_resps_rec.responsibility_id := l_new_responsibility_id;
         l_ge_ptnr_resps_rec.source_resp_map_rule_id := l_resp_map_rule_id;
         l_ge_ptnr_resps_rec.resp_type_code := G_PROGRAM;

         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('create_resp_mapping: l_ge_ptnr_resps_rec.partner_id = ' || l_ge_ptnr_resps_rec.partner_id);
            Debug_Log('create_resp_mapping: l_ge_ptnr_resps_rec.user_role_code = ' || l_ge_ptnr_resps_rec.user_role_code);
            Debug_Log('create_resp_mapping: l_ge_ptnr_resps_rec.program_id = ' || l_ge_ptnr_resps_rec.program_id);
            Debug_Log('create_resp_mapping: l_ge_ptnr_resps_rec.responsibility_id = ' || l_ge_ptnr_resps_rec.responsibility_id);
            Debug_Log('create_resp_mapping: l_ge_ptnr_resps_rec.source_resp_map_rule_id = ' || l_ge_ptnr_resps_rec.source_resp_map_rule_id);
            Debug_Log('create_resp_mapping: l_ge_ptnr_resps_rec.resp_type_code = ' || l_ge_ptnr_resps_rec.resp_type_code);
         END IF;

         PV_Ge_Ptnr_Resps_PVT.Create_Ge_Ptnr_Resps(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL

            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
            ,p_ge_ptnr_resps_rec          => l_ge_ptnr_resps_rec
            ,x_ptnr_resp_id               => l_ptnr_resp_id
         );

         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF; -- End of IF (not l_same_comb)
   END LOOP; -- End of FOR x IN c_get_resp_info_1 (p_source_resp_map_rule_id)
         Debug_Log('create_resp_mapping: program_id is null');

   FOR x IN c_get_resp_info_2 (p_source_resp_map_rule_id) LOOP
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('create_resp_mapping: program_id is null');
      END IF;

      FOR y IN c_get_ptnr_resps_2 (x.user_role_code) LOOP
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('create_resp_mapping: before calling get_default_resp');
         END IF;
         get_default_resp(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
            ,p_partner_id                 => y.partner_id
            ,p_user_role_code             => x.user_role_code
            ,x_responsibility_id          => l_new_responsibility_id
            ,x_resp_map_rule_id           => l_resp_map_rule_id
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF l_resp_map_rule_id <> y.source_resp_map_rule_id THEN
            -- Rovoke the responsibility for all partner users.
            -- Update the corresponding row in pv_ge_ptnr_resps.
            -- Assign the new responsibility for all partner users.
            IF (PV_DEBUG_HIGH_ON) THEN
               Debug_Log('create_resp_mapping: l_resp_map_rule_id <> y.source_resp_map_rule_id');
               Debug_Log('create_resp_mapping: before calling revoke_update_assign');
            END IF;

            -- Call get_partner_users for each partner_id
            l_user_ids_tbl := get_partner_users(y.partner_id, x.user_role_code);
            revoke_update_assign(
                p_api_version_number         => p_api_version_number
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,x_return_status              => x_return_status
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
               ,p_user_ids_tbl               => l_user_ids_tbl
               ,p_ptnr_resp_id               => y.ptnr_resp_id
               ,p_old_responsibility_id      => y.responsibility_id
               ,p_new_responsibility_id      => l_new_responsibility_id
               ,p_resp_map_rule_id           => l_resp_map_rule_id
               ,p_object_version_number      => y.object_version_number
               ,p_is_revoke                  => 'Y'
            );
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF; -- End of IF l_resp_map_rule_id <> y.source_resp_map_rule_id
      END LOOP; -- End of FOR y IN c_get_ptnr_resps_2
   END LOOP; -- End of FOR x IN c_get_resp_info_2 (p_source_resp_map_rule_id)

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO create_resp_mapping;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO create_resp_mapping;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO create_resp_mapping;
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

END create_resp_mapping;

/*
 * revoke_uer_resps
 * This public API will take care of revoking all PRM responsibilities and store
 * responsibilities that are assigned upon partner enrollment into a program
 */
PROCEDURE revoke_user_resps(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_user_id                    IN   NUMBER
   ,p_user_role_code             IN   VARCHAR2
)
IS
   -- Fixed for bug 3766776
   CURSOR c_get_resp_info (cv_partner_id JTF_NUMBER_TABLE)  IS
      SELECT /*+ LEADING(T) USE_NL (T P F) */
             p.responsibility_id, f.responsibility_application_id, f.security_group_id,
             f.start_date, f.description, f.user_id
      FROM   pv_ge_ptnr_resps p,
             (SELECT column_value FROM TABLE (CAST(cv_partner_id AS JTF_NUMBER_TABLE))) t ,
             fnd_user_resp_groups f
      WHERE  p.partner_id = t.column_value
      AND    nvl(end_date, sysdate) >= sysdate
      AND    f.user_id = p_user_id
      AND    f.responsibility_id = p.responsibility_id
      AND    user_role_code in (p_user_role_code, G_ALL);

   -- Fixed for bug 3766776
   CURSOR c_get_user_resp_groups (cv_responsibility_id_tbl JTF_NUMBER_TABLE) IS
      SELECT
             user_id, responsibility_id, responsibility_application_id, security_group_id,
             start_date, description
      FROM   fnd_user_resp_groups,
             (SELECT column_value FROM TABLE (CAST(cv_responsibility_id_tbl AS JTF_NUMBER_TABLE))) t
      WHERE  responsibility_id = t.column_value
      AND    user_id = p_user_id;

   l_api_name              CONSTANT  VARCHAR2(30) := 'revoke_user_resps';
   l_api_version_number    CONSTANT NUMBER   := 1.0;
   primary_user_ids_tbl    JTF_NUMBER_TABLE;
   business_user_ids_tbl   JTF_NUMBER_TABLE;
   l_responsibility_id_tbl JTF_NUMBER_TABLE;
   l_partner_ids_tbl       JTF_NUMBER_TABLE;

BEGIN
  ---- Initialize----------------

   -- Standard Start of API savepoint
   SAVEPOINT revoke_user_resps;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                      ,p_api_version_number
                                      ,l_api_name
                                      ,G_PKG_NAME
                                      )
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_Boolean( p_init_msg_list )
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('PRIVATE API: ' || l_api_name || ' - START');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   l_partner_ids_tbl := get_partners(p_user_id);

   IF (l_partner_ids_tbl.count = 0) THEN
       FND_MESSAGE.set_name('PV', 'PV_INVALID_PTNR_USER');
       FND_MSG_PUB.add;
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Get the program and store responsibility_id
   FOR x IN c_get_resp_info (l_partner_ids_tbl)  LOOP
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('revoke_user_resps: x.responsibility_id = ' || x.responsibility_id);
         Debug_Log('revoke_user_resps: x.user_id = ' || x.user_id);
         Debug_Log('revoke_user_resps: x.responsibility_application_id = ' || x.responsibility_application_id);
         Debug_Log('revoke_user_resps: x.security_group_id = ' || x.security_group_id);
         Debug_Log('revoke_user_resps: x.start_date = ' || x.start_date);
         Debug_Log('revoke_user_resps: x.description = ' || x.description);
      END IF;

      revoke_resp(
          p_api_version_number         => p_api_version_number
         ,p_init_msg_list              => FND_API.G_FALSE
         ,p_commit                     => FND_API.G_FALSE
         ,p_user_id                    => x.user_id
         ,p_resp_id                    => x.responsibility_id
         ,p_app_id                     => x.responsibility_application_id
         ,p_security_group_id          => x.security_group_id
         ,p_start_date                 => x.start_date
         ,p_description                => x.description
         ,x_return_status              => x_return_status
         ,x_msg_count                  => x_msg_count
         ,x_msg_data                   => x_msg_data
      );
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END LOOP;

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO revoke_user_resps;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO revoke_user_resps;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO revoke_user_resps;
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
END revoke_user_resps;


/*
 * revoke_uer_resps
 * This public API will take care of revoking all PRM responsibilities and store
 * responsibilities that are assigned upon partner enrollment into a program
 */
PROCEDURE revoke_user_resps(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_user_name                  IN   VARCHAR2
)
IS

   CURSOR c_get_user_id IS
      select usr.user_id
      from   jtf_rs_resource_extns extn, fnd_user usr
      where  extn.user_id     = usr.user_id
      and    usr.user_name	   = p_user_name;

   l_api_name              CONSTANT  VARCHAR2(30) := 'revoke_user_resps';
   l_api_version_number    CONSTANT NUMBER   := 1.0;
   l_user_role_code        VARCHAR2(30);

BEGIN
  ---- Initialize----------------

   -- Standard Start of API savepoint
   SAVEPOINT revoke_user_resps;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                      ,p_api_version_number
                                      ,l_api_name
                                      ,G_PKG_NAME
                                      )
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_Boolean( p_init_msg_list )
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('PRIVATE API: ' || l_api_name || ' - START');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   FOR x IN c_get_user_id LOOP
      get_user_role_code (
          p_user_id        => x.user_id
         ,x_user_role_code => l_user_role_code
      );
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('revoke_user_resps: l_user_role_code = ' || l_user_role_code);
      END IF;

      revoke_user_resps(
         p_api_version_number         => l_api_version_number
        ,p_init_msg_list              => FND_API.G_FALSE
        ,x_return_status              => x_return_status
        ,x_msg_count                  => x_msg_count
        ,x_msg_data                   => x_msg_data
        ,p_user_id                    => x.user_id
        ,p_user_role_code             => l_user_role_code
      );
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END LOOP;
   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO revoke_user_resps;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO revoke_user_resps;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO revoke_user_resps;
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
END revoke_user_resps;

/*
 * manage_store_resp_on_create
 * This public API will take care of creating store responsibility of partner that
 * have active membership in the program. This should be called when a new store
 * responsibility is added to a program.
 */
PROCEDURE manage_store_resp_on_create(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_resp_map_rule_id           IN   NUMBER
   ,p_resp_id                    IN   NUMBER
   ,p_program_id                 IN   NUMBER
)
IS
   CURSOR c_get_partner_and_program IS
      SELECT partner_id, program_id
      FROM   pv_pg_memberships
      WHERE  program_id in (
            SELECT           program_id
            FROM             pv_partner_program_b
            WHERE            program_level_code = 'MEMBERSHIP'
            START WITH       program_id = p_program_id
            CONNECT BY PRIOR program_id = program_parent_id
      )
      AND    membership_status_code = 'ACTIVE';

   l_api_name              CONSTANT  VARCHAR2(30) := 'manage_store_resp_on_create';
   l_api_version_number    CONSTANT NUMBER        := 1.0;
   l_user_ids_tbl          JTF_NUMBER_TABLE;
   l_ge_ptnr_resps_rec     PV_Ge_Ptnr_Resps_PVT.ge_ptnr_resps_rec_type;
   l_ptnr_resp_id          NUMBER;
   l_exist                 NUMBER;
BEGIN
  ---- Initialize----------------

   -- Standard Start of API savepoint
   SAVEPOINT manage_store_resp_on_create;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                      ,p_api_version_number
                                      ,l_api_name
                                      ,G_PKG_NAME
                                      )
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_Boolean( p_init_msg_list )
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   IF (p_resp_map_rule_id is null) THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.set_name('PV', 'PV_NO_RESP_MAP_RULE_ID');
    FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (p_resp_id is null) THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.set_name('PV', 'PV_NO_RESP_ID');
    FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (p_program_id is null) THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.set_name('PV', 'PV_NO_PROGRAM_ID');
    FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   FOR x IN c_get_partner_and_program LOOP
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('manage_store_resp_on_create: x.partner_id = ' || x.partner_id);
         Debug_Log('manage_store_resp_on_create = x.program_id' || x.program_id);
      END IF;
      l_user_ids_tbl := get_partner_users(x.partner_id, G_ALL);
      FOR l_u_cnt IN 1..l_user_ids_tbl.count LOOP
         assign_resp (
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,p_user_id                    => l_user_ids_tbl(l_u_cnt)
            ,p_resp_id                    => p_resp_id
            ,p_app_id                     => 671
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END LOOP; -- End of l_l_user_ids_tbl

      /****
       * API to add a row to pv_ge_ptnr_resps
       ****/
      l_ge_ptnr_resps_rec.partner_id := x.partner_id;
      l_ge_ptnr_resps_rec.user_role_code := G_ALL;
      l_ge_ptnr_resps_rec.program_id := x.program_id;
      l_ge_ptnr_resps_rec.responsibility_id := p_resp_id;
      l_ge_ptnr_resps_rec.source_resp_map_rule_id := p_resp_map_rule_id;
      l_ge_ptnr_resps_rec.resp_type_code := G_STORE;

      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('manage_store_resp_on_create: l_ge_ptnr_resps_rec.partner_id = ' || l_ge_ptnr_resps_rec.partner_id);
         Debug_Log('manage_store_resp_on_create: l_ge_ptnr_resps_rec.user_role_code = ' || l_ge_ptnr_resps_rec.user_role_code);
         Debug_Log('manage_store_resp_on_create: l_ge_ptnr_resps_rec.program_id = ' || l_ge_ptnr_resps_rec.program_id);
         Debug_Log('manage_store_resp_on_create: l_ge_ptnr_resps_rec.responsibility_id = ' || l_ge_ptnr_resps_rec.responsibility_id);
         Debug_Log('manage_store_resp_on_create: l_ge_ptnr_resps_rec.source_resp_map_rule_id = ' || l_ge_ptnr_resps_rec.source_resp_map_rule_id);
         Debug_Log('manage_store_resp_on_create: l_ge_ptnr_resps_rec.resp_type_code = ' || l_ge_ptnr_resps_rec.resp_type_code);
      END IF;

      PV_Ge_Ptnr_Resps_PVT.Create_Ge_Ptnr_Resps(
          p_api_version_number         => p_api_version_number
         ,p_init_msg_list              => FND_API.G_FALSE
         ,p_commit                     => FND_API.G_FALSE
         ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL

         ,x_return_status              => x_return_status
         ,x_msg_count                  => x_msg_count
         ,x_msg_data                   => x_msg_data
         ,p_ge_ptnr_resps_rec          => l_ge_ptnr_resps_rec
         ,x_ptnr_resp_id               => l_ptnr_resp_id
      );

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END LOOP; -- End of FOR x IN c_get_partner_and_program

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO manage_store_resp_on_create;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO manage_store_resp_on_create;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO manage_store_resp_on_create;
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
END manage_store_resp_on_create;

/*
 * manage_store_resp_on_delete
 * This public API will take care of deleting store responsibility of partner that
 * have active membership in the program. This should be called when a store
 * responsibility is deleted.
 */
PROCEDURE manage_store_resp_on_delete(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_resp_map_rule_id           IN   NUMBER
)
IS
   CURSOR c_get_partner_id (cv_program_id NUMBER) IS
      SELECT partner_id
      FROM   pv_pg_memberships
      WHERE  program_id = cv_program_id
      AND    membership_status_code = 'ACTIVE';

   CURSOR c_get_ptnr_resps_info IS
      SELECT ptnr_resp_id, program_id, responsibility_id, object_version_number
      FROM   pv_ge_ptnr_resps
      WHERE  source_resp_map_rule_id = p_resp_map_rule_id
      AND    resp_type_code = G_STORE;

  CURSOR c_get_count (cv_partner_id NUMBER, cv_responsibility_id NUMBER) IS
      SELECT count(*)
      FROM   pv_ge_ptnr_resps
      WHERE  partner_id = cv_partner_id
         AND user_role_code = G_ALL
         AND responsibility_id = cv_responsibility_id
         AND resp_type_code = G_STORE;

   -- Get the resp id of all other partners which have the same
   -- partner_party_id of the pass in partner
   CURSOR c_get_other_resp_id (cv_partner_id NUMBER) IS
      SELECT responsibility_id
      FROM   pv_ge_ptnr_resps
      WHERE  partner_id in (
                SELECT partner_id
                FROM   pv_partner_profiles
                WHERE  partner_party_id in (
                          SELECT partner_party_id
                          FROM pv_partner_profiles
                          WHERE partner_id = cv_partner_id
                       )
                AND    partner_id <> cv_partner_id
             )
       AND   user_role_code = G_ALL
       AND   resp_type_code = G_STORE;

   l_api_name              CONSTANT  VARCHAR2(30) := 'manage_store_resp_on_delete';
   l_api_version_number    CONSTANT NUMBER   := 1.0;
   l_count                 NUMBER;
   l_no_revoke             BOOLEAN;
   l_ge_ptnr_resps_rec     PV_Ge_Ptnr_Resps_PVT.ge_ptnr_resps_rec_type;

BEGIN
  ---- Initialize----------------

   -- Standard Start of API savepoint
   SAVEPOINT manage_store_resp_on_delete;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                      ,p_api_version_number
                                      ,l_api_name
                                      ,G_PKG_NAME
                                      )
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_Boolean( p_init_msg_list )
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   --Debug_Log('priflie: ' || fnd_profile.VALUE('FND_AS_MSG_LEVEL_THRESHOLD'));
   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('PRIVATE API: ' || l_api_name || ' - START');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   IF (p_resp_map_rule_id is null) THEN
     x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MESSAGE.set_name('PV', 'PV_NO_RESP_MAP_RULE_ID');
    FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
   END IF;

   FOR x IN c_get_ptnr_resps_info LOOP
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('manage_store_resp_on_delete: x.ptnr_resp_id = ' || x.ptnr_resp_id);
         Debug_Log('manage_store_resp_on_delete: x.program_id = ' || x.program_id);
         Debug_Log('manage_store_resp_on_delete: x.responsibility_id = ' || x.responsibility_id);
         Debug_Log('manage_store_resp_on_delete: x.object_version_number = ' || x.object_version_number);
      END IF;
      FOR y IN c_get_partner_id(x.program_id) LOOP
         OPEN c_get_count(y.partner_id, x.responsibility_id);
         FETCH c_get_count into l_count;
         CLOSE c_get_count;
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('manage_store_resp_on_delete: l_count = ' || l_count);
         END IF;
         -- If there is only this (partner_id, responsibility_id) for store responsibility combo,
         -- do the following steps.
         IF (l_count = 1) THEN
            IF (PV_DEBUG_HIGH_ON) THEN
               Debug_Log('manage_store_resp_on_delete: l_count is 1');
            END IF;

            l_no_revoke := false;
            FOR z IN c_get_other_resp_id (y.partner_id) LOOP
               -- To check if there is same resp_id assigned to the users
               -- The users in two partner_id which have the same partner_party_id
               -- We set l_no_revoke to true, that means, we will not revoke this resp
               IF (x.responsibility_id = z.responsibility_id) THEN
                  l_no_revoke := true;
                  exit;
               END IF;
            END LOOP;
            IF (not l_no_revoke) THEN
               revoke_resp(
                   p_api_version_number         => p_api_version_number
                  ,p_init_msg_list              => FND_API.G_FALSE
                  ,p_commit                     => p_commit
                  ,p_user_id                    => get_partner_users(y.partner_id, G_ALL)
                  ,p_resp_id                    => x.responsibility_id
                  ,x_return_status              => x_return_status
                  ,x_msg_count                  => x_msg_count
                  ,x_msg_data                   => x_msg_data
               );
               IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
               END IF;
            END IF; -- End of IF (not l_no_revoke)
         END IF; -- End of IF (l_count = 1)

         /****
          * API to delete the row with ptnr_resp_id = x.ptnr_resp_id from pv_partner_memberships
          ****/
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('manage_store_resp_on_delete: before calling PV_Ge_Ptnr_Resps_PVT.Delete_Ge_Ptnr_Resps');
            Debug_Log('manage_store_resp_on_delete: x.ptnr_resp_id = ' || x.ptnr_resp_id);
            Debug_Log('manage_store_resp_on_delete: x.object_version_number = ' || x.object_version_number);
         END IF;

         PV_Ge_Ptnr_Resps_PVT.Delete_Ge_Ptnr_Resps(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL

            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
            ,p_ptnr_resp_id               => x.ptnr_resp_id
            ,p_object_version_number      => x.object_version_number
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END LOOP; -- End of FOR y IN c_get_partner_id(x.program_id)
   END LOOP; -- End of FOR x IN c_get_ptnr_resps_info

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO manage_store_resp_on_delete;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO manage_store_resp_on_delete;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO manage_store_resp_on_delete;
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
END manage_store_resp_on_delete;

/*
 * assign_default_resp
 * This public API will be called when partner status changes from I to A.
 * It will assign the default responsibility to all the users of the
 * pass in partner.
 */
PROCEDURE assign_default_resp (
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_partner_id                 IN   NUMBER
)
IS
   CURSOR c_get_primary_users IS
      SELECT jtfre.user_id user_id
      FROM   hz_relationships hzr, jtf_rs_resource_extns jtfre, pv_partner_profiles pvpp, fnd_user fndu
      WHERE  pvpp.partner_id = p_partner_id
      AND    pvpp.status = 'A'
      AND    pvpp.partner_party_id = hzr.object_id
      AND    hzr.directional_flag = 'F'
      AND    hzr.relationship_code = 'EMPLOYEE_OF'
      AND    HZR.subject_table_name ='HZ_PARTIES'
      AND    HZR.object_table_name ='HZ_PARTIES'
      AND    hzr.start_date <= SYSDATE
      AND    (hzr.end_date is null or  hzr.end_date > sysdate)
      AND    HZR.status = 'A'
      AND    hzr.party_id = jtfre.source_id
      AND    jtfre.category = 'PARTY'
      AND    fndu.user_id = jtfre.user_id
      AND    fndu.start_date <= sysdate
      AND    (fndu.end_date is null or fndu.end_date > sysdate)
      AND    exists (
                SELECT    jtfp1.principal_name username
                FROM      jtf_auth_principal_maps jtfpm,
                          jtf_auth_principals_b jtfp1,
                          jtf_auth_domains_b jtfd,
                          jtf_auth_principals_b jtfp2,
                          jtf_auth_role_perms jtfrp,
                          jtf_auth_permissions_b jtfperm
                WHERE     jtfp1.is_user_flag=1
                AND       jtfp1.jtf_auth_principal_id=jtfpm.jtf_auth_principal_id
                AND       jtfpm.jtf_auth_parent_principal_id = jtfp2.jtf_auth_principal_id
                AND       jtfp2.is_user_flag=0
                AND       jtfp2.jtf_auth_principal_id = jtfrp.jtf_auth_principal_id
                AND       jtfrp.positive_flag = 1
                AND       jtfrp.jtf_auth_permission_id = jtfperm.jtf_auth_permission_id
                AND       jtfperm.permission_name in ('PV_PARTNER_USER', 'IBE_INT_PRIMARY_USER')
                AND       jtfd.jtf_auth_domain_id=jtfpm.jtf_auth_domain_id
                AND       jtfd.domain_name='CRM_DOMAIN'
		AND       jtfp1.principal_name = jtfre.user_name
                GROUP BY  jtfp1.principal_name
                HAVING    count( distinct decode(jtfperm.permission_name,  'IBE_INT_PRIMARY_USER', null, jtfperm.permission_name ) ) = 1
                AND       count(  distinct decode(jtfperm.permission_name,  'IBE_INT_PRIMARY_USER', jtfperm.permission_name, null ) ) = 1
             );

   CURSOR c_get_business_users IS
      SELECT jtfre.user_id user_id
      FROM   hz_relationships hzr,
             jtf_rs_resource_extns jtfre,
             pv_partner_profiles pvpp, fnd_user fndu
      WHERE  pvpp.partner_id = p_partner_id
      AND    pvpp.status = 'A'
      AND    pvpp.partner_party_id = hzr.object_id
      AND    hzr.directional_flag = 'F'
      AND    hzr.relationship_code = 'EMPLOYEE_OF'
      AND    HZR.subject_table_name ='HZ_PARTIES'
      AND    HZR.object_table_name ='HZ_PARTIES'
      AND    hzr.start_date <= SYSDATE
      AND    (hzr.end_date is null or  hzr.end_date > sysdate)
      AND    HZR.status = 'A'
      AND    hzr.party_id = jtfre.source_id
      AND    jtfre.category = 'PARTY'
      AND    fndu.user_id = jtfre.user_id
      AND    fndu.start_date <= sysdate
      AND    (fndu.end_date is null or fndu.end_date > sysdate)
      AND    exists  (
                SELECT    jtfp1.principal_name username
                FROM      jtf_auth_principal_maps jtfpm,
                          jtf_auth_principals_b jtfp1,
                          jtf_auth_domains_b jtfd,
                          jtf_auth_principals_b jtfp2,
                          jtf_auth_role_perms jtfrp,
                          jtf_auth_permissions_b jtfperm
                WHERE     jtfp1.is_user_flag=1
                AND       jtfp1.jtf_auth_principal_id=jtfpm.jtf_auth_principal_id
                AND       jtfpm.jtf_auth_parent_principal_id = jtfp2.jtf_auth_principal_id
                AND       jtfp2.is_user_flag=0
                AND       jtfp2.jtf_auth_principal_id = jtfrp.jtf_auth_principal_id
                AND       jtfrp.positive_flag = 1
                AND       jtfrp.jtf_auth_permission_id = jtfperm.jtf_auth_permission_id
                AND       jtfperm.permission_name in ('PV_PARTNER_USER', 'IBE_INT_PRIMARY_USER')
                AND       jtfd.jtf_auth_domain_id=jtfpm.jtf_auth_domain_id
                AND       jtfd.domain_name='CRM_DOMAIN'
		AND       jtfp1.principal_name = jtfre.user_name
                GROUP BY  jtfp1.principal_name
                HAVING    count( distinct decode(jtfperm.permission_name,  'IBE_INT_PRIMARY_USER', null, jtfperm.permission_name ) ) = 1
                AND       count(  distinct decode(jtfperm.permission_name,  'IBE_INT_PRIMARY_USER', jtfperm.permission_name, null ) ) = 0
      );

   l_api_name                  CONSTANT  VARCHAR2(30) := 'assign_default_resp';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_responsibility_id         NUMBER;
   l_resp_map_rule_id          NUMBER;
   l_partner_ids_tbl           JTF_NUMBER_TABLE;
   l_ge_ptnr_resps_rec         PV_Ge_Ptnr_Resps_PVT.ge_ptnr_resps_rec_type;
   l_ptnr_resp_id              NUMBER;

BEGIN
   ---- Initialize----------------

   -- Standard Start of API savepoint
   SAVEPOINT assign_default_resp;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                      ,p_api_version_number
                                      ,l_api_name
                                      ,G_PKG_NAME
                                      )
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_Boolean( p_init_msg_list )
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('PRIVATE API: ' || l_api_name || ' - START');
      WRITE_LOG(l_api_name, 'PRIVATE API: ' || l_api_name || ' - START');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Get the default resp for primary users
   get_default_resp(
       p_api_version_number         => p_api_version_number
      ,p_init_msg_list              => FND_API.G_FALSE
      ,p_commit                     => FND_API.G_FALSE
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,p_partner_id                 => p_partner_id
      ,p_user_role_code             => G_PRIMARY
      ,x_responsibility_id          => l_responsibility_id
      ,x_resp_map_rule_id           => l_resp_map_rule_id
   );
   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (l_responsibility_id is not null) and (l_resp_map_rule_id is not null) THEN
      FOR x in c_get_primary_users LOOP
         assign_resp(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,p_user_id                    => x.user_id
            ,p_resp_id                    => l_responsibility_id
            ,p_app_id                     => 691
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END LOOP;

      /****
       * API to add a row to pv_ge_ptnr_resps
       ****/
      l_ge_ptnr_resps_rec.partner_id := p_partner_id;
      l_ge_ptnr_resps_rec.user_role_code := G_PRIMARY;
      l_ge_ptnr_resps_rec.responsibility_id := l_responsibility_id;
      l_ge_ptnr_resps_rec.source_resp_map_rule_id := l_resp_map_rule_id;
      l_ge_ptnr_resps_rec.resp_type_code := G_PROGRAM;

      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('assign_default_resp: l_ge_ptnr_resps_rec.partner_id = ' || l_ge_ptnr_resps_rec.partner_id);
         Debug_Log('assign_default_resp: l_ge_ptnr_resps_rec.user_role_code = ' || l_ge_ptnr_resps_rec.user_role_code);
         Debug_Log('assign_default_resp: l_ge_ptnr_resps_rec.responsibility_id = ' || l_ge_ptnr_resps_rec.responsibility_id);
         Debug_Log('assign_default_resp: l_ge_ptnr_resps_rec.source_resp_map_rule_id = ' || l_ge_ptnr_resps_rec.source_resp_map_rule_id);
         Debug_Log('assign_default_resp: l_ge_ptnr_resps_rec.resp_type_code = ' || l_ge_ptnr_resps_rec.resp_type_code);
         WRITE_LOG(l_api_name, 'assign_default_resp: l_ge_ptnr_resps_rec.partner_id = ' || l_ge_ptnr_resps_rec.partner_id);
         WRITE_LOG(l_api_name, 'assign_default_resp: l_ge_ptnr_resps_rec.user_role_code = ' || l_ge_ptnr_resps_rec.user_role_code);
         WRITE_LOG(l_api_name, 'assign_default_resp: l_ge_ptnr_resps_rec.responsibility_id = ' || l_ge_ptnr_resps_rec.responsibility_id);
         WRITE_LOG(l_api_name, 'assign_default_resp: l_ge_ptnr_resps_rec.source_resp_map_rule_id = ' || l_ge_ptnr_resps_rec.source_resp_map_rule_id);
         WRITE_LOG(l_api_name, 'assign_default_resp: l_ge_ptnr_resps_rec.resp_type_code = ' || l_ge_ptnr_resps_rec.resp_type_code);
      END IF;

      PV_Ge_Ptnr_Resps_PVT.Create_Ge_Ptnr_Resps(
          p_api_version_number         => p_api_version_number
         ,p_init_msg_list              => FND_API.G_FALSE
         ,p_commit                     => FND_API.G_FALSE
         ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL

         ,x_return_status              => x_return_status
         ,x_msg_count                  => x_msg_count
         ,x_msg_data                   => x_msg_data
         ,p_ge_ptnr_resps_rec          => l_ge_ptnr_resps_rec
         ,x_ptnr_resp_id               => l_ptnr_resp_id
      );
   ELSE
      FND_MESSAGE.set_name('PV', 'PV_NO_DEFAULT_RESP');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- Get the default resp for business users
   get_default_resp(
       p_api_version_number         => p_api_version_number
      ,p_init_msg_list              => FND_API.G_FALSE
      ,p_commit                     => FND_API.G_FALSE
      ,x_return_status              => x_return_status
      ,x_msg_count                  => x_msg_count
      ,x_msg_data                   => x_msg_data
      ,p_partner_id                 => p_partner_id
      ,p_user_role_code             => G_BUSINESS
      ,x_responsibility_id          => l_responsibility_id
      ,x_resp_map_rule_id           => l_resp_map_rule_id
   );
   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   IF (l_responsibility_id is not null) and (l_resp_map_rule_id is not null) THEN
      FOR x IN c_get_business_users LOOP
         assign_resp(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,p_user_id                    => x.user_id
            ,p_resp_id                    => l_responsibility_id
            ,p_app_id                     => 691
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END LOOP;

      /****
       * API to add a row to pv_ge_ptnr_resps
       ****/
      l_ge_ptnr_resps_rec.partner_id := p_partner_id;
      l_ge_ptnr_resps_rec.user_role_code := G_BUSINESS;
      l_ge_ptnr_resps_rec.responsibility_id := l_responsibility_id;
      l_ge_ptnr_resps_rec.source_resp_map_rule_id := l_resp_map_rule_id;
      l_ge_ptnr_resps_rec.resp_type_code := G_PROGRAM;

      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('assign_default_resp: l_ge_ptnr_resps_rec.partner_id = ' || l_ge_ptnr_resps_rec.partner_id);
         Debug_Log('assign_default_resp: l_ge_ptnr_resps_rec.user_role_code = ' || l_ge_ptnr_resps_rec.user_role_code);
         Debug_Log('assign_default_resp: l_ge_ptnr_resps_rec.responsibility_id = ' || l_ge_ptnr_resps_rec.responsibility_id);
         Debug_Log('assign_default_resp: l_ge_ptnr_resps_rec.source_resp_map_rule_id = ' || l_ge_ptnr_resps_rec.source_resp_map_rule_id);
         Debug_Log('assign_default_resp: l_ge_ptnr_resps_rec.resp_type_code = ' || l_ge_ptnr_resps_rec.resp_type_code);
         WRITE_LOG(l_api_name, 'assign_default_resp: l_ge_ptnr_resps_rec.partner_id = ' || l_ge_ptnr_resps_rec.partner_id);
         WRITE_LOG(l_api_name, 'assign_default_resp: l_ge_ptnr_resps_rec.user_role_code = ' || l_ge_ptnr_resps_rec.user_role_code);
         WRITE_LOG(l_api_name, 'assign_default_resp: l_ge_ptnr_resps_rec.responsibility_id = ' || l_ge_ptnr_resps_rec.responsibility_id);
         WRITE_LOG(l_api_name, 'assign_default_resp: l_ge_ptnr_resps_rec.source_resp_map_rule_id = ' || l_ge_ptnr_resps_rec.source_resp_map_rule_id);
         WRITE_LOG(l_api_name, 'assign_default_resp: l_ge_ptnr_resps_rec.resp_type_code = ' || l_ge_ptnr_resps_rec.resp_type_code);
      END IF;

      PV_Ge_Ptnr_Resps_PVT.Create_Ge_Ptnr_Resps(
          p_api_version_number         => p_api_version_number
         ,p_init_msg_list              => FND_API.G_FALSE
         ,p_commit                     => FND_API.G_FALSE
         ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL

         ,x_return_status              => x_return_status
         ,x_msg_count                  => x_msg_count
         ,x_msg_data                   => x_msg_data
         ,p_ge_ptnr_resps_rec          => l_ge_ptnr_resps_rec
         ,x_ptnr_resp_id               => l_ptnr_resp_id
      );
   ELSE
      FND_MESSAGE.set_name('PV', 'PV_NO_DEFAULT_RESP');
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO assign_default_resp;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO assign_default_resp;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO assign_default_resp;
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
END assign_default_resp;

/*
 * manage_resp_on_address_change
 * This public procedure will take care of managing partner responsibilities
 * when partner organization address changes.
 */
PROCEDURE manage_resp_on_address_change(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_org_party_id               IN   NUMBER
)
IS
   CURSOR c_get_partner_id IS
      SELECT    partner_id
      FROM      pv_partner_profiles
      WHERE     partner_party_id = p_org_party_id;

   CURSOR c_get_resp_info (cv_partner_id NUMBER) IS
      SELECT   ptnr_resp_id, responsibility_id, partner_id, program_id,
               user_role_code, object_version_number
      FROM     pv_ge_ptnr_resps
      WHERE    partner_id = cv_partner_id
      AND      resp_type_code = G_PROGRAM
      ORDER BY user_role_code;

   CURSOR c_check_prgm_resp_exist (cv_partner_id NUMBER, cv_user_role_code VARCHAR2) IS
      SELECT 1
      FROM   pv_ge_ptnr_resps
      WHERE  partner_id = cv_partner_id
      AND    user_role_code = cv_user_role_code
      AND    resp_type_code = G_PROGRAM;

   l_api_name                  CONSTANT  VARCHAR2(30) := 'manage_resp_on_address_change';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   primary_user_ids_tbl        JTF_NUMBER_TABLE;
   business_user_ids_tbl       JTF_NUMBER_TABLE;
   l_responsibility_id         NUMBER;
   l_resp_map_rule_id          NUMBER;
   l_ge_ptnr_resps_rec         PV_Ge_Ptnr_Resps_PVT.ge_ptnr_resps_rec_type;
   l_ptnr_resp_id              NUMBER;
   l_exist                     NUMBER;
BEGIN
   ---- Initialize----------------

   -- Standard Start of API savepoint
   SAVEPOINT manage_resp_on_address_change;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                      ,p_api_version_number
                                      ,l_api_name
                                      ,G_PKG_NAME
                                      )
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_Boolean( p_init_msg_list )
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('PRIVATE API: ' || l_api_name || ' - START');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   FOR x IN c_get_partner_id LOOP
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('manage_resp_on_address_change: x.partner_id = ' || x.partner_id);
      END IF;
      primary_user_ids_tbl := null;
      business_user_ids_tbl := null;
      FOR y IN c_get_resp_info(x.partner_id) LOOP
         IF (y.user_role_code = G_PRIMARY) THEN
            -- Get all users of the partner_id and the user_role_code by calling get_partner_users().
            -- Only do this once for each partner
            IF (primary_user_ids_tbl is null) THEN
               IF (PV_DEBUG_HIGH_ON) THEN
                  Debug_Log('manage_resp_on_address_change: primary_user_ids_tbl is null');
               END IF;
               primary_user_ids_tbl := get_partner_users(x.partner_id, y.user_role_code);
            END IF;

            IF (PV_DEBUG_HIGH_ON) THEN
               Debug_Log('manage_resp_on_address_change: y.responsibility_id = ' || y.responsibility_id);
            END IF;
            revoke_resp(
                p_api_version_number         => p_api_version_number
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => p_commit
               ,p_user_id                    => primary_user_ids_tbl
               ,p_resp_id                    => y.responsibility_id
               ,x_return_status              => x_return_status
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
            );
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;
         IF (y.user_role_code = G_BUSINESS) THEN
            -- Get all users of the partner_id and the user_role_code by calling get_partner_users().
            -- Only do this once for each partner
            IF (business_user_ids_tbl is null) THEN
               IF (PV_DEBUG_HIGH_ON) THEN
                  Debug_Log('manage_resp_on_address_change: primary_user_ids_tbl is null');
               END IF;
               business_user_ids_tbl := get_partner_users(x.partner_id, y.user_role_code);
            END IF;

            IF (PV_DEBUG_HIGH_ON) THEN
               Debug_Log('manage_resp_on_address_change: y.responsibility_id = ' || y.responsibility_id);
            END IF;
            revoke_resp(
                p_api_version_number         => p_api_version_number
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => p_commit
               ,p_user_id                    => business_user_ids_tbl
               ,p_resp_id                    => y.responsibility_id
               ,x_return_status              => x_return_status
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
            );
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;

         /****
          * API to delete the row with ptnr_resp_id = x.ptnr_resp_id
          ****/
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('manage_resp_on_address_change: before calling PV_Ge_Ptnr_Resps_PVT.Delete_Ge_Ptnr_Resps');
            Debug_Log('manage_resp_on_address_change: y.ptnr_resp_id = ' || y.ptnr_resp_id);
            Debug_Log('manage_resp_on_address_change: y.object_version_number = ' || y.object_version_number);
         END IF;

         PV_Ge_Ptnr_Resps_PVT.Delete_Ge_Ptnr_Resps(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL

            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
            ,p_ptnr_resp_id               => y.ptnr_resp_id
            ,p_object_version_number      => y.object_version_number
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         IF (y.program_id IS NOT NULL) THEN
            get_program_resp(
                p_api_version_number         => p_api_version_number
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,x_return_status              => x_return_status
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
               ,p_partner_id                 => x.partner_id
               ,p_user_role_code             => y.user_role_code
               ,p_program_id                 => y.program_id
               ,x_responsibility_id          => l_responsibility_id
               ,x_resp_map_rule_id           => l_resp_map_rule_id
            );
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         ELSE

            get_default_resp(
                p_api_version_number         => p_api_version_number
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,x_return_status              => x_return_status
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
               ,p_partner_id                 => x.partner_id
               ,p_user_role_code             => y.user_role_code
               ,x_responsibility_id          => l_responsibility_id
               ,x_resp_map_rule_id           => l_resp_map_rule_id
            );
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF;
         IF (l_responsibility_id is not null) and (l_resp_map_rule_id is not null) THEN
            IF (y.user_role_code = G_PRIMARY) THEN
               FOR l_cnt IN 1..primary_user_ids_tbl.count LOOP
                  IF (PV_DEBUG_HIGH_ON) THEN
                     Debug_Log('manage_resp_on_address_change: assign: primary_user_ids_tbl('||l_cnt||')='||primary_user_ids_tbl(l_cnt));
                  END IF;
                  assign_resp(
                      p_api_version_number         => p_api_version_number
                     ,p_init_msg_list              => FND_API.G_FALSE
                     ,p_commit                     => FND_API.G_FALSE
                     ,p_user_id                    => primary_user_ids_tbl(l_cnt)
                     ,p_resp_id                    => l_responsibility_id
                     ,p_app_id                     => 691
                     ,x_return_status              => x_return_status
                     ,x_msg_count                  => x_msg_count
                     ,x_msg_data                   => x_msg_data
                  );
                  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                     RAISE FND_API.G_EXC_ERROR;
                  END IF;
               END LOOP;
            ELSIF (y.user_role_code = G_BUSINESS) THEN
               FOR l_cnt IN 1..business_user_ids_tbl.count LOOP
                  IF (PV_DEBUG_HIGH_ON) THEN
                     Debug_Log('manage_resp_on_address_change: assign: business_user_ids_tbl('||l_cnt||')='||business_user_ids_tbl(l_cnt));
                  END IF;
                  assign_resp(
                      p_api_version_number         => p_api_version_number
                     ,p_init_msg_list              => FND_API.G_FALSE
                     ,p_commit                     => FND_API.G_FALSE
                     ,p_user_id                    => business_user_ids_tbl(l_cnt)
                     ,p_resp_id                    => l_responsibility_id
                     ,p_app_id                     => 691
                     ,x_return_status              => x_return_status
                     ,x_msg_count                  => x_msg_count
                     ,x_msg_data                   => x_msg_data
                  );
                  IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                     RAISE FND_API.G_EXC_ERROR;
                  END IF;
               END LOOP;
            END IF;

            /****
             * API to add a row to pv_ge_ptnr_resps
             ****/
            l_ge_ptnr_resps_rec.partner_id := x.partner_id;
            l_ge_ptnr_resps_rec.user_role_code := y.user_role_code;
            l_ge_ptnr_resps_rec.responsibility_id := l_responsibility_id;
            l_ge_ptnr_resps_rec.source_resp_map_rule_id := l_resp_map_rule_id;
            l_ge_ptnr_resps_rec.resp_type_code := G_PROGRAM;
            IF (y.program_id IS NOT NULL) THEN
               l_ge_ptnr_resps_rec.program_id := y.program_id;
            END IF;

            IF (PV_DEBUG_HIGH_ON) THEN
               Debug_Log('manage_resp_on_address_change: l_ge_ptnr_resps_rec.partner_id = ' || l_ge_ptnr_resps_rec.partner_id);
               Debug_Log('manage_resp_on_address_change: l_ge_ptnr_resps_rec.user_role_code = ' || l_ge_ptnr_resps_rec.user_role_code);
               Debug_Log('manage_resp_on_address_change: l_ge_ptnr_resps_rec.program_id = ' || l_ge_ptnr_resps_rec.program_id);
               Debug_Log('manage_resp_on_address_change: l_ge_ptnr_resps_rec.responsibility_id = ' || l_ge_ptnr_resps_rec.responsibility_id);
               Debug_Log('manage_resp_on_address_change: l_ge_ptnr_resps_rec.source_resp_map_rule_id = ' || l_ge_ptnr_resps_rec.source_resp_map_rule_id);
               Debug_Log('manage_resp_on_address_change: l_ge_ptnr_resps_rec.resp_type_code = ' || l_ge_ptnr_resps_rec.resp_type_code);
            END IF;

            PV_Ge_Ptnr_Resps_PVT.Create_Ge_Ptnr_Resps(
                p_api_version_number         => p_api_version_number
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL

               ,x_return_status              => x_return_status
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
               ,p_ge_ptnr_resps_rec          => l_ge_ptnr_resps_rec
               ,x_ptnr_resp_id               => l_ptnr_resp_id
            );
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END IF; -- End of IF (l_responsibility_id is not null) and (l_resp_map_rule_id is not null)
      END LOOP; -- End of FOR y IN c_get_resp_info(x.partner_id)

      -- Check if at least one partner responsibility exists in
      -- PV_GE_PTNR_RESPS for G_PRIMARY and G_BUSINESS
      -- check for G_PRIMARY first
      OPEN c_check_prgm_resp_exist(x.partner_id, G_PRIMARY);
      FETCH c_check_prgm_resp_exist INTO l_exist;
      IF (c_check_prgm_resp_exist%NOTFOUND) THEN
         -- Get the new default resp, assign it to the users, and add a new
         -- row into pv_ge_ptnr_resps
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('manage_resp_on_address_change: c_check_prgm_resp_exist%NOTFOUND - G_PRIMARY');
         END IF;
         get_default_assign_addrow(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
            ,p_user_role_code             => G_PRIMARY
            ,p_user_ids_tbl               => primary_user_ids_tbl
            ,p_partner_id                 => x.partner_id
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            CLOSE c_check_prgm_resp_exist;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;
      CLOSE c_check_prgm_resp_exist;

      -- check for G_BUSINESS
      OPEN c_check_prgm_resp_exist(x.partner_id, G_BUSINESS);
      FETCH c_check_prgm_resp_exist INTO l_exist;
      IF (c_check_prgm_resp_exist%NOTFOUND) THEN
         -- Get the new default resp, assign it to the users, and add a new
         -- row into pv_ge_ptnr_resps
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('manage_resp_on_address_change: c_check_prgm_resp_exist%NOTFOUND - G_BUSINESS');
         END IF;
         get_default_assign_addrow(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => FND_API.G_FALSE
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
            ,p_user_role_code             => G_BUSINESS
            ,p_user_ids_tbl               => business_user_ids_tbl
            ,p_partner_id                 => x.partner_id
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            CLOSE c_check_prgm_resp_exist;
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF; -- End of IF (c_check_prgm_resp_exist%NOTFOUND)
      CLOSE c_check_prgm_resp_exist;
   END LOOP; -- End of FOR x IN c_get_partner_id

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION
   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO manage_resp_on_address_change;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO manage_resp_on_address_change;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO manage_resp_on_address_change;
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
END manage_resp_on_address_change;

/*
 * revoke_default_resp
 * This public API will be called when partner status changes from A to I
 * after the call to PV_Pg_Memberships_PVT.Terminate_ptr_memberships
 * Because after the the call PV_Pg_Memberships_PVT.Terminate_ptr_memberships
 * at least one responsibility will be assigned to the users, if the
 * partner is inactivated, we want to revoke all the responsibilities.
 */
PROCEDURE revoke_default_resp (
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_partner_id                 IN   NUMBER
)
IS
   CURSOR c_get_default_resp IS
      SELECT ptnr_resp_id, user_role_code, responsibility_id, object_version_number
      FROM   pv_ge_ptnr_resps
      WHERE  partner_id = p_partner_id
      AND    program_id is null
      AND    resp_type_code = G_PROGRAM;

   l_api_name                  CONSTANT  VARCHAR2(30) := 'revoke_default_resp';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   primary_user_ids_tbl        JTF_NUMBER_TABLE;
   business_user_ids_tbl       JTF_NUMBER_TABLE;

BEGIN
   ---- Initialize----------------

   -- Standard Start of API savepoint
   SAVEPOINT revoke_default_resp;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                      ,p_api_version_number
                                      ,l_api_name
                                      ,G_PKG_NAME
                                      )
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_Boolean( p_init_msg_list )
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;
   /*
   Pvx_Utility_Pvt.debug_message('g_log_to_file... = ' || g_log_to_file);

   FND_MESSAGE.set_name('PV', 'PV_DEBUG_MESSAGE');
   FND_MESSAGE.set_token('TEXT', g_log_to_file);
   FND_MSG_PUB.add;
   */
   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('PRIVATE API: ' || l_api_name || ' - START');
      WRITE_LOG(l_api_name, 'PRIVATE API: ' || l_api_name || ' - START');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   -- Get all users of the partner_id and the user_role_code.
   primary_user_ids_tbl := get_partner_users_2(p_partner_id, G_PRIMARY);
   business_user_ids_tbl := get_partner_users_2(p_partner_id, G_BUSINESS);

   FOR x IN c_get_default_resp LOOP
      IF (x.user_role_code = G_PRIMARY) THEN
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('revoke_default_resp: x.responsibility_id = ' || x.responsibility_id);
            WRITE_LOG(l_api_name, 'revoke_default_resp: x.responsibility_id = ' || x.responsibility_id);
         END IF;
         revoke_resp(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => p_commit
            ,p_user_id                    => primary_user_ids_tbl
            ,p_resp_id                    => x.responsibility_id
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      ELSIF (x.user_role_code = G_BUSINESS) THEN
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('revoke_default_resp: x.responsibility_id = ' || x.responsibility_id);
            WRITE_LOG(l_api_name, 'revoke_default_resp: x.responsibility_id = ' || x.responsibility_id);
         END IF;
         revoke_resp(
             p_api_version_number         => p_api_version_number
            ,p_init_msg_list              => FND_API.G_FALSE
            ,p_commit                     => p_commit
            ,p_user_id                    => business_user_ids_tbl
            ,p_resp_id                    => x.responsibility_id
            ,x_return_status              => x_return_status
            ,x_msg_count                  => x_msg_count
            ,x_msg_data                   => x_msg_data
         );
         IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;
      END IF;

      /****
       * API to delete the row with ptnr_resp_id = x.ptnr_resp_id from pv_partner_memberships
       ****/
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('revoke_default_resp: before calling PV_Ge_Ptnr_Resps_PVT.Delete_Ge_Ptnr_Resps');
         Debug_Log('revoke_default_resp: x.ptnr_resp_id = ' || x.ptnr_resp_id);
         WRITE_LOG(l_api_name, 'revoke_default_resp: before calling PV_Ge_Ptnr_Resps_PVT.Delete_Ge_Ptnr_Resps');
         WRITE_LOG(l_api_name, 'revoke_default_resp: x.ptnr_resp_id = ' || x.ptnr_resp_id);
      END IF;

      PV_Ge_Ptnr_Resps_PVT.Delete_Ge_Ptnr_Resps(
          p_api_version_number         => p_api_version_number
         ,p_init_msg_list              => FND_API.G_FALSE
         ,p_commit                     => FND_API.G_FALSE
         ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL

         ,x_return_status              => x_return_status
         ,x_msg_count                  => x_msg_count
         ,x_msg_data                   => x_msg_data
         ,p_ptnr_resp_id               => x.ptnr_resp_id
         ,p_object_version_number      => x.object_version_number
      );
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END LOOP;
      -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO revoke_default_resp;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO revoke_default_resp;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO revoke_default_resp;
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
END revoke_default_resp;

/*
* adjust_user_resps
* input: p_user_id, p_resp_id, p_app_id
* assigning the user p_user_id with resp p_resp_id for application p_app_id
*
*/

PROCEDURE adjust_user_resps
(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2  := Fnd_Api.g_false
   ,p_commit                     IN   VARCHAR2  := Fnd_Api.g_false
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_user_id			 	         IN   NUMBER
   ,p_def_resp_id		 			   IN   NUMBER
   ,p_user_role_code             IN   VARCHAR2
   ,p_partner_id				 	   IN   NUMBER
)
IS
   CURSOR c_get_resp_id IS
      SELECT responsibility_id
      FROM   pv_ge_ptnr_resps
      WHERE  partner_id = p_partner_id
      AND    user_role_code = p_user_role_code
      AND    resp_type_code = G_PROGRAM;

   CURSOR c_get_user_resp_groups IS
      SELECT  user_id, responsibility_id, responsibility_application_id, security_group_id, start_date, description
      FROM    fnd_user_resp_groups
      WHERE   user_id = p_user_id
      AND     responsibility_id = p_def_resp_id;

   l_api_name                  CONSTANT  VARCHAR2(30) := 'adjust_user_resps';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_exist                    NUMBER;

BEGIN
  ---- Initialize----------------

   -- Standard Start of API savepoint
   SAVEPOINT assign_user_resps;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                      ,p_api_version_number
                                      ,l_api_name
                                      ,G_PKG_NAME
                                      )
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_Boolean( p_init_msg_list )
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      Debug_Log('PRIVATE API: ' || l_api_name || ' - START');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   FOR x IN c_get_resp_id LOOP
      IF (PV_DEBUG_HIGH_ON) THEN
         Debug_Log('adjust_user_resps: x.responsibility_id: ' || x.responsibility_id);
      END IF;
      IF (x.responsibility_id = p_def_resp_id) THEN
         -- The p_def_resp_id is the default resp in pv_ge_ptnr_resps
         -- Do nothing
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('adjust_user_resps: c_same_resp_exists%NOTFOUND');
         END IF;
      ELSE
         -- The p_def_resp_id is not the default resp in pv_ge_ptnr_resps
         -- Revoke the original default resp in pv_ge_ptnr_resps.
         -- Assign p_def_resp_id to the user.
         IF (PV_DEBUG_HIGH_ON) THEN
            Debug_Log('adjust_user_resps: !c_same_resp_exists%NOTFOUND');
         END IF;

         FOR y IN c_get_user_resp_groups LOOP
            -- Debug Message
            IF (PV_DEBUG_HIGH_ON) THEN
               Debug_Log('adjust_user_resps: y.responsibility_id = ' || y.responsibility_id);
               Debug_Log('adjust_user_resps: y.user_id = ' || y.user_id);
               Debug_Log('adjust_user_resps: y.responsibility_application_id = ' || y.responsibility_application_id);
               Debug_Log('adjust_user_resps: y.security_group_id = ' || y.security_group_id);
               Debug_Log('adjust_user_resps: y.start_date = ' || y.start_date);
               Debug_Log('adjust_user_resps: y.description = ' || y.description);
            END IF;

            revoke_resp(
                p_api_version_number         => p_api_version_number
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,p_user_id                    => y.user_id
               ,p_resp_id                    => y.responsibility_id
               ,p_app_id                     => y.responsibility_application_id
               ,p_security_group_id          => y.security_group_id
               ,p_start_date                 => y.start_date
               ,p_description                => y.description
               ,x_return_status              => x_return_status
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
            );
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;

            assign_resp (
                p_api_version_number         => p_api_version_number
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,p_user_id                    => p_user_id
               ,p_resp_id                    => x.responsibility_id
               ,p_app_id                     => 691
               ,x_return_status              => x_return_status
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
            );
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END LOOP;
      END IF;
   END LOOP;

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
     PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO assign_user_resps;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO assign_user_resps;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO assign_user_resps;
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

END adjust_user_resps;

procedure exec_cre_upd_del_resp_mapping (
    ERRBUF                       OUT  NOCOPY VARCHAR2
   ,RETCODE                      OUT  NOCOPY VARCHAR2
   ,p_action                     IN   VARCHAR2
   ,p_source_resp_map_rule_id    IN   NUMBER
)
IS
   l_api_version_number       NUMBER;
   l_init_msg_list            VARCHAR2(1);
   l_return_status            VARCHAR2(1);
   l_msg_count                NUMBER;
   l_msg_data                 VARCHAR2(32767);

BEGIN
   g_log_to_file := 'Y';
   Debug_Log('exec_cre_upd_del_resp_mapping: BEGIN');
   Debug_Log('exec_cre_upd_del_resp_mapping: p_action = ' || p_action);
   Debug_Log('exec_cre_upd_del_resp_mapping: p_source_resp_map_rule_id = ' || p_source_resp_map_rule_id);

   IF (p_action IS NULL or (p_action <> 'CRE' and p_action <> 'DEL' and p_action <> 'UPD')) THEN
      RAISE bad_action;
   ELSIF (p_source_resp_map_rule_id IS NULL) THEN
      RAISE no_source_resp_map_rule_id;
   END IF;

   l_api_version_number := 1.0;
   l_init_msg_list := FND_API.g_true;

   IF (p_action = 'CRE') THEN
     Debug_Log('exec_cre_upd_del_resp_mapping: execute create_resp_mapping');
     create_resp_mapping(
         p_api_version_number         => l_api_version_number
        ,p_init_msg_list              => FND_API.G_FALSE
        ,x_return_status              => l_return_status
        ,x_msg_count                  => l_msg_count
        ,x_msg_data                   => l_msg_data
        ,p_source_resp_map_rule_id    => p_source_resp_map_rule_id
      );
   ELSIF (p_action = 'DEL') THEN
    Debug_Log('exec_cre_upd_del_resp_mapping: execute delete_resp_mapping');
      delete_resp_mapping(
         p_api_version_number         => l_api_version_number
        ,p_init_msg_list              => FND_API.G_FALSE
        ,x_return_status              => l_return_status
        ,x_msg_count                  => l_msg_count
        ,x_msg_data                   => l_msg_data
        ,p_source_resp_map_rule_id    => p_source_resp_map_rule_id
      );
   ELSIF (p_action = 'UPD') THEN
     Debug_Log('exec_cre_upd_del_resp_mapping: execute update_resp_mapping');
     update_resp_mapping(
         p_api_version_number         => l_api_version_number
        ,p_init_msg_list              => FND_API.G_FALSE
        ,x_return_status              => l_return_status
        ,x_msg_count                  => l_msg_count
        ,x_msg_data                   => l_msg_data
        ,p_source_resp_map_rule_id    => p_source_resp_map_rule_id
      );
   END IF;

   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      Debug_Log('exec_cre_upd_del_resp_mapping: l_return_status <> FND_API.G_RET_STS_SUCCESS');
      RAISE exc_error;
   END IF;

   Debug_Log('exec_cre_upd_del_resp_mapping: END');
   RETCODE := '0';
   COMMIT;

EXCEPTION
WHEN bad_action THEN
   Debug_Log('------------bad_action-----------------');
   RETCODE := '2';
   ROLLBACK;

WHEN no_source_resp_map_rule_id THEN
   Debug_Log('------------no_source_resp_map_rule_id-----------------');
   RETCODE := '2';
   ROLLBACK;

WHEN exc_error THEN
   Debug_Log('------------exc_error-----------------');
   IF l_msg_count > 1 THEN
      fnd_msg_pub.reset;
      FOR i IN 1..l_msg_count LOOP
         Debug_Log(fnd_msg_pub.get(p_encoded => fnd_api.g_false));
      END LOOP;
   ELSE
      Debug_Log(l_msg_data);
   END IF;
   RETCODE := '2';
   ROLLBACK;

WHEN OTHERS THEN
   Debug_Log(sqlerrm);
   RETCODE := sqlcode;
   ERRBUF := sqlerrm;
   ROLLBACK;

END exec_cre_upd_del_resp_mapping;

procedure exec_asgn_or_rvok_user_resps (
    ERRBUF                       OUT  NOCOPY VARCHAR2
   ,RETCODE                      OUT  NOCOPY VARCHAR2
   ,p_action                     IN   VARCHAR2
   ,p_user_name                  IN   VARCHAR2
)
IS
   l_api_version_number       NUMBER;
   l_init_msg_list            VARCHAR2(1);
   l_return_status            VARCHAR2(1);
   l_msg_count                NUMBER;
   l_msg_data                 VARCHAR2(32767);

BEGIN
   g_log_to_file := 'Y';

   Debug_Log('exec_asgn_or_rvok_user_resps: BEGIN');
   Debug_Log('exec_asgn_or_rvok_user_resps: p_action = ' || p_action);
   Debug_Log('exec_asgn_or_rvok_user_resps: p_user_name = ' || p_user_name);

   IF (p_action IS NULL or (p_action <> 'A' and p_action <> 'R')) THEN
      RAISE bad_action;
   ELSIF (p_user_name IS NULL) THEN
      RAISE no_user_name;
   END IF;

   l_api_version_number := 1.0;
   l_init_msg_list := FND_API.g_true;

   IF (p_action = 'A') THEN
    Debug_Log('exec_asgn_or_rvok_user_resps: execute assign_user_resps');
     assign_user_resps(
         p_api_version_number         => l_api_version_number
        ,p_init_msg_list              => FND_API.G_FALSE
        ,x_return_status              => l_return_status
        ,x_msg_count                  => l_msg_count
        ,x_msg_data                   => l_msg_data
        ,p_user_name                  => p_user_name
      );
   ELSE
    Debug_Log('exec_asgn_or_rvok_user_resps: execute revoke_user_resps');
      revoke_user_resps(
         p_api_version_number         => l_api_version_number
        ,p_init_msg_list              => FND_API.G_FALSE
        ,x_return_status              => l_return_status
        ,x_msg_count                  => l_msg_count
        ,x_msg_data                   => l_msg_data
        ,p_user_name                  => p_user_name
      );
   END IF;

   IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      Debug_Log('exec_asgn_or_rvok_user_resps: l_return_status <> FND_API.G_RET_STS_SUCCESS');
      RAISE exc_error;
   END IF;

   Debug_Log('exec_asgn_or_rvok_user_resps: END');
   RETCODE := '0';
   COMMIT;

EXCEPTION
WHEN bad_action THEN
   Debug_Log('------------bad_action-----------------');
   RETCODE := '2';
   ROLLBACK;

WHEN no_user_name THEN
   Debug_Log('------------no_user_name-----------------');
   RETCODE := '2';
   ROLLBACK;

WHEN exc_error THEN
   Debug_Log('------------exc_error-----------------');
   IF l_msg_count > 1 THEN
      fnd_msg_pub.reset;
      FOR i IN 1..l_msg_count LOOP
         Debug_Log(fnd_msg_pub.get(p_encoded => fnd_api.g_false));
      END LOOP;
   ELSE
      Debug_Log(l_msg_data);
   END IF;
   RETCODE := '2';
   ROLLBACK;

WHEN OTHERS THEN
   Debug_Log(sqlerrm);
   RETCODE := sqlcode;
   ERRBUF := sqlerrm;
   ROLLBACK;

END exec_asgn_or_rvok_user_resps;

/*****************************
 * manage_resp_on_address_change
 *****************************/
FUNCTION manage_resp_on_address_change
( p_subscription_guid  in raw,
  p_event              in out NOCOPY wf_event_t
)
RETURN VARCHAR2
IS
   l_api_name          CONSTANT VARCHAR2(30) := 'manage_resp_on_address_change';
   l_org_id            NUMBER;
   l_location_id       NUMBER;
   l_partner_id        NUMBER;
   l_party_site_id     NUMBER;
   l_party_id          NUMBER;
   x_return_status     VARCHAR2(10);
   x_msg_count         NUMBER;
   x_msg_data          VARCHAR2(2000);
   l_key         VARCHAR2(240) := p_event.GetEventKey();
   CURSOR get_party_id_csr ( p_location_id  IN NUMBER ) IS
   SELECT partner_party_id
   FROM   pv_partner_profiles prof
          , hz_party_sites st
          , hz_locations   loc
   WHERE  prof.partner_party_id = st.party_id
   AND    prof.status = 'A'
   AND    st.location_id=loc.location_id
   AND    st.identifying_address_flag = 'Y'
   AND    st.status='A'
   AND    st.location_id= p_location_id;

  CURSOR is_partner_csr (cv_party_site_id NUMBER) IS
    SELECT partner_id
    FROM   hz_party_sites hzps,
           pv_partner_profiles ppp
    WHERE  hzps.party_site_id = cv_party_site_id
    AND    hzps.status = 'A'
    AND    hzps.identifying_address_flag = 'Y'
    AND    ppp.partner_party_id = hzps.party_id
    AND	   ppp.status = 'A';

 BEGIN
   FND_MSG_PUB.initialize;

   IF (PV_DEBUG_HIGH_ON) THEN
     WRITE_LOG(l_api_name, 'Start manage_resp_on_address_change');
   END IF;
   l_location_id         := p_event.GetValueForParameter('LOCATION_ID');
   IF (PV_DEBUG_HIGH_ON) THEN
     WRITE_LOG(l_api_name, 'l_location_id = ' ||to_char( l_location_id));
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- modified by pukken to get the partner_party_id from the location_id.
   IF ( l_key like 'oracle.apps.ar.hz.Location.update%'  ) THEN
      FOR x in get_party_id_csr ( l_location_id ) LOOP
         IF (PV_DEBUG_HIGH_ON) THEN
           WRITE_LOG(l_api_name, 'partner party_id = ' || to_char(x.partner_party_id) );
	 END IF;
         Pv_User_Resp_Pvt.manage_resp_on_address_change (
             p_api_version_number      => 1.0
            ,p_init_msg_list           => FND_API.G_FALSE
            ,p_commit                  => FND_API.G_FALSE
            ,x_return_status           => x_return_status
            ,x_msg_count               => x_msg_count
            ,x_msg_data                => x_msg_data
            ,p_org_party_id            => x.partner_party_id
         );
	 IF (PV_DEBUG_HIGH_ON) THEN
           WRITE_LOG(l_api_name, 'x_return_status = ' || x_return_status || 'x_msg_data is ' || x_msg_data);
	 END IF;
      END LOOP;
   END IF;
   IF (PV_DEBUG_HIGH_ON) THEN
     WRITE_LOG(l_api_name, 'After loop call to  manage_resp_on_address_change API');
   END IF;

   --jkylee added changes
   l_party_site_id := p_event.GetValueForParameter('PARTY_SITE_ID');
   IF (PV_DEBUG_HIGH_ON) THEN
        WRITE_LOG(l_api_name, ' l_party_site_id   = ' ||  to_char(l_party_site_id)  );
   END IF;

   IF ( l_key like 'oracle.apps.ar.hz.PartySite.update%'  ) THEN
      IF (PV_DEBUG_HIGH_ON) THEN
        WRITE_LOG(l_api_name, 'oracle.apps.ar.hz.PartySite.update event fired');
      END IF;

      /* check if the party_id exists in pv_partner_profiles table and
         also make sure that the address change is for the location of primary address..
         if yes..call resp mapping api
      */
      OPEN is_partner_csr( l_party_site_id );
      FETCH is_partner_csr INTO l_partner_id;
      IF is_partner_csr%FOUND THEN
      	 CLOSE is_partner_csr;
	 IF (PV_DEBUG_HIGH_ON) THEN
      	   WRITE_LOG(l_api_name, 'in party site update evnt before manage update address api call');
	 END IF;
      	 Pv_User_Resp_Pvt.manage_resp_on_address_change (
             p_api_version_number      => 1.0
            ,p_init_msg_list           => FND_API.G_FALSE
            ,p_commit                  => FND_API.G_FALSE
            ,x_return_status           => x_return_status
            ,x_msg_count               => x_msg_count
            ,x_msg_data                => x_msg_data
            ,p_org_party_id            => l_party_id
         );
	 IF (PV_DEBUG_HIGH_ON) THEN
           WRITE_LOG(l_api_name, 'party site update subscription x_return_status = ' || x_return_status || 'x_msg_data is ' || x_msg_data);
	 END IF;
      END IF;-- end of if , if the party is an active partner
   END IF; -- end of if , if the event is PartySite.update

   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   RETURN 'SUCCESS';
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    IF (PV_DEBUG_HIGH_ON) THEN
      WRITE_LOG(l_api_name, 'G_EXC_ERROR');
    END IF;
    WF_CORE.CONTEXT('Pv_User_Resp_Pvt', 'manage_resp_on_address_change', p_event.getEventName(), p_subscription_guid);
    WF_EVENT.setErrorInfo(p_event, 'Error from manage_resp_on_address_change');
    RETURN 'ERROR';
 WHEN OTHERS THEN
    IF (PV_DEBUG_HIGH_ON) THEN
      WRITE_LOG(l_api_name, 'OTHER');
    END IF;
    WF_CORE.CONTEXT('Pv_User_Resp_Pvt', 'manage_resp_on_address_change', p_event.getEventName(), p_subscription_guid);
    WF_EVENT.setErrorInfo(p_event, 'ERROR');
    RETURN 'ERROR';
END;

/*
 * manage_merged_party_memb_resp
 * This public API will take care of managing user responsibilities when
 * two parties are merged.
 */
PROCEDURE manage_merged_party_memb_resp(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
   ,p_from_partner_id            IN   NUMBER
   ,p_to_partner_id              IN   NUMBER
)
IS
   -- Check if there is no row for business user in pv_ge_ptnr_resps but there are business users
   CURSOR c_is_business_user_exist IS
      SELECT 1
      FROM   dual
      WHERE  EXISTS (
             SELECT 1
             FROM   pv_partner_business_users_v
             WHERE  partner_id = p_from_partner_id);

   CURSOR c_is_business_resp_exist IS
      SELECT  1
      FROM    pv_ge_ptnr_resps
      WHERE   partner_id = p_to_partner_id
      and     user_role_code = 'BUSINESS';

   CURSOR c_get_program_id IS
      SELECT program_id, partner_id
      FROM   pv_pg_memberships
      WHERE  partner_id = p_to_partner_id
      AND    membership_status_code = 'ACTIVE';

   CURSOR c_get_to_resp_info IS
      SELECT     responsibility_id, user_role_code
      FROM       pv_ge_ptnr_resps
      WHERE      partner_id = p_to_partner_id;

   l_api_name                  CONSTANT  VARCHAR2(30) := 'manage_merged_party_memb_resp';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_exist                     NUMBER;
   l_last_program_id           NUMBER := 0;
   l_user_ids_tbl              JTF_NUMBER_TABLE;
   l_resp_exist                VARCHAR(1) := 'N';
   l_responsibility_id         NUMBER;
   l_resp_map_rule_id          NUMBER;
   l_ge_ptnr_resps_rec         PV_Ge_Ptnr_Resps_PVT.ge_ptnr_resps_rec_type;
   l_ptnr_resp_id              NUMBER;

BEGIN
  ---- Initialize----------------

   -- Standard Start of API savepoint
   SAVEPOINT manage_merged_party_memb_resp;

   -- Standard call to check for call compatibility.
   IF NOT Fnd_Api.Compatible_API_Call (l_api_version_number
                                      ,p_api_version_number
                                      ,l_api_name
                                      ,G_PKG_NAME
                                      )
   THEN
       RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF Fnd_Api.to_Boolean( p_init_msg_list )
   THEN
      Fnd_Msg_Pub.initialize;
   END IF;

   -- Debug Message
   Debug_Log('PRIVATE API: ' || l_api_name || ' - START');

   -- Initialize API return status to SUCCESS
   x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

   g_log_to_file := 'Y';

   revoke_default_resp (
       p_api_version_number      => 1.0
      ,p_init_msg_list           => FND_API.G_FALSE
      ,p_commit                  => FND_API.G_FALSE
      ,x_return_status           => x_return_status
      ,x_msg_count               => x_msg_count
      ,x_msg_data                => x_msg_data
      ,p_partner_id              => p_from_partner_id
   );
   IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   FOR a IN c_is_business_user_exist LOOP
      Debug_Log('manage_merged_party_memb_resp: start to create resp for business users');

      OPEN c_is_business_resp_exist;
      FETCH c_is_business_resp_exist INTO l_exist;
      -- If there is no row for business user responsibility,
      -- get the correct resp and insert into pv_ge_ptnr_resps
      IF (c_is_business_resp_exist%NOTFOUND) THEN
         Debug_Log('manage_ter_exp_memb_resp: c_is_business_resp_exist%NOTFOUND');

         FOR x IN c_get_program_id LOOP
            l_responsibility_id := null;
            l_resp_map_rule_id := null;
            get_program_resp(
                p_api_version_number         => p_api_version_number
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,x_return_status              => x_return_status
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
               ,p_partner_id                 => x.partner_id
               ,p_user_role_code             => 'BUSINESS'
               ,p_program_id                 => x.program_id
               ,x_responsibility_id          => l_responsibility_id
               ,x_resp_map_rule_id           => l_resp_map_rule_id
            );

            Debug_Log('manage_merged_party_memb_resp: l_responsibility_id = ' || l_responsibility_id);
            Debug_Log('manage_merged_party_memb_resp: l_resp_map_rule_id = ' || l_resp_map_rule_id);

            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;

            IF (l_responsibility_id is not null) and (l_resp_map_rule_id is not null) THEN
               l_resp_exist := 'Y';
               /****
                * API to add a row to pv_ge_ptnr_resps
                ****/
               l_ge_ptnr_resps_rec.partner_id := x.partner_id;
               l_ge_ptnr_resps_rec.user_role_code := 'BUSINESS';
               l_ge_ptnr_resps_rec.program_id := x.program_id;
               l_ge_ptnr_resps_rec.responsibility_id := l_responsibility_id;
               l_ge_ptnr_resps_rec.source_resp_map_rule_id := l_resp_map_rule_id;
               l_ge_ptnr_resps_rec.resp_type_code := G_PROGRAM;

               Debug_Log('manage_merged_party_memb_resp: l_ge_ptnr_resps_rec.partner_id = ' || l_ge_ptnr_resps_rec.partner_id);
               Debug_Log('manage_merged_party_memb_resp: l_ge_ptnr_resps_rec.user_role_code = ' || l_ge_ptnr_resps_rec.user_role_code);
               Debug_Log('manage_merged_party_memb_resp: l_ge_ptnr_resps_rec.program_id = ' || l_ge_ptnr_resps_rec.program_id);
               Debug_Log('manage_merged_party_memb_resp: l_ge_ptnr_resps_rec.responsibility_id = ' || l_ge_ptnr_resps_rec.responsibility_id);
               Debug_Log('manage_merged_party_memb_resp: l_ge_ptnr_resps_rec.source_resp_map_rule_id = ' || l_ge_ptnr_resps_rec.source_resp_map_rule_id);
               Debug_Log('manage_merged_party_memb_resp: l_ge_ptnr_resps_rec.resp_type_code = ' || l_ge_ptnr_resps_rec.resp_type_code);

               PV_Ge_Ptnr_Resps_PVT.Create_Ge_Ptnr_Resps(
                   p_api_version_number         => p_api_version_number
                  ,p_init_msg_list              => FND_API.G_FALSE
                  ,p_commit                     => FND_API.G_FALSE
                  ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL

                  ,x_return_status              => x_return_status
                  ,x_msg_count                  => x_msg_count
                  ,x_msg_data                   => x_msg_data
                  ,p_ge_ptnr_resps_rec          => l_ge_ptnr_resps_rec
                  ,x_ptnr_resp_id               => l_ptnr_resp_id
               );
               IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
               END IF;
            END IF; -- End of IF (l_responsibility_id is not null) and (l_resp_map_rule_id is not null)
         END LOOP; -- End of FOR c_get_program_id LOOP

         IF (l_resp_exist = 'N') THEN
            get_default_resp(
                p_api_version_number         => p_api_version_number
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,x_return_status              => x_return_status
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
               ,p_partner_id                 => p_to_partner_id
               ,p_user_role_code             => 'BUSINESS'
               ,x_responsibility_id          => l_responsibility_id
               ,x_resp_map_rule_id           => l_resp_map_rule_id
            );
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
            IF (l_responsibility_id is not null) and (l_resp_map_rule_id is not null) THEN
               /****
                * API to add a row to pv_ge_ptnr_resps
                ****/
               l_ge_ptnr_resps_rec.partner_id := p_to_partner_id;
               l_ge_ptnr_resps_rec.user_role_code := 'BUSINESS';
               l_ge_ptnr_resps_rec.responsibility_id := l_responsibility_id;
               l_ge_ptnr_resps_rec.source_resp_map_rule_id := l_resp_map_rule_id;
               l_ge_ptnr_resps_rec.resp_type_code := G_PROGRAM;

               Debug_Log('manage_merged_party_memb_resp: l_ge_ptnr_resps_rec.partner_id = ' || l_ge_ptnr_resps_rec.partner_id);
               Debug_Log('manage_merged_party_memb_resp: l_ge_ptnr_resps_rec.user_role_code = ' || l_ge_ptnr_resps_rec.user_role_code);
               Debug_Log('manage_merged_party_memb_resp: l_ge_ptnr_resps_rec.responsibility_id = ' || l_ge_ptnr_resps_rec.responsibility_id);
               Debug_Log('manage_merged_party_memb_resp: l_ge_ptnr_resps_rec.source_resp_map_rule_id = ' || l_ge_ptnr_resps_rec.source_resp_map_rule_id);
               Debug_Log('manage_merged_party_memb_resp: l_ge_ptnr_resps_rec.resp_type_code = ' || l_ge_ptnr_resps_rec.resp_type_code);

               PV_Ge_Ptnr_Resps_PVT.Create_Ge_Ptnr_Resps(
                   p_api_version_number         => p_api_version_number
                  ,p_init_msg_list              => FND_API.G_FALSE
                  ,p_commit                     => FND_API.G_FALSE
                  ,p_validation_level           => FND_API.G_VALID_LEVEL_FULL

                  ,x_return_status              => x_return_status
                  ,x_msg_count                  => x_msg_count
                  ,x_msg_data                   => x_msg_data
                  ,p_ge_ptnr_resps_rec          => l_ge_ptnr_resps_rec
                  ,x_ptnr_resp_id               => l_ptnr_resp_id
               );
               IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
               END IF;
            ELSE
               FND_MESSAGE.set_name('PV', 'PV_NO_DEFAULT_RESP');
               FND_MSG_PUB.add;
               RAISE FND_API.G_EXC_ERROR;
            END IF; -- End of IF (l_responsibility_id is not null) and (l_resp_map_rule_id is not null)
         END IF; -- End of IF (l_resp_exist = 'N')
      END IF; -- End of IF (c_is_business_user_exist%NOTFOUND)
      CLOSE c_is_business_resp_exist;
   END LOOP; -- End of c_is_business_user_exist

   FOR x IN c_get_to_resp_info LOOP
      Debug_Log('manage_merged_party_memb_resp: x.responsibility_id: ' || x.responsibility_id);
      -- PRIMARY users
      IF (x.user_role_code = 'PRIMARY') THEN
         Debug_Log('manage_merged_party_memb_resp: PRIMARY');

         l_user_ids_tbl := get_partner_users(p_from_partner_id, x.user_role_code);
         FOR l_u_cnt IN 1..l_user_ids_tbl.count LOOP
            assign_resp (
                p_api_version_number         => p_api_version_number
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,p_user_id                    => l_user_ids_tbl(l_u_cnt)
               ,p_resp_id                    => x.responsibility_id
               ,p_app_id                     => 691
               ,x_return_status              => x_return_status
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
            );
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END LOOP;
      ELSIF (x.user_role_code = 'BUSINESS') THEN
         Debug_Log('manage_merged_party_memb_resp: BUSINESS');

         l_user_ids_tbl := get_partner_users(p_from_partner_id, x.user_role_code);
         FOR l_u_cnt IN 1..l_user_ids_tbl.count LOOP
            assign_resp (
                p_api_version_number         => p_api_version_number
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,p_user_id                    => l_user_ids_tbl(l_u_cnt)
               ,p_resp_id                    => x.responsibility_id
               ,p_app_id                     => 691
               ,x_return_status              => x_return_status
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
            );
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END LOOP;
      ELSIF (x.user_role_code = 'ALL') THEN
         Debug_Log('manage_merged_party_memb_resp: ALL');
         l_user_ids_tbl := get_partner_users(p_from_partner_id, x.user_role_code);
         FOR l_u_cnt IN 1..l_user_ids_tbl.count LOOP
            assign_resp (
                p_api_version_number         => p_api_version_number
               ,p_init_msg_list              => FND_API.G_FALSE
               ,p_commit                     => FND_API.G_FALSE
               ,p_user_id                    => l_user_ids_tbl(l_u_cnt)
               ,p_resp_id                    => x.responsibility_id
               ,p_app_id                     => 671
               ,x_return_status              => x_return_status
               ,x_msg_count                  => x_msg_count
               ,x_msg_data                   => x_msg_data
            );
            IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
            END IF;
         END LOOP;
      END IF;
   END LOOP;

   -- Check for commit
   IF FND_API.to_boolean(p_commit) THEN
      COMMIT;
   END IF;

   FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
     ,p_count   => x_msg_count
     ,p_data    => x_msg_data
   );

EXCEPTION

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO manage_merged_party_memb_resp;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO manage_merged_party_memb_resp;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO manage_merged_party_memb_resp;
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

END manage_merged_party_memb_resp;

END Pv_User_Resp_Pvt;

/
