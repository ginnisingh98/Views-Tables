--------------------------------------------------------
--  DDL for Package Body AMS_APPR_HIST_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_APPR_HIST_PVT" as
/* $Header: amsvaphb.pls 115.1 2002/12/12 12:56:48 vmodur noship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Appr_Hist_PVT
-- Purpose
--
-- History
--
--    12-DEC-2002    VMODUR   Fixed GSCC Warning related to l_org_id
--
-- NOTE
--
-- This Api is generated with Latest version of
-- Rosetta, where g_miss indicates NULL and
-- NULL indicates missing value. Rosetta Version 1.55
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Appr_Hist_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvaphb.pls';

-- G_USER_ID         NUMBER := FND_GLOBAL.USER_ID;
-- G_LOGIN_ID        NUMBER := FND_GLOBAL.CONC_LOGIN_ID;
--
-- Foreward Procedure Declarations
--

PROCEDURE Default_Appr_Hist_Items (
   p_appr_hist_rec IN  appr_hist_rec_type ,
   x_appr_hist_rec OUT NOCOPY appr_hist_rec_type
) ;



-- Hint: Primary key needs to be returned.
--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Create_Appr_Hist
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
--       p_appr_hist_rec            IN   appr_hist_rec_type  Required
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

PROCEDURE Create_Appr_Hist(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_appr_hist_rec              IN   appr_hist_rec_type  := g_miss_appr_hist_rec
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Appr_Hist';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   -- l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_object_id                 NUMBER;
   l_dummy                     NUMBER;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT create_appr_hist_pvt;

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


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.USER_ID IS NULL
      THEN
         RAISE FND_API.G_EXC_ERROR;
      END IF;



      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN

          -- Invoke validation procedures
          Validate_appr_hist(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_appr_hist_rec  =>  p_appr_hist_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

          l_object_id := p_appr_hist_rec.object_id;

      -- Invoke table handler(Ams_Appr_Hist_Pkg.Insert_Row)
      Ams_Appr_Hist_Pkg.Insert_Row(
          p_object_id  => l_object_id,
          p_object_type_code  => p_appr_hist_rec.object_type_code,
          p_sequence_num  => p_appr_hist_rec.sequence_num,
          p_object_version_num  => p_appr_hist_rec.object_version_num,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_creation_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_action_code  => p_appr_hist_rec.action_code,
          p_action_date  => p_appr_hist_rec.action_date,
          p_approver_id  => p_appr_hist_rec.approver_id,
          p_approval_detail_id  => p_appr_hist_rec.approval_detail_id,
          p_note  => p_appr_hist_rec.note,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_approval_type  => p_appr_hist_rec.approval_type,
          p_approver_type  => p_appr_hist_rec.approver_type,
          p_custom_setup_id  => p_appr_hist_rec.custom_setup_id,
	  p_log_message => p_appr_hist_rec.log_message
);

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

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO CREATE_Appr_Hist_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Appr_Hist_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Appr_Hist_PVT;
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
End Create_Appr_Hist;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Update_Appr_Hist
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
--       p_appr_hist_rec           IN   appr_hist_rec_type  Required
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

PROCEDURE Update_Appr_Hist(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_appr_hist_rec               IN    appr_hist_rec_type
    )

 IS


CURSOR c_get_appr_hist IS
    SELECT *
    FROM  AMS_APPROVAL_HISTORY
    WHERE  object_id = p_appr_hist_rec.object_id
      AND  object_type_code = p_appr_hist_rec.object_type_code
      AND  approval_type = p_appr_hist_rec.approval_type
      AND  sequence_num = p_appr_hist_rec.sequence_num;
    -- Hint: Developer need to provide Where clause


L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Appr_Hist';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_num     NUMBER;
l_object_id    NUMBER;
l_ref_appr_hist_rec  c_get_Appr_Hist%ROWTYPE ;
l_tar_appr_hist_rec  appr_hist_rec_type := P_appr_hist_rec;
l_rowid  ROWID;

 BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT update_appr_hist_pvt;


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

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      OPEN c_get_Appr_Hist;

      FETCH c_get_Appr_Hist INTO l_ref_appr_hist_rec  ;

       IF ( c_get_Appr_Hist%NOTFOUND) THEN
          AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
                                        p_token_name   => 'INFO',
                                        p_token_value  => 'Appr_Hist') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       CLOSE c_get_Appr_Hist;

       -- This code is commented because we are note creating or updating objects
       -- the version number is really the version number of the campaign or event
       -- that was submitted for approval
       -- API gen thought it is the object_version_number used for pseudo locking
      /*
      If (l_tar_appr_hist_rec.object_version_num is NULL or
          l_tar_appr_hist_rec.object_version_num = FND_API.G_MISS_NUM ) Then
          AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
                                        p_token_name   => 'COLUMN',
                                        p_token_value  => 'Last_Update_Date') ;
                                        raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_appr_hist_rec.object_version_num <> l_ref_appr_hist_rec.object_version_num) Then
           AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
                                         p_token_name   => 'INFO',
                                         p_token_value  => 'Appr_Hist') ;
          raise FND_API.G_EXC_ERROR;
      End if;

      */
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN

          -- Invoke validation procedures
          Validate_appr_hist(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_appr_hist_rec  =>  p_appr_hist_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- Invoke table handler(Ams_Appr_Hist_Pkg.Update_Row)
      Ams_Appr_Hist_Pkg.Update_Row(
          p_object_id  => p_appr_hist_rec.object_id,
          p_object_type_code  => p_appr_hist_rec.object_type_code,
          p_sequence_num  => p_appr_hist_rec.sequence_num,
          p_object_version_num  => p_appr_hist_rec.object_version_num,
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_action_code  => p_appr_hist_rec.action_code,
          p_action_date  => p_appr_hist_rec.action_date,
          p_approver_id  => p_appr_hist_rec.approver_id,
          p_approval_detail_id  => p_appr_hist_rec.approval_detail_id,
          p_note  => p_appr_hist_rec.note,
          p_last_update_login  => FND_GLOBAL.conc_login_id,
          p_approval_type  => p_appr_hist_rec.approval_type,
          p_approver_type  => p_appr_hist_rec.approver_type,
          p_custom_setup_id  => p_appr_hist_rec.custom_setup_id,
	  p_log_message => p_appr_hist_rec.log_message);

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
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
     ROLLBACK TO UPDATE_Appr_Hist_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Appr_Hist_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Appr_Hist_PVT;
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
End Update_Appr_Hist;


--   ==============================================================================
--    Start of Comments
--   ==============================================================================
--   API Name
--           Delete_Appr_Hist
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
--       p_object_id               IN   NUMBER
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

PROCEDURE Delete_Appr_Hist(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_object_id                  IN   NUMBER,
    p_object_type_code           IN   VARCHAR2,
    p_sequence_num               IN   NUMBER,
    p_action_code                IN   VARCHAR2,
    p_object_version_num         IN   NUMBER,
    p_approval_type              IN   VARCHAR2
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Appr_Hist';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT delete_appr_hist_pvt;

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

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Invoke table handler(Ams_Appr_Hist_Pkg.Delete_Row)
      Ams_Appr_Hist_Pkg.Delete_Row(
          p_object_id  => p_object_id,
	  p_object_type_code => p_object_type_code,
	  p_sequence_num => p_sequence_num,
	  p_action_code => p_action_code,
	  p_object_version_num => p_object_version_num,
	  p_approval_type => p_approval_type);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;

       -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO DELETE_Appr_Hist_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Appr_Hist_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Appr_Hist_PVT;
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
End Delete_Appr_Hist;

PROCEDURE check_Appr_Hist_Uk_Items(
    p_appr_hist_rec              IN   appr_hist_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      /*
      IF p_validation_mode = JTF_PLSQL_API.g_create
      AND p_appr_hist_rec.object_id IS NOT NULL
      THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'ams_approval_history',
         'object_id = ''' || p_appr_hist_rec.object_id ||''''
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
         x_return_status := FND_API.g_ret_sts_error;
      END IF;
      */
END check_Appr_Hist_Uk_Items;



PROCEDURE check_Appr_Hist_Req_Items(
    p_appr_hist_rec               IN  appr_hist_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_appr_hist_rec.object_id = FND_API.G_MISS_NUM OR p_appr_hist_rec.object_id IS NULL THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_appr_hist_rec.object_type_code = FND_API.g_miss_char OR p_appr_hist_rec.object_type_code IS NULL THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_TYPE_CODE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_appr_hist_rec.sequence_num = FND_API.G_MISS_NUM OR p_appr_hist_rec.sequence_num IS NULL THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'SEQUENCE_NUM' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_appr_hist_rec.object_version_num = FND_API.G_MISS_NUM OR p_appr_hist_rec.object_version_num IS NULL THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUM' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


   ELSE


      IF p_appr_hist_rec.object_id = FND_API.G_MISS_NUM THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_ID' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_appr_hist_rec.object_type_code = FND_API.g_miss_char THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_TYPE_CODE' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_appr_hist_rec.sequence_num = FND_API.G_MISS_NUM THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'SEQUENCE_NUM' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;


      IF p_appr_hist_rec.object_version_num = FND_API.G_MISS_NUM THEN
               AMS_Utility_PVT.Error_Message('AMS_API_MISSING_FIELD', 'MISS_FIELD', 'OBJECT_VERSION_NUM' );
               x_return_status := FND_API.g_ret_sts_error;
      END IF;
   END IF;

END check_Appr_Hist_Req_Items;



PROCEDURE check_Appr_Hist_Fk_Items(
    p_appr_hist_rec IN appr_hist_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Appr_Hist_Fk_Items;



PROCEDURE check_Appr_Hist_Lookup_Items(
    p_appr_hist_rec IN appr_hist_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_Appr_Hist_Lookup_Items;



PROCEDURE Check_Appr_Hist_Items (
    P_appr_hist_rec     IN    appr_hist_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
   l_return_status   VARCHAR2(1);
BEGIN

    l_return_status := FND_API.g_ret_sts_success;
   -- Check Items Uniqueness API calls

   check_Appr_hist_Uk_Items(
      p_appr_hist_rec => p_appr_hist_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   -- Check Items Required/NOT NULL API calls

   check_appr_hist_req_items(
      p_appr_hist_rec => p_appr_hist_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Foreign Keys API calls

   check_appr_hist_FK_items(
      p_appr_hist_rec => p_appr_hist_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;
   -- Check Items Lookups

   check_appr_hist_Lookup_items(
      p_appr_hist_rec => p_appr_hist_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      l_return_status := FND_API.g_ret_sts_error;
   END IF;

   x_return_status := l_return_status;

END Check_appr_hist_Items;





PROCEDURE Complete_Appr_Hist_Rec (
   p_appr_hist_rec IN appr_hist_rec_type,
   x_complete_rec OUT NOCOPY appr_hist_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM ams_approval_history
      WHERE object_id = p_appr_hist_rec.object_id;
   l_appr_hist_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_appr_hist_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_appr_hist_rec;
   CLOSE c_complete;

   -- object_id
   IF p_appr_hist_rec.object_id IS NULL THEN
      x_complete_rec.object_id := l_appr_hist_rec.object_id;
   END IF;

   -- object_type_code
   IF p_appr_hist_rec.object_type_code IS NULL THEN
      x_complete_rec.object_type_code := l_appr_hist_rec.object_type_code;
   END IF;

   -- sequence_num
   IF p_appr_hist_rec.sequence_num IS NULL THEN
      x_complete_rec.sequence_num := l_appr_hist_rec.sequence_num;
   END IF;

   -- object_version_num
   IF p_appr_hist_rec.object_version_num IS NULL THEN
      x_complete_rec.object_version_num := l_appr_hist_rec.object_version_num;
   END IF;

   -- last_update_date
   IF p_appr_hist_rec.last_update_date IS NULL THEN
      x_complete_rec.last_update_date := l_appr_hist_rec.last_update_date;
   END IF;

   -- last_updated_by
   IF p_appr_hist_rec.last_updated_by IS NULL THEN
      x_complete_rec.last_updated_by := l_appr_hist_rec.last_updated_by;
   END IF;

   -- creation_date
   IF p_appr_hist_rec.creation_date IS NULL THEN
      x_complete_rec.creation_date := l_appr_hist_rec.creation_date;
   END IF;

   -- created_by
   IF p_appr_hist_rec.created_by IS NULL THEN
      x_complete_rec.created_by := l_appr_hist_rec.created_by;
   END IF;

   -- action_code
   IF p_appr_hist_rec.action_code IS NULL THEN
      x_complete_rec.action_code := l_appr_hist_rec.action_code;
   END IF;

   -- action_date
   IF p_appr_hist_rec.action_date IS NULL THEN
      x_complete_rec.action_date := l_appr_hist_rec.action_date;
   END IF;

   -- approver_id
   IF p_appr_hist_rec.approver_id IS NULL THEN
      x_complete_rec.approver_id := l_appr_hist_rec.approver_id;
   END IF;

   -- approval_detail_id
   IF p_appr_hist_rec.approval_detail_id IS NULL THEN
      x_complete_rec.approval_detail_id := l_appr_hist_rec.approval_detail_id;
   END IF;

   -- note
   IF p_appr_hist_rec.note IS NULL THEN
      x_complete_rec.note := l_appr_hist_rec.note;
   END IF;

   -- last_update_login
   IF p_appr_hist_rec.last_update_login IS NULL THEN
      x_complete_rec.last_update_login := l_appr_hist_rec.last_update_login;
   END IF;

   -- approval_type
   IF p_appr_hist_rec.approval_type IS NULL THEN
      x_complete_rec.approval_type := l_appr_hist_rec.approval_type;
   END IF;

   -- approver_type
   IF p_appr_hist_rec.approver_type IS NULL THEN
      x_complete_rec.approver_type := l_appr_hist_rec.approver_type;
   END IF;

   -- custom_setup_id
   IF p_appr_hist_rec.custom_setup_id IS NULL THEN
      x_complete_rec.custom_setup_id := l_appr_hist_rec.custom_setup_id;
   END IF;

   -- log_message
   IF p_appr_hist_rec.log_message IS NULL THEN
      x_complete_rec.log_message := l_appr_hist_rec.log_message;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_Appr_Hist_Rec;




PROCEDURE Default_Appr_Hist_Items ( p_appr_hist_rec IN appr_hist_rec_type ,
                                x_appr_hist_rec OUT NOCOPY appr_hist_rec_type )
IS
   l_appr_hist_rec appr_hist_rec_type := p_appr_hist_rec;
BEGIN
   -- Developers should put their code to default the record type
   -- e.g. IF p_campaign_rec.status_code IS NULL
   --      OR p_campaign_rec.status_code = FND_API.G_MISS_CHAR THEN
   --         l_campaign_rec.status_code := 'NEW' ;
   --      END IF ;
   --
   NULL ;
END;




PROCEDURE Validate_Appr_Hist(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_appr_hist_rec              IN   appr_hist_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Appr_Hist';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_appr_hist_rec  appr_hist_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT validate_appr_hist_;

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

              Check_appr_hist_Items(
                 p_appr_hist_rec        => p_appr_hist_rec,
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
         Default_Appr_Hist_Items (p_appr_hist_rec => p_appr_hist_rec ,
                                x_appr_hist_rec => l_appr_hist_rec) ;
      END IF ;


      Complete_appr_hist_Rec(
         p_appr_hist_rec        => l_appr_hist_rec,
         x_complete_rec        => l_appr_hist_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_appr_hist_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_appr_hist_rec           =>    l_appr_hist_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

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
     ROLLBACK TO VALIDATE_Appr_Hist_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Appr_Hist_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Appr_Hist_;
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
End Validate_Appr_Hist;


PROCEDURE Validate_Appr_Hist_Rec (
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_appr_hist_rec               IN    appr_hist_rec_type
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

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_appr_hist_Rec;

END AMS_Appr_Hist_PVT;

/
