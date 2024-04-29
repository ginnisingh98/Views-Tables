--------------------------------------------------------
--  DDL for Package Body PV_PG_ENRQ_INIT_SOURCES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_PG_ENRQ_INIT_SOURCES_PVT" AS
/* $Header: pvxvpeib.pls 120.1 2005/08/26 10:20:52 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Pg_Enrq_Init_Sources_PVT
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Pg_Enrq_Init_Sources_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvpeib.pls';

-- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
-- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
--
-- Foreward Procedure Declarations
--

PROCEDURE Default_Enrq_Init_Src_Items (
   p_enrq_init_sources_rec IN  enrq_init_sources_rec_type ,
   x_enrq_init_sources_rec OUT NOCOPY enrq_init_sources_rec_type
) ;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Pg_Enrq_Init_Sources
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
--       p_enrq_init_sources_rec            IN   enrq_init_sources_rec_type  Required
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

PROCEDURE Create_Pg_Enrq_Init_Sources(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE,
    p_commit                     IN   VARCHAR2     := Fnd_Api.G_FALSE,
    p_validation_level           IN   NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_enrq_init_sources_rec              IN   enrq_init_sources_rec_type  := g_miss_enrq_init_sources_rec,
    x_initiation_source_id              OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Pg_Enrq_Init_Sources';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := Fnd_Api.G_MISS_NUM;
   l_initiation_source_id              NUMBER;
   l_dummy                     NUMBER;
   CURSOR c_id IS
      SELECT pv_pg_enrq_init_sources_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM PV_PG_ENRQ_INIT_SOURCES
      WHERE initiation_source_id = l_id;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_pg_init_src_pvt;

      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
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

      Pvx_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF Fnd_Global.USER_ID IS NULL
      THEN
         Pvx_Utility_Pvt.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;



      IF ( P_validation_level >= Fnd_Api.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          Pvx_Utility_Pvt.debug_message('Private API: Validate_Pg_Init_Src');
          END IF;

          -- Invoke validation procedures
          Validate_Pg_Init_Src(
            p_api_version_number     => 1.0,
            p_init_msg_list    => Fnd_Api.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => Jtf_Plsql_Api.g_create,
            p_enrq_init_sources_rec  =>  p_enrq_init_sources_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;

   -- Local variable initialization

   IF p_enrq_init_sources_rec.initiation_source_id IS NULL OR p_enrq_init_sources_rec.initiation_source_id = Fnd_Api.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_initiation_source_id;
         CLOSE c_id;

         OPEN c_id_exists(l_initiation_source_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
         l_initiation_source_id := p_enrq_init_sources_rec.initiation_source_id;
   END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(Pv_Pg_Enrq_Init_Sources_Pkg.Insert_Row)
      Pv_Pg_Enrq_Init_Sources_Pkg.Insert_Row(
          px_initiation_source_id  => l_initiation_source_id,
          px_object_version_number  => l_object_version_number,
          p_enrl_request_id  => p_enrq_init_sources_rec.enrl_request_id,
          p_prev_membership_id  => p_enrq_init_sources_rec.prev_membership_id,
          p_enrl_change_rule_id  => p_enrq_init_sources_rec.enrl_change_rule_id,
          p_created_by  => Fnd_Global.USER_ID,
          p_creation_date  => SYSDATE,
          p_last_updated_by  => Fnd_Global.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => Fnd_Global.conc_login_id
);

          x_initiation_source_id := l_initiation_source_id;
      IF x_return_status <> Fnd_Api.G_RET_STS_SUCCESS THEN
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
--
-- End of API body
--

      -- Standard check for p_commit
      IF Fnd_Api.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'end');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN Pvx_Utility_Pvt.resource_locked THEN
     x_return_status := Fnd_Api.g_ret_sts_error;
         Pvx_Utility_Pvt.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN Fnd_Api.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Pg_Init_Src_PVT;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Pg_Init_Src_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Pg_Init_Src_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END Create_Pg_Enrq_Init_Sources;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Pg_Enrq_Init_Sources
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
--       p_enrq_init_sources_rec            IN   enrq_init_sources_rec_type  Required
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

PROCEDURE Update_Pg_Enrq_Init_Sources(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE,
    p_commit                     IN   VARCHAR2     := Fnd_Api.G_FALSE,
    p_validation_level           IN  NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_enrq_init_sources_rec               IN    enrq_init_sources_rec_type
    )

 IS


CURSOR c_get_pg_enrq_init_sources(initiation_source_id NUMBER) IS
    SELECT *
    FROM  PV_PG_ENRQ_INIT_SOURCES
    WHERE  initiation_source_id = p_enrq_init_sources_rec.initiation_source_id;
    -- Hint: Developer need to provide Where clause


L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Pg_Enrq_Init_Sources';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_initiation_source_id    NUMBER;
l_ref_enrq_init_sources_rec  c_get_Pg_Enrq_Init_Sources%ROWTYPE ;
l_tar_enrq_init_sources_rec  enrq_init_sources_rec_type := P_enrq_init_sources_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_pg_init_src_pvt;

      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
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

      Pvx_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message('Private API: - Open Cursor to Select');
      END IF;

      OPEN c_get_Pg_Enrq_Init_Sources( l_tar_enrq_init_sources_rec.initiation_source_id);

      FETCH c_get_Pg_Enrq_Init_Sources INTO l_ref_enrq_init_sources_rec  ;

       IF ( c_get_Pg_Enrq_Init_Sources%NOTFOUND) THEN
  Pvx_Utility_Pvt.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Pg_Enrq_Init_Sources') ;
           RAISE Fnd_Api.G_EXC_ERROR;
       END IF;
       -- Debug Message
       IF (PV_DEBUG_HIGH_ON) THEN

       Pvx_Utility_Pvt.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Pg_Enrq_Init_Sources;


      IF (l_tar_enrq_init_sources_rec.object_version_number IS NULL OR
          l_tar_enrq_init_sources_rec.object_version_number = Fnd_Api.G_MISS_NUM ) THEN
  Pvx_Utility_Pvt.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;
      -- Check Whether record has been changed by someone else
      IF (l_tar_enrq_init_sources_rec.object_version_number <> l_ref_enrq_init_sources_rec.object_version_number) THEN
  Pvx_Utility_Pvt.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Pg_Enrq_Init_Sources') ;
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;


      IF ( P_validation_level >= Fnd_Api.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          Pvx_Utility_Pvt.debug_message('Private API: Validate_Pg_Init_Src');
          END IF;

          -- Invoke validation procedures
          Validate_Pg_Init_Src(
            p_api_version_number     => 1.0,
            p_init_msg_list    => Fnd_Api.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => Jtf_Plsql_Api.g_update,
            p_enrq_init_sources_rec  =>  p_enrq_init_sources_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>Fnd_Api.G_RET_STS_SUCCESS THEN
          RAISE Fnd_Api.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message('Private API: Calling update table handler');
      END IF;

      -- Invoke table handler(Pv_Pg_Enrq_Init_Sources_Pkg.Update_Row)
      Pv_Pg_Enrq_Init_Sources_Pkg.Update_Row(
          p_initiation_source_id  => p_enrq_init_sources_rec.initiation_source_id,
          p_object_version_number  => p_enrq_init_sources_rec.object_version_number,
          p_enrl_request_id  => p_enrq_init_sources_rec.enrl_request_id,
          p_prev_membership_id  => p_enrq_init_sources_rec.prev_membership_id,
          p_enrl_change_rule_id  => p_enrq_init_sources_rec.enrl_change_rule_id,
          p_last_updated_by  => Fnd_Global.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => Fnd_Global.conc_login_id
);
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF Fnd_Api.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'end');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN Pvx_Utility_Pvt.resource_locked THEN
     x_return_status := Fnd_Api.g_ret_sts_error;
         Pvx_Utility_Pvt.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN Fnd_Api.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Pg_Init_Src_PVT;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Pg_Init_Src_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Pg_Init_Src_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END Update_Pg_Enrq_Init_Sources;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Pg_Enrq_Init_Sources
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
--       p_initiation_source_id                IN   NUMBER
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

PROCEDURE Delete_Pg_Enrq_Init_Sources(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE,
    p_commit                     IN   VARCHAR2     := Fnd_Api.G_FALSE,
    p_validation_level           IN   NUMBER       := Fnd_Api.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_initiation_source_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Pg_Enrq_Init_Sources';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_pg_init_src_pvt;

      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
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

      Pvx_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message( 'Private API: Calling delete table handler');
      END IF;

      -- Invoke table handler(Pv_Pg_Enrq_Init_Sources_Pkg.Delete_Row)
      Pv_Pg_Enrq_Init_Sources_Pkg.Delete_Row(
          p_initiation_source_id  => p_initiation_source_id,
          p_object_version_number => p_object_version_number     );
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF Fnd_Api.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'end');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN Pvx_Utility_Pvt.resource_locked THEN
     x_return_status := Fnd_Api.g_ret_sts_error;
         Pvx_Utility_Pvt.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN Fnd_Api.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Pg_Init_Src_PVT;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Pg_Init_Src_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Pg_Init_Src_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END Delete_Pg_Enrq_Init_Sources;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Pg_Enrq_Init_Sources
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
--       p_enrq_init_sources_rec            IN   enrq_init_sources_rec_type  Required
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

PROCEDURE Lock_Pg_Enrq_Init_Sources(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_initiation_source_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Pg_Enrq_Init_Sources';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_initiation_source_id                  NUMBER;

BEGIN

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'start');
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
         Fnd_Msg_Pub.initialize;
      END IF;



      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;


------------------------ lock -------------------------
Pv_Pg_Enrq_Init_Sources_Pkg.Lock_Row(l_initiation_source_id,p_object_version);


 -------------------- finish --------------------------
  Fnd_Msg_Pub.count_and_get(
    p_encoded => Fnd_Api.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  IF (PV_DEBUG_HIGH_ON) THEN

  Pvx_Utility_Pvt.debug_message(l_full_name ||': end');
  END IF;
EXCEPTION

   WHEN Pvx_Utility_Pvt.resource_locked THEN
     x_return_status := Fnd_Api.g_ret_sts_error;
         Pvx_Utility_Pvt.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN Fnd_Api.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Pg_Enrq_Init_Sources_PVT;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Pg_Enrq_Init_Sources_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Pg_Enrq_Init_Sources_PVT;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END Lock_Pg_Enrq_Init_Sources;




PROCEDURE check_Init_Src_Uk_Items(
    p_enrq_init_sources_rec               IN   enrq_init_sources_rec_type,
    p_validation_mode            IN  VARCHAR2 := Jtf_Plsql_Api.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := Fnd_Api.g_ret_sts_success;
      IF p_validation_mode = Jtf_Plsql_Api.g_create
      AND p_enrq_init_sources_rec.initiation_source_id IS NOT NULL
      THEN
         l_valid_flag := Pvx_Utility_Pvt.check_uniqueness(
         'pv_pg_enrq_init_sources',
         'initiation_source_id = ''' || p_enrq_init_sources_rec.initiation_source_id ||''''
         );
      END IF;

      IF l_valid_flag = Fnd_Api.g_false THEN
         Pvx_Utility_Pvt.Error_Message(p_message_name => 'PV_initiation_source_id_DUPLICATE');
         x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;

END check_Init_Src_Uk_Items;



PROCEDURE check_Init_Src_Req_Items(
    p_enrq_init_sources_rec               IN  enrq_init_sources_rec_type,
    p_validation_mode IN VARCHAR2 := Jtf_Plsql_Api.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := Fnd_Api.g_ret_sts_success;

   IF p_validation_mode = Jtf_Plsql_Api.g_create THEN

/*
      IF p_enrq_init_sources_rec.initiation_source_id = FND_API.G_MISS_NUM OR p_enrq_init_sources_rec.initiation_source_id IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'INITIATION_SOURCE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_enrq_init_sources_rec.object_version_number = FND_API.G_MISS_NUM OR p_enrq_init_sources_rec.object_version_number IS NULL THEN
               PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUMBER' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
*/

      IF p_enrq_init_sources_rec.enrl_request_id = Fnd_Api.G_MISS_NUM OR p_enrq_init_sources_rec.enrl_request_id IS NULL THEN
               Pvx_Utility_Pvt.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'ENRL_REQUEST_ID' );
               x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;


      IF p_enrq_init_sources_rec.prev_membership_id = Fnd_Api.G_MISS_NUM OR p_enrq_init_sources_rec.prev_membership_id IS NULL THEN
               Pvx_Utility_Pvt.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'PREV_MEMBERSHIP_ID' );
               x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;


   ELSE


      IF p_enrq_init_sources_rec.initiation_source_id = Fnd_Api.G_MISS_NUM THEN
               Pvx_Utility_Pvt.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'INITIATION_SOURCE_ID' );
               x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;


      IF p_enrq_init_sources_rec.object_version_number = Fnd_Api.G_MISS_NUM THEN
               Pvx_Utility_Pvt.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUMBER' );
               x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;


      IF p_enrq_init_sources_rec.enrl_request_id = Fnd_Api.G_MISS_NUM THEN
               Pvx_Utility_Pvt.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'ENRL_REQUEST_ID' );
               x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;


      IF p_enrq_init_sources_rec.prev_membership_id = Fnd_Api.G_MISS_NUM THEN
               Pvx_Utility_Pvt.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'PREV_MEMBERSHIP_ID' );
               x_return_status := Fnd_Api.g_ret_sts_error;
      END IF;
   END IF;

