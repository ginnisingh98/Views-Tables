--------------------------------------------------------
--  DDL for Package Body PV_PG_MEMBERSHIPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PG_MEMBERSHIPS_PVT" as
/* $Header: pvxvmemb.pls 120.6 2006/05/04 13:14:03 dgottlie ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Pg_Memberships_PVT
-- Purpose
--
-- History
--        13-SEP-2005    Karen.Tsao      Removed call to Terminate_Contract API.
--
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Pg_Memberships_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvmemb.pls';

   PV_DEBUG_HIGH_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
   PV_DEBUG_LOW_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
   PV_DEBUG_MEDIUM_ON CONSTANT boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

g_log_level     CONSTANT NUMBER := FND_LOG.LEVEL_ERROR;

-- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
-- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
--
-- Foreward Procedure Declarations
--

FUNCTION isnumber (
   l_value   VARCHAR2
)
   RETURN NUMBER IS
   l_number   NUMBER;
BEGIN
   BEGIN
      l_number := l_value;
   EXCEPTION
      WHEN OTHERS THEN
         RETURN NULL;
   END;

   RETURN l_number;
END isnumber;

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



PROCEDURE Default_Memb_Items (
   p_memb_rec IN  memb_rec_type ,
   x_memb_rec OUT NOCOPY memb_rec_type
) ;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Pg_Memberships
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
--       p_memb_rec            IN   memb_rec_type  Required
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

PROCEDURE Create_Pg_Memberships(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_memb_rec              IN   memb_rec_type  := g_miss_memb_rec,
    x_membership_id              OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Pg_Memberships';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER ;
   l_membership_id              NUMBER;
   l_dummy                     NUMBER;
   CURSOR c_id IS
      SELECT pv_pg_memberships_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM PV_PG_MEMBERSHIPS
      WHERE membership_id = l_id;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_pg_memberships_pvt;

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
      -- Debug Message




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
            -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Private API: Validate_Pg_Memberships');
      END IF;


          -- Invoke validation procedures
          Validate_pg_memberships(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_memb_rec  =>  p_memb_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

   -- Local variable initialization

   IF p_memb_rec.membership_id IS NULL OR p_memb_rec.membership_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_membership_id;
         CLOSE c_id;

         OPEN c_id_exists(l_membership_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
         l_membership_id := p_memb_rec.membership_id;
   END IF;

      -- Debug Message
       IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
       END IF;
      -- Invoke table handler(Pv_Pg_Memberships_Pkg.Insert_Row)
      Pv_Pg_Memberships_Pkg.Insert_Row(
          px_membership_id  => l_membership_id,
          px_object_version_number  => l_object_version_number,
          p_partner_id  => p_memb_rec.partner_id,
          p_program_id  => p_memb_rec.program_id,
          p_start_date  => p_memb_rec.start_date,
          p_original_end_date  => p_memb_rec.original_end_date,
          p_actual_end_date  => p_memb_rec.actual_end_date,
          p_membership_status_code  => p_memb_rec.membership_status_code,
          p_status_reason_code  => p_memb_rec.status_reason_code,
          p_enrl_request_id  => p_memb_rec.enrl_request_id,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
	  p_attribute1 => p_memb_rec.attribute1,
	  p_attribute2 => p_memb_rec.attribute2,
	  p_attribute3 => p_memb_rec.attribute3,
	  p_attribute4 => p_memb_rec.attribute4,
	  p_attribute5 => p_memb_rec.attribute5,
	  p_attribute6 => p_memb_rec.attribute6,
	  p_attribute7 => p_memb_rec.attribute7,
	  p_attribute8 => p_memb_rec.attribute8,
	  p_attribute9 => p_memb_rec.attribute9,
	  p_attribute10 => p_memb_rec.attribute10,
	  p_attribute11 => p_memb_rec.attribute11,
	  p_attribute12 => p_memb_rec.attribute12,
	  p_attribute13 => p_memb_rec.attribute13,
	  p_attribute14 => p_memb_rec.attribute14,
	  p_attribute15 => p_memb_rec.attribute15
);

          x_membership_id := l_membership_id;
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
     ROLLBACK TO CREATE_Pg_Memberships_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Pg_Memberships_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Pg_Memberships_PVT;
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
End Create_Pg_Memberships;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Pg_Memberships
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
--       p_memb_rec            IN   memb_rec_type  Required
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

PROCEDURE Update_Pg_Memberships(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_memb_rec               IN    memb_rec_type
    )

 IS


CURSOR c_get_pg_memberships(membership_id NUMBER) IS
    SELECT *
    FROM  PV_PG_MEMBERSHIPS
    WHERE  membership_id = p_memb_rec.membership_id;
    -- Hint: Developer need to provide Where clause


L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Pg_Memberships';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_membership_id    NUMBER;
l_ref_memb_rec  c_get_Pg_Memberships%ROWTYPE ;
l_tar_memb_rec  memb_rec_type := P_memb_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_pg_memberships_pvt;

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



      OPEN c_get_Pg_Memberships( l_tar_memb_rec.membership_id);

      FETCH c_get_Pg_Memberships INTO l_ref_memb_rec  ;

       If ( c_get_Pg_Memberships%NOTFOUND) THEN
  PVX_UTILITY_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Pg_Memberships') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message

       CLOSE     c_get_Pg_Memberships;


      If (l_tar_memb_rec.object_version_number is NULL or
          l_tar_memb_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  PVX_UTILITY_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_memb_rec.object_version_number <> l_ref_memb_rec.object_version_number) Then
  PVX_UTILITY_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Pg_Memberships') ;
          raise FND_API.G_EXC_ERROR;
      End if;

       -- Invoke table handler(Pv_Pg_Memberships_Pkg.Update_Row)
      IF p_memb_rec.original_end_date < l_ref_memb_rec.start_date THEN

           FND_MESSAGE.set_name('PV', 'PV_END_DATE_SMALL_START_DATE');
           FND_MSG_PUB.add;
           RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message

      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Private API: Validate_Pg_Memberships');
      END IF;


          -- Invoke validation procedures
          Validate_pg_memberships(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_memb_rec  =>  p_memb_rec,
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





      Pv_Pg_Memberships_Pkg.Update_Row(
          p_membership_id  => p_memb_rec.membership_id,
          p_object_version_number  => p_memb_rec.object_version_number,
          p_partner_id  => p_memb_rec.partner_id,
          p_program_id  => p_memb_rec.program_id,
          p_start_date  => p_memb_rec.start_date,
          p_original_end_date  => p_memb_rec.original_end_date,
          p_actual_end_date  => p_memb_rec.actual_end_date,
          p_membership_status_code  => p_memb_rec.membership_status_code,
          p_status_reason_code  => p_memb_rec.status_reason_code,
          p_enrl_request_id  => p_memb_rec.enrl_request_id,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
	  p_attribute1 => p_memb_rec.attribute1,
	  p_attribute2 => p_memb_rec.attribute2,
	  p_attribute3 => p_memb_rec.attribute3,
	  p_attribute4 => p_memb_rec.attribute4,
	  p_attribute5 => p_memb_rec.attribute5,
	  p_attribute6 => p_memb_rec.attribute6,
	  p_attribute7 => p_memb_rec.attribute7,
	  p_attribute8 => p_memb_rec.attribute8,
	  p_attribute9 => p_memb_rec.attribute9,
	  p_attribute10 => p_memb_rec.attribute10,
	  p_attribute11 => p_memb_rec.attribute11,
	  p_attribute12 => p_memb_rec.attribute12,
	  p_attribute13 => p_memb_rec.attribute13,
	  p_attribute14 => p_memb_rec.attribute14,
	  p_attribute15 => p_memb_rec.attribute15
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
     ROLLBACK TO UPDATE_Pg_Memberships_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Pg_Memberships_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Pg_Memberships_PVT;
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
End Update_Pg_Memberships;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Pg_Memberships
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
--       p_membership_id                IN   NUMBER
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

PROCEDURE Delete_Pg_Memberships(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_membership_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Pg_Memberships';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_pg_memberships_pvt;

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

      -- Invoke table handler(Pv_Pg_Memberships_Pkg.Delete_Row)
      Pv_Pg_Memberships_Pkg.Delete_Row(
          p_membership_id  => p_membership_id,
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
     ROLLBACK TO DELETE_Pg_Memberships_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Pg_Memberships_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Pg_Memberships_PVT;
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
End Delete_Pg_Memberships;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Pg_Memberships
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
--       p_memb_rec            IN   memb_rec_type  Required
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

PROCEDURE Lock_Pg_Memberships(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_membership_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Pg_Memberships';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_membership_id                  NUMBER;

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
Pv_Pg_Memberships_Pkg.Lock_Row(l_membership_id,p_object_version);


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
     ROLLBACK TO LOCK_Pg_Memberships_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Pg_Memberships_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Pg_Memberships_PVT;
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
End Lock_Pg_Memberships;




PROCEDURE check_Memb_Uk_Items(
    p_memb_rec               IN   memb_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_memb_rec.membership_id IS NOT NULL
      THEN
         l_valid_flag := PVX_UTILITY_PVT.check_uniqueness(
         'pv_pg_memberships',
         'membership_id = ''' || p_memb_rec.membership_id ||''''
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_membership_id_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

END check_Memb_Uk_Items;



PROCEDURE check_Memb_Req_Items(
    p_memb_rec               IN  memb_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      /**
      IF p_memb_rec.membership_id = FND_API.G_MISS_NUM OR p_memb_rec.membership_id IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'MEMBERSHIP_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_memb_rec.object_version_number = FND_API.G_MISS_NUM OR p_memb_rec.object_version_number IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUMBER' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
      */

      IF p_memb_rec.partner_id = FND_API.G_MISS_NUM OR p_memb_rec.partner_id IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'PARTNER_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_memb_rec.program_id = FND_API.G_MISS_NUM OR p_memb_rec.program_id IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'PROGRAM_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_memb_rec.start_date = FND_API.G_MISS_DATE OR p_memb_rec.start_date IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'START_DATE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_memb_rec.membership_status_code = FND_API.g_miss_char OR p_memb_rec.membership_status_code IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'MEMBERSHIP_STATUS_CODE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_memb_rec.enrl_request_id = FND_API.G_MISS_NUM OR p_memb_rec.enrl_request_id IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'ENRL_REQUEST_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


   ELSE


      IF p_memb_rec.membership_id = FND_API.G_MISS_NUM THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'MEMBERSHIP_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_memb_rec.object_version_number = FND_API.G_MISS_NUM THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUMBER' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_memb_rec.partner_id = FND_API.G_MISS_NUM THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'PARTNER_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_memb_rec.program_id = FND_API.G_MISS_NUM THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'PROGRAM_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_memb_rec.start_date = FND_API.G_MISS_DATE THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'START_DATE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_memb_rec.membership_status_code = FND_API.g_miss_char THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'MEMBERSHIP_STATUS_CODE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_memb_rec.enrl_request_id = FND_API.G_MISS_NUM THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'ENRL_REQUEST_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_Memb_Req_Items;



