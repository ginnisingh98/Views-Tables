--------------------------------------------------------
--  DDL for Package Body OZF_NA_DDN_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_NA_DDN_RULE_PVT" as
/* $Header: ozfvdnrb.pls 120.2 2006/02/25 19:23:31 julou noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Na_Ddn_Rule_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- Wed Jan 14 2004:1/45 PM RSSHARMA Changed AMS_API_MISSING_FIELD messages to OZF_API_MISSING_FIELD
-- Mon Mar 29 2004:5/4 PM RSSHARMA Fixed bug # 3429608. Corrected debug to call local debug_message instead of ozf_utility_pvt.
-- Wed Oct 26 2005:2/8 PM RSSHARMA Fixed package hanging. Debug message was calling itself instead of ozf_utility_pvt.debug_message
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Na_Ddn_Rule_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvam.b.pls';
OZF_DEBUG_HIGH_ON      CONSTANT BOOLEAN :=  FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_high);
OZF_DEBUG_LOW_ON      CONSTANT BOOLEAN :=  FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_debug_low);

-- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
-- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
--
-- Foreward Procedure Declarations
--

PROCEDURE Default_Na_Ddn_Rule_Items (
   p_na_ddn_rule_rec IN  na_ddn_rule_rec_type ,
   x_na_ddn_rule_rec OUT NOCOPY na_ddn_rule_rec_type
) ;

PROCEDURE debug_message(
                        p_message_text   IN  VARCHAR2
                        )
IS
BEGIN
IF OZF_DEBUG_HIGH_ON THEN
    ozf_utility_pvt.debug_message(p_message_text);
END IF;
END debug_message;


-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Na_Ddn_Rule
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
--       p_na_ddn_rule_rec            IN   na_ddn_rule_rec_type  Required
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

PROCEDURE Create_Na_Ddn_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_na_ddn_rule_rec              IN   na_ddn_rule_rec_type  := g_miss_na_ddn_rule_rec,
    x_na_deduction_rule_id              OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Na_Ddn_Rule';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_na_deduction_rule_id              NUMBER;
   l_dummy                     NUMBER;
   CURSOR c_id IS
      SELECT ozf_na_deduction_rules_b_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM OZF_NA_DEDUCTION_RULES_B
      WHERE na_deduction_rule_id = l_id;

l_na_ddn_rule_rec na_ddn_rule_rec_type;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_na_ddn_rule_pvt;

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

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.USER_ID IS NULL
      THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;


   IF p_na_ddn_rule_rec.na_deduction_rule_id IS NULL OR p_na_ddn_rule_rec.na_deduction_rule_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_na_deduction_rule_id;
         CLOSE c_id;

         OPEN c_id_exists(l_na_deduction_rule_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
         l_na_deduction_rule_id := p_na_ddn_rule_rec.na_deduction_rule_id;
   END IF;


l_na_ddn_rule_rec := p_na_ddn_rule_rec;
l_na_ddn_rule_rec.na_deduction_rule_id := l_na_deduction_rule_id;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          debug_message('Private API: Validate_Na_Ddn_Rule');

          -- Invoke validation procedures
          Validate_na_ddn_rule(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_na_ddn_rule_rec  =>  l_na_ddn_rule_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

   -- Local variable initialization

      -- Debug Message
      debug_message( 'Private API: Calling create table handler');

      -- Invoke table handler(Ozf_Na_Ddn_Rule_Pkg.Insert_Row)
      Ozf_Na_Ddn_Rule_Pkg.Insert_Row(
          px_na_deduction_rule_id  => l_na_deduction_rule_id,
          p_transaction_source_code  => l_na_ddn_rule_rec.transaction_source_code,
          p_transaction_type_code  => l_na_ddn_rule_rec.transaction_type_code,
          p_deduction_identifier_id  => l_na_ddn_rule_rec.deduction_identifier_id,
          p_deduction_identifier_org_id  => l_na_ddn_rule_rec.deduction_identifier_org_id,
          px_object_version_number  => l_object_version_number,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_name  => l_na_ddn_rule_rec.name,
          p_description  => l_na_ddn_rule_rec.description
);

          x_na_deduction_rule_id := l_na_deduction_rule_id;
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
     ROLLBACK TO CREATE_Na_Ddn_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Na_Ddn_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Na_Ddn_Rule_PVT;
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
End Create_Na_Ddn_Rule;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Na_Ddn_Rule
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
--       p_na_ddn_rule_rec            IN   na_ddn_rule_rec_type  Required
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

PROCEDURE Update_Na_Ddn_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_na_ddn_rule_rec               IN    na_ddn_rule_rec_type
    )

 IS


CURSOR c_get_na_ddn_rule(na_deduction_rule_id NUMBER) IS
    SELECT *
    FROM  OZF_NA_DEDUCTION_RULES_B
    WHERE  na_deduction_rule_id = p_na_ddn_rule_rec.na_deduction_rule_id;
    -- Hint: Developer need to provide Where clause


L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Na_Ddn_Rule';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_na_deduction_rule_id    NUMBER;
l_ref_na_ddn_rule_rec  c_get_Na_Ddn_Rule%ROWTYPE ;
l_tar_na_ddn_rule_rec  na_ddn_rule_rec_type := P_na_ddn_rule_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_na_ddn_rule_pvt;

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

      OPEN c_get_Na_Ddn_Rule( l_tar_na_ddn_rule_rec.na_deduction_rule_id);

      FETCH c_get_Na_Ddn_Rule INTO l_ref_na_ddn_rule_rec  ;

       If ( c_get_Na_Ddn_Rule%NOTFOUND) THEN
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Na_Ddn_Rule') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       debug_message('Private API: - Close Cursor');
       CLOSE     c_get_Na_Ddn_Rule;


      If (l_tar_na_ddn_rule_rec.object_version_number is NULL or
          l_tar_na_ddn_rule_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_na_ddn_rule_rec.object_version_number <> l_ref_na_ddn_rule_rec.object_version_number) Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Na_Ddn_Rule') ;
          raise FND_API.G_EXC_ERROR;
      End if;


      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          debug_message('Private API: Validate_Na_Ddn_Rule');

          -- Invoke validation procedures
          Validate_na_ddn_rule(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_na_ddn_rule_rec  =>  p_na_ddn_rule_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
--      debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');

      -- Invoke table handler(Ozf_Na_Ddn_Rule_Pkg.Update_Row)
      Ozf_Na_Ddn_Rule_Pkg.Update_Row(
          p_na_deduction_rule_id  => p_na_ddn_rule_rec.na_deduction_rule_id,
          p_transaction_source_code  => p_na_ddn_rule_rec.transaction_source_code,
          p_transaction_type_code  => p_na_ddn_rule_rec.transaction_type_code,
          p_deduction_identifier_id  => p_na_ddn_rule_rec.deduction_identifier_id,
          p_deduction_identifier_org_id  => p_na_ddn_rule_rec.deduction_identifier_org_id,
          p_object_version_number  => p_na_ddn_rule_rec.object_version_number,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_name  => p_na_ddn_rule_rec.name,
          p_description  => p_na_ddn_rule_rec.description
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
     ROLLBACK TO UPDATE_Na_Ddn_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Na_Ddn_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Na_Ddn_Rule_PVT;
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
End Update_Na_Ddn_Rule;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Na_Ddn_Rule
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
--       p_na_deduction_rule_id                IN   NUMBER
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

PROCEDURE Delete_Na_Ddn_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_na_deduction_rule_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Na_Ddn_Rule';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_na_ddn_rule_pvt;

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

      -- Invoke table handler(Ozf_Na_Ddn_Rule_Pkg.Delete_Row)
      Ozf_Na_Ddn_Rule_Pkg.Delete_Row(
          p_na_deduction_rule_id  => p_na_deduction_rule_id,
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
     ROLLBACK TO DELETE_Na_Ddn_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Na_Ddn_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Na_Ddn_Rule_PVT;
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
End Delete_Na_Ddn_Rule;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Na_Ddn_Rule
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
--       p_na_ddn_rule_rec            IN   na_ddn_rule_rec_type  Required
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

PROCEDURE Lock_Na_Ddn_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_na_deduction_rule_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Na_Ddn_Rule';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_na_deduction_rule_id                  NUMBER;

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
Ozf_Na_Ddn_Rule_Pkg.Lock_Row(l_na_deduction_rule_id,p_object_version);


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
     ROLLBACK TO LOCK_Na_Ddn_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Na_Ddn_Rule_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Na_Ddn_Rule_PVT;
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
End Lock_Na_Ddn_Rule;




PROCEDURE check_Na_Ddn_Rule_Uk_Items(
    p_na_ddn_rule_rec               IN   na_ddn_rule_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_na_ddn_rule_rec.na_deduction_rule_id IS NOT NULL
      THEN
         l_valid_flag := OZF_Utility_PVT.check_uniqueness(
         'ozf_na_deduction_rules_b',
         'na_deduction_rule_id = ''' || p_na_ddn_rule_rec.na_deduction_rule_id ||''''
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_na_deduction_rule_id_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

END check_Na_Ddn_Rule_Uk_Items;



PROCEDURE check_Na_Ddn_Rule_Req_Items(
    p_na_ddn_rule_rec               IN  na_ddn_rule_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_na_ddn_rule_rec.na_deduction_rule_id = FND_API.G_MISS_NUM OR p_na_ddn_rule_rec.na_deduction_rule_id IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'NA_DEDUCTION_RULE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_na_ddn_rule_rec.transaction_source_code = FND_API.g_miss_char OR p_na_ddn_rule_rec.transaction_source_code IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'TRANSACTION_SOURCE_CODE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_na_ddn_rule_rec.transaction_type_code = FND_API.g_miss_char OR p_na_ddn_rule_rec.transaction_type_code IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'TRANSACTION_TYPE_CODE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_na_ddn_rule_rec.deduction_identifier_id = FND_API.G_MISS_CHAR OR p_na_ddn_rule_rec.deduction_identifier_id IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'DEDUCTION_IDENTIFIER_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_na_ddn_rule_rec.deduction_identifier_org_id = FND_API.G_MISS_NUM OR p_na_ddn_rule_rec.deduction_identifier_org_id IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'DEDUCTION_IDENTIFIER_ORG_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

/*      IF p_na_ddn_rule_rec.object_version_number = FND_API.G_MISS_NUM OR p_na_ddn_rule_rec.object_version_number IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUMBER' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_na_ddn_rule_rec.last_update_login = FND_API.G_MISS_NUM OR p_na_ddn_rule_rec.last_update_login IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'LAST_UPDATE_LOGIN' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
*/

   ELSE
      IF p_na_ddn_rule_rec.na_deduction_rule_id = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'NA_DEDUCTION_RULE_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_na_ddn_rule_rec.transaction_source_code = FND_API.g_miss_char THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'TRANSACTION_SOURCE_CODE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_na_ddn_rule_rec.transaction_type_code = FND_API.g_miss_char THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'TRANSACTION_TYPE_CODE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_na_ddn_rule_rec.deduction_identifier_id = FND_API.G_MISS_CHAR THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'DEDUCTION_IDENTIFIER_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_na_ddn_rule_rec.deduction_identifier_org_id = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'DEDUCTION_IDENTIFIER_ORG_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

      IF p_na_ddn_rule_rec.object_version_number = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUMBER' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

