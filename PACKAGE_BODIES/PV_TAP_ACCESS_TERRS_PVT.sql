--------------------------------------------------------
--  DDL for Package Body PV_TAP_ACCESS_TERRS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_TAP_ACCESS_TERRS_PVT" as
/* $Header: pvxvtrab.pls 115.1 2003/10/17 09:52:51 rdsharma noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_TAP_ACCESS_TERRS_PVT
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_TAP_ACCESS_TERRS_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvtrab.pls';

PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

-- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
-- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
--
-- Foreward Procedure Declarations
--

-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Tap_Access_Terrs
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
--       p_tap_access_terrs_rec    IN   tap_access_terrs_rec_type  Required
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

PROCEDURE Create_Tap_Access_Terrs(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2 := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2 := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER   := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT  NOCOPY  VARCHAR2,
    x_msg_count                  OUT  NOCOPY  NUMBER,
    x_msg_data                   OUT  NOCOPY  VARCHAR2,
    p_tap_access_terrs_rec  IN   tap_access_terrs_rec_type  := g_miss_tap_access_terrs_rec
)
IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Tap_Access_Terrs';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER ;
   l_partner_access_id         NUMBER;
   l_terr_id                   NUMBER;
   l_dummy                     NUMBER;
   l_err_num                   NUMBER;
   l_err_msg                   VARCHAR2(2000);
   l_return_status             VARCHAR2(1);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Create_Tap_Access_Terrs_Pvt;

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
         PVX_Utility_PVT.debug_message('Private API: ' || l_api_name || ' start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.USER_ID IS NULL
      THEN
         PVX_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug Message
          IF (PV_DEBUG_HIGH_ON) THEN
              PVX_Utility_PVT.debug_message('Private API: Validate_Tap_Access_Terrs');
	  END IF;

          -- Invoke validation procedures
          Validate_Tap_Access_Terrs(
            p_api_version_number   => 1.0,
            p_init_msg_list        => FND_API.G_FALSE,
            p_validation_level     => p_validation_level,
            p_validation_mode      => JTF_PLSQL_API.g_create,
            p_tap_access_terrs_rec => p_tap_access_terrs_rec  ,
            x_return_status        => x_return_status,
            x_msg_count            => x_msg_count,
            x_msg_data             => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

   -- Local variable initialization

      l_partner_access_id := p_tap_access_terrs_rec.partner_access_id;
      l_terr_id := p_tap_access_terrs_rec.terr_id;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_Utility_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(Pv_Territory_Accesses_Pkg.Insert_Row)
      Pv_Tap_Access_Terrs_Pkg.Insert_Row(
          p_partner_access_id  => p_tap_access_terrs_rec.partner_access_id,
          p_terr_id  => p_tap_access_terrs_rec.terr_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_object_version_number  =>  l_object_version_number,
          p_request_id  => p_tap_access_terrs_rec.request_id,
          p_program_application_id  => p_tap_access_terrs_rec.program_application_id,
          p_program_id  => p_tap_access_terrs_rec.program_id,
          p_program_update_date  => p_tap_access_terrs_rec.program_update_date,
	  x_return_status => x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         l_err_msg := substr(to_char(SQLCODE)||'-'||SQLERRM,1,2000);
	 FND_MESSAGE.set_name('PV', 'PV_API_OTHERS_EXCEP');
         FND_MESSAGE.set_token('ERROR', l_err_msg);
	 FND_MSG_PUB.add;
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
	 ELSE
	    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;
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
         PVX_Utility_PVT.debug_message('Private API: ' || l_api_name || 'end');
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
     ROLLBACK TO Create_Tap_Access_Terrs_Pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_Tap_Access_Terrs_Pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Create_Tap_Access_Terrs_Pvt;
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
End Create_Tap_Access_Terrs;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Tap_Access_Terrs
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
--       p_tap_access_terrs_rec  IN   tap_access_terrs_rec_type  Required
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

PROCEDURE Update_Tap_Access_Terrs(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_tap_access_terrs_rec       IN   tap_access_terrs_rec_type
    )
 IS

CURSOR c_get_territory_accesses(cv_partner_access_id NUMBER,cv_terr_id NUMBER) IS
    SELECT *
    FROM  PV_TAP_ACCESS_TERRS
    WHERE  partner_access_id = cv_partner_access_id
    AND  terr_id = cv_terr_id;

L_API_NAME            CONSTANT VARCHAR2(30) := 'Update_Tap_Access_Terrs';
L_API_VERSION_NUMBER  CONSTANT NUMBER   := 1.0;

-- Local Variables
l_object_version_number    NUMBER;
l_partner_access_id        NUMBER;
l_terr_id                  NUMBER;
l_ref_territory_access_rec c_get_Territory_Accesses%ROWTYPE ;
l_tar_tap_access_terrs_rec tap_access_terrs_rec_type := p_tap_access_terrs_rec;
l_rowid  ROWID;
l_err_msg                  VARCHAR(2000);

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Update_Tap_Access_Terrs_Pvt;

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
         PVX_Utility_PVT.debug_message('Private API: ' || l_api_name || ' Start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_Utility_PVT.debug_message('Private API: - Open Cursor to Select');
      END IF;

      OPEN c_get_Territory_Accesses(
		l_tar_tap_access_terrs_rec.partner_access_id ,
      		l_tar_tap_access_terrs_rec.terr_id );

      FETCH c_get_Territory_Accesses INTO l_ref_territory_access_rec  ;

      IF ( c_get_Territory_Accesses%NOTFOUND) THEN
         PVX_Utility_PVT.Error_Message(
             p_message_name => 'API_MISSING_UPDATE_TARGET',
             p_token_name   => 'INFO',
             p_token_value  => 'Territory_Accesses') ;

         RAISE FND_API.G_EXC_ERROR;
      END IF;

    -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
          PVX_Utility_PVT.debug_message('Private API: - Close Cursor c_get_Territory_Accesses;');
      END IF;

      CLOSE     c_get_Territory_Accesses;

      If (l_tar_tap_access_terrs_rec.object_version_number is NULL or
          l_tar_tap_access_terrs_rec.object_version_number = FND_API.G_MISS_NUM ) Then
          PVX_Utility_PVT.Error_Message(
	      p_message_name => 'API_VERSION_MISSING',
              p_token_name   => 'COLUMN',
              p_token_value  => 'OBJECT_VERSION_NUMBER') ;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Check Whether record has been changed by someone else
      If (l_tar_tap_access_terrs_rec.object_version_number <> l_ref_territory_access_rec.object_version_number) Then
          PVX_Utility_PVT.Error_Message(
	      p_message_name => 'API_RECORD_CHANGED',
              p_token_name   => 'INFO',
              p_token_value  => 'Territory_Accesses') ;
          raise FND_API.G_EXC_ERROR;
      End if;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
         -- Debug Message
         IF (PV_DEBUG_HIGH_ON) THEN
            PVX_Utility_PVT.debug_message('Private API: Validate_Territory_Accesses');
	 END IF;

          -- Invoke validation procedures
          Validate_Tap_Access_Terrs(
            p_api_version_number   => 1.0,
            p_init_msg_list        => FND_API.G_FALSE,
            p_validation_level     => p_validation_level,
            p_validation_mode      => JTF_PLSQL_API.g_update,
            p_tap_access_terrs_rec =>  p_tap_access_terrs_rec,
            x_return_status        => x_return_status,
            x_msg_count            => x_msg_count,
            x_msg_data             => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_Utility_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');
      END IF;

      -- Invoke table handler(Pv_Territory_Accesses_Pkg.Update_Row)
      Pv_Tap_Access_Terrs_Pkg.Update_Row(
          p_partner_access_id  => p_tap_access_terrs_rec.partner_access_id,
          p_terr_id  => p_tap_access_terrs_rec.terr_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_object_version_number  => p_tap_access_terrs_rec.object_version_number,
          p_request_id  => p_tap_access_terrs_rec.request_id,
          p_program_application_id  => p_tap_access_terrs_rec.program_application_id,
          p_program_id  => p_tap_access_terrs_rec.program_id,
          p_program_update_date  => p_tap_access_terrs_rec.program_update_date,
	      x_return_status => x_return_status);

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          l_err_msg := substr(to_char(SQLCODE)||'-'||SQLERRM,1,2000);
	  FND_MESSAGE.set_name('PV', 'PV_API_OTHERS_EXCEP');
          FND_MESSAGE.set_token('ERROR', l_err_msg);
	  FND_MSG_PUB.add;
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
	  ELSE
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;
      END IF;
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
          PVX_Utility_PVT.debug_message('Private API: ' || l_api_name || ' End');
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
     ROLLBACK TO Update_Tap_Access_Terrs_Pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Update_Tap_Access_Terrs_Pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Update_Tap_Access_Terrs_Pvt;
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
End Update_Tap_Access_Terrs;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Tap_Access_Terrs
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
--       p_partner_access_id       IN   NUMBER
--       p_terr_id                 IN   NUMBER
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

PROCEDURE Delete_Tap_Access_Terrs(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_partner_access_id	         IN  NUMBER,
    p_terr_id                    IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Tap_Access_Terrs';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_err_msg                  VARCHAR(2000);
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Delete_Tap_Access_Terrs;

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
         PVX_Utility_PVT.debug_message('Private API: ' || l_api_name || ' Start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
          PVX_Utility_PVT.debug_message( 'Private API: Calling delete table handler');
      END IF;

      -- Invoke table handler(Pv_Territory_Accesses_Pkg.Delete_Row)

      Pv_Tap_Access_Terrs_Pkg.Delete_Row(
          p_partner_access_id => p_partner_access_id,
          p_terr_id  => p_terr_id,
          p_object_version_number => p_object_version_number ,
	      x_return_status => x_return_status    );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         l_err_msg := substr(to_char(SQLCODE)||'-'||SQLERRM,1,2000);
         FND_MESSAGE.set_name('PV', 'PV_API_OTHERS_EXCEP');
         FND_MESSAGE.set_token('ERROR', l_err_msg);
	     FND_MSG_PUB.add;
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
	     ELSE
	        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	     END IF;
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
         PVX_Utility_PVT.debug_message('Private API: ' || l_api_name || ' End');
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
     ROLLBACK TO DELETE_Territory_Accesses_Pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Delete_Tap_Access_Terrs_Pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Delete_Tap_Access_Terrs_Pvt;
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

End Delete_Tap_Access_Terrs;

-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Tap_Access_Terrs
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
--       p_tap_access_terrs_rec    IN   tap_access_terrs_rec_type  Required
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

PROCEDURE Lock_Tap_Access_Terrs(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_partner_access_id		IN  NUMBER,
    p_terr_id                   IN  NUMBER,
    p_object_version_number     IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Tap_Access_Terrs';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_partner_access_id	    NUMBER;
l_terr_id                   NUMBER;
l_err_msg                  VARCHAR(2000);
BEGIN
       -- Standard Start of API savepoint
      SAVEPOINT Lock_Tap_Access_Terrs;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_Utility_PVT.debug_message('Private API: ' || l_api_name || 'start');
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
      Pv_Tap_Access_Terrs_Pkg.Lock_Row(
         p_partner_access_id,
	     p_terr_id,
	     p_object_version_number,
     	 x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          l_err_msg := substr(to_char(SQLCODE)||'-'||SQLERRM,1,2000);
	      FND_MESSAGE.set_name('PV', 'PV_API_OTHERS_EXCEP');
          FND_MESSAGE.set_token('ERROR', l_err_msg);
	      FND_MSG_PUB.add;
          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
	      ELSE
	         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	      END IF;
      END IF;

 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);

 -- Debug Message
  IF (PV_DEBUG_HIGH_ON) THEN
     PVX_Utility_PVT.debug_message(l_full_name ||': End');
  END IF;
EXCEPTION
   WHEN PVX_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_Utility_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Lock_Tap_Access_Terrs;
     x_return_status := FND_API.G_RET_STS_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Lock_Tap_Access_Terrs;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Lock_Tap_Access_Terrs;
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
End Lock_Tap_Access_Terrs;

PROCEDURE Chk_Terr_Access_Uk_Items(
    p_tap_access_terrs_rec    IN   tap_access_terrs_rec_type,
    p_validation_mode         IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status           OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1):= 'N';
 CURSOR l_Chk_Terr_Access_Uk_csr(cv_partner_access_id  NUMBER,
                                  cv_terr_id            NUMBER ) IS
  SELECT 'Y'
  FROM   PV_TAP_ACCESS_TERRS
  WHERE  partner_access_id = cv_partner_access_id
  AND    terr_id  = cv_terr_id;

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create AND
         p_tap_access_terrs_rec.partner_access_id IS NOT NULL AND
         p_tap_access_terrs_rec.terr_id IS NOT NULL
      THEN
         OPEN l_Chk_Terr_Access_Uk_csr(p_tap_access_terrs_rec.partner_access_id,
                                       p_tap_access_terrs_rec.terr_id);
         FETCH l_Chk_Terr_Access_Uk_csr INTO l_valid_flag;
         IF (l_Chk_Terr_Access_Uk_csr%FOUND) THEN
             CLOSE l_Chk_Terr_Access_Uk_csr;
             PVX_Utility_PVT.Error_Message(p_message_name => 'PV_DUPLICATE_ID');
             x_return_status := FND_API.g_ret_sts_error;
         ELSE
            CLOSE l_Chk_Terr_Access_Uk_csr;
         END IF;
      END IF;

END Chk_Terr_Access_Uk_Items;

PROCEDURE Chk_Terr_Access_Req_Items(
    p_tap_access_terrs_rec  IN  tap_access_terrs_rec_type,
    p_validation_mode       IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      -- Check for required paramter PARTNER_ACCESS_ID.
      IF p_tap_access_terrs_rec.partner_access_id = FND_API.G_MISS_NUM OR p_tap_access_terrs_rec.partner_access_id IS NULL THEN
         PVX_Utility_PVT.Error_Message('PV_API_MISSING_REQ_COLUMN', 'COLUMN', 'PARTNER_ACCESS_ID' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      -- Check for required paramter TERR_ID.
      IF p_tap_access_terrs_rec.terr_id = FND_API.G_MISS_NUM OR p_tap_access_terrs_rec.terr_id IS NULL THEN
         PVX_Utility_PVT.Error_Message('PV_API_MISSING_REQ_COLUMN', 'COLUMN', 'TERR_ID' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

   ELSE

      -- Check for required paramter PARTNER_ACCESS_ID.
      IF p_tap_access_terrs_rec.partner_access_id = FND_API.G_MISS_NUM THEN
         PVX_Utility_PVT.Error_Message('PV_API_MISSING_REQ_COLUMN', 'COLUMN', 'PARTNER_ACCESS_ID' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      -- Check for required paramter TERR_ID.
      IF p_tap_access_terrs_rec.terr_id = FND_API.G_MISS_NUM THEN
         PVX_Utility_PVT.Error_Message('PV_API_MISSING_REQ_COLUMN', 'COLUMN', 'TERR_ID' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

   END IF;


END Chk_Terr_Access_Req_Items;

PROCEDURE Chk_Terr_Access_Fk_Items(
    p_tap_access_terrs_rec    IN   tap_access_terrs_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
  -- check, the supplied partner_access_id in the PV_PARTNER_ACCESSES table EXISTS.
  CURSOR l_chk_paccess_active_csr(cv_partner_access_id IN NUMBER) IS
     SELECT 'Y'
     FROM pv_partner_accesses
     WHERE partner_access_id = cv_partner_access_id;

  -- check, the supplied territory in the JTF_TERR_ALL table is ACTIVE and EXISTS.
  CURSOR l_chk_terr_active_csr(cv_terr_id IN NUMBER) IS
     SELECT 'Y'
     FROM jtf_terr_all
     WHERE terr_id = cv_terr_id
     AND  nvl(end_date_active , sysdate) >= sysdate;

  -- Local variale declaration.
  l_paccess_exist      VARCHAR2(1) := 'N';
  l_terr_active         VARCHAR2(1) := 'N';
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

  -- check, the supplied partner_access_id exists in the table.
  OPEN l_chk_paccess_active_csr(p_tap_access_terrs_rec.partner_access_id);
  FETCH l_chk_paccess_active_csr INTO l_paccess_exist;

  IF l_chk_paccess_active_csr%NOTFOUND THEN
       CLOSE l_chk_paccess_active_csr ;
       PVX_UTILITY_PVT.Error_Message('PV_NO_RECORD_FOUND');
       x_return_status := FND_API.g_ret_sts_error;
  ELSE
       CLOSE l_chk_paccess_active_csr ;
  END IF;

  -- check, the supplied Territory should exists and Active.
  OPEN l_chk_terr_active_csr(p_tap_access_terrs_rec.terr_id);
  FETCH l_chk_terr_active_csr INTO l_paccess_exist;
  IF l_chk_terr_active_csr%NOTFOUND THEN
       CLOSE l_chk_terr_active_csr ;
       PVX_UTILITY_PVT.Error_Message('PV_TERR_NOT_ACTIVE','TERR_ID',p_tap_access_terrs_rec.terr_id);
       x_return_status := FND_API.g_ret_sts_error;
  ELSE
       CLOSE l_chk_terr_active_csr;
  END IF;

END Chk_Terr_Access_Fk_Items;

PROCEDURE Chk_Tap_Access_Terrs_Items (
    p_tap_access_terrs_rec     IN    tap_access_terrs_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

    l_return_status := FND_API.g_ret_sts_success;
   -- Check Items Uniqueness API calls
   Chk_Terr_Access_Uk_Items(
      p_tap_access_terrs_rec => p_tap_access_terrs_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => l_return_status);
   IF l_return_status <> FND_API.g_ret_sts_success THEN
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Check Items Required/NOT NULL API calls
   Chk_Terr_Access_req_items(
      p_tap_access_terrs_rec => p_tap_access_terrs_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => l_return_status);
   IF l_return_status <> FND_API.g_ret_sts_success THEN
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Check Items Foreign Keys API calls
   Chk_Terr_Access_FK_items(
      p_tap_access_terrs_rec => p_tap_access_terrs_rec,
      x_return_status => l_return_status);
   IF l_return_status <> FND_API.g_ret_sts_success THEN
      x_return_status := FND_API.g_ret_sts_error;
   END IF;

END Chk_Tap_Access_Terrs_Items;

PROCEDURE Complete_Territory_Access_Rec (
   p_tap_access_terrs_rec IN tap_access_terrs_rec_type,
   x_complete_rec OUT NOCOPY tap_access_terrs_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM pv_tap_access_terrs
      WHERE partner_access_id = p_tap_access_terrs_rec.partner_access_id
      AND terr_id = p_tap_access_terrs_rec.terr_id;

   l_tap_access_terrs_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_tap_access_terrs_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_tap_access_terrs_rec;
   CLOSE c_complete;

   -- partner_access_id
   IF p_tap_access_terrs_rec.partner_access_id IS NULL THEN
      x_complete_rec.partner_access_id := l_tap_access_terrs_rec.partner_access_id;
   END IF;

   -- terr_id
   IF p_tap_access_terrs_rec.terr_id IS NULL THEN
      x_complete_rec.terr_id := l_tap_access_terrs_rec.terr_id;
   END IF;

   -- last_update_date
   IF p_tap_access_terrs_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_tap_access_terrs_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_tap_access_terrs_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_tap_access_terrs_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_tap_access_terrs_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_tap_access_terrs_rec.creation_date;
   END IF;

   -- created_by
   IF p_tap_access_terrs_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_tap_access_terrs_rec.created_by;
   END IF;

   -- last_update_login
   IF p_tap_access_terrs_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_tap_access_terrs_rec.last_update_login;
   END IF;

   -- request_id
   IF p_tap_access_terrs_rec.request_id IS NULL THEN
      x_complete_rec.request_id := l_tap_access_terrs_rec.request_id;
   END IF;

   -- program_application_id
   IF p_tap_access_terrs_rec.program_application_id IS NULL THEN
      x_complete_rec.program_application_id := l_tap_access_terrs_rec.program_application_id;
   END IF;

   -- program_id
   IF p_tap_access_terrs_rec.program_id IS NULL THEN
      x_complete_rec.program_id := l_tap_access_terrs_rec.program_id;
   END IF;

   -- program_update_date
   IF p_tap_access_terrs_rec.program_update_date IS NULL THEN
      x_complete_rec.program_update_date := l_tap_access_terrs_rec.program_update_date;
   END IF;

END Complete_Territory_Access_Rec;

PROCEDURE Default_Territory_Access_Items (
              p_tap_access_terrs_rec IN tap_access_terrs_rec_type ,
              x_tap_access_terrs_rec OUT NOCOPY tap_access_terrs_rec_type )
IS
   l_tap_access_terrs_rec tap_access_terrs_rec_type := p_tap_access_terrs_rec;
BEGIN

   IF p_tap_access_terrs_rec.last_update_login IS NULL OR p_tap_access_terrs_rec.last_update_login = FND_API.G_MISS_NUM THEN
            l_tap_access_terrs_rec.last_update_login := FND_GLOBAL.user_id ;
   END IF ;

   IF p_tap_access_terrs_rec.last_update_date IS NULL OR p_tap_access_terrs_rec.last_update_date = FND_API.G_MISS_DATE THEN
            l_tap_access_terrs_rec.last_update_date := sysdate;
   END IF ;

   IF p_tap_access_terrs_rec.last_updated_by IS NULL OR p_tap_access_terrs_rec.last_updated_by = FND_API.G_MISS_NUM THEN
            l_tap_access_terrs_rec.last_updated_by := FND_GLOBAL.user_id  ;
   END IF ;

   IF p_tap_access_terrs_rec.creation_date IS NULL OR p_tap_access_terrs_rec.creation_date = FND_API.G_MISS_DATE THEN
            l_tap_access_terrs_rec.creation_date := sysdate ;
   END IF ;

   IF p_tap_access_terrs_rec.created_by IS NULL OR p_tap_access_terrs_rec.created_by  = FND_API.G_MISS_NUM THEN
            l_tap_access_terrs_rec.created_by  := FND_GLOBAL.user_id ;
   END IF ;

   IF p_tap_access_terrs_rec.object_version_number IS NULL OR p_tap_access_terrs_rec.object_version_number  = FND_API.G_MISS_NUM THEN
            l_tap_access_terrs_rec.object_version_number  := 1 ;
   END IF ;

   x_tap_access_terrs_rec := l_tap_access_terrs_rec;

END;

PROCEDURE Validate_Tap_Access_Terrs(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_validation_mode            IN    VARCHAR2,
    p_tap_access_terrs_rec       IN   tap_access_terrs_rec_type,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Tap_Access_Terrs';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_tap_access_terrs_rec  tap_access_terrs_rec_type ;

 BEGIN
     -- Standard Start of API savepoint
      SAVEPOINT Validate_Tap_Access_Terrs_Pvt;

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

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Chk_Tap_Access_Terrs_Items(
             p_tap_access_terrs_rec => p_tap_access_terrs_rec,
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
         Default_Territory_Access_Items(
             p_tap_access_terrs_rec => p_tap_access_terrs_rec ,
             x_tap_access_terrs_rec => l_tap_access_terrs_rec) ;
      END IF ;

      Complete_territory_access_Rec(
         p_tap_access_terrs_rec => l_tap_access_terrs_rec,
         x_complete_rec         => l_tap_access_terrs_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_Tap_Access_Terrs_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_tap_access_terrs_rec   =>    l_tap_access_terrs_rec);

      IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW) THEN
           PVX_Utility_PVT.debug_message('After Validate_Tap_Access_Terrs_Rec...');
      END IF;

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      -- Debug Message
      PVX_Utility_PVT.debug_message('Private API: ' || l_api_name || 'end');

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
     ROLLBACK TO Validate_Tap_Access_Terrs_Pvt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Validate_Tap_Access_Terrs_Pvt;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Validate_Tap_Access_Terrs_Pvt;
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
End Validate_Tap_Access_Terrs;

PROCEDURE Validate_Tap_Access_Terrs_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT  NOCOPY  VARCHAR2,
    x_msg_count                  OUT  NOCOPY  NUMBER,
    x_msg_data                   OUT  NOCOPY  VARCHAR2,
    p_tap_access_terrs_rec       IN   tap_access_terrs_rec_type
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
      PVX_Utility_PVT.debug_message('Private API: Validate_dm_model_rec');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_Tap_Access_Terrs_Rec;

END PV_TAP_ACCESS_TERRS_PVT;

/