PROCEDURE check_Memb_Fk_Items(
    p_memb_rec IN memb_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Memb_Fk_Items;



PROCEDURE check_Memb_Lookup_Items(
    p_memb_rec IN memb_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
l_exists VARCHAR2(1);
l_lookup_type VARCHAR2(30);
l_lookup_exists  VARCHAR2(1);
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
   --validate lookup
   /**l_lookup_type := 'PV_MEMB_STATUS_REASON_CODE';
   l_lookup_exists := PVX_UTILITY_PVT.check_lookup_exists
                      (   p_lookup_table_name => 'PV_LOOKUPS'
                         ,p_lookup_type => l_lookup_type
                         ,p_lookup_code => p_memb_rec.status_reason_code
                       );
   IF NOT FND_API.to_boolean(l_lookup_exists) THEN
      x_return_status := FND_API.g_ret_sts_error;
      FND_MESSAGE.set_name('PV', 'PV_INVALID_LOOKUP_CODE');
      FND_MESSAGE.set_token('LOOKUP_TYPE', l_lookup_type );
      FND_MESSAGE.set_token('LOOKUP_CODE', p_memb_rec.status_reason_code  );
      FND_MSG_PUB.add;
   END IF;
     */

   -- Enter custom code here

END check_Memb_Lookup_Items;



PROCEDURE Check_Memb_Items (
    P_memb_rec     IN    memb_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

    l_return_status := FND_API.g_ret_sts_success;
   -- Check Items Uniqueness API calls

   check_Memb_Uk_Items(
      p_memb_rec => p_memb_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_memb_req_items(
      p_memb_rec => p_memb_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Foreign Keys API calls

   check_memb_FK_items(
      p_memb_rec => p_memb_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Lookups

   check_memb_Lookup_items(
      p_memb_rec => p_memb_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   x_return_status := l_return_status;

END Check_memb_Items;





PROCEDURE Complete_Memb_Rec (
   p_memb_rec IN memb_rec_type,
   x_complete_rec OUT NOCOPY memb_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM pv_pg_memberships
      WHERE membership_id = p_memb_rec.membership_id;
   l_memb_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_memb_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_memb_rec;
   CLOSE c_complete;

   -- membership_id
   IF p_memb_rec.membership_id IS NULL THEN
      x_complete_rec.membership_id := l_memb_rec.membership_id;
   END IF;

   -- object_version_number
   IF p_memb_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_memb_rec.object_version_number;
   END IF;

   -- partner_id
   IF p_memb_rec.partner_id IS NULL THEN
      x_complete_rec.partner_id := l_memb_rec.partner_id;
   END IF;

   -- program_id
   IF p_memb_rec.program_id IS NULL THEN
      x_complete_rec.program_id := l_memb_rec.program_id;
   END IF;

   -- start_date
   IF p_memb_rec.start_date IS NULL THEN
      x_complete_rec.start_date := l_memb_rec.start_date;
   END IF;

   -- original_end_date
   IF p_memb_rec.original_end_date IS NULL THEN
      x_complete_rec.original_end_date := l_memb_rec.original_end_date;
   END IF;

   -- actual_end_date
   IF p_memb_rec.actual_end_date IS NULL THEN
      x_complete_rec.actual_end_date := l_memb_rec.actual_end_date;
   END IF;

   -- membership_status_code
   IF p_memb_rec.membership_status_code IS NULL THEN
      x_complete_rec.membership_status_code := l_memb_rec.membership_status_code;
   END IF;

   -- status_reason_code
   IF p_memb_rec.status_reason_code IS NULL THEN
      x_complete_rec.status_reason_code := l_memb_rec.status_reason_code;
   END IF;

   -- enrl_request_id
   IF p_memb_rec.enrl_request_id IS NULL THEN
      x_complete_rec.enrl_request_id := l_memb_rec.enrl_request_id;
   END IF;

   -- created_by
   IF p_memb_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_memb_rec.created_by;
   END IF;

   -- creation_date
   IF p_memb_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_memb_rec.creation_date;
   END IF;

   -- last_updated_by
   IF p_memb_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_memb_rec.last_updated_by;
   END IF;

   -- last_update_date
   IF p_memb_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_memb_rec.last_update_date;
   END IF;

   -- last_update_login
   IF p_memb_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_memb_rec.last_update_login;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Memb_Rec;




PROCEDURE Default_Memb_Items ( p_memb_rec IN memb_rec_type ,
                                x_memb_rec OUT NOCOPY memb_rec_type )
IS
   l_memb_rec memb_rec_type := p_memb_rec;
BEGIN
   -- Developers should put their code to default the record type
   -- e.g. IF p_campaign_rec.status_code IS NULL
   --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
   --         l_campaign_rec.status_code := 'NEW' ;
   --      END IF ;
   --
   NULL ;
END;




PROCEDURE Validate_Pg_Memberships(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_memb_rec               IN   memb_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Pg_Memberships';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_memb_rec        memb_rec_type;
l_memb_rec_out    memb_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_pg_memberships_;

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
              Check_memb_Items(
                 p_memb_rec        => p_memb_rec,
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
         Default_Memb_Items (p_memb_rec => p_memb_rec ,
                                x_memb_rec => l_memb_rec) ;
      END IF ;


      Complete_memb_Rec(
         p_memb_rec            => l_memb_rec,
         x_complete_rec        => l_memb_rec_out
      );

      l_memb_rec := l_memb_rec_out;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_memb_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_memb_rec           =>    l_memb_rec);

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

      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
      END IF;
      -- Debug Message



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
     ROLLBACK TO VALIDATE_Pg_Memberships_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Pg_Memberships_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Pg_Memberships_;
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
End Validate_Pg_Memberships;


PROCEDURE Validate_Memb_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_memb_rec               IN    memb_rec_type
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
       -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_memb_Rec;

--------------------------------------------------------------------------

 --------------------------------------------------------------------------
   FUNCTION isTerminatable(p_program_id IN NUMBER,p_partner_id IN NUMBER)
   RETURN   BOOLEAN IS

   l_default_program_id NUMBER;
   l_isterminatable boolean:=true;
   l_relationship  VARCHAR2(15);

   CURSOR pstatus_cur(p_ptr_id NUMBER) IS
   SELECT status
   FROM   pv_partner_profiles
   WHERE  partner_id=p_ptr_id;

   BEGIN
      l_default_program_id:= isnumber(FND_PROFILE.VALUE('PV_PARTNER_DEFAULT_PROGRAM'));
      IF  (l_default_program_id is NOT NULL) AND (l_default_program_id =p_program_id) THEN
         OPEN pstatus_cur(p_partner_id);
            FETCH pstatus_cur into l_relationship;
         CLOSE pstatus_cur;

         IF l_relationship='I' THEN
            l_isterminatable:=true;
         ELSE
            l_isterminatable:=false;
         END IF;
      END IF;
      RETURN   l_isterminatable;

   EXCEPTION
      WHEN OTHERS THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

   END isTerminatable;

   -------------------------------------------------------------------------------

----------------------
   -- PROCEDURE
   --   cancel_all_enrollments
   --
   -- PURPOSE
   --   Terminate one membership given the membership_id. This is also a private procedure
   --   this procedure terminates the contract as well as send terminate notifictaion
   --   and also log into history
   --   but does not terminate deafault program membeship unless the partnership is terminated
   --   also terminate pre-reqs if any
   -- IN
   --   partner_id NUMBER
   --
   -- USED BY
   --
   --
   -- HISTORY
   --           pukken        CREATION
   --------------------------------------------------------------------------

PROCEDURE cancel_all_enrollments
(
    p_enrollment_id_tbl              IN   JTF_NUMBER_TABLE
   , p_status_reason_code            IN   VARCHAR2 -- pass 'MEMBER_TYPE_CHANGE' if it is happening because of member type change -- it validates against PV_MEMB_STATUS_REASON_CODE
   , p_comments                      IN   VARCHAR2 DEFAULT NULL -- pass 'Membership terminated by system as member type is changed' if it is changed because of member type change
   , x_return_status                 OUT  NOCOPY  VARCHAR2
   , x_msg_count                     OUT  NOCOPY  NUMBER
   , x_msg_data                      OUT  NOCOPY  VARCHAR2

)
IS

   l_enrl_request_rec      PV_Pg_Enrl_Requests_PVT.enrl_request_rec_type ;
   l_param_tbl_var         PVX_UTILITY_PVT.log_params_tbl_type;
   l_object_version_number NUMBER;
   l_partner_id            NUMBER;
   l_enrl_request_id       NUMBER;
   l_meaning               VARCHAR2(80);
   l_program_name          VARCHAR2(80);

   CURSOR enrq_csr (enrl_id NUMBER ) IS
   SELECT enrq.enrl_request_id
          , enrq.partner_id
          , enrq.object_version_number
          , prgm.program_name
   FROM   pv_pg_enrl_requests enrq
          , pv_partner_program_vl prgm
   WHERE  enrq.enrl_request_id=enrl_id
   AND    enrq.program_id=prgm.program_id;

BEGIN

   x_return_status := FND_API.g_ret_sts_success;
   IF p_enrollment_id_tbl.exists(1) THEN
      FOR i in 1.. p_enrollment_id_tbl.count() LOOP


         OPEN enrq_csr(p_enrollment_id_tbl(i));
               FETCH enrq_csr into l_enrl_request_id,l_partner_id,l_object_version_number,l_program_name;
         CLOSE enrq_csr;
         l_enrl_request_rec.enrl_request_id:= l_enrl_request_id;
         l_enrl_request_rec.object_version_number:=l_object_version_number;
         l_enrl_request_rec.request_status_code:='CANCELLED';

         PV_Pg_Enrl_Requests_PVT.Update_Pg_Enrl_Requests
         (   p_api_version_number      => 1.0
             ,p_init_msg_list         => Fnd_Api.g_false
             ,p_commit                => Fnd_Api.g_false
             ,x_return_status         => x_return_status
             ,x_msg_count             => x_msg_count
             ,x_msg_data              => x_msg_data
             ,p_enrl_request_rec      => l_enrl_request_rec
         );


         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         PVX_UTILITY_PVT.get_lookup_meaning
         (
            p_lookup_type     => 'PV_MEMB_STATUS_REASON_CODE'
            , p_lookup_code   => p_status_reason_code
            , x_return_status => x_return_status
            , x_meaning       => l_meaning
         );
         l_param_tbl_var(1).param_name := 'PROGRAM_NAME';
         l_param_tbl_var(1).param_value := l_program_name;

         l_param_tbl_var(2).param_name := 'STATUS_REASON_CODE';
         l_param_tbl_var(2).param_value := l_meaning ;

         PVX_UTILITY_PVT.create_history_log
         (
            p_arc_history_for_entity_code   => 'ENRQ'
            , p_history_for_entity_id       => l_enrl_request_id
            , p_history_category_code       => 'ENROLLMENT'
            , p_message_code                => 'PV_ENRL_CANCELLED'
            , p_comments                    => p_comments
            , p_partner_id                  => l_partner_id
            , p_access_level_flag           => 'P'
            , p_interaction_level           => PVX_Utility_PVT.G_INTERACTION_LEVEL_10
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

          PVX_UTILITY_PVT.create_history_log
         (
            p_arc_history_for_entity_code   => 'MEMBERSHIP'
            , p_history_for_entity_id       => l_enrl_request_id
            , p_history_category_code       => 'ENROLLMENT'
            , p_message_code                => 'PV_ENRL_CANCELLED'
            , p_comments                    => p_comments
            , p_partner_id                  => l_partner_id
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
   END IF; -- end of if if atleast one membership id exists in the passed in table

END  cancel_all_enrollments;

------------------------------------------------------------
   -- PROCEDURE
   --   term_all_memberships
   --
   -- PURPOSE
   --   Terminate one membership given the membership_id. This is also a private procedure
   --   this procedure terminates the contract as well as send terminate notifictaion
   --   and also log into history
   --   but does not terminate deafault program membeship unless the partnership is terminated
   --   also terminate pre-reqs if any
   -- IN
   --   partner_id NUMBER
   --
   -- USED BY
   --
   --
   -- HISTORY
   --           pukken        CREATION
   --------------------------------------------------------------------------

PROCEDURE term_all_memberships
(
   p_membership_table                IN   JTF_NUMBER_TABLE
   , p_event_code                    IN   VARCHAR2
   , p_status_reason_code            IN   VARCHAR2
   , p_message_code                  IN   VARCHAR2
   , p_comments                      IN   VARCHAR2 DEFAULT NULL
   , x_return_status                 OUT  NOCOPY  VARCHAR2
   , x_msg_count                     OUT  NOCOPY  NUMBER
   , x_msg_data                      OUT  NOCOPY  VARCHAR2

)  IS

   CURSOR pstatus_cur(p_ptr_id NUMBER) IS
   SELECT status
   FROM   pv_partner_profiles
   WHERE  partner_id=p_ptr_id;

   CURSOR contract_cur(mmbr_id NUMBER) IS
   SELECT contract_id
   FROM   pv_pg_enrl_requests enrq, pv_pg_memberships memb
   WHERE  memb.membership_id=mmbr_id
   AND    memb.enrl_request_id=enrq.enrl_request_id;

   CURSOR memb_cur (mmbr_id NUMBER ) IS
   SELECT memb.partner_id
          , memb.program_id
          , memb.object_version_number
          , memb.enrl_request_id
          , prgm.program_name
   FROM	  pv_pg_memberships memb
          , pv_partner_program_vl prgm
   WHERE  memb.membership_id=mmbr_id
   AND    memb.program_id=prgm.program_id;


   l_isterminatable         boolean:=true;
   l_object_version_number  NUMBER;
   l_defult_program_id      NUMBER;
   l_partner_id             NUMBER;
   l_temp_partner_id        NUMBER;
   l_program_id             NUMBER;
   l_enrl_request_id        NUMBER;
   l_program_name           VARCHAR2(80);
   l_relationship           VARCHAR2(60);
   l_meaning                VARCHAR2(80);
   l_pv_pg_memb_rec         memb_rec_type;
   l_notif_event_code       VARCHAR2(30);
   l_param_tbl_var         PVX_UTILITY_PVT.log_params_tbl_type;
BEGIN

   -- get the  partner status from partner_profiles table
   -- if partner _relationship is terminated then terminate the default membership also.
   --get the program_id of the membership we are terminateing l_program_id
   -- if the progr
   -- update membership record  and call responsiblity management
   -- set the membership record to be updated
   x_return_status := FND_API.g_ret_sts_success;
   IF p_membership_table.exists(1) THEN
      FOR i in 1.. p_membership_table.count() LOOP

         OPEN memb_cur(p_membership_table(i));
               FETCH memb_cur into l_partner_id,l_program_id,l_object_version_number,l_enrl_request_id,l_program_name;
         CLOSE memb_cur;
         -- update the memberships table
         l_pv_pg_memb_rec.membership_id := p_membership_table(i);
         l_pv_pg_memb_rec.actual_end_date := sysdate;
         l_pv_pg_memb_rec.membership_status_code := p_event_code;
         l_pv_pg_memb_rec.status_reason_code := p_status_reason_code;
         l_pv_pg_memb_rec.object_version_number:= l_object_version_number;
         Update_Pg_Memberships
         (    p_api_version_number     => 1.0
             , p_init_msg_list         => Fnd_Api.g_false
             , p_commit                => Fnd_Api.g_false
             , x_return_status         => x_return_status
             , x_msg_count             => x_msg_count
             , x_msg_data              => x_msg_data
             , p_memb_rec              => l_pv_pg_memb_rec
         );
         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         IF p_event_code <> 'DOWNGRADED' THEN

            -- call responsibility management api
            Pv_User_Resp_Pvt.manage_memb_resp
            (    p_api_version_number     => 1.0
                , p_init_msg_list         => Fnd_Api.g_false
                , p_commit                => Fnd_Api.g_false
                , p_membership_id         => p_membership_table(i)
                , x_return_status         => x_return_status
                , x_msg_count             => x_msg_count
                , x_msg_data              => x_msg_data
            );

            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;

        END IF;

         -- write to the logs and set the message tokens
         l_param_tbl_var(1).param_name := 'PROGRAM_NAME';
         l_param_tbl_var(1).param_value := l_program_name;

         PVX_UTILITY_PVT.get_lookup_meaning
         (
            p_lookup_type     => 'PV_MEMBERSHIP_STATUS'
            , p_lookup_code   => p_event_code
            , x_return_status => x_return_status
            , x_meaning       => l_meaning
         );

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;
         l_param_tbl_var(2).param_name := 'EVENT';
         l_param_tbl_var(2).param_value := l_meaning;
         l_meaning:=null;

         PVX_UTILITY_PVT.get_lookup_meaning
         (
            p_lookup_type     => 'PV_MEMB_STATUS_REASON_CODE'
            , p_lookup_code   => p_status_reason_code
            , x_return_status => x_return_status
            , x_meaning       => l_meaning
         );


         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
             RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

         l_param_tbl_var(3).param_name := 'STATUS_REASON_CODE';
         l_param_tbl_var(3).param_value := l_meaning;
         PVX_UTILITY_PVT.create_history_log
         (
            p_arc_history_for_entity_code   => 'ENRQ'
            , p_history_for_entity_id       => l_enrl_request_id
            , p_history_category_code       => 'ENROLLMENT'
            , p_message_code                => 'PV_MEMBERSHIP_STATUS_CHANGE'
            , p_comments                    => p_comments
            , p_partner_id                  => l_partner_id
            , p_access_level_flag           => 'P'
            , p_interaction_level           => PVX_Utility_PVT.G_INTERACTION_LEVEL_10
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
         PVX_UTILITY_PVT.create_history_log
         (
            p_arc_history_for_entity_code   => 'MEMBERSHIP'
            , p_history_for_entity_id       => l_enrl_request_id
            , p_history_category_code       => 'ENROLLMENT'
            , p_message_code                => 'PV_MEMBERSHIP_STATUS_CHANGE'
            , p_comments                    => p_comments
            , p_partner_id                  => l_partner_id
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

         IF p_status_reason_code = 'TERMINATED_BY_GLOBAL' THEN
            l_notif_event_code := 'GLOBAL_TERMINATE_SUBSIDIARY';
         ELSE
           l_notif_event_code := 'PG_TERMINATE';
         END IF;
         -- we do not want to send notification from here if membership is downgraded
         -- it will be send from the downgrade_membership api.
         IF p_event_code <> 'DOWNGRADED' THEN

            PV_PG_NOTIF_UTILITY_PVT.Send_Workflow_Notification
            (
               p_api_version_number    => 1.0
               , p_init_msg_list       => Fnd_Api.g_false
               , p_commit              => Fnd_Api.g_false
               , p_validation_level    => FND_API.g_valid_level_full
               , p_context_id          => l_partner_id
   	       , p_context_code        => p_event_code
               , p_target_ctgry        => 'PARTNER'
               , p_target_ctgry_pt_id  => l_partner_id
               , p_notif_event_code    => l_notif_event_code
               , p_entity_id           => l_enrl_request_id
   	       , p_entity_code         => 'ENRQ'
               , p_wait_time           => 0
               , x_return_status       => x_return_status
               , x_msg_count           => x_msg_count
               , x_msg_data            => x_msg_data
            );
            IF x_return_status = FND_API.G_RET_STS_ERROR THEN
               RAISE FND_API.G_EXC_ERROR;
            ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
              RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
         END IF;
      END LOOP;
   END IF; -- end of if if atleast one membership id exists in the passed in table
END  term_all_memberships;




--------------------------------------------------------------------------
-- PROCEDURE
--   PV_PG_MEMBERSHIPS_PVT.Terminate_ptr_memberships
--
-- PURPOSE
--   Terminate all memberships for a given partner. If the partner is
--   a global partner, terminate its appropraite subsidiary memberships also
-- IN
--   partner_id NUMBER
--
-- USED BY
--   called from change membership type api and can also be called independently
--   to terminate all partner memberships.
--
-- HISTORY
--           pukken        CREATION
--------------------------------------------------------------------------

PROCEDURE Terminate_ptr_memberships
(
    p_api_version_number         IN   NUMBER
   ,p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   ,p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   ,p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
   ,p_partner_id                 IN   NUMBER --partner id for which all memberships need to be terminated
   ,p_memb_type                  IN   VARCHAR  -- if not given, will get from profile, should be 'SUBSIDIARY','GLOBAL','STANDARD'
   ,p_status_reason_code         IN   VARCHAR2 -- pass 'MEMBER_TYPE_CHANGE' if it is happening because of member type change -- it validates against PV_MEMB_STATUS_REASON_CODE
   ,p_comments                   IN   VARCHAR2 DEFAULT NULL -- pass 'Membership terminated by system as member type is changed' if it is changed because of member type change
   ,x_return_status              OUT  NOCOPY  VARCHAR2
   ,x_msg_count                  OUT  NOCOPY  NUMBER
   ,x_msg_data                   OUT  NOCOPY  VARCHAR2
)  IS


   CURSOR memb_csr( p_ptr_id NUMBER)  IS
   SELECT membership_id,program_id
   FROM   pv_pg_memberships
   WHERE  partner_id=p_ptr_id
   AND    membership_status_code IN  ('ACTIVE','FUTURE');

   CURSOR enrq_csr( p_ptr_id NUMBER)  IS
   SELECT enrl_request_id
   FROM   pv_pg_enrl_requests
   WHERE  partner_id=p_ptr_id
   AND    request_status_code in ('INCOMPLETE','AWAITING_APPROVAL');


   CURSOR memb_type_csr(ptr_id NUMBER) IS
   SELECT  enty.attr_value
   FROM    pv_enty_attr_values enty
   WHERE   enty.entity = 'PARTNER'
   AND     enty.entity_id = ptr_id
   AND     enty.attribute_id = 6
   AND     enty.latest_flag = 'Y';

   -- fix this SQL 12266991
   -- Fix this SQL 12267007
   CURSOR c_get_subs_csr (g_ptr_id NUMBER) IS
   SELECT   subs_prof.partner_id
   FROM     pv_partner_profiles subs_prof
          , pv_partner_profiles global_prof
          , pv_enty_attr_values  subs_enty_val
          , hz_relationships rel
   WHERE  global_prof.partner_id = g_ptr_id
   AND   global_prof.partner_party_id = rel.subject_id
   AND   rel.relationship_type = 'PARTNER_HIERARCHY'
   AND   rel.relationship_code = 'PARENT_OF'
   AND   rel.status = 'A'
   AND   NVL(rel.start_date, SYSDATE) <= SYSDATE
   AND   NVL(rel.end_date, SYSDATE) >= SYSDATE
   AND   rel.object_id = subs_prof.partner_party_id
   AND   subs_enty_val.entity_id = subs_prof.partner_id
   AND   subs_enty_val.entity = 'PARTNER'
   AND   subs_enty_val.attribute_id = 6
   AND   subs_enty_val.latest_flag = 'Y'
   AND   subs_enty_val.attr_value = 'SUBSIDIARY';

   CURSOR c_get_membs_csr(l_sub_str_table JTF_NUMBER_TABLE ) IS
   SELECT    /*+ CARDINALITY(sptr 10) */
             memb.membership_id membership_id
             , memb.program_id program_id
   FROM      pv_pg_memberships memb
             , (SELECT column_value FROM TABLE (CAST(l_sub_str_table AS JTF_NUMBER_TABLE))) sptr
   WHERE     memb.partner_id=sptr.column_value
   AND       memb.membership_status_code IN  ('ACTIVE','FUTURE');


   CURSOR c_get_enrls_csr(l_sub_str_table JTF_NUMBER_TABLE ) IS
   SELECT   /*+ CARDINALITY(sptr 10) */ enrq.enrl_request_id enrl_request_id
   FROM     pv_pg_enrl_requests enrq
            , (SELECT column_value FROM TABLE (CAST(l_sub_str_table AS JTF_NUMBER_TABLE))) sptr
   WHERE    enrq.partner_id=sptr.column_value
   AND      request_status_code IN  ('INCOMPLETE','AWAITING_APPROVAL');

   l_api_name                  CONSTANT VARCHAR2(30) := 'Terminate_ptr_memberships ';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_exists                    VARCHAR2(1);
   l_lookup_type               VARCHAR2(30);
   l_memb_id_tbl               JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_enrl_id_tbl               JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_member_type               VARCHAR2(30);
   counter                     NUMBER := 1;
   l_default_program_id        NUMBER;
   l_subs_tbl               JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

BEGIN
   /**
   1. get all the membership_id from memberships table that are ACTIVE, FUTURE and populate
      them in l_l_memberships_id table   Call terminate_membership
   2. also if membtype is global, get all the subsidiaryy partners and
      loop and get the program mmberships for each subsidiary partner
      and add them to thel_memberships_id's table
      call terminate_membership
   3. check wheher any of those other programs has pendingenrollment, cancel them and cancel any associated orders
   4. end date all the invitaions for the subsidiary partner

   */

   -- Standard Start of API savepoint
   SAVEPOINT Terminate_ptr_memberships;

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

   -- validate partner id
   IF p_partner_id IS NULL   THEN
      PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_PARTNER_ID_MISSING'); -- seed this message
      RAISE FND_API.G_EXC_ERROR;
   END IF;

   --validate status reason code
   l_default_program_id := isnumber(FND_PROFILE.VALUE('PV_PARTNER_DEFAULT_PROGRAM'));
   -- get all the membership to be terminated  into a table of memberships

   FOR membs in memb_csr( p_partner_id ) LOOP
      IF p_status_reason_code= 'MEMBER_TYPE_CHANGE' THEN
         IF ( l_default_program_id IS  NULL OR  l_default_program_id <> membs.program_id ) THEN

            l_memb_id_tbl.extend(1);
	    l_memb_id_tbl(counter) := membs.membership_id;
	    counter := counter+1;
         END IF;
      ELSE
         l_memb_id_tbl.extend(1);
	 l_memb_id_tbl(counter) := membs.membership_id;
	 counter := counter+1;
      END IF;

   END LOOP;

   IF l_memb_id_tbl.exists(1) THEN

      term_all_memberships
      (
         p_membership_table                => l_memb_id_tbl
         , p_event_code                    => 'TERMINATED'
         , p_status_reason_code            => p_status_reason_code
         , p_message_code                  => 'PV_TERMINATE_ALL_PRGM_MEMB'
         , p_comments                      => p_comments
         , x_return_status                 => x_return_status
         , x_msg_count                     => x_msg_count
         , x_msg_data                      => x_msg_data

      );

      --write to the logs
   END IF;

   IF x_return_status = FND_API.g_ret_sts_error THEN
      RAISE FND_API.g_exc_error;
   ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
      RAISE FND_API.g_exc_unexpected_error;
   END IF;

   OPEN enrq_csr(p_partner_id);
      FETCH enrq_csr  BULK  COLLECT INTO l_enrl_id_tbl;
   CLOSE enrq_csr;

   IF l_enrl_id_tbl.exists(1) THEN

      cancel_all_enrollments
      (
           p_enrollment_id_tbl     => l_enrl_id_tbl
          ,p_status_reason_code   => p_status_reason_code
          ,p_comments             => p_comments
          ,x_return_status        => x_return_status
          ,x_msg_count            => x_msg_count
          ,x_msg_data             => x_msg_data
      );
      IF x_return_status = FND_API.g_ret_sts_error THEN
         RAISE FND_API.g_exc_error;
      ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
         RAISE FND_API.g_exc_unexpected_error;
      END IF;

   END IF;



   l_enrl_id_tbl.delete();
   l_memb_id_tbl.delete();
   counter :=1;

   l_member_type:=p_memb_type;
   IF l_member_type IS NULL THEN
      OPEN memb_type_csr(p_partner_id);
         FETCH memb_type_csr  INTO l_member_type;
      CLOSE memb_type_csr;
   END IF;

   IF l_member_type='GLOBAL' THEN
      ---write a query to get the membership id's of alll subsidiary partners.
      ---and populate them to l_memb_id_tbl

      OPEN c_get_subs_csr (p_partner_id);
         FETCH c_get_subs_csr BULK COLLECT INTO l_subs_tbl ;
      CLOSE c_get_subs_csr;
      FOR mes in c_get_membs_csr( l_subs_tbl ) LOOP


      	 IF p_status_reason_code= 'MEMBER_TYPE_CHANGE' THEN


            IF ( l_default_program_id IS  NULL OR  l_default_program_id <> mes.program_id ) THEN
               l_memb_id_tbl.extend(1);
   	       l_memb_id_tbl(counter) := mes.membership_id;
   	       counter := counter+1;
            END IF;
         ELSE
            l_memb_id_tbl.extend(1);
   	    l_memb_id_tbl(counter) := mes.membership_id;
   	    counter := counter+1;
         END IF;

      END LOOP;


      IF l_memb_id_tbl.exists(1) THEN

         term_all_memberships
         (
            p_membership_table                => l_memb_id_tbl
            , p_event_code                    => 'TERMINATED'
            , p_status_reason_code            => 'GLOBAL_MEMBER_CHANGED'
            , p_message_code                  => 'PV_TERMINATE_ALL_SUBS_MEMB'
            , p_comments                      => p_comments
            , x_return_status                 => x_return_status
            , x_msg_count                     => x_msg_count
            , x_msg_data                      => x_msg_data

         );

         IF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

         --write to the logs
      END IF;

      OPEN c_get_enrls_csr(l_subs_tbl);
         FETCH c_get_enrls_csr  BULK  COLLECT INTO l_enrl_id_tbl;
      CLOSE c_get_enrls_csr;

      IF l_enrl_id_tbl.exists(1) THEN

         cancel_all_enrollments
         (
              p_enrollment_id_tbl     => l_enrl_id_tbl
             ,p_status_reason_code   => p_status_reason_code
             ,p_comments             => p_comments
             ,x_return_status        => x_return_status
             ,x_msg_count            => x_msg_count
             ,x_msg_data             => x_msg_data
         );
         IF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;

      END IF;

   END IF;




   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
     (p_count          =>   x_msg_count,
      p_data           =>   x_msg_data
   );

   -- Debug Message

   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
       PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
   END IF;

   -- Standard check for p_commit
   IF FND_API.to_Boolean( p_commit )   THEN
      COMMIT WORK;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO Terminate_ptr_memberships;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get
     (    p_encoded => FND_API.G_FALSE
         ,p_count => x_msg_count
         ,p_data  => x_msg_data
      );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Terminate_ptr_memberships;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get
     (    p_encoded => FND_API.G_FALSE
         ,p_count => x_msg_count
         ,p_data  => x_msg_data
      );

   WHEN OTHERS THEN
      ROLLBACK TO Terminate_ptr_memberships;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF FND_MSG_PUB.Check_Msg_Level ( FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)   THEN
         FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME,l_api_name);
      END IF;
      FND_MSG_PUB.Count_And_Get
      (   p_encoded => FND_API.G_FALSE
         ,p_count => x_msg_count
         ,p_data  => x_msg_data
      );
END Terminate_ptr_memberships;


FUNCTION getUniqueIDs(
p_ids           IN  JTF_NUMBER_TABLE
)
RETURN JTF_NUMBER_TABLE IS

l_unique_id_tbl JTF_NUMBER_TABLE:=JTF_NUMBER_TABLE();
counter NUMBER:=1;

BEGIN
   FOR x IN (
      SELECT * FROM TABLE (CAST(p_ids AS JTF_NUMBER_TABLE))
         GROUP  BY column_value )
   LOOP

      l_unique_id_tbl.extend(1);
      l_unique_id_tbl(counter):=x.column_value;
      counter:=counter+1;

   END LOOP;
   RETURN l_unique_id_tbl;

END getUniqueIDs;


-- this function gives all the programs in the pre-req  hierarchy starting from bottom to top
-- So if we have a hieararchy o3 programs A-> B->C, this function will return you
-- B and C , if you pass in A. If you pass B, then the function will return you C and so on.
PROCEDURE get_prereq_programs
(
    p_program_id           IN NUMBER
    ,l_prereq_program_ids   IN OUT NOCOPY JTF_NUMBER_TABLE

)
IS
   CURSOR   prereq_csr(p_prgm_id NUMBER) IS
   SELECT   DISTINCT(change_to_program_id)
   FROM     pv_pg_enrl_change_rules
   WHERE    change_direction_code='PREREQUISITE'
   AND      ACTIVE_FLAG='Y'
   START WITH change_from_program_id=p_prgm_id
   CONNECT BY change_from_program_id=PRIOR change_to_program_id
   AND PRIOR CHANGE_TO_PROGRAM_ID<>CHANGE_FROM_PROGRAM_ID;

BEGIN

   OPEN prereq_csr(p_program_id);
      FETCH prereq_csr  BULK  COLLECT INTO l_prereq_program_ids;
   CLOSE prereq_csr;


EXCEPTION

     WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END get_prereq_programs;


FUNCTION get_dependent_program_id
(

   p_membership_id        IN NUMBER

) RETURN JTF_NUMBER_TABLE IS
   l_dependent_program_id_tbl  JTF_NUMBER_TABLE:=JTF_NUMBER_TABLE();
   l_highest_level NUMBER;
   l_program_id    NUMBER;
   counter         NUMBER:=1;


   CURSOR mmbr_transitions_csr(to_mmbr_id NUMBER) IS
   SELECT memb.program_id program_id,trn.lvl actlevel
   FROM   pv_pg_memberships memb
          ,pv_partner_program_b pvpp,
          (

            SELECT  from_membership_id,min(level) lvl
            FROM    pv_pg_mmbr_transitions
            START WITH to_membership_id=to_mmbr_id
            CONNECT BY to_membership_id=prior from_membership_id
            GROUP BY from_membership_id,level
          ) trn
   WHERE  GLOBAL_MMBR_REQD_FLAG = 'Y'
   AND    pvpp.program_id=memb.program_id
   AND    memb.membership_id=trn.from_membership_id
   ORDER by actlevel;

   CURSOR prg_csr ( to_mmbr_id NUMBER ) IS
   SELECT memb.program_id
   FROM   pv_pg_memberships memb
          ,pv_partner_program_b pvpp
   WHERE  GLOBAL_MMBR_REQD_FLAG = 'Y'
   AND    pvpp.program_id=memb.program_id
   AND    memb.membership_id=to_mmbr_id;

BEGIN

   FOR mem_trans in mmbr_transitions_csr(p_membership_id) LOOP

      IF l_highest_level IS NULL THEN
         --add to the greatest id tbl
         l_highest_level:=mem_trans.actlevel;
         l_dependent_program_id_tbl.extend(1);
         l_dependent_program_id_tbl(1):=mem_trans.program_id;
      ELSE
         IF l_highest_level<mem_trans.actlevel THEN

            --set highest level
            l_highest_level:=mem_trans.actlevel;
            l_dependent_program_id_tbl.delete();
            counter:=1;
            l_dependent_program_id_tbl.extend(1);
            l_dependent_program_id_tbl(1):=mem_trans.program_id;
         ELSIF  l_highest_level= mem_trans.actlevel  THEN
            l_dependent_program_id_tbl.extend(1);
            counter:=counter+1;
            l_dependent_program_id_tbl(counter):=mem_trans.program_id;
         END IF;
      END IF;
   END LOOP;

   /*we are not inserting data into member transitions table when its a new enrollment request
     because there is no from membership.
     so to find the dependent program , just query for the GLOBAL_MMBR_REQD_FLAG for the program
     of the terminating membership
   */

      OPEN prg_csr ( p_membership_id  ) ;
         FETCH prg_csr INTO l_program_id;
      CLOSE prg_csr;
      IF l_program_id is NOT NULL THEN
           l_dependent_program_id_tbl.extend(1);
           l_dependent_program_id_tbl(1):=l_program_id;
      END IF;


   RETURN  l_dependent_program_id_tbl;

EXCEPTION

   WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END get_dependent_program_id;



--------------------------------------------------------------------------
-- PROCEDURE
--   PV_PG_MEMBERSHIPS_PVT.Terminate__membership
--
-- PURPOSE
--   Terminate a  membership for a given partner. If the partner is
--   a global partner, terminate its appropraite subsidiary memberships also
-- IN
--   membership_id IN NUMBER
--     membership_id from memberships table
--   p_event_code  IN VARCHAR2
--     validated against the lookup PV_MEMBERSHIP_STATUS
--   p_memb_type   IN  VARCHAR
--     if not given, will get from profile, should be 'SUBSIDIARY','GLOBAL','STANDARD'
--   p_status_reason_code  IN  VARCHAR2
--     validates against PV_MEMB_STATUS_REASON_CODE
-- USED BY
--   this api is called when you want to terminate,expire or downgrade a single program membership
-- HISTORY
--           pukken        CREATION
--------------------------------------------------------------------------

PROCEDURE Terminate_membership
(
   p_api_version_number           IN  NUMBER
   , p_init_msg_list              IN  VARCHAR2 := FND_API.G_FALSE
   , p_commit                     IN  VARCHAR2 := FND_API.G_FALSE
   , p_validation_level           IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
   , p_membership_id              IN  NUMBER
   , p_event_code                 IN  VARCHAR2
   , p_memb_type                  IN  VARCHAR
   , p_status_reason_code         IN  VARCHAR2
   , p_comments                   IN  VARCHAR2 DEFAULT NULL
   , x_return_status              OUT NOCOPY   VARCHAR2
   , x_msg_count                  OUT NOCOPY   NUMBER
   , x_msg_data                   OUT NOCOPY   VARCHAR2
)  IS

   CURSOR   enrl_csr( ptr_id NUMBER, prgm_id_tbl JTF_NUMBER_TABLE ) IS
   SELECT   enr.enrl_request_id
            , enr.request_status_code
            , memb.membership_status_code
            , memb.membership_id
   FROM     pv_pg_enrl_requests enr
            , pv_pg_memberships memb
   WHERE    enr.partner_id = ptr_id
   AND      enr.program_id
            IN   ( SELECT  * FROM TABLE ( CAST( prgm_id_tbl AS JTF_NUMBER_TABLE ) ) )
   AND      enr.enrl_request_id = memb.enrl_request_id(+);


   CURSOR   enrl_sub_csr( ptr_id_tbl JTF_NUMBER_TABLE, prgm_id_tbl JTF_NUMBER_TABLE ) IS
   SELECT   /*+ CARDINALITY(ptr 10) */
            enr.enrl_request_id
            , enr.request_status_code
            , memb.membership_status_code
            , memb.membership_id
   FROM     pv_pg_enrl_requests enr
            , pv_pg_memberships memb
	    , ( SELECT  column_value FROM TABLE ( CAST( ptr_id_tbl AS JTF_NUMBER_TABLE ) ) ) ptr
	    , ( SELECT  column_value FROM TABLE ( CAST( prgm_id_tbl AS JTF_NUMBER_TABLE ) ) ) prg
   WHERE    enr.partner_id =ptr.column_value
   AND      enr.program_id =prg.column_value
   AND      enr.enrl_request_id = memb.enrl_request_id(+);
   /*
   -- added new SQL above to fix this SQL reported in 11.5.10 CU1 in sql repositiry 12267124
   SELECT   enr.enrl_request_id
            , enr.request_status_code
            , memb.membership_status_code
            , memb.membership_id
   FROM     pv_pg_enrl_requests enr
            , pv_pg_memberships memb
   WHERE    enr.partner_id
            IN   ( SELECT  * FROM TABLE ( CAST( ptr_id_tbl AS JTF_NUMBER_TABLE ) ) )
   AND      enr.program_id
            IN   ( SELECT  * FROM TABLE ( CAST( prgm_id_tbl AS JTF_NUMBER_TABLE ) ) )
   AND      enr.enrl_request_id = memb.enrl_request_id(+);
   */

   CURSOR   subsidiary_csr( global_partner_id NUMBER, p_depentent_id_tbl JTF_NUMBER_TABLE ) IS
   SELECT   enrq.enrl_request_id
            , enrq.request_status_code
            , memb.membership_status_code
            , memb.membership_id
            , memb.partner_id
   FROM     pv_partner_profiles subs_prof
            , pv_partner_profiles global_prof
            , pv_enty_attr_values  subs_enty_val

            , hz_relationships rel
            , pv_pg_memberships memb
            , pv_pg_enrl_requests enrq
   WHERE    global_prof.partner_id = global_partner_id
   AND      global_prof.partner_party_id = rel.subject_id
   AND      rel.relationship_type = 'PARTNER_HIERARCHY'
   AND      rel.object_id = subs_prof.partner_party_id
   AND      rel.relationship_code = 'PARENT_OF'
   AND      rel.status = 'A'
   AND      NVL(rel.start_date, SYSDATE) <= SYSDATE
   AND      NVL(rel.end_date, SYSDATE) >= SYSDATE
   AND      subs_enty_val.entity = 'PARTNER'
   AND      subs_enty_val.entity_id = subs_prof.partner_id
   AND      subs_enty_val.attribute_id = 6
   AND      subs_enty_val.latest_flag = 'Y'
   AND      subs_enty_val.attr_value = 'SUBSIDIARY'
   AND      subs_prof.partner_id = enrq.partner_id
   AND      enrq.enrl_request_id = memb.enrl_request_id(+)
   AND      enrq.dependent_program_id
            IN   ( SELECT  * FROM TABLE ( CAST( p_depentent_id_tbl AS JTF_NUMBER_TABLE ) ) );

   CURSOR   prereq_sub_csr( memb_id_tbl JTF_NUMBER_TABLE ) IS
   SELECT  /*+ LEADING(t) */  DISTINCT( program_id )
   FROM     pv_pg_memberships memb
           , (SELECT column_value FROM TABLE (CAST(memb_id_tbl AS JTF_NUMBER_TABLE))) t
   WHERE   t.column_value=memb.membership_id;
   /*
    -- added new SQL above to fix this SQL reported in 11.5.10 CU1 in sql repositiry 12267161
   SELECT   DISTINCT( program_id )
   FROM     pv_pg_memberships
   WHERE    membership_id
            IN   ( SELECT  * FROM TABLE ( CAST( memb_id_tbl AS JTF_NUMBER_TABLE ) ) );
   */
   CURSOR   memb_type_csr( memb_id NUMBER ) IS
   SELECT   enty.attr_value
            , memb.program_id
            , memb.partner_id
   FROM     pv_pg_memberships memb
            , pv_enty_attr_values enty
   WHERE    memb.membership_id = memb_id
   AND      memb.partner_id = enty.entity_id
   AND      enty.entity = 'PARTNER'
   AND      enty.entity_id = memb.partner_id
   AND      enty.attribute_id = 6
   AND      enty.latest_flag = 'Y';

   CURSOR   memb_csr ( memb_id NUMBER ) IS
   SELECT   program_id
            , partner_id
   FROM     pv_pg_memberships
   WHERE    membership_id = memb_id;

   l_isTerminatable         boolean := true;
   l_program_id_tbl         JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_membid_tbl             JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_enrl_req_tbl           JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_prereq_sub_id_tbl      JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_all_prereq_prgm_tbl    JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_prereq_prgm_tbl        JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_all_depend_prgmids_tbl JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_depend_prgm_ids_tbl    JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();
   l_sub_partner_id_tbl     JTF_NUMBER_TABLE := JTF_NUMBER_TABLE();

   l_member_type            VARCHAR2(30);
   l_program_id             NUMBER := NULL;
   l_partner_id             NUMBER := NULL;
   mcounter                 NUMBER := 1;
   ecounter                 NUMBER := 1;
   dep_counter              NUMBER := 1;
   subscounter              NUMBER := 1;
   l_api_name               CONSTANT VARCHAR2(30) := 'Terminate_membership';
   l_api_version_number     CONSTANT NUMBER := 1.0;
   l_status_reason_code     VARCHAR2(30);
   l_message_code           VARCHAR2(30);

   l_event_code             VARCHAR2(30);

BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  Terminate_membership ;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
   (   l_api_version_number
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
      PVX_UTILITY_PVT.debug_message( 'Private API: ' || l_api_name || 'start' );
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;
   -- Validate Environment
   IF FND_GLOBAL.USER_ID IS NULL   THEN
      PVX_UTILITY_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
      RAISE FND_API.G_EXC_ERROR;
   END IF;
   -- validate  p_status_reason_code
   IF p_status_reason_code is NOT NULL THEN
      validate_Lookup
      (
         p_lookup_type    => 'PV_MEMB_STATUS_REASON_CODE'
         ,p_lookup_code   => p_status_reason_code
         ,x_return_status => x_return_status
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
  END IF;

   -- validate  p_event_code
   validate_Lookup
   (
      p_lookup_type    => 'PV_MEMBERSHIP_STATUS'
      ,p_lookup_code   => p_event_code
      ,x_return_status => x_return_status
   );
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- VALIDATE the passed in member type value thats passed in
   -- find out the existing the member type if its not passed in.. If its passed , validate it
   IF p_memb_type is NULL THEN
      OPEN memb_type_csr( p_membership_id );
        FETCH memb_type_csr INTO l_member_type, l_program_id, l_partner_id;
      CLOSE memb_type_csr;
   ELSE
      --VALIDATE the passed in member type value thats passed in
      /*validate_Lookup
      (
         p_lookup_type    => 'PV_MEMBER_TYPE_CODE'
         , p_lookup_code   => p_memb_type
         , x_return_status => x_return_status
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      */
      validate_member_type
      (
         p_member_type   => p_memb_type
         ,x_return_status => x_return_status
      );
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
         RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      l_member_type := p_memb_type;
   END IF;
   -- need to validate status reason code also. need to evaluate whether we should do it here or in term_all_memberships

   -- call  term_all_memberships to terminate/expire this membership
   -- add the membership_id to l_memberships

   l_membid_tbl.extend(1);
   l_membid_tbl(1):= p_membership_id;

   IF p_event_code = 'TERMINATED' THEN
      l_message_code := 'PV_MEMBERSHIP_TERMINATED';
   ELSIF p_event_code = 'EXPIRED' THEN
      l_message_code := 'PV_MEMBERSHIP_EXPIRED';
   ELSIF p_event_code = 'DOWNGRADED' THEN
      l_message_code := 'PV_MEMBERSHIP_DOWNGRADED';
   END IF;



   term_all_memberships
   (
      p_membership_table                => l_membid_tbl
      , p_event_code                    => p_event_code
      , p_status_reason_code            => p_status_reason_code
      , p_message_code                  => l_message_code
      , p_comments                      => p_comments
      , x_return_status                 => x_return_status
      , x_msg_count                     => x_msg_count
      , x_msg_data                      => x_msg_data

   );
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- incase of downgrades there is a seperate api downgrade_membership which will call this api.
   -- so the term_all_memberships will put the membership status of the membership to downgraded
   -- if there are dependent memberships , those memberships needs to be terminated and it shouild
   -- not be downgraded and hence the if else below.
   IF p_event_code = 'DOWNGRADED' THEN
      l_event_code := 'TERMINATED';
   ELSE
      l_event_code := p_event_code;
   END IF;
   -- delete all values from  the  l_membid_tbl variable
   l_membid_tbl.delete();
   -- get the programid of the membership that got terminated. this is to terminate/expire any prepreq programs.
   IF l_program_id IS NULL THEN
      OPEN memb_csr( p_membership_id );
         FETCH memb_csr INTO l_program_id, l_partner_id;
      CLOSE memb_csr;
   END IF;

   -- get the pre-reqs of the terminated/expired program that will return a table of program_ids.

   get_prereq_programs( l_program_id, l_program_id_tbl );

   IF l_program_id_tbl.exists(1) THEN



      /**
      OPEN a cursor to get all enrollment requests (l_partner_id,l_program_id_tbl)
      loop through the cursor and cancel the enrollments if they are incomplete
      if not check wwhether they have active or future memberships and if yes, add
      the membership id to l_membid_tbl for termination
      call terminate_all_memberships with appropriate status reason code
      */
      FOR enrl in enrl_csr( l_partner_id,l_program_id_tbl ) LOOP

         IF enrl.request_status_code IN ( 'INCOMPELTE','AWAITING_APPROVAL' ) THEN

            -- add the enrollment request_id to l_enrl_req_tbl for cancellation
            l_enrl_req_tbl.extend(1);
            l_enrl_req_tbl(ecounter) := enrl.enrl_request_id;
            ecounter := ecounter+1;
         ELSE
            -- add to the  l_membid_tbl for terminating the prepreqs
            IF  enrl.membership_status_code IN ( 'ACTIVE','FUTURE' ) THEN

               l_membid_tbl.extend(1);
               l_membid_tbl(mcounter) := enrl.membership_id;
               mcounter := mcounter+1;
            END IF;
         END IF;
      END LOOP;
      -- call the terminate api to terminate/expire all the memberships in  the l_membid_tbl table

      IF l_membid_tbl.exists(1) THEN

      	 IF p_event_code = 'TERMINATED' THEN
            l_status_reason_code := 'PREREQ_MEMBERSHIP_TERMINATED';
            l_message_code := 'PV_PREREQ_MEMB_TERMINATED';
         ELSIF p_event_code = 'EXPIRED' THEN
            l_status_reason_code := 'PREREQ_MEMBERSHIP_EXPIRED';
            l_message_code := 'PV_PREREQ_MEMB_EXPIRED';
         ELSIF p_event_code = 'DOWNGRADED' THEN
            l_status_reason_code := 'PREREQ_MEMBERSHIP_DOWNGRADED';
            l_message_code := 'PV_PREREQ_MEMB_DOWNGRADED';
         END IF;

         term_all_memberships
         (
            p_membership_table                => l_membid_tbl
            , p_event_code                    => l_event_code
            , p_status_reason_code            => l_status_reason_code
            , p_message_code                  => l_message_code
            , p_comments                      => p_comments
            , x_return_status                 => x_return_status
            , x_msg_count                     => x_msg_count
            , x_msg_data                      => x_msg_data

         );

         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
            RAISE FND_API.G_EXC_ERROR;
         ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
         END IF;

      END IF;
      --call cancel_all_enrollments to cancel all the  enrollemnt requests in the l_enrl_req_tbl
      IF l_enrl_req_tbl.exists(1) THEN

         cancel_all_enrollments
         (
              p_enrollment_id_tbl     => l_enrl_req_tbl
             , p_status_reason_code   => p_status_reason_code
             , p_comments             => p_comments
             , x_return_status        => x_return_status
             , x_msg_count            => x_msg_count
             , x_msg_data             => x_msg_data
         );
         IF x_return_status = FND_API.g_ret_sts_error THEN
            RAISE FND_API.g_exc_error;
         ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
            RAISE FND_API.g_exc_unexpected_error;
         END IF;
      END IF;
      -- delete all values from  the  l_enrl_req_tbl variable
      l_enrl_req_tbl.delete();
      ecounter := 1;
   END IF; -- end of if , if any prepreq programs exist.

   /** add the membership id (p_membership_id)  to l_membid_tbl  table.
       this is done to get all the memberships that we terminated including prereqs in l_membid_tbl  table.
   */

   l_membid_tbl.extend(1);
   l_membid_tbl(mcounter) := p_membership_id;
   /** now if member type is GLOBAL, we need to terminate/expire all corresponding subsidiary memberships or
       any corresponding subsidiary memberships  thats in the upgrade /downgarde path of the  terminated program.
       If the membership is being downgraded, don't do anything on the subsidiary memberships.
   */
   IF l_member_type = 'GLOBAL' AND p_event_code<> 'DOWNGRADED' THEN

      -- for each membership id in l_mmeberships_tbl, find out all the dependent programs
      FOR m in 1..l_membid_tbl.count() LOOP

         l_depend_prgm_ids_tbl := get_dependent_program_id( l_membid_tbl(m) );

         IF l_depend_prgm_ids_tbl.exists(1) THEN
            --need to add all the values in l_depend_prgm_ids_tbl into another and keep adding it
            --for all the memberships
            FOR n in 1.. l_depend_prgm_ids_tbl.count() LOOP
               l_all_depend_prgmids_tbl.extend(1);
               l_all_depend_prgmids_tbl(dep_counter) := l_depend_prgm_ids_tbl(n);
               dep_counter := dep_counter+1;

            END LOOP;
         END IF;

      END LOOP;

      l_membid_tbl.delete();
      mcounter := 1;
      -- pick all enrollment requests that are dependent on these programs
      -- and whose partner_id is a subsidiary of the global
      -- if that enrollment is incomplete or awaiting approval, cancel that enrollment request
      -- else if its approved,, get the membership id associated with it and add it to l_subs_memb_id_tbl
      -- for termination
      -- also get the prereq programs for the terminated memberships and cancel/terminate any enrollments there.

      IF l_all_depend_prgmids_tbl.exists(1) THEN

      	 -- there could be same program ids in l_all_depend_prgmids_tbl. so get the distinct ids
         l_all_depend_prgmids_tbl := getUniqueIDs( l_all_depend_prgmids_tbl );

         FOR sub_enr in subsidiary_csr( l_partner_id, l_all_depend_prgmids_tbl ) LOOP

            IF sub_enr.request_status_code IN ( 'INCOMPELTE','AWAITING_APPROVAL' ) THEN
               --cancel the enrollments and write to log that this is because of prereq program got terminated
               l_enrl_req_tbl.extend(1);
               l_enrl_req_tbl(ecounter) := sub_enr.enrl_request_id;
               ecounter := ecounter+1;
            ELSE
               IF  sub_enr.membership_status_code IN ( 'ACTIVE','FUTURE' ) THEN
                  l_membid_tbl.extend(1);
                  l_membid_tbl(mcounter) := sub_enr.membership_id;
                  --just capture all subsidiaries partner_ids whose atleast one membership is getting terminated
                  l_sub_partner_id_tbl.extend(1);
                  l_sub_partner_id_tbl(mcounter) := sub_enr.partner_id;
                  mcounter := mcounter+1;
               END IF;
            END IF;

         END LOOP;
         -- set the message code and status reasom code
         IF p_event_code = 'TERMINATED' THEN
            l_status_reason_code := 'GLOBAL_MEMBERSHIP_TERMINATED';
            l_message_code := 'PV_GLOBAL_MEMB_TERMINATED';
         ELSIF p_event_code = 'EXPIRED' THEN
            l_status_reason_code := 'GLOBAL_MEMBERSHIP_EXPIRED';
            l_message_code := 'PV_GLOBAL_MEMB_EXPIRED';
         END IF;
         --cancel all related enrollemnts .. these are becuase of WW tremination
         IF l_enrl_req_tbl.exists(1) THEN
            cancel_all_enrollments
            (
                 p_enrollment_id_tbl     => l_enrl_req_tbl
                , p_status_reason_code   => p_status_reason_code
                , p_comments             => p_comments
                , x_return_status        => x_return_status
                , x_msg_count            => x_msg_count
                , x_msg_data             => x_msg_data
            );
            IF x_return_status = FND_API.g_ret_sts_error THEN
               RAISE FND_API.g_exc_error;
            ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
               RAISE FND_API.g_exc_unexpected_error;
            END IF;
         END IF;
         l_enrl_req_tbl.delete();
         ecounter := 1;
         -- terminate the subsidiary memberships that are in the l_membid_tbl table
         IF l_membid_tbl.exists(1) THEN
            --terminate the dependent programs

            term_all_memberships
            (
               p_membership_table                => l_membid_tbl
               , p_event_code                    => l_event_code
               , p_status_reason_code            => l_status_reason_code
               , p_message_code                  => l_message_code
               , p_comments                      => p_comments
               , x_return_status                 => x_return_status
               , x_msg_count                     => x_msg_count
               , x_msg_data                      => x_msg_data

            );
            -- find out all the program ids for the subsidiary memberships that got terminated
            OPEN prereq_sub_csr (l_membid_tbl);
                FETCH prereq_sub_csr  BULK COLLECT INTO l_prereq_sub_id_tbl;
            CLOSE prereq_sub_csr;
            l_membid_tbl.delete();
            mcounter:=1;
            IF l_prereq_sub_id_tbl.exists(1) THEN
               -- loop through and find out all the prereq programs
               FOR s in 1..l_prereq_sub_id_tbl.count() LOOP
                  --get the prereqs for each program and add it to another table variable
                  get_prereq_programs( l_prereq_sub_id_tbl(s), l_prereq_prgm_tbl );
                  --l_prereq_prgm_tbl := get_prereq_programs( l_prereq_sub_id_tbl(s) );
                  IF l_prereq_prgm_tbl.exists(1) THEN
                      FOR t in 1..l_prereq_prgm_tbl.count() LOOP
                         l_all_prereq_prgm_tbl.extend(1);
                         l_all_prereq_prgm_tbl(subscounter):= l_prereq_prgm_tbl(t);
                         subscounter := subscounter+1;

                      END LOOP;
                  END IF;

               END LOOP;
            END IF;
            IF l_all_prereq_prgm_tbl.exists(1) THEN
               -- there could be same program ids in l_all_depend_prgmids_tbl. so get the distinct ids
               l_all_prereq_prgm_tbl := getUniqueIDs( l_all_prereq_prgm_tbl );
               FOR enroll in enrl_sub_csr( l_sub_partner_id_tbl, l_all_prereq_prgm_tbl ) LOOP
                  IF enroll.request_status_code IN ( 'INCOMPELTE','AWAITING_APPROVAL' ) THEN
                  --cancel the enrollments and write to log that this is because of prereq program got terminated
                     l_enrl_req_tbl.extend(1);
                     l_enrl_req_tbl(ecounter) := enroll.enrl_request_id;
                     ecounter := ecounter+1;
                  ELSE
                     IF enroll.membership_status_code IN ( 'ACTIVE','FUTURE' ) THEN
                        l_membid_tbl.extend(1);
                        l_membid_tbl(mcounter) := enroll.membership_id;
                        mcounter := mcounter+1;
                     END IF;
                  END IF;

               END LOOP;

               IF p_event_code = 'TERMINATED' THEN
                  l_status_reason_code := 'SUBS_PREREQ_MEMB_TERMINATED';
                  l_message_code := 'PV_SUBS_PREREQ_MEMB_TERMINATED';
               ELSIF p_event_code = 'EXPIRED' THEN
                  l_status_reason_code := 'SUBS_PREREQ_MEMB_EXPIRED';
                  l_message_code := 'PV_SUBS_PREREQ_MEMB_EXPIRED';
               END IF;

               -- cancel all related prerequisite enrollments of the subsidiaries.
               IF l_enrl_req_tbl.exists(1) THEN
                  cancel_all_enrollments
                  (
                       p_enrollment_id_tbl    => l_enrl_req_tbl
                      , p_status_reason_code   => p_status_reason_code
                      , p_comments             => p_comments
                      , x_return_status        => x_return_status
                      , x_msg_count            => x_msg_count
                      , x_msg_data             => x_msg_data
                  );
                  IF x_return_status = FND_API.g_ret_sts_error THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;
               END IF;

               --terminate the dependent programs prereqs
               IF l_membid_tbl.exists(1) THEN
                  --terminate the dependent programs
                  term_all_memberships
                  (
                     p_membership_table                => l_membid_tbl
                     , p_event_code                    => l_event_code
                     , p_status_reason_code            => l_status_reason_code
                     , p_message_code                  => l_message_code
                     , p_comments                      => p_comments
                     , x_return_status                 => x_return_status
                     , x_msg_count                     => x_msg_count
                     , x_msg_data                      => x_msg_data

                  );
                  IF x_return_status = FND_API.g_ret_sts_error THEN
                     RAISE FND_API.g_exc_error;
                  ELSIF x_return_status = FND_API.g_ret_sts_unexp_error THEN
                     RAISE FND_API.g_exc_unexpected_error;
                  END IF;
               END IF;

            END IF;-- end of if, if there are any prereqs to terminated subsidiary programs

         END IF; --end of if , if there are dependenden subsidiary memberships to be terminated

      END IF; --end of if , if there are dependent programs for the global membership prorgam

   END IF;  -- end of if , if member type is global
   -- Debug Message
   IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message( 'Private API: ' || l_api_name || 'end' );
   END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (
      p_count      =>   x_msg_count
      , p_data     =>   x_msg_data
   );
   IF FND_API.to_Boolean( p_commit )      THEN
      COMMIT WORK;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO  Terminate_membership;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
   );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO  Terminate_membership;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
   );

   WHEN OTHERS THEN
   ROLLBACK TO  Terminate_membership;
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

END Terminate_membership;

PROCEDURE downgrade_membership
(
   p_api_version_number          IN    NUMBER
   , p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
   , p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
   , p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
   , p_membership_id              IN   NUMBER   -- membership id of the program that you are dwongrading
   , p_status_reason_code         IN   VARCHAR2 -- reason for termoination or downgrade
   , p_comments                   IN   VARCHAR2 DEFAULT NULL
   , p_program_id_downgraded_to   IN   NUMBER   --programid into which the partner is downgraded to.
   , p_requestor_resource_id      IN   NUMBER   --resource_id of the user who's performing the action
   , x_new_memb_id                OUT  NOCOPY  NUMBER
   , x_return_status              OUT  NOCOPY  VARCHAR2
   , x_msg_count                  OUT  NOCOPY  NUMBER
   , x_msg_data                   OUT  NOCOPY  VARCHAR2
)
IS
   CURSOR   membership_csr(p_memb_id NUMBER) IS
   SELECT   partner_id
            , original_end_date
            , enrl_request_id
            , program_name
   FROM     pv_pg_memberships memb
            , pv_partner_program_vl prgm
   WHERE   membership_id = p_memb_id
   AND     memb.program_id=prgm.program_id;

   CURSOR to_program_csr ( p_progm_id IN NUMBER ) IS
   SELECT program_name
   FROM   pv_partner_program_vl
   where  program_id=p_progm_id ;




   l_api_name               CONSTANT VARCHAR2(30) := 'downgrade_membership';
   l_api_version_number     CONSTANT NUMBER := 1.0;
   l_pv_pg_new_memb_rec     memb_rec_type;
   l_pv_pg_enrq_rec         PV_Pg_Enrl_Requests_PVT.enrl_request_rec_type;
   l_mmbr_tran_rec          pv_pg_mmbr_transitions_PVT.mmbr_tran_rec_type;
   l_partner_id             NUMBER;
   l_enrl_request_id        NUMBER;
   l_membership_id          NUMBER;
   l_original_end_date      DATE;
   l_mmbr_transition_id     NUMBER;
   l_from_enrl_request_id   NUMBER;
   l_from_program_name      VARCHAR2(60);
   l_to_program_name      VARCHAR2(60);
   l_param_tbl_var         PVX_UTILITY_PVT.log_params_tbl_type;
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT  downgrade_membership ;
   -- Standard call to check for call compatibility.
   IF NOT FND_API.Compatible_API_Call
   (   l_api_version_number
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
   -- call terminate membership with event code as downgraded
   Terminate_membership
   (
      p_api_version_number         =>1.0
      , p_init_msg_list            => FND_API.G_FALSE
      , p_commit                   => FND_API.G_FALSE
      , p_validation_level         => FND_API.g_valid_level_full
      , p_membership_id            => p_membership_id
      , p_event_code               => 'DOWNGRADED'
      , p_memb_type                => NULL
      , p_status_reason_code       => 'POOR_PERF'
      , p_comments                 => p_comments
      , x_return_status            => x_return_status
      , x_msg_count                => x_msg_count
      , x_msg_data                 => x_msg_data
   );
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   OPEN membership_csr(p_membership_id);
        FETCH membership_csr INTO l_partner_id,l_original_end_date,l_from_enrl_request_id,l_from_program_name;
   CLOSE membership_csr;

   -- create an enrollment request with approved status
   l_pv_pg_enrq_rec.partner_id := l_partner_id;
   l_pv_pg_enrq_rec.program_id := p_program_id_downgraded_to;
   l_pv_pg_enrq_rec.requestor_resource_id := p_requestor_resource_id;
   l_pv_pg_enrq_rec.request_status_code := 'APPROVED';
   l_pv_pg_enrq_rec.enrollment_type_code := 'DOWNGRADE';
   l_pv_pg_enrq_rec.payment_status_code := 'NOT_SUBMITTED';
   l_pv_pg_enrq_rec.request_submission_date := sysdate;
   l_pv_pg_enrq_rec.request_initiated_by_code := 'VENDOR';
   l_pv_pg_enrq_rec.contract_status_code := 'NOT_SIGNED';

   PV_Pg_Enrl_Requests_PVT.Create_Pg_Enrl_Requests
   (
      p_api_version_number    =>1.0
      , p_init_msg_list       => FND_API.G_FALSE
      , p_commit              => FND_API.G_FALSE
      , p_validation_level    => FND_API.g_valid_level_full
      , x_return_status       => x_return_status
      , x_msg_count           => x_msg_count
      , x_msg_data            => x_msg_data
      , p_enrl_request_rec    => l_pv_pg_enrq_rec
      , x_enrl_request_id     => l_enrl_request_id
   );
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --create a membership record with the downgraded program id and end date of the program from which it was
   --downgraded
   l_pv_pg_new_memb_rec.enrl_request_id := l_enrl_request_id;
   l_pv_pg_new_memb_rec.start_date := sysdate;
   l_pv_pg_new_memb_rec.original_end_date := l_original_end_date;
   l_pv_pg_new_memb_rec.membership_status_code := 'ACTIVE';
   l_pv_pg_new_memb_rec.partner_id := l_partner_id;
   l_pv_pg_new_memb_rec.program_id := p_program_id_downgraded_to;

   PV_Pg_Memberships_PVT.Create_Pg_memberships
   (    p_api_version_number=>1.0
       , p_init_msg_list       => FND_API.G_FALSE
       , p_commit              => FND_API.G_FALSE
       , p_validation_level    => FND_API.g_valid_level_full
       , x_return_status       => x_return_status
       , x_msg_count           => x_msg_count
       , x_msg_data            => x_msg_data
       , p_memb_rec            => l_pv_pg_new_memb_rec
       , x_membership_id       => l_membership_id
   );
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   x_new_memb_id :=l_membership_id;
   --insert into member transitions table

   l_mmbr_tran_rec.from_membership_id:=p_membership_id;
   l_mmbr_tran_rec.to_membership_id:=l_membership_id;
   pv_pg_mmbr_transitions_PVT.Create_Mmbr_Trans
   (
      p_api_version_number         =>1.0
      , p_init_msg_list            => FND_API.G_FALSE
      , p_commit                   => FND_API.G_FALSE
      , p_validation_level         => FND_API.g_valid_level_full
      , x_return_status            => x_return_status
      , x_msg_count                => x_msg_count
      , x_msg_data                 => x_msg_data
      , p_mmbr_tran_rec            => l_mmbr_tran_rec
      , x_mmbr_transition_id       => l_mmbr_transition_id
   );
   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;
   --call responsiblity management api for the new membership
   Pv_User_Resp_Pvt.manage_memb_resp
   (
      p_api_version_number      => 1.0
      , p_init_msg_list         => Fnd_Api.g_false
      , p_commit                => Fnd_Api.g_false
      , p_membership_id         => l_membership_id
      , x_return_status         => x_return_status
      , x_msg_count             => x_msg_count
      , x_msg_data              => x_msg_data
   );

   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   OPEN to_program_csr ( p_program_id_downgraded_to );
      FETCH to_program_csr INTO l_to_program_name;
   CLOSE to_program_csr;

   l_param_tbl_var(1).param_name := 'FROM_PROGRAM_NAME';
   l_param_tbl_var(1).param_value := l_from_program_name;

   l_param_tbl_var(2).param_name := 'TO_PROGRAM_NAME';
   l_param_tbl_var(2).param_value := l_to_program_name;


     PVX_UTILITY_PVT.create_history_log
         (
            p_arc_history_for_entity_code   => 'MEMBERSHIP'
            , p_history_for_entity_id       => l_enrl_request_id
            , p_history_category_code       => 'ENROLLMENT'
            , p_message_code                => 'PV_MEMBERSHIP_DOWNGRADED'
            , p_comments                    => p_comments
            , p_partner_id                  => l_partner_id
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

   PV_PG_NOTIF_UTILITY_PVT.Send_Workflow_Notification
    (
       p_api_version_number    => 1.0
       , p_init_msg_list       => FND_API.G_FALSE
       , p_commit              => FND_API.G_FALSE
       , p_validation_level    => FND_API.G_VALID_LEVEL_FULL
       , p_context_id          => p_program_id_downgraded_to
       , p_context_code        => 'PROGRAM'
       , p_target_ctgry        => 'PARTNER'
       , p_target_ctgry_pt_id  => l_partner_id -- this should be  PARTNER ID
       , p_notif_event_code    => 'PG_DOWNGRADE'
       , p_entity_id           => l_from_enrl_request_id
       , p_entity_code         => 'ENRQ'
       , p_wait_time           => 0
       , x_return_status       => x_return_status
       , x_msg_count           => x_msg_count
       , x_msg_data            => x_msg_data
    );


    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR  THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Debug Message
    IF (PV_DEBUG_HIGH_ON) THEN
      PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
    END IF;

   -- Standard call to get message count and if count is 1, get message info.
   FND_MSG_PUB.Count_And_Get
   (
      p_count      =>   x_msg_count
      , p_data     =>   x_msg_data
   );
   IF FND_API.to_Boolean( p_commit )      THEN
      COMMIT WORK;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO  downgrade_membership;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
   );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO  downgrade_membership;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
   );

   WHEN OTHERS THEN
   ROLLBACK TO  downgrade_membership;
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
END downgrade_membership;

-- to calculate the end date for a program from sysdate.
-- this should be called only when the memebership end date is updated
FUNCTION getenddate( p_program_id in NUMBER )
RETURN DATE IS

   CURSOR   rec_cur(p_prgm_id NUMBER, start_date DATE ) IS
   SELECT   program_end_date
            , decode(  membership_period_unit
                       , 'DAY', start_date+membership_valid_period
                       , 'MONTH', add_months( start_date, membership_valid_period )
                       , 'YEAR', add_months( start_date, 12*membership_valid_period )
                       , null
                    )  membership_end_date
   FROM     pv_partner_program_b
   WHERE    program_id=p_prgm_id;

   l_program_end_date DATE;
   l_membership_end_date DATE;
   l_start_date DATE;

BEGIN

   OPEN rec_cur( p_program_id, sysdate);
      FETCH rec_cur into l_program_end_date,l_membership_end_date;
      IF rec_cur%found THEN
         IF l_membership_end_date is NULL THEN
              l_membership_end_date := l_program_end_date;
           END IF;
        END IF;
     CLOSE rec_cur;
     RETURN  l_membership_end_date;

EXCEPTION

   WHEN OTHERS THEN
     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END getenddate;


PROCEDURE  Update_membership_end_date
(
   p_api_version_number         IN   NUMBER
  , p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE
  , p_commit                     IN   VARCHAR2     := FND_API.G_FALSE
  , p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL
  , p_membership_id              IN   NUMBER       -- membership_id for which end date needs to be updated
  , p_new_date                   IN   DATE
  , p_comments                   IN   VARCHAR2 DEFAULT NULL
  , x_return_status              OUT  NOCOPY  VARCHAR2
  , x_msg_count                  OUT  NOCOPY  NUMBER
  , x_msg_data                   OUT  NOCOPY  VARCHAR2
) IS


   ---CURSOR TO get the membertype and partner_id
   CURSOR   memb_type_csr(memb_id NUMBER) IS
   SELECT   memb.partner_id
            , memb.object_version_number
            , enty.attr_value
            , memb.original_end_date
   FROM     pv_pg_memberships memb
            , pv_enty_attr_values enty
   WHERE    memb.membership_id=memb_id
   AND      memb.partner_id=enty.entity_id
   AND      enty.entity = 'PARTNER'
   AND      enty.entity_id = memb.partner_id
   AND      enty.attribute_id = 6
   AND      enty.latest_flag = 'Y';

   --cursor to get all the subsidiaries and all their active memberships
   --that are dependent on this membership id that is being updated

   CURSOR   subsidiary_csr( global_partner_id NUMBER,p_depentent_id_tbl JTF_NUMBER_TABLE) IS
   SELECT   memb.membership_id
            , memb.object_version_number
            , memb.original_end_date
            , memb.partner_id
            , memb.program_id
   FROM     pv_partner_profiles subs_prof
            , pv_partner_profiles global_prof
            , pv_enty_attr_values  subs_enty_val
            , hz_relationships rel
            , pv_pg_memberships memb
            , pv_pg_enrl_requests enrl
   WHERE    global_prof.partner_id = global_partner_id
   AND      global_prof.partner_party_id = rel.subject_id
   AND      rel.relationship_type = 'PARTNER_HIERARCHY'
   AND      rel.object_id = subs_prof.partner_party_id
   AND      rel.relationship_code = 'PARENT_OF'
   AND      rel.status = 'A'
   AND      NVL(rel.start_date, SYSDATE) <= SYSDATE
   AND      NVL(rel.end_date, SYSDATE) >= SYSDATE
   AND      subs_enty_val.entity = 'PARTNER'
   AND      subs_enty_val.entity_id = subs_prof.partner_id
   AND      subs_enty_val.attribute_id = 6
   AND      subs_enty_val.latest_flag = 'Y'
   AND      subs_enty_val.attr_value = 'SUBSIDIARY'
   AND      subs_prof.partner_id=memb.partner_id
   AND      memb.membership_status_code='ACTIVE'
   AND      memb.enrl_request_id=enrl.enrl_request_id
   AND      enrl.dependent_program_id
   in       ( SELECT  * FROM TABLE ( CAST( p_depentent_id_tbl AS JTF_NUMBER_TABLE ) ) );

   l_api_name                  CONSTANT VARCHAR2(30) := 'Update_membership_end_date';
   l_api_version_number        CONSTANT NUMBER   := 1.0;
   l_dependent_program_id      JTF_NUMBER_TABLE;
   l_partner_id                NUMBER;
   l_member_type               VARCHAR2(30);
   l_object_version_number     NUMBER;
   l_pv_pg_memb_rec            memb_rec_type;
   l_global_current_end_date   DATE;
   l_subs_end_date             DATE;

BEGIN

   -- Standard Start of API savepoint
   SAVEPOINT  Update_membership_end_date ;
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

   OPEN memb_type_csr( p_membership_id );
      FETCH memb_type_csr INTO l_partner_id,l_object_version_number,l_member_type,l_global_current_end_date;
   CLOSE memb_type_csr;

   l_pv_pg_memb_rec.membership_id := p_membership_id;
   l_pv_pg_memb_rec.original_end_date := p_new_date;
   l_pv_pg_memb_rec.object_version_number := l_object_version_number;
   PV_Pg_Memberships_PVT.Update_Pg_Memberships
   (    p_api_version_number    => 1.0
       , p_init_msg_list         => Fnd_Api.g_false
       , p_commit                => Fnd_Api.g_false
       , x_return_status         => x_return_status
       , x_msg_count             => x_msg_count
       , x_msg_data              => x_msg_data
       , p_memb_rec              => l_pv_pg_memb_rec
   );
   --also write to the history log
   IF l_member_type='GLOBAL' THEN
      l_dependent_program_id :=get_dependent_program_id( p_membership_id );
      IF l_dependent_program_id.exists(1) THEN
         FOR subsidiary in subsidiary_csr(l_partner_id,l_dependent_program_id) LOOP
            -- set the membership record to be updated
            l_subs_end_date := getenddate( subsidiary.program_id );
            IF l_subs_end_date > p_new_date THEN
               l_subs_end_date := p_new_date;
            END IF;
            l_pv_pg_memb_rec.membership_id := subsidiary.membership_id;
            l_pv_pg_memb_rec.original_end_date := l_subs_end_date;
            l_pv_pg_memb_rec.object_version_number := subsidiary.object_version_number;
            PV_Pg_Memberships_PVT.Update_Pg_Memberships
            (    p_api_version_number    => 1.0
                ,p_init_msg_list         => Fnd_Api.g_false
                ,p_commit                => Fnd_Api.g_false
                ,x_return_status         => x_return_status
                ,x_msg_count             => x_msg_count
                ,x_msg_data              => x_msg_data
                ,p_memb_rec              => l_pv_pg_memb_rec
            );
            -- also write to the history log
         END LOOP;
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
   IF FND_API.to_Boolean( p_commit )      THEN
      COMMIT WORK;
   END IF;

EXCEPTION
   WHEN FND_API.G_EXC_ERROR THEN
   ROLLBACK TO  Update_membership_end_date;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
   );
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO  Update_membership_end_date;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
   );
   WHEN OTHERS THEN
   ROLLBACK TO  Update_membership_end_date;
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
END  Update_membership_end_date;

/*****************************
 * logging_enabled
 *****************************/
FUNCTION logging_enabled (p_log_level IN NUMBER)
  RETURN BOOLEAN
IS
BEGIN
  RETURN (p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL);
END;

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


--  IF logging_enabled (p_log_level) THEN
  IF (p_log_level >= FND_LOG.G_CURRENT_RUNTIME_LEVEL ) THEN
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

/*****************************
 * TERMINATE_PTR_MEMBERSHIPS
 *****************************/
FUNCTION TERMINATE_PTR_MEMBERSHIPS
( p_subscription_guid  in raw,
  p_event              in out NOCOPY wf_event_t)
RETURN VARCHAR2
IS
   l_api_name          CONSTANT VARCHAR2(30) := 'TERMINATE_PTR_MEMBERSHIPS';
   l_partner_id        NUMBER;
   l_old_status        VARCHAR2(1);
   l_new_status        VARCHAR2(1);
   x_return_status     VARCHAR2(10);
   x_msg_count         NUMBER;
   x_msg_data          VARCHAR2(2000);

BEGIN
   FND_MSG_PUB.initialize;
   IF (PV_DEBUG_HIGH_ON) THEN
     WRITE_LOG(l_api_name, 'Start TERMINATE_PTR_MEMBERSHIPS');
   END IF;
   l_partner_id        := p_event.GetValueForParameter('PARTNER_ID');
   l_old_status        := p_event.GetValueForParameter('OLD_PARTNER_STATUS');
   l_new_status        := p_event.GetValueForParameter('NEW_PARTNER_STATUS');
   IF (PV_DEBUG_HIGH_ON) THEN
     WRITE_LOG(l_api_name, 'l_partner_id = ' || l_partner_id);
     WRITE_LOG(l_api_name, 'l_old_status = ' || l_old_status);
     WRITE_LOG(l_api_name, 'l_new_status = ' || l_new_status);
   END IF;

   x_return_status := FND_API.G_RET_STS_SUCCESS;
   IF (l_old_status = 'A' and l_new_status = 'I') THEN
      IF (PV_DEBUG_HIGH_ON) THEN
        WRITE_LOG(l_api_name, 'before calling Terminate_ptr_memberships');
      END IF;
      PV_Pg_Memberships_PVT.Terminate_ptr_memberships (
          p_api_version_number      => 1.0
         ,p_init_msg_list           => FND_API.G_FALSE
         ,p_commit                  => FND_API.G_FALSE
         ,p_partner_id              => l_partner_id
         ,p_memb_type               => null
         ,p_status_reason_code      => 'PTR_INACTIVE'
         ,x_return_status           => x_return_status
         ,x_msg_count               => x_msg_count
         ,x_msg_data                => x_msg_data
      );
      IF (PV_DEBUG_HIGH_ON) THEN
        WRITE_LOG(l_api_name, 'x_return_status = ' || x_return_status);
      END IF;
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (PV_DEBUG_HIGH_ON) THEN
        WRITE_LOG(l_api_name, 'before calling Register_term_ptr_memb_type');
      END IF;
      Pv_ptr_member_type_pvt.Register_term_ptr_memb_type (
          p_api_version_number      => 1.0
         ,p_init_msg_list           => FND_API.G_FALSE
         ,p_commit                  => FND_API.G_FALSE
         ,p_validation_level        => FND_API.G_VALID_LEVEL_FULL
         ,p_partner_id              => l_partner_id
         ,p_current_memb_type       => null
         ,p_new_memb_type           => null
         ,p_global_ptr_id           => null
         ,x_return_status           => x_return_status
         ,x_msg_count               => x_msg_count
         ,x_msg_data                => x_msg_data
      );
      IF (PV_DEBUG_HIGH_ON) THEN
        WRITE_LOG(l_api_name, 'x_return_status = ' || x_return_status);
      END IF;
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF (PV_DEBUG_HIGH_ON) THEN
        WRITE_LOG(l_api_name, 'before calling revoke_default_resp');
      END IF;
      Pv_User_Resp_Pvt.revoke_default_resp (
          p_api_version_number      => 1.0
         ,p_init_msg_list           => FND_API.G_FALSE
         ,p_commit                  => FND_API.G_FALSE
         ,x_return_status           => x_return_status
         ,x_msg_count               => x_msg_count
         ,x_msg_data                => x_msg_data
         ,p_partner_id              => l_partner_id
      );
      IF (PV_DEBUG_HIGH_ON) THEN
        WRITE_LOG(l_api_name, 'x_return_status = ' || x_return_status);
      END IF;
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   ELSIF (l_old_status = 'I' and l_new_status = 'A') THEN
      IF (PV_DEBUG_HIGH_ON) THEN
        WRITE_LOG(l_api_name, 'before calling assign_default_resp');
      END IF;
      Pv_User_Resp_Pvt.assign_default_resp (
          p_api_version_number      => 1.0
         ,p_init_msg_list           => FND_API.G_FALSE
         ,p_commit                  => FND_API.G_FALSE
         ,x_return_status           => x_return_status
         ,x_msg_count               => x_msg_count
         ,x_msg_data                => x_msg_data
         ,p_partner_id              => l_partner_id
      );
      IF (PV_DEBUG_HIGH_ON) THEN
        WRITE_LOG(l_api_name, 'x_return_status = ' || x_return_status);
      END IF;
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;
   END IF;
RETURN 'SUCCESS';
EXCEPTION
 WHEN FND_API.G_EXC_ERROR THEN
    WF_CORE.CONTEXT('PV_PG_MEMBERSHIPS_PVT', 'TERMINATE_PTR_MEMBERSHIPS', p_event.getEventName(), p_subscription_guid);
    WF_EVENT.setErrorInfo(p_event, 'Error from Terminate_ptr_memberships');
    RETURN 'ERROR';
 WHEN OTHERS THEN
    WF_CORE.CONTEXT('PV_PG_MEMBERSHIPS_PVT', 'TERMINATE_PTR_MEMBERSHIPS', p_event.getEventName(), p_subscription_guid);
    WF_EVENT.setErrorInfo(p_event, 'ERROR');
    RETURN 'ERROR';
END;


END PV_Pg_Memberships_PVT;

/
