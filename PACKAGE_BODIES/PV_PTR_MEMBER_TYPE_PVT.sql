--------------------------------------------------------
--  DDL for Package Body PV_PTR_MEMBER_TYPE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PTR_MEMBER_TYPE_PVT" as
/* $Header: pvxvmtcb.pls 120.3 2005/08/31 17:27:24 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--    Pv_ptr_member_type_pvt
-- Purpose
--    to handle member type related functionality
-- History  10-SEP-2003 pukken created
--          16-FEB-2004 pukken fixed bug 3439734
--          29-APRIL-2004 pukken fix bug 3597966
--          31-AUG-2005 ktsao fix bug 4534894


G_PKG_NAME  CONSTANT VARCHAR2(30) := 'Pv_ptr_member_type_pvt';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvmtcb.pls';

PV_DEBUG_HIGH_ON   CONSTANT boolean   := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON    CONSTANT boolean   := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean   := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);
g_log_level     CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;

G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

-- validate whether the partner is having member type 'GLOBAL'
-- IN .. partner_id of the global partner from pv_partner_profiles table

FUNCTION is_global_valid
( p_global_partner_id  IN  NUMBER
)RETURN VARCHAR2
IS

   cursor is_global_cur(p_ptr_id NUMBER) IS
   SELECT decode ( attr_value,'GLOBAL','Y','N')
   FROM   pv_enty_attr_values
   WHERE  entity='PARTNER'
   AND    entity_id=p_ptr_id
   AND    attribute_id=6
   AND    latest_flag='Y';
   l_is_global varchar2(1) := 'N';

BEGIN
   OPEN is_global_cur( p_global_partner_id );
      FETCH  is_global_cur INTO l_is_global;
   CLOSE is_global_cur;

   return l_is_global;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
        return ('N');
END is_global_valid;  --validate whether the partner is having member type 'GLOBAL'



FUNCTION isRecordExists
( p_sub_partner_id  IN  NUMBER --subsidiary partner id
)RETURN VARCHAR2
IS

   cursor is_global_cur(p_ptr_id NUMBER) IS
   SELECT   'Y'
   FROM     hz_relationships rel
            , pv_partner_profiles prof
   WHERE    rel.status='A'
   AND      prof.partner_id=p_ptr_id
   AND      relationship_type = 'PARTNER_HIERARCHY'
   AND      rel.subject_id = prof.partner_party_id
   AND      rel.relationship_code = 'SUBSIDIARY_OF'
   AND      rel.start_date <= SYSDATE
   AND     ( rel.end_date is null or rel.end_date>=sysdate);

   l_is_exists varchar2(1) := 'N';

BEGIN
   OPEN is_global_cur( p_sub_partner_id );
      FETCH  is_global_cur INTO l_is_exists;
   CLOSE is_global_cur;
   return l_is_exists;
EXCEPTION
   WHEN NO_DATA_FOUND THEN
        return ('N');
END;  --validate whether the partner is having member type 'GLOBAL'

PROCEDURE validate_member_type
(
   p_member_type   VARCHAR2
   ,x_return_status OUT  NOCOPY VARCHAR2
)IS

   l_value VARCHAR2(1);
   CURSOR memb_csr( attr_cd VARCHAR2 ) IS
   SELECT 'X'
   FROM   PV_ATTRIBUTE_CODES_VL
   WHERE  ATTRIBUTE_ID = 6
   AND    ENABLED_FLAG = 'Y'
   AND    ATTR_CODE =attr_cd;

BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   OPEN  memb_csr( p_member_type );
      FETCH memb_csr INTO l_value;
   CLOSE memb_csr;
   IF l_value IS NULL THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MESSAGE.set_name('PV', 'PV_INVALID_MEMBER_TYPE');
      FND_MESSAGE.set_token('MEMBER_TYPE',p_member_type );
      FND_MSG_PUB.add;
   END IF;

END validate_member_type;

PROCEDURE validate_Lookup(
    p_lookup_type    IN   VARCHAR2
    ,p_lookup_code   IN   VARCHAR2
    ,x_return_status OUT  NOCOPY VARCHAR2
)
IS
   l_lookup_exists  VARCHAR2(1);
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   --validate lookup
   l_lookup_exists := PVX_UTILITY_PVT.check_lookup_exists
                      (   p_lookup_table_name => 'PV_LOOKUPS'
                         ,p_lookup_type => p_lookup_type
                         ,p_lookup_code => p_lookup_code
                       );
   IF NOT FND_API.to_boolean(l_lookup_exists) THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MESSAGE.set_name('PV', 'PV_INVALID_LOOKUP_CODE');
      FND_MESSAGE.set_token('LOOKUP_TYPE',p_lookup_type );
      FND_MESSAGE.set_token('LOOKUP_CODE', p_lookup_code  );
      FND_MSG_PUB.add;
   END IF;

END validate_Lookup;



FUNCTION logging_enabled (p_log_level IN NUMBER)
  RETURN BOOLEAN
IS
BEGIN
  RETURN (p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL);
END;

PROCEDURE debug_message
(
   p_log_level IN NUMBER
   , p_module_name    IN VARCHAR2
   , p_text   IN VARCHAR2
)
IS
BEGIN

--  IF logging_enabled (p_log_level) THEN
  IF (p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING(p_log_level, p_module_name, p_text);
  END IF;

END debug_message;

PROCEDURE WRITE_LOG
(
   p_api_name      IN VARCHAR2
   , p_log_message   IN VARCHAR2
)
IS



BEGIN
  debug_message
   (
      p_log_level   => g_log_level
      , p_module_name => 'plsql.pv'||'.'|| g_pkg_name||'.'||p_api_name||'.'||p_log_message
      , p_text => p_log_message
   );
END WRITE_LOG;

--======================





PROCEDURE validate_partner_id(
    p_partner_id     IN   NUMBER
    ,x_return_status OUT  NOCOPY VARCHAR2
)
IS

   l_is_valid  VARCHAR2(1):=null;
   CURSOR is_partner_cur(ptr_id NUMBER) IS
   SELECT 'Y'
   FROM   pv_partner_profiles
   WHERE  partner_id=ptr_id
   AND    STATUS='A';

BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   --validate lookup
   IF p_partner_id is NULL THEN
   	l_is_valid :='N';
   ELSE
      OPEN is_partner_cur(p_partner_id);
         FETCH is_partner_cur INTO l_is_valid;
      CLOSE is_partner_cur;
      IF l_is_valid is NULL THEN
         l_is_valid:='N';
      END IF;
   END IF;
   IF l_is_valid='N' THEN
         x_return_status := FND_API.g_ret_sts_error;
         FND_MESSAGE.set_name('PV', 'PV_NO_PARTNER_ID');
         FND_MESSAGE.set_token('ID',p_partner_id );
         FND_MSG_PUB.add;
   END IF;
END validate_partner_id;

--------------------------------------------
   -- PROCEDURE
   --   Register_term_ptr_memb_type
   --
   -- PURPOSE
   --   This api can register as well as terminate member type and its corresponding relationships
   -- IN
   --   partner_id   IN  NUMBER.
   --     for which member type is getting registered/terminated - either created/updated
   --   p_current_memb_type.IN  VARCHAR2 DEFAULT NULL
   --     The existing member type stored in the db. if its not passed, we will query and get it
   --   p_new_memb_type IN  VARCHAR2.
   --     pass GLOBAL,SUBSIDIARY or STANDARD if you want to register a new member type(also validated).
   --     if you want to terminate the relationship pass null.
   --   p_global_ptr_id. IN  NUMBER DEFAULT NULL
   --     if the new member type is  SUBSIDIARY, pass the global's partner id from pv_partner_profiles table
   --     this is validated only if the new member type is  SUBSIDIARY

   -- HISTORY
   --   15-SEP-2003        pukken        CREATION
   --------------------------------------------------------------------------
PROCEDURE Register_term_ptr_memb_type
(
    p_api_version_number  IN  NUMBER
   ,p_init_msg_list       IN  VARCHAR2 := FND_API.G_FALSE
   ,p_commit              IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level    IN  NUMBER   :=  FND_API.G_VALID_LEVEL_FULL
   ,p_partner_id          IN  NUMBER
   ,p_current_memb_type   IN  VARCHAR2 DEFAULT NULL
   ,p_new_memb_type       IN  VARCHAR2
   ,p_global_ptr_id	  IN  NUMBER   DEFAULT NULL
   ,x_return_status       OUT NOCOPY VARCHAR2
   ,x_msg_count           OUT NOCOPY NUMBER
   ,x_msg_data            OUT NOCOPY VARCHAR2
) IS

   CURSOR memb_type_cur( p_ptr_id NUMBER)  IS
   SELECT attr_value,version
   FROM   pv_enty_attr_values
   WHERE  entity='PARTNER'
   AND    entity_id=p_ptr_id
   AND    attribute_id=6
   AND    latest_flag='Y';

   CURSOR attr_version_cur( p_ptr_id NUMBER)  IS
   SELECT version
   FROM   pv_enty_attr_values
   WHERE  entity='PARTNER'
   AND    entity_id=p_ptr_id
   AND    attribute_id=6
   AND    latest_flag='Y';

   CURSOR c_partner_party_id_cur (  p_ptr_id NUMBER )  IS
   SELECT partner_party_id
   FROM   pv_partner_profiles
   WHERE  partner_id=p_ptr_id;

   --to get all the subsidiaries of the given global partner
   CURSOR sub_cur( p_ptr_id NUMBER) IS
   SELECT   subs_prof.partner_id
          , subs_prof.partner_party_id
          , subs_enty_val.version
          , rel.relationship_id
          , rel.object_version_number
          , rel.status
          , rel.start_date
   FROM    pv_partner_profiles subs_prof
          , pv_partner_profiles global_prof
          , pv_enty_attr_values  subs_enty_val
          , hz_relationships rel
   WHERE
   global_prof.partner_id = p_ptr_id
   AND global_prof.partner_party_id = rel.subject_id
   AND rel.relationship_type = 'PARTNER_HIERARCHY'
   AND rel.object_id = subs_prof.partner_party_id
   AND rel.relationship_code = 'PARENT_OF'
   AND rel.status = 'A'
   AND NVL(rel.start_date, SYSDATE) <= SYSDATE
   AND NVL(rel.end_date, SYSDATE) >= SYSDATE
   AND subs_enty_val.entity = 'PARTNER'
   AND subs_enty_val.entity_id = subs_prof.partner_id
   AND subs_enty_val.attribute_id = 6
   AND subs_enty_val.latest_flag = 'Y'
   AND subs_enty_val.attr_value = 'SUBSIDIARY';

   /*
   --to fix sql id 12266928 11.5.10 cu1 , below just befoe the cursor sub_cur is opened,
   --the current memeb type is already queried and hence it need not be querioed again
   --and thats the change done in the above SQL.
   SELECT   subs_prof.partner_id
          , subs_prof.partner_party_id
          , subs_enty_val.version
          , rel.relationship_id
          , rel.object_version_number
          , rel.status
          , rel.start_date
   FROM    pv_partner_profiles subs_prof
          , pv_partner_profiles global_prof
          , pv_enty_attr_values  subs_enty_val
          , pv_enty_attr_values   global_enty_val
          , hz_relationships rel
   WHERE global_enty_val.entity = 'PARTNER'
   AND global_enty_val.entity_id = global_prof.partner_id
   AND global_enty_val.attribute_id = 6
   AND global_enty_val.latest_flag = 'Y'
   AND global_enty_val.attr_value = 'GLOBAL'
   AND global_prof.partner_id = p_ptr_id
   AND global_prof.partner_party_id = rel.subject_id
   AND rel.relationship_type = 'PARTNER_HIERARCHY'
   AND rel.object_id = subs_prof.partner_party_id
   AND rel.relationship_code = 'PARENT_OF'
   AND rel.status = 'A'
   AND NVL(rel.start_date, SYSDATE) <= SYSDATE
   AND NVL(rel.end_date, SYSDATE) >= SYSDATE
   AND subs_enty_val.entity = 'PARTNER'
   AND subs_enty_val.entity_id = subs_prof.partner_id
   AND subs_enty_val.attribute_id = 6
   AND subs_enty_val.latest_flag = 'Y'
   AND subs_enty_val.attr_value = 'SUBSIDIARY';
   */

   --given the subsidiary partner id, get the corresponding relationship id with its global partner
   CURSOR rel_cur (p_subs_ptr_id NUMBER ) IS
   SELECT   rel.relationship_id relationship_id
          , rel.start_date
          , rel.object_version_number object_version_number
          , subs_prof.partner_party_id partner_party_id
   FROM     pv_partner_profiles subs_prof
          , hz_relationships rel
   WHERE  rel.subject_id=subs_prof.partner_party_id
   AND    rel.relationship_code = 'SUBSIDIARY_OF'
   AND    rel.relationship_type = 'PARTNER_HIERARCHY'
   AND    rel.status = 'A'
   AND    NVL(rel.start_date, SYSDATE) <= SYSDATE
   AND    NVL(rel.end_date, SYSDATE) >= SYSDATE
   AND    subs_prof.partner_id=p_subs_ptr_id;

   /*
   --to fix sql id 12266947 in 11.5.10 cu1  , below just befoe the cursor sub_cur is opened,
   --the current memeb type is already queried and hence it need not be querioed again
   --and thats the change done in the above SQL.
   SELECT   rel.relationship_id relationship_id
          , rel.start_date
          , rel.object_version_number object_version_number
          , subs_prof.partner_party_id partner_party_id
          , subs_enty_val.version version
   FROM     pv_partner_profiles subs_prof
          , pv_enty_attr_values  subs_enty_val
          , hz_relationships rel
   WHERE  rel.subject_id=subs_prof.partner_party_id
   AND    rel.relationship_code = 'SUBSIDIARY_OF'
   AND    rel.relationship_type = 'PARTNER_HIERARCHY'
   AND    rel.status = 'A'
   AND    NVL(rel.start_date, SYSDATE) <= SYSDATE
   AND    NVL(rel.end_date, SYSDATE) >= SYSDATE
   AND    subs_prof.partner_id=p_subs_ptr_id
   AND    subs_enty_val.entity = 'PARTNER'
   AND    subs_enty_val.entity_id = p_subs_ptr_id
   AND    subs_enty_val.attribute_id = 6
   AND    subs_enty_val.latest_flag = 'Y'
   AND    subs_enty_val.attr_value = 'SUBSIDIARY';
   */

   CURSOR party_cur(p_ptnr_party_id NUMBER)  IS
   SELECT object_version_number
   FROM   hz_parties
   WHERE  party_id=p_ptnr_party_id;

   CURSOR get_memb_csr ( attr_cd IN VARCHAR2 ) IS
   SELECT  DESCRIPTION
   FROM    PV_ATTRIBUTE_CODES_VL
   WHERE   ATTRIBUTE_ID = 6
   AND     ENABLED_FLAG = 'Y'
   AND     ATTR_CODE =attr_cd;

   CURSOR get_party_csr( p_partner_id IN NUMBER ) IS
   SELECT party_name
   FROM   hz_parties party
          ,pv_partner_profiles prof
   WHERE  prof.partner_id=p_partner_id
   AND    prof.partner_party_id=party.party_id;

   l_api_name                CONSTANT VARCHAR2(30) := 'Register_term_ptr_memb_type';
   l_relationship_rec        HZ_RELATIONSHIP_V2PUB.relationship_rec_type;
   l_current_memb_type       VARCHAR2(30):=null;
   l_partner_party_id        NUMBER;
   l_global_partner_party_id NUMBER;
   l_version                 NUMBER:=null;
   l_party_obj_ver_number    NUMBER;
   l_attr_value_tbl_type     PV_ENTY_ATTR_VALUE_PUB.attr_value_tbl_type;
   l_relationship_id         NUMBER;
   l_object_version_number   NUMBER;
   l_api_version_number      CONSTANT NUMBER   := 1.0;
   l_isGlobalValid           VARCHAR2(1):='N';
   l_memb_rel_id             NUMBER;
   l_memb_party_id           NUMBER;
   l_memb_party_number       VARCHAR2(100);
   l_check_status            VARCHAR2(1) :='N';
   l_start_date              DATE;
   l_from_memb_type          VARCHAR2(30);
   l_to_memb_type            VARCHAR2(30);
   l_param_tbl_var           PVX_UTILITY_PVT.log_params_tbl_type;
   l_param_tbl_var1          PVX_UTILITY_PVT.log_params_tbl_type;
   l_party_name              VARCHAR2(360)  ;