/*
      IF p_na_ddn_rule_rec.last_update_login = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'LAST_UPDATE_LOGIN' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;
*/
END IF;
END check_Na_Ddn_Rule_Req_Items;



PROCEDURE check_Na_Ddn_Rule_Fk_Items(
    p_na_ddn_rule_rec IN na_ddn_rule_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Na_Ddn_Rule_Fk_Items;



PROCEDURE check_Na_Ddn_Rule_Lookup_Items(
    p_na_ddn_rule_rec IN na_ddn_rule_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Na_Ddn_Rule_Lookup_Items;



PROCEDURE Check_Na_Ddn_Rule_Items (
    P_na_ddn_rule_rec     IN    na_ddn_rule_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

    l_return_status := FND_API.g_ret_sts_success;
   -- Check Items Uniqueness API calls

   check_Na_ddn_rule_Uk_Items(
      p_na_ddn_rule_rec => p_na_ddn_rule_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_na_ddn_rule_req_items(
      p_na_ddn_rule_rec => p_na_ddn_rule_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Foreign Keys API calls

   check_na_ddn_rule_FK_items(
      p_na_ddn_rule_rec => p_na_ddn_rule_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Lookups

   check_na_ddn_rule_Lookup_items(
      p_na_ddn_rule_rec => p_na_ddn_rule_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   x_return_status := l_return_status;

END Check_na_ddn_rule_Items;





PROCEDURE Complete_Na_Ddn_Rule_Rec (
   p_na_ddn_rule_rec IN na_ddn_rule_rec_type,
   x_complete_rec OUT NOCOPY na_ddn_rule_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ozf_na_deduction_rules_b
      WHERE na_deduction_rule_id = p_na_ddn_rule_rec.na_deduction_rule_id;
   l_na_ddn_rule_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_na_ddn_rule_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_na_ddn_rule_rec;
   CLOSE c_complete;

   -- na_deduction_rule_id
   IF p_na_ddn_rule_rec.na_deduction_rule_id IS NULL THEN
      x_complete_rec.na_deduction_rule_id := l_na_ddn_rule_rec.na_deduction_rule_id;
   END IF;

   -- transaction_source_code
   IF p_na_ddn_rule_rec.transaction_source_code IS NULL THEN
      x_complete_rec.transaction_source_code := l_na_ddn_rule_rec.transaction_source_code;
   END IF;

   -- transaction_type_code
   IF p_na_ddn_rule_rec.transaction_type_code IS NULL THEN
      x_complete_rec.transaction_type_code := l_na_ddn_rule_rec.transaction_type_code;
   END IF;

   -- deduction_identifier_id
   IF p_na_ddn_rule_rec.deduction_identifier_id IS NULL THEN
      x_complete_rec.deduction_identifier_id := l_na_ddn_rule_rec.deduction_identifier_id;
   END IF;

   -- deduction_identifier_org_id
   IF p_na_ddn_rule_rec.deduction_identifier_org_id IS NULL THEN
      x_complete_rec.deduction_identifier_org_id := l_na_ddn_rule_rec.deduction_identifier_org_id;
   END IF;

   -- object_version_number
   IF p_na_ddn_rule_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_na_ddn_rule_rec.object_version_number;
   END IF;

   -- creation_date
   IF p_na_ddn_rule_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_na_ddn_rule_rec.creation_date;
   END IF;

   -- created_by
   IF p_na_ddn_rule_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_na_ddn_rule_rec.created_by;
   END IF;

   -- last_update_date
   IF p_na_ddn_rule_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_na_ddn_rule_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_na_ddn_rule_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_na_ddn_rule_rec.last_updated_by;
   END IF;

   -- last_update_login
   IF p_na_ddn_rule_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_na_ddn_rule_rec.last_update_login;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Na_Ddn_Rule_Rec;




PROCEDURE Default_Na_Ddn_Rule_Items ( p_na_ddn_rule_rec IN na_ddn_rule_rec_type ,
                                x_na_ddn_rule_rec OUT NOCOPY na_ddn_rule_rec_type )
IS
   l_na_ddn_rule_rec na_ddn_rule_rec_type := p_na_ddn_rule_rec;
BEGIN
   -- Developers should put their code to default the record type
   -- e.g. IF p_campaign_rec.status_code IS NULL
   --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
   --         l_campaign_rec.status_code := 'NEW' ;
   --      END IF ;
   --
   NULL ;
END;




PROCEDURE Validate_Na_Ddn_Rule(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_na_ddn_rule_rec               IN   na_ddn_rule_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Na_Ddn_Rule';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_na_ddn_rule_rec  na_ddn_rule_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_na_ddn_rule_;

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
              Check_na_ddn_rule_Items(
                 p_na_ddn_rule_rec        => p_na_ddn_rule_rec,
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
         Default_Na_Ddn_Rule_Items (p_na_ddn_rule_rec => p_na_ddn_rule_rec ,
                                x_na_ddn_rule_rec => l_na_ddn_rule_rec) ;
      END IF ;

      Complete_na_ddn_rule_Rec(
         p_na_ddn_rule_rec        => p_na_ddn_rule_rec,
         x_complete_rec        => l_na_ddn_rule_rec
      );


      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_na_ddn_rule_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_na_ddn_rule_rec           =>    l_na_ddn_rule_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
      debug_message('Private API: ' || l_api_name || 'start');



      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


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
     ROLLBACK TO VALIDATE_Na_Ddn_Rule_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Na_Ddn_Rule_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Na_Ddn_Rule_;
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
End Validate_Na_Ddn_Rule;


PROCEDURE Validate_Na_Ddn_Rule_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_na_ddn_rule_rec               IN    na_ddn_rule_rec_type
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
      debug_message('Private API: Validate_dm_model_rec');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_na_ddn_rule_Rec;

END OZF_Na_Ddn_Rule_PVT;

/
