--------------------------------------------------------
--  DDL for Package Body PV_PEC_RULES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PEC_RULES_PVT" as
/* $Header: pvxvecrb.pls 120.1 2005/09/06 04:36:22 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Pec_Rules_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Pec_Rules_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvecrb.pls';

-- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
-- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
--
-- Foreward Procedure Declarations
--

PROCEDURE Default_Pec_Rules_Items (
   p_pec_rules_rec IN  pec_rules_rec_type ,
   x_pec_rules_rec OUT NOCOPY pec_rules_rec_type
) ;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Pec_Rules
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
--       p_pec_rules_rec            IN   pec_rules_rec_type  Required
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

PROCEDURE Create_Pec_Rules(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_pec_rules_rec              IN   pec_rules_rec_type  := g_miss_pec_rules_rec,
    x_enrl_change_rule_id              OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Pec_Rules';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_enrl_change_rule_id              NUMBER;
   l_dummy                     NUMBER;
   l_pec_rules_rec       pec_rules_rec_type  := p_pec_rules_rec;
   l_change_direction_code VARCHAR2(30);
   l_enrl_change_from_id_rev  NUMBER;
   l_enrl_change_to_id_rev    NUMBER;
   l_enrl_change_rule_id_rev              NUMBER;
   l_value                     NUMBER;

   CURSOR c_id IS
      SELECT pv_pg_enrl_change_rules_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM PV_PG_ENRL_CHANGE_RULES
      WHERE enrl_change_rule_id = l_id;

  /*CURSOR c_program_id_exists (from_id IN NUMBER,to_id IN NUMBER) IS
      SELECT 1
      FROM PV_PG_ENRL_CHANGE_RULES
      WHERE change_from_program_id = from_id
      AND change_to_program_id = to_id
      AND NVL(effective_to_date,sysdate) >= SYSDATE
      AND change_direction_code = 'UPGRADE';
   */
   CURSOR c_program_id_exists (from_id IN NUMBER,to_id IN NUMBER,p_direction_code in VARCHAR2) IS
      SELECT 1
      FROM PV_PG_ENRL_CHANGE_RULES
      WHERE change_from_program_id = from_id
      AND change_to_program_id = to_id
      AND NVL(effective_to_date,sysdate) >= SYSDATE
      AND change_direction_code = p_direction_code;