BEGIN
   -- Standard Start of API savepoint
  SAVEPOINT Register_term_ptr_memb_type;
  -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
   (    l_api_version_number
       ,p_api_version_number
       ,l_api_name
       ,G_PKG_NAME
   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF ;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )  THEN
      FND_MSG_PUB.initialize;
   END IF;
   -- Debug Message

   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Validate Environment
   IF FND_GLOBAL.USER_ID IS NULL   THEN
      PVX_UTILITY_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- find out the existing the member type if its not passed in.. If its passed , validate it
   IF p_current_memb_type is NULL THEN
          OPEN memb_type_cur(p_partner_id);
             FETCH memb_type_cur INTO l_current_memb_type,l_version;
          CLOSE   memb_type_cur;
   ELSE
      --VALIDATE the passed in member type value thats passed in
      /*validate_Lookup
      (
         p_lookup_type    => 'PV_MEMBER_TYPE_CODE'
         ,p_lookup_code   => p_current_memb_type
         ,x_return_status => x_return_status
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      */
      Validate_member_type
      (
         p_member_type   => p_current_memb_type
         ,x_return_status => x_return_status
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      l_current_memb_type:=p_current_memb_type;
   END IF;

   -- get the attribute value version number for the member type
   OPEN attr_version_cur(p_partner_id);
      FETCH attr_version_cur INTO l_version;
   CLOSE   attr_version_cur;

   --check the new member type value.. if its null, then it means we need to terminate the membership
   IF p_new_memb_type is NULL THEN
      --check the existing the membership type and perform actions accordingly

      IF l_current_memb_type='GLOBAL'  THEN
         --first get all its subsidiariess and terminate the relationship between subsidiaries and global
         --for all these subsidiaries, update the profile attribute value to STANDARD
         --finally update the globals profile attribute value to STANDARD.
         FOR subs in sub_cur(p_partner_id) LOOP
            l_relationship_rec.relationship_id := subs.relationship_id;
            l_relationship_rec.status:= 'I';
            --l_relationship_rec.start_date := to_date(subs.start_date,'DD-MM-YYYY HH24:MI:SS');
            --reduce the end date by 10 seconds from sysdate.the reason is when the subsidiary'd
            -- global chnages to a global ,we need to create a new relationship in the same transaction
            -- and since multiple parents are not allowed, sometimes it will fail in TCA validation
            l_relationship_rec.end_date:= sysdate-10*1/24/60/60;
            l_party_obj_ver_number:=null;
            --terminate the relationship between the subsidiary and global

            HZ_RELATIONSHIP_V2PUB.update_relationship
            (
               p_init_msg_list                  => FND_API.g_false
               ,p_relationship_rec              => l_relationship_rec
               ,p_object_version_number         => subs.object_version_number
               ,p_party_object_version_number   => l_party_obj_ver_number
               ,x_return_status                 => x_return_status
               ,x_msg_count                     => x_msg_count
               ,x_msg_data                      => x_msg_data
            );
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
            --update the attribute value to STANDARD
            l_attr_value_tbl_type(1).attr_value:='STANDARD';
            PV_ENTY_ATTR_VALUE_PUB.Upsert_Attr_Value
            (
               p_api_version_number    => 1.0
               ,p_init_msg_list        => FND_API.g_false
               ,p_commit               => FND_API.g_false
               ,p_validation_level     => FND_API.g_valid_level_full
               ,x_return_status        => x_return_status
               ,x_msg_count            => x_msg_count
               ,x_msg_data             => x_msg_data
               ,p_attribute_id	       => 6
               ,p_entity               => 'PARTNER'
               ,p_entity_id	       => subs.partner_id
               ,p_version              => subs.version
               ,p_attr_val_tbl         => l_attr_value_tbl_type
            );
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

            --send notification to the subsidiary partner that their member type changed
            PV_PG_NOTIF_UTILITY_PVT.Send_Workflow_Notification
            (
               p_api_version_number    => 1.0
               , p_init_msg_list       => FND_API.G_FALSE
               , p_commit              => FND_API.G_FALSE
               , p_validation_level    => FND_API.G_VALID_LEVEL_FULL
               , p_context_id          => p_partner_id -- context id is global partner_id when  change to memb type is subsidiary
               , p_context_code        => 'SUBSIDIARY'
               , p_target_ctgry        => 'PARTNER'
               , p_target_ctgry_pt_id  => subs.partner_id
               , p_notif_event_code    => 'GLOBAL_MEMBTYPE_CHANGE'
               , p_entity_id           =>  subs.partner_id
               , p_entity_code         => 'STANDARD'
               , p_wait_time           => 0
               , x_return_status       => x_return_status
               , x_msg_count           => x_msg_count
               , x_msg_data            => x_msg_data
            );

            --write to the subsdidiary's history log that the global partner's member type changed
            OPEN get_party_csr(p_partner_id) ;
               FETCH get_party_csr INTO l_party_name;
            CLOSE get_party_csr ;

            l_param_tbl_var1(1).param_name := 'PARTNER_NAME';
            l_param_tbl_var1(1).param_value := l_party_name;

            PVX_UTILITY_PVT.create_history_log
            (
               p_arc_history_for_entity_code   => 'GENERAL'
               , p_history_for_entity_id       => subs.partner_id
               , p_history_category_code       => 'PARTNER'
               , p_message_code                => 'PV_GLOBAL_MB_TYPE_CHANGE'
               , p_comments                    => null
               , p_partner_id                  => subs.partner_id
               , p_access_level_flag           => 'P'
               , p_interaction_level           => PVX_Utility_PVT.G_INTERACTION_LEVEL_50
               , p_log_params_tbl              => l_param_tbl_var1
               , p_init_msg_list               => FND_API.g_false
               , p_commit                      => FND_API.G_FALSE
               , x_return_status               => x_return_status
               , x_msg_count                   => x_msg_count
               , x_msg_data                    => x_msg_data
            );
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

             -- write to the subsidiary history log that membertype of the subsidiary changed to standard.
            OPEN get_memb_csr('SUBSIDIARY') ;
               FETCH get_memb_csr INTO l_from_memb_type;
            CLOSE get_memb_csr ;
            OPEN get_memb_csr('STANDARD') ;
               FETCH get_memb_csr INTO l_to_memb_type;
            CLOSE get_memb_csr ;

            l_param_tbl_var(1).param_name := 'FROM_MEMB_TYPE';
            l_param_tbl_var(1).param_value := l_from_memb_type;
            l_param_tbl_var(2).param_name := 'TO_MEMB_TYPE';
            l_param_tbl_var(2).param_value := l_to_memb_type ;

            PVX_UTILITY_PVT.create_history_log
            (
               p_arc_history_for_entity_code   => 'GENERAL'
               , p_history_for_entity_id       => subs.partner_id
               , p_history_category_code       => 'PARTNER'
               , p_message_code                => 'PV_MEMBER_TYPE_CHANGE'
               , p_comments                    => null
               , p_partner_id                  => subs.partner_id
               , p_access_level_flag           => 'P'
               , p_interaction_level           => PVX_Utility_PVT.G_INTERACTION_LEVEL_50
               , p_log_params_tbl              => l_param_tbl_var
               , p_init_msg_list               => FND_API.g_false
               , p_commit                      => FND_API.G_FALSE
               , x_return_status               => x_return_status
               , x_msg_count                   => x_msg_count
               , x_msg_data                    => x_msg_data
            );
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;


         END LOOP;
         --also update the globals profile attribute value to standard
         l_attr_value_tbl_type(1).attr_value:='STANDARD';
         PV_ENTY_ATTR_VALUE_PUB.Upsert_Attr_Value
         (
            p_api_version_number    => 1.0
            ,p_init_msg_list        => FND_API.g_false
            ,p_commit               => FND_API.g_false
            ,p_validation_level     => FND_API.g_valid_level_full
            ,x_return_status        => x_return_status
            ,x_msg_count            => x_msg_count
            ,x_msg_data             => x_msg_data
            ,p_attribute_id	    => 6
            ,p_entity               => 'PARTNER'
            ,p_entity_id	    => p_partner_id
           ,p_version               => l_version
           ,p_attr_val_tbl          => l_attr_value_tbl_type
         );
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
      ELSIF l_current_memb_type='SUBSIDIARY'  THEN

      	 --get the relationship_id
         OPEN rel_cur(p_partner_id);
            FETCH rel_cur INTO l_relationship_id,l_start_date,l_object_version_number,l_partner_party_id;
         CLOSE rel_cur;
         --terminate the relationship between this subsidiary and global
         l_relationship_rec.relationship_id := l_relationship_id;
         l_relationship_rec.status:= 'I';
         --l_relationship_rec.start_date := to_date(l_start_date,'DD-MM-YYYY HH24:MI:SS');
         --reduce the end date by 10 seconds from sysdate.the reason is when the subsidiary'd
         -- global chnages to a global ,we need to create a new relationship in the same transaction
         -- and since multiple parents are not allowed, sometimes it will fail in TCA validation
         l_relationship_rec.end_date:= sysdate-10*1/24/60/60; --reduce the end date by 10 seconds from sysdate
         l_party_obj_ver_number:=null;
         IF l_relationship_id IS NOT NULL THEN

            HZ_RELATIONSHIP_V2PUB.update_relationship
            (
               p_init_msg_list                  => FND_API.g_false
               ,p_relationship_rec              => l_relationship_rec
               ,p_object_version_number         => l_object_version_number
               ,p_party_object_version_number   => l_party_obj_ver_number
               ,x_return_status                 => x_return_status
               ,x_msg_count                     => x_msg_count
               ,x_msg_data                      => x_msg_data
            );
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;
         --also update the attr_value to STANDARD

         IF l_version is NULL THEN
            OPEN attr_version_cur(p_partner_id);
               FETCH attr_version_cur INTO l_version;
            CLOSE   attr_version_cur;
        END IF;

         l_attr_value_tbl_type(1).attr_value:='STANDARD';
         PV_ENTY_ATTR_VALUE_PUB.Upsert_Attr_Value
         (
            p_api_version_number    => 1.0
            ,p_init_msg_list        => FND_API.g_false
            ,p_commit               => FND_API.g_false
            ,p_validation_level     => FND_API.g_valid_level_full
            ,x_return_status        => x_return_status
            ,x_msg_count            => x_msg_count
            ,x_msg_data             => x_msg_data
            ,p_attribute_id	    => 6
            ,p_entity               => 'PARTNER'
            ,p_entity_id            => p_partner_id
            ,p_version              => l_version
            ,p_attr_val_tbl         => l_attr_value_tbl_type
         );

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

      END IF; --end of if else for l_current_memb_type

   ELSE
      --this code is executed when p_new_memb_type is anything other than null
      --VALIDATE the passed in new member type ( p_new_memb_type) value
      /*
      validate_Lookup
      (
         p_lookup_type    => 'PV_MEMBER_TYPE_CODE'
         ,p_lookup_code   => p_new_memb_type
         ,x_return_status => x_return_status
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      */

      Validate_member_type
      (
         p_member_type   => p_new_memb_type
         ,x_return_status => x_return_status
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      --update/insert the attributes table only if its null or the one in the db is not equal to the one thats passed in
      IF ( l_current_memb_type<>p_new_memb_type OR  l_current_memb_type IS NULL ) THEN
      	  --if the attribute val for this attribute is being created for the first time pass version as zero.
          IF l_version is NULL THEN
              l_version:=0;
          END IF;
          --update the attribute value
          l_attr_value_tbl_type(1).attr_value:=p_new_memb_type;

          PV_ENTY_ATTR_VALUE_PUB.Upsert_Attr_Value
          (
             p_api_version_number    => 1.0
             ,p_init_msg_list        => FND_API.g_false
             ,p_commit               => FND_API.g_false
             ,p_validation_level     => FND_API.g_valid_level_full
             ,x_return_status        => x_return_status
             ,x_msg_count            => x_msg_count
             ,x_msg_data             => x_msg_data
             ,p_attribute_id	    => 6
             ,p_entity               => 'PARTNER'
             ,p_entity_id	    => p_partner_id
             ,p_version              => l_version
             ,p_attr_val_tbl         => l_attr_value_tbl_type
          );
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;
          --only if the new memb type is SUBSIADIARY, you need to create a new relationship
          IF p_new_memb_type='SUBSIDIARY' THEN
             l_check_status := isRecordExists(p_partner_id);

             IF l_check_status = 'N' THEN
                --validate  the global partner id
                l_isGlobalValid := is_global_valid(p_global_ptr_id);

                IF l_isGlobalValid='Y' THEN

                  --get the subsidiary partner_party_id
                  OPEN c_partner_party_id_cur(p_partner_id);
                     FETCH c_partner_party_id_cur INTO l_partner_party_id;
                  CLOSE c_partner_party_id_cur;

                  --get the global partner_party_id
                  OPEN c_partner_party_id_cur(p_global_ptr_id);
                     FETCH c_partner_party_id_cur INTO l_global_partner_party_id;
                  CLOSE c_partner_party_id_cur;

                  -- create a new relationship in TCA for subsidiary global relationship
                  -- Initilize the l_relationship_rec with required values.
                  l_relationship_rec.subject_id := l_partner_party_id;--subsidiary party id
                  l_relationship_rec.subject_type := 'ORGANIZATION';
                  l_relationship_rec.subject_table_name := 'HZ_PARTIES';
                  l_relationship_rec.object_id := l_global_partner_party_id;  --global party id
                  l_relationship_rec.object_type := 'ORGANIZATION';
                  l_relationship_rec.object_table_name := 'HZ_PARTIES';
                  l_relationship_rec.relationship_code := 'SUBSIDIARY_OF';
                  l_relationship_rec.relationship_type := 'PARTNER_HIERARCHY';
                  l_relationship_rec.start_date := SYSDATE;
                  l_relationship_rec.created_by_module:= 'PV';
                  l_relationship_rec.application_id:= 691;
                  l_relationship_rec.status:= 'A';
                  -- Create the relationship.

                  HZ_RELATIONSHIP_V2PUB.create_relationship
                  (
                     p_init_msg_list       => FND_API.G_FALSE
                     ,p_relationship_rec   => l_relationship_rec
                     ,x_relationship_id    => l_memb_rel_id
                     ,x_party_id           => l_memb_party_id
                     ,x_party_number       => l_memb_party_number
                     ,x_return_status      => x_return_status
                     ,x_msg_count          => x_msg_count
                     ,x_msg_data           => x_msg_data
                     ,p_create_org_contact => 'N'
                  );

                  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                      RAISE FND_API.G_EXC_ERROR;
                  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;

                  PV_PG_NOTIF_UTILITY_PVT.Send_Workflow_Notification
                  (
                     p_api_version_number    => 1.0
                     , p_init_msg_list       => FND_API.G_FALSE
                     , p_commit              => FND_API.G_FALSE
                     , p_validation_level    => FND_API.G_VALID_LEVEL_FULL
                     , p_context_id          => p_partner_id-- partner id of the subsidiary partner
                     , p_context_code        => 'PARTNER'
                     , p_target_ctgry        => 'PARTNER'
                     , p_target_ctgry_pt_id  => p_global_ptr_id -- global partner_id
                     , p_notif_event_code    => 'SUBSIDIARY_PTNR_REGISTRATION'
                     , p_entity_id           => p_global_ptr_id
                     , p_entity_code         => 'PARTNER'
                     , p_wait_time           => 0
                     , x_return_status       => x_return_status
                     , x_msg_count           => x_msg_count
                     , x_msg_data            => x_msg_data
                  );


                  IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                      RAISE FND_API.G_EXC_ERROR;
                  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                  END IF;
               ELSE
                  --raise error if the global is invalid
                  FND_MESSAGE.set_name('PV', 'PV_GLOBAL_PARTNER_ID_INVALID');
                  FND_MSG_PUB.add;
                  RAISE FND_API.G_EXC_ERROR;
               END IF;-- global exists
            END IF; --end of iif to check whether the subsidiary already has an active relationship with a global
         END IF;--if new memb type is subsidiary
      END IF;--end of if , if the current member type and new member type are not equal
   END IF;    --if we terminating or creating

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
   END IF;

   IF FND_API.to_Boolean( p_commit )      THEN
      COMMIT WORK;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Register_term_ptr_memb_type;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
   );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Register_term_ptr_memb_type;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
   );

   WHEN OTHERS THEN
   ROLLBACK TO Register_term_ptr_memb_type;
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
END Register_term_ptr_memb_type;


