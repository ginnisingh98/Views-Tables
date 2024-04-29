--------------------------------------------------------
--  DDL for Package Body OZF_OFFR_QUAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OZF_OFFR_QUAL_PVT" as
 /* $Header: ozfvoqfb.pls 120.2 2005/09/22 15:57:45 rssharma ship $ */
 -- ===============================================================
 -- Start of Comments
 -- Package name
 --          OZF_Offr_Qual_PVT
 -- Purpose
 --
 -- History
 --
 -- NOTE
 --
 -- This Api is generated with Latest version of
 -- Rosetta, where g_miss indicates NULL and
 -- NULL indicates missing value. Rosetta Version 1.55
 -- Wed Jan 14 2004:1/45 PM RSSHARMA Changed AMS_API_MISSING_FIELD messages to OZF_API_MISSING_FIELD
 -- Thu Sep 22 2005:3/46 PM RSSHARMA Fixed bug # 4628765. Could not update Net Accrual market eligibility
 -- due to offerid being lost in record completion. Record completion does not serve any big purpose
 -- so removed record completion
 -- End of Comments
 -- ===============================================================


 G_PKG_NAME CONSTANT VARCHAR2(30):= 'OZF_Offr_Qual_PVT';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'ozfvoqfb.pls';

 -- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
 -- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
 --
 -- Foreward Procedure Declarations
 --

 PROCEDURE Default_Ozf_Offr_Qual_Items (
    p_ozf_offr_qual_rec IN  ozf_offr_qual_rec_type ,
    x_ozf_offr_qual_rec OUT NOCOPY ozf_offr_qual_rec_type
 ) ;



 -- Hint: Primary key needs to be returned.
 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Create_Offr_Qual
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
 --       p_ozf_offr_qual_rec            IN   ozf_offr_qual_rec_type  Required
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

 PROCEDURE Create_Offr_Qual(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
     p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
     p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2,

     p_ozf_offr_qual_rec              IN   ozf_offr_qual_rec_type  ,
     x_qualifier_id              OUT NOCOPY  NUMBER
      )

  IS
 l_api_name                  CONSTANT VARCHAR2(30) := 'Create_Offr_Qual';
 l_api_version_number        CONSTANT NUMBER   := 1.0;
    l_return_status_full        VARCHAR2(1);
    l_object_version_number     NUMBER := 1;
    l_org_id                    NUMBER := FND_API.G_MISS_NUM;
    l_qualifier_id              NUMBER;
    l_dummy                     NUMBER;
    l_ozf_offr_qual_rec         ozf_offr_qual_rec_type;
    CURSOR c_id IS
       SELECT ozf_offer_qualifiers_s.NEXTVAL
       FROM dual;

    CURSOR c_id_exists (l_id IN NUMBER) IS
       SELECT 1
       FROM OZF_OFFER_QUALIFIERS
       WHERE qualifier_id = l_id;
 BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT create_offr_qual_pvt;

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


    IF p_ozf_offr_qual_rec.qualifier_id IS NULL OR p_ozf_offr_qual_rec.qualifier_id = FND_API.g_miss_num THEN
       LOOP
          l_dummy := NULL;
          OPEN c_id;
          FETCH c_id INTO l_qualifier_id;
          CLOSE c_id;

          OPEN c_id_exists(l_qualifier_id);
          FETCH c_id_exists INTO l_dummy;
          CLOSE c_id_exists;
          EXIT WHEN l_dummy IS NULL;
       END LOOP;
    ELSE
          l_qualifier_id := p_ozf_offr_qual_rec.qualifier_id;
    END IF;



    l_ozf_offr_qual_rec := p_ozf_offr_qual_rec;
    l_ozf_offr_qual_rec.qualifier_id := l_qualifier_id;

       IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
       THEN
           -- Debug message
           OZF_UTILITY_PVT.debug_message('Private API: Validate_Offr_Qual');

           -- Invoke validation procedures
           Validate_offr_qual(
             p_api_version_number     => 1.0,
             p_init_msg_list    => FND_API.G_FALSE,
             p_validation_level => p_validation_level,
             p_validation_mode => JTF_PLSQL_API.g_create,
             p_ozf_offr_qual_rec  =>  l_ozf_offr_qual_rec,
             x_return_status    => x_return_status,
             x_msg_count        => x_msg_count,
             x_msg_data         => x_msg_data);

       END IF;

       IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
       END IF;

    -- Local variable initialization


       -- Debug Message
       OZF_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');

       -- Invoke table handler(Ozf_Offr_Qual_Pkg.Insert_Row)
       Ozf_Offr_Qual_Pkg.Insert_Row(
           px_qualifier_id  => l_qualifier_id,
           p_creation_date  => SYSDATE,
           p_created_by  => FND_GLOBAL.USER_ID,
           p_last_update_date  => SYSDATE,
           p_last_updated_by  => FND_GLOBAL.USER_ID,
           p_last_update_login  => FND_GLOBAL.conc_login_id,
           p_qualifier_grouping_no  => p_ozf_offr_qual_rec.qualifier_grouping_no,
           p_qualifier_context  => p_ozf_offr_qual_rec.qualifier_context,
           p_qualifier_attribute  => p_ozf_offr_qual_rec.qualifier_attribute,
           p_qualifier_attr_value  => p_ozf_offr_qual_rec.qualifier_attr_value,
           p_start_date_active  => p_ozf_offr_qual_rec.start_date_active,
           p_end_date_active  => p_ozf_offr_qual_rec.end_date_active,
           p_offer_id  => p_ozf_offr_qual_rec.offer_id,
           p_offer_discount_line_id  => p_ozf_offr_qual_rec.offer_discount_line_id,
           p_context  => p_ozf_offr_qual_rec.context,
           p_attribute1  => p_ozf_offr_qual_rec.attribute1,
           p_attribute2  => p_ozf_offr_qual_rec.attribute2,
           p_attribute3  => p_ozf_offr_qual_rec.attribute3,
           p_attribute4  => p_ozf_offr_qual_rec.attribute4,
           p_attribute5  => p_ozf_offr_qual_rec.attribute5,
           p_attribute6  => p_ozf_offr_qual_rec.attribute6,
           p_attribute7  => p_ozf_offr_qual_rec.attribute7,
           p_attribute8  => p_ozf_offr_qual_rec.attribute8,
           p_attribute9  => p_ozf_offr_qual_rec.attribute9,
           p_attribute10  => p_ozf_offr_qual_rec.attribute10,
           p_attribute11  => p_ozf_offr_qual_rec.attribute11,
           p_attribute12  => p_ozf_offr_qual_rec.attribute12,
           p_attribute13  => p_ozf_offr_qual_rec.attribute13,
           p_attribute14  => p_ozf_offr_qual_rec.attribute14,
           p_attribute15  => p_ozf_offr_qual_rec.attribute15,
           p_active_flag  => p_ozf_offr_qual_rec.active_flag,
           p_object_version_number => 1
 );

           x_qualifier_id := l_qualifier_id;
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
      ROLLBACK TO CREATE_Offr_Qual_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_Offr_Qual_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO CREATE_Offr_Qual_PVT;
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
 End Create_Offr_Qual;


 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Update_Offr_Qual
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
 --       p_ozf_offr_qual_rec            IN   ozf_offr_qual_rec_type  Required
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

 PROCEDURE Update_Offr_Qual(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
     p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
     p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2,

     p_ozf_offr_qual_rec               IN    ozf_offr_qual_rec_type
     )

  IS


 CURSOR c_get_offr_qual(qualifier_id NUMBER) IS
     SELECT *
     FROM  OZF_OFFER_QUALIFIERS
     WHERE  qualifier_id = p_ozf_offr_qual_rec.qualifier_id;
     -- Hint: Developer need to provide Where clause


 L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Offr_Qual';
 L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
 -- Local Variables
 l_object_version_number     NUMBER;
 l_qualifier_id    NUMBER;
 l_ref_ozf_offr_qual_rec  c_get_Offr_Qual%ROWTYPE ;
 l_tar_ozf_offr_qual_rec  ozf_offr_qual_rec_type := p_ozf_offr_qual_rec;
 l_rowid  ROWID;

  BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT update_offr_qual_pvt;

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

       OPEN c_get_Offr_Qual( l_tar_ozf_offr_qual_rec.qualifier_id);

       FETCH c_get_Offr_Qual INTO l_ref_ozf_offr_qual_rec  ;

        If ( c_get_Offr_Qual%NOTFOUND) THEN
   OZF_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
    p_token_name   => 'INFO',
  p_token_value  => 'Offr_Qual') ;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- Debug Message
        OZF_UTILITY_PVT.debug_message('Private API: - Close Cursor');
        CLOSE     c_get_Offr_Qual;


       If (l_tar_ozf_offr_qual_rec.object_version_number is NULL or
           l_tar_ozf_offr_qual_rec.object_version_number = FND_API.G_MISS_NUM ) Then
   OZF_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
    p_token_name   => 'COLUMN',
  p_token_value  => 'Last_Update_Date') ;
           raise FND_API.G_EXC_ERROR;
       End if;
       -- Check Whether record has been changed by someone else
       If (l_tar_ozf_offr_qual_rec.object_version_number <> l_ref_ozf_offr_qual_rec.object_version_number) Then
   OZF_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
    p_token_name   => 'INFO',
  p_token_value  => 'Offr_Qual') ;
           raise FND_API.G_EXC_ERROR;
       End if;

