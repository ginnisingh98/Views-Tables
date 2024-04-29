--------------------------------------------------------
--  DDL for Package Body PV_GE_NOTIF_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_GE_NOTIF_RULES_PVT" as
/* $Header: pvxvgnrb.pls 120.3 2005/08/26 10:19:51 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Ge_Notif_Rules_PVT
-- Purpose
--
-- History
--  15 Nov 2002  anubhavk created
--  19 Nov 2002 anubhavk  Updated - For NOCOPY by running nocopy.sh
--
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Ge_Notif_Rules_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvgnrb.pls';

-- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
-- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
--
-- Foreward Procedure Declarations
--

PROCEDURE Default_Ge_Notif_Rules_Items (
   p_ge_notif_rules_rec IN  ge_notif_rules_rec_type ,
   x_ge_notif_rules_rec OUT NOCOPY ge_notif_rules_rec_type
) ;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Ge_Notif_Rules
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ge_notif_rules_rec            IN   ge_notif_rules_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Ge_Notif_Rules(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ge_notif_rules_rec              IN   ge_notif_rules_rec_type  := g_miss_ge_notif_rules_rec,
    x_notif_rule_id              OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Ge_Notif_Rules';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_notif_rule_id              NUMBER;
   l_dummy                     NUMBER;
   -- anubhav added
   l_ge_notif_rules_rec       ge_notif_rules_rec_type := p_ge_notif_rules_rec;
   --anubhav added ends

   CURSOR c_id IS
      SELECT pv_ge_notif_rules_b_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM PV_GE_NOTIF_RULES_B
      WHERE notif_rule_id = l_id;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_ge_notif_rules_pvt;

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
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Local variable initialization

      IF p_ge_notif_rules_rec.notif_rule_id IS NULL OR p_ge_notif_rules_rec.notif_rule_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         --FETCH c_id INTO l_notif_rule_id;
         FETCH c_id INTO l_ge_notif_rules_rec.notif_rule_id;
         CLOSE c_id;

         OPEN c_id_exists(l_notif_rule_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
      ELSE
         l_notif_rule_id := p_ge_notif_rules_rec.notif_rule_id;
	 -- Anubhav commented above added below
         l_ge_notif_rules_rec.notif_rule_id := p_ge_notif_rules_rec.notif_rule_id;
	 -- Anubhav added ends
     END IF;



      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.USER_ID IS NULL
      THEN
         PVX_UTILITY_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;



      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: Validate_Ge_Notif_Rules');
          END IF;

       -- Anubhav added to populate default values for not null columns

           l_ge_notif_rules_rec.last_update_date      := SYSDATE;
           l_ge_notif_rules_rec.last_updated_by       := FND_GLOBAL.user_id;
           l_ge_notif_rules_rec.creation_date         := SYSDATE;
           l_ge_notif_rules_rec.created_by            := FND_GLOBAL.user_id;
           l_ge_notif_rules_rec.last_update_login     := FND_GLOBAL.conc_login_id;
           l_ge_notif_rules_rec.object_version_number := l_object_version_number;

       -- Anubhav added ends


          -- Invoke validation procedures
          Validate_ge_notif_rules(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            --p_ge_notif_rules_rec  =>  p_ge_notif_rules_rec,
            --Anubhav added
            p_ge_notif_rules_rec => l_ge_notif_rules_rec,
	    -- Anubhav added ends
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;



      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(Pv_Ge_Notif_Rules_Pkg.Insert_Row)
      Pv_Ge_Notif_Rules_Pkg.Insert_Row(
          --px_notif_rule_id  => l_notif_rule_id,
	  --Anubhav added
	  px_notif_rule_id  => l_ge_notif_rules_rec.notif_rule_id,
	  --Anubhav added ends
          px_object_version_number  => l_object_version_number,
          p_arc_notif_for_entity_code  => p_ge_notif_rules_rec.arc_notif_for_entity_code,
          p_notif_for_entity_id  => p_ge_notif_rules_rec.notif_for_entity_id,
          p_wf_item_type_code  => p_ge_notif_rules_rec.wf_item_type_code,
          p_notif_type_code  => p_ge_notif_rules_rec.notif_type_code,
          p_active_flag  => p_ge_notif_rules_rec.active_flag,
          p_repeat_freq_unit  => p_ge_notif_rules_rec.repeat_freq_unit,
          p_repeat_freq_value  => p_ge_notif_rules_rec.repeat_freq_value,
          p_send_notif_before_unit  => p_ge_notif_rules_rec.send_notif_before_unit,
          p_send_notif_before_value  => p_ge_notif_rules_rec.send_notif_before_value,
          p_send_notif_after_unit  => p_ge_notif_rules_rec.send_notif_after_unit,
          p_send_notif_after_value  => p_ge_notif_rules_rec.send_notif_after_value,
          p_repeat_until_unit  => p_ge_notif_rules_rec.repeat_until_unit,
          p_repeat_until_value  => p_ge_notif_rules_rec.repeat_until_value,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_notif_name  => p_ge_notif_rules_rec.notif_name,
          p_notif_content  => p_ge_notif_rules_rec.notif_content,
          p_notif_desc  => p_ge_notif_rules_rec.notif_desc
);

          x_notif_rule_id := l_notif_rule_id;
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
--
-- End of API body
--

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN PVX_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Ge_Notif_Rules_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Ge_Notif_Rules_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Ge_Notif_Rules_PVT;
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
End Create_Ge_Notif_Rules;



/*********************
 *
 *
 * Copy_Row
 *
 *
 *********************/