---------------------------------------------

-- PROCEDURE
--   Pv_ptr_member_type_pvt.Process_ptr_member_type
--
-- PURPOSE
--   Change Membership Type.
-- IN
--   partner_id             IN NUMBER
--     partner_id for which member type is getting changed
--   p_chg_from_memb_type   IN  VARCHAR2 := NULL
--     if not given, will get from profile, should be 'SUBSIDIARY','GLOBAL','STANDARD'
--   p_chg_to_memb_type     IN  VARCHAR2
--     should be 'SUBSIDIARY','GLOBAL','STANDARD'
--   p_chg_to_global_ptr_id IN  NUMBER   DEFAULT NULL
--     if p_chg_to_memb_type is 'SUBSIDIARY', this needs to be passed for identifying the global partner_id for the subsidiary
-- USED BY
--   called from vendor facing UI when member type change is requested by partner
--
-- HISTORY
--   15-SEP-2003        pukken        CREATION
--------------------------------------------------------------------------
PROCEDURE Process_ptr_member_type
(
   p_api_version_number      IN  NUMBER
   , p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE
   , p_commit                IN  VARCHAR2 := FND_API.G_FALSE
   , p_validation_level      IN  NUMBER   :=  FND_API.G_VALID_LEVEL_FULL
   , p_partner_id            IN  NUMBER
   , p_chg_from_memb_type    IN  VARCHAR2 DEFAULT NULL
   , p_chg_to_memb_type      IN  VARCHAR2
   , p_chg_to_global_ptr_id  IN  NUMBER   DEFAULT NULL
   , x_return_status         OUT NOCOPY VARCHAR2
   , x_msg_count             OUT NOCOPY NUMBER
   , x_msg_data              OUT NOCOPY VARCHAR2
) IS

   CURSOR memb_type_cur( p_ptr_id NUMBER)  IS
   SELECT attr_value
   FROM   pv_enty_attr_values
   WHERE  entity='PARTNER'
   AND    entity_id=p_ptr_id
   AND    attribute_id=6
   AND    latest_flag='Y';

   l_current_memb_type         VARCHAR2(30);
   l_chg_from_memb_type        VARCHAR2(30);
   l_context_id                NUMBER;
   l_api_name                  CONSTANT VARCHAR2(30) := 'Process_ptr_member_type';
   l_api_version_number        CONSTANT NUMBER   := 1.0;

