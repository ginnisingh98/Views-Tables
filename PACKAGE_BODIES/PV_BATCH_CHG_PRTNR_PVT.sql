--------------------------------------------------------
--  DDL for Package Body PV_BATCH_CHG_PRTNR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PV_BATCH_CHG_PRTNR_PVT" as
/* $Header: pvxvchpb.pls 120.1 2005/09/05 22:40:54 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          PV_BTCH_Chg_Prtnrs_PVT
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


G_PKG_NAME CONSTANT VARCHAR2(30):= 'PV_Batch_Chg_Prtnrs_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'pvxvchpb.pls';

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
--           Create_Batch_Chg_Partners
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
--       p_batch_chg_prtnrs_rec    IN   Batch_Chg_Prtnrs_Rec_Type  Required
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

PROCEDURE Create_Batch_Chg_Partners(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_batch_chg_prtnrs_rec       IN   Batch_Chg_Prtnrs_Rec_Type  := g_miss_Batch_Chg_Prtnrs_rec,
    x_partner_id              OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Batch_Chg_Partners';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER ;
   l_partner_id              NUMBER;
   l_dummy                     NUMBER;
   l_err_msg                   VARCHAR2(2000);

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT Create_Batch_Chg_Partners;

      -- Standard call to Chk for call compatibility.
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

      -- Local variable initialization

      IF p_batch_chg_prtnrs_rec.partner_id IS NULL OR
         p_batch_chg_prtnrs_rec.partner_id = FND_API.g_miss_num THEN
         FND_MESSAGE.set_name('PV', 'PV_API_MISSING_REQ_COLUMN');
         FND_MESSAGE.set_token('COLUMN', 'PARTNER_ID');
	 FND_MSG_PUB.add;
         RAISE FND_API.G_EXC_ERROR;
      ELSE
         l_partner_id := p_batch_chg_prtnrs_rec.partner_id;
      END IF;


      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');
      END IF;

      -- Invoke table handler(Pv_BTCH_Chg_Prtnrs_Pkg.Insert_Row)
      PV_BATCH_CHG_PRTNR_PKG.Insert_Row(
             px_partner_id  => l_partner_id,
             p_last_update_date  => SYSDATE,
             p_last_update_by  => p_batch_chg_prtnrs_rec.last_update_by,
             p_creation_date  => SYSDATE,
             p_created_by  => FND_GLOBAL.USER_ID,
             p_last_update_login  => FND_GLOBAL.conc_login_id,
	     p_object_version_number => p_batch_chg_prtnrs_rec.object_version_number,
             p_request_id  => p_batch_chg_prtnrs_rec.request_id,
             p_program_application_id  => p_batch_chg_prtnrs_rec.program_application_id,
             p_program_id  => p_batch_chg_prtnrs_rec.program_id,
             p_program_update_date  =>p_batch_chg_prtnrs_rec.program_update_date,
             p_processed_flag  =>p_batch_chg_prtnrs_rec.processed_flag,
	     p_vad_partner_id => p_batch_chg_prtnrs_rec.vad_partner_id,
	     x_return_status => x_return_status  );

          IF x_return_status = FND_API.G_RET_STS_ERROR THEN
		RAISE FND_API.G_EXC_ERROR;
	  ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
          END IF;

      x_partner_id := l_partner_id;

      --
      -- End of API body
      --

      -- Standard Chk for p_commit
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
     ROLLBACK TO Create_Batch_Chg_Partners;
     x_return_status := FND_API.G_RET_STS_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO Create_Batch_Chg_Partners;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO Create_Batch_Chg_Partners;
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
End Create_Batch_Chg_Partners;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Batch_Chg_Partners
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
--       p_batch_chg_prtnrs_rec    IN   Batch_Chg_Prtnrs_Rec_Type  Required
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

PROCEDURE Update_Batch_Chg_Partners(
     p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_batch_chg_prtnrs_rec IN   Batch_Chg_Prtnrs_REC_TYPE
    )

 IS


CURSOR c_get_BTCH_Chg_Prtnrs(partner_id NUMBER) IS
    SELECT *
    FROM  PV_TAP_BATCH_CHG_PARTNERS
    WHERE  partner_id = p_batch_chg_prtnrs_rec.partner_id;

    -- Hint: Developer need to provide Where clause


L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Batch_Chg_Partners';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_partner_id    NUMBER;
l_ref_BTCH_Chg_Prtnrs_rec  c_get_BTCH_Chg_Prtnrs%ROWTYPE ;
l_tar_BTCH_Chg_Prtnrs_rec  Batch_Chg_Prtnrs_Rec_Type := p_batch_chg_prtnrs_rec;
l_rowid  ROWID;
l_err_msg                   VARCHAR2(2000);

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_BTCH_Chg_Prtnrs_pvt;

      -- Standard call to Chk for call compatibility.
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

      OPEN c_get_BTCH_Chg_Prtnrs( l_tar_BTCH_Chg_Prtnrs_rec.partner_id);

      FETCH c_get_BTCH_Chg_Prtnrs INTO l_ref_BTCH_Chg_Prtnrs_rec  ;

      IF ( c_get_BTCH_Chg_Prtnrs%NOTFOUND) THEN
         PVX_UTILITY_PVT.Error_Message(
             p_message_name => 'API_MISSING_UPDATE_TARGET',
             p_token_name   => 'INFO',
             p_token_value  => 'PV_TAP_BATCH_CHG_PARTNERS') ;
         RAISE FND_API.G_EXC_ERROR;
       END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message('Private API: - Close Cursor');
      END IF;

      CLOSE c_get_BTCH_Chg_Prtnrs;


      If (l_tar_btch_Chg_Prtnrs_rec.object_version_number is NULL or
          l_tar_btch_Chg_Prtnrs_rec.object_version_number = FND_API.G_MISS_NUM ) Then
          PVX_UTILITY_PVT.Error_Message(
	      p_message_name => 'API_VERSION_MISSING',
              p_token_name   => 'COLUMN',
              p_token_value  => 'object_version_number') ;
          raise FND_API.G_EXC_ERROR;
      End if;

      -- Chk Whether record has been changed by someone else
      IF (l_tar_BTCH_Chg_Prtnrs_rec.object_version_number <> l_ref_BTCH_Chg_Prtnrs_rec.object_version_number) THEN
         PVX_UTILITY_PVT.Error_Message(
             p_message_name => 'API_RECORD_CHANGED',
             p_token_name   => 'INFO',
             p_token_value  => 'BTCH_Chg_Prtnrs') ;
          raise FND_API.G_EXC_ERROR;
      END IF;


      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN

          -- Invoke validation procedures
          Validate_Batch_Chg_Partners(
            p_api_version_number   => 1.0,
            p_init_msg_list        => FND_API.G_FALSE,
            p_validation_level     => p_validation_level,
            p_batch_chg_prtnrs_rec  =>  p_batch_chg_prtnrs_rec,
	    p_validation_mode      => JTF_PLSQL_API.g_update,
            x_return_status        => x_return_status,
            x_msg_count            => x_msg_count,
            x_msg_data             => x_msg_data);


         IF x_return_status = FND_API.G_RET_STS_ERROR THEN
             RAISE FND_API.G_EXC_ERROR;
	 ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	     RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	 END IF;

      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message('Private API: Calling update table handler');
      END IF;

      -- Invoke table handler(Pv_BTCH_Chg_Prtnrs_Pkg.Update_Row)
      PV_BATCH_CHG_PRTNR_PKG.Update_Row(
          p_partner_id  => p_batch_chg_prtnrs_rec.partner_id,
          p_last_update_date  => SYSDATE,
          p_last_update_by  => p_batch_chg_prtnrs_rec.last_update_by,
          p_last_update_login  => p_batch_chg_prtnrs_rec.last_update_login,
          p_object_version_number => p_batch_chg_prtnrs_rec.object_version_number,
          p_request_id  => p_batch_chg_prtnrs_rec.request_id,
          p_program_application_id  => p_batch_chg_prtnrs_rec.program_application_id,
          p_program_id  => p_batch_chg_prtnrs_rec.program_id,
          p_program_update_date  => p_batch_chg_prtnrs_rec.program_update_date,
          p_processed_flag  => p_batch_chg_prtnrs_rec.processed_flag,
	  p_vad_partner_id =>  p_batch_chg_prtnrs_rec.vad_partner_id,
	  x_return_status => x_return_status );

      PVX_UTILITY_PVT.debug_message('+++++++++++++++++++++++++++++++++x_return_status =>'||x_return_status);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      --
      -- End of API body.
      --

      -- Standard Chk for p_commit
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
     ROLLBACK TO UPDATE_BTCH_Chg_Prtnrs_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_BTCH_Chg_Prtnrs_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_BTCH_Chg_Prtnrs_PVT;
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
End Update_Batch_Chg_Partners;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Batch_Chg_Prtnrs
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
--       p_partner_id                IN   NUMBER
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

PROCEDURE Delete_Batch_Chg_Prtnrs(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_partner_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_BTCH_Chg_Prtnrs';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_err_msg                   VARCHAR2(2000);

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_BTCH_Chg_Prtnrs_pvt;

      -- Standard call to Chk for call compatibility.
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

      -- Invoke table handler(Pv_BTCH_Chg_Prtnrs_Pkg.Delete_Row)
      PV_BATCH_CHG_PRTNR_PKG.Delete_Row(
          p_partner_id  => p_partner_id,
          p_object_version_number => p_object_version_number ,
	  x_return_status => x_return_status);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      --
      -- End of API body
      --

      -- Standard Chk for p_commit
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
     ROLLBACK TO DELETE_BTCH_Chg_Prtnrs_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_BTCH_Chg_Prtnrs_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_BTCH_Chg_Prtnrs_PVT;
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
End Delete_Batch_Chg_Prtnrs;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Batch_Chg_Prtnrs
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
--       p_batch_chg_prtnrs_rec            IN   Batch_Chg_Prtnrs_Rec_Type  Required
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

PROCEDURE Lock_Batch_Chg_Prtnrs(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_partner_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_BTCH_Chg_Prtnrs';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_partner_id                  NUMBER;
l_err_msg                   VARCHAR2(2000);

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



      -- Standard call to Chk for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      PV_BATCH_CHG_PRTNR_PKG.Lock_Row(l_partner_id,p_object_version,x_return_status);

      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
         RAISE FND_API.G_EXC_ERROR;
      ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
	 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      FND_MSG_PUB.count_and_get(
          p_encoded => FND_API.g_false,
          p_count   => x_msg_count,
          p_data    => x_msg_data);

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
         PVX_UTILITY_PVT.debug_message(l_full_name ||': end');
      END IF;

EXCEPTION

   WHEN PVX_UTILITY_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         PVX_UTILITY_PVT.Error_Message(p_message_name => 'PV_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_BTCH_Chg_Prtnrs_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_BTCH_Chg_Prtnrs_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_BTCH_Chg_Prtnrs_PVT;
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
End Lock_Batch_Chg_Prtnrs;




PROCEDURE Chk_BTCH_Chg_Prtnrs_Uk_Items(
    p_batch_chg_prtnrs_rec       IN   Batch_Chg_Prtnrs_Rec_Type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_batch_chg_prtnrs_rec.partner_id IS NOT NULL
      THEN
         l_valid_flag := PVX_UTILITY_PVT.Check_uniqueness(
         'pv_tap_batch_chg_partners',
         'partner_id = ''' || p_batch_chg_prtnrs_rec.partner_id ||''''
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

END Chk_BTCH_Chg_Prtnrs_Uk_Items;



PROCEDURE Chk_BTCH_Chg_Prtnrs_Req_Items(
    p_batch_chg_prtnrs_rec IN  Batch_Chg_Prtnrs_Rec_Type,
    p_validation_mode      IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status        OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;


   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      -- Check for required column PARTNER_ID
      IF p_batch_chg_prtnrs_rec.partner_id = FND_API.G_MISS_NUM OR p_batch_chg_prtnrs_rec.partner_id IS NULL THEN
         PVX_UTILITY_PVT.Error_Message('PV_API_MISSING_REQ_COLUMN', 'COLUMN', 'PARTNER_ID' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

   ELSE

      -- Check for required column PARTNER_ID
      IF p_batch_chg_prtnrs_rec.partner_id = FND_API.G_MISS_NUM THEN
         PVX_UTILITY_PVT.Error_Message('PV_API_MISSING_REQ_COLUMN', 'COLUMN', 'PARTNER_ID' );
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

   END IF;

END Chk_BTCH_Chg_Prtnrs_Req_Items;

PROCEDURE Chk_BTCH_Chg_Prtnrs_Fk_Items(
    p_batch_chg_prtnrs_rec IN Batch_Chg_Prtnrs_Rec_Type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
  -- check, the supplied partner in the PV_PARTNER_PROFILES table is ACTIVE and EXISTS.
  CURSOR l_chk_partner_active_csr(cv_partner_id IN NUMBER) IS
     SELECT 'Y'
     FROM pv_partner_profiles
     WHERE partner_id = cv_partner_id
     AND   status = 'A';

  -- Local variale declaration.
  l_partner_active      VARCHAR2(1) := 'N';

BEGIN
   x_return_status := FND_API.g_ret_sts_success;

  -- check, the supplied partner is an ACTIVE partner.
  OPEN l_chk_partner_active_csr(p_batch_chg_prtnrs_rec.partner_id);
  FETCH l_chk_partner_active_csr INTO l_partner_active;

  IF l_chk_partner_active_csr%NOTFOUND THEN
       CLOSE l_chk_partner_active_csr ;
       PVX_UTILITY_PVT.Error_Message('PV_PARTNER_NOT_ACTIVE');
       x_return_status := FND_API.g_ret_sts_error;
  ELSE
       CLOSE l_chk_partner_active_csr ;
  END IF;

END Chk_BTCH_Chg_Prtnrs_Fk_Items;

PROCEDURE Check_Batch_Chg_Prtnrs_Items (
    p_batch_chg_prtnrs_rec     IN    Batch_Chg_Prtnrs_REC_TYPE,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

    l_return_status := FND_API.g_ret_sts_success;

   -- Chk Items Uniqueness API calls

   Chk_BTCH_Chg_Prtnrs_Uk_Items(
      p_batch_chg_prtnrs_rec => p_batch_chg_prtnrs_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Chk Items Required/NOT NULL API calls

   Chk_BTCH_Chg_Prtnrs_req_items(
      p_batch_chg_prtnrs_rec => p_batch_chg_prtnrs_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Chk Items Foreign Keys API calls

   Chk_BTCH_Chg_Prtnrs_FK_items(
      p_batch_chg_prtnrs_rec => p_batch_chg_prtnrs_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   x_return_status := l_return_status;

END Check_Batch_Chg_Prtnrs_Items;

PROCEDURE Complete_BTCH_Chg_Prtnrs_Rec (
   p_batch_chg_prtnrs_rec IN Batch_Chg_Prtnrs_Rec_Type,
   x_complete_rec OUT NOCOPY Batch_Chg_Prtnrs_Rec_Type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM PV_TAP_BATCH_CHG_PARTNERS
      WHERE partner_id = p_batch_chg_prtnrs_rec.partner_id;

   l_btch_chg_prtnrs_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_batch_chg_prtnrs_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_btch_chg_prtnrs_rec;
   CLOSE c_complete;

   -- partner_id
   IF p_batch_chg_prtnrs_rec.partner_id IS NULL THEN
      x_complete_rec.partner_id := l_btch_chg_prtnrs_rec.partner_id;
   END IF;

   -- last_update_date
   IF p_batch_chg_prtnrs_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_btch_chg_prtnrs_rec.last_update_date;
   END IF;

   -- last_update_by
   IF p_batch_chg_prtnrs_rec.last_update_by IS NULL THEN
      x_complete_rec.last_update_by := l_btch_chg_prtnrs_rec.last_update_by;
   END IF;

   -- creation_date
   IF p_batch_chg_prtnrs_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_btch_chg_prtnrs_rec.creation_date;
   END IF;

   -- created_by
   IF p_batch_chg_prtnrs_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_btch_chg_prtnrs_rec.created_by;
   END IF;

   -- last_update_login
   IF p_batch_chg_prtnrs_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_btch_chg_prtnrs_rec.last_update_login;
   END IF;

   -- request_id
   IF p_batch_chg_prtnrs_rec.request_id IS NULL THEN
      x_complete_rec.request_id := l_btch_chg_prtnrs_rec.request_id;
   END IF;

   -- program_application_id
   IF p_batch_chg_prtnrs_rec.program_application_id IS NULL THEN
      x_complete_rec.program_application_id := l_btch_chg_prtnrs_rec.program_application_id;
   END IF;

   -- program_id
   IF p_batch_chg_prtnrs_rec.program_id IS NULL THEN
      x_complete_rec.program_id := l_btch_chg_prtnrs_rec.program_id;
   END IF;

   -- program_update_date
   IF p_batch_chg_prtnrs_rec.program_update_date IS NULL THEN
      x_complete_rec.program_update_date := l_btch_chg_prtnrs_rec.program_update_date;
   END IF;

   -- processed_flag
   IF p_batch_chg_prtnrs_rec.processed_flag IS NULL THEN
      x_complete_rec.processed_flag := l_btch_chg_prtnrs_rec.processed_flag;
   END IF;

      -- processed_flag
   IF p_batch_chg_prtnrs_rec.vad_partner_id IS NULL THEN
      x_complete_rec.vad_partner_id := l_btch_chg_prtnrs_rec.vad_partner_id;
   END IF;

   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_BTCH_Chg_Prtnrs_Rec;

PROCEDURE Default_BTCH_Chg_Prtnrs_Items ( p_batch_chg_prtnrs_rec IN Batch_Chg_Prtnrs_Rec_Type ,
                                x_btch_chg_prtnrs_rec OUT NOCOPY Batch_Chg_Prtnrs_Rec_Type )
IS
   l_btch_chg_prtnrs_rec Batch_Chg_Prtnrs_Rec_Type := p_batch_chg_prtnrs_rec;
BEGIN
   IF p_batch_chg_prtnrs_rec.last_update_date IS NULL OR
      p_batch_chg_prtnrs_rec.last_update_date = FND_API.G_MISS_DATE THEN

            l_btch_chg_prtnrs_rec.last_update_date := sysdate ;

   END IF ;

   IF p_batch_chg_prtnrs_rec.last_update_by IS NULL OR
      p_batch_chg_prtnrs_rec.last_update_by = FND_API.G_MISS_NUM THEN

            l_btch_chg_prtnrs_rec.last_update_by := FND_GLOBAL.user_id ;

   END IF ;

   IF p_batch_chg_prtnrs_rec.creation_date IS NULL OR
      p_batch_chg_prtnrs_rec.creation_date = FND_API.G_MISS_DATE THEN

            l_btch_chg_prtnrs_rec.creation_date := sysdate ;

   END IF ;

   IF p_batch_chg_prtnrs_rec.created_by IS NULL OR
      p_batch_chg_prtnrs_rec.created_by = FND_API.G_MISS_NUM THEN

            l_btch_chg_prtnrs_rec.created_by := FND_GLOBAL.user_id ;

   END IF ;

   IF p_batch_chg_prtnrs_rec.last_update_login IS NULL OR
      p_batch_chg_prtnrs_rec.last_update_login = FND_API.G_MISS_NUM THEN

            l_btch_chg_prtnrs_rec.last_update_login := FND_GLOBAL.user_id ;

   END IF ;

   IF p_batch_chg_prtnrs_rec.processed_flag  IS NULL OR
      p_batch_chg_prtnrs_rec.processed_flag  = FND_API.G_MISS_CHAR THEN
            l_btch_Chg_Prtnrs_rec.processed_flag := 'P' ;
   END IF ;

   x_btch_chg_prtnrs_rec := l_btch_chg_prtnrs_rec;
END;

PROCEDURE Validate_Batch_Chg_Partners(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_batch_chg_prtnrs_rec        IN   Batch_Chg_Prtnrs_Rec_Type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Batch_Chg_Partners';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_batch_chg_prtnrs_rec  Batch_Chg_Prtnrs_Rec_Type ;
ld_batch_chg_prtnrs_rec  Batch_Chg_Prtnrs_Rec_Type ;
l_complete_rec   Batch_Chg_Prtnrs_Rec_Type;
 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_BTCH_Chg_Prtnrs_;

      -- Standard call to Chk for call compatibility.
      IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                           p_api_version_number,
                                           l_api_name,
                                           G_PKG_NAME)
      THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'Start');
      END IF;

      -- Initialize message list if p_init_msg_list is set to TRUE.
      IF FND_API.to_Boolean( p_init_msg_list )
      THEN
         FND_MSG_PUB.initialize;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              Check_Batch_Chg_Prtnrs_Items(
                 p_batch_chg_prtnrs_rec => p_batch_chg_prtnrs_rec,
                 p_validation_mode      => p_validation_mode,
                 x_return_status        => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         Default_BTCH_Chg_Prtnrs_Items(
	         p_batch_chg_prtnrs_rec => p_batch_chg_prtnrs_rec,
                 x_BTCH_Chg_Prtnrs_rec => ld_batch_chg_prtnrs_rec) ;
      END IF ;


      Complete_BTCH_Chg_Prtnrs_Rec(
        p_batch_chg_prtnrs_rec => ld_batch_chg_prtnrs_rec,
         x_complete_rec        => l_batch_chg_prtnrs_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_Batch_Chg_Prtnrs_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_batch_chg_prtnrs_rec   =>    l_batch_chg_prtnrs_rec);

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
     ROLLBACK TO VALIDATE_BTCH_Chg_Prtnrs_;
     x_return_status := FND_API.G_RET_STS_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_BTCH_Chg_Prtnrs_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_BTCH_Chg_Prtnrs_;
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
End Validate_Batch_Chg_Partners;


PROCEDURE Validate_Batch_Chg_Prtnrs_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_batch_chg_prtnrs_rec       IN    Batch_Chg_Prtnrs_Rec_Type
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

      IF ( NOT( p_batch_chg_prtnrs_rec.processed_flag = 'P' OR
           p_batch_chg_prtnrs_rec.processed_flag = 'S')) THEN
           PVX_UTILITY_PVT.Error_Message('PV_INVALID_FLAG');
           x_return_status := FND_API.G_RET_STS_ERROR;
      END IF;

      -- Debug Message
      IF (PV_DEBUG_HIGH_ON) THEN
          PVX_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_Batch_Chg_Prtnrs_Rec;

END PV_BATCH_CHG_PRTNR_PVT;

/
