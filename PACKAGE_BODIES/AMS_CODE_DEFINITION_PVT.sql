--------------------------------------------------------
--  DDL for Package Body AMS_CODE_DEFINITION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AMS_CODE_DEFINITION_PVT" as
/* $Header: amsvcdnb.pls 120.1 2005/06/27 05:41:11 appldev ship $ */
-- ===============================================================
-- Start of Comments
-- Package name
--          AMS_Code_Definition_PVT
-- Purpose
--
-- History
--
-- NOTE
--
-- End of Comments
-- ===============================================================


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AMS_Code_Definition_PVT';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'amsvcdnb.pls';

-- Hint: Primary key needs to be returned.
PROCEDURE Create_Code_Definition(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_code_def_rec               IN   code_def_rec_type  := g_miss_code_def_rec,
    x_code_definition_id         OUT NOCOPY  NUMBER
     )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Create_Code_Definition';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
   l_return_status_full        VARCHAR2(1);
   l_object_version_number     NUMBER := 1;
   l_org_id                    NUMBER := FND_API.G_MISS_NUM;
   l_CODE_DEFINITION_ID                  NUMBER;
   l_dummy       NUMBER;


   CURSOR c_id IS
      SELECT BIM_R_CODE_DEFINITIONS_s.NEXTVAL
      FROM dual;

   CURSOR c_id_exists (l_id IN NUMBER) IS
      SELECT 1
      FROM BIM_R_CODE_DEFINITIONS
      WHERE CODE_DEFINITION_ID = l_id
     ;

   CURSOR c_col_name(l_colName IN VARCHAR2, l_obj_type IN VARCHAR2)IS
      SELECT count(*)
      FROM BIM_R_CODE_DEFINITIONS
      WHERE column_name = l_colName
      AND column_name<>'Z'
      AND object_type = l_obj_type
      ;

BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT CREATE_Code_Definition_PVT;

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
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   -- Local variable initialization

   IF p_code_def_rec.CODE_DEFINITION_ID IS NULL OR p_code_def_rec.CODE_DEFINITION_ID = FND_API.g_miss_num THEN
      LOOP
         l_dummy := NULL;
         OPEN c_id;
         FETCH c_id INTO l_CODE_DEFINITION_ID;
         CLOSE c_id;

         OPEN c_id_exists(l_CODE_DEFINITION_ID);
         FETCH c_id_exists INTO l_dummy;
         CLOSE c_id_exists;
         EXIT WHEN l_dummy IS NULL;
   --ELSE
        -- p_code_def_rec.code_definition_id := l_code_definition_id;
      END LOOP;
   END IF;

      -- =========================================================================
      -- Validate Environment
      -- =========================================================================

      IF FND_GLOBAL.User_Id IS NULL
      THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'USER_PROFILE_MISSING');
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          AMS_UTILITY_PVT.debug_message('Private API: Validate_Code_Definition');

          -- Invoke validation procedures
          Validate_code_definition(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_create,
            p_code_def_rec  =>  p_code_def_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF p_code_def_rec.object_def IS NULL OR p_code_def_rec.object_def = FND_API.g_miss_char THEN
	   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
              FND_MESSAGE.set_name('AMS', 'AMS_OBJECT_TYPE_MISSING');
	      FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.g_exc_error;
      END IF;

       OPEN c_col_name(p_code_def_rec.column_name,p_code_def_rec.object_type);
         FETCH c_col_name INTO l_dummy;
       CLOSE c_col_name;

        IF (l_dummy >0) THEN
	   IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
              FND_MESSAGE.set_name('AMS', 'AMS_DUPLICATE_COLUMN_NAME');
	      FND_MSG_PUB.add;
          END IF;
          RAISE FND_API.g_exc_error;
        END IF;
        -- Debug Message
      AMS_UTILITY_PVT.debug_message( 'Private API: Calling create table handler');

      -- Invoke table handler(AMS_R_CODE_DEFINITIONS_PKG.Insert_Row)
      AMS_R_CODE_DEFINITIONS_PKG.Insert_Row(
          p_creation_date  => SYSDATE,
          p_last_update_date  => SYSDATE,
          p_created_by  => FND_GLOBAL.USER_ID,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          p_object_type  => p_code_def_rec.object_type,
          p_column_name  => p_code_def_rec.column_name,
          p_object_def  => p_code_def_rec.object_def,
          px_code_definition_id  => l_code_definition_id,
          px_object_version_number  => l_object_version_number);
          x_code_definition_id := l_code_definition_id;
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
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

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
     ROLLBACK TO CREATE_Code_Definition_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO CREATE_Code_Definition_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO CREATE_Code_Definition_PVT;
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
End Create_Code_Definition;

PROCEDURE Complete_code_def_Rec (
   p_code_def_rec IN code_def_rec_type,
   x_complete_rec OUT NOCOPY code_def_rec_type)
IS
   l_return_status  VARCHAR2(1);

   CURSOR c_complete IS
      SELECT *
      FROM bim_r_code_definitions
      WHERE code_definition_id = p_code_def_rec.code_definition_id;
   l_code_def_rec c_complete%ROWTYPE;
BEGIN
   x_complete_rec := p_code_def_rec;


   OPEN c_complete;
   FETCH c_complete INTO l_code_def_rec;
   CLOSE c_complete;

   -- creation_date
   IF p_code_def_rec.creation_date = FND_API.g_miss_date THEN
      x_complete_rec.creation_date := l_code_def_rec.creation_date;
   END IF;

   -- last_update_date
   IF p_code_def_rec.last_update_date = FND_API.g_miss_date THEN
      x_complete_rec.last_update_date := l_code_def_rec.last_update_date;
   END IF;

   -- created_by
   IF p_code_def_rec.created_by = FND_API.g_miss_num THEN
      x_complete_rec.created_by := l_code_def_rec.created_by;
   END IF;

   -- last_updated_by
   IF p_code_def_rec.last_updated_by = FND_API.g_miss_num THEN
      x_complete_rec.last_updated_by := l_code_def_rec.last_updated_by;
   END IF;

   -- last_update_login
   IF p_code_def_rec.last_update_login = FND_API.g_miss_num THEN
      x_complete_rec.last_update_login := l_code_def_rec.last_update_login;
   END IF;

   -- object_type
   IF p_code_def_rec.object_type = FND_API.g_miss_char THEN
      x_complete_rec.object_type := l_code_def_rec.object_type;
   END IF;

   -- column_name
   IF p_code_def_rec.column_name = FND_API.g_miss_char THEN
      x_complete_rec.column_name := l_code_def_rec.column_name;
   END IF;

   -- object_def
   IF p_code_def_rec.object_def = FND_API.g_miss_char THEN
      x_complete_rec.object_def := l_code_def_rec.object_def;
   END IF;

   -- code_definition_id
   IF p_code_def_rec.code_definition_id = FND_API.g_miss_num THEN
      x_complete_rec.code_definition_id := l_code_def_rec.code_definition_id;
   END IF;

   -- object_version_number
   IF p_code_def_rec.object_version_number = FND_API.g_miss_num THEN
      x_complete_rec.object_version_number := l_code_def_rec.object_version_number;
   END IF;
   -- Note: Developers need to modify the procedure
   -- to handle any business specific requirements.
END Complete_code_def_Rec;


PROCEDURE Update_Code_Definition(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN  NUMBER       := FND_API.G_VALID_LEVEL_FULL,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_code_def_rec               IN    code_def_rec_type,
    x_object_version_number      OUT NOCOPY  NUMBER
    )

 IS

CURSOR c_get_code_definition(creation_date DATE) IS
    SELECT *
    FROM  BIM_R_CODE_DEFINITIONS
    WHERE code_definition_id = p_code_def_rec.code_definition_id;
    -- Hint: Developer need to provide Where clause

L_API_NAME                  CONSTANT VARCHAR2(30) := 'Update_Code_Definition';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
-- Local Variables
l_object_version_number     NUMBER;
l_CODE_DEFINITION_ID    NUMBER;
l_ref_code_def_rec  c_get_Code_Definition%ROWTYPE ;
l_tar_code_def_rec  AMS_Code_Definition_PVT.code_def_rec_type := P_code_def_rec;
l_rowid  ROWID;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_Code_Definition_PVT;

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
      --AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: - Open Cursor to Select');


      OPEN c_get_Code_Definition( l_tar_code_def_rec.creation_date);

      FETCH c_get_Code_Definition INTO l_ref_code_def_rec  ;

      If ( c_get_Code_Definition%NOTFOUND) THEN
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_MISSING_UPDATE_TARGET',
   p_token_name   => 'INFO',
 p_token_value  => 'Code_Definition') ;
           RAISE FND_API.G_EXC_ERROR;
       END IF;
       -- Debug Message
       --AMS_UTILITY_PVT.debug_message('Private API: - Close Cursor');
       CLOSE     c_get_Code_Definition;



      If (l_tar_code_def_rec.object_version_number is NULL or
          l_tar_code_def_rec.object_version_number = FND_API.G_MISS_NUM ) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_VERSION_MISSING',
   p_token_name   => 'COLUMN',
 p_token_value  => 'Last_Update_Date') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      -- Check Whether record has been changed by someone else
      If (l_tar_code_def_rec.object_version_number <> l_ref_code_def_rec.object_version_number) Then
  AMS_Utility_PVT.Error_Message(p_message_name => 'API_RECORD_CHANGED',
   p_token_name   => 'INFO',
 p_token_value  => 'Code_Definition') ;
          raise FND_API.G_EXC_ERROR;
      End if;
      IF ( P_validation_level >= FND_API.G_VALID_LEVEL_FULL)
      THEN
          -- Debug message
          --AMS_UTILITY_PVT.debug_message('Private API: Validate_Code_Definition');

          -- Invoke validation procedures
          Validate_code_definition(
            p_api_version_number     => 1.0,
            p_init_msg_list    => FND_API.G_FALSE,
            p_validation_level => p_validation_level,
            p_validation_mode => JTF_PLSQL_API.g_update,
            p_code_def_rec  =>  p_code_def_rec,
            x_return_status    => x_return_status,
            x_msg_count        => x_msg_count,
            x_msg_data         => x_msg_data);
      END IF;

      IF x_return_status<>FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;
      -- replace g_miss_char/num/date with current column values

      -- Debug Message
      AMS_UTILITY_PVT.debug_message( 'Private API: Calling update table handler');
      AMS_UTILITY_PVT.debug_message( ' p_code_def_rec.code_definition_id'||p_code_def_rec.code_definition_id);
      AMS_UTILITY_PVT.debug_message( ' p_code_def_rec.code_definition_id'||l_tar_code_def_rec.code_definition_id);
      AMS_UTILITY_PVT.debug_message( ' p_code_def_rec.l_object_version_number'||p_code_def_rec.object_version_number);
      AMS_UTILITY_PVT.debug_message( ' p_code_def_rec.object_type'||p_code_def_rec.object_type);
      AMS_UTILITY_PVT.debug_message( ' p_code_def_rec.column_name'||p_code_def_rec.column_name);
      -- Invoke table handler(AMS_R_CODE_DEFINITIONS_PKG.Update_Row)
      AMS_R_CODE_DEFINITIONS_PKG.Update_Row(
          p_last_update_date  => SYSDATE,
          p_last_updated_by  => FND_GLOBAL.USER_ID,
          p_last_update_login  => FND_GLOBAL.CONC_LOGIN_ID,
          p_object_type  => p_code_def_rec.object_type,
          p_column_name  => p_code_def_rec.column_name,
          p_object_def  => p_code_def_rec.object_def,
          p_code_definition_id  => p_code_def_rec.code_definition_id,
          p_object_version_number  => p_code_def_rec.object_version_number);
          --x_object_version_number := l_trade_profile_rec.object_version_number;

      --
      -- End of API body.
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

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
     ROLLBACK TO UPDATE_Code_Definition_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO UPDATE_Code_Definition_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO UPDATE_Code_Definition_PVT;
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
End Update_Code_Definition;