BEGIN
   /**
      a). Call register terminate API twice.
      once to terminate the existing relationship and update profile attribute value
      by passing p_new_membtype as null
      Call it again to create new relationship and update profile attributes
      by passing the p_new_membtype with the member type you want to tag the partner with
      the values would be STANDARD,GLOBAL,SUBSIDIARY.
      But if the partner is getting registered for the first time , you just need to call
      Register_term_ptr_memb_type once with p_new_membtype = to the member type.
      b). Terminate_ptr_memberships to terminate all the program memberships.
   */
   -- Standard Start of API savepoint
   SAVEPOINT Process_ptr_member_type;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
   (    l_api_version_number
       ,p_api_version_number
       ,l_api_name
       ,G_PKG_NAME
   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )  THEN
      FND_MSG_PUB.initialize;
   END IF;
   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Validate Environment
   IF FND_GLOBAL.USER_ID IS NULL   THEN
      PVX_UTILITY_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --terminate program memberships before terminating relationship
   PV_PG_MEMBERSHIPS_PVT.Terminate_ptr_memberships
   (
       p_api_version_number            => 1.0
      ,p_init_msg_list                 => FND_API.G_FALSE
      ,p_commit                        => FND_API.G_FALSE
      ,p_validation_level              => FND_API.G_VALID_LEVEL_FULL
      ,p_partner_id                    => p_partner_id
      ,p_memb_type                     => p_chg_from_memb_type
      ,p_status_reason_code            => 'MEMBER_TYPE_CHANGE' -- pass 'MEMBER_TYPE_CHANGE' if it is happening because of member type change -- it validates against PV_MEMB_STATUS_REASON_CODE
      ,p_comments                      => 'Membership terminated by system as member type is changed'
      ,x_return_status                 => x_return_status
      ,x_msg_count                     => x_msg_count
      ,x_msg_data                      => x_msg_data
   );
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Call register terminate API  with p_new_memb_type  as null
   l_chg_from_memb_type := p_chg_from_memb_type;
   IF l_chg_from_memb_type IS NULL THEN
      OPEN memb_type_cur( p_partner_id );
         FETCH memb_type_cur INTO l_chg_from_memb_type;
      CLOSE memb_type_cur;
   END IF;

   Register_term_ptr_memb_type
   (
      p_api_version_number            => 1.0
      ,p_init_msg_list                 => FND_API.G_FALSE
      ,p_commit                        => FND_API.G_FALSE
      ,p_validation_level              => FND_API.G_VALID_LEVEL_FULL
      ,p_partner_id                    => p_partner_id
      ,p_current_memb_type             => l_chg_from_memb_type
      ,p_new_memb_type                 => null
      ,p_global_ptr_id	               => null
      ,x_return_status                 => x_return_status
      ,x_msg_count                     => x_msg_count
      ,x_msg_data                      => x_msg_data
   );
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Call register terminate API  with p_new_memb_type  with the new member type
   -- since the p_chg_from_memb_type would have got changed by now because of the above call,
   -- i will query the database again and get the current member type again

   OPEN memb_type_cur(p_partner_id);
      FETCH memb_type_cur INTO l_current_memb_type;
   CLOSE memb_type_cur;

   IF ( l_current_memb_type<> p_chg_to_memb_type OR l_current_memb_type IS NULL ) THEN
      Register_term_ptr_memb_type
      (
          p_api_version_number            => 1.0
         ,p_init_msg_list                 => FND_API.G_FALSE
         ,p_commit                        => FND_API.G_FALSE
         ,p_validation_level              => FND_API.G_VALID_LEVEL_FULL
         ,p_partner_id                    => p_partner_id
         ,p_current_memb_type             => l_current_memb_type
         ,p_new_memb_type                 => p_chg_to_memb_type
         ,p_global_ptr_id	          => p_chg_to_global_ptr_id
         ,x_return_status                 => x_return_status
         ,x_msg_count                     => x_msg_count
         ,x_msg_data                      => x_msg_data
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;
   --also terminate all the program memberships


   IF p_chg_to_memb_type = 'SUBSIDIARY' THEN
      l_context_id   := p_chg_to_global_ptr_id;
   ELSE
      l_context_id   := p_partner_id;
   END IF;

   IF l_chg_from_memb_type IS NOT NULL AND p_chg_to_memb_type IS NOT NULL THEN
      PV_PG_NOTIF_UTILITY_PVT.Send_Workflow_Notification
      (
         p_api_version_number    => 1.0
         , p_init_msg_list       => FND_API.G_FALSE
         , p_commit              => FND_API.G_FALSE
         , p_validation_level    => FND_API.G_VALID_LEVEL_FULL
         , p_context_id          => l_context_id -- context id is global partner_id when  change to memb type is subsidiary
         , p_context_code        => l_chg_from_memb_type
         , p_target_ctgry        => 'PARTNER'
         , p_target_ctgry_pt_id  => p_partner_id
         , p_notif_event_code    => 'MEMBER_TYPE_CHANGE'
         , p_entity_id           => p_partner_id
         , p_entity_code         => p_chg_to_memb_type
         , p_wait_time           => 0
         , x_return_status       => x_return_status
         , x_msg_count           => x_msg_count
         , x_msg_data            => x_msg_data
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
   END IF;




   FND_MSG_PUB.Count_And_Get
   (
      p_count      =>   x_msg_count
      , p_data     =>   x_msg_data
   );
   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
   END IF;

   IF FND_API.to_Boolean( p_commit )      THEN
      COMMIT WORK;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Process_ptr_member_type;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
   );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO Process_ptr_member_type;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
   );

   WHEN OTHERS THEN
   ROLLBACK TO Process_ptr_member_type;
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
END Process_ptr_member_type;



