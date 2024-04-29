--------------------------------------------------------
--  DDL for Package Body PV_GE_PTNR_RESPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_GE_PTNR_RESPS_PVT" as
/* $Header: pvxvgprb.pls 120.1 2005/08/26 10:20:13 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_Ge_Ptnr_Resps_PVT
-- Purpose
--
-- History
--         14-SEP-2003    Karen.Tsao          Created.
--         18-NOV-2003    Karen.Tsao          Modified for new column resp_type_code.
--         29-JUL-2004    Karen.Tsao          Added if/else condition in check_Ge_Ptnr_Resps_Uk_Items.
--
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Ge_Ptnr_Resps_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvgprb.pls';

-- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
-- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
--
-- Foreward Procedure Declarations
--

PROCEDURE Default_Ge_Ptnr_Resps_Items (
 p_ge_ptnr_resps_rec IN  ge_ptnr_resps_rec_type ,
 x_ge_ptnr_resps_rec OUT NOCOPY ge_ptnr_resps_rec_type
) ;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Ge_Ptnr_Resps
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
--       p_ge_ptnr_resps_rec            IN   ge_ptnr_resps_rec_type  Required
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

PROCEDURE Create_Ge_Ptnr_Resps(
  p_api_version_number         IN   NUMBER,
  p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
  p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
  p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

  x_return_status              OUT NOCOPY  VARCHAR2,
  x_msg_count                  OUT NOCOPY  NUMBER,
  x_msg_data                   OUT NOCOPY  VARCHAR2,

  p_ge_ptnr_resps_rec              IN   ge_ptnr_resps_rec_type  := g_miss_ge_ptnr_resps_rec,
  x_ptnr_resp_id              OUT NOCOPY  NUMBER
   )

IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Ge_Ptnr_Resps';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
 l_return_status_full        VARCHAR2(1);
 l_object_version_number     NUMBER := 1;
 l_org_id                    NUMBER := FND_API.G_MISS_NUM;
 l_ptnr_resp_id              NUMBER;
 l_dummy                     NUMBER;
 CURSOR c_id IS
    SELECT pv_ge_ptnr_resps_s.NEXTVAL
    FROM dual;

 CURSOR c_id_exists (l_id IN NUMBER) IS
    SELECT 1
    FROM PV_GE_PTNR_RESPS
    WHERE ptnr_resp_id = l_id;
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT create_ge_ptnr_resps_pvt;

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

        PVX_UTILITY_PVT.debug_message('Private API: Validate_Ge_Ptnr_Resps');
        END IF;

        -- Invoke validation procedures
        Validate_ge_ptnr_resps(
          p_api_version_number     => 1.0,
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode => JTF_PLSQL_API.g_create,
          p_ge_ptnr_resps_rec  =>  p_ge_ptnr_resps_rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);
    END IF;

    IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

 -- Local variable initialization

 IF p_ge_ptnr_resps_rec.ptnr_resp_id IS NULL OR p_ge_ptnr_resps_rec.ptnr_resp_id = FND_API.g_miss_num THEN
    LOOP
       l_dummy := NULL;
       OPEN c_id;
       FETCH c_id INTO l_ptnr_resp_id;
       CLOSE c_id;

       OPEN c_id_exists(l_ptnr_resp_id);
       FETCH c_id_exists INTO l_dummy;
       CLOSE c_id_exists;
       EXIT WHEN l_dummy IS NULL;
    END LOOP;
 ELSE
       l_ptnr_resp_id := p_ge_ptnr_resps_rec.ptnr_resp_id;
 END IF;

    -- Debug Message
    IF (PV_DEBUG_HIGH_ON) THEN

    PVX_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
    END IF;

    -- Invoke table handler(Pv_Ge_Ptnr_Resps_Pkg.Insert_Row)
    Pv_Ge_Ptnr_Resps_Pkg.Insert_Row(
        px_ptnr_resp_id  => l_ptnr_resp_id,
        p_partner_id  => p_ge_ptnr_resps_rec.partner_id,
        p_user_role_code  => p_ge_ptnr_resps_rec.user_role_code,
        p_program_id  => p_ge_ptnr_resps_rec.program_id,
        p_responsibility_id  => p_ge_ptnr_resps_rec.responsibility_id,
        p_source_resp_map_rule_id  => p_ge_ptnr_resps_rec.source_resp_map_rule_id,
        p_resp_type_code  => p_ge_ptnr_resps_rec.resp_type_code,
        px_object_version_number  => l_object_version_number,
        p_created_by  => FND_GLOBAL.USER_ID,
        p_creation_date  => SYSDATE,
        p_last_updated_by  => FND_GLOBAL.USER_ID,
        p_last_update_date  => SYSDATE,
        p_last_update_login  => FND_GLOBAL.conc_login_id
     );

        x_ptnr_resp_id := l_ptnr_resp_id;
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
   ROLLBACK TO CREATE_Ge_Ptnr_Resps_PVT;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
   );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO CREATE_Ge_Ptnr_Resps_PVT;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
   );

 WHEN OTHERS THEN
   ROLLBACK TO CREATE_Ge_Ptnr_Resps_PVT;
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
End Create_Ge_Ptnr_Resps;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Ge_Ptnr_Resps
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
--       p_ge_ptnr_resps_rec            IN   ge_ptnr_resps_rec_type  Required
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

PROCEDURE Update_Ge_Ptnr_Resps(
  p_api_version_number         IN   NUMBER,
  p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
  p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
  p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

  x_return_status              OUT NOCOPY  VARCHAR2,
  x_msg_count                  OUT NOCOPY  NUMBER,
  x_msg_data                   OUT NOCOPY  VARCHAR2,

  p_ge_ptnr_resps_rec               IN    ge_ptnr_resps_rec_type
  )

IS


CURSOR c_get_ge_ptnr_resps(ptnr_resp_id NUMBER) IS
  SELECT *
  FROM  PV_GE_PTNR_RESPS
  WHERE  ptnr_resp_id = p_ge_ptnr_resps_rec.ptnr_resp_id;
  -- Hint: Developer need to provide Where clause


L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Ge_Ptnr_Resps';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_ptnr_resp_id    NUMBER;
l_ref_ge_ptnr_resps_rec  c_get_Ge_Ptnr_Resps%ROWTYPE ;
l_tar_ge_ptnr_resps_rec  ge_ptnr_resps_rec_type := P_ge_ptnr_resps_rec;
l_rowid  ROWID;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT update_ge_ptnr_resps_pvt;

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

    OPEN c_get_Ge_Ptnr_Resps( l_tar_ge_ptnr_resps_rec.ptnr_resp_id);

    FETCH c_get_Ge_Ptnr_Resps INTO l_ref_ge_ptnr_resps_rec  ;

     If ( c_get_Ge_Ptnr_Resps%NOTFOUND) THEN
PVX_UTILITY_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
 p_token_name   => 'INFO',
p_token_value  => 'Ge_Ptnr_Resps') ;
         RAISE FND_API.G_EXC_ERROR;
     END IF;
     -- Debug Message
     IF (PV_DEBUG_HIGH_ON) THEN

     PVX_UTILITY_PVT.debug_message('Private API: - Close Cursor');
     END IF;
     CLOSE     c_get_Ge_Ptnr_Resps;


    If (l_tar_ge_ptnr_resps_rec.object_version_number is NULL or
        l_tar_ge_ptnr_resps_rec.object_version_number = FND_API.G_MISS_NUM ) Then
PVX_UTILITY_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
 p_token_name   => 'COLUMN',
p_token_value  => 'Last_Update_Date') ;
        raise FND_API.G_EXC_ERROR;
    End if;
    -- Check Whether record has been changed by someone else
    If (l_tar_ge_ptnr_resps_rec.object_version_number <> l_ref_ge_ptnr_resps_rec.object_version_number) Then
PVX_UTILITY_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
 p_token_name   => 'INFO',
p_token_value  => 'Ge_Ptnr_Resps') ;
        raise FND_API.G_EXC_ERROR;
    End if;


    IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
    THEN
        -- Debug message
        IF (PV_DEBUG_HIGH_ON) THEN

        PVX_UTILITY_PVT.debug_message('Private API: Validate_Ge_Ptnr_Resps');
        END IF;

        -- Invoke validation procedures
        Validate_ge_ptnr_resps(
          p_api_version_number     => 1.0,
          p_init_msg_list    => FND_API.G_FALSE,
          p_validation_level => p_validation_level,
          p_validation_mode => JTF_PLSQL_API.g_update,
          p_ge_ptnr_resps_rec  =>  p_ge_ptnr_resps_rec,
          x_return_status    => x_return_status,
          x_msg_count        => x_msg_count,
          x_msg_data         => x_msg_data);
    END IF;
       IF (PV_DEBUG_HIGH_ON) THEN

        PVX_UTILITY_PVT.debug_message('Private API: x_return_status = ' || x_return_status);
        END IF;

    IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
       IF (PV_DEBUG_HIGH_ON) THEN

        PVX_UTILITY_PVT.debug_message('Private API: x_return_status<>FND_API.G_RET_STS_SUCCESS');
        END IF;
        RAISE FND_API.G_EXC_ERROR;
    END IF;


    -- Debug Message
    IF (PV_DEBUG_HIGH_ON) THEN

    PVX_UTILITY_PVT.debug_message('Private API: Calling update table handler');
    END IF;

    -- Invoke table handler(Pv_Ge_Ptnr_Resps_Pkg.Update_Row)
    Pv_Ge_Ptnr_Resps_Pkg.Update_Row(
        p_ptnr_resp_id  => p_ge_ptnr_resps_rec.ptnr_resp_id,
        p_partner_id  => p_ge_ptnr_resps_rec.partner_id,
        p_user_role_code  => p_ge_ptnr_resps_rec.user_role_code,
        p_program_id  => p_ge_ptnr_resps_rec.program_id,
        p_responsibility_id  => p_ge_ptnr_resps_rec.responsibility_id,
        p_source_resp_map_rule_id  => p_ge_ptnr_resps_rec.source_resp_map_rule_id,
        p_resp_type_code  => p_ge_ptnr_resps_rec.resp_type_code,
        p_object_version_number  => p_ge_ptnr_resps_rec.object_version_number,
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
   ROLLBACK TO UPDATE_Ge_Ptnr_Resps_PVT;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
   );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO UPDATE_Ge_Ptnr_Resps_PVT;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
   );

 WHEN OTHERS THEN
   ROLLBACK TO UPDATE_Ge_Ptnr_Resps_PVT;
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
End Update_Ge_Ptnr_Resps;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Ge_Ptnr_Resps
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
--       p_ptnr_resp_id                IN   NUMBER
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

PROCEDURE Delete_Ge_Ptnr_Resps(
  p_api_version_number         IN   NUMBER,
  p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
  p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
  p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
  x_return_status              OUT NOCOPY  VARCHAR2,
  x_msg_count                  OUT NOCOPY  NUMBER,
  x_msg_data                   OUT NOCOPY  VARCHAR2,
  p_ptnr_resp_id                   IN  NUMBER,
  p_object_version_number      IN   NUMBER
  )

IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Ge_Ptnr_Resps';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT delete_ge_ptnr_resps_pvt;

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

    -- Invoke table handler(Pv_Ge_Ptnr_Resps_Pkg.Delete_Row)
    Pv_Ge_Ptnr_Resps_Pkg.Delete_Row(
        p_ptnr_resp_id  => p_ptnr_resp_id,
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
   ROLLBACK TO DELETE_Ge_Ptnr_Resps_PVT;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
   );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO DELETE_Ge_Ptnr_Resps_PVT;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
   );

 WHEN OTHERS THEN
   ROLLBACK TO DELETE_Ge_Ptnr_Resps_PVT;
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
End Delete_Ge_Ptnr_Resps;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Ge_Ptnr_Resps
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
--       p_ge_ptnr_resps_rec            IN   ge_ptnr_resps_rec_type  Required
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

PROCEDURE Lock_Ge_Ptnr_Resps(
  p_api_version_number         IN   NUMBER,
  p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

  x_return_status              OUT NOCOPY  VARCHAR2,
  x_msg_count                  OUT NOCOPY  NUMBER,
  x_msg_data                   OUT NOCOPY  VARCHAR2,

  p_ptnr_resp_id                   IN  NUMBER,
  p_object_version             IN  NUMBER
  )

IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Ge_Ptnr_Resps';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_ptnr_resp_id                  NUMBER;

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
Pv_Ge_Ptnr_Resps_Pkg.Lock_Row(l_ptnr_resp_id,p_object_version);


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
   ROLLBACK TO LOCK_Ge_Ptnr_Resps_PVT;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
   );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO LOCK_Ge_Ptnr_Resps_PVT;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
   );

 WHEN OTHERS THEN
   ROLLBACK TO LOCK_Ge_Ptnr_Resps_PVT;
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
End Lock_Ge_Ptnr_Resps;




PROCEDURE check_Ge_Ptnr_Resps_Uk_Items(
  p_ge_ptnr_resps_rec               IN   ge_ptnr_resps_rec_type,
  p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
  x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
    x_return_status := FND_API.g_ret_sts_success;
    IF p_validation_mode = JTF_PLSQL_API.g_create
    AND p_ge_ptnr_resps_rec.ptnr_resp_id IS NOT NULL
    THEN
       l_valid_flag := PVX_UTILITY_PVT.check_uniqueness(
       'pv_ge_ptnr_resps',
       'ptnr_resp_id = ''' || p_ge_ptnr_resps_rec.ptnr_resp_id ||''''
       );
    END IF;

    IF l_valid_flag = FND_API.g_false THEN
       PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_ptnr_resp_id_DUPLICATE');
       x_return_status := FND_API.g_ret_sts_error;
    END IF;

   IF p_ge_ptnr_resps_rec.PROGRAM_ID is null THEN
      l_valid_flag := PVX_UTILITY_PVT.check_uniqueness(
      'pv_ge_ptnr_resps'
      ,'PARTNER_ID = ''' || p_ge_ptnr_resps_rec.PARTNER_ID ||
       ''' AND USER_ROLE_CODE = ''' || p_ge_ptnr_resps_rec.USER_ROLE_CODE ||
       ''' AND RESPONSIBILITY_ID = ''' || p_ge_ptnr_resps_rec.RESPONSIBILITY_ID ||
       ''' AND SOURCE_RESP_MAP_RULE_ID = ''' || p_ge_ptnr_resps_rec.SOURCE_RESP_MAP_RULE_ID ||
       ''' AND RESP_TYPE_CODE = ''' || p_ge_ptnr_resps_rec.RESP_TYPE_CODE || ''''
      );
    ELSE
      l_valid_flag := PVX_UTILITY_PVT.check_uniqueness(
      'pv_ge_ptnr_resps'
      ,'PROGRAM_ID = ''' || p_ge_ptnr_resps_rec.PROGRAM_ID ||
       ''' AND PARTNER_ID = ''' || p_ge_ptnr_resps_rec.PARTNER_ID ||
       ''' AND USER_ROLE_CODE = ''' || p_ge_ptnr_resps_rec.USER_ROLE_CODE ||
       ''' AND RESPONSIBILITY_ID = ''' || p_ge_ptnr_resps_rec.RESPONSIBILITY_ID ||
       ''' AND SOURCE_RESP_MAP_RULE_ID = ''' || p_ge_ptnr_resps_rec.SOURCE_RESP_MAP_RULE_ID ||
       ''' AND RESP_TYPE_CODE = ''' || p_ge_ptnr_resps_rec.RESP_TYPE_CODE || ''''
      );
    END IF;

    IF l_valid_flag = FND_API.g_false THEN
       PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_ptnr_resp_id_DUPLICATE');
       x_return_status := FND_API.g_ret_sts_error;
    END IF;

END check_Ge_Ptnr_Resps_Uk_Items;



PROCEDURE check_Ge_Ptnr_Resps_Req_Items(
  p_ge_ptnr_resps_rec               IN  ge_ptnr_resps_rec_type,
  p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
  x_return_status              OUT NOCOPY VARCHAR2
)
IS
BEGIN
 x_return_status := FND_API.g_ret_sts_success;

 IF p_validation_mode = JTF_PLSQL_API.g_create THEN

    /*
    IF p_ge_ptnr_resps_rec.ptnr_resp_id = FND_API.G_MISS_NUM OR p_ge_ptnr_resps_rec.ptnr_resp_id IS NULL THEN
             PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'PTNR_RESP_ID' );
             x_return_status := FND_API.g_ret_sts_error;
    END IF;
    */


    IF p_ge_ptnr_resps_rec.user_role_code = FND_API.g_miss_char OR p_ge_ptnr_resps_rec.user_role_code IS NULL THEN
             PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'USER_ROLE_CODE' );
             x_return_status := FND_API.g_ret_sts_error;
    END IF;

    IF p_ge_ptnr_resps_rec.responsibility_id = FND_API.G_MISS_NUM OR p_ge_ptnr_resps_rec.responsibility_id IS NULL THEN
             PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'RESPONSIBILITY_ID' );
             x_return_status := FND_API.g_ret_sts_error;
    END IF;

    IF p_ge_ptnr_resps_rec.source_resp_map_rule_id = FND_API.G_MISS_NUM OR p_ge_ptnr_resps_rec.source_resp_map_rule_id IS NULL THEN
             PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'SOURCE_RESP_MAP_RULE_ID' );
             x_return_status := FND_API.g_ret_sts_error;
    END IF;

    IF p_ge_ptnr_resps_rec.resp_type_code = FND_API.g_miss_char OR p_ge_ptnr_resps_rec.resp_type_code IS NULL THEN
             PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'RESP_TYPE_CODE' );
             x_return_status := FND_API.g_ret_sts_error;
    END IF;

 ELSE


    IF p_ge_ptnr_resps_rec.ptnr_resp_id = FND_API.G_MISS_NUM THEN
             PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'PTNR_RESP_ID' );
             x_return_status := FND_API.g_ret_sts_error;
    END IF;


    IF p_ge_ptnr_resps_rec.user_role_code = FND_API.g_miss_char THEN
             PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'USER_ROLE_CODE' );
             x_return_status := FND_API.g_ret_sts_error;
    END IF;


    IF p_ge_ptnr_resps_rec.responsibility_id = FND_API.G_MISS_NUM THEN
             PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'RESPONSIBILITY_ID' );
             x_return_status := FND_API.g_ret_sts_error;
    END IF;

    IF p_ge_ptnr_resps_rec.source_resp_map_rule_id = FND_API.G_MISS_NUM THEN
             PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'SOURCE_RESP_MAP_RULE_ID' );
             x_return_status := FND_API.g_ret_sts_error;
    END IF;

    IF p_ge_ptnr_resps_rec.resp_type_code = FND_API.g_miss_char THEN
             PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'RESP_TYPE_CODE' );
             x_return_status := FND_API.g_ret_sts_error;
    END IF;

    IF p_ge_ptnr_resps_rec.object_version_number = FND_API.G_MISS_NUM THEN
             PVX_UTILITY_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUMBER' );
             x_return_status := FND_API.g_ret_sts_error;
    END IF;
 END IF;

