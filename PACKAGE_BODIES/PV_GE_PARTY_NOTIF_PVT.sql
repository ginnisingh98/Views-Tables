--------------------------------------------------------
--  DDL for Package Body PV_GE_PARTY_NOTIF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_GE_PARTY_NOTIF_PVT" as
/* $Header: pvxvgpnb.pls 120.1 2005/08/26 10:20:03 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Ge_Party_Notif_PVT
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Ge_Party_Notif_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvgpnb.pls';

-- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
-- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
--
-- Foreward Procedure Declarations
--

PROCEDURE Default_Pgp_Notif_Items (
   p_pgp_notif_rec IN  pgp_notif_rec_type ,
   x_pgp_notif_rec OUT NOCOPY pgp_notif_rec_type
) ;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Ge_Party_Notif
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
--       p_pgp_notif_rec            IN   pgp_notif_rec_type  Required
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

PROCEDURE Create_Ge_Party_Notif(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_pgp_notif_rec              IN   pgp_notif_rec_type  := g_miss_pgp_notif_rec,
    x_party_notification_id              OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Ge_Party_Notif';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_party_notification_id              NUMBER;
   l_dummy                     NUMBER;
   CURSOR c_id IS
      SELECT pv_ge_party_notifications_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM PV_GE_PARTY_NOTIFICATIONS
      WHERE party_notification_id = l_id;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_ge_party_notif_pvt;

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

          PVX_UTILITY_PVT.debug_message('Private API: Validate_Ge_Party_Notif');
          END IF;

          -- Invoke validation procedures
          Validate_ge_party_notif(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_pgp_notif_rec  =>  p_pgp_notif_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

   -- Local variable initialization

   IF p_pgp_notif_rec.party_notification_id IS NULL OR p_pgp_notif_rec.party_notification_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_party_notification_id;
         CLOSE c_id;

         OPEN c_id_exists(l_party_notification_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
         l_party_notification_id := p_pgp_notif_rec.party_notification_id;
   END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(Pv_Ge_Party_Notif_Pkg.Insert_Row)
      Pv_Ge_Party_Notif_Pkg.Insert_Row(
          px_party_notification_id  => l_party_notification_id,
          p_notification_id  => p_pgp_notif_rec.notification_id,
          px_object_version_number  => l_object_version_number,
          p_partner_id  => p_pgp_notif_rec.partner_id,
          p_recipient_user_id  => p_pgp_notif_rec.recipient_user_id,
          p_notif_for_entity_id  => p_pgp_notif_rec.notif_for_entity_id,
          p_arc_notif_for_entity_code  => p_pgp_notif_rec.arc_notif_for_entity_code,
          p_notif_type_code  => p_pgp_notif_rec.notif_type_code,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => FND_GLOBAL.conc_login_id
);

          x_party_notification_id := l_party_notification_id;
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
     ROLLBACK TO CREATE_Ge_Party_Notif_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Ge_Party_Notif_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Ge_Party_Notif_PVT;
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
End Create_Ge_Party_Notif;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Ge_Party_Notif
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
--       p_pgp_notif_rec            IN   pgp_notif_rec_type  Required
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

PROCEDURE Update_Ge_Party_Notif(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_pgp_notif_rec               IN    pgp_notif_rec_type
    )

 IS


CURSOR c_get_ge_party_notif(party_notification_id NUMBER) IS
    SELECT *
    FROM  PV_GE_PARTY_NOTIFICATIONS
    WHERE  party_notification_id = p_pgp_notif_rec.party_notification_id;
    -- Hint: Developer need to provide Where clause


L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Ge_Party_Notif';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_party_notification_id    NUMBER;
l_ref_pgp_notif_rec  c_get_Ge_Party_Notif%ROWTYPE ;
l_tar_pgp_notif_rec  pgp_notif_rec_type := P_pgp_notif_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_ge_party_notif_pvt;

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

      OPEN c_get_Ge_Party_Notif( l_tar_pgp_notif_rec.party_notification_id);

      FETCH c_get_Ge_Party_Notif INTO l_ref_pgp_notif_rec  ;

       If ( c_get_Ge_Party_Notif%NOTFOUND) THEN
  PVX_UTILITY_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Ge_Party_Notif') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (PV_DEBUG_HIGH_ON) THEN

       PVX_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Ge_Party_Notif;


      If (l_tar_pgp_notif_rec.object_version_number is NULL or
          l_tar_pgp_notif_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  PVX_UTILITY_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_pgp_notif_rec.object_version_number <> l_ref_pgp_notif_rec.object_version_number) Then
  PVX_UTILITY_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Ge_Party_Notif') ;
          raise FND_API.G_EXC_ERROR;
      End if;


      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: Validate_Ge_Party_Notif');
          END IF;

          -- Invoke validation procedures
          Validate_ge_party_notif(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_pgp_notif_rec  =>  p_pgp_notif_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message('Private API: Calling update table handler');
      END IF;

      -- Invoke table handler(Pv_Ge_Party_Notif_Pkg.Update_Row)
      Pv_Ge_Party_Notif_Pkg.Update_Row(
          p_party_notification_id  => p_pgp_notif_rec.party_notification_id,
          p_notification_id  => p_pgp_notif_rec.notification_id,
          p_object_version_number  => p_pgp_notif_rec.object_version_number,
          p_partner_id  => p_pgp_notif_rec.partner_id,
          p_recipient_user_id  => p_pgp_notif_rec.recipient_user_id,
          p_notif_for_entity_id  => p_pgp_notif_rec.notif_for_entity_id,
          p_arc_notif_for_entity_code  => p_pgp_notif_rec.arc_notif_for_entity_code,
          p_notif_type_code  => p_pgp_notif_rec.notif_type_code,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => FND_GLOBAL.conc_login_id
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
     ROLLBACK TO UPDATE_Ge_Party_Notif_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Ge_Party_Notif_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Ge_Party_Notif_PVT;
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
End Update_Ge_Party_Notif;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Ge_Party_Notif
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
--       p_party_notification_id                IN   NUMBER
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

PROCEDURE Delete_Ge_Party_Notif(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_party_notification_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Ge_Party_Notif';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_ge_party_notif_pvt;

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

      -- Invoke table handler(Pv_Ge_Party_Notif_Pkg.Delete_Row)
      Pv_Ge_Party_Notif_Pkg.Delete_Row(
          p_party_notification_id  => p_party_notification_id,
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
     ROLLBACK TO DELETE_Ge_Party_Notif_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Ge_Party_Notif_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Ge_Party_Notif_PVT;
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
End Delete_Ge_Party_Notif;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Ge_Party_Notif
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
--       p_pgp_notif_rec            IN   pgp_notif_rec_type  Required
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

PROCEDURE Lock_Ge_Party_Notif(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_party_notification_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Ge_Party_Notif';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_party_notification_id                  NUMBER;

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
Pv_Ge_Party_Notif_Pkg.Lock_Row(l_party_notification_id,p_object_version);


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
     ROLLBACK TO LOCK_Ge_Party_Notif_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Ge_Party_Notif_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Ge_Party_Notif_PVT;
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
End Lock_Ge_Party_Notif;




PROCEDURE check_Pgp_Notif_Uk_Items(
    p_pgp_notif_rec               IN   pgp_notif_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_pgp_notif_rec.party_notification_id IS NOT NULL
      THEN
         l_valid_flag := PVX_UTILITY_PVT.check_uniqueness(
         'pv_ge_party_notifications',
         'party_notification_id = ''' || p_pgp_notif_rec.party_notification_id ||''''
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_party_notification_id_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

END check_Pgp_Notif_Uk_Items;



PROCEDURE check_Pgp_Notif_Req_Items(
    p_pgp_notif_rec               IN  pgp_notif_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

/*
      IF p_pgp_notif_rec.party_notification_id = FND_API.G_MISS_NUM OR p_pgp_notif_rec.party_notification_id IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'PARTY_NOTIFICATION_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
*/

      IF p_pgp_notif_rec.notification_id = FND_API.G_MISS_NUM OR p_pgp_notif_rec.notification_id IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'NOTIFICATION_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

