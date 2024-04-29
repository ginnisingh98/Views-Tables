--------------------------------------------------------
--  DDL for Package Body PV_PARTNER_ACCESSES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PARTNER_ACCESSES_PVT" as
/* $Header: pvxvprab.pls 120.1 2005/09/05 23:50:35 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Partner_Accesses_PVT
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Partner_Accesses_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvprab.pls';

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
--           Create_Partner_Accesses
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
--       p_partner_access_rec            IN   partner_access_rec_type  Required
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

PROCEDURE Create_Partner_Accesses(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_partner_access_rec         IN   partner_access_rec_type  := g_miss_partner_access_rec,
    x_partner_access_id          OUT NOCOPY  NUMBER
 )
 IS
  L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Partner_Accesses';
  L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
  l_return_status_full        VARCHAR2(1);
  l_object_version_number     NUMBER := 1;
  l_org_id                    NUMBER ;
  l_partner_access_id              NUMBER;
  l_dummy                     NUMBER;
  l_err_num                   NUMBER;
  l_err_msg                   VARCHAR2(2000);
  l_return_status             VARCHAR2(1);

   CURSOR c_id IS
      SELECT pv_partner_accesses_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM PV_PARTNER_ACCESSES
      WHERE partner_access_id = l_id;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_partner_accesses_pvt;

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
         PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' start.');
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
             PVX_UTILITY_PVT.debug_message('Private API: Validate_Partner_Accesses.');
	  END IF;

          -- Invoke validation procedures
          Validate_partner_accesses(
            p_api_version_number => 1.0,
            p_init_msg_list      => FND_API.G_FALSE,
            p_validation_level   => p_validation_level,
            p_validation_mode    => JTF_PLSQL_API.g_create,
            p_partner_access_rec =>  p_partner_access_rec,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

   -- Local variable initialization

   IF p_partner_access_rec.partner_access_id IS NULL OR p_partner_access_rec.partner_access_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_partner_access_id;
         CLOSE c_id;

         OPEN c_id_exists(l_partner_access_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
         l_partner_access_id := p_partner_access_rec.partner_access_id;
   END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message( 'Private API: Calling create table handler.');
      END IF;

      -- Invoke table handler(Pv_Partner_Accesses_Pkg.Insert_Row)
      Pv_Partner_Accesses_Pkg.Insert_Row(
          px_partner_access_id  => l_partner_access_id,
          p_partner_id  => p_partner_access_rec.partner_id,
          p_resource_id  => p_partner_access_rec.resource_id,
          p_keep_flag  => p_partner_access_rec.keep_flag,
          p_created_by_tap_flag  => p_partner_access_rec.created_by_tap_flag,
          p_access_type  => p_partner_access_rec.access_type,
          p_vad_partner_id  => p_partner_access_rec.vad_partner_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_object_version_number => p_partner_access_rec.object_version_number,
          p_request_id  => p_partner_access_rec.request_id,
          p_program_application_id  => p_partner_access_rec.program_application_id,
          p_program_id  => p_partner_access_rec.program_id,
          p_program_update_date  => p_partner_access_rec.program_update_date,
          p_attribute_category  => p_partner_access_rec.attribute_category,
          p_attribute1  => p_partner_access_rec.attribute1,
          p_attribute2  => p_partner_access_rec.attribute2,
          p_attribute3  => p_partner_access_rec.attribute3,
          p_attribute4  => p_partner_access_rec.attribute4,
          p_attribute5  => p_partner_access_rec.attribute5,
          p_attribute6  => p_partner_access_rec.attribute6,
          p_attribute7  => p_partner_access_rec.attribute7,
          p_attribute8  => p_partner_access_rec.attribute8,
          p_attribute9  => p_partner_access_rec.attribute9,
          p_attribute10  => p_partner_access_rec.attribute10,
          p_attribute11  => p_partner_access_rec.attribute11,
          p_attribute12  => p_partner_access_rec.attribute12,
          p_attribute13  => p_partner_access_rec.attribute13,
          p_attribute14  => p_partner_access_rec.attribute14,
          p_attribute15  => p_partner_access_rec.attribute15,
	  x_return_status=> x_return_status);

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

      x_partner_access_id := l_partner_access_id;
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
         PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' end.');
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
     ROLLBACK TO CREATE_Partner_Accesses_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Partner_Accesses_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Partner_Accesses_PVT;
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
End Create_Partner_Accesses;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Partner_Accesses
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
--       p_partner_access_rec            IN   partner_access_rec_type  Required
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

PROCEDURE Update_Partner_Accesses(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT  NOCOPY  VARCHAR2,
    x_msg_count                  OUT  NOCOPY  NUMBER,
    x_msg_data                   OUT  NOCOPY  VARCHAR2,
    p_partner_access_rec         IN   partner_access_rec_type
    )

 IS

CURSOR c_get_partner_accesses(cv_partner_access_id NUMBER) IS
    SELECT *
    FROM  PV_PARTNER_ACCESSES
    WHERE  partner_access_id = cv_partner_access_id;

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Partner_Accesses';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

-- Local Variables
l_object_version_number     NUMBER;
l_partner_access_id         NUMBER;
l_ref_partner_access_rec    c_get_Partner_Accesses%ROWTYPE ;
l_tar_partner_access_rec    partner_access_rec_type := P_partner_access_rec;
l_rowid                     ROWID;
l_err_msg                   VARCHAR2(2000);
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_partner_accesses_pvt;

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
          PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Start');
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
      END IF;

      OPEN c_get_Partner_Accesses( l_tar_partner_access_rec.partner_access_id);

      FETCH c_get_Partner_Accesses INTO l_ref_partner_access_rec  ;

      IF ( c_get_Partner_Accesses%NOTFOUND) THEN
           PVX_UTILITY_PVT.Error_Message(
	       p_message_name => 'API_MISSING_UPDATE_TARGET',
               p_token_name   => 'INFO',
               p_token_value  => 'Partner_Accesses') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message('Private API: - Close Cursor c_get_Partner_Accesses');
      END IF;

      CLOSE     c_get_Partner_Accesses;

      IF (l_tar_partner_access_rec.object_version_number is NULL or
          l_tar_partner_access_rec.object_version_number = FND_API.G_MISS_NUM ) THEN
          PVX_UTILITY_PVT.Error_Message(
	      p_message_name => 'API_VERSION_MISSING',
              p_token_name   => 'COLUMN',
              p_token_value  => 'OBJECT_VERSION_NUMBER') ;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Check Whether record has been changed by someone else
      IF (l_tar_partner_access_rec.object_version_number <> l_ref_partner_access_rec.object_version_number) THEN
          PVX_UTILITY_PVT.Error_Message(
              p_message_name => 'API_RECORD_CHANGED',
              p_token_name   => 'INFO',
              p_token_value  => 'Partner_Accesses') ;
          raise FND_API.G_EXC_ERROR;
      End if;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug Message
          IF (PV_DEBUG_HIGH_ON) THEN
              PVX_UTILITY_PVT.debug_message('Private API: Validate_Partner_Accesses');
	  END IF;

          Validate_partner_accesses(
            p_api_version_number => 1.0,
            p_init_msg_list      => FND_API.G_FALSE,
            p_validation_level   => p_validation_level,
            p_partner_access_rec => p_partner_access_rec,
 	    p_validation_mode    => JTF_PLSQL_API.g_update,
            x_return_status      => x_return_status,
	    x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');
      END IF;

      -- Invoke table handler(Pv_Partner_Accesses_Pkg.Update_Row)
      Pv_Partner_Accesses_Pkg.Update_Row(
          p_partner_access_id  => p_partner_access_rec.partner_access_id,
          p_partner_id  => p_partner_access_rec.partner_id,
          p_resource_id  => p_partner_access_rec.resource_id,
          p_keep_flag  => p_partner_access_rec.keep_flag,
          p_created_by_tap_flag  => p_partner_access_rec.created_by_tap_flag,
          p_access_type  => p_partner_access_rec.access_type,
          p_vad_partner_id  => p_partner_access_rec.vad_partner_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_object_version_number => p_partner_access_rec.object_version_number,
          p_request_id  => p_partner_access_rec.request_id,
          p_program_application_id  => p_partner_access_rec.program_application_id,
          p_program_id  => p_partner_access_rec.program_id,
          p_program_update_date  => p_partner_access_rec.program_update_date,
          p_attribute_category  => p_partner_access_rec.attribute_category,
          p_attribute1  => p_partner_access_rec.attribute1,
          p_attribute2  => p_partner_access_rec.attribute2,
          p_attribute3  => p_partner_access_rec.attribute3,
          p_attribute4  => p_partner_access_rec.attribute4,
          p_attribute5  => p_partner_access_rec.attribute5,
          p_attribute6  => p_partner_access_rec.attribute6,
          p_attribute7  => p_partner_access_rec.attribute7,
          p_attribute8  => p_partner_access_rec.attribute8,
          p_attribute9  => p_partner_access_rec.attribute9,
          p_attribute10  => p_partner_access_rec.attribute10,
          p_attribute11  => p_partner_access_rec.attribute11,
          p_attribute12  => p_partner_access_rec.attribute12,
          p_attribute13  => p_partner_access_rec.attribute13,
          p_attribute14  => p_partner_access_rec.attribute14,
          p_attribute15  => p_partner_access_rec.attribute15,
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
          PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' End');
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
     ROLLBACK TO UPDATE_Partner_Accesses_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Partner_Accesses_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Partner_Accesses_PVT;
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
End Update_Partner_Accesses;

--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Partner_Accesses
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
--       p_partner_access_id                IN   NUMBER
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

PROCEDURE Delete_Partner_Accesses(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_partner_access_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Partner_Accesses';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_err_msg                   VARCHAR2(2000);

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_partner_accesses_pvt;

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
          PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Start');
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

      -- Invoke table handler(Pv_Partner_Accesses_Pkg.Delete_Row)
      Pv_Partner_Accesses_Pkg.Delete_Row(
          p_partner_access_id  => p_partner_access_id,
          p_object_version_number => p_object_version_number ,
	  x_return_status      => x_return_status);

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
          PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' End');
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
     ROLLBACK TO DELETE_Partner_Accesses_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Partner_Accesses_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Partner_Accesses_PVT;
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
End Delete_Partner_Accesses;

-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Partner_Accesses
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
--       p_partner_access_rec            IN   partner_access_rec_type  Required
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

PROCEDURE Lock_Partner_Accesses(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_partner_access_id                   IN  NUMBER,
    p_object_version_number             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Partner_Accesses';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_partner_access_id         NUMBER;
l_err_msg                   VARCHAR2(2000);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Lock_Partner_Accesses;

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
      Pv_Partner_Accesses_Pkg.Lock_Row(
         p_partner_access_id,
	     p_object_version_number,
	     x_return_status);

          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
          ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	  END IF;

      -------------------- finish --------------------------

     FND_MSG_PUB.count_and_get(
        p_encoded => FND_API.g_false,
        p_count   => x_msg_count,
        p_data    => x_msg_data);

     -- Debug Message
     IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message(l_full_name ||': End');
     END IF;

EXCEPTION

   WHEN PVX_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO Lock_Partner_Accesses;
    x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Lock_Partner_Accesses;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Lock_Partner_Accesses;
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
End Lock_Partner_Accesses;

PROCEDURE chk_Partner_Access_Uk_Items(
    p_partner_access_rec         IN   partner_access_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create AND
         p_partner_access_rec.partner_access_id IS NOT NULL THEN
         l_valid_flag := PVX_UTILITY_PVT.check_uniqueness(
         'pv_partner_accesses',
         'partner_access_id = ''' || p_partner_access_rec.partner_access_id ||''''
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_DUPLICATE_ID');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

END chk_Partner_Access_Uk_Items;

PROCEDURE chk_partner_access_Req_Items(
    p_partner_access_rec   IN  partner_access_rec_type,
    p_validation_mode      IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status        OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      -- Check for required paramter PARTNER_ID.
      IF p_partner_access_rec.partner_id = FND_API.G_MISS_NUM OR p_partner_access_rec.partner_id IS NULL THEN
         PVX_UTILITY_PVT.Error_Message('PV_API_MISSING_REQ_COLUMN', 'COLUMN', 'PARTNER_ID' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      -- Check for required paramter RESOURCE_ID.
      IF p_partner_access_rec.resource_id = FND_API.G_MISS_NUM OR p_partner_access_rec.resource_id IS NULL THEN
         PVX_UTILITY_PVT.Error_Message('PV_API_MISSING_REQ_COLUMN', 'COLUMN', 'RESOURCE_ID' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      -- Check for required paramter KEEP_FLAG.
      IF p_partner_access_rec.keep_flag = FND_API.g_miss_char OR p_partner_access_rec.keep_flag IS NULL THEN
         PVX_UTILITY_PVT.Error_Message('PV_API_MISSING_REQ_COLUMN', 'COLUMN', 'KEEP_FLAG' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      -- Check for required paramter CREATED_BY_TAP_FLAG.
      IF p_partner_access_rec.created_by_tap_flag = FND_API.g_miss_char OR p_partner_access_rec.created_by_tap_flag IS NULL THEN
         PVX_UTILITY_PVT.Error_Message('PV_API_MISSING_REQ_COLUMN', 'COLUMN', 'CREATED_BY_TAP_FLAG' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      -- Check for required paramter ACCESS_TYPE.
      IF p_partner_access_rec.access_type = FND_API.g_miss_char OR p_partner_access_rec.access_type IS NULL THEN
         PVX_UTILITY_PVT.Error_Message('PV_API_MISSING_REQ_COLUMN', 'COLUMN', 'ACCESS_TYPE' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

   ELSE

      -- Check for PARTNER_ACCESS_ID in case of Update only.
      IF p_partner_access_rec.partner_access_id = FND_API.G_MISS_NUM THEN
         PVX_UTILITY_PVT.Error_Message('PV_API_MISSING_REQ_COLUMN', 'COLUMN', 'PARTNER_ACCESS_ID' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      -- Check for required paramter PARTNER_ID.
      IF p_partner_access_rec.partner_id = FND_API.G_MISS_NUM THEN
         PVX_UTILITY_PVT.Error_Message('PV_API_MISSING_REQ_COLUMN', 'COLUMN', 'PARTNER_ID' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      -- Check for required paramter RESOURCE_ID.
      IF p_partner_access_rec.resource_id = FND_API.G_MISS_NUM THEN
         PVX_UTILITY_PVT.Error_Message('PV_API_MISSING_REQ_COLUMN', 'COLUMN', 'RESOURCE_ID' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      -- Check for required paramter KEEP_FLAG.
      IF p_partner_access_rec.keep_flag = FND_API.g_miss_char THEN
         PVX_UTILITY_PVT.Error_Message('PV_API_MISSING_REQ_COLUMN', 'COLUMN', 'KEEP_FLAG' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      -- Check for required paramter CREATED_BY_TAP_FLAG.
      IF p_partner_access_rec.created_by_tap_flag = FND_API.g_miss_char THEN
         PVX_UTILITY_PVT.Error_Message('PV_API_MISSING_REQ_COLUMN', 'COLUMN', 'CREATED_BY_TAP_FLAG' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

      -- Check for required paramter ACCESS_TYPE.
      IF p_partner_access_rec.access_type = FND_API.g_miss_char THEN
         PVX_UTILITY_PVT.Error_Message('PV_API_MISSING_REQ_COLUMN', 'COLUMN', 'ACCESS_TYPE' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

 END chk_partner_access_Req_Items;

PROCEDURE chk_partner_access_Fk_Items(
    p_partner_access_rec IN partner_access_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
  -- check, the supplied partner in the PV_PARTNER_PROFILES table is ACTIVE and EXISTS.
  CURSOR l_chk_partner_active_csr(cv_partner_id IN NUMBER) IS
     SELECT 'Y'
     FROM pv_partner_profiles
     WHERE partner_id = cv_partner_id
     AND   status = 'A';

  -- check, the supplied resource in the JTF_RS_RESOURCE_EXTNS table is ACTIVE and EXISTS.
  CURSOR l_chk_resource_active_csr(cv_resource_id IN NUMBER) IS
     SELECT 'Y'
     FROM jtf_rs_resource_extns
     WHERE resource_id = cv_resource_id
     AND  nvl(end_date_active , sysdate) >= sysdate;

  -- Local variale declaration.
  l_partner_active      VARCHAR2(1) := 'N';
  l_resource_active     VARCHAR2(1) := 'N';

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

  -- check, the supplied partner is an ACTIVE partner.
  OPEN l_chk_partner_active_csr(p_partner_access_rec.partner_id);
  FETCH l_chk_partner_active_csr INTO l_partner_active;

  IF l_chk_partner_active_csr%NOTFOUND THEN
       CLOSE l_chk_partner_active_csr ;
       PVX_UTILITY_PVT.Error_Message('PV_PARTNER_NOT_ACTIVE');
       x_return_status := FND_API.g_ret_sts_error;
  ELSE
       CLOSE l_chk_partner_active_csr ;
  END IF;

  -- check, whether the supplied Resource is ACTIVE or NOT-ACTIVE.
  OPEN l_chk_resource_active_csr(p_partner_access_rec.resource_id);
  FETCH l_chk_resource_active_csr INTO l_resource_active;

  IF l_chk_resource_active_csr%NOTFOUND THEN
       CLOSE l_chk_resource_active_csr ;
       PVX_UTILITY_PVT.Error_Message('PV_INVALID_RESOURCE_ID');
       x_return_status := FND_API.g_ret_sts_error;
  ELSE
       CLOSE l_chk_resource_active_csr ;
  END IF;

END chk_partner_access_Fk_Items;

PROCEDURE chk_partner_access_Items (
    P_partner_access_rec     IN    partner_access_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

    l_return_status := FND_API.g_ret_sts_success;
   -- Check Items Uniqueness API calls

   chk_Partner_Access_Uk_Items(
      p_partner_access_rec => p_partner_access_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Check Items Required/NOT NULL API calls

   chk_partner_access_req_items(
      p_partner_access_rec => p_partner_access_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Foreign Keys API calls

   chk_partner_access_FK_items(
      p_partner_access_rec => p_partner_access_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Check Items Lookups
   x_return_status := l_return_status;

END chk_partner_access_Items;

PROCEDURE Complete_Partner_Access_Rec (
   p_partner_access_rec IN partner_access_rec_type,
   x_complete_rec OUT NOCOPY partner_access_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM pv_partner_accesses
      WHERE partner_access_id = p_partner_access_rec.partner_access_id;
   l_partner_access_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_partner_access_rec;

   OPEN c_complete;
   FETCH c_complete INTO l_partner_access_rec;
   CLOSE c_complete;

   -- partner_access_id
   IF p_partner_access_rec.partner_access_id IS NULL THEN
      x_complete_rec.partner_access_id := l_partner_access_rec.partner_access_id;
   END IF;

   -- partner_id
   IF p_partner_access_rec.partner_id IS NULL THEN
      x_complete_rec.partner_id := l_partner_access_rec.partner_id;
   END IF;

   -- resource_id
   IF p_partner_access_rec.resource_id IS NULL THEN
      x_complete_rec.resource_id := l_partner_access_rec.resource_id;
   END IF;

   -- keep_flag
   IF p_partner_access_rec.keep_flag IS NULL THEN
      x_complete_rec.keep_flag := l_partner_access_rec.keep_flag;
   END IF;

   -- created_by_tap_flag
   IF p_partner_access_rec.created_by_tap_flag IS NULL THEN
      x_complete_rec.created_by_tap_flag := l_partner_access_rec.created_by_tap_flag;
   END IF;

   -- access_type
   IF p_partner_access_rec.access_type IS NULL THEN
      x_complete_rec.access_type := l_partner_access_rec.access_type;
   END IF;

   -- vad_partner_id
   IF p_partner_access_rec.vad_partner_id IS NULL THEN
      x_complete_rec.vad_partner_id := l_partner_access_rec.vad_partner_id;
   END IF;

   -- last_update_date
   IF p_partner_access_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_partner_access_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_partner_access_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_partner_access_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_partner_access_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_partner_access_rec.creation_date;
   END IF;

   -- created_by
   IF p_partner_access_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_partner_access_rec.created_by;
   END IF;

   -- last_update_login
   IF p_partner_access_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_partner_access_rec.last_update_login;
   END IF;

   -- request_id
   IF p_partner_access_rec.request_id IS NULL THEN
      x_complete_rec.request_id := l_partner_access_rec.request_id;
   END IF;

   -- program_application_id
   IF p_partner_access_rec.program_application_id IS NULL THEN
      x_complete_rec.program_application_id := l_partner_access_rec.program_application_id;
   END IF;

   -- program_id
   IF p_partner_access_rec.program_id IS NULL THEN
      x_complete_rec.program_id := l_partner_access_rec.program_id;
   END IF;

   -- program_update_date
   IF p_partner_access_rec.program_update_date IS NULL THEN
      x_complete_rec.program_update_date := l_partner_access_rec.program_update_date;
   END IF;

   -- attribute_category
   IF p_partner_access_rec.attribute_category IS NULL THEN
      x_complete_rec.attribute_category := l_partner_access_rec.attribute_category;
   END IF;

   -- attribute1
   IF p_partner_access_rec.attribute1 IS NULL THEN
      x_complete_rec.attribute1 := l_partner_access_rec.attribute1;
   END IF;

   -- attribute2
   IF p_partner_access_rec.attribute2 IS NULL THEN
      x_complete_rec.attribute2 := l_partner_access_rec.attribute2;
   END IF;

   -- attribute3
   IF p_partner_access_rec.attribute3 IS NULL THEN
      x_complete_rec.attribute3 := l_partner_access_rec.attribute3;
   END IF;

   -- attribute4
   IF p_partner_access_rec.attribute4 IS NULL THEN
      x_complete_rec.attribute4 := l_partner_access_rec.attribute4;
   END IF;

   -- attribute5
   IF p_partner_access_rec.attribute5 IS NULL THEN
      x_complete_rec.attribute5 := l_partner_access_rec.attribute5;
   END IF;

   -- attribute6
   IF p_partner_access_rec.attribute6 IS NULL THEN
      x_complete_rec.attribute6 := l_partner_access_rec.attribute6;
   END IF;

   -- attribute7
   IF p_partner_access_rec.attribute7 IS NULL THEN
      x_complete_rec.attribute7 := l_partner_access_rec.attribute7;
   END IF;

   -- attribute8
   IF p_partner_access_rec.attribute8 IS NULL THEN
      x_complete_rec.attribute8 := l_partner_access_rec.attribute8;
   END IF;

   -- attribute9
   IF p_partner_access_rec.attribute9 IS NULL THEN
      x_complete_rec.attribute9 := l_partner_access_rec.attribute9;
   END IF;

   -- attribute10
   IF p_partner_access_rec.attribute10 IS NULL THEN
      x_complete_rec.attribute10 := l_partner_access_rec.attribute10;
   END IF;

   -- attribute11
   IF p_partner_access_rec.attribute11 IS NULL THEN
      x_complete_rec.attribute11 := l_partner_access_rec.attribute11;
   END IF;

   -- attribute12
   IF p_partner_access_rec.attribute12 IS NULL THEN
      x_complete_rec.attribute12 := l_partner_access_rec.attribute12;
   END IF;

   -- attribute13
   IF p_partner_access_rec.attribute13 IS NULL THEN
      x_complete_rec.attribute13 := l_partner_access_rec.attribute13;
   END IF;

   -- attribute14
   IF p_partner_access_rec.attribute14 IS NULL THEN
      x_complete_rec.attribute14 := l_partner_access_rec.attribute14;
   END IF;

   -- attribute15
   IF p_partner_access_rec.attribute15 IS NULL THEN
      x_complete_rec.attribute15 := l_partner_access_rec.attribute15;
   END IF;

END Complete_Partner_Access_Rec;

PROCEDURE Default_Partner_Access_Items (
             p_partner_access_rec IN partner_access_rec_type ,
              x_partner_access_rec OUT NOCOPY partner_access_rec_type )
IS
   l_partner_access_rec partner_access_rec_type := p_partner_access_rec;
BEGIN
  -- Some default the setting for different column attributes.
   IF p_partner_access_rec.keep_flag IS NULL OR p_partner_access_rec.keep_flag = FND_API.G_MISS_CHAR THEN
            l_partner_access_rec.keep_flag := 'Y' ;
   END IF ;

   IF p_partner_access_rec.created_by_tap_flag IS NULL OR p_partner_access_rec.created_by_tap_flag = FND_API.G_MISS_CHAR THEN
            l_partner_access_rec.keep_flag := 'Y' ;
   END IF ;

   IF p_partner_access_rec.access_type IS NULL OR p_partner_access_rec.access_type = FND_API.G_MISS_CHAR THEN
            l_partner_access_rec.access_type := 'F' ;
   END IF ;

   x_partner_access_rec := l_partner_access_rec;
END;

PROCEDURE Validate_Partner_Accesses(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_partner_access_rec         IN   partner_access_rec_type,
    p_validation_mode            IN   VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Partner_Accesses';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_partner_access_rec  partner_access_rec_type ;
ld_partner_access_rec  partner_access_rec_type ;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_partner_accesses;

      -- Standard call to check for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || ' Start');
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
           chk_partner_access_Items(
               p_partner_access_rec => p_partner_access_rec,
               p_validation_mode    => p_validation_mode,
               x_return_status      => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         Default_Partner_Access_Items (
	         p_partner_access_rec => p_partner_access_rec ,
                 x_partner_access_rec => ld_partner_access_rec) ;
      END IF ;

     Complete_partner_access_Rec(
         p_partner_access_rec  => ld_partner_access_rec,
         x_complete_rec        => l_partner_access_rec
      );

     IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_partner_access_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_partner_access_rec           =>    l_partner_access_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
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
     ROLLBACK TO VALIDATE_Partner_Accesses;
     x_return_status := FND_API.G_RET_STS_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Partner_Accesses;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Partner_Accesses;
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
End Validate_Partner_Accesses;


PROCEDURE Validate_Partner_Access_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_partner_access_rec         IN    partner_access_rec_type
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

      -- Validate the FLAG value for KEEP_FLAG and CREATED_BY TAP_FLAG
      IF ( p_partner_access_rec.keep_flag <> 'Y' AND p_partner_access_rec.keep_flag <> 'N' ) THEN
           PVX_UTILITY_PVT.Error_Message('PV_INVALID_FLAG');
           x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      IF ( p_partner_access_rec.CREATED_BY_TAP_FLAG <> 'Y' AND p_partner_access_rec.CREATED_BY_TAP_FLAG <> 'N' ) THEN
           PVX_UTILITY_PVT.Error_Message('PV_INVALID_FLAG');
           x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_partner_access_Rec;

END PV_Partner_Accesses_PVT;

/