END check_Ge_Ptnr_Resps_Req_Items;



PROCEDURE check_Ge_Ptnr_Resps_Fk_Items(
  p_ge_ptnr_resps_rec IN ge_ptnr_resps_rec_type,
  x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
 x_return_status := FND_API.g_ret_sts_success;

   IF (p_ge_ptnr_resps_rec.resp_type_code = 'PROGRAMS') THEN
      IF PVX_Utility_PVT.check_fk_exists(
            'pv_ge_resp_map_rules',                          -- Parent schema object having the primary key
            'resp_map_rule_id',                              -- Column name in the parent object that maps to the fk value
            p_ge_ptnr_resps_rec.source_resp_map_rule_id,     -- Value of fk to be validated against the parent object's pk column
            PVX_utility_PVT.g_number,                        -- datatype of fk
            null
      ) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('PV', 'PV_NOT_VALID_RESP_MAP_RULE_ID');
            FND_MSG_PUB.add;
         END IF;
      END IF;
   ELSIF (p_ge_ptnr_resps_rec.resp_type_code = 'STORES') THEN
      IF PVX_Utility_PVT.check_fk_exists(
            'pv_program_benefits',                          -- Parent schema object having the primary key
            'program_benefits_id',                          -- Column name in the parent object that maps to the fk value
            p_ge_ptnr_resps_rec.source_resp_map_rule_id,    -- Value of fk to be validated against the parent object's pk column
            PVX_utility_PVT.g_number,                       -- datatype of fk
            null
      ) = FND_API.g_false THEN
         IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
            FND_MESSAGE.set_name('PV', 'PV_NOT_VALID_RESP_MAP_RULE_ID');
            FND_MSG_PUB.add;
         END IF;
      END IF;
   END IF;

END check_Ge_Ptnr_Resps_Fk_Items;

PROCEDURE check_Ge_Ptr_Resp_Lkup_Item(
  p_ge_ptnr_resps_rec IN ge_ptnr_resps_rec_type,
  x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
 x_return_status := FND_API.g_ret_sts_success;

 -- Enter custom code here

END check_Ge_Ptr_Resp_Lkup_Item;

PROCEDURE Check_Ge_Ptnr_Resps_Items (
  P_ge_ptnr_resps_rec     IN    ge_ptnr_resps_rec_type,
  p_validation_mode  IN    VARCHAR2,
  x_return_status    OUT NOCOPY   VARCHAR2
  )
IS
 l_return_status   VARCHAR2(1);
BEGIN

  l_return_status := FND_API.g_ret_sts_success;
 -- Check Items Uniqueness API calls
 check_Ge_ptnr_resps_Uk_Items(
    p_ge_ptnr_resps_rec => p_ge_ptnr_resps_rec,
    p_validation_mode => p_validation_mode,
    x_return_status => x_return_status);
 IF x_return_status <> FND_API.g_ret_sts_success THEN
    l_return_status := FND_API.g_ret_sts_error;
 END IF;

 -- Check Items Required/NOT NULL API calls
 check_ge_ptnr_resps_req_items(
    p_ge_ptnr_resps_rec => p_ge_ptnr_resps_rec,
    p_validation_mode => p_validation_mode,
    x_return_status => x_return_status);
 IF x_return_status <> FND_API.g_ret_sts_success THEN
    l_return_status := FND_API.g_ret_sts_error;
 END IF;
 -- Check Items Foreign Keys API calls
 check_ge_ptnr_resps_FK_items(
    p_ge_ptnr_resps_rec => p_ge_ptnr_resps_rec,
    x_return_status => x_return_status);
 IF x_return_status <> FND_API.g_ret_sts_success THEN
    l_return_status := FND_API.g_ret_sts_error;
 END IF;
 -- Check Items Lookups
 check_Ge_Ptr_Resp_Lkup_Item(
    p_ge_ptnr_resps_rec => p_ge_ptnr_resps_rec,
    x_return_status => x_return_status);
 IF x_return_status <> FND_API.g_ret_sts_success THEN
    l_return_status := FND_API.g_ret_sts_error;
 END IF;
 x_return_status := l_return_status;

END Check_ge_ptnr_resps_Items;





PROCEDURE Complete_Ge_Ptnr_Resps_Rec (
 p_ge_ptnr_resps_rec IN ge_ptnr_resps_rec_type,
 x_complete_rec OUT NOCOPY ge_ptnr_resps_rec_type)
IS
 l_return_status  VARCHAR2(1);

 CURSOR c_complete IS
    SELECT *
    FROM pv_ge_ptnr_resps
    WHERE ptnr_resp_id = p_ge_ptnr_resps_rec.ptnr_resp_id;
 l_ge_ptnr_resps_rec c_complete%ROWTYPE;
BEGIN
 x_complete_rec := p_ge_ptnr_resps_rec;


 OPEN c_complete;
 FETCH c_complete INTO l_ge_ptnr_resps_rec;
 CLOSE c_complete;

 -- ptnr_resp_id
 IF p_ge_ptnr_resps_rec.ptnr_resp_id IS NULL THEN
    x_complete_rec.ptnr_resp_id := l_ge_ptnr_resps_rec.ptnr_resp_id;
 END IF;

 -- partner_id
 IF p_ge_ptnr_resps_rec.partner_id IS NULL THEN
    x_complete_rec.partner_id := l_ge_ptnr_resps_rec.partner_id;
 END IF;

 -- user_role_code
 IF p_ge_ptnr_resps_rec.user_role_code IS NULL THEN
    x_complete_rec.user_role_code := l_ge_ptnr_resps_rec.user_role_code;
 END IF;

 -- program_id
 IF p_ge_ptnr_resps_rec.program_id IS NULL THEN
    x_complete_rec.program_id := l_ge_ptnr_resps_rec.program_id;
 END IF;

 -- responsibility_id
 IF p_ge_ptnr_resps_rec.responsibility_id IS NULL THEN
    x_complete_rec.responsibility_id := l_ge_ptnr_resps_rec.responsibility_id;
 END IF;

 -- source_resp_map_rule_id
 IF p_ge_ptnr_resps_rec.source_resp_map_rule_id IS NULL THEN
    x_complete_rec.source_resp_map_rule_id := l_ge_ptnr_resps_rec.source_resp_map_rule_id;
 END IF;

 -- resp_type_code
 IF p_ge_ptnr_resps_rec.resp_type_code IS NULL THEN
    x_complete_rec.resp_type_code := l_ge_ptnr_resps_rec.resp_type_code;
 END IF;

 -- object_version_number
 IF p_ge_ptnr_resps_rec.object_version_number IS NULL THEN
    x_complete_rec.object_version_number := l_ge_ptnr_resps_rec.object_version_number;
 END IF;

 -- created_by
 IF p_ge_ptnr_resps_rec.created_by IS NULL THEN
    x_complete_rec.created_by := l_ge_ptnr_resps_rec.created_by;
 END IF;

 -- creation_date
 IF p_ge_ptnr_resps_rec.creation_date IS NULL THEN
    x_complete_rec.creation_date := l_ge_ptnr_resps_rec.creation_date;
 END IF;

 -- last_updated_by
 IF p_ge_ptnr_resps_rec.last_updated_by IS NULL THEN
    x_complete_rec.last_updated_by := l_ge_ptnr_resps_rec.last_updated_by;
 END IF;

 -- last_update_date
 IF p_ge_ptnr_resps_rec.last_update_date IS NULL THEN
    x_complete_rec.last_update_date := l_ge_ptnr_resps_rec.last_update_date;
 END IF;

 -- last_update_login
 IF p_ge_ptnr_resps_rec.last_update_login IS NULL THEN
    x_complete_rec.last_update_login := l_ge_ptnr_resps_rec.last_update_login;
 END IF;
 -- Note: Developers need to modify the procedure
 -- to handle any business specific requirements.
END Complete_Ge_Ptnr_Resps_Rec;




PROCEDURE Default_Ge_Ptnr_Resps_Items ( p_ge_ptnr_resps_rec IN ge_ptnr_resps_rec_type ,
                              x_ge_ptnr_resps_rec OUT NOCOPY ge_ptnr_resps_rec_type )
IS
 l_ge_ptnr_resps_rec ge_ptnr_resps_rec_type := p_ge_ptnr_resps_rec;
BEGIN
 -- Developers should put their code to default the record type
 -- e.g. IF p_campaign_rec.status_code IS NULL
 --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
 --         l_campaign_rec.status_code := 'NEW' ;
 --      END IF ;
 --
 NULL ;
END;




PROCEDURE Validate_Ge_Ptnr_Resps(
  p_api_version_number         IN   NUMBER,
  p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
  p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
  p_ge_ptnr_resps_rec               IN   ge_ptnr_resps_rec_type,
  p_validation_mode            IN    VARCHAR2,
  x_return_status              OUT NOCOPY  VARCHAR2,
  x_msg_count                  OUT NOCOPY  NUMBER,
  x_msg_data                   OUT NOCOPY  VARCHAR2
  )
IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Ge_Ptnr_Resps';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_ge_ptnr_resps_rec      ge_ptnr_resps_rec_type;
l_ge_ptnr_resps_rec_out  ge_ptnr_resps_rec_type;

BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT validate_ge_ptnr_resps_;

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
            Check_ge_ptnr_resps_Items(
               p_ge_ptnr_resps_rec        => p_ge_ptnr_resps_rec,
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
       Default_Ge_Ptnr_Resps_Items (p_ge_ptnr_resps_rec => p_ge_ptnr_resps_rec ,
                              x_ge_ptnr_resps_rec => l_ge_ptnr_resps_rec) ;
    END IF ;

    Complete_ge_ptnr_resps_Rec(
       p_ge_ptnr_resps_rec        => l_ge_ptnr_resps_rec,
       x_complete_rec             => l_ge_ptnr_resps_rec_out
    );

    l_ge_ptnr_resps_rec := l_ge_ptnr_resps_rec_out;


    IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
       Validate_ge_ptnr_resps_Rec(
         p_api_version_number     => 1.0,
         p_init_msg_list          => FND_API.G_FALSE,
         x_return_status          => x_return_status,
         x_msg_count              => x_msg_count,
         x_msg_data               => x_msg_data,
         p_ge_ptnr_resps_rec           =>    l_ge_ptnr_resps_rec);

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
   ROLLBACK TO VALIDATE_Ge_Ptnr_Resps_;
   x_return_status := FND_API.G_RET_STS_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count   => x_msg_count,
          p_data    => x_msg_data
   );

 WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
   ROLLBACK TO VALIDATE_Ge_Ptnr_Resps_;
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   -- Standard call to get message count and if count=1, get the message
   FND_MSG_PUB.Count_And_Get (
          p_encoded => FND_API.G_FALSE,
          p_count => x_msg_count,
          p_data  => x_msg_data
   );

 WHEN OTHERS THEN
   ROLLBACK TO VALIDATE_Ge_Ptnr_Resps_;
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
End Validate_Ge_Ptnr_Resps;


PROCEDURE Validate_Ge_Ptnr_Resps_Rec (
  p_api_version_number         IN   NUMBER,
  p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
  x_return_status              OUT NOCOPY  VARCHAR2,
  x_msg_count                  OUT NOCOPY  NUMBER,
  x_msg_data                   OUT NOCOPY  VARCHAR2,
  p_ge_ptnr_resps_rec               IN    ge_ptnr_resps_rec_type
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
END Validate_ge_ptnr_resps_Rec;

END PV_Ge_Ptnr_Resps_PVT;

/
