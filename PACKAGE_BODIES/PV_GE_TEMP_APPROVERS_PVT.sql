--------------------------------------------------------
--  DDL for Package Body PV_GE_TEMP_APPROVERS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_GE_TEMP_APPROVERS_PVT" as
/* $Header: pvxvptab.pls 120.3 2006/01/25 15:43:01 ktsao ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          Pv_Ge_Temp_Approvers_PVT
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'Pv_Ge_Temp_Approvers_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvptab.pls';

-- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
-- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
--
-- Foreward Procedure Declarations
--

PROCEDURE Default_Approver_Items (
   p_approver_rec IN  approver_rec_type ,
   x_approver_rec OUT NOCOPY approver_rec_type
) ;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Ptr_Enr_Temp_Appr
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
--       p_approver_rec            IN   approver_rec_type  Required
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

PROCEDURE Create_Ptr_Enr_Temp_Appr(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_approver_rec              IN   approver_rec_type  := g_miss_approver_rec,
    x_entity_approver_id              OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Ptr_Enr_Temp_Appr';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_entity_approver_id              NUMBER;
   l_dummy                     NUMBER;
   CURSOR c_id IS
      SELECT pv_ge_temp_approvers_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM PV_GE_TEMP_APPROVERS
      WHERE entity_approver_id = l_id;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_ptr_enr_temp_appr_pvt;

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
         FND_MESSAGE.Set_Name ('PV', 'USER_PROFILE_MISSING');
         FND_MSG_PUB.Add;
         RAISE FND_API.G_EXC_ERROR;
      END IF;



      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: Validate_Ptr_Enr_Temp_Appr');
          END IF;

          -- Invoke validation procedures
          Validate_ptr_enr_temp_appr(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_approver_rec  =>  p_approver_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

   -- Local variable initialization

   IF p_approver_rec.entity_approver_id IS NULL OR p_approver_rec.entity_approver_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_entity_approver_id;
         CLOSE c_id;

         OPEN c_id_exists(l_entity_approver_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
         l_entity_approver_id := p_approver_rec.entity_approver_id;
   END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(Pv_Ge_Temp_Approvers_Pkg.Insert_Row)
      Pv_Ge_Temp_Approvers_Pkg.Insert_Row(
          px_entity_approver_id  => l_entity_approver_id,
          px_object_version_number  => l_object_version_number,
          p_arc_appr_for_entity_code  => p_approver_rec.arc_appr_for_entity_code,
          p_appr_for_entity_id  => p_approver_rec.appr_for_entity_id,
          p_approver_id  => p_approver_rec.approver_id,
          p_approver_type_code  => p_approver_rec.approver_type_code,
          p_approval_status_code  => p_approver_rec.approval_status_code,
          p_workflow_item_key  => p_approver_rec.workflow_item_key,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_update_login  => FND_GLOBAL.conc_login_id
);

          x_entity_approver_id := l_entity_approver_id;
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
         FND_MESSAGE.Set_Name ('PV', 'PV_API_RESOURCE_LOCKED');
         FND_MSG_PUB.Add;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Ptr_Enr_Temp_Appr_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Ptr_Enr_Temp_Appr_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Ptr_Enr_Temp_Appr_PVT;
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
End Create_Ptr_Enr_Temp_Appr;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Ptr_Enr_Temp_Appr
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
--       p_approver_rec            IN   approver_rec_type  Required
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

PROCEDURE Update_Ptr_Enr_Temp_Appr(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_approver_rec               IN    approver_rec_type
    )

 IS


CURSOR c_get_ptr_enr_temp_appr(entity_approver_id NUMBER) IS
    SELECT *
    FROM  PV_GE_TEMP_APPROVERS
    WHERE  entity_approver_id = p_approver_rec.entity_approver_id;
    -- Hint: Developer need to provide Where clause


L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Ptr_Enr_Temp_Appr';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_entity_approver_id    NUMBER;
l_ref_approver_rec  c_get_Ptr_Enr_Temp_Appr%ROWTYPE ;
l_tar_approver_rec  approver_rec_type := P_approver_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_ptr_enr_temp_appr_pvt;

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

      OPEN c_get_Ptr_Enr_Temp_Appr( l_tar_approver_rec.entity_approver_id);

      FETCH c_get_Ptr_Enr_Temp_Appr INTO l_ref_approver_rec  ;

      If ( c_get_Ptr_Enr_Temp_Appr%NOTFOUND) THEN

        --kvattiku: Oct 27, 05 Commented out and replacing it with FND_MSG calls
	--PVX_UTILITY_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
	--	p_token_name   => 'INFO',
	--	p_token_value  => 'Ptr_Enr_Temp_Appr') ;
	--RAISE FND_API.G_EXC_ERROR;

	FND_MESSAGE.Set_Name ('PV', 'API_MISSING_UPDATE_TARGET');
        FND_MESSAGE.Set_Token('INFO', 'Ptr_Enr_Temp_Appr');
        FND_MSG_PUB.Add;
	x_return_status := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;
      END IF;

       -- Debug Message
       IF (PV_DEBUG_HIGH_ON) THEN

       PVX_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       END IF;
       CLOSE     c_get_Ptr_Enr_Temp_Appr;


      If (l_tar_approver_rec.object_version_number is NULL or
          l_tar_approver_rec.object_version_number = FND_API.G_MISS_NUM )
      Then

	--kvattiku: Oct 27, 05 Commented out and replacing it with FND_MSG calls
	--PVX_UTILITY_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
	--	p_token_name   => 'COLUMN',
	--	p_token_value  => 'Last_Update_Date') ;
	--raise FND_API.G_EXC_ERROR;

	FND_MESSAGE.Set_Name ('PV', 'API_VERSION_MISSING');
        FND_MESSAGE.Set_Token('COLUMN', 'Last_Update_Date');
        FND_MSG_PUB.Add;
	x_return_status := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;

      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_approver_rec.object_version_number <> l_ref_approver_rec.object_version_number)
      Then

	--kvattiku: Oct 27, 05 Commented out and replacing it with FND_MSG calls
	--PVX_UTILITY_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
	--	p_token_name   => 'INFO',
	--	p_token_value  => 'Ptr_Enr_Temp_Appr') ;
        --raise FND_API.G_EXC_ERROR;

	FND_MESSAGE.Set_Name ('PV', 'API_RECORD_CHANGED');
        FND_MESSAGE.Set_Token('INFO', 'Ptr_Enr_Temp_Appr');
        FND_MSG_PUB.Add;
	x_return_status := FND_API.G_RET_STS_ERROR;
	RAISE FND_API.G_EXC_ERROR;

      End if;


      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          IF (PV_DEBUG_HIGH_ON) THEN

          PVX_UTILITY_PVT.debug_message('Private API: Validate_Ptr_Enr_Temp_Appr');
          END IF;

          -- Invoke validation procedures
          Validate_ptr_enr_temp_appr(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_approver_rec  =>  p_approver_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN

      PVX_UTILITY_PVT.debug_message( 'Private API: Calling update table handler');
      END IF;

      -- Invoke table handler(Pv_Ge_Temp_Approvers_Pkg.Update_Row)
      Pv_Ge_Temp_Approvers_Pkg.Update_Row(
          p_entity_approver_id  => p_approver_rec.entity_approver_id,
          p_object_version_number  => p_approver_rec.object_version_number,
          p_arc_appr_for_entity_code  => p_approver_rec.arc_appr_for_entity_code,
          p_appr_for_entity_id  => p_approver_rec.appr_for_entity_id,
          p_approver_id  => p_approver_rec.approver_id,
          p_approver_type_code  => p_approver_rec.approver_type_code,
          p_approval_status_code  => p_approver_rec.approval_status_code,
          p_workflow_item_key  => p_approver_rec.workflow_item_key,
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
   WHEN PVX_Utility_PVT.API_RECORD_CHANGED THEN
      x_return_status := Fnd_Api.G_RET_STS_ERROR;
      IF (PV_DEBUG_HIGH_ON) THEN
         Pvx_Utility_Pvt.debug_message('PRIVATE API: - OPEN CURSOR');
      END IF;
      OPEN c_get_Ptr_Enr_Temp_Appr( l_tar_approver_rec.entity_approver_id);
      FETCH c_get_Ptr_Enr_Temp_Appr INTO l_ref_approver_rec  ;
      If ( c_get_Ptr_Enr_Temp_Appr%NOTFOUND) THEN
         FND_MESSAGE.Set_Name ('PV', 'API_MISSING_UPDATE_TARGET');
         FND_MESSAGE.Set_Token('INFO', 'Ptr_Enr_Temp_Appr');
         FND_MSG_PUB.Add;
       END IF;
       -- Debug Message
       IF (PV_DEBUG_HIGH_ON) THEN
           Pvx_Utility_Pvt.debug_message('PRIVATE API: - CLOSE CURSOR');
       END IF;
       CLOSE     c_get_Ptr_Enr_Temp_Appr;
       If (l_tar_approver_rec.object_version_number <> l_ref_approver_rec.object_version_number) THEN
         x_return_status := Fnd_Api.G_RET_STS_ERROR;
         FND_MESSAGE.Set_Name ('PV', 'API_RECORD_CHANGED');
         FND_MESSAGE.Set_Token('INFO', 'Ptr_Enr_Temp_Appr');
         FND_MSG_PUB.Add;
       END IF;
      Fnd_Msg_Pub.Count_And_Get (
                p_encoded => Fnd_Api.G_FALSE,
                p_count   => x_msg_count,
                p_data    => x_msg_data
         );

   WHEN PVX_UTILITY_PVT.resource_locked THEN

   	--kvattiku: Oct 27, 05 Commented out and replacing it with FND_MSG calls
	--x_return_status := FND_API.g_ret_sts_error;
        --PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

	FND_MESSAGE.Set_Name ('PV', 'PV_API_RESOURCE_LOCKED');
        FND_MSG_PUB.Add;
	x_return_status := FND_API.G_RET_STS_ERROR;

	FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
	);


   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Ptr_Enr_Temp_Appr_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Ptr_Enr_Temp_Appr_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Ptr_Enr_Temp_Appr_PVT;
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
End Update_Ptr_Enr_Temp_Appr;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Ptr_Enr_Temp_Appr
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
--       p_entity_approver_id                IN   NUMBER
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

PROCEDURE Delete_Ptr_Enr_Temp_Appr(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_entity_approver_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Ptr_Enr_Temp_Appr';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_ptr_enr_temp_appr_pvt;

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

      -- Invoke table handler(Pv_Ge_Temp_Approvers_Pkg.Delete_Row)
      Pv_Ge_Temp_Approvers_Pkg.Delete_Row(
          p_entity_approver_id  => p_entity_approver_id,
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
         FND_MESSAGE.Set_Name ('PV', 'PV_API_RESOURCE_LOCKED');
         FND_MSG_PUB.Add;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Ptr_Enr_Temp_Appr_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Ptr_Enr_Temp_Appr_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Ptr_Enr_Temp_Appr_PVT;
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
End Delete_Ptr_Enr_Temp_Appr;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Ptr_Enr_Temp_Appr
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
--       p_approver_rec            IN   approver_rec_type  Required
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

PROCEDURE Lock_Ptr_Enr_Temp_Appr(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_entity_approver_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Ptr_Enr_Temp_Appr';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_entity_approver_id                  NUMBER;

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
Pv_Ge_Temp_Approvers_Pkg.Lock_Row(l_entity_approver_id,p_object_version);


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
         FND_MESSAGE.Set_Name ('PV', 'PV_API_RESOURCE_LOCKED');
         FND_MSG_PUB.Add;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Ptr_Enr_Temp_Appr_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Ptr_Enr_Temp_Appr_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Ptr_Enr_Temp_Appr_PVT;
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
End Lock_Ptr_Enr_Temp_Appr;




PROCEDURE check_Approver_Uk_Items(
    p_approver_rec               IN   approver_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_approver_rec.entity_approver_id IS NOT NULL
      THEN
         l_valid_flag := PVX_UTILITY_PVT.check_uniqueness(
         'pv_ge_temp_approvers',
         'entity_approver_id = ''' || p_approver_rec.entity_approver_id ||''''
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         FND_MESSAGE.Set_Name ('PV', 'PV_entity_approver_id_DUPLICATE');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

END check_Approver_Uk_Items;



PROCEDURE check_Approver_Req_Items(
    p_approver_rec               IN  approver_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      IF p_approver_rec.arc_appr_for_entity_code = FND_API.g_miss_char OR p_approver_rec.arc_appr_for_entity_code IS NULL THEN
         FND_MESSAGE.Set_Name ('PV', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.Set_Token('MISS_FIELD', 'ARC_APPR_FOR_ENTITY_CODE');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_approver_rec.appr_for_entity_id = FND_API.G_MISS_NUM OR p_approver_rec.appr_for_entity_id IS NULL THEN
         FND_MESSAGE.Set_Name ('PV', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.Set_Token('MISS_FIELD', 'APPR_FOR_ENTITY_ID');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_approver_rec.approval_status_code = FND_API.g_miss_char OR p_approver_rec.approval_status_code IS NULL THEN
         FND_MESSAGE.Set_Name ('PV', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.Set_Token('MISS_FIELD', 'APPROVAL_STATUS_CODE');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


   ELSE


      IF p_approver_rec.entity_approver_id = FND_API.G_MISS_NUM THEN
         FND_MESSAGE.Set_Name ('PV', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.Set_Token('MISS_FIELD', 'ENTITY_APPROVER_ID');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_approver_rec.object_version_number = FND_API.G_MISS_NUM THEN
         FND_MESSAGE.Set_Name ('PV', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.Set_Token('MISS_FIELD', 'OBJECT_VERSION_NUMBER');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_approver_rec.arc_appr_for_entity_code = FND_API.g_miss_char THEN
         FND_MESSAGE.Set_Name ('PV', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.Set_Token('MISS_FIELD', 'ARC_APPR_FOR_ENTITY_CODE');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_approver_rec.appr_for_entity_id = FND_API.G_MISS_NUM THEN
         FND_MESSAGE.Set_Name ('PV', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.Set_Token('MISS_FIELD', 'APPR_FOR_ENTITY_ID');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_approver_rec.approval_status_code = FND_API.g_miss_char THEN
         FND_MESSAGE.Set_Name ('PV', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.Set_Token('MISS_FIELD', 'APPROVAL_STATUS_CODE');
         FND_MSG_PUB.Add;
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_Approver_Req_Items;



PROCEDURE check_Approver_Fk_Items(
    p_approver_rec IN approver_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Approver_Fk_Items;



PROCEDURE check_Approver_Lookup_Items(
    p_approver_rec IN approver_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Approver_Lookup_Items;



PROCEDURE Check_Approver_Items (
    P_approver_rec     IN    approver_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

    l_return_status := FND_API.g_ret_sts_success;
   -- Check Items Uniqueness API calls

   check_Approver_Uk_Items(
      p_approver_rec => p_approver_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_approver_req_items(
      p_approver_rec => p_approver_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Foreign Keys API calls

   check_approver_FK_items(
      p_approver_rec => p_approver_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Lookups

   check_approver_Lookup_items(
      p_approver_rec => p_approver_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   x_return_status := l_return_status;

END Check_approver_Items;





PROCEDURE Complete_Approver_Rec (
   p_approver_rec IN approver_rec_type,
   x_complete_rec OUT NOCOPY approver_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM pv_ge_temp_approvers
      WHERE entity_approver_id = p_approver_rec.entity_approver_id;
   l_approver_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_approver_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_approver_rec;
   CLOSE c_complete;

   -- entity_approver_id
   IF p_approver_rec.entity_approver_id IS NULL THEN
      x_complete_rec.entity_approver_id := l_approver_rec.entity_approver_id;
   END IF;

   -- object_version_number
   IF p_approver_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_approver_rec.object_version_number;
   END IF;

   -- arc_appr_for_entity_code
   IF p_approver_rec.arc_appr_for_entity_code IS NULL THEN
      x_complete_rec.arc_appr_for_entity_code := l_approver_rec.arc_appr_for_entity_code;
   END IF;

   -- appr_for_entity_id
   IF p_approver_rec.appr_for_entity_id IS NULL THEN
      x_complete_rec.appr_for_entity_id := l_approver_rec.appr_for_entity_id;
   END IF;

   -- approver_id
   IF p_approver_rec.approver_id IS NULL THEN
      x_complete_rec.approver_id := l_approver_rec.approver_id;
   END IF;

   -- approver_type_code
   IF p_approver_rec.approver_type_code IS NULL THEN
      x_complete_rec.approver_type_code := l_approver_rec.approver_type_code;
   END IF;

   -- approval_status_code
   IF p_approver_rec.approval_status_code IS NULL THEN
      x_complete_rec.approval_status_code := l_approver_rec.approval_status_code;
   END IF;

   -- workflow_item_key
   IF p_approver_rec.workflow_item_key IS NULL THEN
      x_complete_rec.workflow_item_key := l_approver_rec.workflow_item_key;
   END IF;

   -- created_by
   IF p_approver_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_approver_rec.created_by;
   END IF;

   -- creation_date
   IF p_approver_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_approver_rec.creation_date;
   END IF;

   -- last_updated_by
   IF p_approver_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_approver_rec.last_updated_by;
   END IF;

   -- last_update_date
   IF p_approver_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_approver_rec.last_update_date;
   END IF;

   -- last_update_login
   IF p_approver_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_approver_rec.last_update_login;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Approver_Rec;




PROCEDURE Default_Approver_Items ( p_approver_rec IN approver_rec_type ,
                                x_approver_rec OUT NOCOPY approver_rec_type )
IS
   l_approver_rec approver_rec_type := p_approver_rec;
BEGIN
   -- Developers should put their code to default the record type
   -- e.g. IF p_campaign_rec.status_code IS NULL
   --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
   --         l_campaign_rec.status_code := 'NEW' ;
   --      END IF ;
   --
   NULL ;
END;




PROCEDURE Validate_Ptr_Enr_Temp_Appr(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_approver_rec               IN   approver_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Ptr_Enr_Temp_Appr';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_approver_rec       approver_rec_type;
l_approver_rec_out   approver_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_ptr_enr_temp_appr_;

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
              Check_approver_Items(
                 p_approver_rec        => p_approver_rec,
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
         Default_Approver_Items (p_approver_rec => p_approver_rec ,
                                x_approver_rec => l_approver_rec) ;
      END IF ;


      Complete_approver_Rec(
         p_approver_rec        => l_approver_rec,
         x_complete_rec        => l_approver_rec_out
      );

      l_approver_rec := l_approver_rec_out;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_approver_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_approver_rec           =>    l_approver_rec);

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
         FND_MESSAGE.Set_Name ('PV', 'PV_API_RESOURCE_LOCKED');
         FND_MSG_PUB.Add;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Ptr_Enr_Temp_Appr_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Ptr_Enr_Temp_Appr_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Ptr_Enr_Temp_Appr_;
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
End Validate_Ptr_Enr_Temp_Appr;


PROCEDURE Validate_Approver_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_approver_rec               IN    approver_rec_type
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
END Validate_approver_Rec;

END Pv_Ge_Temp_Approvers_PVT;

/