PROCEDURE Copy_Row
(
    p_api_version_number   IN    NUMBER
   ,p_init_msg_list        IN    VARCHAR2 := FND_API.G_FALSE
   ,p_commit               IN    VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level     IN    NUMBER   := FND_API.G_VALID_LEVEL_FULL
   ,x_return_status        OUT   NOCOPY   VARCHAR2
   ,x_msg_count            OUT   NOCOPY   NUMBER
   ,x_msg_data             OUT   NOCOPY   VARCHAR2
   ,p_src_object_id        IN    NUMBER
   ,p_tar_object_id        IN    NUMBER
)

IS

   CURSOR c_get_notif_rules_rec (cv_program_id IN NUMBER)  IS
      SELECT  wf_item_type_code, notif_type_code,  active_flag, repeat_freq_unit, repeat_freq_value,
	send_notif_before_unit, send_notif_before_value, send_notif_after_unit, send_notif_after_value,
	repeat_until_unit, repeat_until_value
      FROM    pv_ge_notif_rules_b
      WHERE   arc_notif_for_entity_code = 'PRGM'
      AND notif_for_entity_id = cv_program_id
      order by notif_rule_id;

   CURSOR c_get_notif_rules_tl_rec (cv_program_id IN NUMBER)  IS
      SELECT  tl.notif_rule_id, notif_name, notif_content, notif_desc, language, source_lang
      FROM     pv_ge_notif_rules_b b, pv_ge_notif_rules_tl tl
      WHERE   arc_notif_for_entity_code = 'PRGM'
      and b.notif_rule_id = tl.notif_rule_id
      AND notif_for_entity_id = cv_program_id
      order by tl.notif_rule_id;

   CURSOR c_get_notif_rules_id (cv_program_id IN NUMBER)  IS
      SELECT  NOTIF_RULE_ID
      FROM    pv_ge_notif_rules_b
      WHERE   arc_notif_for_entity_code = 'PRGM'
      AND notif_for_entity_id = cv_program_id;

   l_notif_rule_id            NUMBER;
   L_API_NAME                 CONSTANT VARCHAR2(30) := 'Copy_Notif_Rules';
   L_API_VERSION_NUMBER       CONSTANT NUMBER   := 1.0;

   elmt_count				NUMBER;

   type numArray is table of number index by binary_integer;
   type varcharArray is table of VARCHAR2(240) index by binary_integer;

   notif_rule_id_array numArray;
   old_notif_rule_id_array numArray;
   new_notif_rule_id_array numArray;

   notif_name_array varcharArray;
   notif_content_array varcharArray;
   notif_desc_array varcharArray;
   source_lang_array varcharArray;
   language_array varcharArray;

   wf_item_type_code_array varcharArray;
   notif_type_code_array varcharArray;
   active_flag_array varcharArray;
   repeat_freq_unit_array varcharArray;
   repeat_freq_value_array numArray;
   send_notif_before_unit_array varcharArray;
   send_notif_before_value_array numArray;
   send_notif_after_unit_array varcharArray;
   send_notif_after_value_array numArray;
   repeat_until_unit_array  varcharArray;
   repeat_until_value_array numArray;

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT Copy_Row;

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
   IF (PV_DEBUG_HIGH_ON) THEN
       PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
   END IF;


   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;


   OPEN c_get_notif_rules_id(p_tar_object_id);
   FETCH c_get_notif_rules_id bulk collect into notif_rule_id_array
   LIMIT 100;
   --exit when c_get_notif_rules_id%notfound;
   Close c_get_notif_rules_id;

   OPEN c_get_notif_rules_rec (p_src_object_id);
   LOOP
   IF (PV_DEBUG_HIGH_ON) THEN
	PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' : inside loop');
   END IF;
   FETCH c_get_notif_rules_rec  bulk collect into
    wf_item_type_code_array, notif_type_code_array,  active_flag_array,
    repeat_freq_unit_array, repeat_freq_value_array, send_notif_before_unit_array, send_notif_before_value_array,
    send_notif_after_unit_array, send_notif_after_value_array, repeat_until_unit_array, repeat_until_value_array
    LIMIT 100;
    IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message(l_api_name || 'notif_rule_id_array.count =' || to_char(notif_rule_id_array.count));

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' : insert into b table');
    END IF;

      forall i in 1..wf_item_type_code_array.count
      update pv_ge_notif_rules_b
      set  wf_item_type_code = wf_item_type_code_array(i),
	   notif_type_code = notif_type_code_array(i),
	   active_flag = active_flag_array(i),
	   repeat_freq_unit = repeat_freq_unit_array(i),
	   repeat_freq_value = repeat_freq_value_array(i),
	   send_notif_before_unit = send_notif_before_unit_array(i),
	   send_notif_before_value = send_notif_before_value_array(i),
	   send_notif_after_unit = send_notif_after_unit_array(i),
	   send_notif_after_value = send_notif_after_value_array(i),
	   repeat_until_unit = repeat_until_unit_array(i),
	   repeat_until_value = repeat_until_value_array(i),
           object_version_number = object_version_number + 1,
           last_updated_by = FND_GLOBAL.USER_ID,
           last_update_date = sysdate,
           last_update_login = FND_GLOBAL.CONC_LOGIN_ID
      where notif_rule_id = notif_rule_id_array(i);

	   exit when c_get_notif_rules_rec%notfound;
     END LOOP;
    Close c_get_notif_rules_rec;


     open c_get_notif_rules_tl_rec(p_src_object_id);
     LOOP

      Fetch c_get_notif_rules_tl_rec bulk collect into
	  old_notif_rule_id_array, notif_name_array, notif_content_array, notif_desc_array, language_array, source_lang_array limit 100;

      	  elmt_count := 1;
	  for k in 1..old_notif_rule_id_array.count loop
	  	  if ((k <> 1) and (old_notif_rule_id_array(k) <> old_notif_rule_id_array(k-1))) then
	      	  elmt_count := elmt_count + 1;
	  	  end if;
		  IF (PV_DEBUG_HIGH_ON) THEN
			PVX_UTILITY_PVT.debug_message(l_api_name || 'k = ' || to_char(k));
			PVX_UTILITY_PVT.debug_message(l_api_name || 'elmt_count = ' || to_char(elmt_count));
		  END IF;
	  	  new_notif_rule_id_array(k) := notif_rule_id_array(elmt_count);

	  end loop;

      forall i in 1..old_notif_rule_id_array.count
      update pv_ge_notif_rules_tl
      set  notif_name = notif_name_array(i),
	   notif_content = notif_content_array(i),
	   notif_desc = notif_desc_array(i),
	   source_lang = source_lang_array(i),
           last_updated_by = FND_GLOBAL.USER_ID,
           last_update_date = sysdate,
           last_update_login = FND_GLOBAL.CONC_LOGIN_ID
      where notif_rule_id = new_notif_rule_id_array(i)
      and   language = language_array(i);

	 exit when c_get_notif_rules_tl_rec%notfound;
	 END LOOP;
     close c_get_notif_rules_tl_rec;

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
     ROLLBACK TO Copy_Row;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Copy_Row;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Copy_Row;
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