FUNCTION validate_global_partner_orgzn
( p_global_prtnr_org_number  IN  VARCHAR2
)RETURN VARCHAR2
IS

   cursor cv_validate_global_orgzn(cv_orgzn_number VARCHAR2) IS
   select 1 from dual where exists
   (select 1 from  hz_parties hzp, pv_partner_profiles pvpp, pv_enty_attr_values pvev
   where hzp.party_number= cv_orgzn_number
   and hzp.party_id = pvpp.partner_party_id
   and pvpp.status = 'A'
   and pvpp.partner_id = pvev.entity_id
   and pvev.entity = 'PARTNER'
   and pvev.enabled_flag = 'Y'
   and pvev.latest_flag = 'Y'
   and pvev.attr_value = 'GLOBAL'
   and pvev.attribute_id = 6
   );

   l_is_global varchar2(1) := 'N';


BEGIN

     FOR x in cv_validate_global_orgzn(p_global_prtnr_org_number) loop
       l_is_global := 'Y';
       exit;
     end loop;

     return l_is_global;
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
        return ('N');
END;  --validate_global_partner_orgzn




FUNCTION get_global_partner_id
( p_global_prtnr_org_number  IN  VARCHAR2
) RETURN NUMBER
IS
   l_global_prtnr_id NUMBER := NULL ;

   cursor cv_get_global_prtnr_id(cv_orgzn_number VARCHAR2) IS
   select pvpp.partner_id from  hz_parties hzp, pv_partner_profiles pvpp, pv_enty_attr_values pvev
   where hzp.party_number= cv_orgzn_number
   and hzp.party_id = pvpp.partner_party_id
   and pvpp.status = 'A'
   and pvpp.partner_id = pvev.entity_id
   and pvev.entity = 'PARTNER'
   and pvev.enabled_flag = 'Y'
   and pvev.latest_flag = 'Y'
   and pvev.attr_value = 'GLOBAL';