BEGIN

	IF (PV_DEBUG_HIGH_ON) THEN



	PVX_UTILITY_PVT.debug_message('Inside Create Proc ');

	END IF;

      -- Standard Start of API savepoint
      SAVEPOINT create_pec_rules_pvt;

	IF (PV_DEBUG_HIGH_ON) THEN



	PVX_UTILITY_PVT.debug_message('Comparing compatibility ');

	END IF;




      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

		IF (PV_DEBUG_HIGH_ON) THEN



		PVX_UTILITY_PVT.debug_message('After Comparing compatibility ');

		END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');
      END IF;


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      l_value := NULL;

       /*
       OPEN c_program_id_exists(l_pec_rules_rec.change_from_program_id,l_pec_rules_rec.change_to_program_id,l_pec_rules_rec.change_direction_code );
        FETCH c_program_id_exists INTO l_value;
        IF c_program_id_exists%FOUND THEN
          CLOSE c_program_id_exists;
          IF l_pec_rules_rec.change_direction_code='UPGRADE' THEN
            FND_MESSAGE.set_name('PV', 'PV_DENY_CREATE_UPGRADE_RULE');
            FND_MSG_PUB.add;
	    --x_return_status := FND_API.G_RET_STS_ERROR;
	  ELSIF l_pec_rules_rec.change_direction_code='PREREQUISITE' THEN
	    FND_MESSAGE.set_name('PV', 'PV_DENY_CREATE_PREREQ_RULE');
            FND_MSG_PUB.add;
	  END IF;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          CLOSE c_program_id_exists;
        */


        OPEN c_program_id_exists(l_pec_rules_rec.change_from_program_id,l_pec_rules_rec.change_to_program_id,'UPGRADE' );
          FETCH c_program_id_exists INTO l_value;
        IF c_program_id_exists%FOUND THEN
          CLOSE c_program_id_exists;
          IF l_pec_rules_rec.change_direction_code='UPGRADE' THEN
             FND_MESSAGE.set_name('PV', 'PV_DENY_CREATE_UPGRADE_RULE');
             FND_MSG_PUB.add;
          ELSIF  l_pec_rules_rec.change_direction_code='PREREQUISITE' THEN
             FND_MESSAGE.set_name('PV', 'PV_UPGRADE_EXISTS');
             FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          CLOSE c_program_id_exists;
        END If;

        OPEN c_program_id_exists(l_pec_rules_rec.change_from_program_id,l_pec_rules_rec.change_to_program_id,'PREREQUISITE' );
          FETCH c_program_id_exists INTO l_value;
        IF c_program_id_exists%FOUND THEN
          CLOSE c_program_id_exists;
          IF l_pec_rules_rec.change_direction_code='UPGRADE' THEN
             FND_MESSAGE.set_name('PV', 'PV_PREREQ_EXISTS');
             FND_MSG_PUB.add;
          ELSIF  l_pec_rules_rec.change_direction_code='PREREQUISITE' THEN
             FND_MESSAGE.set_name('PV', 'PV_DENY_CREATE_PREREQ_RULE');
             FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.G_EXC_ERROR;
        ELSE
          CLOSE c_program_id_exists;
        END If;



     -- Local variable initialization

   IF p_pec_rules_rec.enrl_change_rule_id IS NULL OR p_pec_rules_rec.enrl_change_rule_id = FND_API.g_miss_num THEN
      LOOP
	 l_dummy := NULL;
	 OPEN c_id;
	 FETCH c_id INTO l_pec_rules_rec.enrl_change_rule_id;
	 CLOSE c_id;

	 OPEN c_id_exists(l_pec_rules_rec.enrl_change_rule_id);
	 FETCH c_id_exists INTO l_dummy;
	 CLOSE c_id_exists;
	 EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
	 l_pec_rules_rec.enrl_change_rule_id := p_pec_rules_rec.enrl_change_rule_id;
   END IF;


      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.USER_ID IS NULL
      THEN
         PVX_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

     IF (PV_DEBUG_HIGH_ON) THEN



     PVX_UTILITY_PVT.debug_message('Before Validating ');

     END IF;

      IF ( p_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: Validate_Pec_Rules');
          END IF;

          l_pec_rules_rec.last_update_date := SYSDATE;
	  l_pec_rules_rec.last_updated_by := FND_GLOBAL.user_id;
	  l_pec_rules_rec.creation_date := SYSDATE;
	  l_pec_rules_rec.created_by := FND_GLOBAL.user_id;
	  l_pec_rules_rec.last_update_login := FND_GLOBAL.conc_login_id;
	  l_pec_rules_rec.object_version_number := l_object_version_number;

	  l_pec_rules_rec.effective_from_date := SYSDATE;


	  -- Invoke validation procedures
          Validate_pec_rules(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_pec_rules_rec  =>  l_pec_rules_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF (PV_DEBUG_HIGH_ON) THEN



      PVX_UTILITY_PVT.debug_message('After Validating ');

      END IF;


      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;




     -- Invoke table handler(Pv_Pec_Rules_Pkg.Insert_Row)
      Pv_Pec_Rules_Pkg.Insert_Row(
          px_enrl_change_rule_id  => l_pec_rules_rec.enrl_change_rule_id,
          px_object_version_number  => l_object_version_number,
          p_change_from_program_id  => l_pec_rules_rec.change_from_program_id,
          p_change_to_program_id  => l_pec_rules_rec.change_to_program_id,
          p_change_direction_code  => l_pec_rules_rec.change_direction_code,
          p_effective_from_date  => l_pec_rules_rec.effective_from_date,
          p_effective_to_date  => l_pec_rules_rec.effective_to_date,
          p_active_flag  => l_pec_rules_rec.active_flag,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => FND_GLOBAL.conc_login_id
);

          x_enrl_change_rule_id := l_enrl_change_rule_id;

         IF l_pec_rules_rec.change_direction_code='UPGRADE' THEN
         	  -- Invoke table handler(Pv_Pec_Rules_Pkg.Insert_Row) to insert a second row with reverse Direction Code
         	  l_change_direction_code   := 'DOWNGRADE';
         	  l_enrl_change_from_id_rev := l_pec_rules_rec.change_to_program_id;
         	  l_enrl_change_to_id_rev   := l_pec_rules_rec.change_from_program_id;
         	  OPEN c_id;
         	     FETCH c_id INTO l_pec_rules_rec.enrl_change_rule_id;
         	  CLOSE c_id;

         	  Pv_Pec_Rules_Pkg.Insert_Row(
                   px_enrl_change_rule_id  => l_pec_rules_rec.enrl_change_rule_id ,
                   px_object_version_number  => l_object_version_number,
                   p_change_from_program_id  => l_enrl_change_from_id_rev,
                   p_change_to_program_id  => l_enrl_change_to_id_rev,
                   p_change_direction_code  => l_change_direction_code,
                   p_effective_from_date  => l_pec_rules_rec.effective_from_date,
                   p_effective_to_date  => l_pec_rules_rec.effective_to_date,
                   p_active_flag  => l_pec_rules_rec.active_flag,
                   p_created_by  => FND_GLOBAL.USER_ID,
                   p_creation_date  => SYSDATE,
                   p_last_updated_by  => FND_GLOBAL.USER_ID,
                   p_last_update_date  => SYSDATE,
                   p_last_update_login  => FND_GLOBAL.conc_login_id
                );

      	     x_enrl_change_rule_id := l_enrl_change_rule_id;
          END IF;

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

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Pec_Rules_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Pec_Rules_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Pec_Rules_PVT;
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
End Create_Pec_Rules;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Pec_Rules
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
--       p_pec_rules_rec            IN   pec_rules_rec_type  Required
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

PROCEDURE Update_Pec_Rules(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_pec_rules_rec               IN    pec_rules_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS


CURSOR c_get_pec_rules(enrl_change_rule_id NUMBER) IS
    SELECT *
    FROM  PV_PG_ENRL_CHANGE_RULES
    WHERE  enrl_change_rule_id = p_pec_rules_rec.enrl_change_rule_id;
    -- Hint: Developer need to provide Where clause

CURSOR c_get_pec_rec_down(l_enrl_change_from_id_rev IN NUMBER, l_enrl_change_to_id_rev IN NUMBER ) IS
    SELECT *
    FROM  PV_PG_ENRL_CHANGE_RULES
    WHERE  change_from_program_id = l_enrl_change_from_id_rev
    AND    change_to_program_id   = l_enrl_change_to_id_rev
    AND    effective_to_date is null
    AND    change_direction_code='DOWNGRADE';

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Pec_Rules';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER ;
l_enrl_change_rule_id    NUMBER;

l_ref_pec_rules_rec  c_get_Pec_Rules%ROWTYPE ;
l_tar_pec_rules_rec  pec_rules_rec_type := P_pec_rules_rec;
l_ref_pec_rules_rec_down  c_get_pec_rec_down%ROWTYPE ;
l_rowid  ROWID;
from_id_rev  NUMBER;
to_id_rev    NUMBER;



 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_pec_rules_pvt;

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

      OPEN c_get_Pec_Rules( l_tar_pec_rules_rec.enrl_change_rule_id);

      FETCH c_get_Pec_Rules INTO l_ref_pec_rules_rec  ;

       If ( c_get_Pec_Rules%NOTFOUND) THEN
  PVX_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Pec_Rules') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (PV_DEBUG_HIGH_ON) THEN

       PVX_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Pec_Rules;

--	l_tar_pec_rules_rec.object_version_number := l_object_version_number;


      If (l_tar_pec_rules_rec.object_version_number is NULL or
          l_tar_pec_rules_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  PVX_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_pec_rules_rec.object_version_number <> l_ref_pec_rules_rec.object_version_number) Then
  PVX_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Pec_Rules') ;
          raise FND_API.G_EXC_ERROR;
      End if;


      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: Validate_Pec_Rules');
          END IF;

          -- Invoke validation procedures
          Validate_pec_rules(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_pec_rules_rec  =>  p_pec_rules_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      --IF (PV_DEBUG_HIGH_ON) THENPVX_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');END IF;

      l_object_version_number  := p_pec_rules_rec.object_version_number;

      -- Invoke table handler(Pv_Pec_Rules_Pkg.Update_Row)
      Pv_Pec_Rules_Pkg.Update_Row(
          p_enrl_change_rule_id  => p_pec_rules_rec.enrl_change_rule_id,
          px_object_version_number  => l_object_version_number,
          p_change_from_program_id  => p_pec_rules_rec.change_from_program_id,
          p_change_to_program_id  => p_pec_rules_rec.change_to_program_id,
          p_change_direction_code  => p_pec_rules_rec.change_direction_code,
          p_effective_from_date  => p_pec_rules_rec.effective_from_date,
          p_effective_to_date  => p_pec_rules_rec.effective_to_date,
          p_active_flag  => p_pec_rules_rec.active_flag,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => FND_GLOBAL.conc_login_id );

	 x_object_version_number  := l_object_version_number;


	 IF l_ref_pec_rules_rec.change_direction_code='UPGRADE' THEN
   	   from_id_rev := p_pec_rules_rec.change_to_program_id;
           to_id_rev   := p_pec_rules_rec.change_from_program_id ;

      --
          for downg in c_get_pec_rec_down(from_id_rev, to_id_rev) LOOP
             Pv_Pec_Rules_Pkg.Update_Row(
                p_enrl_change_rule_id  => downg.enrl_change_rule_id,
                px_object_version_number  => downg.object_version_number,
                p_change_from_program_id  => downg.change_from_program_id,
                p_change_to_program_id  => downg.change_to_program_id,
                p_change_direction_code  => downg.change_direction_code,
                p_effective_from_date  => downg.effective_from_date,
                p_effective_to_date  =>  downg.effective_to_date,
                p_active_flag  => p_pec_rules_rec.active_flag,
                p_last_updated_by  => FND_GLOBAL.USER_ID,
                p_last_update_date  => SYSDATE,
                p_last_update_login  => FND_GLOBAL.conc_login_id);

          END LOOP;
      END IF;
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

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Pec_Rules_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Pec_Rules_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Pec_Rules_PVT;
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
End Update_Pec_Rules;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Pec_Rules
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
--       p_enrl_change_rule_id                IN   NUMBER
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

PROCEDURE Delete_Pec_Rules(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_enrl_change_rule_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS

CURSOR c_get_pec_rec IS
    SELECT *
    FROM  PV_PG_ENRL_CHANGE_RULES
    WHERE  enrl_change_rule_id = p_enrl_change_rule_id;

CURSOR c_get_pec_rec_down(l_enrl_change_from_id_rev IN NUMBER, l_enrl_change_to_id_rev IN NUMBER ) IS
    SELECT *
    FROM  PV_PG_ENRL_CHANGE_RULES
    WHERE  change_from_program_id = l_enrl_change_from_id_rev
    AND    change_to_program_id   = l_enrl_change_to_id_rev
    AND    effective_to_date is null
    AND    change_direction_code='DOWNGRADE';

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Pec_Rules';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_enrl_change_rule_id NUMBER;
l_ref_pec_rules_rec  c_get_pec_rec%ROWTYPE ;
l_ref_pec_rules_rec_down  c_get_pec_rec_down%ROWTYPE ;
from_id_rev  NUMBER;
to_id_rev    NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_pec_rules_pvt;

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

      -- Invoke table handler(Pv_Pec_Rules_Pkg.Delete_Row)
      --Pv_Pec_Rules_Pkg.Delete_Row(
         -- p_enrl_change_rule_id  => p_enrl_change_rule_id,
         -- p_object_version_number => p_object_version_number     );
      --
      -- End of API body
      --
      --Pv_Pec_Rules_Pkg.Delete_Row(
          --p_enrl_change_rule_id  => l_enrl_change_rule_id,
          --p_object_version_number => p_object_version_number     );

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
      END IF;

      OPEN c_get_pec_rec;

      FETCH c_get_pec_rec INTO l_ref_pec_rules_rec  ;

       If ( c_get_pec_rec%NOTFOUND) THEN
	PVX_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
	p_token_name   => 'INFO',
	p_token_value  => 'Pec_Rules') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (PV_DEBUG_HIGH_ON) THEN

       PVX_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_pec_rec;

         l_object_version_number := p_object_version_number;

	-- Make the record end dated when it is deleted.
	-- Invoke table handler(Pv_Pec_Rules_Pkg.Update_Row)
        Pv_Pec_Rules_Pkg.Update_Row(
          p_enrl_change_rule_id  => p_enrl_change_rule_id,
          px_object_version_number  => l_object_version_number,
          p_change_from_program_id  => l_ref_pec_rules_rec.change_from_program_id,
          p_change_to_program_id  => l_ref_pec_rules_rec.change_to_program_id,
          p_change_direction_code  => l_ref_pec_rules_rec.change_direction_code,
          p_effective_from_date  => l_ref_pec_rules_rec.effective_from_date,
          p_effective_to_date  => SYSDATE,
          p_active_flag  => l_ref_pec_rules_rec.active_flag,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => FND_GLOBAL.conc_login_id);


	--  x_object_version_number  => l_object_version_number);
      --
      -- End of API body.

      -- Make the corresponding DOWNGRADE record also end dated when it is deleted.
	-- Invoke table handler(Pv_Pec_Rules_Pkg.Update_Row)
	IF l_ref_pec_rules_rec.change_direction_code='UPGRADE' THEN
   	   from_id_rev := l_ref_pec_rules_rec.change_to_program_id;
           to_id_rev   := l_ref_pec_rules_rec.change_from_program_id ;
         	-- Debug Message
           IF (PV_DEBUG_HIGH_ON) THEN

           PVX_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select DOWNGRADE rule');
           END IF;

   	OPEN c_get_pec_rec_down(from_id_rev, to_id_rev);

         FETCH c_get_pec_rec_down INTO l_ref_pec_rules_rec_down  ;

          If ( c_get_pec_rec_down%NOTFOUND) THEN
   	--PVX_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   	--p_token_name   => 'INFO',
   	--p_token_value  => 'Pec_Rules') ;
   	FND_MESSAGE.set_name('PV', 'PV_MISC_ERROR_GROUP_CREATE');
   	FND_MESSAGE.set_token('ID',to_char(from_id_rev));
   	FND_MESSAGE.set_token('ID',to_char(to_id_rev));
           FND_MSG_PUB.add;
              RAISE FND_API.G_EXC_ERROR;
          END IF;
          -- Debug Message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: - Close Cursor');
          END IF;
          CLOSE     c_get_pec_rec_down;

          for downg in c_get_pec_rec_down(from_id_rev, to_id_rev) LOOP
             Pv_Pec_Rules_Pkg.Update_Row(
                p_enrl_change_rule_id  => downg.enrl_change_rule_id,
                px_object_version_number  => downg.object_version_number,
                p_change_from_program_id  => downg.change_from_program_id,
                p_change_to_program_id  => downg.change_to_program_id,
                p_change_direction_code  => downg.change_direction_code,
                p_effective_from_date  => downg.effective_from_date,
                p_effective_to_date  => SYSDATE,
                p_active_flag  => downg.active_flag,
                p_last_updated_by  => FND_GLOBAL.USER_ID,
                p_last_update_date  => SYSDATE,
                p_last_update_login  => FND_GLOBAL.conc_login_id);

          END LOOP;
      END IF;

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

   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Pec_Rules_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Pec_Rules_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Pec_Rules_PVT;
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
End Delete_Pec_Rules;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Pec_Rules
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
--       p_pec_rules_rec            IN   pec_rules_rec_type  Required
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

PROCEDURE Lock_Pec_Rules(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_enrl_change_rule_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Pec_Rules';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_enrl_change_rule_id                  NUMBER;

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
Pv_Pec_Rules_Pkg.Lock_Row(l_enrl_change_rule_id,p_object_version);


 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  IF (PV_DEBUG_HIGH_ON) THEN

  PVX_UTIlity_PVT.debug_message(l_full_name ||': end');
  END IF;
EXCEPTION

   WHEN PVX_UTIlity_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_UTIlity_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Pec_Rules_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Pec_Rules_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Pec_Rules_PVT;
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
End Lock_Pec_Rules;




PROCEDURE check_Pec_Rules_Uk_Items(
    p_pec_rules_rec               IN   pec_rules_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
	IF (PV_DEBUG_HIGH_ON) THEN

	PVX_UTILITY_PVT.debug_message('Inside check uk 1');
	END IF;

      x_return_status := FND_API.g_ret_sts_success;


      IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_pec_rules_rec.enrl_change_rule_id IS NOT NULL
      THEN
         l_valid_flag := PVX_UTIlity_PVT.check_uniqueness(
         'PV_PG_ENRL_CHANGE_RULES',
         ' enrl_change_rule_id = ''' || p_pec_rules_rec.enrl_change_rule_id ||''''
         );
      END IF;

	IF (PV_DEBUG_HIGH_ON) THEN



	PVX_UTILITY_PVT.debug_message('Inside check uk 2' || l_valid_flag);

	END IF;

      IF l_valid_flag = FND_API.g_false THEN
         --PVX_UTIlity_PVT.Error_Message(p_message_name => 'PV_enrl_change_rule_id_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
--	x_return_status := FND_API.g_ret_sts_success;
      END IF;

      	IF (PV_DEBUG_HIGH_ON) THEN



      	PVX_UTILITY_PVT.debug_message('Inside check uk 3' || l_valid_flag);

      	END IF;


END check_Pec_Rules_Uk_Items;



PROCEDURE check_Pec_Rules_Req_Items(
    p_pec_rules_rec               IN  pec_rules_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_pec_rules_rec.enrl_change_rule_id = FND_API.G_MISS_NUM OR p_pec_rules_rec.enrl_change_rule_id IS NULL THEN
               PVX_UTIlity_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'ENRL_CHANGE_RULE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_pec_rules_rec.object_version_number = FND_API.G_MISS_NUM OR p_pec_rules_rec.object_version_number IS NULL THEN
               PVX_UTIlity_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUMBER' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_pec_rules_rec.change_from_program_id = FND_API.G_MISS_NUM OR p_pec_rules_rec.change_from_program_id IS NULL THEN
               PVX_UTIlity_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'CHANGE_FROM_PROGRAM_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_pec_rules_rec.change_to_program_id = FND_API.G_MISS_NUM OR p_pec_rules_rec.change_to_program_id IS NULL THEN
               PVX_UTIlity_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'CHANGE_TO_PROGRAM_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_pec_rules_rec.change_direction_code = FND_API.g_miss_char OR p_pec_rules_rec.change_direction_code IS NULL THEN
               PVX_UTIlity_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'CHANGE_DIRECTION_CODE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_pec_rules_rec.effective_from_date = FND_API.G_MISS_DATE OR p_pec_rules_rec.effective_from_date IS NULL THEN
               PVX_UTIlity_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'EFFECTIVE_FROM_DATE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_pec_rules_rec.active_flag = FND_API.g_miss_char OR p_pec_rules_rec.active_flag IS NULL THEN
               PVX_UTIlity_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'ACTIVE_FLAG' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


   ELSE


      IF p_pec_rules_rec.enrl_change_rule_id = FND_API.G_MISS_NUM THEN
               PVX_UTIlity_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'ENRL_CHANGE_RULE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_pec_rules_rec.object_version_number = FND_API.G_MISS_NUM THEN
               PVX_UTIlity_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUMBER' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_pec_rules_rec.change_from_program_id = FND_API.G_MISS_NUM THEN
               PVX_UTIlity_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'CHANGE_FROM_PROGRAM_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_pec_rules_rec.change_to_program_id = FND_API.G_MISS_NUM THEN
               PVX_UTIlity_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'CHANGE_TO_PROGRAM_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_pec_rules_rec.change_direction_code = FND_API.g_miss_char THEN
               PVX_UTIlity_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'CHANGE_DIRECTION_CODE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_pec_rules_rec.effective_from_date = FND_API.G_MISS_DATE THEN
               PVX_UTIlity_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'EFFECTIVE_FROM_DATE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_pec_rules_rec.active_flag = FND_API.g_miss_char THEN
               PVX_UTIlity_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'ACTIVE_FLAG' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_Pec_Rules_Req_Items;



PROCEDURE check_Pec_Rules_Fk_Items(
    p_pec_rules_rec IN pec_rules_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Pec_Rules_Fk_Items;



PROCEDURE check_Pec_Rules_Lookup_Items(
    p_pec_rules_rec IN pec_rules_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Pec_Rules_Lookup_Items;



PROCEDURE Check_Pec_Rules_Items (
    P_pec_rules_rec     IN    pec_rules_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

	IF (PV_DEBUG_HIGH_ON) THEN



	PVX_UTILITY_PVT.debug_message('Start  ' );

	END IF;

    l_return_status := FND_API.g_ret_sts_success;
   -- Check Items Uniqueness API calls

   check_Pec_rules_Uk_Items(
      p_pec_rules_rec => p_pec_rules_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Check Items Required/NOT NULL API calls
IF (PV_DEBUG_HIGH_ON) THEN

PVX_UTILITY_PVT.debug_message('Middle 1  ' );
END IF;

   check_pec_rules_req_items(
      p_pec_rules_rec => p_pec_rules_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Foreign Keys API calls

IF (PV_DEBUG_HIGH_ON) THEN



PVX_UTILITY_PVT.debug_message('Middle 2  ' );

END IF;

   check_pec_rules_FK_items(
      p_pec_rules_rec => p_pec_rules_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Lookups

   IF (PV_DEBUG_HIGH_ON) THEN



   PVX_UTILITY_PVT.debug_message('Middle 3  ' );

   END IF;

   check_pec_rules_Lookup_items(
      p_pec_rules_rec => p_pec_rules_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   x_return_status := l_return_status;

   IF (PV_DEBUG_HIGH_ON) THEN



   PVX_UTILITY_PVT.debug_message('Error status is  ' || x_return_status);

   END IF;

END Check_pec_rules_Items;





PROCEDURE Complete_Pec_Rules_Rec (
   p_pec_rules_rec IN pec_rules_rec_type,
   x_complete_rec OUT NOCOPY pec_rules_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM pv_pg_enrl_change_rules
      WHERE enrl_change_rule_id = p_pec_rules_rec.enrl_change_rule_id;
   l_pec_rules_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_pec_rules_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_pec_rules_rec;
   CLOSE c_complete;

   -- enrl_change_rule_id
   IF p_pec_rules_rec.enrl_change_rule_id IS NULL THEN
      x_complete_rec.enrl_change_rule_id := l_pec_rules_rec.enrl_change_rule_id;
   END IF;

   -- object_version_number
   IF p_pec_rules_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_pec_rules_rec.object_version_number;
   END IF;

   -- change_from_program_id
   IF p_pec_rules_rec.change_from_program_id IS NULL THEN
      x_complete_rec.change_from_program_id := l_pec_rules_rec.change_from_program_id;
   END IF;

   -- change_to_program_id
   IF p_pec_rules_rec.change_to_program_id IS NULL THEN
      x_complete_rec.change_to_program_id := l_pec_rules_rec.change_to_program_id;
   END IF;

   -- change_direction_code
   IF p_pec_rules_rec.change_direction_code IS NULL THEN
      x_complete_rec.change_direction_code := l_pec_rules_rec.change_direction_code;
   END IF;

   -- effective_from_date
   IF p_pec_rules_rec.effective_from_date IS NULL THEN
      x_complete_rec.effective_from_date := l_pec_rules_rec.effective_from_date;
   END IF;

   -- effective_to_date
   IF p_pec_rules_rec.effective_to_date IS NULL THEN
      x_complete_rec.effective_to_date := l_pec_rules_rec.effective_to_date;
   END IF;

   -- active_flag
   IF p_pec_rules_rec.active_flag IS NULL THEN
      x_complete_rec.active_flag := l_pec_rules_rec.active_flag;
   END IF;

   -- created_by
   IF p_pec_rules_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_pec_rules_rec.created_by;
   END IF;

   -- creation_date
   IF p_pec_rules_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_pec_rules_rec.creation_date;
   END IF;

   -- last_updated_by
   IF p_pec_rules_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_pec_rules_rec.last_updated_by;
   END IF;

   -- last_update_date
   IF p_pec_rules_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_pec_rules_rec.last_update_date;
   END IF;

   -- last_update_login
   IF p_pec_rules_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_pec_rules_rec.last_update_login;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Pec_Rules_Rec;




PROCEDURE Default_Pec_Rules_Items ( p_pec_rules_rec IN pec_rules_rec_type ,
                                x_pec_rules_rec OUT NOCOPY pec_rules_rec_type )
IS
   l_pec_rules_rec pec_rules_rec_type := p_pec_rules_rec;
BEGIN
   -- Developers should put their code to default the record type
   -- e.g. IF p_campaign_rec.status_code IS NULL
   --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
   --         l_campaign_rec.status_code := 'NEW' ;
   --      END IF ;
   --
   -- NULL ;
   x_pec_rules_rec := l_pec_rules_rec;
END;




PROCEDURE Validate_Pec_Rules(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_pec_rules_rec               IN   pec_rules_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Pec_Rules';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_pec_rules_rec  pec_rules_rec_type;
ld_pec_rules_rec  pec_rules_rec_type;

 BEGIN

      IF (PV_DEBUG_HIGH_ON) THEN



      PVX_UTILITY_PVT.debug_message('Inside Validate ');

      END IF;

      -- Standard Start of API savepoint
      SAVEPOINT validate_pec_rules_;

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

     IF (PV_DEBUG_HIGH_ON) THEN



     PVX_UTILITY_PVT.debug_message('Before JTF comparison ');

     END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_pec_rules_Items(
                 p_pec_rules_rec        => p_pec_rules_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      IF (PV_DEBUG_HIGH_ON) THEN



      PVX_UTILITY_PVT.debug_message('Before JTF comparison : 1');

      END IF;

      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         Default_Pec_Rules_Items (p_pec_rules_rec => p_pec_rules_rec ,
                                x_pec_rules_rec => ld_pec_rules_rec) ;
      END IF ;


	IF (PV_DEBUG_HIGH_ON) THEN





	PVX_UTILITY_PVT.debug_message('Before JTF comparison : 2');


	END IF;

      Complete_pec_rules_Rec(
         p_pec_rules_rec        => ld_pec_rules_rec,
         x_complete_rec        => l_pec_rules_rec
      );

	IF (PV_DEBUG_HIGH_ON) THEN



	PVX_UTILITY_PVT.debug_message('Before JTF comparison : 3');

	END IF;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_pec_rules_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_pec_rules_rec           =>    l_pec_rules_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

	IF (PV_DEBUG_HIGH_ON) THEN



	PVX_UTILITY_PVT.debug_message('Before JTF comparison : 4');

	END IF;

	IF (PV_DEBUG_HIGH_ON) THEN



	PVX_UTILITY_PVT.debug_message('After jtf comparison ');

	END IF;
      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start');
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

   WHEN PVX_UTIlity_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_UTIlity_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Pec_Rules_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Pec_Rules_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Pec_Rules_;
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
End Validate_Pec_Rules;


PROCEDURE Validate_Pec_Rules_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_pec_rules_rec               IN    pec_rules_rec_type
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
END Validate_pec_rules_Rec;

END PV_Pec_Rules_PVT;

/