PROCEDURE Delete_Code_Definition(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_commit                     IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER       := FND_API.G_VALID_LEVEL_FULL,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_code_definition_id                   IN  NUMBER,
    p_object_version_number      IN   NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Delete_Code_Definition';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_Code_Definition_PVT;

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
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

      --
      -- Api body
      --
      -- Debug Message
      AMS_UTILITY_PVT.debug_message( 'Private API: Calling delete table handler');

      -- Invoke table handler(AMS_R_CODE_DEFINITIONS_PKG.Delete_Row)
      AMS_R_CODE_DEFINITIONS_PKG.Delete_Row(
          p_CODE_DEFINITION_ID  => p_CODE_DEFINITION_ID);
      --
      -- End of API body
      --

      -- Standard check for p_commit
      IF FND_API.to_Boolean( p_commit )
      THEN
         COMMIT WORK;
      END IF;


      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

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
     ROLLBACK TO DELETE_Code_Definition_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO DELETE_Code_Definition_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO DELETE_Code_Definition_PVT;
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
End Delete_Code_Definition;



-- Hint: Primary key needs to be returned.
PROCEDURE Lock_Code_Definition(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,

    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,

    p_code_definition_id         IN  NUMBER,
    p_object_version             IN  NUMBER
    )

 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Lock_Code_Definition';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
L_FULL_NAME                 CONSTANT VARCHAR2(60) := g_pkg_name ||'.'|| l_api_name;
l_CODE_DEFINITION_ID                  NUMBER;

CURSOR c_Code_Definition IS
   SELECT CODE_DEFINITION_ID
   FROM BIM_R_CODE_DEFINITIONS
   WHERE CODE_DEFINITION_ID = p_CODE_DEFINITION_ID
   AND object_version_number = p_object_version
   FOR UPDATE NOWAIT;

BEGIN

      -- Debug Message
      AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');

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

  AMS_Utility_PVT.debug_message(l_full_name||': start');
  OPEN c_Code_Definition;

  FETCH c_Code_Definition INTO l_CODE_DEFINITION_ID;

  IF (c_Code_Definition%NOTFOUND) THEN
    CLOSE c_Code_Definition;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.g_msg_lvl_error) THEN
       FND_MESSAGE.set_name('AMS', 'AMS_API_RECORD_NOT_FOUND');
       FND_MSG_PUB.add;
    END IF;
    RAISE FND_API.g_exc_error;
  END IF;

  CLOSE c_Code_Definition;

 -------------------- finish --------------------------
  FND_MSG_PUB.count_and_get(
    p_encoded => FND_API.g_false,
    p_count   => x_msg_count,
    p_data    => x_msg_data);
  AMS_Utility_PVT.debug_message(l_full_name ||': end');