END check_Init_Src_Req_Items;



PROCEDURE check_Init_Src_Fk_Items(
    p_enrq_init_sources_rec IN enrq_init_sources_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := Fnd_Api.g_ret_sts_success;

   -- Enter custom code here

END check_Init_Src_Fk_Items;



PROCEDURE check_Init_Src_Lookup_Items(
    p_enrq_init_sources_rec IN enrq_init_sources_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := Fnd_Api.g_ret_sts_success;

   -- Enter custom code here

END check_Init_Src_Lookup_Items;



PROCEDURE check_Init_Src_Items (
    P_enrq_init_sources_rec     IN    enrq_init_sources_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

    l_return_status := Fnd_Api.g_ret_sts_success;
   -- Check Items Uniqueness API calls

   check_Init_Src_Uk_Items(
      p_enrq_init_sources_rec => p_enrq_init_sources_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      l_return_status := Fnd_Api.g_ret_sts_error;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_Init_Src_req_items(
      p_enrq_init_sources_rec => p_enrq_init_sources_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      l_return_status := Fnd_Api.g_ret_sts_error;
   END IF;
   -- Check Items Foreign Keys API calls

   check_Init_Src_FK_items(
      p_enrq_init_sources_rec => p_enrq_init_sources_rec,
      x_return_status => x_return_status);
   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      l_return_status := Fnd_Api.g_ret_sts_error;
   END IF;
   -- Check Items Lookups

   check_Init_Src_Lookup_items(
      p_enrq_init_sources_rec => p_enrq_init_sources_rec,
      x_return_status => x_return_status);
   IF x_return_status <> Fnd_Api.g_ret_sts_success THEN
      l_return_status := Fnd_Api.g_ret_sts_error;
   END IF;

   x_return_status := l_return_status;

END check_Init_Src_Items;





PROCEDURE Complete_Enrq_Init_Sources_Rec (
   p_enrq_init_sources_rec IN enrq_init_sources_rec_type,
   x_complete_rec OUT NOCOPY enrq_init_sources_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM pv_pg_enrq_init_sources
      WHERE initiation_source_id = p_enrq_init_sources_rec.initiation_source_id;
   l_enrq_init_sources_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_enrq_init_sources_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_enrq_init_sources_rec;
   CLOSE c_complete;

   -- initiation_source_id
   IF p_enrq_init_sources_rec.initiation_source_id IS NULL THEN
      x_complete_rec.initiation_source_id := l_enrq_init_sources_rec.initiation_source_id;
   END IF;

   -- object_version_number
   IF p_enrq_init_sources_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_enrq_init_sources_rec.object_version_number;
   END IF;

   -- enrl_request_id
   IF p_enrq_init_sources_rec.enrl_request_id IS NULL THEN
      x_complete_rec.enrl_request_id := l_enrq_init_sources_rec.enrl_request_id;
   END IF;

   -- prev_membership_id
   IF p_enrq_init_sources_rec.prev_membership_id IS NULL THEN
      x_complete_rec.prev_membership_id := l_enrq_init_sources_rec.prev_membership_id;
   END IF;

   -- enrl_change_rule_id
   IF p_enrq_init_sources_rec.enrl_change_rule_id IS NULL THEN
      x_complete_rec.enrl_change_rule_id := l_enrq_init_sources_rec.enrl_change_rule_id;
   END IF;

   -- created_by
   IF p_enrq_init_sources_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_enrq_init_sources_rec.created_by;
   END IF;

   -- creation_date
   IF p_enrq_init_sources_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_enrq_init_sources_rec.creation_date;
   END IF;

   -- last_updated_by
   IF p_enrq_init_sources_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_enrq_init_sources_rec.last_updated_by;
   END IF;

   -- last_update_date
   IF p_enrq_init_sources_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_enrq_init_sources_rec.last_update_date;
   END IF;

   -- last_update_login
   IF p_enrq_init_sources_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_enrq_init_sources_rec.last_update_login;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Enrq_Init_Sources_Rec;




PROCEDURE Default_Enrq_Init_Src_Items ( p_enrq_init_sources_rec IN enrq_init_sources_rec_type ,
                                x_enrq_init_sources_rec OUT NOCOPY enrq_init_sources_rec_type )
IS
   l_enrq_init_sources_rec enrq_init_sources_rec_type := p_enrq_init_sources_rec;
BEGIN
   -- Developers should put their code to default the record type
   -- e.g. IF p_campaign_rec.status_code IS NULL
   --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
   --         l_campaign_rec.status_code := 'NEW' ;
   --      END IF ;
   --
   NULL ;
END;




PROCEDURE Validate_Pg_Init_Src(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE,
    p_validation_level           IN   NUMBER := Fnd_Api.G_VALID_LEVEL_FULL,
    p_enrq_init_sources_rec               IN   enrq_init_sources_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Pg_Init_Src';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_enrq_init_sources_rec      enrq_init_sources_rec_type;
l_enrq_init_sources_rec_out  enrq_init_sources_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Validate_Pg_Init_Src_;

      -- Standard call to check for call compatibility.
      IF NOT Fnd_Api.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
         Fnd_Msg_Pub.initialize;
      END IF;


      IF p_validation_level >= Jtf_Plsql_Api.g_valid_level_item THEN
              Check_init_src_Items(
                 p_enrq_init_sources_rec        => p_enrq_init_sources_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
                  RAISE Fnd_Api.G_EXC_ERROR;
              ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
                  RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      IF p_validation_mode = Jtf_Plsql_Api.g_create THEN
         Default_Enrq_Init_Src_Items (p_enrq_init_sources_rec => p_enrq_init_sources_rec ,
                                x_enrq_init_sources_rec => l_enrq_init_sources_rec) ;
      END IF ;


      Complete_enrq_init_sources_Rec(
         p_enrq_init_sources_rec        => l_enrq_init_sources_rec,
         x_complete_rec                 => l_enrq_init_sources_rec_out
      );

      l_enrq_init_sources_rec := l_enrq_init_sources_rec_out;

      IF p_validation_level >= Jtf_Plsql_Api.g_valid_level_item THEN
         Validate_Init_Src_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => Fnd_Api.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_enrq_init_sources_rec           =>    l_enrq_init_sources_rec);

              IF x_return_status = Fnd_Api.G_RET_STS_ERROR THEN
                 RAISE Fnd_Api.G_EXC_ERROR;
              ELSIF x_return_status = Fnd_Api.G_RET_STS_UNEXP_ERROR THEN
                 RAISE Fnd_Api.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'start');
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message('Private API: ' || l_api_name || 'end');
      END IF;


      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN Pvx_Utility_Pvt.resource_locked THEN
     x_return_status := Fnd_Api.g_ret_sts_error;
         Pvx_Utility_Pvt.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN Fnd_Api.G_EXC_ERROR THEN
     ROLLBACK TO Validate_Pg_Init_Src_;
     x_return_status := Fnd_Api.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN Fnd_Api.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Validate_Pg_Init_Src_;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Validate_Pg_Init_Src_;
     x_return_status := Fnd_Api.G_RET_STS_UNEXP_ERROR;
     IF Fnd_Msg_Pub.Check_Msg_Level ( Fnd_Msg_Pub.G_MSG_LVL_UNEXP_ERROR)
     THEN
        Fnd_Msg_Pub.Add_Exc_Msg( G_PKG_NAME,l_api_name);
     END IF;
     -- Standard call to get message count and if count=1, get the message
     Fnd_Msg_Pub.Count_And_Get (
            p_encoded => Fnd_Api.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );
END Validate_Pg_Init_Src;


PROCEDURE Validate_Init_Src_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := Fnd_Api.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_enrq_init_sources_rec               IN    enrq_init_sources_rec_type
    )
IS
BEGIN
      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF Fnd_Api.to_Boolean( p_init_msg_list )
      THEN
         Fnd_Msg_Pub.initialize;
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := Fnd_Api.G_RET_STS_SUCCESS;

      -- Hint: Validate data
      -- If data not valid
      -- THEN
      -- x_return_status := FND_API.G_RET_STS_ERROR;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      Pvx_Utility_Pvt.debug_message('Private API: Validate_dm_model_rec');
      END IF;
      -- Standard call to get message count and if count is 1, get message info.
      Fnd_Msg_Pub.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_Init_Src_Rec;

END Pv_Pg_Enrq_Init_Sources_Pvt;

/