END Copy_Row;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Ge_Notif_Rules
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ge_notif_rules_rec            IN   ge_notif_rules_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Update_Ge_Notif_Rules(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_ge_notif_rules_rec               IN    ge_notif_rules_rec_type
    )

 IS


CURSOR c_get_ge_notif_rules(notif_rule_id NUMBER) IS
    SELECT *
    FROM  PV_GE_NOTIF_RULES_B
    WHERE  notif_rule_id = p_ge_notif_rules_rec.notif_rule_id;
    -- Hint: Developer need to provide Where clause


L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Ge_Notif_Rules';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_notif_rule_id    NUMBER;
l_ref_ge_notif_rules_rec  c_get_Ge_Notif_Rules%ROWTYPE ;
l_tar_ge_notif_rules_rec  ge_notif_rules_rec_type := P_ge_notif_rules_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_ge_notif_rules_pvt;

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
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
      END IF;

      OPEN c_get_Ge_Notif_Rules( l_tar_ge_notif_rules_rec.notif_rule_id);

      FETCH c_get_Ge_Notif_Rules INTO l_ref_ge_notif_rules_rec  ;

       If ( c_get_Ge_Notif_Rules%NOTFOUND) THEN
  PVX_UTILITY_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Ge_Notif_Rules') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (PV_DEBUG_HIGH_ON) THEN

       PVX_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Ge_Notif_Rules;


      If (l_tar_ge_notif_rules_rec.object_version_number is NULL or
          l_tar_ge_notif_rules_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  PVX_UTILITY_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_ge_notif_rules_rec.object_version_number <> l_ref_ge_notif_rules_rec.object_version_number) Then
  PVX_UTILITY_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Ge_Notif_Rules') ;
          raise FND_API.G_EXC_ERROR;
      End if;


      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: Validate_Ge_Notif_Rules');
          END IF;

          -- Invoke validation procedures
          Validate_ge_notif_rules(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_ge_notif_rules_rec  =>  p_ge_notif_rules_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      --IF (PV_DEBUG_HIGH_ON) THENPVX_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');END IF;

      -- Invoke table handler(Pv_Ge_Notif_Rules_Pkg.Update_Row)
      Pv_Ge_Notif_Rules_Pkg.Update_Row(
          p_notif_rule_id  => p_ge_notif_rules_rec.notif_rule_id,
          p_object_version_number  => p_ge_notif_rules_rec.object_version_number,
          p_arc_notif_for_entity_code  => p_ge_notif_rules_rec.arc_notif_for_entity_code,
          p_notif_for_entity_id  => p_ge_notif_rules_rec.notif_for_entity_id,
          p_wf_item_type_code  => p_ge_notif_rules_rec.wf_item_type_code,
          p_notif_type_code  => p_ge_notif_rules_rec.notif_type_code,
          p_active_flag  => p_ge_notif_rules_rec.active_flag,
          p_repeat_freq_unit  => p_ge_notif_rules_rec.repeat_freq_unit,
          p_repeat_freq_value  => p_ge_notif_rules_rec.repeat_freq_value,
          p_send_notif_before_unit  => p_ge_notif_rules_rec.send_notif_before_unit,
          p_send_notif_before_value  => p_ge_notif_rules_rec.send_notif_before_value,
          p_send_notif_after_unit  => p_ge_notif_rules_rec.send_notif_after_unit,
          p_send_notif_after_value  => p_ge_notif_rules_rec.send_notif_after_value,
          p_repeat_until_unit  => p_ge_notif_rules_rec.repeat_until_unit,
          p_repeat_until_value  => p_ge_notif_rules_rec.repeat_until_value,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_notif_name  => p_ge_notif_rules_rec.notif_name,
          p_notif_content  => p_ge_notif_rules_rec.notif_content,
          p_notif_desc  => p_ge_notif_rules_rec.notif_desc
);
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN PVX_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Ge_Notif_Rules_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Ge_Notif_Rules_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Ge_Notif_Rules_PVT;
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
End Update_Ge_Notif_Rules;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Ge_Notif_Rules
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_notif_rule_id                IN   NUMBER
--       p_object_version_number   IN   NUMBER     Optional  Default = NULL
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Delete_Ge_Notif_Rules(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_notif_rule_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Ge_Notif_Rules';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_ge_notif_rules_pvt;

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
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
      END IF;

      -- Invoke table handler(Pv_Ge_Notif_Rules_Pkg.Delete_Row)
      Pv_Ge_Notif_Rules_Pkg.Delete_Row(
          p_notif_rule_id  => p_notif_rule_id,
          p_object_version_number => p_object_version_number     );
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN PVX_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Ge_Notif_Rules_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Ge_Notif_Rules_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Ge_Notif_Rules_PVT;
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
End Delete_Ge_Notif_Rules;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Ge_Notif_Rules
--   Type
--           Private
--   Pre-Req
--
--   Parameters
--
--   IN
--       p_api_version_number      IN   NUMBER     Required
--       p_init_msg_list           IN   VARCHAR2   Optional  Default = FND_API_G_FALSE
--       p_commit                  IN   VARCHAR2   Optional  Default = FND_API.G_FALSE
--       p_validation_level        IN   NUMBER     Optional  Default = FND_API.G_VALID_LEVEL_FULL
--       p_ge_notif_rules_rec            IN   ge_notif_rules_rec_type  Required
--
--   OUT
--       x_return_status           OUT  VARCHAR2
--       x_msg_count               OUT  NUMBER
--       x_msg_data                OUT  VARCHAR2
--   Version : Current version 1.0
--   Note: This automatic generated procedure definition, it includes standard IN/OUT parameters
--         and basic operation, developer must manually add parameters and business logic as necessary.
--
--   History
--
--   NOTE
--
--   End of Comments
--   ==============================================================================

PROCEDURE Lock_Ge_Notif_Rules(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_notif_rule_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Ge_Notif_Rules';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_notif_rule_id                  NUMBER;

BEGIN

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;



      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


------------------------ lock -------------------------
Pv_Ge_Notif_Rules_Pkg.Lock_Row(l_notif_rule_id,p_object_version);


 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  IF (PV_DEBUG_HIGH_ON) THEN

  PVX_UTILITY_PVT.debug_message(l_full_name ||': end');
  END IF;
EXCEPTION

   WHEN PVX_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Ge_Notif_Rules_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Ge_Notif_Rules_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Ge_Notif_Rules_PVT;
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
End Lock_Ge_Notif_Rules;




PROCEDURE check_Ge_Notif_Rules_Uk_Items(
    p_ge_notif_rules_rec               IN   ge_notif_rules_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_ge_notif_rules_rec.notif_rule_id IS NOT NULL
      THEN
         l_valid_flag := PVX_UTILITY_PVT.check_uniqueness(
         'pv_ge_notif_rules_b',
         'notif_rule_id = ''' || p_ge_notif_rules_rec.notif_rule_id ||''''
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_notif_rule_id_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

END check_Ge_Notif_Rules_Uk_Items;



PROCEDURE check_Ge_Notif_Rules_Req_Items(
    p_ge_notif_rules_rec               IN  ge_notif_rules_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_ge_notif_rules_rec.notif_rule_id = FND_API.G_MISS_NUM OR p_ge_notif_rules_rec.notif_rule_id IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'NOTIF_RULE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ge_notif_rules_rec.object_version_number = FND_API.G_MISS_NUM OR p_ge_notif_rules_rec.object_version_number IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUMBER' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ge_notif_rules_rec.arc_notif_for_entity_code = FND_API.g_miss_char OR p_ge_notif_rules_rec.arc_notif_for_entity_code IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'ARC_NOTIF_FOR_ENTITY_CODE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ge_notif_rules_rec.notif_for_entity_id = FND_API.G_MISS_NUM OR p_ge_notif_rules_rec.notif_for_entity_id IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'NOTIF_FOR_ENTITY_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ge_notif_rules_rec.notif_type_code = FND_API.g_miss_char OR p_ge_notif_rules_rec.notif_type_code IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'NOTIF_TYPE_CODE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ge_notif_rules_rec.active_flag = FND_API.g_miss_char OR p_ge_notif_rules_rec.active_flag IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'ACTIVE_FLAG' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


   ELSE


      IF p_ge_notif_rules_rec.notif_rule_id = FND_API.G_MISS_NUM THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'NOTIF_RULE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ge_notif_rules_rec.object_version_number = FND_API.G_MISS_NUM THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUMBER' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ge_notif_rules_rec.arc_notif_for_entity_code = FND_API.g_miss_char THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'ARC_NOTIF_FOR_ENTITY_CODE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ge_notif_rules_rec.notif_for_entity_id = FND_API.G_MISS_NUM THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'NOTIF_FOR_ENTITY_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ge_notif_rules_rec.notif_type_code = FND_API.g_miss_char THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'NOTIF_TYPE_CODE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_ge_notif_rules_rec.active_flag = FND_API.g_miss_char THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'ACTIVE_FLAG' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_Ge_Notif_Rules_Req_Items;



PROCEDURE check_Ge_Notif_Rules_Fk_Items(
    p_ge_notif_rules_rec IN ge_notif_rules_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Ge_Notif_Rules_Fk_Items;



PROCEDURE check_Ge_Notif_Rules_Lkup_Item(
    p_ge_notif_rules_rec IN ge_notif_rules_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Ge_Notif_Rules_Lkup_Item;



PROCEDURE Check_Ge_Notif_Rules_Items (
    P_ge_notif_rules_rec     IN    ge_notif_rules_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

    l_return_status := FND_API.g_ret_sts_success;
   -- Check Items Uniqueness API calls

   check_Ge_notif_rules_Uk_Items(
      p_ge_notif_rules_rec => p_ge_notif_rules_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_ge_notif_rules_req_items(
      p_ge_notif_rules_rec => p_ge_notif_rules_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Foreign Keys API calls

   check_ge_notif_rules_FK_items(
      p_ge_notif_rules_rec => p_ge_notif_rules_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Lookups

   check_Ge_Notif_Rules_Lkup_Item(
      p_ge_notif_rules_rec => p_ge_notif_rules_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   x_return_status := l_return_status;

END Check_ge_notif_rules_Items;





PROCEDURE Complete_Ge_Notif_Rules_Rec (
   p_ge_notif_rules_rec IN ge_notif_rules_rec_type,
   x_complete_rec OUT NOCOPY ge_notif_rules_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM pv_ge_notif_rules_b
      WHERE notif_rule_id = p_ge_notif_rules_rec.notif_rule_id;
   l_ge_notif_rules_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_ge_notif_rules_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_ge_notif_rules_rec;
   CLOSE c_complete;

   -- notif_rule_id
   IF p_ge_notif_rules_rec.notif_rule_id IS NULL THEN
      x_complete_rec.notif_rule_id := l_ge_notif_rules_rec.notif_rule_id;
   END IF;

   -- object_version_number
   IF p_ge_notif_rules_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_ge_notif_rules_rec.object_version_number;
   END IF;

   -- arc_notif_for_entity_code
   IF p_ge_notif_rules_rec.arc_notif_for_entity_code IS NULL THEN
      x_complete_rec.arc_notif_for_entity_code := l_ge_notif_rules_rec.arc_notif_for_entity_code;
   END IF;

   -- notif_for_entity_id
   IF p_ge_notif_rules_rec.notif_for_entity_id IS NULL THEN
      x_complete_rec.notif_for_entity_id := l_ge_notif_rules_rec.notif_for_entity_id;
   END IF;

   -- wf_item_type_code
   IF p_ge_notif_rules_rec.wf_item_type_code IS NULL THEN
      x_complete_rec.wf_item_type_code := l_ge_notif_rules_rec.wf_item_type_code;
   END IF;

   -- notif_type_code
   IF p_ge_notif_rules_rec.notif_type_code IS NULL THEN
      x_complete_rec.notif_type_code := l_ge_notif_rules_rec.notif_type_code;
   END IF;

   -- active_flag
   IF p_ge_notif_rules_rec.active_flag IS NULL THEN
      x_complete_rec.active_flag := l_ge_notif_rules_rec.active_flag;
   END IF;

   -- repeat_freq_unit
   IF p_ge_notif_rules_rec.repeat_freq_unit IS NULL THEN
      x_complete_rec.repeat_freq_unit := l_ge_notif_rules_rec.repeat_freq_unit;
   END IF;

   -- repeat_freq_value
   IF p_ge_notif_rules_rec.repeat_freq_value IS NULL THEN
      x_complete_rec.repeat_freq_value := l_ge_notif_rules_rec.repeat_freq_value;
   END IF;

   -- send_notif_before_unit
   IF p_ge_notif_rules_rec.send_notif_before_unit IS NULL THEN
      x_complete_rec.send_notif_before_unit := l_ge_notif_rules_rec.send_notif_before_unit;
   END IF;

   -- send_notif_before_value
   IF p_ge_notif_rules_rec.send_notif_before_value IS NULL THEN
      x_complete_rec.send_notif_before_value := l_ge_notif_rules_rec.send_notif_before_value;
   END IF;

   -- send_notif_after_unit
   IF p_ge_notif_rules_rec.send_notif_after_unit IS NULL THEN
      x_complete_rec.send_notif_after_unit := l_ge_notif_rules_rec.send_notif_after_unit;
   END IF;

   -- send_notif_after_value
   IF p_ge_notif_rules_rec.send_notif_after_value IS NULL THEN
      x_complete_rec.send_notif_after_value := l_ge_notif_rules_rec.send_notif_after_value;
   END IF;

   -- repeat_until_unit
   IF p_ge_notif_rules_rec.repeat_until_unit IS NULL THEN
      x_complete_rec.repeat_until_unit := l_ge_notif_rules_rec.repeat_until_unit;
   END IF;

   -- repeat_until_value
   IF p_ge_notif_rules_rec.repeat_until_value IS NULL THEN
      x_complete_rec.repeat_until_value := l_ge_notif_rules_rec.repeat_until_value;
   END IF;

   -- created_by
   IF p_ge_notif_rules_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_ge_notif_rules_rec.created_by;
   END IF;

   -- creation_date
   IF p_ge_notif_rules_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_ge_notif_rules_rec.creation_date;
   END IF;

   -- last_updated_by
   IF p_ge_notif_rules_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_ge_notif_rules_rec.last_updated_by;
   END IF;

   -- last_update_date
   IF p_ge_notif_rules_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_ge_notif_rules_rec.last_update_date;
   END IF;

   -- last_update_login
   IF p_ge_notif_rules_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_ge_notif_rules_rec.last_update_login;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Ge_Notif_Rules_Rec;




PROCEDURE Default_Ge_Notif_Rules_Items ( p_ge_notif_rules_rec IN ge_notif_rules_rec_type ,
                                x_ge_notif_rules_rec OUT NOCOPY ge_notif_rules_rec_type )
IS
   l_ge_notif_rules_rec ge_notif_rules_rec_type := p_ge_notif_rules_rec;
BEGIN
   -- Developers should put their code to default the record type
   -- e.g. IF p_campaign_rec.status_code IS NULL
   --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
   --         l_campaign_rec.status_code := 'NEW' ;
   --      END IF ;
   --
   NULL ;
END;




PROCEDURE Validate_Ge_Notif_Rules(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_ge_notif_rules_rec               IN   ge_notif_rules_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Ge_Notif_Rules';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_ge_notif_rules_rec        ge_notif_rules_rec_type;
l_ge_notif_rules_rec_out    ge_notif_rules_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_ge_notif_rules_;

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


      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_ge_notif_rules_Items(
                 p_ge_notif_rules_rec        => p_ge_notif_rules_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         Default_Ge_Notif_Rules_Items (p_ge_notif_rules_rec => p_ge_notif_rules_rec ,
                                x_ge_notif_rules_rec => l_ge_notif_rules_rec) ;
      END IF ;


      Complete_ge_notif_rules_Rec(
         p_ge_notif_rules_rec        => l_ge_notif_rules_rec,
         x_complete_rec              => l_ge_notif_rules_rec_out
      );

      l_ge_notif_rules_rec := l_ge_notif_rules_rec_out;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_ge_notif_rules_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_ge_notif_rules_rec           =>    l_ge_notif_rules_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN PVX_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Ge_Notif_Rules_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Ge_Notif_Rules_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Ge_Notif_Rules_;
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
End Validate_Ge_Notif_Rules;


PROCEDURE Validate_Ge_Notif_Rules_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_ge_notif_rules_rec               IN    ge_notif_rules_rec_type
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Hint: Validate data
      -- If data not valid
      -- THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_ge_notif_rules_Rec;


PROCEDURE Create_Ge_Notif_Rules_Rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_programId      IN NUMBER
)

IS
l_ge_notif_rules_rec  ge_notif_rules_rec_type;
x_notif_rule_id     NUMBER;

BEGIN


-- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

-- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      l_ge_notif_rules_rec.arc_notif_for_entity_code := 'PRGM';
      l_ge_notif_rules_rec.notif_for_entity_id       := p_programId;
      l_ge_notif_rules_rec.wf_item_type_code         := 'PVXNUTIL';
      l_ge_notif_rules_rec.ACTIVE_FLAG               := 'N';


      l_ge_notif_rules_rec.notif_type_code           := 'PG_THANKYOU';
      l_ge_notif_rules_rec.NOTIF_NAME                := 'ThankYou Notification';
      l_ge_notif_rules_rec.notif_content             := 'ThankYou Notification';

      Create_Ge_Notif_Rules( p_api_version_number,
                            p_init_msg_list,
			    p_commit,
			    p_validation_level,
			    x_return_status,
			    x_msg_count,
			    x_msg_data,
			    l_ge_notif_rules_rec,
			    x_notif_rule_id
			  );

      l_ge_notif_rules_rec.notif_type_code           := 'PG_WELCOME';
      l_ge_notif_rules_rec.NOTIF_NAME                := 'Welcome Notification';
      l_ge_notif_rules_rec.notif_content             := 'Welcome Notification';
      Create_Ge_Notif_Rules( p_api_version_number,
                            p_init_msg_list,
			    p_commit,
			    p_validation_level,
			    x_return_status,
			    x_msg_count,
			    x_msg_data,
			    l_ge_notif_rules_rec,
			    x_notif_rule_id
			  );

      l_ge_notif_rules_rec.notif_type_code           := 'PG_REJECT';
      l_ge_notif_rules_rec.NOTIF_NAME                := 'Rejection Notification';
      l_ge_notif_rules_rec.notif_content             := 'Rejection Notification';
      Create_Ge_Notif_Rules( p_api_version_number,
                            p_init_msg_list,
			    p_commit,
			    p_validation_level,
			    x_return_status,
			    x_msg_count,
			    x_msg_data,
			    l_ge_notif_rules_rec,
			    x_notif_rule_id
			  );

      l_ge_notif_rules_rec.notif_type_code           := 'PG_CONTRCT_NRCVD';
      l_ge_notif_rules_rec.NOTIF_NAME                := 'Contract not received notification';
      l_ge_notif_rules_rec.notif_content             := 'Contract not received';
      l_ge_notif_rules_rec.repeat_freq_value         := 0;

      Create_Ge_Notif_Rules( p_api_version_number,
                            p_init_msg_list,
			    p_commit,
			    p_validation_level,
			    x_return_status,
			    x_msg_count,
			    x_msg_data,
			    l_ge_notif_rules_rec,
			    x_notif_rule_id
			  );


      l_ge_notif_rules_rec.notif_type_code           := 'PG_MEM_EXP';
      l_ge_notif_rules_rec.NOTIF_NAME                := 'Membership Expiry Notification';
      l_ge_notif_rules_rec.notif_content             := 'Membership Expiry Notification';
      l_ge_notif_rules_rec.repeat_freq_value         := 0;

      Create_Ge_Notif_Rules( p_api_version_number,
                            p_init_msg_list,
			    p_commit,
			    p_validation_level,
			    x_return_status,
			    x_msg_count,
			    x_msg_data,
			    l_ge_notif_rules_rec,
			    x_notif_rule_id
			  );



END Create_Ge_Notif_Rules_Rec;






END PV_Ge_Notif_Rules_PVT;

/