BEGIN

    open cv_get_global_prtnr_id(p_global_prtnr_org_number);
    fetch cv_get_global_prtnr_id into l_global_prtnr_id;
    close cv_get_global_prtnr_id;


   RETURN(l_global_prtnr_id);
 EXCEPTION
   WHEN NO_DATA_FOUND THEN
        return (NULL);
END;  --get_global_partner_id




-- Function
--   terminate_partner
--
-- PURPOSE
--   this procedure is called for the subscription for the TCA business event
--   for relationship create or update
--   This would update the member type of the partner to the appropriate value
--   and would also terminate all program memberships
-- HISTORY
--   06-NOV-2003        pukken        CREATION
FUNCTION terminate_partner
(
   p_subscription_guid  IN RAW
   , p_event            IN OUT NOCOPY wf_event_t
)
RETURN VARCHAR2 IS

   l_key         VARCHAR2(240) := p_event.GetEventKey();
   l_api_name    CONSTANT VARCHAR2(30) := 'terminate_partner';
   id            NUMBER;
   l_count       NUMBER;
   l_partner_id  NUMBER;
   l_org_id      NUMBER;
   l_user_id     NUMBER;
   l_resp_id     NUMBER;
   l_old_status        VARCHAR2(1);
   l_new_status        VARCHAR2(1);
   l_attr_value_tbl_type     PV_ENTY_ATTR_VALUE_PUB.attr_value_tbl_type;
   l_version    NUMBER;
   l_memb_type  VARCHAR2(30);
   l_resp_appl_id          NUMBER;
   l_security_group_id     NUMBER;
   x_return_status         VARCHAR2(1);
   x_msg_count             NUMBER;
   x_msg_data              VARCHAR2(2000);
   l_status                VARCHAR2(1);
   l_subject_id            NUMBER;
   l_sub_flag              VARCHAR2(1);

   CURSOR rel_status ( id NUMBER) IS
   SELECT status
          , subject_id
   FROM   hz_relationships
   WHERE  relationship_id= id;

   CURSOR c_get_partner_id ( rel_id NUMBER ) IS
   SELECT partner_id

   FROM   pv_partner_profiles prof
	  , hz_relationships rel
	  , pv_enty_attr_values enty
   WHERE  rel.relationship_id = rel_id
   AND    rel.relationship_type= 'PARTNER_HIERARCHY'
   AND    rel.relationship_code= 'SUBSIDIARY_OF'
   AND    rel.subject_id=prof.partner_party_id
   AND    prof.partner_id=enty.entity_id
   AND    enty.attribute_id=6
   AND    enty.latest_flag='Y'
   AND    enty.attr_value='SUBSIDIARY';

   CURSOR c_get_sub_glob ( rel_id NUMBER ) IS
   SELECT sprof.partner_id subsidiary_partner_id
          , gprof.partner_id global_partner_id
          , enty.attr_value attr_value
   FROM   pv_partner_profiles sprof
          , pv_partner_profiles gprof
	  , hz_relationships rel
	  , pv_enty_attr_values enty
   WHERE  rel.relationship_id = rel_id
   AND   rel.relationship_type= 'PARTNER_HIERARCHY'
   AND   rel.relationship_code= 'SUBSIDIARY_OF'
   AND   rel.subject_id=sprof.partner_party_id
   AND   rel.object_id= gprof.partner_party_id
   AND   gprof.partner_id=enty.entity_id
   AND   enty.attribute_id=6
   AND   enty.latest_flag='Y' ;

   CURSOR attr_version_cur( p_ptr_id NUMBER)  IS
   SELECT version,attr_value
   FROM   pv_enty_attr_values
   WHERE  entity='PARTNER'
   AND    entity_id=p_ptr_id
   AND    attribute_id=6
   AND    latest_flag='Y';

