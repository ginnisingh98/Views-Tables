--------------------------------------------------------
--  DDL for Package Body OZF_VOL_OFFR_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_VOL_OFFR_PVT" as
/* $Header: ozfvvob.pls 120.0 2005/05/31 23:29:02 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Vol_Offr_PVT
-- Purpose
--
-- History
--
-- Mon Jun 14 2004:6/12 PM RSSHARMA Fixed bug # 3564470. Log debug messages depending on the Debug level
--  Added new method to look at the debug level and then add debug messages
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Vol_Offr_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvvob.pls';

OZF_DEBUG_HIGH_ON      CONSTANT BOOLEAN :=  FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON      CONSTANT BOOLEAN :=  FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);


-- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
-- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
--
-- Foreward Procedure Declarations
--

PROCEDURE Default_Vol_Offr_Tier_Items (
   p_vol_offr_tier_rec IN  vol_offr_tier_rec_type ,
   x_vol_offr_tier_rec OUT NOCOPY vol_offr_tier_rec_type
) ;

PROCEDURE debug_message(
                        p_message_text   IN  VARCHAR2
                        )
IS
BEGIN
IF OZF_DEBUG_HIGH_ON THEN
    OZF_UTILITY_PVT.debug_message(p_message_text);
END IF;
END debug_message;


-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Vol_Offr
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
--       p_vol_offr_tier_rec            IN   vol_offr_tier_rec_type  Required
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

PROCEDURE Create_Vol_Offr(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_vol_offr_tier_rec              IN   vol_offr_tier_rec_type  := g_miss_vol_offr_tier_rec,
    x_volume_offer_tiers_id              OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Vol_Offr';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_volume_offer_tiers_id              NUMBER;
   l_dummy                     NUMBER;
   CURSOR c_id IS
      SELECT OZF_volume_offer_tiers_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM OZF_VOLUME_OFFER_TIERS
      WHERE volume_offer_tiers_id = l_id;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_vol_offr_pvt;

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
      debug_message('Private API: ' || l_api_name || 'start1');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   IF p_vol_offr_tier_rec.volume_offer_tiers_id IS NULL OR p_vol_offr_tier_rec.volume_offer_tiers_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_volume_offer_tiers_id;
         CLOSE c_id;

         OPEN c_id_exists(l_volume_offer_tiers_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
         l_volume_offer_tiers_id := p_vol_offr_tier_rec.volume_offer_tiers_id;
   END IF;
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
          debug_message('Private API: Validate_Vol_Offr');

          -- Invoke validation procedures
          Validate_vol_offr(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_vol_offr_tier_rec  =>  p_vol_offr_tier_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      debug_message( 'Private API: Calling create table handler');

      -- Invoke table handler(Ozf_Vol_Offr_Pkg.Insert_Row)
      Ozf_Vol_Offr_Pkg.Insert_Row(
          px_volume_offer_tiers_id  => l_volume_offer_tiers_id,
          p_qp_list_header_id  => p_vol_offr_tier_rec.qp_list_header_id,
          p_discount_type_code  => p_vol_offr_tier_rec.discount_type_code,
          p_discount  => p_vol_offr_tier_rec.discount,
          p_break_type_code  => p_vol_offr_tier_rec.break_type_code,
          p_tier_value_from  => p_vol_offr_tier_rec.tier_value_from,
          p_tier_value_to  => p_vol_offr_tier_rec.tier_value_to,
          p_volume_type  => p_vol_offr_tier_rec.volume_type,
          p_active  => p_vol_offr_tier_rec.active,
          p_uom_code  => p_vol_offr_tier_rec.uom_code,
          px_object_version_number  => l_object_version_number
);

          x_volume_offer_tiers_id := l_volume_offer_tiers_id;
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
      debug_message('Private API: ' || l_api_name || 'end');


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
     ROLLBACK TO CREATE_Vol_Offr_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Vol_Offr_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Vol_Offr_PVT;
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
End Create_Vol_Offr;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Vol_Offr
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
--       p_vol_offr_tier_rec            IN   vol_offr_tier_rec_type  Required
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

PROCEDURE Update_Vol_Offr(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_vol_offr_tier_rec               IN    vol_offr_tier_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS


CURSOR c_get_vol_offr(volume_offer_tiers_id NUMBER) IS
    SELECT *
    FROM  OZF_VOLUME_OFFER_TIERS
    WHERE  volume_offer_tiers_id = p_vol_offr_tier_rec.volume_offer_tiers_id;
    -- Hint: Developer need to provide Where clause


L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Vol_Offr';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER := p_vol_offr_tier_rec.object_version_number;
l_volume_offer_tiers_id    NUMBER;
l_ref_vol_offr_tier_rec  c_get_Vol_Offr%ROWTYPE ;
l_tar_vol_offr_tier_rec  vol_offr_tier_rec_type := P_vol_offr_tier_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_vol_offr_pvt;

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
      debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      debug_message('Private API: - Open Cursor to Select');

      OPEN c_get_Vol_Offr( l_tar_vol_offr_tier_rec.volume_offer_tiers_id);

      FETCH c_get_Vol_Offr INTO l_ref_vol_offr_tier_rec  ;

       If ( c_get_Vol_Offr%NOTFOUND) THEN
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Vol_Offr') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       debug_message('Private API: - Close Cursor');
       CLOSE     c_get_Vol_Offr;


      If (l_tar_vol_offr_tier_rec.object_version_number is NULL or
          l_tar_vol_offr_tier_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_vol_offr_tier_rec.object_version_number <> l_ref_vol_offr_tier_rec.object_version_number) Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Vol_Offr') ;
          raise FND_API.G_EXC_ERROR;
      End if;


      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          debug_message('Private API: Validate_Vol_Offr');

          -- Invoke validation procedures
          Validate_vol_offr(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_vol_offr_tier_rec  =>  p_vol_offr_tier_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;
      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
        debug_message('id: '||p_vol_offr_tier_rec.volume_offer_tiers_id);
        debug_message('ver: '||l_object_version_number);
      -- Debug Message
      --debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');
      -- Invoke table handler(Ozf_Vol_Offr_Pkg.Update_Row)
      Ozf_Vol_Offr_Pkg.Update_Row(
          p_volume_offer_tiers_id  => p_vol_offr_tier_rec.volume_offer_tiers_id,
          p_qp_list_header_id  => p_vol_offr_tier_rec.qp_list_header_id,
          p_discount_type_code  => p_vol_offr_tier_rec.discount_type_code,
          p_discount  => p_vol_offr_tier_rec.discount,
          p_break_type_code  => p_vol_offr_tier_rec.break_type_code,
          p_tier_value_from  => p_vol_offr_tier_rec.tier_value_from,
          p_tier_value_to  => p_vol_offr_tier_rec.tier_value_to,
          p_volume_type  => p_vol_offr_tier_rec.volume_type,
          p_active  => p_vol_offr_tier_rec.active,
          p_uom_code  => p_vol_offr_tier_rec.uom_code,
          px_object_version_number  => l_object_version_number
);
    debug_message('after calling tabel handler');
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
      debug_message('Private API: ' || l_api_name || 'end');


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
     ROLLBACK TO UPDATE_Vol_Offr_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Vol_Offr_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Vol_Offr_PVT;
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
End Update_Vol_Offr;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Vol_Offr
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
--       p_volume_offer_tiers_id                IN   NUMBER
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

PROCEDURE Delete_Vol_Offr(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_volume_offer_tiers_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Vol_Offr';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_vol_offr_pvt;

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
        debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
        debug_message( 'Private API: Calling delete table handler');

      -- Invoke table handler(Ozf_Vol_Offr_Pkg.Delete_Row)
      Ozf_Vol_Offr_Pkg.Delete_Row(
          p_volume_offer_tiers_id  => p_volume_offer_tiers_id,
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
      debug_message('Private API: ' || l_api_name || 'end');


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
     ROLLBACK TO DELETE_Vol_Offr_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Vol_Offr_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Vol_Offr_PVT;
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
End Delete_Vol_Offr;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Vol_Offr
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
--       p_vol_offr_tier_rec            IN   vol_offr_tier_rec_type  Required
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

PROCEDURE Lock_Vol_Offr(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_volume_offer_tiers_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Vol_Offr';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_volume_offer_tiers_id                  NUMBER;

BEGIN

      -- Debug Message
      debug_message('Private API: ' || l_api_name || 'start');


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
OZF_Vol_Offr_PKG.Lock_Row(l_volume_offer_tiers_id,p_object_version);


 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  debug_message(l_full_name ||': end');
EXCEPTION

   WHEN OZF_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Vol_Offr_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Vol_Offr_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Vol_Offr_PVT;
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
End Lock_Vol_Offr;




PROCEDURE check_Vol_Offr_Tier_Uk_Items(
    p_vol_offr_tier_rec               IN   vol_offr_tier_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := OZF_Utility_PVT.check_uniqueness(
         'ozf_volume_offer_tiers',
         'volume_offer_tiers_id = ''' || p_vol_offr_tier_rec.volume_offer_tiers_id ||''''
         );
      ELSE
         l_valid_flag := OZF_Utility_PVT.check_uniqueness(
         'ozf_volume_offer_tiers',
         'volume_offer_tiers_id = ''' || p_vol_offr_tier_rec.volume_offer_tiers_id ||
         ''' AND volume_offer_tiers_id <> ' || p_vol_offr_tier_rec.volume_offer_tiers_id
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_VOLUME_OFFER_TIERS_ID_DUP');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

END check_Vol_Offr_Tier_Uk_Items;



PROCEDURE check_Vol_Offr_Tier_Req_Items(
    p_vol_offr_tier_rec               IN  vol_offr_tier_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;
  -- check qp_list_header_id
  IF p_validation_mode = JTF_PLSQL_API.g_update THEN
    IF p_vol_offr_tier_rec.qp_list_header_id = FND_API.g_miss_num
    OR p_vol_offr_tier_rec.qp_list_header_id IS NULL
    THEN
      Fnd_Message.SET_NAME('OZF', 'OZF_VOL_OFF_NO_LST_HDR_ID');
      Fnd_Msg_Pub.ADD;
      x_return_status := FND_API.g_ret_sts_error;
    END IF;
  END IF;
  -- check discount_type_code
  IF p_vol_offr_tier_rec.discount_type_code = FND_API.g_miss_char
  OR p_vol_offr_tier_rec.discount_type_code IS NULL
  THEN
    Fnd_Message.SET_NAME('OZF', 'OZF_VOL_OFF_NO_DISOUNT_TYPE');
    Fnd_Msg_Pub.ADD;
    x_return_status := FND_API.g_ret_sts_error;
  END IF;
  -- check discount
  IF p_vol_offr_tier_rec.discount = FND_API.g_miss_num
  OR p_vol_offr_tier_rec.discount IS NULL
  THEN
    Fnd_Message.SET_NAME('OZF', 'OZF_VOL_OFF_NO_DISOUNT');
    Fnd_Msg_Pub.ADD;
    x_return_status := FND_API.g_ret_sts_error;
  END IF;
  -- check break_type_code
  IF p_vol_offr_tier_rec.break_type_code = FND_API.g_miss_char
  OR p_vol_offr_tier_rec.break_type_code IS NULL
  THEN
    Fnd_Message.SET_NAME('OZF', 'OZF_VOL_OFF_NO_BREAK_TYPE');
    Fnd_Msg_Pub.ADD;
    x_return_status := FND_API.g_ret_sts_error;
  END IF;
  -- check tier_value_from
  IF p_vol_offr_tier_rec.tier_value_from = FND_API.g_miss_num
  OR p_vol_offr_tier_rec.tier_value_from IS NULL
  THEN
    Fnd_Message.SET_NAME('OZF', 'OZF_VOL_OFF_NO_VALUE_FROM');
    Fnd_Msg_Pub.ADD;
    x_return_status := FND_API.g_ret_sts_error;
  END IF;
  -- check tier_value_to
  IF p_vol_offr_tier_rec.tier_value_to = FND_API.g_miss_num
  OR p_vol_offr_tier_rec.tier_value_to IS NULL
  THEN
    Fnd_Message.SET_NAME('OZF', 'OZF_VOL_OFF_NO_VALUE_TO');
    Fnd_Msg_Pub.ADD;
    x_return_status := FND_API.g_ret_sts_error;
  END IF;
  -- check volume_type
  IF p_vol_offr_tier_rec.volume_type = FND_API.g_miss_char
  OR p_vol_offr_tier_rec.volume_type IS NULL
  THEN
    Fnd_Message.SET_NAME('OZF', 'OZF_VOL_OFF_NO_VOLUME_TYPE');
    Fnd_Msg_Pub.ADD;
    x_return_status := FND_API.g_ret_sts_error;
  END IF;
  -- check uom_code
  IF p_vol_offr_tier_rec.volume_type = 'PRICING_ATTRIBUTE10' THEN
    IF p_vol_offr_tier_rec.uom_code IS NULL
    OR p_vol_offr_tier_rec.uom_code = FND_API.g_miss_char
    THEN
      Fnd_Message.SET_NAME('OZF', 'OZF_VOL_OFF_NO_UOM_CODE');
      Fnd_Msg_Pub.ADD;
      x_return_status := FND_API.g_ret_sts_error;
    END IF;
    RETURN;
  END IF;
  -- check object_version_number
  IF p_vol_offr_tier_rec.object_version_number = FND_API.g_miss_num
  OR p_vol_offr_tier_rec.object_version_number IS NULL
  THEN
    Fnd_Message.SET_NAME('OZF', 'OZF_VOL_OFF_NO_OBJECT_VERSION');
    Fnd_Msg_Pub.ADD;
    x_return_status := FND_API.g_ret_sts_error;
  END IF;

END check_Vol_Offr_Tier_Req_Items;



PROCEDURE check_Vol_Offr_Tier_Fk_Items(
    p_vol_offr_tier_rec IN vol_offr_tier_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

      IF p_vol_offr_tier_rec.qp_list_header_id <> FND_API.g_miss_num
       AND p_vol_offr_tier_rec.qp_list_header_id IS NOT NULL  THEN
      IF
       OZF_Utility_PVT.check_fk_exists(
                                       p_table_name  => 'OZF_OFFERS'
                                       , p_pk_name   => 'qp_list_header_id'
                                       , p_pk_value  => p_vol_offr_tier_rec.qp_list_header_id
                                       , p_pk_data_type => OZF_Utility_PVT.g_number
                                       ,  p_additional_where_clause => NULL
                                       ) = FND_API.g_false
         THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_VO_BAD_LIST_HEADER_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN ;
       END IF;
       END IF;
   -- Enter custom code here
END check_Vol_Offr_Tier_Fk_Items;



PROCEDURE check_Vol_Offr_Tier_Lkp_Items(
    p_vol_offr_tier_rec IN vol_offr_tier_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

 IF p_vol_offr_tier_rec.discount_type_code <> FND_API.G_MISS_CHAR AND p_vol_offr_tier_rec.discount_type_code IS NOT NULL
  THEN
       debug_message(' LookUp type   lookup code  = '''|| p_vol_offr_tier_rec.discount_type_code);
   IF OZF_Utility_PVT.Check_Lookup_Exists
      ( p_lookup_table_name   => 'OZF_LOOKUPS'
             ,p_lookup_type         => 'OZF_QP_ARITHMETIC_OPERATOR'
        ,p_lookup_code         => p_vol_offr_tier_rec.discount_type_code
        ) = FND_API.G_FALSE then
        OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_INVALID_DISCOUNT_TYPE');
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- If any errors happen abort API/Procedure.
      RETURN;
   END IF;
END IF;
 IF p_vol_offr_tier_rec.break_type_code <> FND_API.G_MISS_CHAR AND p_vol_offr_tier_rec.break_type_code IS NOT NULL
  THEN
       debug_message(' LookUp type   lookup code  = '''|| p_vol_offr_tier_rec.break_type_code);
   IF OZF_Utility_PVT.Check_Lookup_Exists
      ( p_lookup_table_name   => 'QP_LOOKUPS'
             ,p_lookup_type         => 'PRICE_BREAK_TYPE_CODE'
        ,p_lookup_code         => p_vol_offr_tier_rec.break_type_code
        ) = FND_API.G_FALSE then
        OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_INVALID_BREAK_TYPE_TYPE');
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- If any errors happen abort API/Procedure.
      RETURN;
   END IF;
END IF;
 IF p_vol_offr_tier_rec.volume_type <> FND_API.G_MISS_CHAR AND p_vol_offr_tier_rec.volume_type IS NOT NULL
  THEN
       debug_message(' LookUp type   lookup code  = '''|| p_vol_offr_tier_rec.volume_type);
   IF OZF_Utility_PVT.Check_Lookup_Exists
      ( p_lookup_table_name   => 'OZF_LOOKUPS'
             ,p_lookup_type         => 'OZF_QP_VOLUME_TYPE'
        ,p_lookup_code         => p_vol_offr_tier_rec.volume_type
        ) = FND_API.G_FALSE then
        OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_INVALID_VOLUME_TYPE');
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- If any errors happen abort API/Procedure.
      RETURN;
   END IF;
  END IF;

--OZF_QP_ARITHMETIC_OPERATOR, OZF_QP_VOLUME_TYPE , QP_LOOKUPS","PRICE_BREAK_TYPE_CODE
   -- Enter custom code here
END check_Vol_Offr_Tier_Lkp_Items;



PROCEDURE Check_Vol_Offr_Tier_Items (
    P_vol_offr_tier_rec     IN    vol_offr_tier_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

    l_return_status := FND_API.g_ret_sts_success;
   -- Check Items Uniqueness API calls

   check_Vol_offr_tier_Uk_Items(
      p_vol_offr_tier_rec => p_vol_offr_tier_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_vol_offr_tier_req_items(
      p_vol_offr_tier_rec => p_vol_offr_tier_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Foreign Keys API calls

   check_vol_offr_tier_FK_items(
      p_vol_offr_tier_rec => p_vol_offr_tier_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Lookups

   check_Vol_Offr_Tier_Lkp_Items(
      p_vol_offr_tier_rec => p_vol_offr_tier_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   x_return_status := l_return_status;

END Check_vol_offr_tier_Items;





PROCEDURE Complete_Vol_Offr_Tier_Rec (
   p_vol_offr_tier_rec IN vol_offr_tier_rec_type,
   x_complete_rec OUT NOCOPY vol_offr_tier_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM OZF_volume_offer_tiers
      WHERE volume_offer_tiers_id = p_vol_offr_tier_rec.volume_offer_tiers_id;
   l_vol_offr_tier_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_vol_offr_tier_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_vol_offr_tier_rec;
   CLOSE c_complete;

   -- volume_offer_tiers_id
   IF p_vol_offr_tier_rec.volume_offer_tiers_id IS NULL THEN
      x_complete_rec.volume_offer_tiers_id := l_vol_offr_tier_rec.volume_offer_tiers_id;
   END IF;

   -- qp_list_header_id
   IF p_vol_offr_tier_rec.qp_list_header_id IS NULL THEN
      x_complete_rec.qp_list_header_id := l_vol_offr_tier_rec.qp_list_header_id;
   END IF;

   -- discount_type_code
   IF p_vol_offr_tier_rec.discount_type_code IS NULL THEN
      x_complete_rec.discount_type_code := l_vol_offr_tier_rec.discount_type_code;
   END IF;

   -- discount
   IF p_vol_offr_tier_rec.discount IS NULL THEN
      x_complete_rec.discount := l_vol_offr_tier_rec.discount;
   END IF;

   -- break_type_code
   IF p_vol_offr_tier_rec.break_type_code IS NULL THEN
      x_complete_rec.break_type_code := l_vol_offr_tier_rec.break_type_code;
   END IF;

   -- tier_value_from
   IF p_vol_offr_tier_rec.tier_value_from IS NULL THEN
      x_complete_rec.tier_value_from := l_vol_offr_tier_rec.tier_value_from;
   END IF;

   -- tier_value_to
   IF p_vol_offr_tier_rec.tier_value_to IS NULL THEN
      x_complete_rec.tier_value_to := l_vol_offr_tier_rec.tier_value_to;
   END IF;

   -- volume_type
   IF p_vol_offr_tier_rec.volume_type IS NULL THEN
      x_complete_rec.volume_type := l_vol_offr_tier_rec.volume_type;
   END IF;

   -- active
   IF p_vol_offr_tier_rec.active IS NULL THEN
      x_complete_rec.active := l_vol_offr_tier_rec.active;
   END IF;

   -- uom_code
   IF p_vol_offr_tier_rec.uom_code IS NULL THEN
      x_complete_rec.uom_code := l_vol_offr_tier_rec.uom_code;
   END IF;

   -- object_version_number
   IF p_vol_offr_tier_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_vol_offr_tier_rec.object_version_number;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Vol_Offr_Tier_Rec;




PROCEDURE Default_Vol_Offr_Tier_Items ( p_vol_offr_tier_rec IN vol_offr_tier_rec_type ,
                                x_vol_offr_tier_rec OUT NOCOPY vol_offr_tier_rec_type )
IS
   l_vol_offr_tier_rec vol_offr_tier_rec_type := p_vol_offr_tier_rec;
BEGIN
   -- Developers should put their code to default the record type
   -- e.g. IF p_campaign_rec.status_code IS NULL
   --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
   --         l_campaign_rec.status_code := 'NEW' ;
   --      END IF ;
   --
   NULL ;
END;




PROCEDURE Validate_Vol_Offr(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_vol_offr_tier_rec               IN   vol_offr_tier_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Vol_Offr';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_vol_offr_tier_rec  vol_offr_tier_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_vol_offr_;

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
              Check_vol_offr_tier_Items(
                 p_vol_offr_tier_rec        => p_vol_offr_tier_rec,
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
         Default_Vol_Offr_Tier_Items (p_vol_offr_tier_rec => p_vol_offr_tier_rec ,
                                x_vol_offr_tier_rec => l_vol_offr_tier_rec) ;
      END IF ;


      Complete_vol_offr_tier_Rec(
         p_vol_offr_tier_rec        => l_vol_offr_tier_rec,
         x_complete_rec        => l_vol_offr_tier_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_vol_offr_tier_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_vol_offr_tier_rec           =>    l_vol_offr_tier_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      debug_message('Private API: ' || l_api_name || ' start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
      debug_message('Private API: ' || l_api_name || ' end');


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
     ROLLBACK TO VALIDATE_Vol_Offr_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Vol_Offr_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Vol_Offr_;
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
End Validate_Vol_Offr;


PROCEDURE Validate_Vol_Offr_Tier_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_vol_offr_tier_rec               IN    vol_offr_tier_rec_type
    )
IS
  CURSOR c_range IS
  SELECT TIER_VALUE_FROM, TIER_VALUE_TO
    FROM OZF_volume_offer_tiers
   WHERE QP_LIST_HEADER_ID = p_vol_offr_tier_rec.qp_list_header_id;

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
      FOR l_range IN c_range LOOP
        IF c_range%NOTFOUND THEN
          RETURN;
        END IF;

        IF p_vol_offr_tier_rec.TIER_VALUE_FROM BETWEEN l_range.TIER_VALUE_FROM AND l_range.TIER_VALUE_TO
        OR p_vol_offr_tier_rec.TIER_VALUE_TO BETWEEN l_range.TIER_VALUE_FROM AND l_range.TIER_VALUE_TO
        THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          RETURN;
        END IF;
      END LOOP;
      -- Debug Message
      debug_message('Private API: Validate_dm_model_rec');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_vol_offr_tier_Rec;

END OZF_Vol_Offr_PVT;

/