/*
      IF p_pgp_notif_rec.object_version_number = FND_API.G_MISS_NUM OR p_pgp_notif_rec.object_version_number IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUMBER' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
*/

      IF p_pgp_notif_rec.recipient_user_id = FND_API.G_MISS_NUM OR p_pgp_notif_rec.recipient_user_id IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'RECIPIENT_USER_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_pgp_notif_rec.notif_for_entity_id = FND_API.G_MISS_NUM OR p_pgp_notif_rec.notif_for_entity_id IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'NOTIF_FOR_ENTITY_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


   ELSE


      IF p_pgp_notif_rec.party_notification_id = FND_API.G_MISS_NUM THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'PARTY_NOTIFICATION_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_pgp_notif_rec.notification_id = FND_API.G_MISS_NUM THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'NOTIFICATION_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_pgp_notif_rec.object_version_number = FND_API.G_MISS_NUM THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUMBER' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_pgp_notif_rec.recipient_user_id = FND_API.G_MISS_NUM THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'RECIPIENT_USER_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_pgp_notif_rec.notif_for_entity_id = FND_API.G_MISS_NUM THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'NOTIF_FOR_ENTITY_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_Pgp_Notif_Req_Items;



PROCEDURE check_Pgp_Notif_Fk_Items(
    p_pgp_notif_rec IN pgp_notif_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Pgp_Notif_Fk_Items;



PROCEDURE check_Pgp_Notif_Lookup_Items(
    p_pgp_notif_rec IN pgp_notif_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Pgp_Notif_Lookup_Items;



PROCEDURE Check_Pgp_Notif_Items (
    P_pgp_notif_rec     IN    pgp_notif_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

    l_return_status := FND_API.g_ret_sts_success;
   -- Check Items Uniqueness API calls

   check_Pgp_notif_Uk_Items(
      p_pgp_notif_rec => p_pgp_notif_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_pgp_notif_req_items(
      p_pgp_notif_rec => p_pgp_notif_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Foreign Keys API calls

   check_pgp_notif_FK_items(
      p_pgp_notif_rec => p_pgp_notif_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Lookups

   check_pgp_notif_Lookup_items(
      p_pgp_notif_rec => p_pgp_notif_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   x_return_status := l_return_status;

END Check_pgp_notif_Items;





PROCEDURE Complete_Pgp_Notif_Rec (
   p_pgp_notif_rec IN pgp_notif_rec_type,
   x_complete_rec OUT NOCOPY pgp_notif_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM pv_ge_party_notifications
      WHERE party_notification_id = p_pgp_notif_rec.party_notification_id;
   l_pgp_notif_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_pgp_notif_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_pgp_notif_rec;
   CLOSE c_complete;

   -- party_notification_id
   IF p_pgp_notif_rec.party_notification_id IS NULL THEN
      x_complete_rec.party_notification_id := l_pgp_notif_rec.party_notification_id;
   END IF;

   -- notification_id
   IF p_pgp_notif_rec.notification_id IS NULL THEN
      x_complete_rec.notification_id := l_pgp_notif_rec.notification_id;
   END IF;

   -- object_version_number
   IF p_pgp_notif_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_pgp_notif_rec.object_version_number;
   END IF;

   -- partner_id
   IF p_pgp_notif_rec.partner_id IS NULL THEN
      x_complete_rec.partner_id := l_pgp_notif_rec.partner_id;
   END IF;

   -- recipient_user_id
   IF p_pgp_notif_rec.recipient_user_id IS NULL THEN
      x_complete_rec.recipient_user_id := l_pgp_notif_rec.recipient_user_id;
   END IF;

   -- notif_for_entity_id
   IF p_pgp_notif_rec.notif_for_entity_id IS NULL THEN
      x_complete_rec.notif_for_entity_id := l_pgp_notif_rec.notif_for_entity_id;
   END IF;

   -- arc_notif_for_entity_code
   IF p_pgp_notif_rec.arc_notif_for_entity_code IS NULL THEN
      x_complete_rec.arc_notif_for_entity_code := l_pgp_notif_rec.arc_notif_for_entity_code;
   END IF;

   -- notif_type_code
   IF p_pgp_notif_rec.notif_type_code IS NULL THEN
      x_complete_rec.notif_type_code := l_pgp_notif_rec.notif_type_code;
   END IF;

   -- created_by
   IF p_pgp_notif_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_pgp_notif_rec.created_by;
   END IF;

   -- creation_date
   IF p_pgp_notif_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_pgp_notif_rec.creation_date;
   END IF;

   -- last_updated_by
   IF p_pgp_notif_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_pgp_notif_rec.last_updated_by;
   END IF;

   -- last_update_date
   IF p_pgp_notif_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_pgp_notif_rec.last_update_date;
   END IF;

   -- last_update_login
   IF p_pgp_notif_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_pgp_notif_rec.last_update_login;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Pgp_Notif_Rec;




PROCEDURE Default_Pgp_Notif_Items ( p_pgp_notif_rec IN pgp_notif_rec_type ,
                                x_pgp_notif_rec OUT NOCOPY pgp_notif_rec_type )
IS
   l_pgp_notif_rec pgp_notif_rec_type := p_pgp_notif_rec;
BEGIN
   -- Developers should put their code to default the record type
   -- e.g. IF p_campaign_rec.status_code IS NULL
   --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
   --         l_campaign_rec.status_code := 'NEW' ;
   --      END IF ;
   --
   NULL ;
END;




PROCEDURE Validate_Ge_Party_Notif(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_pgp_notif_rec               IN   pgp_notif_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Ge_Party_Notif';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_pgp_notif_rec         pgp_notif_rec_type;
l_pgp_notif_rec_out     pgp_notif_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_ge_party_notif_;

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
              Check_pgp_notif_Items(
                 p_pgp_notif_rec        => p_pgp_notif_rec,
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
         Default_Pgp_Notif_Items (p_pgp_notif_rec => p_pgp_notif_rec ,
                                x_pgp_notif_rec => l_pgp_notif_rec) ;
      END IF ;


      Complete_pgp_notif_Rec(
         p_pgp_notif_rec        => l_pgp_notif_rec,
         x_complete_rec         => l_pgp_notif_rec_out
      );

      l_pgp_notif_rec := l_pgp_notif_rec_out;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_pgp_notif_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_pgp_notif_rec           =>    l_pgp_notif_rec);

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
     ROLLBACK TO VALIDATE_Ge_Party_Notif_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Ge_Party_Notif_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Ge_Party_Notif_;
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
End Validate_Ge_Party_Notif;


PROCEDURE Validate_Pgp_Notif_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_pgp_notif_rec               IN    pgp_notif_rec_type
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
END Validate_pgp_notif_Rec;

END PV_Ge_Party_Notif_PVT;

/