BEGIN
   IF (PV_DEBUG_HIGH_ON) THEN
   WRITE_LOG
   (
      l_api_name
      , 'Entered the subscription pl/sql block Pv_ptr_member_type_pvt.terminate_partner()'
   );
   END IF;

   IF ( l_key like 'oracle.apps.ar.hz.Relationship.update%'  OR l_key like 'oracle.apps.ar.hz.Relationship.create%' ) THEN
      l_org_id := p_event.GetValueForParameter('ORG_ID');
      l_user_id := p_event.GetValueForParameter('USER_ID');
      l_resp_id := p_event.GetValueForParameter('RESP_ID');
      l_resp_appl_id := p_event.GetValueForParameter('RESP_APPL_ID');
      l_security_group_id := p_event.GetValueForParameter('SECURITY_GROUP_ID');
      id := p_event.getValueForParameter('RELATIONSHIP_ID');

      IF (PV_DEBUG_HIGH_ON) THEN
      WRITE_LOG
       (
          l_api_name
          , 'relationship id is  ' || id
      );
      END IF;
      fnd_global.apps_initialize
      (
         l_user_id
         , l_resp_id
         , l_resp_appl_id
         , l_security_group_id
      );

      --call register_terminate with new memb type = null;
      -- the logic should be
      -- check whether the relationship is inactive
      -- check whether the subsidiary has any other active global sub relationship.
      -- if not update the enty attr _value s table to STANDARD
      -- terminate all the subsidiary membersips that are because of the previous global.
      OPEN rel_status ( id );
         FETCH  rel_status  INTO l_status, l_subject_id;
      CLOSE rel_status;

      IF l_status= 'I'  THEN
         -- check whether the subsidiary has any other active global sub relationship.
         IF (PV_DEBUG_HIGH_ON) THEN
               WRITE_LOG
               (
                  l_api_name
                  , 'inside if , if status is still Inactive '
               );
         END IF;
         BEGIN
            SELECT 1 INTO l_count
            FROM   HZ_RELATIONSHIPS
            WHERE  SUBJECT_ID = l_subject_id -- subsidiary partner party id
            AND    OBJECT_TABLE_NAME = 'HZ_PARTIES'
            AND    OBJECT_TYPE = 'ORGANIZATION'
            AND    RELATIONSHIP_TYPE = 'PARTNER_HIERARCHY'
            AND    DIRECTION_CODE = 'C'
            AND    STATUS='A';
            -- there is already a parent, so set the flag
            l_sub_flag:= 'Y';
         EXCEPTION
             WHEN NO_DATA_FOUND THEN
                -- no other parent found, proceed
                l_sub_flag:= 'N';
         END;
         IF (PV_DEBUG_HIGH_ON) THEN
         WRITE_LOG
         (
            l_api_name
            , 'is global found found flag  '  || l_sub_flag
         );
         END IF;

         IF l_sub_flag = 'N' THEN
            FOR rec in c_get_partner_id( id ) LOOP
               -- call upsert api with value 'STANDARD' and terminate program memberships
               IF (PV_DEBUG_HIGH_ON) THEN
               WRITE_LOG
               (
                 l_api_name
                  , ' before calling register api'
               );
               END IF;
               OPEN attr_version_cur(rec.partner_id);
                 FETCH attr_version_cur INTO l_version,l_memb_type;
               CLOSE   attr_version_cur;
               IF l_memb_type <> 'STANDARD' THEN
                  l_attr_value_tbl_type(1).attr_value:='STANDARD';
                  PV_ENTY_ATTR_VALUE_PUB.Upsert_Attr_Value
                  (
                     p_api_version_number    => 1.0
                     ,p_init_msg_list        => FND_API.g_false
                     ,p_commit               => FND_API.g_false
                     ,p_validation_level     => FND_API.g_valid_level_full
                     ,x_return_status        => x_return_status
                     ,x_msg_count            => x_msg_count
                     ,x_msg_data             => x_msg_data
                     ,p_attribute_id	        => 6
                     ,p_entity               => 'PARTNER'
                     ,p_entity_id	        => rec.partner_id
                     ,p_version              => l_version
                     ,p_attr_val_tbl         => l_attr_value_tbl_type
                  );
                 IF (PV_DEBUG_HIGH_ON) THEN
                           WRITE_LOG
                           (
                              l_api_name
                              , 'after Register_term_ptr_memb_type call return status ' || x_return_status || 'msgdata' || x_msg_data
                           );
                 END IF;
               END IF;

               --call terminate ptr memberships api to terminate all program memberships
               PV_PG_MEMBERSHIPS_PVT.Terminate_ptr_memberships
               (
                 p_api_version_number            => 1.0
                 , p_init_msg_list                 => FND_API.G_FALSE
                 , p_commit                        => FND_API.G_FALSE
                 , p_validation_level              => FND_API.G_VALID_LEVEL_FULL
                 , p_partner_id                    => rec.partner_id
                 , p_memb_type                     => null
                 , p_status_reason_code            => 'PTR_INACTIVE'
                 , p_comments                      => null
                 , x_return_status                 => x_return_status
                 , x_msg_count                     => x_msg_count
                 , x_msg_data                      => x_msg_data
               );

              IF (PV_DEBUG_HIGH_ON) THEN
                        WRITE_LOG
                        (
                           l_api_name
                            , 'after Terminate_ptr_memberships call return status ' || x_return_status || 'msgdata' || x_msg_data
                        );
              END IF;
            END LOOP;
         END IF; -- end of if , l_sub_flag is N

     -- check whether relationship is still active
     -- check whether global partner is global, if not call change member type api to make it global
     -- then for the subsidiary , call upsert api to change the member type to subsidiary

      ELSIF l_status = 'A' THEN
         FOR rec in c_get_sub_glob( id ) LOOP
            IF rec.attr_value <> 'GLOBAL' THEN
               Process_ptr_member_type
               (
                  p_api_version_number              => 1.0
                  , p_init_msg_list                 => FND_API.G_FALSE
                  , p_commit                        => FND_API.G_FALSE
                  , p_validation_level              => FND_API.G_VALID_LEVEL_FULL
                  , p_partner_id                    => rec.global_partner_id
                  , p_chg_from_memb_type            => rec.attr_value
                  , p_chg_to_memb_type              => 'GLOBAL'
                  , p_chg_to_global_ptr_id          => null
                  , x_return_status                 => x_return_status
                  , x_msg_count                     => x_msg_count
                  , x_msg_data                      => x_msg_data
               );
              IF (PV_DEBUG_HIGH_ON) THEN
                        WRITE_LOG
                        (
                           l_api_name
                           , 'after Process_ptr_member_type call return status ' || x_return_status || 'msgdata' || x_msg_data
                        );
              END IF;
            END IF;
            -- just call upsert api to change the member type to subsidiary if its not subsidiary

            OPEN attr_version_cur(rec.subsidiary_partner_id);
               FETCH attr_version_cur INTO l_version,l_memb_type;
            CLOSE   attr_version_cur;
            IF l_memb_type <> 'SUBSIDIARY' THEN
               l_attr_value_tbl_type(1).attr_value:='SUBSIDIARY';
               PV_ENTY_ATTR_VALUE_PUB.Upsert_Attr_Value
               (
                  p_api_version_number    => 1.0
                  ,p_init_msg_list        => FND_API.g_false
                  ,p_commit               => FND_API.g_false
                  ,p_validation_level     => FND_API.g_valid_level_full
                  ,x_return_status        => x_return_status
                  ,x_msg_count            => x_msg_count
                  ,x_msg_data             => x_msg_data
                  ,p_attribute_id	     => 6
                  ,p_entity               => 'PARTNER'
                  ,p_entity_id	     => rec.subsidiary_partner_id
                  ,p_version              => l_version
                  ,p_attr_val_tbl         => l_attr_value_tbl_type
               );
              IF (PV_DEBUG_HIGH_ON) THEN
                        WRITE_LOG
                        (
                           l_api_name
                          , 'after Upsert_Attr_Value call return status ' || x_return_status || 'msgdata' || x_msg_data
                        );
              END IF;
            END IF;
         END LOOP;
      END IF; -- end of if , if l_status = 'I'
   END IF; -- end of IF ( l_key like 'oracle.apps.ar.hz.Relationship.update%'  OR l_key like 'oracle.apps.ar.hz.Relationship.create%' ) THEN
   RETURN 'SUCCESS';
EXCEPTION
   WHEN OTHERS THEN
      WF_CORE.CONTEXT('pv_ptr_member_type_pvt', 'terminate_partner', p_event.getEventName(), p_subscription_guid);
      WF_EVENT.setErrorInfo(p_event, 'ERROR');
      FND_MESSAGE.SET_NAME('PV', 'PV_API_OTHERS_EXCEP');
      FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
      FND_MSG_PUB.ADD;
      RETURN 'ERROR';
END;


