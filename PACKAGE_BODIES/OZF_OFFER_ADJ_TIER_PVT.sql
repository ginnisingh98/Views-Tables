--------------------------------------------------------
--  DDL for Package Body OZF_OFFER_ADJ_TIER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFER_ADJ_TIER_PVT" as
/* $Header: ozfvoatb.pls 120.2 2005/08/03 01:58:46 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Offer_Adj_Tier_PVT
-- Purpose
--
-- History
--     Tue Aug 02 2005:10/45 PM RSSHARMA R12 changes.Added new Field for offer_discount_line_id
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Offer_Adj_Tier_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'offvadjb.pls';

-- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
-- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
--
-- Foreward Procedure Declarations
--

PROCEDURE Default_Offadj_Tier_Items (
   p_offadj_tier_rec IN  offadj_tier_rec_type ,
   x_offadj_tier_rec OUT NOCOPY offadj_tier_rec_type
) ;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Offer_Adj_Tier
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
--       p_offadj_tier_rec            IN   offadj_tier_rec_type  Required
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

PROCEDURE Create_Offer_Adj_Tier(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offadj_tier_rec            IN   offadj_tier_rec_type  := g_miss_offadj_tier_rec,
    x_offer_adjst_tier_id        OUT NOCOPY  NUMBER
     )

 IS
   L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Offer_Adj_Tier';
   L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_offer_adjst_tier_id       NUMBER;
   l_dummy                     NUMBER;
   CURSOR c_id IS
      SELECT ozf_offer_adjustment_tiers_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM ozf_OFFER_ADJUSTMENT_TIERS
      WHERE offer_adjst_tier_id = l_id;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_offer_adj_tier_pvt;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.USER_ID IS NULL
      THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;



      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          OZF_UTILITY_PVT.debug_message('Private API: Validate_Offer_Adj_Tier');

          -- Invoke validation procedures
          Validate_offer_adj_tier(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_offadj_tier_rec  =>  p_offadj_tier_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

   -- Local variable initialization

   IF p_offadj_tier_rec.offer_adjst_tier_id IS NULL OR p_offadj_tier_rec.offer_adjst_tier_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_offer_adjst_tier_id;
         CLOSE c_id;

         OPEN c_id_exists(l_offer_adjst_tier_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
         l_offer_adjst_tier_id := p_offadj_tier_rec.offer_adjst_tier_id;
   END IF;

      -- Debug Message
      OZF_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');

      -- Invoke table handler(Ozf_Offer_Adj_Tier_Pkg.Insert_Row)
      Ozf_Offer_Adj_Tier_Pkg.Insert_Row(
          px_offer_adjst_tier_id  => l_offer_adjst_tier_id,
          p_offer_adjustment_id  => p_offadj_tier_rec.offer_adjustment_id,
          p_volume_offer_tiers_id  => p_offadj_tier_rec.volume_offer_tiers_id,
          p_qp_list_header_id  => p_offadj_tier_rec.qp_list_header_id,
          p_discount_type_code  => p_offadj_tier_rec.discount_type_code,
          p_original_discount  => p_offadj_tier_rec.original_discount,
          p_modified_discount  => p_offadj_tier_rec.modified_discount,
          p_offer_discount_line_id => p_offadj_tier_rec.offer_discount_line_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          px_object_version_number  => l_object_version_number
);

          x_offer_adjst_tier_id := l_offer_adjst_tier_id;
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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Offer_Adj_Tier_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Offer_Adj_Tier_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Offer_Adj_Tier_PVT;
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
End Create_Offer_Adj_Tier;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Offer_Adj_Tier
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
--       p_offadj_tier_rec            IN   offadj_tier_rec_type  Required
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

PROCEDURE Update_Offer_Adj_Tier(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offadj_tier_rec               IN    offadj_tier_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS


CURSOR c_get_offer_adj_tier(offer_adjst_tier_id NUMBER) IS
    SELECT *
    FROM  ozf_OFFER_ADJUSTMENT_TIERS
    WHERE  offer_adjst_tier_id = p_offadj_tier_rec.offer_adjst_tier_id;
    -- Hint: Developer need to provide Where clause


L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Offer_Adj_Tier';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_offer_adjst_tier_id    NUMBER;
l_ref_offadj_tier_rec  c_get_Offer_Adj_Tier%ROWTYPE ;
l_tar_offadj_tier_rec  offadj_tier_rec_type := P_offadj_tier_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_offer_adj_tier_pvt;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');

      OPEN c_get_Offer_Adj_Tier( l_tar_offadj_tier_rec.offer_adjst_tier_id);

      FETCH c_get_Offer_Adj_Tier INTO l_ref_offadj_tier_rec  ;

       If ( c_get_Offer_Adj_Tier%NOTFOUND) THEN
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Offer_Adj_Tier') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       OZF_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       CLOSE     c_get_Offer_Adj_Tier;


      If (l_tar_offadj_tier_rec.object_version_number is NULL or
          l_tar_offadj_tier_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_offadj_tier_rec.object_version_number <> l_ref_offadj_tier_rec.object_version_number) Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Offer_Adj_Tier') ;
          raise FND_API.G_EXC_ERROR;
      End if;


      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          OZF_UTILITY_PVT.debug_message('Private API: Validate_Offer_Adj_Tier');

          -- Invoke validation procedures
          Validate_offer_adj_tier(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_offadj_tier_rec  =>  p_offadj_tier_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW || ' Private API: Calling update table handler');

      	l_object_version_number := p_offadj_tier_rec.object_version_number;

      -- Invoke table handler(Ozf_Offer_Adj_Tier_Pkg.Update_Row)
      Ozf_Offer_Adj_Tier_Pkg.Update_Row(
          p_offer_adjst_tier_id  => p_offadj_tier_rec.offer_adjst_tier_id,
          p_offer_adjustment_id  => p_offadj_tier_rec.offer_adjustment_id,
          p_volume_offer_tiers_id  => p_offadj_tier_rec.volume_offer_tiers_id,
          p_qp_list_header_id  => p_offadj_tier_rec.qp_list_header_id,
          p_discount_type_code  => p_offadj_tier_rec.discount_type_code,
          p_original_discount  => p_offadj_tier_rec.original_discount,
          p_modified_discount  => p_offadj_tier_rec.modified_discount,
          p_offer_discount_line_id => p_offadj_tier_rec.offer_discount_line_id,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          px_object_version_number  => l_object_version_number
);
   x_object_version_number := l_object_version_number;
      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO UPDATE_Offer_Adj_Tier_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Offer_Adj_Tier_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Offer_Adj_Tier_PVT;
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
End Update_Offer_Adj_Tier;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Offer_Adj_Tier
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
--       p_offer_adjst_tier_id                IN   NUMBER
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

PROCEDURE Delete_Offer_Adj_Tier(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_offer_adjst_tier_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Offer_Adj_Tier';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_offer_adj_tier_pvt;

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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      OZF_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');

      -- Invoke table handler(Ozf_Offer_Adj_Tier_Pkg.Delete_Row)
      Ozf_Offer_Adj_Tier_Pkg.Delete_Row(
          p_offer_adjst_tier_id  => p_offer_adjst_tier_id,
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
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Offer_Adj_Tier_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Offer_Adj_Tier_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Offer_Adj_Tier_PVT;
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
End Delete_Offer_Adj_Tier;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Offer_Adj_Tier
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
--       p_offadj_tier_rec            IN   offadj_tier_rec_type  Required
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

PROCEDURE Lock_Offer_Adj_Tier(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_offer_adjst_tier_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Offer_Adj_Tier';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_offer_adjst_tier_id                  NUMBER;

BEGIN

      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


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
OZF_Offer_Adj_Tier_PKG.Lock_Row(l_offer_adjst_tier_id,p_object_version);


 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  OZF_Utility_PVT.debug_message(l_full_name ||': end');
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Offer_Adj_Tier_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Offer_Adj_Tier_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Offer_Adj_Tier_PVT;
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
End Lock_Offer_Adj_Tier;




PROCEDURE check_Offadj_Tier_Uk_Items(
    p_offadj_tier_rec               IN   offadj_tier_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_offadj_tier_rec.offer_adjst_tier_id IS NOT NULL
      THEN
         l_valid_flag := OZF_Utility_PVT.check_uniqueness(
         'ozf_offer_adjustment_tiers',
         'offer_adjst_tier_id = ''' || p_offadj_tier_rec.offer_adjst_tier_id ||''''
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_OFFER_ADJ_TIER_ID_DUP');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

END check_Offadj_Tier_Uk_Items;



PROCEDURE check_Offadj_Tier_Req_Items(
    p_offadj_tier_rec               IN  offadj_tier_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN

      IF p_offadj_tier_rec.offer_adjustment_id = FND_API.G_MISS_NUM OR p_offadj_tier_rec.offer_adjustment_id IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFFER_ADJUSTMENT_ID' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;

      IF p_offadj_tier_rec.qp_list_header_id = FND_API.G_MISS_NUM OR p_offadj_tier_rec.qp_list_header_id IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'QP_LIST_HEADER_ID' );
               x_return_status := FND_API.g_ret_sts_error;
               return;
      END IF;

      IF p_offadj_tier_rec.modified_discount = FND_API.G_MISS_NUM OR p_offadj_tier_rec.modified_discount IS NULL THEN
	       OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'MODIFIED_DISCOUNT' );
	       x_return_status := FND_API.g_ret_sts_error;
           return;
      END IF;

ozf_utility_pvt.debug_message('OfferDiscountLineId is : '||p_offadj_tier_rec.offer_discount_line_id);
    IF p_offadj_tier_rec.offer_discount_line_id IS NULL OR p_offadj_tier_rec.offer_discount_line_id = FND_API.G_MISS_NUM THEN
            OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','offer_discount_line_id');
            x_return_status := FND_API.g_ret_sts_error;
            return;
    END IF;

   ELSE


      IF p_offadj_tier_rec.offer_adjst_tier_id = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFFER_ADJST_TIER_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_offadj_tier_rec.offer_adjustment_id = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFFER_ADJUSTMENT_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_offadj_tier_rec.qp_list_header_id = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'QP_LIST_HEADER_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_offadj_tier_rec.modified_discount = FND_API.G_MISS_NUM THEN
	       OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'MODIFIED_DISCOUNT' );
	       x_return_status := FND_API.g_ret_sts_error;
      END IF;
      IF p_offadj_tier_rec.offer_discount_line_id = FND_API.G_MISS_NUM THEN
              OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD','MISS_FIELD','OFFER_DISCOUNT_LINE_ID');
              x_return_status := FND_API.g_ret_sts_error;
              return;
      END IF;

   END IF;

END check_Offadj_Tier_Req_Items;



PROCEDURE check_Offadj_Tier_Fk_Items(
    p_offadj_tier_rec IN offadj_tier_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

IF p_offadj_tier_rec.offer_discount_line_id IS NOT NULL AND p_offadj_tier_rec.offer_discount_line_id <> FND_API.G_MISS_NUM THEN
IF OZF_UTILITY_PVT.CHECK_FK_EXISTS('ozf_offer_discount_lines', 'offer_discount_line_id' , to_char(p_offadj_tier_rec.offer_discount_line_id)) = FND_API.G_FALSE THEN
        OZF_Utility_PVT.Error_Message('OZF_OFF_ADJ_TIER_INV_DISC');
        x_return_status := FND_API.g_ret_sts_error;
        return;
END IF;
END IF;
   -- Enter custom code here

END check_Offadj_Tier_Fk_Items;



PROCEDURE check_Offadj_Tier_Lookup_Items(
    p_offadj_tier_rec IN offadj_tier_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Offadj_Tier_Lookup_Items;

PROCEDURE check_offadj_attr
(
p_offadj_tier_rec IN offadj_tier_rec_type
, p_validation_mode IN VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
END check_offadj_attr;

PROCEDURE check_offadj_inter_attr
(
p_offadj_tier_rec IN offadj_tier_rec_type
, p_validation_mode IN VARCHAR2
, x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
x_return_status := FND_API.G_RET_STS_SUCCESS;
IF
(p_offadj_tier_rec.modified_discount > 0 AND p_offadj_tier_rec.original_discount < 0)
OR
(p_offadj_tier_rec.modified_discount < 0 AND p_offadj_tier_rec.original_discount > 0)
THEN
        OZF_Utility_PVT.Error_Message('OZF_OFFADJ_DISC_DIFF');
        x_return_status := FND_API.g_ret_sts_error;
        return;
END IF;
END check_offadj_inter_attr;


PROCEDURE Check_Offadj_Tier_Items (
    P_offadj_tier_rec     IN    offadj_tier_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

    l_return_status := FND_API.g_ret_sts_success;
   -- Check Items Uniqueness API calls

   check_Offadj_tier_Uk_Items(
      p_offadj_tier_rec => p_offadj_tier_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

   -- Check Items Required/NOT NULL API calls

   check_offadj_tier_req_items(
      p_offadj_tier_rec => p_offadj_tier_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;
   -- Check Items Foreign Keys API calls

   check_offadj_tier_FK_items(
      p_offadj_tier_rec => p_offadj_tier_rec,
      x_return_status => x_return_status);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;   -- Check Items Lookups

   check_offadj_tier_Lookup_items(
      p_offadj_tier_rec => p_offadj_tier_rec,
      x_return_status => x_return_status);
IF x_return_status = FND_API.G_RET_STS_ERROR THEN
    RAISE FND_API.G_EXC_ERROR;
ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;


    check_offadj_attr
    (
    p_offadj_tier_rec => p_offadj_tier_rec
    , p_validation_mode => p_validation_mode
    , x_return_status => x_return_status
    );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    check_offadj_inter_attr
    (
    p_offadj_tier_rec => p_offadj_tier_rec
    , p_validation_mode => p_validation_mode
    , x_return_status   => x_return_status
    );
    IF x_return_status = FND_API.G_RET_STS_ERROR THEN
        RAISE FND_API.G_EXC_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

END Check_offadj_tier_Items;





PROCEDURE Complete_Offadj_Tier_Rec (
   p_offadj_tier_rec IN offadj_tier_rec_type,
   x_complete_rec OUT NOCOPY offadj_tier_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ozf_offer_adjustment_tiers
      WHERE offer_adjst_tier_id = p_offadj_tier_rec.offer_adjst_tier_id;
   l_offadj_tier_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_offadj_tier_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_offadj_tier_rec;
   CLOSE c_complete;

   -- offer_adjst_tier_id
   IF p_offadj_tier_rec.offer_adjst_tier_id IS NULL THEN
      x_complete_rec.offer_adjst_tier_id := l_offadj_tier_rec.offer_adjst_tier_id;
   END IF;

   -- offer_adjustment_id
   IF p_offadj_tier_rec.offer_adjustment_id IS NULL THEN
      x_complete_rec.offer_adjustment_id := l_offadj_tier_rec.offer_adjustment_id;
   END IF;

   -- volume_offer_tiers_id
   IF p_offadj_tier_rec.volume_offer_tiers_id IS NULL THEN
      x_complete_rec.volume_offer_tiers_id := l_offadj_tier_rec.volume_offer_tiers_id;
   END IF;

   -- qp_list_header_id
   IF p_offadj_tier_rec.qp_list_header_id IS NULL THEN
      x_complete_rec.qp_list_header_id := l_offadj_tier_rec.qp_list_header_id;
   END IF;

   -- discount_type_code
   IF p_offadj_tier_rec.discount_type_code IS NULL THEN
      x_complete_rec.discount_type_code := l_offadj_tier_rec.discount_type_code;
   END IF;

   -- original_discount
   IF p_offadj_tier_rec.original_discount IS NULL THEN
      x_complete_rec.original_discount := l_offadj_tier_rec.original_discount;
   END IF;

   -- modified_discount
   IF p_offadj_tier_rec.modified_discount IS NULL THEN
      x_complete_rec.modified_discount := l_offadj_tier_rec.modified_discount;
   END IF;

   -- last_update_date
   IF p_offadj_tier_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_offadj_tier_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_offadj_tier_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_offadj_tier_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_offadj_tier_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_offadj_tier_rec.creation_date;
   END IF;

   -- created_by
   IF p_offadj_tier_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_offadj_tier_rec.created_by;
   END IF;

   -- last_update_login
   IF p_offadj_tier_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_offadj_tier_rec.last_update_login;
   END IF;

   -- object_version_number
   IF p_offadj_tier_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_offadj_tier_rec.object_version_number;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Offadj_Tier_Rec;




PROCEDURE Default_Offadj_Tier_Items ( p_offadj_tier_rec IN offadj_tier_rec_type ,
                                x_offadj_tier_rec OUT NOCOPY offadj_tier_rec_type )
IS
   l_offadj_tier_rec offadj_tier_rec_type := p_offadj_tier_rec;
BEGIN
   -- Developers should put their code to default the record type
   -- e.g. IF p_campaign_rec.status_code IS NULL
   --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
   --         l_campaign_rec.status_code := 'NEW' ;
   --      END IF ;
   --
   NULL ;
END;




PROCEDURE Validate_Offer_Adj_Tier(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_offadj_tier_rec               IN   offadj_tier_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Offer_Adj_Tier';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_offadj_tier_rec  offadj_tier_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_offer_adj_tier_;

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
              Check_offadj_tier_Items(
                 p_offadj_tier_rec        => p_offadj_tier_rec,
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
         Default_Offadj_Tier_Items (p_offadj_tier_rec => p_offadj_tier_rec ,
                                x_offadj_tier_rec => l_offadj_tier_rec) ;
      END IF ;


      Complete_offadj_tier_Rec(
         p_offadj_tier_rec        => l_offadj_tier_rec,
         x_complete_rec        => l_offadj_tier_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_offadj_tier_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_offadj_tier_rec           =>    l_offadj_tier_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');


      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO VALIDATE_Offer_Adj_Tier_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Offer_Adj_Tier_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Offer_Adj_Tier_;
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
End Validate_Offer_Adj_Tier;


PROCEDURE Validate_Offadj_Tier_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_offadj_tier_rec               IN    offadj_tier_rec_type
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
      OZF_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_offadj_tier_Rec;

END OZF_Offer_Adj_Tier_PVT;

/