ozf_utility_pvt.debug_message('OfferId 1 is :'||p_ozf_offr_qual_rec.offer_id);
       IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
       THEN
           -- Debug message
           OZF_UTILITY_PVT.debug_message('Private API: Validate_Offr_Qual');

           -- Invoke validation procedures
           Validate_offr_qual(
             p_api_version_number     => 1.0,
             p_init_msg_list    => FND_API.G_FALSE,
             p_validation_level => p_validation_level,
             p_validation_mode => JTF_PLSQL_API.g_update,
             p_ozf_offr_qual_rec  =>  p_ozf_offr_qual_rec,
             x_return_status    => x_return_status,
             x_msg_count        => x_msg_count,
             x_msg_data         => x_msg_data);
       END IF;

       IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
       END IF;

       -- Debug Message
       OZF_UTILITY_PVT.debug_message( 'Private API: Calling update table handler');

       -- Invoke table handler(Ozf_Offr_Qual_Pkg.Update_Row)
       Ozf_Offr_Qual_Pkg.Update_Row(
           p_qualifier_id  => p_ozf_offr_qual_rec.qualifier_id,
           p_last_update_date  => SYSDATE,
           p_last_updated_by  => FND_GLOBAL.USER_ID,
           p_last_update_login  => FND_GLOBAL.conc_login_id,
           p_qualifier_grouping_no  => p_ozf_offr_qual_rec.qualifier_grouping_no,
           p_qualifier_context  => p_ozf_offr_qual_rec.qualifier_context,
           p_qualifier_attribute  => p_ozf_offr_qual_rec.qualifier_attribute,
           p_qualifier_attr_value  => p_ozf_offr_qual_rec.qualifier_attr_value,
           p_start_date_active  =>  p_ozf_offr_qual_rec.start_date_active,
           p_end_date_active  => p_ozf_offr_qual_rec.end_date_active,
           p_offer_id  => p_ozf_offr_qual_rec.offer_id,
           p_offer_discount_line_id  => p_ozf_offr_qual_rec.offer_discount_line_id,
           p_context  => p_ozf_offr_qual_rec.context,
           p_attribute1  => p_ozf_offr_qual_rec.attribute1,
           p_attribute2  => p_ozf_offr_qual_rec.attribute2,
           p_attribute3  => p_ozf_offr_qual_rec.attribute3,
           p_attribute4  => p_ozf_offr_qual_rec.attribute4,
           p_attribute5  => p_ozf_offr_qual_rec.attribute5,
           p_attribute6  => p_ozf_offr_qual_rec.attribute6,
           p_attribute7  => p_ozf_offr_qual_rec.attribute7,
           p_attribute8  => p_ozf_offr_qual_rec.attribute8,
           p_attribute9  => p_ozf_offr_qual_rec.attribute9,
           p_attribute10  => p_ozf_offr_qual_rec.attribute10,
           p_attribute11  => p_ozf_offr_qual_rec.attribute11,
           p_attribute12  => p_ozf_offr_qual_rec.attribute12,
           p_attribute13  => p_ozf_offr_qual_rec.attribute13,
           p_attribute14  => p_ozf_offr_qual_rec.attribute14,
           p_attribute15  => p_ozf_offr_qual_rec.attribute15,
           p_active_flag  => p_ozf_offr_qual_rec.active_flag,
           p_object_version_number => p_ozf_offr_qual_rec.object_version_number
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
      ROLLBACK TO UPDATE_Offr_Qual_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_Offr_Qual_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO UPDATE_Offr_Qual_PVT;
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
 End Update_Offr_Qual;


 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Delete_Offr_Qual
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
 --       p_qualifier_id                IN   NUMBER
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

 PROCEDURE Delete_Offr_Qual(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
     p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
     p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2,
     p_qualifier_id                   IN  NUMBER,
     p_object_version_number      IN   NUMBER
     )

  IS
 L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Offr_Qual';
 L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
 l_object_version_number     NUMBER;

  BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT delete_offr_qual_pvt;

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

       -- Invoke table handler(Ozf_Offr_Qual_Pkg.Delete_Row)
       Ozf_Offr_Qual_Pkg.Delete_Row(
           p_qualifier_id  => p_qualifier_id,
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
      ROLLBACK TO DELETE_Offr_Qual_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO DELETE_Offr_Qual_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO DELETE_Offr_Qual_PVT;
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
 End Delete_Offr_Qual;



 -- Hint: Primary key needs to be returned.
 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Lock_Offr_Qual
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
 --       p_ozf_offr_qual_rec            IN   ozf_offr_qual_rec_type  Required
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

 PROCEDURE Lock_Offr_Qual(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2,

     p_qualifier_id                   IN  NUMBER,
     p_object_version             IN  NUMBER
     )

  IS
 L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Offr_Qual';
 L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
 L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
 l_qualifier_id                  NUMBER;

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
 Ozf_Offr_Qual_Pkg.Lock_Row(l_qualifier_id,p_object_version);


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
      ROLLBACK TO LOCK_Offr_Qual_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO LOCK_Offr_Qual_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO LOCK_Offr_Qual_PVT;
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
 End Lock_Offr_Qual;




 PROCEDURE check_Ozf_Offr_Qual_Uk_Items(
     p_ozf_offr_qual_rec               IN   ozf_offr_qual_rec_type,
     p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
     x_return_status              OUT NOCOPY VARCHAR2)
 IS
 l_valid_flag  VARCHAR2(1);

 BEGIN
       x_return_status := FND_API.g_ret_sts_success;
       IF p_validation_mode = JTF_PLSQL_API.g_create
       AND p_ozf_offr_qual_rec.qualifier_id IS NOT NULL
       THEN
          l_valid_flag := OZF_Utility_PVT.check_uniqueness(
          'ozf_offer_qualifiers',
          'qualifier_id = ''' || p_ozf_offr_qual_rec.qualifier_id ||''''
          );
       END IF;

       IF l_valid_flag = FND_API.g_false THEN
          OZF_Utility_PVT.Error_Message(p_message_name => 'OZF_qual_id_DUP');
          x_return_status := FND_API.g_ret_sts_error;
       END IF;

 END check_Ozf_Offr_Qual_Uk_Items;



 PROCEDURE check_ozf_offr_qual_req_items(
     p_ozf_offr_qual_rec               IN  ozf_offr_qual_rec_type,
     p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
     x_return_status              OUT NOCOPY VARCHAR2
 )
 IS
 BEGIN
    x_return_status := FND_API.g_ret_sts_success;

    IF p_validation_mode = JTF_PLSQL_API.g_create THEN


       IF p_ozf_offr_qual_rec.qualifier_id = FND_API.G_MISS_NUM OR p_ozf_offr_qual_rec.qualifier_id IS NULL THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'QUALIFIER_ID' );
                x_return_status := FND_API.g_ret_sts_error;
       END IF;


/*       IF p_ozf_offr_qual_rec.qualifier_context = FND_API.g_miss_char OR p_ozf_offr_qual_rec.qualifier_context IS NULL THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'QUALIFIER_CONTEXT' );
                x_return_status := FND_API.g_ret_sts_error;
       END IF;
*/

       IF p_ozf_offr_qual_rec.qualifier_attribute = FND_API.g_miss_char OR p_ozf_offr_qual_rec.qualifier_attribute IS NULL THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'QUALIFIER_ATTRIBUTE' );
                x_return_status := FND_API.g_ret_sts_error;
       END IF;

       IF p_ozf_offr_qual_rec.qualifier_attr_value = FND_API.g_miss_char OR p_ozf_offr_qual_rec.qualifier_attr_value IS NULL THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'QUALIFIER_ATTR_VALUE' );
                x_return_status := FND_API.g_ret_sts_error;
       END IF;


       IF p_ozf_offr_qual_rec.offer_id = FND_API.G_MISS_NUM OR p_ozf_offr_qual_rec.offer_id IS NULL THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFFER_ID' );
                x_return_status := FND_API.g_ret_sts_error;
       END IF;


    ELSE


       IF p_ozf_offr_qual_rec.qualifier_id = FND_API.G_MISS_NUM THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'QUALIFIER_ID' );
                x_return_status := FND_API.g_ret_sts_error;
       END IF;


/*       IF p_ozf_offr_qual_rec.qualifier_context = FND_API.g_miss_char THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'QUALIFIER_CONTEXT' );
                x_return_status := FND_API.g_ret_sts_error;
       END IF;
*/

       IF p_ozf_offr_qual_rec.qualifier_attribute = FND_API.g_miss_char THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'QUALIFIER_ATTRIBUTE' );
                x_return_status := FND_API.g_ret_sts_error;
       END IF;

       IF p_ozf_offr_qual_rec.qualifier_attr_value = FND_API.g_miss_char THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'QUALIFIER_ATTR_VALUE' );
                x_return_status := FND_API.g_ret_sts_error;
       END IF;


       IF p_ozf_offr_qual_rec.offer_id = FND_API.G_MISS_NUM THEN
                OZF_Utility_PVT.Error_Message('OZF_API_MISSING_FIELD', 'MISS_FIELD', 'OFFER_ID' );
                x_return_status := FND_API.g_ret_sts_error;
       END IF;
    END IF;

 END check_ozf_offr_qual_req_items;



 PROCEDURE check_ozf_offr_qual_FK_items(
     p_ozf_offr_qual_rec IN ozf_offr_qual_rec_type,
     x_return_status OUT NOCOPY VARCHAR2
 )
 IS
l_fk_exists VARCHAR2(10);
 BEGIN
    x_return_status := FND_API.g_ret_sts_success;


l_fk_exists := ozf_utility_pvt.check_fk_exists(
   p_table_name   => 'OZF_OFFERS',
   p_pk_name      => 'OFFER_ID',
   p_pk_value     => p_ozf_offr_qual_rec.offer_id);

IF  l_fk_exists = FND_API.g_false THEN
    x_return_status := FND_API.g_ret_sts_error;
END IF;

    -- Enter custom code here
 END check_ozf_offr_qual_FK_items;



 PROCEDURE check_ozf_offr_qual_Lkp_items(
     p_ozf_offr_qual_rec IN ozf_offr_qual_rec_type,
     x_return_status OUT NOCOPY VARCHAR2
 )
 IS
 BEGIN
    x_return_status := FND_API.g_ret_sts_success;

    -- Enter custom code here

 END check_ozf_offr_qual_Lkp_items;



 PROCEDURE Check_ozf_offr_qual_Items (
     p_ozf_offr_qual_rec     IN    ozf_offr_qual_rec_type,
     p_validation_mode  IN    VARCHAR2,
     x_return_status    OUT NOCOPY   VARCHAR2
     )
 IS
    l_return_status   VARCHAR2(1);
 BEGIN

     l_return_status := FND_API.g_ret_sts_success;
    -- Check Items Uniqueness API calls

    check_Ozf_Offr_Qual_Uk_Items(
       p_ozf_offr_qual_rec => p_ozf_offr_qual_rec,
       p_validation_mode => p_validation_mode,
       x_return_status => x_return_status);
    IF x_return_status <> FND_API.g_ret_sts_success THEN
       l_return_status := FND_API.g_ret_sts_error;
    END IF;

    -- Check Items Required/NOT NULL API calls

    check_ozf_offr_qual_req_items(
       p_ozf_offr_qual_rec => p_ozf_offr_qual_rec,
       p_validation_mode => p_validation_mode,
       x_return_status => x_return_status);
    IF x_return_status <> FND_API.g_ret_sts_success THEN
       l_return_status := FND_API.g_ret_sts_error;
    END IF;
    -- Check Items Foreign Keys API calls

    check_ozf_offr_qual_FK_items(
       p_ozf_offr_qual_rec => p_ozf_offr_qual_rec,
       x_return_status => x_return_status);
    IF x_return_status <> FND_API.g_ret_sts_success THEN
       l_return_status := FND_API.g_ret_sts_error;
    END IF;
    -- Check Items Lookups

    check_ozf_offr_qual_Lkp_items(
       p_ozf_offr_qual_rec => p_ozf_offr_qual_rec,
       x_return_status => x_return_status);
    IF x_return_status <> FND_API.g_ret_sts_success THEN
       l_return_status := FND_API.g_ret_sts_error;
    END IF;

    x_return_status := l_return_status;

 END Check_ozf_offr_qual_Items;





 PROCEDURE Complete_ozf_offr_qual_Rec (
    p_ozf_offr_qual_rec IN ozf_offr_qual_rec_type,
    x_complete_rec OUT NOCOPY ozf_offr_qual_rec_type)
 IS
    l_return_status  VARCHAR2(1);

    CURSOR c_complete IS
       SELECT *
       FROM ozf_offer_qualifiers
       WHERE qualifier_id = p_ozf_offr_qual_rec.qualifier_id;
    l_ozf_offr_qual_rec c_complete%ROWTYPE;
 BEGIN
    x_complete_rec := p_ozf_offr_qual_rec;

    OPEN c_complete;
    FETCH c_complete INTO l_ozf_offr_qual_rec;
    CLOSE c_complete;

    -- qualifier_id
    IF p_ozf_offr_qual_rec.qualifier_id IS NULL THEN
       x_complete_rec.qualifier_id := l_ozf_offr_qual_rec.qualifier_id;
    END IF;

    -- creation_date
    IF p_ozf_offr_qual_rec.creation_date IS NULL THEN
       x_complete_rec.creation_date := l_ozf_offr_qual_rec.creation_date;
    END IF;

    -- created_by
    IF p_ozf_offr_qual_rec.created_by IS NULL THEN
       x_complete_rec.created_by := l_ozf_offr_qual_rec.created_by;
    END IF;

    -- last_update_date
    IF p_ozf_offr_qual_rec.last_update_date IS NULL THEN
       x_complete_rec.last_update_date := l_ozf_offr_qual_rec.last_update_date;
    END IF;

    -- last_updated_by
    IF p_ozf_offr_qual_rec.last_updated_by IS NULL THEN
       x_complete_rec.last_updated_by := l_ozf_offr_qual_rec.last_updated_by;
    END IF;

    -- last_update_login
    IF p_ozf_offr_qual_rec.last_update_login IS NULL THEN
       x_complete_rec.last_update_login := l_ozf_offr_qual_rec.last_update_login;
    END IF;

    -- qualifier_grouping_no
    IF p_ozf_offr_qual_rec.qualifier_grouping_no IS NULL THEN
       x_complete_rec.qualifier_grouping_no := l_ozf_offr_qual_rec.qualifier_grouping_no;
    END IF;

    -- qualifier_context
/*    IF p_ozf_offr_qual_rec.qualifier_context IS NULL THEN
       x_complete_rec.qualifier_context := l_ozf_offr_qual_rec.qualifier_context;
    END IF;
*/
    -- qualifier_attribute
    IF p_ozf_offr_qual_rec.qualifier_attribute IS NULL THEN
       x_complete_rec.qualifier_attribute := l_ozf_offr_qual_rec.qualifier_attribute;
    END IF;

    -- qualifier_attr_value
    IF p_ozf_offr_qual_rec.qualifier_attr_value IS NULL THEN
       x_complete_rec.qualifier_attr_value := l_ozf_offr_qual_rec.qualifier_attr_value;
    END IF;

    -- start_date_active
    IF p_ozf_offr_qual_rec.start_date_active IS NULL THEN
       x_complete_rec.start_date_active := l_ozf_offr_qual_rec.start_date_active;
    END IF;

    -- end_date_active
    IF p_ozf_offr_qual_rec.end_date_active IS NULL THEN
       x_complete_rec.end_date_active := l_ozf_offr_qual_rec.end_date_active;
    END IF;

    -- offer_id
    IF p_ozf_offr_qual_rec.offer_id IS NULL THEN
       x_complete_rec.offer_id := l_ozf_offr_qual_rec.offer_id;
    END IF;

    -- offer_discount_line_id
    IF p_ozf_offr_qual_rec.offer_discount_line_id IS NULL THEN
       x_complete_rec.offer_discount_line_id := l_ozf_offr_qual_rec.offer_discount_line_id;
    END IF;

    -- context
    IF p_ozf_offr_qual_rec.context IS NULL THEN
       x_complete_rec.context := l_ozf_offr_qual_rec.context;
    END IF;

    -- attribute1
    IF p_ozf_offr_qual_rec.attribute1 IS NULL THEN
       x_complete_rec.attribute1 := l_ozf_offr_qual_rec.attribute1;
    END IF;

    -- attribute2
    IF p_ozf_offr_qual_rec.attribute2 IS NULL THEN
       x_complete_rec.attribute2 := l_ozf_offr_qual_rec.attribute2;
    END IF;

    -- attribute3
    IF p_ozf_offr_qual_rec.attribute3 IS NULL THEN
       x_complete_rec.attribute3 := l_ozf_offr_qual_rec.attribute3;
    END IF;

    -- attribute4
    IF p_ozf_offr_qual_rec.attribute4 IS NULL THEN
       x_complete_rec.attribute4 := l_ozf_offr_qual_rec.attribute4;
    END IF;

    -- attribute5
    IF p_ozf_offr_qual_rec.attribute5 IS NULL THEN
       x_complete_rec.attribute5 := l_ozf_offr_qual_rec.attribute5;
    END IF;

    -- attribute6
    IF p_ozf_offr_qual_rec.attribute6 IS NULL THEN
       x_complete_rec.attribute6 := l_ozf_offr_qual_rec.attribute6;
    END IF;

    -- attribute7
    IF p_ozf_offr_qual_rec.attribute7 IS NULL THEN
       x_complete_rec.attribute7 := l_ozf_offr_qual_rec.attribute7;
    END IF;

    -- attribute8
    IF p_ozf_offr_qual_rec.attribute8 IS NULL THEN
       x_complete_rec.attribute8 := l_ozf_offr_qual_rec.attribute8;
    END IF;

    -- attribute9
    IF p_ozf_offr_qual_rec.attribute9 IS NULL THEN
       x_complete_rec.attribute9 := l_ozf_offr_qual_rec.attribute9;
    END IF;

    -- attribute10
    IF p_ozf_offr_qual_rec.attribute10 IS NULL THEN
       x_complete_rec.attribute10 := l_ozf_offr_qual_rec.attribute10;
    END IF;

    -- attribute11
    IF p_ozf_offr_qual_rec.attribute11 IS NULL THEN
       x_complete_rec.attribute11 := l_ozf_offr_qual_rec.attribute11;
    END IF;

    -- attribute12
    IF p_ozf_offr_qual_rec.attribute12 IS NULL THEN
       x_complete_rec.attribute12 := l_ozf_offr_qual_rec.attribute12;
    END IF;

    -- attribute13
    IF p_ozf_offr_qual_rec.attribute13 IS NULL THEN
       x_complete_rec.attribute13 := l_ozf_offr_qual_rec.attribute13;
    END IF;

    -- attribute14
    IF p_ozf_offr_qual_rec.attribute14 IS NULL THEN
       x_complete_rec.attribute14 := l_ozf_offr_qual_rec.attribute14;
    END IF;

    -- attribute15
    IF p_ozf_offr_qual_rec.attribute15 IS NULL THEN
       x_complete_rec.attribute15 := l_ozf_offr_qual_rec.attribute15;
    END IF;

    -- active_flag
    IF p_ozf_offr_qual_rec.active_flag IS NULL THEN
       x_complete_rec.active_flag := l_ozf_offr_qual_rec.active_flag;
    END IF;
    ozf_utility_pvt.debug_message('OfferId 3 is :'||p_ozf_offr_qual_rec.offer_id|| ' : '||l_ozf_offr_qual_rec.offer_id);

    ozf_utility_pvt.debug_message('Offer Id is '||l_ozf_offr_qual_rec.offer_id ||' : '||x_complete_rec.offer_id);
    -- Note: Developers need to modify the procedure
    -- to handle any business specific requirements.
 END Complete_ozf_offr_qual_Rec;




 PROCEDURE Default_Ozf_Offr_Qual_Items ( p_ozf_offr_qual_rec IN ozf_offr_qual_rec_type ,
                                 x_ozf_offr_qual_rec OUT NOCOPY ozf_offr_qual_rec_type )
 IS
    l_ozf_offr_qual_rec ozf_offr_qual_rec_type := p_ozf_offr_qual_rec;
 BEGIN
    -- Developers should put their code to default the record type
    -- e.g. IF p_campaign_rec.status_code IS NULL
    --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
    --         l_campaign_rec.status_code := 'NEW' ;
    --      END IF ;
    --
    IF  p_ozf_offr_qual_rec.active_flag = FND_API.G_MISS_CHAR OR p_ozf_offr_qual_rec.active_flag IS NULL THEN
        x_ozf_offr_qual_rec.active_flag := 'N';
    END IF;
    NULL ;
 END;




 PROCEDURE Validate_Offr_Qual(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
     p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
     p_ozf_offr_qual_rec               IN   ozf_offr_qual_rec_type,
     p_validation_mode            IN    VARCHAR2,
     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2
     )
  IS
 L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Offr_Qual';
 L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
 l_object_version_number     NUMBER;
 l_ozf_offr_qual_rec  ozf_offr_qual_rec_type;

  BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT validate_offr_qual_Pvt;


         -- Debug Message
       OZF_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

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
    l_ozf_offr_qual_rec := p_ozf_offr_qual_rec ;


            IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN

               Check_ozf_offr_qual_Items(
                  p_ozf_offr_qual_rec        => l_ozf_offr_qual_rec,
                  p_validation_mode   => p_validation_mode,
                  x_return_status     => x_return_status
               );

               IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                   RAISE FND_API.G_EXC_ERROR;
               ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                   RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
       END IF;



       IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
          Validate_ozf_offr_qual_Rec(
            p_api_version_number     => 1.0,
            p_init_msg_list          => FND_API.G_FALSE,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data,
            p_ozf_offr_qual_rec           =>    l_ozf_offr_qual_rec);

               IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
       END IF;

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
      ROLLBACK TO validate_offr_qual_Pvt;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO validate_offr_qual_Pvt;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO validate_offr_qual_Pvt;
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
 End Validate_Offr_Qual;


 PROCEDURE Validate_ozf_offr_qual_Rec (
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2,
     p_ozf_offr_qual_rec               IN    ozf_offr_qual_rec_type
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
 END Validate_ozf_offr_qual_Rec;

 END OZF_Offr_Qual_PVT;

/