PROCEDURE update_partner_dtl
(
   p_api_version_number      IN  NUMBER
   , p_init_msg_list         IN  VARCHAR2 := FND_API.G_FALSE
   , p_commit                IN  VARCHAR2 := FND_API.G_FALSE
   , p_validation_level      IN  NUMBER   :=  FND_API.G_VALID_LEVEL_FULL
   , p_partner_id            IN  NUMBER
   , p_old_partner_status    IN  VARCHAR2
   , p_new_partner_status    IN  VARCHAR2
   , p_chg_from_memb_type    IN  VARCHAR2
   , p_chg_to_memb_type      IN  VARCHAR2
   , p_old_global_ptr_id     IN  NUMBER   DEFAULT NULL
   , p_new_global_ptr_id     IN  NUMBER   DEFAULT NULL
   , x_return_status         OUT NOCOPY VARCHAR2
   , x_msg_count             OUT NOCOPY NUMBER
   , x_msg_data              OUT NOCOPY VARCHAR2
) IS
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_api_name                  CONSTANT VARCHAR2(30) := 'update_partner_dtl';
   l_to_memb_type          VARCHAR2(30);
   l_param_tbl_var         PVX_UTILITY_PVT.log_params_tbl_type;
    l_param_tbl_var1       PVX_UTILITY_PVT.log_params_tbl_type;
   l_from_memb_type        VARCHAR2(30);
   l_from_party_name       VARCHAR2(360);
   l_to_party_name         VARCHAR2(360);

   CURSOR get_memb_csr ( attr_cd IN VARCHAR2 ) IS
   SELECT  DESCRIPTION
   FROM    PV_ATTRIBUTE_CODES_VL
   WHERE   ATTRIBUTE_ID = 6
   AND     ENABLED_FLAG = 'Y'
   AND     ATTR_CODE =attr_cd;

   CURSOR get_party_csr( p_partner_id IN NUMBER ) IS
   SELECT party_name
   FROM   hz_parties party
          ,pv_partner_profiles prof
   WHERE  prof.partner_id=p_partner_id
   AND    prof.partner_party_id=party.party_id;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT update_partner_dtl ;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
   (    l_api_version_number
       ,p_api_version_number
       ,l_api_name
       ,G_PKG_NAME
   )
   THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list )  THEN
      FND_MSG_PUB.initialize;
   END IF;
   -- Debug Message

   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Validate Environment
   IF FND_GLOBAL.USER_ID IS NULL   THEN
      PVX_UTILITY_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   -- validate all the required in parameters
   IF  ( p_partner_id IS NULL OR  p_partner_id = FND_API.G_MISS_NUM ) THEN
      FND_MESSAGE.SET_NAME('PV', 'PV_MISSING_ITEM');
      FND_MESSAGE.SET_TOKEN('ITEM_NAME', 'PARTNER_ID' );
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF ( p_old_partner_status = FND_API.G_MISS_CHAR OR   p_old_partner_status is NULL ) THEN
      FND_MESSAGE.SET_NAME('PV', 'PV_MISSING_ITEM');
      FND_MESSAGE.SET_TOKEN('ITEM_NAME', 'OLD PARTNER STATUS' );
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF ( p_new_partner_status = FND_API.G_MISS_CHAR OR   p_new_partner_status is NULL ) THEN
      FND_MESSAGE.SET_NAME('PV', 'PV_MISSING_ITEM');
      FND_MESSAGE.SET_TOKEN('ITEM_NAME', 'NEW PARTNER STATUS' );
      FND_MSG_PUB.add;
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   IF ( p_new_partner_status = 'A' ) THEN
      IF ( p_chg_from_memb_type IS NULL OR p_chg_from_memb_type = FND_API.G_MISS_CHAR ) THEN
         FND_MESSAGE.SET_NAME('PV', 'PV_MISSING_ITEM');
         FND_MESSAGE.SET_TOKEN('ITEM_NAME', 'CHANGE_FROM_MEMBER_TYPE' );
         FND_MSG_PUB.add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( p_chg_to_memb_type IS NULL OR p_chg_to_memb_type = FND_API.G_MISS_CHAR ) THEN
         FND_MESSAGE.SET_NAME('PV', 'PV_MISSING_ITEM');
         FND_MESSAGE.SET_TOKEN('ITEM_NAME', 'CHANGE_TO_MEMBER_TYPE' );
         FND_MSG_PUB.add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF ( p_chg_to_memb_type ='SUBSIDIARY' AND ( p_new_global_ptr_id IS NULL OR p_new_global_ptr_id = FND_API.G_MISS_NUM) ) THEN
         FND_MESSAGE.SET_NAME('PV', 'PV_MISSING_ITEM');
         FND_MESSAGE.SET_TOKEN('ITEM_NAME', 'NEW GlOBAL PARTNER ID' );
         FND_MSG_PUB.add;
         RAISE FND_API.G_EXC_ERROR;
      	 IF ( p_chg_from_memb_type ='SUBSIDIARY'AND ( p_old_global_ptr_id IS NULL OR p_old_global_ptr_id = FND_API.G_MISS_NUM ) ) THEN
      	    FND_MESSAGE.SET_NAME('PV', 'PV_MISSING_ITEM');
            FND_MESSAGE.SET_TOKEN('ITEM_NAME', 'OLD GlOBAL PARTNER ID' );
            FND_MSG_PUB.add;
            RAISE FND_API.G_EXC_ERROR;
      	 END IF;
      END IF;
   END IF;

   IF ( p_old_partner_status <> p_new_partner_status and p_new_partner_status ='I' ) THEN
      PV_PG_MEMBERSHIPS_PVT.Terminate_ptr_memberships
      (
         p_api_version_number            => 1.0
         ,p_init_msg_list                 => FND_API.G_FALSE
         ,p_commit                        => FND_API.G_FALSE
         ,p_validation_level              => FND_API.G_VALID_LEVEL_FULL
         ,p_partner_id                    => p_partner_id
         ,p_memb_type                     => null
         ,p_status_reason_code            => 'PTR_INACTIVE'  -- it validates against PV_MEMB_STATUS_REASON_CODE
         ,p_comments                      => null
         ,x_return_status                 => x_return_status
         ,x_msg_count                     => x_msg_count
         ,x_msg_data                      => x_msg_data
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      Register_term_ptr_memb_type
      (
         p_api_version_number            => 1.0
         , p_init_msg_list                 => FND_API.G_FALSE
         , p_commit                        => FND_API.G_FALSE
         , p_validation_level              => FND_API.G_VALID_LEVEL_FULL
         , p_partner_id                    => p_partner_id
         , p_current_memb_type             => null
         , p_new_memb_type                 => null
         , p_global_ptr_id	           => null
         , x_return_status                 => x_return_status
         , x_msg_count                     => x_msg_count
         , x_msg_data                      => x_msg_data
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- changed by paul on 28may04 as after discussion with Ravi and Karen
      -- to revoke responsibilities when partner is inactivated
      Pv_User_Resp_Pvt.revoke_default_resp (
          p_api_version_number      => 1.0
         ,p_init_msg_list           => FND_API.G_FALSE
         ,p_commit                  => FND_API.G_FALSE
         ,x_return_status           => x_return_status
         ,x_msg_count               => x_msg_count
         ,x_msg_data                => x_msg_data
         ,p_partner_id              => p_partner_id
      );

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

   ELSE

      IF( p_new_partner_status ='A' and ( p_chg_from_memb_type <> p_chg_to_memb_type ) or ( p_old_global_ptr_id <> p_new_global_ptr_id and p_chg_to_memb_type ='SUBSIDIARY' ) ) THEN
         Process_ptr_member_type
         (
            p_api_version_number              => 1.0
            , p_init_msg_list                 => FND_API.G_FALSE
            , p_commit                        => FND_API.G_FALSE
            , p_validation_level              => FND_API.G_VALID_LEVEL_FULL
            , p_partner_id                    => p_partner_id
            , p_chg_from_memb_type            => p_chg_from_memb_type
            , p_chg_to_memb_type              => p_chg_to_memb_type
            , p_chg_to_global_ptr_id          => p_new_global_ptr_id
            , x_return_status                 => x_return_status
            , x_msg_count                     => x_msg_count
            , x_msg_data                      => x_msg_data
         );

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
         IF  p_chg_from_memb_type<>p_chg_to_memb_type  THEN
            --set the message the member type has been changed.
            -- call the history log api.
            OPEN get_memb_csr( p_chg_from_memb_type ) ;
               FETCH get_memb_csr INTO l_from_memb_type;
            CLOSE get_memb_csr ;

            OPEN get_memb_csr(  p_chg_to_memb_type ) ;
               FETCH get_memb_csr INTO l_to_memb_type;
            CLOSE get_memb_csr ;

            l_param_tbl_var(1).param_name := 'FROM_MEMB_TYPE';
            l_param_tbl_var(1).param_value := l_from_memb_type;
            l_param_tbl_var(2).param_name := 'TO_MEMB_TYPE';
            l_param_tbl_var(2).param_value := l_to_memb_type ;


            PVX_UTILITY_PVT.create_history_log
            (
               p_arc_history_for_entity_code   => 'GENERAL'
               , p_history_for_entity_id       => p_partner_id
               , p_history_category_code       => 'PARTNER'
               , p_message_code                => 'PV_MEMBER_TYPE_CHANGE'
               , p_comments                    => null
               , p_partner_id                  => p_partner_id
               , p_access_level_flag           => 'P'
               , p_interaction_level           => PVX_Utility_PVT.G_INTERACTION_LEVEL_50
               , p_log_params_tbl              => l_param_tbl_var
               , p_init_msg_list               => FND_API.g_false
               , p_commit                      => FND_API.G_FALSE
               , x_return_status               => x_return_status
               , x_msg_count                   => x_msg_count
               , x_msg_data                    => x_msg_data
            );
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

         ELSIF p_chg_from_memb_type=p_chg_to_memb_type  AND p_old_global_ptr_id <> p_new_global_ptr_id and p_chg_to_memb_type ='SUBSIDIARY' THEN
            --set the message that the subsidiary partners global organisation has changed.
            -- call the history log api.
            OPEN get_party_csr(p_old_global_ptr_id) ;
               FETCH get_party_csr INTO l_from_party_name;
            CLOSE get_party_csr ;

            l_param_tbl_var1(1).param_name := 'FROM_PARTNER_NAME';
            l_param_tbl_var1(1).param_value := l_from_party_name;

            OPEN get_party_csr(p_new_global_ptr_id) ;
               FETCH get_party_csr INTO l_to_party_name;
            CLOSE get_party_csr ;

            l_param_tbl_var1(2).param_name := 'TO_PARTNER_NAME';
            l_param_tbl_var1(2).param_value := l_to_party_name;

            PVX_UTILITY_PVT.create_history_log
            (
               p_arc_history_for_entity_code   => 'GENERAL'
               , p_history_for_entity_id       => p_partner_id
               , p_history_category_code       => 'PARTNER'
               , p_message_code                => 'PV_GLOBAL_PARTNER_CHANGE'
               , p_comments                    => null
               , p_partner_id                  => p_partner_id
               , p_access_level_flag           => 'P'
               , p_interaction_level           => PVX_Utility_PVT.G_INTERACTION_LEVEL_50
               , p_log_params_tbl              => l_param_tbl_var1
               , p_init_msg_list               => FND_API.g_false
               , p_commit                      => FND_API.G_FALSE
               , x_return_status               => x_return_status
               , x_msg_count                   => x_msg_count
               , x_msg_data                    => x_msg_data
            );

            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
               RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

         END IF;

      END IF;
   END IF;



   FND_MSG_PUB.Count_And_Get
   (
      p_count      =>   x_msg_count
      , p_data     =>   x_msg_data
   );

   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
   END IF;

   IF FND_API.to_Boolean( p_commit )      THEN
      COMMIT WORK;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO update_partner_dtl;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
   );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO update_partner_dtl;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
   );

   WHEN OTHERS THEN
   ROLLBACK TO update_partner_dtl;
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

END  update_partner_dtl;

END Pv_ptr_member_type_pvt;

/