EXCEPTION

   WHEN AMS_Utility_PVT.resource_locked THEN
     x_return_status := FND_API.g_ret_sts_error;
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_API_RESOURCE_LOCKED');

   WHEN FND_API.G_EXC_ERROR THEN
     ROLLBACK TO LOCK_Code_Definition_PVT;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO LOCK_Code_Definition_PVT;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO LOCK_Code_Definition_PVT;
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
End Lock_Code_Definition;


PROCEDURE check_code_def_uk_items(
    p_code_def_rec               IN   code_def_rec_type,
    p_validation_mode            IN  VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status              OUT NOCOPY VARCHAR2)
IS
l_valid_flag  VARCHAR2(1);

BEGIN
      x_return_status := FND_API.g_ret_sts_success;
      IF p_validation_mode = JTF_PLSQL_API.g_create THEN
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'BIM_R_CODE_DEFINITIONS',
         'CODE_DEFINITION_ID = ''' || p_code_def_rec.CODE_DEFINITION_ID ||''''
         );
      ELSE
         l_valid_flag := AMS_Utility_PVT.check_uniqueness(
         'BIM_R_CODE_DEFINITIONS',
         'CODE_DEFINITION_ID = ''' || p_code_def_rec.CODE_DEFINITION_ID ||
         ''' AND CODE_DEFINITION_ID <> ' || p_code_def_rec.CODE_DEFINITION_ID
         );
      END IF;

      IF l_valid_flag = FND_API.g_false THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_CODE_DEFINITION_ID_DUPLICATE');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;

END check_code_def_uk_items;

PROCEDURE check_code_def_req_items(
    p_code_def_rec               IN  code_def_rec_type,
    p_validation_mode IN VARCHAR2 := JTF_PLSQL_API.g_create,
    x_return_status	         OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   IF p_validation_mode = JTF_PLSQL_API.g_create THEN


      IF p_code_def_rec.code_definition_id = FND_API.g_miss_num OR p_code_def_rec.code_definition_id IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','CODE_DEFINITION_ID');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_code_def_rec.object_version_number = FND_API.g_miss_num OR p_code_def_rec.object_version_number IS NULL THEN
         FND_MESSAGE.set_name('AMS', 'AMS_API_MISSING_FIELD');
         FND_MESSAGE.set_token('MISS_FIELD','OBJECT_VERSION_NUMBER');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   ELSE


      IF p_code_def_rec.code_definition_id IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_code_def_NO_code_definition_id');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;


      IF p_code_def_rec.object_version_number IS NULL THEN
 AMS_Utility_PVT.Error_Message(p_message_name => 'AMS_code_def_NO_object_version_number');
         x_return_status := FND_API.g_ret_sts_error;
         RETURN;
      END IF;
   END IF;

END check_code_def_req_items;

PROCEDURE check_code_def_FK_items(
    p_code_def_rec IN code_def_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_code_def_FK_items;

PROCEDURE check_code_def_Lookup_items(
    p_code_def_rec IN code_def_rec_type,
    x_return_status OUT NOCOPY VARCHAR2
)
IS
BEGIN
   x_return_status := FND_API.g_ret_sts_success;

   -- Enter custom code here

END check_code_def_Lookup_items;

PROCEDURE Check_code_def_Items (
    P_code_def_rec     IN    code_def_rec_type,
    p_validation_mode  IN    VARCHAR2,
    x_return_status    OUT NOCOPY   VARCHAR2
    )
IS
BEGIN

   -- Check Items Uniqueness API calls

   check_code_def_uk_items(
      p_code_def_rec => p_code_def_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

   -- Check Items Required/NOT NULL API calls

 /*  check_code_def_req_items(
      p_code_def_rec => p_code_def_rec,
      p_validation_mode => p_validation_mode,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF; */
   -- Check Items Foreign Keys API calls

   check_code_def_FK_items(
      p_code_def_rec => p_code_def_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;
   -- Check Items Lookups

   check_code_def_Lookup_items(
      p_code_def_rec => p_code_def_rec,
      x_return_status => x_return_status);
   IF x_return_status <> FND_API.g_ret_sts_success THEN
      RETURN;
   END IF;

END Check_code_def_Items;




PROCEDURE Validate_code_definition(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    p_validation_level           IN   NUMBER := FND_API.G_VALID_LEVEL_FULL,
    p_code_def_rec               IN   code_def_rec_type,
    p_validation_mode            IN    VARCHAR2,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2
    )
 IS
L_API_NAME                  CONSTANT VARCHAR2(30) := 'Validate_Code_Definition';
L_API_VERSION_NUMBER        CONSTANT NUMBER   := 1.0;
l_object_version_number     NUMBER;
l_code_def_rec  AMS_Code_Definition_PVT.code_def_rec_type;

 BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT VALIDATE_Code_Definition_;

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
              Check_code_def_Items(
                 p_code_def_rec        => p_code_def_rec,
                 p_validation_mode   => p_validation_mode,
                 x_return_status     => x_return_status
              );

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                  RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;

      Complete_code_def_Rec(
         p_code_def_rec        => p_code_def_rec,
         x_complete_rec        => l_code_def_rec
      );

      IF p_validation_level >= JTF_PLSQL_API.g_valid_level_item THEN
         Validate_code_def_Rec(
           p_api_version_number     => 1.0,
           p_init_msg_list          => FND_API.G_FALSE,
           x_return_status          => x_return_status,
           x_msg_count              => x_msg_count,
           x_msg_data               => x_msg_data,
           p_code_def_rec           =>    l_code_def_rec);

              IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                 RAISE FND_API.G_EXC_ERROR;
              ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                 RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
              END IF;
      END IF;


      -- Debug Message
     -- AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'start');


      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


      -- Debug Message
     -- AMS_UTILITY_PVT.debug_message('Private API: ' || l_api_name || 'end');

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
     ROLLBACK TO VALIDATE_Code_Definition_;
     x_return_status := FND_API.G_RET_STS_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count   => x_msg_count,
            p_data    => x_msg_data
     );

   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO VALIDATE_Code_Definition_;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     -- Standard call to get message count and if count=1, get the message
     FND_MSG_PUB.Count_And_Get (
            p_encoded => FND_API.G_FALSE,
            p_count => x_msg_count,
            p_data  => x_msg_data
     );

   WHEN OTHERS THEN
     ROLLBACK TO VALIDATE_Code_Definition_;
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
End Validate_Code_Definition;


PROCEDURE Validate_code_def_rec(
    p_api_version_number         IN   NUMBER,
    p_init_msg_list              IN   VARCHAR2     := FND_API.G_FALSE,
    x_return_status              OUT NOCOPY  VARCHAR2,
    x_msg_count                  OUT NOCOPY  NUMBER,
    x_msg_data                   OUT NOCOPY  VARCHAR2,
    p_code_def_rec               IN    code_def_rec_type
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
     -- AMS_UTILITY_PVT.debug_message('Private API: Validate_dm_model_rec');
      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
        (p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );
END Validate_code_def_Rec;

END AMS_Code_Definition_PVT;

/
