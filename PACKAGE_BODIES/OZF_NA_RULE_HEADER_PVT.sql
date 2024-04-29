--------------------------------------------------------
--  DDL for Package Body OZF_NA_RULE_HEADER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_NA_RULE_HEADER_PVT" as
/* $Header: ozfvnarb.pls 120.0 2005/06/01 03:24:50 appldev noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          OZF_Na_Rule_Header_PVT
-- Purpose
--
-- History
--        Thu Nov 20 2003:6/35 PM  RSSHARMA Added function get_rule_name
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- Wed Jan 14 2004:1/45 PM RSSHARMA Changed AMS_API_MISSING_FIELD messages to OZF_API_MISSING_FIELD
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Na_Rule_Header_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvdnrb.pls';

-- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
-- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
--
-- Foreward Procedure Declarations
--

PROCEDURE Default_Na_Rule_Header_Items (
   p_na_rule_header_rec IN  na_rule_header_rec_type ,
   x_na_rule_header_rec OUT NOCOPY na_rule_header_rec_type
) ;

FUNCTION get_rule_name(p_na_rule_header_id IN NUMBER)
RETURN VARCHAR2
IS
CURSOR c_rule_name (p_na_rule_header_id NUMBER ) IS
SELECT name FROM OZF_NA_RULE_HEADERS_TL
WHERE na_rule_header_id = p_na_rule_header_id
AND language = userenv('lang');

l_name OZF_NA_RULE_HEADERS_TL.name%type;
BEGIN
OPEN c_rule_name (p_na_rule_header_id);
FETCH c_rule_name  INTO l_name;
close c_rule_name ;

RETURN l_name;
END;


-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Na_Rule_Header
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
--       p_na_rule_header_rec            IN   na_rule_header_rec_type  Required
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

PROCEDURE Create_Na_Rule_Header(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_na_rule_header_rec              IN   na_rule_header_rec_type  ,
    x_na_rule_header_id              OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Na_Rule_Header';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;

l_na_rule_header_rec na_rule_header_rec_type;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_na_rule_header_id              NUMBER;
   l_dummy                     NUMBER;
   CURSOR c_id IS
      SELECT ozf_na_rule_headers_b_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM OZF_NA_RULE_HEADERS_B
      WHERE na_rule_header_id = l_id;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_na_rule_header_pvt;

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


   -- Local variable initialization

   IF p_na_rule_header_rec.na_rule_header_id IS NULL OR p_na_rule_header_rec.na_rule_header_id = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_na_rule_header_id;
         CLOSE c_id;

         OPEN c_id_exists(l_na_rule_header_id);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
      END LOOP;
   ELSE
         l_na_rule_header_id := p_na_rule_header_rec.na_rule_header_id;
   END IF;


l_na_rule_header_rec := p_na_rule_header_rec;
l_na_rule_header_rec.na_rule_header_id := l_na_rule_header_id;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          OZF_UTILITY_PVT.debug_message('Private API: Validate_Na_Rule_Header');

          -- Invoke validation procedures
          Validate_na_rule_header(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_na_rule_header_rec  =>  l_na_rule_header_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
      OZF_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');

      -- Invoke table handler(Ozf_Na_Rule_Header_Pkg.Insert_Row)
      Ozf_Na_Rule_Header_Pkg.Insert_Row(
          px_na_rule_header_id  => l_na_rule_header_id,
          p_user_status_id  => l_na_rule_header_rec.user_status_id,
          p_status_code  => l_na_rule_header_rec.status_code,
          p_start_date  => l_na_rule_header_rec.start_date,
          p_end_date  => l_na_rule_header_rec.end_date,
          px_object_version_number  => l_object_version_number,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_name  => l_na_rule_header_rec.name,
          p_description  => l_na_rule_header_rec.description
);

          x_na_rule_header_id := l_na_rule_header_id;
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
     ROLLBACK TO CREATE_Na_Rule_Header_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Na_Rule_Header_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Na_Rule_Header_PVT;
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
End Create_Na_Rule_Header;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Na_Rule_Header
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
--       p_na_rule_header_rec            IN   na_rule_header_rec_type  Required
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

PROCEDURE Update_Na_Rule_Header(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_na_rule_header_rec               IN    na_rule_header_rec_type
    )

 IS


CURSOR c_get_na_rule_header(na_rule_header_id NUMBER) IS
    SELECT *
    FROM  OZF_NA_RULE_HEADERS_B
    WHERE  na_rule_header_id = p_na_rule_header_rec.na_rule_header_id;
    -- Hint: Developer need to provide Where clause


L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Na_Rule_Header';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_na_rule_header_id    NUMBER;
l_ref_na_rule_header_rec  c_get_Na_Rule_Header%ROWTYPE ;
l_tar_na_rule_header_rec  na_rule_header_rec_type := P_na_rule_header_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT update_na_rule_header_pvt;

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

      OPEN c_get_Na_Rule_Header( l_tar_na_rule_header_rec.na_rule_header_id);

      FETCH c_get_Na_Rule_Header INTO l_ref_na_rule_header_rec  ;

       If ( c_get_Na_Rule_Header%NOTFOUND) THEN
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Na_Rule_Header') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       OZF_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       CLOSE     c_get_Na_Rule_Header;


      If (l_tar_na_rule_header_rec.object_version_number is NULL or
          l_tar_na_rule_header_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_na_rule_header_rec.object_version_number <> l_ref_na_rule_header_rec.object_version_number) Then
  OZF_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Na_Rule_Header') ;
          raise FND_API.G_EXC_ERROR;
      End if;


      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          OZF_UTILITY_PVT.debug_message('Private API: Validate_Na_Rule_Header');

          -- Invoke validation procedures
          Validate_na_rule_header(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_na_rule_header_rec  =>  p_na_rule_header_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;


      -- Debug Message
--      OZF_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');

      -- Invoke table handler(Ozf_Na_Rule_Header_Pkg.Update_Row)
      Ozf_Na_Rule_Header_Pkg.Update_Row(
          p_na_rule_header_id  => p_na_rule_header_rec.na_rule_header_id,
          p_user_status_id  => p_na_rule_header_rec.user_status_id,
          p_status_code  => p_na_rule_header_rec.status_code,
          p_start_date  => p_na_rule_header_rec.start_date,
          p_end_date  => p_na_rule_header_rec.end_date,
          p_object_version_number  => p_na_rule_header_rec.object_version_number,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_name  => p_na_rule_header_rec.name,
          p_description  => p_na_rule_header_rec.description
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
     ROLLBACK TO UPDATE_Na_Rule_Header_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Na_Rule_Header_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Na_Rule_Header_PVT;
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
End Update_Na_Rule_Header;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Na_Rule_Header
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
--       p_na_rule_header_id                IN   NUMBER
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

PROCEDURE Delete_Na_Rule_Header(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_na_rule_header_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Na_Rule_Header';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_na_rule_header_pvt;

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

      -- Invoke table handler(Ozf_Na_Rule_Header_Pkg.Delete_Row)
      Ozf_Na_Rule_Header_Pkg.Delete_Row(
          p_na_rule_header_id  => p_na_rule_header_id,
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
     ROLLBACK TO DELETE_Na_Rule_Header_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Na_Rule_Header_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Na_Rule_Header_PVT;
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
End Delete_Na_Rule_Header;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Lock_Na_Rule_Header
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
--       p_na_rule_header_rec            IN   na_rule_header_rec_type  Required
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

PROCEDURE Lock_Na_Rule_Header(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_na_rule_header_id                   IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Na_Rule_Header';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_na_rule_header_id                  NUMBER;

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
Ozf_Na_Rule_Header_Pkg.Lock_Row(l_na_rule_header_id,p_object_version);


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
     ROLLBACK TO LOCK_Na_Rule_Header_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Na_Rule_Header_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Na_Rule_Header_PVT;
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
End Lock_Na_Rule_Header;




PROCEDURE check_Na_Rule_Hdr_Uk_Items(
    p_na_rule_header_rec               IN   na_rule_header_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_na_rule_header_rec.na_rule_header_id IS NOT NULL
      THEN
         l_valid_flag := OZF_Utility_PVT.check_uniqueness(
         'ozf_na_rule_headers_b',
         'na_rule_header_id = ''' || p_na_rule_header_rec.na_rule_header_id ||''''
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_na_rule_header_id_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
      END IF;

END check_Na_Rule_Hdr_Uk_Items;



PROCEDURE check_Na_Rule_Hdr_Req_Items(
    p_na_rule_header_rec               IN  na_rule_header_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_na_rule_header_rec.na_rule_header_id = FND_API.G_MISS_NUM OR p_na_rule_header_rec.na_rule_header_id IS NULL THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'NA_RULE_HEADER_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


/*      IF p_na_rule_header_rec.user_status_id = FND_API.G_MISS_NUM OR p_na_rule_header_rec.user_status_id IS NULL THEN
               OZF_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'USER_STATUS_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_na_rule_header_rec.status_code = FND_API.g_miss_char OR p_na_rule_header_rec.status_code IS NULL THEN
               OZF_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'STATUS_CODE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
*/

