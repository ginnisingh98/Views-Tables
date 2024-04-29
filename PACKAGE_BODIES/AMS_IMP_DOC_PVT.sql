--------------------------------------------------------
--  DDL for Package Body AMS_IMP_DOC_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_IMP_DOC_PVT" as
 /* $Header: amsvidob.pls 115.4 2002/11/14 22:03:28 jieli noship $ */
 -- ===============================================================
 -- Start of Comments
 -- Package name
 --          AMS_Imp_Doc_PVT
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


 G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Imp_Doc_PVT';
 G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvidob.pls';

 -- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
 -- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;

 -- Hint: Primary key needs to be returned.
 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Create_Imp_Doc
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
 --       p_imp_doc_rec            IN   imp_doc_rec_type  Required
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

 AMS_DEBUG_HIGH_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
AMS_DEBUG_LOW_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
AMS_DEBUG_MEDIUM_ON boolean := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

PROCEDURE Create_Imp_Doc(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
     p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
     p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2,

     p_imp_doc_rec              IN   imp_doc_rec_type  := g_miss_imp_doc_rec,
     x_imp_document_id              OUT NOCOPY  NUMBER
      )

  IS
 L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Imp_Doc';
 L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
    l_return_status_full        VARCHAR2(1);
    l_object_version_number     NUMBER := 1;
    l_org_id                    NUMBER := FND_API.G_MISS_NUM;
    l_imp_document_id              NUMBER;
    l_dummy                     NUMBER;

    CURSOR c_id IS
       SELECT ams_imp_documents_s.NEXTVAL
       FROM dual;

    CURSOR c_id_exists (l_id IN NUMBER) IS
       SELECT 1
       FROM AMS_IMP_DOCUMENTS
       WHERE imp_document_id = l_id;

 BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT create_imp_doc_pvt;

       -- Standard call to check for call compatibility.
       IF NOT FND_API.Compatible_API_Call ( l_api_version_number,
                                            p_api_version_number,
                                            l_api_name,
                                            G_PKG_NAME)
       THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
       END IF;

		--IF (AMS_DEBUG_HIGH_ON) THENAMS_UTILITY_PVT.debug_message( 'The header id is:' || p_imp_doc_rec.import_list_header_id );END IF;

       -- Initialize message list if p_init_msg_list is set to TRUE.
       IF FND_API.to_Boolean( p_init_msg_list )
       THEN
          FND_MSG_PUB.initialize;
       END IF;



       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start and the header id:'
			|| p_imp_doc_rec.import_list_header_id);
       END IF;



       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Local variable initialization

    IF p_imp_doc_rec.imp_document_id IS NULL OR p_imp_doc_rec.imp_document_id = FND_API.g_miss_num THEN
       LOOP
          l_dummy := NULL;
          OPEN c_id;
          FETCH c_id INTO l_imp_document_id;
          CLOSE c_id;

          OPEN c_id_exists(l_imp_document_id);
          FETCH c_id_exists INTO l_dummy;
          CLOSE c_id_exists;
          EXIT WHEN l_dummy IS NULL;
       END LOOP;
    ELSE
          l_imp_document_id := p_imp_doc_rec.imp_document_id;
    END IF;

       -- =========================================================================
       -- Validate Environment
       -- =========================================================================

       IF FND_GLOBAL.USER_ID IS NULL
       THEN
          AMS_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
           RAISE FND_API.G_EXC_ERROR;
       END IF;



       IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
       THEN
           -- Debug message
           IF (AMS_DEBUG_HIGH_ON) THEN

           AMS_UTILITY_PVT.debug_message('Private API: Validate_Imp_Doc');
           END IF;

           -- Invoke validation procedures
           --Validate_imp_doc(
           --p_api_version_number     => 1.0,
           --  p_init_msg_list    => FND_API.G_FALSE,
           --  p_validation_level => p_validation_level,
           --  p_validation_mode => JTF_PLSQL_API.g_create,
           --  p_imp_doc_rec  =>  p_imp_doc_rec,
           --  x_return_status    => x_return_status,
           -- x_msg_count        => x_msg_count,
           --  x_msg_data         => x_msg_data);
			  NULL;
       END IF;

       IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
       END IF;


       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler and the id:'
			|| p_imp_doc_rec.import_list_header_id);
       END IF;

       -- Invoke table handler(Ams_Imp_Doc_Pkg.Insert_Row)
       Ams_Imp_Doc_Pkg.Insert_Row(
           px_imp_document_id  => l_imp_document_id,
           p_last_updated_by  => FND_GLOBAL.USER_ID,
           px_object_version_number  => l_object_version_number,
           p_created_by  => FND_GLOBAL.USER_ID,
           p_last_update_login  => FND_GLOBAL.conc_login_id,
           p_last_update_date  => SYSDATE,
           p_creation_date  => SYSDATE,
           p_import_list_header_id  => p_imp_doc_rec.import_list_header_id,
           --p_content_text  => p_imp_doc_rec.content_text,
           --p_dtd_text  => p_imp_doc_rec.dtd_text,
           p_file_type  => p_imp_doc_rec.file_type,
           --p_filter_content_text  => p_imp_doc_rec.filter_content_text,
           p_file_size  => p_imp_doc_rec.file_size
 );

           x_imp_document_id := l_imp_document_id;
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
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
       END IF;


       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
         (p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
       );
 EXCEPTION

    WHEN AMS_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
          AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO CREATE_Imp_Doc_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO CREATE_Imp_Doc_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO CREATE_Imp_Doc_PVT;
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
 End Create_Imp_Doc;


 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Update_Imp_Doc
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
 --       p_imp_doc_rec            IN   imp_doc_rec_type  Required
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

 PROCEDURE Update_Imp_Doc(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
     p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
     p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2,

     p_imp_doc_rec               IN    imp_doc_rec_type,
     x_object_version_number      OUT NOCOPY  NUMBER
     )

  IS


 CURSOR c_get_imp_doc(imp_document_id NUMBER) IS
     SELECT *
     FROM  AMS_IMP_DOCUMENTS
     WHERE  imp_document_id = p_imp_doc_rec.imp_document_id;
     -- Hint: Developer need to provide Where clause


 L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Imp_Doc';
 L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
 -- Local Variables
 l_object_version_number     NUMBER;
 l_imp_document_id    NUMBER;
 l_ref_imp_doc_rec  c_get_Imp_Doc%ROWTYPE ;
 l_tar_imp_doc_rec  imp_doc_rec_type := P_imp_doc_rec;
 l_rowid  ROWID;

  BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT update_imp_doc_pvt;

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
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
       END IF;



       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');
       END IF;

       OPEN c_get_Imp_Doc( l_tar_imp_doc_rec.imp_document_id);

       FETCH c_get_Imp_Doc INTO l_ref_imp_doc_rec  ;

        If ( c_get_Imp_Doc%NOTFOUND) THEN
   AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
    p_token_name   => 'INFO',
  p_token_value  => 'Imp_Doc') ;
            RAISE FND_API.G_EXC_ERROR;
        END IF;
        -- Debug Message
        IF (AMS_DEBUG_HIGH_ON) THEN

        AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
        END IF;
        CLOSE     c_get_Imp_Doc;


       If (l_tar_imp_doc_rec.object_version_number is NULL or
           l_tar_imp_doc_rec.object_version_number = FND_API.G_MISS_NUM ) Then
   AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
    p_token_name   => 'COLUMN',
  p_token_value  => 'Last_Update_Date') ;
           raise FND_API.G_EXC_ERROR;
       End if;
       -- Check Whether record has been changed by someone else
       If (l_tar_imp_doc_rec.object_version_number <> l_ref_imp_doc_rec.object_version_number) Then
   AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
    p_token_name   => 'INFO',
  p_token_value  => 'Imp_Doc') ;
           raise FND_API.G_EXC_ERROR;
       End if;


       IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
       THEN
           -- Debug message
           IF (AMS_DEBUG_HIGH_ON) THEN

           AMS_UTILITY_PVT.debug_message('Private API: Validate_Imp_Doc');
           END IF;

           -- Invoke validation procedures
           Validate_imp_doc(
             p_api_version_number     => 1.0,
             p_init_msg_list    => FND_API.G_FALSE,
             p_validation_level => p_validation_level,
             p_validation_mode => JTF_PLSQL_API.g_update,
             p_imp_doc_rec  =>  p_imp_doc_rec,
             x_return_status    => x_return_status,
             x_msg_count        => x_msg_count,
             x_msg_data         => x_msg_data);
       END IF;

       IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
           RAISE FND_API.G_EXC_ERROR;
       END IF;


       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'Private API: Calling update table handler');
       END IF;

       -- Invoke table handler(Ams_Imp_Doc_Pkg.Update_Row)
       Ams_Imp_Doc_Pkg.Update_Row(
           p_imp_document_id  => p_imp_doc_rec.imp_document_id,
           p_last_updated_by  => FND_GLOBAL.USER_ID,
           px_object_version_number  => l_object_version_number,
           p_last_update_login  => FND_GLOBAL.conc_login_id,
           p_last_update_date  => SYSDATE,
           p_import_list_header_id  => p_imp_doc_rec.import_list_header_id,
           --p_content_text  => p_imp_doc_rec.content_text,
           --p_dtd_text  => p_imp_doc_rec.dtd_text,
           p_file_type  => p_imp_doc_rec.file_type,
           --p_filter_content_text  => p_imp_doc_rec.filter_content_text,
           p_file_size  => p_imp_doc_rec.file_size
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
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
       END IF;


       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
         (p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
       );
 EXCEPTION

    WHEN AMS_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
          AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO UPDATE_Imp_Doc_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO UPDATE_Imp_Doc_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO UPDATE_Imp_Doc_PVT;
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
 End Update_Imp_Doc;


 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Delete_Imp_Doc
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
 --       p_imp_document_id                IN   NUMBER
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

 PROCEDURE Delete_Imp_Doc(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
     p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
     p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2,
     p_imp_document_id                   IN  NUMBER,
     p_object_version_number      IN   NUMBER
     )

  IS
 L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Imp_Doc';
 L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
 l_object_version_number     NUMBER;

  BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT delete_imp_doc_pvt;

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
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
       END IF;



       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;

       --
       -- Api body
       --
       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');
       END IF;

       -- Invoke table handler(Ams_Imp_Doc_Pkg.Delete_Row)
       Ams_Imp_Doc_Pkg.Delete_Row(
           p_imp_document_id  => p_imp_document_id,
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
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
       END IF;


       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
         (p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
       );
 EXCEPTION

    WHEN AMS_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
          AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO DELETE_Imp_Doc_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO DELETE_Imp_Doc_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO DELETE_Imp_Doc_PVT;
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
 End Delete_Imp_Doc;



 -- Hint: Primary key needs to be returned.
 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           Lock_Imp_Doc
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
 --       p_imp_doc_rec            IN   imp_doc_rec_type  Required
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

 PROCEDURE Lock_Imp_Doc(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2,

     p_imp_document_id                   IN  NUMBER,
     p_object_version             IN  NUMBER
     )

  IS
 L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Imp_Doc';
 L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
 L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
 l_imp_document_id                  NUMBER;

 CURSOR c_imp_doc IS
    SELECT imp_document_id
    FROM ams_imp_documents
    WHERE imp_document_id = p_imp_document_id
    AND object_version_number = p_object_version
    FOR UPDATE NOWAIT;

 BEGIN

       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
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

   IF (AMS_DEBUG_HIGH_ON) THEN



   AMS_Utility_PVT.debug_message(l_full_name||': start');

   END IF;
   OPEN c_imp_doc;

   FETCH c_imp_doc INTO l_imp_document_id;

   IF (c_imp_doc%NOTFOUND) THEN
     CLOSE c_imp_doc;
     IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
        FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
        FND_MSG_PUB.add;
     END IF;
     RAISE FND_API.g_exc_error;
   END IF;

   CLOSE c_imp_doc;

  -------------------- finish --------------------------
   FND_MSG_PUB.count_and_get(
     p_encoded => FND_API.g_false,
     p_count   => x_msg_count,
     p_data    => x_msg_data);
   IF (AMS_DEBUG_HIGH_ON) THEN

   AMS_Utility_PVT.debug_message(l_full_name ||': end');
   END IF;
 EXCEPTION

    WHEN AMS_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
          AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO LOCK_Imp_Doc_PVT;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO LOCK_Imp_Doc_PVT;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO LOCK_Imp_Doc_PVT;
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
 End Lock_Imp_Doc;


 --   ==============================================================================
 --    Start of Comments
 --   ==============================================================================
 --   API Name
 --           add_language
 --   Type
 --           Private
 --   History
 --
 --   NOTE
 --
 -- End of Comments
 -- ===============================================================



 PROCEDURE check_Imp_Doc_Uk_Items(
     p_imp_doc_rec               IN   imp_doc_rec_type,
     p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
     x_return_status              OUT NOCOPY VARCHAR2)
 IS
 l_valid_flag  VARCHAR2(1);

 BEGIN
       x_return_status := FND_API.g_ret_sts_success;
       IF p_validation_mode = JTF_PLSQL_API.g_create THEN
          l_valid_flag := AMS_Utility_PVT.check_uniqueness(
          'ams_imp_documents',
          'imp_document_id = ''' || p_imp_doc_rec.imp_document_id ||''''
          );
       ELSE
          l_valid_flag := AMS_Utility_PVT.check_uniqueness(
          'ams_imp_documents',
          'imp_document_id = ''' || p_imp_doc_rec.imp_document_id ||
          ''' AND imp_document_id <> ' || p_imp_doc_rec.imp_document_id
          );
       END IF;

       IF l_valid_flag = FND_API.g_false THEN
          AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_imp_document_id_DUPLICATE');
          x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;

 END check_Imp_Doc_Uk_Items;



 PROCEDURE check_Imp_Doc_Req_Items(
     p_imp_doc_rec               IN  imp_doc_rec_type,
     p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
     x_return_status              OUT NOCOPY VARCHAR2
 )
 IS
 BEGIN
    x_return_status := FND_API.g_ret_sts_success;

    IF p_validation_mode = JTF_PLSQL_API.g_create THEN


       IF p_imp_doc_rec.imp_document_id = FND_API.G_MISS_NUM OR p_imp_doc_rec.imp_document_id IS NULL THEN
                AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_MISSING_FIELD');
                FND_MESSAGE.set_token('MISS_FIELD', 'IMP_DOCUMENT_ID' );
                x_return_status := FND_API.g_ret_sts_error;
       END IF;


       IF p_imp_doc_rec.last_updated_by = FND_API.G_MISS_NUM OR p_imp_doc_rec.last_updated_by IS NULL THEN
                AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_MISSING_FIELD');
                FND_MESSAGE.set_token('MISS_FIELD', 'LAST_UPDATED_BY' );
                x_return_status := FND_API.g_ret_sts_error;
       END IF;


       IF p_imp_doc_rec.created_by = FND_API.G_MISS_NUM OR p_imp_doc_rec.created_by IS NULL THEN
                AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_MISSING_FIELD');
                FND_MESSAGE.set_token('MISS_FIELD', 'CREATED_BY' );
                x_return_status := FND_API.g_ret_sts_error;
       END IF;


       IF p_imp_doc_rec.last_update_login = FND_API.G_MISS_NUM OR p_imp_doc_rec.last_update_login IS NULL THEN
                AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_MISSING_FIELD');
                FND_MESSAGE.set_token('MISS_FIELD', 'LAST_UPDATE_LOGIN' );
                x_return_status := FND_API.g_ret_sts_error;
       END IF;


       IF p_imp_doc_rec.last_update_date = FND_API.G_MISS_DATE OR p_imp_doc_rec.last_update_date IS NULL THEN
                AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_MISSING_FIELD');
                FND_MESSAGE.set_token('MISS_FIELD', 'LAST_UPDATE_DATE' );
                x_return_status := FND_API.g_ret_sts_error;
       END IF;


       IF p_imp_doc_rec.creation_date = FND_API.G_MISS_DATE OR p_imp_doc_rec.creation_date IS NULL THEN
                AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_MISSING_FIELD');
                FND_MESSAGE.set_token('MISS_FIELD', 'CREATION_DATE' );
                x_return_status := FND_API.g_ret_sts_error;
       END IF;


       IF p_imp_doc_rec.import_list_header_id = FND_API.G_MISS_NUM OR p_imp_doc_rec.import_list_header_id IS NULL THEN
                AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_MISSING_FIELD');
                FND_MESSAGE.set_token('MISS_FIELD', 'IMPORT_LIST_HEADER_ID' );
                x_return_status := FND_API.g_ret_sts_error;
       END IF;


    ELSE


       IF p_imp_doc_rec.imp_document_id = FND_API.G_MISS_NUM THEN
                AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_MISSING_FIELD');
                FND_MESSAGE.set_token('MISS_FIELD', 'IMP_DOCUMENT_ID' );
                x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


       IF p_imp_doc_rec.last_updated_by = FND_API.G_MISS_NUM THEN
                AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_MISSING_FIELD');
                FND_MESSAGE.set_token('MISS_FIELD', 'LAST_UPDATED_BY' );
                x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


       IF p_imp_doc_rec.created_by = FND_API.G_MISS_NUM THEN
                AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_MISSING_FIELD');
                FND_MESSAGE.set_token('MISS_FIELD', 'CREATED_BY' );
                x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


       IF p_imp_doc_rec.last_update_login = FND_API.G_MISS_NUM THEN
                AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_MISSING_FIELD');
                FND_MESSAGE.set_token('MISS_FIELD', 'LAST_UPDATE_LOGIN' );
                x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


       IF p_imp_doc_rec.last_update_date = FND_API.G_MISS_DATE THEN
                AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_MISSING_FIELD');
                FND_MESSAGE.set_token('MISS_FIELD', 'LAST_UPDATE_DATE' );
                x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


       IF p_imp_doc_rec.creation_date = FND_API.G_MISS_DATE THEN
                AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_MISSING_FIELD');
                FND_MESSAGE.set_token('MISS_FIELD', 'CREATION_DATE' );
                x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;


       IF p_imp_doc_rec.import_list_header_id = FND_API.G_MISS_NUM THEN
                AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_MISSING_FIELD');
                FND_MESSAGE.set_token('MISS_FIELD', 'IMPORT_LIST_HEADER_ID' );
                x_return_status := FND_API.g_ret_sts_error;
          RETURN;
       END IF;
    END IF;

 END check_Imp_Doc_Req_Items;



 PROCEDURE check_Imp_Doc_Fk_Items(
     p_imp_doc_rec IN imp_doc_rec_type,
     x_return_status OUT NOCOPY VARCHAR2
 )
 IS
 BEGIN
    x_return_status := FND_API.g_ret_sts_success;

    -- Enter custom code here

 END check_Imp_Doc_Fk_Items;



 PROCEDURE check_Imp_Doc_Lookup_Items(
     p_imp_doc_rec IN imp_doc_rec_type,
     x_return_status OUT NOCOPY VARCHAR2
 )
 IS
 BEGIN
    x_return_status := FND_API.g_ret_sts_success;

    -- Enter custom code here

 END check_Imp_Doc_Lookup_Items;



 PROCEDURE Check_Imp_Doc_Items (
     P_imp_doc_rec     IN    imp_doc_rec_type,
     p_validation_mode  IN    VARCHAR2,
     x_return_status    OUT NOCOPY   VARCHAR2
     )
 IS
 BEGIN

    -- Check Items Uniqueness API calls

    check_Imp_doc_Uk_Items(
       p_imp_doc_rec => p_imp_doc_rec,
       p_validation_mode => p_validation_mode,
       x_return_status => x_return_status);
    IF x_return_status <> FND_API.g_ret_sts_success THEN
       RETURN;
    END IF;

    -- Check Items Required/NOT NULL API calls

    check_imp_doc_req_items(
       p_imp_doc_rec => p_imp_doc_rec,
       p_validation_mode => p_validation_mode,
       x_return_status => x_return_status);
    IF x_return_status <> FND_API.g_ret_sts_success THEN
       RETURN;
    END IF;
    -- Check Items Foreign Keys API calls

    check_imp_doc_FK_items(
       p_imp_doc_rec => p_imp_doc_rec,
       x_return_status => x_return_status);
    IF x_return_status <> FND_API.g_ret_sts_success THEN
       RETURN;
    END IF;
    -- Check Items Lookups

    check_imp_doc_Lookup_items(
       p_imp_doc_rec => p_imp_doc_rec,
       x_return_status => x_return_status);
    IF x_return_status <> FND_API.g_ret_sts_success THEN
       RETURN;
    END IF;

 END Check_imp_doc_Items;





 PROCEDURE Complete_Imp_Doc_Rec (
    p_imp_doc_rec IN imp_doc_rec_type,
    x_complete_rec OUT NOCOPY imp_doc_rec_type)
 IS
    l_return_status  VARCHAR2(1);

    CURSOR c_complete IS
       SELECT *
       FROM ams_imp_documents
       WHERE imp_document_id = p_imp_doc_rec.imp_document_id;
    l_imp_doc_rec c_complete%ROWTYPE;
 BEGIN
    x_complete_rec := p_imp_doc_rec;


    OPEN c_complete;
    FETCH c_complete INTO l_imp_doc_rec;
    CLOSE c_complete;

    -- imp_document_id
    IF p_imp_doc_rec.imp_document_id IS NULL THEN
       x_complete_rec.imp_document_id := l_imp_doc_rec.imp_document_id;
    END IF;

    -- imp_document_id
    IF p_imp_doc_rec.imp_document_id IS NULL THEN
       x_complete_rec.imp_document_id := l_imp_doc_rec.imp_document_id;
    END IF;

    -- last_updated_by
    IF p_imp_doc_rec.last_updated_by IS NULL THEN
       x_complete_rec.last_updated_by := l_imp_doc_rec.last_updated_by;
    END IF;

    -- last_update_date
    IF p_imp_doc_rec.last_update_date IS NULL THEN
       x_complete_rec.last_update_date := l_imp_doc_rec.last_update_date;
    END IF;

    -- object_version_number
    IF p_imp_doc_rec.object_version_number IS NULL THEN
       x_complete_rec.object_version_number := l_imp_doc_rec.object_version_number;
    END IF;

    -- last_update_by
    --IF p_imp_doc_rec.last_update_by IS NULL THEN
    --   x_complete_rec.last_update_by := l_imp_doc_rec.last_update_by;
    --END IF;

    -- created_by
    IF p_imp_doc_rec.created_by IS NULL THEN
       x_complete_rec.created_by := l_imp_doc_rec.created_by;
    END IF;

    -- creation_date
    IF p_imp_doc_rec.creation_date IS NULL THEN
       x_complete_rec.creation_date := l_imp_doc_rec.creation_date;
    END IF;

    -- last_update_login
    IF p_imp_doc_rec.last_update_login IS NULL THEN
       x_complete_rec.last_update_login := l_imp_doc_rec.last_update_login;
    END IF;

    -- created_by
    IF p_imp_doc_rec.created_by IS NULL THEN
       x_complete_rec.created_by := l_imp_doc_rec.created_by;
    END IF;

    -- last_update_date
    IF p_imp_doc_rec.last_update_date IS NULL THEN
       x_complete_rec.last_update_date := l_imp_doc_rec.last_update_date;
    END IF;

    -- last_update_login
    IF p_imp_doc_rec.last_update_login IS NULL THEN
       x_complete_rec.last_update_login := l_imp_doc_rec.last_update_login;
    END IF;

    -- creation_date
    IF p_imp_doc_rec.creation_date IS NULL THEN
       x_complete_rec.creation_date := l_imp_doc_rec.creation_date;
    END IF;

    -- object_version_number
    IF p_imp_doc_rec.object_version_number IS NULL THEN
       x_complete_rec.object_version_number := l_imp_doc_rec.object_version_number;
    END IF;

    -- import_list_header_id
    IF p_imp_doc_rec.import_list_header_id IS NULL THEN
       x_complete_rec.import_list_header_id := l_imp_doc_rec.import_list_header_id;
    END IF;

    -- import_list_header_id
    IF p_imp_doc_rec.import_list_header_id IS NULL THEN
       x_complete_rec.import_list_header_id := l_imp_doc_rec.import_list_header_id;
    END IF;

    -- content_text
    --IF p_imp_doc_rec.content_text IS NULL THEN
    --   x_complete_rec.content_text := l_imp_doc_rec.content_text;
    --END IF;

    -- content_text
    --IF p_imp_doc_rec.content_text IS NULL THEN
    --   x_complete_rec.content_text := l_imp_doc_rec.content_text;
    --END IF;

    -- dtd_text
    --IF p_imp_doc_rec.dtd_text IS NULL THEN
    --   x_complete_rec.dtd_text := l_imp_doc_rec.dtd_text;
    --END IF;

    -- dtd_text
    --IF p_imp_doc_rec.dtd_text IS NULL THEN
    --   x_complete_rec.dtd_text := l_imp_doc_rec.dtd_text;
    --END IF;

    -- file_type
    IF p_imp_doc_rec.file_type IS NULL THEN
       x_complete_rec.file_type := l_imp_doc_rec.file_type;
    END IF;

    -- filter_content_text
    --IF p_imp_doc_rec.filter_content_text IS NULL THEN
    --  x_complete_rec.filter_content_text := l_imp_doc_rec.filter_content_text;
    --END IF;

    -- filter_content_text
    --IF p_imp_doc_rec.filter_content_text IS NULL THEN
    --   x_complete_rec.filter_content_text := l_imp_doc_rec.filter_content_text;
    --END IF;

    -- file_type
    IF p_imp_doc_rec.file_type IS NULL THEN
       x_complete_rec.file_type := l_imp_doc_rec.file_type;
    END IF;

    -- file_size
    IF p_imp_doc_rec.file_size IS NULL THEN
       x_complete_rec.file_size := l_imp_doc_rec.file_size;
    END IF;

    -- file_size
    IF p_imp_doc_rec.file_size IS NULL THEN
       x_complete_rec.file_size := l_imp_doc_rec.file_size;
    END IF;

    -- last_updated_by
    IF p_imp_doc_rec.last_updated_by IS NULL THEN
       x_complete_rec.last_updated_by := l_imp_doc_rec.last_updated_by;
    END IF;
    -- Note: Developers need to modify the procedure
    -- to handle any business specific requirements.
 END Complete_Imp_Doc_Rec;




 PROCEDURE Default_Item_Attribute ( p_imp_doc_rec IN imp_doc_rec_type ,
                                 x_imp_doc_rec OUT NOCOPY imp_doc_rec_type )
 IS
    l_imp_doc_rec imp_doc_rec_type := p_imp_doc_rec;
 BEGIN
    -- Developers should put their code to default the record type
    -- e.g. IF p_campaign_rec.status_code IS NULL
    --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
    --         l_campaign_rec.status_code := 'NEW' ;
    --      END IF ;
    --
    NULL ;
 END;




 PROCEDURE Validate_Imp_Doc(
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
     p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
     p_imp_doc_rec               IN   imp_doc_rec_type,
     p_validation_mode            IN    VARCHAR2,
     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2
     )
  IS
 L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Imp_Doc';
 L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
 l_object_version_number     NUMBER;
 l_imp_doc_rec  imp_doc_rec_type;

  BEGIN
       -- Standard Start of API savepoint
       SAVEPOINT validate_imp_doc_;

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
               Check_imp_doc_Items(
                  p_imp_doc_rec        => p_imp_doc_rec,
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
          Default_Item_Attribute(p_imp_doc_rec => p_imp_doc_rec ,
                                 x_imp_doc_rec => l_imp_doc_rec) ;
       END IF ;


       Complete_imp_doc_Rec(
          p_imp_doc_rec        => p_imp_doc_rec,
          x_complete_rec        => l_imp_doc_rec
       );

       IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
          Validate_imp_doc_Rec(
            p_api_version_number     => 1.0,
            p_init_msg_list          => FND_API.G_FALSE,
            x_return_status          => x_return_status,
            x_msg_count              => x_msg_count,
            x_msg_data               => x_msg_data,
            p_imp_doc_rec           =>    l_imp_doc_rec);

               IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
               ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
               END IF;
       END IF;


       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');
       END IF;



       -- Initialize API return status to SUCCESS
       x_return_status := FND_API.G_RET_STS_SUCCESS;


       -- Debug Message
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');
       END IF;


       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
         (p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
       );
 EXCEPTION

    WHEN AMS_Utility_PVT.resource_locked THEN
      x_return_status := FND_API.g_ret_sts_error;
          AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO VALIDATE_Imp_Doc_;
      x_return_status := FND_API.G_RET_STS_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count   => x_msg_count,
             p_data    => x_msg_data
      );

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
      ROLLBACK TO VALIDATE_Imp_Doc_;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      -- Standard call to get message count and if count=1, get the message
      FND_MSG_PUB.Count_And_Get (
             p_encoded => FND_API.G_FALSE,
             p_count => x_msg_count,
             p_data  => x_msg_data
      );

    WHEN OTHERS THEN
      ROLLBACK TO VALIDATE_Imp_Doc_;
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
 End Validate_Imp_Doc;


 PROCEDURE Validate_Imp_Doc_Rec (
     p_api_version_number         IN   NUMBER,
     p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
     x_return_status              OUT NOCOPY  VARCHAR2,
     x_msg_count                  OUT NOCOPY  NUMBER,
     x_msg_data                   OUT NOCOPY  VARCHAR2,
     p_imp_doc_rec               IN    imp_doc_rec_type
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
       IF (AMS_DEBUG_HIGH_ON) THEN

       AMS_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
       END IF;
       -- Standard call to get message count and if count is 1, get message info.
       FND_MSG_PUB.Count_And_Get
         (p_count          =>   x_msg_count,
          p_data           =>   x_msg_data
       );
 END Validate_imp_doc_Rec;



END AMS_Imp_Doc_PVT;

/