/*      IF p_na_rule_header_rec.object_version_number = FND_API.G_MISS_NUM OR p_na_rule_header_rec.object_version_number IS NULL THEN
               OZF_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUMBER' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
*/

   ELSE


      IF p_na_rule_header_rec.na_rule_header_id = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'NA_RULE_HEADER_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;

/*
      IF p_na_rule_header_rec.user_status_id = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'USER_STATUS_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_na_rule_header_rec.status_code = FND_API.g_miss_char THEN
               OZF_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'STATUS_CODE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
*/

      IF p_na_rule_header_rec.object_version_number = FND_API.G_MISS_NUM THEN
               OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUMBER' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_Na_Rule_Hdr_Req_Items;



PROCEDURE check_Na_Rule_Hdr_Fk_Items(
    p_na_rule_header_rec IN na_rule_header_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Na_Rule_Hdr_Fk_Items;



PROCEDURE check_Na_Rule_Hdr_Lkp_Items(
    p_na_rule_header_rec IN na_rule_header_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Na_Rule_Hdr_Lkp_Items;



PROCEDURE check_Na_Rule_Hdr_Items (
    P_na_rule_header_rec     IN    na_rule_header_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

    l_return_status := FND_API.g_ret_sts_success;
   -- Check Items Uniqueness API calls

   check_Na_Rule_Hdr_Uk_Items(
      p_na_rule_header_rec => p_na_rule_header_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_na_rule_hdr_req_items(
      p_na_rule_header_rec => p_na_rule_header_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Foreign Keys API calls

   check_na_rule_hdr_FK_items(
      p_na_rule_header_rec => p_na_rule_header_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Lookups

   check_na_rule_hdr_Lkp_items(
      p_na_rule_header_rec => p_na_rule_header_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   x_return_status := l_return_status;

END check_na_rule_hdr_Items;





PROCEDURE Complete_Na_Rule_Hdr_Rec (
   p_na_rule_header_rec IN na_rule_header_rec_type,
   x_complete_rec OUT NOCOPY na_rule_header_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ozf_na_rule_headers_b
      WHERE na_rule_header_id = p_na_rule_header_rec.na_rule_header_id;
   l_na_rule_header_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_na_rule_header_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_na_rule_header_rec;
   CLOSE c_complete;

   -- na_rule_header_id
   IF p_na_rule_header_rec.na_rule_header_id IS NULL THEN
      x_complete_rec.na_rule_header_id := l_na_rule_header_rec.na_rule_header_id;
   END IF;

   -- user_status_id
   IF p_na_rule_header_rec.user_status_id IS NULL THEN
      x_complete_rec.user_status_id := l_na_rule_header_rec.user_status_id;
   END IF;

   -- status_code
   IF p_na_rule_header_rec.status_code IS NULL THEN
      x_complete_rec.status_code := l_na_rule_header_rec.status_code;
   END IF;

   -- start_date
   IF p_na_rule_header_rec.start_date IS NULL THEN
      x_complete_rec.start_date := l_na_rule_header_rec.start_date;
   END IF;

   -- end_date
   IF p_na_rule_header_rec.end_date IS NULL THEN
      x_complete_rec.end_date := l_na_rule_header_rec.end_date;
   END IF;

   -- object_version_number
   IF p_na_rule_header_rec.object_version_number IS NULL THEN
      x_complete_rec.object_version_number := l_na_rule_header_rec.object_version_number;
   END IF;

   -- creation_date
   IF p_na_rule_header_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_na_rule_header_rec.creation_date;
   END IF;

   -- created_by
   IF p_na_rule_header_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_na_rule_header_rec.created_by;
   END IF;

   -- last_update_date
   IF p_na_rule_header_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_na_rule_header_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_na_rule_header_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_na_rule_header_rec.last_updated_by;
   END IF;

   -- last_update_login
   IF p_na_rule_header_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_na_rule_header_rec.last_update_login;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Na_Rule_Hdr_Rec;




PROCEDURE Default_Na_Rule_Header_Items ( p_na_rule_header_rec IN na_rule_header_rec_type ,
                                x_na_rule_header_rec OUT NOCOPY na_rule_header_rec_type )
IS
   l_na_rule_header_rec na_rule_header_rec_type := p_na_rule_header_rec;
BEGIN
   -- Developers should put their code to default the record type
   -- e.g. IF p_campaign_rec.status_code IS NULL
   --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
   --         l_campaign_rec.status_code := 'NEW' ;
   --      END IF ;
   --
   NULL ;
END;




PROCEDURE Validate_Na_Rule_Header(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_na_rule_header_rec               IN   na_rule_header_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Na_Rule_Header';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_na_rule_header_rec  na_rule_header_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_na_rule_header_;

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

         l_na_rule_header_rec :=  p_na_rule_header_rec;

      Complete_Na_Rule_Hdr_Rec(
         p_na_rule_header_rec        => p_na_rule_header_rec,
         x_complete_rec        => l_na_rule_header_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
              check_na_rule_hdr_Items(
                 p_na_rule_header_rec        => l_na_rule_header_rec,
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
         Default_Na_Rule_Header_Items (p_na_rule_header_rec => p_na_rule_header_rec ,
                                x_na_rule_header_rec => l_na_rule_header_rec) ;
      END IF ;


      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_na_rule_header_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_na_rule_header_rec           =>    l_na_rule_header_rec);

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
     ROLLBACK TO VALIDATE_Na_Rule_Header_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Na_Rule_Header_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Na_Rule_Header_;
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
End Validate_Na_Rule_Header;


PROCEDURE Validate_Na_Rule_Header_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_na_rule_header_rec               IN    na_rule_header_rec_type
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
END Validate_na_rule_header_Rec;

END OZF_Na_Rule_Header_PVT;

/
